#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TGVA003.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} TGVA003
	Configurador de campos personalizados, para serem utilizados no
	TOTVS Gestão de Vendas (TGV).

	@author Danilo Salve
	@since 13/04/2021
	@version 12.1.27 ou Superior
/*/
//-------------------------------------------------------------------
Function TGVA003()
	Local oMBrowse 	:= Nil

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias('A1V')
	oMBrowse:SetDescription(STR0001) // Configurador de Campos Personalizados
	oMBrowse:SetCanSaveArea(.T.)
	oMBrowse:SetMenudef('TGVA003')

	//Inclui um totalizador no Browse
	oMBrowse:SetTotalDefault('A1V_FILIAL','COUNT', STR0007) // Total de Registros
	oMBrowse:Activate()
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
	Menu de Cadastros de Campos do Gestão de Vendas

	@author 	Danilo Salve
	@version	12.1.27
	@since		13/04/2021
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0004 	ACTION 'PesqBrw' 			    OPERATION 1 ACCESS 0 // 'Pesquisar'
	ADD OPTION aRotina TITLE STR0005	ACTION 'VIEWDEF.TGVA003' 	OPERATION 2	ACCESS 0 // 'Visualizar'
	ADD OPTION aRotina TITLE STR0008	ACTION 'VIEWDEF.TGVA003' 	OPERATION 3	ACCESS 0 // 'Incluir'
	ADD OPTION aRotina TITLE STR0009	ACTION 'VIEWDEF.TGVA003' 	OPERATION 4	ACCESS 0 // 'Alterar'
	ADD OPTION aRotina TITLE STR0006	ACTION 'VIEWDEF.TGVA003' 	OPERATION 8 ACCESS 0 // 'Imprimir'
Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
    Modelo de dados das Notificações

    @sample		ModelDef()
    @return		ExpO - Objeto MPFormModel
    @author		Danilo Salve / Squad CRM & Faturamento
    @since		13/04/2021
    @version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function ModelDef() as Object
	Local oModel        as Object
	Local oStructA1V    := FWFormStruct(1,'A1V',/*bAvalCampo*/,/*lViewUsado*/)
	Local oStructA1W    := FWFormStruct(1,'A1W',/*bAvalCampo*/,/*lViewUsado*/)

	oModel:= MPFormModel():New('TGVA003',/*bPreValidacao*/,/*bPosValid*/,/*bCommit*/,/*bCancel*/)
	oModel:AddFields('A1VMASTER',/*cOwner*/, oStructA1V,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)
	oModel:AddGrid( 'A1WDETAIL', 'A1VMASTER', oStructA1W )
	oModel:SetDescription(STR0001) //'Schemas'

	oModel:SetRelation( 'A1WDETAIL', { { 'A1W_FILIAL', 'FwxFilial( "A1W" )' }, {'A1W_SCHEMA', 'A1V_CODIGO' } }, A1W->( IndexKey( 1 ) ) )

	oModel:GetModel('A1VMASTER'):SetDescription(STR0002)
	oModel:GetModel('A1WDETAIL'):SetDescription(STR0003)
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
	Interface do modelo de dados de Notificações do Vendedor para localização padrão.

	@author 	Danilo Salve
	@version	12.1.27 ou Superior
	@since		13/04/2021
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oView
	Local oModel 		:= ModelDef()
	Local oStructA1V	:= FWFormStruct(2,'A1V',/*bAvalCampo*/,/*lViewUsado*/)
	Local oStructA1W	:= FWFormStruct(2,'A1W',/*bAvalCampo*/,/*lViewUsado*/)

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('VIEW_A1V', oStructA1V,'A1VMASTER')
	oView:AddGrid( 'VIEW_A1W', oStructA1W, 'A1WDETAIL' )

	oView:CreateHorizontalBox( 'SUPERIOR', 35 )
	oView:CreateHorizontalBox( 'INFERIOR', 65 )

	oView:SetOwnerView( 'VIEW_A1V', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_A1W', 'INFERIOR' )

	oView:AddIncrementField( 'VIEW_A1W', 'A1W_ITEM' )
	oView:EnableTitleView('VIEW_A1W')
Return oView
