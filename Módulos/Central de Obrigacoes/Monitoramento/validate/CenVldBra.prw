#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

Class CenVldBra from CenValidator

    Method New() Constructor
    Method validate(oEntity)

EndClass

Method New(oRest) Class CenVldBra
    _Super:New(oRest)
Return self

Method validate(oEntity) Class CenVldBra
    Local lValid     := .T.
    local aDateFormt := .T.
    
    self:cMsg := ''
    lValid    := self:valOpe(oEntity:getValue("operatorRecord"))
    Iif(!lValid,self:cMsg += " Operadora nao cadastrada. ",self:cMsg := self:cMsg)
    
    lValid := self:valDatF(oEntity)
    Iif(!lValid,self:cMsg += " Data do Fornecimento dos Itens deve ser preenchida. ",self:cMsg := self:cMsg)

    aDateFormt := self:valFormDt(oEntity)
    If !aDateFormt[1]
        self:cMsg += aDateFormt[2]
        lValid := aDateFormt[1]
    EndIf

Return lValid
