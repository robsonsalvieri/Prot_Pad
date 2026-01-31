#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE INSERT "03"
#DEFINE DELETE "04"
#DEFINE UPDATE "05"
#DEFINE BUSCA  "07"

Class CenReqAgim from CenRequest

    Method New(oRest,cSvcName) Constructor
    Method destroy()
    Method applyFilter(nType)
    Method applyOrder(cOrder)
    Method buscar(nType)
    Method prepFilter()

EndClass

Method destroy()  Class CenReqAgim
Return _Super:destroy()

Method New(oRest, cSvcName) Class CenReqAgim
    _Super:New(oRest,cSvcName)
    self:oCollection := CenCltAgim():New()
    self:oValidador := CenVldAgim():New()
    self:cPropLote   := "Agim"
Return self

Method applyFilter(nType) Class CenReqAgim
    
    If self:lSuccess
        If nType == ALL
            self:oCollection:setValue("commitmentCode",self:oRest:commitmentCode)
            self:oCollection:setValue("obligationCode",self:oRest:obligationCode)
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)
            self:oCollection:setValue("realEstateGeneralRegis",self:oRest:realEstateGeneralRegis)
            self:oCollection:setValue("commitmentYear",self:oRest:commitmentYear)
            self:oCollection:setValue("assitance",self:oRest:assitance)
            self:oCollection:setValue("ownNetwork",self:oRest:ownNetwork)
            self:oCollection:setValue("trimester",self:oRest:trimester)
            self:oCollection:setValue("status",self:oRest:status)
            self:oCollection:setValue("validityEndDate",self:oRest:validityEndDate)
            self:oCollection:setValue("validityStartDate",self:oRest:validityStartDate)
            self:oCollection:setValue("accountingValue",self:oRest:accountingValue)

        EndIf
        If nType == SINGLE 
            self:oCollection:setValue("commitmentCode",self:oRest:commitmentCode)
            self:oCollection:setValue("obligationCode",self:oRest:obligationCode)
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)
            self:oCollection:setValue("realEstateGeneralRegis",self:oRest:realEstateGeneralRegis)
            self:oCollection:setValue("commitmentYear",self:oRest:commitmentYear)

        EndIf
    EndIf
Return self:lSuccess

Method applyOrder(cOrder) Class CenReqAgim
    If self:lSuccess
        self:oCollection:applyOrder(cOrder)
    EndIf
Return self:lSuccess

Method prepFilter(oJson) Class CenReqAgim

    Default oJson := self:jRequest
    self:oCollection:setValue("commitmentCode", self:oRest:commitmentCode)
    self:oCollection:setValue("obligationCode", self:oRest:obligationCode)
    self:oCollection:setValue("providerRegister", self:oRest:providerRegister)
    self:oCollection:setValue("realEstateGeneralRegis", self:oRest:realEstateGeneralRegis)
    self:oCollection:setValue("commitmentYear", self:oRest:commitmentYear)
    
    self:oCollection:mapFromJson(oJson)

Return

Method buscar(nType) Class CenReqAgim

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


