#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE INSERT "03"
#DEFINE DELETE "04"
#DEFINE UPDATE "05"
#DEFINE BUSCA  "07"

Class CenReqRepr from CenRequest

    Method New(oRest,cSvcName) Constructor
    Method destroy()
    Method applyFilter(nType)
    Method applyOrder(cOrder)
    Method buscar(nType)
    Method prepFilter()

EndClass

Method destroy()  Class CenReqRepr
Return _Super:destroy()

Method New(oRest, cSvcName) Class CenReqRepr
    _Super:New(oRest,cSvcName)
    self:oCollection := CenCltRepr():New()
    self:oValidador := CenVldRepr():New()
    self:cPropLote   := "Repr"
Return self

Method applyFilter(nType) Class CenReqRepr
    
    If self:lSuccess
        If nType == ALL
            self:oCollection:setValue("registrationOfIndividua",self:oRest:registrationOfIndividua)
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)
            self:oCollection:setValue("addressComplement",self:oRest:addressComplement)
            self:oCollection:setValue("district",self:oRest:district)
            self:oCollection:setValue("representativeSPosition",self:oRest:representativeSPosition)
            self:oCollection:setValue("ibgeCityCode",self:oRest:ibgeCityCode)
            self:oCollection:setValue("postAddrCode",self:oRest:postAddrCode)
            self:oCollection:setValue("nationalCallingCd",self:oRest:nationalCallingCd)
            self:oCollection:setValue("internationalCallinfCd",self:oRest:internationalCallinfCd)
            self:oCollection:setValue("idIssueDate",self:oRest:idIssueDate)
            self:oCollection:setValue("addressName",self:oRest:addressName)
            self:oCollection:setValue("representativeSName",self:oRest:representativeSName)
            self:oCollection:setValue("idNumber",self:oRest:idNumber)
            self:oCollection:setValue("addressNumber",self:oRest:addressNumber)
            self:oCollection:setValue("idIssuingBody",self:oRest:idIssuingBody)
            self:oCollection:setValue("country",self:oRest:country)
            self:oCollection:setValue("extension",self:oRest:extension)
            self:oCollection:setValue("stateAcronym",self:oRest:stateAcronym)
            self:oCollection:setValue("telephoneNumber",self:oRest:telephoneNumber)

        EndIf
        If nType == SINGLE 
            self:oCollection:setValue("registrationOfIndividua",self:oRest:registrationOfIndividua)
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)

        EndIf
    EndIf
Return self:lSuccess

Method applyOrder(cOrder) Class CenReqRepr
    If self:lSuccess
        self:oCollection:applyOrder(cOrder)
    EndIf
Return self:lSuccess

Method prepFilter(oJson) Class CenReqRepr

    Default oJson := self:jRequest
    self:oCollection:setValue("registrationOfIndividua", self:oRest:registrationOfIndividua)
    self:oCollection:setValue("providerRegister", self:oRest:providerRegister)
    
    self:oCollection:mapFromJson(oJson)

Return

Method buscar(nType) Class CenReqRepr

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


