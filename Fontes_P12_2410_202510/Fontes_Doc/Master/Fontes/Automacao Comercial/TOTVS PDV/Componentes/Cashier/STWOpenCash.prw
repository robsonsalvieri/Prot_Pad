#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STPOS.CH"        
#INCLUDE "STWOPENCASH.CH"

Static lOpenPDV := .F. //Variavel de controle, indica se é uma abertura de caixa para a rotina de suprimento

//  CAIXA_FECHADO        		1 // Caixa foi fechado pelo operador
//  TROCOU_OPERADOR	        	2 // Houve troca de operador
//  ULTIMO_OPERADOR				3 // Ultimo operador que usou o sistema e nao fechou caixa

//-------------------------------------------------------------------
/*/{Protheus.doc} STWPOSOpenCash
Function abertura de caixa

@param   
@author  Varejo
@version P11.8
@since   29/06/2012
@return  lOpenCash 	Retorna se o caixa esta aberto
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STWPOSOpenCash()            
					
Local lUsaDisplay 		:= !Empty(STFGetStation("DISPLAY")) 		// Verifica se a estacao possui Display
Local lOpenCash			:= 	STBOpenCash()							// Caixa esta aberto
Local aStation			:= 	{}										// Array que guarda status da estacao operdores etc
Local cStation			:=  STFGetStation("CODIGO")					// Estacao atual
Local cNumMov			:= 	AllTrim(STDNumMov())					// Numero da movimento
Local cSupervisor		:=	Space(15)								// Supervisor que autorizou a transacao
Local dDataMovECF		:= dDataBase								// Data do movimento do ECF
Local cReduction		:= ""
Local nAtAux			:= 0
Local aReduction        := {}
Local lHomolPaf			:= STBHomolPaf()   
Local cMV_LJGRMR	 	:= IIF(STBIsPAF(SM0->M0_CGC), "S", SuperGetMv("MV_LJGRMR", ,"S")) 
/*/
	Verifica status da estacao e operador
/*/ 

aStation := STDStStation( cStation , cUserName )

//Se o caixa esta fechado
If !lOpenCash .AND. STWConfCash("1") 

    If lUsaDisplay
		// Inicia Evento
		STFFireEvent(ProcName(0), "STDisplay", { StatDisplay(), "1C" + STR0001 } )  //"A B E R T U R A   D E   C A I X A"
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   	//	 verifica se  houve troca do operador sem que houvesse o fechamento do caixa anterior , 
   	// caso ocorra não prossegue com a operacao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	If !Empty(aStation) .AND. !aStation[CAIXA_FECHADO]  .AND. aStation[TROCOU_OPERADOR]
		LjGrvLog( "Abertura de caixa", "[STWPOSOpenCash] - " + STR0005 + " " + AllTrim(aStation[ULTIMO_OPERADOR]) + " " + STR0006 )  //Gera LOG
		STFMessage("OpenCash","STOP", STR0005 +  " " + AllTrim(aStation[ULTIMO_OPERADOR]) + " "  + ;
				  STR0006) //"Atencao, O usuario nao fechou o caixa. Favor iniciar com este usuario e fechar o caixa."	
		lOpenCash := .F.	
	elseIf STWOpenCash( @cSupervisor	) 		  	  
		lOpenCash := .T.  

		// Grava que foi realizada abertura de caixa, na tabela de Monitoramento das Estacoes(SLI)
		STFSLICreate(cEstacao, "OPE", If(Empty(cSupervisor),cUserName,cSupervisor), "SOBREPOE")
			
		//Se nao conseguiu criar arquivo de semaforo
		If !STBTraffic("OPE", cEstacao)
			
			STFMessage("OpenCash","STOP", STR0002 + ;
						STR0003)            //"Atencao, Nao foi possivel inicializar o semaforo de Abertura de Caixa."
		EndIf                                                                                        //"Verifique se nao existe outra conexao do Front Loja."
		
		If lUsaDisplay
			// Inicia Evento
			STFFireEvent(ProcName(0), "STDisplay", { StatDisplay(), "2E"+ STR0004 } ) //  Exibir Mensagem "Codigo do Produto: " Significa que esta pronto p venda
			STFFireEvent(ProcName(0), "STDisplay", { StatDisplay(), "1E"+ " " } )
		EndIf	
			
	EndIf

// Se houve troca de operador add msg
ElseIf lOpenCash .AND. aStation[TROCOU_OPERADOR]
	STFMessage("OpenCash","STOP", STR0005 +  " " + AllTrim(aStation[ULTIMO_OPERADOR]) + " "  + ;
				  STR0006) //"Atencao, O usuario nao fechou o caixa. Favor iniciar com este usuario e fechar o caixa."
EndIf                                               

If !lOpenCash
	STFMessage("OpenCash","STOP", STR0007) //"Atencao, Não foi possivel abrir o caixa!"
Else

	// Se for o primeiro movimento do dia e usar PafECF
	// Cancela orcamentos vencidos 
	If STFGetCfg("lPafEcf")
	
		cNumMov := STDNumMov()
		If Val(cNumMov) == 1   
			If lHomolPaf
				cReduction := ""
				cReduction := cMV_LJGRMR + space(800)	//PROBLEMAS NO TIMEOUT, CAPTURA OS DADOS DA REDUCAO
				aDados := {cReduction}
				aRet := STFFireEvent(	ProcName(0)																,;		// Nome do processo
											"STRedZData"																,;		// Nome do evento
											aDados)	
		
				If Len(aRet) > 0 .AND. aRet[1] == 0 .AND. Len(aDados) > 0
					cReduction := aDados[1]
				Else
					cReduction := ""
				EndIf
				
				While Len(cReduction) > 0
					nAtAux := At("|", cReduction)
					If nAtAux > 0
						AAdd(aReduction, SUBS(cReduction,1,nAtAux-1) )
						cReduction := SUBS(cReduction, nAtAux + 1, LEN(cReduction) )
					Else
						cReduction := ""
					Endif
				End
		
				
				If Len(aReduction) >= 14  .AND. !Empty(aReduction[14])
					 dDataMovECF	:= CTOD(aReduction[01])		
				EndIf
			Else 
				dDataMovECF := STDZLastRZDt()
			EndIf

			STWCancOrc( dDataMovECF )
		EndIf	
	
	EndIf

	STFMessage("OpenCash","STOP", STR0008) //"Caixa Aberto!"
	
	//Seta variavel statica para nao permitir sair do sistema sem realizar a conferencia
	If FindFunction("STFSetPerExit")
		STFSetPerExit(.F.)
	EndIf
	
EndIf

STFShowMessage("OpenCash")

Return lOpenCash


//-------------------------------------------------------------------
/*/{Protheus.doc} STWOpenCash
Realiza Abertura do Caixa

@param   cSupervisor  Supervisor por referencia
@author  Varejo
@version P11.8
@since   04/07/2012
@return  lRet 	Retorna se o caixa foi aberto
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STWOpenCash( cSupervisor	)

Local dData				:= dDataBase				// Data
Local aDtHr				:= STBDtCash()			// Array data e hora
Local lRet				:= .F.						// Retorna se o caixa foi aberto
Local aRet				:= {}						// Array de retorno
Local aPermissao 		:= {}						// Verifica permissao
Local aDados				:= {}						// Array de informacoes do evento    
Local cNumMov    		:= ""						// Moviemnto
Local cCupomIni 			:= ""						// Cupom inicial
Local cCash 				:= xNumCaixa()			// Caixa
Local lEmitNfce		:= Iif(FindFunction("LjEmitNFCe"), LjEmitNFCe(), .F.) // Sinaliza se utiliza NFC-e


Default cSupervisor 	:= Space(15)		//	Supervisor

ParamType 0 Var 	cSupervisor	As Character	Default Space(15)	

// Verifica nas permissoes de usuario para abrir/reabrir caixa
aPermissao	:= STBAutOpenCash()
cSupervisor := aPermissao[2]

If aPermissao[1]

	lRet :=	 STDOpenCash( 	cCash		,	aDtHr[1]	, aDtHr[2]	)
	
	If lRet
	
		//Emite leitura X segundo a regra de negocios
		STBOpenLX()  	
		
		If STFGetCfg("lMultCoin") // Se usa Multimoeda
			// Abre caixas associados(tratamento multi-moeda)
			STDOpenMult( cCash	,	aDtHr[1]	, aDtHr[2]	)
		EndIf
		  	
		If lUsaDisplay
			// Inicia Evento
			STFFireEvent(ProcName(0), "STDisplay", { StatDisplay(), "1C"+" " } ) 
			STFFireEvent(ProcName(0), "STDisplay", { StatDisplay(), "2C"+" " } )
			STFFireEvent(ProcName(0), "STDisplay", { StatDisplay(), "0C" + STR0009 } ) //"CAIXA DISPONIVEL"		
		EndIf
		
		// Caixa tem acesso a utilizar Impressora Fiscal 
		If (STFProFile(3)[1]) 

			// Pega numero do cupom					
			cCupomIni := space(STBLenReceipt())						//Numero do Cupom
			If !lEmitNfce	
				aDados := {cCupomIni, Nil}
				aRet 	:= 	STFFireEvent(	ProcName(0)						,;		// Nome do processo
											"STGetReceipt"					,;		// Nome do evento
											aDados )
		
				If Len(aRet) == 0 .OR. aRet[1] <> 0 .OR. Len(aDados) == 0      
				   	STFShowMessage( STR0010 , "STGetReceipt" ) //"Falha na obtenção do cupom"
				Else
					cCupomIni 	:= aDados[1]
				EndIf
			Else
				//Se for nfce, captura o último documento
				cCupomIni := STDCSLastSale("L1_DOC")
			EndIf	
		
		EndIf	
						
		// Grava Movimento Processos de Venda(SLW)
		lRet := STDOSaveMov( aDtHr , Soma1( AllTrim(cCupomIni)	) )
		
	
	EndIf	

EndIf	
			

Return lRet 




//-------------------------------------------------------------------
/*/{Protheus.doc} STWOpenSupply
Function abertura de caixa com Troco.
Esta funcao faz chamadas das funcionalidades de abertura e depois de troco.
@param   nVlrTroco			Valor de troco
@author  Varejo
@version P11.8
@since   29/06/2012
@return  lOpenCash 	Retorna se abriu o caixa
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STWOpenSupply(nVlrTroco, cCxOrig, cCxDest, aCaixas, lAbreCx) 

Local lRet 			:= .T.				//	Retorno
Local aValues		:= Array(17)		// Array de valores para operacao
Local nCaixas 		:= 0
Local cAgencia 		:= ""				//Variavel que armazena a Agencia recebita pelo aCaixas
Local cDvage		:= ""				//Variavel que armazena o Digito da agencia recebita pelo aCaixas
Local cConta		:= ""				//Variavel que armazena a Conta recebita pelo aCaixas
Local cDvConta		:= ""				//Variavel que armazena o Digito da conta recebita pelo aCaixas
Local aStation		:= STBInfoEst(	1, .T. ) // Dados da estação

Default nVlrTroco	:= 0				// Valor de troco
Default cCxOrig := ""
Default cCxDest := ""
Default aCaixas := {}
Default lAbreCx	:= .F.					// Indica que foi acionada pela Abertura de caixa

For nCaixas :=  1 to len(aCaixas)
	If Alltrim(cCxOrig) == AllTrim(aCaixas[nCaixas][1][1])
		cAgencia := aCaixas[nCaixas][2][1]
		cDvage	 := aCaixas[nCaixas][2][2]
		cConta   := aCaixas[nCaixas][2][3]
		cDvConta := aCaixas[nCaixas][2][4]
		Exit
	EndIf
Next

cCxOrig := SubSTR(cCxOrig,1,TamSX3("A6_COD")[1])//Extraio apenas o A6_COD

If !Empty(cCxOrig)	
	aValues[CASHIER_ORIGIN]		:= cCxOrig
EndIf
If !Empty(cCxDest)	
	aValues[CASHIER_DESTINY]		:= cCxDest
EndIf

aValues[AGENCY] 	:= cAgencia
aValues[DV_AGENCY]	:= cDvage
aValues[ACCOUNT]	:= cConta
aValues[DV_ACCOUNT]	:= cDvConta

aValues[VALUE_MONEY] := nVlrTroco

lOpenPDV := .T.
 
//Se for abertura de caixa executa o ponto de entrada aqui, senão for executa na função STWSupplyBleeding (Controle feito pela variavel lOpenPDV e função STWGetOpen() )
If ExistBlock("STIMotSa")
	AADD(aStation,cUserName)
	lRet := ExecBlock("STIMotSa",.F.,.F.,{lRet, aValues,lAbreCx,aStation})
EndIf

If lRet 
	lRet := STWPOSOpenCash()
	If lRet .AND. nVlrTroco > 0 
		lRet := STWSupplyBleeding( 2 , aValues , STBGetCurrency() )
	EndIf
EndIf

lOpenPDV := .F.

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STWOpenSupply
Função retorna se é abertura de caixa usada na função STWSupplyBleeding
@author  Lucas Novais
@version P12.1.17
@since   03/11/2017
@return  lOpenPDV 	Retorna se é abertura de caixa
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STWGetOpen()
Return lOpenPDV
