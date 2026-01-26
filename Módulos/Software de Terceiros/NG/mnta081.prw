#INCLUDE "MNTA081.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FONT.CH"

Static cQryManut1
Static cQryManut2

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTA081
Cadastro automático de manutenções.
@type function

@author Felipe N. Welter
@since 30/01/2009

@param aVet     , array, Chave da manutenção padrão:
							[1] - Código do Bem
							[2] - Família do Bem
							[3] - Tipo Modelo
@param [aPeriod], array, Periodicidade das tarefas:
							[1] - Tarefa da Manutenção
							[2] - Data da Ultima Execução
							[3] - Acumulado da Manutenção

@return boolean , Indica se gerou as manutenções.
/*/
//-------------------------------------------------------------------
Function MNTA081( aVet, aPeriod )

	Local aNGBEGINPRM := NGBEGINPRM()
	Local aArea       := GetArea()
	Local aBind       := {}
	Local lRet        := .F.
	Local lRet081     := .T.
	Local cAlsManPad  := GetNextAlias()
	Local cPeriod     := ' '
	Local cTipMod     := ' '
	Local nTamMod     := FWTamSX3( 'TPF_TIPMOD' )[1]
	Local oTmpTbl
	Local oSize
	Local oPanel0
	Local oPanel1
	Local oPanel2

	Private asMenu
	Private cAliasTmp

	aNGBUTTON := {}
	SETKEY(VK_F11, {|| MNTA081VIS((cAliasTmp)->SERVIC,(cAliasTmp)->SEQREL) })

	//Variaveis para montagem de tela ou validacao
	Private oDlgC
	Private oMenu
	Private aVETINR := {}
	Private cCadastro
	Private cMARCA := GetMark()
	Private oFont11B := TFont():New("Arial",-11,-11,,.T.,,,,.F.,.F.)
	Private oFont10N := TFont():New("Arial",-10,-10,,.F.,,,,.F.,.F.)

	//Variaveis parametros
	Private cCodFami := ""
	Private cCodBem  := ""

	If	aVet != NIL

		cCodBem  := aVet[1]
		cCodFami := aVet[2]
		cTipMod  := aVet[3]
		
	Else

		cCodBem  := M->T9_CODBEM
		cCodFami := M->T9_CODFAMI
		cTipMod  := M->T9_TIPMOD

	EndIf

	dbSelectarea( 'TPF' )
	dbSetorder( 4 ) // TPF_FILIAL + TPF_CODFAM + TPF_TIPMOD + TPF_SERVIC + TPF_SEQREL

	If MNTSeekPad( 'TPF', 4, cCodFami, cTipMod )

		If !Empty( aPeriod )

			cPeriod := 'M'

			If Empty( cQryManut1 )

				cQryManut1 := "SELECT "
				cQryManut1 += 		"TPF.R_E_C_N_O_ "
				cQryManut1 += "FROM "
				cQryManut1 += 		RetSQLName( 'TPF' ) + " TPF "
				cQryManut1 += "WHERE "
				cQryManut1 += 		"TPF.TPF_FILIAL = ?     AND "
				cQryManut1 += 		"TPF.TPF_CODFAM = ?     AND "
				cQryManut1 += 		"( TPF.TPF_TIPMOD = ?   OR "
 				cQryManut1 += 		"TPF.TPF_TIPMOD = '*' ) AND "
				cQryManut1 += 		"TPF.TPF_SERVIC = ?     AND "
				cQryManut1 += 		"TPF.TPF_PERIOD = 'M'   AND "
				cQryManut1 += 		"TPF.D_E_L_E_T_ = ' ' "
				cQryManut1 += "ORDER BY "
				cQryManut1 += 		"TPF.TPF_TIPMOD DESC "
				
				cQryManut1 := ChangeQuery( cQryManut1 )

			EndIf

			aAdd( aBind, FWxFilial( 'TPF' ) )
			aAdd( aBind, cCodFami )
			aAdd( aBind, cTipMod )
			aAdd( aBind, aVet[4] )

			dbUseArea( .T., 'TOPCONN', TcGenQry2( , , cQryManut1, aBind ), cAlsManPad, .T., .T. )
			
			If (cAlsManPad)->( !EoF() )

				TPF->( msGoTo( (cAlsManPad)->R_E_C_N_O_ ) )

				MNTATUSTF( TPF->TPF_SEQREL, aPeriod )

			EndIf

			(cAlsManPad)->( DbCloseArea() )

		EndIf

		If Empty( cQryManut2 )

			cQryManut2 := "SELECT "
			cQryManut2 += 		"COUNT( TPF.TPF_FILIAL ) AS QTDMAN "
			cQryManut2 += "FROM "
			cQryManut2 += 		RetSQLName( 'TPF' ) + " TPF "
			cQryManut2 += "WHERE "
			cQryManut2 += 		"TPF.TPF_FILIAL =  ?        AND "
			cQryManut2 += 		"TPF.TPF_CODFAM =  ?        AND "
			cQryManut2 += 		"TPF.TPF_TIPMOD IN ( ?, ? ) AND "
			cQryManut2 += 		"TPF.TPF_PERIOD <> ?        AND "
			cQryManut2 += 		"TPF.D_E_L_E_T_ =  ? "
			
			cQryManut2 := ChangeQuery( cQryManut2 )

		EndIf
		
		aBind := {}
		aAdd( aBind, FWxFilial( 'TPF' ) )
		aAdd( aBind, cCodFami )
		aAdd( aBind, '*' )

		If Empty( cTipMod )

			aAdd( aBind, ' ' )

		Else

			aAdd( aBind, cTipMod )

		EndIf

		aAdd( aBind, cPeriod )
		aAdd( aBind, Space( 1 ) )

		dbUseArea( .T., 'TOPCONN', TcGenQry2( , , cQryManut2, aBind ), cAlsManPad, .T., .T. )

		If (cAlsManPad)->QTDMAN > 0
			
			lRet := APMSGYESNO( STR0001 + Chr( 13 ) + STR0003 ) // Deseja seleciona-las para incorporar ao cadastro de manutenção?

			If lRet

				aDBFC := {}
				aAdd( aDBFC, { 'OK'     , 'C', 02, 0 } )
				aAdd( aDBFC, { 'TIPMOD' , 'C', FWTamSX3( 'TPF_TIPMOD' )[1], FWTamSX3( 'TPF_TIPMOD' )[2] } )
				aAdd( aDBFC, { 'SERVIC' , 'C', FWTamSX3( 'TPF_SERVIC' )[1], FWTamSX3( 'TPF_SERVIC' )[2] } )
				aAdd( aDBFC, { 'SEQREL' , 'C', FWTamSX3( 'TPF_SEQREL' )[1], FWTamSX3( 'TPF_SEQREL' )[2] } )
				aAdd( aDBFC, { 'NOMSER' , 'C', FWTamSX3( 'TPF_NOMSER' )[1], FWTamSX3( 'TPF_NOMSER' )[2] } )
				aAdd( aDBFC, { 'NOMEMA' , 'C', FWTamSX3( 'TPF_NOMEMA' )[1], FWTamSX3( 'TPF_NOMEMA' )[2] } )
				aAdd( aDBFC, { 'CODARE' , 'C', FWTamSX3( 'TPF_CODARE' )[1], FWTamSX3( 'TPF_CODARE' )[2] } )
				aAdd( aDBFC, { 'TIPO'   , 'C', FWTamSX3( 'TPF_TIPO' )[1]  , FWTamSX3( 'TPF_TIPO' )[2]   } )
				aAdd( aDBFC, { 'TIPACO' , 'C', FWTamSX3( 'TPF_TIPACO' )[1], FWTamSX3( 'TPF_TIPACO' )[2] } )
				aAdd( aDBFC, { 'DESACO' , 'C', 15, 0 } )
				aAdd( aDBFC, { 'VARIA'  , 'C', 15, 0 } )
				aAdd( aDBFC, { 'DTULTMA', 'D', FWTamSX3( 'TF_DTULTMA' )[1], FWTamSX3( 'TF_DTULTMA' )[2] } )
				aAdd( aDBFC, { 'CONMANU', 'N', FWTamSX3( 'TF_CONMANU' )[1], FWTamSX3( 'TF_CONMANU' )[2] } )
				aAdd( aDBFC, { 'CALEND' , 'C', FWTamSX3( 'TF_CALENDA' )[1], FWTamSX3( 'TF_CALENDA' )[2] } )
				aAdd( aDBFC, { 'CALTPF' , 'C', FWTamSX3( 'TF_CALENDA' )[1], FWTamSX3( 'TF_CALENDA' )[2] } )

				vINDC  := { 'TIPMOD', 'SERVIC', 'SEQREL' }

				cAliasTmp := GetNextAlias()
				oTmpTbl	  := FWTemporaryTable():New( cAliasTmp, aDBFC )
				oTmpTbl:AddIndex( "Ind01" , vINDC )
				oTmpTbl:Create()

				dbSelectArea( 'TPF' )
				dbSetOrder( 4 ) // TPF_FILIAL + TPF_CODFAM + TPF_TIPMOD + TPF_SERVIC + TPF_SEQREL
				msSeek( FWxFilial( 'TPF' ) + cCodFami )

				While TPF->( !Eof() ) .And. TPF->TPF_FILIAL = FWxFilial( 'TPF' ) .And. TPF->TPF_CODFAM == cCodFami 
				
					If ( TPF->TPF_TIPMOD == cTipMod .Or. TPF->TPF_TIPMOD == PadR( '*', nTamMod ) )

						If Empty( aPeriod ) .Or. (!Empty( aPeriod ) .And. TPF->TPF_PERIOD <> 'M')

							
							RecLock( (cAliasTmp), .T. )
							
								(cAliasTmp)->TIPMOD := TPF->TPF_TIPMOD
								(cAliasTmp)->SERVIC := TPF->TPF_SERVIC
								(cAliasTmp)->SEQREL := TPF->TPF_SEQREL
								(cAliasTmp)->NOMSER := NGSEEK("ST4",TPF->TPF_SERVIC,1,"T4_NOME")
								(cAliasTmp)->NOMEMA := TPF->TPF_NOMEMA
								(cAliasTmp)->CODARE := TPF->TPF_CODARE
								(cAliasTmp)->TIPO   := TPF->TPF_TIPO
								(cAliasTmp)->TIPACO := TPF->TPF_TIPACO
								(cAliasTmp)->CALEND := TPF->TPF_CALEND
								(cAliasTmp)->CALTPF := TPF->TPF_CALEND
								If TPF->TPF_TIPACO $ "T/A"
									If TPF->TPF_TIPACO $ "T"
										(cAliasTmp)->DESACO := STR0004 //"Tempo"
										(cAliasTmp)->VARIA := AllTrim(STR(TPF->TPF_TEENMA))+" "+TPF->TPF_UNENMA
									ElseIf TPF->TPF_TIPACO $ "A"
										(cAliasTmp)->DESACO := STR0005 //"Tempo/Contador"
										(cAliasTmp)->VARIA := AllTrim(STR(TPF->TPF_TEENMA))+" "+TPF->TPF_UNENMA+" / "+AllTrim(STR(TPF->TPF_INENMA))
									EndIf
								ElseIf TPF->TPF_TIPACO $ "C/P/F/S"
									If TPF->TPF_TIPACO $ "C"
										(cAliasTmp)->DESACO := STR0006 //"Contador"
									ElseIf TPF->TPF_TIPACO $ "P"
										(cAliasTmp)->DESACO := STR0007 //"Producao"
									ElseIf TPF->TPF_TIPACO $ "F"
										(cAliasTmp)->DESACO := STR0008 //"Contador Fixo"
									ElseIf TPF->TPF_TIPACO $ "S"
										(cAliasTmp)->DESACO := STR0009 //"Seg. Contador"
									EndIf
									(cAliasTmp)->VARIA := AllTrim(STR(TPF->TPF_INENMA))
								EndIf

							MsUnLock()
						
						EndIf

					EndIf

					TPF->( dbSkip() )

				End

				//Colunas do MarkBrowse
				aTRBC := {}
				aAdd( aTRBC, { STR0033, { | | ( cAliasTmp )->TIPMOD }, 'C', '!@', 0, FWTamSx3( 'TPF_TIPMOD'  )[ 1 ] } ) // Modelo
				aAdd( aTRBC, { STR0010, { | | ( cAliasTmp )->SERVIC }, 'C', '!@', 0, FwTamSx3( 'TPF_SERVIC'  )[ 1 ] } ) //"Servico"
				aAdd( aTRBC, { STR0011, { | | ( cAliasTmp )->SEQREL }, 'C', '!@', 0, FwTamSx3( 'TPF_SEQREL'  )[ 1 ] } ) //"Seq."
				aAdd( aTRBC, { STR0012, { | | ( cAliasTmp )->NOMSER }, 'C', '!@', 0, FwTamSx3( 'TPF_NOMSER'  )[ 1 ] } ) //"Nome"
				aAdd( aTRBC, { STR0013, { | | ( cAliasTmp )->NOMEMA }, 'C', '!@', 0, FwTamSx3( 'TPF_NOMEMA'  )[ 1 ] } ) //"Nome Manutencao"
				aAdd( aTRBC, { STR0014, { | | ( cAliasTmp )->CODARE }, 'C', '!@', 0, FwTamSx3( 'TPF_CODARE'  )[ 1 ] } ) //"Area"
				aAdd( aTRBC, { STR0015, { | | ( cAliasTmp )->TIPO },   'C', '!@', 0, FwTamSx3( 'TPF_TIPO'  )[ 1 ]   } ) //"Tipo"
				aAdd( aTRBC, { STR0016, { | | ( cAliasTmp )->DESACO }, 'C', '!@', 0, 15 } ) //"Acompanha."
				aAdd( aTRBC, { STR0017, { | | ( cAliasTmp )->VARIA },  'C', '!@', 0, 15 } ) //"Increm./Freq."

				// Objeto que calcula as dimensões da tela
				oSize := FwDefSize():New( .F. )

				// Insere dimensões da tela (O cálculo deve ser realizado com base no tamanho da Dialog)
				oSize:aWindSize[1] := 6.5
				oSize:aWindSize[2] := 0
				oSize:aWindSize[3] := 30
				oSize:aWindSize[4] := 90

				oSize:AddObject( 'CIMA' , 100, 11, .T., .T., .T. ) // Totalmente dimensionavel
				oSize:AddObject( 'BAIXO', 100, 89, .T., .T., .T. ) // Totalmente dimensionavel

				oSize:lProp    := .T. // Proporcional

				oSize:Process() // Realiza os cálculos

				DEFINE MSDIALOG oDlgC TITLE STR0018 FROM oSize:aWindSize[1],oSize:aWindSize[2] To oSize:aWindSize[3],oSize:aWindSize[4] := 90 OF oMainWnd STYLE DS_MODALFRAME //"Manutencão Padrao"

				oDlgC:lEscClose := .F.

				// Painel Pai, ocupa toda a Dialog
				oPanel0 := tPanel():New( 000, 000, , oDlgC, , , , , , 100, 100 )
				oPanel0:Align := CONTROL_ALIGN_ALLCLIENT

				// Inicia o Panel superior para as informações sobre o Bem
				oPanel1 := tPanel():New( 000, 000, , oPanel0, , , , , , 100, oSize:aPosObj[ 1, 3 ] )
				oPanel1:Align := CONTROL_ALIGN_TOP

				@ 01,01 Say STR0019 Font oFont11B OF oPanel1 //"Bem: "
				@ 01,07 Say AllTrim(cCodBem)+" - "+NGSEEK("ST9",cCodBem,1,"T9_NOME") OF oPanel1
				@ 02,01 Say STR0020 Font oFont11B OF oPanel1 //"Familia: "
				@ 02,07 Say AllTrim(cCodFami)+" - "+NGSEEK("ST6",cCodFami,1,"T6_NOME") OF oPanel1

				// Inicia o Panel inferior para a lista de Manutenções Padrão
				oPanel2 := tPanel():New( 000, 000, , oPanel0, , , , , , 100, oSize:aPosObj[ 2, 3 ] )
				oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

				// Cria MarkBrowse no painel inferior
				oMark := FWMarkBrowse():New()
				oMark:SetAlias( (cAliasTmp) )
				// Cria CheckBox e adiciona suas ações
				oMark:AddMarkColumns(	{|| If((cAliasTmp)->OK == cMarca,'lbok','lbno')},;
											{ || MNT081Mark() },;
											{ || M081MarkAll() } )
				oMark:SetColumns( aTRBC )
				oMark:SetTemporary( .T. )
				// SetMenuDef e SetIgnoreARotina necessário para inibir a EnchoiceBar do próprio FwMarkBrowse
				oMark:SetMenuDef('')
				oMark:SetIgnoreARotina( .T. )
				oMark:DisableReport()
				oMark:Activate( oPanel2 )

				@ 01.1,0.5 TO 4.1,44.0 OF oDlgC

				@ 03,38 Say STR0022 Font oFont10N OF oPanel1 //"(F11) - Visualizar"

				dbSelectArea(cAliasTmp)
				dbGotop()

				ACTIVATE MSDIALOG ODlgC ON INIT EnchoiceBar(ODlgC,{||If(MNTA081OK(),ODlgC:End(),)},;
				{||If(APMSGYESNO(STR0023),ODlgC:End(),)}) CENTERED //"Deseja cancelar esse processo?"

			EndIf

		EndIf

		(cAlsManPad)->( dbCloseArea() )

	Else

		lRet081 := .F.

	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Devolve variaveis armazenadas (NGRIGHTCLICK)                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RestArea(aArea)

	If lRet
		oTmpTbl:Delete()
	EndIf

	NGRETURNPRM(aNGBEGINPRM)
	
	FwFreeArray( aArea )
	FwFreeArray( aBind )

Return lRet081

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNT081Mark ³ Autor ³Felipe N. Welter      ³ Data ³ 30/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao chamada no duplo clique em um elemento no browse     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MNTA081                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MNT081Mark()

	nReg := Recno()
	If !(IsMark('OK',cMarca))
		If MNT081INF()
			RecLock((cAliasTmp),.F.)
			(cAliasTmp)->OK := cMarca
			MsUnLock(cAliasTmp)
		EndIf
	Else
		RecLock((cAliasTmp),.F.)
		(cAliasTmp)->OK := Space(02)
		MsUnLock(cAliasTmp)
	Endif

	dbGoTo(nReg)
	oMark:oBrowse:Refresh()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNT081INF  ³ Autor ³Felipe N. Welter      ³ Data ³ 02/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Solicita que informe data/contador da ultima manutencao     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MNTA081/MNT081Mark                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNT081INF()

	Local oDlgS
	Local lSai := .F.
	Local lCalVazio := If(Empty((cAliasTmp)->CALTPF),.t.,.f.)
	Local aAltVar := {}

	Private oFont := TFont():New("Arial",,14,,.T.,,,,.F.,.F.)

	dbSelectArea(cAliasTmp)
	Private dData := If(!Empty((cAliasTmp)->DTULTMA),(cAliasTmp)->DTULTMA,CTOD("  /  /    "))
	Private nContador := If(!Empty((cAliasTmp)->CONMANU),(cAliasTmp)->CONMANU,0)
	Private cCalendTPF := If(!Empty((cAliasTmp)->CALEND),(cAliasTmp)->CALEND,Space(Len((cAliasTmp)->CALEND)))

	If !((cAliasTmp)->TIPACO $ "T")

		DEFINE MSDIALOG oDlgS TITLE STR0024  From 6,0 To 16,53 OF oDlgC //"Última Manutenção"

		oDlgS:lEscClose := .F.

		@ 00,00 SCROLLBOX oScr VERTICAL SIZE 91,215 OF oDlgS BORDER
		@ 08,05 SAY STR0024+" - "+AllTrim(cCodBem)+" - "+SubStr(NGSEEK("ST9",cCodBem,1,"T9_NOME"),1,20);
		+" "+(cAliasTmp)->SERVIC+" "+(cAliasTmp)->SEQREL Of oScr Pixel Font oFont //"Última Manutenção"
		@ 25,05 SAY STR0025 Of oScr Pixel //"Data:"
		@ 25,40 MsGet dData Size 45,08 Pixel Of oScr Picture '99/99/99' Valid naovazio() .And. NGCPDIAATU(dData,"<=",.T.,.T.,.T.) .And. VLDATAULTM()
		@ 38,05 SAY STR0026 Of oScr Pixel //"Contador:"
		@ 38,40 MsGet nContador Size 49,08 Pixel Of oScr Picture "@E 999,999,999,999";
				Valid ( nContador > 0 ) .And. naovazio( nContador ) .And. Positivo()
		If lCalVazio
			@ 51,05 SAY STR0029 Of oScr Pixel //"Calendário"
			@ 51,40 MSGET cCalendTPF SIZE 25,07 OF oDlgS PIXEL PICTURE '@!' F3 "SH7";
				VALID naovazio() .And. Existcpo("SH7",cCalendTPF)
		Endif
		DEFINE SBUTTON FROM 60,180 TYPE 1 ENABLE OF oScr ACTION ;
			EVAL({||lSai := .T.,If((dData <= dDataBase .And. nContador > 0 .And. If(!lCalVazio,.t.,If(Empty(cCalendTPF),.f.,.t.))),oDlgS:End(),lSai := .F.)})
	Else

		DEFINE MSDIALOG oDlgS TITLE STR0024  From 6,0 To 14,53 OF oDlgC //"Última Manutenção"

		oDlgS:lEscClose := .F.

		@ 00,00 SCROLLBOX oScr VERTICAL SIZE 91,215 OF oDlgS BORDER
		@ 08,05 SAY STR0024+" - "+AllTrim(cCodBem)+" - "+SubStr(NGSEEK("ST9",cCodBem,1,"T9_NOME"),1,20);
		+" "+(cAliasTmp)->SERVIC+" "+(cAliasTmp)->SEQREL Of oScr Pixel Font oFont //"Última Manutenção"
		@ 25,05 SAY STR0025 Of oScr Pixel //"Data:"
		@ 25,40 MsGet dData Size 45,08 Pixel Of oScr Picture '99/99/99' Valid naovazio() .And. NGCPDIAATU(dData,"<=",.T.,.T.,.T.) .And. VLDATAULTM()
		If lCalVazio
			@ 38,05 SAY STR0029 Of oScr Pixel //"Calendário"
			@ 38,40 MSGET cCalendTPF SIZE 25,07 OF oDlgS PIXEL PICTURE '@!' F3 "SH7";
			VALID naovazio() .And. Existcpo("SH7",cCalendTPF)
		Endif
		DEFINE SBUTTON FROM 45,180 TYPE 1 ENABLE OF oScr ACTION ;
			EVAL({||lSai := .T.,If((dData <= dDataBase .And. If(!lCalVazio,.t.,If(Empty(cCalendTPF),.f.,.t.))),oDlgS:End(),lSai := .F.)})

	EndIf

	/*Ponto de entrada para realizar alterações das variáveis
	considerando os diferentes tipos de manutenção (tempo, contador, etc).*/
	If ExistBlock( "MNTA081B" )
		aAltVar := { dData,nContador,cCalendTPF }
		ExecBlock( "MNTA081B",.F.,.F.,{ aAltVar } )
	EndIf

	ACTIVATE MSDIALOG oDlgS CENTERED

	If lSai

		dbSelectArea(cAliasTmp)
		RecLock((cAliasTmp),.F.)
		(cAliasTmp)->DTULTMA := dData
		(cAliasTmp)->CONMANU := nContador
		If !Empty(cCalendTPF)
			(cAliasTmp)->CALEND := cCalendTPF
		Endif
		MsUnLock(cAliasTmp)

	EndIf

Return lSai

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M081MarkAll³ Autor ³Felipe N. Welter      ³ Data ³ 30/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava marca em todos os registros validos                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MNTA081                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function M081MarkAll()

	dbSelectArea(cAliasTmp)
	dbGotop()
	While !Eof()
	If IsMark('OK',cMarca)
		RecLock((cAliasTmp),.F.)
		Replace OK      With Space(2)
		Replace DTULTMA With Ctod('  /  /  ')
		Replace CONMANU With 0
		Replace CALEND  With Space(Len(sh7->h7_codigo))
		MsUnLock(cAliasTmp)
	Else
		If Empty((cAliasTmp)->DTULTMA) .Or. Empty((cAliasTmp)->CONMANU) .Or.;
			Empty((cAliasTmp)->CALEND)
			MNT081INF()
		Endif
		RecLock((cAliasTmp),.F.)
		Replace OK With cMarca
		MsUnLock(cAliasTmp)
	EndIf
	dbSkip()
	End
	dbGoTop()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNTA081VIS³ Autor ³Felipe N. Welter       ³ Data ³ 02/02/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Visualiza Manutencao Padrao selecionada (F11)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA081                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTA081VIS(cServico,cSequencia)

	Local aArea := FWGetArea()

	dbSelectArea( 'TPF' )
	dbSetOrder( 4 ) // TPF_FILIAL + TPF_CODFAM + TPF_TIPMOD + TPF_SERVIC + TPF_SEQREL
	If msSeek( FWxFilial( 'TPF' ) + cCodFami + (cAliasTmp)->TIPMOD + (cAliasTmp)->SERVIC + (cAliasTmp)->SEQREL )

		NG180FOLD("TPF",TPF->(Recno()),2)
	
	EndIf
	
	FWRestArea( aArea )

	FWFreeArray( aArea )

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNTA081OK  ³ Autor ³Felipe N. Welter      ³ Data ³ 30/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida e Grava as Manutencoes Padrao                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MNTA081                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTA081OK()

Local lMark := .F.
Local lRet := .T.

dbSelectArea(cAliasTmp)
dbGotop()
While !Eof()
	If IsMark('OK',cMarca)
		lMark := .T.
	EndIf
	dbSkip()
EndDo

If !lMark
	APMSGALERT(STR0027) //"Nenhuma manutencao foi selecionada!"
	lRet := .F.
Else
	If APMSGYESNO(STR0028) //"Deseja realmente incorporar as manutencoes selecionadas?"

		dbSelectArea(cAliasTmp)
		dbGotop()
		While !Eof()
           If IsMark('OK',cMarca)
              lProbl := If(Empty((cAliasTmp)->DTULTMA) .Or. Empty((cAliasTmp)->CALEND),.T.,.F.)
              If !lProbl .And. !(cAliasTmp)->TIPACO $ "T"
                 lProbl := If(Empty((cAliasTmp)->CONMANU),.T.,.F.)
              Endif
              If lProbl
                 HELP(" ",1,"OBRIGAT",,STR0024+CRLF+CRLF+STR0025+" , "+STR0026+" , "+STR0029,5,1)
                 Return .f.
              Endif
           Endif
           dbSkip()
        End

		dbGotop()
		While (cAliasTmp)->( !EoF() )

			If IsMark('OK',cMarca)

				dbSelectArea( 'TPF' )
				dbSetorder( 4 ) // TPF_FILIAL + TPF_CODFAM + TPF_TIPMOD + TPF_SERVIC + TPF_SEQREL
				If msSeek( FWxFilial( 'TPF' ) + cCodFami + (cAliasTmp)->TIPMOD + (cAliasTmp)->SERVIC + (cAliasTmp)->SEQREL )

				   MNTATUSTF()

				EndIf

			EndIf

			dbSelectarea(cAliasTmp)
            dbSkip()

		End
	Else
		lRet := .F.
	EndIf

EndIf

dbSelectArea(cAliasTmp)
dbGoTop()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTATUSTF
Alimenta os campos da manut. com os detalhes da manutenção padrão.
@type function

@author Felipe N. Welter
@since 30/01/2009

@param [cSeqPad], string, Sequência da manutenção padrão.
@param [aPeriod], array , Periodicidade das tarefas:
							[1] - Tarefa da Manutenção
							[2] - Data da Ultima Execução
							[3] - Acumulado da Manutenção
@param [cTipMod], string, Tipo modelo utilizado na manutenção padrão.

@return boolean
/*/
//-------------------------------------------------------------------
Static Function MNTATUSTF( cSeqPad, aPeriod, cTipMod )

	Local cSTF      := ""
	Local cTPF      := ""
	Local cContext  := ""
	Local cSequen   := ''
	Local nInd      := 0
	Local nTam      := 0
	Local aSTF      := {}
	Local aStruct   := {}
	Local aNAO      := { 'TF_FILIAL', 'TF_CODBEM', 'TF_PADRAO', 'TF_SEQUEPA', 'TF_SEQREPA', 'TF_SEQRELA' }

	/*------------------------------------------------------------------------------------------+
	| Var. utilizadas para gravar Data Ultima e Acumulado quando o array aPeriod não é enviado. |
	+------------------------------------------------------------------------------------------*/
	Private dDtUltm := CToD( '' )
	Private nContMa := 0

	Default aPeriod := {}
	Default cTipMod := TPF->TPF_TIPMOD

	//Cria Array de controle do STF
	dbselectarea("STF")
	aStruct := DBSTRUCT()
	nTam    := Len(aStruct)

	For nInd := 1 To nTam

		If aSCAN(aNAO,AllTrim(aStruct[nInd,1])) > 0
			dbskip()
			Loop
		Endif

		cContext := Posicione("SX3",2,aStruct[nInd,1],"X3_CONTEXT")
		If !(cContext $ "V")
			cSTF := "STF->" + aStruct[nInd,1]
			If SUBSTR(aStruct[nInd,1],10,01) $ "0123456789"
				cTPF := "TPF_"+SUBSTR(aStruct[nInd,1],4,5)+SUBSTR(aStruct[nInd,1],10,01)
			Else
				cTPF := "TPF_"+SUBSTR(aStruct[nInd,1],4,6)
			Endif
			Aadd(aSTF,{cSTF, cTPF})
		EndIf
		dbskip()

	Next nInd

	If Len( aPeriod ) < 2

		cSequen := (cAliasTmp)->SEQREL
		dDtUltm := (cAliasTmp)->DTULTMA
		nContMa := (cAliasTmp)->CONMANU

	Else

		cSequen := cSeqPad

	EndIf

	//Carrega o TPF nas variaveis do STF
	RecLock( 'STF', .T. )		

		For nInd := 1 TO Len(aSTF)
			cTPF := aSTF[nInd][2]
			cSTF := aSTF[nInd][1]
			dbSelectArea("TPF")
			STF->(&cSTF.) := FIELDGET(FIELDPOS(cTPF))
		Next

		STF->TF_FILIAL  := FWxFilial( 'STF' )
		STF->TF_CODBEM  := cCodBem
		STF->TF_PADRAO  := "S"
		STF->TF_SEQREPA := cSequen
		STF->TF_ATIVO   := "S"
		STF->TF_PLANEJA := "S"
		STF->TF_SEQRELA := MNTA120Seq( STF->TF_CODBEM, STF->TF_SERVICO )

		If STF->TF_PERIODO != 'M'

			STF->TF_DTULTMA := dDtUltm
			STF->TF_CONMANU := nContMa

		EndIf

	STF->(MsUnlock())

	MNTATUST5( cTipMod, STF->TF_SERVICO, STF->TF_SEQRELA, STF->TF_SEQREPA, aPeriod )
	MNTATUSTM( cTipMod, STF->TF_SERVICO, STF->TF_SEQRELA, STF->TF_SEQREPA )
	MNTATUSTG( cTipMod, STF->TF_SERVICO, STF->TF_SEQRELA, STF->TF_SEQREPA )
	MNTATUSTH( cTipMod, STF->TF_SERVICO, STF->TF_SEQRELA, STF->TF_SEQREPA )

	//---------------------------------------------------------------------------
	// Ponto de Entrada que possibilita fazer alterações na STF, STM, STG e STH
	//---------------------------------------------------------------------------
	If ExistBlock("MNTA081A")
		ExecBlock("MNTA081A",.F.,.F.)
	EndIf

	dbSelectArea("STF")

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTATUST5
Grava tarefas da manutenção conforme a manutenção padrão.
@type function

@author Felipe N. Welter
@since 30/01/2009

@param cTipMod  , string, Tipo modelo.
@param cCodSer  , string, Código do Serviço.
@param cSeqRel  , string, Sequência da manutenção.
@param cSeqPad  , string, Sequência da manutenção padrão.
@param [aPeriod], array , Periodicidade das tarefas:
							[1] - Tarefa da Manutenção
							[2] - Data da Ultima Execução
							[3] - Acumulado da Manutenção

@return
/*/
//-------------------------------------------------------------------
Static Function MNTATUST5( cTipMod, cCodSer, cSeqRel, cSeqPad, aPeriod )

	Local cST5      := ""
	Local cTP5      := ""
	Local cContext  := ""
	Local nInd      := 0
	Local nTam      := 0
	Local nPosTar   := 0
	Local aST5      := {}
	Local aNAO      := { 'T5_FILIAL', '"T5_CODBEM', 'T5_SEQRELA' }
	Local aStruct   := {}

	Default aPeriod := {}

	//Cria Array de controle do STF
	dbselectarea("ST5")
	aStruct := DBSTRUCT()
	nTam    := Len(aStruct)

	For nInd := 1 To nTam

		If aSCAN(aNAO,AllTrim(aStruct[nInd,1])) > 0
			Dbskip()
			Loop
		Endif

		cContext := Posicione("SX3",2,aStruct[nInd,1],"X3_CONTEXT")
		If !(cContext $ "V")

			cST5 := "ST5->" + aStruct[nInd,1]
			If SUBSTR(aStruct[nInd,1],10,01) $ "0123456789"
				cTP5 := "TP5_" + SUBSTR(aStruct[nInd,1],4,5) + SUBSTR(aStruct[nInd,1],10,01)
			Else
				cTP5 := "TP5_" + SUBSTR(aStruct[nInd,1],4,6)
			Endif
			aAdd(aST5,{cST5, cTP5})

		EndIf
		dbSkip()

	End

	dbSelectArea( 'TP5' )
	dbSetOrder( 3 ) // TP5_FILIAL + TP5_CODFAM + TP5_TIPMOD + TP5_SERVIC + TP5_SEQREL + TP5_TAREFA
	If msSeek( FWxFilial( 'TP5' ) + cCodFami + cTipMod + cCodSer + cSeqPad )

		While TP5->( !EoF() ) .And. TP5->TP5_FILIAL == FWxFilial( 'TP5' ) .And. TP5->TP5_CODFAM == cCodFami .And.;
			TP5->TP5_TIPMOD == cTipMod .And. TP5->TP5_SERVIC == cCodSer	.And. TP5->TP5_SEQREL == cSeqPad

			RecLock( 'ST5', .T. )

				ST5->T5_FILIAL  := FWxFilial( 'ST5' )
				ST5->T5_CODBEM  := cCodBem
				ST5->T5_SEQRELA := cSeqRel
				ST5->T5_ATIVA   := '1'

				For nInd := 1 TO LEN(aST5)
					cTP5 := aST5[nInd][2]
					cST5 := aST5[nInd][1]
					dbSelectArea("TP5")
					&cST5. := FIELDGET(FIELDPOS(cTP5))
				Next

				If STF->TF_PERIODO == 'M'
					
					If !Empty( aPeriod ) .And. !Empty( aPeriod[ 2 ] ) 
						
						If ( nPosTar := aScan( aPeriod[ 2 ], { |x| x[1] == ST5->T5_TAREFA } ) ) > 0

							ST5->T5_DTULTMA := aPeriod[ 2, nPosTar,2 ]
							ST5->T5_CONMANU := aPeriod[ 2, nPosTar,3 ]

						Else

							ST5->T5_DTULTMA := CToD( '' )
							ST5->T5_CONMANU := 0

						EndIf

					Else

						ST5->T5_DTULTMA := dDtUltm
						ST5->T5_CONMANU := nContMa

					EndIf

				EndIf

			MsUnLock()

			TP5->( dbSkip() )

		End
		
	Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTATUSTM
Grava dependências da manutenção conforme a manutenção padrão.
@type function

@author Deivys Joenck
@since 30/01/2009

@param cTipMod  , string, Tipo modelo.
@param cCodSer  , string, Código do Serviço.
@param cSeqRel  , string, Sequência da manutenção.
@param cSeqPad  , string, Sequência da manutenção padrão.

@return
/*/
//-------------------------------------------------------------------
Static Function MNTATUSTM( cTipMod, cCodSer, cSeqRel, cSeqPad )

	Local cSTM     := ""
	Local cTPM     := ""
	Local cContext := ""
	Local nInd     := 0
	Local nTam     := 0
	Local aSTM     := {}
	Local aNAO     := { 'TM_FILIAL', 'TM_CODBEM', 'TM_SEQRELA' }
	Local aStruct  := {}

	//Cria Array de controle do STF
	dbselectarea("STM")
	aStruct := DBSTRUCT()
	nTam    := Len(aStruct)

	For nInd := 1 To nTam

		If aSCAN(aNAO,AllTrim(aStruct[nInd,1])) > 0
			Dbskip()
			Loop
		Endif

		cContext := Posicione("SX3",2,aStruct[nInd,1],"X3_CONTEXT")
		If !(cContext $ "V")
			cSTM := "STM->" + aStruct[nInd,1]
			If SUBSTR(aStruct[nInd,1],10,01) $ "0123456789"
				cTPM := "TPM_" + SUBSTR(aStruct[nInd,1],4,5) + SUBSTR(aStruct[nInd,1],10,01)
			Else
				cTPM := "TPM_" + SUBSTR(aStruct[nInd,1],4,6)
			Endif
			Aadd(aSTM,{cSTM, cTPM})
		EndIf
		dbskip()

	End

	dbSelectArea( 'TPM' )
	dbSetOrder( 2 ) // TPM_FILIAL + TPM_CODFAM + TPM_TIPMOD + TPM_SERVIC + TPM_SEQREL + TPM_TAREFA + TPM_DEPEND
	If msSeek( FWxFilial( 'TPM' ) + cCodFami + cTipMod + cCodSer + cSeqPad )

		While TPM->( !EoF() ) .And. TPM->TPM_FILIAL == FWxFilial( 'TPM' ) .And. TPM->TPM_CODFAM == cCodFami .And.;
			TPM->TPM_TIPMOD == cTipMod .And. TPM->TPM_SERVIC == cCodSer	.And. TPM->TPM_SEQREL == cSeqPad

			dbSelectArea("STM")
			RecLock("STM",.T.)
				
				STM->TM_FILIAL  := xFilial("STM")
				STM->TM_CODBEM  := cCodBem
				STM->TM_SEQRELA := cSeqRel

				For nInd := 1 TO LEN(aSTM)
					cTPM := aSTM[nInd][2]
					cSTM := aSTM[nInd][1]
					dbSelectArea("TPM")
					&cSTM. := FIELDGET(FIELDPOS(cTPM))
				Next

				dbSelectArea("TPM")
				dbSkip()

			MsUnLock("STM")

		End

	Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTATUSTG
Grava insumos da manutenção conforme a manutenção padrão.
@type function

@author Deivys Joenck
@since 30/01/2009

@param cTipMod  , string, Tipo modelo.
@param cCodSer  , string, Código do Serviço.
@param cSeqRel  , string, Sequência da manutenção.
@param cSeqPad  , string, Sequência da manutenção padrão.

@return
/*/
//-------------------------------------------------------------------
Static Function MNTATUSTG( cTipMod, cCodSer, cSeqRel, cSeqPad )

	Local cSTG     := ""
	Local cTPG     := ""
	Local cContext := ""
	Local nInd     := 0
	Local nTam     := 0
	Local aSTG     := {}
	Local aNAO     := { 'TG_FILIAL', 'TG_CODBEM', 'TG_SEQRELA' }
	Local aStruct  := {}

	//Cria Array de controle do STF
	dbselectarea("STG")
	aStruct := DBSTRUCT()
	nTam    := Len(aStruct)

	For nInd := 1 To nTam

		If aSCAN(aNAO,AllTrim(aStruct[nInd,1])) > 0
			dbSkip()
			Loop
		Endif

		cContext := Posicione("SX3",2,aStruct[nInd,1],"X3_CONTEXT")
		If !(cContext $ "V")
			cSTG := "STG->" + aStruct[nInd,1]
			If SUBSTR(aStruct[nInd,1],10,01) $ "0123456789"
				cTPG := "TPG_" + SUBSTR(aStruct[nInd,1],4,5) + SUBSTR(aStruct[nInd,1],10,01)
			Else
				cTPG := "TPG_" + SUBSTR(aStruct[nInd,1],4,6)
			Endif
			aAdd(aSTG,{cSTG, cTPG})
		EndIf
		dbSkip()
	End

	dbSelectArea( 'TPG' )
	dbSetOrder( 3 ) // TPG_FILIAL + TPG_CODFAM + TPG_TIPMOD + TPG_SERVIC + TPG_SEQREL + TPG_TAREFA + TPG_TIPORE + TPG_CODIGO
	If msSeek( FWxFilial( 'TPG' ) + cCodFami + cTipMod + cCodSer + cSeqPad )

		While TPG->( !EoF() ) .And. TPG->TPG_FILIAL == FWxFILIAL( 'TPG' ) .And. TPG->TPG_CODFAM == cCodFami .And.;
			TPG->TPG_TIPMOD == cTipMod .And. TPG->TPG_SERVIC == cCodSer	.And. TPG->TPG_SEQREL == cSeqPad

			dbSelectArea("STG")
			RecLock("STG",.T.)
				
				STG->TG_FILIAL  := xFilial("STG")
				STG->TG_CODBEM  := cCodBem
				STG->TG_SEQRELA := cSeqRel
				
				For nInd := 1 TO LEN(aSTG)
					cTPG := aSTG[nInd][2]
					cSTG := aSTG[nInd][1]
					dbSelectArea("TPG")
					&cSTG. := FIELDGET(FIELDPOS(cTPG))
				Next
				dbSelectArea("TPG")
				dbSkip()
			MsUnLock("STG")
		End

	Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTATUSTH
Grava etapas da manutenção conforme a manutenção padrão.
@type function

@author Deivys Joenck
@since 30/01/2009

@param cTipMod  , string, Tipo modelo.
@param cCodSer  , string, Código do Serviço.
@param cSeqRel  , string, Sequência da manutenção.
@param cSeqPad  , string, Sequência da manutenção padrão.

@return
/*/
//-------------------------------------------------------------------
Static Function MNTATUSTH( cTipMod, cCodSer, cSeqRel, cSeqPad )

	Local cSTH     := ""
	Local cTPH     := ""
	Local cContext := ""
	Local nInd     := 0
	Local nTam     := 0
	Local aSTH     := {}
	Local aNAO     := { 'TH_FILIAL', 'TH_CODBEM', 'TH_SEQRELA' }
	Local aStruct  := {}

	//Cria Array de controle do STF
	dbselectarea("STH")
	aStruct := DBSTRUCT()
	nTam    := Len(aStruct)

	For nInd := 1 To nTam

		If aSCAN(aNAO,AllTrim(aStruct[nInd,1])) > 0
			dbSkip()
			Loop
		Endif

		cContext := Posicione("SX3",2,aStruct[nInd,1],"X3_CONTEXT")
		If !(cContext $ "V")
			cSTH := "STH->" + aStruct[nInd,1]
			If SUBSTR(aStruct[nInd,1],10,01) $ "0123456789"
				cTPH := "TPH_" + SUBSTR(aStruct[nInd,1],4,5) + SUBSTR(aStruct[nInd,1],10,01)
			Else
				cTPH := "TPH_" + SUBSTR(aStruct[nInd,1],4,6)
			Endif
			aAdd(aSTH,{cSTH, cTPH})
		EndIf
		dbSkip()
	End

	dbSelectArea( 'TPH' )
	dbSetOrder( 6 ) // TPH_FILIAL + TPH_CODFAM + TPH_TIPMOD + TPH_SERVIC + TPH_SEQREL + TPH_TAREFA + TPH_ETAPA
	If msSeek( FWxFilial( 'TPH' ) + cCodFami + cTipMod + cCodSer + cSeqPad )

		While TPH->( !EoF() ) .And. TPH->TPH_FILIAL == FWxFilial( 'TPH' ) .And. TPH->TPH_CODFAM == cCodFami .And.;
			TPH->TPH_TIPMOD == cTipMod .And. TPH->TPH_SERVIC == cCodSer	.And. TPH->TPH_SEQREL == cSeqPad

			dbSelectArea("STH")
			
			RecLock("STH",.T.)
				
				STH->TH_FILIAL  := FWxFilial( 'STH' )
				STH->TH_CODBEM  := cCodBem
				STH->TH_SEQRELA := cSeqRel

				For nInd := 1 TO LEN(aSTH)
					cTPH := aSTH[nInd][2]
					cSTH := aSTH[nInd][1]
					dbSelectArea("TPH")
					&cSTH. := FIELDGET(FIELDPOS(cTPH))
				Next

			MsUnLock("STH")

			If Alltrim(STH->TH_OPCOES) <> "S"
				dbSelectArea("TPC")
				dbSetOrder(1)
				dbSeek(xFilial("TPC")+STH->TH_ETAPA)
				While !Eof() .and. TPC->TPC_ETAPA == STH->TH_ETAPA
					RecLock("TP1",.T.)
					TP1->TP1_FILIAL := xFILIAL("TP1")
					TP1->TP1_CODBEM := STH->TH_CODBEM
					TP1->TP1_SERVIC := STH->TH_SERVICO
					TP1->TP1_SEQREL := STH->TH_SEQRELA
					TP1->TP1_TAREFA := STH->TH_TAREFA
					TP1->TP1_ETAPA  := TPC->TPC_ETAPA
					TP1->TP1_OPCAO  := TPC->TPC_OPCAO
					TP1->TP1_TIPRES := TPC->TPC_TIPRES
					TP1->TP1_CONDOP := TPC->TPC_CONDOP
					TP1->TP1_CONDIN := TPC->TPC_CONDIN
					TP1->TP1_TPMANU := TPC->TPC_TPMANU
					TP1->TP1_TIPCAM := TPC->TPC_TIPCAM
					TP1->TP1_BEMIMN := If(TPC->TPC_PORBEM = 'P',STH->TH_CODBEM,SubStr(TPC->TPC_DESCRI,1,16))
					TP1->TP1_SERVMN := TPC->TPC_SERVIC
					TP1->TP1_BLOQMA := "S"
					TP1->TP1_BLOQFU := "S"
					TP1->TP1_BLOQFE := "S"
					MsUnLock("TP1")
					dbSelectArea("TPC")
					TPC->(dbSkip())
				End
			EndIf
			dbSelectArea("TPH")
			dbSkip()
		End
		
	Endif

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} VLDATAULTM
Valida a data da última manutenção.

@author Elynton Fellipe Bazzo
@since 24/09/13
@version P11
@return .T.
/*/
//--------------------------------------------------------------------
Static Function VLDATAULTM()

	Local dDtUltCon := CtoD("  /  /    ")

	If dData > dDataBase
		CHKHELP("NG080DTINV")//Data informada invalida.//A data informada não pode ser maior que a data atual do sistema.
		Return .F.
	EndIf

	If !Empty(dData) //Se estiver preenchida.
		If (cAliasTmp)->TIPACO  == "S" //Se o Tipo do Acompanhamento for igual a "Seg. Contador".
			dbSelectArea( "TPE" )
			dbSetOrder( 01 ) //TPE_FILIAL+TPE_CODBEM
			dbSeek( xFilial( "TPE" )+ST9->T9_CODBEM )
			dDtUltCon := TPE->TPE_DTULTA //Recebe a Data Ult. Acompanhamento da tabela 'TPE'.
		ElseIf ST9->T9_TEMCONT == "S" .And. (cAliasTmp)->TIPACO <> "T" //Se Tem contador e Tipo do Acompanhamento for diferente de "tempo".
			dDtUltCon := ST9->T9_DTULTAC //Recebe a Data Ult. Acompanhamento da tabela 'ST9'.
		EndIf
		If !Empty(dDtUltCon) .And. dData > dDtUltCon
			MsgStop(If((cAliasTmp)->TIPACO == "S",STR0030,STR0031)+DTOC(dDtUltCon)+" .")
			Return .F.
		EndIf
	EndIf

Return .T.
