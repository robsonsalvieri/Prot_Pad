#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Funcao   ³ GFEI020 º Autor ³ Hercilio Henning Neto  º Data ³ 18/07/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Desc.    ³ Funcao de integracao com o adapter EAI para recebimento  e   º±±
±±º          ³ envio do XML de Cadastro de cidades,usando a tabela cidade.  º±±
±±º          ³ Conceito de mensagem unica.                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Param.   ³ cXML - Variavel com conteudo xml para envio/recebimento.     º±±
±±º          ³ nTypeTrans - Tipo de transacao. (Envio/Recebimento)          º±±
±±º          ³ cTypeMessage - Tipo de mensagem. (Business Type, WhoIs, etc) º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno  ³ aRet - Array contendo o resultado da execucao e a mensagem   º±±
±±º          ³        Xml de retorno.                                       º±±
±±º          ³ aRet[1] - (boolean) Indica o resultado da execução da função º±±
±±º          ³ aRet[2] - (caracter) Mensagem Xml para envio                 º±±
±±º          ³ aRet[3] - (caracter) Nome da Mensagem Transacional que iden- º±±
±±º          ³           tifica a integracao para execução pelo adapter EAI.º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso      ³ GFEA020                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Function GFEI020(cXml,nType,cTypeMsg)
Local aResult           := {}
Private cEntityName    := ""
Private aAreaXX4        := {}

//--Obtém a versão caso seja necessário realizar algum tratamento por versão
dbSelectArea('XX4')
aAreaXX4 := XX4->(GetArea())

//+---------------------------------------------------------------------
//| Mensagem - Recebimento
//+---------------------------------------------------------------------
If nType == TRANS_RECEIVE
    aResult := GFEA020REC(cXml,cTypeMsg)
EndIf

RestArea(aAreaXX4)

//- Adiciona o nome da Transação da mensagem no cadastro do Adapter EAI
//- Gatilha o campo XX4_MODEL
AAdd(aResult,cEntityName)

Return aResult

/*/
=================================================================================
{Protheus.doc} _FReceive(cXml,cTypeMsg)

//TODO Descrição : Funcao para tratar o xml de recebimento
@author Hercilio Henning Neto
@since 18/07/2017
@version undefined
@param cXml, characters, descricao
@type function
=================================================================================
/*/
Static Function GFEA020REC(cXml,cTypeMsg)

Local cXmlRet     := ""
Local lResult     := .T.
Local oModel 
Local oXml        := ""
Local cAction     := ""
Local cMarca      := ""
Local aErrsList   := {}
Local cCodIBGE := ""
Local cNomeCidade := ""
Local cUF := ""
Local lRet := .T.
Local aErro := {}
Local cCodeInt := ""
Local cCodeExt := ""
Local cAlias := "GU7"
Local cCampo := "GU7_NRCID"
Local nx := 0
Local nOpcx := 0

//+--------------------------------------------------------------+
//| Trata a mensagem de Negocio/BusinessMessage					 |
//+--------------------------------------------------------------+
If cTypeMsg == EAI_MESSAGE_BUSINESS
	
	oXml := TXmlManager():new()
    If !oXml:Parse(cXml)

        lResult:= .F.
        Aadd(aErrsList, {"", 1, ""}) // Description | nType: 1-ERROR;2-WARNING | cCode : Generic Code

        cXmlRet := FWEAILOfMessages(aErrsList)

        Return {lResult,cXmlRet}
    EndIf
	
	//Inicio do processamento do XML de Endereço de Entrega.
    cAction    := Upper(oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessEvent/Event"))
    cCodeExt   := oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessEvent/Identification")
    cMarca     := oXml:XPathGetAtt( "/TOTVSMessage/MessageInformation/Product", "name" )

    //Obtém o código interno da tabela de/para através de um código externo
    cCodeInt := PadR(CFGA070INT( cMarca, cAlias, cCampo, cCodeExt ), TamSX3('GU7_NRCID')[1])

    If Empty(cCodeInt)
        cCodeInt := cCodeExt
    EndIf

    cCodIBGE 	:= oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/OfficialCode")
    cNomeCidade := oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/Description")
    cUF 		:= oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/FederalUnit")

    //Valida a ação sendo: upsert=inclusão/alteração ou delete=exclusão
    If cAction == "UPSERT" 
    	GU7->(dbSetOrder(1))
    	If !GU7->(dbSeek(xFilial("GU7")+cCodIBGE))
    		nOpcx := 3
    	Else
    		nOpcx := 4
    	EndIf
    ElseIf cAction == "DELETE"
    	GU7->(dbSetOrder(1))
    	GU7->(dbSeek(xFilial("GU7")+cCodIBGE))
    	nOpcx := 5
    Endif
    
	oModel := FWLoadModel( "GFEA020" )
	oModel:SetOperation( nOpcx )
	oModel:Activate()
	
	If nOpcx != 5
		oModel:SetValue("GFEA020_GU7",'GU7_NRCID' , cCodIBGE	)
		oModel:SetValue("GFEA020_GU7",'GU7_NMCID' , cNomeCidade )
		oModel:SetValue("GFEA020_GU7",'GU7_CDUF'  , cUF			)
		oModel:SetValue("GFEA020_GU7",'GU7_CDPAIS', "105"		)
	EndIf
	
	lRet := oModel:VldData()
	
	If lRet
		oModel:CommitData()
		// Monta xml com status do processamento da rotina automatica OK.
        cXMLRet +=      "<ListOfInternalId>"
        cXMLRet +=            "<InternalId>"
        cXMLRet +=                  "<Name>CodeInternalId</Name>"
        cXMLRet +=                  "<Origin>"      + cCodeExt + "</Origin>"
        cXMLRet +=                  "<Destination>" + cCodeInt + "</Destination>"
        cXMLRet +=            "</InternalId>"
        cXMLRet +=      "</ListOfInternalId>"
	Else
		//Recupera as mensagens de erro
		aErro := oModel:GetErrorMessage()
		oModel:DeActivate()
		cXmlRet := ""
		
        cXmlRet += _NoTags(aErro[6])
        
		lResult := .F.
	EndIf
    
    //+--------------------------------------------------------------
    //| Trata a mensagem de Resposta/Devolve Mensagem.
    //+--------------------------------------------------------------
ElseIf cTypeMsg == EAI_MESSAGE_RESPONSE

    //+--------------------------------------------------------------
    //| Mensagem: responde com a Versão
    //+--------------------------------------------------------------
ElseIf cTypeMsg == EAI_MESSAGE_WHOIS
    cXmlRet := "1.000|1.001"

    //+--------------------------------------------------------------
    //| Trata a mensagem de Negocio/BusinessMessage
    //+--------------------------------------------------------------
ElseIf cTypeMsg == EAI_MESSAGE_RECEIPT

EndIf

//Monta a mensagem de erro
If !Empty(aErrsList)
    lResult := .F.
    cXmlRet := FWEAILOfMessages( aErrsList )
EndIf

Return {lResult,cXmlRet}