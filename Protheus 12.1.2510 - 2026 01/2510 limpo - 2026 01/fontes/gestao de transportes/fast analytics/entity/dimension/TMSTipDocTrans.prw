#INCLUDE "BADEFINITION.CH"

NEW ENTITY 43TPDCT
		   
//-------------------------------------------------------------------
/*/{Protheus.doc} TMSTipoDocumentoTransporte
Visualiza as informações por Tipo de Documento de Transporte.

@author  Leandro Paulino
@since   07/12/2018
/*/
//-------------------------------------------------------------------
Class TMSTIPDOCTRANS from BAEntity	  
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
Method Setup( ) Class TMSTIPDOCTRANS
	_Super:Setup("TMS Tipo Doc.Transporte", DIMENSION, "###", .F.)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constrói a query da entidade.
@return cQuery, string, query a ser processada.

@author  Leandro Paulino
@since   07/12/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class TMSTIPDOCTRANS
	Local cQuery	:= ""
	Local aTipDoc	:= {}
	Local nTipDoc	:= 0
	Local cDatabase := Upper( SGDB() )

    aTipDoc := TmsValField('DOCTMS',.F.,,,.T.)

	//------------------------------------------------
	// Geração de um select virtual.
	//------------------------------------------------
	For nTipDoc := 1 To Len( aTipDoc )
		cQuery += "SELECT "
		cQuery += "'" + BAPrefixBK("<<KEY_###_>>") + aTipDoc[nTipDoc][1] + "' AS BK_DOCTMS, "
		cQuery += "'" + aTipDoc[nTipDoc][1] + "' AS CODIGO_DOCTMS, 		"
		cQuery += "'" + aTipDoc[nTipDoc][2] + "' AS DESCRICAO_DOCTMS, "
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

		If (nTipDoc < Len( aTipDoc ) )
			cQuery += "UNION "
		EndIf
	Next nTipDoc
	
Return cQuery