#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class CenDaoSaid from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    
EndClass

Method New(aFields) Class CenDaoSaid
	_Super:New(aFields)
    self:cAlias := "B8F"
    self:cfieldOrder := "B8F_CDCOMP,B8F_CODOBR,B8F_CODOPE,B8F_ANOCMP,B8F_VENCTO"
Return self

Method buscar() Class CenDaoSaid
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		B8F->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoSaid
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoSaid

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B8F') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	B8F_FILIAL = '" + xFilial("B8F") + "' "

    cQuery += " AND B8F_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND B8F_CODOBR = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("obligationCode")))
    cQuery += " AND B8F_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerRegister")))
    cQuery += " AND B8F_ANOCMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentYear")))
    cQuery += " AND B8F_VENCTO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("financialDueDate")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method insert() Class CenDaoSaid
    Local lFound := !self:bscChaPrim()
	If lFound
        self:commit(.T.)
    EndIf
Return lFound

Method commit(lInclui) Class CenDaoSaid

    Default lInclui := .F.

	If B8F->(RecLock("B8F",lInclui))
		
        B8F->B8F_FILIAL := xFilial("B8F")
        If lInclui
        
            B8F->B8F_CDCOMP := _Super:normalizeType(B8F->B8F_CDCOMP,self:getValue("commitmentCode")) /* Column B8F_CDCOMP */
            B8F->B8F_CODOBR := _Super:normalizeType(B8F->B8F_CODOBR,self:getValue("obligationCode")) /* Column B8F_CODOBR */
            B8F->B8F_CODOPE := _Super:normalizeType(B8F->B8F_CODOPE,self:getValue("providerRegister")) /* Column B8F_CODOPE */
            B8F->B8F_ANOCMP := _Super:normalizeType(B8F->B8F_ANOCMP,self:getValue("commitmentYear")) /* Column B8F_ANOCMP */
            B8F->B8F_VENCTO := _Super:normalizeType(B8F->B8F_VENCTO,self:getValue("financialDueDate")) /* Column B8F_VENCTO */

        EndIf

        B8F->B8F_AQUCAR := _Super:normalizeType(B8F->B8F_AQUCAR,self:getValue("debWPortfAcquis")) /* Column B8F_AQUCAR */
        B8F->B8F_COMERC := _Super:normalizeType(B8F->B8F_COMERC,self:getValue("mktOnOperations")) /* Column B8F_COMERC */
        B8F->B8F_DEBOPE := _Super:normalizeType(B8F->B8F_DEBOPE,self:getValue("debitsWithOperators")) /* Column B8F_DEBOPE */
        B8F->B8F_DEPBEN := _Super:normalizeType(B8F->B8F_DEPBEN,self:getValue("benefDepContrapIns")) /* Column B8F_DEPBEN */
        B8F->B8F_EVENTO := _Super:normalizeType(B8F->B8F_EVENTO,self:getValue("eventClaimNetPres")) /* Column B8F_EVENTO */
        B8F->B8F_EVESUS := _Super:normalizeType(B8F->B8F_EVESUS,self:getValue("eventClaimNetSus")) /* Column B8F_EVESUS */
        B8F->B8F_OUDBOP := _Super:normalizeType(B8F->B8F_OUDBOP,self:getValue("otherDebOprWPlan")) /* Column B8F_OUDBOP */
        B8F->B8F_OUDBPG := _Super:normalizeType(B8F->B8F_OUDBPG,self:getValue("otherDebitsToPay")) /* Column B8F_OUDBPG */
        B8F->B8F_REFERE := _Super:normalizeType(B8F->B8F_REFERE,self:getValue("trimester")) /* Column B8F_REFERE */
        B8F->B8F_SERASS := _Super:normalizeType(B8F->B8F_SERASS,self:getValue("hthCareServProv")) /* Column B8F_SERASS */
        B8F->B8F_STATUS := _Super:normalizeType(B8F->B8F_STATUS,self:getValue("status")) /* Column B8F_STATUS */
        B8F->B8F_TITSEN := _Super:normalizeType(B8F->B8F_TITSEN,self:getValue("billsChargesCollect")) /* Column B8F_TITSEN */

        B8F->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound
