#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'WMSA050.CH'

#DEFINE WMSA05001 "WMSA05001"
#DEFINE WMSA05002 "WMSA05002"
#DEFINE WMSA05003 "WMSA05003"
#DEFINE WMSA05004 "WMSA05004"

//----------------------------------------------------------
/*/{Protheus.doc} WMSA050 - Cadastro de Estruturas Físicas

@author  SIGAWMS
@version P11
@since   25/02/15
/*/
//----------------------------------------------------------
Function WMSA050()
Local oBrowse
	If AMiIn(39,42) // Somente autorizado para OMS e WMS
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias('DC8')         // Alias da tabela utilizada
		oBrowse:SetDescription(STR0006) // Descrição do browse "Cadastro de Estruturas Físicas"
		oBrowse:SetMenuDef('WMSA050')   // Nome do fonte onde esta a função MenuDef
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

	ADD OPTION aRotina TITLE STR0001 ACTION 'AxPesqui'        OPERATION 1 ACCESS 0 //Pesquisar
	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.WMSA050' OPERATION 2 ACCESS 0 //Visualizar
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.WMSA050' OPERATION 3 ACCESS 0 //Incluir
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.WMSA050' OPERATION 4 ACCESS 0 //Alterar
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.WMSA050' OPERATION 5 ACCESS 0 //Excluir
	//Ponto de entrada utilizado para inserir novas opções no array aRotina
	If ExistBlock("DLG050MNU")
		ExecBlock("DLG050MNU",.F.,.F.)
	EndIf
Return aRotina
//----------------------------------------------------------
// Função ModelDef
//----------------------------------------------------------
Static Function ModelDef()
Local oModel   := MPFormModel():New('WMSA050')
Local oStruDC8 := FWFormStruct(1, 'DC8')
	oModel:AddFields('DC8MASTER', /*cOwner*/, oStruDC8)
Return oModel
//----------------------------------------------------------
// Função ViewDef
//----------------------------------------------------------
Static Function ViewDef()
Local oModel   := FWLoadModel('WMSA050')
Local oView    := FWFormView():New()
Local oStruDC8 := FWFormStruct(2, 'DC8')
Local lWmsNew  := SuperGetMv("MV_WMSNEW",.F.,.F.)

	If !lWmsNew .And. WmsX312120("DC8","DC8_NRUNIT") 
		oStruDC8:RemoveField('DC8_NRUNIT')
	EndIf
	oView:SetModel(oModel)
	oView:AddField('VIEWDC8', oStruDC8, 'DC8MASTER')
Return oView