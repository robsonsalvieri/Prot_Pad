#INCLUDE "QIEA050.CH"
#INCLUDE "TOTVS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ QIEA050  ³ Autor ³ Paulo Emidio de Barros³ Data ³23/07/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de atualizacao de Responsaveis					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAQIE													  
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Eduardo S.  ³28/08/02³ ---- ³Incluido validacao no codigo do Usuario   ³±±
±±³            ³        ³      ³quando integrado com SIGAGPE.             ³±±
±±³Eduardo S.  ³09/09/02³ ---- ³Alterado para nao permitir a inclusao de  ³±±
±±³            ³        ³      ³um codigo existente e usuario inativo.    ³±±
±±³Eduardo S.  ³09/09/02³ ---- ³Incluido a opcao "Excluir".               ³±±
±±³Eduardo S.  ³26/11/02³ ---- ³Alterado para validar a exclusao de usua- ³±±
±±³            ³        ³      ³rios/auditores no modulo de Auditoria.    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MenuDef()
Local aRotina   := {}
Private lIntLox := GetMv("MV_QALOGIX") == "1"

If lIntLox
	Aadd(aRotina,{OemToAnsi(STR0001), "AxPesqui",  0, 1,,.F.}) //"Pesquisar"
	Aadd(aRotina,{OemToAnsi(STR0002), "QEA050Atu", 0, 2}) //"Visualizar"
	Aadd(aRotina,{OemToAnsi(STR0004), "QEA050Atu", 0, 4}) //"Alterar"
	Aadd(aRotina,{OemToAnsi(STR0006), "QEA050Vrf", 0, 3,,.F.}) //"Mostrar demitido"
	Aadd(aRotina,{OemToAnsi(STR0007), "QEA050Leg", 0, 6,,.F.}) //"Legenda"
Else
	Aadd(aRotina,{OemToAnsi(STR0001), "AxPesqui",  0, 1,,.F.}) //"Pesquisar"
	Aadd(aRotina,{OemToAnsi(STR0002), "QEA050Atu", 0, 2}) //"Visualizar"
	Aadd(aRotina,{OemToAnsi(STR0003), "QEA050Atu", 0, 3}) //"Incluir" 
	Aadd(aRotina,{OemToAnsi(STR0004), "QEA050Atu", 0, 4}) //"Alterar"
	Aadd(aRotina,{OemToAnsi(STR0015), "QEA050Atu", 0, 5}) // "Excluir"
	Aadd(aRotina,{OemToAnsi(STR0006), "QEA050Vrf", 0, 3,,.F.}) //"Mostrar demitido"
	Aadd(aRotina,{OemToAnsi(STR0007), "QEA050Leg", 0, 6,,.F.}) //"Legenda"
Endif

Return aRotina

Function QIEA050()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := OemtoAnsi(STR0005)  //"Respons veis/Usu rios"
Private cUsrInat  := GetMv("MV_QUSRINA")
Private lUsrInat  := If(cUsrInat == "N",.T.,.F.)
Private lIntGPE   := GetlIntGPE()


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aRotina := MenuDef()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ oBROWSE                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'QAA' )
oBrowse:SetDescription( cCadastro )  
oBrowse:AddLegend( "Qaxa010Vld(1) == 1", 'ENABLE'    ,STR0024)	//Verde - Normal,sem nenhum lacto de pendencia
oBrowse:AddLegend( "Qaxa010Vld(2) == 2", 'DISABLE'   ,STR0025)	// Vermelho - Demitido, sem nenhum lacto de pendencia
oBrowse:AddLegend( "Qaxa010Vld(3) == 3", 'BR_AMARELO',STR0026)	// Amarelo - Normal,com lacto de pendencia
oBrowse:AddLegend( "Qaxa010Vld(4) == 4", 'BR_AZUL'   ,STR0027)	// Azul - Transferido,com lacto de pendencia
oBrowse:AddLegend( "Qaxa010Vld(5) == 5", 'BR_PRETO'  ,STR0028)	// Preta - Demitido, com lacto de pendencia
oBrowse:SetFilterDefault( "QAA->QAA_STATUS == '1'" )

DbselectArea("QAA")
QAA->(DbSetOrder(1))
DbSeek(xFilial("QAA"))                                                                     
oBrowse:Activate()

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QEA050Atu ³ Autor ³ Paulo Emidio de Barros³ Data ³23/07/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Manutencao dos dados referentes aos Responsaveis			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA050													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QEA050Atu(cAlias,nReg,nOpc)
Local aMsSize   := MsAdvSize()
Local cChaveMat := AllTrim(SubStr(QAA->QAA_MAT, Len(cEmpAnt)+1, TAMSX3("QAA_MAT")[1])) // Da posição do tamanho da empresa + 1 até o tamanho do código do usuário
Local cEmpReg   := SubStr(QAA->QAA_MAT, 1, Len(cEmpAnt)) // Da primeira posição até o tamanho da empresa
Local cFilReg   := SubStr(QAA->QAA_MAT, Len(cEmpAnt)+1, FWSizeFilial()) // Da posição do tamanho da empresa + 1 até o tamanho da filial
Local lAchouSRA := .F.
Local nOpTA     := 0
local nOptB     := 0
Local nRetorno  := 0
Local nSaveSX8  := GetSX8Len()
Local oDlg

Private aGets   := {}
Private aTela   := {}
Private lAltUsr := GetlAltUsr()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria as variaveis para edicao na enchoice					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("QAA",If(nOpc==3,.T.,.F.),.T.)

If nOpc == 3 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Retira o filtro para validacao na inclusao do usuario. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("QAA")
	Set Filter To   
EndIf

//DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,0 TO 28,80 PIXEL 
DEFINE MSDIALOG oDlg TITLE cCadastro FROM aMsSize[7],000 To aMsSize[6]-40,aMsSize[5]-350  OF oMainWnd PIXEL
oDlg:lMaximized := .T.
                                                                                          
nOpTA := Msmget():New("QAA",nReg,nOpc,,,,,{001,001,oDlg:nClientHeight,oDlg:nClientWidth * 0.60})

nOpTA:oBox:Align := CONTROL_ALIGN_ALLCLIENT                          
                                                                                                                                                                                            
If (nOpc == 3)              
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, ;
		{||If((Obrigatorio(aGets,aTela) .And. Q050TudoOk(nOpc) .And. QX10VldEmp(lIntGPE) .And. QA010VrCfg(.T.) ), (nOpTB := 1,oDlg:End()),)}, ;
		{|| (nOpTB :=0,oDlg:End())},,)

Else
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpTB:=1,If(nOpc == 4,If(QIE050TOK(),oDlg:End(),.F.),oDlg:End())},{||nOpTB:=2,oDlg:End()})
EndIf	  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Realiza a atualizacao das Notificacoes das nao-conformidades			  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If nOpTB == 1       
	If (nOpc <> 2) .And. (nOpc <> 5)
		Q050GrvAll(nOpc)         
		While ( GetSX8Len() > nSaveSx8 )
			ConfirmSX8()
		EndDo
    ElseIf (nOpc == 5)
		If !lIntGpe .Or. M->QAA_TPUSR <> "1"
			QEA050Dele()   //Exclui Usuario
		ElseIf lIntGpe .And. M->QAA_TPUSR == "1"

			// Verifica se o usuário(QAA) existe na SRA(Gestão de Pessoal)
			If cEmpReg+cFilReg <> cEmpAnt+cFilAnt
				nRetorno := StartJob("LOCALIZSRA", GetEnvServer(), .T.,cEmpReg, cFilReg, cChaveMat, cModulo)
				
				If nRetorno == 0 // Se a tabela SRA NÃO foi localizada ou ocorreu falha na abertura do ambiente 
					// STR0029 - "Não foi possível encontrar o arquivo: " + "SRA"
					Help(NIL, NIL, cEmpReg+cFilReg, NIL, STR0029+"SRA", 1, 0, NIL, NIL, NIL, NIL, NIL, {""})
					Return .F.

				ElseIf nRetorno == 1 // Se o usuário existir na SRA, não exclui o usuário do QAA
					lAchouSRA := .T.
				Endif
			Else
				dbSelectArea("SRA")
				dbSetOrder(1) // Filial + Matrícula
				If SRA->(dbSeek(cChaveMat))
					lAchouSRA := .T.
				Endif
			Endif
			
			If !lAchouSRA
				QEA050Dele() //Exclui Usuario
			Else
				Help(" ",1,"QX10EXGPE") // "O Usuario somente podera ser excluido pelo modulo Gestao de Pessoal."
			Endif
		Else
			Help(" ",1,"QX10EXGPE") // "O Usuario somente podera ser excluido pelo modulo Gestao de Pessoal."
		EndIf				
    EndIf
Else
	While ( GetSX8Len() > nSaveSx8 )
		RollBackSX8()
    EndDo
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtra os Usuarios Inativos									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 3.And. lUsrInat
	Q050Filtro() 
Endif

Return(NIL)
                    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q050GrvAll³ Autor ³ Paulo Emidio de Barros³ Data ³23/07/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualizacao dos Responsaveis								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA050													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q050GrvAll(nOpc)    
Local bCampo := {|x|Field(x)}
Local nCpo
             
dbSelectArea('QAA')
dbSetorder(1)
If MsSeek(xFilial("QAA")+M->QAA_MAT)
	RecLock("QAA",.F.)
Else
	RecLock("QAA",.T.)
EndIf

If valAltFunc()==.T.
EndIf

M->QAA_LOGIN:= UPPER(M->QAA_LOGIN)
For nCpo := 1 to fCount()
	FieldPut(nCpo,M->&(EVAL(bCampo,nCpo)))
Next nCpo

QAA->QAA_FILIAL := xFilial("QAA")
MsUnLock()

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q050Filtro ³ Autor ³Paulo Emidio de Barros³ Data ³23/07/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Filtra os Usuarios/Responsaveis Inativos                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q050Filtro()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA050													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                      
Function Q050Filtro()
Local cFiltro := QA_FilSitF() //"Ativo"

oBrowse:SetFilterDefault(cFiltro)

Return(NIL)                                          

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QEA050Vrf ³ Autor ³ Paulo Emidio de Barros³ Data ³23/07/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Filtra aleatoriamente funcionarios Inativos e/ou Normais   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QEA050Vrf()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA050													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                      
Function QEA050Vrf()
lUsrInat:= !lUsrInat

If !lUsrInat
	oBrowse:SetFilterDefault("QAA->QAA_STATUS <> '*'")
Else
	MsgRun(OemToAnsi(STR0010),OemToAnsi(STR0011),{||Q050Filtro()}) //"Selecionando Usu rios" ### "Aguarde..."
Endif

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q050UsuAti³ Autor ³Paulo Emidio de Barros ³ Data ³23/07/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna o status dos responsaveis ativos					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q050UsuAti()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA050													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q050UsuAti()
Local lRetorno := .F.

If QA_SitFolh()
	lRetorno := .T.                    
EndIf
Return(lRetorno)                                     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q050UsuDem³ Autor ³Paulo Emidio de Barros ³ Data ³23/07/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna o status dos responsaveis demitidos				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q050UsuAti()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA050													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q050UsuDem()
Local lRetorno := .F.

If ! QA_SitFolh()
	lRetorno := .T.                    
EndIf

Return(lRetorno)                                     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QEA050Leg ³ Autor ³Paulo Emidio de Barros ³ Data ³23/07/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Define as Legendas utilizadas no cadastro de Responsaveis  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QEA050Leg()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA050													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QEA050Leg() 
Local aLegenda := {}

Aadd(aLegenda,{"BR_VERDE",   OemToAnsi(STR0012)}) //"Ativos"
Aadd(aLegenda,{"BR_VERMELHO",OemToAnsi(STR0013)}) //"Demitidos"
Aadd(aLegenda,{"BR_AMARELO", OemToAnsi(STR0021)}) //Ativo com pendencia
Aadd(aLegenda,{"BR_AZUL", OemToAnsi(STR0022)}) //Transferido com pendencia
Aadd(aLegenda,{"BR_PRETO", OemToAnsi(STR0023)}) //Demitido com pendencia

BrwLegenda(cCadastro,STR0007,aLegenda) //"Legenda"

Return(NIL)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ QEA050Dele ³ Autor ³ Eduardo de Souza    ³ Data ³ 09/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Exclusao de registros do Cadastro de Usuarios              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QEA050Dele()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QEA050Dele()

Local lApaga:= .F.

MsgRun(OemToAnsi(STR0016),OemToAnsi(STR0011),{|| lApaga := Iif(FindFunction("QAAValExc"), QAAValExc(), lApaga) }) // "Validando Exclusao de Usuarios..." ### "Aguarde..."	

If lApaga
	Begin Transaction
		If RecLock("QAA",.F.)
			QAA->(DbDelete())
			MsUnlock()
			QAA->(DbSkip())
		Endif
	End Transaction
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ QEA050VdDel³ Autor ³ Eduardo de Souza    ³ Data ³ 26/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida Exclusao de Usuarios                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QEA050VdDel()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QEA050VdDel()

Local lApaga := .T.
Local nOrd01 := 0
Local nOrd02 := 0
Local nOrd03 := 0
Local nOrd04 := 0
Local nOrd05 := 0
Local cIndex := ""
Local cKey   := ""
Local cFiltro:= "" 
Local QTD	  := 0

// SIGAQIE (Inspecao de Entradas)
If lApaga
	QE5->(DbSetOrder(3))
	If QE5->(DbSeek(xFilial("QE5")+QAA->QAA_FILIAL+QAA->QAA_MAT))
		lApaga:= .F.
	EndIf
	QE5->(DbSetOrder(nOrd01))
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ MEDICOES - DADOS GENERICOS                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lApaga
	cQuery := "Select Count (*)  QTD" 
	cQuery += " From " + RetSqlName("QER") + " QER "
	cQuery += " Where QER.QER_FILMAT = '" + QAA->QAA_FILIAL + "' and "
	cQuery += "       QER.QER_ENSR = '" + QAA->QAA_MAT + "' and "
	cQuery += "       QER.D_E_L_E_T_ = ' '"
	
	cQuery := ChangeQuery(cQuery)
	
	If Qtd > 0
		lApaga := .F.
	Endif
EndIf

// SIGAQMT (Metrologia)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CADASTRO DE INSTRUMENTOS                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lApaga
	nOrd01:= QM2->(IndexOrd())
	DbSelectarea("QM2")
	cIndex  := CriaTrab(Nil,.F.)
	cKey    := "QM2_FILRES+QM2_RESP"
	cFiltro := "QM2->QM2_FILRES+QM2->QM2_RESP == '"+QAA->QAA_FILIAL+QAA->QAA_MAT+"'"
	IndRegua("QM2",cIndex,cKey,,cFiltro,OemToAnsi(STR0016)) //"Validando Exclusao..."
	If QM2->(!Eof())
		lApaga:= .F.
	EndIf
	RetIndex("QM2")
	Set Filter to
	cIndex += OrDbagExt()
	Delete File &(cIndex)
	QM2->(DbSetOrder(nOrd01))
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ MEDICOES DE ENSAIOS REPE/REPRO                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lApaga
	nOrd01:= QM5->(IndexOrd())
	DbSelectarea("QM5")
	cIndex  := CriaTrab(Nil,.F.)
	cKey    := "QM5_FILRES+QM5_ENSR"
	cFiltro := "QM5->QM5_FILRES+QM5->QM5_ENSR == '"+QAA->QAA_FILIAL+QAA->QAA_MAT+"'"
	IndRegua("QM5",cIndex,cKey,,cFiltro,OemToAnsi(STR0016)) //"Validando Exclusao..."
	If QM5->(!Eof())
		lApaga:= .F.
	EndIf
	RetIndex("QM5")
	Set Filter to
	cIndex += OrDbagExt()
	Delete File &(cIndex)
	QM5->(DbSetOrder(nOrd01))
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CABECALHO DE CALIBRACAO                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lApaga
	
	cQuery := "Select Count (*)  QTD" 
	cQuery += " From " + RetSqlName("QM6") + " QM6 "
	cQuery += " Where QM6.QM6_FILRES = '" + QAA->QAA_FILIAL + "' and "
	cQuery += "       QM6.QM6_RESP = '" + QAA->QAA_MAT + "' and "
	cQuery += "       QM6.D_E_L_E_T_ = ' '"
	
	cQuery := ChangeQuery(cQuery)
	
	If Qtd > 0
		lApaga := .F.
	Endif
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CADASTRO MANUT.REALIZADAS                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lApaga
	nOrd01:= QME->(IndexOrd())
	DbSelectarea("QME")
	cIndex  := CriaTrab(Nil,.F.)
	cKey    := "QME_FILRES+QME_RESP"
	cFiltro := "QME->QME_FILRES+QME->QME_RESP == '"+QAA->QAA_FILIAL+QAA->QAA_MAT+"'"
	IndRegua("QME",cIndex,cKey,,cFiltro,OemToAnsi(STR0016)) //"Validando Exclusao..."
	If QME->(!Eof())
		lApaga:= .F.
	EndIf
	RetIndex("QME")
	Set Filter to
	cIndex += OrDbagExt()
	Delete File &(cIndex)
	QME->(DbSetOrder(nOrd01))
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CADASTRO DE LOCALIZACAO INSTR.                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lApaga
	nOrd01:= QML->(IndexOrd())
	DbSelectarea("QML")
	cIndex  := CriaTrab(Nil,.F.)
	cKey    := "QML_FILRET+QML_RESRET"
	cFiltro := "QML->QML_FILRET+QML->QML_RESRET == '"+QAA->QAA_FILIAL+QAA->QAA_MAT+"'"
	IndRegua("QML",cIndex,cKey,,cFiltro,OemToAnsi(STR0016)) //"Validando Exclusao..."
	If QML->(!Eof())
		lApaga:= .F.
	EndIf
	RetIndex("QML")
	Set Filter to
	cIndex += OrDbagExt()
	Delete File &(cIndex)
	QML->(DbSetOrder(nOrd01))
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CADASTRO DO MSA                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lApaga
	nOrd01:= QMU->(IndexOrd())
	DbSelectarea("QMU")
	cIndex  := CriaTrab(Nil,.F.)
	cKey    := "QMU_FILRES+QMU_RESP"
	cFiltro := "QMU->QMU_FILRES+QMU->QMU_RESP == '"+QAA->QAA_FILIAL+QAA->QAA_MAT+"'"
	IndRegua("QMU",cIndex,cKey,,cFiltro,OemToAnsi(STR0016)) //"Validando Exclusao..."
	If QMU->(!Eof())
		lApaga:= .F.
	EndIf
	RetIndex("QMU")
	Set Filter to
	cIndex += OrDbagExt()
	Delete File &(cIndex)
	QMU->(DbSetOrder(nOrd01))
EndIf

// SIGAQIP (Inspecao de Processos)
If lApaga
	nOrd01:= QP5->(IndexOrd())
	QP5->(DbSetOrder(2))
	If QP5->(DbSeek(xFilial("QP5")+QAA->QAA_MAT))
		lApaga:= .F.
	EndIf
	QP5->(DbSetOrder(nOrd01))
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ MEDICOES - DADOS GENERICOS                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lApaga 
	
	cQuery := "Select Count (*)  QTD" 
	cQuery += " From " + RetSqlName("QPR") + " QPR "
	cQuery += " Where QPR.QPR_FILMAT = '" + QAA->QAA_FILIAL + "' and "
	cQuery += "       QPR.QPR_ENSR = '" + QAA->QAA_MAT + "' and "
	cQuery += "       QPR.D_E_L_E_T_ = ' '"
	
	cQuery := ChangeQuery(cQuery)
	
	If Qtd > 0
		lApaga := .F.
	Endif

EndIf

// SIGAQAD (Controle de Auditoria)
If lApaga
	nOrd01:= QUA->(IndexOrd())
	nOrd02:= QUB->(IndexOrd())
	nOrd03:= QUC->(IndexOrd())
	QUA->(DbSetOrder(2))
	QUB->(DbSetOrder(2))
	QUC->(DbSetOrder(4))
	If QUA->(DbSeek(xFilial("QUA")+QAA->QAA_MAT))
		lApaga:= .F.
	ElseIf QUB->(DbSeek(xFilial("QUB")+QAA->QAA_MAT))
		lApaga:= .F.
	ElseIf QUC->(DbSeek(xFilial("QUC")+QAA->QAA_MAT))
		lApaga:= .F.
	EndIf
	QUA->(DbSetOrder(nOrd01))
	QUB->(DbSetOrder(nOrd02))
	QUC->(DbSetOrder(nOrd03))
EndIf

If lApaga
	nOrd04:= QUD->(IndexOrd())
	QUD->(DbSetOrder(3))
	QUD->(DbSeek(xFilial("QUD")))
	While QUD->(!Eof()) .And. QUD->QUD_FILIAL == xFilial("QUD")
		If QUD->QUD_CODAUD == QAA->QAA_MAT
			lApaga:= .F.
		EndIf
		QUD->(DbSkip())
		QUD->(DbSetOrder(nOrd04))
	EndDo
EndIf

If lApaga
	nOrd05:= QUH->(IndexOrd())
	QUH->(DbSetOrder(2))
	QUH->(DbSeek(xFilial("QUH")))
	While QUH->(!Eof()) .And. QUH->QUH_FILIAL == xFilial("QUH")
		If QUH->QUH_CODAUD == QAA->QAA_MAT
			lApaga:= .F.
		EndIf
		QUH->(DbSkip())
	EndDo
	QUH->(DbSetOrder(nOrd05))
EndIf

// SIGAPPAP (PPAP)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ ITENS FMEA DE PROJETO                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lApaga
	nOrd01:= QK6->(IndexOrd())
	DbSelectarea("QK6")
	cIndex  := CriaTrab(Nil,.F.)
	cKey    := "QK6_FILRES+QK6_CODRES"
	cFiltro := "QK6->QK6_FILRES+QK6->QK6_CODRES == '"+QAA->QAA_FILIAL+QAA->QAA_MAT+"'"
	IndRegua("QK6",cIndex,cKey,,cFiltro,OemToAnsi(STR0016)) //"Validando Exclusao..."
	If QK6->(!Eof())
		lApaga:= .F.
	EndIf
	RetIndex("QK6")
	Set Filter to
	cIndex += OrDbagExt()
	Delete File &(cIndex)
	QK6->(DbSetOrder(nOrd01))
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ ITENS FMEA DE PROCESSO                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lApaga
	nOrd01:= QK8->(IndexOrd())
	DbSelectarea("QK8")
	cIndex  := CriaTrab(Nil,.F.)
	cKey    := "QK8_FILRES+QK8_CODRES"
	cFiltro := "QK8->QK8_FILRES+QK8->QK8_CODRES == '"+QAA->QAA_FILIAL+QAA->QAA_MAT+"'"
	IndRegua("QK8",cIndex,cKey,,cFiltro,OemToAnsi(STR0016)) //"Validando Exclusao..."
	If QK8->(!Eof())
		lApaga:= .F.
	EndIf
	RetIndex("QK8")
	Set Filter to
	cIndex += OrDbagExt()
	Delete File &(cIndex)
	QK8->(DbSetOrder(nOrd01))
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CRONOGRAMA                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lApaga
	nOrd01:= QKG->(IndexOrd())
	DbSelectarea("QKG")
	cIndex  := CriaTrab(Nil,.F.)
	cKey    := "QKG_FILRES+QKG_RESP"
	cFiltro := "QKG->QKG_FILRES+QKG->QKG_RESP == '"+QAA->QAA_FILIAL+QAA->QAA_MAT+"'"
	IndRegua("QKG",cIndex,cKey,,cFiltro,OemToAnsi(STR0016)) //"Validando Exclusao..."
	If QKG->(!Eof())
		lApaga:= .F.
	EndIf
	RetIndex("QKG")
	Set Filter to
	cIndex += OrDbagExt()
	Delete File &(cIndex)
	QKG->(DbSetOrder(nOrd01))
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CERTIFICADO DE SUBMISSAO                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lApaga
	nOrd01:= QKI->(IndexOrd())
	DbSelectarea("QKI")
	cIndex  := CriaTrab(Nil,.F.)
	cKey    := "QKI_FILMAT+QKI_MAT"
	cFiltro := "QKI->QKI_FILMAT+QKI->QKI_MAT == '"+QAA->QAA_FILIAL+QAA->QAA_MAT+"'"
	IndRegua("QKI",cIndex,cKey,,cFiltro,OemToAnsi(STR0016)) //"Validando Exclusao..."
	If QKI->(!Eof())
		lApaga:= .F.
	EndIf
	RetIndex("QKI")
	Set Filter to
	cIndex += OrDbagExt()
	Delete File &(cIndex)
	QKI->(DbSetOrder(nOrd01))
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ ETAPAS DO CRONOGRAMA                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lApaga
	nOrd01:= QKP->(IndexOrd())
	DbSelectarea("QKP")
	cIndex  := CriaTrab(Nil,.F.)
	cKey    := "QKP_FILMAT+QKP_MAT"
	cFiltro := "QKP->QKP_FILMAT+QKP->QKP_MAT == '"+QAA->QAA_FILIAL+QAA->QAA_MAT+"'"
	IndRegua("QKP",cIndex,cKey,,cFiltro,OemToAnsi(STR0016)) //"Validando Exclusao..."
	If QKP->(!Eof())
		lApaga:= .F.
	EndIf
	RetIndex("QKP")
	Set Filter to
	cIndex += OrDbagExt()
	Delete File &(cIndex)
	QKP->(DbSetOrder(nOrd01))
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CHECKLIST APQP - A1                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lApaga
	nOrd01:= QKQ->(IndexOrd())
	DbSelectarea("QKQ")
	cIndex  := CriaTrab(Nil,.F.)
	cKey    := "QKQ_FILRES+QKQ_RESP"
	cFiltro := "(QKQ->QKQ_FILRES+QKQ->QKQ_RESP == '"+QAA->QAA_FILIAL+QAA->QAA_MAT+"' .Or. "
	cFiltro += "QKQ->QKQ_FILRES+QKQ->QKQ_RESPOR == '"+QAA->QAA_FILIAL+QAA->QAA_MAT+"')"
	IndRegua("QKQ",cIndex,cKey,,cFiltro,OemToAnsi(STR0016)) //"Validando Exclusao..."
	If QKQ->(!Eof())
		lApaga:= .F.
	EndIf
	RetIndex("QKQ")
	Set Filter to
	cIndex += OrDbagExt()
	Delete File &(cIndex)
	QKQ->(DbSetOrder(nOrd01))
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CHECKLIST APQP - A2                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lApaga
	nOrd01:= QKR->(IndexOrd())
	DbSelectarea("QKR")
	cIndex  := CriaTrab(Nil,.F.)
	cKey    := "QKR_FILRES+QKR_RESP"
	cFiltro := "(QKR->QKR_FILRES+QKR->QKR_RESP == '"+QAA->QAA_FILIAL+QAA->QAA_MAT+"' .Or. "
	cFiltro += "QKR->QKR_FILRES+QKR->QKR_RESPOR == '"+QAA->QAA_FILIAL+QAA->QAA_MAT+"')"
	IndRegua("QKR",cIndex,cKey,,cFiltro,OemToAnsi(STR0016)) //"Validando Exclusao..."
	If QKR->(!Eof())
		lApaga:= .F.
	EndIf
	RetIndex("QKR")
	Set Filter to
	cIndex += OrDbagExt()
	Delete File &(cIndex)
	QKR->(DbSetOrder(nOrd01))
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CHECKLIST APQP - A3                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lApaga
	nOrd01:= QKS->(IndexOrd())
	DbSelectarea("QKS")
	cIndex  := CriaTrab(Nil,.F.)
	cKey    := "QKS_FILRES+QKS_RESP"
	cFiltro := "(QKS->QKS_FILRES+QKS->QKS_RESP == '"+QAA->QAA_FILIAL+QAA->QAA_MAT+"' .Or. "
	cFiltro += "QKS->QKS_FILRES+QKS->QKS_RESPOR == '"+QAA->QAA_FILIAL+QAA->QAA_MAT+"')"
	IndRegua("QKS",cIndex,cKey,,cFiltro,OemToAnsi(STR0016)) //"Validando Exclusao..."
	If QKS->(!Eof())
		lApaga:= .F.
	EndIf
	RetIndex("QKS")
	Set Filter to
	cIndex += OrDbagExt()
	Delete File &(cIndex)
	QKS->(DbSetOrder(nOrd01))
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CHECKLIST APQP - A4                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lApaga
	nOrd01:= QKT->(IndexOrd())
	DbSelectarea("QKT")
	cIndex  := CriaTrab(Nil,.F.)
	cKey    := "QKT_FILRES+QKT_RESP"
	cFiltro := "(QKT->QKT_FILRES+QKT->QKT_RESP == '"+QAA->QAA_FILIAL+QAA->QAA_MAT+"' .Or. "
	cFiltro += "QKT->QKT_FILRES+QKT->QKT_RESPOR == '"+QAA->QAA_FILIAL+QAA->QAA_MAT+"')"
	IndRegua("QKT",cIndex,cKey,,cFiltro,OemToAnsi(STR0016)) //"Validando Exclusao..."
	If QKT->(!Eof())
		lApaga:= .F.
	EndIf
	RetIndex("QKT")
	Set Filter to
	cIndex += OrDbagExt()
	Delete File &(cIndex)
	QKT->(DbSetOrder(nOrd01))
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CHECKLIST APQP - A5                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lApaga
	nOrd01:= QKU->(IndexOrd())
	DbSelectarea("QKU")
	cIndex  := CriaTrab(Nil,.F.)
	cKey    := "QKU_FILRES+QKU_RESP"
	cFiltro := "(QKU->QKU_FILRES+QKU->QKU_RESP == '"+QAA->QAA_FILIAL+QAA->QAA_MAT+"' .Or. "
	cFiltro += "QKU->QKU_FILRES+QKU->QKU_RESPOR == '"+QAA->QAA_FILIAL+QAA->QAA_MAT+"')"
	IndRegua("QKU",cIndex,cKey,,cFiltro,OemToAnsi(STR0016)) //"Validando Exclusao..."
	If QKU->(!Eof())
		lApaga:= .F.
	EndIf
	RetIndex("QKU")
	Set Filter to
	cIndex += OrDbagExt()
	Delete File &(cIndex)
	QKU->(DbSetOrder(nOrd01))
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CHECKLIST APQP - A6                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lApaga
	nOrd01:= QKV->(IndexOrd())
	DbSelectarea("QKV")
	cIndex  := CriaTrab(Nil,.F.)
	cKey    := "QKV_FILRES+QKV_RESP"
	cFiltro := "(QKV->QKV_FILRES+QKV->QKV_RESP == '"+QAA->QAA_FILIAL+QAA->QAA_MAT+"' .Or. "
	cFiltro += "QKV->QKV_FILRES+QKV->QKV_RESPOR == '"+QAA->QAA_FILIAL+QAA->QAA_MAT+"')"
	IndRegua("QKV",cIndex,cKey,,cFiltro,OemToAnsi(STR0016)) //"Validando Exclusao..."
	If QKV->(!Eof())
		lApaga:= .F.
	EndIf
	RetIndex("QKV")
	Set Filter to
	cIndex += OrDbagExt()
	Delete File &(cIndex)
	QKV->(DbSetOrder(nOrd01))
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CHECKLIST APQP - A7                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lApaga
	nOrd01:= QKW->(IndexOrd())
	DbSelectarea("QKW")
	cIndex  := CriaTrab(Nil,.F.)
	cKey    := "QKW_FILRES+QKW_RESP"
	cFiltro := "(QKW->QKW_FILRES+QKW->QKW_RESP == '"+QAA->QAA_FILIAL+QAA->QAA_MAT+"' .Or. "
	cFiltro += "QKW->QKW_FILRES+QKW->QKW_RESPOR == '"+QAA->QAA_FILIAL+QAA->QAA_MAT+"')"
	IndRegua("QKW",cIndex,cKey,,cFiltro,OemToAnsi(STR0016)) //"Validando Exclusao..."
	If QKW->(!Eof())
		lApaga:= .F.
	EndIf
	RetIndex("QKW")
	Set Filter to
	cIndex += OrDbagExt()
	Delete File &(cIndex)
	QKW->(DbSetOrder(nOrd01))
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CHECKLIST APQP - A8                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lApaga
	nOrd01:= QKX->(IndexOrd())
	DbSelectarea("QKX")
	cIndex  := CriaTrab(Nil,.F.)
	cKey    := "QKX_FILRES+QKX_RESP"
	cFiltro := "(QKX->QKX_FILRES+QKX->QKX_RESP == '"+QAA->QAA_FILIAL+QAA->QAA_MAT+"' .Or. "
	cFiltro += "QKX->QKX_FILRES+QKX->QKX_RESPOR == '"+QAA->QAA_FILIAL+QAA->QAA_MAT+"')"
	IndRegua("QKX",cIndex,cKey,,cFiltro,OemToAnsi(STR0016)) //"Validando Exclusao..."
	If QKX->(!Eof())
		lApaga:= .F.
	EndIf
	RetIndex("QKX")
	Set Filter to
	cIndex += OrDbagExt()
	Delete File &(cIndex)
	QKX->(DbSetOrder(nOrd01))
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CHECKLIST MATERIAL A GRANEL                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lApaga
	nOrd01:= QKY->(IndexOrd())
	DbSelectarea("QKY")
	cIndex  := CriaTrab(Nil,.F.)
	cKey    := "QKY_FILRES+QKY_RESP1"
	cFiltro := "(QKY->QKY_FILRES+QKY->QKY_RESP1 == '"+QAA->QAA_FILIAL+QAA->QAA_MAT+"' .Or. "
	cFiltro += "QKY->QKY_FILRES+QKY->QKY_RESP2 == '"+QAA->QAA_FILIAL+QAA->QAA_MAT+"' .Or. "
	cFiltro += "QKY->QKY_FILRES+QKY->QKY_RESP3 == '"+QAA->QAA_FILIAL+QAA->QAA_MAT+"')"
	IndRegua("QKY",cIndex,cKey,,cFiltro,OemToAnsi(STR0016)) //"Validando Exclusao..."
	If QKY->(!Eof())
		lApaga:= .F.
	EndIf
	RetIndex("QKY")
	Set Filter to
	cIndex += OrDbagExt()
	Delete File &(cIndex)
	QKY->(DbSetOrder(nOrd01))
EndIf

Return lApaga


Static Function Q050TudoOk(nOpc)
Local lRet := .T.

If nOpc == 3
	If QAD->(dbSeek(xFilial("QAD")+M->QAA_CC))
		If QAD->QAD_STATUS <> "1"
			MsgAlert(STR0019, STR0018)
			lRet := .F.
		EndIF
	Else
		MsgAlert(STR0020+xFilial("QAD"), STR0018)
		lRet := .F.
	EndIf
EndIf

Return lRet

Function GetlIntGPE()
Return If(SuperGetMv("MV_QGINT",.F.,"N") == "S",.T.,.F.)

Function GetlAltUsr()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variavel utilizada para bloquear os campos que nao podem ser alterados. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lAltUsr := .F.

If GetlIntGPE() .And. ((IsInCallStack('QIEA050') .AND. INCLUI) .Or. M->QAA_TPUSR == "1")
	lAltUsr:= .T.
EndIf

Return lAltUsr

/*/{Protheus.doc} QIE050TOK
@type  Static Function
@author rafael.hesse
@since 13/07/2022
@return lRet, Lógico, indica se o cadastro está válido para inclusão/alteração
/*/
Function QIE050TOK()
Local lRet := .T.	

	If !(QA010VrCfg(.T.))
		lRet := .F.
	EndIf
	
	lRet :=	IIf( lRet .And. Altera .And. M->QAA_STATUS == '2' .And. FindFunction("QAAValIna"), QAAValIna(), lRet) //Iif na mesma linha para facilitar cobertura

Return lRet
