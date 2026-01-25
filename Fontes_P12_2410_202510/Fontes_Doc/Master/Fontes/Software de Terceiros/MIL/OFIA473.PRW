#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "OFIA471.CH"

/*/{Protheus.doc} OFIA473
	Solicitações e Liberações de Limite de Crédito do Cliente na Saida de Serviços Especializados

	@author Andre Luis Almeida
	@since 29/09/2022
/*/
Function OFIA473()
Local aSize       := FWGetDialogSize( oMainWnd )
Private cCadastro := STR0031 // Solicitações e Liberações de Limite de Crédito do Cliente na Saida de Serviços Especializados
//
DbSelectArea("VRU")
DbSetOrder(3)

oDlgOA473 := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cCadastro, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )

oWorkArea := FWUIWorkArea():New( oDlgOA473 )
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
oBrwVRU:SetFilterDefault( "@ VRU_TIPSOL = '1' " ) // 1 = Limite de Crédito do Cliente
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

oDlgOA473:Activate( , , , , , , ) //ativa a janela

Return

Static Function MenuDef()

	Local aRotina := {}
	ADD OPTION aRotina TITLE STR0049 ACTION 'VIEWDEF.OFIA471' OPERATION 2 ACCESS 0 // Visualizar Solicitação
	ADD OPTION aRotina TITLE STR0050 ACTION 'OA4710021_AprovarReprovarSolicitacao("1")' OPERATION 4 ACCESS 0 // Aprovar
	ADD OPTION aRotina TITLE STR0051 ACTION 'OA4710021_AprovarReprovarSolicitacao("2")' OPERATION 4 ACCESS 0 // Reprovar

Return aRotina

/*/{Protheus.doc} OA4730011_VisualizarCliente
Visualizar Cadastro do Cliente (MATA030)

@author Andre Luis Almeida
@since 04/10/2022
@type function
/*/
Function OA4730011_VisualizarCliente()
Private cCadastro := STR0052 // Cadastro do Cliente
VRR->(DbSetOrder(1)) // VRR_FILIAL+VRR_CODIGO
VRR->(DbSeek(VRU->VRU_FILIAL+VRU->VRU_CODVRR))
SA1->(DbSetOrder(1)) // A1_FILIAL+A1_COD+A1_LOJA
If SA1->(DbSeek(xFilial("SA1")+VRR->VRR_CODCLI+VRR->VRR_LOJCLI))
	A030Visual("SA1", SA1->(RecNo()), 2)
EndIf
Return

/*/{Protheus.doc} OA4730021_VisualizarFichaCliente
Visualizar Ficha do Cliente (FINC010)

@author Andre Luis Almeida
@since 04/10/2022
@type function
/*/
Function OA4730021_VisualizarFichaCliente()
Private cCadastro := STR0053 // Posição do Cliente
VRR->(DbSetOrder(1)) // VRR_FILIAL+VRR_CODIGO
VRR->(DbSeek(VRU->VRU_FILIAL+VRU->VRU_CODVRR))
SA1->(DbSetOrder(1)) // A1_FILIAL+A1_COD+A1_LOJA
If SA1->(DbSeek(xFilial("SA1")+VRR->VRR_CODCLI+VRR->VRR_LOJCLI))
	Pergunte("FIC010", .t.)
	Fc010Con("SA1", SA1->(RecNo()), 2)
EndIf
Return