#INCLUDE "BADEFINITION.CH"

NEW ENTITY LOCALTRABALHO

//-------------------------------------------------------------------
/*/{Protheus.doc} BALocalTrabalho
Visualiza as informacoes dos Escritorios (Extensao Filial).  

@author  Helio Leal
@since   23/02/2018
/*/
//-------------------------------------------------------------------
Class BALocalTrabalho from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrao.  

@author  Helio Leal
@since   23/02/2018
/*/
//-------------------------------------------------------------------  
Method Setup() class BALocalTrabalho
	_Super:Setup("LocalTrabalho", DIMENSION, "NS7" )
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Helio Leal
@since   23/02/2018
/*/
//------------------------------------------------------------------- 
Method BuildQuery() class BALocalTrabalho
	Local cQuery := ""

	cQuery += " SELECT <<KEY_NS7_NS7_FILIAL+NS7_COD>> AS BK_LOCAL_TRABALHO,"
	cQuery += " 	NS7_COD AS COD_LOCAL_TRABALHO,"
	cQuery += " 	NS7_NOME AS NOME_LOCAL_TRABALHO,"
	cQuery += "     <<CODE_INSTANCE>> AS INSTANCIA"
	cQuery += " FROM <<NS7_COMPANY>> NS7"
	cQuery += " WHERE NS7.D_E_L_E_T_ = ' '" 
	cQuery += " <<AND_XFILIAL_NS7_FILIAL>>"

Return cQuery
