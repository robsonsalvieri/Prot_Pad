#INCLUDE "BADefinition.CH"

NEW ENTITY EVENTOS

//-------------------------------------------------------------------
/*/{Protheus.doc} BAEventos
Visualiza as informa??es de Eventos.

@author  raquel.andrade
@since   24/05/2019
/*/
//-------------------------------------------------------------------
Class BAEventos from BAEntity
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
Method Setup( ) Class BAEventos
	_Super:Setup("Eventos", DIMENSION, "SP9")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constr?i a query da entidade.
@return cQuery, string, query a ser processada.

@author  raquel.andrade
@since   24/05/2019
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAEventos
	Local cQuery := ""

    cQuery += " SELECT"
    cQuery += "         <<KEY_SP9_P9_FILIAL+P9_CODIGO>> AS BK_EVENTO,"
    cQuery += "         SP9.P9_CODIGO AS EVE_CODIGO,"
    cQuery += "         SP9.P9_DESC AS EVE_DESCRICAO,"
    cQuery += "         SP9.P9_IDPON AS EVE_IDPON,"
    cQuery += "         SP9.P9_BHORAS AS EVE_BHORAS,"
    cQuery += "         SP9.P9_BHVAL AS EVE_BHVAL,"
    cQuery += "         SP9.P9_TIPOCOD AS EVE_TIPOCOD,"
    cQuery += "         SP9.P9_CLASEV AS EVE_CLASEV,"
	cQuery += "         <<CODE_INSTANCE>> AS INSTANCIA"
    cQuery += "     FROM <<SP9_COMPANY>> SP9"
    cQuery += "     WHERE "
    cQuery += "     SP9.D_E_L_E_T_ = ' ' <<AND_XFILIAL_P9_FILIAL>>"

Return cQuery
