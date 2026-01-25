#INCLUDE "BADEFINITION.CH"

NEW ENTITY REGCOMERCIAL

//-------------------------------------------------------------------
/*/{Protheus.doc} BARegComercial
Visualiza as informacoes da Regiao Comercial.

@author  Helio Leal
@since   06/11/2017
/*/
//-------------------------------------------------------------------
Class BARegComercial from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padrao.

@author  Helio Leal
@since   06/11/2017
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BARegComercial
	_Super:Setup("RegComercial", DIMENSION, "ACY")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Helio Leal
@since   06/11/2017
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BARegComercial
	Local cQuery := ""

	cQuery += " SELECT"
	cQuery += " 		<<KEY_ACY_ACY_FILIAL+ACY_GRPVEN>> as BK_REGIAO_COMERCIAL,"
	cQuery += " 		ACY.ACY_GRPVEN AS COD_REGIAO_COMERCIAL,"
	cQuery += " 		ACY.ACY_DESCRI AS DESC_REGIAO_COMERCIAL,"
	cQuery += "         <<CODE_INSTANCE>> AS INSTANCIA"
	cQuery += " 	FROM <<ACY_COMPANY>> ACY" 
	cQuery += " 	WHERE "
	cQuery += "	   	ACY.D_E_L_E_T_ = ' '"
	cQuery += "     <<AND_XFILIAL_ACY_FILIAL>>"
Return cQuery 