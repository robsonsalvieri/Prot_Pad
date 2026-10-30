#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TAFRGSP.CH"

#DEFINE MASKVLR "@E 9,999,999,999,999.99"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFRGSP
Relatório em TReport para previa análise das informações que serão transmitidas a GIA-SP

@author Wesley Pinheiro
@since 18/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFRGSP( )

	Local oReport

	If FindFunction( "TRepInUse" ) .and. TRepInUse( )
		oReport := ReportDef( )
		oReport:PrintDialog( )
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Instancia a classe TReport() e monta a estrutura a ser utilizada para o relatório

@author Wesley Pinheiro
@since 18/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReportDef( )

	Local oReport
	Local oTpCfop
	Local oFilial
	Local oCR10
	Local oCR14
	Local oBreak
	Local cPerg   :=  "TAFRGSP"
	Local nTam    := TamSX3( "C20_FILIAL" )[1]

	Pergunte( cPerg, .F. ) // Carrego os MV_PAR do grupo de perguntas
	
	oReport := TReport( ):New( "TAFRGSP", STR0001, cPerg, { | oReport | PrintReport( oReport ) } ) // "GIA SP"
	oReport:SetTitle( STR0002 ) // "Conferência GIA-SP"
	oReport:SetTotalInLine( .F. )
	oReport:SetLandscape( )
	oReport:DisableOrientation( )
	oReport:SetPageFooter( 3  , { || } )
	oReport:SetColSpace( 40, .T. )

	oFilial := TRSection( ):New( oReport, STR0003,,,,,, .F. ) // "Filial"
	oFilial:SetPageBreak( .T. ) // Pula página na quebra da seção
	TRCell( ):New( oFilial, "FILIAL", "", STR0003,, nTam,,,,,,,,,,, .T. ) // "Filial"
	TRCell( ):New( oFilial, "NOME"  , "", STR0004,, 020 ,,,,,,,,,,, .T. ) // "Nome"
	TRCell( ):New( oFilial, "CNPJ"  , "", STR0005,, 014 ,,,,,,,,,,, .T. ) // "CNPJ"
	TRCell( ):New( oFilial, "IE"    , "", STR0006,, 012 ,,,,,,,,,,, .T. ) // "Insc.Estadual"

	oTpCfop := TRSection( ):New( oFilial, STR0007,,,,,, .F. ) // "CFOP's"

	oCR10 := TRSection( ):New( oTpCfop, STR0009 ) // "Resumo CFOP's"
	TRCell( ):New( oCR10, "FILIAL"      , "", STR0003,        , nTam,,,,, "LEFT"  ) // "Filial"
	TRCell( ):New( oCR10, "TIPO"        , "", STR0008,        , 004 ,,,,, "RIGHT" ) // "Tipo"
	TRCell( ):New( oCR10, "CFOP"        , "", STR0010,        , 004 ,,,,, "RIGHT" ) // "CFOP"
	TRCell( ):New( oCR10, "REG"         , "", STR0011,        , 004 ,,,,, "RIGHT" ) // "Registro"
	TRCell( ):New( oCR10, "VLOPE"       , "", STR0012, MASKVLR, 016 ,,,,, "RIGHT" ) // "Vlr Contábil"
	TRCell( ):New( oCR10, "BASE"        , "", STR0013, MASKVLR, 016 ,,,,, "RIGHT" ) // "Base Cálculo"
	TRCell( ):New( oCR10, "IMPOSTO"     , "", STR0014, MASKVLR, 016 ,,,,, "RIGHT" ) // "Imposto Credit"
	TRCell( ):New( oCR10, "ISENTO"      , "", STR0015, MASKVLR, 016 ,,,,, "RIGHT" ) // "Isent./N.Trib"
	TRCell( ):New( oCR10, "OUTRAS"      , "", STR0016, MASKVLR, 016 ,,,,, "RIGHT" ) // "Outras"
	TRCell( ):New( oCR10, "IMPOSTO_RET" , "", STR0017, MASKVLR, 016 ,,,,, "RIGHT" ) // "Imposto Retido"
	TRCell( ):New( oCR10, "SBTUTO"      , "", STR0018, MASKVLR, 016 ,,,,, "RIGHT" ) // "Substituto"
	TRCell( ):New( oCR10, "SBTUIDO"     , "", STR0019, MASKVLR, 016 ,,,,, "RIGHT" ) // "Substituído"
	TRCell( ):New( oCR10, "OUTROIMP"    , "", STR0020, MASKVLR, 016 ,,,,, "RIGHT" ) // "Outr.Impostos"

	oBreakFil := TRBreak( ):New( oFilial, { || oFilial:Cell( "FILIAL" ) } ) // Quebra por Filial
	oBreakFil:OnPrintTotal( { || oReport:ThinLine( ) } )

	TRFunction( ):New( oCR10:Cell( "VLOPE"       ) ,, "SUM", oBreakFil,,,, .F.,,, oFilial )
	TRFunction( ):New( oCR10:Cell( "BASE"        ) ,, "SUM", oBreakFil,,,, .F.,,, oFilial )
	TRFunction( ):New( oCR10:Cell( "IMPOSTO"     ) ,, "SUM", oBreakFil,,,, .F.,,, oFilial )
	TRFunction( ):New( oCR10:Cell( "ISENTO"      ) ,, "SUM", oBreakFil,,,, .F.,,, oFilial )
	TRFunction( ):New( oCR10:Cell( "OUTRAS"      ) ,, "SUM", oBreakFil,,,, .F.,,, oFilial )
	TRFunction( ):New( oCR10:Cell( "IMPOSTO_RET" ) ,, "SUM", oBreakFil,,,, .F.,,, oFilial )
	TRFunction( ):New( oCR10:Cell( "SBTUTO"      ) ,, "SUM", oBreakFil,,,, .F.,,, oFilial )
	TRFunction( ):New( oCR10:Cell( "SBTUIDO"     ) ,, "SUM", oBreakFil,,,, .F.,,, oFilial )
	TRFunction( ):New( oCR10:Cell( "OUTROIMP"    ) ,, "SUM", oBreakFil,,,, .F.,,, oFilial )

	oBreak := TRBreak( ):New( oTpCfop, { || oTpCfop:Cell( "TIPO" ) } ) // Quebra por Tipo de CFOP - Entrada/Saída
	oBreak:OnPrintTotal( {|| oReport:ThinLine( ) } )

	TRFunction( ):New( oCR10:Cell( "VLOPE"       ) ,, "SUM", oBreak,,,, .F., .F.,, oTpCfop )
	TRFunction( ):New( oCR10:Cell( "BASE"        ) ,, "SUM", oBreak,,,, .F., .F.,, oTpCfop )
	TRFunction( ):New( oCR10:Cell( "IMPOSTO"     ) ,, "SUM", oBreak,,,, .F., .F.,, oTpCfop )
	TRFunction( ):New( oCR10:Cell( "ISENTO"      ) ,, "SUM", oBreak,,,, .F., .F.,, oTpCfop )
	TRFunction( ):New( oCR10:Cell( "OUTRAS"      ) ,, "SUM", oBreak,,,, .F., .F.,, oTpCfop )
	TRFunction( ):New( oCR10:Cell( "IMPOSTO_RET" ) ,, "SUM", oBreak,,,, .F., .F.,, oTpCfop )
	TRFunction( ):New( oCR10:Cell( "SBTUTO"      ) ,, "SUM", oBreak,,,, .F., .F.,, oTpCfop )
	TRFunction( ):New( oCR10:Cell( "SBTUIDO"     ) ,, "SUM", oBreak,,,, .F., .F.,, oTpCfop )
	TRFunction( ):New( oCR10:Cell( "OUTROIMP"    ) ,, "SUM", oBreak,,,, .F., .F.,, oTpCfop )

	oCR14 := TRSection( ):New( oCR10, STR0021 ) // "UF x CFOP"
	oCR14:SetBorder( "BOTTOM", 0,, .T. ) // Retiro as bordas do cabeçalho

	TRCell( ):New( oCR14, "FILIAL"    , "", ""     ,        , nTam,,,        ,, "LEFT"  )
	TRCell( ):New( oCR14, "UF"        , "", STR0022, "@!"   , 004 ,,, "RIGHT",, "RIGHT" ) // UF
	TRCell( ):New( oCR14, "CFOP"      , "", STR0010,        , 004 ,,,        ,, "RIGHT" ) // CFOP
	TRCell( ):New( oCR14, "REG"       , "", STR0011,        , 004 ,,,        ,, "RIGHT" ) // "Registro"
	TRCell( ):New( oCR14, "VLOP"      , "", STR0012, MASKVLR, 016 ,,,        ,, "RIGHT" ) // "Vlr Contábil"
	TRCell( ):New( oCR14, "BASE"      , "", STR0013, MASKVLR, 016 ,,,        ,, "RIGHT" ) // "Base Cálculo"
	TRCell( ):New( oCR14, "IMPOSTO"   , "", STR0014, MASKVLR, 016 ,,,        ,, "RIGHT" ) // "Imposto Credit"
	TRCell( ):New( oCR14, "B"         , "", ""     ,        , 016 ,,,        ,, "RIGHT" )
	TRCell( ):New( oCR14, "OUTRAS"    , "", STR0016, MASKVLR, 016 ,,,        ,, "RIGHT" ) // "Outras"
	TRCell( ):New( oCR14, "PETRENERG" , "", STR0023, MASKVLR, 016 ,,,        ,, "RIGHT" ) // "Petroleo/Energia"
	TRCell( ):New( oCR14, "OUTROPROD" , "", STR0024, MASKVLR, 016 ,,,        ,, "RIGHT" ) // "Outros Produtos"

Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Instancia a classe TReport() e monta a estrutura a ser utilizada para o relatório

@author Wesley Pinheiro
@since 18/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function PrintReport( oReport )

	Local cFilSel   := ""
    Local cInscEst  := ""
    Local cCnpj     := ""
	Local cIn       := ""
	Local cNomeFil  := ""
	Local cMesRef   := ""
	Local cAnoRef   := ""

	Local nI        := 0
	Local lAglutina := .F.

	Local aSm0      := { }
	Local oFilial   := oReport:Section( 1 )

	cMesRef := StrZero( MV_PAR01, 2 )
	cAnoRef := StrZero( MV_PAR02, 4 )

	If MV_PAR03 == 2 // Seleciona Filiais?
		ImpFiliais( @aSM0 )

		If MV_PAR04 == 2 .and. ( Len( aSM0) > 1 ) // Aglutina CNPJ+IE?
			lAglutina := .T.
		EndIf
	Else
		AADD( aSM0, { SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_INSC, SM0->M0_CGC } )	
	EndIf

	if lAglutina .And. TafDivAglt(aSM0)
		oReport:CancelPrint( )
		MsgAlert( STR0027 + CRLF ; //"Não será possível gerar o relatório com a combinação: "
		+ (STR0028 + STR0029) ) //#"Seleciona filial igual a sim, aglutina igual a CNPJ + IE e alguma "#"filial selecionada divergente das demais em relação ao CNPJ ou IE. "
	else
		If Len( aSm0 ) > 0
			For nI := 1 to Len( aSm0 )
				/* 
					Função AglutVlr diminui o tamanho do array aSm0 devido a possibilidade de aglutinação de SM0's com o mesmo CNPJ e IE,
					por isso verifico o tamanho, evitando array of bounds
				*/
				If nI <= Len( aSm0 )
					cFilSel  := aSm0[nI][2]
					cInscEst := aSm0[nI][3]
					cCnpj    := aSm0[nI][4]
					cNomeFil := AllTrim( FWSM0Util( ):GetSM0Data( , cFilSel , { "M0_FILIAL" } )[1][2] ) // Não incluir no Array aSm0 para não comprometer a manutenção da função AglutVlr

					If lAglutina
						If FindFunction("AglutVlr")
							AglutVlr( @aSM0, @cIn, cCNPJ, cInscEst )
						endif
					EndIf

					oFilial:aBreak[1]:SetTitle( STR0025 + cFilSel ) // "Total Filial "
					oFilial:Init( )
					oFilial:Cell( "FILIAL" ):SetValue( cFilSel  )
					oFilial:Cell( "NOME"   ):SetValue( cNomeFil )
					oFilial:Cell( "CNPJ"   ):SetValue( cCnpj    )
					oFilial:Cell( "IE"     ):SetValue( cInscEst )
					oFilial:PrintLine( )

					TAFGS10( , cFilSel,, cInscEst,,, cMesRef, cAnoRef,, cIn, oReport )

					oFilial:Finish( )
				EndIf
			next nI
		Else
			oReport:CancelPrint( )
			MsgAlert( STR0026 ) // "Impressão cancelada"
		EndIf
	endif

	oReport := Nil
	FreeObj( oReport )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ImpFiliais
Interface de seleção das filiais a serem processadas para a geração do relatório

@param aSM0 -> Array a ser contruído com as filiais selecionadas para processamento

@author Wesley Pinheiro
@since 18/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ImpFiliais( aSM0 )
	Local lGiaSP   := .T. //adiciona na tela de selecao as colunas CNPJ e IE
	Local aFiliais := xFunTelaFil( .T.,,,lGiaSP)
	Local nI       := 0
	Local nTamAFil := 0

	If !Empty( aFiliais )

		nTamAFil := Len( aFiliais )

		If nTamAFil > 0

			For nI := 1 to nTamAFil
				
				If aFiliais[nI][1] // Filial Selecionada

					aInfoFilial := FWSM0Util():GetSM0Data(  , aFiliais[nI][2] , { "M0_CODIGO", "M0_CODFIL", "M0_INSC", "M0_CGC" } )

					AADD( aSM0, { AllTrim( aInfoFilial[1][2] ),; // Grupo de Empresa
								  AllTrim( aInfoFilial[2][2] ),; // Código da Filial
								  AllTrim( aInfoFilial[3][2] ),; // Inscrição Estadual 
								  AllTrim( aInfoFilial[4][2] );  // CNPJ
								   } )				
				Endif
			Next nI
		EndIf
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TafDivAglt
Validação de filiais divergentes para geração do relatório com
aglutinação CNPJ + IE

@param aSM0 -> Array com as filiais selecionadas para processamento

@author Denis Souza
@since 13/05/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TafDivAglt( aSM0 )

	Local lFilDiv := .F. //Filial Divergente
	Local nI      := 0
	Local nAte 	  := 0
	Local aAux    := {}
	Default aSM0  := {}

	nAte := Len( aSM0 )
	if nAte > 0
		if len(aSM0[1]) >= 4
			aadd( aAux, (aSM0[1][3] + aSM0[1][4]) ) //IE+CNPJ
		endif
		For nI := 1 to nAte
			if nI > 1
				if aScan(aAux, { |x| x == (aSM0[nI][3] + aSM0[nI][4]) } ) == 0
					lFilDiv := .T.
					Exit
				endif
			endif
		Next nI
	endif

Return lFilDiv
