#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

Class CenVldBw8 from CenValidator

    Method New() Constructor
    Method validate(oEntity)

EndClass

Method New() Class CenVldBw8
    _Super:New()
Return self

Method validate(oEntity) Class CenVldBw8
    Local lValid  := .T.
    
    self:cMsg := ''
    lValid := self:valOpe(oEntity:getValue("operatorRecord"))
    Iif(!lValid,self:cMsg += " Operadora nao cadastrada. ",self:cMsg := self:cMsg)

    lValid := self:valDatF(oEntity)
    Iif(!lValid,self:cMsg += " Data do Fornecimento dos Itens deve ser preenchida. ",self:cMsg := self:cMsg)
    
Return lValid
