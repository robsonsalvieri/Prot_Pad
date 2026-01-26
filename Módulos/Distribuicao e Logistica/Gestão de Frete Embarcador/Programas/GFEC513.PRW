#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
//-------------------------------------------------------------------
//Inclusão Pátios 12.1.4
//-----------------------------------
/*{Protheus.doc} GFEC513
Movimentações do Pátio

@author Felipe Machado de Oliveira
@version P12
@Since	15/04/2014
@obs Movimentações do Pátio
*/
//-----------------------------------
Function GFEC513()
	Local aCoors := FWGetDialogSize(oMainWnd)
	Local oLayer, oPanelUp, oPanelDwn, oRel
	Local aColsUp := {}
	Local aColsDown := {}
	
	Private oDlgPatio
	Private cAliasTab1
	Private cAliasTab2
	Private oBrwUp, oBrwDwn
	
	If Pergunte("GFEC513")
	
		DEFINE MSDIALOG oDlgPatio TITLE "Movimentações do Pátio" FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] PIXEL
		oLayer := FWLayer():New()
		oLayer:Init(oDlgPatio,.F.,.T.)
		oLayer:AddLine("UP",50,.T.)
		oLayer:AddLine("DOWN",50,.T.)
		
		//-- Cria tabelas temporárias
		CriaTab()
		LoadTab()
	
		oPanelUp := oLayer:GetLinePanel("UP")
		oPanelDwn := oLayer:GetLinePanel("DOWN")
		
		aColsUp := {;
						{ "Filial"							,{|| (cAliasTab1)->X1_FILIAL }	,"C","@!",1,TamSX3("GX4_FILIAL")[1],0,.F.,,,,,,,,1},;
						{ "Ponto de Controle"			,{|| (cAliasTab1)->X1_PONTO }	,"C","@!",1,TamSX3("GX4_CDPTCT")[1],0,.F.,,,,,,,,1},;
						{ "Qtd Movimentações"			,{|| (cAliasTab1)->X1_QTDMOV }	,"N","",2,4,0,.F.,,,,,,,,1},;
						{ "Com Agendamento"				,{|| (cAliasTab1)->X1_COMAGE }	,"N","",2,4,0,.F.,,,,,,,,1},;
						{ "Sem Agendamento"				,{|| (cAliasTab1)->X1_SEMAGE }	,"N","",2,4,0,.F.,,,,,,,,1},;
						{ "Aprovadas"						,{|| (cAliasTab1)->X1_APROV }	,"N","",2,4,0,.F.,,,,,,,,1},;
						{ "Reprovadas"					,{|| (cAliasTab1)->X1_REPRO }	,"N","",2,4,0,.F.,,,,,,,,1},;
						{ "Tempo Médio Atendimento (h)"	,{|| (cAliasTab1)->X1_TEMPATE }	,"N","@E 99,999,999,999,999.99",2,5,3,.F.,,,,,,,,1};
						}
		
		oBrwUp := FWMBrowse():New()
		oBrwUp:SetOwner(oPanelUp)
		oBrwUp:SetAlias(cAliasTab1)
		oBrwUp:SetFields(aColsUp)
		oBrwUp:SetDescription("Pontos de Controle")
		oBrwUp:SetLocate()
		oBrwUp:ForceQuitButton()
		oBrwUp:DisableDetails()
		oBrwUp:DisableConfig()
		oBrwUp:SetAmbiente(.F.)
		oBrwUp:SetWalkthru(.F.)
		oBrwUp:SetProfileID("1")
		oBrwUp:SetMenuDef("GFEC513")
		
		aColsDown := {;
						{ "Operação"						,{|| (cAliasTab2)->X2_CDOPER }	,"C","@!",1,TamSX3("GX3_CDOPER")[1],0,.F.,,,,,,,,1},;
						{ "Sequencia"						,{|| (cAliasTab2)->X2_SEQ }		,"C","@!",1,TamSX3("GX3_SEQ")[1],0,.F.,,,,,,,,1},;
						{ "Desc Config"					,{|| (cAliasTab2)->X2_DSCONF }	,"C","@!",1,TamSX3("GVI_DSCONF")[1],0,.F.,,,,,,,,1},;
						{ "Qtd Movimentações"			,{|| (cAliasTab2)->X2_QTDOPE }	,"N","",2,4,0,.F.,,,,,,,,1},;
						{ "Qtd Reprovações"				,{|| (cAliasTab2)->X2_QTDREP }	,"N","",2,4,0,.F.,,,,,,,,1},;
						{ "Tempo Médio Atendimento (h)"	,{|| (cAliasTab2)->X2_TEMPATE }	,"N","@E 99,999,999,999,999.99",2,5,3,.F.,,,,,,,,1};
						}
						
		oBrwDwn := FWMBrowse():New()
		oBrwDwn:SetOwner(oPanelDwn)
		oBrwDwn:SetAlias(cAliasTab2)
		oBrwDwn:SetFields(aColsDown)
		oBrwDwn:SetDescription("Operações")
		oBrwDwn:SetLocate()
		oBrwDwn:DisableDetails()
		oBrwDwn:DisableConfig()
		oBrwDwn:SetAmbiente(.F.)
		oBrwDwn:SetWalkthru(.F.)
		oBrwDwn:SetProfileID("1") 
		oBrwDwn:SetMenuDef("")
		oBrwDwn:AddButton("Movimentações",{|| GFEC513MEN(2)  },,2)
		
		oBrwUp:Activate()
		oBrwDwn:Activate()
		
		oRel := FWBrwRelation():New()
		oRel:AddRelation(oBrwUp,oBrwDwn,{ {"X2_FILIAL","X1_FILIAL"},{"X2_CDPTCT","X1_PONTO"} })
		oRel:Activate()
		
		ACTIVATE MSDIALOG oDlgPatio CENTER
		
		GFEDelTab(cAliasTab1)
		GFEDelTab(cAliasTab2)
	EndIf

Return
//-----------------------------------
/*{Protheus.doc}
Menu

@author Felipe Machado de Oliveira
@version P12
@Since	15/04/2014
@obs Movimentações do Pátio
*/
//-----------------------------------
Function GFEC513MEN(nOpcao)
	Local aAreaTab1 := (cAliasTab1)->(GetArea())
	Local aAreaTab2 := (cAliasTab2)->(GetArea())
	
	GFEC513A(nOpcao,{(cAliasTab1)->X1_PONTO,(cAliasTab2)->X2_CDOPER,(cAliasTab2)->X2_SEQ})
	
	RestArea(aAReaTab1)
	RestArea(aAReaTab2)
	
Return


//-----------------------------------
/*{Protheus.doc}
Cria as tabelas temporarias dos pontos de controle

@author Felipe Machado de Oliveira
@version P12
@Since	15/04/2014
@obs Cria a tabela temporaria dos pontos de controle
*/
//-----------------------------------
Static Function CriaTab()
	Local aFields 	:= {}
	Local aIndices 	:= {}
	Local nCont 		:= 0
	Local aStruct 	:= {}
	
	aFields := ;
		{{"Filial"					,"X1_FILIAL"	,"C",TamSX3("GX4_FILIAL")[1],0},;
		{"Ponto de Controle"		,"X1_PONTO"	,"C",TamSX3("GX4_CDPTCT")[1],0},;
		{"Qtd Movimentações"		,"X1_QTDMOV"	,"N",4,0},;
		{"Com Agendamento"			,"X1_COMAGE"	,"N",4,0},;
		{"Sem Agendamento"			,"X1_SEMAGE"	,"N",4,0},;
		{"Aprovadas"				,"X1_APROV"	,"N",4,0},;
		{"Reprovadas"				,"X1_REPRO"	,"N",4,0},;
		{"Tempo Médio Atendimento"	,"X1_TEMPATE"	,"N",14,2}}
		
	aIndices := {"X1_FILIAL+X1_PONTO"}
		
	For nCont := 1 To Len(aFields)
		aADD(aStruct,{aFields[nCont][2],; //Nome do campo
						aFields[nCont][3],; //Tipo
						aFields[nCont][4],; //Tamanho
						aFields[nCont][5]}) //Decimal
	Next nCont
		
	cAliasTab1 := GFECriaTab({aStruct,aIndices})
	
	
	aFields := ;
		{{"Filial"					,"X2_FILIAL"	,"C",TamSX3("GX3_FILIAL")[1],0},;
		{"Ponto de Controle"		,"X2_CDPTCT"	,"C",TamSX3("GX4_CDPTCT")[1],0},;
		{"Operação"					,"X2_CDOPER"	,"C",TamSX3("GX3_CDOPER")[1],0},;
		{"Sequencia"				,"X2_SEQ"		,"C",TamSX3("GX3_SEQ")[1],0},;
		{"Desc Config"				,"X2_DSCONF"	,"C",TamSX3("GVI_DSCONF")[1],0},;
		{"Qtd Movimentações"		,"X2_QTDOPE"	,"N",4,0},;
		{"Qtd Reprovações"			,"X2_QTDREP"	,"N",4,0},;
		{"Tempo Médio Atendimento"	,"X2_TEMPATE"	,"N",14,2};
		}
		
	aIndices := {"X2_FILIAL+X2_CDPTCT+X2_CDOPER+X2_SEQ"}
	
	aStruct := {}
	
	For nCont := 1 To Len(aFields)
		aADD(aStruct,{aFields[nCont][2],; //Nome do campo
						aFields[nCont][3],; //Tipo
						aFields[nCont][4],; //Tamanho
						aFields[nCont][5]}) //Decimal
	Next nCont
		
	cAliasTab2 := GFECriaTab({aStruct,aIndices})

Return


//-----------------------------------
/*{Protheus.doc}
Carrega as tabelas temporarias dos pontos de controle

@author Felipe Machado de Oliveira
@version P12
@Since	15/04/2014
@obs Carrega as tabelas temporarias dos pontos de controle
*/
//-----------------------------------
Static Function LoadTab()
	Local cTmp := GetNextAlias()
	Local cQuery := ""
	Local cWhere := ""
	
	cWhere := "    GX3.D_E_L_E_T_ = ' ' "
	cWhere += "    AND GX3.GX3_DTCRIA >= '"+DTOS(MV_PAR03)+"' "
	cWhere += "    AND GX3.GX3_DTCRIA <= '"+DTOS(MV_PAR04)+"' "
	cWhere += "    AND GX3.GX3_CDOPER >= '"+MV_PAR05+"' "
	cWhere += "    AND GX3.GX3_SEQ >= '"+MV_PAR06+"' "
	cWhere += "    AND GX3.GX3_CDOPER <= '"+MV_PAR07+"' "
	cWhere += "    AND GX3.GX3_SEQ <= '"+MV_PAR08+"' "
	If !Empty(xFilial("GX3"))
		cWhere += " AND GX3.GX3_FILIAL >= '"+MV_PAR01+"' "
		cWhere += " AND GX3.GX3_FILIAL <= '"+MV_PAR02+"' "
	EndIf
	If !Empty(MV_PAR09)
		cWhere += " AND GX3.GX3_CDEMIT = '"+MV_PAR09+"' "
	EndIf
	
	dbSelectArea(cAliasTab1)
	(cAliasTab1)->(dbSetOrder(1))
	ZAP
	
	cQuery := "SELECT GX3.GX3_FILIAL, "
	cQuery += "       GX4.GX4_CDPTCT, "
	cQuery += "       COUNT( DISTINCT GX4.GX4_NRMOV ) QTDMOV, "
	cQuery += "       COUNT( CASE WHEN GX4.GX4_SIT = '2' THEN 1 END ) QTDAPR, "
	cQuery += "       COUNT( CASE WHEN GX4.GX4_SIT = '3' THEN 1 END ) QTDREP, "
	cQuery += "       COUNT( DISTINCT GWV.GWV_NRMOV ) QTDCOMAG "
	cQuery += "  FROM "+RetSQLName("GX3")+" GX3 "
	cQuery += " INNER JOIN "+RetSQLName("GX4")+" GX4 "
	cQuery += "         ON GX4.GX4_NRMOV = GX3.GX3_NRMOV "
	cQuery += "        AND GX4.D_E_L_E_T_ = ' ' "
	If xFilial("GX4") == xFilial("GX3")
		cQuery += "     AND GX4.GX4_FILIAL = GX3.GX3_FILIAL "
	EndIf
	cQuery += "  LEFT JOIN (SELECT DISTINCT GWV_FILIAL, GWV_NRMOV "
	cQuery += "               FROM "+RetSQLName("GX3")+" GX3 "
	cQuery += "              INNER JOIN "+RetSQLName("GWV")+" GWV "
	cQuery += "                      ON GX3_NRMOV = GWV_NRMOV "
	If xFilial("GX3") == xFilial("GWV")
		cQuery += "                  AND GX3_FILIAL = GWV_FILIAL "
	EndIf
	cQuery += "              WHERE "
	cQuery += cWhere //-- WHERE
	cQuery += "                AND GWV.D_E_L_E_T_ = '') GWV "
	cQuery += "         ON GWV.GWV_NRMOV = GX3.GX3_NRMOV "
	If xFilial("GWV") == xFilial("GX3")
		cQuery += "     AND GWV.GWV_FILIAL = GX3.GX3_FILIAL "
	EndIf
	cQuery += " WHERE "
	cQuery += cWhere //-- WHERE
	cQuery += "  GROUP BY GX3.GX3_FILIAL, "
	cQuery += "           GX4.GX4_CDPTCT "
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	
	While (cTmp)->(!Eof())
		RecLock(cAliasTab1,.T.)
		(cAliasTab1)->X1_FILIAL	:= (cTmp)->GX3_FILIAL
		(cAliasTab1)->X1_PONTO	:= (cTmp)->GX4_CDPTCT
		(cAliasTab1)->X1_QTDMOV	:= (cTmp)->QTDMOV
		(cAliasTab1)->X1_COMAGE	:= (cTmp)->QTDCOMAG
		(cAliasTab1)->X1_SEMAGE	:= (cTmp)->QTDMOV - (cTmp)->QTDCOMAG
		(cAliasTab1)->X1_APROV	:= (cTmp)->QTDAPR
		(cAliasTab1)->X1_REPRO	:= (cTmp)->QTDREP
		(cAliasTab1)->X1_TEMPATE	:= GFEC513TMP(1,(cTmp)->GX4_CDPTCT)
		MsUnlock(cAliasTab1)
		(cTmp)->(dbSkip())
	EndDo
	
	(cTmp)->(dbCloseArea())
	
	dbSelectArea(cAliasTab2)
	(cAliasTab2)->(dbSetOrder(1))
	ZAP
	
	cQuery := "SELECT GX3.GX3_FILIAL, "
	cQuery += "       GX4.GX4_CDPTCT, "
	cQuery += "       GX3.GX3_CDOPER, "
	cQuery += "       GX3.GX3_SEQ, "
	cQuery += "       GVI.GVI_DSCONF, "
	cQuery += "       COUNT( DISTINCT GX3_NRMOV ) QTDOPE, "
	cQuery += "       COUNT( CASE WHEN GX4.GX4_SIT = '3' THEN 1 END ) QTDREP "
	cQuery += "  FROM "+RetSQLName("GX3")+" GX3 "
	cQuery += " INNER JOIN "+RetSQLName("GX4")+" GX4 "
	cQuery += "         ON GX3.GX3_NRMOV = GX4.GX4_NRMOV "
	cQuery += "        AND GX3.D_E_L_E_T_ = ' ' "
	If xFilial("GX3") == xFilial("GX4")
		cQuery += "     AND GX3.GX3_FILIAL = GX4.GX4_FILIAL "
	EndIf
	cQuery += " INNER JOIN "+RetSQLName("GVI")+" GVI "
	cQuery += "         ON GX3.GX3_CDOPER = GVI.GVI_CDOPER "
	cQuery += "        AND GX3.GX3_SEQ = GVI.GVI_SEQ "
	cQuery += "        AND GVI.D_E_L_E_T_ = ' ' "
	If xFilial("GVI") == xFilial("GX3")
		cQuery += "     AND GVI.GVI_FILIAL = GX3.GX3_FILIAL "
	EndIf
	cQuery += " WHERE "
	cQuery += cWhere //-- WHERE
	cQuery += " GROUP BY GX3.GX3_FILIAL, "
	cQuery += "          GX3.GX3_CDOPER, "
	cQuery += "          GX3.GX3_SEQ, "
	cQuery += "          GVI.GVI_DSCONF, "
	cQuery += "          GX4.GX4_CDPTCT "
	cQuery := ChangeQuery(cQuery)
	
	cTmp := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	
	While (cTmp)->(!Eof())
		RecLock(cAliasTab2,.T.)
		(cAliasTab2)->X2_FILIAL	:= (cTmp)->GX3_FILIAL
		(cAliasTab2)->X2_CDPTCT	:= (cTmp)->GX4_CDPTCT
		(cAliasTab2)->X2_CDOPER	:= (cTmp)->GX3_CDOPER
		(cAliasTab2)->X2_SEQ		:= (cTmp)->GX3_SEQ
		(cAliasTab2)->X2_DSCONF	:= (cTmp)->GVI_DSCONF
		(cAliasTab2)->X2_QTDOPE	:= (cTmp)->QTDOPE
		(cAliasTab2)->X2_QTDREP	:= (cTmp)->QTDREP
		(cAliasTab2)->X2_TEMPATE	:= GFEC513TMP(2,(cTmp)->GX4_CDPTCT,(cTmp)->GX3_CDOPER,(cTmp)->GX3_SEQ)
		MsUnlock(cAliasTab2)
		(cTmp)->(dbSkip())
	EndDo
		
	(cTmp)->(dbCloseArea())

Return


//-----------------------------------
/*{Protheus.doc}
Parametros Iniciais

@author Felipe Machado de Oliveira
@version P12
@Since	15/04/2014
@obs Parametros Iniciais
*/
//-----------------------------------
Function GFEC513PAR()

	If Pergunte("GFEC513")
		LoadTab()
		oBrwUp:Disable()
		oBrwUp:Refresh()
		oBrwUp:Enable()
		oBrwUp:Refresh()
	EndIf

Return


//-----------------------------------
/*{Protheus.doc}
Calcula o tempo médio, mínimo e máximo do atendimento

@author Felipe Machado de Oliveira
@version P12
@Since	15/04/2014
@obs Calcula o tempo médio, mínimo e máximo do atendimento
*/
//-----------------------------------
Function GFEC513TMP(nPontOpe,cPonto,cOper,cSeq,nMedMinMax)
	Local cQuery 	:= ""
	Local cTmp 	:= GetNextAlias()
	Local nTMedAt := 0
	Local nValAnt := 9999999
	Local nQtd		:= 0
	Local dtEnt
	Local dtSai
	Local hrEnt
	Local hrSai
	
	Default cOper := ""
	Default cSeq 	:= ""
	Default nMedMinMax := 1
	
	cQuery := "SELECT GX4.GX4_DTENTR, "
	cQuery += "       GX4.GX4_DTSAI, "
	cQuery += "       GX4.GX4_HRENTR, "
	cQuery += "       GX4.GX4_HRSAI "
	cQuery += "  FROM "+RetSQLName("GX3")+" GX3 "
	cQuery += " INNER JOIN "+RetSQLName("GX4")+" GX4 "
	cQuery += "         ON GX4.GX4_NRMOV = GX3.GX3_NRMOV "
	cQuery += "        AND GX4.D_E_L_E_T_ = ' ' "
	If xFilial("GX4") == xFilial("GX3")
		cQuery += "     AND GX4.GX4_FILIAL = GX3.GX3_FILIAL "
	EndIf
	If nPontOpe = 2
		cQuery += " INNER JOIN "+RetSQLName("GVI")+" GVI "
		cQuery += "         ON GX3.GX3_CDOPER = GVI.GVI_CDOPER "
		cQuery += "        AND GX3.GX3_SEQ = GVI.GVI_SEQ "
		cQuery += "        AND GVI.D_E_L_E_T_ = ' ' "
		If xFilial("GVI") == xFilial("GX3")
			cQuery += "     AND GVI.GVI_FILIAL = GX3.GX3_FILIAL "
		EndIf
	EndIf
	cQuery += " WHERE GX3.D_E_L_E_T_ = ' ' "
	cQuery += "   AND GX4.GX4_CDPTCT = '"+cPonto+"' "
	cQuery += "   AND GX3.GX3_DTCRIA >= '"+DTOS(MV_PAR03)+"' "
	cQuery += "   AND GX3.GX3_DTCRIA <= '"+DTOS(MV_PAR04)+"' "
	If nPontOpe = 2
		cQuery += "AND GX3.GX3_CDOPER = '"+cOper+"' "
		cQuery += "AND GX3.GX3_SEQ = '"+cSeq+"' "
	Else
		cQuery += "AND GX3.GX3_CDOPER >= '"+MV_PAR05+"' "
		cQuery += "AND GX3.GX3_SEQ >= '"+MV_PAR06+"' "
		cQuery += "AND GX3.GX3_CDOPER <= '"+MV_PAR07+"' "
		cQuery += "AND GX3.GX3_SEQ <= '"+MV_PAR08+"' "
	EndIf
	If !Empty(xFilial("GX3"))
		cQuery += "AND GX3.GX3_FILIAL >= '"+MV_PAR01+"' "
		cQuery += "AND GX3.GX3_FILIAL <= '"+MV_PAR02+"' "
	EndIf
	If !Empty(MV_PAR09)
		cQuery += "AND GX3.GX3_CDEMIT = '"+MV_PAR09+"' "
	EndIf
	cQuery += "   AND GX4.GX4_DTENTR <> '' "
	cQuery += "   AND GX4.GX4_DTSAI <> '' "
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	
	If nMedMinMax != 2
		nValAnt := 0
	EndIf
	
	While (cTmp)->(!Eof())
		nQtd++
		
		dtEnt := (cTmp)->GX4_DTENTR
		dtSai := (cTmp)->GX4_DTSAI
		hrEnt := (cTmp)->GX4_HRENTR
		hrSai := (cTmp)->GX4_HRSAI

		If nMedMinMax == 1 //Tempo Médio
			nTMedAt += GFEC511ATM(StoD(dtEnt),StoD(dtSai),hrEnt,hrSai)
		ElseIf nMedMinMax == 2 //Tempo Minimo
			nTMedAt := GFEC511ATM(StoD(dtEnt),StoD(dtSai),hrEnt,hrSai)
			If nTMedAt < nValAnt 
				nValAnt := nTMedAt
			EndIf
		ElseIf nMedMinMax == 3 //Tempo Máximo
			nTMedAt := GFEC511ATM(StoD(dtEnt),StoD(dtSai),hrEnt,hrSai)
			If nTMedAt > nValAnt 
				nValAnt := nTMedAt
			EndIf
		EndIf
	
		(cTmp)->(dbSkip())
	EndDo
	(cTmp)->(dbCloseArea())
	
	If nMedMinMax != 1
		If nValAnt == 9999999
			nValAnt := 0
		EndIf
		nTMedAt := nValAnt
	Else
		nTMedAt := nTMedAt / nQtd
	EndIf

Return nTMedAt

Static Function MenuDef()
Local aRotina := {}
	ADD OPTION aRotina TITLE "Movimentações" 	ACTION "GFEC513MEN(1)" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Parâmetros" 	ACTION "GFEC513PAR()" OPERATION 2 ACCESS 0
Return aRotina
