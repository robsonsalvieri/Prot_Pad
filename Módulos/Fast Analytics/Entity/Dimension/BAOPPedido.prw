#INCLUDE "BADEFINITION.CH"

NEW ENTITY OPPEDIDO

//-------------------------------------------------------------------
/*/{Protheus.doc} BAOPPedido
Visualiza as informacoes de Ordem x Pedido.

@author  Helio Leal
@since   23/11/2017
/*/
//-------------------------------------------------------------------
Class BAOPPedido from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrao.

@author  Helio Leal
@since   23/11/2017
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BAOPPedido
	_Super:Setup("OPPedido", DIMENSION, "SC2")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.

@return aQuery, array, Retona as consultas da entidade por empresa.

@author Helio Leal
@since   23/11/2017
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAOPPedido
	Local cQuery := ""

	cQuery := " SELECT"
	cQuery += " 	<<KEY_SC2_C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD>> AS BK_ORDEM_PEDIDO,"
	cQuery += " 	C2_NUM||C2_ITEM||C2_SEQUEN||C2_ITEMGRD AS ORDEM, C2_PEDIDO AS PEDIDO,"
	cQuery += " 	C2_SEQUEN AS SEQUENCIA,"
	cQuery += "     <<CODE_INSTANCE>> AS INSTANCIA "
	cQuery += " FROM <<SC2_COMPANY>> SC2"
	cQuery += " WHERE SC2.D_E_L_E_T_ = ' '"
	cQuery += " <<AND_XFILIAL_C2_FILIAL>> "
	
Return cQuery

