#INCLUDE "BADEFINITION.CH"

NEW ENTITY GRPFORNECEDOR

//-------------------------------------------------------------------
/*/{Protheus.doc} BAGrpFornecedor
visualiza as informacoes Grupo de Fornecedores

@author  BI TEAM
@since   29/12/2017
/*/
//-------------------------------------------------------------------
Class BAGrpFornecedor from BAEntity
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
Method Setup() class BAGrpFornecedor
	_Super:Setup("GrpFornecedor", DIMENSION, "SX5" ) //"Grupo de Fornecedor"
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  BI TEAM
@since   29/12/2017
/*/
//------------------------------------------------------------------- 
Method BuildQuery() class BAGrpFornecedor
	Local cQuery := ""

	cQuery += " SELECT"
	cQuery += " 		<<KEY_SX5_X5_FILIAL+X5_CHAVE>> AS BK_GRUPO_FORNECEDOR,"
	cQuery += " 		SX5.X5_CHAVE AS COD_GRUPO_FOR,"
	cQuery += " 		SX5.X5_DESCRI AS DESC_GRUPO_FOR,"
	cQuery += "         <<CODE_INSTANCE>> AS INSTANCIA"
	cQuery += " 	FROM <<SX5_COMPANY>> SX5" 
	cQuery += " 	WHERE "
	cQuery += "	   	SX5.X5_TABELA = 'Y7'"
	cQuery += "	   	AND SX5.D_E_L_E_T_ = ' '"
    cQuery += "	   	<<AND_XFILIAL_X5_FILIAL>> "
Return cQuery
