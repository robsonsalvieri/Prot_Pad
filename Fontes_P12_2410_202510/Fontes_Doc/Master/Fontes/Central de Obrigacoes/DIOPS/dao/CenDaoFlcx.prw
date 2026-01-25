#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class CenDaoFlcx from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    
EndClass

Method New(aFields) Class CenDaoFlcx
	_Super:New(aFields)
    self:cAlias := "B8H"
    self:cfieldOrder := "B8H_ANOCMP,B8H_CDCOMP,B8H_CODIGO,B8H_CODOBR,B8H_CODOPE,B8H_STATUS"
Return self

Method buscar() Class CenDaoFlcx
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		B8H->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoFlcx
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoFlcx

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B8H') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	B8H_FILIAL = '" + xFilial("B8H") + "' "

    cQuery += " AND B8H_ANOCMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentYear")))
    cQuery += " AND B8H_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND B8H_CODIGO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("cashFlowCode")))
    cQuery += " AND B8H_CODOBR = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("obligationCode")))
    cQuery += " AND B8H_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerRegister")))
    cQuery += " AND B8H_STATUS = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("status")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method insert() Class CenDaoFlcx
    Local lFound := !self:bscChaPrim()
	If lFound
        self:commit(.T.)
    EndIf
Return lFound

Method commit(lInclui) Class CenDaoFlcx

    Default lInclui := .F.

	If B8H->(RecLock("B8H",lInclui))
		
        B8H->B8H_FILIAL := xFilial("B8H")
        If lInclui
        
            B8H->B8H_ANOCMP := _Super:normalizeType(B8H->B8H_ANOCMP,self:getValue("commitmentYear")) /* Column B8H_ANOCMP */
            B8H->B8H_CDCOMP := _Super:normalizeType(B8H->B8H_CDCOMP,self:getValue("commitmentCode")) /* Column B8H_CDCOMP */
            B8H->B8H_CODIGO := _Super:normalizeType(B8H->B8H_CODIGO,self:getValue("cashFlowCode")) /* Column B8H_CODIGO */
            B8H->B8H_CODOBR := _Super:normalizeType(B8H->B8H_CODOBR,self:getValue("obligationCode")) /* Column B8H_CODOBR */
            B8H->B8H_CODOPE := _Super:normalizeType(B8H->B8H_CODOPE,self:getValue("providerRegister")) /* Column B8H_CODOPE */
            B8H->B8H_STATUS := _Super:normalizeType(B8H->B8H_STATUS,self:getValue("status")) /* Column B8H_STATUS */

        EndIf

        B8H->B8H_VLRCON := _Super:normalizeType(B8H->B8H_VLRCON,self:getValue("value")) /* Column B8H_VLRCON */
        B8H->B8H_REFERE := _Super:normalizeType(B8H->B8H_REFERE,self:getValue("trimester")) /* Column B8H_REFERE */

        B8H->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound
