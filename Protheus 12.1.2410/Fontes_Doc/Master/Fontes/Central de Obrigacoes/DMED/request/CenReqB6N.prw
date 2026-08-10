#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE INSERT "03"
#DEFINE DELETE "04"
#DEFINE UPDATE "05"
#DEFINE BUSCA  "07"

Class CenReqB6N from CenRequest

    Method New(oRest,cSvcName) Constructor
    Method destroy()
    Method readPathPar(cPathKey)
    Method applyFilter(nType)
    Method applyOrder(cOrder)
    Method buscar(nType)
    Method prepFilter()

EndClass

Method destroy()  Class CenReqB6N
Return _Super:destroy()

Method New(oRest, cSvcName) Class CenReqB6N
    _Super:New(oRest,cSvcName)
    self:oCollection := CenCltB6N():New()
    self:oValidador := CenVldB6N():New()
    self:cPropLote   := "B6N"
Return self

Method readPathPar(cPathKey) Class CenReqB6N
    Local aPathKey := {}
    Default cPathKey := ""
    aPathKey := StrTokArr2(cPathKey,"|",.F.)
    If Len(aPathKey) > 1
        self:oRest:healthInsurerCode := IIf(len(aPathKey) >= 1, aPathKey[1],nil)
        self:oRest:ssn := IIf(len(aPathKey) >= 2, aPathKey[2],nil)

    EndIf
Return aPathKey

Method applyFilter(nType) Class CenReqB6N
    self:readPathPar(self:oRest:uniqueKey)

    If self:lSuccess
        If nType == ALL
            self:oCollection:setValue("healthInsurerCode",self:oRest:healthInsurerCode)
            self:oCollection:setValue("ssn",self:oRest:ssn)
            self:oCollection:setValue("name",self:oRest:name)
            self:oCollection:setValue("areaCode",self:oRest:areaCode)
            self:oCollection:setValue("phoneNumber",self:oRest:phoneNumber)
            self:oCollection:setValue("extensionLine",self:oRest:extensionLine)
            self:oCollection:setValue("fax",self:oRest:fax)
            self:oCollection:setValue("eMail",self:oRest:eMail)
            self:oCollection:setValue("active",self:oRest:active)

        EndIf
        If nType == SINGLE
            self:oCollection:setValue("healthInsurerCode",self:oRest:healthInsurerCode)
            self:oCollection:setValue("ssn",self:oRest:ssn)

        EndIf
    EndIf
Return self:lSuccess

Method applyOrder(cOrder) Class CenReqB6N
    If self:lSuccess
        self:oCollection:applyOrder(cOrder)
    EndIf
Return self:lSuccess

Method prepFilter(oJson) Class CenReqB6N

    Default oJson := self:jRequest
    self:readPathPar(self:oRest:uniqueKey)
    self:oCollection:setValue("healthInsurerCode", self:oRest:healthInsurerCode)
    self:oCollection:setValue("ssn", self:oRest:ssn)

    self:oCollection:mapFromJson(oJson)

Return

Method buscar(nType) Class CenReqB6N

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


