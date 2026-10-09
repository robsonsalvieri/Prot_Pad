#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"

PUBLISH MODEL REST NAME FSMPERFILTEC SOURCE FSMA056 RESOURCE OBJECT FsmRestModel

Static Function ModelDef()

    Local oModel   As Object
    Local oStruJOM As Object
    Local oStruJON As Object

    oModel   := Nil
    oStruJOM := FWFormStruct(1, "JOM")
    oStruJON := FWFormStruct(1, "JON")

    oModel := MPFormModel():New("FSMA056")

    oModel:AddFields("JOMMASTER", /*cOwner*/, oStruJOM)
    oModel:AddGrid("JONDETAIL", "JOMMASTER", oStruJON)

    oModel:SetRelation("JONDETAIL", ;
        { ;
            {"JON_FILIAL", 'xFilial("JON")'}, ;
            {"JON_CODJOM", "JOM_CODIGO"} ;
        }, ;
        JON->(IndexKey(1)) ;
    )

    oModel:GetModel("JOMMASTER"):SetDescription("Perfil do Técnico")
    oModel:GetModel("JONDETAIL"):SetDescription("Técnicos vinculados")

    oModel:SetDescription("Cadastro de Perfil do Técnico")

    oModel:GetModel("JONDETAIL"):SetOptional(.T.)

Return oModel
