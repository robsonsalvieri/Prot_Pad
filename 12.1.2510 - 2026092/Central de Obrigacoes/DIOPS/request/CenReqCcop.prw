#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE INSERT "03"
#DEFINE DELETE "04"
#DEFINE UPDATE "05"
#DEFINE BUSCA  "07"

Class CenReqCcop from CenRequest

    Method New(oRest,cSvcName) Constructor
    Method destroy()
    Method applyFilter(nType)
    Method applyOrder(cOrder)
    Method buscar(nType)
    Method prepFilter()

EndClass

Method destroy()  Class CenReqCcop
Return _Super:destroy()

Method New(oRest, cSvcName) Class CenReqCcop
    _Super:New(oRest,cSvcName)
    self:oCollection := CenCltCcop():New()
    self:oValidador := CenVldCcop():New()
    self:cPropLote   := "Ccop"
Return self

Method applyFilter(nType) Class CenReqCcop
    
    If self:lSuccess
        If nType == ALL
            self:oCollection:setValue("commitmentCode",self:oRest:commitmentCode)
            self:oCollection:setValue("obligationCode",self:oRest:obligationCode)
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)
            self:oCollection:setValue("taxName",self:oRest:taxName)
            self:oCollection:setValue("periodDate",self:oRest:periodDate)
            self:oCollection:setValue("taxType",self:oRest:taxType)
            self:oCollection:setValue("commitmentYear",self:oRest:commitmentYear)
            self:oCollection:setValue("monetaryUpdate",self:oRest:monetaryUpdate)
            self:oCollection:setValue("amtPaidTrimester",self:oRest:amtPaidTrimester)
            self:oCollection:setValue("totalAmtFinanced",self:oRest:totalAmtFinanced)
            self:oCollection:setValue("totalAmtPaid",self:oRest:totalAmtPaid)
            self:oCollection:setValue("dateAdhesionToRefis",self:oRest:dateAdhesionToRefis)
            self:oCollection:setValue("numberOfInstallments",self:oRest:numberOfInstallments)
            self:oCollection:setValue("numbDueInstallments",self:oRest:numbDueInstallments)
            self:oCollection:setValue("numbOfPaidInstallm",self:oRest:numbOfPaidInstallm)
            self:oCollection:setValue("trimester",self:oRest:trimester)
            self:oCollection:setValue("trimesterFinalBalance",self:oRest:trimesterFinalBalance)
            self:oCollection:setValue("trimesterInitialBalance",self:oRest:trimesterInitialBalance)
            self:oCollection:setValue("status",self:oRest:status)

        EndIf
        If nType == SINGLE 
            self:oCollection:setValue("commitmentCode",self:oRest:commitmentCode)
            self:oCollection:setValue("obligationCode",self:oRest:obligationCode)
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)
            self:oCollection:setValue("taxName",self:oRest:taxName)
            self:oCollection:setValue("periodDate",self:oRest:periodDate)
            self:oCollection:setValue("taxType",self:oRest:taxType)
            self:oCollection:setValue("commitmentYear",self:oRest:commitmentYear)

        EndIf
    EndIf
Return self:lSuccess

Method applyOrder(cOrder) Class CenReqCcop
    If self:lSuccess
        self:oCollection:applyOrder(cOrder)
    EndIf
Return self:lSuccess

Method prepFilter(oJson) Class CenReqCcop

    Default oJson := self:jRequest
    self:oCollection:setValue("commitmentCode", self:oRest:commitmentCode)
    self:oCollection:setValue("obligationCode", self:oRest:obligationCode)
    self:oCollection:setValue("providerRegister", self:oRest:providerRegister)
    self:oCollection:setValue("taxName", self:oRest:taxName)
    self:oCollection:setValue("periodDate", self:oRest:periodDate)
    self:oCollection:setValue("taxType", self:oRest:taxType)
    self:oCollection:setValue("commitmentYear", self:oRest:commitmentYear)
    
    self:oCollection:mapFromJson(oJson)

Return

Method buscar(nType) Class CenReqCcop

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


