#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class PLSDaoBil from CENDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    
EndClass

Method New(aFields) Class PLSDaoBil
	_Super:New(aFields)
    self:cAlias := "BIL"
    self:cfieldOrder := "BIL_CODIGO,BIL_VERSAO"
Return self

Method buscar() Class PLSDaoBil
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		BIL->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class PLSDaoBil
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class PLSDaoBil

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BIL') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	BIL_FILIAL = '" + xFilial("BIL") + "' "

    cQuery += " AND BIL_CODIGO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BIL_CODIGO")))
    cQuery += " AND BIL_VERSAO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BIL_VERSAO")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method insert() Class PLSDaoBil
    Local lFound := !self:bscChaPrim()
	If lFound
        self:commit(.T.)
    EndIf
Return lFound

Method commit(lInclui) Class PLSDaoBil

    Default lInclui := .F.

	If BIL->(RecLock("BIL",lInclui))
		
        BIL->BIL_FILIAL := xFilial("BIL")
        If lInclui
        
            BIL->BIL_CODIGO := _Super:normalizeType(BIL->BIL_CODIGO,self:getValue("BIL_CODIGO")) 
            BIL->BIL_VERSAO := _Super:normalizeType(BIL->BIL_VERSAO,self:getValue("BIL_VERSAO")) 

        EndIf

        BIL->BIL_DATINI := _Super:normalizeType(BIL->BIL_DATINI,self:getValue("BIL_DATINI")) 
        BIL->BIL_DATFIN := _Super:normalizeType(BIL->BIL_DATFIN,self:getValue("BIL_DATFIN")) 
        BIL->BIL_CODANT := _Super:normalizeType(BIL->BIL_CODANT,self:getValue("BIL_CODANT")) 
        BIL->BIL_DESANT := _Super:normalizeType(BIL->BIL_DESANT,self:getValue("BIL_DESANT")) 

        BIL->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound
