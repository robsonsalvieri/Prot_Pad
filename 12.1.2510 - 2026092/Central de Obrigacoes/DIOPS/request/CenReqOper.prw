#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE INSERT "03"
#DEFINE DELETE "04"
#DEFINE UPDATE "05"
#DEFINE BUSCA  "07"

Class CenReqOper from CenRequest

    Method New(oRest,cSvcName) Constructor
    Method destroy()
    Method applyFilter(nType)
    Method applyOrder(cOrder)
    Method buscar(nType)
    Method prepFilter()

EndClass

Method destroy()  Class CenReqOper
Return _Super:destroy()

Method New(oRest, cSvcName) Class CenReqOper
    _Super:New(oRest,cSvcName)
    self:oCollection := CenCltOper():New()
    self:oValidador := CenVldOper():New()
    self:cPropLote   := "Oper"
Return self

Method applyFilter(nType) Class CenReqOper
    
    If self:lSuccess
        If nType == ALL
            self:oCollection:setValue("operatorCnpj",self:oRest:operatorCnpj)
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)
            self:oCollection:setValue("operatorMode",self:oRest:operatorMode)
            self:oCollection:setValue("legalNature",self:oRest:legalNature)
            self:oCollection:setValue("tradeName",self:oRest:tradeName)
            self:oCollection:setValue("corporateName",self:oRest:corporateName)
            self:oCollection:setValue("operatorSegmentation",self:oRest:operatorSegmentation)

        EndIf
        If nType == SINGLE 
            self:oCollection:setValue("operatorCnpj",self:oRest:operatorCnpj)
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)

        EndIf
    EndIf
Return self:lSuccess

Method applyOrder(cOrder) Class CenReqOper
    If self:lSuccess
        self:oCollection:applyOrder(cOrder)
    EndIf
Return self:lSuccess

Method prepFilter(oJson) Class CenReqOper

    Default oJson := self:jRequest
    self:oCollection:setValue("operatorCnpj", self:oRest:operatorCnpj)
    self:oCollection:setValue("providerRegister", self:oRest:providerRegister)
    
    self:oCollection:mapFromJson(oJson)

Return

Method buscar(nType) Class CenReqOper

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


