#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class CenDaoCoes from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    
EndClass

Method New(aFields) Class CenDaoCoes
	_Super:New(aFields)
    self:cAlias := "BUP"
    self:cfieldOrder := "BUP_ANOCMP,BUP_CDCOMP,BUP_CODOBR,BUP_CODOPE,BUP_OPECOE,BUP_REFERE"
Return self

Method buscar() Class CenDaoCoes
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		BUP->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoCoes
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoCoes

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BUP') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	BUP_FILIAL = '" + xFilial("BUP") + "' "

    cQuery += " AND BUP_ANOCMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentYear")))
    cQuery += " AND BUP_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND BUP_CODOBR = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("obligationCode")))
    cQuery += " AND BUP_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerRegister")))
    cQuery += " AND BUP_OPECOE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecordInAns")))
    cQuery += " AND BUP_REFERE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("trimester")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method insert() Class CenDaoCoes
    Local lFound := !self:bscChaPrim()
	If lFound
        self:commit(.T.)
    EndIf
Return lFound

Method commit(lInclui) Class CenDaoCoes

    Default lInclui := .F.

	If BUP->(RecLock("BUP",lInclui))
		
        BUP->BUP_FILIAL := xFilial("BUP")
        If lInclui
        
            BUP->BUP_ANOCMP := _Super:normalizeType(BUP->BUP_ANOCMP,self:getValue("commitmentYear")) /* Column BUP_ANOCMP */
            BUP->BUP_CDCOMP := _Super:normalizeType(BUP->BUP_CDCOMP,self:getValue("commitmentCode")) /* Column BUP_CDCOMP */
            BUP->BUP_CODOBR := _Super:normalizeType(BUP->BUP_CODOBR,self:getValue("obligationCode")) /* Column BUP_CODOBR */
            BUP->BUP_CODOPE := _Super:normalizeType(BUP->BUP_CODOPE,self:getValue("providerRegister")) /* Column BUP_CODOPE */
            BUP->BUP_OPECOE := _Super:normalizeType(BUP->BUP_OPECOE,self:getValue("operatorRecordInAns")) /* Column BUP_OPECOE */
            BUP->BUP_REFERE := _Super:normalizeType(BUP->BUP_REFERE,self:getValue("trimester")) /* Column BUP_REFERE */

        EndIf

        BUP->BUP_STATUS := _Super:normalizeType(BUP->BUP_STATUS,self:getValue("status")) /* Column BUP_STATUS */
        BUP->BUP_VLRFAT := _Super:normalizeType(BUP->BUP_VLRFAT,self:getValue("billingValue")) /* Column BUP_VLRFAT */

        BUP->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound
