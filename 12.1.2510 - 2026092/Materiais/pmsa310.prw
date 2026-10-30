#include "pmsa310.ch"
#include "protheus.ch"
#include "msgraphi.ch"
#include "pmsicons.ch"

STATIC __oStmtQry := Nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PMSA310  ³ Autor ³ Edson Maricate        ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Controle da Execucao de Projetos.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSA310()

Local cFilUser		:= ""

PRIVATE cCadastro	:= STR0001 //"Confirmacoes"
Private aRotina := MenuDef()

Set Key VK_F12 To FAtiva()


If AMIIn(44) .And. !PMSBLKINT()
	Pergunte("PMA200",.F.)
	
	If ExistBlock("PMA310FIL")
		cFilUser := ExecBlock("PMA310FIL",.F.,.F.)
		If ValType(cFilUser) <> "C"
			cFilUser := ""
		EndIf							
	EndIf

	mBrowse(6,1,22,75,"AF8",,,,,,PmsAF8Color(),,,,,,,,cFilUser)
EndIf

Set Key VK_F12 To

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS310Dlg³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de Inclusao,Alteracao,Visualizacao e Exclusao        ³±±
±±³          ³do Controle de Execucao de Projetos.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS310Dlg(cAlias,nReg,nOpcx)

Local oDlg
Local oMenu
Local l310Inclui	:= .F.
Local l310Visual	:= .F.
Local l310Altera	:= .F.
Local l310Exclui	:= .F.
Local aConfig		:= {1, PMS_MIN_DATE, PMS_MAX_DATE, Space(TamSX3("AE8_RECURS")[1])}
Local lFWGetVersao	:= .T.  
Local lGrava:= ExistBlock ("AF8GRAVA")
Local lPMA310MNU 	:= ExistBlock("PMA310MNU")

// variaveis para posicionamento do popup menu
Local nScreVal1 := 775 
Local nScreVal2 := 23

PRIVATE cRevisa		:= AF8->AF8_REVISA
PRIVATE cCmpPLN
PRIVATE cArqPLN
PRIVATE cPLNVer		:= ''
PRIVATE cPLNDescri	:= ''
PRIVATE cPLNSenha	:= ''
PRIVATE lSenha		:= .F.
PRIVATE nIndent		:= PMS_SHEET_INDENT
Private aMenu		:= {}
Private oTree
Private cArquivo		:= CriaTrab(,.F.)

If cPaisLoc == 'RUS'
	//Set popup menu location using the screen resolution
	nScreVal1 := RU99XFUN15()[1] // GetRusPopupMenuPos
	nScreVal2 := RU99XFUN15()[2] // GetRusPopupMenuPos
EndIf

Pergunte("PMA200",.F.)

FATPDLogUser("PMS310DLG")
Do Case
	Case aRotina[nOpcx][4] == 2 .and. nOpcx == 3
		l310Visual := .T.
	Case aRotina[nOpcx][4] == 4
		l310Inclui	:= .T.
	Case aRotina[nOpcx][4] == 2  .and. nOpcx == 2
		l310Altera	:= .T.
	Case aRotina[nOpcx][4] == 5
		l310Exclui	:= .T.
		l310Visual	:= .T.
EndCase

MENU oMenu3 POPUP
	MENUITEM STR0016 ACTION PmsDlgAF8Gnt(cRevisa,aConfig,@oDlg,@oTree,cArquivo) //"Grafico de Gantt..."
	MENUITEM STR0017 ACTION PmsDlgAF8Rec(cRevisa,@oTree,cArquivo) //"Grafico de Alocacao dos Recursos..."
EndMenu
MENU oMenu POPUP
	MENUITEM STR0001 Action A310ViewBrw(@oTree,l310Visual,cArquivo),Eval(bRefresh) //"Confirmacoes"
	MENUITEM STR0023 Action A310ConfEDT(@oTree, cArquivo) ,Eval(bRefresh) //"Confirmacao multi-tarefa"
	If lPMA310MNU
		ExecBlock("PMA310MNU",.F.,.F., {@oMenu, @oTree, cArquivo, l310Visual })
	Endif
ENDMENU

If !lFWGetVersao .or. GetVersao(.F.) == "P10"

	If mv_par01 == PMS_VIEW_SHEET
		// modo planilha
		aMenu := {;
		         {TIP_PROJ_INFO,      {||PmsPrjInf()}, BMP_PROJ_INFO, TOOL_PROJ_INFO},;
		         {TIP_COLUNAS,        {||PMC200Cfg("",0,0), oDlg:End()}, BMP_COLUNAS, TOOL_COLUNAS},;
		         {TIP_PROJ_CONSULTAS, {||oMenu3:Activate(75,45,oDlg)}, BMP_PROJ_CONSULTAS, TOOL_PROJ_CONSULTAS },;
		         {TIP_PROJ_ESTRUTURA, {||A310CtrMenu(@oMenu,oTree,l310Visual,cArquivo),oMenu:Activate(105,45,oDlg)}, BMP_PROJ_ESTRUTURA, TOOL_PROJ_ESTRUTURA}} //"&Estrutura"	
	Else 
	
		// modo arvore
		aMenu := {;
		         {TIP_PROJ_INFO,      {||PmsPrjInf()}, BMP_PROJ_INFO, TOOL_PROJ_INFO},;
		         {TIP_PROJ_CONSULTAS, {||oMenu3:Activate(35,45,oDlg)}, BMP_PROJ_CONSULTAS, TOOL_PROJ_CONSULTAS },;
		         {TIP_PROJ_ESTRUTURA, {||A310CtrMenu(@oMenu,oTree,l310Visual,cArquivo),oMenu:Activate(75,45,oDlg)}, BMP_PROJ_ESTRUTURA, TOOL_PROJ_ESTRUTURA}} //"&Estrutura"
	EndIf

Else
	//Acoes relacionadas

	If mv_par01 == PMS_VIEW_SHEET
		// modo planilha
		aMenu := {;
		         {TIP_PROJ_INFO,      {||PmsPrjInf()}, BMP_PROJ_INFO, TOOL_PROJ_INFO},;
		         {TIP_COLUNAS,        {||PMC200Cfg("",0,0), oDlg:End()}, BMP_COLUNAS, TOOL_COLUNAS},;
		         {TIP_PROJ_CONSULTAS, {||oMenu3:Activate(nScreVal1,nScreVal2,oDlg)}, BMP_PROJ_CONSULTAS, TOOL_PROJ_CONSULTAS },;
		         {TIP_PROJ_ESTRUTURA, {||A310CtrMenu(@oMenu,oTree,l310Visual,cArquivo),oMenu:Activate(nScreVal1,nScreVal2,oDlg)}, BMP_PROJ_ESTRUTURA, TOOL_PROJ_ESTRUTURA}} //"&Estrutura"	
	Else 
	
		// modo arvore
		aMenu := {;
		         {TIP_PROJ_INFO,      {||PmsPrjInf()}, BMP_PROJ_INFO, TOOL_PROJ_INFO},;
		         {TIP_PROJ_CONSULTAS, {||oMenu3:Activate(nScreVal1,nScreVal2,oDlg)}, BMP_PROJ_CONSULTAS, TOOL_PROJ_CONSULTAS },;
		         {TIP_PROJ_ESTRUTURA, {||A310CtrMenu(@oMenu,oTree,l310Visual,cArquivo),oMenu:Activate(nScreVal1,nScreVal2,oDlg)}, BMP_PROJ_ESTRUTURA, TOOL_PROJ_ESTRUTURA}} //"&Estrutura"
	EndIf
	
Endif
	
If ExistTemplate("PMA310MENU")   // ponto de entrada concebido originalmente para 
	ExecTemplate("PMA310MENU",.F.,.F.,{l310Visual}) // manipular array aMenu - Alt.Estrutura PMSA410
EndIf

If mv_par01 == PMS_VIEW_SHEET
	aCampos := {{"AF9_TAREFA","AFC_EDT",8,,,.F.,"",},{"AF9_DESCRI","AFC_DESCRI",55,,,.F.,"",150}}
	A200Opn(@aCampos,"\PROFILE\PMSA310","MV_PMSPLN3","MV_PMSPLN4")
	PmsPlanAF8(cCadastro,cRevisa,aCampos,@cArquivo,,,,aMenu,@oDlg,,,aConfig,,nIndent)
Else 
	PmsDlgAF8(cCadastro,@oMenu,cRevisa,@oTree,"AF8,AFC,AF9,AFD,ACB",,,,aMenu,@oDlg,aConfig,@cArquivo)
EndIf 

       If lGrava  // Ponto de Entrada que realiza a gravação dos dados da tabela AF8
	        ExecBlock( "AF8GRAVA",.F.,.F.,)
       EndIf

Return 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A310ViewBrw³ Autor ³ Edson Maricate       ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de Visualizacao do arquivo de Execucao das Tarefas   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A310ViewBrw(oTree,lVisual,cArquivo)
Local aSize		:= MsAdvSize(,.F.,430)
Local aRotina 	
Local lHabVis 	:= .T.
Local lHabInc	:= .T.
Local lHabAlt	:= .T.
Local lHabExc	:= .T.
Local cAlias	
Local nRecView	
                
If oTree!= Nil
	cAlias		:= SubStr(oTree:GetCargo(),1,3)
	nRecView	:= Val(SubStr(oTree:GetCargo(),4,12))
Else 
	cAlias		:= (cArquivo)->ALIAS
	nRecView	:= (cArquivo)->RECNO
Endif

A310ValOp(cAlias,nRecView,@lHabVis,@lHabInc,@lHabAlt,@lHabExc)

If cAlias == "AF9" .And. nRecView<>0
	
	aRotina 	:= If(lVisual,{{ STR0003,"A310to311", 0 , 2,  ,lHabVis}},; //"Visualizar"
							   {{ STR0003,"A310to311", 0 , 2,  ,lHabVis},; //"Visualizar"
								{ STR0009,"A310to311", 0 , 3,  ,lHabInc},;	 //"Incluir"
								{ STR0010,"A310to311", 0 , 4,  ,lHabAlt},;	 //"Alterar"
								{ STR0011,"A310to311", 0 , 5, 1,lHabExc} } ) //"Excluir"

	AF9->(dbGoto(nRecView))
	MaWndBrowse(aSize[7],0,aSize[6],aSize[5],cCadastro,"AFF",,aRotina,,;
	'xFilial("AFF")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA',;
	'xFilial("AFF")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA',;
	.F.,,,{{STR0014,1}},xFilial("AFF")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA) //"Data de Referencia"
EndIf

If cAlias == "AFC" .And. nRecView<>0 
	aRotina 	:= If(.T.,	{{ STR0003,"AxVisual", 0 , 2,  ,lHabVis}},;   //"Visualizar"
							{{ STR0003,"AxVisual", 0 , 2,  ,lHabVis},;    //"Visualizar"
							 { STR0009,"A310ConfEDT", 0 , 3,  ,lHabInc},; //"Incluir"
							} ) 

	AFC->(dbGoto(nRecView))
	MaWndBrowse(aSize[7],0,aSize[6],aSize[5],cCadastro,"AFQ",,aRotina,,;
	'xFilial("AFQ")+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT',;
	'xFilial("AFQ")+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT',;
	.F.,,,{{STR0014,1}},xFilial("AFQ")+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT) //"Data de Referencia"
EndIf

FATPDLogUser("A310ViewBr")
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A310To311³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Chamada da tela de inclusao/alteracao/visualizacao do AFF.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A310To311(cAlias,nReg,nOpcx)
Local aGetCpos := {}
Local aDadosAFF := {}
Local nTotalReg := 0
Local nTotalQuant := 0

Do Case
	Case nOpcx == 1
		PMSA311(2)

	Case nOpcx == 2
		If PmsVldFase("AF8", AF8->AF8_PROJET, "91")
			aDadosAFF := CountAFF(AF9->AF9_PROJET, AF9->AF9_REVISA, AF9->AF9_TAREFA)
			nTotalReg := aDadosAFF[1]
			nTotalQuant := aDadosAFF[2]

			If ((nTotalReg == 1 .And. nTotalQuant == 1) .Or. (nTotalReg > 1 .And. nTotalQuant == 1))
				Help("", 1, "TRF100CONC", , STR0042, 1, 0)
			Else
				aGetCpos := { 	{"AFF_PROJET", AF9->AF9_PROJET, .F.}, ;
								{"AFF_REVISA", AF9->AF9_REVISA, .F.}, ;
								{"AFF_DESCRI", AF8->AF8_DESCRI, .F.}, ;
								{"AFF_TAREFA", AF9->AF9_TAREFA, .F.} ;
							}
				PMSA311(3, aGetCpos)
			EndIf
		EndIf
	Case nOpcx == 3
		If PmsVldFase("AF8",AF8->AF8_PROJET,"93")
		PMSA311(4)
		Endif
	Case nOpcx == 4
		If PmsVldFase("AF8",AF8->AF8_PROJET,"95")
			PMSA311(5)
		Endif
EndCase

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A310View³ Autor ³ Edson Maricate          ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que monta o a Tarefa no Tree do Projeto.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA310                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A310View(oTree,aSVAlias,aEnch,aPos)
Local cAlias	:= SubStr(oTree:GetCargo(),1,3)
Local nRecView	:= Val(SubStr(oTree:GetCargo(),4,12))
Local nPosAlias	:= aScan(aSVAlias,cAlias)
Local nx := 0
//Local lOneColumn:= If(aPos[4]-aPos[2]>312,.F.,.T.)

If nRecView <> 0
	dbSelectArea(cAlias)
	dbGoto(nRecView)
	RegToMemory(cAlias,.F.)
	For nx := 1 to Len(aEnch)
		If aEnch[nx] <> Nil
			aEnch[nx]:Hide()
		EndIf
	Next

	If nPosAlias > 0
		Do Case
			Case cAlias == "AF9"
				aEnch[1]:EnchRefreshAll()
				aEnch[1]:Show()
			Case cAlias == "AFA"
				aEnch[2]:EnchRefreshAll()
				aEnch[2]:Show()
			Case cAlias == "AFB"
				aEnch[3]:EnchRefreshAll()
				aEnch[3]:Show()
			Case cAlias == "AFD"
				aEnch[4]:EnchRefreshAll()
				aEnch[4]:Show()
			Case cAlias == "AFC"
				aEnch[5]:EnchRefreshAll()
				aEnch[5]:Show()
			Case cAlias == "AF8"
				aEnch[6]:EnchRefreshAll()
				aEnch[6]:Show()
		EndCase
	EndIf
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS310PERC³ Autor ³ Edson Maricate        ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de preenchimento da Quantidade referente ao percentual ³±±
±±³          ³digitado.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA310                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS310PERC(lMemory)
Local nQuant	:= 0
Local aArea		:= GetArea()
Local aAreaAF9	:= AF9->(GetArea())

DEFAULT lMemory := .T.

dbSelectArea("AF9")
dbSetOrder(1)
If lMemory
	If !Empty(M->AFF_TAREFA)
		If dbSeek(xFilial("AF9")+M->AFF_PROJET+M->AFF_REVISA+M->AFF_TAREFA)
			If NoRound(M->AFF_QUANT/AF9->AF9_QUANT*100,2) <> M->AFF_PERC
				nQuant := NoRound(M->AFF_PERC*AF9->AF9_QUANT/100, TamSX3("AFF_QUANT")[2])
			else
				nQuant := M->AFF_QUANT
			Endif
		EndIf
	Else
		nQuant := NoRound(M->AFF_PERC/100, TamSX3("AFF_QUANT")[2])
	EndIf
Else
	If !Empty(AFF->AFF_TAREFA)
		If dbSeek(xFilial("AF9")+AFF->AFF_PROJET+AFF->AFF_REVISA+AFF->AFF_TAREFA)
			nQuant := NoRound(AFF->AFF_PERC*AF9->AF9_QUANT/100, TamSX3("AFF_QUANT")[2])
		EndIf
	Else
		nQuant := NoRound(AFF->AFF_PERC/100, TamSX3("AFF_QUANT")[2])
	EndIf
Endif

RestArea(aAreaAF9)
RestArea(aArea)
Return nQuant

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS310QT³ Autor ³ Edson Maricate          ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de preenchimento do percentual referente a quantidade  ³±±
±±³          ³digitada.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA310                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS310QT(lMemory,cAlias)
Local nPerc		:= 0
Local aArea		:= GetArea()
Local aAreaAF9	:= AF9->(GetArea())
Local aAreaAFC	:= AFC->(GetArea())

DEFAULT cAlias	:= "AFF"
DEFAULT lMemory := .T.

	If cAlias=="AFF"
		If lMemory
			dbSelectArea("AF9")
			dbSetOrder(1)
			If !Empty(M->AFF_TAREFA)
				If MsSeek(xFilial("AF9")+M->AFF_PROJET+M->AFF_REVISA+M->AFF_TAREFA)
					nPerc := NoRound(M->AFF_QUANT/AF9->AF9_QUANT*100,2)
				EndIf
			Else
				nPerc := NoRound(M->AFF_QUANT*100,2)
			EndIf
		Else
			dbSelectArea("AF9")
			dbSetOrder(1)
			If !Empty(AFF->AFF_TAREFA)
				If MsSeek(xFilial("AF9")+AFF->AFF_PROJET+AFF->AFF_REVISA+AFF->AFF_TAREFA)
					nPerc := NoRound(AFF->AFF_QUANT/AF9->AF9_QUANT*100,2)
				EndIf
			Else
				nPerc := NoRound(AFF->AFF_QUANT*100,2)
			EndIf
		EndIf
	Else
		If lMemory
			dbSelectArea("AFC")
			dbSetOrder(1)
			If MsSeek(xFilial("AFC")+M->AFQ_PROJET+M->AFQ_REVISA+M->AFQ_EDT)
				nPerc := NoRound(M->AFQ_QUANT/AFC->AFC_QUANT*100,2)
			EndIf
		Else
			dbSelectArea("AFC")
			dbSetOrder(1)
			If MsSeek(xFilial("AFC")+AFQ->AFQ_PROJET+AFQ->AFQ_REVISA+AFQ->AFQ_EDT)
				nPerc := NoRound(AFQ->AFQ_QUANT/AFC->AFC_QUANT*100,2)
			EndIf
		EndIf
	EndIf
		
RestArea(aAreaAFC)
RestArea(aAreaAF9)
RestArea(aArea)
Return nPerc


Function Montagra(oGraphic)
Local dx := 0
Local dFim	:= If(AF8->AF8_FINISH>AF8->AF8_DTATUF,AF8->AF8_FINISH,If(!Empty(AF8->AF8_DTATUF),AF8->AF8_DTATUF,AF8->AF8_FINISH))
Local dIni	:= If(AF8->AF8_START<AF8->AF8_DTATUI,AF8->AF8_START,If(!Empty(AF8->AF8_DTATUI),AF8->AF8_DTATUI,AF8->AF8_START))
Local nTotal :=  dFim - dIni
Local nStep	 := INT(nTotal/30)


nSerie := oGraphic:CreateSerie( 1 )
nSerie2 := oGraphic:CreateSerie( 1 )

nStep := If(nStep<1,1,nStep)

For dx := dIni to dFim STEP nStep
	oGraphic:Add(nSerie,PMSPrvAF8(AF8->AF8_PROJET,AF8->AF8_REVISA,dx),DTOC(dx),CLR_HBLUE)
	dbSelectArea("AFQ")
	dbSetOrder(1)
	If MsSeek(xFilial()+AF8->AF8_PROJET+AF8->AF8_REVISA+AF8->AF8_PROJET+"  "+DTOS(dx),.T.)
			nQuantEx  := AFQ->AFQ_QUANT
	Else
		dbSkip(-1)
		If 	!Bof().And. AF8->AF8_PROJET==AFQ->AFQ_PROJET.And.;
			AF8->AF8_REVISA==AFQ->AFQ_REVISA.And.;
			AFQ->AFQ_EDT==AF8->AF8_PROJET+"  "
			nQuantEx  := AFQ->AFQ_QUANT
		Else
			nQuantEx  := 0
		EndIf
	EndIf
	If dx <= AF8->AF8_DTATUF
		oGraphic:Add(nSerie2,nQuantEx*100,DTOC(dx),CLR_HGREEN)
	EndIf
Next

oGraphic:Refresh()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A310CtrMenu³ Autor ³Edson Maricate        ³ Data ³ 30-08-2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que controla as opcoes de menu do usuario.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA310                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A310CtrMenu(oMenu,oTree,lVisual,cArquivo)
Local aArea		:= GetArea()
Local cAlias	
Local nRecView	
Local nItens := Len(oMenu:aItems)
Local cProject := ""

Default lVisual := .F.

If oTree == Nil
	cAlias	:= (cArquivo)->ALIAS
	nRecView	:= (cArquivo)->RECNO
Else
	cAlias	:= SubStr(oTree:GetCargo(),1,3)
	nRecView	:= Val(SubStr(oTree:GetCargo(),4,12))
EndIf

dbSelectArea(cAlias)
dbGoto(nRecView)

Do Case

	Case cAlias == "AF9"
		cProject := (cAlias)->AF9_PROJET

	Case cAlias == "AFC"
		cProject := (cAlias)->AFC_PROJET

	Case cAlias == "AF8"
		cProject := (cAlias)->AF8_PROJET

End Case

If lVisual == .F. //Permite acessar as confirmações em visualização.
	If !PMSVldFase("AF8", cProject, "91", .F.)
		oMenu:aItems[1]:Disable()
	
		If nItens >1
			oMenu:aItems[2]:Disable()	
		EndIf
		
		Return
	EndIf
EndIf
	
Do Case 

	Case cAlias=="AF9"

		// verifica a permissao para as Confirmacoes
		If PmsChkUser(AF9->AF9_PROJET,AF9->AF9_TAREFA,,AF9->AF9_EDTPAI,2,"CONFIR",AF9->AF9_REVISA)//Confirmacoes
			oMenu:aItems[1]:Enable()
		Else
			oMenu:aItems[1]:Disable()
		EndIf
		
		If nItens >1
			oMenu:aItems[2]:Disable()	
		EndIf

	Case cAlias == "AFC"
	
		If nItens >1
			If PmsChkUser(AFC->AFC_PROJET,,AFC->AFC_EDT,AFC->AFC_EDTPAI,2,"CONFIR",AFC->AFC_REVISA)
				oMenu:aItems[2]:Enable()
			Else
				oMenu:aItems[2]:Disable()
			EndIf
		EndIf
		
		oMenu:aItems[1]:Disable()

	OtherWise
		oMenu:aItems[1]:Disable()
		If nItens >1
			oMenu:aItems[2]:Disable()
		EndIf
EndCase


RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A310ValOp  ³ Autor ³Fabio Rogerio Pereira ³ Data ³ 07-01-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que controla as opcoes de menu do usuario.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA310                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A310ValOp(cAlias,nRecView,lHabVis,lHabInc,lHabAlt,lHabExc)
dbSelectArea(cAlias)
dbGoto(nRecView)

If cAlias == "AF9"
	If PmsChkUser(AF9->AF9_PROJET,AF9->AF9_TAREFA,,AF9->AF9_EDTPAI,4,"CONFIR",AF9->AF9_REVISA)//Controle Total
		lHabVis:= .T.
		lHabInc:= .T.
		lHabAlt:= .T.
		lHabExc:= .T.
	ElseIf PmsChkUser(AF9->AF9_PROJET,AF9->AF9_TAREFA,,AF9->AF9_EDTPAI,3,"CONFIR",AF9->AF9_REVISA)//Alterar
		lHabVis:= .T.
		lHabAlt:= .T.
		lHabInc:= .F.
		lHabExc:= .F.
	ElseIf PmsChkUser(AF9->AF9_PROJET,AF9->AF9_TAREFA,,AF9->AF9_EDTPAI,2,"CONFIR",AF9->AF9_REVISA)//Visualizar
		lHabVis:= .T.
		lHabAlt:= .F.
		lHabInc:= .F.
		lHabExc:= .F.
	Else
		lHabVis:= .F.
		lHabAlt:= .F.
		lHabInc:= .F.
		lHabExc:= .F.
	EndIf
ElseIf cAlias == "AFC"
	If PmsChkUser(AFC->AFC_PROJET,,AFC->AFC_EDT,AFC->AFC_EDTPAI,4,"CONFIR",AFC->AFC_REVISA)//Controle Total
		lHabVis:= .T.
		lHabInc:= .T.
		lHabAlt:= .T.
		lHabExc:= .T.
	ElseIf PmsChkUser(AFC->AFC_PROJET,,AFC->AFC_EDT,AFC->AFC_EDTPAI,2,"CONFIR",AFC->AFC_REVISA)//Controle Total
		lHabVis:= .T.
		lHabAlt:= .F.
		lHabInc:= .F.
		lHabExc:= .F.
	Else
		lHabVis:= .F.
		lHabAlt:= .F.
		lHabInc:= .F.
		lHabExc:= .F.
	EndIf
EndIf

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FAtiva   ³ Autor ³ Edson Maricate        ³ Data ³ 18.10.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chama a&pergunte                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA310                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FAtiva()
	Pergunte("PMA200",.T.)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A310ConfEDT Autor ³ Adriano Ueda          ³ Data ³ 19/08/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Permite a inclusão de uma confirmação para várias tarefas. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
8±±³ Uso      ³ PMSA310                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A310ConfEDT(oTree, cArquivo)
	Local oDlg       := Nil
	Local oBold      := Nil

	Local lOk 		 := .F.
	Local cAlias	 := ""
	Local nRecAlias	 := 0
	Local nRecAF9    := 0
	
	Local oDataRef   := Nil
	Local dDateRef   := MsDate() //Space(TamSx3("AFF_DATA")[1])
	
	Local oPerExec   := Nil
	Local nPerExec   := 0

	Local oOcorren   := Nil
	Local cOcorren   := Space(TamSX3("AFF_OCORRE")[1])
		
	Local oUser      := Nil
	Local cUser      := RetCodUsr()

	Local oProject   := Nil
	Local cProject   := Space(TamSX3("AF8_PROJET")[1])
	
	Local oDescProj  := Nil
	Local cDescProj  := ""
	
	Local oVersao    := Nil
	Local cVersao    := ""

	Local oUserName  := Nil
	Local cUsrName   := UsrRetName(cUser)
	                     
	Local oAE        := Nil
	Local cAE        := InitPad( GetSx3Cache("AFF_CONFIRM","X3_RELACAO") , "AFF_CONFIRM" )
	
	Local oObs       := Nil
	Local cObs       := ""

	Local oRecPost
	Local lRecPost := .F.
	
	Local oDelPost
	Local lDelPost := .F.
	
	Local lHabVis := .F.
	Local lHabInc := .F.
	Local lHabAlt := .F.
	Local lHabExc := .F.
	
	Local lContinua := .T.
	
	Local aITCBox := RetSX3Box( Posicione("SX3", 2, "AFF_CONFIRM", "X3CBox()" ),,,1)
	Local aAEItens := {}
	
	aEval( aITCBox,{|x|iif(!Empty(X[1]) ,aAdd( aAEItens ,X[1]),.T.) } )
	
	// Se a fase permite incluir e alterar a confirmacao da tarefa
	If PmsVldFase("AF8",AF8->AF8_PROJET,"92") .and. PmsVldFase("AF8",AF8->AF8_PROJET,"94")
		
		If oTree!= Nil
			cAlias		:= SubStr(oTree:GetCargo(),1,3)
			nRecView	:= Val(SubStr(oTree:GetCargo(),4,12))
		Else 
			cAlias		:= (cArquivo)->ALIAS
			nRecView	:= (cArquivo)->RECNO
		Endif
		
		cProject  := AFC->AFC_PROJET
		cDescProj := ReadValue("AF8", 1, xFilial("AF8") + (cAlias)->AFC_PROJET, "AF8_DESCRI")
		cVersao   := AFC->AFC_REVISA
	
		// se for inclusao de confirmacao de tarefa
		If ExistBlock("PMA311IN")
			lContinua := ExecBlock("PMA311IN",.F.,.F.)
		EndIf
		
		If lContinua .AND. (cAlias == "AFC" .And. nRecView<>0)
	        //
	        // valida a permissao do usuario na EDT
			A310ValOp(cAlias,nRecView,@lHabVis,@lHabInc,@lHabAlt,@lHabExc)
			
			Define Font oBold NAME "Arial" SIZE 0, -12 BOLD
			Define MsDialog oDlg From 1, 1 To 366, 521 Title STR0023 Of oMainWnd PIXEL //"Confirmação Multi-tarefa"
		
				// linha 1 - Codigo do Projeto e versao do projeto
				@  10,  10 Say STR0024       Of oDlg Pixel Size 45, 08 //"Projeto:"
				@  08,  50 MsGet oProject Var cProject Picture PesqPict("AF8", "AF8_PROJET") Of oDlg When .F. Pixel Size 40, 08
		
				@  10, 180 Say STR0025        Of oDlg Pixel Size 45, 08 //"Versao:"
				@  08, 220 MsGet oVersao Var cVersao Picture PesqPict("AF8", "AF8_REVISA") Of oDlg When .F. Pixel Size 40, 08
		
				// linha 2 - descricao do projeto
				@  25,  10 Say STR0026   Of oDlg Pixel Size 45, 08
				@  23,  50 MsGet oDescProj Var cDescProj Picture PesqPict("AF8", "AF8_DESCRI") Of oDlg When .F. Pixel Size 210, 08
		
				// linha 3 - data de referencia para confirmacao e percentual executado
				@  40,  10 Say STR0027     Of oDlg Pixel Size 45, 08 //"Data Ref.:"
				@  38,  50 MsGet oDataRef Var dDateRef Picture PesqPict("AFF", "AFF_DATA") Of oDlg HasButton Pixel Size 50, 08
		
				@  40, 180 Say STR0028  Of oDlg Pixel Size 45, 08 //"% Perc Exec.:"
				@  38, 220 MsGet oPerExec Var nPerExec Picture "@E 9999.99" Valid Positivo(nPerExec) .And. PerEx(nPerExec);
				           Of oDlg HasButton Pixel Size 25, 08
		
				// linha 4 - codigo de ocorrencia
				@  55,  10 Say STR0029     Of oDlg Pixel Size 45, 08 //"Ocorrencia:"
				@  53,  50 MsGet oOcorren Var cOcorren Picture PesqPict("AFF", "AFF_OCORRE") F3 "AE7" Of oDlg HasButton Pixel Size 50, 08				
		
				// linha 5 - codigo e descricao de usuario
				@  70,  10 Say STR0030 Of oDlg Pixel Size 45, 08 //"Código Usuário:"
				@  68,  50 MsGet oUser    Var cUser Picture PesqPict("AFF", "AFF_USER") Of oDlg When .F. Pixel Size 25, 08
		
				@  70,  90 Say STR0031   Of oDlg Pixel Size 45, 08 //"Nome Usuário:"
				@  68, 140 MsGet oUserName Var cUsrName Picture PesqPict("AE7", "AE7_DESCRI") Of oDlg When .F. Pixel Size 120, 08
		
				// linha 6 - gera autorizacao de entrega.
		 		@  85,  10 Say STR0032       Of oDlg Pixel Size 45, 08 //"Gera AE?"
		 		@  83,  50 Combobox oAE Var cAe Items aAEItens Size 45, 08 Of oDlg Valid cAe $ "12" Pixel
		
				// linha 7	- Observacao
				@ 100,  10 Say STR0033     Of oDlg Pixel Size 45, 08 //"Observação:"
				@  98,  50 Get oObs Var cObs Memo Size 210, 30 Pixel Of oDlg
				
				// linha 8 - confirmacao para recalculo de confirmacao posteriores.
		 		@ 140,  10 CHECKBOX oRecPost VAR lRecPost Prompt STR0038 + STR0039 ;// "Deseja recalcular os percentuais das confirmacoes posteriores, " ## "caso existam?" 
		 		               Size 300, 20 Pixel Of oDlg 
		 		
				// linha 8 - confirmacao para recalculo de confirmacao posteriores.
		 		@ 155,  10 CHECKBOX oDelPost VAR lDelPost Prompt STR0040 + STR0041 ; //"Deseja excluir as confirmacoes cujos percentuais forem menores " ## "que 0% ou maiores que 100%?" 
		 		               Size 300, 20 Pixel Of oDlg 
		 		
				// linha 9		
				@ 170, 180 Button STR0034 Size 35 ,11 Font oDlg:oFont ;
				           Action If(PmsVldConf(dDateRef, nPerExec),;
				                    (lOk := .T., oDlg:End()),;
		                            Help("   ",1,"OBRIGAT",,STR0035)) ;
				           WHEN lHabInc .AND. lHabAlt;
				           Of oDlg Pixel  //"OK"##"Algum campo obrigatorio nao foi preenchido."
		
				@ 170, 220 Button STR0036  Size 35 ,11 Font oDlg:oFont Action (oDlg:End()) Of oDlg Pixel
			FATPDLogUser("A310CONFED")
			Activate MsDialog oDlg Centered
		
			If lOk
				Begin Transaction
					Processa({||A310Grava( dDateRef ,nPerExec ,cOcorren ,cAE ,lRecPost ,lDelPost, cObs )},"" ) //"Gravando...")
				End Transaction	
				FWAlertSuccess( STR0037 ) //"Foi(ram) gerada(s) confirmação(ões) para a tarefa(s) filha(s) da EDT "
			EndIf
		EndIf
	EndIf	
Return .T. 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A310Grava ³ Autor ³ Reynaldo Miyashita    ³ Data ³ 26.09.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava as confirmacoes das tarefas da edt.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
8±±³ Uso      ³ PMSA310                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A310Grava( dDateRef ,nPerExec ,cOcorren ,cAE ,lRecPost ,lDelPost, cObs )
Local nRecAFF 
Local lContinua := .T.
Default cObs     	:= ""

	dbSelectArea("AF9")
	AF9->(dbSetOrder(2))  //AF9_FILIAL+AF9_PROJET+AF9_REVISA+AF9_EDTPAI+AF9_ORDEM
	AF9->(MsSeek(xFilial("AF9") + AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT))
	
	While !AF9->(Eof()) .And. AF9->AF9_FILIAL + AF9->AF9_PROJET + AF9->AF9_REVISA + AF9->AF9_EDTPAI ==;
	                          xFilial("AF9")  + AFC->AFC_PROJET + AFC->AFC_REVISA + AFC->AFC_EDT

		PmsIncProc(.T.)
					    
	    //
	    // se já existe o apontamento sobrepoe, senao inclui
	    //                      
		If AFF->(dbSeek(xFilial("AFF")  + AF9->AF9_PROJET + AF9->AF9_REVISA + AF9->AF9_TAREFA + dtos(dDateRef) ))
			If !SoftLock("AFF") .Or. !MaCanAltAFF("AFF",.T.)
				lContinua := .F.
			Else
				nRecAFF := AFF->(RecNo())
			Endif
				
			lInclui := .F.
			lAltera := .T.
		Else
			lInclui := .T.
			lAltera := .F.
		EndIf
		
		If lContinua
			RegToMemory("AFF" ,lInclui)
					
			//M->AFF_FILIAL := xFilial("AF9")
			M->AFF_PROJET := AF9->AF9_PROJET
			M->AFF_REVISA := AF9->AF9_REVISA
			M->AFF_DATA   := dDateRef
			M->AFF_TAREFA := AF9->AF9_TAREFA
			M->AFF_QUANT  := AF9->AF9_QUANT * (nPerExec / 100)
			M->AFF_PERC   := nPerExec
			M->AFF_OCORRE := cOcorren
			//M->AFF_USER   := cUser
			M->AFF_CONFIR := cAE
			if !Empty(cObs)
			   M->AFF_OBS := cObs
			endif
			
			//
			// valida os dados para gravacao.
			//	
			If A311AFFTudok(lInclui,.F.,lAltera)
			
				PMS311Grava(.F.,nRecAFF)
				
				// se deve recalcular os apontamentos posteriores e se existe apontamentos posteriores
				If lRecPost .and. PMSExistAFF(AFF->AFF_PROJET, AFF->AFF_REVISA, AFF->AFF_TAREFA, DToS(AFF->AFF_DATA + 1) )
					
					PMS311Rec(M->AFF_PROJET, M->AFF_REVISA, M->AFF_TAREFA, DToS(M->AFF_DATA), M->AFF_QUANT, lDelPost)
						
				EndIf
			EndIf
			AF9->(dbSkip())
		EndIf			
	EndDo
	
Return( .T. )			

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PerExn   ³ Autor ³ Adriano Ueda          ³ Data ³ 19/08/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validação da porcentagem da confirmação da tarefa.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA310                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PerEx(nQuant)
Return (nQuant <= 100 .and. nQuant >= 0)

Static Function PmsVldConf(dDate, nPerExec)
Return !Empty(dDate) .And. PerEx(nPerExec)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms310VHrf³ Autor ³ Edson Maricate        ³ Data ³ 30/08/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validação da hora final informada na confirmação           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA310                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pms310VHrf(cHora)
Local lRet := .T.

If cHora < M->AFF_HORAI
	lRet := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms310VHrf³ Autor ³ Edson Maricate        ³ Data ³ 30/08/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validação da hora final informada na confirmação           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA310                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pms310VHrI(cHora)
Local lRet := .T.

If !Empty(M->AFF_HORAF) .And. M->AFF_HORAF >= cHora
	M->AFF_HORAF := cHora
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³30/11/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados     ³±±
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
Local aRotina 	:= {	{ STR0002, "AxPesqui"  , 0 , 1,,.F.},; //"Pesquisar"
							{ STR0004,"PMS310Dlg", 0 , 2},; //"Atualizar"
							{ STR0003,"PMS310Dlg", 0 , 2}}	 //"Visualizar"
Return(aRotina)

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLogUser
    @description
    Realiza o log dos dados acessados, de acordo com as informações enviadas, 
    quando a regra de auditoria de rotinas com campos sensíveis ou pessoais estiver habilitada
	Remover essa função quando não houver releases menor que 12.1.27

   @type  Function
    @sample FATPDLogUser(cFunction, nOpc)
    @author Squad CRM & Faturamento
    @since 06/01/2020
    @version P12
    @param cFunction, Caracter, Rotina que será utilizada no log das tabelas
    @param nOpc, Numerico, Opção atribuída a função em execução - Default=0

    @return lRet, Logico, Retorna se o log dos dados foi executado. 
    Caso o log esteja desligado ou a melhoria não esteja aplicada, também retorna falso.

/*/
//-----------------------------------------------------------------------------
Static Function FATPDLogUser(cFunction, nOpc)

	Local lRet := .F.

	If FATPDActive()
		lRet := FTPDLogUser(cFunction, nOpc)
	EndIf 

Return lRet  

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Função que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive  

/*/{Protheus.doc} CountAFF
	Retorna a quantidade de confirmações da tarefa e o seu respectivo percentual de conclusão (Registros da tabela AFF)

	@Param cProjeto, character, Código do projeto
	@Param cRevisao, character, Número da revisão
	@Param cTarefa, character, Código da Tarefa

	@Return nCount - Retorna a quanditade de confirmações realizada na Tarefa
	@Return nSoma - Retorna o percentual realizado da Tarefa
    @author Squad CRM & Faturamento
    @since 10/11/2025
/*/
Function CountAFF(cProjeto, cRevisao, cTarefa)
	Local nCount   	:= 0
	Local nSoma    	:= 0
	Local cSQL     	:= ""
	Local cAliasAFF	:= ""

	Default cProjeto  := ""
	Default cRevisao  := ""
	Default cTarefa	  := ""

	If __oStmtQry == Nil
		cSQL := "SELECT COUNT(*) AS QTD, SUM(AFF_QUANT) AS SOMA " + ;
				"FROM " + RetSQLName("AFF") + " " + ;
				"WHERE D_E_L_E_T_ = '' " + ;
				"AND AFF_FILIAL = ? " + ;
				"AND AFF_PROJET = ? " + ;
				"AND AFF_REVISA = ? " + ;
				"AND AFF_TAREFA = ?"
	
		__oStmtQry := FwExecStatement():New(cSQL)
	EndIf
	
	__oStmtQry:SetString(1, xFilial("AFF"))
	__oStmtQry:SetString(2, cProjeto)
	__oStmtQry:SetString(3, cRevisao)
	__oStmtQry:SetString(4, cTarefa)
	
	cAliasAFF := __oStmtQry:OpenAlias()

	If !Empty(cAliasAFF) .And. (cAliasAFF)->(!Eof())
		nCount := Val(cValToChar((cAliasAFF)->QTD))
		nSoma  := Val(cValToChar((cAliasAFF)->SOMA))
	EndIf

Return {nCount, nSoma}
