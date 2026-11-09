#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class CenDaoLcpr from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    
EndClass

Method New(aFields) Class CenDaoLcpr
	_Super:New(aFields)
    self:cAlias := "B8E"
    self:cfieldOrder := "B8E_ANOCMP,B8E_CDCOMP,B8E_CODOBR,B8E_CODOPE,B8E_CONTA"
Return self

Method buscar() Class CenDaoLcpr
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		B8E->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoLcpr
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoLcpr

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B8E') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	B8E_FILIAL = '" + xFilial("B8E") + "' "

    cQuery += " AND B8E_ANOCMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentYear")))
    cQuery += " AND B8E_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND B8E_CODOBR = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("obligationCode")))
    cQuery += " AND B8E_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerRegister")))
    cQuery += " AND B8E_CONTA = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("accountCode")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method insert() Class CenDaoLcpr
    Local lFound := !self:bscChaPrim()
	If lFound
        self:commit(.T.)
    EndIf
Return lFound

Method commit(lInclui) Class CenDaoLcpr

    Default lInclui := .F.

	If B8E->(RecLock("B8E",lInclui))
		
        B8E->B8E_FILIAL := xFilial("B8E")
        If lInclui
        
            B8E->B8E_ANOCMP := _Super:normalizeType(B8E->B8E_ANOCMP,self:getValue("commitmentYear")) /* Column B8E_ANOCMP */
            B8E->B8E_CDCOMP := _Super:normalizeType(B8E->B8E_CDCOMP,self:getValue("commitmentCode")) /* Column B8E_CDCOMP */
            B8E->B8E_CODOBR := _Super:normalizeType(B8E->B8E_CODOBR,self:getValue("obligationCode")) /* Column B8E_CODOBR */
            B8E->B8E_CODOPE := _Super:normalizeType(B8E->B8E_CODOPE,self:getValue("providerRegister")) /* Column B8E_CODOPE */
            B8E->B8E_CONTA := _Super:normalizeType(B8E->B8E_CONTA,self:getValue("accountCode")) /* Column B8E_CONTA */

        EndIf

        B8E->B8E_DESCRI := _Super:normalizeType(B8E->B8E_DESCRI,self:getValue("description")) /* Column B8E_DESCRI */
        B8E->B8E_REFERE := _Super:normalizeType(B8E->B8E_REFERE,self:getValue("trimester")) /* Column B8E_REFERE */
        B8E->B8E_STATUS := _Super:normalizeType(B8E->B8E_STATUS,self:getValue("status")) /* Column B8E_STATUS */
        B8E->B8E_VLRCON := _Super:normalizeType(B8E->B8E_VLRCON,self:getValue("accountingValue")) /* Column B8E_VLRCON */

        B8E->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound
