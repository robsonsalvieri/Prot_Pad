#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class CenDaoB2U from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()
    Method bscChaPrim()
    Method setNumRecibo()
    Method bscReqRet()
    Method atuStaArq(oCenCltB2U)
    Method verNumDup(oCenCltB2U)
EndClass

Method New(aFields) Class CenDaoB2U
    _Super:New(aFields)
    self:cAlias := "B2U"
    self:cfieldOrder := "B2U_CODOPE,B2U_CODOBR,B2U_ANOCMP,B2U_CDCOMP,B2U_REFERE,B2U_ANOCAL"
Return self

Method buscar() Class CenDaoB2U
    Local lFound := .F.
    lFound := _Super:buscar()
    If lFound
        B2U->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoB2U
    Local lFound := .F.
    if self:bscChaPrim()
        lFound := _Super:delete()
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoB2U

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B2U') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	B2U_FILIAL = '" + xFilial("B2U") + "' "

    cQuery += " AND B2U_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("healthInsurerCode")))
    cQuery += " AND B2U_CODOBR = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND B2U_ANOCMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentYear")))
    cQuery += " AND B2U_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND B2U_REFERE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("reference")))
    cQuery += " AND B2U_ANOCAL = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("calendarYear")))
    cQuery += " AND B2U_NOMARQ = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("fileName")))
    cQuery += " AND B2U_STATUS = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("status")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()

return lFound

Method insert() Class CenDaoB2U
    Local lFound := !self:bscChaPrim()
    self:commit(lFound)
Return lFound

Method commit(lInclui) Class CenDaoB2U

    Default lInclui := .F.

    If B2U->(RecLock("B2U",lInclui))

        B2U->B2U_FILIAL := xFilial("B2U")
        If lInclui

            B2U->B2U_CODOPE := _Super:normalizeType(B2U->B2U_CODOPE,self:getValue("healthInsurerCode")) /* Column B2U_CODOPE */
            B2U->B2U_CODOBR := _Super:normalizeType(B2U->B2U_CODOBR,self:getValue("requirementCode")) /* Column B2U_CODOBR */
            B2U->B2U_ANOCMP := _Super:normalizeType(B2U->B2U_ANOCMP,self:getValue("commitmentYear")) /* Column B2U_ANOCMP */
            B2U->B2U_CDCOMP := _Super:normalizeType(B2U->B2U_CDCOMP,self:getValue("commitmentCode")) /* Column B2U_CDCOMP */
            B2U->B2U_REFERE := _Super:normalizeType(B2U->B2U_REFERE,self:getValue("reference")) /* Column B2U_REFERE */
            B2U->B2U_ANOCAL := _Super:normalizeType(B2U->B2U_ANOCAL,self:getValue("calendarYear")) /* Column B2U_ANOCAL */

        EndIf

        B2U->B2U_RECRET := _Super:normalizeType(B2U->B2U_RECRET,self:getValue("correctedReceiptNumber")) /* Column B2U_RECRET */
        B2U->B2U_NUMREC := _Super:normalizeType(B2U->B2U_NUMREC,self:getValue("receiptNumber")) /* Column B2U_NUMREC */
        B2U->B2U_DATARQ := _Super:normalizeType(B2U->B2U_DATARQ,self:getValue("fileDate")) /* Column B2U_DATARQ */
        B2U->B2U_HORARQ := _Super:normalizeType(B2U->B2U_HORARQ,self:getValue("fileTime")) /* Column B2U_HORARQ */
        B2U->B2U_NOMARQ := _Super:normalizeType(B2U->B2U_NOMARQ,self:getValue("fileName")) /* Column B2U_NOMARQ */
        B2U->B2U_STATUS := _Super:normalizeType(B2U->B2U_STATUS,self:getValue("status")) /* Column B2U_STATUS */
        B2U->B2U_USRDEL := _Super:normalizeType(B2U->B2U_STATUS,self:getValue("userDeleted")) /* Column B2U_USRDEL */
        B2U->B2U_DTHDEL := _Super:normalizeType(B2U->B2U_STATUS,self:getValue("timeDeleted")) /* Column B2U_DTHDEL */

        B2U->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound

Method setNumRecibo() Class CenDaoB2U

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " UPDATE "
    cQuery += " " + RetSqlName('B2U') + " "
    cQuery += " SET "
    cQuery += " B2U_STATUS='"+self:toString(self:getValue("status"))+"' "
    cQuery += " , "
    cQuery += " B2U_NUMREC='"+self:toString(self:getValue("receiptNumber"))+"' "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	B2U_FILIAL = '" + xFilial("B2U") + "' "

    cQuery += " AND B2U_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("healthInsurerCode")))
    cQuery += " AND B2U_CODOBR = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND B2U_ANOCMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentYear")))
    cQuery += " AND B2U_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND B2U_REFERE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("reference")))
    cQuery += " AND B2U_ANOCAL = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("calendarYear")))
    cQuery += " AND B2U_STATUS <> '3' AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')

    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:execStatement()

return lFound

Method bscReqRet() Class CenDaoB2U

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B2U') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	B2U_FILIAL = '" + xFilial("B2U") + "' "

    cQuery += " AND B2U_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("healthInsurerCode")))
    cQuery += " AND B2U_CODOBR = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND B2U_ANOCMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentYear")))
    cQuery += " AND B2U_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND B2U_REFERE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("reference")))
    cQuery += " AND B2U_ANOCAL = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("calendarYear")))
    cQuery += " AND B2U_STATUS = '2' "
    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')

    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()
    If lFound
        B2U->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

return lFound


Method atuStaArq(oCenCltB2U) Class CenDaoB2U

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " UPDATE "
    cQuery += " " + RetSqlName('B2U') + " "
    cQuery += " SET "
    cQuery += " B2U_STATUS='2' "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	B2U_FILIAL = '" + xFilial("B2U") + "' "
    cQuery += " AND B2U_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("healthInsurerCode")))
    cQuery += " AND B2U_CODOBR = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND B2U_ANOCMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentYear")))
    cQuery += " AND B2U_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND B2U_REFERE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("reference")))
    cQuery += " AND B2U_ANOCAL = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("calendarYear")))
    cQuery += " AND B2U_NUMREC = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("correctedReceiptNumber")))
    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')

    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:execStatement()

return lFound

Method verNumDup(oCenCltB2U) Class CenDaoB2U

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B2U') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	B2U_FILIAL = '" + xFilial("B2U") + "' "

    cQuery += " AND B2U_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("healthInsurerCode")))
    cQuery += " AND B2U_CODOBR = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND B2U_ANOCMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentYear")))
    cQuery += " AND B2U_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND B2U_REFERE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("reference")))
    cQuery += " AND B2U_ANOCAL = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("calendarYear")))
    cQuery += " AND B2U_NUMREC = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("receiptNumber")))
    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')

    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()

return lFound