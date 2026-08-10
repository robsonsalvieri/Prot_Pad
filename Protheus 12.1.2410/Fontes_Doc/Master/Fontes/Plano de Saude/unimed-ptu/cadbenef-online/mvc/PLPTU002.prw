#include "protheus.ch"
#include "fwmvcdef.ch"
#include "plptu002.ch"

#define PENDING_SEND "1" // Pendente de envio
#define SEND_COMPLETED "2" // Envio finalizado
#define SEND_ERROR "3" // Erro de envio

/*/{Protheus.doc} PLPTU002
Browser com os beneficiário do lote do Cadbenef selecionado na tela anterior
@type function
@version 12.1.2410 
@author vinicius.queiros
@since 21/05/2024
/*/
function PLPTU002()

    local oBrowse as object

    oBrowse := FWMBrowse():new()
	oBrowse:setAlias("BPY")
	oBrowse:setDescription(STR0001) // "Beneficiários do Lote"
    oBrowse:setMenuDef("PLPTU002")
    oBrowse:SetFilterDefault("BPY_CODLOT == '" + BPW->BPW_CODIGO + "'")

    oBrowse:addLegend("BPY_STATUS == '" + PENDING_SEND + "'", "WHITE", STR0002) // "Pendente de Envio"
    oBrowse:addLegend("BPY_STATUS == '" + SEND_COMPLETED + "'", "GREEN", STR0003) // "Envio finalizado"
    oBrowse:addLegend("BPY_STATUS == '" + SEND_ERROR + "'", "RED", STR0004) // "Erro de envio"
    
	oBrowse:activate()
 
    oBrowse:destroy()
    freeObj(oBrowse)

return

/*/{Protheus.doc} menuDef
Menu do browser dos beneficiários do lote
@type function
@version 12.1.2410
@author vinicius.queiros
@since 21/05/2024
@return array, lista de menus do browser (aRotina)
/*/
static function menuDef() as array

    local aRotina := {} as array
    local cSendFunction as character
    local cDeleteBatchFunction as character
   
    cSendFunction := "fwMsgRun(nil, {|| totvs.protheus.health.plan.unimed.cadBenefSendBeneficiary()}, '', '" + STR0005 + "')" // Processando envio do beneficiário ...
    cDeleteBatchFunction := "fwMsgRun(nil, {|| totvs.protheus.health.plan.unimed.cadBenefDeleteItem()}, '', '" + STR0015 + "')" // "Excluindo item do lote ..."

    ADD OPTION aRotina TITLE STR0006 ACTION cSendFunction OPERATION MODEL_OPERATION_VIEW ACCESS 0 // "Enviar"
	ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.PLPTU002" OPERATION MODEL_OPERATION_VIEW ACCESS 0 // "Detalhes do Envio"
    ADD OPTION aRotina TITLE STR0016 ACTION cDeleteBatchFunction OPERATION MODEL_OPERATION_DELETE ACCESS 0 //"Excluir Beneficiário do Lote"
return aRotina

/*/{Protheus.doc} modelDef
Modelo de dados para incluir, alterar e excluir os beneficiários do lote
@type function
@version 12.1.2410  
@author vinicius.queiros
@since 21/05/2024
@return object, objeto da instância do modelo
/*/
static function modelDef() as object

    local oModel as object
    local oStruBPY as object
    local oStruError := FWFormModelStruct():new() as object

    oStruBPY := fwFormStruct(1, "BPY")
    oStruError := errorFormStruct(1, oStruError)

    oModel := MPFormModel():new("PLPTU002")
    oModel:setDescription(STR0008) // "Dados de Envio do Beneficiário"

    oModel:addFields("BPYMASTER", nil, oStruBPY)
    oModel:addGrid("ERRODETAIL", "BPYMASTER", oStruError, nil, nil, nil, nil, {|oMdl| loadErrorData(oMdl)})

    oModel:getModel("ERRODETAIL"):setOnlyQuery(.T.)
    oModel:getModel("ERRODETAIL"):setOptional(.T.)
    oModel:getModel("ERRODETAIL"):setNoInsertLine(.T.) 
    oModel:getModel("ERRODETAIL"):setNoDeleteLine(.T.)

    oModel:getModel("BPYMASTER"):setDescription(STR0008) // "Dados de Envio do Beneficiário"
    oModel:setPrimaryKey({"BPY_FILIAL", "BPY_CODLOT", "BPY_CODINT", "BPY_CODEMP", "BPY_MATRIC", "BPY_TIPREG", "BPY_DIGITO"})

return oModel

/*/{Protheus.doc} viewDef
Interface (View) para incluir, alterar e excluir os beneficiáriso do lote
@type function
@version 12.1.2410  
@author vinicius.queiros
@since 21/05/2024
@return object, objeto da instância da interface
/*/
static function viewDef() as object

	local oModel as object
	local oView as object
	local oStruBPY as object
    local oStruError :=	FWFormViewStruct():new() as object

    oStruBPY := fwFormStruct(2, "BPY")
    oStruError := errorFormStruct(2, oStruError)

    oStruBPY:removeField("BPY_CODLOT")

    oModel := fwLoadModel("PLPTU002")

	oView := FWFormView():new()
	oView:setModel(oModel)

	oView:addField("FORM_BPY", oStruBPY, "BPYMASTER") 
    oView:addGrid("FORM_ERRO", oStruError, "ERRODETAIL")

    oView:enableTitleView("FORM_ERRO", STR0010) // "Mensagens de Erro"

	oView:createHorizontalBox("BOX_FORM", 60)
    oView:createHorizontalBox("BOX_ERRO", 40)

	oView:setOwnerView("FORM_BPY", "BOX_FORM")
    oView:setOwnerView("FORM_ERRO", "BOX_ERRO")
	
return oView

/*/{Protheus.doc} errorFormStruct
Adiciona o formuario de erro manualmente na model e na view, esse formulário não utiliza uma
tabela do dicionário.
@type function
@version 12.1.2410
@author vinicius.queiros
@since 21/05/2024
@param nType, numeric, tipo da estrutura: 1 = Model e 2 = View
@param oFormStruct, object, objeto em que o formulario de erro será adicionado
@return object, o proprio objeto com as alterações
/*/
static function errorFormStruct(nType as numeric, oFormStruct as object) as object 

    do case
        case nType == 1 // modelDef
            oFormStruct:addTable("ERR", {}, STR0010) // "Mensagens de Erro"

            oFormStruct:addField("", "", "ERR_LEGEND", "C", 50, 0, nil, nil, {}, .F., FwBuildFeature(STRUCT_FEATURE_INIPAD, ""), .F.)
            oFormStruct:addField(STR0011, STR0011, "ERR_SEQUEN", "C", 6, 0, nil, nil, {}, .F., FwBuildFeature(STRUCT_FEATURE_INIPAD, ""), .F.) // "Seq."
            oFormStruct:addField(STR0012, STR0012, "ERR_CODIGO", "C", 7, 0, nil, nil, {}, .F., FwBuildFeature(STRUCT_FEATURE_INIPAD, ""), .F.) // "Código"
            oFormStruct:addField(STR0013, STR0013, "ERR_MENSAG", "C", 100, 0, nil, nil, {}, .F., FwBuildFeature(STRUCT_FEATURE_INIPAD, ""), .F.) // "Mensagem"
            oFormStruct:addField(STR0014, STR0014, "ERR_SOLUCA", "M", 10, 0, nil, nil, {}, .F., FwBuildFeature(STRUCT_FEATURE_INIPAD, ""), .F.) // "Solução"
            
        case nType == 2 // viewDef
            oFormStruct:AddField("ERR_LEGEND", "01", "", "", nil, "C", "@BMP", nil, nil, .T., nil, nil, nil, nil, nil, nil, nil, nil)
            oFormStruct:AddField("ERR_SEQUEN", "02", STR0011, STR0011, nil, "C", "", nil, nil, .T., nil, nil, nil, nil, nil, nil, nil, nil) // "Seq."
            oFormStruct:AddField("ERR_CODIGO", "03", STR0012, STR0012, nil, "C", "", nil, nil, .T., nil, nil, nil, nil, nil, nil, nil, nil) // "Código"
            oFormStruct:AddField("ERR_MENSAG", "04", STR0013, STR0013, nil, "C", "", nil, nil, .T., nil, nil, nil, nil, nil, nil, nil, nil) // "Mensagem"
            oFormStruct:AddField("ERR_SOLUCA", "05", STR0014, STR0014, nil, "M", "", nil, nil, .T., nil, nil, nil, nil, nil, nil, nil, nil) // "Solução"
    endcase

return oFormStruct

/*/{Protheus.doc} loadErrorData
Carrega os dados do grid de erro pelo json de resposta
@type function
@version 12.1.2410  
@author vinicius.queiros
@since 5/21/2024
@param oGrid, object, objeto grid do MVC
@return array, lista de erros que serão apresentados na tela
/*/
static function loadErrorData(oGrid as object) as array

    local aErrorData := {} as array
    local oErrorData := JsonObject():new() as object
    local cResponseData := BPY->BPY_MSGRES as character
    local cRet as character
    local nCount as numeric
    local nSequential := 1 as numeric
    local nLenArray as numeric
    local cMessage as character

    cRet := oErrorData:fromJson(cResponseData)

    if valType(cRet) == "U"
        do case
            case oErrorData:hasProperty("details") .and. valType(oErrorData["details"]) == "A"
                nLenArray := len(oErrorData["details"])

                for nCount := 1 to nLenArray
                    aAdd(aErrorData, {0, {"BR_VERMELHO",;
                                          strZero(nSequential++, 3),;
                                          oErrorData["details"][nCount]["code"],;
                                          oErrorData["details"][nCount]["message"],;
                                          oErrorData["details"][nCount]["detailedMessage"]}})
                next nCount
            
            case oErrorData:hasProperty("code") .and. oErrorData:hasProperty("message") .and. oErrorData:hasProperty("detailedMessage")
                aAdd(aErrorData, {0, {"BR_VERMELHO",;
                                      strZero(nSequential++, 3),;
                                      oErrorData["code"],;
                                      oErrorData["message"],;
                                      oErrorData["detailedMessage"]}})
            
            case oErrorData:hasProperty("errors") .and. valType(oErrorData["errors"]) == "A"
                nLenArray := len(oErrorData["errors"])

                for nCount := 1 to nLenArray
                    aAdd(aErrorData, {0, {"BR_VERMELHO",;
                                          strZero(nSequential++, 3),;
                                          cValToChar(oErrorData["status"]),;
                                          decodeUtf8(oErrorData["errors"][nCount]["message"]),;
                                          ""}})
                next nCount
            
            case oErrorData:hasProperty("dadosBeneficiario") .and. oErrorData["dadosBeneficiario"]:hasProperty("statusProcessamento") .and.;
                valType(oErrorData["dadosBeneficiario"]["statusProcessamento"]) == "A"

                nLenArray := len(oErrorData["dadosBeneficiario"]["statusProcessamento"])
                
                for nCount := 1 to nLenArray
                    if oErrorData["dadosBeneficiario"]["statusProcessamento"][nCount]["status"] == "E"
                        cMessage := decodeUtf8(oErrorData["dadosBeneficiario"]["statusProcessamento"][nCount]["descricaoMensagem"])

                        aAdd(aErrorData, {0, {"BR_VERMELHO",;
                                              strZero(nSequential++, 3),;
                                              oErrorData["dadosBeneficiario"]["statusProcessamento"][nCount]["codigoMensagem"],;
                                              cMessage,;
                                              getSolutionMessage(cMessage)}})
                    endif
                next nCount

                if oErrorData:hasProperty("compartilhamentoRisco") .and. oErrorData["compartilhamentoRisco"]:hasProperty("statusProcessamento") .and.;
                   valType(oErrorData["compartilhamentoRisco"]["statusProcessamento"]) == "A"

                    nLenArray := len(oErrorData["compartilhamentoRisco"]["statusProcessamento"])
                
                    for nCount := 1 to nLenArray
                        if oErrorData["compartilhamentoRisco"]["statusProcessamento"][nCount]["status"] == "E"
                            cMessage := decodeUtf8(oErrorData["compartilhamentoRisco"]["statusProcessamento"][nCount]["descricaoMensagem"])

                            aAdd(aErrorData, {0, {"BR_VERMELHO",;
                                                  strZero(nSequential++, 3),;
                                                  oErrorData["compartilhamentoRisco"]["statusProcessamento"][nCount]["codigoMensagem"],;
                                                  cMessage,;
                                                  getSolutionMessage(cMessage)}})
                        endif
                    next nCount
                endif
        endcase
    else
        aAdd(aErrorData, {0, {"", "", "", "", ""}})
    endif
    
return aErrorData

/*/{Protheus.doc} getSolutionMessage
Obter a messagem da solução de preenchimento do campo criticado
@type function
@version 12.1.2410  
@author vinicius.queiros
@since 08/08/2024
@param cMessage, character, message com a critica do campo
@return character, message com a solução do preenchimento do campo
/*/
static function getSolutionMessage(cMessage as character) as character

    local cSolutionMessage := "" as character
    local aData as array
    local nPos as numeric
    local cField as character

    aData := StrTokArr(cMessage, " ")

    if len(aData) > 0
        nPos := aScan(aData, "campo")

        if nPos > 0
            cField := aData[nPos + 1]
            cSolutionMessage := totvs.protheus.health.plan.unimed.cadBenefGetFieldSolution(cField)
        endif
    endif

    fwFreeArray(aData)

return cSolutionMessage
