#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEC002D
Painel Gerencial de Filiais - Informações sobre Entregas

Uso Restrito. 

Param:
aParam[1] := Data de
aParam[2] := Data ate
aParam[3] := Filial     

@sample
GFEC002D(aParam)

@author Alan Victor Lamb
@since 01/07/13
@version 1.0
--------------------------------------------------------------------------------------------------/*/  
Function GFEC002D(aParam)
	Local aCoors := FWGetDialogSize(oMainWnd)
	Local cTitulo := 'Painel Gerencial - Filial'
	
	Private oBrowseEnt, oBrowseEst
	Private aDados, aFiltros, aBrowse
	Private aGrfReg, aGrfCum, aGrfSReg
	Private oGrfReg, oGrfCum, oGrfSReg
	Private oFolder, oDLG
	Private cFil  := aParam[3]
	Private dDataDe  := If(Empty(aParam[1]),DDATABASE -30 ,aParam[1])
	Private dDataAte := If(Empty(aParam[2]),DDATABASE     ,aParam[2])                   
	Private cAliasGWU
	
	aFiltros := {{"","GW1_FILIAL","=",cFil},;
				   {"","GW1_DTEMIS",">=",Dtos(dDataDe)},;
				   {"","GW1_DTEMIS","<=",Dtos(dDataAte)}}  
	
	Define MsDialog oDLG Title cTitulo From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
	
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDLG,.F.)
	oFWLayer:AddLine('LINE_TOP',50,.F.)
	oFWLayer:AddLine('LINE_MIDDLE',50,.F.)
	oFWLayer:AddCollumn('COL_TOP',100,.T.,'LINE_TOP')
	oFWLayer:AddCollumn('COL_LEFT',40,.T.,'LINE_MIDDLE')
	oFWLayer:AddCollumn('COL_RIGHT',60,.T.,'LINE_MIDDLE')
    oFWLayer:AddWindow('COL_LEFT','WIN_LEFT','Estatísticas',100,.F.,.F.,,'LINE_MIDDLE',)
  	oFWLayer:AddWindow('COL_RIGHT','WIN_RIGHT','Gráfico',100,.F.,.F.,,'LINE_MIDDLE',)
    
    oWIN_TOP   := oFWLayer:GetColPanel('COL_TOP','LINE_TOP')
    oWIN_LEFT  := oFWLayer:GetWinPanel('COL_LEFT','WIN_LEFT','LINE_MIDDLE')
	oWIN_RIGHT := oFWLayer:GetWinPanel('COL_RIGHT','WIN_RIGHT','LINE_MIDDLE')
	
	oDLG:Activate(,,,.T.,,,{||Processa({||Iniciar()})})
	
	GFEDelTab(cAliasGWU)
Return 

Static Function Iniciar()
	Local cBrowseFiltro  
	Local oPnl
	Local nCount
	Local aFieldsGWU
	
	aFieldsGWU := ;
	{{"Filial"	     ,"GWU_FILIAL","C",TamSX3("GWU_FILIAL")[1],0,"",1,TamSX3("GWU_FILIAL")[1]},;
	{"Tp Doc"	   	 ,"GWU_CDTPDC","C",TamSX3("GWU_CDTPDC")[1],0,"",1,TamSX3("GWU_CDTPDC")[1]},;
	{"Emissor"      ,"GWU_EMISDC","C",TamSX3("GWU_EMISDC")[1],0,"",1,TamSX3("GWU_EMISDC")[1]},;
	{"Sequencia"    ,"GWU_SEQ"   ,"C",TamSX3("GWU_SEQ")[1] ,0,"",1,2},;
	{"Série",			"GWU_SERDC",	"C",TamSX3("GWU_SERDC")[1],	0,"!!!",1,10},;
	{"Número"       ,"GWU_NRDC"  ,"C",TamSX3("GWU_NRDC")[1]  ,0,"",1,10},;
	{"Transp"       ,"GWU_CDTRP" ,"C",TamSX3("GWU_CDTRP")[1]  ,0,"",1,10},;
	{"Nome Transp" ,"GU3_NMEMIT","C",TamSX3("GU3_NMEMIT")[1]  ,0,"",1,10},;
	{"Tipo Veiculo","GWU_CDTPVC","C",TamSX3("GWU_CDTPVC")[1]  ,0,"",1,10},;
	{"Pagar"  		 ,"GWU_PAGAR" ,"C",3,0,"",1,3},;
	{"Dt Prev Entr","GWU_DTPENT","D",8,0,"",1,10},;
	{"Hr Prev Entr","GWU_HRPENT","C",TamSX3("GWU_HRPENT")[1],0,"",1,TamSX3("GWU_HRPENT")[1]},;
	{"Dt Entrega"  ,"GWU_DTENT" ,"D",8,0,"",1,10},;
	{"Hora Entrega","GWU_HRENT" ,"C",TamSX3("GWU_HRENT")[1],0,"",1,TamSX3("GWU_HRENT")[1]}}
	
	cAliasGWU := CriaTab()
	
	CarregaDados(aFiltros)
	
	// Entregas
	oBrowseEnt:= FWMBrowse():New() 
	oBrowseEnt:SetOwner(oWIN_TOP)  
	oBrowseEnt:SetDescription("Trechos")
	oBrowseEnt:SetAlias(cAliasGWU)
	oBrowseEnt:SetLocate()
	oBrowseEnt:DisableDetails()
	oBrowseEnt:DisableConfig()
	oBrowseEnt:SetAmbiente(.F.)
	oBrowseEnt:SetWalkthru(.F.)
	oBrowseEnt:SetProfileID("1") 
	oBrowseEnt:SetMenuDef("")
	oBrowseEnt:AddButton("Sair",{|| oDLG:End()},,1)
	oBrowseEnt:AddButton("Visualizar",{|| VisualGWU() },,2)
	
	For nCount := 1 To Len(aFieldsGWU)
		oBrowseEnt:AddColumn({aFieldsGWU[nCount][1],;
							     &("{|| (cAliasGWU)->" + aFieldsGWU[nCount][2] + "}"),;
							     aFieldsGWU[nCount][3],;
							     aFieldsGWU[nCount][6],;
							     aFieldsGWU[nCount][7],;
							     aFieldsGWU[nCount][8],;
							     aFieldsGWU[nCount][5],;
							     .F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}})						     
	Next nCount
	
	oBrowseEnt:Activate()
	
	// Estatísticas
	oBrowseEst := FWBrowse():New()
	oBrowseEst:SetOwner(oWIN_LEFT)
	oBrowseEst:SetDescription("Dados") 
	oBrowseEst:SetDataArray()
	oBrowseEst:DisableFilter()
	oBrowseEst:DisableConfig()
	oBrowseEst:SetArray(aBrowse)
	oBrowseEst:SetColumns(GFEC001COL("Situação Entrega",1,,1,14,"oBrowseEst"))
	oBrowseEst:SetColumns(GFEC001COL("Qtde Entregas",2,,2,8,"oBrowseEst"))
	oBrowseEst:SetColumns(GFEC001COL("Valor Carga",3,"@E 999,999,999.99",2,14,"oBrowseEst"))
	oBrowseEst:SetColumns(GFEC001COL("Peso Bruto",4,"@E 999,999,999.999",2,15,"oBrowseEst"))
	oBrowseEst:SetColumns(GFEC001COL("Qtde Volumes",5,,2,12,"oBrowseEst"))
	oBrowseEst:Activate()
	
	oFolder :=  tFolder():New(30,0,{"Registro das Entregas","Prazo Transportador","Sem registro de Entrega"},{"G1","G2","G3"},oWIN_RIGHT,)
	oFolder:Align := CONTROL_ALIGN_ALLCLIENT
	
	oPnl := tPanel():New(30,0,,oFolder:aDialogs[1],,,,,,)
	oPnl:Align := CONTROL_ALIGN_ALLCLIENT
	
	// Registro das Entregas
   	GFEC001GRC("oGrfReg","Registro das Entregas",oPnl,aGrfReg)
    
    oPnl := tPanel():New(30,0,,oFolder:aDialogs[2],,,,,,)
	oPnl:Align := CONTROL_ALIGN_ALLCLIENT
	
	// Cumprimento de Prazo
   	GFEC001GRC("oGrfCum","Prazo Transportador",oPnl,aGrfCum)
	
	oPnl := tPanel():New(30,0,,oFolder:aDialogs[3],,,,,,)
	oPnl:Align := CONTROL_ALIGN_ALLCLIENT
	
	// Sem registro de Entrega
   	GFEC001GRC("oGrfSReg","Sem registro de Entrega",oPnl,aGrfSReg)
Return Nil


Static Function VisualGWU()
	dbSelectArea("GWU")
	GWU->(dbSetOrder(1))
	If GWU->(dbSeek((cAliasGWU)->(GWU_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SERDC+GWU_NRDC+GWU_SEQ)))
		FWExecView("Visualizar", "GFEA051", 1,, {||.T.})
	EndIf 
Return Nil

Static Function CarregaDados(aFiltros,cBrwFiltro)
	Local cQuery := ""
	Local cTmp   := ""
	Default cBrwFiltro := ""
	
	// Array do browse estatísticas
	aBrowse := {}
	
	cQuery += "	SELECT COUNT(CASE WHEN GWU_DTENT = '' THEN 1 END) QTD_NREG,"
	cQuery += "		   COUNT(CASE WHEN GWU_DTENT != '' THEN 1 END) QTD_REG,"
	cQuery += "		   COUNT(CASE WHEN GWU_DTPENT != '' AND GWU_DTENT != '' AND GWU_DTENT > GWU_DTPENT THEN 1 END) QTD_ATR,"
	cQuery += "		   COUNT(CASE WHEN GWU_DTPENT != '' AND GWU_DTENT != '' AND GWU_DTENT = GWU_DTPENT THEN 1 END) QTD_PRA,"
	cQuery += "		   COUNT(CASE WHEN GWU_DTPENT != '' AND GWU_DTENT != '' AND GWU_DTENT < GWU_DTPENT THEN 1 END) QTD_ADI,"
	cQuery += "		   COUNT(CASE WHEN GWU_DTPENT = '' AND GWU_DTENT != '' THEN 1 END) QTD_SEMPRA,"
	cQuery += "		   COUNT(CASE WHEN GWU_DTENT = '' AND GW1.GW1_SIT != '8' THEN 1 END) QTD_NAOINF,"
	cQuery += "		   COUNT(CASE WHEN GWU_DTENT = '' AND GW1.GW1_SIT = '8' THEN 1 END) QTD_SIN,"
	cQuery += "		   SUM(CASE WHEN GWU_DTENT = '' THEN GW8_VALOR END) NREG_VAL,"
	cQuery += "		   SUM(CASE WHEN GWU_DTENT = '' THEN GW8_PESOR END) NREG_PES,"
	cQuery += "		   SUM(CASE WHEN GWU_DTENT = '' THEN GW8_QTDE END) NREG_QTD,"
	cQuery += "		   SUM(CASE WHEN GWU_DTENT != '' THEN GW8_VALOR END) REG_VAL,"
	cQuery += "		   SUM(CASE WHEN GWU_DTENT != '' THEN GW8_PESOR END) REG_PES,"
	cQuery += "		   SUM(CASE WHEN GWU_DTENT != '' THEN GW8_QTDE END) REG_QTD,"
	cQuery += "		   SUM(CASE WHEN GWU_DTPENT != '' AND GWU_DTENT != '' AND GWU_DTENT > GWU_DTPENT THEN GW8_VALOR END) ATR_VAL,"
	cQuery += "		   SUM(CASE WHEN GWU_DTPENT != '' AND GWU_DTENT != '' AND GWU_DTENT > GWU_DTPENT THEN GW8_PESOR END) ATR_PES,"
	cQuery += "		   SUM(CASE WHEN GWU_DTPENT != '' AND GWU_DTENT != '' AND GWU_DTENT > GWU_DTPENT THEN GW8_QTDE END) ATR_QTD,"
	cQuery += "		   SUM(CASE WHEN GWU_DTPENT != '' AND GWU_DTENT != '' AND GWU_DTENT = GWU_DTPENT THEN GW8_VALOR END) PRA_VAL,"
	cQuery += "		   SUM(CASE WHEN GWU_DTPENT != '' AND GWU_DTENT != '' AND GWU_DTENT = GWU_DTPENT THEN GW8_PESOR END) PRA_PES,"
	cQuery += "		   SUM(CASE WHEN GWU_DTPENT != '' AND GWU_DTENT != '' AND GWU_DTENT = GWU_DTPENT THEN GW8_QTDE END) PRA_QTD,"
	cQuery += "		   SUM(CASE WHEN GWU_DTPENT != '' AND GWU_DTENT != '' AND GWU_DTENT < GWU_DTPENT THEN GW8_VALOR END) ADI_VAL,"
	cQuery += "		   SUM(CASE WHEN GWU_DTPENT != '' AND GWU_DTENT != '' AND GWU_DTENT < GWU_DTPENT THEN GW8_PESOR END) ADI_PES,"
	cQuery += "		   SUM(CASE WHEN GWU_DTPENT != '' AND GWU_DTENT != '' AND GWU_DTENT < GWU_DTPENT THEN GW8_QTDE END) ADI_QTD,"
	cQuery += "		   SUM(CASE WHEN GWU_DTENT = '' AND GW1.GW1_SIT = '8' THEN GW8_VALOR END) SIN_VAL,"
	cQuery += "		   SUM(CASE WHEN GWU_DTENT = '' AND GW1.GW1_SIT = '8' THEN GW8_PESOR END) SIN_PES,"
	cQuery += "		   SUM(CASE WHEN GWU_DTENT = '' AND GW1.GW1_SIT = '8' THEN GW8_QTDE END) SIN_QTD,"
	cQuery += "		   SUM(CASE WHEN GWU_DTPENT = '' AND GWU_DTENT != '' THEN GW8_VALOR END) SEMPRA_VAL,"
	cQuery += "		   SUM(CASE WHEN GWU_DTPENT = '' AND GWU_DTENT != '' THEN GW8_PESOR END) SEMPRA_PES,"
	cQuery += "		   SUM(CASE WHEN GWU_DTPENT = '' AND GWU_DTENT != '' THEN GW8_QTDE END) SEMPRA_QTD"
	cQuery += "	  FROM " + RetSQLName("GW1") + " GW1"
	cQuery += "	 INNER JOIN " + RetSQLName("GWU") + " GWU ON GWU.GWU_FILIAL = GW1.GW1_FILIAL"
	cQuery += "	                      AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC"
	cQuery += "	                      AND GWU.GWU_EMISDC = GW1.GW1_EMISDC"
	cQuery += "	                      AND GWU.GWU_SERDC  = GW1.GW1_SERDC"
	cQuery += "	                      AND GWU.GWU_NRDC   = GW1.GW1_NRDC"
	cQuery += "	                      AND GWU.GWU_PAGAR = '1' "
	cQuery += "	                      AND GWU.D_E_L_E_T_ = ' '	 "
	cQuery += "	INNER JOIN ( "
	cQuery += "	 	SELECT GW8_FILIAL, GW8_CDTPDC, GW8_EMISDC, GW8_SERDC, GW8_NRDC, "
	cQuery += "	 	       SUM(GW8_PESOR) GW8_PESOR,"
	cQuery += "	 	       SUM(GW8_VALOR) GW8_VALOR,"
	cQuery += "	 	       SUM(GW8_QTDE) GW8_QTDE"
	cQuery += "	 	  FROM " + RetSQLName("GW8")
	cQuery += "	 	 WHERE D_E_L_E_T_ = ' ' "
	cQuery += "	 	 GROUP BY GW8_FILIAL, GW8_CDTPDC, GW8_EMISDC, GW8_SERDC, GW8_NRDC"
	cQuery += "	 ) GW8 ON GW8.GW8_FILIAL = GW1.GW1_FILIAL"
	cQuery += "	                     AND GW8.GW8_CDTPDC = GW1.GW1_CDTPDC"
	cQuery += "	                     AND GW8.GW8_EMISDC = GW1.GW1_EMISDC"
	cQuery += "	                     AND GW8.GW8_SERDC  = GW1.GW1_SERDC"
	cQuery += "	                     AND GW8.GW8_NRDC   = GW1.GW1_NRDC"
	cQuery += "	 WHERE GW1.D_E_L_E_T_ = ' ' "
	cQuery += "		AND GW1.GW1_SIT != '7' "
	cQuery += "       AND GW1.GW1_DTEMIS >= '" + DtoS(dDataDe) + "'"
	cQuery += "       AND GW1.GW1_DTEMIS <= '" + DtoS(dDataAte) + "'"
	cQuery += "       AND GW1.GW1_FILIAL = '" + cFil + "'"
	
	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	
	aGrfCum  := {}
	aGrfReg  := {}
	aGrfSReg := {}
	
	If (cTmp)->(Recno()) > 0
		/* Gráfico Registro das entregas */
		aADD(aGrfReg, {"Não registradas",(cTmp)->QTD_NREG})
		aADD(aGrfReg, {"Registradas",(cTmp)->QTD_REG})
		
		/* Gráfico Cumprimento dos prazos */
		aADD(aGrfCum, {"Atrasadas",(cTmp)->QTD_ATR})
		aADD(aGrfCum, {"No prazo",(cTmp)->QTD_PRA})
		aADD(aGrfCum, {"Adiantadas",(cTmp)->QTD_ADI})
		aADD(aGrfCum, {"Sem prazo",(cTmp)->QTD_SEMPRA})
		
		/* Gráfico Sem registro de entrega*/
		aADD(aGrfSReg, {"Não informadas",(cTmp)->QTD_NAOINF})
		aADD(aGrfSReg, {"Sinistradas",(cTmp)->QTD_SIN})
		
		/* Browse de Estatísticas */
		//Total = Registradas + Não registradas
		aAdd(aBrowse,{"Todas",(cTmp)->QTD_REG + (cTmp)->QTD_NREG,;
			                     (cTmp)->REG_VAL + (cTmp)->NREG_VAL,;
			                     (cTmp)->REG_PES + (cTmp)->NREG_PES,;
			                     (cTmp)->REG_QTD + (cTmp)->NREG_QTD})
		
		aAdd(aBrowse,{"Registradas",(cTmp)->QTD_REG,(cTmp)->REG_VAL,(cTmp)->REG_PES,(cTmp)->REG_QTD })
		aAdd(aBrowse,{"Não registradas",(cTmp)->QTD_NREG,(cTmp)->NREG_VAL,(cTmp)->NREG_PES,(cTmp)->NREG_QTD })
		aAdd(aBrowse,{"Adiantadas",(cTmp)->QTD_ADI,(cTmp)->ADI_VAL,(cTmp)->ADI_PES,(cTmp)->ADI_QTD })
		aAdd(aBrowse,{"No prazo",(cTmp)->QTD_PRA,(cTmp)->PRA_VAL,(cTmp)->PRA_PES,(cTmp)->PRA_QTD })
		aAdd(aBrowse,{"Atrasadas",(cTmp)->QTD_ATR,(cTmp)->ATR_VAL,(cTmp)->ATR_PES,(cTmp)->ATR_QTD })
		aAdd(aBrowse,{"Sem prazo",(cTmp)->QTD_SEMPRA,(cTmp)->SEMPRA_VAL,(cTmp)->SEMPRA_PES,(cTmp)->SEMPRA_QTD })
		aAdd(aBrowse,{"Fora do prazo",(cTmp)->QTD_ATR + (cTmp)->QTD_ADI,;
			                              (cTmp)->ATR_VAL + (cTmp)->ADI_VAL,;
			                              (cTmp)->ATR_PES + (cTmp)->ADI_PES,;
			                              (cTmp)->ATR_QTD + (cTmp)->ADI_QTD })
		aAdd(aBrowse,{"Sinistradas",(cTmp)->QTD_SIN,(cTmp)->SIN_VAL,(cTmp)->SIN_PES,(cTmp)->SIN_QTD })
		
	EndIf
	
	(cTmp)->(dbCloseArea())
Return Nil

//=========================================================================/ 
// Aplica o filtro do browse na consulta SQL
//=========================================================================/
Function GFEC002DV(aParam) 
	Local nCont 
	Local cFiltro := ""
	
	For nCont := 1 To Len(aParam)
		If !aParam[nCont][5]
	       	If !Empty(cFiltro)
	       		cFiltro := cFiltro + " AND (" +  aParam[nCont][3] + ")"
	       	Else
	       	    cFiltro := " AND (" +  aParam[nCont][3] + ")"
	       	Endif
		EndIf
	Next nCont	
	
	Processa({||Atualiza(cFiltro)})
Return .T.

Static Function Atualiza(cFiltro)
	CarregaDados(aFiltros,cFiltro)
	GFEC001GRA(oGrfCum,.T.,aGrfCum)
	GFEC001GRA(oGrfReg,.T.,aGrfReg)
	GFEC001GRA(oGrfSReg,.T.,aGrfSReg)
	oBrowseEst:SetArray(aBrowse)
	oBrowseEst:UpdateBrowse()
Return Nil      

//
// Cria tabela temporária para o browse com os trechos dos documentos 
// de carga para o emitente selecionadao
//
Static Function CriaTab()
	Local cQuery := ""
	Local cAlias
	Local aFields, aIndices
	Local nCont
	Local cTmp
	Local aStruct := {}
	
	aFields := ;
	{{"Filial"	     ,"GWU_FILIAL","C",TamSX3("GWU_FILIAL")[1],0},;
	{"Tp Doc"	   	 ,"GWU_CDTPDC","C",TamSX3("GWU_CDTPDC")[1],0},;
	{"Emissor"      ,"GWU_EMISDC","C",TamSX3("GWU_EMISDC")[1],0},;
	{"Sequencia"    ,"GWU_SEQ"   ,"C",TamSX3("GWU_SEQ")[1] ,0},;
	{"Série"        ,"GWU_SERDC" ,"C",TamSX3("GWU_SERDC")[1] ,0},;
	{"Número"       ,"GWU_NRDC"  ,"C",TamSX3("GWU_NRDC")[1]  ,0},;
	{"Transp"       ,"GWU_CDTRP" ,"C",TamSX3("GWU_CDTRP")[1]  ,0},;
	{"Nome Transp" ,"GU3_NMEMIT","C",TamSX3("GU3_NMEMIT")[1]  ,0},;
	{"Tipo Veiculo","GWU_CDTPVC"  ,"C",TamSX3("GWU_CDTPVC")[1]  ,0},;
	{"Pagar"  		 ,"GWU_PAGAR" ,"C",3,0},;
	{"Dt Prev Entr","GWU_DTPENT","D",8,0},;
	{"Hr Prev Entr","GWU_HRPENT","C",TamSX3("GWU_HRPENT")[1],0},;
	{"Dt Entrega"  ,"GWU_DTENT" ,"D",8,0},;
	{"Hora Entrega","GWU_HRENT" ,"C",TamSX3("GWU_HRENT")[1],0}}
	
	aIndices := {"GWU_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SERDC+GWU_NRDC+GWU_SEQ"}
	
	For nCont := 1 To Len(aFields)
		aADD(aStruct,{aFields[nCont][2],;  //Nome do campo
						aFields[nCont][3],;  //Tipo
						aFields[nCont][4],;  //Tamanho
						aFields[nCont][5]}) //Decimal
	Next nCont
	
	cAlias := GFECriaTab({aStruct,aIndices})
	
	cQuery += "	SELECT GWU_FILIAL,"
	cQuery += "		   GWU_CDTPDC,"
	cQuery += "		   GWU_EMISDC,"
	cQuery += "		   GWU_SEQ,"
	cQuery += "		   GWU_SERDC,"
	cQuery += "		   GWU_NRDC,"
	cQuery += "		   GWU_CDTRP,"
	cQuery += "		   GWU_CDTPVC,"
	cQuery += "		   GWU_PAGAR,"
	cQuery += "		   GWU_DTPENT,"
	cQuery += "		   GWU_HRPENT,"
	cQuery += "		   GWU_DTENT,"
	cQuery += "		   GWU_HRENT"
	cQuery += "	  FROM " + RetSQLName("GW1") + " GW1 "
	cQuery += "	 INNER JOIN " + RetSQLName("GWU") + " GWU ON GWU.GWU_FILIAL = GW1.GW1_FILIAL "
	cQuery += "	 					  AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC "
	cQuery += "	 					  AND GWU.GWU_EMISDC = GW1.GW1_EMISDC "
	cQuery += "	 					  AND GWU.GWU_SERDC  = GW1.GW1_SERDC "
	cQuery += "	 					  AND GWU.GWU_NRDC   = GW1.GW1_NRDC "
	cQuery += "	 WHERE GW1.D_E_L_E_T_ = '' "
	cQuery += "		AND GW1.GW1_SIT != '7' "
	cQuery += "	   AND GWU.D_E_L_E_T_ = '' "
	cQuery += "	   AND GW1.GW1_FILIAL = '"+cFil+"' "
	cQuery += "	   AND GW1.GW1_DTEMIS >= '"+DtoS(dDataDe)+"' "
	cQuery += "	   AND GW1.GW1_DTEMIS <= '"+DtoS(dDataAte)+"' "
		
	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())

	While (cTmp)->(!Eof())
		RecLock(cAlias,.T.)
		(cAlias)->GWU_FILIAL := (cTmp)->GWU_FILIAL
		(cAlias)->GWU_CDTPDC := (cTmp)->GWU_CDTPDC
		(cAlias)->GWU_EMISDC := (cTmp)->GWU_EMISDC
		(cAlias)->GWU_SEQ  := (cTmp)->GWU_SEQ
		(cAlias)->GWU_SERDC   := (cTmp)->GWU_SERDC
		(cAlias)->GWU_NRDC := (cTmp)->GWU_NRDC
		(cAlias)->GWU_CDTRP := (cTmp)->GWU_CDTRP
		(cAlias)->GU3_NMEMIT  := Posicione("GU3",1,xFilial("GU3")+(cTmp)->GWU_CDTRP,"GU3_NMEMIT")
		(cAlias)->GWU_CDTPVC := (cTmp)->GWU_CDTPVC
		(cAlias)->GWU_PAGAR := If((cTmp)->GWU_PAGAR == "1","Sim","Não")
		(cAlias)->GWU_DTPENT := StoD((cTmp)->GWU_DTPENT)
		(cAlias)->GWU_HRPENT  := (cTmp)->GWU_HRPENT
		(cAlias)->GWU_DTENT := StoD((cTmp)->GWU_DTENT)
		(cAlias)->GWU_HRENT  := (cTmp)->GWU_HRENT		
		MsUnlock(cAlias)
		(cTmp)->(dbSkip())
	EndDo
	
	(cTmp)->(dbCloseArea())
Return cAlias

