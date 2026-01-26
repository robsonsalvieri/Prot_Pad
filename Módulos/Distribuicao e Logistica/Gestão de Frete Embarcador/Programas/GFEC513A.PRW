#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
//-------------------------------------------------------------------
//Inclusão Pátios 12.1.4
//-----------------------------------
/*{Protheus.doc} GFEC513A
Movimentações Ponto de Controle/Operação

@author Felipe Machado de Oliveira
@version P12
@Since	15/04/2014
@param nParam1 = 1- Mov Ponto de Controle
                 2- Mov Ponto de Controle x Operação
       aParam2 = aParam2[1] - Ponto de Controle
                 aParam2[2] - Operação
                 aParam2[3] - Sequencia
@obs Movimentações Ponto de Controle
*/
//-----------------------------------
Function GFEC513A(nParam1,aParam2)
	Local aCoors := FWGetDialogSize(oMainWnd)
	Local oLayer, oPnlUp, oPnlDwnL, oPnlDwnR, oBrwUp, oBrwDwnLf
	Local oChart1, oChart2, oChart3, oChart4, oFolder
	Local aColsUp := {}
	Local aColsDownL := {}
	Local aFolders := {}
	
	Private oDlgMov
	Private cAliasTab3
	Private cAliasTab4
	
	DEFINE MSDIALOG oDlgMov TITLE "Movimentações do Ponto de Controle x Operações" FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] PIXEL
	oLayer := FWLayer():New()
	oLayer:Init(oDlgMov,.F.,.T.)
	oLayer:AddLine("UP",50,.T.)
	oLayer:AddLine("DOWN",50,.T.)
	oLayer:AddCollumn("LEFT",35,.F.,"DOWN")
	oLayer:AddCollumn("RIGHT",65,.F.,"DOWN")
	
	//-- Cria tabelas temporárias
	
	oPnlUp := oLayer:GetLinePanel("UP")
	oPnlDwnL := oLayer:GetColPanel("LEFT","DOWN")
	oPnlDwnR := oLayer:GetColPanel("RIGHT","DOWN")
	
	//-- Cria tabelas temporárias
	CriaTab()
	
	//-- WHERE
	cWhere := "   GX3.D_E_L_E_T_ = ' ' "
	If !Empty(xFilial("GX3"))
		cWhere += "AND GX3.GX3_FILIAL >= '"+MV_PAR01+"' "
		cWhere += "AND GX3.GX3_FILIAL <= '"+MV_PAR02+"' "
	EndIf
	cWhere += "   AND GX3.GX3_DTCRIA >= '"+DTOS(MV_PAR03)+"' "
	cWhere += "   AND GX3.GX3_DTCRIA <= '"+DTOS(MV_PAR04)+"' "
	If nParam1 = 2
		cWhere += "AND GX3.GX3_CDOPER = '"+aParam2[2]+"' "
		cWhere += "AND GX3.GX3_SEQ = '"+aParam2[3]+"' "
	Else
		cWhere += "AND GX3.GX3_CDOPER >= '"+MV_PAR05+"' "
		cWhere += "AND GX3.GX3_SEQ >= '"+MV_PAR06+"' "
		cWhere += "AND GX3.GX3_CDOPER <= '"+MV_PAR07+"' "
		cWhere += "AND GX3.GX3_SEQ <= '"+MV_PAR08+"' "
	EndIf
	If !Empty(MV_PAR09)
		cWhere += "AND GX3.GX3_CDEMIT = '"+MV_PAR09+"' "
	EndIf
	
	//-- Carregamento dos dados
	LoadTab(nParam1,aParam2,cWhere)
	
	aColsUp := {{ "Nr Movimentação"	,{|| (cAliasTab3)->X3_NR }		,"C","@!",1,TamSX3("GX3_NRMOV")[1],0,.F.,,,,,,,,1},;
				{ "Operação"			,{|| (cAliasTab3)->X3_OPER }	,"C","@!",1,TamSX3("GX3_CDOPER")[1],0,.F.,,,,,,,,1},;
				{ "Veículo"			,{|| (cAliasTab3)->X3_VEIC }	,"C","@!",1,20,0,.F.,,,,,,,,1},;
				{ "Motorista"			,{|| (cAliasTab3)->X3_MOTO }	,"C","@!",1,30,0,.F.,,,,,,,,1},;
				{ "Dt Entrada"		,{|| (cAliasTab3)->X3_DTENT }	,"D","",0,TamSX3("GX4_DTENTR")[1],0,.F.,,,,,,,,1},;
				{ "Hr Entrada"		,{|| (cAliasTab3)->X3_HRENT }	,"C","@R 99:99",0,TamSX3("GX4_HRENTR")[1],0,.F.,,,,,,,,1},;
				{ "Dt Saída"			,{|| (cAliasTab3)->X3_DTSAI }	,"D","",0,TamSX3("GX4_DTSAI")[1],0,.F.,,,,,,,,1},;
				{ "Hr Saída"			,{|| (cAliasTab3)->X3_HRSAI }	,"C","@R 99:99",0,TamSX3("GX4_HRSAI")[1],0,.F.,,,,,,,,1}}
	
	oBrwUp := FWMBrowse():New()
	oBrwUp:SetOwner(oPnlUp)
	oBrwUp:SetAlias(cAliasTab3)
	oBrwUp:SetFields(aColsUp)
	oBrwUp:SetDescription("Movimentações")
	oBrwUp:SetLocate()
	oBrwUp:DisableDetails()
	oBrwUp:DisableConfig()
	oBrwUp:ForceQuitButton()
	oBrwUp:SetAmbiente(.F.)
	oBrwUp:SetWalkthru(.F.)
	oBrwUp:SetProfileID("1") 
	oBrwUp:SetMenuDef("")
	oBrwUp:AddButton("Consultar Movimentação",{|| ConsMov() },,2)
	
	aColsDown := {{ "Descrição"	,{|| (cAliasTab4)->X4_DESCRI }	,"C","",1,25,0,.F.,,,,,,,,1},;
					{ "Valor"		,{|| (cAliasTab4)->X4_VALOR }	,"C","",1,TamSX3("GX4_CDPTCT")[1],0,.F.,,,,,,,,1}}
					
	oBrwDwnLf := FWMBrowse():New()
	oBrwDwnLf:SetOwner(oPnlDwnL)
	oBrwDwnLf:SetAlias(cAliasTab4)
	oBrwDwnLf:SetFields(aColsDown)
	oBrwDwnLf:SetDescription("Estatísticas")
	oBrwDwnLf:SetLocate()
	oBrwDwnLf:DisableDetails()
	oBrwDwnLf:DisableConfig()
	oBrwDwnLf:SetAmbiente(.F.)
	oBrwDwnLf:SetWalkthru(.F.)
	oBrwDwnLf:SetProfileID("1") 
	oBrwDwnLf:SetMenuDef("")
	
	aFolders := {"Qtd Tipo Veículo","Agendamentos"}
	If nParam1 == 1
		aAdd(aFolders,"Qtd Operação")
		aAdd(aFolders,"Tempo Médio Operação")
	EndIf
	oFolder := TFolder():New(0,0,aFolders,aFolders,oPnlDwnR,,,,.T.,,oPnlDwnR:NCLIENTWIDTH/2,oPnlDwnR:NCLIENTHEIGHT/2)
	
	oChart1 := FWChartPie():New()
	oChart1:Init( oFolder:aDialogs[1], .T. )
	DefChart(1,oChart1,cWhere,aParam2[1])
	oChart1:SetLegend( CONTROL_ALIGN_LEFT )
	oChart1:Build()
	
	oChart2 := FWChartPie():New()
	oChart2:Init( oFolder:aDialogs[2], .T. )
	DefChart(2,oChart2,cWhere,aParam2[1])
	oChart2:SetLegend( CONTROL_ALIGN_LEFT )
	oChart2:Build()
	
	If nParam1 == 1
		oChart3 := FWChartPie():New()
		oChart3:Init( oFolder:aDialogs[3], .T. )
		DefChart(3,oChart3,cWhere,aParam2[1])
		oChart3:SetLegend( CONTROL_ALIGN_LEFT )
		oChart3:Build()
		
		oChart4 := FWChartBar():New()
		oChart4:Init( oFolder:aDialogs[4], .T. )
		DefChart(4,oChart4,cWhere,aParam2[1])
		oChart4:SetLegend( CONTROL_ALIGN_LEFT )
		oChart4:SetPicture("@E 999,999.99") 
		oChart4:Build()
	EndIf
	
	oBrwUp:Activate()
	oBrwDwnLf:Activate()
	
	ACTIVATE MSDIALOG oDlgMov CENTER
	
	GFEDelTab(cAliasTab3)
	GFEDelTab(cAliasTab4)

Return


//-----------------------------------
/*{Protheus.doc}
Cria as tabelas temporarias das movimentações

@author Felipe Machado de Oliveira
@version P12
@Since	15/04/2014
@obs Cria as tabelas temporarias das movimentações
*/
//-----------------------------------
Static Function CriaTab()
	Local aFields := {}
	Local aIndices := {}
	Local nCont := 0
	Local aStruct := {}
	
	aFields := ;
		{{"Filial"				,"X3_FILIAL"	,"C",TamSX3("GX3_FILIAL")[1],0},;
		{"Nr Movimentação"	,"X3_NR"		,"C",TamSX3("GX3_NRMOV")[1],0},;
		{"Operação"			,"X3_OPER"		,"C",TamSX3("GX3_CDOPER")[1],0},;
		{"Veículo"				,"X3_VEIC"		,"C",200,0},;
		{"Motorista"			,"X3_MOTO"		,"C",200,0},;
		{"Dt Entrada"			,"X3_DTENT"	,"D",TamSX3("GX4_DTENTR")[1],0},;
		{"Hr"					,"X3_HRENT"	,"C",TamSX3("GX4_HRENTR")[1],0},;
		{"Dt Saída"			,"X3_DTSAI"	,"D",TamSX3("GX4_DTSAI")[1],0},;
		{"Hr"					,"X3_HRSAI"	,"C",TamSX3("GX4_HRSAI")[1],0}}
		
	aIndices := {"X3_FILIAL+X3_NR"}
		
	For nCont := 1 To Len(aFields)
		aADD(aStruct,{aFields[nCont][2],; //Nome do campo
						aFields[nCont][3],; //Tipo
						aFields[nCont][4],; //Tamanho
						aFields[nCont][5]}) //Decimal
	Next nCont
		
	cAliasTab3 := GFECriaTab({aStruct,aIndices})
	
	aFields := {;
		{"Codigo"		,"X4_CODEST"	,"C",2,0},;
		{"Descrição"	,"X4_DESCRI"	,"C",29,0},;
		{"Valor"		,"X4_VALOR"	,"C",TamSX3("GX4_CDPTCT")[1],0}}
	
	aIndices := {"X4_CODEST"}
		
	For nCont := 1 To Len(aFields)
		aADD(aStruct,{aFields[nCont][2],; //Nome do campo
						aFields[nCont][3],; //Tipo
						aFields[nCont][4],; //Tamanho
						aFields[nCont][5]}) //Decimal
	Next nCont
		
	cAliasTab4 := GFECriaTab({aStruct,aIndices})
Return

//-----------------------------------
/*{Protheus.doc}
Carrega as tabelas temporarias

@author Felipe Machado de Oliveira
@version P12
@Since	15/04/2014
@obs Carrega as tabelas temporarias
*/
//-----------------------------------
Static Function LoadTab(nPontOpe,aInfoMov,cWhere)
	Local cTmp 	:= GetNextAlias()
	Local cQuery 	:= ""
	Local nCont 	:= 0
	Local cPlaca	:= ""
	Local cDes		:= ""
	Local aStatistic := { "Ponto de Controle","Movimentações De","Movimentações Até","Qtd Movimentações","Com Agendamento","Sem Agendamento",;
							"Aprovados","Reprovados","Tempo Médio Atendimento (h)","Tempo Mínimo Atendimento (h)","Tempo Máximo Atendimento (h)","Qtd Veículos",;
							"Qtd Motoristas","Qtd Ocorrências","Qtd Reprovações"}
	
	// PONTOS DE CONTROLE
	cQuery := "SELECT GX3.GX3_FILIAL, "
	cQuery += "       GX3.GX3_NRMOV, "
	cQuery += "       GX3.GX3_CDOPER, "
	cQuery += "       GX4.GX4_DTENTR, "
	cQuery += "       GX4.GX4_HRENTR, "
	cQuery += "       GX4.GX4_DTSAI, "
	cQuery += "       GX4.GX4_HRSAI "
	cQuery += "  FROM "+RetSQLName("GX3")+" GX3 "
	cQuery += " INNER JOIN "+RetSQLName("GX4")+" GX4 "
	cQuery += "         ON GX3.GX3_NRMOV = GX4.GX4_NRMOV "
	cQuery += "        AND GX4.GX4_CDPTCT = '"+aInfoMov[1]+"' "
	cQuery += "        AND GX3.D_E_L_E_T_ = ' ' "
	If xFilial("GX3") == xFilial("GX4")
		cQuery += "     AND GX3.GX3_FILIAL = GX4.GX4_FILIAL "
	EndIf
	cQuery += " WHERE "
	cQuery += cWhere //-- WHERE
	cQuery += " GROUP BY GX3.GX3_FILIAL, "
	cQuery += "          GX3.GX3_NRMOV, "
	cQuery += "          GX3.GX3_CDOPER, "
	cQuery += "          GX4.GX4_DTENTR, "
	cQuery += "          GX4.GX4_HRENTR, "
	cQuery += "          GX4.GX4_DTSAI, "
	cQuery += "          GX4.GX4_HRSAI "
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	
	While (cTmp)->(!Eof())
		RecLock(cAliasTab3,.T.)
		(cAliasTab3)->X3_FILIAL	:= (cTmp)->GX3_FILIAL
		(cAliasTab3)->X3_NR		:= (cTmp)->GX3_NRMOV
		(cAliasTab3)->X3_OPER	:= (cTmp)->GX3_CDOPER

		// Busca Todos os Veículos
		cPlaca := ""
		cDes   := ""
		dbSelectArea("GX6")
		GX6->( dbSetOrder(1) )
		GX6->( dbSeek(xFilial("GX6") + (cTmp)->GX3_NRMOV) )
		While GX6->( !Eof() ) .And. xFilial("GX6") == (cTmp)->GX3_FILIAL .And. GX6->GX6_NRMOV == (cTmp)->GX3_NRMOV
			cPlaca := Posicione("GU8",1,xFilial("GU8")+GX6->GX6_CDVEIC,"GU8_PLACA")
			If Empty(cDes)
				cDes :=			Substr( AllTrim(cPlaca) ,1,3) +"-"+ Substr( AllTrim(cPlaca) ,4,4)
			Else
				cDes += " / " +	Substr( AllTrim(cPlaca) ,1,3) +"-"+ Substr( AllTrim(cPlaca) ,4,4)
			EndIf
			
			GX6->( dbSkip() )
		EndDo
		(cAliasTab3)->X3_VEIC := cDes
		
		// Busca Todos os Motoristas
		cDes := ""
		dbSelectArea("GX8")
		GX8->( dbSetOrder(1) )
		GX8->( dbSeek(xFilial("GX8") + (cTmp)->GX3_NRMOV) )
		While GX8->( !Eof() ) .And. xFilial("GX8") == (cTmp)->GX3_FILIAL .And. GX8->GX8_NRMOV == (cTmp)->GX3_NRMOV 
			If Empty(cDes)
				cDes :=			AllTrim(Posicione("GUU",1,xFilial("GUU")+GX8->GX8_CDMTR,"GUU_NMMTR"))
			Else
				cDes += " / " +	AllTrim(Posicione("GUU",1,xFilial("GUU")+GX8->GX8_CDMTR,"GUU_NMMTR"))
			EndIf
			
			GX8->( dbSkip() )
		EndDo
		(cAliasTab3)->X3_MOTO := cDes
				
		(cAliasTab3)->X3_DTENT	:= STOD((cTmp)->GX4_DTENTR)
		(cAliasTab3)->X3_HRENT	:= (cTmp)->GX4_HRENTR
		(cAliasTab3)->X3_DTSAI	:= STOD((cTmp)->GX4_DTSAI)
		(cAliasTab3)->X3_HRSAI	:= (cTmp)->GX4_HRSAI
		MsUnlock(cAliasTab3)
		(cTmp)->(dbSkip())
	EndDo
	
	(cTmp)->(dbCloseArea())


	// OPERAÇÕES
	cQuery := "SELECT COUNT( DISTINCT GX4.GX4_NRMOV ) QTDMOV, "
	cQuery += "       COUNT( CASE WHEN GWV.GWV_NRMOV IS NOT NULL THEN 1 END ) QTDCOMAG, "
	cQuery += "       COUNT( CASE WHEN GWV.GWV_NRMOV IS NULL THEN 1 END ) QTDSEMAG, "
	cQuery += "       COUNT( CASE WHEN GX4.GX4_SIT = '2' THEN 1 END ) QTDAPR, "
	cQuery += "       COUNT( CASE WHEN GX4.GX4_SIT = '3' THEN 1 END ) QTDREP, "
	cQuery += "       COUNT( CASE WHEN GX6.GX6_NRMOV IS NOT NULL THEN 1 END ) QTDVEIC, "
	cQuery += "       COUNT( CASE WHEN GX8.GX8_NRMOV IS NOT NULL THEN 1 END ) QTDMTR, "
	cQuery += "       COUNT( CASE WHEN GWD.GWD_NRMOV IS NOT NULL THEN 1 END ) QTDOCO, "
	cQuery += "       SUM( GX5.QTD ) QTDREPPERG "	
	
	cQuery += "  FROM "+RetSQLName("GX3")+" GX3 "  
	cQuery += " INNER JOIN "+RetSQLName("GX4")+" GX4  ON GX4.GX4_FILIAL = GX3.GX3_FILIAL "
	cQuery += "											AND GX4.GX4_NRMOV  = GX3.GX3_NRMOV "      
	cQuery += "											AND GX4.GX4_CDPTCT = '"+aInfoMov[1]+"' "
	cQuery += "											AND GX4.D_E_L_E_T_ = '' "
	cQuery += "  LEFT JOIN (SELECT DISTINCT GWV.GWV_FILIAL, GWV.GWV_NRMOV "
	cQuery += "			     FROM "+RetSQLName("GX3")+" GX3 "
	cQuery += "			    INNER JOIN "+RetSQLName("GWV")+" GWV ON GWV.GWV_FILIAL = GX3.GX3_FILIAL "
	cQuery += "											            AND GWV.GWV_NRMOV = GX3.GX3_NRMOV "
	cQuery += "			    WHERE GX3.D_E_L_E_T_ = '' "
	cQuery += "			      AND GWV.D_E_L_E_T_ = '') "
	cQuery += "				GWV ON GWV.GWV_FILIAL = GX3.GX3_FILIAL "
	cQuery += "				AND 	GWV.GWV_NRMOV  = GX3.GX3_NRMOV "
	
	cQuery += "  LEFT JOIN (SELECT DISTINCT GX6.GX6_FILIAL, GX6.GX6_NRMOV "
	cQuery += "			     FROM "+RetSQLName("GX3")+" GX3 "
	cQuery += "			    INNER JOIN "+RetSQLName("GX6")+" GX6 ON GX6.GX6_FILIAL = GX3.GX3_FILIAL "
	cQuery += "											            AND GX6.GX6_NRMOV = GX3.GX3_NRMOV "
	cQuery += "			    WHERE GX3.D_E_L_E_T_ = '' "
	cQuery += "			      AND GX6.D_E_L_E_T_ = '') "
	cQuery += "				GX6 ON GX6.GX6_FILIAL = GX3.GX3_FILIAL "
	cQuery += "				AND 	GX6.GX6_NRMOV  = GX3.GX3_NRMOV "

	cQuery += "  LEFT JOIN (SELECT DISTINCT GX8.GX8_FILIAL, GX8.GX8_NRMOV "
	cQuery += "			     FROM "+RetSQLName("GX3")+" GX3 "
	cQuery += "			    INNER JOIN "+RetSQLName("GX8")+" GX8 ON GX8.GX8_FILIAL = GX3.GX3_FILIAL "
	cQuery += "											            AND GX8.GX8_NRMOV = GX3.GX3_NRMOV "
	cQuery += "			    WHERE GX3.D_E_L_E_T_ = '' "
	cQuery += "			      AND GX8.D_E_L_E_T_ = '') "
	cQuery += "				GX8 ON GX8.GX8_FILIAL = GX3.GX3_FILIAL "
	cQuery += "				AND 	GX8.GX8_NRMOV  = GX3.GX3_NRMOV "

	cQuery += "  LEFT JOIN (SELECT DISTINCT GWD.GWD_FILIAL, GWD.GWD_NRMOV "
	cQuery += "			     FROM "+RetSQLName("GX3")+" GX3 "
	cQuery += "			    INNER JOIN "+RetSQLName("GWD")+" GWD ON GWD.GWD_FILIAL = GX3.GX3_FILIAL "
	cQuery += "											            AND GWD.GWD_NRMOV = GX3.GX3_NRMOV "
	cQuery += "			    WHERE GX3.D_E_L_E_T_ = '' "
	cQuery += "			      AND GWD.D_E_L_E_T_ = '') "
	cQuery += "				GWD ON GWD.GWD_FILIAL = GX3.GX3_FILIAL "
	cQuery += "				AND 	GWD.GWD_NRMOV  = GX3.GX3_NRMOV "

	cQuery += "  LEFT JOIN (SELECT GX5.GX5_FILIAL, GX5.GX5_NRMOV , GX5.GX5_CDPTCT, COUNT(*) QTD "
	cQuery += "			     FROM "+RetSQLName("GX3")+" GX3 "
	cQuery += "			    INNER JOIN "+RetSQLName("GX5")+" GX5 ON GX5.GX5_FILIAL = GX3.GX3_FILIAL "
	cQuery += "											            AND GX5.GX5_NRMOV = GX3.GX3_NRMOV "
	cQuery += "			    WHERE GX3.D_E_L_E_T_ = '' "
	cQuery += "			      AND GX5.D_E_L_E_T_ = '' "
	cQuery += "			      AND GX5.GX5_RESPOS = '2' "
	cQuery += "			    GROUP BY GX5.GX5_FILIAL, GX5.GX5_NRMOV , GX5.GX5_CDPTCT )"
	cQuery += "				GX5 ON GX5.GX5_FILIAL = GX3.GX3_FILIAL "
	cQuery += "				AND 	GX5.GX5_NRMOV  = GX3.GX3_NRMOV "
	cQuery += "				AND 	GX5.GX5_CDPTCT = GX4.GX4_CDPTCT "	

	cQuery += " WHERE " + cWhere //-- WHERE
	cQuery += " GROUP BY GX4.GX4_CDPTCT "

	cQuery := ChangeQuery(cQuery)
	cTmp := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	
	For nCont := 1 To Len(aStatistic)
		RecLock(cAliasTab4,.T.)
		(cAliasTab4)->X4_CODEST := str(nCont)
		(cAliasTab4)->X4_DESCRI := aStatistic[nCont]
		If nCont == 1
			(cAliasTab4)->X4_VALOR := aInfoMov[1]
		ElseIf nCont == 2
			(cAliasTab4)->X4_VALOR := DTOC(MV_PAR03)
		ElseIf nCont == 3
			(cAliasTab4)->X4_VALOR := DTOC(MV_PAR04)
		ElseIf nCont > 3 .And. nCont < 9
			(cAliasTab4)->X4_VALOR := AllTrim(str((cTmp)->(FieldGet(nCont - 3))))
		ElseIf nCont > 8 .And. nCont < 12 //1-Medio 2-Minimo 3-Maximo
			(cAliasTab4)->X4_VALOR := AllTrim(str(NoRound(GFEC513TMP(nPontOpe,aInfoMov[1],aInfoMov[2],aInfoMov[3],nCont - 8))))
		ElseIf nCont > 11 .And. nCont < 15
			(cAliasTab4)->X4_VALOR := AllTrim(str((cTmp)->(FieldGet(nCont - 6))))
		ElseIf nCont == 15
			(cAliasTab4)->X4_VALOR := AllTrim(str((cTmp)->(QTDREP)))
		EndIf
		MsUnlock(cAliasTab4)
	Next
	
	(cTmp)->(dbCloseArea())

Return


//-----------------------------------
/*{Protheus.doc}
Define as Series dos Graficos

@author Felipe Machado de Oliveira
@version P12
@Since	15/04/2014
@obs Define as Series dos Graficos
*/
//-----------------------------------
Static Function DefChart(nGrafico,oChart,cWhere,cOper)
	Local cQuery := ""
	Local cTmp
	
	If nGrafico == 1
		cQuery := " SELECT GV3.GV3_CDTPVC CDTPVC, "
		cQuery += "        COUNT(GX3.GX3_NRMOV) QTDMOV "
		cQuery += "   FROM "+RetSqlName("GX3")+" GX3 "
		cQuery += "  INNER JOIN "+RetSqlName("GX4")+" GX4 "
		cQuery += "          ON GX4.GX4_CDPTCT = '"+cOper+"' "
		cQuery += "         AND GX4.GX4_NRMOV = GX3.GX3_NRMOV "
		cQuery += "         AND GX4.D_E_L_E_T_ = ' ' "
		If xFilial("GX3") == xFilial("GX4")
			cQuery += "      AND GX4.GX4_FILIAL = GX3.GX3_FILIAL "
		EndIf
		cQuery += "  INNER JOIN "+RetSqlName("GX6")+" GX6 "
		cQuery += "          ON GX6.GX6_NRMOV = GX3.GX3_NRMOV "
		cQuery += "         AND GX6.D_E_L_E_T_ = ' ' "
		If xFilial("GX6") == xFilial("GX3")
			cQuery += "      AND GX6.GX6_FILIAL = GX3.GX3_FILIAL "
		EndIf
		cQuery += "  INNER JOIN "+RetSqlName("GU8")+" GU8 "
		cQuery += "          ON GU8.GU8_CDVEIC = GX6.GX6_CDVEIC "
		cQuery += "         AND GU8.D_E_L_E_T_ = ' ' "
		If xFilial("GU8") == xFilial("GX6")
			cQuery += "      AND GU8.GU8_FILIAL = GX6.GX6_FILIAL "
		EndIf
		cQuery += "  INNER JOIN "+RetSqlName("GV3")+" GV3 "
		cQuery += "          ON GV3.GV3_CDTPVC = GU8.GU8_CDTPVC "
		cQuery += "         AND GV3.D_E_L_E_T_ = ' ' "
		If xFilial("GV3") == xFilial("GU8")
			cQuery += "      AND GV3.GV3_FILIAL = GU8.GU8_FILIAL "
		EndIf
		cQuery += "  WHERE "
		cQuery += cWhere //-- WHERE
		cQuery += "  GROUP BY GV3.GV3_CDTPVC "
		cQuery += "  UNION ALL "
		cQuery += " SELECT 'MOV SEM VEÍCULO', "
		cQuery += "        COUNT(GX3.GX3_NRMOV) QTDMOV "
		cQuery += "   FROM "+RetSqlName("GX3")+" GX3 "
		cQuery += "  INNER JOIN "+RetSqlName("GX4")+" GX4 "
		cQuery += "          ON GX4.GX4_CDPTCT = '"+cOper+"' "
		cQuery += "         AND GX4.GX4_NRMOV = GX3.GX3_NRMOV "
		cQuery += "         AND GX4.D_E_L_E_T_ = ' ' "
		If xFilial("GX3") == xFilial("GX4")
			cQuery += "      AND GX4.GX4_FILIAL = GX3.GX3_FILIAL "
		EndIf
		cQuery += "   LEFT JOIN "+RetSqlName("GX6")+" GX6 "
		cQuery += "          ON GX6.GX6_NRMOV = GX3.GX3_NRMOV "
		cQuery += "         AND GX6.D_E_L_E_T_ = ' ' "
		If xFilial("GX6") == xFilial("GX3")
			cQuery += "      AND GX6.GX6_FILIAL = GX3.GX3_FILIAL "
		EndIf
		cQuery += "  WHERE "
		cQuery += cWhere //-- WHERE
		cQuery += "    AND GX6.GX6_CDVEIC IS NULL "
		cQuery += " HAVING COUNT(GX3.GX3_NRMOV) <> 0 "
		cQuery := ChangeQuery(cQuery)
		
		cTmp := GetNextAlias()
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
		dbSelectArea(cTmp)
		(cTmp)->(dbGoTop())
		
		While (cTmp)->(!Eof())
			oChart:AddSerie( (cTmp)->(CDTPVC), (cTmp)->(QTDMOV) )
			(cTmp)->(dbSkip())
		EndDo
		
		(cTmp)->(dbCloseArea())
		
	ElseIf nGrafico == 2
		cQuery := "SELECT COUNT( CASE WHEN GWV.GWV_NRMOV IS NOT NULL THEN 1 END ) QTDCOMAG, "
		cQuery += "       COUNT( CASE WHEN GWV.GWV_NRMOV IS NULL THEN 1 END ) QTDSEMAG "
		cQuery += "  FROM "+RetSQLName("GX3")+" GX3 "
		cQuery += " INNER JOIN "+RetSQLName("GX4")+" GX4 "
		cQuery += "         ON GX3.GX3_NRMOV = GX4.GX4_NRMOV "
		cQuery += "        AND GX4.GX4_CDPTCT = '"+cOper+"' "
		cQuery += "        AND GX4.D_E_L_E_T_ = ' ' "
		If xFilial("GX3") == xFilial("GX4")
			cQuery += "     AND GX3.GX3_FILIAL = GX4.GX4_FILIAL "
		EndIf
		cQuery += "  LEFT JOIN (SELECT DISTINCT GWV_FILIAL, GWV_NRMOV "
		cQuery += "               FROM "+RetSQLName("GX3")+" GX3 "
		cQuery += "              INNER JOIN "+RetSQLName("GWV")+" GWV "
		cQuery += "                      ON GX3_NRMOV = GWV_NRMOV "
		If xFilial("GX3") == xFilial("GWV")
			cQuery += "                  AND GX3_FILIAL = GWV_FILIAL "
		EndIf
		cQuery += "              WHERE GX3.D_E_L_E_T_ = '' "
		cQuery += "                AND GWV.D_E_L_E_T_ = '') GWV "
		cQuery += "         ON GWV.GWV_NRMOV = GX3.GX3_NRMOV "
		If xFilial("GWV") == xFilial("GX3")
			cQuery += "     AND GWV.GWV_FILIAL = GX3.GX3_FILIAL "
		EndIf
		cQuery += " WHERE "
		cQuery += cWhere //-- WHERE
		cQuery += " GROUP BY GX4.GX4_CDPTCT "
		cQuery := ChangeQuery(cQuery)
	
		cTmp := GetNextAlias()
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
		dbSelectArea(cTmp)
		(cTmp)->(dbGoTop())
		
		oChart:AddSerie( "Com Agendamento", (cTmp)->(QTDCOMAG))
		oChart:AddSerie( "Sem Agendamento", (cTmp)->(QTDSEMAG))
		
		(cTmp)->(dbCloseArea())
	
	ElseIf nGrafico == 3
		cQuery := "SELECT GVI.GVI_DSCONF, "
		cQuery += "       COUNT( GX3.GX3_SEQ ) QTDOPE "
		cQuery += "  FROM "+RetSQLName("GX3")+" GX3 "
		cQuery += " INNER JOIN "+RetSQLName("GX4")+" GX4 "
		cQuery += "    ON GX3.GX3_NRMOV = GX4.GX4_NRMOV "
		cQuery += "   AND GX4.GX4_CDPTCT = '"+cOper+"' "
		cQuery += "   AND GX4.D_E_L_E_T_ = ' ' "
		If xFilial("GX3") == xFilial("GX4")
			cQuery += "AND GX3.GX3_FILIAL = GX4.GX4_FILIAL "
		EndIf
		cQuery += " INNER JOIN "+RetSQLName("GVI")+" GVI "
		cQuery += "    ON GVI.GVI_CDOPER = GX3.GX3_CDOPER "
		cQuery += "   AND GVI.GVI_SEQ = GX3.GX3_SEQ "
		cQuery += "   AND GVI.D_E_L_E_T_ = ' ' "
		If xFilial("GVI") == xFilial("GX3")
			cQuery += "AND GVI.GVI_FILIAL = GX3.GX3_FILIAL "
		EndIf
		cQuery += " WHERE "
		cQuery += cWhere //-- WHERE
		cQuery += " GROUP BY GVI.GVI_DSCONF, "
		cQuery += "          GX4.GX4_CDPTCT "
		cQuery := ChangeQuery(cQuery)
		
		cTmp := GetNextAlias()
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
		dbSelectArea(cTmp)
		(cTmp)->(dbGoTop())
		
		While (cTmp)->(!Eof())
			oChart:AddSerie( (cTmp)->(GVI_DSCONF), (cTmp)->(QTDOPE) )
			(cTmp)->(dbSkip())
		EndDo
		
		(cTmp)->(dbCloseArea())
	
	ElseIf nGrafico == 4
		cQuery := " SELECT GX3.GX3_CDOPER, "
		cQuery += "        GVI.GVI_DSCONF, "
		cQuery += "        GX3.GX3_SEQ "
		cQuery += "   FROM "+RetSQLName("GX3")+" GX3 " 
		cQuery += "  INNER JOIN "+RetSQLName("GX4")+" GX4 "
		cQuery += "     ON GX3.GX3_NRMOV = GX4.GX4_NRMOV "
		cQuery += "    AND GX4.GX4_CDPTCT = '"+cOper+"' "
		cQuery += "    AND GX4.D_E_L_E_T_ = ' ' "
		cQuery += "  INNER JOIN "+RetSQLName("GVI")+" GVI "
		cQuery += "     ON GVI.GVI_CDOPER = GX3.GX3_CDOPER "
		cQuery += "    AND GVI.GVI_SEQ = GX3.GX3_SEQ "
		cQuery += "    AND GVI.D_E_L_E_T_ = ' ' "
		If xFilial("GVI") == xFilial("GX3") 
			cQuery += " AND GVI.GVI_FILIAL = GX3.GX3_FILIAL "
		EndIf 
		If xFilial("GX3") == xFilial("GX4")
			cQuery += " AND GX3.GX3_FILIAL = GX4.GX4_FILIAL "
		EndIf
		cQuery += "  WHERE "
		cQuery += cWhere //-- WHERE
		cQuery += "  GROUP BY GX3.GX3_CDOPER, "
		cQuery += "           GVI.GVI_DSCONF, "
		cQuery += "           GX3.GX3_SEQ, "
		cQuery += "           GX4.GX4_CDPTCT "
		cQuery := ChangeQuery(cQuery)
		
		cTmp := GetNextAlias()
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
		dbSelectArea(cTmp)
		(cTmp)->(dbGoTop())
		
		While (cTmp)->(!Eof())
			oChart:AddSerie( (cTmp)->(GVI_DSCONF), Round(GFEC513TMP(2,cOper,(cTmp)->(GX3_CDOPER),(cTmp)->(GX3_SEQ),1),2) )
			(cTmp)->(dbSkip())
		EndDo
		
		(cTmp)->(dbCloseArea())
	EndIf

Return Nil


//-----------------------------------
/*{Protheus.doc}
Consulta da Movimentação

@author Felipe Machado de Oliveira
@version P12
@Since	15/04/2014
@obs Consulta da Movimentação
*/
//-----------------------------------
Static Function ConsMov()
	Local aAreaTab3 := (cAliasTab3)->(GetArea())
	Local aAreaTab4 := (cAliasTab4)->(GetArea())
	
	dbSelectArea("GX3")
	GX3->(dbSetOrder(1))
	GX3->(dbSeek((cAliasTab3)->X3_FILIAL+(cAliasTab3)->X3_NR))
	
	FWExecView("Visualizar","GFEC510",MODEL_OPERATION_VIEW,,{||.T.})
	
	RestArea(aAreaTab4)
	RestArea(aAreaTab3)
Return
 