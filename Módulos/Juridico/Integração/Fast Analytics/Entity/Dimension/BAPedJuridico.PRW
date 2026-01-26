#INCLUDE "BADEFINITION.CH"

NEW ENTITY PEDJURIDICO

//-------------------------------------------------------------------
/*/{Protheus.doc} BAPedJuridico
Visualiza as informacoes dos Pedidos do Juridico.

@author  henrique.cesar
@since   21/02/2018
/*/
//-------------------------------------------------------------------
Class BAPedJuridico from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padrao.

@author  henrique.cesar
@since   21/02/2018
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BAPedJuridico
	_Super:Setup("PedJuridico", DIMENSION, "NSP")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Helio Leal
@since   26/10/2017
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAPedJuridico
	Local cQuery := ""

	cQuery += " SELECT"
	cQuery += " 		<<KEY_NSP_NSP_FILIAL+NSP_COD>> AS BK_PEDIDOS_JURIDICO,"
	cQuery += " 		NSP.NSP_COD AS COD_DO_PEDIDO,"
	cQuery += " 		NSP.NSP_DESC AS DESC_DO_PEDIDO,"
	cQuery += " 		NSP.NSP_TIPO AS TIPO_DO_PEDIDO,"
	cQuery += "         <<CODE_INSTANCE>> AS INSTANCIA"
	cQuery += " 	FROM <<NSP_COMPANY>> NSP" 
	cQuery += " 	WHERE "
	cQuery += "	   	NSP.D_E_L_E_T_ = ' '"
	cQuery += "	   	<<AND_XFILIAL_NSP_FILIAL>> "
Return cQuery
