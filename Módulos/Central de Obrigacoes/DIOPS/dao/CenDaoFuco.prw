#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class CenDaoFuco from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    
EndClass

Method New(aFields) Class CenDaoFuco
	_Super:New(aFields)
    self:cAlias := "B6R"
    self:cfieldOrder := "B6R_ANOCMP,B6R_CDCOMP,B6R_CNPJ,B6R_CODOBR,B6R_CODOPE,B6R_TIPO"
Return self

Method buscar() Class CenDaoFuco
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		B6R->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoFuco
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoFuco

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B6R') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	B6R_FILIAL = '" + xFilial("B6R") + "' "

    cQuery += " AND B6R_ANOCMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentYear")))
    cQuery += " AND B6R_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND B6R_CNPJ = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("cnpjOrFundAnsRec")))
    cQuery += " AND B6R_CODOBR = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("obligationCode")))
    cQuery += " AND B6R_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerRegister")))
    cQuery += " AND B6R_TIPO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("fundType")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method insert() Class CenDaoFuco
    Local lFound := !self:bscChaPrim()
	If lFound
        self:commit(.T.)
    EndIf
Return lFound

Method commit(lInclui) Class CenDaoFuco

    Default lInclui := .F.

	If B6R->(RecLock("B6R",lInclui))
		
        B6R->B6R_FILIAL := xFilial("B6R")
        If lInclui
        
            B6R->B6R_ANOCMP := _Super:normalizeType(B6R->B6R_ANOCMP,self:getValue("commitmentYear")) /* Column B6R_ANOCMP */
            B6R->B6R_CDCOMP := _Super:normalizeType(B6R->B6R_CDCOMP,self:getValue("commitmentCode")) /* Column B6R_CDCOMP */
            B6R->B6R_CNPJ := _Super:normalizeType(B6R->B6R_CNPJ,self:getValue("cnpjOrFundAnsRec")) /* Column B6R_CNPJ */
            B6R->B6R_CODOBR := _Super:normalizeType(B6R->B6R_CODOBR,self:getValue("obligationCode")) /* Column B6R_CODOBR */
            B6R->B6R_CODOPE := _Super:normalizeType(B6R->B6R_CODOPE,self:getValue("providerRegister")) /* Column B6R_CODOPE */
            B6R->B6R_TIPO := _Super:normalizeType(B6R->B6R_TIPO,self:getValue("fundType")) /* Column B6R_TIPO */

        EndIf

        B6R->B6R_NOME := _Super:normalizeType(B6R->B6R_NOME,self:getValue("fundName")) /* Column B6R_NOME */
        B6R->B6R_REFERE := _Super:normalizeType(B6R->B6R_REFERE,self:getValue("trimester")) /* Column B6R_REFERE */
        B6R->B6R_SLDCRD := _Super:normalizeType(B6R->B6R_SLDCRD,self:getValue("creditBalanceOfFund")) /* Column B6R_SLDCRD */
        B6R->B6R_SLDDEB := _Super:normalizeType(B6R->B6R_SLDDEB,self:getValue("debitorBalanceOfFund")) /* Column B6R_SLDDEB */
        B6R->B6R_STATUS := _Super:normalizeType(B6R->B6R_STATUS,self:getValue("status")) /* Column B6R_STATUS */

        B6R->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound
