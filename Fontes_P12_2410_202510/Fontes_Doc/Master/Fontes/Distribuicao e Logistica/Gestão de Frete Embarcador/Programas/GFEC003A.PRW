#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEC003A
Painel Gerencial Clientes - Informações sobre Documentos de Carga

Uso Restrito. 

Param:
aParam[1] := Filial de
aParam[2] := Filial ate
aParam[3] := Data de
aParam[4] := Data até
aParam[5] := CDEmit do cliente 

@sample
GFEC003A(aParam)

@author Alan Victor Lamb
@since 03/07/13
@version 1.0
--------------------------------------------------------------------------------------------------/*/  
Function GFEC003A(aParam)
	Local aCoors := FWGetDialogSize(oMainWnd)
	Local cTitulo := 'Painel Gerencial - Cliente'
	
	Private oGrfSit, oGrfVal, oGrfPes, oGrfReg, oGrfCum, oGrfSReg
	Private aBrowse, aGrfSit, aGrfVal, aGrfPes, aGrfEnt, aGrfReg, aGrfCum, aGrfSReg, aBrowseTrp
	Private oBrowseEst, oBrowseTrp
	Private cFilialDe       := aParam[1]
	Private cFilialAte      := aParam[2]
	Private dDataDe         := If(Empty(aParam[3]),DDATABASE - 30,aParam[3])
	Private dDataAte        := If(Empty(aParam[4]),DDATABASE     ,aParam[4])
	Private cCdCliente      := aParam[5]
	Private aFiltros
	Private cFilRem, cFilDest
	
	Private oWIN_TOP, oWIN_LEFT, oWIN_MIDDLE, oWIN_RIGHT, oWIN_TRANSP
	
	Private oFolderPrin
	
	//Carrega os dados do Grafico e do Resumo  
	aFiltros := {{"GW1","GW1_FILIAL",">=",cFilialDe	   },;
			      {"GW1","GW1_FILIAL","<=",cFilialAte     },;
				  {"GW1","GW1_DTEMIS",">=",DtoS(dDataDe)  },;
				  {"GW1","GW1_DTEMIS","<=",DtoS(dDataAte) }}  
	
	Define MsDialog oDLG Title cTitulo From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
	
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDLG,.F.)
	
	oFWLayer:AddLine('LINE_TOP',45,.F.)
	oFWLayer:AddLine( 'LINE_BOTTOM',55,.F.)
	oFWLayer:AddCollumn('COL_TOP',100,.T.,'LINE_TOP')
	oFWLayer:AddCollumn('COL_BOTTOM',100,.T.,'LINE_BOTTOM')
	
	oWIN_TOP     := oFWLayer:GetColPanel('COL_TOP','LINE_TOP')
	oWIN_BOTTOM := oFWLayer:GetColPanel('COL_BOTTOM','LINE_BOTTOM')
	
	oFolderPrin := TFolder():New(0,0,{"Geral","por Transportador"},,oWIN_BOTTOM,,,,.T.,,(oWIN_BOTTOM:nwidth/2),(oWIN_BOTTOM:nHeight/2))
	oFolderPrin:Align := CONTROL_ALIGN_ALLCLIENT
	
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oFolderPrin:aDialogs[1],.F.)
	oFWLayer:AddLine('LINE',100,.F.)
	oFWLayer:AddCollumn('COL_LEFT',33,.T.,'LINE')
  	oFWLayer:AddCollumn('COL_MIDDLE',34,.T.,'LINE')
  	oFWLayer:AddCollumn('COL_RIGHT',33,.T.,'LINE')
  	oFWLayer:AddWindow('COL_LEFT','WIN_LEFT','Estatísticas',100,.F.,.F.,,'LINE',)
  	oFWLayer:AddWindow('COL_MIDDLE','WIN_MIDDLE','Gráficos por Situação',100,.F.,.F.,,'LINE',)
  	oFWLayer:AddWindow('COL_RIGHT','WIN_RIGHT','Cumprimento de Prazo dos Documentos de Carga',100,.F.,.F.,,'LINE',)
    
    oWIN_LEFT  := oFWLayer:GetWinPanel('COL_LEFT','WIN_LEFT', 'LINE')
    oWIN_MIDDLE := oFWLayer:GetWinPanel('COL_MIDDLE','WIN_MIDDLE', 'LINE')
    oWIN_RIGHT := oFWLayer:GetWinPanel('COL_RIGHT','WIN_RIGHT', 'LINE')
	 
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oFolderPrin:aDialogs[2],.F.)
	oFWLayer:AddLine('LINE',100,.F.)
	oFWLayer:AddCollumn('COL',100,.T.,'LINE')
  	oFWLayer:AddWindow('COL','WIN_TRANSP','Transportador',100,.F.,.F.,,'LINE',)
  	
    oWIN_TRANSP := oFWLayer:GetWinPanel('COL','WIN_TRANSP', 'LINE')
     
    oDLG:Activate(,,,.T.,,,{||Processa({||Iniciar()})})
Return 

Static Function GetSituacao()
	Local aSituacao := StrToKArr(Posicione("SX3",2,"GW1_SIT","X3_CBOX"),";")
	Local cRet
	
	If !Empty(GW1->GW1_SIT) .AND.;
	   Val(GW1->GW1_SIT) > 0 .AND.;
	   Val(GW1->GW1_SIT) <= Len(aSituacao)
		cRet := SUBSTR(aSituacao[Val(GW1->GW1_SIT)],3)
	EndIf
Return cRet 

Static Function Iniciar()
	Local cFiltroBrowse := ''
	
	cFiltroBrowse := "(GW1_CDREM == '" + cCdCliente + "' .OR. GW1_CDDEST == '" + cCdCliente + "') .AND. "+;
	                   "GW1_FILIAL >= '" + cFilialDe + "' .AND. GW1_FILIAL <= '" + cFilialAte + "' .AND. "+;
	                   "GW1_DTEMIS >= '"+DtoS(dDataDe)+"' .AND. GW1_DTEMIS <= '"+DtoS(dDataAte)+"'"
	
	CarregaDados(aFiltros)
	
	cFilRem   := "GW1_CDREM == '" + cCdCliente + "'"
	cFilDest  := "GW1_CDDEST == '" + cCdCliente + "'"
	
	//Browse Doc carga
	oBrowseDoc:= FWMBrowse():New()
	oBrowseDoc:SetOwner(oWIN_TOP)
	oBrowseDoc:SetDescription("Documentos de Carga")
	oBrowseDoc:SetAlias('GW1')
	oBrowseDoc:SetLocate()
	oBrowseDoc:DisableDetails()
	oBrowseDoc:SetAmbiente(.F.)
	oBrowseDoc:SetWalkthru(.F.)
	oBrowseDoc:SetProfileID("1")
	oBrowseDoc:ForceQuitButton(.T.)
	oBrowseDoc:SetFilterDefault(cFiltroBrowse)
	oBrowseDoc:AddFilter("somente como Remetente", cFilRem)
	oBrowseDoc:AddFilter("somente como Destinatário", cFilDest)
	oBrowseDoc:BVLDEXECFILTER := {|aParam| GFEC003AV(aParam)}
	oBrowseDoc:SetMenuDef("")
	oBrowseDoc:AddButton("Visualizar","VIEWDEF.GFEC040",,2)
	oBrowseDoc:SetFields({{"Situação", {|| GetSituacao() }, "C","",1,10,0,.F.}})
	oBrowseDoc:Activate()
	
	Define Font oFont Name 'Courier New' Size 0, -12
	 
   	oBrowseEst := FWBrowse():New()
	oBrowseEst:SetOwner(oWIN_LEFT)
	oBrowseEst:SetDescription("Dados")
	oBrowseEst:SetDataArray()
	oBrowseEst:DisableFilter()
	oBrowseEst:DisableConfig()
	oBrowseEst:SetArray(aBrowse)
   	oBrowseEst:SetColumns(GFEC001COL("Descrição",1,,1,20,"oBrowseEst"))
	oBrowseEst:SetColumns(GFEC001COL("Unidade",2,,1,2,"oBrowseEst"))
	oBrowseEst:SetColumns(GFEC001COL("Conteúdo",3,,1,20,"oBrowseEst"))
	oBrowseEst:Activate()
	
	oFolder := TFolder():New(0,0,{"Quantidade Documentos","Valor Carga", "Peso Carga"},,oWIN_MIDDLE,,,,.T.,,(oWIN_MIDDLE:nwidth/2),(oWIN_MIDDLE:nHeight/2))
	oFolder:Align := CONTROL_ALIGN_ALLCLIENT
	
	GFEC001GRC("oGrfSit", "Quantidade Doc Carga",oFolder:aDialogs[1],aGrfSit)
	GFEC001GRC("oGrfVal", "Valor Carga",oFolder:aDialogs[2],aGrfVal)
	GFEC001GRC("oGrfPes", "Peso Carga",oFolder:aDialogs[3],aGrfPes)
	
	oFolder := TFolder():New(0,0,{"Registro de entregas", "Cumprimento de prazo", "Sem registro de entrega"},,oWIN_RIGHT,,,,.T.,,(oWIN_RIGHT:nwidth/2),(oWIN_RIGHT:nHeight/2))
	oFolder:Align := CONTROL_ALIGN_ALLCLIENT
	
	GFEC001GRC("oGrfReg", "Registro de entregas",oFolder:aDialogs[1],aGrfReg)
	GFEC001GRC("oGrfCum", "Cumprimento de prazo",oFolder:aDialogs[2],aGrfCum)
	GFEC001GRC("oGrfSReg", "Sem registro de entrega",oFolder:aDialogs[3],aGrfSReg)
	
	oBrowseTrp := FWBrowse():New()
	oBrowseTrp:SetOwner(oWIN_TRANSP)
	oBrowseTrp:SetDescription("Dados")
	oBrowseTrp:SetDataArray()
	oBrowseTrp:DisableFilter()
	oBrowseTrp:DisableConfig()
	oBrowseTrp:SetArray(aBrowseTrp)
   	oBrowseTrp:SetColumns(GFEC001COL("Cod Transp",1,,1,5,"oBrowseTrp"))
	oBrowseTrp:SetColumns(GFEC001COL("Nome",2,,1,20,"oBrowseTrp"))
	oBrowseTrp:SetColumns(GFEC001COL("Qtd Doc Carga",3,,2,8,"oBrowseTrp"))
	oBrowseTrp:SetColumns(GFEC001COL("Doc mais Recente",4,,2,8,"oBrowseTrp"))
	oBrowseTrp:SetColumns(GFEC001COL("Peso Carga Total",5,"@E 99,999,999.99999",2,8,"oBrowseTrp"))
	oBrowseTrp:SetColumns(GFEC001COL("Valor Carga Total",6,"@E 999,999,999.99",2,8,"oBrowseTrp"))
	oBrowseTrp:SetColumns(GFEC001COL("Volume Carga Total",7,"@E 99,999,999.99999",2,8,"oBrowseTrp"))
	oBrowseTrp:SetColumns(GFEC001COL("Valor Frete Calculado",8,"@E 999,999,999.99",2,8,"oBrowseTrp"))
	oBrowseTrp:SetColumns(GFEC001COL("$ Frete por kg",9,"@E 999,999,999.99",2,8,"oBrowseTrp"))
	oBrowseTrp:SetColumns(GFEC001COL("$ Frete por m3",10,"@E 999,999,999.99",2,8,"oBrowseTrp"))
	oBrowseTrp:SetColumns(GFEC001COL("% Frete Valor Carga",11,"@E 9,999.99",2,6,"oBrowseTrp"))
	oBrowseTrp:SetColumns(GFEC001COL("Qtde Ocorr Total",12,,2,8,"oBrowseTrp"))
	oBrowseTrp:SetColumns(GFEC001COL("Qtde Ocorr Provoc",13,,2,8,"oBrowseTrp"))
	oBrowseTrp:Activate()
Return Nil

//---------------------------------------------------------------------------------------------------            
Static Function CarregaDados(aFiltros,cBrwFiltro)
	Local cQuery   := ''
	Local cTmp     := ''
	Local nTotCalc := 0
	Local nTmpPeso := 0
	Local nTmpValC := 0
	Local nTmpVolC := 0
	Default cBrwFiltro := ''
	
	aGrfSit  := {}
	aGrfPes  := {}
	aGrfVal  := {}
	aGrfReg  := {}
	aGrfCum  := {}
	aGrfSReg := {}
	aBrowse  := {}
	aBrowseTrp := {}
	
	cQuery += "	SELECT COUNT(CASE WHEN GW1.GW1_SIT = '1' THEN 1 END) GW1_SITDIG, "
	cQuery += "		   COUNT(CASE WHEN GW1.GW1_SIT = '2' THEN 1 END) GW1_SITBLO, "
	cQuery += "	       COUNT(CASE WHEN GW1.GW1_SIT = '3' THEN 1 END) GW1_SITLIB, "
	cQuery += "	       COUNT(CASE WHEN GW1.GW1_SIT = '4' THEN 1 END) GW1_SITEMB, "
	cQuery += "	       COUNT(CASE WHEN GW1.GW1_SIT = '5' THEN 1 END) GW1_SITENT, "
	cQuery += "	       COUNT(CASE WHEN GW1.GW1_SIT = '6' THEN 1 END) GW1_SITRET, "
	cQuery += "	       COUNT(CASE WHEN GW1.GW1_SIT = '7' THEN 1 END) GW1_SITCAN, "
	cQuery += "	       COUNT(CASE WHEN GW1.GW1_SIT = '8' THEN 1 END) GW1_SITSIN, "
	cQuery += "	       COUNT(*) GW1_TOTAL, "
	cQuery += "	       SUM(CASE WHEN GW1.GW1_SIT = '1' THEN GW8.GW8_VALOR ELSE 0 END) VAL_SIT1, "
	cQuery += "		   SUM(CASE WHEN GW1.GW1_SIT = '2' THEN GW8.GW8_VALOR ELSE 0 END) VAL_SIT2, "
	cQuery += "	       SUM(CASE WHEN GW1.GW1_SIT = '3' THEN GW8.GW8_VALOR ELSE 0 END) VAL_SIT3, "
	cQuery += "	       SUM(CASE WHEN GW1.GW1_SIT = '4' THEN GW8.GW8_VALOR ELSE 0 END) VAL_SIT4, "
	cQuery += "	       SUM(CASE WHEN GW1.GW1_SIT = '5' THEN GW8.GW8_VALOR ELSE 0 END) VAL_SIT5, "
	cQuery += "	       SUM(CASE WHEN GW1.GW1_SIT = '6' THEN GW8.GW8_VALOR ELSE 0 END) VAL_SIT6, "
	cQuery += "	       SUM(CASE WHEN GW1.GW1_SIT = '7' THEN GW8.GW8_VALOR ELSE 0 END) VAL_SIT7, "
	cQuery += "	       SUM(CASE WHEN GW1.GW1_SIT = '8' THEN GW8.GW8_VALOR ELSE 0 END) VAL_SIT8, "
	cQuery += "	       SUM(CASE WHEN GW1.GW1_SIT = '1' THEN GW8.GW8_PESOR ELSE 0 END) PES_SIT1, "
	cQuery += "		   SUM(CASE WHEN GW1.GW1_SIT = '2' THEN GW8.GW8_PESOR ELSE 0 END) PES_SIT2, "
	cQuery += "	       SUM(CASE WHEN GW1.GW1_SIT = '3' THEN GW8.GW8_PESOR ELSE 0 END) PES_SIT3, "
	cQuery += "	       SUM(CASE WHEN GW1.GW1_SIT = '4' THEN GW8.GW8_PESOR ELSE 0 END) PES_SIT4, "
	cQuery += "	       SUM(CASE WHEN GW1.GW1_SIT = '5' THEN GW8.GW8_PESOR ELSE 0 END) PES_SIT5, "
	cQuery += "	       SUM(CASE WHEN GW1.GW1_SIT = '6' THEN GW8.GW8_PESOR ELSE 0 END) PES_SIT6, "
	cQuery += "	       SUM(CASE WHEN GW1.GW1_SIT = '7' THEN GW8.GW8_PESOR ELSE 0 END) PES_SIT7, "
	cQuery += "	       SUM(CASE WHEN GW1.GW1_SIT = '8' THEN GW8.GW8_PESOR ELSE 0 END) PES_SIT8,"
	cQuery += "	       SUM(GW8.GW8_PESOR) GFE_PEBRTO,"
	cQuery += "		   SUM(GW8.GW8_PESOC) GFE_PECUTO,"
	cQuery += "		   SUM(GW8.GW8_QTDALT) GFE_QTDALT,"
	cQuery += "		   SUM(GW8.GW8_VOLUME) GFE_VOLTOT,"
	cQuery += "		   SUM(GW8.GW8_QTDE) GFE_QTVOTO,"
	cQuery += "		   SUM(GW8.GW8_VALOR) GFE_VLCATO,"
	cQuery += "		   SUM(GWU_QTD) GWU_QTD,"
	cQuery += "    	   COUNT(CASE WHEN GW1_TPFRET = '1' THEN 1 END) QTD_CIF,"
	cQuery += "		   COUNT(CASE WHEN GW1_TPFRET = '3' THEN 1 END) QTD_FOB,"
	cQuery += "		   COUNT(CASE WHEN GW1_TPFRET IN ('2','4') THEN 1 END) QTD_RED,"
	cQuery += "		   COUNT(CASE WHEN GWU_DTENT != '' THEN 1 END) ENT_REG, "
	cQuery += "		   COUNT(CASE WHEN GWU_DTENT = '' OR GWU_DTENT IS NULL THEN 1 END) ENT_NREG, "
	cQuery += "		   COUNT(CASE WHEN GW1_DTPENT = '' THEN 1 END) SEM_PRV, "
	cQuery += "		   COUNT(CASE WHEN GW1_DTPENT  = ''  AND GWU_DTENT != '' AND GWU_DTENT IS NOT NULL THEN 1 END) SEM_PRZ,"
	cQuery += "		   COUNT(CASE WHEN GW1_DTPENT != '' AND GWU_DTENT != '' AND GW1_DTPENT = GWU_DTENT THEN 1 END) PRZ, "
	cQuery += "		   COUNT(CASE WHEN GW1_DTPENT != '' AND GWU_DTENT != '' AND GW1_DTPENT < GWU_DTENT THEN 1 END) ATR, "
	cQuery += "		   COUNT(CASE WHEN GW1_DTPENT != '' AND GWU_DTENT != '' AND GW1_DTPENT > GWU_DTENT THEN 1 END) ADI,"
	cQuery += "		   COUNT(CASE WHEN (GWU_DTENT = '' OR GWU_DTENT IS NULL) AND GW1_SIT != '8' THEN 1 END) NAO_INF,"
	cQuery += "		   COUNT(CASE WHEN (GWU_DTENT = '' OR GWU_DTENT IS NULL) AND GW1_SIT = '8' THEN 1 END) ENT_SIN"
	cQuery += "	  FROM " + RetSQLName("GW1") + " GW1"
	cQuery += "	  LEFT JOIN ( SELECT GW8_FILIAL, GW8_CDTPDC, GW8_EMISDC, GW8_SERDC, GW8_NRDC, "
	cQuery += "	                     SUM(GW8_PESOR) GW8_PESOR,SUM(GW8_PESOC) GW8_PESOC,SUM(GW8_QTDALT) GW8_QTDALT,"
	cQuery += "	                     SUM(GW8_VOLUME) GW8_VOLUME,SUM(GW8_QTDE) GW8_QTDE,SUM(GW8_VALOR) GW8_VALOR"
	cQuery += "	                FROM " + RetSQLName("GW8")
	cQuery += "	               WHERE D_E_L_E_T_ = ' '"
	cQuery += "	               GROUP BY GW8_FILIAL, GW8_CDTPDC, GW8_EMISDC, GW8_SERDC, GW8_NRDC"
	cQuery += "	             ) GW8 ON GW8.GW8_FILIAL = GW1.GW1_FILIAL"
	cQuery += "	                  AND GW8.GW8_CDTPDC = GW1.GW1_CDTPDC "
	cQuery += "	                  AND GW8.GW8_EMISDC = GW1.GW1_EMISDC "
	cQuery += "	                  AND GW8.GW8_SERDC  = GW1.GW1_SERDC "
	cQuery += "	                  AND GW8.GW8_NRDC   = GW1.GW1_NRDC "
	cQuery += "	  LEFT JOIN ( "
	cQuery += "		   	SELECT GWU1.GWU_FILIAL, GWU1.GWU_CDTPDC, GWU1.GWU_EMISDC, GWU1.GWU_SERDC, GWU1.GWU_NRDC, GWU1.GWU_DTENT,GWU_QTD"
	cQuery += "			  FROM " + RetSQLName("GWU") + " GWU1"
	cQuery += "			 INNER JOIN ("
	cQuery += "			 	SELECT GWU_FILIAL, GWU_CDTPDC, GWU_EMISDC, GWU_SERDC, GWU_NRDC, COUNT(*) GWU_QTD, MAX(GWU_SEQ) GWU_SEQ"
	cQuery += "			 	  FROM " + RetSQLName("GWU")
	cQuery += "			 	 WHERE D_E_L_E_T_ = ' ' "
	cQuery += "			 	   AND GWU_PAGAR = '1' "
	cQuery += "			     GROUP BY GWU_FILIAL, GWU_CDTPDC, GWU_EMISDC, GWU_SERDC, GWU_NRDC"
	cQuery += "			 ) GWU2 ON GWU1.GWU_FILIAL = GWU2.GWU_FILIAL "
	cQuery += "				   AND GWU1.GWU_CDTPDC = GWU2.GWU_CDTPDC"
	cQuery += "				   AND GWU1.GWU_EMISDC = GWU2.GWU_EMISDC"
	cQuery += "				   AND GWU1.GWU_SERDC  = GWU2.GWU_SERDC"
	cQuery += "				   AND GWU1.GWU_NRDC   = GWU2.GWU_NRDC"
	cQuery += "				   AND GWU1.GWU_SEQ    = GWU2.GWU_SEQ"
	cQuery += "			WHERE GWU1.D_E_L_E_T_ = ' '"
	cQuery += "			  AND GWU1.GWU_PAGAR = '1'"
	cQuery += "		 ) GWU ON GWU.GWU_FILIAL = GW1.GW1_FILIAL "
	cQuery += "		      AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC "
	cQuery += "		      AND GWU.GWU_EMISDC = GW1.GW1_EMISDC "
	cQuery += "		      AND GWU.GWU_SERDC  = GW1.GW1_SERDC "
	cQuery += "		      AND GWU.GWU_NRDC   = GW1.GW1_NRDC "
	cQuery += "	 WHERE GW1.D_E_L_E_T_ = ' ' AND (GW1.GW1_CDREM = '"+cCdCliente+"' OR GW1.GW1_CDDEST = '"+cCdCliente+"') " + CriaQueryCondicao(aFiltros,"") + cBrwFiltro
	
	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)	
	(cTmp)->(dbGoTop())
	If (cTmp)->(RecNo()) > 0
		aADD(aGrfSit, {"Digitado"  ,(cTmp)->GW1_SITDIG})
		aADD(aGrfSit, {"Bloqueado" ,(cTmp)->GW1_SITBLO})
		aADD(aGrfSit, {"Liberado"  ,(cTmp)->GW1_SITLIB})
		aADD(aGrfSit, {"Embarcado" ,(cTmp)->GW1_SITEMB})
		aADD(aGrfSit, {"Entregue"  ,(cTmp)->GW1_SITENT})
		aADD(aGrfSit, {"Retornado" ,(cTmp)->GW1_SITRET})
		aADD(aGrfSit, {"Cancelado" ,(cTmp)->GW1_SITCAN})
		aADD(aGrfSit, {"Sinistrado",(cTmp)->GW1_SITSIN})
		
		aADD(aGrfVal, {"Digitado"  ,(cTmp)->VAL_SIT1})
		aADD(aGrfVal, {"Bloqueado" ,(cTmp)->VAL_SIT2})
		aADD(aGrfVal, {"Liberado"  ,(cTmp)->VAL_SIT3})
		aADD(aGrfVal, {"Embarcado" ,(cTmp)->VAL_SIT4})
		aADD(aGrfVal, {"Entregue"  ,(cTmp)->VAL_SIT5})
		aADD(aGrfVal, {"Retornado" ,(cTmp)->VAL_SIT6})
		aADD(aGrfVal, {"Cancelado" ,(cTmp)->VAL_SIT7})
		aADD(aGrfVal, {"Sinistrado",(cTmp)->VAL_SIT8})
		
		aADD(aGrfPes, {"Digitado"  ,(cTmp)->PES_SIT1})
		aADD(aGrfPes, {"Bloqueado" ,(cTmp)->PES_SIT2})
		aADD(aGrfPes, {"Liberado"  ,(cTmp)->PES_SIT3})
		aADD(aGrfPes, {"Embarcado" ,(cTmp)->PES_SIT4})
		aADD(aGrfPes, {"Entregue"  ,(cTmp)->PES_SIT5})
		aADD(aGrfPes, {"Retornado" ,(cTmp)->PES_SIT6})
		aADD(aGrfPes, {"Cancelado" ,(cTmp)->PES_SIT7})
		aADD(aGrfPes, {"Sinistrado",(cTmp)->PES_SIT8})
		
		aADD(aGrfReg, {"Registradas", (cTmp)->ENT_REG})
		aADD(aGrfReg, {"Não registradas", (cTmp)->ENT_NREG})
		
		aADD(aGrfCum, {"Adiantado", (cTmp)->ADI})
		aADD(aGrfCum, {"Atrasado", (cTmp)->ATR})
		aADD(aGrfCum, {"No prazo", (cTmp)->PRZ})
		aADD(aGrfCum, {"Sem prazo", (cTmp)->SEM_PRZ})
		
		aADD(aGrfSReg, {"Não informadas",(cTmp)->NAO_INF})
		aADD(aGrfSReg, {"Sinistradas",    (cTmp)->ENT_SIN})
		
		aADD(aBrowse, {"Cliente"                         		,"-" , POSICIONE("GU3",1,xFilial("GU3")+cCdCliente,"GU3_NMEMIT")})
		aADD(aBrowse, {"Peso Bruto Total"    					,"Kg", AllTrim(Transform((cTmp)->GFE_PEBRTO,'@E 99,999,999,999.99999'))}) 
		aADD(aBrowse, {"Peso Cubado Total"   					,"Kg", AllTrim(Transform((cTmp)->GFE_PECUTO ,'@E 99,999,999,999.99999'))}) 
		aADD(aBrowse, {"Peso/Qtde Alternativa Cargas"			,"Un", AllTrim(Transform((cTmp)->GFE_QTDALT,'@E 99,999,999,999.99999'))})   
		aADD(aBrowse, {"Volume Total"        					,"M3", AllTrim(Transform((cTmp)->GFE_VOLTOT ,'@E 99,999,999,999.99999'))}) 
		aADD(aBrowse, {"Qtde Volumes Total"  					,"Un", AllTrim(Transform((cTmp)->GFE_QTVOTO ,'@E 99,999,999,999'))}) 
		aADD(aBrowse, {"Valor Carga Total"   					,"$" , AllTrim(Transform((cTmp)->GFE_VLCATO ,'@E 99,999,999,999.99'))})   
		aADD(aBrowse, {"Qtde de Documentos"         			,"Un", Alltrim(STR((cTmp)->GW1_TOTAL)) })
		aADD(aBrowse, {"Qtde de Doctos CIF"         			,"Un", Alltrim(STR((cTmp)->QTD_CIF)) })
		aADD(aBrowse, {"Qtde de Doctos FOB"         			,"Un", Alltrim(STR((cTmp)->QTD_FOB)) })
		aADD(aBrowse, {"Qtde de Doctos com Redesp"         	,"Un", Alltrim(STR((cTmp)->QTD_RED)) })
		aADD(aBrowse, {"Qtde de Trechos"         			    ,"Un", Alltrim(STR((cTmp)->GWU_QTD)) })
		aADD(aBrowse, {"Qtde de Entregas Registradas"        	,"Un", Alltrim(STR((cTmp)->ENT_REG)) })
		aADD(aBrowse, {"Qtde de Entregas Não registradas"    	,"Un", Alltrim(STR((cTmp)->ENT_NREG)) })
		aADD(aBrowse, {"Qtde de Entregas Sem Prazo"   		,"Un", Alltrim(STR((cTmp)->SEM_PRZ)) })
		aADD(aBrowse, {"Qtde de Entregas No Prazo"         	,"Un", Alltrim(STR((cTmp)->PRZ)) })
		aADD(aBrowse, {"Qtde de Entregas Adiantados"       	,"Un", Alltrim(STR((cTmp)->ADI)) })
		aADD(aBrowse, {"Qtde de Entregas Atrasados"         	,"Un", Alltrim(STR((cTmp)->ATR)) })
		
		nTmpPeso := (cTmp)->GFE_PEBRTO
		nTmpValC := (cTmp)->GFE_VLCATO
		nTmpVolC := (cTmp)->GFE_VOLTOT
	EndIf
	
	(cTmp)->(dbCloseArea())
	
	//
	// Aba Transportador 
	//
	cQuery := ""
	cQuery += "	SELECT GU3_CDEMIT, GU3_NMEMIT, TRP.QTD_DOC, TRP.GW1_DTEMIS, TRP.GW8_PESOR, TRP.GW8_VALOR, TRP.GW8_VOLUME, TRP.GWM_VLFRET, QTD_OCO, QTD_PROVOC"
	cQuery += "	  FROM " + RetSQLName("GU3") + " GU3"
	cQuery += "	 INNER JOIN ("
	cQuery += "	 	SELECT GWU_CDTRP, QTD_OCO, QTD_PROVOC, SUM(GW8_PESOR) GW8_PESOR, SUM(GW8_VOLUME) GW8_VOLUME, "
	cQuery += "	 	       SUM(GW8_VALOR) GW8_VALOR, MAX(GW1_DTEMIS) GW1_DTEMIS, COUNT(*) QTD_DOC,"
	cQuery += "	 	       SUM(GWM.GWM_VLFRET) GWM_VLFRET"
	cQuery += "	 	  FROM " + RetSQLName("GW1") + " GW1"
	cQuery += "	 	 INNER JOIN ("
	cQuery += "	 	 	SELECT DISTINCT GWU_FILIAL, GWU_CDTPDC, GWU_EMISDC, GWU_SERDC, GWU_NRDC, GWU_CDTRP"
	cQuery += "	 	 	  FROM " + RetSQLName("GWU")
	cQuery += "	 	 	 WHERE D_E_L_E_T_ = ' '"
	cQuery += "	 	 	   AND GWU_PAGAR = '1'"
	cQuery += "	 	 ) GWU ON GWU.GWU_FILIAL = GW1.GW1_FILIAL"
	cQuery += "	 	      AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC"
	cQuery += "	 	      AND GWU.GWU_EMISDC = GW1.GW1_EMISDC"
	cQuery += "	 	      AND GWU.GWU_SERDC  = GW1.GW1_SERDC"
	cQuery += "	 	      AND GWU.GWU_NRDC   = GW1.GW1_NRDC"
	cQuery += "	 	  LEFT JOIN ( SELECT GW8_FILIAL, GW8_CDTPDC, GW8_EMISDC, GW8_SERDC, GW8_NRDC, "
	cQuery += "	                     SUM(GW8_PESOR) GW8_PESOR,SUM(GW8_VOLUME) GW8_VOLUME,SUM(GW8_VALOR) GW8_VALOR"
	cQuery += "	                FROM " + RetSQLName("GW8")
	cQuery += "	               WHERE D_E_L_E_T_ = ' '"
	cQuery += "	               GROUP BY GW8_FILIAL, GW8_CDTPDC, GW8_EMISDC, GW8_SERDC, GW8_NRDC"
	cQuery += "	             ) GW8 ON GW8.GW8_FILIAL = GW1.GW1_FILIAL"
	cQuery += "	                  AND GW8.GW8_CDTPDC = GW1.GW1_CDTPDC "
	cQuery += "	                  AND GW8.GW8_EMISDC = GW1.GW1_EMISDC "
	cQuery += "	                  AND GW8.GW8_SERDC  = GW1.GW1_SERDC "
	cQuery += "	                  AND GW8.GW8_NRDC   = GW1.GW1_NRDC"
	cQuery += "	      LEFT JOIN ("
	cQuery += "	      	SELECT GWM.GWM_FILIAL, GWM.GWM_CDTPDC, GWM.GWM_EMISDC, GWM.GWM_SERDC, "
	cQuery += "	      	       GWM.GWM_NRDC, GWM.GWM_CDTRP, SUM(GWM_VLFRET) GWM_VLFRET"
	cQuery += "			  FROM " + RetSQLName("GWM") + " GWM"
	cQuery += "			 WHERE GWM.D_E_L_E_T_ = ' '"
	cQuery += "			   AND GWM.GWM_TPDOC = '1'"
	cQuery += "			 GROUP BY GWM.GWM_FILIAL, GWM.GWM_CDTPDC, GWM.GWM_EMISDC, GWM.GWM_SERDC, "
	cQuery += "			          GWM.GWM_NRDC, GWM.GWM_CDTRP"
	cQuery += "	      ) GWM ON GWM.GWM_FILIAL = GW1.GW1_FILIAL"
	cQuery += "               AND GWM.GWM_CDTPDC = GW1.GW1_CDTPDC "
	cQuery += "               AND GWM.GWM_EMISDC = GW1.GW1_EMISDC "
	cQuery += "               AND GWM.GWM_SERDC  = GW1.GW1_SERDC "
	cQuery += "               AND GWM.GWM_NRDC   = GW1.GW1_NRDC"
	cQuery += "               AND GWM.GWM_CDTRP  = GWU.GWU_CDTRP"
	cQuery += "          LEFT JOIN ("
	cQuery += "			SELECT GWD_CDTRP, COUNT(GWL_NROCO) QTD_OCO, COUNT(CASE WHEN GU6_PROVOC = '1' THEN 1 END) QTD_PROVOC"
	cQuery += "			  FROM ("
	cQuery += "				SELECT DISTINCT GWL_NROCO, GWD.GWD_CDTRP, GU6_PROVOC"
	cQuery += "				  FROM " + RetSQLName("GWL") + " GWL"
	cQuery += "				 INNER JOIN " + RetSQLName("GW1") + " GW1 ON GW1.GW1_FILIAL = GWL.GWL_FILDC"
	cQuery += "				                      AND GW1.GW1_CDTPDC = GWL.GWL_TPDC"
	cQuery += "				                      AND GW1.GW1_EMISDC = GWL.GWL_EMITDC"
	cQuery += "				                      AND GW1.GW1_SERDC  = GWL.GWL_SERDC"
	cQuery += "				                      AND GW1.GW1_NRDC   = GWL.GWL_NRDC"
	cQuery += "				 INNER JOIN " + RetSQLName("GWD") + " GWD ON GWD.GWD_NROCO = GWL.GWL_NROCO"
	cQuery += "				 INNER JOIN " + RetSQLName("GU6") + " GU6 ON GU6.GU6_CDMOT = GWD.GWD_CDMOT"
	cQuery += "				 WHERE GWL.D_E_L_E_T_ = ' '"
	cQuery += "				   AND (GW1.GW1_CDREM = '"+cCdCliente+"' OR GW1.GW1_CDDEST = '"+cCdCliente+"') " + CriaQueryCondicao(aFiltros,"") + cBrwFiltro
	cQuery += "			) AUX"
	cQuery += "			GROUP BY GWD_CDTRP"
	cQuery += "          ) GWD ON GWD.GWD_CDTRP = GWU.GWU_CDTRP"
	cQuery += "	 	 WHERE GW1.D_E_L_E_T_ = ' ' AND (GW1.GW1_CDREM = '"+cCdCliente+"' OR GW1.GW1_CDDEST = '"+cCdCliente+"') " + CriaQueryCondicao(aFiltros,"") + cBrwFiltro
	cQuery += "	 	 GROUP BY GWU_CDTRP, QTD_OCO, QTD_PROVOC"
	cQuery += "	  ) TRP ON GWU_CDTRP = GU3.GU3_CDEMIT"
	cQuery += "	 WHERE GU3.D_E_L_E_T_ = ' '"
	cQuery += "	   AND (GU3.GU3_TRANSP = '1' OR GU3.GU3_AUTON = '1')"
	
	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	If (cTmp)->(RecNo()) > 0
		While (cTmp)->(!Eof())
			aADD(aBrowseTrp, { (cTmp)->GU3_CDEMIT, ;
				                  (cTmp)->GU3_NMEMIT,;
				                  (cTmp)->QTD_DOC, ;
				                  StoD((cTmp)->GW1_DTEMIS), ;
				                  (cTmp)->GW8_PESOR, ;
				                  (cTmp)->GW8_VALOR, ;
				                  (cTmp)->GW8_VOLUME, ;
				                  (cTmp)->GWM_VLFRET, ;
				                  (cTmp)->GWM_VLFRET / (cTmp)->GW8_PESOR,;//$ Frete por kg, 
								  (cTmp)->GWM_VLFRET / (cTmp)->GW8_VOLUME,;//$ Frete por m3, 
								  (cTmp)->GW8_VALOR / (cTmp)->GWM_VLFRET * 100,;//% Frete Valor Carga,
				                  (cTmp)->QTD_OCO, ;
				                  (cTmp)->QTD_PROVOC;
				                })
				                
			nTotCalc += (cTmp)->GWM_VLFRET;
			
			(cTmp)->(dbSkip())
		EndDo
	EndIf
	
	(cTmp)->(dbCloseArea())
	
	
	//Frete Calculado, $ Frete por kg, $ Frete por m3, % Frete Valor Carga
	aADD(aBrowse, {"Frete Calculado", "$", AllTrim(Transform(nTotCalc,'@E 99,999,999,999.99'))})
	aADD(aBrowse, {"$ Frete por kg" , "$", Alltrim(Transform(nTotCalc / nTmpPeso,'@E 99,999,999,999.99')) })
	aADD(aBrowse, {"$ Frete por m3" , "$", Alltrim(Transform(nTotCalc / nTmpVolC,'@E 99,999,999,999.99')) })
	aADD(aBrowse, {"% Frete Valor Carga","$", Alltrim(Transform(nTmpValC / nTotCalc * 100,'@E 9,999.99')) })
Return Nil		   

//=========================================================================/
Function GFEC003AV(aParam) 
	Local nCont 
	Local cFiltro := ""
	Local cTmp := ""
	
	For nCont := 1 To Len(aParam)
		If !aParam[nCont][5]
			cTmp := aParam[nCont][3]
			
			If aParam[nCont][2] == cFilRem
				cTmp := "GW1_CDREM = '"+cCdCliente+"'"
			ElseIf aParam[nCont][2] == cFilDest
				cTmp := "GW1_CDDEST = '"+cCdCliente+"'"
			EndIf
			
	       	If !Empty(cFiltro)
	       		cFiltro := cFiltro + " AND (" + cTmp + ")"
	       	Else
	       	    cFiltro := " AND (" + cTmp + ")"
	       	Endif
		EndIf
	Next nCont
	
	Processa({||Atualiza(cFiltro)})
Return .T.

Static Function Atualiza(cFiltro)
	CarregaDados(aFiltros,cFiltro)
	
	//Atualiza Gráficos
	GFEC001GRA(oGrfSit,.T.,aGrfSit)
	GFEC001GRA(oGrfVal,.T.,aGrfVal)
	GFEC001GRA(oGrfPes,.T.,aGrfPes)
	GFEC001GRA(oGrfCum,.T.,aGrfCum)
	GFEC001GRA(oGrfReg,.T.,aGrfReg)
	GFEC001GRA(oGrfSReg,.T.,aGrfSReg)
	
	//Atualiza o Grid  
	oBrowseEst:SetArray(aBrowse)
	oBrowseEst:UpdateBrowse()
Return Nil 

//=========================================================================/
