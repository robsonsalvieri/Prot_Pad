#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class CenDaoBrc from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    
EndClass

Method New(aFields) Class CenDaoBrc
	_Super:New(aFields)
    self:cAlias := "BRC"
    self:cfieldOrder := "BRC_CDPRIT,BRC_CDTBIT,BRC_CODOPE,BRC_SEQGUI,BRC_SEQITE"
Return self

Method buscar() Class CenDaoBrc
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		BRC->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoBrc
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoBrc

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BRC') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	BRC_FILIAL = '" + xFilial("BRC") + "' "

    cQuery += " AND BRC_CDPRIT = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("itemProCode")))
    cQuery += " AND BRC_CDTBIT = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("itemTableCode")))
    cQuery += " AND BRC_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BRC_SEQGUI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("formSequential")))
    cQuery += " AND BRC_SEQITE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("sequentialItem")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method commit(lInclui) Class CenDaoBrc

    Default lInclui := .F.

	If BRC->(RecLock("BRC",lInclui))
		
        BRC->BRC_FILIAL := xFilial("BRC")
        If lInclui
        
            BRC->BRC_CDPRIT := _Super:normalizeType(BRC->BRC_CDPRIT,self:getValue("itemProCode")) /* Column BRC_CDPRIT */
            BRC->BRC_CDTBIT := _Super:normalizeType(BRC->BRC_CDTBIT,self:getValue("itemTableCode")) /* Column BRC_CDTBIT */
            BRC->BRC_CODOPE := _Super:normalizeType(BRC->BRC_CODOPE,self:getValue("operatorRecord")) /* Column BRC_CODOPE */
            BRC->BRC_SEQGUI := _Super:normalizeType(BRC->BRC_SEQGUI,self:getValue("formSequential")) /* Column BRC_SEQGUI */
            BRC->BRC_SEQITE := _Super:normalizeType(BRC->BRC_SEQITE,self:getValue("sequentialItem")) /* Column BRC_SEQITE */

        EndIf

        BRC->BRC_QTPRPC := _Super:normalizeType(BRC->BRC_QTPRPC,self:getValue("packageQuantity")) /* Column BRC_QTPRPC */

        BRC->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound
