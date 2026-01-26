#include "protheus.ch"
#include "fwmvcdef.ch"
#include "plgfba1event.ch"

/*/{Protheus.doc} PLGFBA1Event
Classe de Eventos do MVC para validar/commit os modelos relacionados
ao cadastro do beneficiário (BA1)

@type class
@version 12.1.2310
@author vinicius.queiros
@since 11/08/2023
/*/
class PLGFBA1Event from FWModelEvent

    data lJuriContract as logical

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
    method gridPosVld(oSubModel, cModelID)
    method gridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue)
    method gridLinePosVld(oSubModel, cModelID, nLine)                                       
    method fieldPreVld(oSubModel, cModelID, cAction, cId, xValue)
    method fieldPosVld(oSubModel, cModelID)  

    method sendBenefObgCenter(cSubscriberId, nOperation)               
 
endclass

/*/{Protheus.doc} new
Método construtor da classe

@type method
@version 12.1.2310
@author vinicius.queiros
@since 11/08/2023
@return object, objeto da classe PLGFBA1Event 
/*/
method new() class PLGFBA1Event
    
    self:lJuriContract := .f.

return self

/*/{Protheus.doc} after
Método que é chamado pelo MVC quando ocorrer as ações do commit
depois da gravação de cada submodelo (field ou cada linha de uma grid)

@type method
@version 12.1.2310
@author vinicius.queiros
@since 11/08/2023
@param oSubModel, object, Sub modelo
@param cModelId, character, Id do submodelo
@param cAlias, character, Alias do submodelo
@param lNewRecord, logical, Indica se é um registro novo
/*/
method after(oSubModel, cModelId, cAlias, lNewRecord) class PLGFBA1Event
return

/*/{Protheus.doc} before
Método que é chamado pelo MVC quando ocorrer as ações do commit antes 
da gravação de cada submodelo (field ou cada linha de uma grid)

@type method
@version 12.1.2310
@author vinicius.queiros
@since 11/08/2023
@param oSubModel, object, Sub modelo
@param cModelId, character, Id do submodelo
@param cAlias, character, Alias do submodelo
@param lNewRecord, logical, Indica se é um registro novo
/*/
method before(oSubModel, cModelId, cAlias, lNewRecord) class PLGFBA1Event    

return

/*/{Protheus.doc} afterTTS
Método que é chamado pelo MVC quando ocorrer as ações do  após a transação.
Esse evento ocorre uma vez no contexto do modelo principal.

@type method
@version 12.1.2310
@author vinicius.queiros
@since 11/08/2023
@param oModel, object, Modelo principal
@param cModelId, character, Id do submodelo
/*/
method afterTTS(oModel, cModelId) class PLGFBA1Event

    local nOperation := oModel:getOperation() as numeric
    local cSubscriberId := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) as chararcter

    if nOperation <> MODEL_OPERATION_VIEW .and. nOperation <> MODEL_OPERATION_DELETE 
        self:sendBenefObgCenter(cSubscriberId, nOperation)
    endif

return

/*/{Protheus.doc} beforeTTS
Método que é chamado pelo MVC quando ocorrer as ações do commit antes da transação.
Esse evento ocorre uma vez no contexto do modelo principal.

@type method
@version 12.1.2310
@author vinicius.queiros
@since 11/08/2023
@param oModel, object, Modelo principal
@param cModelId, character, Id do submodelo
/*/
method beforeTTS(oModel, cModelId) class PLGFBA1Event

    local nOperation := oModel:getOperation() as numeric
    local cSubscriberId := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) as chararcter

    if nOperation == MODEL_OPERATION_DELETE 
        self:sendBenefObgCenter(cSubscriberId, nOperation)
    endif
    
return

/*/{Protheus.doc} inTTS
Método que é chamado pelo MVC quando ocorrer as ações do commit Após as gravações porém
antes do final da transação.
Esse evento ocorre uma vez no contexto do modelo principal.

@type method
@version 12.1.2310
@author vinicius.queiros
@since 11/08/2023
@param oModel, object, Modelo principal
@param cModelId, character, Id do submodelo
/*/
method inTTS(oModel, cModelId) class PLGFBA1Event

return

/*/{Protheus.doc} activate
Método que é chamado pelo MVC quando ocorrer a ativação do Model.
Esse evento ocorre uma vez no contexto do modelo principal.

@type method
@version 12.1.2310
@author vinicius.queiros
@since 11/08/2023
@param oModel, object, Modelo principal
@param lCopy, logical, Informa se o model deve carregar os dados do registro posicionado em operações de inclusão.
                       Essa opção é usada quando é necessário fazer uma operação de cópia.
/*/
method activate(oModel, lCopy) class PLGFBA1Event

return

/*/{Protheus.doc} deActivate
Método que é chamado pelo MVC quando ocorrer a desativação do Model.
Esse evento ocorre uma vez no contexto do modelo principal.

@type method
@version 12.1.2310
@author vinicius.queiros
@since 11/08/2023
@param oModel, object, Modelo principal
/*/
method deActivate(oModel) class PLGFBA1Event

return

/*/{Protheus.doc} vldActivate
Método que é chamado pelo MVC quando ocorrer as ações de validação do Model.
Esse evento ocorre uma vez no contexto do modelo principal.

@type method
@version 12.1.2310
@author vinicius.queiros
@since 11/08/2023
@param oModel, object, Modelo principal
@param cModelId, chararcter, Id do submodelo
@return logical, se está valido para ativação
/*/ 
method vldActivate(oModel, cModelId) class PLGFBA1Event
    
    local lOk := .t. as logical
    local nOperation := oModel:getOperation() as numeric

    self:lJuriContract := !empty(BA1->BA1_CONEMP)

    if nOperation <> MODEL_OPERATION_VIEW
        if self:lJuriContract
            BQC->(dbSetOrder(1))
            if BQC->(msSeek(xFilial("BQC")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)))
                if !empty(BQC->BQC_DATBLO) .and. !empty(BQC->BQC_CODBLO)
                    help(nil, nil, STR0001, nil, STR0002, 1, 0, nil, nil, nil, nil, nil, {STR0003}) // "Subcontrato Bloqueado"; "Este subcontrato encontra-se bloqueado. só será permitido a visualização dos registos já existentes!"; "Sair"
                    lOk := .f.
                endif
            endif
        endif
    endif

    if lOk .and. nOperation <> MODEL_OPERATION_INSERT .and. nOperation <> MODEL_OPERATION_VIEW
        BA3->(dbSetorder(1))
		if BA3->(msSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))
			if !empty(BA3->BA3_MOTBLO)
                help(nil, nil, STR0004, nil, STR0005, 1, 0, nil, nil, nil, nil, nil, {STR0003}) // "Família Bloqueada"; "Esta família encontra-se bloqueada, o registo poderá ser apenas visualizado."; "Sair"
                lOk := .f.
			endif
		endif

        if lOk .and. !empty(BA1->BA1_MOTBLO)
            help(nil, nil, STR0006, nil, STR0007, 1, 0, nil, nil, nil, nil, nil, {STR0003}) // "Beneficiário Bloqueado"; "Este beneficiário encontra-se bloqueado, o registro somente podera ser visualizado."; "Sair"
            lOk := .f.
        endif
    endif

return lOk

/*/{Protheus.doc} modelPreVld
Método que é chamado pelo MVC quando ocorrer as ações de pre validação do Model
Esse evento ocorre uma vez no contexto do modelo principal.

@type method
@version 12.1.2310
@author vinicius.queiros
@since 11/08/2023
@param oModel, object, Modelo principal
@param cModelId, chararcter, Id do submodelo
@return logical, se o modelo está valido antes das alterações
/*/  
method modelPreVld(oModel, cModelId) class PLGFBA1Event

    local lOK := .t. as logical

return lOK

/*/{Protheus.doc} modelPosVld
Método que é chamado pelo MVC quando ocorrer as ações de pos validação do Model
Esse evento ocorre uma vez no contexto do modelo principal.

@type method
@version 12.1.2310
@author vinicius.queiros
@since 11/08/2023
@param oModel, object, Modelo principal
@param cModelId, chararcter, Id do submodelo
@return logical, se o modelo principal está valido após as alterações
/*/ 
method modelPosVld(oModel, cModelId) class PLGFBA1Event

    local lOK := .t. as logical

return lOK

/*/{Protheus.doc} gridPosVld
Método que é chamado pelo MVC quando ocorrer as ações de pós validação do Grid

@type method
@version 12.1.2310
@author vinicius.queiros
@since 11/08/2023
@param oSubModel, object, Modelo principal
@param cModelId, chararcter, Id do submodelo
@return logical, se o modelo está valido após as alterações
/*/ 
method gridPosVld(oSubModel, cModelID) class PLGFBA1Event

    local lOK := .t. as logical
    
return lOK

/*/{Protheus.doc} gridLinePreVld
Método que é chamado pelo MVC quando ocorrer as ações de pre validação da linha do Grid

@type method
@version 12.1.2310
@author vinicius.queiros
@since 11/08/2023
@param oSubModel, object, Modelo principal
@param cModelId, chararcter, Id do submodelo
@param nLine, numeric, Linha do grid
@param cAction, chararcter, Ação executada no grid, podendo ser: UNDELETE, DELETE, SETVALUE, CANSETVALUE
@param cId, chararcter, nome do campo
@param xValue, variant, Novo valor do campo
@param xCurrentValue, variant, Valor atual do campo
@return logical, se o modelo está valido antes das alterações
/*/ 
method gridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) class PLGFBA1Event

    local lOK := .t. as logical
    
return lOK

/*/{Protheus.doc} gridLinePosVld
Método que é chamado pelo MVC quando ocorrer as ações de pos validação da linha do Grid

@type method
@version 12.1.2310
@author vinicius.queiros
@since 11/08/2023
@param oSubModel, object, Modelo principal
@param cModelId, chararcter, Id do submodelo
@param nLine, numeric, Linha do grid
@return logical, se o modelo está valido após as alterações
/*/  
method gridLinePosVld(oSubModel, cModelID, nLine) class PLGFBA1Event 

    Local lOK := .t. as logical
    
return lOK

/*/{Protheus.doc} fieldPreVld
Método que é chamado pelo MVC quando ocorrer a ação de pré validação do Field

@type method
@version 12.1.2310
@author vinicius.queiros
@since 11/08/2023
@param oSubModel, object, Modelo principal
@param cModelId, character, Id do submodelo
@param cAction, character, Ação executada no grid, podendo ser: SETVALUE, CANSETVALUE
@param cId, character, nome do campo
@param xValue, variant, Novo valor do campo
@return logical, se o modelo está valido antes das alterações
/*/ 
method fieldPreVld(oSubModel, cModelID, cAction, cId, xValue) class PLGFBA1Event

    local lOK := .t. as logical

return lOK

/*/{Protheus.doc} fieldPosVld
Método que é chamado pelo MVC quando ocorrer a ação de pós validação do Field

@type method
@version 12.1.2310
@author vinicius.queiros
@since 11/08/2023
@param oSubModel, object, Modelo principal
@param cModelId, character, Id do submodelo
@return logical, se o modelo está valido após as alterações
/*/
method fieldPosVld(oSubModel, cModelID) class PLGFBA1Event 

    local lOK := .t. as logical
    
return lOK

/*/{Protheus.doc} sendBenefObgCenter
Realiza o envio das movimentações de inclusão, alteração e exclusão
do beneficiário no PLS para a Central de Obrigações

@type method
@version 12.1.2310
@author vinicius.queiros
@since 24/08/2023
@param cSubscriberId, character, matricula completa do beneficiário
@param nOperation, numeric, operação que está sendo realizada: inclusão,alteração,exclusão
/*/
method sendBenefObgCenter(cSubscriberId, nOperation) class PLGFBA1Event

    local aCritSIB := {} as array
    local oSendObgCenter as object

    oSendObgCenter := totvs.protheus.health.plan.familygroup.obligationcenter.SendBeneficiary():new()
    if oSendObgCenter:addBeneficiary(cSubscriberId, nOperation)
        if oSendObgCenter:commitSend()
            aCritSIB := oSendObgCenter:getCritSIB()

            if len(aCritSIB) > 0 .and. !isBlind()
                PlsCriGen(aCritSib, {{STR0008, "@C", 5}, {STR0009, "@C", 200}, {STR0010, "@C", 200}}, STR0011) // "Codigo Crit." ; "Descrição" ; "Solução" ; "Criticas de Beneficiários"
            endif
        endif
    endif
    oSendObgCenter:restore()

return
