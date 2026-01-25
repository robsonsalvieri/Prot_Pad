#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class CenDaoQdrs from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    
EndClass

Method New(aFields) Class CenDaoQdrs
	_Super:New(aFields)
    self:cAlias := "B8X"
    self:cfieldOrder := "B8X_ANOCMP,B8X_CDCOMP,B8X_CODOBR,B8X_CODOPE,B8X_QUADRO"
Return self

Method buscar() Class CenDaoQdrs
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		B8X->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoQdrs
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoQdrs

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B8X') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	B8X_FILIAL = '" + xFilial("B8X") + "' "

    cQuery += " AND B8X_ANOCMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentYear")))
    cQuery += " AND B8X_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND B8X_CODOBR = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("obligationCode")))
    cQuery += " AND B8X_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerRegister")))
    cQuery += " AND B8X_QUADRO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("diopsChart")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method insert() Class CenDaoQdrs
    Local lFound := !self:bscChaPrim()
	If lFound
        self:commit(.T.)
    EndIf
Return lFound

Method commit(lInclui) Class CenDaoQdrs

    Default lInclui := .F.

	If B8X->(RecLock("B8X",lInclui))
		
        B8X->B8X_FILIAL := xFilial("B8X")
        If lInclui
        
            B8X->B8X_ANOCMP := _Super:normalizeType(B8X->B8X_ANOCMP,self:getValue("commitmentYear")) /* Column B8X_ANOCMP */
            B8X->B8X_CDCOMP := _Super:normalizeType(B8X->B8X_CDCOMP,self:getValue("commitmentCode")) /* Column B8X_CDCOMP */
            B8X->B8X_CODOBR := _Super:normalizeType(B8X->B8X_CODOBR,self:getValue("obligationCode")) /* Column B8X_CODOBR */
            B8X->B8X_CODOPE := _Super:normalizeType(B8X->B8X_CODOPE,self:getValue("providerRegister")) /* Column B8X_CODOPE */
            B8X->B8X_QUADRO := _Super:normalizeType(B8X->B8X_QUADRO,self:getValue("diopsChart")) /* Column B8X_QUADRO */

        EndIf

        B8X->B8X_RECEBI := _Super:normalizeType(B8X->B8X_RECEBI,self:getValue("chartReceived")) /* Column B8X_RECEBI */
        B8X->B8X_VALIDA := _Super:normalizeType(B8X->B8X_VALIDA,self:getValue("validateChart")) /* Column B8X_VALIDA */

        B8X->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound
