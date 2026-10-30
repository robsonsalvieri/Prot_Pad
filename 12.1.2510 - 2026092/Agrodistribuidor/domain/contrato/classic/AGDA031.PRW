#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AGDA031.CH"

/*/{Protheus.doc} AGDA031
Browser da ACL de Movimentos de Contratos Barter
@type function
@version 12
@author Gilson.Venturi
@since 27/01/2025
@return variant, nil
/*/
Function AGDA031(pcFiltro)
	Local oMBrowse := Nil

	If .Not. TableInDic('NEI')
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		Return()
	Endif

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NEI" )
	oMBrowse:SetDescription( STR0001  )  //'Movimentos Contratos de Compra da Negociacao'
	oMBrowse:DisableDetails()

	if !Empty(pcFiltro)
		oMBrowse:SetFilterDefault(pcFiltro)
	Endif

	oMBrowse:Activate()

Return Nil

/*/{Protheus.doc} MenuDef
Menu
@type function
@version 12
@author Gilson.Venturi
@since 27/01/2025
@return variant, nil
/*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina Title STR0002 Action 'VIEWDEF.AGDA031' OPERATION 2 ACCESS 0 // 'Visualizar'

Return aRotina

/*/{Protheus.doc} ModelDef
Model da ACL de Movimentos de Contratos de Negócios Barter
@type function
@version 12
@author Gilson.Venturi
@since 27/01/2025
@return variant, nil
/*/
Static Function ModelDef()
	Local oModel	:= Nil
	Local oStruNEI	:= FwFormStruct( 1, "NEI" )
	Local oEvent	:= AGDA031EVT():New()

	oModel := MpFormModel():New( "AGDA031" )
	oModel:SetDescription( STR0001 )

	// Adiciona a field no modelo de dados
	oModel:AddFields( "AGDA031_NEI", , oStruNEI)
	oModel:GetModel( "AGDA031_NEI" ):SetDescription( STR0001 )

	oModel:SetPrimaryKey( { "NEI_FILIAL","NEI_IDCTR", "NEI_SEQ" } )

	oModel:InstallEvent("AGDA031EVT", /*cOwner*/, oEvent)

Return oModel

/*/{Protheus.doc} ViewDef
Visualizacao do Model
@type function
@version 12
@author Gilson.Venturi
@since 27/01/2025
@return variant, nil
/*/
Static Function ViewDef()
	Local oModel	:= FwLoadModel( "AGDA031" )
	Local oStruNEI  := FwFormStruct( 2, "NEI" )
	Local oView		:= FwFormView():New() // Instancia o modelo de dados

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_NEI', oStruNEI, 'AGDA031_NEI' )

	oView:CreateHorizontalBox( 'CABEC', 100 )

	oView:SetOwnerView( 'VIEW_NEI', 'CABEC' )

	oView:EnableTitleView("VIEW_NEI")

	oView:SetCloseOnOk({||.T.})

Return oView

