#INCLUDE "BADEFINITION.CH"

NEW ENTITY 43SrvTMS

//-------------------------------------------------------------------
/*/{Protheus.doc} BATipoOcorrencia
Visualiza as informações por Tabela de Ocorrencia

@author  Leandro Paulino
@since   07/12/2018
/*/
//-------------------------------------------------------------------
Class TMSServicoTMS from BAEntity
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
Method Setup( ) Class TMSServicoTMS
	_Super:Setup("TMS Servicos - SERMTS", DIMENSION, "###", .F.)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constrói a query da entidade.
@return cQuery, string, query a ser processada.

@author  Leandro Paulino
@since   07/12/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class TMSServicoTMS
	Local cQuery    := ""
	Local aSerTMS  := {}
	Local nSerTMS  := 0
	Local cDatabase := Upper( SGDB() )

 	aSerTMS := TmsValField('SERTMS',.F.,,,.T.,,.T.)
    
	//------------------------------------------------
	// Geração de um select virtual.
	//------------------------------------------------
	For nSerTMS := 1 To Len( aSerTMS )
		cQuery += "SELECT "
		cQuery += "'" + BAPrefixBK("<<KEY_###_>>") + aSerTMS[nSerTMS][1] + "' AS BK_SERTMS, "
		cQuery += "'" + aSerTMS[nSerTMS][1] + "' AS CODIGO_SERTMS, 		"
		cQuery += "'" + NoAcento(aSerTMS[nSerTMS][2]) + "' AS DESCRICAO_SERTMS, "
		cQuery += " <<CODE_INSTANCE>>	AS INSTANCIA "
		//------------------------------------------------------
		// Tratamento por banco para pegar uma tabela dummy.
		//------------------------------------------------------
		Do Case    
			Case ( "ORACLE" $ cDatabase )
				cQuery += " FROM DUAL "
			Case ( "DB2" $ cDatabase )
				cQuery += " FROM SYSIBM.SYSDUMMY1 "
		EndCase

		If (nSerTMS < Len( aSerTMS ) )
			cQuery += "UNION "
		EndIf
	Next nSerTMS

Return cQuery