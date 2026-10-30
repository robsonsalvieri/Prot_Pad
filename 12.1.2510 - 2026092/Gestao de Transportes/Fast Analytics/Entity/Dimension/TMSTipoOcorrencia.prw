#INCLUDE "BADEFINITION.CH"

NEW ENTITY 43TPOCO

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSTipoOcorrencia
Visualiza as informações por Tabela de Ocorrencia

@author  Leandro Paulino
@since   07/12/2018
/*/
//-------------------------------------------------------------------
Class TMSTipoOcorrencia from BAEntity
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
Method Setup( ) Class TMSTipoOcorrencia
	_Super:Setup("TMS Tipo Ocorrencia Transporte", DIMENSION, "###", .F.)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constrói a query da entidade.
@return cQuery, string, query a ser processada.

@author  Leandro Paulino
@since   07/12/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class TMSTipoOcorrencia
	Local cQuery    := ""
	Local aTipOco  := {}
	Local nTipOco  := 0
	Local cDatabase := Upper( SGDB() )

    aTipOco := TmsValField('TIPOCO',.F.,,,.T.,,,.T.)
    
	//------------------------------------------------
	// Geração de um select virtual.
	//------------------------------------------------
	For nTipOco := 1 To Len( aTipOco )
		cQuery += "SELECT "
		cQuery += "'" + BAPrefixBK("<<KEY_###_>>") + aTipOco[nTipOco][1] + "' AS BK_TIPOCO, "
		cQuery += "'" + aTipOco[nTipOco][1] + "' AS CODIGO_TIPOCO, 		"
		cQuery += "'" + NoAcento(aTipOco[nTipOco][2]) + "' AS DESCRICAO_TIPOCO, "
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

		If (nTipOco < Len( aTipOco ) )
			cQuery += "UNION "
		EndIf
	Next nTipOco

Return cQuery