#INCLUDE "BADEFINITION.CH"

NEW ENTITY MARCA

//-------------------------------------------------------------------
/*/{Protheus.doc} BAMarca
Visualiza as informacoes de Marca.

@author  Helio Leal
@since   21/02/2018
/*/
//-------------------------------------------------------------------
Class BAMarca from BAEntity
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
Method Setup() class BAMarca
	_Super:Setup("Marca", DIMENSION, "O0E" )
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Helio Leal
@since   21/02/2018
/*/
//------------------------------------------------------------------- 
Method BuildQuery() class BAMarca
	Local cQuery := ""

	cQuery += " SELECT"
	cQuery += " 		<<KEY_O0E_O0E_FILIAL+O0E_MARCA>> AS BK_MARCA,"
	cQuery += " 		O0E.O0E_MARCA AS COD_MARCA,"
	cQuery += " 		O0E.O0E_DESC AS DESC_MARCA,"
	cQuery += "         <<CODE_INSTANCE>> AS INSTANCIA"
	cQuery += " 	FROM <<O0E_COMPANY>> O0E" 
	cQuery += " 	WHERE "
	cQuery += "	   	O0E.D_E_L_E_T_ = ' '"
	cQuery += "     <<AND_XFILIAL_O0E_FILIAL>> " 

Return cQuery
