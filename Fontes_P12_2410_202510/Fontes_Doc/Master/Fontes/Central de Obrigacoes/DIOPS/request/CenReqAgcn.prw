#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE INSERT "03"
#DEFINE DELETE "04"
#DEFINE UPDATE "05"
#DEFINE BUSCA  "07"

Class CenReqAgcn from CenRequest

    Method New(oRest,cSvcName) Constructor
    Method destroy()
    Method applyFilter(nType)
    Method applyOrder(cOrder)
    Method buscar(nType)
    Method prepFilter()

EndClass

Method destroy()  Class CenReqAgcn
Return _Super:destroy()

Method New(oRest, cSvcName) Class CenReqAgcn
    _Super:New(oRest,cSvcName)
    self:oCollection := CenCltAgcn():New()
    self:oValidador := CenVldAgcn():New()
    self:cPropLote   := "Agcn"
Return self

Method applyFilter(nType) Class CenReqAgcn
    
    If self:lSuccess
        If nType == ALL
            self:oCollection:setValue("commitmentYear",self:oRest:commitmentYear)
            self:oCollection:setValue("commitmentCode",self:oRest:commitmentCode)
            self:oCollection:setValue("obligationCode",self:oRest:obligationCode)
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)
            self:oCollection:setValue("riskPool",self:oRest:riskPool)
            self:oCollection:setValue("pceCorresponGranted",self:oRest:pceCorresponGranted)
            self:oCollection:setValue("pceIssuedCounterprov",self:oRest:pceIssuedCounterprov)
            self:oCollection:setValue("eveClaimsKnownPce",self:oRest:eveClaimsKnownPce)
            self:oCollection:setValue("plaCorresponGranted",self:oRest:plaCorresponGranted)
            self:oCollection:setValue("issuedConsiderationsPla",self:oRest:issuedConsiderationsPla)
            self:oCollection:setValue("plaKnowlLossEvents",self:oRest:plaKnowlLossEvents)
            self:oCollection:setValue("trimester",self:oRest:trimester)
            self:oCollection:setValue("status",self:oRest:status)

        EndIf
        If nType == SINGLE 
            self:oCollection:setValue("commitmentYear",self:oRest:commitmentYear)
            self:oCollection:setValue("commitmentCode",self:oRest:commitmentCode)
            self:oCollection:setValue("obligationCode",self:oRest:obligationCode)
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)
            self:oCollection:setValue("riskPool",self:oRest:riskPool)

        EndIf
    EndIf
Return self:lSuccess

Method applyOrder(cOrder) Class CenReqAgcn
    If self:lSuccess
        self:oCollection:applyOrder(cOrder)
    EndIf
Return self:lSuccess

Method prepFilter(oJson) Class CenReqAgcn

    Default oJson := self:jRequest
    self:oCollection:setValue("commitmentYear", self:oRest:commitmentYear)
    self:oCollection:setValue("commitmentCode", self:oRest:commitmentCode)
    self:oCollection:setValue("obligationCode", self:oRest:obligationCode)
    self:oCollection:setValue("providerRegister", self:oRest:providerRegister)
    self:oCollection:setValue("riskPool", self:oRest:riskPool)
    
    self:oCollection:mapFromJson(oJson)

Return

Method buscar(nType) Class CenReqAgcn

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


