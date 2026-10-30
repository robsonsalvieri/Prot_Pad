#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"


//--------------------------------------------------------------------
// Funcao dumb
//--------------------------------------------------------------------
Function STBWCPayment() ; Return

//--------------------------------------------------------------------
/*/{Protheus.doc} STBWCPayment
Classe responsavel por fazer todos WorkFlow e chamar outros Workflow de 
pagamento
@param   
@return  Self
@author  Varejo
@since   24/04/2012
@version P11.8
@see	
@obs   
/*/
//--------------------------------------------------------------------
Class STBWCPayment

Data oCache		// Objeto cache
Data oPayX5		// Objeto Pagamento SX5 
Data oAdmin		// Objeto Adminstrador
Data oConPay		// Objeto Condicao pagamento
Data oOptPay		// Objeto opcao de pagamento
Data oSelPay		// Objeto selecao de pagamento

Method STBWCPayment() 
Method STBWCStartPayment()
Method STBCPaymentOptionsCreator() 
Method Show()

EndClass


//--------------------------------------------------------------------
/*/{Protheus.doc} STBWCPayment
MEtodo construtor
pagamento
@param   
@return  Nil
@author  Varejo
@since   24/04/2012
@version P11.8
@see	
@obs   
/*/
//--------------------------------------------------------------------
Method STBWCPayment() Class STBWCPayment

Self:oCache	:=  STFWCMemCache():STFWCMemCache()

Self:oPayX5 := STDTTypePayX5():STDTTypePayX5(Self:oCache)
Self:oPayX5:GetAllData() 

Self:oAdmin := STDAAdministratorFinancial():STDAAdministratorFinancial(Self:oCache)
Self:oAdmin:GetAllData() 

//TODO:
//Self:oConPay := STDAPayConditionPayment():STDAPayConditionPayment(Self:oCache)
//Self:oConPay:GetAllData()

// Retorno já com os dados, u seja não é necessario usar o GetAll, apesar de existir,
// esse Metodo Privado
Self:oOptPay := Self:STBCPaymentOptionsCreator(Self:oCache) 

Return Nil


//--------------------------------------------------------------------
/*/{Protheus.doc} STBWCStartPayment
Classe responsavel iniciar Workflow de Pagamento
pagamento
@param   
@return  Self
@author  Varejo
@since   24/04/2012
@version P11.8
@see	
@obs   
/*/
//-------------------------------------------------------------------- 
Method STBWCStartPayment() Class  STBWCPayment

Self:Show()

//TODO: imprementar???

If oOptPay:cRet := "CC"

ElseIf oOptPay:cRet := "CD"

ElseIf oOptPay:cRet := "FI"

ElseIf oOptPay:cRet := "CP"

ElseIf oOptPay:cRet := "CN"

ElseIf oOptPay:cRet := "MN"

EndIf

Return Nil


//--------------------------------------------------------------------
/*/{Protheus.doc} STBCPaymentOptionsCreator
Classe responsavel Chamar classe para criar opcoes de pagamento
pagamento
@param   
@return  Nil
@author  Varejo
@since   24/04/2012
@version P11.8
@see	
@obs   
/*/
//-------------------------------------------------------------------- 
Method STBCPaymentOptionsCreator() Class  STBWCPayment

Self:oSelPay := STBCPaymentOptionsCreator():STBCPaymentOptionsCreator(Self:oPayX5, Self:oAdmin, Self:oConPay) // ajustar

Return Nil


//--------------------------------------------------------------------
/*/{Protheus.doc} Show
Metodos responsavel Chamar classe de VIew
pagamento
@param   
@return  Nil
@author  Varejo
@since   24/04/2012
@version P11.8
@see	
@obs   
/*/
//-------------------------------------------------------------------- 
Method Show() Class STBWCPayment

Local nX // Contador

For nX := 1 to Len(oSelPay)

	CoNout("R$")
	CoNout("CC")
	CoNout("CD")

Next nX

Return Nil



