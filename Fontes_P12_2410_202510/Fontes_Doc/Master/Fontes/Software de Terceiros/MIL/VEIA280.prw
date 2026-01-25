#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWEditPanel.CH'
#INCLUDE 'VEIA280.CH'

/*/{Protheus.doc} VEIA280
	Cadastro de Fluxo de Processos

@author Renato Vinicius
@since 08/09/2022
@version undefined

@type function
/*/

Function VEIA280(cCodPesq)

Local aRotinaBkp := If(type("aRotina") <> "U", aRotina,{})
Local oBrowseVal

Default cCodPesq := ""

Private cCodigo := cCodPesq

aRotina := {}

oBrowseVal := FWMBrowse():New()
oBrowseVal:SetAlias('VAL')
oBrowseVal:SetMenuDef('VEIA280')
oBrowseVal:SetDescription( STR0001 ) // "Fluxo de Processos"

if !Empty(cCodigo)
	cFiltro := "@ VAL_FILIAL = '"+xFilial("VV9")+"' AND VAL_NUMATE = '" + cCodigo + "'"
	oBrowseVal:SetFilterDefault( cFiltro )
EndIf

oBrowseVal:Activate()

aRotina := aRotinaBkp

Return

Static Function MenuDef()

Local aRotina := {}

	ADD OPTION aRotina Title STR0002 Action 'VIEWDEF.VEIA280' OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.VEIA280' OPERATION 3 ACCESS 0 //"Incluir"

Return aRotina

Static Function ModelDef()
Local oModel
Local oStrVAL := FWFormStruct(1, "VAL")

oModel := MPFormModel():New('VEIA280',;
/*Pré-Validacao*/,;
/*Pós-Validacao*/,;
/*Confirmacao da Gravação*/,;
/*Cancelamento da Operação*/)

oModel:AddFields('VALMASTER',/*cOwner*/ , oStrVAL)
oModel:SetPrimaryKey( { "VAL_FILIAL", "VAL_CODIGO" } )
oModel:SetDescription( STR0001 ) // "Fluxo de Processos"
oModel:GetModel('VALMASTER'):SetDescription( STR0004 ) //Dados do fluxo de processos

oModel:InstallEvent("VEIA280EVDF", /*cOwner*/, VEIA280EVDF():New("VEIA280"))
 
Return oModel

Static Function ViewDef()

Local oView
Local oModel := ModelDef()
Local oStrVAL:= FWFormStruct(2, "VAL")

oView := FWFormView():New()

oView:SetModel(oModel)

oStrVAL:SetProperty( 'VAL_TIPO' , MVC_VIEW_CANCHANGE, .f. )
oStrVAL:SetProperty( 'VAL_NUMATE' , MVC_VIEW_CANCHANGE, .f. )

oView:CreateHorizontalBox( 'VAL', 100)
oView:AddField('VIEW_VAL', oStrVAL, 'VALMASTER')
oView:EnableTitleView('VIEW_VAL', STR0001 ) // "Fluxo de Processos"
oView:SetOwnerView('VIEW_VAL','VAL')

Return oView