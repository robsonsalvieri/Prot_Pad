#include "protheus.ch"
#include "fwmvcdef.ch"
#include "plsa260bgu.ch"

/*/{Protheus.doc} modelDef
Modelo de dados do Histórico de Bloqueio dos Opcionais do beneficiário

@type function
@version Protheus 12.1.2310 
@author vinicius.queiros
@since 24/07/2023
@return object, Retorna o modelo de dados criado
/*/
static function modelDef()

    local oModel as object
    local oStruBA1 := fwFormStruct(1, "BA1") as object
    local oStruBGU := fwFormStruct(1, "BGU") as object

    oStruBA1:setProperty("*", MODEL_FIELD_OBRIGAT, .f.)

    oStruBA1 := PLAddFldStruct(1, oStruBA1, {"BA1_MATRIC"}, .t.)

    oModel := MPFormModel():new("PLSA260BGU")
    oModel:setDescription("Histórico de Bloqueio dos Opcionais do Beneficiário")

    oModel:addFields("MASTERBA1", nil, oStruBA1)
    oModel:addGrid("DETAILBGU", "MASTERBA1", oStruBGU)

    oModel:setRelation("DETAILBGU", {{"BGU_FILIAL", "xFilial('BGU')"},; 
                                     {"BGU_MATRIC", "BA1_CODINT+BA1_CODEMP+BA1_MATRIC"},;
                                     {"BGU_TIPREG", "BA1_TIPREG"}},;
                                     BGU->(indexKey(2)))

    oModel:getModel("MASTERBA1"):setOnlyView(.T.)
    oModel:getModel("MASTERBA1"):setOnlyQuery(.T.)

    oModel:getModel("MASTERBA1"):setDescription("Beneficiário")
    oModel:getModel("DETAILBGU"):setDescription("Histórico de Bloqueio dos Opcionais")

    oModel:SetPrimaryKey({})

return oModel

/*/{Protheus.doc} viewDef
Tela de visualização do Histórico de Bloqueio dos Opcionais do beneficiário

@type function
@version Protheus 12.1.2310 
@author vinicius.queiros
@since 21/07/2023
@return object, Retorna a tela de visualização do modelo de dados criado
/*/
static function viewDef()

    local oView as object
    local oStruBA1 := fwFormStruct(2, "BA1", {|cField| alltrim(cField) $ "BA1_CODINT,BA1_CODEMP,BA1_MATRIC,BA1_TIPREG,BA1_DIGITO,BA1_NOMUSR"}) as object
    local oStruBGU := fwFormStruct(2, "BGU") as object
    local oModel := fwLoadModel("PLSA260BGU") as object

    oStruBA1 := PLAddFldStruct(2, oStruBA1, {"BA1_MATRIC"}, .t.)

    oStruBGU:removeField("BGU_MATRIC")
    oStruBGU:removeField("BGU_TIPREG")
    oStruBGU:removeField("BGU_NOMUSR")
    oStruBA1:setNoFolder()

    oView := FWFormView():new()
    oView:setModel(oModel)

    oView:addField("VIEWBA1", oStruBA1, "MASTERBA1")
    oView:addGrid("VIEWBGU", oStruBGU, "DETAILBGU")

    oView:createHorizontalBox("HEADER", 20)
    oView:createHorizontalBox("CONTENT", 80)

    oView:setOwnerView("VIEWBA1", "HEADER")
    oView:setOwnerView("VIEWBGU", "CONTENT")
	
    oView:enableTitleView("VIEWBA1", STR0001) // "Beneficiário"
    oView:enableTitleView("VIEWBGU", STR0002) // "Histórico de Bloqueio dos Opcionais"

return oView

/*/{Protheus.doc} PFldGetBGU
Retorna o valor do campo informado, sendo para o grupo familiar antigo o valor de memória e 
para o grupo familiar em MVC o valor do modelo.

@type function
@version Protheus 12.1.2310
@author vinicius.queiros
@since 25/07/2023
@param cField, character, Campo para busca do valor
@return cFieldValue, Retornar o valor do campo informado
/*/
function PFldGetBGU(cField)

    local cFieldValue as character
    local oModel as object

    oModel := fwModelActive()

    if valType(oModel) <> "U" .and. oModel:isActive() .and. oModel:getId() == "PLSA260BGU"
        cFieldValue := oModel:getValue("DETAILBGU", cField)
    else
        cFieldValue := &("M->"+cField)
    endif

return cFieldValue
