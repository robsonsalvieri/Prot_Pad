#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

Static lLjcFid		:= SuperGetMv("MV_LJCFID",,.F.) .AND. CrdxInt()//Indica se a recarga de cartao fidelidade esta ativa
Static lRecharge		:= .F.												 // Controle de Atualiza do shopcard				


//-------------------------------------------------------------------
/*{Protheus.doc} STWShopCardRecharge
Efetua os processamentos para produtos agrupados. Chamado durante o processamento do STWItemReg.
@param   cItemCode		Codigo do item
@author  Varejo
@version P11.8
@since   23/05/2012
@return  lRet 	- Caso o produto seja do tipo Recarga Shop Card, retorna .T.
@obs     
@sample
*/
//-------------------------------------------------------------------
Function STWShopCardRecharge(cItemCode)

Local lRet				:= .F.								// Indica se o cartao eh valido para recarga
Local cProdFid				:= SuperGetMv("MV_LJPFID")		// Parametro com o codigo do produto tipo recarga de cartao fidelidade	
Local oModelShopCard		:= Nil								// Model

Default cItemCode := ""

ParamType 0 Var 	cItemCode 	As Character	Default 	""

/*  
Caso o parametro MV_LJCFID esteja setado como True e o produto esteja preenchido, continua o processamento.. 
*/

If !Empty(cItemCode) .AND. lLjcFid

	lRet := STBAvalShopCard(cItemCode) // Funcao que avalia se a regra de recarga do ShopCard se aplica ao produto informado.
	
	If lRet
		If Empty(STDGPBasket("SL2","L2_ITEM",1))	
			STIRecShopCard(cItemCode) //Exibe Interface.	
		Else
			STFMessage(ProcName(),"STOP","Para efetuar a recarga, nenhum outro item pode estar registrado.")
			STFShowMessage(ProcName())	
			STFCleanMessage(ProcName())
		EndIf		
	EndIf
	
EndIf

Return lRet


//-------------------------------------------------------------------
/*/ {Protheus.doc} STWUpdShopCardFunds
Workflow responsavel por atualizar o saldo do ShopCard no momento da recarga.
@author  Varejo
@version P11.8
@since   23/05/2012
@return  lRet - atualizar o saldo do ShopCard no momento da recarga
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STWUpdShopCardFunds(cNumCartao,nValor,dDtValid)
Local lRet 			:= .T.  											// Retorno		
Local cDoc			:= STDGPBasket("SL1","L1_DOC")					// Documento
Local cSerie		:= STDGPBasket("SL1","L1_SERIE")				// Serie
Local cLoja			:= STDGPBasket("SL1","L1_LOJA")					// Loja

DEFAULT cNumCartao 	:= ""
DEFAULT nValor		:= 0
DEFAULT	dDtValid	:= Ctod("")

If lRet
	lRet := STBVldShopCard(cNumCartao,dDtValid,nValor)
	If lRet
		STDSShopCardValues(cNumCartao,dDtValid,nValor,cLoja)	
	EndIf
EndIf

lRecharge := lRet

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STDGUpdShopCardFundsResult
Funcao que retorna se o cartao foi recarregado ou nao
@author  Varejo
@version P11.8
@since   19/02/2013
@return  lRecharge - retorna se o cartao foi recarregado ou nao
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDGUpdShopCardFundsResult()
Return lRecharge


//-------------------------------------------------------------------
/*/{Protheus.doc} STDRUpdShopCardFundsResult
Reinicializa a variavel de controle lRecharge.
@author  Varejo
@version P11.8
@since   19/02/2013
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDRUpdShopCardFundsResult()

lRecharge := .F.

Return Nil


//-------------------------------------------------------------------
/*/ {Protheus.doc} STWPayShopCard
Workflow responsavel por atualizar o saldo do ShopCard no momento da recarga.
@author  Varejo
@version P11.8
@since   23/05/2012
@return  lRet - Atualizou saldo
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STWPayShopCard()

Local lRet := .F.				 // Retorno
Local cFormaPagamento := "FID" // TO DO: Pegar forma de pagamento da cesta

If AllTrim(cFormaPagamento) == "FID"
	//TO DO: ???
EndIf

Return lRet



