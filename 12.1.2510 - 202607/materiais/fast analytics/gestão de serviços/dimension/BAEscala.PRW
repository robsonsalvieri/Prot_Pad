#INCLUDE "BADEFINITION.CH"

NEW ENTITY ESCALA

//-------------------------------------------------------------------
/*/{Protheus.doc} BAEscala
Visualiza as informacoes de Escala.

@author  Helio Leal
@since   21/03/2018
/*/
//-------------------------------------------------------------------
Class BAEscala from BAEntity
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
Method Setup( ) Class BAEscala
	_Super:Setup("Escala", DIMENSION, "TDW")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Helio Leal
@since   21/03/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAEscala
	Local cQuery := ""

	cQuery += " SELECT "
    cQuery +=   "<<KEY_TDW_TDW_FILIAL+TDW_COD>> AS BK_ESCALA, "
    cQuery +=   "TDW_COD AS COD_ESCALA, "
    cQuery +=   "TDW_DESC AS DESC_ESCALA, "
    cQuery +=   "<<CODE_INSTANCE>> AS INSTANCIA "
    cQuery += "FROM <<TDW_COMPANY>> TDW "
    cQuery += "WHERE "
    cQuery +=   "TDW.D_E_L_E_T_ = ' ' "
	cQuery +=   "<<AND_XFILIAL_TDW_FILIAL>> "

Return cQuery
