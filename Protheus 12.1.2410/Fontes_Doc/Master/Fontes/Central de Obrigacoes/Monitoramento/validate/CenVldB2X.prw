#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

Class CenVldB2X from CenValidator

    Method New() Constructor
    Method validate(oEntity)

EndClass

Method New() Class CenVldB2X
    _Super:New()
Return self

Method validate(oEntity) Class CenVldB2X
    Local lValid  := .T.
    Local aValPer := {}
    Local aValIde := {}
    
    self:cMsg := ''
    lValid := self:valOpe(oEntity:getValue("operatorRecord"))
    If !lValid
        self:cMsg += " Operadora nao cadastrada. "
        Return lValid
    EndIf    
    aValPer := self:valPer(oEntity)
    If aValPer[1] == .F.
        lValid  := .F.
        self:cMsg += aValPer[2]
        Return lValid
    EndIf
    aValIde := self:valIdent(oEntity)
    If aValIde[1] == .F.
        lValid  := .F.
        self:cMsg += aValIde[2]
    EndIf

Return lValid
