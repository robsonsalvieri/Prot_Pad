#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class CenDaoTeap from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    
EndClass

Method New(aFields) Class CenDaoTeap
	_Super:New(aFields)
    self:cAlias := "B89"
    self:cfieldOrder := "B89_ANOCMP,B89_CDCOMP,B89_CODOBR,B89_CODOPE,B89_TIPPLA"
Return self

Method buscar() Class CenDaoTeap
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		B89->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoTeap
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoTeap

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B89') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	B89_FILIAL = '" + xFilial("B89") + "' "

    cQuery += " AND B89_ANOCMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentYear")))
    cQuery += " AND B89_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND B89_CODOBR = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("obligationCode")))
    cQuery += " AND B89_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerRegister")))
    cQuery += " AND B89_TIPPLA = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("planType")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method insert() Class CenDaoTeap
    Local lFound := !self:bscChaPrim()
	If lFound
        self:commit(.T.)
    EndIf
Return lFound

Method commit(lInclui) Class CenDaoTeap

    Default lInclui := .F.

	If B89->(RecLock("B89",lInclui))
		
        B89->B89_FILIAL := xFilial("B89")
        If lInclui
        
            B89->B89_ANOCMP := _Super:normalizeType(B89->B89_ANOCMP,self:getValue("commitmentYear")) /* Column B89_ANOCMP */
            B89->B89_CDCOMP := _Super:normalizeType(B89->B89_CDCOMP,self:getValue("commitmentCode")) /* Column B89_CDCOMP */
            B89->B89_CODOBR := _Super:normalizeType(B89->B89_CODOBR,self:getValue("obligationCode")) /* Column B89_CODOBR */
            B89->B89_CODOPE := _Super:normalizeType(B89->B89_CODOPE,self:getValue("providerRegister")) /* Column B89_CODOPE */
            B89->B89_TIPPLA := _Super:normalizeType(B89->B89_TIPPLA,self:getValue("planType")) /* Column B89_TIPPLA */

        EndIf

        B89->B89_TXCANC := _Super:normalizeType(B89->B89_TXCANC,self:getValue("contractCancelRate")) /* Column B89_TXCANC */
        B89->B89_AJUTAB := _Super:normalizeType(B89->B89_AJUTAB,self:getValue("biomTabAdjustment")) /* Column B89_AJUTAB */
        B89->B89_ESTFLX := _Super:normalizeType(B89->B89_ESTFLX,self:getValue("cashFlowAdjEstimation")) /* Column B89_ESTFLX */
        B89->B89_FAIETA := _Super:normalizeType(B89->B89_FAIETA,self:getValue("utiOfRangesRn632003")) /* Column B89_FAIETA */
        B89->B89_INFMED := _Super:normalizeType(B89->B89_INFMED,self:getValue("estimatedMedicalInflati")) /* Column B89_INFMED */
        B89->B89_METINT := _Super:normalizeType(B89->B89_METINT,self:getValue("ettjInterMethod")) /* Column B89_METINT */
        B89->B89_REACUS := _Super:normalizeType(B89->B89_REACUS,self:getValue("averageAdjustmentPerVa")) /* Column B89_REACUS */
        B89->B89_REAMAX := _Super:normalizeType(B89->B89_REAMAX,self:getValue("estimatedMaximumAdjustm")) /* Column B89_REAMAX */
        B89->B89_REFERE := _Super:normalizeType(B89->B89_REFERE,self:getValue("trimester")) /* Column B89_REFERE */
        B89->B89_STATUS := _Super:normalizeType(B89->B89_STATUS,self:getValue("status")) /* Column B89_STATUS */

        B89->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound
