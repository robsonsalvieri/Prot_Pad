#include "protheus.ch"
#include "fwmvcdef.ch"

PUBLISH MODEL REST NAME addBeneficiaryProtocol SOURCE PLINCBENMODEL RESOURCE OBJECT PLBenProtRestModel
PUBLISH MODEL REST NAME updBeneficiaryProtocol SOURCE PLALTBENMODEL RESOURCE OBJECT PLBenProtRestModel

/*/{Protheus.doc} PLBenProtRestModel
Classe responsável por gerenciar os acessos ao modelo de dados (MVC) do protocolo de inclusão de beneficiários
da rotina de Analise de beneficiários
@type class
@version 12.1.2510  
@author vinicius.queiros
@since 10/04/2025
*/
class PLBenProtRestModel from FwRestModel

    public method activate() as logical

    private method validateBeneficiaryAccess() as logical
    private method getProtocolBeneficiaryData() as json

endclass

/*/{Protheus.doc} activate
Realiza a ativação do modelo REST associado ao protocolo de beneficiários.
@type method
@version 12.1.2510
@author vinicius.queiros
@since 10/04/2025
*/
method activate() class PLBenProtRestModel

    self:lActivate := self:validateBeneficiaryAccess()

return self:lActivate

/*/{Protheus.doc} validateBeneficiaryAccess
Valida o acesso do usuário ao beneficiário.
@type method
@version 12.1.2510
@author vinicius.queiros
@since 10/04/2025
@return logical, Indica se o acesso ao beneficiário é válido.
*/
method validateBeneficiaryAccess() as logical class PLBenProtRestModel

    local aRequiredParams as array
    local lHasAccess := .F. as logical
    local lAccessBeneficiary as logical
    local oController := totvs.protheus.health.plan.api.util.BaseController():new() as object
    local jBeneficiaryData := self:getProtocolBeneficiaryData(oRest:getBodyRequest()) as json

    lAccessBeneficiary := jBeneficiaryData:hasProperty("subscriberId")

    if lAccessBeneficiary
        aRequiredParams := {"subscriberId"}
    else
        aRequiredParams := {"healthInsurerCode", "companyCode", "contractCode", "contractVersion", "subcontractCode", "subcontractVersion"}
    endif

    if oController:validatePortalUserAccess() .and. oController:validateRequiredParams(jBeneficiaryData, aRequiredParams)
        if lAccessBeneficiary
            lHasAccess := oController:hasAccessToBeneficiary(jBeneficiaryData["subscriberId"])
        else
            lHasAccess := oController:hasAccessToContract(jBeneficiaryData)
        endif
    endif

    oController:destroy()
    freeObj(oController)
    freeObj(jBeneficiaryData)
    fwFreeArray(aRequiredParams)

return lHasAccess

/*/{Protheus.doc} getProtocolBeneficiaryData
Retorna os dados do beneficiário com base nas informações do corpo da requisição.
@type method
@version 12.1.2510
@author vinicius.queiros
@since 10/04/2025
@param cBody, character, conteúdo da requisição em formato JSON
@return json, dados do beneficiário extraídos do protocolo
*/
method getProtocolBeneficiaryData(cBody as character) as json class PLBenProtRestModel

    local jBeneficiaryData := JsonObject():new() as json
    local jBody := JsonObject():new() as json
    local cError as character
    local nX, nY as numeric
    local nSizeModels as numeric
    local nSizeFields as numeric
    local cField as character
    local xValue as variant
    local jProperties := JsonObject():new() as json

    jProperties["BBA_CODINT"] := "healthInsurerCode"
    jProperties["BBA_CODEMP"] := "companyCode"
    jProperties["BBA_CONEMP"] := "contractCode"
    jProperties["BBA_VERCON"] := "contractVersion"
    jProperties["BBA_SUBCON"] := "subcontractCode"
    jProperties["BBA_VERSUB"] := "subcontractVersion"
    jProperties["BBA_MATRIC"] := "subscriberId"

    cError := jBody:fromJson(cBody)

    if empty(cError)
        if jBody:hasProperty("models")
            nSizeModels := len(jBody["models"]) 

            for nX := 1 to nSizeModels
                if jBody["models"][nX]["id"] == "MASTERBBA"
                    nSizeFields := len(jBody["models"][nX]["fields"])

                    for nY := 1 to nSizeFields
                        cField := jBody["models"][nX]["fields"][nY]["id"]
                        xValue := jBody["models"][nX]["fields"][nY]["value"]

                        if jProperties:hasProperty(cField) .and. !empty(xValue)
                            jBeneficiaryData[jProperties[cField]] := xValue
                        endif
                    next nY
                endif
            next nX
        endif		
    endif

    freeObj(jBody)
    freeObj(jProperties)

return jBeneficiaryData
