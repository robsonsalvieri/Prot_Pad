#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2
#Define PROCESSING '0'
#Define PROCESSED '1'
#Define MSSQL     "MSSQL"
#Define POSTGRES  "POSTGRES"
#Define ORACLE    "ORACLE"

Class CenDaoB2X from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method commit()
    Method delete()
    Method bscChaPrim()
    Method setProcessing()
    Method getMessage()
    Method setEndProc(nRecno)
    Method setExpired()
    Method GetProcess(cIdProc)

EndClass

Method New(aFields) Class CenDaoB2X
    _Super:New(aFields)
    self:cAlias := "B2X"
    self:cfieldOrder := "B2X_SEQUEN,B2X_CODOPE"
Return self

Method buscar() Class CenDaoB2X
    Local lFound := .F.
    lFound := _Super:buscar()
    If lFound
        B2X->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoB2X
    Local lFound := .F.
    if self:bscChaPrim()
        lFound := _Super:delete()
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoB2X

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B2X') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	B2X_FILIAL = '" + xFilial("B2X") + "' "

    cQuery += " AND B2X_SEQUEN = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("formSequential")))
    cQuery += " AND B2X_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()

return lFound

Method commit(lInclui) Class CenDaoB2X

    Default lInclui := .F.

    If B2X->(RecLock("B2X",lInclui))

        B2X->B2X_FILIAL := xFilial("B2X")
        If lInclui

            B2X->B2X_SEQUEN := _Super:normalizeType(B2X->B2X_SEQUEN,self:getValue("formSequential")) /* Column B2X_SEQUEN */
            B2X->B2X_CODOPE := _Super:normalizeType(B2X->B2X_CODOPE,self:getValue("operatorRecord")) /* Column B2X_CODOPE */

        EndIf

        B2X->B2X_VLRPRE := _Super:normalizeType(B2X->B2X_VLRPRE,self:getValue("presetValue")) /* Column B2X_VLRPRE */
        B2X->B2X_CDMNPR := _Super:normalizeType(B2X->B2X_CDMNPR,self:getValue("cityOfProvider")) /* Column B2X_CDMNPR */
        B2X->B2X_CNES := _Super:normalizeType(B2X->B2X_CNES,self:getValue("cnes")) /* Column B2X_CNES */
        B2X->B2X_COMCOB := _Super:normalizeType(B2X->B2X_COMCOB,self:getValue("periodCover")) /* Column B2X_COMCOB */
        B2X->B2X_CPFCNP := _Super:normalizeType(B2X->B2X_CPFCNP,self:getValue("providerCpfCnpj")) /* Column B2X_CPFCNP */
        B2X->B2X_DATINC := _Super:normalizeType(B2X->B2X_DATINC,self:getValue("inclusionDate")) /* Column B2X_DATINC */
        B2X->B2X_EXCLU := _Super:normalizeType(B2X->B2X_EXCLU,self:getValue("exclusionId")) /* Column B2X_EXCLU */
        B2X->B2X_HORINC := _Super:normalizeType(B2X->B2X_HORINC,self:getValue("inclusionTime")) /* Column B2X_HORINC */
        B2X->B2X_IDEPRE := _Super:normalizeType(B2X->B2X_IDEPRE,self:getValue("providerIdentifier")) /* Column B2X_IDEPRE */
        B2X->B2X_IDVLRP := _Super:normalizeType(B2X->B2X_IDVLRP,self:getValue("presetValueIdent")) /* Column B2X_IDVLRP */
        B2X->B2X_PROCES := _Super:normalizeType(B2X->B2X_PROCES,self:getValue("processed")) /* Column B2X_PROCES */
        B2X->B2X_RGOPIN := _Super:normalizeType(B2X->B2X_RGOPIN,self:getValue("ansRecordNumber")) /* Column B2X_RGOPIN */
        B2X->B2X_ROBOID := _Super:normalizeType(B2X->B2X_ROBOID,self:getValue("roboId")) /* Column B2X_ROBOID */

        B2X->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound

Method setProcessing() Class CenDaoB2X

    Local cQuery := ""
    Local lFound := .F.

    If self:cDB <> POSTGRES

        If self:cDB $ MSSQL
            cQuery := " UPDATE TOP(1) "
        Else
            cQuery := " UPDATE "

        EndIf

        cQuery += " " + RetSqlName('B2X') + " "
        cQuery += " SET "
        cQuery += " B2X_PROCES = '" + PROCESSING + "' "
        cQuery += " , B2X_ROBOID='"+self:toString(self:getValue("processId"))+"' "
        cQuery += " , B2X_ROBOHR = '" + DToS(Date()) + " " + Time() + "' "
        cQuery += " WHERE 1=1 "
        cQuery += " AND B2X_FILIAL = '" + xFilial( 'B2X' ) + "' "
        cQuery += " AND B2X_PROCES <> '" + PROCESSED + "' "
        cQuery += " AND B2X_ROBOID = '' "

        If (self:cDB $ "ORACLE")
            cQuery += "	AND ROWNUM = 1 "
        EndIf

        cQuery += " AND D_E_L_E_T_ = ' ' "

    Else
        cQuery := " UPDATE " + RetSqlName('B2X') + " SET "
        cQuery += " B2X_PROCES = '" + PROCESSING + "' "
        cQuery += " , B2X_ROBOID='"+self:toString(self:getValue("processId"))+"' "
        cQuery += " , B2X_ROBOHR = '" + DToS(Date()) + " " + Time() + "' "
        cQuery += " WHERE R_E_C_N_O_ = (SELECT R_E_C_N_O_ FROM  " + RetSqlName('B2X') + " WHERE  "
        cQuery += " B2X_FILIAL = '" + xFilial( 'B2X' ) + "' "
        cQuery += " AND B2X_PROCES <> '" + PROCESSED + "' "
        cQuery += " AND B2X_ROBOID = '' "
        cQuery += " AND D_E_L_E_T_ = ' ' "
        cQuery += "	LIMIT 1 )"

    EndIf

    self:setQuery(cQuery)
    lFound := self:execStatement()

Return lFound

Method getMessage() Class CenDaoB2X

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B2X') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND B2X_PROCES = '" + PROCESSING + "' "
    cQuery += " AND B2X_ROBOID ='"+self:toString(self:getValue("processId"))+"' "

    self:setQuery(cQuery)
    lFound := self:executaQuery()
    If lFound
        B2X->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

return lFound

Method setEndProc(nRecno) Class CenDaoB2X

    Local cQuery := ""
    Local lFound := .F.

    Default nRecno := 0

    If self:cDB <> POSTGRES

        If self:cDB $ MSSQL
            cQuery := " UPDATE TOP(1) "
        Else
            cQuery := " UPDATE "

        EndIf
        cQuery += " " + RetSqlName('B2X') + " "
        cQuery += " SET "
        cQuery += " B2X_PROCES = '" + PROCESSED + "' "
        cQuery += " WHERE 1=1 "
        cQuery += " AND R_E_C_N_O_ = '" + AllTrim(Str(nRecno)) + "' "

        If (self:cDB $ "ORACLE")
            cQuery += "	AND ROWNUM = 1 "
        EndIf

    Else
        cQuery := " UPDATE " + RetSqlName('B2X') + " SET "
        cQuery += " B2X_PROCES = '" + PROCESSED + "' "
        cQuery += " WHERE R_E_C_N_O_ = (SELECT R_E_C_N_O_ FROM  " + RetSqlName('B2X') + " "
        cQuery += " WHERE 1=1 "
        cQuery += " AND R_E_C_N_O_ = '" + AllTrim(Str(nRecno)) + "' "
        cQuery += "	LIMIT 1 )"

    EndIf

    self:setQuery(cQuery)
    lFound := self:execStatement()

Return lFound

Method setExpired() Class CenDaoB2X

    Local cQuery := ""
    Local lFound := .F.

    cQuery := " UPDATE "
    cQuery += " " + RetSqlName('B2X') + " "
    cQuery += " SET "
    cQuery += " B2X_ROBOID = '' "
    cQuery += " ,B2X_PROCES = '" + PROCESSING + "' "
    cQuery += " WHERE 1=1 "
    cQuery += " AND B2X_ROBOID <> '' "
    cQuery += " AND B2X_PROCES = '" + PROCESSING + "' "
    cQuery += " AND B2X_ROBOHR <= '" + SubMinutos(Date(),Time(),2) + "' "
    cQuery += " AND B2X_ROBOHR <> ' ' "
    cQuery += " AND D_E_L_E_T_ = ' ' "

    self:setQuery(cQuery)
    lFound := self:execStatement()
Return lFound

Method GetProcess(cIdProc) Class CenDaoB2X

    Local cQuery    := ''
    Local lFound    := .F.
    Default cIdProc := ''

    cQuery := " SELECT  "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B2X') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	B2X_FILIAL = '" + xFilial("B2X") + "' "
    cQuery += " AND B2X_ROBOID = '"+ AllTrim(Str(cIdProc)) +"' "
    cQuery += " AND B2X_PROCES = '" + PROCESSED + "' "
    cQuery += " AND D_E_L_E_T_ = ' ' "

    self:setQuery(cQuery)
    lFound := self:executaQuery()
    If lFound
        B2X->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

Return lFound
