#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE INSERT "03"
#DEFINE DELETE "04"
#DEFINE UPDATE "05"
#DEFINE BUSCA  "07"

Class CenReqSaid from CenRequest

    Method New(oRest,cSvcName) Constructor
    Method destroy()
    Method applyFilter(nType)
    Method applyOrder(cOrder)
    Method buscar(nType)
    Method prepFilter()

EndClass

Method destroy()  Class CenReqSaid
Return _Super:destroy()

Method New(oRest, cSvcName) Class CenReqSaid
    _Super:New(oRest,cSvcName)
    self:oCollection := CenCltSaid():New()
    self:oValidador := CenVldSaid():New()
    self:cPropLote   := "Said"
Return self

Method applyFilter(nType) Class CenReqSaid
    
    If self:lSuccess
        If nType == ALL
            self:oCollection:setValue("commitmentCode",self:oRest:commitmentCode)
            self:oCollection:setValue("obligationCode",self:oRest:obligationCode)
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)
            self:oCollection:setValue("commitmentYear",self:oRest:commitmentYear)
            self:oCollection:setValue("financialDueDate",self:oRest:financialDueDate)
            self:oCollection:setValue("debWPortfAcquis",self:oRest:debWPortfAcquis)
            self:oCollection:setValue("mktOnOperations",self:oRest:mktOnOperations)
            self:oCollection:setValue("debitsWithOperators",self:oRest:debitsWithOperators)
            self:oCollection:setValue("benefDepContrapIns",self:oRest:benefDepContrapIns)
            self:oCollection:setValue("eventClaimNetPres",self:oRest:eventClaimNetPres)
            self:oCollection:setValue("eventClaimNetSus",self:oRest:eventClaimNetSus)
            self:oCollection:setValue("otherDebOprWPlan",self:oRest:otherDebOprWPlan)
            self:oCollection:setValue("otherDebitsToPay",self:oRest:otherDebitsToPay)
            self:oCollection:setValue("trimester",self:oRest:trimester)
            self:oCollection:setValue("hthCareServProv",self:oRest:hthCareServProv)
            self:oCollection:setValue("status",self:oRest:status)
            self:oCollection:setValue("billsChargesCollect",self:oRest:billsChargesCollect)

        EndIf
        If nType == SINGLE 
            self:oCollection:setValue("commitmentCode",self:oRest:commitmentCode)
            self:oCollection:setValue("obligationCode",self:oRest:obligationCode)
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)
            self:oCollection:setValue("commitmentYear",self:oRest:commitmentYear)
            self:oCollection:setValue("financialDueDate",self:oRest:financialDueDate)

        EndIf
    EndIf
Return self:lSuccess

Method applyOrder(cOrder) Class CenReqSaid
    If self:lSuccess
        self:oCollection:applyOrder(cOrder)
    EndIf
Return self:lSuccess

Method prepFilter(oJson) Class CenReqSaid

    Default oJson := self:jRequest
    self:oCollection:setValue("commitmentCode", self:oRest:commitmentCode)
    self:oCollection:setValue("obligationCode", self:oRest:obligationCode)
    self:oCollection:setValue("providerRegister", self:oRest:providerRegister)
    self:oCollection:setValue("commitmentYear", self:oRest:commitmentYear)
    self:oCollection:setValue("financialDueDate", self:oRest:financialDueDate)
    
    self:oCollection:mapFromJson(oJson)

Return

Method buscar(nType) Class CenReqSaid

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


