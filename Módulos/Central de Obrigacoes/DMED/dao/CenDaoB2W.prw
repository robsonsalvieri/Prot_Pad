#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2
#Define PROCESSING '0'
#Define PROCESSED '1'
#define TOP         "1"
#define RTOP        "2"
#define DTOP        "3"
#define RDTOP       "4"
#Define MSSQL           "MSSQL"
#Define POSTGRES        "POSTGRES"
#Define ORACLE          "ORACLE"

Class CenDaoB2W from CenDao
    Data lAuto  As Boolean

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()
    Method bscChaPrim()
    Method setExpired()
    Method setProcessing()
    Method getMessage()
    Method getAnoOpe()
    Method getTop()
    Method getRTop(cCpfTit)
    Method getDTop(cCpfTit)
    Method getRDTop(cCpfBenef, cBenefName)
    Method setEndProc(nRecno)
    Method VerAtuB2W()
    Method updateStatus(cStatus)
    Method buscacpf()
    Method setCriPro()
    Method bscCpfBen()
    Method setlAuto(lAuto)
EndClass

Method New(aFields) Class CenDaoB2W
    _Super:New(aFields)
    self:cAlias := "B2W"
    self:cfieldOrder := "B2W_FILIAL,B2W_CODOPE,B2W_CODOBR,B2W_ANOCMP,B2W_CDCOMP,B2W_CPFTIT,B2W_CPFBEN,B2W_DTNASD,B2W_NOMBEN,B2W_CPFPRE"
    self:setlAuto()
Return self

Method setlAuto(lAuto) Class CenDaoB2W
    Default lAuto   := .F.
    self:lAuto      := lAuto
Return

Method buscar() Class CenDaoB2W
    Local lFound := .F.
    lFound := _Super:buscar()
    If lFound
        B2W->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoB2W
    Local lFound := .F.
    if self:bscChaPrim()
        lFound := _Super:delete()
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoB2W

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B2W') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	B2W_FILIAL = '" + xFilial("B2W") + "' "

    cQuery += " AND B2W_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("healthInsurerCode")))
    cQuery += " AND B2W_CODOBR = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND B2W_ANOCMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND B2W_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND B2W_CPFTIT = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("ssnHolder")))
    //-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    If !Empty(self:getValue("ssnBeneficiary")) .Or. Empty(self:getValue("dependenceRelationship"))

        cQuery += " AND ((B2W_CPFBEN = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("ssnBeneficiary")))
        cQuery += " AND B2W_CPFBEN <> '') OR ( B2W_CPFBEN = '' AND ( "
        cQuery += " B2W_DTNASD = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("dependentBirthDate")))
        cQuery += " AND B2W_NOMBEN = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("beneficiaryName")))
        cQuery += " ))) "
    Else
        cQuery += " AND ( B2W_DTNASD = ?
        aAdd(self:aMapBuilder, self:toString(self:getValue("dependentBirthDate")))
        cQuery += " AND B2W_NOMBEN = ? )
        aAdd(self:aMapBuilder, self:toString(self:getValue("beneficiaryName")))

    Endif
    //-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    cQuery += " AND B2W_CPFPRE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerEinSsn")))
    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()

    If lFound
        B2W->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

return lFound

Method insert() Class CenDaoB2W
    Local lFound := self:bscChaPrim()

    If lFound
        lFound:=self:commit(.F.) //estou adicionando valor a um registro que ja existe na B2W.
    Else
        lFound:=self:commit(.T.) //crio novo registro
    EndIf

Return lFound

Method commit(lInclui,lSub) Class CenDaoB2W
    Local lFound    := .F.
    Default lInclui := .F.
    Default lSub    := .F.

    If B2W->(RecLock("B2W",lInclui))

        B2W->B2W_FILIAL := xFilial("B2W")
        If lInclui

            B2W->B2W_CODOPE := _Super:normalizeType(B2W->B2W_CODOPE,self:getValue("healthInsurerCode"))
            B2W->B2W_CODOBR := _Super:normalizeType(B2W->B2W_CODOBR,self:getValue("requirementCode"))
            B2W->B2W_ANOCMP := _Super:normalizeType(B2W->B2W_ANOCMP,self:getValue("referenceYear"  ))
            B2W->B2W_CDCOMP := _Super:normalizeType(B2W->B2W_CDCOMP,self:getValue("commitmentCode"))
            B2W->B2W_CPFTIT := _Super:normalizeType(B2W->B2W_CPFTIT,self:getValue("ssnHolder"))
            B2W->B2W_CPFBEN := _Super:normalizeType(B2W->B2W_CPFBEN,self:getValue("ssnBeneficiary"))
            B2W->B2W_NOMBEN := _Super:normalizeType(B2W->B2W_NOMBEN,self:getValue("beneficiaryName"))
            B2W->B2W_CPFPRE := _Super:normalizeType(B2W->B2W_CPFPRE,self:getValue("providerEinSsn"))
            B2W->B2W_VLRDES := _Super:normalizeType(B2W->B2W_VLRDES,self:getValue("expenseAmount"))
            B2W->B2W_VLRREE := _Super:normalizeType(B2W->B2W_VLRREE,self:getValue("reimburseTotalValue"))
            B2W->B2W_VLRANE := _Super:normalizeType(B2W->B2W_VLRANE,self:getValue("previousYearReimburseT"))
            B2W->B2W_DTNASD := _Super:normalizeType(B2W->B2W_DTNASD,self:getValue("dependentBirthDate"))
            B2W->B2W_RELDEP := _Super:normalizeType(B2W->B2W_RELDEP,self:getValue("dependenceRelationship"))
            B2W->B2W_NOMPRE := _Super:normalizeType(B2W->B2W_NOMPRE,self:getValue("providerName"))
            B2W->B2W_IDEREG := _Super:normalizeType(B2W->B2W_IDEREG,self:getValue("recordId"))

        Else

            If B2W->B2W_IDEREG $ "1/2"   //1=TOP;2=RTOP;3=DTOP;4=RDTOP
                B2W->B2W_NOMBEN := B2Y->B2Y_NOMTIT
                B2W->B2W_CPFBEN := B2Y->B2Y_CPFTIT
            Else
                B2W->B2W_NOMBEN := B2Y->B2Y_NOMDEP
                B2W->B2W_DTNASD := B2Y->B2Y_DTNASD
                B2W->B2W_RELDEP := B2Y->B2Y_RELDEP
                B2W->B2W_NOMPRE := B2Y->B2Y_NOMPRE
                B2W->B2W_CPFBEN := B2Y->B2Y_CPFDEP

            EndIf

            If lSub
                IF B2W->B2W_IDEREG $ '1/3'
                    B2W->B2W_VLRDES -= _Super:normalizeType(B2W->B2W_VLRDES,self:getValue("expenseAmount")) // Column B2W_VLRDES
                Else
                    B2W->B2W_VLRREE -= _Super:normalizeType(B2W->B2W_VLRREE,self:getValue("reimburseTotalValue")) // Column B2W_VLRREE
                    B2W->B2W_VLRANE -= _Super:normalizeType(B2W->B2W_VLRANE,self:getValue("previousYearReimburseT")) // Column B2W_VLRANE
                EndIf

            Else

                IF B2W->B2W_IDEREG $ '1/3'
                    B2W->B2W_VLRDES += _Super:normalizeType(B2W->B2W_VLRDES,self:getValue("expenseAmount")) // Column B2W_VLRDES
                Else
                    B2W->B2W_VLRREE += _Super:normalizeType(B2W->B2W_VLRREE,self:getValue("reimburseTotalValue")) // Column B2W_VLRREE
                    B2W->B2W_VLRANE += _Super:normalizeType(B2W->B2W_VLRANE,self:getValue("previousYearReimburseT")) // Column B2W_VLRANE
                EndIf
            EndIf

        EndIf
        If self:lAuto
            B2W->B2W_STATUS := _Super:normalizeType(B2W->B2W_STATUS,self:getValue("status"))
            B2W->B2W_PROCES := "1"
        Else
            B2W->B2W_STATUS := "1"
            B2W->B2W_PROCES := "0"
        EndIf
        B2W->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound

Method setExpired() Class CenDaoB2W

    Local cQuery := ""
    Local lFound := .F.

    cQuery := " UPDATE "
    cQuery += " " + RetSqlName('B2W') + " "
    cQuery += " SET "
    cQuery += " B2W_ROBOID = '' "
    cQuery += " ,B2W_PROCES = '" + PROCESSING + "' "
    cQuery += " WHERE 1=1 "
    cQuery += " AND B2W_ROBOID <> '' "
    cQuery += " AND B2W_PROCES = '" + PROCESSING + "' "
    cQuery += " AND B2W_ROBOHR <= '" + SubMinutos(Date(),Time(),2) + "' "
    cQuery += " AND B2W_ROBOHR <> ' ' "
    cQuery += " AND D_E_L_E_T_ = ' ' "

    self:setQuery(cQuery)
    lFound := self:execStatement()
Return lFound

Method setProcessing() Class CenDaoB2W

    Local cQuery := ""
    Local lFound := .F.

    If self:cDB <> POSTGRES

        If self:cDB $ MSSQL
            cQuery := " UPDATE TOP(1) "
        Else
            cQuery := " UPDATE "

        EndIf

        cQuery += " " + RetSqlName('B2W') + " "
        cQuery += " SET "
        cQuery += " B2W_PROCES = '" + PROCESSING + "' "
        cQuery += " , B2W_ROBOID='"+self:toString(self:getValue("processId"))+"' "
        cQuery += " , B2W_ROBOHR = '" + DToS(Date()) + " " + Time() + "' "
        cQuery += " WHERE 1=1 "
        cQuery += " AND B2W_FILIAL = '" + xFilial( 'B2W' ) + "' "
        cQuery += " AND B2W_PROCES <> '" + PROCESSED + "' "
        cQuery += " AND B2W_ROBOID = '' "

        If (self:cDB $ "ORACLE")
            cQuery += "	AND ROWNUM = 1 "
        EndIf

        cQuery += " AND D_E_L_E_T_ = ' ' "

    Else
        cQuery := " UPDATE " + RetSqlName('B2W') + " SET "
        cQuery += " B2W_PROCES = '" + PROCESSING + "' "
        cQuery += " , B2W_ROBOID='"+self:toString(self:getValue("processId"))+"' "
        cQuery += " , B2W_ROBOHR = '" + DToS(Date()) + " " + Time() + "' "
        cQuery += " WHERE R_E_C_N_O_ = (SELECT R_E_C_N_O_ FROM  " + RetSqlName('B2W') + " WHERE  "
        cQuery += " B2W_FILIAL = '" + xFilial( 'B2W' ) + "' "
        cQuery += " AND B2W_PROCES <> '" + PROCESSED + "' "
        cQuery += " AND B2W_ROBOID = '' "
        cQuery += " AND D_E_L_E_T_ = ' ' "
        cQuery += "	LIMIT 1 )"

    EndIf

    self:setQuery(cQuery)
    lFound := self:execStatement()

Return lFound

Method getMessage() Class CenDaoB2W

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B2W') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND B2W_PROCES = '" + PROCESSING + "' "
    cQuery += " AND B2W_ROBOID ='"+self:toString(self:getValue("processId"))+"' "

    self:setQuery(cQuery)
    lFound := self:executaQuery()
    If lFound
        B2W->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

return lFound

Method getAnoOpe() Class CenDaoB2W

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B2W') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND B2W_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("healthInsurerCode")))
    cQuery += " AND B2W_ANOCMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND B2W_STATUS IN ('" + self:toString(self:getValue("status")) + "')"
    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')

    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()
    If lFound
        B2W->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

return lFound

Method getTop() Class CenDaoB2W

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B2W') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND B2W_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("healthInsurerCode")))
    cQuery += " AND B2W_ANOCMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND B2W_STATUS IN ('" + self:toString(self:getValue("status")) + "')"
    cQuery += " AND B2W_IDEREG = '" + TOP + "' "
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY B2W_CPFTIT "

    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()
    If lFound
        B2W->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

return lFound

Method getRTop(cCpfTit) Class CenDaoB2W

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B2W') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND B2W_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("healthInsurerCode")))
    cQuery += " AND B2W_ANOCMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND B2W_STATUS IN ('" + self:toString(self:getValue("status")) + "')"
    cQuery += " AND B2W_IDEREG = '" + RTOP + "' "
    cQuery += " AND B2W_CPFTIT = '" + cCpfTit + "' "
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY B2W_CPFPRE "

    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()
    If lFound
        B2W->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

return lFound

Method getDTop(cCpfTit) Class CenDaoB2W

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B2W') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND B2W_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("healthInsurerCode")))
    cQuery += " AND B2W_ANOCMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND B2W_STATUS IN ('" + self:toString(self:getValue("status")) + "')"
    cQuery += " AND B2W_IDEREG = '" + DTOP + "' "
    cQuery += " AND B2W_CPFTIT = '" + cCpfTit + "' "
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY B2W_CPFBEN "
    cQuery += " , B2W_DTNASD "

    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()
    If lFound
        B2W->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

return lFound

Method getRDTop(cCpfBenef, cBenefName) Class CenDaoB2W

    Local lFound := .F.
    Local cQuery := ""
    Local cDB	 := TCGetDB()

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B2W') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND B2W_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("healthInsurerCode")))
    cQuery += " AND B2W_ANOCMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND B2W_STATUS IN ('" + self:toString(self:getValue("status")) + "')"
    cQuery += " AND B2W_IDEREG = '" + RDTOP + "' "
    If !Empty(cCpfBenef) .And. Len(cCpfBenef) == 11
        cQuery += " AND B2W_CPFBEN = '" + cCpfBenef + "' "
    Else
        cQuery += " AND B2W_NOMBEN = '" + cBenefName + "' "
        cQuery += " AND B2W_CPFBEN = '' "
    EndIf
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY "
    If cDB $ 'ORACLE/POSTGRES'
        cQuery += " LENGTH(B2W_CPFPRE) "
    else
        cQuery += " LEN(B2W_CPFPRE) "
    Endif
    cQuery += " , B2W_CPFPRE "

    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()
    If lFound
        B2W->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

return lFound

Method setEndProc(nRecno) Class CenDaoB2W

    Local cQuery := ""
    Local lFound := .F.

    Default nRecno := 0

    If self:cDB <> POSTGRES

        If self:cDB $ MSSQL
            cQuery := " UPDATE TOP(1) "
        Else
            cQuery := " UPDATE "

        EndIf
        cQuery += " " + RetSqlName('B2W') + " "
        cQuery += " SET "
        cQuery += " B2W_PROCES = '" + PROCESSED + "' "
        cQuery += " WHERE 1=1 "
        cQuery += " AND R_E_C_N_O_ = '" + AllTrim(Str(nRecno)) + "' "

        If (self:cDB $ "ORACLE")
            cQuery += "	AND ROWNUM = 1 "
        EndIf

    Else
        cQuery := " UPDATE " + RetSqlName('B2W') + " SET "
        cQuery += " B2W_PROCES = '" + PROCESSED + "' "
        cQuery += " WHERE R_E_C_N_O_ = (SELECT R_E_C_N_O_ FROM  " + RetSqlName('B2W') + " "
        cQuery += " WHERE 1=1 "
        cQuery += " AND R_E_C_N_O_ = '" + AllTrim(Str(nRecno)) + "' "
        cQuery += "	LIMIT 1 )"

    EndIf

    self:setQuery(cQuery)
    lFound := self:execStatement()

Return lFound

Method VerAtuB2W() Class CenDaoB2W

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B2W') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	B2W_FILIAL = '" + xFilial("B2W") + "' "

    cQuery += " AND B2W_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("healthInsurerCode")))
    cQuery += " AND B2W_CODOBR = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND B2W_ANOCMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND B2W_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND B2W_CPFTIT = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("ssnHolder")))
    cQuery += " AND B2W_CPFBEN = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("ssnBeneficiary")))
    cQuery += " AND B2W_DTNASD = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("dependentBirthDate")))
    cQuery += " AND B2W_NOMBEN = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("beneficiaryName")))
    cQuery += " AND B2W_CPFPRE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerEinSsn")))
    cQuery += " AND D_E_L_E_T_ = ? "

    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()
    If lFound
        B2W->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

    If lFound                                //1=TOP;2=RTOP;3=DTOP;4=RDTOP
        B2W->(RecLock("B2W",.F.))

        If B2W->B2W_IDEREG $ "1/3"
            If (B2W->B2W_VLRDES - B2Y->B2Y_VLRDES)<=0
                B2W->B2W_VLRDES:= 0
                lFound:= .T.
            Else
                B2W->B2W_VLRDES -= B2Y->B2Y_VLRDES
                lFound:= .F.
            EndIf
        Else
            If (B2W->B2W_VLRANE - B2Y->B2Y_VLRRAA)<=0
                B2W->B2W_VLRANE := 0
            Else
                B2W->B2W_VLRANE -= B2Y->B2Y_VLRRAA
            EndIf

            If (B2W->B2W_VLRREE - B2Y->B2Y_VLRREE)<=0
                B2W->B2W_VLRREE := 0
            Else
                B2W->B2W_VLRREE -= B2Y->B2Y_VLRREE
            EndIf

            If B2W->B2W_VLRANE > 0 .Or. B2W->B2W_VLRREE > 0
                lFound:= .F.
            Else
                lFound:= .T.
            EndIf

        EndIf
        B2W->(MsUnlock())

    endif

Return lFound        //lFound = .F. significa que não tenho mais "saldo" na tabela B2W

Method updateStatus(cStatus) Class CenDaoB2W

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " UPDATE "
    cQuery += " " + RetSqlName('B2W') + " "
    cQuery += " SET "
    cQuery += " B2W_STATUS='"+cStatus+"' "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	B2W_FILIAL = '" + xFilial("B2W") + "' "

    cQuery += " AND B2W_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("healthInsurerCode")))
    cQuery += " AND B2W_CODOBR = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND B2W_ANOCMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND B2W_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND B2W_STATUS = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("status")))
    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')

    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:execStatement()

return lFound

Method buscacpf() Class CenDaoB2W

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B2W') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	B2W_FILIAL = '" + xFilial("B2W") + "' "

    cQuery += " AND B2W_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("healthInsurerCode")))
    cQuery += " AND B2W_CODOBR = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND B2W_ANOCMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND B2W_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND B2W_CPFTIT = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("ssnHolder")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()

    If lFound
        B2W->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

return lFound

Method setCriPro() Class CenDaoB2W

    Local cQuery := ""
    Local lFound := .F.

    cQuery := " UPDATE " + RetSqlName('B2W') + " SET "
    cQuery += " B2W_PROCES = '" + PROCESSING + "' "
    cQuery += " , B2W_ROBOID='' "
    cQuery += " WHERE B2W_STATUS = '3' "
    cQuery += " AND D_E_L_E_T_ = ' ' "

    self:setQuery(cQuery)
    lFound := self:execStatement()

Return lFound

Method bscCpfBen() Class CenDaoB2W

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B2W') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	B2W_FILIAL = '" + xFilial("B2W") + "' "

    cQuery += " AND B2W_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("healthInsurerCode")))
    cQuery += " AND B2W_CODOBR = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND B2W_ANOCMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND B2W_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND B2W_CPFTIT = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("ssnHolder")))
    cQuery += " AND B2W_IDEREG <> ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("recordId")))
    cQuery += " AND B2W_NOMBEN = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("beneficiaryName")))

    If !Empty(self:getValue("dependentBirthDate"))
        cQuery += " AND B2W_DTNASD = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("dependentBirthDate")))
    Endif

    cQuery += " AND B2W_CPFBEN = '' AND B2W_IDEREG NOT IN ('1','2')    AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()

    If lFound
        B2W->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

return lFound