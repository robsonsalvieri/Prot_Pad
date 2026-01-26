#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class CenDaoBnw from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    
EndClass

Method New(aFields) Class CenDaoBnw
	_Super:New(aFields)
    self:cAlias := "BNW"
    self:cfieldOrder := "BNW_CODOPE,BNW_DECNUM,BNW_SEQGUI,BNW_TIPO"
Return self

Method buscar() Class CenDaoBnw
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		BNW->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoBnw
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoBnw

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BNW') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	BNW_FILIAL = '" + xFilial("BNW") + "' "

    cQuery += " AND BNW_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BNW_DECNUM = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("certificateNumber")))
    cQuery += " AND BNW_SEQGUI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("formSequential")))
    cQuery += " AND BNW_TIPO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("certificateType")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method insert() Class CenDaoBnw
    Local lFound := !self:bscChaPrim()
	If lFound
        self:commit(.T.)
    EndIf
Return lFound

Method commit(lInclui) Class CenDaoBnw

    Default lInclui := .F.

	If BNW->(RecLock("BNW",lInclui))
		
        BNW->BNW_FILIAL := xFilial("BNW")
        If lInclui
        
            BNW->BNW_CODOPE := _Super:normalizeType(BNW->BNW_CODOPE,self:getValue("operatorRecord")) /* Column BNW_CODOPE */
            BNW->BNW_DECNUM := _Super:normalizeType(BNW->BNW_DECNUM,self:getValue("certificateNumber")) /* Column BNW_DECNUM */
            BNW->BNW_SEQGUI := _Super:normalizeType(BNW->BNW_SEQGUI,self:getValue("formSequential")) /* Column BNW_SEQGUI */
            BNW->BNW_TIPO := _Super:normalizeType(BNW->BNW_TIPO,self:getValue("certificateType")) /* Column BNW_TIPO */

        EndIf


        BNW->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound
