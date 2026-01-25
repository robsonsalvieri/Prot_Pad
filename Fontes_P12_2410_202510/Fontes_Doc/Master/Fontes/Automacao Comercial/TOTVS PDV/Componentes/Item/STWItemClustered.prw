#Include 'Protheus.ch'
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STPOS.CH"

//-------------------------------------------------------------------
/*/ {Protheus.doc} STWItemClustered
Efetua os processamentos para produtos agrupados. Chamado durante o processamento do STWItemReg.

@param   cItemCode		Quantidade do Item 
@author  Varejo
@version P11.8
@since   23/05/2012
@return  lRet - Executou corretamente
@obs     
@sample
/*/
//-------------------------------------------------------------------

Function STWItemClustered(aInfoItem)

Local cItemCode		:= aInfoItem[ITEM_CODIGO]	// Codigo do produto
Local cTipoProd		:= aInfoItem[ITEM_TIPO] 		// Tipo do produto
Local lRet			:= .T.							// Retorno da Funcao

Default aInfoItem := {}

ParamType 0 Var   	aInfoItem 	As Array	Default 	{}

If cTipoProd == "KT"
	lRet := .F.
	STWKitSales(cItemCode)
EndIf

Return lRet

