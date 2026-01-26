#INCLUDE 'protheus.ch'
#INCLUDE 'restful.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSBCIOBSReq

@author    Lucas Nonato
@version   V12
@since     14/04/2021
/*/
class PLSBCIOBSReq from CenRequest 

    data cError 
    data oRest 
    data oJson 

    method New(oRest) constructor
    // // @Get("/api/healthcare/hat/:apiVersion/knowledgeBank")
    method put()
    method valida()

endclass

//-------------------------------------------------------------------
/*/{Protheus.doc} New

@author    Lucas Nonato
@version   V12
@since     14/04/2021
/*/
method New(oRest) class PLSBCIOBSReq 
::oRest     := oRest
::cError    := ""
::oJson     := jsonObject():new()
_Super:New(oRest,'')
return self


//-------------------------------------------------------------------
/*/{Protheus.doc} post

@author    Lucas Nonato
@version   V12
@since     14/04/2021
/*/
method put() class PLSBCIOBSReq
local oAppService   := nil

if self:valida()
    oAppService := PLSBCIOBSSvc():new(self:oRest)
    oAppService:grava(self:jRequest['notes'])
endif

return .t.

//-------------------------------------------------------------------
/*/{Protheus.doc} valida

@author    Lucas Nonato
@version   V12
@since     08/03/2021
/*/
method valida() class PLSBCIOBSReq
local cError    := ''

if empty(self:jRequest['healthProviderCode'])
    cError := "Campo obrigatório não preenchido: 'healthProviderCode'"
endif

if empty(cError)
    BCI->(dbSetOrder(14))
    if !BCI->(msseek(xFilial("BCI")+self:oRest:protocol)) .or. BCI->BCI_CODRDA <> alltrim(self:jRequest['healthProviderCode'])
        cError := "Protocolo '"+self:oRest:protocol+"' não localizado na operadora."
    endif
endif

iif(empty(cError) .and. BCI->(fieldpos("BCI_OBSERV")) <= 0, cError := "Necessário a criação do campo BCI_OBSERV ","" ) 

if !empty(cError)
    self:lSuccess     := .F.
    self:nFault       := 400
    self:nStatus      := 400
    self:cFaultDesc   := "Requisição invalida."
    self:cFaultDetail := cError
endif

return self:lSuccess