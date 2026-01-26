#INCLUDE "BADefinition.CH"

NEW ENTITY FuncProcessos

//-------------------------------------------------------------------
/*/{Protheus.doc} BAFunProcessos
Visualiza as informacoes de Processos.

@author  raquel.andrade
@since   24/05/2019
/*/
//-------------------------------------------------------------------
Class BAFunProcessos from BAEntity
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
Method Setup( ) Class BAFunProcessos
	_Super:Setup("FuncProcessos", DIMENSION, "RCJ")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constr?i a query da entidade.
@return cQuery, string, query a ser processada.

@author  raquel.andrade
@since   24/05/2019
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAFunProcessos
	Local cQuery := ""

    cQuery += " SELECT"
    cQuery += "         <<KEY_RCJ_RCJ_FILIAL+RCJ_CODIGO>> AS BK_FUNCPROC,"
    cQuery += "         RCJ.RCJ_CODIGO AS PROC_CODIGO,"
    cQuery += "         RCJ.RCJ_DESCRI AS PROC_DESCRICAO,"
	cQuery += "         <<CODE_INSTANCE>> AS INSTANCIA"
    cQuery += "     FROM <<RCJ_COMPANY>> RCJ"
    cQuery += "     WHERE "
    cQuery += "     RCJ.D_E_L_E_T_ = ' ' <<AND_XFILIAL_RCJ_FILIAL>>"

Return cQuery
