#INCLUDE "BADEFINITION.CH"

NEW ENTITY COMARCA

//-------------------------------------------------------------------
/*/{Protheus.doc} BAComarca
visualiza as informacoes do Banco

@author  Helio Leal
@since   21/02/2018
/*/
//-------------------------------------------------------------------
Class BAComarca from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrao.  

@author  Helio Leal
@since   21/02/2018
/*/
//-------------------------------------------------------------------  
Method Setup() class BAComarca
	_Super:Setup("Comarca", DIMENSION, "NQ6" )
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Helio Leal
@since   21/02/2018
/*/
//------------------------------------------------------------------- 
Method BuildQuery() class BAComarca
	Local cQuery := ""

	cQuery += " SELECT"
	cQuery += " 		<<KEY_NQ6_NQ6_FILIAL+NQ6_COD>> AS BK_COMARCA,"
	cQuery += " 		NQ6.NQ6_COD AS COD_COMARCA,"
	cQuery += " 		NQ6.NQ6_DESC AS DESC_COMARCA,"
	cQuery += " 		NQ6.NQ6_UF AS UF_COMARCA,"
	cQuery += "         <<CODE_INSTANCE>> AS INSTANCIA"
	cQuery += " 	FROM <<NQ6_COMPANY>> NQ6" 
	cQuery += " 	WHERE "
	cQuery += "	   	NQ6.D_E_L_E_T_ = ' '"
	cQuery += "	   	<<AND_XFILIAL_NQ6_FILIAL>> "
Return cQuery
