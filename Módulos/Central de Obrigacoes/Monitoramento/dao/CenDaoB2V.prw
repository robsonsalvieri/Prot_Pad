#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2
#Define PROCESSING '0'
#Define PROCESSED '1'
#Define MSSQL     "MSSQL"
#Define POSTGRES  "POSTGRES"
#Define ORACLE    "ORACLE"

Class CenDaoB2V from CenDao

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

Method New(aFields) Class CenDaoB2V
    _Super:New(aFields)
    self:cAlias := "B2V"
    self:cfieldOrder := "B2V_SEQUEN,B2V_CODOPE"
Return self

Method buscar() Class CenDaoB2V
    Local lFound := .F.
    lFound := _Super:buscar()
    If lFound
        B2V->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoB2V
    Local lFound := .F.
    if self:bscChaPrim()
        lFound := _Super:delete()
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoB2V

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B2V') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	B2V_FILIAL = '" + xFilial("B2V") + "' "

    cQuery += " AND B2V_SEQUEN = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("formSequential")))
    cQuery += " AND B2V_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()

return lFound

Method commit(lInclui) Class CenDaoB2V

    Default lInclui := .F.

    If B2V->(RecLock("B2V",lInclui))

        B2V->B2V_FILIAL := xFilial("B2V")
        If lInclui

            B2V->B2V_SEQUEN := _Super:normalizeType(B2V->B2V_SEQUEN,self:getValue("formSequential")) /* Column B2V_SEQUEN */
            B2V->B2V_CODOPE := _Super:normalizeType(B2V->B2V_CODOPE,self:getValue("operatorRecord")) /* Column B2V_CODOPE */

        EndIf

        B2V->B2V_CPFCNP := _Super:normalizeType(B2V->B2V_CPFCNP,self:getValue("providerCpfCnpj")) /* Column B2V_CPFCNP */
        B2V->B2V_DTPROC := _Super:normalizeType(B2V->B2V_DTPROC,self:getValue("formProcDt")) /* Column B2V_DTPROC */
        B2V->B2V_VLTGLO := _Super:normalizeType(B2V->B2V_VLTGLO,self:getValue("totalDisallowValue")) /* Column B2V_VLTGLO */
        B2V->B2V_VLTINF := _Super:normalizeType(B2V->B2V_VLTINF,self:getValue("totalValueEntered")) /* Column B2V_VLTINF */
        B2V->B2V_VLTPAG := _Super:normalizeType(B2V->B2V_VLTPAG,self:getValue("totalValuePaid")) /* Column B2V_VLTPAG */
        B2V->B2V_EXCLU := _Super:normalizeType(B2V->B2V_EXCLU,self:getValue("exclusionId")) /* Column B2V_EXCLU */
        B2V->B2V_HORINC := _Super:normalizeType(B2V->B2V_HORINC,self:getValue("inclusionTime")) /* Column B2V_HORINC */
        B2V->B2V_IDEREC := _Super:normalizeType(B2V->B2V_IDEREC,self:getValue("identReceipt")) /* Column B2V_IDEREC */
        B2V->B2V_DATINC := _Super:normalizeType(B2V->B2V_DATINC,self:getValue("inclusionDate")) /* Column B2V_DATINC */
        B2V->B2V_PROCES := _Super:normalizeType(B2V->B2V_PROCES,self:getValue("processed")) /* Column B2V_PROCES */
        B2V->B2V_ROBOID := _Super:normalizeType(B2V->B2V_ROBOID,self:getValue("roboId")) /* Column B2V_ROBOID */

        B2V->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound

Method setProcessing() Class CenDaoB2V

    Local cQuery := ""
    Local lFound := .F.

    If self:cDB <> POSTGRES

        If self:cDB $ MSSQL
            cQuery := " UPDATE TOP(1) "
        Else
            cQuery := " UPDATE "

        EndIf

        cQuery += " " + RetSqlName('B2V') + " "
        cQuery += " SET "
        cQuery += " B2V_PROCES = '" + PROCESSING + "' "
        cQuery += " , B2V_ROBOID='"+self:toString(self:getValue("processId"))+"' "
        cQuery += " , B2V_ROBOHR = '" + DToS(Date()) + " " + Time() + "' "
        cQuery += " WHERE 1=1 "
        cQuery += " AND B2V_FILIAL = '" + xFilial( 'B2V' ) + "' "
        cQuery += " AND B2V_PROCES <> '" + PROCESSED + "' "
        cQuery += " AND B2V_ROBOID = '' "

        If (self:cDB $ "ORACLE")
            cQuery += "	AND ROWNUM = 1 "
        EndIf

        cQuery += " AND D_E_L_E_T_ = ' ' "

    Else
        cQuery := " UPDATE " + RetSqlName('B2V') + " SET "
        cQuery += " B2V_PROCES = '" + PROCESSING + "' "
        cQuery += " , B2V_ROBOID='"+self:toString(self:getValue("processId"))+"' "
        cQuery += " , B2V_ROBOHR = '" + DToS(Date()) + " " + Time() + "' "
        cQuery += " WHERE R_E_C_N_O_ = (SELECT R_E_C_N_O_ FROM  " + RetSqlName('B2V') + " WHERE  "
        cQuery += " B2V_FILIAL = '" + xFilial( 'B2V' ) + "' "
        cQuery += " AND B2V_PROCES <> '" + PROCESSED + "' "
        cQuery += " AND B2V_ROBOID = '' "
        cQuery += " AND D_E_L_E_T_ = ' ' "
        cQuery += "	LIMIT 1 )"

    EndIf

    self:setQuery(cQuery)
    lFound := self:execStatement()

Return lFound

Method getMessage() Class CenDaoB2V

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B2V') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND B2V_PROCES = '" + PROCESSING + "' "
    cQuery += " AND B2V_ROBOID ='"+self:toString(self:getValue("processId"))+"' "

    self:setQuery(cQuery)
    lFound := self:executaQuery()
    If lFound
        B2V->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

return lFound

Method setEndProc(nRecno) Class CenDaoB2V

    Local cQuery := ""
    Local lFound := .F.

    Default nRecno := 0

    If self:cDB <> POSTGRES

        If self:cDB $ MSSQL
            cQuery := " UPDATE TOP(1) "
        Else
            cQuery := " UPDATE "

        EndIf
        cQuery += " " + RetSqlName('B2V') + " "
        cQuery += " SET "
        cQuery += " B2V_PROCES = '" + PROCESSED + "' "
        cQuery += " WHERE 1=1 "
        cQuery += " AND R_E_C_N_O_ = '" + AllTrim(Str(nRecno)) + "' "

        If (self:cDB $ "ORACLE")
            cQuery += "	AND ROWNUM = 1 "
        EndIf

    Else
        cQuery := " UPDATE " + RetSqlName('B2V') + " SET "
        cQuery += " B2V_PROCES = '" + PROCESSED + "' "
        cQuery += " WHERE R_E_C_N_O_ = (SELECT R_E_C_N_O_ FROM  " + RetSqlName('B2V') + " "
        cQuery += " WHERE 1=1 "
        cQuery += " AND R_E_C_N_O_ = '" + AllTrim(Str(nRecno)) + "' "
        cQuery += "	LIMIT 1 )"

    EndIf

    self:setQuery(cQuery)
    lFound := self:execStatement()

Return lFound

Method setExpired() Class CenDaoB2V

    Local cQuery := ""
    Local lFound := .F.

    cQuery := " UPDATE "
    cQuery += " " + RetSqlName('B2V') + " "
    cQuery += " SET "
    cQuery += " B2V_ROBOID = '' "
    cQuery += " ,B2V_PROCES = '" + PROCESSING + "' "
    cQuery += " WHERE 1=1 "
    cQuery += " AND B2V_ROBOID <> '' "
    cQuery += " AND B2V_PROCES = '" + PROCESSING + "' "
    cQuery += " AND B2V_ROBOHR <= '" + SubMinutos(Date(),Time(),2) + "' "
    cQuery += " AND B2V_ROBOHR <> ' ' "
    cQuery += " AND D_E_L_E_T_ = ' ' "

    self:setQuery(cQuery)
    lFound := self:execStatement()
Return lFound

Method GetProcess(cIdProc) Class CenDaoB2V

    Local cQuery    := ''
    Local lFound    := .F.
    Default cIdProc := ''

    cQuery := " SELECT  "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B2V') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	B2V_FILIAL = '" + xFilial("B2V") + "' "
    cQuery += " AND B2V_ROBOID = '"+ AllTrim(Str(cIdProc)) +"' "
    cQuery += " AND B2V_PROCES = '" + PROCESSED + "' "
    cQuery += " AND D_E_L_E_T_ = ' ' "

    self:setQuery(cQuery)
    lFound := self:executaQuery()
    If lFound
        B2V->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

Return lFound

