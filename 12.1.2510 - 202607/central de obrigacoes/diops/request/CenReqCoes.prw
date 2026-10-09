#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE INSERT "03"
#DEFINE DELETE "04"
#DEFINE UPDATE "05"
#DEFINE BUSCA  "07"

Class CenReqCoes from CenRequest

    Method New(oRest,cSvcName) Constructor
    Method destroy()
    Method applyFilter(nType)
    Method applyOrder(cOrder)
    Method buscar(nType)
    Method prepFilter()

EndClass

Method destroy()  Class CenReqCoes
Return _Super:destroy()

Method New(oRest, cSvcName) Class CenReqCoes
    _Super:New(oRest,cSvcName)
    self:oCollection := CenCltCoes():New()
    self:oValidador := CenVldCoes():New()
    self:cPropLote   := "Coes"
Return self

Method applyFilter(nType) Class CenReqCoes
    
    If self:lSuccess
        If nType == ALL
            self:oCollection:setValue("commitmentYear",self:oRest:commitmentYear)
            self:oCollection:setValue("commitmentCode",self:oRest:commitmentCode)
            self:oCollection:setValue("obligationCode",self:oRest:obligationCode)
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)
            self:oCollection:setValue("operatorRecordInAns",self:oRest:operatorRecordInAns)
            self:oCollection:setValue("trimester",self:oRest:trimester)
            self:oCollection:setValue("status",self:oRest:status)
            self:oCollection:setValue("billingValue",self:oRest:billingValue)

        EndIf
        If nType == SINGLE 
            self:oCollection:setValue("commitmentYear",self:oRest:commitmentYear)
            self:oCollection:setValue("commitmentCode",self:oRest:commitmentCode)
            self:oCollection:setValue("obligationCode",self:oRest:obligationCode)
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)
            self:oCollection:setValue("operatorRecordInAns",self:oRest:operatorRecordInAns)
            self:oCollection:setValue("trimester",self:oRest:trimester)

        EndIf
    EndIf
Return self:lSuccess

Method applyOrder(cOrder) Class CenReqCoes
    If self:lSuccess
        self:oCollection:applyOrder(cOrder)
    EndIf
Return self:lSuccess

Method prepFilter(oJson) Class CenReqCoes

    Default oJson := self:jRequest
    self:oCollection:setValue("commitmentYear", self:oRest:commitmentYear)
    self:oCollection:setValue("commitmentCode", self:oRest:commitmentCode)
    self:oCollection:setValue("obligationCode", self:oRest:obligationCode)
    self:oCollection:setValue("providerRegister", self:oRest:providerRegister)
    self:oCollection:setValue("operatorRecordInAns", self:oRest:operatorRecordInAns)
    self:oCollection:setValue("trimester", self:oRest:trimester)
    
    self:oCollection:mapFromJson(oJson)

Return

Method buscar(nType) Class CenReqCoes

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


