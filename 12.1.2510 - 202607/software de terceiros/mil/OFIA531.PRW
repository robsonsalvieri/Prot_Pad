#include "PROTHEUS.CH"  
#include "OFIA531.CH"
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} OFIA531
@description Cadastro de Tipos de Negocio em MVC
@author Bruno Forcato
@since 23/07/2025
@version 1.0

@type function
/*/
Function OFIA531()
    Local oBrowse

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias('VZN')
    oBrowse:SetDescription(STR0001) //Tipos de Negocio
    oBrowse:Activate()
Return

Static Function MenuDef()
    Local aRotina := {}

    ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.OFIA531' OPERATION 1 ACCESS 0 // "Pesquisar"
    ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.OFIA531' OPERATION 2 ACCESS 0 // "Visualizar"
    ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.OFIA531' OPERATION 3 ACCESS 0 // "Incluir"
    ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.OFIA531' OPERATION 4 ACCESS 0 // "Alterar"
    ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.OFIA531' OPERATION 5 ACCESS 0 // "Excluir"
Return aRotina

Static Function ModelDef()
    Local oStruVZN := FWFormStruct( 1, 'VZN' )
    Local oModel

    oModel := MPFormModel():New('OFIA531')
    oModel:AddFields( 'VZNMASTER',, oStruVZN)
    oModel:SetDescription( STR0001 ) //Tipos de Negocio
    oModel:GetModel( 'VZNMASTER' ):SetDescription( STR0007 ) //Dados do Tipo de Negocio
Return oModel

Static Function ViewDef()
    Local oModel   := FWLoadModel( 'OFIA531' )
    Local oStruVZN := FWFormStruct( 2, 'VZN' )
    Local oView

    oView := FWFormView():New()
    oView:SetModel( oModel )
    oView:AddField( 'VIEW_VZN', oStruVZN, 'VZNMASTER' )
    oView:CreateHorizontalBox( 'TELA' , 100 )
    oView:SetOwnerView( 'VIEW_VZN', 'TELA' )
Return oView