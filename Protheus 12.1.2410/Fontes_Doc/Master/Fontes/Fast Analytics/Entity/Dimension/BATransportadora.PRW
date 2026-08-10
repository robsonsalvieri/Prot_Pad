#INCLUDE "BADEFINITION.CH"

NEW ENTITY TRANSPORTADORA

//-------------------------------------------------------------------
/*/{Protheus.doc} BATransportadora
Visualiza as informacoes da Transportadora.

@author  Helio Leal
@since   06/11/2017
/*/
//-------------------------------------------------------------------
Class BATransportadora from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padrao.

@author  Helio Leal
@since   06/11/2017
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BATransportadora
	_Super:Setup("Transportadora", DIMENSION, "SA4")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Helio Leal
@since   06/11/2017
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BATransportadora
	Local cQuery := ""

	cQuery += " SELECT"
	cQuery += " 		<<KEY_SA4_A4_FILIAL+A4_COD>> as BK_TRANSPORTADORA,"
	cQuery += " 		SA4.A4_COD AS COD_TRANSPORTADORA,"
	cQuery += " 		SA4.A4_NOME AS TRANSPORTADORA,"
	cQuery += " 		SA4.A4_NREDUZ AS TRANSPORTADORA_REDUZIDO,"
	cQuery += "         <<CODE_INSTANCE>> AS INSTANCIA"
	cQuery += " 	FROM <<SA4_COMPANY>> SA4" 
	cQuery += " 	WHERE "
	cQuery += "	   	SA4.D_E_L_E_T_ = ' '"
	cQuery += "     <<AND_XFILIAL_A4_FILIAL>>"
Return cQuery 