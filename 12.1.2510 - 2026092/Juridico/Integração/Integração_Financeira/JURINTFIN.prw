#INCLUDE "JURINTFIN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TRYEXCEPTION.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JurIntFin()
Rotina responsavel pela integração financeira a partir da tabela O0U

@param	 nOper 	 	- Tipo de operação executada na integração
@param	 cTabInt 	- Tabela que originou a integração
@param 	 oModelAct	- Modelo ativo que sera atualizado com o retorno
@return  cXml 	 	- XML com o conteudo dos campos e formulas

@author	 Rafael Tenorio da Costa
@since 	 20/09/18
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurIntFin(nOper, cTabInt, oModelAct)

Local aArea      := GetArea()
Local aAreaNSZ   := NSZ->( GetArea() )
Local aAreaSA2   := SA2->( GetArea() )
Local aRetorno   := {.T., ""}
Local cTipo      := IIF(cTabInt == "NT2", "1", "2")	//1=Garantia;2=Despesa
Local cAcao      := IIF(nOper == 3, "1", "3")		//1=Inclusão de Título;2=Consulta de Saldo;3=Exclusão de Título
Local oRestCli   := Nil
Local cChaveNSZ  := StrTran("M->NT2_CAJURI"				, "NT2", cTabInt)
Local cChaveSA2  := StrTran("M->NT2_CFORNT+M->NT2_LFORNT", "NT2", cTabInt)
Local nIndex     := 0


	DbSelectArea("O0U")
	nIndex := Ordkey(2)

	If !Empty(nIndex)

		O0U->( DbSetOrder(2) )	//O0U_FILIAL+O0U_TIPO+O0U_ACAO+O0U_STATUS
		O0U->( dbGoTop() )

		If O0U->( DbSeek(xFilial("O0U") + cTipo + cAcao + "1") )

			//Posiciona tabelas que podem ser utilizadas no XML
			DbSelectArea("NSZ")
			NSZ->( DbSetOrder(1) )
			NSZ->( DbSeek( xFilial(cTabInt) + &(cChaveNSZ) ) )

			DbSelectArea("SA2")
			SA2->( DbSetOrder(1) )
			SA2->( DbSeek( xFilial("SA2") + &(cChaveSA2) ) )

			//Instancia apenas 1 vez o objeto o caminho absoluto passamos no metodo path
			oRestCli 		  := FWRest():New("")
			oRestCli:nTimeOut := 600

			While !O0U->( Eof() ) .And. O0U->O0U_TIPO == cTipo .And. O0U->O0U_ACAO == cAcao .And. O0U->O0U_STATUS == "1"

				//Efetua a integração financeira
				aRetorno := Integra(cTabInt, oRestCli)

				//Grava retorno da integração
				GravaRet(cTabInt, aRetorno, oModelAct)

				//Se conseguiu efetuar a integração limpa msg de retorno
				If aRetorno[1]
					aRetorno[2] := ""
				EndIf

				O0U->( DbSkip() )
			EndDo

			FwFreeObj(oRestCli)
		EndIf
	EndIf

	RestArea(aAreaSA2)
	RestArea(aAreaNSZ)
	RestArea(aArea)

Return aRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} Integra()
Efetua a integração financeira

@param	 cTabInt  - Tabela que originou a integração
@param	 oRestCli - Objeto REST utilizado para integrar com o outro sistema
@return  aRetorno - Define se executou corretamente, descrição do retorno

@author	 Rafael Tenorio da Costa
@since 	 20/09/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Integra(cTabInt, oRestCli)

	Local lRet 		:= .T.
	Local cRet 		:= ""
	Local aRetorno	:= Array(2)
	Local cXmlRet	:= ""
	Local aHeadOut 	:= {}
	Local cWsdl 	:= AllTrim(O0U->O0U_WSDL)
	Local cOperWsdl := AllTrim(O0U->O0U_OPERAC)
	Local cTagSta	:= AllTrim(O0U->O0U_TAGSTA)
	Local cTagCod	:= AllTrim(O0U->O0U_TAGCOD)
	Local cTagErro  := AllTrim(O0U->O0U_TAGERR)
	Local cUser 	:= AllTrim(O0U->O0U_USER)
	Local cSenha 	:= AllTrim(O0U->O0U_SENHA)
	Local cXml 	  	:= CarregaXml(cTabInt, EncodeUtf8( O0U->O0U_LAYOUT ))

	If Empty(cTagCod)
		lRet := .F.
		cRet := I18n(STR0001, {STR0002}) + CRLF	//"Tag para localizar retorno de #1 não preenchida."	//"sucesso"
	EndIf

	If Empty(cTagErro)
		lRet := .F.
		cRet += I18n(STR0001, {STR0003})	//"Tag para localizar retorno de #1 não preenchida."	//"erro"
	EndIf

	If lRet
		oRestCli:SetPath(cWsdl + cOperWsdl)

		Aadd(aHeadOut,'content-type: text/xml;charset=UTF-8')
		Aadd(aHeadOut,'soapaction: http://sap.com/xi/WebService/soap1.1')
		Aadd(aHeadOut,'User-Agent: Mozilla/5.0 (Compatible)')
		Aadd(aHeadOut,'accept-encoding: gzip,deflate')
		Aadd(aHeadOut,'accept-charset: windows-1251,iso-8859-1,utf-8;q=0.7,*;q=0.7')
		Aadd(aHeadOut,'accept:*/*')
		Aadd(aHeadOut,'Connection: Keep-Alive')
		Aadd(aHeadOut,'cache-control: no-cache')

		If !Empty(cUser)
			Aadd(aHeadOut, "Authorization:  BASIC " + Encode64(cUser + ":" + cSenha))
		EndIf

		oRestCli:SetPostParams(cXml)

		If oRestCli:Post(aHeadOut)

			cXmlRet := oRestCli:GetResult()

			//Verifica a TAG com status de sucesso
			If !Empty(cTagSta)
				lRet := At(cTagSta, cXmlRet) > 0
			EndIf

			//Pega retorno de positivo
			If lRet
				cRet := JurGetTag(cXmlRet, cTagCod, .F.)
			EndIf

			If Empty(cRet)

				//Pega retorno negativo
				lRet := .F.
				cRet := JurGetTag(cXmlRet, cTagErro, .F.)
				cRet := STR0004 + CRLF +;							//"Não foi possível efetuar a integração financeira."
						STR0005 + IIF(Empty(cRet), cXmlRet, cRet)	//"Retorno: "
			EndIf

		Else
			lRet := .F.
			cRet := I18n(STR0006, {cWsdl + cOperWsdl}) + CRLF +;	//"Não foi possível conectar ao serviço #1"
						 STR0005 + oRestCli:GetLastError()			//"Retorno: "
		EndIf
	EndIf

	aRetorno[1] := lRet
	aRetorno[2] := cRet	

	If GetSrvProfString( "Trace", "0" ) == "1" //Grava XML de envio no Log
		JurConOut("xml envio financeiro: " + cXml)
		JurConOut("recebimento financeiro: " + cXmlRet)
	EndIf

Return aRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaRet()
Grava o retorno da integração

@param cTabInt		- Tabela que será integrada
@param aRetorno		- Retorno da integração
@param oModelAct	- Modelo ativo que sera atualizado

@author	 Rafael Tenorio da Costa
@since 	 24/09/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GravaRet(cTabInt, aRetorno, oModelAct)

	Local cModelo	:= cTabInt + "MASTER"
	Local oModelAux := Nil
	Local cCmpCod 	:= AllTrim(O0U->O0U_CMPCOD)
	Local cCmpErro 	:= AllTrim(O0U->O0U_CMPERR)
	Local cCampo	:= ""
	Local xConteudo	:= Nil

	If aRetorno[1]
		cCampo := cCmpCod
	Else
		cCampo := cCmpErro
	EndIf

	If !Empty(cCampo)

		If oModelAct <> Nil

			oModelAux := oModelAct:GetModel(cModelo)

			If oModelAux <> Nil .And. oModelAux:HasField(cCampo)

				//Ponto de entrada para tratar o retorno que será gravado
				If ExistBlock("JUINFIGR")
					xConteudo := ExecBlock("JUINFIGR", .F., .F., {cCampo, aRetorno[2]})
				EndIf

				If xConteudo == Nil
					xConteudo := aRetorno[2]
				EndIf

				oModelAux:LoadValue(cCampo, xConteudo)
			Else
				JurMsgErro( I18n(STR0007, {cCampo, aRetorno[2]}) )	//"Campo (#1) para gravar o retorno, não localizado no modelo: #2"
			EndIf

		EndIf

	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} CarregaXml()
Carrega o conteudo dos campos e as formulas do XML

@param	 cTabInt - Tabela que originou a integração
@param	 cLayout - Layout com o XML que sera atualizado
@return  cXml 	 - XML com o conteudo dos campos e formulas

@author	 Rafael Tenorio da Costa
@since 	 20/09/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CarregaXml(cTabInt, cLayout)
Local cXml       := cLayout
Local cAux       := ""
Local cCampo     := ""
Local cFormula   := ""
Local xConteudo  := ""
Local oError     := Nil
Local cTabCmp    := ""
Local aAreaAux   := {}

	If At("NSR_", cXml) > 0
		aAreaAux := NSR->( GetArea() )
		DbSelectArea("NSR")
		NSR->( DbSetOrder(1) ) //NSR_FILIAL+NSR_COD
		NSR->( DbSeek( xFilial("NSR") + M->NT3_CTPDES ) )
	EndIf

	//Carrega conteudo dos campos %CAMPO%
	While ( nPosIni:= At("%", cXml) ) > 0

		//Carrega campo
		cAux 	:= SubStr(cXml, nPosIni + 1)
		nPosFim := At("%", cAux)
		cCampo  := SubStr(cAux, 1, nPosFim - 1)

		cTabCmp := Left(cCampo, At("_", cCampo) - 1)

		//Busca conteudo
		Do Case
			Case cTabCmp == cTabInt
				xConteudo := &("M->" + cCampo)

			Case cTabCmp == "NSZ"
				xConteudo := &("NSZ->" + cCampo)

			Case cTabCmp == "A2"
				xConteudo := &("SA2->" + cCampo)

			Case cTabCmp == "NSR"
				xConteudo := &("NSR->" + cCampo)

			OTherWise
				xConteudo := cCampo
		End Case

		//Atualiza XML
		xConteudo := TrataCmp(xConteudo)
		cXml 	  := SubStr(cXml, 1, nPosIni - 1) + xConteudo +  SubStr(cXml, nPosIni + nPosFim + 1)
	EndDo

	//Carrega conteudo das formulas $FORMULA$
	While ( nPosIni:= At("$", cXml) ) > 0

		//Carrega formula
		cAux 	:= SubStr(cXml, nPosIni + 1)
		nPosFim := At("$", cAux)
		cFormula:= SubStr(cAux, 1, nPosFim - 1)

		//Executa formula
		TRY EXCEPTION
			//Condição que pode dar erro
			xConteudo := &(cFormula)
		CATCH EXCEPTION USING oError
			//Se ocorreu erro
			xConteudo := Nil
		ENDTRY

		If xConteudo == Nil
			xConteudo := I18n(STR0008, {cFormula})	//"Erro na execução da formula: #1"
		EndIf

		//Atualiza XML
		xConteudo := TrataCmp(xConteudo)
		cXml	  := SubStr(cXml, 1, nPosIni - 1) + xConteudo +  SubStr(cXml, nPosIni + nPosFim + 1)
	EndDo

Return cXml

//-------------------------------------------------------------------
/*/{Protheus.doc} TrataCmp()
Formata os campos a partir do seu conteudo

@param	 xConteudo	- Conteúdo a ser formatado
@return  xConteudo 	- Conteúdo formatado

@author	 Rafael Tenorio da Costa
@since 	 20/09/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TrataCmp(xConteudo)

	Local cTipo := ValType(xConteudo)

	Do Case
		Case cTipo $ "C|M"
			xConteudo := AllTrim(xConteudo)

		Case cTipo == "D"
			xConteudo := DtoS(xConteudo)

		Case cTipo == "N"
			xConteudo := cValToChar(xConteudo)
	End Case

Return xConteudo