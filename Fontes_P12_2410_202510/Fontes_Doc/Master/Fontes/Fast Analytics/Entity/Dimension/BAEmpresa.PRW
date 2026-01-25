#INCLUDE "BADEFINITION.CH"

NEW ENTITY EMPRESA

//-------------------------------------------------------------------
/*/{Protheus.doc} BAEmpresa
Visualiza as informacoes de Empresa.

@author  Helio Leal
@author  Andreia Lima
@since   31/10/2017
/*/
//-------------------------------------------------------------------
Class BAEmpresa from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padrao.

@author  Helio Leal
@author  Andreia Lima
@since   31/10/2017
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BAEmpresa
	_Super:Setup("Empresa", DIMENSION, "SM0", .F.)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Helio Leal
@author  Andreia Lima
@since   31/10/2017
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAEmpresa
	Local cQuery    := ""
	Local aCompany  := BICompanySelected( )
	Local nCompany  := 0
	Local cDatabase := Upper( TCGetDB() )

	//------------------------------------------------
	// Gera��o de um select virtual.
	//------------------------------------------------
	For nCompany := 1 To Len( aCompany )
		cQuery += "SELECT "
		cQuery += "'" + BAPrefixBK("<<KEY_SM0_>>") + aCompany[nCompany] + "' AS BK_EMPRESA, "
		cQuery += "'" + aCompany[nCompany] + "' AS CODIGO_EMPRESA, "
		cQuery += "'" + AllTrim( FWEmpName( aCompany[nCompany] ) ) + "' AS DESCRICAO_EMPRESA, "
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

		If (nCompany < Len( aCompany ) )
			cQuery += "UNION "
		EndIf
	Next nCompany
Return cQuery
