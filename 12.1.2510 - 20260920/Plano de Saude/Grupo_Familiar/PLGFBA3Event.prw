#include "protheus.ch"
#include "fwmvcdef.ch"
#include "plgfba3event.ch"

/*/{Protheus.doc} PLGFBA3Event
Classe de Eventos do MVC para validar/commit os modelos relacionados
ao cadastro da família (BA3)

@type class
@version 12.1.2310
@author vinicius.queiros
@since 24/08/2023
/*/
class PLGFBA3Event from FWModelEvent

    method new() constructor
    method after(oSubModel, cModelId, cAlias, lNewRecord)
    method before(oSubModel, cModelId, cAlias, lNewRecord)
    method afterTTS(oModel, cModelId)                                                       
    method beforeTTS(oModel, cModelId)                                                     
    method inTTS(oModel, cModelId)                                                          
    method activate(oModel, lCopy)
    method deActivate(oModel)   
    method vldActivate(oModel, cModelId)
    method modelPreVld(oModel, cModelId)
    method modelPosVld(oModel, cModelId)    
    method fieldPreVld(oSubModel, cModelID, cAction, cId, xValue)
    method fieldPosVld(oSubModel, cModelID)  

    method sendBenefObgCenter(jFamilyData, nOperation)               
 
endclass

/*/{Protheus.doc} new
Método construtor da classe

@type method
@version 12.1.2310
@author vinicius.queiros
@since 24/08/2023
@return object, objeto da classe PLGFBA3Event 
/*/
method new() class PLGFBA3Event
    
return self

/*/{Protheus.doc} after
Método que é chamado pelo MVC quando ocorrer as ações do commit
depois da gravação de cada submodelo (field ou cada linha de uma grid)

@type method
@version 12.1.2310
@author vinicius.queiros
@since 24/08/2023
@param oSubModel, object, Sub modelo
@param cModelId, character, Id do submodelo
@param cAlias, character, Alias do submodelo
@param lNewRecord, logical, Indica se é um registro novo
/*/
method after(oSubModel, cModelId, cAlias, lNewRecord) class PLGFBA3Event

return

/*/{Protheus.doc} before
Método que é chamado pelo MVC quando ocorrer as ações do commit antes 
da gravação de cada submodelo (field ou cada linha de uma grid)

@type method
@version 12.1.2310
@author vinicius.queiros
@since 24/08/2023
@param oSubModel, object, Sub modelo
@param cModelId, character, Id do submodelo
@param cAlias, character, Alias do submodelo
@param lNewRecord, logical, Indica se é um registro novo
/*/
method before(oSubModel, cModelId, cAlias, lNewRecord) class PLGFBA3Event    

return

/*/{Protheus.doc} afterTTS
Método que é chamado pelo MVC quando ocorrer as ações do  após a transação.
Esse evento ocorre uma vez no contexto do modelo principal.

@type method
@version 12.1.2310
@author vinicius.queiros
@since 24/08/2023
@param oModel, object, Modelo principal
@param cModelId, character, Id do submodelo
/*/
method afterTTS(oModel, cModelId) class PLGFBA3Event

    local nOperation := oModel:getOperation() as numeric
    local jFamilyData := JsonObject():new()

    jFamilyData["healthInsurerCode"] := BA3->BA3_CODINT
    jFamilyData["companyCode"] := BA3->BA3_CODEMP
    jFamilyData["matricCode"] := BA3->BA3_MATRIC

    if nOperation == MODEL_OPERATION_UPDATE
        self:sendBenefObgCenter(jFamilyData, nOperation)
    endif

return

/*/{Protheus.doc} beforeTTS
Método que é chamado pelo MVC quando ocorrer as ações do commit antes da transação.
Esse evento ocorre uma vez no contexto do modelo principal.

@type method
@version 12.1.2310
@author vinicius.queiros
@since 24/08/2023
@param oModel, object, Modelo principal
@param cModelId, character, Id do submodelo
/*/
method beforeTTS(oModel, cModelId) class PLGFBA3Event
    
return

/*/{Protheus.doc} inTTS
Método que é chamado pelo MVC quando ocorrer as ações do commit Após as gravações porém
antes do final da transação.
Esse evento ocorre uma vez no contexto do modelo principal.

@type method
@version 12.1.2310
@author vinicius.queiros
@since 24/08/2023
@param oModel, object, Modelo principal
@param cModelId, character, Id do submodelo
/*/
method inTTS(oModel, cModelId) class PLGFBA3Event

return

/*/{Protheus.doc} activate
Método que é chamado pelo MVC quando ocorrer a ativação do Model.
Esse evento ocorre uma vez no contexto do modelo principal.

@type method
@version 12.1.2310
@author vinicius.queiros
@since 24/08/2023
@param oModel, object, Modelo principal
@param lCopy, logical, Informa se o model deve carregar os dados do registro posicionado em operações de inclusão.
                       Essa opção é usada quando é necessário fazer uma operação de cópia.
/*/
method activate(oModel, lCopy) class PLGFBA3Event

return

/*/{Protheus.doc} deActivate
Método que é chamado pelo MVC quando ocorrer a desativação do Model.
Esse evento ocorre uma vez no contexto do modelo principal.

@type method
@version 12.1.2310
@author vinicius.queiros
@since 24/08/2023
@param oModel, object, Modelo principal
/*/
method deActivate(oModel) class PLGFBA3Event

return

/*/{Protheus.doc} vldActivate
Método que é chamado pelo MVC quando ocorrer as ações de validação do Model.
Esse evento ocorre uma vez no contexto do modelo principal.

@type method
@version 12.1.2310
@author vinicius.queiros
@since 24/08/2023
@param oModel, object, Modelo principal
@param cModelId, chararcter, Id do submodelo
@return logical, se está valido para ativação
/*/ 
method vldActivate(oModel, cModelId) class PLGFBA3Event
    
    local lOk := .t. as logical
    
return lOk

/*/{Protheus.doc} modelPreVld
Método que é chamado pelo MVC quando ocorrer as ações de pre validação do Model
Esse evento ocorre uma vez no contexto do modelo principal.

@type method
@version 12.1.2310
@author vinicius.queiros
@since 24/08/2023
@param oModel, object, Modelo principal
@param cModelId, chararcter, Id do submodelo
@return logical, se o modelo está valido antes das alterações
/*/  
method modelPreVld(oModel, cModelId) class PLGFBA3Event

    local lOK := .t. as logical

return lOK

/*/{Protheus.doc} modelPosVld
Método que é chamado pelo MVC quando ocorrer as ações de pos validação do Model
Esse evento ocorre uma vez no contexto do modelo principal.

@type method
@version 12.1.2310
@author vinicius.queiros
@since 24/08/2023
@param oModel, object, Modelo principal
@param cModelId, chararcter, Id do submodelo
@return logical, se o modelo principal está valido após as alterações
/*/ 
method modelPosVld(oModel, cModelId) class PLGFBA3Event

    local lOK := .t. as logical

return lOK

/*/{Protheus.doc} fieldPreVld
Método que é chamado pelo MVC quando ocorrer a ação de pré validação do Field

@type method
@version 12.1.2310
@author vinicius.queiros
@since 24/08/2023
@param oSubModel, object, Modelo principal
@param cModelId, character, Id do submodelo
@param cAction, character, Ação executada no grid, podendo ser: SETVALUE, CANSETVALUE
@param cId, character, nome do campo
@param xValue, variant, Novo valor do campo
@return logical, se o modelo está valido antes das alterações
/*/ 
method fieldPreVld(oSubModel, cModelID, cAction, cId, xValue) class PLGFBA3Event

    local lOK := .t. as logical

return lOK

/*/{Protheus.doc} fieldPosVld
Método que é chamado pelo MVC quando ocorrer a ação de pós validação do Field

@type method
@version 12.1.2310
@author vinicius.queiros
@since 24/08/2023
@param oSubModel, object, Modelo principal
@param cModelId, character, Id do submodelo
@return logical, se o modelo está valido após as alterações
/*/
method fieldPosVld(oSubModel, cModelID) class PLGFBA3Event 

    local lOK := .t. as logical
    
return lOK
 
/*/{Protheus.doc} sendBenefObgCenter
Método eu realiza do envio das movimentações de inclusão, alteração e exclusão
dos beneficiários da família no PLS para a Central de Obrigações

@type method
@version 12.1.2310
@author vinicius.queiros
@since 24/08/2023
@param jFamilyData, json, dados da família, sendo código da operadora,empresa e matricula
@param nOperation, numeric, operação que está sendo realizada: inclusão,alteração,exclusão
/*/
method sendBenefObgCenter(jFamilyData, nOperation) class PLGFBA3Event

    local aCritSIB := {} as array
    local oSendObgCenter as object

    oSendObgCenter := totvs.protheus.health.plan.familygroup.obligationcenter.SendBeneficiary():new()
    if oSendObgCenter:addFamily(jFamilyData, nOperation)
        if oSendObgCenter:commitSend()
            aCritSIB := oSendObgCenter:getCritSIB()

            if len(aCritSIB) > 0 .and. !isBlind()
                PlsCriGen(aCritSib, {{STR0001, "@C", 5}, {STR0002, "@C", 200}, {STR0003, "@C", 200}}, STR0004) // "Codigo Crit." ; "Descrição" ; "Solução" ; "Criticas de Beneficiários"
            endif
        endif
    endif
    oSendObgCenter:restore()

return
