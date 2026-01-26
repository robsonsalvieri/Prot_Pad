#INCLUDE "BADEFINITION.CH"

NEW ENTITY FAMCOM

//-------------------------------------------------------------------
/*/{Protheus.doc} BAFamCom
Visualiza as informacoes da Familia Comercial.

@author  Helio Leal
@since   26/10/2017
/*/
//-------------------------------------------------------------------
Class BAFamCom from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padrao.

@author  Helio Leal
@since   26/10/2017
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BAFamCom
	_Super:Setup("FamiliaComercial", DIMENSION, "ACU")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Helio Leal
@since   26/10/2017
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAFamCom
	Local cQuery := ""

	cQuery += " SELECT"
	cQuery += " 		<<KEY_ACU_ACU_FILIAL+ACU_COD>> as BK_FAMILIA_COMERCIAL,"
	cQuery += " 		ACU.ACU_COD AS COD_FAMILIA_COMERCIAL,"
	cQuery += " 		ACU.ACU_DESC AS DESC_FAMILIA_COMERCIAL,"
	cQuery += "         <<CODE_INSTANCE>> AS INSTANCIA"
	cQuery += " 	FROM <<ACU_COMPANY>> ACU" 
	cQuery += " 	WHERE "
	cQuery += "	   	ACU.D_E_L_E_T_ = ' '"
	cQuery += "	   	<<AND_XFILIAL_ACU_FILIAL>> "
Return cQuery 