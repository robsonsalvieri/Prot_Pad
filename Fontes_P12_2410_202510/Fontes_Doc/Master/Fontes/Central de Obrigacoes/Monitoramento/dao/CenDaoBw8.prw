#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2
#Define PROCESSING '0'
#Define PROCESSED '1'
#Define MSSQL     "MSSQL"
#Define POSTGRES  "POSTGRES"
#Define ORACLE    "ORACLE"

Class CenDaoBw8 from CenDao

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

Method New(aFields) Class CenDaoBw8
    _Super:New(aFields)
    self:cAlias := "BW8"
    self:cfieldOrder := "BW8_CODOPE,BW8_SEQGUI"
Return self

Method buscar() Class CenDaoBw8
    Local lFound := .F.
    lFound := _Super:buscar()
    If lFound
        BW8->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoBw8
    Local lFound := .F.
    if self:bscChaPrim()
        lFound := _Super:delete()
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoBw8

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BW8') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	BW8_FILIAL = '" + xFilial("BW8") + "' "

    cQuery += " AND BW8_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BW8_SEQGUI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("formSequential")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()

return lFound

Method commit(lInclui) Class CenDaoBw8

    Default lInclui := .F.

    If BW8->(RecLock("BW8",lInclui))

        BW8->BW8_FILIAL := xFilial("BW8")
        If lInclui

            BW8->BW8_CODOPE := _Super:normalizeType(BW8->BW8_CODOPE,self:getValue("operatorRecord")) /* Column BW8_CODOPE */
            BW8->BW8_SEQGUI := _Super:normalizeType(BW8->BW8_SEQGUI,self:getValue("formSequential")) /* Column BW8_SEQGUI */

        EndIf

        BW8->BW8_DTPRGU := _Super:normalizeType(BW8->BW8_DTPRGU,self:getValue("formProcDt")) /* Column BW8_DTPRGU */
        BW8->BW8_MATRIC := _Super:normalizeType(BW8->BW8_MATRIC,self:getValue("registration")) /* Column BW8_MATRIC */
        BW8->BW8_NMGPRE := _Super:normalizeType(BW8->BW8_NMGPRE,self:getValue("providerFormNumber")) /* Column BW8_NMGPRE */
        BW8->BW8_PROCES := _Super:normalizeType(BW8->BW8_PROCES,self:getValue("processed")) /* Column BW8_PROCES */
        BW8->BW8_DATINC := _Super:normalizeType(BW8->BW8_DATINC,self:getValue("inclusionDate")) /* Column BW8_DATINC */
        BW8->BW8_HORINC := _Super:normalizeType(BW8->BW8_HORINC,self:getValue("inclusionTime")) /* Column BW8_HORINC */
        BW8->BW8_EXCLU := _Super:normalizeType(BW8->BW8_EXCLU,self:getValue("exclusionId")) /* Column BW8_EXCLU */
        BW8->BW8_ROBOID := _Super:normalizeType(BW8->BW8_ROBOID,self:getValue("roboId")) /* Column BW8_ROBOID */

        BW8->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound

Method setProcessing() Class CenDaoBw8

    Local cQuery := ""
    Local lFound := .F.

    If self:cDB <> POSTGRES

        If self:cDB $ MSSQL
            cQuery := " UPDATE TOP(1) "
        Else
            cQuery := " UPDATE "

        EndIf

        cQuery += " " + RetSqlName('BW8') + " "
        cQuery += " SET "
        cQuery += " BW8_PROCES = '" + PROCESSING + "' "
        cQuery += " , BW8_ROBOID='"+self:toString(self:getValue("processId"))+"' "
        cQuery += " , BW8_ROBOHR = '" + DToS(Date()) + " " + Time() + "' "
        cQuery += " WHERE 1=1 "
        cQuery += " AND BW8_FILIAL = '" + xFilial( 'BW8' ) + "' "
        cQuery += " AND BW8_PROCES <> '" + PROCESSED + "' "
        cQuery += " AND BW8_ROBOID = '' "

        If (self:cDB $ "ORACLE")
            cQuery += "	AND ROWNUM = 1 "
        EndIf

        cQuery += " AND D_E_L_E_T_ = ' ' "

    Else
        cQuery := " UPDATE " + RetSqlName('BW8') + " SET "
        cQuery += " BW8_PROCES = '" + PROCESSING + "' "
        cQuery += " , BW8_ROBOID='"+self:toString(self:getValue("processId"))+"' "
        cQuery += " , BW8_ROBOHR = '" + DToS(Date()) + " " + Time() + "' "
        cQuery += " WHERE R_E_C_N_O_ = (SELECT R_E_C_N_O_ FROM  " + RetSqlName('BW8') + " WHERE  "
        cQuery += " BW8_FILIAL = '" + xFilial( 'BW8' ) + "' "
        cQuery += " AND BW8_PROCES <> '" + PROCESSED + "' "
        cQuery += " AND BW8_ROBOID = '' "
        cQuery += " AND D_E_L_E_T_ = ' ' "
        cQuery += "	LIMIT 1 )"

    EndIf

    self:setQuery(cQuery)
    lFound := self:execStatement()

Return lFound

Method getMessage() Class CenDaoBw8

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BW8') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND BW8_PROCES = '" + PROCESSING + "' "
    cQuery += " AND BW8_ROBOID ='"+self:toString(self:getValue("processId"))+"' "

    self:setQuery(cQuery)
    lFound := self:executaQuery()
    If lFound
        BW8->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

return lFound

Method setEndProc(nRecno) Class CenDaoBw8

    Local cQuery := ""
    Local lFound := .F.

    Default nRecno := 0

    If self:cDB <> POSTGRES

        If self:cDB $ MSSQL
            cQuery := " UPDATE TOP(1) "
        Else
            cQuery := " UPDATE "

        EndIf
        cQuery += " " + RetSqlName('BW8') + " "
        cQuery += " SET "
        cQuery += " BW8_PROCES = '" + PROCESSED + "' "
        cQuery += " WHERE 1=1 "
        cQuery += " AND R_E_C_N_O_ = '" + AllTrim(Str(nRecno)) + "' "

        If (self:cDB $ "ORACLE")
            cQuery += "	AND ROWNUM = 1 "
        EndIf

    Else
        cQuery := " UPDATE " + RetSqlName('BW8') + " SET "
        cQuery += " BW8_PROCES = '" + PROCESSED + "' "
        cQuery += " WHERE R_E_C_N_O_ = (SELECT R_E_C_N_O_ FROM  " + RetSqlName('BW8') + " "
        cQuery += " WHERE 1=1 "
        cQuery += " AND R_E_C_N_O_ = '" + AllTrim(Str(nRecno)) + "' "
        cQuery += "	LIMIT 1 )"

    EndIf

    self:setQuery(cQuery)
    lFound := self:execStatement()

Return lFound

Method setExpired() Class CenDaoBw8

    Local cQuery := ""
    Local lFound := .F.

    cQuery := " UPDATE "
    cQuery += " " + RetSqlName('BW8') + " "
    cQuery += " SET "
    cQuery += " BW8_ROBOID = '' "
    cQuery += " ,BW8_PROCES = '" + PROCESSING + "' "
    cQuery += " WHERE 1=1 "
    cQuery += " AND BW8_ROBOID <> '' "
    cQuery += " AND BW8_PROCES = '" + PROCESSING + "' "
    cQuery += " AND BW8_ROBOHR <= '" + SubMinutos(Date(),Time(),2) + "' "
    cQuery += " AND BW8_ROBOHR <> ' ' "
    cQuery += " AND D_E_L_E_T_ = ' ' "

    self:setQuery(cQuery)
    lFound := self:execStatement()
Return lFound

Method GetProcess(cIdProc) Class CenDaoBw8

    Local cQuery    := ''
    Local lFound    := .F.
    Default cIdProc := ''

    cQuery := " SELECT  "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BW8') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	BW8_FILIAL = '" + xFilial("BW8") + "' "
    cQuery += " AND BW8_ROBOID = '"+ AllTrim(Str(cIdProc)) +"' "
    cQuery += " AND BW8_PROCES = '" + PROCESSED + "' "
    cQuery += " AND D_E_L_E_T_ = ' ' "

    self:setQuery(cQuery)
    lFound := self:executaQuery()
    If lFound
        BW8->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

Return lFound
