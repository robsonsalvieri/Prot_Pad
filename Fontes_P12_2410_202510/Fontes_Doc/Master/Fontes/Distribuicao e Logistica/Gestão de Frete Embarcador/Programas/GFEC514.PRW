#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH' 
//-------------------------------------------------------------------
//Inclusão Pátios 12.1.4
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEC514
Movimentações de Portarias
Generico

@sample
GFEC514()

@author Helder Fuckner dos Santos
@since 23/04/14
@version 1.0                                 
/*/
//------------------------------------------------------------------------------------------------

Function GFEC514()
	Local oBrowse
	Local aCoors			:= FWGetDialogSize( oMainWnd )
	Private cTitulo		:= 'Movimentações de Portarias'
	Private nInd			:= 0
	Private cFiltro		:= ''
	Private lFirst		:= .F.
	Private cFilialDe  	:= MV_PAR01
	Private cFilialAte 	:= MV_PAR02
	Private dDataDe  		:= If(Empty(MV_PAR03),DDATABASE -30 ,MV_PAR03)
	Private dDataAte 		:= If(Empty(MV_PAR04),DDATABASE     ,MV_PAR04)
	Private cCdOperDe		:= MV_PAR05
	Private cSeqDe		:= MV_PAR06
	Private cCdOperAte	:= MV_PAR07
	Private cSeqAte		:= MV_PAR08                   
	Private cCodTransp 	:= MV_PAR09
	
	Private oGrid1, oGrid2, oGrid3, oGrf1, oGrf2, oGrf3, oGrf4
	Private aGrid1, aGrid2, aGrid3, aGrf1, aGrf2, aGrf3, aGrf4
	Private oPnl1, oPnl2, oPnl3, oPnl4, oPnl41, oPnl42, oPnl43, oPnl44
	Private cAlias1, cAlias2, cAlias3
	Private oRelacGX4
	Private oDlg
	
	If !VldPergunte()
		Return 
	EndIf
	
	CriaTabelas()
	
	Define MsDialog oDlg Title cTitulo From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel

	/*Criando objeto Layer*/
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDLG,.F.)
	
	oFWLayer:AddLine('LINEMV1',35,.F.)
	oFWLayer:AddLine('LINEMV2',35,.F.)
	oFWLayer:AddLine('LINEMV3',30,.F.)

	oFWLayer:AddCollumn('COL_BRWMOV',100,.T.,'LINEMV1')
	oFWLayer:AddCollumn('COL_BRWPTC',100,.T.,'LINEMV2')
	oFWLayer:AddCollumn('COL_BRW3',35,.T.,'LINEMV3')
	oFWLayer:AddCollumn('COL_GRF3',65,.T.,'LINEMV3')

	oPnl1 := oFWLayer:GetColPanel('COL_BRWMOV','LINEMV1')
	oPnl2 := oFWLayer:GetColPanel('COL_BRWPTC','LINEMV2')

	oPnl3 := oFWLayer:GetColPanel('COL_BRW3','LINEMV3')

	oFWLayer:AddWindow('COL_GRF3','WIN_GRF','Gráficos Movimentações',100,.F.,.F.,,'LINEMV3',)
	oPnl4 := oFWLayer:GetWinPanel('COL_GRF3', 'WIN_GRF', 'LINEMV3')

	oDlg:Activate(,,,.T.,,,{|| Processa({|| Iniciar() }) })

	GFEDelTab(cAlias1)
	GFEDelTab(cAlias2)
	GFEDelTab(cAlias3)

Return

Static Function VldPergunte()
	Local lRet := .F.
	Local s_GFEC514 := Pergunte("GFEC514", .T.)
	
	While s_GFEC514
		
		cFilialDe	:= MV_PAR01
		cFilialAte	:= MV_PAR02
		dDataDe	:= MV_PAR03
		dDataAte	:= MV_PAR04
		cCdOperDe	:= MV_PAR05
		cSeqDe		:= MV_PAR06
		cCdOperAte	:= MV_PAR07
		cSeqAte	:= MV_PAR08
		cCodTransp	:= MV_PAR09
		
		If Empty(dDataDe) .Or. Empty(dDataAte)
			MsgStop("Informe a faixa de data de movimentação dos Pontos de Controle.", "Atenção")
			Loop
		EndIf

		If dDataDe > dDataAte
			MsgStop("A 'Data de Movimentação de' deve ser menor do que a 'Data Movimentação até'.", "Atenção")
			Loop
		EndIf

		If cCdOperDe > cCdOperAte
			MsgStop("O 'Código de Operação de' deve ser menor do que o 'Código de Operação até'.", "Atenção")
			Loop
		EndIf

		If cSeqDe > cSeqAte
			MsgStop("A 'Sequência de' deve ser menor do que a 'Sequência até'.", "Atenção")
			Loop
		EndIf
				
		lRet := .T.

		cFiltro := " WHERE GX3.D_E_L_E_T_ = '' AND GX4.D_E_L_E_T_ = '' "
		cFiltro += " 	 AND GX3.GX3_FILIAL >= '" + cFilialDe + "' AND GX3.GX3_FILIAL <= '" + cFilialAte + "' "
		cFiltro += "   AND GX3.GX3_SIT IN ('5','6')"
		cFiltro += "   AND GX3.GX3_DTCRIA >= '" + DtoS(dDataDe) + "' AND GX3.GX3_DTCRIA <= '" + DtoS(dDataAte) + "' "
		cFiltro += "   AND GX3.GX3_CDOPER || GX3.GX3_SEQ >= '" + cCdOperDe + cSeqDe + "'"
		cFiltro += "   AND GX3.GX3_CDOPER || GX3.GX3_SEQ <= '" + cCdOperAte + cSeqAte + "'"

		If Trim(cCodTransp) != "" 
			cFiltro += " AND GX3.GX3_CDEMIT = '" + cCodTransp + "' "
		EndIf
		cFiltro += "   AND GX4.GX4_SEQ    = '001'"
		
		Exit
	EndDo
	
Return lRet

Static Function Iniciar()
	Local nCount

	//Browses
	CursorWait()
	oPnl1:SetUpdatesEnabled(.F.)
	oPnl2:SetUpdatesEnabled(.F.)

	// BROWSE PONTO DE CONTROLE GX4
	aGrid1 := {;
				{"Filial"				,"GX4_FILIAL"	,"C",TamSX3("GX4_FILIAL")[1],0,"",1,10},;
				{"Ponto Controle"		,"GX4_CDPTCT"	,"C",TamSX3("GX4_CDPTCT")[1],0,"",1,10},;
				{"Qtd Mov"				,"QTD_MOV"		,"N",7,0,"",1,10},;
				{"Com Agend"			,"QTD_CAG"		,"N",7,0,"",1,10},;
				{"Sem Agend"			,"QTD_SAG"		,"N",7,0,"",1,10},;
				{"Aprovadas"			,"QTD_APR"		,"N",7,0,"",1,10},;
				{"Reprovadas"			,"QTD_REP"		,"N",7,0,"",1,10},;
				{"Tempo Médio Atend"	,"TMP_MEDAT"	,"C",7,0,"",1,10},;
				{"Qtd Veículos"		,"QTD_VEI"		,"N",7,0,"",1,10},;
				{"Qtd Motoristas"		,"QTD_MOT"		,"N",7,0,"",1,10} }

	LoadPTO()

	oGrid1:= FWMBrowse():New()
	oGrid1:SetOwner(oPnl1)
	oGrid1:SetDescription("Pontos de Controle")
	oGrid1:SetAlias(cAlias1)
	oGrid1:SetLocate()
	oGrid1:ForceQuitButton()
	oGrid1:DisableDetails()
	oGrid1:DisableConfig()
	//oGrid1:SetAmbiente(.F.) // comentado pois não estava apresentando os 2 botões definidos abaixo
	oGrid1:SetWalkthru(.F.)
	oGrid1:SetProfileID("1")
	oGrid1:SetChange( {|| MudaEstGrf( (cAlias1)->GX4_FILIAL, (cAlias1)->GX4_CDPTCT ) } )
	oGrid1:SetFixedBrowse(.T.)
	oGrid1:SetMenuDef("GFEC514")

	For nCount := 1 To Len(aGrid1)
		oGrid1:AddColumn({ aGrid1[nCount][1],;
						     &("{|| (cAlias1)->" + aGrid1[nCount][2] + "}"),;
						     aGrid1[nCount][3],;
						     aGrid1[nCount][6],;
						     aGrid1[nCount][7],;
						     aGrid1[nCount][8],;
						     aGrid1[nCount][5],;
						     .F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}})						     
	Next nCount
	
	// BROWSE MOVIMENTACAO GX3
	aGrid2 := {;
				{"Dt Entrada"	,"GX4_DTENTR"	,"C",10,0,"",1,10},;
				{"Hr"			,"GX4_HRENTR"	,"C",TamSX3("GX4_HRENTR")[1],0,"",1,10},;
				{"Nr Mov"		,"GX3_NRMOV"	,"C",TamSX3("GX3_NRMOV")[1],0,"",1,10},;
				{"Operações"	,"GX3_CDOPER"	,"C",TamSX3("GX3_CDOPER")[1],0,"",1,10},;
				{"Veículo"		,"GU8_PLACA"	,"C",200,0,"",1,10},;
				{"Motorista"	,"GUU_NMMTR"	,"C",200,0,"",1,10},;
				{"Dt Saída"	,"GX4_DTSAI"	,"C",10,0,"",1,10},;
				{"Hr"			,"GX4_HRSAI"	,"C",TamSX3("GX4_HRSAI")[1],0,"",1,10},;
				{"Tempo Médio","TMP_MED"		,"C",7,0,"",1,10} }

	LoadMOV()

	oGrid2:= FWMBrowse():New()
	oGrid2:SetOwner(oPnl2)
	oGrid2:SetDescription("Movimentações")
	oGrid2:SetAlias(cAlias2)
	//oGrid2:SetAlias("GX4")
	oGrid2:SetLocate()
	oGrid2:DisableDetails()
//	oGrid2:ForceQuitButton()
	oGrid2:DisableConfig()
	oGrid2:SetAmbiente(.T.)
	oGrid2:SetWalkthru(.F.)
	oGrid2:SetProfileID("2") 
	oGrid2:SetFixedBrowse(.T.)
	oGrid2:AddButton("Consultar movimentação", "C514VMOV()",, 3, 0)
	oGrid2:SetMenuDef("")

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
	
	// ########## Estatísticas
	aGrid3 := {}
	
   	oGrid3 := FWBrowse():New()
	oGrid3:SetOwner(oPnl3)
	oGrid3:SetDescription("Estatísticas")
	oGrid3:SetDataArray()
	oGrid3:DisableFilter()
	oGrid3:DisableConfig()
//	oGrid3:DisableReport()
	oGrid3:SetArray(aGrid3)
	// Function GFEC001COL(cTitulo,xArrData,cPicture,nAlign,nSize,cBrowse,cTipo,nDecimal)
   	oGrid3:SetColumns(GFEC001COL("Descrição",1,,1,20,"oGrid3"))
	oGrid3:SetColumns(GFEC001COL("Valor",2,,1,18,"oGrid3"))


	// RELATIONS
	oRelacGX4:= FWBrwRelation():New()
	oRelacGX4:AddRelation(oGrid1, oGrid2, {{'FILMOV', 'GX4_FILIAL'}, {'PTCTMOV', 'GX4_CDPTCT'}})
	
	
	
	oGrid1:Activate()
	oGrid2:Activate()
	oGrid3:Activate()
	oRelacGX4:Activate()
	
	oPnl1:SetUpdatesEnabled(.T.)
	oPnl2:SetUpdatesEnabled(.T.)
	
	
	// ########## Graficos
	oFolder := TFolder():New(0,0,{"Agendamentos","Qtd Tipo Veículo","Qtd Operação","Tempo Médio Operações"},,oPnl4,,,,.T.,,(oPnl4:nwidth/2),(oPnl4:nHeight/2))
	oFolder:Align := CONTROL_ALIGN_ALLCLIENT

	aGrid4 := {}

	// ########## Grafico 1
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oFolder:aDialogs[1],.F.)
	
	oFWLayer:AddLine('LINE_1',100,.F.)

	oFWLayer:AddCollumn('COL_GRF_1',100,.T.,'LINE_1')
	
	oPnl41	:= oFWLayer:GetColPanel('COL_GRF_1','LINE_1')

	GFEC512GRC("oGrf1", "Agendamentos", oPnl41,	aGrf1)
	
	// ########## Grafico 2
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oFolder:aDialogs[2],.F.)
	
	oFWLayer:AddLine('LINE_2',100,.F.)

	oFWLayer:AddCollumn('COL_GRF_2',100,.T.,'LINE_2')
	
	oPnl42	:= oFWLayer:GetColPanel('COL_GRF_2','LINE_2')

	GFEC512GRC("oGrf2", "Qtd Tipo Veículo", oPnl42, aGrf2)
	
	// ########## Grafico 3
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oFolder:aDialogs[3],.F.)
	
	oFWLayer:AddLine('LINE_3',100,.F.)

	oFWLayer:AddCollumn('COL_GRF_3',100,.T.,'LINE_3')
	
	oPnl43	:= oFWLayer:GetColPanel('COL_GRF_3','LINE_3')

	GFEC512GRC("oGrf3", "Qtd Operação", oPnl43, aGrf3)

	// ########## Grafico 4
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oFolder:aDialogs[4],.F.)
	
	oFWLayer:AddLine('LINE_3',100,.F.)

	oFWLayer:AddCollumn('COL_GRF_4',	100,.T.,'LINE_3')
	
	oPnl44	:= oFWLayer:GetColPanel('COL_GRF_4','LINE_3')

	GFEC512GRC("oGrf4", "Tempo Médio Operações", oPnl44, aGrf4)
	
	lFirst := .T.
	CursorArrow()
	
Return Nil

//-------------------------------------------------------------------

Static Function MenuDef()

	Local aRotina := {}

	//-------------------------------------------------------
	// Adiciona botões do browse
	//-------------------------------------------------------
	ADD OPTION aRotina TITLE "Parâmetros" 				 ACTION "C514RefrBrowse()"	OPERATION 2 ACCESS 0

Return aRotina

//-------------------------------------------------------------------

Static Function CriaTabelas()
	Local aFields, aIndices, nCont
	Local aStruct
	
	// PONTO DE CONTROLE
	aStruct := {}
	aFields := {;
				{"Filial"				,"GX4_FILIAL"	,"C",TamSX3("GX4_FILIAL")[1],0},;
				{"Ponto Controle"		,"GX4_CDPTCT"	,"C",TamSX3("GX4_CDPTCT")[1],0},;
				{"Qtd Mov"				,"QTD_MOV"		,"N",7,0},;
				{"Com Agend"			,"QTD_CAG"		,"N",7,0},;
				{"Sem Agend"			,"QTD_SAG"		,"N",7,0},;
				{"Aprovadas"			,"QTD_APR"		,"N",7,0},;
				{"Reprovadas"			,"QTD_REP"		,"N",7,0},;
				{"Tempo Médio Atend"	,"TMP_MEDAT"	,"C",7,0},;
				{"Qtd Veículos"		,"QTD_VEI"		,"N",7,0},;
				{"Qtd Motoristas"		,"QTD_MOT"		,"N",7,0},;
				{"REPROVACOES"		,"TOT_REPRO"	,"N",7,0},;
				{"OCORRENCIAS"		,"TOT_OCORR"	,"N",7,0},;
				{"Tmp mínimo Atend"	,"TMP_MINAT"	,"C",7,0},;
				{"Tmp máximo Atend"	,"TMP_MAXAT"	,"C",7,0}}

	aIndices := {"GX4_FILIAL+GX4_CDPTCT"}

	For nCont := 1 To Len(aFields)
		aADD(aStruct,{aFields[nCont][2],;  // Nome do campo
						aFields[nCont][3],;  // Tipo
						aFields[nCont][4],;  // Tamanho
						aFields[nCont][5]})	// Decimal
	Next nCont

	cAlias1 := GFECriaTab({aStruct,aIndices})
	
	// MOVIMENTACOES
	aStruct := {}
	aFields := {;
				{"Filial"		,"FILMOV"		,"C",TamSX3("GX4_FILIAL")[1],0},;
				{"Pto Contr"	,"PTCTMOV"		,"C",TamSX3("GX4_CDPTCT")[1],0},;
				{"Dt Entrada"	,"GX4_DTENTR"	,"C",10,0},;
				{"Hr"			,"GX4_HRENTR"	,"C",TamSX3("GX4_HRENTR")[1],0},;
				{"Nr Mov"		,"GX3_NRMOV"	,"C",TamSX3("GX3_NRMOV")[1],0},;
				{"Operações"	,"GX3_CDOPER"	,"C",TamSX3("GX3_CDOPER")[1],0},;
				{"Veículo"		,"GU8_PLACA"	,"C",200,0},;
				{"Motorista"	,"GUU_NMMTR"	,"C",200,0},;
				{"Dt Saída"	,"GX4_DTSAI"	,"C",10,0},;
				{"Hr"			,"GX4_HRSAI"	,"C",TamSX3("GX4_HRSAI")[1],0},;
				{"Tempo Médio","TMP_MED"		,"C",7,0,"",1,10} }

	aIndices := {"FILMOV+PTCTMOV+GX3_NRMOV"}

	For nCont := 1 To Len(aFields)
		aADD(aStruct,{aFields[nCont][2],;  // Nome do campo
						aFields[nCont][3],;  // Tipo
						aFields[nCont][4],;  // Tamanho
						aFields[nCont][5]})	// Decimal
	Next nCont

	cAlias2 := GFECriaTab({aStruct,aIndices})
	
	// ESTATISTICAS
	aStruct := {}
	aFields := {;
				{"Filial"	     		,"GWN_FILIAL"	,"C",TamSX3("GWN_FILIAL")[1],0},;
				{"Nr Romaneio"		,"GWN_NRROM"	,"C",TamSX3("GWN_NRROM")[1],0},;
				{"Situação"      		,"GWN_SIT"		,"C",15,0,"",1,10},;
				{"Data Criação"		,"GWN_DTIMPL"	,"C",TamSX3("GWN_DTIMPL")[1],0},;
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

	cAlias3 := GFECriaTab({aStruct,aIndices})
Return

Function C514RefrBrowse()

	If VldPergunte()
		LoadPTO()
		oGrid1:UpdateBrowse()
		
		LoadMOV()
		oGrid2:UpdateBrowse()
		
		MudaEstGrf( (cAlias1)->GX4_FILIAL, (cAlias1)->GX4_CDPTCT )
	EndIf

Return

Static Function LoadPTO()
	Local cQuery	:= ''
	Local nCont		:= 0
	Local cTmp
	Local aFields, aIndices
	Local aStruct, cTmpMov
	Local nQtdAtend  	:= 0
	Local nTmpAtend	:= 0
	Local nVlrAtend	:= 0
	Local nTmpTot  	:= 0
	Local nTmpMax 	:= 0
	Local nTmpMin 	:= 0
	
	
	//
	// Temporária base para calcular o tempo de atendimento por ponto de controle
	//
	aStruct := {}
	aFields := {;
				{"ID"    			,"ID"			,"N",4,0},;
				{"Filial"    		,"GX4_FILIAL"	,"C",TamSX3("GX4_FILIAL")[1],0},;
				{"Ponto Controle"	,"GX4_CDPTCT"	,"C",TamSX3("GX4_CDPTCT")[1],0},;
				{"Nr. Movimento"	,"GX4_NRMOV"	,"C",TamSX3("GX4_NRMOV")[1],0},;
				{"Dt. Inicial"	,"DTINI"		,"C",TamSX3("GX4_DTSAI")[1],0},;
				{"Hr. Inicial"	,"HRINI"		,"C",TamSX3("GX4_HRSAI")[1],0},;
				{"Dt. Final"		,"DTFIM"		,"C",TamSX3("GX4_DTSAI")[1],0},;
				{"Hr. Final"		,"HRFIM"		,"C",TamSX3("GX4_HRSAI")[1],0}}

	aIndices := {"GX4_FILIAL+GX4_CDPTCT+GX4_NRMOV"}

	For nCont := 1 To Len(aFields)
		aADD(aStruct,{aFields[nCont][2],;  // Nome do campo
						aFields[nCont][3],;  // Tipo
						aFields[nCont][4],;  // Tamanho
						aFields[nCont][5]})	// Decimal
	Next nCont

	cTmpMov := GFECriaTab({aStruct,aIndices})
	
	cQuery := "SELECT	GX4.GX4_FILIAL, "
	cQuery += "  		GX4.GX4_CDPTCT, "
	cQuery += "		GX4.GX4_NRMOV, "
	cQuery += "		'' ID, "
	cQuery += "		GX4.GX4_DTENTR DTINI, "
	cQuery += "		GX4.GX4_HRENTR HRINI, "
	cQuery += "		GX4.GX4_DTSAI DTFIM, "
	cQuery += "		GX4.GX4_HRSAI HRFIM "
	cQuery += "  FROM	" + RetSqlName("GX3") + " GX3 "
	cQuery += " INNER JOIN " + RetSqlName("GX4") + " GX4 ON GX4.GX4_FILIAL = GX3.GX3_FILIAL "
	cQuery += "   AND GX4.GX4_NRMOV = GX3.GX3_NRMOV "
	cQuery += cFiltro
	cQuery += "   AND GX4.GX4_DTSAI != '' "
	
	
	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())

	nCont := 0
	While (cTmp)->(!Eof())
		RecLock(cTmpMov,.T.)
			
			nCont += 1
			(cTmpMov)->ID				:= nCont
			
			(cTmpMov)->GX4_FILIAL	:= (cTmp)->GX4_FILIAL
			(cTmpMov)->GX4_CDPTCT	:= (cTmp)->GX4_CDPTCT
			(cTmpMov)->GX4_NRMOV 	:= (cTmp)->GX4_NRMOV
			(cTmpMov)->DTINI			:= (cTmp)->DTINI
			(cTmpMov)->HRINI			:= (cTmp)->HRINI
			(cTmpMov)->DTFIM			:= (cTmp)->DTFIM
			(cTmpMov)->HRFIM			:= (cTmp)->HRFIM
			
		MsUnlock(cAlias1)
		(cTmp)->(dbSkip())
	EndDo
	(cTmp)->(dbCloseArea())
	
	
	dbSelectArea(cAlias1)
	ZAP
	
	//
	// Tabela com estatísticas por ponto de controle
	//

	// ####### PONTOS DE CONTROLE #######
	cQuery := "SELECT	GX4.GX4_FILIAL, "
	cQuery += "      	GX4.GX4_CDPTCT, "
	cQuery += "		COUNT(DISTINCT GX4_NRMOV) QTD_MOV, " 
	cQuery += "		COUNT(CASE WHEN GWV.QTD_AGEN IS NOT NULL THEN 1 END) QTD_CAG, "
	//cQuery += "		COUNT(CASE WHEN GWV.QTD_AGEN IS NULL THEN 1 END) QTD_SAG, "   
	cQuery += "		COUNT(CASE WHEN GX4.GX4_SIT = '2' THEN 1 END) QTD_APR, "
	cQuery += "		COUNT(CASE WHEN GX4.GX4_SIT = '3' THEN 1 END) QTD_REP, "
	cQuery += "		SUM(GX6.QTD_VEICULOS) 	QTD_VEI, " 
	cQuery += "		SUM(GX8.QTD_MOTORISTAS) 	QTD_MOT, "
	cQuery += "		SUM(GX5.QTD_REPROV) 		TOT_REPRO, "
	cQuery += "		SUM(GWD.QTD_OCORR) 		TOT_OCORR, "
	cQuery += "		'' TMP_MEDAT, "
	cQuery += "		'' TMP_MINAT, "
	cQuery += "		'' TMP_MAXAT "	
	cQuery += "  FROM "+ RetSQLName("GX3") +" GX3 "
	cQuery += " INNER JOIN "+ RetSQLName("GX4") +" GX4 ON GX4.GX4_FILIAL = GX3.GX3_FILIAL "
	cQuery += "                   						 AND GX4.GX4_NRMOV  = GX3.GX3_NRMOV "
	cQuery += "  LEFT JOIN (SELECT GWV_FILIAL, GWV_NRMOV, COUNT(*) QTD_AGEN "
	cQuery += "               FROM "+ RetSQLName("GWV")
	cQuery += "              WHERE D_E_L_E_T_ = '' "
	cQuery += "              GROUP BY GWV_FILIAL, GWV_NRMOV) GWV ON GWV.GWV_FILIAL = GX4.GX4_FILIAL " 
	cQuery += "                       							    AND GWV.GWV_NRMOV  = GX4.GX4_NRMOV "
	cQuery += "  LEFT JOIN (SELECT GX6_FILIAL, GX6_NRMOV, COUNT(*) QTD_VEICULOS " 
	cQuery += "               FROM "+ RetSQLName("GX6")
	cQuery += "              WHERE D_E_L_E_T_ = '' "
	cQuery += "              GROUP BY GX6_FILIAL, GX6_NRMOV) GX6 ON GX6.GX6_FILIAL = GX4.GX4_FILIAL " 
	cQuery += "                                                  AND GX6.GX6_NRMOV = GX4.GX4_NRMOV "
	cQuery += "  LEFT JOIN (SELECT GX8_FILIAL, GX8_NRMOV, COUNT(*) QTD_MOTORISTAS "
	cQuery += "               FROM "+ RetSQLName("GX8")
	cQuery += "              WHERE D_E_L_E_T_ = '' "
	cQuery += "              GROUP BY GX8_FILIAL, GX8_NRMOV) GX8 ON GX8.GX8_FILIAL = GX4.GX4_FILIAL "
	cQuery += "                                                  AND GX8.GX8_NRMOV = GX4.GX4_NRMOV "
	cQuery += "  LEFT JOIN (SELECT GX5_FILIAL, GX5_NRMOV, GX5_CDPTCT, GX5_SEQ, COUNT(*) QTD_REPROV "
	cQuery += "               FROM "+ RetSQLName("GX5")
	cQuery += "              WHERE D_E_L_E_T_ = '' "
	cQuery += "                AND GX5_RESPOS = '2' "
	cQuery += "              GROUP BY GX5_FILIAL, GX5_NRMOV, GX5_CDPTCT, GX5_SEQ) GX5 ON GX5.GX5_FILIAL = GX4.GX4_FILIAL " 
	cQuery += "	    		  								AND GX5.GX5_NRMOV  = GX4.GX4_NRMOV "
	cQuery += "			  	      							AND GX5.GX5_CDPTCT = GX4.GX4_CDPTCT "
	cQuery += "  	    			  							AND GX5.GX5_SEQ    = GX4.GX4_SEQ "
	cQuery += "  LEFT JOIN (SELECT GWD_FILIAL, GWD_NRMOV, GWD_CDPTCT, COUNT(*) QTD_OCORR "
	cQuery += "               FROM "+ RetSQLName("GWD")
	cQuery += "              WHERE D_E_L_E_T_ = '' "
	cQuery += "              GROUP BY GWD_FILIAL, GWD_NRMOV, GWD_CDPTCT) GWD ON GWD.GWD_FILIAL = GX4.GX4_FILIAL " 
	cQuery += " 	    			  							AND GWD.GWD_NRMOV  = GX4.GX4_NRMOV "
	cQuery += " 	    			  							AND GWD.GWD_CDPTCT = GX4.GX4_CDPTCT "
	cQuery += cFiltro
	cQuery += " GROUP BY GX4.GX4_FILIAL, GX4.GX4_CDPTCT "
	
	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())

	dbSelectArea(cTmpMov)
	(cTmpMov)->(dbSetOrder(1))

	While (cTmp)->(!Eof())
		RecLock(cAlias1,.T.)

			(cAlias1)->GX4_FILIAL	:= (cTmp)->GX4_FILIAL
			(cAlias1)->GX4_CDPTCT	:= (cTmp)->GX4_CDPTCT
			(cAlias1)->QTD_MOV 		:= (cTmp)->QTD_MOV
			(cAlias1)->QTD_CAG 		:= (cTmp)->QTD_CAG
			//(cAlias1)->QTD_SAG 		:= (cTmp)->QTD_SAG
			(cAlias1)->QTD_SAG 		:= (cTmp)->QTD_MOV - (cTmp)->QTD_CAG
			(cAlias1)->QTD_APR 		:= (cTmp)->QTD_APR
			(cAlias1)->QTD_REP 		:= (cTmp)->QTD_REP
			(cAlias1)->QTD_VEI		:= (cTmp)->QTD_VEI
			(cAlias1)->QTD_MOT		:= (cTmp)->QTD_MOT
			(cAlias1)->TOT_REPRO		:= (cTmp)->TOT_REPRO
			(cAlias1)->TOT_OCORR		:= (cTmp)->TOT_OCORR
			(cAlias1)->TMP_MEDAT		:= ''
			(cAlias1)->TMP_MINAT		:= ''
			(cAlias1)->TMP_MINAT		:= ''


			If (cTmpMov)->(dbSeek((cAlias1)->GX4_FILIAL+(cAlias1)->GX4_CDPTCT))

				nQtdAtend	:= 0
				nTmpAtend	:= 0
				nTmpMin	:= 99999
				nTmpMax	:= 0

				While (cTmpMov)->(!Eof()) .And. ;
				      (cTmpMov)->GX4_FILIAL == (cAlias1)->GX4_FILIAL .And. ;
				      (cTmpMov)->GX4_CDPTCT == (cAlias1)->GX4_CDPTCT

					nVlrAtend := GFEC511ATM(StoD((cTmpMov)->DTINI),StoD((cTmpMov)->DTFIM),(cTmpMov)->HRINI,(cTmpMov)->HRFIM)

					// INI - Calcula Mínimo e Máximo
					If nVlrAtend != 0
						
						If nTmpMin == 99999
							nTmpMin := nVlrAtend
						ElseIf nVlrAtend < nTmpMin
							nTmpMin := nVlrAtend
						EndIf
						
						If nTmpMax == 0
							nTmpMax := nVlrAtend
						ElseIf nVlrAtend > nTmpMax
							nTmpMax := nVlrAtend
						EndIf

					EndIf
					// FIM - Calcula Mínimo e Máximo
					
					If nVlrAtend != 0
						nQtdAtend++
						nTmpAtend += nVlrAtend
					EndIf

					(cTmpMov)->(dbSkip())
				EndDo

				nTmpTot := nTmpAtend / nQtdAtend

				If nTmpTot > 0
					(cAlias1)->TMP_MEDAT := AllTrim(Transform(nTmpTot,'@E 99999.99'))
				EndIf

				(cAlias1)->TMP_MINAT := AllTrim(Transform(nTmpMin,'@E 99999.99'))
				(cAlias1)->TMP_MAXAT := AllTrim(Transform(nTmpMax,'@E 99999.99'))

			EndIf

		MsUnlock(cAlias1)
		(cTmp)->(dbSkip())
	EndDo

	(cTmp)->(dbCloseArea())
Return


Static Function LoadMOV()
	Local cQuery	:= ''
	Local cCodMTR	:= ''
	Local cCodVei	:= ''
	Local cLstVei	:= ''
	Local cLstMot	:= ''
	Local cPictPlaca := PesqPict('GU8','GU8_PLACA')
	Local cTmp

	dbSelectArea(cAlias2)
	ZAP

	cQuery := "SELECT	GX4.GX4_FILIAL FILMOV, "
	cQuery += "		GX4.GX4_CDPTCT PTCTMOV, "
	cQuery += "		GX4.GX4_DTENTR, "
	cQuery += "		GX4.GX4_HRENTR, "
	cQuery += "		GX3.GX3_NRMOV, "
	cQuery += "		GX3.GX3_CDOPER, "
	cQuery += "		GX4.GX4_DTSAI, "
	cQuery += "		GX4.GX4_HRSAI, "
	cQuery += "		'' TMP_MED "
	cQuery += "  FROM " + RetSQLName("GX4") + " GX4 "
	cQuery += " INNER JOIN " + RetSQLName("GX3") + " GX3	 ON GX3.GX3_FILIAL = GX4.GX4_FILIAL "
	cQuery += "    				  							AND GX3.GX3_NRMOV  = GX4.GX4_NRMOV "
	cQuery += "    				  							AND GX3.D_E_L_E_T_ = '' "
	cQuery += cFiltro
	cQuery += " ORDER BY GX4.GX4_FILIAL, GX4.GX4_CDPTCT, GX3.GX3_NRMOV"

	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())

	While (cTmp)->(!Eof())

		//cCodVei := Posicione("GX6",1,xFilial("GX6")+(cTmp)->GX3_NRMOV,"GX6_CDVEIC")
		// Lista de Veiculos da Movimentação
		cLstVei := ''
	  	dbSelectArea("GX6")
		GX6->( dbSetOrder(1) ) // GX6_FILIAL + GX6->GX6_NRMOV + GX6_CDVEIC
		If GX6->( dbSeek((cTmp)->FILMOV + (cTmp)->GX3_NRMOV ) )
			While GX6->( !Eof() ) .And. GX6->GX6_FILIAL == (cTmp)->FILMOV .And. GX6->GX6_NRMOV == (cTmp)->GX3_NRMOV 

				cCodVei := Posicione("GU8",1,xFilial("GU8")+GX6->GX6_CDVEIC,"GU8_PLACA") 

				If !Empty(cCodVei)
					cCodVei := Transform(cCodVei,cPictPlaca)

					If cLstVei == ''
						cLstVei := cCodVei
					Else
						cLstVei += ", " + cCodVei
					EndIf
				EndIf
				
				GX6->( dbSkip() )
			EndDo
		EndIf
				
		//cCodMTR := Posicione("GX8",1,xFilial("GX8")+(cTmp)->GX3_NRMOV,"GX8_CDMTR")
		// Lista de Motoristas da Movimentação
		cLstMot := ''
	  	dbSelectArea("GX8")
		GX8->( dbSetOrder(1) ) // GX8_FILIAL + GX8->GX8_NRMOV + GX8_CDVEIC
		If GX8->( dbSeek((cTmp)->FILMOV + (cTmp)->GX3_NRMOV ) )
			While GX8->( !Eof() ) .And. GX8->GX8_FILIAL == (cTmp)->FILMOV .And. GX8->GX8_NRMOV == (cTmp)->GX3_NRMOV 

				cCodMTR := AllTrim(Posicione("GUU",1,xFilial("GUU")+GX8->GX8_CDMTR,"GUU_PSEUD")) 

				If !Empty(cCodMTR)
					If cLstMot == ''
						cLstMot := cCodMTR
					Else
						cLstMot += ", " + cCodMTR
					EndIf
				EndIf
				
				GX8->( dbSkip() )
			EndDo
		EndIf

		RecLock(cAlias2,.T.)

			(cAlias2)->FILMOV			:= (cTmp)->FILMOV
			(cAlias2)->PTCTMOV		:= (cTmp)->PTCTMOV
			(cAlias2)->GX4_DTENTR	:= Substr((cTmp)->GX4_DTENTR, 7,2) +'/'+ Substr((cTmp)->GX4_DTENTR, 5,2) +'/'+ Substr((cTmp)->GX4_DTENTR, 0,4)
			(cAlias2)->GX4_HRENTR	:= Substr((cTmp)->GX4_HRENTR,0,2) +':'+ Substr((cTmp)->GX4_HRENTR,3,2)
			(cAlias2)->GX3_NRMOV		:= (cTmp)->GX3_NRMOV
			(cAlias2)->GX3_CDOPER	:= (cTmp)->GX3_CDOPER
			(cAlias2)->GU8_PLACA		:= cLstVei
			(cAlias2)->GUU_NMMTR		:= cLstMot
			(cAlias2)->GX4_DTSAI		:= Substr((cTmp)->GX4_DTSAI, 7,2) +'/'+ Substr((cTmp)->GX4_DTSAI, 5,2) +'/'+ Substr((cTmp)->GX4_DTSAI, 0,4)
			(cAlias2)->GX4_HRSAI		:= Substr((cTmp)->GX4_HRSAI,0,2) +':'+ Substr((cTmp)->GX4_HRSAI,3,2)
			(cAlias2)->TMP_MED		:= AllTrim(Transform( GFEC511ATM(StoD((cTmp)->GX4_DTENTR),StoD((cTmp)->GX4_DTSAI),(cTmp)->GX4_HRENTR,(cTmp)->GX4_HRSAI) ,'@E 99999.99'))

		MsUnlock(cAlias2)
		(cTmp)->(dbSkip())
	EndDo

	(cTmp)->(dbCloseArea())

Return


Static Function LoadEstat()
			
	aGrid3 := {}

	aADD(aGrid3, {"Qtd movimentações",				(cAlias1)->QTD_MOV})
	aADD(aGrid3, {"Com agendamento",				(cAlias1)->QTD_CAG})
	aADD(aGrid3, {"Sem agendamento",				(cAlias1)->QTD_SAG})
	aADD(aGrid3, {"Aprovadas",						(cAlias1)->QTD_APR})
	aADD(aGrid3, {"Reprovadas",						(cAlias1)->QTD_REP})
	aADD(aGrid3, {"Qtd Veículos", 					(cAlias1)->QTD_VEI})
	aADD(aGrid3, {"Qtd Motoristas", 				(cAlias1)->QTD_MOT})
	aADD(aGrid3, {"Qtd Reprovações",				(cAlias1)->TOT_REPRO})
	aADD(aGrid3, {"Qtd Ocorrências", 				(cAlias1)->TOT_OCORR})
	aADD(aGrid3, {"Tempo médio atendimento (h)",	(cAlias1)->TMP_MEDAT})
	aADD(aGrid3, {"Tempo mínimo atendimento (h)",	(cAlias1)->TMP_MINAT})
	aADD(aGrid3, {"Tempo máximo atendimento (h)",	(cAlias1)->TMP_MAXAT})
			
Return


Static Function LoadGraf(cFil, cPto)
	Local cQuery		:= ''
	Local cTmp   		:= ''
	Local cFiltroPTO 	:= ''
	Local cOper		:= ''
	Local nTmpMed		:= 0
	Local dtEnt
	Local hrEnt
	Local dtSai
	Local hrSai

	aGrf1	:= {}
	aGrf2	:= {}
	aGrf3	:= {}
	aGrf4	:= {}

	// Adiciona Filtro Pto Controle
	If Trim(cPto) != ""
  		cFiltroPTO := cFiltro + " AND GX4.GX4_CDPTCT = '" + cPto + "'"
	EndIf

	// ####### GRAFICO AGENDAMENTOS com e sem agendamentos #######
	aADD(aGrf1, {"Mov. com Agendamento",	(cAlias1)->QTD_CAG})
	aADD(aGrf1, {"Mov. sem Agendamento",	(cAlias1)->QTD_SAG})


	// ####### GRAFICO MOVIMENTACOES Tipo veículo: séries contendo a quantidade de movimentações por tipo de veículo utilizado. #######
	cQuery := "SELECT		GV3.GV3_DSTPVC, "
	cQuery += "			COUNT(GX3.GX3_NRMOV) TOT"
	cQuery += "  FROM " + RetSQLName("GV3") + " GV3 "
	cQuery += " INNER JOIN " + RetSQLName("GU8") + " GU8	 ON GU8.GU8_CDTPVC = GV3.GV3_CDTPVC "
	cQuery += "  	 			  	  							AND GU8.D_E_L_E_T_ = '' "
	cQuery += "  LEFT JOIN " + RetSQLName("GX6") + " GX6	 ON GX6.GX6_CDVEIC = GU8.GU8_CDVEIC "
	cQuery += "  	 			  	  							AND GX6.D_E_L_E_T_ = '' "
	cQuery += "  LEFT JOIN " + RetSQLName("GX4") + " GX4	 ON GX4.GX4_FILIAL = GX6.GX6_FILIAL "
	cQuery += "												AND GX4.GX4_NRMOV  = GX6.GX6_NRMOV "
	cQuery += "  	 			  	  							AND GX4.D_E_L_E_T_ = '' "
	cQuery += "  LEFT JOIN " + RetSQLName("GX3") + " GX3	 ON GX3.GX3_FILIAL = GX4.GX4_FILIAL "
	cQuery += "												AND GX3.GX3_NRMOV  = GX4.GX4_NRMOV "
	cQuery += "  	 			  	  							AND GX3.D_E_L_E_T_ = '' "
	cQuery += cFiltroPTO
	cQuery += " GROUP BY GV3.GV3_DSTPVC "

	cTmp 	:= GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	If (cTmp)->(RecNo()) > 0
		While (cTmp)->(!Eof())

			aADD(aGrf2,{(cTmp)->GV3_DSTPVC, (cTmp)->TOT})

			(cTmp)->(dbSkip())
		EndDo
	EndIf
	(cTmp)->(dbCloseArea())

	// ####### GRAFICO MOV por OPERACOES: séries com a quantidade de movimentações por operação utilizada. #######
	cQuery := "SELECT	COUNT(DISTINCT GX4_NRMOV) QTD_MOV,"
	cQuery += "		GX3.GX3_CDOPER"
	cQuery += "  FROM " + RetSQLName("GX3") + " GX3 "
	cQuery += " INNER JOIN " + RetSQLName("GX4") + " GX4	 ON GX4.GX4_FILIAL = GX3.GX3_FILIAL"
	cQuery += "												AND GX4.GX4_NRMOV  = GX3.GX3_NRMOV"
	cQuery += cFiltroPTO
	cQuery += " GROUP BY GX3.GX3_CDOPER"


	cTmp 	:= GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	If (cTmp)->(RecNo()) > 0
		While (cTmp)->(!Eof())

			aADD(aGrf3, {(cTmp)->GX3_CDOPER, (cTmp)->QTD_MOV})

			(cTmp)->(dbSkip())
		EndDo
	EndIf
	(cTmp)->(dbCloseArea())
	
	// ####### TEMPO MEDIO OPERACOES: séries com o tempo médio de duração das movimentações em horas, por operação ####### 
 	cQuery := "SELECT	GX3.GX3_CDOPER,"
	cQuery += "		GX3.GX3_NRMOV,"
	cQuery += "		GX4.GX4_DTENTR,"
	cQuery += "		GX4.GX4_HRENTR,"
	cQuery += "		GX4.GX4_DTSAI,"
	cQuery += "		GX4.GX4_HRSAI"
	cQuery += "  FROM "+ RetSQLName("GX3") +" GX3"
	cQuery += " INNER JOIN "+ RetSQLName("GX4") +" GX4 ON GX4.GX4_FILIAL = GX3.GX3_FILIAL"
	cQuery += "                   	  					 AND GX4.GX4_NRMOV  = GX3.GX3_NRMOV" 
	cQuery += "					  						 AND GX4.GX4_SEQ    = '001'"  
	cQuery += cFiltroPTO 
	cQuery += " AND GX3.GX3_FILIAL >= '"+ cFil +"' AND GX3.GX3_FILIAL <= '"+ cFil +"'"
	cQuery += " ORDER BY GX3.GX3_CDOPER"

	cTmp 	:= GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	If (cTmp)->(RecNo()) > 0
	
		nInd	 := 0
		nTmpMed := 0
		cOper	 := ''
		While (cTmp)->( !Eof() )

			If cOper == ''
				cOper := AllTrim((cTmp)->GX3_CDOPER)
			EndIf
			
			dtEnt	:= (cTmp)->GX4_DTENTR
			hrEnt	:= (cTmp)->GX4_HRENTR
			dtSai	:= (cTmp)->GX4_DTSAI
			hrSai	:= (cTmp)->GX4_HRSAI

			nInd	 += 1
			nTmpMed += GFEC511ATM(StoD(dtEnt),StoD(dtSai),hrEnt,hrSai)			

			(cTmp)->(dbSkip())

			If cOper != AllTrim((cTmp)->GX3_CDOPER) .Or.(cTmp)->(Eof())
							
				aADD(aGrf4, {cOper, Val(AllTrim(Transform( nTmpMed / nInd ,'@E 99999.99'))) })

				// Inicializa
				nInd	 := 0
				nTmpMed := 0
				cOper	 := AllTrim((cTmp)->GX3_CDOPER)
			EndIf
			
					
		EndDo
		
		// Deixado como no mínimo 1 para apresentação, devido a invisibilidade do gráfico com menos de 1  
		If Len(aGrf4) == 1 .And. aGrf4[1][2] < 1
			aGrf4[1][2] := 1
		EndIf
		
	EndIf
	
	(cTmp)->(dbCloseArea())
	
Return Nil


Static Function MudaEstGrf(cFil, cPto)
	
	LoadEstat()
	LoadGraf(cFil, cPto)
	
	oGrid3:Disable()
	oGrid3:SetArray(aGrid3)
	oGrid3:UpdateBrowse()
	oGrid3:Enable()

	If lFirst == .T.
		// Atualiza Grafico
		GFEC001GRA(oGrf1,.T.,aGrf1)
		GFEC001GRA(oGrf2,.T.,aGrf2)
		GFEC001GRA(oGrf3,.T.,aGrf3)
		GFEC001GRA(oGrf4,.T.,aGrf4)
	EndIf
	dbSelectarea(cAlias1)
Return	


Function C514VMOV()

	dbSelectArea("GX3")
	GX3->(dbSetOrder(1))
	If GX3->(dbSeek((cAlias2)->( xFilial("GX3") + GX3_NRMOV )))
		FWExecView("Visualizar", "GFEC510", 1,, {||.T.})
	EndIf

Return Nil
