#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TAFA555

/*/
//-------------------------------------------------------------------------------------------------------------
Function TAFA555()
    Local   oBrowse as object

    oBrowse :=  FWmBrowse():New()

    oBrowse:SetDescription( "Central de Notificações" )
    oBrowse:SetAlias( 'V49' )
    oBrowse:Activate()

Return

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

/*/
//-------------------------------------------------------------------------------------------------------------
Static Function MenuDef()
    Local aRotina   as array

    aRotina	:= {}

    ADD OPTION aRotina TITLE 'Visualizar'	ACTION 'VIEWDEF.TAFA555' OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE 'Incluir'		ACTION 'VIEWDEF.TAFA555' OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE 'Alterar'		ACTION 'VIEWDEF.TAFA555' OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE 'Excluir'		ACTION 'VIEWDEF.TAFA555' OPERATION 5 ACCESS 0

Return aRotina


//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

/*/
//-------------------------------------------------------------------------------------------------------------
Static Function ModelDef()

    Local oStruV49  as object
    Local oModel    as object

    oStruV49 := FWFormStruct( 1, 'V49' )
    oModel 	 := MPFormModel():New( 'TAFA555')

    oModel:AddFields( 'MODEL_V49' ,, oStruV49 )

    oModel:GetModel( 'MODEL_V49' ):SetPrimaryKey( { 'V49_ID'} )

Return oModel

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

/*/
//-------------------------------------------------------------------------------------------------------------
Static Function ViewDef()

    Local oModel    as object
    Local oStruV49  as object
    Local oView     as object

    oModel 	 := MPFormModel():new("TAFA555") //FWLoadModel( 'TAFA555' )
    oStruV49 := FWFormStruct( 2, 'V49' )
    oView 	 := FWFormView():New()

    oView:SetModel( oModel )

    oView:AddField( 'VIEW_V49', oStruV49, 'MODEL_V49' )
    oView:EnableTitleView( 'VIEW_V49', "Central de Notificações" )

    oView:CreateHorizontalBox( 'V49', 100 )

    oModel:GetModel( 'MODEL_V49' ):SetDescription("Central de Notificações")
    oView:SetOwnerView( 'VIEW_V49', 'V49' )

Return oView
