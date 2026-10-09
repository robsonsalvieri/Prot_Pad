#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"
#Include "AGDA042.ch"

/*/{Protheus.doc} AGDA042
Browser da NF2 de notas de saida exportada receituario
@type function
@version 12
@author lindembergson.pacheco
@since 05/05/2026
@return variant, nil
/*/
Function AGDA042(pcFiltro)
	Local oMBrowse := Nil

	If .Not. TableInDic('NF2')
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		Return()
	Endif

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NF2" )
	oMBrowse:SetDescription( STR0001  )  //"NF Saida Agrodefesa"

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

	ADD OPTION aRotina Title STR0002 Action 'VIEWDEF.AGDA042' OPERATION 2 ACCESS 0  //"Visualizar"
	// ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.AGDA042' OPERATION 3 ACCESS 0 //#"Incluir"
	// ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.AGDA042' OPERATION 4 ACCESS 0 //#"Alterar"
	// ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.AGDA042' OPERATION 5 ACCESS 0 //#"Excluir"

Return aRotina

/*/{Protheus.doc} ModelDef
Model do AGDA042
@type function
@version 12
@author lindembergson.pacheco
@since 05/05/2026
@return variant, nil
/*/
Static Function ModelDef()
	Local oModel	:= Nil
	Local oStruNF2  := FwFormStruct( 1, "NF2" )

	oModel := MpFormModel():New( "AGDA042" )
	oModel:SetDescription(  STR0001 )  //"NF Saida Agrodefesa"

	// Adiciona a field no modelo de dados
	oModel:AddFields( "AGDA042_NF2", , oStruNF2)
	oModel:GetModel( "AGDA042_NF2" ):SetDescription(  STR0001 )  //"NF Saida Agrodefesa"
	oModel:SetPrimaryKey( { "NF2_FILIAL", "NF2_DOC", "NF2_SERIE", "NF2_CLIENT", "NF2_LOJA" } )

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
	Local oModel	:= FwLoadModel( "AGDA042" )
	Local oStruNF2  := FwFormStruct( 2, "NF2" )
	Local oView		:= FwFormView():New() // Instancia o modelo de dados

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_NF2', oStruNF2, 'AGDA042_NF2' )

	oView:CreateHorizontalBox( 'CABEC', 100 )
	oView:SetOwnerView( 'VIEW_NF2', 'CABEC' )
	oView:EnableTitleView("VIEW_NF2")
	oView:SetCloseOnOk({||.T.})

Return oView

