#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE INSERT "03"
#DEFINE DELETE "04"
#DEFINE UPDATE "05"
#DEFINE BUSCA  "07"

Class CenReqB8M from CenRequest

    Method New(oRest,cSvcName) Constructor
    Method destroy()
    Method readPathPar(cPathKey)
    Method applyFilter(nType)
    Method applyOrder(cOrder)
    Method buscar(nType)
    Method prepFilter()

EndClass

Method destroy()  Class CenReqB8M
Return _Super:destroy()

Method New(oRest, cSvcName) Class CenReqB8M
    _Super:New(oRest,cSvcName)
    self:oCollection := CenCltB8M():New()
    self:oValidador := CenVldB8M():New()
    self:cPropLote   := "B8M"
Return self

Method readPathPar(cPathKey) Class CenReqB8M
    Local aPathKey := {}
    Default cPathKey := ""
    aPathKey := StrTokArr2(cPathKey,"|",.F.)
    If Len(aPathKey) > 1
        self:oRest:registerNumber := IIf(len(aPathKey) >= 1, aPathKey[1],nil)
        self:oRest:operatorCnpj := IIf(len(aPathKey) >= 2, aPathKey[2],nil)
    Else
        self:oRest:registerNumber := IIf(len(aPathKey) >= 1, aPathKey[1],nil)
    EndIf
Return aPathKey

Method applyFilter(nType) Class CenReqB8M
    self:readPathPar(self:oRest:uniqueKey)

    If self:lSuccess
        If nType == ALL
            self:oCollection:setValue("registerNumber",self:oRest:registerNumber)
            self:oCollection:setValue("operatorCnpj",self:oRest:operatorCnpj)
            self:oCollection:setValue("corporateName",self:oRest:corporateName)
            self:oCollection:setValue("tradeName",self:oRest:tradeName)
            self:oCollection:setValue("legalNature",self:oRest:legalNature)
            self:oCollection:setValue("operatorMode",self:oRest:operatorMode)
            self:oCollection:setValue("operatorSegmentation",self:oRest:operatorSegmentation)

        EndIf
        If nType == SINGLE
            self:oCollection:setValue("registerNumber",self:oRest:registerNumber)
            // self:oCollection:setValue("operatorCnpj",self:oRest:operatorCnpj)

        EndIf
    EndIf
Return self:lSuccess

Method applyOrder(cOrder) Class CenReqB8M
    If self:lSuccess
        self:oCollection:applyOrder(cOrder)
    EndIf
Return self:lSuccess

Method prepFilter(oJson) Class CenReqB8M

    Default oJson := self:jRequest
    self:readPathPar(self:oRest:uniqueKey)
    self:oCollection:setValue("registerNumber", self:oRest:registerNumber)
    self:oCollection:setValue("operatorCnpj", self:oRest:operatorCnpj)

    self:oCollection:mapFromJson(oJson)

Return

Method buscar(nType) Class CenReqB8M

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


