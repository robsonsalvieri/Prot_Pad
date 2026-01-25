#INCLUDE "BADEFINITION.CH"
#INCLUDE "BASITCONTRATO.CH"

NEW ENTITY SITCONTRATO

//-------------------------------------------------------------------
/*/{Protheus.doc} BASitContrato
Visualiza as informacoes da situacao do contrato.

@author  Angelo Lee
@since   25/10/2018
/*/
//-------------------------------------------------------------------
Class BASitContrato from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padrao.

@author  Angelo Lee
@since   25/10/2018
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BASitContrato
	_Super:Setup("SituacaoContrato", DIMENSION, "###", .F.)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Angelo Lee
@since   25/10/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BASitContrato
	Local cDatabase  := Upper( SGDB() )
	Local cQuery     := ""
	Local aStatus    := {}          
	Local nStatus    := 0

	aAdd( aStatus, { "01", STR0001 } ) //"Cancelado"
	aAdd( aStatus, { "02", STR0002 } ) //"Em Elaboracao" 
	aAdd( aStatus, { "03", STR0003 } ) //"Emitido" 
	aAdd( aStatus, { "04", STR0004 } ) //"Em Aprovacao" 
	aAdd( aStatus, { "05", STR0005 } ) //"Vigente" 
	aAdd( aStatus, { "06", STR0006 } ) //"Paralisado" 
	aAdd( aStatus, { "07", STR0007 } ) //"Sol Fina." 
	aAdd( aStatus, { "08", STR0008 } ) //"Finalizado" 
	aAdd( aStatus, { "09", STR0009 } ) //"Revisao" 
	aAdd( aStatus, { "10", STR0010 } ) //"Revisado" 
	aAdd( aStatus, { "11", STR0011 } ) //"Rejeitado" 
	aAdd( aStatus, { " A", STR0012 } ) //"Revisao por Alcadas" 

    For nStatus := 1 To Len( aStatus )
        //------------------------------------------------
        // Geracao de um select virtual.
        //------------------------------------------------
        cQuery += "SELECT "
        cQuery += "'" + BAPrefixBK("<<KEY_###_>>") + aStatus[nStatus][1] + "' AS BK_SITCONTRATO, "
        cQuery += "'" + aStatus[nStatus][1] + "' AS CODIGO_SITCONTRATO, "
        cQuery += "'" + aStatus[nStatus][2] + "' AS DESCRICAO_SITCONTRATO, "
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