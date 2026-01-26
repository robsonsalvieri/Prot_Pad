#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class CenDaoBny from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    
EndClass

Method New(aFields) Class CenDaoBny
	_Super:New(aFields)
    self:cAlias := "BNY"
    self:cfieldOrder := "BNY_CODOPE,BNY_DECNUM,BNY_NMGOPE,BNY_TIPO"
Return self

Method buscar() Class CenDaoBny
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		BNY->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoBny
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoBny

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BNY') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	BNY_FILIAL = '" + xFilial("BNY") + "' "

    cQuery += " AND BNY_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BNY_DECNUM = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("certificateNumber")))
    cQuery += " AND BNY_NMGOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorFormNumber")))
    cQuery += " AND BNY_TIPO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("certificateType")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method commit(lInclui) Class CenDaoBny

    Default lInclui := .F.

	If BNY->(RecLock("BNY",lInclui))
		
        BNY->BNY_FILIAL := xFilial("BNY")
        If lInclui
        
            BNY->BNY_CODOPE := _Super:normalizeType(BNY->BNY_CODOPE,self:getValue("operatorRecord")) /* Column BNY_CODOPE */
            BNY->BNY_DECNUM := _Super:normalizeType(BNY->BNY_DECNUM,self:getValue("certificateNumber")) /* Column BNY_DECNUM */
            BNY->BNY_NMGOPE := _Super:normalizeType(BNY->BNY_NMGOPE,self:getValue("operatorFormNumber")) /* Column BNY_NMGOPE */
            BNY->BNY_TIPO := _Super:normalizeType(BNY->BNY_TIPO,self:getValue("certificateType")) /* Column BNY_TIPO */

        EndIf


        BNY->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound
