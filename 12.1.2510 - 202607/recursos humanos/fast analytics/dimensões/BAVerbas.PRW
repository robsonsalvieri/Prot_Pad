#INCLUDE "BADefinition.CH"

NEW ENTITY VERBAS

//-------------------------------------------------------------------
/*/{Protheus.doc} BAVerbas
Visualiza as informa??es de Verbas.

@author  raquel.andrade
@since   24/05/2019
/*/
//-------------------------------------------------------------------
Class BAVerbas from BAEntity
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
Method Setup( ) Class BAVerbas
	_Super:Setup("Verbas", DIMENSION, "SRV")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constr?i a query da entidade.
@return cQuery, string, query a ser processada.

@author  raquel.andrade
@since   24/05/2019
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAVerbas
	Local cQuery := ""

    cQuery += " SELECT"
    cQuery += "         <<KEY_SRV_RV_FILIAL+RV_COD>> AS BK_VERBA,"
    cQuery += "         SRV.RV_COD AS PD_CODIGO,"
    cQuery += "         SRV.RV_DESC AS PD_DESCRICAO,"
    cQuery += "         SRV.RV_TIPOCOD AS PD_TIPOCOD,"
    cQuery += "         SRV.RV_TIPO AS PD_TIPO,"
    cQuery += "         SRV.RV_CODFOL AS PD_CODFOL,"
    cQuery += "         SRV.RV_INSS AS PD_INSS,"
    cQuery += "         SRV.RV_DEDINSS AS PD_DEDINSS,"
    cQuery += "         SRV.RV_IR AS PD_IR,"
    cQuery += "         SRV.RV_FGTS AS PD_FGTS,"
    cQuery += "         SRV.RV_NATUREZ AS PD_NATUREZ,"
	cQuery += "         <<CODE_INSTANCE>> AS INSTANCIA"
    cQuery += "     FROM <<SRV_COMPANY>> SRV"
    cQuery += "     WHERE "
    cQuery += "     SRV.D_E_L_E_T_ = ' ' <<AND_XFILIAL_RV_FILIAL>>"

Return cQuery
