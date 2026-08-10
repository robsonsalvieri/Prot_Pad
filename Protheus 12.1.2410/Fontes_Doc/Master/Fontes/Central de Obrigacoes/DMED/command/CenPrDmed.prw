#include "TOTVS.CH"
#define idExcGuia "1"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenPrDmed
    Classe abstrata para execução de comandos
    @type  Class
    @author jose.paulo
    @since 06/10/2020
/*/
//------------------------------------------------------------------------------------------
Class CenPrDmed From CenProDmed

    Method New() Constructor
    Method proGuiaAPI()
    Method atuProcAPI()
    //Metodos de inclusao
    Method procInclus()
    //Metodos de commit de dados
    Method grvMovB2W()
    //Exclucao Movimentacao
    Method delMovB2W(oObjB2W)
    Method loadChave(oAuxCab)
    Method excGuia()
    method VerAtuB2W()

EndClass


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
    Metodo construtor da classe proGuiaAPI
    @type  Class
    @author jose.paulo
    @since 06/10/2020
/*/
//------------------------------------------------------------------------------------------
Method New() Class CenPrDmed

    _Super:new()

return self


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} proGuiaAPI
    Processa uma guia enviada para a API
    @type  Class
    @author jose.paulo
    @since 06/10/2020
/*/
//------------------------------------------------------------------------------------------
Method proGuiaAPI(oAuxCab) Class CenPrDmed
    Local oColB2Y   := nil
    Default oAuxCab := nil

    self:lOkProces := .T.

    If oAuxCab == nil
        oColB2Y := CenCltB2Y():New()
        oColB2Y:SetValue("healthInsurerCode",self:cCodOpe)
        oColB2Y:SetValue("processed","0")
        if oColB2Y:bscChaPrim()
            oAuxCab := oColB2Y:GetNext()
        EndIf
        //oColB2Y:destroy()
    EndIf

    If oAuxCab != nil
        self:loadChave(oAuxCab)
        //Processa Exclusao
        if oAuxCab:getValue("exclusionId") == "1" //Exclusao de Guia
            self:excGuia()
        Else
            If self:lOkProces
                self:procInclus()
            EndIf
        endIf
        self:atuProcAPI() //Atualiza registro na b2y como processado

    endIf

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} procInclus
    Grava registros de movimentacao

    @type  Class
    @author jose.paulo
    @since 06/10/2020
/*/
//------------------------------------------------------------------------------------------
Method procInclus() Class CenPrDmed

    self:grvMovB2W()

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} grvMovB2W
    Grava o cabecalho da movimentacao na B2W

    @type  Class
    @author jose.paulo
    @since 06/10/2020
/*/
//------------------------------------------------------------------------------------------
Method grvMovB2W() Class CenPrDmed

    Local oColB2W := CenCltB2W():New()

    oColB2W:SetValue("healthInsurerCode"      ,self:cCodOpe  )    //  B2W_CODOPE
    oColB2W:SetValue("requirementCode"        ,self:cCodObrig)    //  B2W_CODOBR
    oColB2W:SetValue("referenceYear"          ,self:cAno     )    //  B2W_ANOCMP
    oColB2W:SetValue("commitmentCode"         ,self:cCdComp  )    //  B2W_CDCOMP
    oColB2W:SetValue("ssnHolder"              ,self:cCpfTit  )    //  B2W_CPFTIT

    //1=TOP;2=RTOP;3=DTOP;4=RDTOP
    If Empty(self:cCpfBen) .And. Empty(self:cNomBen) .And. !Empty(self:cCpfTit) .And. Empty(self:cCpfCgc)        //replico dados do titular ao beneficiário.
        oColB2W:SetValue("ssnBeneficiary"            ,self:cCpfTit  )    //  B2W_CPFBEN
        oColB2W:SetValue("beneficiaryName"           ,self:cNomTit  )    //  B2W_NOMBEN
        oColB2W:SetValue("recordId"                  ,"1"           )    //  B2W_IDEREG

    Else
        oColB2W:SetValue("ssnBeneficiary"            ,self:cCpfBen  )    //  B2W_CPFBEN
        oColB2W:SetValue("beneficiaryName"           ,self:cNomBen  )    //  B2W_NOMBEN

        If !Empty(self:cCpfCgc) .And. Empty(self:cCpfBen) .And. Empty(self:cNomBen)
            oColB2W:SetValue("ssnBeneficiary"            ,self:cCpfTit  )    //  B2W_CPFBEN
            oColB2W:SetValue("beneficiaryName"           ,self:cNomTit  )    //  B2W_NOMBEN
            oColB2W:SetValue("recordId","2" )

        ElseIf Empty(self:cCpfCgc) .And. (!Empty(self:cCpfBen) .Or. !Empty(self:cNomBen))
            oColB2W:SetValue("recordId","3"  )

        ElseIf !Empty(self:cCpfCgc) .And. (!Empty(self:cCpfBen) .Or. !Empty(self:cNomBen))
            oColB2W:SetValue("recordId","4"  )
        EndIf
    EndIf

    oColB2W:SetValue("dependentBirthDate"        ,self:cDatAni  )    //  B2W_CPFPRE
    oColB2W:SetValue("providerName"              ,self:cNomPre  )    //  B2W_NOMPRE
    oColB2W:SetValue("expenseAmount"             ,self:cVlrDes  )    //  B2W_VLRDES
    oColB2W:SetValue("reimburseTotalValue"       ,self:cValRee  )    //  B2W_VLRREE
    oColB2W:SetValue("previousYearReimburseT"    ,self:cValRaa  )    //  B2W_VLRANE
    oColB2W:SetValue("dependenceRelationship"    ,self:cRelDep  )    //  B2W_RELDEP
    oColB2W:SetValue("status"                    ,self:cStatus  )    //  B2W_STATUS
    oColB2W:SetValue("providerEinSsn"            ,self:cCpfCgc  )    //
    oColB2W:SetValue("holderName"                ,self:cNomTit  )    // B2W_NOMTIT

    oColB2W:insert()

    //após ter gravado a movimentação, verifico se o TOP e/ou RDTOP estão com CPF, caso não esteja e eu tenha prenchido...atualizo.
    If oColB2W:GetValue("recordId") $ '3/4' .And. !Empty(self:cCpfBen)
        if oColB2W:bscCpfBen()       //pego toda família baseado no cpf do titular e limpo as criticas e também ajusto o status

            while oColB2W:HasNext()
                oObjB2W := oColB2W:GetNext()

                B2W->(RecLock("B2W",.F.))
                B2W->B2W_CPFBEN:=self:cCpfBen
                If B2W->B2W_STATUS=='3'
                    B2W->B2W_PROCES:='0'
                    B2W->B2W_STATUS:='1'     //mudando status do processamento pois quando há mudança de CPF e o registro está marcado como criticado precisamos forcar a revalidação.
                EndIf
                B2W->(MsUnlock())
            endDo
        endIf
    EndIf
    oColB2W:destroy()

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} delMovB2W
    Deleta os eventos B2W de uma movimentacao pendente

    @type  Class
    @author jose.paulo
    @since 06/10/2020
/*/
//------------------------------------------------------------------------------------------
Method delMovB2W(oAuxB2W) Class CenPrDmed

    Local oCltB2W := CenCltB2W():New()
    Default oAuxB2W    := nil

    oCltB2W:SetValue("healthInsurerCode"     ,oAuxB2W:getValue("healthInsurerCode"     ))    // Column B2W_CODOPE
    oCltB2W:SetValue("requirementCode"       ,oAuxB2W:getValue("requirementCode"       ))    // Column B2W_CODOBR
    oCltB2W:SetValue("referenceYear"         ,oAuxB2W:getValue("referenceYear"         ))    //Column B2W_ANOCMP
    oCltB2W:SetValue("commitmentCode"        ,oAuxB2W:getValue("commitmentCode"        ))    // Column B2W_CDCOMP
    oCltB2W:SetValue("ssnBeneficiary"        ,oAuxB2W:getValue("ssnBeneficiary"        ))    // Column B2W_CPFBEN
    oCltB2W:SetValue("beneficiaryName"       ,oAuxB2W:getValue("beneficiaryName"       ))     // Column B2W_NOMBEN
    oCltB2W:SetValue("ssnHolder"             ,oAuxB2W:getValue("ssnHolder"             ))     // Column B2W_CPFTIT
    oCltB2W:SetValue("dependentBirthDate"    ,oAuxB2W:getValue("dependentBirthDate"    ))     // Column B2W_CPFPRE
    oCltB2W:SetValue("providerName"          ,oAuxB2W:getValue("providerName"          ))     // Column B2W_NOMPRE
    oCltB2W:SetValue("expenseAmount"         ,oAuxB2W:getValue("expenseAmount"         ))     // Column B2W_VLRDES
    oCltB2W:SetValue("reimburseTotalValue"   ,oAuxB2W:getValue("reimburseTotalValue"   ))    // Column B2W_VLRREE
    oCltB2W:SetValue("previousYearReimburseT",oAuxB2W:getValue("previousYearReimburseT"))    // Column B2W_VLRANE
    oCltB2W:SetValue("dependenceRelationship",oAuxB2W:getValue("dependenceRelationship"))    // Column B2W_RELDEP
    oCltB2W:SetValue("status"                ,oAuxB2W:getValue("status"                ))    // Column B2W_STATUS
    oCltB2W:SetValue("providerEinSsn"        ,oAuxB2W:getValue("providerEinSsn"        ))
    oCltB2W:SetValue("holder"                ,oAuxB2W:getValue("holder"                ))

    oCltB2W:delete()

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} atuProcAPI
    Marca a guia como processada no Alais da API B2Y

    @type  Class
    @author jose.paulo
    @since 06/10/2020
/*/
//------------------------------------------------------------------------------------------
Method atuProcAPI() Class CenPrDmed

    Local oCltB2Y := CenCltB2Y():New()

    oCltB2Y:SetValue("healthInsurerCode",self:cCodOpe)

    if oCltB2Y:bscChaPrim()
        oCltB2Y:mapFromDao()
        oCltB2Y:SetValue("processed","1")
        oCltB2Y:update()
    endIf
    oCltB2Y:destroy()

Return

Method loadChave(oAuxCab) Class CenPrDmed

    Local cAno      := Substr(oAuxCab:getValue("period"),1,4)
    Local cMes      := Strzero(Val(Substr(oAuxCab:getValue("period"),5,2)),2)
    Local oColB3A   := CenCltObri():New()
    Local oAux      := nil
    Local cCodObrig := ""

    oColB3A:SetValue("obligationType","4")
    oColB3A:SetValue("activeInactive","1")
    oColB3A:SetValue("healthInsurerCode",oAuxCab:getValue("healthInsurerCode"))

    if oColB3A:buscar() .And. oColB3A:HasNext()
        oAux      := oColB3A:GetNext()
        cCodObrig := oAux:GetValue("requirementCode")
    endIf

    self:cCodObrig := cCodObrig
    self:cAno      := cAno
    self:cMes      := cMes
    self:cCdComp   := "001"
    self:cCpfBen   := oAuxCab:getValue("dependentSsn")
    self:cCpfTit   := oAuxCab:getValue("ssnHolder")
    self:cNomBen   := oAuxCab:getValue("dependentName")
    self:cNomTit   := oAuxCab:getValue("holderName")
    self:cDatAni   := oAuxCab:getValue("dependentBirthDate")
    self:cRelDep   := oAuxCab:getValue("dependenceRelationships")
    self:cVlrDes   := oAuxCab:getValue("expenseAmount")
    self:cValRee   := oAuxCab:getValue("refundAmount")
    self:cValRaa   := oAuxCab:getValue("previousYearRefundAmt")
    self:cCpfCgc   := oAuxCab:getValue("providerSsnEin")
    self:cNomPre   := oAuxCab:getValue("providerName")
    self:cVlrAne   := oAuxCab:getValue("previousYearReimburseT")
    self:cStatus   := oAuxCab:getValue("status")
    self:cChvDes   := oAuxCab:getValue("expenseKey")
    self:cExclId   := oAuxCab:getValue("exclusionId")

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} excGuia
    Processa a exclusao de uma despesa

    @type  Class
    @author jose.paulo

    @since 20201016
/*/
//------------------------------------------------------------------------------------------
Method excGuia() Class CenPrDmed

    Local oColB2W    := CenCltB2W():New()
    Local oColB2Y    := CenCltB2Y():New()
    Local oObjB2W    := nil
    Local lContinua  := .T.
    Local aAreaB2Y   := B2Y->(GetArea())
    Local nRec       := 0

    If !Empty(self:cCpfBen) .Or. !Empty(self:cNomBen)
        oColB2W:SetValue("ssnBeneficiary"        ,self:cCpfBen  )
        oColB2W:SetValue("beneficiaryName"       ,self:cNomBen  )
        oColB2W:SetValue("ssnHolder"             ,self:cCpfTit  )
    Else
        oColB2W:SetValue("ssnBeneficiary"        ,self:cCpfTit  )
        oColB2W:SetValue("beneficiaryName"       ,self:cNomTit  )
        oColB2W:SetValue("ssnHolder"             ,self:cCpfTit  )
    EndIf

    oColB2W:SetValue("healthInsurerCode"     ,self:cCodOpe  )
    oColB2W:SetValue("requirementCode"       ,self:cCodObrig)
    oColB2W:SetValue("referenceYear"         ,self:cAno     )
    oColB2W:SetValue("commitmentCode"        ,self:cCdComp  )
    oColB2W:SetValue("expenseKey"            ,self:cChvDes  )
    oColB2W:SetValue("period"                ,self:cCompet  )
    oColB2W:SetValue("beneficiaryEnrollment" ,self:cMatDep  )
    oColB2W:SetValue("providerEinSsn"        ,self:cCpfCgc  )
    oColB2W:SetValue("dependentBirthDate"    ,self:cDatAni  )
    oColB2W:SetValue("providerName"          ,self:cNomPre  )
    oColB2W:SetValue("expenseAmount"         ,self:cVlrDes  )
    oColB2W:SetValue("reimburseTotalValue"   ,self:cValRee  )
    oColB2W:SetValue("previousYearReimburseT",self:cValRaa  )
    oColB2W:SetValue("dependenceRelationship",self:cRelDep  )

    oColB2Y:SetValue("healthInsurerCode"     ,self:cCodOpe  )
    oColB2Y:SetValue("ssnHolder"             ,self:cCpfTit  )
    oColB2Y:SetValue("dependentSsn"          ,self:cCpfBen  )
    oColB2Y:SetValue("dependentBirthDate"    ,self:cDatAni  )
    oColB2Y:SetValue("dependentName"         ,self:cNomBen  )
    oColB2Y:SetValue("expenseKey"            ,self:cChvDes  )
    oColB2Y:SetValue("providerSsnEin"        ,self:cCpfCgc  )

    lContinua:=oColB2Y:posregexc()     //posiciono no registro que não é exclusão

    If lContinua

        lContinua:=oColB2W:VerAtuB2W()

        B2Y->(RestArea(aAreaB2Y))

        if lContinua .And. oColB2W:bscChaPrim()

            while oColB2W:HasNext()

                oObjB2W := oColB2W:GetNext()

                nRec:=B2W->(Recno())
                self:delMovB2W(oObjB2W)
                self:delMovB3F(oObjB2W,"B2W",nRec)
                oObjB2W:destroy()
            endDo

            if oColB2W:buscacpf()       //pego toda família baseado no cpf do titular e limpo as criticas e também ajusto o status

                while oColB2W:HasNext()
                    oObjB2W := oColB2W:GetNext()

                    nRec:=B2W->(Recno())
                    self:delMovB3F(oObjB2W,"B2W",nRec)

                    B2W->(RecLock("B2W",.F.))
                    B2W->B2W_STATUS:="1"
                    B2W->B2W_PROCES := "0"
                    B2W->B2W_ROBOHR := ""
                    B2W->B2W_ROBOID := ""
                    B2W->(MsUnlock())
                endDo
            endIf
        endIf
        oColB2W:destroy()
    EndIf
Return


