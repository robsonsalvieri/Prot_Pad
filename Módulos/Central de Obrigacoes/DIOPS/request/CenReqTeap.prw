#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE INSERT "03"
#DEFINE DELETE "04"
#DEFINE UPDATE "05"
#DEFINE BUSCA  "07"

Class CenReqTeap from CenRequest

    Method New(oRest,cSvcName) Constructor
    Method destroy()
    Method applyFilter(nType)
    Method applyOrder(cOrder)
    Method buscar(nType)
    Method prepFilter()

EndClass

Method destroy()  Class CenReqTeap
Return _Super:destroy()

Method New(oRest, cSvcName) Class CenReqTeap
    _Super:New(oRest,cSvcName)
    self:oCollection := CenCltTeap():New()
    self:oValidador := CenVldTeap():New()
    self:cPropLote   := "Teap"
Return self

Method applyFilter(nType) Class CenReqTeap
    
    If self:lSuccess
        If nType == ALL
            self:oCollection:setValue("commitmentYear",self:oRest:commitmentYear)
            self:oCollection:setValue("commitmentCode",self:oRest:commitmentCode)
            self:oCollection:setValue("obligationCode",self:oRest:obligationCode)
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)
            self:oCollection:setValue("planType",self:oRest:planType)
            self:oCollection:setValue("contractCancelRate",self:oRest:contractCancelRate)
            self:oCollection:setValue("biomTabAdjustment",self:oRest:biomTabAdjustment)
            self:oCollection:setValue("cashFlowAdjEstimation",self:oRest:cashFlowAdjEstimation)
            self:oCollection:setValue("utiOfRangesRn632003",self:oRest:utiOfRangesRn632003)
            self:oCollection:setValue("estimatedMedicalInflati",self:oRest:estimatedMedicalInflati)
            self:oCollection:setValue("ettjInterMethod",self:oRest:ettjInterMethod)
            self:oCollection:setValue("averageAdjustmentPerVa",self:oRest:averageAdjustmentPerVa)
            self:oCollection:setValue("estimatedMaximumAdjustm",self:oRest:estimatedMaximumAdjustm)
            self:oCollection:setValue("trimester",self:oRest:trimester)
            self:oCollection:setValue("status",self:oRest:status)

        EndIf
        If nType == SINGLE 
            self:oCollection:setValue("commitmentYear",self:oRest:commitmentYear)
            self:oCollection:setValue("commitmentCode",self:oRest:commitmentCode)
            self:oCollection:setValue("obligationCode",self:oRest:obligationCode)
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)
            self:oCollection:setValue("planType",self:oRest:planType)

        EndIf
    EndIf
Return self:lSuccess

Method applyOrder(cOrder) Class CenReqTeap
    If self:lSuccess
        self:oCollection:applyOrder(cOrder)
    EndIf
Return self:lSuccess

Method prepFilter(oJson) Class CenReqTeap

    Default oJson := self:jRequest
    self:oCollection:setValue("commitmentYear", self:oRest:commitmentYear)
    self:oCollection:setValue("commitmentCode", self:oRest:commitmentCode)
    self:oCollection:setValue("obligationCode", self:oRest:obligationCode)
    self:oCollection:setValue("providerRegister", self:oRest:providerRegister)
    self:oCollection:setValue("planType", self:oRest:planType)
    
    self:oCollection:mapFromJson(oJson)

Return

Method buscar(nType) Class CenReqTeap

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


