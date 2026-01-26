#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STPOS.CH"   
#INCLUDE "STWSUPPLYBLEEDNG.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} STWSupplyBleeding
Realiza suprimento e sangria de caixa
@param nTypeOpe			Tipo da rotina: (1) Sangria / Entrada de troco (2)
@param lShowScreen		Exibe tela
@param   aValues
					01 - TYPEOPERATION      // 01 - Tipo da rotina: (1) Sangria / Entrada de troco (2) 
					02 - CASHIER_ORIGIN     // 02 - Codigo do caixa de origem
					03 - CASHIER_DESTINY	// 03 - Codigo do caixa de destino
					04 - VALUE_MONEY		// 04 - Valor em dinheiro
					05 - VALUE_CHECK       	// 05 - Valor em cheque
					06 - VALUE_CREDITCARD	// 06 - Valor em cartao de credito
					07 - VALUE_DEBITCARD	// 07 - Valor em cartao de debito
					08 - VALUE_FINANCED    	// 08 - Valor em financiado
					09 - VALUE_COVENANT     // 09 - Valor em convenio
					10 - VALUE_COUPONS		// 10 - Valor em vales
					11 - VALUE_OTHERS       // 11 - Valor em outros
					16 - VALUE_PD 			// 16 - Valor em pagamentos digitais
					17 - VALUE_PIX 			// 17 - Valor em PIX
@param cCoin 			Moeda 
					  
@author  Varejo
@version P11.8
@since   23/07/2012
@return  lRet 	Retorna se realizou o suplimento de caixa ou troco
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STWSupplyBleeding( nTypeOpe , aValues , nCoin , lOnlyBleeding )
Local lRet			:= .T.									// Retorno
Local cRotCompr		:= SuperGetMV("MV_LJIMPCO",,"LOJR950")	// Nome da rotina para impressao do comprovante Nao Fiscal
Local cSupervisor	:= Space(15)							// Supervisor que autorizou a transacao
Local lPermission	:= .F.									// Permissao de usuario
Local aRet			:= {}									// Array para retornos em geral
Local cSimb    		:= ""                              		// Array de simbolos das moedas 

Default nTypeOpe 		:= 2								// Tipo de operacao 1=Sangria | 2= Suprimento/Troco
Default aValues			:= Array(17)						// Array Valores
Default nCoin			:= STBGetCurrency()					// Moeda corrente
Default lOnlyBleeding	:= .F.								// Realiza apenas a sangria na impressora

//Faz configuracao Inicial do array de valores
STBSuppIni( nTypeOpe , aValues)

// Verifica permissao para Suprimento/Troco/Sangria
aRet := STFProfile(5)
lPermission := aRet[1]	
cSupervisor := aRet[2]	

// Verifica permissao para Suprimento/Troco/Sangria
If lPermission
  
	//Criar evento para gaveta de dinheiro   
	STFFireEvent(ProcName(0), "STDrawerAci",	{ nHdlGaveta, STFGetStation("PORTGAV") } 	)
	STFFireEvent(ProcName(0), "STDrawer",	{ nHdlECF } )

	lRet := ExistFunc("STWActivePrinter") .And. STWActivePrinter(/*lMensagem*/)
	//Motivo de Sangria
	If ExistBlock("STIMotSa") .AND. !STWGetOpen() //Se for abertura de caixa o STIMotSa já foi executado pelo STWOpencash.PRW
		lRet := ExecBlock("STIMotSa",.F.,.F.,{lRet, aValues})
	EndIf
	
	//Gera e grava o SE5 Conforme os campos passados
	If lRet                                 
		lRet := STBCrSupMov( aValues , nCoin , lOnlyBleeding)	
	EndIf	

	// PAF-ECF: Insere na tabela de apoio informacoes ref. ao suprimento/sangria
	If lRet .AND. STFGetCfg("lPafEcf")
	
		If aValues[TYPEOPERATION] == 1 //Sangria
			STFFireEvent(ProcName(0), "STGrvMdz",	{"CN",aValues[VALUE_MONEY],Upper(STR0001), NIL, NIL}) //"Sangria"
		ElseIf aValues[TYPEOPERATION] == 2 //Suprimento	
			STFFireEvent(ProcName(0), "STGrvMdz",	{"CN",aValues[VALUE_MONEY],Upper(STR0002), NIL, NIL}) //"Suprimento"
		EndIf
		
		//Registra o primeiro movimento, caso exista não grava duas vezes
		STFFireEvent(ProcName(0), "STGrvMdz",	{"PV", 0, "REGPAF", "", ""}) 
	EndIf
EndIf

Return lRet
