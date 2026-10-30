#INCLUDE "BADEFINITION.CH"

NEW ENTITY VENDEDORREPST

//-------------------------------------------------------------------
/*/{Protheus.doc} BAVendedorRepst
Visualiza as informacoes do Vendedor/Representante.

@author  Helio Leal
@since   07/11/2017
/*/
//-------------------------------------------------------------------
Class BAVendedorRepst from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padrao.

@author  Helio Leal
@since   07/11/2017
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BAVendedorRepst
	_Super:Setup("VendedorRepst", DIMENSION, "SA3")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Helio Leal
@since   07/11/2017
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAVendedorRepst
	Local cQuery := ""

	cQuery += " SELECT"
	cQuery += " 		<<KEY_SA3_A3_FILIAL+A3_COD>> as BK_VENDEDOR,"
	cQuery += " 		SA3.A3_COD AS COD_REPRESENTANTE,"
	cQuery += " 		SA3.A3_NOME AS REPRESENTANTE,"
	cQuery += "         <<CODE_INSTANCE>> AS INSTANCIA"
	cQuery += " 	FROM <<SA3_COMPANY>> SA3" 
	cQuery += " 	WHERE "
	cQuery += "	   	SA3.D_E_L_E_T_ = ' '"
	cQuery += "     <<AND_XFILIAL_A3_FILIAL>>"
Return cQuery 