#INCLUDE "BADEFINITION.CH"
#INCLUDE "BATPCARTEIRA.CH"

NEW ENTITY TPCARTEIRA

//-------------------------------------------------------------------
/*/{Protheus.doc} BATpCarteira
Visualiza as informacoes de tipo de carteira.

@author  Andreia Lima
@since   03/01/2018
/*/
//-------------------------------------------------------------------
Class BATpCarteira from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padrao.

@author  Andreia Lima
@since   03/01/2018
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BATpCarteira
	_Super:Setup("TpCarteira", DIMENSION, "###", .F.)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Andreia Lima
@since   03/01/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BATpCarteira
	Local cDatabase := Upper( TCGetDB() )
	Local cQuery    := ""
	
	//------------------------------------------------
	// Geracao de um select virtual.
	//------------------------------------------------
	cQuery += "SELECT "
	cQuery += "'" + BAPrefixBK("<<KEY_###_>>") + 'P' + "' AS BK_TPCARTEIRA, "
	cQuery += "'" + 'P' + "' AS CODIGO_TPCARTEIRA, "
	cQuery += "'" + STR0001 + "' AS DESCRICAO_TPCARTEIRA, " //Previsto
	cQuery += "<<CODE_INSTANCE>> AS INSTANCIA "
		
	//------------------------------------------------------
	// Tratamento por banco para pegar uma tabela dummy.
	//------------------------------------------------------
	Do Case    
		Case ( "ORACLE" $ cDatabase )
			cQuery += " FROM DUAL "
		Case ( "DB2" $ cDatabase )
			cQuery += " FROM SYSIBM.SYSDUMMY1 "
	EndCase

	cQuery += "UNION "

	cQuery += "SELECT "
	cQuery += "'" + BAPrefixBK("<<KEY_###_>>") + 'R' + "' AS BK_TPCARTEIRA, "
	cQuery += "'" + 'R' + "' AS CODIGO_TPCARTEIRA, "
	cQuery += "'" + STR0002 + "' AS DESCRICAO_TPCARTEIRA, " //Realizado
	cQuery += "<<CODE_INSTANCE>> AS INSTANCIA "

	Do Case    
		Case ( "ORACLE" $ cDatabase )
			cQuery += " FROM DUAL "
		Case ( "DB2" $ cDatabase )
			cQuery += " FROM SYSIBM.SYSDUMMY1 "
	EndCase
	
Return cQuery
