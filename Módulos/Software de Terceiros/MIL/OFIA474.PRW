#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "OFIA471.CH"

/*/{Protheus.doc} OFIA474
	Pendências na Saida de Serviços Especializados

	@author Andre Luis Almeida
	@since 26/10/2022
/*/
Function OFIA474()
Local aSize       := FWGetDialogSize( oMainWnd )
Private cCadastro := STR0054 // Pendências na Saida de Serviços Especializados

oDlgOA474 := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cCadastro, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )

oWorkArea := FWUIWorkArea():New( oDlgOA474 )
oWorkArea:CreateHorizontalBox( "LINE01", 70 )
oWorkArea:SetBoxCols( "LINE01", { "OBJ1" } )
oWorkArea:CreateHorizontalBox( "LINE02", 30 )
oWorkArea:SetBoxCols( "LINE02", { "OBJ2" } )
oWorkArea:Activate()

DbSelectArea("VRU")
DbSetOrder(1)
oBrwVRU := FWMBrowse():New()
oBrwVRU:SetAlias('VRU')
oBrwVRU:SetDescription(cCadastro)
oBrwVRU:SetOwner(oWorkArea:GetPanel("OBJ1"))
oBrwVRU:DisableDetails()
oBrwVRU:DisableLocate()
oBrwVRU:AddFilter( STR0055 , "@ VRU_TIPSOL = '1'" ,.f.,.f.,) // Pendências de Limite de Crédito
oBrwVRU:AddFilter( STR0056 , "@ VRU_TIPSOL = '2'" ,.f.,.f.,) // Pendências de Valor Minimo
oBrwVRU:AddFilter( STR0032 , "@ VRU_ATIVO = '1'" ,.f.,.t.,) // Registros Ativos
oBrwVRU:AddLegend( 'VRU->VRU_ATIVO == "1" .and. VRU->VRU_STATUS == "0"' , 'BR_BRANCO'   , STR0034+" ( "+STR0033+" )" ) // Solicitação Pendente / Ativo
oBrwVRU:AddLegend( 'VRU->VRU_ATIVO == "1" .and. VRU->VRU_STATUS == "1"' , 'BR_VERDE'    , STR0035+" ( "+STR0033+" )" ) // Solicitação Aprovada / Ativo
oBrwVRU:AddLegend( 'VRU->VRU_ATIVO == "1" .and. VRU->VRU_STATUS == "2"' , 'BR_VERMELHO' , STR0036+" ( "+STR0033+" )" ) // Solicitação Reprovada / Ativo
oBrwVRU:AddLegend( 'VRU->VRU_ATIVO == "0"' , 'BR_PRETO' , STR0037 ) // Registros Cancelados
oBrwVRU:SetAmbiente(.F.)
oBrwVRU:SetWalkthru(.F.)
oBrwVRU:SetUseFilter()
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
oBrwVRR:AddButton(STR0047,{ || OA4730011_VisualizarCliente() } ) // Visualizar Cadastro do Cliente
oBrwVRR:AddButton(STR0048,{ || OA4730021_VisualizarFichaCliente() } ) // Visualizar Ficha do Cliente
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

oDlgOA474:Activate( , , , , , , ) //ativa a janela

Return

Static Function MenuDef()

	Local aRotina := {}
	ADD OPTION aRotina TITLE STR0049 ACTION 'VIEWDEF.OFIA471' OPERATION 2 ACCESS 0 // Visualizar Solicitação
	ADD OPTION aRotina TITLE STR0057 ACTION 'VIEWDEF.OFIA471' OPERATION 8 ACCESS 0 // Imprimir

Return aRotina