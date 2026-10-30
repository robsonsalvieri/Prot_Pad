#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE INSERT "03"
#DEFINE DELETE "04"
#DEFINE UPDATE "05"
#DEFINE BUSCA  "07"

Class CenReqSpid from CenRequest

    Method New(oRest,cSvcName) Constructor
    Method destroy()
    Method applyFilter(nType)
    Method applyOrder(cOrder)
    Method buscar(nType)
    Method prepFilter()

EndClass

Method destroy()  Class CenReqSpid
Return _Super:destroy()

Method New(oRest, cSvcName) Class CenReqSpid
    _Super:New(oRest,cSvcName)
    self:oCollection := CenCltSpid():New()
    self:oValidador := CenVldSpid():New()
    self:cPropLote   := "Spid"
Return self

Method applyFilter(nType) Class CenReqSpid
    
    If self:lSuccess
        If nType == ALL
            self:oCollection:setValue("commitmentYear",self:oRest:commitmentYear)
            self:oCollection:setValue("commitmentCode",self:oRest:commitmentCode)
            self:oCollection:setValue("obligationCode",self:oRest:obligationCode)
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)
            self:oCollection:setValue("financialDueDate",self:oRest:financialDueDate)
            self:oCollection:setValue("collectiveFloating",self:oRest:collectiveFloating)
            self:oCollection:setValue("collectiveFixed",self:oRest:collectiveFixed)
            self:oCollection:setValue("beneficiariesOperationC",self:oRest:beneficiariesOperationC)
            self:oCollection:setValue("postPaymentOperCredit",self:oRest:postPaymentOperCredit)
            self:oCollection:setValue("individualFloating",self:oRest:individualFloating)
            self:oCollection:setValue("individualFixed",self:oRest:individualFixed)
            self:oCollection:setValue("prePaymentOperatorsCre",self:oRest:prePaymentOperatorsCre)
            self:oCollection:setValue("otherCreditsWithPlan",self:oRest:otherCreditsWithPlan)
            self:oCollection:setValue("otherCredNotRelatPlan",self:oRest:otherCredNotRelatPlan)
            self:oCollection:setValue("partBenefInEveClaim",self:oRest:partBenefInEveClaim)
            self:oCollection:setValue("trimester",self:oRest:trimester)
            self:oCollection:setValue("status",self:oRest:status)

        EndIf
        If nType == SINGLE 
            self:oCollection:setValue("commitmentYear",self:oRest:commitmentYear)
            self:oCollection:setValue("commitmentCode",self:oRest:commitmentCode)
            self:oCollection:setValue("obligationCode",self:oRest:obligationCode)
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)
            self:oCollection:setValue("financialDueDate",self:oRest:financialDueDate)

        EndIf
    EndIf
Return self:lSuccess

Method applyOrder(cOrder) Class CenReqSpid
    If self:lSuccess
        self:oCollection:applyOrder(cOrder)
    EndIf
Return self:lSuccess

Method prepFilter(oJson) Class CenReqSpid

    Default oJson := self:jRequest
    self:oCollection:setValue("commitmentYear", self:oRest:commitmentYear)
    self:oCollection:setValue("commitmentCode", self:oRest:commitmentCode)
    self:oCollection:setValue("obligationCode", self:oRest:obligationCode)
    self:oCollection:setValue("providerRegister", self:oRest:providerRegister)
    self:oCollection:setValue("financialDueDate", self:oRest:financialDueDate)
    
    self:oCollection:mapFromJson(oJson)

Return

Method buscar(nType) Class CenReqSpid

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


