#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "MATI120.CH"

/*/{Protheus.doc} MATI120
Funcao de integracao com o adapter EAI para envio e recebimento do
Pedido de Compra (SC7/SCH/AJ7) utilizando o conceito de mensagem unica
(Order).

@param   cXML          Variavel com conteudo xml para envio/recebimento.
@param   nTypeTrans    Tipo de transacao. (Envio/Recebimento)
@param   cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)

@author  Leandro Luiz da Cruz
@version P11
@since   19/04/2013
@return  aRet - Array contendo o resultado da execucao e a mensagem JSON de retorno.
         aRet[1] - (boolean) Indica o resultado da execução da função
         aRet[2] - (caracter) Mensagem JSON para envio
         aRet[3] - (caracter) Nome da mensagem unica- ORDER

@obs     O método irá retornar um objeto do tipo TOTVSBusinessEvent caso
         o tipo da mensagem seja EAI_BUSINESS_EVENT ou um tipo
         TOTVSBusinessRequest caso a mensagem seja do tipo TOTVSBusinessRequest.
         O tipo da classe pode ser definido com a função EAI_BUSINESS_REQUEST. 
/*/
//
Function MATI120O(oEAIObEt, nTypeTrans, cTypeMessage, cVersion)

	Local cVersao	:= ""
	Local lRet		:= .T.
	Local ofwEAIObj	:= FWEAIobj():NEW()
	Local cNameMsg	:= "ORDER"
	Local aRet		:= {}

	//Busca versão de envio e/ou recebimento
	cVersao := StrTokArr(cVersion, ".")[1]

	AdpLogEAI(1, "MATI120", nTypeTrans, cTypeMessage, oEAIObEt)

	If nTypeTrans == TRANS_RECEIVE
		If cTypeMessage == EAI_MESSAGE_BUSINESS .Or. cTypeMessage == EAI_MESSAGE_RESPONSE
			If cVersao == "4"
				aRet := v3002(oEAIObEt, nTypeTrans, cTypeMessage)
			Else
				lRet := .F.
				ofwEAIObj:Activate()
				ofwEAIObj:setProp("ReturnContent")
				ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", STR0036) // "A versão da mensagem informada não foi implementada!"
				AdpLogEAI(5, "MATI120", ofwEAIObj, lRet)
			EndIf
		ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
			aRet := v3002(oEAIObEt, nTypeTrans, cTypeMessage)
		EndIf
	ElseIf nTypeTrans == TRANS_SEND
		If cVersao == "4"
			aRet := v3002(oEAIObEt, nTypeTrans, cTypeMessage)
		Else
			lRet := .F.
			ofwEAIObj:Activate()
			ofwEAIObj:setProp("ReturnContent")
			ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", STR0039) // "A versão da mensagem informada não foi implementada!"
			AdpLogEAI(5, "MATI120", ofwEAIObj, lRet)
		EndIf
	Endif

	If Len(aRet) > 0
		lRet 	:= aRet[1]
		ofwEAIObj := aRet[2]
	Endif

Return {lRet, ofwEAIObj, cNameMsg}

//----------------------------------------------------------------------------------
/*/{Protheus.doc} v3002
Funcao de integracao com o adapter EAI para envio e recebimento do
Pedido de Compra (SC7/SCH/AJ7) utilizando o conceito de mensagem unica
(Order).

@param   cXML          Variavel com conteudo xml para envio/recebimento.
@param   nTypeTrans    Tipo de transacao. (Envio/Recebimento)
@param   cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)

@author  Leandro Luiz da Cruz
@version P11
@since   19/04/2013
@return  aRet - Array contendo o resultado da execucao e a mensagem Xml de retorno.
         aRet[1] - (boolean) Indica o resultado da execução da função
         aRet[2] - (caracter) Mensagem Xml para envio

@obs     O método irá retornar um objeto do tipo TOTVSBusinessEvent caso
         o tipo da mensagem seja EAI_BUSINESS_EVENT ou um tipo
         TOTVSBusinessRequest caso a mensagem seja do tipo TOTVSBusinessRequest.
         O tipo da classe pode ser definido com a função EAI_BUSINESS_REQUEST.
/*/
//----------------------------------------------------------------------------------
Static Function v3002(oEAIObEt, nTypeTrans, cTypeMessage)
	Local lRet             := .T.
	Local cAlias           := "SC7"
	Local cField           := "C7_NUM"
	Local cEvent           := "upsert"
	Local cUserPar         := AllTrim(GetNewPar("MV_SLMCOMP", ""))
	Local lSlmUsr          := Iif(SuperGetMv("MV_SLMPUSR",,"N")=="S",.T.,.F.)
	Local cUser	           := ""
	Local ofwEAIObj		   := FWEAIobj():NEW()
	Local cValExt          := ""
	Local cValInt          := ""
	Local cValIntI         := ""
	Local cMarca           := ""
	Local cNumCot          := ""
	Local cFornec          := ""
	Local cLoja            := ""
	Local cProduto            := ""
	Local cNumPed          := ""
	Local cItemSC7         := ""
	Local nOpcx            := 0
	Local nI               := 0
	Local nI2              := 0
	Local nI3              := 0
	Local nI4              := 0
	Local nI5              := 0
	Local nY			   := 0
	Local nQtd             := 0
	Local nVlrUni          := 0
	Local nVlrTot          := 0
	Local aCab             := {}
	Local aAux             := {}
	Local aCCusto          := {}
	Local aProjeto         := {}
	Local aLinha           := {}
	Local aItens           := {}
	Local aItensRat        := {}
	Local aItensPrj        := {}
	Local aItemAux         := {}
	Local aDePara          := {}
	Local aRateio          := {}
	Local aRet             := {}
	Local aAdtPC           := {}
	Local nAux             := 0
	Local nDescTotal       := 0
	Local nValorTotal      := 0
	Local n1Cnt            := 0
	Local n2Cnt            := 0
	Local aDescUnit        := {}
	Local cCond            := ""
	Local cNameInternalId  := ""
	Local cVenVer          := RTrim(PmsMsgUVer('CUSTOMERVENDOR',         'MATA020')) //Versão do Fornecedor
	Local cCusVer          := RTrim(PmsMsgUVer('COSTCENTER',             'CTBA030')) //Versão do Centro de Custo
	Local cUndVer          := RTrim(PmsMsgUVer('UNITOFMEASURE',          'QIEA030')) //Versão da Unidade de Medida
	Local cConVer          := RTrim(PmsMsgUVer('PAYMENTCONDITION',       'MATA360')) //Versão da Condição de Pagamento
	Local cMoeVer          := RTrim(PmsMsgUVer('CURRENCY',               'CTBA140')) //Versão da Moeda
	Local cLocVer          := RTrim(PmsMsgUVer('WAREHOUSE',              'AGRA045')) //Versão do Local de Estoque
	Local cPrdVer          := RTrim(PmsMsgUVer('ITEM',                   'MATA010')) //Versão do Produto
	Local cPrjVer          := RTrim(PmsMsgUVer('PROJECT',                'PMSA200')) //Versão do Projeto
	Local cTrfVer          := RTrim(PmsMsgUVer('TASKPROJECT',            'PMSA203')) //Versão da Tarefa
	Local cTPgVer          := RTrim(PmsMsgUVer('ACCOUNTPAYABLEDOCUMENT', 'FINA050')) //Versão do Título a Pagar
	Local cPdCVer          := RTrim(PmsMsgUVer('ORDER',                  'MATA120')) //Versão do Pedido de Compra
	Local cSCoVer          := RTrim(PmsMsgUVer('REQUEST',                'MATA110')) //Versão da Solicitação de Compra
	Local lMktPlace        := SuperGetMv("MV_MKPLACE",.F.,.F.)
	Local lRestInc         := Iif(SuperGetMv("MV_RESTINC",,"N")=="S",.T.,.F.)
	Local cCodSc           := ""
	Local nPosMoeda        := ""
	Local nPosTxMoeda      := ""
	Local nMoedaInt        := ""
	Local nTxMoeInt        := ""
	Local cObsM			   := ""
	Local cNumPc		   := ""
	Local cMoedaExt		   := ""
	Local nPosProd		   := 0
	Local aErro		   	   := {}
	Local cLogErro		   := ""
	Local oDiscounts	   := nil
	Local oSalesOrderItens	   := nil
	Local oItemDiscounts   := nil
	Local oApportionOrderItem   := nil
	Local oItemRat   	   := nil
	Local xAux   	   	   := nil
	Local oObjLtCred   	   := nil
	Local oObLisOfIt   	   := nil
	Local aRetPe   	   	   := {}
	Local aErroAuto	   	   := {}
	Local nErrSize	   	   := 0
	Local cJson	   	   	   := 0
	Local oObjItem		   := nil
	Local nCtItem		   := ""
	Local cUnidMed		   := ""
	Local nLtOfItID		   := 1

	Private cAliasTMP		   := ""
	Private oXml           := Nil
	Private oXmlAux        := Nil
	Private oXmlRat        := Nil
	Private lMsErroAuto    := .F.
	Private lAutoErrNoFile := .T.
	Private cNumPCWS       := ""
	Private lRetDedFat     := A120RDFRM("I120")

	// Mensagem de Entrada
	If nTypeTrans == TRANS_RECEIVE
		// Regra de Negócio
		If cTypeMessage == EAI_MESSAGE_BUSINESS
			If lMktPlace .And. oEAIObEt:getPropValue("funcmsgorder") !=  nil .And. !Empty( oEAIObEt:getPropValue("funcmsgorder") )
				cNumPc :=  PadR( StrToArray( oEAIObEt:getPropValue("InternalId") , "|")[3] , TamSX3('C7_NUM')[1])
				If oEAIObEt:getPropValue("funcmsgorder") == "42" // Confirmação (Utilizada no Paradigma)
					If SC7->( DbSeek( xFilial("SC7") + cNumPc  ) )
						cCodSc := SC7->C7_NUMSC
						While SC7->( !EOF() )  .And. SC7->(C7_FILIAL+C7_NUM) == xFilial("SC7")+cNumPc
							RecLock("SC7",.F.)
							SC7->C7_ACCPROC := '2'
							MsUnLock()
							SC7->(DbSkip())
						EndDo
					EndIf
				ElseIf oEAIObEt:getPropValue("funcmsgorder") == '43' // Recusa (Utilizada no Paradigma)
					AADD(aCab  ,{"C7_NUM"	, cNumPc ,Nil})
					AADD(aItens,{{"C7_NUM"	, cNumPc ,Nil}})
					lMsErroAuto := .F.

					SC7->( dbSetOrder(1) )
					If SC7->( DbSeek( xFilial("SC7") + cNumPc ) )
						cNumCot := SC7->C7_NUMCOT
						cFornec := SC7->C7_FORNECE
						cLoja   := SC7->C7_LOJA
						cProduto:= SC7->C7_PRODUTO

						AdpLogEAI(4, 5)

						SC8->( dbSetOrder(3) )
						SC8->( DbSeek( xFilial("SC8") + cNumCot  + cFornec + cLoja + cNumPc ) )
						lMSErroAuto	:= .F.
						MSExecAuto({|v,x,y,z| MATA120(v,x,y,z)},1,aCab,aItens,5)

						If lMsErroAuto
							aErro := GetAutoGRLog()
							For nY := 1 To Len(aErro)
								cLogErro += aErro[nY] +CRLF
							Next nY
							lRet := .F.
						Endif

						aCab   :={}
						aItens :={}

						aAdd(aCab,{"C8_NUM"    ,cNumCot,NIL})
						aAdd(aCab,{"COMPACC"   ,""     ,NIL})
						aAdd(aCab,{"C8_FORNECE",cFornec,Nil})
						aAdd(aCab,{"C8_LOJA"   ,cLoja  ,Nil})

						AdpLogEAI(4, 5)

						lMSErroAuto	:= .F.
						lAutoErrNoFile := .T.
						MSExecAuto({|x,y,z| MATA150(x,y,z)},aCab,aItens,5)

						If lMsErroAuto
							aErro := GetAutoGRLog()
							For nY := 1 To Len(aErro)
								cLogErro += aErro[nY] +CRLF
							Next nY
							lRet := .F.
							ofwEAIObj:Activate()
							ofwEAIObj:setProp("ReturnContent")
							ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
							AdpLogEAI(3, "MATI120", ofwEAIObj, lRet)
							Return {lRet, ofwEAIObj}
						Else
							Return {.T.,"OK",}
						Endif

					EndIf
				EndIf
			ElseIf oEAIObEt:getPropValue("OrderPurpose") !=  nil .And. !Empty( oEAIObEt:getPropValue("OrderPurpose") )
				If AllTrim(oEAIObEt:getPropValue("OrderPurpose")) == "1"
					//Verifica se a marca foi informada
					If oEAIObEt:getHeaderValue("ProductName") !=  nil .And. !Empty( oEAIObEt:getHeaderValue("ProductName") )
						cMarca := Upper(oEAIObEt:getHeaderValue("ProductName"))
					Else
						lRet := .F.
						cLogErro := ""
						ofwEAIObj:Activate()
						ofwEAIObj:setProp("ReturnContent")
						cLogErro := STR0014 // "Informe a Marca!"
						ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
						AdpLogEAI(3, "MATI120", ofwEAIObj, lRet)
						Return {lRet, ofwEAIObj}
					EndIf

					// Verifica se a filial atual é a mesma filial de inclusão do cadastro
					aAux := IntChcEmp(oEAIObEt, cAlias, cMarca)
					/*If !aAux[1]
						lRet := aAux[1]
						cLogErro := ""
						ofwEAIObj:Activate()
						ofwEAIObj:setProp("ReturnContent")
						cLogErro := aAux[2]
						ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
						AdpLogEAI(3, "MATI120", ofwEAIObj, lRet)
						Return {lRet, ofwEAIObj}
					EndIf*/

					//Verifica se o InternalId foi informado
					If oEAIObEt:getPropValue("InternalId") != nil .And. !Empty( oEAIObEt:getPropValue("InternalId") )
						cValExt := oEAIObEt:getPropValue("InternalId")
					Else
						lRet := .F.
						cLogErro := ""
						ofwEAIObj:Activate()
						ofwEAIObj:setProp("ReturnContent")
						cLogErro := STR0015 // "O InternalId é obrigatório!"
						ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
						AdpLogEAI(3, "MATI120", ofwEAIObj, lRet)
						Return {lRet, ofwEAIObj}
					EndIf

					aAux := IntPdCInt(cValExt, cMarca, cPdCVer)
					If aAux[1]
						cNumPed := RTrim(aAux[2][3])

						If Upper(AllTrim(oEAIObEt:getEvent())) == "UPSERT"
							AdpLogEAI(3, "MATI120", ofwEAIObj, lRet)
							If SC7->(dbSeek(xFilial(cAlias) + cNumPed))
								nOpcx := 4 //UPDATE
								cValInt := IntPdCExt(/*Empresa*/, /*Filial*/, aAux[2][3], Nil, cPdCVer)[2]
								aAdd(aCab, {"C7_NUM", cNumPed, Nil})
							Else
								lRet := .F.
								cLogErro := ""
								ofwEAIObj:Activate()
								ofwEAIObj:setProp("ReturnContent")
								cLogErro := STR0016 // "Erro no processamento da operação. Verifique o de/para do pedido."
								ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
								AdpLogEAI(3, "MATI120", ofwEAIObj, lRet)
								Return {lRet, ofwEAIObj}
							EndIf
						ElseIf Upper(AllTrim(oEAIObEt:getEvent())) == "DELETE"
							If SC7->(dbSeek(xFilial("SC7") + cNumPed))
								nOpcx := 5 //DELETE
								cValInt := IntPdCExt(/*Empresa*/, /*Filial*/, aAux[2][3], Nil, cPdCVer)[2]
								aAdd(aCab, {"C7_FILIAL", xFilial(cAlias), Nil})
								aAdd(aCab, {"C7_NUM", cNumPed, Nil})
								aDePara := GetDePara(cMarca, xFilial(cAlias) + cNumPed, cPdCVer)

								If lRestInc .OR. lSlmUsr

									If !Empty(cUserPar)
										//Atualiza variavel global para excluir o pedido
										cUserName	:= cUserPar
									Endif
								Endif
							Else
								lRet := .F.
								cLogErro := ""
								ofwEAIObj:Activate()
								ofwEAIObj:setProp("ReturnContent")
								cLogErro := STR0017 // "Pedido a ser excluído não encontrado no Protheus."
								ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
								AdpLogEAI(3, "MATI120", ofwEAIObj, lRet)
								Return {lRet, ofwEAIObj}
							EndIf
						EndIf
					Else
						If Upper(AllTrim(oEAIObEt:getEvent())) == "UPSERT"
							nOpcx := 3 //INSERT

							If Empty(Posicione('SX3', 2, Padr('C7_NUM', 10), 'X3_RELACAO'))
								If oEAIObEt:getPropValue("Number") != "U" .and. !Empty(oEAIObEt:getPropValue("Number"))
									aAdd(aCab, {"C7_NUM",oEAIObEt:getPropValue("Number"), Nil})
								Else
									lRet := .F.
									cLogErro := ""
									ofwEAIObj:Activate()
									ofwEAIObj:setProp("ReturnContent")
									cLogErro := "Informe um numero de pedido ou preencha o inicializador padrão."
									ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
									AdpLogEAI(3, "MATI120", ofwEAIObj, lRet)
									Return {lRet, ofwEAIObj}
								Endif
							Endif
						Else
							lRet := .F.
							cLogErro := ""
							ofwEAIObj:Activate()
							ofwEAIObj:setProp("ReturnContent")
							cLogErro := STR0018 // "O registro a ser excluído não foi encontrado na base Protheus."
							ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
							AdpLogEAI(3, "MATI120", ofwEAIObj, lRet)
							Return {lRet, ofwEAIObj}
						EndIf
					EndIf

					If nOpcx != 5
						//Filial
						aAdd(aCab, {"C7_FILIAL", xFilial("SC7"), Nil})

						// Obtém o Código Interno do Fornecedor e a Loja
						If oEAIObEt:getPropValue("CustomerInternalId") != nil .And. !Empty( oEAIObEt:getPropValue("CustomerInternalId") )
							aAux := IntForInt(oEAIObEt:getPropValue("CustomerInternalId"), cMarca)
							If !aAux[1]
								lRet := aAux[1]
								// cXmlRet := aAux[2]
								// Return {lRet, cXmlRet}
								cLogErro := ""
								ofwEAIObj:Activate()
								ofwEAIObj:setProp("ReturnContent")
								cLogErro := aAux[2]
								ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
								AdpLogEAI(3, "MATI120", ofwEAIObj, lRet)
								Return {lRet, ofwEAIObj}
							Else
								cFornec := PadR(aAux[2][3], TamSX3("C7_FORNECE")[1])
								cLoja   := PadR(aAux[2][4], TamSX3("C7_LOJA")[1])
								aAdd(aCab, {"C7_FORNECE", cFornec, Nil})
								aAdd(aCab, {"C7_LOJA",    cLoja,   Nil})
							EndIf
						ElseIf oEAIObEt:getPropValue("CustomerCode") != nil .And. !Empty( oEAIObEt:getPropValue("CustomerCode") )
							If Len(oEAIObEt:getPropValue("CustomerCode")) > TamSX3("C7_FORNECE")[1]
								cFornec := SubStr(oEAIObEt:getPropValue("CustomerCode"), 1, TamSX3("C7_FORNECE")[1])
								cLoja   := PadR(SubStr(oEAIObEt:getPropValue("CustomerCode"), TamSX3("C7_FORNECE")[1] + 1), TamSX3("C7_LOJA")[1])
							Else
								cFornec := PadR(oEAIObEt:getPropValue("CustomerCode"), TamSX3("C7_FORNECE")[1])
								cLoja   := ""
							EndIf
							aAdd(aCab, {"C7_FORNECE", cFornec, Nil})
							aAdd(aCab, {"C7_LOJA",    cLoja,   Nil})
						Else
							lRet := .F.
							cLogErro := ""
							ofwEAIObj:Activate()
							ofwEAIObj:setProp("ReturnContent")
							cLogErro := STR0041 //"Fornecedor não informado"
							ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
							AdpLogEAI(3, "MATI120", ofwEAIObj, lRet)
							Return {lRet, ofwEAIObj}
						EndIf

						//Data de emissão
						If oEAIObEt:getPropValue("RegisterDate") != nil .And. !Empty( oEAIObEt:getPropValue("RegisterDate") )
							aAdd(aCab, {"C7_EMISSAO", SToD(StrTran(oEAIObEt:getPropValue("RegisterDate"), "-", "")), Nil})
						Else
							aAdd(aCab, {"C7_EMISSAO", dDataBase, Nil})
						EndIf

						// Obtém o código interno da Condição de Pagamento
						If oEAIObEt:getPropValue("PaymentConditionInternalId") != nil .And. !Empty( oEAIObEt:getPropValue("PaymentConditionInternalId") )
							aAux := IntConInt(oEAIObEt:getPropValue("PaymentConditionInternalId"), cMarca)
							If !aAux[1]
								lRet := aAux[1]
								cLogErro := ""
								ofwEAIObj:Activate()
								ofwEAIObj:setProp("ReturnContent")
								cLogErro := aAux[2]
								ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
								AdpLogEAI(3, "MATI120", ofwEAIObj, lRet)
								Return {lRet, ofwEAIObj}
							Else
								cCond := aAux[2][3]
								aAdd(aCab, {"C7_COND", cCond, Nil})
							EndIf
							//Se o InternalID não foi informado e é integração com o TOP (RM Solum) pegar a condição do parâmetro MV_SLMCOND
						ElseIf IsIntegTop()
							aAdd(aCab, {"C7_COND", GETMV("MV_SLMCOND", .F., ""), Nil}) 
						ElseIf oEAIObEt:getPropValue("PaymentTermCode") != nil .And. !Empty( oEAIObEt:getPropValue("PaymentTermCode") )
							cCond := oEAIObEt:getPropValue("PaymentTermCode")
							AADD(aCab,{"C7_COND",cCond,NIL})
						Else
							lRet := .F.
							cLogErro := ""
							ofwEAIObj:Activate()
							ofwEAIObj:setProp("ReturnContent")
							cLogErro := STR0042 //"Condição de pagamento não informada"
							ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
							AdpLogEAI(3, "MATI120", ofwEAIObj, lRet)
							Return {lRet, ofwEAIObj}
						EndIf

						//Tipo do frete utilizado
						If oEAIObEt:getPropValue("FreightType") != nil .And. !Empty( oEAIObEt:getPropValue("FreightType") )
							aAdd(aCab, {"C7_TPFRETE", getTpFre(AllTrim(oEAIObEt:getPropValue("FreightType")), nTypeTrans), Nil})
						EndIf

						//Peso Bruto
						If oEAIObEt:getPropValue("GrossWeight") != nil .And. !Empty( oEAIObEt:getPropValue("GrossWeight") )
							aAdd(aCab, {"C7_PESO_B", Val(oEAIObEt:getPropValue("GrossWeight")), Nil})
						EndIf

						//Volume Cubado
						If oEAIObEt:getPropValue("CubicVolume") != nil .And. !Empty( oEAIObEt:getPropValue("CubicVolume") )
							aAdd(aCab, {"C7_MT3", Val(oEAIObEt:getPropValue("CubicVolume")), Nil})
						EndIf

						//Valor do Seguro Unitário
						If oEAIObEt:getPropValue("InsuranceValue") != nil .And. !Empty( oEAIObEt:getPropValue("InsuranceValue") )
							aAdd(aCab, {"C7_SEGURO", oEAIObEt:getPropValue("InsuranceValue"), Nil})
						EndIf

						aAdd(aCab, {"C7_CONTATO", Space(1), Nil})
						aAdd(aCab, {"C7_FILENT", xFilial("SC7"), Nil})

						//Valor do Desconto
						If oEAIObEt:getPropValue("Discounts") != nil
							oDiscounts := oEAIObEt:getPropValue("Discounts")

							For nI := 1 To Len(oDiscounts)
								nDescTotal += Val(oDiscounts[nI]:getPropValue("Discount"))
							Next nI
						EndIf

						//Moeda
						If oEAIObEt:getPropValue("CurrencyId") != nil .And. !Empty( oEAIObEt:getPropValue("CurrencyId") )
							cMoedaExt	:= oEAIObEt:getPropValue("CurrencyId")

							aAux := IntMoeInt(cMoedaExt, cMarca, cMoeVer)
							If !aAux[1]
								lRet := aAux[1]
								cLogErro := ""
								ofwEAIObj:Activate()
								ofwEAIObj:setProp("ReturnContent")
								cLogErro := aAux[2]
								ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
								AdpLogEAI(3, "MATI120", ofwEAIObj, lRet)
								Return {lRet, ofwEAIObj}
							Else
								aAdd(aCab, {"C7_MOEDA",Iif(cMoeVer=="1.000",Val(aAux[2][2]),Val(aAux[2][3])), Nil})
							EndIf
						ElseIf oEAIObEt:getPropValue("CurrencyCode") != nil .And. !Empty( oEAIObEt:getPropValue("CurrencyCode") )
							aAdd(aCab, {"C7_MOEDA", Val(oEAIObEt:getPropValue("CurrencyCode")), Nil})
						EndIf

						If oEAIObEt:getPropValue("CurrencyRate") != nil .And. !Empty( oEAIObEt:getPropValue("CurrencyRate") )
							aAdd(aCab, {"C7_TXMOEDA", Val(oEAIObEt:getPropValue("CurrencyRate")), Nil})
						Endif

						nPosMoeda		:= aScan(aCab,{|x| AllTrim(x[1]) == "C7_MOEDA"})
						nPosTxMoeda	:= aScan(aCab,{|x| AllTrim(x[1]) == "C7_TXMOEDA"})

						//Esta sendo enviada a Moeda, e é preciso enviar a taxa da moeda
						If nPosMoeda > 0
							nMoedaInt := aCab[nPosMoeda,2]

							If nMoedaInt == 1 //Moeda Local
								If nPosTxMoeda == 0
									aAdd(aCab, {"C7_TXMOEDA",1, Nil})
								Endif
							Else
								If nPosTxMoeda == 0
									nTxMoeInt := RecMoeda(dDataBase,nMoedaInt)
									If nTxMoeInt > 0
										aAdd(aCab, {"C7_TXMOEDA",nTxMoeInt, Nil})
									Else
										lRet := .F.
										cLogErro := ""
										ofwEAIObj:Activate()
										ofwEAIObj:setProp("ReturnContent")
										cLogErro := "Cadastrar taxa da moeda " + AllTrim(Str(nMoedaInt)) + "(" + AllTrim(cMoedaExt) + ") na data: " + DtoC(dDataBase)
										ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
										AdpLogEAI(3, "MATI120", ofwEAIObj, lRet)
										Return {lRet, ofwEAIObj}
									Endif
								Endif
							Endif
						Endif

						//Origem
						aAdd(aCab, {"C7_ORIGEM","MSGEAI",Nil})

						If SC7->(ColumnPos("C7_APROPRM")) > 0 .And. oEAIObEt:getPropValue("TaskCostAssignmentDocument") != nil .And. !Empty( oEAIObEt:getPropValue("TaskCostAssignmentDocument") )
							cTpAprop := Alltrim(oEAIObEt:getPropValue("TaskCostAssignmentDocument"))
							AADD(aCab,{"C7_APROPRM",StrTran(cTpAprop,'0',''),NIL})
						Endif

						If oEAIObEt:getPropValue("Observation") != nil .And. !Empty( oEAIObEt:getPropValue("Observation") )
							cObsM := AllTrim(oEAIObEt:getPropValue("Observation"))
						Endif

						// Se não for array
						If oEAIObEt:getPropValue("SalesOrderItens") != nil
							oSalesOrderItens := oEAIObEt:getPropValue("SalesOrderItens")

							For nI := 1 To Len(oSalesOrderItens)
								nQtd    := 0
								nVlrUni := 0
								nVlrTot := 0
								aItemAux := {}

								// Atualiza o objeto com a posição atual
								oItemAux := oEAIObEt:getPropValue("SalesOrderItens")[nI]

								//Array e contador que serão usados para manipular o de/para
								aAdd(aDePara, Array(4))
								aDePara[nI][1] := oItemAux:getPropValue("InternalId")
								aDePara[nI][2] := PadL(oItemAux:getPropValue("OrderItem"), TamSx3("C7_ITEM")[1], "0")
								aDePara[nI][3] := 'SC7'
								aDePara[nI][4] := 'C7_ITEM'

								If nOpcx == 4
									If SC7->(dbSeek(xFilial("SC7") + cNumPed + StrZero(nI, TamSX3("C7_ITEM")[1])))
										aAdd(aItemAux, {"LINPOS", "C7_ITEM", StrZero(nI, TamSX3("C7_ITEM")[1]),Nil})
										aAdd(aItemAux, {"AUTDELETA", "N", Nil})
									Else
										aAdd(aItemAux, {"C7_ITEM", StrZero(nI, TamSX3("C7_ITEM")[1]), Nil})
									EndIf
								Else
									aAdd(aItemAux, {"C7_ITEM", StrZero(nI, TamSX3("C7_ITEM")[1]), Nil})
								EndIf

								cItemSC7 := StrZero(nI, TamSX3("C7_ITEM")[1])

								//Obtém o Código Interno do produto
								If  oItemAux:getPropValue("ItemInternalId") != nil .And. !Empty( oItemAux:getPropValue("ItemInternalId") )
									aAux := IntProInt(oItemAux:getPropValue("ItemInternalId"), cMarca, cPrdVer)
									If !aAux[1]
										lRet := aAux[1]
										cLogErro := ""
										ofwEAIObj:Activate()
										ofwEAIObj:setProp("ReturnContent")
										cLogErro := aAux[2]
										ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
										AdpLogEAI(3, "MATI120", ofwEAIObj, lRet)
										Return {lRet, ofwEAIObj}
									Else
										aAdd(aItemAux, {"C7_PRODUTO", aAux[2][3], Nil})
									EndIf
								ElseIf oItemAux:getPropValue("ItemCode") != nil .And. !Empty( oItemAux:getPropValue("ItemCode") )
									aAdd(aItemAux, {"C7_PRODUTO", oItemAux:getPropValue("ItemCode"), Nil})
								EndIf

								//Descrição do produto
								If oItemAux:getPropValue("ItemDescription") != nil .And. !Empty( oItemAux:getPropValue("ItemDescription") )
									aAdd(aItemAux , {"C7_DESCRI" , AllTrim(oItemAux:getPropValue("ItemDescription")), Nil})
								EndIf

								//Obtém o código interno do local de estoque
								If oItemAux:getPropValue("WarehouseInternalId") != nil .And. !Empty( oItemAux:getPropValue("WarehouseInternalId") )
									aAux := IntLocInt(oItemAux:getPropValue("WarehouseInternalId"), cMarca, cLocVer)
									If !aAux[1]
										lRet := aAux[1]
										cLogErro := ""
										ofwEAIObj:Activate()
										ofwEAIObj:setProp("ReturnContent")
										cLogErro := aAux[2]
										ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
										AdpLogEAI(3, "MATI410", ofwEAIObj, lRet)
										Return {lRet, ofwEAIObj}
									Else
										aAdd(aItemAux, {"C7_LOCAL", aAux[2][3], Nil})
									EndIf
								EndIf

								//Obtém o Código Internl da Unidade de Medida
								If oItemAux:getPropValue("UnitOfMeasureInternalId") != nil .And. !Empty( oItemAux:getPropValue("UnitOfMeasureInternalId") )
									aAux := IntUndInt(oItemAux:getPropValue("UnitOfMeasureInternalId"), cMarca)
									If !aAux[1]
										lRet := aAux[1]
										cLogErro := ""
										ofwEAIObj:Activate()
										ofwEAIObj:setProp("ReturnContent")
										cLogErro := aAux[2]
										ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
										AdpLogEAI(3, "MATI120", ofwEAIObj, lRet)
										Return {lRet, ofwEAIObj}
									Else
										aAdd(aItemAux, {"C7_UM", aAux[2][3], Nil})
									EndIf
								ElseIf oItemAux:getPropValue("itemunitofmeasure") != nil .And. !Empty( oItemAux:getPropValue("itemunitofmeasure") )
									aAdd(aItemAux, {"C7_UM", oItemAux:getPropValue("itemunitofmeasure"), Nil})
								EndIf

								//Obtém o Centro de Custo
								If oItemAux:getPropValue("CostCenterInternalId") != nil .And. !Empty( oItemAux:getPropValue("CostCenterInternalId") )
									aAux := IntCusInt(oItemAux:getPropValue("CostCenterInternalId"), cMarca)
									If !aAux[1]
										lRet := aAux[1]
										cLogErro := ""
										ofwEAIObj:Activate()
										ofwEAIObj:setProp("ReturnContent")
										cLogErro := aAux[2]
										ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
										AdpLogEAI(3, "MATI120", ofwEAIObj, lRet)
										Return {lRet, ofwEAIObj}
									Else
										aAdd(aItemAux, {"C7_CC", aAux[2][3], Nil})
									EndIf
								ElseIf oItemAux:getPropValue("CostCenterCode") != nil .And. !Empty( oItemAux:getPropValue("CostCenterCode") )
									aAdd(aItemAux, {"C7_CC", oItemAux:getPropValue("CostCenterCode"), Nil})
								EndIf

								//Quantidade
								If oItemAux:getPropValue("Quantity") != nil
									nQtd := Val(AllTrim(oItemAux:getPropValue("Quantity")))
									aAdd(aItemAux, {"C7_QUANT", nQtd, Nil})
								EndIf

								//Preço unitário
								If oItemAux:getPropValue("UnityPrice") != nil
									nVlrUni := Val(AllTrim(oItemAux:getPropValue("UnityPrice")))
									aAdd(aItemAux, {"C7_PRECO", nVlrUni, Nil})
								EndIf

								//Preço total
								If oItemAux:getPropValue("TotalPrice") != nil .And. !Empty( oItemAux:getPropValue("TotalPrice") )
									nVlrTot := Val(oItemAux:getPropValue("TotalPrice"))
									aAdd(aItemAux, {"C7_TOTAL", Val(oItemAux:getPropValue("TotalPrice")), Nil})
								Else
									nVlrTot := nQtd * nVlrUni
									aAdd(aItemAux, {"C7_TOTAL", nVlrTot, Nil})
								EndIf

								//Monta o rateio do desconto da capa
								aAdd(aDescUnit, {cItemSC7, nVlrTot, 0.0})
								nValorTotal += nVlrTot

								//Valor de desconto do item
								If oItemAux:getPropValue("ItemDiscounts") != nil .And. !Empty( oItemAux:getPropValue("ItemDiscounts") )
									//Se não é array transforma em array
									oItemDiscounts := oItemAux:getPropValue("ItemDiscounts")

									For nI2 := 1 To Len(oItemDiscounts)
										nAux += Val(oItemDiscounts[nI2]:getPropValue("ItemDiscount"))
									Next nI2

									aAdd(aItemAux, {"C7_VLDESC", nAux, Nil})
								EndIf

								//Valor do frete do item
								If oEAIObEt:getPropValue("FreightValue") != nil .And. !Empty( oEAIObEt:getPropValue("FreightValue") )
									aAdd(aCab, {"C7_VALFRE", Val(oEAIObEt:getPropValue("FreightValue")), Nil})
								EndIf

								//Valor do seguro
								If oItemAux:getPropValue("InsuranceValue") != nil
									aAdd(aItemAux, {"C7_SEGURO", Val(AllTrim(oItemAux:getPropValue("InsuranceValue"))), Nil})
								EndIf

								//Observações
								If !Empty(cObsM) .Or. (oItemAux:getPropValue("Observation") != nil  .And. !Empty(oItemAux:getPropValue("Observation")))
									cObsM := Iif(!Empty(cObsM),cObsM,AllTrim(oItemAux:getPropValue("Observation")))
									cObsM := Padr(cObsM, TamSX3("C7_OBSM")[1])
									aAdd(aItemAux, {"C7_OBSM",cObsM, Nil})
								EndIf

								// Integração com o TOTVS Obras e Projetos
								If IsIntegTop()
									If lRestInc .OR. lSlmUsr
										// Código do usuário comprador
										If lSlmUsr
											If oEAIObEt:getPropValue("UserInternalId") != nil .And. !Empty( oEAIObEt:getPropValue("UserInternalId") )
												cUser	  := RetCodUsr(AllTrim(oEAIObEt:getPropValue("UserInternalId")))
											EndIf

											If Empty(cUser)
												lRet := .F. 
												cLogErro := ""
												ofwEAIObj:Activate()
												ofwEAIObj:setProp("ReturnContent")
												cLogErro := STR0049 + AllTrim(cUser) + STR0051 // "Usuário: " # " não encontrado nos usuarios do Protheus."
												ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
												AdpLogEAI(3, "MATI120", ofwEAIObj, lRet)
												Return {lRet, ofwEAIObj}
											EndIf
										ElseIf Empty(cUserPar)
											lRet := .F. 
											cLogErro := ""
											ofwEAIObj:Activate()
											ofwEAIObj:setProp("ReturnContent")
											cLogErro := STR0045 // "Usuário comprador inválido. Verifique o parâmetro MV_SLMCOMP."
											ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
											AdpLogEAI(3, "MATI120", ofwEAIObj, lRet)
											Return {lRet, ofwEAIObj}
										Else
											cUser		:= RetCodUsr(cUserPar)

											If Empty(cUser)
												lRet := .F. 
												cLogErro := ""
												ofwEAIObj:Activate()
												ofwEAIObj:setProp("ReturnContent")
												cLogErro := STR0049 + AllTrim(cUserPar) + STR0050 // "Usuário: " # " não encontrado nos usuarios do Protheus. Verifique o parametro e respeite as letras maiusculas e minusculas."
												ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
												AdpLogEAI(3, "MATI120", ofwEAIObj, lRet)
												Return {lRet, ofwEAIObj}
											EndIf
										EndIf

										If !Empty(cUser)
											aAdd(aItemAux, {"C7_USER", cUser, Nil}) 
										Endif
									Endif
								EndIf

								aAdd(aItemAux, {"C7_ORIGEM","MSGEAI",Nil})

								If SC7->(ColumnPos("C7_APROPRM")) > 0 .And. oEAIObEt:getPropValue("TaskCostAssignmentDocument") != nil .And. !Empty( oEAIObEt:getPropValue("TaskCostAssignmentDocument") )
									cTpAprop := Alltrim(oEAIObEt:getPropValue("TaskCostAssignmentDocument"))
									AADD(aItemAux,{"C7_APROPRM",StrTran(cTpAprop,'0',''),NIL})
								Endif

								//Dedução
								If oItemAux:getPropValue("DeductionValue") != nil  .And. !Empty(oItemAux:getPropValue("DeductionValue"))
									If lRetDedFat
										aAdd(aItemAux, {"C7_DEDUCAO", Val(oItemAux:getPropValue("DeductionValue")), Nil})
									Endif
								Endif

								//Retenção
								If oItemAux:getPropValue("RetentionValue") != nil  .And. !Empty(oItemAux:getPropValue("RetentionValue"))
									If lRetDedFat
										aAdd(aItemAux, {"C7_RETENCA", Val(oItemAux:getPropValue("RetentionValue")), Nil})
									Endif
								Endif

								//Faturamento direto
								If oItemAux:getPropValue("DirectDeductionValue") != nil  .And. !Empty(oItemAux:getPropValue("DirectDeductionValue"))
									If lRetDedFat
										aAdd(aItemAux, {"C7_FATDIRE", Val(oItemAux:getPropValue("DirectDeductionValue")), Nil})
									Endif
								Endif

								aAdd(aItens, aClone(aItemAux))

								//Se não for array
								If oItemAux:getPropValue("ListOfApportionOrderItem") != nil .and. !Empty(oItemAux:getPropValue("ListOfApportionOrderItem"))

									oApportionOrderItem := oItemAux:getPropValue("ListOfApportionOrderItem")

									For nI2 := 1 To Len(oApportionOrderItem)
										//Atualiza objeto com a posição atual
										oItemRat := oApportionOrderItem[nI2]

										//Possui centro de custo informado
										If oItemRat:getPropValue("CostCenterInternalId") != nil .And. !Empty(oItemRat:getPropValue("CostCenterInternalId"))
											// Possui percentual informado
											If oItemRat:getPropValue("Percentual") != nil .And. !Empty(oItemRat:getPropValue("Percentual"))
												// O centro de Custo existe no de/para e na base
												aAux := IntCusInt(oItemRat:getPropValue("CostCenterInternalId"), cMarca)
												If !aAux[1]
													lRet := .F.
													cLogErro := ""
													ofwEAIObj:Activate()
													ofwEAIObj:setProp("ReturnContent")
													cLogErro := aAux[2] + STR0021 /*" Item "*/ + AllTrim(oItemAux:getPropValue("OrderItem")) + "."
													ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
													AdpLogEAI(3, "MATI120", ofwEAIObj, lRet)
													Return {lRet, ofwEAIObj}
												EndIf

												//Valida o Centro de Custo obtido
												aItemAux := IntVldCC(aAux[2][3], Date(), "MATI120")
												If !aItemAux[1]
													lRet := .F.
													cLogErro := ""
													ofwEAIObj:Activate()
													ofwEAIObj:setProp("ReturnContent")
													cLogErro := aItemAux[2] + STR0021 /*" Item "*/ + AllTrim(oItemAux:getPropValue("OrderItem")) + "."
													ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
													AdpLogEAI(3, "MATI120", ofwEAIObj, lRet)
													Return {lRet, ofwEAIObj}
												EndIf

												// Verifica se já existe o centro de custo para este item
												nI3 := aScan(aCCusto, {|x| RTrim(x[3]) == RTrim(aAux[2][3])})

												// Caso já exista o centro de custo para o item somar o %
												If nI3 > 0
													aCCusto[nI3][2] += Val(oItemRat:getPropValue("Percentual"))
												Else
													aAdd(aCCusto, {cItemSC7, Val(oItemRat:getPropValue("Percentual")), aAux[2][3]})
												EndIf
											Else
												lRet := .F.
												cLogErro := ""
												ofwEAIObj:Activate()
												ofwEAIObj:setProp("ReturnContent")
												cLogErro := STR0022 + cItemSC7 + "." //"Percentual de rateio inválido para o item "
												ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
												AdpLogEAI(3, "MATI120", ofwEAIObj, lRet)
												Return {lRet, ofwEAIObj}
											EndIf
										EndIf

										// Possui projeto informado
										If oItemRat:getPropValue("ProjectInternalId") != nil .And. !Empty(oItemRat:getPropValue("ProjectInternalId"))
											// O projeto possui um código válido?
											aAux := IntPrjInt(oItemRat:getPropValue("ProjectInternalId"), cMarca, cPrjVer) //Empresa/Filial/Projeto
											If !aAux[1]
												lRet := .F.
												cLogErro := ""
												ofwEAIObj:Activate()
												ofwEAIObj:setProp("ReturnContent")
												cLogErro := aAux[2] + STR0021 /*" Item "*/ + AllTrim(oItemAux:getPropValue("OrderItem")) + "."
												ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
												AdpLogEAI(3, "MATI120", ofwEAIObj, lRet)
												Return {lRet, ofwEAIObj}
											Else
												xAux := aAux[2][3]
											EndIf

											// Possui tarefa informada
											If oItemRat:getPropValue("TaskInternalId") != nil .And. !Empty(oItemRat:getPropValue("ProjectInternalId"))
												// A tarefa possui um código válido?
												aAux := IntTrfInt(oItemRat:getPropValue("TaskInternalId"), cMarca, cTrfVer) //Empresa/Filial/Projeto/Revisao/Tarefa
												If !aAux[1]
													lRet := .F.
													cLogErro := ""
													ofwEAIObj:Activate()
													ofwEAIObj:setProp("ReturnContent")
													cLogErro := aAux[2] + STR0021 /*" Item "*/ + AllTrim(oItemAux:getPropValue("OrderItem")) + "."
													ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
													AdpLogEAI(3, "MATI120", ofwEAIObj, lRet)
													Return {lRet, ofwEAIObj}
												EndIf
											Else
												lRet := .F.
												cLogErro := ""
												ofwEAIObj:Activate()
												ofwEAIObj:setProp("ReturnContent")
												cLogErro := STR0023 /*"Tarefa inválida para o item "*/ + cItemSC7 + "."
												ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
												AdpLogEAI(3, "MATI120", ofwEAIObj, lRet)
												Return {lRet, ofwEAIObj}
											EndIf

											// Possui quantidade informada
											If oItemRat:getPropValue("Quantity") != nil .And. !Empty(oItemRat:getPropValue("Quantity"))
												// Verifica se já existe o projeto e tarefa para o item
												nI4 := aScan(aProjeto, {|x| RTrim(x[1]) == RTrim(aAux[2][3]) .And. RTrim(x[3]) == RTrim(aAux[2][5])})

												// Caso já exista o projeto/tarefa somar a quantidade
												If nI4 > 0
													aProjeto[nI4][4] += Val(oItemRat:getPropValue("Quantity"))
												Else
													aAdd(aProjeto, {xAux, aAux[2][4], aAux[2][5], Val(oItemRat:getPropValue("Quantity")), Nil, cItemSC7, Nil})
												EndIf
											Else
												lRet := .F.
												cLogErro := ""
												ofwEAIObj:Activate()
												ofwEAIObj:setProp("ReturnContent")
												cLogErro := STR0024 /*"Quantidade de rateio inválido para o item "*/ + cItemSC7 + "."
												ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
												AdpLogEAI(3, "MATI120", ofwEAIObj, lRet)
												Return {lRet, ofwEAIObj}
											EndIf
										EndIf
									Next nI2
								Endif

								If Len(aCCusto) > 0
									// Monta o array com os itens do rateio de centro de custo agrupados por centro de custo
									aAdd(aItensRat, Array(2))
									aItensRat[nI][1] := cItemSC7
									aItensRat[nI][2] := {}

									For nI5 := 1 To Len(aCCusto)
										aAdd(aLinha, {"CH_FILIAL", xFilial("SCH"),                       Nil})
										aAdd(aLinha, {"CH_ITEMPD", aCCusto[nI5][1],                      Nil})
										aAdd(aLinha, {"CH_ITEM",   PadL(nI5, TamSx3("CH_ITEM")[1], "0"), Nil})
										aAdd(aLinha, {"CH_PERC",   aCCusto[nI5][2],                      Nil})
										aAdd(aLinha, {"CH_CC",     aCCusto[nI5][3],                      Nil})

										aAdd(aItensRat[nI][2], aClone(aLinha))
										aLinha := {}
									Next nI5
								Endif

								aCCusto := {}

								If Len(aProjeto) > 0
									// Monta o array com os itens do rateio de projeto agrupados por projeto/tarefa
									For nI5 := 1 To Len(aProjeto)
										aAdd(aLinha, {"AJ7_PROJET", PadR(aProjeto[nI5][1], TamSx3("AJ7_PROJET")[1]), Nil})
										aAdd(aLinha, {"AJ7_TAREFA", PadR(aProjeto[nI5][3], TamSx3("AJ7_TAREFA")[1]), Nil})
										aAdd(aLinha, {"AJ7_QUANT",  aProjeto[nI5][4],                                Nil})
										aAdd(aLinha, {"AJ7_ITEMPC", aProjeto[nI5][6],                       			Nil})
										aAdd(aLinha, {"AJ7_NUMPC", Iif(Empty(cNumPed),"cNumPCWS",cNumPed) , 			Nil})
										aAdd(aLinha, {"AJ7_REVISA", "0001",                                			Nil})

										nPosProd := aScan(aItens[nI], {|x| x[1] == "C7_PRODUTO"})
										If nPosProd > 0
											aAdd(aLinha, {"AJ7_COD", aItens[nI][nPosProd][2], Nil})
										EndIf

										aAdd(aItensPrj, aClone(aLinha))
										aLinha := {}
									Next nI5
								Endif

								aProjeto := {}

								/*If Len(aCCusto) > 0
									//Caso tenha rateio de centro de custo excluir o centro de custo do item para evitar erro
									nCount := aScan(aItens[nI], {|x| x[1] == "C7_CC"})
									If nCount > 0
										aDel(aItens[nI], nCount)
										aSize(aItens[nI], Len(aItens[nI]) - 1)
									EndIf
								EndIf*/
							Next nI
							// Rateio de desconto
							For nI := 1 To Len(aDescUnit)
								aDescUnit[nI][3] := Round(nDescTotal * aDescUnit[nI][2] / nValorTotal,TamSx3("C7_VLDESC")[2])

								nI2 := aScan(aItens[nI], {|x| x[1] == "C7_VLDESC"})

								If nI2 > 0
									aItens[nI][nI2][2] += aDescUnit[nI][3]
								Else
									aAdd(aItens[nI], {"C7_VLDESC", aDescUnit[nI][3], Nil})
								EndIf
							Next nI
						EndIf

						//Se não for array
						If oEAIObEt:getPropValue("ListOfCreditDocument") != nil .And. !Empty( oEAIObEt:getPropValue("ListOfCreditDocument") ) 
							If !Adiantamento(cCond)
								lRet    := .F.
								cLogErro := ""
								ofwEAIObj:Activate()
								ofwEAIObj:setProp("ReturnContent")
								cLogErro := STR0046 //"Para utilizar título de adiantamento a condição de pagamento do pedido deve ser do tipo adiantamento."
								ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
								AdpLogEAI(3, "MATI120", ofwEAIObj, lRet)
								Return {lRet, ofwEAIObj}
							Else

								oObjLtCred := oEAIObEt:getPropValue("ListOfCreditDocument")

								For nI := 1 To Len(oObjLtCred)
									//Atualiza objeto com a posição atual
									oItemAux := oObjLtCred[nI]

									//Adiantamentos
									If oItemAux:getPropValue("CreditDocumentInternalId") != nil .And. !Empty( oItemAux:getPropValue("CreditDocumentInternalId") )
										aAux := IntTPgInt(oItemAux:getPropValue("CreditDocumentInternalId"), cMarca, cTPgVer)

										If !aAux[1]
											lRet    := aAux[1]
											cLogErro := ""
											ofwEAIObj:Activate()
											ofwEAIObj:setProp("ReturnContent")
											cLogErro := aAux[2]
											ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
											AdpLogEAI(3, "MATI120", ofwEAIObj, lRet)
											Return {lRet, ofwEAIObj}
										EndIf
									Else
										lRet    := .F.
										cLogErro := ""
										ofwEAIObj:Activate()
										ofwEAIObj:setProp("ReturnContent")
										cLogErro := STR0047 //"O InternalID do título de adiantamento não foi informado."
										ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
										AdpLogEAI(3, "MATI120", ofwEAIObj, lRet)
										Return {lRet, ofwEAIObj}
									EndIf

									If oItemAux:getPropValue("Value") != nil .And. Empty( oItemAux:getPropValue("Value") )
										lRet    := .F.
										cLogErro := ""
										ofwEAIObj:Activate()
										ofwEAIObj:setProp("ReturnContent")
										cLogErro := STR0048 //"O valor a ser abatido no título de adiantamento não foi informado."
										ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
										AdpLogEAI(3, "MATI120", ofwEAIObj, lRet)
										Return {lRet, ofwEAIObj}
									EndIf

									aAdd(aLinha, {"FIE_FILIAL", xFilial("FIE"),                            Nil})
									aAdd(aLinha, {"FIE_CART",   "P",                                       Nil}) // Carteira pagar
									aAdd(aLinha, {"FIE_PEDIDO", "",                                        Nil}) // Não precisa, pois quem trata é a a120adiantamento()
									aAdd(aLinha, {"FIE_PREFIX", PadR(aAux[2][3], TamSX3("FIE_PREFIX")[1]), Nil})
									aAdd(aLinha, {"FIE_NUM",    PadR(aAux[2][4], TamSX3("FIE_NUM")[1]),    Nil})
									aAdd(aLinha, {"FIE_PARCEL", PadR(aAux[2][5], TamSX3("FIE_PARCEL")[1]), Nil})
									aAdd(aLinha, {"FIE_TIPO",   PadR(aAux[2][6], TamSX3("FIE_TIPO")[1]),   Nil})
									aAdd(aLinha, {"FIE_FORNEC", PadR(aAux[2][7], TamSX3("FIE_FORNEC")[1]), Nil})
									aAdd(aLinha, {"FIE_LOJA",   PadR(aAux[2][8], TamSX3("FIE_LOJA")[1]),   Nil})
									aAdd(aLinha, {"FIE_VALOR",  Val(oItemAux:getPropValue("Value")),                  Nil}) // Valor do pa que está vinculado ao pedido

									aAdd(aAdtPC, aClone(aLinha))
									aLinha := {}
								Next nI
							EndIf
						EndIf

					EndIf

					If ExistBlock("ITMT120")
						aRetPe := ExecBlock("ITMT120",.F.,.F.,{aCab,aItens,aItensRat,aItensPrj})
						If ValType(aRetPe) == "A" .And. Len(aRetPe) >0
							If ValType(aRetPe[1]) == "A"
								aCab := aClone(aRetPe[1])
							EndIf
							If ValType(aRetPe[2]) == "A"
								aItens := aClone(aRetPe[2])
							EndIf
							If ValType(aRetPe[3]) == "A"
								aItensRat := aClone(aRetPe[3])
							EndIf
							If ValType(aRetPe[4]) == "A"
								aItensPrj := aClone(aRetPe[4])
							EndIf
						EndIf
					EndIf

					If Empty( cLogErro )
						AdpLogEAI(4, nOpcx)
						Begin Transaction
							If nOpcx == 5
								MsExecAuto({|v,x,y,z| MATA120(v, x, y, z)}, 1, aCab, aItens, nOpcx)
							Else
								If Len(aItensRat) > 0
									MsExecAuto({|v,x,y,z,a,b,c,d| MATA120(v,x,y,z,a,b,c,d)}, 1, aCab, aItens, nOpcx, .F., aItensRat, aAdtPC)
								Else
									MsExecAuto({|v,x,y,z,a,b,c,d| MATA120(v,x,y,z,a,b,c,d)}, 1, aCab, aItens, nOpcx, .F., , aAdtPC)
								Endif
							EndIf

							// Se houve erros no processamento do MSExecAuto
							If lMsErroAuto
								aErroAuto := GetAutoGRLog()
								nErrSize := Len(aErroAuto)
								lRet := .F.

								cLogErro := ""
								For nI := 1 To nErrSize
									cLogErro += aErroAuto[nI]
								Next nI

								ofwEAIObj:Activate()
								ofwEAIObj:setProp("ReturnContent")
								ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
								AdpLogEAI(3, "MATI120", ofwEAIObj, lRet)

								//Desfaz a transacao
								DisarmTransaction()
								msUnlockAll()
							Else
								If Len(aItensPrj) > 0
									If nOpcx <> 5
										For n1Cnt := 1 To Len(aItensPrj)
											If (n2Cnt := aScan(aItensPrj[n1Cnt], {|x| x[1] == "AJ7_NUMPC"})) > 0
												aItensPrj[n1Cnt, n2Cnt, 2] := cNumPCWS
											EndIf
										Next n1Cnt
									Endif
								Else
									If nOpcX == 5
										aAdd(aLinha, {"AJ7_PROJET","", Nil})
										aAdd(aLinha, {"AJ7_TAREFA","", Nil})
										aAdd(aLinha, {"AJ7_QUANT",0,Nil})
										aAdd(aLinha, {"AJ7_ITEMPC","",Nil})
										aAdd(aLinha, {"AJ7_NUMPC",cNumPed,Nil})
										aAdd(aLinha, {"AJ7_REVISA","0001",Nil})

										aAdd(aItensPrj,aClone(aLinha))
									Endif
								Endif

								If Len(aItensPrj) > 0
									pmsWs120(AllTrim(Str(nOpcx)),aItensPrj)
								Endif

								If nOpcx == 3 //INSERT
									// Monta o InternalId com a variável cNumPCWS (número do pedido gerado)
									// Esta variável é povoada somente após a execução da Rotina Automática
									cValInt := IntPdCExt(/*Empresa*/, /*Filial*/, cNumPCWS, Nil, cPdCVer)[2]
									//Insere o registro na tabela XXF (de/para)
									CFGA070Mnt(cMarca, cAlias, cField, cValExt, cValInt, .F., 1)
								ElseIf nOpcx == 4 //UPDATE
									//Atualiza o registro na tabela XXF (de/para)
									CFGA070Mnt(cMarca, cAlias, cField, cValExt, cValInt, .F., 1)
								Else //DELETE
									//Exclui o registro na tabela XXF (de/para)
									CFGA070Mnt(cMarca, cAlias, cField, cValExt, cValInt, .T., 1)
								EndIf

								//Loop para manipular os Itens na tabela XXF (de/para)
								For nI := 1 To Len(aDePara)
									If nOpcx == 3 // INSERT
										cValIntI := IntPdCExt(/*Empresa*/, /*Filial*/, cNumPCWS, aDePara[nI][2], cPdCVer)[2]
										CFGA070Mnt(cMarca, aDePara[nI][3], aDePara[nI][4], aDePara[nI][1], cValIntI, .F., 1)
									ElseIf nOpcx == 4 // UPDATE
										cValIntI := IntPdCExt(/*Empresa*/, /*Filial*/, cNumPed, aDePara[nI][2], cPdCVer)[2]
										CFGA070Mnt(cMarca, aDePara[nI][3], aDePara[nI][4], aDePara[nI][1], cValIntI, .F., 1)
									Else // DELETE
										CFGA070Mnt(cMarca, aDePara[nI][3], aDePara[nI][4], aDePara[nI][1], aDePara[nI][2], .T., 1)
									EndIf
								Next nI

								// Monta o XML de retorno (CAPA)
								ofwEAIObj:Activate()
								ofwEAIObj:setProp("ReturnContent")
								ofwEAIObj:getPropValue("ReturnContent"):setProp("ListOfInternalID",{},'InternalId')
								nLtOfItID := 1
								ofwEAIObj:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[nLtOfItID]:setprop("Name","OrderInternalId")
								ofwEAIObj:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[nLtOfItID]:setprop("Origin",cValExt)
								If nOpcx == 3 // Insert
									ofwEAIObj:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[nLtOfItID]:setprop("Destination",IntPdCExt( , , cNumPCWS, Nil, cPdCVer)[2])
								Else
									ofwEAIObj:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[nLtOfItID]:setprop("Destination",IntPdCExt( , , aAux[2][3], Nil, cPdCVer)[2])
								EndIf
								For nI := 1 To Len(aDePara)
									nLtOfItID++
									ofwEAIObj:getPropValue("ReturnContent"):setProp("ListOfInternalID",{},'InternalId',,.T.)
									ofwEAIObj:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[nLtOfItID]:setprop("Name","ItemInternalId",,.T.)
									ofwEAIObj:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[nLtOfItID]:setprop("Origin",aDePara[nI][1],,.T.)
									If nOpcx == 3 // Insert
										ofwEAIObj:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[nLtOfItID]:setprop("Destination", IntPdCExt( , , cNumPCWS, aDePara[nI][2], cPdCVer)[2])
									ElseIf nOpcx == 4 // Update
										ofwEAIObj:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[nLtOfItID]:setprop("Destination", IntPdCExt( , , cNumPed, aDePara[nI][2], cPdCVer)[2])
									Else // Delete
										ofwEAIObj:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[nLtOfItID]:setprop("Destination", aDePara[nI][2])
									EndIf
								Next
							EndIf

						End Transaction
						MsUnlockAll()
					EndIF
				ElseIf AllTrim(oEAIObEt:getPropValue("OrderPurpose")) == "2"

					aAdd(aRet, FWIntegDef("MATA410", cTypeMessage, nTypeTrans, oEAIObEt))

					If ValType(aRet) == "A"
						If !Empty(aRet)
							lRet := aRet[1][1]
							cLogErro := ""
							ofwEAIObj:Activate()
							ofwEAIObj:setProp("ReturnContent")
							cLogErro := aRet[1][2]
							ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
							AdpLogEAI(3, "MATI120", ofwEAIObj, lRet)
						EndIf
					Endif
				Else
					lRet:= .F.
					cLogErro := ""
					ofwEAIObj:Activate()
					ofwEAIObj:setProp("ReturnContent")
					cLogErro := STR0025 // "Tipo de Pedido inválido!"
					ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
					AdpLogEAI(3, "MATI120", ofwEAIObj, lRet)
				EndIf
			Else
				lRet := .F.
				//cXmlRet := STR0026 // "Tipo de pedido não enviado."
				//Return {lRet, cXmlRet}
				cLogErro := ""
				ofwEAIObj:Activate()
				ofwEAIObj:setProp("ReturnContent")
				cLogErro := STR0026 // "Tipo de pedido não enviado."
				ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
				AdpLogEAI(3, "MATI120", ofwEAIObj, lRet)
			EndIf

		ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE
			//Faz o parser do XML de retorno em um objeto

			//Se não houve erros na resposta
			If Upper(oEAIObEt:getPropValue("ProcessingInformation"):getPropValue("Status")) == "OK"
				//Verifica se a marca foi informada
				If oEAIObEt:getHeaderValue("ProductName") !=  nil .And. !Empty( oEAIObEt:getHeaderValue("ProductName") )
					cMarca := Upper(oEAIObEt:getHeaderValue("ProductName"))
				Else
					lRet := .F.
					cLogErro := ""
					ofwEAIObj:Activate()
					ofwEAIObj:setProp("ReturnContent")
					cLogErro := STR0028 // "Erro no retorno. O Product é obrigatório!"
					ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
					AdpLogEAI(3, "MATI120", ofwEAIObj, lRet)
					Return {lRet, ofwEAIObj}
				EndIf

				oObLisOfIt := oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")

				For nI := 1 To Len( oObLisOfIt )
					cNameInternalId := oObLisOfIt[nI]:getPropValue('Name')
					aAdd(aDePara, Array(3))

					//Verifica se o InternalId foi informado
					If oObLisOfIt[nI]:getPropValue('Origin') != nil .And. !Empty( oObLisOfIt[nI]:getPropValue('Origin') )
						//Não armazena Rateio
						If 'ORDER' == AllTrim(Upper(cNameInternalId)) .Or. 'ITEM' == AllTrim(Upper(cNameInternalId))
							aDePara[nI][1] := oObLisOfIt[nI]:getPropValue('Origin')
						EndIf
					Else
						lRet := .F.
						cLogErro := ""
						ofwEAIObj:Activate()
						ofwEAIObj:setProp("ReturnContent")
						cLogErro := STR0029 // "Erro no retorno. O OriginalInternalId é obrigatório!"
						ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
						AdpLogEAI(3, "MATI120", ofwEAIObj, lRet)
						Return {lRet, ofwEAIObj}
					EndIf

					//Verifica se o código externo foi informado
					If oObLisOfIt[nI]:getPropValue('Destination') != nil .And. !Empty( oObLisOfIt[nI]:getPropValue('Destination') )
						//Não armazena Rateio
						If 'ORDER' == AllTrim(Upper(cNameInternalId)) .Or. 'ITEM' == AllTrim(Upper(cNameInternalId))
							aDePara[nI][2] := oObLisOfIt[nI]:getPropValue('Destination')
						EndIf
					Else
						lRet := .F.
						cLogErro := ""
						ofwEAIObj:Activate()
						ofwEAIObj:setProp("ReturnContent")
						cLogErro := STR0030 // "Erro no retorno. O DestinationInternalId é obrigatório!"
						ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
						AdpLogEAI(3, "MATI120", ofwEAIObj, lRet)
						Return {lRet, ofwEAIObj}
					EndIf

					//Envia os valores de InternalId e ExternalId para o Log
					AdpLogEAI(3, "cValInt" + Str(nI) + ": ", aDePara[nI][1]) // InternalId
					AdpLogEAI(3, "cValExt" + Str(nI) + ": ", aDePara[nI][2]) // ExternalId

					If 'ORDER' $ AllTrim(Upper(cNameInternalId))
						aDePara[nI][3] := cField
					ElseIf 'ITEM' $ AllTrim(Upper(cNameInternalId))
						aDePara[nI][3] := "C7_ITEM"
					EndIf

				Next nI

				//Obtém a mensagem original enviada
				For nI := 1 To Len(aDePara)
					If Upper(AllTrim(oEAIObEt:getPropValue("ReceivedMessage"):getPropValue("Event"))) == "UPSERT"
						//Insere / Atualiza o registro na tabela XXF (de/para)
						CFGA070Mnt(cMarca, cAlias, aDePara[nI][3], aDePara[nI][2], aDePara[nI][1], .F., 1)
					ElseIf Upper(AllTrim(oEAIObEt:getPropValue("ReceivedMessage"):getPropValue("Event"))) == "DELETE"
						//Exclui o registro na tabela XXF (de/para)
						CFGA070Mnt(cMarca, cAlias, aDePara[nI][3], aDePara[nI][2], aDePara[nI][1], .T., 1)
					Else
						lRet := .F.
						cLogErro := ""
						ofwEAIObj:Activate()
						ofwEAIObj:setProp("ReturnContent")
						cLogErro := STR0032 // "Evento do retorno inválido!"
						ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
						AdpLogEAI(3, "MATI120", ofwEAIObj, lRet)
						Return {lRet, ofwEAIObj}
					EndIf
				Next nI

			Else
				//erro
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
				AdpLogEAI(3, "MATI120", ofwEAIObj, lRet)
			EndIf
		ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
			Return {.T., '2.000|3.000|3.001|3.002|3.004|3.005|3.006|3.007|4.003'}
		EndIf
		// Mensagem de Saída
	ElseIf nTypeTrans == TRANS_SEND

		Do Case
		Case Inclui
			AdpLogEAI(4, 3)
		Case Altera
			AdpLogEAI(4, 4)
		OtherWise
			AdpLogEAI(4, 5)
			cEvent := "delete"
		EndCase
		cC7Num := Iif(Type("cA120Num")=="C",cA120Num,SC7->C7_NUM)

		SC7->(dbSetOrder(1))
		SC7->(dbSeek(xFilial("SC7")+cC7Num))

		ofwEAIObj:Activate()

		ofwEAIObj:setEvent(cEvent)
		ofwEAIObj:setprop("InternalId",IntPdCExt(/*Empresa*/, /*Filial*/, SC7->C7_NUM, Nil, cPdCVer)[2])
		ofwEAIObj:setprop("OrderPurpose","1")
		ofwEAIObj:setprop("CompanyId",cEmpAnt)
		ofwEAIObj:setprop("BranchId",cFilAnt)
		ofwEAIObj:setprop("CompanyInternalId",cEmpAnt + '|' + RTrim(cFilAnt))
		ofwEAIObj:setprop("OrderId",RTrim( SC7->C7_NUM))
		ofwEAIObj:setprop("CustomerInternalId",IntForExt(, , SC7->C7_FORNECE, SC7->C7_LOJA, cVenVer)[2])

		If Len( Separa(SC7->C7_ACCNUM,"|") ) > 1
			ofwEAIObj:setprop("contractnumber",Separa( SC7->C7_ACCNUM , "|" )[1] + "|" + Separa( SC7->C7_ACCNUM , "|" )[2])
		EndIf

		ofwEAIObj:setprop("CustomerCode",RTrim(SC7->C7_FORNECE))

		If SA2->(dbSeek(xFilial("SC7") + SC7->C7_FORNECE + SC7->C7_LOJA))
			ofwEAIObj:setprop("CustomerGovInfo",(SA2->A2_CGC))
		EndIf

		ofwEAIObj:setprop("CurrencyCode", StrZero(SC7->C7_MOEDA,TamSX3("CTO_MOEDA")[1],0))

		If lMktPlace
			ofwEAIObj:setprop("CurrencyId", '|' + '|' + StrZero(SC7->C7_MOEDA,TamSX3("CTO_MOEDA")[1],0))
		Else
			ofwEAIObj:setprop("CurrencyId", C40MontInt(,StrZero(SC7->C7_MOEDA,TamSX3("CTO_MOEDA")[1],0)))
		Endif

		ofwEAIObj:setprop("CurrencyRate", RTrim(cValToChar(SC7->C7_TXMOEDA)))
		ofwEAIObj:setprop("PaymentTermCode",RTrim(SC7->C7_COND))
		ofwEAIObj:setprop("PaymentConditionInternalId",IntConExt(, , SC7->C7_COND, cConVer)[2])
		ofwEAIObj:setprop("RegisterDate",INTDTANO(SC7->C7_EMISSAO))
		ofwEAIObj:setprop("UserInternalId",SC7->C7_USER)

		If AllTrim(SC7->C7_FREPPCC) == "C"
			ofwEAIObj:setprop("FreightType",'1')
		ElseIf AllTrim(SC7->C7_FREPPCC) == "F"
			ofwEAIObj:setprop("FreightType",'2')
		Else
			ofwEAIObj:setprop("FreightType",'3')
		Endif

		If lMktPlace
			ofwEAIObj:setprop("OTHER")
			ofwEAIObj:getPropValue("OTHER"):setprop("ADDFIELDS")
			ofwEAIObj:getPropValue("OTHER"):getPropValue("ADDFIELDS"):setprop("ADDFIELD")
			ofwEAIObj:getPropValue("OTHER"):getPropValue("ADDFIELDS"):getPropValue("ADDFIELD"):setprop("field","TipoOrigem")
			ofwEAIObj:getPropValue("OTHER"):getPropValue("ADDFIELDS"):getPropValue("ADDFIELD"):setprop("value", QtType())

			//--------------------------------------
			// Ponto de entrada para adicionar dados
			// ao cabecalho do pedido de compra
			//--------------------------------------
			If ExistBlock("MTI120OPC")
				cJson := ExecBlock("MTI120OPC",.F.,.F.,{cEvent, ofwEAIObj:getPropValue("OTHER"):getPropValue("ADDFIELDS"):getJSON()})
				If ValType( cJson ) == "C" .And. !( Empty( cJson ) )
					ofwEAIObj:getPropValue("OTHER"):getPropValue("ADDFIELDS"):loadJson(cJson)
				Endif
			EndIf	

		EndIf

		cAliasTMP:=GetNextAlias()

		cQuery := "SELECT C7_NUM, C7_ITEM, C7_PRODUTO, C7_UM, C7_DESCRI, C7_QUANT, C7_PRECO, C7_TOTAL, C7_CC, C7_CONTA, C7_DATPRF, C7_VLDESC, C7_VALFRE"
		cQuery += ", C7_SEGURO, C7_OBS, C7_LOCAL, C7_FILIAL, C7_FORNECE, C7_LOJA, C7_RATEIO, C7_QUJE, C7_ENCER, C7_RESIDUO, C7_NUMSC, C7_ITEMSC"
		cQuery += " FROM " + RetSqlName("SC7")
		cQuery += " WHERE C7_FILIAL = '" + xFilial("SC7") + "'"
		cQuery += " AND C7_NUM = '" + SC7->C7_NUM + "'"
		cQuery += " AND D_E_L_E_T_ = ''"
		cQuery += " ORDER BY C7_ITEM"
		cQuery := ChangeQuery(cQuery)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTMP,.T.,.T.)
		If Select(cAliasTMP) > 0
			(cAliasTMP)->(dbGoTop())
			While (cAliasTMP)->(!EOF())
				SC7->(dbSetOrder(1))
				SC7->(DbSeek(xFilial("SC7")+(cAliasTmp)->C7_NUM+(cAliasTmp)->C7_ITEM))

				oObjItem := ofwEAIObj:setprop('SalesOrderItens',{},'Item',,.T.)
				nCtItem := Len( oObjItem )

				oObjItem[nCtItem]:setprop("CompanyId", cEmpAnt)
				oObjItem[nCtItem]:setprop("BranchId", xFilial(cAlias))
				oObjItem[nCtItem]:setprop("OrderId", (cAliasTmp)->C7_NUM)
				oObjItem[nCtItem]:setprop("OrderItem", (cAliasTmp)->C7_ITEM)
				oObjItem[nCtItem]:setprop("InternalId", IntPdCExt(/*Empresa*/, /*Filial*/, (cAliasTMP)->C7_NUM, (cAliasTMP)->C7_ITEM, cPdCVer)[2])
				oObjItem[nCtItem]:setprop("ItemCode", RTrim((cAliasTmp)->C7_PRODUTO))
				If lMktPlace
					oObjItem[nCtItem]:setprop("ItemInternalId", cEmpAnt +"|"+ RTrim(xFilial("SB1")) +"|"+ RTrim((cAliasTmp)->C7_PRODUTO))
				Else
					oObjItem[nCtItem]:setprop("ItemInternalId", IntProExt(, , (cAliasTmp)->C7_PRODUTO, cPrdVer)[2])
				Endif
				oObjItem[nCtItem]:setprop("contractnumber", SC7->C7_ACCITEM)
				oObjItem[nCtItem]:setprop("ItemDescription", _NoTags(RTrim((cAliasTmp)->C7_DESCRI)))
				oObjItem[nCtItem]:setprop("Quantity", RTrim(cValToChar((cAliasTmp)->C7_QUANT)))
				oObjItem[nCtItem]:setprop("QuantityReached", RTrim(cValToChar((cAliasTmp)->C7_QUJE)))
				oObjItem[nCtItem]:setprop("UnityPrice", RTrim(cValToChar((cAliasTmp)->C7_PRECO)))
				oObjItem[nCtItem]:setprop("TotalPrice", RTrim(cValToChar((cAliasTmp)->C7_TOTAL)))
				If Empty((cAliasTmp)->C7_CC)
					oObjItem[nCtItem]:setprop("CostCenterCode", '')
					oObjItem[nCtItem]:setprop("CostCenterInternalId", '')
				Else
					oObjItem[nCtItem]:setprop("CostCenterCode", RTrim((cAliasTmp)->C7_CC))
					oObjItem[nCtItem]:setprop("CostCenterInternalId", IntCusExt(, , (cAliasTmp)->C7_CC, cCusVer)[2])
				EndIf
				oObjItem[nCtItem]:setprop("DeliveryDate", INTDTANO((cAliasTmp)->C7_DATPRF))
				oObjItem[nCtItem]:setprop("ItemDiscounts",{})
				oObjItem[nCtItem]:getPropValue("ItemDiscounts")[1]:setprop("ItemDiscount", RTrim(cValToChar((cAliasTmp)->C7_VLDESC)))
				oObjItem[nCtItem]:setprop("FreightValue", RTrim(cValToChar((cAliasTmp)->C7_VALFRE)))
				oObjItem[nCtItem]:setprop("InsuranceValue", RTrim(cValToChar((cAliasTmp)->C7_SEGURO)))
				oObjItem[nCtItem]:setprop("itemunitofmeasure", RTrim((cAliasTmp)->C7_UM))
				oObjItem[nCtItem]:setprop("UnitOfMeasureInternalId", IntUndExt(, , (cAliasTmp)->C7_UM, cUndVer)[2])
				oObjItem[nCtItem]:setprop("WarehouseInternalId", IntLocExt(, , (cAliasTmp)->C7_LOCAL, cLocVer)[2])
				oObjItem[nCtItem]:setprop("observation", _NoTags(RTrim((cAliasTmp)->C7_OBS)))

				If !Empty((cAliasTmp)->C7_NUMSC)
					oObjItem[nCtItem]:setprop("RequestItemInternalId", IntSCoExt(/*cEmpresa*/, /*cFilial*/, (cAliasTmp)->C7_NUMSC, (cAliasTmp)->C7_ITEMSC, cSCoVer)[2])
				Else
					oObjItem[nCtItem]:setprop("RequestItemInternalId", '')
				Endif
				If lMktPlace
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Local de entrega das mercadorias |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					oObjItem[nCtItem]:SetProp("CROSSDOCKING")
					oObjItem[nCtItem]:GetPropValue("CROSSDOCKING"):SetProp("CROSSDOCKING_ITEM")
					oObjItem[nCtItem]:GetPropValue("CROSSDOCKING"):GetPropValue("CROSSDOCKING_ITEM"):setprop("dhinidelivery", INTDTANO(SC7->C7_DATPRF)+"T00:00:00")
					oObjItem[nCtItem]:GetPropValue("CROSSDOCKING"):GetPropValue("CROSSDOCKING_ITEM"):setprop("dhfindelivery", INTDTANO(SC7->C7_DATPRF)+"T23:59:00")
					oObjItem[nCtItem]:GetPropValue("CROSSDOCKING"):GetPropValue("CROSSDOCKING_ITEM"):setprop("quantdelivery", AllTrim(Str(SC7->(C7_QUANT-C7_QUJE))))
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Unidade de Medida do Item do Ped.|
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cUnidMed := A120IUnMed(AllTrim(SC7->C7_UM))
					If !Empty(cUnidMed)
						oObjItem[nCtItem]:GetPropValue("CROSSDOCKING"):GetPropValue("CROSSDOCKING_ITEM"):setprop("mensuunit", cUnidMed)
					EndIf
					oObjItem[nCtItem]:GetPropValue("CROSSDOCKING"):GetPropValue("CROSSDOCKING_ITEM"):setprop("orderline", SC7->C7_ITEM)
					oObjItem[nCtItem]:SetProp("LISTOFTAXESITEM")
					oObjItem[nCtItem]:GetPropValue("LISTOFTAXESITEM"):SetProp("VALUESANDTAXES")
					oObjItem[nCtItem]:GetPropValue("LISTOFTAXESITEM"):GetPropValue("VALUESANDTAXES"):SetProp("tpvalue", '1' )
					oObjItem[nCtItem]:GetPropValue("LISTOFTAXESITEM"):GetPropValue("VALUESANDTAXES"):SetProp("tpreasondescandtax", '1' )
					oObjItem[nCtItem]:GetPropValue("LISTOFTAXESITEM"):GetPropValue("VALUESANDTAXES"):SetProp("valuedescandtaxes", '1' )
				EndIf

				// Integração com o TOTVS Obras e Projetos
				If IsIntegTop()
					aRateio := RatPC((cAliasTmp)->C7_FILIAL + (cAliasTmp)->C7_NUM + (cAliasTmp)->C7_ITEM) 

					If !Empty(aRateio)
						For nI := 1 To Len(aRateio)
							oObjItem[nCtItem]:setprop('ListOfApportionOrderItem',{},'ApportionOrderItem')
							oObjItem[nCtItem]:getPropValue("ListOfApportionOrderItem")[nI]:setprop("InternalId", IntPdCExt(/*Empresa*/, /*Filial*/, (cAliasTMP)->C7_NUM, (cAliasTMP)->C7_ITEM, cPdCVer)[2] + '|' + RTrim(cValToChar(nI)))
							oObjItem[nCtItem]:getPropValue("ListOfApportionOrderItem")[nI]:setprop("DepartamentCode", '')
							oObjItem[nCtItem]:getPropValue("ListOfApportionOrderItem")[nI]:setprop("DepartamentInternalId", '')
							If Empty(aRateio[nI][1])
								oObjItem[nCtItem]:getPropValue("ListOfApportionOrderItem")[nI]:setprop("CostCenterInternalId", '')
							Else
								oObjItem[nCtItem]:getPropValue("ListOfApportionOrderItem")[nI]:setprop("CostCenterInternalId", IntCusExt(, , aRateio[nI][1], cCusVer)[2])
							EndIf
							If Empty((cAliasTMP)->C7_CONTA)
								oObjItem[nCtItem]:getPropValue("ListOfApportionOrderItem")[nI]:setprop("AccountantAcountInternalId", '')
							Else
								oObjItem[nCtItem]:getPropValue("ListOfApportionOrderItem")[nI]:setprop("AccountantAcountInternalId", cEmpAnt + "|" + xFilial("CT1") + "|" + AllTrim(aRateio[nI][2]))
							EndIf
							If Empty(aRateio[nI][6])	//Codigo do Projeto
								oObjItem[nCtItem]:getPropValue("ListOfApportionOrderItem")[nI]:setprop("ProjectInternalId", '')
							Else
								oObjItem[nCtItem]:getPropValue("ListOfApportionOrderItem")[nI]:setprop("ProjectInternalId", IntPrjExt(, , aRateio[nI][6], cPrjVer)[2])
							EndIf
							oObjItem[nCtItem]:getPropValue("ListOfApportionOrderItem")[nI]:setprop("SubProjectInternalId", '')
							If Empty(aRateio[nI][7])	//Codigo da Tarefa
								oObjItem[nCtItem]:getPropValue("ListOfApportionOrderItem")[nI]:setprop("TaskInternalId", '')
								oObjItem[nCtItem]:getPropValue("ListOfApportionOrderItem")[nI]:setprop("Value", 0)
								oObjItem[nCtItem]:getPropValue("ListOfApportionOrderItem")[nI]:setprop("Quantity", 0)
							Else
								oObjItem[nCtItem]:getPropValue("ListOfApportionOrderItem")[nI]:setprop("TaskInternalId", IntTrfExt(, , aRateio[nI][6], '0001', aRateio[nI][7], cTrfVer)[2])
								oObjItem[nCtItem]:getPropValue("ListOfApportionOrderItem")[nI]:setprop("Value",RTrim(cValToChar(aRateio[nI][8] * (cAliasTmp)->C7_PRECO)))
								oObjItem[nCtItem]:getPropValue("ListOfApportionOrderItem")[nI]:setprop("Quantity", cValToChar(aRateio[nI][8]))
							EndIf
							oObjItem[nCtItem]:getPropValue("ListOfApportionOrderItem")[nI]:setprop("Percentual", cValToChar(aRateio[nI][5]))
						Next nI

					EndIf
				Else
					//Rateio por Centro de Custo
					SCH->(DbSetOrder(1))
					If SCH->(DbSeek(xFilial(cAlias) + (cAliasTmp)->C7_NUM + (cAliasTmp)->C7_FORNECE + (cAliasTmp)->C7_LOJA + (cAliasTmp)->C7_ITEM))
						nI := 1

						While SCH->(!EOF() .And. SCH->CH_FILIAL + SCH->CH_PEDIDO + SCH->CH_FORNECE + SCH->CH_LOJA + SCH->CH_ITEMPD == xFilial(cAlias) + (cAliasTmp)->C7_NUM + (cAliasTmp)->C7_FORNECE + (cAliasTmp)->C7_LOJA + (cAliasTmp)->C7_ITEM )
							oObjItem[nCtItem]:setprop('ListOfApportionOrderItem',{},'ApportionOrderItem')
							oObjItem[nCtItem]:getPropValue("ListOfApportionOrderItem")[nI]:setprop("InternalId", IntPdCExt(/*Empresa*/, /*Filial*/, (cAliasTMP)->C7_NUM, (cAliasTMP)->C7_ITEM, cPdCVer)[2] + '|' + RTrim(cValToChar(nI)))
							oObjItem[nCtItem]:getPropValue("ListOfApportionOrderItem")[nI]:setprop("CostCenterInternalId", IntCusExt(, , SCH->CH_CC, cCusVer)[2])
							oObjItem[nCtItem]:getPropValue("ListOfApportionOrderItem")[nI]:setprop("AccountantAcountInternalId", cEmpAnt + "|" + xFilial("CT1") + "|" + AllTrim(SCH->CH_CONTA))
							oObjItem[nCtItem]:getPropValue("ListOfApportionOrderItem")[nI]:setprop("Percentual", RTrim(cValToChar(SCH->CH_PERC)))

							nI ++
							SCH->(DbSkip())
						EndDo

					EndIf
				EndIf

				If lMktPlace
					SC7->(dbSetOrder(1))
					If SC7->(DbSeek(xFilial("SC7")+(cAliasTmp)->C7_NUM+(cAliasTmp)->C7_ITEM))
						RecLock("SC7")
						SC7->C7_ACCPROC := "1"
						MsUnlock()
					EndIf
				EndIf

				(cAliasTmp)->(dbSkip())
			EndDo

			(cAliasTMP)->(dbCloseArea())
		EndIf

	EndIf

	AdpLogEAI(5, "MATI120", ofwEAIObj, lRet)

Return {lRet, ofwEAIObj}

// --------------------------------------------------------------------------------------
/*/{Protheus.doc} getPType
Faz o de/para do Tipo de Frete

@param   cTipo      Tipo de Produto
@param   nTypeTrans Tipo da transação

@author  Leandro Luiz da Cruz
@version P11
@since   26/04/2013
@return  cResult Variavel com o valor obtido
/*/
// --------------------------------------------------------------------------------------
Static Function getTpFre(cTipo, nTypeTrans)
	Local cResult := ""

	If nTypeTrans == TRANS_RECEIVE
		Do Case
		Case cTipo == "1"
			cResult := "CIF"
		Case cTipo == "2"
			cResult := "FOB"
		Case cTipo == "3"
			cResult := "SFT"
		EndCase
	/*ElseIf nTypeTrans == TRANS_SEND
		Do Case
		Case cTipo == "CIF"
			cResult := "1"
		Case cTipo == "FOB"
			cResult := "2"
		Case cTipo == "STF"
			cResult := "3"
		EndCase*/
	EndIf
Return cResult

//-------------------------------------------------------------------
/*/{Protheus.doc} RatPC
Recebe a chave de busca do Pedido de Compra e monta o rateio.

@author  Leandro Luiz da Cruz
@version P11
@since   13/05/2013

@return aResult
/*/
//-------------------------------------------------------------------
Static Function RatPC(cChave)
	Local aResult  := {}
	Local aPrjtTrf := {}
	Local aCntrCst := {}
	Local nI       := 0
	Local cChaveCC := ""
	Local aAreaSC7 := SC7->(GetArea())
	Local aAreaAJ7 := AJ7->(GetArea())
	Local aAreaSCH := SCH->(GetArea())

	AJ7->(dbSetOrder(2)) // Rateio por Projeto/Tarefa   - AJ7_FILIAL+AJ7_NUMPC+AJ7_ITEMPC+AJ7_PROJET+AJ7_REVISA+AJ7_TAREFA
	SCH->(dbSetOrder(1)) // Rateios por Centro de Custo - CH_FILIAL+CH_PEDIDO+CH_FORNECE+CH_LOJA+CH_ITEMPD+CH_ITEM

	//Povoa o array de Projeto
	If AJ7->(dbSeek(cChave))
		While AJ7->(!EOF()) .And. cChave == AJ7->AJ7_FILIAL + AJ7->AJ7_NUMPC + AJ7->AJ7_ITEMPC
			aAdd(aPrjtTrf, Array(4))
			nI++
			aPrjtTrf[nI][1] := AJ7->AJ7_PROJET
			aPrjtTrf[nI][2] := AJ7->AJ7_REVISA
			aPrjtTrf[nI][3] := AJ7->AJ7_TAREFA
			aPrjtTrf[nI][4] := AJ7->AJ7_QUANT
			AJ7->(dbSkip())
		EndDo
	EndIf

	nI := 0
	cChaveCC := AllTrim((cAliasTmp)->C7_FILIAL + (cAliasTmp)->C7_NUM + (cAliasTmp)->C7_FORNECE + (cAliasTmp)->C7_LOJA + (cAliasTmp)->C7_ITEM) 

	//Povoa o array de Centro de Custo
	If Upper((cAliasTmp)->C7_RATEIO) == '1' //Possui rateio de centro de custo
		If SCH->(dbSeek(cChaveCC))
			While SCH->(!EOF()) .And. SCH->CH_FILIAL + SCH->CH_PEDIDO + SCH->CH_FORNECE + SCH->CH_LOJA + SCH->CH_ITEMPD == cChaveCC

				aAdd(aCntrCst, Array(5))
				nI++
				aCntrCst[nI][1] := SCH->CH_CC
				aCntrCst[nI][2] := SCH->CH_CONTA
				aCntrCst[nI][3] := SCH->CH_ITEMCTA
				aCntrCst[nI][4] := SCH->CH_CLVL
				aCntrCst[nI][5] := SCH->CH_PERC
				SCH->(dbSkip())
			EndDo
		EndIf
	EndIf

	//Se não possui rateio de centro de custo buscar dados do item
	If Len(aCntrCst) == 0
		SC7->(dbSetOrder(1)) //C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN

		If SC7->(dbSeek(cChave))
			aAdd(aCntrCst, {SC7->C7_CC, SC7->C7_CONTA, SC7->C7_ITEMCTA, SC7->C7_CLVL, 100})
		EndIF
	EndIf

	aResult := IntRatPrjCC(aCntrCst, aPrjtTrf)

	RestArea(aAreaSC7)
	RestArea(aAreaAJ7)
	RestArea(aAreaSCH)
Return aResult

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDePara
Função para tratamento do de/para de registros da SA7

@param   cValInt InternalID pai

@author  Leandro Luiz da Cruz
@version P11
@since   03/07/2013
@return  aResult Array contendo no primeiro parâmetro o valor do
         InternalId de origem e no segundo parâmetro o InternalId
         de destino.
/*/
//-------------------------------------------------------------------
Static Function GetDePara(cRefer, cChave, cVersao)
	Local aResult  := {}
	Local cValInt  := ""
	Local cValExt  := ""
	Local aAreaAnt := GetArea()

	DbSelectArea("SC7")
	SC7->(DbSetOrder(1))

	If SC7->(DbSeek(cChave))
		While SC7->(!EOF()) .And. xFilial("SC7") + SC7->C7_NUM == cChave
			cValInt := IntPdCExt(/*Empresa*/, /*Filial*/, SC7->C7_NUM, SC7->C7_ITEM, cVersao)[2]
			cValExt := RTrim(CFGA070Ext(cRefer, "SC7", "C7_ITEM", cValInt))
			aAdd(aResult, {cValExt, cValInt, "SC7", "C7_ITEM"})
			SC7->(DbSkip())
		EndDo
	EndIf

	RestArea(aAreaAnt)
Return aResult

//--------------------------------------------------------------------
/*/{Protheus.doc} Adiantamento
Recebe uma condição de pagamento e retorna se ela é do tipo adiantamento.

@param   cCond Código da condição de pagamento.

@author  Mateus Gustavo de Freitas e Silva
@version P11
@since   10/12/2013
@return  cResult Valor lógico indicando se a condição de pagamento é do
          tipo adiantamento.
/*/
//--------------------------------------------------------------------
Static Function Adiantamento(cCond)
	Local cResult    := .F.
	Local cE4_CTRADT := ""

	cE4_CTRADT := Posicione("SE4", 1, xFilial("SE4") + PadR(cCond, TamSX3("E4_CODIGO")[1]), "E4_CTRADT")

	If cE4_CTRADT == "1"
		cResult := .T.
	EndIf
Return cResult

//-------------------------------------------------------------------
/*{Protheus.doc} QtType
	Retorna o tipo da cotação que gerou o pedido
	"1" - Leilão Reverso
	"2" - Cotação Normal
	
	@author	Flávio Teixeira Lopes
	@version	P11 / P12
	@since	03/07/2014
*/
//-------------------------------------------------------------------

Static Function QtType()
	Local aArea:= GetArea()
	Local cRet:=""

	If !Empty(SC7->C7_NUMCOT)
		SC8->(dbSetOrder(1))
		If SC8->(dbSeek(xFilial("SC8")+SC7->C7_NUMCOT))
			If !Empty(SC8->C8_ACCNUM)
				cRet := AllTrim(STRTOKARR(SC8->C8_ACCNUM,'|')[2])
			Endif
		Endif
	Endif

	RestArea(aArea)
Return cRet

/*/{Protheus.doc} IntChcEmp
Função que retorna a filial do registro recebido.
O RM permite estar logado em uma filial no contexto e manipular registros
de outras filiais. Neste caso o EAI utiliza a filial do Messageinformation
(contexto) para logar no Protheus e esta função altera a filial corrente
para a filial do registro.
No execauto dos formulários MVC não informamos o código da filial. Ele
utiliza a filial logada.
@type function
@version P12 
@author TOTVS
@since 23/05/2025
@param oEAIObEt, object, Objeto JSON
@param cAlias, character, Alias da tabela do cadastro
@param cProduto, character, Produto da integração
@return Array, aEmpresas Valor booleano indicando se o de/para de empresa
         foi informado corretamente e a filial a ser utilizada no cadastro.         
         Realizado ajuste para trabalhar com objeto JSON
/*/
Static Function IntChcEmp(oEAIObEt, cAlias, cProduto)

	Local aFilialP := {}
	Local cEmp     := ""
	Local cFil     := ""
	Local cEmpProt := ""
	Local cFilProt := ""
	Local lLog     := FindFunction("AdpLogEAI")

	If oEAIObEt:getPropValue("CompanyId") != nil .And. !Empty( oEAIObEt:getPropValue("CompanyId") )
		cEmp := oEAIObEt:getPropValue("CompanyId")
	EndIf

	If oEAIObEt:getPropValue("BranchId") != nil .And. !Empty( oEAIObEt:getPropValue("BranchId") )
		cFil := oEAIObEt:getPropValue("BranchId")
	EndIf

	// Se o cadastro é compartilhado a nível de filial ou a nível de empresa no RM
	// As tags CompanyID e BranchId podem vir vazias
	If Empty(cEmp)
		If lLog
			AdpLogEAI(2, "Empresa compartilhada." + Chr(10) + "Tag CompanyId do BusinessContent veio vazia.") //"Empresa compartilhada." "Tag CompanyId do BusinessContent veio vazia."
		EndIf
	EndIf

	If Empty(cFil)
		If lLog
			AdpLogEAI(2, "Filial compartilhada." + Chr(10) + "Tag BranchId do BusinessContent veio vazia.") //"Filial compartilhada." "Tag BranchId do BusinessContent veio vazia."
		EndIf
	EndIf

	If Empty(cEmp) .Or. Empty(cFil)
		aAdd(aFilialP, .T.)
		aAdd(aFilialP, cFilProt)
		Return aFilialP
	EndIf

	aFilialP := FWEAIEMPFIL(cEmp, cFil, UPPER(cProduto))

	If Empty(aFilialP)
		If lLog
			AdpLogEAI(2, "Empresa/Filial " + cEmp + "/" + cFil + " recebida no BusinessContent não esta cadastrada no de/para para o produto " + cProduto + ".") //"Empresa/Filial " " recebida no BusinessContent não esta cadastrada no de/para para o produto "
		EndIf
		cEmpProt := cEmpAnt
		cFilProt := cFilAnt
	Else
		cEmpProt := aFilialP[1]
		cFilProt := aFilialP[2]
	EndIf

	If cEmpProt != cEmpAnt
		If lLog
			AdpLogEAI(2, "Empresa" + " " + cEmpProt + " recebida no BusinessContent é diferente da empresa " + cEmpAnt + " enviada no MessageInformation.") //"Empresa" " recebida no BusinessContent é diferente da empresa " " enviada no MessageInformation."
		EndIf

		cEmpProt := cEmpAnt
		cFilProt := cFilAnt
	EndIf

	aFilialP := {}

	If cFilAnt != cFilProt
		If lLog
			AdpLogEAI(2, "Alteração de filial.") //"Alteração de filial."
			AdpLogEAI(2, "Filial Anterior: " + cFilAnt) //"Filial Anterior: "
		EndIf

		cFilAnt := cFilProt

		If lLog
			AdpLogEAI(2, "Nova Filial: " + cFilAnt) //"Nova Filial: "
		EndIf
	EndIf

	aAdd(aFilialP, .T.)
	aAdd(aFilialP, cFilProt)

Return aFilialP
