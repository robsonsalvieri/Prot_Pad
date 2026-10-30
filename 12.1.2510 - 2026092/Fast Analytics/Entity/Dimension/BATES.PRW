#INCLUDE "BADEFINITION.CH"

NEW ENTITY TES

//-------------------------------------------------------------------
/*/{Protheus.doc} BATES
Visualiza as informacoes do Tipo de Entrada e Saida.

@author  Helio Leal
@since   06/11/2017
/*/
//-------------------------------------------------------------------
Class BATES from BAEntity
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
Method Setup( ) Class BATES
	_Super:Setup("TES", DIMENSION, "SF4")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Helio Leal
@since   06/11/2017
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BATES
	Local cQuery := ""

	cQuery += " SELECT"
	cQuery += " 		<<KEY_SF4_F4_FILIAL+F4_CODIGO>> as BK_TES,"
	cQuery += " 		SF4.F4_CODIGO AS COD_TES,"	
	cQuery += " 		SF4.F4_TEXTO AS DESC_TES,"
	cQuery += " 		SF4.F4_DUPLIC AS GERA_DUPLICATA_TES,"
	cQuery += " 		SF4.F4_ESTOQUE AS GERA_ESTOQUE_TES,"
	cQuery += " 		SF4.F4_TIPOPER AS TIPO_OPERACAO_TES,"
	cQuery += "         <<CODE_INSTANCE>> AS INSTANCIA"
	cQuery += " 	FROM <<SF4_COMPANY>> SF4" 
	cQuery += " 	WHERE "
	cQuery += "	   	SF4.D_E_L_E_T_ = ' ' "
	cQuery += "	   	<<AND_XFILIAL_F4_FILIAL>> "
Return cQuery