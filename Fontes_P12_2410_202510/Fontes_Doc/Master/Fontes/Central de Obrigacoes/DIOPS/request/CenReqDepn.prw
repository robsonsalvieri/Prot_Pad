#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE INSERT "03"
#DEFINE DELETE "04"
#DEFINE UPDATE "05"
#DEFINE BUSCA  "07"

Class CenReqDepn from CenRequest

    Method New(oRest,cSvcName) Constructor
    Method destroy()
    Method applyFilter(nType)
    Method applyOrder(cOrder)
    Method buscar(nType)
    Method prepFilter()

EndClass

Method destroy()  Class CenReqDepn
Return _Super:destroy()

Method New(oRest, cSvcName) Class CenReqDepn
    _Super:New(oRest,cSvcName)
    self:oCollection := CenCltDepn():New()
    self:oValidador := CenVldDepn():New()
    self:cPropLote   := "Depn"
Return self

Method applyFilter(nType) Class CenReqDepn
    
    If self:lSuccess
        If nType == ALL
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)
            self:oCollection:setValue("legalEntityNatRegister",self:oRest:legalEntityNatRegister)
            self:oCollection:setValue("postAddrCode",self:oRest:postAddrCode)
            self:oCollection:setValue("longDistanceCode",self:oRest:longDistanceCode)
            self:oCollection:setValue("internationalCallinfCd",self:oRest:internationalCallinfCd)
            self:oCollection:setValue("district",self:oRest:district)
            self:oCollection:setValue("ibgeCityCode",self:oRest:ibgeCityCode)
            self:oCollection:setValue("addressComplement",self:oRest:addressComplement)
            self:oCollection:setValue("eMail",self:oRest:eMail)
            self:oCollection:setValue("addressName",self:oRest:addressName)
            self:oCollection:setValue("corporateName",self:oRest:corporateName)
            self:oCollection:setValue("addressNumber",self:oRest:addressNumber)
            self:oCollection:setValue("extensionLine",self:oRest:extensionLine)
            self:oCollection:setValue("stateAcronym",self:oRest:stateAcronym)
            self:oCollection:setValue("telephoneNumber",self:oRest:telephoneNumber)
            self:oCollection:setValue("dependenceType",self:oRest:dependenceType)

        EndIf
        If nType == SINGLE 
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)
            self:oCollection:setValue("legalEntityNatRegister",self:oRest:legalEntityNatRegister)

        EndIf
    EndIf
Return self:lSuccess

Method applyOrder(cOrder) Class CenReqDepn
    If self:lSuccess
        self:oCollection:applyOrder(cOrder)
    EndIf
Return self:lSuccess

Method prepFilter(oJson) Class CenReqDepn

    Default oJson := self:jRequest
    self:oCollection:setValue("providerRegister", self:oRest:providerRegister)
    self:oCollection:setValue("legalEntityNatRegister", self:oRest:legalEntityNatRegister)
    
    self:oCollection:mapFromJson(oJson)

Return

Method buscar(nType) Class CenReqDepn

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


