#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

PUBLISH MODEL REST NAME FSMITEMCONTABIL source FSMA045 RESOURCE OBJECT FsmRestModel

Static Function ModelDef()

    Local oModel	:= Nil
    Local oStruCTD	:= FWFormStruct(1, "CTD")

    oModel := MPFormModel():New('FSMA045', /*bPreValid*/, /*bPosValid*/,, /*bCancel*/)
    oModel:AddFields('CTDMASTER',/*cOwner*/,oStruCTD)

    oModel:GetModel('CTDMASTER'):SetDescription("Item contábil")

    oModel:SetDescription("Item contábil")

    oModel:SetPrimaryKey( { "CTD_FILIAL", "CTD_ITEM" } )

Return oModel
