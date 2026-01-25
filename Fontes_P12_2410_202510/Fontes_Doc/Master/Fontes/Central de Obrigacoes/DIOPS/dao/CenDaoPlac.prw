#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class CenDaoPlac from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    
EndClass

Method New(aFields) Class CenDaoPlac
	_Super:New(aFields)
    self:cAlias := "B8B"
    self:cfieldOrder := "B8B_CODOPE,B8B_CONTA,B8B_VIGFIN,B8B_VIGINI"
Return self

Method buscar() Class CenDaoPlac
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		B8B->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoPlac
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoPlac

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B8B') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	B8B_FILIAL = '" + xFilial("B8B") + "' "

    cQuery += " AND B8B_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerRegister")))
    cQuery += " AND B8B_CONTA = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("accountCode")))
    cQuery += " AND B8B_VIGFIN = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("validityEndDate")))
    cQuery += " AND B8B_VIGINI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("validityStartDate")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method insert() Class CenDaoPlac
    Local lFound := !self:bscChaPrim()
	If lFound
        self:commit(.T.)
    EndIf
Return lFound

Method commit(lInclui) Class CenDaoPlac

    Default lInclui := .F.

	If B8B->(RecLock("B8B",lInclui))
		
        B8B->B8B_FILIAL := xFilial("B8B")
        If lInclui
        
            B8B->B8B_CODOPE := _Super:normalizeType(B8B->B8B_CODOPE,self:getValue("providerRegister")) /* Column B8B_CODOPE */
            B8B->B8B_CONTA := _Super:normalizeType(B8B->B8B_CONTA,self:getValue("accountCode")) /* Column B8B_CONTA */
            B8B->B8B_VIGFIN := _Super:normalizeType(B8B->B8B_VIGFIN,self:getValue("validityEndDate")) /* Column B8B_VIGFIN */
            B8B->B8B_VIGINI := _Super:normalizeType(B8B->B8B_VIGINI,self:getValue("validityStartDate")) /* Column B8B_VIGINI */

        EndIf

        B8B->B8B_DESCRI := _Super:normalizeType(B8B->B8B_DESCRI,self:getValue("accountDescription")) /* Column B8B_DESCRI */

        B8B->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound
