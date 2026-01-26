#INCLUDE "BADEFINITION.CH"

NEW ENTITY CLIENTE

//-------------------------------------------------------------------
/*/{Protheus.doc} BACliente
Visualiza as informacoes de Cliente.

@author  Helio Leal
@since   26/10/2017
/*/
//-------------------------------------------------------------------
Class BACliente from BAEntity
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
Method Setup( ) Class BACliente
	_Super:Setup("Cliente", DIMENSION, "SA1")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Helio Leal
@since   26/10/2017
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BACliente
	Local cQuery := ""

	cQuery += " SELECT"
	cQuery += " 		<<KEY_SA1_A1_FILIAL+A1_COD+A1_LOJA>> AS BK_CLIENTE,"
	cQuery += " 		SA1.A1_COD AS COD_CLIENTE,"
	cQuery += " 		SA1.A1_LOJA AS LOJA_CLIENTE,"
	cQuery += " 		SA1.A1_NOME AS NOME_CLIENTE,"
	cQuery += " 		SA1.A1_SATIV1 AS SEGMENTACAO_ATIVIDADE_1,"
	cQuery += "         <<CODE_INSTANCE>> AS INSTANCIA"
	cQuery += " 	FROM <<SA1_COMPANY>> SA1" 
	cQuery += " 	WHERE "
	cQuery += "	   	SA1.D_E_L_E_T_ = ' '"
	cQuery += "     <<AND_XFILIAL_A1_FILIAL>>"
Return cQuery
