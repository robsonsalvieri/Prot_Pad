#INCLUDE "BADEFINITION.CH"

NEW ENTITY OBRASRENTAL 

//-------------------------------------------------------------------
/*/{Protheus.doc} BAObrasRental
Visualiza as informações do cadastro de Obras.

@author  Djalma Mathias da Silva
@since   23/08/2022
/*/
//-------------------------------------------------------------------
Class BAObrasRental from BAEntity
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
Method Setup( ) Class BAObrasRental
	_Super:Setup("Obras", DIMENSION, "FP1")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Djalma Mathias da Silva
@since   23/08/2022
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAObrasRental
	Local cQuery := ""
 
	cQuery += " SELECT"
	cQuery += " 		<<KEY_FP1_FP1_FILIAL+FP1_PROJET+FP1_OBRA>> 	AS BK_OBRAS,"
    cQuery += " 		FP1.FP1_OBRA								AS OBRA, "
	cQuery += " 		FP1.FP1_NOMORI								AS NOME_OBRA,"	
	cQuery += "         <<CODE_INSTANCE>> AS INSTANCIA"
	cQuery += " 	FROM <<FP1_COMPANY>> FP1" 
	cQuery += " 	WHERE "
	cQuery += "	   	FP1.D_E_L_E_T_ = ' '"
	cQuery += "     <<AND_XFILIAL_FP1_FILIAL>>"
Return cQuery