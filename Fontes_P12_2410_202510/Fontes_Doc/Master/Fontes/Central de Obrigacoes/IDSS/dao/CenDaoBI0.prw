#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

#DEFINE DIOPS	 	"3"
#DEFINE MONIT	 	"5"

Class CenDaoBI0 from CenDao
    Data nContasDio     As Numeric
    Data oContDiops     As Object
    Data cAliasAux      As String

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()
    Method bscChaPrim()
    Method applySearch(cSearch)
    Method getVlrRzTISS(cCampoRet)
    Method hasNextQuery(cTipoObrig)
    Method getWhereMonit()
    Method getWhereDiops()
    Method getContasDiops()

EndClass

Method New(aFields) Class CenDaoBI0
    _Super:New(aFields)
    self:cAlias         := "BI0"
    self:cfieldOrder    := "BI0_CODOPE,BI0_ANO"
    self:cAliasAux      := ""
    self:nContasDio     := 1
    self:oContDiops     := nil
Return self

Method buscar() Class CenDaoBI0
    Local lFound := .F.
    lFound := _Super:buscar()
    If lFound
        BI0->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoBI0
    Local lFound := .F.
    if self:bscChaPrim()
        lFound := _Super:delete()
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoBI0

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BI0') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	BI0_FILIAL = '" + xFilial("BI0") + "' "

    cQuery += " AND BI0_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("healthInsurerCode")))
    cQuery += " AND BI0_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()

return lFound

Method applySearch(cSearch) Class CenDaoBI0

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BI0') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	BI0_FILIAL = '" + xFilial("BI0") + "' "

    cQuery += " AND ( 1=2 "
    cQuery += " OR BI0_CODOPE LIKE '%" + cSearch + "%'"
    cQuery += " OR BI0_ANO LIKE '%" + cSearch + "%'"

    cQuery += " ) "
    cQuery += " AND D_E_L_E_T_ = ' ' "
    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()

return lFound

Method insert() Class CenDaoBI0
    Local lFound := !self:bscChaPrim()
    If lFound
        self:commit(.T.)
    Else
        self:commit(.F.)
    EndIf
Return lFound

Method commit(lInclui) Class CenDaoBI0

    Default lInclui := .F.

    If BI0->(RecLock("BI0",lInclui))

        BI0->BI0_FILIAL := xFilial("BI0")
        If lInclui

            BI0->BI0_CODOPE := _Super:normalizeType(BI0->BI0_CODOPE ,self:getValue("healthInsurerCode"))
            BI0->BI0_ANO    := _Super:normalizeType(BI0->BI0_ANO    ,self:getValue("referenceYear"))

        EndIf

        BI0->BI0_NUMRZT := _Super:normalizeType(BI0->BI0_NUMRZT,self:getValue("numeratorTissRatio"))
        BI0->BI0_DENRZT := _Super:normalizeType(BI0->BI0_DENRZT,self:getValue("denominatorTissRatio"))
        BI0->BI0_PRCRZT := _Super:normalizeType(BI0->BI0_PRCRZT,self:getValue("partialTissRatio"))
        BI0->BI0_TOTRZT := _Super:normalizeType(BI0->BI0_TOTRZT,self:getValue("totalTissRatio"))

        BI0->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound

Method hasNextQuery(cTipoObrig) Class CenDaoBI0
    Local lRet          := .F.
    Default cTipoObrig  := ''
    If cTipoObrig == DIOPS
        lRet := self:oContDiops:Get(self:nContasDio)
    EndIf
Return lRet

Method getVlrRzTISS(cCampoRet, cTipoObrig, oContDiops) Class CenDaoBI0
    Local nTotal        := 0
    Local cQuery        := ''
    Local lFirst        := .T.  //Para sempre executar a query pelo menos uma vez.
    Default cCampoRet   := ''
    Default cTipoObrig  := ''
    Default oContDiops  := nil

    self:oContDiops     := oContDiops

    While self:hasNextQuery(cTipoObrig) .OR. lFirst

        cQuery := " SELECT SUM(" + cCampoRet + ")  TOTAL "
        cQuery += " FROM " + RetSqlName(Self:cAliasAux) + " "
        cQuery += " WHERE 1=1 "
        cQuery += " AND	" + Self:cAliasAux + "_FILIAL = '" + xFilial(Self:cAliasAux) + "' "

        Do Case
            Case cTipoObrig == MONIT
                cQuery += self:getWhereMonit()
            Case cTipoObrig == DIOPS
                cQuery += self:getWhereDiops()
        EndCase

        cQuery += " AND D_E_L_E_T_ = ? "
        aAdd(self:aMapBuilder, ' ')
        self:setQuery(self:queryBuilder(cQuery))
        If self:executaQuery()
            nTotal += (self:getAliasTemp())->TOTAL
        EndIf
        self:fechaQuery()
        lFirst      := .F.
    EndDo

Return nTotal

Method getWhereMonit() Class CenDaoBI0
    Local cWhere    := ''

    cWhere += " AND " + Self:cAliasAux + "_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("healthInsurerCode")))
    cWhere += " AND " + Self:cAliasAux + "_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
Return cWhere

Method getWhereDiops() Class CenDaoBI0
    Local cWhere    := ''

    cWhere += " AND " + Self:cAliasAux + "_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("healthInsurerCode")))
    cWhere += " AND " + Self:cAliasAux + "_ANOCMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cWhere += " AND " + Self:cAliasAux + "_CONTA IN(" + self:getContasDiops() + ")"

Return cWhere

Method getContasDiops() Class CenDaoBI0
    Local cContasDio    := ''
    Local cContaRet     := ''
    Local nLimitWhere   := 1

    While self:oContDiops:Get(self:nContasDio, @cContaRet) .AND. nLimitWhere <= 20
        if nLimitWhere != 1
            cContasDio += ","
        EndIf
        cContasDio += "'" + cContaRet + "'"
        self:nContasDio++
        nLimitWhere++
    EndDo

Return cContasDio