#INCLUDE "BADEFINITION.CH"

NEW ENTITY 43RESOC

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSResponsavelOcorrencia
Visualiza as informaÁıes por Tabela de Ocorrencia

@author  Leandro Paulino
@since   02/05/2019	
/*/
//-------------------------------------------------------------------
Class TMSResponsavelOcorrencia from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padr√£o.

@author  Leandro Paulino
@since   07/12/2018
/*/
//-------------------------------------------------------------------
Method Setup( ) Class TMSResponsavelOcorrencia
	_Super:Setup("TMS Respons·vel Ocorrencia", DIMENSION, "###", .F.)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constr√≥i a query da entidade.
@return cQuery, string, query a ser processada.

@author  Leandro Paulino
@since   07/12/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class TMSResponsavelOcorrencia
	Local cQuery    := ""
	Local aRespon  := {}
	Local nRespon  := 0
	Local cDatabase := Upper( SGDB() )

 	aRespon := RetSx3Box( Posicione('SX3', 2, 'DT2_RESOCO', 'X3CBox()' ),,, Len(DT2->DT2_RESOCO))
    
	//------------------------------------------------
	// Gera√ß√£o de um select virtual.
	//------------------------------------------------
	For nRespon := 1 To Len( aRespon )
		cQuery += "SELECT "
		cQuery += "'" + BAPrefixBK("<<KEY_###_>>") + aRespon[nRespon][2] + "' AS BK_Respon, "
		cQuery += "'" + aRespon[nRespon][2] + "' AS CODIGO_Respon, 		"
		cQuery += "'" + NoAcento(aRespon[nRespon][3]) + "' AS DESCRICAO_Respon, "
		cQuery += " <<CODE_INSTANCE>>						AS INSTANCIA "

		//------------------------------------------------------
		// Tratamento por banco para pegar uma tabela dummy.
		//------------------------------------------------------
		Do Case    
			Case ( "ORACLE" $ cDatabase )
				cQuery += " FROM DUAL "
			Case ( "DB2" $ cDatabase )
				cQuery += " FROM SYSIBM.SYSDUMMY1 "
		EndCase

		If (nRespon < Len( aRespon ) )
			cQuery += "UNION "
		EndIf
	Next nRespon

Return cQuery