#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEC001N
Painel Gerencial de Transportadores - Informações sobre Despesa de Transporte
Utilizado apenas para quando o transportador é AUTONOMO;
Para os demais, consultar o programa GFEC001K

Uso Restrito. 

Param:
aParam[1] := Filial de
aParam[2] := Filial ate
aParam[3] := Data de
aParam[4] := Data ate
aParam[5] := Codigo do Emitente     

@sample
GFEC001N(aParam)

@author Alan Victor Lamb
@since 21/06/13
@version 1.0
--------------------------------------------------------------------------------------------------/*/  
Function GFEC001N(aParam)
	Local aCoors  := FWGetDialogSize(oMainWnd)
	Local cTitulo := 'Painel Gerencial - Transportador'     
	Local oPnl
	
	Private oBrowseCal, oBrowseCon, oBrowseEst
	Private aGrfTpc, aGrfCom, aGrfNeg, aGrfCCon
	Private oGrfTpc, oGrfCom, oGrfNeg, oGrfCCon
	Private aStat
	Private aFiltrosFP, aFiltrosFR
	Private cFilialDe  := aParam[1]
	Private cFilialAte := aParam[2]
	Private dDataDe  := If(Empty(aParam[3]),DDATABASE -30 ,aParam[3])
	Private dDataAte := If(Empty(aParam[4]),DDATABASE     ,aParam[4])                   
	Private cCodEmit := aParam[5]
	Private oFolder
	
	Private nValCalc, nQtdCalc
	
	aFiltrosFP := {{"GWF","GWF_TRANSP","=" ,cCodEmit},;
				     {"GWF","GWF_FILIAL",">=",cFilialDe},;
				     {"GWF","GWF_FILIAL","<=",cFilialAte},;   
				     {"GWF","GWF_DTCRIA",">=",DtoS(dDataDe)},;
				     {"GWF","GWF_DTCRIA","<=",DtoS(dDataAte)}}

	aFiltrosFR := {{"GW2","GW2_CDPROP","=" ,cCodEmit},;
				     {"GW2","GW2_FILIAL",">=",cFilialDe},;
				     {"GW2","GW2_FILIAL","<=",cFilialAte},;   
				     {"GW2","GW2_DTCRIA",">=",Dtos(dDataDe)},;
				     {"GW2","GW2_DTCRIA","<=",Dtos(dDataAte)}}
	
	Define MsDialog oDLG Title cTitulo From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
	oDLG:Activate(,,,.T.,,,{||RptStatus({||Iniciar()},"Aguarde", "Realizando consultas de dados")})
Return 

Static Function Iniciar()
	Local cBrowseFiltro
	Local oPnl,oFolderEst,oFolderGrf,oPnlGrf
	Local oFWLayer, oWIN_TOP, oWIN_LEFT, oWIN_RIGHT, oWIN_MIDDLE
	Local aColValCalc
	Local nCount := 0
	Local oData
	
	SetRegua(3)
	
	CarregaFP(aFiltrosFP)
	CarregaFR(aFiltrosFR)
	
	IncRegua()
	
	oFolder :=  tFolder():New(30,0,{"Cálculos de frete","Contratos"},{"G1","G2"},oDLG,)
	oFolder:Align := CONTROL_ALIGN_ALLCLIENT
	
	//
	// Aba Cálculos de Frete
	//
	
	cBrowseFiltro := "GWF_TRANSP == '" + cCodEmit        + "' .AND. "
	cBrowseFiltro += "GWF_TPCALC != '8' .AND. " // Desconsidera cálculos do tipo "Provisão"  
	cBrowseFiltro += "GWF_FILIAL >= '" + cFilialDe      + "' .AND. GWF_FILIAL <= '" + cFilialAte     + "' .AND. "  
	cBrowseFiltro += "GWF_DTCRIA >= '" + DtoS(dDataDe) + "' .AND. GWF_DTCRIA <= '" + DtoS(dDataAte) + "'"
	
	oPnl := tPanel():New(30,0,,oFolder:aDialogs[1],,,,,,)
	oPnl:Align := CONTROL_ALIGN_ALLCLIENT
	
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oPnl,.F.)
	oFWLayer:AddLine('LINE_TOP',50,.F.)
	oFWLayer:AddLine('LINE_MIDDLE',50,.F.)
	oFWLayer:AddCollumn('COL_TOP',100,.T.,'LINE_TOP')
	oFWLayer:AddCollumn('COL_LEFT',33,.T.,'LINE_MIDDLE')
	oFWLayer:AddCollumn('COL_MIDDLE',34,.T.,'LINE_MIDDLE')
	oFWLayer:AddCollumn('COL_RIGHT',33,.T.,'LINE_MIDDLE')
    oFWLayer:AddWindow('COL_LEFT','WIN_LEFT','Tipo de Cálculo',100,.F.,.F.,,'LINE_MIDDLE',)
  	oFWLayer:AddWindow('COL_MIDDLE','WIN_MIDDLE','Componente de Frete',100,.F.,.F.,,'LINE_MIDDLE',)
  	oFWLayer:AddWindow('COL_RIGHT','WIN_RIGHT','Tipo de Negociação',100,.F.,.F.,,'LINE_MIDDLE',)
  	
    oWIN_TOP    := oFWLayer:GetColPanel('COL_TOP','LINE_TOP')
    oWIN_LEFT   := oFWLayer:GetWinPanel('COL_LEFT','WIN_LEFT','LINE_MIDDLE')
    oWIN_RIGHT  := oFWLayer:GetWinPanel('COL_RIGHT','WIN_RIGHT','LINE_MIDDLE')
    oWIN_MIDDLE := oFWLayer:GetWinPanel('COL_MIDDLE','WIN_MIDDLE','LINE_MIDDLE')
	
	//
	// Cálculos de frete
	//
	aColValCalc := {{"Valor Calc", {||GFEC001VLF()}, "N","@E 999,999,999.99",2,15,2,.F.}}
	
	oBrowseCal:= FWMBrowse():New()
	oBrowseCal:SetOwner(oWIN_TOP)
	oBrowseCal:SetAlias('GWF')
	oBrowseCal:SetDescription("Cálculos de frete")
	oBrowseCal:SetLocate()
	oBrowseCal:SetAmbiente(.F.)
	oBrowseCal:SetWalkthru(.F.)
	oBrowseCal:DisableDetails()
	oBrowseCal:SetMenuDef("")
	oBrowseCal:AddButton("Visualizar","VIEWDEF.GFEC080",,2)
	oBrowseCal:ForceQuitButton(.T.)
	oBrowseCal:SetFields(aColValCalc)
	oBrowseCal:SetProfileID("1")
	oBrowseCal:SetFilterDefault(cBrowseFiltro)
	oBrowseCal:BVLDEXECFILTER := {|aParam| GFEC001NCF(aParam)}
	oBrowseCal:Activate()
	
	//
	// Valor de Frete por Tipo de cálculo
	// 
   	GFEC001GRC("oGrfTpc", "Valor por tipo de cálculo", oWIN_LEFT, aGrfTpc, "@E 999,999,999.99")
    
    //
	// Valor de Frete por Componente
	// 
   	GFEC001GRC("oGrfCom", "Valor por componente", oWIN_MIDDLE, aGrfCom, "@E 999,999,999.99")
    
    //
	// Valor de Frete por Tipo de Negociação
	// 
    GFEC001GRC("oGrfNeg", "Valor por tipo de negociação", oWIN_RIGHT, aGrfNeg, "@E 999,999,999.99")
    
    IncRegua()
    
    //
    // Aba Contratos
    //
    
    cBrowseFiltro := "GW2_CDPROP == '" + cCodEmit        + "' .AND. "  
    cBrowseFiltro += "(GW2_SITCON == '2' .OR. GW2_SITCON == '3') .AND. "
	cBrowseFiltro += "GW2_FILIAL >= '" + cFilialDe      + "' .AND. GW2_FILIAL <= '" + cFilialAte     + "' .AND. "  
	cBrowseFiltro += "GW2_DTCRIA >= '" + DtoS(dDataDe) + "' .AND. GW2_DTCRIA <= '" + DtoS(dDataAte) + "'"
	
    oPnl := tPanel():New(30,0,,oFolder:aDialogs[2],,,,,,)
	oPnl:Align := CONTROL_ALIGN_ALLCLIENT
	
    oFWLayer := FWLayer():New()
	oFWLayer:Init(oPnl,.F.)
	oFWLayer:AddLine('LINE_TOP',50,.F.)
	oFWLayer:AddLine('LINE_MIDDLE',50,.F.)
	oFWLayer:AddCollumn('COL_TOP',100,.T.,'LINE_TOP')
	oFWLayer:AddCollumn('COL_LEFT',40,.T.,'LINE_MIDDLE')
	oFWLayer:AddCollumn('COL_RIGHT',60,.T.,'LINE_MIDDLE')
    oFWLayer:AddWindow('COL_LEFT','WIN_LEFT','Estatísticas',100,.F.,.F.,,'LINE_MIDDLE',)
  	oFWLayer:AddWindow('COL_RIGHT','WIN_RIGHT','Custo do frete',100,.F.,.F.,,'LINE_MIDDLE',)
  	
    oWIN_TOP   := oFWLayer:GetColPanel('COL_TOP','LINE_TOP')
    oWIN_LEFT  := oFWLayer:GetWinPanel('COL_LEFT','WIN_LEFT','LINE_MIDDLE')
    oWIN_RIGHT := oFWLayer:GetWinPanel('COL_RIGHT','WIN_RIGHT','LINE_MIDDLE')
	
	//
	// Contratos com Autonomos
	//
	oBrowseCon:= FWMBrowse():New()
	oBrowseCon:SetOwner(oWIN_TOP)
	oBrowseCon:SetAlias('GW2')
	oBrowseCon:SetDescription("Contratos com autônomos")
	oBrowseCon:SetLocate()
	oBrowseCon:SetAmbiente(.F.)
	oBrowseCon:SetWalkthru(.F.)
	oBrowseCon:DisableDetails()
	oBrowseCon:SetMenuDef("")
	oBrowseCon:AddButton("Visualizar","VIEWDEF.GFEC100",,2)
	oBrowseCon:ForceQuitButton(.T.)
	oBrowseCon:SetProfileID("2")
	oBrowseCon:SetFilterDefault(cBrowseFiltro)
	oBrowseCon:BVLDEXECFILTER := {|aParam| GFEC001NDF(aParam)}
	oBrowseCon:Activate()
	
	//
	// Estatísticas
	// 
	oBrowseEst := FWBrowse():New()
	oBrowseEst:SetOwner(oWIN_LEFT)
	oBrowseEst:SetDescription("Dados")
	oBrowseEst:SetDataArray()
	oBrowseEst:DisableFilter()
	oBrowseEst:DisableConfig()
	oBrowseEst:SetArray(aStat)
   	oBrowseEst:SetColumns(GFEC001COL("Descrição",1,,1,15,"oBrowseEst"))
   	oBrowseEst:SetColumns(GFEC001COL("Unidade",2,,2,2,"oBrowseEst"))
	oBrowseEst:SetColumns(GFEC001COL("Valor",3,,2,13,"oBrowseEst"))
	oBrowseEst:Activate()
	
	//
	// Custo do frete
	//
	GFEC001GRC("oGrfCCon", "Custo do frete", oWIN_RIGHT, aGrfCCon, "@E 999,999,999.99")
	
    IncRegua()
Return Nil

//
// Carrega os dados de Frete Realizado
//
Static Function CarregaFR(aFiltrosFR, cBrwFiltro)
	Local   cQuery      := ""
	Local   cTmp        := ""
	Local   nTmp        := 0
	Default cBrwFiltro := ""
	
	aGrfCCon := {}
	aStat    := {}
	
	cQuery += "	SELECT COUNT(*) QTDE_CONT, "
	cQuery += "	       SUM(GW2_VLFRET) GW2_VLFRET, "
	cQuery += "	       SUM(GW2_VLADIC) GW2_VLADIC, "
	cQuery += "	       SUM(GW2_VLDESC) GW2_VLDESC, "
	cQuery += "	       SUM(GW2_VLSEST) GW2_VLSEST, "
	cQuery += "	       SUM(GW2_VLISS) GW2_VLISS, "
	cQuery += "	       SUM(GW2_VLINSS) GW2_VLINSS, "
	cQuery += "	       SUM(GW2_VLIRRF) GW2_VLIRRF, "
	cQuery += "	       SUM(GW2_VLINEM) GW2_VLINEM, "
	cQuery += "	       SUM(GW2_VLLIQ) GW2_VLLIQ"
	cQuery += "	  FROM " + RetSQLName("GW2") + " GW2"
	cQuery += "	 WHERE GW2.D_E_L_E_T_ = ' ' AND GW2.GW2_SITCON IN ('2','3') " + cBrwFiltro + CriaQueryCondicao(aFiltrosFR,"")
	
	//
	// Custo do frete:
	// Gráfico contendo todos os componentes do custo total do frete com autonomo.
	// Valor Líquido do frete (Valor pago ao autonomo)
	// Impostos pagos pelo RPA: ISS, INSS, IRRF, SEST
	// Imposto pago pela empresa, não relacionado ao auton.: INEM
	// 
	
	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	
	If (cTmp)->(Recno()) > 0
		// Dados do gráfico
		aAdd(aGrfCCon, {"Prestação de Serviço", (cTmp)->GW2_VLLIQ})
		aAdd(aGrfCCon, {"SEST/SENAT", (cTmp)->GW2_VLSEST})
		aAdd(aGrfCCon, {"INSS autônomo", (cTmp)->GW2_VLINSS})
		aAdd(aGrfCCon, {"INSS embarcador", (cTmp)->GW2_VLINEM})
		aAdd(aGrfCCon, {"ISS", (cTmp)->GW2_VLISS})
		aAdd(aGrfCCon, {"IRRF", (cTmp)->GW2_VLIRRF})
		
		// Dados estatísticas
		aAdd(aStat, {"Transportador"              , "-", AllTrim(Posicione("GU3",1,xFilial("GU3")+cCodEmit,"GU3_NMEMIT"))})
		
		aAdd(aStat, {"Qtde contratos"             , "Un", (cTmp)->QTDE_CONT})
		aAdd(aStat, {"Valor Total Prest Serviço", "$",  Transform((cTmp)->GW2_VLLIQ, "@E 999,999,999.99")})
		aAdd(aStat, {"Valor Médio Prest Serviço", "$",  Transform(((cTmp)->GW2_VLLIQ / (cTmp)->QTDE_CONT), "@E 999,999,999.99")})
		
		aAdd(aStat, {"Qtde Cálculos"        , "Un", nQtdCalc})
		aAdd(aStat, {"Valor Médio Cálculos", "$", Transform(nValCalc / nQtdCalc, "@E 999,999,999.99")})
		
		aAdd(aStat, {"Valor Total Adicionais"    , "$", Transform((cTmp)->GW2_VLADIC, "@E 999,999,999.99")})
		aAdd(aStat, {"Valor Total Descontos"     , "$", Transform((cTmp)->GW2_VLDESC, "@E 999,999,999.99")})
		aAdd(aStat, {"Valor Total Imp Autônomo"  , "$", Transform(((cTmp)->GW2_VLSEST+(cTmp)->GW2_VLISS+(cTmp)->GW2_VLINSS+(cTmp)->GW2_VLIRRF), "@E 999,999,999.99")})
		aAdd(aStat, {"Valor Total Imp Embarcador", "$", Transform((cTmp)->GW2_VLINEM, "@E 999,999,999.99")})
		
		// Custo total:
		// Valor Líquido + Impostos + Descontos - Adicionais + INEM
		nTmp := (cTmp)->GW2_VLLIQ + ((cTmp)->GW2_VLSEST+(cTmp)->GW2_VLISS+(cTmp)->GW2_VLINSS+(cTmp)->GW2_VLIRRF) + (cTmp)->GW2_VLDESC - (cTmp)->GW2_VLADIC + (cTmp)->GW2_VLINEM
		aAdd(aStat, {"Custo Total"          , "$", Transform(nTmp, "@E 999,999,999.99")})
		aAdd(aStat, {"Custo Médio Contrato", "$", Transform((nTmp / (cTmp)->QTDE_CONT), "@E 999,999,999.99")})
	EndIf
	
	(cTmp)->(dbCloseArea())
Return Nil

//
// Carrega os dados de Frete Previsto
//
Static Function CarregaFP(aFiltrosFP,cBrwFiltro)
	Local   cQuery      := ""
	Local   cTmp        := ""
	Default cBrwFiltro := ""
	
	aGrfTpc := {}
	aGrfCom := {}
	aGrfNeg := {}
	
	// Valor de Frete por Tipo de Cálculo	
	cQuery += "SELECT SUM(CASE WHEN GWF_TPCALC = '1' THEN GWI_VLFRET ELSE 0 END) VAL_TP1,"
	cQuery += "	   	  SUM(CASE WHEN GWF_TPCALC = '2' THEN GWI_VLFRET ELSE 0 END) VAL_TP2,"
	cQuery += "	      SUM(CASE WHEN GWF_TPCALC = '3' THEN GWI_VLFRET ELSE 0 END) VAL_TP3,"
	cQuery += "	      SUM(CASE WHEN GWF_TPCALC = '4' THEN GWI_VLFRET ELSE 0 END) VAL_TP4,"
	cQuery += "	      SUM(CASE WHEN GWF_TPCALC = '5' THEN GWI_VLFRET ELSE 0 END) VAL_TP5,"
	cQuery += "	      SUM(CASE WHEN GWF_TPCALC = '6' THEN GWI_VLFRET ELSE 0 END) VAL_TP6,"
	cQuery += "	      SUM(CASE WHEN GWF_TPCALC = '7' THEN GWI_VLFRET ELSE 0 END) VAL_TP7,"
	cQuery += "		  SUM(CASE WHEN GWF_ORIGEM = '1' THEN GWI_VLFRET END) TABELADO, "
	cQuery += "	      SUM(CASE WHEN GWF_ORIGEM = '2' THEN GWI_VLFRET END) COMBINADO, "
	cQuery += "	      COUNT(*) QTD_CALC, "
	cQuery += "	      SUM(GWI_VLFRET) VAL_CALC "
	cQuery += "  FROM " + RetSQLName("GWF") + " GWF "
	cQuery += " INNER JOIN ( "
	cQuery += " 	SELECT GWI_NRCALC, GWI_FILIAL, SUM(GWI_VLFRET) GWI_VLFRET "
	cQuery += " 	  FROM " + RetSQLName("GWI")
	cQuery += " 	 WHERE D_E_L_E_T_ = ' ' "
	cQuery += " 	   AND GWI_TOTFRE = '1' "
	cQuery += " 	 GROUP BY GWI_NRCALC, GWI_FILIAL "
	cQuery += " ) GWI ON GWI.GWI_FILIAL = GWF.GWF_FILIAL "
	cQuery += "      AND GWI.GWI_NRCALC = GWF.GWF_NRCALC "
	cQuery += " WHERE GWF.D_E_L_E_T_ = ' ' "
	cQuery += "   AND GWF.GWF_TPCALC != '8' " + cBrwFiltro + CriaQueryCondicao(aFiltrosFP,"") 
	
	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	
	If (cTmp)->(Recno()) > 0
		aADD(aGrfTpc, {"Normal",(cTmp)->VAL_TP1})
		aADD(aGrfTpc, {"Compl Valor",(cTmp)->VAL_TP2})
		aADD(aGrfTpc, {"Compl Imposto",(cTmp)->VAL_TP3})
		aADD(aGrfTpc, {"Reentrega",(cTmp)->VAL_TP4})
		aADD(aGrfTpc, {"Devolução",(cTmp)->VAL_TP5})
		aADD(aGrfTpc, {"Redespacho",(cTmp)->VAL_TP6})
		aADD(aGrfTpc, {"Serviço",(cTmp)->VAL_TP7})
		aAdd(aGrfNeg, {"Tabelado", (cTmp)->TABELADO})
		aAdd(aGrfNeg, {"Combinado", (cTmp)->COMBINADO})
		
		nValCalc := (cTmp)->VAL_CALC
		nQtdCalc := (cTmp)->QTD_CALC
	EndIf
	
	(cTmp)->(dbCloseArea())
	
	// Valor de Frete por Componente de frete
	cQuery := ""
	cQuery += "SELECT GWI.GWI_CDCOMP,"
	cQuery += "		SUM(GWI.GWI_VLFRET) VLFRET"
	cQuery += "  FROM " + RetSQLName("GWF") + " GWF"
	cQuery += " INNER JOIN " + RetSQLName("GWI") + " GWI ON GWI.GWI_FILIAL = GWF.GWF_FILIAL"
	cQuery += "		      		  AND GWI.GWI_NRCALC = GWF.GWF_NRCALC"
	cQuery += "		      		  AND GWI.GWI_TOTFRE = '1'"
	cQuery += "		      		  AND GWI.D_E_L_E_T_ = ' '"
	cQuery += " WHERE GWF.D_E_L_E_T_ = ' '"
	cQuery += "   AND GWF.GWF_TPCALC != '8'" + cBrwFiltro + CriaQueryCondicao(aFiltrosFP,"")
	cQuery += " GROUP BY GWI.GWI_CDCOMP"
	
	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	
	If (cTmp)->(Recno()) > 0
		While (cTmp)->(!Eof())
			aAdd(aGrfCom, {(cTmp)->GWI_CDCOMP, (cTmp)->VLFRET})
			(cTmp)->(dbSkip())
		EndDo
	EndIf
	
	(cTmp)->(dbCloseArea())
Return Nil

//=========================================================================/ 
// Aplica o filtro do browse na consulta SQL
// Aba "Cálculos de Frete"
//=========================================================================/

Function GFEC001NCF(aParam) 
	Local nCont 
	Local cFiltro := ""
	
	For nCont := 1 to Len(aParam)
		If !aParam[nCont][5]
	       	If !Empty(cFiltro)
	       		cFiltro := cFiltro + " AND (" +  aParam[nCont][3] + ")"
	       	Else
	       	    cFiltro := " AND (" +  aParam[nCont][3] + ")"
	       	Endif
		EndIf
	Next nCont	
	
	Processa({||AtualizaFP(cFiltro)})
Return .T. 

Static Function AtualizaFP(cFiltro)
	CarregaFP(aFiltrosFP,cFiltro)
	GFEC001GRA(oGrfTpc,.T.,aGrfTpc)
	GFEC001GRA(oGrfCom,.T.,aGrfCom)
Return Nil      

//=========================================================================/ 
// Aplica o filtro do browse na consulta SQL
// Aba "Contratos"
//=========================================================================/
Function GFEC001NDF(aParam) 
	Local nCont 
	Local cFiltro := ""
	
	For nCont := 1 to Len(aParam)
		If !aParam[nCont][5]
	       	If !Empty(cFiltro)
	       		cFiltro := cFiltro + " AND (" +  aParam[nCont][3] + ")"
	       	Else
	       	    cFiltro := " AND (" +  aParam[nCont][3] + ")"
	       	Endif
		EndIf
	Next nCont	
	
	Processa({||AtualizaFR(cFiltro)})
Return .T. 

Static Function AtualizaFR(cFiltro)
	CarregaFR(aFiltrosFR,cFiltro)
	GFEC001GRA(oGrfCCon,.T.,oGrfCCon)
Return Nil
