#INCLUDE "BADEFINITION.CH"

NEW ENTITY TURNO

//-------------------------------------------------------------------
/*/{Protheus.doc} BATurno
Visualiza as informacoes de Turno.

@author  Helio Leal
@since   21/03/2018
/*/
//-------------------------------------------------------------------
Class BATurno from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padrao.

@author  Helio Leal
@since   21/03/2018
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BATurno
	_Super:Setup("Turno", DIMENSION, "SR6")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Helio Leal
@since   21/03/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BATurno
	Local cQuery := ""

	cQuery += " SELECT "
    cQuery +=   "<<KEY_SR6_R6_FILIAL+R6_TURNO>> AS BK_TURNO, "
    cQuery +=   "R6_TURNO AS COD_TURNO, "
    cQuery +=   "R6_DESC AS DESC_TURNO, "
    cQuery +=   "<<CODE_INSTANCE>> AS INSTANCIA "
    cQuery += "FROM <<SR6_COMPANY>> SR6 "
    cQuery += "WHERE "
    cQuery +=   "SR6.D_E_L_E_T_ = ' ' "
	cQuery +=   "<<AND_XFILIAL_R6_FILIAL>> "

Return cQuery
