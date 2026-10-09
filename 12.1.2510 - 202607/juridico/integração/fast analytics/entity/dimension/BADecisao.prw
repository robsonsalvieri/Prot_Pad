#INCLUDE "BADEFINITION.CH"

NEW ENTITY DECISAO

//-------------------------------------------------------------------
/*/{Protheus.doc} BADecisao
Visualiza as informacoes das Decisoes da area Juridica.

@author  henrique.cesar
@since   23/02/2018
/*/
//-------------------------------------------------------------------
Class BADecisao from BAEntity
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
Method Setup() class BADecisao
	_Super:Setup("Decisao", DIMENSION, "NQQ" )
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  henrique.cesar
@since   23/02/2018
/*/
//------------------------------------------------------------------- 
Method BuildQuery() class BADecisao
	Local cQuery := ""

	cQuery += " SELECT"
	cQuery += " 		<<KEY_NQQ_NQQ_FILIAL+NQQ_COD>> AS BK_DECISAO,"
	cQuery += " 		NQQ.NQQ_COD AS COD_DECISAO,"
	cQuery += " 		NQQ.NQQ_DESC AS DESC_DECISAO,"
	cQuery += "         <<CODE_INSTANCE>> AS INSTANCIA"
	cQuery += " 	FROM <<NQQ_COMPANY>> NQQ" 
	cQuery += " 	WHERE "
	cQuery += "	   	NQQ.D_E_L_E_T_ = ' '"
	cQuery += "     <<AND_XFILIAL_NQQ_FILIAL>> "
Return cQuery
