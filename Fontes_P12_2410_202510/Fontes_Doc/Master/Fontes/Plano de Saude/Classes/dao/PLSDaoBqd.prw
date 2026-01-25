#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class PLSDaoBqd from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    
EndClass

Method New(aFields) Class PLSDaoBqd
	_Super:New(aFields)
    self:cAlias := "BQD"
    self:cfieldOrder := "BQD_CODIGO,BQD_NUMCON,BQD_VERCON,BQD_SUBCON,BQD_VERSUB"
Return self

Method buscar() Class PLSDaoBqd
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		BQD->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class PLSDaoBqd
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class PLSDaoBqd

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BQD') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	BQD_FILIAL = '" + xFilial("BQD") + "' "

    cQuery += " AND BQD_CODIGO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("code"))) /* Column BQD_CODIGO */
    cQuery += " AND BQD_NUMCON = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("groupCompanyGroup"))) /* Column BQD_NUMCON */
    cQuery += " AND BQD_VERCON = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("version"))) /* Column BQD_VERCON */
    cQuery += " AND BQD_SUBCON = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("subContract"))) /* Column BQD_SUBCON */
    cQuery += " AND BQD_VERSUB = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("subContractVersion"))) /* Column BQD_VERSUB */

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method insert() Class PLSDaoBqd
    Local lFound := !self:bscChaPrim()
	If lFound
        self:commit(.T.)
    EndIf
Return lFound

Method commit(lInclui) Class PLSDaoBqd

    Default lInclui := .F.

	If BQD->(RecLock("BQD",lInclui))
		
        BQD->BQD_FILIAL := xFilial("BQD")
        If lInclui
        
            BQD->BQD_CODIGO := _Super:normalizeType(BQD->BQD_CODIGO,self:getValue("code")) 
            BQD->BQD_NUMCON := _Super:normalizeType(BQD->BQD_NUMCON,self:getValue("groupCompanyGroup")) 
            BQD->BQD_VERCON := _Super:normalizeType(BQD->BQD_VERCON,self:getValue("version")) 
            BQD->BQD_SUBCON := _Super:normalizeType(BQD->BQD_SUBCON,self:getValue("subContract")) 
            BQD->BQD_VERSUB := _Super:normalizeType(BQD->BQD_VERSUB,self:getValue("subContractVersion")) 

        EndIf

        BQD->BQD_DATINI := _Super:normalizeType(BQD->BQD_DATINI,self:getValue("versionInitialDate")) 
        BQD->BQD_DATFIN := _Super:normalizeType(BQD->BQD_DATFIN,self:getValue("versionFinalDate")) 

        BQD->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound
