#INCLUDE "BADEFINITION.CH"

NEW ENTITY FAMIBEMRENTAL 

//-------------------------------------------------------------------
/*/{Protheus.doc} BAFamiBemRental
Visualiza as informacoes das Famílias dos Bens.

@author  Djalma Mathias da Silva
@since   23/08/2022
/*/
//-------------------------------------------------------------------
Class BAFamiBemRental from BAEntity
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
Method Setup( ) Class BAFamiBemRental
	_Super:Setup("FamiliaBem", DIMENSION, "ST6")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Djalma Mathias da Silva
@since   23/08/2022
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAFamiBemRental
	Local cQuery := ""
 
	cQuery += " SELECT"
	cQuery += " 		<<KEY_ST6_T6_FILIAL+T6_CODFAMI>> 	AS BK_FAMILIA,"
	cQuery += " 		ST6.T6_CODFAMI						AS COD_FAMILIA,"
	cQuery += " 		ST6.T6_NOME							AS NOME_FAMILIA,"
	cQuery += " 		ST6.T6_TIPOFAM						AS TIPO_FAMILIA,"
	cQuery += "         <<CODE_INSTANCE>> 					AS INSTANCIA"
	cQuery += " 	FROM <<ST6_COMPANY>> ST6" 
	cQuery += " 	WHERE "
	cQuery += "	   	ST6.D_E_L_E_T_ = ' '"
	cQuery += "     <<AND_XFILIAL_T6_FILIAL>>"
Return cQuery
