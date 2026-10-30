#INCLUDE "BADefinition.CH"

NEW ENTITY PERIODOS

//-------------------------------------------------------------------
/*/{Protheus.doc} BAPeriodos
Visualiza as informa??es de Periodos.

@author  raquel.andrade
@since   24/05/2019
/*/
//-------------------------------------------------------------------
Class BAPeriodos from BAEntity
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
Method Setup( ) Class BAPeriodos
	_Super:Setup("Periodos", DIMENSION, "RCH")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constr?i a query da entidade.
@return cQuery, string, query a ser processada.

@author  raquel.andrade
@since   24/05/2019
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAPeriodos
	Local cQuery := ""

    cQuery += " SELECT"
    cQuery += "         <<KEY_RCH_RCH_FILIAL+RCH_PROCES+RCH_PER+RCH_NUMPAG+RCH_ROTEIR>> AS BK_PERIODO,"
    cQuery += "         RCH.RCH_PER AS PER_CODIGO,"
    cQuery += "         RCH.RCH_NUMPAG AS PER_NUMPAG,"
    cQuery += "         RCH.RCH_PROCES AS PER_PROCES,"
    cQuery += "         RCH.RCH_ROTEIR AS PER_ROTEIR,"
    cQuery += "         RCH.RCH_DTINI AS PER_DTINICIAL,"
    cQuery += "         RCH.RCH_DTFIM AS PER_DTFINAL,"
    cQuery += "         RCH.RCH_DTPAGO AS PER_DTPAGAMENTO,"
    cQuery += "         RCH.RCH_DTFECH AS PER_DTFECH,"
    cQuery += "         RCH.RCH_DTINTE AS PER_INTEGRA,"
	cQuery += "         <<CODE_INSTANCE>> AS INSTANCIA"
    cQuery += "     FROM <<RCH_COMPANY>> RCH"
    cQuery += "     WHERE "
    cQuery += "     RCH.D_E_L_E_T_ = ' ' <<AND_XFILIAL_RCH_FILIAL>>"

Return cQuery
