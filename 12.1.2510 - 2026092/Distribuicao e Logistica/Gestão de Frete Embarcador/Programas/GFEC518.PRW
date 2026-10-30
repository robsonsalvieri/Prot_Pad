#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
//-------------------------------------------------------------------
//Inclusão Pátios 12.1.4
/*/{Protheus.doc} GFEC518
Atividades por usuário
	
@author siegklenes.beulke
@since 08/04/2014
@version 1.0

/*/

Function GFEC518()
	Local aCoors := FWGetDialogSize(oMainWnd)
	Local cTitulo := 'Atividades por Usuário'
	
	Private oBrowseUsu
	Private oBrowseMov
	Private oGrafTempPt //Tempo médio x Média - Barras
	Private oGrafTempGe //Tempo médio x Média Geral - Barras
	Private oGrafAtOp 	//Tempo médio por tipo de operação do usuário - Pizza
	Private oGrafQtOp 	//Quantidade de operações - Pizza
	Private oBrwEstGer	//Estatísticas Gerais
	Private oBrwEstPto	//Estatísticas Ponto
	Private oDLGC518
	Private cAliasUSU
	Private cAliasMOV
	Private nMediaGeUsu := 0
	Private aUsu 		:= {} // Lista dos usuários
	Private aPto 		:= {} // Lista dos Pontos e seus dados/ médias
	Private aUsuOper 	:= {} // Lista dos usuários x Operações
	Private aUsuPto 	:= {} // Lista dos usuários x Pontos
	Private aGrafTempPt	:= {}//Tempo médio x Média - Barras
	Private aGrafTempGe	:= {}//Tempo médio x Média Geral - Barras
	Private aGrafAtOp		:= {}//Tempo médio por tipo de operação do usuário - Pizza
	Private aGrafQtOp		:= {}//Quantidade de operações - Pizza
	Private aBrwEstGer	:= {}//Informações de Estatísticas
	Private aBrwEstPto	:= {}//Informações de Estatísticas
	Private oFolder
	Private oFolder2
	Private oPnlTempPt
	Private oPnlTempGe
	Private oPnlAtOp
	Private oPnlQtOp
	Private oPnlTop
	Private oPnlMid
	
	//Parâmetros de consulta
	Private cFilGX3	:= ""
	Private cFilGX4	:= ""
	Private cFilGWD	:= ""
	Private cUsuGX3	:= ""
	Private cUsuGX4A:= ""
	Private cUsuGX4B:= ""
	Private cUsuGX4C:= ""
	Private cUsuGX4D:= ""
	Private cUsuGWD	:= ""
	Private cDtMvGX3:= ""
	Private cSitGX3	:= ""
	Private cMvOpGX3:= ""
	Private cMvSqGX3:= ""
	Private oWTop
	Private oWMid
	Private oWLef
	Private oWRig
	
	Private cPicPadrao := "@E 999,999,999.99"
	
	If !Parametros()
		Return
	EndIf
	
	Define MsDialog oDLGC518 Title cTitulo From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
	
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDLGC518,.F.)
	
	oFWLayer:AddLine('LINE_TOP',30,.F.)
	oFWLayer:AddLine('LINE_MIDDLE',30,.F.)
	oFWLayer:AddLine('LINE_BOTTOM',40,.F.)
	
	oFWLayer:AddCollumn('COL_TOP',100,.T.,'LINE_TOP')
	oFWLayer:AddCollumn('COL_MIDDLE',100,.T.,'LINE_MIDDLE')
	oFWLayer:AddCollumn('COL_BOT_LEFT',60,.T.,'LINE_BOTTOM')
	oFWLayer:AddCollumn('COL_BOT_RIGHT',40,.T.,'LINE_BOTTOM')
	
    oFWLayer:AddWindow('COL_BOT_LEFT','WIN_BOT_LEFT','Gráficos',100,.F.,.F.,,'LINE_BOTTOM',)
    
    oWTop   := oFWLayer:GetColPanel('COL_TOP','LINE_TOP')
    oWMid	:= oFWLayer:GetColPanel('COL_MIDDLE','LINE_MIDDLE')
    oWLef	:= oFWLayer:GetWinPanel('COL_BOT_LEFT','WIN_BOT_LEFT','LINE_BOTTOM')
	oWRig	:= oFWLayer:GetColPanel('COL_BOT_RIGHT','LINE_BOTTOM')
	
    oDLGC518:Activate(,,,.T.,,,{||Processa({||Iniciar()})})
    GfeDelTab(cAliasUSU)
    GfeDelTab(cAliasMOV)
Return

Function GFEC518PAR()
	If Parametros(.T.)
		Processa({||Atualizar()})
	EndIf
Return

Static Function CriaRelBrw()
	Local cTmp
	Local bChange
	If Type("oBrowseUsu:bChange") == "B"
		cTmp := GetCbSource(oBrowseUsu:bChange)
		cTmp := SubStr(cTmp, 1, Len(cTmp) -1) + ", C518BCHANGE() }"
		bChange := &(cTmp)
	Else
		bChange := {|| C518BCHANGE() } 
	EndIf
	
	oBrowseUsu:SetChange(bChange)
	
	If Type("oBrowseMov:bChange") == "B"
		cTmp := GetCbSource(oBrowseMov:bChange)
		cTmp := SubStr(cTmp, 1, Len(cTmp) -1) + ", C518CCHANGE() }"
		bChange := &(cTmp)
	Else
		bChange := {|| C518CCHANGE() } 
	EndIf
	
	oBrowseMov:SetChange(bChange)
	
Return

Static Function CriaBrwUsu(aBrwUsu)
	oPnlTop := tPanel():New(00,00,,oWTop,,,,,,60,60,.F.,.F.)
	oPnlTop:Align := CONTROL_ALIGN_ALLCLIENT
	oBrowseUsu:= FWMBrowse():New() 
	oBrowseUsu:SetOwner(oPnlTop)  
	oBrowseUsu:SetDescription("Usuários")
	oBrowseUsu:SetAlias(cAliasUsu)
	oBrowseUsu:DisableDetails()
	oBrowseUsu:DisableConfig()
	oBrowseUsu:DisableFilter()
	oBrowseUsu:SetWalkthru(.F.)
	oBrowseUsu:SetMenuDef("GFEC518A")
	oBrowseUsu:ForceQuitButton(.T.)
	
	SetColunas(aBrwUsu[1],"cAliasUsu", oBrowseUsu)
	
	oBrowseUsu:Activate()
Return

Static Function CriaBrwMov(aBrwMov)
	oPnlMid := tPanel():New(00,00,,oWMid,,,,,,60,60,.F.,.F.)
	oPnlMid:Align := CONTROL_ALIGN_ALLCLIENT
	oBrowseMov:= FWMBrowse():New() 
	oBrowseMov:SetOwner(oPnlMid)
	oBrowseMov:SetDescription("Movimentações")
	oBrowseMov:SetAlias(cAliasMOV)
	oBrowseMov:DisableDetails()
	oBrowseMov:DisableConfig()
	oBrowseMov:DisableFilter()
	oBrowseMov:DisableReport()
	oBrowseMov:SetWalkthru(.F.)
	oBrowseMov:SetFixedBrowse(.T.)
	oBrowseMov:SetMenuDef("GFEC518")
		
	SetColunas(aBrwMov[1],"cAliasMOV", oBrowseMov)
	oBrowseMov:Activate()
Return

Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE "Consultar movimentação" 	ACTION "GFEC518MOV()" OPERATION 2 ACCESS 0
Return aRotina

Static Function Atualizar()
	Local	aBrwUsu := {}
	Local	aBrwMov := {}
	
	ProcRegua(10)
	
	dbSelectArea(cAliasUsu)
	ZAP
	
	dbSelectArea(cAliasMov)
	ZAP
	
	IncProc("Consultando usuários")
	aBrwUsu := StruUsuario(.F.)
	ConsUsuario(aBrwUsu[2])
	
	IncProc("Consultando movimentações")
	aBrwMov := StruMovimen(.F.)
	ConsMovimen(aBrwMov[2])
	//Auxilia a evitar bugs de foco de componente
	oBrowseUsu:Disable()
	oBrowseUsu:Refresh()
	oBrowseUsu:Enable()
	oBrowseUsu:Refresh()
	oBrowseMov:Disable()
	oBrowseMov:Refresh()
	oBrowseMov:Enable()
	oBrowseMov:Refresh()
	IncProc("Ativando gráficos, estatísticas e relacionamentos")
	(cAliasUsu)->(dbGoTop())
	oBrowseUsu:Refresh()
	oBrowseUsu:SetFocus()
	Eval(oBrowseUsu:bChange)
Return

/*
	Inicia as atividades de consulta
*/
Static Function Iniciar()
	
	Local	aBrwUsu := {}
	Local	aBrwMov := {}
	
	ProcRegua(10)
	
	IncProc("Consultando usuários")
	aBrwUsu := StruUsuario()
	ConsUsuario(aBrwUsu[2])
	
	IncProc("Consultando movimentações")
	aBrwMov := StruMovimen()
	ConsMovimen(aBrwMov[2])
	
	IncProc("Ativando browse movimentações")
	CriaBrwMov(aBrwMov)
		
	IncProc("Ativando browse usuários")
	CriaBrwUsu(aBrwUsu)
	
	C518BCHANGE(.T.)
	
	oFolder := TFOLDER():New(11,0,{"Tempo Pto Controle", "Tempo Geral", "Atend Operação", "Operações"},{"F1","F2","F3","F4"}, oWLef,,,, .T.,, 10, 10,)
	oFolder:Align := CONTROL_ALIGN_ALLCLIENT
	
	CriaPnls(3,.T.)
	
	IncProc("Ativando Gráficos - Barras")
	 // Gráfico Médio usuário Posicionado x Pto controle Posicionado

	GFEC001GRC("oGrafTempPt", "Tempo Médio Usuário x Pto Controle", oPnlTempPt, aGrafTempPt,cPicPadrao,,BARCHART)
	
	// Gráfico Médio usuário Posicionado x outros usuários
	GFEC001GRC("oGrafTempGe", "Tempo Médio Usuário x Tempo Médio Geral", oPnlTempGe, aGrafTempGe,cPicPadrao,,BARCHART)
	
	IncProc("Ativando Gráficos - Pizzas")
	// Gráfico Tempo médio por operação do usuário
	GFEC001GRC("oGrafAtOp", "Tempo médio atendimento por operação", oPnlAtOp, aGrafAtOp,cPicPadrao)
	// Gráfico quantidade por operação do usuário
	GFEC001GRC("oGrafQtOp", "Quantidade por Operação", oPnlQtOp, aGrafQtOp,cPicPadrao)
			
	IncProc("Ativando Estatísticas - Geral")
	oFolder2 := TFOLDER():New(11,0,{"Geral", "Ponto Controle"},{"F1A","F2A"}, oWRig,,,, .T.,, 10, 10,)
	oFolder2:Align := CONTROL_ALIGN_ALLCLIENT
	oBrwEstGer := FWBrowse():New()
	oBrwEstGer:SetOwner(oFolder2:ADialogs[1])
	oBrwEstGer:SetDescription("Estatísticas") 
	oBrwEstGer:SetDataArray()
	oBrwEstGer:DisableFilter()
	oBrwEstGer:DisableConfig()
	oBrwEstGer:SetArray(aBrwEstGer)
   	oBrwEstGer:SetColumns(GFEC001COL("Descrição",1,,1,15,"oBrwEstGer"))
	oBrwEstGer:SetColumns(GFEC001COL("Valor",2,,1,20,"oBrwEstGer"))
	oBrwEstGer:Activate()
	
	IncProc("Ativando Estatísticas - Ponto Controle")
	oBrwEstPto := FWBrowse():New()
	oBrwEstPto:SetOwner(oFolder2:ADialogs[2])
	oBrwEstPto:SetDescription("Estátisticas") 
	oBrwEstPto:SetDataArray()
	oBrwEstPto:DisableFilter()
	oBrwEstPto:DisableConfig()
	oBrwEstPto:SetArray(aBrwEstPto)
   	oBrwEstPto:SetColumns(GFEC001COL("Descrição",1,,1,15,"oBrwEstPto"))
	oBrwEstPto:SetColumns(GFEC001COL("Valor",2,,1,20,"oBrwEstPto"))
	oBrwEstPto:Activate()
	
	CriaRelBrw()
	oBrowseUsu:Refresh()
	oBrowseUsu:SetFocus()
Return

Function GFEC518MOV()
	GX3->(dbSetOrder(1))
	GX3->(dbSeek((cAliasMOV)->GX4_FILIAL + (cAliasMOV)->GX4_NRMOV))
	FWExecView("Visualizar","GFEC510",MODEL_OPERATION_VIEW,,{||.T.})
Return

Function C518BCHANGE(lInit)
	Local nX
	Local aBrwMov := StruMovimen(.F.)
	Static nLastNx := 0
	Default lInit := .F.
	nX := AtuArrays(4)[1]
	dbSelectArea(cAliasMov)
	ZAP
	ConsMovimen(aBrwMov[2],.F.)//Consulta executada para filtrar o segundo browse
	oBrowseMov:Disable()
	oBrowseMov:Refresh()
	oBrowseMov:Enable()
	oBrowseMov:Refresh()
	If !lInit
		LimpaObjs(3)
		CriaPnls(3)
		GFEC001GRC("oGrafTempPt", "Tempo Médio Usuário x Pto Controle", oPnlTempPt, aGrafTempPt,cPicPadrao,,BARCHART)
		GFEC001GRC("oGrafTempGe", "Tempo Médio Usuário x Tempo Médio Geral", oPnlTempGe, aGrafTempGe,cPicPadrao,,BARCHART)
		GFEC001GRC("oGrafAtOp", "Atendimento por Operação", oPnlAtOp, aGrafAtOp,cPicPadrao)
		GFEC001GRC("oGrafQtOp", "Quantidade por Operação", oPnlQtOp, aGrafQtOp,cPicPadrao)
		oBrwEstGer:SetArray(aBrwEstGer)
		oBrwEstGer:Refresh()
		oBrwEstPto:SetArray(aBrwEstPto)
		oBrwEstPto:Refresh()
	EndIf
	nLastNx := nX
	
Return

Function C518CCHANGE()
	Local nX
	Static nLastNx := 0
	nX := AtuArrays(0)[1]
	If nLastNx != nX .And. nX > 0
		LimpaObjs(0)
		CriaPnls(0)
		GFEC001GRC("oGrafTempPt", "Tempo Médio Usuário x Pto Controle", oPnlTempPt, aGrafTempPt,cPicPadrao,,BARCHART)
		oBrwEstPto:SetArray(aBrwEstPto)
		oBrwEstPto:Refresh()
	EndIf
	nLastNx := nX 
Return

Static Function AtuArrays(nOrdem)
	Local nX := 0
	Local nX2 := 0
	Default nOrdem := 0
	aGrafTempPt := {}
	aGrafTempGe := {}
	Parametros(.F.,.F.)
	
	If nOrdem >= 0 .And. !Empty((cAliasMOV)->GX4_CDPTCT)
		nX := aScan(aPto,{|x|x[1] == (cAliasMOV)->GX4_CDPTCT})
		nX2 := aScan(aUsuPto,{|x|x[1] == (cAliasUSU)->GX3_USUCRI .And. x[2] == (cAliasMOV)->GX4_CDPTCT})
		
		aGrafTempPt := {{"Usuário",Round((cAliasUSU)->ATENDAVG,2)},{"Ponto de Controle",Round(If(nX>0,aPto[nx][2],0),2)}}
		 
		aBrwEstPto :=	{;
							{"Usuário"						,AllTrim((cAliasUSU)->GX3_USUCRI)},;
							{"Data inicial"				,DTOC(MV_PAR05)},;
							{"Data final"					,DTOC(MV_PAR06)},;
							{"Ponto de Controle"			,(cAliasMOV)->GX4_CDPTCT},;
							{"Qtd Movimentações"			,cValToChar(If(nX2>0,aUsuPto[nX2][5],0))},;
							{"Qtd Ocorrências"			,cValToChar(If(nX2>0,aUsuPto[nX2][6],0))},;
							{"Tempo médio atend usu"		,cValToChar(Round(If(nX2>0,aUsuPto[nX2][3],0),2))},;
							{"Tempo médio atend geral"	,cValToChar(Round(If(nX>0,aPto[nX][2],0),2))},;
							{"Qtd Reprovações"			,cValToChar(If(nX2>0,aUsuPto[nX2][7],0))};
					 	}
	ElseIf nOrdem >= 0 .And. Empty((cAliasMOV)->GX4_CDPTCT)
		aGrafTempPt := {{"Usuário",0},{"Ponto de Controle",0}}
		 
		aBrwEstPto :=	{;
							{"Usuário"						,""},;
							{"Data inicial"				,DTOC(MV_PAR05)},;
							{"Data final"					,DTOC(MV_PAR06)},;
							{"Ponto de Controle"			,""},;
							{"Qtd Movimentações"			,"0"},;
							{"Qtd Ocorrências"			,"0"},;
							{"Tempo médio atend usu"		,"0"},;
							{"Tempo médio atend geral"	,"0"},;
							{"Qtd Reprovações"			,"0"};
					 	}
	EndIf
	
	If nOrdem >= 1 .And. !Empty((cAliasUSU)->ATENDAVG)
		aGrafTempGe	:= {{"Usuário",Round((cAliasUSU)->ATENDAVG,2)},{"Média Geral",Round(nMediaGeUsu,2)}}
	EndIf
	
	If nOrdem >= 3
		aGrafAtOp := {}
		aGrafQtOp := {}
		For nX2 := 1 To Len(aUsuOper)
			If aUsuOper[nX2][1] == (cAliasUSU)->GX3_USUCRI
				aAdd(aGrafAtOp,{aUsuOper[nX2][2],Round(aUsuOper[nX2][3],2)})
				aAdd(aGrafQtOp,{aUsuOper[nX2][2],Round(aUsuOper[nX2][4],2)})
			EndIf
		Next nX
	EndIf
	
	If nOrdem >= 4
		aBrwEstGer :=	{;
							{"Usuário"						,AllTrim((cAliasUSU)->GX3_USUCRI)},;
							{"Data inicial"				,DTOC(MV_PAR05)},;
							{"Data final"					,DTOC(MV_PAR06)},;
							{"Qtd Movimentações"			,cValToChar((cAliasUSU)->QTDMOVIMEN)},;
							{"Qtd Ocorrências"			,cValToChar((cAliasUSU)->QTDOCORREN)},;
							{"Tempo médio atend usu"		,cValToChar((cAliasUSU)->ATENDAVG)},;
							{"Tempo médio atend geral"	,cValToChar(Round(nMediaGeUsu,2))},;
							{"Qtd Reprovações"			,cValToChar((cAliasUSU)->QTDREPRO)};
					 	}
	EndIf
	
Return {nX}

Static Function LimpaObjs(nOrdem)
	Default nOrdem := 0
	If nOrdem >= 0
		FreeObj(oGrafTempPt)
		oPnlTempPt:FreeChildren()
		FreeObj(oPnlTempPt)
		oFolder:ADialogs[1]:FreeChildren()
	EndIf
	If nOrdem >= 1
		FreeObj(oGrafTempGe)
		oPnlTempGe:FreeChildren()
		FreeObj(oPnlTempGe)
		oFolder:ADialogs[2]:FreeChildren()
	EndIf
	If nOrdem >= 2
		FreeObj(oGrafAtOp)
		oPnlAtOp:FreeChildren()
		FreeObj(oPnlAtOp)
		oFolder:ADialogs[3]:FreeChildren()
	EndIf
	If nOrdem >= 3
		FreeObj(oGrafQtOp)
		oPnlQtOp:FreeChildren()
		FreeObj(oPnlQtOp)
		oFolder:ADialogs[4]:FreeChildren()
	EndIf
Return

Static Function CriaPnls(nOrdem,lInit)
	Local nOpt := 1
	Default nOrdem := 0
	Default lInit := .F.
	
	If nOrdem >= 0
		If lInit
			nOpt := oFolder:nOption
			oFolder:ShowPage(1) // Dependendo da versão do binário, pode ocorrer erro se a página não estiver sendo exibida na criação do componente
		EndIf
		oPnlTempPt := tPanel():New(00,00,,oFolder:ADialogs[1],,,,,,60,60,.F.,.F.)
		oPnlTempPt:Align := CONTROL_ALIGN_ALLCLIENT
	EndIf
	If nOrdem >= 1
		If lInit
			oFolder:ShowPage(2) // Dependendo da versão do binário, pode ocorrer erro se a página não estiver sendo exibida na criação do componente
		EndIf
		oPnlTempGe := tPanel():New(00,00,,oFolder:ADialogs[2],,,,,,60,60,.F.,.F.)
		oPnlTempGe:Align := CONTROL_ALIGN_ALLCLIENT
	EndIf
	If nOrdem >= 2
		If lInit
			oFolder:ShowPage(3) // Dependendo da versão do binário, pode ocorrer erro se a página não estiver sendo exibida na criação do componente
		EndIf
		oPnlAtOp := tPanel():New(00,00,,oFolder:ADialogs[3],,,,,,60,60,.F.,.F.)
		oPnlAtOp:Align := CONTROL_ALIGN_ALLCLIENT
	EndIf
	If nOrdem >= 3
		If lInit
			oFolder:ShowPage(4) // Dependendo da versão do binário, pode ocorrer erro se a página não estiver sendo exibida na criação do componente
		EndIf
		oPnlQtOp := tPanel():New(00,00,,oFolder:ADialogs[4],,,,,,60,60,.F.,.F.)
		oPnlQtOp:Align := CONTROL_ALIGN_ALLCLIENT
	EndIf
	oFolder:ShowPage(nOpt)
Return

Static Function Parametros(lShow,lVar)
	Default lShow := .T.
	Default lVar := .T.
	
	If lShow
		If !Pergunte("GFEC518",.T.)
			Return .F.
		EndIf
	Else
		Pergunte("GFEC518",.F.)
	EndIf
	
	If !lVar
		Return .T.
	EndIf
	//Limpa Variáveis
	cFilGX3 := cFilGX4 := cFilGWD := cUsuGX3 := cUsuGX4A := cUsuGX4B := cUsuGX4C := cUsuGX4D := cUsuGWD := cDtMvGX3 := cSitGX3 := cMvOpGX3 := cMvSqGX3 := ""
	
	If !Empty(MV_PAR01)
		cFilGX3	+= " AND GX3.GX3_FILIAL >= '" + MV_PAR01 + "'"
		cFilGX4	+= " AND GX4.GX4_FILIAL >= '" + MV_PAR01 + "'"
		cFilGWD	+= " AND GWD.GWD_FILIAL >= '" + MV_PAR01 + "'"
	EndIf
	
	If !Empty(MV_PAR02)
		cFilGX3	+= " AND GX3.GX3_FILIAL <= '" + MV_PAR02 + "'"
		cFilGX4	+= " AND GX4.GX4_FILIAL <= '" + MV_PAR02 + "'"
		cFilGWD	+= " AND GWD.GWD_FILIAL <= '" + MV_PAR02 + "'"
	EndIf
	
	If !Empty(MV_PAR03)
		MV_PAR03 := Padr(MV_PAR03,50)
		cUsuGX3	+= " AND GX3.GX3_USUCRI >= '" + MV_PAR03 + "'"
		cUsuGX4A	+= " AND GX4.GX4_USUENT >= '" + MV_PAR03 + "'"
		cUsuGX4B	+= " AND GX4.GX4_USUSAI >= '" + MV_PAR03 + "'"
		cUsuGX4C	+= " AND GX4.GX4_USUPES >= '" + MV_PAR03 + "'"
		cUsuGX4D	+= " AND GX4.GX4_REPUSU >= '" + MV_PAR03 + "'"
		cUsuGWD	+= " AND GWD.GWD_USUCRI >= '" + MV_PAR03 + "'"
	EndIf
	
	If !Empty(MV_PAR04)
		MV_PAR04 := Padr(MV_PAR04,50)
		cUsuGX3	+= " AND GX3.GX3_USUCRI <= '" + MV_PAR04 + "'"
		cUsuGX4A	+= " AND GX4.GX4_USUENT <= '" + MV_PAR04 + "'"
		cUsuGX4B	+= " AND GX4.GX4_USUSAI <= '" + MV_PAR04 + "'"
		cUsuGX4C	+= " AND GX4.GX4_USUPES <= '" + MV_PAR04 + "'"
		cUsuGX4D	+= " AND GX4.GX4_REPUSU <= '" + MV_PAR04 + "'"
		cUsuGWD	+= " AND GWD.GWD_USUCRI <= '" + MV_PAR04 + "'"
	EndIf
	
	If !Empty(MV_PAR05)
		cDtMvGX3+= " AND GX3.GX3_DTCRIA >= '" + DTOS(MV_PAR05) + "'"
	EndIf
	
	If !Empty(MV_PAR06)
		cDtMvGX3+= " AND GX3.GX3_DTCRIA <= '" + DTOS(MV_PAR06) + "'"
	EndIf
	
	If Iif(Type("MV_PAR07") == "C", Val(MV_PAR07),MV_PAR07) == 2
		cSitGX3 += " AND GX3.GX3_SIT IN ('1','2','3','4')"
	ElseIf Iif(Type("MV_PAR07") == "C", Val(MV_PAR07),MV_PAR07) == 3
		cSitGX3 += " AND GX3.GX3_SIT <> '5'"
	EndIf
	
	If !Empty(MV_PAR08)
		cMvOpGX3+= " AND GX3.GX3_CDOPER >= '" + MV_PAR08 + "'"
	EndIf
	
	If !Empty(MV_PAR09)
		cMvSqGX3+= " AND GX3.GX3_SEQ >= '" + MV_PAR09 + "'"
	EndIf
	
	If !Empty(MV_PAR10)
		cMvOpGX3+= " AND GX3.GX3_CDOPER <= '" + MV_PAR10 + "'"
	EndIf
	
	If !Empty(MV_PAR11)
		cMvSqGX3+= " AND GX3.GX3_SEQ <= '" + MV_PAR11 + "'"	
	EndIf
Return .T.

/*-----------------------------------------------------------
Estrutura do Browse Usuários
-----------------------------------------------------------*/

Static Function StruUsuario(lCriaTab)
	Local aStru := {}
	Local nCont
	
	Local aFlds := ;
	{{"Nome Usuário"			,"NOMEUSUAR"	,"C",32,0,"",1,8,.T.},;
	{"Usuário"					,"GX3_USUCRI"	,"C",50,0,"",1,8,.T.},;
	{"Qtd Movimentações"		,"QTDMOVIMEN"	,"N",15,0,"",1,8,.T.},;
	{"Qtd Ocorrências"			,"QTDOCORREN"	,"N",15,0,"",1,8,.T.},;
	{"Tempo médio atendimento"	,"ATENDAVG"	,"N",15,2,"@E 99999.99",1,8,.T.},;
	{"Tempo máximo atendimento"	,"ATENDMAX"	,"N",15,2,"@E 99999.99",1,8,.T.},;
	{"Tempo mínimo atendimento"	,"ATENDMIN"	,"N",15,2,"@E 99999.99",1,8,.T.},;
	{"Qtd pesagem"				,"QTDPESO"	 	,"N",15,0,"",1,8,.T.},;
	{"Reprovações"				,"QTDREPRO"	,"N",15,0,"",1,8,.T.},;
	{"Entrada Pto Controle"		,"QTDENTR"	 	,"N",15,0,"",1,8,.T.},;
	{"Saídas Pto Controle"		,"QTDSAI"	 	,"N",15,0,"",1,8,.T.};
	}
	Default lCriaTab := .T.
	For nCont := 1 to Len(aFlds)
		aADD(aStru,{	aFlds[nCont][2],;  //Nome do campo
						aFlds[nCont][3],;  //Tipo
						aFlds[nCont][4],;  //Tamanho
						aFlds[nCont][5]}) //Decimal
	Next nX
	If lCriaTab
		cAliasUSU := GFECriaTab({aStru,{"GX3_USUCRI","NOMEUSUAR"}})
	EndIf
	
Return {aFlds,aStru}

/*-----------------------------------------------------------
Estrutura do Browse Movimentações
-----------------------------------------------------------*/

Static Function StruMovimen(lCriaTab)
	Local aStru := {}
	Local nCont
	
	Local aFlds := ;
	{{"Filial"				,"GX4_FILIAL","C",TamSX3("GX4_FILIAL")[1]	,0,"",1,2,.T.},;
	{"Movimentação"			,"GX4_NRMOV" ,"C",08							,0,"",1,8,.T.},;
	{"Ponto de Controle"	,"GX4_CDPTCT","C",16					 		,0,"",1,8,.T.},;
	{"Criou Movimento?"		,"GX3_USUCRI","C",50							,0,"",1,8,.T.,{||If ((cAliasMOV)->GX3_USUCRI == (cAliasUSU)->GX3_USUCRI,"Sim","Não")}},;
	{"Reg Entrada?"			,"GX4_USUENT","C",50					 		,0,"",1,8,.T.,{||If ((cAliasMOV)->GX4_USUENT == (cAliasUSU)->GX3_USUCRI,"Sim","Não")}},;
	{"Reg Saída?"			,"GX4_USUSAI","C",50					 		,0,"",1,8,.T.,{||If ((cAliasMOV)->GX4_USUSAI == (cAliasUSU)->GX3_USUCRI,"Sim","Não")}},;
	{"Pesagem?"				,"GX4_USUPES","C",50					 		,0,"",1,8,.T.,{||If ((cAliasMOV)->GX4_USUPES == (cAliasUSU)->GX3_USUCRI,"Sim","Não")}},;
	{"Reprovado?"			,"GX4_REPUSU","C",50					 		,0,"",1,8,.T.,{||If ((cAliasMOV)->GX4_USUSAI == (cAliasUSU)->GX3_USUCRI .And. (cAliasMOV)->GX4_SIT == '3',"Sim","Não")}},;
	{"Ocorrências?"			,"GWD_USUCRI","C",50					 		,0,"",1,8,.T.,{||If ((cAliasMOV)->GWD_USUCRI == (cAliasUSU)->GX3_USUCRI,"Sim","Não")}},;
	{"Tempo Atendimento"	,"TEMPOATEND","C",15					 		,0,"",1,8,.T.,{||ShowAtend()}},;
	{"Dt Entrada"			,"GX4_DTENTR","D",08					 	 	,0,"",1,8,.F.},;
	{"Hr Entrada"			,"GX4_HRENTR","C",05					 	 	,0,"",1,8,.F.},;
	{"Dt Saída"				,"GX4_DTSAI" ,"D",08					 	 	,0,"",1,8,.F.},;
	{"Hr Saída"				,"GX4_HRSAI" ,"C",05					 	 	,0,"",1,8,.F.},;
	{"Código Operação"		,"GX3_CDOPER","C",16					 		,0,"",1,8,.F.},;
	{"SEQ"					,"GX4_SEQ"	 ,"C",03						 	,0,"",1,8,.F.},;
	{"SIT"					,"GX4_SIT"	 ,"C",01						 	,0,"",1,8,.F.};
	}
	Default lCriaTab := .T.
	For nCont := 1 to Len(aFlds)
		aADD(aStru,{	aFlds[nCont][2],;  //Nome do campo
						aFlds[nCont][3],;  //Tipo
						aFlds[nCont][4],;  //Tamanho
						aFlds[nCont][5]}) //Decimal
	Next nX
	If lCriaTab
		cAliasMOV := GFECriaTab({aStru,{"GX4_FILIAL+GX4_NRMOV+GX4_SEQ+GX4_CDPTCT"}})
	EndIf
	
Return {aFlds,aStru}

Static Function ShowAtend()
	Local _nTempo := GetTempoMov((cAliasMOV)->GX4_DTENTR,(cAliasMOV)->GX4_DTSAI,(cAliasMOV)->GX4_HRENTR,(cAliasMOV)->GX4_HRSAI)
	
	If (cAliasMOV)->GX4_USUENT != (cAliasUSU)->GX3_USUCRI .Or. (cAliasMOV)->GX4_USUSAI != (cAliasUSU)->GX3_USUCRI .Or. _nTempo == 0 
		cRet := "Indeterminado"
	Else
		cRet := Transform(_nTempo,"@E 99999.99")
	EndIf
Return cRet

/*-----------------------------------------------------------
Consulta do Browse Movimentações
-----------------------------------------------------------*/

Static Function ConsUsuario(aStru)
	Local cQuery 	:= ""
	Local cUsrFName	:= UsrFullName((cAliasUSU)->GX3_USUCRI)

	aUsu := {}
	
	cQuery+="SELECT A.GX3_USUCRI,SUM(A.QTDENTR) QTDENTR"
	cQuery+=" ,SUM(A.QTDMOVIMEN) QTDMOVIMEN"
	cQuery+=" ,SUM(A.QTDOCORREN) QTDOCORREN"
	cQuery+=" ,SUM(A.QTDPESO) QTDPESO"
	cQuery+=" ,SUM(A.QTDREPRO) QTDREPRO"
	cQuery+=" ,SUM(A.QTDSAI) QTDSAI"
	cQuery+=" FROM("
	cQuery+="SELECT "
	cQuery+="	GVP.GX3_NRMOV, GVP.GX3_USUCRI,"
	cQuery+="	COUNT(GVP.GX3_USUCRI) QTDMOVIMEN,"
	cQuery+="	(SELECT COUNT(GWD.GWD_USUCRI) "
	cQuery+="		FROM " + RetSqlName("GWD") + " GWD "
	cQuery+="		WHERE GWD.D_E_L_E_T_ = ''"
	cQuery+="			AND GWD.GWD_USUCRI = GVP.GX3_USUCRI"
	cQuery+="			AND GWD.GWD_NRMOV = GVP.GX3_NRMOV"
	cQuery+="			AND GWD.GWD_CDPTCT <> ''"
	cQuery+="		)QTDOCORREN,"
	cQuery+="	(SELECT COUNT(GX4.GX4_NRMOV) "
	cQuery+="		FROM " + RetSqlName("GX4") + " GX4 "
	cQuery+="		WHERE GX4.D_E_L_E_T_ = ''"
	cQuery+="			AND GX4_USUPES = GVP.GX3_USUCRI"
	cQuery+="			AND GX4_NRMOV = GVP.GX3_NRMOV"
	cQuery+="		)QTDPESO,"
	cQuery+="	(SELECT COUNT(GX4.GX4_NRMOV) "
	cQuery+="		FROM " + RetSqlName("GX4") + " GX4 "
	cQuery+="		WHERE GX4.D_E_L_E_T_ = ''"
	cQuery+="			AND GX4_USUSAI = GVP.GX3_USUCRI"
	cQuery+="			AND GX4_NRMOV = GVP.GX3_NRMOV"
	cQuery+="			AND GX4_SIT = '3'"
	cQuery+="		)QTDREPRO,"
	cQuery+="	(SELECT COUNT(GX4.GX4_NRMOV) "
	cQuery+="		FROM " + RetSqlName("GX4") + " GX4 "
	cQuery+="		WHERE GX4.D_E_L_E_T_ = ''"
	cQuery+="			AND GX4_USUENT = GVP.GX3_USUCRI"
	cQuery+="			AND GX4_NRMOV = GVP.GX3_NRMOV"
	cQuery+="		)QTDENTR,"
	cQuery+="	(SELECT COUNT(GX4.GX4_NRMOV) "
	cQuery+="		FROM " + RetSqlName("GX4") + " GX4 "
	cQuery+="		WHERE GX4.D_E_L_E_T_ = ''"
	cQuery+="			AND GX4_USUSAI = GVP.GX3_USUCRI"
	cQuery+="			AND GX4_NRMOV = GVP.GX3_NRMOV"
	cQuery+="		)QTDSAI"
	cQuery+="	FROM " + RetSqlName("GX3") + " GX3"
	cQuery+="	INNER JOIN"
	cQuery+="	(	SELECT GX3_USUCRI, GX3_FILIAL, GX3_NRMOV FROM " + RetSqlName("GX3") + " GX3 "
	cQuery+="		WHERE GX3.GX3_USUCRI <> '' AND GX3.D_E_L_E_T_ = ''" + cFilGX3 + cUsuGX3 + cDtMvGX3 + cSitGX3 + cMvOpGX3 + cMvSqGX3
	cQuery+="	UNION"
	cQuery+="		SELECT GX4_USUENT, GX4_FILIAL, GX4_NRMOV FROM " + RetSqlName("GX4") + " GX4 "
	cQuery+="		WHERE GX4.GX4_USUENT <> '' AND GX4.D_E_L_E_T_ = ''" + cFilGX4 + cUsuGX4A
	cQuery+="	UNION"
	cQuery+="		SELECT GX4_USUSAI, GX4_FILIAL, GX4_NRMOV FROM " + RetSqlName("GX4") + " GX4 "
	cQuery+="		WHERE GX4.GX4_USUSAI <> '' AND GX4.D_E_L_E_T_ = ''" + cFilGX4 + cUsuGX4B
	cQuery+="	UNION"
	cQuery+="		SELECT GX4_USUPES, GX4_FILIAL, GX4_NRMOV FROM " + RetSqlName("GX4") + " GX4 "
	cQuery+="		WHERE GX4.GX4_USUPES <> '' AND GX4.D_E_L_E_T_ = ''" + cFilGX4 + cUsuGX4C
	cQuery+="	UNION"
	cQuery+="		SELECT GX4_REPUSU, GX4_FILIAL, GX4_NRMOV FROM " + RetSqlName("GX4") + " GX4 "
	cQuery+="		WHERE GX4.GX4_REPUSU <> '' AND GX4.D_E_L_E_T_ = ''" + cFilGX4 + cUsuGX4D
	cQuery+="	UNION"
	cQuery+="		SELECT GWD_USUCRI, GWD_FILIAL, GWD_NRMOV FROM " + RetSqlName("GWD") + " GWD "
	cQuery+="		WHERE GWD.GWD_USUCRI <> '' AND GWD.D_E_L_E_T_ = '' AND GWD.GWD_NRMOV <> '' AND GWD.GWD_CDPTCT <> ''"
	cQuery+=cFilGWD + cUsuGWD
	cQuery+="	) GVP "
	cQuery+="		ON GVP.GX3_FILIAL = GX3.GX3_FILIAL "
	cQuery+="		AND GVP.GX3_NRMOV = GX3.GX3_NRMOV"
	cQuery+="	WHERE GX3.D_E_L_E_T_ = ''" + cFilGX3 + cDtMvGX3 + cSitGX3 + cMvOpGX3 + cMvSqGX3
	cQuery+="	GROUP BY GVP.GX3_USUCRI,GVP.GX3_NRMOV"
	cQuery+=")A GROUP BY A.GX3_USUCRI"
		
	SqlToTrb(cQuery,aStru,cAliasUSU)
	dbSelectArea(cAliasUSU)

	(cAliasUSU)->(dbSetOrder(1))
	(cAliasUSU)->(dbGotop())
	While !(cAliasUSU)->(Eof())
		aAdd(aUsu,{(cAliasUSU)->GX3_USUCRI,0,0,0,0})
		
		RecLock(cAliasUSU, .F.)
			(cAliasUSU)->NOMEUSUAR := cUsrFName
		(cAliasUSU)->(MsUnLock())
		
		(cAliasUSU)->(dbSkip())
	EndDo

	(cAliasUSU)->(dbSetOrder(2))
	(cAliasUSU)->(dbGotop())
Return

Static Function ConsMovimen(aStru,lInit)
	Local cQuery := ""
	Local cQryOcoPto := "" // Consulta de ocorrências por usuário/ponto de controle
	Local cAliOcoPto := ""
	Local nX
	Local nY
	Local cIn := ""
	Local nTempo := 0
	Local cChave := ""
	Local cChvMvOp:= ""
	Local cFiltro
	Default lInit := .T.
	nMediaGeUsu := 0
	
	If Len(aUsu) == 0
		Return
	EndIf
	
	cQuery+="	SELECT DISTINCT"
	cQuery+="		GX4.GX4_FILIAL,"
	cQuery+="		GX4.GX4_NRMOV,"
	cQuery+="		GX4.GX4_CDPTCT,"
	cQuery+="		GX4.GX4_USUENT,"
	cQuery+="		GX4.GX4_USUSAI,"
	cQuery+="		GX4.GX4_USUPES,"
	cQuery+="		GX4.GX4_REPUSU,"
	cQuery+="		GWD.GWD_USUCRI,"
	cQuery+="		GX4.GX4_DTENTR,"
	cQuery+="		GX4.GX4_HRENTR,"
	cQuery+="		GX4.GX4_DTSAI,"
	cQuery+="		GX3.GX3_CDOPER,"
	cQuery+="		GX4.GX4_HRSAI,"
	cQuery+="		GX4.GX4_SEQ,"
	cQuery+="		GX3.GX3_USUCRI,"
	cQuery+="		GX4.GX4_SIT"
	cQuery+="		"
	cQuery+="		FROM " + RetSqlName("GX3") + " GX3"
	cQuery+="		INNER JOIN " + RetSqlName("GX4") + " GX4" 
	cQuery+="			ON GX3.GX3_FILIAL = GX4.GX4_FILIAL"
	cQuery+="			AND GX3.GX3_NRMOV = GX4.GX4_NRMOV"
	cQuery+="			AND GX4.D_E_L_E_T_ = ''" 
	cQuery+="		"
	cQuery+="		LEFT JOIN " + RetSqlName("GWD") + " GWD"
	cQuery+="			ON GWD.GWD_FILIAL = GX4.GX4_FILIAL"
	cQuery+="			AND GWD.GWD_NRMOV = GX4.GX4_NRMOV"
	cQuery+="			AND GWD.GWD_CDPTCT = GX4.GX4_CDPTCT"
	cQuery+="			AND GWD.D_E_L_E_T_ = ''"
	cQuery+="		"
	cQuery+="		WHERE GX3.D_E_L_E_T_ = ''" + cFilGX3 + cDtMvGX3 + cSitGX3 + cMvOpGX3 + cMvSqGX3
	cFiltro := ""
	If lInit
		cFiltro+="		AND ("
		
		cIn := "("
		
		For nX := 1 to Len(aUsu)
			cIn += "'" + aUsu[nX][1] + "'"
			If nX != Len(aUsu)
				cIn += ","
			EndIf
		Next nX
		cIn += ")"
		
		cFiltro += "GX3.GX3_USUCRI IN" + cIn
		cFiltro += " OR "
		cFiltro += "GX4.GX4_USUENT IN " + cIn
		cFiltro += " OR "
		cFiltro += "GX4.GX4_USUSAI IN " + cIn
		cFiltro += " OR "
		cFiltro += "GX4.GX4_USUPES IN " + cIn
		cFiltro += " OR "
		cFiltro += "GX4.GX4_REPUSU IN " + cIn
	
		
		
		cAliOcoPto := GetNextAlias()
		
		
		cQryOcoPto += "	SELECT COUNT(*) QTDOCOPTO,        		"
		cQryOcoPto += "	GWD_CDPTCT,                       		"
		cQryOcoPto += "	GWD_USUCRI FROM  " + RetSqlName("GWD") + " GWD"
		cQryOcoPto += "	WHERE GWD.D_E_L_E_T_ = '' AND GWD.GWD_USUCRI IN " + cIn
		cQryOcoPto += "	AND EXISTS(SELECT 1 "
		cQryOcoPto += "				FROM " + RetSqlName("GX3") + " GX3 "
		cQryOcoPto += "				INNER JOIN " + RetSqlName("GX4") + " GX4 "
		cQryOcoPto += "				ON GX3.GX3_FILIAL = GX4.GX4_FILIAL		"
		cQryOcoPto += "				AND GX3.GX3_NRMOV = GX4.GX4_NRMOV 		"
		cQryOcoPto += "				WHERE GWD.GWD_NRMOV = GX4.GX4_NRMOV	"
		cQryOcoPto += "				AND GWD.GWD_CDPTCT = GX4.GX4_CDPTCT	"
		cQryOcoPto += "				AND GX4.D_E_L_E_T_ = ''          		"
		cQryOcoPto += "				AND GX3.D_E_L_E_T_ = ''          		"
		cQryOcoPto += cFilGX3 + cDtMvGX3 + cSitGX3 + cMvOpGX3 + cMvSqGX3 + cFiltro + ")"
		cQryOcoPto += "				)
		cQryOcoPto += "	GROUP BY GWD_CDPTCT,              		"
		cQryOcoPto += "	GWD_USUCRI                  		"
				
		cFiltro += " OR "
		cFiltro += "GWD.GWD_USUCRI IN " + cIn
		cFiltro +=")"
		
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQryOcoPto),cAliOcoPto, .F., .T.)
		
		
	Else
		cFiltro+="		AND ("
		
		cFiltro += "GX3.GX3_USUCRI = '" + (cAliasUsu)->GX3_USUCRI + "'"
		cFiltro += " OR "
		cFiltro += "GX4.GX4_USUENT = '" + (cAliasUsu)->GX3_USUCRI + "'"
		cFiltro += " OR "
		cFiltro += "GX4.GX4_USUSAI = '" + (cAliasUsu)->GX3_USUCRI + "'"
		cFiltro += " OR "
		cFiltro += "GX4.GX4_USUPES = '" + (cAliasUsu)->GX3_USUCRI + "'"
		cFiltro += " OR "
		cFiltro += "GX4.GX4_REPUSU = '" + (cAliasUsu)->GX3_USUCRI + "'"
		cFiltro += " OR "
		cFiltro += "GWD.GWD_USUCRI = '" + (cAliasUsu)->GX3_USUCRI + "'"
		cFiltro +=")"
	EndIf
	
	
	SqlToTrb(cQuery+cFiltro + " ORDER BY GX4_FILIAL,GX4_NRMOV,GX4_SEQ",aStru,cAliasMOV)
	dbSelectArea(cAliasMOV)
	(cAliasMOV)->(dbSetOrder(1))
	(cAliasMOV)->(dbGotop())
	If lInit
		IncProc("Calculando os tempos de atendimento")
		aPto := {}
		aUsuOper := {}
		aUsuPto := {}
		While !(cAliasMOV)->(Eof())
			nTempo := GetTempoMov((cAliasMOV)->GX4_DTENTR,(cAliasMOV)->GX4_DTSAI,(cAliasMOV)->GX4_HRENTR,(cAliasMOV)->GX4_HRSAI)
				
			cChave := (cAliasMOV)->(GX4_FILIAL+GX4_NRMOV)
			nX := aScan(aUsu,{|x|x[1] == (cAliasMOV)->GX4_USUENT .And. x[1] == (cAliasMOV)->GX4_USUSAI})
				
			If nX > 0 .And. !Empty(DTOS((cAliasMOV)->GX4_DTENTR)+DTOS((cAliasMOV)->GX4_DTSAI)+(cAliasMOV)->GX4_HRENTR+(cAliasMOV)->GX4_HRSAI)
				aUsu[nx][2] += nTempo // Média do Tempo
				If nTempo > 0
					aUsu[nx][5]++ // Quantidade de atendimentos para realizar média
				EndIf
					
				If aUsu[nx][3] < nTempo // Tempo Máximo
					aUsu[nx][3] := nTempo
				EndIf
					
				If aUsu[nx][4] > nTempo // Tempo Mínimo
					aUsu[nx][4] := nTempo
				EndIf
					
				If aUsu[nx][4] == 0
					aUsu[nx][4] := nTempo
				EndIf
					
				nY := aScan(aUsuOper,{|x|x[1] == (cAliasMOV)->GX4_USUENT .And. x[2] == (cAliasMOV)->GX3_CDOPER})
				If nY > 0//tempo e quantidade usuario X operações
					aUsuOper[nY][3]+=nTempo
					If nTempo > 0
						If cChvMvOp != cChave
							cChvMvOp := cChave
							aUsuOper[nY][4]++ // Quantidade de Movimentação
						EndIf
						aUsuOper[nY][5]++ // Quantidade de atendimentos
					EndIf
				Else
					cChvMvOp := cChave
					aAdd(aUsuOper,{(cAliasMOV)->GX4_USUENT,(cAliasMOV)->GX3_CDOPER,nTempo,If(nTempo >0,1,0),If(nTempo >0,1,0)})
				EndIf
				nY := aScan(aUsuPto,{|x|x[1] == (cAliasMOV)->GX4_USUENT .And. x[2] == (cAliasMOV)->GX4_CDPTCT})
				If nY > 0//tempo e quantidade usuario X pto
					aUsuPto[nY][3]+=nTempo
					If nTempo > 0
						aUsuPto[nY][4]++ // Quantidade de atendimento
					EndIf
					If aUsuPto[nY][8] != cChave // Última movimentação diferente usuário
						aUsuPto[nY][5]++ // Quantidade de Movimentações
					EndIf
					If (cAliasMOV)->GX4_USUSAI == (cAliasMOV)->GX4_USUENT .And. (cAliasMOV)->GX4_SIT == '3'
						aUsuPto[nY][7]++ // Quantidade de Reprovações
					EndIf
						
					aUsuPto[nY][8] := cChave
				Else
					aAdd(aUsuPto,{(cAliasMOV)->GX4_USUENT,(cAliasMOV)->GX4_CDPTCT,nTempo,If(nTempo>0,1,0),1,0,If ((cAliasMOV)->GX4_USUSAI == (cAliasMOV)->GX4_USUENT .And. (cAliasMOV)->GX4_SIT == '3',1,0),cChave})
				EndIf
					
				//Usuário de entrada e saída são os mesmos
				CriaUsuPto((cAliasMOV)->GX3_USUCRI,(cAliasMOV)->GX4_CDPTCT,(cAliasMOV)->GWD_USUCRI,(cAliasMOV)->GX4_USUSAI,cChave,(cAliasMOV)->GX4_SIT)
				CriaUsuPto((cAliasMOV)->GX4_USUPES,(cAliasMOV)->GX4_CDPTCT,(cAliasMOV)->GWD_USUCRI,(cAliasMOV)->GX4_USUSAI,cChave,(cAliasMOV)->GX4_SIT)
				CriaUsuPto((cAliasMOV)->GX4_REPUSU,(cAliasMOV)->GX4_CDPTCT,(cAliasMOV)->GWD_USUCRI,(cAliasMOV)->GX4_USUSAI,cChave,(cAliasMOV)->GX4_SIT)
				CriaUsuPto((cAliasMOV)->GWD_USUCRI,(cAliasMOV)->GX4_CDPTCT,(cAliasMOV)->GWD_USUCRI,(cAliasMOV)->GX4_USUSAI,cChave,(cAliasMOV)->GX4_SIT)
					
			ElseIf !Empty((cAliasMOV)->(GX3_USUCRI+GX4_USUENT+GX4_USUSAI+GX4_USUPES+GX4_REPUSU+GWD_USUCRI))
				//Apenas quando o usuário de entrada não é o mesmo que o de saída
				CriaUsuPto((cAliasMOV)->GX3_USUCRI,(cAliasMOV)->GX4_CDPTCT,(cAliasMOV)->GWD_USUCRI,(cAliasMOV)->GX4_USUSAI,cChave,(cAliasMOV)->GX4_SIT)
				CriaUsuPto((cAliasMOV)->GX4_USUENT,(cAliasMOV)->GX4_CDPTCT,(cAliasMOV)->GWD_USUCRI,(cAliasMOV)->GX4_USUSAI,cChave,(cAliasMOV)->GX4_SIT)
				CriaUsuPto((cAliasMOV)->GX4_USUSAI,(cAliasMOV)->GX4_CDPTCT,(cAliasMOV)->GWD_USUCRI,(cAliasMOV)->GX4_USUSAI,cChave,(cAliasMOV)->GX4_SIT)
				CriaUsuPto((cAliasMOV)->GX4_USUPES,(cAliasMOV)->GX4_CDPTCT,(cAliasMOV)->GWD_USUCRI,(cAliasMOV)->GX4_USUSAI,cChave,(cAliasMOV)->GX4_SIT)
				CriaUsuPto((cAliasMOV)->GX4_REPUSU,(cAliasMOV)->GX4_CDPTCT,(cAliasMOV)->GWD_USUCRI,(cAliasMOV)->GX4_USUSAI,cChave,(cAliasMOV)->GX4_SIT)
				CriaUsuPto((cAliasMOV)->GWD_USUCRI,(cAliasMOV)->GX4_CDPTCT,(cAliasMOV)->GWD_USUCRI,(cAliasMOV)->GX4_USUSAI,cChave,(cAliasMOV)->GX4_SIT)
					
			EndIf
				
			nX := aScan(aPto,{|x|x[1] == (cAliasMOV)->GX4_CDPTCT})
			//Tempo médio por ponto de controle
			If nX > 0
				aPto[nX][2] += nTempo
				If nTempo > 0
					aPto[nX][3]++ // Quantidade de atendimento somente se o atendimento está finalizado.
				EndIf
					
				If !Empty((cAliasMOV)->GX4_USUSAI) .And. (cAliasMOV)->GX4_SIT == '3'
					aPto[nX][5]++
				EndIf
			Else
				aAdd(aPto,{(cAliasMOV)->GX4_CDPTCT,nTempo,If(nTempo > 0,1,0),0,If (!Empty((cAliasMOV)->GX4_USUSAI) .And. (cAliasMOV)->GX4_SIT == '3',1,0)})
			EndIf
				
			(cAliasMOV)->(dbSkip())
		EndDo
		
		(cAliasMOV)->(dbgotop())
		
		IncProc("Atualizando os tempos de atendimento")
			
		For nX := 1 To Len(aUsu)
				
			If aUsu[nx][5] > 0
				aUsu[nx][2] := aUsu[nx][2]/aUsu[nx][5]
			Else
				aUsu[nx][2] := 0
			EndIf
				
			If (cAliasUSU)->(dbSeek(aUsu[nx][1]))
				RecLock(cAliasUSU,.F.)
				(cAliasUSU)->ATENDAVG := aUsu[nx][2]
				(cAliasUSU)->ATENDMAX := aUsu[nx][3]
				(cAliasUSU)->ATENDMIN := aUsu[nx][4]
				MsUnlock(cAliasUSU)
			EndIf
			nMediaGeUsu += aUsu[nx][2]
		Next nX
			
		nMediaGeUsu := nMediaGeUsu / (nX-1) // Média geral dos usuários
			
		For nX := 1 To Len(aPto)
			aPto[nx][2] := Round(aPto[nx][2]/aPto[nx][3],2)
		Next nX
			
		aSort(aUsuOper,,,{|x,y| x[1] + x[2] < y[1] + y[2]})
		aSort(aUsuPto,,,{|x,y| x[1] + x[2] < y[1] + y[2]})
			
		For nX := 1 To Len(aUsuOper)
			aUsuOper[nx][3] := Round(aUsuOper[nx][3]/aUsuOper[nx][5],2)
		Next nX
			
		For nX := 1 To Len(aUsuPto)
			If aUsuPto[nx][4] > 0
				aUsuPto[nx][3] := Round(aUsuPto[nx][3]/aUsuPto[nx][4],2)
			EndIf
		Next nX
	
		(cAliOcoPto)->(dbGoTop())
		While !(cAliOcoPto)->(Eof())
			If (nY := aScan(aPto,{|x|x[1] == (cAliOcoPto)->GWD_CDPTCT})) > 0
				aPto[nY][4] += (cAliOcoPto)->QTDOCOPTO
			EndIf
			If (nY := aScan(aUsuPto,{|x|x[1] == (cAliOcoPto)->GWD_USUCRI .And. x[2] == (cAliOcoPto)->GWD_CDPTCT})) > 0
				aUsuPto[nY][6] += (cAliOcoPto)->QTDOCOPTO
			EndIf
			(cAliOcoPto)->(dbSkip())
		EndDo
		(cAliOcoPto)->(dbCloseArea())
	EndIf
	Return


Static Function CriaUsuPto(cUsuario,cCDPTCT,cUsuGWD,cUsuRep,cChave,cSit)
	Local nY
	If !Empty(cUsuario)
		nY := aScan(aUsuPto,{|x|x[1] == cUsuario .And. x[2] == cCDPTCT})
		If nY > 0//quantidade usuario X pto
			//Não soma duplicado a quantidade de movimentações pela chave da última pesquisa
			If cChave == aUsuPto[nY][8]
				Return
			EndIf
			aUsuPto[nY][8] := cChave
			aUsuPto[nY][5]++ // Quantidade de Movimentações
			
			If cUsuRep == cUsuario .And. cSit == '3'
				aUsuPto[nY][7]++ // Quantidade de Reprovações
			EndIf
		Else
			aAdd(aUsuPto,{cUsuario,cCDPTCT,0,0,1,0,If (cUsuRep == cUsuario .And. cSit == '3',1,0),cChave})
		EndIf
	EndIf
Return

Static Function SetColunas(aCampos,cAli,oBrw)
Local nCount

For nCount := 1 To Len(aCampos)
		If aCampos[nCount][9]
			oBrw:AddColumn({aCampos[nCount][1],;
									If (Len(aCampos[nCount]) != 10,;
								     &("{|| (" + cAli + ")->" + aCampos[nCount][2] + "}"),;
								     aCampos[nCount][10]),;
								     aCampos[nCount][3],;
								     aCampos[nCount][6],;
								     aCampos[nCount][7],;
								     aCampos[nCount][8],;
								     aCampos[nCount][5],;
								     .F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}})
		EndIf						     
	Next nCount
	
Return

Static Function GetTempoMov(dtEnt,dtSai,hrEnt,hrSai)
	Local nHrDiff
	Local nMinDiff
	Local nTmDiff := 0
	dtEnt := DTOS(dtEnt)
	dtSai := DTOS(dtSai)
	If !Empty(dtEnt) .And. !Empty(dtSai) .And. !Empty(hrEnt) .And. !Empty(hrSai)
				
			// Calculo de horas restantes
			nHrDiff := Val(SubStr(ElapTime(AllTrim(Stuff(hrEnt,3,0,":"))+":00",AllTrim(Stuff(hrSai,3,0,":"))+":00"),1,2))
			nHrDiff := nHrDiff * 60 // Transforma em Minutos 
			
			// Calculo de minutos restantes
			nMinDiff := Val(SubStr(ElapTime(AllTrim(Stuff(hrEnt,3,0,":"))+":00",AllTrim(Stuff(hrSai,3,0,":"))+":00"),4,2))

			If ( dtEnt == dtSai .And. Val(hrEnt) < Val(hrSai) ) .Or. dtEnt < dtSai
				nTmDiff := ( ( (StoD(dtSai) - StoD(dtEnt)) * 24) * 60 ) + nHrDiff + nMinDiff
			ElseIf ( dtEnt == dtSai .And. Val(hrEnt) > Val(hrSai) ) .Or. dtEnt > dtSai
				nTmDiff := ( ( (StoD(dtSai) - StoD(dtEnt)) * 24) * 60 ) + nHrDiff + nMinDiff
			EndIf
			
			 Return nTmDiff / 60
		EndIf
Return 0
