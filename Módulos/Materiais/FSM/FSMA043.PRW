#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

PUBLISH MODEL REST NAME FSMCENTCUST source FSMA043 RESOURCE OBJECT FsmRestModel

Static Function ModelDef()

    Local oModel	:= Nil
    Local oStruCTT	:= FWFormStruct(1, "CTT")

    oModel := MPFormModel():New('FSMA043', /*bPreValid*/, /*bPosValid*/,, /*bCancel*/)
    oModel:AddFields('CTTMASTER',/*cOwner*/,oStruCTT)

    oModel:GetModel('CTTMASTER'):SetDescription("Centro de custo")

    oModel:SetDescription("Centro de custo")

    oModel:SetPrimaryKey( { "CTT_FILIAL", "CTT_CUSTO" } )

Return oModel
