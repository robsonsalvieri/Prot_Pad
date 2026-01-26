#include "protheus.ch"
#include "fwmvcdef.ch"
#include "plsa260bgt.ch"

/*/{Protheus.doc} modelDef
Modelo de dados do Histórico de Bloqueio dos Opcionais da Família

@type function
@version Protheus 12.1.2310 
@author vinicius.queiros
@since 21/07/2023
@return object, Retorna o modelo de dados criado
/*/
static function modelDef()

    local oModel as object
    local oStruBA3 := fwFormStruct(1, "BA3") as object 
    local oStruBGT := fwFormStruct(1, "BGT") as object

    oStruBA3:setProperty("*", MODEL_FIELD_OBRIGAT, .f.)

    oModel := MPFormModel():new("PLSA260BGT")
    oModel:setDescription("Histórico de Bloqueio dos Opcionais da Família")

    oModel:addFields("MASTERBA3", nil, oStruBA3)
    oModel:addGrid("DETAILBGT", "MASTERBA3", oStruBGT)

    oModel:setRelation("DETAILBGT", {{"BGT_FILIAL", "xFilial('BGT')"},;
                                     {"BGT_MATRIC", "BA3_CODINT+BA3_CODEMP+BA3_MATRIC"}},;
                                     BGT->(indexKey(1)))

    oModel:getModel("MASTERBA3"):setOnlyView(.T.)
    oModel:getModel("MASTERBA3"):setOnlyQuery(.T.)

    oModel:getModel("MASTERBA3"):setDescription("Família")
    oModel:getModel("DETAILBGT"):setDescription("Histórico de Bloqueio dos Opcionais")

    oModel:SetPrimaryKey({})

return oModel

/*/{Protheus.doc} viewDef
Tela de visualização do Histórico de Bloqueio dos Opcionais da família

@type function
@version Protheus 12.1.2310 
@author vinicius.queiros
@since 21/07/2023
@return object, Retorna a tela de visualização do modelo de dados criado
/*/
static function viewDef()

    local oView as object
    local oStruBA3 := fwFormStruct(2, "BA3", {|cField| alltrim(cField) $ "BA3_CODINT,BA3_CODEMP,BA3_MATRIC"}) as object
    local oStruBGT := fwFormStruct(2, "BGT") as object
    local oModel := fwLoadModel("PLSA260BGT") as object

    oStruBGT:removeField("BGT_MATRIC")
    oStruBGT:removeField("BGT_NOMUSR")
    oStruBA3:setNoFolder()

    oView := FWFormView():new()
    oView:setModel(oModel)

    oView:addField("VIEWBA3", oStruBA3, "MASTERBA3")
    oView:addGrid("VIEWBGT", oStruBGT, "DETAILBGT")

    oView:createHorizontalBox("HEADER", 20)
    oView:createHorizontalBox("CONTENT", 80)

    oView:setOwnerView("VIEWBA3", "HEADER")
    oView:setOwnerView("VIEWBGT", "CONTENT")
	
    oView:enableTitleView("VIEWBA3", STR0001) // "Família"
    oView:enableTitleView("VIEWBGT", STR0002) // "Histórico de Bloqueio dos Opcionais"

return oView

/*/{Protheus.doc} PFldGetBGT
Retorna o valor do campo informado, sendo para o grupo familiar antigo o valor de memória e 
para o grupo familiar em MVC o valor do modelo.

@type function
@version Protheus 12.1.2310
@author vinicius.queiros
@since 25/07/2023
@param cField, character, Campo para busca do valor
@return cFieldValue, Retornar o valor do campo informado
/*/
function PFldGetBGT(cField)

    local cFieldValue as character
    local oModel as object

    oModel := fwModelActive()

    if valType(oModel) <> "U" .and. oModel:isActive() .and. oModel:getId() == "PLSA260BGT"
        cFieldValue := oModel:getValue("DETAILBGT", cField)
    else
        cFieldValue := &("M->"+cField)
    endif

return cFieldValue
