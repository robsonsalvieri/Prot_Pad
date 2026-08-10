#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE INSERT "03"
#DEFINE DELETE "04"
#DEFINE UPDATE "05"
#DEFINE BUSCA  "07"

Class CenReqLcpr from CenRequest

    Method New(oRest,cSvcName) Constructor
    Method destroy()
    Method applyFilter(nType)
    Method applyOrder(cOrder)
    Method buscar(nType)
    Method prepFilter()

EndClass

Method destroy()  Class CenReqLcpr
Return _Super:destroy()

Method New(oRest, cSvcName) Class CenReqLcpr
    _Super:New(oRest,cSvcName)
    self:oCollection := CenCltLcpr():New()
    self:oValidador := CenVldLcpr():New()
    self:cPropLote   := "Lcpr"
Return self

Method applyFilter(nType) Class CenReqLcpr
    
    If self:lSuccess
        If nType == ALL
            self:oCollection:setValue("commitmentYear",self:oRest:commitmentYear)
            self:oCollection:setValue("commitmentCode",self:oRest:commitmentCode)
            self:oCollection:setValue("obligationCode",self:oRest:obligationCode)
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)
            self:oCollection:setValue("accountCode",self:oRest:accountCode)
            self:oCollection:setValue("description",self:oRest:description)
            self:oCollection:setValue("trimester",self:oRest:trimester)
            self:oCollection:setValue("status",self:oRest:status)
            self:oCollection:setValue("accountingValue",self:oRest:accountingValue)

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

Method applyOrder(cOrder) Class CenReqLcpr
    If self:lSuccess
        self:oCollection:applyOrder(cOrder)
    EndIf
Return self:lSuccess

Method prepFilter(oJson) Class CenReqLcpr

    Default oJson := self:jRequest
    self:oCollection:setValue("commitmentYear", self:oRest:commitmentYear)
    self:oCollection:setValue("commitmentCode", self:oRest:commitmentCode)
    self:oCollection:setValue("obligationCode", self:oRest:obligationCode)
    self:oCollection:setValue("providerRegister", self:oRest:providerRegister)
    self:oCollection:setValue("accountCode", self:oRest:accountCode)
    
    self:oCollection:mapFromJson(oJson)

Return

Method buscar(nType) Class CenReqLcpr

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


