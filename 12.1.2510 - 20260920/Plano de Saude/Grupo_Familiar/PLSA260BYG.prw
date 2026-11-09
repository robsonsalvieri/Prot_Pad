#include "protheus.ch"
#include "fwmvcdef.ch"
#include "plsa260byg.ch"

/*/{Protheus.doc} modelDef
Modelo de dados do Histórico de Reajuste da Taxa de Adesão da Família

@type function
@version Protheus 12.1.2310 
@author vinicius.queiros
@since 26/07/2023
@return object, Retorna o modelo de dados criado
/*/
static function modelDef()

    local oModel as object
    local oStruBA3 := fwFormStruct(1, "BA3") as object 
    local oStruBYG := fwFormStruct(1, "BYG") as object

    oStruBA3:setProperty("*", MODEL_FIELD_OBRIGAT, .f.)

    oModel := MPFormModel():new("PLSA260BYG")
    oModel:setDescription("Histórico de Reajuste da Taxa de Adesão da Família")

    oModel:addFields("MASTERBA3", nil, oStruBA3)
    oModel:addGrid("DETAILBYG", "MASTERBA3", oStruBYG)

    oModel:setRelation("DETAILBYG", {{"BYG_FILIAL", "xFilial('BYG')"},;
                                     {"BYG_CODOPE", "BA3_CODINT"},;
                                     {"BYG_CODEMP", "BA3_CODEMP"},;
                                     {"BYG_MATRIC", "BA3_MATRIC"}},;
                                     BYG->(indexKey(1)))

    oModel:getModel("MASTERBA3"):setOnlyView(.T.)
    oModel:getModel("MASTERBA3"):setOnlyQuery(.T.)

    oModel:getModel("MASTERBA3"):setDescription("Família")
    oModel:getModel("DETAILBYG"):setDescription("Histórico de Reajuste da Taxa de Adesão")

    oModel:SetPrimaryKey({})

return oModel

/*/{Protheus.doc} viewDef
Tela de visualização do Histórico de Reajuste da Taxa de Adesão da Família

@type function
@version Protheus 12.1.2310 
@author vinicius.queiros
@since 26/07/2023
@return object, Retorna a tela de visualização do modelo de dados criado
/*/
static function viewDef()

    local oView as object
    local oStruBA3 := fwFormStruct(2, "BA3", {|cField| alltrim(cField) $ "BA3_CODINT,BA3_CODEMP,BA3_MATRIC"}) as object
    local oStruBYG := fwFormStruct(2, "BYG") as object
    local oModel := fwLoadModel("PLSA260BYG") as object

    oStruBYG:removeField("BYG_CODOPE")
    oStruBYG:removeField("BYG_CODEMP")
    oStruBYG:removeField("BYG_MATRIC")
    oStruBA3:setNoFolder()

    oView := FWFormView():new()
    oView:setModel(oModel)

    oView:addField("VIEWBA3", oStruBA3, "MASTERBA3")
    oView:addGrid("VIEWBYG", oStruBYG, "DETAILBYG")

    oView:createHorizontalBox("HEADER", 20)
    oView:createHorizontalBox("CONTENT", 80)

    oView:setOwnerView("VIEWBA3", "HEADER")
    oView:setOwnerView("VIEWBYG", "CONTENT")
	
    oView:enableTitleView("VIEWBA3", STR0001) // "Família"
    oView:enableTitleView("VIEWBYG", STR0002) // "Histórico de Reajuste da Taxa de Adesão"

return oView
