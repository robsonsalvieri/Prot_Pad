#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "WMSA040.CH"

#DEFINE WMSA04001 "WMSA04001"
#DEFINE WMSA04002 "WMSA04002"
#DEFINE WMSA04003 "WMSA04003"

//----------------------------------------------------------
/*/{Protheus.doc} WMSA040 - Cadastro de Zonas de Armazenagem

@author  SIGAWMS
@version P11
@since   25/02/15
/*/
//----------------------------------------------------------
Function WMSA040()
Local oBrowse
	If AMiIn(39,42) // Somente autorizado para OMS e WMS
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias('DC4')         // Alias da tabela utilizada
		oBrowse:SetDescription(STR0006) // Descrição do browse "Cadastro de Zonas de Armazenagem"
		oBrowse:SetMenuDef('WMSA040')   // Nome do fonte onde esta a função MenuDef
		oBrowse:SetAmbiente(.F.)        // Desabilita opção Ambiente do menu Ações Relacionadas
		oBrowse:SetWalkThru(.F.)        // Desabilita opção WalkThru do menu Ações Relacionadas
		oBrowse:Activate()
	EndIf
Return
//----------------------------------------------------------
// Função MenuDef
//----------------------------------------------------------
Static Function MenuDef()
Private aRotina := {}
	
	ADD OPTION aRotina TITLE STR0001 ACTION 'AxPesqui'        OPERATION 1 ACCESS 0 // Pesquisar
	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.WMSA040' OPERATION 2 ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.WMSA040' OPERATION 3 ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.WMSA040' OPERATION 4 ACCESS 0 // Alterar
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.WMSA040' OPERATION 5 ACCESS 0 // Excluir
	// Ponto de entrada utilizado para inserir novas opcoes no array aRotina
	If ExistBlock("DLG040MNU")
		ExecBlock("DLG040MNU",.F.,.F.)
	EndIf
Return aRotina
//----------------------------------------------------------
// Função ModelDef
//----------------------------------------------------------
Static Function ModelDef()
Local oModel   := MPFormModel():New('WMSA040')
Local oStruDC4 := FWFormStruct(1, 'DC4')
	oModel:AddFields('DC4MASTER', /*cOwner*/, oStruDC4)
	// Tratamento para o campo memo virutal
	FWMemoVirtual(oStruDC4, { {'DC4_CODPRO', 'DC4_PROCED'} })
Return oModel
//----------------------------------------------------------
// Função ViewDef
//----------------------------------------------------------
Static Function ViewDef()
Local oModel   := FWLoadModel('WMSA040')
Local oView    := FWFormView():New()
Local oStruDC4 := FWFormStruct(2, 'DC4')
	// O campo código do procedimento não deve aparecer em tela
	oStruDC4:RemoveField("DC4_CODPRO")
	oView:SetModel(oModel)
	oView:AddField('VIEWDC4', oStruDC4, 'DC4MASTER')
Return oView