#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "OFIA471.CH"

/*/{Protheus.doc} OFIA472
	Solicitações e Liberações de Valor Minimo na Saida de Serviços Especializados

	@author Andre Luis Almeida
	@since 29/09/2022
/*/
Function OFIA472()
Local aSize       := FWGetDialogSize( oMainWnd )
Private cCadastro := STR0030 // Solicitações e Liberações de Valor Minimo na Saida de Serviços Especializados
//
DbSelectArea("VRU")
DbSetOrder(3)

oDlgOA472 := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cCadastro, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )

oWorkArea := FWUIWorkArea():New( oDlgOA472 )
oWorkArea:CreateHorizontalBox( "LINE01", 70 )
oWorkArea:SetBoxCols( "LINE01", { "OBJ1" } )
oWorkArea:CreateHorizontalBox( "LINE02", 30 )
oWorkArea:SetBoxCols( "LINE02", { "OBJ2" } )
oWorkArea:Activate()

oBrwVRU := FWMBrowse():New()
oBrwVRU:SetAlias('VRU')
oBrwVRU:SetDescription(cCadastro)
oBrwVRU:SetOwner(oWorkArea:GetPanel("OBJ1"))
oBrwVRU:DisableDetails()
oBrwVRU:DisableLocate()
oBrwVRU:SetFilterDefault( "@ VRU_TIPSOL = '2' " ) // 2 = Valor Minimo
oBrwVRU:AddFilter( STR0032 , "@ VRU_ATIVO = '1'" ,.f.,.t.,) // Registros Ativos
oBrwVRU:AddLegend( 'VRU->VRU_ATIVO == "1" .and. VRU->VRU_STATUS == "0"' , 'BR_BRANCO'   , STR0034+" ( "+STR0033+" )" ) // Solicitação Pendente / Ativo
oBrwVRU:AddLegend( 'VRU->VRU_ATIVO == "1" .and. VRU->VRU_STATUS == "1"' , 'BR_VERDE'    , STR0035+" ( "+STR0033+" )" ) // Solicitação Aprovada / Ativo
oBrwVRU:AddLegend( 'VRU->VRU_ATIVO == "1" .and. VRU->VRU_STATUS == "2"' , 'BR_VERMELHO' , STR0036+" ( "+STR0033+" )" ) // Solicitação Reprovada / Ativo
oBrwVRU:AddLegend( 'VRU->VRU_ATIVO == "0"' , 'BR_PRETO' , STR0037 ) // Registros Cancelados
oBrwVRU:SetAmbiente(.F.)
oBrwVRU:SetWalkthru(.F.)
oBrwVRU:SetUseFilter()
oBrwVRU:lOptionReport := .f.
oBrwVRU:ForceQuitButton()
oBrwVRU:Activate()

oBrwVRR := FWMBrowse():New()
oBrwVRR:SetAlias('VRR')
oBrwVRR:SetDescription(STR0038) // Saida relacionada
oBrwVRR:SetOwner(oWorkArea:GetPanel("OBJ2"))
oBrwVRR:SetMenuDef( '' )
oBrwVRR:DisableDetails()
oBrwVRR:DisableLocate()
oBrwVRR:AddButton(STR0039,{ || OA4710031_VisualizarSaida() } ) // Visualizar Saida
oBrwVRR:AddButton(STR0046,{ || OA4720011_VisualizaValorMinimo() } ) // Visualizar Valor Desejado x Valor Minimo da Saida
oBrwVRR:AddLegend( 'VRR->VRR_STATUS == "0"' , 'BR_BRANCO'   , STR0040 ,,.f. ) // Saida Digitada
oBrwVRR:AddLegend( 'VRR->VRR_STATUS == "3"' , 'BR_LARANJA'  , STR0041 ,,.f. ) // Pendências - Aguadando Liberação
oBrwVRR:AddLegend( 'VRR->VRR_STATUS == "5"' , 'BR_MARROM'   , STR0042 ,,.f. ) // Liberação de Pendências Reprovada
oBrwVRR:AddLegend( 'VRR->VRR_STATUS == "4"' , 'BR_AZUL'     , STR0043 ,,.f. ) // Liberado para Efetivar Saida
oBrwVRR:AddLegend( 'VRR->VRR_STATUS == "1"' , 'BR_VERDE'    , STR0044 ,,.f. ) // Saida Efetivada
oBrwVRR:AddLegend( 'VRR->VRR_STATUS == "2"' , 'BR_VERMELHO' , STR0045 ,,.f. ) // Saida Cancelada
oBrwVRR:DisableConfig()
oBrwVRR:DisableSeek()
oBrwVRR:SetAmbiente(.F.)
oBrwVRR:SetWalkthru(.F.)
oBrwVRR:SetUseFilter(.f.)
oBrwVRR:lOptionReport := .f.
oBrwVRR:Activate()

oRelac:= FWBrwRelation():New()
oRelac:AddRelation( oBrwVRU , oBrwVRR , {{ "VRR_FILIAL", "VRU_FILIAL" }, { "VRR_CODIGO", "VRU_CODVRR" } })
oRelac:Activate()

oDlgOA472:Activate( , , , , , , ) //ativa a janela

Return

Static Function MenuDef()

	Local aRotina := {}
	ADD OPTION aRotina TITLE STR0049 ACTION 'VIEWDEF.OFIA471' OPERATION 2 ACCESS 0 // Visualizar Solicitação
	ADD OPTION aRotina TITLE STR0050 ACTION 'OA4710021_AprovarReprovarSolicitacao("1")' OPERATION 4 ACCESS 0 // Aprovar
	ADD OPTION aRotina TITLE STR0051 ACTION 'OA4710021_AprovarReprovarSolicitacao("2")' OPERATION 4 ACCESS 0 // Reprovar

Return aRotina

/*/{Protheus.doc} OA4720011_VisualizaValorMinimo
Visualiza Valor Desejado x Valor Minimo dos Servicos Especializados

@author Andre Luis Almeida
@since 04/10/2022
@type function
/*/
Function OA4720011_VisualizaValorMinimo()
Local aVlrMin := {}
Local nVlrMin := 0
VRR->(DbSetOrder(1)) // VRR_FILIAL+VRR_CODIGO
VRR->(DbSeek(VRU->VRU_FILIAL+VRU->VRU_CODVRR))
VRS->(DbSetOrder(2)) // VRS_FILIAL+VRS_CODVRR
If VRS->(DbSeek(VRR->VRR_FILIAL+VRR->VRR_CODIGO))
	Do While !VRS->(Eof()) .and. VRS->VRS_FILIAL == VRR->VRR_FILIAL .and. VRS->VRS_CODVRR == VRR->VRR_CODIGO
		VPX->(DbSetOrder(1))
		VPX->(DbSeek(xFilial("VPX")+VRS->VRS_SERINT))
		nVlrMin := IIf( VPX->VPX_VLRMIN > 0 , VPX->VPX_VLRMIN , OA3800041_Valor( "2" , VPX->VPX_SERINT , VPX->VPX_TIPSER , VPX->VPX_GRUSER , VRR->VRR_CODCLI , VRR->VRR_LOJCLI , VPX->VPX_CUSMED ) ) // Retorna o Valor Minimo do Serviço
		aAdd(aVlrMin,{	( nVlrMin <= ( VRS->VRS_VLRTOT / VRS->VRS_QTDSER ) ) ,;
						VPX->VPX_GRUSER ,;
						VPX->VPX_CODSER ,;
						VPX->VPX_DESSER ,;
						VPX->VPX_TIPSER ,;
						nVlrMin ,;
						( VRS->VRS_VLRTOT / VRS->VRS_QTDSER ) ,;
						VRS->VRS_QTDSER ,;
						VRS->VRS_VLRTOT })
		VRS->(DbSkip())
	EndDo
	OA4710041_TelaPendencias( {} , aVlrMin , .f. ) // Apenas Visualiza as Pendencias na Tela de Solicitar Liberacao
EndIf
Return