#INCLUDE "BADefinition.CH"

NEW ENTITY ROTEIROSCALCULO

//-------------------------------------------------------------------
/*/{Protheus.doc} BARoteirosCalculo
Visualiza as informa??es de Roteiros de Calculo.

@author  raquel.andrade
@since   24/05/2019
/*/
//-------------------------------------------------------------------
Class BARoteirosCalculo from BAEntity
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
Method Setup( ) Class BARoteirosCalculo
	_Super:Setup("RoteirosCalculo", DIMENSION, "SRY")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constr?i a query da entidade.
@return cQuery, string, query a ser processada.

@author  raquel.andrade
@since   24/05/2019
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BARoteirosCalculo
	Local cQuery := ""

    cQuery += " SELECT"
    cQuery += "         <<KEY_SRY_RY_FILIAL+RY_CALCULO>> AS BK_ROTEIRO,"
    cQuery += "         SRY.RY_CALCULO AS ROT_CODIGO,"
    cQuery += "         SRY.RY_DESC AS ROT_DESCRICAO,"
    cQuery += "         SRY.RY_ORDINAR AS ROT_ORDINAR,"
    cQuery += "         SRY.RY_TIPO AS ROT_TIPO,"
	cQuery += "         <<CODE_INSTANCE>> AS INSTANCIA"
    cQuery += "     FROM <<SRY_COMPANY>> SRY"
    cQuery += "     WHERE "
    cQuery += "     SRY.D_E_L_E_T_ = ' ' <<AND_XFILIAL_RY_FILIAL>>"

Return cQuery
