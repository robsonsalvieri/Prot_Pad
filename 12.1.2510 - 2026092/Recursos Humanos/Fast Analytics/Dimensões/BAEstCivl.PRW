#INCLUDE "BADefinition.CH"

NEW ENTITY ESTCIVL

//-------------------------------------------------------------------
/*/{Protheus.doc} BACatFunc
Visualiza as informa??es de Estado Civil.

@author  raquel.andrade
@since   16/09/2019
/*/
//-------------------------------------------------------------------
Class BAEstCivl from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padr?o.

@author  raquel.andrade
@since   16/09/2019
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BAEstCivl
	_Super:Setup("EstCivl", DIMENSION, "SX5")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constr?i a query da entidade.
@return cQuery, string, query a ser processada.

@author  raquel.andrade
@since   16/09/2019
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAEstCivl
	Local cQuery := ""

    cQuery += " SELECT"
    cQuery += "         <<KEY_SX5_X5_FILIAL+X5_CHAVE>> AS BK_ESTCIVL,"    
    cQuery += "         	X5_CHAVE AS COD_ESTCIVL,"
    cQuery += "         	X5_DESCRI AS DESC_ESTCIVL,"
	cQuery += "             <<CODE_INSTANCE>> AS INSTANCIA"
    cQuery += "     FROM <<SX5_COMPANY>> SX5"
    cQuery += "     WHERE SX5.X5_TABELA = '33' "
    cQuery += "     AND SX5.D_E_L_E_T_ = ' ' <<AND_XFILIAL_X5_FILIAL>>"

Return cQuery
