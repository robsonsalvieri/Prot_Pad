#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE INSERT "03"
#DEFINE DELETE "04"
#DEFINE UPDATE "05"
#DEFINE BUSCA  "07"

Class CenReqSmcr from CenRequest

    Method New(oRest,cSvcName) Constructor
    Method destroy()
    Method applyFilter(nType)
    Method applyOrder(cOrder)
    Method buscar(nType)
    Method prepFilter()

EndClass

Method destroy()  Class CenReqSmcr
Return _Super:destroy()

Method New(oRest, cSvcName) Class CenReqSmcr
    _Super:New(oRest,cSvcName)
    self:oCollection := CenCltSmcr():New()
    self:oValidador := CenVldSmcr():New()
    self:cPropLote   := "Smcr"
Return self

Method applyFilter(nType) Class CenReqSmcr
    
    If self:lSuccess
        If nType == ALL
            self:oCollection:setValue("commitmentYear",self:oRest:commitmentYear)
            self:oCollection:setValue("commitmentCode",self:oRest:commitmentCode)
            self:oCollection:setValue("benefitAdmOperCode",self:oRest:benefitAdmOperCode)
            self:oCollection:setValue("obligationCode",self:oRest:obligationCode)
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)
            self:oCollection:setValue("trimester",self:oRest:trimester)
            self:oCollection:setValue("status",self:oRest:status)
            self:oCollection:setValue("amt1StMthTrimester",self:oRest:amt1StMthTrimester)
            self:oCollection:setValue("amt2NdMthTrimester",self:oRest:amt2NdMthTrimester)
            self:oCollection:setValue("amt3RdMthTrimester",self:oRest:amt3RdMthTrimester)

        EndIf
        If nType == SINGLE 
            self:oCollection:setValue("commitmentYear",self:oRest:commitmentYear)
            self:oCollection:setValue("commitmentCode",self:oRest:commitmentCode)
            self:oCollection:setValue("benefitAdmOperCode",self:oRest:benefitAdmOperCode)
            self:oCollection:setValue("obligationCode",self:oRest:obligationCode)
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)

        EndIf
    EndIf
Return self:lSuccess

Method applyOrder(cOrder) Class CenReqSmcr
    If self:lSuccess
        self:oCollection:applyOrder(cOrder)
    EndIf
Return self:lSuccess

Method prepFilter(oJson) Class CenReqSmcr

    Default oJson := self:jRequest
    self:oCollection:setValue("commitmentYear", self:oRest:commitmentYear)
    self:oCollection:setValue("commitmentCode", self:oRest:commitmentCode)
    self:oCollection:setValue("benefitAdmOperCode", self:oRest:benefitAdmOperCode)
    self:oCollection:setValue("obligationCode", self:oRest:obligationCode)
    self:oCollection:setValue("providerRegister", self:oRest:providerRegister)
    
    self:oCollection:mapFromJson(oJson)

Return

Method buscar(nType) Class CenReqSmcr

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


