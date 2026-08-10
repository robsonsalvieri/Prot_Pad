#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

#Define ATIVO "1"


Class CenDaoB6N from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()
    Method bscChaPrim()
	Method getRespByCodOpe(cCodOpe,cCpf)
    Method applySearch(cSearch)

EndClass

Method New(aFields) Class CenDaoB6N
    _Super:New(aFields)
    self:cAlias := "B6N"
    self:cfieldOrder := "B6N_CODOPE,B6N_CPFRES"
Return self

Method buscar() Class CenDaoB6N
    Local lFound := .F.
    lFound := _Super:buscar()
    If lFound
        B6N->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoB6N
    Local lFound := .F.
    if self:bscChaPrim()
        lFound := _Super:delete()
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoB6N

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B6N') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	B6N_FILIAL = '" + xFilial("B6N") + "' "

    cQuery += " AND B6N_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("healthInsurerCode")))
    cQuery += " AND B6N_CPFRES = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("ssn")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()

return lFound

Method applySearch(cSearch) Class CenDaoB6N

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B6N') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	B6N_FILIAL = '" + xFilial("B6N") + "' "

    cQuery += " AND ( 1=2 "
    cQuery += " OR B6N_CODOPE LIKE '%" + cSearch + "%' "
    cQuery += " OR B6N_CPFRES LIKE '%" + cSearch + "%' "
    cQuery += " OR B6N_NOMRES LIKE '%" + cSearch + "%' "
    cQuery += " OR B6N_NOMRES LIKE '%" + Upper(cSearch) + "%' "
    cQuery += " OR B6N_NOMRES LIKE '%" + Lower(cSearch) + "%' "
    cQuery += " ) "

    cQuery += " AND D_E_L_E_T_ = ' ' "
    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()

return lFound

Method insert() Class CenDaoB6N
    Local lFound := !self:bscChaPrim()
    If lFound
        self:commit(.T.)
    EndIf
Return lFound

Method commit(lInclui) Class CenDaoB6N

    Default lInclui := .F.

    If B6N->(RecLock("B6N",lInclui))

        B6N->B6N_FILIAL := xFilial("B6N")
        If lInclui

            B6N->B6N_CODOPE := _Super:normalizeType(B6N->B6N_CODOPE,self:getValue("healthInsurerCode")) /* Column B6N_CODOPE */
            B6N->B6N_CPFRES := _Super:normalizeType(B6N->B6N_CPFRES,self:getValue("ssn")) /* Column B6N_CPFRES */

        EndIf

        B6N->B6N_NOMRES := _Super:normalizeType(B6N->B6N_NOMRES,self:getValue("name")) /* Column B6N_NOMRES */
        B6N->B6N_DDDRES := _Super:normalizeType(B6N->B6N_DDDRES,self:getValue("areaCode")) /* Column B6N_DDDRES */
        B6N->B6N_TELRES := _Super:normalizeType(B6N->B6N_TELRES,self:getValue("phoneNumber")) /* Column B6N_TELRES */
        B6N->B6N_RAMALR := _Super:normalizeType(B6N->B6N_RAMALR,self:getValue("extensionLine")) /* Column B6N_RAMALR */
        B6N->B6N_FAXRES := _Super:normalizeType(B6N->B6N_FAXRES,self:getValue("fax")) /* Column B6N_FAXRES */
        B6N->B6N_EMAILR := _Super:normalizeType(B6N->B6N_EMAILR,self:getValue("eMail")) /* Column B6N_EMAILR */
        B6N->B6N_ATIVO  := _Super:normalizeType(B6N->B6N_ATIVO ,self:getValue("active")) /* Column B6N_ATIVO  */

        B6N->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound

Method getRespByCodOpe(cCodOpe,cCpf) Class CenDaoB6N

    Local lFound := .F.
    Local cQuery := ""
    Default cCpf   := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B6N') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND B6N_CODOPE ='"+ cCodOpe +"' "
    cQuery += " AND B6N_CPFRES ='"+ cCpf +"' "
    cQuery += " AND B6N_ATIVO ='"+ ATIVO +"' "
    cQuery += " AND D_E_L_E_T_ = ' ' "

    self:setQuery(cQuery)
    lFound := self:executaQuery()
    If lFound
        B6N->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

return lFound