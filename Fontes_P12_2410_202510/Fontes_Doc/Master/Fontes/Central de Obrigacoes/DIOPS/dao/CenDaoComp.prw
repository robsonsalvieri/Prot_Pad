#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class CenDaoComp from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()
    Method bscChaPrim()
    Method podeImpDiops()
    Method bscCmpMonAtiv()
    Method bscCmpDmAtiv()

EndClass

Method New(aFields) Class CenDaoComp
    _Super:New(aFields)
    self:cAlias := "B3D"
    self:cfieldOrder := "B3D_CDOBRI,B3D_CODIGO,B3D_CODOPE,B3D_ANO,B3D_TIPOBR"
Return self

Method buscar() Class CenDaoComp
    Local lFound := .F.
    lFound := _Super:buscar()
    If lFound
        B3D->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoComp
    Local lFound := .F.
    if self:bscChaPrim()
        lFound := _Super:delete()
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoComp

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B3D') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	B3D_FILIAL = '" + xFilial("B3D") + "' "

    cQuery += " AND B3D_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND B3D_CODIGO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND B3D_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND B3D_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND B3D_TIPOBR = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("obligationType")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()

return lFound

Method insert() Class CenDaoComp
    Local lFound := !self:bscChaPrim()
    If lFound
        self:commit(.T.)
    EndIf
Return lFound

Method commit(lInclui) Class CenDaoComp

    Default lInclui := .F.

    If B3D->(RecLock("B3D",lInclui))

        B3D->B3D_FILIAL := xFilial("B3D")
        If lInclui

            B3D->B3D_CDOBRI := _Super:normalizeType(B3D->B3D_CDOBRI,self:getValue("requirementCode")) /* Column B3D_CDOBRI */
            B3D->B3D_CODIGO := _Super:normalizeType(B3D->B3D_CODIGO,self:getValue("commitmentCode")) /* Column B3D_CODIGO */
            B3D->B3D_CODOPE := _Super:normalizeType(B3D->B3D_CODOPE,self:getValue("operatorRecord")) /* Column B3D_CODOPE */
            B3D->B3D_ANO := _Super:normalizeType(B3D->B3D_ANO,self:getValue("referenceYear")) /* Column B3D_ANO */
            B3D->B3D_TIPOBR := _Super:normalizeType(B3D->B3D_TIPOBR,self:getValue("obligationType")) /* Column B3D_TIPOBR */

        EndIf

        B3D->B3D_VCTO := _Super:normalizeType(B3D->B3D_VCTO,self:getValue("commitmentDueDate")) /* Column B3D_VCTO */
        B3D->B3D_AVVCTO := _Super:normalizeType(B3D->B3D_AVVCTO,self:getValue("dueDateNotification")) /* Column B3D_AVVCTO */
        B3D->B3D_REFERE := _Super:normalizeType(B3D->B3D_REFERE,self:getValue("trimester")) /* Column B3D_REFERE */
        B3D->B3D_SNTBEN := _Super:normalizeType(B3D->B3D_SNTBEN,self:getValue("synthetizesBenefit")) /* Column B3D_SNTBEN */
        B3D->B3D_STATUS := _Super:normalizeType(B3D->B3D_STATUS,self:getValue("status")) /* Column B3D_STATUS */

        B3D->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound

Method podeImpDiops() Class CenDaoComp

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B3D') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	B3D_FILIAL = '" + xFilial("B3D") + "' "

    cQuery += " AND B3D_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND B3D_CODIGO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND B3D_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND B3D_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND B3D_TIPOBR = '3' "
    cQuery += " AND B3D_STATUS IN ('4','6') "
    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')

    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()

return !lFound

Method bscCmpMonAtiv() Class CenDaoComp

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B3D') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	B3D_FILIAL = '" + xFilial("B3D") + "' "

    If !Empty(self:getValue("requirementCode"))
        cQuery += " AND B3D_CDOBRI = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    EndIf
    If !Empty(self:getValue("commitmentCode"))
        cQuery += " AND B3D_CODIGO = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    EndIf
    If !Empty(self:getValue("operatorRecord"))
        cQuery += " AND B3D_CODOPE = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    EndIf
    If !Empty(self:getValue("referenceYear"))
        cQuery += " AND B3D_ANO = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    EndIf
    cQuery += " AND B3D_TIPOBR = '5' "
    cQuery += " AND B3D_STATUS <> '6' "

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')

    cQuery += " ORDER BY B3D_CODIGO "

    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()

return lFound

Method bscCmpDmAtiv() Class CenDaoComp

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B3D') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	B3D_FILIAL = '" + xFilial("B3D") + "' "

    If !Empty(self:getValue("requirementCode"))
        cQuery += " AND B3D_CDOBRI = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    EndIf
    If !Empty(self:getValue("commitmentCode"))
        cQuery += " AND B3D_CODIGO = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    EndIf
    If !Empty(self:getValue("operatorRecord"))
        cQuery += " AND B3D_CODOPE = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    EndIf
    If !Empty(self:getValue("referenceYear"))
        cQuery += " AND B3D_ANO = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    EndIf
    cQuery += " AND B3D_TIPOBR = '4' "
    cQuery += " AND B3D_STATUS <> '6' "

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')

    cQuery += " ORDER BY B3D_CODIGO "

    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()

return lFound