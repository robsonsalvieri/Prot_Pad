#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

PUBLISH MODEL REST NAME FSMENDERECOTECNICO source FSMA054 RESOURCE OBJECT FsmRestModel

Static Function ModelDef()

    Local oModel   as object
    Local oStruSBF as object

    oStruSBF := FWFormStruct(1, "SBF")		

    oModel := MPFormModel():New('FSMA054', /*bPreValid*/, /*bPosValid*/,, /*bCancel*/)
    
    oModel:AddFields('SBFMASTER',/*cOwner*/,oStruSBF)

    oModel:GetModel('SBFMASTER'):SetDescription("Endereco do técnico")

    oModel:SetDescription("Endereço do técnico")

    oModel:SetPrimaryKey( { "BF_FILIAL", "BF_PRODUTO" } )

Return oModel
