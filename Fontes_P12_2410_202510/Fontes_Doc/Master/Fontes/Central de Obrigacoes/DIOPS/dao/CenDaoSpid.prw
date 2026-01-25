#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class CenDaoSpid from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    
EndClass

Method New(aFields) Class CenDaoSpid
	_Super:New(aFields)
    self:cAlias := "B8G"
    self:cfieldOrder := "B8G_ANOCMP,B8G_CDCOMP,B8G_CODOBR,B8G_CODOPE,B8G_VENCTO"
Return self

Method buscar() Class CenDaoSpid
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		B8G->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoSpid
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoSpid

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B8G') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	B8G_FILIAL = '" + xFilial("B8G") + "' "

    cQuery += " AND B8G_ANOCMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentYear")))
    cQuery += " AND B8G_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND B8G_CODOBR = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("obligationCode")))
    cQuery += " AND B8G_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerRegister")))
    cQuery += " AND B8G_VENCTO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("financialDueDate")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method insert() Class CenDaoSpid
    Local lFound := !self:bscChaPrim()
	If lFound
        self:commit(.T.)
    EndIf
Return lFound

Method commit(lInclui) Class CenDaoSpid

    Default lInclui := .F.

	If B8G->(RecLock("B8G",lInclui))
		
        B8G->B8G_FILIAL := xFilial("B8G")
        If lInclui
        
            B8G->B8G_ANOCMP := _Super:normalizeType(B8G->B8G_ANOCMP,self:getValue("commitmentYear")) /* Column B8G_ANOCMP */
            B8G->B8G_CDCOMP := _Super:normalizeType(B8G->B8G_CDCOMP,self:getValue("commitmentCode")) /* Column B8G_CDCOMP */
            B8G->B8G_CODOBR := _Super:normalizeType(B8G->B8G_CODOBR,self:getValue("obligationCode")) /* Column B8G_CODOBR */
            B8G->B8G_CODOPE := _Super:normalizeType(B8G->B8G_CODOPE,self:getValue("providerRegister")) /* Column B8G_CODOPE */
            B8G->B8G_VENCTO := _Super:normalizeType(B8G->B8G_VENCTO,self:getValue("financialDueDate")) /* Column B8G_VENCTO */

        EndIf

        B8G->B8G_COLPOS := _Super:normalizeType(B8G->B8G_COLPOS,self:getValue("collectiveFloating")) /* Column B8G_COLPOS */
        B8G->B8G_COLPRE := _Super:normalizeType(B8G->B8G_COLPRE,self:getValue("collectiveFixed")) /* Column B8G_COLPRE */
        B8G->B8G_CREADM := _Super:normalizeType(B8G->B8G_CREADM,self:getValue("beneficiariesOperationC")) /* Column B8G_CREADM */
        B8G->B8G_CROPPO := _Super:normalizeType(B8G->B8G_CROPPO,self:getValue("postPaymentOperCredit")) /* Column B8G_CROPPO */
        B8G->B8G_INDPOS := _Super:normalizeType(B8G->B8G_INDPOS,self:getValue("individualFloating")) /* Column B8G_INDPOS */
        B8G->B8G_INDPRE := _Super:normalizeType(B8G->B8G_INDPRE,self:getValue("individualFixed")) /* Column B8G_INDPRE */
        B8G->B8G_OUCROP := _Super:normalizeType(B8G->B8G_OUCROP,self:getValue("prePaymentOperatorsCre")) /* Column B8G_OUCROP */
        B8G->B8G_OUCRPL := _Super:normalizeType(B8G->B8G_OUCRPL,self:getValue("otherCreditsWithPlan")) /* Column B8G_OUCRPL */
        B8G->B8G_OUTCRE := _Super:normalizeType(B8G->B8G_OUTCRE,self:getValue("otherCredNotRelatPlan")) /* Column B8G_OUTCRE */
        B8G->B8G_PARBEN := _Super:normalizeType(B8G->B8G_PARBEN,self:getValue("partBenefInEveClaim")) /* Column B8G_PARBEN */
        B8G->B8G_REFERE := _Super:normalizeType(B8G->B8G_REFERE,self:getValue("trimester")) /* Column B8G_REFERE */
        B8G->B8G_STATUS := _Super:normalizeType(B8G->B8G_STATUS,self:getValue("status")) /* Column B8G_STATUS */

        B8G->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound
