#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GFEA523.CH"


// Códigos de mensagens padronizadas
#DEFINE GFEA523001 "GFEA523001"
#DEFINE GFEA523002 "GFEA523002"
#DEFINE GFEA523003 "GFEA523003"
#DEFINE GFEA523004 "GFEA523004"
#DEFINE GFEA523005 "GFEA523005"
#DEFINE GFEA523006 "GFEA523006"
#DEFINE GFEA523007 "GFEA523007"
#DEFINE GFEA523008 "GFEA523008"
#DEFINE GFEA523009 "GFEA523009"


//-------------------------------------------------------------------
//Inclusão Pátios 12.1.4
/*{Protheus.doc} GFEA523
@author Siegklenes.beulke
@since 16/09/2013
@version 1.0		
@description
Operar Ponto de Controle	
*/
// SONARQUBE - CA1003: Uso não permitido de chamada de API em LOOP

Static s_GFEA5231 := ExistBlock("GFEA5231")

Function GFEA523()
	Local aCoors := FWGetDialogSize(oMainWnd)
	Local nI := 0
	Local aRet := {}
	Private oFWLayer, oPnlFilters, oPnlBrowses
	Private oPnlVeiculos 
	Private oPnlEnderecos
	Private oPnlBtnVeic
	Private oPnlBtnEnd
	Private oDlgOPC, oBtnPadrao, oBtnInstr, cPlaca, oPanelEntr
	Private aLMostrarDefault := {.F., .T., .T. }
	Private aLMostrar		 := {.F., .T., .T. }
	Private cCodUsr 		 := RetCodUsr() //Código usuario
	Private aGrpUsr 		 := UsrRetGrp() //Grupos do qual o usuário faz parte.
	Private aPontos 		 := {} //
	Private aValores 		 := {}
	Private aPlcs 			 := {} 
	Private cPtCtSel 		 := "1" //Ponto de controle selecionado
	Private cAliasVeic
	Private cAliasEnd 
	Private oFWLayerPri
	Private oPanelSair
	Private oBrowse
	Private oBrowse2
	Private aAlturas	:= {0.0,0.0,0.0,0.0}
	Private cFilAtu := cFilAnt
	Private cFillog := cFilAnt
	// Nao alterar a ordem das linhas, mas sim a coluna ORDEM
	// 					   { DESCRICAO               , FUNCAO              , OBJ, HABILITAR, ORDEM }
	Private aMenuVeic := {;
					/*01*/ {"1. Entrada"			 , {|| MNU1_Click(01) },    , .F.      , 1},;
					/*02*/ {"2. Endereçar"			 , {|| MNU1_Click(02) },    , .F.      , 2},;
					/*03*/ {"3. Check-List"			 , {|| MNU1_Click(03) },    , .T.      , 3},;
					/*04*/ {"4. Doc Carga"			 , {|| MNU1_Click(04) },    , .T.      , 4},;				
					/*05*/ {"7. Pesagem"			 , {|| MNU1_Click(06) },    , .F.      , 7},;
					/*06*/ {"8. Hodômetro"			 , {|| MNU1_Click(11) },    , .T.      , 8},;
					/*07*/ {"9. Dados Complementares", {|| MNU1_Click(12) },    , .T.      , 9},;
					/*08*/ {"10. Concluir"			 , {|| MNU1_Click(07) },    , .F.      , 10},;
					/*09*/ {"Retornar"				 , {|| MNU1_Click(08) },    , .F.      , 14},;
					/*10*/ {"Resumo Pto. Controle"	 , {|| MNU1_Click(09) },    , .T.      , 15},;
					/*11*/ {"Imprimir Checklist"	 , {|| MNU1_Click(10) },    , .T.      , 16},;
					/*12*/ {"6. Tara"				 , {|| MNU1_Click(05) },    , .T.      , 6},;
					/*13*/ {"Avaliar Reprovação"	 , {|| MNU1_Click(13) },    , .F.      , 13},;
					/*15*/ {"Ocorrência"			 , {|| MNU1_Click(15) },    , .F.      , 12},;
					/*16*/ {"5. Qtd Doc Carga"		 , {|| MNU1_Click(16) },    , .F.      , 5},;
					/*17*/ {"Unitizadores"			 , {|| MNU1_Click(17) },    , .F.      , 11},;
					/*18*/ {"Ver agendamentos"		 , {|| MNU1_Click(18) },    , .F.      , 17};
	}

	// 			{ DESCRICAO , FUNCAO , OBJ , HABILITAR , ORDEM }
	Private aMenuEnder := { {"1. Chegada"				, {|| MNU2_Click(2) }, ,.F.,1},;
							{"2. Início Carga/Descarga" , {|| MNU2_Click(3) }, ,.F.,2},;
							{"3. Fim Carga /Descarga"	, {|| MNU2_Click(4) }, ,.F.,3},;
							{"4. Liberação"				, {|| MNU2_Click(5) }, ,.F.,4},;
							{"5. Saída"					, {|| MNU2_Click(6) }, ,.F.,5},;
							{"Trocar Endereço"			, {|| MNU2_Click(7) }, ,.T.,6},;
							{"Desfazer Endereçamento"	, {|| MNU2_Click(8) }, ,.T.,7};
						}
	Private aSitGX3cBox	:= STRToKArr(Posicione("SX3",2,"GX3_SIT","X3CBOX()"),";")
	Private aSitGVDcBox	:= {"1=Ocupado","2=Livre"}
	Private aSitGX4cBox	:= StrToKArr(Posicione("SX3",2,"GX4_SIT","X3CBOX()"),";")
	//Private de gfe519/model
	Private aOper := {'',''} 
	Private cOpAgen := "" 
	Private aAgend  := {}
	//Privadas de 519b
	Private _cMov
	Private _cOper    
	Private _cSeq     
	Private _cPtCt    
	Private _lNEnd
	Private _lNLib
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
	Private aStruEnd
	Private aStruVei
	Private s_GFEA5232 := ExistBlock("GFEA5232")

	If !GFECheckGX4()
		Return .F.
	EndIF
	
	If ! VldAberturaTela()
		Return Nil
	EndIf
	
	If s_GFEA5232
		aRet := ExecBlock("GFEA5232", .F., .F., {})   
		
		For nI := 1 To Len(aRet)
			aAdd(aMenuVeic,{aRet[nI][1],aRet[nI][2], ,.F.,Len(aMenuVeic) + 1})
		Next nI
	EndIF
	
	Define MsDialog oDlgOPC Title "Operação de Ponto de Controle" From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
	
	oDlgOPC:Activate(,,,.T.,,,{|| CriaTela() })
	cfilant := cFilAtu 
	GFEDelTab(cAliasVeic)
	GFEDelTab(cAliasEnd)
	
Return Nil


//////////////////////////////////////////////////////////////////
//
// Funções relacionadas a interfaces e eventos
//
//////////////////////////////////////////////////////////////////
Static Function CriaTela()
	Local oCombo, oPanel, oBtnTroca, oBtnEntVei, oBtnAplicar, oBtnCons, oBtnLimp, oBtnProc
	Local oGet
	Local lEnderecamento := HasEnderecamento()
	Local lPontos 		 := (Len(aPontos)>1)

	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDlgOPC,.F.)

	oFWLayer:AddLine('LINE_ALL',100,.F.)
	oFWLayer:AddCollumn('COL_LEFT',22,.T.,'LINE_ALL')
	oFWLayer:AddWindow('COL_LEFT', 'Win_left', 'Opções', 100, .F., .F.,{|| },'LINE_ALL',{|| })
	oFWLayer:AddCollumn('COL_RIGHT',78,.T.,'LINE_ALL')

	oPnlFilters := oFWLayer:getWinPanel('COL_LEFT', 'Win_left','LINE_ALL')
	oPnlBrowses := oFWLayer:GetColPanel('COL_RIGHT', 'LINE_ALL')

	MontaPaineis()

	If !lEnderecamento
		oPnlEnderecos:Hide()
		oPnlBtnEnd:Hide()
	EndIf

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

	oPanelSair := TPanel():New(0,60,,oPnlFilters,,,,,RGB(239,243,247),60,10,,)
	oPanelSair:Align := CONTROL_ALIGN_BOTTOM

	oPanel := TPanel():New(0,60,,oPnlFilters,,,,,RGB(239,243,247),20,10,,)
	oPanel:Align := CONTROL_ALIGN_BOTTOM

	oQuit := TButton():New(0, 0, "Sair", oPanelSair, {|| oDlgOPC:End() }, 23, 10, , )
	oQuit:Align := CONTROL_ALIGN_RIGHT
	oQuit:SetColor(RGB(002,070,112),)

	// ----- Combo Pontos de Controle + Botão trocar
	If lPontos // Quando possui mais de um ponto de controle
		oPanel := TPanel():New(0,0,,oPnlFilters,,,,,RGB(239,243,247),100,15,,)
		oPanel:Align := CONTROL_ALIGN_TOP

		oCombo := TComboBox():New(0,0, {|u|If(PCount()>0,cPtCtSel:=u,cPtCtSel)},aPontos,100,10,oPanel,,/*bChange,bValid,nClrBack,nClrText,lPixel,oFont,,,bWhen,,,,,cReadVar,cLabelText,nLabelPos,oLabelFont,nLabelColor*/)
		oCombo:Align := CONTROL_ALIGN_ALLCLIENT

		oPanel := TPanel():New(0,60,,oPanel,,,,,RGB(239,243,247),25,10,,)
		oPanel:Align := CONTROL_ALIGN_RIGHT

		oBtnTroca := TButton():New(0,2, "Trocar", oPanel, {|| BtnTrocar_Click() },23,10,,/*[oFont]*/,,.T.,,,,/*[bWhen]*/)
	EndIf

	// ----- Botão Entrada Veículo
	oPanelEntr := TPanel():New(0,60,,oPnlFilters,,,,,RGB(239,243,247),100,20,,)
	oPanelEntr:Align := CONTROL_ALIGN_TOP

	oFont := TFont():New ("Tahoma", , -13, , .T., , , , , .F., .F. )
	oBtnEntVei := TButton():New(0,0, "Entrada Veículo", oPanelEntr, {|| BtnVeiculo_523() }, 20, 10,,oFont,, .T.,,,,/*[bWhen]*/)
	oBtnEntVei:Align := CONTROL_ALIGN_ALLCLIENT

	oSay := TSay():New (005, 0, {|| "" }, oBtnEntVei, , oFont, , , , .T., CLR_BLUE, , Int(oBtnEntVei:NCLIENTHEIGHT/4)-7,Int(oBtnEntVei:NCLIENTHEIGHT/4)-7, ,,,,, .T. )
	oSay:Align := CONTROL_ALIGN_TOP
	oSay:lTransparent := .T.

	oImg := TBitmap():New(0,0,10+Int(oBtnEntVei:NCLIENTHEIGHT/4),10,"CARGA",/*[cBmpFile]*/,.T.,oBtnEntVei,/*[bLClicked]*/,/*[bRClicked]*/,/*[lScroll]*/,/*[lStretch]*/,/*[oCursor]*/,,,/*[bWhen]*/,.F./*[lPixel]*/,/*[bValid]*/) 
	oImg:Align := CONTROL_ALIGN_RIGHT

	If CanEntradaVeiculo()
		oPanelEntr:Show()
	Else
		oPanelEntr:Hide()
	EndIf

	// ----- Margem
	oPanel := TPanel():New(0,60,,oPnlFilters,,,,,RGB(239,243,247),20,5,,)
	oPanel:Align := CONTROL_ALIGN_TOP

	// ---- Checkboxes
	oPanel := TPanel():New(0,60,,oPnlFilters,,,,,RGB(239,243,247),20,150,,)
	oPanel:Align := CONTROL_ALIGN_TOP

	oFont := TFont():New ("Arial", , -12, , .T., , , , , .F., .F. )
	oFontChk := TFont():New ("Tahoma", , -11, , .F., , , , , .F., .F. )

	oSay := TSay():New (005, 0, {|| "Mostrar" }, oPanel, , oFont, , , , .T., CLR_BLUE, , 100, 10, ,,,,, .T. )
	oSay:lTransparent := .T.

	oChk := TCheckBox():New( 020, 0, "Previstos", {|u| If(PCount()>0,aLMostrar[1]:=u,aLMostrar[1]) }, oPanel, 100,10,,{|| Checkbox_Click() },,/*[ bValid]*/,,,,.T.,"Marque para visualizar os veículos que não ainda chegaram ao ponto de controle",,/*[ bWhen]*/ )

	oChk := TCheckBox():New( 035, 0, "Sem entrada registrada", {|u| If(PCount()>0,aLMostrar[2]:=u,aLMostrar[2]) }, oPanel, 100,10,,{|| Checkbox_Click() },,/*[bValid]*/,,,,.T.,"Marque para visualizar os veículos que ainda não tiveram sua entrada registrada no ponto de controle",, /*[ bWhen]*/ )

	oChk := TCheckBox():New( 050, 0, "Em andamento", {|u| If(PCount()>0,aLMostrar[3]:=u,aLMostrar[3]) }, oPanel, 100,10,,{|| Checkbox_Click() },,/*[ bValid]*/,,,,.T.,"Marque para visualizar os veículos que estão no ponto de controle",,/*[ bWhen]*/)

	oBtnAplicar := TButton():New(070,00, "Aplicar", oPanel, {|| BtnAplicar_Click() }, 22, 10,,/*[oFont]*/,, .T.,,,,/*[bWhen]*/)

	oBtnPadrao := TButton():New(070,25, "Restaurar Padrão", oPanel, {|| BtnRestaurar_Click() }, 50, 10,,/*[oFont]*/,,.T.,,,,/*bWhen*/)
	oBtnPadrao:Disable()

	//Carregar dados
	aStru:= MontaStru()
	aStruVei := aStru[1][2]
	aStruEnd := aStru[2][2]

	// ---- Consulta de placas
	oSay := TSay():New (095, 0, {|| "Consultar placa" },oPanel,,oFont,,,,.T.,CLR_BLUE,,100,10,,,,,,.T.)
	oSay:lTransparent := .T.

	oSay := TSay():New (112, 0, {|| "Placa" },oPanel,,oFontChk,,,,.T.,RGB(0,74,119),RGB(239,243,247),15,10,,,,,,.T.)

	cPlaca 		:= Space(TamSX3('GU8_PLACA')[01])
	oGetPl 		:= TGet():New( 110,20,{|u| If( Pcount()>0, cPlaca:= u, cPlaca) },oPanel,90,010,PesqPict('GU8','GU8_PLACA'),,0,,,,,.T.,,,,,,,.F.,.F.,,cPlaca,,,,.T.  )
	oGetPl:bF3 	:= {|oGet| A523SXBPLC(oGet)}

	oBtnCons := TButton():New(125,00, "Filtrar", oPanel, {|| BtnConsultar_Click()() }, 30, 10,,/*[oFont]*/,, .T.,,,,/*[bWhen]*/)
	oBtnLimp := TButton():New(125,35, "Desfazer Filtro", oPanel, {|| BtnLimpar_Click() }, 40, 10,,/*[oFont]*/,, .T.,,,,)
	oBtnProc := TButton():New(125,80, "Procurar", oPanel, {|| A523PROCU(cPlaca)  }, 30, 10,,/*[oFont]*/,, .T.,,,,)

	oFont 	  := TFont():New ("Tahoma", , -11, , .T., , , , , .F., .F. )
	oBtnInstr := TButton():New(0, 0, "Instruções", oPanelSair, {|| ShowInstr() }, 30, 10, , )
	oBtnInstr:Align := CONTROL_ALIGN_LEFT

	// Mostra/Esconde Botao de Instrucoes
	GFEA523HSInstr()

	CursorWait()

	// ------- Browses
	oPnlBrowses:SetUpdatesEnabled(.F.)

	CriaBrwVeiculos()

	CriaBrwEnderecos()

	A523VEICBC()
	A523ENDBC()
	oPnlBrowses:SetUpdatesEnabled(.T.)

	BtnTrocar_Click()

	CursorArrow()

Return Nil

Static Function TelaEndereco(oModel,lRet)
	Private oDlgEnd

	Define MsDialog oDlgEnd Title "Endereçar Ponto de Controle" From 0,0 To 200, 500 Pixel
	COMP519GEND(oDlgEnd,oModel,.T.)
	oDlgEnd:Activate(,,,.T.,,,{|| EnchoiceBar(oDlgEnd,{|| If((lRet:=ValidaModel(oModel)),oDlgEnd:End(),Nil)}, {||oDlgEnd:End()},,)})
Return

// Carrega uma tela mvc para os modelos de documentos e checklist
Static Function CarregaMVCView(oModel,oStruct,cTitulo,cNameModel,aCoors,lField,lShowRes,nOperation,aButtons)
	Local nX
	Local oView 		:= FWFormView():New()
	Local oFWMVCWindow	:= FWMVCWindow():New()
	Default lField 	  	:= .F.
	Default lShowRes	:= .T.
	Default aButtons	:= {}
	Default nOperation	:= MODEL_OPERATION_UPDATE
	Default aCoors 	  	:= FWGetDialogSize(oMainWnd)

	oView:SetModel(oModel)
	oView:CreateHorizontalBox("MASTER", 100)

	If !lField
		oView:AddGrid(cNameModel, oStruct )
		oView:CreateFolder("IDFOLDER","MASTER")
		oView:AddSheet("IDFOLDER", "IDSHEET01", cTitulo)

		oView:CreateHorizontalBox("DETAILBG" , 100,,,"IDFOLDER","IDSHEET01")

		oView:SetOwnerView(cNameModel, "DETAILBG")
	Else
		oView:AddField(cNameModel, oStruct)
		oView:SetOwnerView(cNameModel, "MASTER")
	EndIf

	oView:SetCloseOnOk({|oView| lModified := oView:GetModel():lModify .And. oView:GetModel():VldData(), .T.})
	If lShowRes
		oView:SetAfterOkButton({|oView| GFEA519BRE(oView)})
	EndIf

	oView:EnableControlBar(.T.)
	oView:SetOperation(nOperation)
	oView:SetUseCursor(.F.)

	For nX := 1 to Len(aButtons)
		oView:AddUserButton(aButtons[nX][1],"MAGIC_BMP",aButtons[nX][2])
	Next nX

	oFWMVCWindow:SetUseControlBar(.T.)
	oFWMVCWindow:SetView(oView)
	oFWMVCWindow:SetCentered(.T.)
	oFWMVCWindow:SetPos(aCoors[1],aCoors[2])
	oFWMVCWindow:SetSize(aCoors[3],aCoors[4])
	oFWMVCWindow:SetTitle(cTitulo)
	oFWMVCWindow:Activate()
Return oFWMVCWindow

///////////////////////////
// Posicionamento do Browse
///////////////////////////
Static Function A523VEICBC()
	GX3->(dbSetOrder(1))
	GX3->(dbSeek((cAliasVeic)->GX4_FILIAL + (cAliasVeic)->GX4_NRMOV))

	GX4->(dbSetOrder(4))
	If GX4->(dbSeek((cAliasVeic)->GX4_FILIAL + (cAliasVeic)->GX4_NRMOV + (cAliasVeic)->GX4_SEQ + GetValCbPonto() ))
		cFilAnt := (cAliasVeic)->GX4_FILIAL
		A523VVMN()
	EndIf

Return

Static Function A523ENDBC()
	GX3->(dbSetOrder(1))
	GX3->(dbSeek((cAliasEnd)->GX4_FILIAL + (cAliasEnd)->GX4_NRMOV))

	GX4->(dbSetOrder(4))
	If GX4->(dbSeek((cAliasEnd)->GX4_FILIAL + (cAliasEnd)->GX4_NRMOV + (cAliasEnd)->GX4_SEQ + GetValCbPonto() ))	
		cFilAnt := (cAliasEnd)->GX4_FILIAL
		A523ENDVMN()
	EndIf
Return

Static Function A523VVMN()
	Local nX
	Local cAcaoRep
	Local nI          := 0
	Local nOpcs       := 0
	Local nNivelAtual := 1
	Local aRet        := {}
	Local aLMenu      := { .F.,;	//"1. Entrada"
						   .F.,;	//"2. Endereçar"
						   .T.,;	//"3. Check-List"
						   .T.,;	//"4. Doc Carga"				
						   .F.,;	//"7. Pesagem"
						   .F.,;	//"8. Hodômetro"
						   .T.,;	//"9. Dados Complementares"
						   .F.,;	//"10. Concluir"
						   .F.,;	//"Retornar"
						   .T.,;	//"Resumo Pto Controle"
						   .T.,;	//"Imprimir Checklist"
						   .T.,;	//"6. Tara"
						   .F.,;	//"Avaliar Reprovação"
						   .F.,;	//"Ocorrência"
						   .F.,;	//"5. Qtd doc carga"
						   .T.,;	//Unitizadores
						   .T.; 	//Ver agendamentos
						}

	If !Empty(GX4->GX4_DTSAI) // Quando a movimentação está REPROVADA no ponto de controle
		aLMenu := {;
					.F.,;//"1. Entrada"
					.F.,;//"2. Endereçar"
					.F.,;//"3. Check-List"
					.F.,;//"4. Doc Carga"				
					.F.,;//"7. Pesagem"
					.F.,;//"8. Hodômetro"
					.F.,;//"9. Dados Complementares"
					.F.,;//"10. Concluir"
					.F.,;//"Retornar"
					.T.,;//"Resumo Pto Controle"
					.F.,;//"Imprimir Checklist"
					.F.,;//"6. Tara"
					.F.,;//"Avaliar Reprovação"
					.F.,;//"Ocorrência"
					.F.,;//"5. Qtd doc carga"
					.F.,;//Unitizadores
					.F.; //Ver agendamentos
				}

		cAcaoRep := A523AcaoReprov()

		If cAcaoRep == "3"
			aLMenu[13] := .T. //"Avaliar Reprovação"
		ElseIf cAcaoRep == "1"
			aLMenu[14] := .T. //Ocorrência
		EndIf

	Else
		//Carrega as variáveis usadas na função que movimentará do model
		M->GX4_DTENTR := GX4->GX4_DTENTR
		M->GX4_HRENTR := GX4->GX4_HRENTR
		M->GX4_DTCHEN := GX4->GX4_DTCHEN
		M->GX4_HRCHEN := GX4->GX4_HRCHEN
		M->GX4_DTINCA := GX4->GX4_DTINCA
		M->GX4_HRINCA := GX4->GX4_HRINCA
		M->GX4_DTFICA := GX4->GX4_DTFICA
		M->GX4_HRFICA := GX4->GX4_HRFICA
		M->GX4_DTLIEN := GX4->GX4_DTLIEN
		M->GX4_HRLIEN := GX4->GX4_HRLIEN
		M->GX4_DTSAEN := GX4->GX4_DTSAEN
		M->GX4_HRSAEN := GX4->GX4_HRSAEN
		M->GX4_DTSAI  := GX4->GX4_DTSAI
		M->GX4_HRSAI  := GX4->GX4_HRSAI
		nNivelAtual   := ABS(COMP519NIVEL(.F.,,GX4->GX4_CDPTCT,,GX4->GX4_CDENDE))

		// Concluir
		If nNivelAtual == 9
			nNivelAtual := 8
		EndIf

		If nNivelAtual > 0 .And. nNivelAtual <= Len(aMenuVeic)
			aLMenu[nNivelAtual] := .T.
		EndIf

		If nNivelAtual == 0
			nNivelAtual := 1
		EndIf

		// "1. Entrada"
		aLMenu[1]	:= If((nNivelAtual == 1) .And. Empty(GX4->GX4_DTENTR),.T.,.F.)

		// "2. Endereçar"
		aLMenu[2]	:= If((nNivelAtual == 1) .And. HasEnderecamento() .And. !Empty(GX4->GX4_DTENTR) .And. (Empty(GX4->GX4_CDENDE) .Or. Empty(GX4->GX4_PRIORI)),.T.,.F.)

		// "3. Check-List"
		aLMenu[3]	:= !Empty(Posicione("GX5",1,GX4->GX4_FILIAL+GX4->GX4_NRMOV+GX4->GX4_CDPTCT,"GX5_NRMOV"))

		// "4. Doc Carga"
		aLMenu[4] 	:= !aLMenu[1] .And. Posicione("GVF",1,xFilial("GVF") + GX4->GX4_CDPTCT,"GVF_IDVIDC") == '1'

		// "6. Pesagem"
		aLMenu[5] 	:= !aLMenu[1] .And. (Posicione("GVF",1,xFilial("GVF") + GX4->GX4_CDPTCT,"GVF_IDPESO") $ '2;3' .and. Posicione("GVJ",2,xFilial("GVJ") + GX4->GX4_SEQ + GX4->GX4_CDPTCT  ,"GVJ_IDPESO") $ '0;2;3')	// 2 = Informar Peso

		// "8. Hodômetro"
		aLMenu[6] 	:= !aLMenu[1]

		// "9. Dados Complementares"
		aLMenu[7] 	:= !aLMenu[1] .And. (A523VCMPCOMP() != "")

		// "10. Concluir"
		aLMenu[8] 	:= If(((nNivelAtual == 6) .Or. ((nNivelAtual == 1) .And. !HasEnderecamento() .And. !Empty(GX4->GX4_DTENTR))),.T.,.F.)

		// "Voltar Ponto Anterior"
		aLMenu[9]	:= If(((Val(GX4->GX4_SEQ) > 1) .And. (GX4->GX4_SIT == "1")),.T.,.F.)

		// "7. Tara"
		aLMenu[12]	:= !aLMenu[1] .And. GFEA519BW2(GX4->GX4_CDPTCT)

		// "5. Qtd doc carga"
		aLMenu[15]	:= !aLMenu[1] .And. Posicione("GVF",1,xFilial("GVF") + GX4->GX4_CDPTCT,"GVF_IDQTDC") == '1'

		// "Unitizadores"
		aLMenu[16] 	:= !aLMenu[1]

		// "Ver agendamentos"
		aLMenu[17] 	:= !Empty(Posicione("GWV",4,GX4->GX4_FILIAL+GX4->GX4_NRMOV,"GWV_NRMOV"))
	EndIf

	If s_GFEA5232
		aRet  := ExecBlock("GFEA5232", .F., .F., {})

		nOpcs := Len(aRet)
		For nI := 1 To nOpcs
		 	aADD(aLMenu, Nil)
		Next nI
	EndIf

	// Resumo pto. controle
	aLMenu[10] := !Empty(GX4->GX4_DTSAI)

	For nX := 1 To Len(aMenuVeic)
		aMenuVeic[nX][3]:LACTIVE := aLMenu[nX]
		aMenuVeic[nX][3]:Refresh()
	Next nX
Return

Static Function A523ENDVMN()
	Local nX
	Local nQtdMenu    := 0
	Local nNivelAtual := 1 
	Local aLMenu      := {.F.,.F.,.F.,.F.,.F.,.F.,.F.}

	If !Empty(GX4->GX4_DTSAI)
		aLMenu := {.F.,.F.,.F.,.F.,.F.,.F.,.F.}
	Else
		//Carrega as variáveis usadas na função que movimentará do model
		M->GX4_DTENTR := GX4->GX4_DTENTR
		M->GX4_HRENTR := GX4->GX4_HRENTR
		M->GX4_DTCHEN := GX4->GX4_DTCHEN
		M->GX4_HRCHEN := GX4->GX4_HRCHEN
		M->GX4_DTINCA := GX4->GX4_DTINCA
		M->GX4_HRINCA := GX4->GX4_HRINCA
		M->GX4_DTFICA := GX4->GX4_DTFICA
		M->GX4_HRFICA := GX4->GX4_HRFICA
		M->GX4_DTLIEN := GX4->GX4_DTLIEN
		M->GX4_HRLIEN := GX4->GX4_HRLIEN
		M->GX4_DTSAEN := GX4->GX4_DTSAEN
		M->GX4_HRSAEN := GX4->GX4_HRSAEN
		M->GX4_DTSAI  := GX4->GX4_DTSAI
		M->GX4_HRSAI  := GX4->GX4_HRSAI
		nNivelAtual   := ABS(COMP519NIVEL(.F.,,GX4->GX4_CDPTCT,,GX4->GX4_CDENDE))

		If nNivelAtual > 0 .And. nNivelAtual <= Len(aMenuEnder)
			aLMenu[nNivelAtual] := .T.
		EndIf

		dbSelectArea("GVK")
		GVK->(dbSetOrder(2))

		aLMenu[1] := If((nNivelAtual == 1 .And. !Empty(GX4->GX4_CDENDE)),.T.,.F.)
		If aLMenu[2]
			aLMenu[2] := !GVK->( dbSeek(xFilial("GVK") + GX4->GX4_NRMOV + GX4->GX4_CDPTCT + GX4->GX4_SEQ) )
		EndIf
		If aLMenu[4]
			aLMenu[4] := !GVK->( dbSeek(xFilial("GVK") + GX4->GX4_NRMOV + GX4->GX4_CDPTCT + GX4->GX4_SEQ) )
		EndIf
		aLMenu[6] := !Empty(GX4->GX4_CDENDE) .And. Empty(GX4->GX4_DTCHEN)
		aLMenu[7] := !Empty(GX4->GX4_CDENDE)
	EndIf

	nQtdMenu := Len(aMenuEnder)
	For nX := 1 To nQtdMenu
		aMenuEnder[nX][3]:LACTIVE := aLMenu[nX]
		aMenuEnder[nX][3]:Refresh()
	Next nX	
Return

///////////////////////////
// Funções de Botões
///////////////////////////
Static Function MNU1_Click(nClick)
	Local nX
	Local nSX3
	Local oView
	Local wnrel
	Local aCoors
	Local oModel
	Local oStruct
	Local cString
	Local cTitulo
	Local aAreaGXA
	Local cTamanho
	Local aAreaGX4
	Local cPrograma
	Local aStructSX
	Local oFWMVCWindow
	Local nDocCarga 	:= 0
	Local cDesOper 		:= ""
	Local cRegAtual     := ""
	Local aLstCampos 	:= {} 
	Local lRet5233 		:= .F.
	Local lRet5235		:= .T.
	Local cNrMov 		:= (cAliasVeic)->GX4_NRMOV
	Local oStructX3		:= GFESeekSX():New()
	Local s_GFEA5233 	:= ExistBlock("GFEA5233")
	Local s_GFEA5235 	:= ExistBlock("GFEA5235")
	Local lGFEA5237		:= ExistBlock("GFEA5237")
	Local cMVAGRORI		:= SuperGetMV("MV_AGRORI",.F.,.F.)
	Local cMVSIGAAGR	:= SuperGetMV("MV_SIGAAGR",.F.,.F.)
	Local nRetPeso		:= 0

	Private aReturn 	:= { "", 1, "", 1, 2, 1, "", 1 }

	If !(cAliasVeic)->(Eof())
		A523VEICBC() // Posicionamento GX3/GX4

		_cMov   := GX3->GX3_NRMOV
		_cOper  := GX3->GX3_CDOPER
		_cSeq   := GX3->GX3_SEQ
		_cPtCt  := GetValCbPonto()
		cFilGX3	:= xFilial("GX3")
		cSeqGX4 := GX4->GX4_SEQ

		GFEA519BIN()

		If s_GFEA5235
			lRet5235 := ExecBlock("GFEA5235", .F., .F., {cFilGX3,_cMov,_cOper,_cSeq,_cPtCt,nClick,cSeqGX4})
		EndIF

		If lRet5235
			Do Case
				Case nClick == 1 .Or. nClick == 7 //Chegada ou concluir
					If nClick == 7 .and. (!Empty(Posicione("GX5",1,GX4->GX4_FILIAL+GX4->GX4_NRMOV+GX4->GX4_CDPTCT,"GX5_NRMOV"))) .and. Posicione("GX5",1,GX4->GX4_FILIAL+GX4->GX4_NRMOV+GX4->GX4_CDPTCT,"GX5_RESPOS") == "0"
						GFEMessage(5, GFEA523001, STR0001, STR0002)
						Return .F.
					EndIf

					If MovimentaEndereco(nClick)
						A523ENDBC()
						A523VEICBC()
						Reclock(cAliasVeic,.F.)
						Set Century Off // Ano Dois dígitos
						(cAliasVeic)->DTENTRADA 	:= (cAliasVeic)->DTENTRADA := DTOC(GX4->GX4_DTENTR) + " " + Transform(GX4->GX4_HRENTR,"@R 99:99")
						(cAliasVeic)->GX3_SIT 		:= GX3->GX3_SIT
						(cAliasVeic)->GX4_SIT 		:= GX4->GX4_SIT
						(cAliasVeic)->GX4_DTSAI 	:= GX4->GX4_DTSAI
						aAreaGX4 := GX4->(GetArea())
						(cAliasVeic)->GX4_SITDS 	:= GetSitDs()
						RestArea(aAreaGX4)
						Set Century On
						MsUnLock(cAliasVeic)
						oBrowse:Refresh()
						oBrowse2:Refresh()

						If s_GFEA5233 .And. nClick == 7
							lRet5233 := ExecBlock("GFEA5233", .F., .F., {GX3->GX3_FILIAL,_cMov,GX3->GX3_SIT,GX4->GX4_SIT})
						EndIF

						// Busca Proximo Ponto de Controle
						// 1="Não Avaliado" 2="Aprovado" 3="Reprovado"
						If GX4->GX4_SIT != '3' .And. !Empty(GX4->GX4_DTSAI)
							cNrMov := GX4->GX4_FILIAL+GX4->GX4_NRMOV
							cRegAtual := GX4->GX4_FILIAL+GX4->GX4_NRMOV+GX4->GX4_SEQ
							aAreaGX4 := GX4->(GetArea())
								GX4->(dbSetOrder(4))
								If GX4->(dbSeek(cRegAtual))
									GX4->(dbSkip())
									If GX4->GX4_FILIAL+GX4->GX4_NRMOV == cNrMov
										cAux := Posicione("GVF",1,xFilial("GVF") + GX4->GX4_CDPTCT,"GVF_DSPTCT")
										If cAux != ""
											GFEMessage(0, GFEA523002, GFEMsgFmt(STR0003,{{"[VAR01]",AllTrim(cAux)}}))
										EndIf
									EndIf
								EndIf
							RestArea(aAreaGX4)
						EndIf
						If nClick == 7
							A523PROC()
						EndIf
					EndIf

				Case nClick == 2 // Endereçar
					If MovimentaEndereco(nClick,1)
						BtnAplicar_Click()
					EndIf

				Case nClick == 3 //Check-List
					oModel := FWLoadModel("GFEA519B")

					oStruct:= FWFormStruct(2,"GX5")
					oStruct:RemoveField("GX5_NRMOV")
					oStruct:RemoveField("GX5_CDPTCT")
					oStruct:RemoveField("GX5_DSPTCT")
					oStruct:RemoveField("GX5_SEQ")
					CarregaMVCView(oModel,oStruct,"Check-List","GFE519BGX5")

				Case nClick == 4 //Documentos de Carga
					oModel := FWLoadModel("GFEA519B")

					oStruct:= FWFormStruct(2,"GXA")
					oStruct:RemoveField("GXA_NRMOV" )
					oStruct:RemoveField("GXA_CDPTCT")
					oStruct:RemoveField("GXA_SEQ")
					CarregaMVCView(oModel,oStruct,"Documentos de Carga","GFE519BGXA",,,,,{{"Doc. Relac.",{|oView|GFE519REL(oView)}}})

				Case nClick == 6 // Pesagem
					If lGFEA5237
						nRetPeso := 0
						
						nRetPeso := ExecBlock("GFEA5237", .F., .F., {GX4->GX4_FILIAL, _cMov, _cPtCt, cPlaca, GX4->GX4_QTPESO})

						If nRetPeso <> 0
							RecLock("GX4", .F.)
								GX4->GX4_QTPESO := nRetPeso
							GX4->(MsUnlock())
						EndIf
					Else 
						If cMVAGRORI .and. cMVSIGAAGR .and. FindFunction("AX500PRFUN")
							AX500PRFUN("PESAGEM")
						Else
							oModel := FWLoadModel("GFEA519B")
							oStruct:= FWFormStruct(2,"GX4")
							For nX := Len(oStruct:AFIELDS) to 1 Step -1
								If !(oStruct:AFIELDS[nX][1] $ "GX4_QTPESO" )
									oStruct:RemoveField(oStruct:AFIELDS[nX][1])
								EndIf
							Next nX
							oStruct:AddGroup("Peso" , "Informações de Pesagem", "", 2)
							oStruct:SetProperty("GX4_QTPESO", MVC_VIEW_GROUP_NUMBER, "Peso")
							CarregaMVCView(oModel,oStruct,"Pesagem","GFEA519B_GX4",{0,0,175,450},.T.)
						EndIf
					EndIf
					
				Case nClick == 5 // Informa a Tara
					oModel := FWLoadModel("GFEA519B")
					oStruct:= FWFormStruct(2,"GX4")
					For nX := Len(oStruct:AFIELDS) to 1 Step -1
						If !(oStruct:AFIELDS[nX][1] $ "GX4_VLTARA" )
							oStruct:RemoveField(oStruct:AFIELDS[nX][1])
						EndIf
					Next nX
					oStruct:AddGroup("Peso" , "Informações da Tara", "", 2)
					oStruct:SetProperty("GX4_VLTARA", MVC_VIEW_GROUP_NUMBER, "Peso")
					oStruct:SetProperty("GX4_VLTARA", MVC_VIEW_CANCHANGE, .T. )
					CarregaMVCView(oModel,oStruct,"Pesagem","GFEA519B_GX4",{0,0,175,450},.T.,.F.)

				Case nClick == 8
					If GFEA519BRP() // Retorna ponto de controle
						dbSelectArea(cAliasVeic)
						RecLock(cAliasVeic,.F.)
						dbDelete()
						msUnlock(cAliasVeic)
						oBrowse:Refresh()
					EndIf

				Case nClick == 9 //Resumo Pto controle
					//Faz um carregamento do model para ativar o array de valid dos campos
					oModel:= FwLoadModel("GFEA519B")
					oModel:SetOperation( 4 )
					oModel:Activate()
					oModel:LMODIFY := .T.
					oModel:VldData()
					GFEA519BRE(,.F.)
					FreeObj(oModel)

				Case nClick == 10
					cString 	:= "GVH"
					cTitulo  	:= "Impressão de Checklist"
					cPrograma	:= "CHECKLIST"
					cTamanho	:= "M"

					dbSelectArea("GVH")
					GVH->( dbSetOrder(2) )
					If !GVH->( dbSeek(xFilial("GVH") + GX4->GX4_CDPTCT ) )
						MsgAlert('Não existe Perguntas (Checklist) no Ponto de Controle do Movimento.','Aviso')
					Else
						wnrel := SetPrint(cString,cPrograma,"",@cTitulo,"", "", "",.F.,.F.,.F.,cTamanho,,.F.)

						If nLastkey == 27
						 	Return
						EndIf

						SetDefault(aReturn,cString)

						If nLastkey == 27
						 	Return
						EndIf

						RptStatus({|lEnd| RelCheck(@lEnd,wnRel,cString,cTamanho,cPrograma,GX4->GX4_NRMOV,GX4->GX4_CDPTCT)},cTitulo)
					EndIf

				Case nClick == 11 // Hodometro
					oModel := FWLoadModel("GFEA519B")
					oStruct:= FWFormStruct(2,"GX4")
					For nX := Len(oStruct:AFIELDS) to 1 Step -1
						If !(oStruct:AFIELDS[nX][1] $ "GX4_VLHODO" )
							oStruct:RemoveField(oStruct:AFIELDS[nX][1])
						EndIf
					Next nX

					oStruct:AddGroup("Hodo" , "Informações do Hodômetro", "", 2)
					oStruct:SetProperty("GX4_VLHODO", MVC_VIEW_GROUP_NUMBER, "Hodo")

					CarregaMVCView(oModel,oStruct,"Pesagem","GFEA519B_GX4",{0,0,175,450},.T.,.F.)

				Case nClick == 12 // Dados complementares
					cDesOper := Posicione("GVC",1,GX3->GX3_FILIAL + GX3->GX3_CDOPER + GX3->GX3_SEQ,"GVC_DSOPER")
					If Empty(cDesOper)
						GVC->(dbSetOrder(01))
						GVC->(dbSeek(xFilial("GVC")+GX3->GX3_CDOPER))
						cDesOper := GVC->GVC_DSOPER
					EndIf

					// INICIO - Retira campos da tela GFEA519B
					oModel  := FWLoadModel("GFEA519B")
					oStruct := oModel:GetModel("GFEA519B_GX4"):GetStruct()
					oStruct:DeActivate()
					oStruct:AddField("Nr Mov"		, "", "GX3_NRMOV" ,	"C", 08, 0, /*bvalid*/,{|| .F. } ,/*avalues*/ ,/*lobrigat*/,{|| GX3->GX3_NRMOV } ,/*lkey*/,/*lnoipd*/,.T. )
					oStruct:AddField("Cod. Operação", "", "GX3_CDOPER",	"C", 16, 0, /*bvalid*/,{|| .F. } ,/*avalues*/ ,/*lobrigat*/,{|| GX3->GX3_CDOPER },/*lkey*/,/*lnoipd*/,.T. )
					oStruct:AddField("Sequência"	, "", "GX3_SEQ"   ,	"C", 03, 0, /*bvalid*/,{|| .F. } ,/*avalues*/ ,/*lobrigat*/,{|| GX3->GX3_SEQ }   ,/*lkey*/,/*lnoipd*/,.T. )
					oStruct:AddField("Des. Operação", "", "DSOPER"    ,	"C", 50, 0, /*bvalid*/,{|| .F. } ,/*avalues*/ ,/*lobrigat*/,{|| cDesOper }       ,/*lkey*/,/*lnoipd*/,.T. )
					oStruct:Activate()

					aStructSX := FWFormStruct(3,"GX4")[1] //Todos os Campos
					For nSX3 := 1 to Len(aStructSX)
						oStructX3:SeekX3(aStructSX[nSX3,3],.T.,.F.,.F.)
						If GetSx3Cache(aStructSX[nSX3,3],"X3_PROPRI") == "U"
							aAdd(aLstCampos,AllTrim(aStructSX[nSX3,3]))
					   	EndIf
					Next nSX3
					oStructX3:Destroy()

					// Pega Estrutura do GX4 para a VIEW
					oStruct:= FWFormStruct(2,"GX4")
					For nX := Len(oStruct:AFIELDS) to 1 Step -1
						If aScan(aLstCampos,{|x| x == oStruct:AFIELDS[nX][1]}) == 0
							oStruct:RemoveField(oStruct:AFIELDS[nX][1])
						EndIf
					Next nX

					// Cria GRUPO
					oStruct:AddGroup("Movimentacao", "Movimentação", "", 2)
					oStruct:AddField("GX3_NRMOV" , "1", "Nr Mov"	   , "", , "C",,,,,,,/* ACOMBOVALUES */,,,.T.)
					oStruct:AddField("GX3_CDOPER", "2", "Cod. Operação", "", , "C",,,,,,,,,,.T.)
					oStruct:AddField("GX3_SEQ"	 , "3", "Sequência"	   , "", , "C",,,,,,,,,,.T.)
					oStruct:AddField("DSOPER"	 , "4", "Des. Operação", "", , "C",,,,,,,,,,.T.)

					// Associa campo ao Grupo
					oStruct:SetProperty("GX3_NRMOV" , MVC_VIEW_GROUP_NUMBER, "Movimentacao")
					oStruct:SetProperty("GX3_CDOPER", MVC_VIEW_GROUP_NUMBER, "Movimentacao")
					oStruct:SetProperty("GX3_SEQ"   , MVC_VIEW_GROUP_NUMBER, "Movimentacao")
					oStruct:SetProperty("DSOPER"    , MVC_VIEW_GROUP_NUMBER, "Movimentacao")

					// Cria GRUPO
					oStruct:AddGroup("Dados", "Dados Complementares", "", 2)

					For nX := 1 to Len(aLstCampos)
					    oStruct:SetProperty(aLstCampos[nX], MVC_VIEW_GROUP_NUMBER, "Dados")
				   	Next nX

					// Carregar somente campos X3_PROPI == "U" da tabela SX3 -- Campos Personalizaveis pelo usuario
					CarregaMVCView(oModel,oStruct,"Pesagem","GFEA519B_GX4",,.T.,.F.)

				Case nClick == 13	// 13-Avaliar Reprovação
					If GFEA519BAR()
						A523PROC()
					EndIf

				Case nClick == 15	// 15-Ocorrência
					//Abre ocorrência
					If _aAtuPC[1] != GX4->GX4_CDPTCT .Or. _aAtuPC[2] != GX4->GX4_SEQ
						GFEMessage(5, GFEA523003, GFEMsgFmt(STR0004,{{"[VAR01]", cValToChar(_aAtuPC[1])}}), STR0005)
 						Return .F.
					EndIf

					If !Empty(cString := GFEA032PTO(,GX4->GX4_NRMOV,GX4->GX4_CDPTCT))
						GFEMessage(5, GFEA523004, GFEMsgFmt(STR0006,{{"[VAR01]", (" " + CRLF)},{"[VAR02]",AllTrim(cString)}}), STR0007)
						Return .F.
					EndIf

					oModel:= FwLoadModel("GFEA032")
					oView := FWLoadView("GFEA032")
					aCoors := FWGetDialogSize(oMainWnd)

					oStruct := oView:GetViewStruct("GFEA032_GWD")

					oView:SetModel(oModel)
					oStruct:SetProperty("GWD_DTOCOR", MVC_VIEW_CANCHANGE, .F.)
					oStruct:SetProperty("GWD_HROCOR", MVC_VIEW_CANCHANGE, .F.)
					oView:EnableControlBar(.T.)
					oView:SetOperation(MODEL_OPERATION_INSERT)
					oView:SetUseCursor(.F.)
					oView:SetCloseOnOk({|| .T.})
					oView:oModel:SetActivate({|oModel|A523AbreCad(oModel,oView)})

					oFWMVCWindow := FWMVCWindow():New()
					oFWMVCWindow:SetUseControlBar(.T.)
					oFWMVCWindow:SetView(oView)
					oFWMVCWindow:SetCentered(.T.)
					oFWMVCWindow:SetPos(aCoors[1],aCoors[2])
					oFWMVCWindow:SetSize(aCoors[3],aCoors[4])
					oFWMVCWindow:SetTitle("Ocorrência")
					oFWMVCWindow:Activate()

				Case nClick == 16	//16-Qtd doc carga
					oModel := FWLoadModel("GFEA519B")
					oStruct:= FWFormStruct(2,"GX4")
					For nX := Len(oStruct:AFIELDS) to 1 Step -1
						If !(oStruct:AFIELDS[nX][1] $ "GX4_QTDC" )
							oStruct:RemoveField(oStruct:AFIELDS[nX][1])
						EndIf
					Next nX
					oStruct:AddGroup("Qt Doc Carga" , "Qt Doc Carga", "", 2)
					oStruct:SetProperty("GX4_QTDC", MVC_VIEW_GROUP_NUMBER, "Qt Doc Carga")
					CarregaMVCView(oModel,oStruct,"Qt Doc Carga","GFEA519B_GX4",{0,0,175,450},.T.)

				Case nClick == 17	//17-Unitizadores
					oModel := FWLoadModel("GFEA519")

					oStruct:= FWFormStruct(2,"GX9")
					oStruct:RemoveField("GX9_NRMOV" )
					CarregaMVCView(oModel,oStruct,"Unitizadores","GFEA519_GX9")

				Case nClick == 18	// Ver agendamentos
					oModel := FWLoadModel("GFEA519")

					oStruct:= FWFormStruct(2,"GWV")
					oStruct:RemoveField( "GWV_CDOPER" )
					oStruct:RemoveField( "GWV_CDEMIT" )
					oStruct:RemoveField( "GWV_NMEMIT" )
					oStruct:RemoveField( "GWV_TPEMIT" )
					oStruct:RemoveField( "GWV_DSOPER" )
					oStruct:RemoveField( "GWV_USUCRI" )
					oStruct:RemoveField( "GWV_SIT"    )
					oStruct:RemoveField( "GWV_IDTIPO" )
					oStruct:RemoveField( "GWV_SENHA"  )
					oStruct:RemoveField( "GWV_IDENVI" )
					oStruct:RemoveField( "GWV_HRENVI" )
					oStruct:RemoveField( "GWV_DTENVI" )
					oStruct:RemoveField( "GWV_IDCONF" )
					oStruct:RemoveField( "GWV_DTCONF" )
					oStruct:RemoveField( "GWV_HRCONF" )
					oStruct:RemoveField( "GWV_USUCAN" )
					oStruct:RemoveField( "GWV_MOTCAN" )
					oStruct:RemoveField( "GWV_NRMOV"  )
					oStruct:RemoveField( "GWV_NRMOV"  )
					oStruct:RemoveField( "GWV_DSCONF" )
					oStruct:RemoveField( "GWV_SEQ"    )

					CarregaMVCView(oModel,oStruct,"Agendamentos","GFEA519_GWV",,,,MODEL_OPERATION_VIEW)
			EndCase

			//Altera o Status na tabela temporária
			If (nClick >= 3 .And. nClick <= 6) .Or. nClick == 16
				A523VEICBC()
				Reclock(cAliasVeic,.F.)
				(cAliasVeic)->GX3_SIT 	:= GX3->GX3_SIT
				(cAliasVeic)->GX4_SIT 	:= GX4->GX4_SIT
				aAreaGX4 := GX4->(GetArea())
				(cAliasVeic)->GX4_SITDS := GetSitDs()
				RestArea(aAreaGX4)
				If nClick == 3
					(cAliasVeic)->CHECKLIST := GetCheckList()
				EndIf
				(cAliasVeic)->GX4_QTPESO := GX4->GX4_QTPESO

				If nClick == 4
					dbSelectArea("GXA")
					aAreaGXA := GXA->(GetArea())
						If GXA->(dbSeek(GX4->GX4_FILIAL + GX4->GX4_NRMOV))
							While !GXA->(Eof()) .And. GX4->GX4_FILIAL + GX4->GX4_NRMOV ==  GXA->GXA_FILIAL + GXA->GXA_NRMOV
								nDocCarga++
								GXA->(dbSkip())
							EndDo
						EndIf
					RestArea(aAreaGXA)
					(cAliasVeic)->QTDOCCARGA := nDocCarga
				EndIf

				MsUnLock(cAliasVeic)
				oBrowse:Refresh()
				oBrowse2:Refresh()
			EndIf
		EndIf
	EndIf
Return

Static Function MNU2_Click(nClick)
	Local oModel
	Local aAreaEnd
	Local aAreaGX4
	Local cFilGX3    := ""
	Local cSeqGX4    := ""
	Local lRet5236   := .T.
	Local cNrMov     := (cAliasEnd)->GX4_NRMOV
	Local s_GFEA5236 := ExistBlock("GFEA5236")

	If !(cAliasEnd)->(Eof())
		A523ENDBC() // Posicionamento GX3/GX4

		_cMov   := GX3->GX3_NRMOV
		_cOper  := GX3->GX3_CDOPER
		_cSeq   := GX3->GX3_SEQ
		_cPtCt  := GetValCbPonto()
		cFilGX3 := xFilial("GX3")
		cSeqGX4 := GX4->GX4_SEQ

		GFEA519BIN()

		If s_GFEA5236 
			lRet5236 := ExecBlock("GFEA5236", .F., .F.,{cFilGX3,_cMov,_cOper,_cSeq,_cPtCt,nClick,cSeqGX4})
		EndIf

		If lRet5236
			If nClick >= 2 .And. nClick<= 6 .And. MovimentaEndereco(nClick )
				A523ENDBC()
				Reclock(cAliasEnd,.F.)

				(cAliasEnd)->SITENDER := SubStr(aSitGX3cBox[aScan(aSitGX3cBox,{|x| SubStr(x,1,1) == GX3->GX3_SIT })],3)
				(cAliasEnd)->POS := If(Empty((cTemp:=Posicione("GVK",2,GX4->GX4_FILIAL + GX4->GX4_NRMOV + GX4->GX4_CDPTCT + GX4->GX4_SEQ,"GVK_SEQ"))), " - ",cValToChar(Val(cTemp)))
				Set Century Off // Ano Dois dígitos
				Do Case
					Case nClick == 2
						(cAliasEnd)->DTENTRADA := DTOC(GX4->GX4_DTCHEN) + " " + Transform(GX4->GX4_HRCHEN,"@R 99:99")
					Case nClick == 3
						(cAliasEnd)->DTINICARG := DTOC(GX4->GX4_DTINCA) + " " + Transform(GX4->GX4_HRINCA,"@R 99:99")
					Case nClick == 4
						(cAliasEnd)->DTFIMCARG := DTOC(GX4->GX4_DTFICA) + " " + Transform(GX4->GX4_HRFICA,"@R 99:99")
					Case nClick == 5
						(cAliasEnd)->DTLIBERAC := DTOC(GX4->GX4_DTLIEN) + " " + Transform(GX4->GX4_HRLIEN,"@R 99:99")
					Case nClick == 6
						(cAliasEnd)->DTSAIDA := DTOC(GX4->GX4_DTSAEN) + " " + Transform(GX4->GX4_HRSAEN,"@R 99:99")
				EndCase
				Set Century On // Ano Dois dígitos
				(cAliasEnd)->GX3_SIT := GX3->GX3_SIT
				MsUnLock(cAliasEnd)

				If nClick ==2 .Or. nClick == 5
					aAreaEnd := (cAliasEnd)->(GetArea())
					aAreaGX4 := GX4->(GetArea())
					cCDENDE  := GX4->GX4_CDENDE
					(cAliasEnd)->(dbSetOrder(2))
					(cAliasEnd)->(dbSeek(cCDENDE))
					While !(cAliasEnd)->(Eof()) .And. (cAliasEnd)->GX4_CDENDE == cCDENDE
						A523ENDBC()
						Reclock(cAliasEnd,.F.)
						(cAliasEnd)->SITENDER := SubStr(aSitGX3cBox[aScan(aSitGX3cBox,{|x| SubStr(x,1,1) == GX3->GX3_SIT })],3)
						(cAliasEnd)->POS := If(Empty((cTemp:=Posicione("GVK",2,GX4->GX4_FILIAL + GX4->GX4_NRMOV + GX4->GX4_CDPTCT + GX4->GX4_SEQ,"GVK_SEQ"))), " - ",cValToChar(Val(cTemp)))
						MsUnLock(cAliasEnd)
						(cAliasEnd)->(dbSkip())
					EndDo
					RestArea(aAreaEnd)
					RestArea(aAreaGX4)
				EndIf

				A523ENDBC()
				oBrowse:Refresh()
				oBrowse2:Refresh()

				If nClick == 6
					BtnAplicar_Click()
					(cAliasVeic)->(dbSeek(cNrMov))
					A523VEICBC() // Posicionamento GX3/GX4
					_cMov  := GX3->GX3_NRMOV
					_cOper := GX3->GX3_CDOPER
					_cSeq  := GX3->GX3_SEQ
					_cPtCt := GetValCbPonto()

					GFEA519BIN()
				EndIf
				oBrowse:UpdateBrowse()

			ElseIf nClick == 7 .And. MovimentaEndereco(2,1) // trocar endereço
				A523ENDBC()
				A523ENDER()

			ElseIf nClick == 8
				oModel := FWLoadModel("GFEA519B")
				oModel:SetOperation( MODEL_OPERATION_UPDATE )
				If oModel:Activate()
					A523CanEnd(oModel) // desfaz endereço
					If ValidaModel(oModel)
						BtnAplicar_Click()
					EndIf
					oModel:Deactivate()
					FreeObj(oModel)
				EndIf
			EndIf
		EndIf
	EndIf

Return

Static Function A523ENDER()

	If !(cAliasEnd)->(Eof())
		Reclock(cAliasEnd,.F.)
		(cAliasEnd)->GX4_CDENDE := GX4->GX4_CDENDE
		(cAliasEnd)->DSENDE     := Posicione("GVD",1,GX4->GX4_FILIAL + GX4->GX4_CDENDE,"GVD_DSENDE")
		(cAliasEnd)->SITENDER   := GetSitEnder()
		(cAliasEnd)->POS 		:= If(Empty((cTemp:=Posicione("GVK",2,GX4->GX4_FILIAL + GX4->GX4_NRMOV + GX4->GX4_CDPTCT + GX4->GX4_SEQ,"GVK_SEQ"))), " - ",cValToChar(Val(cTemp)))
		Set Century Off // Ano Dois dígitos
		(cAliasEnd)->DTENTRADA := DTOC(GX4->GX4_DTCHEN) + " " + Transform(GX4->GX4_HRCHEN,"@R 99:99")
		(cAliasEnd)->DTINICARG := DTOC(GX4->GX4_DTINCA) + " " + Transform(GX4->GX4_HRINCA,"@R 99:99")
		(cAliasEnd)->DTFIMCARG := DTOC(GX4->GX4_DTFICA) + " " + Transform(GX4->GX4_HRFICA,"@R 99:99")
		(cAliasEnd)->DTLIBERAC := DTOC(GX4->GX4_DTLIEN) + " " + Transform(GX4->GX4_HRLIEN,"@R 99:99")
		(cAliasEnd)->DTSAIDA   := DTOC(GX4->GX4_DTSAEN) + " " + Transform(GX4->GX4_HRSAEN,"@R 99:99")
		Set Century On // Ano Dois dígitos
		(cAliasEnd)->GX3_SIT := GX3->GX3_SIT
		MsUnLock(cAliasEnd)
	EndIf
	oBrowse:Refresh()
	oBrowse2:Refresh()
Return

Static Function Checkbox_Click()
	If  aLMostrar[1] == aLMostrarDefault[1] .AND. ;
		aLMostrar[2] == aLMostrarDefault[2] .AND. ;
		aLMostrar[3] == aLMostrarDefault[3]
		oBtnPadrao:Disable()
	Else
		oBtnPadrao:Enable()
	EndIf
Return Nil

//
// Trocar de ponto de controle
//
Static Function BtnTrocar_Click()
	CursorWait()
	Processa({|lEnd| A523PROC()},"Carregando informações", "Aguarde...")
	CursorArrow()
Return Nil

//
// Iniciar movimentações
//
Function BtnVeiculo_523()
	GFEA522()
	BtnTrocar_Click()
Return Nil

//
// Filtro das movimentações
//
Static Function BtnAplicar_Click()
	BtnTrocar_Click()
Return Nil

Static Function BtnRestaurar_Click()
	aCopy(aLMostrarDefault,aLMostrar)
	oBtnPadrao:Disable()

	BtnAplicar_Click()
Return Nil

//
//Consulta por placas
//
Static Function BtnConsultar_Click()
	BtnTrocar_Click()
Return Nil

Static Function BtnLimpar_Click()
	cPlaca := Space(TamSX3('GU8_PLACA')[01])
	BtnTrocar_Click()
Return Nil

Static Function MontaPaineis()
	Local oMenu
	Local oMenuBtn
	Local oBtnRIVei, oBtnRIEnd , oBtn1SLC, oBtn2SLC
	Local lEnderecamento := HasEnderecamento()
	Local nAlturaBase    := If(lEnderecamento,oPnlBrowses:NHEIGHT*0.55/2-10,oPnlBrowses:NHEIGHT/2)
	Local s_GFEA5234     := ExistBlock("GFEA5234")

	oPnlVeiculos := TPanel():New(0,0,,oPnlBrowses,,,,,,oPnlBrowses:NWIDTH/2,oPnlBrowses:NHEIGHT*0.55/2,,)
	aAlturas[1]  := oPnlVeiculos:NHEIGHT

	oPnlVeiculos  := TPanel():New(0,0,,oPnlBrowses,,,,,,oPnlBrowses:NWIDTH/2,nAlturaBase,,)
	oPnlBtnVeic	  := TPanel():New(nAlturaBase-2,0,,oPnlBrowses,,,,,,oPnlBrowses:NWIDTH/2,11,,)
	oPnlEnderecos := TPanel():New(nAlturaBase+11,0,,oPnlBrowses,,,,,,oPnlBrowses:NWIDTH/2,oPnlBrowses:NHEIGHT*0.45/2-10,,)
	oPnlBtnEnd	  := TPanel():New(nAlturaBase+(oPnlBrowses:NHEIGHT*0.35/2),0,,oPnlBrowses,,,,,,oPnlBrowses:NWIDTH/2,10,,)
	aAlturas[2]   := oPnlBtnVeic:NCLIENTHEIGHT
	aAlturas[3]   := oPnlEnderecos:NCLIENTHEIGHT
	aAlturas[4]   := oPnlBtnEnd:NCLIENTHEIGHT

	//Menu Veículos
	oPanel := TPanel():New(0,60,,oPnlBtnVeic,,,,,,5,1,,)
	oPanel:Align := CONTROL_ALIGN_TOP

	oPanel := TPanel():New(0,60,,oPnlBtnVeic,,,,,,5,2,,)
	oPanel:Align := CONTROL_ALIGN_LEFT

	oPanel := TPanel():New(0,60,,oPnlBtnVeic,,,,,,5,2,,)
	oPanel:Align := CONTROL_ALIGN_RIGHT

	oBtnRIVei := TButton():New(0,0, "Registrar Informações", oPnlBtnVeic, {||}, 70, 8, ,,,.T.,,,,)
	oBtnRIVei:Align := CONTROL_ALIGN_RIGHT

	If s_GFEA5234
		oMenuBtn := TMenu():New (0, 0, 0, 0, .T.)
		oMenuBtn := ExecBlock("GFEA5234", .F., .F., { oMenuBtn, .F. })
		oBtn1SLC := TButton():New(0,0, "Inf Complementares", oPnlBtnVeic, {||}, 70, 8, ,,,.T.,,,,)
		oBtn1SLC:Align := CONTROL_ALIGN_RIGHT
		oBtn1SLC:SetPopupMenu(oMenuBtn)
	EndIf

	oMenu:= TMenu():New ( 0,0,0,0, .T.)

	AddMenu(oMenu,aMenuVeic)
	oBtnRIVei:SetPopupMenu(oMenu)

	//Menu Endereços
	oPanel := TPanel():New(0,60,,oPnlBtnEnd,,,,,,5,2,,)
	oPanel:Align := CONTROL_ALIGN_LEFT

	oPanel := TPanel():New(0,60,,oPnlBtnEnd,,,,,,5,2,,)
	oPanel:Align := CONTROL_ALIGN_RIGHT

	oBtnRIEnd := TButton():New(0,0, "Registrar Informações", oPnlBtnEnd, {||}, 70, 8, ,,,.T.,,,,)
	oBtnRIEnd:Align := CONTROL_ALIGN_RIGHT

	If s_GFEA5234
		oMenuBtn := TMenu():New (0, 0, 0, 0, .T.)
		oMenuBtn := ExecBlock("GFEA5234", .F., .F., { oMenuBtn, .T. })
		oBtn2SLC := TButton():New(0,0, "Inf Complementares" , oPnlBtnEnd, {||}, 70, 8, ,,,.T.,,,,)
		oBtn2SLC:Align := CONTROL_ALIGN_RIGHT
		oBtn2SLC:SetPopupMenu(oMenuBtn)
	EndIf

	oMenu:= TMenu():New ( 0,0,0,0, .T.)

	AddMenu(oMenu,aMenuEnder)
	oBtnRIEnd:SetPopupMenu(oMenu)
Return Nil

Static Function AddMenu(oMenu,aMenu)
	Local nX
	Local aSrt := {}

	aSrt := aClone(aMenu)

	aSort(aSrt,,, {|x, y| x[5] < y[5]})

	For nX := 1 To Len(aSrt)
		oMenu:Add( (aSrt[nX][3]:=TMenuItem():New(oDlgOPC,aSrt[nX][1],,,,aSrt[nX][2],,,,,,,,,.T.)))

		aMenu[aScan(aMenu,{|x| aSrt[nX][1] == x[1]})][3] := aSrt[nX][3]
	Next nX
Return Nil


//////////////////////////////////////////////////////////////////
//
// Funções relacionadas a dados
//
//////////////////////////////////////////////////////////////////
Function A523SXBPLC(oGet) //Carrega um SXB (consulta) específica 
	Local nItem	  := 0
	Local lRet	  := .F.
	Local cTitulo := "Veículos - Placas"

	If Len(aPlcs) > 0
		lRet  := .F.
		nItem := TmsF3Array( {"Placa", "Código Veículo"}, aPlcs, cTitulo )
		If nItem > 0
			lRet   := .T.
			cPlaca := StrTran(aPlcs[nItem][1],"-","")
			oGet:CtrlRefresh()
		EndIf
	Else
		GFEMessage(0, GFEA523005, STR0008)
	EndIf

Return lRet

Static Function MontaStru()
	Local aStru
	Local nY        := 0  
	Local aRet      := {}
	Local aStruEnd  := {}
	Local aStruVeic := {}

	aStru := {;
				{"GX4_FILIAL"	, "C", TamSx3("GX4_FILIAL")[1], 0},;
				{"GX4_NRMOV"	, "C", TamSx3("GX4_NRMOV")[1] , 0},;
				{"GX4_SEQ"		, "C", TamSx3("GX4_SEQ")[1]   , 0},;
				{"GX3_SIT"		, "C", 1					  , 0},;
				{"GX4_SIT"		, "C", 1					  , 0},;
				{"GX4_DTSAI"	, "D", 8					  , 0},;
				{"GX4_SITDS"	, "C", 25					  , 0},;
				{"PLACAS"		, "C", 250					  , 0},;
				{"VEIODE"		, "C", 50					  , 0},;
				{"VAIPARA"		, "C", 50					  , 0},;
				{"DTENTRADA"	, "C", 14					  , 0},;
				{"QTDOCCARGA"	, "N", 3					  , 0},;
				{"GX4_QTPESO"	, "N", 15					  , 5},;
				{"CHECKLIST"	, "C", 15					  , 0};				
			}

	/*Ponto de entrada Sementes Goias
      Permite selecionar campos para serem exibidos no grid.
      Também define a ordem dos campos na tela.
    */
	If s_GFEA5231
		aRet := ExecBlock("GFEA5231", .F., .F., {})
		For nY := 1 to Len(aRet[1])
			aAdd(aStru, aRet[1][nY])
		Next nY
	EndIF
	aAdd(aStruVeic,aStru)

	cAliasVeic := GFECriaTab({aStruVeic[1], {"GX4_NRMOV"}})

	aAdd(aStruVeic, {;	// {Titulo,Nome do campo,Tipo,Tamanho,Decimal,Picture}
					{"Sit Aprovação"	,"GX4_SITDS"	,"C",8,0,	""},;
					{"Placas"			,"PLACAS"		,"C",10,0,	""},;
					{"Veio de"			,"VEIODE"		,"C",10,0,	""},;
					{"Vai para"			,"VAIPARA"		,"C",10,0,	""},;
					{"Dt Entrada"		,"DTENTRADA"	,"C",10,0,	""},;
					{"Qt Doc Carga"		,"QTDOCCARGA"	,"N",8,0,	""},;
					{"Peso"				,"GX4_QTPESO"	,"N",5,5,	""},;
					{"Check-list"		,"CHECKLIST"	,"C",5,0,	""};
					})

	/*Ponto de entrada Sementes Goias
      Permite selecionar campos para serem exibidos no grid.
      Também define a ordem dos campos na tela.
    */
    aRet := {}
	If s_GFEA5231
		aRet := ExecBlock("GFEA5231", .F., .F., {})
		For nY := 1 to Len(aRet[1])
			aAdd(aStruVeic[2], aRet[2][nY])
		Next nY
	EndIF

	aAdd(aStruEnd, {;
					{"GX4_FILIAL"	, "C", TamSx3("GX4_FILIAL")[1], 0},;
					{"GX4_NRMOV"	, "C", TamSx3("GX4_NRMOV")[1] , 0},;
					{"GX4_SEQ"		, "C", TamSx3("GX4_SEQ")[1]	  , 0},;
					{"GX3_SIT"		, "C", 1					  , 0},;
					{"GX4_CDENDE"	, "C", TamSx3("GX4_CDENDE")[1], 0},;
					{"PLACAS"		, "C", 250					  , 0},;
					{"DSENDE"		, "C", 50					  , 0},;
					{"SITENDER"		, "C", 11					  ,	0},;
					{"POS"			, "C", 3					  ,	0},;
					{"DTENTRADA"	, "C", 14					  , 0},;
					{"DTINICARG"	, "C", 14					  , 0},;
					{"DTFIMCARG"	, "C", 14					  , 0},;
					{"DTLIBERAC"	, "C", 14					  , 0},;
					{"DTSAIDA"		, "C", 14					  , 0};
				})

	cAliasEnd := GFECriaTab({aStruEnd[1], {"GX4_FILIAL+GX4_NRMOV+GX4_SEQ","GX4_CDENDE+GX4_NRMOV"}})

	aAdd(aStruEnd, {;	// {Titulo,Nome do campo,Tipo,Tamanho,Decimal,Picture}
					{"Placas"			 ,"PLACAS"		, "C",12,0,""},;
					{"Endereço"			 ,"DSENDE"		, "C",08,0,""},;
					{"Sit. Endereçamento","SITENDER"	, "C",08,0,""},;
					{"Pos"				 ,"POS"			, "C",04,0,""},;
					{"Chegada"			 ,"DTENTRADA"	, "C",10,0,""},;
					{"Início Carg/Desc"	 ,"DTINICARG"	, "C",16,0,""},;
					{"Fim Carg/Desc"	 ,"DTFIMCARG"	, "C",13,0,""},;
					{"Liberação"		 ,"DTLIBERAC"	, "C",09,0,""},;
					{"Saída"			 ,"DTSAIDA"		, "C",05,0,""};
				})

	dbSelectArea(cAliasEnd)
	dbSetOrder(01)
	dbGoTop()
	dbSelectArea(cAliasVeic)
	dbSetOrder(01)
	dbGoTop()
	A523MD()
Return {aStruVeic,aStruEnd}

// Monta Dados
Static Function A523MD()
	Local nX     
	Local cPlc
	Local cPtAnt
	Local cPtProx
	Local aAreaGX4
	Local aAreaTmp
	Local cSeqAtual
	Local nDocCarga
	Local nCont       := 0
	Local cTemp 	  := ""
	Local cTeste 	  := ""
	Local cCampo	  := ""
	Local cQuery	  := ""
	Local cFilSQL	  := ""
	Local cUserFils   := ""	
	Local lEndereco   := .F.
	Local lPadrao 	  := .F.
	Local aRet		  := {}
	Local cFilAtu 	  := cFilAnt
	Local cPictPlaca  := PesqPict('GU8','GU8_PLACA')
	Local aUserFils	  := GetBrwFils()
	Local s_gfepfl    := SuperGetMV('MV_GFEPFL',,'1')
	Private cAliasGX3 := ""

	aPlcs := {}
	dbSelectArea(cAliasEnd)
	ZAP
	dbSelectArea(cAliasVeic)
	ZAP

	GU8->(dbSetOrder(1))
	GXA->(dbSetOrder(1))
	GVF->(dbSetOrder(1))
	GVD->(dbSetOrder(1))
	GVK->(dbSetOrder(2))
	GWD->(dbSetOrder(1))
	GX6->(dbSetOrder(1))
	GX4->(dbSetOrder(4))

   	lPadrao := !aLMostrar[1] .And. !aLMostrar[2] .And. !aLMostrar[3]

	Set Century Off //Ano vai para dois digitos
	lEndereco := HasEnderecamento()

	For nX:= 1 To Len(aUserFils)
		cFilSQL := aUserFils[nX]
		If AT(cFilSQL,cUserFils) == 0
		   	If s_gfepfl == "1" 	
        	  	If Empty(cUserFils)
					cUserFils := "'" + cFilSQL + "'"
			  	Else
					cUserFils += ",'" + cFilSQL + "'"
			  	EndIf
		   	Else
		       	If Empty(cUserFils)
				  	cUserFils := "'" + cFillog + "'"
			   	EndIf
		   	EndIf
		EndIf
	Next

	cAliasGX3 := GetNextAlias()
	cQuery := " SELECT GX3.GX3_FILIAL, GX3.GX3_NRMOV, GX3.GX3_SIT, GX3.GX3_CDOPER, GX3.GX3_SEQ"
	cQuery += " FROM " + RetSQLName("GX3") + " GX3 "
	cQuery += " WHERE GX3.D_E_L_E_T_ = ' ' "
	cQuery += " AND GX3.GX3_SIT NOT IN ('5','6')"
	cQuery += " AND GX3.GX3_FILIAL IN  (" + cUserFils + ")"
	cQuery += " ORDER BY GX3.GX3_FILIAL, R_E_C_N_O_ "

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasGX3, .F., .T.)

	While (cAliasGX3)->( !Eof() )

 		If GX4->(dbSeek((cAliasGX3)->GX3_FILIAL + (cAliasGX3)->GX3_NRMOV ))

 			cFilAnt := (cAliasGX3)->GX3_FILIAL

 			While !GX4->(Eof()) .AND. ;
 				  GX4->GX4_FILIAL == (cAliasGX3)->GX3_FILIAL .AND. ;
 				  GX4->GX4_NRMOV  == (cAliasGX3)->GX3_NRMOV

 				If GetValCbPonto() != GX4->GX4_CDPTCT
 					GX4->(dbSkip())
					Loop
 				EndIf

 				If GetSeq() > GX4->GX4_SEQ
					GX4->(dbSkip())
					Loop
 				Else
 					If GetSeq() == GX4->GX4_SEQ  // É o atual
 						If !lPadrao
	 						If !aLMostrar[2] .And. !aLMostrar[3]
	 							GX4->(dbSkip())
			 					Loop
	 						EndIf

	 						If aLMostrar[2] == .T. .And. aLMostrar[3] == .F. .And. !Empty(GX4->GX4_DTENTR)  // verifica se deve verificar se a entrada está registrada
			 					GX4->(dbSkip())
			 					Loop
			 				ElseIf aLMostrar[3] == .T.  .And. Empty(GX4->GX4_DTENTR) .And. aLMostrar[2] == .F.
			 					GX4->(dbSkip())
			 					Loop
			 				EndIf
		 				EndIf
		 			Else
		 				// É um anterior
		 				If !aLMostrar[1]
		 					GX4->(dbSkip())
		 					Loop
		 				EndIf
	 				EndIf
 				EndIf

				cSeqAtual := GX4->GX4_CDPTCT + GX4->GX4_SEQ
 				cTeste 	  := GX4->GX4_FILIAL + GX4->GX4_NRMOV
		 		aAreaTmp  := GX4->(GetArea())

				cTemp := ""
				GX6->(dbSeek(GX4->GX4_FILIAL + GX4->GX4_NRMOV))

 				//Monta a lista de placas
 				While !GX6->(Eof()) .And. ;
 					   GX6->GX6_FILIAL == GX4->GX4_FILIAL .AND. ;
 					   GX6->GX6_NRMOV  == GX4->GX4_NRMOV

 					If Len(cTemp) + 9 < 250
 						If !Empty(cTemp)
 							cTemp += ";"
 						EndIf
 						cTemp += (cPlc:=Transform(Posicione("GU8",1,xFilial("GU8")+GX6->GX6_CDVEIC,"GU8_PLACA"),cPictPlaca))
 					EndIf

 					If aScan(aPlcs,{|x| AllTrim(x[2]) == AllTrim(GX6->GX6_CDVEIC)}) == 0
 						aAdd( aPlcs, {cPlc,GX6->GX6_CDVEIC} )
 					EndIf

 					GX6->(dbSkip())
				EndDo

				If !Empty(cPlaca) .And. !(Transform(cPlaca,cPictPlaca) $ cTemp) // Filtra placas?
					GX4->(dbSkip())
					Loop
				EndIf

 				//Encontra os pontos anterior e o próximo
 				GX4->(dbSkip(-1)) //Anterior
 				If !GX4->(Eof()) .And. (GX4->GX4_FILIAL + GX4->GX4_NRMOV == cTeste) .And. (cSeqAtual != GX4->GX4_CDPTCT + GX4->GX4_SEQ)
 					cPtAnt  := Posicione("GVF",1,GVF->GVF_FILIAL + GX4->GX4_CDPTCT,"GVF_DSPTCT")
 				Else
 					cPtAnt := "    -    "
 				EndIf

 				RestArea(aAreaTmp)

 				GX4->(dbSkip()) //Próximo
 				If !GX4->(Eof()) .And. (GX4->GX4_FILIAL + GX4->GX4_NRMOV == cTeste) .And. (cSeqAtual != GX4->GX4_CDPTCT + GX4->GX4_SEQ)
 					cPtProx := Posicione("GVF",1,GVF->GVF_FILIAL + GX4->GX4_CDPTCT,"GVF_DSPTCT")
 				Else
 					cPtProx := "    -    "
 				EndIf
 				RestArea(aAreaTmp)

				If !lEndereco .Or. Empty(GX4->GX4_CDENDE) .Or. !Empty(GX4->GX4_DTSAEN)
					dbSelectArea(cAliasVeic)
					RecLock(cAliasVeic,.T.)
					(cAliasVeic)->GX4_FILIAL	:= GX4->GX4_FILIAL
					(cAliasVeic)->GX4_NRMOV 	:= GX4->GX4_NRMOV
					(cAliasVeic)->GX4_SEQ 		:= GX4->GX4_SEQ
					(cAliasVeic)->PLACAS  		:= cTemp
					(cAliasVeic)->GX3_SIT 		:= (cAliasGX3)->GX3_SIT
					(cAliasVeic)->GX4_SIT 		:= GX4->GX4_SIT
					(cAliasVeic)->GX4_DTSAI 	:= GX4->GX4_DTSAI
					aAreaGX4 := GX4->(GetArea())
					(cAliasVeic)->GX4_SITDS 	:= GetSitDs()
					RestArea(aAreaGX4)
					(cAliasVeic)->VEIODE 		:= cPtAnt
					(cAliasVeic)->VAIPARA 		:= cPtProx
					(cAliasVeic)->DTENTRADA 	:= DTOC(GX4->GX4_DTENTR) + " " + Transform(GX4->GX4_HRENTR,"@R 99:99")
					nDocCarga := 0
					If GXA->(dbSeek(GX4->GX4_FILIAL + GX4->GX4_NRMOV))
						While !GXA->(Eof()) .And. GX4->GX4_FILIAL + GX4->GX4_NRMOV ==  GXA->GXA_FILIAL + GXA->GXA_NRMOV
							nDocCarga++
							GXA->(dbSkip())
						EndDo
					EndIf 
					(cAliasVeic)->QTDOCCARGA := nDocCarga
					(cAliasVeic)->GX4_QTPESO := GX4->GX4_QTPESO
					(cAliasVeic)->CHECKLIST  := GetCheckList()

					nCont++
					/*Ponto de entrada Sementes Goias
				      Permite selecionar campos para serem exibidos no grid.
				      Também define a oredem dos campos na tela.
				    */
				    aRet := {}
				    nX   := 0
					If s_GFEA5231
						aRet := ExecBlock("GFEA5231", .F., .F., {(cAliasVeic), nCont}) 
						For nX := 1 To Len(aRet[1]) 
							cCampo := aRet[1][nX][1]
							(cAliasVeic)->&cCampo := aRet[3][nX]
						Next nX
					EndIf

					MsUnLock(cAliasVeic)
				EndIf

				If lEndereco .And. (!Empty(GX4->GX4_CDENDE) .And. !Empty(GX4->GX4_PRIORI) .And. Empty(GX4->GX4_DTSAEN))
					dbSelectArea(cAliasEnd)
					RecLock(cAliasEnd,.T.)
					(cAliasEnd)->GX4_FILIAL	:= GX4->GX4_FILIAL
					(cAliasEnd)->GX4_NRMOV 	:= GX4->GX4_NRMOV
					(cAliasEnd)->GX4_SEQ 	:= GX4->GX4_SEQ
					(cAliasEnd)->GX3_SIT 	:= (cAliasGX3)->GX3_SIT
					(cAliasEnd)->PLACAS  	:= cTemp
					(cAliasEnd)->DSENDE 	:= Posicione("GVD",1,GX4->GX4_FILIAL + GX4->GX4_CDENDE,"GVD_DSENDE")
					(cAliasEnd)->GX4_CDENDE	:= GX4->GX4_CDENDE
					(cAliasEnd)->SITENDER	:= SubStr(aSitGX3cBox[aScan(aSitGX3cBox,{|x| SubStr(x,1,1) == (cAliasGX3)->GX3_SIT })],3)	
					(cAliasEnd)->POS 			:= If(Empty((cTemp:=Posicione("GVK",2,GX4->GX4_FILIAL + GX4->GX4_NRMOV + GX4->GX4_CDPTCT + GX4->GX4_SEQ,"GVK_SEQ"))), " - ",cValToChar(Val(cTemp)))
					(cAliasEnd)->DTENTRADA 	:= DTOC(GX4->GX4_DTCHEN) + " " + Transform(GX4->GX4_HRCHEN,"@R 99:99")
					(cAliasEnd)->DTINICARG 	:= DTOC(GX4->GX4_DTINCA) + " " + Transform(GX4->GX4_HRINCA,"@R 99:99")
					(cAliasEnd)->DTFIMCARG 	:= DTOC(GX4->GX4_DTFICA) + " " + Transform(GX4->GX4_HRFICA,"@R 99:99")
					(cAliasEnd)->DTLIBERAC 	:= DTOC(GX4->GX4_DTLIEN) + " " + Transform(GX4->GX4_HRLIEN,"@R 99:99")
					(cAliasEnd)->DTSAIDA 	:= DTOC(GX4->GX4_DTSAEN) + " " + Transform(GX4->GX4_HRSAEN,"@R 99:99")
					MsUnLock(cAliasEnd)
				EndIf

 				GX4->(dbSkip())
 			EndDo
 		EndIf
		(cAliasGX3)->(dbSkip())
	EndDo
	(cAliasGX3)->( dbCloseArea() )
	Set Century On 

Return

Static Function GetSitEnder()
	Local cSit := GX3->GX3_SIT

	If empty(cSit)
		cSit := (cAliasGX3)->GX3_SIT
	EndIf

	If !Empty(cSit)
		cSit := SubStr(aSitGX3cBox[aScan(aSitGX3cBox,{|x| SubStr(x,1,1) == cSit })],3)
	EndIf
Return cSit

// Retorna sequencia atual
Static Function GetSeq()
	Local cSeq 		:= "999"
	Local cNrMov	:= GX4->GX4_FILIAL + GX4->GX4_NRMOV
	Local aAreaGX4 	:= GX4->(GetArea())

	GX4->( dbSetOrder(4) )
	GX4->( dbSeek(cNrMov) )
	While !GX4->(Eof()) .And. cNrMov == GX4->GX4_FILIAL + GX4->GX4_NRMOV
		// >>Não Impeditivo = (GVF_IDIMPE == '2')
		If (Empty(GX4->GX4_DTSAI) .And. Empty(GX4->GX4_HRSAI)) .Or.;
		   (!Empty(GX4->GX4_DTSAI) .And. !Empty(GX4->GX4_HRSAI) .And. GX4->GX4_SIT == "3" .And. Posicione("GVF",1,xFilial("GVF") + GX4->GX4_CDPTCT,"GVF_IDIMPE") == '1')
			cSeq := GX4->GX4_SEQ
			Exit
		EndIf
		GX4->(dbSkip())
	EndDo

	RestArea(aAreaGX4)
Return cSeq

Function GetSitDs()
	Local cSit 		 := ""
	Local aSitGX4Box := StrToKArr(Posicione("SX3",2,"GX4_SIT","X3CBOX()"),";")
	Local cGX3NRMOV  := GX3->GX3_NRMOV
	Local cGX3DOPER  := GX3->GX3_CDOPER
	Local cGX3SEQ 	 := GX3->GX3_SEQ

	If Empty(cGX3NRMOV) .And. Empty(cGX3DOPER) .And. Empty(cGX3SEQ)
		cGX3NRMOV := (cAliasGX3)->GX3_NRMOV
		cGX3DOPER := (cAliasGX3)->GX3_CDOPER
		cGX3SEQ   := (cAliasGX3)->GX3_SEQ
	EndIf

	If !Empty(GX4->GX4_DTSAI) .And. GX4->GX4_SIT != "3"
		cSit := "Concluído"
	ElseIF GX4->GX4_SIT == "3" .and. GFEA519BLE(4,cGX3NRMOV,cGX3DOPER,cGX3SEQ,GX4->GX4_CDPTCT)
		cSit := "Pendente ação reprovação"
	Else
		cSit := SubStr(aSitGX4Box[aScan(aSitGX4Box,{|x| SubStr(x,1,1) == cValtoChar(GX4->GX4_SIT)})],3)
	EndIf

Return cSit

Static Function GetValCbPonto() // Retorna o valor do combo
	Local nRet := 0
	Local cRet := ""

	If Len(aPontos) > 0
		nRet := aScan(aPontos,{|x| x == cPtCtSel})
		Iif(nRet == 0,nRet:=1,nil)
		cRet := aValores[nRet]
	EndIf
Return cRet

Static Function HasEnderecamento(cPontoCont)
	Local lRet := .F.
	Default cPontoCont := GetValCbPonto()

	GVF->(dbSetOrder(1))
	If GVF->( dbSeek(xFilial("GVF") + cPontoCont)) .And. GVF->GVF_IDINEN == "1"
		lRet := .T. 
	EndIf
Return lRet

Static Function CanEntradaVeiculo()
	Local lRet  := .T.
	Local aArea := GetArea()

	CbPonto := GetValCbPonto()
	GVJ->(dbSetOrder(2))
	If !GVJ->(dbSeek(xFilial("GVJ") + "001" + CbPonto ) )
		lRet := .F.
	EndIf

	RestArea(aArea)
Return lRet

Static Function A523PROC()
	oPnlBrowses:SetUpdatesEnabled(.F.)
	ProcRegua(3)
	IncProc("Buscando Informações")

	If CanEntradaVeiculo()
		oPanelEntr:Show()
	Else
		oPanelEntr:Hide()
	EndIf

	A523MD()
	IncProc("Montando Veículos")
	oPnlVeiculos:nHeight := If(HasEnderecamento(),aAlturas[1],aAlturas[1]+aAlturas[2]+aAlturas[3]-aAlturas[4])-15
	oPnlBtnVeic:nTop := If(HasEnderecamento(),aAlturas[1]+1,aAlturas[1]+aAlturas[2]+aAlturas[3]-aAlturas[4])-10
	oBrowse:UpdateBrowse()
	If HasEnderecamento()
		oPnlEnderecos:Show()
		oPnlBtnEnd:Show()
		oPnlEnderecos:nTop := oPnlBtnVeic:nTop + oPnlBtnVeic:nHeight
		oPnlBtnEnd:nTop  := oPnlEnderecos:nTop + oPnlEnderecos:nHeight -19
		oBrowse2:UpdateBrowse()
	Else
		oPnlEnderecos:Hide()
		oPnlBtnEnd:Hide()
	EndIf
	A523VEICBC()
	A523ENDBC()
	oPnlBrowses:SetUpdatesEnabled(.T.)

	// Verifica se existe texto de INSTRUCAO para mostrar ou nao o botao
	GFEA523HSInstr()
Return Nil

Static Function MovimentaEndereco(nEnder,nMnu) // Realiza a movimentação e grava os dados
	Local oModel := FWLoadModel("GFEA519B")
	Local lRet := .F.

	Default nMnu := 2

	M->GX4_DTENTR := GX4->GX4_DTENTR
	M->GX4_HRENTR := GX4->GX4_HRENTR
	M->GX4_DTCHEN := GX4->GX4_DTCHEN
	M->GX4_HRCHEN := GX4->GX4_HRCHEN
	M->GX4_DTINCA := GX4->GX4_DTINCA
	M->GX4_HRINCA := GX4->GX4_HRINCA
	M->GX4_DTFICA := GX4->GX4_DTFICA
	M->GX4_HRFICA := GX4->GX4_HRFICA
	M->GX4_DTLIEN := GX4->GX4_DTLIEN
	M->GX4_HRLIEN := GX4->GX4_HRLIEN
	M->GX4_DTSAEN := GX4->GX4_DTSAEN
	M->GX4_HRSAEN := GX4->GX4_HRSAEN
	M->GX4_DTSAI  := GX4->GX4_DTSAI
	M->GX4_HRSAI  := GX4->GX4_HRSAI

	oModel:SetOperation( MODEL_OPERATION_UPDATE )
    If !oModel:Activate()
    	Help( ,, 'HELP',, oModel:GetErrorMessage()[6], 1, 0)
    	Return .F.
    EndIf
    If nMnu == 2
		If GFEA519BDT(oModel, nEnder)
			lRet:= ValidaModel(oModel)
		EndIf
	Else
		Do Case
			Case nEnder == 2
				TelaEndereco(oModel,@lRet)
		EndCase
	EndIf
	oModel:Deactivate()
Return lRet

Function A523CanEnd(oModel)
	Local nX
	Local lRet 	  := .F.
	Local aCampos := {"HRSAI","DTSAI","HRSAEN","DTSAEN","HRLIEN","DTLIEN","HRFICA","DTFICA","HRINCA","DTINCA","HRCHEN","DTCHEN","CDENDE"}

    For nX := 1 to Len(aCampos)
    	If At("HR",aCampos[nX]) == 1
    		If Empty(oModel)
    			&("GX4->GX4_" + aCampos[nX]) := "    "
    		Else
	    		If !oModel:LoadValue("GFEA519B_GX4","GX4_" + aCampos[nX], "    ")
	    			Exit
	    		Else
	    			&('M->' + "GX4_" + aCampos[nX] ) := "    "
	    		EndIf
	    	EndIf
    	ElseIf At("DT",aCampos[nX]) == 1
    		If Empty(oModel)
    			&("GX4->GX4_" + aCampos[nX]) := CtoD("  /  /    ")
    		Else
	    		If !oModel:LoadValue("GFEA519B_GX4","GX4_" + aCampos[nX], CtoD("  /  /    "))
	    			Exit
	    		Else
	    			&('M->' + "GX4_" + aCampos[nX] ) := CtoD("  /  /    ")
	    		EndIf
	    	EndIf
    	Else
    		If Empty(oModel)
    			&("GX4->GX4_" + aCampos[nX]) := Space(TamSx3("GX4_" + aCampos[nX])[1])
    		Else
	    		If !oModel:LoadValue("GFEA519B_GX4","GX4_" + aCampos[nX], Space(TamSx3("GX4_" + aCampos[nX])[1]))
	    			Exit
	    		Else
	    			&('M->' + "GX4_" + aCampos[nX] ) := Space(TamSx3("GX4_" + aCampos[nX])[1])
	    		EndIf
	    	EndIf
    	EndIf
    Next nX
Return lRet

Static Function ValidaModel(oModel)
	Local lRet := .F.

	If oModel:VldData() .And. oModel:GetModel("GFE519BGXA"):VldData() .And. oModel:GetModel("GFE519BGX5"):VldData()
		oModel:CommitData()
        lRet := .T.
	Else
		Help( ,, 'HELP',, oModel:GetErrorMessage(.T.)[6], 1, 0)
	EndIf
Return lRet

//////////////////////////////////////////////////////////////////
// Funções relacionadas a validação de inicialiação
//////////////////////////////////////////////////////////////////
Static Function VldAberturaTela()
	Local nJ        := 0
	Local cQuery    := ""
	Local cQuery2   := ""
	Local lRet      := .T. 
	Local cAliasGVP := GetNextAlias()

	For nJ := 1 to Len(aGrpUsr)
		If nJ == 1
			cQuery2 += "'" + aGrpUsr[nJ] + "'"
		Else
			cQuery2 += ", '" + aGrpUsr[nJ] + "'"
		EndIf
	Next nJ

	cQuery := " SELECT GVP_FILIAL, GVP.GVP_CDPTCT, GVF.GVF_DSPTCT "
	cQuery += " FROM " + RetSQLName("GVP") + " GVP "
	cQuery += " INNER JOIN " + RetSQLName("GVF") + " GVF"
	cQuery += " ON (GVP.GVP_CDPTCT = GVF.GVF_CDPTCT AND GVP.GVP_FILIAL = GVF.GVF_FILIAL) "
	cQuery += " WHERE GVP.D_E_L_E_T_ = ' '"
	cQuery += " AND GVF.D_E_L_E_T_ = ' ' "
	cQuery += " AND ( GVP.GVP_CDUSUR = '" + cCodUsr + "'"
	If Len(aGrpUsr) > 0 .And. GFXCP12123("GVP_GRPUSU")
		cQuery += "OR GVP.GVP_GRPUSU IN ( " + cQuery2 + " ) "
	EndIf
	cQuery += " )"
	cQuery += " GROUP BY GVP.GVP_FILIAL, GVP.GVP_CDPTCT, GVF.GVF_DSPTCT "
	cQuery += " ORDER BY GVF.GVF_DSPTCT"

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
		GFEMessage(5, GFEA523006, STR0009, STR0010)
	EndIf

Return lRet

Function RelCheck(lEnd,WnRel,cString,cTamanho,cPrograma,cNrMov,cPtoCtr)
	Local cabec1
	Local cabec2
	Local cAliasGVH
	Local nInd		 := 0
	Local nTipo 	 := 15	// Monta os Cabecalhos
	Local cQuery	 := ""
	Local cRodaTxt	 := OemToAnsi("Rodapé")
	Local cPlaca     := Space(TamSX3("GU8_PLACA")[01])
	Local cPictPlaca := PesqPict("GU8","GU8_PLACA")

	Li 	   	:= 80 
	M_PAG 	:= 1	// Inicializa os codigos de caracter Comprimido da impressora ³

	// Busca PLACA
	GX6->( dbSetOrder(1) ) // GX6_FILIAL + GX6->GX6_NRMOV + GX6_CDVEIC
   	If GX6->( dbSeek( GX4->GX4_FILIAL + GX4->GX4_NRMOV ) )
 		While GX6->( !Eof() ) .And. GX6->GX6_FILIAL + GX6->GX6_NRMOV == GX4->GX4_FILIAL + GX4->GX4_NRMOV
 			cPlaca := Transform(Posicione("GU8",1,xFilial("GU8")+GX6->GX6_CDVEIC,"GU8_PLACA"),cPictPlaca)
 			GX6->( dbSkip() )
		EndDo
	EndIf

	dbSelectArea("GVF")
	GVF->( dbSetOrder(1) ) // GVF_FILIAL + GVF_CDPTCT

	cabec1 := "Data: " + DToC(DDATABASE) + "  Hora: " + Substr(Time(), 1,5)
	cabec2 := "Nr Movto:	" + cNrMov
	cabec2 += "  Pto Controle: " + POSICIONE("GVF",1,xFilial("GVF")+cPtoCtr,"GVF_DSPTCT")
	cabec2 += Space(32)
	cabec2 += "  Placa: " + cPlaca

	If GVF->( dbSeek(xFilial("GVF") + cPtoCtr ) )

		cAliasGVH := GetNextAlias()
		cQuery := " SELECT GVH.GVH_CDPERG "
		cQuery += " FROM " + RetSQLName("GVH") + " GVH "
		cQuery += " WHERE GVH.D_E_L_E_T_ = ' ' "
		cQuery += " AND GVH.GVH_CDPTCT = '" + GVF->GVF_CDPTCT + "'" 
		cQuery += " AND GVH.GVH_FILIAL = '" + xFilial("GVH") + "'" 
		cQuery += " ORDER BY R_E_C_N_O_  "

		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasGVH, .F., .T.)

		While (cAliasGVH)->( !Eof() )

			If Li > 60
				Cabec("Checklist", cabec1, cabec2, cPrograma, cTamanho, 15)
			EndIf

			@ Li,00 PSAY (cAliasGVH)->GVH_CDPERG  + " - "
			@ Li,09 PSAY Posicione("GVG",1,xFilial("GVG")+(cAliasGVH)->GVH_CDPERG,"GVG_DSPERG")

			Li++
			@ Li,00 PSAY "( ) Sim  ( ) Não"

			Li++
			@ Li,00 PSAY "Observações: "

			Li++
	   		nInd++
			Li++

			(cAliasGVH)->( dbSkip() )
		EndDo
		(cAliasGVH)->( dbCloseArea() )
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

Static Function ShowInstr()
	Local oTMultiget
	Local cTextoGVF := ""
	Local cAuxGVF   := ""
	Local cTextoGVI := ""
	Local cTexto 	:= ""
	Private oDlgInst

	If GFXCP12117("GVF_INSTRU")
		cTextoGVF 	:= Posicione("GVF",1,xFilial("GVF") + GetValCbPonto(),"GVF_INSTRU")
		cAuxGVF 	:= StrTran(cTextoGVF, Chr(13)+Chr(10), "")
		cTexto		+= "** Ponto de Controle **" + CRLF
		If AllTrim(cAuxGVF) <> ""
			cTexto 	+= + cTextoGVF +  CRLF + CRLF + CRLF
		Else
			cTexto	+= "Não há instruções cadastradas para este Ponto de Controle." + CRLF + CRLF + CRLF
		EndIf
	EndIf

	If GFXCP12117("GVI_INSTRU")
		A523VEICBC()

		GVI->( dbSetOrder(1) )
		GVI->( dbSeek(xFilial("GVI") + GX3->GX3_CDOPER + GX3->GX3_SEQ) )

		cTextoGVI 	:= GVI->GVI_INSTRU
		cAuxGVI 	:= StrTran(cTextoGVI, Chr(13)+Chr(10), "")
		cTexto		+= "** Configuração de Operação **" + CRLF
		If AllTrim(cAuxGVI) <> ""
			cTexto 	+= + cTextoGVI +  CRLF + CRLF + CRLF
		Else
			cTexto	+= "Não há instruções cadastradas para esta Configuração da Operação." + CRLF + CRLF + CRLF
		EndIf
	EndIf

	DEFINE DIALOG oDlgInst TITLE "Instruções" FROM 180, 110 TO 400, 628 PIXEL
	oTMultiget := tMultiget():new( 01, 01, {| u | if( pCount() > 0, cTexto := u, cTexto ) }, oDlgInst, 260, 92, , , , , , .T. ,,,,,,.T.,,,,,.T.)
 	DEFINE SBUTTON oSBtnEnd FROM 95, 01 TYPE 01 OF oDlgInst ENABLE ACTION oDlgInst:End()
 	ACTIVATE DIALOG oDlgInst CENTERED

Return

// Retorna ação da reprovação
// 1=Abrir Ocorrencia;
// 2=Informar Controle Patio;
// 3=Decisao Pto Controle;
// 4=Cancelar Movto;
// 5=Permitir Continuar;
// 6=Voltar Pto Anterior
Function A523AcaoReprov()
	Local cRet := "1"

	dbSelectArea("GVJ")
	GVJ->(dbSetOrder(2))
	If GVJ->(dbSeek(xFilial("GVJ") + GX4->GX4_SEQ + GX4->GX4_CDPTCT + GX3->GX3_CDOPER + GX3->GX3_SEQ )) 
		If !Empty(GVJ->GVJ_REPROV)
			cRet := GVJ->GVJ_REPROV
		EndIf
	EndIf
Return cRet

// As ações “Continuar” e “Cancelar” devem solicitar uma confirmação e uma justificativa, que será gravada no campo GX4_REPOBS
// Também será gravado o usuário corrente no campo GX4_REPUSU;
Function GFEA523AVJ(cJustifica, cCombo, cLabel)

	A523VEICBC()

	If AllTrim(cJustifica) <> ""
		If cCombo == "Cancelar"
			RecLock("GX3", .F.)
				GX3->GX3_SIT := "5"
			MsUnlock("GX3")
		EndIf

		If cCombo == "Continuar"
			// Continuar -> GX4_SIT do ponto de controle da movimentação como aprovado
			RecLock("GX4", .F.)
				GX4->GX4_SIT := "2"
			MsUnlock("GX4")
		EndIf

		RecLock(cAliasVeic, .F.)
			(cAliasVeic)->GX3_SIT := GX3->GX3_SIT
			(cAliasVeic)->GX4_SIT := GX4->GX4_SIT
		MsUnlock(cAliasVeic)

		RecLock("GX4",.F.)
			// Gravar justificativa no campo GX4_REPOBS
			GX4->GX4_REPOBS := cJustifica
			// gravar usuário corrente no campo GX4_REPUSU
			GX4->GX4_REPUSU := cUserName
		MsUnlock("GX4")

		oBrowse:Refresh()
		oBrowse2:Refresh()

		oDlgJust:End()
	Else
		GFEMessage(0, GFEA523007, STR0011)
	EndIf

Return

// Verifica se deve ou nao mostrar o botao de Instrucao do Ponto de Controle TABELAS: GX4 GVP
Static Function GFEA523HSInstr()
	oBtnInstr:Show()
Return

Static Function A523VCMPCOMP()
	Local nSX		
	Local aStructSX
	Local cLstCampos := ""
	Local oStructX3	 := GFESeekSX():New()

	aStructSX := FWFormStruct(3,"GX4")[1] //Todos os Campos
	For nSX := 1 to Len(aStructSX)

		oStructX3:SeekX3(aStructSX[nSX,3],.T.,.F.,.F.)
		If GetSx3Cache(aStructSX[nSX,3],"X3_PROPRI") != "U"
			If cLstCampos == ""
	   			cLstCampos := aStructSX[nSX,3]
	   		Else
	   			cLstCampos := cLstCampos + "," + aStructSX[nSX,3]
	   		EndIf
	   	EndIf
	Next nSX

	oStructX3:Destroy()
Return cLstCampos

Static Function GetGWDCpos()
	Local aCpoVal := {;
						{ "GWD_CDTRP" , GX3->GX3_CDEMIT	},;
						{ "GWD_NRMOV" , GX3->GX3_NRMOV	},;
						{ "GWD_CDPTCT", GX4->GX4_CDPTCT	},;
						{ "GWD_DTOCOR", GX4->GX4_DTSAI	},;
						{ "GWD_HROCOR", GX4->GX4_HRSAI	};
						}
Return aCpoVal

Static Function A523AbreCad(oModel, oView)
	Local nCount
	Local aCpoVal := GetGWDCpos()

	For nCount := 1 To Len(aCpoVal)
		oModel:SetValue('GFEA032_GWD', aCpoVal[nCount][1], aCpoVal[nCount][2])
	Next nCount

Return

Static Function CriaBrwEnderecos()
	Local cTmp
	Local bChange

	oBrowse2:= FWMBrowse():New()
	oBrowse2:SetTemporary(.T.)
	oBrowse2:SetAlias(cAliasEnd)
	oBrowse2:SetFields(aStruEnd)
	oBrowse2:DisableDetails()
	oBrowse2:DisableConfig()
	oBrowse2:DisableFilter()
	oBrowse2:DisableLocate()
	oBrowse2:DisableSeek()
	oBrowse2:SetMenuDef("")
	oBrowse2:SetAmbiente(.F.)
	oBrowse2:SetWalkthru(.F.)
	oBrowse2:SetFixedBrowse(.T.)
	oBrowse2:SetDescription("Endereços")
	oBrowse2:SetOwner(oPnlEnderecos)
	oBrowse2:Activate()

	If Type("oBrowse2:bChange") == "B"
		cTmp := GetCbSource(oBrowse2:bChange)
		cTmp := SubStr(cTmp, 1, Len(cTmp) -1) + ", A523ENDBC() }"
		bChange := &(cTmp)
	Else
		bChange := {|| A523ENDBC() }
	EndIf

	oBrowse2:SetChange(bChange)
Return

Static Function CriaBrwVeiculos()
	oBrowse:= FWMBrowse():New()
	oBrowse:SetTemporary(.T.)
	oBrowse:SetAlias(cAliasVeic)
	oBrowse:SetFields(aStruVei)
	oBrowse:DisableDetails()
	oBrowse:DisableConfig()
	oBrowse:DisableFilter()
	oBrowse:DisableLocate()
	oBrowse:DisableSeek()
	oBrowse:SetMenuDef("")
	oBrowse:SetAmbiente(.F.)
	oBrowse:SetWalkthru(.F.)
	oBrowse:SetFixedBrowse(.T.)
	oBrowse:SetDescription("Veículos")

	oBrowse:AddLegend("GX4_SIT=='1'", "BLACK", "Não avaliado", "2")
	oBrowse:AddLegend("GX4_SIT=='2'", "GREEN", "Aprovado", "2")
	oBrowse:AddLegend("GX4_SIT=='3'", "RED"  , "Reprovado", "2")

	oBrowse:AddLegend("GX3_SIT=='1'", "GREEN" , "Aberto","1")
	oBrowse:AddLegend("GX3_SIT=='2' .And. (Empty(GX4_DTSAI) .Or. (!Empty(GX4_DTSAI) .And. GX4_SIT == '3'))", "BLUE"  , "Movimentado","1")
	oBrowse:AddLegend("GX3_SIT=='3'", "WHITE" , "Em Fila","1")
	oBrowse:AddLegend("GX3_SIT=='4'", "ORANGE", "Endereçado","1")
	oBrowse:AddLegend("GX3_SIT=='5'", "RED"   , "Cancelado","1")
	oBrowse:AddLegend("!Empty(GX4_DTSAI) .And. GX4_SIT != '3'", "BLACK" , "Concluído","1")

	oBrowse:SetOwner(oPnlVeiculos)
	oBrowse:Activate()

	If Type("oBrowse:bChange") == "B"
		cTmp := GetCbSource(oBrowse:bChange)
		cTmp := SubStr(cTmp, 1, Len(cTmp) -1) + ", A523VEICBC() }"
		bChange := &(cTmp)
	Else
		bChange := {|| A523VEICBC() }
	EndIf

	oBrowse:SetChange(bChange)
Return

Function GetCheckList()
	Local cQuery  := ""
	Local cStatus := ""
	Local cAliasT := GetNextAlias()

	cQuery += "SELECT GX5_RESPOS,GVH_IDIMPE "
	cQuery += " FROM " + RetSqlName("GX4") + " GX4 "
	cQuery += " INNER JOIN " + RetSqlName("GX5") + " GX5"
	cQuery += " ON GX4_FILIAL = GX5_FILIAL"
	cQuery += "	AND GX4_NRMOV = GX5_NRMOV"
	cQuery += "	AND GX4_CDPTCT = GX5_CDPTCT"
	cQuery += "	AND GX4_SEQ = GX5_SEQ"
	cQuery += "	LEFT JOIN " + RetSqlName("GVH") + " GVH "
	cQuery += "	ON GVH_FILIAL = GX4_FILIAL"
	cQuery += "	AND GX4_CDPTCT = GVH_CDPTCT"
	cQuery += "	AND GX5_CDPERG = GVH_CDPERG"
	cQuery += "	AND GVH_IDIMPE = '1'"
	cQuery += "	WHERE GX4.D_E_L_E_T_ = '' AND GX5.D_E_L_E_T_ = '' AND GVH.D_E_L_E_T_ = ''"
	cQuery += "	AND GX4_FILIAL = '" + GX4->GX4_FILIAL + "'"
	cQuery += "	AND GX4_NRMOV  = '" + GX4->GX4_NRMOV  + "'"
	cQuery += "	AND GX4_CDPTCT = '" + GX4->GX4_CDPTCT + "'"
	cQuery += "	AND GX4_SEQ    = '" + GX4->GX4_SEQ    + "'"
	cQuery += "	ORDER BY GX5_RESPOS DESC"
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,ChangeQuery(cQuery)),cAliasT, .F., .T.)
	If (cAliasT)->(Eof())
		cStatus := "Não Checado"
	ElseIf (cAliasT)->GVH_IDIMPE == "1" .And. (cAliasT)->GX5_RESPOS == "2"
		cStatus := "Reprovado"
	Else
		cStatus := "Aprovado"
	EndIf
	(cAliasT)->(dbCloseArea())
Return cStatus

Static Function A523PROCU(cPlaca)
	Local cQuery 	:= ""
	Local cSitGX3	:= ""
	Local cDTENTR 	:= ""
	Local cSitGX4	:= ""
	Local cDescAtu	:= ""
	Local cPontoAtu := ""
	Local cMSGRPROC := ""
	Local CProxPont	:= ""
	Local CProxPontN:= ""
	Local cAliasT 	:= GetNextAlias()

	cQuery += " SELECT *"
	cQuery += " FROM " + RetSqlName("GX6") + " GX6"
	cQuery += "	INNER JOIN " + RetSqlName("GX4") + " GX4"
	cQuery += "	ON GX4.GX4_NRMOV = GX6.GX6_NRMOV"
	cQuery += "	INNER JOIN " + RetSqlName("GX3") + " GX3"
	cQuery += "	ON GX3.GX3_NRMOV = GX6.GX6_NRMOV"
	cQuery += "	AND GX3.D_E_L_E_T_ = ''"
	cQuery += "	AND GX6.GX6_CDVEIC = '" + cPlaca + "'"
	cQuery += "	AND GX6.D_E_L_E_T_ = ''"
	cQuery += " ORDER BY GX6.GX6_NRMOV DESC, GX3.GX3_DTCRIA DESC, GX3.GX3_HRCRIA DESC "

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,ChangeQuery(cQuery)),cAliasT, .F., .T.)
	(cAliasT)->(dbGoTop())

	If !(cAliasT)->(Eof()) 
		// GX3_SIT >>>> 1=Aberto;2=Movimentado;3=Em Fila;4=Enderecado;5=Cancelado;6=Concluido
		If (cAliasT)->GX3_SIT == "5"
			GX3->(dbSetOrder(1))
			GX3->(dbSeek((cAliasT)->GX6_FILIAL + (cAliasT)->GX6_NRMOV))
			cMSGRPROC 	:= "Status Movimentação......: Cancelada" + CRLF
			cMSGRPROC 	+= "Última Movimentação......: " + (cAliasT)->GX3_NRMOV + CRLF
			cMotCan		:=  GX3->GX3_MOTCAN
			cMSGRPROC 	+= "Motivo Cancelamento......: " + cMotCan + CRLF + CRLF
			cMSGRPROC 	+= "OBS : Se o veículo ainda se encontra no pátio, informe o motorista sobre o término da operação."
			MsgInfo(cMSGRPROC,"Aviso")
		ElseIf (cAliasT)->GX3_SIT == '6'
			cDTSAI		:=  cValToChar(sToD((cAliasT)->GX4_DTSAI))
			cMSGRPROC	:= "Status Movimentação......: Concluído" + CRLF
			cMSGRPROC 	+= "Última Movimentação......: " + (cAliasT)->GX3_NRMOV + CRLF
			cMSGRPROC 	+= "Data Conclusão Mov........: " + cDTSAI + CRLF + CRLF
			cMSGRPROC 	+= "OBS: Se o veículo ainda se encontra no pátio, informe o motorista sobre o término da operação."
			MsgInfo(cMSGRPROC,"Aviso")
		EndIf

		If (cAliasT)->GX3_SIT $ "1,2,3,4"
			cDTENTR := cValToChar(sToD((cAliasT)->GX4_DTENTR))
			If (cAliasT)->GX3_SIT == "1"
				cSitGX3 := "Aberto"
				cDTENTR := cValToChar(sToD((cAliasT)->GX3_DTCRIA))
			ElseIf (cAliasT)->GX3_SIT == "2"
				cSitGX3 := "Movimentado"
			ElseIf (cAliasT)->GX3_SIT == "3"
				cSitGX3 := "Em Fila"
			ElseIf (cAliasT)->GX3_SIT == "4"
				cSitGX3 := "Endereçado"
			EndIf

			cMSGRPROC := "Status Movimentação.............: " + cSitGX3 + CRLF
			cMSGRPROC += "Última Movimentação.............: " + (cAliasT)->GX3_NRMOV  + CRLF

			GX4->(dbSetOrder(1))
			GX4->(dbSeek( (cAliasT)->GX6_FILIAL + (cAliasT)->GX6_NRMOV ) )
			While !GX4->(Eof()) .and. ((cAliasT)->GX6_FILIAL + (cAliasT)->GX6_NRMOV == GX4->GX4_FILIAL + GX4->GX4_NRMOV)
				If Empty(GX4->GX4_DTSAI)

					If GX4->GX4_SIT == "1"
						cSitGX4 := "Não Avaliado"
					ElseIf GX4->GX4_SIT == "2"
						cSitGX4 := "Aprovado"
					ElseIf GX4->GX4_SIT == "3"
						cSitGX4 := "Reprovado"
					EndIf
					GVF->(dbSetOrder(1))
					GVF->(dbSeek( xFilial("GVF") + GX4->GX4_CDPTCT))
					cPontoAtu 	:= GX4->GX4_CDPTCT
					cDescAtu 	:= GVF->GVF_DSPTCT
					//Procura o ponto de controle posicionado
					cMSGRPROC += "Ponto de Controle Atual..........: " + cpontoAtu + " - " + cDescAtu + CRLF 
					cMSGRPROC += "Status Ponto de Controle.......: " + cSitGX4  + CRLF

					GX4->(dbSkip())
					//Procura o Proximo ponto de Controle.
					GVF->(dbSetOrder(1))
					GVF->(dbSeek(xFilial("GVF") + GX4->GX4_CDPTCT))
					CProxPont	:= GX4->GX4_CDPTCT
					CProxPontN	:= GVF->GVF_DSPTCT

					Exit
				EndIf

				GX4->(dbSkip())
			EndDo

			GX3->(dbSetOrder(1))
			GX3->(dbSeek((cAliasT)->GX6_FILIAL + (cAliasT)->GX6_NRMOV))
			GVC->(dbSetOrder(1))
			GVC->(dbSeek(xFilial("GVC")+ GX3->GX3_CDOPER))
			cMSGRPROC += "Operação...................................: " + GX3->GX3_CDOPER + " - " + GVC->GVC_DSOPER + CRLF

			GX4->(dbSetOrder(1))
			GX4->(dbSeek( (cAliasT)->GX6_FILIAL + (cAliasT)->GX6_NRMOV ) )
			GVI->( dbSetOrder(1) )
			GVI->( dbSeek(GX3->GX3_FILIAL + GX3->GX3_CDOPER + GX4->GX4_SEQ) )
			cMSGRPROC += "Configuração Operação.........: " + GVI->GVI_SEQ + " - " + GVI->GVI_DSCONF + CRLF
			If 	cPontoAtu != CProxPont
				cMSGRPROC += "Próximo Ponto de Controle....: " + CProxPont + " - " + CProxPontN	 + CRLF + CRLF
				cMSGRPROC += "OBS: Se o veículo não se encontra no Ponto de Controle "+ CProxPont + " - " + CProxPontN  +" encaminhe-o para lá. "
			EndIf

			MsgInfo(cMSGRPROC,"Aviso")
 		EndIf
	Else
		GU8->(dbSetOrder(1))
		If GU8->( dbSeek(xFilial("GU8")+cPlaca))
			GFEMessage(0, GFEA523008, STR0012)
		ElseIf !empty(cPlaca)
			GFEMessage(0, GFEA523009, STR0013)
		EndIf 			
	EndIf

	(cAliasT)->(dbCloseArea())
Return 


