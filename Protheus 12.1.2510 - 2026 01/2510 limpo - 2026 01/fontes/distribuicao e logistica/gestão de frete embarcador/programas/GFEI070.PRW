#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "TBICONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Funcao ³ GFEI070 º Autor ³ Estela Baratto           º Data ³ 04/10/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Desc.    ³ Funcao de integracao com o adapter EAI para envio            º±±
±±º          ³ do XML de Fatura de Frete.                                º±±
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
±±º Uso      ³ GFEA070                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 

Function GFEI070(cXml,nType,cTypeMsg)
Local aResult           := {}
Private cEntityName     := ""
Private aAreaXX4        := {}
Private lMsErroAuto     := .F.    //Armazena o status da execucao da MsExecAuto
Private lGFEA096        := .F. 
Private lAutoErrNoFile  := .T.
Private cVersion        := "1.000"

//--Obtém a versão caso seja necessário realizar algum tratamento por versão
dbSelectArea('XX4')
aAreaXX4 := XX4->(GetArea())

//+---------------------------------------------------------------------
//| Mensagem - ENVIO
//+---------------------------------------------------------------------
If nType == TRANS_SEND
    aResult := GFEI070ENV()
    
ElseIf nType == TRANS_RECEIVE  
    //+---------------------------------------------------------------------
	//| Mensagem - Recebimento
	//+---------------------------------------------------------------------
	aResult := GFEI070REC(cXml,cTypeMsg)
    
EndIf

RestArea(aAreaXX4)

//- Adiciona o nome da Transação da mensagem no cadastro do Adapter EAI
//- Gatilha o campo XX4_MODEL
AAdd(aResult,cEntityName)
AAdd(aResult,.F.)
AAdd(aResult,.F.)
      
Return aResult


/*/
=================================================================================
{Protheus.doc} GFEI070ENV

//TODO Descrição : Funcao para tratar o xml de envio
@author Estela Baratto
@since 04/10/2017
@version undefined
@param cXml, characters, descricao
@type function
=================================================================================
/*/
Static Function GFEI070ENV()

Local cXmlRet     	:= ""
Local lResult     	:= .T.
Local cInternalId 	:= ""
Local cEvent      	:= "upsert"
Local cGW6_EMIFAT 	:= GW6->GW6_EMIFAT
Local cGW6_NRFAT	:= GW6->GW6_NRFAT
Local cGW6_SERFAT  	:= GW6->GW6_SERFAT
Local cGW6_DTEMIS 	:= Transform(dToS(GW6->GW6_DTEMIS),"@R 9999-99-99")
Local cGW6_DTVENC 	:= Transform(dToS(GW6->GW6_DTVENC),"@R 9999-99-99")
Local cGW6_DTFIN 	:= Transform(dToS(GW6->GW6_DTFIN),"@R 9999-99-99")
Local cGW6_VLFATU   := cValToChar(GW6->GW6_VLFATU)
Local cGW6_OBS      := GW6->GW6_OBS
Local nGW6_VLISRE	:= GW6->GW6_VLISRE
Local cCityCode 	:= ""
Local nBaseCalc 	:= 0
Local nGW6_VLDESC	:= GW6->GW6_VLDESC
Local nGW6_VLJURO	:= GW6->GW6_VLJURO

If GW6->GW6_SITFIN == '5'
	cEvent := "delete"
EndIf
    
If nGW6_VLISRE > 0
	//CITYCODE: código IBGE da cidade (GU7_NRCID) do emissor da primeira nota relacionado ao primeiro documento de frete da fatura
	GW3->(dbSetOrder(8))
	GW3->(dbSeek(xFilial("GW6")+cGW6_EMIFAT+cGW6_SERFAT+cGW6_NRFAT+DToS(GW6->GW6_DTEMIS)))
		GW4->(dbSetOrder(1))
		GW4->(dbSeek(GW3->GW3_FILIAL+GW3->GW3_EMISDF+GW3->GW3_CDESP+GW3->GW3_SERDF+GW3->GW3_NRDF+DToS(GW3->GW3_DTEMIS)))
			GW1->(dbSetOrder(1))
			GW1->(dbSeek(GW4->(GW4_FILIAL+GW4_TPDC+GW4_EMISDC+GW4_SERDC+GW4_NRDC)))
				GWU->(dbSetOrder(1))
				GWU->(dbSeek(GW1->(GW1_FILIAL+GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC)))
					cCityCode := GWU->GWU_NRCIDD
					
	//CalculationBasis: somatório das bases de impostos dos documentos de frete relacionados que têm ISS Retido.
	GW3->(dbSetOrder(8))
	GW3->(dbSeek(xFilial("GW6")+cGW6_EMIFAT+cGW6_SERFAT+cGW6_NRFAT+DToS(GW6->GW6_DTEMIS)))
	While !GW3->( Eof() ) .And. xFilial("GW6")+cGW6_EMIFAT+cGW6_SERFAT+cGW6_NRFAT+DToS(GW6->GW6_DTEMIS) == ;
	 							GW3->GW3_FILIAL+GW3->GW3_EMIFAT+GW3->GW3_SERFAT+GW3->GW3_NRFAT+DToS(GW3->GW3_DTEMIS)
	 							
		GVT->(dbSetOrder(1))
		GVT->(dbSeek(xFilial("GVT")+GW3->GW3_CDESP))
		
		If GVT->GVT_TPIMP == '2' .And. GW3->GW3_IMPRET > 0 //Imposto é ISS e tem Valor Retido.
			nBaseCalc += GW3->GW3_BASIMP
		EndIf
		
		GW3->(dbSkip())
	EndDo
	
EndIf

cInternalId := getIntlId()

cXMLRet := "<BusinessEvent>"
cXMLRet +=     "<Entity>" 	+ cEntityName + "</Entity>"
cXMLRet +=     "<Event>" 	+ cEvent 	  + "</Event>"
cXMLRet +=     "<Identification>"
cXMLRet +=          "<key name=" + Chr( 34 )+ "InternalId" 				+ Chr( 34 ) + ">" + cInternalId + "</key>"
If nGW6_VLJURO > 0
	cXMLRet +=          "<key name=" + Chr( 34 )+ "FinancialAdjustment1" 	+ Chr( 34 ) + ">" + "JUROS" 	+ "</key>"
	cXMLRet +=          "<key name=" + Chr( 34 )+ "ValueAdjustment1"		+ Chr( 34 ) + ">" + cValToChar(nGW6_VLJURO) + "</key>"
EndIf
If nGW6_VLDESC > 0
	cXMLRet +=          "<key name=" + Chr( 34 )+ "FinancialAdjustment2" 	+ Chr( 34 ) + ">" + "DESCONTO" 	+ "</key>"
	cXMLRet +=          "<key name=" + Chr( 34 )+ "ValueAdjustment2" 		+ Chr( 34 ) + ">" + cValToChar(nGW6_VLDESC) + "</key>"
EndIf
cXMLRet +=     "</Identification>"
cXMLRet += "</BusinessEvent>"

cXMLRet += "<BusinessContent>"
	
cXMLRet += 		"<InternalId>"          + cInternalId                               + "</InternalId>"

cXMLRet += 	    "<CompanyId>"         	+ cEmpAnt                                   + "</CompanyId>"
cXMLRet +=      "<BranchId>"          	+ cFilAnt                                   + "</BranchId>"
cXMLRet +=      "<ListOfAccountPayableDocument>"
cXMLRet +=      		"<AccountPayableDocument>"
cXMLRet +=   					"<InternalId>"          + cInternalId                 + "</InternalId>"
cXMLRet +=   					"<DocumentPrefix>"      + cGW6_SERFAT                 + "</DocumentPrefix>"
cXMLRet +=   					"<DocumentNumber>"     	+ cGW6_NRFAT                  + "</DocumentNumber>"
cXMLRet +=      				"<DocumentParcel>"      + "1"                         + "</DocumentParcel>"
cXMLRet +=               		"<IssueDate>"   	    + cGW6_DTEMIS                 + "</IssueDate>"
cXMLRet +=               		"<ReceiptDate>"   	    + cGW6_DTFIN                  + "</ReceiptDate>"
cXMLRet +=               		"<DueDate>"   	    	+ cGW6_DTVENC                 + "</DueDate>"
cXMLRet +=                  	"<RealDueDate>"     	+ cGW6_DTVENC                 + "</RealDueDate>"
cXMLRet +=      				"<VendorCode>"        	+ cGW6_EMIFAT                 + "</VendorCode>"
cXMLRet +=      				"<NetValue>"     	    + cGW6_VLFATU                 + "</NetValue>"
cXMLRet +=      				"<GrossValue>"   	    + cGW6_VLFATU                 + "</GrossValue>"
cXMLRet +=      				"<Observation>"   	    +  cGW6_OBS                   + "</Observation>"
cXMLRet +=      				"<Origin>"          	+ "PROTHEUS_GFE"              + "</Origin>"

If nGW6_VLISRE > 0
	cXMLRet +=      				"<Taxes>"
	cXMLRet +=      					"<Tax>"
	cXMLRet +=      						"<Attributes>"
	cXMLRet +=      							"<Taxe>" 				+ "ISS" 					+ "</Taxe>"
	cXMLRet +=      							"<CityCode>" 			+ cCityCode 				+ "</CityCode>"
	cXMLRet +=      							"<CalculationBasis>" 	+ cValToChar(nBaseCalc) 	+ "</CalculationBasis>"
	cXMLRet +=      							"<Value>" 				+ cValToChar(nGW6_VLISRE) 	+ "</Value>"
	cXMLRet +=      						"</Attributes>"
	cXMLRet +=      					"</Tax>"
	cXMLRet +=      				"</Taxes>"
EndIf

cXMLRet +=                  "<ApportionmentDistribution>"
	
GW7->( dbSetOrder(1) )
GW7->( dbseek(GW6->GW6_FILIAL+GW6->GW6_EMIFAT+GW6->GW6_SERFAT+GW6->GW6_NRFAT+DTOS(GW6->GW6_DTEMIS)) )

While !GW7->(EOF()) .And. ;
		GW6->(GW6->GW6_FILIAL+GW6->GW6_EMIFAT+GW6->GW6_SERFAT+GW6->GW6_NRFAT+DTOS(GW6->GW6_DTEMIS)) == ;
		GW7->(GW7->GW7_FILIAL+GW7->GW7_EMIFAT+GW7->GW7_SERFAT+GW7->GW7_NRFAT+DTOS(GW7->GW7_DTEMIS)) 
	              
	cXMLRet +=						    "<Apportionment>"	 
	cXMLRet +=							    "<CostCenterInternalId>" + GW7->GW7_UNINEG + "</CostCenterInternalId>"
	cXMLRet +=				               "<Value>" + cValToChar(GW7->GW7_VLMOV) + "</Value>"
	cXMLRet +=				           "</Apportionment>"	
	    	
	GW7->(DBSKIP())
		
EndDo
		
cXMLRet +=				       "</ApportionmentDistribution>"
cXMLRet += 	  			"</AccountPayableDocument>"
cXMLRet += 	  	"</ListOfAccountPayableDocument>"
cXMLRet += "</BusinessContent> "

Return {lResult,cXmlRet}

/*/
=================================================================================
{Protheus.doc} GFEI070REC(cXml,cTypeMsg)

//TODO Descrição : Funcao para tratar o xml de recebimento
@author Hercilio Neto
@since 06/10/2017
@version undefined
@param cXml, characters, descricao
@type function
=================================================================================
/*/
Static Function GFEI070REC(cXml,cTypeMsg)

Local cXMLRet   := ""
Local lResult := .T.
Local oXml   	:= ""
Local cStatus
Local aErrsList	:= {}
Local aMessageError := {}
Local cMessageError := ""
Local cProcessed
Local aFatKey := {}
Local cFatKey       := ""
Local nI := 0
Local cDelType 
Local nContMsg
Local cErrorXml := ""
Local cWarnXml := ""
Local cGW6_FILIAL := ""
Local cGW6_EMIFAT := ""
Local cGW6_SERFAT := ""
Local cGW6_NRFAT := ""
Local cGW6_DTEMIS := ""

	//+--------------------------------------------------------------
	//| Trata a mensagem de Resposta/Devolve Mensagem.
	//+--------------------------------------------------------------
	If cTypeMsg == EAI_MESSAGE_RESPONSE
	
	   oXml := TXmlManager():new()	   
       If !oXml:Parse(cXml)         
        	lResult:= .F.        	
        	Aadd(aErrsList, {"", 1, ""}) // Description | nType: 1-ERROR;2-WARNING | cCode : Generic Code
        	cXmlRet := FWEAILOfMessages(aErrsList)        	
        	Return {lResult,cXmlRet}        	
    	EndIf
    	    	
    	cDocKey    := oXml:xPathGetNodeValue("/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalIdDocument/InternalIdDocument/Origin")  
		IF Len(cDocKey) > 0
			aDocKey := StrToKArr(cDocKey, "|")
			cFili	:= PadR(Alltrim(aDocKey[1]), TamSX3("GXE_FILIAL")[1])
		    cCodLot	:= PadR(Alltrim(aDocKey[2]), TamSX3("GXE_CODLOT")[1])
		    
		    GXE->(dbSetOrder(1))
		    lGFEA096 := GXE->(dbSeek(cFili + cCodLot)) 		    
		Else
			IF AT("GFEI096",cXml) > 0
				lGFEA096 := .T.				
			EndIf
		EndIf
		
		if lGFEA096
			Return GFEI096(cXml,TRANS_RECEIVE,cTypeMsg)			
		Else
		cDelType := oXml:xPathGetNodeValue("/TOTVSMessage/MessageInformation/DeliveryType")
		cFatKey    := oXml:xPathGetNodeValue("/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalIdDocument/InternalIdDocument/Origin")  
				
		cStatus 	:= oXml:xPathGetNodeValue("/TOTVSMessage/ResponseMessage/ProcessingInformation/Status")
		cProcessed	:= oXml:xPathGetNodeValue("/TOTVSMessage/ResponseMessage/ProcessingInformation/ProcessedOn")
		
		aFatKey := StrToKArr(cFatKey, "|")
		cGW6_FILIAL := Alltrim(aFatKey[1])
		cGW6_EMIFAT := Alltrim(aFatKey[2])
		cGW6_SERFAT := Alltrim(aFatKey[3])
		cGW6_NRFAT 	:= Alltrim(aFatKey[4])
		cGW6_DTEMIS := Alltrim(aFatKey[5])
		
		GW6->(dbSetOrder(1))
		GW6->(dbSeek(PadR(cGW6_FILIAL, TamSX3("GW6_FILIAL")[1]) + PadR(cGW6_EMIFAT, TamSX3("GW6_EMIFAT")[1]) + PadR(cGW6_SERFAT, TamSX3("GW6_SERFAT")[1]) + PadR(cGW6_NRFAT, TamSX3("GW6_NRFAT")[1]) + cGW6_DTEMIS))	
		
		If cStatus == "ok"
		
		    If GW6->GW6_SITFIN == "2"			    
	        	StartJob("GFEI70UPD",getenvserver(),.T.,cEmpAnt,cFilAnt, GW6->(RecNo()),"4","")	        	
	        ElseIf GW6->GW6_SITFIN == "5"		            
	        	StartJob("GFEI70UPD",getenvserver(),.T.,cEmpAnt,cFilAnt, GW6->(RecNo()),"1","")	     
	        EndIf       
		Else
		    oXML := XmlParser(cXml,"_",@cErrorXml, @cWarnXml)
			If oXML != NIL
				aMessageError := ListErrors(oXML)
	        EndIf
	        
	        For nI := 1 To Len(aMessageError)
	        	cMessageError += aMessageError[nI][1] + ". "
	        Next nI
	        
	        If GW6->GW6_SITFIN == "2"	           
	        	StartJob("GFEI70UPD",getenvserver(),.T.,cEmpAnt,cFilAnt, GW6->(RecNo()),"3",cMessageError)
	        ElseIf GW6->GW6_SITFIN == "5"		            
	        	StartJob("GFEI70UPD",getenvserver(),.T.,cEmpAnt,cFilAnt, GW6->(RecNo()),"4",cMessageError)
	        EndIf
	    EndIf
	EndIf
			
	//+--------------------------------------------------------------
    //| Mensagem: responde com a Versão
    //+--------------------------------------------------------------
	ElseIf cTypeMsg == EAI_MESSAGE_WHOIS
   		cXmlRet := "1.000"
   		
    //+--------------------------------------------------------------
    //| Trata a mensagem de Negocio/BusinessMessage
    //+--------------------------------------------------------------
	ElseIf cTypeMsg == EAI_MESSAGE_RECEIPT
			
	EndIf

Return {lResult,cXmlRet}

function GFEI70UPD(cCodEmp, cCodFil, nRecNo, cSitFin, cMotFin)
	
	PREPARE ENVIRONMENT EMPRESA cCodEmp FILIAL cCodFil TABLES  'GW6' MODULO 'GFE'
	
	dbSelectArea("GW6")
	GW6->(dbGoTo(nRecNo))
	RecLock("GW6", .F.)
		GW6->GW6_SITFIN  	:= cSitFin
		GW6->GW6_MOTFIN  	:= cMotFin
	MsUnlock()

Return .T.
/*/{Protheus.doc} getIntlId
//TODO Recupera a identificação interna da mensagem trafegada.
@author Estela Baratto
@since 05/10/2017
@version 1.000

@type function
/*/
Static Function getIntlId()
Local cResult := ""

cResult := GW6->GW6_FILIAL + "|" + GW6->GW6_EMIFAT + "|" + GW6->GW6_SERFAT + "|" + GW6->GW6_NRFAT + "|" + DTOS(GW6->GW6_DTEMIS) + "|" + "GFEI070"

Return cResult

/*/{Protheus.doc} ListErrors
//TODO Descrição auto-gerada.
@author Hercilio Neto
@since 24/10/2017
@version undefined
@param oXML, object, descricao
@type function
/*/
Static Function ListErrors(oXML)
Local aLisMsg := {}
Local cMsg    := ""
Local cType   := ""
Local cCode   := ""
Local nType   := 1
Local nCount  := 0
     
//-- Mensagens de erro no padrao ListOfMessages
If XmlChildEx(oXml:_TOTVSMessage, '_RESPONSEMESSAGE' ) != Nil .And.;
	XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage, '_PROCESSINGINFORMATION' ) != Nil .And.;
	XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation, '_LISTOFMESSAGES' ) != Nil .And.;
	XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages, '_MESSAGE' ) != Nil

	//-- Se nao for array
	If ValType(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message) != "A"
		//-- Transforma em array
		XmlNode2Arr(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message, "_Message")
	EndIf

	//-- Percorre o array para obter os erros gerados
	For nCount := 1 To Len(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message)

		cMsg    := ""
		cType   := ""
		cCode   := ""
		nType   := 1

		cMsg := oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount]:Text

		//-- Verifica se o tipo da mensagem foi informado
		If XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount], '_TYPE' ) != Nil .And.;
			!Empty(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount]:_type:Text)
			
			cType := oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount]:_type:Text
			Do Case
				Case (Upper(cType) == "ERROR")
				nType := 1
				Case (Upper(cType) == "WARNING")
				nType := 2
			EndCase
			
		EndIf

		//-- Verifica se o codigo da mensagem foi informado
		If XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount], '_CODE' ) != Nil .And.;
			!Empty(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount]:_code:Text)
			
			cCode := oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount]:_code:Text
		EndIf

		If ! Empty(cCode)
			cMsg += " (" + cCode + ")"
		EndIf

		Aadd(aLisMsg, {cMsg, nType, cCode})
	Next nCount
EndIf

Return aLisMsg
