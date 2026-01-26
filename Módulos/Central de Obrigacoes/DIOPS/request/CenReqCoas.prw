#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE INSERT "03"
#DEFINE DELETE "04"
#DEFINE UPDATE "05"
#DEFINE BUSCA  "07"

Class CenReqCoas from CenRequest

    Method New(oRest,cSvcName) Constructor
    Method destroy()
    Method applyFilter(nType)
    Method applyOrder(cOrder)
    Method buscar(nType)
    Method prepFilter()

EndClass

Method destroy()  Class CenReqCoas
Return _Super:destroy()

Method New(oRest, cSvcName) Class CenReqCoas
    _Super:New(oRest,cSvcName)
    self:oCollection := CenCltCoas():New()
    self:oValidador := CenVldCoas():New()
    self:cPropLote   := "Coas"
Return self

Method applyFilter(nType) Class CenReqCoas
    
    If self:lSuccess
        If nType == ALL
            self:oCollection:setValue("commitmentYear",self:oRest:commitmentYear)
            self:oCollection:setValue("commitmentCode",self:oRest:commitmentCode)
            self:oCollection:setValue("obligationCode",self:oRest:obligationCode)
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)
            self:oCollection:setValue("typeOfPlan",self:oRest:typeOfPlan)
            self:oCollection:setValue("paymentOrigin",self:oRest:paymentOrigin)
            self:oCollection:setValue("otherPayments",self:oRest:otherPayments)
            self:oCollection:setValue("trimester",self:oRest:trimester)
            self:oCollection:setValue("status",self:oRest:status)
            self:oCollection:setValue("therapies",self:oRest:therapies)
            self:oCollection:setValue("medicalAppointment",self:oRest:medicalAppointment)
            self:oCollection:setValue("otherExpenses",self:oRest:otherExpenses)
            self:oCollection:setValue("examinations",self:oRest:examinations)
            self:oCollection:setValue("hospitalizations",self:oRest:hospitalizations)

        EndIf
        If nType == SINGLE 
            self:oCollection:setValue("commitmentYear",self:oRest:commitmentYear)
            self:oCollection:setValue("commitmentCode",self:oRest:commitmentCode)
            self:oCollection:setValue("obligationCode",self:oRest:obligationCode)
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)
            self:oCollection:setValue("typeOfPlan",self:oRest:typeOfPlan)
            self:oCollection:setValue("paymentOrigin",self:oRest:paymentOrigin)

        EndIf
    EndIf
Return self:lSuccess

Method applyOrder(cOrder) Class CenReqCoas
    If self:lSuccess
        self:oCollection:applyOrder(cOrder)
    EndIf
Return self:lSuccess

Method prepFilter(oJson) Class CenReqCoas

    Default oJson := self:jRequest
    self:oCollection:setValue("commitmentYear", self:oRest:commitmentYear)
    self:oCollection:setValue("commitmentCode", self:oRest:commitmentCode)
    self:oCollection:setValue("obligationCode", self:oRest:obligationCode)
    self:oCollection:setValue("providerRegister", self:oRest:providerRegister)
    self:oCollection:setValue("typeOfPlan", self:oRest:typeOfPlan)
    self:oCollection:setValue("paymentOrigin", self:oRest:paymentOrigin)
    
    self:oCollection:mapFromJson(oJson)

Return

Method buscar(nType) Class CenReqCoas

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


