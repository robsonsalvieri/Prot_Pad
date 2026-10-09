#INCLUDE "BADefinition.CH"

NEW ENTITY DEPARTAMENTOS

//-------------------------------------------------------------------
/*/{Protheus.doc} BADepartamentos
Visualiza as informa??es de Departamentos.

@author  raquel.andrade
@since   24/05/2019
/*/
//-------------------------------------------------------------------
Class BADepartamentos from BAEntity
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
Method Setup( ) Class BADepartamentos
	_Super:Setup("Departamentos", DIMENSION, "SQB")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constr?i a query da entidade.
@return cQuery, string, query a ser processada.

@author  raquel.andrade
@since   24/05/2019
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BADepartamentos
	Local cQuery := ""

    cQuery += " SELECT"
    cQuery += "         <<KEY_SQB_QB_FILIAL+QB_DEPTO>> AS BK_DEPARTAMENTO,"
    cQuery += "         SQB.QB_DEPTO AS DEPTO_CODIGO,"
    cQuery += "         SQB.QB_DESCRIC AS DEPTO_DESCRICAO,"
	cQuery += "         <<CODE_INSTANCE>> AS INSTANCIA"
    cQuery += "     FROM <<SQB_COMPANY>> SQB"
    cQuery += "     WHERE "
    cQuery += "     SQB.D_E_L_E_T_ = ' ' <<AND_XFILIAL_QB_FILIAL>>"

Return cQuery
