#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE INSERT "03"
#DEFINE DELETE "04"
#DEFINE UPDATE "05"
#DEFINE BUSCA  "07"

Class CenReqPlac from CenRequest

    Method New(oRest,cSvcName) Constructor
    Method destroy()
    Method applyFilter(nType)
    Method applyOrder(cOrder)
    Method buscar(nType)
    Method prepFilter()

EndClass

Method destroy()  Class CenReqPlac
Return _Super:destroy()

Method New(oRest, cSvcName) Class CenReqPlac
    _Super:New(oRest,cSvcName)
    self:oCollection := CenCltPlac():New()
    self:oValidador := CenVldPlac():New()
    self:cPropLote   := "Plac"
Return self

Method applyFilter(nType) Class CenReqPlac
    
    If self:lSuccess
        If nType == ALL
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)
            self:oCollection:setValue("accountCode",self:oRest:accountCode)
            self:oCollection:setValue("validityEndDate",self:oRest:validityEndDate)
            self:oCollection:setValue("validityStartDate",self:oRest:validityStartDate)
            self:oCollection:setValue("accountDescription",self:oRest:accountDescription)

        EndIf
        If nType == SINGLE 
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)
            self:oCollection:setValue("accountCode",self:oRest:accountCode)
            self:oCollection:setValue("validityEndDate",self:oRest:validityEndDate)
            self:oCollection:setValue("validityStartDate",self:oRest:validityStartDate)

        EndIf
    EndIf
Return self:lSuccess

Method applyOrder(cOrder) Class CenReqPlac
    If self:lSuccess
        self:oCollection:applyOrder(cOrder)
    EndIf
Return self:lSuccess

Method prepFilter(oJson) Class CenReqPlac

    Default oJson := self:jRequest
    self:oCollection:setValue("providerRegister", self:oRest:providerRegister)
    self:oCollection:setValue("accountCode", self:oRest:accountCode)
    self:oCollection:setValue("validityEndDate", self:oRest:validityEndDate)
    self:oCollection:setValue("validityStartDate", self:oRest:validityStartDate)
    
    self:oCollection:mapFromJson(oJson)

Return

Method buscar(nType) Class CenReqPlac

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


