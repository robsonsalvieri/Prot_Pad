#INCLUDE "BADEFINITION.CH"

NEW ENTITY ITEM

//-------------------------------------------------------------------
/*/{Protheus.doc} BAItem
Visualiza as informacoes de Item.

@author  Helio Leal
@since   06/11/2017
/*/
//-------------------------------------------------------------------
Class BAItem from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padrao.

@author  Helio Leal
@since   06/11/2017
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BAItem
	_Super:Setup("Item", DIMENSION, "SB1")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Helio Leal
@since   06/11/2017
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAItem
	Local cQuery := ""

	cQuery += " SELECT"
	cQuery += " 		<<KEY_SB1_B1_FILIAL+B1_COD>> as BK_ITEM,"
	cQuery += " 		SB1.B1_COD AS COD_ITEM,"
	cQuery += " 		SB1.B1_DESC AS DESC_ITEM,"
	cQuery += " 		SB1.B1_POSIPI AS CLASSIFICACAO_FISCAL,"
	cQuery += "         <<CODE_INSTANCE>> AS INSTANCIA"
	cQuery += " 	FROM <<SB1_COMPANY>> SB1" 
	cQuery += " 	WHERE "
	cQuery += "	   	SB1.D_E_L_E_T_ = ' '"
	cQuery += "     <<AND_XFILIAL_B1_FILIAL>>"
Return cQuery 