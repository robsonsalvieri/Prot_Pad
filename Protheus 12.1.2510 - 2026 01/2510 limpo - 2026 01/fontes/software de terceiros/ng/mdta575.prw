#INCLUDE "MDTA575.ch"
#Include "Protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MDTA575  ³ Autor ³ Jackson Machado       ³ Data ³20/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Cadastro de Agenda de Reuniões                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MDTA575()

	//Armazena variaveis p/ devolucao (NGRIGHTCLICK)
	Local aNGBEGINPRM := NGBEGINPRM()

	If !NGCADICBASE("TKS_CODCJN","A","TKS",.F.)
		If !NGINCOMPDIC("UPDMDT38","TDGQ95")
			Return .F.
		Endif
	Endif

	//---------------------------------------------------------
	// Define Array contendo as Rotinas a executar do programa
	// ----------- Elementos contidos por dimensao ------------
	// 1. Nome a aparecer no cabecalho
	// 2. Nome da Rotina associada
	// 3. Usado pela rotina
	// 4. Tipo de Transa‡„o a ser efetuada
	//    1 - Pesquisa e Posiciona em um Banco de Dados
	//    2 - Simplesmente Mostra os Campos
	//    3 - Inclui registros no Banc0s de Dados
	//    4 - Altera o registro corrente
	//    5 - Remove o registro corrente do Banco de Dados
	//---------------------------------------------------------
	PRIVATE aRotina := MenuDef()

	// Define o cabecalho da tela de atualizacoes
	PRIVATE aCHKDEL := {}, bNGGRAVA := {|| MDT575GRAV(nOpcx)}
	cCadastro := OemtoAnsi(STR0010)  //"Agenda Brigada"


	//aCHKDEL array que verifica a INTEGRIDADE REFERENCIAL na exclu-
	//s„o do registro.
	//
	//1 - Chave de pesquisa
	//2 - Alias de pesquisa
	//3 - ordem de pesquisa
	//aCHKDEL := { {'TKQ->TKQ_BRIGAD + DTOS(TKQ->TKQ_DTREUN) + TKQ->TKQ_HRREUN'    , "TKR", 1}}

	// Endereca a funcaO de BRoWSE
	DbSelectArea("TKQ")
	DbSetorder(1)
	mBrowse( 6, 1,22,75,"TKQ")

	// Devolve variaveis armazenadas (NGRIGHTCLICK)
	NGRETURNPRM(aNGBEGINPRM)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MDT575GRAV ³ Autor ³ Jackson Machado         ³ Data ³20/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava o agendamento da reunião                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MDTA575                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function MDT575GRAV(nOpcx)
Local cOldAlias := Alias()
Local lRet := .t.
Local nOrder := NGRETORDEM("TKQ","TKQ_BRIGAD+DTOS(TKQ_DTREUN)+TKQ_HRREUN",.F.)
Local aWFReun := {}
Local cPesq

//Para caso de ter alterado algum dos campos da chave unica então persiste essas alteracoes na TKR
If nOpcx == 4 .And. ( DtoS(TKQ->TKQ_DTREUN) != DtoS(M->TKQ_DTREUN) .Or. TKQ->TKQ_HRREUN != M->TKQ_HRREUN )

	cPesq := xFilial("TKR")+TKQ->TKQ_BRIGAD+DTOS(TKQ->TKQ_DTREUN)+TKQ->TKQ_HRREUN
	DbSelectArea("TKR")
	DbSetOrder(1)
	If DbSeek(cPesq)

		While DbSeek(cPesq)

			RecLock("TKR",.F.)
			TKR->TKR_DTREUN := M->TKQ_DTREUN
			TKR->TKR_HRREUN := M->TKQ_HRREUN
			MsUnLock("TKR")
			DbSelectArea("TKR")

		EndDo

	EndIf

EndIf

If nOpcx == 3
	If !EXISTCHAV("TKQ",M->TKQ_BRIGAD+DTOS(M->TKQ_DTREUN)+M->TKQ_HRREUN,1)
		lRet := .f.
	Else
		dbSelectArea("TKL")
		dbSetOrder(nOrder)
		If dbSeek(xFilial("TKL")+M->TKQ_BRIGAD)
			If M->TKQ_DTREUN < TKL->TKL_DTVIIN .or. M->TKQ_DTREUN > TKL->TKL_DTVIFI .or. M->TKQ_DTREUN < TKL->TKL_DTVIIN .or. M->TKQ_DTREUN > TKL->TKL_DTVIFI
				MsgInfo(STR0011 + Chr(13) + Chr(10) + ;  //"A Data da Reunião não está no período de vigência da brigada"
						STR0012 + DtoC(TKL->TKL_DTVIIN) + STR0013 + DtoC(TKL->TKL_DTVIFI) )  //"Período de Vigência "###" a "
				lRet := .f.
			Endif
		Endif
	Endif
EndIf
If nOpcx == 5
	If Empty(TKQ->TKQ_DTREAL) .And. Empty(TKQ->TKQ_HRREAL)
	   	dbSelectArea("TKR")
		dbSetOrder(1)
		If dbSeek(xFilial("TKR")+TKQ->TKQ_BRIGAD)
			While !Eof() .and. xFilial("TKR")+TKR->TKR_BRIGAD == xFilial("TKQ")+TKQ->TKQ_BRIGAD
		    	dbSelectArea("SRA")
		    	dbSetOrder(1)
		    	If dbSeek(xFilial("SRA")+TKR->TKR_MAT)
		    		If !Empty(SRA->RA_EMAIL)
						aAdd(aWFReun,{ M->TKQ_DTREUN, M->TKQ_HRREUN, M->TKQ_DURAC,, M->TKQ_ASSUNT, M->TKQ_LOCAL, SRA->RA_EMAIL, SRA->RA_NOME, 3 })
					EndIf
				EndIf
				dbSelectArea("TKR")
				RecLock("TKR",.F.)
				DbDelete()
				MsUnLock("TKR")
				dbSkip()
			End
		EndIf
	Else
		MsgStop(STR0017,STR0018) //"Essa reunião não poderá ser excluída, pois já foi realizada."##"Atenção"
		Return .F.
	EndIf
	If ExistBlock("MDTA5751")
		ExecBlock("MDTA5751",.F.,.F.,{.F.,,,aWFReun})
	EndIf
EndIf

If !Empty(cOldAlias)
	dbSelectArea(cOldAlias)
Endif

Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MD575PA  ³ Autor ³ Jackson Machado       ³ Data ³20/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Cadastro de Participantes                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MD575PA(cAlias, nRecno, nOpcx)
	Local oFont, oGet, oDlg, nX2, nX
	Local nControl 	:= 0
	Local aPages   	:= {}
	Local aTitles  	:= {}
	Local cCadOpt  	:= ""
	Local nBRIGADA 	:= 0
	Local nCODCC	:= 0
	Local lAltProg 	:= .T.
	Local cFilOld 	:= cFilAnt
	Local cFilTKR 	:= xFilial("TKR")

	Private aCols
	Private aCoBrwA := {}
	Private aHoBrwA := {}
	Private oBrwA
	Private lAltInd  := .t.
	Private cCodExp  := 0
	Private cMemoFor := ""
	Private aSvATela := {}, aSvAGets := {}, aTela := {}, aGets := {}, aNao := {}
	Private oMemoFor, oCodVar, oCodExp
	Private oBtn01, oBtn02, oBtn03, oBtn04, oBtn05, oBtn06, oBtnAdd, oBtnLim, oBtnDes, aNoFields
	Private nLenA := 0
	Private oMenu
	Private cFilA575 := cFilAnt

	//Tamanho da tela
	Private aAC 	:= {STR0014,STR0015} //"Abandona"###"Confirma"
	Private aCRA	:= {STR0015,STR0016,STR0014} //"Confirma"###"Redigita"###"Abandona"
	Private aSize 	:= MsAdvSize(,.f.,430), aObjects := {}
	Private aHeader[0], Continua, nUsado :=0

	dbSelectArea("TKQ")
	RegToMemory("TKQ",(nOpcx == 3))

	aCols:={}
	aHeader:={}
	aNoFields:={}

	aAdd(aNoFields,"TKR_BRIGAD")
	aAdd(aNoFields,"TKR_FILIAL")
	aAdd(aNoFields,"TKR_DTREUN")
	aAdd(aNoFields,"TKR_HRREUN")

	nInd	:= 1
	cKeyTPY	:="TKQ->TKQ_BRIGAD+DTOS(TKQ->TKQ_DTREUN)+TKQ->TKQ_HRREUN"
	cGETWHTPB:= "TKR->TKR_FILIAL == '"+xFilial("TKR")+"' .AND. TKR->TKR_BRIGAD == '"+TKQ->TKQ_BRIGAD+"'"+;
					" .AND. DTOS(TKR->TKR_DTREUN) == '"+DTOS(TKQ->TKQ_DTREUN)+"' .AND. TKR->TKR_HRREUN == '"+TKQ->TKQ_HRREUN+"'"
	dbSelectArea("TKR")
	dbSetOrder(nInd)
	FillGetDados( nOpcx, "TKR", nInd, cKeyTPY, {|| }, {|| .T.},aNoFields,,,,;
				{|| NGMontaAcols("TKR",&cKeyTPY,cGETWHTPB)})

	If Empty(aCols) .Or. nOpcx == 3
		aCols :=BLANKGETD(aHeader)
	Endif

	aCoBrwA := ACLONE(aCols)
	aHoBrwA := ACLONE(aHeader)
	nLenA   := Len(aCoBrwA)

	If nOpcx == 2 .or. nOpcx == 5
		lAltProg := .f.
	Endif

	// Inicializa variaveis para campos Memos Virtuais
	If Type("aMemos")=="A"
		For nX2 := 1 To Len(aMemos)
			cMemo := "M->" + aMemos[nX2][2]
			If ExistIni(aMemos[nX2][2])
				&cMemo := InitPad( GetSx3Cache( aMemos[nX2][2], 'X3_RELACAO' ) )
			Else
				&cMemo := ""
			EndIf
		Next nX2
	EndIf

	If nOpcx == 3
		cCadOpt  := " - "+STR0005 //" - Incluir" //"Incluir"
	ElseIf nOpcx == 2
		cCadOpt  := " - "+STR0002 //" - Visualizar" //"Visualizar"
		lAltInd := .f.
	ElseIf nOpcx == 5
		cCadOpt  := " - "+STR0007 //" - Excluir" //"Excluir"
		lAltInd := .f.
	ElseIf nOpcx == 4
		cCadOpt  := " - "+STR0006 //" - Alterar" //"Alterar"
	EndIf

	//aChoice recebe os campos que serao apresentados na tela
	aNao    := {}
	aChoice := NGCAMPNSX3("TKQ",aNao)
	aTela   := {}
	aGets   := {}

	Aadd(aObjects,{045,045,.t.,.t.})
	Aadd(aObjects,{055,055,.t.,.t.})
	aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
	aPosObj := MsObjSize(aInfo, aObjects,.t.)

	nOpca:=0
	DEFINE MSDIALOG oDlg TITLE OemToAnsi(cCadastro+cCadOpt) From aSize[7],0 To aSize[6],aSize[5] COLOR CLR_BLACK,CLR_WHITE OF oMainWnd PIXEL

		oPnlPai := TPanel():New( , , , oDlg , , , , , , , , .F. , .F. )
			oPnlPai:Align := CONTROL_ALIGN_ALLCLIENT

			//Enchoice tabela TKQ
			oEnc01:= MsMGet():New("TKQ",nRecno,2,,,,aChoice,aPosObj[1],,,,,,oPnlPai,,,.f.,"aSvATela")
				oEnc01:oBox:Align := CONTROL_ALIGN_TOP

				oEnc01:oBox:bGotFocus := {|| NgEntraEnc("TKQ")}
				aSvATela := aClone(aTela)
				aSvAGets := aClone(aGets)

				DbSelectArea( "TKR" )
				DbSetOrder( 1 )
				DbSeek( FwxFilial( "TKR" ) + TKQ->TKQ_BRIGAD + DTOS( TKQ->TKQ_DTREUN ) + TKQ->TKQ_HRREUN )

			oBrwA := MsNewGetDados():New(005,005,100,200,IIF(!lAltProg,0,GD_INSERT+GD_UPDATE+GD_DELETE),;
										{|| D575CHK() },{|| .T. },,,,9999,,,,oPnlPai,aHoBrwA,aCoBrwA)
				oBrwA:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

				oBrwA:oBrowse:bChange := {|| fMDT575CHG(Len(oBrwA:aCols)) }
				oBrwA:oBrowse:Refresh()

		//Click da Direita
		If Len(aSMenu) > 0
			NGPOPUP(asMenu,@oMenu)
			oDlg:bRClicked := { |o,x,y| oMenu:Activate(x,y,oDlg)}
			oEnc01:oBox:bRClicked := { |o,x,y| oMenu:Activate(x,y,oDlg)}
		Endif
		cFilAnt := cFilOld
	Activate MsDialog oDlg On Init EnchoiceBar(oDlg,{||nOpca:=1,If(!MDT575TOK(nOpcx),nOpca := 0,oDlg:End())},{||oDlg:End()}) CENTERED

	cFilAnt := cFilTKR

	If nOpca == 1
	A575GRAVA(cAlias,nRecno,nOpcx)
	Endif
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³D575CHK   ³ Autor ³ Jackson Machado       ³ Data ³20/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consiste a existencia de outro codigo na GetDados          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function D575CHK(lFim)

Local f, nQtd := 0
Local aColsOk, aHeadOk, nAt, nPos, nPos1, nPos2, nPos3, nPos4
Default lFim := .F.

aColsOk := aClone(oBrwA:aCols)
aHeadOk := aClone(aHoBrwA)
nAt := oBrwA:nAt
nPOS  := aSCAN( aHoBrwA, { |x| Trim( Upper(x[2]) ) == "TKR_MAT"})
nPos1 := aSCAN( aHoBrwA, { |x| Trim( Upper(x[2]) ) == "TKR_TIPPAR"})
nPos2 := aSCAN( aHoBrwA, { |x| Trim( Upper(x[2]) ) == "TKR_NOME"})
nPos3 := aSCAN( aHoBrwA, { |x| Trim( Upper(x[2]) ) == "TKR_COMPAR"})
nPos4 := aSCAN( aHoBrwA, { |x| Trim( Upper(x[2]) ) == "TKR_FILPAR"})

//Percorre aCols
For f:= 1 to Len(aColsOk)
	If !aColsOk[f][Len(aColsOk[f])]
		nQtd ++
		If lFim .or. f == nAt
			//VerIfica se os campos obrigatórios estão preenchidos
			If Empty(aColsOk[f][nPos1])
				//Mostra mensagem de Help
				Help(1," ","OBRIGAT2",,aHeadOk[nPos1][1],3,0)
				Return .F.
			Else
				If aColsOk[f][nPos1] == "1"
					If nPos > 0 .and. Empty(aColsOk[f][nPos])
						//Mostra mensagem de Help
						Help(1," ","OBRIGAT2",,aHeadOk[nPos][1],3,0)
						Return .F.
					Elseif nPos4 > 0 .and. Empty(aColsOk[f][nPos4])
						//Mostra mensagem de Help
						Help(1," ","OBRIGAT2",,aHeadOk[nPos4][1],3,0)
						Return .F.
					Endif
				Elseif aColsOk[f][nPos1] == "2"
					If nPos2 > 0 .and. Empty(aColsOk[f][nPos2])
						//Mostra mensagem de Help
						Help(1," ","OBRIGAT2",,aHeadOk[nPos2][1],3,0)
						Return .F.
					Endif
				Endif
			Endif
		Endif

		//Verifica se é somente LinhaOk
		If f <> nAt .and. !aColsOk[nAt][Len(aColsOk[nAt])]
			If aColsOk[f][nPos1] == "1"
				If aColsOk[f][nPos] == aColsOk[nAt][nPos]
					Help(" ",1,"JAEXISTINF",,aHeadOk[nPos][1])
					Return .F.
				Endif
			Elseif aColsOk[f][nPos1] == "2"
			 	If AllTrim(aColsOk[f][nPos2]) == AllTrim(aColsOk[nAt][nPos2])
					Help(" ",1,"JAEXISTINF",,aHeadOk[nPos2][1])
					Return .F.
				Endif
			Endif
		Endif
	Endif
Next f

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MDT575AG  ³ Autor ³ Jackson Machado       ³ Data ³20/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Browse das agendas.                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MDT575AG()

	Local aArea	:= GetArea()
	Local oldROTINA := aCLONE(aROTINA)
	Local oldCad := cCadastro
	Local lPyme := Iif(Type("__lPyme") <> "U",__lPyme,.F.)
	Local aNao      := { "TKQ_CLIENT", "TKQ_LOJA", "TKQ_FILIAL"}
	cCliMdtPs := SA1->A1_COD+SA1->A1_LOJA

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Array contendo as Rotinas a executar do programa      ³
	//³ ----------- Elementos contidos por dimensao ------------     ³
	//³ 1. Nome a aparecer no cabecalho                              ³
	//³ 2. Nome da Rotina associada                                  ³
	//³ 3. Usado pela rotina                                         ³
	//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
	//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
	//³    2 - Simplesmente Mostra os Campos                         ³
	//³    3 - Inclui registros no Banc0s de Dados                   ³
	//³    4 - Altera o registro corrente                            ³
	//³    5 - Remove o registro corrente do Banco de Dados          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aRotina :=	{ { STR0003 , "AxPesqui"  , 0 , 1},; //"Pesquisar"
						{ STR0002 , "MDT575INC" , 0 , 2},;  //"Visualizar"
						{ STR0005 , "MDT575INC" , 0 , 3},; //"Incluir"
						{ STR0006 , "MDT575INC" , 0 , 4},;  //"Alterar"
						{ STR0007 , "MDT575INC" , 0 , 5, 3},;  //"Excluir"
						{ STR0008 , "MD575PA"   , 0 , 6, 3} } //"Participantes"

	If !lPyme
		AAdd( aRotina, { STR0009, "MsDocument", 0, 4 } )   //"Conhecimento"
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define o cabecalho da tela de atualizacoes                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private cCadastro := OemtoAnsi(STR0010)  //"Agenda Brigada"
	Private aCHKDEL := {}, bNGGRAVA := {|| MDT575GRAV(nOpcx)}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³aCHKDEL array que verifica a INTEGRIDADE REFERENCIAL na exclu-³
	//³s„o do registro.                                              ³
	//³                                                              ³
	//³1 - Chave de pesquisa                                         ³
	//³2 - Alias de pesquisa                                         ³
	//³3 - ordem de pesquisa                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//aCHKDEL := { {'cCliMdtps + TKQ->TKQ_BRIGAD + DTOS(TKQ->TKQ_DTREUN) + TKQ->TKQ_HRREUN', "TKR", 3}}

	aCHOICE := {}

	aCHOICE := NGCAMPNSX3( 'TKQ' , aNao )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcaO de BRoWSE                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("TKQ")
	Set Filter To TKQ->(TKQ_CLIENT+TKQ_LOJA) == cCliMdtps
	DbSetorder(1)
	mBrowse( 6, 1,22,75,"TKQ")

	DbSelectArea("TKQ")
	Set Filter To

	aROTINA := aCLONE(oldROTINA)
	RestArea(aArea)
	cCadastro := oldCad

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MDT575INC ³ Autor ³Jackson Machado        ³ Data ³20/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Inclui, altera e exclui Agendas de Reuniao.                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/

Function MDT575INC(cAlias,nRecno,nOpcx)

	Local aArea := GetArea()

	bNGGRAVA := {|| MDT575GRAV(nOpcx)}

	NGCAD01(cAlias,nRecno,nOpcx)

	bNGGRAVA := {}

	RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MDT575FLVL Autor  ³Jackson Machado        ³ Data ³20/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida filial dos campos relacionados a tabela SRA         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function MDT575FLVL(cTKR_FILMAT)
Local aArea    := GetArea()
Local aAreaSM0 := SM0->(GetArea())
Local lRet     := .T.
Local nPOS     := aSCAN( aHoBrwA, { |x| Trim( Upper(x[2]) ) == "TKR_MAT"})
Local nPOS2    := aSCAN( aHoBrwA, { |x| Trim( Upper(x[2]) ) == "TKR_NOME"})

dbSelectArea("SM0")
IF !dbSeek(cEmpAnt+cTKR_FILMAT)
	Help(" ",1,"REGNOIS")
	lRet := .F.
Else
	cFilAnt := cTKR_FILMAT
    dbSelectArea("SRA")
	dbSetOrder(01)
	If !dbSeek(xFilial("SRA",cFilAnt)+ aCols[n,nPOS] )
		aCols[n,nPOS] := Space( Len(SRA->RA_MAT) )
		aCols[n,nPOS2] := " "
	Else
		aCols[n,nPOS2] := SRA->RA_NOME
	Endif
EndIF

RestArea(aAreaSM0)
RestArea(aArea)
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MDT575TOK ³ Autor ³Jackson Machado        ³ Data ³20/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Critica se a getdados esta OK                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MDT575TOK(nOpcx)

aCoBrwA := aClone(oBrwA:aCols)

If nOpcx !=2 .and. nOpcx !=5
	If !D575CHK(.T.)
		Return .F.
	Endif
Endif

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MDT575CHKE³ Autor ³ Jackson Machado       ³ Data ³20/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida campos 					                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Campos    ³ cTabelaP -> Tabela de Pesquisa							  ³±±
±±³          ³ cCampo -> Campo de Pesquisa								  ³±±
±±³          ³ cCampo -> Campo da Tabela de Pesquisa no Dicionário        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MDT575CHKE(cTabelaP,cCampo,cCampoO)
Local nOrder := 1

If NGRETORDEM(cTabelaP,cTabelaP+"_FILIAL+"+SUBSTR(cCampoO,6),.F.) > 0
	nOrder := NGRETORDEM(cTabelaP,cTabelaP+"_FILIAL+"+SUBSTR(cCampoO,6),.F.)
Endif
If Empty(&(cCampo))
	Return .T.
Endif
Return EXISTCPO(cTabelaP,&(cCampo),nOrder)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A575GRAVA ³ Autor ³ Jackson Machado       ³ Data ³20/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao chamada para gravacao                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A575GRAVA(cAliasX,nRecnoX,nOpcx)
Local i, j, ny
Local aArea := GetArea()
Local nOrd, cKey, cWhile, cVac, cKey2
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Manipula a tabela TKR³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPosCod := aScan( aHoBrwA,{|x| Trim(Upper(x[2])) == "TKR_MAT"})
nPosNom := aScan( aHoBrwA,{|x| Trim(Upper(x[2])) == "TKR_NOME"})
nPosTip := aScan( aHoBrwA,{|x| Trim(Upper(x[2])) == "TKR_TIPPAR"})
nOrd 	:= 1
cKey 	:= xFilial("TKR")+M->TKQ_BRIGAD+DTOS(M->TKQ_DTREUN)+M->TKQ_HRREUN
cWhile:= "xFilial('TKR')+M->TKQ_BRIGAD+DTOS(M->TKQ_DTREUN)+M->TKQ_HRREUN == TKR->TKR_FILIAL+TKR->TKR_BRIGAD+DTOS(TKR->TKR_DTREUN)+TKR->TKR_HRREUN"
If nOpcx == 5
	dbSelectArea("TKR")
	dbSetOrder(nOrd)
	dbSeek(cKey)
	While !Eof() .and. &(cWhile)
		RecLock("TKR",.f.)
		DbDelete()
		MsUnLock("TKR")
		dbSelectArea("TKR")
		dbSkip()
	End
Else
	If Len(aCoBrwA) > 0
		aSORT(aCoBrwA,,, { |x, y| x[Len(aCoBrwA[1])] .and. !y[Len(aCoBrwA[1])] } )
	   	If ExistBlock("MDTA5751")
 			ExecBlock("MDTA5751",.F.,.F.,{.T.,aCoBrwA,aHoBrwA})
		EndIf

		For i:=1 to Len(aCoBrwA)
			If !aCoBrwA[i][Len(aCoBrwA[i])] .and. (!Empty(aCoBrwA[i][nPosCod]) .AND. aCoBrwA[i][nPosTip] = '1') .or. ;
															  ( Empty(aCoBrwA[i][nPosCod]) .AND. aCoBrwA[i][nPosTip] = '2')
				If aCoBrwA[i][nPosTip] = '1'
					nOrd := 1
					nPos := nPosCod
				Elseif aCoBrwA[i][nPosTip] = '2'
					nOrd := 2
					nPos := nPosNom
				Endif
				dbSelectArea("TKR")
				dbSetOrder(nOrd)
				If dbSeek(xFilial("TKR")+M->TKQ_BRIGAD+DTOS(M->TKQ_DTREUN)+M->TKQ_HRREUN+aCoBrwA[i][nPos])
					RecLock("TKR",.F.)
				Else
					RecLock("TKR",.T.)
				Endif
				For j:=1 to FCount()
					If "_FILIAL"$Upper(FieldName(j))
						FieldPut(j, xFilial("TKR"))
					ElseIf "_BRIGAD"$Upper(FieldName(j))
						FieldPut(j, M->TKQ_BRIGAD)
					ElseIf "_DTREUN"$Upper(FieldName(j))
						FieldPut(j, DTOS(M->TKQ_DTREUN))
					ElseIF "_HRREUN"$Upper(FieldName(j))
						FieldPut(j, M->TKQ_HRREUN)
					ElseIf (nPos := aScan(aHoBrwA, {|x| Trim(Upper(x[2])) == Trim(Upper(FieldName(j))) }) ) > 0
						FieldPut(j, aCoBrwA[i][nPos])
					Endif
				Next j
				MsUnlock("TKR")
			Elseif (!Empty(aCoBrwA[i][nPosCod]) .AND. aCoBrwA[i][nPosTip] = '1') .or. ;
					 ( Empty(aCoBrwA[i][nPosCod]) .AND. aCoBrwA[i][nPosTip] = '2' .AND. !Empty(aCoBrwA[i][nPosNom]))
				If aCoBrwA[i][nPosTip] = '1'
					nOrd := 1
					nPos := nPosCod
				Elseif aCoBrwA[i][nPosTip] = '2'
					nOrd := 2
					nPos := nPosNom
				Endif
				dbSelectArea("TKR")
				dbSetOrder(nOrd)
				If dbSeek(xFilial("TKR")+M->TKQ_BRIGAD+DTOS(M->TKQ_DTREUN)+M->TKQ_HRREUN+aCoBrwA[i][nPos])
					RecLock("TKR",.F.)
					dbDelete()
					MsUnlock("TKR")
				Endif
			Endif
		Next i
	Endif
	dbSelectArea("TKR")
	dbSetOrder(nOrd)
	dbSeek(cKey)
	While !Eof() .and. &(cWhile) //  xFilial("TKR")+M->TKQ_BRIGAD+DTOS(M->TKQ_DTREUN)+M->TKQ_HRREUN == TKR->TKR_FILIAL+TKR->TKR_BRIGAD+DTOS(TKR->TKR_DTREUN)+TKR->TKR_HRREUN
		If TKR->TKR_TIPPAR == '1'
			If aScan( aCoBrwA,{|x| x[nPosCod] == TKR->TKR_MAT .AND. !x[Len(x)]}) == 0
				RecLock("TKR",.f.)
				DbDelete()
				MsUnLock("TKR")
			Endif
		Elseif TKR->TKR_TIPPAR == '2'
			If aScan( aCoBrwA,{|x| x[nPosNom] == TKR->TKR_NOME .AND. !x[Len(x)]}) == 0
				RecLock("TKR",.f.)
				DbDelete()
				MsUnLock("TKR")
			Endif
		Endif
		dbSelectArea("TKR")
		dbSkip()
	End

Endif


Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |MDT575WHEN³ Autor ³ Jackson Machado       ³ Data ³20/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ When dos campos				                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MDT575WHEN(cCampo)
Local lRet := .F.
Local aCols := aClone(oBrwA:aCols)
Local n  := oBrwA:nAt
Local aHeader := aClone(oBrwA:aHeader)
Local nPos := GDFIELDPOS(cCampo,aHeader)
Local nPos2 := GDFIELDPOS("TKR_TIPPAR",aHeader)
Default cCampo := ""

If cCampo == "TKR_FILPAR"
	If !Empty(aCols[n][nPos2]) .AND. aCols[n][nPos2] == '1'
		lRet := .T.
	Else
		aCols[n][nPos] := Space(TAMSX3("TKR_FILPAR")[1])
	Endif
ElseIf cCampo == "TKR_MAT"
	If !Empty(aCols[n][nPos2]) .AND. aCols[n][nPos2] == '1'
		lRet := .T.
	Else
		aCols[n][nPos] := Space(TAMSX3("TKR_MAT")[1])
	Endif
ElseIf cCampo == "TKR_NOME"
	If !Empty(aCols[n][nPos2]) .AND. aCols[n][nPos2] == '2'
		lRet := .T.
	Endif
Endif

/*oBrwA:aCols := aClone(aCols)
oBrwA:oBrowse:Refresh()*/
Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |MDT575VAL | Autor ³ Jackson Machado       ³ Data ³20/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valid dos campos				                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MDT575VAL()
Local aCols := oBrwA:aCols
Local n  := oBrwA:nAt
Local aHeader := oBrwA:aHeader
Local nPos := GDFIELDPOS("TKR_MAT",aHeader)
Local nPos1 := GDFIELDPOS("TKR_NOME",aHeader)
Local nPos2 := GDFIELDPOS("TKR_FILPAR",aHeader)

If M->TKR_TIPPAR == "1" .AND. Empty(aCols[n][nPos1]) .AND. !Empty(aCols[n][nPos2])
	aCols[n][nPos1] := Space(TAMSX3("TKR_NOME")[1])
Elseif M->TKR_TIPPAR == "2"
	aCols[n][nPos2] := Space(TAMSX3("TKR_FILPAR")[1])
	If !Empty(aCols[n][nPos])
		aCols[n][nPos] := Space(TAMSX3("TKR_MAT")[1])
		aCols[n][nPos1] := Space(TAMSX3("TKR_NOME")[1])
	Endif
Endif
oBrwA:aCols := aCols
aCoBrwA := aCols
oBrwA:oBrowse:Refresh()
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fMDT575CHG|Autor  ³ Jackson Machado       ³ Data ³ 27/05/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao executa ao mudar de linha na Getdados               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function fMDT575CHG(n)
Local nPOS1 := aSCAN( oBrwA:aHeader, { |x| Trim( Upper(x[2]) ) == "TKR_FILPAR"})
cFilAnt := oBrwA:aCols[n,nPos1]
Return .t.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fMDT575CHG|Autor  ³ Jackson Machado       ³ Data ³ 27/05/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao executa ao mudar de linha na Getdados               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function MenuDef()
	Local lPyme := Iif(Type("__lPyme") <> "U",__lPyme,.F.)
	Local aRotina :={ 	{ STR0003 , "AxPesqui", 0 , 1		},;  	//"Pesquisar"
						{ STR0002 , "MDT575INC" , 0 , 2		},;  	//"Visualizar"
						{ STR0005 , "MDT575INC" , 0 , 3		},;  	//"Incluir"
						{ STR0006 , "MDT575INC" , 0 , 4		},;  	//"Alterar"
						{ STR0007 , "MDT575INC" , 0 , 5, 3	},; 	//"Excluir"
						{ STR0008 , "MD575PA"   , 0 , 6, 3	} }  	//"Participantes"


	If !lPyme
		AAdd( aRotina, { STR0009, "MsDocument", 0, 4 } )   //"Conhecimento"
	EndIf

Return aRotina
