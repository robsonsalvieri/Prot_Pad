#INCLUDE "BADEFINITION.CH"

NEW ENTITY REGIAO

//-------------------------------------------------------------------
/*/{Protheus.doc} BARegiao
Visualiza as informacoes da Regiao Geografica.

@author  Helio Leal
@since   26/10/2017
/*/
//-------------------------------------------------------------------
Class BARegiao from BAEntity
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
Method Setup( ) Class BARegiao
	_Super:Setup("Regiao", DIMENSION, "CC2")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Helio Leal
@since   26/10/2017
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BARegiao
	Local cQuery := ""

	cQuery += " SELECT "
	cQuery += " 	<<KEY_CC2_X5_CHAVE>> AS BK_REGIAO, "
	cQuery += " 	SX5.X5_CHAVE AS COD_ESTADO, " 
	cQuery += " 	SX5.X5_DESCRI AS DESC_ESTADO, "
	cQuery += " 	' ' AS COD_MUNICIPIO, ' '  AS DESC_MUNICIPIO, "
	cQuery += "     <<CODE_INSTANCE>> AS INSTANCIA "
	cQuery += " FROM <<SX5_COMPANY>> SX5 "
	cQuery += " WHERE SX5.X5_TABELA = '12' AND SX5.D_E_L_E_T_ = ' ' <<AND_XFILIAL_X5_FILIAL>> " 
	cQuery += " UNION ALL "
	cQuery += " SELECT "
	cQuery += " 	<<KEY_CC2_CC2_EST+CC2_CODMUN>> AS BK_REGIAO,"
	cQuery += " 	CC2.CC2_EST AS COD_ESTADO, "
	cQuery += "		(SELECT DISTINCT SX5.X5_DESCRI FROM <<SX5_COMPANY>> SX5 "
	cQuery += "			WHERE SX5.X5_TABELA = '12' AND SX5.X5_CHAVE = CC2.CC2_EST AND SX5.D_E_L_E_T_ = ' ' <<AND_XFILIAL_X5_FILIAL>> ) AS DESC_ESTADO, "
	cQuery += " 	CC2.CC2_CODMUN AS COD_MUNICIPIO, "
	cQuery += " 	CC2.CC2_MUN AS DESC_MUNICIPIO, "
	cQuery += "     <<CODE_INSTANCE>> AS INSTANCIA "
	cQuery += " FROM <<CC2_COMPANY>> CC2 " 
	cQuery += " WHERE "
	cQuery += "	   	CC2.D_E_L_E_T_ = ' ' "
	cQuery += "     <<AND_XFILIAL_CC2_FILIAL>>"
Return cQuery