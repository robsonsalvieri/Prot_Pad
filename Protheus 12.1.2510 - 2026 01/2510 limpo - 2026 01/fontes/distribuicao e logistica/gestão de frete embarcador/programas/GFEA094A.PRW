#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
 
Function GFEA094A()
	Local aTFolder  := IIF( GFEA105ATV(), { 'Lotes de Provisão','Lançamentos Contábeis', 'Lotes de Estorno' }, { 'Lotes de Provisão', 'Lançamentos Contábeis'} )
	Local aCoors 	:= FWGetDialogSize(oMainWnd)
	Local aAreaGWM 	:= GWM->(GetArea())
	Local aAreaGWA 	:= GWA->(GetArea())
	Local aAreaGXE 	:= GXE->(GetArea())
	Local aAreaGXN  := IIF( GFEA105ATV(),GXN->(GetArea()),"" )
	Private oDlg2	
	Private oPanelUp
	Private oPanelDown
	Private oFolder
	Private oBrowseGWA
	Private oBrowseGXE
	Private oBrowseGWM
	Private oBrowseGXN
	
	Define MsDialog oDlg2 Title 'Provisão' From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
	
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDlg2, .F., .T.)
	
	oFWLayer:AddLine('UP',40,.F.)
	oFWLayer:AddLine('DOWN',60,.F.)
	oFWLayer:AddCollumn('ALL',100,.T.,'UP')
	oFWLayer:AddCollumn('ALL',100,.T.,'DOWN')
	
	oPanelUp   := oFWLayer:GetColPanel('ALL','UP')
	oPanelDown := oFWLayer:GetColPanel('ALL','DOWN')
	
	oTFolder := TFolder():New( 0,0,aTFolder,,oPanelDown,,,,.T.,,260,184 )
    oTFolder:Align := CONTROL_ALIGN_ALLCLIENT
	
	oDlg2:Activate(,,,.T.,,,{||RptStatus({||Iniciar()}, "Carregando", "Aguarde, carregando dados...")}) 
	RestArea(aAreaGWM)
	RestArea(aAreaGWA)
	RestArea(aAreaGXE)
	IF GFEA105ATV()
		RestArea(aAreaGXN)
	EndIf
Return 

Static Function Iniciar()

	IF GFEA105ATV()
		dbSelectArea("GXN")
		GXN->(dbSetOrder(1))
		
		oBrowseGXN:= FWMBrowse():New()
		oBrowseGXN:SetAlias("GXN")
		oBrowseGXN:SetDescription("")
		oBrowseGXN:SetMenuDef("")
		oBrowseGXN:SetOwner(oTFolder:aDialogs[3])
		oBrowseGXN:DisableDetails()
		oBrowseGXN:SetProfileID("4")
		oBrowseGXN:SetFixedBrowse(.T.)
		oBrowseGXN:AddButton("Sair", {|| oDlg2:End() },,2,,.F.)
		oBrowseGXN:AddButton("Visualizar", {|| FwExecView("Visualizar",'GFEC105',,,{||.T.}) },,2,,.F.)
		oBrowseGXN:SetAmbiente(.F.)
		oBrowseGXN:SetWalkthru(.F.)
		oBrowseGXN:Activate()
	EndIf
	
	dbSelectArea("GXE")
	GXE->(dbSetOrder(1))
	
	oBrowseGXE:= FWMBrowse():New()
	oBrowseGXE:SetAlias("GXE")
	oBrowseGXE:SetDescription("")
	oBrowseGXE:SetMenuDef("")
	oBrowseGXE:SetOwner(oTFolder:aDialogs[1])
	oBrowseGXE:DisableDetails()
	oBrowseGXE:SetProfileID("3")
	oBrowseGXE:SetFixedBrowse(.T.)
	oBrowseGXE:AddButton("Sair", {|| oDlg2:End() },,2,,.F.)
	oBrowseGXE:AddButton("Visualizar", {|| FwExecView("Visualizar",'GFEA096',,,{||.T.}) },,2,,.F.)
	oBrowseGXE:SetAmbiente(.F.)
	oBrowseGXE:SetWalkthru(.F.)
	oBrowseGXE:Activate()
	
	dbSelectArea("GWA")
	GWA->(dbSetOrder(1))
	
	oBrowseGWA:= FWMBrowse():New()
	oBrowseGWA:SetAlias("GWA")
	oBrowseGWA:SetMenuDef("")
	oBrowseGWA:SetDescription("")
	oBrowseGWA:SetOwner(oTFolder:aDialogs[2])
	oBrowseGWA:DisableDetails()
	oBrowseGWA:SetProfileID("2")
	oBrowseGWA:SetFixedBrowse(.T.)
	oBrowseGWA:AddButton("Sair", {|| oDlg2:End() },,2,,.F.)
	oBrowseGWA:SetAmbiente(.F.)
	oBrowseGWA:SetWalkthru(.F.)
	oBrowseGWA:Activate()
	
	dbSelectArea("GWM")
	GWM->(dbSetOrder(2))
	
	oBrowseGWM:= FWMBrowse():New()
	oBrowseGWM:SetAlias("GWM")
	oBrowseGWM:SetDescription("Rateios de Frete")
	oBrowseGWM:SetMenuDef("")
	oBrowseGWM:SetOwner(oPanelUp)
	oBrowseGWM:DisableDetails()
	oBrowseGWM:SetProfileID("1")
	oBrowseGWM:SetFixedBrowse(.T.)
	oBrowseGWM:SetFilterDefault("GWM_TPDOC $ '1;4' .And. GWM_FILIAL == GW1->GW1_FILIAL .And. GWM_CDTPDC == GW1->GW1_CDTPDC .And. GWM_EMISDC == GW1->GW1_EMISDC .And. GWM_SERDC == GW1->GW1_SERDC .And. GWM_NRDC == GW1->GW1_NRDC")
	oBrowseGWM:SetAmbiente(.F.)
	oBrowseGWM:SetWalkthru(.F.)
	oBrowseGWM:Activate()
	
	oBrowseGWM:DelColumn(7)
	oBrowseGWM:DelColumn(8)
	oBrowseGWM:DelColumn(9)
	oBrowseGWM:DelColumn(10)
	oBrowseGWM:UpdateBrowse()
	
	oRelation := FWBrwRelation():New()
	oRelation:AddRelation(oBrowseGWM,oBrowseGWA,{{'GWA_FILIAL','GWM_FILIAL'},;
														{'GWA_TPDOC','GWM_TPDOC'},;
														{'GWA_CDESP','GWM_CDESP'},;
														{"GWA_CDEMIT",'GWM_CDTRP'},;
														{"GWA_SERIE",'GWM_SERDOC'},;
														{'GWA_NRDOC','GWM_NRDOC'},;
														{'DTOS(GWA_DTEMIS)','DTOS(GWM_DTEMIS)'}})
														
	
	oRelation:Activate()
	// Utiliza um relacionamento atráves dos códigos de lot(CODLOT) do Lançamentos Contábeis(GWA) relacionados aos rateio de frete, atravessando o cálculo(GWF)
	oRelation2 := FWBrwRelation():New()
	oRelation2:AddRelation(oBrowseGWM,oBrowseGXE,{{'GXE_FILIAL','GWM_FILIAL'},{'GXE_CODLOT','GFEA094AGX(1)','$'}})
	oRelation2:Activate()
	
	If GFEA105ATV()
		oRelation3 := FWBrwRelation():New()
		oRelation3:AddRelation(oBrowseGWM,oBrowseGXN,{{'GXN_FILIAL','GWM_FILIAL'},{'GXN_CODLOT','GFEA094AGX(2)','$'}})
		oRelation3:Activate()
	EndIf
Return

Function GFEA094AGX(nTipo)

	Local cRelacGXE := ""
	
	If nTipo == 1
		oBrowseGXE:SETFILTERDEFAULT("")
	EndIf
	
	If nTipo == 2
		oBrowseGXN:SETFILTERDEFAULT("")
	EndIf

	GWA->(dbSeek(GWM->(GWM_FILIAL+GWM_TPDOC+GWM_CDESP+GWM_CDTRP+GWM_SERDOC+GWM_NRDOC+DTOS(GWM_DTEMIS))))	
	
	While !GWA->(Eof()) .And. GWM->(GWM_FILIAL+GWM_TPDOC+GWM_CDESP+GWM_CDTRP+GWM_SERDOC+GWM_NRDOC+DTOS(GWM_DTEMIS)) == ;
								 GWA->(GWA_FILIAL+GWA_TPDOC+GWA_CDESP+GWA_CDEMIT+GWA_SERIE+GWA_NRDOC+DTOS(GWA_DTEMIS))
		If !Empty(GWA->GWA_CODLOT)
			If At(GWA->GWA_CODLOT,cRelacGXE) == 0
				cRelacGXE += GWA->GWA_CODLOT
			EndIf
		EndIf
		GWA->(dbSkip())
	EndDo
	
Return cRelacGXE