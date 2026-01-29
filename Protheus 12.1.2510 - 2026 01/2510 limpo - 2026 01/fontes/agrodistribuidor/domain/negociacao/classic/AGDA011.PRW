#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AGDA011.CH"

/*/{Protheus.doc} AGDA011
Browser Dados Contrato da Negociação  
@type function
@version 12
@author claudineia.reinert
@since 19/05/2025
@return variant, nil
/*/
Function AGDA011(pcFiltro)
	Local oMBrowse := Nil

	If .Not. TableInDic('NEE')
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		Return()
	Endif

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NEE" )
	oMBrowse:SetDescription( alltrim(FWX2Nome("NEE")) )  //'Contratos de Compra da Negociacao'
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
@author claudineia.reinert
@since 19/05/2025
@return variant, nil
/*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.AGDA011' OPERATION 2 ACCESS 0 // 'Visualizar'


Return aRotina

/*/{Protheus.doc} ModelDef
Model da ACL de Contratos de Negócios Barter
@type function
@version 12
@author claudineia.reinert
@since 19/05/2025
@return variant, nil
/*/
Static Function ModelDef()
	Local oModel	:= Nil
	Local oStruNEF  := FwFormStruct( 1, "NEE" )

	oModel := MpFormModel():New( "AGDA011" )
	oModel:SetDescription(  FWX2Nome("NEE") )

	// Adiciona a field no modelo de dados
	oModel:AddFields( "AGDA011_NEE", , oStruNEF)
	oModel:SetPrimaryKey( { "NEE_FILIAL", "NEE_CODBRT", "NEE_VERSAO", "NEE_ITEM" } )

Return oModel

/*/{Protheus.doc} ViewDef
Visualizacao do Model
@type function
@version 12
@author claudineia.reinert
@since 19/05/2025
@return variant, nil
/*/
Static Function ViewDef()
	Local oModel	:= FwLoadModel( "AGDA011" )
	Local oStruNEE  := FwFormStruct( 2, "NEE" )
	Local oView		:= FwFormView():New() // Instancia o modelo de dados

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_NEE', oStruNEE, 'AGDA011_NEE' )

	oView:CreateHorizontalBox( 'CABEC', 100 )

	oView:SetOwnerView( 'VIEW_NEE', 'CABEC' )

	oView:EnableTitleView("VIEW_NEE")

	oView:SetCloseOnOk({||.T.})

Return oView
