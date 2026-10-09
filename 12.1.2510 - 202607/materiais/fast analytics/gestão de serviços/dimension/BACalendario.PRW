#INCLUDE "BADEFINITION.CH"

NEW ENTITY CALENDARIO

//-------------------------------------------------------------------
/*/{Protheus.doc} BACalendario
Visualiza as informa��es de Calendario.

@author  Helio Leal
@since   21/03/2018
/*/
//-------------------------------------------------------------------
Class BACalendario from BAEntity
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
Method Setup( ) Class BACalendario
	_Super:Setup("Calendario", DIMENSION, "AC0")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Helio Leal
@since   21/03/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BACalendario
	Local cQuery := ""

	cQuery += " SELECT "
    cQuery +=   "<<KEY_AC0_AC0_FILIAL+AC0_CODIGO>> AS BK_CALENDARIO, "
    cQuery +=   "AC0_CODIGO AS COD_CADASTRO_FERIADO, "
    cQuery +=   "AC0_DESC AS DESC_CADASTRO_FERIADO, "
    cQuery +=   "<<CODE_INSTANCE>> AS INSTANCIA "
    cQuery += "FROM <<AC0_COMPANY>> AC0 "
    cQuery += "WHERE "
    cQuery +=   "AC0.D_E_L_E_T_ = ' ' "
	cQuery +=   "<<AND_XFILIAL_AC0_FILIAL>> "

Return cQuery
