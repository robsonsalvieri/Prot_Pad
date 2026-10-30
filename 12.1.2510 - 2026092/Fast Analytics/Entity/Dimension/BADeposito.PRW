#INCLUDE "BADEFINITION.CH"

NEW ENTITY DEPOSITO

//-------------------------------------------------------------------
/*/{Protheus.doc} BADeposito
Visualiza as informacoes de Deposito.

@author  Helio Leal
@since   26/10/2017
/*/
//-------------------------------------------------------------------
Class BADeposito from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padrao.

@author  Helio Leal
@since   26/10/2017
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BADeposito
	_Super:Setup("Deposito", DIMENSION, "SB2")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Helio Leal
@since   26/10/2017
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BADeposito
	Local cQuery := ""

	cQuery += " SELECT DISTINCT"
	cQuery += " 		<<KEY_SB2_B2_FILIAL+B2_LOCAL>> AS BK_DEPOSITO,"
	cQuery += " 		SB2.B2_LOCAL  AS COD_DEPOSITO,"
	cQuery += " 		'ARMAZEM ' || SB2.B2_LOCAL AS DESC_DEPOSITO,"
	cQuery += "         <<CODE_INSTANCE>> AS INSTANCIA"
	cQuery += " 	FROM <<SB2_COMPANY>> SB2" 
	cQuery += " 	WHERE "
	cQuery += "	   	SB2.D_E_L_E_T_ = ' '"
	cQuery += "		<<AND_XFILIAL_B2_FILIAL>>"
Return cQuery