#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

Class CenVldB2V from CenValidator
    Data cMsg 
    Data oApiVal 

    Method New() Constructor
    Method validate(oEntity)

EndClass

Method New() Class CenVldB2V
    _Super:New()
Return self

Method validate(oEntity) Class CenVldB2V
    Local lValid  := .T.
    
    self:cMsg := ''
    lValid := self:valOpe(oEntity:getValue("operatorRecord"))
    Iif(!lValid,self:cMsg += " Operadora nao cadastrada. ",self:cMsg := self:cMsg)

    lValid := self:valDatF(oEntity)
    Iif(!lValid,self:cMsg += " Data do Fornecimento dos Itens deve ser preenchida. ",self:cMsg := self:cMsg)
  
Return lValid
