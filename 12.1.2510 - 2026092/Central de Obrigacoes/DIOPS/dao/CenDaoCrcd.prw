#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class CenDaoCrcd from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    
EndClass

Method New(aFields) Class CenDaoCrcd
	_Super:New(aFields)
    self:cAlias := "B36"
    self:cfieldOrder := "B36_ANOCMP,B36_CDCOMP,B36_CODIGO,B36_CODOBR,B36_CODOPE"
Return self

Method buscar() Class CenDaoCrcd
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		B36->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoCrcd
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoCrcd

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B36') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	B36_FILIAL = '" + xFilial("B36") + "' "

    cQuery += " AND B36_ANOCMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentYear")))
    cQuery += " AND B36_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND B36_CODIGO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("ansEventCode")))
    cQuery += " AND B36_CODOBR = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("obligationCode")))
    cQuery += " AND B36_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerRegister")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method insert() Class CenDaoCrcd
    Local lFound := !self:bscChaPrim()
	If lFound
        self:commit(.T.)
    EndIf
Return lFound

Method commit(lInclui) Class CenDaoCrcd

    Default lInclui := .F.

	If B36->(RecLock("B36",lInclui))
		
        B36->B36_FILIAL := xFilial("B36")
        If lInclui
        
            B36->B36_ANOCMP := _Super:normalizeType(B36->B36_ANOCMP,self:getValue("commitmentYear")) /* Column B36_ANOCMP */
            B36->B36_CDCOMP := _Super:normalizeType(B36->B36_CDCOMP,self:getValue("commitmentCode")) /* Column B36_CDCOMP */
            B36->B36_CODIGO := _Super:normalizeType(B36->B36_CODIGO,self:getValue("ansEventCode")) /* Column B36_CODIGO */
            B36->B36_CODOBR := _Super:normalizeType(B36->B36_CODOBR,self:getValue("obligationCode")) /* Column B36_CODOBR */
            B36->B36_CODOPE := _Super:normalizeType(B36->B36_CODOPE,self:getValue("providerRegister")) /* Column B36_CODOPE */

        EndIf

        B36->B36_REFERE := _Super:normalizeType(B36->B36_REFERE,self:getValue("trimester")) /* Column B36_REFERE */
        B36->B36_STATUS := _Super:normalizeType(B36->B36_STATUS,self:getValue("status")) /* Column B36_STATUS */
        B36->B36_VLMES1 := _Super:normalizeType(B36->B36_VLMES1,self:getValue("amt1StMthTrimester")) /* Column B36_VLMES1 */
        B36->B36_VLMES2 := _Super:normalizeType(B36->B36_VLMES2,self:getValue("amt2NdMthTrimester")) /* Column B36_VLMES2 */
        B36->B36_VLMES3 := _Super:normalizeType(B36->B36_VLMES3,self:getValue("amt3RdMthTrimester")) /* Column B36_VLMES3 */

        B36->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound
