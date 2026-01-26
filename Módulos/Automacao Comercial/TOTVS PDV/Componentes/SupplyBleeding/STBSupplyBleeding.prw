#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STPOS.CH"           
#INCLUDE "STBSUPPLYBLEEDING.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "AUTODEF.CH"  
//-------------------------------------------------------------------
/*/{Protheus.doc} STBCrSupMov
Gera o movimentos de recebimentos(SE5) Conforme os Parametros recebidos	

@param   aValues
					01 - TYPEOPERATION        				// 01 - Tipo da rotina: (1) Sangria / Entrada de troco (2) 
					02 - CASHIER_ORIGIN        				// 02 - Codigo do caixa de origem
					03 - CASHIER_DESTINY	        		// 03 - Codigo do caixa de destino
					04 - VALUE_MONEY						// 04 - Valor em dinheiro
					05 - VALUE_CHECK       					// 05 - Valor em cheque
					06 - VALUE_CREDITCARD      				// 06 - Valor em cartao de credito
					07 - VALUE_DEBITCARD					// 07 - Valor em cartao de debito
					08 - VALUE_FINANCED    					// 08 - Valor em financiado
					09 - VALUE_COVENANT        				// 09 - Valor em convenio
					10 - VALUE_COUPONS						// 10 - Valor em vales
					11 - VALUE_OTHERS        				// 11 - Valor em outros		
					12 - AGENCY                             // 12 - Numero da conta
					13 - DV_AGENCY 				         	// 13 - Digito da agencia
					14 - ACCOUNT				            // 14 - Numero da conta
					15 - DV_ACCOUNT         			    // 15 - Digito da conta	
					16 - VALUE_PD         			     	// 16 - Valor em pagamento digital		
					17 - VALUE_PIX         			     	// 17 - Valor em PIX		
@param   cCoin 		Moeda corrente
	
@author  Varejo
@version P11.8
@since   23/07/2012
@return  lRet 	Retorna se realizou o suplimento de caixa
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBCrSupMov( aValues , nCoin , lOnlyBleeding )

Local aNumerarios 		:= {}				// Numerarios
Local nX				:= 0 				// Contador
Local nTotal 			:= 0				// Total dos Numerarios
Local cNumCup			:= ""				// Numero do cupom
Local cSimb 			:= ""				// Simbolo
Local lRet				:= .F.				// Retorno da funcao
Local cFormSup			:= "" 				// forma de pagamento do suprimento/sangria
Local nI     			:= 0   				// Contador
Local aFormas 			:= {} 				// Array das formas 
Local nPos				:= 0  				// Posicao da forma
Local aRet				:= {}  				// Retorno de stategy
Local aDados			:= {} 				// Numero do cupom
Local cSerie			:= IIF(!Empty(STFGetStation("LG_SERNFIS")),STFGetStation("LG_SERNFIS"),SuperGetMv("MV_LJSERE5", .F., "SE5")) //Serie da Sangria/Suprimento
Local oBPgtos 			:= STBWCPayment():STBWCPayment() 	//Obj de Pagamentos
Local oPgtos 			:= oBPgtos:oPayX5:GetAllData() 		//Obj de Pagamentos
Local oMdlPgtos  		:= oPgtos:GetModel("GridStr") 		//Pega Model dos Pagamentos
Local lEmitNfce			:= Iif(FindFunction("LjEmitNFCe"), LjEmitNFCe(), .F.) // Sinaliza se utiliza NFC-e
Local aNotas			:= {} 				//Array de Notas
Local nMVLJ350MV		:= SuperGetMv("MV_LJ350MV", ,2) // Gerar movimentacao bancaria SE5 para todas as formas de pagamento ou somente dinheiro | 1 = Somente Dinheiro | 2 = Todas
Local cOrigemMov		:= STFGetStation("CODIGO") // Codigo da Estação para rastreio na SE5 - Sera gravado no campo E5_ORIGEM

Default aValues			:= 	{}					// Array de valores para operacao	    
Default nCoin			:= STBGetCurrency()		// Moeda corrente
Default lOnlyBleeding	:= .F.					//Realiza apenas a sangria na impressora

ParamType 0 Var   aValues 		As Array		Default 	{}
ParamType 1 Var 	nCoin 		    As Numeric		Default 	STBGetCurrency()	
     
// Soma os valores recebidos  
nTotal :=	(	aValues[VALUE_MONEY] 		+ ;
				aValues[VALUE_CHECK] 		+ ;
				aValues[VALUE_CREDITCARD]	+ ;
				aValues[VALUE_DEBITCARD] 	+ ;
				aValues[VALUE_FINANCED] 	+ ;
				aValues[VALUE_COVENANT] 	+ ;
				aValues[VALUE_COUPONS] 		+ ;
				aValues[VALUE_OTHERS] 		+ ;
				aValues[VALUE_PD]			+ ;
				aValues[VALUE_PIX]			 )

									
If nTotal > 0

	cSimb 	:= GetMV("MV_SIMB"+LTrim(Str(nCoin)))
		
	If  aValues[TYPEOPERATION] == 2  //suprimento
	
		aFormas := { {cSimb, "DINHEIRO"}		,;
		             {"CC", "CARTAO CREDITO"}	,;
		             {"CD", "CARTAO DEBITO"}	,;
		             {"FI", "FINANCIADO"}		,;
		             {"CO", "CONVENIO"}			,;
		             {"VA", "VALES"}			,;
		             {"OU", "OUTROS"}			,;
					  {"PD", "PAGAMENTO DIGITAL"},;
					 {"PX", "PIX"} }				


		//Carrega as formas de pagamento
	 	For nI := 1 To oMdlPgtos:Length()
	
			oMdlPgtos:GoLine(nI)

	        If ( nPos := aScan(aFormas, { |f| AllTrim(oMdlPgtos:GetValue("X5_TYPE")) == f[1]  } ) ) > 0
	        	aFormas[nPos,2] := oMdlPgtos:GetValue("X5_DESC")
	        EndIf
	   
		Next
		
		// Limpa OBJ
		oMdlPgtos 		:= FreeObj(oMdlPgtos)
		oPgtos	  		:= FreeObj(oPgtos)   
		oBPgtos	  	:= FreeObj(oBPgtos) 
		
		
	
		If aValues[VALUE_MONEY]  > 0  
			cFormSup	:= aFormas[VALUE_MONEY,2]  + "|" + STRZERO(aValues[VALUE_MONEY] , 10,2)+"|" //DINHEIRO
		EndIf
		If aValues[VALUE_CHECK]  > 0			     
			cFormSup = cFormSup + aFormas[VALUE_CHECK, 2] + "|" + STRZERO( aValues[VALUE_CHECK], 10,2)+"|" //CHEQUE
		EndIf	
		If aValues[VALUE_CREDITCARD] > 0			     
			cFormSup = cFormSup + aFormas[VALUE_CREDITCARD, 2] + "|" + STRZERO(aValues[VALUE_CREDITCARD], 10,2)+"|" //CARTAO CREDITO
		EndIf	
		If aValues[VALUE_DEBITCARD] > 0			     
			cFormSup = cFormSup + aFormas[VALUE_DEBITCARD, 2] + "|" + STRZERO(aValues[VALUE_DEBITCARD], 10,2)+"|" //CARTAO DEBITO
	 	EndIf	
		If aValues[VALUE_FINANCED] > 0			     
			cFormSup = cFormSup + aFormas[VALUE_FINANCED, 2] + "|" + STRZERO(aValues[VALUE_FINANCED], 10,2)+"|" //FINANCIADO
		EndIf	
		If aValues[VALUE_COVENANT] > 0			     
			cFormSup = cFormSup + aFormas[VALUE_COVENANT, 2] + "|" + STRZERO(aValues[VALUE_COVENANT], 10,2)+"|" //CONVENIO
		EndIf
		If aValues[VALUE_COUPONS] > 0			     
			cFormSup = cFormSup +aFormas[VALUE_COUPONS,2] + "|" + STRZERO(aValues[VALUE_COUPONS], 10,2)+"|" //VALES
		EndIf

		If aValues[VALUE_PD] > 0			     
			cFormSup = cFormSup + aFormas[VALUE_PD,2] + "|" + STRZERO(aValues[VALUE_PD], 10,2)+"|" //PAGAMENTO DIGITAL
		EndIf
		
		If aValues[VALUE_PIX] > 0			     
			cFormSup = cFormSup + aFormas[VALUE_PIX,2] + "|" + STRZERO(aValues[VALUE_PIX], 10,2)+"|" //PIX
		EndIf

		If aValues[VALUE_OTHERS] > 0			     
			cFormSup = cFormSup + aFormas[VALUE_OTHERS,2] + "|" + STRZERO(aValues[VALUE_OTHERS], 10,2)+"|" //OUTROS
		EndIf	
		

	EndIf	
	
	If 	lEmitNfce
		lRet := STBImpSupNFCE(aValues[TYPEOPERATION],ntotal)
		If lRet .AND. Empty(cNumCup)
			LjxDNota( cSerie, 3, .F., 1, @aNotas,,,,,,,,,,,,, "DOCNF" ) // DOC/SERIE

			If Len(aNotas) > 0 .AND. Len(aNotas[1]) > 1
				cNumCup := cDoc := aNotas[1][2]
			EndIf
			
			lRet := !Empty(cNumCup)
	
		EndIf
	Else
		cSerie := "" //Serie é padrão (cadastro de estações)
	EndIf
		
	If !STFGetCfg("lUsesNotFiscal")	.AND. !lEmitNfce				
		
		aRet :=   STFFireEvent(ProcName(0), ;
							"STSupply", ;
							{ IIF( aValues[TYPEOPERATION] == 1 , 3 ,aValues[TYPEOPERATION] ) , StrZero(nTotal,14,2) , "" , "" ,;
							  NIL, cFormSup  } 	)  // Suprimento //Sangria

		If ValType(aRet[1]) == "U" .OR. aRet[1] == 0
		    
		   cNumCup := space(STBLenReceipt())						//Numero do Cupom   
		   aDados := {cNumCup, Nil} 
			aRet 	:= 	STFFireEvent(	ProcName(0)						,;		// Nome do processo
										"STGetReceipt"					,;		// Nome do evento
										aDados )
			
			If Len(aRet) == 0 .OR. aRet[1] <> 0 .OR. Len(aDados) == 0      
			   	STFShowMessage( STR0001, "STGetReceipt" ) //"Falha na obtenção do cupom"
			Else
				cNumCup 	:= aDados[1]				
			EndIf	
			
			lRet := .T.	
			
		Else
		
			lRet := .F.	
			STFMessage("STSupply","STOP",STR0002) //"Atencao, Nao foi possivel registrar Sangria/Troco no ECF. Operacao nao efetuada."
			STFShowMessage("STSupply")
				
		EndIf 
	
	EndIf
	
	
	// Monta o array de numerarios
	LjGrvLog( aValues[CASHIER_ORIGIN] , "Sangria | STBSupplyBleeding | STBCrSupMov | MV_LJ350MV -> ", nMVLJ350MV)

	If nMVLJ350MV == 1
		aNumerarios := {	{cSimb,aValues[VALUE_MONEY]	}	} // Somente Dinheiro

	Else
		aNumerarios := {	{cSimb,aValues[VALUE_MONEY] 		},;
							{"CH",aValues[VALUE_CHECK]			},;
							{"CC",aValues[VALUE_CREDITCARD]		},;
							{"CD",aValues[VALUE_DEBITCARD]		},;
							{"FI",aValues[VALUE_FINANCED]		},;
							{"CO",aValues[VALUE_COVENANT]		},;
							{"VA",aValues[VALUE_COUPONS]		},;
							{"OU",aValues[VALUE_OTHERS]			},;
							{"PD",aValues[VALUE_PD]			    },;
							{"PX",aValues[VALUE_PIX]			}}
	EndIf
					
	If lRet .And. !lOnlyBleeding
		//Gravacao da SE5
		For nX := 1 to If(aValues[TYPEOPERATION]==1, Len(aNumerarios) ,1 )
				
				If aNumerarios[nX, 02] > 0 //Valida para não gravar SE5 vazio
										
					STDRecSup(	aValues[CASHIER_ORIGIN]	, "P"		, aNumerarios[nX],cNumCup	, ;
								nCoin		, aValues[TYPEOPERATION]	, cSerie , aValues[AGENCY] , aValues[ACCOUNT] , cOrigemMov )
								 	
										
					STDRecSup(	aValues[CASHIER_DESTINY]	, "R"		, aNumerarios[nX],  cNumCup	,;
								nCoin		, aValues[TYPEOPERATION]	, cSerie , aValues[AGENCY] , aValues[ACCOUNT] , cOrigemMov )
					
					// Chama função que faz a subtração dos valores da Sangria na tabela MGX
					If AliasIndic("MGX")
						STDGrvBleedingMGX(aNumerarios[nX]) 
					EndIf
				EndIf
			
		Next nX

		If nTotal > 0
			//Fazer a chamada da funcao para impressao do complemento da sangria (relatorio gerencial)
			STBCompSan(Iif(aValues[TYPEOPERATION] == 1,;
						aValues[CASHIER_DESTINY],;
						aValues[CASHIER_ORIGIN]),;								//Caixa Origem ou Destino
						 ,;														//Data
						 ,;														//Número da Movimentação
						 ,;														//[1]-CAIXA [2]-ESTACAO [3]-SERIE [4]-PDV
						 iIf(aValues[TYPEOPERATION] == 1,"SANGRIA","TROCO"))	//Operação: Sangria ou Suprimento
		Endif
	EndIf
	
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBSuppIni
Faz configuracao Inicial do array de valores

@param  	nTypeOpe  Tipo de operacao 1=Sangria | 2= Suprimento/Troco
@param   aValues
					01 - TYPEOPERATION        			// 01 - Tipo da rotina: (1) Sangria / Entrada de troco (2) 
					02 - CASHIER_ORIGIN        			// 02 - Codigo do caixa de origem
					03 - CASHIER_DESTINY	        		// 03 - Codigo do caixa de destino
					04 - VALUE_MONEY						// 04 - Valor em dinheiro
					05 - VALUE_CHECK       				// 05 - Valor em cheque
					06 - VALUE_CREDITCARD      			// 06 - Valor em cartao de credito
					07 - VALUE_DEBITCARD					// 07 - Valor em cartao de debito
					08 - VALUE_FINANCED    				// 08 - Valor em financiado
					09 - VALUE_COVENANT        			// 09 - Valor em convenio
					10 - VALUE_COUPONS						// 10 - Valor em vales
					11 - VALUE_OTHERS        			// 11 - Valor em outros
					 
@author  Varejo
@version P11.8
@since   23/07/2012
@return  aValues	Retorna com valores padrao
					01 - TYPEOPERATION        			// 01 - Tipo da rotina: (1) Sangria / Entrada de troco (2) 
					02 - CASHIER_ORIGIN        			// 02 - Codigo do caixa de origem
					03 - CASHIER_DESTINY	        		// 03 - Codigo do caixa de destino
					04 - VALUE_MONEY						// 04 - Valor em dinheiro
					05 - VALUE_CHECK       				// 05 - Valor em cheque
					06 - VALUE_CREDITCARD      			// 06 - Valor em cartao de credito
					07 - VALUE_DEBITCARD					// 07 - Valor em cartao de debito
					08 - VALUE_FINANCED    				// 08 - Valor em financiado
					09 - VALUE_COVENANT        			// 09 - Valor em convenio
					10 - VALUE_COUPONS						// 10 - Valor em vales
					11 - VALUE_OTHERS        			// 11 - Valor em outros

@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBSuppIni( nTypeOpe , aValues)
Local nTamSA6		:= 0	

Default nTypeOpe := 0				// Tipo de operacao 1=Sangria | 2= Suprimento/Troco
Default aValues 	:= Array(17)	// Array de valores para operacao

ParamType 0 Var 	nTypeOpe 		As Numeric		Default 	0
ParamType 1 Var   aValues 		As Array		Default 	Array(12)

// Se o array nao estiver completo Zera
If ( Len(aValues) < 17 )
	aValues := Array(17)
EndIf

//Guarda o Tipo de operacao 
If Empty(aValues[TYPEOPERATION])
	aValues[TYPEOPERATION] := nTypeOpe
EndIf 

//Carrega Origem e destino padrao caso nao tenha recebido
If Empty(aValues[CASHIER_ORIGIN]) .OR. Empty(aValues[CASHIER_DESTINY])
	If nTypeOpe = 2
		//Se Suplimento/Troco o caixa destino sempre eh o operador atual
		aValues[CASHIER_DESTINY] 	:= xNumCaixa()
		//Se caixa origem for igual ao caixa destino, então houve manipulação do array
		If (aValues[CASHIER_ORIGIN] = aValues[CASHIER_DESTINY]) .OR. Empty(aValues[CASHIER_ORIGIN])
			nTamSA6 :=  At("/", "MV_CXLOJA") -1 
			If nTamSA6 <= 0
				nTamSA6 := SA6->(TamSx3("A6_COD"))[1]
			EndIf
			aValues[CASHIER_ORIGIN] 		:= Substr(GetMv("MV_CXLOJA"),1,nTamSA6)
		EndIf

	Else
		// Se sangria o caixa origem sempre eh o operador atual
		aValues[CASHIER_ORIGIN] 		:= xNumCaixa()
		If  (aValues[CASHIER_DESTINY]  = aValues[CASHIER_ORIGIN]) .OR. Empty(aValues[CASHIER_DESTINY])
			nTamSA6 :=  At("/", "MV_CXLOJA") -1 
			If nTamSA6 <= 0
				nTamSA6 := SA6->(TamSx3("A6_COD"))[1]
			EndIf
			aValues[CASHIER_DESTINY] 	:= Substr(GetMv("MV_CXLOJA"),1,nTamSA6)
		EndIf
	EndIf
EndIf

//Zera os valores do array que estao vazios 
If Empty(aValues[VALUE_MONEY])
	aValues[VALUE_MONEY] := 0
EndIf 

If Empty(aValues[VALUE_CHECK])
	aValues[VALUE_CHECK] := 0
EndIf 

If Empty(aValues[VALUE_CREDITCARD])
	aValues[VALUE_CREDITCARD] := 0
EndIf 

If Empty(aValues[VALUE_DEBITCARD])
	aValues[VALUE_DEBITCARD] := 0
EndIf 

If Empty(aValues[VALUE_FINANCED])
	aValues[VALUE_FINANCED] := 0
EndIf 

If Empty(aValues[VALUE_COVENANT])
	aValues[VALUE_COVENANT] := 0
EndIf 

If Empty(aValues[VALUE_COUPONS])
	aValues[VALUE_COUPONS] := 0
EndIf 

If Empty(aValues[VALUE_PD])
	aValues[VALUE_PD] := 0
EndIf

If Empty(aValues[VALUE_PIX])
	aValues[VALUE_PIX] := 0
EndIf

If Empty(aValues[VALUE_OTHERS])
	aValues[VALUE_OTHERS] := 0
EndIf 

Return aValues

//-------------------------------------------------------------------
/*/{Protheus.doc} STBImpSupNFCE
Chamada principal para a tela do POS

@param
@author  Varejo
@version P11.8
@since   29/10/2014
@return
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function STBImpSupNFCE(nOperacao, nTotal)
Local lRet		:= .T.		// Retorno da função
Local cTexto	:= ""		// Texto que será impresso
Local cTotal	:= ""		// Total recebido
Local aID		:= LjInfoCxAt(1,.F.,.T.)	//[1]-CAIXA [2]-ESTACAO [3]-SERIE [4]-PDV
Local cNumMov	:= AllTrim(STDNumMov()) //Numero do movimento 
Local lGuil		:= SuperGetMV("MV_FTTEFGU",, .T.)	// Ativa guilhotina
Local cPLinha	:= CHR(10)+CHR(13)

Default nOperacao	:= 0
Default	nTotal		:= 0

cTotal := AllTrim(Str(nTotal))
If AT(".",cTotal)  == 0
	cTotal += ".00"
ElseIf Len(SubsTr(cTotal, AT(".",cTotal)+1)) == 1
	cTotal += "0"
EndIf     
cTotal := StrTran(cTotal,".", ",")

cTexto +=  SM0->M0_NOMECOM + cPLinha + cPLinha


If nOperacao == 1 //"SANGRIA"
	cTexto +=  TAG_CENTER_INI+TAG_NEGRITO_INI+STR0020 + " " + STR0044+TAG_NEGRITO_FIM+TAG_CENTER_FIM + cPLinha //"Saida de Caixa"###"(Acumulado)"
ElseIf nOperacao == 2 //"TROCO"
	cTexto += TAG_CENTER_INI+TAG_NEGRITO_INI+STR0037 + " " + STR0044+TAG_NEGRITO_FIM+TAG_CENTER_FIM + cPLinha //"Suprimento de Caixa"###"(Acumulado)"
EndIf

cTexto += "- - - - - - - - - - - - - - - - - - - - - - - -"		+ cPLinha
cTexto += STR0045 + PadR(cTotal, 29, "") 						+ cPLinha	//"VALOR        : R$ "
cTexto += STR0046 + PadR(DtoC(Date()) + " - " + Time(), 32, "")	+ cPLinha	//"DATA         : "
cTexto += STR0047 + PadR(aID[1][1], 32, "")						+ cPLinha	//"CAIXA        : "
cTexto += STR0041 + "      : "	+ PadR(aID[2][1], 32, "")		+ cPLinha	//"ESTACAO"
cTexto += STR0048 + PadR(aID[4][1], 32, "")						+ cPLinha	//"PDV          : "
cTexto += STR0042 + "     : "	+ PadR(cNumMov, 32, "")			+ cPLinha	//"NUM.MOV."
cTexto += "- - - - - - - - - - - - - - - - - - - - - - - -"		+ cPLinha
cTexto += STR0035 + " ________________________________" + Replic(cPLinha,2) //"Ass. Caixa   :"
cTexto += STR0036 + " ________________________________" + Replic(cPLinha,6) //"Ass. Superior:"

lRet := (STWPrintTextNotFiscal(cTexto) == 0)

If lGuil 
	cTexto := TAG_GUIL_INI+TAG_GUIL_FIM
	STWPrintTextNotFiscal(cTexto)
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBCompSan
Rotina para impressão detalhada de sangria e suprimento, através 
do relatório gerencial. Ativar pelo parâmetro MV_LJICMSA = .T.

@param	 cCxDest  : Caixa de destino, quando nao for o caixa geral 
@param	 dAbert   : Data de abertura do movimento 
@param	 cNumMov  : Numero do movimento
@param	 aID	  : 
@param   cOperacao: "SANGRIA" ou "TROCO" 
@author  Varejo
@version P12.1
@since   10.08.2010
@return
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STBCompSan(cCxDest,dAbert,cNumMov,aID,cOperacao)
Local aArea				:= GetArea()
Local lImpComp			:= SuperGetMV("MV_LJICMSA",.F.,.F.)	//Imprimir complemento da sangria?
Local lContMovSE5		:= .T.
Local nI				:= 0
Local nX				:= 0
Local nPos				:= 0
Local aNumerario		:= {}	//Tabela que armanezara toda a somatoria das entradas de : 1.troco 2.sangria 3.vendas 4.valores digitados na conferencia
Local cChave			:= ""
Local aCxDest			:= {}
Local nTamCx			:= TamSX3("A6_COD")[1]
Local cLinSep			:= ""
Local nValTMP			:= 0
Local cMasc				:= "@E 999,999,999.99"
Local cFiltro			:= ""
Local aFormExtra		:= {}
Local lEmitNFCe         := ExistFunc("LjEmitNFCe") .AND. LjEmitNFCe()     //Indica a utilizacao da NFC-e
Local cTagNegrIni		:= Iif( lEmitNFCe, TAG_NEGRITO_INI, "" )
Local cTagNegrFim		:= Iif( lEmitNFCe, TAG_NEGRITO_FIM, "" )
Local cTexto			:= ""						//Texto para impressão
Local nCols				:= IIf(!Empty(LJGetStation("LG_LARGCOL")),LJGetStation("LG_LARGCOL"),40)
Local nColsUtil			:= nCols - 2
Local cCol				:= "-"
Local lRet				:= .T.		//Retorno
Local lPOS				:= STFIsPOS()													//Pos?
Local cModelo			:= IIF(lPOS,STFGetStation("IMPFISC"),LjGetStation("IMPFISC"))	//Modelo da impressora configurada

Default cCxDest	   		:= Substr(AllTrim(SuperGetMV("MV_CXLOJA",.F.,"")),1,3)
Default dAbert			:= Date()
Default cNumMov	  		:= AllTrim(LjNumMov())
Default aID 			:= LjInfoCxAt(1,.F.,.T.)		//[1]-CAIXA [2]-ESTACAO [3]-SERIE [4]-PDV [5] - SERIE NÃO FISCAL
Default cOperacao		:= ""

//Se nao imprime complemento de sangria, os parametros forem indevidos ou se o dicionario nao estiver atualizado, sair
If !lImpComp .OR. Empty(cCxDest) .OR. ValType(dAbert) # "D" .OR. Empty(cNumMov) .OR.;
	 ValType(cNumMov) # "C" .OR. ValType(aID) # "A" .OR. Len(aID)  < 4
	
	lRet := .F.
Endif

//Tratamento exclusivo para a MP-4200 HS pois existe uma limitação da 
//DLL do fabricante em interpretar os comandos desse relatorio
If "BEMATECH MP-4200 HS" $ cModelo
	nCols := 47
	nColsUtil := nCols - 2
EndIf

If lRet
	//Definir array com dados do caixa de destino
	If AllTrim(cCxDest) == AllTrim(SuperGetMV("MV_CXLOJA",.F.,""))
		aAdd(aCxDest,Substr(AllTrim(cCxDest),1										,nTamCx))				//Banco
		aAdd(aCxDest,Substr(AllTrim(cCxDest),nTamCx + 2							,TamSX3("A6_AGENCIA")[1]))	//Agência
		aAdd(aCxDest,Substr(AllTrim(cCxDest),nTamCx + TamSX3("A6_AGENCIA")[1] + 3	,nTamCx))				//Conta
	Else
		//Por alguma razao desconhecida, a pesquisa do caixa geral
		//pode falhar atraves do dbseek, por conta disso foi
		//criado um filtro. Nao alterar! 
		dbSelectArea("SA6")
		SA6->(dbSetOrder(1))	//A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
		cFiltro := "A6_FILIAL = '" + xFilial("SA6") + "' .AND. A6_COD = '" + PadR(cCxDest,TamSX3("A6_COD")[1]) + "'"
		SA6->(dbSetFilter({|| &cFiltro},cFiltro))
		SA6->(dbGoTop())
		If !SA6->(Eof())
			aAdd(aCxDest,AllTrim(SA6->A6_COD))
			aAdd(aCxDest,AllTrim(SA6->A6_AGENCIA))
			aAdd(aCxDest,AllTrim(SA6->A6_NUMCON))
			aAdd(aCxDest,AllTrim(SA6->A6_NOME))
		Else
			//Caixa de destino sugerido nao encontrado, sair
			SA6->(dbClearFilter())
			lRet := .F.		
		Endif
		SA6->(dbClearFilter())
	Endif
EndIf

If lRet
	//Montar a array de formas de pagamento
	cChave := xFilial("SX5") + "24"
	dbSelectArea("SX5")
	SX5->(dbSetOrder(1))		//X5_FILIAL+X5_TABELA+X5_CHAVE
	SX5->(dbSeek(cChave))
	If SX5->(Found())
		Do While !SX5->(Eof()) .AND. RTrim(SX5->(X5_FILIAL + X5_TABELA)) == cChave
			If !SX5->(Deleted())
				/*
				1. Forma pagto reduzido 
				2. Troco,Sangria,Vendas,Valores digitados na conferencia (valor , quantidade)
				3. Forma pagto completo
				*/
				aAdd(aNumerario,{SX5->X5_CHAVE,{{0,0},{0,0},{0,0},{0,0}},SX5->X5_DESCRI})
			Endif
			SX5->(dbSkip())
		EndDo
	
		aAdd(aFormExtra, {"SG" , STR0030}) //"SANGRIA"
		aAdd(aFormExtra, {"TC" , STR0031}) //"ENTRADA DE TROCO"
		aAdd(aFormExtra, {"REC", STR0032}) //"RECEBIMENTOS"
		aAdd(aFormExtra, {"CB" , STR0033}) //"CORRESPONDENTES BANCARIOS"
		aAdd(aFormExtra, {"RCE", STR0034}) //"RECARGA DE CELULAR"
	
		For nI := 1 To Len(aFormExtra)
			aAdd(aNumerario,{aFormExtra[nI][1],{{0,0},{0,0},{0,0},{0,0}},aFormExtra[nI][2]})
		Next 
	
	Else
		lRet := .F.
	Endif
EndIf

If lRet
	//Procurar movimentos de entrada de troco no SE5
	cChave := RTrim(xFilial("SE5") + DtoS(dAbert) + aID[1][1])
	dbSelectArea("SE5")
	SE5->(dbSetOrder(1))	//E5_FILIAL+DTOS(E5_DATA)+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ
	SE5->(dbSeek(cChave))
	Do While !SE5->(Eof()) .AND. RTrim(SE5->(E5_FILIAL + DTOS(E5_DATA) + E5_BANCO)) == cChave
		//Se o movimento nao for de recebimento, se estiver cancelado ou se nao for um movimento de transferencia, saltar
		If SE5->E5_RECPAG # "R" .OR. SE5->E5_SITUACA == "C" .OR. SE5->E5_TIPODOC # "TR" .OR. SE5->E5_MOEDA # "TC" //Troco
			SE5->(dbSkip())
			Loop
		Endif
		//Caso exista controle de numero de movimento, validar
		If lContMovSE5
			If !Empty(SE5->E5_NUMMOV) .AND. AllTrim(SE5->E5_NUMMOV) # cNumMov
				SE5->(dbSkip())
				Loop
			Endif
		Endif		
		If (nPos := aScan(aNumerario,{|x| AllTrim(x[1]) == AllTrim(SE5->E5_MOEDA)})) > 0
			aNumerario[nPos][2][1][1] += SE5->E5_VALOR
			aNumerario[nPos][2][1][2] += 1
		Endif
		SE5->(dbSkip())
	EndDo
	
	//Procurar movimentos de Recebimentos no SE5
	cChave := RTrim(xFilial("SE5") + DtoS(dAbert) + aID[1][1])
	dbSelectArea("SE5")
	SE5->(dbSetOrder(1))	//E5_FILIAL+DTOS(E5_DATA)+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ
	SE5->(dbSeek(cChave))
	Do While !SE5->(Eof()) .AND. RTrim(SE5->(E5_FILIAL + DTOS(E5_DATA) + E5_BANCO)) == cChave
		//Se o movimento nao for de recebimento, se estiver cancelado ou se nao for um movimento de transferencia, saltar
		If SE5->E5_RECPAG <> "R" .OR. SE5->E5_TIPO <> "FI" .OR. SE5->E5_TIPODOC # "VL"
			SE5->(dbSkip())
			Loop
		Endif
		//Caso exista controle de numero de movimento, validar
		If lContMovSE5
			If !Empty(SE5->E5_NUMMOV) .AND. AllTrim(SE5->E5_NUMMOV) # cNumMov
				SE5->(dbSkip())
				Loop
			Endif
		Endif
		If (nPos := aScan(aNumerario,{|x| AllTrim(x[1]) == "REC" })) > 0
			aNumerario[nPos][2][3][1] += SE5->E5_VALOR
			aNumerario[nPos][2][3][2] += 1
		Endif
		SE5->(dbSkip())
	EndDo
	
	//Procurar movimentos de Recarga de Cel. no SE5
	cChave := RTrim(xFilial("SE5") + DtoS(dAbert) + aID[1][1])
	dbSelectArea("SE5")
	SE5->(dbSetOrder(1))	//E5_FILIAL+DTOS(E5_DATA)+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ
	SE5->(dbSeek(cChave))
	Do While !SE5->(Eof()) .AND. RTrim(SE5->(E5_FILIAL + DTOS(E5_DATA) + E5_BANCO)) == cChave
		//Se o movimento nao for de recebimento, se estiver cancelado ou se nao for um movimento de transferencia, saltar
	
		If Upper(AllTrim(SE5->E5_HISTOR)) <> Upper(STR0034) .OR. SE5->E5_TIPODOC # "VL"	//"RECARGA DE CELULAR"
			SE5->(dbSkip())
			Loop
		Endif
		//Caso exista controle de numero de movimento, validar
		If lContMovSE5
			If !Empty(SE5->E5_NUMMOV) .AND. AllTrim(SE5->E5_NUMMOV) # cNumMov
				SE5->(dbSkip())
				Loop
			Endif
		Endif
		If (nPos := aScan(aNumerario,{|x| AllTrim(x[1]) == "RCE" })) > 0
			aNumerario[nPos][2][3][1] += SE5->E5_VALOR
			aNumerario[nPos][2][3][2] += 1
		Endif
		SE5->(dbSkip())
	EndDo
	
	//Procurar movimentos de sangria (saida) no SE5
	cChave := RTrim(xFilial("SE5") + DtoS(dAbert) + aID[1][1])
	dbSelectArea("SE5")
	SE5->(dbSetOrder(1))	//E5_FILIAL+DTOS(E5_DATA)+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ
	SE5->(dbSeek(cChave))
	Do While !SE5->(Eof()) .AND. RTrim(SE5->(E5_FILIAL + DTOS(E5_DATA) + E5_BANCO)) == cChave
		//Se o movimento nao for de recebimento, se estiver cancelado ou se nao for um movimento de transferencia, saltar
		If SE5->E5_RECPAG # "P" .OR. SE5->E5_SITUACA == "C" .OR. SE5->E5_TIPODOC # "TR"
			SE5->(dbSkip())
			Loop
		Endif
		//Caso exista controle de numero de movimento, validar
		If lContMovSE5
			If !Empty(SE5->E5_NUMMOV) .AND. AllTrim(SE5->E5_NUMMOV) # cNumMov
				SE5->(dbSkip())
				Loop
			Endif
		Endif	
		If (nPos := aScan(aNumerario,{|x| AllTrim(x[1]) == AllTrim(SE5->E5_MOEDA)})) > 0
			aNumerario[nPos][2][2][1] += SE5->E5_VALOR
			aNumerario[nPos][2][2][2] += 1
		Endif
		SE5->(dbSkip())
	EndDo
	
	cLinSep := "+" + Replicate("-",nCols) + "+"
	//Cabecalho - para todos os modelos
	//Alinhar a primeira estrutura ao centro e usar delimitadores
	cTexto += Replic(cCol,nCols) + CRLF
	If cOperacao == "SANGRIA"
		cTexto += cTagNegrIni+PadC(STR0020 + " " + STR0044,nCols)+cTagNegrFim + CRLF	//#"Saida de Caixa" ##"(Acumulado)"
	ELseIf cOperacao == "TROCO"
		cTexto += cTagNegrIni+PadC(STR0037 + " " + STR0044,nCols)+cTagNegrFim + CRLF	//#"Suprimento de Caixa" ##"(Acumulado)"
	EndIf
	cTexto += CRLF
	cTexto += PadR("DATA",13) + ": " + PadR(DtoC(Date()),nCols - 13) + CRLF
	cTexto += PadR(Iif(cOperacao=="TROCO", STR0039,STR0040),13) + ": " + PadR(aID[1][1] + "-" + GetAdvfVal("SA6","A6_NOME",xFilial("SA6") + RTrim(aID[1][1]),1),nCols - 13) + CRLF //#"CX.DESTINO" ##"CX.ORIGEM"
	cTexto += PadR(Iif(cOperacao=="TROCO", STR0040,STR0039),13) + ": " + PadR(aCxDest[1] + "-" + aCxDest[4],nCols - 13) + CRLF //#"CX.ORIGEM" ##"CX.DESTINO"
	cTexto += PadR(STR0041,13) + ": " + PadR(aID[2][1],nCols - 13) + CRLF	//#"ESTACAO"
	cTexto += PadR("PDV",13) + ": " + PadR(aID[4][1],nCols - 13) + CRLF
	cTexto += PadR(STR0042,13) + ": " + PadR(cNumMov,nCols - 13) + CRLF	//#"NUM.MOV."
	cTexto += cLinSep + CRLF
	
	/*
	ARRAY COM NUMERARIO E DETALHES
	aNumerario = Elemento 2
	[1] Troco 								(Valor , Quantidade)
	[2] Sangria 							(Valor , Quantidade)
	[3] Vendas 								(Valor , Quantidade)
	[4] Valores digitados na conferencia 	(Valor , Quantidade)
	*/
	Do Case
		Case cOperacao == "SANGRIA"		//Sangria
			Eval({|| nValTMP := 0, aEval(aNumerario,{|x| nValTMP += x[2][2][1]})})
			cTexto += PadR(STR0043,20) + ":" + Transform(nValTMP,cMasc) + CRLF //#"RETIRADAS"
			cTexto += Replic(cCol,nCols) + CRLF
			For ni := 1 to Len(aNumerario)
				If aNumerario[ni][2][2][1] > 0
					cTexto += PadR(aNumerario[ni][3],20) + ":" + Transform(aNumerario[ni][2][2][1],cMasc) + CRLF
				Endif
			Next ni
			
		Case cOperacao == "TROCO"		//Suprimento
			Eval({|| nValTMP := 0, aEval(aNumerario,{|x| nValTMP += x[2][1][1]})})
			cTexto += PadR(STR0031,20) + ":" + Transform(nValTMP,cMasc) + CRLF //#"ENTRADA DE TROCO"
			cTexto += Replic(cCol,nCols) + CRLF
			For ni := 1 to Len(aNumerario)
				If aNumerario[ni][2][1][1] > 0
					cTexto += PadR(aNumerario[ni][3],20) +":" + Transform(aNumerario[ni][2][1][1],cMasc)+ CRLF
				Endif
			Next ni
	End Case
	
	//Assinaturas
	cTexto += Replic(cCol,nCols) + CRLF
	cTexto += CRLF
	cTexto += STR0035 + " " +Replic( "_",nCols-15 ) + CRLF //#->"Ass. Caixa   :"
	cTexto += CRLF
	cTexto += STR0036 + " " +Replic( "_",nCols-15 ) + CRLF //#->"Ass. Superior:"
	cTexto += cLinSep + CRLF
	
	//Imprimir o relatorio gerencial
	STWManagReportPrint( cTexto ,1 )
EndIf

RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} STBCashList
Retorna array com os caixas agências e contas cadastrados respeitando o parâmetro MV_CXLOJA  
 
@author  Varejo
@version P12.1.17
@since   06/02/2018
@return  aCashList 	Retorna array com caixas cadastrados conforme SA6
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBCashList()

Local aCashList   := {}
Local aStation	:= STBInfoEst( 1, .T. )
Local aCaixas		:= STIGetSA6(aStation[1])

Local cComboCx   := AllTrim(SuperGetMv("MV_CXLOJA",.F.,"")) // Caixa Geral 
Local aComboCx   := StrTokArr( cComboCx, '/' ) 
Local cCodBanco  := PadR(aComboCx[1],TamSX3("A6_COD")[1],)
Local cCodAgen   := PadR(aComboCx[2],TamSX3("A6_AGENCIA")[1],)
Local cNumCon    := PadR(aComboCx[3],TamSX3("A6_NUMCON")[1],)
Local nCxGeral   := 0 

Local nX         := 0
Local nCaixas	   := 0

For nX:= 1 to Len(aCaixas)
	If cCodBanco $ aCaixas[nX][1][1] .AND. cCodAgen $ aCaixas[nX][1][1] .AND. cNumCon $ aCaixas[nX][1][1]
	   nCxGeral := nX
	   
	   AADD(aCashList,aCaixas[nCxGeral][1][1]) 
	   For nCaixas := 1 to len(aCaixas)
	       If nCaixas <> nCxGeral
		       AADD(aCashList,aCaixas[nCaixas][1][1])
		   EndIf
	   Next
	   	   
	   Exit	   
	EndIf
Next nX

If nCxGeral == 0 
   For nCaixas := 1 to len(aCaixas)
	   AADD(aCashList,aCaixas[nCaixas][1][1])
   Next  
EndIf

Return aCashList
