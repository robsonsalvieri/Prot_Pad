#INCLUDE "BADEFINITION.CH"

NEW ENTITY MODALCOBRANCA
//-------------------------------------------------------------------
/*/{Protheus.doc} BAModalCobranca
visualiza as informacoes do ModalCobranca

@author  BI TEAM
@since   29/12/2017
/*/
//-------------------------------------------------------------------
Class BAModalCobranca from BAEntity
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
Method Setup() class BAModalCobranca
	_Super:Setup("ModalCobranca", DIMENSION, "SX5" ) //"ModalCobranca"
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  BI TEAM
@since   29/12/2017
/*/
//------------------------------------------------------------------- 
Method BuildQuery() class BAModalCobranca
	Local cQuery := ""

	cQuery += " SELECT"
	cQuery += " 		<<KEY_SX5_X5_FILIAL+X5_CHAVE>> AS BK_MODALCOBRANCA,"
	cQuery += " 		SX5.X5_TABELA AS COD_MODALCOBRANCA,"
	cQuery += " 		SX5.X5_DESCRI AS DESC_MODALCOBRANCA,"
	cQuery += "         <<CODE_INSTANCE>> AS INSTANCIA"
	cQuery += " 	FROM <<SX5_COMPANY>> SX5" 
	cQuery += " 	WHERE "
	cQuery += "	   	SX5.X5_TABELA = '07'"
	cQuery += "     <<AND_XFILIAL_X5_FILIAL>> "
Return cQuery
