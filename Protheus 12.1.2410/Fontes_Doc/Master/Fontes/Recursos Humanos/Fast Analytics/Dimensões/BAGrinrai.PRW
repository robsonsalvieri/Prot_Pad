#INCLUDE "BADefinition.CH"

NEW ENTITY GRINRAI

//-------------------------------------------------------------------
/*/{Protheus.doc} BACatFunc
Visualiza as informa??es de Grau de Instrucao RAIS.

@author  raquel.andrade
@since   16/09/2019
/*/
//-------------------------------------------------------------------
Class BAGrinrai from BAEntity
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
Method Setup( ) Class BAGrinrai
	_Super:Setup("Grinrai", DIMENSION, "SX5")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constr?i a query da entidade.
@return cQuery, string, query a ser processada.

@author  raquel.andrade
@since   16/09/2019
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAGrinrai
	Local cQuery := ""

    cQuery += " SELECT"
    cQuery += "         <<KEY_SX5_X5_FILIAL+X5_CHAVE>> AS BK_GRINRAI,"    
    cQuery += "         	X5_CHAVE AS COD_GRINRAI,"
    cQuery += "         	X5_DESCRI AS DESC_GRINRAI,"
	cQuery += "             <<CODE_INSTANCE>> AS INSTANCIA"
    cQuery += "     FROM <<SX5_COMPANY>> SX5"
    cQuery += "     WHERE SX5.X5_TABELA = '26' "
    cQuery += "     AND SX5.D_E_L_E_T_ = ' ' <<AND_XFILIAL_X5_FILIAL>>"

Return cQuery
