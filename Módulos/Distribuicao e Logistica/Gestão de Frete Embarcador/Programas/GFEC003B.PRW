#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEC003B
Painel Gerencial Clientes - Informações sobre Ocorrências

Param:
aParam[1] := Filial de
aParam[2] := Filial ate
aParam[3] := Data de
aParam[4] := Data até 
aParam[5] := CDEmit do cliente    

@sample
GFEC003B(aParam)

@author Alan Victor Lamb
@since 01/07/13
@version 1.0
--------------------------------------------------------------------------------------------------/*/  
Function GFEC003B(aParam)   
	Local aCoors := FWGetDialogSize(oMainWnd)
	Local cTitulo := 'Painel Gerencial - Ocorrências'
	Local aStruTip, aIndTip, aStruMot, aIndMot, aStruPro, aIndPro, aStruOco, aIndOco
	
	Private cAliasTip, cAliasMot, cAliasPro, cAliasOco
	
	Private aDados, aFiltros
	Private aDadosTip, aDadosMot, aDadosPro
	Private aFolhaTip, aFolhaMot, aFolhaPro
	Private oBrowseOco
	
	Private cFilialDe       := aParam[1]
	Private cFilialAte      := aParam[2]
	Private dDataDe         := If(Empty(aParam[3]),DDATABASE - 30,aParam[3])
	Private dDataAte        := If(Empty(aParam[4]),DDATABASE     ,aParam[4])
	Private cCdCliente      := aParam[5]  
	
	Private oWinTOP, oWinBLEFT, oWinBRIGHT, oWinBMID
	Private oFTipo, oFMotivo, oFProvocador
	Private oGTQtd, oGTVal, oGTDoc, oGMQtd, oGMVal, oGMDoc, oGPQtd, oGPVal, oGPDoc
	Private oFolhaTip, oFolhaMot, oFolhaPro
	Private nSeries := 5 // Quantidade máx de séries em todos os gráficos
	
	Define MsDialog oDLG Title cTitulo From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
	
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDLG,.F.)
	oFWLayer:AddLine('LINE_TOP',50,.F.)
	oFWLayer:AddLine('LINE_BOT',50,.F.)
	oFWLayer:AddCollumn('COL_TOP',100,.T.,'LINE_TOP')
	oFWLayer:AddCollumn('COL_BLEFT',33,.T.,'LINE_BOT')
	oFWLayer:AddCollumn('COL_BMID',34,.T.,'LINE_BOT')
	oFWLayer:AddCollumn('COL_BRIGHT',33,.T.,'LINE_BOT')
	oFWLayer:AddWindow('COL_BLEFT','WIN_BLEFT','Tipo da Ocorrência',100,.F.,.F.,,'LINE_BOT',)
    oFWLayer:AddWindow('COL_BMID','WIN_BMID','Motivo da Ocorrência',100,.F.,.F.,,'LINE_BOT',)
  	oFWLayer:AddWindow('COL_BRIGHT','WIN_BRIGHT','Provocador da Ocorrência',100,.F.,.F.,,'LINE_BOT',)
    
    oWinTOP    := oFWLayer:GetColPanel('COL_TOP','LINE_TOP')
    oWinBLEFT  := oFWLayer:GetWinPanel('COL_BLEFT','WIN_BLEFT','LINE_BOT')
	oWinBRIGHT := oFWLayer:GetWinPanel('COL_BRIGHT','WIN_BRIGHT','LINE_BOT')
	oWinBMID    := oFWLayer:GetWinPanel('COL_BMID','WIN_BMID','LINE_BOT')
	
	oDLG:Activate(,,,.T.,,,{||Processa({||Iniciar()})})
	
	GFEDelTab(cAliasMot)
	GFEDelTab(cAliasPro)
	GFEDelTab(cAliasTip)
	GFEDelTab(cAliasOco)
Return 

Static Function Iniciar()
	Local nCount
	
	/*
		aStru
		[n,1] = Título no browse folha de dados
		[n,2] = Nome Campo
		[n,3] = Tipo
		[n,4] = Tamanho
		[n,5] = Decimal
		[n,6] = Picture
		[n,7] = Alinhamento no browse (1=esquerda,2=direita)
	*/
	
	aStruTip := ;
	{{"Cod Tipo","GWD_CDTIPO","C",14,0,,1} ,;
	{"Desc Tipo","GU5_DESC","C",50,0,,1} ,;
	{"Quantidade","QTD_OCO","N",15,4,,2},;
	{"Valor","VAL_OCO","N",15,2,"@E 999,999,999.99",2},;
	{"Qtd Doc Carga" ,"QTD_DOC","N",15,2,,2}}
	
	aIndTip := { "GWD_CDTIPO+GU5_DESC" }
	
	aStruMot := ;
	{{"Cod Tipo","GWD_CDTIPO","C",14,0,,1},;
	{"Cod Motivo","GWD_CDMOT","C",14,0,,1},;
	{"Desc Motivo","GU6_DESC","C",50,0,,1},;
	{"Quantidade","QTD_OCO","N",15,0,,2},;
	{"Valor","VAL_OCO","N",15,2,"@E 999,999,999.99",2},;
	{"Qtd Doc Carga" ,"QTD_DOC","N",15,0,,2}}
	
	aIndMot := {"GWD_CDMOT+GU6_DESC", "GWD_CDTIPO+GWD_CDMOT+GU6_DESC"}
	
	aStruPro := ;
	{{"Cod Tipo","GWD_CDTIPO","C",14,0,,1},;
	{"Provoc","GU6_PROVOC","C",1,0,,1},;
	{"Desc Provoc","GU6_PRODES","C",15,0,,1},;
	{"Quantidade","QTD_OCO","N",15,0,,2},;
	{"Valor","VAL_OCO","N",15,2,"@E 999,999,999.99",2},;
	{"Qtd Doc Carga" ,"QTD_DOC","N",15,0,,2}}
	
	aIndPro := {"GU6_PROVOC", "GWD_CDTIPO+GU6_PROVOC"}
	
	aStruOco := ;
	{{"Filial"		 ,"GWD_FILIAL" ,"C",TamSX3("GWD_FILIAL")[1],0,,1,TamSX3("GWD_FILIAL")[1]},;
	{"Ocorrencia"	 ,"GWD_NROCO"  ,"C",TamSX3("GWD_NROCO")[1],0,,1,TamSX3("GWD_NROCO")[1]},;
	{"Resumo"	 	 ,"GWD_DSOCOR" ,"C",TamSX3("GWD_DSOCOR")[1],0,,1,10},;
	{"Val Ocorr"	 ,"VAL_OCO"    ,"N",15,2,"@E 999,999,999.99",2,10},;
	{"Tipo"	 	 ,"GWD_CDTIPO","C",TamSX3("GWD_CDTIPO")[1],0,,1,6},;
	{"Descr Tipo"	 ,"GU5_DESC"	,"C",TamSX3("GU5_DESC")[1],0,,1,10},;
	{"Motivo"		 ,"GWD_CDMOT" ,"C",TamSX3("GWD_CDMOT")[1],0,,1,6},;
	{"Descr Motivo","GU6_DESC"	,"C",TamSX3("GU6_DESC")[1],0,,1,10},;
	{"Dt Ocorren"  ,"GWD_DTOCOR","D",08,0,,1,8},;
	{"Hr Ocorren"  ,"GWD_HROCOR","C",05,0,,1,5},;
	{"Dt Criacao"  ,"GWD_DTCRIA","D",08,0,,1,8},;
	{"Hr Criacao"  ,"GWD_HRCRIA","C",05,0,,1,5},;
	{"Dt Aprov"	 ,"GWD_DTBAI" ,"D",08,0,,1,8},;
	{"Hr Aprov"	 ,"GWD_HRBAI" ,"C",05,0,,1,5},;
	{"Situacao"	 ,"GWD_SIT"	,"C",10,0,,1,10},;
	{"Nr Movto"	 ,"GWD_NRMOV" ,"C",TamSX3("GWD_NRMOV")[1],0,,1,10},;
	{"Pto Controle","GWD_CDPTCT","C",TamSX3("GWD_CDPTCT")[1],0,,1,10},;
	{"Transp" 		 ,"GWD_CDTRP"	,"C",TamSX3("GWD_CDTRP")[1],0,,1,5},;
	{"Nome Transp" ,"GU3_NMEMIT","C",TamSX3("GU3_NMEMIT")[1],0,,1,10}}
	
	aIndOco := {"GWD_FILIAL+GWD_NROCO"}
	
	cAliasTip := CriaTab(aStruTip, aIndTip)
	cAliasMot := CriaTab(aStruMot, aIndMot)
	cAliasPro := CriaTab(aStruPro, aIndPro)
	cAliasOco := CriaTab(aStruOco, aIndOco)
	
	//Carrega os dados do Grafico e do Resumo  
	aFiltros := {{"GWD","GWD_FILIAL",">=",cFilialDe},;   
				   {"GWD","GWD_FILIAL","<=",cFilialAte},;
				   {"GWD","GWD_DTOCOR",">=",Dtos(dDataDe)},;
				   {"GWD","GWD_DTOCOR","<=",Dtos(dDataAte)}}  
	
	CarregaDados(aFiltros)
	CarregaOcorr()
	CriaArray()
	
	// Browse Ocorrências
	oBrowseOco:= FWMBrowse():New() 
	oBrowseOco:SetOwner(oWinTOP)  
	oBrowseOco:SetDescription("Ocorrências")
	oBrowseOco:SetAlias(cAliasOco)
	oBrowseOco:SetLocate()
	oBrowseOco:DisableDetails()
	oBrowseOco:DisableConfig()
	oBrowseOco:SetAmbiente(.F.)
	oBrowseOco:SetWalkthru(.F.)
	oBrowseOco:SetProfileID("1") 
	oBrowseOco:SetMenuDef("")
	oBrowseOco:AddButton("Sair",{|| oDLG:End()},,1)
	oBrowseOco:AddButton("Visualizar",{|| VisualGWD() },,2)
	
	For nCount := 1 To Len(aStruOco)
		oBrowseOco:AddColumn({aStruOco[nCount][1],;
							     &("{|| (cAliasOco)->" + aStruOco[nCount][2] + "}"),;
							     aStruOco[nCount][3],;
							     aStruOco[nCount][6],;
							     aStruOco[nCount][7],;
							     aStruOco[nCount][8],;
							     aStruOco[nCount][5],;
							     .F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}})						     
	Next nCount
	
	oBrowseOco:Activate()
	
	/* Cria os Folders */
	oFTipo :=  tFolder():New(30,0,{"Quantidade","Valor","Qtd Doc Carga","Dados"},{"G1","G2","G3","G4"},oWinBLEFT,)
	oFTipo:Align := CONTROL_ALIGN_ALLCLIENT
	oFMotivo :=  tFolder():New(30,0,{"Quantidade","Valor","Qtd Doc Carga","Dados"},{"G1","G2","G3","G4"},oWinBMID,)
	oFMotivo:Align := CONTROL_ALIGN_ALLCLIENT
	oFProvocador :=  tFolder():New(30,0,{"Quantidade","Valor","Qtd Doc Carga","Dados"},{"G1","G2","G3","G4"},oWinBRIGHT,)
	oFProvocador:Align := CONTROL_ALIGN_ALLCLIENT
	
	/* Cria os Gráficos */
	CriaGrafico("oGTQtd", oFTipo:aDialogs[1],.T.,.F.)
	CriaGrafico("oGTVal", oFTipo:aDialogs[2],.T.,.F.,.T.) 
	CriaGrafico("oGTDoc", oFTipo:aDialogs[3],.T.,.F.)
	CriaGrafico("oGMQtd", oFMotivo:aDialogs[1],,.F.)
	CriaGrafico("oGMVal", oFMotivo:aDialogs[2],,.F.,.T.)
	CriaGrafico("oGMDoc", oFMotivo:aDialogs[3],,.F.)
	CriaGrafico("oGPQtd", oFProvocador:aDialogs[1],,.F.)
	CriaGrafico("oGPVal", oFProvocador:aDialogs[2],,.F.,.T.)
	CriaGrafico("oGPDoc", oFProvocador:aDialogs[3],,.F.)
	
	/* Cria as folhas de dados */
	CriaFolha("oFolhaTip", oFTipo:aDialogs[4], aStruTip, aFolhaTip)
	CriaFolha("oFolhaMot", oFMotivo:aDialogs[4], aStruMot, aFolhaMot, {1})
	CriaFolha("oFolhaPro", oFProvocador:aDialogs[4], aStruPro, aFolhaPro, {1,2})
	
	AtuDados()
Return 

Static Function VisualGWD()
	dbSelectArea("GWD")
	GWD->(dbSetOrder(1))
	If GWD->(dbSeek((cAliasOco)->(GWD_FILIAL+GWD_NROCO)))
		FWExecView("Visualizar", "GFEC032", 1,, {||.T.})
	EndIf 
Return Nil

Static Function AtuDados()
	/* Atualiza infos gráficos */
	AtuGrafico("oGTQtd", aDadosTip, 3, "Tipo por Quantidade")
	AtuGrafico("oGTVal", aDadosTip, 4, "Tipo por Valor")
	AtuGrafico("oGTDoc", aDadosTip, 5, "Tipo por Qtd Doc Carga")
	
	AtuGrafico("oGMQtd", aDadosMot, 3, "Motivo por Quantidade")
	AtuGrafico("oGMVal", aDadosMot, 4, "Motivo por Valor")
	AtuGrafico("oGMDoc", aDadosMot, 5, "Motivo por Qtd Doc Carga")
	
	AtuGrafico("oGPQtd", aDadosPro, 3, "Provocador por Quantidade")
	AtuGrafico("oGPVal", aDadosPro, 4, "Provocador por Valor")
	AtuGrafico("oGPDoc", aDadosPro, 5, "Provocador por Qtd Doc Carga")
	
	// Volta pra primeira aba em todos os folders
	oFTipo:SetOption(1)
	oFMotivo:SetOption(oFTipo:nOption)
	oFProvocador:SetOption(oFTipo:nOption)
	
	//Atualiza os browses de folha de dados
	oFolhaTip:SetArray(aFolhaTip)
	oFolhaTip:UpdateBrowse()
	oFolhaMot:SetArray(aFolhaMot)
	oFolhaMot:UpdateBrowse()
	oFolhaPro:SetArray(aFolhaPro)
	oFolhaPro:UpdateBrowse()
Return Nil

Static Function CriaGrafico(cGrf, oOwner, lAction, lLegend, lDecimal)
	Local oPnl
	Local cMVGFE015	:= SuperGetMV("MV_GFE015",,"1")
	
	Default lAction := .F.
	Default lLegend := .T. // Mostra legenda do gráfico como padrão
	
	oPnl := tPanel():New(30,0,,oOwner,,,,,,)
	oPnl:Align := CONTROL_ALIGN_ALLCLIENT
	
	&(cGrf) := FWChartFactory():New()
 	&(cGrf) := &(cGrf):GetInstance(PIECHART)
 	&(cGrf):Init(oPnl,!lLegend)
 	
 	If lDecimal
 		&(cGrf):SetPicture("@E 999,999,999.99")
 	EndIf
 	
 	If lLegend
 		&(cGrf):SetLegend(CONTROL_ALIGN_BOTTOM)
 	EndIf
 	
 	If lAction
 		&(cGrf):SetSerieAction({|nSerie|GrfClick(nSerie, cGrf)})
 	EndIf
 	
 	If cMVGFE015 == "2"
 		&(cGrf):oFwChartColor:SetColor("RANDOM")
 	EndIf
 	
 	&(cGrf):Build()
Return Nil

/*
	cFolha = Objeto Browse
	oOwner = onde ficará o browse
	aStru = estrutura das colunas
	aDados = dados do browse
	aExclui = array com os índices das colunas que não devem ser exibidas
*/
Static Function CriaFolha(cFolha, oOwner, aStru, aDados, aExclui)
	Local nCount := 0
	Default aStru := {}
	Default aExclui := {}
	
	&(cFolha) := FWBrowse():New()
	&(cFolha):SetOwner(oOwner)
	&(cFolha):SetDescription("Dados") 
	&(cFolha):SetDataArray()
	&(cFolha):DisableFilter()
	&(cFolha):DisableConfig()
	
	//
	// aStru - {"Cod Tipo Ocorr","GWD_CDTIPO","C",14,0,"@E 999,999,999.00",1}
	// GFEC001COL(cTitulo,nArrData,cPicture,nAlign,nSize,cBrowse)
	//
	
	For nCount := 1 To Len(aStru)
		If aScan(aExclui, nCount) == 0
			&(cFolha):SetColumns(GFEC001COL(aStru[nCount,1],nCount,aStru[nCount,6],aStru[nCount,7],aStru[nCount,4],cFolha))
		EndIf
	Next nCount 
		
	If aDados != Nil
		&(cFolha):SetArray(aDados)
	EndIf
	
	&(cFolha):Activate()
Return Nil	

Static Function AtuGrafico(cGrf,aDados,nCampoVal,cTitle)
	Local nCount
	Local cDescOutros
	Local nValOutros
	Local aDadosGrf := {}
	nValOutros := 0
	
	//Ordena o array de forma decrescente conforme o campo
	aSORT(aDados,,,{ |x,y| x[nCampoVal] > y[nCampoVal] })
	
	&(cGrf):Reset()
	&(cGrf):SetTitle(cTitle,CONTROL_ALIGN_CENTER)
	
	For nCount := 1 To Len(aDados)
		If nCount < nSeries
			&(cGrf):AddSerie(AllTrim(aDados[nCount,2]), aDados[nCount,nCampoVal])
		Else
			nValOutros += aDados[nCount,nCampoVal]
		EndIf	
	Next nCount
	
	If nCount >= nSeries .And. nValOutros > 0
		cDescOutros := 'Outros'
		&(cGrf):AddSerie(cDescOutros, nValOutros)
	EndIf
	
	&(cGrf):Build()
Return Nil

/*
	Função utilizada no gráfico Tipo da Ocorrência.
	------------------------------------------------------------------
	Filtra os gráficos Motivo da Ocorrência e Provocador da ocorrência 
	pelo código do tipo da ocorrência selecionado
*/
Static Function GrfClick(nSerie, cSender)
	Local nCount := 0
	Local nCampoVal := 0
	
	Local cTipo := SUBSTR(cSender,4,3)
	Local cTipoDesc := ''
	Local cTipoFiltro := ''
	
	Local lOutros := .F.
	Local aDados := {}
	Local oGrf := &(cSender) 
	
	Local cDescMot := ''
	Local cDescPro := ''
	
	Do Case
		Case cTipo == "Qtd"
			nCampoVal := 3
			cDescMot := "Motivo por Quantidade"
			cDescPro := "Provocador por Quantidade"
		Case cTipo == "Val"
			nCampoVal := 4
			cDescMot := "Motivo por Valor"
			cDescPro := "Provocador por Valor"
		Case cTipo == "Doc"
			nCampoVal := 5
			cDescMot := "Motivo por Quantidade"
			cDescPro := "Provocador por Qtd Doc Carga"
	EndCase
	
	If nSerie != 0
		aSORT(aDadosTip,,,{ |x,y| x[nCampoVal] > y[nCampoVal] })
	
		For nCount := 1 To Len(oGrf:aSeries)
			If oGrf:aSeries[nCount]:nID == nSerie
				If nCount == nSeries
					lOutros := .T.
					cTipoDesc := 'Outros'
				Else
					cTipoFiltro := aDadosTip[nCount,1] //GWD_CDTIPO
					cTipoDesc   := aDadosTip[nCount,2] //GU5_DESC
				EndIf
				
				Exit
			Else
				cTipoFiltro += aDadosTip[nCount,1] + ";"
			EndIf
		Next nCount
		
		cDescMot := "Motivos de " + cTipoDesc
		cDescPro := "Provocadores de " + cTipoDesc
	EndIf
	
	CriaArray(cTipoFiltro, lOutros)
	AtuGrafico("oGM"+cTipo,aDadosMot,nCampoVal,cDescMot)
	AtuGrafico("oGP"+cTipo,aDadosPro,nCampoVal,cDescPro)
	oFMotivo:SetOption(oFTipo:nOption)
	oFProvocador:SetOption(oFTipo:nOption)
Return Nil

Static Function CarregaDados(aFiltros,cBrwFiltro)
	Local cQuery := ''
	Local cTmp   := ''
	Default cBrwFiltro := ''
	
	dbSelectArea(cAliasTip)
	ZAP
	dbSelectArea(cAliasMot)
	ZAP
	dbSelectArea(cAliasPro)
	ZAP
	
	// Array do browse estatísticas
	aBrowse := {}
		
	cQuery += "	SELECT GWD_CDTIPO, " 
	cQuery += "	       GU5_DESC, "
	cQuery += "		   COUNT(*) QTD_OCO, "
	cQuery += "		   SUM(GWI_VLFRET+GWF_VLAJUS) VAL_OCO, "
	cQuery += "		   SUM(GW1L.QTD_DOCS) QTD_DOC "
	cQuery += "	  FROM " + RetSQLName("GWD") + " GWD "
	cQuery += "	 INNER JOIN (SELECT GWL.GWL_NROCO,"
	cQuery += "      					GWL.GWL_FILIAL,	"
	cQuery += " 						COUNT(*) QTD_DOCS "
	cQuery += "	   			    FROM " + RetSQLName("GWL") + " GWL "
	cQuery += "	   			   INNER JOIN " + RetSQLName("GW1") + " GW1 ON GW1.GW1_FILIAL = GWL.GWL_FILDC "
	cQuery += "						   				AND GW1.GW1_CDTPDC = GWL.GWL_TPDC "
	cQuery += "						   				AND GW1.GW1_EMISDC = GWL.GWL_EMITDC "
	cQuery += "						   				AND GW1.GW1_SERDC  = GWL.GWL_SERDC "
	cQuery += "						   				AND GW1.GW1_NRDC   = GWL.GWL_NRDC "
	cQuery += "						   				AND GW1.D_E_L_E_T_ = '' "
	cQuery += "				   WHERE GWL.D_E_L_E_T_ = '' "
	cQuery += "					 AND (GW1.GW1_CDREM = '"+cCdCliente+"' OR GW1.GW1_CDDEST = '"+cCdCliente+"') "
	cQuery += "				   GROUP BY GWL.GWL_NROCO, GWL.GWL_FILIAL "
	cQuery += "	             ) GW1L ON GW1L.GWL_NROCO  = GWD.GWD_NROCO "
	cQuery += "	             	   AND GW1L.GWL_FILIAL = GWD.GWD_FILIAL "
	cQuery += "	  LEFT JOIN " + RetSQLName("GU5") + " GU5 ON GU5.GU5_CDTIPO = GWD.GWD_CDTIPO AND GU5.D_E_L_E_T_ = '' "
	cQuery += "	  LEFT JOIN " + RetSQLName("GU6") + " GU6 ON GU6.GU6_CDMOT  = GWD.GWD_CDMOT AND GU6.D_E_L_E_T_ = '' "
	cQuery += "	  LEFT JOIN ( "
	cQuery += "	    	SELECT GWF_FILIAL, GWF_NROCO, GWF_VLAJUS, SUM(GWI_VLFRET) GWI_VLFRET "
	cQuery += "	    	  FROM " + RetSQLName("GWF") + " GWF "
	cQuery += "	    	 INNER JOIN " + RetSQLName("GWI") + " GWI ON GWI.D_E_L_E_T_ = '' "
	cQuery += "	    	                      AND GWI.GWI_TOTFRE = '1' "
	cQuery += "	    	                      AND GWI.GWI_NRCALC = GWF.GWF_NRCALC "
	cQuery += "	    	                      AND GWI.GWI_FILIAL = GWF.GWF_FILIAL "
	cQuery += "	    	 WHERE GWF.D_E_L_E_T_ = '' "
	cQuery += "	    	 GROUP BY GWF_FILIAL, GWF_NROCO, GWF_VLAJUS "
	cQuery += "	      ) GWFI ON GWFI.GWF_FILIAL = GWD.GWD_FILIAL "
	cQuery += "	            AND GWFI.GWF_NROCO  = GWD.GWD_NROCO  "
	cQuery += "	 WHERE GWD.D_E_L_E_T_ = '' " + cBrwFiltro + CriaQueryCondicao(aFiltros,"")
	cQuery += "	 GROUP BY GWD_CDTIPO,GU5_DESC"
	
	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	If (cTmp)->(Recno()) > 0
		While (cTmp)->(!Eof())
			RecLock(cAliasTip,.T.)
			(cAliasTip)->GWD_CDTIPO  := (cTmp)->GWD_CDTIPO
			(cAliasTip)->GU5_DESC  	:= (cTmp)->GU5_DESC
			(cAliasTip)->QTD_OCO  	:= (cTmp)->QTD_OCO
			(cAliasTip)->VAL_OCO  	:= (cTmp)->VAL_OCO
			(cAliasTip)->QTD_DOC     := (cTmp)->QTD_DOC
			MsUnlock()
			
			(cTmp)->(dbSkip())
		EndDo
	EndIf
	
	(cTmp)->(dbCloseArea())
	
	cQuery := ""
	cQuery += " SELECT GWD_CDTIPO,"
	cQuery += "        GWD_CDMOT,"
	cQuery += "        GU6_DESC,"
	cQuery += "	    COUNT(*) QTD_OCO,"
	cQuery += "	    SUM(GWI_VLFRET+GWF_VLAJUS) VAL_OCO,"
	cQuery += "	    SUM(GW1L.QTD_DOCS) QTD_DOC"
	cQuery += "  FROM " + RetSQLName("GWD") + " GWD"
	cQuery += "  INNER JOIN (SELECT GWL.GWL_NROCO,"
	cQuery += "     					GWL.GWL_FILIAL,	"
	cQuery += "						COUNT(*) QTD_DOCS"
	cQuery += "   			    FROM " + RetSQLName("GWL") + " GWL"
	cQuery += "   			   INNER JOIN " + RetSQLName("GW1") + " GW1 ON GW1.GW1_FILIAL = GWL.GWL_FILDC"
	cQuery += "					   				AND GW1.GW1_CDTPDC = GWL.GWL_TPDC"
	cQuery += "					   				AND GW1.GW1_EMISDC = GWL.GWL_EMITDC"
	cQuery += "					   				AND GW1.GW1_SERDC  = GWL.GWL_SERDC"
	cQuery += "					   				AND GW1.GW1_NRDC   = GWL.GWL_NRDC"
	cQuery += "					   				AND GW1.D_E_L_E_T_ = ' '"
	cQuery += "			   WHERE GWL.D_E_L_E_T_ = ' '"
	cQuery += "				 AND (GW1.GW1_CDREM = '"+cCdCliente+"' OR GW1.GW1_CDDEST = '"+cCdCliente+"')"
	cQuery += "			   GROUP BY GWL.GWL_NROCO, GWL.GWL_FILIAL"
	cQuery += "             ) GW1L ON GW1L.GWL_NROCO  = GWD.GWD_NROCO"
	cQuery += "             	     AND GW1L.GWL_FILIAL = GWD.GWD_FILIAL"
	cQuery += "  LEFT JOIN " + RetSQLName("GU5") + " GU5 ON GU5.GU5_CDTIPO = GWD.GWD_CDTIPO AND GU5.D_E_L_E_T_ = ' '"
	cQuery += "  LEFT JOIN " + RetSQLName("GU6") + " GU6 ON GU6.GU6_CDMOT = GWD.GWD_CDMOT AND GU6.D_E_L_E_T_ = ' '"
	cQuery += "  LEFT JOIN ( "
	cQuery += "	    	SELECT GWF_FILIAL, GWF_NROCO, GWF_VLAJUS, SUM(GWI_VLFRET) GWI_VLFRET "
	cQuery += "	    	  FROM " + RetSQLName("GWF") + " GWF "
	cQuery += "	    	 INNER JOIN " + RetSQLName("GWI") + " GWI ON GWI.D_E_L_E_T_ = ' ' "
	cQuery += "	    	                      AND GWI.GWI_TOTFRE = '1' "
	cQuery += "	    	                      AND GWI.GWI_NRCALC = GWF.GWF_NRCALC "
	cQuery += "	    	                      AND GWI.GWI_FILIAL = GWF.GWF_FILIAL "
	cQuery += "	    	 WHERE GWF.D_E_L_E_T_ = ' ' "
	cQuery += "	    	 GROUP BY GWF_FILIAL, GWF_NROCO, GWF_VLAJUS "
	cQuery += "	    ) GWFI ON GWFI.GWF_FILIAL = GWD.GWD_FILIAL " 
	cQuery += "	         AND GWFI.GWF_NROCO  = GWD.GWD_NROCO  "
	cQuery += "	 WHERE GWD.D_E_L_E_T_ = ' ' " + cBrwFiltro + CriaQueryCondicao(aFiltros,"")
	cQuery += " GROUP BY GWD_CDTIPO,GWD_CDMOT,GU6_DESC"
	
	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	If (cTmp)->(Recno()) > 0
		While (cTmp)->(!Eof())
			RecLock(cAliasMot,.T.)
			(cAliasMot)->GWD_CDTIPO  := (cTmp)->GWD_CDTIPO
			(cAliasMot)->GWD_CDMOT  	:= (cTmp)->GWD_CDMOT
			(cAliasMot)->GU6_DESC  	:= (cTmp)->GU6_DESC
			(cAliasMot)->QTD_OCO  	:= (cTmp)->QTD_OCO
			(cAliasMot)->VAL_OCO  	:= (cTmp)->VAL_OCO
			(cAliasMot)->QTD_DOC     := (cTmp)->QTD_DOC
			MsUnlock()
			
			(cTmp)->(dbSkip())
		EndDo
	EndIf
	
	(cTmp)->(dbCloseArea())
	
	cQuery := ""
	cQuery += "	SELECT GWD_CDTIPO,"
	cQuery += "	       GU6_PROVOC,"
	cQuery += "	       CASE "
	cQuery += "	        WHEN GU6_PROVOC = '1' THEN 'Transportador' "
	cQuery += "	        WHEN GU6_PROVOC = '2' THEN 'Remetente' "
	cQuery += "	        WHEN GU6_PROVOC = '3' THEN 'Destinatario'  "
	cQuery += "	        WHEN GU6_PROVOC = '4' THEN 'Outro'  "
	cQuery += "	       END GU6_PRODES, "
	cQuery += "		   COUNT(*) QTD_OCO, "
	cQuery += "		   SUM(GWI_VLFRET+GWF_VLAJUS) VAL_OCO, "
	cQuery += "		   SUM(GW1L.QTD_DOCS) QTD_DOC "
	cQuery += "	  FROM " + RetSQLName("GWD") + " GWD "
	cQuery += "  INNER JOIN (SELECT GWL.GWL_NROCO, "
	cQuery += "      					GWL.GWL_FILIAL,	 "
	cQuery += " 						COUNT(*) QTD_DOCS "
	cQuery += "	   			    FROM " + RetSQLName("GWL") + " GWL "
	cQuery += "	   			   INNER JOIN " + RetSQLName("GW1") + " GW1 ON GW1.GW1_FILIAL = GWL.GWL_FILDC "
	cQuery += "						   				AND GW1.GW1_CDTPDC = GWL.GWL_TPDC "
	cQuery += "						   				AND GW1.GW1_EMISDC = GWL.GWL_EMITDC "
	cQuery += "						   				AND GW1.GW1_SERDC  = GWL.GWL_SERDC "
	cQuery += "						   				AND GW1.GW1_NRDC   = GWL.GWL_NRDC "
	cQuery += "						   				AND GW1.D_E_L_E_T_ = ' ' "
	cQuery += "				   WHERE GWL.D_E_L_E_T_ = ' ' "
	cQuery += "				 	  AND (GW1.GW1_CDREM = '"+cCdCliente+"' OR GW1.GW1_CDDEST = '"+cCdCliente+"')"
	cQuery += "				   GROUP BY GWL.GWL_NROCO, GWL.GWL_FILIAL "
	cQuery += "	             ) GW1L ON GW1L.GWL_NROCO  = GWD.GWD_NROCO "
	cQuery += "	             	     AND GW1L.GWL_FILIAL = GWD.GWD_FILIAL "
	cQuery += "	  LEFT JOIN " + RetSQLName("GU5") + " GU5 ON GU5.GU5_CDTIPO = GWD.GWD_CDTIPO AND GU5.D_E_L_E_T_ = ' ' "
	cQuery += "	  LEFT JOIN " + RetSQLName("GU6") + " GU6 ON GU6.GU6_CDMOT = GWD.GWD_CDMOT AND GU6.D_E_L_E_T_ = ' ' "
	cQuery += "	  LEFT JOIN ( "
    cQuery += "	    	SELECT GWF_FILIAL, GWF_NROCO, GWF_VLAJUS, SUM(GWI_VLFRET) GWI_VLFRET "
    cQuery += "	    	  FROM " + RetSQLName("GWF") + " GWF "
    cQuery += "	    	 INNER JOIN " + RetSQLName("GWI") + " GWI ON GWI.D_E_L_E_T_ = ' ' "
    cQuery += "	    	                      AND GWI.GWI_TOTFRE = '1' "
    cQuery += "	    	                      AND GWI.GWI_NRCALC = GWF.GWF_NRCALC "
    cQuery += "	    	                      AND GWI.GWI_FILIAL = GWF.GWF_FILIAL "
    cQuery += "	    	 WHERE GWF.D_E_L_E_T_ = ' ' "
    cQuery += "	    	 GROUP BY GWF_FILIAL, GWF_NROCO, GWF_VLAJUS "
    cQuery += "	    ) GWFI ON GWFI.GWF_FILIAL = GWD.GWD_FILIAL " 
    cQuery += "	         AND GWFI.GWF_NROCO  = GWD.GWD_NROCO  "
	cQuery += "	 WHERE GWD.D_E_L_E_T_ = ' ' " + cBrwFiltro + CriaQueryCondicao(aFiltros,"")
	cQuery += "	 GROUP BY GWD_CDTIPO,GU6_PROVOC "
	
	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	If (cTmp)->(Recno()) > 0
		While (cTmp)->(!Eof())
			RecLock(cAliasPro,.T.)
			(cAliasPro)->GWD_CDTIPO  := (cTmp)->GWD_CDTIPO
			(cAliasPro)->GU6_PROVOC 	:= (cTmp)->GU6_PROVOC
			(cAliasPro)->GU6_PRODES	:= (cTmp)->GU6_PRODES
			(cAliasPro)->QTD_OCO  	:= (cTmp)->QTD_OCO
			(cAliasPro)->VAL_OCO  	:= (cTmp)->VAL_OCO
			(cAliasPro)->QTD_DOC     := (cTmp)->QTD_DOC
			MsUnlock()
			
			(cTmp)->(dbSkip())
		EndDo
	EndIf
	
	(cTmp)->(dbCloseArea())
	
Return Nil

/* 
	Cria os arrays para as séries dos gráficos 
*/
Static Function CriaArray(cTipoFiltro,lOutros)
	Local cTmpMot
	Local cTmpDesc
	Local cTmpGrpF := ''
	Local nTmpSum1 := 0
	Local nTmpSum2 := 0
	Local nTmpSum3 := 0
	Default cTipoFiltro := '' // Filtro do tipo da ocorrência
	Default lOutros := .F. // Se é fatia "Outros" (Nesse caso, o cFiltroTipo contém uma string com os dados das fatias que não são outros. "CDTIPO001;CDTIPO002;etc"
	
	// 
	// Motivos: apenas coloca no array, já vem pronto do banco.
	// 
	// aDadosTip
	// {n, {CDTIPO, GU5_DESC, QTD_OCO,VAL_OCO,QTD_DOC}}
	//
	
	If Empty(cTipoFiltro)
		aDadosTip := {}
		aFolhaTip := {}
		
		dbSelectArea(cAliasTip)
		(cAliasTip)->(dbSetOrder(1))
		(cAliasTip)->(dbGoTop())
		
		While (cAliasTip)->(!Eof())
			aAdd(aDadosTip, {(cAliasTip)->GWD_CDTIPO, (cAliasTip)->GU5_DESC,;
							   (cAliasTip)->QTD_OCO, (cAliasTip)->VAL_OCO, ;
							   (cAliasTip)->QTD_DOC })
			(cAliasTip)->(dbSkip())
		EndDo
		
		aFolhaTip := aDadosTip
	EndIf
	
	// 
	// Tipos: Agrupa dados pelo GWD_CDTIPO
	// Quando detalhado, filtra pelo GWD_CDMOT
	// 
	// aDadosMot
	// {n,{ CDTIPO, GU6_DESC, QTD_OCO, VAL_OCO, QTD_DOC}}
	//
	
	aDadosMot := {}
	aFolhaMot := {}
	
	dbSelectArea(cAliasMot)
	If Empty(cTipoFiltro) .Or. lOutros
		(cAliasMot)->(dbSetOrder(1))
	Else
		(cAliasMot)->(dbSetOrder(2))
	EndIf
	
	(cAliasMot)->(dbGoTop())
	
	cTmpGrpF := ''
	
	While (cAliasMot)->(!Eof())
		
		/* 
			Agrupa os dados pelo motivo da ocorrência sem filtro de motivo
		*/
		If Len(aFolhaMot) == 0 .Or. AllTrim(cTmpGrpF) != AllTrim((cAliasMot)->GWD_CDMOT)
			cTmpGrpF :=  (cAliasMot)->GWD_CDMOT
			
			aAdd(aFolhaMot, {(cAliasMot)->GWD_CDTIPO, (cAliasMot)->GWD_CDMOT,;
								(cAliasMot)->GU6_DESC, (cAliasMot)->QTD_OCO, ;
								(cAliasMot)->VAL_OCO, (cAliasMot)->QTD_DOC })
		Else
			aFolhaMot[Len(aFolhaMot), 4] := aFolhaMot[Len(aFolhaMot), 4] + (cAliasMot)->QTD_OCO
			aFolhaMot[Len(aFolhaMot), 5] := aFolhaMot[Len(aFolhaMot), 5] + (cAliasMot)->VAL_OCO
			aFolhaMot[Len(aFolhaMot), 6] := aFolhaMot[Len(aFolhaMot), 6] + (cAliasMot)->QTD_DOC
		EndIf
		
		If (Empty(cTipoFiltro) .Or. ;
		    (!lOutros .And. AllTrim((cAliasMot)->GWD_CDTIPO) == AllTrim(cTipoFiltro))  .Or. ;
		    (lOutros .And. !((cAliasMot)->GWD_CDTIPO $ cTipoFiltro)))
			If Empty(cTmpMot)
				cTmpMot := (cAliasMot)->GWD_CDMOT
				cTmpDesc := (cAliasMot)->GU6_DESC
				nTmpSum1 := (cAliasMot)->QTD_OCO
				nTmpSum2 := (cAliasMot)->VAL_OCO
				nTmpSum3 := (cAliasMot)->QTD_DOC
			Else
				If cTmpMot == (cAliasMot)->GWD_CDMOT
					nTmpSum1 += (cAliasMot)->QTD_OCO
					nTmpSum2 += (cAliasMot)->VAL_OCO
					nTmpSum3 += (cAliasMot)->QTD_DOC
				Else
					aAdd(aDadosMot, { cTmpMot, cTmpDesc, nTmpSum1, nTmpSum2, nTmpSum3 })
					
					cTmpMot := (cAliasMot)->GWD_CDMOT
					cTmpDesc := (cAliasMot)->GU6_DESC
					nTmpSum1 := (cAliasMot)->QTD_OCO
					nTmpSum2 := (cAliasMot)->VAL_OCO
					nTmpSum3 := (cAliasMot)->QTD_DOC
				EndIf
			EndIf
		EndIf
		
	    (cAliasMot)->(dbSkip())	    
	EndDo
	
	If (!Empty(cTmpMot) .And. Len(aDadosMot) == 0) .Or.(Len(aDadosMot) > 0 .And. aDadosMot[Len(aDadosMot), 1] != cTmpMot)
		aAdd(aDadosMot, { cTmpMot, cTmpDesc, nTmpSum1, nTmpSum2, nTmpSum3 })
	EndIf
	
	// 
	// Provocador: Agrupa dados pelo GWD_CDTIPO
	// Quando detalhado, filtra pelo GWD_CDMOT
	// 
	// aDadosPro
	// {n,{ CDTIPO, GU6_PROVOC, QTD_OCO, VAL_OCO, QTD_DOC}}
	//
	
	aDadosPro := {}
	aFolhaPro := {}
	
	cTmpMot  := ''
	cTmpDesc := ''
	
	dbSelectArea(cAliasPro)
	If Empty(cTipoFiltro) .Or. lOutros
		(cAliasPro)->(dbSetOrder(1))
	Else
		(cAliasPro)->(dbSetOrder(2))
	EndIf
	
	(cAliasPro)->(dbGoTop())
	
	// 
	// Agrupamento das folhas de dados
	//
	cTmpGrpF := ''
	
	While (cAliasPro)->(!Eof())
		
		/* 
			Agrupa os dados por descrição de Provocador da Ocorrência sem filtro de motivo
		*/
		If Len(aFolhaPro) == 0 .Or. AllTrim(cTmpGrpF) != AllTrim((cAliasPro)->GU6_PRODES)
			cTmpGrpF :=  (cAliasPro)->GU6_PRODES
			
			aAdd(aFolhaPro, {(cAliasPro)->GWD_CDTIPO, (cAliasPro)->GU6_PROVOC,;
								(cAliasPro)->GU6_PRODES, (cAliasPro)->QTD_OCO, ;
							    (cAliasPro)->VAL_OCO, (cAliasPro)->QTD_DOC})
		Else
			aFolhaPro[Len(aFolhaPro), 4] := aFolhaPro[Len(aFolhaPro), 4] + (cAliasPro)->QTD_OCO
			aFolhaPro[Len(aFolhaPro), 5] := aFolhaPro[Len(aFolhaPro), 5] + (cAliasPro)->VAL_OCO
			aFolhaPro[Len(aFolhaPro), 6] := aFolhaPro[Len(aFolhaPro), 6] + (cAliasPro)->QTD_DOC
		EndIf
		
		If (Empty(cTipoFiltro) .Or. ;
		    (!lOutros .And. AllTrim((cAliasPro)->GWD_CDTIPO) == AllTrim(cTipoFiltro))  .Or. ;
		    (lOutros .And. !((cAliasPro)->GWD_CDTIPO $ cTipoFiltro)))
			If Empty(cTmpMot)
				cTmpMot := (cAliasPro)->GU6_PROVOC
				cTmpDesc := (cAliasPro)->GU6_PRODES
				nTmpSum1 := (cAliasPro)->QTD_OCO
				nTmpSum2 := (cAliasPro)->VAL_OCO
				nTmpSum3 := (cAliasPro)->QTD_DOC
			Else
				If AllTrim(cTmpMot) == AllTrim((cAliasPro)->GU6_PROVOC)
					nTmpSum1 += (cAliasPro)->QTD_OCO
					nTmpSum2 += (cAliasPro)->VAL_OCO
					nTmpSum3 += (cAliasPro)->QTD_DOC
				Else
					aAdd(aDadosPro, { cTmpMot, cTmpDesc, nTmpSum1, nTmpSum2, nTmpSum3 })
					
					cTmpMot  := (cAliasPro)->GU6_PROVOC
					cTmpDesc := (cAliasPro)->GU6_PRODES
					nTmpSum1 := (cAliasPro)->QTD_OCO
					nTmpSum2 := (cAliasPro)->VAL_OCO
					nTmpSum3 := (cAliasPro)->QTD_DOC
				EndIf
			EndIf
		EndIf
		
	    (cAliasPro)->(dbSkip())	    
	EndDo
	
	If (!Empty(cTmpMot) .And. Len(aDadosPro) == 0) .Or.(Len(aDadosPro) > 0 .And. aDadosPro[Len(aDadosPro), 1] != cTmpMot)
		aAdd(aDadosPro, { cTmpMot, cTmpDesc, nTmpSum1, nTmpSum2, nTmpSum3 })
	EndIf
	
Return Nil

Static Function CriaTab(aStru, aIndices)
	Local cAlias
	Local nCont
	Local aStruct := {}
	
	For nCont := 1 to Len(aStru)
		aADD(aStruct,{aStru[nCont][2],;  //Nome do campo
						aStru[nCont][3],;  //Tipo
						aStru[nCont][4],;  //Tamanho
						aStru[nCont][5]}) //Decimal
	Next nCont
	
	cAlias := GFECriaTab({aStruct,aIndices})
Return cAlias

//=========================================================================/ 
//Validação do filtro do Browse, adapta a expressão do filtro para uma expressão SQL
//=========================================================================/
Function GFEC003BV(aParam) 
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
	
	Processa({||CarregaDados(aFiltros,cFiltro),CriaArray(),AtuDados()})
Return .T.         



Static Function CarregaOcorr()
	Local cQuery := ""
	Local cTmp    := ""
	Local aSits   := {"Pendente","Aprovada","Reprovada"}
	
	cQuery += "	SELECT GWD.GWD_FILIAL,"
	cQuery += "	       GWD.GWD_NROCO,"
	cQuery += "	       GWD.GWD_DSOCOR,"
	cQuery += "	       VAL.GWI_VLFRET VAL_OCO,"
	cQuery += "	       GWD.GWD_CDTIPO,"
	cQuery += "	       GWD.GWD_CDMOT,"
	cQuery += "	       GWD.GWD_DTOCOR,"
	cQuery += "	       GWD.GWD_HROCOR,"
	cQuery += "	       GWD.GWD_DTCRIA,"
	cQuery += "	       GWD.GWD_HRCRIA,"
	cQuery += "	       GWD.GWD_DTBAI,"
	cQuery += "	       GWD.GWD_HRBAI,"
	cQuery += "	       GWD.GWD_SIT,"
	cQuery += "	       GWD.GWD_NRMOV,"
	cQuery += "	       GWD.GWD_CDPTCT,"
	cQuery += "	       GWD.GWD_CDTRP"
	cQuery += "	  FROM " + RetSQLName("GWD") + " GWD"
	cQuery += "	 INNER JOIN ("
	cQuery += "	 		SELECT DISTINCT GWL.GWL_FILIAL, GWL.GWL_NROCO "
	cQuery += "			  FROM " + RetSQLName("GWL") + " GWL"
	cQuery += "			 INNER JOIN " + RetSQLName("GW1") + " GW1 ON GW1.GW1_FILIAL = GWL.GWL_FILDC"
	cQuery += "			                      AND GW1.GW1_CDTPDC = GWL.GWL_TPDC"
	cQuery += "			                      AND GW1.GW1_EMISDC = GWL.GWL_EMITDC"
	cQuery += "			                      AND GW1.GW1_SERDC  = GWL.GWL_SERDC"
	cQuery += "			                      AND GW1.GW1_NRDC   = GWL.GWL_NRDC"
	cQuery += "			                      AND GW1.D_E_L_E_T_ = ''"
	cQuery += "			                      AND (GW1.GW1_CDREM = '"+cCdCliente+"' OR GW1.GW1_CDDEST = '"+cCdCliente+"')"
	cQuery += "			 WHERE GWL.D_E_L_E_T_ = ''"
	cQuery += "	 ) GWL ON GWL.GWL_FILIAL = GWD.GWD_FILIAL"
	cQuery += "	      AND GWL.GWL_NROCO  = GWD.GWD_NROCO"
	cQuery += "	  LEFT JOIN ("
	cQuery += "	  	SELECT GWF.GWF_FILIAL, GWF.GWF_NROCO, SUM(GWF_VLAJUS+GWI_VLFRET) GWI_VLFRET"
	cQuery += "		  FROM " + RetSQLName("GWF") + " GWF"
	cQuery += "		 INNER JOIN ("
	cQuery += "		 	SELECT GWI_FILIAL, GWI_NRCALC, SUM(GWI_VLFRET) GWI_VLFRET"
	cQuery += "		 	  FROM " + RetSQLName("GWI")
	cQuery += "		 	 WHERE D_E_L_E_T_ = ''"
	cQuery += "		 	   AND GWI_TOTFRE = '1'"
	cQuery += "		 	 GROUP BY GWI_FILIAL, GWI_NRCALC"
	cQuery += "		 ) GWI ON GWI.GWI_FILIAL = GWF.GWF_FILIAL"
	cQuery += "		 	  AND GWI.GWI_NRCALC = GWF.GWF_NRCALC"
	cQuery += "		 WHERE GWF.D_E_L_E_T_ = ''"
	cQuery += "		 GROUP BY GWF.GWF_FILIAL, GWF.GWF_NROCO"
	cQuery += "	  ) VAL ON VAL.GWF_FILIAL = GWD.GWD_FILIAL"
	cQuery += "	       AND VAL.GWF_NROCO  = GWD.GWD_NROCO"
	cQuery += "	 WHERE GWD.D_E_L_E_T_  = ''"
	cQuery += "	   AND GWD.GWD_FILIAL >= '"+cFilialDe+"'"
	cQuery += "	   AND GWD.GWD_FILIAL <= '"+cFilialAte+"'"
	cQuery += "	   AND GWD.GWD_DTOCOR >= '"+DtoS(dDataDe)+"'"
	cQuery += "   	   AND GWD.GWD_DTOCOR <= '"+DtoS(dDataAte)+"'"
	
	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	If (cTmp)->(Recno()) > 0
		While (cTmp)->(!Eof())
			RecLock(cAliasOco,.T.)
			(cAliasOco)->GWD_FILIAL  := (cTmp)->GWD_FILIAL
			(cAliasOco)->GWD_NROCO   := (cTmp)->GWD_NROCO
			(cAliasOco)->GWD_DSOCOR  := (cTmp)->GWD_DSOCOR
			(cAliasOco)->VAL_OCO     := (cTmp)->VAL_OCO
			(cAliasOco)->GWD_CDTIPO  := (cTmp)->GWD_CDTIPO
			(cAliasOco)->GU5_DESC    := Posicione("GU5",1,xFilial("GU5")+(cTmp)->GWD_CDTIPO,"GU5_DESC")
			(cAliasOco)->GWD_CDMOT   := (cTmp)->GWD_CDMOT
			(cAliasOco)->GU6_DESC    := Posicione("GU6",1,xFilial("GU6")+(cTmp)->GWD_CDMOT,"GU6_DESC")
			(cAliasOco)->GWD_DTOCOR  := StoD((cTmp)->GWD_DTOCOR)
			(cAliasOco)->GWD_HROCOR  := (cTmp)->GWD_HROCOR
			(cAliasOco)->GWD_DTCRIA  := StoD((cTmp)->GWD_DTCRIA)
			(cAliasOco)->GWD_HRCRIA  := (cTmp)->GWD_HRCRIA
			(cAliasOco)->GWD_DTBAI   := StoD((cTmp)->GWD_DTBAI)
			(cAliasOco)->GWD_HRBAI   := (cTmp)->GWD_HRBAI
			(cAliasOco)->GWD_SIT	 	:= aSits[Val((cTmp)->GWD_SIT)]
			(cAliasOco)->GWD_NRMOV   := (cTmp)->GWD_NRMOV
			(cAliasOco)->GWD_CDPTCT  := (cTmp)->GWD_CDPTCT
			(cAliasOco)->GWD_CDTRP   := (cTmp)->GWD_CDTRP
			(cAliasOco)->GU3_NMEMIT  := Posicione("GU3",1,xFilial("GU3")+(cTmp)->GWD_CDTRP,"GU3_NMEMIT")
			MsUnlock()
			
			(cTmp)->(dbSkip())
		EndDo
	EndIf
	
	(cTmp)->(dbCloseArea())
Return Nil
