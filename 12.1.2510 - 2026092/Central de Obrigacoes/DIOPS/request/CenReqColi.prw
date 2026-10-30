#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE INSERT "03"
#DEFINE DELETE "04"
#DEFINE UPDATE "05"
#DEFINE BUSCA  "07"

Class CenReqColi from CenRequest

    Method New(oRest,cSvcName) Constructor
    Method destroy()
    Method applyFilter(nType)
    Method applyOrder(cOrder)
    Method buscar(nType)
    Method prepFilter()

EndClass

Method destroy()  Class CenReqColi
Return _Super:destroy()

Method New(oRest, cSvcName) Class CenReqColi
    _Super:New(oRest,cSvcName)
    self:oCollection := CenCltColi():New()
    self:oValidador := CenVldColi():New()
    self:cPropLote   := "Coli"
Return self

Method applyFilter(nType) Class CenReqColi
    
    If self:lSuccess
        If nType == ALL
            self:oCollection:setValue("legalEntityNatRegister",self:oRest:legalEntityNatRegister)
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)
            self:oCollection:setValue("quantityOfActions",self:oRest:quantityOfActions)
            self:oCollection:setValue("companyName",self:oRest:companyName)
            self:oCollection:setValue("totalOfActionsOrQuota",self:oRest:totalOfActionsOrQuota)
            self:oCollection:setValue("typeOfShare",self:oRest:typeOfShare)
            self:oCollection:setValue("companyClassification",self:oRest:companyClassification)

        EndIf
        If nType == SINGLE 
            self:oCollection:setValue("legalEntityNatRegister",self:oRest:legalEntityNatRegister)
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)

        EndIf
    EndIf
Return self:lSuccess

Method applyOrder(cOrder) Class CenReqColi
    If self:lSuccess
        self:oCollection:applyOrder(cOrder)
    EndIf
Return self:lSuccess

Method prepFilter(oJson) Class CenReqColi

    Default oJson := self:jRequest
    self:oCollection:setValue("legalEntityNatRegister", self:oRest:legalEntityNatRegister)
    self:oCollection:setValue("providerRegister", self:oRest:providerRegister)
    
    self:oCollection:mapFromJson(oJson)

Return

Method buscar(nType) Class CenReqColi

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


