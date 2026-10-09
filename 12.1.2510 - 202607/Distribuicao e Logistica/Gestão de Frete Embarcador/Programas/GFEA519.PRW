#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GFEA519.CH"

Static s_RetCodUsr := RetCodUsr()

//-------------------------------------------------------------------
//Inclusão Pátios 12.1.4
/*/{Protheus.doc} GFEA519

Registro de Movimentação

@author Jorge Matos Valcanaia / Octávio Augusto Felippe de Macedo
@since 07/09/2010
@version 1.0
/*/
//-------------------------------------------------------------------
//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA519

Registro de Movimentação visão geral

@author Siegklenes.Beulke
@since 18/09/2013
@version 2.0
/*/
//-------------------------------------------------------------------

Function GFEA519()

	Local aCoors := FWGetDialogSize(oMainWnd)
	Private lCpoSrGXA := GfeVerCmpo({"GXA_SDOC"})
	Private oDlg2
	Private aLMostrarDefault := {.T., .T., .T., .T., .F., .F.}
	Private aLMostrar  := {.T., .T., .T., .T., .F., .F.}
	Private oBrwGX3
	Private oBrwGX4
	Private cPlaca
	Private cBkpPlaca
	Private oBtnPadrao
	Private oGetPl
	Private cAliGX3
	Private aOper := {'',''}
	Private cOpAgen := ""
	Private oRelacGX4
	Private oPnlBrowses
	Private lPE1       := .F.
	Private lPE2       := .F.
	Private aCpoAlias  := {}
	Private aCpoAlias2 := {}
	//Privadas de 519b
	Private _cMov
	Private _cOper
	Private _cSeq
	Private _cPtCt
	Private _lNEnd
	Private _lNLib
	Private _lAtivo   := .F.
	Private _aAtuPC   := {"",""}
	Private lAlt
	Private lSame     := .F.
	Private aPtCt     := {,,,.F.}
	Private lModified := .F.
	Private cImped    := ""
	Private aDC       := {}
	Private aValid    := { {"NA","--","--"}, ; //1-Agen. (atraso)
	{"NA","--","--"}, ; //2-Agen. (antecipado)
	{"NA","--","--"}, ; //3-Peso mín.(valor)
	{"NA","--","--"}, ; //4-Peso mín.(%)
	{"NA","--","--"}, ; //5-Peso max.(valor)
	{"NA","--","--"}, ; //6-Peso max.(%)
	{"NA","--","--"}, ; //7-Peso max.(%)
	{"NA","--","--"}, ; //8-Peso max.(%)
	{"NA","--","--"} }  //9-Qtd. DC

	If !GFECheckGX4()
		Return .F.
	EndIF
	
	If !GFEA519VLD()
		Return
	EndIf

	Define MsDialog oDlg2 Title "Controle de Pátio" From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel

	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDlg2,.F.)

	oFWLayer:AddLine('LINE_ALL',100,.F.)
	oFWLayer:AddCollumn('COL_LEFT',25,.T.,'LINE_ALL')
	oFWLayer:AddWindow('COL_LEFT', 'Win_left', 'Opções', 100, .F., .F.,{|| },'LINE_ALL',{|| })
	oFWLayer:AddCollumn('COL_RIGHT',75,.T.,'LINE_ALL')

	oPnlFilters := oFWLayer:getWinPanel('COL_LEFT', 'Win_left','LINE_ALL')
	oPnlBrowses := oFWLayer:GetColPanel('COL_RIGHT', 'LINE_ALL')

	dbSelectArea("GX6")
	GX6->(dbSetOrder(1))

	oDlg2:Activate(,,,.T.,,,{|| CriaTela() })

Return Nil

Static Function CriaTela()
	Local oPanel, oBtn
	Local cTgetCss
	Local aSeek := {}
	Local aFiltro := {}

	// Criação do Layer BROWSES
	oFWLayerSec := FWLayer():New()
	oFWLayerSec:Init(oPnlBrowses,.F.)

	oFWLayerSec:AddLine('LINE_TOP',55,.F.)
	oFWLayerSec:AddCollumn('COL_TOP',100,.T.,'LINE_TOP')
	oPnlMovim:= oFWLayerSec:GetColPanel('COL_TOP', 'LINE_TOP')

	oFWLayerSec:AddLine('LINE_BOT',45,.F.)
	oFWLayerSec:AddCollumn('COL_BOT',100,.T.,'LINE_BOT')
	oPnlPonto:= oFWLayerSec:GetColPanel('COL_BOT', 'LINE_BOT')

	// -- Margens Esquerda x Direita

	oPanel := TPanel():New(0,60,,oPnlFilters,,,,,RGB(239,243,247),2,2,,)
	oPanel:Align := CONTROL_ALIGN_LEFT

	oPanel := TPanel():New(0,60,,oPnlFilters,,,,,RGB(239,243,247),2,2,,)
	oPanel:Align := CONTROL_ALIGN_RIGHT

	oPnlFilters := TPanel():New(0,60,,oPnlFilters,,,,,RGB(239,243,247),20,5,,)
	oPnlFilters:Align := CONTROL_ALIGN_ALLCLIENT

	// ----- Margem Superior

	oPanel := TPanel():New(0,60,,oPnlFilters,,,,,RGB(239,243,247),20,5,,)
	oPanel:Align := CONTROL_ALIGN_TOP

	//entrada do veículo
	oPanel := TPanel():New(0,60,,oPnlFilters,,,,,RGB(239,243,247),100,20,,)
	oPanel:Align := CONTROL_ALIGN_TOP
	oFont := TFont():New ("Tahoma", , -13, , .T., , , , , .F., .F. )
	oBtn := TButton():New(0,0, "Entrada Veículo", oPanel, {|| BtnVeiculo_Click() }, 20, 10,,oFont,, .T.,,,,/*[bWhen]*/)
	oBtn:Align := CONTROL_ALIGN_ALLCLIENT
	//FWGetCSS (<cclasse>, ntipo) nTipo buscar no arquivo FWCSS.CH
	cTgetCss := FWGetCSS( "TBUTTON", CSS_BUTTON )
	AddCss(@cTgetCss,"background-image: url(rpo:CARGA.png);background-repeat: none ;background-position: right")
	oBtn:SetCss(cTgetCss)

	oSay := TSay():New (005, 0, {|| "" }, oBtn, , oFont, , , , .T., CLR_BLUE, , Int(oBtn:NCLIENTHEIGHT/4)-7,Int(oBtn:NCLIENTHEIGHT/4)-7, ,,,,, .T. )
	oSay:Align := CONTROL_ALIGN_TOP
	oSay:lTransparent := .T.

	// ---- Checkboxes

	oPanel := TPanel():New(0,60,,oPnlFilters,,,,,RGB(239,243,247),20,190,)
	oPanel:Align := CONTROL_ALIGN_TOP

	oFont := TFont():New ("Arial", , -12, , .T., , , , , .F., .F. )
	oFontChk := TFont():New ("Tahoma", , -11, , .F., , , , , .F., .F. )

	oSay := TSay():New (005, 0, {|| "Mostrar apenas:" }, oPanel, , oFont, , , , .T., CLR_BLUE, , 100, 10, ,,,,, .T. )
	oSay:lTransparent := .T.

	oChk := TCheckBox():New( 020, 0, "Aberto", {|u| If(PCount()>0,aLMostrar[1]:=u,aLMostrar[1]) }, oPanel, 100,10,,{|| Checkbox_Click() },,/*[ bValid]*/,,,,.T.,"Marque para visualizar os veículos que não ainda chegaram ao ponto de controle",,/*[ bWhen]*/ )
	//	oChk:SetCss(cCSSCheck)

	oChk := TCheckBox():New( 035, 0, "Movimentado", {|u| If(PCount()>0,aLMostrar[2]:=u,aLMostrar[2]) }, oPanel, 100,10,,{|| Checkbox_Click() },,/*[bValid]*/,,,,.T.,"Marque para visualizar os veículos que ainda não tiveram sua entrada registrada no ponto de controle",, /*[ bWhen]*/ )
	//	oChk:SetCss(cCSSCheck)

	oChk := TCheckBox():New( 050, 0, "Em Fila", {|u| If(PCount()>0,aLMostrar[3]:=u,aLMostrar[3]) }, oPanel, 100,10,,{|| Checkbox_Click() },,/*[ bValid]*/,,,,.T.,"Marque para visualizar os veículos que estão no ponto de controle",,/*[ bWhen]*/)
	//	oChk:SetCss(cCSSCheck)

	oChk := TCheckBox():New( 065, 0, "Endereçado", {|u| If(PCount()>0,aLMostrar[4]:=u,aLMostrar[4]) }, oPanel, 100,10,,{|| Checkbox_Click() },,/*[ bValid]*/,,,,.T.,"Marque para visualizar os veículos que estão no ponto de controle",,/*[ bWhen]*/)
	//	oChk:SetCss(cCSSCheck)

	oChk := TCheckBox():New( 080, 0, "Cancelado", {|u| If(PCount()>0,aLMostrar[5]:=u,aLMostrar[5]) }, oPanel, 100,10,,{|| Checkbox_Click() },,/*[ bValid]*/,,,,.T.,"Marque para visualizar os veículos que estão no ponto de controle",,/*[ bWhen]*/)
	//	oChk:SetCss(cCSSCheck)

	oChk := TCheckBox():New( 095, 0, "Concluído", {|u| If(PCount()>0,aLMostrar[6]:=u,aLMostrar[6]) }, oPanel, 100,10,,{|| Checkbox_Click() },,/*[ bValid]*/,,,,.T.,"Marque para visualizar os veículos que estão no ponto de controle",,/*[ bWhen]*/)
	//	oChk:SetCss(cCSSCheck)

	// Botoes Aplicar e Restaurar

	oBtn := TButton():New(110,00, "Aplicar", oPanel, {|| BtnAplicar_Click() }, 22, 10,,/*[oFont]*/,, .T.,,,,/*[bWhen]*/)

	oBtnPadrao := TButton():New(110,25, "Restaurar Padrão", oPanel, {|| BtnRestaurar_Click() }, 50, 10,,/*[oFont]*/,,.T.,,,,/*bWhen*/)
	oBtnPadrao:Disable()

	// ---- Consulta de placas

	oSay := TSay():New (130, 0, {|| "Consultar placa:" },oPanel,,oFont,,,,.T.,CLR_BLUE,,100,10,,,,,,.T.)
	oSay:lTransparent := .T.

	oSay := TSay():New (142, 0, {|| "Placa" },oPanel,,oFontChk,,,,.T.,RGB(0,74,119),RGB(239,243,247),15,10,,,,,,.T.)

	cPlaca 		:= Space(TamSX3('GU8_PLACA')[01])
	cBkpPlaca 		:= Space(TamSX3('GU8_PLACA')[01])
	oGetPl 		:= TGet():New( 140,20,{|u| If( Pcount()>0, cPlaca:= u, cPlaca) },oPanel,90,010,PesqPict('GU8','GU8_PLACA'),,0,,,,,.T.,,,,,,,.F.,.F.,,cPlaca,,,,.T.  )
	oGetPl:bF3 	:= {|oGet| A519SXBPLC(oGet)}
	//	oGet:cF3 	:= "GU8PLC"

	//	@ 140,20 MSGET oGetPl VAR cPlaca F3 "GU8PLC" PICTURE PesqPict('GU8','GU8_PLACA') SIZE 90, 6 OF oPanel PIXEL HASBUTTON

	oBtn := TButton():New(160,00, "Consultar", oPanel, {|| BtnConsultar_Click() }, 28, 10,,/*[oFont]*/,, .T.,,,,/*[bWhen]*/)
	oBtn := TButton():New(160,30, "Limpar", oPanel, {|| BtnLimpar_Click() }, 22, 10,,/*[oFont]*/,, .T.,,,,)

	//Browses
	CursorWait()
	oPnlBrowses:SetUpdatesEnabled( .F.)

	aStru:= MontaStru()

	// Montagem do array de índice para realizar a busca na tabela temporária
	Aadd( aSeek, { Alltrim(aStru[2][1][1]) + "+" + Alltrim(aStru[2][2][1]), ;
	{{"",aStru[2][1][3],aStru[2][1][4],aStru[2][1][5],aStru[2][1][1],},;
	{"",aStru[2][2][3],aStru[2][2][4],aStru[2][2][5],aStru[2][2][1],};
	}, 1} )

	Aadd( aSeek, { Alltrim(aStru[2][1][1]) + "+" + Alltrim(aStru[2][3][1]) + "+" + Alltrim(aStru[2][4][1]), ;
	{{"",aStru[2][1][3],aStru[2][1][4],aStru[2][1][5],aStru[2][1][1],},;
	{"",aStru[2][3][3],aStru[2][3][4],aStru[2][3][5],aStru[2][3][1],},;
	{"",aStru[2][4][3],aStru[2][4][4],aStru[2][4][5],aStru[2][4][1],};
	}, 1} )

	Aadd( aSeek, { Alltrim(aStru[2][1][1]) + "+" + Alltrim(aStru[2][6][1]), ;
	{{"",aStru[2][1][3],aStru[2][1][4],aStru[2][1][5],aStru[2][1][1],},;
	{"",aStru[2][6][3],aStru[2][6][4],aStru[2][6][5],aStru[2][6][1],};
	}, 1} )

	Aadd( aSeek, { Alltrim(aStru[2][1][1]) + "+" + Alltrim(aStru[2][9][1]) + "+" + Alltrim(aStru[2][10][1]), ;
	{{"",aStru[2][1][3],aStru[2][1][4],aStru[2][1][5],aStru[2][1][1],},;
	{"",aStru[2][9][3],aStru[2][9][4],aStru[2][9][5],aStru[2][9][1],},;
	{"",aStru[2][10][3],aStru[2][10][4],aStru[2][10][5],aStru[2][10][1],};
	}, 1} )

	dbSelectArea("GX4")
	GX4->( dbSetOrder(4) )
	oBrwGX4:= FWMBrowse():New()
	oBrwGX4:SetAlias("GX4")
	oBrwGX4:DisableDetails()
	oBrwGX4:SetMenuDef("GFEA519B")
	oBrwGX4:SetDescription("Ponto de Controle")
	oBrwGX4:SetOwner(oPnlPonto)
	oBrwGX4:SetAmbiente(.F.)
	oBrwGX4:SetWalkthru(.F.)
	oBrwGX4:SetProfileID("2")
	oBrwGX4:SetFixedBrowse(.T.)

	oBrwGX4:AddLegend("GX4_SIT=='1'", "BLACK", "Não avaliado", "2") //"Não avaliado"
	oBrwGX4:AddLegend("GX4_SIT=='2'", "GREEN", "Aprovado", "2") 	 //"Aprovado"
	oBrwGX4:AddLegend("GX4_SIT=='3'", "RED"  , "Reprovado", "2") 	 //"Reprovado"

	oBrwGX4:AddLegend("GFEA519BLE(1,(cAliGX3)->GX3_NRMOV,(cAliGX3)->GX3_CDOPER,(cAliGX3)->GX3_SEQ,GX4->GX4_CDPTCT,(cAliGX3)->GX3_FILIAL)", "BLACK" , "Finalizado", "1") //"Finalizado"
	//	oBrwGX4:AddLegend("GFEA519BLE(2,(cAliGX3)->GX3_NRMOV,(cAliGX3)->GX3_CDOPER,(cAliGX3)->GX3_SEQ,GX4->GX4_CDPTCT,(cAliGX3)->GX3_FILIAL)", "BLUE"  , "Ponto de Controle corrente", "1") //"Ponto de Controle corrente"
	//	oBrwGX4:AddLegend("GFEA519BLE(3,(cAliGX3)->GX3_NRMOV,(cAliGX3)->GX3_CDOPER,(cAliGX3)->GX3_SEQ,GX4->GX4_CDPTCT,(cAliGX3)->GX3_FILIAL)", "YELLOW", "Normal", "1") //"Normal"
	//	oBrwGX4:AddLegend("GFEA519BLE(4,(cAliGX3)->GX3_NRMOV,(cAliGX3)->GX3_CDOPER,(cAliGX3)->GX3_SEQ,GX4->GX4_CDPTCT,(cAliGX3)->GX3_FILIAL)", "RED"   , "Aguardando Ocorrência", "1") //"Aguardando Ocorrência"
	oBrwGX4:AddButton("Visualizar", {|| GFEA519BVW() },,2,,.F.)

	If Type("oBrwGX3:bChange") == "B"
		cTmp := GetCbSource(oBrwGX3:bChange)
		cTmp := SubStr(cTmp, 1, Len(cTmp) -1) + ", A519GX3BC() }"
		bChange := &(cTmp)
	Else
		bChange := {|| A519GX3BC() }
	EndIf
	
	aAdd(aFiltro, {"GX3_FILIAL"	, "Filial"		, "C", TamSX3("GX3_FILIAL")[1], TamSX3("GX3_FILIAL")[2],""})
	aAdd(aFiltro, {"GX3_NRMOV"	, "Nr Mov"		, "C", TamSX3("GX3_NRMOV")[1], TamSX3("GX3_NRMOV")[2],"99999999"})
	aAdd(aFiltro, {"GX3_CDOPER"	, "Cod Operação", "C", TamSX3("GX3_CDOPER")[1], TamSX3("GX3_CDOPER")[2],"@!"})
	aAdd(aFiltro, {"GX3_SEQ"	, "Sequencia"   , "C", TamSX3("GX3_SEQ")[1], TamSX3("GX3_SEQ")[2],"999"})
	aAdd(aFiltro, {"GX3_CDEMIT"	, "Cod Emitente", "C", TamSX3("GX3_CDEMIT")[1], TamSX3("GX3_CDEMIT")[2],"@!"})
	aAdd(aFiltro, {"GX3_DTCRIA"	, "Data Criação", "D", TamSX3("GX3_DTCRIA")[1], TamSX3("GX3_DTCRIA")[2],""})
	aAdd(aFiltro, {"GX3_HRCRIA"	, "Hr Criação"  , "C", TamSX3("GX3_HRCRIA")[1], TamSX3("GX3_HRCRIA")[2],"@R 99:99"})

	oBrwGX3:= FWMBrowse():New()
	oBrwGX3:SetTemporary(.T.)
	oBrwGX3:SetAlias(cAliGX3)
	oBrwGX3:SetFields(aStru[2])
	oBrwGX3:SetSeek(.T., aSeek)
	oBrwGX3:DisableDetails()
	oBrwGX3:SetMenuDef("GFEA519")
	oBrwGX3:SetDescription("Movimentações")
	oBrwGX3:SetOwner(oPnlMovim)
	oBrwGX3:SetAmbiente(.F.)
	oBrwGX3:SetWalkthru(.F.)
	oBrwGX3:SetProfileID("1")
	oBrwGX3:AddButton("Sair", {|| oDlg2:End() },,2,,.F.)
	oBrwGX3:AddLegend("(cAliGX3)->GX3_SIT=='1'", "GREEN" , "Aberto")
	oBrwGX3:AddLegend("(cAliGX3)->GX3_SIT=='2'", "BLUE"  , "Movimentado")
	oBrwGX3:AddLegend("(cAliGX3)->GX3_SIT=='3'", "WHITE" , "Em Fila")
	oBrwGX3:AddLegend("(cAliGX3)->GX3_SIT=='4'", "ORANGE", "Endereçado")
	oBrwGX3:AddLegend("(cAliGX3)->GX3_SIT=='5'", "RED"   , "Cancelado")
	oBrwGX3:AddLegend("(cAliGX3)->GX3_SIT=='6'", "BLACK" , "Concluído")
	oBrwGX3:SetFixedBrowse( .T. )
	oBrwGX3:SetUseFilter( .T. )
	oBrwGX3:SetDBFFilter(.T.)
	oBrwGX3:SetFieldFilter(aFiltro)
	
	oBrwGX3:SetChange(bChange)

	Processa({|lEnd| A519ACTBRW()},"Ativando Browses", "Aguarde...")

	If Type("oBrwGX4:bChange") == "B"
		cTmp := GetCbSource(oBrwGX4:bChange)
		cTmp := SubStr(cTmp, 1, Len(cTmp) -1) + ", A519GX4BC() }"
		bChange := &(cTmp)
	Else
		bChange := {|| A519GX4BC() }
	EndIf
	oBrwGX4:SetChange(bChange)
	A519GX3BC()
	oPnlBrowses:SetUpdatesEnabled(.T.)
	oRelacGX4:= FWBrwRelation():New()
	oRelacGX4:AddRelation(oBrwGX3, oBrwGX4, {{'GX4_FILIAL', 'GX3_FILIAL'}, {'GX4_NRMOV', 'GX3_NRMOV'}})
	oRelacGX4:Activate()

	CursorArrow()
Return Nil

///////////////////////////////////////////////
//			Eventos de componentes
///////////////////////////////////////////////

Function A519ACTBRW(lRefresh)
	Default lRefresh := .F.
	If !lRefresh
		ProcRegua(3)
		IncProc("Ativando Pontos de Controle")
		oBrwGX4:Activate()
		oBrwGX4:DelColumn(3)
		oBrwGX4:SetColumnOrder(15,5)
		IncProc("Ativando Pontos de Controle")
		oBrwGX4:UpdateBrowse()

		IncProc("Ativando Movimentação")
		oBrwGX3:Activate()
	Else
		Processa({|lEnd| A519MontaDados(!Empty(cPlaca))},"Carregando informações", "Aguarde...")
		ProcRegua(2)
		IncProc("Ativando Pontos de Controle")
		oBrwGX4:Refresh()
		IncProc("Ativando Movimentação")
		dbSelectArea(cAliGX3)
		(cAliGX3)->(dbSetOrder(1))
		oBrwGX3:Refresh()
		(cAliGX3)->(dbGoBottom())
	EndIf
	If Type("oBrwGX3:bChange") == "B"
		Eval(oBrwGX3:bChange)
	EndIf
Return
Static Function A519SXBPLC(oGet) //Carrega um SXB (consulta) específica
	Local aRet		:= {}
	Local cTitulo	:= ""
	Local lRet		:= .F.
	Local nItem	:= 0
	Local cFiltro := ""
	Local nX
	Local cAliasT := GetNextAlias()
	Local cQuery := ""

	For nX := 1 to Len(aLMostrar)
		If aLMostrar[nX] == .T.
			If !Empty(cFiltro)
				cFiltro += ","
			EndIf
			cFiltro += "'" + cValToChar(nX) + "'"
		EndIf
	Next nX

	cQuery += "SELECT DISTINCT GU8.GU8_PLACA, GU8.GU8_CDVEIC FROM " + RetSqlName("GU8") + " GU8"
	cQuery += "	INNER JOIN " + RetSqlName("GX6") + " GX6"
	cQuery += "		ON GX6.GX6_FILIAL = '" + xFilial("GX6") + "'"
	cQuery += "		AND GX6.GX6_CDVEIC = GU8.GU8_CDVEIC"
	cQuery += "		AND GX6.D_E_L_E_T_ = '' AND GU8.D_E_L_E_T_ = ''"
	cQuery += "	INNER JOIN " + RetSqlName("GX3") + " GX3"
	cQuery += "		ON GX3.GX3_FILIAL = '" + xFilial("GX3") + "'"
	cQuery += "		AND GX3.GX3_NRMOV = GX6.GX6_NRMOV"
	cQuery += "		AND GX3.D_E_L_E_T_ = ''"

	If !Empty(cFiltro)
		cQuery += "		AND GX3.GX3_SIT IN (" + cFiltro + ")"
	EndIf

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,ChangeQuery(cQuery)),cAliasT, .F., .T.)
	cTitulo := "Veículos - Placas"
	(cAliasT)->(dbGoTop())

	While !(cAliasT)->(Eof())
		If !Empty((cAliasT)->GU8_CDVEIC)
			aAdd( aRet, {(cAliasT)->GU8_PLACA,(cAliasT)->GU8_CDVEIC} )
			lRet:= .T.
		EndIf
		(cAliasT)->(dbSkip())
	EndDo

	If lRet
		lRet := .F.
		nItem := TmsF3Array( {"Placa", "Código Veículo"}, aRet, cTitulo )
		If nItem > 0
			lRet := .T.
			cPlaca := UPPER(aRet[nItem][1])
			cBkpPlaca := cPlaca
			oGet:CtrlRefresh()
		Endif
	Else
		MsgInfo("As movimentações atuais não possuem veículos relacionados.","Aviso")
	EndIf
	(cAliasT)->(dbCloseArea())
Return lRet

Static Function A519GX3BC() //Realiza posicionamento do GX3
	dbSelectArea("GX3")
	GX3->(dbSetOrder(1))
	If !Empty((cAliGX3)->GX3_NRMOV)
		GX3->(dbSeek((cAliGX3)->GX3_FILIAL + (cAliGX3)->GX3_NRMOV))
		_cMov     := GX3->GX3_NRMOV
		_cOper    := GX3->GX3_CDOPER
		_cSeq     := GX3->GX3_SEQ
		_cPtCt    := GX4->GX4_CDPTCT
		GFEA519BIN()
		dbSelectArea("GX3")
		dbSelectArea("GX4")
		GX4->( dbSetOrder(4) )
	EndIf
Return
Static Function A519GX4BC() //Realiza posicionamento do GX3
	dbSelectArea("GX3")
	GX3->(dbSetOrder(1))
	If !Empty((cAliGX3)->GX3_NRMOV)
		GX3->(dbSeek((cAliGX3)->GX3_FILIAL + (cAliGX3)->GX3_NRMOV))
		_cMov     := GX3->GX3_NRMOV
		_cOper    := GX3->GX3_CDOPER
		_cSeq     := GX3->GX3_SEQ
		_cPtCt    := GX4->GX4_CDPTCT
		GFEA519BIN()
		dbSelectArea("GX4")
		GX4->( dbSetOrder(4) )
	EndIf
Return

Static Function BtnConsultar_Click()
	BtnAplicar_Click(.T.)
Return Nil

Static Function BtnLimpar_Click()
	cPlaca := Space(TamSX3('GU8_PLACA')[01])
	oGetPl:CtrlRefresh()
	BtnAplicar_Click(.F.)

Return Nil

Static Function Checkbox_Click()
	If	aLMostrar[1] == aLMostrarDefault[1] .AND. ;
	aLMostrar[2] == aLMostrarDefault[2] .AND. ;
	aLMostrar[3] == aLMostrarDefault[3] .AND. ;
	aLMostrar[4] == aLMostrarDefault[4] .AND. ;
	aLMostrar[5] == aLMostrarDefault[5] .AND. ;
	aLMostrar[6] == aLMostrarDefault[6]
		oBtnPadrao:Disable()
	Else
		oBtnPadrao:Enable()
	EndIf
Return Nil

Static Function BtnRestaurar_Click()
	aLMostrar[1] := aLMostrarDefault[1]
	aLMostrar[2] := aLMostrarDefault[2]
	aLMostrar[3] := aLMostrarDefault[3]
	aLMostrar[4] := aLMostrarDefault[4]
	aLMostrar[5] := aLMostrarDefault[5]
	aLMostrar[6] := aLMostrarDefault[6]
	oBtnPadrao:Disable()

	BtnAplicar_Click()
Return Nil

Static Function BtnVeiculo_Click()
	GFEA522()
	A519ACTBRW(.T.)
Return Nil

Static Function BtnAplicar_Click(lPlaca)
	Default lPlaca:= .F.
	If Empty(cBkpPlaca)
		cBkpPlaca := cPlaca
	EndIf

	CursorWait()
	oPnlBrowses:SetUpdatesEnabled(.F.)
	Processa({|lEnd| A519MontaDados(lPlaca)},"Carregando informações", "Aguarde...")
	dbSelectArea(cAliGX3)
	(cAliGX3)->(dbSetOrder(1))
	(cAliGX3)->(dbGoTop())
	oBrwGX3:UpdateBrowse()
	If Type("oBrwGX3:bChange") == "B"
		Eval(oBrwGX3:bChange)
	EndIf
	oPnlBrowses:SetUpdatesEnabled(.T.)
	CursorArrow()
Return Nil

Function A519BtnGX3(cTitulo,nOp,cPrograma)
	Default cPrograma := "GFEA519"

	dbSelectArea("GX3")
	GX3->(dbSetOrder(1))

	If GX3->(dbSeek((cAliGX3)->GX3_FILIAL + (cAliGX3)->GX3_NRMOV))
		FWExecView(cTitulo,cPrograma, nOp,,{||.T.})
	EndIf
Return Nil

////////////////////////////////////////////
//		Funções de dados
////////////////////////////////////////////

Static Function MontaStru(lPlaca)

	Local aStruct  := {}
	Local aTmpStru := {}
	Local nI
	Local aPos     := {;
	{"GX3_FILIAL"	, 1},;
	{"GX3_NRMOV"	, 2},;
	{"GX3_CDOPER" 	, 3},;
	{"GX3_SEQ"   	, 4},;
	{"GU8_PLACAC" 	, 5},;
	{"GX3_CDEMIT"	, 6},;
	{"GU3_NMEMIT"	, 7},;
	{"GX3_SIT2"	, 8},;
	{"GX3_DTCRIA"	, 9},;
	{"GX3_HRCRIA"	, 10}}
	Local aHeader  := Array(Len(aPos))
	Local aCpoAdic := {}
	Local nCont    := 0
	Local nX       := 0
	Local s_GFEA5191 := ExistBlock("GFEA5191")
	Local s_GFEA5192 := ExistBlock("GFEA5192")
	Private cCpoAdic  := ""

	Default lPlaca:= .F.
	dbSelectArea("GX3")
	aTmpStru := GX3->( dbStruct() )

	AAdd(aStruct, {"GX3_SIT", "C", 1, 0})

	/*Ponto de entrada Sementes Goias
	Permite selecionar campos da GX3 que podem ser exibidos na tela além daquele
	já definidos com padrão.
	Também define a oredem dos campos na tela.
	Ticket Zendesk: 873634
	*/
	If s_GFEA5191
		cCpoAdic := ExecBlock("GFEA5191", .F., .F., {})
		If ! EMPTY(cCpoAdic)
			lPE1 := .T.

			aCpoAdic := StrTokArr( cCpoAdic, "|" )
			aAdd(aCpoAlias, aCpoAdic)
			aHeader := Array(Len(aHeader) + Len(aCpoAdic))

			For nX := Len(aPos)  to Len(aHeader) - 1
				nCont++
				aAdd(aPos, {aCpoAdic[nCont], nX + 1})
			Next nX
		EndIf
	EndIF

	AEval(aTmpStru, {|x| IIf(x[1] $ "GX3_FILIAL|GX3_NRMOV|GX3_CDOPER|GX3_SEQ|GX3_CDEMIT|GU3_NMEMIT|GX3_DTCRIA|GX3_HRCRIA|" + cCpoAdic, AAdd(aStruct, x), )})

	dbSelectArea("GU3")
	aTmpStru := GU3->( dbStruct() )

	/*Ponto de entrada Sementes Goias
	Permite selecionar campos da GU3 que podem ser exibidos na tela além daquele
	já definicos com padrão.
	Ticket Zendesk: 873634
	*/
	cCpoAdic := ""
	aCpoAdic := {}
	If s_GFEA5192
		cCpoAdic := ExecBlock("GFEA5192", .F., .F., {})
		If ! EMPTY(cCpoAdic)
			lPE2 := .T.

			aCpoAdic := StrTokArr( cCpoAdic, "|" )
			aAdd(aCpoAlias2, aCpoAdic)
			aHeader := Array(Len(aHeader) + Len(aCpoAdic))

			nCont := 0
			For nX := Len(aPos)  to Len(aHeader) - 1
				nCont++
				aAdd(aPos, {aCpoAdic[nCont], nX + 1})
			Next nX
		EndIf
	EndIF

	AEval(aTmpStru, {|x| IIf(x[1] $ "GX3_FILIAL|GX3_NRMOV|GX3_CDOPER|GX3_SEQ|GX3_CDEMIT|GU3_NMEMIT|GX3_DTCRIA|GX3_HRCRIA|" + cCpoAdic, AAdd(aStruct, x), )})

	AAdd(aStruct, {"GX3_SIT2", "C", 25, 0})
	AAdd(aStruct, {"GU8_PLACAC", "C", 250, 0})
	cAliGX3 := GFECriaTab({aStruct, {"GX3_FILIAL+GX3_NRMOV","GX3_FILIAL+GX3_CDOPER+GX3_SEQ","GX3_FILIAL+GX3_CDEMIT","GX3_FILIAL+DTOS(GX3_DTCRIA)+GX3_HRCRIA"}})

	For nI :=2 To Len(aStruct)

		dbSelectArea("SX3")
		SX3->( dbSetOrder(2) )
		If SX3->( dbSeek(aStruct[nI][1] ) )

			aHeader[aPos[AScan(aPos, {|x| x[1]==aStruct[nI][1]})][2]] := ;
			{;
			X3TITULO(), ; //Título
			aStruct[nI][1], ; // Nome do campo
			aStruct[nI][2], ; // Tipo
			aStruct[nI][3], ; // Tamanho
			aStruct[nI][4], ; // Decimal
			X3PICTURE() ;     // Picture
			}
		ElseIf aStruct[nI][1]=="GX3_SIT2"
			aHeader[aPos[AScan(aPos, {|x| x[1]==aStruct[nI][1]})][2]] := ;
			{;
			"Situação", ; //Título
			"GX3_SIT2", ; // Nome do campo
			"C", ; // Tipo
			10, ; // Tamanho
			0, ; // Decimal
			"@!";     // Picture
			}
		ElseIf aStruct[nI][1]=="GU8_PLACAC"
			aHeader[aPos[AScan(aPos, {|x| x[1]==aStruct[nI][1]})][2]] := ;
			{;
			"Placas", ; //Título
			"GU8_PLACAC", ; // Nome do campo
			"C", ; // Tipo
			10, ; // Tamanho
			0, ; // Decimal
			"@!";     // Picture
			}
		EndIf

	Next nI
	dbSelectArea(cAliGX3)
	dbSetOrder(01)
	dbGoTop()
	Processa({|lEnd| A519MontaDados(lPlaca)},"Carregando informações", "Aguarde...")
Return {aStruct,aHeader}

Function A519MontaDados(lPlaca)
	Local lInclui := .F.
	Local cFiltrPlac := cBkpPlaca
	Local cPlaca  := Space(TamSX3('GU8_PLACA')[01])
	Local nY
	Local cCampo := ""
	Local cTab   := ""
	Local aFilPerm	:= FWUsrEmp(__cUserID) // Lista as filiais que o usuário tem permissão.
	Local cGrpCompany := FWGrpCompany()
	Local s_GFEA5191 := ExistBlock("GFEA5191")
	Local s_GFEA5192 := ExistBlock("GFEA5192")
	Local cAliasGX3 := GetNextAlias()
	Local cQuery := ""
	Local cFiltro := ''
	Local cNrsMovs := ''
	Local nH
	Local lFiltro := .F.
	Local aMovimenta := {}
	Local nJ
	Local cAliasGX6 := GetNextAlias()
	Private cTemp := ""
	Default lPlaca:= .F.
	dbSelectArea(cAliGX3)
	ZAP
	ProcRegua(3)
	IncProc("Buscando Informações")

	If lPlaca .And. !Empty(cFiltrPlac)

		cQuery := " SELECT * FROM "+ RetSQLName("GX6") +" GX6 "
		cQuery += " WHERE GX6.GX6_CDVEIC = '" + cFiltrPlac + "'"
		cQuery += " AND GX6.D_E_L_E_T_ = ' ' "

		dbUseArea( .T., "TOPCONN", TCGENQRY(,,ChangeQuery(cQuery)),cAliasGX6, .F., .T.)

		GX6->(dbSetOrder(2))
		While (cAliasGX6)->( !Eof() )
			If GX6->(dbSeek((cAliasGX6)->GX6_FILIAL + (cAliasGX6)->GX6_CDVEIC))
				aAdd(aMovimenta,{(cAliasGX6)->GX6_NRMOV})
				lFiltro := .T.
			EndIf
			(cAliasGX6)->(dbSkip())
		EndDo
		(cAliasGX6)->(dbCloseArea())
	EndIf

	cAliasGX3 := GetNextAlias()
	cQuery := " SELECT * FROM "+RetSQLName("GX3")+" GX3 "
	cQuery += " WHERE GX3.D_E_L_E_T_ = ' ' "

	For nH := 1 to Len(aLMostrar)
		If aLMostrar[nH] == .T.
			If !Empty(cFiltro)
				cFiltro += ","
			EndIf
			cFiltro += "'" + cValToChar(nH) + "'"
		EndIf
	Next nH

	If !Empty(cFiltro)
		cQuery += "		AND GX3.GX3_SIT IN (" + cFiltro + ")"
	EndIf

	If lFiltro
		For nJ := 1 to Len(aMovimenta)
			If !Empty(cNrsMovs)
				cNrsMovs += ","
			EndIf
			cNrsMovs += "'" + aMovimenta[nJ][1] + "'"
		Next nJ
		cQuery += "		AND GX3.GX3_NRMOV IN (" + cNrsMovs + ")"
	EndIf

	cQuery += " ORDER BY GX3.GX3_FILIAL, R_E_C_N_O_  "

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,ChangeQuery(cQuery)),cAliasGX3, .F., .T.)

	(cAliasGX3)->(dbGoTop())

	IncProc("Processando Movimentações")
	While (cAliasGX3)->( !Eof() )
		If Empty((cAliasGX3)->GX3_FILIAL) .OR.;															// Se Filial em Branco, lista
		ASCAN(aFilPerm,{|X| Alltrim(X) == Alltrim(cGrpCompany+(cAliasGX3)->GX3_FILIAL)}) > 0 .OR. ;	// se tem permissão da filial, lista
		AScan(aFilPerm,"@@@@") > 0															// se tem permissão para todas as filiais, lista

			cTemp := ""

			GX6->(dbSetOrder(1))
			GX6->(dbSeek((cAliasGX3)->GX3_FILIAL + (cAliasGX3)->GX3_NRMOV)) // Vasculha Placas
			While !GX6->(Eof()) .And. (cAliasGX3)->GX3_FILIAL + (cAliasGX3)->GX3_NRMOV == GX6->GX6_FILIAL + GX6->GX6_NRMOV;
			.And. Len(cTemp) + 9 < 250 // para não ultrapassar o limite de dados de placa
				cPlaca := Posicione('GU8',1,xFilial('GU8') + GX6->GX6_CDVEIC ,'GU8_PLACA')
				If !Empty(cTemp)
					cTemp += ";"
				EndIF
				cTemp += Transform(cPlaca, PesqPict('GU8','GU8_PLACA'))
				GX6->(dbSkip())
			EndDo

			RecLock(cAliGX3,.T.)
			lInclui :=.T.
			(cAliGX3)->GX3_SIT 		:= (cAliasGX3)->GX3_SIT
			(cAliGX3)->GX3_FILIAL 	:= (cAliasGX3)->GX3_FILIAL
			(cAliGX3)->GX3_NRMOV 	:= (cAliasGX3)->GX3_NRMOV
			(cAliGX3)->GX3_CDOPER 	:= (cAliasGX3)->GX3_CDOPER
			(cAliGX3)->GX3_SEQ 		:= (cAliasGX3)->GX3_SEQ

			(cAliGX3)->GU8_PLACAC	:= cTemp
			(cAliGX3)->GX3_CDEMIT 	:= (cAliasGX3)->GX3_CDEMIT
			(cAliGX3)->GU3_NMEMIT 	:= Posicione('GU3',1,xFilial('GU3') + (cAliasGX3)->GX3_CDEMIT ,'GU3_NMEMIT')
			(cAliGX3)->GX3_SIT2		:= GetStrCbox(GetSx3Inf("GX3_SIT")[2],(cAliasGX3)->GX3_SIT)
			(cAliGX3)->GX3_DTCRIA	:= STOD((cAliasGX3)->GX3_DTCRIA)
			(cAliGX3)->GX3_HRCRIA	:= (cAliasGX3)->GX3_HRCRIA

			/*Ponto de entrada Sementes Goias
			Permite selecionar campos da GU3 que podem ser exibidos na tela além daquele
			já definicos com padrão.
			Ticket Zendesk: 873634
			*/
			If s_GFEA5191 .AND. lPE1
				For nY := 1 To Len(aCpoAlias[1])
					cCampo := aCpoAlias[1][nY]
					cTab   := SUBSTR(cCampo,1,3)
					If ValType((cAliGX3)->&cCampo) == "D"
						(cAliGX3)->&cCampo := STod((cAliasGX3)->&cCampo)
					Else
						(cAliGX3)->&cCampo := (cAliasGX3)->&cCampo
					EndIf
				Next nY
			EndIf
			If s_GFEA5192 .AND. lPE2
				For nY := 1 To Len(aCpoAlias2[1])
					cCampo := aCpoAlias2[1][nY]
					(cAliGX3)->&cCampo := Posicione('GU3',1,xFilial('GU3') + (cAliasGX3)->GX3_CDEMIT , cCampo)
				Next nY
			EndIf
			msUnlock(cAliGX3)
		EndIf
		(cAliasGX3)->(dbSkip())

		cFiltrPlac := ""
		cBkpPlaca  := ""
		aMovimenta := {}

	EndDo
	(cAliasGX3)->(dbCloseArea())
	IncProc("Processando Pontos de Controle")
Return Nil

Static Function GetFiltro(lPlaca)
	Local nX
	Local cFiltro := ''
	Default lPlaca:= .F.

	For nX := 1 to Len(aLMostrar)
		If aLMostrar[nX] == .T.
			cFiltro += cValToChar(nX)
		EndIf
	Next nX

	If !Empty(cFiltro)
		cFiltro := "GX3->GX3_SIT $'" + cFiltro +"'"
		If lPlaca .And. !Empty(cPlaca)
			cFiltro += " .And. "
		EndIf
	EndIf

	If lPlaca	.And. !Empty(cPlaca)
		cFiltro += "'" + AllTrim(StrTran(UPPER(cPlaca),'-','')) + "' $ AllTrim(StrTran(cTemp,'-',''))"
	EndIf

Return cFiltro

/*/{Protheus.doc} GetStrCbox

@author siegklenes.beulke
@since 16/07/2013
@version 1.0

@param cBox, character, Caracter Representando X3Cbox
@param cVal, character, Valor de pesquisa

@description

Retorna o valor do combo dado o valor da sequencia

@example

GetStrCbox("1=Sim;2=Nao","1") // retorna "Sim"

@return cRet Valor Buscado
/*/

Static Function GetStrCbox(cBox,cVal)
	Local aArr := STRTOKARR(cBox,";")
	Local aArr2 := {}
	Local nCont,nPos,cRet:=""
	For nCont :=1 to Len(aArr)
		aAdd(aArr2,STRTOKARR(aArr[ncont],"="))
	Next nCont
	If Len(aArr2) > 0
		nPos := aScan(aArr2,{|x|x[1]==cVal})
		If nPos > 0
			cRet := aArr2[nPos][2]
		EndIf
	EndIf
Return cRet

/*/{Protheus.doc} GetSx3Inf

@author siegklenes.beulke
@since 16/07/2013
@version 1.0

@param cCampo, character, Campo  do Banco de dados
@param aRetorno, array, Opcional, Informações de Retorno caso não encontre o Campo

@description

Função que busca no sx3 as informações de titulo,cbox,picture e descrição do campo
e retorna um array nessa ordem, ou caso não encontre o campo, retorna o segundo parametro

@example

GetSx3Inf("GW1_FILIAL") Retorno {"Filial","","@!","Filial"}
GetSx3Inf("GW1_FILI",{"Fila","1=Sim;2=Nao","","Fila de espera"})Retorno {"Fila","1=Sim;2=Nao","","Fila de espera"}

@return aArray:={X3Titulo, X3Cbox,X3Picture,X3DESCRIC}
/*/

Static Function GetSx3Inf(cCampo,aRetorno)
	Local nCont := 1
	Local aArea := GetArea("SX3")
	Default aRetorno := {"","","",""}
	For nCont := 1 to 4-Len(aRetorno)
		aAdd(aRetorno,"")
	Next
	dbSelectArea("SX3")
	dbSetOrder(2)
	If dbSeek( cCampo )
		aRetorno[1] := X3Titulo()
		aRetorno[2] := X3Cbox()
		aRetorno[3] := X3Picture()
		aRetorno[4] := X3DESCRIC()
	EndIf
	RestArea(aArea)
Return aRetorno

Function GFEA519VLD()

	Private aOper   := {"",""}
	Private cAliMKB

	Private aMKB    := {{"OK", "C", 02, 0}}
	Private aCpMKB
	Private cMarca  := GetMark()
	Private aPontosUsu := GFEA519PTOUSU()

	If !GFEA510COMP()
		MsgStop( "Necessário aplicar o update U_GFE11I20 para utilizar o processo de pátios e portarias." )
		Return .F.
	EndIf

	GFEA519VTA()

	GFEA519INI()
Return .T.

//---------------------------------------------------

Function GFEA519PTOUSU()
	Local aPontos := {}

	// GVF	- Pontos de Controle
	dbSelectArea("GVF")
	GVF->( dbSetOrder(1) )
	If GVF->( dbSeek(xFilial("GVF")) )

		While !GVF->( Eof() )	.And. GVF->GVF_FILIAL == xFilial("GVF")

			dbSelectArea("GVP")
			GVP->( dbSetOrder(1) )
			GVP->( dbSeek(xFilial("GVP") + s_RetCodUsr) )
			While !GVP->( Eof() ) .And. GVP->GVP_CDUSUR == s_RetCodUsr .And. GVP->GVP_FILIAL == xFilial("GVP")

				If GVP->GVP_CDPTCT == GVF->GVF_CDPTCT
					aAdd(aPontos, GVF->GVF_CDPTCT)
					Exit
				EndIf

				dbSelectArea("GVP")
				GVP->( dbSkip() )
			EndDo

			GVF->( dbSkip() )
		EndDo
	EndIf

Return aPontos

//---------------------------------------------------

Function GFEA519INI()
	Local oStructGWV := FwFormStruct(1,"GWV")
	Local aStruct    := oStructGWV:GetFields()
	Local nCont
	Local lOk        := .F.
	Local lFound     := .F.

	dbSelectArea("GVJ")
	GVJ->( dbSetOrder(2) )

	//
	// Se for o primeiro ponto de controle da conf operação, verifica se tem agendamentos
	//
	If GVJ->( dbSeek( xFilial("GVJ") + "001" ) )

		For nCont := 1 To Len(aStruct)

			AAdd(aMKB,{aStruct[nCont][3],aStruct[nCont][4],aStruct[nCont][5],aStruct[nCont][6]})

			If aStruct[nCont][3] == "GWV_CDEMIT"
				AAdd(aMKB,{"GWV_DSEMIT","C",50,0})
			EndIf

		Next nCont

		AAdd(aMKB,{"GWV_SEQOP","C",TamSX3("GVJ_SEQ")[1],0})

		aCpMKB := {{"OK"        , NIL, "", ""}, ;
		{"GWV_NRAGEN", NIL, STR0013, "99999999"}, ; //"Agendamento"
		{"GWV_CDOPER", NIL, STR0077, "@! XXXXXXXXXXXXXXXX"}, ; //"Operação"
		{"GWV_SEQOP" , NIL, "Seq", "999"}, ;
		{"GWV_CDEMIT", NIL, STR0072, Replicate("9",TamSX3("GWV_CDEMIT")[1])}, ; //"Emitente"
		{"GWV_DSEMIT", NIL, STR0078, ""}, ; //"Ds Emitente"
		{"GWV_DTAGEN", NIL, STR0014, "99/99/9999"}, ; //"Dt Agendamento"
		{"GWV_HRAGEN", NIL, STR0015, "99:99"}, ; //"Hr Agendamento"
		{"GWV_DTCRIA", NIL, STR0016, "99/99/9999"}, ; //"Dt Criação"
		{"GWV_HRCRIA", NIL, STR0017, "99:99"}} //"Hr Criação"

		cAliMKB := GFECriaTab({aMKB,{"GWV_NRAGEN","GWV_CDOPER"}})

		While !GVJ->( Eof() ) .And. GVJ->GVJ_FILIAL == xFilial("GVJ") .And. GVJ->GVJ_ORDEM == "001"

			dbSelectArea(cAliMKB)
			(cAliMKB)->( dbSetOrder(2) )
			If !(cAliMKB)->( dbSeek(GVJ->GVJ_CDOPER) )

				dbSelectArea("GWV")
				GWV->( dbSetOrder(2) )
				GWV->( dbSeek(xFilial("GWV") + GVJ->GVJ_CDOPER) )
				While !GWV->( Eof() ) .And. GWV->GWV_FILIAL == xFilial("GWV") .And. GWV->GWV_CDOPER == GVJ->GVJ_CDOPER

					If aScan(aPontosUsu,{|x| x == GVJ->GVJ_CDPTCT}) != 0
						If GWV->GWV_SIT == "1"

							lFound := .T.

							RecLock((cAliMKB), .T.)
							For nCont := 1 To Len(aStruct)
								If !aStruct[nCont][14]
									If aStruct[nCont][3] == "GWV_HRAGEN"
										(cAliMKB)->GWV_HRAGEN := Stuff(GWV->GWV_HRAGEN,3,0,":")
									Else
										&("(cAliMKB)->" + aStruct[nCont][3] + " := " + "GWV->" + aStruct[nCont][3])
									EndIf
								EndIf
							Next nCont

							(cAliMKB)->GWV_DSEMIT := POSICIONE("GU3",1,xFilial("GU3")+GWV->GWV_CDEMIT,"GU3_NMEMIT")
							(cAliMKB)->GWV_SEQOP  := GWV->GWV_SEQ

							MsUnlock((cAliMKB))
						EndIf
					EndIf
					dbSelectArea("GWV")
					GWV->( dbSkip() )
				EndDo

			EndIf
			dbSelectArea("GVJ")
			GVJ->( dbSkip() )
		EndDo

		(cAliMKB)->( dbSetOrder(1) )

	EndIf

	//---------------------------------------

	If lFound

		cOpAgen := cAliMKB

		(cAliMKB)->( dbGoTop() )

		oDlg2 := MSDialog():New(10, 10, 390, 800, STR0079,,,,,CLR_BLACK,CLR_WHITE,,,.T.) //"Agendamentos: "

		oMark := MsSelect():New(cAliMKB,"OK",,aCpMKB,,@cMarca,{0,0,0,0},,,oDlg2)
		oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		oMark:oBrowse:bLDblClick := {|| GFEA519CHK()}
		oMark:oBrowse:Refresh()

		oPanel := tPanel():New(0,0,,oDlg2,,,,,,31,15,.F.,.F.)
		oPanel:Align := CONTROL_ALIGN_BOTTOM

		oBtn := tButton():New(3,310,"Ok",oPanel,{||If(GFEA519VLS(),Eval({|| lOk:=.T., oDlg2:End()}), Nil)},40,10,,,,.T.) //"Selecione pelo menos um agendamento."
		oBtn := tButton():New(3,355,STR0002,oPanel,{|| oDlg2:End()},40,10,,,,.T.) //"Cancelar"

		oDlg2:Activate()

		If lOk
			FWExecView(STR0008,"GFEA519",MODEL_OPERATION_INSERT,,{|| .T.},,,,{|| .T.}) //"Incluir"
			//		GFEA519A(cPtCt)
		Else
			GFEDelTab(cOpAgen)
			cOpAgen := ""
			//		GFEA519A(cPtCt)
		EndIf

	Else
		If !Empty(cAliMKB)
			GFEDelTab(cAliMKB)
		EndIf
		//	GFEA519A(cPtCt)
	EndIf

Return

//----------------------------------------------------

Static Function GFEA519VLS()
	Local lVld := .F.
	Local cOper := ""

	dbSelectArea(cOpAgen)
	(cOpAgen)->( dbSetOrder(1) )
	(cOpAgen)->( dbGoTop() )
	While !(cOpAgen)->( Eof() )

		If IsMark("OK",cMarca)
			lVld := .T.
			If Empty(cOper)
				cOper := (cOpAgen)->GWV_CDOPER + (cOpAgen)->GWV_SEQOP
			Else
				If cOper != (cOpAgen)->GWV_CDOPER + (cOpAgen)->GWV_SEQOP
					MsgInfo(STR0081) //"Selecione Agendamentos com a mesma 'Operação'."
					(cOpAgen)->( dbGoTop() )
					Return .F.
				EndIf
			EndIf
		EndIf

		dbSelectArea(cOpAgen)
		(cOpAgen)->( dbSkip() )
	EndDo

	(cOpAgen)->( dbGoTop() )

	If !lVld
		MsgInfo(STR0080)
		Return .F.
	EndIf

Return .T.

//----------------------------------------------------

Function GFEA519CHK()

	RecLock(cAliMKB,.F.)
	(cAliMKB)->OK := If(IsMark("OK",cMarca), " ", cMarca)
	MsUnlock(cAliMKB)

Return

//----------------------------------------------------

/*Function GFEA519A(cPar)
Private cPtCtr := cPar

//-------------------------

//Browse Movimentação
oBrowse := FWMBrowse():New()
oBrowse:SetOwner(oPnTop)
oBrowse:SetAlias("GX3")			// Alias da tabela utilizada
oBrowse:SetMenuDef("GFEA519")	// Nome do fonte onde esta a função MenuDef
oBrowse:SetDescription("Movimentações em: " + cPtCtr) //"Registro de Movimentação"
//oBrowse:DisableDetails()
oBrowse:SetAmbiente(.F.)
oBrowse:SetWalkthru(.F.)
oBrowse:SetFixedBrowse(.T.)

oBrowse:AddLegend("GX3_SIT=='1'", "GREEN" , STR0047) //"Aberto"
oBrowse:AddLegend("GX3_SIT=='2'", "BLUE"  , STR0048) //"Movimentado"
oBrowse:AddLegend("GX3_SIT=='3'", "WHITE" , STR0049) //"Em Fila"
oBrowse:AddLegend("GX3_SIT=='4'", "ORANGE", STR0050) //"Endereçado"
oBrowse:AddLegend("GX3_SIT=='5'", "RED"   , STR0051) //"Cancelado"
oBrowse:AddLegend("GX3_SIT=='6'", "BLACK" , STR0052) //"Concluído"

oBrowse:Activate()
Return Nil*/

//-----------------------------------------------------

Static Function MenuDef()
	Local aRotina := {}

	Local s_GFEA5194:= ExistBlock("GFEA5194")
	//-------------------------------------------------------
	// Adiciona botões do browse
	//-------------------------------------------------------
	ADD OPTION aRotina TITLE STR0007 	ACTION "VIEWDEF.GFEA519" 	OPERATION 2  ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0008 	ACTION "VIEWDEF.GFEA519" 	OPERATION 3  ACCESS 0 //"Incluir"
	ADD OPTION aRotina TITLE STR0009 	ACTION "VIEWDEF.GFEA519" 	OPERATION 4  ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0011 	ACTION "VIEWDEF.GFEA519" 	OPERATION 5  ACCESS 0 //"Excluir"
	ADD OPTION aRotina TITLE STR0012 	ACTION "VIEWDEF.GFEA519" 	OPERATION 8  ACCESS 0 //"Imprimir"
	ADD OPTION aRotina TITLE STR0039 	ACTION "GFEA519CAN()"    	OPERATION 12 ACCESS 0 //"Cancelar"
	ADD OPTION aRotina TITLE "Reabrir" ACTION "GFEA519REA()"  	 	OPERATION 13 ACCESS 0 //"Reabre "

	If s_GFEA5194
		aRotAdic := ExecBlock("GFEA5194 ",.f.,.f.)
		If ValType(aRotAdic) == "A"
			AEval(aRotAdic, {|x| AAdd(aRotina ,x)})
		EndIf
	EndIf

	ADD OPTION aRotina TITLE STR0041 	ACTION "GFEA519RES()"    	OPERATION 11 ACCESS 0 //"Resumo Movimentação"

Return aRotina

//-------------------------------------------------------------------

Static Function ModelDef()
	Local oModel
	Local oStructGX3 := FWFormStruct(1,"GX3")
	Local oStructGWV := FWFormStruct(1,"GWV")
	Local oStructGX6 := FWFormStruct(1,"GX6")
	Local oStructGX8 := FWFormStruct(1,"GX8")
	Local oStructGX7 := FWFormStruct(1,"GX7")
	Local oStructGX9 := FWFormStruct(1,"GX9")
	Local nCont

	For nCont := 1 To Len(oStructGWV:aFields)
		oStructGWV:SetProperty(oStructGWV:aFields[nCont][3],MODEL_FIELD_INIT,{|a,b,c| FWInitCpo(a,b,c),lRetorno:= "",FWCloseCpo(a,b,c,.t.),lRetorno})
		oStructGWV:SetProperty(oStructGWV:aFields[nCont][3],MODEL_FIELD_VALID,{|A,B,C,D| FWINITCPO(A,B,C), LRETORNO := (.T.),FWCLOSECPO(A,B,C,LRETORNO),LRETORNO})
		oStructGWV:SetProperty(oStructGWV:aFields[nCont][3],MODEL_FIELD_OBRIGAT,.F.)
	Next nCont

	oStructGWV:AddTrigger("GWV_NRAGEN","GWV_NRMOV",{|| .T.},{|| GFEA519TGR()})

	oModel := MPFormModel():New("GFEA519", /*bPre*/, {|oModel| GFEA519POS(oModel)}, {|oModel| GFEA519CMT(oModel)}, /*bCancel*/)

	oModel:SetVldActivate({|oMod| GFEA519VLM(oMod)})

	oModel:AddFields("GFEA519_GX3", Nil, oStructGX3,/*bPre*/,,/*bLoad*/)
	oModel:SetPrimaryKey({"GX3_FILIAL", "GX3_NRMOV"})

	oModel:AddGrid("GFEA519_GWV","GFEA519_GX3",oStructGWV,{|oMod,nLinha,cOp| GFEA519PRE(oMod,nLinha,cOp)},{|oModel| GFEA519GWV(oModel)},/*bLinePost*/,/*bPre*/,/*bLoad*/)
	oModel:SetRelation("GFEA519_GWV",{{"GWV_FILIAL",'xFilial("GWV")'},{"GWV_NRMOV","GX3_NRMOV"}},"GWV_FILIAL+GWV_NRMOV")
	oModel:GetModel("GFEA519_GWV"):SetDelAllLine(.T.)
	oModel:GetModel("GFEA519_GWV"):SetOptional(.T.)
	oModel:GetModel("GFEA519_GWV"):SetOnlyQuery(.T.)

	oModel:AddGrid("GFEA519_GX6","GFEA519_GX3",oStructGX6,/*bLinePre*/,{|oModel| GFEA519GX6(oModel)},,/*bPre*/,,/*bLoad*/)
	oModel:SetRelation("GFEA519_GX6",{{"GX6_FILIAL",'xFilial("GX6")'},{"GX6_NRMOV","GX3_NRMOV"}},"GX6_FILIAL+GX6_NRMOV")
	//oModel:GetModel("GFEA519_GX6"):SetDelAllLine(.t.)
	oModel:GetModel("GFEA519_GX6"):SetOptional(.T.)

	oModel:AddGrid("GFEA519_GX8","GFEA519_GX3",oStructGX8,/*bLinePre*/,{|oModel| GFEA519GX8(oModel)},/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetRelation("GFEA519_GX8",{{"GX8_FILIAL",'xFilial("GX8")'},{"GX8_NRMOV","GX3_NRMOV"}},"GX8_FILIAL+GX8_NRMOV")
	//oModel:GetModel("GFEA519_GX8"):SetDelAllLine(.t.)
	oModel:GetModel("GFEA519_GX8"):SetOptional(.T.)

	oModel:AddGrid("GFEA519_GX7","GFEA519_GX3",oStructGX7,/*bLinePre*/,{|oModel| GFEA519GX7(oModel)},/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetRelation("GFEA519_GX7",{{"GX7_FILIAL",'xFilial("GX7")'},{"GX7_NRMOV","GX3_NRMOV"}},"GX7_FILIAL+GX7_NRMOV")
	//oModel:GetModel("GFEA519_GX7"):SetDelAllLine(.t.)
	oModel:GetModel("GFEA519_GX7"):SetOptional(.T.)

	oModel:AddGrid("GFEA519_GX9","GFEA519_GX3",oStructGX9,/*bLinePre*/,{|oModel| GFEA519GX9(oModel)},/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetRelation("GFEA519_GX9",{{"GX9_FILIAL",'xFilial("GX9")'},{"GX9_NRMOV","GX3_NRMOV"}},"GX9_FILIAL+GX9_NRMOV")
	oModel:GetModel("GFEA519_GX9"):SetOptional(.T.)

	oModel:SetActivate({|oMod| GFEA519ACT(oMod)})
Return oModel

//-------------------------------------------------------------------

Static Function ViewDef()
	Local oModel := FWLoadModel("GFEA519")
	Local oView  := Nil
	Local oStructGX3 := FWFormStruct(2,"GX3")
	Local oStructGWV := FWFormStruct(2,"GWV")
	Local oStructGX6 := FWFormStruct(2,"GX6")
	Local oStructGX8 := FWFormStruct(2,"GX8")
	Local oStructGX7 := FWFormStruct(2,"GX7")
	Local oStructGX9 := FWFormStruct(2,"GX9")

	oStructGX6:RemoveField( "GX6_NRMOV" )
	oStructGX7:RemoveField( "GX7_NRMOV" )
	oStructGX8:RemoveField( "GX8_NRMOV" )
	oStructGX9:RemoveField( "GX9_NRMOV" )

	oStructGWV:RemoveField( "GWV_CDOPER" )
	oStructGWV:RemoveField( "GWV_CDEMIT" )
	oStructGWV:RemoveField( "GWV_NMEMIT" )
	oStructGWV:RemoveField( "GWV_TPEMIT" )
	oStructGWV:RemoveField( "GWV_DSOPER" )
	oStructGWV:RemoveField( "GWV_USUCRI" )
	oStructGWV:RemoveField( "GWV_SIT"    )
	oStructGWV:RemoveField( "GWV_IDTIPO" )
	oStructGWV:RemoveField( "GWV_SENHA"  )
	oStructGWV:RemoveField( "GWV_IDENVI" )
	oStructGWV:RemoveField( "GWV_HRENVI" )
	oStructGWV:RemoveField( "GWV_DTENVI" )
	oStructGWV:RemoveField( "GWV_IDCONF" )
	oStructGWV:RemoveField( "GWV_DTCONF" )
	oStructGWV:RemoveField( "GWV_HRCONF" )
	oStructGWV:RemoveField( "GWV_USUCAN" )
	oStructGWV:RemoveField( "GWV_MOTCAN" )
	oStructGWV:RemoveField( "GWV_NRMOV"  )
	oStructGWV:RemoveField( "GWV_SEQ" )
	oStructGWV:RemoveField( "GWV_DSCONF" )

	oStructGWV:SetProperty("*",MVC_VIEW_CANCHANGE,.F.)

	oStructGWV:SetProperty("GWV_NRAGEN",MVC_VIEW_LOOKUP,"GWVABR")
	oStructGWV:SetProperty("GWV_NRAGEN",MVC_VIEW_CANCHANGE,.T.)

	oView := FWFormView():New()
	// Objeto do model a se associar a view.
	oView:SetModel(oModel)
	// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
	// oStruct - Objeto do model a se associar a view.
	// cLinkID - Representa o ID criado no Model ,Só é necessári o caso estamos mundando o ID no View.
	oView:AddField( "GFEA519_GX3" , oStructGX3 )
	oView:AddGrid(  "GFEA519_GWV" , oStructGWV )
	oView:AddGrid(  "GFEA519_GX6" , oStructGX6 )
	oView:AddGrid(  "GFEA519_GX8" , oStructGX8 )
	oView:AddGrid(  "GFEA519_GX7" , oStructGX7 )
	oView:AddGrid(  "GFEA519_GX9" , oStructGX9 )

	// cID		  	Id do Box a ser utilizado
	// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. é a qtd de pixel exato)
	// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas criações uma dentro da outra.
	// lFixPixel	Determina que o valor passado no nPercHeight é na verdade a qtd de pixel a ser usada.
	// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, é necessário informar o cIDSheet
	// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
	oView:CreateHorizontalBox( "MASTER" , 50, /*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/,/*cIDSheet*/ )
	oView:CreateHorizontalBox( "DETAIL" , 50 )

	oView:CreateFolder("IDFOLDER","DETAIL")
	oView:AddSheet("IDFOLDER","IDSHEET01",STR0013) //"Agendamento"
	oView:AddSheet("IDFOLDER","IDSHEET02",STR0018) //"Veículos"
	oView:AddSheet("IDFOLDER","IDSHEET03",STR0019) //"Motoristas"
	oView:AddSheet("IDFOLDER","IDSHEET04",STR0020) //"Visitantes"
	oView:AddSheet("IDFOLDER","IDSHEET05","Unitizadores")

	oView:CreateHorizontalBox( "DETAILAG"  , 100,,,"IDFOLDER","IDSHEET01" )
	oView:CreateHorizontalBox( "DETAILVE"  , 100,,,"IDFOLDER","IDSHEET02" )
	oView:CreateHorizontalBox( "DETAILMO"  , 100,,,"IDFOLDER","IDSHEET03" )
	oView:CreateHorizontalBox( "DETAILVI"  , 100,,,"IDFOLDER","IDSHEET04" )
	oView:CreateHorizontalBox( "DETAILUN"  , 100,,,"IDFOLDER","IDSHEET05" )

	// Associa um View a um box
	oView:SetOwnerView( "GFEA519_GX3" , "MASTER"   )
	oView:SetOwnerView( "GFEA519_GWV" , "DETAILAG" )
	oView:SetOwnerView( "GFEA519_GX6" , "DETAILVE" )
	oView:SetOwnerView( "GFEA519_GX8" , "DETAILMO" )
	oView:SetOwnerView( "GFEA519_GX7" , "DETAILVI" )
	oView:SetOwnerView( "GFEA519_GX9" , "DETAILUN" )

	//oView:SetCloseOnOk({|oView| GFEA519AOK(oModel,oView)})

Return oView

//------------------------------------------------------------

Function GFEA519SEQ()
	dbSelectArea("GVI")
	dbSetOrder(1)
	If !dbSeek(xFilial("GVI")+FwFldGet("GX3_CDOPER")+FwFldGet("GX3_SEQ"))
		Help( ,, 'HELP',, "Configuração não cadastrada para a operação.", 1, 0)
		Return .F.
	EndIf
Return .T.

//-----------------------------------------------------------

Function GFEA519GX6(oModelGX6)
	Local oModel    := oModelGX6:GetModel()
	Local oModelGWV := oModel:GetModel("GFEA519_GWV")
	Local nLineGWV  := oModelGWV:GetLine()
	Local nLineGX6  := oModelGX6:GetLine()
	Local aAreaGX6  := GX6->(GetArea())
	Local aAreaGX3  := GX3->(GetArea())
	Local aAreaGU8  := GU8->(GetArea())
	Local aTpVeic := {}
	Local nCont     := 1
	Local cQuery    := ""
	Local cAliasGX3 := GetNextAlias()

	dbSelectArea("GU8")
	dbSetOrder(1)
	If dbSeek(xFilial("GU8")+FwFldGet("GX6_CDVEIC"))
		If GU8->GU8_SIT == "2"
			Help( ,, 'HELP',, "Situação do veículo está como inativo, não pode ser utilizado.", 1, 0)
			RestArea(aAreaGU8)
			RestArea(aAreaGX3)
			RestArea(aAreaGX6)
			Return .F.
		EndIf
	EndIf

	cQuery := "SELECT GX3_NRMOV"
	cQuery +=  " FROM "+RetSqlName('GX3')+" GX3,"
	cQuery +=           RetSqlName('GX6')+" GX6"
	cQuery += " WHERE GX3_FILIAL = '"+xFilial('GX3')+"'"
	cQuery +=   " AND GX3_SIT IN ('1','2','3','4')"
	cQuery +=   " AND GX3.D_E_L_E_T_ = ' '"
	cQuery +=   " AND GX6_FILIAL = '"+xFilial('GX6')+"'"
	cQuery +=   " AND GX6_CDVEIC = '"+FwFldGet("GX6_CDVEIC")+"'"
	cQuery +=   " AND GX6_NRMOV  = GX3_NRMOV"
	cQuery +=   " AND GX6.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasGX3,.F.,.T.)

	If !(cAliasGX3)->(Eof())
		Help( ,, 'HELP',, "Veículo não pode ser utilizado, já está sendo utilizado em outro movimento ("+AllTrim((cAliasGX3)->GX3_NRMOV)+").", 1, 0)
		(cAliasGX3)->(DbCloseArea())
		RestArea(aAreaGU8)
		RestArea(aAreaGX3)
		RestArea(aAreaGX6)
		Return .F.
	EndIf

	(cAliasGX3)->(DbCloseArea())

	For nCont := 1 To oModelGX6:Length()
		oModelGX6:GoLine(nCont)
		If !oModelGX6:IsDeleted() .And. nCont != nLineGX6
			If FwFldGet("GX6_CDVEIC",nCont) == FwFldGet("GX6_CDVEIC",nLineGX6)
				Help( ,, 'HELP',, "Veículo informado já existe para esta movimentação.", 1, 0)
				RestArea(aAreaGX6)
				Return .F.
			EndIf
		EndIf
	Next nCont

	For nCont := 1 To oModelGWV:Length()
		oModelGWV:GoLine(nCont)

		If !oModelGWV:IsDeleted()

			dbSelectArea("GWY")
			GWY->( dbSetOrder(1) )
			GWY->( dbSeek(xFilial("GWY") + oModelGWV:GetValue("GWV_NRAGEN")) )

			While !GWY->( Eof() ) .And. GWY->GWY_FILIAL == xFilial("GWY") .And. GWY->GWY_NRAGEN == oModelGWV:GetValue("GWV_NRAGEN")

				If AScan(aTpVeic,{|x| x == GWY_CDTPVC}) == 0
					AAdd(aTpVeic,GWY_CDTPVC)
				EndIf

				dbSelectArea("GWY")
				GWY->( dbSkip() )
			EndDo
		EndIf

	Next nCont

	oModelGWV:GoLine(nLineGWV)

	If !Empty(aTpVeic)

		For nCont := 1 To oModelGX6:Length()
			oModelGX6:GoLine(nCont)

			If !oModelGX6:IsDeleted() .And. AScan(aTpVeic, {|x| x == Posicione("GU8",1,xFilial("GU8")+oModelGX6:GetValue("GX6_CDVEIC"),"GU8_CDTPVC")}) == 0
				Help( ,, 'HELP',, STR0040, 1, 0) //"O 'Tipo' do Veículo informado deve pertencer a um dos 'Tipos de Veículo' cadastrados nos Agendamentos."
				oModelGX6:GoLine(nLineGX6)
				Return .F.
			EndIf
		Next nCont

		oModelGX6:GoLine(nLineGX6)
	EndIf

	RestArea(aAreaGU8)
	RestArea(aAreaGX3)
	RestArea(aAreaGX6)
Return .T.

//--------------------------------------------------

Function GFEA519GX7(oModelGX7)
	Local aAreaGX7  := GX7->(GetArea())
	Local aAreaGX3  := GX3->(GetArea())
	Local nLineGX7  := oModelGX7:GetLine()
	Local nCont

	dbSelectArea("GX7")
	dbSetOrder(2)
	If dbSeek(xFilial("GX7")+FwFldGet("GX7_CDVISI"))
		dbSelectArea("GX3")
		dbSetOrder(1)
		If dbSeek(xFilial("GX3")+GX7->GX7_NRMOV)
			If GX3->GX3_SIT $ "1234"
				Help( ,, 'HELP',, "Visitante não pode ser utilizado, já está sendo utilizado em outro movimento.", 1, 0)
				RestArea(aAreaGX3)
				RestArea(aAreaGX7)
				Return .F.
			EndIf
		EndIf
	EndIf

	For nCont := 1 To oModelGX7:Length()
		oModelGX7:GoLine(nCont)
		If !oModelGX7:IsDeleted() .And. nCont != nLineGX7
			If FwFldGet("GX7_CDVISI",nCont) == FwFldGet("GX7_CDVISI",nLineGX7)
				Help( ,, 'HELP',, "Visitante informado já existe para esta movimentação.", 1, 0)
				RestArea(aAreaGX3)
				RestArea(aAreaGX7)
				Return .F.
			EndIf
		EndIf
	Next nCont

	RestArea(aAreaGX3)
	RestArea(aAreaGX7)
Return .T.

//--------------------------------------------

Function GFEA519GX8(oModelGX8)
	Local aAreaGX8  := GX8->(GetArea())
	Local aAreaGX3  := GX3->(GetArea())
	Local aAreaGUU  := GUU->(GetArea())
	Local nLineGX8  := oModelGX8:GetLine()
	Local cCpf		:= ""
	Local lRetMoto	:= .T.
	Local nCont

	dbSelectArea("GUU")
	GUU->( dbSetOrder(1) )
	If GUU->( dbSeek(xFilial("GUU")+FwFldGet("GX8_CDMTR")) )
		cCpf := GUU->GUU_IDFED
		GUU->( dbSetOrder(2) )
		If GUU->( dbSeek( xFilial("GUU") + cCpf ) )		
			lRetMoto := .F.
			While GUU->(!Eof())			
				If GUU->GUU_SIT == "1"	
					lRetMoto := .T.
				EndIf
				GUU->( dbSkip() )
			EndDo
		EndIf
		If !lRetMoto
			Help( ,, 'HELP',, "Situação do Motorista/Ajudante está como inativo, não pode ser utilizado.", 1, 0)
			RestArea(aAreaGUU)
			RestArea(aAreaGX3)
			RestArea(aAreaGX8)
			Return .F.
		EndIf
	EndIf

	dbSelectArea("GX8")
	GX8->( dbSetOrder(2) )
	If GX8->( dbSeek(xFilial("GX8")+FwFldGet("GX8_CDMTR")) )
		dbSelectArea("GX3")
		GX3->( dbSetOrder(1) )
		If GX3->( dbSeek(xFilial("GX3")+GX8->GX8_NRMOV) )
			If GX3->GX3_SIT $ "1234"
				Help( ,, 'HELP',, "Motorista não pode ser utilizado, já está sendo utilizado em outro movimento.", 1, 0)
				RestArea(aAreaGUU)
				RestArea(aAreaGX3)
				RestArea(aAreaGX8)
				Return .F.
			EndIf
		EndIf
	EndIf

	For nCont := 1 To oModelGX8:Length()
		oModelGX8:GoLine(nCont)
		If !oModelGX8:IsDeleted() .And. nCont != nLineGX8
			If FwFldGet("GX8_CDMTR",nCont) == FwFldGet("GX8_CDMTR",nLineGX8)
				Help( ,, 'HELP',, "Motorista informado já existe para esta movimentação.", 1, 0)
				RestArea(aAreaGUU)
				RestArea(aAreaGX3)
				RestArea(aAreaGX8)
				Return .F.
			EndIf
		EndIf
	Next nCont

	RestArea(aAreaGUU)
	RestArea(aAreaGX3)
	RestArea(aAreaGX8)
Return .T.

//---------------------------------------------------------

Function GFEA519POS(oModel)
	Local aAreaGVF  := GVF->(GetArea())
	Local aAreaGWV  := GWV->(GetArea())
	Local oModelGWV := oModel:GetModel("GFEA519_GWV")
	Local oModelGX7 := oModel:GetModel("GFEA519_GX7")
	Local oModelGX8 := oModel:GetModel("GFEA519_GX8")
	Local oModelGX6 := oModel:GetModel("GFEA519_GX6")
	Local lEmit     := .F.
	Local nLine     := oModelGWV:GetLine()
	Local nLineGX7  := oModelGX7:GetLine()
	Local nLineGX8  := oModelGX8:GetLine()
	Local lFound    := .F.
	Local nCont
	Local nI
	Local lFAgen    := .F.
	Local lFoundVei := .F.
	Local lMot      := .F.
	Local aAgend 	  := LoadAgenda(oModelGWV)

	If oModel:GetOperation() == MODEL_OPERATION_UPDATE .Or. oModel:GetOperation() == MODEL_OPERATION_INSERT

		If GX3->GX3_SIT == "2" .And. !Empty(aAgend)

			For nI := 1 To Len(aAgend)

				For nCont := 1 To oModelGWV:Length()
					oModelGWV:GoLine(nCont)
					If !oModelGWV:IsDeleted() .And. oModelGWV:GetValue("GWV_NRAGEN") == aAgend[nI]
						lFAgen := .T.
						Exit
					EndIf
				Next nCont

				If lFAgen
					lFAgen := .F.
				Else
					Help( ,, 'HELP',, STR0088 + aAgend[nI] + STR0089, 1, 0) //"O Agendamento " ### " deve estar relacionado a Movimentação."
					Return .F.
				EndIf

			Next nI

			oModelGWV:GoLine(nLine)
		EndIf

		GVI->( dbSetOrder(1) )
		If GVI->( dbSeek(xFilial("GVI") + FwFldGet("GX3_CDOPER") + FwFldGet("GX3_SEQ")) )

			If GVI->GVI_IDOBAG == "1"

				For nCont := 1 To oModelGWV:Length()
					oModelGWV:GoLine(nCont)
					If !oModelGWV:IsDeleted() .And. !Empty(oModelGWV:GetValue("GWV_NRAGEN"))
						lFound := .T.
					EndIf
				Next nCont

				If !lFound
					Help( ,, 'HELP',, STR0034, 1, 0) //"O Ponto de Controle obriga que seja informado um agendamento para a configuração."
					Return .F.
				EndIf
			EndIf

			GVJ->( dbSetOrder(1) )
			GVJ->( dbSeek(xFilial("GVJ") + GVI->GVI_CDOPER + GVI->GVI_SEQ ) )
			While GVJ->( !Eof() ) .And. xFilial("GVJ") == GVJ->GVJ_FILIAL .And. GVJ->GVJ_CDOPER == GVI->GVI_CDOPER .And. GVJ->GVJ_SEQ == GVI->GVI_SEQ
				dbSelectArea("GVF")
				GVF->( dbSetOrder(1) )
				If GVF->( dbSeek(xFilial("GVF") + GVJ->GVJ_CDPTCT) )

					If GVF->GVF_IDEMIT == "1"

						For nCont := 1 To oModelGX7:Length()

							oModelGX7:GoLine(nCont)

							If !oModelGX7:IsDeleted() .And. !Empty(oModelGX7:GetValue("GX7_CDVISI"))
								lEmit := .T.
								Exit
							EndIf

						Next nCont

						oModelGX7:GoLine(nLineGX7)

						If !lEmit

							For nCont := 1 To oModelGX8:Length()

								oModelGX8:GoLine(nCont)

								If !oModelGX8:IsDeleted() .And. !Empty(oModelGX8:GetValue("GX8_CDMTR"))
									lEmit := .T.
									lMot  := .T.
									Exit
								EndIf

							Next nCont

							oModelGX8:GoLine(nLineGX8)

						EndIf

						If !lEmit
							Help( ,, 'HELP',, "O Ponto de Controle obriga que seja informado pelo menos um visitante ou motorista."	, 1, 0)
							Return .F.
						EndIf
						If lMot
							For nCont := 1 To oModelGX6:Length()
								oModelGX6:GoLine(nCont)
								If !oModelGX6:IsDeleted() .And. !Empty(oModelGX6:GetValue("GX6_CDVEIC"))
									lFoundVei := .T.
								EndIf
							Next nCont

							If !lFoundVei
								Help( ,, "HELP",, "Veículo não informado!", 1, 0,,,,,, {"Quando informado motorista, é necessário informar veículo."})
								Return .F.
							EndIf
						EndIf

					EndIf

					If oModel:GetOperation() == MODEL_OPERATION_UPDATE
						If !Empty(aOper[1]) .And. !Empty(aOper[2])

							If (aOper[1] == FwFldGet("GX3_CDOPER") .And. aOper[2] == FwFldGet("GX3_SEQ"))
								Exit
							ElseIf (aOper[1] != FwFldGet("GX3_CDOPER") .Or. aOper[2] != FwFldGet("GX3_SEQ"))

								If GX3->GX3_SIT != "1"
									Help( ,, 'HELP',, STR0037, 1, 0) //"A Configuração de Operação só pode ser alterada quando a situação da movimentação for 'Aberto'."
									Return .F.
								EndIf

								//Deleta relacionamentos do Ponto de Controle da Movimentação.
								//GFEA519DEL()

							EndIf

							aOper[1] := ""
							aOper[2] := ""

						EndIf
					EndIf
				EndIf

				GVJ->( dbSkip() )
			EndDo

		EndIf

	ElseIf oModel:GetOperation() == MODEL_OPERATION_DELETE

		GFEA519DEL()

	EndIf

	RestArea(aAreaGWV)
	RestArea(aAreaGVF)

Return .T.

//----------------------------------------

Function GFEA519GWV(oModel)
	Local aAreaGWV := GWV->(GetArea())
	Local nLine := oModel:GetLine()
	Local nCont

	If AllTrim(FwFldGet("GWV_NRAGEN")) <> ""
		dbSelectArea("GWV")
		dbSetOrder(1)
		If dbSeek(xFilial("GWV") + FwFldGet("GWV_NRAGEN"))
			If GWV->GWV_SIT $ '23' .And. GWV->GWV_NRMOV != GX3->GX3_NRMOV
				Help( ,, 'HELP',, STR0035, 1, 0) //"Somente Agendamentos que estejam com situação em 'Aberto' podem ser vinculados a movimentações."
				RestArea(aAreaGWV)
				Return .F.
			EndIf
			If GWV->GWV_CDOPER+GWV->GWV_SEQ != FwFldGet("GX3_CDOPER")+FwFldGet("GX3_SEQ")
				Help( ,, 'HELP',, "Selecione somente agendamentos com a mesma Operação e sequência do movimento.", 1, 0)
				RestArea(aAreaGWV)
				Return .F.
			EndIf
		Else
			Help( ,, 'HELP',, "Agendamento não cadastrado.", 1, 0)
			RestArea(aAreaGWV)
			Return .F.
		EndIf

		For nCont := 1 To oModel:Length()
			oModel:GoLine(nCont)
			If !oModel:IsDeleted() .And. nCont != nLine
				If FwFldGet("GWV_NRAGEN",nCont) == FwFldGet("GWV_NRAGEN",nLine)
					Help( ,, 'HELP',, "O agendamento informado já existe para esta movimentação.", 1, 0)
					RestArea(aAreaGWV)
					Return .F.
				EndIf
			EndIf
		Next nCont

		RestArea(aAreaGWV)
	EndIf

Return .T.

//----------------------------------------------

Function GFEA519CMT(oModel)
	Local oModelGWV := oModel:GetModel("GFEA519_GWV")
	Local nCont
	Local nLine     := oModelGWV:GetLine()
	Local aAgend 	  := LoadAgenda(oModelGWV)
	Local lCpoSrGXA := GfeVerCmpo({"GXA_SDOC"})
	Local cQuery	:= ""
	Local cAliasGVH

	//Valida a sequencia da ocorrência.
	If !GFEA519SEQ()
		Return .F.
	EndIf

	If oModel:GetOperation() == MODEL_OPERATION_INSERT

		For nCont := 1 To oModelGWV:Length()
			oModelGWV:GoLine(nCont)
			If !oModelGWV:IsDeleted() .And. !Empty(oModelGWV:GetValue("GWV_NRAGEN"))
				dbSelectArea("GWV")
				GWV->( dbSetOrder(1) )
				If GWV->( dbSeek(xFilial("GWV") + oModelGWV:GetValue("GWV_NRAGEN")) )
					RecLock("GWV",.F.)
					GWV->GWV_NRMOV := FwFldGet("GX3_NRMOV")
					GWV->GWV_SIT := "2"
					MsUnlock("GWV")
				EndIf
			EndIf
		Next nCont

	ElseIf oModel:GetOperation() == MODEL_OPERATION_UPDATE

		dbSelectArea("GWV")
		GWV->( dbSetOrder(1) )
		For nCont := 1 To Len(aAgend)
			If GWV->( dbSeek(xFilial("GWV") + aAgend[nCont]) )
				RecLock("GWV", .F.)
				GWV->GWV_NRMOV := ""
				GWV->GWV_SIT   := "1"
				MSUnlock("GWV")
			EndIf
		Next nCont

		For nCont := 1 To oModelGWV:Length()
			oModelGWV:GoLine(nCont)
			If !oModelGWV:IsDeleted() .And. !Empty(oModelGWV:GetValue("GWV_NRAGEN"))
				dbSelectArea("GWV")
				GWV->( dbSetOrder(1) )
				If GWV->( dbSeek(xFilial("GWV") + oModelGWV:GetValue("GWV_NRAGEN")) )
					RecLock("GWV",.F.)
					GWV->GWV_NRMOV := FwFldGet("GX3_NRMOV")
					GWV->GWV_SIT   := "2"
					MsUnlock("GWV")
				EndIf
			EndIf
		Next nCont

	ElseIf oModel:GetOperation() == MODEL_OPERATION_DELETE
		For nCont := 1 To oModelGWV:Length()
			oModelGWV:GoLine(nCont)
			dbSelectArea("GWV")
			GWV->( dbSetOrder(1) )
			If GWV->( dbSeek(xFilial("GWV") + oModelGWV:GetValue("GWV_NRAGEN")) )
				RecLock("GWV",.F.)
				GWV->GWV_NRMOV := ""
				GWV->GWV_SIT   := "1"
				MsUnlock("GWV")
			EndIf
		Next nCont

		DelTabFilho("GX6", oModel)
		DelTabFilho("GX7", oModel)
		DelTabFilho("GX8", oModel)
		DelTabFilho("GX9", oModel)
	EndIf

	If oModel:GetOperation() == MODEL_OPERATION_INSERT

		// Grava registros das tabelas filhas
		dbSelectArea("GVI")
		GVI->( dbSetOrder(1) )
		If GVI->( dbSeek(xFilial("GVI") + FwFldGet("GX3_CDOPER") + FwFldGet("GX3_SEQ")) )

			dbSelectArea("GVJ")
			GVJ->( dbSetOrder(1) )
			GVJ->( dbSeek(xFilial("GVJ") + GVI->GVI_CDOPER + GVI->GVI_SEQ ) )
			While GVJ->( !Eof() ) .And. xFilial("GVJ") == GVJ->GVJ_FILIAL .And. GVJ->GVJ_CDOPER == GVI->GVI_CDOPER .And. GVJ->GVJ_SEQ == GVI->GVI_SEQ
				dbSelectArea("GVF")
				GVF->( dbSetOrder(1) )
				If GVF->( dbSeek(xFilial("GVF") + GVJ->GVJ_CDPTCT) )

					RecLock("GX4",.T.)
					GX4->GX4_FILIAL	:= xFilial("GX4")
					GX4->GX4_NRMOV  	:= FwFldGet("GX3_NRMOV")
					GX4->GX4_CDPTCT 	:= GVF->GVF_CDPTCT
					GX4->GX4_SEQ    	:= GVJ->GVJ_ORDEM
					GX4->GX4_SIT    	:= "1"
					GX4->GX4_IDPEDI 	:= "2"
					MsUnLock("GX4")

					For nCont := 1 To oModelGWV:Length()
						oModelGWV:GoLine(nCont)

						If !oModelGWV:IsDeleted()
							dbSelectArea("GWW")
							GWW->( dbSetOrder(1) )
							GWW->( dbSeek(xFilial("GWW") + oModelGWV:GetValue("GWV_NRAGEN")) )
							While !GWW->( Eof() ) .And. GWW->GWW_FILIAL == xFilial("GWW") .And. GWW->GWW_NRAGEN == oModelGWV:GetValue("GWV_NRAGEN")

								// Documentos de Carga
								dbSelectArea("GW1")
								GW1->( dbSetOrder(1) )
								GW1->( dbSeek(xFilial("GW1") + GWW->GWW_CDTPDC + GWW->GWW_EMISDC + GWW->GWW_SERDC + GWW->GWW_NRDC ) )
								While !GW1->( Eof() ) .And. GW1->GW1_FILIAL == xFilial("GW1") .And. GW1->GW1_CDTPDC == GWW->GWW_CDTPDC .And. GW1->GW1_EMISDC == GWW->GWW_EMISDC .And. GW1->GW1_SERDC == GWW->GWW_SERDC .And. GW1->GW1_NRDC == GWW->GWW_NRDC
									// GWN - Romaneios de Carga
									dbSelectArea("GWN")
									GWN->( dbSetOrder(1) )
									GWN->( dbSeek(xFilial("GWN") + GW1->GW1_NRROM ) )
									While !GWN->( Eof() ) .And. GWN->GWN_NRROM == GW1->GW1_NRROM
										RecLock("GWN", .F.)
										GWN->GWN_NRMOV := GX4->GX4_NRMOV
										MsUnLock("GWN")

										GWN->( dbSkip() )
									EndDo

									GW1->( dbSkip() )
								EndDo

								RecLock("GXA", .T.)
								GXA->GXA_FILIAL := xFilial("GXA")
								GXA->GXA_NRDC   := GWW->GWW_NRDC
								GXA->GXA_NRMOV  := GX4->GX4_NRMOV
								GXA->GXA_CDPTCT := GVF->GVF_CDPTCT
								GXA->GXA_SEQ    := GVJ->GVJ_ORDEM
								GXA->GXA_CDTPDC := GWW->GWW_CDTPDC
								GXA->GXA_EMISDC := GWW->GWW_EMISDC
								GXA->GXA_SERDC  := GWW->GWW_SERDC
								If lCpoSrGXA
									GXA->GXA_SDOC := GWW->GWW_SDOC
								EndIf
								MsUnLock("GXA")

								GWW->( dbSkip() )
							EndDo
						EndIf

					Next nCont

					oModelGWV:GoLine(nLine)

					//Vincula Perguntas
					cQuery := "SELECT GVH.GVH_CDPERG FROM " + RetSQLName("GVH") + " GVH "
					cQuery += " WHERE GVH.GVH_FILIAL = '"   + xFilial("GVH") + "'"
					cQuery += "   AND GVH.GVH_CDPTCT = '"   + GVF->GVF_CDPTCT + "'"
					cQuery += "   AND GVH.D_E_L_E_T_ = '' "
					cQuery += "   ORDER BY R_E_C_N_O_ "
					cQuery := ChangeQuery(cQuery)

					cAliasGVH := GetNextAlias()
					dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),cAliasGVH, .F., .T.)

					dbSelectArea(cAliasGVH)
					(cAliasGVH)->( dbGoTop() )
					While !(cAliasGVH)->(Eof())
						RecLock("GX5", .T.)
						GX5->GX5_FILIAL := xFilial("GX5")
						GX5->GX5_NRMOV  := GX4->GX4_NRMOV
						GX5->GX5_CDPTCT := GVF->GVF_CDPTCT
						GX5->GX5_SEQ    := GVJ->GVJ_ORDEM
						GX5->GX5_CDPERG := (cAliasGVH)->GVH_CDPERG
						GX5->GX5_RESPOS := "0"
						GX5->GX5_OBS    := ""
						MsUnLock("GX5")

						(cAliasGVH)->( dbSkip() )

					EndDo

					(cAliasGVH)->( dbCloseArea() )

				EndIf

				GVJ->( dbSkip() )
			EndDo
		EndIf

	EndIf

	FwFormCommit(oModel)

	If !(Type("oBrwGX3") $ 'U;UE;UI')
		oPnlBrowses:SetUpdatesEnabled(.F.)
		Processa({|lEnd| A519MontaDados(!Empty(cPlaca))},"Carregando informações", "Aguarde...")
		dbSelectArea("GX3")
		GX3->(dbSetOrder(1))
		dbSelectArea(cAliGX3)
		(cAliGX3)->(dbSetOrder(1))
		If !oModel:GetOperation() == MODEL_OPERATION_DELETE
			(cAliGX3)->(dbSeek(oModel:GetValue("GFEA519_GX3","GX3_NRMOV")))
			GX3->(dbSeek(oModel:GetValue("GFEA519_GX3","GX3_FILIAL")+oModel:GetValue("GFEA519_GX3","GX3_NRMOV")))
		Else
			(cAliGX3)->(dbGoTop())
		EndIf
		oBrwGX3:Refresh()
		oBrwGX4:Refresh()
		oPnlBrowses:SetUpdatesEnabled(.T.)
	EndIf
Return .T.

//----------------------------------------------

Function GFEA519TGR()
	Local lFind
	Local oModel    := FWModelActive()
	Local oModelGWV := oModel:GetModel("GFEA519_GWV")
	Local aFields   := oModelGWV:GetStruct():GetFields()
	Local cCmp      := "GWV_DTAGEN;GWV_HRAGEN;GWV_DTCRIA;GWV_HRCRIA;GWV_NRROM;GWV_PESOR"
	Local cCmpDt    := "GWV_DTAGEN;GWV_DTCRIA"
	Local nCont
	Local aAreaGWV := GWV->( GetArea() )

	dbSelectArea("GWV")
	GWV->(dbSetOrder(1))
	lFind := GWV->(dbSeek(xFilial("GWV") + oModelGWV:GetValue("GWV_NRAGEN")))

	For nCont := 1 To Len(aFields)
		If aFields[nCont][3] $ cCmp
			If lFind
				oModelGWV:SetValue(aFields[nCont][3],&("GWV->"+aFields[nCont][3]))
			Else
				If aFields[nCont][3] $ cCmpDt
					oModelGWV:SetValue(aFields[nCont][3],SToD(" "))
				Else
					oModelGWV:SetValue(aFields[nCont][3]," ")
				EndIf
			EndIf
		EndIf
	Next nCont

	GFEA519REL()

	RestArea(aAreaGWV)

Return FwFldGet("GX3_NRMOV")

//----------------------------------------------

Function GFEA519REL()
	Local oModel    := FWModelActive()
	Local oModelGX7 := oModel:GetModel("GFEA519_GX7") // Visitantes
	Local oModelGX8 := oModel:GetModel("GFEA519_GX8") // Motoristas
	Local nGX7Line  := oModelGX7:GetLine()
	Local nGX8Line  := oModelGX8:GetLine()
	Local lLoop     := .F.
	Local nCont

	dbSelectArea("GX1")
	GX1->( dbSetOrder(1) )
	GX1->( dbSeek(xFilial("GX1") + GWV->GWV_NRAGEN) )
	While !GX1->( Eof() ) .And. GX1->GX1_FILIAL == xFilial("GX1") .And. GX1->GX1_NRAGEN == GWV->GWV_NRAGEN

		For nCont := 1 To oModelGX8:Length()
			oModelGX8:GoLine(nCont)

			If oModelGX8:GetValue("GX8_CDMTR") == GX1->GX1_CDMTR
				lLoop := .T.
				Exit
			EndIf
		Next nCont

		If lLoop
			lLoop := .F.
			dbSelectArea("GX1")
			GX1->( dbSkip() )
			Loop
		EndIf

		oModelGX8:GoLine(1)

		If Empty(oModelGX8:GetValue("GX8_CDMTR"))
			oModelGX8:LoadValue("GX8_CDMTR", GX1->GX1_CDMTR)
			oModelGX8:LoadValue("GX8_NMMTR", Posicione("GUU",1,XFILIAL("GUU")+GX1->GX1_CDMTR,"GUU_NMMTR"))
		Else
			oModelGX8:AddLine()
			oModelGX8:LoadValue("GX8_CDMTR", GX1->GX1_CDMTR)
			oModelGX8:LoadValue("GX8_NMMTR", Posicione("GUU",1,XFILIAL("GUU")+GX1->GX1_CDMTR,"GUU_NMMTR"))
		EndIf

		dbSelectArea("GX1")
		GX1->( dbSkip() )
	EndDo

	oModelGX8:GoLine(nGX8Line)

	lLoop := .F.

	//-------------------------

	dbSelectArea("GWZ")
	GWZ->( dbSetOrder(1) )
	GWZ->( dbSeek(xFilial("GWZ") + GWV->GWV_NRAGEN) )
	While !GWZ->( Eof() ) .And. GWZ->GWZ_FILIAL == xFilial("GWZ") .And. GWZ->GWZ_NRAGEN == GWV->GWV_NRAGEN

		For nCont := 1 To oModelGX7:Length()
			oModelGX7:GoLine(nCont)

			If oModelGX7:GetValue("GX7_CDVISI") == GWZ->GWZ_CDVISI
				lLoop := .T.
				Exit
			EndIf
		Next nCont

		If lLoop
			lLoop := .F.
			dbSelectArea("GWZ")
			GWZ->( dbSkip() )
			Loop
		EndIf

		oModelGX7:GoLine(1)

		If Empty(oModelGX7:GetValue("GX7_CDVISI"))
			oModelGX7:LoadValue("GX7_CDVISI", GWZ->GWZ_CDVISI)
			oModelGX7:LoadValue("GX7_NMVISI", Posicione("GVE",1,XFILIAL("GVE")+GWZ->GWZ_CDVISI,"GVE_NMVISI"))
		Else
			oModelGX7:AddLine()
			oModelGX7:LoadValue("GX7_CDVISI", GWZ->GWZ_CDVISI)
			oModelGX7:LoadValue("GX7_NMVISI", Posicione("GVE",1,XFILIAL("GVE")+GWZ->GWZ_CDVISI,"GVE_NMVISI"))
		EndIf

		dbSelectArea("GWZ")
		GWZ->( dbSkip() )
	EndDo

	oModelGX7:GoLine(nGX7Line)

Return

//----------------------------------------------

function LoadAgenda(oModelGWV)
	Local aAgend 	:= {}
	Local nCont 	:= 0

	For nCont := 1 To oModelGWV:Length()
		oModelGWV:GoLine(nCont)
		If !Empty(oModelGWV:GetValue("GWV_NRAGEN"))
			AAdd(aAgend, oModelGWV:GetValue("GWV_NRAGEN"))
		EndIf
	Next nCont

return aagend

Function GFEA519ACT(oModel)
	Local oModelGWV := oModel:GetModel("GFEA519_GWV")
	Local oModelGX3 := oModel:GetModel("GFEA519_GX3")
	Local nLine := oModelGWV:GetLine()
	Local aAreaGWV := GWV->( GetArea() )
	Local aAgend := {}
	Local lAtrib := .F.

	If !IsInCallStack("GFEA522")
		If oModel:GetOperation() == MODEL_OPERATION_UPDATE
			aOper[1] := FwFldGet("GX3_CDOPER")
			aOper[2] := FwFldGet("GX3_SEQ")
		EndIf

		aAgend := LoadAgenda(oModelGWV)

		oModelGWV:GoLine(nLine)

		If !Empty(cOpAgen)

			oModelGWV:GoLine(1)

			dbSelectArea(cOpAgen)
			(cOpAgen)->( dbSetOrder(1) )
			(cOpAgen)->( dbGoTop() )
			While !(cOpAgen)->( Eof() )

				If IsMark("OK",cMarca)

					If !lAtrib
						lAtrib := .T.

						oModelGX3:SetValue("GX3_CDOPER", (cOpAgen)->GWV_CDOPER)
						oModelGX3:SetValue("GX3_SEQ"   , (cOpAgen)->GWV_SEQOP )
						oModelGX3:SetValue("GX3_CDEMIT", (cOpAgen)->GWV_CDEMIT)
					EndIf

					If Empty(oModelGWV:GetValue("GWV_NRAGEN"))
						oModelGWV:SetValue("GWV_NRAGEN", (cOpAgen)->GWV_NRAGEN)
						oModelGWV:SetValue("GWV_DTAGEN", (cOpAgen)->GWV_DTAGEN)
						oModelGWV:SetValue("GWV_HRAGEN", (cOpAgen)->GWV_HRAGEN)
						oModelGWV:SetValue("GWV_DTCRIA", (cOpAgen)->GWV_DTAGEN)
						oModelGWV:SetValue("GWV_HRCRIA", (cOpAgen)->GWV_HRCRIA)
					Else
						oModelGWV:AddLine()
						oModelGWV:SetValue("GWV_NRAGEN", (cOpAgen)->GWV_NRAGEN)
						oModelGWV:SetValue("GWV_DTAGEN", (cOpAgen)->GWV_DTAGEN)
						oModelGWV:SetValue("GWV_HRAGEN", (cOpAgen)->GWV_HRAGEN)
						oModelGWV:SetValue("GWV_DTCRIA", (cOpAgen)->GWV_DTAGEN)
						oModelGWV:SetValue("GWV_HRCRIA", (cOpAgen)->GWV_HRCRIA)
					EndIf

					dbSelectArea("GWV")
					GWV->( dbSetOrder(1) )
					GWV->( dbSeek(xFilial("GWV") + (cOpAgen)->GWV_NRAGEN) )

					GFEA519REL()
				EndIf

				dbSelectArea(cOpAgen)
				(cOpAgen)->( dbSkip() )
			EndDo

			oModelGWV:GoLine(nLine)
			RestArea(aAreaGWV)

			GFEDelTab(cOpAgen)
			cOpAgen := ""

		EndIf

	EndIf
Return

//---------------------------------------------

Function GFEA519VLM(oModel)

	If !(GX3->GX3_SIT $ "1;2") .And. oModel:GetOperation() == MODEL_OPERATION_UPDATE
		Help( ,, 'HELP',, "Só pode ser alterada uma movimentação com situação 'Aberto' ou 'Movimentado'.", 1, 0)
		Return .F.
	EndIf

	If GX3->GX3_SIT != "1" .And. oModel:GetOperation() == MODEL_OPERATION_DELETE
		Help( ,, 'HELP',, "Só pode ser excluída uma movimentação com situação 'Aberto'.", 1, 0)
		Return .F.
	EndIf

Return .T.

//--------------------------------------------

Function GFEA519AOK(oModel,oView)

	If oModel:GetOperation() == MODEL_OPERATION_DELETE

		dbSelectArea("GX4")
		GX4->( dbSetOrder(1) )
		GX4->( dbSeek(xFilial("GX4") + GX3->GX3_NRMOV) )
		While !GX4->( Eof() ) .And. GX4->GX4_FILIAL == xFilial("GX4") .And. GX4->GX4_NRMOV == GX3->GX3_NRMOV
			RecLock("GX4", .F.)
			dbDelete()
			MsUnlock("GX4")

			dbSelectArea("GX4")
			GX4->( dbSkip() )
		EndDo

		dbSelectArea("GX5")
		GX5->( dbSetOrder(1) )
		GX5->( dbSeek(xFilial("GX5") + GX3->GX3_NRMOV) )
		While !GX5->( Eof() ) .And. GX5->GX5_FILIAL == xFilial("GX5") .And. GX5->GX5_NRMOV == GX3->GX3_NRMOV
			RecLock("GX5", .F.)
			dbDelete()
			MsUnlock("GX5")

			dbSelectArea("GX5")
			GX5->( dbSkip() )
		EndDo

		dbSelectArea("GXA")
		GXA->( dbSetOrder(1) )
		GXA->( dbSeek(xFilial("GXA") + GX3->GX3_NRMOV) )
		While !GXA->( Eof() ) .And. GXA->GXA_FILIAL == xFilial("GXA") .And. GXA->GXA_NRMOV == GX3->GX3_NRMOV
			RecLock("GXA", .F.)
			dbDelete()
			MsUnlock("GXA")

			dbSelectArea("GXA")
			GXA->( dbSkip() )
		EndDo

	EndIf

Return .T.

//-------------------------------

Static Function GFEA519DEL()

	//Deleta PC
	dbSelectArea("GX4")
	GX4->( dbSetOrder(1) )
	GX4->( dbSeek(xFilial("GX4") + GX3->GX3_NRMOV) )

	While !GX4->( Eof() ) .And. GX4->GX4_FILIAL == xFilial("GX4") .And. GX4->GX4_NRMOV == FwFldGet("GX3_NRMOV")
		RecLock("GX4",.F.)
		dbDelete()
		MsUnLock("GX4")

		dbSelectArea("GX4")
		GX4->( dbSkip() )
	EndDo

	//Deleta DC
	dbSelectArea("GXA")
	GXA->( dbSetOrder(1) )
	GXA->( dbSeek(xFilial("GXA") + GX3->GX3_NRMOV) )
	While !GXA->( Eof() ) .And. GXA->GXA_FILIAL == xFilial("GXA") .And. GXA->GXA_NRMOV == GX3->GX3_NRMOV

		RecLock("GXA",.F.)
		dbDelete()
		MsUnLock("GXA")

		dbSelectArea("GXA")
		GXA->( dbSkip() )
	EndDo

	//Deleta Pergunta
	dbSelectArea("GX5")
	GX5->( dbSetOrder(1) )
	GX5->( dbSeek(xFilial("GX5") + GX3->GX3_NRMOV) )

	While !GX5->( Eof() ) .And. GX5->GX5_FILIAL == xFilial("GX5") .And. GX5->GX5_NRMOV == FwFldGet("GX3_NRMOV")
		RecLock("GX5",.F.)
		dbDelete()
		MsUnLock("GX5")

		dbSelectArea("GX5")
		GX5->( dbSkip() )
	EndDo

Return

//------------------------------------

Function GFEA519PRE(oModelGWV,nLine,cOp)
	Local oModel    := oModelGWV:GetModel()
	Local oView     := FWViewActive()
	Local oModelGX7 := oModel:GetModel("GFEA519_GX7")
	Local oModelGX8 := oModel:GetModel("GFEA519_GX8")
	Local nGX7Line  := oModelGX7:GetLine()
	Local nGX8Line  := oModelGX8:GetLine()
	Local cAgen     := oModelGWV:GetValue("GWV_NRAGEN")
	Local nCont

	If cOp $ "DELETE,UNDELETE"

		dbSelectArea("GX1")
		GX1->( dbSetOrder(1) )
		GX1->( dbSeek(xFilial("GX1") + cAgen) )
		While !GX1->( Eof() ) .And. GX1->GX1_FILIAL == xFilial("GX1") .And. GX1->GX1_NRAGEN == cAgen

			For nCont := 1 To oModelGX8:Length()
				oModelGX8:GoLine(nCont)

				If oModelGX8:GetValue("GX8_CDMTR") == GX1->GX1_CDMTR //.And. !oModelGX8:IsDeleted()
					If(cOp == "DELETE",	oModelGX8:DeleteLine(), oModelGX8:UnDeleteLine())
				EndIf
			Next nCont

			dbSelectArea("GX1")
			GX1->( dbSkip() )
		EndDo

		oModelGX8:GoLine(nGX8Line)

		//----------------------------

		dbSelectArea("GWZ")
		GWZ->( dbSetOrder(1) )
		GWZ->( dbSeek(xFilial("GWZ") + cAgen) )
		While !GWZ->( Eof() ) .And. GWZ->GWZ_FILIAL == xFilial("GWZ") .And. GWZ->GWZ_NRAGEN == cAgen

			For nCont := 1 To oModelGX7:Length()
				oModelGX7:GoLine(nCont)

				If oModelGX7:GetValue("GX7_CDVISI") == GWZ->GWZ_CDVISI //.And. !oModelGX7:IsDeleted()
					If(cOp == "DELETE",	oModelGX7:DeleteLine(), oModelGX7:UnDeleteLine())
				EndIf
			Next nCont

			dbSelectArea("GWZ")
			GWZ->( dbSkip() )
		EndDo

		oModelGX7:GoLine(nGX7Line)

		oView:Refresh("GFEA519_GWV")
		oView:Refresh("GFEA519_GX7")
		oView:Refresh("GFEA519_GX8")

	EndIf

Return .T.

//-----------------------------------

Function GFEA519RES()
	Local cLog
	Local cAux := ""
	Local aDc  := {}

	cLog := Upper(STR0041) + CRLF + CRLF //

	cLog += "-" + STR0043 + GX3->GX3_NRMOV + CRLF //"MOVIMENTAÇÃO : "
	cLog += "-" + STR0044 + GX3->GX3_CDOPER + CRLF //"OPERAÇÃO : "
	cLog += "-" + STR0045 + GX3->GX3_SEQ + CRLF //"SEQ. OPERAÇÃO : "
	cLog += "-" + "DESCRIÇÃO : " + Posicione("GVI",1,xFilial("GVI")+GX3->GX3_CDOPER+GX3->GX3_SEQ,"GVI_DSCONF")
	cLog += "-" + STR0046 + {STR0047,STR0048,STR0049,STR0050,STR0051,STR0052}[Val(GX3->GX3_SIT)] + CRLF //"SITUAÇÃO : " ### "Aberto" ### "Movimentado" ### "Em Fila" ### "Endereçado" ### "Cancelado" ### "Concluído"
	cLog += CRLF

	cLog += "-" + STR0053 + CRLF //"PONTOS DE CONTROLE"

	cLog += "|_" + PadR(STR0054, 17) + "|" + STR0055 + "|" + PadR(STR0056,50) + "|" + PadR(STR0057,15) + "|" + PadR(STR0058,17) + "|" + STR0059 + CRLF //"Código" ### "Sequência" ### "Endereço" ### "Status" ### "Entrada" ### "Saída"

	dbSelectArea("GX4")
	GX4->( dbSetOrder(4) )
	GX4->( dbSeek(xFilial("GX4") + GX3->GX3_NRMOV) )
	While !GX4->( Eof() ) .And. GX4->GX4_FILIAL == xFilial("GX4") .And. GX4->GX4_NRMOV == GX3->GX3_NRMOV

		cLog += " |_" + PadR(GX4->GX4_CDPTCT,16) + "|" + PadR(GX4->GX4_SEQ,9) + "|" + Posicione("GVD",1,xFilial("GVD")+GX4->GX4_CDENDE,"GVD_DSENDE") + "|" +;
		PadR({STR0060,STR0061,STR0062}[Val(GX4->GX4_SIT)], 15) + "|" + DToC(GX4->GX4_DTENTR) + " " + Stuff(GX4->GX4_HRENTR,3,0,":") + "|" + DToC(GX4->GX4_DTSAI) + " " + Stuff(GX4->GX4_HRSAI,3,0,":") + CRLF //"Não Avaliado" ### "Aprovado" ### "Reprovado"

		dbSelectArea("GX4")
		GX4->( dbSkip() )
	EndDo

	cLog += CRLF + "-" + STR0063 + CRLF //"EMITENTES DA MOVIMENTAÇÃO"

	cLog += "|_" + PadR(STR0064, TamSX3("GU3_NMEMIT")[1]) + "|" + STR0065 + CRLF //"Nome" ### "Tipo"

	dbSelectArea("GU3")
	GU3->( dbSetOrder(1) )
	If GU3->( dbSeek(xFilial("GU3") + GX3->GX3_CDEMIT) )

		If GU3->GU3_EMFIL == "1"
			cAux += STR0066 //"Filial,"
		EndIf

		If GU3->GU3_TRANSP == "1"
			cAux += STR0067 //"Transportador,"
		EndIf

		If GU3->GU3_CLIEN == "1"
			cAux += STR0068 //"Cliente,"
		EndIf

		If GU3->GU3_FORN == "1"
			cAux += STR0069 //"Fornecedor,"
		EndIf

		If GU3->GU3_AUTON == "1"
			cAux += STR0070 //"Autônomo,"
		EndIf

		cLog += " |_ " + GU3->GU3_NMEMIT + "|" + SubStr(cAux,1,Len(cAux)-1)

	EndIf

	cLog += CRLF + CRLF + "-" + STR0071 + CRLF //"DOCUMENTOS DE CARGA"
	cLog += "|_" + STR0065 + "   |" + STR0072 + " |" + STR0073 + "|" + STR0074 //"Tipo" ### "Emitente" ### "Série" ### "Número"

	dbSelectArea("GX4")
	GX4->( dbSetOrder(1) )
	GX4->( dbSeek(xFilial("GX4") + GX3->GX3_NRMOV) )
	While !GX4->( Eof() ) .And. GX4->GX4_FILIAL == xFilial("GX4") .And. GX4->GX4_NRMOV == GX3->GX3_NRMOV

		dbSelectArea("GXA")
		GXA->( dbSetOrder(1) )
		GXA->( dbSeek(xFilial("GXA") + GX4->GX4_NRMOV + GX4->GX4_CDPTCT + GX4->GX4_SEQ) )
		While !GXA->( Eof() ) .And. GXA->GXA_FILIAL == xFilial("GXA") .And. GXA->GXA_NRMOV == GX4->GX4_NRMOV .And. GXA->GXA_CDPTCT == GX4->GX4_CDPTCT .And. GXA->GXA_SEQ == GX4->GX4_SEQ

			If AScan(aDC,{|x| x == GXA->GXA_CDTPDC+GXA->GXA_EMISDC+GXA->GXA_SERDC+GXA->GXA_NRDC}) == 0
				cLog += CRLF + " |_ "+ GXA->GXA_CDTPDC + "|" + GXA->GXA_EMISDC + "|" + If (lCpoSrGXA ,SerieNfId("GXA",2,"GXA_SERDC"), GXA->GXA_SERDC) + "|" + GXA->GXA_NRDC
				AAdd(aDC, GXA->GXA_CDTPDC+GXA->GXA_EMISDC+GXA->GXA_SERDC+GXA->GXA_NRDC)
			EndIf

			dbSelectArea("GXA")
			GXA->( dbSkip() )
		EndDo

		dbSelectArea("GX4")
		GX4->( dbSkip() )
	EndDo

	cLog += CRLF + CRLF + "-" + "UNITIZADORES" + CRLF
	cLog += "|_" + Padr("Código",TamSX3("GX9_CDUNIT")[1]) + "  | " + Padr("Descrição",TamSX3("GX9_DSUNIT")[1]) + " | " + "QTD" + " | " + PadR("Tara", Len(PESQPICT("GUG", "GUG_TARA"))) + "|" + "ID"
	dbSelectArea("GX9")
	GX9->( dbSetOrder(1) )
	If GX9->( dbSeek(xFilial("GX9") + GX3->GX3_NRMOV) )

		While !GX9->( Eof() ) .And. GX9->GX9_FILIAL == xFilial("GX9") .And. GX9->GX9_NRMOV == GX3->GX3_NRMOV
			cLog += CRLF + " |_ "+ GX9->GX9_CDUNIT + "| " + Posicione("GUG",1,xFilial("GUG")+GX9->GX9_CDUNIT,"GUG_DSUNIT") + " | " + ;
			PadR(cValToChar(GX9->GX9_QTD),3) + " | " + ;
			PadR(Transform(Posicione("GUG",1,xFilial("GUG")+GX9->GX9_CDUNIT,"GUG_TARA"),PESQPICT("GUG","GUG_TARA")), Len(PESQPICT("GUG","GUG_TARA"))) + " | " + ;
			GX9->GX9_IDUNIT

			GX9->( dbSkip() )
		EndDo

	EndIf

	cLog += CRLF + CRLF + CRLF

	DEFINE MSDIALOG oDlgResMov TITLE STR0075 FROM 500,120 TO 900,950 OF oMainWnd Color CLR_BLACK,RGB(225,225,225) PIXEL //"Resumo da Movimentação"

	oMGet:= tMultiget():New(0,0,{|u| If(Pcount()>0,cLog:=u,cLog)},oDlgResMov,300,204,,,,,,.T.,,,,,,.T.)
	oMGet:EnableVScroll(.T.)
	oMGet:EnableHScroll(.T.)
	oMGet:Align := CONTROL_ALIGN_ALLCLIENT
	oMGet:oFont := TFont():New( 'Courier New', 6, 16 )

	oPanel := tPanel():New(0,0,,oDlgResMov,,,,,,31,15,.F.,.F.)
	oPanel:Align := CONTROL_ALIGN_BOTTOM

	oBtn := TButton():New( 2, 370, "OK", oPanel,{||oDlgResMov:End()},;
	40, 10,,,.F.,.T.,.F.,,.F.,,,.F. )

	ACTIVATE MSDIALOG oDlgResMov CENTERED

Return

//---------------------------------------------------

Function GFEA519CAN()
	Local cOp       	:= ""
	Local lLast     	:= .F.
	Local aChave    	:= {}
	Local cOcor
	Local lRet      	:= .T.
	Local s_GFEA5193	:= ExistBlock("GFEA5193")
	Local lExiMotCan	:= GFXCP12123("GX3_MOTCAN")
	Local oGFEComment

	/*Ponto de entrada Sementes Goias
	Permite não autorizar o cancelamento da ação.
	Ticket Zendesk: 1423304
	*/
	If s_GFEA5193
		lRet := ExecBlock("GFEA5193",.F.,.F., {GX3->GX3_NRMOV,GX3->GX3_CDOPER})
	EndIf

	If lRet // Resultado do ponto de controle
		If Alltrim(GX3->GX3_SIT) == "6" // Movimento Concluído
			MsgAlert("Movimentos Concluídos não podem ser cancelados.", "Aviso")
			Return
		Else

			oGFEComment := GFEComment():New()
			oGFEComment:setTitleWindow("Cancelar Movimentação")
			oGFEComment:setTitleMemo("Digite o motivo para o cancelamento da movimentação: " + GX3->GX3_NRMOV)
			oGFEComment:setBtnConfirm("Confirmar")
			oGFEComment:setBtnCancel("Desistir")
			oGFEComment:createWindow()

			If !oGFEComment:getStatus()
				oGFEComment:destroy(oGFEComment)
				Return
			Else
				If AllTrim(oGFEComment:getText()) != ""
					GX4->( dbSetOrder(4) )
					GX4->( dbSeek(xFilial("GX4") + GX3->GX3_NRMOV) )
					While !GX4->( Eof() ) .And. GX4->GX4_FILIAL == xFilial("GX4") .And. GX4->GX4_NRMOV == GX3->GX3_NRMOV

						aChave := {GX4->GX4_CDPTCT, GX4->GX4_SEQ}

						If lLast
							dbSelectArea("GX4")
							GX4->( dbSkip() )
							Loop
						EndIf

						If GX4->GX4_SIT == "1"
							cOp := "1"
						ElseIf ( Empty(GX4->GX4_DTSAI) .Or. Empty(GX4->GX4_HRSAI) ) .And. GX4->GX4_SIT == "2"
							cOp := "2"
						ElseIf ( !Empty(GX4->GX4_DTSAI) .And. !Empty(GX4->GX4_HRSAI) ) .And. GX4->GX4_SIT == "2"
							cOp := "3"
						ElseIf ( Empty(GX4->GX4_DTSAI) .Or. Empty(GX4->GX4_HRSAI) ) .And. GX4->GX4_SIT == "3"
							cOp := "4"
						ElseIf ( !Empty(GX4->GX4_DTSAI) .And. !Empty(GX4->GX4_HRSAI) ) .And. GX4->GX4_SIT == "3"
							cOp := "5"
						EndIf

						cOcor := GFEA519BIM(GX4->GX4_NRMOV, GX4->GX4_CDPTCT, GX4->GX4_SEQ)

						If cOp $ "124"
							Exit
						Else
							If cOp == "5" .And. Posicione("GVF",1,xFilial("GVF")+GX4->GX4_CDPTCT,"GVF_IDIMPE") == "1"
								If cOcor == "3"
									lLast  := .T.
								ElseIf cOcor $ "0;1"
									Exit
								EndIf
							EndIf
						EndIf

						dbSelectArea("GX4")
						GX4->( dbSkip() )
					EndDo

					If Len(aChave) == 0
						aChave := {"" , ""}
					EndIf

					dbSelectArea("GX4")
					GX4->( dbSetOrder(1) )
					If GX4->( dbSeek(xFilial("GX4") + GX3->GX3_NRMOV + aChave[1] + aChave[2]) )

						If Posicione("GVF",1,xFilial("GVF")+GX4->GX4_CDPTCT,"GVF_IDINEN") == "1" .And. !Empty(GX4->GX4_DTCHEN) .And. !Empty(GX4->GX4_HRCHEN) .And. ;
						Empty(GX4->GX4_DTLIEN) .And. Empty(GX4->GX4_HRLIEN)

							dbSelectArea("GVK")
							GVK->( dbSetOrder(2) )
							If GVK->( dbSeek(xFilial("GVK") + GX4->GX4_NRMOV + GX4->GX4_CDPTCT + GX4->GX4_SEQ) )
								GFEA519RGK()//Exclui da fila e atualiza a posição das outras
							Else
								dbSelectArea("GVD")
								GVD->( dbSetOrder(1) )
								If GVD->( dbSeek(xFilial("GVD") + GX4->GX4_CDENDE) )

									RecLock("GVD", .F.)
									GVD->GVD_IDOCUP := "2"
									MsUnlock("GVD")

								EndIf
							EndIf

						EndIf

					EndIf

					dbSelectArea("GWV")
					GWV->( dbSetOrder(4) )
					GWV->( dbSeek(xFilial("GWV") + GX3->GX3_NRMOV) )
					While !GWV->( Eof() ) .And. GWV->GWV_FILIAL == xFilial("GWV") .And. GWV->GWV_NRMOV == GX3->GX3_NRMOV

						RecLock("GWV", .F.)
						GWV->GWV_SIT := "3"
						MsUnlock("GWV")

						dbSelectArea("GWV")
						GWV->( dbSkip() )
					EndDo

					RecLock("GX3", .F.)
					GX3->GX3_SIT 	:= "5"
					If lExiMotCan
						GX3->GX3_MOTCAN := oGFEComment:getText()
					EndIf
					MsUnlock("GX3")

					If !(Type("oBrwGX3") $ 'U;UE;UI')
						oPnlBrowses:SetUpdatesEnabled(.F.)
						Processa({|lEnd| A519MontaDados(!Empty(cPlaca))},"Carregando informações", "Aguarde...")
						dbSelectArea(cAliGX3)
						(cAliGX3)->(dbGoTop())
						oBrwGX3:Refresh()
						oBrwGX4:Refresh()
						oPnlBrowses:SetUpdatesEnabled(.T.)
					EndIf
				Else
					GFEHelp("É necessário que exista um motivo para realizar esta ação!")
					GFEA519CAN()
				EndIf
			EndIf

			oGFEComment:destroy(oGFEComment)
		EndIf
	EndIf

Return

Static Function RelCheck(lEnd,WnRel,cString,cTamanho,cPrograma,cNrMov,cPtoCtr)
	Local cabec1,cabec2
	Local cRodaTxt := oemtoansi("Rodapé")
	Local nInd
	Local nTipo

	nInd	:= 0
	Li 	   	:= 80
	M_PAG 	:= 1	// Inicializa os codigos de caracter Comprimido da impressora ³
	nTipo 	:= 15	// Monta os Cabecalhos                                        ³

	dbSelectArea("GVF")
	GVF->( dbSetOrder(1) ) // GVF_FILIAL + GVF_CDPTCT

	cabec1 := "Data: " + DToC(DDATABASE) + "  Hora: " + Substr(Time(), 1,5)
	cabec2 := "Nr Movto:	"+ cNrMov + "	 Pto Controle: " + POSICIONE("GVF",1,xFilial("GVF")+cPtoCtr,"GVF_DSPTCT")

	If GVF->( dbSeek(xFilial("GVF") + cPtoCtr ) )
		dbSelectArea("GVH")
		GVH->( dbSetOrder(2) )
		// GVH - INDICE 1 - GVH_CDPERG + GVH_CDPTCT
		// GVH - INDICE 2 - GVH_CDPTCT + GVH_CDPERG
		If GVH->( dbSeek(xFilial("GVH") + GVF->GVF_CDPTCT ) )
			While GVH->( !Eof() ) .And. GVH->GVH_FILIAL == xFilial("GVH") .And. GVH->GVH_CDPTCT == GVF->GVF_CDPTCT

				If Li > 60
					Cabec("Checklist", cabec1, cabec2, cPrograma, cTamanho, 15)
				EndIf

				@ Li,00 PSAY GVH->GVH_CDPERG  + " - "
				@ Li,09 PSAY POSICIONE("GVG",1,XFILIAL("GVG")+GVH->GVH_CDPERG,"GVG_DSPERG")

				Li++

				@ Li,00 PSAY "( ) Sim  ( ) Não"

				Li++

				@ Li,00 PSAY "Observações: "

				Li++

				nInd++
				Li++

				GVH->( dbSkip() )
			EndDo
		EndIf
	EndIf

	If Li != 80
		Roda(nInd,cRodaTxt,cTamanho)
	EndIf

	Set Device to Screen

	If aReturn[5] = 1
		Set Printer To
		dbCommitAll()
		OurSpool(wnrel)
	Endif

	MS_FLUSH()
Return

Function GFEA519REA()

	If GX3->GX3_SIT == "5"
		// Para “Reabrir” marcar o campo GX3_SIT como “2=Movimentado”
		// Atualiza GX3 da memoria
		RecLock(cAliGX3,.F.)
		(cAliGX3)->GX3_SIT := "2"
		(cAliGX3)->GX3_SIT2		:= GetStrCbox(GetSx3Inf("GX3_SIT")[2],GX3->GX3_SIT)
		MsUnlock(cAliGX3)

		RecLock("GX3",.F.)
		GX3->GX3_SIT := "2"
		MsUnlock("GX3")

		dbSelectArea("GX4")
		GX4->( dbSetOrder(4) )
		GX4->( dbSeek(xFilial("GX4") + GX3->GX3_NRMOV + "ZZZZZZZZ",.T.) )
		// Posicionar no ultimo registro
		GX4->( dbSkip(-1) )
		While !GX4->( Eof() ) .And. GX4->GX4_FILIAL == xFilial("GX4") .And. GX4->GX4_NRMOV == GX3->GX3_NRMOV
			// Valores Iniciais
			RecLock("GX4",.F.)
			GX4->GX4_SIT 		:= "1"
			GX4->GX4_DTSAI	:= CTOD("  /  /    ")
			MsUnlock("GX4")

			GX4->( dbSkip() )
		EndDo
	Else
		MsgAlert("Somente movimentos Cancelados podem ser reabertos.", "Aviso")
	EndIf

	oBrwGX3:Refresh()

Return

Function GFEA519RGK()// Remove da fila do endereçamento
	Local cCdEnd := GVK->GVK_CDENDE
	Local cSeqAtual := GVK->GVK_SEQ
	Local nTam := TamSx3("GVK_SEQ")[1]

	RecLock("GVK", .F.)
	dbDelete()
	MsUnlock("GVK")
	dbSelectArea("GVK")
	GVK->( dbSetOrder(1) )
	GVK->( dbSeek(xFilial("GVK") + cCdEnd))
	While !GVK->(Eof()) .And. xFilial("GVK") + cCdEnd == GVK->(GVK_FILIAL+GVK_CDENDE)
		If Val(GVK->GVK_SEQ) != 1 .And. cSeqAtual < GVK->GVK_SEQ
			RecLock("GVK",.F.)
			GVK->GVK_SEQ := StrZero(Val(GVK->GVK_SEQ)-1,nTam)
			MsUnLock("GVK")
		EndIf
		GVK->(dbSkip())
	EndDo
Return

Function GFEA519GX9(oModelGX9)//Validação da linhas dos unitizadores informados
	Local aAreaGX9 := GX9->(GetArea())
	Local cCDUnit  := oModelGX9:GetValue("GX9_CDUNIT")
	Local nLineGX9 := oModelGX9:GetLine()
	Local nCont

	If !Empty(cCDUnit) .And. Empty(oModelGX9:GetValue("GX9_IDUNIT"))
		DbSelectArea("GUG")
		GUG->(dbSetOrder(1))
		If GUG->(dbSeek(xFilial("GUG") + cCDUnit))
			If GUG->GUG_IDENT == "3"
				Help(,,"HELP",,"A identificação do unitizador é obrigatória.",1,0)
				Return .F.
			EndIf
		EndIf
	EndIf

	For nCont := 1 To oModelGX9:Length()
		oModelGX9:GoLine(nCont)
		If !oModelGX9:IsDeleted() .And. nCont != nLineGX9
			If FwFldGet("GX9_CDUNIT",nCont) == FwFldGet("GX9_CDUNIT",nLineGX9)
				Help( ,, 'HELP',, "Unitizador informado já existe para esta movimentação.", 1, 0)
				RestArea(aAreaGX9)
				Return .F.
			EndIf
		EndIf
	Next nCont

Return .T.

Function GFEA519UNT()
	Local oModel 	:= FwModelActive()
	Local oModGX9 := oModel:GetModel("GFEA519_GX9")
	Local cCDUnit := oModGX9:GetValue("GX9_CDUNIT")

	If !Empty(cCDUnit)
		DbSelectArea("GUG")
		GUG->(dbSetOrder(1))
		If GUG->(dbSeek(xFilial("GUG") + cCDUnit))
			If GUG->GUG_IDENT == "1"
				Return .F.
			EndIf
		EndIf
	EndIf
Return .T.

//Adiciona um css a um css(FWGetCSS) em string
Function AddCss(cCssOrigem,cCssAdd)
	Local cTCss := cCssOrigem
	Local nStart := At("{",cTCss)
	Local nFinish := Rat(";",cCssAdd)
	Local aTags := {}
	Local nX
	Local cTmpAdd
	Local cReturn := ""
	cTCss := StrTran(cTCss,CHR(09),'')
	If nFinish > 0 .And. Empty(AllTrim(SubStr(cCssAdd,nFinish+1)))
		cTmpAdd := STUFF(cCssAdd,nFinish,1," ")
	Else
		cTmpAdd := cCssAdd
	EndIf

	nFinish := 1
	While nStart > 0
		nX := nStart +1
		While SubStr(cTCss,nX,1) != "}"
			nX++
		EndDo
		aAdd(aTags,{SubStr(cTCss,nFinish,nStart-nFinish),CHR(09)+cTmpAdd + ";" + SubStr(cTCss,nStart +1,nX-1-nStart)})
		cTCss := STUFF(cTCss, nStart, 1, "|")
		nStart := At("{",cTCss)
		nFinish := At("}",cTCss)
		cTCss := STUFF(cTCss, nFinish, 1, "|")
		nFinish++
	EndDo

	For nX := 1 To Len(aTags)
		cReturn += aTags[nX][1] + "{" + aTags[nX][2] + "}"
	Next nX
	cCssOrigem := cReturn
Return cReturn

Static Function DelTabFilho(cTab, oModel)
	dbSelectArea(cTab)
	dbSetOrder(1)
	dbSeek(xFilial(cTab)+oModel:GetValue("GFEA519_GX3","GX3_NRMOV"))
	While !Eof().AND.;
	&(cTab + "->" + cTab + "_FILIAL") == xFilial("GX3").AND.;
	&(cTab + "->" + cTab + "_NRMOV") == oModel:getValue("GFEA519_GX3","GX3_NRMOV")
		RecLock(cTab,.F.)
		dbDelete()
		MsUnlock(cTab)

		dbSelectArea(cTab)
		dbSkip()
	EndDo

Return .T.

Function GFEA519VTA()
	Local lRet := .T. 
	Local cAliasGVP := GetNextAlias()
	Local cQuery := ""
	Local cQuery2 := ""
	Local nJ := 0
	Local aGrpUsr 	:= UsrRetGrp() //Grupos do qual o usuário faz parte.
	Local aPontos 	:= {}
	Local aValores := {}
	
	For nJ := 1 to Len(aGrpUsr)
		If nJ == 1
			cQuery2 += "'" + aGrpUsr[nJ] + "'"
		Else
			cQuery2 += ", '" + aGrpUsr[nJ] + "'"
		EndIf
	Next nJ

	cQuery := " SELECT GVP.GVP_CDPTCT, GVF.GVF_DSPTCT "
	cQuery += " FROM "+RetSQLName("GVP")+" GVP "
	cQuery += " INNER JOIN "+RetSQLName("GVF")+" GVF ON (GVP.GVP_CDPTCT = GVF.GVF_CDPTCT) "
	cQuery += " WHERE GVP.D_E_L_E_T_ = ' ' AND GVF.D_E_L_E_T_ = ' ' "
	cQuery += " AND ( GVP.GVP_CDUSUR = '" + s_RetCodUsr + "'"
	If Len(aGrpUsr) > 0 .And. GFXCP12123("GVP_GRPUSU")
		cQuery += "OR GVP.GVP_GRPUSU IN ( " + cQuery2 + " ) "
	EndIf
	cQuery += ") GROUP BY GVP.GVP_CDPTCT, GVF.GVF_DSPTCT "
	cQuery += "  ORDER BY GVF.GVF_DSPTCT  "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasGVP, .F., .T.)

	While (cAliasGVP)->( !Eof() ) .And. lRet
		aAdd(aPontos,AllTrim((cAliasGVP)->GVF_DSPTCT))
		aAdd(aValores,(cAliasGVP)->GVP_CDPTCT)
		(cAliasGVP)->( dbSkip() )
	EndDo
	(cAliasGVP)->( dbCloseArea() )

	If Len(aPontos) == 0
		lRet := .F.
		HELP(,,'HELP',,'Não existe nenhum ponto de controle vinculado ao seu usuário ou a filial logada.',1,0)
	EndIF	
	
Return lRet
