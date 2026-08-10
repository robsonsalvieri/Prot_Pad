#INCLUDE "BADEFINITION.CH"

NEW ENTITY 43STIND

//-------------------------------------------------------------------
/*/{Protheus.doc} BASTatusIndenizacaoTransporte
Visualiza as informações por Tabela de Ocorrencia

@author  Leandro Paulino
@since   07/12/2018	
/*/
//-------------------------------------------------------------------
Class TMSStatusIndenizacao from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padrão.

@author  Leandro Paulino
@since   07/12/2018
/*/
//-------------------------------------------------------------------
Method Setup( ) Class TMSStatusIndenizacao
	_Super:Setup("TMS Status Indenizacao", DIMENSION, "###", .F.)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constrói a query da entidade.
@return cQuery, string, query a ser processada.

@author  Leandro Paulino
@since   07/12/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class TMSStatusIndenizacao
	Local cQuery    := ""
	Local aStatus  := {}
	Local nStatus  := 0
	Local cDatabase := Upper( SGDB() )

//    aStatus := TmsValField('Status',.F.,,,.T.,,.T.)
 	aStatus := RetSx3Box( Posicione('SX3', 2, 'DUB_STATUS', 'X3CBox()' ),,, Len(DUB->DUB_STATUS))
    
	//------------------------------------------------
	// Geração de um select virtual.
	//------------------------------------------------
	For nStatus := 1 To Len( aStatus )
		cQuery += "SELECT "
		cQuery += "'" + BAPrefixBK("<<KEY_###_>>") + aStatus[nStatus][2] + "' AS BK_STATUS_INDENIZACAO, "
		cQuery += "'" + aStatus[nStatus][2] + "' AS CODIGO_Status, 		"
		cQuery += "'" + NoAcento(aStatus[nStatus][3]) + "' AS DESCRICAO_Status, "
		cQuery += " <<CODE_INSTANCE>>					AS INSTANCIA "

		//------------------------------------------------------
		// Tratamento por banco para pegar uma tabela dummy.
		//------------------------------------------------------
		Do Case    
			Case ( "ORACLE" $ cDatabase )
				cQuery += " FROM DUAL "
			Case ( "DB2" $ cDatabase )
				cQuery += " FROM SYSIBM.SYSDUMMY1 "
		EndCase

		If (nStatus < Len( aStatus ) )
			cQuery += "UNION "
		EndIf
	Next nStatus

Return cQuery