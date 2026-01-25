#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"    
#INCLUDE "STWCLOSECASH.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} STWPOSCloseCash
Realiza Fechamento do Caixa 

@param   
@author  Varejo
@version P11.8
@since   04/07/2012
@return  lRet 	Retorna se fechou o caixa
@obs     
@sample
/*/
//------------------------------------------------------------------- 
Function STWPOSCloseCash()

Local lUsaDisplay 	:= !Empty(STFGetStation("DISPLAY")) // Verifica se a estacao possui Display
Local cSupervisor	:=	Space(15)						// Supervisor que autorizou a transacao
Local lRet			:= .T.								// Retorno
Local cStation 		:= STFGetStation("CODIGO")			// Estacao atual
Local lLjConff		:= SuperGetMV("MV_LJCONFF",.T.,.F.) // Fechamento de caixa
Local lObgFecha		:= SuperGetMv("MV_LJOBGCF",,.T.)	// Obrigatorio o fechamento de caixa.
Local lMobile 		:= STFGetCfg("lMobile", .F.)		// Smart Client Mobile

lMobile := ValType(lMobile) == "L" .AND. lMobile

// Se o caixa estiver aberto, sem vendas pendentes e nao estiver realizando recebimentos
If lRet .And. STBOpenCash()

	If lUsaDisplay
		STFFireEvent(ProcName(0), "STDisplay", { StatDisplay(), "1C"+ STR0001 } ) // "FECHAMENTO DO CAIXA"
	EndIf          
	
	// Fechamento do caixa
	lObgFecha := lObgFecha .Or. !IsInCallStack("STFExit") //tratamento para fechamento de caixa nao ser obrigatorio
	If (!lLjConff .Or. lObgFecha) .And. STWCloseCash( @cSupervisor )
	
			// Grava que foi realizado fechamento na tabela de Monitoramento das Estacoes(SLI)
			STFSLICreate(cStation, "OPE", "", "SOBREPOE")

			//Em versoes Mobile nao faz controle por arquivo 
			//fisico apenas por registros em Base de dados
			If lMobile
				//Desabilita os botoes do PDV 
				STIBtnDeActivate()
			Else
			// Fecha o arquivo semaforo que esta aberto
			FClose( STBGetCXHnd() ) 
			EndIf	
			
			//Caixa Fechado
			lRet := .T.  

	ElseIf (!lLjConff .Or. lObgFecha)
		lRet := .F.  // usuario sem acesso a fechar o caixa
	EndIf

EndIf

Return lRet 


//-------------------------------------------------------------------
/*/{Protheus.doc} STWCloseCash
Realiza Fechamento do caixa

@param   cSupervisor por referencia
@author  Varejo
@version P11.8
@since   29/06/2012
@return  lCloseCash 	Retorna se o caixa esta aberto
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STWCloseCash(cSupervisor)

Local lRet				:= .F.							// Retorno
Local aDtHr				:= STBDtCash()				// Array data e hora
Local cCupomFim			:= ""							// Numeracao final da venda
Local cCash 			:= xNumCaixa()				// Caixa atual
Local aPermissao 		:= {}							// Verifica permissao 
Local aRet				:= {}							// Array de retorno
Local aDados			:= {}							// Array de informacoes do evento
Local lEmitNfce			:= Iif(ExistFunc("LjEmitNFCe"), LjEmitNFCe(), .F.) // Sinaliza se utiliza NFC-e

Default cSupervisor 	:= Space(15)					//	Supervisor

ParamType 0 Var 	cSupervisor	As Character	Default Space(15)

// Verifica autorizacao de usuario e caixa para fechar o caixa
aPermissao := STBAutCloseCash()
cSupervisor := aPermissao[2]

If aPermissao[1]
	
	// Fechamento do caixa
	lRet := STDCloseCash( 	cCash		,	aDtHr[1]	, aDtHr[2]	)
	
	If lRet
	
		If STFGetCfg("lMultCoin") // Se usa Multimoeda
			// Fecha caixas associados(tratamento multi-moeda)
			lRet :=	STDCloseMult( cCash	,	aDtHr[1]	, aDtHr[2]	)
		EndIf
		   	 
		If lUsaDisplay				   	
			DisplayEnv(StatDisplay(), "1C"+ STR0002  )  // CAIXA FECHADO    
			DisplayEnv(StatDisplay(), "2C"+ " "  )  
			DisplayEnv(StatDisplay(), '0C'+ STR0002  )  // CAIXA FECHADO 				
		EndIf
		
		If lRet
			// Caixa tem acesso a utilizar Impressora Fiscal 
			If STFProFile(3)[1]
				If !lEmitNfce
					// Pega numero do cupom
					cCupomFim := space(STBLenReceipt())						//Numero do Cupom
							
					aDados := {cCupomFim, Nil}
					aRet 	:= 	STFFireEvent(	ProcName(0)						,;		// Nome do processo
												"STGetReceipt"					,;		// Nome do evento
												aDados )
			
					If Len(aRet) == 0 .OR. aRet[1] <> 0 .OR. Len(aDados) == 0      
					   	STFShowMessage( STR0003, "STGetReceipt" ) //"Falha na obtenção do cupom"
					Else
						cCupomFim 	:= aDados[1]
					EndIf
				Else
					//Captura o último documento a partir das vendas
					cCupomFim := STDCSLastSale("L1_DOC")	
				EndIf
			EndIf
			
			// Grava Movimento Processos de Venda(SLW)
			lRet := STDCSaveMov( aDtHr , cCupomFim) 
			
		EndIf
		
				
	EndIf	

	If !lRet
		STFMessage("STCloseCash","STOP", STR0004)  //"Atencao, Não foi possivel fechar o caixa!"
	Else
		STFMessage("STCloseCash","STOP", STR0002)
	EndIf
Else
	STFMessage("STCloseCash","STOP", STR0008) //"Usuario sem permissão para encerrar o caixa!"
EndIf

STFShowMessage("STCloseCash")	
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STWCash
Realiza Fechamento do Caixa 

@param   
@author  Varejo
@version P11.8
@since   04/07/2012
@return  lRet 	Retorna se fechou o caixa
@obs     
@sample
/*/
//------------------------------------------------------------------- 
Function STWCash()

Local lLjConff := SuperGetMV("MV_LJCONFF",.T.,.F.) //Fechamento de caixa
Local oTotal   := STFGetTot() // Recebe o Objeto totalizador
Local nTotSale := oTotal:GetValue( "L1_VLRTOT" ) //Total da venda que esta em andamento

If nTotSale > 0
	STFMessage("STCloseCash","STOP", STR0005 ) //"Não é possível Fechar o Caixa, venda já iniciada. Fechar ou cancelar a venda."
Else
	If STBOpenCash()
		If lLjConff
			// Se usa conferencia de caixa
			If STWConfCash("2")
				STIConfCash() 
			EndIf
		Else
			If MsgNoYes(STR0006,STR0007) //"Deseja realmente fechar o caixa?" # "Atenção"
				STWPOSCloseCash()
				STIExchangePanel( { || STIPanOpenCash() } )
			EndIf
		EndIf
	EndIf
EndIf

Return .T.
