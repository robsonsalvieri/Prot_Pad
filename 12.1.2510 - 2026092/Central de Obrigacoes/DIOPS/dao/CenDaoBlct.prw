#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class CenDaoBlct from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    
EndClass

Method New(aFields) Class CenDaoBlct
	_Super:New(aFields)
    self:cAlias := "B8A"
    self:cfieldOrder := "B8A_ANOCMP,B8A_CDCOMP,B8A_CODOBR,B8A_CODOPE,B8A_CONTA"
Return self

Method buscar() Class CenDaoBlct
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		B8A->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoBlct
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoBlct

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B8A') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	B8A_FILIAL = '" + xFilial("B8A") + "' "

    cQuery += " AND B8A_ANOCMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentYear")))
    cQuery += " AND B8A_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND B8A_CODOBR = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("obligationCode")))
    cQuery += " AND B8A_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerRegister")))
    cQuery += " AND B8A_CONTA = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("accountCode")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method insert() Class CenDaoBlct
    Local lFound := !self:bscChaPrim()
	If lFound
        self:commit(.T.)
    EndIf
Return lFound

Method commit(lInclui) Class CenDaoBlct

    Default lInclui := .F.

	If B8A->(RecLock("B8A",lInclui))
		
        B8A->B8A_FILIAL := xFilial("B8A")
        If lInclui
        
            B8A->B8A_ANOCMP := _Super:normalizeType(B8A->B8A_ANOCMP,self:getValue("commitmentYear")) /* Column B8A_ANOCMP */
            B8A->B8A_CDCOMP := _Super:normalizeType(B8A->B8A_CDCOMP,self:getValue("commitmentCode")) /* Column B8A_CDCOMP */
            B8A->B8A_CODOBR := _Super:normalizeType(B8A->B8A_CODOBR,self:getValue("obligationCode")) /* Column B8A_CODOBR */
            B8A->B8A_CODOPE := _Super:normalizeType(B8A->B8A_CODOPE,self:getValue("providerRegister")) /* Column B8A_CODOPE */
            B8A->B8A_CONTA := _Super:normalizeType(B8A->B8A_CONTA,self:getValue("accountCode")) /* Column B8A_CONTA */

        EndIf

        B8A->B8A_CREDIT := _Super:normalizeType(B8A->B8A_CREDIT,self:getValue("credits")) /* Column B8A_CREDIT */
        B8A->B8A_DEBITO := _Super:normalizeType(B8A->B8A_DEBITO,self:getValue("debits")) /* Column B8A_DEBITO */
        B8A->B8A_REFERE := _Super:normalizeType(B8A->B8A_REFERE,self:getValue("trimester")) /* Column B8A_REFERE */
        B8A->B8A_SALANT := _Super:normalizeType(B8A->B8A_SALANT,self:getValue("previousBalance")) /* Column B8A_SALANT */
        B8A->B8A_SALFIN := _Super:normalizeType(B8A->B8A_SALFIN,self:getValue("finalBalance")) /* Column B8A_SALFIN */
        B8A->B8A_STATUS := _Super:normalizeType(B8A->B8A_STATUS,self:getValue("status")) /* Column B8A_STATUS */

        B8A->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound
