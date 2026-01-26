#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'


/*/ GFEA094
@author siegklenes.beulke
@since 03/01/2013
@version 1.0		

@description
Monitor Contabil
/*/
Function GFEA094() 
	Local aCoors := FWGetDialogSize(oMainWnd)
	Static cMsg := "É necessário aplicar ou reaplicar o update de Inovação GFE11I28"
	Private cRealizado	:= "Realizado > 0"
	Private cCalculado	:= "Calculado > 0"
	Private cEstimado	:= "Estimado > 0"
	Private cSemCalc	:= "Estimado == 0 .And. Calculado == 0 .And. Realizado == 0 "
	Private cSemDiverg	:=	" If(Realizado > 0, TotalRatei == LctoDespe , " +;
							  	" If(Calculado > 0, TotalRatei == LctoDespe , " +;
							  	" If(Estimado  > 0, TotalRatei == LctoDespe , .F.)))"
	Private cComDiverg	:= ".T."
	Private lSDGW1		:= TamSX3("GW1_SERDC")[1] == 14
	Private oFWLayer, oPanelUp
	Private oBrowseGW1
	Private oDlg
	Private aFieldsGW1
	Private cAliasGW1
	Private cAliGW1Cal
	Private aNotaReal
	Private aNotaCalc
	Private aNotaEstim
	Private aNotaSemCalc
	Private aStructGW1 := {}
	
	Static cFil94
	
	If !Pergunte("GFEA094A",.T.)
		Return
	EndIf

	If Type("MV_PAR06") == "C"
		MsgInfo(cMsg,"Aviso")
	EndIf
	
	Define MsDialog oDlg Title 'Monitor Contábil' From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
	
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDlg, .F., .T.)
	
	oFWLayer:AddLine('UP',100,.F.)
	oFWLayer:AddCollumn('ALL',100,.T.,'UP')	
	oPanelUp   := oFWLayer:GetColPanel('ALL','UP')
	
	oDlg:Activate(,,,.T.,,,{||RptStatus({||Iniciar()}, "Carregando", "Aguarde, carregando dados...")})
	
	GFEDelTab(cAliasGW1)
Return Nil

Static Function MenuDef()
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE "Visualizar"	 			ACTION "GFEA094VIS()" OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Dados Provisão" 			ACTION "GFEA094PRV()" OPERATION 13 ACCESS 0
	ADD OPTION aRotina TITLE "Parâmetros" 				ACTION "GFEA094PAR()" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Estimar Frete"			ACTION "GFEA094EST()" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Filtrar"    				ACTION "GFEA094FDC()" OPERATION 3 ACCESS 0
	
Return aRotina

Static Function Iniciar()
	Local aIndGW1
	Local nTamVlr1	:= TamSx3("GWM_VLFRET")[1]
	Local nTamVlr2	:= TamSx3("GWM_VLFRET")[2]
	Local cPic		:= PESQPICT("GWM","GWM_VLFRET")
	Local nTamSer	:= TamSx3("GW1_SERDC")[1]

	SetRegua(5)
	
	IncRegua()
	
	aFieldsGW1 := { ;
	{"Filial"				,"GW1_FILIAL"	,	"C", FWSizeFilial(),0,,,,.T.},;
	{"Tipo Docto Carga"		,"GW1_CDTPDC"	,	"C", 05,0,/*cpicture*/,1,3,.T.},;
	{"Emissor Doc Carga"	,"GW1_EMISDC"	,	"C", TamSX3("GW1_EMISDC")[1],0,/*cpicture*/,1,3,.T.},;
	{"Série Docto"			,"GW1_SERDC"	,	"C", nTamSer,0,PESQPICT("GW1","GW1_SERDC"),1,3,.T.},;
	{"Nr.Doc.Carga"			,"GW1_NRDC"		,	"C", 16,0,/*cpicture*/,1,8,.T.},;
	{"Realizado"			,"Realizado"	,	"N", 16,0,,,,.F.},;
	{"Calculado"			,"Calculado"	,	"N", 16,0,,,,.F.},;
	{"Estimado"				,"Estimado"		,	"N", 16,0,,,,.F.},;
	{"Data Emissão"			,"GW1_DTEMIS"	,	"D", 8,0,,,,.T.},;
	{"Valor Carga"			,"GW8_VALOR"	,	"N", nTamVlr1,nTamVlr2,cPic,1,6,.T.},;
	{"Tipo Frete"			,"GW1_TPFRET"	,	"C", 20,0,/*cpicture*/,1,8,.T.,{||GetStrCbox(GetSx3Inf("GW1_TPFRET")[2],AllTrim((cAliasGW1)->GW1_TPFRET))}},;
	{"Valor Estimado"		,"VlEstim"		,	"N", nTamVlr1,nTamVlr2,cPic,1,6,.T.},;
	{"Valor Previsto"		,"VlPrevist"	,	"N", nTamVlr1,nTamVlr2,cPic,1,6,.T.},;
	{"Valor Realizado"		,"VlRealRat"  	,	"N", nTamVlr1,nTamVlr2,cPic,1,6,.T.},;
	{"Lancamento Despesa"	,"LctoDespe"	,	"N", nTamVlr1,nTamVlr2,cPic,1,6,.T./*,{||If ((cAliasGW1)->Realizado > 0, (cAliasGW1)->LctoDespe2, If ((cAliasGW1)->Calculado > 0,(cAliasGW1)->LctoDespe,(cAliasGW1)->LctoDespe3))}*/},;
	{"Lancamento Despesa"	,"LctoDespe2"	,	"N", nTamVlr1,nTamVlr2,cPic,1,6,.F.},;
	{"Lancamento Despesa"	,"LctoDespe3"	,	"N", nTamVlr1,nTamVlr2,cPic,1,6,.F.},;
	{"Lancamento Imposto"	,"LctoImpo"		,	"N", nTamVlr1,nTamVlr2,cPic,1,6,.F.},;
	{"Transportador"		,"GWU_CDTRP"	,	"C", TamSX3("GW1_EMISDC")[1],0,/*cpicture*/,1,8,.T.},;
	{"Nome Transportador"	,"GWU_NMTRP"	,	"C", TamSx3("GU3_NMEMIT")[1],0,/*cpicture*/,1,8,.T.,{||Posicione("GU3",1,xFilial("GU3")+(cAliasGW1)->GWU_CDTRP,"GU3_NMEMIT")}},;	
	{"Número cálculo"		,"GWF_NRCALC"	,	"C", TamSX3("GWF_NRCALC")[1],0,,1,8,.T.},;
	{"Lote de Provisão"		,"GXE_CODLOT"	,	"C", TamSX3("GXE_CODLOT")[1],0,,1,8,.T.},;
	{"Demais Lotes"			,"OutrosLote"	,	"C", 50,0,,1,8,.T.},;
	{"Nr Doc. Frete"		,"NrDocFrete"	,	"C", 50,0,,1,8,.T.},;
	{"Soma dos Rateios"		,"TotalRatei"	,	"N", nTamVlr1,nTamVlr2,,1,6,.F.};
	}
	
	aIndGW1 := {"GW1_FILIAL+GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC"}
	cAliasGW1 := CriaTab(aFieldsGW1, aIndGW1,@aStructGW1)
	cAliGW1Cal := CriaTab(aFieldsGW1, aIndGW1,@aStructGW1)
	
	IncRegua()
	// Pergunte()
	CarregarDados()

	dbSelectArea(cAliasGW1)
	(cAliasGW1)->(dbSetOrder(1))
	
	
	IncRegua()
	
	//
	// Documentos de Transporte
	//
	oBrowseGW1:= FWMBrowse():New()
	oBrowseGW1:SetOwner(oPanelUp)
	oBrowseGW1:SetDescription('Documentos de Carga')
	oBrowseGW1:DisableDetails()
	oBrowseGW1:SetAlias(cAliasGW1)
	oBrowseGW1:SetMenuDef('GFEA094')
	oBrowseGW1:SetProfileID('1')
	oBrowseGW1:ForceQuitButton()
	oBrowseGW1:SetAmbiente(.F.)
	oBrowseGW1:SetWalkthru(.F.)
	oBrowseGW1:SetFixedBrowse(.T.)
	
	oBrowseGW1:AddLegend(cRealizado,"GREEN", "Realizado","1")
	oBrowseGW1:AddLegend(cCalculado,"BLUE", "Calculado","1")
	oBrowseGW1:AddLegend(cEstimado,"YELLOW", "Estimado","1")
	oBrowseGW1:AddLegend(cSemCalc,"WHITE", "Sem Cálculo","1")
	oBrowseGW1:AddLegend(cSemDiverg,"GREEN", "Sem Divergências","2")
	oBrowseGW1:AddLegend(cComDiverg,"RED", "Com Divergências","2")
	
	oBrowseGW1:SetFields(GetFields(aFieldsGW1, "cAliasGW1"))
	A094Filtro()
	oBrowseGW1:Activate()
	
	IncRegua()
	
Return Nil

//
// Retorna estrutura de campos/colunas para browse com tabela temporária
//
Static Function GetFields(aStruct, cAlias)
	Local aFields := {}
	Local nCount
	
	For nCount := 1 To Len(aStruct)
		If aStruct[nCount, 9]
			aAdd(aFields, {aStruct[nCount,1],;
						     If (Len (aStruct[nCount]) >9, aStruct[nCount,10],&("{|| ("+cAlias+")->" + aStruct[nCount,2] + "}")),;
						     aStruct[nCount,3],;
						     aStruct[nCount,6],;
						     aStruct[nCount,7],;
						     aStruct[nCount,8],;
						     aStruct[nCount,5],;
						     .F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}})					     
		EndIf
	Next nCount 
Return aFields

// Cria tabela temporária
Static Function CriaTab(aFields, aIndices,aStruct)
	Local cAlias
	Local nCont
	               
	For nCont := 1 To Len(aFields)
		If aScan(aStruct,{|x| x[1] == aFields[nCont][2]}) == 0
			aADD(aStruct,{aFields[nCont][2],;  //Nome do campo
							aFields[nCont][3],;  //Tipo
							aFields[nCont][4],;  //Tamanho
							aFields[nCont][5]}) //Decimal
		EndIf
	Next nCont
	
	cAlias := GFECriaTab({aStruct,aIndices})
Return cAlias

Static Function CarregarDados(lChange)
	Local cQuery := ""
	Local cFiltroGWF
	Local cFiltroGWM
	Local cFiltroGW1 
	Local cFiltroGW3
	Local cFiltroGW6
	Local nTamGW9_NRCONT := TamSX3("GW9_NRCONT")[1]
	Local lGWAFrete
	Local lGWAImposto
	Local cGWA_TRANS
	Local aAreaAliGW1
	Local lContCal := .F.
	Local cProvCon := SuperGetMV("MV_PROVCON",, "1")
	Local cChaveAli
	Local aAreaAli
	Local aLotProv := {}
	Local nI := 1
	Local cMaior := ''
	Local nPos := 0
	Local nJ := 1
	Local cLotes := ''
	Local s_DSCTB  := SuperGetMv('MV_DSCTB',, '1')
	Local s_ERPGFE := SuperGetMv('MV_ERPGFE',, '1')
	
	Private dDataIni := MV_PAR03
	Private dDataFim := MV_PAR04
	
	Default lChange := .T.
	
	dbSelectArea(cAliasGW1)
	ZAP
	
	Pergunte("GFEA094A",.F.)
	// SQL
	cFiltroGW1 := " AND GW1.GW1_FILIAL >= '" + MV_PAR01        + "' AND GW1.GW1_FILIAL <='" + MV_PAR02        + "' "
	cFiltroGW1 += " AND GW1.GW1_SIT NOT IN ('2','7','8')"
	
	// ADVPL
	cFiltroGWF := "GWF->GWF_DTCRIA >= MV_PAR03 .AND. GWF->GWF_DTCRIA <= MV_PAR04"
	cFiltroGWM := "GWM->GWM_DTEMIS >= MV_PAR03 .AND. GWM->GWM_DTEMIS <= MV_PAR04 .AND. GWM->GWM_CDTRP == (cAliasGW1)->GWU_CDTRP"
	cFiltroGW3 := "GW3->GW3_DTEMIS >= MV_PAR03 .AND. GW3->GW3_DTEMIS <= MV_PAR04 .AND. Alltrim((cAliasGW1)->GWU_CDTRP) == Alltrim(GW3->GW3_EMISDF)"
	cFiltroGW6 := "GW6->GW6_DTFIN  >= MV_PAR03 .AND. GW6->GW6_DTFIN  <= MV_PAR04"
	
	cQuery += "SELECT GW1.GW1_FILIAL, GW1.GW1_CDTPDC, GW1.GW1_EMISDC, GW1.GW1_SERDC, GW1.GW1_NRDC, GW1.GW1_DTEMIS, GW1.GW1_TPFRET, "
	cQuery += "0 AS Realizado , "
	cQuery += "0 AS Calculado , "
	cQuery += "0 AS Estimado  , "
	cQuery += "0 AS VlEstim	  , "
	cQuery += "0 AS VlPrevist , "
	cQuery += "0 AS VlRealRat , "
	cQuery += "0 AS LctoDespe , "
	cQuery += "0 AS LctoDespe2, "
	cQuery += "0 AS LctoDespe3, "
	cQuery += "0 AS LctoImpo, "
	cQuery += "0 AS TotalRatei, "
	cQuery += "GWU.GWU_CDTRP, "
	cQuery += "'' AS GWU_NMTRP, "
	cQuery += "'' AS NrDocFrete, "
	cQuery += " (SELECT	SUM(GW8.GW8_VALOR)  FROM " + RetSqlName("GW8") + " GW8 "
	cQuery += "			WHERE GW8.GW8_FILIAL = GW1.GW1_FILIAL "
	cQuery += "				AND GW8.GW8_CDTPDC = GW1.GW1_CDTPDC "
	cQuery += "				AND GW8.GW8_EMISDC = GW1.GW1_EMISDC "
	cQuery += "				AND GW8.GW8_SERDC  = GW1.GW1_SERDC "
	cQuery += "				AND GW8.GW8_NRDC   = GW1.GW1_NRDC "
	cQuery += "				AND GW8.D_E_L_E_T_ = '') GW8_VALOR, "
	cQuery += " GWF.GWF_NRCALC, '' AS GXE_CODLOT "
	cQuery += "	FROM " + RetSqlName("GW1") + " GW1"
	cQuery += "			INNER JOIN  " + RetSqlName("GWU") + " GWU"
	cQuery += "			ON	GWU.GWU_FILIAL = GW1.GW1_FILIAL "
	cQuery += "				AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC"
	cQuery += "				AND GWU.GWU_EMISDC = GW1.GW1_EMISDC"
	cQuery += "				AND GWU.GWU_SERDC  = GW1.GW1_SERDC"
	cQuery += "				AND GWU.GWU_NRDC   = GW1.GW1_NRDC "
	cQuery += "				AND GWU.D_E_L_E_T_ = '' "
	cQuery += " 		LEFT JOIN " + RetSqlName("GWH") + " GWH "
	cQuery += " 		ON GWH.GWH_CDTPDC = GW1_CDTPDC "
	cQuery += " 			AND GWH.GWH_EMISDC = GW1.GW1_EMISDC "
	cQuery += " 			AND GWH.GWH_FILIAL = GW1.GW1_FILIAL "
	cQuery += " 			AND GWH.GWH_NRDC = GW1.GW1_NRDC "
	cQuery += " 			AND GWH.GWH_SERDC = GW1.GW1_SERDC "
	cQuery += " 			AND GWH.D_E_L_E_T_ = '' "
	cQuery += " 		LEFT JOIN " + RetSqlName("GWF") + " GWF  "
	cQuery += " 		ON GWF.GWF_FILIAL = GWH.GWH_FILIAL "
	cQuery += " 			AND GWF.GWF_NRCALC = GWH.GWH_NRCALC "
	cQuery += " 			AND GWF.D_E_L_E_T_ = '' " 
	cQuery += " 		LEFT JOIN " + RetSqlName("GXD") + " GXD "
	cQuery += "			ON GWF.GWF_FILIAL = GXD.GXD_FILCAL "
	cQuery += "			AND GWF.GWF_NRCALC = GXD.GXD_NRCALC "
	cQuery += "			AND GXD.D_E_L_E_T_ = '' "
	cQuery += "	WHERE GW1.D_E_L_E_T_ = '' AND"
	cQuery += "	GWF.GWF_DTCRIA >= '" + DTOS(MV_PAR03) + "' AND GWF.GWF_DTCRIA <='" + DTOS(MV_PAR04) + "' "
	cQuery += "    " + cFiltroGW1
	cQuery += "		GROUP BY GW1.GW1_FILIAL, "
	cQuery += "				GW1.GW1_CDTPDC, "
	cQuery += "				GW1.GW1_EMISDC, "
	cQuery += "				GW1.GW1_SERDC, "
	cQuery += "				GW1.GW1_NRDC,"
	cQuery += "				GW1.GW1_DTEMIS,"
	cQuery += "				GW1.GW1_TPFRET,"
	cQuery += "				GWU.GWU_CDTRP,"
	cQuery += "				GWF.GWF_NRCALC,"
	cQuery += "				GXD.GXD_CODLOT"
	cQuery += "		ORDER BY GW1.GW1_DTEMIS"
	
	SqlToTrb(cQuery, aStructGW1, cAliasGW1)
	
	cQuery := ""
	
	//Realiza um novo select para trazer os documentos de carga que não tem cálculo relacionado.
	cQuery += "SELECT GW1.GW1_FILIAL, GW1.GW1_CDTPDC, GW1.GW1_EMISDC, GW1.GW1_SERDC, GW1.GW1_NRDC, GW1.GW1_DTEMIS, GW1.GW1_TPFRET, "
	cQuery += "0 AS Realizado , "
	cQuery += "0 AS Calculado , "
	cQuery += "0 AS Estimado  , "
	cQuery += "0 AS VlEstim	  , "
	cQuery += "0 AS VlPrevist , "
	cQuery += "0 AS VlRealRat , "
	cQuery += "0 AS LctoDespe , "
	cQuery += "0 AS LctoDespe2, "
	cQuery += "0 AS LctoDespe3, "
	cQuery += "0 AS TotalRatei, "
	cQuery += "GWU.GWU_CDTRP, "
	cQuery += "'' AS GWU_NMTRP, "
	cQuery += " (SELECT	SUM(GW8.GW8_VALOR)  FROM " + RetSqlName("GW8") + " GW8 "
	cQuery += "			WHERE GW8.GW8_FILIAL = GW1.GW1_FILIAL "
	cQuery += "				AND GW8.GW8_CDTPDC = GW1.GW1_CDTPDC"
	cQuery += "				AND GW8.GW8_EMISDC = GW1.GW1_EMISDC"
	cQuery += "				AND GW8.GW8_SERDC  = GW1.GW1_SERDC"
	cQuery += "				AND GW8.GW8_NRDC   = GW1.GW1_NRDC "
	cQuery += "				AND GW8.D_E_L_E_T_ = '') GW8_VALOR, "
	cQuery += " '' AS GWF_NRCALC, '' AS GXE_CODLOT"	
	cQuery += "	FROM " + RetSqlName("GW1") + " GW1"
	cQuery += "			INNER JOIN  " + RetSqlName("GWU") + " GWU"
	cQuery += "			ON		GWU.GWU_FILIAL = GW1.GW1_FILIAL "
	cQuery += "				AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC"
	cQuery += "				AND GWU.GWU_EMISDC = GW1.GW1_EMISDC"
	cQuery += "				AND GWU.GWU_SERDC  = GW1.GW1_SERDC"
	cQuery += "				AND GWU.GWU_NRDC   = GW1.GW1_NRDC "
	cQuery += "				AND GWU.D_E_L_E_T_ = '' "
	cQuery += "	WHERE GW1.D_E_L_E_T_ = '' AND "
	cQuery += "	GW1.GW1_DTEMIS >= '" + DTOS(MV_PAR03) + "' AND GW1.GW1_DTEMIS <='" + DTOS(MV_PAR04) + "'"
	cQuery += "		" + cFiltroGW1
	cQuery += "		GROUP BY GW1.GW1_FILIAL, "
	cQuery += "				GW1.GW1_CDTPDC, "
	cQuery += "				GW1.GW1_EMISDC, "
	cQuery += "				GW1.GW1_SERDC, "
	cQuery += "				GW1.GW1_NRDC,"
	cQuery += "				GW1.GW1_DTEMIS,"
	cQuery += "				GW1.GW1_TPFRET,"
	cQuery += "				GWU.GWU_CDTRP"
	cQuery += "		ORDER BY GW1.GW1_DTEMIS"

	SqlToTrb(cQuery, aStructGW1, cAliGW1Cal)

	//Apaga os registros duplicados da cAliasGW1
	dbSelectArea(cAliasGW1)
	dbGoTop()
	While !(cAliasGW1)->( Eof() )
	
		//Guarda a chave do registro posicionado para posterior comparação.
		cChaveAli := (cAliasGW1)->(GW1_FILIAL+GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC+GWU_CDTRP)
		
		//Guarda o posicionamento da GW1
		aAreaAli := (cAliasGW1)->( GetArea() )
		
		(cAliasGW1)->( dbSkip() )
		
		lAcumula := .F.
		
		While !(cAliasGW1)->( Eof() )
			
			//Verifica se os movimentos correspondem as mesmas contas e tipo de movimento
			//para realizar a soma dos valores.
			If cChaveAli == (cAliasGW1)->(GW1_FILIAL+GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC+GWU_CDTRP)

				//apaga registro
				RecLock(cAliasGW1, .F.)
					(cAliasGW1)->( dbDelete() )	
				MsUnlock(cAliasGW1)
			EndIf
			
			(cAliasGW1)->( dbSkip() )
		EndDo
		
		RestArea(aAreaAli)
		   
		(cAliasGW1)->( dbSkip() )
		
	EndDo
	
	//Transfere os registros do cAliGW1Cal para o cAliasGW1
	dbSelectArea(cAliGW1Cal)
	dbGoTop()
	While !(cAliGW1Cal)->(Eof())
		
		dbSelectArea(cAliasGW1)
		dbSetOrder(01)
		If !dbSeek((cAliGW1Cal)->(GW1_FILIAL+GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC))
			RecLock((cAliasGW1), .T.)
				(cAliasGW1)->GW1_FILIAL := (cAliGW1Cal)->GW1_FILIAL
				(cAliasGW1)->GW1_CDTPDC := (cAliGW1Cal)->GW1_CDTPDC
				(cAliasGW1)->GW1_EMISDC := (cAliGW1Cal)->GW1_EMISDC
				(cAliasGW1)->GW1_SERDC	:= (cAliGW1Cal)->GW1_SERDC
				(cAliasGW1)->GW1_NRDC	:= (cAliGW1Cal)->GW1_NRDC
				(cAliasGW1)->GWF_NRCALC	:= (cAliGW1Cal)->GWF_NRCALC
				(cAliasGW1)->GW1_DTEMIS	:= (cAliGW1Cal)->GW1_DTEMIS
				(cAliasGW1)->GW1_TPFRET	:= (cAliGW1Cal)->GW1_TPFRET
				(cAliasGW1)->GWU_CDTRP	:= (cAliGW1Cal)->GWU_CDTRP
			(cAliasGW1)->( MsUnlock() )
		EndIf
		
		RecLock((cAliGW1Cal), .F.)
			(cAliGW1Cal)->( dbDelete() )
		(cAliGW1Cal)->( MsUnlock() )
	
		(cAliGW1Cal)->(dbSkip())	
	EndDo
	
	//Localiza os outros documentos de carga do cálculo (caso tenham documentos que estão fora do filtro)
	dbSelectArea(cAliasGW1)
	dbGoTop()
	While !(cAliasGW1)->(Eof())
	
		aAreaAliGW1 := (cAliasGW1)->(GetArea())
		
		If !Empty((cAliasGW1)->GWF_NRCALC)
			//Procura por outros documentos de carga relacionados e adiciona na tabela temporária
			dbSelectArea("GWH")
			dbSetOrder(01)
			If dbSeek((cAliasGW1)->GW1_FILIAL+(cAliasGW1)->GWF_NRCALC)
				While !GWH->( Eof() ) .And. (cAliasGW1)->(GW1_FILIAL+GWF_NRCALC) == GWH->(GWH_FILIAL+GWH_NRCALC)
					dbSelectArea(cAliasGW1)
					dbSetOrder(01)
					If !dbSeek(GWH->(GWH_FILIAL+GWH_CDTPDC+GWH_EMISDC+GWH_SERDC+GWH_NRDC))
						dbSelectArea("GW1")
						dbSetOrder(01)
						dbSeek(GWH->(GWH_FILIAL+GWH_CDTPDC+GWH_EMISDC+GWH_SERDC+GWH_NRDC))
						
						dbSelectArea("GWF")
						dbSetOrder(01)
						dbSeek(GWH->(GWH_FILIAL+GWH_NRCALC))
						
						RecLock((cAliasGW1), .T.)
							(cAliasGW1)->GW1_FILIAL := GW1->GW1_FILIAL
							(cAliasGW1)->GW1_CDTPDC := GW1->GW1_CDTPDC
							(cAliasGW1)->GW1_EMISDC := GW1->GW1_EMISDC
							(cAliasGW1)->GW1_SERDC	:= GW1->GW1_SERDC
							(cAliasGW1)->GW1_NRDC	:= GW1->GW1_NRDC
							(cAliasGW1)->GW1_DTEMIS	:= GW1->GW1_DTEMIS
							(cAliasGW1)->GW1_TPFRET	:= GW1->GW1_TPFRET
							(cAliasGW1)->GWU_CDTRP	:= GWF->GWF_TRANSP
						(cAliasGW1)->( MsUnlock() )
						
					EndIf
					GWH->(dbSkip())
				EndDo
				RestArea(aAreaAliGW1)
			
			EndIf
		EndIf
		(cAliasGW1)->(dbSkip())	
	EndDo

	dbSelectArea(cAliasGW1)
	dbGoTop()	
	
	While !(cAliasGW1)->(Eof())
		RecLock((cAliasGW1), .F.)
				
		dbSelectArea("GWM")
		dbSetOrder(2)
		If dbSeek((cAliasGW1)->GW1_FILIAL + (cAliasGW1)->GW1_CDTPDC + (cAliasGW1)->GW1_EMISDC + (cAliasGW1)->GW1_SERDC + (cAliasGW1)->GW1_NRDC)
			While !GWM->(Eof()) .AND. ;
				  	GWM->GWM_FILIAL == (cAliasGW1)->GW1_FILIAL .AND. ;
				  	GWM->GWM_CDTPDC == (cAliasGW1)->GW1_CDTPDC .AND. ;
		         	GWM->GWM_EMISDC == (cAliasGW1)->GW1_EMISDC .AND. ;
		         	GWM->GWM_SERDC  == (cAliasGW1)->GW1_SERDC  .AND. ;
		         	GWM->GWM_NRDC   == (cAliasGW1)->GW1_NRDC
		        
			    	If &(cFiltroGWM)
			    	
			    		// DOCUMENTO DE FRETE
						If GWM->GWM_TPDOC == '2'
							dbSelectArea("GW4")
							dbSetOrder(2) // GW4_FILIAL+GW4_EMISDC+GW4_SERDC+GW4_NRDC+GW4_TPDC
							If dbSeek(GWM->GWM_FILIAL + GWM->GWM_EMISDC + GWM->GWM_SERDC + GWM->GWM_NRDC + GWM->GWM_CDTPDC)
								While !GW4->(Eof()) .AND. ;
								       GW4->GW4_FILIAL == GWM->GWM_FILIAL .AND. ;
								       GW4->GW4_EMISDC == GWM->GWM_EMISDC .AND. ;
								       GW4->GW4_SERDC  == GWM->GWM_SERDC  .AND. ;
								       GW4->GW4_NRDC   == GWM->GWM_NRDC   .AND. ;
								       GW4->GW4_TPDC   == GWM->GWM_CDTPDC
								       
									dbSelectArea("GW3")
								   	dbSetOrder(1) // GW3_FILIAL+GW3_CDESP+GW3_EMISDF+GW3_SERDF+GW3_NRDF+DTOS(GW3_DTEMIS)
								  	If dbSeek(GW4->GW4_FILIAL + GW4->GW4_CDESP + GW4->GW4_EMISDF + GW4->GW4_SERDF + GW4->GW4_NRDF + DTOS(GW4->GW4_DTEMIS))
										
										If Empty(Alltrim( (cAliasGW1)->NrDocFrete ))
											(cAliasGW1)->NrDocFrete := Alltrim(GW3->GW3_NRDF)
										Else
											If !(Alltrim(GW3->GW3_NRDF) $ (cAliasGW1)->NrDocFrete )
												(cAliasGW1)->NrDocFrete += ", " + Alltrim(GW3->GW3_NRDF)
											EndIf
										EndIf

								  		If &(cFiltroGW3)
									  		dbSelectArea("GW6")
									  		dbSetOrder(1) // GW6_FILIAL+GW6_EMIFAT+GW6_SERFAT+GW6_NRFAT+GW6_DTEMIS
									  		If dbSeek(GW3->GW3_FILIAL + GW3->GW3_EMIFAT + GW3->GW3_SERFAT + GW3->GW3_NRFAT + DTOS(GW3->GW3_DTEMFA))
									  			If &(cFiltroGW6) .AND. GW6->GW6_SITFIN == '4'
									  			
									  				// [VlRealRat] - Valor Real
									         		(cAliasGW1)->VlRealRat += GWM->GWM_VLFRET
													
										        	// [Realizado]
													If GW6->(RecNo()) < (cAliasGW1)->Realizado .OR. (cAliasGW1)->Realizado == 0
														(cAliasGW1)->Realizado := GW6->(RecNo())
													EndIf
												EndIf
									  		ElseIf GW3->GW3_SITFIS == "4" .And. GW3->GW3_ACINT == "1" .And. s_DSCTB == "2" .And. s_ERPGFE == "1"
													// [VlRealRat] - Valor Real
								         			(cAliasGW1)->VlRealRat += GWM->GWM_VLFRET
												
										        	// [Realizado]
													If GW3->(RecNo()) < (cAliasGW1)->Realizado .OR. (cAliasGW1)->Realizado == 0
														(cAliasGW1)->Realizado := GW3->(RecNo())
													EndIf 
									  		EndIf
									  	EndIf
								  	EndIf
								
									GW4->(dbSkip())
								EndDo
							EndIf
						EndIf
					EndIf
						// CONTRATO
						If GWM->GWM_TPDOC == '3'
													
							// [VlRealRat]
							(cAliasGW1)->VlRealRat += GWM->GWM_VLFRET
							
							// [LctoDespe2]
							dbSelectArea("GW9")
							dbSetOrder(1)
							If dbSeek(GWM->GWM_FILIAL + PadR(GWM->GWM_NRDOC, nTamGW9_NRCONT))
				         		(cAliasGW1)->LctoDespe2 += GWM->GWM_VLFRET
							EndIf
						EndIf
						
			    		// CALCULO DE FRETE
			    		If GWM->GWM_TPDOC == '1' .OR. GWM->GWM_TPDOC == '4'
				          	dbSelectArea("GWF")
				          	GWF->( dbSetOrder(1) )
				          	If GWF->( dbSeek(GWM->GWM_FILIAL + GWM->GWM_NRDOC) )
				          		If GWF->GWF_TRANSP == (cAliasGW1)->GWU_CDTRP
					          		If &(cFiltroGWF)
									    If GWF->GWF_TPCALC == "1" .OR. GWF->GWF_TPCALC == "6"
									    
									    	If GWF->GWF_TRANSP == (cAliasGW1)->GWU_CDTRP
									        	
									        	(cAliasGW1)->GWF_NRCALC := GWF->GWF_NRCALC
											
									        		aLotProv := {}
													cMaior := ''
													nPos := 0
													cLotes := ''
									        		
									        		GXD->(dbSetOrder(2))
									        		If GXD->(dbSeek(GWF->GWF_FILIAL+GWF->GWF_NRCALC))
									        			While !GXD->( Eof() ) .And. GXD->GXD_FILCAL == GWF->GWF_FILIAL ;
									        								  .And. GXD->GXD_NRCALC == GWF->GWF_NRCALC
										        			
										        			aAdd(aLotProv, GXD->GXD_CODLOT)
										        
															GXD->( dbSkip() )
														EndDo
														
														//Busca o ultimo lote de provisão
														
														For nI := 1 to Len(aLotProv)
															If aLotProv[nI] > cMaior
																cMaior := aLotProv[nI]
																nPos := nI
															EndIf
														Next nI
														
														aDel(aLotProv, nPos)
														aSize(aLotProv, Len(aLotProv)-1)
														
														For nJ := 1 to Len(aLotProv)
															cLotes += aLotProv[nJ] + If(nJ == Len(aLotProv), " ", ", ")
														Next nJ
														
														//Carrega o valor nos campos
														(cAliasGW1)->GXE_CODLOT := cMaior
														(cAliasGW1)->OutrosLote := cLotes
														
									        		EndIf
													
											EndIf
									    
						          			If cProvCon == "1" //"1=Despesa Total"
						          				/*Opção 1-Despesa Total
												Coluna Valor: Valor Total do Frete (GWM_VL_FRETE) / 
												Coluna Lançamento: Valor Total das Despesas de Frete (GWM_VLFRETE que tenham GWA).*/
						          				// [VlPrevist] - Valor Previsto
									        	(cAliasGW1)->VlPrevist += GWM->GWM_VLFRET
									        	// [Calculado]
												If GWF->(RecNo()) < (cAliasGW1)->Calculado .OR. (cAliasGW1)->Calculado == 0
													(cAliasGW1)->Calculado := GWF->(RecNo())
												EndIf		
							  				ElseIf cProvCon == "2" //"2=Despesa menos Impostos Recuperáveis"
							  					/*Opção 2- Despesa Menos Imp Recuperáveis
												Coluna Valor (Valor Total do Frete descontando os Impostos Recuperáveis )
												Coluna Lançamento: Valor Total das Despesas de Frete (GWM_VLFRETE que tenham GWA) 
												descontando as colunas de impostos recuperáveis*/
							  					// [VlPrevist] - Valor Previsto
									        	(cAliasGW1)->VlPrevist += GWM->GWM_VLFRET
									        	//(cAliasGW1)->VlPrevist := DescImpRec((cAliasGW1)->VlPrevist)
									        	// [Calculado]
												If GWF->(RecNo()) < (cAliasGW1)->Calculado .OR. (cAliasGW1)->Calculado == 0
													(cAliasGW1)->Calculado := GWF->(RecNo())
												EndIf
							  				ElseIf cProvCon == "3" //"3=Despesa menos Impostos"
							  					/*Opção 3- Despesa Menos Impostos
												Coluna Valor (Valor Total do Frete descontando todos Impostos)
												Coluna Lançamento: Valor Total das Despesas de Frete (GWM_VLFRETE que 
												tenham GWA) descontando as colunas de impostos*/
												// [VlPrevist] - Valor Previsto
									        	(cAliasGW1)->VlPrevist += GWM->GWM_VLFRET
									        	(cAliasGW1)->VlPrevist := DescImpGWF((cAliasGW1)->VlPrevist)
									        	// [Calculado]
												If GWF->(RecNo()) < (cAliasGW1)->Calculado .OR. (cAliasGW1)->Calculado == 0
													(cAliasGW1)->Calculado := GWF->(RecNo())
												EndIf
							  				Else //"4=Despesa e Impostos Recuperáveis"
							  					/*Opção 4 – Despesa E Impostos
												Coluna Valor: Valor Total do Frete (GWM_VL_FRETE) 
												Coluna Lançamento: Valor Total das Despesas de Frete 
												(GWM_VLFRETE que tenham GWA). ? Este aqui ficaria igual a opção 1, 
												a diferença somente seria visto no lote, onde as contas 
												estariam diferentes (a parte do imposto estará em um lançamento 
												diferente).*/
												// [VlPrevist] - Valor Previsto
									        	(cAliasGW1)->VlPrevist += GWM->GWM_VLFRET
									        	// [Calculado]
												If GWF->(RecNo()) < (cAliasGW1)->Calculado .OR. (cAliasGW1)->Calculado == 0
													(cAliasGW1)->Calculado := GWF->(RecNo())
												EndIf
							  				EndIf
										Else
											 // [VlEstim] - Valor Estimado
									        If GWF->GWF_TPCALC == "8"
									        
									        	If GWF->GWF_TRANSP == (cAliasGW1)->GWU_CDTRP
										        	
										        	(cAliasGW1)->GWF_NRCALC := GWF->GWF_NRCALC
												
										        	aLotProv := {}
													cMaior := ''
													nPos := 0
													cLotes := ''
									        		
									        		GXD->(dbSetOrder(2))
									        		If GXD->(dbSeek(GWF->GWF_FILIAL+GWF->GWF_NRCALC))
									        			While !GXD->( Eof() ) .And. GXD->GXD_FILCAL == GWF->GWF_FILIAL ;
									        								  .And. GXD->GXD_NRCALC == GWF->GWF_NRCALC
										        			
										        			aAdd(aLotProv, GXD->GXD_CODLOT)
										        
															GXD->( dbSkip() )
														EndDo
														
														//Busca o ultimo lote de provisão
														
														For nI := 1 to Len(aLotProv)
															If aLotProv[nI] > cMaior
																cMaior := aLotProv[nI]
																nPos := nI
															EndIf
														Next nI
														
														aDel(aLotProv, nPos)
														aSize(aLotProv, Len(aLotProv)-1)
														
														For nJ := 1 to Len(aLotProv)
															cLotes += aLotProv[nJ] + If(nJ == Len(aLotProv), " ", ", ")
														Next nJ
														
														//Carrega o valor nos campos
														(cAliasGW1)->GXE_CODLOT := cMaior
														(cAliasGW1)->OutrosLote := cLotes
														
									        		EndIf
												EndIf
									        
									        	If cProvCon == "1" //"1=Despesa Total"
							          				/*Opção 1-Despesa Total
													Coluna Valor: Valor Total do Frete (GWM_VL_FRETE) / 
													Coluna Lançamento: Valor Total das Despesas de Frete (GWM_VLFRETE que tenham GWA).*/
							          				(cAliasGW1)->VlEstim += GWM->GWM_VLFRET
										        	(cAliasGW1)->VlEstim := DescImpGWF((cAliasGW1)->VlEstim)
										        	// [Estimado]
													If GWF->(RecNo()) < (cAliasGW1)->Estimado .OR. (cAliasGW1)->Estimado == 0
														(cAliasGW1)->Estimado := GWF->(RecNo())
													EndIf			
								  				ElseIf cProvCon == "2" //"2=Despesa menos Impostos Recuperáveis"
								  					/*Opção 2- Despesa Menos Imp Recuperáveis
													Coluna Valor (Valor Total do Frete descontando os Impostos Recuperáveis )
													Coluna Lançamento: Valor Total das Despesas de Frete (GWM_VLFRETE que tenham GWA) 
													descontando as colunas de impostos recuperáveis*/
								  					// [VlPrevist] - Valor Previsto
										        	(cAliasGW1)->VlEstim += GWM->GWM_VLFRET
										        	//(cAliasGW1)->VlEstim := DescImpRec((cAliasGW1)->VlEstim)
										        	// [Calculado]
													If GWF->(RecNo()) < (cAliasGW1)->Estimado .OR. (cAliasGW1)->Estimado == 0
														(cAliasGW1)->Estimado := GWF->(RecNo())
													EndIf
								  				ElseIf cProvCon == "3" //"3=Despesa menos Impostos"
								  					/*Opção 3- Despesa Menos Impostos
													Coluna Valor (Valor Total do Frete descontando todos Impostos)
													Coluna Lançamento: Valor Total das Despesas de Frete (GWM_VLFRETE que 
													tenham GWA) descontando as colunas de impostos*/
													// [VlPrevist] - Valor Previsto
										        	(cAliasGW1)->VlEstim += GWM->GWM_VLFRET
										        	(cAliasGW1)->VlEstim := DescImpGWF((cAliasGW1)->VlEstim)
										        	// [Calculado]
													If GWF->(RecNo()) < (cAliasGW1)->Estimado .OR. (cAliasGW1)->Estimado == 0
														(cAliasGW1)->Estimado := GWF->(RecNo())
													EndIf
								  				Else //"4=Despesa e Impostos Recuperáveis"
								  					/*Opção 4 – Despesa E Impostos
													Coluna Valor: Valor Total do Frete (GWM_VL_FRETE) 
													Coluna Lançamento: Valor Total das Despesas de Frete 
													(GWM_VLFRETE que tenham GWA). ? Este aqui ficaria igual a opção 1, 
													a diferença somente seria visto no lote, onde as contas 
													estariam diferentes (a parte do imposto estará em um lançamento 
													diferente).*/
													// [VlPrevist] - Valor Previsto
										        	(cAliasGW1)->VlEstim += GWM->GWM_VLFRET
										        	// [Calculado]
													If GWF->(RecNo()) < (cAliasGW1)->Estimado .OR. (cAliasGW1)->Estimado == 0
														(cAliasGW1)->Estimado := GWF->(RecNo())
													EndIf
							  					EndIf
									        EndIf
									    EndIf
									 EndIf 
								EndIf
							EndIf
					EndIf	
				GWM->(dbSkip())
			EndDo
		EndIf
		
		MsUnlock()
		
		lContCal := .F.
				
		(cAliasGW1)->(dbSkip())
	EndDo		
	
	/*
		i.Valores Colunas: Mostrar somente um valor entre as colunas Valor Estimado, Valor Previsto e Valor Realizado. Será apresentado 
		o valor que estiver de acordo com o período selecionado. Se todos estiverem no mesmo período, apresenta o último documento 
		(o realizado).
		Ex: nota em 30/04, cálculo em 01/05 e fatura em 15/06. Quando selecionado período de abril, será apresentado cálculo de 
		estimativa, quando selecionado período de maio será apresentado o valor do cálculo previsto e se junho, então é apresentando 
		o realizado.	
	*/
	
	dbSelectArea(cAliasGW1)
	dbGoTop()
	While !(cAliasGW1)->(Eof())
		If (cAliasGW1)->VlRealRat != 0
			//Verificar a data da fatura para comparar com a data do filtro e verificar qual o valor que irá permanecer;
			dbSelectArea("GW4")
			GW4->( dbSetOrder(2) ) //GWM_FILIAL+GWM->GWM_EMISDC+GWM->GWM_SERDC+GWM->GWM_NRDC+GWM->GWM_CDTPDC
			GW4->( dbSeek((cAliasGW1)->(GW1_FILIAL+GW1_EMISDC+GW1_SERDC+GW1_NRDC+GW1_CDTPDC)) )
				dbSelectArea("GW3")
				GW3->( dbSetOrder(1) ) // GW3_FILIAL+GW3_CDESP+GW3_EMISDF+GW3_SERDF+GW3_NRDF+DTOS(GW3_DTEMIS)
				GW3->( dbSeek(GW4->GW4_FILIAL + GW4->GW4_CDESP + GW4->GW4_EMISDF + GW4->GW4_SERDF + GW4->GW4_NRDF + DTOS(GW4->GW4_DTEMIS)) )
					dbSelectArea("GW6")
					GW6->( dbSetOrder(1) ) //GW6_FILIAL+GW6_EMIFAT+GW6_SERFAT+GW6_NRFAT+GW6_DTEMIS
					If GW6->( dbSeek(GW3->GW3_FILIAL + GW3->GW3_EMIFAT + GW3->GW3_SERFAT + GW3->GW3_NRFAT + DTOS(GW3->GW3_DTEMFA)) )
						If (GW6->GW6_DTEMIS < dDataIni .Or. GW6->GW6_DTEMIS > dDataFim) .And. GW6->GW6_SITFIN != '4'
							RecLock(cAliasGW1, .F.)
								(cAliasGW1)->VlRealRat := 0
							(cAliasGW1)->( MsUnlock() )
						EndIf
					EndIf
		EndIf
		
		If (cAliasGW1)->VlPrevist != 0
			//Verificar a data da cálculo para comparar com a data do filtro e verificar qual o valor que irá permanecer;
			dbSelectArea("GWF")
			GWF->( dbSetOrder(1) )
			GWF->( dbSeek((cAliasGW1)->GW1_FILIAL+(cAliasGW1)->GWF_NRCALC) )
				If (GWF->GWF_TPCALC == "1" .OR. GWF->GWF_TPCALC == "6") //Normal ou redespacho.
					If (cAliasGW1)->VlRealRat != 0
						RecLock(cAliasGW1, .F.)
							(cAliasGW1)->VlPrevist := 0
						(cAliasGW1)->( MsUnlock() )
					ElseIf (GWF->GWF_DTCRIA < dDataIni .Or. GWF->GWF_DTCRIA > dDataFim)
						RecLock(cAliasGW1, .F.)
							(cAliasGW1)->VlPrevist := 0
						(cAliasGW1)->( MsUnlock() )
					EndIf
				EndIf
		EndIf 
		
		If (cAliasGW1)->VlEstim != 0
			//Verificar a data da estimativa para comparar com a data do filtro e verificar qual o valor que irá permanecer;
			dbSelectArea("GWF")
			GWF->( dbSetOrder(1) )
			GWF->( dbSeek((cAliasGW1)->GW1_FILIAL+(cAliasGW1)->GWF_NRCALC) )
				If (cAliasGW1)->VlRealRat != 0 .Or. (cAliasGW1)->VlPrevist != 0
					RecLock(cAliasGW1, .F.)
						(cAliasGW1)->VlEstim := 0
					(cAliasGW1)->( MsUnlock() )
				ElseIf (GWF->GWF_DTCRIA < dDataIni .Or. GWF->GWF_DTCRIA > dDataFim)
					RecLock(cAliasGW1, .F.)
						(cAliasGW1)->VlEstim := 0
					(cAliasGW1)->( MsUnlock() )
				EndIf
		EndIf
		
		(cAliasGW1)->(dbSkip())
	EndDo
	
	/*Compoe o valor dos lançamentos contábeis.*/
	dbSelectArea(cAliasGW1)
	(cAliasGW1)->( dbGoTop() )
	While !(cAliasGW1)->(Eof())
	
		If (cAliasGW1)->VlRealRat != 0
			dbSelectArea("GW4")
			GW4->(dbSetOrder(02))
			If GW4->(dbSeek((cAliasGW1)->(GW1_FILIAL+GW1_EMISDC+GW1_SERDC+GW1_NRDC+GW1_CDTPDC)))//GW4_FILIAL+GW4_EMISDC+GW4_SERDC+GW4_NRDC+GW4_TPDC
				While !GW4->(EOF()) .And. ;
					(cAliasGW1)->GW1_FILIAL == GW4->GW4_FILIAL .And. ;
					(cAliasGW1)->GW1_EMISDC == GW4->GW4_EMISDC .And. ;
					(cAliasGW1)->GW1_SERDC == GW4->GW4_SERDC .And. ;
					(cAliasGW1)->GW1_NRDC == GW4->GW4_NRDC .And. ;
					(cAliasGW1)->GW1_CDTPDC == GW4->GW4_TPDC
					
					If GW4->GW4_EMISDF == (cAliasGW1)->GWU_CDTRP

						dbSelectArea("GWA")
						GWA->(dbSetOrder(01))
						If GWA->(dbSeek(GW4->GW4_FILIAL+'2'+GW4->GW4_CDESP+GW4->GW4_EMISDF+GW4->GW4_SERDF+GW4->GW4_NRDF+DTOS(GW4->GW4_DTEMIS)))
						//GWA_FILIAL+GWA_TPDOC+GWA_CDESP+GWA_CDEMIT+GWA_SERIE+GWA_NRDOC+DTOS(GWA_DTEMIS)+GWA_CDTRAN+GWA_SEQ
							While !GWA->(Eof()) 					.AND. ;
							   GWA->GWA_FILIAL == GW4->GW4_FILIAL	.AND. ;
							   GWA->GWA_TPDOC  == '2'				.AND. ;
							   GWA->GWA_CDESP  == GW4->GW4_CDESP   	.AND. ;
							   GWA->GWA_CDEMIT == GW4->GW4_EMISDF  	.AND. ;
							   GWA->GWA_SERIE  == GW4->GW4_SERDF  	.AND. ;
							   GWA->GWA_NRDOC  == GW4->GW4_NRDF   	.AND. ;
							   GWA->GWA_DTEMIS == GW4->GW4_DTEMIS
							   				   
								cGWA_TRANS := AllTrim(GWA->GWA_CDTRAN)
								
								RecLock((cAliasGW1), .F.)
									
									If cGWA_TRANS == "310"	
										(cAliasGW1)->LctoDespe += GWA->GWA_VLMOV
									EndIf
									
									If (cGWA_TRANS == "311" .OR. cGWA_TRANS == "312" .OR. cGWA_TRANS == "313") /*.And. cProvCon $ '1;4'*/
										(cAliasGW1)->LctoDespe += GWA->GWA_VLMOV
									EndIf
									
								MsUnlock()
							
								GWA->(dbSkip())
							EndDo
						
						EndIf
					EndIf
					
					GW4->( dbSkip() )
				EndDo
			EndIf
		EndIf
		
		If (cAliasGW1)->VlPrevist != 0 
			dbSelectArea("GWH")
			GWH->(dbSetOrder(02))
			If GWH->(dbSeek((cAliasGW1)->(GW1_FILIAL+GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC)))//GWH_FILIAL+GWH_CDTPDC+GWH_EMISDC+GWH_SERDC+GWH_NRDC+GWH_NRCALC
				While !GWH->( Eof() ) .And. ;
						(cAliasGW1)->GW1_FILIAL == GWH->GWH_FILIAL .And. ;
						(cAliasGW1)->GW1_CDTPDC == GWH->GWH_CDTPDC .And. ;
						(cAliasGW1)->GW1_EMISDC == GWH->GWH_EMISDC .And. ;
						(cAliasGW1)->GW1_SERDC	== GWH->GWH_SERDC  .And. ;
						(cAliasGW1)->GW1_NRDC	== GWH->GWH_NRDC
				
					dbSelectArea("GWF")
					GWF->(dbSetOrder(01))
					If GWF->(dbSeek(GWH->(GWH_FILIAL+GWH_NRCALC)))
						If GWF->GWF_TRANSP == (cAliasGW1)->GWU_CDTRP
							If GWF->GWF_TPCALC == '1' .Or. GWF->GWF_TPCALC == '6' 
								dbSelectArea("GWA")
								dbSetOrder(01)
								If dbSeek(GWF->GWF_FILIAL+'1'+Space(TamSX3("GWA_CDESP")[1])+GWF->GWF_TRANSP+Space(TamSX3("GWA_SERIE")[1])+GWF->GWF_NRCALC)
								//GWA_FILIAL+GWA_TPDOC+GWA_CDESP+GWA_CDEMIT+GWA_SERIE+GWA_NRDOC+DTOS(GWA_DTEMIS)+GWA_CDTRAN+GWA_SEQ
									While !GWA->(Eof()) 					.AND. ;
									   GWA->GWA_FILIAL == GWH->GWH_FILIAL	.AND. ;
									   GWA->GWA_TPDOC  == '1'				.AND. ;
									   GWA->GWA_CDESP  == Space(TamSX3("GWA_CDESP")[1])  	.AND. ;
									   GWA->GWA_CDEMIT == GWF->GWF_TRANSP  	.AND. ;
									   GWA->GWA_SERIE  == Space(TamSX3("GWA_SERIE")[1])  	.AND. ;
									   Alltrim(GWA->GWA_NRDOC)  == Alltrim(GWF->GWF_NRCALC)
									   
										cGWA_TRANS := AllTrim(GWA->GWA_CDTRAN)
											
										RecLock((cAliasGW1), .F.)
											If cGWA_TRANS == "300"	
												(cAliasGW1)->LctoDespe += GWA->GWA_VLMOV
											EndIf
											
											If (cGWA_TRANS == "301" .OR. cGWA_TRANS == "302" .OR. cGWA_TRANS == "303") .And. cProvCon $ '1;4'
												(cAliasGW1)->LctoDespe += GWA->GWA_VLMOV
											EndIf
											
										MsUnlock()
										
										GWA->(dbSkip())
									EndDo
								EndIf
							EndIf
						EndIf
					EndIf
					GWH->(dbSkip())
				
				EndDo
			EndIf
		EndIf 
		
		If (cAliasGW1)->VlEstim != 0
			dbSelectArea("GWH")
			GWH->(dbSetOrder(02))
			If GWH->(dbSeek((cAliasGW1)->(GW1_FILIAL+GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC)))//GWH_FILIAL+GWH_CDTPDC+GWH_EMISDC+GWH_SERDC+GWH_NRDC+GWH_NRCALC
				While !GWH->( Eof() ) .And. ;
						(cAliasGW1)->GW1_FILIAL == GWH->GWH_FILIAL .And. ;
						(cAliasGW1)->GW1_CDTPDC == GWH->GWH_CDTPDC .And. ;
						(cAliasGW1)->GW1_EMISDC == GWH->GWH_EMISDC .And. ;
						(cAliasGW1)->GW1_SERDC	== GWH->GWH_SERDC  .And. ;
						(cAliasGW1)->GW1_NRDC	== GWH->GWH_NRDC
						
					If GWH->GWH_NRCALC == (cAliasGW1)->GWF_NRCALC
				
						dbSelectArea("GWF")
						GWF->(dbSetOrder(01))
						If GWF->(dbSeek(GWH->(GWH_FILIAL+GWH_NRCALC)))
							If GWF->GWF_TPCALC == '8'
								dbSelectArea("GWA")
								dbSetOrder(01)
								If dbSeek(GWF->GWF_FILIAL+'4'+Space(TamSX3("GWA_CDESP")[1])+GWF->GWF_TRANSP+Space(TamSX3("GWA_SERIE")[1])+GWF->GWF_NRCALC)
								//GWA_FILIAL+GWA_TPDOC+GWA_CDESP+GWA_CDEMIT+GWA_SERIE+GWA_NRDOC+DTOS(GWA_DTEMIS)+GWA_CDTRAN+GWA_SEQ
									While !GWA->(Eof()) 					.AND. ;
									   GWA->GWA_FILIAL == GWF->GWF_FILIAL	.AND. ;
									   GWA->GWA_TPDOC  == '4'				.AND. ;
									   GWA->GWA_CDESP  == Space(TamSX3("GWA_CDESP")[1])  	.AND. ;
									   GWA->GWA_CDEMIT == GWF->GWF_TRANSP  	.AND. ;
									   GWA->GWA_SERIE  == Space(TamSX3("GWA_SERIE")[1])  	.AND. ;
									   Alltrim(GWA->GWA_NRDOC)  == Alltrim(GWF->GWF_NRCALC)
									   
										cGWA_TRANS := AllTrim(GWA->GWA_CDTRAN)
											
										RecLock((cAliasGW1), .F.)
											If cGWA_TRANS == "300"	
												(cAliasGW1)->LctoDespe += GWA->GWA_VLMOV
											EndIf
											
											If (cGWA_TRANS == "301" .OR. cGWA_TRANS == "302" .OR. cGWA_TRANS == "303") .And. cProvCon $ '1;4'
												(cAliasGW1)->LctoDespe += GWA->GWA_VLMOV
											EndIf
											
										MsUnlock()
										
										GWA->(dbSkip())
									EndDo
								EndIf
							EndIf
						EndIf
					EndIf
					
				GWH->(dbSkip())
				
				EndDo
			EndIf
		EndIf 
		
		(cAliasGW1)->(dbSkip())
	EndDo
	
	/*Soma os valores dos rateios para verificar se confere com o valor dos lançamentos contábeis.*/
	dbSelectArea(cAliasGW1)
	(cAliasGW1)->( dbGoTop() )
	While !(cAliasGW1)->(Eof())
	 
		   If (cAliasGW1)->VlEstim != 0
		   
				dbSelectArea("GWM")
				dbSetOrder(1)
				If dbSeek((cAliasGW1)->GW1_FILIAL+"4"+Space(TamSX3("GWM_CDESP")[1])+PadR((cAliasGW1)->GWU_CDTRP, TamSX3("GWM_CDTRP")[1])+Space(TamSX3("GWM_SERDOC")[1])+PadR((cAliasGW1)->GWF_NRCALC, TamSX3("GWM_NRDOC")[1]))
					While !GWM->(Eof()) .AND. ;
						  	GWM->GWM_FILIAL == (cAliasGW1)->GW1_FILIAL .AND. ;
						  	GWM->GWM_TPDOC == "4" .AND. ;
				         	GWM->GWM_CDESP == Space(TamSX3("GWM_CDESP")[1]) .AND. ;
				         	GWM->GWM_CDTRP == PadR((cAliasGW1)->GWU_CDTRP, TamSX3("GWM_CDTRP")[1]) .AND. ;
				         	GWM->GWM_SERDOC == Space(TamSX3("GWM_SERDOC")[1]) .AND. ;
				         	GWM->GWM_NRDOC == PadR((cAliasGW1)->GWF_NRCALC, TamSX3("GWM_NRDOC")[1])
				         	
				         	RecLock(cAliasGW1,.F.)
				         		(cAliasGW1)->TotalRatei += GWM->GWM_VLFRET
				         	(cAliasGW1)->(MsUnlock())
				     
				         GWM->( dbSkip() )
				   EndDo
				         	
				EndIf
		   ElseIf (cAliasGW1)->VlPrevist != 0
		   		
		   		dbSelectArea("GWM")
				dbSetOrder(1)
				If dbSeek((cAliasGW1)->GW1_FILIAL+"1"+Space(TamSX3("GWM_CDESP")[1])+PadR((cAliasGW1)->GWU_CDTRP, TamSX3("GWM_CDTRP")[1])+Space(TamSX3("GWM_SERDOC")[1])+PadR((cAliasGW1)->GWF_NRCALC, TamSX3("GWM_NRDOC")[1]))
					While !GWM->(Eof()) .AND. ;
						  	GWM->GWM_FILIAL == (cAliasGW1)->GW1_FILIAL .AND. ;
						  	GWM->GWM_TPDOC == "1" .AND. ;
				         	GWM->GWM_CDESP == Space(TamSX3("GWM_CDESP")[1]) .AND. ;
				         	GWM->GWM_CDTRP == PadR((cAliasGW1)->GWU_CDTRP, TamSX3("GWM_CDTRP")[1]) .AND. ;
				         	GWM->GWM_SERDOC == Space(TamSX3("GWM_SERDOC")[1]) .AND. ;
				         	GWM->GWM_NRDOC == PadR((cAliasGW1)->GWF_NRCALC, TamSX3("GWM_NRDOC")[1])
				         	
				         	RecLock(cAliasGW1,.F.)
				         		(cAliasGW1)->TotalRatei += GWM->GWM_VLFRET
				         	(cAliasGW1)->(MsUnlock())
				     
				         GWM->( dbSkip() )
				   EndDo
				         	
				EndIf
				
		   ElseIf (cAliasGW1)->VlRealRat != 0
		   	
		   		dbSelectArea("GW4")
				dbSetOrder(2) // GW4_FILIAL+GW4_EMISDC+GW4_SERDC+GW4_NRDC+GW4_TPDC
				If dbSeek((cAliasGW1)->GW1_FILIAL+(cAliasGW1)->GW1_EMISDC+(cAliasGW1)->GW1_SERDC+(cAliasGW1)->GW1_NRDC+(cAliasGW1)->GW1_CDTPDC)
					While !GW4->(Eof()) .AND. ;
					       GW4->GW4_FILIAL == (cAliasGW1)->GW1_FILIAL .AND. ;
					       GW4->GW4_EMISDC == (cAliasGW1)->GW1_EMISDC .AND. ;
					       GW4->GW4_SERDC  == (cAliasGW1)->GW1_SERDC  .AND. ;
					       GW4->GW4_NRDC   == (cAliasGW1)->GW1_NRDC   .AND. ;
					       GW4->GW4_TPDC   == (cAliasGW1)->GW1_CDTPDC
					       
					    dbSelectArea("GWF")
					    GWF->(dbSetOrder(1))
					    GWF->(dbSeek((cAliasGW1)->GW1_FILIAL+(cAliasGW1)->GWF_NRCALC))
					       
						dbSelectArea("GW3")
					   	dbSetOrder(1) // GW3_FILIAL+GW3_CDESP+GW3_EMISDF+GW3_SERDF+GW3_NRDF+DTOS(GW3_DTEMIS)
					  	If dbSeek(GW4->GW4_FILIAL + GW4->GW4_CDESP + GW4->GW4_EMISDF + GW4->GW4_SERDF + GW4->GW4_NRDF + DTOS(GW4->GW4_DTEMIS))
						  	While !GW3->( Eof() ) .And. ;
								  	GW4->GW4_FILIAL == GW3->GW3_FILIAL .And. ;
								  	GW4->GW4_CDESP == GW3->GW3_CDESP .And. ; 
								  	GW4->GW4_EMISDF == GW3->GW3_EMISDF .And. ;
								  	GW4->GW4_SERDF == GW3->GW3_SERDF .And. ;
								  	GW4->GW4_NRDF == GW3->GW3_NRDF .And. ;
								  	GW4->GW4_DTEMIS == GW3->GW3_DTEMIS
						  	
						  		If GWF->GWF_TPCALC == GW3->GW3_TPDF
						   		
							   		dbSelectArea("GWM")
									dbSetOrder(1)
									If dbSeek(GW3->GW3_FILIAL+"2"+GW3->GW3_CDESP+GW3->GW3_EMISDF+GW3->GW3_SERDF+GW3->GW3_NRDF+DTOS(GW3->GW3_DTEMIS))
										While !GWM->(Eof()) .AND. ;
											  	GWM->GWM_FILIAL == GW3->GW3_FILIAL .AND. ;
											  	GWM->GWM_TPDOC == "2" .AND. ;
									         	GWM->GWM_CDESP == GW3->GW3_CDESP .AND. ;
									         	GWM->GWM_CDTRP == GW3->GW3_EMISDF  .AND. ;
									         	GWM->GWM_SERDOC == GW3->GW3_SERDF .AND. ;
									         	GWM->GWM_NRDOC == GW3->GW3_NRDF .And. ;
									         	GWM->GWM_DTEMIS == GW3->GW3_DTEMIS
									         	
									         	RecLock(cAliasGW1,.F.)
									         		(cAliasGW1)->TotalRatei += GWM->GWM_VLFRET
									         	(cAliasGW1)->(MsUnlock())
									     
									         GWM->( dbSkip() )
									   EndDo
						         	
									EndIf
								EndIf
						  	
						  		GW3->( dbSkip() )
						  	EndDo

						EndIf
					GW4->(dbSkip())
					EndDo
				EndIf
				
		   EndIf

		(cAliasGW1)->(dbSkip())
	EndDo
		
Return

Static Function DescImpGWF(nValor)
	If GWF->GWF_CRDICM == '1'
		nValor  -= GWM->GWM_VLICMS
	EndIf
					        	
	If GWF->GWF_CRDPC == '1'
		nValor  -= (GWM->GWM_VLPIS + GWM->GWM_VLCOFI)
	EndIf
Return(nValor)

Static Function DescImpRec(nValor)
	If GWF->GWF_CRDICM == '1'
		nValor  -= GWF->GWF_ICMRET
	EndIf
					        	
Return(nValor)

Static Function DescImpGW3(nValor)
	
	If GW3->GW3_CRDICM == '1'
		nValor  -= GWM->GWM_VLICMS
	EndIf
					        	
	If GW3->GW3_CRDPC == '1'
		nValor  -= (GWM->GWM_VLPIS + GWM->GWM_VLCOFI)
	EndIf
Return(nValor)

Function A094Atualizar()
	SetRegua(3)
	IncRegua()
	CarregarDados()
	A094Filtro()
	IncRegua()
	oBrowseGW1:Refresh()
	IncRegua()
Return

Function GFEA094PAR()
	If Pergunte("GFEA094A",.T.)
		RptStatus({||A094Atualizar()}, "Carregando", "Aguarde, carregando dados...")
	EndIf
 Return

Function GFEA094VIS()
	Local aAreaGW1 := GW1->(GetArea())
	dbSelectArea("GW1")
	GW1->(dbSetOrder(1))
	If GW1->(dbSeek((cAliasGW1)->(GW1_FILIAL+GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC)))
		FwExecView('Visualizar','GFEC040',,,{||.T.})	
		RestArea(aAreaGW1)
	Else
		MsgInfo("Documento não localizado")
	EndIf
Return

Function A094Filtro()
	Local lDiverg
	(cAliasGW1)->(dbGoTop())	
	Pergunte("GFEA094A",.F.)
	While !(cAliasGW1)->(Eof())
		
		Do Case
			Case MV_PAR05 == 5 .And. ((cAliasGW1)->Estimado > 0 .Or. (cAliasGW1)->Calculado > 0 .Or. (cAliasGW1)->Realizado > 0) 
				RecLock(cAliasGW1,.F.)
				(cAliasGW1)->(dbDelete())
				(cAliasGW1)->(MsUnLock(cAliasGW1))
			Case MV_PAR05 == 4 .And. (cAliasGW1)->Realizado > 0 
				RecLock(cAliasGW1,.F.)
				(cAliasGW1)->(dbDelete())
				(cAliasGW1)->(MsUnLock(cAliasGW1))
			Case MV_PAR05 == 3 .And. ((cAliasGW1)->Calculado == 0 .Or. (cAliasGW1)->Realizado > 0)
				RecLock(cAliasGW1,.F.)
				(cAliasGW1)->(dbDelete())
				(cAliasGW1)->(MsUnLock(cAliasGW1))
			Case MV_PAR05 == 2 .And. ((cAliasGW1)->Estimado == 0 .Or. (cAliasGW1)->Calculado > 0 .Or. (cAliasGW1)->Realizado > 0) 
				RecLock(cAliasGW1,.F.)
				(cAliasGW1)->(dbDelete())
				(cAliasGW1)->(MsUnLock(cAliasGW1))				
		EndCase
		
		If (cAliasGW1)->Realizado > 0
			lDiverg := !((cAliasGW1)->VlRealRat == (cAliasGW1)->LctoDespe2)
		ElseIf (cAliasGW1)->Calculado > 0
			lDiverg := !((cAliasGW1)->VlPrevist == (cAliasGW1)->LctoDespe)
		ElseIf (cAliasGW1)->Estimado  > 0 
			lDiverg := !((cAliasGW1)->VlEstim   == (cAliasGW1)->LctoDespe3)
		Else
			lDiverg := .T.
		EndIf
		Do Case
			Case MV_PAR06 == 2 .And. !lDiverg
				
				RecLock(cAliasGW1,.F.)
				(cAliasGW1)->(dbDelete())
				(cAliasGW1)->(MsUnLock())
			Case MV_PAR06 == 3 .And. lDiverg
				RecLock(cAliasGW1,.F.)
				(cAliasGW1)->(dbDelete())
				(cAliasGW1)->(MsUnLock(cAliasGW1))
		EndCase
		
		(cAliasGW1)->(dbSkip())
	EndDo
Return

//Abre a tela de dados de provisão de frete
Function GFEA094PRV()
	Local aAreaGW1 := GW1->(GetArea())
	dbSelectArea("GW1")
	GW1->(dbSetOrder(1))
	If GW1->(dbSeek((cAliasGW1)->(GW1_FILIAL+GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC)))
		GFEA094A()
		RestArea(aAreaGW1)
	Else
		MsgInfo("Documento não localizado")
	EndIf
Return

//Estima frete posicionado se for o caso
Function GFEA094EST()
	Local lCalc := .F.
	If !(cAliasGW1)->(Eof())
		If (cAliasGW1)->Realizado > 0
			MsgStop("Documento de carga já possuí frete realizado.")
		ElseIf(cAliasGW1)->Calculado > 0
			MsgStop("Documento de carga já possuí cálculo de frete.")
		ElseIf(cAliasGW1)->Estimado > 0
			If MsgYesNo("O documento de carga já possui uma estimativa de frete. Deseja recalcular?")
				lCalc := .T.
			EndIf
		Else
			lCalc := .T.
		EndIf
		If lCalc
			RptStatus({||GFEA094PRO()}, "Aguarde", "Estimando valor do frete")
		EndIf
	EndIf
Return

Function GFEA094PRO()
	Local nCalc := 0
	Local nDesp := 0
	Local nTamCDESP := TamSx3("GWA_CDESP")[1]
	Local nTamSERIE := TamSx3("GWA_SERIE")[1]
	Local nValFret := 0
	
	nValFret := A088CLCEST((cAliasGW1)->GW1_FILIAL, (cAliasGW1)->GW1_CDTPDC, (cAliasGW1)->GW1_EMISDC, (cAliasGW1)->GW1_SERDC, (cAliasGW1)->GW1_NRDC)
	Pergunte("GFEA094A",.F.)
	dbSelectArea("GWA")
	GWA->(dbSetOrder(1))
	dbSelectArea("GWF")
	GWF->(dbSetOrder(1))
	dbSelectArea("GWM")
	GWM->(dbSetOrder(2))
	GWM->(dbSeek((cAliasGW1)->(GW1_FILIAL+GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC)))
	While !GWM->(Eof()) .And. (cAliasGW1)->(GW1_FILIAL+GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC) == GWM->(GWM_FILIAL+GWM_CDTPDC+GWM_EMISDC+GWM_SERDC+GWM_NRDC)
		If DTOS(GWM->GWM_DTEMIS) >= DTOS(MV_PAR03) .And. DTOS(GWM->GWM_DTEMIS) <= DTOS(MV_PAR04) .And. GWM->GWM_TPDOC == '4'
			If GWF->(dbSeek(GWM->GWM_FILIAL+GWM->GWM_NRDOC)) .And. DTOS(GWF->GWF_DTCRIA) >= DTOS(MV_PAR03) .And. DTOS(GWF->GWF_DTCRIA) <= DTOS(MV_PAR04) .And. GWF->GWF_TPCALC == '8' .And. GWF->GWF_TRANSP == GWM->GWM_CDTRP
				nCalc += GWM->GWM_VLFRET - If(GWF->GWF_CRDICM == '1',GWM->GWM_VLICMS,0) - If(GWF->GWF_CRDPC == '1',GWM->GWM_VLPIS+GWM->GWM_VLCOFI,0)
				
				//GWA_FILIAL+GWA_TPDOC+GWA_CDESP+GWA_CDEMIT+GWA_SERIE+GWA_NRDOC+DTOS(GWA_DTEMIS)+GWA_CDTRAN+GWA_SEQ
				If GWA->(dbSeek(GWF->GWF_FILIAL + '4' + Space(nTamCDESP) + GWF->GWF_TRANSP + Space(nTamSERIE) + GWF->GWF_NRCALC))
					nDesp += GWM->GWM_VLFRET - If(GWF->GWF_CRDICM == '1',GWM->GWM_VLICMS,0) - If(GWF->GWF_CRDPC == '1',GWM->GWM_VLPIS+GWM->GWM_VLCOFI,0)
				EndIf
			EndIf
		EndIf
		GWM->(dbSkip())
	EndDo
	RecLock(cAliasGW1,.F.)
	(cAliasGW1)->VlEstim := nCalc
	(cAliasGW1)->LctoDespe3 := nDesp
	If nValFret != 0
		(cAliasGW1)->Estimado := 1
	EndIf
	MsUnLock(cAliasGW1)
Return

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

Function GFEA094FDC()

	Local oFilter  := FWFilter():New(oBrowseGW1:GetOwner())
	Local aFields  := {}

	AAdd(aFields, {"(cAliasGW1)->Realizado", "Realizado", "N", 16, 0})
	AAdd(aFields, {"(cAliasGW1)->Calculado", "Calculado", "N", 16, 0})
	AAdd(aFields, {"(cAliasGW1)->Estimado", "Estimado", "N", 16, 0})
	
	oFilter:SetAlias(cAliasGW1)
	oFilter:SetField(aFields)
	oFilter:SetExecute({|| cFil94 := oFilter:GetExprAdvPL(), CarregaFiltro() })
	oFilter:DisableValid(.F.)
	oFilter:CleanFilter(.F.)
	oFilter:DisableAdd(.T.)
	oFilter:DisableDel(.T.)
		
	//Filtros
	AAdd(oFilter:aCheckFil, .T.)
	AAdd(oFilter:aFilter, {"Realizado", "(cAliasGW1)->Realizado > 0",, {}, .F., .F., .F.,,})
	
	AAdd(oFilter:aCheckFil, .T.)
	AAdd(oFilter:aFilter, {"Calculado", "(cAliasGW1)->Calculado > 0",, {}, .F., .F., .F.,,})
	
	AAdd(oFilter:aCheckFil, .T.)
	AAdd(oFilter:aFilter, {"Estimado", "(cAliasGW1)->Estimado > 0",, {}, .F., .F., .F.,,})
	
	AAdd(oFilter:aCheckFil, .T.)
	AAdd(oFilter:aFilter, {"Sem cálculo", "(cAliasGW1)->Estimado == 0 .And. (cAliasGW1)->Calculado == 0 .And. (cAliasGW1)->Realizado == 0 ",, {}, .F., .F., .F.,,})

	oFilter:LoadFilter()

	oFilter:Activate()

Return

Function CarregaFiltro()

	CarregarDados()

	dbSelectArea(cAliasGW1)
	dbGoTop()
	//Apaga do filtro os regitros que não estão relacionados.
	While !(cAliasGW1)->(Eof())
		//filtro   
		If IIf(Empty(cFil94), .T., &(cFil94))
			(cAliasGW1)->(dbSkip())
		Else
			RecLock(cAliasGW1, .F.)
				(cAliasGW1)->( dbDelete() )
			(cAliasGW1)->( MSUnlock() )
			(cAliasGW1)->(dbSkip())
		EndIf
	EndDo
	
Return
