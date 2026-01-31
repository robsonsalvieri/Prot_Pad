#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "VEIA072.CH"

/*/{Protheus.doc} VEIA072
	Controle de Atualização do veículo

	@author rubens.takahashi
	@since 19/04/2022
	@version 1.0
	@return ${return}, ${return_description}
	@type function
/*/
Function VEIA072()
	Local oBrowse

	oBrowse := BrowseDef()
	oBrowse:Activate()
Return


Static Function ModelDef()
	local oModel
	Local oStruVK9 := FWFormStruct( 1, 'VK9' )
	Local oStruVW0 := FWFormStruct( 1, 'VW0' )

	VA0720023_AddTrigger(@oStruVK9)

	VA0710023_AddTrigger(@oStruVW0)

	//oStruVK9:SetProperty('VK9_CODVW0',MODEL_FIELD_OBRIGAT,.f.)

	oStruVW0:SetProperty('VW0_CODIGO', MODEL_FIELD_INIT , FWBuildFeature( STRUCT_FEATURE_INIPAD , ' ' ))
	oStruVW0:SetProperty('VW0_USERID', MODEL_FIELD_INIT , FWBuildFeature( STRUCT_FEATURE_INIPAD , ' ' ))
	oStruVW0:SetProperty('VW0_DATREG', MODEL_FIELD_INIT , FWBuildFeature( STRUCT_FEATURE_INIPAD , ' ' ))
	oStruVW0:SetProperty('VW0_HORREG', MODEL_FIELD_INIT , FWBuildFeature( STRUCT_FEATURE_INIPAD , ' ' ))

	// oStruVK9:SetProperty('VK9_USERID', MODEL_FIELD_INIT , FWBuildFeature( STRUCT_FEATURE_INIPAD , '__cUserId' ))
	// oStruVK9:SetProperty('VK9_DATREG', MODEL_FIELD_INIT , FWBuildFeature( STRUCT_FEATURE_INIPAD , 'Date()' ))
	// oStruVK9:SetProperty('VK9_HORREG', MODEL_FIELD_INIT , FWBuildFeature( STRUCT_FEATURE_INIPAD , 'Val(StrTran(Time(),":",""))' ))

	oStruVW0:SetProperty( '*' , MODEL_FIELD_OBRIGAT, .f.)

	oModel := MPFormModel():New('VEIA072')
	oModel:SetDescription( 'LOG' )

	oModel:AddFields('MODEL_VK9', /*cOwner*/ , oStruVK9 , /* <bPre > */ , /* <bPost > */ , /* <bLoad> */ )
	oModel:GetModel( 'MODEL_VK9' ):SetDescription(STR0002)	// 'Log Atualização de Equipment'

	oModel:AddFields('MODEL_VW0', 'MODEL_VK9' , oStruVW0 , /* <bPre > */ , /* <bPost > */ , /* <bLoad> */ )
	oModel:GetModel( 'MODEL_VW0' ):SetDescription(STR0003)	// 'Log Atualização do Veículo'

	//oModel:SetRelation('MODEL_xx', { { 'VW0_ZZ' , 'VK9_FILIAL' } , { 'VW0_CODVK9' , 'VK9_CODIGO' } } , 'VW0_FILIAL+VW0_CODIGO' )
	oModel:SetRelation( 'MODEL_VW0', { { 'VW0_FILIAL', 'xFilial( "VW0" )' }, { 'VW0_CODVK9', 'VK9_CODIGO' } }, VW0->( IndexKey( 4 ) ) )

	//
	oModel:GetModel( 'MODEL_VW0' ):SetOptional( .T. )
	//
	oModel:InstallEvent("PADRAO",, VEIA072EVDEF():New())
	//oModel:InstallEvent("LOGEV",, MVCLogEv():New("VEIA072"))

	//oModel:InstallEvent("PADRAO",, VEIA071EVDEF():New())
	//oModel:InstallEvent("LOGEV",, MVCLogEv():New("VEIA071"))
	
Return oModel

Function VA0720023_AddTrigger(oStruVK9)

	AddTrigger( oStruVK9 , FwStruTrigger("VK9_CHASSI","VK9_CHAINT","VV1->VV1_CHAINT",.T.,"VV1",2,"xFilial('VV1') + FWFldGet('VK9_CHASSI')") )

Return


Static Function AddTrigger(oAuxStru, aAuxTrigger)
	oAuxStru:AddTrigger(aAuxTrigger[1], aAuxTrigger[2], aAuxTrigger[3], aAuxTrigger[4])
Return


/*/{Protheus.doc} ViewDef
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 19/04/2022
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ViewDef()

	Local oView
	Local oModel := FWLoadModel( 'VEIA072' )
	Local oStruVK9 := FWFormStruct( 2, 'VK9' )
	Local oStruVW0 := FWFormStruct( 2, 'VW0' , { |cField| ! (AllTrim(Upper(cField)) $ "VW0_KILOME/VW0_HORTRI/VW0_DATA/VW0_HORA/VW0_ORIGEM/VW0_FILOSV/VW0_NUMOSV/VW0_FILPRO/VW0_FILENT/VW0_TRACPA/VW0_FILSAI/VW0_NUMTRA/VW0_CODVK9") })

	oView := FWFormView():New()
	oView:SetModel( oModel )

	oView:SetContinuousForm(.T.)

	oView:CreateHorizontalBox( 'TELA_072' , 10 )

	oView:AddField('1VIEW_VK9', oStruVK9, 'MODEL_VK9' )
	oView:AddField('2VIEW_VW0', oStruVW0, 'MODEL_VW0' )

	oView:SetOwnerView('1VIEW_VK9','TELA_072')
	oView:SetOwnerView('2VIEW_VW0','TELA_072')

	oView:EnableTitleView("1VIEW_VK9", FwX2Nome("VK9"))
	oView:EnableTitleView("2VIEW_VW0", FwX2Nome("VW0"))

Return oView

Function VA0720033_ViewVW0Movimentacao()

	local oView := ViewDef()
	local oExecView
	local oModel := FWLoadModel( 'VEIA072' )
	local nRecVK9 := VK9->(Recno())

	oExecView := FWViewExec():New()
	oExecView:setTitle(STR0004) // "Movimentação de Equipment"
	oExecView:setModel(oModel)
	oExecView:setView(oView)
	oExecView:setOperation(MODEL_OPERATION_VIEW)

	oExecView:openView(.t.)

	VK9->(dbGoTo(nRecVK9))
	
	dbselectarea("VW0")

Return

Function VA0720043_ViewVK9Reserva()

	Local oView
	Local oExecView
	Local oModel := FWLoadModel( 'VEIA072' )
	Local oStruVK9 := FWFormStruct( 2, 'VK9' )

	oView := FWFormView():New()
	oView:SetModel( oModel )

	oView:CreateHorizontalBox( 'TELA_072' , 100 )

	oView:AddField('1VIEW_VK9', oStruVK9, 'MODEL_VK9' )

	oView:SetOwnerView('1VIEW_VK9','TELA_072')

	oExecView := FWViewExec():New()
	oExecView:setTitle(STR0005) // "Reserva de Equipamento"
	oExecView:setModel(oModel)
	oExecView:setView(oView)
	oExecView:setOperation(MODEL_OPERATION_VIEW)

	oExecView:openView(.t.)

Return

/*/{Protheus.doc} MenuDef
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 19/04/2022
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina Title STR0006 Action 'VA0720033_ViewVW0Movimentacao' OPERATION 2 ACCESS 0	// 'Visualizar - VW0'
	ADD OPTION aRotina Title STR0007 Action 'VA0720043_ViewVK9Reserva' OPERATION 2 ACCESS 0	// 'Visualizar - VK9'
	//ADD OPTION aRotina Title STR0008 Action 'VIEWDEF.VEIA072' OPERATION 3 ACCESS 0	// 'Incluir'
	//ADD OPTION aRotina Title STR0009 Action 'VIEWDEF.VEIA072' OPERATION 4 ACCESS 0	// 'Alterar'

Return aRotina


/*/{Protheus.doc} BrowseDef
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 19/04/2022
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function BrowseDef()

	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('VK9')
	oBrowse:SetDescription( STR0001 )
	
Return oBrowse
