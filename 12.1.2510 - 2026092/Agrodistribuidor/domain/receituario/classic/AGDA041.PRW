#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"
#Include "AGDA041.ch"

/*/{Protheus.doc} AGDA041
Browser da NF1 de notas de entrada exportada receituario
@type function
@version 12
@author lindembergson.pacheco
@since 05/05/2026
@return variant, nil
/*/
Function AGDA041(pcFiltro)
	Local oMBrowse := Nil

	If .Not. TableInDic('NF1')
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		Return()
	Endif

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NF1" )
	oMBrowse:SetDescription( STR0001  )  //"NF Entrada Agrodefesa"
	if !Empty(pcFiltro)
		oMBrowse:SetFilterDefault(pcFiltro)
	Endif

	oMBrowse:DisableDetails()
	oMBrowse:Activate()

Return Nil

/*/{Protheus.doc} MenuDef
Menu
@type function
@version 12
@author lindembergson.pacheco
@since 05/05/2026
@return variant, nil
/*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina Title STR0002 Action 'VIEWDEF.AGDA041' OPERATION 2 ACCESS 0  //"Visualizar"
	// ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.AGDA041' OPERATION 3 ACCESS 0 //#"Incluir"
	// ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.AGDA041' OPERATION 4 ACCESS 0 //#"Alterar"
	// ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.AGDA041 ' OPERATION 5 ACCESS 0 //#"Excluir"

Return aRotina

/*/{Protheus.doc} ModelDef
Model do AGDA041
@type function
@version 12
@author lindembergson.pacheco
@since 05/05/2026
@return variant, nil
/*/
Static Function ModelDef()
	Local oModel	:= Nil
	Local oStruNF1  := FwFormStruct( 1, "NF1" )

	oModel := MpFormModel():New( "AGDA041" )
	oModel:SetDescription(  STR0001 )  //"NF Entrada Agrodefesa"

	// Adiciona a field no modelo de dados
	oModel:AddFields( "AGDA041_NF1", , oStruNF1)
	oModel:GetModel( "AGDA041_NF1" ):SetDescription(  STR0001 )  //"NF Entrada Agrodefesa"
	oModel:SetPrimaryKey( { "NF1_FILIAL", "NF1_DOC", "NF1_SERIE", "NF1_FORNEC", "NF1_LOJA", "NF1_FORMUL" } )

Return oModel

/*/{Protheus.doc} ViewDef
Visualizacao do Model
@type function
@version 12
@author lindembergson.pacheco
@since 05/05/2026
@return variant, nil
/*/
Static Function ViewDef()
	Local oModel	:= FwLoadModel( "AGDA041" )
	Local oStruNF1  := FwFormStruct( 2, "NF1" )
	Local oView		:= FwFormView():New() // Instancia o modelo de dados

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_NF1', oStruNF1, 'AGDA041_NF1' )

	oView:CreateHorizontalBox( 'CABEC', 100 )
	oView:SetOwnerView( 'VIEW_NF1', 'CABEC' )
	oView:EnableTitleView("VIEW_NF1")
	oView:SetCloseOnOk({||.T.})

Return oView

