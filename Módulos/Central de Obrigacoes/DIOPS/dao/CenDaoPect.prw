#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class CenDaoPect from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    
EndClass

Method New(aFields) Class CenDaoPect
	_Super:New(aFields)
    self:cAlias := "B37"
    self:cfieldOrder := "B37_CDCOMP,B37_CODOBR,B37_CODOPE,B37_PERCOB,B37_PLANO,B37_ANOCMP"
Return self

Method buscar() Class CenDaoPect
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		B37->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoPect
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoPect

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B37') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	B37_FILIAL = '" + xFilial("B37") + "' "

    cQuery += " AND B37_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND B37_CODOBR = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("obligationCode")))
    cQuery += " AND B37_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerRegister")))
    cQuery += " AND B37_PERCOB = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("counterpartCoveragePeri")))
    cQuery += " AND B37_PLANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("planType")))
    cQuery += " AND B37_ANOCMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentYear")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method insert() Class CenDaoPect
    Local lFound := !self:bscChaPrim()
	If lFound
        self:commit(.T.)
    EndIf
Return lFound

Method commit(lInclui) Class CenDaoPect

    Default lInclui := .F.

	If B37->(RecLock("B37",lInclui))
		
        B37->B37_FILIAL := xFilial("B37")
        If lInclui
        
            B37->B37_CDCOMP := _Super:normalizeType(B37->B37_CDCOMP,self:getValue("commitmentCode")) /* Column B37_CDCOMP */
            B37->B37_CODOBR := _Super:normalizeType(B37->B37_CODOBR,self:getValue("obligationCode")) /* Column B37_CODOBR */
            B37->B37_CODOPE := _Super:normalizeType(B37->B37_CODOPE,self:getValue("providerRegister")) /* Column B37_CODOPE */
            B37->B37_PERCOB := _Super:normalizeType(B37->B37_PERCOB,self:getValue("counterpartCoveragePeri")) /* Column B37_PERCOB */
            B37->B37_PLANO := _Super:normalizeType(B37->B37_PLANO,self:getValue("planType")) /* Column B37_PLANO */
            B37->B37_ANOCMP := _Super:normalizeType(B37->B37_ANOCMP,self:getValue("commitmentYear")) /* Column B37_ANOCMP */

        EndIf

        B37->B37_AVENCE := _Super:normalizeType(B37->B37_AVENCE,self:getValue("valueToExpire")) /* Column B37_AVENCE */
        B37->B37_RECEBI := _Super:normalizeType(B37->B37_RECEBI,self:getValue("receivedValue")) /* Column B37_RECEBI */
        B37->B37_REFERE := _Super:normalizeType(B37->B37_REFERE,self:getValue("trimester")) /* Column B37_REFERE */
        B37->B37_STATUS := _Super:normalizeType(B37->B37_STATUS,self:getValue("status")) /* Column B37_STATUS */
        B37->B37_VENCID := _Super:normalizeType(B37->B37_VENCID,self:getValue("dueValueInArrears")) /* Column B37_VENCID */
        B37->B37_EMITID := _Super:normalizeType(B37->B37_EMITID,self:getValue("netIssuedValue")) /* Column B37_EMITID */

        B37->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound
