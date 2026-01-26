#INCLUDE "BADEFINITION.CH"

NEW ENTITY BASEDECISAO

//-------------------------------------------------------------------
/*/{Protheus.doc} BABaseDecisao
Visualiza as informacoes da Base de Decisoes do Juridico.

@author  henrique.cesar
@since   23/02/2018
/*/
//-------------------------------------------------------------------
Class BABaseDecisao from BAEntity
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
Method Setup() class BABaseDecisao
	_Super:Setup("BaseDecisao", DIMENSION, "O03" )
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  henrique.cesar
@since   23/02/2018
/*/
//------------------------------------------------------------------- 
Method BuildQuery() class BABaseDecisao
	Local cQuery := ""

	cQuery += " SELECT"
	cQuery += " 		<<KEY_O03_O03_FILIAL+O03_COD>> AS BK_BASE_DECISAO,"
	cQuery += " 		O03.O03_COD AS COD_BASE_DECISAO,"
	cQuery += " 		O03.O03_DESC AS DESC_BASE_DECISAO,"
	cQuery += "         <<CODE_INSTANCE>> AS INSTANCIA"
	cQuery += " 	FROM <<O03_COMPANY>> O03" 
	cQuery += " 	WHERE "
	cQuery += "	   	O03.D_E_L_E_T_ = ' ' "
	cQuery += "     <<AND_XFILIAL_O03_FILIAL>> "
Return cQuery
