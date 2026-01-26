#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE INSERT "03"
#DEFINE DELETE "04"
#DEFINE UPDATE "05"
#DEFINE BUSCA  "07"

Class CenReqBra from CenRequest

    Data nContEve as Integer

    Method New(oRest,cSvcName) Constructor
    Method destroy()
    Method applyFilter(nType)
    Method applyOrder(cOrder)
    Method buscar(nType)
    Method prepFilter()
    Method prePstIns(oCltPai)
    Method preRlt2Ins(oCltPai, oCltFilho)
    Method preRlt3Ins(oCltPai, oCltFilho)
    Method posRlt3Ins(oCltPai, oCltFilho)

EndClass

Method destroy()  Class CenReqBra
Return _Super:destroy()

Method New(oRest, cSvcName) Class CenReqBra
    _Super:New(oRest,cSvcName)
    self:oCollection := CenCltBra():New()
    self:oValidador := CenVldBra():New()
    self:cPropLote   := "Bra"
    self:nContEve   := 0
Return self

Method applyFilter(nType) Class CenReqBra
    
    If self:lSuccess
        If nType == ALL
            self:oCollection:setValue("operatorRecord",self:oRest:operatorRecord)
            self:oCollection:setValue("formSequential",self:oRest:formSequential)
            self:oCollection:setValue("hospitalizationRequest",self:oRest:hospitalizationRequest)
            self:oCollection:setValue("admissionType",self:oRest:admissionType)
            self:oCollection:setValue("serviceType",self:oRest:serviceType)
            self:oCollection:setValue("appointmentType",self:oRest:appointmentType)
            self:oCollection:setValue("invoicingTp",self:oRest:invoicingTp)
            self:oCollection:setValue("hospTp",self:oRest:hospTp)
            self:oCollection:setValue("aEventType",self:oRest:aEventType)
            self:oCollection:setValue("tissProviderVersion",self:oRest:tissProviderVersion)
            self:oCollection:setValue("cboSCode",self:oRest:cboSCode)
            self:oCollection:setValue("icdDiagnosis1",self:oRest:icdDiagnosis1)
            self:oCollection:setValue("icdDiagnosis2",self:oRest:icdDiagnosis2)
            self:oCollection:setValue("icdDiagnosis3",self:oRest:icdDiagnosis3)
            self:oCollection:setValue("icdDiagnosis4",self:oRest:icdDiagnosis4)
            self:oCollection:setValue("executingCityCode",self:oRest:executingCityCode)
            self:oCollection:setValue("cnes",self:oRest:cnes)
            self:oCollection:setValue("providerCpfCnpj",self:oRest:providerCpfCnpj)
            self:oCollection:setValue("authorizationDate",self:oRest:authorizationDate)
            self:oCollection:setValue("inclusionDate",self:oRest:inclusionDate)
            self:oCollection:setValue("executionDate",self:oRest:executionDate)
            self:oCollection:setValue("requestDate",self:oRest:requestDate)
            self:oCollection:setValue("escortDailyRates",self:oRest:escortDailyRates)
            self:oCollection:setValue("icuDailyRates",self:oRest:icuDailyRates)
            self:oCollection:setValue("invoicingEndDate",self:oRest:invoicingEndDate)
            self:oCollection:setValue("invoicingStartDate",self:oRest:invoicingStartDate)
            self:oCollection:setValue("paymentDt",self:oRest:paymentDt)
            self:oCollection:setValue("formProcDt",self:oRest:formProcDt)
            self:oCollection:setValue("collectionProtocolDate",self:oRest:collectionProtocolDate)
            self:oCollection:setValue("exclusionId",self:oRest:exclusionId)
            self:oCollection:setValue("submissionMethod",self:oRest:submissionMethod)
            self:oCollection:setValue("inclusionTime",self:oRest:inclusionTime)
            self:oCollection:setValue("executerId",self:oRest:executerId)
            self:oCollection:setValue("refundId",self:oRest:refundId)
            self:oCollection:setValue("presetValueIdent",self:oRest:presetValueIdent)
            self:oCollection:setValue("newborn",self:oRest:newborn)
            self:oCollection:setValue("indicAccident",self:oRest:indicAccident)
            self:oCollection:setValue("registration",self:oRest:registration)
            self:oCollection:setValue("outflowType",self:oRest:outflowType)
            self:oCollection:setValue("operatorFormNumber",self:oRest:operatorFormNumber)
            self:oCollection:setValue("providerFormNumber",self:oRest:providerFormNumber)
            self:oCollection:setValue("mainFormNumb",self:oRest:mainFormNumb)
            self:oCollection:setValue("eventOrigin",self:oRest:eventOrigin)
            self:oCollection:setValue("processed",self:oRest:processed)
            self:oCollection:setValue("hospRegime",self:oRest:hospRegime)
            self:oCollection:setValue("ansRecordNumber",self:oRest:ansRecordNumber)
            self:oCollection:setValue("roboId",self:oRest:roboId)

        EndIf
        If nType == SINGLE 
            self:oCollection:setValue("operatorRecord",self:oRest:operatorRecord)
            self:oCollection:setValue("formSequential",self:oRest:formSequential)

        EndIf
    EndIf
Return self:lSuccess

Method applyOrder(cOrder) Class CenReqBra
    If self:lSuccess
        self:oCollection:applyOrder(cOrder)
    EndIf
Return self:lSuccess

Method prepFilter(oJson) Class CenReqBra

    Default oJson := self:jRequest
    self:oCollection:setValue("operatorRecord", self:oRest:operatorRecord)
    self:oCollection:setValue("formSequential", self:oRest:formSequential)
    
    self:oCollection:mapFromJson(oJson)

Return

Method buscar(nType) Class CenReqBra

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

Method prePstIns(oCltPai) Class CenReqBra
    Local cSeqGui := GetSXENum( "BRA","BRA_SEQGUI" )
	BRA->(ConfirmSX8())
    oCltPai:setValue("formSequential",cSeqGui)
    oCltPai:setValue("processed","0")
    oCltPai:setValue("inclusionDate",Dtos(dDataBase))
    oCltPai:setValue("inclusionTime",StrTran(Time(),":",""))
Return

Method preRlt2Ins(oCltPai, oCltFilho) Class CenReqBra
    
    oCltFilho:setValue("formSequential",oCltPai:getValue("formSequential"))
    oCltFilho:setValue("operatorRecord",oCltPai:getValue("operatorRecord"))
    oCltFilho:setValue("package","0")
    if oCltFilho:oDao:cAlias == "BRB"
        self:nContEve++
        oCltFilho:setValue("sequence", Strzero(self:nContEve,3)) 
    endIf
Return

Method preRlt3Ins(oCltPai, oCltFilho) Class CenReqBra
    oCltFilho:setValue("formSequential",oCltPai:getValue("formSequential"))
    oCltFilho:setValue("sequentialItem",oCltPai:getValue("sequence"))
    oCltFilho:setValue("operatorRecord",oCltPai:getValue("operatorRecord"))
Return

Method posRlt3Ins(oCltPai, oCltFilho) Class CenReqBra
    oCltPai:SetValue("package","1")
    oCltPai:update()
Return