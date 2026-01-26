#INCLUDE "BADEFINITION.CH"
#INCLUDE "BAORIGEM.CH"

NEW ENTITY ORIGEM

//-------------------------------------------------------------------
/*/{Protheus.doc} BAOrigem
Visualiza as informacoes por Origem que refere-se a origem da 
composicao das informacoes apresentadas. Exemplo: Contas a Receber, 
Contas A Pagar, Pedido de Venda, Pedido de Compra, Aplicacao Financeira, 
Empréstimo Financeiro. 

@author  Helio Leal
@author  Andreia Lima
@author  Angelo Lee
@since   03/01/2018
/*/
//-------------------------------------------------------------------
Class BAOrigem from BAEntity
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
Method Setup( ) Class BAOrigem
	_Super:Setup("Origem", DIMENSION, "###", .F.)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constrói a query da entidade.
@return cQuery, string, query a ser processada.

@author  Helio Leal
@author  Andreia Lima
@author  Angelo Lee
@since   03/01/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAOrigem
	Local cQuery    := ""
	Local aOrigem  := {}
	Local nOrigem  := 0
	Local cDatabase := Upper( TCGetDB() )

	aAdd( aOrigem, {"1", STR0001 } ) //"TITULOS A RECEBER"
	aAdd( aOrigem, {"2", STR0002 } ) //"TITULOS A PAGAR" 
	aAdd( aOrigem, {"3", STR0003 } ) //"COMISSOES" 
	aAdd( aOrigem, {"4", STR0004 } ) //"PEDIDO DE VENDA" 
	aAdd( aOrigem, {"5", STR0005 } ) //"PEDIDO DE COMPRA" 
	aAdd( aOrigem, {"6", STR0006 } ) //"APLICACOES" 
	aAdd( aOrigem, {"7", STR0007 } ) //"EMPRESTIMOS" 
	aAdd( aOrigem, {"8", STR0008 } ) //"CHEQUES NAO LIBERADOS" 
	aAdd( aOrigem, {"9", STR0009 } ) //"DOCTOS. DE TRANSPORTE" 
	//------------------------------------------------
	// Geração de um select virtual.
	//------------------------------------------------
	For nOrigem := 1 To Len( aOrigem )
		cQuery += "SELECT "
		cQuery += "'" + BAPrefixBK("<<KEY_###_>>") + aOrigem[nOrigem][1] + "' AS BK_ORIGEM, "
		cQuery += "'" + aOrigem[nOrigem][1] + "' AS CODIGO_ORIGEM, "
		cQuery += "'" + aOrigem[nOrigem][2] + "' AS DESCRICAO_ORIGEM, "
		cQuery += " <<CODE_INSTANCE>> AS INSTANCIA "

		//------------------------------------------------------
		// Tratamento por banco para pegar uma tabela dummy.
		//------------------------------------------------------
		Do Case    
			Case ( "ORACLE" $ cDatabase )
				cQuery += " FROM DUAL "
			Case ( "DB2" $ cDatabase )
				cQuery += " FROM SYSIBM.SYSDUMMY1 "
		EndCase

		If (nOrigem < Len( aOrigem ) )
			cQuery += "UNION "
		EndIf
	Next nOrigem
Return cQuery
