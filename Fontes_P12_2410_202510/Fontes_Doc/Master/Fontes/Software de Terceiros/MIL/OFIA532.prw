#include "PROTHEUS.CH"
#include "OFIA532.CH"
#include "fwmvcdef.ch"

/*/{Protheus.doc} OFIA532
    Cadastro de negocios do cliente - Versão MVC da OFIIA410
    @type  Function
    @author Renan Migliaris
    @since 23/07/2025
    /*/
Function OFIA532()
    local oBrowse := FWMBrowse():new()
    private aRotina := menudef()

    oBrowse:SetAlias("VZO")
    oBrowse:SetDescription(STR0001)
    oBrowse:SetExecuteDef(2)
    oBrowse:activate()
Return

Static Function MenuDef()
    local aRotina := {}

    ADD OPTION aRotina TITLE STR0007 ACTION 'axPesqui'          OPERATION 1 ACCESS 0 //pesquisar
    ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.OFIA532'   OPERATION 2 ACCESS 0 //visualizar
    ADD OPTION aRotina TITLE STR0009 ACTION 'VIEWDEF.OFIA532'   OPERATION 3 ACCESS 0 //incluir 
    ADD OPTION aRotina TITLE STR0010 ACTION 'VIEWDEF.OFIA532'   OPERATION 4 ACCESS 0 //alterar 
    ADD OPTION aRotina TITLE STR0011 ACTION 'VIEWDEF.OFIA532'   OPERATION 5 ACCESS 0 //excluir 

Return aRotina

Static Function ViewDef()
    local oStruct
    local oModel
    local oView

    oStruct := FWFormStruct(2, "VZO")
    oModel := fwLoadModel("OFIA532")
    oView := fwFormView():new()

    oView:setModel(oModel)
    oView:addField('VZOMASTER', oStruct , 'VZOMASTER')
    oView:CreateHorizontalBox('BOXVZO', 100)
    oView:setOwnerview('VZOMASTER', 'BOXVZO')
Return oView


Static Function ModelDef()
    local oModel
    local oStruct
    local aTrigger
    local bModelPos := {|x| OF532003J_fnModPos(x)}

    aTrigger := {}

    oStruct := FWFormStruct(1, 'VZO')
    oModel := MPFormModel():new('MODEL_OFIA532', /*bModelPre*/, bModelPos, /*bCommit*/, /*bCancel*/)

    aTrigger := fwStruTrigger('VZO_LOJA', 'VZO_NOME', 'SA1->A1_NREDUZ', .t., "SA1", 1, "xFilial('SA1')+fwFldGet('VZO_CLIENT')+fwFldGet('VZO_LOJA')")
    oStruct:addTrigger(aTrigger[1], aTrigger[2], aTrigger[3], aTrigger[4])
    aTrigger := fwStruTrigger('VZO_TIPO', 'VZO_DESCRI', 'VZN->VZN_DESCRI', .t., "VZN", 1, "xFilial('VZN')+fwFldGet('VZO_TIPO')")
    oStruct:addTrigger(aTrigger[1], aTrigger[2], aTrigger[3], aTrigger[4])

    oModel:addFields('VZOMASTER',,oStruct, ,/*bFieldPos*/,)
    oModel:SetPrimaryKey({xFilial("VZO"), "VZO_CLIENT", "VZO_LOJA", "VZO_TIPO"})
    oModel:addRules('VZOMASTER', 'VZO_LOJA', 'VZOMASTER', 'VZO_CLIENT', 3)
    oModel:SetDescription(STR0001)

    oStruct:SetProperty('VZO_CLIENT',MODEL_FIELD_OBRIGAT,.T.)
    oStruct:SetProperty('VZO_LOJA',MODEL_FIELD_OBRIGAT,.T.)
    oStruct:SetProperty('VZO_TIPO',MODEL_FIELD_OBRIGAT,.T.)

    oStruct:SetProperty('VZO_CLIENT', MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN, 'INCLUI'))
    oStruct:SetProperty('VZO_LOJA'  , MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN, 'INCLUI')) 
    oStruct:SetProperty('VZO_TIPO'  , MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN, 'INCLUI'))
Return oModel


Static Function  OF532003J_fnModPos(oModel)
    local nOpc := oModel:getOperation()
    local lValid := .t.

    if nOpc == 3
        dbSelectArea("VZO")
        dbSetOrder(1)           
        if dbSeek(xFilial("VZO")+fwFldGet('VZO_CLIENT')+fwFldGet('VZO_LOJA')+fwFldGet('VZO_TIPO'))
            FMX_help(STR0001, STR0002)
            lValid := .f.
        Endif
    endif
Return lValid

