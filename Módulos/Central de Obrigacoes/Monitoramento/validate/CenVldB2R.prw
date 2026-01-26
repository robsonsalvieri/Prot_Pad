#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

Class CenVldB2R from CenValidator
    Data cMsg 
    Data oApiVal 

    Method New() Constructor
    Method validate(oEntity)

EndClass

Method New() Class CenVldB2R
    _Super:New()
Return self

Method validate(oEntity) Class CenVldB2R
    Local lValid  := .T.
    
    self:cMsg := ''
    lValid := self:valOpe(oEntity:getValue("operatorRecord"))
    Iif(!lValid,self:cMsg += " Operadora nao cadastrada. ",self:cMsg := self:cMsg)
    
Return lValid
