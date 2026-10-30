#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE INSERT "03"
#DEFINE DELETE "04"
#DEFINE UPDATE "05"
#DEFINE BUSCA  "07"

Class CenReqMdpc from CenRequest

    Method New(oRest,cSvcName) Constructor
    Method destroy()
    Method applyFilter(nType)
    Method applyOrder(cOrder)
    Method buscar(nType)
    Method prepFilter()

EndClass

Method destroy()  Class CenReqMdpc
Return _Super:destroy()

Method New(oRest, cSvcName) Class CenReqMdpc
    _Super:New(oRest,cSvcName)
    self:oCollection := CenCltMdpc():New()
    self:oValidador := CenVldMdpc():New()
    self:cPropLote   := "Mdpc"
Return self

Method applyFilter(nType) Class CenReqMdpc
    
    If self:lSuccess
        If nType == ALL
            self:oCollection:setValue("commitmentYear",self:oRest:commitmentYear)
            self:oCollection:setValue("commitmentCode",self:oRest:commitmentCode)
            self:oCollection:setValue("obligationCode",self:oRest:obligationCode)
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)
            self:oCollection:setValue("tempRemidNumber",self:oRest:tempRemidNumber)
            self:oCollection:setValue("vitRemidNumber",self:oRest:vitRemidNumber)
            self:oCollection:setValue("trimester",self:oRest:trimester)
            self:oCollection:setValue("tempExpSom",self:oRest:tempExpSom)
            self:oCollection:setValue("vitExpSom",self:oRest:vitExpSom)
            self:oCollection:setValue("tempRemisSom",self:oRest:tempRemisSom)
            self:oCollection:setValue("vitRemisSom",self:oRest:vitRemisSom)
            self:oCollection:setValue("status",self:oRest:status)

        EndIf
        If nType == SINGLE 
            self:oCollection:setValue("commitmentYear",self:oRest:commitmentYear)
            self:oCollection:setValue("commitmentCode",self:oRest:commitmentCode)
            self:oCollection:setValue("obligationCode",self:oRest:obligationCode)
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)

        EndIf
    EndIf
Return self:lSuccess

Method applyOrder(cOrder) Class CenReqMdpc
    If self:lSuccess
        self:oCollection:applyOrder(cOrder)
    EndIf
Return self:lSuccess

Method prepFilter(oJson) Class CenReqMdpc

    Default oJson := self:jRequest
    self:oCollection:setValue("commitmentYear", self:oRest:commitmentYear)
    self:oCollection:setValue("commitmentCode", self:oRest:commitmentCode)
    self:oCollection:setValue("obligationCode", self:oRest:obligationCode)
    self:oCollection:setValue("providerRegister", self:oRest:providerRegister)
    
    self:oCollection:mapFromJson(oJson)

Return

Method buscar(nType) Class CenReqMdpc

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


