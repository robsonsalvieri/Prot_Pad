#INCLUDE "BADEFINITION.CH"

NEW ENTITY AREASJURIDICO

//-------------------------------------------------------------------
/*/{Protheus.doc} BAAreasJuridico
Visualiza as informacoes dos assuntos juridicos de acordo com a area 
juridica responsavel.

@author  Helio Leal
@since   21/02/2018
/*/
//-------------------------------------------------------------------
Class BAAreasJuridico from BAEntity
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
Method Setup() class BAAreasJuridico
	_Super:Setup("AreasJuridico", DIMENSION, "NRB" )
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Helio Leal
@since   21/02/2018
/*/
//------------------------------------------------------------------- 
Method BuildQuery() class BAAreasJuridico
	Local cQuery := ""

	cQuery += " SELECT"
	cQuery += " 		<<KEY_NRB_NRB_FILIAL+NRB_COD>> AS BK_AREA_JURIDICA,"
	cQuery += " 		NRB.NRB_COD AS COD_AREASJURIDICO,"
	cQuery += " 		NRB.NRB_DESC AS DESC_AREASJURIDICO,"
	cQuery += "         <<CODE_INSTANCE>> AS INSTANCIA"
	cQuery += " 	FROM <<NRB_COMPANY>> NRB" 
	cQuery += " 	WHERE "
	cQuery += "	   	NRB.D_E_L_E_T_ = ' '"
	cQuery += "	   	<<AND_XFILIAL_NRB_FILIAL>> "
Return cQuery
