#INCLUDE "BADEFINITION.CH"
#INCLUDE "BASITCOMPRA.CH"

NEW ENTITY SITCOMPRA

//-------------------------------------------------------------------
/*/{Protheus.doc} BASitCompra
Visualiza as informacoes da situacao da compra.

@author  Andreia Lima
@since   16/02/2018
/*/
//-------------------------------------------------------------------
Class BASitCompra from BAEntity
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
Method Setup( ) Class BASitCompra
	_Super:Setup("SituacaoCompra", DIMENSION, "###", .F.)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Andreia Lima
@since   03/01/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BASitCompra
	Local cDatabase  := Upper( TCGetDB() )
	Local cQuery     := ""
	Local aStatus    := {}          
	Local nStatus    := 0

	aAdd( aStatus, { "F", STR0001 } ) //"CONFIRMADA"
	aAdd( aStatus, { "P", STR0002 } ) //"PROGRAMADA" 
	aAdd( aStatus, { "R", STR0003 } ) //"RECEBIDA PARCIALMENTE" 
	aAdd( aStatus, { "I", STR0004 } ) //"RECEBIDA INTEGRALMENTE" 
	aAdd( aStatus, { "D", STR0005 } ) //"DEVOLVIDA" 

    For nStatus := 1 To Len( aStatus )
        //------------------------------------------------
        // Geracao de um select virtual.
        //------------------------------------------------
        cQuery += "SELECT "
        cQuery += "'" + BAPrefixBK("<<KEY_###_>>") + aStatus[nStatus][1] + "' AS BK_SITUACAO_COMPRA, "
        cQuery += "'" + aStatus[nStatus][1] + "' AS CODIGO_SITCOMPRA, "
        cQuery += "'" + aStatus[nStatus][2] + "' AS DESCRICAO_SITCOMPRA, "
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

        If nStatus < Len( aStatus )
            cQuery += "UNION "
        EndIf
    Next nStatus
Return cQuery
