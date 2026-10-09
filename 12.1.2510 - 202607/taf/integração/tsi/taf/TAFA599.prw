#include "protheus.ch"
#include "fwmvcdef.ch"
#include "TAFA599.ch"

/*-------------------------------------------------------------------
{Protheus.doc} TAFA564()
(Rotina para visualização do ultimo STAMP gerado)
@author Jose Felipe
@since 21/10/2021
@return Nil, nulo, não tem retorno.
//-----------------------------------------------------------------*/
Function TAFA599() 
Local oBrowse := FWMBrowse():New()
	
oBrowse:SetDescription(STR0001)
oBrowse:SetAlias('V80')
oBrowse:SetMenuDef('TAFA599')
oBrowse:Activate()

Return

/*-------------------------------------------------------------------
{Protheus.doc} MenuDef()
@author Jose Felipe
@since 21/10/2021
@return Nil, nulo, não tem retorno.
//-----------------------------------------------------------------*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.TAFA599' OPERATION 2 ACCESS 0 //Visualizar
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.TAFA599' OPERATION 3 ACCESS 0 //Incluir
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.TAFA599' OPERATION 4 ACCESS 0 //Alterar

Return aRotina

/*-------------------------------------------------------------------
{Protheus.doc} ModelDef()
@author Jose Felipe
@since 21/10/2021
@return Nil, nulo, não tem retorno.
//-----------------------------------------------------------------*/
Static Function ModelDef()
Local oStruV5R := FWFormStruct(1,'V80')
Local oModel   := MPFormModel():New( "TAFA599")

oModel:AddFields('MODEL_V80', /*cOwner*/, oStruV5R)
oModel:GetModel('MODEL_V80'):SetPrimaryKey({'V80_FILIAL', 'V80_ALIAS', 'V80_STAMP' })

Return oModel

/*-------------------------------------------------------------------
{Protheus.doc} ViewDef()
@author Jose Felipe
@since 21/10/2021
@return Nil, nulo, não tem retorno.
//-----------------------------------------------------------------*/
Static Function ViewDef()
Local oModel        := FwLoadModel('TAFA599')
Local oStrV5R       := FWFormStruct(2, 'V80')
Local oView         := FWFormView():New() 

oView:SetModel(oModel)
oView:AddField('VIEW_V80' ,oStrV5R,'MODEL_V80')  
oView:EnableTitleView( 'VIEW_V80', STR0001 ) 
oView:CreateHorizontalBox( 'FIELDS_V80', 100 ) 
oView:SetOwnerView( 'VIEW_V80', 'FIELDS_V80' )
	
Return oView
