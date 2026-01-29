#INCLUDE 'Protheus.ch'
#INCLUDE 'FWMVCDEF.ch'
#INCLUDE "GTPU011A.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPU011A
Exceção de Alocação - Urbano

@author Yuri Porto
@since 01/07/2024
@version 1.0
/*/
//-------------------------------------------------------------------

Function GTPU011A()	
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription(STR0001) //"'Exceção de Alocação'" 
oBrowse:SetAlias("H7R")
oBrowse:SetLocate()
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional


@author Yuri Porto
@since 01/07/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aRotina, { STR0003, "VIEWDEF.GTPU011A", 0, 2, 0, NIL } ) //"Visualizar"
aAdd( aRotina, { STR0004, "VIEWDEF.GTPU011A", 0, 3, 0, NIL } ) //"Incluir"
aAdd( aRotina, { STR0005, "VIEWDEF.GTPU011A", 0, 4, 0, NIL } ) //"Alterar"
aAdd( aRotina, { STR0006, "VIEWDEF.GTPU011A", 0, 5, 0, NIL } ) //"Excluir"
aAdd( aRotina, { STR0007, "VIEWDEF.GTPU011A", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina
//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função responsavel pela definição do modelo
@since 10/09/2021
@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel    := nil
Local oStrH7R   := FWFormStruct(1,'H7R')

	oModel := MPFormModel():New('GTPU011A', /*bPreValidacao*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/ )
	oModel:AddFields('H7RMASTER',/*cOwner*/,oStrH7R,/*bPre*/,/*bPos*/,/*bLoad*/)
	oModel:SetDescription(STR0001)// "'Exceção de Alocação'"
	oModel:GetModel('H7RMASTER'):SetDescription(STR0001) //"'Exceção de Alocação'" 

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função responsavel pela definição da view
@type Static Function
@author Yuri porto
@since 13/09/2021
@version 1.0
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oView   := FWFormView():New()
Local oModel  := FwLoadModel('GTPU011A')
Local oStrH7R := FWFormStruct(2, 'H7R')

	oView:SetModel(oModel)
	oView:AddField('VIEW_H7R' ,oStrH7R,'H7RMASTER')
	oView:SetDescription(STR0001) //"'Exceção de Alocação'"

Return oView
