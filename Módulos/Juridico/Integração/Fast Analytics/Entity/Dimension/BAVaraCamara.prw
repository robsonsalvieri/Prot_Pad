#INCLUDE "BADEFINITION.CH"

NEW ENTITY VARACAMARA

//-------------------------------------------------------------------
/*/{Protheus.doc} BAVaraCamara
Visualiza as informacoes dos assuntos juridicos de acordo com a area 
juridica responsavel.

@author  Helio Leal
@since   23/02/2018
/*/
//-------------------------------------------------------------------
Class BAVaraCamara from BAEntity
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
Method Setup() class BAVaraCamara
	_Super:Setup("VaraCamara", DIMENSION, "NQE" )
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Helio Leal
@since   23/02/2018
/*/
//------------------------------------------------------------------- 
Method BuildQuery() class BAVaraCamara
	Local cQuery := ""

	cQuery += " SELECT"
	cQuery += " 		<<KEY_NQE_NQE_FILIAL+NQE_COD>> AS BK_VARACAMARA,"
	cQuery += " 		NQE.NQE_COD AS COD_VARACAMARA,"
	cQuery += " 		NQE.NQE_DESC AS DESC_VARACAMARA,"
	cQuery += "         <<CODE_INSTANCE>> AS INSTANCIA"
	cQuery += " 	FROM <<NQE_COMPANY>> NQE" 
	cQuery += " 	WHERE "
	cQuery += "	   	NQE.D_E_L_E_T_ = ' '"
	cQuery += "     <<AND_XFILIAL_NQE_FILIAL>>"
Return cQuery
