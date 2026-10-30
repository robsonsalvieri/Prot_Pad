#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'WMSA130.CH'

#DEFINE WMSA13001 "WMSA13001"

//----------------------------------------------------------
/*/{Protheus.doc} WMSA130 - Recursos Humanos

@author  SIGAWMS
@version P11
@since   03/03/15
/*/
//----------------------------------------------------------
Function WMSA130()
Local oBrowse

	If AMiIn(39,42) // Somente autorizado para OMS e WMS
		Pergunte('DLA130',.F.)
		oBrowse := FWMBrowse():New()
		If MV_PAR01 == 1
			oBrowse:SetAlias('DCD') // Apresenta as informações no browse por recurso humano
		Else
			oBrowse:SetAlias('DCI') // Apresenta as informações no browse por função
		EndIf

		oBrowse:SetDescription(STR0001)               // Descrição do browse "Recursos Humanos"
		oBrowse:SetMenuDef('WMSA130')                 // Nome do fonte onde esta a função MenuDef
		oBrowse:SetParam({|| Pergunte('DLA130',.T.)}) // Definição da função chamada ao pressionar tecla F12
		oBrowse:SetAmbiente(.F.)                      // Desabilita opção Ambiente do menu Ações Relacionadas
		oBrowse:SetWalkThru(.F.)                      // Desabilita opção WalkThru do menu Ações Relacionadas
		oBrowse:Activate()
	EndIf
Return
//----------------------------------------------------------
// Função MenuDef
//----------------------------------------------------------
Static Function MenuDef()
Private aRotina := {}

	ADD OPTION aRotina TITLE STR0008 ACTION 'AxPesqui'        OPERATION 1 ACCESS 0 // Pesquisar
	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.WMSA130' OPERATION 2 ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.WMSA130' OPERATION 3 ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.WMSA130' OPERATION 4 ACCESS 0 // Alterar
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.WMSA130' OPERATION 5 ACCESS 0 // Excluir

	//Ponto de entrada utilizado para inserir novas opções no array aRotina
	If ExistBlock("DLG130MNU")
		ExecBlock("DLG130MNU",.F.,.F.)
	EndIf
Return(aRotina)
//----------------------------------------------------------
// Função ModelDef
//----------------------------------------------------------
Static Function ModelDef()
Local oModel   := MPFormModel():New('WMSA130')
Local oStruDCD := FWFormStruct(1,'DCD')
Local oStruDCI := FWFormStruct(1,'DCI')
	
	oStruDCD:SetProperty('DCD_CODFUN', MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID,'NaoVazio() .And. ExistChav("DCD",M->DCD_CODFUN,1) .And. WMS130VFld(A,B,C)'))
	
	oModel:SetDescription(STR0001) // Recursos Humanos
	// Adicionando ao modelo um componente de formulário
	oModel:AddFields('DCDMASTER', /*cOwner*/, oStruDCD)
	// Remove obrigatoriedade do campo, pois ele será preenchido automaticamente no commit
	oStruDCI:SetProperty("DCI_CODFUN",MODEL_FIELD_OBRIGAT,.F.)
	// Adicionando ao modelo um componente de grid
	oModel:AddGrid('DCIDETAIL', 'DCDMASTER', oStruDCI)
	// Criação de relação entre as entidades do modelo
	oModel:SetRelation('DCIDETAIL', { { 'DCI_FILIAL', 'xFilial( "DCI" )' }, { 'DCI_CODFUN', 'DCD_CODFUN' } }, DCI->( IndexKey( 1 ) ) )
	// Define validação de linha duplicada para o grid
	oModel:GetModel('DCIDETAIL'):SetUniqueLine({'DCI_FUNCAO'})
Return oModel
//----------------------------------------------------------
// Função ViewDef
//----------------------------------------------------------
Static Function ViewDef()
Local oModel   := FWLoadModel('WMSA130')
Local oView    := FWFormView():New()
Local oStruDCD := FWFormStruct(2,'DCD')
Local oStruDCI := FWFormStruct(2,'DCI')
	oView:SetModel(oModel)
	// Criando o componente de formulário na interface
	oView:AddField('VIEWDCD', oStruDCD, 'DCDMASTER')
	//Remove campos repetidos
	oStruDCI:RemoveField('DCI_CODFUN')
	oStruDCI:RemoveField('DCI_NOMFUN')
	// Criando o componente de grid na interface
	oView:AddGrid('VIEWDCI', oStruDCI, 'DCIDETAIL')
	// Criação dos conteiners para exibição dos dados na interface
	oView:CreateHorizontalBox('SUPERIOR', 20)
	oView:CreateHorizontalBox('INFERIOR', 80)
	// Relacionando o componente da interface
	oView:SetOwnerView('VIEWDCD', 'SUPERIOR')
	oView:SetOwnerView('VIEWDCI', 'INFERIOR')
Return oView
//----------------------------------------------------------
// Função de validação dos campos
//----------------------------------------------------------
Function WMS130VFld(oModel,cField,xValue)
Local aAreaAnt := GetArea()
Local lRet     := .T.
	If cField == 'DCD_CODFUN'
		PswOrder(1)
		If !PswSeek(xValue,.T.)
			oModel:GetModel():SetErrorMessage(oModel:GetId(),cField,,,WMSA13001,STR0006,STR0007) // Código de usuário não existe. // Verifique o código informado.
			lRet := .F.
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return lRet
