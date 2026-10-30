#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE INSERT "03"
#DEFINE DELETE "04"
#DEFINE UPDATE "05"
#DEFINE BUSCA  "07"

Class CenReqResp from CenRequest

    Method New(oRest,cSvcName) Constructor
    Method destroy()
    Method applyFilter(nType)
    Method applyOrder(cOrder)
    Method buscar(nType)
    Method prepFilter()

EndClass

Method destroy()  Class CenReqResp
Return _Super:destroy()

Method New(oRest, cSvcName) Class CenReqResp
    _Super:New(oRest,cSvcName)
    self:oCollection := CenCltResp():New()
    self:oValidador := CenVldResp():New()
    self:cPropLote   := "Resp"
Return self

Method applyFilter(nType) Class CenReqResp
    
    If self:lSuccess
        If nType == ALL
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)
            self:oCollection:setValue("cpfCnpj",self:oRest:cpfCnpj)
            self:oCollection:setValue("responsibleLeOrIndivid",self:oRest:responsibleLeOrIndivid)
            self:oCollection:setValue("responsibilityType",self:oRest:responsibilityType)
            self:oCollection:setValue("nameCorporateName",self:oRest:nameCorporateName)
            self:oCollection:setValue("recordNumber",self:oRest:recordNumber)

        EndIf
        If nType == SINGLE 
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)
            self:oCollection:setValue("cpfCnpj",self:oRest:cpfCnpj)
            self:oCollection:setValue("responsibleLeOrIndivid",self:oRest:responsibleLeOrIndivid)
            self:oCollection:setValue("responsibilityType",self:oRest:responsibilityType)

        EndIf
    EndIf
Return self:lSuccess

Method applyOrder(cOrder) Class CenReqResp
    If self:lSuccess
        self:oCollection:applyOrder(cOrder)
    EndIf
Return self:lSuccess

Method prepFilter(oJson) Class CenReqResp

    Default oJson := self:jRequest
    self:oCollection:setValue("providerRegister", self:oRest:providerRegister)
    self:oCollection:setValue("cpfCnpj", self:oRest:cpfCnpj)
    self:oCollection:setValue("responsibleLeOrIndivid", self:oRest:responsibleLeOrIndivid)
    self:oCollection:setValue("responsibilityType", self:oRest:responsibilityType)
    
    self:oCollection:mapFromJson(oJson)

Return

Method buscar(nType) Class CenReqResp

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


