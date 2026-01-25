#INCLUDE "BADEFINITION.CH"

NEW ENTITY FORMACORRECAO

//-------------------------------------------------------------------
/*/{Protheus.doc} BAFormaCorrecao
Visualiza as informacoes das Fases de Correcao da area juridica.

@author  henrique.cesar
@since   23/02/2018
/*/
//-------------------------------------------------------------------
Class BAFormaCorrecao from BAEntity
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
Method Setup() class BAFormaCorrecao
	_Super:Setup("FormaCorrecao", DIMENSION, "NW7" )
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  henrique.cesar
@since   23/02/2018
/*/
//------------------------------------------------------------------- 
Method BuildQuery() class BAFormaCorrecao
	Local cQuery := ""

	cQuery += " SELECT"
	cQuery += " 		<<KEY_NW7_NW7_FILIAL+NW7_COD>> AS BK_FORMA_CORRECAO,"
	cQuery += " 		NW7.NW7_COD AS COD_FORMA_CORRECAO,"
	cQuery += " 		NW7.NW7_DESC AS DESC_FORMA_CORRECAO,"
	cQuery += "         <<CODE_INSTANCE>> AS INSTANCIA"
	cQuery += " 	FROM <<NW7_COMPANY>> NW7" 
	cQuery += " 	WHERE "
	cQuery += "	   	NW7.D_E_L_E_T_ = ' '"
	cQuery += "     <<AND_XFILIAL_NW7_FILIAL>> "
Return cQuery
