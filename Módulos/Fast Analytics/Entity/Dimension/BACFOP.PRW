#INCLUDE "BADEFINITION.CH"

NEW ENTITY CFOP

//-------------------------------------------------------------------
/*/{Protheus.doc} BACFOP
Visualiza as informacoes da CFOP.

@author  henrique.cesar
@since   09/11/2017
/*/
//-------------------------------------------------------------------
Class BACFOP from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padrao.

@author  henrique.cesar
@since   09/11/2017
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BACFOP
	_Super:Setup("CFOP", DIMENSION, "SX5")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  henrique.cesar
@since   09/11/2017
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BACFOP
	Local cQuery := ""

	cQuery += " SELECT"
	cQuery += " 		<<KEY_SX5_X5_FILIAL+X5_CHAVE>> AS BK_CFOP,"
	cQuery += " 		SX5.X5_CHAVE AS COD_CFOP,"
	cQuery += " 		SX5.X5_DESCRI AS DESC_CFOP,"
	cQuery += "         <<CODE_INSTANCE>> AS INSTANCIA"
	cQuery += " 	FROM <<SX5_COMPANY>> SX5" 
	cQuery += " 	WHERE "
	cQuery += "	   	SX5.X5_TABELA = '13'"
	cQuery += "     <<AND_XFILIAL_X5_FILIAL>>"
Return cQuery