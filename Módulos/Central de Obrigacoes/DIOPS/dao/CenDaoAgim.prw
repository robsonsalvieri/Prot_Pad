#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class CenDaoAgim from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    
EndClass

Method New(aFields) Class CenDaoAgim
	_Super:New(aFields)
    self:cAlias := "B8C"
    self:cfieldOrder := "B8C_CDCOMP,B8C_CODOBR,B8C_CODOPE,B8C_CODRGI,B8C_ANOCMP"
Return self

Method buscar() Class CenDaoAgim
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		B8C->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoAgim
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoAgim

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B8C') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	B8C_FILIAL = '" + xFilial("B8C") + "' "

    cQuery += " AND B8C_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND B8C_CODOBR = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("obligationCode")))
    cQuery += " AND B8C_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerRegister")))
    cQuery += " AND B8C_CODRGI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("realEstateGeneralRegis")))
    cQuery += " AND B8C_ANOCMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentYear")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method insert() Class CenDaoAgim
    Local lFound := !self:bscChaPrim()
	If lFound
        self:commit(.T.)
    EndIf
Return lFound

Method commit(lInclui) Class CenDaoAgim

    Default lInclui := .F.

	If B8C->(RecLock("B8C",lInclui))
		
        B8C->B8C_FILIAL := xFilial("B8C")
        If lInclui
        
            B8C->B8C_CDCOMP := _Super:normalizeType(B8C->B8C_CDCOMP,self:getValue("commitmentCode")) /* Column B8C_CDCOMP */
            B8C->B8C_CODOBR := _Super:normalizeType(B8C->B8C_CODOBR,self:getValue("obligationCode")) /* Column B8C_CODOBR */
            B8C->B8C_CODOPE := _Super:normalizeType(B8C->B8C_CODOPE,self:getValue("providerRegister")) /* Column B8C_CODOPE */
            B8C->B8C_CODRGI := _Super:normalizeType(B8C->B8C_CODRGI,self:getValue("realEstateGeneralRegis")) /* Column B8C_CODRGI */
            B8C->B8C_ANOCMP := _Super:normalizeType(B8C->B8C_ANOCMP,self:getValue("commitmentYear")) /* Column B8C_ANOCMP */

        EndIf

        B8C->B8C_ASSIST := _Super:normalizeType(B8C->B8C_ASSIST,self:getValue("assitance")) /* Column B8C_ASSIST */
        B8C->B8C_REDPRO := _Super:normalizeType(B8C->B8C_REDPRO,self:getValue("ownNetwork")) /* Column B8C_REDPRO */
        B8C->B8C_REFERE := _Super:normalizeType(B8C->B8C_REFERE,self:getValue("trimester")) /* Column B8C_REFERE */
        B8C->B8C_STATUS := _Super:normalizeType(B8C->B8C_STATUS,self:getValue("status")) /* Column B8C_STATUS */
        B8C->B8C_VIGFIN := _Super:normalizeType(B8C->B8C_VIGFIN,self:getValue("validityEndDate")) /* Column B8C_VIGFIN */
        B8C->B8C_VIGINI := _Super:normalizeType(B8C->B8C_VIGINI,self:getValue("validityStartDate")) /* Column B8C_VIGINI */
        B8C->B8C_VLRCON := _Super:normalizeType(B8C->B8C_VLRCON,self:getValue("accountingValue")) /* Column B8C_VLRCON */

        B8C->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound
