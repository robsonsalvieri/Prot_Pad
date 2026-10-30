#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE INSERT "03"
#DEFINE DELETE "04"
#DEFINE UPDATE "05"
#DEFINE BUSCA  "07"

Class PLUtzUsReq from CenRequest

    Method New(oRest,cSvcName) Constructor
    Method destroy()
    Method applyFilter(nType)
    Method buscar()
    Method applyOrder(cOrder)

EndClass

Method destroy()  Class PLUtzUsReq
Return _Super:destroy()

Method New(oRest, cSvcName) Class PLUtzUsReq
    _Super:New(oRest,cSvcName)
    self:oCollection := PLUtzUsClt():New()
    self:cPropLote   := "BD6QRY"

Return self


Method applyFilter(nType) Class PLUtzUsReq

    Local lFault      := .F.
    Local cFaultDesc  := ''
    Local cFaultDetai := '' 

    if self:lSuccess
        
        if Empty(self:oRest:subscriberId) .Or. Empty(self:oRest:initialPeriod) .Or. Empty(self:oRest:finalPeriod)
            lFault      := .T.
            cFaultDesc  := 'Os parametros abaixo sao obrigatorios: '
            cFaultDetai := 'subscriberId, initialPeriod, finalPeriod' 
        else
            if len(self:oRest:initialPeriod) <> 6 .Or. len(self:oRest:finalPeriod) <> 6 
                lFault      := .T.
                cFaultDesc  := 'Os parametros abaixo devem ter 6 caracteres: '
                cFaultDetai := 'initialPeriod, finalPeriod' 
            elseIf len(self:oRest:subscriberId) <> 17
                lFault      := .T.
                cFaultDesc  := 'O parametros abaixo deve ter 17 caracteres: '
                cFaultDetai := 'subscriberId' 
            endIf
        endIf
        
        If !lFault .And. nType == ALL
       
            //Obrigatorios
            self:oCollection:setValue("subscriberId",self:oRest:subscriberId)
            self:oCollection:setValue("initialPeriod",self:oRest:initialPeriod)
            self:oCollection:setValue("finalPeriod",self:oRest:finalPeriod)

            //Opcionais
            self:oCollection:setValue("procedureCode",self:oRest:procedureCode)
            self:oCollection:setValue("executionDate",self:oRest:executionDate)
            self:oCollection:setValue("healthProviderCode",self:oRest:healthProviderCode)
            self:oCollection:setValue("healthProviderDocument",self:oRest:healthProviderDocument)
            self:oCollection:setValue("cid",self:oRest:cid)
            self:oCollection:setValue("procedureName",self:oRest:procedureName)
            self:oCollection:setValue("healthProviderName",self:oRest:healthProviderName)
            self:oCollection:setValue("quantity",self:oRest:quantity)
            self:oCollection:setValue("toothRegion",self:oRest:toothRegion)
            self:oCollection:setValue("face",self:oRest:face)
        EndIf

        //Erros de preenchimento
        if lFault
            self:nFault := 400
            self:cFaultDesc   := cFaultDesc
            self:cFaultDetail := cFaultDetai
            self:lSuccess     := .F.
        endIf    
      
    endIf

Return self:lSuccess

Method buscar() Class PLUtzUsReq

    Local cMatric    := self:oRest:subscriberId
    Local cPeriodDe  := self:oRest:initialPeriod
    Local cPeriodAte := self:oRest:finalPeriod

    If self:lSuccess
        self:oCollection:bscUtiliz(cMatric,cPeriodDe,cPeriodAte)
    EndIf

Return self:lSuccess


//-----------------------------------------------------------------
/*/{Protheus.doc} applyOrder
 Aplica ordem dos campos
 
@author renan.almeida
@since 09/09/2020
@version 1.0
/*/
//-----------------------------------------------------------------
Method applyOrder(cOrder) Class PLUtzUsReq

    Local cOrderAux := ""
    Local aFields   := {}
    Local aOrder    := {}
    Local lFault    := .F.
    Local nX        := 0

    if self:lSuccess .And. !Empty(cOrder)

        aFields := self:oCollection:getAFields()
        aOrder  := StrTokArr(cOrder, "," )
        
        for nX := 1 to len(aOrder)
            if SubStr(aOrder[nX],1,1) == "-"
				cOrderAux := SubStr(aOrder[nX], 2, Len(aOrder[nX]))
			else
                cOrderAux := aOrder[nX]
            endIf
            if aScan(aFields,{|aFields|aFields[2] == cOrderAux }) == 0
                lFault := .T.
                exit
            endIf
        next
        
        if lFault
            self:nFault := 400
            self:cFaultDesc := "Não foi possivel aplicar a ordenacao"
            self:cFaultDetail := "order="+cOrder
            self:lSuccess := .F.
        else
            self:oCollection:oDao:cfieldOrder := ""
            self:oCollection:applyOrder(cOrder)
        endIf
    endIf

Return self:lSuccess