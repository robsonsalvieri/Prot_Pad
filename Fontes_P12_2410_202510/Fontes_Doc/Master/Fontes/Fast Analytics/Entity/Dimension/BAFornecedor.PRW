#INCLUDE "BADEFINITION.CH"

NEW ENTITY FORNECEDOR

//-------------------------------------------------------------------
/*/{Protheus.doc} BAFornecedor
Visualiza as informacoes do Fornecedor.

@author  henrique.cesar
@since   09/11/2017
/*/
//-------------------------------------------------------------------
Class BAFornecedor from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padrao.

@author  henrique.cesar
@since   09/11/2017
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BAFornecedor
	_Super:Setup("Fornecedor", DIMENSION, "SA2")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  henrique.cesar
@since   09/11/2017
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAFornecedor
	Local cQuery := ""

	cQuery += " SELECT"
	cQuery += " 		<<KEY_SA2_A2_FILIAL+A2_COD+A2_LOJA>> AS BK_FORNECEDOR,"
	cQuery += " 		SA2.A2_COD AS COD_FORNECEDOR,"
	cQuery += " 		SA2.A2_LOJA AS LOJA_FORNECEDOR,"
	cQuery += " 		SA2.A2_NOME AS FORNECEDOR,"
	cQuery += "         <<CODE_INSTANCE>> AS INSTANCIA"
	cQuery += " 	FROM <<SA2_COMPANY>> SA2" 
	cQuery += " 	WHERE "
	cQuery += "	   	SA2.D_E_L_E_T_ = ' '"
	cQuery += "	    <<AND_XFILIAL_A2_FILIAL>> " 
Return cQuery 