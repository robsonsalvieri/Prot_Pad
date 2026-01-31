#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

Static oTempTable := Nil

/*/ GFEA094
@author siegklenes.beulke
@since 03/01/2013
@version 1.0		

@description
Monitor Contabil
/*/
Function GFEA094() 
	Local aCoors := FWGetDialogSize(oMainWnd)

	Private cRealizado	:= "REALIZADO  > 0"
	Private cCalculado	:= "CALCULADO  > 0"
	Private cEstimado	:= "ESTIMADO   > 0"
	Private cSemCalc	:= "SEMCALCULO > 0"
	Private cSemDiverg	:=	" Iif(REALIZADO > 0, VLREALIZA == LCTODESPE2, " +;
							" Iif(CALCULADO > 0, VLCALCUL  == LCTODESPE , " +;
							" Iif(ESTIMADO  > 0, VLESTIM   == LCTODESPE3, .T.)))"
	Private cComDiverg	:=	" Iif(VLREALIZA > 0, VLREALIZA <> LCTODESPE2, " +;
							" Iif(VLCALCUL  > 0, VLCALCUL  <> LCTODESPE , " +;
							" Iif(VLESTIM   > 0, VLESTIM   <> LCTODESPE3, .F.)))"
	Private lSDGW1		:= TamSX3("GW1_SERDC")[1] == 14
	Private oFWLayer, oPanelUp
	Private oBrowseGW1
	Private oDlg
	Private aFieldsGW1
	Private cAliasGW1
	Private aNotaReal
	Private aNotaCalc
	Private aNotaEstim
	Private aNotaSemCalc
	Private aStructGW1 := {}

	Pergunte("GFEA094A",.F.)

	If Type("MV_PAR10") <> "N"
		MsgAlert("O grupo de perguntas da rotina está desatualizado.","GFEA064A")
		Return
	EndIf

	If !Pergunte("GFEA094A",.T.)
		Return
	EndIf

	Define MsDialog oDlg Title 'Monitor Contábil' From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
	
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDlg, .F., .T.)
	
	oFWLayer:AddLine('UP',100,.F.)
	oFWLayer:AddCollumn('ALL',100,.T.,'UP')	
	oPanelUp := oFWLayer:GetColPanel('ALL','UP')
	
	oDlg:Activate(,,,.T.,,,{||RptStatus({||Iniciar()}, "Carregando", "Aguarde, carregando dados...")})
	
	GFEDelTab(cAliasGW1)
	oTempTable := Nil

Return Nil

Static Function MenuDef()
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE "Visualizar"	 	ACTION "GFEA094VIS()" OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Dados Provisão" 	ACTION "GFEA094PRV()" OPERATION 13 ACCESS 0
	ADD OPTION aRotina TITLE "Parâmetros" 		ACTION "GFEA094PAR()" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Estimar Frete"	ACTION "GFEA094EST()" OPERATION 4 ACCESS 0
	
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
	{"Tipo Doc. Carga"		,"GW1_CDTPDC"	,	"C", 05,0,/*cpicture*/,1,3,.T.},;
	{"Emissor Doc. Carga"	,"GW1_EMISDC"	,	"C", TamSX3("GW1_EMISDC")[1],0,/*cpicture*/,1,3,.T.},;
	{"Série Doc. Carga"		,"GW1_SERDC"	,	"C", nTamSer,0,PESQPICT("GW1","GW1_SERDC"),1,3,.T.},;
	{"Número Doc. Carga"	,"GW1_NRDC"		,	"C", 16,0,/*cpicture*/,1,8,.T.},;
	{"Data Emissão"			,"GW1_DTEMIS"	,	"D", 8,0,,,,.T.},;
	{"Valor Doc. Carga"		,"GW8_VALOR"	,	"N", nTamVlr1,nTamVlr2,cPic,1,6,.T.},;
	{"Tipo Frete"			,"GW1_TPFRET"	,	"C", 20,0,/*cpicture*/,1,8,.T.,{||GetStrCbox(GetSx3Inf("GW1_TPFRET")[2],AllTrim((cAliasGW1)->GW1_TPFRET))}},;
	{"Valor Estimado"		,"VLESTIM"		,	"N", nTamVlr1,nTamVlr2,cPic,1,6,.T.},;
	{"Valor Previsto"		,"VLCALCUL"		,	"N", nTamVlr1,nTamVlr2,cPic,1,6,.T.},;
	{"Valor Realizado"		,"VLREALIZA"  	,	"N", nTamVlr1,nTamVlr2,cPic,1,6,.T.},;
	{"Lançamento Despesa"	,"LCTODESPE"	,	"N", nTamVlr1,nTamVlr2,cPic,1,6,.T.,{||If ((cAliasGW1)->VLREALIZA > 0, (cAliasGW1)->LCTODESPE2, If ((cAliasGW1)->VLCALCUL > 0,(cAliasGW1)->LCTODESPE,(cAliasGW1)->LCTODESPE3))}},;
	{"Lançamento Despesa"	,"LCTODESPE2"	,	"N", nTamVlr1,nTamVlr2,cPic,1,6,.F.},;
	{"Lançamento Despesa"	,"LCTODESPE3"	,	"N", nTamVlr1,nTamVlr2,cPic,1,6,.F.},;
	{"Estimado"				,"ESTIMADO"		,	"N", 1,0,,,,.F.},;
	{"Calculado"			,"CALCULADO"	,	"N", 1,0,,,,.F.},;
	{"Realizado"			,"REALIZADO"	,	"N", 1,0,,,,.F.},;
	{"Sem Cálculo"			,"SEMCALCULO"	,	"N", 1,0,,,,.F.},;
	{"Cód. Transportador"	,"GWM_CDTRP"	,	"C", TamSX3("GW1_EMISDC")[1],0,/*cpicture*/,1,8,.T.},;
	{"Nome Transportador"	,"GWU_NMTRP"	,	"C", TamSx3("GU3_NMEMIT")[1],0,/*cpicture*/,1,8,.T.},;
	{"Número Cálculo"		,"GWF_NRCALC"	,	"C", TamSX3("GWF_NRCALC")[1],0,,1,8,.T.},;
	{"Último Lote Provisão"	,"GXD_CODLOT"	,	"C", TamSX3("GXD_CODLOT")[1],0,,1,8,.T.},;
	{"Todos os Lotes"		,"GXD_OUTLOT"	,	"C", 50,0,,1,8,.T.},;
	{"Número Doc. Frete"	,"NRDOCFRETE"	,	"C", 50,0,,1,8,.T.};
	}
	
	aIndGW1 := {"GW1_FILIAL+GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC"}
	cAliasGW1 := CriaTab(aFieldsGW1, aIndGW1,@aStructGW1)
	
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
	
	oBrowseGW1:AddLegend(cRealizado,"GREEN" , "Realizado"       ,"1")
	oBrowseGW1:AddLegend(cCalculado,"BLUE"  , "Calculado"       ,"1")
	oBrowseGW1:AddLegend(cEstimado ,"YELLOW", "Estimado"        ,"1")
	oBrowseGW1:AddLegend(cSemCalc  ,"WHITE" , "Sem Cálculo"     ,"1")
	oBrowseGW1:AddLegend(cSemDiverg,"GREEN" , "Sem Divergências","2")
	oBrowseGW1:AddLegend(cComDiverg,"RED"   , "Com Divergências","2")
	
	oBrowseGW1:SetFields(GetFields(aFieldsGW1, "cAliasGW1"))

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
	
	cAlias := GFECriaTab({aStruct,aIndices},@oTempTable)
Return cAlias

Static Function CarregarDados(lChange)
	Local cQuery     := ""
	Local lCalcEstim := MV_PAR05 == 1
	Local lCalcRoman := MV_PAR06 == 1
	Local lCalcOcorr := MV_PAR07 == 1
	Local lRealizado := MV_PAR08 == 1
	Local lSemCalc   := MV_PAR09 == 1
	Local cTipoCalc  := ""
	Local cOpcContab := SuperGetMv('MV_DSCTB',, '1')  // Opção de contabilização por: 1 - Fatura ou 2 - Documento de Frete
	Local cERPGFE    := SuperGetMv('MV_ERPGFE',, '1') // ERP integrado ao GFE: 1 - Datasul 2 - Protheus, 3 - RM ou 4 - Logix
	Local cProvCon   := SuperGetMV("MV_PROVCON",, "1")
	Local cFunStrAgg := Iif(AllTrim(Upper(TcGetDb())) == "ORACLE","LISTAGG","STRING_AGG")
	
	Private dDataIni := MV_PAR03
	Private dDataFim := MV_PAR04
	
	Default lChange := .T.

	If !lCalcEstim .And. !lCalcRoman .And. !lCalcOcorr .And. !lRealizado .And. !lSemCalc
		MsgAlert("Não foi selecionado nenhum tipo de cálculo. Favor selecionar ao menos um dos tipos: Estimado, Romaneio, Ocorrências, Realizado ou Sem Cálculo.")
		Return
	EndIf

	cStatement := "DELETE FROM "+oTempTable:GetRealName()
	// Executa o comando no banco
	If TcSqlExec(cStatement) < 0
		MsgStop("Erro ao tentar limpar a tabela temporária: " + CRLF + TCSqlError())
	EndIf

	If lCalcEstim
		cTipoCalc += "'8'"
	EndIf

	If lCalcRoman
		cTipoCalc += Iif(!Empty(cTipoCalc),",","") + "'1','6'"
	EndIf

	If lCalcOcorr
		cTipoCalc += Iif(!Empty(cTipoCalc),",","") + "'4','5','7'"
	EndIf

	cQuery := "SELECT GW1_FILIAL,"
	cQuery +=       " GW1_CDTPDC,"
	cQuery +=       " GW1_EMISDC,"
	cQuery +=       " GW1_SERDC,"
	cQuery +=       " GW1_NRDC,"
	cQuery +=       " GW1_DTEMIS,"
    cQuery +=       " (SELECT SUM(GW8.GW8_VALOR) AS GW8_VALOR"
	cQuery +=          " FROM "+RetSqlName("GW8")+" GW8"
    cQuery +=         " WHERE GW8.GW8_FILIAL = TBL.GW1_FILIAL"
    cQuery +=           " AND GW8.GW8_CDTPDC = TBL.GW1_CDTPDC"
    cQuery +=           " AND GW8.GW8_EMISDC = TBL.GW1_EMISDC"
    cQuery +=           " AND GW8.GW8_SERDC  = TBL.GW1_SERDC"
    cQuery +=           " AND GW8.GW8_NRDC   = TBL.GW1_NRDC"
    cQuery +=           " AND GW8.D_E_L_E_T_ = ' ') GW8_VALOR,"
	cQuery +=       " GW1_TPFRET,"
	cQuery +=       " ROUND(CASE WHEN SUM(REALIZADO) > 0 OR SUM(CALCULADO) > 0 THEN 0 ELSE SUM(VLESTIM) END,2) AS VLESTIM,"
	cQuery +=       " ROUND(CASE WHEN SUM(REALIZADO) > 0 THEN 0 ELSE SUM(VLCALCUL) END,2) AS VLCALCUL,"
	cQuery +=       " ROUND(SUM(VLREALIZA ),2) AS VLREALIZA,"
	cQuery +=       " ROUND(SUM(LCTODESPE ),2) AS LCTODESPE,"
	cQuery +=       " ROUND(SUM(LCTODESPE2),2) AS LCTODESPE2,"
	cQuery +=       " ROUND(SUM(LCTODESPE3),2) AS LCTODESPE3,"
	cQuery +=       " CASE WHEN SUM(ESTIMADO)   > 0 THEN 1 ELSE 0 END ESTIMADO,"
	cQuery +=       " CASE WHEN SUM(CALCULADO)  > 0 THEN 1 ELSE 0 END CALCULADO,"
	cQuery +=       " CASE WHEN SUM(REALIZADO)  > 0 THEN 1 ELSE 0 END REALIZADO,"
	cQuery +=       " CASE WHEN SUM(SEMCALCULO) > 0 THEN 1 ELSE 0 END SEMCALCULO,"
	cQuery +=       " GWM_CDTRP,"
	cQuery +=       " GU3_NMEMIT      AS GWU_NMTRP,"
	cQuery +=       " MAX(GWF_NRCALC) AS GWF_NRCALC,"
	cQuery +=       " MAX(GXD_CODLOT) AS GXD_CODLOT,"
	cQuery +=       " MAX(GXD_OUTLOT) AS GXD_OUTLOT,"
	cQuery +=       " MAX(NRDOCFRETE) AS NRDOCFRETE"
	cQuery += " FROM ("

	If lCalcEstim

		cQuery += "SELECT GW1_FILIAL,"
		cQuery +=       " GW1_CDTPDC,"
		cQuery +=       " GW1_EMISDC,"
		cQuery +=       " GW1_SERDC,"
		cQuery +=       " GW1_NRDC,"
		cQuery +=       " GW1_DTEMIS,"
		cQuery +=       " GW1_TPFRET,"
		cQuery +=       " SUM(GWM_VLFRET) AS VLESTIM,"
		cQuery +=       " 0 AS VLCALCUL,"
		cQuery +=       " 0 AS VLREALIZA,"
		cQuery +=       " 0 AS LCTODESPE,"
		cQuery +=       " 0 AS LCTODESPE2,"
		cQuery +=       " SUM(GWA_VLMOV)  AS LCTODESPE3,"
		cQuery +=       " 1 AS ESTIMADO,"
		cQuery +=       " 0 AS CALCULADO,"
		cQuery +=       " 0 AS REALIZADO,"
		cQuery +=       " 0 AS SEMCALCULO,"
		cQuery +=       " GWM_CDTRP,"
		cQuery +=       " ' ' AS NRDOCFRETE,"
		cQuery +=       " GWF_NRCALC,"
		cQuery +=       " GXD_CODLOT,"
		cQuery +=       " GXD_OUTLOT"
		cQuery +=  " FROM ("+QryGWM(MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,"4")+") AS GWM"
		cQuery += " INNER JOIN "+RetSqlName("GW1")+" GW1"
		cQuery +=    " ON GW1.GW1_FILIAL = GWM.GWM_FILIAL"
		cQuery +=   " AND GW1.GW1_CDTPDC = GWM.GWM_CDTPDC"
		cQuery +=   " AND GW1.GW1_EMISDC = GWM.GWM_EMISDC"
		cQuery +=   " AND GW1.GW1_SERDC  = GWM.GWM_SERDC"
		cQuery +=   " AND GW1.GW1_NRDC   = GWM.GWM_NRDC"
		cQuery +=   " AND GW1.GW1_SIT NOT IN ('2','7','8')"
		cQuery +=   " AND GW1.D_E_L_E_T_ = ' '"
		cQuery += " INNER JOIN "+RetSqlName("GWF")+" GWF"
		cQuery +=    " ON GWF.GWF_FILIAL = GWM.GWM_FILIAL"
		cQuery +=   " AND GWF.GWF_NRCALC = GWM.GWM_NRDOC"
		// Otimização, caso as datas de/até sejam iguais
		If MV_PAR03 == MV_PAR04
			cQuery += " AND GWF.GWF_DTCRIA = '"+DtoS(MV_PAR03)+"'"
		Else
			cQuery += " AND GWF.GWF_DTCRIA >= '"+DtoS(MV_PAR03)+"'"
			cQuery += " AND GWF.GWF_DTCRIA <= '"+DtoS(MV_PAR04)+"'"
		EndIf
		cQuery +=   " AND GWF.GWF_TPCALC = '8'" // Estimativa
		cQuery +=   " AND GWF.D_E_L_E_T_ = ' '"
		cQuery +=  " LEFT JOIN (SELECT GWA_FILIAL,"
		cQuery +=                    " GWA_CDEMIT,"
		cQuery +=                    " GWA_NRDOC,"
		cQuery +=                    " SUM(CASE WHEN GWA_CDTRAN IN ('300'"+If(cProvCon $ "1;4",",'301','302','303'","")+") THEN GWA_VLMOV ELSE 0 END) AS GWA_VLMOV"
		cQuery +=             " FROM "+RetSqlName("GWA")+" GWA"
		cQuery +=            " WHERE "
		// Otimização, caso as filiais de/até sejam iguais
		If MV_PAR01 == MV_PAR02
			cQuery +=                " GWA.GWA_FILIAL = '"+MV_PAR01+"'"
		Else
			cQuery +=                " GWA.GWA_FILIAL >= '"+MV_PAR01+"'"
			cQuery +=            " AND GWA.GWA_FILIAL <= '"+MV_PAR02+"'"
		EndIf
		cQuery +=                " AND GWA.GWA_TPDOC  = '4'"
		cQuery +=                " AND GWA.GWA_CDESP  = ' '"
		cQuery +=                " AND GWA.GWA_SERIE  = ' '"
		cQuery +=                " AND GWA.D_E_L_E_T_ = ' '"
		cQuery +=              " GROUP BY "
		cQuery +=                    " GWA_FILIAL,"
		cQuery +=                    " GWA_CDEMIT,"
		cQuery +=                    " GWA_NRDOC) AS GWA"
		cQuery +=    " ON GWA.GWA_FILIAL = GWF.GWF_FILIAL"
		cQuery +=   " AND GWA.GWA_CDEMIT = GWF.GWF_TRANSP"
		cQuery +=   " AND GWA.GWA_NRDOC  = GWF.GWF_NRCALC"
		cQuery +=  " LEFT JOIN (SELECT GXD_FILCAL,"
		cQuery +=                    " GXD_NRCALC,"
		cQuery +=                    " MAX(GXD_CODLOT)             AS GXD_CODLOT,"
		cQuery +=                    " "+cFunStrAgg+"(GXD_CODLOT,', ') AS GXD_OUTLOT"
		cQuery +=               " FROM "+RetSqlName("GXD")+" GXD"
		cQuery +=              " WHERE "
		// Otimização, caso as filiais de/até sejam iguais
		If MV_PAR01 == MV_PAR02
			cQuery +=                " GXD.GXD_FILCAL = '"+MV_PAR01+"'"
		Else
			cQuery +=                " GXD.GXD_FILCAL >= '"+MV_PAR01+"'"
			cQuery +=            " AND GXD.GXD_FILCAL <= '"+MV_PAR02+"'"
		EndIf
		cQuery +=                " AND GXD.D_E_L_E_T_ = ' '"
		cQuery +=              " GROUP BY"
		cQuery +=                    " GXD_FILCAL,"
		cQuery +=                    " GXD_NRCALC) LOT"
		cQuery +=    " ON LOT.GXD_FILCAL = GWM.GWM_FILIAL"
		cQuery +=   " AND LOT.GXD_NRCALC = GWM.GWM_NRDOC"
		cQuery += " GROUP BY "
		cQuery +=       " GW1_FILIAL,"
		cQuery +=       " GW1_CDTPDC,"
		cQuery +=       " GW1_EMISDC,"
		cQuery +=       " GW1_SERDC,"
		cQuery +=       " GW1_NRDC,"
		cQuery +=       " GW1_DTEMIS,"
		cQuery +=       " GW1_TPFRET,"
		cQuery +=       " GWM_CDTRP,"
		cQuery +=       " GWF_NRCALC,"
		cQuery +=       " GWF_TPCALC,"
		cQuery +=       " GXD_CODLOT,"
		cQuery +=       " GXD_OUTLOT"

	EndIf

	If lCalcRoman .Or. lCalcOcorr

		If lCalcEstim
			cQuery += " UNION ALL "
		EndIf

		cQuery += "SELECT GW1_FILIAL,"
		cQuery +=       " GW1_CDTPDC,"
		cQuery +=       " GW1_EMISDC,"
		cQuery +=       " GW1_SERDC,"
		cQuery +=       " GW1_NRDC,"
		cQuery +=       " GW1_DTEMIS,"
		cQuery +=       " GW1_TPFRET,"
		cQuery +=       " 0 AS VLESTIM,"
		cQuery +=       " SUM(GWM_VLFRET) AS VLCALCUL,"
		cQuery +=       " 0 AS VLREALIZA,"
		cQuery +=       " SUM(GWA_VLMOV)  AS LCTODESPE,"
		cQuery +=       " 0 AS LCTODESPE2,"
		cQuery +=       " 0 AS LCTODESPE3,"
		cQuery +=       " 0 AS ESTIMADO,"
		cQuery +=       " 1 AS CALCULADO,"
		cQuery +=       " 0 AS REALIZADO,"
		cQuery +=       " 0 AS SEMCALCULO,"
		cQuery +=       " GWM_CDTRP,"
		cQuery +=       " ' ' AS NRDOCFRETE,"
		cQuery +=       " GWF_NRCALC,"
		cQuery +=       " GXD_CODLOT,"
		cQuery +=       " GXD_OUTLOT"
		cQuery +=  " FROM ("+QryGWM(MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,"1")+") AS GWM"
		cQuery += " INNER JOIN "+RetSqlName("GW1")+" GW1"
		cQuery +=    " ON GW1.GW1_FILIAL = GWM.GWM_FILIAL"
		cQuery +=   " AND GW1.GW1_CDTPDC = GWM.GWM_CDTPDC"
		cQuery +=   " AND GW1.GW1_EMISDC = GWM.GWM_EMISDC"
		cQuery +=   " AND GW1.GW1_SERDC  = GWM.GWM_SERDC"
		cQuery +=   " AND GW1.GW1_NRDC   = GWM.GWM_NRDC"
		cQuery +=   " AND GW1.GW1_SIT NOT IN ('2','7','8')"
		cQuery +=   " AND GW1.D_E_L_E_T_ = ' '"
		cQuery += " INNER JOIN "+RetSqlName("GWF")+" GWF"
		cQuery +=    " ON GWF.GWF_FILIAL = GWM.GWM_FILIAL"
		cQuery +=   " AND GWF.GWF_NRCALC = GWM.GWM_NRDOC"
		// Otimização, caso as datas de/até sejam iguais
		If MV_PAR03 == MV_PAR04
			cQuery += " AND GWF.GWF_DTCRIA = '"+DtoS(MV_PAR03)+"'"
		Else
			cQuery += " AND GWF.GWF_DTCRIA >= '"+DtoS(MV_PAR03)+"'"
			cQuery += " AND GWF.GWF_DTCRIA <= '"+DtoS(MV_PAR04)+"'"
		EndIf
		cQuery +=   " AND GWF.GWF_TPCALC IN ("+cTipoCalc+")"
		cQuery +=   " AND GWF.D_E_L_E_T_ = ' '"
		cQuery +=  " LEFT JOIN (SELECT GWA_FILIAL,"
		cQuery +=                    " GWA_CDEMIT,"
		cQuery +=                    " GWA_NRDOC,"
		cQuery +=                    " SUM(CASE WHEN GWA_CDTRAN IN ('300'"+If(cProvCon $ "1;4",",'301','302','303'","")+") THEN GWA_VLMOV ELSE 0 END) AS GWA_VLMOV"
		cQuery +=             " FROM "+RetSqlName("GWA")+" GWA"
		cQuery +=            " WHERE "
		// Otimização, caso as filiais de/até sejam iguais
		If MV_PAR01 == MV_PAR02
			cQuery +=                " GWA.GWA_FILIAL = '"+MV_PAR01+"'"
		Else
			cQuery +=                " GWA.GWA_FILIAL >= '"+MV_PAR01+"'"
			cQuery +=            " AND GWA.GWA_FILIAL <= '"+MV_PAR02+"'"
		EndIf
		cQuery +=                " AND GWA.GWA_TPDOC  = '1'"
		cQuery +=                " AND GWA.GWA_CDESP  = ' '"
		cQuery +=                " AND GWA.GWA_SERIE  = ' '"
		cQuery +=                " AND GWA.D_E_L_E_T_ = ' '"
		cQuery +=              " GROUP BY "
		cQuery +=                    " GWA_FILIAL,"
		cQuery +=                    " GWA_CDEMIT,"
		cQuery +=                    " GWA_NRDOC) AS GWA"
		cQuery +=    " ON GWA.GWA_FILIAL = GWF.GWF_FILIAL"
		cQuery +=   " AND GWA.GWA_CDEMIT = GWF.GWF_TRANSP"
		cQuery +=   " AND GWA.GWA_NRDOC  = GWF.GWF_NRCALC"
		cQuery +=  " LEFT JOIN (SELECT GXD_FILCAL,"
		cQuery +=                    " GXD_NRCALC,"
		cQuery +=                    " MAX(GXD_CODLOT)             AS GXD_CODLOT,"
		cQuery +=                    " "+cFunStrAgg+"(GXD_CODLOT,', ') AS GXD_OUTLOT"
		cQuery +=               " FROM "+RetSqlName("GXD")+" GXD"
		cQuery +=              " WHERE "
			If MV_PAR01 == MV_PAR02
			cQuery +=                " GXD.GXD_FILCAL = '"+MV_PAR01+"'"
		Else
			cQuery +=                " GXD.GXD_FILCAL >= '"+MV_PAR01+"'"
			cQuery +=            " AND GXD.GXD_FILCAL <= '"+MV_PAR02+"'"
		EndIf
		cQuery +=                " AND GXD.D_E_L_E_T_ = ' '"
		cQuery +=              " GROUP BY"
		cQuery +=                    " GXD_FILCAL,"
		cQuery +=                    " GXD_NRCALC) LOT"
		cQuery +=    " ON LOT.GXD_FILCAL = GWM.GWM_FILIAL"
		cQuery +=   " AND LOT.GXD_NRCALC = GWM.GWM_NRDOC"
		cQuery += " GROUP BY "
		cQuery +=       " GW1_FILIAL,"
		cQuery +=       " GW1_CDTPDC,"
		cQuery +=       " GW1_EMISDC,"
		cQuery +=       " GW1_SERDC,"
		cQuery +=       " GW1_NRDC,"
		cQuery +=       " GW1_DTEMIS,"
		cQuery +=       " GW1_TPFRET,"
		cQuery +=       " GWM_CDTRP,"
		cQuery +=       " GWF_NRCALC,"
		cQuery +=       " GWF_TPCALC,"
		cQuery +=       " GXD_CODLOT,"
		cQuery +=       " GXD_OUTLOT"

	EndIf

	If lRealizado

		If lCalcEstim .Or. lCalcRoman .Or. lCalcOcorr
			cQuery += " UNION ALL "
		EndIf

		cQuery += "SELECT GW1_FILIAL,"
		cQuery +=       " GW1_CDTPDC,"
		cQuery +=       " GW1_EMISDC,"
		cQuery +=       " GW1_SERDC,"
		cQuery +=       " GW1_NRDC,"
		cQuery +=       " GW1_DTEMIS,"
		cQuery +=       " GW1_TPFRET,"
		cQuery +=       " 0 AS VLESTIM,"
		cQuery +=       " 0 AS VLCALCUL,"
		cQuery +=       " SUM(GWM_VLFRET) AS VLREALIZA,"
		cQuery +=       " 0 AS LCTODESPE,"
		cQuery +=       " 0 AS LCTODESPE2,"
		cQuery +=       " CASE WHEN GW9_NRCONT <> NULL THEN SUM(GWM_VLFRET) ELSE 0 END LCTODESPE3,"
		cQuery +=       " 0 AS ESTIMADO,"
		cQuery +=       " 0 AS CALCULADO,"
		cQuery +=       " 1 AS REALIZADO,"
		cQuery +=       " 0 AS SEMCALCULO,"
		cQuery +=       " GWM_CDTRP,"
		cQuery +=       " ' ' AS NRDOCFRETE,"
		cQuery +=       " ' ' AS GWF_NRCALC,"
		cQuery +=       " ' ' AS GXD_CODLOT,"
		cQuery +=       " ' ' AS GXD_OUTLOT"
		cQuery +=  " FROM ("+QryGWM(MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,"3")+") AS GWM"
		cQuery +=  " INNER JOIN "+RetSqlName("GW1")+" GW1"
		cQuery +=     " ON GW1.GW1_FILIAL = GWM.GWM_FILIAL"
		cQuery +=    " AND GW1.GW1_CDTPDC = GWM.GWM_CDTPDC"
		cQuery +=    " AND GW1.GW1_EMISDC = GWM.GWM_EMISDC"
		cQuery +=    " AND GW1.GW1_SERDC  = GWM.GWM_SERDC"
		cQuery +=    " AND GW1.GW1_NRDC   = GWM.GWM_NRDC"
		cQuery +=    " AND GW1.GW1_SIT NOT IN ('2','7','8')"
		cQuery +=    " AND GW1.D_E_L_E_T_ = ' '"
		cQuery +=   " LEFT JOIN (SELECT DISTINCT"
		cQuery +=                     " GW9_FILIAL,"
		cQuery +=                     " GW9_NRCONT"
		cQuery +=                " FROM "+RetSqlName("GW9")+" GW9"
		cQuery +=               " WHERE "
		If MV_PAR01== MV_PAR02
			cQuery +=                  " GW9.GW9_FILIAL = '"+MV_PAR01+"'"
		Else
			cQuery +=                  " GW9.GW9_FILIAL >= '"+MV_PAR01+"'"
			cQuery +=              " AND GW9.GW9_FILIAL <= '"+MV_PAR02+"'"
		EndIf
		cQuery +=                 " AND GW9.D_E_L_E_T_ = ' ') GW9"
		cQuery +=    " ON GW9.GW9_FILIAL = GWM.GWM_FILIAL"
		cQuery +=   " AND GW9.GW9_NRCONT = GWM.GWM_NRDOC"
		cQuery +=  " GROUP BY "
		cQuery +=       " GW1_FILIAL,"
		cQuery +=       " GW1_CDTPDC,"
		cQuery +=       " GW1_EMISDC,"
		cQuery +=       " GW1_SERDC,"
		cQuery +=       " GW1_NRDC,"
		cQuery +=       " GW1_DTEMIS,"
		cQuery +=       " GW1_TPFRET,"
		cQuery +=       " GWM_CDTRP"

		cQuery += " UNION ALL "

		cQuery += "SELECT GW1_FILIAL,"
		cQuery +=       " GW1_CDTPDC,"
		cQuery +=       " GW1_EMISDC,"
		cQuery +=       " GW1_SERDC,"
		cQuery +=       " GW1_NRDC,"
		cQuery +=       " GW1_DTEMIS,"
		cQuery +=       " GW1_TPFRET,"
		cQuery +=       " 0 AS VLESTIM,"
		cQuery +=       " 0 AS VLCALCUL,"
		cQuery +=       " SUM(CASE WHEN GW6_SITFIN = '4' THEN GWM_VLFRET "+Iif(cOpcContab == "2" .And. cERPGFE == "1","WHEN GW3_SITFIS = '4' AND GW3_ACINT = '1' THEN GWM_VLFRET","")+" ELSE 0 END) VLREALIZA,"
		cQuery +=       " 0 AS LCTODESPE,"
		cQuery +=       " 0 AS LCTODESPE2,"
		cQuery +=       " SUM(GWA_VLMOV) AS LCTODESPE3,"
		cQuery +=       " 0 AS ESTIMADO,"
		cQuery +=       " 0 AS CALCULADO,"
		cQuery +=       " 1 AS REALIZADO,"
		cQuery +=       " 0 AS SEMCALCULO,"
		cQuery +=       " GWM_CDTRP,"
		cQuery +=       " "+cFunStrAgg+"(TRIM(GW3_NRDF), ', ') AS NRDOCFRETE,"
		cQuery +=       " ' ' AS GWF_NRCALC,"
		cQuery +=       " ' ' AS GXD_CODLOT,"
		cQuery +=       " ' ' AS GXD_OUTLOT"
		cQuery +=  " FROM ("+QryGWM(MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,"2")+") AS GWM"
		cQuery += " INNER JOIN "+RetSqlName("GW1")+" GW1"
		cQuery +=    " ON GW1.GW1_FILIAL = GWM.GWM_FILIAL"
		cQuery +=   " AND GW1.GW1_CDTPDC = GWM.GWM_CDTPDC"
		cQuery +=   " AND GW1.GW1_EMISDC = GWM.GWM_EMISDC"
		cQuery +=   " AND GW1.GW1_SERDC  = GWM.GWM_SERDC"
		cQuery +=   " AND GW1.GW1_NRDC   = GWM.GWM_NRDC"
		cQuery +=   " AND GW1.GW1_SIT NOT IN ('2','7','8')"
		cQuery +=   " AND GW1.D_E_L_E_T_ = ' '"
		cQuery += " INNER JOIN "+RetSqlName("GW4")+" GW4"
		cQuery +=    " ON GW4.GW4_FILIAL = GWM.GWM_FILIAL"
		cQuery +=   " AND GW4.GW4_EMISDC = GWM.GWM_EMISDC"
		cQuery +=   " AND GW4.GW4_SERDC  = GWM.GWM_SERDC"
		cQuery +=   " AND GW4.GW4_NRDC   = GWM.GWM_NRDC"
		cQuery +=   " AND GW4.GW4_TPDC   = GWM.GWM_CDTPDC"
		cQuery +=   " AND GW4.GW4_EMISDF = GWM.GWM_CDTRP"
		cQuery +=   " AND GW4.D_E_L_E_T_ = ' '"
		cQuery += " INNER JOIN "+RetSqlName("GW3")+" GW3"
		cQuery +=    " ON GW3.GW3_FILIAL = GW4.GW4_FILIAL"
		cQuery +=   " AND GW3.GW3_CDESP  = GW4.GW4_CDESP"
		cQuery +=   " AND GW3.GW3_EMISDF = GW4.GW4_EMISDF"
		cQuery +=   " AND GW3.GW3_SERDF  = GW4.GW4_SERDF"
		cQuery +=   " AND GW3.GW3_NRDF   = GW4.GW4_NRDF"
		cQuery +=   " AND GW3.GW3_DTEMIS = GW4.GW4_DTEMIS"
		// Otimização, caso as datas de/até sejam iguais
		If MV_PAR03 == MV_PAR04
			cQuery += " AND GW3.GW3_DTEMIS = '"+DtoS(MV_PAR03)+"'"
		Else
			cQuery += " AND GW3.GW3_DTEMIS >= '"+DtoS(MV_PAR03)+"'"
			cQuery += " AND GW3.GW3_DTEMIS <= '"+DtoS(MV_PAR04)+"'"
		EndIf
		cQuery +=   " AND GW3.D_E_L_E_T_ = ' '"
		cQuery +=  " LEFT JOIN "+RetSqlName("GW6")+" GW6"
		cQuery +=    " ON GW6.GW6_FILIAL = GW3.GW3_FILIAL"
		cQuery +=   " AND GW6.GW6_EMIFAT = GW3.GW3_EMIFAT"
		cQuery +=   " AND GW6.GW6_SERFAT = GW3.GW3_SERFAT"
		cQuery +=   " AND GW6.GW6_NRFAT  = GW3.GW3_NRFAT"
		cQuery +=   " AND GW6.GW6_DTEMIS = GW3.GW3_DTEMFA"
		// Otimização, caso as datas de/até sejam iguais
		If MV_PAR03 == MV_PAR04
			cQuery += " AND GW6.GW6_DTFIN = '"+DtoS(MV_PAR03)+"'"
		Else
			cQuery += " AND GW6.GW6_DTFIN >= '"+DtoS(MV_PAR03)+"'"
			cQuery += " AND GW6.GW6_DTFIN <= '"+DtoS(MV_PAR04)+"'"
		EndIf
		cQuery +=  " AND GW6.D_E_L_E_T_ = ' '"
		cQuery += " LEFT JOIN (SELECT GWA_FILIAL,"
		cQuery +=                   " GWA_TPDOC,"
		cQuery +=                   " GWA_CDESP,"
		cQuery +=                   " GWA_CDEMIT,"
		cQuery +=                   " GWA_SERIE,"
		cQuery +=                   " GWA_NRDOC,"
		cQuery +=                   " GWA_DTEMIS,"
		cQuery +=                   " SUM(CASE WHEN GWA_CDTRAN IN ('300'"+If(cProvCon $ "1;4",",'301','302','303'","")+") THEN GWA_VLMOV ELSE 0 END) AS GWA_VLMOV"
		cQuery +=            " FROM "+RetSqlName("GWA")+" GWA"
		cQuery +=           " WHERE "
		// Otimização, caso as filiais de/até sejam iguais
		If MV_PAR01 == MV_PAR02
			cQuery +=               " GWA.GWA_FILIAL = '"+MV_PAR01+"'"
		Else
			cQuery +=               " GWA.GWA_FILIAL >= '"+MV_PAR01+"'"
			cQuery +=           " AND GWA.GWA_FILIAL <= '"+MV_PAR02+"'"
		EndIf
		cQuery +=               " AND GWA.GWA_TPDOC  = '2'"
		cQuery +=               " AND GWA.D_E_L_E_T_ = ' '"
		cQuery +=             " GROUP BY "
		cQuery +=                   " GWA_FILIAL,"
		cQuery +=                   " GWA_TPDOC,"
		cQuery +=                   " GWA_CDESP,"
		cQuery +=                   " GWA_CDEMIT,"
		cQuery +=                   " GWA_SERIE,"
		cQuery +=                   " GWA_NRDOC,"
		cQuery +=                   " GWA_DTEMIS) AS GWA"
		cQuery +=    " ON GWA.GWA_FILIAL = GW4.GW4_FILIAL"
		cQuery +=   " AND GWA.GWA_CDESP  = GW4.GW4_CDESP"
		cQuery +=   " AND GWA.GWA_CDEMIT = GW4.GW4_EMISDF"
		cQuery +=   " AND GWA.GWA_SERIE  = GW4.GW4_SERDF"
		cQuery +=   " AND GWA.GWA_NRDOC  = GW4.GW4_NRDF"
		cQuery +=   " AND GWA.GWA_DTEMIS = GW4.GW4_DTEMIS"
		cQuery += " GROUP BY "
		cQuery +=       " GW1_FILIAL,"
		cQuery +=       " GW1_CDTPDC,"
		cQuery +=       " GW1_EMISDC,"
		cQuery +=       " GW1_SERDC,"
		cQuery +=       " GW1_NRDC,"
		cQuery +=       " GW1_DTEMIS,"
		cQuery +=       " GW1_TPFRET,"
		cQuery +=       " GWM_CDTRP"

	EndIf

	If lSemCalc

		If lCalcEstim .Or. lCalcRoman .Or. lCalcOcorr .Or. lRealizado
			cQuery += " UNION ALL "
		EndIf

		cQuery += "SELECT GW1_FILIAL,"
		cQuery +=       " GW1_CDTPDC,"
		cQuery +=       " GW1_EMISDC,"
		cQuery +=       " GW1_SERDC,"
		cQuery +=       " GW1_NRDC,"
		cQuery +=       " GW1_DTEMIS,"
		cQuery +=       " GW1_TPFRET,"
		cQuery +=       " 0 AS VLESTIM,"
		cQuery +=       " 0 AS VLCALCUL,"
		cQuery +=       " 0 AS VLREALIZA,"
		cQuery +=       " 0 AS LCTODESPE,"
		cQuery +=       " 0 AS LCTODESPE2,"
		cQuery +=       " 0 AS LCTODESPE3,"
		cQuery +=       " 0 AS ESTIMADO,"
		cQuery +=       " 0 AS CALCULADO,"
		cQuery +=       " 0 AS REALIZADO,"
		cQuery +=       " 1 AS SEMCALCULO,"
		cQuery +=       " GWU_CDTRP AS GWM_CDTRP,"
		cQuery +=       " ' ' AS NRDOCFRETE,"
		cQuery +=       " ' ' AS GWF_NRCALC,"
		cQuery +=       " ' ' AS GXD_CODLOT,"
		cQuery +=       " ' ' AS GXD_OUTLOT"
		cQuery +=  " FROM "+RetSqlName("GW1")+" GW1"
		cQuery += " INNER JOIN "+RetSqlName("GWU")+" GWU"
		cQuery +=    " ON GWU.GWU_FILIAL = GW1.GW1_FILIAL"
		cQuery +=   " AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC"
		cQuery +=   " AND GWU.GWU_EMISDC = GW1.GW1_EMISDC"
		cQuery +=   " AND GWU.GWU_SERDC  = GW1.GW1_SERDC"
		cQuery +=   " AND GWU.GWU_NRDC   = GW1.GW1_NRDC"
		cQuery +=   " AND GWU.D_E_L_E_T_ = ' '"
		cQuery += " WHERE "
		// Otimização, caso as filiais de/até sejam iguais
		If MV_PAR01 == MV_PAR02
			cQuery +=   " GW1.GW1_FILIAL = '"+MV_PAR01+"'"
		Else
			cQuery +=     " GW1.GW1_FILIAL >= '"+MV_PAR01+"'"
			cQuery += " AND GW1.GW1_FILIAL <= '"+MV_PAR02+"'"
		EndIf
		// Otimização, caso as datas de/até sejam iguais
		If MV_PAR03 == MV_PAR04
			cQuery += " AND GW1.GW1_DTEMIS = '"+DtoS(MV_PAR03)+"'"
		Else
			cQuery += " AND GW1.GW1_DTEMIS >= '"+DtoS(MV_PAR03)+"'"
			cQuery += " AND GW1.GW1_DTEMIS <= '"+DtoS(MV_PAR04)+"'"
		EndIf
		cQuery +=   " AND GW1.GW1_SIT NOT IN ('2','7','8')"
		cQuery +=   " AND GW1.D_E_L_E_T_ = ' '"
		cQuery +=   " AND NOT EXISTS(SELECT 1"
		cQuery +=                    " FROM "+RetSqlName("GWH")+" GWH"
		cQuery +=                   " WHERE GWH.GWH_FILIAL = GW1.GW1_FILIAL"
		cQuery +=                     " AND GWH.GWH_CDTPDC = GW1.GW1_CDTPDC"
		cQuery +=                     " AND GWH.GWH_EMISDC = GW1.GW1_EMISDC"
		cQuery +=                     " AND GWH.GWH_SERDC  = GW1.GW1_SERDC"
		cQuery +=                     " AND GWH.GWH_NRDC   = GW1.GW1_NRDC"
		cQuery +=                     " AND GWH.D_E_L_E_T_ = ' ')"

	EndIf

	cQuery += ") AS TBL"

	cQuery += " INNER JOIN "+RetSqlName("GU3")+" GU3"
	cQuery +=    " ON GU3.GU3_FILIAL = '"+xFilial("GU3")+"'"
	cQuery +=   " AND GU3.GU3_CDEMIT = TBL.GWM_CDTRP"
	cQuery +=   " AND GU3.D_E_L_E_T_ = ' '"

	cQuery += " GROUP BY "
	cQuery +=       " GW1_FILIAL,"
	cQuery +=       " GW1_CDTPDC,"
	cQuery +=       " GW1_EMISDC,"
	cQuery +=       " GW1_SERDC,"
	cQuery +=       " GW1_NRDC,"
	cQuery +=       " GW1_DTEMIS,"
	cQuery +=       " GW1_TPFRET,"
	cQuery +=       " SEMCALCULO,"
	cQuery +=       " GWM_CDTRP,"
	cQuery +=       " GU3_NMEMIT"
	cQuery += " ORDER BY "
	cQuery +=       " GW1_DTEMIS"

	WmsQry2Tmp(cAliasGW1,oTempTable:oStruct:aFields,cQuery,oTempTable)

	// Apresenta apenas os com divergência
	If MV_PAR10 == 2
		cStatement := "DELETE FROM "+oTempTable:GetRealName()
		cStatement += " WHERE ( ESTIMADO  > 0 AND VLESTIM   = LCTODESPE3)"
		cStatement +=    " OR ( CALCULADO > 0 AND VLCALCUL  = LCTODESPE )"
		cStatement +=    " OR ( REALIZADO > 0 AND VLREALIZA = LCTODESPE2)"
		// Executa o comando no banco
		If TcSqlExec(cStatement) < 0
			MsgStop("Erro ao tentar excluir os documentos sem divergência: " + CRLF + TCSqlError())
		EndIf
	EndIf

	// Apresenta apenas os sem divergência
	If MV_PAR10 == 3
		cStatement := "DELETE FROM "+oTempTable:GetRealName()
		cStatement += " WHERE ( ESTIMADO  > 0 AND VLESTIM   <> LCTODESPE3)"
		cStatement +=    " OR ( CALCULADO > 0 AND VLCALCUL  <> LCTODESPE )"
		cStatement +=    " OR ( REALIZADO > 0 AND VLREALIZA <> LCTODESPE2)"
		// Executa o comando no banco
		If TcSqlExec(cStatement) < 0
			MsgStop("Erro ao tentar excluir os documentos com divergência: " + CRLF + TCSqlError())
		EndIf
	EndIf

Return

Function A094Atualizar()
	SetRegua(3)
	IncRegua()
	CarregarDados()
	IncRegua()
	oBrowseGW1:Refresh()
	(cAliasGW1)->(DbGoTop())
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
		If (cAliasGW1)->VLREALIZA > 0
			MsgStop("Documento de carga já possui frete realizado.")
		ElseIf(cAliasGW1)->VLCALCUL > 0
			MsgStop("Documento de carga já possui cálculo de frete.")
		ElseIf(cAliasGW1)->VLESTIM > 0
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
	(cAliasGW1)->VLESTIM := nCalc
	(cAliasGW1)->LCTODESPE3 := nDesp
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

Static Function QryGWM(cFilDe,cFilAte,dDataDe,dDataAte,cTpDoc)
Local cQuery := ""
Local lNrDoc := ( cTpDoc $ "1,3,4" ) // Cálculo, Contrato com Autônomo ou Estimativa

	cQuery := "SELECT GWM_FILIAL,"
	cQuery +=       " GWM_CDTPDC,"
	cQuery +=       " GWM_EMISDC,"
	cQuery +=       " GWM_SERDC,"
	cQuery +=       " GWM_NRDC,"
	If lNrDoc
		cQuery +=   " GWM_NRDOC,"
	EndIf
	cQuery +=       " GWM_CDTRP,"
	cQuery +=       " SUM(GWM_VLFRET) AS GWM_VLFRET"
	cQuery +=  " FROM "+RetSqlName("GWM")+" GWM"
	cQuery += " WHERE "
	If cFilDe == cFilAte
		cQuery +=     " GWM.GWM_FILIAL = '"+cFilDe+"'"
	Else
		cQuery +=     " GWM.GWM_FILIAL >= '"+cFilDe+"'"
		cQuery += " AND GWM.GWM_FILIAL <= '"+cFilAte+"'"
	EndIf
	// Otimização, caso as datas de/até sejam iguais
	If dDataDe == dDataAte
		cQuery += " AND GWM.GWM_DTEMIS = '"+DtoS(dDataDe)+"'"
	Else
		cQuery += " AND GWM.GWM_DTEMIS >= '"+DtoS(dDataDe)+"'"
		cQuery += " AND GWM.GWM_DTEMIS <= '"+DtoS(dDataAte)+"'"
	EndIf
	cQuery +=   " AND GWM.GWM_TPDOC   = '"+cTpDoc+"'"
	cQuery +=   " AND GWM.D_E_L_E_T_  = ' '"
	cQuery += " GROUP BY "
	cQuery +=       " GWM_FILIAL,"
	cQuery +=       " GWM_CDTPDC,"
	cQuery +=       " GWM_EMISDC,"
	cQuery +=       " GWM_SERDC,"
	cQuery +=       " GWM_NRDC,"
	If lNrDoc
		cQuery +=   " GWM_NRDOC,"
	EndIf
	cQuery +=       " GWM_CDTRP"

Return cQuery
