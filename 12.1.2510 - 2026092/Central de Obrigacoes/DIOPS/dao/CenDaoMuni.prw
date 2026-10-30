#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class CenDaoMuni from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    
EndClass

Method New(aFields) Class CenDaoMuni
	_Super:New(aFields)
    self:cAlias := "B8W"
    self:cfieldOrder := "B8W_CDIBGE,B8W_CODOPE,B8W_SIGLUF"
Return self

Method buscar() Class CenDaoMuni
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		B8W->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoMuni
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoMuni

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B8W') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	B8W_FILIAL = '" + xFilial("B8W") + "' "

    cQuery += " AND B8W_CDIBGE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("ibgeCityCode")))
    cQuery += " AND B8W_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerRegister")))
    cQuery += " AND B8W_SIGLUF = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("stateAcronym")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method insert() Class CenDaoMuni
    Local lFound := !self:bscChaPrim()
	If lFound
        self:commit(.T.)
    EndIf
Return lFound

Method commit(lInclui) Class CenDaoMuni

    Default lInclui := .F.

	If B8W->(RecLock("B8W",lInclui))
		
        B8W->B8W_FILIAL := xFilial("B8W")
        If lInclui
        
            B8W->B8W_CDIBGE := _Super:normalizeType(B8W->B8W_CDIBGE,self:getValue("ibgeCityCode")) /* Column B8W_CDIBGE */
            B8W->B8W_CODOPE := _Super:normalizeType(B8W->B8W_CODOPE,self:getValue("providerRegister")) /* Column B8W_CODOPE */
            B8W->B8W_SIGLUF := _Super:normalizeType(B8W->B8W_SIGLUF,self:getValue("stateAcronym")) /* Column B8W_SIGLUF */

        EndIf


        B8W->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound
