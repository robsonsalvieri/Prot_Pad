#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEC002K
Painel Gerencial - Estatísticas

Uso Restrito. 

Param:
aParam[1] := Data de
aParam[2] := Data ate
aParam[3] := Filial

@sample
GFEC002K(aParam)

@author Alan Victor Lamb
@since 19/06/13
@version 1.0
--------------------------------------------------------------------------------------------------/*/  
Function GFEC002K(aParam)   
	Local aCoors := FWGetDialogSize(oMainWnd)
	Local cTitulo := 'Painel Gerencial - Filial'     
	
	Private aDadosBrw, aGrfMov, aGrfOco, aGrfNeg
	Private oBrowseEst, oGrfMov, oGrfOco, oGrfNeg
	Private oWIN_TOPL, oWIN_TOPR, oWIN_BOTL, oWIN_BOTR
	
	Private cAliasEst, aIndEst, aFieldEst
	
	Private cFil  := aParam[3]
	Private dDataDe  := If(Empty(aParam[1]),DDATABASE -30 ,aParam[1])
	Private dDataAte := If(Empty(aParam[2]),DDATABASE     ,aParam[2])                   
	
	Define MsDialog oDLG Title cTitulo From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
	
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDLG,.F.)
	oFWLayer:AddLine('LINE_TOP',50,.F.)
	oFWLayer:AddLine('LINE_BOTTOM',50,.F.)
	oFWLayer:AddCollumn('COL_TOPL',60,.T.,'LINE_TOP')
	oFWLayer:AddCollumn('COL_TOPR',40,.T.,'LINE_TOP')
	oFWLayer:AddCollumn('COL_BOTTOML',60,.T.,'LINE_BOTTOM')
	oFWLayer:AddCollumn('COL_BOTTOMR',40,.T.,'LINE_BOTTOM')
	oFWLayer:AddWindow('COL_TOPL','WIN_TOPL','Movimentação',100,.F.,.F.,,'LINE_TOP',)
	oFWLayer:AddWindow('COL_TOPR','WIN_TOPR','Ocorrências',100,.F.,.F.,,'LINE_TOP',)
	oFWLayer:AddWindow('COL_BOTTOML','WIN_BOTTOML','Negociação e Auditoria',100,.F.,.F.,,'LINE_BOTTOM',)
	
    oWIN_TOPL      := oFWLayer:GetWinPanel('COL_TOPL','WIN_TOPL','LINE_TOP')
    oWIN_TOPR      := oFWLayer:GetWinPanel('COL_TOPR','WIN_TOPR','LINE_TOP')
    oWIN_BOTL   := oFWLayer:GetWinPanel('COL_BOTTOML','WIN_BOTTOML','LINE_BOTTOM')
    oWIN_BOTR   := oFWLayer:GetColPanel('COL_BOTTOMR','LINE_BOTTOM')
    
	oDLG:Activate(,,,.T.,,,{||Processa({||Iniciar()})})
	
	GFEDelTab(cAliasEst)
Return 

Static Function Iniciar()
	Local cFilName := ""
	Local nCount
	
	CarregaDados()
	
	Grafico(oGrfMov,aGrfMov,oWIN_TOPL,"Movimentação") 
	Grafico(oGrfOco,aGrfOco,oWIN_TOPR,"Ocorrências") 
	Grafico(oGrfNeg,aGrfNeg,oWIN_BOTL,"Negociação e Auditoria") 
	
	cFilName := AllTrim(FWFilialName(,cFil,))
	
	If Len(cFilName) > 20
		cFilName := SUBSTR(cFilName, 1, 17) + "..."
	EndIf
	
	aFieldEst := ;
	{{"Descrição"	,"DESCRI" ,"C",25,0,"",1,10},;
	{"UN"	   	    ,"UNIDAD" ,"C",2,0,"",1,2},;
	{cFilName       ,"VALEMI" ,"C",15,0,"",1,10},;
	{"Todas"        ,"VALTOT" ,"C",15,0,"",1,10},;
	{"%"            ,"PCTEMI" ,"N",5,1,"",2,5}}
	
	aIndEst := {"DESCRI"}
	
	//Cria tabelas temporárias
	cAliasEst := CriaTab(aFieldEst, aIndEst)
	
	For nCount := 1 To Len(aDadosBrw)
		RecLock(cAliasEst, .T.)
		(cAliasEst)->DESCRI := aDadosBrw[nCount, 1]
		(cAliasEst)->UNIDAD := aDadosBrw[nCount, 5]
		(cAliasEst)->VALEMI := aDadosBrw[nCount, 3]
		(cAliasEst)->VALTOT := aDadosBrw[nCount, 2]
		(cAliasEst)->PCTEMI := aDadosBrw[nCount, 4]
		MsUnlock()
	Next nCount
	
	// Estatísticas
	oBrowseEst:= FWMBrowse():New()
	oBrowseEst:SetOwner(oWIN_BOTR)
	oBrowseEst:SetAlias(cAliasEst)
	oBrowseEst:SetDescription("Dados")
	oBrowseEst:SetAmbiente(.F.)
	oBrowseEst:SetWalkthru(.F.)
	oBrowseEst:DisableDetails()
	oBrowseEst:DisableConfig()
	oBrowseEst:SetMenuDef("")
	oBrowseEst:AddButton("Sair",{|| oDLG:End()},,2)
	oBrowseEst:SetProfileID("1")
	
	For nCount := 1 To Len(aFieldEst)
		oBrowseEst:AddColumn({aFieldEst[nCount][1],;
							     &("{|| (cAliasEst)->" + aFieldEst[nCount][2] + "}"),;
							     aFieldEst[nCount][3],;
							     aFieldEst[nCount][6],;
							     aFieldEst[nCount][7],;
							     aFieldEst[nCount][8],;
							     aFieldEst[nCount][5],;
							     .F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{} } )
	Next nCont
	
	oBrowseEst:Activate()
Return Nil

Static Function Grafico(oGrf,aSerie,oOwner,cTitle)  
	Local nCont
	
	oGrf := FWChartFactory():New()
	oGrf := oGrf:GetInstance(BARCHART)
	oGrf:SetTitle(cTitle,CONTROL_ALIGN_CENTER)
	oGrf:Init(oOwner,.F.)
	oGrf:SetLegend(CONTROL_ALIGN_BOTTOM)
	oGrf:SetPicture("@E 999.99")
	oGrf:SetMask("*@* %")
	
	For nCont := 1 To Len(aSerie)
		oGrf:AddSerie(AllTrim(aSerie[nCont][1]), aSerie[nCont][2])
	Next
	
	oGrf:Build()
Return 

//
// Realiza todas as consultas necessárias no banco de dados e
// adiciona os resultados aos arrays dos gráficos / browse 
//
Static Function CarregaDados()
	Local aRels  := {}
	Local cQuery := ""
	
	aDadosBrw := {}	
	aGrfMov   := {}
	aGrfOco   := {}
	aGrfNeg   := {}
	
	// Romaneios Total x Transportador
	cQuery += "	SELECT COUNT(CASE WHEN GWN_FILIAL = '" + cFil + "' THEN 1 END) TRANSP,"
	cQuery += "		   COUNT(*) TOTAL"
	cQuery += "	  FROM " + RetSQLName("GWN") + " GWN"
	cQuery += "	 WHERE GWN.D_E_L_E_T_ = ' '" + GetWhere("GWN", "GWN_DTIMPL")
	
	aRels := {"Qtd Romaneios", "TOTAL", "TRANSP",,"Un"}
	ExecutaQuery({aRels},cQuery,"aGrfMov")
	
	// Documentos de Carga
	cQuery := ""	 
	cQuery += "	 SELECT COUNT(*) TOTAL,"
	cQuery += "	        COUNT(CASE WHEN GWU_FILIAL = '" + cFil + "' THEN 1 END) TRANSP"
	cQuery += "	   FROM " + RetSQLName("GW1") + " GW1"
	cQuery += "	  INNER JOIN (SELECT DISTINCT GWU_FILIAL, GWU_CDTPDC, GWU_EMISDC, GWU_SERDC, GWU_NRDC, GWU_CDTRP"
	cQuery += "	                FROM " + RetSQLName("GWU")
	cQuery += "	               WHERE D_E_L_E_T_ = ' ' AND GWU_PAGAR = '1') GWU ON GWU.GWU_FILIAL = GW1.GW1_FILIAL"
	cQuery += "	                                           AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC "
	cQuery += "	                                           AND GWU.GWU_EMISDC = GW1.GW1_EMISDC"
	cQuery += "	                                           AND GWU.GWU_SERDC  = GW1.GW1_SERDC"
	cQuery += "	                                           AND GWU.GWU_NRDC   = GW1.GW1_NRDC"
	cQuery += "	  WHERE D_E_L_E_T_ = ' '" + GetWhere("GW1", "GW1_DTEMIS")
	
	aRels := {"Qtd Doc Carga", "TOTAL", "TRANSP",,"Un"}
	ExecutaQuery({aRels},cQuery,"aGrfMov")
	
	// Documentos de Carga Sinistrados
	cQuery := ""	 
	cQuery += "	 SELECT COUNT(*) TOTAL,"
	cQuery += "	        COUNT(CASE WHEN GWU_FILIAL = '" + cFil + "' THEN 1 END) TRANSP"
	cQuery += "	   FROM " + RetSQLName("GW1") + " GW1"
	cQuery += "	  INNER JOIN (SELECT DISTINCT GWU_FILIAL, GWU_CDTPDC, GWU_EMISDC, GWU_SERDC, GWU_NRDC, GWU_CDTRP"
	cQuery += "	                FROM " + RetSQLName("GWU")
	cQuery += "	               WHERE D_E_L_E_T_ = ' ' AND GWU_PAGAR = '1') GWU ON GWU.GWU_FILIAL = GW1.GW1_FILIAL"
	cQuery += "	                                           AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC "
	cQuery += "	                                           AND GWU.GWU_EMISDC = GW1.GW1_EMISDC"
	cQuery += "	                                           AND GWU.GWU_SERDC  = GW1.GW1_SERDC"
	cQuery += "	                                           AND GWU.GWU_NRDC   = GW1.GW1_NRDC"
	cQuery += "     WHERE D_E_L_E_T_ = ' '"
	cQuery += "       AND GW1.GW1_SIT = '8'" + GetWhere("GW1", "GW1_DTEMIS")
	
	aRels := {"Qtd Doc Carga Sinistrados", "TOTAL", "TRANSP",,"Un"}
	ExecutaQuery({aRels},cQuery,"aGrfMov")
	
	// Entregas
	cQuery := ""
	cQuery += "	SELECT COUNT(*) TOTAL, "
	cQuery += "	       COUNT(CASE WHEN GWU_FILIAL = '" + cFil + "' THEN 1 END) TRANSP "
	cQuery += "	  FROM " + RetSQLName("GWU") + " GWU "
	cQuery += "	 WHERE GWU.D_E_L_E_T_ = ' ' AND GWU_PAGAR = '1' " + GetWhere("GWU", "GWU_FILIAL", "GWU_DTENT")
	//cQuery += "	   AND GWU.GWU_DTENT != '' " + GetWhere("GWU", "GWU_DTENT")
	
	aRels := {"Qtd Entregas", "TOTAL", "TRANSP",,"Un"}
	ExecutaQuery({aRels},cQuery,"aGrfMov")
	
	// Entregas em atraso
	cQuery := ""
	cQuery += "    SELECT COUNT(CASE WHEN GWU_DTENT > GWU_DTPENT THEN 1 END) TOTAL, "
	cQuery += "	       COUNT(CASE WHEN GWU_DTENT > GWU_DTPENT AND GWU_FILIAL = '" + cFil + "' THEN 1 END) TRANSP "
	cQuery += "	  FROM " + RetSQLName("GWU") + " GWU "
	cQuery += "	 WHERE GWU.D_E_L_E_T_ = ' ' "
	cQuery += "	   AND GWU.GWU_DTENT != '' " 
	cQuery += "	   AND GWU.GWU_DTPENT != '' AND GWU_PAGAR = '1' " + GetWhere("GWU", "GWU_DTENT")
	
	aRels := {"Qtd entregas em atraso", "TOTAL", "TRANSP",,"Un"}
	ExecutaQuery({aRels},cQuery,"aGrfMov")
	
	// Valor das Cargas, Peso Bruto das Cargas,  Peso Cubado das Cargas, 
	// Peso Alternativo das Cargas, Quantidade de Volumes das Cargas, Volume das Cargas
	cQuery := ""
	cQuery += "  SELECT SUM(GW8_VALOR) VAL_TOT, "
	cQuery += "         SUM(CASE WHEN GWU_FILIAL = '" + cFil + "' THEN GW8_VALOR END) VAL_TRP, "
	cQuery += "         SUM(GW8_PESOR) PEB_TOT, "
	cQuery += "         SUM(CASE WHEN GWU_FILIAL = '" + cFil + "' THEN GW8_PESOR END) PEB_TRP, "
	cQuery += "         SUM(GW8_PESOC) PEC_TOT, "
	cQuery += "         SUM(CASE WHEN GWU_FILIAL = '" + cFil + "' THEN GW8_PESOC END) PEC_TRP, "
	cQuery += "         SUM(GW8_QTDALT) PEA_TOT, "
	cQuery += "         SUM(CASE WHEN GWU_FILIAL = '" + cFil + "' THEN GW8_QTDALT END) PEA_TRP, "
	cQuery += "         SUM(GW8_QTDE) QVL_TOT, "
	cQuery += "         SUM(CASE WHEN GWU_FILIAL = '" + cFil + "' THEN GW8_QTDE END) QVL_TRP, "
	cQuery += "         SUM(GW8_VOLUME) VOL_TOT, "
	cQuery += "         SUM(CASE WHEN GWU_FILIAL = '" + cFil + "' THEN GW8_VOLUME END) VOL_TRP "
	cQuery += "    FROM " + RetSQLName("GW1") + " GW1 "
	cQuery += "   INNER JOIN (SELECT DISTINCT GWU_FILIAL, GWU_CDTPDC, GWU_EMISDC, GWU_SERDC, GWU_NRDC, GWU_CDTRP "
	cQuery += "                FROM " + RetSQLName("GWU")
	cQuery += "               WHERE D_E_L_E_T_ = ' ' AND GWU_PAGAR = '1') GWU ON GWU.GWU_FILIAL = GW1.GW1_FILIAL "
	cQuery += "                                           AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC "
	cQuery += "                                           AND GWU.GWU_EMISDC = GW1.GW1_EMISDC "
	cQuery += "                                           AND GWU.GWU_SERDC  = GW1.GW1_SERDC "
	cQuery += "                                           AND GWU.GWU_NRDC   = GW1.GW1_NRDC "
	cQuery += "   INNER JOIN " + RetSQLName("GW8") + " GW8 ON GW8.GW8_FILIAL = GW1.GW1_FILIAL "
	cQuery += "                        AND GW8.GW8_CDTPDC = GW1.GW1_CDTPDC "
	cQuery += "                        AND GW8.GW8_EMISDC = GW1.GW1_EMISDC "
	cQuery += "                        AND GW8.GW8_SERDC  = GW1.GW1_SERDC "
	cQuery += "                        AND GW8.GW8_NRDC   = GW1.GW1_NRDC "
	cQuery += "   WHERE GW1.D_E_L_E_T_ = ' ' "
	cQuery += "     AND GW8.D_E_L_E_T_ = ' ' " + GetWhere("GW1", "GW1_DTEMIS")
	
	aRels := {{"Valor Cargas", "VAL_TOT", "VAL_TRP","@E 999,999,999.99","$"},;
			   {"Peso Bruto Cargas", "PEB_TOT", "PEB_TRP", "@E 999,999,999.99999","Kg"},;
			   {"Qtd Volumes Cargas", "QVL_TOT", "QVL_TRP",,"Un"},;
			   {"Volume Cargas", "VOL_TOT", "VOL_TRP", "@E 999,999,999.99999","M3"}}
	ExecutaQuery(aRels,cQuery,"aGrfMov")
	
	// Ocorrências: Quantidade, Ocorrências: Valor, Ocorrências: Qtd doc carga
	cQuery := ""  
	cQuery += "	SELECT COUNT(*) OCO_TOT, "
	cQuery += "	       COUNT(CASE WHEN GWD.GWD_FILIAL = '" + cFil + "' THEN 1 END) OCO_TRP, "
	cQuery += "	       SUM(GW1L.QTD_DOCS) QDC_TOT, "
	cQuery += "	       SUM(CASE WHEN GWD.GWD_FILIAL = '" + cFil + "' THEN GW1L.QTD_DOCS END) QDC_TRP, "
	cQuery += "	   	   SUM(GWI_VLFRET) VLO_TOT, "
	cQuery += "	   	   SUM(CASE WHEN GWD.GWD_FILIAL = '" + cFil + "' THEN GWI_VLFRET END) VLO_TRP "
	cQuery += "      FROM " + RetSQLName("GWD") + " GWD "
	cQuery += "     INNER JOIN " + RetSQLName("GU6") + " GU6 ON GU6.GU6_CDMOT = GWD.GWD_CDMOT AND GU6.D_E_L_E_T_ = ' ' "
	cQuery += "      LEFT JOIN ( "
	cQuery += "      	SELECT GWF_FILIAL, GWF_NROCO, SUM(GWI_VLFRET) GWI_VLFRET "
	cQuery += "      	  FROM " + RetSQLName("GWF") + " GWF "
	cQuery += "      	 INNER JOIN " + RetSQLName("GWI") + " GWI ON GWI.D_E_L_E_T_ = ' ' "
	cQuery += "      	                      AND GWI.GWI_TOTFRE = '1' "
	cQuery += "      	                      AND GWI.GWI_NRCALC = GWF.GWF_NRCALC "
	cQuery += "      	                      AND GWI.GWI_FILIAL = GWF.GWF_FILIAL "
	cQuery += "      	 WHERE GWF.D_E_L_E_T_ = ' ' "
	cQuery += "      	 GROUP BY GWF_FILIAL, GWF_NROCO "
	cQuery += "      ) GWFI ON GWFI.GWF_FILIAL = GWD.GWD_FILIAL "
	cQuery += "            AND GWFI.GWF_NROCO  = GWD.GWD_NROCO "
	cQuery += "       LEFT JOIN (SELECT GWL.GWL_NROCO,GWL.GWL_FILIAL, "
	cQuery += "					     COUNT(*) QTD_DOCS "
	cQuery += "   			        FROM " + RetSQLName("GWL") + " GWL "
	cQuery += "   			       INNER JOIN " + RetSQLName("GW1") + " GW1 ON GW1.GW1_FILIAL = GWL.GWL_FILDC "
	cQuery += "					   				    AND GW1.GW1_CDTPDC = GWL.GWL_TPDC "
	cQuery += "					   					AND GW1.GW1_EMISDC = GWL.GWL_EMITDC "
	cQuery += "					   					AND GW1.GW1_SERDC  = GWL.GWL_SERDC "
	cQuery += "					   			   		AND GW1.GW1_NRDC   = GWL.GWL_NRDC "
	cQuery += "					   					AND GW1.D_E_L_E_T_ = ' ' "
	cQuery += "			       WHERE GWL.D_E_L_E_T_ = ' ' "
	cQuery += "			       GROUP BY GWL.GWL_NROCO, GWL.GWL_FILIAL "
	cQuery += "             ) GW1L ON GW1L.GWL_NROCO  = GWD.GWD_NROCO "
	cQuery += "             	   AND GW1L.GWL_FILIAL = GWD.GWD_FILIAL  "
	cQuery += "     WHERE GWD.D_E_L_E_T_ = ' ' " + GetWhere("GWD", "GWD_DTOCOR")
	
	aRels := {{"Qtd Ocorrências", "OCO_TOT", "OCO_TRP",,"Un"},;
			   {"Val Ocorrências", "VLO_TOT", "VLO_TRP", "@E 999,999,999.99","$"},;
			   {"Qtd doc carga Ocorrências", "QDC_TOT", "QDC_TRP",,"Un"}}
	ExecutaQuery(aRels,cQuery,"aGrfOco")
	
	// Cálculos Ajustados
	cQuery := ""
	cQuery += "    SELECT COUNT(*) TOTAL,"
	cQuery += "	       COUNT(CASE WHEN GWF.GWF_FILIAL = '" + cFil + "' THEN 1 END) TRANSP "
	cQuery += "	  FROM " + RetSQLName("GWF") + " GWF "
	cQuery += "	 INNER JOIN " + RetSQLName("GWO") + " GWO ON GWO.GWO_NRCALC = GWF.GWF_NRCALC "
	cQuery += "	 					  AND GWO.D_E_L_E_T_ = ' ' "
	cQuery += "	 WHERE GWF.D_E_L_E_T_ = ' ' " + GetWhere("GWF", "GWF_DTCRIA")
	    
	aRels := {"Qtd Cálculos Ajustados", "TOTAL", "TRANSP",,"Un"}
	ExecutaQuery({aRels},cQuery,"aGrfNeg")
	  
	// Documentos de Frete
	cQuery := ""
	cQuery += "	SELECT COUNT(*) TOTAL, "
	cQuery += "		   COUNT(CASE WHEN GW3.GW3_FILIAL = '" + cFil + "' THEN 1 END) TRANSP "
	cQuery += "	  FROM " + RetSQLName("GW3") + " GW3 "
	cQuery += "	 WHERE GW3.D_E_L_E_T_ = ' ' " + GetWhere("GW3", "GW3_DTENT")
	
	aRels := {"Qtd Documentos Frete", "TOTAL", "TRANSP",,"Un"}
	ExecutaQuery({aRels},cQuery,"aGrfNeg")
	
	// Documentos de Frete com Divergência (por quantidade e valor)
	cQuery := ""
	cQuery += "	SELECT COUNT(*) QTD_TOT, "
	cQuery += "		   COUNT(CASE WHEN GW3.GW3_FILIAL = '" + cFil + "' THEN 1 END) QTD_TRP, "
	cQuery += "		   SUM(GW3_VLDF) VAL_TOT, "
	cQuery += "		   SUM(CASE WHEN GW3.GW3_FILIAL = '" + cFil + "' THEN GW3_VLDF END) VAL_TRP "
	cQuery += "	  FROM " + RetSQLName("GW3") + " GW3 "
	cQuery += "	 WHERE GW3.D_E_L_E_T_ = ' ' "
	cQuery += "	   AND GW3.GW3_SIT IN ('2','4') " + GetWhere("GW3", "GW3_DTENT")
	
	aRels := {{"Qtd Doc Frt Divergente", "QTD_TOT", "QTD_TRP",,"Un"},;
			   {"Val Doc Frt Divergente", "VAL_TOT", "VAL_TRP","@E 999,999,999.99","$"}}
	ExecutaQuery(aRels,cQuery,"aGrfNeg")
	
	// Faturas de Frete
	cQuery := ""
	cQuery += "	SELECT COUNT(*) TOTAL, "
	cQuery += "		   COUNT(CASE WHEN GW6.GW6_FILIAL = '" + cFil + "' THEN 1 END) TRANSP "
	cQuery += "	  FROM " + RetSQLName("GW6") + " GW6 "
	cQuery += "	 WHERE GW6.D_E_L_E_T_ = ' ' " + GetWhere("GW6", "GW6_DTCRIA")
	
	aRels := {"Qtd Faturas Frete", "TOTAL", "TRANSP",,"Un"}
	ExecutaQuery({aRels},cQuery,"aGrfNeg")
	
	// Faturas de Frete com Divergência (por quantidade e valor) 
	cQuery := ""
	cQuery += "	SELECT  COUNT(*) QTD_TOT, "
	cQuery += "		    COUNT(CASE WHEN GW6.GW6_FILIAL = '" + cFil + "' THEN 1 END) QTD_TRP, "
	cQuery += "		    SUM(GW6_VLFATU) VAL_TOT, "
	cQuery += "		    SUM(CASE WHEN GW6.GW6_FILIAL = '" + cFil + "' THEN GW6_VLFATU END) VAL_TRP "
	cQuery += "	  FROM " + RetSQLName("GW6") + " GW6 "
	cQuery += "	 WHERE GW6.D_E_L_E_T_ = ' ' " 
	cQuery += "	   AND GW6.GW6_SITAPR IN ('2','4') " + GetWhere("GW6", "GW6_DTCRIA")
	
	aRels := {{"Qtd Fat Frt Divergente", "QTD_TOT", "QTD_TRP",,"Un"},;
			   {"Val Fat Frt Divergente", "VAL_TOT", "VAL_TRP","@E 999,999,999.99","$"}}
	ExecutaQuery(aRels,cQuery,"aGrfNeg")
	
Return Nil

// 
//	Função para executar consulta e adicionar os dados relacionados aos arrays do 
//	browse e gráfico de estatísticas
//	
//	Parametros:
//	
//	aRels: Relacionamento dos campos na consulta
//	[n,1] = Descrição a ser exibida na série do gráfico e no browse.
//	[n,2] = Campo Valor Total
//	[n,3] = Campo Valor Transportador
//	[n,4] = Picture
//	cQuery: a consulta a ser executada
//  cArrayGrf: nome do array q contém os dados do gráfico
//
Static Function ExecutaQuery(aRels, cQuery, cArrayGrf)
	Local cTmp := ""
	Local nTmp := 0
	Local nCount := 0
	Local cPicture := ""
	
	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	If (cTmp)->(Recno()) > 0 
		For nCount := 1 To Len(aRels)
			cPicture := ""
			If aRels[nCount,4] != Nil
				cPicture := aRels[nCount,4]
			EndIf
			
			nTmp := (cTmp)->&(aRels[nCount,3]) / (cTmp)->&(aRels[nCount,2]) * 100
			aAdd(aDadosBrw, {aRels[nCount,1], ; // Descrição
							   AllTrim(Transform((cTmp)->&(aRels[nCount,2]),cPicture)),; // Total
							   AllTrim(Transform((cTmp)->&(aRels[nCount,3]),cPicture)),; // Transportadora
							   nTmp,;// Porcentagem
							   aRels[nCount,5]}) // Unidade de apresentação 
			aAdd(&(cArrayGrf), {aRels[nCount,1], nTmp})			
		Next nCount
	EndIf
	(cTmp)->(dbCloseArea())
Return Nil

//
// Gera o Where do SQL para uma determinada tabela
// de acordo com os parametros do pergunte
//
//	Parametros
//	cAliasTab: alias da tabela dentro da consulta sql
//	cCampoFil: campo filial da tabela
//	cCampoDt: campo de data da tabela
//
Static Function GetWhere(cAliasTab, cCampoDt)
	Local aFiltros
	aFiltros := {{cAliasTab,cCampoDt,">=",Dtos(dDataDe)},;
				   {cAliasTab,cCampoDt,"<=",Dtos(dDataAte)}}
Return CriaQueryCondicao(aFiltros,"")

Static Function CriaTab(aFields, aIndices)
	Local cAlias
	Local nCont
	Local aStruct := {}
	               
	For nCont := 1 To Len(aFields)
		aADD(aStruct,{aFields[nCont][2],;  //Nome do campo
						aFields[nCont][3],;  //Tipo
						aFields[nCont][4],;  //Tamanho
						aFields[nCont][5]}) //Decimal
	Next nCont
	
	cAlias := GFECriaTab({aStruct,aIndices})
Return cAlias
