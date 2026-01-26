#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class CenDaoPact from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()
    Method bscChaPrim()
    Method bscSequen()

EndClass

Method New(aFields) Class CenDaoPact
    _Super:New(aFields)
    self:cAlias := "BUY"
    self:cfieldOrder := "BUY_CDCOMP,BUY_CODOBR,BUY_CODOPE,BUY_CONTA,BUY_ANOCMP"
Return self

Method buscar() Class CenDaoPact
    Local lFound := .F.
    lFound := _Super:buscar()
    If lFound
        BUY->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoPact
    Local lFound := .F.
    if self:bscChaPrim()
        lFound := _Super:delete()
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoPact

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BUY') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	BUY_FILIAL = '" + xFilial("BUY") + "' "

    cQuery += " AND BUY_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND BUY_CODOBR = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("obligationCode")))
    cQuery += " AND BUY_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerRegister")))
    cQuery += " AND BUY_CONTA = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("accountCode")))
    cQuery += " AND BUY_ANOCMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentYear")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()

return lFound

Method insert() Class CenDaoPact
    // Sempre que receber um post ele grava um BUY_SEQUEN auto geravél,
    // marcelo está avaliando se eu posso ter a mesma conta dentro do mesmo trimestre.
    //Local lFound := !self:bscChaPrim()
    Local lFound := .T.
    If lFound
        self:commit(.T.)
    EndIf
Return lFound

Method bscSequen() Class CenDaoPact

    Local nSequen := ""
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += " MAX(BUY_SEQUEN) AS MAIOR "
    cQuery += " FROM " + RetSqlName("BUY") "
    cQuery += " WHERE BUY_FILIAL = '" + xFilial("BUY") + "' "

    cQuery += " AND BUY_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerRegister")))
    cQuery += " AND BUY_CODOBR = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("obligationCode")))
    cQuery += " AND BUY_ANOCMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentYear")))
    cQuery += " AND BUY_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery +=" AND BUY_CONTA = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("accountCode")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,self:getQuery()),"TRBBUYAPI",.F.,.T.)

    If !TRBBUYAPI->(Eof())

        cRet := TRBBUYAPI->MAIOR
        If !Empty(cRet)
            nSequen := Soma1(cRet)
        Else
            nSequen := "000001"
        EndIf

        TRBBUYAPI->(dbCloseArea())
    Else
        nSequen := "000001"
    EndIf


Return nSequen

Method commit(lInclui) Class CenDaoPact

    Default lInclui := .F.

    If BUY->(RecLock("BUY",lInclui))

        BUY->BUY_FILIAL := xFilial("BUY")
        If lInclui

            BUY->BUY_CDCOMP := _Super:normalizeType(BUY->BUY_CDCOMP,self:getValue("commitmentCode")) /* Column BUY_CDCOMP */
            BUY->BUY_CODOBR := _Super:normalizeType(BUY->BUY_CODOBR,self:getValue("obligationCode")) /* Column BUY_CODOBR */
            BUY->BUY_CODOPE := _Super:normalizeType(BUY->BUY_CODOPE,self:getValue("providerRegister")) /* Column BUY_CODOPE */
            BUY->BUY_CONTA := _Super:normalizeType(BUY->BUY_CONTA,self:getValue("accountCode")) /* Column BUY_CONTA */
            BUY->BUY_ANOCMP := _Super:normalizeType(BUY->BUY_ANOCMP,self:getValue("commitmentYear")) /* Column BUY_ANOCMP */
            BUY->BUY_SEQUEN := _Super:normalizeType(BUY->BUY_SEQUEN,self:bscSequen()) /* Column BUY_SEQUEN */

        EndIf

        BUY->BUY_ATUMON := _Super:normalizeType(BUY->BUY_ATUMON,self:getValue("monetaryUpdate")) /* Column BUY_ATUMON */
        BUY->BUY_DTCOMP := _Super:normalizeType(BUY->BUY_DTCOMP,self:getValue("competenceDate")) /* Column BUY_DTCOMP */
        BUY->BUY_REFERE := _Super:normalizeType(BUY->BUY_REFERE,self:getValue("trimester")) /* Column BUY_REFERE */
        BUY->BUY_SLDFIN := _Super:normalizeType(BUY->BUY_SLDFIN,self:getValue("balanceAtTheEndOfThe")) /* Column BUY_SLDFIN */
        BUY->BUY_STATUS := _Super:normalizeType(BUY->BUY_STATUS,self:getValue("status")) /* Column BUY_STATUS */
        BUY->BUY_VLRINI := _Super:normalizeType(BUY->BUY_VLRINI,self:getValue("initialValue")) /* Column BUY_VLRINI */
        BUY->BUY_VLRPAG := _Super:normalizeType(BUY->BUY_VLRPAG,self:getValue("valuePaid")) /* Column BUY_VLRPAG */

        BUY->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound
