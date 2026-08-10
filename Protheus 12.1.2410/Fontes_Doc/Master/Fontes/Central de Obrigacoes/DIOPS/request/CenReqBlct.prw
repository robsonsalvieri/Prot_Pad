#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE INSERT "03"
#DEFINE DELETE "04"
#DEFINE UPDATE "05"
#DEFINE BUSCA  "07"

Class CenReqBlct from CenRequest

    Method New(oRest,cSvcName) Constructor
    Method destroy()
    Method applyFilter(nType)
    Method applyOrder(cOrder)
    Method buscar(nType)
    Method prepFilter()

EndClass

Method destroy()  Class CenReqBlct
Return _Super:destroy()

Method New(oRest, cSvcName) Class CenReqBlct
    _Super:New(oRest,cSvcName)
    self:oCollection := CenCltBlct():New()
    self:oValidador := CenVldBlct():New()
    self:cPropLote   := "Blct"
Return self

Method applyFilter(nType) Class CenReqBlct
    
    If self:lSuccess
        If nType == ALL
            self:oCollection:setValue("commitmentYear",self:oRest:commitmentYear)
            self:oCollection:setValue("commitmentCode",self:oRest:commitmentCode)
            self:oCollection:setValue("obligationCode",self:oRest:obligationCode)
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)
            self:oCollection:setValue("accountCode",self:oRest:accountCode)
            self:oCollection:setValue("credits",self:oRest:credits)
            self:oCollection:setValue("debits",self:oRest:debits)
            self:oCollection:setValue("trimester",self:oRest:trimester)
            self:oCollection:setValue("previousBalance",self:oRest:previousBalance)
            self:oCollection:setValue("finalBalance",self:oRest:finalBalance)
            self:oCollection:setValue("status",self:oRest:status)

        EndIf
        If nType == SINGLE 
            self:oCollection:setValue("commitmentYear",self:oRest:commitmentYear)
            self:oCollection:setValue("commitmentCode",self:oRest:commitmentCode)
            self:oCollection:setValue("obligationCode",self:oRest:obligationCode)
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)
            self:oCollection:setValue("accountCode",self:oRest:accountCode)

        EndIf
    EndIf
Return self:lSuccess

Method applyOrder(cOrder) Class CenReqBlct
    If self:lSuccess
        self:oCollection:applyOrder(cOrder)
    EndIf
Return self:lSuccess

Method prepFilter(oJson) Class CenReqBlct

    Default oJson := self:jRequest
    self:oCollection:setValue("commitmentYear", self:oRest:commitmentYear)
    self:oCollection:setValue("commitmentCode", self:oRest:commitmentCode)
    self:oCollection:setValue("obligationCode", self:oRest:obligationCode)
    self:oCollection:setValue("providerRegister", self:oRest:providerRegister)
    self:oCollection:setValue("accountCode", self:oRest:accountCode)
    
    self:oCollection:mapFromJson(oJson)

Return

Method buscar(nType) Class CenReqBlct

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


