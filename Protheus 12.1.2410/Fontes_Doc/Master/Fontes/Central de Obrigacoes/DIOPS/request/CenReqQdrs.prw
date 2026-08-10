#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE INSERT "03"
#DEFINE DELETE "04"
#DEFINE UPDATE "05"
#DEFINE BUSCA  "07"

Class CenReqQdrs from CenRequest

    Method New(oRest,cSvcName) Constructor
    Method destroy()
    Method applyFilter(nType)
    Method applyOrder(cOrder)
    Method buscar(nType)
    Method prepFilter()

EndClass

Method destroy()  Class CenReqQdrs
Return _Super:destroy()

Method New(oRest, cSvcName) Class CenReqQdrs
    _Super:New(oRest,cSvcName)
    self:oCollection := CenCltQdrs():New()
    self:oValidador := CenVldQdrs():New()
    self:cPropLote   := "Qdrs"
Return self

Method applyFilter(nType) Class CenReqQdrs
    
    If self:lSuccess
        If nType == ALL
            self:oCollection:setValue("commitmentYear",self:oRest:commitmentYear)
            self:oCollection:setValue("commitmentCode",self:oRest:commitmentCode)
            self:oCollection:setValue("obligationCode",self:oRest:obligationCode)
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)
            self:oCollection:setValue("diopsChart",self:oRest:diopsChart)
            self:oCollection:setValue("chartReceived",self:oRest:chartReceived)
            self:oCollection:setValue("validateChart",self:oRest:validateChart)

        EndIf
        If nType == SINGLE 
            self:oCollection:setValue("commitmentYear",self:oRest:commitmentYear)
            self:oCollection:setValue("commitmentCode",self:oRest:commitmentCode)
            self:oCollection:setValue("obligationCode",self:oRest:obligationCode)
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)
            self:oCollection:setValue("diopsChart",self:oRest:diopsChart)

        EndIf
    EndIf
Return self:lSuccess

Method applyOrder(cOrder) Class CenReqQdrs
    If self:lSuccess
        self:oCollection:applyOrder(cOrder)
    EndIf
Return self:lSuccess

Method prepFilter(oJson) Class CenReqQdrs

    Default oJson := self:jRequest
    self:oCollection:setValue("commitmentYear", self:oRest:commitmentYear)
    self:oCollection:setValue("commitmentCode", self:oRest:commitmentCode)
    self:oCollection:setValue("obligationCode", self:oRest:obligationCode)
    self:oCollection:setValue("providerRegister", self:oRest:providerRegister)
    self:oCollection:setValue("diopsChart", self:oRest:diopsChart)
    
    self:oCollection:mapFromJson(oJson)

Return

Method buscar(nType) Class CenReqQdrs

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


