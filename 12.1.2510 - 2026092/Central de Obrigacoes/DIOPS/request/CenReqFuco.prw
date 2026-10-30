#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE INSERT "03"
#DEFINE DELETE "04"
#DEFINE UPDATE "05"
#DEFINE BUSCA  "07"

Class CenReqFuco from CenRequest

    Method New(oRest,cSvcName) Constructor
    Method destroy()
    Method applyFilter(nType)
    Method applyOrder(cOrder)
    Method buscar(nType)
    Method prepFilter()

EndClass

Method destroy()  Class CenReqFuco
Return _Super:destroy()

Method New(oRest, cSvcName) Class CenReqFuco
    _Super:New(oRest,cSvcName)
    self:oCollection := CenCltFuco():New()
    self:oValidador := CenVldFuco():New()
    self:cPropLote   := "Fuco"
Return self

Method applyFilter(nType) Class CenReqFuco
    
    If self:lSuccess
        If nType == ALL
            self:oCollection:setValue("commitmentYear",self:oRest:commitmentYear)
            self:oCollection:setValue("commitmentCode",self:oRest:commitmentCode)
            self:oCollection:setValue("cnpjOrFundAnsRec",self:oRest:cnpjOrFundAnsRec)
            self:oCollection:setValue("obligationCode",self:oRest:obligationCode)
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)
            self:oCollection:setValue("fundType",self:oRest:fundType)
            self:oCollection:setValue("fundName",self:oRest:fundName)
            self:oCollection:setValue("trimester",self:oRest:trimester)
            self:oCollection:setValue("creditBalanceOfFund",self:oRest:creditBalanceOfFund)
            self:oCollection:setValue("debitorBalanceOfFund",self:oRest:debitorBalanceOfFund)
            self:oCollection:setValue("status",self:oRest:status)

        EndIf
        If nType == SINGLE 
            self:oCollection:setValue("commitmentYear",self:oRest:commitmentYear)
            self:oCollection:setValue("commitmentCode",self:oRest:commitmentCode)
            self:oCollection:setValue("cnpjOrFundAnsRec",self:oRest:cnpjOrFundAnsRec)
            self:oCollection:setValue("obligationCode",self:oRest:obligationCode)
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)
            self:oCollection:setValue("fundType",self:oRest:fundType)

        EndIf
    EndIf
Return self:lSuccess

Method applyOrder(cOrder) Class CenReqFuco
    If self:lSuccess
        self:oCollection:applyOrder(cOrder)
    EndIf
Return self:lSuccess

Method prepFilter(oJson) Class CenReqFuco

    Default oJson := self:jRequest
    self:oCollection:setValue("commitmentYear", self:oRest:commitmentYear)
    self:oCollection:setValue("commitmentCode", self:oRest:commitmentCode)
    self:oCollection:setValue("cnpjOrFundAnsRec", self:oRest:cnpjOrFundAnsRec)
    self:oCollection:setValue("obligationCode", self:oRest:obligationCode)
    self:oCollection:setValue("providerRegister", self:oRest:providerRegister)
    self:oCollection:setValue("fundType", self:oRest:fundType)
    
    self:oCollection:mapFromJson(oJson)

Return

Method buscar(nType) Class CenReqFuco

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


