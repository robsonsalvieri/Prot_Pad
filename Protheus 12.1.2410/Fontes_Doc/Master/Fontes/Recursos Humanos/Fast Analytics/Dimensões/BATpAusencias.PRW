#INCLUDE "BADefinition.CH"

NEW ENTITY TipoAusencias

//-------------------------------------------------------------------
/*/{Protheus.doc} BATpAusencias
Visualiza as informa??es de Tipo de Ausencias.

@author  raquel.andrade
@since   24/05/2019
/*/
//-------------------------------------------------------------------
Class BATpAusencias from BAEntity
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
Method Setup( ) Class BATpAusencias
	_Super:Setup("TipoAusencias", DIMENSION, "RCM")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constr?i a query da entidade.
@return cQuery, string, query a ser processada.

@author  raquel.andrade
@since   24/05/2019
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BATpAusencias
	Local cQuery := ""

    cQuery += " SELECT"
    cQuery += "         <<KEY_RCM_RCM_FILIAL+RCM_TIPO>> AS BK_TPAUSENCIA,"
    cQuery += "         RCM.RCM_TIPO AS TPAUS_CODIGO,"
    cQuery += "         RCM.RCM_DESCRI AS TPAUS_DESCRICAO,"
    cQuery += "         RCM.RCM_CODSEF AS TPAUS_CODSEFIP,"
	cQuery += "         <<CODE_INSTANCE>> AS INSTANCIA"
    cQuery += "     FROM <<RCM_COMPANY>> RCM"
    cQuery += "     WHERE "
    cQuery += "     RCM.D_E_L_E_T_ = ' ' <<AND_XFILIAL_RCM_FILIAL>>"

Return cQuery
