#Include "TOTVS.CH"
#Include "FWMVCDEF.CH"
#Include "FWADAPTEREAI.CH"
#Include "AGDIP120.CH"
#Define MODEL_NAME  "AGDA120"

/*/{Protheus.doc} AGDIP120
Adapter EAI para envio da Receita/Itens de Receita (AGDA120) ao AgroReceita,
utilizando Mensagem Única em formato JSON.
@type    function
@version 12
@author rodrigo.nsoledade
@since   03/12/2025
@param   xEnt       , variant   , xml/obj para envio/recebimento
@param   cTypeTrans , character , '0'=TRANS_SEND, '1'=TRANS_RECEIVE
@param   cTypeMsg   , character , Tipo Mensagem '20','21','22','23'
@param   cVersion   , character , Versão da mensagem
@param   cTransac   , character , Nome da transação (mensagem única)
@param   lEAIObj    , logical   , .T. = objeto JSON (FWEAIobj)
@return  array, { lResult , xValue(oFWEAIobj ou cMsgErr) , cModelName }
/*/
Function AGDIP120(xEnt, nTypeTrans, cTypeMessage, cVersion, cTransac, lEAIObj)
    Local lRet     := .T.
	Local aRet     := { .T., "" }
	Local aAux     := { .F., "" }
    Default lEAIObj := .F.

	If !lEAIObj
		If nTypeTrans == TRANS_RECEIVE

			If cTypeMessage == EAI_MESSAGE_WHOIS
				aAux := { lRet , "1.000"  }
			else
				lRet     := .F.
				aAux := { lRet , 	STR0004 } //"Mensagem Não Implementada"
			EndIf

			aRet := { aAux[ 1 ] , aAux[ 2 ], MODEL_NAME }

		ElseIf nTypeTrans == TRANS_SEND

			lRet     := .F.
			aAux := { lRet , 	STR0005 } //"Mensagem Não Implementada para XML"
			aRet := { aAux[ 1 ] , aAux[ 2 ], MODEL_NAME }

		EndIf

	Else
		//FORMATO JSON
		If nTypeTrans == TRANS_RECEIVE
			If cTypeMessage == EAI_MESSAGE_WHOIS
				aAux := { lRet , "1.000"  }
			else
				lRet     := .F.
				aAux := { lRet , 	STR0004 } //'Mensagem Não Implementada'
			EndIf

			aRet := { aAux[ 1 ] , aAux[ 2 ], MODEL_NAME }

		ElseIf nTypeTrans == TRANS_SEND

			aAux := genEAIobj()

			aRet := { aAux[ 1 ] , aAux[ 2 ], MODEL_NAME }

		EndIf
	EndIf

Return aRet

/*/{Protheus.doc} genEAIobj
Gera o objeto JSON (FWEAIobj) para envio da Receita (NE6) e Itens (NE7)
a partir dos MODELOS ao AgroReceita.
@type    function
@version 12
@author  rodrigo.nsoledade
@since   03/12/2025
@return  array, { lResult , xValue(oFWEAIobj ou cMsgErr) }
/*/
Static Function genEAIobj()
    Local aReturn     := { .F., Nil }
    Local oModelAct   := FWModelActive()
    Local oMdlNE6     := Nil
    Local oMdlNE7     := Nil
    Local oFWEAIobj   := Nil
    Local cEvent      := "upsert"
    Local cInternalId := ""
    Local cExternalId := ""
    Local nI          := 0

    // Valida o modelo ativo
    If oModelAct == Nil          ;
        .Or. ValType(oModelAct) != "O" ;
        .Or. !oModelAct:IsActive()     ;
        .Or. oModelAct:GetId() != MODEL_NAME
        aReturn[2] := STR0002 //"Modelo não ativo."
        Return aReturn
    EndIf

    // Obtém modelos NE6 (pai) e NE7 (filho)
    oMdlNE6 := oModelAct:GetModel("AGDA120_NE6")
    oMdlNE7 := oModelAct:GetModel("AGDA120_NE7")

    //  INTERNAL ID E EXTERNAL ID (via CFGA070Ext)    
    cInternalId := cEmpAnt + "|" + cFilAnt + "|" + oMdlNE6:GetValue("NE6_CODREC")
    cExternalId := CFGA070Ext(cEmpAnt + "|" + cFilAnt, "NE6", "NE6_CODREC", cInternalId)

    //  OBJETO JSON
    oFWEAIobj := FWEAIobj():New()
    oFWEAIobj:Activate()
    oFWEAIobj:setEvent(cEvent)

    oFWEAIobj:setProp("Entity"            , MODEL_NAME)
    oFWEAIobj:setProp("Event"             , cEvent)
    oFWEAIobj:setProp("InternalId"        , cInternalId)
    oFWEAIobj:setProp("ExternalId"        , AllTrim(cExternalId))
    oFWEAIobj:setProp("CompanyId"         , cEmpAnt)
    oFWEAIobj:setProp("BranchId"          , cFilAnt)
    oFWEAIobj:setProp("ReceiptId"         , oMdlNE6:GetValue("NE6_CODREC"))
    oFWEAIobj:setProp("ExternalReceiptId" , AllTrim(oMdlNE6:GetValue("NE6_CODEXT")))
    oFWEAIobj:setProp("CustomerCode"      , oMdlNE6:GetValue("NE6_CLIENT"))
    oFWEAIobj:setProp("CustomerStore"     , oMdlNE6:GetValue("NE6_LOJA"))
    oFWEAIobj:setProp("ReceiptNumber"     , AllTrim(oMdlNE6:GetValue("NE6_NUMREC")))
    oFWEAIobj:setProp("IssueDate"         , oMdlNE6:GetValue("NE6_DTEMIS"))
    oFWEAIobj:setProp("IssueTime"         , oMdlNE6:GetValue("NE6_HREMIS"))
    oFWEAIobj:setProp("InvoiceNumber"     , oMdlNE6:GetValue("NE6_DOC"))
    oFWEAIobj:setProp("InvoiceSeries"     , oMdlNE6:GetValue("NE6_SERIE"))
    oFWEAIobj:setProp("Status"            , oMdlNE6:GetValue("NE6_STATUS"))
    oFWEAIobj:setProp("SourceOrder"       , oMdlNE6:GetValue("NE6_PEDORI"))
    oFWEAIobj:setProp("ReceiptUrl"        , oMdlNE6:GetValue("NE6_URLREC"))
    oFWEAIobj:setProp("Culture"           , oMdlNE6:GetValue("NE6_CULTUR"))
    oFWEAIobj:setProp("Notes"             , oMdlNE6:GetValue("NE6_OBS"))
    oFWEAIobj:setProp("StatusNF"          , oMdlNE6:GetValue("NE6_STSNF"))

    //  ITENS (NE7) – várias linhas
    For nI := 1 To oMdlNE7:Length()

        oMdlNE7:GoLine(nI)

        oFWEAIobj:setprop("Items",{},'Item',,.T.)
		oFWEAIobj:getPropValue("Items")[nI]:setProp("ItemSequence"     , oMdlNE7:GetValue("NE7_SEQREC"))
		oFWEAIobj:getPropValue("Items")[nI]:setProp("ProductCode"      , oMdlNE7:GetValue("NE7_PRODUT"))
		oFWEAIobj:getPropValue("Items")[nI]:setProp("Quantity"         , oMdlNE7:GetValue("NE7_QTDE"))
		oFWEAIobj:getPropValue("Items")[nI]:setProp("AvailableQuantity", oMdlNE7:GetValue("NE7_QTDISP"))

    Next nI
    oMdlNE7:GoLine(1)

    aReturn[1] := .T.
    aReturn[2] := oFWEAIobj
Return aReturn
