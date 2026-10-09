#INCLUDE "BADEFINITION.CH"

NEW ENTITY NATOPER

//-------------------------------------------------------------------
/*/{Protheus.doc} BANatOper
Visualiza as informacoes de Natureza da Operacoo.

@author  Helio Leal
@since   26/10/2017
/*/
//-------------------------------------------------------------------
Class BANatOper from BAEntity
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
Method Setup( ) Class BANatOper
	_Super:Setup("NatOper", DIMENSION, "SX5")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Helio Leal
@since   26/10/2017
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BANatOper
	Local cQuery := ""

	cQuery += " SELECT"
	cQuery += " 		<<KEY_SX5_X5_FILIAL+X5_CHAVE>> AS BK_NATUREZA_DE_OPERACAO_TES,"
	cQuery += " 		SX5.X5_CHAVE AS COD_NATUR_OPER,"
	cQuery += " 		SX5.X5_DESCRI AS DESC_NATUR_OPER,"
	cQuery += "         <<CODE_INSTANCE>> AS INSTANCIA"
	cQuery += " 	FROM <<SX5_COMPANY>> SX5" 
	cQuery += " 	WHERE "
	cQuery += "	   	SX5.X5_TABELA = 'DJ'"
	cQuery += "	   	<<AND_XFILIAL_X5_FILIAL>> "

Return cQuery 