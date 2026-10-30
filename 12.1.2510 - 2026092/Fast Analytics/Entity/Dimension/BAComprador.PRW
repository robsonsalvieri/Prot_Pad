#INCLUDE "BADEFINITION.CH"

NEW ENTITY COMPRADOR

//-------------------------------------------------------------------
/*/{Protheus.doc} BAComprador
Visualiza as informacoes de Comprador.

@author  Helio Leal
@since   16/02/2018
/*/
//-------------------------------------------------------------------
Class BAComprador from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padrao.

@author  Helio Leal
@since   16/02/2018
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BAComprador
	_Super:Setup("Comprador", DIMENSION, "SY1")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Helio Leal
@since   16/02/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAComprador
	Local cQuery := ""

	cQuery += " SELECT "
	cQuery += 	"<<KEY_SY1_Y1_FILIAL+Y1_COD>> AS BK_COMPRADOR, "
	cQuery += 	"SY1.Y1_COD AS COD_COMPRADOR, "
	cQuery += 	"SY1.Y1_NOME AS NOME_COMPRADOR, "
	cQuery +=   "<<CODE_INSTANCE>> AS INSTANCIA "
	cQuery += "FROM <<SY1_COMPANY>> SY1 " 
	cQuery += "WHERE "
	cQuery += 	"SY1.D_E_L_E_T_ = ' ' "
	cQuery += 	"<<AND_XFILIAL_Y1_FILIAL>> "
Return cQuery
