#INCLUDE "BADEFINITION.CH"

NEW ENTITY BANCO

//-------------------------------------------------------------------
/*/{Protheus.doc} BABanco
visualiza as informacoes do Banco

@author  BI TEAM
@since   29/12/2017
/*/
//-------------------------------------------------------------------
Class BABanco from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrao.  

@author  BI TEAM
@since   29/12/2017
/*/
//-------------------------------------------------------------------  
Method Setup() class BABanco
	_Super:Setup("Banco", DIMENSION, "SA6" ) //"Banco"
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  BI TEAM
@since   29/12/2017
/*/
//------------------------------------------------------------------- 
Method BuildQuery() class BABanco
	Local cQuery := ""

	cQuery += " SELECT"
	cQuery += " 		<<KEY_SA6_A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON>> AS BK_BCO,"
	cQuery += " 		SA6.A6_COD AS COD_BCO,"
	cQuery += " 		SA6.A6_AGENCIA AS AGENCIA_BCO,"
	cQuery += " 		SA6.A6_NUMCON AS NUMCON_BCO,"
	cQuery += " 		SA6.A6_NOME AS NOME_BCO,"
	cQuery += "         <<CODE_INSTANCE>> AS INSTANCIA"
	cQuery += " 	FROM <<SA6_COMPANY>> SA6" 
	cQuery += " 	WHERE "
	cQuery += "	   	SA6.D_E_L_E_T_ = ' '"
	cQuery += " 	<<AND_XFILIAL_A6_FILIAL>> "
Return cQuery
