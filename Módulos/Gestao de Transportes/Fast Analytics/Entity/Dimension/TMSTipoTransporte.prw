#INCLUDE "BADEFINITION.CH"
#INCLUDE "TMSXFUNA.CH"

NEW ENTITY 43TTIPT
		   

//-------------------------------------------------------------------
/*/{Protheus.doc} BATipoDocumentoTransporte
Visualiza as informações por Tipo de Documento de Transporte.

@author  Leandro Paulino
@since   07/12/2018
/*/
//-------------------------------------------------------------------
Class TMSTipoTransporte from BAEntity
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
Method Setup( ) Class TMSTipoTransporte
	_Super:Setup("TMS Tipo Transporte", DIMENSION, "###", .F.)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constrói a query da entidade.
@return cQuery, string, query a ser processada.

@author  Leandro Paulino
@since   07/12/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class TMSTipoTransporte
	Local cQuery    := ""
	Local aTipTra  := {}
	Local nTipTra  := 0
	Local cDatabase := Upper( SGDB() )

    aTipTra := TmsValField('TIPTRA',.F.,,,.T.)
    
	//------------------------------------------------
	// Geração de um select virtual.
	//------------------------------------------------
	For nTipTra := 1 To Len( aTipTra )
		cQuery += "SELECT "
		cQuery += "'" + BAPrefixBK("<<KEY_###_>>") + aTipTra[nTipTra][1] + "' AS BK_TIPTRA, "
		cQuery += "'" + aTipTra[nTipTra][1] + "' AS CODIGO_TIPTRA, 		"
		cQuery += "'" + NoAcento(aTipTra[nTipTra][2]) + "' AS DESCRICAO_TIPTRA, "
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

		If (nTipTra < Len( aTipTra ) )
			cQuery += "UNION "
		EndIf
	Next nTipTra
Return cQuery