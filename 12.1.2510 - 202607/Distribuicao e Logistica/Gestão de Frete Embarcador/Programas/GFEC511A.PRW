#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
//-------------------------------------------------------------------
//Inclusão Pátios 12.1.4
/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEC511A
Painel de Veículos

Uso Restrito.

@sample
GFEC511A()

@author Helder Fuckner dos Santos 
@since 02/04/14
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFEC511A(aParam)
	Local aCoors     	 	:= FWGetDialogSize( oMainWnd )

	Private cTitulo	:= 'Painel de Veículos - Movimentação'
	Private cFiltro	:= ""

	Private cFilDe  	:= aParam[1]
	Private cFilAte 	:= aParam[2]
	Private dDataDe  	:= If(Empty(aParam[3]),DDATABASE -30 ,aParam[3])
	Private dDataAte 	:= If(Empty(aParam[4]),DDATABASE     ,aParam[4])                   
	Private cCodTrans	:= aParam[5]
	Private cCodVei	:= GU8->GU8_CDVEIC
	Private cTpVei	:= Posicione("GV3",1,xFilial("GV3")+GU8->GU8_CDTPVC,"GV3_DSTPVC")
	Private cPropr	:= GU8->GU8_CDPROP
	Private cNmPropr	:= Posicione("GU3",1,xFilial("GU3")+GU8->GU8_CDPROP,"GU3_NMEMIT")
	Private cPlaca	:= Stuff(GU8->GU8_PLACA,4,0,"-")
	Private cPlacaUF	:= GU8->GU8_UFPLAC
	
	Private nInd		:= 0
	Private nTmpMed	:= 0
	Private nTmpTot  	:= 0
	Private nTmpMax 	:= 0
	Private nTmpMin 	:= 0
	Private dtEnt
	Private hrEnt
	Private dtSai
	Private hrSai

	Private oWIN_TOP, oWIN_LEFT, oWIN_MIDDLE, oWIN_RIGHT
	Private oGrfSitAg, oGrfSitMov, oGrfMovOp, oGridEst, oGrid2, oGrid31, oGrid32, oGrid4, oGrid5, oGrid6
	Private aGrfSitAg, aGrfSitMov, aGrfMovOp, aGridEst, aGrid2, aGrid31, aGrid32, aGrid4, aGrid5, aGrid6 
	Private oPnl1Agend, oPnl1Mov, oPnl1Oper, oPnl1Brw, oPnl2Brw, oPnl3Brw1, oPnl3Brw2 
	Private cAlias2, cAlias31, cAlias32, cAlias4, cAlias5, cAlias6, cAlias7
	Private oRelacGX4

	Define MsDialog oDlg Title cTitulo From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel

	/*Criando objeto Layer*/
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDLG,.F.)
	
	oFWLayer:AddLine('LINE_TOP',28,.F.)
	oFWLayer:AddLine('LINE_MIDDLE',72,.F.)
	
	// Veiculo selecionado
	oFWLayer:AddCollumn('COL_TOP',100,.T.,'LINE_TOP')
	oFWLayer:AddWindow('COL_TOP','WIN_TOP','Veículo', 100,.F.,.F.,,'LINE_TOP',)

	oWIN_TOP	:= oFWLayer:GetWinPanel('COL_TOP','WIN_TOP', 'LINE_TOP')
	oWIN_MIDDLE	:= oFWLayer:GetLinePanel('LINE_MIDDLE')
	
	//Transportador - Cabeçalho
	@ 001, 008 SAY   oCodVei  PROMPT "Cód Veículo"	SIZE 040, 008 OF oWIN_TOP			COLORS 0, 16777215 PIXEL
	@ 001, 070 SAY   oTpVei	  PROMPT "Tipo Veículo"	SIZE 040, 008 OF oWIN_TOP			COLORS 0, 16777215 PIXEL
	@ 001, 170 SAY   oPlaca	  PROMPT "Placa"		SIZE 040, 008 OF oWIN_TOP			COLORS 0, 16777215 PIXEL
	@ 001, 220 SAY   oUFPlac  PROMPT "UF Placa"		SIZE 040, 008 OF oWIN_TOP			COLORS 0, 16777215 PIXEL
	@ 010, 008 MSGET oCodVei  VAR cCodVei 			SIZE 055, 010 OF oWIN_TOP READONLY	COLORS 0, 16777215 PIXEL
	@ 010, 070 MSGET oTpVei   VAR cTpVei  			SIZE 090, 010 OF oWIN_TOP READONLY	COLORS 0, 16777215 PIXEL
	@ 010, 170 MSGET oPlaca   VAR cPlaca  			SIZE 040, 010 OF oWIN_TOP READONLY	COLORS 0, 16777215 PIXEL
	@ 010, 220 MSGET oPlacaUF VAR cPlacaUF 			SIZE 020, 010 OF oWIN_TOP READONLY	COLORS 0, 16777215 PIXEL

	@ 026, 008 SAY oCodPro 	  PROMPT "Proprietário"	SIZE 040, 008 OF oWIN_TOP			COLORS 0, 16777215 PIXEL
	@ 026, 070 SAY oNmPro     PROMPT "Nome Proprietário"	SIZE 120, 008 OF oWIN_TOP			COLORS 0, 16777215 PIXEL
	@ 036, 008 MSGET oPropr   VAR cPropr				SIZE 055, 010 OF oWIN_TOP READONLY	COLORS 0, 16777215 PIXEL
	@ 036, 070 MSGET oNmPropr VAR cNmPropr			SIZE 200, 010 OF oWIN_TOP READONLY	COLORS 0, 16777215 PIXEL

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

	oFolder := TFolder():New(0,0,{"Gráficos","Agendamentos","Movimentações","Ocorrências","Romaneios","Motoristas"},,oWIN_MIDDLE,,,,.T.,,(oWIN_MIDDLE:nwidth/2),(oWIN_MIDDLE:nHeight/2))
	oFolder:Align := CONTROL_ALIGN_ALLCLIENT

	// ########## 1 - Graficos
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oFolder:aDialogs[1],.F.)
	
	oFWLayer:AddLine('LINE_TOP',45,.F.)
	oFWLayer:AddLine('LINE_DOWN',55,.F.)

	oFWLayer:AddCollumn('COL_LEFT',33,.T.,'LINE_TOP')
	oFWLayer:AddCollumn('COL_MIDDLE',33,.T.,'LINE_TOP')
	oFWLayer:AddCollumn('COL_RIGHT',33,.T.,'LINE_TOP')
	oFWLayer:AddCollumn('COL_BRW',100,.T.,'LINE_DOWN')
	
	oPnl1Agend	:= oFWLayer:GetColPanel('COL_LEFT','LINE_TOP')
	oPnl1Mov	:= oFWLayer:GetColPanel('COL_MIDDLE','LINE_TOP')
	oPnl1Oper 	:= oFWLayer:GetColPanel('COL_RIGHT','LINE_TOP')
	oPnl1Brw	:= oFWLayer:GetColPanel('COL_BRW', 'LINE_DOWN')

	Load1()

	GFEC511GRC("oGrfSitAg"	,"Sit Agendamentos"	,oPnl1Agend,	aGrfSitAg)
	GFEC511GRC("oGrfSitMov"	,"Sit Movimentações"	,oPnl1Mov,		aGrfSitMov)
	GFEC511GRC("oGrfMovOp"	,"Mov por Operação"	,oPnl1Oper,	aGrfMovOp)

   	oGridEst := FWBrowse():New()
	oGridEst:SetOwner(oPnl1Brw)
	oGridEst:SetDescription("Estatísticas")
	oGridEst:SetDataArray()
	oGridEst:DisableFilter()
	oGridEst:DisableConfig()
	oGridEst:SetArray(aGridEst)
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
				{"Situação"			,"GX3_SIT"		,"C",20,0,"",1,10},;
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


	// ########## 6 - Motoristas
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oFolder:aDialogs[6],.F.)

	oFWLayer:AddLine('LINEMOT',100,.F.)
	oFWLayer:AddCollumn('COL_BRWMOT',100,.T.,'LINEMOT')

	oPnl6Brw := oFWLayer:GetColPanel('COL_BRWMOT','LINEMOT')

	aGrid6 := {;
				{"Cód Motorista"	,"GUU_CDMTR"	,"C",TamSX3("GUU_CDMTR")[1],0,"",1,10},;
				{"Nome"			,"GUU_NMMTR"	,"C",TamSX3("GUU_NMMTR")[1],0,"",1,10},;
				{"Pseud/Apelid"	,"GUU_PSEUD" ,"C",TamSX3("GUU_PSEUD")[1],0,"",1,10},;
				{"CPF"				,"GUU_IDFED" ,"C",TamSX3("GUU_IDFED")[1],0,"",1,10},;
				{"Situação"		,"GUU_SIT" ,"C",20,0,"",1,10} }
  
	cAlias6 := Load6()
	
	oGrid6:= FWMBrowse():New()
	oGrid6:SetOwner(oPnl6Brw)
	oGrid6:SetDescription("Motoristas")
	oGrid6:SetAlias(cAlias6)
	oGrid6:SetLocate()
	oGrid6:DisableDetails()
	oGrid6:DisableConfig()
	oGrid6:SetAmbiente(.F.)
	oGrid6:SetWalkthru(.F.)
	oGrid6:SetProfileID("1") 
	oGrid6:SetMenuDef("")
	oGrid6:AddButton("Sair",{|| oDLG:End()},,1)
	oGrid6:AddButton("Consultar motorista",{|| VisualMoto() },,2)
	
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


Return Nil

//---------------------------------------------------------------------------------------------------
Static Function Load1()
	Local cQuery	:= ''
	Local cTmp   	:= ''
	Local cPlaca	:= ''

	aGrfSitAg	:= {}
	aGrfSitMov	:= {}
	aGrfMovOp	:= {}
	aGridEst  	:= {}

	cFiltro  = " WHERE GX3.D_E_L_E_T_ = '' "
	cFiltro += " 	 AND GX3.GX3_FILIAL >= '" + cFilDe + "' AND GX3.GX3_FILIAL <= '" + cFilAte + "' "
	cFiltro += "   AND GX3.GX3_DTCRIA >= '" + DtoS(dDataDe) + "' AND GX3.GX3_DTCRIA <= '" + DtoS(dDataAte) + "' "
	If Trim(cCodTrans) != "" 
		cFiltro += "   AND GX3.GX3_CDEMIT = '" + cCodTrans + "' "
	EndIf
	If Trim(cCodVei) != ""
		cFiltro += "   AND GX6.GX6_CDVEIC = '" + cCodVei + "' "
	EndIf
	
	cPlaca := Posicione("GU8",1,xFilial("GU8")+cCodVei,"GU8_PLACA")
	
	aADD(aGridEst, {"Veículo",	Substr(cPlaca,0,3) +"-"+ Substr(cPlaca,4,4) })
	aADD(aGridEst, {"Data de", 	dDataDe })
	aADD(aGridEst, {"Data até", dDataAte })


	cQuery := "SELECT		MAX(GX3.GX3_DTCRIA) 	MAX_DTMOV, "
	cQuery += "        	MIN(GX3.GX3_DTCRIA) 	MIN_DTMOV, "
	cQuery += "       	SUM(GWN.QTD_ROM) 	TOT_ROM, "
	cQuery += "       	COUNT(GX3.GX3_NRMOV) TOT_MOVTO, "
	cQuery += "       	SUM(GWV.QTD_AGEN) 	TOT_MOVAG, "
	cQuery += "       	COUNT(CASE WHEN GX3.GX3_SIT = '5' THEN 1 END) TOT_MOVCAN, "
	cQuery += "       	COUNT(CASE WHEN GX3.GX3_SIT = '6' THEN 1 END) TOT_MOVCON, "
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
	cQuery += " INNER JOIN " + RetSQLName("GX6") + " GX6 ON GX6.GX6_FILIAL = GX3.GX3_FILIAL "
	cQuery += "						 AND GX6.GX6_NRMOV  = GX3.GX3_NRMOV "
	cQuery += "                      AND GX6.D_E_L_E_T_ = '' "

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
	cQuery += "  		     INNER JOIN (SELECT GW8_FILIAL, GW8_CDTPDC, GW8_EMISDC, GW8_SERDC, GW8_NRDC, SUM(GW8_PESOR) GW8_PESOR, SUM(GW8_VOLUME) GW8_VOLUME, SUM(GW8_PESOR) GW8_VALOR  "
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
			aADD(aGridEst, {"Mov Concluídas",					(cTmp)->TOT_MOVCON})
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

			If Trim(cCodTrans) != ""

				If GX3->GX3_CDEMIT == cCodTrans
					GFEC511CTM()					
				EndIf
				
			Else
				GFEC511CTM()
			EndIf

			GX3->( dbSkip() )
		EndDo
	EndIf
	
	aADD(aGridEst, {"Tempo médio movimentações (h)",		AllTrim(Transform(nTmpTot / nInd,'@E 999.99')) })
	aADD(aGridEst, {"Tempo máximo movimentações (h)",	AllTrim(Transform(nTmpMax,'@E 999.99')) })
	aADD(aGridEst, {"Tempo mínimo movimentações (h)",	AllTrim(Transform(nTmpMin,'@E 999.99')) })
	

	// ####### GRAFICO SIT AGENDAMENTOS #######
	cQuery := "SELECT	COUNT(CASE WHEN GWV.GWV_SIT = '1' THEN 1 END) TOT_AGAB , "
	cQuery += "		COUNT(CASE WHEN GWV.GWV_SIT = '2' THEN 1 END) TOT_AGCON , "
	cQuery += "		COUNT(CASE WHEN GWV.GWV_SIT = '3' THEN 1 END) TOT_AGCAN "
	cQuery += "  FROM " + RetSQLName("GWV") + " GWV "
	cQuery += "  LEFT JOIN " + RetSQLName("GX3") + " GX3	 ON GWV.GWV_FILIAL = GX3.GX3_FILIAL "
	cQuery += "  					  							AND GWV.GWV_NRMOV = GX3.GX3_NRMOV "
	cQuery += "  	 			  	  							AND GWV.D_E_L_E_T_ = '' "
	cQuery += "  LEFT JOIN " + RetSQLName("GX6") + " GX6	 ON GX6.GX6_FILIAL = GX3.GX3_FILIAL "
	cQuery += "  	 			  	  							AND GX6.GX6_NRMOV  = GX3.GX3_NRMOV "
	cQuery += "  	 			  	  							AND GX6.D_E_L_E_T_ = '' "
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
	cQuery := "SELECT	COUNT(DISTINCT GX3.GX3_NRMOV) MOV_ANDA,
	cQuery += " 		COUNT(CASE WHEN GX3.GX3_SIT = '5' THEN 1 END) MOV_CANC,
	cQuery += " 		COUNT(CASE WHEN GX3.GX3_SIT = '6' THEN 1 END) MOV_CONC
	cQuery += "   FROM " + RetSQLName("GX3") + " GX3
	cQuery += " INNER JOIN " + RetSQLName("GX6") + " GX6	 ON GX6.GX6_FILIAL = GX3.GX3_FILIAL "
	cQuery += "  	 			  	  							AND GX6.GX6_NRMOV  = GX3.GX3_NRMOV "
	cQuery += "  	 			  	  							AND GX6.D_E_L_E_T_ = '' "
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
	cQuery += "  LEFT JOIN " + RetSQLName("GX6") + " GX6	 ON GX6.GX6_FILIAL = GX3.GX3_FILIAL "
	cQuery += "			  	  	  							AND GX6.GX6_NRMOV  = GX3.GX3_NRMOV "
	cQuery += "  	 			  	  							AND GX6.D_E_L_E_T_ = '' "
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
	cQuery += "  LEFT JOIN " + RetSQLName("GX6") + " GX6	 ON GX6.GX6_FILIAL = GX3.GX3_FILIAL "
	cQuery += "			  	  	  							AND GX6.GX6_NRMOV  = GX3.GX3_NRMOV "
	cQuery += "  	 			  	  							AND GX6.D_E_L_E_T_ = '' "	
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
				{"Situação"			,"GX3_SIT"		,"C",20,0},;
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
	cQuery += "  LEFT JOIN " + RetSQLName("GX6") + " GX6	 ON GX6.GX6_FILIAL = GX3.GX3_FILIAL "
	cQuery += "			  	  	  							AND GX6.GX6_NRMOV  = GX3.GX3_NRMOV "
	cQuery += "  	 			  	  							AND GX6.D_E_L_E_T_ = '' "
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
	cQuery += "  LEFT JOIN " + RetSQLName("GX6") + " GX6	 ON GX6.GX6_FILIAL = GX3.GX3_FILIAL "
	cQuery += "			  	  	  							AND GX6.GX6_NRMOV  = GX3.GX3_NRMOV "
	cQuery += "  	 			  	  							AND GX6.D_E_L_E_T_ = '' "
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
	cQuery += "  LEFT JOIN " + RetSQLName("GX6") + " GX6	 ON GX6.GX6_FILIAL = GWD.GWD_FILIAL "
	cQuery += "			  	  	  							AND GX6.GX6_NRMOV  = GWD.GWD_NRMOV "
	cQuery += "  	 			  	  							AND GX6.D_E_L_E_T_ = '' "
	cQuery += cFiltro
	cQuery += "   AND GWD.D_E_L_E_T_ = '' "

	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	
	While (cTmp)->(!Eof())
		RecLock(cAlias,.T.)
		
			cNmTrans	:= Posicione("GU3",1,xFilial("GU3")+(cTmp)->GWD_CDTRP,"GU3_NMEMIT")
			cTipo 		:= Posicione("GU5",1,xFilial("GU5")+(cTmp)->GWD_CDTIPO,"GU5_DESC")
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
				{"Situação"      		,"GWN_SIT"		,"C",15,0},;
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
	cQuery += "  LEFT JOIN " + RetSQLName("GX6") + " GX6	 ON GX6.GX6_FILIAL = GWN.GWN_FILIAL "
	cQuery += "			  	  	  							AND GX6.GX6_NRMOV  = GWN.GWN_NRMOV "
	cQuery += "  	 			  	  							AND GX6.D_E_L_E_T_ = '' "
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
	Local cSit		:= ''
	Local cAlias
	Local aFields, aIndices
	Local nCont
	Local aStruct := {}

	aFields := {;
				{"Filial"			,"GUU_FILIAL"	,"C",TamSX3("GUU_FILIAL")[1],0},;
				{"Cód Motorista"	,"GUU_CDMTR"	,"C",TamSX3("GUU_CDMTR")[1],0},;
				{"Nome"			,"GUU_NMMTR"	,"C",TamSX3("GUU_NMMTR")[1],0},;
				{"Pseud/Apelid"	,"GUU_PSEUD" 	,"C",TamSX3("GUU_PSEUD")[1],0},;
				{"CPF"				,"GUU_IDFED" 	,"C",TamSX3("GUU_IDFED")[1],0},;
				{"Situação"		,"GUU_SIT" 	,"C",20,0} }  

	aIndices := {"GUU_FILIAL+GUU_CDMTR"}

	For nCont := 1 To Len(aFields)
		aADD(aStruct,{aFields[nCont][2],;  // Nome do campo
						aFields[nCont][3],;  // Tipo
						aFields[nCont][4],;  // Tamanho
						aFields[nCont][5]})	// Decimal
	Next nCont

	cAlias := GFECriaTab({aStruct,aIndices})

	// ####### MOTORISTAS #######
	cQuery := "SELECT GUU.GUU_FILIAL, GUU.GUU_CDMTR, GUU.GUU_NMMTR, GUU.GUU_PSEUD, GUU.GUU_IDFED, GUU.GUU_SIT " 
	cQuery += "  FROM " + RetSQLName("GUU") + " GUU " 
	cQuery += " INNER JOIN " + RetSQLName("GX8") + " GX8	 ON GX8.GX8_CDMTR  = GUU.GUU_CDMTR "
	cQuery += "  LEFT JOIN " + RetSQLName("GX3") + " GX3	 ON GX3.GX3_FILIAL = GX8.GX8_FILIAL "
	cQuery += "	  											AND GX3.GX3_NRMOV  = GX8.GX8_NRMOV	"
	cQuery += "												AND GX3.D_E_L_E_T_ = '' "
	cQuery += "  LEFT JOIN " + RetSQLName("GX6") + " GX6	 ON GX6.GX6_FILIAL = GX8.GX8_FILIAL "
	cQuery += "			  	  	  							AND GX6.GX6_NRMOV  = GX8.GX8_NRMOV "
	cQuery += "  	 			  	  							AND GX6.D_E_L_E_T_ = '' "
	cQuery += cFiltro
	cQuery += "   AND GUU.D_E_L_E_T_ = '' "
	cQuery += " GROUP BY GUU.GUU_FILIAL, GUU.GUU_CDMTR, GUU.GUU_NMMTR, GUU.GUU_PSEUD, GUU.GUU_IDFED, GUU.GUU_SIT "

	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	
	While (cTmp)->(!Eof())
		RecLock(cAlias,.T.)

			// GUU_SIT 1=Ativo | 2=Inativo | 3=Entrada Proibida
			DO CASE
				CASE (cTmp)->GUU_SIT = '1'
					cSit := "Ativo"
				CASE (cTmp)->GUU_SIT = '2'
					cSit := "Inativo"
				CASE (cTmp)->GUU_SIT = '3'
					cSit := "Entrada Proibida"
			ENDCASE

			(cAlias)->GUU_FILIAL	:= (cTmp)->GUU_FILIAL
			(cAlias)->GUU_CDMTR 	:= (cTmp)->GUU_CDMTR 
			(cAlias)->GUU_NMMTR 	:= (cTmp)->GUU_NMMTR
			(cAlias)->GUU_PSEUD 	:= (cTmp)->GUU_PSEUD 
			(cAlias)->GUU_IDFED 	:= (cTmp)->GUU_IDFED 
			(cAlias)->GUU_SIT 	:= cSit

		MsUnlock(cAlias)
		(cTmp)->(dbSkip())
	EndDo

	(cTmp)->(dbCloseArea())

Return cAlias


Static Function Atualiza()
	//Atualiza Gráficos
	GFEC511GRA(oGrfSitAg	,.T.,aGrfSitAg)
	GFEC511GRA(oGrfSitMov,.T.,aGrfSitMov)
	GFEC511GRA(oGrfMovOp	,.T.,aGrfMovOp)
	
	//Atualiza o Grid  
//	oGridEst:SetArray(aGridEst)
//	oGridEst:UpdateBrowse()
	
Return Nil

//=========================================================================/
Function GFEC511GRA(oGrf,lAtual,aSerie,cTitulo)  
	Local nCont
	Default lAtual := .F.
	   
	If lAtual
		oGrf:Reset()
	EndIf 
	
	If cTitulo != Nil
		oGrf:SetTitle(cTitulo)
	EndIf
	
	For nCont := 1 To Len(aSerie)
		oGrf:AddSerie(AllTrim(aSerie[nCont][1]), aSerie[nCont][2])
	Next
	
	oGrf:Build()
Return Nil 

Function GFEC511GRC(cGrf,cTitulo,oOwner,aSerie,cPicture,bSerieAction,xTipo)
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
	
	GFEC511GRA(&(cGrf),,aSerie)
	
Return Nil


Static Function VisualAgen()

	dbSelectArea("GWV")
	GWV->(dbSetOrder(1))
	If GWV->(dbSeek((cAlias2)->(GWV_FILIAL + GWV_NRAGEN )))
		FWExecView("Visualizar", "GFEA517", 1,, {||.T.})
	EndIf
	
Return Nil


Static Function VisualMov()

	dbSelectArea("GX3")
	GX3->(dbSetOrder(1))
	If GX3->(dbSeek((cAlias31)->(GX3_FILIAL + GX3_NRMOV )))
		FWExecView("Visualizar", "GFEC510", 1,, {||.T.})
	EndIf

Return Nil

Static Function VisualOcor()

	dbSelectArea("GWD")
	GWD->(dbSetOrder(1))
	If GWD->(dbSeek((cAlias4)->(GWD_FILIAL + GWD_NROCO )))
		FWExecView("Visualizar", "GFEC032", 1,, {||.T.})
	EndIf

Return Nil

Static Function VisualRoma()

	dbSelectArea("GWN")
	GWN->(dbSetOrder(1))
	If GWN->(dbSeek((cAlias5)->(GWN_FILIAL + GWN_NRROM )))
		FWExecView("Visualizar", "GFEC050", 1,, {||.T.})
	EndIf

Return Nil

Static Function VisualMoto()

	dbSelectArea("GUU")
	GUU->(dbSetOrder(1))
	If GUU->(dbSeek((cAlias6)->( GUU_FILIAL + GUU_CDMTR )))
		FWExecView("Visualizar", "GFEA012", 1,, {||.T.})
	EndIf

Return Nil


Static Function GFEC511CTM()
	
	dbSelectArea("GX6")
	GX6->( dbSetOrder(1) )
	GX6->( dbSeek(xFilial("GX6") + GX3->GX3_NRMOV ) )
	While GX6->( !Eof() ) .And. xFilial("GX6") == GX6->GX6_FILIAL .And. GX6->GX6_NRMOV == GX3->GX3_NRMOV
		If Trim(cCodVei) != ""
			If GX6->GX6_CDVEIC == cCodVei
	
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
						nInd += 1									
						nTmpTot += nTmpMed
	
						// GX3_SIT ==== 1=Aberto 2=Movimentado 3=Em Fila 4=Endereçado 5=Cancelado 6=Concluido
						If nTmpMin == 0
							nTmpMin := nTmpMed
						ElseIf nTmpMed < nTmpMin
							nTmpMin := nTmpMed
						EndIf
							
						If nTmpMax == 0
							nTmpMax := nTmpMed
						ElseIf nTmpMed > nTmpMax
							nTmpMax := nTmpMed
						EndIf
						
					EndIf
						
					GX4->( dbSkip() )
				EndDo
			EndIf
		EndIf
	
		GX6->( dbSkip() )
	EndDo
	
Return Nil


// -------------------------------
// Retorna em Horas a diferença
// -------------------------------
Function GFEC511ATM(dDtEnt,dDtSai,cHrEnt,cHrSai)
	Local nDiff   := 0
	Local nDifDt	:= 0
	Local nDifHr	:= 0
	Local nDifMin	:= 0
	Local nDifTot	:= 0
	Local cAux		:= ""
	
	// Verifica preenchimento dos parâmetros
	If Empty(dDtEnt) .Or. Empty(dDtSai) .Or. Empty(cHrEnt) .Or. Empty(cHrSai)
		Return nDiff
	EndIf
	
	// Diferença das datas (em dias)
	nDifDt := dDtSai - dDtEnt
	
	cHrEnt := AllTrim( StrTran(cHrEnt,":","") )
	cHrSai := AllTrim( StrTran(cHrSai,":","") )
	
	// Se informar a data de saída menor que a data de entrada para a mesma data retorna 0
	If nDifDt == 0 .And. cHrSai < cHrEnt
		Return nDiff
	EndIf
	
	// Prepara horas para função ElapTime
	cHrEnt := Stuff(cHrEnt,3,0,":") + ":00"
	cHrSai := Stuff(cHrSai,3,0,":") + ":00"
	
	  // Diferença dos horários
	cAux	:= ElapTime(cHrEnt, cHrSai)
	
	nDifHr	:= Val(SubStr(cAux,1,2))
	nDifMin:= Val(SubStr(cAux,4,2))
	
	// Diferença total em minutos
	nDifTot := nDifMin + (nDifHr * 60) + (nDifDt * 24 * 60)
	
	// Quando a hora de entrada é maior do que a hora de saída, devemos tirar 1 dia (em minutos do total). 
	// Verificar funcionamento da função ElapTime para dúvidas.
	If cHrEnt > cHrSai
		nDifTot -= 24 * 60   
	EndIf
	
	// Transforma para horas
	nDiff := nDifTot / 60
Return nDiff
