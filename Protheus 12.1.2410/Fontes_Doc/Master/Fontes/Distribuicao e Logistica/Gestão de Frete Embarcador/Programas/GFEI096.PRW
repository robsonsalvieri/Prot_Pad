#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "TBICONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Funcao ³ GFEI096 º Autor ³ Squad Adm Frete          º Data ³ 06/09/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Desc.    ³ Funcao de integracao com o adapter EAI para envio            º±±
±±º          ³ do XML de Lote de Provisão.                                  º±±
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
±±º Uso      ³ GFEA096                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 

Function GFEI096(cXml,nType,cTypeMsg)
Local   aResult         := {}
Private cEntityName     := ""
Private aAreaXX4        := {}
Private lMsErroAuto     := .F.    //Armazena o status da execucao da MsExecAuto
Private lAutoErrNoFile  := .T.
Private cVersion        := "1.000"

//--Obtém a versão caso seja necessário realizar algum tratamento por versão
dbSelectArea('XX4')
aAreaXX4 := XX4->(GetArea())

//+---------------------------------------------------------------------
//| Mensagem - ENVIO
//+---------------------------------------------------------------------
If nType == TRANS_SEND
    aResult := GFEI096ENV()
    
    //+---------------------------------------------------------------------
	//| Mensagem - Recebimento
	//+---------------------------------------------------------------------
ElseIf nType == TRANS_RECEIVE
	aResult := GFEI096REC(cXml,cTypeMsg)
    
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
{Protheus.doc} GFEI096ENV

//TODO Descrição : Funcao para tratar o xml de envio
@author Estela Baratto
@since 06/09/2018
@version undefined
@param cXml, characters, descricao
@type function
=================================================================================
/*/
Static Function GFEI096ENV()

Local cXmlRet     	:= ""
Local lResult     	:= .T.
Local cInternalId 	:= ""
Local cEvent      	:= "upsert"
Local cGXE_CDEMIT 	:= GXE->GXE_CDEMIT
Local cGXE_CODLOT	:= GXE->GXE_CODLOT
Local cDTEMIS    	:= ""
Local cDTVENC 	    := ""
Local cDTFIN 	    := ""
Local cValTot       := ""

If GXE->GXE_SIT == '5'
	cEvent := "delete"
EndIf
    

// DATAS
cDTEMIS := Transform(DTOS(GFEA096DIP(GXE->GXE_PERIOD)),"@R 9999-99-99")
cDTVENC := Transform(DTOS(GFEA096DIP(GXE->GXE_PERIOD,1)),"@R 9999-99-99")
cDTFIN  := Transform(dToS(GXE->GXE_DTSIT),"@R 9999-99-99")

//Valor Total do Lote - Titulo Previsão
cValTot := cValToChar(GFEA096VL(GXE->GXE_FILIAL, GXE->GXE_CODLOT))


cInternalId := getIntlId()

cXMLRet := "<BusinessEvent>"
cXMLRet +=     "<Entity>" 	+ cEntityName + "</Entity>"
cXMLRet +=     "<Event>" 	+ cEvent 	  + "</Event>"
cXMLRet +=     "<Identification>"
cXMLRet +=          "<key name=" + Chr( 34 )+ "InternalId" 				+ Chr( 34 ) + ">" + cInternalId + "</key>"
cXMLRet +=     "</Identification>"
cXMLRet += "</BusinessEvent>"

cXMLRet += "<BusinessContent>"
	
cXMLRet += 		"<InternalId>"          + cInternalId                               + "</InternalId>"

cXMLRet += 	    "<CompanyId>"         	+ cEmpAnt                                   + "</CompanyId>"
cXMLRet +=      "<BranchId>"          	+ cFilAnt                                   + "</BranchId>"
cXMLRet +=      "<ListOfAccountPayableDocument>"
cXMLRet +=      		"<AccountPayableDocument>"
cXMLRet +=   					"<InternalId>"          + cInternalId                 + "</InternalId>"
//cXMLRet +=   					"<DocumentPrefix>"      + ""                          + "</DocumentPrefix>"
cXMLRet +=   					"<DocumentNumber>"     	+ cGXE_CODLOT                 + "</DocumentNumber>"
cXMLRet +=      				"<DocumentParcel>"      + "1"                         + "</DocumentParcel>"
cXMLRet +=               		"<IssueDate>"   	    + cDTEMIS                     + "</IssueDate>"
cXMLRet +=               		"<ReceiptDate>"   	    + cDTFIN                      + "</ReceiptDate>"
cXMLRet +=               		"<DueDate>"   	    	+ cDTVENC                     + "</DueDate>"
cXMLRet +=                  	"<RealDueDate>"     	+ cDTVENC                     + "</RealDueDate>"
cXMLRet +=      				"<VendorCode>"        	+ cGXE_CDEMIT                 + "</VendorCode>"
cXMLRet +=      				"<NetValue>"     	    + cValTot                     + "</NetValue>"
cXMLRet +=      				"<GrossValue>"   	    + cValTot                     + "</GrossValue>"
cXMLRet +=      				"<Origin>"          	+ "PROTHEUS_GFE"              + "</Origin>"

cXMLRet +=                  "<ApportionmentDistribution>"

dbSelectArea("GXF")
GXF->(dbSetOrder(1))
GXF->(dbSeek(GXE->GXE_FILIAL + GXE->GXE_CODLOT ))
While !GXF->(Eof()) .And. GXF->GXF_FILIAL == GXE->GXE_FILIAL .And. GXF->GXF_CODLOT == GXE->GXE_CODLOT
		
		//cString += "#GWK|"+GXF->GXF_CCUSTO+"|"+GXF->GXF_CONTA+"|"+GXF->GXF_UNINEG+"|"+STR(GXF->GXF_VALOR)
		
	              
	cXMLRet +=						    "<Apportionment>"	 	
	cXMLRet +=							   "<CostCenterInternalId>"       + GXF->GXF_UNINEG            + "</CostCenterInternalId>"
	cXMLRet +=							   "<AccountantAcountInternalId>" + GXF->GXF_CONTA             + "</AccountantAcountInternalId>"
	cXMLRet +=				               "<Value>"                      + cValToChar(GXF->GXF_VALOR) + "</Value>"
	cXMLRet +=				           "</Apportionment>"	
	    	
	GXF->(dbSkip())
EndDo		
		
cXMLRet +=				       "</ApportionmentDistribution>"
cXMLRet += 	  			"</AccountPayableDocument>"
cXMLRet += 	  	"</ListOfAccountPayableDocument>"
cXMLRet += "</BusinessContent> "

Return {lResult,cXmlRet}

/*/
=================================================================================
{Protheus.doc} GFEI096REC(cXml,cTypeMsg)

//TODO Descrição : Funcao para tratar o xml de recebimento
@author Hercilio Neto
@since 06/10/2017
@version undefined
@param cXml, characters, descricao
@type function
=================================================================================
/*/
Static Function GFEI096REC(cXml,cTypeMsg)

Local cXMLRet   := ""
Local lResult := .T.
Local oXml   	:= ""
Local cStatus
Local aErrsList	:= {}
Local aMessageError := {}
Local cMessageError := ""
Local cProcessed
Local aLotKey := {}
Local cLotKey := ""
Local nI := 0
Local cDelType 
Local nContMsg
Local cErrorXml := ""
Local cWarnXml := ""
Local cGXE_FILIAL := ""
Local cGXE_CODLOT := ""


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
    	    	
		cDelType := oXml:xPathGetNodeValue("/TOTVSMessage/MessageInformation/DeliveryType")
		cLotKey    := oXml:xPathGetNodeValue("/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalIdDocument/InternalIdDocument/Origin")  
				
		cStatus 	:= oXml:xPathGetNodeValue("/TOTVSMessage/ResponseMessage/ProcessingInformation/Status")
		cProcessed	:= oXml:xPathGetNodeValue("/TOTVSMessage/ResponseMessage/ProcessingInformation/ProcessedOn")
		
		aLotKey := StrToKArr(cLotKey, "|")
		cGXE_FILIAL := Alltrim(aLotKey[1])
		cGXE_CODLOT := Alltrim(aLotKey[2])
		
		
		GXE->(dbSetOrder(1))
		GXE->(dbSeek(PadR(cGXE_FILIAL, TamSX3("GXE_FILIAL")[1]) + PadR(cGXE_CODLOT, TamSX3("GXE_CODLOT")[1])))	
		
		If cStatus == "ok"
		
		    If GXE->GXE_SIT == "2"		//Atualiza Lote	    
	        	StartJob("GFEI96UPD",getenvserver(),.T.,cEmpAnt,cFilAnt, GXE->(RecNo()),"4","")	        	
	        ElseIf GXE->GXE_SIT == "5"	 //Estorna Lote	            
	        	StartJob("GFEI96UPD",getenvserver(),.T.,cEmpAnt,cFilAnt, GXE->(RecNo()),"1","")	     
	        EndIf       
		Else
		    oXML := XmlParser(cXml,"_",@cErrorXml, @cWarnXml)
			If oXML != NIL
				aMessageError := ListErrors(oXML)
	        EndIf
	        
	        For nI := 1 To Len(aMessageError)
	        	cMessageError += aMessageError[nI][1] + ". "
	        Next nI
	        
	        If GXE->GXE_SIT == "2"	           
	        	StartJob("GFEI96UPD",getenvserver(),.T.,cEmpAnt,cFilAnt, GXE->(RecNo()),"3",cMessageError)
	        ElseIf GXE->GXE_SIT == "5"		            
	        	StartJob("GFEI96UPD",getenvserver(),.T.,cEmpAnt,cFilAnt, GXE->(RecNo()),"4",cMessageError)
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

function GFEI96UPD(cCodEmp, cCodFil, nRecNo, cSitFin, cMotFin)
	
	PREPARE ENVIRONMENT EMPRESA cCodEmp FILIAL cCodFil TABLES  'GXE' MODULO 'GFE'
	
	dbSelectArea("GXE")
	GXE->(dbGoTo(nRecNo))
	RecLock("GXE", .F.)
		GXE->GXE_SIT  	:= cSitFin
		GXE->GXE_MOTIVO	:= cMotFin
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

cResult := GXE->GXE_FILIAL + "|" + GXE->GXE_CODLOT + "|" + "GFEI096"

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
