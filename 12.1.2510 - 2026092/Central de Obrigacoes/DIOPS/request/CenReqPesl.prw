#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE INSERT "03"
#DEFINE DELETE "04"
#DEFINE UPDATE "05"
#DEFINE BUSCA  "07"

Class CenReqPesl from CenRequest

    Method New(oRest,cSvcName) Constructor
    Method destroy()
    Method applyFilter(nType)
    Method applyOrder(cOrder)
    Method buscar(nType)
    Method prepFilter()

EndClass

Method destroy()  Class CenReqPesl
Return _Super:destroy()

Method New(oRest, cSvcName) Class CenReqPesl
    _Super:New(oRest,cSvcName)
    self:oCollection := CenCltPesl():New()
    self:oValidador := CenVldPesl():New()
    self:cPropLote   := "Pesl"
Return self

Method applyFilter(nType) Class CenReqPesl
    
    If self:lSuccess
        If nType == ALL
            self:oCollection:setValue("commitmentCode",self:oRest:commitmentCode)
            self:oCollection:setValue("obligationCode",self:oRest:obligationCode)
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)
            self:oCollection:setValue("commitmentYear",self:oRest:commitmentYear)
            self:oCollection:setValue("evCorrAssumMajorPer",self:oRest:evCorrAssumMajorPer)
            self:oCollection:setValue("lastDaysAssumCorrEv",self:oRest:lastDaysAssumCorrEv)
            self:oCollection:setValue("greaterDangerLossEvent",self:oRest:greaterDangerLossEvent)
            self:oCollection:setValue("latestDaysEvents",self:oRest:latestDaysEvents)
            self:oCollection:setValue("noOfBeneficiaries",self:oRest:noOfBeneficiaries)
            self:oCollection:setValue("trimester",self:oRest:trimester)
            self:oCollection:setValue("status",self:oRest:status)

        EndIf
        If nType == SINGLE 
            self:oCollection:setValue("commitmentCode",self:oRest:commitmentCode)
            self:oCollection:setValue("obligationCode",self:oRest:obligationCode)
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)
            self:oCollection:setValue("commitmentYear",self:oRest:commitmentYear)

        EndIf
    EndIf
Return self:lSuccess

Method applyOrder(cOrder) Class CenReqPesl
    If self:lSuccess
        self:oCollection:applyOrder(cOrder)
    EndIf
Return self:lSuccess

Method prepFilter(oJson) Class CenReqPesl

    Default oJson := self:jRequest
    self:oCollection:setValue("commitmentCode", self:oRest:commitmentCode)
    self:oCollection:setValue("obligationCode", self:oRest:obligationCode)
    self:oCollection:setValue("providerRegister", self:oRest:providerRegister)
    self:oCollection:setValue("commitmentYear", self:oRest:commitmentYear)
    
    self:oCollection:mapFromJson(oJson)

Return

Method buscar(nType) Class CenReqPesl

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


