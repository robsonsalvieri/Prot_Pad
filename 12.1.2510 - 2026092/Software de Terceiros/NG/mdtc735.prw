#INCLUDE "mdtc735.ch"
#Include "Protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MDTC735  ³ Autor ³ Ricardo Dal Ponte     ³ Data ³25/05/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Estatistica de Acidentes por periodo                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMDT                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ F.O  ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MDTC735()
Local cCbox := STR0001 //"Por Parte Atingida"
Local oDlg,oScr,oCbox
Local nOpcz := 0

SetKey( VK_F9, { | | NGVersao( "MDTC735" , 02 ) } )

Private odtv1, dDtval1 := dDatabase - 30
Private odtv2, dDtval2 := dDatabase
Private cCadastro := OemToAnsi(STR0009) //"Estatistica de Acidentes por periodo"
Private lCORRET   := .F., INCLUI := .F., lRETOR := .F.

Private nLenCodigo, cTbGrafico ,cModGrafico, cTituloG
Private vSERPR:={}
Private cPerg := "MDTC735   "
Private aOpcCbox := {STR0001, STR0002, STR0003, ; //"Por Parte Atingida"###"Por Natureza da Lesão"###"Por Agente Causador"
                   STR0004, STR0005, STR0006, ; //"Por Fonte Geradora de Acidente"###"Por CID-10"###"Por Centro de Custo e Função"
                   STR0007, STR0021, STR0023, STR0008,; //"Com e Sem Afastamento"###"Taxa de Frequencia"###"Taxa de Gravidade"####"Estatística Anual"
                   STR0034, STR0035 }//"Por Centro de Custo"###"Por Função"

Pergunte( AllTrim(cPerg) ,.F.)

If !Empty( MV_PAR01 )
	dDtVal1 := MV_PAR01
EndIf
If !Empty( MV_PAR02 )
	dDtVal2 := MV_PAR02
EndIf
If !Empty( MV_PAR03 ) .And. !IsAlpha( MV_PAR03 )
	cCbox := aOpcCbox[Val(MV_PAR03)]
EndIf

DEFINE MSDIALOG oDlg TITLE STR0010 From 6,0 To 15,38 OF oMainWnd //"Parâmetros"

@ 00,00 SCROLLBOX oScr VERTICAL SIZE 70,160 OF oDlg BORDER
@ 10,5  SAY STR0011 Of oScr Pixel //"De Data Acidente ?"
@ 10,55 MsGet oDtv1 VAR dDtVal1 Size 60,08 Picture "99/99/9999" Of oScr Pixel When .t. Valid !Empty(dDtVal1) HasButton
@ 22,5  SAY STR0012 Of oScr Pixel //"Ate Data Acidente ?"
@ 22,55 MsGet oDtv2 VAR dDtVal2 Size 60,08 Picture "99/99/9999" Of oScr Pixel When .t.Valid !Empty(dDtVal2) .And. (dDtVal2 >= dDtVal1) HasButton
@ 34,5  SAY STR0013 Of oScr Pixel //"Tipo de Consulta ?"
@ 34,55 Combobox oCbox VAR cCbox ITEMS aOpcCbox SIZE 90,10 Pixel OF oScr

DEFINE SBUTTON FROM 50, 55 TYPE 1 ENABLE OF oScr ACTION EVAL({||MDTC735GRA(cCbox),oDlg:End()})
DEFINE SBUTTON FROM 50, 85 TYPE 2 ENABLE OF oScr ACTION oDlg:End()

ACTIVATE MSDIALOG oDlg CENTERED

Return .t.
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³MDTC735GRA ³ Autor³                       ³ Data  ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±/*/
Function MDTC735GRA(cCbox)

/*
"Por Parte Atingida"
"Por Natureza da Lesão"
"Por Agente Causador"
"Por Fonte Geradora de Acidente"
"Por CID-10"
"Por Centro de Custo e Função"
"Com e Sem Afastamento"
"Taxa de Frequencia"
"Taxa de Gravidade"
"Estatística Anual"
"Por Centro de Custo"
"Por Função"
*/

Local nQtvit := 0
Local nMes := 0
Local nQtDiasPerd := 0
Local nHrTrab := 0
Local nHrDia := 0
Local nQtDiHoPerd := 0
Local nQTIndGra := 0
Local nQTFreq := 0
Local nANO := 0
Local cANOMES := ""
Local nSizeSI3 := If((TAMSX3("I3_CUSTO")[1]) < 1,9,(TAMSX3("I3_CUSTO")[1]))
Local nSizeSRJ := If((TAMSX3("RJ_FUNCAO")[1]) < 1,5,(TAMSX3("RJ_FUNCAO")[1]))
Local cAliasTNC := GetNextAlias()

Private cTRB  := GetNextAlias()
Private cTRB2 := GetNextAlias()
Private oTempTRB, oTempTRB2

If cCbox	== STR0001 //"Por Parte Atingida"
	cTituloG := STR0014  //"Acidentes - Ocorrências por Partes do Corpo Atingidas"
	Aadd(vSERPR,"QUANTI")
	nLenCodigo := 12
	cTbGrafico := cTRB
	cModGrafico := "4"
EndIf

If cCbox	== STR0002 //"Por Natureza da Lesão"
	cTituloG := STR0015  //"Acidentes - Ocorrências por Natureza de Lesões"
	nLenCodigo := 12
	Aadd(vSERPR,"QUANTI")
	cTbGrafico := cTRB
	cModGrafico := "4"
EndIf

If cCbox	== STR0003 //"Por Agente Causador"
	cTituloG := STR0016  //"Acidentes - Ocorrências por Agentes Causadores"
	nLenCodigo := 12
	Aadd(vSERPR,"QUANTI")
	cTbGrafico := cTRB
	cModGrafico := "4"
EndIf

If cCbox	== STR0004 //"Por Fonte Geradora de Acidente"
	cTituloG := STR0017  //"Acidentes - Ocorrências por Tipo de Fontes Geradoras de Acidentes/Doenças"
	nLenCodigo := 12
	Aadd(vSERPR,"QUANTI")
	cTbGrafico := cTRB
	cModGrafico := "4"
EndIf

If cCbox	== STR0005 //"Por CID-10"
	cTituloG := STR0018  //"Acidentes - Ocorrências por CID-10 registradas no período"
	nLenCodigo := 8
	Aadd(vSERPR,"QUANTI")
	cTbGrafico := cTRB
	cModGrafico := "4"
EndIf

If cCbox	== STR0006 //"Por Centro de Custo e Função"
	cTituloG := STR0019  //"Acidentes - Ocorrências por Centro de Custo e Função no período"
	If SuperGetMv("MV_MCONTAB",.F.,"N") == "CTB"
		nSizeSI3 := If((TAMSX3("CTT_CUSTO")[1]) < 1,9,(TAMSX3("CTT_CUSTO")[1]))
	Endif
	nLenCodigo := nSizeSI3 + nSizeSRJ
	Aadd(vSERPR,"QUANTI")
	cTbGrafico := cTRB
	cModGrafico := "4"
EndIf

If cCbox	== STR0007 //"Com e Sem Afastamento"
	cTituloG := STR0020  //"Acidentes - Ocorrências Com e Sem Afastamento no período"
	nLenCodigo := 1
	Aadd(vSERPR,"QUANTI")
	cTbGrafico := cTRB
	cModGrafico := "4"
EndIf

If cCbox	== STR0021 //"Taxa de Frequencia"
	cTituloG := STR0022  //"Acidentes - Taxa de Frequência"
	nLenCodigo := 6
	Aadd(vSERPR,"QUANTI")
	cTbGrafico := cTRB
	cModGrafico := "4"
EndIf

If cCbox	== STR0023 //"Taxa de Gravidade"
	cTituloG := STR0024  //"Acidentes - Taxa de Gravidade"
	nLenCodigo := 6
	Aadd(vSERPR,"QUANTI")
	cTbGrafico := cTRB
	cModGrafico := "4"
EndIf

If cCbox	== STR0008 //"Estatística Anual"
	cTituloG := STR0025  //"Acidentes - Estatística Anual"

	Aadd(vSERPR,STR0026) //"Com Afastamento"
	Aadd(vSERPR,STR0027) //"Sem Afastamento"

	nLenCodigo := 6
	cTbGrafico := cTRB2
	cModGrafico := "0"
EndIf

If cCbox	== STR0034 //"Por Centro de Custo"
	cTituloG := STR0036  //"Acidentes - Ocorrências por Centro de Custo no período"
	If SuperGetMv("MV_MCONTAB",.F.,"N") == "CTB"
		nSizeSI3 := If((TAMSX3("CTT_CUSTO")[1]) < 1,9,(TAMSX3("CTT_CUSTO")[1]))
	Endif
	nLenCodigo := nSizeSI3
	Aadd(vSERPR,"QUANTI")
	cTbGrafico := cTRB
	cModGrafico := "4"
EndIf
If cCbox	== STR0035 //"Por Função"
	cTituloG := STR0037 //"Acidentes - Ocorrências por Função no período"
	nLenCodigo := nSizeSRJ
	Aadd(vSERPR,"QUANTI")
	cTbGrafico := cTRB
	cModGrafico := "4"
EndIf

aDBF := {{"CODIGO", "C", nLenCodigo,0},;
         {"DESCRI", "C", 100,0},;
         {"QUANTI", "N", 10,2}}

oTempTRB := FWTemporaryTable():New( cTRB, aDBF )
oTempTRB:AddIndex( "1", {"CODIGO"}  )
oTempTRB:Create()

aDBF := {{"CODIGO", "C", nLenCodigo,0},;
         {"DESCRI", "C", 100,0},;
         {"QUANT1", "N", 10,2},;
         {"QUANT2", "N", 10,2}}

oTempTRB2 := FWTemporaryTable():New( cTRB2, aDBF )
oTempTRB2:AddIndex( "1", {"CODIGO"}  )
oTempTRB2:Create()

If cCbox	== STR0008   //"Estatística Anual"
		C735GDATAS()
EndIf

If cCbox	== STR0021  .Or. ; //"Taxa de Frequencia"
   cCbox	== STR0023         //"Taxa de Gravidade"
		C735DTTRB()
		Private nQtFunc   := 0   //Quantidade Total de Funcionarios (no periodo informado)
		Private nQtHrsFun := 0   //Quantidade Total de Horas Trabalhadas (no periodo informado)
		Private nJornada  := 0	 //Quantidade de horas da jornada de trabalho
		If !QTEFUNC(cCbox)  //Calcula estas variaveis acima
			oTempTRB:Delete()
			oTempTRB2:Delete()
			Return .F.  //Cancelado
		Endif
Endif

//------------------------------------------------
//Filtra os acidentes
//------------------------------------------------
BeginSql Alias cAliasTNC
	SELECT  TNC.*  
	FROM    %table:TNC%  TNC
	WHERE   TNC.TNC_FILIAL = %xFilial:TMJ%
		AND TNC.TNC_DTACID >= %Exp:( DtoS( dDtVal1 ) )%
		AND TNC.TNC_DTACID <= %Exp:( DtoS( dDtVal2 ) )%
		AND TNC.%NotDel%
EndSql

While ( cAliasTNC )->( !Eof() )
	IncProc()

	DbselectArea( cTRB )
	DbSetOrder(1)

	// ------------------------------------------------------------------------------
	// Geracao "Por Parte Atingida"
	// ------------------------------------------------------------------------------
	If cCbox == STR0001 //"Por Parte Atingida"
		
		DbselectArea( "TYF" )
		DbSetOrder( 1 )		
		If MsSeek( FwxFilial( 'TYF' ) + ( cAliasTNC )->( TNC_ACIDEN ) )
			
			While ( 'TYF' )->( !Eof() ) .And. ( cAliasTNC )->( TNC_ACIDEN ) == TYF->TYF_ACIDEN
				
				DbselectArea( cTRB )
				DbSetOrder(1)
				If !MsSeek( TYF->TYF_CODPAR )
					
					( cTRB )->( DbAppend() )
					( cTRB )->CODIGO := TYF->TYF_CODPAR
					( cTRB )->DESCRI := ""
					( cTRB )->QUANTI := 1

					DbselectArea( "TOI" )
					DbSetOrder( 1 )
					If MsSeek( xFilial( "TOI" ) + ( cTRB )->CODIGO )
						( cTRB )->DESCRI := AllTrim( TOI->TOI_DESPAR )
					EndIf

				Else

					( cTRB )->QUANTI := ( cTRB )->QUANTI + 1
					
				EndIf

				( 'TYF' )->( DbSkip() )

			End

		EndIf

	EndIf

	// ------------------------------------------------------------------------------
	// Geracao "Por Natureza da Lesão"
	// ------------------------------------------------------------------------------
	If cCbox == STR0002 .And. !Empty( ( cAliasTNC )->( TNC_CODLES ) ) //"Por Natureza da Lesão"
		
		If !MsSeek( ( cAliasTNC )->( TNC_CODLES ) )
			
			( cTRB )->( DbAppend() )
			( cTRB )->CODIGO := ( cAliasTNC )->( TNC_CODLES )
			( cTRB )->DESCRI := ""
			( cTRB )->QUANTI := 1

			DbselectArea( "TOJ" )
			DbSetOrder( 1 )
			If MsSeek( xFilial( "TOJ" ) + ( cTRB )->CODIGO )
				( cTRB )->DESCRI := AllTrim( TOJ->TOJ_NOMLES )
			EndIf

		Else

			( cTRB )->QUANTI := ( cTRB )->QUANTI + 1

		EndIf

	EndIf


	// ------------------------------------------------------------------------------
	// Geracao "Por Agente Causador"
	// ------------------------------------------------------------------------------
	If cCbox == STR0003 //"Por Agente Causador"
		
		DbselectArea( "TYE" )
		DbSetOrder( 1 )
		If MsSeek( FwxFilial( 'TYE' ) + ( cAliasTNC )->( TNC_ACIDEN ) )
			
			While ( 'TYE' )->( !Eof() ) .And. ( cAliasTNC )->( TNC_ACIDEN ) == TYE->TYE_ACIDEN

				DbselectArea( cTRB )
				DbSetOrder(1)
				If !MsSeek( TYE->TYE_CAUSA )

					( cTRB )->( DbAppend() )
					( cTRB )->CODIGO := TYE->TYE_CAUSA
					( cTRB )->DESCRI := ""
					( cTRB )->QUANTI := 1

					DbselectArea( "TNH" )
					DbSetOrder( 1 )
					If MsSeek( xFilial( "TNH" ) + ( cTRB )->CODIGO )
						( cTRB )->DESCRI := AllTrim( TNH->TNH_DESOBJ )
					EndIf

				Else

					( cTRB )->QUANTI := ( cTRB )->QUANTI + 1

				EndIf

				( 'TYE' )->( DbSkip() )

			End

		EndIf

	EndIf

	// ------------------------------------------------------------------------------
	// Geracao "Por Fonte Geradora de Acidente"
	// ------------------------------------------------------------------------------
	If cCbox == STR0004 .And. !Empty( ( cAliasTNC )->( TNC_TIPACI ) ) //"Por Fonte Geradora de Acidente"
		If !MsSeek( ( cAliasTNC )->( TNC_TIPACI) )
			
			( cTRB )->( DbAppend() )
			( cTRB )->CODIGO := ( cAliasTNC )->( TNC_TIPACI )
			( cTRB )->DESCRI := ""
			( cTRB )->QUANTI := 1

			DbselectArea( "TNG" )
			DbSetOrder( 1 )
			If MsSeek( xFilial( "TNG" ) + ( cTRB )->CODIGO )
				( cTRB )->DESCRI := AllTrim( TNG->TNG_DESTIP )
			EndIf

		Else

			( cTRB )->QUANTI := ( cTRB )->QUANTI + 1

		EndIf

	EndIf

	// ------------------------------------------------------------------------------
	// Geracao "Por CID-10"
	// ------------------------------------------------------------------------------
	If cCbox == STR0005 .And. !Empty( ( cAliasTNC )->( TNC_CID ) ) //"Por CID-10"
		
		If !MsSeek( ( cAliasTNC )->( TNC_CID ) )
			
			( cTRB )->( DbAppend() )
			( cTRB )->CODIGO := ( cAliasTNC )->( TNC_CID )
			( cTRB )->DESCRI := ""
			( cTRB )->QUANTI := 1

			DbselectArea( "TMR" )
			DbSetOrder( 1 )
			If MsSeek( xFilial( "TMR" ) + ( cTRB )->CODIGO )
				( cTRB )->DESCRI := AllTrim( Substr( TMR->TMR_DOENCA, 1, 100 ) )
			EndIf

		Else

			( cTRB )->QUANTI := ( cTRB )->QUANTI + 1

		EndIf

	EndIf

	// ------------------------------------------------------------------------------
	// Geracao "Por Centro de Custo e Função"
	// ------------------------------------------------------------------------------
	If cCbox	== STR0006 .And. !Empty( ( cAliasTNC )->( TNC_CC ) ) .And. !Empty( ( cAliasTNC )->( TNC_CODFUN ) ) //"Por Centro de Custo e Função"
		
		If !MsSeek( ( cAliasTNC )->( TNC_CC ) + ( cAliasTNC )->( TNC_CODFUN ) )
			
			( cTRB )->( DbAppend() )
			( cTRB )->CODIGO := ( cAliasTNC )->( TNC_CC ) + ( cAliasTNC )->( TNC_CODFUN )
			( cTRB )->DESCRI := ""
			( cTRB )->QUANTI := 1

			DbselectArea( "CTT" )
			DbSetOrder( 1 )
			If MsSeek( xFilial( "CTT" ) + ( cAliasTNC )->( TNC_CC ) )
				( cTRB )->DESCRI := AllTrim( CTT->CTT_DESC01 )
			EndIf

			DbselectArea( "SRJ" )
			DbSetOrder( 1 )
			If MsSeek( xFilial( "SRJ" ) + ( cAliasTNC )->( TNC_CODFUN ) )
				( cTRB )->DESCRI := AllTrim( ( cTRB )->DESCRI ) + " - " + AllTrim( SRJ->RJ_DESC )
			EndIf

		Else

			( cTRB )->QUANTI := ( cTRB )->QUANTI + 1

		EndIf

	EndIf

	// ------------------------------------------------------------------------------
	// Geracao "Com e Sem Afastamento"
	// ------------------------------------------------------------------------------
	If cCbox == STR0007 .And. !Empty( ( cAliasTNC )->( TNC_AFASTA ) ) //"Com e Sem Afastamento"
		
		If !MsSeek( ( cAliasTNC )->( TNC_AFASTA ) )
			
			( cTRB )->( DbAppend() )
			( cTRB )->CODIGO := ( cAliasTNC )->( TNC_AFASTA )
			( cTRB )->DESCRI := ""
			( cTRB )->QUANTI := 1

			IF ( cAliasTNC )->( TNC_AFASTA == "1" )
				( cTRB )->DESCRI := STR0026 //"Com Afastamento"
			Else
				( cTRB )->DESCRI := STR0027 //"Sem Afastamento"
			EndIf

		Else

			( cTRB )->QUANTI := ( cTRB )->QUANTI + 1

		EndIf

	EndIf

	// ------------------------------------------------------------------------------
	// Geracao "Taxa de Frequencia"
	// ------------------------------------------------------------------------------
	If cCbox == STR0021 .And. ( ( cAliasTNC )->( TNC_VITIMA ) == '1' .Or. ( cAliasTNC )->( TNC_VITIMA  == '3') ) //"Taxa de Frequencia"

		If ( nMes + nAno ) != ( Month( Stod( ( cAliasTNC )->( TNC_DTACID ) ) ) + Year( Stod( ( cAliasTNC )->( TNC_DTACID ) ) ) )
			
			nQtvit := 1
			nQTFreq := ( nQtvit * 1000000 ) / nQtHrsFun  //Taxa de Frequencia
			nMES    := Month( Stod( ( cAliasTNC )->( TNC_DTACID ) ) )
			nANO    := Year( Stod( ( cAliasTNC )->( TNC_DTACID ) ) )
			cANOMES := Str( nANO, 4 ) + Strzero( nMES, 2 )

			DbSelectArea( cTRB )
			If ( cTRB )->( MsSeek( cANOMES ) )
				( cTRB )->QUANTI := nQTFreq
			EndIf

		Else

			nQtvit++
			nQTFreq := ( nQtvit * 1000000 ) / nQtHrsFun  //Taxa de Frequencia

			DbSelectArea( cTRB )
			If ( cTRB )->( MsSeek( cANOMES ) )
				( cTRB )->QUANTI := nQTFreq
			EndIf

		Endif

	EndIf

	// ------------------------------------------------------------------------------
	// Geracao "Taxa de Gravidade"
	// ------------------------------------------------------------------------------
	If cCbox == STR0023 .And. ( ( cAliasTNC )->( TNC_VITIMA ) == '1' .or. ( cAliasTNC )->( TNC_VITIMA  == '3') )  //"Taxa de Gravidade"

		If (nMes + nAno) != ( Month( Stod( ( cAliasTNC )->( TNC_DTACID ) ) ) + Year( Stod( ( cAliasTNC )->( TNC_DTACID ) ) ) )
			
			nQtDiasPerd := ( cAliasTNC )->( TNC_DIASDB )
			nHrTrab := mdt865conv( ( cAliasTNC )->( TNC_HRTRAB ) )
			nHrDia := 0
			
			If !Empty( ( cAliasTNC )->( TNC_HRTRAB ) ) .and. nHrTrab > 0 .and. nHrTrab < nJornada
				nHrDia := nJornada - nHrTrab
			Endif

			nQtDiHoPerd :=( ( nQtDiasPerd * nJornada) + nHrDia ) / nJornada
			nQTIndGra := nQtDiHoPerd / nQtFunc //Taxa de gravidade
			nMES := Month( Stod( ( cAliasTNC )->( TNC_DTACID ) ) )
			nANO := Year( Stod( ( cAliasTNC )->( TNC_DTACID ) ) )
			cANOMES := Str( nANO, 4 ) + Strzero( nMES, 2 )

			DbSelectArea( cTRB )
			If ( cTRB )->( MsSeek( cANOMES ) )
				( cTRB )->QUANTI := nQTIndGra
			EndIf

		Else

			nQtDiasPerd += ( cAliasTNC )->( TNC_DIASDB )
			nHrTrab := mdt865conv( ( cAliasTNC )->( TNC_HRTRAB ) )

			If !Empty( ( cAliasTNC )->( TNC_HRTRAB ) ) .and. nHrTrab > 0 .and. nHrTrab < nJornada
				nHrDia += nJornada - nHrTrab
			Endif
			
			nQtDiHoPerd :=( ( nQtDiasPerd * nJornada ) + nHrDia ) / nJornada
			nQTIndGra := nQtDiHoPerd / nQtFunc	    //Taxa de gravidade

			DbSelectArea( cTRB )
			If ( cTRB )->( MsSeek( cANOMES ) )
				( cTRB )->QUANTI := nQTIndGra
			EndIf

		Endif

	EndIf

	// ------------------------------------------------------------------------------
	// Geracao "Estatística Anual"
	// ------------------------------------------------------------------------------
	If cCbox == STR0008 //"Estatística Anual"

		nMES := Month( Stod( ( cAliasTNC )->( TNC_DTACID ) ) )
		nANO := Year( Stod( ( cAliasTNC )->( TNC_DTACID ) ) )
		cANOMES := Str( nANO, 4 ) + Strzero( nMES, 2 )

		DbSelectArea( cTRB2 )
		If ( cTRB2 )->( MsSeek( cANOMES ) )

			IF ( cAliasTNC )->( TNC_AFASTA == "1" )
				( cTRB2 )->QUANT1 := ( cTRB2 )->QUANT1 +1
			Else
				( cTRB2 )->QUANT2 := ( cTRB2 )->QUANT2 +1
			Endif

		EndIf

	EndIf

	// ------------------------------------------------------------------------------
	// Geracao "Por Centro de Custo"
	// ------------------------------------------------------------------------------
	If cCbox == STR0034 .And. !Empty( ( cAliasTNC )->( TNC_CC ) ) //"Por Centro de Custo"
		
		If !MsSeek( ( cAliasTNC )->( TNC_CC ) )
			
			( cTRB )->( DbAppend() )
			( cTRB )->CODIGO := ( cAliasTNC )->( TNC_CC )
			( cTRB )->DESCRI := ""
			( cTRB )->QUANTI := 1

			DbselectArea( "CTT"  )
			DbSetOrder( 1 )
			If MsSeek( xFilial( "CTT" ) + ( cAliasTNC )->( TNC_CC ) )
				( cTRB )->DESCRI := AllTrim( CTT->CTT_DESC01 )
			EndIf

		Else

			( cTRB )->QUANTI := ( cTRB )->QUANTI + 1

		EndIf

	EndIf

	// ------------------------------------------------------------------------------
	// Geracao "Por Funcao"
	// ------------------------------------------------------------------------------
	If cCbox == STR0035 .And. !Empty( ( cAliasTNC )->( TNC_CODFUN) ) //"Por Função"
		
		If !MsSeek( ( cAliasTNC )->( TNC_CODFUN ) )
			
			( cTRB )->( DbAppend() )
			( cTRB )->CODIGO := ( cAliasTNC )->( TNC_CODFUN )
			( cTRB )->DESCRI := ""
			( cTRB )->QUANTI := 1

			DbselectArea( "SRJ" )
			DbSetOrder( 1 )
			If MsSeek( xFilial( "SRJ" ) + ( cAliasTNC )->( TNC_CODFUN ) )
				( cTRB )->DESCRI := AllTrim( ( cTRB )->DESCRI ) + " - " + AllTrim( SRJ->RJ_DESC )
			EndIf

		Else

			( cTRB )->QUANTI := ( cTRB )->QUANTI + 1

		EndIf

	EndIf

	DbSelectArea( cAliasTNC )
	DbSkip()

End

( cTRB )->( DbGoTop() )
( cTRB2 )->( DbGoTop() )
If ( cTRB )->( !Eof() ) .Or. ( cTRB2 )->( !Eof() )
	vCRIGTXT := NGGRAFICO( cTituloG, "", "", cTituloG, "", vSERPR, "A", cTbGrafico, , cModGrafico )
Else
	MsgInfo( STR0029 ) //"Sem Informações para gerar a consulta!"
EndIf

( cAliasTNC )->( DbCloseArea() )

oTempTRB:Delete()
oTempTRB2:Delete()

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C735GDATAS³ Autor ³ Ricardo Dal Ponte     ³ Data ³05/10/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gera registros de Mes/Ano no arquivo temporario de acordo   ³±±
±±³          ³com a faixa de datas informado nos parametros da consulta.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMDT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function C735GDATAS()
MV012   := dDtVal1
nCONT   := 1
nDIA    := day(mv012)
nMES    := Month(mv012)
nANO    := year(mv012)

nLopINI := val(SubStr(dtos(mv012), 1, 6))
nLopFIM := val(SubStr(dtos(dDtVal2), 1, 6))

While nLopINI <= nLopFIM

	dData := mv012
	cMes := SubStr( MESEXTENSO( Str( Month( dData ) ) ), 1, 3 )
	cAno := AllTrim( Str( Year( dData ) ) )
	cANOMES := STR( nANO, 4 ) + Strzero( nMES, 2 )

	DbSelectArea( cTRB2 )
	If !DbSeek( cANOMES )
		( cTRB2 )->( DbAppend() )
		( cTRB2 )->CODIGO := cANOMES
		( cTRB2 )->DESCRI := MESEXTENSO( nMES ) + "/" + STR( nANO, 4 ) //' De '
		( cTRB2 )->QUANT1 := 0
		( cTRB2 )->QUANT2 := 0
	EndIf

   nCONT += 1
   nMES  += 1

   If nMES > 12
      nMES := nMES -12
      nANO := nANO + 1
   EndIf

   nDIA1 := NGDIASMES(nMES,nANO)
   nDIA1 := If(nDIA <= nDIA1,nDIA,nDIA1)
   mv012 := cTod(Str(nDIA1)+Str(nMes)+Str(nAno))

	nLopINI := val(SubStr(dtos(mv012), 1, 6))
End
Return .t.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C735DTTRB ³ Autor ³  Andre Perez          ³ Data ³22/02/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gera registros de Mes/Ano no arquivo temporario de acordo   ³±±
±±³          ³com a faixa de datas informado nos parametros da consulta.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMDT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C735DTTRB()
MV012   := dDtVal1
nCONT   := 1
nDIA    := day(mv012)
nMES    := Month(mv012)
nANO    := year(mv012)

nLopINI := val(SubStr(dtos(mv012), 1, 6))
nLopFIM := val(SubStr(dtos(dDtVal2), 1, 6))

While nLopINI <= nLopFIM

	dData := mv012
	cMes := SubStr( MESEXTENSO( Str( Month( dData  ) ) ), 1, 3 )
	cAno := AllTrim( Str( Year( dData ) ) )
	cANOMES := STR( nANO, 4 ) + Strzero( nMES, 2 )
	
	DbSelectArea( cTRB )
   	If !DbSeek( cANOMES )
	   	( cTRB )->( DbAppend() )
	   	( cTRB )->CODIGO := cANOMES
	   	( cTRB )->DESCRI := MESEXTENSO( nMES ) + "/" + STR( nANO, 4 ) //' De '
		( cTRB )->QUANTI := 0
   	EndIf

   nCONT += 1
   nMES  += 1

   If nMES > 12
      nMES := nMES -12
      nANO := nANO + 1
   EndIf

   nDIA1 := NGDIASMES(nMES,nANO)
   nDIA1 := If(nDIA <= nDIA1,nDIA,nDIA1)
   mv012 := cTod(Str(nDIA1)+Str(nMes)+Str(nAno))

	nLopINI := val(SubStr(dtos(mv012), 1, 6))
End
Return .t.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³QTEFUNC    ³ Autor³Andre Perez Alvarez    ³ Data  ³ 20/02/07³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Acumula o Total de Horas Trabalhadas E a qtde. de funcion. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ QTEFUNC()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MDTC735                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function QTEFUNC(cCbox)

Local cVerbas  := ""
Local DdtIni, DdtFim
Local lIntMDTGPE := .f.

If (cCbox == STR0021)   //Taxa de Frequencia
	Private nDiUteis := 0
	If Alltrim(GETMV("MV_MDTGPE")) == "S"
		lIntMDTGPE := .t.
		cVerbas := Alltrim(GETMV("MV_MDTVERBA"))
	Else
		If QTEPER1() != 1   //Cancelado
			Return .F.
		Endif
	Endif
Endif

If (cCbox == STR0023)  //Taxa de Gravidade
	If QTEPER2() != 1  //Cancelado
		Return .F.
	Endif
Endif

DbSelectArea( "SRA" )
DbSetOrder( 2 )
DbSeek( xFilial( "SRA" ) )
While !EOF() .AND. SRA->RA_FILIAL == xFilial( "SRA" )

	If SRA->RA_ADMISSA >= dDtVal2 .Or. ( SRA->RA_DEMISSA <= dDtVal1 .and. !Empty( SRA->RA_DEMISSA ) )
		DbSelectArea( "SRA" )
		DbSkip()
		Loop
	Endif

	nQtFunc++    //Total de Funcionarios

	If lIntMDTGPE  .And. ( cCbox == STR0021 )   //Integracao com o GPE   //Taxa de Frequencia
		
		DdtIni := dDtVal1
		DdtFim := dDtVal2

		If SRA->RA_ADMISSA > dDtVal1
			DdtIni := SRA->RA_ADMISSA
		Endif

		If SRA->RA_DEMISSA < DdtFim .and. !Empty(SRA->RA_DEMISSA)
			DdtFim := SRA->RA_DEMISSA
		Endif

		If dDataBase < DdtFim
			DdtFim := dDataBase
		Endif

		//Total de horas trabalhadas pelo funcionario
		nQtHrsFun += ( ( DdtFim - DdtIni ) + 1 ) * ( SRA->RA_HRSMES / 30 )
		//Acrescenta as horas extras e subtrai as faltas
		nQtHrsFun += MDT865HrsF( SRA->RA_FILIAL + SRA->RA_MAT, cVerbas, dDtVal1, dDtVal2, SRA->RA_HRSMES )
	Endif

	DbSelectArea( "SRA" )
	DbSkip()
End

If !lIntMDTGPE .And. (cCbox == STR0021)  //Taxa de Frequencia
	nQtHrsFun  := nQtFunc * nDiUteis  * nJornada
Endif

Return  .t.
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³QTEPER1    ³ Autor³Andre Perez Alvarez    ³ Data  ³ 20/02/07³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Pergunta a jornada de trabalho (horas) e a quantidade de   ³±±
±±³          ³ dias uteis no periodo.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ QTEPER1()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MDTC735                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function QTEPER1()

Local oDlg,oScr,oCbox
Local nOpcz := 0
Local oFont := TFont():New("Arial",8,14,,.t.,,.f.,,.f.,.f.)

Local oV1, cJorn := "08:00"
Local oV2, nDiasU := 310

DEFINE MSDIALOG oDlg TITLE STR0010 From 6,0 To 13,30 OF oMainWnd //"Parâmetros"

@ 00,00 SCROLLBOX oScr VERTICAL SIZE 70,160 OF oDlg BORDER
@ 10,5  SAY STR0030 Of oScr Pixel //"Jornada de trabalho: "
@ 10,61 MsGet oV1 VAR cJorn Size 20,08 Picture "99:99" Of oScr Pixel When .t. Valid (cJorn != " : ")
@ 22,5  SAY STR0031 Of oScr Pixel //"Dias úteis no período: "
@ 22,61 MsGet oV2 VAR nDiasU Size 20,08 Picture "999" Of oScr Pixel When .t.Valid !Empty(nDiasU)

DEFINE SBUTTON FROM 36, 35 TYPE 1 ENABLE OF oScr ACTION EVAL({|| nOpcz := 1,oDlg:End()})
DEFINE SBUTTON FROM 36, 65 TYPE 2 ENABLE OF oScr ACTION oDlg:End()
ACTIVATE MSDIALOG oDlg CENTERED

nJornada := mdt865conv(cJorn)
nDiUteis := nDiasU

Return nOpcz
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³QTEPER2    ³ Autor³Andre Perez Alvarez    ³ Data  ³ 20/02/07³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Pergunta a jornada (horas)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ QTEPER2()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MDTC735                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function QTEPER2()

Local oDlg,oScr,oCbox
Local nOpcz := 0
Local oFont := TFont():New("Arial",8,14,,.t.,,.f.,,.f.,.f.)

Local oV1, cJorn := "08:00"
Local oV2, nDiasU := 310

DEFINE MSDIALOG oDlg TITLE STR0010 From 6,0 To 12,30 OF oMainWnd //"Parâmetros"

@ 00,00 SCROLLBOX oScr VERTICAL SIZE 70,160 OF oDlg BORDER
@ 10,5  SAY STR0030 Of oScr Pixel //"Jornada de trabalho: "
@ 10,61 MsGet oV1 VAR cJorn Size 20,08 Picture "99:99" Of oScr Pixel When .t. Valid (cJorn != " : ")

DEFINE SBUTTON FROM 30, 35 TYPE 1 ENABLE OF oScr ACTION EVAL({|| nOpcz := 1,oDlg:End()})
DEFINE SBUTTON FROM 30, 65 TYPE 2 ENABLE OF oScr ACTION oDlg:End()
ACTIVATE MSDIALOG oDlg CENTERED

nJornada := mdt865conv(cJorn)

Return nOpcz
