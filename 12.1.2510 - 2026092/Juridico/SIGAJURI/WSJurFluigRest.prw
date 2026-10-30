#INCLUDE "Protheus.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "WSJURFLUIGREST.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURFLUIGREST
Métodos WS REST do Jurídico de serviços de FLUIG para TJD.

@since 19/01/2023
/*/
//-------------------------------------------------------------------
WSRESTFUL JURFLUIGREST DESCRIPTION STR0001 //"Webservice de Integração TJD x Fluig"
	DATA WorkflowOp AS STRING

	WSMETHOD GET pendTasksFluig DESCRIPTION STR0002 PATH "pendTasksFluig"  PRODUCES APPLICATION_JSON // "Busca tarefas pendentes de aprovação no FLUIG"

	WSMETHOD PUT FupWFUpd DESCRIPTION STR0003 PATH "aprovaFu/{WorkflowOp}" PRODUCES APPLICATION_JSON // "Atualiza solicitação de aprovação de Follow-up"
END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} GET pendTasksFluig
Busca tarefas pendentes de aprovação no FLUIG

@example GET -> http://127.0.0.1:9090/rest/JURFLUIGREST/pendTasksFluig

@since 19/01/2023
/*/
//-------------------------------------------------------------------
WSMETHOD GET pendTasksFluig WSREST JURFLUIGREST
Local oResponse  := JSonObject():New()
Local aResponse  := {}
Local aValores   := {}
Local cSolicitId := ""
Local cMensagem  := ""
Local cUsuInt    := AllTrim(SuperGetMV('MV_ECMUSER',,""))
Local cSenhaInt  := AllTrim(SuperGetMV('MV_ECMPSW' ,,""))
Local cEmpresa   := AllTrim(SuperGetMV('MV_ECMEMP' ,,""))

	oResponse['tarefas'] := {}

	Begin Sequence
		// Obtem o ColleagueId do usuário logado
		cSolicitId := JColId(cUsuInt, cSenhaInt, cEmpresa, UsrRetMail(__cUserID))

		aAdd(aValores, {"username"          , cUsuInt                        })
		aAdd(aValores, {"password"          , JurEncUTF8(cSenhaInt)          })
		aAdd(aValores, {"companyId"         , cEmpresa                       })
		aAdd(aValores, {"colleagueId"       , cSolicitId                     })

		If Empty( cSolicitId )
			cMensagem := STR0004  // "Problema para obter id do solicitante!"
			Break
		Else

			// Obtem tarefas pendentes de aprovação a partir do serviço SOAP
			aResponse := JPendTasks(cSolicitId, aValores)

			If aResponse[1] .AND. Len(aResponse[2]) > 0
				oResponse['tarefas'] := JFlgDados(aResponse[2], cSolicitId)
			EndIf
		EndIf
	End Sequence

	If !Empty(cMensagem)
		SetRestFault(404, cMensagem)
		ConOut(cMensagem)
		lRet := .F.
	Else
		Self:SetResponse(oResponse:toJson())
		oResponse:fromJson("{}")
		oResponse := NIL
		lRet := .T.
	EndIf	

	aSize(aResponse, 0)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JPendTasks(cSolicitId, aParams)
Obtem tarefas pendentes de aprovação no FLUIG, de acordo com o ID 
do usuário no FLUIG

@param  cSolicitId - ID do usuário no FLUIG
@param  aParams    - Array com parametros a serem utilizados pelo serviço
					Exemplo:
							aParams[1] - "username"
							aParams[2] - "password"
							aParams[3] - "companyId"
							aParams[4] - "colleagueId"
@return  lRet - Indica se foi possível obter a lista de tarefas pendentes

@since 19/01/2023
/*/
//-------------------------------------------------------------------
Function JPendTasks(cSolicitId, aParams)

Local oWsdl      := Nil
Local xRet       := Nil
Local nI         := 0
Local lRet       := .F.
Local lSetValue  := .F.
Local cMsg       := ""
Local cErro      := ""
Local cWSMetodo  := "findWorkflowTasks"
Local cUrl       := StrTran(AllTrim(JFlgUrl())+"/ECMDashBoardService?wsdl","//E","/E")
Local aSimple    := {}
Local aTarefas   := {}

Default aParams := {}

	// Cria e conecta no Wsdl
	oWsdl := JurConWsdl(cUrl, @cErro)

	If Empty( cErro )

		// Define a operação
		If ( lRet := oWsdl:SetOperation( cWSMetodo ) )
			oWsdl:cLocation := cUrl

			/*
				Parâmetros necessários para o serviço:
				<ws:findWorkflowTasks>
					<username>ricardo.rampazzo@totvs.com.br</username>
					<password>Totvs@123</password>
					<companyId>1</companyId>
					<colleagueId>ricardo.rampazzo</colleagueId>
				</ws:findWorkflowTasks>
			*/
			aSimple := oWsdl:SimpleInput()

			// Define os parâmetros necessários para o serviço
			For nI := 1 To Len(aParams)
				lSetValue := JSetFields(aParams[nI][1], aParams[nI][2], aSimple, oWsdl)
				
				If !lSetValue
					lRet := .F.
					Exit
				EndIf
			Next nI

			// faz o envio das infos
			If lRet

				// Pega a mensagem SOAP que será enviada ao servidor
				xRet := oWsdl:GetSoapMsg()

				//Retirado o elemento da tag devido o obj nao suportar
				cMsg := StrTran(xRet, ' xmlns="http://ws.dm.ecm.technology.totvs.com/"', '')
				cMsg := StrTran(cMsg, ' xmlns="http://ws.foundation.ecm.technology.totvs.com/"', '')

				JConLogXML(cMsg, "E")  // Log do XML de Envio
				xRet := oWsdl:SendSoapMsg(cMsg)  // Envia a mensagem SOAP ao servidor
				xRet := oWsdl:GetSoapResponse()  // Pega a mensagem de resposta
				JConLogXML(xRet, "R")  // Log do XML de Recebimento

				// Tratamento para a resposta do serviço
				aTarefas := aClone( JFlSoapRes(xRet) )
			EndIf
		
		Else
			If !Empty(oWsdl:cError)
				cErro := oWsdl:cError
			Else
				cErro := STR0005 // "Problema para configurar o método webservice!"
			EndIf
			JurConout(cErro)
			Break
		EndIf
	EndIf

Return {lRet, aTarefas}

//-------------------------------------------------------------------
/*/{Protheus.doc} JSetFields(cTag, cValor, aSimple, oWsdl)
Define o valor de cada parâmeto necessário para o serviço SOAP findWorkflowTasks

@param  cTag    - Indica o parâmetro a ser setado
@param  cValor  - Indica o valor a ser setado
@param  aSimple - Array com estrutura de parâmetros disponíveis
@param  oWsdl   - Objeto com estrutura do a ser utilizada no serviço de busca
@return lRet    - Indica se o valor foi setado no parâmetro

@since 20/01/2023
/*/
//-------------------------------------------------------------------
Static Function JSetFields(cTag, cValor, aSimple, oWsdl)

Local nPos := 1
Local lRet := .F.

	nPos := aScan( aSimple, {|x| x[2] == cTag } )
	lRet := oWsdl:SetValue( aSimple[nPos][1], cValor )

	If lRet == .F.
		JurConout("Error: " + oWsdl:cError) // "Error: "
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}  JFlSoapRes(xRet)
Retorna a lista de tarefas obtidas pelo serviço

@param  xRet        - XML de retorno do serviço
@param  cRefElement - Elemento de referência para gerar a Lista
@param  cRefTag     - Tag para encontrar os dados no XML

@return aTarefas - Lista de tarefas pendentes de aprovação

@since 20/01/2023
/*/
//-------------------------------------------------------------------
Function JFlSoapRes(xRet, cRefElement, cRefTag)

Local cErro     := ""
Local cAviso    := ""
Local cMensagem := ""
Local nPosTag   := 0
Local oXml      := nil
Local aTarefas  := {}

Default cRefElement := "_WORKFLOWTASKS"
Default cRefTag     := "</WorkflowTasks>"

	nPosTag := At(StrTran(cRefTag, "/", ""), xRet)  // Obtem a Tag <WorkflowTasks> do XML de retorno
	xRet    := SubStr(xRet, nPosTag, Len(xRet))  // Remove a Tag <WorkflowTasks> do inicio da resposta
	nPosTag := At(cRefTag, xRet) + Len(cRefTag) - 1
	xRet    := Left(xRet, nPosTag)
	cRefElement := "oXml:" + cRefElement

	oXml := XmlParser( xRet, "_", @cErro, @cAviso ) //Gera o objeto do Result Tag

	If !Empty(cErro)
		cMensagem := JMsgErrFlg(oXML)
		JurConOut(cMensagem)
		Break
	EndIf

	//Analisa o tipo de retorno do Fluig
	If ValType(oXml) == "O" .And. XmlChildEx(&(cRefElement), "_ITEM") <> Nil

		If VALTYPE(XmlChildEx(&(cRefElement), "_ITEM")) == "A"
			aTarefas := aClone(XmlChildEx(&(cRefElement), "_ITEM"))
		EndIf
	EndIf

Return aTarefas

//-------------------------------------------------------------------
/*/{Protheus.doc} JFlgDados(aListTasks, cSolicitId)
Obtem das tarefas pendentes a partir do XML de response do serviço

@param  aListTasks - Lista de Objetos com dados das tarefas obtidos do FLUIG
@param  cSolicitId - ID do usuário
@return aResult    - Lista de tarefas

@since 20/01/2023
/*/
//-------------------------------------------------------------------
Static Function JFlgDados(aListTasks, cSolicitId)

Local nI         := 0
Local cCodWF     := ""
Local cDataFinal := ""
Local oDadosFUP  := Nil
Local lAprovacao := .F.
Local lProcessID := .F.
Local aResult    := {}
Local NTotalApr := 0

Default aListTasks := {}
Default cSolicitId := ""

	For nI := 1 To Len(aListTasks)
		
		lAprovacao := aListTasks[nI]:_STATEID:TEXT == "6"  // Em aprovação
		lProcessID := aListTasks[nI]:_PROCESSID:TEXT == "SIGAJURI_AprovaFU"
		If (lProcessID)
			NTotalApr++
		EndIf
		If lAprovacao .AND. lProcessID

			cCodWF := aListTasks[nI]:_PROCESSINSTANCEID:TEXT
			oDadosFUP := JFlgQryNTA(cCodWF)

			If VALTYPE(oDadosFUP) <> "U"
				oDadosFUP['dataInclusao'] := SUBSTR(aListTasks[nI]:_MOVEMENTHOUR:TEXT, 1, 10)
				cDataFinal := STRTRAN(SUBSTR(aListTasks[nI]:_DEADLINEDATE:TEXT, 1, 10), "-", "")
				oDadosFUP['dataFinal']    := DTOC(STOD(cDataFinal))
				oDadosFUP['solicitante']  := JConvUTF8(aListTasks[nI]:_REQUESTERNAME:TEXT)
				oDadosFUP['urlFluig']     := JFlgUrlWF(cCodWF)

				aAdd(aResult, oDadosFUP)
			EndIf
		EndIf
	Next nI

Return aResult

//-------------------------------------------------------------------
/*/{Protheus.doc} JFlgQryNTA(cCodWF)
Busca detalhes das tarefas pendentes

@param  cCodWF - Código do workflow da tarefa no FLUIG
@return oDados - Objeto com estrutura e infos da tarefa

@since 20/01/2023
/*/
//-------------------------------------------------------------------
Static Function JFlgQryNTA(cCodWF)

Local aArea   := GetArea()
Local cAlias  := GetNextAlias()
Local oDados  := Nil
Local cQuery  := ""
Local aParams := {}

	aAdd(aParams, xFilial("NVE") )
	aAdd(aParams, xFilial("NQS") )
	aAdd(aParams, cCodWF )

	cQuery += " SELECT NTA_CAJURI, "
	cQuery +=         " NTA_CODWF, "
	cQuery +=         " NQS_DESC, "
	cQuery +=         " NVE_TITULO, "
	cQuery +=         " COALESCE(" + JQryMemo("NTA_DESC", Nil, Nil, 4000) + ", '') NTA_DESC"
	cQuery += " FROM " + RetSqlName( "NTA" ) + " NTA "
	cQuery +=     " INNER JOIN " + RetSqlName( "NSZ" ) + " NSZ "
	cQuery +=         " ON NSZ.NSZ_FILIAL = NTA.NTA_FILIAL "
	cQuery +=             " AND NSZ.NSZ_COD = NTA.NTA_CAJURI "
	cQuery +=             " AND NSZ.D_E_L_E_T_ =  ' ' "
	cQuery +=     " INNER JOIN " + RetSqlName( "NVE" ) + " NVE "
	cQuery +=         " ON NVE.NVE_FILIAL = ? "
	cQuery +=             " AND NVE.NVE_NUMCAS = NSZ.NSZ_NUMCAS "
	cQuery +=             " AND NVE.NVE_CCLIEN = NSZ.NSZ_CCLIEN "
	cQuery +=             " AND NVE.NVE_LCLIEN = NSZ.NSZ_LCLIEN "
	cQuery +=             " AND NVE.D_E_L_E_T_ = ' ' "
	cQuery +=     " INNER JOIN " + RetSqlName( "NQS" ) + " NQS "
	cQuery +=         " ON NQS.NQS_FILIAL = ? "
	cQuery +=             " AND NQS.NQS_COD = NTA.NTA_CTIPO "
	cQuery +=             " AND NQS.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE NTA_CODWF = ? "
	cQuery +=     " AND NTA.D_E_L_E_T_ = ' ' "

	dbUseArea( .T., 'TOPCONN', TCGenQry2(NIL, NIL, cQuery, aParams), cAlias, .T., .F. )

	If (cAlias)->(!Eof())
		oDados := JSonObject():New()
		oDados['codigoWF']   := cCodWF
		oDados['cajuri']     := (cAlias)->NTA_CAJURI
		oDados['tipo']       := JConvUTF8((cAlias)->NQS_DESC)     // Tipo do Prazo / Tarefa (NQS_DESC)
		oDados['detalhes']   := JConvUTF8((cAlias)->NTA_DESC)     // Detalhes da tarefa (NTA_DESC)
		oDados['tituloCaso'] := JConvUTF8((cAlias)->NVE_TITULO)   // Título do caso (NVE_TITULO)
	EndIf

	(cAlias)->( dbCloseArea() )
	RestArea( aArea )
Return oDados


//-------------------------------------------------------------------
/*/{Protheus.doc} PUT FupWFUpd
Atualiza a solicitação com a observação de aprovação

@body 
{
	"idWorkflow": "",
	"observacao": ""
}
@return oDados - Objeto com estrutura e infos da tarefa

@since 20/01/2023
/*/
//-------------------------------------------------------------------
WSMETHOD PUT FupWFUpd PATHPARAM WorkflowOp WSREST JURFLUIGREST
Local lRet        := .T.
Local cOperacao   := Self:WorkflowOp
Local cBody       := Self:GetContent()
Local oBody       := JSonObject():New()
Local oRequest    := JSonObject():New()
Local itensBody   := Nil
Local xmlCardData := Nil
Local cUsuario    := AllTrim(SuperGetMV('MV_ECMUSER',,""))
Local cSenha      := AllTrim(SuperGetMV('MV_ECMPSW' ,,""))
Local cEmpresa    := AllTrim(SuperGetMV('MV_ECMEMP' ,,""))
Local cIdWF       := ""
Local cSolicitId  := ""
Local cMsgFlg     := ""
Local aReqUserInfo:= {}

	Self:SetContentType("application/json")
	/**
	 * {
	 * 		"idWorkflow": "",
	 * 		"observacao": ""
	 * }
	 */
	oBody:FromJSon(cBody)
	itensBody := oBody:GetNames()
	cSolicitId := JColId(cUsuario, cSenha, cEmpresa, UsrRetMail(__cUserID))
	
	// Verifica a operação a ser feita
	If (cOperacao == "aprovacao")
		cNextStep := "11"
	ElseIf (cOperacao == "rejeicao")
		cNextStep := "4"
	Else
		oRequest['error'] := STR0006 //"A operação informada não existe!"
		lRet := .F.
	EndIf

	// Verifica o ID da solicitação
	If lRet .And. aScan(itensBody, "idWorkflow") == 0
		oRequest['error'] := STR0007 //"Não foi informado o ID do Workflow a ser aprovado!"
		lRet := .F.
	Else
		cIdWF := oBody['idWorkflow']
	EndIf

	// Verifica a observação da aprovação
	If lRet .And. aScan(itensBody, "observacao") == 0 .OR. Empty(oBody['observacao'])
		oRequest['error'] := STR0008 //"Não foi informado o texto da aprovação!"
		lRet := .F.
	EndIf

	If (lRet)
		If !Empty(cIdWF)
			// Cabeçalho padrão
			aAdd(aReqUserInfo, {"username"          , cUsuario    })
			aAdd(aReqUserInfo, {"password"          , JurEncUTF8(cSenha)})
			aAdd(aReqUserInfo, {"companyId"         , cEmpresa    })
			aAdd(aReqUserInfo, {"userId"            , cSolicitId  })
			aAdd(aReqUserInfo, {"processInstanceId" , cIdWF       })

			// Processamento da solicitação
			xmlCardData := getCardData(aReqUserInfo)
			lRet := SendToFlg(cNextStep, aClone(aReqUserInfo), DecodeUTF8(oBody['observacao']), xmlCardData, @cMsgFlg)

			If (!lRet)
				oRequest['error'] :=I18n(STR0009, {cIdWF, AllTrim(cMsgFlg)}) //"Erro ao processar a solicitação [#1]. Mensagem: #2"
			EndIf
		EndIf
	Else 
		SetRestFault(400, oRequest['error'])
	EndIf

	If lRet
		oRequest['message'] := I18n(STR0010 ,{cIdWF}) //"A solicitação #1 foi atualizada com sucesso!"
		Self:SetResponse(oRequest:ToJSon())
	Else
		SetRestFault(400, oRequest['error'])
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} getCardData(aDataReq)
Busca os dados da Solicitação

@param aDataReq - Cabeçalho padrão para buscar os dados da solicitação
@return aCardItens - Itens da solicitação

@since 20/01/2023
/*/
//-------------------------------------------------------------------
Static Function getCardData(aDataReq)
Local lRet        := .F.
Local lSetValue   := .F.
Local cErro       := ""
Local cMsg        := ""
Local xRet        := Nil
Local oWsdl       := Nil
Local nI          := 0
Local aSimple     := {}
Local aCardItens  := {}
Local cUrl        := StrTran(AllTrim(JFlgUrl())+"/ECMWorkflowEngineService?wsdl","//E","/E")
Local cWSMetodo   := "getInstanceCardData"

	oWsdl := JurConWsdl(cUrl, @cErro)

	// Define a operação
	If ( lRet := oWsdl:SetOperation( cWSMetodo ) )
		oWsdl:cLocation := cUrl
		aSimple := oWsdl:SimpleInput()

		// Define os parâmetros necessários para o serviço
		For nI := 1 To Len(aDataReq)
			lSetValue := JSetFields(aDataReq[nI][1], aDataReq[nI][2], aSimple, oWsdl)
			If !lSetValue
				lRet := .F.
				Exit
			EndIf
		Next nI

		// faz o envio das infos
		If lRet

			// Pega a mensagem SOAP que será enviada ao servidor
			xRet := oWsdl:GetSoapMsg()

			//Retirado o elemento da tag devido o obj nao suportar
			cMsg := StrTran(xRet, ' xmlns="http://ws.dm.ecm.technology.totvs.com/"', '')
			cMsg := StrTran(cMsg, ' xmlns="http://ws.foundation.ecm.technology.totvs.com/"', '')

			JConLogXML(cMsg, "E")  // Log do XML de Envio
			xRet := oWsdl:SendSoapMsg(cMsg)  // Envia a mensagem SOAP ao servidor
			xRet := oWsdl:GetSoapResponse()  // Pega a mensagem de resposta
			JConLogXML(xRet, "R")  // Log do XML de Recebimento

			// Tratamento para a resposta do serviço
			aCardItens := aClone( JFlSoapRes(xRet, "_CardData", "</CardData>") )
		EndIf
	
	Else 
		If !Empty(oWsdl:cError)
			cErro := oWsdl:cError
		Else
			cErro := STR0005 // "Problema para configurar o método webservice!"
		EndIf
		JurConout(cErro)
		Break
	EndIf	
Return aCardItens


//-------------------------------------------------------------------
/*/{Protheus.doc} SendToFlg(cNextStep, aDataReq, cObsAprov, aXmlCardData, cMsgFluig)
Envia os dados para o Fluig e movimenta a Solicitação para o proximo passo

@param cNextStep    - Proximo passo do Fluxo
@param aDataReq     - Cabeçalho dos dados para identificação da solicitação
@param cObsAprov    - Texto de Aprovação 
@param aXmlCardData - Informações da Solicitação 
@param cMsgFluig    - Mensagem de retorno do Fluig

@return oDados - Objeto com estrutura e infos da tarefa

@since 20/01/2023
/*/
//-------------------------------------------------------------------
Static Function SendToFlg(cNextStep, aDataReq, cObsAprov, aXmlCardData, cMsgFluig)
Local xRet        := Nil
Local oXml        := Nil
Local lRet        := .T.
Local nI          := 0
Local nPosTag     := 0
Local aCardData   := {}
Local aSubs       := {}
Local cObsComment := STR0011 //"Workflow atualizado via TOTVS Jurídico Departamento"
Local cExceptItem := "sObsAprovador" // Lista de campos que não serão copiados
Local cRefTgError := "</result>"
Local cErro       := ""
Local cAviso      := ""
	
	aAdd( aSubs, {'"', "'"})
	aAdd( aSubs, {" xmlns='http://ws.workflow.ecm.technology.totvs.com/'", ""})
	aAdd( aSubs, {"<item />", ""})

	// Pega os dados do getInstanceCardData
	For nI := 1 To Len(aXmlCardData)
		If !(aXmlCardData[nI]:_Item[1]:Text $ cExceptItem) .And. !Empty(aXmlCardData[nI]:_Item[2]:Text)
			aAdd(aCardData, {AllTrim(aXmlCardData[nI]:_Item[1]:Text)    , JurEncUTF8(AllTrim(aXmlCardData[nI]:_Item[2]:Text)) })
		EndIf
	Next nI

	aAdd(aCardData, {'sObsAprovador'    , JurEncUTF8(cObsAprov)           })

	// Atualiza dados padrão do Card
	aAdd(aDataReq, {"choosedState"      , cNextStep                       })
	aAdd(aDataReq, {"completeTask"      , "true"                          })
	aAdd(aDataReq, {"managerMode"       , "false"                         })
	aAdd(aDataReq, {"comments"          , JurEncUTF8(AllTrim(cObsComment))}) 
	aAdd(aDataReq, {"threadSequence"    , "0"                             })

	lRet := JA106TWSDL("ECMWorkflowEngineService", "saveAndSendTaskClassic", aDataReq, aCardData, aSubs, @xRet, @cMsgFluig) 

	If lRet
		If ("<key>ERROR</key>" $ xRet)
			nPosTag := At(StrTran(cRefTgError, "/", ""), xRet)  // Obtem a Tag <WorkflowTasks> do XML de retorno
			xRet    := SubStr(xRet, nPosTag, Len(xRet))  // Remove a Tag <WorkflowTasks> do inicio da resposta
			nPosTag := At(cRefTgError, xRet) + Len(cRefTgError) - 1
			xRet    := Left(xRet, nPosTag)

			oXml := XmlParser( xRet, "_", @cErro, @cAviso ) //Gera o objeto do Result Tag
			
			If oXml <> Nil
				cMsgFluig := JMsgErrFlg(oXml)
				JurConOut(cMsgFluig)
			EndIf

			lRet := .F.
		EndIf
	EndIf
Return lRet
