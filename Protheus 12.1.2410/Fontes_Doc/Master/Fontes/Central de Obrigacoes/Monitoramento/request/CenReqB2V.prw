#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE INSERT "03"
#DEFINE DELETE "04"
#DEFINE UPDATE "05"
#DEFINE BUSCA  "07"

Class CenReqB2V from CenRequest

    Method New(oRest,cSvcName) Constructor
    Method destroy()
    Method applyFilter(nType)
    Method applyOrder(cOrder)
    Method buscar(nType)
    Method prepFilter()
    Method prePstIns(oCltPai)

EndClass

Method destroy()  Class CenReqB2V
Return _Super:destroy()

Method New(oRest, cSvcName) Class CenReqB2V
    _Super:New(oRest,cSvcName)
    self:oCollection := CenCltB2V():New()
    self:oValidador := CenVldB2V():New()
    self:cPropLote   := "B2V"
Return self

Method applyFilter(nType) Class CenReqB2V
    
    If self:lSuccess
        If nType == ALL
            self:oCollection:setValue("formSequential",self:oRest:formSequential)
            self:oCollection:setValue("operatorRecord",self:oRest:operatorRecord)
            self:oCollection:setValue("providerCpfCnpj",self:oRest:providerCpfCnpj)
            self:oCollection:setValue("formProcDt",self:oRest:formProcDt)
            self:oCollection:setValue("totalDisallowValue",self:oRest:totalDisallowValue)
            self:oCollection:setValue("totalValueEntered",self:oRest:totalValueEntered)
            self:oCollection:setValue("totalValuePaid",self:oRest:totalValuePaid)
            self:oCollection:setValue("exclusionId",self:oRest:exclusionId)
            self:oCollection:setValue("inclusionTime",self:oRest:inclusionTime)
            self:oCollection:setValue("identReceipt",self:oRest:identReceipt)
            self:oCollection:setValue("inclusionDate",self:oRest:inclusionDate)
            self:oCollection:setValue("processed",self:oRest:processed)
            self:oCollection:setValue("roboId",self:oRest:roboId)

        EndIf
        If nType == SINGLE 
            self:oCollection:setValue("formSequential",self:oRest:formSequential)
            self:oCollection:setValue("operatorRecord",self:oRest:operatorRecord)

        EndIf
    EndIf
Return self:lSuccess

Method applyOrder(cOrder) Class CenReqB2V
    If self:lSuccess
        self:oCollection:applyOrder(cOrder)
    EndIf
Return self:lSuccess

Method prepFilter(oJson) Class CenReqB2V

    Default oJson := self:jRequest
    self:oCollection:setValue("formSequential", self:oRest:formSequential)
    self:oCollection:setValue("operatorRecord", self:oRest:operatorRecord)
    
    self:oCollection:mapFromJson(oJson)

Return

Method buscar(nType) Class CenReqB2V

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

Method prePstIns(oCltPai) Class CenReqB2V
    Local cSeqGui := GetSXENum( "B2V","B2V_SEQUEN" )
	B2V->(ConfirmSX8())
    oCltPai:setValue("formSequential",cSeqGui)
    oCltPai:setValue("processed","0")
    oCltPai:setValue("inclusionDate",Dtos(dDataBase))
    oCltPai:setValue("inclusionTime",StrTran(Time(),":",""))
Return