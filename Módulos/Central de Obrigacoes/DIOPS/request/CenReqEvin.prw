#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE INSERT "03"
#DEFINE DELETE "04"
#DEFINE UPDATE "05"
#DEFINE BUSCA  "07"

Class CenReqEvin from CenRequest

    Method New(oRest,cSvcName) Constructor
    Method destroy()
    Method applyFilter(nType)
    Method applyOrder(cOrder)
    Method buscar(nType)
    Method prepFilter()

EndClass

Method destroy()  Class CenReqEvin
Return _Super:destroy()

Method New(oRest, cSvcName) Class CenReqEvin
    _Super:New(oRest,cSvcName)
    self:oCollection := CenCltEvin():New()
    self:oValidador := CenVldEvin():New()
    self:cPropLote   := "Evin"
Return self

Method applyFilter(nType) Class CenReqEvin
    
    If self:lSuccess
        If nType == ALL
            self:oCollection:setValue("commitmentYear",self:oRest:commitmentYear)
            self:oCollection:setValue("commitmentCode",self:oRest:commitmentCode)
            self:oCollection:setValue("eventCodeAns",self:oRest:eventCodeAns)
            self:oCollection:setValue("obligationCode",self:oRest:obligationCode)
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)
            self:oCollection:setValue("trimester",self:oRest:trimester)
            self:oCollection:setValue("status",self:oRest:status)
            self:oCollection:setValue("quarterMthFirstValue",self:oRest:quarterMthFirstValue)
            self:oCollection:setValue("quarterMthSecValue",self:oRest:quarterMthSecValue)
            self:oCollection:setValue("quarterMthThirdValue",self:oRest:quarterMthThirdValue)

        EndIf
        If nType == SINGLE 
            self:oCollection:setValue("commitmentYear",self:oRest:commitmentYear)
            self:oCollection:setValue("commitmentCode",self:oRest:commitmentCode)
            self:oCollection:setValue("eventCodeAns",self:oRest:eventCodeAns)
            self:oCollection:setValue("obligationCode",self:oRest:obligationCode)
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)

        EndIf
    EndIf
Return self:lSuccess

Method applyOrder(cOrder) Class CenReqEvin
    If self:lSuccess
        self:oCollection:applyOrder(cOrder)
    EndIf
Return self:lSuccess

Method prepFilter(oJson) Class CenReqEvin

    Default oJson := self:jRequest
    self:oCollection:setValue("commitmentYear", self:oRest:commitmentYear)
    self:oCollection:setValue("commitmentCode", self:oRest:commitmentCode)
    self:oCollection:setValue("eventCodeAns", self:oRest:eventCodeAns)
    self:oCollection:setValue("obligationCode", self:oRest:obligationCode)
    self:oCollection:setValue("providerRegister", self:oRest:providerRegister)
    
    self:oCollection:mapFromJson(oJson)

Return

Method buscar(nType) Class CenReqEvin

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


