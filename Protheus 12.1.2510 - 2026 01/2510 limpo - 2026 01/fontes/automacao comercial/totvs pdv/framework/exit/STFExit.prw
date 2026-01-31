#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"  
#INCLUDE "STFEXIT.CH" 

Static lPerExit	:= .F.		// Permite sair do sistema. Usado para conferencia de caixa

//-------------------------------------------------------------------
/*/{Protheus.doc} STFExit
Finalização do Sistema
@param   	
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet Retorna se pode sair do sistema
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFExit()

Local lRet 			:= .T.  							// Retorna se pode sair do sistema
Local nTotSale		:= 0								// Valor total da venda 
Local oTotal 		:= STFGetTot()						// Recebe o Objeto totalizador
Local lSTExitPOS    := ExistBlock("STEXITPOS")			// VerIfica se existe o PE FTVD7019        
Local lCloseCxAut 	:= SuperGetMv("MV_LJFECCX",,.T.)	// Indica se usa Fechamento automatico de caixa
Local lLjConff		:= SuperGetMV("MV_LJCONFF",.T.,.F.) // Fechamento de caixa
Local lObgFecha		:= SuperGetMv("MV_LJOBGCF",,.T.)	// Obrigatorio o fechamento de caixa.
Local lMobile		:= STFGetCfg( "lMobile" , .F. )  	// Valida se é versao mobile
Local cCesta		:= STDGPBasket("SL2", "L2_SITUA")	// Recebe a situação do item da venda
Local lOpenCash 	:= STBOpenCash() 					// Verifico se o caixa esta aberto

If ValType(oTotal) == "O"
	nTotSale := oTotal:GetValue( "L1_VLRTOT" )

	If nTotSale > 0 .OR. cCesta == "05"
		STFMessage("STFExit","STOP", STR0001 ) //"Nao e possivel sair, venda ja iniciada. Fechar ou cancelar a venda."
		lRet := .F.
	EndIf	
EndIf

If lRet
	If lOpenCash .AND. lLjConff
		If lObgFecha .AND. !STFGetPerExit()
			STFMessage("STFExit", "STOP", STR0003) //"Conf. de Caixa Ativa. É obrigatório confirmar o Encerramento de Caixa - Menu(F2)."
			STFShowMessage("STFExit")
			lRet = .F.
		ElseIf !STFGetPerExit()
		    STFMessage("STFExit", "YESNO", STR0004 ) //"Deseja abandonar a conferência de caixa e sair do sistema?"
			lRet := STFShowMessage("STFExit")
			STFSetPerExit(lRet)
		EndIf

	ElseIf !STFGetPerExit() .AND. STBOpenCash()
		STFMessage("STFExit", "YESNO", STR0002 ) //"Deseja realmente sair do sistema?"
		lRet := STFShowMessage("STFExit")
		STFSetPerExit(lRet)
	EndIf

EndIf

If lSTExitPOS 
	lRet :=  ExecBlock( "STEXITPOS",.F.,.F.,{} )
EndIf  

// Se puder sair do POS faz validacoes necessarias antes
If lRet

	//Fecha comunicacao com perifericos
	STWCloseDevice() 
	
	//Ao Sair Fecha o Caixa Automaticamente se o Parametro estiver configurado
	If lCloseCxAut
		lRet := STWPOSCloseCash()
	EndIf
	
	//Libera o objeto de totais da venda
	If ExistFunc("STFTotRelease")
		STFTotRelease()
	EndIf
	//Versao Mobile sai do sistema direto 
	//sem voltar para o menu do Protheus
	If ValType(lMobile) == "L" .AND. lMobile
		MS_QUIT()
	EndIf

	If lRet 
		FreeUsedCode()
	Endif 	
	
EndIf

If lRet 
	PutGlbVars("lPosOpen",.F.) // -- Indica que o PDV esta fechado
EndIf 

STI7InfCPF(.F.)

STFShowMessage("STFExit")

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STFSetPerExit
Seta variavel statica que controla a saida do sistema. Usado para conferencia de caixa
@param   lExit   Valida se pode sair do sistema	
@author  Varejo
@version P11.8
@since   29/03/2012
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFSetPerExit(lExit)

Default lExit := .F.

lPerExit := lExit	// Permite sair do sistema. Usado para conferencia de caixa

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STFGetPerExit
Retorna a variavel estatica que controla a saida do sistema. Usado para conferencia de caixa
@author  Varejo
@version P12.1.14
@since   02/01/2017
@return  lPerExit
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFGetPerExit()
Return lPerExit