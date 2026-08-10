#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE INSERT "03"
#DEFINE DELETE "04"
#DEFINE UPDATE "05"
#DEFINE BUSCA  "07"

Class CenReqBw8 from CenRequest
    
    Data nContEve as Integer

    Method New(oRest,cSvcName) Constructor
    Method destroy()
    Method applyFilter(nType)
    Method applyOrder(cOrder)
    Method buscar(nType)
    Method prepFilter()
    Method prePstIns(oCltPai)
    Method preRlt2Ins(oCltPai, oCltFilho)

EndClass

Method destroy()  Class CenReqBw8
Return _Super:destroy()

Method New(oRest, cSvcName) Class CenReqBw8
    _Super:New(oRest,cSvcName)
    self:oCollection := CenCltBw8():New()
    self:oValidador := CenVldBw8():New()
    self:cPropLote   := "Bw8"
    self:nContEve   := 0
Return self

Method applyFilter(nType) Class CenReqBw8
    
    If self:lSuccess
        If nType == ALL
            self:oCollection:setValue("operatorRecord",self:oRest:operatorRecord)
            self:oCollection:setValue("formSequential",self:oRest:formSequential)
            self:oCollection:setValue("formProcDt",self:oRest:formProcDt)
            self:oCollection:setValue("registration",self:oRest:registration)
            self:oCollection:setValue("providerFormNumber",self:oRest:providerFormNumber)
            self:oCollection:setValue("processed",self:oRest:processed)
            self:oCollection:setValue("inclusionDate",self:oRest:inclusionDate)
            self:oCollection:setValue("inclusionTime",self:oRest:inclusionTime)
            self:oCollection:setValue("exclusionId",self:oRest:exclusionId)
            self:oCollection:setValue("roboId",self:oRest:roboId)

        EndIf
        If nType == SINGLE 
            self:oCollection:setValue("operatorRecord",self:oRest:operatorRecord)
            self:oCollection:setValue("formSequential",self:oRest:formSequential)

        EndIf
    EndIf
Return self:lSuccess

Method applyOrder(cOrder) Class CenReqBw8
    If self:lSuccess
        self:oCollection:applyOrder(cOrder)
    EndIf
Return self:lSuccess

Method prepFilter(oJson) Class CenReqBw8

    Default oJson := self:jRequest
    self:oCollection:setValue("operatorRecord", self:oRest:operatorRecord)
    self:oCollection:setValue("formSequential", self:oRest:formSequential)
    
    self:oCollection:mapFromJson(oJson)

Return

Method buscar(nType) Class CenReqBw8

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

Method prePstIns(oCltPai) Class CenReqBw8
    Local cSeqGui := GetSXENum( "BW8","BW8_SEQGUI" )
	BW8->(ConfirmSX8())
    oCltPai:setValue("formSequential",cSeqGui)
    oCltPai:setValue("processed","0")
    oCltPai:setValue("inclusionDate",Dtos(dDataBase))
    oCltPai:setValue("inclusionTime",StrTran(Time(),":",""))
Return

Method preRlt2Ins(oCltPai, oCltFilho) Class CenReqBw8
    
    oCltFilho:setValue("formSequential",oCltPai:getValue("formSequential"))
    oCltFilho:setValue("operatorRecord",oCltPai:getValue("operatorRecord"))
    if oCltFilho:oDao:cAlias == "BWL"
        self:nContEve++
        oCltFilho:setValue("sequence", Strzero(self:nContEve,3)) 
    endIf
Return