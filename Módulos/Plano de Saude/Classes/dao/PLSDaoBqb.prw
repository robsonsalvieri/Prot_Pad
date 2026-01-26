#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class PLSDaoBqb from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()
    Method bscChaPrim()

EndClass

Method New(aFields) Class PLSDaoBqb
    _Super:New(aFields)
    self:cAlias := "BQB"
    self:cfieldOrder := "BQB_CODIGO,BQB_NUMCON,BQB_VERSAO"
Return self

Method buscar() Class PLSDaoBqb
    Local lFound := .F.
    lFound := _Super:buscar()
    If lFound
        BQB->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class PLSDaoBqb
    Local lFound := .F.
    if self:bscChaPrim()
        lFound := _Super:delete()
    EndIf
Return lFound

Method bscChaPrim() Class PLSDaoBqb

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BQB') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	BQB_FILIAL = '" + xFilial("BQB") + "' "

    cQuery += " AND BQB_CODIGO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("code"))) /* Column BQB_CODIGO */
    cQuery += " AND BQB_NUMCON = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("groupCompanyGroup"))) /* Column BQB_NUMCON */
    cQuery += " AND BQB_VERSAO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("version"))) /* Column BQB_VERSAO */

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()

return lFound

Method insert() Class PLSDaoBqb
    Local lFound := !self:bscChaPrim()
    If lFound
        self:commit(.T.)
    EndIf
Return lFound

Method commit(lInclui) Class PLSDaoBqb

    Default lInclui := .F.

    If BQB->(RecLock("BQB",lInclui))

        BQB->BQB_FILIAL := xFilial("BQB")
        If lInclui

            BQB->BQB_CODIGO := _Super:normalizeType(BQB->BQB_CODIGO,self:getValue("code"))
            BQB->BQB_NUMCON := _Super:normalizeType(BQB->BQB_NUMCON,self:getValue("groupCompanyGroup"))
            BQB->BQB_VERSAO := _Super:normalizeType(BQB->BQB_VERSAO,self:getValue("version"))

        EndIf

        BQB->BQB_DATINI := _Super:normalizeType(BQB->BQB_DATINI,self:getValue("versionInitialDate"))
        BQB->BQB_DATFIN := _Super:normalizeType(BQB->BQB_DATFIN,self:getValue("versionFinalDate"))
        BQB->BQB_CODINT := _Super:normalizeType(BQB->BQB_CODINT,self:getValue("operatorCode"))
        BQB->BQB_CDEMP := _Super:normalizeType(BQB->BQB_CDEMP,self:getValue("companyCode"))

        BQB->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound
