#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "OFIA477.CH"

/*/{Protheus.doc} OFIA477
	"Solicitações de Liberações de Limite de Crédito e Valor Minimo na Saida de Serviços Especializados"                                                                                                                                                                                                                                                                                                                                                                                                                

	@author João Félix
	@since 04/04/2025
/*/
Function OFIA477()
Local aSize       := FWGetDialogSize( oMainWnd )
Private cCadastro := STR0001 // "Solicitações de Liberações de Limite de Crédito e Valor Minimo na Saida de Serviços Especializados"                                                                                                                                                                                                                                                                                                                                                                                                                
//	
DbSelectArea("VRU")
DbSetOrder(3)

oDlgOA477 := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cCadastro, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )


oBrwVRU := FWMBrowse():New()
oBrwVRU:SetAlias('VRU')
oBrwVRU:SetDescription(cCadastro)
oBrwVRU:SetOwner(oDlgOA477)
oBrwVRU:SetMenuDef( '' )
oBrwVRU:DisableDetails()
oBrwVRU:SetFilterDefault( "@ VRU_USRSOL = '"+__cUserId+"' AND VRU_STATUS = '0' AND VRU_ATIVO = '1'" ) // Filtro por usuário logado, status de liberação pendente e ativo 
oBrwVRU:AddButton(STR0002,{|| OA477001I_ReprovarSolicitacao()})// Cancelar solicitação
oBrwVRU:AddButton(STR0007,{|| OA4710031_VisualizarSaida() } )// Visualizar
oBrwVRU:AddLegend( 'VRU_TIPSOL == "2"' , 'BR_LARANJA'   , STR0003) // Solicitação de valor mínimo
oBrwVRU:AddLegend( 'VRU_TIPSOL == "1"' , 'BR_AZUL'      , STR0004 ) // Solicitação de limite de crédito 
oBrwVRU:lOptionReport := .f.
oBrwVRU:ForceQuitButton()
oBrwVRU:Activate()

oDlgOA477:Activate( , , , , , , ) //ativa a janela
Return

/*/{Protheus.doc} OA477001I_ReprovarSolicitacao
	Função para permitir o usúario voltar o registro para status de digitado 
	@type  Function
	@author João félix
	@since 04/04/2025
	/*/
Function OA477001I_ReprovarSolicitacao()
IF MsgNoYes(STR0005,STR0006)// Deseja cancelar a solicitação? / Atenção                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
	DbSelectArea("VRR")
	DbSetOrder(1)
	DbSeek(VRU->VRU_FILIAL + VRU->VRU_CODVRR)

	OA4710051_DesativarSolicitacoes( VRR->VRR_FILIAL , VRR->VRR_CODIGO , 0 ) // Marcar 0=NAO ATIVO para todas as Solicitações da Saida VRR
	OA4700011_GravaStatusSaida( VRR->VRR_CODIGO , "0" ) // Mudar Status para 0=Saida Digitada

	oBrwVRU:Refresh()
EndiF
Return 