#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class CenDaoBrh from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    
EndClass

Method New(aFields) Class CenDaoBrh
	_Super:New(aFields)
    self:cAlias := "BRH"
    self:cfieldOrder := "BRH_CDPRIT,BRH_CDTBIT,BRH_CODOPE,BRH_CODPRO,BRH_CODTAB,BRH_NMGOPE"
Return self

Method buscar() Class CenDaoBrh
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		BRH->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoBrh
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoBrh

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BRH') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	BRH_FILIAL = '" + xFilial("BRH") + "' "

    cQuery += " AND BRH_CDPRIT = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("itemProCode")))
    cQuery += " AND BRH_CDTBIT = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("itemTableCode")))
    cQuery += " AND BRH_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BRH_CODPRO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("procedureCode")))
    cQuery += " AND BRH_CODTAB = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("tableCode")))
    cQuery += " AND BRH_NMGOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorFormNumber")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method commit(lInclui) Class CenDaoBrh

    Default lInclui := .F.

	If BRH->(RecLock("BRH",lInclui))
		
        BRH->BRH_FILIAL := xFilial("BRH")
        If lInclui
        
            BRH->BRH_CDPRIT := _Super:normalizeType(BRH->BRH_CDPRIT,self:getValue("itemProCode")) /* Column BRH_CDPRIT */
            BRH->BRH_CDTBIT := _Super:normalizeType(BRH->BRH_CDTBIT,self:getValue("itemTableCode")) /* Column BRH_CDTBIT */
            BRH->BRH_CODOPE := _Super:normalizeType(BRH->BRH_CODOPE,self:getValue("operatorRecord")) /* Column BRH_CODOPE */
            BRH->BRH_CODPRO := _Super:normalizeType(BRH->BRH_CODPRO,self:getValue("procedureCode")) /* Column BRH_CODPRO */
            BRH->BRH_CODTAB := _Super:normalizeType(BRH->BRH_CODTAB,self:getValue("tableCode")) /* Column BRH_CODTAB */
            BRH->BRH_NMGOPE := _Super:normalizeType(BRH->BRH_NMGOPE,self:getValue("operatorFormNumber")) /* Column BRH_NMGOPE */

        EndIf

        BRH->BRH_QTPRPC := _Super:normalizeType(BRH->BRH_QTPRPC,self:getValue("packageQuantity")) /* Column BRH_QTPRPC */

        BRH->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound
