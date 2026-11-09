#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class CenDaoPesl from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    
EndClass

Method New(aFields) Class CenDaoPesl
	_Super:New(aFields)
    self:cAlias := "B8J"
    self:cfieldOrder := "B8J_CDCOMP,B8J_CODOBR,B8J_CODOPE,B8J_ANOCMP"
Return self

Method buscar() Class CenDaoPesl
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		B8J->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoPesl
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoPesl

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B8J') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	B8J_FILIAL = '" + xFilial("B8J") + "' "

    cQuery += " AND B8J_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND B8J_CODOBR = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("obligationCode")))
    cQuery += " AND B8J_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerRegister")))
    cQuery += " AND B8J_ANOCMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentYear")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method insert() Class CenDaoPesl
    Local lFound := !self:bscChaPrim()
	If lFound
        self:commit(.T.)
    EndIf
Return lFound

Method commit(lInclui) Class CenDaoPesl

    Default lInclui := .F.

	If B8J->(RecLock("B8J",lInclui))
		
        B8J->B8J_FILIAL := xFilial("B8J")
        If lInclui
        
            B8J->B8J_CDCOMP := _Super:normalizeType(B8J->B8J_CDCOMP,self:getValue("commitmentCode")) /* Column B8J_CDCOMP */
            B8J->B8J_CODOBR := _Super:normalizeType(B8J->B8J_CODOBR,self:getValue("obligationCode")) /* Column B8J_CODOBR */
            B8J->B8J_CODOPE := _Super:normalizeType(B8J->B8J_CODOPE,self:getValue("providerRegister")) /* Column B8J_CODOPE */
            B8J->B8J_ANOCMP := _Super:normalizeType(B8J->B8J_ANOCMP,self:getValue("commitmentYear")) /* Column B8J_ANOCMP */

        EndIf

        B8J->B8J_CAMAIS := _Super:normalizeType(B8J->B8J_CAMAIS,self:getValue("evCorrAssumMajorPer")) /* Column B8J_CAMAIS */
        B8J->B8J_CAULTI := _Super:normalizeType(B8J->B8J_CAULTI,self:getValue("lastDaysAssumCorrEv")) /* Column B8J_CAULTI */
        B8J->B8J_EVMAIS := _Super:normalizeType(B8J->B8J_EVMAIS,self:getValue("greaterDangerLossEvent")) /* Column B8J_EVMAIS */
        B8J->B8J_EVULTI := _Super:normalizeType(B8J->B8J_EVULTI,self:getValue("latestDaysEvents")) /* Column B8J_EVULTI */
        B8J->B8J_QTDE := _Super:normalizeType(B8J->B8J_QTDE,self:getValue("noOfBeneficiaries")) /* Column B8J_QTDE */
        B8J->B8J_REFERE := _Super:normalizeType(B8J->B8J_REFERE,self:getValue("trimester")) /* Column B8J_REFERE */
        B8J->B8J_STATUS := _Super:normalizeType(B8J->B8J_STATUS,self:getValue("status")) /* Column B8J_STATUS */

        B8J->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound
