#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "QDOA080.CH"
#INCLUDE "TOTVS.CH"

#DEFINE TR_RECNO     1
#DEFINE TR_STATUS    2
#DEFINE TR_COUNTER   3
#DEFINE TR_HISTORICO 4

Static lFiltraFil := .F.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QDOA080  ³ Autor ³ Rodrigo de A. Sartorio  ³ Data ³ 29/06/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro de Treinamento                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDOA080()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico ( Windows )                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Eduardo S.  ³20/02/02³ META ³ Incluido Quebra p/ Depto no Relatorio de Re³±±
±±³            ³        ³      ³ gistro de Treinamento,Otimizacao e Melhoria³±±
±±³Eduardo S.  ³27/02/02³ META ³ Alterado para gerar Aviso de Agendamento de³±±
±±³            ³        ³      ³ Treinamento.                               ³±±
±±³Eduardo S.  ³01/04/02³ META ³ Alteracao devido novo conceito na utiliza- ³±±
±±³            ³        ³      ³ cao dos arquivos de Usuarios\Centros de Cus³±±
±±³            ³        ³      ³ to\Funcoes pelo Quality.                   ³±±
±±³Eduardo S.  ³23/05/02³ xxxx ³ Acerto para validar os campos obrigatorios ³±±
±±³            ³        ³      ³ e acerto para validar os instrutores.      ³±±
±±³Eduardo S.  ³03/08/02³ xxxx ³ Acerto para validar se a folder Treinandos ³±±
±±³            ³        ³      ³ foi selecionada para atualizacao arquivos. ³±±
±±³Eduardo S.  ³03/08/02³ xxxx ³ Incluido validacao na Data e Hora.         ³±±
±±³Eduardo S.  ³03/08/02³ xxxx ³ Acerto para listar corretamente o texto da ³±±
±±³            ³        ³      ³ convocacao.                                ³±±
±±³Eduardo S.  ³24/10/02³ xxxx ³ Alterado para permitir a finalizacao somen ³±±
±±³            ³        ³      ³ te se existir Treinandos cadastrados.      ³±±
±±³Eduardo S.  ³08/01/03³ ---- ³ Alterado para permitir pesquisar usuarios  ³±±
±±³            ³        ³      ³ de outras filiais.                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function MenuDef()

Local aRotina  := {	{ OemToAnsi( STR0001 ) ,"AxPesqui"									, 0, 1,,.F.},;  								//1"Pesquisar"
                    { OemToAnsi( STR0002 ) ,"QD080Visual"								, 0, 2},;										//2"Visualizar"
                    { OemToAnsi( STR0003 ) ,"QD080Inclu"								, 0, 3},;  										//3"Incluir"
                    { OemToAnsi( STR0025 ) ,"QD080Alter"								, 0, 4},;  										//4"Alterar"
                    { OemToAnsi( STR0004 ) ,"QD080Excl"									, 0, 5},;  										//5"Excluir"
                    { OemToAnsi( STR0005 ) ,"QD080Confir"								, 0, 4},; 										//6"Confirmar"
                    { OemToAnsi( STR0024 ) ,"QD080ReTrei"								, 0, 4},; 										//7"Retreinar"
                    { OemToAnsi( STR0028 ) ,"A080Rel"									, 0, 7},;										//8"Imprimir"
					{ OemToAnsi( STR0081 ) ,"MsDocument('QDA', QDA->(RecNo()), 4)"		, 0, 4},;										//9"Conhecimento"
					{ OemToAnsi( STR0062 ), "QD080Legen"								, 0, 9,,.F.}}									//10"Legenda"		

Return aRotina

Function QDOA080()

	Local aCores	  := {}
	Local oQLTQueryM  := QLTQueryManager():New()

	Private aRotina   := MenuDef()
	Private cCadastro := STR0006 //"Cadastro de Treinamento"
	Private cFilMat   := cFilAnt
	
	
	oQLTQueryM:ValidaDadosDaFilial("QDA", Nil, Nil, .T.)
	oQLTQueryM:ValidaDadosDaFilial("QAA", Nil, Nil, .T.)
	oQLTQueryM:ValidaDadosDaFilial("QAD", Nil, Nil, .T.)
	oQLTQueryM:ValidaDadosDaFilial("QAC", Nil, Nil, .T.)

	aCores := {	{"QDA->QDA_BAIXA == 'S'","ENABLE"	},;
				{"QDA->QDA_BAIXA <> 'S'","DISABLE"	} }

	DBSelectArea( "QDA" )
	mBrowse(6,1,22,75,"QDA",,"QDA->QDA_BAIXA <> 'S'",,,,aCores)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QDO080Visual³ Autor ³Edilson M. Nascimento  ³ Data ³ 07/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de visualizacao de Treinamentos                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDO080Visual( <cAlias>, <nReg>, <nOpc> )                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ <cAlias> = Alias do arquivo                                  ³±±
±±³          ³ <nReg>   = Numero do registro                                ³±±
±±³          ³ <nOpc>   = Numero da opcao selecionada                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA080                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
FUNCTION QD080Visual( cAlias, nReg, nOpc)

Local aMemos   := {{"QDA_CONVOC", "QDA_MEMO1"}} // Texto convocacao treinamento
Local aUsrMat  := QA_USUARIO()
Local bCampo   := {|nCPO| Field(nCPO) }
Local cExpQAA  := ""
Local lApelido := aUsrMat[1]
Local lRet     := .F.
Local nI       := 0
Local nPos     := 0

Private aCargos    := {}
Private aDeptos    := {}
Private aGets[0]
Private aItsCargo  := {}
Private aItsDepto  := {}
Private aItsUser   := {}
Private aTela[0][0]
Private aUsers     := {}
Private hNo        := LoadBitmap( GetResources(), "LBNO" )
Private hOk        := LoadBitmap( GetResources(), "LBTIK" )
Private lChkFolder := Nil
Private lFolder2   := .F.
Private nQaConpad  := 3
Private oDlgFolder := Nil
Private oTreina    := Nil

//Chama a validação de compartilhamentos de tabela
If !fVldComp()
	Return .F.
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa campos MEMO                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI:=1 to Len(aMemos)
	cMemo := aMemos[nI][2]
	If ExistIni(cMemo)
		&cMemo := InitPad(GetSx3Cache(cMemo, "X3_RELACAO"))
	Else
		&cMemo := ""
	EndIf
Next nI

If lApelido
	
	DbSelectArea("QAA")
	QAA->(DbSetOrder(1))
	cExpQAA:= Qa_FilSitF()
	Set Filter To &(cExpQAA)
	QAA->(DbGotop())
	
	DBSelectArea("QDA")
	FOR nPos := 1 TO QDA->( FCount() )
		M->&( Eval( bCampo, nPos )) := QDA->( FieldGet( nPos ) )
	NEXT
	
	Qd080Telas(nReg,nOpc)
	
	ACTIVATE MSDIALOG oDlgFolder ON INIT EnchoiceBar(oDlgFolder,{||lRet:= .T.,oDlgFolder:End()},{||oDlgFolder:End()})
	
	DBSelectArea("QAA")
	SET FILTER TO
	
Else
	Help( " ", 1, "QD_LOGIN") // "O usuario atual nao possui um Login" ### "cadastrado igual ao apelido do configurador."
Endif                            // cadastrado igual ao do configurador

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QD080Inclu ³ Autor ³Edilson M. Nascimento  ³ Data ³ 07/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para inclusao de Treinamentos                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD080Inclu( <cAlias>, <nReg>, <nOpc>)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ <cAlias> = Alias do arquivo                                  ³±±
±±³          ³ <nReg>   = Numero do registro                                ³±±
±±³          ³ <nOpc>   = Numero da opcao selecionada                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA080                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
FUNCTION QD080Inclu(cAlias,nReg,nOpc,cDocto,cRv,lAviso)

Local aDiv     := {}
Local aMemos   := {{"QDA_CONVOC", "QDA_MEMO1"}} // Texto convocacao treinamento
Local aUsrMail := {}
Local aUsrMat  := QA_USUARIO()
Local bCampo   := {|nCPO| Field(nCPO) }
Local cCampo   := ""
Local cExpQAA  := ""
Local cFilSx2  := SX2->(DbFilter())
Local cMatCod  := aUsrMat[3]
Local cMatDep  := aUsrMat[4]
Local cMatFil  := aUsrMat[2]
Local cModoRA1 := ""
Local cModoRA3 := ""
Local cTitulo  := ""
Local cTpDocto := ""
Local dDtVig   := ""
Local i        := ""
Local lApelido := aUsrMat[1]
Local lExist   := .F.
Local lGrava   := .F.
Local lQGTRM   := GetMV("MV_QGTRM",.F.,"2")=="1" .AND. GetMv("MV_QGINT")=="S" // "Define se os modulos Quality estÒo integrados com Modulo SIGATRM trabalha em conjunto com MV_QGINT 1=SIM;2=NAO"
Local lRetRA3  := .T.
Local nPCur    := 0
Local nPos     := 0
Local nSaveSX8 := GetSX8Len()
Local oCargos  := NIL
Local oDeptos  := NIL
Local oUsers   := NIL

Private aCargos     := {}
Private aCursos     := {}
Private aDeptos     := {}
Private aGets[0]
Private aItsCargo   := {}
Private aItsDepto   := {}
Private aItsUser    := {}
Private aTela[0][0]
Private aUsers      := {}
Private cOldDocto   := ""
Private cOldRevisao := ""
Private hNo         := LoadBitmap( GetResources(), "LBNO" )
Private hOK         := LoadBitmap( GetResources(), "LBTIK" )
Private lChkFolder  := .F.
Private lFolder2    := .F.
Private nQaConpad   := 3
Private oDlgFolder  := NIL
Private oTreina     := NIL

lAviso              := If(lAviso==Nil,.F.,lAviso)

//Chama a validação de compartilhamentos de tabela
If !fVldComp()
	Return .F.
EndIF


IF lQGTRM
	dbSelectArea("SX2")
	DbClearFilter()
	DbSetOrder(1)
	
	cModoRA3:= FWModeAccess("RA3", 3)
	cModoRA1:= FWModeAccess("RA1", 3)
	
	dbSelectArea("SX2")
	Set Filter To &(cFilSx2)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa campos MEMO                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For i:=1 to Len(aMemos)
	cMemo := aMemos[i][2]
	If ExistIni(cMemo)
		&cMemo := InitPad( GetSx3Cache(cMemo, "X3_RELACAO") )
	Else
		&cMemo := ""
	EndIf
Next i

If lApelido
	DbSelectArea("QAA")
	QAA->(DBSetOrder(1))
	cExpQAA := Qa_FilSitF()
	SET FILTER TO &(cExpQAA)
	QAA->(DbGotop())
	
	DBSelectArea("QDA")
	FOR nPos := 1 TO QDA->( FCOUNT() )
		cCampo := EVAL( bCampo, nPos )
		lExist := .F.
		If ExistIni( cCampo )
			lExist := .T.
			M->&( cCampo ) := InitPad( GetSx3Cache(cCampo, "X3_RELACAO") )
			If VALTYPE( M->&( cCampo ) ) == "C"
				M->&( cCampo ) := PADR( M->&( cCampo ), GetSx3Cache(cCampo, "X3_TAMANHO") )
			EndIf
			If M->&( cCampo ) == Nil
				lExist := .F.
			EndIf
		EndIf
		If ! lExist
			M->&( cCampo ) := QDA->( FieldGet( nPos ) )
			If VALTYPE( M->&( cCampo ) ) == "C"
				M->&( cCampo ) := SPACE( LEN( M->&( cCampo ) ) )
			ElseIf VALTYPE( M->&( cCampo ) ) == "N"
				M->&( cCampo ) := 0
			ElseIf VALTYPE( M->&( cCampo ) ) == "D"
				M->&( cCampo ) := CTOD( "  /  /  ", "DDMMYY" )
			ElseIf VALTYPE( M->&( cCampo ) ) == "L"
				M->&( cCampo ) := .F.
			EndIf
		EndIf
	NEXT
	M->QDA_FILIAL := xFilial("QDA")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Chamada via Rotina de Aviso        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lAviso
		M->QDA_DOCTO:= cDocto
		M->QDA_RV   := cRv
	EndIf
	
	Qd080Fil(nOpc)
	
	If !Qd080Telas(nReg,nOpc,@oDeptos,@oCargos,@oUsers,lQGTRM)
		Return 
	EndIf
	
	SetKey( VK_F4 , { || If(QD080Fold2(lFolder2,.F.), QAA->(fPesqF(oUsers,1)),) } )
	SetKey( VK_F5 , { || If(QD080Fold2(lFolder2,.F.), QAD->(fPesqF(oDeptos,2)),) } )
	SetKey( VK_F6 , { || If(QD080Fold2(lFolder2,.F.), QAC->(fPesqF(oCargos,3)),) })
	aButtons := { 	{ 'BMPGROUP', {|| If(QD080Fold2(lFolder2,.F.), QAA->(fPesqF(oUsers,1)),)  },OemtoAnsi(STR0055),OemtoAnsi(STR0058) },; //"<F4>-Pesquisa por Usuario" //"Pq.Usuario"
					{ 'GROUP',    {|| If(QD080Fold2(lFolder2,.F.), QAD->(fPesqF(oDeptos,2)),) },OemtoAnsi(STR0056),OemtoAnsi(STR0059) },; //"<F5>-Pesquisa por Departamento" //"Pq.Depto"
					{ 'CARGA',    {|| If(QD080Fold2(lFolder2,.F.), QAC->(fPesqF(oCargos,3)),) },OemtoAnsi(STR0057),OemtoAnsi(STR0060) },; //"<F6>-Pesquisa por Funcao" //"Pq.Função"
					{ 'FILTRO',   {|| QDOA080RLG(@oDeptos,@oCargos,@oUsers)                   },OemtoAnsi(STR0077),OemtoAnsi(STR0077) } } // "Oculta/Exibe Filiais"
	
	ACTIVATE MSDIALOG oDlgFolder ON INIT EnchoiceBar(oDlgFolder, { || If(Obrigatorio(aGets,aTela) .And. QD080Fold2(lFolder2,.F.),(lGrava:= .T.,oDlgFolder:End()),.F.)},{ || (lGrava := .F.,oDlgFolder:End())},,;
	Qd080But(nOpc, aButtons, oDeptos, oCargos, oUsers, oDlgFolder))
	
	lGrava := Qd080Grv(nOpc, lGrava)
	
	SetKey( VK_F4 , Nil)
	SetKey( VK_F5 , Nil)
	SetKey( VK_F6 , Nil)
	
	CursorWait()
	If lGrava .AND. !lQGTRM
		Begin Transaction
		
		RecLock( "QDA", .T. )
		FOR nPos := 1 TO QDA->( FCOUNT() )
			If QDA->( FieldName( nPos ) ) == "QDA_FILIAL"
				QDA->( FieldPut( nPos, xFilial( "QDA" ) ) )
			Else
				QDA->( FieldPut( nPos, M->&( FieldName( nPos ) ) ) )
			EndIf
		NEXT
		QDA->QDA_BAIXA := CriaVar( "QDA_BAIXA" )  // Traz o inicializador padrao da variavel
		
		While (GetSX8Len() > nSaveSx8)
			ConfirmSX8()   // Atualiza o ultimo roteiro em SX8
		End
		
		EvalTrigger()      // Executa todos os gatilhos dos SX7
		//Gravacao das chaves dos Campos Memo na Inclusao
		If !Empty(M->QDA_MEMO1)
			MSMM(QDA_CONVOC,,,M->QDA_MEMO1,1,,,"QDA","QDA_CONVOC")
		Endif
		QDA->( MSUnLock() )
		FKCOMMIT()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Baixa o Aviso de Inclusao de Treinamento   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		QDS->(DbSetOrder(2))
		If QDS->(DbSeek(M->QDA_FILIAL+M->QDA_DOCTO+M->QDA_RV+"TRE"))
			While QDS->(!Eof()) .And. 	QDS->QDS_FILIAL+QDS->QDS_DOCTO+QDS->QDS_RV+QDS->QDS_TPPEND == ;
				M->QDA_FILIAL+M->QDA_DOCTO+M->QDA_RV+"TRE"
				If QDS->QDS_PENDEN == "P"
					RecLock("QDS",.F.)
					QDS->QDS_PENDEN := "B"
					QDS->QDS_DTBAIX:= dDataBase
					QDS->QDS_HRBAIX:= SubStr(Time(),1,5)
					QDS->QDS_FMATBX := cMatFil
					QDS->QDS_MATBX  := cMatCod
					QDS->QDS_DEPBX  := cMatDep
					QDS->(MsUnlock())
					FKCOMMIT()
				EndIf
				QDS->(DbSkip())
			EndDo
		EndIf
		
		If ! EMPTY( aUsers )
			FOR nPos := 1 TO LEN( aUsers )
				QAA->( DBGoto( aUsers[ nPos ][ TR_RECNO ] ) )
				If CheckQDO( , QAA->( Recno() ), aUsers ) == hOk
					DBSelectArea( "QAD" )
					QAD->( DBSetOrder(1) )
					If QAD->( DBSeek( xFilial( "QAD",QAA->QAA_FILIAL)  + QAA->QAA_CC ) )
						DBSelectArea( "QD8" )
						QD8->( DBSetOrder(1) )
						If ! QD8->( DBSeek( xFilial( "QDA" ) + M->QDA_ANO + M->QDA_NUMERO + QAA->QAA_FILIAL + QAA->QAA_CC + QAA->QAA_CODFUN + QAA->QAA_MAT ) )
							RecLock( "QD8", .T. )
							QD8->QD8_TIPO   := "N"
							QD8->QD8_FILIAL := xFilial( "QDA" )
							QD8->QD8_ANO    := M->QDA_ANO
							QD8->QD8_NUMERO := M->QDA_NUMERO
							QD8->QD8_FILDEP := QAA->QAA_FILIAL
							QD8->QD8_DEPTO  := QAA->QAA_CC
							QD8->QD8_CARGO  := QAA->QAA_CODFUN
							QD8->QD8_FILMAT := QAA->QAA_FILIAL
							QD8->QD8_MAT    := QAA->QAA_MAT
							QD8->QD8_SELECA := "S"
							QD8->( MsUnlock() )
							FKCOMMIT()
						ENDIF
						
						DBSelectArea( "QDM" )
						QDM->(DbSetOrder(1))
						If ! QDM->( DBSeek( xFilial( "QDA" ) + M->QDA_ANO + M->QDA_NUMERO + QAA->QAA_FILIAL + QAA->QAA_CC + QAA->QAA_CODFUN ) )
							RecLock( "QDM", .T. )
							QDM->QDM_FILIAL := xFilial( "QDA" )
							QDM->QDM_ANO    := M->QDA_ANO
							QDM->QDM_NUMERO := M->QDA_NUMERO
							QDM->QDM_FILMAT := QAA->QAA_FILIAL
							QDM->QDM_DEPTO  := QAA->QAA_CC
							QDM->QDM_CARGO  := QAA->QAA_CODFUN
							QDM->QDM_SELECA := "S"
							MsUnLock()
							FKCOMMIT()
						EndIf 

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Grava Aviso de Agendamento de Treinamento                   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						QDS->(DbSetOrder(1))
						If !QDS->(DbSeek(QAA->QAA_FILIAL+QAA->QAA_MAT+"P"+"TI "+M->QDA_DOCTO+M->QDA_RV+M->QDA_ANO+M->QDA_NUMERO))
							QDXGvAviso("TI ",QAA->QAA_FILIAL,QAA->QAA_MAT,QAA->QAA_CC,M->QDA_DOCTO,M->QDA_RV,M->QDA_ANO+M->QDA_NUMERO,M->QDA_FILIAL)
						Endif
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Envia e-mail para os usuarios envolvidos no Treinamento                         ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If ! EMPTY( QAA->QAA_EMAIL ) .And. QAA->QAA_RECMAI == "1"
							QDOA080Doc(M->QDA_DOCTO,M->QDA_RV,@cTitulo,@cTpDocto,@dDtVig)
							aDiv := { { DTOC( M->QDA_DTINIC ),;
							DTOC( M->QDA_DTFIM ), ;
							M->QDA_LOCAL,         	;
							M->QDA_OBS,           	;
							M->QDA_HORAI,         	;
							M->QDA_HORAF,         	;
							M->QDA_NUMERO,			;
							M->QDA_ANO,         	;
							M->QDA_FILF1,         	;
							M->QDA_MAT1,         	;
							M->QDA_FILF2,         	;
							M->QDA_MAT2,         	;
							M->QDA_FILF3,         	;
							M->QDA_MAT3,         	;
							QDA->QDA_CONVOC       	} }
							fQdoTpMail( aUsrMail,M->QDA_DOCTO,M->QDA_RV,cTitulo,QAA->QAA_EMAIL,;
							"TI",, QAA->QAA_APELID,,,,aDiv,cTpDocto,dDtVig)
						Endif
					EndIf
				EndIf
			NEXT
		EndIf
		
		If ! EMPTY( aDeptos )
			FOR nPos := 1 TO LEN( aDeptos )
				QAD->( DBGoTo( aDeptos[ nPos ][ TR_RECNO ] ) )
				If CheckQDO( , QAD->( Recno() ), aDeptos ) == hOk
					RecLock( "QDL", .T. )
					QDL->QDL_FILIAL := xFilial( "QDA" )
					QDL->QDL_ANO    := M->QDA_ANO
					QDL->QDL_NUMERO := M->QDA_NUMERO
					QDL->QDL_FILMAT := QAD->QAD_FILIAL
					QDL->QDL_DEPTO  := QAD->QAD_CUSTO
					QDL->QDL_SELECA := "S"
					QDL->( MSUnlock() )
					FKCOMMIT()
				EndIf
			NEXT
		EndIf
		
		End Transaction
		
		IF Len(aUsrMail) > 0
			QaEnvMail( aUsrMail ,,,,aUsrMat[5],"1")
		Endif
	ElseIF lGrava .AND. lQGTRM
		
		Begin Transaction
		
		If ! EMPTY( aUsers )
			
			FOR nPos := 1 TO LEN( aUsers )
				QAA->( DBGoto( aUsers[ nPos ][ TR_RECNO ] ) )
				If CheckQDO( , QAA->( Recno() ), aUsers ) == hOk
					
					FOR nPCur := 1 TO LEN( aCursos )
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Grava Solicitacao (necessidade) de Treinamento              ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						IF !QA_GNECTRM(QAA->QAA_MAT,QAA->QAA_NOME,cModoRA3,aCursos[nPcur,3],aCursos[nPcur,4],@aUsrMail,cModoRA1)
							lRetRA3:=.F.
							Loop
						Endif
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Grava Aviso de Agendamento de Treinamento                   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						QDS->(DbSetOrder(1))
						If !QDS->(DbSeek(QAA->QAA_FILIAL+QAA->QAA_MAT+"P"+"TI "+M->QDA_DOCTO+M->QDA_RV+M->QDA_ANO+aCursos[nPCur,3]))
							QDXGvAviso("TI ",QAA->QAA_FILIAL,QAA->QAA_MAT,QAA->QAA_CC,M->QDA_DOCTO,M->QDA_RV,M->QDA_ANO+aCursos[nPCur,3],M->QDA_FILIAL)
						Endif
					Next
					
				EndIf
			NEXT
			
		Endif
		
		IF lRetRA3
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Baixa o Aviso de Inclusao de Treinamento   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			QDS->(DbSetOrder(2))
			If QDS->(DbSeek(M->QDA_FILIAL+M->QDA_DOCTO+M->QDA_RV+"TRE"))
				While QDS->(!Eof()) .And. 	QDS->QDS_FILIAL+QDS->QDS_DOCTO+QDS->QDS_RV+QDS->QDS_TPPEND == ;
					M->QDA_FILIAL+M->QDA_DOCTO+M->QDA_RV+"TRE"
					If QDS->QDS_PENDEN == "P"
						RecLock("QDS",.F.)
						QDS->QDS_PENDEN := "B"
						QDS->QDS_DTBAIX:= dDataBase
						QDS->QDS_HRBAIX:= SubStr(Time(),1,5)
						QDS->QDS_FMATBX := cMatFil
						QDS->QDS_MATBX  := cMatCod
						QDS->QDS_DEPBX  := cMatDep
						QDS->(MsUnlock())
						FKCOMMIT()
					EndIf
					QDS->(DbSkip())
				EndDo
			EndIf
		Endif
		End Transaction
		
		/*
		Pendente implantação futura do EventViewer na issue DMANQUALI-8410
		If Len(aUsrMail) > 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Envia e-mail do Evento 013 SIGATRM                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MEnviaMail("013",aUsrMail)
		EndIf
		*/
		
	Else
		While (GetSX8Len() > nSaveSx8)
			RollBackSX8()
		Enddo
	EndIf
	
	If lGrava
		Qd080Fim(nOpc)
	EndIf
	CursorArrow()
	
	DBSelectArea("QAA")
	SET FILTER TO
	
Else
	Help( " ", 1, "QD_LOGIN") // "O usuario atual nao possui um Login" ### "cadastrado igual ao apelido do configurador."
Endif


RETURN( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QDO080Alter³ Autor ³Edilson M. Nascimento  ³ Data ³ 07/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para alteracao do registro de Treinamentos         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDO080Alter( <cAlias>, <nReg>, <nOpc> )                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ <cAlias> = Alias do arquivo                                 ³±±
±±³          ³ <nReg>   = Numero do registro                               ³±±
±±³          ³ <nOpc>   = Numero da opcao selecionada                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA080                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
FUNCTION QD080Alter( cAlias, nReg, nOpc)

Local aButtons  := {}
Local aDiv      := {}
Local aDptAux   := {}
Local aMemos    := {{"QDA_CONVOC", "QDA_MEMO1"}} // Texto convocacao treinamento
Local aRegDepto := {}
Local aUsrMail  := {}
Local aUsrMat   := QA_USUARIO()
Local bCampo    := {|nCPO| Field(nCPO) }
Local cExpQAA   := ""
Local cMatCod   := aUsrMat[3]
Local cMatDep   := aUsrMat[4]
Local cMatFil   := aUsrMat[2]
Local cTitulo   := ""
Local cTpDocto  := ""
Local dDtVig    := ""
Local i         := 0
Local lApelido  := aUsrMat[1]
Local lGrava    := .F.
Local nPos      := 0
Local oCargos   := NIL
Local oDeptos   := NIL
Local oUsers    := NIL

Private aCargos    := {}
Private aDeptos    := {}
Private aGets[0]
Private aItsCargo  := {}
Private aItsDepto  := {}
Private aItsUser   := {}
Private aTela[0][0]
Private aUsers     := {}
Private aUsrsAux   := {}
Private hNo        := LoadBitmap( GetResources(), "LBNO" )
Private hOk        := LoadBitmap( GetResources(), "LBTIK" )
Private lChkFolder := .T.
Private lFolder2   := .F.
Private nQaConpad  := 3
Private oDlgFolder := NIL
Private oTreina    := NIL

//Chama a validação de compartilhamentos de tabela
If !fVldComp()
	Return .F.
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa campos MEMO                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For i:=1 to Len(aMemos)
	cMemo := aMemos[i][2]
	If ExistIni(cMemo)
		&cMemo := InitPad(GetSx3Cache(cMemo, "X3_RELACAO"))
	Else
		&cMemo := ""
	EndIf
Next i

If lApelido
	DbSelectArea("QAA")
	QAA->(DBSetOrder(1))
	cExpQAA := Qa_FilSitF()
	SET FILTER TO &(cExpQAA)
	QAA->(DbGotop())
	
	DBSelectArea( "QDA" )
	If QDA->QDA_BAIXA != "S"
		
		FOR nPos := 1 TO QDA->( FCount() )
			M->&( Eval( bCampo, nPos )) := QDA->( FieldGet( nPos ) )
		NEXT
		
		Qd080Fil(nOpc)
		
		Qd080Telas(nReg,nOpc,@oDeptos,@oCargos,@oUsers)
		
		aButtons := { 	{ 'BMPGROUP', {|| If(QD080Fold2(lFolder2,.F.), QAA->(fPesqF(oUsers, 1)),)  },OemtoAnsi(STR0055),OemtoAnsi(STR0058) },; //"<F4>-Pesquisa por Usuario" //"Pq.Usuario"
						{ 'GROUP',    {|| If(QD080Fold2(lFolder2,.F.), QAD->(fPesqF(oDeptos, 2)),) },OemtoAnsi(STR0056),OemtoAnsi(STR0059) },; //"<F5>-Pesquisa por Departamento" //"Pq.Depto"
						{ 'CARGA',    {|| If(QD080Fold2(lFolder2,.F.), QAC->(fPesqF(oCargos, 3)),) },OemtoAnsi(STR0057),OemtoAnsi(STR0060) },; //"<F6>-Pesquisa por Funcao" //"Pq.Função"
						{ 'FILTRO',   {|| QDOA080RLG(@oDeptos,@oCargos,@oUsers)                    },OemtoAnsi(STR0077),OemtoAnsi(STR0077) },; //"Oculta/Exibe Filiais"
						{ "IMPRESSAO", { || A080Rel() }, OemToAnsi( STR0028 ) } }  //"Imprimir"
		
		SetKey( VK_F4 , { || If(QD080Fold2(lFolder2,.F.), QAA->(fPesqF(oUsers, 1)),) } )
		SetKey( VK_F5 , { || If(QD080Fold2(lFolder2,.F.), QAD->(fPesqF(oDeptos, 2)),) } )
		SetKey( VK_F6 , { || If(QD080Fold2(lFolder2,.F.), QAC->(fPesqF(oCargos, 3)),) })
		
		ACTIVATE MSDIALOG oDlgFolder ON INIT EnchoiceBar(oDlgFolder,{ || If(Obrigatorio(aGets,aTela) .And. QD080Fold2(lFolder2,.F.),(lGrava:= .T.,oDlgFolder:End()),.F.)},{ || (lGrava := .F.,oDlgFolder:End())},,;
		Qd080But(nOpc, aButtons, oDeptos, oCargos, oUsers, oDlgFolder))
		
		SetKey( VK_F4 , Nil)
		SetKey( VK_F5 , Nil)
		SetKey( VK_F6 , Nil)
		
		lGrava := Qd080Grv(nOpc, lGrava)
		
		CursorWait()
		If lGrava
			Begin Transaction
			RecLock( "QDA", .F. )
			FOR nPos := 1 TO QDA->( FCOUNT() )
				If QDA->( FieldName( nPos ) ) == "QDA_FILIAL"
					QDA->( FieldPut( nPos, xFilial( "QDA" ) ) )
				Else
					QDA->( FieldPut( nPos, M->&( FieldName( nPos ) ) ) )
				EndIf
			NEXT
			QDA->QDA_BAIXA := CriaVar( "QDA_BAIXA" )   // Traz o inicializador padrao da variavel
			
			EvalTrigger()     // Executa todos os gatilhos dos SX7
			If !Empty(M->QDA_MEMO1)
				MSMM(QDA_CONVOC,,,M->QDA_MEMO1,1,,,"QDA","QDA_CONVOC")
			Endif
			QDA->( MsUnlock() )
			FKCOMMIT()

			aUsrsAux := aClone(aUsers)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Elimina do Arq. SX8 os registros que foram desmarcados no LISTBOX de Usuarios. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ! EMPTY( aUsers )
				DBSelectArea( "QD8" )
				QD8->( DBSelectArea(1) )
				QD8->( DBSeek( xFilial( "QDA" ) + M->QDA_ANO + M->QDA_NUMERO ) )
				WHILE QD8->( ! EOF() ) .And. 	xFilial( "QDA" ) + M->QDA_ANO + M->QDA_NUMERO == ;
					QD8->QD8_FILIAL + QD8->QD8_ANO + QD8->QD8_NUMERO
					
					DBSelectArea( "QAA" )
					QAA->( DBSetOrder(1) )
					If QAA->( DBSeek( QD8->QD8_FILMAT + QD8->QD8_MAT ) )
						If CheckQDO( , QAA->( Recno() ), aUsers ) == hNo
							RecLock( "QD8", .F. )
							QD8->QD8_SELECA := "N"
							QD8->( MSUnLock() )
							FKCOMMIT()
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Baixa o Aviso de Agendamente de Treinamento³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							QDS->(DbSetOrder(1))
							If QDS->(DbSeek(QD8->QD8_FILMAT+QD8->QD8_MAT+"P"+"TI "+M->QDA_DOCTO+M->QDA_RV+M->QDA_ANO+M->QDA_NUMERO))
								RecLock("QDS",.F.)
								QDS->QDS_PENDEN := "B"
								QDS->QDS_DTBAIX:= dDataBase
								QDS->QDS_HRBAIX:= SubStr(Time(),1,5)
								QDS->QDS_FMATBX := cMatFil
								QDS->QDS_MATBX  := cMatCod
								QDS->QDS_DEPBX  := cMatDep
								QDS->(MsUnlock())
								FKCOMMIT()
							EndIf
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Envia e-mail para os usuarios excluidos do Treinamento                          ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If ! EMPTY( QAA->QAA_EMAIL ) .And. QAA->QAA_RECMAI == "1"
								QDOA080Doc(M->QDA_DOCTO,M->QDA_RV,@cTitulo,@cTpDocto,@dDtVig)
								aDiv := { {	DTOC( M->QDA_DTINIC ),;
								DTOC( M->QDA_DTFIM ), ;
								M->QDA_LOCAL,         	;
								M->QDA_OBS,           	;
								M->QDA_HORAI,         	;
								M->QDA_HORAF,         	;
								M->QDA_NUMERO,			;
								M->QDA_ANO,         	;
								M->QDA_FILF1,         	;
								M->QDA_MAT1,         	;
								M->QDA_FILF2,         	;
								M->QDA_MAT2,         	;
								M->QDA_FILF3,         	;
								M->QDA_MAT3,         	;
								M->QDA_CONVOC        	} }
								fQdoTpMail( aUsrMail,M->QDA_DOCTO,M->QDA_RV,cTitulo,QAA->QAA_EMAIL,;
								"TD",, QAA->QAA_APELID,,,,aDiv,cTpDocto,dDtVig)
							EndIf
						Else
							If QD8->QD8_SELECA <> "S"
								RecLock( "QD8", .F. )
								QD8->QD8_SELECA := "S"
								IF QD8->QD8_FILDEP <> QAA->QAA_FILIAL
									QD8->QD8_FILDEP := QAA->QAA_FILIAL
								Endif
								IF QD8->QD8_DEPTO <> QAA->QAA_CC	
									QD8->QD8_DEPTO  := QAA->QAA_CC
								Endif
								IF QD8->QD8_CARGO  <> QAA->QAA_CODFUN
									QD8->QD8_CARGO  := QAA->QAA_CODFUN
								Endif
								QD8->( MSUnLock() )
								FKCOMMIT()
								
								
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Grava Aviso de Agendamento de Treinamento                  	³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								QDS->(DbSetOrder(1))
								If !QDS->(DbSeek(QAA->QAA_FILIAL+QAA->QAA_MAT+"P"+"TI "+M->QDA_DOCTO+M->QDA_RV+M->QDA_ANO+M->QDA_NUMERO))
									QDXGvAviso("TI ",QAA->QAA_FILIAL,QAA->QAA_MAT,QAA->QAA_CC,M->QDA_DOCTO,M->QDA_RV,M->QDA_ANO+M->QDA_NUMERO,M->QDA_FILIAL)
								Endif
								
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Envia e-mail para os usuarios incluidos no Treinamento                          ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If ! EMPTY( QAA->QAA_EMAIL ) .And. QAA->QAA_RECMAI == "1"
									QDOA080Doc(M->QDA_DOCTO,M->QDA_RV,@cTitulo,@cTpDocto,@dDtVig)
									aDiv := { { 	DTOC( M->QDA_DTINIC ),;
									DTOC( M->QDA_DTFIM ), ;
									M->QDA_LOCAL,         	;
									M->QDA_OBS,           	;
									M->QDA_HORAI,         	;
									M->QDA_HORAF,         	;
									M->QDA_NUMERO,			;
									M->QDA_ANO,         	;
									M->QDA_FILF1,         	;
									M->QDA_MAT1,         	;
									M->QDA_FILF2,         	;
									M->QDA_MAT2,         	;
									M->QDA_FILF3,         	;
									M->QDA_MAT3,         	;
									M->QDA_CONVOC } }
									fQdoTpMail( aUsrMail,M->QDA_DOCTO,M->QDA_RV,cTitulo,QAA->QAA_EMAIL,;
									"TI",, QAA->QAA_APELID,,,,aDiv,cTpDocto,dDtVig)
								EndIf
							EndIf
						EndIf
						
						/* Elimina os Itens do Vetor */
						If ( nPos := ASCAN( aUsers, {|x| x[ TR_RECNO ] == QAA->( Recno() ) } ) ) != 0
							ADEL( aUsers, nPos )
							ASIZE( aUsers, LEN( aUsers ) -1 )
						EndIf
						
					EndIf
					
					QD8->( DBSkip() )
					
				ENDDO

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Inclui no Arq. SX8 os registros que foram selecionados no LISTBOX de Usuarios.  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If LEN( aUsers ) != 0
					FOR nPos := 1 TO LEN( aUsers )
						QAA->( DBGoto( aUsers[ nPos ][ TR_RECNO ] ) )
						If CheckQDO( , QAA->( Recno() ), aUsers ) == hOk
							DBSelectArea( "QD8" )
							QD8->( DBSetOrder(1) )
							If ! QD8->( DBSeek( xFilial( "QDA" ) + M->QDA_ANO + M->QDA_NUMERO + QAA->QAA_FILIAL + QAA->QAA_CC + QAA->QAA_CODFUN + QAA->QAA_MAT ) )
								RecLock( "QD8", .T. )
								QD8->QD8_TIPO   := "N"
								QD8->QD8_FILIAL := xFilial( "QDA" )
								QD8->QD8_ANO    := M->QDA_ANO
								QD8->QD8_NUMERO := M->QDA_NUMERO
								QD8->QD8_FILDEP := QAA->QAA_FILIAL
								QD8->QD8_DEPTO  := QAA->QAA_CC
								QD8->QD8_CARGO  := QAA->QAA_CODFUN
								QD8->QD8_FILMAT := QAA->QAA_FILIAL
								QD8->QD8_MAT    := QAA->QAA_MAT
								QD8->QD8_SELECA := "S"
								QD8->( MsUnlock() )
								FKCOMMIT()
								
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Grava Aviso de Agendamento de Treinamento                  	³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								QDS->(DbSetOrder(1))
								If !QDS->(DbSeek(QAA->QAA_FILIAL+QAA->QAA_MAT+"P"+"TI "+M->QDA_DOCTO+M->QDA_RV+M->QDA_ANO+M->QDA_NUMERO))
									QDXGvAviso("TI ",QAA->QAA_FILIAL,QAA->QAA_MAT,QAA->QAA_CC,M->QDA_DOCTO,M->QDA_RV,M->QDA_ANO+M->QDA_NUMERO,M->QDA_FILIAL)
								Endif
								
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Envia e-mail para os usuarios envolvidos no Treinamento                         ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If ! EMPTY( QAA->QAA_EMAIL ) .And. QAA->QAA_RECMAI == "1"
									QDOA080Doc(M->QDA_DOCTO,M->QDA_RV,@cTitulo,@cTpDocto,@dDtVig)
									aDiv := { { DTOC( M->QDA_DTINIC ),;
									DTOC( M->QDA_DTFIM ), ;
									M->QDA_LOCAL,         	;
									M->QDA_OBS,           	;
									M->QDA_HORAI,         	;
									M->QDA_HORAF,         	;
									M->QDA_NUMERO,			;
									M->QDA_ANO,         	;
									M->QDA_FILF1,         	;
									M->QDA_MAT1,         	;
									M->QDA_FILF2,         	;
									M->QDA_MAT2,         	;
									M->QDA_FILF3,         	;
									M->QDA_MAT3,         	;
									M->QDA_CONVOC        	} }
									fQdoTpMail( aUsrMail,M->QDA_DOCTO,M->QDA_RV,cTitulo,QAA->QAA_EMAIL,;
									"TI",, QAA->QAA_APELID,,,,aDiv,cTpDocto,dDtVig)
								EndIf
							EndIf
						EndIf
					NEXT
				EndIf
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Elimina do Arq. QDM os registros que foram desmarcados no LISTBOX de Cargos.   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ! EMPTY( aCargos )
				DBSelectArea( "QDM" )
				QDM->( DBSelectArea(1) )
				QDM->( DBSeek( xFilial( "QDA" ) + M->QDA_ANO + M->QDA_NUMERO ) )
				WHILE QDM->( ! EOF() ) .And. xFilial( "QDA" ) + M->QDA_ANO + M->QDA_NUMERO == ;
					QDM->QDM_FILIAL + QDM->QDM_ANO + QDM->QDM_NUMERO
					// A tabela QDM pode ser mais exclusiva que a tabela QAC, mas não o contrário
					DBSelectArea( "QAC" )
					QAC->( DBSetOrder(1) )
					If QAC->( DBSeek( xFilial("QAC",QDM->QDM_FILMAT ) + QDM->QDM_CARGO ) )
						If CheckQDO( , QAC->( Recno() ), aCargos ) == hNo
							RecLock( "QDM", .F. )
							QDM->QDM_SELECA := "N"
							QDM->( MSUnLock() )
							FKCOMMIT()
						Else
							RecLock( "QDM", .F. )
							QDM->QDM_SELECA := "S"
							QDM->( MSUnLock() )
						EndIf
						
						/* Elimina os Itens do Vetor */
						If ( nPos := ASCAN( aCargos, {|x| x[ TR_RECNO ] == QAC->( Recno() ) } ) ) != 0
							ADEL( aCargos, nPos )
							ASIZE( aCargos, LEN( aCargos ) -1 )
						EndIf
						
					EndIf
					
					QDM->( DBSkip() )
					
				ENDDO
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Inclui no Arq. QDM os registros que foram selecionados no LISTBOX de Cargos.    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(aUsrsAux)
					FOR nPos := 1 TO LEN( aUsrsAux )
						QAA->( DBGoto( aUsrsAux[ nPos ][ TR_RECNO ] ) )
						If CheckQDO( , QAA->( Recno() ), aUsrsAux ) == hOk .And. !fPesqQDM(QAA->QAA_FILIAL,QAA->QAA_CC,QAA->QAA_CODFUN)
							If LEN( aCargos ) != 0
								FOR nPos := 1 TO LEN( aCargos )
									QAC->( DBGoTo ( aCargos[ nPos ][ TR_RECNO ] ) )
									If CheckQDO( , QAC->( Recno() ), aCargos ) == hOk
										DbSelectArea("QDM")	
										QDM->(DbSetOrder(1))
										If !(QDM->(DbSeek(xFilial("QDA")+M->QDA_ANO+M->QDA_NUMERO+QAA->QAA_FILIAL+QAA->QAA_CC+QAA->QAA_CODFUN)))
											RecLock( "QDM", .T. )
											QDM->QDM_FILIAL := xFilial( "QDA" )
											QDM->QDM_ANO    := M->QDA_ANO
											QDM->QDM_NUMERO := M->QDA_NUMERO
											QDM->QDM_FILMAT := QAA->QAA_FILIAL
											QDM->QDM_DEPTO  := QAA->QAA_CC
											QDM->QDM_CARGO  := QAA->QAA_CODFUN
											QDM->QDM_SELECA := "S"
											QDM->( MsUnLock() )
											FKCOMMIT()
										Endif
									EndIf
								NEXT
							EndIf
						EndIf	
					Next
				EndIf	
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Elimina do Arq. QDL os registros que foram desmarcados no LISTBOX de Deptos.   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ! EMPTY( aDeptos )
				For nPos := 1 To Len(aDeptos)
					aRegDepto := fBuscaDpto(aDeptos[nPos][1])
					IF !Empty(aRegDepto)
						DBSelectArea( "QDL" )
						QDL->( DBSetOrder(1) )
						QDL->( DBSeek( xFilial( "QDA" ) + aRegDepto[1][2] + aRegDepto[1][3] + aRegDepto[1][4] + aRegDepto[1][5]) )
						IF QDL->( ! EOF() ) .And. xFilial( "QDA" ) + M->QDA_ANO + M->QDA_NUMERO == ;
							QDL->QDL_FILIAL + QDL->QDL_ANO + QDL->QDL_NUMERO

							DBSelectArea( "QAD" )
							QAD->( DBSetOrder(1) )
							If QAD->( DBSeek( xFilial("QAD",QDL->QDL_FILMAT ) + QDL->QDL_DEPTO ) )
							
								If CheckQDO( , QAD->( Recno() ), aDeptos ) == hNo
									RecLock( "QDL", .F. )
									QDL->QDL_SELECA := "N"
									QDL->( MSUnLock() )
									FKCOMMIT()
								Else
									RecLock( "QDL", .F. )
									QDL->QDL_SELECA := "S"
									QDL->( MSUnLock() )
									FKCOMMIT()
								EndIf								
							EndIf	
						ENDIF
					Else
						AAdd(aDptAux,aDeptos[nPos])
					Endif
				Next

				aDeptos := aClone(aDptAux)

				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Inclui no Arq. QDM os registros que foram selecionados no LISTBOX de Cargos.   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If LEN( aDeptos ) != 0
					FOR nPos := 1 TO LEN( aDeptos )
						QAD->( DBGoTo( aDeptos[ nPos ][ TR_RECNO ] ) )
						If CheckQDO( , QAD->( Recno() ), aDeptos ) == hOk
							If !(QDL->( DBSeek( xFilial( "QDA" ) + M->QDA_ANO + M->QDA_NUMERO + QAD->QAD_FILIAL + QAD->QAD_CUSTO) ))
								RecLock( "QDL", .T. )
								QDL->QDL_FILIAL := xFilial( "QDA" )
								QDL->QDL_ANO    := M->QDA_ANO
								QDL->QDL_NUMERO := M->QDA_NUMERO
								QDL->QDL_FILMAT := QAD->QAD_FILIAL
								QDL->QDL_DEPTO  := QAD->QAD_CUSTO
								QDL->QDL_SELECA := "S"
								QDL->( MSUnlock() )
								FKCOMMIT()
							EndIf
						Endif
					NEXT
				EndIf
			EndIf
			End Transaction
			
			IF Len(aUsrMail) > 0
				QaEnvMail(aUsrMail,,,,aUsrMat[5],"1")
			Endif
			
			Qd080Fim(nOpc)
			
		EndIf
		CursorArrow()
		
		DBSelectArea("QAA")
		SET FILTER TO
		
	Else
		Help(" ",1,"QDOA080ALT")  // Nao pode ser efetuada a alteracao desse registro,
	EndIf                        // pois a confirmacao ja foi concluida
	
Else
	Help( " ", 1, "QD_LOGIN") // "O usuario atual nao possui um Login" ### "cadastrado igual ao apelido do configurador."
Endif

RETURN( Nil )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QD080Excl  ³ Autor ³Edilson M. Nascimento  ³ Data ³ 07/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de exclusao de registro de Treinamentos             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD080Excl( <cAlias>, <nReg>, <nOpc> )                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ <cAlias> = Alias do arquivo                                  ³±±
±±³          ³ <nReg>   = Numero do registro                                ³±±
±±³          ³ <nOpc>   = Numero da opcao selecionada                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA080                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION QD080Excl( cAlias, nReg, nOpc)

Local aDiv     := {}
Local aMemos   := {{"QDA_CONVOC", "QDA_MEMO1"}} // Texto convocacao treinamento
Local aUsrMail := {}
Local aUsrMat  := QA_USUARIO()
Local bCampo   := {|nCPO| Field(nCPO) }
Local cExpQAA  := NIL
Local cMatCod  := aUsrMat[3]
Local cMatDep  := aUsrMat[4]
Local cMatFil  := aUsrMat[2]
Local cTitulo  := ""
Local cTpDocto := ""
Local dDtVig   := ""
Local i        := NIL
Local lApelido := aUsrMat[1]
Local lGrava   := .F.
Local nPos     := NIL
Local oCargos  := NIL
Local oDeptos  := NIL
Local oUsers   := NIL

Private aCargos    := {}
Private aDeptos    := {}
Private aGets[0]
Private aItsCargo  := {}
Private aItsDepto  := {}
Private aItsUser   := {}
Private aTela[0][0]
Private aUsers     := {}
Private hNo        := LoadBitmap( GetResources(), "LBNO" )
Private hOK        := LoadBitmap( GetResources(), "LBTIK" )
Private lChkFolder := NIL
Private lFolder2   := .F.
Private nQaConpad  := 3
Private oDlgFolder := NIL
Private oTreina    := NIL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa campos MEMO                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For i:=1 to Len(aMemos)
	cMemo := aMemos[i][2]
	If ExistIni(cMemo)
		&cMemo := InitPad(GetSx3Cache(cMemo, "X3_RELACAO"))
	Else
		&cMemo := ""
	EndIf
Next i

If lApelido
	DbSelectArea("QAA")
	QAA->(DBSetOrder(1))
	cExpQAA := Qa_FilSitF()
	SET FILTER TO &(cExpQAA)
	QAA->(DbGotop())
	
	DBSelectArea("QDA")
	If QDA->QDA_BAIXA != "S"
		
		FOR nPos := 1 TO QDA->( FCount() )
			M->&( Eval( bCampo, nPos )) := QDA->( FieldGet( nPos ) )
		NEXT
		
		Qd080Fil(nOpc)
		
		Qd080Telas(nReg,nOpc,@oDeptos,@oCargos,@oUsers)
		
		ACTIVATE MSDIALOG oDlgFolder;
		ON INIT  EnchoiceBar( oDlgFolder, ;
		{ || ( lGrava := .T., oDlgFolder:End() ) }, ;
		{ || ( lGrava := .F., oDlgFolder:End() ) },,;
		Qd080But(nOpc,, oDeptos, oCargos, oUsers, oDlgFolder))
		
		lGrava := Qd080Grv(nOpc, lGrava)
		
		CursorWait()
		If lGrava
			Begin Transaction
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Elimina os registros do Arq. QD8 envolvidos neste Treinamento.                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DBSelectArea( "QD8" )
			QD8->( DBSetOrder(1) )
			QD8->( DBSeek( xFilial( "QDA" ) + M->QDA_ANO + M->QDA_NUMERO ) )
			WHILE QD8->( ! EOF() ) .And. xFilial( "QDA" ) + M->QDA_ANO + M->QDA_NUMERO == ;
				QD8->QD8_FILIAL + QD8->QD8_ANO + QD8->QD8_NUMERO
				
				DBSelectArea( "QAA" )
				QAA->( DBSetOrder(1) )
				If QAA->( DBSeek( QD8->QD8_FILMAT + QD8->QD8_MAT ) )
					
					If QD8->QD8_SELECA == "S"
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Baixa o Aviso de Agendamente de Treinamento³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						QDS->(DbSetOrder(1))
						If QDS->(DbSeek(QD8->QD8_FILMAT+QD8->QD8_MAT+"P"+"TI "+M->QDA_DOCTO+M->QDA_RV+M->QDA_ANO+M->QDA_NUMERO))
							RecLock("QDS",.F.)
							QDS->QDS_PENDEN := "B"
							QDS->QDS_DTBAIX:= dDataBase
							QDS->QDS_HRBAIX:= SubStr(Time(),1,5)
							QDS->QDS_FMATBX := cMatFil
							QDS->QDS_MATBX  := cMatCod
							QDS->QDS_DEPBX  := cMatDep
							QDS->(MsUnlock())
							FKCOMMIT()
						EndIf
						
						If ! EMPTY( QAA->QAA_EMAIL ) .And. QAA->QAA_RECMAI == "1"
							QDOA080Doc(M->QDA_DOCTO,M->QDA_RV,@cTitulo,@cTpDocto,@dDtVig)
							aDiv := { { DTOC( M->QDA_DTINIC ),;
							DTOC( M->QDA_DTFIM ), ;
							M->QDA_LOCAL,         	;
							M->QDA_OBS,           	;
							M->QDA_HORAI,         	;
							M->QDA_HORAF,         	;
							M->QDA_NUMERO,			;
							M->QDA_ANO,         	;
							M->QDA_FILF1,         	;
							M->QDA_MAT1,         	;
							M->QDA_FILF2,         	;
							M->QDA_MAT2,         	;
							M->QDA_FILF3,         	;
							M->QDA_MAT3,         	;
							M->QDA_CONVOC        	} }
							fQdoTpMail( aUsrMail,M->QDA_DOCTO,M->QDA_RV,cTitulo,QAA->QAA_EMAIL,;
							"TD",, QAA->QAA_APELID,,,,aDiv,cTpDocto,dDtVig)
						EndIf
					EndIf
				EndIf
				
				RecLock( "QD8", .F. )
				QD8->( DBDelete() )
				QD8->( MSUnLock() )
				FKCOMMIT()
				
				QD8->( DBSkip() )
				
			ENDDO
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Elimina os registros do Arq. QDM envolvidos neste Treinamento.                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DBSelectArea( "QDM" )
			QDM->( DBSetOrder(1) )
			QDM->( DBSeek( xFilial( "QDA" ) + M->QDA_ANO + M->QDA_NUMERO ) )
			WHILE QDM->( ! EOF() ) .And. xFilial( "QDA" ) + M->QDA_ANO + M->QDA_NUMERO == ;
				QDM->QDM_FILIAL + QDM->QDM_ANO + QDM->QDM_NUMERO
				
				RecLock( "QDM", .F. )
				QDM->( DBDelete() )
				QDM->( MSUnLock() )
				FKCOMMIT()
				
				QDM->( DBSkip() )
				
			ENDDO
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Elimina os registros do Arq. QDL envolvidos neste Treinamento.                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DBSelectArea( "QDL" )
			QDL->( DBSetOrder(1) )
			QDL->( DBSeek( xFilial( "QDA" ) + M->QDA_ANO + M->QDA_NUMERO ) )
			WHILE QDL->( ! EOF() ) .And. xFilial( "QDA" ) + M->QDA_ANO + M->QDA_NUMERO == ;
				QDL->QDL_FILIAL + QDL->QDL_ANO + QDL->QDL_NUMERO
				
				RecLock( "QDL", .F. )
				QDL->( DBDelete() )
				QDL->( MSUnLock() )
				FKCOMMIT()
				
				QDL->( DBSkip() )
			ENDDO
			RecLock( "QDA", .F. )
			QDA->( DBDelete() )
			QDA->( MSUnLock() )
			FKCOMMIT()
			
			MSMM(QDA->QDA_CONVOC,,,,2)

			MsDocument( 'QDA', QDA->(RecNo()), 2, , 3 ) // Exclui o anexo do treinamento
			
			End Transaction
			
			IF Len(aUsrMail) > 0
				QaEnvMail(aUsrMail,,,,aUsrMat[5],"1")
			Endif
			Qd080Fim(nOpc)
		EndIf
		CursorArrow()
	Else
		Help( " ", 1, "QDOA080JBX" )  // Nao e possivel BAIXAR, ALTERAR ou
	EndIf                            // EXCLUIR este treinamento
	
	DBSelectArea( "QAA" )
	SET FILTER TO
	
Else
	Help( " ", 1, "QD_LOGIN") // "O usuario atual nao possui um Login" ### "cadastrado igual ao apelido do configurador."
Endif

RETURN( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QD080Confir ³ Autor ³Edilson M. Nascimento  ³ Data ³ 07/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para confirmacao do registro de Treinamentos        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD080Confir( <cAlias>, <nReg>, <nOpc> )                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ <cAlias> = Alias do arquivo                                  ³±±
±±³          ³ <nReg>   = Numero do registro                                ³±±
±±³          ³ <nOpc>   = Numero da opcao selecionada                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA080                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD080Confir(cAlias,nReg,nOpc)

Local aButtons    := {}
Local aMemos      := {{"QDA_CONVOC", "QDA_MEMO1"}} // Texto convocacao treinamento
Local aUsrMat     := QA_USUARIO()
Local aUsrsAux    := {}
Local bCampo      := {|nCPO| Field(nCPO) }
Local cExpQAA     := ""
Local cMatCod     := aUsrMat[3]
Local cMatDep     := aUsrMat[4]
Local cMatFil     := aUsrMat[2]
Local dDataFech   := dDataBase
Local i           := 0
Local lApelido    := aUsrMat[1]
Local lFechamento := .F.
Local lGrava      := .F.
Local nPos        := 0
Local oCargos     := NIL
Local oDeptos     := NIL
Local oDlgGetDt   := NIL
Local oUsers      := NIL

Private aCargos    := {}
Private aDeptos    := {}
Private aGets[0]
Private aItsCargo  := {}
Private aItsDepto  := {}
Private aItsUser   := {}
Private aTela[0][0]
Private aUsers     := {}
Private hNo        := LoadBitmap( GetResources(), "LBNO" )
Private hOK        := LoadBitmap( GetResources(), "LBTIK" )
Private lChkFolder := .T.
Private lFolder2   := .F.
Private nQaConpad  := 3
Private oDlgFolder := NIL
Private oTreina    := NIL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa campos MEMO                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For i:=1 to Len(aMemos)
	cMemo := aMemos[i][2]
	If ExistIni(cMemo)
		&cMemo := InitPad(GetSx3Cache(cMemo, "X3_RELACAO"))
	Else
		&cMemo := ""
	EndIf
Next i

If lApelido
	DbSelectArea("QAA")
	QAA->(DBSetOrder(1))
	cExpQAA := Qa_FilSitF()
	SET FILTER TO &(cExpQAA)
	QAA->(DbGotop())
	
	DBSelectArea("QDA")
	If QDA->QDA_BAIXA != "S"
		FOR nPos := 1 TO QDA->( FCount() )
			M->&( Eval( bCampo, nPos )) := QDA->( FieldGet( nPos ) )
		NEXT
		
		Qd080Fil(nOpc)
		
		Qd080Telas(nReg,nOpc,@oDeptos,@oCargos,@oUsers)
		
		aButtons := { 	{ 'BMPGROUP', {|| If(QD080Fold2(lFolder2), QAA->(fPesqF(oUsers, 1)),) },OemtoAnsi(STR0055),OemtoAnsi(STR0058) },;  //"<F4>-Pesquisa por Usuario" //"Pq.Usuario"
						{ 'GROUP',    {|| If(QD080Fold2(lFolder2), QAD->(fPesqF(oDeptos, 2)),) },OemtoAnsi(STR0056),OemtoAnsi(STR0059) },; //"<F5>-Pesquisa por Departamento" //"Pq.Depto"
						{ 'CARGA',    {|| If(QD080Fold2(lFolder2), QAC->(fPesqF(oCargos, 3)),) },OemtoAnsi(STR0057),OemtoAnsi(STR0060)  },;//"<F6>-Pesquisa por Funcao" //"Pq.Função"
						{ "IMPRESSAO", { || A080Rel() }, OemToAnsi( STR0028 ) } }  //"Imprimir"
		
		SetKey( VK_F4 , { || If(QD080Fold2(lFolder2), QAA->(fPesqF(oUsers, 1)),) } )
		SetKey( VK_F5 , { || If(QD080Fold2(lFolder2), QAD->(fPesqF(oDeptos, 2)),) } )
		SetKey( VK_F6 , { || If(QD080Fold2(lFolder2), QAC->(fPesqF(oCargos, 3)),) })
		
		ACTIVATE MSDIALOG oDlgFolder ON INIT EnchoiceBar(oDlgFolder, { || If(Obrigatorio(aGets,aTela) .And. QD080Fold2(lFolder2,.T.),(lGrava:= .T.,oDlgFolder:End()),.F.)},{ || (lGrava := .F.,oDlgFolder:End())},,;
		Qd080But(nOpc, aButtons, oDeptos, oCargos, oUsers, oDlgFolder))
		
		SetKey( VK_F4 , Nil)
		SetKey( VK_F5 , Nil)
		SetKey( VK_F6 , Nil)
		
		lGrava := Qd080Grv(nOpc, lGrava)
		
		If lGrava
			
			DEFINE MSDIALOG  oDlgGetDt;
			TITLE     OemToAnsi( STR0026 );  //"Fechamento"
			FROM      150, 000;
			TO        260, 240;
			PIXEL;
			STYLE     DS_MODALFRAME
			
			@ 010, 010 SAY  OemToAnsi( STR0023 );   //"Data de Fechamento"
			OF   oDlgGetDt;
			PIXEL
			
			@ 010, 065 MSGET  dDataFech;
			OF     oDlgGetDt;
			PIXEL
			
			DEFINE SBUTTON;
			FROM     028, 031;
			TYPE     1;
			ACTION   ( lFechamento := QDOMSGE(dDataFech), If (lFechamento,If( NaoVazio( dDataFech ), ( lFechamento := .T., oDlgGetDt:End() ), ),) );
			ENABLE;
			OF       oDlgGetDt
			
			DEFINE SBUTTON;
			FROM     028, 060;
			TYPE     2;
			ACTION   ( If( NaoVazio( dDataFech ), oDlgGetDt:End(), ), lFechamento := .F. ) ;
			ENABLE;
			OF       oDlgGetDt
			
			ACTIVATE MSDIALOG  oDlgGetDt;
			CENTERED
			
			CursorWait()
			If lFechamento
				RecLock( "QDA", .F. )
				QDA->QDA_BAIXA := "S"
				QDA->QDA_DTFEC := dDataFech
				QDA->( MsUnlock() )
				FKCOMMIT()

				aUsrsAux := aClone(aUsers)
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica a existencia do registro dentro do QD8, mas que por algum motivo nao   ³
				//³ esta mais selecionado dentro do QAA, deve-se justificar no campo QD8_HISTOR.    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ! EMPTY( aUsers )
					DBSelectArea( "QD8" )
					QD8->( DBSelectArea(1) )
					QD8->( DBSeek( xFilial( "QDA" ) + M->QDA_ANO + M->QDA_NUMERO ) )
					WHILE QD8->( ! EOF() ) .And. xFilial( "QDA" ) + M->QDA_ANO + M->QDA_NUMERO == ;
						QD8->QD8_FILIAL + QD8->QD8_ANO + QD8->QD8_NUMERO
						
						DBSelectArea( "QAA" )
						QAA->( DBSetOrder(1) )
						If QAA->( DBSeek( QD8->QD8_FILMAT + QD8->QD8_MAT ) )
							If CheckQDO( , QAA->( Recno() ), aUsers ) == hNo
								RecLock( "QD8", .F. )
								QD8->QD8_SELECA := "N"
								QD8->QD8_BAIXA  := "S"
								If ( nPos := ASCAN( aUsers, { |x| x[ TR_RECNO ] == QAA->( Recno() ) } ) ) != 0
									QD8->QD8_HISTOR := aUsers[ nPos ][ TR_HISTORICO ]
								EndIf
								QD8->( MSUnLock() )
								FKCOMMIT()
							Else
								RecLock( "QD8", .F. )
								QD8->QD8_SELECA := "S"
								QD8->QD8_BAIXA  := "S"
								QD8->QD8_HISTOR := SPACE( LEN( QD8->QD8_HISTOR ) )
								QD8->( MSUnLock() )
								FKCOMMIT()
								
								/* Elimina os Itens do Vetor */
								If ( nPos := ASCAN( aUsers, {|x| x[ TR_RECNO ] == QAA->( Recno() ) } ) ) != 0
									ADEL( aUsers, nPos )
									ASIZE( aUsers, LEN( aUsers ) -1 )
								EndIf
							EndIf
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Baixa o Aviso de Agendamente de Treinamento³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							QDS->(DbSetOrder(1))
							If QDS->(DbSeek(QD8->QD8_FILMAT+QD8->QD8_MAT+"P"+"TI "+M->QDA_DOCTO+M->QDA_RV+M->QDA_ANO+M->QDA_NUMERO))
								RecLock("QDS",.F.)
								QDS->QDS_PENDEN := "B"
								QDS->QDS_DTBAIX:= dDataBase
								QDS->QDS_HRBAIX:= SubStr(Time(),1,5)
								QDS->QDS_FMATBX := cMatFil
								QDS->QDS_MATBX  := cMatCod
								QDS->QDS_DEPBX  := cMatDep
								QDS->(MsUnlock())
								FKCOMMIT()
							EndIf
						EndIf
						QD8->( DBSkip() )
					ENDDO
					
					/* Adiciona os registro Inexistentes dentro do QD8 */
					If LEN( aUsers ) != 0
						FOR nPos := 1 TO LEN( aUsers )
							QAA->( DBGoto( aUsers[ nPos ][ TR_RECNO ] ) )
							DBSelectArea( "QD8" )
							QD8->( DBSetOrder(1) )
							If ! QD8->( DBSeek( xFilial( "QDA" ) + M->QDA_ANO + M->QDA_NUMERO + QAA->QAA_FILIAL + QAA->QAA_CC + QAA->QAA_CODFUN + QAA->QAA_MAT ) )
								RecLock( "QD8", .T. )
								QD8->QD8_TIPO   := "N"
								QD8->QD8_BAIXA  := "S"
								QD8->QD8_FILIAL := xFilial( "QDA" )
								QD8->QD8_ANO    := M->QDA_ANO
								QD8->QD8_NUMERO := M->QDA_NUMERO
								QD8->QD8_FILDEP := QAA->QAA_FILIAL
								QD8->QD8_DEPTO  := QAA->QAA_CC
								QD8->QD8_CARGO  := QAA->QAA_CODFUN
								QD8->QD8_FILMAT := QAA->QAA_FILIAL
								QD8->QD8_MAT    := QAA->QAA_MAT
								QD8->QD8_SELECA := IIf( aUsers[ nPos ][ TR_STATUS ] == "S", "S", "N" )
								If ( nPos := ASCAN( aUsers, { |x| x[ TR_RECNO ] == QAA->( Recno() ) } ) ) != 0
									QD8->QD8_HISTOR := aUsers[ nPos ][ TR_HISTORICO ]
								EndIf
								QD8->( MsUnlock() )
								FKCOMMIT()
							EndIf
						NEXT
					EndIf
				EndIf
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica a existencia do registro dentro do QDM, mas que por algum motivo nao   ³
				//³ esta mais selecionado dentro do QAA, deve-se justificar no campo QDM_HISTOR.    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ! EMPTY( aCargos )
					DBSelectArea( "QDM" )
					QDM->( DBSelectArea(1) )
					QDM->( DBSeek( xFilial( "QDA" ) + M->QDA_ANO + M->QDA_NUMERO ) )
					WHILE QDM->( ! EOF() ) .And. xFilial( "QDA" ) + M->QDA_ANO + M->QDA_NUMERO == ;
						QDM->QDM_FILIAL + QDM->QDM_ANO + QDM->QDM_NUMERO
						
						DBSelectArea( "QAC" )
						QAC->( DBSetOrder(1) )
						// A tabela QDM pode ser mais exclusiva que a tabela QAC, mas não o contrário
						If QAC->( DBSeek( xFilial("QAC",QDM->QDM_FILMAT )  + QDM->QDM_CARGO ) )
							If CheckQDO( , QAC->( Recno() ), aCargos ) == hNo
								RecLock( "QDM", .F. )
								QDM->QDM_SELECA := "N"
								If ( nPos := ASCAN( aCargos, { |x| x[ TR_RECNO ] == QAC->( Recno() ) } ) ) != 0
									QDM->QDM_HISTOR := aCargos[ nPos ][ TR_HISTORICO ]
								EndIf
								QDM->( MSUnLock() )
								FKCOMMIT()
							Else
								RecLock( "QDM", .F. )
								QDM->QDM_SELECA := "S"
								QDM->QDM_HISTOR := SPACE( LEN( QDM->QDM_HISTOR ) )
								QDM->( MSUnLock() )
								FKCOMMIT()
							EndIf
							/* Elimina os Itens do Vetor */
							If ( nPos := ASCAN( aCargos, {|x| x[ TR_RECNO ] == QAC->( Recno() ) } ) ) != 0
								ADEL( aCargos, nPos )
								ASIZE( aCargos, LEN( aCargos ) -1 )
							EndIf
						EndIf
						QDM->( DBSkip() )
					ENDDO

					/* Adiciona os registro Inexistentes dentro do QD8 */
					If !Empty(aUsrsAux)
						FOR nPos := 1 TO LEN( aUsrsAux )
							QAA->( DBGoto( aUsrsAux[ nPos ][ TR_RECNO ] ) )
							If CheckQDO( , QAA->( Recno() ), aUsrsAux ) == hOk .And. !fPesqQDM(QAA->QAA_FILIAL,QAA->QAA_CC,QAA->QAA_CODFUN)
								If LEN( aCargos ) != 0
									FOR nPos := 1 TO LEN( aCargos )
										QAC->( DBGoto( aCargos[ nPos ][ TR_RECNO ] ) )
										If CheckQDO( , QAC->( Recno() ), aCargos ) == hOk
											RecLock( "QDM", .T. )
											QDM->QDM_FILIAL := xFilial( "QDA" )
											QDM->QDM_ANO    := M->QDA_ANO
											QDM->QDM_NUMERO := M->QDA_NUMERO
											QDM->QDM_FILMAT := QAA->QAA_FILIAL
											QDM->QDM_DEPTO  := QAA->QAA_CC
											QDM->QDM_CARGO  := QAA->QAA_CODFUN
											QDM->QDM_SELECA := IIf( aCargos[ nPos ][ TR_STATUS ] == "S", "S", "N" )
											If ( nPos := ASCAN( aCargos, { |x| x[ TR_RECNO ] == QAC->( Recno() ) } ) ) != 0
												QDM->QDM_HISTOR := aCargos[ nPos ][ TR_HISTORICO ]
											EndIf
											QDM->( MsUnLock() )
											FKCOMMIT()
										Endif
									NEXT
								EndIf
							EndIf
						Next
					Endif
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica a existencia do registro dentro do QDL, mas que por algum motivo nao   ³
				//³ esta mais selecionado dentro do QAA, deve-se justificar no campo QDL_HISTOR.    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ! EMPTY( aDeptos )
					DBSelectArea( "QDL" )
					QDL->( DBSetOrder(1) )
					QDL->( DBSeek( xFilial( "QDA" ) + M->QDA_ANO + M->QDA_NUMERO ) )
					WHILE QDL->( ! EOF() ) .And. xFilial( "QDA" ) + M->QDA_ANO + M->QDA_NUMERO == ;
						QDL->QDL_FILIAL + QDL->QDL_ANO + QDL->QDL_NUMERO
						
						DBSelectArea( "QAD" )
						QAD->( DBSetOrder(1) )
						If QAD->( DBSeek( xFilial("QAD",QDL->QDL_FILMAT )  + QDL->QDL_DEPTO ) )
							If CheckQDO( , QAD->( Recno() ), aDeptos ) == hNo
								RecLock( "QDL", .F. )
								QDL->QDL_SELECA := "N"
								If ( nPos := ASCAN( aDeptos, { |x| x[ TR_RECNO ] == QAD->( Recno() ) } ) ) != 0
									QDL->QDL_HISTOR := aDeptos[ nPos ][ TR_HISTORICO ]
								EndIf
								QDL->( MSUnLock() )
								FKCOMMIT()
							Else
								RecLock( "QDL", .F. )
								QDL->QDL_SELECA := "S"
								QDL->QDL_HISTOR := SPACE( LEN( QDL->QDL_HISTOR ) )
								QDL->( MSUnLock() )
								FKCOMMIT()
							EndIf
							
							/* Elimina os Itens do Vetor */
							If ( nPos := ASCAN( aDeptos, {|x| x[ TR_RECNO ] == QAD->( Recno() ) } ) ) != 0
								ADEL( aDeptos, nPos )
								ASIZE( aDeptos, LEN( aDeptos ) -1 )
							EndIf
						EndIf
						QDL->( DBSkip() )
					ENDDO
					
					/* Adiciona os registro Inexistentes dentro do QD8 */
					If LEN( aDeptos ) != 0
						FOR nPos := 1 TO LEN( aDeptos )
							QAD->( DBGoto( aDeptos[ nPos ][ TR_RECNO ] ) )
							RecLock( "QDL", .T. )
							QDL->QDL_FILIAL := xFilial( "QDA" )
							QDL->QDL_ANO    := M->QDA_ANO
							QDL->QDL_NUMERO := M->QDA_NUMERO
							QDL->QDL_FILMAT := QAD->QAD_FILIAL
							QDL->QDL_DEPTO  := QAD->QAD_CUSTO
							QDL->QDL_SELECA := IIf( aDeptos[ nPos ][ TR_STATUS ] == "S", "S", "N" )
							If ( nPos := ASCAN( aDeptos, { |x| x[ TR_RECNO ] == QAD->( Recno() ) } ) ) != 0
								QDL->QDL_HISTOR := aDeptos[ nPos ][ TR_HISTORICO ]
							EndIf
							QDL->( MSUnlock() )
							FKCOMMIT()
						NEXT
					EndIf
				EndIf
			EndIf
			CursorArrow()

		EndIf
	Else
		Help( " ", 1, "QDOA080JBX")  // Nao e possivel BAIXAR, ALTERAR ou
	EndIf                           // EXCLUIR este treinamento
	
	DBSelectArea( "QAA" )
	SET FILTER TO
	
Else
	Help( " ", 1, "QD_LOGIN") // "O usuario atual nao possui um Login" ### "cadastrado igual ao apelido do configurador."
Endif

RETURN( Nil )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A080Historico³ Autor ³Edilson M. Nascimento  ³ Data ³ 07/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para justificar o Treinamentos                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A080Historico( <nRecno>, <aArray> )                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ <nRecno> = Numero do registro selecionado                     ³±±
±±³          ³ <aArray> = Vetor contendo os registro selecionados            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA080                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC FUNCTION A080Historico( nRecno, aArray )

Local oDlgGetHis
Local lGrava     := .F.
Local cHistorico := CriaVar( "QD8_HISTOR" )   // Get do historico
Local nPos


If CheckQDO( , nRecno, aArray ) == hOk
   DEFINE MSDIALOG oDlgGetHis ;
          TITLE    OemToAnsi( STR0022 );  //"Justificativa pela Ausencia"
          FROM     150,   0 ;
          TO       250, 395 ;
          OF       oMainWnd ;
          PIXEL    STYLE DS_MODALFRAME     //"Justificativa pela ausencia"

   @ 10,005 SAY  OemtoAnsi( STR0022 );  //"Justificativa pela Ausencia"
               OF   oDlgGetHis;
               PIXEL

   @ 10,075 MSGET   cHistorico ;
             PICTURE "@!" ;
             OF      oDlgGetHis ;
             SIZE 90,10 ;
             PIXEL

   DEFINE SBUTTON;
          FROM    26, 130;
          TYPE    1;
          ACTION  ( If( NaoVazio( cHistorico ), ( lGrava := .T., oDlgGetHis:End() ), ) ) ;
          ENABLE;
          OF      oDlgGetHis

   DEFINE SBUTTON;
          FROM    26, 160;
          TYPE    2;                   
          ACTION  ( lGrava := .F., oDlgGetHis:end() );
          ENABLE;
          OF      oDlgGetHis 

   ACTIVATE MSDIALOG oDlgGetHis;
            CENTERED 

   If lGrava
      CheckQDO( .F., nRecno, aArray )
      If ( nPos := ASCAN( aArray, { |x| x[ TR_RECNO ] == nRecno } ) ) != 0
         aArray[ nPos ][ TR_HISTORICO ] := cHistorico
      EndIf      
   EndIf

Else
   CheckQDO( .T., nRecno, aArray )
   If ( nPos := ASCAN( aArray, { |x| x[ TR_RECNO ] == nRecno } ) ) != 0  // Elimina a Justificatica do Usuario
      aArray[ nPos ][ TR_HISTORICO ] := ""
   EndIf
EndIf

RETURN( cHistorico )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QD080ReTrei³ Autor ³Edilson M. Nascimento  ³ Data ³ 07/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para Retreinar determinados Documentos              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD080ReTrei( <cAlias>, <nReg>, <nOpc> )                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ <cAlias> = Alias do arquivo                                  ³±±
±±³          ³ <nReg>   = Numero do registro                                ³±±
±±³          ³ <nOpc>   = Numero da opcao selecionada                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA080                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION QD080ReTrei( cAlias, nReg, nOpc)

Local aButtons := Nil
Local aDiv     := {}
Local aMemos   := {{"QDA_CONVOC", "QDA_MEMO1"}} // Texto convocacao treinamento
Local aUsrMail := {}
Local aUsrMat  := QA_USUARIO()
Local bCampo   := {|nCPO| Field(nCPO) }
Local cExpQAA  := Nil
Local cTitulo  := ""
Local cTpDocto := ""
Local dDtVig   := ""
Local i        := Nil
Local lApelido := aUsrMat[1]
Local lGrava   := .F.
Local nPos     := Nil
Local nSaveSX8 := GetSX8Len()
Local oCargos  := Nil
Local oDeptos  := Nil
Local oUsers   := Nil

Private aCargos     := {}
Private aDeptos     := {}
Private aGets[0]
Private aItsCargo   := {}
Private aItsDepto   := {}
Private aItsUser    := {}
Private aTela[0][0]
Private aUsers      := {}
Private cOldDocto   := ""
Private cOldRevisao := ""
Private hNo         := LoadBitmap( GetResources(), "LBNO" )
Private hOK         := LoadBitmap( GetResources(), "LBTIK" )
Private lChkFolder  := NIL
Private lFolder2    := .F.
Private nQaConpad   := 3
Private oDlgFolder  := NIL
Private oTreina     := NIL
            
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa campos MEMO                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For i:=1 to Len(aMemos)
	cMemo := aMemos[i][2]
	If ExistIni(cMemo)
		&cMemo := InitPad(GetSx3Cache(cMemo, "X3_RELACAO"))
	Else
		&cMemo := ""
	EndIf
Next i

If lApelido 
   DbSelectArea("QAA")
   QAA->(DBSetOrder(1))
   cExpQAA := Qa_FilSitF()
   SET FILTER TO &(cExpQAA)
	QAA->(DbGotop())
	
   DBSelectArea("QDA")
   If QDA->QDA_BAIXA == "S"
      	FOR nPos := 1 TO QDA->( FCOUNT() )
          	M->&( EVAL( bCampo, nPos ) ) := QDA->( FieldGet( nPos ) )
          	If UPPER( ALLTRIM( QDA->( FieldName( nPos ) ) ) ) $ "QDA_DTINIC,QDA_DTFIM,QDA_HORAI,QDA_HORAF,QDA_LOCAL,QDA_DTFEC"
             	If     ( VALTYPE( M->&( EVAL( bCampo, nPos ) ) ) == "C" )
                	M->&( EVAL( bCampo, nPos ) ) := SPACE( LEN( M->&( EVAL( bCampo, nPos ) ) ) )
             	ElseIf ( VALTYPE( M->&( EVAL( bCampo, nPos ) ) ) == "N" )
                	M->&( EVAL( bCampo, nPos ) ) := 0
             	ElseIf ( VALTYPE( M->&( EVAL( bCampo, nPos ) ) ) == "D" )
                	M->&( EVAL( bCampo, nPos ) ) := CTOD( "  /  /  ", "DDMMYY" )
             	ElseIf ( VALTYPE( M->&( EVAL( bCampo, nPos ) ) ) == "L" )
                	M->&( EVAL( bCampo, nPos ) ) := .F.
             	EndIf
          	EndIf
          	If QDA->( FieldName( nPos ) ) == "QDA_NUMERO"
             	cOriginal:= QDA->( FieldGet( nPos ) )
             	M->&( EVAL( bCampo, nPos ) ) := GetSX8Num( "QDA", "QDA_NUMERO" )
          	EndIf
          	If QDA->( FieldName( nPos ) ) == "QDA_DTCAD"
             	M->&( EVAL( bCampo, nPos ) ) := dDataBase
          	EndIf     
          	If QDA->( FieldName( nPos ) ) == "QDA_CONVOC"
             	M->&( EVAL( bCampo, nPos ) ) := SPACE( LEN( M->&( EVAL( bCampo, nPos ) ) ) )
           	EndIf
      	NEXT

        Qd080Fil(nOpc)
        
      	Qd080Telas(nReg,nOpc,@oDeptos,@oCargos,@oUsers)
      	
		SetKey( VK_F4 , { || If(QD080Fold2(lFolder2), QAA->(fPesqF(oUsers, 1)),) } )
		SetKey( VK_F5 , { || If(QD080Fold2(lFolder2), QAD->(fPesqF(oDeptos, 2)),) } )
		SetKey( VK_F6 , { || If(QD080Fold2(lFolder2), QAC->(fPesqF(oCargos, 3)),) })
  		aButtons := { 	{ 'BMPGROUP', {|| If(QD080Fold2(lFolder2), QAA->(fPesqF(oUsers, 1)),) },OemtoAnsi(STR0055),OemtoAnsi(STR0058) },;  //"<F4>-Pesquisa por Usuario" //"Pq.Usuario"
						{ 'GROUP',    {|| If(QD080Fold2(lFolder2), QAD->(fPesqF(oDeptos, 2)),) },OemtoAnsi(STR0056),OemtoAnsi(STR0059) },; //"<F5>-Pesquisa por Departamento" //"Pq.Depto"
						{ 'CARGA',    {|| If(QD080Fold2(lFolder2), QAC->(fPesqF(oCargos, 3)),) },OemtoAnsi(STR0057),OemtoAnsi(STR0060) } } //"<F6>-Pesquisa por Funcao" //"Pq.Função"

	   	ACTIVATE MSDIALOG oDlgFolder ON INIT EnchoiceBar(oDlgFolder, { || If(Obrigatorio(aGets,aTela) .And. QD080Fold2(lFolder2,.T.),(lGrava:= .T.,oDlgFolder:End()),.F.)},{ || (lGrava := .F.,oDlgFolder:End())},,;
		Qd080But(nOpc, aButtons, oDeptos, oCargos, oUsers, oDlgFolder))
   
		SetKey( VK_F4 , Nil)
		SetKey( VK_F5 , Nil)
		SetKey( VK_F6 , Nil)

   		lGrava := Qd080Grv(nOpc, lGrava)
	  
      	CursorWait()
      	If lGrava

         	RecLock( "QDA", .T. ) // No caso de Alteracao 
         	FOR nPos := 1 TO QDA->( FCOUNT() )
            	If QDA->( FieldName( nPos ) ) == "QDA_FILIAL"
               		QDA->( FieldPut( nPos, xFilial( "QDA" ) ) )
            	Else
               		QDA->( FieldPut( nPos, M->&( FieldName( nPos ) ) ) )
            	EndIf
         	NEXT
         	QDA->QDA_BAIXA := CriaVar("QDA_BAIXA")  // Traz o inicializador padrao da variavel

   			While (GetSX8Len() > nSaveSx8)
            	ConfirmSX8()   // Atualiza o ultimo roteiro em SX8
         	Enddo
         	EvalTrigger()     // Executa todos os gatilhos dos SX7
			If !Empty(M->QDA_MEMO1)
				MSMM(QDA_CONVOC,,,M->QDA_MEMO1,1,,,"QDA","QDA_CONVOC")
			Endif
         	QDA->( MSUnLock() )
         	FKCOMMIT()

         	If ! EMPTY( aUsers )
            	DBSelectArea( "QD8" )
            	If ! QD8->( DBSeek( xFilial( "QDA" ) + M->QDA_ANO + M->QDA_NUMERO ) )
               	FOR nPos := 1 TO LEN( aUsers )
                  	QAA->( DBGoto( aUsers[ nPos ][ TR_RECNO ] ) )
		            If CheckQDO( , QAA->( Recno() ), aUsers ) == hOk
	                  	DBSelectArea( "QD8" )
	                  	QD8->( DBSetOrder(1) )
	                  	If ! QD8->( DBSeek( xFilial( "QDA" ) + M->QDA_ANO + M->QDA_NUMERO + QAA->QAA_FILIAL + QAA->QAA_CC + QAA->QAA_CODFUN + QAA->QAA_MAT ) )
	                     	RecLock( "QD8", .T. )
	                     	QD8->QD8_TIPO   := "N"
	                     	QD8->QD8_FILIAL := xFilial( "QDA" )
	                     	QD8->QD8_ANO    := M->QDA_ANO
	                     	QD8->QD8_NUMERO := M->QDA_NUMERO
	                     	QD8->QD8_FILDEP := QAA->QAA_FILIAL
	                     	QD8->QD8_DEPTO  := QAA->QAA_CC
	                     	QD8->QD8_CARGO  := QAA->QAA_CODFUN
	                     	QD8->QD8_FILMAT := QAA->QAA_FILIAL
	                     	QD8->QD8_MAT    := QAA->QAA_MAT
	                     	QD8->QD8_SELECA := "S"
	                     	MsUnlock() 
	                     	FKCOMMIT()
	                    Endif

	                    DBSelectArea( "QDM" )
		            	QDM->(DbSetOrder(1))
	                  	If ! QDM->( DBSeek( xFilial( "QDA" ) + M->QDA_ANO + M->QDA_NUMERO + QAA->QAA_FILIAL + QAA->QAA_CC + QAA->QAA_CODFUN ) )	               
	                     	RecLock( "QDM", .T. )
	                     	QDM->QDM_FILIAL := xFilial( "QDA" )
	                     	QDM->QDM_ANO    := M->QDA_ANO
	                     	QDM->QDM_NUMERO := M->QDA_NUMERO
	                     	QDM->QDM_FILMAT := QAA->QAA_FILIAL
	                     	QDM->QDM_DEPTO  := QAA->QAA_CC
	                     	QDM->QDM_CARGO  := QAA->QAA_CODFUN
	                     	QDM->QDM_SELECA := "S"
	                     	MsUnLock()
	                     	FKCOMMIT()
						EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Grava Aviso de Agendamento de Treinamento                  	³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					
						QDS->(DbSetOrder(1))
						If !QDS->(DbSeek(QAA->QAA_FILIAL+QAA->QAA_MAT+"P"+"TI "+M->QDA_DOCTO+M->QDA_RV+M->QDA_ANO+M->QDA_NUMERO))
							QDXGvAviso("TI ",QAA->QAA_FILIAL,QAA->QAA_MAT,QAA->QAA_CC,M->QDA_DOCTO,M->QDA_RV,M->QDA_ANO+M->QDA_NUMERO,M->QDA_FILIAL)
						Endif	

                     	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	                  	//³ Envia e-mail para os usuarios envolvidos no Treinamento                         ³
	                  	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	                  	If ! EMPTY( QAA->QAA_EMAIL ) .And. QAA->QAA_RECMAI == "1"
							QDOA080Doc(M->QDA_DOCTO,M->QDA_RV,@cTitulo,@cTpDocto,@dDtVig)
							aDiv := { { DTOC( M->QDA_DTINIC ),;
								DTOC( M->QDA_DTFIM ), ;
								M->QDA_LOCAL,         	;
								M->QDA_OBS,           	;
								M->QDA_HORAI,         	;
								M->QDA_HORAF,         	;
								M->QDA_NUMERO,			;
								M->QDA_ANO,         	;
								M->QDA_FILF1,         	;
								M->QDA_MAT1,         	;
								M->QDA_FILF2,         	;
								M->QDA_MAT2,         	;
								M->QDA_FILF3,         	;
								M->QDA_MAT3,         	;
								M->QDA_CONVOC        	} }
	                     	fQdoTpMail( aUsrMail,M->QDA_DOCTO,M->QDA_RV,cTitulo,QAA->QAA_EMAIL,;
	                        	"TI",, QAA->QAA_APELID,,,,aDiv,cTpDocto,dDtVig)
	                  	Endif
					EndIf
               	Next
            	EndIf
         	EndIf

	      	If ! EMPTY( aDeptos )
            	DBSelectArea( "QDL" )     
           		FOR nPos := 1 TO LEN( aDeptos )
               		QAD->( DBGoTo( aDeptos[ nPos ][ TR_RECNO ] ) )
  		            If CheckQDO( , QAD->( Recno() ), aDeptos ) == hOk
			            If ! QDL->( DBSeek( xFilial( "QDL" ) + M->QDA_ANO + M->QDA_NUMERO + QAD->QAD_FILIAL + QAD->QAD_CUSTO) )
		                	RecLock( "QDL", .T. )
		                	QDL->QDL_FILIAL := xFilial( "QDA" )
		                	QDL->QDL_ANO    := M->QDA_ANO
		                	QDL->QDL_NUMERO := M->QDA_NUMERO
		                	QDL->QDL_FILMAT := QAD->QAD_FILIAL
		                	QDL->QDL_DEPTO  := QAD->QAD_CUSTO
		                	QDL->QDL_SELECA := "S"
		                	MSUnlock()
		                	FKCOMMIT()
		                EndIf
		           Endif
               	NEXT           	
         	EndIf
           	IF Len(aUsrMail) > 0
         		QaEnvMail(aUsrMail,,,,aUsrMat[5],"1")
         	Endif	
         
      	Else
   	   		While (GetSX8Len() > nSaveSx8)
            	RollBackSX8()
         	Enddo
      	EndIf
      	CursorArrow()

   Else
      	Help( " ", 1, "QD_NRETREI" )  	// Nao e possivel realizar um retreinamento
   EndIf                            	// de um treinamento ainda nao finalizado

   DBSelectArea( "QAA" )
   SET FILTER TO

Else
	Help( " ", 1, "QD_LOGIN") // "O usuario atual nao possui um Login" ### "cadastrado igual ao apelido do configurador."
Endif

RETURN( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ A080Rel    ³ Autor ³Rodrigo de A. Sartorio ³ Data ³ 02/07/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Lista os relatorios relativos a treinamento                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A080Rel( )                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA080                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A080Rel()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ mv_par01 - Lista Relatorio 1 - Registro 2 - Convocacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Pergunte( "QDA080", .t. )
	If mv_par01 == 1
		QDOR082(.T.)
	Else
		QDOR081()
	EndIf
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QDOA080Load  ³ Autor ³ Edilson M. Nascimento ³ Data ³ 07/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Seleciona Depto, Cargo e Users do respectivo documento         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDOA080Load( <nOpcao>, <cDocumento>, <cRevisao> )              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ <nOpcao>     = Numero do registro                              ³±±
±±³          ³ <cDocumento> = Codigo do Documento                             ³±±
±±³          ³ <cRevisao>   = Numero da Revisao                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA080 ( Windows )                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
STATIC FUNCTION QDOA080Load( nOpcao, cDocumento, cRevisao, lQGTRM, lValida )

Local aAlias     := {}
Local nPos       := 0
Default lValida  := .t.

AADD( aAlias, { "QAD", QAD->( IndexOrd() ), QAD->( Recno() ) } )
AADD( aAlias, { "QAC", QAC->( IndexOrd() ), QAC->( Recno() ) } )
AADD( aAlias, { "QAA", QAA->( IndexOrd() ), QAA->( Recno() ) } )
AADD( aAlias, { "QDJ", QDJ->( IndexOrd() ), QDJ->( Recno() ) } )
AADD( aAlias, { "QDL", QDL->( IndexOrd() ), QDL->( Recno() ) } )
AADD( aAlias, { "QDM", QDM->( IndexOrd() ), QDM->( Recno() ) } )
AADD( aAlias, { "QD1", QD1->( IndexOrd() ), QD1->( Recno() ) } )
AADD( aAlias, { "QD8", QD8->( IndexOrd() ), QD8->( Recno() ) } )

QAA->( DBSetOrder(1) )
QAD->( DBSetOrder(1) )
QAC->( DBSetOrder(1) )
QDL->( DBSetOrder(1) )
QDM->( DBSetOrder(1) )
QD1->( DBSetOrder(1) )
QD8->( DBSetOrder(1) )

If ! EMPTY( nOpcao ) .AND. lValida
	lChkFolder := Obrigatorio( M->aGets, M->aTela )
Endif               

If nOpcao == 3 .Or. nOpcao == 7 // Inclusao && ReTreinamento
	
	If cOldDocto != M->QDA_DOCTO .Or. cOldRevisao != M->QDA_RV
		M->aDeptos     := {}
		M->aCargos     := {}
		M->aUsers      := {}
		M->aContDeptos := {}
		M->aContCargos := {}
		
		DBSelectArea( "QD1" )
		QD1->( DBSeek( xFilial( "QDA" ) + M->QDA_DOCTO + M->QDA_RV ) )
		WHILE QD1->( ! EOF() ) .And. xFilial( "QDA" ) + M->QDA_DOCTO + M->QDA_RV == ;
			QD1->QD1_FILIAL + QD1->QD1_DOCTO + QD1->QD1_RV
			
			If QD1->QD1_TPPEND == PADR( "L", TamSX3( "QD1_TPPEND" )[1] )
				
				DBSelectArea( "QAA" )
				If FWModeAccess("QAA")=='E'
					lSeek := QAA->( DBSeek( QD1->QD1_FILMAT + QD1->QD1_MAT ) )
				Else 
					lSeek := QAA->( DBSeek( xFilial("QAA") + QD1->QD1_MAT ) ) 
				Endif

				If lSeek
					IF !lQGTRM
						CheckQDO( .T., QAA->( Recno() ), M->aUsers )
					Else
						If QAA->QAA_TPUSR=="2"
							QD1->( DBSkip() )
							Loop
						Endif
						CheckQDO( .T., QAA->( Recno() ), M->aUsers )
					Endif
					If QAA->QAA_STATUS <> "2" 
					DBSelectArea( "QAD" )
						If QAD->( DBSeek( xFilial( "QAD",QD1->QD1_FILMAT) + QD1->QD1_DEPTO ) )
							CheckQDO( .T., QAD->( Recno() ), M->aDeptos )
							CheckQuant( .T., QAD->( Recno() ), M->aDeptos )
						EndIf
					Endif
				
				EndIf    
					
				DBSelectArea( "QAC" )
				If QAC->( DBSeek( xFilial( "QAC",QD1->QD1_FILMAT) + QD1->QD1_CARGO ) )
					CheckQDO( .T., QAC->( Recno() ), M->aCargos )
					CheckQuant( .T., QAC->( Recno() ), M->aCargos )
				EndIf
				
			EndIf
			
			QD1->( DBSkip() )
			
		ENDDO
	EndIf
	
	M->cOldDocto   := M->QDA_DOCTO
	M->cOldRevisao := M->QDA_RV
	
Else
	
	If EMPTY( M->aDeptos )
		DBSelectArea( "QDL" )
		QDL->( DBSeek( xFilial( "QDA" ) + M->QDA_ANO + M->QDA_NUMERO ) )
		WHILE QDL->( ! EOF() ) .And. xFilial( "QDA" ) + M->QDA_ANO + M->QDA_NUMERO == ;
			QDL->QDL_FILIAL + QDL->QDL_ANO + QDL->QDL_NUMERO

			If QDL->QDL_SELECA == "S"
				DBSelectArea( "QAD" )
				If QAD->( DBSeek( xFilial("QAD",QDL->QDL_FILMAT) + QDL->QDL_DEPTO ) )
					CheckQDO( .T., QAD->( Recno() ), M->aDeptos )
				EndIf
			EndIf
			
			QDL->( DBSkip() )
			
		ENDDO
	EndIf
	
	If EMPTY( M->aCargos )
		DBSelectArea( "QDM" )
		QDM->( DBSeek( xFilial( "QDA" ) + M->QDA_ANO + M->QDA_NUMERO ) )
		WHILE QDM->( ! EOF() ) .And. xFilial( "QDA" ) + M->QDA_ANO + M->QDA_NUMERO == ;
			QDM->QDM_FILIAL + QDM->QDM_ANO + QDM->QDM_NUMERO
			
			If QDM->QDM_SELECA == "S"
				DBSelectArea( "QAC" )
				If QAC->( DBSeek( xFilial("QAC",QDM->QDM_FILMAT ) + QDM->QDM_CARGO ) )
					CheckQDO( .T., QAC->( Recno() ), M->aCargos )
				EndIf
			EndIf
			
			QDM->( DBSkip() )
			
		ENDDO
	EndIf
	
	If EMPTY( M->aUsers )
		DBSelectArea( "QD8" )
		QD8->( DBSeek( xFilial( "QDA" ) + M->QDA_ANO + M->QDA_NUMERO ) )
		WHILE QD8->( ! EOF() ) .And. xFilial( "QDA" ) + M->QDA_ANO + M->QDA_NUMERO == ;
			QD8->QD8_FILIAL + QD8->QD8_ANO + QD8->QD8_NUMERO
			
			If QD8->QD8_SELECA == "S"
				DBSelectArea( "QAA" )
				If QAA->( DBSeek( xFilial("QAA",QD8->QD8_FILMAT) + QD8->QD8_MAT ) )
					CheckQDO( .T., QAA->( Recno() ), M->aUsers )
				EndIf
				
				DBSelectArea( "QAD" )
				If QAD->( DBSeek( xFilial( "QAD",QD8->QD8_FILMAT ) + QD8->QD8_DEPTO ) )
					CheckQuant( .T., QAD->( Recno() ), M->aDeptos )
				EndIf
				
				DBSelectArea( "QAC" )
				If QAC->( DBSeek( xFilial( "QAC",QD8->QD8_FILMAT ) + QD8->QD8_CARGO ) )
					CheckQuant( .T., QAC->( Recno() ), M->aCargos )
				EndIf
				
			EndIf
			
			QD8->( DBSkip() )
			
		ENDDO
	EndIf
	
EndIf

FOR nPos := 1 TO LEN( aAlias )
	DBSelectArea( aAlias[ nPos ][1] )
	DBSetOrder( aAlias[ nPos ][2] )
	DBGoTop()
NEXT

QAA->(dbSetFilter({||&(Qa_FilSitF())},Qa_FilSitF()))

RETURN( lChkFolder )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QDOSeleDeptAll³ Autor ³ Edilson M. Nascimento ³ Data ³ 07/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Seleciona os Cargos e Usuarios relativos ao Depto. Selecionado ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDOSeleDeptAll( <lOpcao>, <cFilUsr>, <cCusto> )                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ <lOpcao> = Operacao, .T. Marca e .F. Desmarca                  ³±±
±±³          ³ <cFilUsr>= Filial do Depto. Selecionado                        ³±±
±±³          ³ <cCusto> = Codigo do Depto.                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA080 ( Windows )                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC FUNCTION QDOSeleDeptAll( lOpcao, cFilDpto, cCusto, cHistorico )

Local aAlias     := {}
Local cFiltFil   := ""
Local cOldAlias  := ALIAS()
Local cQuery     := ""
Local lQGTRM     := GetMV("MV_QGTRM",.F.,"2")=="1" .AND. GetMv("MV_QGINT")=="S" // "Define se os modulos Quality estÒo integrados com Modulo SIGATRM trabalha em conjunto com MV_QGINT 1=SIM;2=NAO"
Local nOk        := 0
Local nPos       := 0
Local oQLTQueryM := QLTQueryManager():New()

CursorWait()

cHistorico := IIf( VALTYPE( cHistorico ) == "U", "", cHistorico )

AADD( aAlias, { "QAD", QAD->( IndexOrd() ), QAD->( Recno() ) } )
AADD( aAlias, { "QAC", QAC->( IndexOrd() ), QAC->( Recno() ) } )
AADD( aAlias, { "QAA", QAA->( IndexOrd() ), QAA->( Recno() ) } )

DBSelectArea( "QAA" )

cQuery := "SELECT QAA.R_E_C_N_O_ QAARECNO ,QAC.R_E_C_N_O_ QACRECNO, QAD.R_E_C_N_O_ QADRECNO "
cQuery += "FROM " + RetSqlName("QAA")+" QAA, "
cQuery +=           RetSqlName("QAC")+" QAC, "
cQuery +=           RetSqlName("QAD")+" QAD "
cQuery += "WHERE QAA.QAA_CC='"+cCusto+"' AND "

//Filtros Filias QAD Mandante Referente Registro Marcado - INICIO
cFiltFil := oQLTQueryM:MontaQueryComparacaoFiliaisComValorReferencia("QAD", "QAD_FILIAL", "QAD", cFilDpto)
cQuery +=	cFiltFil + " AND "

cFiltFil := oQLTQueryM:MontaQueryComparacaoFiliaisComValorReferencia("QAC", "QAC_FILIAL", "QAD", cFilDpto)
cQuery +=	cFiltFil + " AND "

cFiltFil := oQLTQueryM:MontaQueryComparacaoFiliaisComValorReferencia("QAA", "QAA_FILIAL", "QAD", cFilDpto)
cQuery +=	cFiltFil + " AND "
//Filtros Filias QAD Mandante Referente Registro Marcado - FIM

cQuery += QA_FilSitF(.T.,.T.) + " AND "
If lQGTRM
	cQuery += " QAA.QAA_TPUSR = '1' AND "		
Endif
cQuery += " QAA.QAA_CODFUN = QAC.QAC_FUNCAO AND "
cQuery += " QAA.QAA_CC     = QAD.QAD_CUSTO AND "
cQuery += " QAA.D_E_L_E_T_ = ' ' AND "
cQuery += " QAC.D_E_L_E_T_ = ' ' AND "
cQuery += " QAD.D_E_L_E_T_ = ' ' "

cQuery += " ORDER BY " + SqlOrder("QAARECNO+QACRECNO+QADRECNO")

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPQAA",.T.,.T.)

DbGotop()
If TMPQAA->(Eof())
	Help( " ", 1, "QDOA080NUS" ) // Nao existe usuario cadastrado nesse
EndIf                            // Departamento/Cargo

While TMPQAA->(!Eof())
	CheckQDO( lOpcao, TMPQAA->(QAARECNO), M->aUsers )
	
	/* Trabalha com o Campo Historico do Vetor */
	If ( nPos := ASCAN( M->aUsers, {|x| x[ TR_RECNO ] == TMPQAA->(QAARECNO) } ) ) != 0
		M->aUsers[ nPos ][ TR_HISTORICO ] := cHistorico
	EndIf
	
	/* Trabalha com o Campo Historico do Vetor */
	If ( nPos := ASCAN( M->aCargos, {|x| x[ TR_RECNO ] == TMPQAA->(QACRECNO) } ) ) != 0
		M->aCargos[ nPos ][ TR_HISTORICO ] := cHistorico
	EndIf
	
	nOk:= CheckQuant( ,  TMPQAA->(QACRECNO), M->aCargos )
	IF nOk <= 1
		CheckQDO( lOpcao, TMPQAA->(QACRECNO), M->aCargos )
		CheckQuant( lOpcao, TMPQAA->(QACRECNO), M->aCargos )
	ElseIf nOk >= 2
		CheckQuant( lOpcao, TMPQAA->(QACRECNO), M->aCargos )
	EndIf
	
	/* Trabalha com o Campo Historico do Vetor */
	If ( nPos := ASCAN( M->aDeptos, {|x| x[ TR_RECNO ] == TMPQAA->(QADRECNO) } ) ) != 0
		M->aDeptos[ nPos ][ TR_HISTORICO ] := cHistorico
	EndIf
	
	nOk:= CheckQuant( ,TMPQAA->(QADRECNO), M->aDeptos )
	IF nOk <= 1
		CheckQDO( lOpcao, TMPQAA->(QADRECNO), M->aDeptos )
		CheckQuant( lOpcao,TMPQAA->(QADRECNO), M->aDeptos )
	ElseIf nOk >= 2
		CheckQuant( lOpcao, TMPQAA->(QADRECNO), M->aDeptos )
	EndIf
	
	TMPQAA->(DbSkip())
Enddo
TMPQAA->(DbCLOSEAREA())

FOR nPos := 1 TO LEN( aAlias )
   DBSelectArea( aAlias[ nPos ][1] )
   DBSetOrder( aAlias[ nPos ][2] )
   DBGoTo( aAlias[ nPos ][3] )
NEXT

DBSelectArea( cOldAlias )

CursorArrow()

RETURN( .T. )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QDOSeleCargAll³ Autor ³ Edilson M. Nascimento ³ Data ³ 07/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Seleciona os Depto. e Usuarios relativos ao Cargo Selecionado  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDOSeleCargAll( <lOpcao>, <cFilUsr>, <cCodFunc> )              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ <lOpcao>  = Operacao, .T. Marca e .F. Desmarca                 ³±±
±±³          ³ <cFilUsr> = Filial do Cargo Selecionado                        ³±±
±±³          ³ <cCodFunc>= Codigo do Cargo                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA080 ( Windows )                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC FUNCTION QDOSeleCargAll( lOpcao, cFilCargo, cCodFunc, cHistorico )

Local aAlias     := {}
Local cFiltFil   := ""
Local cOldAlias  := ALIAS()
Local cQuery     := ""
Local lQGTRM     := GetMV("MV_QGTRM",.F.,"2")=="1" .AND. GetMv("MV_QGINT")=="S" // "Define se os modulos Quality estÒo integrados com Modulo SIGATRM trabalha em conjunto com MV_QGINT 1=SIM;2=NAO"
Local nOk        := 0
Local nPos       := 0
Local oQLTQueryM := QLTQueryManager():New()

CursorWait()

cHistorico := IIf( VALTYPE( cHistorico ) == "U", "", cHistorico )

AADD( aAlias, { "QAD", QAD->( IndexOrd() ), QAD->( Recno() ) } )
AADD( aAlias, { "QAC", QAC->( IndexOrd() ), QAC->( Recno() ) } )
AADD( aAlias, { "QAA", QAA->( IndexOrd() ), QAA->( Recno() ) } )

DBSelectArea( "QAA" )

cQuery := "SELECT QAA.R_E_C_N_O_ QAARECNO ,QAC.R_E_C_N_O_ QACRECNO, QAD.R_E_C_N_O_ QADRECNO "
cQuery += "FROM " + RetSqlName("QAA")+" QAA, "
cQuery +=           RetSqlName("QAC")+" QAC, "
cQuery +=           RetSqlName("QAD")+" QAD "
cQuery += "WHERE QAA.QAA_CODFUN='"+cCodFunc+"' AND "

//Filtros Filias QAC Mandante Referente Registro Marcado - INICIO
cFiltFil := oQLTQueryM:MontaQueryComparacaoFiliaisComValorReferencia("QAD", "QAD_FILIAL", "QAC", cFilCargo)
cQuery +=	cFiltFil + " AND "

cFiltFil := oQLTQueryM:MontaQueryComparacaoFiliaisComValorReferencia("QAC", "QAC_FILIAL", "QAC", cFilCargo)
cQuery +=	cFiltFil + " AND "

cFiltFil := oQLTQueryM:MontaQueryComparacaoFiliaisComValorReferencia("QAA", "QAA_FILIAL", "QAC", cFilCargo)
cQuery +=	cFiltFil + " AND "
//Filtros Filias QAC Mandante Referente Registro Marcado - FIM

cQuery += QA_FilSitF(.T.,.T.) + " AND "
If lQGTRM
	cQuery += " QAA.QAA_TPUSR = '1' AND "		
Endif
cQuery += " QAA.QAA_CODFUN = QAC.QAC_FUNCAO AND "
cQuery += " QAA.QAA_CC     = QAD.QAD_CUSTO AND "
cQuery += " QAA.D_E_L_E_T_ = ' ' AND "
cQuery += " QAC.D_E_L_E_T_ = ' ' AND "
cQuery += " QAD.D_E_L_E_T_ = ' ' "

cQuery += " ORDER BY " + SqlOrder("QAARECNO+QACRECNO+QADRECNO")
		
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPQAA",.T.,.T.)

DbGotop()
If TMPQAA->(Eof())
	Help( " ", 1, "QDOA080NUS" ) // Nao existe usuario cadastrado nesse
EndIf                            // Departamento/Cargo

While TMPQAA->(!Eof())			                                                  
	CheckQDO( lOpcao, TMPQAA->(QAARECNO), M->aUsers )
	
	/* Trabalha com o Campo Historico do Vetor */
	If ( nPos := ASCAN( M->aUsers, {|x| x[ TR_RECNO ] == TMPQAA->(QAARECNO) } ) ) != 0
		M->aUsers[ nPos ][ TR_HISTORICO ] := cHistorico
	EndIf
	
	/* Trabalha com o Campo Historico do Vetor */
	If ( nPos := ASCAN( M->aCargos, {|x| x[ TR_RECNO ] == TMPQAA->(QACRECNO) } ) ) != 0
		M->aCargos[ nPos ][ TR_HISTORICO ] := cHistorico
	EndIf
	
	nOk:= CheckQuant( ,  TMPQAA->(QACRECNO), M->aCargos )
	IF nOk <= 1
		CheckQDO( lOpcao, TMPQAA->(QACRECNO), M->aCargos )
		CheckQuant( lOpcao, TMPQAA->(QACRECNO), M->aCargos )
	ElseIf nOk >= 2
		CheckQuant( lOpcao, TMPQAA->(QACRECNO), M->aCargos )
	EndIf
	
	/* Trabalha com o Campo Historico do Vetor */
	If ( nPos := ASCAN( M->aDeptos, {|x| x[ TR_RECNO ] == TMPQAA->(QADRECNO) } ) ) != 0
		M->aDeptos[ nPos ][ TR_HISTORICO ] := cHistorico
	EndIf
	
	nOk:= CheckQuant( ,TMPQAA->(QADRECNO), M->aDeptos )
	IF nOk <= 1
		CheckQDO( lOpcao, TMPQAA->(QADRECNO), M->aDeptos )
		CheckQuant( lOpcao,TMPQAA->(QADRECNO), M->aDeptos )
	ElseIf nOk >= 2
		CheckQuant( lOpcao, TMPQAA->(QADRECNO), M->aDeptos )
	EndIf		
		
	TMPQAA->(DbSkip())
Enddo
TMPQAA->(DbCLOSEAREA())

FOR nPos := 1 TO LEN( aAlias )
   DBSelectArea( aAlias[ nPos ][1] )
   DBSetOrder( aAlias[ nPos ][2] )
   DBGoTo( aAlias[ nPos ][3] )
NEXT

DBSelectArea( cOldAlias )

CursorArrow()

RETURN( .T. )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QDOSeleUserAll³ Autor ³ Edilson M. Nascimento ³ Data ³ 07/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Seleciona os Depto. e Cargos relativos ao User. Selecionado    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDOSeleUserAll( <lOpcao>, <cFilUsr>, <cMatricula> )            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ <lOpcao>    = Operacao, .T. Marca e .F. Desmarca               ³±±
±±³          ³ <cFilUsr>   = Filial do User. Selecionado                      ³±±
±±³          ³ <cMatricula>= Matricula do User. Selecionado                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA080 ( Windows )                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC FUNCTION QDOSeleUserAll( lOpcao, cFilUsr, cMatricula )

Local aAlias     := {}
Local cFiltFil   := ""
Local cOldAlias  := ALIAS()
Local cQuery     := ""
Local lQGTRM     := GetMV("MV_QGTRM",.F.,"2")=="1" .AND. GetMv("MV_QGINT")=="S" // "Define se os modulos Quality estÒo integrados com Modulo SIGATRM trabalha em conjunto com MV_QGINT 1=SIM;2=NAO"
Local nOk        := 0
Local nPos       := 0
Local oQLTQueryM := QLTQueryManager():New()

CursorWait()

AADD( aAlias, { "QAD", QAD->( IndexOrd() ), QAD->( Recno() ) } )
AADD( aAlias, { "QAC", QAC->( IndexOrd() ), QAC->( Recno() ) } )
AADD( aAlias, { "QAA", QAA->( IndexOrd() ), QAA->( Recno() ) } )

QAD->( DBSetOrder(1) )
QAC->( DBSetOrder(1) )
QAA->( DBSetOrder(1) )

DBSelectArea( "QAA" )

cQuery := "SELECT QAA.R_E_C_N_O_ QAARECNO ,QAC.R_E_C_N_O_ QACRECNO, QAD.R_E_C_N_O_ QADRECNO "
cQuery += "FROM " + RetSqlName("QAA")+" QAA, "
cQuery +=           RetSqlName("QAC")+" QAC, "
cQuery +=           RetSqlName("QAD")+" QAD "
cQuery += "WHERE QAA.QAA_MAT   ='"+cMatricula+"' AND "

//Filtros Filias QAA Mandante Referente Registro Marcado - INICIO
cFiltFil := oQLTQueryM:MontaQueryComparacaoFiliaisComValorReferencia("QAD", "QAD_FILIAL", "QAA", cFilUsr)
cQuery +=	cFiltFil + " AND "

cFiltFil := oQLTQueryM:MontaQueryComparacaoFiliaisComValorReferencia("QAC", "QAC_FILIAL", "QAA", cFilUsr)
cQuery +=	cFiltFil + " AND "

cFiltFil := oQLTQueryM:MontaQueryComparacaoFiliaisComValorReferencia("QAA", "QAA_FILIAL", "QAA", cFilUsr)
cQuery +=	cFiltFil + " AND "
//Filtros Filias QAA Mandante Referente Registro Marcado - FIM

cQuery += QA_FilSitF(.T.,.T.) + " AND "                                   
If lQGTRM
	cQuery +=" QAA.QAA_TPUSR = '1' AND "		
Endif
cQuery += " QAA.QAA_CODFUN = QAC.QAC_FUNCAO AND "
cQuery += " QAA.QAA_CC     = QAD.QAD_CUSTO AND "
cQuery += " QAA.D_E_L_E_T_ = ' ' AND "
cQuery += " QAC.D_E_L_E_T_ = ' ' AND "
cQuery += " QAD.D_E_L_E_T_ = ' ' "

cQuery += " ORDER BY " + SqlOrder("QAARECNO+QACRECNO+QADRECNO")
		
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPQAA",.T.,.T.)

DbGotop()		
While TMPQAA->(!Eof())
	CheckQDO( lOpcao, TMPQAA->(QAARECNO), M->aUsers )
					
	nOk:= CheckQuant( ,  TMPQAA->(QACRECNO), M->aCargos )
	IF nOk <= 1
		CheckQDO( lOpcao, TMPQAA->(QACRECNO), M->aCargos )
		CheckQuant( lOpcao, TMPQAA->(QACRECNO), M->aCargos )
	ElseIf nOk >= 2
		CheckQuant( lOpcao, TMPQAA->(QACRECNO), M->aCargos )
	EndIf
					
	nOk:= CheckQuant( ,TMPQAA->(QADRECNO), M->aDeptos )
	IF nOk <= 1
		CheckQDO( lOpcao, TMPQAA->(QADRECNO), M->aDeptos )
		CheckQuant( lOpcao,TMPQAA->(QADRECNO), M->aDeptos )
	ElseIf nOk >= 2
		CheckQuant( lOpcao, TMPQAA->(QADRECNO), M->aDeptos )
	EndIf	
		
	TMPQAA->(DbSkip())
Enddo
TMPQAA->(DbCLOSEAREA())

FOR nPos := 1 TO LEN( aAlias )
   DBSelectArea( aAlias[ nPos ][1] )
   DBSetOrder( aAlias[ nPos ][2] )
   DBGoTo( aAlias[ nPos ][3] )
NEXT

DBSelectArea( cOldAlias )

CursorArrow()

RETURN( .T. )
 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³   CheckQDO   ³ Autor ³ Edilson M. Nascimento ³ Data ³ 07/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Executa a Operacao de Selecao do Registro                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CheckQDO( <lOpcao>, <nItem>, <aArray> )                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ <lOpcao> = Operacao, .T. Marca e .F. Desmarca                  ³±±
±±³          ³ <nItem>  = Numero do Registro Selecionado                      ³±±
±±³          ³ <aArray> = Vetor contendo os registros Selecionados            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA080 ( Windows )                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC FUNCTION CheckQDO( lOpcao, nItem, aArray)

Local oRetValue   := hNo
Local nPos        := 0  
Local nRecno      := IIF(Empty(TR_RECNO), 1, TR_RECNO)
Local nStaus      := IIF(Empty(TR_STATUS), 2, TR_STATUS)

If lOpcao == Nil
   If ( nPos := ASCAN( aArray, { |x| x[ nRecno ] == nItem } ) ) != 0
      If aArray[ nPos ][ nStaus ] == "S"
         oRetValue := hOk
      EndIf
   Endif
Else
  If lOpcao
     If ( nPos := ASCAN( aArray, { |x| x[ nRecno ] == nItem } ) ) == 0
        AADD( aArray, { nItem, "S", 0, "" } )
     Else
        aArray[ nPos ][ nStaus ] := "S"
     Endif
  Else
     If ( nPos := ASCAN( aArray, { |x| x[ nRecno ] == nItem } ) ) != 0
        aArray[ nPos ][ nStaus ] := "N"
     Endif
  Endif
EndIf

RETURN( oRetValue )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³  CheckQUANT  ³ Autor ³ Edilson M. Nascimento ³ Data ³ 07/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Executa a Operacao de Selecao do Registro                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CheckQDO( <lOpcao>, <nItem>, <aArray> )                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ <lOpcao> = Operacao, .T. Marca e .F. Desmarca                  ³±±
±±³          ³ <nItem>  = Numero do Registro Selecionado                      ³±±
±±³          ³ <aArray> = Vetor contendo os registros Selecionados            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA080 ( Windows )                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CheckQUANT(lOpcao,nItem,aArray)

Local nRetValue := 0
Local nPos

If lOpcao == Nil
	If ( nPos := ASCAN( aArray, { |x| x[ TR_RECNO ] == nItem } ) ) != 0
		nRetValue := aArray[ nPos ][ TR_COUNTER ]
	Endif
Else
	If lOpcao
		If ( nPos := ASCAN( aArray, { |x| x[ TR_RECNO ] == nItem } ) ) != 0
			aArray[ nPos ][ TR_COUNTER ] += 1
			nRetValue                    := aArray[ nPos ][ TR_COUNTER ]
		Endif
	Else
		If ( nPos := ASCAN( aArray, { |x| x[ TR_RECNO ] == nItem } ) ) > 0
			If aArray[ nPos ][ TR_COUNTER ] != 0
				aArray[ nPos ][ TR_COUNTER ] -= 1
				nRetValue                    := aArray[ nPos ][ TR_COUNTER ]
			EndIf
		EndIf
	EndIf
EndIf

RETURN( nRetValue )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QDOA080Doc    ³ Autor ³ Eduardo de Souza      ³ Data ³ 26/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega variaveis com Dados do QDH                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDOA080Doc(ExpC1,ExpC2,ExpC3,ExpC4,ExpC5)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpC1 - Codigo do documento                                    ³±±
±±³          ³ ExpC2 - Codigo da Revisao do Documento                         ³±±
±±³          ³ ExpC3 - Titulo do Documento                                    ³±±
±±³          ³ ExpC4 - Tipo de Documento                                      ³±±
±±³          ³ ExpC5 - Data de Vigencia                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA080.PRW                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDOA080Doc(cDocumento,cRevisao,cTitulo,cTpDocto,dDtVig)

Local cOldAlias := ALIAS()
Local nOldOrder := IndexOrd()

DBSelectArea( "QDH" )
QDH->( DBSetOrder(1) )
If QDH->( DBSeek( xFilial( "QDH" ) + cDocumento + cRevisao ) )
	cTitulo := QDH->QDH_TITULO
	cTpDocto:= QDH->QDH_CODTP
	dDtVig  := QDH->QDH_DTVIG
EndIf

DBSelectArea( cOldAlias )
DBSetOrder( nOldOrder )

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QD080VldI ³ Autor ³ Eduardo de Souza      ³ Data ³ 26/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida Instrutores do Treinamento                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD080VldI()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA080                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD080VldI(cFilUsr,cMat)

If !QA_CHKMAT(cFilUsr,cMat,.T.)
	Return .F.
EndIf

If !Empty(M->QDA_MAT1) .And. M->QDA_FILF1+M->QDA_MAT1 == M->QDA_FILF2+M->QDA_MAT2 .Or. ;
	!Empty(M->QDA_MAT1) .And. M->QDA_FILF1+M->QDA_MAT1 == M->QDA_FILF3+M->QDA_MAT3 .Or. ;
	!Empty(M->QDA_MAT2) .And. M->QDA_FILF2+M->QDA_MAT2 == M->QDA_FILF3+M->QDA_MAT3
	
	Help(" ",1,"QDA080INST") // "Instrutor ja cadastrado para este treinamento."
	Return .F.
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QD080Fold2 ³ Autor ³ Eduardo de Souza      ³ Data ³ 26/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se a pasta Treinandos foi selecionada para atuali- ³±±
±±³          ³ zacao dos arquivos.                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD080Fold2(ExpL1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA080                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD080Fold2(lFolder2,lConfTrei)

Default lConfTrei:= .F. // se .T. Chamada pela rotina Confirmacao de Treinamento

/*If !lFolder2
	Help(" ",1,"QD080FOLD2") //  "Para finalizar, selecione a pasta Treinandos."
	Return .F.
EndIf*/

If lConfTrei .And. Ascan(aUsers, { |x| x[2] == "S"}) == 0
	Help("",1,"QD080TREIN") // "Nao e possivel finalizar o treinamento sem" ### "cadastrar os treinandos"
	Return .F.
EndIf
	
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ QD80VDtFim ³ Autor ³ Eduardo de Souza    ³ Data ³ 03/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida a Data Fim do cadastro de Treinamento               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD80VDtFim()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA080                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD080VDtFim()

If !Empty(M->QDA_DTFIM) .And. M->QDA_DTFIM < M->QDA_DTINIC
	Help(" ",1,"QXDTFIM") // "A Data Final nao pode ser menor que a Data de Inicio."
	Return .F.
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ QD80VHrFim ³ Autor ³ Eduardo de Souza    ³ Data ³ 03/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida a Data Fim do cadastro de Treinamento               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD80VHrFim()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA080                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD80VHrFim()


IF ReadVar() == "M->QDA_HORAI"
	IF LEN(ALLTRIM(M->QDA_HORAI)) <>  4 .OR. !QA_VlHr(ALLTRIM(M->QDA_HORAI),.T.)
		Return .F.
	Endif
Endif

IF ReadVar() == "M->QDA_HORAF"
	IF LEN(ALLTRIM(M->QDA_HORAF)) <>  4 .OR. !QA_VlHr(ALLTRIM(M->QDA_HORAF),.T.)
		Return .F.
	Endif
Endif


If !Empty(M->QDA_HORAF) .And. (M->QDA_HORAF <= M->QDA_HORAI) .And.(DTOS(M->QDA_DTFIM) == DTOS(M->QDA_DTINIC))
	Help(" ",1,"QXHRFIM") // "A Hora Final nao pode ser menor que a Hora Inicial."
	Return .F.
EndIf

Return .T.


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ QD080Telas ³ Autor ³ Wagner Mobile Costa ³ Data ³ 13/04/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Monta a tela de treinamento (Inc/Alt/Exc/Retreinar)        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD080Telas()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA080                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD080Telas(nReg,nOpc,oDeptos,oCargos,oUsers,lQGTRM)

Local aArea     := GetArea()
Local aInfo     := {}
Local aObjects  := {{800,600,.T.,.T.}}
Local aPosObj   := {}
Local aSize     := {}
Local cHistory  := ""
Local nIntHei   := 0
Local nIntWid   := 0

Default lQGTRM :=.F.

DbSelectArea("QAD")
QAD->(DbGotop())
aItsDepto := LoadDepto() //Carrega registros de Departamento
If Empty(aItsDepto)
	Help(NIL, NIL, STR0065, NIL, STR0071, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0072}) //#"ATENÇÃO" #"Não foi possível localizar registros de Departamentos para filial logada."#"Por favor cadastre Departamentos ou acesso uma filial com Departamentos"
	RestArea(aArea)
	Return .F.
Endif

DbSelectArea("QAC")
QAC->(DbGotop())
aItsCargo := LoadCargo() //Carrega registros de Cargos
If Empty(aItsCargo)
	Help(NIL, NIL, STR0065, NIL, STR0073, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0074}) //#"ATENÇÃO" #"Não foi possível localizar registros de Cargos para filial logada."#"Por favor cadastre Cargos ou acesso uma filial com Cargos"
	RestArea(aArea)
	Return .F.
Endif

DbSelectArea("QAA")
QAA->(DbGotop())
aItsUser := LoadUser() //Carrega registros de Usuários
If Empty(aItsCargo) .Or. Empty(aItsUser)
	Help(NIL, NIL, STR0065, NIL, STR0075, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0076}) //#"ATENÇÃO"#"Não foi possível localizar registros de Usuários para filial logada."#"Por favor cadastre Usuários ou acesso uma filial com Usuários"
	RestArea(aArea)
	Return .F.
Endif


aSize	:= MsAdvSize(,.F.,400)
aInfo	:= {aSize[1],aSize[2],aSize[3],aSize[4],5,5}
aPosObj := MsObjSize(aInfo,aObjects,.T.)

DEFINE MSDIALOG oDlgFolder FROM aSize[7],000 To aSize[6],aSize[5] OF GetWndDefault();
TITLE OemToAnsi(STR0006)+" - "+ StrTran(aRotina[nOpc][1], "&", "")+IF(lQGTRM,OemToAnsi(" Integrada ao SIGATRM"),"") PIXEL

@ aPosObj[1,1],aPosObj[1,2] FOLDER oTreina PROMPTS OemToAnsi(STR0007),OemToAnsi(STR0008);
SIZE aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1] OF oDlgFolder PIXEL  //"Treinamento"  ### "Treinandos"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Botoes definidos apenas para o folder nao perder o Foco na troca de Folders     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE SBUTTON FROM 5000,5000 TYPE 6 ACTION .T. ENABLE OF oTreina:aDialogs[1]

IF !lQGTRM
	MsMGet():New("QDA",nReg,nOpc,,,,,{005,005,(oTreina:aDialogs[1]:nClientHeight -10 )/2,(oTreina:aDialogs[1]:nClientWidth - 10 )/2},,,,,,oTreina:aDialogs[1])

	oTreina:bSetOption := {|nAtu| ( CursorWait(),      ;
	IIf( nAtu == 1, Nil,(lFolder2:= .T.,QDOA080Load(nOpc,M->QDA_DOCTO,M->QDA_RV,lQGTRM,.t.))), ;
	oDeptos:Refresh(), oCargos:Refresh(),oUsers:Refresh(),CursorArrow()) }
	
Else
	MsMGet():New("QDA",nReg,nOpc,,,,{"QDA_DOCTO","QDA_RV"},{005,005,(oTreina:aDialogs[1]:nClientHeight -10 )/2,(oTreina:aDialogs[1]:nClientWidth - 10 )/2},,,,,,oTreina:aDialogs[1])

	oTreina:bSetOption := {|nAtu| ( ;
	IIf( nAtu == 1, Nil,IF(QA_CURSTRM(M->QDA_DOCTO,M->QDA_RV,@aCursos),(CursorWait(),lFolder2:= .T.,QDOA080Load(nOpc,M->QDA_DOCTO,M->QDA_RV,lQGTRM,.t.)),lFolder2:= .F.)), ;
	oDeptos:Refresh(), oCargos:Refresh(),oUsers:Refresh(),CursorArrow()) }
Endif

oTreina:bChange := {|| If(!(lChkFolder) .And. oTreina:nOption <> 1,oTreina:nOption:=1,"") }

nIntWid := oTreina:aDialogs[2]:nClientWidth		// Area interna Width do Folder 2
nIntHei := oTreina:aDialogs[2]:nClientHeight	// Area interna Height do Folder 2

@ 03,03		SAY OemToAnsi(STR0009) OF oTreina:aDialogs[2] PIXEL //"Departamentos"
oDeptos := TCBrowse():New(10,03,(nIntWid / 4) - 5,(nIntHei / 4) - 20,,{" ", OemToAnsi( STR0018 ) , OemToAnsi( STR0019 ) },,oTreina:aDialogs[2],,,,,,,,,,,,.F.,"QAD",.T.,,.F.)
oDeptos:SetArray(aItsDepto)
oDeptos:bLine := {||{ CheckQDO( , aItsDepto[oDeptos:nAt,4], aDeptos ),;
					  aItsDepto[oDeptos:nAt,1] + "-" + aItsDepto[oDeptos:nAt,2] ,;
					  aItsDepto[oDeptos:nAt,3] } }
oDeptos:Refresh(.T.)



@ 03, 3 + (nIntWid) / 4 SAY OemToAnsi(STR0010) OF oTreina:aDialogs[2] PIXEL //"Cargos"
oCargos := TCBrowse():New(10,3 + (nIntWid) / 4 ,(nIntWid / 4) - 8,(nIntHei / 4) - 20,,{" ",OemToAnsi( STR0018 ),OemToAnsi( STR0019 )},,oTreina:aDialogs[2],,,,,,,,,,,,.F.,"QAC",.T.,,.F.)
oCargos:SetArray(aItsCargo)
oCargos:bLine := {||{ CheckQDO( , aItsCargo[oCargos:nAt,4], aCargos ),;
					  aItsCargo[oCargos:nAt,1] + "-" + aItsCargo[oCargos:nAt,2],;
					  aItsCargo[oCargos:nAt,3] } }
oCargos:Refresh(.T.)


@ 11 + (nIntHei / 4) - 20,03 SAY OemToAnsi(STR0011) OF oTreina:aDialogs[2] PIXEL //"Usuarios"
oUsers := TCBrowse():New( 18 + (nIntHei / 4) - 20,03,(nIntWid / 2) - 8,((nIntHei / 4) - 5),,{" ",OemToAnsi( STR0018 ),OemToAnsi( STR0027 ),OemToAnsi( STR0020 ),OemToAnsi( STR0021 )},,oTreina:aDialogs[2],,,,,,,,,,,,.F.,"QAA",.T.,,.F.)
oUsers:SetArray(aItsUser)
oUsers:bLine := {||{ CheckQDO( , aItsUser[oUsers:nAt,6], aUsers ),;
					  aItsUser[oUsers:nAt,1] + "-" + aItsUser[oUsers:nAt,2],;
                      aItsUser[oUsers:nAt,3],;
                      aItsUser[oUsers:nAt,4],;
                      aItsUser[oUsers:nAt,5] } }
oUsers:Refresh(.T.)

If nOpc <> 2 .And. nOpc # 5
	If nOpc = 6
		oDeptos:bLDbLClick := { || ( cHistory := A080Historico( aItsDepto[oDeptos:nAt,4], aDeptos ),;
		Iif( CheckQDO( , aItsDepto[oDeptos:nAt,4], aDeptos ) == hNo, lOpcao := .F., lOpcao := .T. ),;
		QDOSeleDeptAll( lOpcao, aItsDepto[oDeptos:nAt,1], aItsDepto[oDeptos:nAt,2], cHistory ),;
		oDeptos:UpStable(), oDeptos:Refresh(),;
		oCargos:UpStable(), oCargos:Refresh(),;
		oUsers:UpStable(), oUsers:Refresh() ) }
		
		oCargos:bLDbLClick := { || ( cHistory := A080Historico( aItsCargo[oCargos:nAt,4], aCargos ),;
		Iif( CheckQDO( , aItsCargo[oCargos:nAt,4], aCargos ) == hNo, lOpcao := .F., lOpcao := .T. ),;
		QDOSeleCargAll( lOpcao, aItsCargo[oCargos:nAt,1], aItsCargo[oCargos:nAt,2] ),;
		oDeptos:UpStable(), oDeptos:Refresh(),;
		oCargos:UpStable(), oCargos:Refresh(),;
		oUsers:UpStable(), oUsers:Refresh() ) }
		
		oUsers:bLDbLClick := { || A080Historico(aItsUser[oUsers:nAt,6], aUsers ) }
	Else
		oDeptos:bLDbLClick := { || ( 	Iif( CheckQDO( ,  aItsDepto[oDeptos:nAt,4], aDeptos ) == hNo, lOpcao := .T., lOpcao := .F. ),;
		QDOSeleDeptAll( lOpcao, aItsDepto[oDeptos:nAt,1], aItsDepto[oDeptos:nAt,2] ),;
		oDeptos:UpStable(), oDeptos:Refresh(),;
		oCargos:UpStable(), oCargos:Refresh(),;
		oUsers:UpStable(), oUsers:Refresh() ) }
		
		oCargos:bLDbLClick := { || ( 	Iif( CheckQDO( , aItsCargo[oCargos:nAt,4], aCargos ) == hNo, lOpcao := .T., lOpcao := .F. ),;
		QDOSeleCargAll( lOpcao, aItsCargo[oCargos:nAt,1], aItsCargo[oCargos:nAt,2] ),;
		oDeptos:UpStable(), oDeptos:Refresh(),;
		oCargos:UpStable(), oCargos:Refresh(),;
		oUsers:UpStable(), oUsers:Refresh()) }
		
		oUsers:bLDbLClick := { || ( 	Iif( CheckQDO( , aItsUser[oUsers:nAt,6], aUsers ) == hNo, lOpcao := .T., lOpcao := .F. ),;
		QDOSeleUserAll( lOpcao, aItsUser[oUsers:nAt,1], aItsUser[oUsers:nAt,2] ),;
		oDeptos:UpStable(), oDeptos:Refresh(),;
		oCargos:UpStable(), oCargos:Refresh(),;
		oUsers:UpStable(), oUsers:Refresh(.T.) ) }
	Endif
	QDOA080Load(nOpc,M->QDA_DOCTO,M->QDA_RV,lQGTRM,.f.)

	oDeptos:cToolTip := OemToAnsi( STR0015 )  //"Duplo click para Confirmar/Desconfirmar Deptos."
	oCargos:cToolTip := OemToAnsi( STR0016 )  //"Duplo click para Confirmar/Desconfirmar Cargos"
	oUsers:cToolTip := OemToAnsi( STR0017 )  //"Duplo click para Confirmar/Desconfirmar Usuario"
Endif

RestArea(aArea)
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ QD080But  ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 05/06/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Retorna o botao utilizado na ENCHOICE-BAR do treinamento    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD080But()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA080                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Qd080But(nOpc, aButPad, oDeptos, oCargos, oUsers, oDlg)

Local aButtons := { }, nButtons

DEFAULT aButPad := {}

If ExistBlock("QD080BUT")
	aButtons := ExecBlock("QD080BUT", .F., .F., { nOpc, oDeptos, oCargos, oUsers, oDlg })	
   	If ValType(aButtons) <> "A"
   		aButtons := {}
   	Endif
   	For nButtons := 1 To Len(aButtons)
   		Aadd(aButPad, aButtons[nButtons])
   	Next
Endif

Return aButPad


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ QD080Grv  ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 10/06/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Verifica a existencia do ponto de entrada QD080GRV/Executa  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD080Grv()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA080                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Qd080Grv(nOpc, lGrava)

Local lGrvRec := lGrava

If ExistBlock("QD080GRV")
	lGrava := ExecBlock("QD080GRV", .F., .F., { nOpc, lGrava } )
	If ValType(lGrava) <> "L"
		lGrava := lGrvRec
	Endif
Endif

Return lGrava

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ QD080Fil  ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 10/06/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Verifica a existencia do ponto de entrada QD080FIL/Executa  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD080Fil()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA080                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Qd080Fil(nOpc)

If ExistBlock("QD080FIL")
	ExecBlock("QD080FIL", .F., .F., nOpc )
Endif

Return


/*/ {Protheus.doc} QD080FIM
Ponto de Entrada utilizado para o envio de anexo de evidência de treinamento via Banco de conhecimento.

@type  Function
@author willian.ramalho
@since 02/04/2025
@param nOpc, númerico, Número da opção selecionada
/*/
Function Qd080Fim(nOpc)

If ExistBlock("QD080FIM")
	ExecBlock("QD080FIM", .F., .F., nOpc )
Endif

Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Funcao criacao para compatibilizar a funcao de valid no campo QDA_RV            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Function QDOA080STATUS(cDocto,cRv)

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QDOMSGE   ³ Autor ³ Leandro S Sabino      ³ Data ³ 29/06/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se a data de encerramento e maior que a data de    ³±±
±±³          | inicio do treinamento                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDOMSGE(dDataFe)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA080                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDOMSGE(dDataFe)
Local lFecha := .T.

If (dDataFe < QDA->QDA_DTINIC )
	MsgAlert(STR0061)//"A data de encerramento deve ser maior que a data de inicio do Treinamento."	
	lFecha := .F.
Endif

Return lFecha 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ QD080Legen ³ Autor ³ Paulo Fco. Cruz Nt.	³ Data ³ 08.06.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Cria uma janela contendo a legenda da mBrowse              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD080Legen()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD080Legen()

Local aLegenda := {	{"ENABLE" , STR0063},;	// "Treinamento Fechado"
					{"DISABLE", STR0064} }	// "Treinamento Aberto"


BrwLegenda	(STR0006,STR0062,aLegenda) 	// "Legenda"

Return .T.

/*--------------------------------------------------------------------/
{Protheus.doc} LoadDepto
A função carrega os departamentos de acordo com o compartilhamento de tabela
@type  LoadDepto()
@author thiago.rover
@since 13/11/2020
@version 12.1.27
@see (links_or_references)
/--------------------------------------------------------------------*/
Function LoadDepto(cOrder)
Local aArea      := GetArea()
Local aCarDpt    := {}
Local cAliasQry  := ""
Local cQry       := ""
Local oQLTQueryM := QLTQueryManager():New()

Default cOrder :="QAD_FILIAL+QAD_DESC"

cAliasQry := GetNextAlias()

cQry := " SELECT * "
cQry += " FROM " + RetSqlName("QAD") +" QAD "
cQry += " WHERE QAD.D_E_L_E_T_ = ' ' "

//Filtro pela QDA (Treinamento) mandante para filtro de exibição de registros
If lFiltraFil
	cQry     += " AND " + oQLTQueryM:MontaQueryComparacaoFiliaisComValorReferencia("QAD", "QAD_FILIAL", "QDA", M->QDA_FILIAL)
EndIf

cQry += "ORDER BY " + SqlOrder(cOrder)
cQry := ChangeQuery( cQry )	
dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )	

//Seleciona a tabela 
dbSelectArea(cAliasQry)
dbGoTop()
While (cAliasQry)->(!Eof())
	
	aAdd( aCarDpt, { (cAliasQry)->QAD_FILIAL, (cAliasQry)->QAD_CUSTO ,(cAliasQry)->QAD_DESC, (cAliasQry)->R_E_C_N_O_ } )

(cAliasQry)->(DbSkip())
EndDo

(cAliasQry)->(DbCloseArea())

RestArea(aArea)

Return aCarDpt

/*--------------------------------------------------------------------/
{Protheus.doc} LoadCargo
A função carrega os cargos de acordo com o compartilhamento de tabela
@type  LoadCargo()
@author thiago.rover
@since 13/11/2020
@version 12.1.27
@see (links_or_references)
/--------------------------------------------------------------------*/
Function LoadCargo(cOrder)
Local aArea      := GetArea()
Local aCarCarg   := {}
Local cAliasQry  := ""
Local cQry       := ""
Local oQLTQueryM := QLTQueryManager():New()

Default cOrder := QAC->(IndexKey(2)) //QAC_FILIAL+QAC_DESC

cAliasQry := GetNextAlias()

cQry := " SELECT * "
cQry += " FROM " + RetSqlName("QAC") +" QAC "
cQry += " WHERE QAC.D_E_L_E_T_ = ' ' "

If lFiltraFil
	//Filtro pela QDA (Treinamento) mandante para filtro de exibição de registros
	cQry +=	" AND " + oQLTQueryM:MontaQueryComparacaoFiliaisComValorReferencia("QAC", "QAC_FILIAL", "QDA", M->QDA_FILIAL)
EndIf

cQry += "ORDER BY " + SqlOrder(cOrder)
cQry := ChangeQuery( cQry )	
dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )	

//Seleciona a tabela 
dbSelectArea(cAliasQry)
dbGoTop()
While (cAliasQry)->(!Eof())
	
	aAdd( aCarCarg, { (cAliasQry)->QAC_FILIAL, (cAliasQry)->QAC_FUNCAO, (cAliasQry)->QAC_DESC, (cAliasQry)->R_E_C_N_O_ } )

(cAliasQry)->(DbSkip())
EndDo

(cAliasQry)->(DbCloseArea())

RestArea(aArea)

Return aCarCarg


/*--------------------------------------------------------------------/
{Protheus.doc} LoadUser
A função carrega os usuários de acordo com o compartilhamento de tabela
@type  LoadUser()
@author thiago.rover
@since 13/11/2020
@version 12.1.27
@see (links_or_references)
/--------------------------------------------------------------------*/
Function LoadUser(cOrder)
Local aArea      := GetArea()
Local aCarUsers  := {}
Local cAliasQry  := ""
Local cQry       := ""
Local oQLTQueryM := QLTQueryManager():New()

Default cOrder := "QAA_NOME"

cAliasQry := GetNextAlias()

cQry := " SELECT * "
cQry += "   FROM " + RetSqlName("QAA") +" QAA "
cQry += "  WHERE QAA.D_E_L_E_T_ = ' ' "
cQry += "    AND QAA.QAA_STATUS <> '2' "

If lFiltraFil
	//Filtro pela QDA (Treinamento) mandante para filtro de exibição de registros
	cQry += " AND " + oQLTQueryM:MontaQueryComparacaoFiliaisComValorReferencia("QAA", "QAA_FILIAL", "QDA", M->QDA_FILIAL)
EndIf

cQry += " ORDER BY " + SqlOrder(cOrder)

cQry := ChangeQuery( cQry )	
dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )	

//Seleciona a tabela 
dbSelectArea(cAliasQry)
(cAliasQry)->(dbGoTop())
While (cAliasQry)->(!Eof())
	
	aAdd( aCarUsers, { (cAliasQry)->QAA_FILIAL, (cAliasQry)->QAA_MAT, (cAliasQry)->QAA_NOME ,(cAliasQry)->QAA_CC, (cAliasQry)->QAA_CODFUN, (cAliasQry)->R_E_C_N_O_ } )

(cAliasQry)->(DbSkip())
EndDo

(cAliasQry)->(DbCloseArea())

RestArea(aArea)

Return aCarUsers

/*/{Protheus.doc} fBuscaDpto
Função que retorna o código do Departamento QAD de acordo com o Recno e retorno dos registros da QDL
@type  Function
@author user
@since 26/07/2021
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function fBuscaDpto(cRecNo)
Local aArea	        := GetArea() 
Local aRegQDL       := {}
Local cCodigoQAD    := ""
Local cAliasQAD     := ""
Local cAliasQDL     := ""
Local cQry          := ""

cAliasQAD := GetNextAlias()

cQry := " SELECT * "
cQry += " FROM "+ RetSqlName("QAD") +" QAD "
cQry += " WHERE R_E_C_N_O_ = "+Str(cRecNo)
cQry += " AND D_E_L_E_T_ = ' ' "
cQry := ChangeQuery( cQry )	
dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQAD, .F., .T. )	

If (cAliasQAD)->( !Eof() )        
	cCodigoQAD := (cAliasQAD)->(QAD_CUSTO)
EndIf

(cAliasQAD)->(DbCloseArea())

RestArea(aArea)

//Busca dos registros da QDL

cAliasQDL := GetNextAlias()

cQry := " SELECT * "
cQry += " FROM "+ RetSqlName("QDL") +" QDL "
cQry += " WHERE QDL_FILIAL= '"+xFilial( "QDA" )+" '"
cQry += " AND QDL_ANO = '"+M->QDA_ANO+" '"
cQry += " AND QDL_NUMERO = '"+M->QDA_NUMERO+" '"
cQry += " AND QDL_DEPTO = '"+cCodigoQAD+" '"
cQry += " AND D_E_L_E_T_ = ' ' "
cQry := ChangeQuery( cQry )	
dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQDL, .F., .T. )	

IF (cAliasQDL)->(!Eof())
	aAdd( aRegQDL, { (cAliasQDL)->QDL_FILIAL, (cAliasQDL)->QDL_ANO, (cAliasQDL)->QDL_NUMERO, (cAliasQDL)->QDL_FILMAT, (cAliasQDL)->QDL_DEPTO } )
Endif

(cAliasQDL)->(DbCloseArea())

RestArea(aArea)
	
Return aRegQDL

/*/{Protheus.doc} fPesqF
Função responsável pela busca e posicionamento dos registros de Usuário, Departamento e Funções atraves dos atalhos 
F4, F5 e F6
@type  Function
@author thiago.rover
@since 19/08/2021
/*/
Static Function fPesqF(oObjGen,nTipo)
Local aCargLoad := {}
Local aContAux  := {}
Local aConteudo := {}
Local aDptoLoad := {}
Local aUserLoad := {}
Local cCodFunc  := ""
Local cDepto    := ""
Local cFil      := ""
Local cGrptmk   := ""
Local cLogin    := ""
Local cNome     := ""
Local cOrder    := Nil
Local cTpOrdem  := ""
Local cUser     := ""

	// Tela com as opções de busca
	aConteudo := Qa_PesquiF()

	If (ValType(aConteudo) != "A")
		Return
	EndIf

	// Valida o tipo de chamada(1=Usuário, 2=Departamento e 3=Função)
	If nTipo == 1

		//Atualiza Ordem da pesquisa
		If Len(aConteudo[1]) >= 1
			cOrder := QAA ->(IndexKey(aConteudo[1][2]))
		Endif

		// Carrega registros de Usuários
		aUserLoad := LoadUser(cOrder)
		aItsUser  := aUserLoad

		// Remove espaços dentro do Array
		aContAux := fRemSpace(aUserLoad)

		// Valida se a opção escolhida é Filial + Cod. Usuário
		If aConteudo[1][2] == 1

			// Remoção da filial 
			cFil  := Alltrim(Left(ALLTRIM(aConteudo[1][1]), AT("-",ALLTRIM(aConteudo[1][1])) -1 ))

			// Remoção da matricula do usuário
			cUser := Alltrim(Right(ALLTRIM(aConteudo[1][1]),Len(ALLTRIM(aConteudo[1][1])) - AT("-",ALLTRIM(aConteudo[1][1]))))
			oObjGen:SetArray(aUserLoad)
			oObjGen:bLine := {||{  CheckQDO( , aUserLoad[oObjGen:nAt,6], aUsers ),;
						aUserLoad[oObjGen:nAt,1] + "-" + aUserLoad[oObjGen:nAt,2],;
						aUserLoad[oObjGen:nAt,3],;
						aUserLoad[oObjGen:nAt,4],;
						aUserLoad[oObjGen:nAt,5] } }
			If Empty(cUser)
				If (nPos:= aScan(aContAux,{|x| x[1] == cFil} )) > 0
					oObjGen:nAt:= nPos
				EndIf
			ElseIF Empty(cFil)
				If (nPos:= aScan(aContAux,{|x| x[2] == cUser} )) > 0
					oObjGen:nAt:= nPos
				EndIf
			Else
				If (nPos:= aScan(aContAux,{|x| x[1]+x[2] == cFil+cUser} )) > 0
					oObjGen:nAt:= nPos
				EndIf
			Endif
			oObjGen:Refresh()
		// Valida se a opção escolhida é Filial + Cod. Depto + Cod. Usuário	
		ElseIf aConteudo[1][2] == 2

			// Remoção da filial 
			cFil := Alltrim(Left(ALLTRIM(aConteudo[1][1]), AT("-",ALLTRIM(aConteudo[1][1])) -1 ))
			
			// Remoção do Código do Departamento
			cDepto := Right(ALLTRIM(aConteudo[1][1]),Len(ALLTRIM(aConteudo[1][1])) - AT("-",ALLTRIM(aConteudo[1][1])))
			cDepto := ALLTRIM(Left(cDepto, aConteudo[1][3][2][3]))

			// Remoção matricula do usuário
			cUser  := Alltrim(Right(aConteudo[1][1],aConteudo[1][3][3][3]))
			oObjGen:SetArray(aUserLoad)
			oObjGen:bLine := {||{  CheckQDO( , aUserLoad[oObjGen:nAt,6], aUsers ),;
						aUserLoad[oObjGen:nAt,1] + "-" + aUserLoad[oObjGen:nAt,2],;
						aUserLoad[oObjGen:nAt,3],;
						aUserLoad[oObjGen:nAt,4],;
						aUserLoad[oObjGen:nAt,5] } }
			If Empty(cFil) .And. Empty(cDepto)
				If (nPos:= aScan(aContAux,{|x| x[2] == cUser})) > 0
					oObjGen:nAt:= nPos
				EndIf
			ElseIf Empty(cFil) .And. Empty(cUser)
				If (nPos:= aScan(aContAux,{|x| x[4] == cDepto})) > 0
					oObjGen:nAt:= nPos
				EndIf
			ElseIf Empty(cDepto) .And. Empty(cUser)
				If (nPos:= aScan(aContAux,{|x| x[1] == cFil})) > 0
					oObjGen:nAt:= nPos
				EndIf
			ElseIf Empty(cDepto)
				If (nPos:= aScan(aContAux,{|x| x[1]+x[2] == cFil+cUser})) > 0
					oObjGen:nAt:= nPos
				EndIf
			ElseIF Empty(cUser)
				If (nPos:= aScan(aContAux,{|x| x[1]+x[4] == cFil+cDepto})) > 0
					oObjGen:nAt:= nPos
				EndIf
			ElseIF Empty(cFil)
				If (nPos:= aScan(aContAux,{|x| x[4]+x[2] == cDepto+cUser})) > 0
					oObjGen:nAt:= nPos
				EndIf
			Else
				If (nPos:= aScan(aContAux,{|x| x[1]+x[4]+x[2] == cFil+cDepto+cUser})) > 0
					oObjGen:nAt:= nPos
				EndIf
			Endif
			oObjGen:Refresh()
		// Valida se a opção escolhida é Filial + Nome do Usuário + Cod. Usuário		
		ElseIf aConteudo[1][2] == 3

			// Remoção da filial 
			cFil := Alltrim(Left(ALLTRIM(aConteudo[1][1]), AT("-",ALLTRIM(aConteudo[1][1])) -1 ))

			// Remoção do nome do usuário e  Tipo de Ordenação
			cNome := Right(ALLTRIM(aConteudo[1][1]),Len(ALLTRIM(aConteudo[1][1])) - AT("-",ALLTRIM(aConteudo[1][1])))
			cTpOrdem := Substring(cNome,aConteudo[1][3][2][3]+1,1)
			cNome := ALLTRIM(Left(cNome, aConteudo[1][3][2][3]))

			// Remoção matricula do usuário
			cUser  := Alltrim(Right(aConteudo[1][1],aConteudo[1][3][4][3]))
			oObjGen:SetArray(aUserLoad)
			oObjGen:bLine := {||{  CheckQDO( , aUserLoad[oObjGen:nAt,6], aUsers ),;
						aUserLoad[oObjGen:nAt,1] + "-" + aUserLoad[oObjGen:nAt,2],;
						aUserLoad[oObjGen:nAt,3],;
						aUserLoad[oObjGen:nAt,4],;
						aUserLoad[oObjGen:nAt,5] } }
			IF Empty(cFil) .And. Empty(cNome)
				If (nPos:= aScan(aContAux,{|x| x[2] == cUser})) > 0
					oObjGen:nAt:= nPos
				EndIf
			ElseIF Empty(cFil) .And. Empty(cUser)
				If (nPos:= aScan(aContAux,{|x| Iif(cTpOrdem == "1",cNome == left(x[3],Len(cNome)),cNome $ x[3])})) > 0
					oObjGen:nAt:= nPos
				EndIf
			ElseIF Empty(cNome) .And. Empty(cUser)
				If (nPos:= aScan(aContAux,{|x| x[1] == cFil})) > 0
					oObjGen:nAt:= nPos
				EndIf
			ElseIF Empty(cNome)
				If (nPos:= aScan(aContAux,{|x| x[1]+x[2] == cFil+cUser})) > 0
					oObjGen:nAt:= nPos
				EndIf
			ElseIF Empty(cUser)
				If (nPos:= aScan(aContAux,{|x| cFil == x[1] .And. Iif(cTpOrdem == "1",cNome == left(x[3],Len(cNome)),cNome $ x[3])})) > 0
					oObjGen:nAt:= nPos
				EndIf
			ElseIF Empty(cFil)
				If (nPos:= aScan(aContAux,{|x| cUser == x[2] .And. Iif(cTpOrdem == "1",cNome == left(x[3],Len(cNome)),cNome $ x[3])})) > 0
					oObjGen:nAt:= nPos
				EndIf
			Else
				If (nPos:= aScan(aContAux,{|x| cFil+cUser == x[1]+x[2] .And. Iif(cTpOrdem == "1",cNome == left(x[3],Len(cNome)),cNome $ x[3])})) > 0
					oObjGen:nAt:= nPos
				EndIf
			EndIf
			oObjGen:Refresh()
		// Valida se a opção escolhida é Filial + Cod. Funcao
		ElseIf aConteudo[1][2] == 4

			// Remoção da filial 
			cFil := Alltrim(Left(ALLTRIM(aConteudo[1][1]), AT("-",ALLTRIM(aConteudo[1][1])) -1 ))

			// Remoção do código da função
			cCodFunc := Alltrim(Right(ALLTRIM(aConteudo[1][1]),Len(ALLTRIM(aConteudo[1][1])) - AT("-",ALLTRIM(aConteudo[1][1]))))
			oObjGen:SetArray(aUserLoad)
			oObjGen:bLine := {||{  CheckQDO( , aUserLoad[oObjGen:nAt,6], aUsers ),;
						aUserLoad[oObjGen:nAt,1] + "-" + aUserLoad[oObjGen:nAt,2],;
						aUserLoad[oObjGen:nAt,3],;
						aUserLoad[oObjGen:nAt,4],;
						aUserLoad[oObjGen:nAt,5] } }
			If Empty(cFil)
				If (nPos:= aScan(aContAux,{|x| x[5] == cCodFunc})) > 0
					oObjGen:nAt:= nPos
				EndIf
			ElseIf Empty(cCodFunc)
				If (nPos:= aScan(aContAux,{|x| x[1] == cFil})) > 0
					oObjGen:nAt:= nPos
				EndIf
			Else
				If (nPos:= aScan(aContAux,{|x| x[1]+x[5] == cFil+cCodFunc})) > 0
					oObjGen:nAt:= nPos
				EndIf
			Endif
			oObjGen:Refresh()
		// Valida se a opção escolhida é Filial + Cod. Depto + Nome do Usuário
		ElseIf aConteudo[1][2] == 5

			// Remoção da filial 
			cFil := Alltrim(Left(ALLTRIM(aConteudo[1][1]), AT("-",ALLTRIM(aConteudo[1][1])) -1 ))

			cDepto := Right(ALLTRIM(aConteudo[1][1]),Len(ALLTRIM(aConteudo[1][1])) - AT("-",ALLTRIM(aConteudo[1][1])))
			// Remoção nome do usuário
			cNome  := Alltrim(Substring(cDepto,aConteudo[1][3][2][3]+1,aConteudo[1][3][3][3]))

			// Remoção do Código do Departamento
			cDepto := ALLTRIM(Left(cDepto, aConteudo[1][3][2][3]))

			// Remoção do Tipo de Ordenação
			cTpOrdem := Alltrim(Right(aConteudo[1][1],aConteudo[1][3][4][3]))


			oObjGen:SetArray(aUserLoad)
			oObjGen:bLine := {||{  CheckQDO( , aUserLoad[oObjGen:nAt,6], aUsers ),;
						aUserLoad[oObjGen:nAt,1] + "-" + aUserLoad[oObjGen:nAt,2],;
						aUserLoad[oObjGen:nAt,3],;
						aUserLoad[oObjGen:nAt,4],;
						aUserLoad[oObjGen:nAt,5] } }
			
			If Len(aUserLoad) < oObjGen:nAt
				oObjGen:nAt := 1
			Endif

			If Empty(cFil) .And. Empty(cDepto)
				If (nPos:= aScan(aContAux,{|x| Iif(cTpOrdem == "1",cNome == left(x[3],Len(cNome)),cNome $ x[3])})) > 0
					oObjGen:nAt:= nPos
				EndIf
			ElseIf Empty(cFil) .And. Empty(cNome)
				If (nPos:= aScan(aContAux,{|x| x[4] == cDepto})) > 0
					oObjGen:nAt:= nPos
				EndIf
			ElseIf Empty(cDepto) .And. Empty(cNome)
				If (nPos:= aScan(aContAux,{|x| x[1] == cFil})) > 0
					oObjGen:nAt:= nPos
				EndIf
			ElseIF Empty(cDepto)
				If (nPos:= aScan(aContAux,{|x| cFil == x[1] .And. Iif(cTpOrdem == "1",cNome == left(x[3],Len(cNome)),cNome $ x[3])})) > 0
					oObjGen:nAt:= nPos
				EndIf
			ElseIF Empty(cNome)
				If (nPos:= aScan(aContAux,{|x| x[1]+x[4] == cFil+cDepto})) > 0
					oObjGen:nAt:= nPos
				EndIf
			ElseIF Empty(cFil)
				If (nPos:= aScan(aContAux,{|x| cDepto == x[4] .And. Iif(cTpOrdem == "1",cNome == left(x[3],Len(cNome)),cNome $ x[3])})) > 0
					oObjGen:nAt:= nPos
				EndIf
			Else
				If (nPos:= aScan(aContAux,{|x| cFil+cDepto == x[1]+x[4] .And. Iif(cTpOrdem == "1",cNome == left(x[3],Len(cNome)),cNome $ x[3])})) > 0
					oObjGen:nAt:= nPos
				EndIf
			Endif
			oObjGen:Refresh()

		// Valida se a opção escolhida é Login Usuário
		ElseIf aConteudo[1][2] == 6

			// Remoção do Login 
			cLogin := Alltrim(Right(ALLTRIM(aConteudo[1][1]),Len(ALLTRIM(aConteudo[1][1])) - AT("-",ALLTRIM(aConteudo[1][1]))))

			// Posiciona na QAA por intermédio do Login e retorna o código da matrícula
			cUser := AllTrim(Posicione("QAA",6,cLogin,"QAA_MAT"))
			oObjGen:SetArray( aUserLoad )
			oObjGen:bLine := {||{  CheckQDO( , aUserLoad[oObjGen:nAt,6], aUsers ),;
						aUserLoad[oObjGen:nAt,1] + "-" + aUserLoad[oObjGen:nAt,2],;
						aUserLoad[oObjGen:nAt,3],;
						aUserLoad[oObjGen:nAt,4],;
						aUserLoad[oObjGen:nAt,5] } }
			If (nPos:= aScan(aContAux,{|x| x[2] == cUser})) > 0
				oObjGen:nAt:= nPos
			EndIf
			oObjGen:Refresh()
		Endif	

	ElseIf nTipo == 2

		//Atualiza Ordem da Pesquisa
		If Len(aConteudo[1]) >= 1
			cOrder := QAD->(IndexKey(aConteudo[1][2]))
		EndIf

		//Carrega registros de Departamento
		aDptoLoad := LoadDepto(cOrder) 
		aItsDepto := aDptoLoad

		// Remove espaços dentro do Array
		aContAux := fRemSpace(aDptoLoad)

		// Valida se a opção escolhida é Código Depto
		If aConteudo[1][2] == 1

			// Remoção do Código do Departamento
			cDepto := Alltrim(Right(ALLTRIM(aConteudo[1][1]),Len(ALLTRIM(aConteudo[1][1])) - AT("-",ALLTRIM(aConteudo[1][1]))))
			oObjGen:SetArray( aDptoLoad )
			oObjGen:bLine := {||{ CheckQDO( , aDptoLoad[oObjGen:nAt,4], aDeptos ),;
						aDptoLoad[oObjGen:nAt,1] + "-" + aDptoLoad[oObjGen:nAt,2] ,;
						aDptoLoad[oObjGen:nAt,3] } }
			If (nPos:= aScan(aContAux,{|x| x[2] == cDepto} )) > 0
				oObjGen:nAt:= nPos
			EndIf
			oObjGen:Refresh()
		// Valida se a opção escolhida é Filial Usuário Responsável + Código Usuário Responsável
		ElseIf aConteudo[1][2] == 2

			// Remoção da filial usuário responsável
			cFil := Left(ALLTRIM(aConteudo[1][1]), AT("-",ALLTRIM(aConteudo[1][1])) -1 )

			// Remoção da matricula do usuário responsável
			cUser  := Alltrim(Right(ALLTRIM(aConteudo[1][1]),Len(ALLTRIM(aConteudo[1][1])) - AT("-",ALLTRIM(aConteudo[1][1]))))

			// Posiciona na QAD por intermédio da filial do user responsável + Usuário responsável e retorna o cod do departamento
			cDepto := AllTrim(Posicione("QAD",2,cFil+cUser,"QAD_CUSTO"))
			cFil := Alltrim(cFil)
			oObjGen:SetArray( aDptoLoad )
			oObjGen:bLine := {||{ CheckQDO( , aDptoLoad[oObjGen:nAt,4], aDeptos ),;
						aDptoLoad[oObjGen:nAt,1] + "-" + aDptoLoad[oObjGen:nAt,2] ,;
						aDptoLoad[oObjGen:nAt,3] } }
			IF Empty(cDepto)
				If (nPos:= aScan(aContAux,{|x| x[1] == cFil} )) > 0
					oObjGen:nAt:= nPos
				EndIf
			ElseIf Empty(cFil)
				If (nPos:= aScan(aContAux,{|x| x[2] == cDepto} )) > 0
					oObjGen:nAt:= nPos
				EndIF	
			Else
				IF (nPos:= aScan(aContAux,{|x| x[1]+x[2] == cFil+cDepto} )) > 0
					oObjGen:nAt:= nPos
				EndIf
			Endif
			oObjGen:Refresh()
		// Valida se a opção escolhida é Grupo Atendimento  	
		Elseif aConteudo[1][2] == 3

			// Remoção do Codigo de Atendimento TMK
			cGrptmk  := Alltrim(Right(ALLTRIM(aConteudo[1][1]),Len(ALLTRIM(aConteudo[1][1])) - AT("-",ALLTRIM(aConteudo[1][1]))))

			// Posiciona na QAD por intermédio da Grupo de Atendimento TMK e retorna o cod do departamento
			cDepto := AllTrim(Posicione("QAD",3,xFilial("QAD")+cGrptmk,"QAD_CUSTO"))
			oObjGen:SetArray( aDptoLoad )
			oObjGen:bLine := {||{ CheckQDO( , aDptoLoad[oObjGen:nAt,4], aDeptos ),;
						aDptoLoad[oObjGen:nAt,1] + "-" + aDptoLoad[oObjGen:nAt,2] ,;
						aDptoLoad[oObjGen:nAt,3] } }
			If (nPos:= aScan(aContAux,{|x| x[2] == cDepto} )) > 0
					oObjGen:nAt:= nPos	
			EndIf
			oObjGen:Refresh()
		Endif

	ElseIf nTipo == 3

		//Atualiza Ordem da Pesquisa
		If Len(aConteudo[1]) >= 1
			cOrder := QAC->(IndexKey(aConteudo[1][2]))
		EndIf

		// Carrega registros de Cargos
		aCargLoad := LoadCargo(cOrder) 
		aItsCargo := aCargLoad

		// Remove espaços dentro do Array
		aContAux := fRemSpace(aCargLoad)

		// Valida se a opção escolhida é Cod. Função
		If aConteudo[1][2] == 1

			// Remoção do codigo da funcao
			cCodFunc := Alltrim(Right(ALLTRIM(aConteudo[1][1]),Len(ALLTRIM(aConteudo[1][1])) - AT("-",ALLTRIM(aConteudo[1][1]))))
			oObjGen:SetArray( aCargLoad )
			oObjGen:bLine := {||{ CheckQDO( , aCargLoad[oObjGen:nAt,4], aCargos ),;
						aCargLoad[oObjGen:nAt,1] + "-" + aCargLoad[oObjGen:nAt,2],;
						aCargLoad[oObjGen:nAt,3] } }
			If (nPos:= aScan(aContAux,{|x| x[2] == cCodFunc})) > 0
				oObjGen:nAt:= nPos
			EndIf
			oObjGen:Refresh()
		// Valida se a opção escolhida é Nome da Função
		Elseif aConteudo[1][2] == 2

			// Remoção do codigo da funcao
			cNomeFunc := Alltrim(Right(ALLTRIM(aConteudo[1][1]),Len(ALLTRIM(aConteudo[1][1])) - AT("-",ALLTRIM(aConteudo[1][1]))))
			cNomeFunc := ALLTRIM(Left(cNomeFunc, aConteudo[1][3][2][3]))

			// Remoção do tipo de ordem
			cTpOrdem := Alltrim(Right(aConteudo[1][1],aConteudo[1][3][3][3]))

			oObjGen:SetArray( aCargLoad )
			oObjGen:bLine := {||{ CheckQDO( , aCargLoad[oObjGen:nAt,4], aCargos ),;
						aCargLoad[oObjGen:nAt,1] + "-" + aCargLoad[oObjGen:nAt,2],;
						aCargLoad[oObjGen:nAt,3] } }
			If (nPos:= aScan(aContAux,{|x| Iif(cTpOrdem == "1",cNomeFunc == left(x[3],Len(cNomeFunc)),cNomeFunc $ x[3])})) > 0
				oObjGen:nAt:= nPos
			EndIf
			oObjGen:Refresh()
		Endif
	Endif

Return

/*/{Protheus.doc} QDOA080RLG
Função responsável pelo recarregamento das grids e alternância da exibição de registros relacionados apenas a filial do treinamento ou não
@type  Function
@author brunno.costa
@since 06/03/2024
@param 01 - oDeptos, objeto, recebe por referência a instância do objeto TCBrowse() de Departamentos
@param 02 - oCargos, objeto, recebe por referência a instância do objeto TCBrowse() de Cargos
@param 03 - oUsers , objeto, recebe por referência a instância do objeto TCBrowse() de Usuários
/*/
Function QDOA080RLG(oDeptos, oCargos, oUsers)

	Local aCargLoad  := {}
	Local aDptoLoad  := {}
	Local aUserLoad  := {}
	Local lDesmarca  := .F.
	Local lProssegue := .T.
	Local nOutros    := 0

	//Alterna controle de exibição
	lFiltraFil := !lFiltraFil

	If lFiltraFil
		//Avalia se existe usuário marcado de outra filial
		If QD080AVOFI(@nOutros) 
			//STR0078 - "Somente os usuários da filial do treinamento serão considerados como treinandos. Esta ação desconsiderará os "
			//STR0079 - " usuários de outras filiais, deseja prosseguir?"
			//STR0080 - "Deseja Prosseguir?"
			If MsgYesNo(STR0078 + cValToChar(nOutros) + STR0079,STR0080)
				lDesmarca  := .T.
			Else
				lProssegue := .F.
				lFiltraFil := !lFiltraFil
			EndIf
		EndIf
	EndIf

	If lProssegue
		//Desmarca Usuários de Outras Filiais
		If lDesmarca
			QD080DUOF()
		EndIf

		//Carrega registros de Usuários
		aUserLoad := LoadUser()
		aItsUser  := aUserLoad
		oUsers:SetArray(aUserLoad)
		oUsers:bLine := {||{  CheckQDO( , aUserLoad[oUsers:nAt,6], aUsers ),;
					aUserLoad[oUsers:nAt,1] + "-" + aUserLoad[oUsers:nAt,2],;
					aUserLoad[oUsers:nAt,3],;
					aUserLoad[oUsers:nAt,4],;
					aUserLoad[oUsers:nAt,5] } }
		oUsers:nAt := 1


		//Carrega registros de Departamento
		aDptoLoad := LoadDepto() 
		aItsDepto := aDptoLoad
		oDeptos:SetArray( aDptoLoad )
		oDeptos:bLine := {||{ CheckQDO( , aDptoLoad[oDeptos:nAt,4], aDeptos ),;
					aDptoLoad[oDeptos:nAt,1] + "-" + aDptoLoad[oDeptos:nAt,2] ,;
					aDptoLoad[oDeptos:nAt,3] } }
		oDeptos:nAt:= 1
		oDeptos:Refresh()


		// Carrega registros de Cargos
		aCargLoad := LoadCargo() 
		aItsCargo := aCargLoad
		oCargos:SetArray( aCargLoad )
		oCargos:bLine := {||{ CheckQDO( , aCargLoad[oCargos:nAt,4], aCargos ),;
					aCargLoad[oCargos:nAt,1] + "-" + aCargLoad[oCargos:nAt,2],;
					aCargLoad[oCargos:nAt,3] } }
		oCargos:nAt:= 1
		oCargos:Refresh()
	EndIf

Return

/*/{Protheus.doc} QD080AVOFI
Avalia se existem usuários de outras filiais marcados
@type  Function
@author brunno.costa
@since 14/03/2024
@param 01 - nOutros, número, retorna por referência a quantidade de outros usuários de outras filiais
@return - lOutFilial, lógico, indica se existem usuários de outras filiais marcados
/*/
Function QD080AVOFI(nOutros)

	Local aAreaQAA    := QAA->(GetArea())
	Local cFilQDA     := xFilial("QDA")
	Local lOutFilial  := .F.
	Local nIndUser    := Nil
	Local nTotal      := Len(aUsers)
	Local oQryManager := QLTQueryManager():New()

	For nIndUser := 1 to nTotal
		QAA->(DbGoTo(aUsers[nIndUser][TR_RECNO]))
		If !oQryManager:ComparacaoFiliais("QDA", cFilQDA, "QAA", QAA->QAA_FILIAL)
			lOutFilial := .T.
			nOutros++
		EndIf
	Next

	RestArea(aAreaQAA)

Return lOutFilial

/*/{Protheus.doc} QD080DUOF
Desmarca usuários selecionados de outras filiais
@type  Function
@author brunno.costa
@since 14/03/2024
/*/
Function QD080DUOF()

	Local aAreaQAA    := QAA->(GetArea())
	Local cFilQDA     := xFilial("QDA")
	Local nIndUser    := Nil
	Local nTotal      := Len(aUsers)
	Local oQryManager := QLTQueryManager():New()
	Local aAuxUsers   := {}

	For nIndUser := 1 to nTotal
		QAA->(DbGoTo(aUsers[nIndUser][TR_RECNO]))
		If oQryManager:ComparacaoFiliais("QDA", cFilQDA, "QAA", QAA->QAA_FILIAL)
			aAdd(aAuxUsers, aUsers[nIndUser])
		Else
			CheckQDO( .F., aUsers[nIndUser][TR_RECNO], aUsers )
			QDOSeleUserAll( .F., QAA->QAA_FILIAL, QAA->QAA_MAT )
		EndIf
	Next

	aUsers := aAuxUsers

	RestArea(aAreaQAA)

Return 

/*/{Protheus.doc} fRemSpace
(long_description)
@type  Function
@author user
@since 19/08/2021
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function fRemSpace(aContArray)
Local aArrayAux := aClone(aContArray)
Local nX := 0 
Local nY := 0

For nX := 1 To Len(aContArray)
	For nY := 1 To Len(aContArray[nX])
		aArrayAux[nX][nY] := IIF(VALTYPE(aContArray[nX][nY])=="C",ALLTRIM(aContArray[nX][nY]),aContArray[nX][nY])
	Next nY
Next nX
	
Return aArrayAux

/*/{Protheus.doc} fVldComp
Função que valida a integridade dos registros de acordo com o compartilhamento de tabelas
@type  Function
@author thiago.rover
@since 07/12/2021
/*/
Function fVldComp()

	Local oManager  := QLTQueryManager():New()

	//Validação QAD
	oManager:ValidaDadosDaFilial("QAD", "QAD", "QAD_FILIAL", .T.)

	//Validação QAC
	oManager:ValidaDadosDaFilial("QAC", "QAC", "QAC_FILIAL", .T.)

	//Valida Compartilhamentos QAD, QDT, QDC, QAC
	If FindFunction(Upper("ValidQAD"))
		ValidQAD(oManager)
	EndIf

	//Seta status inicial para exibir todas as filiais
	lFiltraFil := .F.
	
Return .T.



/*/{Protheus.doc} fPesqQDM
Função que consulta a tabela QDM e restorna .T. caso conseguiu localizar registros e .F. caso não conseguiu localizar registros, tendo como 
base a tabela QAA - Usuários e QDA - Treinamentos
@type  Static Function
@author thiagor.rover
@since 15/03/2022
@version version
@param param_name, param_type, param_descr
@return lRetorna  Retorna .T.(Quando localiza registros) e .F.(Quando não localiza registros)
/*/
Static Function fPesqQDM(cFilQAA, cDeptoQAA, cFunQAA)

Local cAliasQry := GetNextAlias()
Local cQuery    := ""
Local lRetorna  := .F.

	cQuery := " SELECT QDM_FILIAL FROM " + RetSqlName("QDM")+" QDM "
	cQuery += " WHERE QDM_FILIAL = '"+ xFilial( "QDA" )+"'"
	cQuery += " AND QDM_ANO = '"+M->QDA_ANO+"'"
	cQuery += " AND QDM_NUMERO = '"+M->QDA_NUMERO+"'"
	cQuery += " AND QDM_FILMAT = '"+cFilQAA+"'"
	cQuery += " AND QDM_DEPTO = '"+cDeptoQAA+"'"
	cQuery += " AND QDM_CARGO = '"+cFunQAA+"'"
	cQuery += " AND QDM.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery( cQuery )
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
	(cAliasQry)->(DBGotop())  
	IF (cAliasQry)->(!EOF())
		lRetorna := .T.
	Endif

	(cAliasQry)->(DbCloseArea())
	
Return lRetorna

