#include "MATA312.CH"
#include 'totvs.ch'
#include 'protheus.ch'
#include 'FWMVCDEF.CH'
#INCLUDE "FWMBROWSE.CH"

PUBLISH MODEL REST NAME MATA312

/*/{Protheus.doc} MATA312
	Cadastro de Precificação de Materiais para Transferências
	entre Filiais.
@type  Function
@author Everton Fregonezi Diniz
@since 19/01/2026
/*/
Function MATA312()

local oBrowse	:= Nil	as object

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias('D4Y')
    oBrowse:SetDescription(STR0001)	// "Precificação de Materiais P/ Transferencia Filiais"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Função do Browser SMARTX                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If hasSmartX()
		oBrowse:setSmartX()
	Endif 
    oBrowse:Activate()

Return


/*/{Protheus.doc} MenuDef
	Definição do menu da rotina
@type  Static Function
@author Everton Fregonezi Diniz
@since 19/01/2026
@version version
@return aRotina, Array, Array contendo o menu da rotina
/*/
Static Function MenuDef()

local aRotina	:= {}	as array

	ADD OPTION aRotina TITLE STR0002	ACTION "VIEWDEF.MATA312"	OPERATION 2	ACCESS 0  	//'Visualizar'
	ADD OPTION aRotina TITLE STR0003	ACTION "VIEWDEF.MATA312"	OPERATION 3	ACCESS 0  	//'Incluir'
	ADD OPTION aRotina TITLE STR0004	ACTION "VIEWDEF.MATA312"	OPERATION 4	ACCESS 0  	//'Alterar'
	ADD OPTION aRotina TITLE STR0005	ACTION "VIEWDEF.MATA312"	OPERATION 5	ACCESS 0  	//'Excluir'

Return aRotina


/*/{Protheus.doc} ModelDef
	Definição do modelo de dados da rotina
@type  Static Function
@author Everton Fregonezi Diniz
@since 19/01/2026
@version version
@return oModel, oModel, Retorna o modelo de dados
/*/
Static Function ModelDef()

local oModel	:= Nil	as object
local oStruD4Y	:= Nil	as object

	oStruD4Y := FWFormStruct(1,'D4Y')

	oModel := MPFormModel():New('MATA312')
	oModel:AddFields('D4YMASTER',,oStruD4Y)
	oModel:GetModel('D4YMASTER'):SetDescription(STR0001)	// "Precificação de Materiais P/ Transferencia Filiais"
	oModel:SetPrimaryKey({"D4Y_FILIAL","D4Y_TIPO"})

Return oModel


/*/{Protheus.doc} ViewDef
	Definição da visão dos dados do modelo
@type  Static Function
@author Everton Fregonezi Diniz
@since 19/01/2026
@version version
@param param_name, param_type, param_descr
@return oView, Object, Retorna o objeto de visualização dos dados do modelo
/*/
Static Function ViewDef()

Local oModel	:= Nil	as object
Local oStruD4Y	:= Nil	as object
Local oView		:= Nil	as object

	oModel		:= ModelDef()
	oStruD4Y	:= FWFormStruct(2,'D4Y')

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('D4YMASTER',oStruD4Y,'D4YMASTER')
	oView:EnableTitleView('D4YMASTER',STR0006)	// "Cadastral"
	oView:CreateHorizontalBox('FORM',100)
	oView:SetOwnerView('D4YMASTER','FORM')

Return oView
