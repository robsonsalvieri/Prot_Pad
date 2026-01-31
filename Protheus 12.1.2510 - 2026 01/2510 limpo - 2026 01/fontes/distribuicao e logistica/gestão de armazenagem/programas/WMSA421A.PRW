#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "WMSA421A.CH"

//-----------------------------------
/*/{Protheus.doc} WMSA421A
Monitor Carga x WMS Detalhe

@author Felipe Machado de Oliveira
@version P12
@Since	30/11/12
@obs Monitor Carga x WMS Detalhe
/*/
//-----------------------------------
Static nQtdLibPed := 0
Static nQtdEmpPed := 0
Static nQtdLibIte := 0
Static nQtdEmpIte := 0
Static cSitPed    := "1"
Static cSitItem   := "1"

Function WMSA421A()
Local aCoors    := FWGetDialogSize(oMainWnd)
Local oRelSC9   := Nil
Local oLayer    := Nil
Local oPanelUp  := Nil
Local oPanelDown:= Nil
Local oDlgPrinc := Nil
Local oBrowsePed:= Nil
Local oBrowseIte:= Nil
Local aColsIte  := {}
Local aColsPed  := {}
Local aColsSX3  := {}
Local bKeyF5    := SetKey(VK_F5)

	Define MsDialog oDlgPrinc Title STR0001 From aCoors[1],aCoors[2] To aCoors[3],aCoors[4] Pixel // Monitor Carga vs WMS

	oLayer := FWLayer():New()
	oLayer:Init(oDlgPrinc,.F.,.T.)
	oLayer:AddLine("UP",50,.T.)
	oLayer:AddLine("DOWN",50,.T.)

	oPanelUp := oLayer:GetLinePanel("UP")
	oPanelDown := oLayer:GetLinePanel("DOWN")

	// Colunas da grid superior
	aAdd(aColsPed,{buscarSX3("DAI_COD"   ,,aColsSX3),"DAI_COD"})
	aAdd(aColsPed,{buscarSX3("DAI_PEDIDO",,aColsSX3),"DAI_PEDIDO"})
	aAdd(aColsPed,{buscarSX3("C9_QTDLIB" ,,aColsSX3),{|| nQtdLibPed},"N",aColsSX3[2],2,aColsSX3[4],aColsSX3[3]})
	aAdd(aColsPed,{buscarSX3("DCS_QTSEPA",,aColsSX3),{|| nQtdEmpPed},"N",aColsSX3[2],2,aColsSX3[4],aColsSX3[3]})
	aAdd(aColsPed,{buscarSX3("DC3_PERREP",STR0002,aColsSX3),{|| ((nQtdEmpPed/nQtdLibPed)*100)},"N",aColsSX3[2],2,aColsSX3[4],aColsSX3[3]}) // % Executado
	
	oBrowsePed := FWMBrowse():New()
	oBrowsePed:SetOwner(oPanelUp)
	oBrowsePed:SetAlias('DAI')
	oBrowsePed:SetFields(aColsPed)
	oBrowsePed:SetDescription(STR0003) // Pedido
	oBrowsePed:SetFilterDefault("@"+MontaQuery())
	oBrowsePed:AddLegend({|| WMSA421AMN(2,@cSitPed,@nQtdLibPed,@nQtdEmpPed) == '1'},"RED",STR0004) // Não iniciado
	oBrowsePed:AddLegend({|| cSitPed == '2'},"YELLOW" ,STR0005) // Em andamento
	oBrowsePed:AddLegend({|| cSitPed == '3'},"ORANGE" ,STR0006) // Finalizado
	oBrowsePed:AddLegend({|| cSitPed == '4'},"BLUE"   ,STR0007) // Aguardando faturamento
	oBrowsePed:AddLegend({|| cSitPed == '5'},"GREEN"  ,STR0008) // Faturado
	oBrowsePed:SetMenuDef('')
	oBrowsePed:DisableDetails()
	oBrowsePed:SetFixedBrowse(.T.)
	oBrowsePed:SetAmbiente(.F.)
	oBrowsePed:ForceQuitButton()
	oBrowsePed:DisableConfig()
	oBrowsePed:DisableReport()
	oBrowsePed:SetWalkThru(.F.)
	oBrowsePed:SetProfileID('1')

	// Colunas da grid inferior
	aAdd(aColsIte,{buscarSX3("C9_PEDIDO" ,,aColsSX3),"C9_PEDIDO"})
	aAdd(aColsIte,{buscarSX3("C9_PRODUTO",,aColsSX3),"C9_PRODUTO"})
	aAdd(aColsIte,{buscarSX3("B1_DESC"   ,,aColsSX3),{|| POSICIONE("SB1",1,xFilial("SB1")+SC9->C9_PRODUTO,"SB1->B1_DESC") } ,"C",1,aColsSX3[2],aColsSX3[4],aColsSX3[3]})
	aAdd(aColsIte,{buscarSX3("C9_QTDLIB" ,,aColsSX3),{|| nQtdLibIte},"N",aColsSX3[2],2,aColsSX3[4],aColsSX3[3]})
	aAdd(aColsIte,{buscarSX3("DCS_QTSEPA",,aColsSX3),{|| nQtdEmpIte},"N",aColsSX3[2],2,aColsSX3[4],aColsSX3[3]})
	aAdd(aColsIte,{buscarSX3("DC3_PERREP",STR0002,aColsSX3),{|| ((nQtdEmpIte/nQtdLibIte)*100)},"N",aColsSX3[2],2,aColsSX3[4],aColsSX3[3]}) // % Executado
	
	oBrowseIte := FWMBrowse():New()
	oBrowseIte:SetOwner(oPanelDown)
	oBrowseIte:SetAlias("SC9")
	oBrowseIte:SetFields(aColsIte)
	oBrowseIte:SetOnlyFields({'C9_PEDIDO','C9_PRODUTO'})
	oBrowseIte:AddLegend({|| WMSA421AMN(3,@cSitItem,@nQtdLibIte,@nQtdEmpIte) == '1'},"RED",STR0004) // Não iniciado
	oBrowseIte:AddLegend({|| cSitItem == '2'},"YELLOW" ,STR0005) // Em andamento
	oBrowseIte:AddLegend({|| cSitItem == '3'},"ORANGE" ,STR0006) // Finalizado
	oBrowseIte:AddLegend({|| cSitItem == '4'},"BLUE"   ,STR0007) // Aguardando faturamento
	oBrowseIte:AddLegend({|| cSitItem == '5'},"GREEN"  ,STR0008) // Faturado
	oBrowseIte:SetMenuDef('')
	oBrowseIte:DisableDetails()
	oBrowseIte:SetFixedBrowse(.T.)
	oBrowseIte:SetDescription(STR0009) // Itens do Pedido
	oBrowseIte:SetAmbiente(.F.)
	oBrowseIte:DisableConfig()
	oBrowseIte:DisableReport()
	oBrowseIte:SetWalkThru(.F.)
	oBrowseIte:SetProfileID('2')
	
	oBrowsePed:Activate()
	oBrowseIte:Activate()
		
	oBrowsePed:SetFocus()
	
	// Relacionamento browse Itens com Pedidos
	oRelSC9 := FWBrwRelation():New()
	oRelSC9:AddRelation(oBrowsePed,oBrowseIte,{ {"C9_FILIAL","xFilial('SC9')"},{"C9_CARGA","DAI_COD"},{"C9_SEQCAR","DAI_SEQCAR"},{"C9_PEDIDO","DAI_PEDIDO"} })
	oRelSC9:Activate()

	SetKey(VK_F5 , {||  RefreshBrw(oBrowsePed, oBrowseIte)})
	
	Activate MsDialog oDlgPrinc Center

	SetKey(VK_F5 , bKeyF5)
Return
//-----------------------------------
/*/{Protheus.doc} RefreshBrw
Atualiza Browses

@author Felipe Machado de Oliveira
@version P12
@Since	03/12/12
@obs Atualiza Browses
/*/
//-----------------------------------
Static Function RefreshBrw(oBrowsePed, oBrowseIte)
	oBrowsePed:Refresh()
	oBrowseIte:Refresh()
Return .T.
/*---------------------------------------------------------------------------
---MontaQuery
---Retorna expressao do filtro
---Alexsander
---------------------------------------------------------------------------*/
Static Function MontaQuery()
Local cQuery := ''
	cQuery :=    " DAI_COD = '"+DAK->DAK_COD+"'"
	cQuery +=    " AND DAI_SEQCAR = '"+DAK->DAK_SEQCAR+"'"
Return(cQuery)

Static Function WMSA421AMN(cOpcao,cSituacao,nQtdLib,nQtdEmp)
	cSituacao := WMSA421MNT(cOpcao,@nQtdLib,@nQtdEmp)
Return cSituacao