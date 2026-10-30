#INCLUDE "BADEFINITION.CH"

NEW ENTITY UNMEDITEM

//-------------------------------------------------------------------
/*/{Protheus.doc} BAUnMedItem
Visualiza as informacoes de Unidade de Medida do Item.

@author  Helio Leal
@since   26/10/2017
/*/
//-------------------------------------------------------------------
Class BAUnMedItem from BAEntity
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
Method Setup( ) Class BAUnMedItem
	_Super:Setup("UnidadeMedidaItem", DIMENSION, "SAH")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Helio Leal
@since   26/10/2017
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAUnMedItem
	Local cQuery := ""

	cQuery += " SELECT"
	cQuery += " 		<<KEY_SAH_AH_FILIAL+AH_UNIMED>> as BK_UNIDADE_DE_MEDIDA,"
	cQuery += " 		SAH.AH_UNIMED AS COD_UNID_MEDIDA,"
	cQuery += " 		SAH.AH_DESCPO AS DESC_UNID_MEDIDA,"
	cQuery += " 		SAH.AH_UMRES AS DESC_ABREV_UNID_MEDIDA,"
	cQuery += "         <<CODE_INSTANCE>> AS INSTANCIA"
	cQuery += " 	FROM <<SAH_COMPANY>> SAH" 
	cQuery += " 	WHERE "
	cQuery += "	   	SAH.D_E_L_E_T_ = ' '"
	cQuery += "     <<AND_XFILIAL_AH_FILIAL>>"
Return cQuery 