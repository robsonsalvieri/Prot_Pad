#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class CenDaoCoas from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    
EndClass

Method New(aFields) Class CenDaoCoas
	_Super:New(aFields)
    self:cAlias := "B8I"
    self:cfieldOrder := "B8I_ANOCMP,B8I_CDCOMP,B8I_CODOBR,B8I_CODOPE,B8I_PLANO,B8I_ORIGEM"
Return self

Method buscar() Class CenDaoCoas
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		B8I->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoCoas
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoCoas

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B8I') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	B8I_FILIAL = '" + xFilial("B8I") + "' "

    cQuery += " AND B8I_ANOCMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentYear")))
    cQuery += " AND B8I_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND B8I_CODOBR = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("obligationCode")))
    cQuery += " AND B8I_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerRegister")))
    cQuery += " AND B8I_PLANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("typeOfPlan")))
    cQuery += " AND B8I_ORIGEM = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("paymentOrigin")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method insert() Class CenDaoCoas
    Local lFound := !self:bscChaPrim()
	If lFound
        self:commit(.T.)
    EndIf
Return lFound

Method commit(lInclui) Class CenDaoCoas

    Default lInclui := .F.

	If B8I->(RecLock("B8I",lInclui))
		
        B8I->B8I_FILIAL := xFilial("B8I")
        If lInclui
        
            B8I->B8I_ANOCMP := _Super:normalizeType(B8I->B8I_ANOCMP,self:getValue("commitmentYear")) /* Column B8I_ANOCMP */
            B8I->B8I_CDCOMP := _Super:normalizeType(B8I->B8I_CDCOMP,self:getValue("commitmentCode")) /* Column B8I_CDCOMP */
            B8I->B8I_CODOBR := _Super:normalizeType(B8I->B8I_CODOBR,self:getValue("obligationCode")) /* Column B8I_CODOBR */
            B8I->B8I_CODOPE := _Super:normalizeType(B8I->B8I_CODOPE,self:getValue("providerRegister")) /* Column B8I_CODOPE */
            B8I->B8I_PLANO := _Super:normalizeType(B8I->B8I_PLANO,self:getValue("typeOfPlan")) /* Column B8I_PLANO */
            B8I->B8I_ORIGEM := _Super:normalizeType(B8I->B8I_ORIGEM,self:getValue("paymentOrigin")) /* Column B8I_ORIGEM */

        EndIf

        B8I->B8I_OUTROS := _Super:normalizeType(B8I->B8I_OUTROS,self:getValue("otherPayments")) /* Column B8I_OUTROS */
        B8I->B8I_REFERE := _Super:normalizeType(B8I->B8I_REFERE,self:getValue("trimester")) /* Column B8I_REFERE */
        B8I->B8I_STATUS := _Super:normalizeType(B8I->B8I_STATUS,self:getValue("status")) /* Column B8I_STATUS */
        B8I->B8I_TERAPI := _Super:normalizeType(B8I->B8I_TERAPI,self:getValue("therapies")) /* Column B8I_TERAPI */
        B8I->B8I_CONSUL := _Super:normalizeType(B8I->B8I_CONSUL,self:getValue("medicalAppointment")) /* Column B8I_CONSUL */
        B8I->B8I_DEMAIS := _Super:normalizeType(B8I->B8I_DEMAIS,self:getValue("otherExpenses")) /* Column B8I_DEMAIS */
        B8I->B8I_EXAMES := _Super:normalizeType(B8I->B8I_EXAMES,self:getValue("examinations")) /* Column B8I_EXAMES */
        B8I->B8I_INTERN := _Super:normalizeType(B8I->B8I_INTERN,self:getValue("hospitalizations")) /* Column B8I_INTERN */

        B8I->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound
