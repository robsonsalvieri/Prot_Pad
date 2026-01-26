#INCLUDE "BADEFINITION.CH"

NEW ENTITY FILIAL

//-------------------------------------------------------------------
/*/{Protheus.doc} BAFilial
Visualiza as informacoes de Filial.

@author  Andreia Lima
@since   03/11/2017
/*/
//-------------------------------------------------------------------
Class BAFilial from BAEntity
	Method Setup() CONSTRUCTOR
	Method BuildQuery( )
	Method GetCompFilial()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padrao.

@author  Andreia Lima
@since   03/11/2017
/*/
//-------------------------------------------------------------------
Method Setup() Class BAFilial
	_Super:Setup("Filial", DIMENSION, "SM0", .F.)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Andreia Lima
@since   03/11/2017
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAFilial
	Local cQuery      := ""
	Local cFrom       := ""
	Local cPrefix     := BAPrefixBK("<<KEY_SM0_>>")
	Local aFilial     := ::GetCompFilial()
	Local aGrpEmpUnit := {}
	Local nFilial     := 0
	Local nGrpEmpUnit := 0
	Local nLenFilial  := 0
	
	Local cDatabase := Upper( TCGetDB() )	
	
	//-----------------------------------------------------------
	// Tratamento por banco para usar o FROM em uma tabela dummy.
	//-----------------------------------------------------------
	Do Case    
		Case ( "ORACLE" $ cDatabase )
			cFrom := " FROM DUAL "
		Case ( "DB2" $ cDatabase )
			cFrom := " FROM SYSIBM.SYSDUMMY1 "
	EndCase
	
	If Len( aFilial ) > 0
		nLenFilial := FWSizeFilial() + Len( aFilial[1][1] )
	EndIf	
	
	//------------------------------------------------
	// Monta select para as filiais
	//------------------------------------------------
	For nFilial := 1 To Len( aFilial )
	
	    If ( aScan( aGrpEmpUnit, { |grupo| grupo[1] == Padr( aFilial[nFilial][1], nLenFilial ) } ) == 0)
			AAdd( aGrpEmpUnit, { Padr( aFilial[nFilial][1], nLenFilial ), AllTrim( aFilial[nFilial][21] ) } ) //Grupo de empresa, descricao do grupo
		EndIf	
		
		If ( aScan( aGrpEmpUnit, { |empresa| empresa[1] ==  Padr( aFilial[nFilial][1] + aFilial[nFilial][3], nLenFilial ) } ) == 0)
			AAdd( aGrpEmpUnit, { Padr( aFilial[nFilial][1] + aFilial[nFilial][3], nLenFilial ), AllTrim( aFilial[nFilial][19] ) } ) //Grupo de empresa + empresa, descricao da empresa
		EndIf	
		
		If ( Empty( aFilial[nFilial][13] ) ) //Verifica se nao ha empresa
			If ( aScan( aGrpEmpUnit, { |unidade| unidade[1] == Padr( aFilial[nFilial][1] + aFilial[nFilial][4], nLenFilial ) } ) == 0)
				AAdd( aGrpEmpUnit, { Padr( aFilial[nFilial][1] + aFilial[nFilial][4], nLenFilial ), AllTrim( aFilial[nFilial][20] ) } ) //Grupo de empresa + unidade, descricao da unidade
			EndIf
		Else
			If ( aScan( aGrpEmpUnit, { |unidade| unidade[1] == Padr( aFilial[nFilial][1] + aFilial[nFilial][3] + aFilial[nFilial][4], nLenFilial ) } ) == 0)
				AAdd( aGrpEmpUnit, { Padr( aFilial[nFilial][1] + aFilial[nFilial][3] + aFilial[nFilial][4], nLenFilial ), AllTrim( aFilial[nFilial][20] ) } ) // Grupo de empresa + empresa + unidade, descricao da unidade
			EndIf	
		EndIf

		cQuery += "SELECT "
		cQuery += "'" + cPrefix + aFilial[nFilial][1] + aFilial[nFilial][2] + "' AS BK_FILIAL,"
		cQuery += "'" + aFilial[nFilial][2] + "' AS COD_FILIAL,"
		cQuery += "'" + AllTrim( aFilial[nFilial][7] ) + "' AS DESC_FILIAL,"
		cQuery += "'" + aFilial[nFilial][4] + "' AS COD_UNINEG,"
		cQuery += "'" + AllTrim( aFilial[nFilial][20] ) + "' AS DESC_UNINEG, "
		cQuery += "<<CODE_INSTANCE>> AS INSTANCIA "
		cQuery += cFrom
		cQuery += "UNION "
		
	Next nFilial
	
	//--------------------------------------------------
	// Monta select para os grupos, empresas e unidades
	//--------------------------------------------------
	For nGrpEmpUnit := 1 To Len( aGrpEmpUnit )
		cQuery += "SELECT "
		cQuery += "'" + cPrefix + aGrpEmpUnit[nGrpEmpUnit][1] + "' AS BK_FILIAL,"
		cQuery += "'" + aGrpEmpUnit[nGrpEmpUnit][1] + "' AS COD_FILIAL,"
		cQuery += "'" + aGrpEmpUnit[nGrpEmpUnit][2] + " - COMPARTILHADA' AS DESC_FILIAL,"
		cQuery += "'' AS COD_UNINEG,"
		cQuery += "'' AS DESC_UNINEG, "
		cQuery += "<<CODE_INSTANCE>> AS INSTANCIA "
		cQuery += cFrom
		
		If ( nGrpEmpUnit < Len( aGrpEmpUnit ) )
			cQuery += "UNION "
		EndIf 
	Next 
	 	
Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCompFilial
Retorna somente as filiais das empresas selecionadas para instalacao.
@return array, filiais.

@author  Andreia Lima
@since   25/06/2019
/*/
//-------------------------------------------------------------------
Method GetCompFilial() Class BAFilial
	Local aCompFilial := {}
	Local aAllFilial  := FWLoadSM0()
	Local aCompany    := BICompanySelected( )
	Local nCompany    := 0
	Local nFilial     := 0
	
	For nCompany := 1 To Len( aCompany )
		For nFilial := 1 To Len( aAllFilial )
			If ( aCompany[nCompany] == aAllFilial[nFilial][1] ) 
				AADD( aCompFilial, aAllFilial[nFilial] )
			EndIf	
		Next nFilial
	Next nCompany
	
Return aCompFilial
