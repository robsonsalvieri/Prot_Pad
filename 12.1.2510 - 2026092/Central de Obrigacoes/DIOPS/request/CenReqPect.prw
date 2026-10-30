#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE INSERT "03"
#DEFINE DELETE "04"
#DEFINE UPDATE "05"
#DEFINE BUSCA  "07"

Class CenReqPect from CenRequest

    Method New(oRest,cSvcName) Constructor
    Method destroy()
    Method applyFilter(nType)
    Method applyOrder(cOrder)
    Method buscar(nType)
    Method prepFilter()

EndClass

Method destroy()  Class CenReqPect
Return _Super:destroy()

Method New(oRest, cSvcName) Class CenReqPect
    _Super:New(oRest,cSvcName)
    self:oCollection := CenCltPect():New()
    self:oValidador := CenVldPect():New()
    self:cPropLote   := "Pect"
Return self

Method applyFilter(nType) Class CenReqPect
    
    If self:lSuccess
        If nType == ALL
            self:oCollection:setValue("commitmentCode",self:oRest:commitmentCode)
            self:oCollection:setValue("obligationCode",self:oRest:obligationCode)
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)
            self:oCollection:setValue("counterpartCoveragePeri",self:oRest:counterpartCoveragePeri)
            self:oCollection:setValue("planType",self:oRest:planType)
            self:oCollection:setValue("commitmentYear",self:oRest:commitmentYear)
            self:oCollection:setValue("valueToExpire",self:oRest:valueToExpire)
            self:oCollection:setValue("receivedValue",self:oRest:receivedValue)
            self:oCollection:setValue("trimester",self:oRest:trimester)
            self:oCollection:setValue("status",self:oRest:status)
            self:oCollection:setValue("dueValueInArrears",self:oRest:dueValueInArrears)
            self:oCollection:setValue("netIssuedValue",self:oRest:netIssuedValue)

        EndIf
        If nType == SINGLE 
            self:oCollection:setValue("commitmentCode",self:oRest:commitmentCode)
            self:oCollection:setValue("obligationCode",self:oRest:obligationCode)
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)
            self:oCollection:setValue("counterpartCoveragePeri",self:oRest:counterpartCoveragePeri)
            self:oCollection:setValue("planType",self:oRest:planType)
            self:oCollection:setValue("commitmentYear",self:oRest:commitmentYear)

        EndIf
    EndIf
Return self:lSuccess

Method applyOrder(cOrder) Class CenReqPect
    If self:lSuccess
        self:oCollection:applyOrder(cOrder)
    EndIf
Return self:lSuccess

Method prepFilter(oJson) Class CenReqPect

    Default oJson := self:jRequest
    self:oCollection:setValue("commitmentCode", self:oRest:commitmentCode)
    self:oCollection:setValue("obligationCode", self:oRest:obligationCode)
    self:oCollection:setValue("providerRegister", self:oRest:providerRegister)
    self:oCollection:setValue("counterpartCoveragePeri", self:oRest:counterpartCoveragePeri)
    self:oCollection:setValue("planType", self:oRest:planType)
    self:oCollection:setValue("commitmentYear", self:oRest:commitmentYear)
    
    self:oCollection:mapFromJson(oJson)

Return

Method buscar(nType) Class CenReqPect

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


