#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2
#Define PROCESSING '0'
#Define PROCESSED '1'
#Define MSSQL           "MSSQL"
#Define POSTGRES        "POSTGRES"
#Define ORACLE          "ORACLE"

Class CenDaoB2Y from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()
    Method bscChaPrim()
    Method setProcessing()
    Method getMessage()
    Method setEndProc(nRecno)
    Method setExpired()
    Method GetProcess(cIdProc)
    Method DadosB3K(cCodOpe,cMatric,cCpf)
    Method posregexc()
    Method applySearch()
    Method getExpensesByDate(cIncDate,cFinalDate)
    Method dateFilter(cIncDate,cFinalDate)

EndClass

Method New(aFields) Class CenDaoB2Y
    _Super:New(aFields)
    self:cAlias := "B2Y"
    self:cfieldOrder := "B2Y_FILIAL,B2Y_CODOPE,B2Y_CPFTIT,B2Y_CPFDEP,B2Y_DTNASD,B2Y_NOMDEP,B2Y_CPFCGC,B2Y_CHVDES,B2Y_COMPET,B2Y_EXCLU"
Return self

Method buscar() Class CenDaoB2Y
    Local lFound := .F.
    lFound := _Super:buscar()
    If lFound
        B2Y->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoB2Y
    Local lFound := .F.
    if self:bscChaPrim()
        lFound := _Super:delete()
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoB2Y

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B2Y') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	B2Y_FILIAL = '" + xFilial("B2Y") + "' "

    cQuery += " AND B2Y_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("healthInsurerCode")))
    cQuery += " AND B2Y_CPFTIT = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("ssnHolder")))

    If !Empty(self:getValue("dependentSsn")) .Or. Empty(self:getValue("dependenceRelationships"))

        cQuery += " AND ((B2Y_CPFDEP = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("dependentSsn")))
        cQuery += " ) OR (B2Y_CPFDEP = '' AND ( "
        cQuery += " B2Y_DTNASD = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("dependentBirthDate")))
        cQuery += " AND B2Y_NOMDEP = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("dependentName")))
        cQuery += " ))) "
    Else
        cQuery += " AND ( B2Y_DTNASD = ?
        aAdd(self:aMapBuilder, self:toString(self:getValue("dependentBirthDate")))
        cQuery += " AND B2Y_NOMDEP = ? )
        aAdd(self:aMapBuilder, self:toString(self:getValue("beneficiaryName")))

    EndIf

    cQuery += " AND B2Y_CPFCGC = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerSsnEin")))
    cQuery += " AND B2Y_CHVDES = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("expenseKey")))
    cQuery += " AND B2Y_COMPET = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("period")))
    cQuery += " AND B2Y_EXCLU = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("exclusionId")))
    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')

    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()

    If lFound
        B2Y->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

return lFound

Method insert() Class CenDaoB2Y
    Local lFound := !self:bscChaPrim()

    If lFound
        lFound:=self:commit(.T.)
    Else
        lFound:=self:delete()
        lFound:=self:commit(.T.)
    EndIf
Return lFound

Method commit(lInclui) Class CenDaoB2Y
    Local cCpfDep   := _Super:normalizeType(B2Y->B2Y_CPFDEP,self:getValue("dependentSsn"))
    Local cNomTit   := _Super:normalizeType(B2Y->B2Y_NOMTIT,self:getValue("holderName"))
    Local cNomDep   := _Super:normalizeType(B2Y->B2Y_NOMDEP,self:getValue("dependentName"))
    Local cDatNas   := _Super:normalizeType(B2Y->B2Y_DTNASD,self:getValue("dependentBirthDate"))
    Local cRelDep   := _Super:normalizeType(B2Y->B2Y_RELDEP,self:getValue("dependenceRelationships"))
    Local cMatTit   := _Super:normalizeType(B2Y->B2Y_MATTIT,self:getValue("titleHolderEnrollment"))
    Local cMatDep   := _Super:normalizeType(B2Y->B2Y_MATDEP,self:getValue("dependentEnrollment"))
    Local cCodOpe   := _Super:normalizeType(B2Y->B2Y_CODOPE,self:getValue("healthInsurerCode"))
    Local cCpfTit   := _Super:normalizeType(B2Y->B2Y_CPFTIT,self:getValue("ssnHolder"))
    Local cTypeGrv  := _Super:normalizeType(B2Y->B2Y_TIPGRV,self:getValue("inclusionType"))
    Default lInclui := .F.

    If B2Y->(RecLock("B2Y",lInclui))

        B2Y->B2Y_FILIAL := xFilial("B2Y")
        If lInclui
            B2Y->B2Y_CODOPE := cCodOpe
            B2Y->B2Y_CPFTIT := IIF(!Empty(cCpfTit),cCpfTit,Self:DadosB3K(cCodOpe,cMatTit)[1])
            B2Y->B2Y_MATTIT := cMatTit
            B2Y->B2Y_CPFDEP := IIF(!Empty(cCpfDep),cCpfDep,Self:DadosB3K(cCodOpe,cMatDep)[1])
            B2Y->B2Y_MATDEP := cMatDep
            B2Y->B2Y_CHVDES := _Super:normalizeType(B2Y->B2Y_CHVDES,self:getValue("expenseKey")) /* Column B2Y_CHVDES */
            B2Y->B2Y_COMPET := _Super:normalizeType(B2Y->B2Y_COMPET,self:getValue("period")) /* Column B2Y_COMPET */
            B2Y->B2Y_TIPGRV := IIF(!Empty(cTypeGrv),"1","2")
            B2Y->B2Y_PROCES := "0"
            B2Y->B2Y_DATINC := dDataBase
            B2Y->B2Y_HORINC := Substr(Time(),1,2)+Substr(Time(),4,2)+Substr(Time(),7,2)  /* Column B2Y_HORINC */

        EndIf

        B2Y->B2Y_NOMTIT := IIF(!Empty(cNomTit),cNomTit,Self:DadosB3K(cCodOpe,cMatTit)[2])
        B2Y->B2Y_NOMDEP := IIF(!Empty(cNomDep),cNomDep,Self:DadosB3K(cCodOpe,cMatDep)[2])
        B2Y->B2Y_DTNASD := IIF(!Empty(cDatNas),cDatNas,Self:DadosB3K(cCodOpe,cMatDep)[4]) //data de nascimento sempre é do dependente
        B2Y->B2Y_RELDEP := IIF(!Empty(cRelDep),cRelDep,Self:DadosB3K(cCodOpe,cMatDep)[3]) //para o titular sempre será vazia
        B2Y->B2Y_VLRDES := _Super:normalizeType(B2Y->B2Y_VLRDES,self:getValue("expenseAmount")) /* Column B2Y_VLRDES */
        B2Y->B2Y_VLRREE := _Super:normalizeType(B2Y->B2Y_VLRREE,self:getValue("refundAmount")) /* Column B2Y_VLRREE */
        B2Y->B2Y_VLRRAA := _Super:normalizeType(B2Y->B2Y_VLRRAA,self:getValue("previousYearRefundAmt")) /* Column B2Y_VLRRAA */
        B2Y->B2Y_CPFCGC := _Super:normalizeType(B2Y->B2Y_CPFCGC,self:getValue("providerSsnEin")) /* Column B2Y_CPFCGC */
        B2Y->B2Y_NOMPRE := _Super:normalizeType(B2Y->B2Y_ROBOID,self:getValue("providerName")) /* Column B2Y_ROBOID */
        B2Y->B2Y_EXCLU  := IIF(!Empty(self:getValue("exclusionId")),_Super:normalizeType(B2Y->B2Y_EXCLU,self:getValue("exclusionId")),"0")
        B2Y->B2Y_ROBOID := _Super:normalizeType(B2Y->B2Y_ROBOID,self:getValue("roboId")) /* Column B2Y_ROBOID */

        B2Y->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound


Method setProcessing() Class CenDaoB2Y

    Local cQuery := ""
    Local lFound := .F.

    If self:cDB <> POSTGRES

        If self:cDB $ MSSQL
            cQuery := " UPDATE TOP(1) "
        Else
            cQuery := " UPDATE "

        EndIf

        cQuery += " " + RetSqlName('B2Y') + " "
        cQuery += " SET "
        cQuery += " B2Y_PROCES = '" + PROCESSING + "' "
        cQuery += " , B2Y_ROBOID='"+self:toString(self:getValue("processId"))+"' "
        cQuery += " , B2Y_ROBOHR = '" + DToS(Date()) + " " + Time() + "' "
        cQuery += " WHERE 1=1 "
        cQuery += " AND B2Y_FILIAL = '" + xFilial( 'B2Y' ) + "' "
        cQuery += " AND B2Y_PROCES <> '" + PROCESSED + "' "
        cQuery += " AND B2Y_ROBOID = '' "

        If (self:cDB $ "ORACLE")
            cQuery += "	AND ROWNUM = 1 "
        EndIf

        cQuery += " AND D_E_L_E_T_ = ' ' "

    Else
        cQuery := " UPDATE " + RetSqlName('B2Y') + " SET "
        cQuery += " B2Y_PROCES = '" + PROCESSING + "' "
        cQuery += " , B2Y_ROBOID='"+self:toString(self:getValue("processId"))+"' "
        cQuery += " , B2Y_ROBOHR = '" + DToS(Date()) + " " + Time() + "' "
        cQuery += " WHERE R_E_C_N_O_ = (SELECT R_E_C_N_O_ FROM  " + RetSqlName('B2Y') + " WHERE  "
        cQuery += " B2Y_FILIAL = '" + xFilial( 'B2Y' ) + "' "
        cQuery += " AND B2Y_PROCES <> '" + PROCESSED + "' "
        cQuery += " AND B2Y_ROBOID = '' "
        cQuery += " AND D_E_L_E_T_ = ' ' "
        cQuery += "	LIMIT 1 )"

    EndIf

    self:setQuery(cQuery)
    lFound := self:execStatement()

Return lFound

Method getMessage() Class CenDaoB2Y

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B2Y') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND B2Y_PROCES = '" + PROCESSING + "' "
    cQuery += " AND B2Y_ROBOID ='"+self:toString(self:getValue("processId"))+"' "

    self:setQuery(cQuery)
    lFound := self:executaQuery()
    If lFound
        B2Y->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

return lFound

Method setEndProc(nRecno) Class CenDaoB2Y

    Local cQuery := ""
    Local lFound := .F.

    Default nRecno := 0

    If self:cDB <> POSTGRES

        If self:cDB $ MSSQL
            cQuery := " UPDATE TOP(1) "
        Else
            cQuery := " UPDATE "

        EndIf
        cQuery += " " + RetSqlName('B2Y') + " "
        cQuery += " SET "
        cQuery += " B2Y_PROCES = '" + PROCESSED + "' "
        cQuery += " WHERE 1=1 "
        cQuery += " AND R_E_C_N_O_ = '" + AllTrim(Str(nRecno)) + "' "

        If (self:cDB $ "ORACLE")
            cQuery += "	AND ROWNUM = 1 "
        EndIf

    Else
        cQuery := " UPDATE " + RetSqlName('B2Y') + " SET "
        cQuery += " B2Y_PROCES = '" + PROCESSED + "' "
        cQuery += " WHERE R_E_C_N_O_ = (SELECT R_E_C_N_O_ FROM  " + RetSqlName('B2Y') + " "
        cQuery += " WHERE 1=1 "
        cQuery += " AND R_E_C_N_O_ = '" + AllTrim(Str(nRecno)) + "' "
        cQuery += "	LIMIT 1 )"

    EndIf

    self:setQuery(cQuery)
    lFound := self:execStatement()

Return lFound

Method setExpired() Class CenDaoB2Y

    Local cQuery := ""
    Local lFound := .F.

    cQuery := " UPDATE "
    cQuery += " " + RetSqlName('B2Y') + " "
    cQuery += " SET "
    cQuery += " B2Y_ROBOID = '' "
    cQuery += " ,B2Y_PROCES = '" + PROCESSING + "' "
    cQuery += " WHERE 1=1 "
    cQuery += " AND B2Y_ROBOID <> '' "
    cQuery += " AND B2Y_PROCES = '" + PROCESSING + "' "
    cQuery += " AND B2Y_ROBOHR <= '" + SubMinutos(Date(),Time(),2) + "' "
    cQuery += " AND B2Y_ROBOHR <> ' ' "
    cQuery += " AND D_E_L_E_T_ = ' ' "

    self:setQuery(cQuery)
    lFound := self:execStatement()
Return lFound

Method GetProcess(cIdProc) Class CenDaoB2Y

    Local cQuery    := ''
    Local lFound    := .F.
    Default cIdProc := ''

    cQuery := " SELECT  "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B2Y') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	B2Y_FILIAL = '" + xFilial("B2Y") + "' "
    cQuery += " AND B2Y_ROBOID = '"+ AllTrim(Str(cIdProc)) +"' "
    cQuery += " AND B2Y_PROCES = '" + PROCESSED + "' "
    cQuery += " AND D_E_L_E_T_ = ' ' "

    self:setQuery(cQuery)
    lFound := self:executaQuery()
    If lFound
        B2Y->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

Return lFound

Method DadosB3K(cCodOpe,cMatric,cCpf) class CenDaoB2Y
    Local cQuery    := ''
    Local lFound    := .F.
    Local aRet      := {}
    Default cCodOpe := ''
    Default cMatric := ''
    Default cCpf    := ''

    If !Empty(cCodOpe) .And. (!Empty(cMatric) .Or. !Empty(cCpf))
        cQuery := " SELECT R_E_C_N_O_ RECNO  "
        cQuery += " FROM " + RetSqlName('B3K') + " "
        cQuery += " WHERE B3K_FILIAL = '" + xFilial("B3K") + "' "
        cQuery += " AND B3K_CODOPE = '"+ cCodOpe +"' "

        If !Empty(cMatric)
            cQuery += " AND B3K_MATRIC = '" + cMatric + "' "
        EndIf
        If !Empty(cCpf)
            cQuery += " AND B3K_MATRIC = '" + cCpf + "' "
        EndIf

        cQuery += " AND D_E_L_E_T_ = ' ' "

        self:setQuery(cQuery)
        lFound := self:executaQuery()
        If lFound
            B3K->(DbGoto((self:getAliasTemp())->RECNO))
            AADD(aRet,B3K->B3K_CPF)
            AADD(aRet,AllTrim(B3K->B3K_NOMBEN))
            AADD(aRet,B3K->B3K_TIPDEP)
            AADD(aRet,B3K->B3K_DATNAS)
        Else
            aRet:= {'','','',Ctod("  /  /    ")}
        EndIf

    Else
        aRet:= {'','','',Ctod("  /  /    ")}
    EndIf

Return aRet

Method posregexc() Class CenDaoB2Y

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B2Y') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND B2Y_CODOPE ='"+self:toString(self:getValue("healthInsurerCode"))+"' "
    cQuery += " AND B2Y_CPFTIT ='"+self:toString(self:getValue("ssnHolder"))+"' "
    cQuery += " AND B2Y_CPFDEP ='"+self:toString(self:getValue("dependentSsn"))+"' "
    cQuery += " AND B2Y_DTNASD ='"+self:toString(self:getValue("dependentBirthDate"))+"' "
    cQuery += " AND B2Y_NOMDEP ='"+self:toString(self:getValue("dependentName"))+"' "
    cQuery += " AND B2Y_CHVDES ='"+self:toString(self:getValue("expenseKey"))+"' "
    cQuery += " AND B2Y_CPFCGC ='"+self:toString(self:getValue("providerSsnEin"))+"' "
    cQuery += " AND B2Y_EXCLU <> '1'   "

    self:setQuery(cQuery)
    lFound := self:executaQuery()
    If lFound
        B2Y->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

return lFound

Method applySearch(cSearch) Class CenDaoB2Y

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B2Y') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	B2Y_FILIAL = '" + xFilial("B2Y") + "' "
    cQuery += " AND ( 1=2 "
    cQuery += " OR B2Y_CODOPE LIKE '%" + Upper(cSearch) + "%'"
    cQuery += " OR B2Y_NOMTIT LIKE '%" + Upper(cSearch) + "%'"
    cQuery += " OR B2Y_NOMTIT LIKE '%" + Lower(cSearch) + "%'"
    cQuery += " OR B2Y_NOMTIT LIKE '%" + cSearch + "%'"
    cQuery += " OR B2Y_MATTIT LIKE '%" + Lower(cSearch) + "%'"
    cQuery += " OR B2Y_CPFTIT LIKE '%" + Upper(cSearch) + "%'"
    cQuery += " OR B2Y_CPFDEP LIKE '%" + Upper(cSearch) + "%'"
    cQuery += " OR B2Y_NOMDEP LIKE '%" + Upper(cSearch) + "%'"
    cQuery += " OR B2Y_NOMDEP LIKE '%" + Lower(cSearch) + "%'"
    cQuery += " OR B2Y_NOMDEP LIKE '%" + cSearch + "%'"
    cQuery += " OR B2Y_COMPET LIKE '%" + Lower(cSearch) + "%'"
    cQuery += " ) "
    cQuery += " AND D_E_L_E_T_ = ' ' "
    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()

return lFound

Method getExpensesByDate(cIncDate,cFinalDate) Class CenDaoB2Y

    Local cQuery := ""
    Local lFound := .F.

    cQuery += _Super:getRowControl()
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName("B2Y") + " " + "B2Y "
    cQuery += self:dateFilter(cIncDate,cFinalDate)
    cQuery := _Super:queryBuilder(cQuery)
    cQuery += _Super:getWhereRow()

    _Super:setQuery(cQuery)
    lFound := _Super:executaQuery()

return lFound

method dateFilter(cIncDate,cFinalDate) Class CenDaoB2Y
    local cFilter := ''

    cFilter += _Super:getFilters()
    if !Empty(cIncDate)
        cFilter += " AND B2Y_DATINC >= ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("inicialDate")))
    EndIf
    If !Empty(cFinalDate)
        cFilter += " AND B2Y_DATINC <= ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("finalDate")))
    EndIf

return cFilter


