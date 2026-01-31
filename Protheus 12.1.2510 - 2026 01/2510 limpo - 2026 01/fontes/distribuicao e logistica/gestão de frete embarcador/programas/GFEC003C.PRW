#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEC003C
Painel Gerencial - Estatísticas

Uso Restrito. 

Param:
aParam[1] := Filial de
aParam[2] := Filial ate
aParam[3] := Data de
aParam[4] := Data até
aParam[5] := CDEmit do cliente 

@sample
GFEC003C(aParam)

@author Alan Victor Lamb
@since 05/07/13
@version 1.0
--------------------------------------------------------------------------------------------------/*/  
Function GFEC003C(aParam)   
	Local aCoors := FWGetDialogSize( oMainWnd )
	Local cTitulo := 'Painel Gerencial - Estatísticas'     
	
	Private aDadosBrw, aGrfMov, aGrfOco, aGrfNeg
	Private oBrowseEst, oGrfMov, oGrfOco, oGrfNeg
	Private oWIN_TOPL, oWIN_TOPR, oWIN_BOTL, oWIN_BOTR
	
	Private cAliasEst, aIndEst, aFieldEst
	
	Private cFilialDe       := aParam[1]
	Private cFilialAte      := aParam[2]
	Private dDataDe         := If(Empty(aParam[3]),DDATABASE - 30,aParam[3])
	Private dDataAte        := If(Empty(aParam[4]),DDATABASE     ,aParam[4])
	Private cCdCliente      := aParam[5]
	
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
	Local cCliName := ""
	Local nCount
	
	CarregaDados()
	
	Grafico(oGrfMov,aGrfMov,oWIN_TOPL,"Movimentação") 
	Grafico(oGrfOco,aGrfOco,oWIN_TOPR,"Ocorrências") 
	Grafico(oGrfNeg,aGrfNeg,oWIN_BOTL,"Negociação e Auditoria") 
	
	cCliName := AllTrim(POSICIONE("GU3",1,xFilial("GU3")+cCdCliente,"GU3_NMEMIT"))
	
	If Len(cCliName) > 20
		cCliName := SUBSTR(cCliName, 1, 17) + "..."
	EndIf
	
	aFieldEst := ;
	{{"Descrição"	,"DESCRI" ,"C",25,0,"",1,10},;
	{"UN"	   	    ,"UNIDAD" ,"C",2,0,"",1,2},;
	{cCliName       ,"VALEMI" ,"C",15,0,"",1,10},;
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
		MsUnlock(cAliasEst)
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
	Local cMVGFE015	:= SuperGetMV("MV_GFE015",,"1")
	
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
	
	If cMVGFE015 == "2"
 		oGrf:oFwChartColor:SetColor("RANDOM")
 	EndIf
	
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
	
	// Documentos de Carga
	cQuery := ""	 
	cQuery += "	 SELECT COUNT(*) TOTAL,"
	cQuery += "	        COUNT(CASE WHEN GW1_CDREM = '" + cCdCliente + "' OR GW1_CDDEST = '" + cCdCliente + "' THEN 1 END) TRANSP"
	cQuery += "	   FROM " + RetSQLName("GW1") + " GW1 "
	cQuery += "	  INNER JOIN (SELECT DISTINCT GWU_FILIAL, GWU_CDTPDC, GWU_EMISDC, GWU_SERDC, GWU_NRDC"
	cQuery += "	                FROM " + RetSQLName("GWU")
	cQuery += "	               WHERE D_E_L_E_T_ = ' ' AND GWU_PAGAR = '1') GWU ON GWU.GWU_FILIAL = GW1.GW1_FILIAL"
	cQuery += "	                                           AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC "
	cQuery += "	                                           AND GWU.GWU_EMISDC = GW1.GW1_EMISDC"
	cQuery += "	                                           AND GWU.GWU_SERDC  = GW1.GW1_SERDC"
	cQuery += "	                                           AND GWU.GWU_NRDC   = GW1.GW1_NRDC"
	cQuery += "	  WHERE D_E_L_E_T_ = ' '" + GetWhere("GW1", "GW1_FILIAL", "GW1_DTEMIS")
	
	aRels := {"Qtd Doc Carga", "TOTAL", "TRANSP",,"Un"}
	ExecutaQuery({aRels},cQuery,"aGrfMov")
	
	// Documentos de Carga Sinistrados
	cQuery := ""	 
	cQuery += "	 SELECT COUNT(*) TOTAL,"
	cQuery += "	        COUNT(CASE WHEN GW1_CDREM = '" + cCdCliente + "' OR GW1_CDDEST = '" + cCdCliente + "' THEN 1 END) TRANSP"
	cQuery += "	   FROM " + RetSQLName("GW1") + " GW1"
	cQuery += "	  INNER JOIN (SELECT DISTINCT GWU_FILIAL, GWU_CDTPDC, GWU_EMISDC, GWU_SERDC, GWU_NRDC"
	cQuery += "	                FROM " + RetSQLName("GWU")
	cQuery += "	               WHERE D_E_L_E_T_ = ' ' AND GWU_PAGAR = '1') GWU ON GWU.GWU_FILIAL = GW1.GW1_FILIAL"
	cQuery += "	                                           AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC "
	cQuery += "	                                           AND GWU.GWU_EMISDC = GW1.GW1_EMISDC"
	cQuery += "	                                           AND GWU.GWU_SERDC  = GW1.GW1_SERDC"
	cQuery += "	                                           AND GWU.GWU_NRDC   = GW1.GW1_NRDC"
	cQuery += "     WHERE D_E_L_E_T_ = ' '"
	cQuery += "       AND GW1.GW1_SIT = '8'" + GetWhere("GW1", "GW1_FILIAL", "GW1_DTEMIS")
	
	aRels := {"Qtd Doc Carga Sinistrados", "TOTAL", "TRANSP",,"Un"}
	ExecutaQuery({aRels},cQuery,"aGrfMov")
	
	// Entregas
	cQuery := ""
	cQuery += " SELECT COUNT(*) TOTAL,"
	cQuery += "        COUNT(CASE WHEN GW1_CDREM = '" + cCdCliente + "' OR GW1_CDDEST = '" + cCdCliente + "' THEN 1 END) CLI "
	cQuery += "   FROM " + RetSQLName("GW1") + " GW1 "
	cQuery += "  INNER JOIN " + RetSQLName("GWU") + " GWU ON GWU.GWU_FILIAL = GW1.GW1_FILIAL "
	cQuery += " 					  AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC "
	cQuery += " 					  AND GWU.GWU_EMISDC = GW1.GW1_EMISDC "
	cQuery += " 					  AND GWU.GWU_SERDC  = GW1.GW1_SERDC "
	cQuery += " 					  AND GWU.GWU_NRDC   = GW1.GW1_NRDC "
	cQuery += " 					  AND GWU.GWU_PAGAR = '1' "
	cQuery += " 					  AND GWU.D_E_L_E_T_ = ' ' "
	cQuery += "  WHERE GW1.D_E_L_E_T_ = ' ' " + GetWhere("GW1", "GW1_FILIAL", "GW1_DTEMIS")
	aRels := {"Qtd Entregas", "TOTAL", "CLI",,"Un"}
	ExecutaQuery({aRels},cQuery,"aGrfMov")
	
	// Entregas em atraso
	
	cQuery := ""
	cQuery += "    SELECT COUNT(CASE WHEN GWU_DTENT > GWU_DTPENT THEN 1 END) TOTAL, "
	cQuery += "        	 COUNT(CASE WHEN GWU_DTENT > GWU_DTPENT AND (GW1_CDREM = '" + cCdCliente + "' OR GW1_CDDEST = '" + cCdCliente + "') THEN 1 END) CLI "
	cQuery += "   FROM " + RetSQLName("GW1") + " GW1 "
	cQuery += "  INNER JOIN " + RetSQLName("GWU") + " GWU ON GWU.GWU_FILIAL = GW1.GW1_FILIAL "
	cQuery += " 					  AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC "
	cQuery += " 					  AND GWU.GWU_EMISDC = GW1.GW1_EMISDC "
	cQuery += " 					  AND GWU.GWU_SERDC  = GW1.GW1_SERDC "
	cQuery += " 					  AND GWU.GWU_NRDC   = GW1.GW1_NRDC "
	cQuery += " 					  AND GWU.GWU_PAGAR = '1' "
	cQuery += " 					  AND GWU.D_E_L_E_T_ = ' ' "
	cQuery += "	                AND GWU.GWU_DTENT != '' " 
	cQuery += "                   AND GWU.GWU_DTPENT != '' "
	cQuery += "  WHERE GW1.D_E_L_E_T_ = ' ' " + GetWhere("GW1", "GW1_FILIAL", "GW1_DTEMIS")
	
	aRels := {"Qtd Entregas em atraso", "TOTAL", "CLI",,"Un"}
	ExecutaQuery({aRels},cQuery,"aGrfMov")
	
	
	// Valor das Cargas, Peso Bruto das Cargas,  Peso Cubado das Cargas, 
	// Peso Alternativo das Cargas, Quantidade de Volumes das Cargas, Volume das Cargas
	cQuery := ""
	cQuery += "  SELECT SUM(GW8_VALOR) VAL_TOT, "
	cQuery += "         SUM(CASE WHEN GW1_CDREM = '" + cCdCliente + "' OR GW1_CDDEST = '" + cCdCliente + "' THEN GW8_VALOR END) VAL_TRP, "
	cQuery += "         SUM(GW8_PESOR) PEB_TOT, "
	cQuery += "         SUM(CASE WHEN GW1_CDREM = '" + cCdCliente + "' OR GW1_CDDEST = '" + cCdCliente + "' THEN GW8_PESOR END) PEB_TRP, "
	cQuery += "         SUM(GW8_PESOC) PEC_TOT, "
	cQuery += "         SUM(CASE WHEN GW1_CDREM = '" + cCdCliente + "' OR GW1_CDDEST = '" + cCdCliente + "' THEN GW8_PESOC END) PEC_TRP, "
	cQuery += "         SUM(GW8_QTDALT) PEA_TOT, "
	cQuery += "         SUM(CASE WHEN GW1_CDREM = '" + cCdCliente + "' OR GW1_CDDEST = '" + cCdCliente + "' THEN GW8_QTDALT END) PEA_TRP, "
	cQuery += "         SUM(GW8_QTDE) QVL_TOT, "
	cQuery += "         SUM(CASE WHEN GW1_CDREM = '" + cCdCliente + "' OR GW1_CDDEST = '" + cCdCliente + "' THEN GW8_QTDE END) QVL_TRP, "
	cQuery += "         SUM(GW8_VOLUME) VOL_TOT, "
	cQuery += "         SUM(CASE WHEN GW1_CDREM = '" + cCdCliente + "' OR GW1_CDDEST = '" + cCdCliente + "' THEN GW8_VOLUME END) VOL_TRP "
	cQuery += "    FROM " + RetSQLName("GW1") + " GW1 "
	cQuery += "   INNER JOIN (SELECT DISTINCT GWU_FILIAL, GWU_CDTPDC, GWU_EMISDC, GWU_SERDC, GWU_NRDC "
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
	cQuery += "     AND GW8.D_E_L_E_T_ = ' ' " + GetWhere("GW1", "GW1_FILIAL", "GW1_DTEMIS")
	
	aRels := {{"Valor Cargas", "VAL_TOT", "VAL_TRP","@E 999,999,999.99","$"},;
			   {"Peso Bruto Cargas", "PEB_TOT", "PEB_TRP", "@E 999,999,999.99999","Kg"},;
			   {"Qtd Volumes Cargas", "QVL_TOT", "QVL_TRP",,"Un"},;
			   {"Volume Cargas", "VOL_TOT", "VOL_TRP", "@E 999,999,999.99999","M3"}}
			   
	ExecutaQuery(aRels,cQuery,"aGrfMov")
	
	// Ocorrências: Quantidade, Ocorrências: Valor, Ocorrências: Qtd doc carga
	cQuery := ""
	cQuery += " SELECT SUM(QTD_CLI) QTD_CLI, "
	cQuery += "        SUM(QTD_TOT) QTD_TOT, "
	cQuery += "        SUM(QDC_CLI) QDC_CLI, "
	cQuery += "        SUM(QDC_TOT) QDC_TOT, "
	cQuery += "        SUM(VLO_CLI) VLO_CLI, "
	cQuery += "        SUM(VLO_TOT) VLO_TOT "
	cQuery += "   FROM ( "
	cQuery += "      SELECT COUNT(*) AS QTD_CLI, "
	cQuery += "      		0 AS QTD_TOT, "
	cQuery += "      		SUM(GW1L.QTD_DOCS) QDC_CLI, "
	cQuery += " 	        0 QDC_TOT, "
	cQuery += " 	      	SUM(GWI_VLFRET) VLO_CLI, "
	cQuery += " 	     	0 VLO_TOT " 
	cQuery += "        FROM " + RetSQLName("GWD") + " GWD "
	cQuery += "       INNER JOIN ( "
	cQuery += "       		SELECT DISTINCT GWL_NROCO "
	cQuery += " 			  FROM " + RetSQLName("GWL") + " GWL "
	cQuery += " 			 INNER JOIN " + RetSQLName("GW1") + " GW1 ON GW1.GW1_FILIAL = GWL.GWL_FILDC"
	cQuery += " 			                      AND GW1.GW1_CDTPDC = GWL.GWL_TPDC"
	cQuery += " 			                      AND GW1.GW1_EMISDC = GWL.GWL_EMITDC"
	cQuery += " 			                      AND GW1.GW1_SERDC  = GWL.GWL_SERDC"
	cQuery += " 			                      AND GW1.GW1_NRDC   = GWL.GWL_NRDC"
	cQuery += " 			                      AND GW1.D_E_L_E_T_ = ' '"
	cQuery += " 			                      AND (GW1.GW1_CDDEST = '"+cCdCliente+"' OR GW1.GW1_CDREM = '"+cCdCliente+"') " + GetWhere("GW1", "GW1_FILIAL", "GW1_DTEMIS")
	cQuery += " 			 WHERE GWL.D_E_L_E_T_ = ' '"
	cQuery += "       ) OCOS ON GWD.GWD_NROCO = OCOS.GWL_NROCO "
	cQuery += "       LEFT JOIN ( "
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
	cQuery += " 	  LEFT JOIN ( SELECT GWL.GWL_NROCO,GWL.GWL_FILIAL, "
	cQuery += " 				     	 COUNT(*) QTD_DOCS "
	cQuery += "   			        FROM " + RetSQLName("GWL") + " GWL "
	cQuery += "   			       INNER JOIN " + RetSQLName("GW1") + " GW1 ON GW1.GW1_FILIAL = GWL.GWL_FILDC "
	cQuery += " 				   				    AND GW1.GW1_CDTPDC = GWL.GWL_TPDC "
	cQuery += " 				   					AND GW1.GW1_EMISDC = GWL.GWL_EMITDC "
	cQuery += " 				   					AND GW1.GW1_SERDC  = GWL.GWL_SERDC "
	cQuery += " 				   			   		AND GW1.GW1_NRDC   = GWL.GWL_NRDC "
	cQuery += " 				   					AND GW1.D_E_L_E_T_ = ' ' "
	cQuery += " 		       WHERE GWL.D_E_L_E_T_ = ' ' "
	cQuery += " 		       GROUP BY GWL.GWL_NROCO, GWL.GWL_FILIAL "
	cQuery += "             ) GW1L ON GW1L.GWL_NROCO  = GWD.GWD_NROCO "
	cQuery += "             	   AND GW1L.GWL_FILIAL = GWD.GWD_FILIAL  "
	cQuery += "     WHERE GWD.D_E_L_E_T_ = ' '     "
	cQuery += "  UNION ALL 			 "
	cQuery += "    SELECT 0  AS QTD_CLI, "  
	cQuery += "     	  COUNT(*) AS QTD_TOT, "
	cQuery += "      	  0 QDC_CLI, "
	cQuery += " 	      SUM(GW1L.QTD_DOCS) QDC_TOT, "
	cQuery += " 	      0 VLO_CLI, "
	cQuery += " 	      SUM(GWI_VLFRET) VLO_TOT "
	cQuery += "      FROM " + RetSQLName("GWD") + " GWD "
	cQuery += "     INNER JOIN ("
	cQuery += "     	SELECT DISTINCT GWL_NROCO"
	cQuery += " 		  FROM " + RetSQLName("GWL") + " GWL "
	cQuery += " 		 INNER JOIN " + RetSQLName("GW1") + " GW1 ON GW1.GW1_FILIAL = GWL.GWL_FILDC "
	cQuery += " 		                      AND GW1.GW1_CDTPDC = GWL.GWL_TPDC "
	cQuery += " 		                      AND GW1.GW1_EMISDC = GWL.GWL_EMITDC "
	cQuery += " 		                      AND GW1.GW1_SERDC  = GWL.GWL_SERDC "
	cQuery += " 		                      AND GW1.GW1_NRDC   = GWL.GWL_NRDC "
	cQuery += " 		                      AND GW1.D_E_L_E_T_ = ' ' " + GetWhere("GW1", "GW1_FILIAL", "GW1_DTEMIS")
	cQuery += " 		 WHERE GWL.D_E_L_E_T_ = ' ' "
	cQuery += "     ) OCOS ON GWD.GWD_NROCO = OCOS.GWL_NROCO "
	cQuery += "     LEFT JOIN ( "
	cQuery += "     	SELECT GWF_FILIAL, GWF_NROCO, SUM(GWI_VLFRET) GWI_VLFRET "
	cQuery += "      	  FROM " + RetSQLName("GWF") + " GWF "
	cQuery += "      	 INNER JOIN " + RetSQLName("GWI") + " GWI ON GWI.D_E_L_E_T_ = ' ' "
	cQuery += "      	                      AND GWI.GWI_TOTFRE = '1' "
	cQuery += "      	                      AND GWI.GWI_NRCALC = GWF.GWF_NRCALC "
	cQuery += "      	                      AND GWI.GWI_FILIAL = GWF.GWF_FILIAL "
	cQuery += "      	 WHERE GWF.D_E_L_E_T_ = ' ' "
	cQuery += "      	 GROUP BY GWF_FILIAL, GWF_NROCO "
	cQuery += "      ) GWFI ON GWFI.GWF_FILIAL = GWD.GWD_FILIAL "
	cQuery += "            AND GWFI.GWF_NROCO  = GWD.GWD_NROCO "
	cQuery += " 	  LEFT JOIN ( SELECT GWL.GWL_NROCO,GWL.GWL_FILIAL, "
	cQuery += " 				     	 COUNT(*) QTD_DOCS "
	cQuery += "   			        FROM " + RetSQLName("GWL") + " GWL "
	cQuery += "   			       INNER JOIN " + RetSQLName("GW1") + " GW1 ON GW1.GW1_FILIAL = GWL.GWL_FILDC "
	cQuery += " 				   				    AND GW1.GW1_CDTPDC = GWL.GWL_TPDC "
	cQuery += " 				   					AND GW1.GW1_EMISDC = GWL.GWL_EMITDC "
	cQuery += " 				   					AND GW1.GW1_SERDC  = GWL.GWL_SERDC "
	cQuery += " 				   			   		AND GW1.GW1_NRDC   = GWL.GWL_NRDC "
	cQuery += " 				   					AND GW1.D_E_L_E_T_ = ' ' "
	cQuery += " 		       WHERE GWL.D_E_L_E_T_ = ' ' "
	cQuery += " 		       GROUP BY GWL.GWL_NROCO, GWL.GWL_FILIAL "
	cQuery += "             ) GW1L ON GW1L.GWL_NROCO  = GWD.GWD_NROCO "
	cQuery += "             	   AND GW1L.GWL_FILIAL = GWD.GWD_FILIAL  "
	cQuery += "     WHERE GWD.D_E_L_E_T_ = ' '"
	cQuery += "  	) AUX"
	
	aRels := {{"Qtd Ocorrências", "QTD_TOT", "QTD_CLI",,"Un"},;
			   {"Val Ocorrências", "VLO_TOT", "VLO_CLI", "@E 999,999,999.99","$"},;
			   {"Qtd doc carga Ocorrências", "QDC_TOT", "QDC_CLI",,"Un"}}
	
	ExecutaQuery(aRels,cQuery,"aGrfOco")
	
	// Valor de frete Previsto x Realizado
	cQuery := ""
	cQuery += "	SELECT SUM(CASE WHEN GWM_TPDOC = '1' THEN GWM.GWM_VLFRET END) TOT_PRV, "
	cQuery += " 	       SUM(CASE WHEN GWM_TPDOC = '1' AND (GW1.GW1_CDREM = '" + cCdCliente + "' OR GW1.GW1_CDDEST = '" + cCdCliente + "') THEN GWM.GWM_VLFRET END) CLI_PRV, "
	cQuery += " 	       SUM(CASE WHEN GWM_TPDOC IN ('2','3') THEN GWM.GWM_VLFRET END) TOT_REA, "
	cQuery += " 	       SUM(CASE WHEN GWM_TPDOC IN ('2','3') AND (GW1.GW1_CDREM = '" + cCdCliente + "' OR GW1.GW1_CDDEST = '" + cCdCliente + "') THEN GWM.GWM_VLFRET END) CLI_REA "
	cQuery += " 	  FROM " + RetSQLName("GW1") + " GW1 "
	cQuery += " 	  LEFT JOIN ( "
	cQuery += "      	SELECT GWM.GWM_FILIAL, GWM.GWM_CDTPDC, GWM.GWM_EMISDC, GWM.GWM_SERDC, "
	cQuery += "      	       GWM.GWM_NRDC, GWM_TPDOC, SUM(GWM_VLFRET) GWM_VLFRET "
	cQuery += "		  FROM " + RetSQLName("GWM") + " GWM "
	cQuery += "		 WHERE GWM.D_E_L_E_T_ = ' ' "
	cQuery += "		 GROUP BY GWM.GWM_FILIAL, GWM.GWM_CDTPDC, GWM.GWM_EMISDC, GWM.GWM_SERDC, "
	cQuery += "		          GWM.GWM_NRDC,GWM_TPDOC "
	cQuery += "      ) GWM ON GWM.GWM_FILIAL = GW1.GW1_FILIAL "
	cQuery += "              AND GWM.GWM_CDTPDC = GW1.GW1_CDTPDC "
	cQuery += "              AND GWM.GWM_EMISDC = GW1.GW1_EMISDC "
	cQuery += "              AND GWM.GWM_SERDC  = GW1.GW1_SERDC "
	cQuery += "              AND GWM.GWM_NRDC   = GW1.GW1_NRDC "
	cQuery += "     WHERE GW1.D_E_L_E_T_ = ' ' " + GetWhere("GW1", "GW1_FILIAL", "GW1_DTEMIS")
	
	aRels := {{"Val Frete Previsto", "TOT_PRV", "CLI_PRV", "@E 999,999,999.99","$"},;
			   {"Val Frete Realizado", "TOT_REA", "CLI_REA", "@E 999,999,999.99","$"}}
	
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
Static Function GetWhere(cAliasTab, cCampoFil, cCampoDt)
	Local aFiltros
	aFiltros := {{cAliasTab,cCampoFil,">=",cFilialDe},;
				   {cAliasTab,cCampoFil,"<=",cFilialAte},;   
				   {cAliasTab,cCampoDt,">=",Dtos(dDataDe)},;
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
