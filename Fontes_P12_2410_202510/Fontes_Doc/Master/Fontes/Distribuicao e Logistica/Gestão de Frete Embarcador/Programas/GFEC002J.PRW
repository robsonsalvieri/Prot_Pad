#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEC002J
Painel Gerencial de Filiais - Informações sobre Despesa de Transporte

Uso Restrito.

Param:
aParam[1] := Data de
aParam[2] := Data ate
aParam[3] := Filial     

@sample
GFEC002J(aParam)

@author Alan Victor Lamb
@since  01/07/13
@version 1.0
--------------------------------------------------------------------------------------------------/*/  
Function GFEC002J(aParam)
	Local aCoors  := FWGetDialogSize(oMainWnd)
	Local cTitulo := 'Painel Gerencial - Filial'     
	
	Private oBrowseCal, oBrowseDoc, oBrowseCar, oBrowseEst
	Private aGrfTpc, aGrfCom, aGrfTPDF, aGrfCTDF, aGrfDCTo, aGrfDCNo, aGrfIRT, aGrfIRN, aGrfIPT, aGrfIPN, aGrfNeg, aGrfCatTrp, aGrfTpLot, aGrfCCon
	Private oGrfTpc, oGrfCom, oGrfTPDF, oGrfCTDF, oGrfDCTo, oGrfDCNo, oGrfImp, oGrfNeg, oGrfCatTrp, oGrfTpLot, oGrfCCon
	Private aStatPre, aStatRea, aStat
	Private oBrowsePre, oBrowseRea
	Private aFiltrosFP, aFiltrosFR, aFiltrosPR, aFiltrosCON
	Private cFil  := aParam[3]
	Private dDataDe  := If(Empty(aParam[1]),DDATABASE -30 ,aParam[1])
	Private dDataAte := If(Empty(aParam[2]),DDATABASE     ,aParam[2])                   
	Private oFolder
	
	Private nValCalc, nQtdCalc
		
	aFiltrosFP := {{"GWF","GWF_FILIAL","=",cFil},;   
				   {"GWF","GWF_DTCRIA",">=",DtoS(dDataDe)},;
				   {"GWF","GWF_DTCRIA","<=",DtoS(dDataAte)}}
	
	aFiltrosFR := {{"GW3","GW3_FILIAL","=",cFil},;   
				   {"GW3","GW3_DTENT",">=",DtoS(dDataDe)},;
				   {"GW3","GW3_DTENT","<=",DtoS(dDataAte)}}
	
	aFiltrosPR := {{"GW1","GW1_FILIAL","=",cFil},;   
				   {"GW1","GW1_DTEMIS",">=",DtoS(dDataDe)},;
				   {"GW1","GW1_DTEMIS","<=",DtoS(dDataAte)}}
	
	aFiltrosCON := {{"GW2","GW2_FILIAL","=",cFil},;   
				     {"GW2","GW2_DTCRIA",">=",Dtos(dDataDe)},;
				     {"GW2","GW2_DTCRIA","<=",Dtos(dDataAte)}}
	
	Define MsDialog oDLG Title cTitulo From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
	oDLG:Activate(,,,.T.,,,{||RptStatus({||Iniciar()},"Aguarde", "Realizando consultas de dados")})
Return 

//
// Inicia a tela
//
Static Function Iniciar()
	Local cBrowseFiltro
	Local oPnl,oFolderEst,oFolderGrf
	Local oFWLayer, oWIN_TOP, oWIN_LEFT, oWIN_RIGHT, oWIN_MIDDLE
	Local aColFrtCal, aColFrtPre, aColunas
	Local aColValCalc
	
	SetRegua(5)
	
	//Carrega dados de consultas SQL
	CarregaFP(aFiltrosFP)
	CarregaFR(aFiltrosFR)
	CarregaPR(aFiltrosPR)
	CarregaCON(aFiltrosCON)
	
	IncRegua()
	
	oFolder :=  tFolder():New(30,0,{"Cálculos de frete","Documentos de frete","Contratos", "Previsto x Realizado"},{"G1","G2","G3"},oDLG,)
	oFolder:Align := CONTROL_ALIGN_ALLCLIENT
	
	//
	// Aba Cálculos de Frete
	//
	cBrowseFiltro := "GWF_TPCALC != '8' .AND. " // Desconsidera cálculos do tipo "Provisão"  
	cBrowseFiltro += "GWF_FILIAL == '" + cFil + "' .AND. "  
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
  	oFWLayer:AddWindow('COL_RIGHT','WIN_RIGHT','Forma de Negociação',100,.F.,.F.,,'LINE_MIDDLE',)
  	
    oWIN_TOP    := oFWLayer:GetColPanel('COL_TOP','LINE_TOP')
    oWIN_LEFT   := oFWLayer:GetWinPanel('COL_LEFT','WIN_LEFT','LINE_MIDDLE')
    oWIN_RIGHT  := oFWLayer:GetWinPanel('COL_RIGHT','WIN_RIGHT','LINE_MIDDLE')
    oWIN_MIDDLE := oFWLayer:GetWinPanel('COL_MIDDLE','WIN_MIDDLE','LINE_MIDDLE')
	
	//
	// Cálculos de frete
	//
	aColValCalc := {{"Valor Calc", {|| GFEC001VLF()}, "N","@E 999,999,999.99",2,15,2,.F.}}
	
	//
	// Cálculos de frete
	//
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
	oBrowseCal:BVLDEXECFILTER := {|aParam| GFEC002FIL(1,aParam)}
	oBrowseCal:Activate()
	
	GFEC001GRC("oGrfTpc","Valor por tipo de cálculo",oWIN_LEFT,aGrfTpc,"@E 999,999,999.99")
    GFEC001GRC("oGrfCom","Valor por componente",oWIN_MIDDLE,aGrfCom,"@E 999,999,999.99")
    
    oFolderTmp := TFolder():New(0,0,{"Cálculo","Categoria Transp.","Tipo Lotação"},,oWIN_RIGHT,,,,.T.,,(oWIN_RIGHT:nwidth/2),(oWIN_RIGHT:nHeight/2))
	oFolderTmp:Align := CONTROL_ALIGN_ALLCLIENT
    
    GFEC001GRC("oGrfNeg","Tipo de Negociação",oFolderTmp:aDialogs[1],aGrfNeg,"@E 999,999,999.99")
    GFEC001GRC("oGrfCatTrp","Categoria de transportadora",oFolderTmp:aDialogs[2],aGrfCatTrp,"@E 999,999,999.99")
    GFEC001GRC("oGrfTpLot","Tipo de Lotação",oFolderTmp:aDialogs[3],aGrfTpLot,"@E 999,999,999.99")
    
    IncRegua()
    
    //
    // Aba Documentos de Frete
    //
    cBrowseFiltro := "GW3_FILIAL == '" + cFil + "' .AND. "  
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
	oBrowseDoc:BVLDEXECFILTER := {|aParam| GFEC002FIL(2,aParam)}
	oBrowseDoc:Activate()
	
	GFEC001GRC("oGrfTPDF","Valor por tipo de Doc Frete",oWIN_LEFT,aGrfTPDF,"@E 999,999,999.99")
	GFEC001GRC("oGrfCTDF","Valor por Categoria",oWIN_RIGHT,aGrfCTDF,"@E 999,999,999.99")
    
    IncRegua()
    
    //
    // Aba Contratos
    //
	cBrowseFiltro := "(GW2_SITCON == '2' .OR. GW2_SITCON == '3') .AND. "
	cBrowseFiltro += "GW2_FILIAL == '" + cFil  + "' .AND. "  
	cBrowseFiltro += "GW2_DTCRIA >= '" + DtoS(dDataDe) + "' .AND. GW2_DTCRIA <= '" + DtoS(dDataAte) + "'"
	
    oPnl := tPanel():New(30,0,,oFolder:aDialogs[3],,,,,,)
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
	oBrowseCon:BVLDEXECFILTER := {|aParam| GFEC002FIL(3,aParam)}
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
	
	// Custo do frete
	GFEC001GRC("oGrfCCon", "Custo do Frete", oWIN_RIGHT, aGrfCCon, "@E 999,999,999.99")
	
	IncRegua()
	
    //
    // Aba Previsto x Realizado
    //
	oPnl := tPanel():New(30,0,,oFolder:aDialogs[4],,,,,,)
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
    aColFrtCal := {"Frt Calculado", {||CalcFrtTip("1")}, "N","@E 999,999,999.99",2,15,2,.F.}
    aColFrtPre := {"Frt Realizado", {||CalcFrtTip("2;3")}, "N","@E 999,999,999.99",2,15,2,.F.}
    aColunas   := { aColFrtCal, aColFrtPre }
    
    //
	// Documentos de carga
	//
	oBrowseCar:= FWMBrowse():New()
	oBrowseCar:SetOwner(oWIN_TOP)
	oBrowseCar:SetAlias('GW1')
	oBrowseCar:SetDescription("Documentos de carga")
	oBrowseCar:SetLocate()
	oBrowseCar:SetAmbiente(.F.)
	oBrowseCar:SetWalkthru(.F.)
	oBrowseCar:DisableDetails()
	oBrowseCar:SetMenuDef("")
	oBrowseCar:AddButton("Visualizar","VIEWDEF.GFEC040",,2)
	oBrowseCar:ForceQuitButton(.T.)
	oBrowseCar:SetFields(aColunas)
	oBrowseCar:SetProfileID("3")
	oBrowseCar:SetFilterDefault("GW1_FILIAL == '" + cFil + "' .AND. DTOS(GW1_DTEMIS) >= '" + DtoS(dDataDe) + "' .And. DTOS(GW1_DTEMIS) <= '" + DtoS(dDataAte) + "'")
	oBrowseCar:AddFilter("Somente documentos com Previsto e Realizado", "GFEC002REL()")
	oBrowseCar:SetVldExecFilter({|aParam| GFEC002FIL(4,aParam)})
	oBrowseCar:Activate()
	
	oBrowseCar:SetColumnOrder(1,9)
	oBrowseCar:SetColumnOrder(2,10)
	oBrowseCar:UpdateBrowse()
	
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
	// Últimos parametros do construtor: Consultar chamado TFKSA9
	// 
	oFolderGrf := TFolder():New( 0,0,{"Total","Normal"},,oWIN_MIDDLE,,,,.T.,,(oWIN_MIDDLE:nwidth/2),(oWIN_MIDDLE:nHeight/2))
	oFolderGrf:Align := CONTROL_ALIGN_ALLCLIENT
	oFolderGrf:bSetOption := {|nOption|AtuFolder(nOption)} // Atualiza o gráfico de impostos ao mudar aba
	
	// Gráfico com a soma total do valor de frete
	GFEC001GRC("oGrfDCTo","Valor de Frete Total",oFolderGrf:aDialogs[1],aGrfDCTo,"@E 999,999,999",{|nSerie| AtuImpostos(nSerie,"T")},BARCHART)
	// Gráfico com a soma do frete normal GWD_TPDF/GWF_TPCALC 1 e 6
	GFEC001GRC("oGrfDCNo","Valor de Frete Normal",oFolderGrf:aDialogs[2],aGrfDCNo,"@E 999,999,999",{|nSerie| AtuImpostos(nSerie,"N")},BARCHART)
	// Gráfico impostos
    GFEC001GRC("oGrfImp","Impostos Frete Previsto Total",oWIN_RIGHT,aGrfIPT,"@E 999,999,999")
    
    IncRegua()
Return Nil

Static Function AtuFolder(nOption)
	If nOption == 1
		AtuImpostos(1, "T")
	ElseIf nOption == 2
		AtuImpostos(1, "N")
	EndIf
Return Nil

//
// Atualiza o gráfico de impostos da aba "Previsto x Realizado"
// Utilizada no duplo clique dos gráficos de frete total/normal 
//
// nSerie: 1 Previsto
//         2 Realizdo
// cTipo:  "N" Normal
//         "T" Total
//
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
// Faz a soma do valor total de frete por Tipo de Documento
//
Static Function CalcFrtTip(cTpDoc)
	Local nRet      := 0
	Local aAreaGW1 := GW1->(GetArea())
	Local aAreaGWM
	
	dbSelectArea("GWM")
	aAreaGWM := GWM->(GetArea())
	GWM->(dbSetOrder(2))
	
	If GWM->(dbSeek(GW1->(GW1_FILIAL+GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC)))
		While GWM->(!Eof()) .And. ;
		       GWM->(GWM_FILIAL+GWM_CDTPDC+GWM_EMISDC+GWM_SERDC+GWM_NRDC) == GW1->(GW1_FILIAL+GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC)
		    If GWM->GWM_TPDOC $ cTpDoc 
				nRet += GWM->GWM_VLFRET
			EndIf
			
			GWM->(dbSkip())
 		EndDo
	EndIf
	
	RestArea(aAreaGWM)
	RestArea(aAreaGW1)
Return nRet

//
// Filtro para exibir apenas documentos de carga que tenham frete previsto e calculado
//
Function GFEC002REL()
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
		    ElseIf GWM->GWM_TPDOC $ "2;3"
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
	
	// Valor por Tipo Doc Frete
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
	
	// Valor por Categoria de Valor de Frete
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
// Carrega os dados de Contratos
//
Static Function CarregaCON(aFiltrosCON, cBrwFiltro)
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
	cQuery += "	 WHERE GW2.D_E_L_E_T_ = ' ' AND GW2.GW2_SITCON IN ('2','3') " + cBrwFiltro + CriaQueryCondicao(aFiltrosCON,"")
	
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
		aAdd(aStat, {"Filial"              , "-", AllTrim(FWFilialName(,cFil,))})
		
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
	aGrfCatTrp := {}
	aGrfTpLot := {}
	
	// Valor de Frete por Tipo de Cálculo	
	cQuery += "SELECT SUM(CASE WHEN GWF_TPCALC = '1' THEN GWI_VLFRET + GWF_VLAJUS ELSE 0 END) VAL_TP1,"
	cQuery += "	   	  SUM(CASE WHEN GWF_TPCALC = '2' THEN GWI_VLFRET + GWF_VLAJUS ELSE 0 END) VAL_TP2,"
	cQuery += "	      SUM(CASE WHEN GWF_TPCALC = '3' THEN GWI_VLFRET + GWF_VLAJUS ELSE 0 END) VAL_TP3,"
	cQuery += "	      SUM(CASE WHEN GWF_TPCALC = '4' THEN GWI_VLFRET + GWF_VLAJUS ELSE 0 END) VAL_TP4,"
	cQuery += "	      SUM(CASE WHEN GWF_TPCALC = '5' THEN GWI_VLFRET + GWF_VLAJUS ELSE 0 END) VAL_TP5,"
	cQuery += "	      SUM(CASE WHEN GWF_TPCALC = '6' THEN GWI_VLFRET + GWF_VLAJUS ELSE 0 END) VAL_TP6,"
	cQuery += "	      SUM(CASE WHEN GWF_TPCALC = '7' THEN GWI_VLFRET + GWF_VLAJUS ELSE 0 END) VAL_TP7,"
	cQuery += "		  SUM(CASE WHEN GWF_ORIGEM = '1' THEN GWI_VLFRET + GWF_VLAJUS END) TABELADO, "
	cQuery += "	      SUM(CASE WHEN GWF_ORIGEM = '2' THEN GWI_VLFRET + GWF_VLAJUS END) COMBINADO, "
	cQuery += "		  SUM(CASE WHEN GU3_CATTRP = '1' THEN GWI_VLFRET + GWF_VLAJUS END) GU3_CAT1, "
	cQuery += "	      SUM(CASE WHEN GU3_CATTRP = '2' THEN GWI_VLFRET + GWF_VLAJUS END) GU3_CAT2, "
	cQuery += "	      SUM(CASE WHEN GU3_CATTRP = '3' THEN GWI_VLFRET + GWF_VLAJUS END) GU3_CAT3, "
	cQuery += "	      SUM(CASE WHEN GU3_CATTRP = '4' THEN GWI_VLFRET + GWF_VLAJUS END) GU3_CAT4, "
	cQuery += "	      SUM(CASE WHEN GU3_CATTRP = '5' THEN GWI_VLFRET + GWF_VLAJUS END) GU3_CAT5, "  
	cQuery += "	      SUM(CASE WHEN GU3_CATTRP = '6' THEN GWI_VLFRET + GWF_VLAJUS END) GU3_CAT6, "
	cQuery += "	      SUM(CASE WHEN GU3_CATTRP = '7' THEN GWI_VLFRET + GWF_VLAJUS END) GU3_CAT7, "
	cQuery += "	      SUM(CASE WHEN GU3_CATTRP = '8' THEN GWI_VLFRET + GWF_VLAJUS END) GU3_CAT8,  "
	cQuery += "	      SUM(CASE WHEN GV9_TPLOTA = '1' THEN GWI_VLFRET + GWF_VLAJUS END) FRAC,"
	cQuery += "	      SUM(CASE WHEN GV9_TPLOTA = '2' THEN GWI_VLFRET + GWF_VLAJUS END) FECH,"
	cQuery += "	      COUNT(*) QTD_CALC, "
	cQuery += "	      SUM(GWI_VLFRET + GWF_VLAJUS) VAL_CALC "
	cQuery += "  FROM " + RetSQLName("GWF") + " GWF "
	cQuery += " INNER JOIN ( "
	cQuery += " 	SELECT GWI_NRCALC, GWI_FILIAL, SUM(GWI_VLFRET) GWI_VLFRET "
	cQuery += " 	  FROM " + RetSQLName("GWI")
	cQuery += " 	 WHERE D_E_L_E_T_ = ' ' "
	cQuery += " 	   AND GWI_TOTFRE = '1' "
	cQuery += " 	 GROUP BY GWI_NRCALC, GWI_FILIAL "
	cQuery += " ) GWI ON GWI.GWI_FILIAL = GWF.GWF_FILIAL "
	cQuery += "      AND GWI.GWI_NRCALC = GWF.GWF_NRCALC "
	cQuery += " LEFT JOIN " + RetSQLName("GU3") + " GU3 ON GU3.GU3_CDEMIT = GWF.GWF_TRANSP "
	cQuery += "		LEFT JOIN ( SELECT DISTINCT GWG_NRCALC, GV9_TPLOTA " 
	cQuery += "                FROM " + RetSQLName("GWG") + " GWG "
	cQuery += "			    LEFT JOIN " + RetSQLName("GV9") + " GV9 ON GV9.GV9_CDEMIT = GWG.GWG_CDEMIT "
	cQuery += "			                        AND GV9.GV9_NRTAB  = GWG.GWG_NRTAB "
	cQuery += "			                        AND GV9.GV9_NRNEG  = GWG.GWG_NRNEG "
	cQuery += "			   WHERE GWG.D_E_L_E_T_ = ' ' "
	cQuery += "			     AND GV9.D_E_L_E_T_ = ' ') GWG ON GWG.GWG_NRCALC = GWF.GWF_NRCALC "
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
		
		aAdd(aGrfCatTrp, {"Empresa Comercial", (cTmp)->GU3_CAT1})
		aAdd(aGrfCatTrp, {"Autonomo", (cTmp)->GU3_CAT2})
		aAdd(aGrfCatTrp, {"Cooperativa", (cTmp)->GU3_CAT3})
		aAdd(aGrfCatTrp, {"Operador Logistico", (cTmp)->GU3_CAT4})
		aAdd(aGrfCatTrp, {"Distribuidor", (cTmp)->GU3_CAT5})
		aAdd(aGrfCatTrp, {"Correios", (cTmp)->GU3_CAT6})
		aAdd(aGrfCatTrp, {"Proprio Embarcador", (cTmp)->GU3_CAT7})
		aAdd(aGrfCatTrp, {"Outros", (cTmp)->GU3_CAT8})
		
		aAdd(aGrfTpLot, {"Fracionada", (cTmp)->FRAC})
		aAdd(aGrfTpLot, {"Fechada", (cTmp)->FECH})
		
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

//
// Carrega dados Previsto x Realizado
//
Static Function CarregaPR(aFiltrosPR,cBrwFiltro,lRelac)
	Local cQuery      	:= ""
	Local cTmp        	:= ""
	Local cAliPrev 		:= ""
	Local cAliReDF		:= ""
	Local cAliReCon		:= ""
	Local cQryFiltro 	:= ""
	Local cFiltro		:= ""
	
	Local nReaNor		:= 0
	Local nReaTot		:= 0
	Local nPreNor		:= 0
	Local nPreTot		:= 0	
	Local nTotFret		:= 0
	Local nTotDesp		:= 0
	Local nNorIss		:= 0
	Local nNorICMRec	:= 0
	Local nNorICMNaoRec := 0
	Local nNorPisRec 	:= 0
	Local nNorCofRec	:= 0
	Local nNorPisNaoRec := 0
	Local nNorCofNaoRec := 0
	Local nTotReent		:= 0
	Local nTotDevol		:= 0
	Local nTotServ		:= 0
	Local nTotIss		:= 0
	Local nTotICMRec	:= 0
	Local nTotICMNaoRec	:= 0
	Local nTotPisRec	:= 0 
	Local nTotCofRec	:= 0
	Local nTotPisNaoRec	:= 0
	Local nTotCofNaoRec	:= 0
	Local nAutIss		:= 0
	Local nAutIrrf		:= 0
	Local nAutInAu		:= 0
	Local nAutInEm		:= 0
	Local nAutSest 		:= 0

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
	
	cQryFiltro := CriaQueryCondicao(aFiltrosPR,"")
	cFiltro    := "%" + cBrwFiltro + cQryFiltro + "%"

	cAliPrev := GetNextAlias()

	BeginSQL Alias cAliPrev 
		SELECT GWF.GWF_TPCALC,
			   GWF.GWF_CRDICM,
			   GWF.GWF_CRDPC,
			   SUM(GWM.GWM_VLFRET) GWM_VLFRET,
			   SUM(GWM.GWM_VLISS) GWM_VLISS,
			   SUM(GWM.GWM_VLICMS) GWM_VLICMS,
			   SUM(GWM.GWM_VLPIS) GWM_VLPIS,
			   SUM(GWM.GWM_VLCOFI) GWM_VLCOFI
		FROM %Table:GWM% GWM
		INNER JOIN %Table:GWF% GWF
		ON GWF.GWF_FILIAL = GWM.GWM_FILIAL
		AND GWF.GWF_NRCALC = GWM.GWM_NRDOC
		AND GWF.%NotDel%
		INNER JOIN %Table:GW1% GW1
		ON GW1.GW1_FILIAL = GWM.GWM_FILIAL
		AND GW1.GW1_CDTPDC = GWM.GWM_CDTPDC
		AND GW1.GW1_EMISDC = GWM.GWM_EMISDC
		AND GW1.GW1_SERDC = GWM.GWM_SERDC
		AND GW1.GW1_NRDC = GWM.GWM_NRDC
		AND GW1.GW1_DTEMIS = GWM.GWM_DTEMDC
		AND GW1.%NotDel%
		WHERE GWM.GWM_TPDOC = '1'
		AND GWM.%NotDel%
		%Exp:cFiltro%
		GROUP BY GWF.GWF_TPCALC, GWF.GWF_CRDICM, GWF.GWF_CRDPC
		ORDER BY GWF.GWF_TPCALC, GWF.GWF_CRDICM, GWF.GWF_CRDPC
	EndSQL

	(cAliPrev)->(dbGoTop())

	While (cAliPrev)->(!Eof())
		nTotFret += (cAliPrev)->GWM_VLFRET

		If (cAliPrev)->GWF_TPCALC $ '1236'
			nTotDesp += (cAliPrev)->GWM_VLFRET
			nNorIss  += (cAliPrev)->GWM_VLISS

			If (cAliPrev)->GWF_CRDICM == '1'
				nNorICMRec += (cAliPrev)->GWM_VLICMS
			EndIf

			If (cAliPrev)->GWF_CRDICM == '2'
				nNorICMNaoRec += (cAliPrev)->GWM_VLICMS
			EndIf

			If (cAliPrev)->GWF_CRDPC == '1'
				nNorPisRec += (cAliPrev)->GWM_VLPIS
				nNorCofRec += (cAliPrev)->GWM_VLCOFI
			EndIf

			If (cAliPrev)->GWF_CRDPC == '2'
				nNorPisNaoRec += (cAliPrev)->GWM_VLPIS
				nNorCofNaoRec += (cAliPrev)->GWM_VLCOFI
			EndIf
		EndIf

		If (cAliPrev)->GWF_TPCALC == '4'
			nTotReent += (cAliPrev)->GWM_VLFRET
		EndIf
		
		If (cAliPrev)->GWF_TPCALC == '5'
			nTotDevol += (cAliPrev)->GWM_VLFRET
		EndIf

		If (cAliPrev)->GWF_TPCALC == '7'
			nTotServ += (cAliPrev)->GWM_VLFRET
		EndIf

		nTotIss += (cAliPrev)->GWM_VLISS

		If (cAliPrev)->GWF_CRDICM = '1'
			nTotICMRec += (cAliPrev)->GWM_VLICMS
		EndIf

		If (cAliPrev)->GWF_CRDICM = '2'
			nTotICMNaoRec += (cAliPrev)->GWM_VLICMS
		EndIf

		If (cAliPrev)->GWF_CRDPC == '1'
			nTotPisRec += (cAliPrev)->GWM_VLPIS
			nTotCofRec += (cAliPrev)->GWM_VLCOFI
		EndIf

		If (cAliPrev)->GWF_CRDPC == '2'
			nTotPisNaoRec += (cAliPrev)->GWM_VLPIS
			nTotCofNaoRec += (cAliPrev)->GWM_VLCOFI
		EndIf

		(cAliPrev)->(dbSkip())
	EndDo

	(cAliPrev)->(dbCloseArea())

	// Séries Gráficos Frete Normal / Total
	aAdd(aGrfDCTo, {"Previsto", nTotFret})
	aAdd(aGrfDCNo, {"Previsto", nTotDesp})
	
	// Estatísticas Previsto
	aAdd(aStatPre, {"Filial", AllTrim(FWFilialName(,cFil,))})
	aAdd(aStatPre, {"Frete Total", AllTrim(Transform(nTotFret,"@E 99,999,999,999.99"))})
	aAdd(aStatPre, {"ISS do Frete Total", AllTrim(Transform(nTotIss,"@E 99,999,999,999.99"))})
	aAdd(aStatPre, {"ICMS recuperável do Frete Total", AllTrim(Transform(nTotICMRec,"@E 99,999,999,999.99"))})
	aAdd(aStatPre, {"ICMS não recuperável do Frete Total", AllTrim(Transform(nTotICMNaoRec,"@E 99,999,999,999.99"))})
	aAdd(aStatPre, {"PIS/COFINS recuperável do Frete Total", AllTrim(Transform(nTotPisRec + nTotCofRec,"@E 99,999,999,999.99"))})
	aAdd(aStatPre, {"PIS/COFINS não recuperável do Frete Total", AllTrim(Transform(nTotPisNaoRec + nTotCofNaoRec,"@E 99,999,999,999.99"))})
	aAdd(aStatPre, {"ISS Autônomo do Frete Total", AllTrim(Transform(0,"@E 99,999,999,999.99"))})
	aAdd(aStatPre, {"IRRF do Frete Total", AllTrim(Transform(0,"@E 99,999,999,999.99"))})
	aAdd(aStatPre, {"INSS Autônomo do Frete Total", AllTrim(Transform(0,"@E 99,999,999,999.99"))})
	aAdd(aStatPre, {"INSS Empresa do Frete Total", AllTrim(Transform(0,"@E 99,999,999,999.99"))})
	aAdd(aStatPre, {"SEST/SENAT do Frete Total", AllTrim(Transform(0,"@E 99,999,999,999.99"))})
	aAdd(aStatPre, {"Frete Normal", AllTrim(Transform(nTotDesp,"@E 99,999,999,999.99"))})
	aAdd(aStatPre, {"Frete Reentregas", AllTrim(Transform(nTotReent,"@E 99,999,999,999.99"))})
	aAdd(aStatPre, {"Frete Devoluções", AllTrim(Transform(nTotDevol,"@E 99,999,999,999.99"))})
	aAdd(aStatPre, {"Serviços", AllTrim(Transform(nTotServ,"@E 99,999,999,999.99"))})
		
	/* Gráfico pizza - Imposto Frete Total Previsto */
	aAdd(aGrfIPT, {"ISS", nTotIss})
	aAdd(aGrfIPT, {"Impostos Autonônomo", 0})
	aAdd(aGrfIPT, {"ICMS recuperável", nTotICMRec})
	aAdd(aGrfIPT, {"ICMS não recuperável", nTotICMNaoRec})
	aAdd(aGrfIPT, {"PIS/COFINS recuperável", nTotPisRec + nTotCofRec})
	aAdd(aGrfIPT, {"PIS/COFINS não recuperável", nTotPisNaoRec + nTotCofNaoRec})
	aAdd(aGrfIPT, {"Despesa sem impostos", nTotFret - ;
								    	   (nTotIss + nTotICMRec + ;
											nTotICMNaoRec + nTotPisRec +;
											nTotCofRec + nTotPisNaoRec +;
											nTotCofNaoRec)})
				
	/* Gráfico pizza - Imposto Frete Normal Previsto */
	aAdd(aGrfIPN, {"ISS", nNorIss})
	aAdd(aGrfIPN, {"Impostos Autonônomo", 0})
	aAdd(aGrfIPN, {"ICMS recuperável", nNorICMRec})
	aAdd(aGrfIPN, {"ICMS não recuperável", nNorICMNaoRec})
	aAdd(aGrfIPN, {"PIS/COFINS recuperável", nNorPisRec + nNorCofRec})
	aAdd(aGrfIPN, {"PIS/COFINS não recuperável", nNorPisNaoRec + nNorCofNaoRec})
	aAdd(aGrfIPN, {"Despesa sem impostos", nTotDesp - ;
									    (nNorIss + nNorICMRec + ;
									     nNorICMNaoRec + nNorPisRec +;
									     nNorCofRec + nNorPisNaoRec +;
									     nNorCofNaoRec)})
	
	nPreNor := nTotDesp
	nPreTot := nTotFret

	nTotFret		:= 0
	nTotDesp		:= 0
	nNorIss			:= 0
	nNorICMRec		:= 0
	nNorICMNaoRec 	:= 0
	nNorPisRec 		:= 0
	nNorCofRec		:= 0
	nNorPisNaoRec 	:= 0
	nNorCofNaoRec 	:= 0
	nTotReent		:= 0
	nTotDevol		:= 0
	nTotServ		:= 0
	nTotIss			:= 0
	nTotICMRec		:= 0
	nTotICMNaoRec	:= 0
	nTotPisRec		:= 0 
	nTotCofRec		:= 0
	nTotPisNaoRec	:= 0
	nTotCofNaoRec	:= 0
	nAutIss			:= 0
	nAutIrrf		:= 0
	nAutInAu		:= 0
	nAutInEm		:= 0
	nAutSest 		:= 0

	cAliReDF := GetNextAlias()

	BeginSQL Alias cAliReDF 
		SELECT GW3.GW3_TPDF,
			   GW3.GW3_CRDICM,
			   GW3.GW3_CRDPC,
			   SUM(GWM.GWM_VLFRET) GWM_VLFRET,
			   SUM(GWM.GWM_VLISS) GWM_VLISS,
			   SUM(GWM.GWM_VLICMS) GWM_VLICMS,
			   SUM(GWM.GWM_VLPIS) GWM_VLPIS,
			   SUM(GWM.GWM_VLCOFI) GWM_VLCOFI
		FROM %Table:GWM% GWM
		INNER JOIN %Table:GW3% GW3
		ON GW3.GW3_FILIAL = GWM.GWM_FILIAL
		AND GW3.GW3_CDESP = GWM.GWM_CDESP
		AND GW3.GW3_EMISDF = GWM.GWM_CDTRP
		AND GW3.GW3_SERDF = GWM.GWM_SERDOC
		AND GW3.GW3_NRDF = GWM.GWM_NRDOC
		AND GW3.GW3_DTEMIS = GWM.GWM_DTEMIS
		AND GW3.%NotDel%
		INNER JOIN %Table:GW1% GW1
		ON GW1.GW1_FILIAL = GWM.GWM_FILIAL
		AND GW1.GW1_CDTPDC = GWM.GWM_CDTPDC
		AND GW1.GW1_EMISDC = GWM.GWM_EMISDC
		AND GW1.GW1_SERDC = GWM.GWM_SERDC
		AND GW1.GW1_NRDC = GWM.GWM_NRDC
		//AND GW1.GW1_DTEMIS = GWM.GWM_DTEMDC
		AND GW1.%NotDel%
		WHERE GWM.GWM_TPDOC = '2'
		AND GWM.%NotDel%
		%Exp:cFiltro%
		GROUP BY GW3.GW3_TPDF, GW3.GW3_CRDICM, GW3.GW3_CRDPC
		ORDER BY GW3.GW3_TPDF, GW3.GW3_CRDICM, GW3.GW3_CRDPC
	EndSQL

	(cAliReDF)->(dbGoTop())

	While (cAliReDF)->(!Eof())
		nTotFret += (cAliReDF)->GWM_VLFRET

		If (cAliReDF)->GW3_TPDF $ '1236'
			nTotDesp += (cAliReDF)->GWM_VLFRET
			nNorIss  += (cAliReDF)->GWM_VLISS

			If (cAliReDF)->GW3_CRDICM == '1'
				nNorICMRec += (cAliReDF)->GWM_VLICMS
			EndIf

			If (cAliReDF)->GW3_CRDICM == '2'
				nNorICMNaoRec += (cAliReDF)->GWM_VLICMS
			EndIf

			If (cAliReDF)->GW3_CRDPC == '1'
				nNorPisRec += (cAliReDF)->GWM_VLPIS
				nNorCofRec += (cAliReDF)->GWM_VLCOFI
			EndIf

			If (cAliReDF)->GW3_CRDPC == '2'
				nNorPisNaoRec += (cAliReDF)->GWM_VLPIS
				nNorCofNaoRec += (cAliReDF)->GWM_VLCOFI
			EndIf
		EndIf

		If (cAliReDF)->GW3_TPDF == '4'
			nTotReent += (cAliReDF)->GWM_VLFRET
		EndIf
		
		If (cAliReDF)->GW3_TPDF == '5'
			nTotDevol += (cAliReDF)->GWM_VLFRET
		EndIf

		If (cAliReDF)->GW3_TPDF == '7'
			nTotServ += (cAliReDF)->GWM_VLFRET
		EndIf

		nTotIss += (cAliReDF)->GWM_VLISS

		If (cAliReDF)->GW3_CRDICM = '1'
			nTotICMRec += (cAliReDF)->GWM_VLICMS
		EndIf

		If (cAliReDF)->GW3_CRDICM = '2'
			nTotICMNaoRec += (cAliReDF)->GWM_VLICMS
		EndIf

		If (cAliReDF)->GW3_CRDPC == '1'
			nTotPisRec += (cAliReDF)->GWM_VLPIS
			nTotCofRec += (cAliReDF)->GWM_VLCOFI
		EndIf

		If (cAliReDF)->GW3_CRDPC == '2'
			nTotPisNaoRec += (cAliReDF)->GWM_VLPIS
			nTotCofNaoRec += (cAliReDF)->GWM_VLCOFI
		EndIf

		(cAliReDF)->(dbSkip())
	EndDo

	(cAliReDF)->(dbCloseArea())

	cAliReCon := GetNextAlias()

	BeginSQL Alias cAliReCon 
		SELECT SUM(GWM.GWM_VLFRET) GWM_VLFRET,
			   SUM(GWM.GWM_VLISS) GWM_VLISS,
			   SUM(GWM.GWM_VLICMS) GWM_VLICMS,
			   SUM(GWM.GWM_VLPIS) GWM_VLPIS,
			   SUM(GWM.GWM_VLCOFI) GWM_VLCOFI,
			   SUM(GWM.GWM_VLIRRF) GWM_VLIRRF,
			   SUM(GWM.GWM_VLINAU) GWM_VLINAU,
			   SUM(GWM.GWM_VLINEM) GWM_VLINEM,
			   SUM(GWM.GWM_VLSEST) GWM_VLSEST
		FROM %Table:GWM% GWM
		INNER JOIN %Table:GW1% GW1
		ON GW1.GW1_FILIAL = GWM.GWM_FILIAL
		AND GW1.GW1_CDTPDC = GWM.GWM_CDTPDC
		AND GW1.GW1_EMISDC = GWM.GWM_EMISDC
		AND GW1.GW1_SERDC = GWM.GWM_SERDC
		AND GW1.GW1_NRDC = GWM.GWM_NRDC
		AND GW1.GW1_DTEMIS = GWM.GWM_DTEMDC
		AND GW1.%NotDel%
		WHERE GWM.GWM_TPDOC = '3'
		AND GWM.%NotDel%
		%Exp:cFiltro%
	EndSQL

	(cAliReCon)->(dbGoTop())

	While (cAliReCon)->(!Eof())
		nTotFret += (cAliReCon)->GWM_VLFRET
		nTotDesp += (cAliReCon)->GWM_VLFRET
		nTotIss  += (cAliReCon)->GWM_VLISS
		
		nAutIss  += (cAliReCon)->GWM_VLISS
		nAutIrrf += (cAliReCon)->GWM_VLIRRF
		nAutInAu += (cAliReCon)->GWM_VLINAU
		nAutInEm += (cAliReCon)->GWM_VLINEM
		nAutSest += (cAliReCon)->GWM_VLSEST

		(cAliReCon)->(dbSkip())
	EndDo

	(cAliReCon)->(dbCloseArea())

	// Séries Gráficos Frete Normal / Total
	aAdd(aGrfDCTo, {"Realizado", nTotFret})
	aAdd(aGrfDCNo, {"Realizado", nTotDesp})
	
	// Estatísticas Realizado
	aAdd(aStatRea, {"Filial", AllTrim(FWFilialName(,cFil,))})
	aAdd(aStatRea, {"Frete Total", AllTrim(Transform(nTotFret,"@E 99,999,999,999.99"))})
	aAdd(aStatRea, {"ISS do Frete Total", AllTrim(Transform(nTotIss,"@E 99,999,999,999.99"))})
	aAdd(aStatRea, {"ICMS recuperável do Frete Total", AllTrim(Transform(nTotICMRec,"@E 99,999,999,999.99"))})
	aAdd(aStatRea, {"ICMS não recuperável do Frete Total", AllTrim(Transform(nTotICMNaoRec,"@E 99,999,999,999.99"))})
	aAdd(aStatRea, {"PIS/COFINS recuperável do Frete Total", AllTrim(Transform(nTotPisRec + nTotCofRec,"@E 99,999,999,999.99"))})
	aAdd(aStatRea, {"PIS/COFINS não recuperável do Frete Total", AllTrim(Transform(nTotPisNaoRec + nTotCofNaoRec,"@E 99,999,999,999.99"))})
	aAdd(aStatRea, {"ISS Autônomo do Frete Total", AllTrim(Transform(nAutIss,"@E 99,999,999,999.99"))})
	aAdd(aStatRea, {"IRRF do Frete Total", AllTrim(Transform(nAutIrrf,"@E 99,999,999,999.99"))})
	aAdd(aStatRea, {"INSS Autônomo do Frete Total", AllTrim(Transform(nAutInAu,"@E 99,999,999,999.99"))})
	aAdd(aStatRea, {"INSS Empresa do Frete Total", AllTrim(Transform(nAutInEm,"@E 99,999,999,999.99"))})
	aAdd(aStatRea, {"SEST/SENAT do Frete Total", AllTrim(Transform(nAutSest,"@E 99,999,999,999.99"))})
	aAdd(aStatRea, {"Frete Normal", AllTrim(Transform(nTotDesp,"@E 99,999,999,999.99"))})
	aAdd(aStatRea, {"Frete Reentregas", AllTrim(Transform(nTotReent,"@E 99,999,999,999.99"))})
	aAdd(aStatRea, {"Frete Devoluções", AllTrim(Transform(nTotDevol,"@E 99,999,999,999.99"))})
	aAdd(aStatRea, {"Serviços", AllTrim(Transform(nTotServ,"@E 99,999,999,999.99"))})
		
	/* Gráfico pizza - Imposto Frete Total Realizado */
	aAdd(aGrfIRT, {"ISS", nTotIss})
	aAdd(aGrfIRT, {"ICMS recuperável", nTotICMRec})
	aAdd(aGrfIRT, {"Impostos Autonônomo", (nAutIss + nAutIrrf + nAutInAu + nAutInEm + nAutSest)})
	aAdd(aGrfIRT, {"ICMS não recuperável", nTotICMNaoRec})
	aAdd(aGrfIRT, {"PIS/COFINS recuperável", nTotPisRec + nTotCofRec})
	aAdd(aGrfIRT, {"PIS/COFINS não recuperável", nTotPisNaoRec + nTotCofNaoRec})
	aAdd(aGrfIRT, {"Despesa sem impostos", nTotFret - ;
											    (nTotIss + nTotICMRec + ;
											    nTotICMNaoRec + nTotPisRec +;
											    nTotCofRec + nTotPisNaoRec +;
											    nTotCofNaoRec)})
		
	/* Gráfico pizza - Imposto Frete Normal Realizado */
	aAdd(aGrfIRN, {"ISS", nNorIss})
	aAdd(aGrfIRN, {"Impostos Autonônomo", (nAutIss + nAutIrrf + nAutInAu + nAutInEm + nAutSest)})
	aAdd(aGrfIRN, {"ICMS recuperável", nNorICMRec})
	aAdd(aGrfIRN, {"ICMS não recuperável", nNorICMNaoRec})
	aAdd(aGrfIRN, {"PIS/COFINS recuperável", nNorPisRec + nNorCofRec})
	aAdd(aGrfIRN, {"PIS/COFINS não recuperável", nNorPisNaoRec + nNorCofNaoRec})
	aAdd(aGrfIRN, {"Despesa sem impostos", nTotDesp - ;
											    (nNorIss + nNorICMRec + ;
											     nNorICMNaoRec + nNorPisRec +;
											     nNorCofRec + nNorPisNaoRec +;
											     nNorCofNaoRec)})
		
	nReaNor := nTotDesp
	nReaTot := nTotFret
		
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
	cQuery += "	              WHERE (GWM_TPDOC = '2' OR GWM_TPDOC = '3') AND D_E_L_E_T_ = ' ') GWM2 ON GWM2.GWM_FILIAL = GW1.GW1_FILIAL "
	cQuery += "                         AND GWM2.GWM_CDTPDC = GW1.GW1_CDTPDC "
	cQuery += "                         AND GWM2.GWM_EMISDC = GW1.GW1_EMISDC "
	cQuery += "                         AND GWM2.GWM_SERDC  = GW1.GW1_SERDC "
	cQuery += "                         AND GWM2.GWM_NRDC   = GW1.GW1_NRDC "
	cQuery += "	 WHERE GW1.D_E_L_E_T_ = ' '" + cBrwFiltro + CriaQueryCondicao(aFiltrosPR,"")
	
	If lRelac
		cQuery += " AND GWM1.GWM_CDTPDC IS NOT NULL "
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

// 
// Aplica os filtros dos browses nas consultas SQL
// nAba: aba de origem
// 
Function GFEC002FIL(nAba,aParam)
	Local nCont 
	Local cFiltro := ""
	Local lRelac  := .F. // Identifica se é o filtro para mostrar apenas documentos c/ prev e realizado (Aba PxR)
	
	For nCont := 1 To Len(aParam)
	   	If !aParam[nCont][5] .And. !("GFEC002REL()" $ aParam[nCont][2])
	       	If !Empty(cFiltro)
	       		cFiltro := cFiltro + " AND (" +  aParam[nCont][3] + ")"
	       	Else
	       	    cFiltro := " AND (" +  aParam[nCont][3] + ")"
	       	EndIf
		EndIf
		
		If "GFEC002REL()" $ aParam[nCont][2] 
			lRelac := .T.
		EndIf
	Next nCont	
	
	Processa({||AtualizaAba(nAba,cFiltro,lRelac)})
Return .T.

//
// Atualização dos objetos após aplicação de filtros nos browses
//
Static Function AtualizaAba(nAba, cFiltro, lRelac)
	Default lRelac := .F.
	
	Do Case
		Case nAba == 1 // Cálculos de Frete
			CarregaFP(aFiltrosFP,cFiltro)
			
			GFEC001GRA(oGrfTpc,.T.,aGrfTpc)
			GFEC001GRA(oGrfCom,.T.,aGrfCom)
			GFEC001GRA(oGrfCatTrp,.T.,aGrfCatTrp)
			GFEC001GRA(oGrfTpLot,.T.,aGrfTpLot)
			GFEC001GRA(oGrfNeg,.T.,aGrfNeg)
			
		Case nAba == 2 // Documentos de Frete
			CarregaFR(aFiltrosFR,cFiltro)
			
			GFEC001GRA(oGrfTPDF,.T.,aGrfTPDF)
			GFEC001GRA(oGrfCTDF,.T.,aGrfCTDF)
			
		Case nAba == 3 // Contratos com autonomos
			CarregaCON(aFiltrosCON, cFiltro)
			
			GFEC001GRA(oGrfCCon,.T.,aGrfCCon)
			
			oBrowseEst:SetArray(aStat)
			oBrowseEst:UpdateBrowse()
			
		Case nAba == 4 // Previsto x Realizado
			CarregaPR(aFiltrosPR,cFiltro,lRelac)
			
			GFEC001GRA(oGrfDCNo,.T.,aGrfDCNo)
			GFEC001GRA(oGrfDCTo,.T.,aGrfDCTo)
			GFEC001GRA(oGrfImp,.T.,aGrfIPT)
			
			oBrowsePre:SetArray(aStatPre)
			oBrowsePre:UpdateBrowse()
			oBrowseRea:SetArray(aStatRea)
			oBrowseRea:UpdateBrowse()			
	EndCase
Return Nil
