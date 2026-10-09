#INCLUDE "MSOBJECT.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "DEFTEF.CH"
#INCLUDE "AUTODEF.CH"
#INCLUDE "LJCComPaymentHub.CH"

Function LJCComPaymentHub ; Return

Static cTermTEF := "" 	//Terminal TEF selecionado para utilização nas transações

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LJCPaymentHubCCCD
Envia os dados de todas as operacoes para o Payment Hub.

@type       Class
@author     Alberto Deviciente
@since      15/07/2020
@version    12.1.27
/*/
//-------------------------------------------------------------------------------------
Class LJCComPaymentHub
   	
   	Data lIniciado								//Indica se a comunicação com Payment Hub foi realizada
	Data oCfgPayHub 							//Objeto contendo as configuracoes do Payment Hub
	Data cCurrency 								//Codigo da Moeda
	Data oTransacao								//Objeto do tipo LJADadosTransacao
	Data oRetorno								//Objeto do tipo LJCRetornoPayHub
	Data oPayHubApi								//Objeto da Classe da API Payment Hub
	Data cDirTranstef							//Diretorio da pasta Traastef		
	Data cDirTPD								//Sub diretorio da pasta TPD
	Data cDirCompleto

	Method New()
	Method CommPaymentHub()
	Method TransCCCD()
	Method TransPD()
	Method TransacCanc()
	Method FinTrans()
	Method ShowGerencial()
	Method SetTrans()
	Method GetRetorno()
	Method RetTransCCCD()
	Method RetTransPD()
	Method GetRetTrnCanc()
	Method Gerenciais()
	Method GetRetGerenciais()
	Method GetTerminalTef()
	Method FormatDataHora()
	Method GetIdTransaction()
	Method TrataAdm()
	Method RetornaAdm()
	Method ImptTxTerm()
	Method TrataPend() 
	Method TransPed()
	Method DeletaArqTrans()
	Method RetNumOrc()
	Method TratarArquivoBin()
	Method PermiteCancelar()
	

EndClass

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da classe LJCComPaymentHub.

@type       Method
@author     Alberto Deviciente
@since      14/07/2020
@version    12.1.27

@param oCfgPayHub, Objeto, Objeto contendo as configuracoes do Payment Hub.

@return Self, Objeto, Objeto de representação da classe LJCComPaymentHub.
/*/
//-------------------------------------------------------------------------------------
Method New(oCfgPayHub) Class LJCComPaymentHub

    Self:lIniciado		:= .F.
	Self:oCfgPayHub 	:= oCfgPayHub
	Self:cCurrency 		:= "BRL"
	Self:oTransacao		:= Nil
	Self:oRetorno		:= Nil

	Self:oCfgPayHub:cCodeComp		:= AllTrim(Self:oCfgPayHub:cCodeComp)
	Self:oCfgPayHub:cIdPinPed		:= AllTrim(Self:oCfgPayHub:cIdPinPed)
	Self:oCfgPayHub:cTenant 		:= AllTrim(Self:oCfgPayHub:cTenant)
	Self:oCfgPayHub:cUserName		:= AllTrim(Self:oCfgPayHub:cUserName)
	Self:oCfgPayHub:cPassword		:= AllTrim(Self:oCfgPayHub:cPassword)
	Self:oCfgPayHub:cEnvironment	:= AllTrim(Self:oCfgPayHub:cEnvironment)
	Self:oCfgPayHub:cClientId		:= AllTrim(Self:oCfgPayHub:cClientId)
	Self:oCfgPayHub:cClientSecret	:= AllTrim(Self:oCfgPayHub:cClientSecret)

	If Empty(cTermTEF)
		cTermTEF := Self:oCfgPayHub:cIdPinPed
	EndIf

	Self:oPayHubApi 	:= PaymentHub():New(Self:oCfgPayHub:cCodeComp		, Self:cCurrency			,;
											Self:oCfgPayHub:cIdPinPed		, STFGetStation("CODIGO")	,;
											Self:oCfgPayHub:cTenant			, Self:oCfgPayHub:cUserName	,;
											Self:oCfgPayHub:cPassword		, Self:oCfgPayHub:cClientId	,;
											Self:oCfgPayHub:cClientSecret	, Nil						,;
											Nil								, Nil						,;
											Self:oCfgPayHub:cEnvironment )

	Self:cDirTranstef 	:= GetClientDir() + "transtef\"
	Self:cDirTPD	  	:= "tpd"
	Self:cDirCompleto	:= Self:cDirTranstef  + Self:cDirTPD
 	
Return Self

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} CommPaymentHub
Comunicação com a API do Payment Hub.

@type       Method
@author     Alberto Deviciente
@since      15/07/2020
@version    12.1.27

@return lRetorno, Lógico, Retorna se conseguiu se comunicar com o Payment Hub.
/*/
//-------------------------------------------------------------------------------------
Method CommPaymentHub() Class LJCComPaymentHub

	Local lRetorno		:= .F.
	
	LjGrvLog("TPD"," Inicio -  Comunicação com a API do Payment Hub.",,,.T. )

	//Verifica se já foi iniciada a comunicação com o Payment Hub.
	If !::lIniciado
				 
		//Faz comunicação com a API do Payment Hub para testar a comunicação
        lRetorno := .T. //Aqui deve ser feita a chamada para se comunicar com a API do Payment Hub para testar a comunicação
  
  		//Verifica se conseguiu se comunicar
		If !lRetorno
	    	MsgAlert(STR0001) // -- "Não foi possível se comunicar com o Payment Hub."
			LjGrvLog("TPD"," Não foi possível se comunicar com o Payment Hub. ",,,.T. )
		Else
			::lIniciado := .T.
		EndIf

		// -- Tratamento de vendas pendentes
		If !FWIsInCallStack("STBFunAdm") // -- Quando ativo pelo TEF gerenciais não preciso tratar vendas pendentes
			Self:TrataPend()
		EndIf 

	EndIf

	LjGrvLog("TPD"," Fim -  Comunicação com a API do Payment Hub. lRetorno -> ", lRetorno,,.T.)
		
Return lRetorno

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} TransCCCD
Envia transacao de pagamento CC e CD.

@type       Method
@author     Alberto Deviciente
@since      16/07/2020
@version    12.1.27

@return Nil, Nulo, Nulo
/*/
//-------------------------------------------------------------------------------------
Method TransCCCD() Class LJCComPaymentHub
	
	Local cTerminal 	:= ""
	Local aResult 		:= {}
	Local cIdTransct	:= Self:GetIdTransaction() //Id da Transação (Identificador ùnico da transação)

	::oRetorno := LJCRetornoPayHub():New()

	//Seleciona o Terminal TEF que será utilizado na transação
	cTerminal := Self:GetTerminalTef( 1, cTermTEF )

	If Empty(cTerminal)
		::oRetorno:lTransOK := .F.
		MsgAlert(STR0002)	// -- "É necessário selecionar um terminal para realizar transação."
	Else

		If Self:oTransacao:nParcela == 0
			Self:oTransacao:nParcela := 1
		EndIf

		//----------------------------------------------------
		// Envia Transação do Cartão para a API Payment Hub.
		//----------------------------------------------------
		STFMessage("TEFPayHubEnvia", "RUN", STR0003										,; // -- "Realizando transação..."
		{|| aResult := Self:oPayHubAPI:PaymentTransaction(	Self:oCfgPayHub:cCodeComp	,;
															cIdTransct					,;
															Self:oTransacao:nValor		,;
															Self:cCurrency				,;
															cTerminal					,;
															STFGetStation("CODIGO")		,;
															Self:oTransacao:nTipoTrans	,;
															Self:oTransacao:nParcela	); 
		} )
		STFShowMessage("TEFPayHubEnvia")

		//----------------------------------------------------
		// Pega o retorno da resposta da API Payment Hub.
		//----------------------------------------------------
		If aResult[1]
			STFMessage("TEFPayHubGetRet", "RUN", STR0004, { || Self:RetTransCCCD() } ) // -- "Concluindo transação..."
			STFShowMessage("TEFPayHubGetRet")
		Else
			MsgAlert(STR0005) // -- "Não foi possivel comunicação com terminal ou com o Hub de pagamentos."
		EndIf
	
	EndIf

Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} TransPD
Envia transacao de pagamento CC e CD.

@type       Method
@author     Alberto Deviciente
@since      16/07/2020
@version    12.1.27

@return Nil, Nulo, Nulo
/*/
//-------------------------------------------------------------------------------------
Method TransPD() Class LJCComPaymentHub
	
	Local aResult 		:= {}
	Local cIdTransct	:= Self:GetIdTransaction() //Id da Transação (Identificador ùnico da transação)

	::oRetorno := LJCRetornoPayHub():New()

	//----------------------------------------------------
	// Inicia transação para pagamentos digitais
	//----------------------------------------------------
	oPgDigital := PagamentosDigitais():New(Self:oPayHubAPI,cIdTransct,Self:oTransacao:nValor,Self:oTransacao:cIdPagto,Self:oCfgPayHub,Self:oTransacao:cFormaPgto)
	aResult := oPgDigital:FlowForDigitalPayments(Self:oTransacao)
	
	//----------------------------------------------------
	// Pega o retorno da resposta da API Payment Hub.
	//----------------------------------------------------
	If aResult[1] .And. oPgDigital:lClosed
		STFMessage("TEFPayHubGetRet", "RUN", STR0004, { || Self:RetTransPD() } ) // -- "Concluindo transação..."
		STFShowMessage("TEFPayHubGetRet") 
		LjGrvLog("Pagamentos Digitais","Concluindo transação " + cIdTransct + " do Payment Hub ")
	Else
		If Len(aResult[2]) == 0 .OR. Empty(aResult[2][1])
			MsgAlert(STR0018) // "Cancelado pelo usuario!"
		Else	
			MsgAlert(aResult[2][1]) 
		EndIf
	EndIf

	FreeObj(oPgDigital)
	
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} TransacCanc
Envia transacao de Cancelamento/Estorno do pagamento.

@type       Method
@author     Alberto Deviciente
@since      24/07/2020
@version    12.1.27

@param 	oDadosTran, Objeto, Objeto representando os dados da transação.
@param 	aDados, Array, Array com o dados da transação a ser cancelada.
@param	lObrigat, Logico, Indica seleção obrigatória do terminal.
@param	lMessage, Lógico, Indica mensagem na tela.

@return Nil, Nulo, Nulo
/*/
//-------------------------------------------------------------------------------------
Method TransacCanc(oDadosTran,aDados,lObrigat,lMessage) Class LJCComPaymentHub
	
	Local cTerminal 	:= ""
	Local nValor 		:= aDados[1]
	Local cIdtran		:= aDados[2]
	Local cProcTran		:= aDados[3]
	Local cExterTran	:= aDados[4]
	Local cFormaPgto	:= aDados[7]
	Local aResult 		:= {}
	Local bActionCanc	:= Nil			// -- Ação para cencelar 
	Local bActionConc	:= Nil			// -- Ação para concluir cancelamento 
	Local lCancTrnOk	:= .F.

	Default lObrigat	:= .F.
	Default lMessage	:= .T.   
	
	LjGrvlog("Totvs Pagamentos Digitais","Metodo TransacCanc - Inicio.",aDados,.T.,.T.)	
	LjGrvlog("Totvs Pagamentos Digitais","Metodo TransacCanc - Usuario: ",{PswChave(RetCodUsr()),FwGetUserName(RetCodUsr())},,.T.)	
	
		bActionCanc := {|| aResult := Self:oPayHubAPI:RefundTransaction(	cIdtran						,; 	//Idtransaction
																			cProcTran					,; 	//ProcessorTransactionId
																			Self:oCfgPayHub:cCodeComp	,; 	//Código da Companhia
																			cExterTran					,;	//ExternalTransactionId
																			nValor						,;	//Valor
																			Self:cCurrency				,;	//Moeda
																			cTerminal					,;	//ID Terminal TEF
																			STFGetStation("CODIGO")		); 	//Código Estacao
						}

		bActionConc := { || Self:GetRetTrnCanc() }

		If Valtype(oDadosTran) == "O"
			oDadosTran:nValor := nValor
		EndIf 

		::oRetorno := LJCRetornoPayHub():New()
		
		If !IsPDOrPix(cFormaPgto)
			//Seleciona o Terminal TEF que será utilizado na transação
			cTerminal := Self:GetTerminalTef( 1, cTermTEF,Nil,lObrigat )
		EndIf 

		If Empty(cTerminal) .AND. !IsPDOrPix(cFormaPgto)
			::oRetorno:lTransOK := .F.
			MsgAlert(STR0002) // -- "É necessário selecionar um terminal para realizar transação."
		Else

			While !lCancTrnOk
				//----------------------------------------------------
				// Envia Transação de cancelamento para a API Payment Hub.
				//----------------------------------------------------
				If lMessage
					STFMessage("TEFPayHubEnvia", "RUN", STR0006 ,bActionCanc)// -- "Aguarde. Cancelando transação..."
					STFShowMessage("TEFPayHubEnvia")
				Else
					Eval(bActionCanc)
				EndIf 

				If aResult[1]
					lCancTrnOk := .T.
				ElseIf IsBlind() .OR. (!IsBlind() .AND. !(MsgNoYes(STR0037)) ) // "Não foi possivel cancelar a transação, deseja tentar novamente?"
					lCancTrnOk := .F.
					Exit
				EndIf

			EndDo
			
			//----------------------------------------------------
			// Pega o retorno da resposta da API Payment Hub.
			//----------------------------------------------------
			If lCancTrnOk

				LjGrvlog("Totvs Pagamentos Digitais","Metodo TransacCanc - Cancelamento da transação realizado.",aDados,,.T.)
				
				If lMessage
					STFMessage("TEFPayHubGetRet", "RUN", STR0004 ,bActionConc ) // -- "Concluindo transação..."
					STFShowMessage("TEFPayHubGetRet")
				Else
					Eval(bActionConc)
				EndIf 

				If ::oRetorno:cErrorReason <> Nil .And. UPPER(::oRetorno:cErrorReason) == "BUSY"
					If MsgNoYes(STR0007 + cTerminal + STR0008,STR0009) // -- "o Terminal: " "XXXXXXXX"  " esta ocupado, gostaria de realizar uma nova tentativa em outro terminal?" "Terminal ocupado"
						cTermTEF := ""
						Self:TransacCanc(oDadosTran,aDados)
					Else	
						MsgAlert(STR0010  + cIdtran + STR0011) // -- "A transação: " XXXXXXXXX  " não será cancelada, para cencelar posteriormente utilizar rotina de TEF GERENCIAIS no menu F2"
					EndIf 
				EndIf  
			Else
				If !IsPDOrPix(cFormaPgto)
					MsgAlert(STR0005) // -- "Não foi possivel comuncação com terminal ou com o Hub de pagamentos."
				Else
					Help( " ", 1, STR0028, ,STR0035 + CHR(10)+CHR(13) +; // "Totvs Pagamentos Digitais" ## "Cancelamento da transação não realizado."
						STR0035, 1, 0 ) // "Consulte a plataforma de Pagamentos Digitais para verificar o status da transação, e considere efetuar a devolução da venda caso seja possível."
					LjGrvlog("Totvs Pagamentos Digitais","Nao foi possivel cancelar transacao.",aResult,,.T.)
				EndIf 
			EndIf
		EndIf
	
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} FinTrans
Confimar ou desfaz uma transacao.

@type       Method
@author     Alberto Deviciente
@since      16/07/2020
@version    12.1.27

@param nConfirma, Numérico, Identifica se a transacao deve ser confirmada (1) ou desfeita(0)

@return Nil, Nulo, Nil
/*/
//-------------------------------------------------------------------------------------
Method FinTrans(nConfirma) Class LJCComPaymentHub
Local aDados 	  := {}
Local lObrigat    := .T. // -- Indica que a tela do terminal é obrigatoria 


	LjGrvLog("Totvs Pagamentos Digitais","FinTrans - Deleta arquivo de transacao pendente",nConfirma,.T.,.T.)
	

	If nConfirma == 0
		
		If Self:oTransacao:nValor > 0 .AND. !Empty(Self:oTransacao:oRetorno:cIdTransaction)
			
			aDados := { Self:oTransacao:nValor                              ,;  //[1]=nValor
            Self:oTransacao:oRetorno:cIdTransaction             ,;  //[2]=cIdtran
            Self:oTransacao:oRetorno:cProcessorTransactionId    ,;  //[3]=cProcTran
            Self:oTransacao:oRetorno:cExternalTransactionId     ,;  //[4]
            Nil                                                 ,;  //[5]
            Nil                                                 ,;  //[6]
            Self:oTransacao:CFORMAPGTO                          }   //[7]=cFormaPgto

			If Self:PermiteCancelar(Self:oTransacao:nValor                           ,;
                        Self:oTransacao:oRetorno:cIdTransaction          ,;
                        Self:oTransacao:oRetorno:cExternalTransactionId ,;
                        Self:oTransacao:CFORMAPGTO                       ,;
                        "FinTrans",										 ,;
						Self:oTransacao:oRetorno:cProcessorTransactionId) 
				Self:TransacCanc(Self:oTransacao,aDados,lObrigat) 
			EndIf
			
		EndIf	
	EndIf 
	
	If !Empty(Self:oTransacao:oRetorno:cIdTransaction) 
		Self:DeletaArqTrans(Self:oTransacao:oRetorno:cIdTransaction)
	EndIf 
	
Return Nil

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ShowGerencial
Monta a tela para troca de dados com o Payment Hub.

@type       Method
@author     Alberto Deviciente
@since      16/07/2020
@version    12.1.27

@return aRet, Array, Array contendo a opção escolhida e os dados da transação TEF.
/*/
//-------------------------------------------------------------------------------------
Method ShowGerencial() Class LJCComPaymentHub

	Local nOpcao 	 := 0
	Local aRet       := {}
	Local aDados 	 := {}
	Local oRotinas   := RotinasGerenciaisPaymentHub():New()

	If ValType( oRotinas) == "O"
		oRotinas:ShowScreenGerencial()
		aDados := oRotinas:TransacaoGetDados()
		nOpcao := oRotinas:GetRotina()

		If nOpcao <> 2 .And. Empty(aDados)
			nOpcao := 0
		EndIf
	EndIf

	aRet := {nOpcao, aDados}

Return aRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetTrans
Recebe o objeto com os dados da transacao.

@type       Method
@author     Alberto Deviciente
@since      16/07/2020
@version    12.1.27

@param oTransacao, Objeto, Objeto do tipo LJADadosTransacao

@return Nil, Nulo, Nil
/*/
//-------------------------------------------------------------------------------------
Method SetTrans(oTransacao) Class LJCComPaymentHub

	::oTransacao := oTransacao
		
Return Nil

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetRetorno
Retorna o objeto do tipo LJCRetornoPayHub.

@type       Method
@author     Alberto Deviciente
@since      16/07/2020
@version    12.1.27

@return Nil, Nulo, Nil
/*/
//-------------------------------------------------------------------------------------
Method GetRetorno() Class LJCComPaymentHub
Return ::oRetorno

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RetTransCCCD
Alimenta os atributos de retorno da transação de pagamento, conforme dados retornados da API Payment Hub.

@type       Method
@author     Alberto Deviciente
@since      17/07/2020
@version    12.1.27

@return Nil, Nulo, Nil
/*/
//-------------------------------------------------------------------------------------
Method RetTransCCCD() Class LJCComPaymentHub

	Local oResult 	:= Nil
	Local cData 	:= ""
	Local cHora 	:= ""

	oResult := Self:oPayHubAPI:ResultPaymentTransaction()

	If Upper(oResult["transactionStatus"]) <> "AUTHORIZED"
		::oRetorno:lTransOK 	:= .F.	
		::oRetorno:cErrorReason := oResult["errorReason"]
	Else
		Self:FormatDataHora(oResult["transactionTimestamp"], @cData, @cHora)

		::oRetorno:lTransOK 				:= .T.
		::oRetorno:cTpCartao 				:= oResult["card"]["brand"] 						//Bandeira do Cartão
		::oRetorno:cNsuPayHub				:= oResult["internalNsu"]							//Identificador sequencial interno do Payment Hub, é o que deve ser usado para conciliação. 
		::oRetorno:cNsuAuto 				:= oResult["nsu"] 									//NSU do Autorizador
		::oRetorno:dData 					:= sToD(cData) 										//Data da transação
		::oRetorno:cHora 					:= cHora 											//Hora da transação
		::oRetorno:cCodAuto					:= oResult["authorizationCode"] 					//Codigo da autorizacao
		::oRetorno:cRede					:= oResult["acquirer"] 								//Rede que processou a transação?
		::oRetorno:cInstit					:= oResult["acquirer"] 								//Instituicao que processou a transação
		::oRetorno:aViaCliente 				:= oResult["customerReceipt"]["receiptData"]		//Comprovante (Via do Cliente)
		::oRetorno:aViaCaixa				:= oResult["cashierReceipt"]["receiptData"] 		//Comprovante (Via do Caixa)
		::oRetorno:nParcelas				:= oResult["installments"]["numberOfInstallments"]	//Numero de parcelas
		::oRetorno:cIdtransaction 			:= oResult["id"]									//ID da Transação
		::oRetorno:cProcessorTransactionId	:= oResult["processorTransactionId"]				//ID da transação do processador
		::oRetorno:cExternalTransactionId	:= oResult["externalTransactionId"]					//ID da transação Externa
	
		//Trata a Adm Financeira Retornada
		Self:TrataAdm(Self:oTransacao:nParcela) 

		// -- Deixa a venda como pendente
		Self:TransPed()		
	EndIf

Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RetTransPD
Alimenta os atributos de retorno da transação de pagamento, conforme dados retornados da API Payment Hub.

@type       Method
@author     Lucas Novais (lnovais@)
@since      04/11/2020
@version    12.1.27

@return Nil, Nulo, Nil
/*/
//-------------------------------------------------------------------------------------
Method RetTransPD() Class LJCComPaymentHub

	Local oResult 	:= Nil

	oResult := Self:oPayHubAPI:ResultStatusLinkPaymentTransaction()()

	If Upper(oResult["status"]) <> "APPROVED"
		::oRetorno:lTransOK 	:= .F.	
		::oRetorno:cErrorReason := oResult["errorReason"]
	Else

		If Empty(oResult["nsu"])
			oResult["nsu"] := "123456"
		EndIf

		::oRetorno:lTransOK 				:= .T.
		::oRetorno:cTpCartao 				:= oResult["wallet"]									//Bandeira do Cartão
		::oRetorno:cNsuPayHub				:= oResult["nsu"]										//Identificador sequencial interno do Payment Hub, é o que deve ser usado para conciliação. 
		::oRetorno:cNsuAuto 				:= oResult["externalTransactionId"]		 				//ID da transação Externa
		::oRetorno:dData 					:= dDatabase			 								//Data da transação
		::oRetorno:cHora 					:= Time() 												//Hora da transação
		::oRetorno:cCodAuto					:= oResult["processorTransactionId"] 					//ID da transação do processador
		::oRetorno:cRede					:= oResult["processorName"] 							//Rede que processou a transação?
		::oRetorno:cInstit					:= oResult["processorName"] 							//Instituicao que processou a transação
		::oRetorno:aViaCliente 				:= oResult["customerReceipt"]["receiptData"]			//Comprovante (Via do Cliente)
		::oRetorno:aViaCaixa				:= oResult["cashierReceipt"]["receiptData"] 			//Comprovante (Via do Caixa)
		::oRetorno:nParcelas				:= 1
		::oRetorno:cIdtransaction 			:= oResult["transactionId"]								//ID da Transação
		::oRetorno:cProcessorTransactionId	:= oResult["processorTransactionId"]					//ID da transação do processador
		::oRetorno:cExternalTransactionId	:= oResult["externalTransactionId"]						//ID da transação Externa
	
		//Trata a Adm Financeira Retornada
		Self:TrataAdm(Self:oTransacao:nParcela) 

	EndIf

Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetRetTrnCanc
Alimenta os atributos de retorno da transação de cancelamento/estorno, conforme dados retornados da API Payment Hub.

@type       Method
@author     Alberto Deviciente
@since      24/07/2020
@version    12.1.27

@return Nil, Nulo, Nil
/*/
//-------------------------------------------------------------------------------------
Method GetRetTrnCanc() Class LJCComPaymentHub

	Local oResult 	:= Nil

	oResult := Self:oPayHubAPI:ResultRefundTransaction()

	LjGrvLog("Totvs Pagamentos Digitais","GetRetTrnCanc - Resultado da transacao",oResult,,.T.)

	If Empty(oResult["transactionId"])
		::oRetorno:lTransOK 	:= .F.

		If !Empty(oResult["reversalResponse"])
			::oRetorno:cErrorReason := oResult["reversalResponse"]["response"]["errorCondition"]
		EndIf 

	Else
		
		::oRetorno:lTransOK 	:= .T.
		::oRetorno:dData 		:= dDatabase 										//Data da transação
		::oRetorno:cHora 		:= Time() 											//Hora da transação
		::oRetorno:cDocCanRei	:= oResult["transactionId"]
		::oRetorno:dDataCanRei	:= dDatabase
		If oResult["customerReceipt"] <> Nil
			::oRetorno:aViaCliente 	:= oResult["customerReceipt"]["receiptData"]	//Comprovante (Via do Cliente)
		EndIf
		If oResult["cashierReceipt"] <> Nil
			::oRetorno:aViaCaixa	:= oResult["cashierReceipt"]["receiptData"] 	//Comprovante (Via do Caixa)
		EndIf
	EndIf

Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Gerenciais
Trata as rotinas Administrativas/Gerenciais.

@type       Method
@author     Alberto Deviciente
@since      24/07/2020
@version    12.1.27

@param 	oDadosTran, Objeto, Objeto representando os dados da transação.
@param 	aTransCanc, Array, Array com o dados da transação a ser cancelada

@return Nil, Nulo, Nil
/*/
//-------------------------------------------------------------------------------------
Method Gerenciais(oDadosTran,aTransCanc) Class LJCComPaymentHub

	Local aResult    := {}
	Local aRetGerec  := {}
	Local nOption    := 0
	Local aDadosTEF  := {}
	Local bAction	 := {||}
	Local cFormaPgto := "" 
	Local aDados     := {}

	Default aTransCanc := {} 		
	
	LjGrvLog("Totvs Pagamentos Digitais","Metodo Gerenciais - Inicio",,.T.,.T.)

	If Empty(aTransCanc)
		//Chama a interface para o usuário escolher a opção que deseja realizar.
		aRetGerec 	:= Self:ShowGerencial()

		nOption 	:= aRetGerec[1]	//Opção Selecionada pelo Usuário
		aDados 		:= aRetGerec[2]	//Dados da transação
		If Len(aDados) >= 14
			aTransCanc	:= { 	AllTrim(aDados[11])	,; 	//01-DOCTEF da transação
								aDados[6]			,;	//02-Valor Total da transação
								AllTrim(aDados[12])	,;	//03-ID da Transação
								AllTrim(aDados[13])	,;	//04-ID Transação Processador
								AllTrim(aDados[14])	,;	//05-ID da Transação Externa
								AllTrim(aDados[08])	,;	//06-Data da Transação
								AllTrim(aDados[10])	,;	//07-Forma de Pagamento
								aDados[16]			} 	//08-Recnos relacionados a transação
		EndIf 		  
	Else				
		nOption 	:= 3 //Cancelamento
		aDadosTEF	:= { 	aTransCanc[2],; //01-Valor Total da transação
							aTransCanc[3],;	//02-ID da Transação
							aTransCanc[4],;	//03-ID Transação Processador
							aTransCanc[5],;	//04-ID da Transação Externa
							aTransCanc[6],;	//05-Data da Transação
							aTransCanc[1],;	//06-DOCTEF
							aTransCanc[7] }	//07-Forma de Pagamento
	EndIf
	
	::oRetorno := LJCRetornoPayHub():New()

	If Len(aTransCanc) >= 7
		cFormaPgto := aTransCanc[07]
	EndIf

	If nOption == 1 //Reimpressao
		
		cIdtransaction := AllTrim(aDados[12])
		cIdprocessor   := AllTrim(aDados[13])
		
		
		bAction := {|| aResult := Self:oPayHubAPI:ReceiptTransaction(cIdtransaction) } 

		//----------------------------------------------------
		// Envia Transação de cancelamento para a API Payment Hub.
		//----------------------------------------------------
		STFMessage("TEFPayHubEnvia", "RUN", STR0012 ,bAction) // "Efetuadno reimpressão..."
		STFShowMessage("TEFPayHubEnvia")

		//----------------------------------------------------
		// Pega o retorno da resposta da API Payment Hub.
		//----------------------------------------------------
		If aResult[1]
			STFMessage("TEFPayHubGetRet", "RUN",STR0013, { || Self:GetRetGerenciais(Alltrim(aDados[10]))}) // --  "Aguarde, processando..."
			STFShowMessage("TEFPayHubGetRet")
		Else
			If !IsPDOrPix(cFormaPGTO)
				MsgAlert(STR0005) // -- "Não foi possivel comuncação com terminal ou com o Hub de pagamentos."
			Else
				MsgAlert(STR0019)  // "Não foi possivel comunicar com TOTVS Pagamento Digitais, tente mais tarde."
			EndIf 
		EndIf
		
	ElseIf nOption == 2 //Seleção de Terminal

		//Selecionação do Terminal TEF
		Self:GetTerminalTef( 2, Nil, .T. )

	ElseIf nOption == 3 //Cancelamento/Estorno
		
		LjGrvLog("Totvs Pagamentos Digitais","Metodo Gerenciais - Cancelamento - Usuario: ",{PswChave(RetCodUsr()),FwGetUserName(RetCodUsr())},.T.,.T.)

		If Empty(aDadosTEF) .And. !Empty(aDados)
			aDadosTEF := { aDados[6], AllTrim(aDados[12]), AllTrim(aDados[13]), AllTrim(aDados[14]), AllTrim(aDados[08]), AllTrim(aDados[11]), AllTrim(aDados[10]) }
		EndIf

		// Quando vem de aTransCanc (sem aDados), usa aTransCanc diretamente
        If !Empty(aDados)
            // Veio pelo menu gerenciais - aDados está disponível
            If Self:PermiteCancelar(aDados[6]           ,;  // Valor Transacao
                                    AllTrim(aDados[11]) ,;  // cIdtran
                                    AllTrim(aDados[12]) ,;  // cProcTran
                                    AllTrim(aDados[10]) ,;  // cFormaPgto
                                    "Gerenciais"        ,;  // cRotina
                                    AllTrim(aDados[13]) )   // cExtTran = processorTransactionId
                Self:TransacCanc(oDadosTran,aDadosTEF)
            EndIf
        Else
            // Veio por aTransCanc (cancelamento automático ex: STWCANCELSALE)
            If Self:PermiteCancelar(aTransCanc[2]          ,;  // Valor Transacao
                                    AllTrim(aTransCanc[1]) ,;  // cIdtran  = DOCTEF
                                    AllTrim(aTransCanc[3]) ,;  // cProcTran
                                    AllTrim(aTransCanc[7]) ,;  // cFormaPgto
                                    "Gerenciais"           ,;  // cRotina
                                    AllTrim(aTransCanc[4]) )   // cExtTran = processorTransactionId
                Self:TransacCanc(oDadosTran,aDadosTEF)
            EndIf
        EndIf
		
	EndIf

Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetRetGerenciais
Alimenta os atributos de retorno Gerenciais.

@type       Method
@author     Alberto Deviciente
@since      03/08/2020
@version    12.1.27

@return Nil, Nulo, Nil
/*/
//-------------------------------------------------------------------------------------
Method GetRetGerenciais(cTpTrans) Class LJCComPaymentHub

	Local oResult 	:= Nil
	
	oResult := Self:oPayHubAPI:ResultReceiptTransaction()

	If Empty(oResult["transactionId"])
		::oRetorno:lTransOK 	:= .F.
	Else
		
		::oRetorno:lTransOK 	:= .T.
		::oRetorno:aViaCliente 	:= oResult["customerReceipt"]["receiptData"]	//Comprovante (Via do Cliente)
		::oRetorno:aViaCaixa	:= oResult["cashierReceipt"]["receiptData"]		//Comprovante (Via do Caixa)
	EndIf

Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetTerminalTef
Seleciona o Terminal TEF que será utilizado na transação.

@type       Method
@author     Alberto Deviciente
@since      01/08/2020
@version    12.1.27

@param nOrigem, Numérico, Origem de onde está sendo chamado (1=Venda; 2=Consulta F3 Cadastro de estação)
@param cTerminal, Caracter, Código do terminal
@param lForceSel, Lógico, Força a seleção do Terminal.

@return cRet, Lógico, Retorna o código do terminal TEF.
/*/
//-------------------------------------------------------------------------------------
Method GetTerminalTef(nOrigem,cTerminal,lForceSel,lObrigat) Class LJCComPaymentHub

	Local cRet 			:= ""
	Local lMantemCfg 	:= .F. //Controla se mantém Terminal TEF escolhido para utilizar nas próximas vendas
	
	Default nOrigem		:= 1
	Default cTerminal 	:= ""
	Default lForceSel 	:= .F.
	Default lObrigat	:= .F.

	If LjPHSelTer(nOrigem, Self:oCfgPayHub, @lMantemCfg, !lForceSel, cTerminal,lObrigat)
		cRet := LjPHGetTer()
		If lMantemCfg .Or. lForceSel
			cTermTEF := cRet
		EndIf
	Else
		cRet := ""
	EndIf

Return cRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} FormatDataHora
Formata Data e Hora.

@type       Method
@author     Alberto Deviciente
@since      01/08/2020
@version    12.1.27

@param cDataHora, Caracter, Informação contendo a data e hora.
@param cData, Caracter, Data Formatada
@param cHora, Caracter, Hora Formatada

@return Nil, Nulo
/*/
//-------------------------------------------------------------------------------------
Method FormatDataHora(cDataHora, cDataAux, cHoraAux) Class LJCComPaymentHub
		
	cDataAux := Replace(SubStr(cDataHora,1,10),"-","")
	cHoraAux := SubStr(cDataHora,12,8)

Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetIdTransaction
Retorna o Id da Transação (Identificador ùnico da transação).

@type       Method
@author     Alberto Deviciente
@since      01/08/2020
@version    12.1.27

@return cRet, Caracter, Id da Transação.
/*/
//-------------------------------------------------------------------------------------
Method GetIdTransaction() Class LJCComPaymentHub

	Local cRet 	:= ""

	//Composição do ID Unico da Transação
	cRet := AllTrim(STFGetStation("CODIGO")) + dToS(Date()) + Replace(Time(),":","")

Return cRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} TrataAdm
Trata a Administrador Financeira.

@type       Method
@author     Alberto Deviciente
@since      06/08/2020
@version    12.1.27

@param nParcela, Numérico, Parcela da transação.

@return Nil, Nulo
/*/
//-------------------------------------------------------------------------------------
Method TrataAdm(nParcela) Class LJCComPaymentHub
			
	If (::oTransacao:nTipoTrans == 1 .OR. ::oTransacao:nTipoTrans == 2 .Or. ::oTransacao:nTipoTrans == 14) 
		
		LjGrvLog(Nil, "Quantidade de parcelas informado na rotina: ", nParcela,,.T.)
		
		::oRetorno:aAdmin := aClone( Self:RetornaAdm(::oRetorno:cTpCartao, ::oTransacao:cFormaPgto, nParcela, ::oRetorno:cInstit) )

	EndIf

Return 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RetornaAdm
Retorna a Administradora Financeira, conforme codigo da bandeira retornado na transação.

@type       Method
@author     Alberto Deviciente
@since      06/08/2020
@version    12.1.27

@param cCodBand, Caractere, Código de retorno da Bandeira do Cartão.
@param cForma, Caractere, Forma de Pagamento (CC / CD)
@param nParcelas, Numérico, Qtde de Parcelas da transação.
@param cCodRede, Caractere, Código de retorno da Rede Autorizdora da Transação

@return aRetorno, Array, Array com a relação de Adm. Financeiras encontradas.
/*/
//-------------------------------------------------------------------------------------
Method RetornaAdm(cCodBand, cForma, nParcelas, cCodRede) Class LJCComPaymentHub
Local aRetorno	:= {}
Local oTEF		:= STBGetTef()
Local aAdmin	:= oTEF:Administradoras()
Local nPos		:= 0
Local lPesqREDE := Len(aAdmin) > 0 .And. Len(aAdmin[1]) > 8 .And. (cForma <> "PD" .Or. cForma <> "PX") //Verifica se alem da Bandeira, considera tambem a pesquisa por Rede
Local lAchouADM := .F.

Default cCodRede := ""

LjGrvLog( Nil, "Forma de pagamento"				, cForma	,,.T. )
LjGrvLog( Nil, "Quantidade de Parcelas"			, nParcelas	,,.T. )
LjGrvLog( Nil, "Codigo da Bandeira retornada"	, cCodBand	,,.T. )
LjGrvLog( Nil, "Codigo da Rede retornada"		, cCodRede	,,.T. )

aSort(aAdmin, , , { |a, b| a[2] + a[8] + StrZero(a[4], 4) + StrZero(a[5], 4) < b[2] + b[8] + StrZero(b[4], 4) + StrZero(b[5], 4)} )

//realiza a busca da Adm.Fin. baseado no Codigo retornado (oitava posicao do array)
If ( nPos := aScan(aAdmin, { |a| a[2] == cForma .AND. AllTrim(UPPER(a[8])) == AllTrim(UPPER(cCodBand)) }) )  > 0

	Do While nPos <= Len(aAdmin) .AND. aAdmin[nPos, 2] == cForma .AND. AllTrim(UPPER(aAdmin[nPos, 8])) == AllTrim(UPPER(cCodBand))
	  	
	  	//Verifica se esta dentro do range de parcelas
	  	If aAdmin[nPos, 4]  <= nParcelas .AND. aAdmin[nPos, 5] >=  nParcelas
			lAchouADM := .T.
		Else
			LjGrvLog( Nil, "A parcela retornada nao esta entre os valores dos campos Parcela De e Ate da Adm.Fin.", aAdmin[nPos][3],,.T. )
			lAchouADM := .F.				
		EndIf
		
	  	//Verifica se esta relacionado com o codigo da REDE retornada
	  	If lAchouADM .And. lPesqREDE
	  		//Verifica se a Rede configurada eh igual a Rede retornada ou se a Rede estah em branco (nao configurado o campo AE_REDEAUT)
	  		If aAdmin[nPos, 9] == cCodRede .Or. Empty(aAdmin[nPos, 9]) 
				lAchouADM := .T.
			Else
				lAchouADM := .F.				
			EndIf
		EndIf
		
		If lAchouADM
			Aadd( aRetorno, aAdmin[nPos] )
		EndIf

		nPos++
	EndDo
Else
	LjGrvLog( Nil, "Nenhuma Adm.Fin. possui o codigo de retorno vinculado ao codigo da bandeira retornado", cCodBand,,.T. )		 
EndIf

If Len(aRetorno) == 0
	LjGrvLog(Nil, "Nao foi possivel selecionar nenhuma Adm.Fin. atraves da tabela MDE",,,.T.)
ElseIf Len(aRetorno) > 1
	LjGrvLog(Nil, "Retornado mais de uma Adm. Fin com o mesmo codigo de retorno configurado / Forma de Pagamento / Parcelas",,,.T. )
EndIf

Return aRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} ImptTxTerm
Solicita o CPF pelo Terminal.

@author		JMM
@version	V12.1.25
@since		06/08/2020

@param		cTexto, Caractere, String com o texto para ser apresentado no Terminal

@return		aRet, Array, Array contendo o resultado do retorno e o texto informado no Terminal.
/*/
//-------------------------------------------------------------------
Method ImptTxTerm( cTexto ) Class LJCComPaymentHub
Local cRetorno		:= "" 
Local cTerminal 	:= Self:GetTerminalTef( 1, cTermTEF )
Local oResult		:= Nil
Local cCodeRet		:= "0"
Local aResult		:= {.F.,"","-43"}

Default cTexto := STR0020 // "DIGITE SEU CPF"

If Empty(cTerminal)
	STFShowMessage(STR0014) // -- "Não é possível realizar a operação sem selecionar um terminal."
Else

	STFMessage("TEFPayHubEnvia", "RUN", STR0015 ,; // -- "Comunicando com o terminal..."
	{|| Self:oPayHubAPI:InputTextTransaction(Nil,cTerminal,Nil,cTexto) } )	

	STFShowMessage("TEFPayHubEnvia")

	oResult := Self:oPayHubAPI:ResultInputTextTransaction() 

	If ValType(oResult) == "O" .OR. ValType(oResult) == "J"		
		cRetorno := oResult:GetJsonText("resultText")
		If ValType(oResult["processorMessage"]) == "C".AND. UPPER(oResult["processorMessage"]) == "FAILURE"
			cCodeRet := "-43"
		EndIf 
		aResult := {.T.,cRetorno,cCodeRet}	
	Else
		aResult := {.F.,cRetorno,"-43"}
	EndIf

EndIf

Return aResult

//-------------------------------------------------------------------
/*/{Protheus.doc} TransPed
Metodo responsavel por gravar o arquivo de transação pendente.

@author		Lucas Novais (lnovais@)
@version	12.1.25
@since		06/08/2020

/*/
//-------------------------------------------------------------------
Method TransPed(cIdTransaction,nValor,cProcessorTransactionId,cExternalTransactionId,cFormaPGTO) Class LJCComPaymentHub
	Local nHandle :=  0
	Local cTransacao := ""
	Local aDadosOrc	:= IIF(!IsBlind(), Self:RetNumOrc() ,{"",""})
	
	Default cIdTransaction 				:= Self:oRetorno:cIdTransaction
	Default nValor						:= Self:oTransacao:nValor
	Default cProcessorTransactionId		:= Self:oRetorno:cProcessorTransactionId
	Default cExternalTransactionId		:= Self:oRetorno:cExternalTransactionId
	Default cFormaPGTO					:= Self:oTransacao:cFormaPGTO

	LjGrvLog("Totvs Pagamentos Digitais","Metodo TransPed - Criacao arquivo de transacao pendente - Inicio",,.T.,.T.)

	If ExistDir(Self:cDirTranstef)
        If !ExistDir(Self:cDirCompleto)
           If  MakeDir(Self:cDirCompleto) <> 0
				MsgStop(STR0021 + Self:cDirCompleto + STR0022) // "Não foi possível criar o diretório '"  "' para controle de transações TEF."
		   EndIf 
        EndIf 
    Else
        If MakeDir(Self:cDirTranstef) <> 0
            If MakeDir(Self:cDirCompleto) <> 0 
				MsgStop( STR0021 + Self:cDirCompleto + STR0022 ) // "Não foi possível criar o diretório '" "' para controle de transações TEF."
			EndIf 
        EndIf 
    EndIf

	nHandle := FCreate(Self:cDirCompleto + "\" + cIdTransaction + ".bin")
	cTransacao := Embaralha(AllTrim(STR(nValor)) + ";" + cIdTransaction + ";" + cProcessorTransactionId + ";" + cExternalTransactionId + ";" + cFormaPGTO  + ";" + aDadosOrc[01] + ";" + aDadosOrc[02],0)
	
	FWrite(nHandle,cTransacao)
	FClose(nHandle)

	LjGrvLog("Totvs Pagamentos Digitais","Metodo TransPed - Criacao do arquivo de transacao pendente - Dados da transacao: ",cTransacao,.T.,.T.)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} DeletaArqTrans
Metodo responsavel por confirmar a transação pendente, excluindo o arquivo

@author		Lucas Novais (lnovais@)
@version	12.1.25
@since		06/08/2020

@param		cTransacao, Caractere, String contendo o id da transação que será confimada.
/*/
//-------------------------------------------------------------------

Method DeletaArqTrans(cTransacao) Class LJCComPaymentHub 
	If !Empty(cTransacao) .AND. ExistDir(Self:cDirCompleto) .AND. File(Self:cDirCompleto + "\" + cTransacao + ".bin") .AND. (FERASE(Self:cDirCompleto + "\" + cTransacao + ".bin") == -1)
		If !IsBlind()
			MSGAlert( STR0025 + CHR(10) + STR0026 + cTransacao + CHR(10)+CHR(13) + STR0027 ) // "Falha ao tentar deletar o arquivo de transação pendente." ## "Transação: " ## "Informe ao administrador do sistema."
		EndIf
		LjGrvLog("Totvs Pagamentos Digitais","Falha ao tentar deletar o arquivo de transação pendente.",cTransacao,,.T.)
	EndIf 
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TrataPend()
Metodo responsavem por estornar vendas que estejam pendentes apos recuperação de venda

@author		Lucas Novais (lnovais@)
@version	12.1.25
@since		06/08/2020

/*/
//-------------------------------------------------------------------

Method TrataPend(cTransacao,lCanPgTP) Class LJCComPaymentHub
	Local aDiretorio	:= {}						// Diretorio do arquivo de Transação Pendente
	Local nHandle		:= -1
	Local cLinha     	:= ""
	Local nX         	:= 0
	Local aTransCanc 	:= Array(7)					// Dados da transação a ser cancelada
	Local aAux       	:= {}
	Local lCancTrnOk	:= .F.
	Local lPermtCanc	:= .F.						// Status da venda permite cancelamento, com base no L1_SITUA do orcamento
	Local cFilOrc		:= ""
	Local cCodOrc		:= ""
	Local lLjL1Situa 	:= ExistFunc("LjL1Situa")
	
	Default cTransacao := ""
	Default lCanPgTP   := .F.  //Usuário cancelou o pagamento do pix

	LjGrvLog("Totvs Pagamentos Digitais","Metodo TrataPend - Trata transacao pendente - Inicio",,.T.,.T.)
	LjGrvLog("Totvs Pagamentos Digitais","Metodo TrataPend - Usuario - Codigo - Nome",{PswChave(RetCodUsr()),FwGetUserName(RetCodUsr())},.T.,.T.)

	If !Empty(cTransacao) 
		If File(Self:cDirCompleto + "\" + cTransacao + ".bin")

			nHandle := FT_FUse(Self:cDirCompleto + "\" + cTransacao + ".bin")

			If nHandle != -1
				FT_FGoTop()
				cLinha  := Embaralha(FT_FReadLn(),1)
				FT_FUSE()

				If !Empty(cLinha)
					aAux			:= StrTokArr(cLinha,";")
					aTransCanc[1]  	:= aAux[1]
					aTransCanc[2]  	:= aAux[2]
					aTransCanc[3]  	:= aAux[3]
					aTransCanc[4]  	:= aAux[4]
					aTransCanc[7]  	:= aAux[5]

				    
					If lCanPgTP
						Self:TransacCanc(Nil,aTransCanc,,.F.)
						
						LjGrvLog("Totvs Pagamentos Digitais","Metodo TrataPend - Retorno da transacao.",::oRetorno:lTransOK,,.T.)
						If ::oRetorno:lTransOK
							FERASE(Self:cDirCompleto + "\" + cTransacao + ".bin")
						EndIf
					
					ElseIf  Self:PermiteCancelar(Val(AllTrim(aAux[1])) ,aAux[2],aAux[3],aAux[5],"TrataPend", aAux[4])
						Self:TransacCanc(Nil,aTransCanc,,.F.)

						LjGrvLog("Totvs Pagamentos Digitais","Metodo TrataPend - Retorno da transacao.",::oRetorno:lTransOK,,.T.)

						If ::oRetorno:lTransOK
							FERASE(Self:cDirCompleto + "\" + cTransacao + ".bin")
						EndIf
					EndIf

				EndIF
			EndIf
		EndIf

	Else
		If ExistDir(Self:cDirCompleto)
			aDiretorio := Directory(Self:cDirCompleto + "\*.bin")
			LjGrvLog("Totvs Pagamentos Digitais","Metodo TrataPend - Dados da transacao",aDiretorio,,.T.)

			For nX := 1  to Len(aDiretorio)
				nHandle := FT_FUse(Self:cDirCompleto + "\" + aDiretorio[nX][1])
				If nHandle == -1
					MsgStop(STR0017 + STR(fError(),4)) // -- "Erro na abertura do arquivo, motivo: "
				Else
					FT_FGoTop()
					cLinha  := Embaralha(FT_FReadLn(),1)					
					FT_FUSE()
				Endif

				If !Empty(cLinha)
					aAux		:= StrTokArr(cLinha,";")
					aTransCanc[1]  := aAux[1]
					aTransCanc[2]  := aAux[2]
					aTransCanc[3]  := aAux[3]
					aTransCanc[4]  := aAux[4]
					aTransCanc[7]  := aAux[5]	

					If Len(aAux) > 5
						cFilOrc := aAux[6]
						cCodOrc := aAux[7]
					EndIf				

					If lLjL1Situa
						aDadosOrc := LjL1Situa( aTransCanc[2], aTransCanc[3],aTransCanc[4], cCodOrc )
						lPermtCanc := aDadosOrc[01]
						LjGrvLog("Totvs Pagamentos Digitais","Metodo TrataPend - Retorno LjL1Situa",{lCancTrnOk,aDadosOrc},,.T.)
					EndIf
					
					//Verifica o status da PIX ou PD
					Self:TratarArquivoBin(aDadosOrc, aTransCanc, Self:cDirCompleto + "\" + aDiretorio[nX][1])
				EndIf
			Next
		EndIf 
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RetNumOrc()
Metodo responsavem por retornar o numero do orçamento
@author		joao.marcos
@version	12.1.25
@since		22/04/2022
/*/
//-------------------------------------------------------------------

Method RetNumOrc() Class LJCComPaymentHub
return {SL1->L1_FILIAL, SL1->L1_NUM,SL1->L1_VLRTOT}


//-------------------------------------------------------------------
/*/{Protheus.doc} TratarArquivoBin()
Verificar do arquivo bin da transação PIX ou PD. Caso a transação esteja pendente, faz o cancelamento. Não deve fazer o cancelamento de transação confirmada.
@author		nilson.junior
@version	15.12.25
@since		22/12/2025
/*/
//-------------------------------------------------------------------

Method TratarArquivoBin(aDadosOrc, aTransCanc, cArqBin) Class LJCComPaymentHub

Local lStatusPay := .F.
Local cValorTran := ""
Local nTentativa := 1
Local aResult    := {.F.,""}
Local oResult	 := Nil

If !Empty(aDadosOrc) .And. !Empty(aTransCanc)

	If Val(aTransCanc[01]) - Int(Val(aTransCanc[01])) == 0
		cValorTran := AllTrim(aTransCanc[1]) + ",00"
	Else
		cValorTran := StrTran( AllTrim(aTransCanc[1]), ".", ",")
	EndIf		   

	While nTentativa <= 3

		aResult := Self:oPayHubAPI:StatusLinkPaymentTransaction(,,aTransCanc[3])

		If aResult[01]

			oResult :=  Self:oPayHubAPI:ResultStatusLinkPaymentTransaction()

			If !Empty(oResult["status"])
				lStatusPay := .T.

				Exit
			EndIf
		EndIf

		nTentativa++
	EndDo

	If lStatusPay 
		If UPPER(oResult["status"]) == "PENDING"
			If Self:PermiteCancelar(Val(AllTrim(aTransCanc[1])) ,aTransCanc[2],aTransCanc[4],aTransCanc[7],"TratarArquivoBin", aTransCanc[3])
				STFMessage("SITEF","RUN",STR0040, {||Self:TransacCanc(Nil,aTransCanc)}) // -- "Aguarde. Cancelando transação Pendente..."
				STFShowMessage("SITEF")

				LjGrvLog("Totvs Pagamentos Digitais","Transacao pendente cancelada. Dados da transacao: ", aTransCanc,,.T.)
			EndIf
		Else // Transação Aprovada, mensagem para avisar que precisa realizar o credito para o cliente
			Help( " ", 1, STR0028, , STR0038 + CHR(10)+CHR(13)	      +; // "Totvs Pagamentos Digitais" ##  "Transação Realizada com sucesso."
					STR0026 + aTransCanc[3] + CHR(10)			      +; // "Transaçao: "  
					STR0029	+ aDadosOrc[02] + CHR(10)			      +; // "Orcamento: "
					STR0030 + "  " + DtoC(aDadosOrc[07]) + CHR(10) 	  +; // "Emissão  : "
					STR0031	+ "      " + cValorTran + CHR(10)+CHR(13) +; // "Valor    : " 
					STR0039, 1, 0)                                       // ""O Pix ou Pagamento Digital foi pago com Sucesso. Deve-se gerar o crédito manual para o cliente e concluir a venda.""
			
			LjGrvLog("Totvs Pagamentos Digitais","Transacao confirmada. Dados da transacao: ", aTransCanc,,.T.)
		EndIf	
	EndIF

	If FERASE(cArqBin) == -1
		LjGrvLog("Totvs Pagamentos Digitais","Não foi possivel deletar o arquivo de transacao pendente.",  Right(cArqBin, Len(cArqBin) - RAt("\", cArqBin)),,.T.)
	Else
		LjGrvLog("Totvs Pagamentos Digitais","Arquivo de transacao deletado.", Right(cArqBin, Len(cArqBin) - RAt("\", cArqBin)),,.T.)
	EndIf

EndIf

Return


/*/{Protheus.doc} PermiteCancelar
    Verifica se a transação já foi aprovada antes de permitir o cancelamento.
	Verifica permissão do operador para o cancelamento
    @type  Method
    @author Jose Erik 
    @since 01/05/2026
    @version 1.0
    @param 	aDados, Array, Array com o dados da transação a ser cancelada.
	@param 	cRotina,caracter,com o nome da rotina que disparou o cancelamento
    @return logical
    @see GetTransAproved
	@see TransacCanc
/*/

Method PermiteCancelar(nValor, cIdtran, cProcTran, cFormaPgto, cRotina,cExtTran) Class LJCComPaymentHub

Local cStatus    := ""
Local lAprovado  := .F.
Local lCancela   := .T.//Iniciado como .T. pois rotinas automáticas (IsBlind) não passam pelo bloco de validação e devem prosseguir com o cancelamento por padrão.
Local cValorTran := ""
Local oPgDigital := Nil

	LjGrvLog("Totvs Pagamentos Digitais","PermiteCancelar- Cancelamento solicitado pela rotina: ",cRotina,,.T.)

	If  IsPDOrPix(cFormaPgto) .AND. !IsBlind()  // Se for PIX ou TPD e diferente de automatico

		cValorTran := Alltrim(Transform(nValor, "@E 999,999,999.99"))
					
		oPgDigital := PagamentosDigitais():New(Self:oPayHubAPI, cIdtran, nValor, cFormaPgto, Self:oCfgPayHub, cFormaPgto)
		
		lAprovado	:= oPgDigital:GetTransAproved(@cStatus,cExtTran)

		LjGrvLog("Totvs Pagamentos Digitais","PermiteCancelar- Transação aprovada?",lAprovado,,.T.)

		If  Upper(Alltrim(cRotina)) <> "GERENCIAIS" // Se o canncelamento não foi chamado pelo menu, apresenta mensagem na tela
			FWAlertHelp( STR0026 + cIdtran   + CHR(10) +;  //  Solução:  "Transaçao: "
                 STR0042 + cProcTran + CHR(10) +;  //                "Processo ID: "
                 STR0031 + cValorTran + CHR(10), ;  // "Valor: "
                 STR0046, ;  //  Problema: "O sistema identificou uma transação pendente..."
                 STR0028 )  //  Título:   "Totvs Pagamentos Digitais"
		EndIf

		lCancela := MsgNoYes(STR0045 + CHR(10)+CHR(13) + ; //"Confirma estorno da transação: "
                     STR0026 + cIdtran   + CHR(10) + ; //"Transaçao: "
                     STR0042 + cProcTran + CHR(10) + ; //"Processo ID: "
                     STR0043 + cStatus   + CHR(10) + ; //"Status:      "
                     STR0031 + cValorTran + CHR(10)+CHR(13), "Confirma?") //"Valor:       "
		
		If lCancela
			If !STFPROFILE(17)[1] // verifica se o caixa possui permissão para cancelamento TEF na SLF e Se o canncelamento não foi chamado pelo menu, apresenta mensagem na tela
				lCancela := .F.	
				LjGrvLog("Totvs Pagamentos Digitais","PermiteCancelar - Usuário sem permissão para cancelamento de transação", .T., .T.)
				FWAlertHelp( STR0026 + cIdtran   + CHR(10) +;  // Solução:  "Transaçao: "
					STR0042 + cProcTran + CHR(10) +;  //                "Processo ID: "
					STR0043 + cStatus   + CHR(10) +;  //                "Status: "
					STR0031 + cValorTran  + CHR(10), ;  // "Valor: "	
					STR0041, ;  //  Problema: "Usuário não possui permissão para cancelamento de transação"
					STR0028 )  // Título:   "Totvs Pagamentos Digitais"
			Else 
				LjGrvLog("Totvs Pagamentos Digitais","PermiteCancelar - Usuario confirmou cancelamento - Usuario - Codigo - Nome",{PswChave(RetCodUsr()),FwGetUserName(RetCodUsr())},.T.,.T.)	
			EndIf
		Else
			LjGrvLog("Totvs Pagamentos Digitais","PermiteCancelar - Usuario Não confirmou cancelamento - Usuario - Codigo - Nome",{PswChave(RetCodUsr()),FwGetUserName(RetCodUsr())},.T.,.T.)
		EndIf
		
		FreeObj(oPgDigital)
	EndIf
	


Return lCancela
