#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE INSERT "03"
#DEFINE DELETE "04"
#DEFINE UPDATE "05"
#DEFINE BUSCA  "07"

Class CenReqAcio from CenRequest

    Method New(oRest,cSvcName) Constructor
    Method destroy()
    Method applyFilter(nType)
    Method applyOrder(cOrder)
    Method buscar(nType)
    Method prepFilter()

EndClass

Method destroy()  Class CenReqAcio
Return _Super:destroy()

Method New(oRest, cSvcName) Class CenReqAcio
    _Super:New(oRest,cSvcName)
    self:oCollection := CenCltAcio():New()
    self:oValidador := CenVldAcio():New()
    self:cPropLote   := "Acio"
Return self

Method applyFilter(nType) Class CenReqAcio
    
    If self:lSuccess
        If nType == ALL
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)
            self:oCollection:setValue("shareholderSCpfCnpj",self:oRest:shareholderSCpfCnpj)
            self:oCollection:setValue("corporateName",self:oRest:corporateName)
            self:oCollection:setValue("numberOfShares",self:oRest:numberOfShares)
            self:oCollection:setValue("shareholderType",self:oRest:shareholderType)

        EndIf
        If nType == SINGLE 
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)
            self:oCollection:setValue("shareholderSCpfCnpj",self:oRest:shareholderSCpfCnpj)

        EndIf
    EndIf
Return self:lSuccess

Method applyOrder(cOrder) Class CenReqAcio
    If self:lSuccess
        self:oCollection:applyOrder(cOrder)
    EndIf
Return self:lSuccess

Method prepFilter(oJson) Class CenReqAcio

    Default oJson := self:jRequest
    self:oCollection:setValue("providerRegister", self:oRest:providerRegister)
    self:oCollection:setValue("shareholderSCpfCnpj", self:oRest:shareholderSCpfCnpj)
    
    self:oCollection:mapFromJson(oJson)

Return

Method buscar(nType) Class CenReqAcio

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


