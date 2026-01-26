#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class CenDaoAgcn from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    
EndClass

Method New(aFields) Class CenDaoAgcn
	_Super:New(aFields)
    self:cAlias := "B8K"
    self:cfieldOrder := "B8K_ANOCMP,B8K_CDCOMP,B8K_CODOBR,B8K_CODOPE,B8K_TIPO"
Return self

Method buscar() Class CenDaoAgcn
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		B8K->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoAgcn
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoAgcn

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B8K') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	B8K_FILIAL = '" + xFilial("B8K") + "' "

    cQuery += " AND B8K_ANOCMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentYear")))
    cQuery += " AND B8K_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND B8K_CODOBR = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("obligationCode")))
    cQuery += " AND B8K_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerRegister")))
    cQuery += " AND B8K_TIPO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("riskPool")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method insert() Class CenDaoAgcn
    Local lFound := !self:bscChaPrim()
	If lFound
        self:commit(.T.)
    EndIf
Return lFound

Method commit(lInclui) Class CenDaoAgcn

    Default lInclui := .F.

	If B8K->(RecLock("B8K",lInclui))
		
        B8K->B8K_FILIAL := xFilial("B8K")
        If lInclui
        
            B8K->B8K_ANOCMP := _Super:normalizeType(B8K->B8K_ANOCMP,self:getValue("commitmentYear")) /* Column B8K_ANOCMP */
            B8K->B8K_CDCOMP := _Super:normalizeType(B8K->B8K_CDCOMP,self:getValue("commitmentCode")) /* Column B8K_CDCOMP */
            B8K->B8K_CODOBR := _Super:normalizeType(B8K->B8K_CODOBR,self:getValue("obligationCode")) /* Column B8K_CODOBR */
            B8K->B8K_CODOPE := _Super:normalizeType(B8K->B8K_CODOPE,self:getValue("providerRegister")) /* Column B8K_CODOPE */
            B8K->B8K_TIPO := _Super:normalizeType(B8K->B8K_TIPO,self:getValue("riskPool")) /* Column B8K_TIPO */

        EndIf

        B8K->B8K_PCECC := _Super:normalizeType(B8K->B8K_PCECC,self:getValue("pceCorresponGranted")) /* Column B8K_PCECC */
        B8K->B8K_PCECE := _Super:normalizeType(B8K->B8K_PCECE,self:getValue("pceIssuedCounterprov")) /* Column B8K_PCECE */
        B8K->B8K_PCEEV := _Super:normalizeType(B8K->B8K_PCEEV,self:getValue("eveClaimsKnownPce")) /* Column B8K_PCEEV */
        B8K->B8K_PLACC := _Super:normalizeType(B8K->B8K_PLACC,self:getValue("plaCorresponGranted")) /* Column B8K_PLACC */
        B8K->B8K_PLACE := _Super:normalizeType(B8K->B8K_PLACE,self:getValue("issuedConsiderationsPla")) /* Column B8K_PLACE */
        B8K->B8K_PLAEV := _Super:normalizeType(B8K->B8K_PLAEV,self:getValue("plaKnowlLossEvents")) /* Column B8K_PLAEV */
        B8K->B8K_REFERE := _Super:normalizeType(B8K->B8K_REFERE,self:getValue("trimester")) /* Column B8K_REFERE */
        B8K->B8K_STATUS := _Super:normalizeType(B8K->B8K_STATUS,self:getValue("status")) /* Column B8K_STATUS */

        B8K->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound
