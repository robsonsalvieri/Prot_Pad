#INCLUDE 'DLGA010.CH'
#INCLUDE 'FIVEWIN.CH'
#DEFINE MAXGETDAD 4096
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ DLGA010  ³ Autor ³ Equipe ABPL           ³ Data ³02.12.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastro de Unitizadores                                   ³±±
±±³          ³                                                            ³±±
±±³          ³ Unitizadores sao estruturas que comportam o produto,       ³±±
±±³          ³ considerando sua largura, comprimento, altura, capacidade  ³±±
±±³          ³ de carga e quantidade maxima para empilhamento. O cadastro ³±±
±±³          ³ sera feito a partir do volume ou relacionando os           ³±±
±±³          ³ unitizadores com o limite de altura.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DLGA010()

Private aTELA[0][0]
Private aGETS[0]
Private bCampo1    := {|nCPO| Field(nCPO)}
Private cCadastro  := OemToAnsi(STR0006) //'Cadastro de Unitizadores'

If AmIIn(39,42,43) //-- Somente autorizado para OMS, WMS e TMS
	//--- Menu Funcional
	Private aRotina := MenuDef()
	mBrowse( 6, 1, 22, 75, 'DC1')
	//--- Recupera a Integridade dos dados
	MsUnLockAll()
EndIf
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DLGA010   ºAutor  ³Microsiga           º Data ³  08/04/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DLA010Manu(cAlias, nReg, nOpc)

Local aSize      := {}
Local aInfo      := {}
Local aObjects   := {}
Local aPosObj    := {}
Local cSeekDCO   := ''
Local lInit      := .F.
Local nOpca      := 0
Local nUsado     := 0
Local nX         := 0
Local oDlg
Local cWhile     := ''
Local aNoFields  := {'DCO_UNITIZ'}
Local aColsCop   := {}
Local l010Visual := .F.
Local l010Inclui := .F.
Local l010Altera := .F.
Local l010Deleta := .F.

Private aTELA[0][0]
Private aGETS[0]
Private aButtons   := {}
Private nPosAtu    := 0
Private nPosAnt    := 9999
Private nColAnt    := 9999
Private cArqF3     := ''
Private cCampoF3   := ''
Private nOpcRot    := nOpc
Private aHeader    := {}
Private aCols      := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 2
	l010Visual  := .T.
ElseIf nOpc == 3
	l010Inclui	:= .T.
ElseIf nOpc == 4
	l010Altera	:= .T.
ElseIf nOpc == 5
	l010Deleta	:= .T.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Joga para memoria os campos do Cadastro Sintetico de unitizadores ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea('DC1')
For nX := 1 To fCount()
	If l010Inclui //-- Inclusao
		M->&(Eval(bCampo1,nX)) := FieldGet(nX)
		lInit := .F.
		If ExistIni(Eval(bCampo1, nX))
			lInit := .T.
			M->&(Eval(bCampo1, nX)) := InitPad(GetSx3Cache(Eval(bCampo1, nX), "X3_RELACAO"))
			If ValType(M->&(Eval(bCampo1,nX))) == 'C'
				M->&(Eval(bCampo1, nX)) := PadR(M->&(Eval(bCampo1,nX)), GetSx3Cache(Eval(bCampo1, nX), "X3_TAMANHO"))
			Endif
			If M->&(Eval(bCampo1, nX)) == Nil
				lInit := .F.
			EndIf
		EndIf
		If !lInit
			IF ValType(M->&(Eval(bCampo1, nX))) == 'C'
				M->&(Eval(bCampo1, nX)) := Space(LEN(M->&(Eval(bCampo1,nX))))
			ElseIf ValType(M->&(Eval(bCampo1, nX))) == 'N'
				M->&(Eval(bCampo1, nX)) := 0
			ElseIf ValType(M->&(Eval(bCampo1, nX))) == 'D'
				M->&(Eval(bCampo1, nX)) := CtoD('  /  /  ')
			ElseIf ValType(M->&(Eval(bCampo1, nX))) == 'L'
				M->&(Eval(bCampo1, nX)) := .F.
			ENDIF
		EndIf
	Else
		M->&(Eval(bCampo1, nX)) := FieldGet(nX)
	EndIf
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do AHEADER e ACOLS para GetDados ref. ao Cadastro Analitico de Unitizadores ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If l010Inclui
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Sintaxe da FillGetDados(/*nOpcX*/,/*Alias*/,/*nOrdem*/,/*cSeek*/,/*bSeekWhile*/,/*uSeekFor*/,/*aNoFields*/,/*aYesFields*/,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/,/*lEmpty*/,/*aHeaderAux*/,/*aColsAux*/,/*bAfterCols*/) |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	FillGetDados(nOpc,'DCO',1,,,,aNoFields,,,,,.T.,,,)
Else

	cSeekDCO := xFilial('DCO')+DC1->DC1_CODUNI
	cWhile := 'DCO->DCO_FILIAL+DCO->DCO_UNITIZ'

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Sintaxe da FillGetDados(/*nOpcX*/,/*Alias*/,/*nOrdem*/,/*cSeek*/,/*bSeekWhile*/,/*uSeekFor*/,/*aNoFields*/,/*aYesFields*/,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/,/*lEmpty*/,/*aHeaderAux*/,/*aColsAux*/,/*bAfterCols*/) |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	FillGetDados(nOpc,'DCO',1,cSeekDCO,{|| &cWhile },,aNoFields,,,,,,,,)
EndIf

If !INCLUI
	aColsCop := aClone(aCols)
EndIf

aAdd(aObjects, {100, 090, .T., .F.}) // Indica dimensoes x e y e indica que redimensiona x e y e assume que retorno sera em linha final coluna final (.F.)
aAdd(aObjects, {100, 100, .T., .T.}) // Indica dimensoes x e y e indica que redimensiona x e y
aSize   := MsAdvSize()
aInfo   := {aSize[1], aSize[2], aSize[3], aSize[4], 3, 3}
aPosObj := MsObjSize(aInfo, aObjects)
Do While .T.
	nOpca := 0
	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	EnChoice('DC1', nReg, nOpc,,,,, aPosObj[1],, 3,,, 'DLA010TdOk()')
	oGet := MSGetDados():New(aPosObj[2, 1], aPosObj[2, 2], aPosObj[2, 3], aPosObj[2, 4], nOpc, 'DLA010LiOK()', 'DLA010TdOk()', '', .T.,,,,MAXGETDAD,'DLA010C')
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1, If(oGet:TudoOk(), oDlg:End(), nOpca:=0)}, {||oDlg:End()},, aButtons)
	If nOpca == 1
		If !Obrigatorio(aGets, aTela)
			Loop
		Else
			Exit
		EndIf
	Else
		Exit
	EndIf
EndDo

If nOpcA == 1 .And. !l010Visual
	If !(l010Deleta) .Or. (l010Deleta .And. DLGA010DEL())//-- Exclusao
		Begin Transaction
			DLA010Grv(cAlias, aCols, nReg, nOpc, aColsCop)
			EvalTrigger() //-- Processa Gatilhos
		End Transaction
	EndIf	
ElseIf __lSX8
	RollBackSX8()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a integridade da janela                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAlias)

Return nOpca

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DLA010LiOKºAutor  ³Microsiga           º Data ³  08/04/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DLA010LiOK(nLinha)

Local lTudoOk    := !(nLinha==Nil)
Local lRet       := .T.
Local nX         := 0
Local nPosCodAna := aScan(aHeader,{|x| Upper(Alltrim(x[2])) == 'DCO_CODANA'})
Local nPosDIni   := aScan(aHeader,{|x| Upper(Alltrim(x[2])) == 'DCO_DTINI' })
Local nPosHIni   := aScan(aHeader,{|x| Upper(Alltrim(x[2])) == 'DCO_HRINI' })
Local nPosDFim   := aScan(aHeader,{|x| Upper(Alltrim(x[2])) == 'DCO_DTFIM' })
Local nPosHFim   := aScan(aHeader,{|x| Upper(Alltrim(x[2])) == 'DCO_HRFIM' })
Local nPosEnder  := aScan(aHeader,{|x| Upper(Alltrim(x[2])) == 'DCO_ENDER' })

Default nLinha     := n

If !aCols[nLinha,Len(aCols[nLinha])]
	lRet := AtVldHora(aCols[nLinha, nPosHIni])
	If lRet
		lRet := Empty(aCols[nLinha, nPosDFim]) .Or. aCols[nLinha, nPosDFim] >= aCols[nLinha, nPosDIni]
	EndIf
	If lRet
		lRet := Empty(aCols[nLinha, nPosHFim]) .Or. AtVldHora(aCols[nLinha, nPosHFim])
	EndIf
	If lRet
		lRet := Empty(aCols[nLinha, nPosEnder]) .Or. ExistCPO('SBE', aCols[nLinha, nPosEnder], 9)
	EndIf
	If lRet .And. nLinha > 1 .And. Empty(aCols[nLinha, nPosCodAna])
		Help(' ', 1, 'DCO_CODANA')
		lRet := .F.
	EndIf
	If lRet .And. !lTudoOk .And. !Empty(aCols[nLinha, nPosCodAna])
		For nX := 1 to Len(aCols)
			If !aCols[nX,Len(aCols[nX])] .And. !(nX==nLinha) .And. aCols[nX, nPosCodAna]==aCols[nLinha, nPosCodAna]
				Aviso(STR0007, STR0008, {'Ok'}) //'Atencao'###'O Codigo Analitico informado ja existe.'
				lRet := .F.
				Exit
			EndIf
		Next nX
	EndIf
EndIf
If	lRet
	If	ExistBlock("DL010LOK")
		lRet := ExecBlock("DL010LOK",.F.,.F.)
		lRet := If(ValType(lRet)=="L",lRet,.T.)
	EndIf
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DLA010TdOkºAutor  ³Microsiga           º Data ³  08/04/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DLA010TdOk()

Local lRet       := .T.
Local nX         := 0
Local nLinhas    := 0
Local nPosCodAna := aScan(aHeader,{|x| Upper(Alltrim(x[2])) == 'DCO_CODANA'})

For nX := 1 to Len(aCols)
	If !aCols[nX,Len(aCols[nX])]
		lRet := DLA010LiOK(nX)	
		If !Empty(aCols[nX, nPosCodAna])
			nLinhas ++
		EndIf
	EndIf
	If !lRet
		Exit
	EndIf
Next nX

If lRet .And. nLinhas > M->DC1_QUANT
	Aviso(STR0007, STR0009, {'Ok'}) //'Atencao'###'O Numero de Linhas nao pode exceder a Quantidade de Unitizadores Existentes (DC1_QUANT)'
	lRet := .F.
EndIf
If	lRet
	If	ExistBlock("DL010TOK")
		lRet := ExecBlock("DL010TOK",.F.,.F.)
		lRet := If(ValType(lRet)=="L",lRet,.T.)
	EndIf
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ DLA010Grv³ Autor ³ Microsiga             ³ Data ³ 03/02/93 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava dados dos recursos                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLA010Grv(ExpC1,ExpA1,ExpN1)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do Arquivo                                   ³±±
±±³          ³ ExpA1 = Array com Recursos Alternativos/Secundarios        ³±±
±±³          ³ ExpN1 = Registro a ser alterado do SH1                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA610                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DLA010Grv(cAlias, aCols, nReg, nOpc, aColsCop)
Local aAreaAnt   := GetArea()
Local aAreaDCO   := DCO->(GetArea())
Local nX         := 0
Local nPosCodAna := aScan(aHeader,{|x| Upper(Alltrim(x[2])) == 'DCO_CODANA'})
Local nPosSta    := aScan(aHeader,{|x| Upper(Alltrim(x[2])) == 'DCO_STATUS'})
Local nPosDIni   := aScan(aHeader,{|x| Upper(Alltrim(x[2])) == 'DCO_DTINI' })
Local nPosHIni   := aScan(aHeader,{|x| Upper(Alltrim(x[2])) == 'DCO_HRINI' })
Local nPosDFim   := aScan(aHeader,{|x| Upper(Alltrim(x[2])) == 'DCO_DTFIM' })
Local nPosHFim   := aScan(aHeader,{|x| Upper(Alltrim(x[2])) == 'DCO_HRFIM' })
Local nPosLocal  := aScan(aHeader,{|x| Upper(Alltrim(x[2])) == 'DCO_LOCAL' })
Local nPosEnder  := aScan(aHeader,{|x| Upper(Alltrim(x[2])) == 'DCO_ENDER' })
Local nPosObs    := aScan(aHeader,{|x| Upper(Alltrim(x[2])) == 'DCO_OBS'   })
Local nPosFilBas := aScan(aHeader,{|x| Upper(Alltrim(x[2])) == 'DCO_FILBAS'})
Local lUnitiz 	  := FindFunction('TmsChkVer') .And. TmsChkVer('11','R7')


//--- Ponto de Entrada Antes da gravacao
If	ExistBlock("DL010ANT")
	ExecBlock("DL010ANT",.F.,.F.,{nOpc})
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Realiza a inclusao Sintetica no DC1 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAlias)
If INCLUI
	RecLock(cAlias, .T.)
Else
	dbGoto(nReg)
	RecLock(cAlias, .F.)
EndIf

If INCLUI .Or. ALTERA
	For nX := 1 To fCount()
		If 'FILIAL'$Upper(Field(nX))
			FieldPut(nX, xFilial(cAlias))
		Else
			FieldPut(nX, M->&(Eval(bCampo1,nX)))
		EndIf
	Next nX
Else
	dbDelete()
EndIf
MsUnlock()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Realiza a inclusao Analitica no DCO ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If INCLUI
	For nX:=1 To Len(aCols)
		If !(aCols[nX, Len(aCols[nX])]) .And. !Empty(aCols[nX, nPosCodAna])
			RecLock('DCO', .T.)
			Replace DCO_FILIAL With xFilial('DCO')
			Replace DCO_UNITIZ With M->DC1_CODUNI
			Replace DCO_CODANA With aCols[nX, nPosCodAna]
			Replace DCO_STATUS With aCols[nX, nPosSta]
			Replace DCO_DTINI  With aCols[nX, nPosDIni]
			Replace DCO_HRINI  With aCols[nX, nPosHIni]
			Replace DCO_DTFIM  With aCols[nX, nPosDFim]
			Replace DCO_HRFIM  With aCols[nX, nPosHFim]
			Replace DCO_LOCAL  With aCols[nX, nPosLocal]
			Replace DCO_ENDER  With aCols[nX, nPosEnder]
			If lUnitiz 
				Replace DCO_FILBAS With aCols[nX, nPosFilBas]
			EndIf
			MsUnlock()
			MSMM(DCO->DCO_CODOBS, TamSx3('DCO_OBS')[1],, aCols[nX, nPosObs], 1,,, 'DCO', 'DCO_CODOBS')
		EndIf
	Next nX
Else
	dbSelectArea('DCO')
	dbSetOrder(1)
	For nX := 1 To Len(aCols)
		If MSSeek(xFilial('DCO')+M->DC1_CODUNI+aCols[nX, nPosCodAna])
			If !ALTERA .Or. GdDeleted(nX) //-- Se estiver Deletado, Deleta tambem do arquivo
				RecLock('DCO', .F., .T.)
				dbDelete()
				MsUnLock()
			Else
				RecLock('DCO', .F.)
				Replace DCO_CODANA With aCols[nX, nPosCodAna]
				Replace DCO_STATUS With aCols[nX, nPosSta]
				Replace DCO_DTINI  With aCols[nX, nPosDIni]
				Replace DCO_HRINI  With aCols[nX, nPosHIni]
				Replace DCO_DTFIM  With aCols[nX, nPosDFim]
				Replace DCO_HRFIM  With aCols[nX, nPosHFim]
				Replace DCO_LOCAL  With aCols[nX, nPosLocal]
				Replace DCO_ENDER  With aCols[nX, nPosEnder]
				If lUnitiz
					Replace DCO_FILBAS With aCols[nX, nPosFilBas]
				EndIf
				MSMM(DCO->DCO_CODOBS, TamSx3('DCO_OBS')[1],, aCols[nX, nPosObs], 1,,, 'DCO', 'DCO_CODOBS')
				MsUnlock()
			EndIf
		ElseIf !Empty(aCols[nX, nPosCodAna]) .And. !GdDeleted(nX) //!aCols[nX, Len(aCols[nX])]
			RecLock('DCO', .T.)
			Replace DCO_FILIAL With xFilial('DCO')
			Replace DCO_UNITIZ With M->DC1_CODUNI
			Replace DCO_CODANA With aCols[nX, nPosCodAna]
			Replace DCO_STATUS With aCols[nX, nPosSta]
			Replace DCO_DTINI  With aCols[nX, nPosDIni]
			Replace DCO_HRINI  With aCols[nX, nPosHIni]
			Replace DCO_DTFIM  With aCols[nX, nPosDFim]
			Replace DCO_HRFIM  With aCols[nX, nPosHFim]
			Replace DCO_LOCAL  With aCols[nX, nPosLocal]
			Replace DCO_ENDER  With aCols[nX, nPosEnder]
			If lUnitiz
				Replace DCO_FILBAS  With aCols[nX, nPosFilBas]
			EndIf
			MSMM(DCO->DCO_CODOBS, TamSx3('DCO_OBS')[1],, aCols[nX, nPosObs], 1,,, 'DCO', 'DCO_CODOBS')
			MsUnlock()
		EndIf
	Next nX
Endif

If INCLUI .Or. ALTERA
	If __lSX8
		ConfirmSX8()
	EndIf
EndIf

//--- Ponto de Entrada Apos gravacao
If	ExistBlock("DL010GRV")
	ExecBlock("DL010GRV",.F.,.F.,{nOpc})
EndIf

RestArea(aAreaDCO)
RestArea(aAreaAnt)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³DLGA010Del³ Autor ³Equipe ABPL            ³ Data ³02.12.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao da Delecao do Unitizador                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLGA010Del()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1 -> .T. -> Deleta / .F. -> Nao Deleta                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ DLGA010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DLGA010DEL()

Local lRet       := .T.

#IFDEF TOP
	Local cQuery     := ""
#ELSE
	Local cCondicao  := ""
	Local cKey       := ""
	Local cIndDA3    := ""
	Local nIndDA3    := 0
#ENDIF

DC2->(dbSetOrder(3))
If DC2->(MsSeek(xFilial('DC2')+DC1->DC1_CODUNI, .F.))
	Help(' ',1,'DLGA010H01')
	lRet := .F.
Endif

If lRet .And. Select('DA3') > 0
	#IFDEF TOP
		cQuery := "SELECT COUNT(*) QTDUNI "
		cQuery += " FROM " + RetSqlName("DA3")+ " DA3 "
		cQuery += " WHERE "
		cQuery += " DA3_FILIAL = '"+xFilial("DA3")+"' AND "
		cQuery += " DA3_UNITIZ = '"+DC1->DC1_CODUNI+"' AND "
		cQuery += " DA3.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRYVAL",.F.,.T.)
		lQuery := .T.
		If QRYVAL->QTDUNI > 0
			Help(" ",1,"NODELETA") //Nao e possivel excluir o ajudante pois o mesmo encontras-se relacionado a outros cadastro ### INCLUIR ATUSX
			lRet := .F.
		Endif
		dbSelectArea("QRYVAL")
		dbCloseArea()
	#ELSE
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Filtro pedidos liberados e com carga³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("DA3")
		dbSetOrder(1)
		cIndDA3 := CriaTrab(NIL,.F.)

		cKey := IndexKey()
		cCondicao := 'DA3_FILIAL == "'+xFilial("DA3")+'" .And.'
		cCondicao += 'DA3_UNITIZ == "'+DC1->DC1_CODUNI+'"'

		IndRegua("DA3",cIndDA3,cKey,,cCondicao) //"Selecionando Registros ..."
		nIndDA3 := RetIndex("DA3")

		dbSetIndex(cIndDA3+OrdBagExT())
		dbSetOrder(nIndDA3+1)
		dbGotop()

		If DA3->(!Eof())
			Help(" ",1,"NODELETA") //Nao e possivel excluir o ajudante pois o mesmo encontras-se relacionado a outros cadastro ### INCLUIR ATUSX
			lRet := .F.
		Endif

		dbSelectArea("DA3")
		dbClearFilter()
		RetIndex("DA3")
		Ferase(cIndDA3+OrdBagExt())
	#ENDIF
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DLA010C   ºAutor  ³Microsiga           º Data ³  09/24/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DLA010C(cCampo, cOrigem)

Local cCont      := ''
Local nX         := 0
Local lRet       := .T.
Local nPosCodAna := aScan(aHeader,{|x| Upper(Alltrim(x[2])) == 'DCO_CODANA'})

Default cCampo     := ReadVar()
Default cOrigem    := ''

If 'DCO_CODANA' $cCampo 
	cCont := &(cCampo)
	If !Empty(cCont)
		For nX := 1 to Len(aCols)
			If !aCols[nX,Len(aCols[nX])] .And. !(nX==n) .And. aCols[nX, nPosCodAna]==cCont
				Aviso(STR0007, STR0008, {'Ok'}) //'Atencao'###'O Codigo Analitico informado ja existe.'
				lRet := .F.
				Exit
			EndIf
		Next nX
	EndIf
EndIf

Return lRet

//===========================================================================================================
/* Atualiza Status dos Unitizadores Analiticos 
@author  	Leandro Paulino
@Parametros ExpN1 = Operacao (1=Carregamento;2=Saida Viagem;3=Chegada Viagem)
	         ExpC1 = Cod.do Unitizador
	         ExpC2 = Codigo do Unitizador Analitico                                 
@version 	P11 R11.80 
@build		700120420A
@since 	30/01/2013    
@return 	aRotina - Array com as opçoes de Menu */
//===========================================================================================================
Function Dlga010Sta(nAcao, cUnitiz, cCodAna, cLocal, cLocali, cFilDca, cFilOri, cViagem, cStatus,lEstorno)

Local dDtIniAnt := CtoD("  /  /  ")
Local dDtFimAnt := CtoD("  /  /  ")
Local cHrIniAnt := ""
Local cHrFimAnt := ""

Default nAcao   := 0 
Default cUnitiz := ""
Default cCodAna := ""
Default cLocal  := ""
Default cLocali := ""
Default cFilDca := ""
Default cFilOri := ""
Default cViagem := ""
Default cStatus := ""
Default lEstorno:= .F.

DCO->(dbSetOrder(1))
If DCO->(dbSeek(xFilial('DCO')+cUnitiz+cCodAna))
	dDtIniAnt := DCO->DCO_DTINI
	cHrIniAnt := DCO->DCO_HRINI
	dDtFimAnt := DCO->DCO_DTFIM
	cHrFimAnt := DCO->DCO_HRFIM
	RecLock('DCO',.F.)
	If !lEstorno
		If nAcao == 1 .Or. nAcao == 3 .Or. nAcao == 4//1=Notas Fiscais do Cliente (TMS050) //3=Chegada de Viagem   //4=Chegada de Viagem Unitizador Sem Docto/
			DCO->DCO_STATUS := Iif(Empty(cStatus),'2',cStatus) //--Em Uso
			DCO->DCO_LOCAL  := cLocal
			DCO->DCO_ENDER  := cLocali //--Em Uso
			DCO->DCO_DTINI  := ddatabase
			DCO->DCO_HRINI  := Left(Time(),5)
			DCO->DCO_HRFIM  := ""
			DCO->DCO_DTFIM  := CtoD("  /  /  ")
			If nAcao == 1
				DCO->DCO_FILORI := ""
				DCO->DCO_VIAGEM := ""
				DCO->DCO_FILDCA := ""
			ElseIf nAcao == 4
				DCO->DCO_FILORI := cFilOri
				DCO->DCO_VIAGEM := cViagem
			EndIf
			DCO->DCO_FILATU := cFilAnt
			DCO->DCO_DTINIA := dDtIniAnt
			DCO->DCO_HRINIA := cHrIniAnt
			DCO->DCO_DTFIMA := dDtFimAnt
			DCO->DCO_HRFIMA := cHrFimAnt
      ElseIf nAcao == 2 //--Carregamento
	      DCO->DCO_STATUS := '3' //--Indisponível
			DCO->DCO_FILORI := cFilOri
			DCO->DCO_VIAGEM := cViagem
			DCO->DCO_FILDCA := cFilDca
			DCO->DCO_DTFIM  := ddatabase
			DCO->DCO_HRFIM  := Left(Time(),5)
		ElseIf nAcao == 5 //--Unitizador 	vinculado a uma viagem e ainda não carregado
			DCO->DCO_FILORI := cFilOri
			DCO->DCO_FILATU := cFilAnt
			DCO->DCO_VIAGEM := cViagem
			DCO->DCO_FILDCA := cFilDca	                           		
			DCO->DCO_DTINI  := ddatabase
			DCO->DCO_HRINI  := Left(Time(),5)
		EndIf
	Else //--Estorno
		If nAcao == 1 //--Estorno NF do Cliente   
		   DCO->DCO_STATUS := '1' //--Indisponível
			DCO->DCO_DTINI  := CtoD("  /  /  ")
			DCO->DCO_HRINI  := ""	                     
			DCO->DCO_LOCAL  := ""
			DCO->DCO_ENDER  := ""
		ElseIf nAcao == 2 //--Estorno Carregamento
			DCO->DCO_STATUS := IIf(Empty(cStatus),'2',cStatus)
			DCO->DCO_FILDCA := ""
			DCO->DCO_VIAGEM := ""
			DCO->DCO_FILORI := ""
			DCO->DCO_DTFIM  := CtoD("  /  /  ")
			DCO->DCO_HRFIM  := " "
		   DCO->DCO_FILATU := DlgA010Psq (cFilOri, cViagem)
		ElseIf nAcao == 3 //--Estorno da chegada
			DCO->DCO_STATUS := '3'
			DCO->DCO_DTINI  := DCO->DCO_DTINIA
			DCO->DCO_HRINI  := DCO->DCO_HRINIA
			DCO->DCO_DTFIM  := DCO->DCO_DTFIMA
			DCO->DCO_HRFIM  := DCO->DCO_HRFIMA
		   DCO->DCO_LOCAL  := ""
		   DCO->DCO_ENDER  := ""
		   DCO->DCO_FILATU := DlgA010Psq (cFilOri, cViagem)
		   DCO->DCO_FILORI := cFilOri
  		   DCO->DCO_VIAGEM := cViagem
  		   DCO->DCO_FILDCA := cFilDca
	  ElseIf nAcao == 5 //--Vinculo do Docto na Viagem
			DCO->DCO_FILORI := ""
			DCO->DCO_VIAGEM := ""
			DCO->DCO_FILDCA := ""                    		
			DCO->DCO_DTINI  := CtoD("  /  /  ")
			DCO->DCO_HRINI  := ""     
			DCO->DCO_FILATU := cFilAnt
		EndIf   
	EndIf      
	MsUnLock()	
EndIf	
Return Nil

//===========================================================================================================
/* Busca ultima filial onde houve Chegada de Viagem
@author  	Leandro Paulino
@Parametros ExpC1 = Filial de Origem
	         ExpC2 = NUmero da Viagem
@version 	P11 R11.80 
@build		700120420A
@since 	30/01/2013    
@return 	aRotina - Array com as opçoes de Menu */
//===========================================================================================================
Static Function DlgA010Psq (cFilOri, cViagem)

Local cAtivChg	 := GetMV('MV_ATIVCHG',,'')
Local cFilAtu 	 := ""
Local aAreaAnt	 := GetArea()

Default cFilOri	:= ""
Default cViagem 	:= ""

cQuery := "SELECT DTW_SEQUEN, DTW_FILATU, DTW_FILATI "
cQuery += "FROM  " + RetSqlName("DTW") + " DTW "
cQuery += "WHERE "
cQuery += "DTW_FILIAL = '" + xFilial("DTW")  + "' AND "
cQuery += "DTW_FILORI = '" + cFilOri 			+ "' AND "
cQuery += "DTW_VIAGEM = '" + cViagem  			+ "' AND "
cQuery += "DTW_ATIVID = '" + cAtivChg 			+ "' AND "
cQuery += "DTW_STATUS = '2' AND "
cQuery += "D_E_L_E_T_ = ' ' "
cQuery += "ORDER BY DTW_SEQUEN "
cQuery := ChangeQuery(cQuery)

cAliasQry := GetNextAlias()

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

While((cAliasQry)->(!EoF()) )//-- Nao Existe nenhuma passagem Efetivada!
	cFilAtu := (cAliasQry)->DTW_FILATU
	(cAliasQry)->(dbSkip())
EndDo
(cAliasQry)->(DbCloseArea())
              
RestArea(aAreaAnt)

Return cFilAtu

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Fabio Alves Silva     ³ Data ³20/10/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³    1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
PRIVATE aRotina	:= {	{STR0001, 'AxPesqui' , 0 , 1, 0, .F.},; //"Pesquisar"
						{STR0002,'DLA010Manu', 0 , 2, 0, nil},; //"Visualizar"
						{STR0003,'DLA010Manu', 0 , 3, 0, nil},; //"Incluir"
						{STR0004,'DLA010Manu', 0 , 4, 0, nil},; //"Alterar"
						{STR0005,'DLA010Manu', 0 , 5, 0, nil}}  //"Excluir"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada utilizado para inserir novas opcoes no array aRotina  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("DLG010MNU")
	ExecBlock("DLG010MNU",.F.,.F.)
EndIf
Return(aRotina)


//===========================================================================================================
/* Function DLGa010whe()
 
IsInCallStack("DLA010Manu") = Desativa a edição dos campos DCO_CODCLI, DCO_LOJCLI, DCO_CODFOR e DCO_LOJFOR no cadastro padrão do Unitizador (DLGA010), 
sendo permitido somente a edição deste campos na Manutenção do Unitizador (DLGA015)- Projeto Controle de Unitizadores nas Viagens de Entrega/Coleta 
Função sendo chamada a partir do X3_WHEN para os campos citados acima. 

IsInCallStack("DLGA015") = Valida o codigo/loja do cliente ou parceiro na Manutenção do Unitizador
caso o cliente seja preenchido, não poderemos preencher o Parceiro ou vice/versa

@author  	Gianni Furlan
@Parametros 
@version 	P11 R11.80
@build		
@since 	25/05/2015
@return 	logico 
//===========================================================================================================*/
Function DLGa010whe()

Local lRet		:= .T. 
Local cCampo	:= ReadVar() 
Local oModel 	:= Nil
Local oMdlGrd	:= Nil
Local cCodcli	:= ""  
Local cLojcli	:= ""
Local cCodfor	:= ""
Local cLojfor	:= ""
Local cFilOri := ""
Local cViagem := ""

	If IsInCallStack("DLA010Manu")
		If cCampo =="M->DCO_CODCLI" .OR. cCampo =="M->DCO_LOJCLI" .OR. cCampo =="M->DCO_CODFOR" .OR. cCampo =="M->DCO_LOJFOR" 
			lRet := .F.
		ElseIf cCampo =="M->DCO_STATUS" .AND. IntTMS()
			If  !Empty( GdFieldGet('DCO_FILORI',n) ) .OR. !Empty( GdFieldGet('DCO_VIAGEM',n) )  .OR.;
				!Empty( GdFieldGet('DCO_CODCLI',n) ) .OR. !Empty( GdFieldGet('DCO_LOJCLI',n) )  .OR.;
				!Empty( GdFieldGet('DCO_CODFOR',n) ) .OR. !Empty( GdFieldGet('DCO_LOJFOR',n) )
				lRet := .F.
			EndIf
		Endif
	
	Elseif IsInCallStack("DLGA015")
	
		oModel 	:= FwModelActive()
		oMdlGrd	:= oModel:GetModel("MdFieldDCO")
		cCodcli	:= oMdlGrd:GetValue("DCO_CODCLI")  
		cLojcli	:= oMdlGrd:GetValue("DCO_LOJCLI")
		cCodfor	:= oMdlGrd:GetValue("DCO_CODFOR")
		cLojfor	:= oMdlGrd:GetValue("DCO_LOJFOR") 
		cFilOri	:= oMdlGrd:GetValue("DCO_FILORI") 
		cViagem	:= oMdlGrd:GetValue("DCO_VIAGEM") 
		
		If (cCampo =="M->DCO_CODCLI" .OR. cCampo =="M->DCO_LOJCLI") .AND. !Empty(cCodfor) .AND. !Empty(cLojfor)
			lRet := .F.
		ElseIf (cCampo =="M->DCO_CODFOR" .OR. cCampo =="M->DCO_LOJFOR") .AND. !Empty(cCodcli) .AND. !Empty(cLojcli)
			lRet := .F.	
		ElseIf cCampo =="M->DCO_STATUS" .AND. IntTMS() .AND. (!Empty(cFilOri) .OR. !Empty(cViagem) .OR. !Empty(cCodfor) .OR. !Empty(cLojfor) .OR. !Empty(cCodcli) .OR. !Empty(cLojcli))
			lRet := .F.
		Endif 
	Endif
Return lRet
