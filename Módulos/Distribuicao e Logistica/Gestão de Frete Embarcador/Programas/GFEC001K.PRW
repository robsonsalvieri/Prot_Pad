#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEC001K
Painel Gerencial de Transportadores - Informações sobre Despesa de Transporte
Utilizado apenas para quando o transportador é pessoa JURIDICA.
Transportadores autonomos, consultar o programa GFEC001N

Uso Restrito.

Param:
aParam[1] := Filial de
aParam[2] := Filial ate
aParam[3] := Data de
aParam[4] := Data ate
aParam[5] := Codigo do Emitente     

@sample
GFEC001K(aParam)

@author Alan Victor Lamb
@since 12/06/13
@version 1.0
--------------------------------------------------------------------------------------------------/*/  
Function GFEC001K(aParam)
	Local aCoors  := FWGetDialogSize(oMainWnd)
	Local cTitulo := 'Painel Gerencial - Transportador'     
	Local oPnl
	
	Private oBrowseCal, oBrowseDoc, oBrowseCar, oBrowseEst
	Private aGrfTpc, aGrfCom, aGrfTPDF, aGrfCTDF, aGrfDCTo, aGrfDCNo, aGrfIRT, aGrfIRN, aGrfIPT, aGrfIPN, aGrfNeg
	Private oGrfTpc, oGrfCom, oGrfTPDF, oGrfCTDF, oGrfDCTo, oGrfDCNo, oGrfImp, oGrfNeg
	Private aStatPre, aStatRea
	Private oBrowsePre, oBrowseRea
	Private aFiltrosFP, aFiltrosFR, aFiltrosPR
	Private cFilialDe  := aParam[1]
	Private cFilialAte := aParam[2]
	Private dDataDe  := If(Empty(aParam[3]),DDATABASE -30 ,aParam[3])
	Private dDataAte := If(Empty(aParam[4]),DDATABASE     ,aParam[4])                   
	Private cCodEmit := aParam[5]
	Private oFolder
	Private cAliasGW1
	
	aFiltrosFP := {{"GWF","GWF_TRANSP","=" ,cCodEmit},;
				   {"GWF","GWF_FILIAL",">=",cFilialDe},;
				   {"GWF","GWF_FILIAL","<=",cFilialAte},;   
				   {"GWF","GWF_DTCRIA",">=",DtoS(dDataDe)},;
				   {"GWF","GWF_DTCRIA","<=",DtoS(dDataAte)}}
	
	aFiltrosFR := {{"GW3","GW3_EMISDF","=" ,cCodEmit},;
				   {"GW3","GW3_FILIAL",">=",cFilialDe},;
				   {"GW3","GW3_FILIAL","<=",cFilialAte},;   
				   {"GW3","GW3_DTENT",">=",DtoS(dDataDe)},;
				   {"GW3","GW3_DTENT","<=",DtoS(dDataAte)}}
	
	aFiltrosPR := {{"GWU","GWU_CDTRP","=" ,cCodEmit},;
				   {"GW1","GW1_FILIAL",">=",cFilialDe},;
				   {"GW1","GW1_FILIAL","<=",cFilialAte},;   
				   {"GW1","GW1_DTEMIS",">=",DtoS(dDataDe)},;
				   {"GW1","GW1_DTEMIS","<=",DtoS(dDataAte)}}
	
	Define MsDialog oDLG Title cTitulo From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
	oDLG:Activate(,,,.T.,,,{||RptStatus({||Iniciar()},"Aguarde", "Realizando consultas de dados")})
	
	GFEDelTab(cAliasGW1)
Return 

Static Function Iniciar()
	Local cBrowseFiltro
	Local oPnl,oFolderEst,oFolderGrf,oPnlGrf
	Local oFWLayer, oWIN_TOP, oWIN_LEFT, oWIN_RIGHT, oWIN_MIDDLE
	Local aColFrtCal, aColFrtPre, aColunas, aColValCalc
	Local nCount := 0
	Local oData
	Local aFieldsGW1
	
	SetRegua(4)
	
	CarregaFP(aFiltrosFP)
	CarregaFR(aFiltrosFR)
	CarregaPR(aFiltrosPR)
	
	IncRegua()
	
	oFolder :=  tFolder():New(30,0,{"Cálculos de frete","Documentos de frete", "Previsto x Realizado"},{"G1","G2","G3"},oDLG,)
	oFolder:Align := CONTROL_ALIGN_ALLCLIENT
	
	//
	// Aba Frete Previsto
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
  	
    oWIN_TOP   := oFWLayer:GetColPanel('COL_TOP','LINE_TOP')
    oWIN_LEFT  := oFWLayer:GetWinPanel('COL_LEFT','WIN_LEFT','LINE_MIDDLE')
    oWIN_RIGHT := oFWLayer:GetWinPanel('COL_RIGHT','WIN_RIGHT','LINE_MIDDLE')
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
	oBrowseCal:BVLDEXECFILTER := {|aParam| GFEC001KCF(aParam)}
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
    // Aba Frete Realizado
    //
    
    cBrowseFiltro := "GW3_EMISDF == '" + cCodEmit        + "' .AND. "
	cBrowseFiltro += "GW3_FILIAL >= '" + cFilialDe      + "'  .AND. GW3_FILIAL <= '" + cFilialAte     + "' .AND. "  
	cBrowseFiltro += "GW3_DTENT  >= '" + DtoS(dDataDe) + "'  .AND. GW3_DTENT <= '" + DtoS(dDataAte) + "'"
	
    oPnl := tPanel():New(30,0,,oFolder:aDialogs[2],,,,,,)
	oPnl:Align := CONTROL_ALIGN_ALLCLIENT
	
    oFWLayer := FWLayer():New()
	oFWLayer:Init(oPnl,.F.)
	oFWLayer:AddLine('LINE_TOP',50,.F.)
	oFWLayer:AddLine('LINE_MIDDLE',50,.F.)
	oFWLayer:AddCollumn('COL_TOP',100,.T.,'LINE_TOP')
	oFWLayer:AddCollumn('COL_LEFT',50,.T.,'LINE_MIDDLE')
	oFWLayer:AddCollumn('COL_RIGHT',50,.T.,'LINE_MIDDLE')
    oFWLayer:AddWindow('COL_LEFT','WIN_LEFT','Tipo de Documento de Frete',100,.F.,.F.,,'LINE_MIDDLE',)
  	oFWLayer:AddWindow('COL_RIGHT','WIN_RIGHT','Categoria de Valor de Frete',100,.F.,.F.,,'LINE_MIDDLE',)
  	
    oWIN_TOP   := oFWLayer:GetColPanel('COL_TOP','LINE_TOP')
    oWIN_LEFT  := oFWLayer:GetWinPanel('COL_LEFT','WIN_LEFT','LINE_MIDDLE')
    oWIN_RIGHT := oFWLayer:GetWinPanel('COL_RIGHT','WIN_RIGHT','LINE_MIDDLE')
	
	//
	// Documentos de frete
	//
	oBrowseDoc:= FWMBrowse():New()
	oBrowseDoc:SetOwner(oWIN_TOP)
	oBrowseDoc:SetAlias('GW3')
	oBrowseDoc:SetDescription("Documentos de frete")
	oBrowseDoc:SetLocate()
	oBrowseDoc:SetAmbiente(.F.)
	oBrowseDoc:SetWalkthru(.F.)
	oBrowseDoc:DisableDetails()
	oBrowseDoc:SetMenuDef("")
	oBrowseDoc:AddButton("Visualizar","VIEWDEF.GFEC065",,2)
	oBrowseDoc:ForceQuitButton(.T.)
	oBrowseDoc:SetProfileID("2")
	oBrowseDoc:SetFilterDefault(cBrowseFiltro)
	oBrowseDoc:BVLDEXECFILTER := {|aParam| GFEC001KDF(aParam)}
	oBrowseDoc:Activate()
	
	//
	// Valor de Frete por Tipo de Doc Frete
	// 
   	GFEC001GRC("oGrfTPDF", "Valor por tipo de Doc Frete", oWIN_LEFT, aGrfTPDF, "@E 999,999,999.99")
	
	//
	// Valor de Frete por Categoria de Valor de Frete
	//
	GFEC001GRC("oGrfCTDF", "Valor por Categoria", oWIN_RIGHT, aGrfCTDF, "@E 999,999,999.99")
    
    IncRegua()
    
    //
    // Aba Previsto x Realizado
    //
	
	oPnl := tPanel():New(30,0,,oFolder:aDialogs[3],,,,,,)
	oPnl:Align := CONTROL_ALIGN_ALLCLIENT
	
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oPnl,.F.)
	oFWLayer:AddLine('LINE_TOP',50,.F.)
	oFWLayer:AddLine('LINE_MIDDLE',50,.F.)
	oFWLayer:AddCollumn('COL_TOP',100,.T.,'LINE_TOP')
	oFWLayer:AddCollumn('COL_LEFT',33,.T.,'LINE_MIDDLE')
	oFWLayer:AddCollumn('COL_MIDDLE',34,.T.,'LINE_MIDDLE')
	oFWLayer:AddCollumn('COL_RIGHT',33,.T.,'LINE_MIDDLE')
	oFWLayer:AddWindow('COL_LEFT','WIN_LEFT','Estatísticas',100,.F.,.F.,,'LINE_MIDDLE',)
    oFWLayer:AddWindow('COL_MIDDLE','WIN_MIDDLE','Previsto x Realizado',100,.F.,.F.,,'LINE_MIDDLE',)
  	oFWLayer:AddWindow('COL_RIGHT','WIN_RIGHT','',100,.F.,.F.,,'LINE_MIDDLE',)
  	
    oWIN_TOP    := oFWLayer:GetColPanel('COL_TOP','LINE_TOP')
    oWIN_LEFT   := oFWLayer:GetWinPanel('COL_LEFT','WIN_LEFT','LINE_MIDDLE')
    oWIN_MIDDLE := oFWLayer:GetWinPanel('COL_MIDDLE','WIN_MIDDLE','LINE_MIDDLE')
    oWIN_RIGHT  := oFWLayer:GetWinPanel('COL_RIGHT','WIN_RIGHT','LINE_MIDDLE')
    
    //Campos calculados do Browse Doc Carga
//    aColFrtCal  := {"Frt Calculado", {||CalcFrtTip("1")}, "N","@E 999,999,999.99",2,15,2,.F.}
//    aColFrtPre  := {"Frt Realizado", {||CalcFrtTip("2")}, "N","@E 999,999,999.99",2,15,2,.F.}
//    aColunas    := {aColFrtCal, aColFrtPre}
//    
 
    aColFrtCal  := {"Frt Calculado", {||CalcFrtTip("1")}, "N",15,2,"@E 999,999,999.99",2,15}
    aColFrtPre  := {"Frt Realizado", {||CalcFrtTip("2")}, "N",15,2,"@E 999,999,999.99",2,15}
    
    aFieldsGW1 := ;
	{{"Filial"	     ,"GW1_FILIAL","C",TamSX3("GW1_FILIAL")[1],0,"",1,TamSX3("GW1_FILIAL")[1]},;
	{"Tp Doc"	   	 ,"GW1_CDTPDC","C",TamSX3("GW1_CDTPDC")[1],0,"",1,10},;
	{"Emissor"      ,"GW1_EMISDC","C",TamSX3("GW1_EMISDC")[1],0,"",1,10},;
	{"Série",		"GW1_SERDC",	"C",TamSX3("GW1_SERDC")[1],	0,"!!!",1,10},;
	{"Número"       ,"GW1_NRDC"  ,"C",TamSX3("GW1_NRDC")[1]  ,0,"",1,10},;
	{"Dt Emissão"  ,"GW1_DTEMIS","D",8,0,"",1,10},;
	{"Remetente"   ,"GW1_CDREM" ,"C",TamSX3("GW1_CDREM")[1] ,0,"",1,10},;
	{"Destinatário","GW1_CDDEST","C",TamSX3("GW1_CDDEST")[1],0,"",1,10},;
	{"Tipo Frete"  ,"GW1_TPFRET","C",20,0,"",1,10},;
	{"Nr Romaneio" ,"GW1_NRROM" ,"C",TamSX3("GW1_NRROM")[1] ,0,"",1,10},;
	{"Seq Trecho"  ,"GWU_SEQ" 	,"C",TamSX3("GWU_SEQ")[1]   ,0,"",1,10}}
	
    cAliasGW1 := CriaTab()
    
    //
	// Documentos de carga
	//
	/*
	oBrowseCar:AddFilter("Somente documentos com Previsto e Realizado", "GFEC001REL()")
	*/
	
	oBrowseCar:= FWMBrowse():New() 
	oBrowseCar:SetOwner(oWIN_TOP)  
	oBrowseCar:SetDescription("Documentos de Carga")
	oBrowseCar:SetAlias(cAliasGW1)
	oBrowseCar:SetLocate()
	oBrowseCar:DisableDetails()
	oBrowseCar:DisableConfig()
	oBrowseCar:SetAmbiente(.F.)
	oBrowseCar:SetWalkthru(.F.)
	oBrowseCar:SetProfileID("1") 
	oBrowseCar:SetMenuDef("")
	oBrowseCar:AddButton("Sair",{|| oDLG:End()},,1)
	oBrowseCar:AddButton("Visualizar",{|| VisualGW1() },,2)
	
	For nCount := 1 To Len(aFieldsGW1)
		If nCount == Len(aFieldsGW1)
			oBrowseCar:AddColumn({aColFrtCal[1], aColFrtCal[2], aColFrtCal[3], aColFrtCal[6],;
								     aColFrtCal[7], aColFrtCal[8], aColFrtCal[5],;
								     .F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}})
			
			oBrowseCar:AddColumn({aColFrtPre[1],aColFrtPre[2],aColFrtPre[3],aColFrtPre[6],;
								     aColFrtPre[7],aColFrtPre[8],aColFrtPre[5],;
								     .F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}})
		EndIf
		
		oBrowseCar:AddColumn({aFieldsGW1[nCount][1],;
							     &("{|| (cAliasGW1)->" + aFieldsGW1[nCount][2] + "}"),;
							     aFieldsGW1[nCount][3],;
							     aFieldsGW1[nCount][6],;
							     aFieldsGW1[nCount][7],;
							     aFieldsGW1[nCount][8],;
							     aFieldsGW1[nCount][5],;
							     .F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}})						     
	Next nCount
	
	oBrowseCar:Activate()
	
	//
	// Estatísticas
	//
	oFolderEst :=  tFolder():New(30,0,{"Frete Previsto","Frete Realizado"},{"G1","G2"},oWIN_LEFT,)
	oFolderEst:Align := CONTROL_ALIGN_ALLCLIENT
	
	oBrowsePre := FWBrowse():New()
	oBrowsePre:SetOwner(oFolderEst:aDialogs[1])
	oBrowsePre:SetDescription("Dados")
	oBrowsePre:SetDataArray()
	oBrowsePre:DisableFilter()
	oBrowsePre:DisableConfig()
	oBrowsePre:SetColumns(GFEC001COL("Descrição",1,,,20,"oBrowsePre"))
	oBrowsePre:SetColumns(GFEC001COL("Valor",2,,2,14,"oBrowsePre"))
	oBrowsePre:SetArray(aStatPre)
	oBrowsePre:Activate()
	
	oBrowseRea := FWBrowse():New()
	oBrowseRea:SetOwner(oFolderEst:aDialogs[2])
	oBrowseRea:SetDescription("Dados")
	oBrowseRea:SetDataArray()
	oBrowseRea:DisableFilter()
	oBrowseRea:DisableConfig()
	oBrowseRea:SetColumns(GFEC001COL("Descrição",1,,,20,"oBrowseRea"))
	oBrowseRea:SetColumns(GFEC001COL("Valor",2,,2,14,"oBrowseRea"))
	oBrowseRea:SetArray(aStatRea)
	oBrowseRea:Activate()
	
	//
	// Folder Gráficos de valor de frete total e normal (Previsto x Realizado)
	// 
	// Últimos parametros do folder: Consultar chamado TFKSA9 
	oFolderGrf := TFolder():New( 0,0,{"Total","Normal"},,oWIN_MIDDLE,,,,.T.,,(oWIN_MIDDLE:nwidth/2),(oWIN_MIDDLE:nHeight/2))
	oFolderGrf:Align := CONTROL_ALIGN_ALLCLIENT
	oFolderGrf:bSetOption := {|nOption|AtuFolder(nOption)} // Atualiza o gráfico de impostos ao mudar aba
	
	//
	// Gráfico com a soma total do valor de frete
	//
	GFEC001GRC("oGrfDCTo","Valor de Frete Total",oFolderGrf:aDialogs[1],aGrfDCTo,"@E 999,999,999.99",{|nSerie| AtuImpostos(nSerie,"T")},BARCHART)
	
	// 
	// Gráfico com a soma do frete normal GWD_TPDF/GWF_TPCALC 1 e 6
	//
	GFEC001GRC("oGrfDCNo","Valor de Frete Normal",oFolderGrf:aDialogs[2],aGrfDCNo,"@E 999,999,999.99",{|nSerie| AtuImpostos(nSerie,"N")},BARCHART)
	
    //
    // Gráfico impostos
    //
    GFEC001GRC("oGrfImp", "Impostos Frete Previsto Total", oWIN_RIGHT, aGrfIPT, "@E 999,999,999.99")
    
    IncRegua()
Return Nil

Static Function VisualGW1()
	dbSelectArea("GW1")
	GW1->(dbSetOrder(1))
	If GW1->(dbSeek((cAliasGW1)->(GW1_FILIAL+GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC)))
		FWExecView("Visualizar", "GFEC040", 1,, {||.T.})
	EndIf 
Return Nil

Static Function AtuFolder(nOption)
	If nOption == 1
		AtuImpostos(1, "T")
	ElseIf nOption == 2
		AtuImpostos(1, "N")
	EndIf
Return Nil

Static Function AtuImpostos(nSerie, cTipo)
	Local aDados := {}
	Local cTitulo
	
	If nSerie == 2
		aDados := If(cTipo=="T",aGrfIRT,aGrfIRN)
		cTitulo := "Impostos Frete Realizado " + If(cTipo=="T","Total","Normal")
	Else
		aDados := If(cTipo=="T",aGrfIPT,aGrfIPN)
		cTitulo := "Impostos Frete Previsto " + If(cTipo=="T","Total","Normal")
	EndIf
	
	GFEC001GRA(oGrfImp,.T.,aDados,cTitulo)
Return Nil

//
// Faz cálculo do valor de frete para um registro da GWF
//
Function GFEC001VLF()
	Local nTotal := 0
	Local aAreaGWF := GWF->(GetArea())
	
	dbSelectArea("GWI")
	GWI->(dbSetOrder(1))
	If GWI->(dbSeek(GWF->GWF_FILIAL+GWF->GWF_NRCALC))
		While GWI->(!Eof()) .And. GWI->GWI_FILIAL == GWF->GWF_FILIAL .And. GWI->GWI_NRCALC == GWF->GWF_NRCALC
			If GWI->GWI_TOTFRE == "1"
				nTotal += GWI->GWI_VLFRET
			Endif
			GWI->(dbSkip())
		EndDo
	EndIf
	
	nTotal += GWF->GWF_VLAJUS
	
	RestArea(aAreaGWF)
Return nTotal

//
// Calcula o valor total de frete por Tipo de Documento
//
Static Function CalcFrtTip(cTpDoc)
	Local nRet      := 0
	//Local aAreaGW1 := GW1->(GetArea())
	Local aAreaGW1 := (cAliasGW1)->(GetArea())
	Local aAreaGWM
	
	dbSelectArea("GWM")
	aAreaGWM := GWM->(GetArea())
	GWM->(dbSetOrder(2))
	
	If GWM->(dbSeek((cAliasGW1)->(GW1_FILIAL+GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC)))
		While GWM->(!Eof()) .And. ;
		       GWM->(GWM_FILIAL+GWM_CDTPDC+GWM_EMISDC+GWM_SERDC+GWM_NRDC) == (cAliasGW1)->(GW1_FILIAL+GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC)
		    If GWM->GWM_TPDOC == cTpDoc .And. GWM->GWM_CDTRP == cCodEmit 
				nRet += GWM->GWM_VLFRET
			EndIf
			
			GWM->(dbSkip())
 		EndDo
	EndIf
		
	RestArea(aAreaGWM)
	RestArea(aAreaGW1)
Return nRet

Function GFEC001REL()
	Local lRet      := .F.
	Local aAreaGW1 := GW1->(GetArea())
	Local aAreaGWM
	Local lTpDoc1, lTpDoc2
	
	lTpDoc1 := .F.
	lTpDoc2 := .F.
	
	dbSelectArea("GWM")
	aAreaGWM := GWM->(GetArea())
	GWM->(dbSetOrder(2))
	
	If GWM->(dbSeek(GW1->(GW1_FILIAL+GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC)))
		While GWM->(!Eof()) .And. ;
		       GWM->(GWM_FILIAL+GWM_CDTPDC+GWM_EMISDC+GWM_SERDC+GWM_NRDC) == GW1->(GW1_FILIAL+GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC)
		    
		    If GWM->GWM_TPDOC == "1"
		    	lTpDoc1 := .T.
		    ElseIf GWM->GWM_TPDOC == "2"
		    	lTpDoc2 := .T.
		    EndIf
		    
		    If lTpDoc1 .And. lTpDoc2
		    	lRet := .T.
		    	Exit
		    EndIf
		    
			GWM->(dbSkip())
 		EndDo
	EndIf
		
	RestArea(aAreaGWM)
	RestArea(aAreaGW1)
Return lRet

//
// Carrega os dados de Frete Realizado
//
Static Function CarregaFR(aFiltrosFR, cBrwFiltro)
	Local   cQuery      := ""
	Local   cTmp        := ""
	Default cBrwFiltro := ""
	
	aGrfTPDF := {}
	aGrfCTDF := {}
	
	/*
		Valor por Tipo Doc Frete
	*/
	cQuery += "	 SELECT GW3.GW3_TPDF,"
	cQuery += "	 		CASE"
	cQuery += "	 			WHEN GW3.GW3_TPDF = '1' THEN 'Normal'"
	cQuery += "	 			WHEN GW3.GW3_TPDF = '2' THEN 'Complementar Valor'"
	cQuery += "	 			WHEN GW3.GW3_TPDF = '3' THEN 'Complementar Imposto'"
	cQuery += "	 			WHEN GW3.GW3_TPDF = '4' THEN 'Reentrega'"
	cQuery += "	 			WHEN GW3.GW3_TPDF = '5' THEN 'Devolução'"
	cQuery += "	 			WHEN GW3.GW3_TPDF = '6' THEN 'Redespacho'"
	cQuery += "	 			WHEN GW3.GW3_TPDF = '7' THEN 'Serviço'"
	cQuery += "	 		END DESC_TPDF,"
	cQuery += "	        SUM(GW3.GW3_VLDF) GW3_VLDF"
	cQuery += "	   FROM " + RetSQLName("GW3") + " GW3"
	cQuery += "	  WHERE GW3.D_E_L_E_T_ = ' ' " + cBrwFiltro + CriaQueryCondicao(aFiltrosFR,"")
	cQuery += "	  GROUP BY GW3.GW3_TPDF"
	
	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	
	If (cTmp)->(Recno()) > 0
		While (cTmp)->(!Eof())
			aAdd(aGrfTPDF, {(cTmp)->DESC_TPDF, (cTmp)->GW3_VLDF})
			(cTmp)->(dbSkip())
		EndDo
	EndIf
	
	(cTmp)->(dbCloseArea())
	
	/*
		Valor por Categoria de Valor de Frete
	*/
	cQuery := ""
	cQuery += "	 SELECT SUM(GW3.GW3_PEDAG) GW3_PEDAG,"
	cQuery += "	 		SUM(GW3.GW3_TAXAS) GW3_TAXAS,"
	cQuery += "	 		SUM(GW3.GW3_FRPESO) GW3_FRPESO,"
	cQuery += "	 		SUM(GW3.GW3_FRVAL) GW3_FRVAL"
	cQuery += "	   FROM " + RetSQLName("GW3") + " GW3"
	cQuery += "	  WHERE GW3.D_E_L_E_T_ = ' '" + cBrwFiltro + CriaQueryCondicao(aFiltrosFR,"")
	
	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	
	If (cTmp)->(Recno()) > 0
		aAdd(aGrfCTDF, {"Pedágio", (cTmp)->GW3_PEDAG})
		aAdd(aGrfCTDF, {"Taxas", (cTmp)->GW3_TAXAS})
		aAdd(aGrfCTDF, {"Frete Peso", (cTmp)->GW3_FRPESO})
		aAdd(aGrfCTDF, {"Frete Valor", (cTmp)->GW3_FRVAL})
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
	cQuery += "SELECT SUM(CASE WHEN GWF_TPCALC = '1' THEN GWI_VLFRET + GWF_VLAJUS ELSE 0 END) VAL_TP1,"
	cQuery += "	   	  SUM(CASE WHEN GWF_TPCALC = '2' THEN GWI_VLFRET + GWF_VLAJUS ELSE 0 END) VAL_TP2,"
	cQuery += "	      SUM(CASE WHEN GWF_TPCALC = '3' THEN GWI_VLFRET + GWF_VLAJUS ELSE 0 END) VAL_TP3,"
	cQuery += "	      SUM(CASE WHEN GWF_TPCALC = '4' THEN GWI_VLFRET + GWF_VLAJUS ELSE 0 END) VAL_TP4,"
	cQuery += "	      SUM(CASE WHEN GWF_TPCALC = '5' THEN GWI_VLFRET + GWF_VLAJUS ELSE 0 END) VAL_TP5,"
	cQuery += "	      SUM(CASE WHEN GWF_TPCALC = '6' THEN GWI_VLFRET + GWF_VLAJUS ELSE 0 END) VAL_TP6,"
	cQuery += "	      SUM(CASE WHEN GWF_TPCALC = '7' THEN GWI_VLFRET + GWF_VLAJUS ELSE 0 END) VAL_TP7,"
	cQuery += "		  SUM(CASE WHEN GWF_ORIGEM = '1' THEN GWI_VLFRET + GWF_VLAJUS ELSE 0 END) TABELADO, "
	cQuery += "	      SUM(CASE WHEN GWF_ORIGEM = '2' THEN GWI_VLFRET + GWF_VLAJUS ELSE 0 END) COMBINADO "
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

//
// Carrega dados Previsto x Realizado
//
Static Function CarregaPR(aFiltrosPR,cBrwFiltro,lRelac)
	Local   cQuery      := ""
	Local   cTmp        := ""
	Local   nReaNor, nReaTot, nPreNor, nPreTot
	Default cBrwFiltro := ""
	
	aGrfDCTo := {}
	aGrfDCNo := {}
	aStatPre := {}
	aStatRea := {}
	aGrfIRT  := {}
	aGrfIRN  := {}
	aGrfIPT  := {}
	aGrfIPN  := {}
	
	nReaNor := 0
	nReaTot := 0
	nPreNor := 0
	nPreTot := 0
	
	//
	// Valor de frete por Tipo Doc e TPDF/TPDOC
	//
	cQuery += "	SELECT GWM_TPDOC, "
	cQuery += "		   SUM(GWM_TOT.GWM_VLFRET) TOTAL, "
	cQuery += "		   SUM(CASE "
	cQuery += "		         WHEN (GWM_TPDOC = '1' AND GWF_TPCALC IN ('1','2','3','6')) OR "
	cQuery += "		              (GWM_TPDOC = '2' AND GW3_TPDF IN ('1','2','3','6'))  "
	cQuery += "		         THEN GWM_TOT.GWM_VLFRET "
	cQuery += "		       END) DESPACHOS, "
	cQuery += "		   SUM(CASE "
	cQuery += "		         WHEN (GWM_TPDOC = '1' AND GWF_TPCALC = '4') OR "
	cQuery += "		              (GWM_TPDOC = '2' AND GW3_TPDF = '4') "
	cQuery += "		         THEN GWM_TOT.GWM_VLFRET  "
	cQuery += "		       END) REENTREGAS, "
	cQuery += "		   SUM(CASE "
	cQuery += "		         WHEN (GWM_TPDOC = '1' AND GWF_TPCALC = '5') OR "
	cQuery += "		              (GWM_TPDOC = '2' AND GW3_TPDF = '5') "
	cQuery += "		         THEN GWM_TOT.GWM_VLFRET  "
	cQuery += "		       END) DEVOLUCOES, "
	cQuery += "		   SUM(CASE "
	cQuery += "		         WHEN (GWM_TPDOC = '1' AND GWF_TPCALC = '7') OR "
	cQuery += "		              (GWM_TPDOC = '2' AND GW3_TPDF = '7') " 
	cQuery += "		         THEN GWM_TOT.GWM_VLFRET "
	cQuery += "		       END) SERVICOS, "
	cQuery += "		   SUM(GWM_TOT.GWM_VLISS) TISS, "
	cQuery += "		   SUM(CASE WHEN (GWM_TPDOC = '1' AND GWF_TPCALC IN ('1','2','3','6')) OR "
	cQuery += "		                 (GWM_TPDOC = '2' AND GW3_TPDF IN ('1','2','3','6')) "
	cQuery += "		            THEN GWM_TOT.GWM_VLISS END) NISS, "
	cQuery += "		   SUM(CASE WHEN (GWM_TPDOC = '1' AND GWF_CRDICM = '1') OR "
	cQuery += "		                 (GWM_TPDOC = '2' AND GW3_CRDICM = '1') "
	cQuery += "		            THEN GWM_TOT.GWM_VLICMS END) TICMS_REC, "
	cQuery += "		   SUM(CASE WHEN (GWM_TPDOC = '1' AND GWF_CRDICM = '1' AND GWF_TPCALC IN ('1','2','3','6')) OR "
	cQuery += "		                 (GWM_TPDOC = '2' AND GW3_CRDICM = '1' AND GW3_TPDF IN ('1','2','3','6')) "
	cQuery += "		            THEN GWM_TOT.GWM_VLICMS END) NICMS_REC, "
	cQuery += "		   SUM(CASE WHEN (GWM_TPDOC = '1' AND GWF_CRDICM = '2') OR "
	cQuery += "		                 (GWM_TPDOC = '2' AND GW3_CRDICM = '2') "
	cQuery += "		            THEN GWM_TOT.GWM_VLICMS END) TICMS_NREC, "  
	cQuery += "		   SUM(CASE WHEN (GWM_TPDOC = '1' AND GWF_CRDICM = '2' AND GWF_TPCALC IN ('1','2','3','6')) OR "
	cQuery += "		                 (GWM_TPDOC = '2' AND GW3_CRDICM = '2' AND GW3_TPDF IN ('1','2','3','6')) "
	cQuery += "		            THEN GWM_TOT.GWM_VLICMS END) NICMS_NREC, "
	cQuery += "		   SUM(CASE WHEN (GWM_TPDOC = '1' AND GWF_CRDPC = '1') OR "
	cQuery += "		                 (GWM_TPDOC = '2' AND GW3_CRDPC = '1') "
	cQuery += "		            THEN GWM_TOT.GWM_VLPIS END) TPIS_REC, "
	cQuery += "		   SUM(CASE WHEN (GWM_TPDOC = '1' AND GWF_CRDPC = '1' AND GWF_TPCALC IN ('1','2','3','6')) OR "
	cQuery += "		                 (GWM_TPDOC = '2' AND GW3_CRDPC = '1' AND GW3_TPDF IN ('1','2','3','6')) "
	cQuery += "		            THEN GWM_TOT.GWM_VLPIS END) NPIS_REC, "
	cQuery += "		   SUM(CASE WHEN (GWM_TPDOC = '1' AND GWF_CRDPC = '2') OR "
	cQuery += "		                 (GWM_TPDOC = '2' AND GW3_CRDPC = '2') "
	cQuery += "		            THEN GWM_TOT.GWM_VLPIS END) TPIS_NREC, "
	cQuery += "		   SUM(CASE WHEN (GWM_TPDOC = '1' AND GWF_CRDPC = '2' AND GWF_TPCALC IN ('1','2','3','6')) OR "
	cQuery += "		                 (GWM_TPDOC = '2' AND GW3_CRDPC = '2' AND GW3_TPDF IN ('1','2','3','6')) "
	cQuery += "		            THEN GWM_TOT.GWM_VLPIS END) NPIS_NREC, " 
	cQuery += "		   SUM(CASE WHEN (GWM_TPDOC = '1' AND GWF_CRDPC = '1') OR "
	cQuery += "		                 (GWM_TPDOC = '2' AND GW3_CRDPC = '1') "
	cQuery += "		            THEN GWM_TOT.GWM_VLCOFI END) TCOFI_REC, "
	cQuery += "		   SUM(CASE WHEN (GWM_TPDOC = '1' AND GWF_CRDPC = '1' AND GWF_TPCALC IN ('1','2','3','6')) OR "
	cQuery += "		                 (GWM_TPDOC = '2' AND GW3_CRDPC = '1' AND GW3_TPDF IN ('1','2','3','6')) "
	cQuery += "		            THEN GWM_TOT.GWM_VLCOFI END) NCOFI_REC, "
	cQuery += "		   SUM(CASE WHEN (GWM_TPDOC = '1' AND GWF_CRDPC = '2') OR  "
	cQuery += "		                 (GWM_TPDOC = '2' AND GW3_CRDPC = '2') "
	cQuery += "		            THEN GWM_TOT.GWM_VLCOFI END) TCOFI_NREC, "
	cQuery += "		   SUM(CASE WHEN (GWM_TPDOC = '1' AND GWF_CRDPC = '2' AND GWF_TPCALC IN ('1','2','3','6')) OR "
	cQuery += "		                 (GWM_TPDOC = '2' AND GW3_CRDPC = '2' AND GW3_TPDF IN ('1','2','3','6')) "
	cQuery += "		            THEN GWM_TOT.GWM_VLCOFI END) NCOFI_NREC "
	cQuery += "	  FROM " + RetSQLName("GW1") + " GW1 "
	cQuery += "	  INNER JOIN (SELECT DISTINCT GWU_FILIAL,GWU_CDTPDC,GWU_EMISDC,GWU_SERDC,GWU_NRDC,GWU_CDTRP "
	cQuery += "	 			   FROM " + RetSQLName("GWU") + " "
	cQuery += "	 			  WHERE D_E_L_E_T_ = ' ' AND GWU_PAGAR = '1') GWU ON GWU.GWU_FILIAL = GW1.GW1_FILIAL "
	cQuery += "	 			                              AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC "
	cQuery += "	 			                              AND GWU.GWU_EMISDC = GW1.GW1_EMISDC "
	cQuery += "	 			                              AND GWU.GWU_SERDC  = GW1.GW1_SERDC "
	cQuery += "	 			                              AND GWU.GWU_NRDC   = GW1.GW1_NRDC "
	cQuery += "	  LEFT JOIN (SELECT GWM_TPDOC, GWM_CDTRP, GWM_FILIAL, GWM_CDTPDC, GWM_EMISDC, GWM_SERDC, GWM_NRDC, GWM_NRDOC, GWM_SERDOC, GWM_DTEMIS, GWM_CDESP, SUM(GWM_VLFRET) GWM_VLFRET, SUM(GWM_VLISS) GWM_VLISS, SUM(GWM_VLICMS) GWM_VLICMS, SUM(GWM_VLPIS) GWM_VLPIS, SUM(GWM_VLCOFI) GWM_VLCOFI "
	cQuery += "	               FROM " + RetSQLName("GWM") + " GWM "
	cQuery += "	              WHERE GWM.D_E_L_E_T_ = ' ' "
	cQuery += "	              GROUP BY GWM_SERDOC, GWM_DTEMIS, GWM_CDESP, GWM_TPDOC, GWM_CDTRP, GWM_FILIAL, GWM_CDTPDC, GWM_EMISDC, GWM_SERDC, GWM_NRDC, GWM_NRDOC) GWM_TOT ON GWM_TOT.GWM_FILIAL = GW1.GW1_FILIAL "
	cQuery += "                         AND GWM_TOT.GWM_CDTPDC = GW1.GW1_CDTPDC "
	cQuery += "                         AND GWM_TOT.GWM_EMISDC = GW1.GW1_EMISDC "
	cQuery += "                         AND GWM_TOT.GWM_SERDC  = GW1.GW1_SERDC "
	cQuery += "                         AND GWM_TOT.GWM_NRDC   = GW1.GW1_NRDC "
	cQuery += "      LEFT JOIN " + RetSQLName("GWF") + " GWF ON GWF.GWF_FILIAL = GWM_FILIAL "
	cQuery += "							 AND GWF.GWF_NRCALC = GWM_NRDOC "
	cQuery += "                          AND GWF.D_E_L_E_T_ = ' ' "
	cQuery += "      LEFT JOIN " + RetSQLName("GW3") + " GW3 ON GW3.GW3_FILIAL = GWM_FILIAL "
	cQuery += "                  		  AND GW3.GW3_NRDF   = GWM_NRDOC "
	cQuery += "                  		  AND GW3.GW3_CDESP  = GWM_CDESP "
	cQuery += "                  		  AND GW3.GW3_EMISDF = GWM_CDTRP "
	cQuery += "                  		  AND GW3.GW3_SERDF  = GWM_SERDOC "
	cQuery += "                  		  AND GW3.GW3_DTEMIS = GWM_DTEMIS "
	cQuery += "                  		  AND GW3.D_E_L_E_T_ = ' ' "
	cQuery += "	  LEFT JOIN ( SELECT DISTINCT GWM_FILIAL, GWM_CDTPDC, GWM_EMISDC, GWM_SERDC, GWM_NRDC"
	cQuery += "	               FROM " + RetSQLName("GWM")
	cQuery += "	              WHERE GWM_TPDOC = '1' AND D_E_L_E_T_ = ' ') GWM1 ON GWM1.GWM_FILIAL = GW1.GW1_FILIAL"
	cQuery += "                         AND GWM1.GWM_CDTPDC = GW1.GW1_CDTPDC"
	cQuery += "                         AND GWM1.GWM_EMISDC = GW1.GW1_EMISDC"
	cQuery += "                         AND GWM1.GWM_SERDC  = GW1.GW1_SERDC"
	cQuery += "                         AND GWM1.GWM_NRDC   = GW1.GW1_NRDC"
	cQuery += "      LEFT JOIN ( SELECT DISTINCT GWM_FILIAL, GWM_CDTPDC, GWM_EMISDC, GWM_SERDC, GWM_NRDC"
	cQuery += "	               FROM " + RetSQLName("GWM")
	cQuery += "	              WHERE GWM_TPDOC = '2' AND D_E_L_E_T_ = ' ') GWM2 ON GWM2.GWM_FILIAL = GW1.GW1_FILIAL"
	cQuery += "                         AND GWM2.GWM_CDTPDC = GW1.GW1_CDTPDC"
	cQuery += "                         AND GWM2.GWM_EMISDC = GW1.GW1_EMISDC"
	cQuery += "                         AND GWM2.GWM_SERDC  = GW1.GW1_SERDC"
	cQuery += "                         AND GWM2.GWM_NRDC   = GW1.GW1_NRDC "
	cQuery += "	 WHERE GW1.D_E_L_E_T_ = ' ' " 
	cQuery += "	   AND GWM_TOT.GWM_CDTRP = GWU.GWU_CDTRP " + cBrwFiltro + CriaQueryCondicao(aFiltrosPR,"")
	
	If lRelac
		cQuery += " AND GWM1.GWM_CDTPDC IS NOT NULL "
	    cQuery += " AND GWM2.GWM_CDTPDC IS NOT NULL "
	EndIf
	
	cQuery += "	 GROUP BY GWM_TPDOC"
	
	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	
	If (cTmp)->(Recno()) > 0
		While (cTmp)->(!Eof())
			If (cTmp)->GWM_TPDOC == "1" // Previsto
				// Séries Gráficos Frete Normal / Total
				aAdd(aGrfDCTo, {"Previsto", (cTmp)->TOTAL})
				aAdd(aGrfDCNo, {"Previsto", (cTmp)->DESPACHOS})
				// Estatísticas Previsto
				aAdd(aStatPre, {"Transportador", POSICIONE("GU3", 1, xFilial("GU3")+cCodEmit, "GU3_NMEMIT")})
				aAdd(aStatPre, {"Frete Total", AllTrim(Transform((cTmp)->TOTAL,"@E 99,999,999,999.99"))})
				aAdd(aStatPre, {"ISS do Frete Total", AllTrim(Transform((cTmp)->TISS,"@E 99,999,999,999.99"))})
				aAdd(aStatPre, {"ICMS recuperável do Frete Total", AllTrim(Transform((cTmp)->TICMS_REC,"@E 99,999,999,999.99"))})
				aAdd(aStatPre, {"ICMS não recuperável do Frete Total", AllTrim(Transform((cTmp)->TICMS_NREC,"@E 99,999,999,999.99"))})
				aAdd(aStatPre, {"PIS/COFINS recuperável do Frete Total", AllTrim(Transform((cTmp)->TPIS_REC + (cTmp)->TCOFI_REC,"@E 99,999,999,999.99"))})
				aAdd(aStatPre, {"PIS/COFINS não recuperável do Frete Total", AllTrim(Transform((cTmp)->TPIS_NREC + (cTmp)->TCOFI_NREC,"@E 99,999,999,999.99"))})
				aAdd(aStatPre, {"Frete Normal", AllTrim(Transform((cTmp)->DESPACHOS,"@E 99,999,999,999.99"))})
				aAdd(aStatPre, {"Frete Reentregas", AllTrim(Transform((cTmp)->REENTREGAS,"@E 99,999,999,999.99"))})
				aAdd(aStatPre, {"Frete Devoluções", AllTrim(Transform((cTmp)->DEVOLUCOES,"@E 99,999,999,999.99"))})
				aAdd(aStatPre, {"Serviços", AllTrim(Transform((cTmp)->SERVICOS,"@E 99,999,999,999.99"))})
				
				/* Gráfico pizza - Imposto Frete Total Previsto */
				aAdd(aGrfIPT, {"ISS", (cTmp)->TISS})
				aAdd(aGrfIPT, {"ICMS recuperável", (cTmp)->TICMS_REC})
				aAdd(aGrfIPT, {"ICMS não recuperável", (cTmp)->TICMS_NREC})
				aAdd(aGrfIPT, {"PIS/COFINS recuperável", (cTmp)->TPIS_REC + (cTmp)->TCOFI_REC})
				aAdd(aGrfIPT, {"PIS/COFINS não recuperável", (cTmp)->TPIS_NREC + (cTmp)->TCOFI_NREC})
				aAdd(aGrfIPT, {"Despesa sem impostos", (cTmp)->TOTAL - ;
														    ((cTmp)->TISS + (cTmp)->TICMS_REC + ;
														     (cTmp)->TICMS_NREC + (cTmp)->TPIS_REC +;
														     (cTmp)->TCOFI_REC + (cTmp)->TPIS_NREC +;
														     (cTmp)->TCOFI_NREC)})
				
				/* Gráfico pizza - Imposto Frete Normal Previsto */
				aAdd(aGrfIPN, {"ISS", (cTmp)->NISS})
				aAdd(aGrfIPN, {"ICMS recuperável", (cTmp)->NICMS_REC})
				aAdd(aGrfIPN, {"ICMS não recuperável", (cTmp)->NICMS_NREC})
				aAdd(aGrfIPN, {"PIS/COFINS recuperável", (cTmp)->NPIS_REC + (cTmp)->NCOFI_REC})
				aAdd(aGrfIPN, {"PIS/COFINS não recuperável", (cTmp)->NPIS_NREC + (cTmp)->NCOFI_NREC})
				aAdd(aGrfIPN, {"Despesa sem impostos", (cTmp)->DESPACHOS - ;
														    ((cTmp)->NISS + (cTmp)->NICMS_REC + ;
														     (cTmp)->NICMS_NREC + (cTmp)->NPIS_REC +;
														     (cTmp)->NCOFI_REC + (cTmp)->NPIS_NREC +;
														     (cTmp)->NCOFI_NREC)})
														     
				nPreNor := (cTmp)->DESPACHOS
				nPreTot := (cTmp)->TOTAL
			ElseIf (cTmp)->GWM_TPDOC == "2" // Realizado
				// Séries Gráficos Frete Normal / Total
				aAdd(aGrfDCTo, {"Realizado", (cTmp)->TOTAL})
				aAdd(aGrfDCNo, {"Realizado", (cTmp)->DESPACHOS})
				// Estatísticas Realizado
				aAdd(aStatRea, {"Transportador", POSICIONE("GU3", 1, xFilial("GU3")+cCodEmit, "GU3_NMEMIT")})
				aAdd(aStatRea, {"Frete Total", AllTrim(Transform((cTmp)->TOTAL,"@E 99,999,999,999.99"))})
				aAdd(aStatRea, {"ISS do Frete Total", AllTrim(Transform((cTmp)->TISS,"@E 99,999,999,999.99"))})
				aAdd(aStatRea, {"ICMS recuperável do Frete Total", AllTrim(Transform((cTmp)->TICMS_REC,"@E 99,999,999,999.99"))})
				aAdd(aStatRea, {"ICMS não recuperável do Frete Total", AllTrim(Transform((cTmp)->TICMS_NREC,"@E 99,999,999,999.99"))})
				aAdd(aStatRea, {"PIS/COFINS recuperável do Frete Total", AllTrim(Transform((cTmp)->TPIS_REC + (cTmp)->TCOFI_REC,"@E 99,999,999,999.99"))})
				aAdd(aStatRea, {"PIS/COFINS não recuperável do Frete Total", AllTrim(Transform((cTmp)->TPIS_NREC + (cTmp)->TCOFI_NREC,"@E 99,999,999,999.99"))})
				aAdd(aStatRea, {"Frete Normal", AllTrim(Transform((cTmp)->DESPACHOS,"@E 99,999,999,999.99"))})
				aAdd(aStatRea, {"Frete Reentregas", AllTrim(Transform((cTmp)->REENTREGAS,"@E 99,999,999,999.99"))})
				aAdd(aStatRea, {"Frete Devoluções", AllTrim(Transform((cTmp)->DEVOLUCOES,"@E 99,999,999,999.99"))})
				aAdd(aStatRea, {"Serviços", AllTrim(Transform((cTmp)->SERVICOS,"@E 99,999,999,999.99"))})
				
				/* Gráfico pizza - Imposto Frete Total Previsto */
				aAdd(aGrfIRT, {"ISS", (cTmp)->TISS})
				aAdd(aGrfIRT, {"ICMS recuperável", (cTmp)->TICMS_REC})
				aAdd(aGrfIRT, {"ICMS não recuperável", (cTmp)->TICMS_NREC})
				aAdd(aGrfIRT, {"PIS/COFINS recuperável", (cTmp)->TPIS_REC + (cTmp)->TCOFI_REC})
				aAdd(aGrfIRT, {"PIS/COFINS não recuperável", (cTmp)->TPIS_NREC + (cTmp)->TCOFI_NREC})
				aAdd(aGrfIRT, {"Despesa sem impostos", (cTmp)->TOTAL - ;
														    ((cTmp)->TISS + (cTmp)->TICMS_REC + ;
														     (cTmp)->TICMS_NREC + (cTmp)->TPIS_REC +;
														     (cTmp)->TCOFI_REC + (cTmp)->TPIS_NREC +;
														     (cTmp)->TCOFI_NREC)})
				
				/* Gráfico pizza - Imposto Frete Normal Previsto */
				aAdd(aGrfIRN, {"ISS", (cTmp)->NISS})
				aAdd(aGrfIRN, {"ICMS recuperável", (cTmp)->NICMS_REC})
				aAdd(aGrfIRN, {"ICMS não recuperável", (cTmp)->NICMS_NREC})
				aAdd(aGrfIRN, {"PIS/COFINS recuperável", (cTmp)->NPIS_REC + (cTmp)->NCOFI_REC})
				aAdd(aGrfIRN, {"PIS/COFINS não recuperável", (cTmp)->NPIS_NREC + (cTmp)->NCOFI_NREC})
				aAdd(aGrfIRN, {"Despesa sem impostos", (cTmp)->DESPACHOS - ;
														    ((cTmp)->NISS + (cTmp)->NICMS_REC + ;
														     (cTmp)->NICMS_NREC + (cTmp)->NPIS_REC +;
														     (cTmp)->NCOFI_REC + (cTmp)->NPIS_NREC +;
														     (cTmp)->NCOFI_NREC)})
				
				nReaNor := (cTmp)->DESPACHOS
				nReaTot := (cTmp)->TOTAL
			EndIf
			
			(cTmp)->(dbSkip())
		EndDo
	EndIf
	
	(cTmp)->(dbCloseArea())
	
	cQuery := ""
	cQuery += "	SELECT COUNT(CASE WHEN GWM1.GWM_CDTPDC IS NULL THEN 1 END) SEM_PRV," 
	cQuery += "		    COUNT(CASE WHEN GWM2.GWM_CDTPDC IS NULL THEN 1 END) SEM_REA,"
	cQuery += "			SUM(CASE WHEN GWM1.GWM_CDTPDC IS NOT NULL THEN GW8_VOLUME END) VOL_PRV,"
	cQuery += "			SUM(CASE WHEN GWM2.GWM_CDTPDC IS NOT NULL THEN GW8_VOLUME END) VOL_REA,"
	cQuery += "			SUM(CASE WHEN GWM1.GWM_CDTPDC IS NOT NULL THEN GW8_QTDE END) QTD_PRV,"
	cQuery += "			SUM(CASE WHEN GWM2.GWM_CDTPDC IS NOT NULL THEN GW8_QTDE END) QTD_REA,"
	cQuery += "			SUM(CASE WHEN GWM1.GWM_CDTPDC IS NOT NULL THEN GW8_VALOR END) VAL_PRV,"
	cQuery += "			SUM(CASE WHEN GWM2.GWM_CDTPDC IS NOT NULL THEN GW8_VALOR END) VAL_REA,"
	cQuery += "			SUM(CASE WHEN GWM1.GWM_CDTPDC IS NOT NULL THEN GW8_PESOR END) PES_PRV,"
	cQuery += "			SUM(CASE WHEN GWM2.GWM_CDTPDC IS NOT NULL THEN GW8_PESOR END) PES_REA "
	cQuery += "	  FROM " + RetSQLName("GW1") + " GW1 "
	cQuery += "	 INNER JOIN (SELECT GWU_FILIAL,GWU_CDTPDC,GWU_EMISDC,GWU_SERDC,GWU_NRDC,GWU_CDTRP "
	cQuery += "	 			   FROM " + RetSQLName("GWU")
	cQuery += "	 			  WHERE D_E_L_E_T_ = ' ' AND GWU_PAGAR = '1') GWU ON GWU.GWU_FILIAL = GW1.GW1_FILIAL "
	cQuery += "	 			                              AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC "
	cQuery += "	 			                              AND GWU.GWU_EMISDC = GW1.GW1_EMISDC "
	cQuery += "	 			                              AND GWU.GWU_SERDC  = GW1.GW1_SERDC "
	cQuery += "	 			                              AND GWU.GWU_NRDC   = GW1.GW1_NRDC "
	cQuery += "	 INNER JOIN (SELECT GW8_FILIAL,GW8_CDTPDC,GW8_EMISDC,GW8_SERDC,GW8_NRDC, "
	cQuery += "	                    SUM(GW8_PESOR) GW8_PESOR, "
	cQuery += "	                    SUM(GW8_QTDE) GW8_QTDE, "
	cQuery += "	                    SUM(GW8_VOLUME) GW8_VOLUME, "
	cQuery += "	                    SUM(GW8_VALOR) GW8_VALOR "
	cQuery += "	               FROM " + RetSQLName("GW8")
	cQuery += "	              WHERE D_E_L_E_T_<> '*' "
	cQuery += "	              GROUP BY GW8_FILIAL,GW8_CDTPDC,GW8_EMISDC,GW8_SERDC,GW8_NRDC "
	cQuery += "	              ) GW8 ON GW8.GW8_FILIAL = GW1.GW1_FILIAL "
	cQuery += "                       AND GW8.GW8_CDTPDC = GW1.GW1_CDTPDC "
	cQuery += "                       AND GW8.GW8_EMISDC = GW1.GW1_EMISDC "
	cQuery += "                       AND GW8.GW8_SERDC  = GW1.GW1_SERDC "
	cQuery += "                       AND GW8.GW8_NRDC   = GW1.GW1_NRDC	"
	cQuery += "	  LEFT JOIN ( SELECT DISTINCT GWM_FILIAL, GWM_CDTPDC, GWM_EMISDC, GWM_SERDC, GWM_NRDC "
	cQuery += "	               FROM " + RetSQLName("GWM")
	cQuery += "	              WHERE GWM_TPDOC = '1' AND D_E_L_E_T_ = ' ') GWM1 ON GWM1.GWM_FILIAL = GW1.GW1_FILIAL "
	cQuery += "                         AND GWM1.GWM_CDTPDC = GW1.GW1_CDTPDC "
	cQuery += "                         AND GWM1.GWM_EMISDC = GW1.GW1_EMISDC "
	cQuery += "                         AND GWM1.GWM_SERDC  = GW1.GW1_SERDC "
	cQuery += "                         AND GWM1.GWM_NRDC   = GW1.GW1_NRDC "
	cQuery += "      LEFT JOIN ( SELECT DISTINCT GWM_FILIAL, GWM_CDTPDC, GWM_EMISDC, GWM_SERDC, GWM_NRDC "
	cQuery += "	               FROM " + RetSQLName("GWM")
	cQuery += "	              WHERE GWM_TPDOC = '2' AND D_E_L_E_T_ = ' ') GWM2 ON GWM2.GWM_FILIAL = GW1.GW1_FILIAL "
	cQuery += "                         AND GWM2.GWM_CDTPDC = GW1.GW1_CDTPDC "
	cQuery += "                         AND GWM2.GWM_EMISDC = GW1.GW1_EMISDC "
	cQuery += "                         AND GWM2.GWM_SERDC  = GW1.GW1_SERDC "
	cQuery += "                         AND GWM2.GWM_NRDC   = GW1.GW1_NRDC "
	cQuery += "	 WHERE GW1.D_E_L_E_T_ = ' '" + cBrwFiltro + CriaQueryCondicao(aFiltrosPR,"")
	If lRelac
		cQuery +=  "AND GWM1.GWM_CDTPDC IS NOT NULL "
		cQuery += " AND GWM2.GWM_CDTPDC IS NOT NULL "	
	EndIf
	
	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	
	If (cTmp)->(Recno()) > 0
		// Estatísticas Previsto
		aAdd(aStatPre, {"Qtde Doc Carga sem Previsto", (cTmp)->SEM_PRV})
		
		If (cTmp)->PES_PRV > 0
			aAdd(aStatPre, {"Frete Total por Ton", AllTrim(Transform((nPreTot / (cTmp)->PES_PRV * 1000),"@E 99,999,999,999.99"))})
			aAdd(aStatPre, {"Frete Normal por Ton", AllTrim(Transform((nPreNor / (cTmp)->PES_PRV * 1000),"@E 99,999,999,999.99"))})
		Else
			aAdd(aStatPre, {"Frete Total por Ton", 0})
			aAdd(aStatPre, {"Frete Normal por Ton", 0})
		EndIf
		
		If (cTmp)->VOL_PRV > 0
			aAdd(aStatPre, {"Frete Total por m3",  AllTrim(Transform((nPreTot / (cTmp)->VOL_PRV),"@E 99,999,999,999.99"))})
			aAdd(aStatPre, {"Frete Normal por m3", AllTrim(Transform((nPreNor / (cTmp)->VOL_PRV),"@E 99,999,999,999.99"))})
		Else
			aAdd(aStatPre, {"Frete Total por m3",  0})
			aAdd(aStatPre, {"Frete Normal por m3", 0})
		EndIf
		
		If (cTmp)->QTD_PRV > 0
			aAdd(aStatPre, {"Frete Total por Qtde Vol", AllTrim(Transform((nPreTot / (cTmp)->QTD_PRV),"@E 99,999,999,999.99"))})
			aAdd(aStatPre, {"Frete Normal por Qtde Vol", AllTrim(Transform((nPreNor / (cTmp)->QTD_PRV),"@E 99,999,999,999.99"))})
		Else
			aAdd(aStatPre, {"Frete Total por Qtde Vol", 0})
			aAdd(aStatPre, {"Frete Normal por Qtde Vol", 0})
		EndIf
		
		If (cTmp)->VAL_PRV > 0
			aAdd(aStatPre, {"% Frete Total sobre Valor Carga", AllTrim(Transform((nPreTot / (cTmp)->VAL_PRV * 100),"@E 99,999,999,999.99"))})
			aAdd(aStatPre, {"% Frete Normal sobre Valor Carga",AllTrim(Transform((nPreNor / (cTmp)->VAL_PRV * 100),"@E 99,999,999,999.99"))})
		Else
			aAdd(aStatPre, {"% Frete Total sobre Valor Carga", 0})
			aAdd(aStatPre, {"% Frete Normal sobre Valor Carga", 0})
		EndIf
		
		// Estatísticas Realizado
		aAdd(aStatRea, {"Qtde Doc Carga sem Realizado", (cTmp)->SEM_REA})
		
		If (cTmp)->PES_REA > 0
			aAdd(aStatRea, {"Frete Total por Ton", AllTrim(Transform((nReaTot / (cTmp)->PES_REA * 1000),"@E 99,999,999,999.99"))})
			aAdd(aStatRea, {"Frete Normal por Ton", AllTrim(Transform((nReaNor / (cTmp)->PES_REA * 1000),"@E 99,999,999,999.99"))})
		Else
			aAdd(aStatRea, {"Frete Total por Ton", 0})
			aAdd(aStatRea, {"Frete Normal por Ton", 0})
		EndIf
		
		If (cTmp)->VOL_PRV > 0
			aAdd(aStatRea, {"Frete Total por m3", AllTrim(Transform((nReaTot / (cTmp)->VOL_REA),"@E 99,999,999,999.99"))})
			aAdd(aStatRea, {"Frete Normal por m3", AllTrim(Transform((nReaNor / (cTmp)->VOL_REA),"@E 99,999,999,999.99"))})
		Else
			aAdd(aStatRea, {"Frete Total por m3",  0})
			aAdd(aStatRea, {"Frete Normal por m3", 0})
		EndIf
		
		If (cTmp)->QTD_PRV > 0
			aAdd(aStatRea, {"Frete Total por Qtde Vol", AllTrim(Transform((nReaTot / (cTmp)->QTD_REA),"@E 99,999,999,999.99"))})
			aAdd(aStatRea, {"Frete Normal por Qtde Vol", AllTrim(Transform((nReaNor / (cTmp)->QTD_REA),"@E 99,999,999,999.99"))})
		Else
			aAdd(aStatRea, {"Frete Total por Qtde Vol", 0})
			aAdd(aStatRea, {"Frete Normal por Qtde Vol", 0})
		EndIf
		
		If (cTmp)->VAL_PRV > 0
			aAdd(aStatRea, {"% Frete Total sobre Valor Carga", AllTrim(Transform((nReaTot / (cTmp)->VAL_REA * 100),"@E 99,999,999,999.99"))})
			aAdd(aStatRea, {"% Frete Normal sobre Valor Carga",AllTrim(Transform((nReaNor / (cTmp)->VAL_REA * 100),"@E 99,999,999,999.99"))})
		Else
			aAdd(aStatRea, {"% Frete Total sobre Valor Carga", 0})
			aAdd(aStatRea, {"% Frete Normal sobre Valor Carga", 0})
		EndIf
	EndIf
	
	(cTmp)->(dbCloseArea())
Return Nil

//=========================================================================/ 
// Aplica o filtro do browse na consulta SQL
// Aba "Cálculos de Frete"
//=========================================================================/

Function GFEC001KCF(aParam) 
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
// Aba "Documentos de Frete"
//=========================================================================/
Function GFEC001KDF(aParam) 
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

//=========================================================================/ 
// Aplica o filtro do browse na consulta SQL
// Aba "Previsto x Realizado"
//=========================================================================/
Function GFEC001KEF(aParam)
	Local nCont 
	Local cFiltro := ""
	Local lRelac  := .F.
	
	For nCont := 1 To Len(aParam)
		If !aParam[nCont][5] .And. aParam[nCont][2] != "GFEC001REL()"
	       	If !Empty(cFiltro)
	       		cFiltro := cFiltro + " AND (" +  aParam[nCont][3] + ")"
	       	Else
	       	    cFiltro := " AND (" +  aParam[nCont][3] + ")"
	       	EndIf
		EndIf
		
		If aParam[nCont][2] == "GFEC001REL()"
			lRelac := .T.
		EndIf
	Next nCont
	
	Processa({||AtualizaPR(cFiltro, lRelac)})
Return .T. 

Static Function AtualizaFR(cFiltro)
	CarregaFR(aFiltrosFR,cFiltro)
	GFEC001GRA(oGrfTPDF,.T.,aGrfTPDF)
	GFEC001GRA(oGrfCTDF,.T.,aGrfCTDF)
Return Nil     

Static Function AtualizaPR(cFiltro, lRelac)
	CarregaPR(aFiltrosPR,cFiltro,lRelac)
	GFEC001GRA(oGrfDCNo,.T.,aGrfDCNo)
	GFEC001GRA(oGrfDCTo,.T.,aGrfDCTo)
	oBrowsePre:SetArray(aStatPre)
	oBrowsePre:UpdateBrowse()
	oBrowseRea:SetArray(aStatRea)
	oBrowseRea:UpdateBrowse()
Return Nil


//
// Cria tabela temporária para o browse com os documentos 
// de carga para o emitente selecionadao
//
// OBS
// Não é feito com SetFilterDefault pois precisa validar o transportador 
// através dos trechos na GWU e utilizando função como filtro fica muito lento
// com muitos registros.
//
Static Function CriaTab()
	Local cQuery := ""
	Local cAlias
	Local aFields, aIndices
	Local nCont
	Local cTmp
	Local aStruct := {}
	Local aTpFret := {"CIF","CIF Redesp","FOB","FOB Redesp","Consignado","Consig Redesp"} 
	
	aFields := ;
	{{"Filial"	     ,"GW1_FILIAL","C",TamSX3("GW1_FILIAL")[1],0},;
	{"Tp Doc"	   	 ,"GW1_CDTPDC","C",TamSX3("GW1_CDTPDC")[1],0},;
	{"Emissor"      ,"GW1_EMISDC","C",TamSX3("GW1_EMISDC")[1],0},;
	{"Série"        ,"GW1_SERDC" ,"C",TamSX3("GW1_SERDC")[1] ,0},;
	{"Número"       ,"GW1_NRDC"  ,"C",TamSX3("GW1_NRDC")[1]  ,0},;
	{"Dt Emissão"  ,"GW1_DTEMIS","D",TamSX3("GW1_DTEMIS")[1],0},;
	{"Remetente"   ,"GW1_CDREM" ,"C",TamSX3("GW1_CDREM")[1] ,0},;
	{"Destinatário","GW1_CDDEST","C",TamSX3("GW1_CDDEST")[1],0},;
	{"Tipo Frete"  ,"GW1_TPFRET","C",20,0},;
	{"Nr Romaneio" ,"GW1_NRROM" ,"C",TamSX3("GW1_NRROM")[1] ,0},;
	{"Seq Trecho"  ,"GWU_SEQ" 	,"C",TamSX3("GWU_SEQ")[1]   ,0}}
	
	aIndices := {"GW1_FILIAL+GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC+DtoS(GW1_DTEMIS)"}
	
	For nCont := 1 To Len(aFields)
		aADD(aStruct,{aFields[nCont][2],;  //Nome do campo
						aFields[nCont][3],;  //Tipo
						aFields[nCont][4],;  //Tamanho
						aFields[nCont][5]}) //Decimal
	Next nCont
	
	cAlias := GFECriaTab({aStruct,aIndices})
	
	cQuery += "	SELECT GW1_FILIAL, "
	cQuery += "		   GW1_CDTPDC, "
	cQuery += "		   GW1_EMISDC, "
	cQuery += "		   GW1_SERDC, "
	cQuery += "		   GW1_NRDC, "
	cQuery += "		   GW1_DTEMIS, "
	cQuery += "		   GW1_CDREM, "
	cQuery += "		   GW1_CDDEST, "
	cQuery += "		   GW1_TPFRET, "
	cQuery += "		   GW1_NRROM, "
	cQuery += "		   GWU_SEQ "
	cQuery += "	  FROM " + RetSQLName("GW1") + " GW1 "
	cQuery += "	 INNER JOIN " + RetSQLName("GWU") + " GWU ON GWU.GWU_FILIAL = GW1.GW1_FILIAL "
	cQuery += "	 					  AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC "
	cQuery += "	 					  AND GWU.GWU_EMISDC = GW1.GW1_EMISDC "
	cQuery += "	 					  AND GWU.GWU_SERDC  = GW1.GW1_SERDC "
	cQuery += "	 					  AND GWU.GWU_NRDC   = GW1.GW1_NRDC "
	cQuery += "	 WHERE GW1.D_E_L_E_T_ = '' "
	cQuery += "	   AND GWU.D_E_L_E_T_ = '' "
	cQuery += "	   AND GW1.GW1_FILIAL >= '"+cFilialDe+"' "
	cQuery += "	   AND GW1.GW1_FILIAL <= '"+cFilialAte+"' "
	cQuery += "	   AND GW1.GW1_DTEMIS >= '"+DtoS(dDataDe)+"' "
	cQuery += "	   AND GW1.GW1_DTEMIS <= '"+DtoS(dDataAte)+"' "
	cQuery += "	   AND GWU.GWU_CDTRP   = '"+cCodEmit+"' "
	
	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	
	While (cTmp)->(!Eof())
		RecLock(cAlias,.T.)
		(cAlias)->GW1_FILIAL := (cTmp)->GW1_FILIAL
		(cAlias)->GW1_CDTPDC := (cTmp)->GW1_CDTPDC
		(cAlias)->GW1_EMISDC := (cTmp)->GW1_EMISDC
		(cAlias)->GW1_SERDC  := (cTmp)->GW1_SERDC
		(cAlias)->GW1_NRDC   := (cTmp)->GW1_NRDC
		(cAlias)->GW1_DTEMIS := StoD((cTmp)->GW1_DTEMIS)
		(cAlias)->GW1_CDREM  := (cTmp)->GW1_CDREM
		(cAlias)->GW1_CDDEST := (cTmp)->GW1_CDDEST
		(cAlias)->GW1_TPFRET := aTpFret[Val((cTmp)->GW1_TPFRET)]
		(cAlias)->GW1_NRROM  := (cTmp)->GW1_NRROM
		(cAlias)->GWU_SEQ    := (cTmp)->GWU_SEQ
		MsUnlock(cAlias)
		(cTmp)->(dbSkip())
	EndDo
	
	(cTmp)->(dbCloseArea())
Return cAlias
