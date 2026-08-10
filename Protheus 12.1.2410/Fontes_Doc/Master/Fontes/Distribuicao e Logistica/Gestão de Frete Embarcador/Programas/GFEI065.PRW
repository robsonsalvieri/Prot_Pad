#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "TBICONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Funcao ³ GFEI065 º Autor ³ SQUAD ADM FRETES         º Data ³ 13/09/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Desc.    ³ Funcao de integracao com o adapter EAI para envio            º±±
±±º          ³ do XML de Documento de Frete.                                º±±
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
±±º Uso      ³ GFEA065                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 

Function GFEI065(cXml,nType,cTypeMsg)
	Local aResult           := {}
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
		aResult := GFEI065ENV()
    
//+---------------------------------------------------------------------
//| Mensagem - Recebimento
//+---------------------------------------------------------------------    
	ElseIf nType == TRANS_RECEIVE
		aResult := GFEI065REC(cXml,cTypeMsg)

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
{Protheus.doc} GFEI065ENV

//TODO Descrição : Funcao para tratar o xml de recebimento
@author SQUAD ADM FRETES
@since 17/08/2017
@version undefined
@param cXml, characters, descricao
@type function
=================================================================================
/*/
Static Function GFEI065ENV()

	Local cXmlRet     	:= ""
	Local lResult     	:= .T.
	Local cInternalId 	:= ""
	Local cEvent      	:= "upsert"
	Local cGW3_EMISDF 	:= Alltrim(GW3->GW3_EMISDF)
	Local cGW3_NRDF	 	:= Alltrim(GW3->GW3_NRDF)
	Local cGW3_DTEMIS 	:= Transform(dToS(GW3->GW3_DTEMIS),"@R 9999-99-99")
	Local cGW3_DTENT  	:= Transform(dToS(GW3->GW3_DTENT),"@R 9999-99-99")
	Local cGW3_TPDF	  	:= "COV" //frete venda, para frete compra será CON - ainda não usado
	Local cGW3_VLDF   	:= cValToChar(GW3->GW3_VLDF)
	Local cGW3_SERDF  	:= Alltrim(GW3->GW3_SERDF)
	Local cGW3_CFOP	  	:= RIGHT(Alltrim(GW3->GW3_CFOP), 3)    
	Local cTaxe			:= "ICM"	
	Local cTpTrib       := "C"
	Local cGW3_BASIMP	:= cValToChar(GW3->GW3_BASIMP)
	Local cGW3_PCIMP	:= cValToChar(GW3->GW3_PCIMP)
	Local cGW3_VLIMP	:= cValToChar(GW3->GW3_VLIMP)
	Local cGW3_PEDAG	:= cValToChar(GW3->GW3_PEDAG)
	Local cGW3_CTE	    := GW3->GW3_CTE
	Local cGW3_TPCTE    := GW3->GW3_TPCTE
	Local aGWA			:= {}
	Local nI			:= 0
	Local nPerc 		:= 0
	Local nPerc1 		:= 0
	Local nPerc2 		:= 0
	Local nPerTot		:= 0
	Local aCidades	    := {}

	GW4->(dbSetOrder(1))
	GW4->(dbSeek(xFilial("GW3")+GW3->GW3_EMISDF+GW3->GW3_CDESP+GW3->GW3_SERDF+GW3->GW3_NRDF+DTOS(GW3->GW3_DTEMIS)))

	If GW3->GW3_SITFIS == '5'
		cEvent := "delete"
	EndIf

	cInternalId := getIntlId()

	If GFXCP12131("GW3_MUNINI") .And. GFXCP12131("GW3_UFINI") .And. GFXCP12131("GW3_MUNFIM") .And. GFXCP12131("GW3_UFFIM") .And. ;
	   !(Empty(GW3->GW3_MUNINI) .And. Empty(GW3->GW3_UFINI) .And. Empty(GW3->GW3_MUNFIM) .And. Empty(GW3->GW3_UFFIM))   			   					   
						  
		aAdd(aCidades, {GW3->GW3_MUNINI, GW3->GW3_MUNFIM})
	Else			
		aCidades := (GFEWSCITY( GW3->GW3_FILIAL, GW3->GW3_EMISDF, GW3->GW3_CDESP, GW3->GW3_SERDF, GW3->GW3_NRDF, DTOS(GW3->GW3_DTEMIS), GW3->GW3_TPDF))
	EndIf

	cXMLRet := "<BusinessEvent>"
	cXMLRet +=     	"<Entity>" 	+ cEntityName 	+ "</Entity>"
	cXMLRet +=     	"<Event>" 		+ cEvent 			+ "</Event>"
	cXMLRet +=     	"<Identification>"
	cXMLRet +=			"<key name=" + Chr( 34 )+ "InternalId" + Chr( 34 ) + ">" + cInternalId + "</key>"
	cXMLRet +=     	"</Identification>"
	cXMLRet += "</BusinessEvent>"

	cXMLRet += "<BusinessContent>"
	
	cXMLRet += 		"<InternalId>"            + cInternalId     + "</InternalId>"
	cXMLRet +=      "<CompanyId>"         	  + cEmpAnt			+ "</CompanyId>"
	cXMLRet +=      "<BranchId>"          	  + cFilAnt			+ "</BranchId>"
	cXMLRet +=      "<InvoiceNumber>"     	  + cGW3_NRDF       + "</InvoiceNumber>"
	cXMLRet +=      "<InvoiceSerie>"      	  + cGW3_SERDF      + "</InvoiceSerie>"
	cXMLRet += 		"<InvoiceSubSerie>" 	  + "0" 			+ "</InvoiceSubSerie>"
	cXMLRet +=      "<TypeofDocument>"    	  + cGW3_TPDF     	+ "</TypeofDocument>"
	cXMLRet +=      "<VendorCode>"        	  + cGW3_EMISDF   	+ "</VendorCode>"
	cXMLRet +=      "<IssueDate>"   	  	  + cGW3_DTEMIS   	+ "</IssueDate>"
	cXMLRet +=      "<InputDate>"     	      + cGW3_DTENT    	+ "</InputDate>"
	cXMLRet +=      "<InvoiceAmount>"         + cGW3_VLDF    	+ "</InvoiceAmount>"
	cXMLRet +=      "<TaxOpCode>"      		  + cGW3_CFOP     	+ "</TaxOpCode>"
	cXMLRet +=      "<Purpose>"               + cGW3_TPCTE        + "</Purpose>"
	cXMLRet +=      "<ElectronicAccessKey>"   + cGW3_CTE        + "</ElectronicAccessKey>"
	
	If (GW3->GW3_PDGPIS == '2') .or. (GW3->GW3_ICMPDG == '2')
		cXMLRet +=	"<TollValue >" 		      + cGW3_PEDAG		+ "</TollValue>"	
	EndIf
	
	cXMLRet +=		"<OriginCity>"	
	cXMLRet +=			"<CityCode>" 	+ aCidades[1][1] + "</CityCode>"
	cXMLRet +=		"</OriginCity>"
	
	cXMLRet +=		"<DestinationCity>"	
	cXMLRet +=			"<CityCode>" 	+ aCidades[1][2] + "</CityCode>"
	cXMLRet +=		"</DestinationCity>"
	
	cXMLRet +=		"<ShippingAddress>"
	cXMLRet +=			"<City>"	
	cXMLRet +=				"<CityCode>" 	+ aCidades[1][2] + "</CityCode>"
	cXMLRet +=			"</City>"	
	cXMLRet +=		"</ShippingAddress>"
	
	
	cXMLRet +=			"<ListOfRelatedInvoices>"


	While !GW4->(EOF()) .And. ;
			GW3->(GW3->GW3_FILIAL+GW3->GW3_EMISDF+GW3->GW3_CDESP+GW3->GW3_SERDF+GW3->GW3_NRDF+DTOS(GW3->GW3_DTEMIS)) == ;
			GW4->(GW4->GW4_FILIAL+GW4->GW4_EMISDF+GW4->GW4_CDESP+GW4->GW4_SERDF+GW4->GW4_NRDF+DTOS(GW4->GW4_DTEMIS))

		GW1->( dbSetOrder(1) )
		GW1->( dbSeek(GW4->GW4_FILIAL + GW4->GW4_TPDC + GW4->GW4_EMISDC + GW4->GW4_SERDC + GW4->GW4_NRDC ))

		cXMLRet +=			"<RelatedInvoices>"
		cXMLRet += 			"<InvoiceNumber>"		+ GW4->GW4_NRDC   	+ "</InvoiceNumber>"
		cXMLRet += 			"<InvoiceSerie>"			+ GW4->GW4_SERDC  	+ "</InvoiceSerie>"
		cXMLRet += 			"<InvoiceDateIssue>" 	+ Transform(dToS(GW1->GW1_DTEMIS),"@R 9999-99-99") + "</InvoiceDateIssue>"
		cXMLRet +=      	"</RelatedInvoices>"

		GW4->(dbSkip())
	EndDo
	
	// Tipo de Tributação: "C" com crédito, "O" outros, "I" isento
	if GW3->GW3_TRBIMP = "2"
	   cTpTrib := "I"
	elseif GW3->GW3_TRBIMP = "6"
	   cTpTrib := "O"
	Endif

	cXMLRet += "</ListOfRelatedInvoices>"
	cXMLRet +=		"<ListOfItens>"
	cXMLRet += 		"<Item>"
	cXMLRet +=				"<ListOfTaxes>"
	cXMLRet +=					"<Taxes>"	
	cXMLRet +=						"<Taxe>" 				+ cTaxe				+ "</Taxe>"
	cXMLRet +=						"<CalculationBasis>" 	+ cGW3_BASIMP	 	+ "</CalculationBasis>"
	cXMLRet +=						"<Percentage>"      	+ cGW3_PCIMP	 	+ "</Percentage>"	
	cXMLRet +=						"<Value>" 				+ cGW3_VLIMP		+ "</Value>"
	cXMLRet +=						"<IncidenceType>" 		+ cTpTrib    		+ "</IncidenceType>"
	cXMLRet +=					"</Taxes>"	
	cXMLRet +=					"</ListOfTaxes>"	
	cXMLRet += 			"<ListOfApportionInvoiceItem>"	
	GWA->(dbSetOrder(1))//GWA_FILIAL+GWA_TPDOC+GWA_CDESP+GWA_CDEMIT+GWA_SERIE+GWA_NRDOC+DTOS(GWA_DTEMIS)
	GWA->(dbSeek(GW3->GW3_FILIAL + "2" + GW3->GW3_CDESP + GW3->GW3_EMISDF + GW3->GW3_SERDF + GW3->GW3_NRDF + DtoS(GW3->GW3_DTEMIS)))
		
		While GWA->(!Eof()) .AND. (GW3->GW3_FILIAL + GW3->GW3_CDESP + GW3->GW3_EMISDF + GW3->GW3_SERDF + GW3->GW3_NRDF) == (GWA->GWA_FILIAL + GWA->GWA_CDESP +GWA->GWA_CDEMIT + GWA->GWA_SERIE + GWA->GWA_NRDOC)
			nPerc 	:= Round(((GWA->GWA_VLMOV/GW3->GW3_VLDF) * 100),2)

			aAdd(aGWA,{GWA->GWA_CTADEB, GWA->GWA_UNINEG,  nPerc})
			
			GWA->(dbSkip())
		EndDo
		For nI := 1 To Len(aGWA)
			
			cUNINEG 		:= aGWA[nI][2]
			nPerc1		:= aGWA[nI][3] 
			
			If nI == Len(aGWA)
				nPerc2 	:= 100 - nPerTot
			Else 
				nPerc2 	:= nPerc1
			EndIf	
			nPerTot		+= nPerc1 
					
			cXMLRet += 			"<ApportionInvoiceItem>" 				   
			cXMLRet += 				"<AccountantAcountInternalId>"	+ aGWA[nI][1]					+ "</AccountantAcountInternalId>"			
			cXMLRet += 				"<ProjectInternalId>"    			+ SUBSTR(cUNINEG,1,2)  	+ "</ProjectInternalId>"
			cXMLRet += 				"<SubProjectInternalId>"				+ SUBSTR(cUNINEG,3,2)  	+ "</SubProjectInternalId>"
			cXMLRet += 				"<MarketSegmentCode>"     			+ SUBSTR(cUNINEG,5,2)  	+ "</MarketSegmentCode>"
			cXMLRet += 				"<ClassValueCode>"    				+ SUBSTR(cUNINEG,7,2)  	+ "</ClassValueCode>"		
			cXMLRet += 				"<Percentual>"    						+ cValToChar(nPerc2)	  	+ "</Percentual>"														
			cXMLRet += 			"</ApportionInvoiceItem>" 		
		Next nI
		cXMLRet += 			"</ListOfApportionInvoiceItem>" 		
		cXMLRet += 		"</Item>"
		cXMLRet +=		"</ListOfItens>"
		cXMLRet += "</BusinessContent> "



Return {lResult,cXmlRet}

/*
=================================================================================
{Protheus.doc} GFEI065REC(cXml,cTypeMsg)

//TODO Descrição : Funcao para tratar o xml de recebimento
@author Marcelo Silva
@since 09/10/2017
@version undefined
@param cXml, characters, descricao
@type function
=================================================================================
*/

Static Function GFEI065REC(cXml,cTypeMsg)

	Local cXmlRet        := ""		
Local lResult        := .T.
Local oXml   	       := ""
Local cStatus	
Local aErrsList      := {}
Local aMessageError  := {}
Local cMessageError  := ""
Local cProcessed
Local aDocKey 		:= {}
	Local cDocKey        := ""
Local nI 				:= 0
Local cResult
Local cFili			:= ""
Local cCDESP			:= ""
Local cEMISDF			:= ""
Local cSERDF			:= ""
Local cNRDF	  		:= ""
Local cDTEMIS
Local cErrorXml      := ""
Local cWarnXml       := ""
	
//+--------------------------------------------------------------+
//| Trata a mensagem de Negocio/BusinessMessage					  |
//+--------------------------------------------------------------+

//If cTypeMsg == EAI_MESSAGE_BUSINESS
If cTypeMsg == EAI_MESSAGE_RESPONSE
	
	oXml := TXmlManager():new()
    If !oXml:Parse(cXml)
        lResult:= .F.
        Aadd(aErrsList, {"", 1, ""}) // Description | nType: 1-ERROR;2-WARNING | cCode : Generic Code
        cXmlRet := FWEAILOfMessages(aErrsList)
        Return {lResult,cXmlRet}
    EndIf
    
    cDelType   := oXml:xPathGetNodeValue("/TOTVSMessage/MessageInformation/DeliveryType")
    
		cDocKey    := oXml:xPathGetNodeValue("/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalId/InternalId/Origin")  
				
    cStatus 	 := oXml:xPathGetNodeValue("/TOTVSMessage/ResponseMessage/ProcessingInformation/Status")
    cProcessed := oXml:xPathGetNodeValue("/TOTVSMessage/ResponseMessage/ProcessingInformation/ProcessedOn")
	
		aDocKey := StrToKArr(cDocKey, "|")
	cFili	:= Alltrim(aDocKey[1])
    cCDESP	:= Alltrim(aDocKey[2])
    cEMISDF	:= Alltrim(aDocKey[3])
    cSERDF	:= Alltrim(aDocKey[4])
    cNRDF	:= Alltrim(aDocKey[5])
    cDTEMIS := Alltrim(aDocKey[6])

		GW3->(dbSetOrder(1))
		GW3->(dbSeek(PadR(cFili, TamSX3("GW3_FILIAL")[1]) + PadR(cCDESP, TamSX3("GW3_CDESP")[1]) + PadR(cEMISDF, TamSX3("GW3_EMISDF")[1]) + PadR(cSERDF, TamSX3("GW3_SERDF")[1]) + PadR(cNRDF, TamSX3("GW3_NRDF")[1]) + cDTEMIS))	
		
		If cStatus == "ok"
			If GW3->GW3_SITFIS  	== "2"
				StartJob("GFEI65UPD",getenvserver(),.T.,cEmpAnt,cFilAnt, GW3->(RecNo()),"4","")
			ElseIf GW3->GW3_SITFIS  	== "5"
				StartJob("GFEI65UPD",getenvserver(),.T.,cEmpAnt,cFilAnt, GW3->(RecNo()),"1","")
			EndIf
		Else
			oXML := XmlParser(cXml,"_",@cErrorXml, @cWarnXml)
			If oXML != NIL
				aMessageError := ListErrors(oXML)
			EndIf

			For nI := 1 To Len(aMessageError)
				cMessageError += aMessageError[nI][1] + ". "
			Next nI	  

			If GW3->GW3_SITFIS == "2"
				StartJob("GFEI65UPD",getenvserver(),.T.,cEmpAnt,cFilAnt, GW3->(RecNo()),"3",cMessageError)
			ElseIf GW3->GW3_SITFIS == "5"
				StartJob("GFEI65UPD",getenvserver(),.T.,cEmpAnt,cFilAnt, GW3->(RecNo()),"4",cMessageError)
			EndIf
		EndIf							

//+--------------------------------------------------------------
//| Mensagem: responde com a Versão
//+--------------------------------------------------------------
ElseIf cTypeMsg == EAI_MESSAGE_WHOIS
   		cXmlRet := "1.000|3.011"				

//+--------------------------------------------------------------
//| Trata a mensagem de Negocio/BusinessMessage
//+--------------------------------------------------------------
ElseIf cTypeMsg == EAI_MESSAGE_RECEIPT

EndIf

Return {lResult,cXmlRet}

function GFEI65UPD(cCodEmp, cCodFil, nRecNo, cSitFis, cMotFis)
	
	PREPARE ENVIRONMENT EMPRESA cCodEmp FILIAL cCodFil TABLES  'GW3' MODULO 'GFE'
	
	//Conout('GFEI65UPD: cSitFis:|' + cSitFis + '| cMotFis:|' + cMotFis+ '|')

	dbSelectArea("GW3")
	GW3->(dbGoTo(nRecNo))
	RecLock("GW3", .F.)
		GW3->GW3_SITFIS  	:= cSitFis
		GW3->GW3_MOTFIS  	:= cMotFis	
	MsUnlock()

Return .T.
/*/{Protheus.doc} getIntlId
//TODO Recupera a identificação interna da mensagem trafegada.
@author SQUAD ADM FRETES - SIGAGFE
@since 17/08/2017
@version 1.001

@type function
/*/
Static Function getIntlId()
	Local cResult := ""

	cResult := GW3->GW3_FILIAL + "|" + GW3->GW3_CDESP + "|" + GW3->GW3_EMISDF + "|" + GW3->GW3_SERDF + "|" +  GW3->GW3_NRDF + "|" + DTOS(GW3->GW3_DTEMIS) + "|" + "GFEI065"

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
