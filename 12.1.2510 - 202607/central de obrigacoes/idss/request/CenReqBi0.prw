#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE INSERT "03"
#DEFINE DELETE "04"
#DEFINE UPDATE "05"
#DEFINE BUSCA  "07"

Class CenReqBI0 from CenRequest

    Method New(oRest,cSvcName) Constructor
    Method destroy()
    Method readPathPar(cPathKey)
    Method applyFilter(nType)
    Method applyOrder(cOrder)
    Method buscar(nType)
    Method prepFilter()

EndClass

Method destroy()  Class CenReqBI0
Return _Super:destroy()

Method New(oRest, cSvcName) Class CenReqBI0
    _Super:New(oRest,cSvcName)
    self:oCollection := CenCltBI0():New()
    self:oValidador := CenVldBI0():New()
    self:cPropLote   := "BI0"
Return self

Method readPathPar(cPathKey) Class CenReqBI0
    Local aPathKey := {}
    Default cPathKey := ""
    aPathKey := StrTokArr2(cPathKey,"|",.F.)
    If Len(aPathKey) > 1
        self:oRest:healthInsurerCode := IIf(len(aPathKey) >= 1, aPathKey[1],nil)
        self:oRest:referenceYear := IIf(len(aPathKey) >= 2, aPathKey[2],nil)

    EndIf
Return aPathKey

Method applyFilter(nType) Class CenReqBI0
    self:readPathPar(self:oRest:uniqueKey)

    If self:lSuccess
        If nType == ALL
            self:oCollection:setValue("healthInsurerCode",self:oRest:healthInsurerCode)
            self:oCollection:setValue("referenceYear",self:oRest:referenceYear)
            self:oCollection:setValue("numeratorTissRatio",self:oRest:numeratorTissRatio)
            self:oCollection:setValue("denominatorTissRatio",self:oRest:denominatorTissRatio)
            self:oCollection:setValue("partialTissRatio",self:oRest:totalTissRatio)
            self:oCollection:setValue("totalTissRatio",self:oRest:totalTissRatio)

        EndIf
        If nType == SINGLE
            self:oCollection:setValue("healthInsurerCode",self:oRest:healthInsurerCode)
            self:oCollection:setValue("referenceYear",self:oRest:referenceYear)

        EndIf
    EndIf
Return self:lSuccess

Method applyOrder(cOrder) Class CenReqBI0
    If self:lSuccess
        self:oCollection:applyOrder(cOrder)
    EndIf
Return self:lSuccess

Method prepFilter(oJson) Class CenReqBI0

    Default oJson := self:jRequest
    self:readPathPar(self:oRest:uniqueKey)
    self:oCollection:setValue("healthInsurerCode", self:oRest:healthInsurerCode)
    self:oCollection:setValue("referenceYear", self:oRest:referenceYear)

    self:oCollection:mapFromJson(oJson)

Return

Method buscar(nType) Class CenReqBI0

    Local lExiste := .F.
    If self:lSuccess
        If nType == BUSCA
            self:oCollection:buscar()
        Else
            lExiste := self:oCollection:bscChaPrim()
            If nType == INSERT
                self:lSuccess := !lExiste
            Else
                self:lSuccess := lExiste
            EndIf
        EndIf
    EndIf

Return self:lSuccess


