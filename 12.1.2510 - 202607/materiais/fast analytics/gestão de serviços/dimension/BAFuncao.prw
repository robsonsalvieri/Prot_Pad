#INCLUDE "BADEFINITION.CH"

NEW ENTITY FUNCAO

//-------------------------------------------------------------------
/*/{Protheus.doc} BAFuncao
Visualiza as informacoes da Funcao Juridica.

@author  henrique.cesar
@since   23/02/2018
/*/
//-------------------------------------------------------------------
Class BAFuncao from BAEntity
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
Method Setup() class BAFuncao
	_Super:Setup("Funcao", DIMENSION, "SRJ" )
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  henrique.cesar
@since   23/02/2018
/*/
//------------------------------------------------------------------- 
Method BuildQuery() class BAFuncao
	Local cQuery := ""

	cQuery += " SELECT"
	cQuery += " 		<<KEY_SRJ_RJ_FILIAL+RJ_FUNCAO>> AS BK_FUNCAO,"
	cQuery += " 		SRJ.RJ_FUNCAO AS COD_FUNCAO,"
	cQuery += " 		SRJ.RJ_DESC AS DESC_FUNCAO,"
	cQuery += "         <<CODE_INSTANCE>> AS INSTANCIA"
	cQuery += " 	FROM <<SRJ_COMPANY>> SRJ" 
	cQuery += " 	WHERE "
	cQuery += "	   	SRJ.D_E_L_E_T_ = ' '"
	cQuery += "     <<AND_XFILIAL_RJ_FILIAL>>"
Return cQuery
