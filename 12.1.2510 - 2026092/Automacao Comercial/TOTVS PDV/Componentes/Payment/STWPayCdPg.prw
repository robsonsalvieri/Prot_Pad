#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//--------------------------------------------------------------------
/*/{Protheus.doc} STWPayCdPg
Pagamento condicao de pagamento
@param   	oMdlGrd - Grid do Model 
@author  	Varejo
@version 	P11.8
@since   	26/03/2013
@return  	Se executou corretamente
@obs     
@sample
/*/
//--------------------------------------------------------------------
Function STWPayCdPg(oMdlGrd)
Local cTypePay	:= "" //Tipo da forma de pagamento
Local lContinua	:= IIf(ExistFunc("STIVerCTef"),STIVerCTef(.F.),.T.)

Default oMdlGrd := Nil


If lContinua .And. ValType(oMdlGrd) == 'O' .AND. STBChkIsVp(oMdlGrd) .AND. STBChkTpCP(oMdlGrd)
	
	STIZeraPay()			//Zera os pagamentos antes de lancar a condicao de pagamento
	STBApliDes(oMdlGrd) 	//Aplica desconto da condicao de pagamento
	STBApliAcr(oMdlGrd) 	//Aplica acrescimo da condicao de pagamento
	STBParcCp() 			//Gera as parcelas da condicao de pagamento
	STBTratPar()			//Tratamento das parcelas geradas

	STBCDPGAtuBasket()		//Atualizo a condição de pagamento 

	cTypePay := STBGetTpPay()
	
	Do Case
		Case cTypePay $ 'CC|CD'
			STBTrnsCard(cTypePay)			
		Case cTypePay == 'CH'
			STBTrnsCheck(oMdlGrd:aDatAModel)
		Case !Empty(cTypePay)
			STBTrnsCp()
		Case Empty(cTypePay) // Mv_CondPad = ""
			STBTrnsCp()
			STIZeraPay(.T.)  // sem essa alteracao, trava a tela de pagamentos	
	EndCase
EndIf

Return .T.

