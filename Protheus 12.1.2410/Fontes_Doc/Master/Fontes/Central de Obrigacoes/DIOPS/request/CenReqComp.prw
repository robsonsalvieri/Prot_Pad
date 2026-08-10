#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE INSERT "03"
#DEFINE DELETE "04"
#DEFINE UPDATE "05"
#DEFINE BUSCA  "07"

Class CenReqComp from CenRequest

    Method New(oRest,cSvcName) Constructor
    Method destroy()
    Method applyFilter(nType)
    Method applyOrder(cOrder)
    Method buscar(nType)
    Method prepFilter()

EndClass

Method destroy()  Class CenReqComp
Return _Super:destroy()

Method New(oRest, cSvcName) Class CenReqComp
    _Super:New(oRest,cSvcName)
    self:oCollection := CenCltComp():New()
    self:oValidador := CenVldComp():New()
    self:cPropLote   := "Comp"
Return self

Method applyFilter(nType) Class CenReqComp
    
    If self:lSuccess
        If nType == ALL
            self:oCollection:setValue("obligationCode",self:oRest:obligationCode)
            self:oCollection:setValue("commitmentCode",self:oRest:commitmentCode)
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)
            self:oCollection:setValue("referenceYear",self:oRest:referenceYear)
            self:oCollection:setValue("obligationType",self:oRest:obligationType)
            self:oCollection:setValue("commitmentDueDate",self:oRest:commitmentDueDate)
            self:oCollection:setValue("dueDateNotification",self:oRest:dueDateNotification)
            self:oCollection:setValue("trimester",self:oRest:trimester)
            self:oCollection:setValue("synthetizesBenefit",self:oRest:synthetizesBenefit)
            self:oCollection:setValue("status",self:oRest:status)

        EndIf
        If nType == SINGLE 
            self:oCollection:setValue("obligationCode",self:oRest:obligationCode)
            self:oCollection:setValue("commitmentCode",self:oRest:commitmentCode)
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)
            self:oCollection:setValue("referenceYear",self:oRest:referenceYear)
            self:oCollection:setValue("obligationType",self:oRest:obligationType)

        EndIf
    EndIf
Return self:lSuccess

Method applyOrder(cOrder) Class CenReqComp
    If self:lSuccess
        self:oCollection:applyOrder(cOrder)
    EndIf
Return self:lSuccess

Method prepFilter(oJson) Class CenReqComp

    Default oJson := self:jRequest
    self:oCollection:setValue("obligationCode", self:oRest:obligationCode)
    self:oCollection:setValue("commitmentCode", self:oRest:commitmentCode)
    self:oCollection:setValue("providerRegister", self:oRest:providerRegister)
    self:oCollection:setValue("referenceYear", self:oRest:referenceYear)
    self:oCollection:setValue("obligationType", self:oRest:obligationType)
    
    self:oCollection:mapFromJson(oJson)

Return

Method buscar(nType) Class CenReqComp

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


