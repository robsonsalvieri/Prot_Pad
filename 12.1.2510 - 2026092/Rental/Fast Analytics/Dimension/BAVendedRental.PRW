#INCLUDE "BADEFINITION.CH"

NEW ENTITY CADVENDRENTAL

//-------------------------------------------------------------------
/*/{Protheus.doc} BAVENDEDRENTAL 
Visualiza as informacoes do Cadastro de Vendedor

@author  Djalma Mathias da Silva
@since   23/08/2022
/*/
//-------------------------------------------------------------------
Class BAVENDEDRENTAL from BAEntity
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
Method Setup( ) Class BAVENDEDRENTAL
	_Super:Setup("VendedorRental", DIMENSION, "SA3")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Djalma Mathias da Silva
@since   23/08/2022
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAVENDEDRENTAL
	Local cQuery := ""

	cQuery += " SELECT "
	cQuery += " <<KEY_SA3_A3_FILIAL+A3_COD>> 	AS BK_GESTOR, "
	cQuery += " SA3.A3_COD         				AS COD_GESTOR, "
	cQuery += " SA3.A3_NOME        				AS NOME_GESTOR, "
	cQuery += " <<CODE_INSTANCE>> 				AS INSTANCIA "
	cQuery += " FROM <<SA3_COMPANY>> SA3 " 
	cQuery += " WHERE "
	cQuery += "	SA3.D_E_L_E_T_ = ' ' "
	cQuery += " <<AND_XFILIAL_A3_FILIAL>> "
	
Return cQuery
