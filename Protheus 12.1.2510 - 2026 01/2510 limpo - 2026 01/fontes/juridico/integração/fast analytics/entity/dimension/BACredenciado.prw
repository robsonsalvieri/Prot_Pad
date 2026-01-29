#INCLUDE "BADEFINITION.CH"

NEW ENTITY CREDENCIADO

//-------------------------------------------------------------------
/*/{Protheus.doc} BACredenciado
Visualiza as informacoes dos Credenciados da area Juridica.

@author  henrique.cesar
@since   23/02/2018
/*/
//-------------------------------------------------------------------
Class BACredenciado from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrao.  

@author  henrique.cesar
@since   23/02/2018
/*/
//-------------------------------------------------------------------  
Method Setup() class BACredenciado
	_Super:Setup("Credenciado", DIMENSION, "SA2" )
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  henrique.cesar
@since   23/02/2018
/*/
//------------------------------------------------------------------- 
Method BuildQuery() class BACredenciado
	Local cQuery := ""

	cQuery += " SELECT"
	cQuery += " 		<<KEY_SA2_A2_FILIAL+A2_COD+A2_LOJA>> AS BK_CREDENCIADO,"
	cQuery += " 		SA2.A2_COD AS COD_CREDENCIADO,"
	cQuery += " 		SA2.A2_LOJA AS LOJA_CREDENCIADO,"
	cQuery += " 		SA2.A2_NOME AS NOME_CREDENCIADO,"
	cQuery += "         <<CODE_INSTANCE>> AS INSTANCIA"
	cQuery += " 	FROM <<SA2_COMPANY>> SA2" 
	cQuery += " 	WHERE "
	cQuery += "	   	SA2.D_E_L_E_T_ = ' '"
	cQuery += "	   	<<AND_XFILIAL_A2_FILIAL>> "
Return cQuery
