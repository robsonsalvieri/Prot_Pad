#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class CenDaoEvin from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    
EndClass

Method New(aFields) Class CenDaoEvin
	_Super:New(aFields)
    self:cAlias := "B8L"
    self:cfieldOrder := "B8L_ANOCMP,B8L_CDCOMP,B8L_CODIGO,B8L_CODOBR,B8L_CODOPE"
Return self

Method buscar() Class CenDaoEvin
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		B8L->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoEvin
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoEvin

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B8L') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	B8L_FILIAL = '" + xFilial("B8L") + "' "

    cQuery += " AND B8L_ANOCMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentYear")))
    cQuery += " AND B8L_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND B8L_CODIGO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("eventCodeAns")))
    cQuery += " AND B8L_CODOBR = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("obligationCode")))
    cQuery += " AND B8L_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerRegister")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method insert() Class CenDaoEvin
    Local lFound := !self:bscChaPrim()
	If lFound
        self:commit(.T.)
    EndIf
Return lFound

Method commit(lInclui) Class CenDaoEvin

    Default lInclui := .F.

	If B8L->(RecLock("B8L",lInclui))
		
        B8L->B8L_FILIAL := xFilial("B8L")
        If lInclui
        
            B8L->B8L_ANOCMP := _Super:normalizeType(B8L->B8L_ANOCMP,self:getValue("commitmentYear")) /* Column B8L_ANOCMP */
            B8L->B8L_CDCOMP := _Super:normalizeType(B8L->B8L_CDCOMP,self:getValue("commitmentCode")) /* Column B8L_CDCOMP */
            B8L->B8L_CODIGO := _Super:normalizeType(B8L->B8L_CODIGO,self:getValue("eventCodeAns")) /* Column B8L_CODIGO */
            B8L->B8L_CODOBR := _Super:normalizeType(B8L->B8L_CODOBR,self:getValue("obligationCode")) /* Column B8L_CODOBR */
            B8L->B8L_CODOPE := _Super:normalizeType(B8L->B8L_CODOPE,self:getValue("providerRegister")) /* Column B8L_CODOPE */

        EndIf

        B8L->B8L_REFERE := _Super:normalizeType(B8L->B8L_REFERE,self:getValue("trimester")) /* Column B8L_REFERE */
        B8L->B8L_STATUS := _Super:normalizeType(B8L->B8L_STATUS,self:getValue("status")) /* Column B8L_STATUS */
        B8L->B8L_VLMES1 := _Super:normalizeType(B8L->B8L_VLMES1,self:getValue("quarterMthFirstValue")) /* Column B8L_VLMES1 */
        B8L->B8L_VLMES2 := _Super:normalizeType(B8L->B8L_VLMES2,self:getValue("quarterMthSecValue")) /* Column B8L_VLMES2 */
        B8L->B8L_VLMES3 := _Super:normalizeType(B8L->B8L_VLMES3,self:getValue("quarterMthThirdValue")) /* Column B8L_VLMES3 */

        B8L->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound
