#INCLUDE "BADEFINITION.CH"

NEW ENTITY SUBAREA

//-------------------------------------------------------------------
/*/{Protheus.doc} BASubArea
Visualiza as informacoes das subareas juridicas

@author  Helio Leal
@since   21/02/2018
/*/
//-------------------------------------------------------------------
Class BASubArea from BAEntity
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
Method Setup() class BASubArea
	_Super:Setup("SubArea", DIMENSION, "NRL" )
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Helio Leal
@since   21/02/2018
/*/
//------------------------------------------------------------------- 
Method BuildQuery() class BASubArea
	Local cQuery := ""

	cQuery += " SELECT"
	cQuery += " 		<<KEY_NRL_NRL_FILIAL+NRL_COD+NRL_CAREA>> AS BK_SUBAREA,"
	cQuery += " 		NRL.NRL_COD AS COD_SUBAREA,"
	cQuery += " 		NRL.NRL_CAREA AS COD_AREA,"
	cQuery += " 		NRL.NRL_DESC AS DESC_SUBAREA,"
	cQuery += "         <<CODE_INSTANCE>> AS INSTANCIA "
	cQuery += " 	FROM <<NRL_COMPANY>> NRL" 
	cQuery += " 	WHERE "
	cQuery += "	   	NRL.D_E_L_E_T_ = ' '"
	cQuery += "     <<AND_XFILIAL_NRL_FILIAL>> "
Return cQuery
