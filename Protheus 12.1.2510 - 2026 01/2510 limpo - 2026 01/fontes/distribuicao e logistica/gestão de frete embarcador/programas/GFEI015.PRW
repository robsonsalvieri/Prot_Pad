#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Desc.    ³ Funcao de integracao com o adapter EAI para recebimento  e   º±±
±±º          ³ do XML de Cadastro de emitentes,usando a tabela GU3.		    º±±
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
±±º Uso      ³ GFEA015                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 

Function GFEI015(cXml,nType,cTypeMsg)
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
    aResult := GFEA015REC(cXml,cTypeMsg)
EndIf

RestArea(aAreaXX4)

//- Adiciona o nome da Transação da mensagem no cadastro do Adapter EAI
//- Gatilha o campo XX4_MODEL
AAdd(aResult,cEntityName)

Return aResult

/*/
=================================================================================
{Protheus.doc} GFEA015REC(cXml,cTypeMsg)

//TODO Descrição : Funcao para tratar o xml de recebimento
@since 03/08/2017
@version undefined
@param cXml, characters, descricao
@type function
=================================================================================
/*/
Static Function GFEA015REC(cXml,cTypeMsg)

Local cXmlRet    	:= ""
Local lResult    	:= .T.
Local oModel 
Local oXml       	:= ""
Local cAction    	:= ""
Local cMarca		:= ""
Local aErrsList		:= {}  
Local lRet 			:= .T.
Local aErro 		:= {}
Local cCodeInt	 	:= ""
Local cCodeExt 		:= ""
Local cAlias 		:= "GU3"
Local cCampo 		:= "GU3_CDEMIT"
Local nOpcx 		:= 0
Local cTIPO			:= ""
Local cCDEMIT 		:= ""
Local cNMEMIT 		:= ""
Local cNMABRV		:= ""
Local cDTIMPL		:= "" 	
Local cNATUR 		:= ""	
Local cTRANSP		:= ""
Local cIDFED 		:= ""
Local cENDER 		:= ""
Local cNRCID 		:= ""
Local cNMCID		:= ""
Local cUF			:= ""
Local cBAIRRO		:= ""
Local cCEP			:= ""
Local cCOMPL		:= ""
Local cEMAIL 		:= ""
Local cFONE1		:= ""
Local cFAX			:= ""
Local cNUM 			:= ""
Local cVendorTyp	:= ""

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
    cCodeInt := PadR(CFGA070INT( cMarca, cAlias, cCampo, cCodeExt ), TamSX3('GU3_CDEMIT')[1])

    If Empty(cCodeInt)
        cCodeInt := cCodeExt
    EndIf

	cCDEMIT 	:= oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/Code")
	cNMEMIT 	:= oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/Name")
	cNMABRV		:= oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/ShortName")
	cDTIMPL		:= oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/RegisterDate")  	
	cNATUR 		:= oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/EntityType") 	
	cTIPO		:= oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/Type") 
	cTRANSP		:= oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/CarrierCode") 
	cVendorTyp	:= oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/VendorInformation/VendorType/VendorTypeCode") 
	
	cIDFED 		:= oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/GovernmentalInformation/Id")
  
	cENDER 		:= oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/Address/Address")
	cNUM    	:= oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/Address/Number")
	cBAIRRO		:= oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/Address/District")       
	cCOMPL		:= oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/Address/Complement")   
	cCEP		:= oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/Address/ZIPCode")    
	cNMCID		:= oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/Address/City/CityDescription")   
	cUF			:= oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/Address/State/StateCode")   
	
	cEMAIL 		:= oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/ListOfCommunicationInformation/CommunicationInformation/Email")      
	cFONE1		:= oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/ListOfCommunicationInformation/CommunicationInformation/PhoneNumber	")       
	cFAX		:= oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/ListOfCommunicationInformation/CommunicationInformation/FaxNumber")  

	If cNMCID == ""
		cNMCID := oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/Address/City/Description")
	EndIf
	
	If cUF == ""
		cUF := oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/Address/State/Code") 
	EndIf
	
	If cNum != ""
		cENDER := cENDER + ", " + cNum
	EndIf
	
	
    //Valida a ação sendo: upsert=inclusão/alteração ou delete=exclusão
    If cAction == "UPSERT" 
    	GU3->(dbSetOrder(1))
    	If !GU3->(dbSeek(xFilial("GU3")+ PADR(cCDEMIT,tamSX3("GU3_CDEMIT")[1])))
    		nOpcx := 3
    	Else
    		nOpcx := 4
    	EndIf
    ElseIf cAction == "DELETE"
    	GU3->(dbSetOrder(1))
    	GU3->(dbSeek(xFilial("GU3")+ PADR(cCDEMIT,tamSX3("GU3_CDEMIT")[1])))
    	nOpcx := 5
    Endif
    
	oModel := FWLoadModel( "GFEA015" )
	oModel:SetOperation( nOpcx )
	oModel:Activate()

	If nOpcx == 3
		oModel:SetValue("GFEA015_GU3",'GU3_CDEMIT' , cCDEMIT )
	Endif	

	If nOpcx != 5
		oModel:SetValue("GFEA015_GU3",'GU3_NMEMIT'	, cNMEMIT 	)
		oModel:LoadValue("GFEA015_GU3", 'GU3_SIT' 	, "1" 		)//Ativo		
		oModel:LoadValue("GFEA015_GU3",'GU3_ORIGEM' 	, "2"		)//ERP
		oModel:SetValue("GFEA015_GU3",'GU3_CDTERP' 	, cTRANSP	)//Código transportador no ERP
		oModel:SetValue("GFEA015_GU3",'GU3_NMABRV'	, cNMABRV	) 
		oModel:SetValue("GFEA015_GU3",'GU3_DTIMPL' 	, cDTIMPL	)
		oModel:LoadValue("GFEA015_GU3",'GU3_CDGREM' 	, "0"	)	
		
		oModel:SetValue("GFEA015_GU3",'GU3_IDFED' 	, cIDFED	)
		
		oModel:SetValue("GFEA015_GU3",'GU3_ENDER'		, cENDER 	)		
		oModel:SetValue("GFEA015_GU3",'GU3_BAIRRO'	, cBAIRRO 	)
		oModel:SetValue("GFEA015_GU3",'GU3_CEP' 		, cCEP		)	
		oModel:SetValue("GFEA015_GU3",'GU3_COMPL' 	, cCOMPL	)			
		oModel:LoadValue("GFEA015_GU3",'GU3_UF' 		, cUF		)
		oModel:LoadValue("GFEA015_GU3",'GU3_NMCID' 	, cNMCID	)	
		cNRCID := POSICIONE("GU7",3,xFILIAL("GU7")+ UPPER(PADR(cNMCID,TamSX3("GU7_NMCID")[1]))+UPPER(cUF),"GU7_NRCID") 
		oModel:SetValue("GFEA015_GU3",'GU3_NRCID'		, cNRCID	)	
		
		oModel:LoadValue("GFEA015_GU3",'GU3_EMAIL'	, cEMAIL 	)
		oModel:LoadValue("GFEA015_GU3",'GU3_FONE1' 	, cFONE1	)
		oModel:LoadValue("GFEA015_GU3",'GU3_FAX'		, cFAX 	)

		If cNATUR == "Person" .and. !empty(cTRANSP)
			oModel:SetValue("GFEA015_GU3",'GU3_NATUR' 	, "F"	)//Pessoa Física	
			//Quando for incluído um fornecedor pessoa física e tiver a tag CarrierCode preenchida, deve ser considerado Autônomo //
			oModel:SetValue("GFEA015_GU3",'GU3_TRANSP' 	, "1"	)		
			oModel:SetValue("GFEA015_GU3",'GU3_AUTON' 	, "1"	)
		Else 		
			oModel:SetValue("GFEA015_GU3",'GU3_NATUR' , "J"		)//Pessoa Juridica	
			If cTIPO == "Customer" // Cliente
				oModel:SetValue("GFEA015_GU3",'GU3_CLIEN' 	, "1"	)
			ElseIf cTIPO == "Vendor" // Fornecedor
				oModel:SetValue("GFEA015_GU3",'GU3_FORN ' 	, "1"	)
			ElseIf cTIPO == "Both" // Ambos
				oModel:SetValue("GFEA015_GU3",'GU3_CLIEN'	, "1"	)
				oModel:SetValue("GFEA015_GU3",'GU3_FORN', "1"	)
			ElseIf !Empty(cTRANSP)
				oModel:SetValue("GFEA015_GU3",'GU3_TRANSP' 	, "1"	)	
			EndIf	
			
			If cVendorTyp == "5"	
				oModel:SetValue("GFEA015_GU3", 'GU3_TRANSP', "1")
			EndIf
		EndIf	
		
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
		
		cXmlRet := ""
		
		cXmlRet += _NoTags(aErro[6])
               
		lResult := .F.
	EndIf
    oModel:DeActivate()
    oModel:Destroy()
    oModel := Nil
    
    //+--------------------------------------------------------------
    //| Trata a mensagem de Resposta/Devolve Mensagem.
    //+--------------------------------------------------------------
ElseIf cTypeMsg == EAI_MESSAGE_RESPONSE

    //+--------------------------------------------------------------
    //| Mensagem: responde com a Versão
    //+--------------------------------------------------------------
ElseIf cTypeMsg == EAI_MESSAGE_WHOIS
    cXmlRet := "1.000|1.001|2.005"

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
