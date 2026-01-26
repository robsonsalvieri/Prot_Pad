#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class CenDaoB2R from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    
EndClass

Method New(aFields) Class CenDaoB2R
	_Super:New(aFields)
    self:cAlias := "B2R"
    self:cfieldOrder := "B2R_CODTAB,B2R_CDTERM"
Return self

Method buscar() Class CenDaoB2R
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		B2R->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoB2R
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoB2R

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B2R') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	B2R_FILIAL = '" + xFilial("B2R") + "' "

    cQuery += " AND B2R_CODTAB = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("tableCode")))
    cQuery += " AND B2R_CDTERM = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("termCode")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method insert() Class CenDaoB2R
    Local lFound := !self:bscChaPrim()
	If lFound
        self:commit(.T.)
    EndIf
Return lFound

Method commit(lInclui) Class CenDaoB2R

    Default lInclui := .F.

	If B2R->(RecLock("B2R",lInclui))
		
        B2R->B2R_FILIAL := xFilial("B2R")
        If lInclui
        
            B2R->B2R_CODTAB := _Super:normalizeType(B2R->B2R_CODTAB,self:getValue("tableCode")) /* Column B2R_CODTAB */
            B2R->B2R_CDTERM := _Super:normalizeType(B2R->B2R_CDTERM,self:getValue("termCode")) /* Column B2R_CDTERM */

        EndIf

        B2R->B2R_DESTER := _Super:normalizeType(B2R->B2R_DESTER,self:getValue("termDescription")) /* Column B2R_DESTER */
        B2R->B2R_VIGDE  := _Super:normalizeType(B2R->B2R_VIGDE ,self:getValue("validityFrom")) /* Column B2R_VIGDE  */
        B2R->B2R_VIGATE := _Super:normalizeType(B2R->B2R_VIGATE,self:getValue("validityTo")) /* Column B2R_VIGATE */
        B2R->B2R_DATFIM := _Super:normalizeType(B2R->B2R_DATFIM,self:getValue("deploymentEndDate")) /* Column B2R_DATFIM */
        B2R->B2R_DSCDET := _Super:normalizeType(B2R->B2R_DSCDET,self:getValue("detailedDescription")) /* Column B2R_DSCDET */
        B2R->B2R_TABTUS := _Super:normalizeType(B2R->B2R_TABTUS,self:getValue("tussTerminology")) /* Column B2R_TABTUS */
        B2R->B2R_CODGRU := _Super:normalizeType(B2R->B2R_CODGRU,self:getValue("groupCode")) /* Column B2R_CODGRU */
        B2R->B2R_DESGRU := _Super:normalizeType(B2R->B2R_DESGRU,self:getValue("groupDescription")) /* Column B2R_DESGRU */
        B2R->B2R_HASVIN := _Super:normalizeType(B2R->B2R_HASVIN,self:getValue("hasLinkFromTo")) /* Column B2R_HASVIN */

        B2R->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound
