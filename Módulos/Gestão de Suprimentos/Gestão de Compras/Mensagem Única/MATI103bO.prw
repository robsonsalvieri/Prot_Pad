#Include "Protheus.ch"
#Include "fwAdapterEAI.ch"
#Include "MATI103b.ch"

/*/{Protheus.doc} MATI103b
Funcao de integracao com o adapter EAI para envio e recebimento da
nota fiscal de entrada (SF1/SD1/SDE/AFN) utilizando o conceito de
mensagem unica (Invoice).
@type function
@version 12
@author SIGAEST / SIGAAGD 
@since 16/04/2025
@param oEAIObEt, object, JsonObject do EAI com Dados de Entrada
@param cTypeTrans, character, Tipo Transação da Mensagem EAI
@param cTypeMsg, character, Tipo Mensagem EAI
@param cVersion, character, Versão da Mensagem
@return array,  Contendo o resultado da execucao e a mensagem json de retorno.
aRetEAI[1] - (boolean) Indica o resultado da execução da função
aRetEAI[2] - (caracter) Mensagem JSON para envio
aRetEAI[3] - (caracter) Nome da mensagem
/*/
Function MATI103bo(oEAIObEt, cTypeTrans, cTypeMsg, cVersion)

Local ofwEAIObj := FWEAIobj():NEW()
Local lRet      := .T.
Local aRetEAI   := {}
Local cEntity   := "Invoice"
Local nI        := 0
Local cValInt   := ""
Local cValExt   := ""
Local cProduct  := ""

Local lDePara   := .F.
Local cAlias    := "SF1"
Local cField    := "F1_DOC"
Local cDePara   := ""
Local aDePara   := {}
Local nCont     := 0

Private oXML    := Nil

AdpLogEAI(1, "MATI103b", cTypeTrans, cTypeMsg, oEAIObEt)

// Mensagem de Entrada
If cTypeTrans == TRANS_RECEIVE
	If cTypeMsg == EAI_MESSAGE_BUSINESS
		lRet := .F.
		ofwEAIObj := "Recebimento não implementado!" 
		aRetEAI := {lRet, ofwEAIObj, cEntity}

	ElseIf cTypeMsg == EAI_MESSAGE_RESPONSE

		// Se não houve erros na resposta
		If Upper(oEAIObEt:getPropValue("ProcessingInformation"):getPropValue("Status")) == "OK" 
		
			If oEAIObEt:getHeaderValue("ProductName") !=  nil .And. !Empty( oEAIObEt:getHeaderValue("ProductName") ) ///verificar se é o mesmo no mata410
				cProduct := oEAIObEt:getHeaderValue("ProductName")
			Else
				lRet := .F.
				ofwEAIObj:Activate()
				ofwEAIObj:setProp("ReturnContent")
				ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", STR0002) //"Erro no retorno. O Product é obrigatório!"
				AdpLogEAI(5, "MATI103b", ofwEAIObj, lRet)
				aRetEAI := {lRet, ofwEAIObj, cEntity}
				Return aRetEAI																						
			EndIf
			
			oObLisOfIt := oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")

			if Len( oObLisOfIt ) > 0 

				For nI := 1 To Len( oObLisOfIt )
					If oObLisOfIt[nI]:getPropValue('Origin') != nil .And. !Empty( oObLisOfIt[nI]:getPropValue('Origin') )
						cDePara := oObLisOfIt[nI]:getPropValue('Name')  
						cValInt := oObLisOfIt[nI]:getPropValue('Origin')  
						
						If oObLisOfIt[nI]:getPropValue('Destination') != nil .And. !Empty( oObLisOfIt[nI]:getPropValue('Destination') )
							cValExt := oObLisOfIt[nI]:getPropValue('Destination')  
						else
							cValExt := ""
						EndIf	

						// Não armazena Capa e Rateio
						If cDePara == 'INVOICEITEM'
							aAdd(aDePara, Array(4))
							nCont++
							aDePara[nCont][1] := cValInt
							aDePara[nCont][2] := cValExt
							aDePara[nCont][3] := "SD1"
							aDePara[nCont][4] := "D1_ITEM"

						ElseIf cDePara == 'APPORTIONINVOICEITEM'
							aAdd(aDePara, Array(4))
							nCont++
							aDePara[nCont][1] := cValInt
							aDePara[nCont][2] := cValExt
							aDePara[nCont][3] := "SDE"
							aDePara[nCont][4] := "DE_CC"

						ElseIf cDePara == 'ACCOUNTRECEIVABLEDOCUMENT'
							aAdd(aDePara, Array(4))
							nCont++
							aDePara[nCont][1] := cValInt
							aDePara[nCont][2] := cValExt
							aDePara[nCont][3] := "SE1"
							aDePara[nCont][4] := "E1_NUM"

						ElseIf cDePara == 'ACCOUNTPAYABLEDOCUMENT'
							aAdd(aDePara, Array(4))
							nCont++
							aDePara[nCont][1] := cValInt
							aDePara[nCont][2] := cValExt
							aDePara[nCont][3] := "SE2"
							aDePara[nCont][4] := "E2_NUM"

						ElseIf cDePara == 'INVOICE'
							aAdd(aDePara, Array(4))
							nCont++
							aDePara[nCont][1] := cValInt
							aDePara[nCont][2] := cValExt
							aDePara[nCont][3] := "SF1"
							aDePara[nCont][4] := "F1_DOC"

							lDePara := .T.
							AdpLogEAI(3, "cValInt: ", cValInt)
							AdpLogEAI(3, "cValExt: ", cValExt)
						EndIf
					Else
						lRet    := .F.
						ofwEAIObj:Activate()
						ofwEAIObj:setProp("ReturnContent")
						ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", STR0004)  //"Erro no retorno. O OriginalInternalId do Item é obrigatório!"
						AdpLogEAI(5, "MATI103b", ofwEAIObj, lRet)
						aRetEAI := {lRet, ofwEAIObj, cEntity}
						Return aRetEAI
					EndIf							
					
				Next nI
				
				If !lDePara
					lRet    := .F.
					ofwEAIObj:Activate()
					ofwEAIObj:setProp("ReturnContent")
					ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", STR0005) //"Erro no retorno. O DestinationInternalId é obrigatório!"
					AdpLogEAI(5, "MATI103b", ofwEAIObj, lRet)
					aRetEAI := {lRet, ofwEAIObj, cEntity}
					Return aRetEAI
				Endif

				If Upper(AllTrim(oEAIObEt:getPropValue("ReceivedMessage"):getPropValue("Event"))) == "UPSERT"
					For nI := 1 To Len(aDePara)
						cValInt := aDePara[nI][1]
						cValExt := aDePara[nI][2]
						cAlias  := aDePara[nI][3]
						cField  := aDePara[nI][4]
						CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt)
					Next nI
				Else
					lRet := .F.
					ofwEAIObj:Activate()
					ofwEAIObj:setProp("ReturnContent")
					ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", STR0006) //"Evento do retorno inválido!"	 
					aRetEAI := {lRet, ofwEAIObj, cEntity}
				EndIf
			else
				lRet := .F.
				ofwEAIObj:Activate()
				ofwEAIObj:setProp("ReturnContent")
				ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", STR0006) //"Evento do retorno inválido!"	 
				aRetEAI := {lRet, ofwEAIObj, cEntity}
			Endif	
			
		Else

			cLogErro := ""
			If oEAIObEt:getpropvalue('ProcessingInformation') != nil
				oMsgError := oEAIObEt:getpropvalue('ProcessingInformation'):getpropvalue("ListOfMessages")
				For nI := 1 To Len( oMsgError )
					cLogErro += oMsgError[nI]:getpropvalue('Message') + Chr(10)
				Next nI
			Endif
	
			lRet := .F.
			ofwEAIObj:Activate()
			ofwEAIObj:setProp("ReturnContent")
			ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)		

			aRetEAI := {lRet, ofwEAIObj, cEntity}
		EndIf

	ElseIf cTypeMsg == EAI_MESSAGE_WHOIS
		ofwEAIObj := "4.000|4.001"
		aRetEAI := {lRet, ofwEAIObj, cEntity}
	Endif
ElseIf cTypeTrans == TRANS_SEND

	If cVersion = "4."
		aRetEAI := v4000(oEAIObEt, cTypeTrans, cTypeMsg, cVersion)
		ofwEAIObj := aRetEAI[2] //devolve o objeto json de retorno para ser usado no log
	Else
		lRet := .F.
		ofwEAIObj := STR0008   // "Versão da Nota Fiscal não suportada."
		//Retorno
		aRetEAI := {lRet, ofwEAIObj, cEntity}
	EndIf
EndIf

AdpLogEAI(5, "MATI103b", ofwEAIObj, lRet) 
Return aRetEAI

/*/{Protheus.doc} v4000
Implementação do adapter EAI, versão 4.x
@type function
@version 12
@author jean.schulze
@since 16/04/2025
@param oEAIObEt, object, JsonObject do EAI com Dados de Entrada
@param cTypeTrans, character, Tipo Transação da Mensagem EAI
@param cTypeMsg, character, Tipo Mensagem EAI
@param cVersion, character, Versão da Mensagem
@return array,  Contendo o resultado da execucao e a mensagem json de retorno.
/*/
Static Function v4000(oEAIObEt, cTypeTrans, cTypeMsg, cVersion)

Local ofwEAIObj	:= FWEAIobj():NEW()
Local lRet      := .T.
Local cEntity   := "Invoice"
Local cEvent    := "upsert"
Local cIntId    := ""
Local aArea     := {}
Local aRestSD1  := {}
Local aRestAFN  := {}
Local aRestSDE  := {}
Local aRestCTO  := {}
Local aRestTit  := {}
Local aRateio   := {}
Local nCont     := 0
Local cRegSf1   := ""
Local cIntSd1   := ""
Local cMoedaDoc := ""
Local cMoedaInt := ""
Local cDuplic   := ""
Local cIntTitulo := ""


// Verifica a operação realizada
Do Case
	Case Inclui
		AdpLogEAI(4, 3)
	Case Altera
		AdpLogEAI(4, 4)
	OtherWise
		AdpLogEAI(4, 5)
EndCase

aArea    := GetArea()
aRestSD1 := SD1->(GetArea())
aRestAFN := AFN->(GetArea())
aRestSDE := SDE->(GetArea())
aRestCTO := CTO->(GetArea())

cIntId := IntInvExt(/*cEmpresa*/, SF1->F1_FILIAL, SF1->F1_DOC, SF1->F1_SERIE, SF1->F1_FORNECE, SF1->F1_LOJA)[2]

If !Inclui .And. !Altera
	cEvent := 'delete' // Exclusão
	CFGA070Mnt( , "SF1", "F1_DOC",, cIntId, .T. ) //Exclui o de/para da nota
EndIf

cMoedaDoc := cValToChar(SF1->F1_MOEDA)
CTO->(dbSetOrder(1))  // CTO_FILIAL, CTO_MOEDA.
If !CTO->(MsSeek(xFilial("CTO")+cMoedaDoc))
	If CTO->(MsSeek(xFilial("CTO")+ StrZero(SF1->F1_MOEDA,TamSX3("CTO_MOEDA")[1]) ))
		cMoedaDoc := StrZero(SF1->F1_MOEDA,TamSX3("CTO_MOEDA")[1])
	EndIf
EndIf
cMoedaInt := IntMoeExt(,,cMoedaDoc)[2]

/*Escrita do objeto json*/
ofwEAIObj:Activate()

/*BusinessEvent*/
ofwEAIObj:setEvent(cEvent)
ofwEAIObj:setHeader("Entity",cEntity)

/*BusinessContent*/		
ofwEAIObj:setprop("CompanyId",cEmpAnt)		
ofwEAIObj:setprop("BranchId", xFilial("SF1"))
ofwEAIObj:setprop("CompanyInternalId", cEmpAnt + '|' + xFilial("SF1"))
ofwEAIObj:setprop("InternalId", cIntId)
ofwEAIObj:setprop("InvoiceNumber", RTrim(SF1->F1_DOC))
ofwEAIObj:setprop("InvoiceSerie", RTrim(SF1->F1_SERIE))
ofwEAIObj:setprop("InvoiceSubSerie","")
ofwEAIObj:setprop("InvoiceModel","")
ofwEAIObj:setprop("InvoiceSituation", IIf(SF1->F1_STATUS $ "BC", "2", "1"))
ofwEAIObj:setprop("TypeOfDocument", TipDocExt(SF1->F1_TIPO))
ofwEAIObj:setprop("VendorCode", RTrim(SF1->F1_FORNECE))
If SF1->F1_TIPO $ "DB"
	ofwEAIObj:setprop("CustomerInternalId", IntCliExt(,, SF1->F1_FORNECE, SF1->F1_LOJA)[2])
Else
	ofwEAIObj:setprop("VendorInternalId", IntForExt(,, SF1->F1_FORNECE, SF1->F1_LOJA)[2])
Endif
ofwEAIObj:setprop("IssueDate",INTDTANO(SF1->F1_EMISSAO) )
ofwEAIObj:setprop("InputDate",INTDTANO(SF1->F1_DTDIGIT))
ofwEAIObj:setprop("InvoiceAmount",cValToChar(SF1->F1_VALBRUT))
ofwEAIObj:setprop("ValueofGoods",cValToChar(SF1->F1_VALMERC))
ofwEAIObj:setprop("FreightAmount",cValToChar(SF1->F1_FRETE))
ofwEAIObj:setprop("InsuranceAmount", cValToChar(SF1->F1_SEGURO))
ofwEAIObj:setprop("DiscountAmount", cValToChar(SF1->F1_DESCONT))
ofwEAIObj:setprop("ExpenseAmount", cValToChar(SF1->F1_DESPESA))
ofwEAIObj:setprop("CurrencyRate", cValToChar(SF1->F1_TXMOEDA) )
ofwEAIObj:setprop("CurrencyInternalId", cMoedaInt)
ofwEAIObj:setprop("PaymentConditionCode", RTrim(SF1->F1_COND))
ofwEAIObj:setprop("PaymentConditionInternalId", IntConExt(/*cEmpresa*/, /*cFilial*/, SF1->F1_COND)[2] )


// Lista de títulos financeiros.
If val(cVersion) >= 4.001

	// Títulos a receber.
	aRestTit := SE1->(GetArea())
	cDuplic  := SF1->(xFilial("SE1") + F1_PREFIXO + F1_DUPL)
	SE1->(dbSetOrder(1))  // E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO.
	SE1->(dbSeek(cDuplic, .F.))
	Do While SE1->(!eof() .and. E1_FILIAL + E1_PREFIXO + E1_NUM == cDuplic)
		cIntTitulo := SE1->( IntTRcExt(, E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO)[2] )

		//Se for delete, exclui o de/para do título a receber
		If cEvent == 'delete'
			CFGA070Mnt( , "SE1", "E1_NUM",, cIntTitulo, .T. )
		EndIf

		oFinDocEAI := ofwEAIObj:setprop("ListOfFinancialDocument", {}, 'FinancialDocument', , .T. )
		oFinDocEAI[Len(oFinDocEAI)]:setprop("FinancialAccount",   'Receivable' ,,.T.)
		oFinDocEAI[Len(oFinDocEAI)]:setprop("DocumentPrefix",  RTrim(SE1->E1_PREFIXO)   ,,.T.)
		oFinDocEAI[Len(oFinDocEAI)]:setprop("DocumentNumber",  RTrim(SE1->E1_NUM)  ,,.T.)
		oFinDocEAI[Len(oFinDocEAI)]:setprop("DocumentParcel",  RTrim(SE1->E1_PARCELA)   ,,.T.)
		oFinDocEAI[Len(oFinDocEAI)]:setprop("DocumentTypeCode",RTrim(SE1->E1_TIPO)    ,,.T.)
		oFinDocEAI[Len(oFinDocEAI)]:setprop("CustomerVendorInternalId",IntCliExt(,, SE1->E1_CLIENTE, SE1->E1_LOJA)[2]    ,,.T.)
		oFinDocEAI[Len(oFinDocEAI)]:setprop("FinancialDocumentInternalId", cIntTitulo   ,,.T.)
		oFinDocEAI[Len(oFinDocEAI)]:setprop("DueDate", INTDTANO(SE1->E1_VENCTO)   ,,.T.)
		oFinDocEAI[Len(oFinDocEAI)]:setprop("RealDueDate",INTDTANO(SE1->E1_VENCREA)    ,,.T.)
		oFinDocEAI[Len(oFinDocEAI)]:setprop("Value", cValToChar(SE1->E1_VALOR)    ,,.T.)
		oFinDocEAI[Len(oFinDocEAI)]:setprop("CurrencyCode", PadL(SE1->E1_MOEDA, 2, '0')    ,,.T.)
		oFinDocEAI[Len(oFinDocEAI)]:setprop("CurrencyInternalId", IntMoeExt(,, PadL(SE1->E1_MOEDA, 2, '0'), PmsMsgUVer('CURRENCY','CTBA140'))[2]   ,,.T.)

		If Empty(SE1->E1_NATUREZ)
			oFinDocEAI[Len(oFinDocEAI)]:setprop("FinancialNatureInternalId",  ""  ,,.T.)
		Else
			oFinDocEAI[Len(oFinDocEAI)]:setprop("FinancialNatureInternalId", F10MontInt(, SE1->E1_NATUREZ)    ,,.T.)
		EndIf

		SE1->(dbSkip())
	EndDo
	RestArea(aRestTit)

	// Títulos a pagar.
	aRestTit := SE2->(GetArea())
	cDuplic  := SF1->(xFilial("SE2") + F1_PREFIXO + F1_DUPL)
	SE2->(dbSetOrder(1))  // E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA.
	SE2->(dbSeek(cDuplic, .F.))
	Do While SE2->(!eof() .and. E2_FILIAL + E2_PREFIXO + E2_NUM == cDuplic)
		cIntTitulo := SE2->( IntTPgExt(, E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA)[2] )

		//Se for delete, exclui o de/para do título a pagar
		If cEvent == 'delete'
			CFGA070Mnt( , "SE2", "E2_NUM",, cIntTitulo, .T. )
		EndIf

		oFinDocEAI := ofwEAIObj:setprop("ListOfFinancialDocument", {}, 'FinancialDocument', , .T. )
		oFinDocEAI[Len(oFinDocEAI)]:setprop("FinancialAccount",   'Payable' ,,.T.)
		oFinDocEAI[Len(oFinDocEAI)]:setprop("DocumentPrefix", RTrim(SE2->E2_PREFIXO) ,,.T.)
		oFinDocEAI[Len(oFinDocEAI)]:setprop("DocumentNumber", RTrim(SE2->E2_NUM)  ,,.T.)
		oFinDocEAI[Len(oFinDocEAI)]:setprop("DocumentParcel", RTrim(SE2->E2_PARCELA)  ,,.T.)
		oFinDocEAI[Len(oFinDocEAI)]:setprop("DocumentTypeCode", RTrim(SE2->E2_TIPO)  ,,.T.)
		oFinDocEAI[Len(oFinDocEAI)]:setprop("CustomerVendorInternalId", IntForExt(,, SE2->E2_FORNECE, SE2->E2_LOJA)[2]  ,,.T.)
		oFinDocEAI[Len(oFinDocEAI)]:setprop("FinancialDocumentInternalId", cIntTitulo ,,.T.)
		oFinDocEAI[Len(oFinDocEAI)]:setprop("DueDate", INTDTANO(SE2->E2_VENCTO)  ,,.T.)
		oFinDocEAI[Len(oFinDocEAI)]:setprop("RealDueDate", INTDTANO(SE2->E2_VENCREA)  ,,.T.)
		oFinDocEAI[Len(oFinDocEAI)]:setprop("Value", cValToChar(SE2->E2_VALOR)  ,,.T.)
		oFinDocEAI[Len(oFinDocEAI)]:setprop("CurrencyCode", PadL(SE2->E2_MOEDA, 2, '0')  ,,.T.)
		oFinDocEAI[Len(oFinDocEAI)]:setprop("CurrencyInternalId", IntMoeExt(,, PadL(SE2->E2_MOEDA, 2, '0'), PmsMsgUVer('CURRENCY','CTBA140'))[2]  ,,.T.)

		If Empty(SE2->E2_NATUREZ)
			oFinDocEAI[Len(oFinDocEAI)]:setprop("FinancialNatureInternalId", '' ,,.T.)
		Else
			oFinDocEAI[Len(oFinDocEAI)]:setprop("FinancialNatureInternalId", F10MontInt(, SE2->E2_NATUREZ) ,,.T.)
		EndIf

		SE2->(dbSkip())
	EndDo
	RestArea(aRestTit)

Endif

// Lista os itens da nota.
cRegSf1 := xFilial("SD1") + SF1->(F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA)
If Inclui .Or. Altera
	SD1->(dbSetOrder(1))  // D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM.
	If SD1->(dbSeek(cRegSf1, .F.))
		While SD1->(!Eof() .and. D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA == cRegSf1)
			cIntSd1 := IntInvExt(cEmpAnt, SD1->D1_FILIAL, SD1->D1_DOC, SD1->D1_SERIE, SD1->D1_FORNECE, SD1->D1_LOJA, SD1->D1_COD, SD1->D1_ITEM)[2]
			
			oItemEAI := ofwEAIObj:setprop("ListOfItems", {}, 'Item', , .T. )
			oItemEAI[Len(oItemEAI)]:setprop("InternalId",   cIntSd1 ,,.T.)
			oItemEAI[Len(oItemEAI)]:setprop("InvoiceSequence", SD1->D1_ITEM    ,,.T.)
			oItemEAI[Len(oItemEAI)]:setprop("OrderNumber",      SD1->D1_PEDIDO      ,,.T.)
			oItemEAI[Len(oItemEAI)]:setprop("OrderInternalId",  IntPdCExt(,,SD1->D1_PEDIDO,,)[2]    ,,.T.)
			oItemEAI[Len(oItemEAI)]:setprop("OrdemItem",  SD1->D1_ITEMPC   ,,.T.)
			oItemEAI[Len(oItemEAI)]:setprop("OrderItemInternalId",  IntPdCExt(,,SD1->D1_PEDIDO,SD1->D1_ITEMPC,)[2]     ,,.T.)
			A103REQIT(SD1->D1_PEDIDO,SD1->D1_ITEMPC, oItemEAI[Len(oItemEAI)])
			oItemEAI[Len(oItemEAI)]:setprop("ItemCode", RTrim(SD1->D1_COD)    ,,.T.)
			oItemEAI[Len(oItemEAI)]:setprop("ItemInternalId",  RTrim(IntProExt(/*cEmpresa*/, /*cFilial*/, SD1->D1_COD)[2])   ,,.T.)
			oItemEAI[Len(oItemEAI)]:setprop("Quantity", cValToChar(SD1->D1_QUANT)     ,,.T.)
			oItemEAI[Len(oItemEAI)]:setprop("UnitofMeasureCode",  RTrim(SD1->D1_UM)     ,,.T.)
			oItemEAI[Len(oItemEAI)]:setprop("UnitofMeasureInternalId", RTrim(IntUndExt(/*cEmpresa*/, /*cFilial*/, SD1->D1_UM)[2])    ,,.T.)
			oItemEAI[Len(oItemEAI)]:setprop("UnityPrice", cValToChar(SD1->D1_VUNIT)      ,,.T.)
			oItemEAI[Len(oItemEAI)]:setprop("GrossValue", cValToChar(SD1->D1_QUANT * SD1->D1_VUNIT)    ,,.T.)
			oItemEAI[Len(oItemEAI)]:setprop("FreightValue", cValToChar(SD1->D1_VALFRE)    ,,.T.)
			oItemEAI[Len(oItemEAI)]:setprop("InsuranceValue", cValToChar(SD1->D1_SEGURO)     ,,.T.)
			oItemEAI[Len(oItemEAI)]:setprop("DiscountValue", cValToChar(SD1->D1_VALDESC)     ,,.T.)
			oItemEAI[Len(oItemEAI)]:setprop("ExpenseValue", cValToChar(SD1->D1_DESPESA)    ,,.T.)
			oItemEAI[Len(oItemEAI)]:setprop("NetValue",  cValToChar(SD1->D1_TOTAL)     ,,.T.)
			oItemEAI[Len(oItemEAI)]:setprop("AreAndLineOfBusinessCode",  ''   ,,.T.)
			oItemEAI[Len(oItemEAI)]:setprop("WarehouseCode", RTrim(SD1->D1_LOCAL)     ,,.T.)
			oItemEAI[Len(oItemEAI)]:setprop("WarehouseInternalId", RTrim(IntLocExt(/*cEmpresa*/, /*cFilial*/, SD1->D1_LOCAL)[2])      ,,.T.)
			oItemEAI[Len(oItemEAI)]:setprop("LotNumber",  RTrim(SD1->D1_LOTECTL)    ,,.T.)
			oItemEAI[Len(oItemEAI)]:setprop("SubLotNumber", RTrim(SD1->D1_NUMLOTE)     ,,.T.)
			
			// Pega os impostos do item.
			GetTaxes(cVersion, oItemEAI[Len(oItemEAI)])

			//Bloco de XML do Rateio
			aRateio := RatNFE(SD1->D1_FILIAL + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA + SD1->D1_ITEM)
		
			For nCont := 1 To Len(aRateio)
				
				oRatItEAI := oItemEAI[Len(oItemEAI)]:setprop("ListOfApportionInvoiceItem", {}, 'ApportionInvoiceItem', , .T. )
				oRatItEAI[Len(oRatItEAI)]:setprop("InternalId",  cIntSd1 + '|' + cValToChar(nCont)   ,,.T.)
				oRatItEAI[Len(oRatItEAI)]:setprop("CostCenterInternalId",  IIf(!Empty(aRateio[nCont][1]), IntCusExt(/*cEmpresa*/, /*cFilial*/, aRateio[nCont][1])[2] , '')    ,,.T.)
				oRatItEAI[Len(oRatItEAI)]:setprop("AccountantAcountInternalId",  IIf(!Empty(aRateio[nCont][2]), aRateio[nCont][2] , '')    ,,.T.)
				//Se não for informado Projeto
				oRatItEAI[Len(oRatItEAI)]:setprop("ProjectInternalId",  IIf(Empty(aRateio[nCont][6]), '',  IntPrjExt(/*cEmpresa*/, /*cFilial*/, aRateio[nCont][6])[2] )    ,,.T.)
				oRatItEAI[Len(oRatItEAI)]:setprop("TaskInternalId",  IIf(Empty(aRateio[nCont][6]), '', Alltrim(IntTrfExt(/*cEmpresa*/, /*cFilial*/, aRateio[nCont][6], '0001', aRateio[nCont][7])[2]) )    ,,.T.)
				oRatItEAI[Len(oRatItEAI)]:setprop("Value", IIf(Empty(aRateio[nCont][8]), '0', cValToChar(aRateio[nCont][8] * SD1->D1_VUNIT) )     ,,.T.)
				oRatItEAI[Len(oRatItEAI)]:setprop("Percentual", cValToChar(aRateio[nCont][5])    ,,.T.)
				oRatItEAI[Len(oRatItEAI)]:setprop("Quantity", IIf(Empty(aRateio[nCont][8]), '0', cValToChar(aRateio[nCont][8]) )    ,,.T.)
		
			Next nCont

			nQtdPrd:= MTICalPrd(SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD))//Considera a quantidade do produto se estiver repetido na nota fiscal.

			SB2->(dbSetOrder(1))  // B2_FILIAL, B2_COD, B2_LOCAL.
			If SB2->(dbSeek(xFilial() + SD1->(D1_COD + D1_LOCAL), .F.))	
				oItemEAI[Len(oItemEAI)]:setprop("TotalStock", cValToChar(SB2->B2_QATU - nQtdPrd)    ,,.T.)
			EndIf
			If !Empty(SD1->D1_LOTECTL)
				nQtdPrd:= MTICalPrd(SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD),SD1->D1_LOTECTL)//Considera a quantidade do produto se estiver repetido na nota fiscal considerando o lote
				oItemEAI[Len(oItemEAI)]:setprop("LotStock", cValToChar(SaldoLote(SD1->D1_COD,SD1->D1_LOCAL,SD1->D1_LOTECTL,NIL,.T.,.T.,NIL,dDataBase)- nQtdPrd)    ,,.T.)
			EndIf
			If SF4->(dbSeek(xFilial("SF4")+SD1->D1_TES))
				oItemEAI[Len(oItemEAI)]:setprop("UpdateStock",If(SF4->F4_ESTOQUE == 'S','true','false')     ,,.T.)
			EndIf
			If !Empty(SD1->D1_DTVALID)
				oItemEAI[Len(oItemEAI)]:setprop("LotExpirationDate", INTDTANO(SD1->D1_DTVALID)    ,,.T.)
			EndIf
			If !Empty(AFN->AFN_CONTRA)
				oItemEAI[Len(oItemEAI)]:setprop("ContractInternalID", IntCntExt(/*Empresa*/, xFilial("AFN"), AFN->AFN_PROJET, AFN->AFN_REVISA, AFN->AFN_CONTRA)[2]   ,,.T.)//Criar função
			EndIf

			SD1->(dbSkip())
		EndDo
	EndIf
Else
	GetItens(cRegSf1, @ofwEAIObj)
EndIf

SD1->(RestArea(aRestSD1))
AFN->(RestArea(aRestAFN))
SDE->(RestArea(aRestSDE))
CTO->(RestArea(aRestCTO))
RestArea(aArea)

Return {lRet, ofwEAIObj, cEntity}


/*/{Protheus.doc} A103REQIT
Busca as Solicitações de Compras amarrada a NF (Pedido)

@param   cPedido Numero de pedido de compra amarrado a NF
@param   cItemPC Item do pedido de compra amarrado a NF

@author  Rodrigo Machado Pontes
@version P11
@since   12/01/2016
@return  cResult - Lista de SCs
/*/
Static Function A103REQIT(cPedido,cItemPC, oItemEAI )

Local aArea		:= GetArea()
Local cQry		:= ""
Local aSCs		:= {}
Local nI		:= 0

If Select("SCNF") > 0
	SCNF->(DbCloseArea())
Endif

cQry := " SELECT C1_NUM,"
cQry += "        C1_ITEM"
cQry += " FROM " + RetSqlName("SC1")
cQry += " WHERE D_E_L_E_T_ = ''"
cQry += " AND C1_PEDIDO = '" + cPedido + "'"
cQry += " AND C1_ITEMPED = '" + cItemPC + "'"
cQry += " GROUP BY C1_NUM,"
cQry += "          C1_ITEM"

cQry := ChangeQuery(cQry)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"SCNF",.T.,.T.)

DbSelectArea("SCNF")
While SCNF->(!EOF())
	aAdd(aSCs,{SCNF->C1_NUM,SCNF->C1_ITEM})
	SCNF->(DbSkip())
Enddo

If Len(aSCs) > 0 .And. !Empty(cPedido)

	For nI := 1 To Len(aSCs)
		oReqEAI := oItemEAI:setprop("ListOfRequests", {}, 'Requests', , .T. )
		oReqEAI[Len(oReqEAI)]:setprop("RequestItemInternalId",   IntSCoExt(,,aSCs[nI,1],aSCs[nI,2],)[2]  ,,.T.)
	Next nI

Else
	oItemEAI:setprop("ListOfRequests", ''  ,,.T.)
Endif
RestArea(aArea)

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TipDocExt
Funcao que recebe o tipo de documento do Protheus e retorna o tipo de
documento da mensagem Invoice.

@param   cValue Variavel com conteudo xml para envio/recebimento.

@author  Mateus Gustavo de Freitas e Silva
@version P11
@since   23/02/2013
@return  cResult - String com o tipo de documento do Protheus
/*/
//-------------------------------------------------------------------
Static Function TipDocExt(cValue)
Local cResult := ""

Do Case
	Case cValue == "N"
		cResult := "01" //NF Normal
	Case cValue == "C"
		cResult := "02" //Compl. Preço
	Case cValue == "D"
		cResult := "03" //Devolução
	Case cValue == "I"
		cResult := "04" //NF Compl. ICMS
	Case cValue == "P"
		cResult := "05" //NF Compl. IPI
	Case cValue == "B"
		cResult := "06" //NF Beneficiamento
	EndCase
Return cResult

//-------------------------------------------------------------------
/*/{Protheus.doc} RatNFE
Recebe a chave de busca do Documento de Entrada e monta o rateio de
acordo com a estrutura do RM Solum (TOTVS Obras e Projetos).

@author  Leandro Luiz da Cruz
@version P11
@since   12/03/2013

@return aResult
/*/
//-------------------------------------------------------------------
Static Function RatNFE(chaveSD1)

Local aResult  := {}
Local aPrjtTrf := {}
Local aCntrCst := {}
Local nI       := 0

// Povoa o array de Projeto
AFN->(dbSetOrder(2))  // AFN_FILIAL, AFN_DOC, AFN_SERIE, AFN_FORNEC, AFN_LOJA, AFN_ITEM, AFN_PROJET, AFN_REVISA, AFN_TAREFA.
If AFN->(dbSeek(chaveSD1))
	While !AFN->(Eof()) .And. chaveSD1 == AFN->AFN_FILIAL + AFN->AFN_DOC + AFN->AFN_SERIE + AFN->AFN_FORNEC + AFN->AFN_LOJA + AFN->AFN_ITEM
		aAdd(aPrjtTrf, Array(4))
		nI++
		aPrjtTrf[nI][1] := AFN->AFN_PROJET
		aPrjtTrf[nI][2] := AFN->AFN_REVISA
		aPrjtTrf[nI][3] := AFN->AFN_TAREFA
		aPrjtTrf[nI][4] := AFN->AFN_QUANT
		AFN->(dbSkip())
	EndDo
EndIf

nI := 0

//Povoa o array de Centro de Custo
If SD1->D1_RATEIO == '1' //Possui rateio de centro de custo
	SDE->(dbSetOrder(1))  // DE_FILIAL, DE_DOC, DE_SERIE, DE_FORNECE, DE_LOJA, DE_ITEMNF, DE_ITEM.
	If SDE->(dbSeek(chaveSD1))
		While !SDE->(Eof()) .And. chaveSD1 == SDE->DE_FILIAL + SDE->DE_DOC + SDE->DE_SERIE + SDE->DE_FORNECE + SDE->DE_LOJA + SDE->DE_ITEMNF
			aAdd(aCntrCst, Array(5))
			nI++
			aCntrCst[nI][1] := SDE->DE_CC
			aCntrCst[nI][2] := SDE->DE_CONTA
			aCntrCst[nI][3] := SDE->DE_ITEMCTA
			aCntrCst[nI][4] := SDE->DE_CLVL
			aCntrCst[nI][5] := SDE->DE_PERC
			SDE->(dbSkip())
		EndDo
	EndIf
EndIf

If Len(aCntrCst) == 0
	aAdd(aCntrCst,{SD1->D1_CC, SD1->D1_CONTA, SD1->D1_ITEMCTA, SD1->D1_CLVL, 100})
EndIf

aResult := IntRatPrjCC(aCntrCst, aPrjtTrf)
Return aResult


//-------------------------------------------------------------------
/*/{Protheus.doc} GetItens
Recebe o número da Invoice de Compra e monta o bloco de XML
contendo a ListOfRequestItens.

@param   cChave Registro SF1
@author  Leandro Luiz da Cruz
@version P11
@since   02/07/2013

@return aResult
/*/
//-------------------------------------------------------------------
Static Function GetItens(cChave, ofwEAIObj)

Local cIntSd1  	 := ""
Local cIntApport := ""
Local aAreaAnt 	 := GetArea()
Local aRatExc  	 := {}
Local nI       	 := 0

DbSelectArea("SD1")
SD1->(dbSetOrder(1))  // D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM.
If SD1->(DbSeek(cChave))
	While SD1->(!EOF()) .And. SD1->D1_FILIAL + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA == cChave
		cIntSd1 := IntInvExt(cEmpAnt, SD1->D1_FILIAL, SD1->D1_DOC, SD1->D1_SERIE, SD1->D1_FORNECE, SD1->D1_LOJA, SD1->D1_COD, SD1->D1_ITEM)[2]

		//Exclui o de/para do item
		CFGA070Mnt( , "SD1", "D1_ITEM",, cIntSd1, .T. )
		oItemEAI := ofwEAIObj:setprop("ListOfItems", {}, 'Item', , .T. )
		oItemEAI[Len(oItemEAI)]:setprop("InternalId",   cIntSd1 ,,.T.)
		oItemEAI[Len(oItemEAI)]:setprop("OrderInternalId", IntPdCExt(,,SD1->D1_PEDIDO,,)[2]   ,,.T.)
		oItemEAI[Len(oItemEAI)]:setprop("OrderItemInternalId", IntPdCExt(,,SD1->D1_PEDIDO,SD1->D1_ITEMPC,)[2]  ,,.T.)

		A103REQIT(SD1->D1_PEDIDO,SD1->D1_ITEMPC, oItemEAI[Len(oItemEAI)])

		aRatExc := RatNFE(SD1->D1_FILIAL + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA + SD1->D1_ITEM)

		For nI := 1 To Len(aRatExc)
			cIntApport := cIntSd1 + '|' + cValToChar(nI)

			//Exclui o de/para do rateio
			CFGA070Mnt( , "SDE", "DE_CC",, cIntApport, .T. )

			oRatItEAI := oItemEAI[Len(oItemEAI)]:setprop("ListOfApportionInvoiceItem", {}, 'ApportionInvoiceItem', , .T. )
			oRatItEAI[Len(oRatItEAI)]:setprop("InternalId", cIntApport   ,,.T.)
			oRatItEAI[Len(oRatItEAI)]:setprop("CostCenterInternalId", IIf(!Empty(aRatExc[nI][1]),  IntCusExt(/*cEmpresa*/, /*cFilial*/, aRatExc[nI][1])[2] , '')   ,,.T.)
			oRatItEAI[Len(oRatItEAI)]:setprop("ProjectInternalId", IIf(Empty(aRatExc[nI][6]),  '', IntPrjExt(/*cEmpresa*/, /*cFilial*/, aRatExc[nI][6])[2] )   ,,.T.)
			oRatItEAI[Len(oRatItEAI)]:setprop("TaskInternalId",IIf(Empty(aRatExc[nI][6]),  '',  Alltrim(IntTrfExt(/*cEmpresa*/, /*cFilial*/, aRatExc[nI][6], '0001', aRatExc[nI][7])[2]) )    ,,.T.)
			oRatItEAI[Len(oRatItEAI)]:setprop("Percentual",  cValToChar(aRatExc[nI][5])   ,,.T.)
			oRatItEAI[Len(oRatItEAI)]:setprop("Quantity",  cValToChar(aRatExc[nI][8])   ,,.T.)
	
	
		Next nI

		SD1->(DbSkip())
	EndDo
EndIf

RestArea(aAreaAnt)
Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GetTaxes
Monta o xml com os impostos da nota fiscal.

@author      Mateus Gustavo de Freitas e Silva
@version     P11
@since       01/08/2013

@return cXML Variável com o xml gerado.
/*/
//-------------------------------------------------------------------
Static Function GetTaxes(cVersion, oItemEAI)

Local aImpostos := {}
Local nI

Local lD1FECP   := SD1->(ColumnPos( "D1_ALQFECP" )) > 0 .And. SD1->(ColumnPos( "D1_VALFECP" )) > 0 .And. SD1->(ColumnPos( "D1_BASFECP" )) > 0 // Verifica se os campos FECP existem
Local lD1FECPST := SD1->(ColumnPos( "D1_ALFCPST" )) > 0 .And. SD1->(ColumnPos( "D1_VFECPST" )) > 0 .And. SD1->(ColumnPos( "D1_BSFCPST" )) > 0 // Verifica se os campos FECP_ST existem

If cPaisLoc == "BRA"
	// {Imposto, Valor, Aliquota, Base de Cálculo, Retenção}
	aAdd(aImpostos, {"IPI",     "SD1->D1_VALIPI",  "SD1->D1_IPI",     "SD1->D1_BASEIPI", .F.})
	aAdd(aImpostos, {"ICM",     "SD1->D1_VALICM",  "SD1->D1_PICM",    "SD1->D1_BASEICM", .F.})
	aAdd(aImpostos, {"ICMS_ST", "SD1->D1_ICMSRET", "SD1->D1_ALIQSOL", "SD1->D1_BRICMS",  .F.})
	aAdd(aImpostos, {"ISS",     "SD1->D1_VALISS",  "SD1->D1_ALIQISS", "SD1->D1_BASEISS", .F.})
	aAdd(aImpostos, {"PIS",     "SD1->D1_VALIMP6", "SD1->D1_ALQIMP6", "SD1->D1_BASIMP6", .F.})
	aAdd(aImpostos, {"CONFINS", "SD1->D1_VALIMP5", "SD1->D1_ALQIMP5", "SD1->D1_BASIMP5", .F.})
	aAdd(aImpostos, {"PIS",     "SD1->D1_VALPIS",  "SD1->D1_ALQPIS",  "SD1->D1_BASEPIS", .T.})
	aAdd(aImpostos, {"CONFINS", "SD1->D1_VALCOF",  "SD1->D1_ALQCOF",  "SD1->D1_BASECOF", .T.})
	aAdd(aImpostos, {"CSLL",    "SD1->D1_VALCSL",  "SD1->D1_ALQCSL",  "SD1->D1_BASECSL", .T.})
	aAdd(aImpostos, {"IRRF",    "SD1->D1_VALIRR",  "SD1->D1_ALIQIRR", "SD1->D1_BASEIRR", .T.})
	aAdd(aImpostos, {"INSS",    "SD1->D1_VALINS",  "SD1->D1_ALIQINS", "SD1->D1_BASEINS", .T.})

	//FECP e FECP-ST
	If (lD1FECP)
		aAdd(aImpostos, {"FECP", "SD1->D1_VALFECP", "SD1->D1_ALQFECP", "SD1->D1_BASFECP", .F.})
	EndIf

	If (lD1FECPST)
		aAdd(aImpostos, {"FECP_ST", "SD1->D1_VFECPST", "SD1->D1_ALFCPST", "SD1->D1_BSFCPST", .T.})
	EndIf
Else
	//-- Onde: ExpC1 := Código do TES
	//-- ExpA1[n][1] := Código do Imposto Ex: "IVA"
	//-- ExpA1[n][2] := Identifica em qual campos sera gravado o valor do imposto Ex: "VALIMP1"
	//-- ExpA1[n][3] := Define se o Imposto ser  somado ao total da Nota Fiscal. Ex: "S,N"
	//-- ExpA1[n][4] := Define se o Imposto ser  somado ao valor base das duplicatas. Ex: "S,N"
	//-- ExpA1[n][5] := Define se o Imposto ser  creditado ao custo. Ex: "S,N"
	//-- ExpA1[n][6] := Define se o Imposto ser  calculado com base no total dos itens ou no total das mercadorias. Ex: "S,N"
	//-- ExpA1[n][7] := Identifica em qual campo sera gravado a Base do  imposto Ex: "BASIMP1"
	//-- ExpA1[n][8] := Identifica em qual campo sera gravado a Aliquota do imposto Ex: "ALQIMP1

	aImpLoc := DefImposto(SD1->D1_TES)
	For nI := 1 To Len(aImpLoc)
		aAdd(aImpostos, {aImpLoc[nI, 1], "SD1->D1_" + aImpLoc[nI, 2], "SD1->D1_" + aImpLoc[nI, 8], "SD1->D1_" + aImpLoc[nI, 7], .F.})
	Next nI
EndIf

For nI := 1 To Len(aImpostos)
	If &(aImpostos[Ni][2]) > 0
		oTaxaEAI := oItemEAI:setprop("ListOfTaxes", {}, 'Tax', , .T. )
	
		oTaxaEAI[Len(oTaxaEAI)]:setprop("Tax",   aImpostos[Ni, 1] ,,.T.)
	
		oTaxaEAI[Len(oTaxaEAI)]:setprop("StateCode",  RTrim(SF1->F1_EST) ,,.T.)
		oTaxaEAI[Len(oTaxaEAI)]:setprop("StateInternalId", RTrim(SF1->F1_EST)   ,,.T.)
		oTaxaEAI[Len(oTaxaEAI)]:setprop("CalculationBasis",  cValToChar(&(aImpostos[Ni, 4])) ,,.T.)
		oTaxaEAI[Len(oTaxaEAI)]:setprop("Percentage",  cValToChar(&(aImpostos[Ni, 3]))  ,,.T.)
		oTaxaEAI[Len(oTaxaEAI)]:setprop("Value", cValToChar(&(aImpostos[Ni, 2]))  ,,.T.)
		oTaxaEAI[Len(oTaxaEAI)]:setprop("WithHoldingTax", If(aImpostos[Ni, 5], 'true', 'false')  ,,.T.)

	EndIf
Next nI


Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MTICalPrd()
Soma a quantidade de produtos iguais e do mesmo lote
para considerar no calculo do saldo anterior
@author Leonardo Quintania
@since 11/12/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Static Function MTICalPrd(cChave,cLote)
Local nRet		:= 0
Local aRestSD1:= SD1->(GetArea())

Default cLote:= ""

If SD1->(DbSeek(cChave)) //D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA + D1_COD
	While SD1->(!EOF()) .And. SD1->(D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA + D1_COD) == cChave
		If Empty(cLote) .Or. SD1->D1_LOTECTL == cLote
			nRet+=	SD1->D1_QUANT
		EndIf
		SD1->(DbSkip())
	EndDo
EndIf

SD1->(RestArea(aRestSD1))

Return nRet
