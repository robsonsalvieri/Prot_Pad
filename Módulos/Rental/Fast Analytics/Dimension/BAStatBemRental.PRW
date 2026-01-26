#INCLUDE "BADEFINITION.CH"

NEW ENTITY STATBEMRENTAL

//-------------------------------------------------------------------
/*/{Protheus.doc} BASTATBEMRENTAL 
Visualiza as informacoes do Status do Bem.

@author  Djalma Mathias da Silva
@since   23/08/2022   
/*/
//-------------------------------------------------------------------
Class BASTATBEMRENTAL from BAEntity
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
Method Setup( ) Class BASTATBEMRENTAL
	_Super:Setup("StatusBem", DIMENSION, "FQ4")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Djalma Mathias da Silva
@since   23/08/2022
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BASTATBEMRENTAL

	Local cQuery := ""

	cQuery += " SELECT DISTINCT "
	cQuery += " <<KEY_FQ4_FQ4_FILIAL+FQ4_STATUS>> 	AS BK_STATUS,"
	cQuery += " FQ4.FQ4_STATUS 						AS COD_STATUS, "
	cQuery += " FQ4.FQ4_DESTAT 						AS DESC_STATUS,"
	cQuery += " <<CODE_INSTANCE>> 					AS INSTANCIA"
	cQuery += " FROM <<FQ4_COMPANY>> FQ4" 
	cQuery += " WHERE "
	cQuery += "	FQ4.D_E_L_E_T_ = ' ' "
	cQuery += " <<AND_XFILIAL_FQ4_FILIAL>> AND FQ4.FQ4_STATUS <> '' "
	
Return cQuery
