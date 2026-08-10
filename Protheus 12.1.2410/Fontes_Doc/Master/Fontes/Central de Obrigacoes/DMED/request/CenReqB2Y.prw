#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE INSERT "03"
#DEFINE DELETE "04"
#DEFINE UPDATE "05"
#DEFINE BUSCA  "07"

Class CenReqB2Y from CenRequest

    Method New(oRest,cSvcName) Constructor
    Method destroy()
    Method applyFilter(nType)
    Method applyOrder(cOrder)
    Method searcher(nType)
    Method buscar(nType)
    Method prepFilter()
    Method CenReqB2Y()
    Method prePstIns(oCollection)

EndClass

Method destroy()  Class CenReqB2Y
Return _Super:destroy()

Method New(oRest, cSvcName) Class CenReqB2Y
    _Super:New(oRest,cSvcName)
    self:oCollection := CenCltB2Y():New()
    self:oValidador := CenVldB2Y():New()
    self:cPropLote   := "B2Y"
Return self

Method applyFilter(nType) Class CenReqB2Y

    If self:lSuccess
        If nType == ALL
            self:oCollection:setValue("healthInsurerCode",self:oRest:healthInsurerCode)
            self:oCollection:setValue("ssnHolder",self:oRest:ssnHolder)
            self:oCollection:setValue("titleHolderEnrollment",self:oRest:titleHolderEnrollment)
            self:oCollection:setValue("holderName",self:oRest:holderName)
            self:oCollection:setValue("dependentSsn",self:oRest:dependentSsn)
            self:oCollection:setValue("dependentEnrollment",self:oRest:dependentEnrollment)
            self:oCollection:setValue("dependentName",self:oRest:dependentName)
            self:oCollection:setValue("dependentBirthDate",self:oRest:dependentBirthDate)
            self:oCollection:setValue("dependenceRelationships",self:oRest:dependenceRelationships)
            self:oCollection:setValue("expenseKey",self:oRest:expenseKey)
            self:oCollection:setValue("expenseAmount",self:oRest:expenseAmount)
            self:oCollection:setValue("refundAmount",self:oRest:refundAmount)
            self:oCollection:setValue("previousYearRefundAmt",self:oRest:previousYearRefundAmt)
            self:oCollection:setValue("period",self:oRest:period)
            self:oCollection:setValue("providerSsnEin",self:oRest:providerSsnEin)
            self:oCollection:setValue("providerName",self:oRest:providerName)
            self:oCollection:setValue("status",self:oRest:status)

            self:oCollection:setValue("roboId",self:oRest:roboId)
            self:oCollection:setValue("inclusionTime",self:oRest:inclusionTime)
            self:oCollection:setValue("exclusionId",self:oRest:exclusionId)
            self:oCollection:setValue("inicialDate",self:oRest:inicialDate)
            self:oCollection:setValue("finalDate",self:oRest:finalDate)

        EndIf
        If nType == SINGLE
            self:oCollection:setValue("healthInsurerCode",self:oRest:healthInsurerCode)
            self:oCollection:setValue("ssnHolder",self:oRest:ssnHolder)
            self:oCollection:setValue("titleHolderEnrollment",self:oRest:titleHolderEnrollment)
            self:oCollection:setValue("dependentSsn",self:oRest:dependentSsn)
            self:oCollection:setValue("dependentEnrollment",self:oRest:dependentEnrollment)
            self:oCollection:setValue("expenseKey",self:oRest:expenseKey)
            self:oCollection:setValue("period",self:oRest:period)

        EndIf
    EndIf
Return self:lSuccess

Method applyOrder(cOrder) Class CenReqB2Y
    If self:lSuccess
        self:oCollection:applyOrder(cOrder)
    EndIf
Return self:lSuccess

Method prepFilter(oJson) Class CenReqB2Y

    Default oJson := self:jRequest
    self:oCollection:setValue("healthInsurerCode", self:oRest:healthInsurerCode)
    self:oCollection:setValue("ssnHolder", self:oRest:ssnHolder)
    self:oCollection:setValue("titleHolderEnrollment", self:oRest:titleHolderEnrollment)
    self:oCollection:setValue("dependentSsn", self:oRest:dependentSsn)
    self:oCollection:setValue("dependentEnrollment", self:oRest:dependentEnrollment)
    self:oCollection:setValue("expenseKey", self:oRest:expenseKey)
    self:oCollection:setValue("period", self:oRest:period)

    self:oCollection:mapFromJson(oJson)

Return

Method searcher(nType) Class CenReqB2Y
    Local lExiste   := .F.
    Local oColB3A   := CenCltObri():New()
    Local oAux      := nil
    Local cCodObrig := ""

    oColB3A:SetValue("obligationType","4")
    oColB3A:SetValue("activeInactive","1")
    oColB3A:SetValue("healthInsurerCode",B2Y->B2Y_CODOPE)

    if oColB3A:buscar() .And. oColB3A:HasNext()
        oAux      := oColB3A:GetNext()
        cCodObrig := oAux:GetValue("requirementCode")
    endIf

    If self:lSuccess
        self:oCollection:buscar()
    EndIf

    if (!(empty(self:oCollection:getValue("inicialDate"))) .OR. !(empty(self:oCollection:getValue("finalDate"))))
        self:oCollection:getExpensesByDate(self:oCollection:getValue("inicialDate"),self:oCollection:getValue("finalDate"))
    Else
        self:buscar(nType)
    endIf

return self:lSuccess

Method buscar(nType) Class CenReqB2Y

    Local lExiste   := .F.
    Local oColB3A   := CenCltObri():New()
    Local oAux      := nil
    Local cCodObrig := ""

    oColB3A:SetValue("obligationType","4")
    oColB3A:SetValue("activeInactive","1")
    oColB3A:SetValue("healthInsurerCode",B2Y->B2Y_CODOPE)

    if oColB3A:buscar() .And. oColB3A:HasNext()
        oAux      := oColB3A:GetNext()
        cCodObrig := oAux:GetValue("requirementCode")
    endIf

    If self:lSuccess
        If nType == BUSCA
            self:oCollection:buscar()
        Else
            lExiste := self:oCollection:bscChaPrim()
            If nType == INSERT
                self:lSuccess := .T.

                If lExiste .And. B2Y->B2Y_EXCLU == "1" .And. B2Y->B2Y_PROCES == "0"
                    self:lSuccess     := .F.
                EndIf
            Else
                self:lSuccess := lExiste
            EndIf
        EndIf
    EndIf

Return self:lSuccess

Method prePstIns(oColB2YJ) Class CenReqB2Y
    Local oColB2W    := CenCltB2W():New()
    Local oColB2Y    := CenCltB2Y():New()
    Local lFound     := .F.
    Local oColB3A    := CenCltObri():New()
    Local oAux       := nil
    Local cCodObrig  := ""
    Local lExiste    := .F.

    oColB3A:SetValue("obligationType","4")
    oColB3A:SetValue("activeInactive","1")
    oColB3A:SetValue("healthInsurerCode",oColB2Y:getValue("healthInsurerCode"))

    if oColB3A:buscar() .And. oColB3A:HasNext()
        oAux      := oColB3A:GetNext()
        cCodObrig := oAux:GetValue("requirementCode")
    endIf

    oColB2Y:SetValue("healthInsurerCode"     ,oColB2YJ:getValue("healthInsurerCode"    ))
    oColB2Y:SetValue("ssnHolder"             ,oColB2YJ:getValue("ssnHolder"            ))
    oColB2Y:SetValue("titleHolderEnrollment" ,oColB2YJ:getValue("titleHolderEnrollment"))
    oColB2Y:SetValue("dependentSsn"          ,oColB2YJ:getValue("dependentSsn"         ))
    oColB2Y:SetValue("dependentEnrollment"   ,oColB2YJ:getValue("dependentEnrollment"  ))
    oColB2Y:SetValue("dependentName"         ,oColB2YJ:getValue("dependentName"        ))
    oColB2Y:SetValue("dependentBirthDate"    ,oColB2YJ:getValue("dependentBirthDate"   ))
    oColB2Y:SetValue("expenseKey"            ,oColB2YJ:getValue("expenseKey"           ))
    oColB2Y:SetValue("period"                ,oColB2YJ:getValue("period"               ))
    oColB2Y:SetValue("exclusionId"           ,oColB2YJ:getValue("exclusionId"          ))
    oColB2Y:SetValue("providerSsnEin"        ,oColB2YJ:getValue("providerSsnEin"       ))

    lExiste:=oColB2Y:bscChaPrim()

    If lExiste
        oColB2Y:mapFromDao()

        oColB2W:SetValue("healthInsurerCode"     ,oColB2Y:getValue("healthInsurerCode"))
        oColB2W:SetValue("requirementCode"       ,cCodObrig)
        oColB2W:SetValue("referenceYear"         ,SUBSTR(oColB2Y:getValue("period"),1,4))
        oColB2W:SetValue("commitmentCode"        ,"001")


        If Empty(oColB2Y:getValue("dependentSsn")) .And. Empty(oColB2Y:getValue("beneficiaryName"))
            oColB2W:SetValue("ssnBeneficiary"    ,oColB2Y:getValue("ssnHolder"))
            oColB2W:SetValue("beneficiaryName"   ,oColB2Y:getValue("holderName"))
            oColB2W:SetValue("ssnHolder"         ,oColB2Y:getValue("ssnHolder"))

        Else
            oColB2W:SetValue("ssnBeneficiary"    ,oColB2Y:getValue("dependentSsn"))
            oColB2W:SetValue("ssnHolder"         ,oColB2Y:getValue("ssnHolder"))
        EndIf

        oColB2W:SetValue("providerEinSsn"        ,oColB2Y:getValue("providerSsnEin"))

        lfound:= oColB2W:bscChaPrim()

        If lFound .And. B2Y->B2Y_PROCES == '1' .And. B2Y->B2Y_EXCLU == '0'                             //1=TOP;2=RTOP;3=DTOP;4=RDTOP

            oColB2W:mapFromDao()

            If oColB2W:getValue("recordId") $ "1/3"
                If (oColB2W:getValue("expenseAmount") - B2Y->B2Y_VLRDES)<0
                    oColB2W:setValue("expenseAmount",0)
                Else
                    oColB2W:setValue("expenseAmount",B2Y->B2Y_VLRDES)
                EndIf
            Else
                If (oColB2W:getValue("previousYearReimburseT") - B2Y->B2Y_VLRRAA)<0
                    oColB2W:SetValue("previousYearReimburseT",0)
                Else
                    oColB2W:SetValue("previousYearReimburseT",B2Y->B2Y_VLRRAA)
                EndIf

                If (oColB2W:getValue("reimburseTotalValue") - B2Y->B2Y_VLRREE)<0
                    oColB2W:SetValue("reimburseTotalValue",0)
                Else
                    oColB2W:SetValue("reimburseTotalValue",B2Y->B2Y_VLRREE)
                EndIf
            EndIf

            oColB2W:commit(.F.,.T.)

        EndIf
    EndIf

Return self:lSuccess
