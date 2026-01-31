#include 'Protheus.ch'
#include 'FWMVCDef.ch'
#include 'FWADAPTEREAI.CH'
#include 'MATA010PPI.CH'

Static _lFunLite := FindFunction("PCPMESHabl")

/*/{Protheus.doc} MATA010PPI
Classe de eventos para integração do produto com o PC Factory.

Importante: Use somente a função Help para exibir mensagens ao usuario, pois apenas o help
é tratado pelo MVC. 

Documentação sobre eventos do MVC: http://tdn.totvs.com/pages/viewpage.action?pageId=269552294

@type classe
 
@author Juliane Venteu
@since 14/03/2017
@version P12.1.17
 
/*/
CLASS MATA010PPI FROM FWModelEvent
	
	DATA nOpc
	DATA cXML
	DATA cProduto
	DATA lExclusao
	DATA lFiltra
	DATA lPendAut
	DATA lShowHlp
	DATA lFiltroAnt
	DATA nAlterData
	
	METHOD New() CONSTRUCTOR
	METHOD BeforeTTS(oModel, cModelID)
	METHOD InTTS()
	METHOD execute()
	METHOD intMESLite()
	
ENDCLASS

//-----------------------------------------------------------------
METHOD New(cXml, cProd, lExclusao, lFiltra, lPendAut, lShowHlp) CLASS MATA010PPI

	Default cXml      := ""
	Default cProd     := ""
	Default lExclusao := .F.
	Default lFiltra   := .T.
	Default lPendAut  := .F.
	Default lShowHlp  := .T.

	::cXML       := cXml
	::cProduto   := cProd
	::lExclusao  := lExclusao
	::lFiltra    := lFiltra
	::lPendAut   := lPendAut
	::lShowHlp   := lShowHlp
	::lFiltroAnt := .F.
	::nAlterData := 0
Return

/*/{Protheus.doc} BeforeTTS
Método que é chamado pelo MVC quando ocorrer as ações do commit antes da transação

@author lucas.franca
@since 07/10/2024
@version P12
@param 01 oModel  , Object   , Modelo de dados
@param 02 cModelId, Character, ID do modelo de dados
@return Nil
/*/
METHOD BeforeTTS(oModel, cModelID) Class MATA010PPI
	Local aAreaB1   := SB1->(GetArea())
	Local oModelSB1 := oModel:GetModel("SB1MASTER")
	
	::nAlterData := 2 // não integra o produto com MES LITE
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1") + oModelSB1:getValue("B1_COD")))
	EndIf

	//Verifica se a alteração realizada tem necessidade de integrar com o MES LITE.
	If oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. ;
	   (oModel:GetOperation() == MODEL_OPERATION_UPDATE .And.;
	   oModelSB1:getValue("B1_DESC"  ) != SB1->B1_DESC  .Or. ;
	   oModelSB1:getValue("B1_LE"    ) != SB1->B1_LE    .Or. ;
	   oModelSB1:getValue("B1_UM"    ) != SB1->B1_UM    .Or. ;
	   oModelSB1:getValue("B1_FPCOD" ) != SB1->B1_FPCOD .Or. ;
	   oModelSB1:getValue("B1_MSBLQL") != SB1->B1_MSBLQL)
		
		::nAlterData := 1 // permite integrar o produto com MES LITE
	EndIf

	If ::nAlterData == 2
		//Se não alterou alguma informação que faz o produto integrar, verifica se os filtros atuais
		//para integração do produto fazem o produto não ser integrado.
		//Depois, será verificado se com os dados alterados o produto passa nos filtros, nesse caso executa a integração.
		::lFiltroAnt := PCPFiltPPI("SB1", SB1->B1_COD, "SB1")
	EndIf

	SB1->(RestArea(aAreaB1))
	aSize(aAreaB1, 0)

Return

METHOD InTTS(oModel) CLASS MATA010PPI
	Local aArea     := GetArea()
	Local aFilInt   := getFilInt()
	Local aRetArq   := {}
	Local aRetData  := {}
	Local aRetWS    := {}
	Local aRetXML   := {}
	Local cFilBkp   := cFilAnt
	Local cGerouXml := ""
	Local cNomeXml  := ""
	Local cXmlAnt   := ""
	Local lIntgPPI  := .F.
	Local lMESLite  := .F.
	Local lRet      := .T.
	Local nIndex    := 0
	Local nTotFil   := Len(aFilInt)

	//Variável utilizada para identificar que está sendo executada a integração para o PPI dentro do MATI010.
	Private lRunPPI := .T.

	If !Empty(::cXml)
		aFilInt := {cFilAnt}
		nTotFil := 1
		If _lFunLite 
			PCPMESHabl("SB1", cFilAnt, @lMESLite)
		EndIf
		If PCPEvntXml(::cXml, lMESLite) == "delete"
			::lExclusao := .T.
		EndIf
	EndIf
	
	If Empty(::cProduto)
		::cProduto := SB1->B1_COD
	EndIf

	For nIndex := 1 To nTotFil

		cFilAnt  := aFilInt[nIndex]
		lIntgPPI := .F.

		If _lFunLite .And. PCPMESHabl("SB1", cFilAnt, @lMESLite)
			lIntgPPI := !lMESLite
			If lMESLite
				::lExclusao := ::lExclusao .Or. (oModel != Nil .And. oModel:GetOperation() == MODEL_OPERATION_DELETE)
				lRet := Self:intMESLite()
			EndIf
		Else
			//Verifica se a filial integra com a PPI
			dbSelectArea("SOD")
			SOD->(dbSetOrder(1))
			If SOD->(dbSeek(cFilAnt+"1"))
				lIntgPPI = .T.
				If (ExistBlock('PCPXFUNPPI'))
					lIntgPPI := ExecBlock('PCPXFUNPPI',.F.,.F.,FunName())
				EndIf
			EndIf
			RestArea(aArea)
		EndIf
		If !lIntgPPI
			Loop
		EndIf

		//Realiza filtro na tabela SOE, para verificar se o produto entra na integração.
		If !Empty(::cXml) .Or. !::lFiltra .Or. PCPFiltPPI("SB1", ::cProduto, "SB1")
			//Adapter para criação do XML
			If Empty(::cXml)
				aRetXML := MATI010("", TRANS_SEND, EAI_MESSAGE_BUSINESS)
			Else
				aRetXML := {.T.,::cXml}
			EndIf
			/*
				aRetXML[1] - Status da criação do XML
				aRetXML[2] - String com o XML
			*/
			If aRetXML[1]
				//Retira os caracteres especiais
				cXmlAnt    := aRetXML[2] //Guarda o xml antes da retirada dos caracteres especiais
				aRetXML[2] := EncodeUTF8(aRetXML[2])

				//Verifica se houve a conversão de todos os caracteres especiais
				//Quando não há, o retorno do EncodeUTF fica nulo.
				If aRetXML[2] == NIL
					lRet := .F.
					aAdd(aRetWS,"3")
				 	aRetXML[2] := cXmlAnt // Apresenta o xml para o cliente identificar os caracteres especiais
					aAdd(aRetWS,STR0001 + ' ' + ::cProduto) //Não é possível enviar Xml com caracteres especiais. É necessário revisar o cadastro do produto XXXX

					//Busca a data/hora de geração do XML
					aRetData := PCPxDtXml(aRetXML[2])
					/*
						aRetData[1] - Data de geração AAAAMMDD
						aRetData[1] - Hora de geração HH:MM:SS
					*/
				Else

					//Busca a data/hora de geração do XML
					aRetData := PCPxDtXml(aRetXML[2])
					/*
						aRetData[1] - Data de geração AAAAMMDD
						aRetData[1] - Hora de geração HH:MM:SS
					*/

					//Envia o XML para o PCFactory
					aRetWS := PCPWebsPPI(aRetXML[2])
					/*
						aRetWS[1] - Status do envio (1 - OK, 2 - Pendente, 3 - Erro.)
						aRetWS[2] - Mensagem de retorno do PPI
					*/			
				EndIf
	
				If aRetWS[1] != "1" .And. Empty(::cXml)
					Help(" ",1,AllTrim(aRetWS[2]))
					lRet := .F.
				EndIf

				//Cria o XML fisicamente no diretório parametrizado
				aRetArq := PCPXmLPPI(aRetWS[1],"SB1",::cProduto,aRetData[1],aRetData[2],aRetXML[2])
				/*
					aRetArq[1] Status da criação do arquivo. .T./.F.
					aRetArq[2] Nome do XML caso tenha criado. Mensagem de erro caso não tenha criado o XML.
				*/

				If !aRetArq[1]
					Help(" ",1,AllTrim(aRetArq[2]))
					lRet := .F.
				Else
					cNomeXml := aRetArq[2]
				EndIf
   	        
				If Empty(cNomeXml)
					cGerouXml := "2"
				Else
					cGerouXml := "1"
				EndIf
   	        
				//Cria a tabela SOF
				PCPCriaSOF("SB1",::cProduto,aRetWS[1],cGerouXml,cNomeXml,aRetData[1],aRetData[2],__cUserId,aRetWS[2],aRetXML[2])
			EndIf
		EndIf
	Next nIndex

	If cFilAnt != cFilBkp
		cFilAnt := cFilBkp
	EndIf

	If len(aRetWS) >0 
		If aRetWS[1] != "1"  .And. AllTrim(FunName()) == "PCPA111"
			lRet := .F.
		EndIf 
	EndIf
	
	::nAlterData := 0
	
	RestArea(aArea)
Return lRet

METHOD execute() CLASS MATA010PPI
Return ::InTTS()

/*/{Protheus.doc} intMESLite
Executa a integração do produto com o MES Lite

@author lucas.franca
@since 07/10/2024
@version P12
@return lRet, Logical, Indica se integrou com sucesso
/*/
Method intMESLite() CLASS MATA010PPI
	Local aAreaPrd  := {}
	Local aRetArq   := {}
	Local cEndPoint := "/api/v1/exchange/product"
	Local cCode     := ""
	Local cData     := DtoS(Date())
	Local cError    := ""
	Local cGerouArq := "2"
	Local cHelp     := ""
	Local cHora     := Time()
	Local cNomeArq  := ""
	Local cRetAPI   := ""
	Local cRetorno  := ""
	Local cStatus   := ""
	Local lFiltro   := .F.
	Local lFalha    := .F.
	Local lRet      := .F.
	Local oConMES   := Nil
	Local oDataEnv  := Nil

	lFiltro := Self:lFiltra == .F. .Or. !Empty(Self:cXml) .Or. PCPFiltPPI("SB1", ::cProduto, "SB1")

	/*
		Vai integrar o produto se:
		Alterou algum dado que é enviado para o MES LITE E o produto atende aos filtros definidos no PCPA109 - ::nAlterData < 2
		OU
		O produto está atendendo os filtros definidos no PCPA109 após e alteração E antes da alteração não atendia aos filtros do PCPA109. - !::lFiltroAnt
		OU
		Produto atende os filtros do PCPA109 e está excluindo o produto - ::lExclusao
	*/

	If lFiltro .And. (::nAlterData < 2 .Or. !::lFiltroAnt .Or. ::lExclusao)
		
		oConMES := MESLiteConnection():New()
		
		If ::lExclusao
			lRet := oConMES:executaDelete(cEndPoint, { {"code", RTrim(::cProduto)} })
		Else
			If Empty(Self:cXml)
				aAreaPrd := SB1->(GetArea())

				SB1->(dbSetOrder(1))
				SB1->(dbSeek(xFilial("SB1") + ::cProduto))
				
				oDataEnv := PCPPrdMLit()
				SB1->(RestArea(aAreaPrd))
				aSize(aAreaPrd, 0)
			Else
				oDataEnv := JsonObject():New()
				oDataEnv:FromJson(Self:cXml)
			EndIf
			
			lRet := oConMES:executaPost(cEndPoint, oDataEnv)
			
			FreeObj(oDataEnv)
		EndIf

		If lRet
			cStatus  := "1"
			cRetorno := "OK"
		Else
			oConMES:retornoAPI(@cCode, @cRetAPI, @cError, @lFalha)
			cStatus  := Iif(lFalha, "2", "3")
			cRetorno := Iif(Empty(cError), cRetAPI, cError)
			If ::lShowHlp .And. (::lExclusao .And. cStatus == "3" .And. cCode == "404") == .F.
				cHelp    := STR0002 + CHR(10) + cRetorno //"Erro ao integrar o produto com o TOTVS MES."
				Help( ,, 'Help',, cHelp , 1, 0 )
			EndIf
		EndIf

		aRetArq := PCPXmLPPI(cStatus, "SB1", ::cProduto, cData, cHora, oConMES:getJsonEnviado(), .T.)
		If aRetArq[1]
			cNomeArq := aRetArq[2]
		
		ElseIf !Empty(aRetArq[2]) .And. ::lShowHlp
			cHelp := STR0003 + CHR(10) + aRetArq[2] //"Erro ao salvar a mensagem de integração do TOTVS MES."
			Help( ,, 'Help',, cHelp , 1, 0 )
		EndIf

		If !Empty(cNomeArq)
			cGerouArq := "1"
		EndIf

		PCPCriaSOF("SB1", ::cProduto, cStatus, cGerouArq, cNomeArq, cData, cHora, __cUserId, cRetorno, oConMES:getJsonEnviado(), .T.)

		oConMES:Destroy()
		FreeObj(oConMES)

		aSize(aRetArq, 0)
	EndIf
Return lRet

/*/{Protheus.doc} PCPPrdMLit
Retorna o JSON com os dados do produto para integração MES LITE.
Para uso, a tabela SB1 já deve estar posicionada no produto correto.

@type  Function
@author lucas.franca
@since 07/10/2024
@version P12
@return oProd, Object, JSON com os dados do produto para envio
/*/
Function PCPPrdMLit()
	Local oProd := JsonObject():New()
	
	oProd["code"      ] := RTrim(SB1->B1_COD)
	oProd["familyCode"] := RTrim(SB1->B1_FPCOD)
	oProd["name"      ] := RTrim(SB1->B1_DESC)
	oProd["quantity"  ] := SB1->B1_LE
	oProd["unit"      ] := RTrim(SB1->B1_UM)
	oProd["enable"    ] := SB1->B1_MSBLQL <> "1"
	oProd["operations"] := {}
Return oProd
