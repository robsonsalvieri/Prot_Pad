#INCLUDE "BADEFINITION.CH"

NEW ENTITY FAMMAT

//-------------------------------------------------------------------
/*/{Protheus.doc} BAFamMat
Visualiza as informacoes da Familia Material.

@author  Helio Leal
@since   26/10/2017
/*/
//-------------------------------------------------------------------
Class BAFamMat from BAEntity
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
Method Setup( ) Class BAFamMat
	_Super:Setup("FamiliaMaterial", DIMENSION, "SX5")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Helio Leal
@since   26/10/2017
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAFamMat
	Local cQuery := ""

	cQuery += " SELECT"
	cQuery += " 		<<KEY_SX5_X5_FILIAL+X5_CHAVE>> as BK_FAMILIA_MATERIAL,"
	cQuery += " 		SX5.X5_FILIAL AS FILIAL,"
	cQuery += " 		SX5.X5_TABELA AS TABELA,"
	cQuery += " 		SX5.X5_CHAVE AS COD_FAMILIA_MATERIAL,"
	cQuery += " 		SX5.X5_DESCRI AS DESC_FAMILIA_MATERIAL,"
	cQuery += "         <<CODE_INSTANCE>> AS INSTANCIA"	
	cQuery += " 	FROM <<SX5_COMPANY>> SX5" 
	cQuery += " 	WHERE X5_TABELA = '02' AND "
	cQuery += "	   	SX5.D_E_L_E_T_ = ' '"
	cQuery += "	   	<<AND_XFILIAL_X5_FILIAL>> "
Return cQuery 