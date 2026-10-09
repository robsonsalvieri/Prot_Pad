#INCLUDE "BADEFINITION.CH"

NEW ENTITY ESPECDOC

//-------------------------------------------------------------------
/*/{Protheus.doc} BAEspecDoc
visualiza as informacoes Grupo de Fornecedores

@author  BI TEAM
@since   29/12/2017
/*/
//-------------------------------------------------------------------
Class BAEspecDoc from BAEntity
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
Method Setup() class BAEspecDoc
	_Super:Setup("EspecDoc", DIMENSION, "SX5" ) //"Especie de Documento"
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  BI TEAM
@since   29/12/2017
/*/
//------------------------------------------------------------------- 
Method BuildQuery() class BAEspecDoc
	Local cQuery := ""

	cQuery += " SELECT"
	cQuery += " 		<<KEY_SX5_X5_FILIAL+X5_CHAVE>> AS BK_ESPEC_DOC,"
	cQuery += " 		SX5.X5_TABELA AS TABELA_ESPEC_DOC,"
	cQuery += " 		SX5.X5_CHAVE AS COD_ESPEC_DOC,"
	cQuery += " 		SX5.X5_DESCRI AS DESC_ESPEC_DOC,"
	cQuery += "         <<CODE_INSTANCE>> AS INSTANCIA"
	cQuery += " 	FROM <<SX5_COMPANY>> SX5" 
	cQuery += " 	WHERE "
	cQuery += "	   		SX5.X5_TABELA = '05'"
	cQuery += "	   		AND SX5.D_E_L_E_T_ = ' '"
	cQuery += "	   		<<AND_XFILIAL_X5_FILIAL>>"
Return cQuery
