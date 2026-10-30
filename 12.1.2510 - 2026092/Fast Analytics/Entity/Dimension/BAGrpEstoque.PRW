#INCLUDE "BADEFINITION.CH"

NEW ENTITY GRPESTOQUE

//-------------------------------------------------------------------
/*/{Protheus.doc} BAGrpEstoque
Visualiza as informacoes do Grupo de Estoque.

@author  Helio Leal
@since   26/10/2017
/*/
//-------------------------------------------------------------------
Class BAGrpEstoque from BAEntity
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
Method Setup( ) Class BAGrpEstoque
	_Super:Setup("GrupoEstoque", DIMENSION, "SBM")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Helio Leal
@since   26/10/2017
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAGrpEstoque
	Local cQuery := ""

	cQuery += " SELECT"
	cQuery += " 		<<KEY_SBM_BM_FILIAL+BM_GRUPO>> as BK_GRUPO_ESTOQUE,"
	cQuery += " 		SBM.BM_GRUPO AS COD_GRUPO_ESTOQUE,"
	cQuery += " 		SBM.BM_DESC AS DESC_GRUPO_ESTOQUE,"
	cQuery += "         <<CODE_INSTANCE>> AS INSTANCIA"
	cQuery += " 	FROM <<SBM_COMPANY>> SBM" 
	cQuery += " 	WHERE "
	cQuery += "	   	SBM.D_E_L_E_T_ = ' '"
	cQuery += "     <<AND_XFILIAL_BM_FILIAL>>"
Return cQuery 