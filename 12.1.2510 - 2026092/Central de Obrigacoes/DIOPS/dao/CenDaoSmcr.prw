#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class CenDaoSmcr from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    
EndClass

Method New(aFields) Class CenDaoSmcr
	_Super:New(aFields)
    self:cAlias := "BVS"
    self:cfieldOrder := "BVS_ANOCMP,BVS_CDCOMP,BVS_CODIGO,BVS_CODOBR,BVS_CODOPE"
Return self

Method buscar() Class CenDaoSmcr
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		BVS->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoSmcr
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoSmcr

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BVS') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	BVS_FILIAL = '" + xFilial("BVS") + "' "

    cQuery += " AND BVS_ANOCMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentYear")))
    cQuery += " AND BVS_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND BVS_CODIGO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("benefitAdmOperCode")))
    cQuery += " AND BVS_CODOBR = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("obligationCode")))
    cQuery += " AND BVS_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerRegister")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method insert() Class CenDaoSmcr
    Local lFound := !self:bscChaPrim()
	If lFound
        self:commit(.T.)
    EndIf
Return lFound

Method commit(lInclui) Class CenDaoSmcr

    Default lInclui := .F.

	If BVS->(RecLock("BVS",lInclui))
		
        BVS->BVS_FILIAL := xFilial("BVS")
        If lInclui
        
            BVS->BVS_ANOCMP := _Super:normalizeType(BVS->BVS_ANOCMP,self:getValue("commitmentYear")) /* Column BVS_ANOCMP */
            BVS->BVS_CDCOMP := _Super:normalizeType(BVS->BVS_CDCOMP,self:getValue("commitmentCode")) /* Column BVS_CDCOMP */
            BVS->BVS_CODIGO := _Super:normalizeType(BVS->BVS_CODIGO,self:getValue("benefitAdmOperCode")) /* Column BVS_CODIGO */
            BVS->BVS_CODOBR := _Super:normalizeType(BVS->BVS_CODOBR,self:getValue("obligationCode")) /* Column BVS_CODOBR */
            BVS->BVS_CODOPE := _Super:normalizeType(BVS->BVS_CODOPE,self:getValue("providerRegister")) /* Column BVS_CODOPE */

        EndIf

        BVS->BVS_REFERE := _Super:normalizeType(BVS->BVS_REFERE,self:getValue("trimester")) /* Column BVS_REFERE */
        BVS->BVS_STATUS := _Super:normalizeType(BVS->BVS_STATUS,self:getValue("status")) /* Column BVS_STATUS */
        BVS->BVS_VLMES1 := _Super:normalizeType(BVS->BVS_VLMES1,self:getValue("amt1StMthTrimester")) /* Column BVS_VLMES1 */
        BVS->BVS_VLMES2 := _Super:normalizeType(BVS->BVS_VLMES2,self:getValue("amt2NdMthTrimester")) /* Column BVS_VLMES2 */
        BVS->BVS_VLMES3 := _Super:normalizeType(BVS->BVS_VLMES3,self:getValue("amt3RdMthTrimester")) /* Column BVS_VLMES3 */

        BVS->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound
