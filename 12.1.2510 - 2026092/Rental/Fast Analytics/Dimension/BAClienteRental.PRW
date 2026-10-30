#INCLUDE "BADEFINITION.CH"
 
NEW ENTITY CDCLIENTRENTAL
 
//-------------------------------------------------------------------
/*/{Protheus.doc} BAClienteRental
Visualiza as informacoes de Cliente.
 
@author  Djalma Mathias da Silva
@since   22/08/2022
/*/
//-------------------------------------------------------------------
Class BAClienteRental from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( ) 
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padrao.

@author  Djalma Mathias da Silva
@since   22/08/2022
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BAClienteRental 
	_Super:Setup("ClienteRental", DIMENSION, "SA1") 
Return
 
//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Djalma Mathias da Silva
@since   22/08/2022
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAClienteRental
	Local cQuery := ""

	cQuery += " SELECT"
	cQuery += " 		<<KEY_SA1_A1_FILIAL+A1_COD+A1_LOJA>> AS BK_CLIENTE,"
	cQuery += " 		SA1.A1_COD 		AS COD_CLIENTE,"
	cQuery += " 		SA1.A1_LOJA 	AS LOJA_CLIENTE,"
	cQuery += " 		SA1.A1_NOME 	AS NOME_CLIENTE,"
	cQuery += " 		SA1.A1_SATIV1 	AS SEGMENTACAO_ATIVIDADE_1,"	
    cQuery += " 		SA1.A1_END		AS END_CLI,"
    cQuery += " 		SA1.A1_BAIRRO	AS BAIRRO_CLI,"
    cQuery += " 		SA1.A1_MUN		AS MUN_CLI,"
    cQuery += " 		SA1.A1_EST		AS UF_CLI,"
    cQuery += " 		SA1.A1_CEP		AS CEP_CLI,"
    cQuery += " 		SA1.A1_PAIS		AS PAIS_CLI,"
	cQuery += "         <<CODE_INSTANCE>> AS INSTANCIA"
	cQuery += " 	FROM <<SA1_COMPANY>> SA1" 
	cQuery += " 	WHERE "
	cQuery += "	   	SA1.D_E_L_E_T_ = ' '"
	cQuery += "     <<AND_XFILIAL_A1_FILIAL>>"
Return cQuery