#INCLUDE "BADefinition.CH"

NEW ENTITY CATFUNC

//-------------------------------------------------------------------
/*/{Protheus.doc} BACatFunc
Visualiza as informa??es de Categoria Funcional.

@author  raquel.andrade
@since   24/05/2019
/*/
//-------------------------------------------------------------------
Class BACatFunc from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padr?o.

@author  raquel.andrade
@since   24/05/2019
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BACatFunc
	_Super:Setup("CatFunc", DIMENSION, "SX5")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constr?i a query da entidade.
@return cQuery, string, query a ser processada.

@author  raquel.andrade
@since   24/05/2019
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BACatFunc
	Local cQuery := ""

    cQuery += " SELECT"
    cQuery += "         <<KEY_SX5_X5_FILIAL+X5_CHAVE>> AS BK_CAT,"    
    cQuery += "         	X5_CHAVE AS COD_CATFUNC,"
    cQuery += "         	X5_DESCRI AS DESC_CATFUNC,"
	cQuery += "             <<CODE_INSTANCE>> AS INSTANCIA"
    cQuery += "     FROM <<SX5_COMPANY>> SX5"
    cQuery += "     WHERE SX5.X5_TABELA = '28' "
    cQuery += "     AND SX5.D_E_L_E_T_ = ' ' <<AND_XFILIAL_X5_FILIAL>>"
    

Return cQuery
