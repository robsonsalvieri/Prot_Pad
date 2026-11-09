#INCLUDE "BADEFINITION.CH"

NEW ENTITY CNDPGTORENTAL

//-------------------------------------------------------------------
/*/{Protheus.doc} BACNDPGTORENTAL 
Visualiza as informacoes de Condição de Pagamento.

@author  Djalma Mathias da Silva
@since   23/08/2022
/*/
//-------------------------------------------------------------------
Class BACNDPGTORENTAL from BAEntity
	Method Setup( ) CONSTRUCTOR 
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padrao.

@author  Djalma Mathias da Silva
@since   23/08/2022 
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BACNDPGTORENTAL
	_Super:Setup("CondPgtoRental", DIMENSION, "SE4")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Djalma Mathias da Silva
@since   23/08/2022
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BACNDPGTORENTAL
	Local cQuery := ""

	cQuery += " SELECT"
	cQuery += " 		<<KEY_SE4_E4_FILIAL+E4_CODIGO>> 	AS BK_CONDICAO_DE_PAGAMENTO,"
	cQuery += " 		SE4.E4_CODIGO                 		AS COD_CONDICAO_PAGAMENTO, "
	cQuery += " 		SE4.E4_DESCRI                 		AS DESC_CONDICAO_PAGAMENTO, "
	cQuery += "         <<CODE_INSTANCE>> 					AS INSTANCIA"
	cQuery += " 	FROM <<SE4_COMPANY>> SE4" 
	cQuery += " 	WHERE "
	cQuery += "	   	SE4.D_E_L_E_T_ = ' '"
	cQuery += "     <<AND_XFILIAL_E4_FILIAL>>"
Return cQuery
