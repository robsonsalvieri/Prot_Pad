#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"
#Include "TBICONN.CH"
#Include "GPEA923API.ch"

#DEFINE HELP_URL "https://tdn.totvs.com/x/ZYNvI"
#DEFINE ERRORCODE_DEF	400 // Erro no momento da listagem do registro.
#DEFINE ERRORSRV_DEF	500 // Erro no acesso ao EndPoint.
#DEFINE TAB  			CHR ( 13 ) + CHR ( 10 )

Private oError		As Object
Private bError      := { |e| oError := e, Break(e) }
Private bErrorBlock := ErrorBlock( bError )

// Serviço genérico para controle das informações de Controle de Estabilidade
WSRESTFUL stabilityControl DESCRIPTION OemToAnsi(STR0001) FORMAT ("application/json") // Serviço genérico para controle das informações de Controle de Estabilidade
	WSDATA authorization 	As Character
	WSDATA stabilityId 		As Character
	WSDATA page			 	As Integer Optional
	WSDATA pageSize		 	As Integer Optional

	WSMETHOD POST;
	DESCRIPTION EncodeUTF8(OemToAnsi(STR0002)); // Inclui um novo Período de Estabilidade no módulo SIGAGPE
	WSSYNTAX "/api/rh/v1/stabilityControl" ;
	PATH "/api/rh/v1/stabilityControl" ;
	PRODUCES 'application/json;charset=utf-8';
	TTALK "v1"

	WSMETHOD PUT stabilityId ;
  	DESCRIPTION EncodeUTF8(OemToAnsi(STR0004)) ;
  	WSSYNTAX "/api/rh/v1/stabilityControl/{stabilityId}" ; //Altera um Período de Estabilidade no módulo SIGAGPE
  	PATH "/api/rh/v1/stabilityControl/{stabilityId}" ;
  	PRODUCES 'application/json;charset=utf-8' ;
  	TTALK "v1"

	WSMETHOD DELETE stabilityId ;
  	DESCRIPTION EncodeUTF8(OemToAnsi(STR0003)) ; //Delete um Período de Estabilidade no módulo SIGAGPE
  	WSSYNTAX "/api/rh/v1/stabilityControl/{stabilityId}" ;
  	PATH "/api/rh/v1/stabilityControl/{stabilityId}" ;
  	PRODUCES 'application/json;charset=utf-8' ;
  	TTALK "v1"

END WSRESTFUL

/*/{Protheus.doc} DELETE
// Método responsável pela exclusão do Período de Estabiliade de um funcionário.
@author raquel.andrade
@since 12/03/2020
@version 1.0
@return return, return_description
/*/
WSMETHOD DELETE stabilityId WSREST stabilityControl

	Local aUrlParam	:= ::aUrlParms
	Local jQryParams := oRest:getQueryRequest()	as Json

	Local aDelChv		As Array
	Local lRetorno		As Logical
	Local jEstab		As Object
	Local cChave     := ""
	Local cEmpAntBck := cEmpAnt
	Local cFilAntBck := cFilAnt
	Local cParEmp    := cEmpAnt
	Local cParFil    := cFilAnt
	Local nCodRet    := 0

	DEFAULT Self:authorization  := ""
	DEFAULT Self:stabilityId   	:= ""

	jEstab		:= JsonObject():New()
	lRetorno	:= .T.

	BEGIN SEQUENCE

		If jQryParams:hasProperty("forcaErro")
			BREAK
		Endif

		If !Empty(aUrlParam)
			cChave = aUrlParam[1]
		EndIf

		if Empty(cChave)
			nCodRet := ERRORCODE_DEF
			// "Informação stabilityId ausente ou inválida." ### "Erro na validação do recebimento da mensagem."
			SetRestFault(ERRORCODE_DEF, EncodeUTF8(STR0005), .T. ,ERRORCODE_DEF , EncodeUTF8(STR0006) , HELP_URL, )
			lRetorno := .F.
			BREAK
		EndIf

		If Empty(cChave) .Or. Len(fIdValid(cChave, @aDelChv )) == 0
			nCodRet := ERRORCODE_DEF
			// "Informação stabilityId ausente ou inválida." ### "Erro na validação do recebimento da mensagem."
			SetRestFault(ERRORCODE_DEF, EncodeUTF8(STR0005), .T. ,ERRORCODE_DEF , EncodeUTF8(STR0006) , HELP_URL, )
			lRetorno := .F.
			BREAK
		EndIf

		If lRetorno	.And. Len(aDelChv) > 0

			cParEmp	:= aDelChv[1]
			cParFil	:= aDelChv[2]
			If cEmpAntBck <> cParEmp .Or. cFilAntBck <> cParFil
				fTrGrpGPE(cParEmp, cParFil, "RFX", "GPE")
			EndIf

			lRetorno	:= fDelData(@jEstab, aDelChv)

			If lRetorno
				cResponse := fCompress(@jEstab)
				::SetResponse(cResponse)
			Else
				//"Ocorreu uma falha no retorno desta operação." ### "Erro na validação do recebimento da mensagem."
				SetRestFault(ERRORCODE_DEF, EncodeUTF8(STR0011), .T. ,ERRORCODE_DEF , EncodeUTF8(STR0006) , HELP_URL, )
			EndIf

		EndIf

	RECOVER
		If nCodRet == 0
			lRetorno := .F.
			// "Ocorreu uma falha no retorno da informação."
			SetRestFault(ERRORSRV_DEF ,  EncodeUTF8(STR0008) ,.T. ,ERRORSRV_DEF  , STR0011 , HELP_URL, )
		EndIf

	END SEQUENCE

	If cEmpAntBck <> cParEmp .Or. cFilAntBck <> cParFil
		fTrGrpGPE(cEmpAntBck, cFilAntBck)
	EndIf

Return lRetorno


/*/{Protheus.doc} PUT
// Método responsável pela alteração do Período de Estabiliade de um funcionário.
@author raquel.andrade
@since 12/03/2020
@version 1.0
@return return, return_description
/*/
WSMETHOD PUT stabilityId WSREST stabilityControl

	Local aUrlParam	:= ::aUrlParms
	Local jQryParams := oRest:getQueryRequest()	as Json

	Local aTemp   := {}
	Local aCodi   := {}
	Local aFunc   := {}
	Local aPutChv := {}
	Local aChvPr  := {}
	Local cBody			as Character
	Local lRetorno 		As Logical
	Local jEstab		As Object
	Local cChave     := ""
	Local cEmpAntBck := cEmpAnt
	Local cFilAntBck := cFilAnt
	Local cParEmp    := cEmpAnt
	Local cParFil    := cFilAnt
	Local nCodRet    := 0

	DEFAULT Self:authorization  := ""
	DEFAULT Self:stabilityId   	:= ""

	cBody     	:= ::GetContent()
	lRetorno 	:= .T.
	jEstab		:= JsonObject():New()
	jEstab:FromJSON(EncodeUTF8(NoAcento(cBody)))

	BEGIN SEQUENCE

		If jQryParams:hasProperty("forcaErro")
			BREAK
		Endif

		if Empty(aUrlParam) .OR. Len(aUrlParam) == 0
			// "Informação stabilityId ausente ou inválida." ### "Erro na validação do recebimento da mensagem."
			SetRestFault(ERRORCODE_DEF, EncodeUTF8(STR0005), .T. ,ERRORCODE_DEF , EncodeUTF8(STR0006) , HELP_URL, )
			lRetorno := .F.
			return (lRetorno)
		else
			cChave = aUrlParam[1]
		EndIf

		aTemp := StrTokArr2(cChave,";",.T.)

		If ( Len(aTemp) < 5)
			SetRestFault(ERRORCODE_DEF, EncodeUTF8(STR0005), .T. ,ERRORCODE_DEF , EncodeUTF8(STR0006) , HELP_URL, )
			lRetorno := .F.
			Return (lRetorno)
		EndIf

		aFunc := StrTokArr2(aTemp[3],"|",.T.)

		aCodi := StrTokArr2(aTemp[5],"|",.T.)

		If ( Len(aFunc) < 3)
			SetRestFault(ERRORCODE_DEF, EncodeUTF8(STR0005), .T. ,ERRORCODE_DEF , EncodeUTF8(STR0006) , HELP_URL, )
			lRetorno := .F.
			Return (lRetorno)
		EndIf
		If ( Len(aCodi) < 3)
			SetRestFault(ERRORCODE_DEF, EncodeUTF8(STR0005), .T. ,ERRORCODE_DEF , EncodeUTF8(STR0006) , HELP_URL, )
			lRetorno := .F.
			Return (lRetorno)
		EndIf

		aChvPr	:=  {	aTemp[1],;
		 				aTemp[2],;
						aFunc[1],;
						aFunc[2],;
						aFunc[3],;
						aTemp[3],;
						aCodi[1],;
						aCodi[2],;
						aCodi[3],;
			     	}

		If Empty(cChave) .Or. Len(fIdValid(cChave, @aPutChv )) == 0
			// "Informação stabilityId ausente ou inválida." ### "Erro na validação do recebimento da mensagem."
			SetRestFault(ERRORCODE_DEF, EncodeUTF8(STR0005), .T. ,ERRORCODE_DEF , EncodeUTF8(STR0006) , HELP_URL, )
			lRetorno := .F.
		ElseIf !fTratDados(@jEstab,,,aChvPr,4)
				lRetorno	:= .F.
		EndIf

		If lRetorno	.And. Len(aPutChv) > 0

			cParEmp	:= aPutChv[1]
			cParFil	:= aPutChv[2]
			If cEmpAntBck <> cParEmp .Or. cFilAntBck <> cParFil
				fTrGrpGPE(cParEmp,cParFil, "RFX", "GPE")
			EndIf

			cChave := STRTran(cChave,";","|")

			lRetorno	:= fPutData(@jEstab, aPutChv, cBody, cChave)

			If lRetorno
				cResponse := fCompress(@jEstab)
				::SetResponse(cResponse)
			Else
				//"Ocorreu uma falha no retorno desta operação." ### "Erro na validação do recebimento da mensagem."
				SetRestFault(ERRORCODE_DEF, EncodeUTF8(STR0011), .T. ,ERRORCODE_DEF , EncodeUTF8(STR0006) , HELP_URL, )
			EndIf

		EndIf

	RECOVER
		If nCodRet == 0
			lRetorno := .F.
			// "Ocorreu uma falha no retorno da informação."
			SetRestFault(ERRORSRV_DEF ,  EncodeUTF8(STR0008) ,.T. ,ERRORSRV_DEF  , STR0011 , HELP_URL, )
		EndIf

	END SEQUENCE

	If cEmpAntBck <> cParEmp .Or. cFilAntBck <> cParFil
		fTrGrpGPE(cEmpAntBck, cFilAntBck)
	EndIf

Return lRetorno

/*/{Protheus.doc} POST
// Método responsável pela inclusão do Período de Estabiliade de um funcionário.
@author raquel.andrade
@since 12/03/20120
@version 1.0
@param authorization, chave de autorização
/*/
WSMETHOD POST HEADERPARAM authorization WSREST stabilityControl

	Local aConteudo		As Array
	Local cChave		As Character
	Local cBody			As Character
	Local cCatch		As Character
	Local lRetorno		As Logical
	Local jEstab		As Object
	Local cEmpAntBck := cEmpAnt
	Local cFilAntBck := cFilAnt
	Local cParEmp    := cEmpAnt
	Local cParFil    := cFilAnt
	Local jQryParams := oRest:getQueryRequest()	as Json
	Local nCodRet    := 0

	jEstab		:= JsonObject():New()
	cBody		:= Self:GetContent()
	lRetorno	:= .T.
	aConteudo	:= {,,,,,}
	cChave		:= ""

	BEGIN SEQUENCE

		If jQryParams:hasProperty("forcaErro")
			BREAK
		Endif

		cCatch   := jEstab:FromJSON(EncodeUTF8(NoAcento(cBody)))

		If cCatch != Nil  .Or. Len(jEstab:GetNames()) == 0
			// "Não foi possível efetuar a leitura do pacote enviado, favor verificar e reenviar." ### Erro na validação do recebimento da mensagem
			SetRestFault(ERRORCODE_DEF, EncodeUTF8(STR0009), .T. ,ERRORCODE_DEF , EncodeUTF8(STR0006) , HELP_URL, )
			lRetorno := .F.
		ElseIf !fTratDados(@jEstab, @aConteudo, @cChave,,3)
			lRetorno := .F.
		EndIf

		If lRetorno .And. Len(aConteudo) > 0 .And. !Empty(cChave)

			cParEmp	:= aConteudo[1]
			cParFil	:= aConteudo[2]
			If cEmpAntBck <> cParEmp .Or. cFilAntBck <> cParFil
				fTrGrpGPE(cParEmp, cParFil, "RFX", "GPE")
			EndIf

			lRetorno	:= NewStabPer(cBody,jEstab,aConteudo,cChave)

			If lRetorno
				cResponse := fCompress(@jEstab)
				::SetResponse(cResponse)
			EndIf

		EndIf

	RECOVER
		If nCodRet == 0
			lRetorno := .F.
			//"Ocorreu uma falha no retorno desta operação."
			SetRestFault(ERRORSRV_DEF ,  EncodeUTF8(STR0008) ,.T. ,ERRORSRV_DEF  , STR0011 , HELP_URL, )
		EndIf

	END SEQUENCE

	If cEmpAntBck <> cParEmp .Or. cFilAntBck <> cParFil
		fTrGrpGPE(cEmpAntBck, cFilAntBck)
	EndIf

Return lRetorno

/*/{Protheus.doc} NewStabPer
// Método que irá gravar o Período de Estabilidade do Funcionário
@author raquel.andrade
@since 12/02/2020
@return lRet, Logical, definição se houve sucesso ou falha na geração do currículo
@param cBody, characters, corpo do pacote enviado na requisição do método
@param ojEstab, object, Json que será preenchido com o retorno
/*/
Static Function NewStabPer(cBody,jEstab,aConteudo,cChave)

	Local cSeek			As Character
	Local cRetSqlName	As Character
	Local lRetorno		As Logical
	Local lDtFim		As Logical
	Local dDataF		As Date
	Default cBody  		:= ""
	Default jEstab 		:= JsonObject():New()
	Default aConteudo	:= {,,,,,} // Grupo de Empresa, Filial, Matricula, Data de Início, Data de Término, Tipo de Estabilidade
	Default cChave		:= ""

	lRetorno 	:= .F.
	lDtFim		:= .F.
	dDataF		:= StoD("")

	Begin Transaction

		cRetSqlName := RetSqlName( "RFX" )+"\3"
		dbSelectArea("RFX")
		dbSetOrder(1) // RFX_FILIAL + RFX_MAT + DOTS(RFX_DATAI) + RFX_TPESTB
		cSeek := xFilial("RFX", aConteudo[2])+aConteudo[3]+DtoS(aConteudo[4])+aConteudo[6]

		DbSelectArea("RFX")
		RFX->(dbSetOrder( 1 ))
		If !RFX->(dbSeek(cSeek))

			Reclock("RFX",.T.,.T.)
			RFX->RFX_FILIAL		:=	xFilial("RFX", aConteudo[2])
			RFX->RFX_MAT		:= 	aConteudo[3]
			RFX->RFX_DATAI		:=  aConteudo[4]
			RFX->RFX_TPESTB		:= 	aConteudo[6]

			If !Empty(aConteudo[5])
				RFX->RFX_DATAF		:=  aConteudo[5]
				lDtFim := .T.
			EndIf
			MsUnlock()

			If lDtFim
				While RFX->( !EoF() .And. RFX_FILIAL + RFX_MAT == xFilial("RFX",aConteudo[2]) + aConteudo[3] )
					If RFX->RFX_DATAF > dDataF
						dDataF := RFX->RFX_DATAF
					EndIf
					RFX->(dbSkip())
				EndDo
				fRAtuVtEst( aConteudo[2], aConteudo[3], dDataF )
			EndIf

			jEstab["id"] 	:= cChave

			lRetorno := .T.
		else
			//"Ocorreu uma falha no retorno desta operação." ### ""Esta solicitação de controle de estabilidade já existe na base do Protheus. Verifique!"
			SetRestFault(ERRORCODE_DEF, EncodeUTF8(STR0017), .T. ,ERRORCODE_DEF , EncodeUTF8(STR0011) , HELP_URL, )

		EndIf

	End Transaction

Return lRetorno


/*/{Protheus.doc} fTratDados
// Valida dados do jSon (verbo Post/Put)
@author raquel.andrade
@since 12/03/2020
@param jEstab,object, variável de objeto que contém os dados de json
@param aConteudo , array, variável array que contém campos graváveis do Post
@param cChave , character, variável que representa o id do Post
@param aChvPr , array, variável array que contém  parametro stabilityId do Put
@param nOpc	, numeric, variável que contém opção de acesso (3-Post, 4-Put)
@return lRet, logical, variável que verifica se ocorreu erro ou não
/*/
Static Function fTratDados(jEstab,aConteudo,cChave, aChvPr,nOpc)
	Local aNames	As Array
	Local aCpoObt	As Array
	Local aFunc		As Array
	Local aEstab	As Array
	Local cMsgRest	:= ""
	Local ctmpCia 	:= ""
	Local ctmpFil 	:= ""
	Local ctmpEmp	:= ""
	Local ctmpDtI 	:= ""
	Local ctmpDtF 	:= ""
	Local ctmpSCd 	:= ""
	Local ctmpEstb	:= ""
	Local nItem		:= 0
	Local lRet		As Logical
	Local cEmpAntBck	:= cEmpAnt
	Local cFilAntBck	:= cFilAnt
	Local nTamFil		:= 0

	Default jEstab 		:= JsonObject():New()
	Default aConteudo	:= {,,,,,}
	Default cChave		:= ""
	Default aChvPr		:= {}
	Default nOpc		:= 0

	cCpoObt		:= "companyId/branchId/employeeId/startDate/stabilityCode" // Campos obrigatorios (chave única)
	lRet		:= .T.
	aNames		:= jEstab:GetNames()
	aCpoObt		:= StrToArray(cCpoObt,"/")
	aFunc		:= {}
	aEstab		:= {}
	cMsgRest	:= ""


	// Verifica tags obrigatórias
	//  "Verifique o conteúdo da TAG ("
	// " ) pois ela é obrigatória para a manipulação deste processo."
	If nOpc == 3 // Apenas para Post
		For nItem:= 1 to Len(aCpoObt)
			If aScan(aNames,{|x| UPPER(x) == UPPER(aCpoObt[nItem])})== 0
				cMsgRest+=  OemToAnsi(STR0012)+ aCpoObt[nItem] +OemToAnsi(STR0013)
				lRet	:= .F.
			EndIf
		Next nItem

	EndIf

	If lRet
		For nItem:= 1 to Len(aNames)
			If UPPER(aNames[nItem]) $ "COMPANYID"
				ctmpCia := jEstab[aNames[nItem]]
			ElseIf UPPER(aNames[nItem]) =="BRANCHID"
				ctmpFil := jEstab[aNames[nItem]]
			ElseIf UPPER(aNames[nItem]) $ "EMPLOYEEID"
				If !Empty(jEstab[aNames[nItem]])
					ctmpEmp	:= jEstab[aNames[nItem]]
					aFunc 	:= StrTokArr2(jEstab[aNames[nItem]],"|",.T.)
				EndIf
			ElseIf UPPER(aNames[nItem]) $ "STARTDATE"
				ctmpDtI := jEstab[aNames[nItem]]
			ElseIf UPPER(aNames[nItem]) $ "ENDDATE"
				ctmpDtF := jEstab[aNames[nItem]]
			ElseIf UPPER(aNames[nItem]) $ "STABILITYCODE"
				If !Empty(jEstab[aNames[nItem]])
					ctmpEstb	:= jEstab[aNames[nItem]]
					aEstab 		:= StrTokArr2(jEstab[aNames[nItem]],"|",.T.)
				EndIf
			EndIf
		Next nItem
	EndIf


	If nOpc == 4 // Apenas para Put
		// Verifica se dados de Body são os mesmo de parametro stabilityId
		// ref a Grupo de Empresa + Filial + Dados Funcionário (dados fixos)
		If lRet .And. !Empty(aChvPr) .And. !(Len(aFunc) < 3)
			If  !(aChvPr[1] + aChvPr[2] + aChvPr[3] + aChvPr[4] + aChvPr[5] == ctmpCia + ctmpFil + aFunc[1] + aFunc[2] + aFunc[3] )
				// "Informação stabilityId difere do conteúdo do pacote.
				cMsgRest		+= OemToAnsi(STR0016)
				lRet	:= .F.
			EndIf
		EndIf
	EndIf

	//Verifica Empresa/Filial
	If lRet .And. !Empty(ctmpCia) .And. !Empty(ctmpFil)
		If !FWFilExist(ctmpCia,ctmpFil)
			// "De-Para de Empresa/Filial não encontrado na base."
			cMsgRest		+= OemToAnsi(STR0007)
			lRet	:= .F.
		EndIf
	EndIf

	If cEmpAntBck <> ctmpCia .Or. cFilAntBck <> ctmpFil
		fTrGrpGPE(ctmpCia, ctmpFil, "SRA, RCC", "GPE")
	EndIf
	nTamFil := FwSizeFilial(ctmpCia, ctmpFil)
	// Verifica Matrícula
 	If lRet .And. !Empty(ctmpCia) .And. !Empty(ctmpFil)
	 	If Len(aFunc) == 3
			DBSelectArea("SRA")
			DBSetOrder(1)
			If !DBseek (aFunc[2]+aFunc[3])
				//"Verifique o conteúdo da TAG () pois não foi possível encontrar esta informação no Protheus."
				cMsgRest+= OemToAnsi(STR0012) +"employeeId" + OemToAnsi(STR0015)
				lRet	:= .F.
			EndIf
		ElseIf lRet .And. Len(aFunc) < 3 .And. Len(aFunc) != 0
			//"Verifique o conteúdo da TAG () pois não foi possível encontrar esta informação no Protheus."
			cMsgRest+= OemToAnsi(STR0012) +"employeeId" + OemToAnsi(STR0015)
			lRet	:= .F.
		EndIf
	EndIf

	// Verifica formato da Data de Início
	// "Verifique o conteúdo da TAG ("
	// ") pois a data não está no formato correto: 'YYYY-MM-DDTHH:MM:SS'"
	If lRet .And. !Empty(ctmpDtI)
		If  SubStr(ctmpDtI, 5,  1) != "-" .Or. SubStr(ctmpDtI, 8,  1) != "-" .Or. ;
			SubStr(ctmpDtI, 11, 1) != "T" .Or. SubStr(ctmpDtI, 14, 1) != ":" .Or. ;
			SubStr(ctmpDtI, 17, 1) != ":" .Or. Empty(fClearDate(ctmpDtI))
			cMsgRest	+=  OemToAnsi(STR0012)+ "startDate" + OemToAnsi(STR0014)
			lRet	:= .F.
		EndIf
	EndIf

	// Verifica formato da Data de Término
	// "Verifique o conteúdo da TAG ("
	// ") pois a data não está no formato correto: 'YYYY-MM-DDTHH:MM:SS'"
	If lRet .And. !Empty(ctmpDtF)
		If  SubStr(ctmpDtF, 5,  1) != "-" .Or. SubStr(ctmpDtF, 8,  1) != "-" .Or. ;
			SubStr(ctmpDtF, 11, 1) != "T" .Or. SubStr(ctmpDtF, 14, 1) != ":" .Or. ;
			SubStr(ctmpDtF, 17, 1) != ":" .Or. Empty(fClearDate(ctmpDtF))
			cMsgRest	+=  OemToAnsi(STR0012)+ "endDate" + OemToAnsi(STR0014)
			lRet	:= .F.
		EndIf
	EndIf

	// Verifica Código de Estabilidade
	//"Verifique o conteúdo da TAG () pois não foi possível encontrar esta informação no Protheus."
	If lRet .And. !Empty(ctmpCia) .And. !Empty(ctmpFil)
		If ( Len(aEstab) == 3)
			ctmpSCd	:= aEstab[3]
			dbSelectArea( "RCC" )
			dbSetOrder(1) // RCC_FILIAL + RCC_CODIGO
			If !dbSeek(PADR(aEstab[2], nTamFil) + "S053") .Or. !ValidRCC('S053',ctmpSCd ,1,3)
				cMsgRest+= OemToAnsi(STR0012) +"stabilityCode" + OemToAnsi(STR0015)
				lRet	:= .F.
			EndIf
		ElseIf lRet .And. Len(aEstab) < 3 .And. Len(aEstab) != 0
			cMsgRest+= OemToAnsi(STR0012) +"stabilityCode" + OemToAnsi(STR0015)
			lRet	:= .F.
		EndIf
	EndIf

	If !lRet .And. !Empty(cMsgRest)
		// "Erro na validação do recebimento da mensagem"
		SetRestFault(ERRORCODE_DEF,  EncodeUTF8(STR0006), .T. ,ERRORCODE_DEF , EncodeUTF8(cMsgRest) , HELP_URL, )
	ElseIf nOpc == 3
		aConteudo	:= {	If(!Empty(aFunc[1]),aFunc[1] , ""),;					// [1] Grupo de Empresa
							If(!Empty(aFunc[2]),aFunc[2] , ""),;					// [2] Filial
							If(!Empty(aFunc[3]),aFunc[3] , ""),;					// [3] Matrícula
							If(!Empty(ctmpDtI),fClearDate(ctmpDtI) , CtoD("//")),;  // [4] Data de Início
 							If(!Empty(ctmpDtF),fClearDate(ctmpDtF) , CtoD("//")),;	// [5] Data de Término
							If(!Empty(ctmpSCd),ctmpSCd , "")	}					// [6] Tipo de Estabilidade
		cChave		:=  ctmpCia + ';' + ctmpFil + ';' + ctmpEmp + ';' + ctmpDtI + ';' + ctmpEstb
	EndIf

	If cEmpAntBck <> ctmpCia .Or. cFilAntBck <> ctmpFil
		fTrGrpGPE(cEmpAntBck, cFilAntBck)
	EndIf

Return lRet

/*/{Protheus.doc} fIdValid
Valida dados da Chave (verbos Delete/Put)
@author raquel.andrade
@since 12/03/2020
@return lRetorno, return_description
@param  cChave, characters, descricao
@param  aChv, array, descricao
/*/
Static Function fIdValid(cChave, aChv)
	Local aFunc    := {}
	Local aEstab	:= {}
	Local aReto 	:= {}
	Local aErro 	:= {}
	Local aTemp := {}

	Local ctmpDtI   As Character
	Local lRetorno := .T.
	Local cEmpAntBck	:= cEmpAnt
	Local cFilAntBck	:= cFilAnt
	Local nTamFil		:= 0

	Default cChave	:= ""
	Default aChv	:= {}

	aTemp := StrTokArr2(cChave,";",.T.)

	// Verifica preenchimento de todas as tags
	If ( Len(aTemp) < 5)
		lRetorno	:= .F.
		Return (aErro)
	EndIf

	aFunc := StrTokArr2(aTemp[3],"|",.T.)

	If ( Len(aFunc) <> 3)
		lRetorno	:= .F.
		Return (aErro)
	EndIf

	aEstab := StrTokArr2(aTemp[5],"|",.T.)

	If ( Len(aEstab) <> 3)
		lRetorno	:= .F.
		Return (aErro)
	EndIf

	//Verifica Empresa/Filial
	If lRetorno .And. !FWFilExist(aTemp[1],aTemp[2])
		lRetorno	:= .F.
		Return (aErro)
	EndIf

	If cEmpAntBck <> aTemp[1] .Or. cFilAntBck <> aTemp[2]
		fTrGrpGPE(aTemp[1], aTemp[2], "SRA, RFX", "GPE")
	EndIf
	nTamFil := FwSizeFilial(aTemp[1],aTemp[2])
	//Verifica Funcionario
	If lRetorno
		DBSelectArea("SRA")
		DBSetOrder(1)
		If ! DBseek (aFunc[2]+aFunc[3])
			lRetorno	:= .F.
			Return (aErro)
		Else
		// Verifica Código de Estabilidade
			dbSelectArea( "RCC" )
			dbSetOrder(1) // RCC_FILIAL + RCC_CODIGO
			If  !dbSeek(PADR(aEstab[2], nTamFil) + "S053") .Or. !ValidRCC('S053',aEstab[3] ,1,3)
				lRetorno	:= .F.
				Return (aErro)
			EndIf
		EndIf
	EndIf

	// Verifica Data de Início
	// Formato Considerado como válido: "2001-01-01T18:25:43"
	If lRetorno .And. Len(aTemp[4]) > 0
		ctmpDtI :=  aTemp[4]
		If  SubStr(ctmpDtI, 5,  1) != "-" .Or. SubStr(ctmpDtI, 8,  1) != "-" .Or. ;
			SubStr(ctmpDtI, 11, 1) != "T" .Or. SubStr(ctmpDtI, 14, 1) != ":" .Or. ;
			SubStr(ctmpDtI, 17, 1) != ":" .Or. Empty(fClearDate(ctmpDtI))
				lRetorno	:= .F.
				Return (aErro)
		EndIf
	EndIf

	If !lRetorno
		// "Erro na validação do recebimento da mensagem" ### "Informação stabilityId ausente ou inválida."
		SetRestFault(ERRORCODE_DEF,  EncodeUTF8(STR0006), .T. ,ERRORCODE_DEF , EncodeUTF8(STR0005) , HELP_URL, )
	Else
		aReto	:= {	aTemp[1] ,;				// [1] Grupo de Empresa
						aTemp[2] ,;				// [2] Filial
						aFunc[3] ,;				// [3] Matrícula
						fClearDate(ctmpDtI),;	// [4] Data de Início
						aEstab[3] 	}			// [5] Tipo de Estabilidade

		dbSelectArea( "RFX" )
		dbSetOrder(1)
		If  !dbSeek(aReto[2] + aReto[3] + DtoS(aReto[4]) + aReto[5])
			lRetorno	:= .F.
		EndIf
	EndIf

	aChv	:= If(lRetorno,aClone(aReto),aClone(aErro))

	If cEmpAntBck <> aTemp[1] .Or. cFilAntBck <> aTemp[2]
		fTrGrpGPE(cEmpAntBck, cFilAntBck)
	EndIf

Return (aChv)


/*/{Protheus.doc} fDelData
@author raquel.andrade
@since 12/03/2020
@return lRet, return_description
@param jEstab, object, descricao
@param  aDelChv, array, com conteúdo da mensagem
/*/
Static Function fDelData(jEstab, aDelChv)
	Local lRet		:= .F.

	Default jEstab 		:= JsonObject():New()
	Default aDelChv		:= {,,,,} // Grupo de Empresa + Filial + Matricula + Data de Início + Tipo de Estabilidade

	// Se não houver erros executa a exclusão no banco
	Begin Transaction

		DBSelectArea("RFX")
		dbSetOrder(1) // RFX_FILIAL + RFX_MAT + DOTS(RFX_DATAI) + RFX_TPESTB

		// Deleta conteúdo
		If RFX->(DbSeek(xFilial("RFX",aDelChv[2])+aDelChv[3]+DtoS(aDelChv[4])+aDelChv[5]))
			If( !Empty(RFX->RFX_DATAF), fRAtuVtEst(aDelChv[2], aDelChv[3], RFX->RFX_DATAF, .T.), Nil )

			RecLock("RFX", .F.)
				RFX->( dbDelete() )
				RFX->( MsUnLock() )

			lRet := .T.

			jEstab["code"]		:= "200"
			jEstab["message"]	:= STR0010 // "Operação realizada com sucesso!"
		else
			SetRestFault(ERRORCODE_DEF, EncodeUTF8(STR0005), .T. ,ERRORCODE_DEF , EncodeUTF8(STR0006) , HELP_URL, )
		EndIF

	End Transaction

Return lRet

/*/{Protheus.doc} fPutData
// Inclui dados na tabela.
@author raquel.andrade
@since 12/03/2020
@return lRet, return_description
@param  jEstab, object, descricao
@param  aConteudo, array, com conteúdo da mensagem
@param  cBody, characters, descricao
/*/
Static Function fPutData(jEstab, aPutChv, cBody, cChave)

	Local aNewChv		As Array
	Local aEstab		As Character
	Local cDataI		As Character
	Local dDataF		As Date
	Local cObjDtI		As Character
	Local cObjDtF		As Character
	Local lRet			As Logical
	Local lDtTroca		As Logical
	Local lDtFim		As Logical

	Default jEstab 		:= JsonObject():New()
	Default aPutChv		:= {,,,,} // Grupo de Empresa + Filial + Matricula + Data de Início + Tipo de Estabilidade
	Default	cBody 		:= ""
	Default cChave		:= ""

	lRet 		:= .T.
	lDtTroca 	:= .F.
	aEstab		:= {}
	lDtFim		:= .F.

	// Pega o conteudo do Body
	If !Empty(cBody)

		// Se não houver erros executa a alteração no banco
		Begin Transaction
			RFX->(DBSelectArea("RFX"))
			RFX->(DBSetOrder(1)) // Filial + Matrícula + Data de Início + Tipo de Estabilidade

			// Recebe novos valores dos campos
			If RFX->(DbSeek(xFilial("RFX",aPutChv[2])+aPutChv[3]+DtoS(aPutChv[4])+aPutChv[5]))

				RecLock("RFX", .F.)

					If jEstab:hasProperty("startDate") .And. jEstab["startDate"] != ""
						cObjDtI	:= jEstab["startDate"]
						cDataI	:= fClearDate(cObjDtI)
						If !Empty(cDataI)
							RFX->RFX_DATAI  := cDataI
							lDtTroca		:= .T.
						Else
							lRet	:= .F.
						EndIf
					EndIf

					If jEstab:hasProperty("endDate") .And. jEstab["endDate"] != ""
						cObjDtF	:= jEstab["endDate"]
						dDataF	:= fClearDate(cObjDtF)
						If !Empty(dDataF)
							RFX->RFX_DATAF := dDataF
							lDtFim := .T.
						Else
							lRet	:= .F.
						EndIf
					EndIf

					If jEstab:hasProperty("stabilityCode") .And. jEstab["stabilityCode"] != ""
						aEstab = StrTokArr2(jEstab["stabilityCode"],"|",.T.)
						If Len(aEstab) == 3
							RFX->RFX_TPESTB := aEstab[3]
						Else
							lRet	:= .F.
						EndIf
					EndIf

				RFX->( MsUnLock() )

				If lRet
					If lDtFim
						While RFX->( !EoF() .And. RFX_FILIAL + RFX_MAT == xFilial("RFX",aPutChv[2]) + aPutChv[3] )
							If RFX->RFX_DATAF > dDataF
								dDataF := RFX->RFX_DATAF
							EndIf
							RFX->(dbSkip())
						EndDo
						fRAtuVtEst( aPutChv[2], aPutChv[3], dDataF )
					EndIf

					aNewChv	:= StrTokArr2(cChave,"|",.T.)
					cChave	:= 	 	aNewChv[1] + ';' +; // Grupo de Empresa
									aNewChv[2] + ';' +; // Filial
									aNewChv[3] + '|' +; // Grupo de Empresa Funcionário
									aNewChv[4] + '|' +; // Filial Funcionário
									aNewChv[5] + ';' +; // Matrícula Funcionário
									If(lDtTroca,cObjDtI,aNewChv[6]) + ';' +; // Data de Início
									aNewChv[7] + '|' +; // Grupo de Empresa Cod. Estabilidade
									aNewChv[8] + '|' +; // Filial Cod. Estabilidade
									If(Len(aEstab) == 0, aNewChv[9], aEstab[3])			// Cod. Estabilidade



					jEstab["id"] 		:= cChave
				EndIf

			EndIF
		End Transaction
	EndIf

Return lRet

/*/{Protheus.doc} fResetErrorHandler
//TODO fSetErro Seta código e mensagem de erro
@author oliveira.hugo
@return return, boolean, valor fixo .T.
@param cTitle, characters, título do erro
/*/
Static Function fResetErrorHandler(cTitle)
	bError  := { |e| oError := e , Break(e) }
	bErrorBlock    := ErrorBlock( bError )
Return(.T.)


/*/{Protheus.doc} fCompress
//TODO Descrição auto-gerada.
@author oliveira.hugo
@since 07/08/2019
@return return, return_description
@param oObj, object, descricao
/*/
Static Function fCompress(oObj)
	Local cJson    := ""
	Local cComp    := ""
	Local lCompact := .F.

	// Set gzip format to Json Object
	cJson := oObj:toJSON()

	cJson := EncodeUTF8(cJson)

	If Type("::GetHeader('Accept-Encoding')") != "U"  .and. 'GZIP' $ Upper(::GetHeader('Accept-Encoding') )
		lCompact := .T.
	EndIf

	If(lCompact)
		::SetHeader('Content-Encoding','gzip')
		GzStrComp(cJson, @cComp, @nLenComp )
	Else
		cComp := cJson
	Endif

Return cComp


/*/{Protheus.doc} function ClearDate
Clean especial character from Date Input. Input Format: 2012-04-23T18:25:43
@author  Wesley Alves Pereira
@since   02/05/2019
@version 12.1.23
/*/
Static Function fClearDate(cDate)
Local dData := STOD("")

	cDate := StrTran(cDate, "T", "")
	cDate := StrTran(cDate, ":", "")
	cDate := StrTran(cDate, "-", "")
	cDate := SubStr(cDate,1,8)
	dData := StoD(cDate)

Return ( dData )

/*/{Protheus.doc} fRAtuVtEst
Atualiza Campo de Vcto Estabilidade do cad funcionário conforme RFX
@author isabel.noguti
@since 18/09/2024
@version 12.1.2410
@param cFilFun, string, Filial
@param cMatFun, string, Matricula
@param dVenc,	data,	RFX_DATAF
@param lDeleta, logico, indica exclusao
@return lRet,	logico, indica campo SRA Atualizado
/*/
Static Function fRAtuVtEst(cFilFun, cMatFun, dVenc, lDeleta)
	Local aArea		:= GetArea()
	Local lRet		:= .F.

	Default cFilFun	:= cFilAnt
	Default cMatFun	:= ""
	Default dVenc	:= Stod("")
	Default lDeleta := .F.

	If SRA->(dbSeek(cFilFun + cMatFun))
		RecLock("SRA", .F.)
			If lDeleta
				If dVenc == SRA->RA_DTVTEST
					SRA->RA_DTVTEST := Stod("")
					lRet := .T.
				EndIf
			ElseIf !Empty(dVenc)
				SRA->RA_DTVTEST := dVenc
				lRet := .T.
			EndIf
		SRA->(MsUnlock())
	EndIf

	RestArea(aArea)
Return lRet
