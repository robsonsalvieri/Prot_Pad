#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
//-------------------------------------------------------------------
//Inclusão Pátios 12.1.4
/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEC512A
Painel de Motoristas

Uso Restrito.

@sample
GFEC512A()

@author Helder Fuckner dos Santos 
@since 17/04/14
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFEC512A(aParam)
	Local aCoors     	 	:= FWGetDialogSize( oMainWnd )

	Private cFilialDe  	:= aParam[1]
	Private cFilialAte 	:= aParam[2]
	Private dDataDe  		:= If(Empty(aParam[3]),DDATABASE -30 ,aParam[3])
	Private dDataAte 		:= If(Empty(aParam[4]),DDATABASE     ,aParam[4])                   
	Private cCodTransp 	:= aParam[5]

	Private oGrfSitAg, oGrfSitMov, oGrfMovOp, oGridEst, oGrid2, oGrid31, oGrid32, oGrid4, oGrid5, oGrid6, oGrid7
	Private aGrfSitAg, aGrfSitMov, aGrfMovOp, aGridEst, aGrid2, aGrid31, aGrid32, aGrid4, aGrid5, aGrid6, aGrid7
	Private oPnl1Agend, oPnl1Mov, oPnl1Oper, oPnl1Brw, oPnl2Brw, oPnl3Brw1, oPnl3Brw2

	Private cCodMot   	:= GUU->GUU_CDMTR
	Private cNmMot    	:= GUU->GUU_NMMTR
	Private cPseud		:= GUU->GUU_PSEUD
	Private cCPFMot		:= GUU->GUU_IDFED

	Private cTitulo    	:= 'Painel de Motoristas - Movimentação'
	Private nInd			:= 0
	Private cFiltro		:= ""

	Private oWIN_TOP, oWIN_LEFT, oWIN_MIDDLE, oWIN_RIGHT

	Private cAlias2, cAlias31, cAlias32, cAlias4, cAlias5, cAlias6, cAlias7
	Private oRelacGX4

	Define MsDialog oDlg Title cTitulo From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel

	/*Criando objeto Layer*/
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDLG,.F.)

	// ############################
	// ATENÇÃO: Deixar sobrando ao menos 2% ... 
	// pois ao usuário navegar pelos PAINÉIS passam automaticamente das margens, não mostrando os botões corretamente
	oFWLayer:AddLine('LINE_TOP',24,.F.)
	oFWLayer:AddLine('LINE_MIDDLE',74,.F.)
	// ############################
	
	// Veiculo selecionado
	oFWLayer:AddCollumn('COL_TOP',100,.T.,'LINE_TOP')
	oFWLayer:AddWindow('COL_TOP','WIN_TOP','Motorista',100,.F.,.F.,,'LINE_TOP',)
	oWIN_TOP		:= oFWLayer:GetWinPanel('COL_TOP','WIN_TOP', 'LINE_TOP')
	oWIN_MIDDLE	:= oFWLayer:GetLinePanel('LINE_MIDDLE')

	//Transportador - Cabeçalho
	@ 001, 008 SAY   oCodMot	PROMPT "Cód Motorista"	SIZE 040, 008 OF oWIN_TOP			COLORS 0, 16777215 PIXEL
	@ 001, 070 SAY   oNmMot	PROMPT "Nome"				SIZE 040, 008 OF oWIN_TOP			COLORS 0, 16777215 PIXEL
	@ 001, 190 SAY   oPseud	PROMPT "Pseud/Apelido"	SIZE 040, 008 OF oWIN_TOP			COLORS 0, 16777215 PIXEL
	@ 001, 260 SAY   oCPFMot	PROMPT "CPF"				SIZE 040, 008 OF oWIN_TOP			COLORS 0, 16777215 PIXEL
	@ 010, 008 MSGET oCodMot		VAR cCodMot 			SIZE 055, 010 OF oWIN_TOP READONLY	COLORS 0, 16777215 PIXEL
	@ 010, 070 MSGET oNmMot  	VAR cNmMot  			SIZE 110, 010 OF oWIN_TOP READONLY	COLORS 0, 16777215 PIXEL
	@ 010, 190 MSGET oPseud  	VAR cPseud  			SIZE 060, 010 OF oWIN_TOP READONLY	COLORS 0, 16777215 PIXEL
	@ 010, 260 MSGET oCPFMot		VAR cCPFMot PICTURE "@R 999.999.999-99" SIZE 050, 010 OF oWIN_TOP READONLY COLORS 0, 16777215 PIXEL

 	oDLG:Activate(,,,.T.,,,{|| Processa({|| Iniciar() }) })

	GFEDelTab(cAlias2)
	GFEDelTab(cAlias31)
	GFEDelTab(cAlias32)
	GFEDelTab(cAlias4)
	GFEDelTab(cAlias5)
	GFEDelTab(cAlias6)
	GFEDelTab(cAlias7)	

Return


Static Function Iniciar()
	Local nCount := 0

	
	oFolder := TFolder():New(0,0,{"Gráficos","Agendamentos","Movimentações","Ocorrências","Romaneios","Transportador","Veículos"},,oWIN_MIDDLE,,,,.T.,,(oWIN_MIDDLE:nwidth/2),(oWIN_MIDDLE:nHeight/2))
	oFolder:Align := CONTROL_ALIGN_ALLCLIENT

	// ########## 1 - Graficos
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oFolder:aDialogs[1],.F.)
	
	oFWLayer:AddLine('LINE_TOP',40,.F.)
	oFWLayer:AddLine('LINE_DOWN',60,.F.)

	oFWLayer:AddCollumn('COL_LEFT',33,.T.,'LINE_TOP')
	oFWLayer:AddCollumn('COL_MIDDLE',33,.T.,'LINE_TOP')
	oFWLayer:AddCollumn('COL_RIGHT',33,.T.,'LINE_TOP')
	oFWLayer:AddCollumn('COL_BRW',100,.T.,'LINE_DOWN')
	
	oPnl1Agend	:= oFWLayer:GetColPanel('COL_LEFT','LINE_TOP')
	oPnl1Mov	:= oFWLayer:GetColPanel('COL_MIDDLE','LINE_TOP')
	oPnl1Oper 	:= oFWLayer:GetColPanel('COL_RIGHT','LINE_TOP')
	oPnl1Brw	:= oFWLayer:GetColPanel('COL_BRW','LINE_DOWN')

	Load1()

	GFEC512GRC("oGrfSitAg"	,"Sit Agendamentos"	,oPnl1Agend,	aGrfSitAg)
	GFEC512GRC("oGrfSitMov"	,"Sit Movimentações"	,oPnl1Mov,		aGrfSitMov)
	GFEC512GRC("oGrfMovOp"	,"Mov por Operação"	,oPnl1Oper,	aGrfMovOp)

   	oGridEst := FWBrowse():New()
	oGridEst:SetOwner(oPnl1Brw)
	oGridEst:SetDescription("Estatísticas")
	oGridEst:SetDataArray()
	oGridEst:DisableFilter()
	oGridEst:DisableConfig()
	oGridEst:SetArray(aGridEst)
	// Function GFEC001COL(cTitulo,xArrData,cPicture,nAlign,nSize,cBrowse,cTipo,nDecimal)
   	oGridEst:SetColumns(GFEC001COL("Descrição",1,,1,80,"oGridEst"))
	oGridEst:SetColumns(GFEC001COL("Valor",2,,1,40,"oGridEst"))
	oGridEst:Activate()

	// PROCESSA GRAFICOS
	Processa({|| Atualiza() })


	// ########## 2 - Agendamentos
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oFolder:aDialogs[2],.F.)

	oFWLayer:AddLine('LINEAG',100,.F.)
	oFWLayer:AddCollumn('COL_BRWAG',100,.T.,'LINEAG')

	oPnl2Brw := oFWLayer:GetColPanel('COL_BRWAG','LINEAG')
	aGrid2 := {;
				{"Filial"	     	,"GWV_FILIAL"	,"C",TamSX3("GWV_FILIAL")[1],0,"",1,10},;
				{"Nr agendamento"	,"GWV_NRAGEN"	,"C",TamSX3("GWV_NRAGEN")[1],0,"",1,10},;
				{"Situação"      	,"SIT"			,"C",20,0,"",1,10},;
				{"Data Agend"		,"GWV_DTAGEN" ,"D",TamSX3("GWV_DTAGEN")[1],0,"",1,10},;
				{"Pontualidade"	,"PONT"  		,"C",30  ,0,"",1,10}}

	cAlias2 := Load2()
	
	oGrid2:= FWMBrowse():New()
	oGrid2:SetOwner(oPnl2Brw)
	oGrid2:SetDescription("Documentos de Carga")
	oGrid2:SetAlias(cAlias2)
	oGrid2:SetLocate()
	oGrid2:DisableDetails()
	oGrid2:DisableConfig()
	oGrid2:SetAmbiente(.F.)
	oGrid2:SetWalkthru(.F.)
	oGrid2:SetProfileID("1") 
	oGrid2:SetMenuDef("")
	oGrid2:AddButton("Sair",{|| oDLG:End()},,1)
	oGrid2:AddButton("Consultar agendamento",{|| VisualAgen() },,2)
	
	For nCount := 1 To Len(aGrid2)
		oGrid2:AddColumn({ aGrid2[nCount][1],;
						     &("{|| (cAlias2)->" + aGrid2[nCount][2] + "}"),;
						     aGrid2[nCount][3],;
						     aGrid2[nCount][6],;
						     aGrid2[nCount][7],;
						     aGrid2[nCount][8],;
						     aGrid2[nCount][5],;
						     .F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}})						     
	Next nCount
	
	oGrid2:Activate()


	// ########## 3 - Movimentacoes
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oFolder:aDialogs[3],.F.)

	oFWLayer:AddLine('LINEMV1',50,.F.)
	oFWLayer:AddLine('LINEMV2',50,.F.)
	oFWLayer:AddCollumn('COL_BRWMOV',100,.T.,'LINEMV1')
	oFWLayer:AddCollumn('COL_BRWPTC',100,.T.,'LINEMV2')

	oPnl3Brw1 := oFWLayer:GetColPanel('COL_BRWMOV','LINEMV1')
	oPnl3Brw2 := oFWLayer:GetColPanel('COL_BRWPTC','LINEMV2')
	
	//Browses
	CursorWait()
	oPnl3Brw1:SetUpdatesEnabled(.F.)
	oPnl3Brw2:SetUpdatesEnabled(.F.)
	

	// ####  BROWSE 3.1
	aGrid31 := {;
				{"Filial"	     		,"GX3_FILIAL"	,"C",TamSX3("GX3_FILIAL")[1],0,"",1,10},;
				{"Nr Movimentação"	,"GX3_NRMOV"	,"C",TamSX3("GX3_NRMOV")[1],0,"",1,10},;
				{"Data Criação"		,"GX3_DTCRIA"	,"D",TamSX3("GX3_DTCRIA")[1],0,"",1,10},;
				{"Situação"			,"GX3_SIT"		,"C",15,0,"",1,10},;
				{"Operação"			,"GX3_CDOPER"	,"C",TamSX3("GX3_CDOPER")[1],0,"",1,10},;
				{"Seq"					,"GX3_SEQ"		,"C",TamSX3("GX3_SEQ")[1],0,"",1,10},;
				{"Desc Config"		,"GVI_DSCONF"	,"C",TamSX3("GVI_DSCONF")[1],0,"",1,10},;
				{"Dt Início"			,"GX4_DTENTR"	,"D",TamSX3("GX4_DTENTR")[1],0,"",1,10},;
				{"Dt Fim"				,"GX4_DTSAI"	,"D",TamSX3("GX4_DTSAI")[1],0,"",1,10}}

	cAlias31 := Load31()

	oGrid31:= FWMBrowse():New()
	oGrid31:SetOwner(oPnl3Brw1)
	oGrid31:SetDescription("Movimentos")
	oGrid31:SetAlias(cAlias31)
	oGrid31:SetLocate()
	oGrid31:DisableDetails()
	oGrid31:DisableConfig()
	oGrid31:SetAmbiente(.F.)
	oGrid31:SetWalkthru(.F.)
	oGrid31:SetProfileID("1") 
	oGrid31:SetMenuDef("")
	oGrid31:AddButton("Consultar movimentação",{|| VisualMov() },,2)

	For nCount := 1 To Len(aGrid31)
		oGrid31:AddColumn({ aGrid31[nCount][1],;
						     &("{|| (cAlias31)->" + aGrid31[nCount][2] + "}"),;
						     aGrid31[nCount][3],;
						     aGrid31[nCount][6],;
						     aGrid31[nCount][7],;
						     aGrid31[nCount][8],;
						     aGrid31[nCount][5],;
						     .F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}})						     
	Next nCount
	
	oGrid31:Activate()
	
	
	// ####  BROWSE 3.2	
	aGrid32 := {;
				{"Ponto de Controle"	,"GX4_CDPTCT"	,"C",TamSX3("GX4_CDPTCT")[1],0,"",1,10},;
				{"Situação"			,"GX4_SIT"		,"C",15,0,"",1,10},;
				{"Dt Início"			,"GX4_DTENTR"	,"D",TamSX3("GX4_DTENTR")[1],0,"",1,10},;
				{"Hr Início"			,"GX4_HRENTR"	,"C",TamSX3("GX4_HRENTR")[1],0,"",1,10},;
				{"Dt Fim"				,"GX4_DTSAI"	,"D",TamSX3("GX4_DTSAI")[1],0,"",1,10},;
				{"Hr Fim"				,"GX4_HRSAI"	,"C",TamSX3("GX4_HRSAI")[1],0,"",1,10}}

	cAlias32 := Load32()

	oGrid32:= FWMBrowse():New()
	oGrid32:SetOwner(oPnl3Brw2)
	oGrid32:SetDescription("Pontos de Controle")
	oGrid32:SetAlias(cAlias32)
	oGrid32:SetLocate()
	oGrid32:DisableDetails()
	oGrid32:DisableConfig()
	oGrid32:SetAmbiente(.F.)
	oGrid32:SetWalkthru(.F.)
	oGrid32:SetProfileID("2") 
	oGrid32:SetMenuDef("")

	For nCount := 1 To Len(aGrid32)
		oGrid32:AddColumn({ aGrid32[nCount][1],;
						     &("{|| (cAlias32)->" + aGrid32[nCount][2] + "}"),;
						     aGrid32[nCount][3],;
						     aGrid32[nCount][6],;
						     aGrid32[nCount][7],;
						     aGrid32[nCount][8],;
						     aGrid32[nCount][5],;
						     .F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}})						     
	Next nCount
	
	oGrid32:Activate()


	// Relaciona BROWSES
	oGrid32:SetFocus()
	oGrid31:SetFocus()
	//...Relation
	oRelacGX4:= FWBrwRelation():New()
	oRelacGX4:AddRelation(oGrid31, oGrid32, {{'GX4_FILIAL', 'GX3_FILIAL'}, {'GX4_NRMOV', 'GX3_NRMOV'}})
	oRelacGX4:Activate()
	oPnl3Brw1:SetUpdatesEnabled(.T.)
	oPnl3Brw2:SetUpdatesEnabled(.T.)
	CursorArrow()		
	

	// ########## 4 - Ocorrencias
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oFolder:aDialogs[4],.F.)

	oFWLayer:AddLine('LINEOCOR',100,.F.)
	oFWLayer:AddCollumn('COL_BRWOCOR',100,.T.,'LINEOCOR')

	oPnl4Brw := oFWLayer:GetColPanel('COL_BRWOCOR','LINEOCOR')
	
	aGrid4 := {;
				{"Filial"	     	,"GWD_FILIAL"	,"C",TamSX3("GWD_FILIAL")[1],0,"",1,10},;
				{"Nr Ocorrência"	,"GWD_NROCO"	,"C",TamSX3("GWD_NROCO")[1],0,"",1,10},;
				{"Dt Ocorrência"	,"GWD_DTOCOR"	,"D",TamSX3("GWD_DTOCOR")[1],0,"",1,10},;
				{"Tipo"	     	,"GWD_CDTIPO"	,"C",TamSX3("GU5_DESC")[1],0,"",1,10},;
				{"Motivo"	     	,"GWD_CDMOT"	,"C",TamSX3("GU6_DESC")[1],0,"",1,10},;
				{"Transp"	     	,"GWD_CDTRP"	,"C",TamSX3("GWD_CDTRP")[1],0,"",1,10},;
				{"Nome Transp"	,"GU3_NMEMIT"	,"C",TamSX3("GU3_NMEMIT")[1],0,"",1,10}}

	cAlias4 := Load4()
	
	oGrid4:= FWMBrowse():New()
	oGrid4:SetOwner(oPnl4Brw)
	oGrid4:SetDescription("Ocorrências")
	oGrid4:SetAlias(cAlias4)
	oGrid4:SetLocate()
	oGrid4:DisableDetails()
	oGrid4:DisableConfig()
	oGrid4:SetAmbiente(.F.)
	oGrid4:SetWalkthru(.F.)
	oGrid4:SetProfileID("1") 
	oGrid4:SetMenuDef("")
	oGrid4:AddButton("Sair",{|| oDLG:End()},,1)
	oGrid4:AddButton("Consultar ocorrência",{|| VisualOcor() },,2)
	
	For nCount := 1 To Len(aGrid4)
		oGrid4:AddColumn({ aGrid4[nCount][1],;
						     &("{|| (cAlias4)->" + aGrid4[nCount][2] + "}"),;
						     aGrid4[nCount][3],;
						     aGrid4[nCount][6],;
						     aGrid4[nCount][7],;
						     aGrid4[nCount][8],;
						     aGrid4[nCount][5],;
						     .F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}})						     
	Next nCount
	
	oGrid4:Activate()
	
	
	// ########## 5 - Romaneios
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oFolder:aDialogs[5],.F.)

	oFWLayer:AddLine('LINEROM',100,.F.)
	oFWLayer:AddCollumn('COL_BRWROM',100,.T.,'LINEROM')

	oPnl5Brw := oFWLayer:GetColPanel('COL_BRWROM','LINEROM')
	aGrid5 := {;
				{"Filial"	     		,"GWN_FILIAL"	,"C",TamSX3("GWN_FILIAL")[1],0,"",1,10},;
				{"Nr Romaneio"		,"GWN_NRROM"	,"C",TamSX3("GWN_NRROM")[1],0,"",1,10},;
				{"Situação"      		,"GWN_SIT"		,"C",15,0,"",1,10},;
				{"Data Criação"		,"GWN_DTIMPL"	,"D",TamSX3("GWN_DTIMPL")[1],0,"",1,10},;
				{"Tipo Oper"			,"GWN_CDTPOP"	,"C",TamSX3("GWN_CDTPOP")[1],0,"",1,10},;
				{"Clas Frete"			,"GWN_CDCLFR"	,"C",TamSX3("GWN_CDCLFR")[1],0,"",1,10},;
				{"Transp"				,"GWN_CDTRP" 	,"C",TamSX3("GWN_CDTRP")[1],0,"",1,10},;
				{"Nome Transportadora","GU3_NMEMIT","C",TamSX3("GU3_NMEMIT")[1],0,"",1,10}	} 

	cAlias5 := Load5()
	
	oGrid5:= FWMBrowse():New()
	oGrid5:SetOwner(oPnl5Brw)
	oGrid5:SetDescription("Romaneios")
	oGrid5:SetAlias(cAlias5)
	oGrid5:SetLocate()
	oGrid5:DisableDetails()
	oGrid5:DisableConfig()
	oGrid5:SetAmbiente(.F.)
	oGrid5:SetWalkthru(.F.)
	oGrid5:SetProfileID("1") 
	oGrid5:SetMenuDef("")
	oGrid5:AddButton("Sair",{|| oDLG:End()},,1)
	oGrid5:AddButton("Consultar romaneio",{|| VisualRoma() },,2)
	
	For nCount := 1 To Len(aGrid5)
		oGrid5:AddColumn({ aGrid5[nCount][1],;
						     &("{|| (cAlias5)->" + aGrid5[nCount][2] + "}"),;
						     aGrid5[nCount][3],;
						     aGrid5[nCount][6],;
						     aGrid5[nCount][7],;
						     aGrid5[nCount][8],;
						     aGrid5[nCount][5],;
						     .F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}})						     
	Next nCount
	
	oGrid5:Activate()


	// ########## 6 - Transportadores
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oFolder:aDialogs[6],.F.)

	oFWLayer:AddLine('LINEMOT',100,.F.)
	oFWLayer:AddCollumn('COL_BRWMOT',100,.T.,'LINEMOT')

	oPnl6Brw := oFWLayer:GetColPanel('COL_BRWMOT','LINEMOT')
//				{"Filial"			,"GUU_FILIAL"	,"C",TamSX3("GUU_FILIAL")[1],0,"",1,10},;
	aGrid6 := {;
				{"Cód Emitente"	,"GU3_CDEMIT"	,"C",TamSX3("GU3_CDEMIT")[1],0,"",1,10},;
				{"Nome"			,"GU3_NMEMIT"	,"C",TamSX3("GU3_NMEMIT")[1],0,"",1,10},;
				{"Nome Abrev"		,"GU3_NMABRV"	,"C",TamSX3("GU3_NMABRV")[1],0,"",1,10},;
				{"Natureza"		,"GU3_NATUR"	,"C",TamSX3("GU3_NATUR")[1],0,"",1,10},;
				{"Situação"		,"GU3_SIT"		,"C",15,0,"",1,10},;
				{"Autonomo?"		,"GU3_AUTON"	,"C",10,0,"",1,10},;
				{"Transportador?"	,"GU3_TRANSP"	,"C",10,0,"",1,10},;
				{"Nome Cidade"	,"GU7_NMCID"	,"C",TamSX3("GU7_NMCID")[1],0,"",1,10},;
				{"Estado"			,"GU7_CDUF"	,"C",TamSX3("GU7_CDUF")[1],0,"",1,10} }

	cAlias6 := Load6()

	oGrid6:= FWMBrowse():New()
	oGrid6:SetOwner(oPnl6Brw)
	oGrid6:SetDescription("Transportadores")
	oGrid6:SetAlias(cAlias6)
	oGrid6:SetLocate()
	oGrid6:DisableDetails()
	oGrid6:DisableConfig()
	oGrid6:SetAmbiente(.F.)
	oGrid6:SetWalkthru(.F.)
	oGrid6:SetProfileID("1") 
	oGrid6:SetMenuDef("")
	oGrid6:AddButton("Sair",{|| oDLG:End()},,1)
	oGrid6:AddButton("Consultar transportador",{|| VisualTransp() },,2)
	
	For nCount := 1 To Len(aGrid6)
		oGrid6:AddColumn({ aGrid6[nCount][1],;
						     &("{|| (cAlias6)->" + aGrid6[nCount][2] + "}"),;
						     aGrid6[nCount][3],;
						     aGrid6[nCount][6],;
						     aGrid6[nCount][7],;
						     aGrid6[nCount][8],;
						     aGrid6[nCount][5],;
						     .F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}})						     
	Next nCount

	oGrid6:Activate()

	// ########## 7 - Veiculos
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oFolder:aDialogs[7],.F.)

	oFWLayer:AddLine('LINEVEI',100,.F.)
	oFWLayer:AddCollumn('COL_BRWVEI',100,.T.,'LINEVEI')

	oPnl7Brw := oFWLayer:GetColPanel('COL_BRWVEI','LINEVEI')

	aGrid7 := {;
				{"Cod"				,"GU8_CDVEIC"	,"C",TamSX3("GU8_CDVEIC")[1],0,"",1,10},;
				{"Tipo"			,"GU8_CDTPVC"	,"C",25,0,"",1,10},;
				{"Placa"			,"GU8_PLACA"	,"C",TamSX3("GU8_PLACA")[1],0,"",1,10},;
				{"Proprietário"	,"GU8_CDPROP"	,"C",TamSX3("GU8_CDPROP")[1],0,"",1,10},;
				{"Nome Prop"		,"GU3_NMEMIT"	,"C",TamSX3("GU3_NMEMIT")[1],0,"",1,10},;
				{"Tipo"			,"GU8_TPPROP"	,"C",15,0,"",1,10},;
				{"Tipo Acesso"	,"GU8_TPACES"	,"C",15,0,"",1,10},;
				{"Situação"		,"GU8_SIT"		,"C",15,0,"",1,10},;
				{"Volume"			,"GU8_VOLUT"	,"N",TamSX3("GU8_VOLUT")[1],TamSX3("GU8_VOLUT")[2],"",1,10},;
				{"Carga"			,"GU8_CARGUT"	,"N",TamSX3("GU8_CARGUT")[1],TamSX3("GU8_VOLUT")[2],"",1,10} }

	cAlias7 := Load7()

	oGrid7:= FWMBrowse():New()
	oGrid7:SetOwner(oPnl7Brw)
	oGrid7:SetDescription("Veículos")
	oGrid7:SetAlias(cAlias7)
	oGrid7:SetLocate()
	oGrid7:DisableDetails()
	oGrid7:DisableConfig()
	oGrid7:SetAmbiente(.F.)
	oGrid7:SetWalkthru(.F.)
	oGrid7:SetProfileID("1") 
	oGrid7:SetMenuDef("")
	oGrid7:AddButton("Sair",{|| oDLG:End()},,1)
	oGrid7:AddButton("Consultar veículo",{|| VisualVei() },,2)
	
	For nCount := 1 To Len(aGrid7)
		oGrid7:AddColumn({ aGrid7[nCount][1],;
						     &("{|| (cAlias7)->" + aGrid7[nCount][2] + "}"),;
						     aGrid7[nCount][3],;
						     aGrid7[nCount][6],;
						     aGrid7[nCount][7],;
						     aGrid7[nCount][8],;
						     aGrid7[nCount][5],;
						     .F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}})						     
	Next nCount

	oGrid7:Activate()

Return Nil

//---------------------------------------------------------------------------------------------------
Static Function Load1()
	Local cQuery		:= ''
	Local cTmp   		:= ''
	Local nTmpMed		:= 0
	Local nTmpMedAt  	:= 0
	Local nTmpMedMax 	:= 0
	Local nTmpMedMin 	:= 0
	Local dtEnt
	Local hrEnt
	Local dtSai
	Local hrSai

	aGrfSitAg	:= {}
	aGrfSitMov	:= {}
	aGrfMovOp	:= {}
	aGridEst  	:= {}

	cFiltro  = " WHERE GX3.D_E_L_E_T_ = '' "
	cFiltro += " 	 AND GX3.GX3_FILIAL >= '" + cFilialDe + "' AND GX3.GX3_FILIAL <= '" + cFilialAte + "' "
	cFiltro += "   AND GX3.GX3_DTCRIA >= '" + DtoS(dDataDe) + "' AND GX3.GX3_DTCRIA <= '" + DtoS(dDataAte) + "' "
	If Trim(cCodTransp) != "" 
		cFiltro += "   AND GX3.GX3_CDEMIT = '" + cCodTransp + "' "
	EndIf
	If Trim(cCodMot) != "" 
		cFiltro += "   AND GX8.GX8_CDMTR = '" + cCodMot + "' "
	EndIf

	aADD(aGridEst, {"Nome Motorista",	cNmMot })
	aADD(aGridEst, {"Apelido", 			cPseud })
	aADD(aGridEst, {"CPF", 				AllTrim(Transform(cCPFMot, "@R 999.999.999-99")) })
	aADD(aGridEst, {"Data de", 			dDataDe })
	aADD(aGridEst, {"Data até", 		dDataAte })
	
	cQuery := "SELECT		MAX(GX3.GX3_DTCRIA) 	MAX_DTMOV, "
	cQuery += "        	MIN(GX3.GX3_DTCRIA) 	MIN_DTMOV, "
	cQuery += "       	SUM(GWN.QTD_ROM) 	TOT_ROM, "
	cQuery += "       	COUNT(GX3.GX3_NRMOV) TOT_MOVTO, "
	cQuery += "       	SUM(GWV.QTD_AGEN) 	TOT_MOVAG, "
	cQuery += "       	COUNT(CASE WHEN GX3.GX3_SIT = '5' THEN 1 END) TOT_MOVCAN, "
	cQuery += " 			COUNT(CASE WHEN GX3.GX3_SIT = '6' THEN 1 END) TOT_MOVCONC, "
	cQuery += "       	SUM(GX5.QTD_REPROV) TOT_CHKLST, "
	cQuery += "       	SUM(GWD.QTD_OCO) TOT_OCORR, "
	cQuery += "       	SUM(GWD.QTD_OCO_PRV) TOT_OCORRTRP, "
	cQuery += "			SUM(GXA.QTD_DOCS) TOT_DOCCMOV, "
	cQuery += "			SUM(GXA.GW8_VALOR) VALOR, "
	cQuery += "			SUM(GXA.GW8_PESOR) PESO, "
	cQuery += "			SUM(GXA.GW8_VOLUME) VOLUME, "
	cQuery += "			SUM(GX4.GX4_QTPESO) TOT_PESO, "
	cQuery += "			MAX(GX4.GX4_QTPESO) MAX_PESO, "
	cQuery += "			MIN(CASE WHEN GX4.GX4_QTPESO > 0 THEN GX4.GX4_QTPESO END) MIN_PESO, "
	cQuery += "			SUM(GX4.GX4_QTPESO) GX4_QTPESO,"
	cQuery += "			COUNT(CASE WHEN GX4.GX4_QTPESO > 0 THEN 1 END) QTD_QTPESO "

	cQuery += "  FROM " + RetSQLName("GX3") + " GX3 "
	cQuery += " INNER JOIN " + RetSQLName("GX8") + " GX8 ON GX8.GX8_FILIAL = GX3.GX3_FILIAL "
	cQuery += "						 						AND GX8.GX8_NRMOV  = GX3.GX3_NRMOV "
	cQuery += "                      						AND GX8.D_E_L_E_T_ = '' "

	cQuery += " INNER JOIN (SELECT GX4_FILIAL, GX4_NRMOV, SUM(GX4_QTPESO) GX4_QTPESO "
	cQuery += "			      FROM " + RetSQLName("GX4")
	cQuery += "              WHERE D_E_L_E_T_ = '' "
	cQuery += "              GROUP BY GX4_FILIAL, GX4_NRMOV) "
	cQuery += "            GX4 ON GX4.GX4_FILIAL = GX3.GX3_FILIAL "
	cQuery += "			   AND GX4.GX4_NRMOV  = GX3.GX3_NRMOV "

	cQuery += "  LEFT JOIN (SELECT GX5_FILIAL, GX5_NRMOV, COUNT(*) QTD_REPROV "
	cQuery += "               FROM " + RetSQLName("GX5")
	cQuery += "              WHERE D_E_L_E_T_ = '' "
	cQuery += "                AND GX5_RESPOS = '2' "
	cQuery += "              GROUP BY GX5_FILIAL, GX5_NRMOV) "
	cQuery += "            GX5 ON GX5.GX5_FILIAL = GX3.GX3_FILIAL "
	cQuery += "			   AND GX5.GX5_NRMOV  = GX3.GX3_NRMOV "

	cQuery += "  LEFT JOIN (SELECT GWN_FILIAL, GWN_NRMOV, COUNT(*) QTD_ROM "
	cQuery += "               FROM " + RetSQLName("GWN")
	cQuery += "              WHERE D_E_L_E_T_ = '' "
	cQuery += "              GROUP BY GWN_FILIAL, GWN_NRMOV) "
	cQuery += "            GWN ON GWN.GWN_FILIAL = GX3.GX3_FILIAL "
	cQuery += "        		  AND GWN.GWN_NRMOV  = GX3.GX3_NRMOV "

	cQuery += "  LEFT JOIN (SELECT GWD.GWD_FILIAL, GWD.GWD_NRMOV, COUNT(*) QTD_OCO, COUNT(CASE WHEN GU6.GU6_PROVOC = '1' THEN 1 END) QTD_OCO_PRV "
	cQuery += "               FROM " + RetSQLName("GWD") + " GWD "
	cQuery += "               LEFT JOIN " + RetSQLName("GU6") + " GU6 ON GU6.GU6_CDMOT = GWD.GWD_CDMOT "
	cQuery += "              WHERE GWD.D_E_L_E_T_ = '' AND GU6.D_E_L_E_T_ = '' "
	cQuery += "              GROUP BY GWD.GWD_FILIAL, GWD.GWD_NRMOV) "
	cQuery += "            GWD ON GWD.GWD_FILIAL = GX3.GX3_FILIAL "
	cQuery += "			      AND GWD.GWD_NRMOV  = GX3.GX3_NRMOV "

	cQuery += "  LEFT JOIN (SELECT GXA_FILIAL, GXA_NRMOV, COUNT(*) QTD_DOCS, SUM(GW8_PESOR) GW8_PESOR, SUM(GW8_VALOR) GW8_VALOR, SUM(GW8_VOLUME) GW8_VOLUME "
	cQuery += "  			  FROM (SELECT DISTINCT GXA_FILIAL, GXA_NRMOV, GXA_CDTPDC, GXA_EMISDC, GXA_SERDC, GXA_NRDC "
	cQuery += "  			  		   FROM " + RetSQLName("GXA")
	cQuery += "  			  		  WHERE D_E_L_E_T_ = '') G "
	cQuery += "  		     INNER JOIN (SELECT GW8_FILIAL, GW8_CDTPDC, GW8_EMISDC, GW8_SERDC, GW8_NRDC, SUM(GW8_PESOR) GW8_PESOR, SUM(GW8_VOLUME) GW8_VOLUME, SUM(GW8_VALOR) GW8_VALOR  "
	cQuery += "  			               FROM " + RetSQLName("GW8")
	cQuery += "  			              WHERE D_E_L_E_T_ = '' "
	cQuery += "  			              GROUP BY GW8_FILIAL, GW8_CDTPDC, GW8_EMISDC, GW8_SERDC, GW8_NRDC) "
	cQuery += "						  GW8 ON GW8.GW8_FILIAL = G.GXA_FILIAL "
	cQuery += "						     AND GW8.GW8_CDTPDC = G.GXA_CDTPDC "
	cQuery += "						     AND GW8.GW8_EMISDC = G.GXA_EMISDC "
	cQuery += "						     AND GW8.GW8_SERDC  = G.GXA_SERDC "
	cQuery += "						     AND GW8.GW8_NRDC   = G.GXA_NRDC "
	cQuery += "  			 GROUP BY GXA_FILIAL, GXA_NRMOV) "
	cQuery += "				GXA ON GXA.GXA_FILIAL = GX4.GX4_FILIAL "
	cQuery += "	             	AND GXA.GXA_NRMOV  = GX4.GX4_NRMOV "

	cQuery += "   LEFT JOIN (SELECT GWV_FILIAL, GWV_NRMOV, COUNT(*) QTD_AGEN "
	cQuery += "                FROM " + RetSQLName("GWV")
	cQuery += "               WHERE D_E_L_E_T_ = '' "
	cQuery += "               GROUP BY GWV_FILIAL, GWV_NRMOV) "
	cQuery += "             GWV ON GWV.GWV_FILIAL = GX3.GX3_FILIAL "
	cQuery += "                AND GWV.GWV_NRMOV = GX3.GX3_NRMOV "
	
	cQuery += cFiltro
	
	cTmp 	:= GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	If (cTmp)->(RecNo()) > 0
		While (cTmp)->(!Eof())
			// Quantidade de documentos de carga por tipo de documento
			aADD(aGridEst, {"Qtd romaneios",					(cTmp)->TOT_ROM})
			aADD(aGridEst, {"Dt Mov mais antiga", 				StoD((cTmp)->MIN_DTMOV)})
			aADD(aGridEst, {"Dt Mov mais recente",				StoD((cTmp)->MAX_DTMOV)})
			aADD(aGridEst, {"Qtd movimentações",				(cTmp)->TOT_MOVTO})
			aADD(aGridEst, {"Mov com agendamento",				(cTmp)->TOT_MOVAG})
			aADD(aGridEst, {"Mov sem agendamento",				(cTmp)->TOT_MOVTO - (cTmp)->TOT_MOVAG})
			aADD(aGridEst, {"Mov Canceladas",					(cTmp)->TOT_MOVCAN})
			aADD(aGridEst, {"Mov Concluídas",					(cTmp)->TOT_MOVCONC})
			aADD(aGridEst, {"Qtd reprov checklist", 			(cTmp)->TOT_CHKLST})
			aADD(aGridEst, {"Qtd Ocorrências", 				(cTmp)->TOT_OCORR})
			aADD(aGridEst, {"Qtd Ocorrências Transp", 		(cTmp)->TOT_OCORRTRP})
			aADD(aGridEst, {"Qtd Doc Carga Mov", 				(cTmp)->TOT_DOCCMOV})
			aADD(aGridEst, {"Valor Total Doc Carga Mov", 		(cTmp)->VALOR})
			aADD(aGridEst, {"Peso total Doc Carga Mov", 		(cTmp)->PESO})
			aADD(aGridEst, {"Vol Total Doc Carga Mov (m3)", 	(cTmp)->VOLUME})
			If (cTmp)->QTD_QTPESO > 0
				aADD(aGridEst, {"Peso Médio Movto", 				Round( (cTmp)->GX4_QTPESO/(cTmp)->QTD_QTPESO, 2 ) })
			Else
				aADD(aGridEst, {"Peso Médio Movto", 				0 })
			EndIf
			aADD(aGridEst, {"Peso Máx Movto", 					(cTmp)->MAX_PESO})
			If (cTmp)->MIN_PESO == 0
				aADD(aGridEst, {"Peso Min Movto", 				(cTmp)->MAX_PESO})
			Else
				aADD(aGridEst, {"Peso Min Movto", 				(cTmp)->MIN_PESO})
			EndIf
			aADD(aGridEst, {"Total Pesagem Veículo", 			(cTmp)->TOT_PESO})
			
			(cTmp)->(dbSkip())
		EndDo
	EndIf
	(cTmp)->(dbCloseArea())
	
	
	nInd := 0
	dbSelectArea("GX3")
	GX3->( dbSetOrder(4) )
	If GX3->( dbSeek( xFilial("GX3") ) ) // + DtoS(dDataDe)
		While GX3->( !Eof() ) .And. xFilial("GX3") == GX3->GX3_FILIAL .And. GX3->GX3_DTCRIA >= dDataDe .And. GX3->GX3_DTCRIA <= dDataAte

			If Trim(cCodTransp) != ""

				If GX3->GX3_CDEMIT == cCodTransp

					dbSelectArea("GX8")
					GX8->( dbSetOrder(1) )
					GX8->( dbSeek(xFilial("GX8") + GX3->GX3_NRMOV ) )
					While GX8->( !Eof() ) .And. xFilial("GX8") == GX8->GX8_FILIAL .And. GX8->GX8_NRMOV == GX3->GX3_NRMOV
						If Trim(cCodMot) != ""
							If GX8->GX8_CDMTR == cCodMot

								dbSelectArea("GX4")
								GX4->( dbSetOrder(1) )
								GX4->( dbSeek(xFilial("GX4") + GX3->GX3_NRMOV ) )
								While GX4->( !Eof() ) .And. xFilial("GX4") == GX4->GX4_FILIAL .And. GX4->GX4_NRMOV == GX3->GX3_NRMOV

									dtEnt	:= GX4->GX4_DTENTR
									hrEnt	:= GX4->GX4_HRENTR
									dtSai	:= GX4->GX4_DTSAI
									hrSai	:= GX4->GX4_HRSAI

									nTmpMed := GFEC511ATM(dtEnt,dtSai,hrEnt,hrSai)

									If nTmpMed != 0
									
										nTmpMedAt += nTmpMed
	
										If nTmpMedMin == 0
											nTmpMedMin := nTmpMed
										ElseIf nTmpMed < nTmpMedMin
											nTmpMedMin := nTmpMed
										EndIf
										
										If nTmpMedMax == 0
											nTmpMedMax := nTmpMed
										ElseIf nTmpMed > nTmpMedMax
											nTmpMedMax := nTmpMed
										EndIf
										
									EndIf
										
									GX4->( dbSkip() )
								EndDo
							EndIf
						EndIf

						GX8->( dbSkip() )
					EndDo
				EndIf
				
			Else
				
				dbSelectArea("GX8")
				GX8->( dbSetOrder(1) )
				GX8->( dbSeek(xFilial("GX8") + GX3->GX3_NRMOV ) )
				While GX8->( !Eof() ) .And. xFilial("GX8") == GX8->GX8_FILIAL .And. GX8->GX8_NRMOV == GX3->GX3_NRMOV
					If Trim(cCodMot) != ""
						If GX8->GX8_CDMTR == cCodMot

							dbSelectArea("GX4")
							GX4->( dbSetOrder(1) )
							GX4->( dbSeek(xFilial("GX4") + GX3->GX3_NRMOV ) )
							While GX4->( !Eof() ) .And. xFilial("GX4") == GX4->GX4_FILIAL .And. GX4->GX4_NRMOV == GX3->GX3_NRMOV

								dtEnt	:= GX4->GX4_DTENTR
								hrEnt	:= GX4->GX4_HRENTR
								dtSai	:= GX4->GX4_DTSAI
								hrSai	:= GX4->GX4_HRSAI

								nTmpMed := GFEC511ATM(dtEnt,dtSai,hrEnt,hrSai)
								
								If nTmpMed != 0
								
									nTmpMedAt += nTmpMed
	
									If nTmpMedMin == 0
										nTmpMedMin := nTmpMed
									ElseIf nTmpMed < nTmpMedMin
										nTmpMedMin := nTmpMed
									EndIf
	
									If nTmpMedMax == 0
										nTmpMedMax := nTmpMed
									ElseIf nTmpMed > nTmpMedMax
										nTmpMedMax := nTmpMed
									EndIf
									
								EndIf
								
								GX4->( dbSkip() )
							EndDo
						EndIf
					EndIf
					
					GX8->( dbSkip() )
				EndDo
				
			EndIf
			
			GX3->( dbSkip() )
		EndDo
	EndIf
	
	aADD(aGridEst, {"Tempo médio movimentações (h)",		AllTrim(Transform(nTmpMedAt / nInd,'@E 999.99')) })
	aADD(aGridEst, {"Tempo máximo movimentações (h)",	AllTrim(Transform(nTmpMedMax,'@E 999.99')) })
	aADD(aGridEst, {"Tempo mínimo movimentações (h)",	AllTrim(Transform(nTmpMedMin,'@E 999.99')) })


	// ####### GRAFICO SIT AGENDAMENTOS #######
	cQuery := "SELECT	COUNT(CASE WHEN GWV.GWV_SIT = '1' THEN 1 END) TOT_AGAB , "
	cQuery += "		COUNT(CASE WHEN GWV.GWV_SIT = '2' THEN 1 END) TOT_AGCON , "
	cQuery += "		COUNT(CASE WHEN GWV.GWV_SIT = '3' THEN 1 END) TOT_AGCAN "
	cQuery += "  FROM " + RetSQLName("GWV") + " GWV "
	cQuery += "  LEFT JOIN " + RetSQLName("GX3") + " GX3	 ON GWV.GWV_FILIAL = GX3.GX3_FILIAL "
	cQuery += "  					  							AND GWV.GWV_NRMOV = GX3.GX3_NRMOV "
	cQuery += "  	 			  	  							AND GWV.D_E_L_E_T_ = '' "
	cQuery += "  LEFT JOIN " + RetSQLName("GX8") + " GX8	 ON GX8.GX8_FILIAL = GX3.GX3_FILIAL "
	cQuery += "  	 			  	  							AND GX8.GX8_NRMOV  = GX3.GX3_NRMOV "
	cQuery += "  	 			  	  							AND GX8.D_E_L_E_T_ = '' "
	cQuery += cFiltro

	cTmp 	:= GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	If (cTmp)->(RecNo()) > 0
		While (cTmp)->(!Eof())

			// GWV_SIT ==== 1=Aberto 2=Concluido 3=Cancelado 
			aADD(aGrfSitAg, {"Abertos",		(cTmp)->TOT_AGAB})
			aADD(aGrfSitAg, {"Concluídos",	(cTmp)->TOT_AGCON})
			aADD(aGrfSitAg, {"Cancelados",	(cTmp)->TOT_AGCAN})

			(cTmp)->(dbSkip())
		EndDo
	EndIf
	(cTmp)->(dbCloseArea())


	// ####### GRAFICO SIT MOVIMENTACOES #######
	cQuery := "SELECT	COUNT(DISTINCT GX3.GX3_NRMOV) MOV_ANDA, "
	cQuery += " 		COUNT(CASE WHEN GX3.GX3_SIT = '5' THEN 1 END) MOV_CANC, "
	cQuery += " 		COUNT(CASE WHEN GX3.GX3_SIT = '6' THEN 1 END) MOV_CONC "
	cQuery += "   FROM " + RetSQLName("GX3") + " GX3"
	cQuery += " INNER JOIN " + RetSQLName("GX8") + " GX8	 ON GX8.GX8_FILIAL = GX3.GX3_FILIAL "
	cQuery += "  	 			  	  							AND GX8.GX8_NRMOV  = GX3.GX3_NRMOV "
	cQuery += "  	 			  	  							AND GX8.D_E_L_E_T_ = '' "
	cQuery += cFiltro

	cTmp 	:= GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	If (cTmp)->(RecNo()) > 0
		While (cTmp)->(!Eof())

			// GX3_SIT ==== 1=Aberto 2=Movimentado 3=Em Fila 4=Endereçado 5=Cancelado 6=Concluido 
			aADD(aGrfSitMov,{"Em andamento",	(cTmp)->MOV_ANDA - (cTmp)->MOV_CANC - (cTmp)->MOV_CONC})
			aADD(aGrfSitMov,{"Canceladas",		(cTmp)->MOV_CANC})
			aADD(aGrfSitMov,{"Concluídas",		(cTmp)->MOV_CONC})

			(cTmp)->(dbSkip())
		EndDo
	EndIf
	(cTmp)->(dbCloseArea())


	// ####### GRAFICO MOV por OPERACOES #######
	cQuery := "SELECT	GX3.GX3_CDOPER, "
	cQuery += "		COUNT(GX3.GX3_CDOPER) TOT_OPER "
	cQuery += "  FROM " + RetSQLName("GX3") + " GX3 "
	cQuery += "  LEFT JOIN " + RetSQLName("GX8") + " GX8	 ON GX8.GX8_FILIAL = GX3.GX3_FILIAL "
	cQuery += "			  	  	  							AND GX8.GX8_NRMOV  = GX3.GX3_NRMOV "
	cQuery += "  	 			  	  							AND GX8.D_E_L_E_T_ = '' "
	cQuery += cFiltro
	cQuery += " GROUP BY GX3.GX3_CDOPER "
	cQuery += " ORDER BY GX3.GX3_CDOPER "

	cTmp 	:= GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	If (cTmp)->(RecNo()) > 0
		While (cTmp)->(!Eof())

			aADD(aGrfMovOp, {(cTmp)->GX3_CDOPER, (cTmp)->TOT_OPER})

			(cTmp)->(dbSkip())
		EndDo
	EndIf
	(cTmp)->(dbCloseArea())

Return Nil		   

Static Function Load2()
	Local cQuery	:= ''
	Local cPont	:= ''
	Local cAlias
	Local aFields, aIndices
	Local nCont
	Local cTmp
	Local nMin 	:= 0
	Local nMinNeg := 0
	Local nMinPos := 0
	Local nMinDif	:= 0
	Local aStruct := {}
		
	aFields := {;
				{"Filial"	     	,"GWV_FILIAL"	,"C",TamSX3("GWV_FILIAL")[1],0},;
				{"Nr agendamento"	,"GWV_NRAGEN"	,"C",TamSX3("GWV_NRAGEN")[1],0},;
				{"Situação"      	,"SIT"			,"C",20,0,"",1,10},;
				{"Data Agend"		,"GWV_DTAGEN" ,"D",TamSX3("GWV_DTAGEN")[1],0},;
				{"Pontualidade"	,"PONT"  		,"C",30  ,0}}
	
	aIndices := {"GWV_FILIAL+GWV_NRAGEN"}

	For nCont := 1 To Len(aFields)
		aADD(aStruct,{aFields[nCont][2],;  // Nome do campo
						aFields[nCont][3],;  // Tipo
						aFields[nCont][4],;  // Tamanho
						aFields[nCont][5]})	// Decimal
	Next nCont

	cAlias := GFECriaTab({aStruct,aIndices})

	// ####### GRAFICO AGENDAMENTOS #######
	cQuery := "SELECT	GWV.GWV_FILIAL, GWV.GWV_NRAGEN, GX3.GX3_CDOPER, GX3.GX3_SEQ," 
	cQuery += "		CASE  "
	cQuery += "			WHEN GWV.GWV_SIT = '1' THEN 'Aberto' "
	cQuery += "			WHEN GWV.GWV_SIT = '2' THEN 'Concluído' "
	cQuery += "			WHEN GWV.GWV_SIT = '3' THEN 'Cancelado' "
	cQuery += "		END SIT, "
	cQuery += "		GWV.GWV_DTAGEN, "
	cQuery += "		GWV.GWV_HRAGEN, "
	cQuery += "		GX4.GX4_DTENTR, "
	cQuery += "		GX4.GX4_HRENTR, "
	cQuery += "      '' PONT"
	cQuery += "  FROM " + RetSQLName("GWV") + " GWV "
	cQuery += " INNER JOIN " + RetSQLName("GX3") + " GX3	 ON GWV.GWV_FILIAL = GX3.GX3_FILIAL"
	cQuery += "												AND GWV.GWV_NRMOV  = GX3.GX3_NRMOV "
	cQuery += "												AND GWV.D_E_L_E_T_ = '' "
	cQuery += "  LEFT JOIN " + RetSQLName("GX4") + " GX4	 ON GX4.GX4_FILIAL = GX3.GX3_FILIAL"
	cQuery += "												AND GX4.GX4_NRMOV  = GX3.GX3_NRMOV"
	cQuery += "												AND GX4.GX4_SEQ    = '001'"
	cQuery += "												AND GX4.D_E_L_E_T_ = ''"
	cQuery += "  LEFT JOIN " + RetSQLName("GX8") + " GX8	 ON GX8.GX8_FILIAL = GX3.GX3_FILIAL "
	cQuery += "			  	  	  							AND GX8.GX8_NRMOV  = GX3.GX3_NRMOV "
	cQuery += "  	 			  	  							AND GX8.D_E_L_E_T_ = '' "
	cQuery += cFiltro
	cQuery += " GROUP BY GWV.GWV_FILIAL, GWV.GWV_NRAGEN, GX3.GX3_CDOPER, GX3.GX3_SEQ, "
	cQuery += "          GWV.GWV_SIT, GWV.GWV_DTAGEN, GWV.GWV_HRAGEN, GX4.GX4_DTENTR, GX4.GX4_HRENTR"

	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	
	While (cTmp)->(!Eof())

		dtEnt := StoD((cTmp)->GX4_DTENTR)
		hrEnt := (cTmp)->GX4_HRENTR
		dtAge := StoD((cTmp)->GWV_DTAGEN)
		hrAge := (cTmp)->GWV_HRAGEN
		cPont := ""
		
		If !Empty(dtEnt) .And. !Empty(hrEnt) .And. !Empty(dtAge) .And. !Empty(hrAge) 
		
			// Limites de atraso e adiantamento
			nMinNeg := Posicione("GVI",1,xFilial("GVI") + (cTmp)->GX3_CDOPER + (cTmp)->GX3_SEQ,"GVI_QTHRNE")
			nMinPos := Posicione("GVI",1,xFilial("GVI") + (cTmp)->GX3_CDOPER + (cTmp)->GX3_SEQ,"GVI_QTHRPO")		

			If Val(hrAge) < Val(hrEnt)
				// Converte as horas em minutos
				nMin := Val(SubStr(ElapTime(AllTrim(Stuff(hrAge,3,0,":"))+":00",AllTrim(Stuff(hrEnt,3,0,":"))+":00"),1,2))
				nMin := nMin * 60
				// Converte as horas em minutos
				
				// Soma os minutos restantes				
				nMin += Val(SubStr(ElapTime(AllTrim(Stuff(hrAge,3,0,":"))+":00",AllTrim(Stuff(hrEnt,3,0,":"))+":00"),4,2))
			Else
				// Converte as horas em minutos
				nMin := Val(SubStr(ElapTime(AllTrim(Stuff(hrEnt,3,0,":"))+":00",AllTrim(Stuff(hrAge,3,0,":"))+":00"),1,2))
				nMin := nMin * 60
				// Converte as horas em minutos
				
				// Soma os minutos restantes
				nMin += Val(SubStr(ElapTime(AllTrim(Stuff(hrEnt,3,0,":"))+":00",AllTrim(Stuff(hrAge,3,0,":"))+":00"),4,2))
			EndIf
	
	 		If		( dtAge == dtEnt .And. Val(hrAge) < Val(hrEnt) ) .Or. ;
	                dtAge < dtEnt
	
				nMinDif := ( ( (dtEnt - dtAge) * 24 ) * 60 ) + nMin
	
				If nMinDif <= nMinNeg
					cPont := "No horário"
				Else
					cPont := "Atrasado"
				EndIf
	
			ElseIf	( dtAge == dtEnt .And. Val(hrAge) > Val(hrEnt) ) .Or. ;
	            	  dtAge > dtEnt
	
				nMinDif := ( ( (dtAge - dtEnt) * 24 ) * 60 ) + nMin
	                            
				If nMinDif <= nMinPos
					cPont := "No horário"
				Else
					cPont := "Adiantado"
				EndIf
				
	       EndIf

		EndIf
		
		RecLock(cAlias,.T.)
		(cAlias)->GWV_FILIAL := (cTmp)->GWV_FILIAL
		(cAlias)->GWV_NRAGEN := (cTmp)->GWV_NRAGEN
		(cAlias)->SIT  		:= (cTmp)->SIT
		(cAlias)->GWV_DTAGEN := StoD((cTmp)->GWV_DTAGEN)
		(cAlias)->PONT 		:= cPont
		MsUnlock(cAlias)
		(cTmp)->(dbSkip())
	EndDo
	
	(cTmp)->(dbCloseArea())

Return cAlias

Static Function Load31()
	Local cQuery	:= ''
	Local cSit		:= ''
	Local cAlias
	Local aFields, aIndices
	Local nCont
	Local cTmp
	Local aStruct := {}
	
    aFields := {;
				{"Filial"	     		,"GX3_FILIAL"	,"C",TamSX3("GX4_FILIAL")[1],0},;
				{"Nr Movimentação"	,"GX3_NRMOV"	,"C",TamSX3("GX4_NRMOV")[1],0},;
				{"Data Criação"		,"GX3_DTCRIA"	,"D",TamSX3("GX3_DTCRIA")[1],0},;
				{"Situação"			,"GX3_SIT"		,"C",15,0},;
				{"Operação"			,"GX3_CDOPER"	,"C",TamSX3("GX3_CDOPER")[1],0},;
				{"Seq"					,"GX3_SEQ"		,"C",TamSX3("GX3_SEQ")[1],0},;
				{"Desc Config"		,"GVI_DSCONF"	,"C",TamSX3("GVI_DSCONF")[1],0},;
				{"Dt Início"			,"GX4_DTENTR"	,"D",TamSX3("GX4_DTENTR")[1],0},;
				{"Dt Fim"				,"GX4_DTSAI"	,"D",TamSX3("GX4_DTSAI")[1],0}}	
	
	aIndices := {"GX3_FILIAL+GX3_NRMOV"}

	For nCont := 1 To Len(aFields)
		aADD(aStruct,{aFields[nCont][2],;  // Nome do campo
						aFields[nCont][3],;  // Tipo
						aFields[nCont][4],;  // Tamanho
						aFields[nCont][5]})	// Decimal
	Next nCont

	cAlias := GFECriaTab({aStruct,aIndices})

	cQuery := "SELECT	"  
	cQuery += "		GX3.GX3_FILIAL,	"
	cQuery += "		GX3.GX3_NRMOV,	"
	cQuery += "		GX3.GX3_DTCRIA,	"
	cQuery += "		GX3.GX3_SIT,	"
	cQuery += "		GX3.GX3_CDOPER,	"
	cQuery += "		GX3.GX3_SEQ,	"
	cQuery += "		'' GVI_DSCONF,	"
	cQuery += "		MAX(GX4.GX4_DTENTR) 	GX4_DTENTR,	"
	cQuery += "		MIN(GX4.GX4_DTSAI)	GX4_DTSAI "
	cQuery += "  FROM " + RetSQLName("GX3") + " GX3	"
	cQuery += "  LEFT JOIN " + RetSQLName("GX4") + " GX4	 ON GX4.GX4_FILIAL = GX3.GX3_FILIAL	"
	cQuery += "	  											AND GX4.GX4_NRMOV  = GX3.GX3_NRMOV	"
	cQuery += "												AND GX4.D_E_L_E_T_ = '' "
	cQuery += "  LEFT JOIN " + RetSQLName("GX8") + " GX8	 ON GX8.GX8_FILIAL = GX3.GX3_FILIAL "
	cQuery += "			  	  	  							AND GX8.GX8_NRMOV  = GX3.GX3_NRMOV "
	cQuery += "  	 			  	  							AND GX8.D_E_L_E_T_ = '' "
	cQuery += cFiltro
	cQuery += "	GROUP BY GX3.GX3_FILIAL, GX3.GX3_NRMOV, GX3.GX3_DTCRIA, GX3.GX3_SIT, GX3.GX3_CDOPER, GX3.GX3_SEQ	"

	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	
	While (cTmp)->(!Eof())
	
		DO CASE
			CASE (cTmp)->GX3_SIT = '1'
				cSit := "Aberto"
			CASE (cTmp)->GX3_SIT = '2'
				cSit := "Movimentado"
			CASE (cTmp)->GX3_SIT = '3'
				cSit := "Em Fila"
			CASE (cTmp)->GX3_SIT = '4'
				cSit := "Endereçado"
			CASE (cTmp)->GX3_SIT = '5'
				cSit := "Cancelado"
			CASE (cTmp)->GX3_SIT = '6'
				cSit := "Concluído"
		ENDCASE
	
		RecLock(cAlias,.T.)
			(cAlias)->GX3_FILIAL	:= (cTmp)->GX3_FILIAL
			(cAlias)->GX3_NRMOV	:= (cTmp)->GX3_NRMOV
			(cAlias)->GX3_DTCRIA := StoD((cTmp)->GX3_DTCRIA)
			(cAlias)->GX3_SIT  	:=	cSit
			(cAlias)->GX3_CDOPER := (cTmp)->GX3_CDOPER
			(cAlias)->GX3_SEQ 	:= (cTmp)->GX3_SEQ
			(cAlias)->GVI_DSCONF := Posicione("GVI",1,xFilial("GVI") + (cTmp)->GX3_CDOPER + (cTmp)->GX3_SEQ,"GVI_DSCONF")
			(cAlias)->GX4_DTENTR := StoD((cTmp)->GX4_DTENTR)
			(cAlias)->GX4_DTSAI 	:= StoD((cTmp)->GX4_DTSAI)
		MsUnlock(cAlias)
		(cTmp)->(dbSkip())
	EndDo
	
	(cTmp)->(dbCloseArea())

Return cAlias


Static Function Load32()
	Local cQuery	:= ''
	Local cSit		:= ''
	Local cAlias
	Local aFields, aIndices
	Local nCont
	Local cTmp
	Local aStruct := {}

	aFields := {;
				{"Filial"				,"GX4_FILIAL"	,"C",TamSX3("GX4_FILIAL")[1],0},;
				{"Nr Movimentação"	,"GX4_NRMOV"	,"C",TamSX3("GX4_NRMOV")[1],0},;
				{"Seq"					,"GX4_SEQ"		,"C",TamSX3("GX4_SEQ")[1],0},;
				{"Ponto de Controle"	,"GX4_CDPTCT"	,"C",TamSX3("GX4_CDPTCT")[1],0},;
				{"Situação"			,"GX4_SIT"		,"C",15,0},;
				{"Dt Início"			,"GX4_DTENTR"	,"D",TamSX3("GX4_DTENTR")[1],0},;
				{"Hr Início"			,"GX4_HRENTR"	,"C",TamSX3("GX4_HRENTR")[1],0},;
				{"Dt Fim"				,"GX4_DTSAI"	,"D",TamSX3("GX4_DTSAI")[1],0},;
				{"Hr Fim"				,"GX4_HRSAI"	,"C",TamSX3("GX4_HRSAI")[1],0}}
 
	aIndices := {"GX4_FILIAL+GX4_NRMOV+GX4_SEQ+GX4_CDPTCT"}

	For nCont := 1 To Len(aFields)
		aADD(aStruct,{aFields[nCont][2],;  // Nome do campo
						aFields[nCont][3],;  // Tipo
						aFields[nCont][4],;  // Tamanho
						aFields[nCont][5]})	// Decimal
	Next nCont

	cAlias := GFECriaTab({aStruct,aIndices})

	// ####### PONTOS DE CONTROLE #######
	cQuery := "SELECT	GX4.GX4_FILIAL, GX4.GX4_NRMOV, GX4.GX4_SEQ, GX4.GX4_CDPTCT, GX4_SIT, GX4_DTENTR, GX4_HRENTR, GX4_DTSAI, GX4_HRSAI " 
	cQuery += "  FROM " + RetSQLName("GX4") + " GX4 "
	cQuery += "  LEFT JOIN " + RetSQLName("GX3") + " GX3	 ON GX3.GX3_FILIAL = GX4.GX4_FILIAL "
	cQuery += "	  											AND GX3.GX3_NRMOV  = GX4.GX4_NRMOV	"
	cQuery += "												AND GX3.D_E_L_E_T_ = '' "
	cQuery += "  LEFT JOIN " + RetSQLName("GX8") + " GX8	 ON GX8.GX8_FILIAL = GX3.GX3_FILIAL "
	cQuery += "			  	  	  							AND GX8.GX8_NRMOV  = GX3.GX3_NRMOV "
	cQuery += "  	 			  	  							AND GX8.D_E_L_E_T_ = '' "
	cQuery += cFiltro

	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	
	While (cTmp)->(!Eof())
		RecLock(cAlias,.T.)

			// GX4_SIT ==== 1=Nao Avaliado | 2=Aprovado | 3=Reprovado		
			DO CASE
				CASE (cTmp)->GX4_SIT = '1'
					cSit := "Não Avaliado"
				CASE (cTmp)->GX4_SIT = '2'
					cSit := "Aprovado"
				CASE (cTmp)->GX4_SIT = '3'
					cSit := "Reprovado"
			ENDCASE

			(cAlias)->GX4_FILIAL	:= (cTmp)->GX4_FILIAL
			(cAlias)->GX4_NRMOV	:= (cTmp)->GX4_NRMOV
			(cAlias)->GX4_SEQ		:= (cTmp)->GX4_SEQ
			(cAlias)->GX4_CDPTCT	:= (cTmp)->GX4_CDPTCT
			(cAlias)->GX4_SIT		:= cSit
			(cAlias)->GX4_DTENTR	:= StoD((cTmp)->GX4_DTENTR)
			(cAlias)->GX4_HRENTR	:= SubStr((cTmp)->GX4_HRENTR,0,2) +":"+ SubStr((cTmp)->GX4_HRENTR,3,2)
			(cAlias)->GX4_DTSAI	:= StoD((cTmp)->GX4_DTSAI)
			(cAlias)->GX4_HRSAI	:= SubStr((cTmp)->GX4_HRSAI,0,2) +":"+ SubStr((cTmp)->GX4_HRSAI,3,2)
			
		MsUnlock(cAlias)
		(cTmp)->(dbSkip())
	EndDo

	(cTmp)->(dbCloseArea())

Return cAlias


Static Function Load4()
	Local cQuery	:= ''
	Local cTipo	:= ''
	Local cMotivo	:= ''
	Local cNmTrans:= ''
	Local cAlias
	Local aFields, aIndices
	Local nCont
	Local cTmp
	Local aStruct := {}

	aFields := {;
				{"Filial"	     	,"GWD_FILIAL"	,"C",TamSX3("GWD_FILIAL")[1],0},;
				{"Nr Ocorrência"	,"GWD_NROCO"	,"C",TamSX3("GWD_NROCO")[1],0},;
				{"Dt Ocorrência"	,"GWD_DTOCOR"	,"D",TamSX3("GWD_DTOCOR")[1],0},;
				{"Tipo"	     	,"GWD_CDTIPO"	,"C",TamSX3("GU5_DESC")[1],0},;
				{"Motivo"	     	,"GWD_CDMOT"	,"C",TamSX3("GU6_DESC")[1],0},;
				{"Transp"	     	,"GWD_CDTRP"	,"C",TamSX3("GWD_CDTRP")[1],0},;
				{"Nome Transp"	,"GU3_NMEMIT"	,"C",TamSX3("GU3_NMEMIT")[1],0}}

	aIndices := {"GWD_FILIAL+GWD_NROCO"}

	For nCont := 1 To Len(aFields)
		aADD(aStruct,{aFields[nCont][2],;  // Nome do campo
						aFields[nCont][3],;  // Tipo
						aFields[nCont][4],;  // Tamanho
						aFields[nCont][5]})	// Decimal
	Next nCont

	cAlias := GFECriaTab({aStruct,aIndices})

	// ####### OCORRENCIAS #######
	cQuery := "SELECT GWD.GWD_FILIAL, GWD.GWD_NROCO, GWD.GWD_DTOCOR, GWD.GWD_CDTIPO, GWD.GWD_CDMOT, GWD.GWD_CDTRP, '' GU3_NMEMIT " 
	cQuery += "  FROM " + RetSQLName("GWD") + " GWD " 
	cQuery += "  LEFT JOIN " + RetSQLName("GX3") + " GX3	 ON GX3.GX3_FILIAL = GWD.GWD_FILIAL "
	cQuery += "	  											AND GX3.GX3_NRMOV  = GWD.GWD_NRMOV	"
	cQuery += "												AND GX3.D_E_L_E_T_ = '' "
	cQuery += "  LEFT JOIN " + RetSQLName("GX8") + " GX8	 ON GX8.GX8_FILIAL = GWD.GWD_FILIAL "
	cQuery += "			  	  	  							AND GX8.GX8_NRMOV  = GWD.GWD_NRMOV "
	cQuery += "  	 			  	  							AND GX8.D_E_L_E_T_ = '' "
	cQuery += cFiltro
	cQuery += "   AND GWD.D_E_L_E_T_ = '' "

	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	
	While (cTmp)->(!Eof())
		RecLock(cAlias,.T.)
		
			cNmTrans:= Posicione("GU3",1,xFilial("GU3")+(cTmp)->GWD_CDTRP,"GU3_NMEMIT")
			cTipo 	:= Posicione("GU5",1,xFilial("GU5")+(cTmp)->GWD_CDTIPO,"GU5_DESC")
			cMotivo	:= Posicione("GU6",1,xFilial("GU6")+(cTmp)->GWD_CDMOT,"GU6_DESC")

			(cAlias)->GWD_FILIAL	:= (cTmp)->GWD_FILIAL
			(cAlias)->GWD_NROCO	:= (cTmp)->GWD_NROCO
			(cAlias)->GWD_DTOCOR	:= StoD((cTmp)->GWD_DTOCOR)
			(cAlias)->GWD_CDTIPO	:= cTipo 
			(cAlias)->GWD_CDMOT	:= cMotivo
			(cAlias)->GWD_CDTRP	:= (cTmp)->GWD_CDTRP
			(cAlias)->GU3_NMEMIT	:= cNmTrans
			
		MsUnlock(cAlias)
		(cTmp)->(dbSkip())
	EndDo

	(cTmp)->(dbCloseArea())

Return cAlias


Static Function Load5()
	Local cQuery	:= ''
	Local cTmp   	:= ''
	Local cSit		:= ''
	Local cNmTrans:= ''
	Local cAlias
	Local aFields, aIndices
	Local nCont
	Local aStruct := {}

	aFields := {;
				{"Filial"	     		,"GWN_FILIAL"	,"C",TamSX3("GWN_FILIAL")[1],0},;
				{"Nr Romaneio"		,"GWN_NRROM"	,"C",TamSX3("GWN_NRROM")[1],0},;
				{"Situação"      		,"GWN_SIT"		,"C",15,0,"",1,10},;
				{"Data Criação"		,"GWN_DTIMPL"	,"D",TamSX3("GWN_DTIMPL")[1],0},;
				{"Tipo Oper"			,"GWN_CDTPOP"	,"C",TamSX3("GWN_CDTPOP")[1],0},;
				{"Clas Frete"			,"GWN_CDCLFR"	,"C",TamSX3("GWN_CDCLFR")[1],0},;
				{"Transp"				,"GWN_CDTRP" 	,"C",TamSX3("GWN_CDTRP")[1],0},;
				{"Nome Transportadora","GU3_NMEMIT","C",TamSX3("GU3_NMEMIT")[1],0} }

	aIndices := {"GWN_FILIAL+GWN_NRROM"}

	For nCont := 1 To Len(aFields)
		aADD(aStruct,{aFields[nCont][2],;  // Nome do campo
						aFields[nCont][3],;  // Tipo
						aFields[nCont][4],;  // Tamanho
						aFields[nCont][5]})	// Decimal
	Next nCont

	cAlias := GFECriaTab({aStruct,aIndices})

	// ####### ROMANEIOS #######
	cQuery := "SELECT GWN.GWN_FILIAL, GWN.GWN_NRROM, GWN.GWN_SIT, GWN.GWN_DTIMPL, GWN.GWN_CDTPOP, GWN.GWN_CDCLFR, GWN.GWN_CDTRP, '' GU3_NMEMIT " 
	cQuery += "  FROM " + RetSQLName("GWN") + " GWN " 
	cQuery += "  LEFT JOIN " + RetSQLName("GX3") + " GX3	 ON GX3.GX3_FILIAL = GWN.GWN_FILIAL "
	cQuery += "	  											AND GX3.GX3_NRMOV  = GWN.GWN_NRMOV	"
	cQuery += "												AND GX3.D_E_L_E_T_ = '' "
	cQuery += "  LEFT JOIN " + RetSQLName("GX8") + " GX8	 ON GX8.GX8_FILIAL = GWN.GWN_FILIAL "
	cQuery += "			  	  	  							AND GX8.GX8_NRMOV  = GWN.GWN_NRMOV "
	cQuery += "  	 			  	  							AND GX8.D_E_L_E_T_ = '' "
	cQuery += cFiltro
	cQuery += "   AND GWN.D_E_L_E_T_ = '' "

	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	
	While (cTmp)->(!Eof())
		RecLock(cAlias,.T.)
			// GWN_SIT 1=Digitado | 2=Impresso | 3=Liberado | 4=Encerrado
			DO CASE
				CASE (cTmp)->GWN_SIT = '1'
					cSit := "Digitado"
				CASE (cTmp)->GWN_SIT = '2'
					cSit := "Impresso"
				CASE (cTmp)->GWN_SIT = '3'
					cSit := "Liberado"
				CASE (cTmp)->GWN_SIT = '4'
					cSit := "Encerrado"
			ENDCASE

			cNmTrans := Posicione("GU3",1,xFilial("GU3")+(cTmp)->GWN_CDTRP,"GU3_NMEMIT") 

			(cAlias)->GWN_FILIAL	:= (cTmp)->GWN_FILIAL
			(cAlias)->GWN_NRROM	:= (cTmp)->GWN_NRROM
			(cAlias)->GWN_SIT		:= cSit
			(cAlias)->GWN_DTIMPL	:= StoD((cTmp)->GWN_DTIMPL) 
			(cAlias)->GWN_CDTPOP	:= (cTmp)->GWN_CDTPOP
			(cAlias)->GWN_CDCLFR	:= (cTmp)->GWN_CDCLFR
			(cAlias)->GWN_CDTRP	:= (cTmp)->GWN_CDTRP
			(cAlias)->GU3_NMEMIT := cNmTrans
			
		MsUnlock(cAlias)
		(cTmp)->(dbSkip())
	EndDo

	(cTmp)->(dbCloseArea())

Return cAlias


Static Function Load6()
	Local cQuery	:= ''
	Local cTmp   	:= ''
	Local cSit, cAut, cTransp := '' 
	Local cAlias
	Local aFields, aIndices
	Local nCont
	Local aStruct := {}

	aFields := {;
				{"Cód Emitente"	,"GU3_CDEMIT"	,"C",TamSX3("GU3_CDEMIT")[1],0},;
				{"Nome"			,"GU3_NMEMIT"	,"C",TamSX3("GU3_NMEMIT")[1],0},;
				{"Nome Abrev"		,"GU3_NMABRV"	,"C",TamSX3("GU3_NMABRV")[1],0},;
				{"Natureza"		,"GU3_NATUR"	,"C",TamSX3("GU3_NATUR")[1],0},;
				{"Situação"		,"GU3_SIT"		,"C",15,0},;
				{"Autonomo?"		,"GU3_AUTON"	,"C",10,0},;
				{"Transportador?"	,"GU3_TRANSP"	,"C",10,0},;
				{"Nome Cidade"	,"GU7_NMCID"	,"C",TamSX3("GU7_NMCID")[1],0},;
				{"Estado"			,"GU7_CDUF"	,"C",TamSX3("GU7_CDUF")[1],0} }

	aIndices := {"GU3_CDEMIT"}

	For nCont := 1 To Len(aFields)
		aADD(aStruct,{aFields[nCont][2],;  // Nome do campo
						aFields[nCont][3],;  // Tipo
						aFields[nCont][4],;  // Tamanho
						aFields[nCont][5]})	// Decimal
	Next nCont

	cAlias := GFECriaTab({aStruct,aIndices})

	// ####### TRANSPORTADORES #######
	cQuery := "SELECT GU3.GU3_CDEMIT, GU3.GU3_NMEMIT, GU3.GU3_NMABRV, GU3.GU3_NATUR, GU3.GU3_SIT, GU3.GU3_AUTON, GU3.GU3_TRANSP, GU3.GU3_NRCID, '' ESTADO " 
	cQuery += "  FROM " + RetSQLName("GU3") + " GU3 " 
	cQuery += "  LEFT JOIN " + RetSQLName("GX3") + " GX3	 ON GX3.GX3_CDEMIT = GU3.GU3_CDEMIT "
	cQuery += "												AND GX3.D_E_L_E_T_ = '' "
	cQuery += "  LEFT JOIN " + RetSQLName("GX8") + " GX8	 ON GX8.GX8_FILIAL = GX3.GX3_FILIAL "
	cQuery += "												AND GX8.GX8_NRMOV  = GX3.GX3_NRMOV "
	cQuery += "												AND GX8.D_E_L_E_T_ = ' ' "
	cQuery += cFiltro
	cQuery += "   AND GU3.D_E_L_E_T_ = '' "
	cQuery += " GROUP BY GU3.GU3_CDEMIT, GU3.GU3_NMEMIT, GU3.GU3_NMABRV, GU3.GU3_NATUR, GU3.GU3_SIT, GU3.GU3_AUTON, GU3.GU3_TRANSP, GU3.GU3_NRCID "

	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	
	While (cTmp)->(!Eof())
		RecLock(cAlias,.T.)

			// GU3_SIT 1=Ativo | 2=Inativo
			DO CASE
				CASE (cTmp)->GU3_SIT = '1'
					cSit := "Ativo"
				CASE (cTmp)->GU3_SIT = '2'
					cSit := "Inativo"
			ENDCASE

			If (cTmp)->GU3_AUTON = '1'
				cAut := 'Sim'
			Else
				cAut := 'Não'
			EndIf
			
			If (cTmp)->GU3_TRANSP = '1'
				cTransp := 'Sim'
			Else
				cTransp := 'Não'
			EndIf

			(cAlias)->GU3_CDEMIT	:= (cTmp)->GU3_CDEMIT
			(cAlias)->GU3_NMEMIT	:= (cTmp)->GU3_NMEMIT
			(cAlias)->GU3_NMABRV	:= (cTmp)->GU3_NMABRV
			(cAlias)->GU3_NATUR	:= (cTmp)->GU3_NATUR
			(cAlias)->GU3_SIT		:= cSit
			(cAlias)->GU3_AUTON	:= cAut
			(cAlias)->GU3_TRANSP	:= cTransp
			(cAlias)->GU7_NMCID	:= Posicione("GU7",1,xFilial("GU7")+(cTmp)->GU3_NRCID,"GU7_NMCID")
			(cAlias)->GU7_CDUF	:= Posicione("GU7",1,xFilial("GU7")+(cTmp)->GU3_NRCID,"GU7_CDUF")

		MsUnlock(cAlias)
		(cTmp)->(dbSkip())
	EndDo

	(cTmp)->(dbCloseArea())

Return cAlias


Static Function Load7()
	Local cQuery	:= ''
	Local cTmp   	:= ''
	Local cSit, cDesTpP, cDesTpA
	Local cAlias
	Local aFields, aIndices
	Local nCont
	Local aStruct := {}

	aFields := {;
				{"Cod"				,"GU8_CDVEIC"	,"C",TamSX3("GU8_CDVEIC")[1],0},;
				{"Tipo"			,"GU8_CDTPVC"	,"C",25,0},;
				{"Placa"			,"GU8_PLACA"	,"C",TamSX3("GU8_PLACA")[1],0},;
				{"Proprietário"	,"GU8_CDPROP"	,"C",TamSX3("GU8_CDPROP")[1],0},;
				{"Nome Prop"		,"GU3_NMEMIT"	,"C",TamSX3("GU3_NMEMIT")[1],0},;
				{"Tipo"			,"GU8_TPPROP"	,"C",15,0},;
				{"Tipo Acesso"	,"GU8_TPACES"	,"C",15,0},;
				{"Situação"		,"GU8_SIT"		,"C",15,0},;
				{"Volume"			,"GU8_VOLUT"	,"N",TamSX3("GU8_VOLUT")[1],TamSX3("GU8_VOLUT")[2]},;
				{"Carga"			,"GU8_CARGUT"	,"N",TamSX3("GU8_CARGUT")[1],TamSX3("GU8_CARGUT")[2]} }

	aIndices := {"GU8_CDVEIC"}

	For nCont := 1 To Len(aFields)
		aADD(aStruct,{aFields[nCont][2],;  // Nome do campo
						aFields[nCont][3],;  // Tipo
						aFields[nCont][4],;  // Tamanho
						aFields[nCont][5]})	// Decimal
	Next nCont

	cAlias := GFECriaTab({aStruct,aIndices})

	// ####### VEICULOS #######
	cQuery := "SELECT GU8.GU8_CDVEIC, GU8.GU8_CDTPVC, GU8.GU8_PLACA, GU8.GU8_CDPROP, '' NomeProp, GU8.GU8_TPPROP, GU8.GU8_TPACES, GU8.GU8_SIT, GU8.GU8_VOLUT, GU8.GU8_CARGUT " 
	cQuery += "  FROM " + RetSQLName("GU8") + " GU8 "
	cQuery += "  LEFT JOIN " + RetSQLName("GX6") + " GX6	 ON GX6.GX6_CDVEIC = GU8.GU8_CDVEIC "
	cQuery += "												AND GX6.D_E_L_E_T_ = '' "
	cQuery += "  LEFT JOIN " + RetSQLName("GX3") + " GX3	 ON GX3.GX3_FILIAL = GX6.GX6_FILIAL "
	cQuery += "												AND GX3.GX3_NRMOV  = GX6.GX6_NRMOV "
	cQuery += "												AND GX3.D_E_L_E_T_ = '' "
	cQuery += "  LEFT JOIN " + RetSQLName("GX8") + " GX8	 ON GX8.GX8_FILIAL = GX3.GX3_FILIAL "
	cQuery += "												AND GX8.GX8_NRMOV  = GX3.GX3_NRMOV "
	cQuery += "												AND GX8.D_E_L_E_T_ = ' ' "
	cQuery += cFiltro
	cQuery += "   AND GU8.D_E_L_E_T_ = '' "
	cQuery += " GROUP BY GU8.GU8_CDVEIC, GU8.GU8_CDTPVC, GU8.GU8_PLACA, GU8.GU8_CDPROP, GU8.GU8_TPPROP, GU8.GU8_TPACES, GU8.GU8_SIT,GU8.GU8_VOLUT, GU8.GU8_CARGUT "

	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())

	While (cTmp)->(!Eof())
		RecLock(cAlias,.T.)

			// GU8_SIT		1=Ativo | 2=Inativo
			DO CASE
				CASE (cTmp)->GU8_SIT = '1'
					cSit := "Ativo"
				CASE (cTmp)->GU8_SIT = '2'
					cSit := "Inativo"
			ENDCASE

			DO CASE
				CASE (cTmp)->GU8_TPPROP == '1'
					cDesTpP := "Terceiro" 
				CASE (cTmp)->GU8_TPPROP == '2'
					cDesTpP := "Próprio"
				CASE (cTmp)->GU8_TPPROP == '3'
					cDesTpP := "Alugado"
				CASE (cTmp)->GU8_TPPROP == '4'
					cDesTpP := "Outros"
			ENDCASE

			DO CASE
				CASE (cTmp)->GU8_TPACES == '1'
					cDesTpA := "Sem restrições"
				CASE (cTmp)->GU8_TPACES == '2'
					cDesTpA := "Sob permissão"
				CASE (cTmp)->GU8_TPACES == '3'
					cDesTpA := "Suspenso"
				CASE (cTmp)->GU8_TPACES == '4'
					cDesTpA := "Não permitido"
			ENDCASE

			(cAlias)->GU8_CDVEIC := (cTmp)->GU8_CDVEIC
			(cAlias)->GU8_CDTPVC := 	Posicione("GV3", 1, xFilial("GV3") + (cTmp)->GU8_CDTPVC, "GV3_DSTPVC") // Descrição Tipo de Veículo
			(cAlias)->GU8_PLACA 	:= (cTmp)->GU8_PLACA
			(cAlias)->GU8_CDPROP := (cTmp)->GU8_CDPROP
			(cAlias)->GU3_NMEMIT := Posicione("GU3",1,xFilial("GU3")+(cTmp)->GU8_CDPROP,"GU3_NMEMIT") 
			(cAlias)->GU8_TPPROP := cDesTpP	// Descrição Tipo Proprietário
			(cAlias)->GU8_TPACES := cDesTpA	// Descrição Tipo de Acesso
			(cAlias)->GU8_SIT 	:= cSit
			(cAlias)->GU8_VOLUT 	:= (cTmp)->GU8_VOLUT
			(cAlias)->GU8_CARGUT := (cTmp)->GU8_CARGUT

		MsUnlock(cAlias)
		(cTmp)->(dbSkip())
	EndDo

	(cTmp)->(dbCloseArea())

Return cAlias


Static Function Atualiza()
	//Atualiza Gráficos
	GFEC512GRA(oGrfSitAg	,.T.,aGrfSitAg)
	GFEC512GRA(oGrfSitMov,.T.,aGrfSitMov)
	GFEC512GRA(oGrfMovOp	,.T.,aGrfMovOp)
	
	//Atualiza o Grid  
//	oGridEst:SetArray(aGridEst)
//	oGridEst:UpdateBrowse()
	
Return Nil

//=========================================================================/
Function GFEC512GRA(oGrf,lAtual,aSerie,cTitulo)  
	Local nCont
	Default lAtual := .F.
	   
	If lAtual
		oGrf:Reset()
	EndIf 
	
	If cTitulo != Nil
		oGrf:SetTitle(cTitulo)
	EndIf
	If ValType(aSerie) == "A"
		For nCont := 1 To Len(aSerie)
			oGrf:AddSerie(AllTrim(aSerie[nCont][1]), aSerie[nCont][2])
		Next
		If Len(aSerie) > 0
			oGrf:Build()
		EndIf
	EndIf
Return Nil 

Function GFEC512GRC(cGrf,cTitulo,oOwner,aSerie,cPicture,bSerieAction,xTipo)
	Default xTipo := PIECHART
	
	&(cGrf) := FWChartFactory():New()
	&(cGrf) := &(cGrf):GetInstance(xTipo)
	&(cGrf):SetTitle(cTitulo,CONTROL_ALIGN_CENTER) 
	&(cGrf):Init(oOwner,.F.)
	&(cGrf):SetLegend(CONTROL_ALIGN_BOTTOM)
	
	If cPicture != Nil
		&(cGrf):SetPicture(cPicture)
	EndIf
	
	If bSerieAction != Nil
		&(cGrf):SetSerieAction(bSerieAction)
	EndIf
	
	GFEC512GRA(&(cGrf),,aSerie)
	
Return Nil

Static Function VisualAgen()

	dbSelectArea("GWV")
	GWV->(dbSetOrder(1))
	If GWV->(dbSeek((cAlias2)->( GWV_FILIAL + GWV_NRAGEN )))
		FWExecView("Visualizar", "GFEA517", 1,, {||.T.})
	EndIf
	
Return Nil


Static Function VisualMov()

	dbSelectArea("GX3")
	GX3->(dbSetOrder(1))
	If GX3->(dbSeek((cAlias31)->( GX3_FILIAL + GX3_NRMOV )))
		FWExecView("Visualizar", "GFEC510", 1,, {||.T.})
	EndIf

Return Nil

Static Function VisualOcor()

	dbSelectArea("GWD")
	GWD->(dbSetOrder(1))
	If GWD->(dbSeek((cAlias4)->( GWD_FILIAL + GWD_NROCO )))
		FWExecView("Visualizar", "GFEC032", 1,, {||.T.})
	EndIf

Return Nil

Static Function VisualRoma()

	dbSelectArea("GWN")
	GWN->(dbSetOrder(1))
	If GWN->(dbSeek((cAlias5)->( GWN_FILIAL + GWN_NRROM )))
		FWExecView("Visualizar", "GFEC050", 1,, {||.T.})
	EndIf

Return Nil

Static Function VisualTransp()

	dbSelectArea("GU3")
	GU3->(dbSetOrder(1))
	If GU3->(dbSeek((cAlias6)->( xFilial("GU3") + GU3_CDEMIT )))
		FWExecView("Visualizar", "GFEA015", 1,, {||.T.})
	EndIf

Return Nil

Static Function VisualVei()

	dbSelectArea("GU8")
	GU8->(dbSetOrder(1))
	If GU8->(dbSeek((cAlias7)->( xFilial("GU3") + GU8_CDVEIC )))
		FWExecView("Visualizar", "GFEA046", 1,, {||.T.})
	EndIf

Return Nil
