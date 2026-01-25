#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE INSERT "03"
#DEFINE DELETE "04"
#DEFINE UPDATE "05"
#DEFINE BUSCA  "07"

Class CenReqPact from CenRequest

    Method New(oRest,cSvcName) Constructor
    Method destroy()
    Method applyFilter(nType)
    Method applyOrder(cOrder)
    Method buscar(nType)
    Method prepFilter()

EndClass

Method destroy()  Class CenReqPact
Return _Super:destroy()

Method New(oRest, cSvcName) Class CenReqPact
    _Super:New(oRest,cSvcName)
    self:oCollection := CenCltPact():New()
    self:oValidador := CenVldPact():New()
    self:cPropLote   := "Pact"
Return self

Method applyFilter(nType) Class CenReqPact

    If self:lSuccess
        If nType == ALL
            self:oCollection:setValue("commitmentCode",self:oRest:commitmentCode)
            self:oCollection:setValue("obligationCode",self:oRest:obligationCode)
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)
            self:oCollection:setValue("accountCode",self:oRest:accountCode)
            self:oCollection:setValue("commitmentYear",self:oRest:commitmentYear)
            self:oCollection:setValue("monetaryUpdate",self:oRest:monetaryUpdate)
            self:oCollection:setValue("competenceDate",self:oRest:competenceDate)
            self:oCollection:setValue("trimester",self:oRest:trimester)
            self:oCollection:setValue("balanceAtTheEndOfThe",self:oRest:balanceAtTheEndOfThe)
            self:oCollection:setValue("status",self:oRest:status)
            self:oCollection:setValue("initialValue",self:oRest:initialValue)
            self:oCollection:setValue("valuePaid",self:oRest:valuePaid)

        EndIf
        If nType == SINGLE
            self:oCollection:setValue("commitmentCode",self:oRest:commitmentCode)
            self:oCollection:setValue("obligationCode",self:oRest:obligationCode)
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)
            self:oCollection:setValue("accountCode",self:oRest:accountCode)
            self:oCollection:setValue("commitmentYear",self:oRest:commitmentYear)

        EndIf
    EndIf
Return self:lSuccess

Method applyOrder(cOrder) Class CenReqPact
    If self:lSuccess
        self:oCollection:applyOrder(cOrder)
    EndIf
Return self:lSuccess

Method prepFilter(oJson) Class CenReqPact

    Default oJson := self:jRequest
    self:oCollection:setValue("commitmentCode", self:oRest:commitmentCode)
    self:oCollection:setValue("obligationCode", self:oRest:obligationCode)
    self:oCollection:setValue("providerRegister", self:oRest:providerRegister)
    self:oCollection:setValue("accountCode", self:oRest:accountCode)
    self:oCollection:setValue("commitmentYear", self:oRest:commitmentYear)

    self:oCollection:mapFromJson(oJson)

Return

Method buscar(nType) Class CenReqPact

    Local lExiste := .F.
    If self:lSuccess
        If nType == BUSCA
            self:oCollection:buscar()
        Else
            lExiste := self:oCollection:bscChaPrim()
            If nType == INSERT
                // Sempre que receber um post ele grava um BUY_SEQUEN auto geravél,
                // marcelo está avaliando se eu posso ter a mesma conta dentro do mesmo trimestre.
                // self:lSuccess := !lExiste
                self:lSuccess := .T.
            Else
                self:lSuccess := lExiste
            EndIf
        EndIf
    EndIf

Return self:lSuccess


