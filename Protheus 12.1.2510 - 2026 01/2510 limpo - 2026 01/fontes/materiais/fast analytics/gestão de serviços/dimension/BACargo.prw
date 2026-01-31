#INCLUDE "BADEFINITION.CH"

NEW ENTITY CARGO

//-------------------------------------------------------------------
/*/{Protheus.doc} BACargo
Visualiza as informacoes dos Cargos Juridicos.

@author  henrique.cesar
@since   23/02/2018
/*/
//-------------------------------------------------------------------
Class BACargo from BAEntity
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
Method Setup() class BACargo
	_Super:Setup("Cargo", DIMENSION, "SQ3" )
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  henrique.cesar
@since   23/02/2018
/*/
//------------------------------------------------------------------- 
Method BuildQuery() class BACargo
	Local cQuery := ""

	cQuery += " SELECT"
	cQuery += " 		<<KEY_SQ3_Q3_FILIAL+Q3_CARGO>> AS BK_CARGO,"
	cQuery += " 		SQ3.Q3_CARGO AS COD_CARGO,"
	cQuery += " 		SQ3.Q3_DESCSUM AS DESC_CARGO,"
	cQuery += "         <<CODE_INSTANCE>> AS INSTANCIA"
	cQuery += " 	FROM <<SQ3_COMPANY>> SQ3" 
	cQuery += " 	WHERE "
	cQuery += "	   	SQ3.D_E_L_E_T_ = ' ' "
	cQuery += "     <<AND_XFILIAL_Q3_FILIAL>> "
Return cQuery
