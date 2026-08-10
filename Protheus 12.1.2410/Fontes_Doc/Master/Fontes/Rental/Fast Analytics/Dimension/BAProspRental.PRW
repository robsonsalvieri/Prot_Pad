#INCLUDE "BADEFINITION.CH"

NEW ENTITY PROSPECTRENTAL 

//-------------------------------------------------------------------
/*/{Protheus.doc} BACNDPGTO 
Visualiza as informacoes do Cadastro de Prospect

@author  Djalma Mathias da Silva
@since   23/08/2022
/*/
//-------------------------------------------------------------------
Class BAPROSPRENTAL from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass
 
//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padrao.

@author  Djalma Mathias da Silva
@since   23/08/2022
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BAPROSPRENTAL
	_Super:Setup("Prospect", DIMENSION, "SUS")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Djalma Mathias da Silva
@since   23/08/2022
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAPROSPRENTAL
	Local cQuery := ""

	cQuery += " SELECT"
	cQuery += " 		<<KEY_SUS_US_FILIAL+US_COD>> 	AS BK_PROSP,   "
	cQuery += " 		SUS.US_COD             			AS COD_PROSP,  "
	cQuery += " 		SUS.US_LOJA 					AS LOJA_PROSP, "
	cQuery += " 		SUS.US_NOME  					AS NOME_PROSP, "
	cQuery += "         <<CODE_INSTANCE>> 				AS INSTANCIA   "
	cQuery += " 	FROM <<SUS_COMPANY>> SUS" 
	cQuery += " 	WHERE "
	cQuery += "	   	SUS.D_E_L_E_T_ = ' ' "
	cQuery += "     <<AND_XFILIAL_US_FILIAL>>"
Return cQuery