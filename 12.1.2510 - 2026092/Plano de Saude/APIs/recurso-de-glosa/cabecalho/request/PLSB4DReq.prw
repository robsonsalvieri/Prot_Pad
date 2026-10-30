#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE INSERT "03"
#DEFINE DELETE "04"
#DEFINE UPDATE "05"
#DEFINE BUSCA  "07"

Class PLSB4DReq from CenRequest

    Method New(oRest,cSvcName) Constructor
    Method destroy()
    Method applyFilter(nType)
    Method buscar()
    Method applyOrder(cOrder)

EndClass

Method destroy()  Class PLSB4DReq
    self:oCollection:destroy()
    _Super:destroy()
Return 

Method New(oRest, cSvcName) Class PLSB4DReq
    _Super:New(oRest,cSvcName)
    self:oCollection := PLSB4DClt():New()
    self:cPropLote   := "B4DQRY"

Return self


Method applyFilter(nType) Class PLSB4DReq

    Local lFault      := .F.
    Local cFaultDesc  := ''
    Local cFaultDetai := '' 

    if self:lSuccess
        
        if Empty(self:oRest:healthProviderCode) 
            lFault      := .T.
            cFaultDesc  := 'O campo abaixo e obrigatorio: '
            cFaultDetai := 'healthProviderCode' 
        else
            If len(self:oRest:healthProviderCode) <> 6
                lFault      := .T.
                cFaultDesc  := 'O parametro abaixo deve ter 6 caracteres: '
                cFaultDetai := 'healthProviderCode' 
            endIf
        endIf
        
        If !lFault .And. nType == ALL
            //Obrigatorios
            self:oCollection:setValue("healthProviderCode",self:oRest:healthProviderCode)
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

Method buscar() Class PLSB4DReq

    local cCodRda       := self:oRest:healthProviderCode
    local cPeriodDe     := self:oRest:initialPeriod
    local cPeriodAte    := self:oRest:finalPeriod
    local cStatus       := self:oRest:status
    local cCodPeg       := self:oRest:protocol
    local cProtoc       := self:oRest:appealProtocol

    If self:lSuccess
        self:oCollection:bscUtiliz(cCodRda,cPeriodDe,cPeriodAte,cStatus,cCodPeg,cProtoc)
    EndIf

Return self:lSuccess


//-----------------------------------------------------------------
/*/{Protheus.doc} applyOrder
 Aplica ordem dos campos
 
@author Lucas Nonato
@since  18/03/2021
@version 1.0
/*/
//-----------------------------------------------------------------
Method applyOrder(cOrder) Class PLSB4DReq

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
