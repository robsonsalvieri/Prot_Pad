#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class CenDaoMdpc from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    
EndClass

Method New(aFields) Class CenDaoMdpc
	_Super:New(aFields)
    self:cAlias := "B82"
    self:cfieldOrder := "B82_ANOCMP,B82_CDCOMP,B82_CODOBR,B82_CODOPE"
Return self

Method buscar() Class CenDaoMdpc
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		B82->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoMdpc
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoMdpc

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B82') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	B82_FILIAL = '" + xFilial("B82") + "' "

    cQuery += " AND B82_ANOCMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentYear")))
    cQuery += " AND B82_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND B82_CODOBR = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("obligationCode")))
    cQuery += " AND B82_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerRegister")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method insert() Class CenDaoMdpc
    Local lFound := !self:bscChaPrim()
	If lFound
        self:commit(.T.)
    EndIf
Return lFound

Method commit(lInclui) Class CenDaoMdpc

    Default lInclui := .F.

	If B82->(RecLock("B82",lInclui))
		
        B82->B82_FILIAL := xFilial("B82")
        If lInclui
        
            B82->B82_ANOCMP := _Super:normalizeType(B82->B82_ANOCMP,self:getValue("commitmentYear")) /* Column B82_ANOCMP */
            B82->B82_CDCOMP := _Super:normalizeType(B82->B82_CDCOMP,self:getValue("commitmentCode")) /* Column B82_CDCOMP */
            B82->B82_CODOBR := _Super:normalizeType(B82->B82_CODOBR,self:getValue("obligationCode")) /* Column B82_CODOBR */
            B82->B82_CODOPE := _Super:normalizeType(B82->B82_CODOPE,self:getValue("providerRegister")) /* Column B82_CODOPE */

        EndIf

        B82->B82_NMRMTP := _Super:normalizeType(B82->B82_NMRMTP,self:getValue("tempRemidNumber")) /* Column B82_NMRMTP */
        B82->B82_NMRMVI := _Super:normalizeType(B82->B82_NMRMVI,self:getValue("vitRemidNumber")) /* Column B82_NMRMVI */
        B82->B82_REFERE := _Super:normalizeType(B82->B82_REFERE,self:getValue("trimester")) /* Column B82_REFERE */
        B82->B82_SMDETP := _Super:normalizeType(B82->B82_SMDETP,self:getValue("tempExpSom")) /* Column B82_SMDETP */
        B82->B82_SMDEVI := _Super:normalizeType(B82->B82_SMDEVI,self:getValue("vitExpSom")) /* Column B82_SMDEVI */
        B82->B82_SMRMTP := _Super:normalizeType(B82->B82_SMRMTP,self:getValue("tempRemisSom")) /* Column B82_SMRMTP */
        B82->B82_SMRMVI := _Super:normalizeType(B82->B82_SMRMVI,self:getValue("vitRemisSom")) /* Column B82_SMRMVI */
        B82->B82_STATUS := _Super:normalizeType(B82->B82_STATUS,self:getValue("status")) /* Column B82_STATUS */

        B82->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound
