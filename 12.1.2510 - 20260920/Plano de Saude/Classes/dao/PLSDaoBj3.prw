#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class PLSDaoBj3 from CENDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    
EndClass

Method New(aFields) Class PLSDaoBj3
	_Super:New(aFields)
    self:cAlias := "BJ3"
    self:cfieldOrder := "BJ3_CODIGO,BJ3_VERSAO,BJ3_CODFOR"
Return self

Method buscar() Class PLSDaoBj3
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		BJ3->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class PLSDaoBj3
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class PLSDaoBj3

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BJ3') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	BJ3_FILIAL = '" + xFilial("BJ3") + "' "

    cQuery += " AND BJ3_CODIGO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BJ3_CODIGO")))
    cQuery += " AND BJ3_VERSAO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BJ3_VERSAO")))
    cQuery += " AND BJ3_CODFOR = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BJ3_CODFOR")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method insert() Class PLSDaoBj3
    Local lFound := !self:bscChaPrim()
	If lFound
        self:commit(.T.)
    EndIf
Return lFound

Method commit(lInclui) Class PLSDaoBj3

    Default lInclui := .F.

	If BJ3->(RecLock("BJ3",lInclui))
		
        BJ3->BJ3_FILIAL := xFilial("BJ3")
        If lInclui
        
            BJ3->BJ3_CODIGO := _Super:normalizeType(BJ3->BJ3_CODIGO,self:getValue("BJ3_CODIGO")) 
            BJ3->BJ3_VERSAO := _Super:normalizeType(BJ3->BJ3_VERSAO,self:getValue("BJ3_VERSAO")) 
            BJ3->BJ3_CODFOR := _Super:normalizeType(BJ3->BJ3_CODFOR,self:getValue("BJ3_CODFOR")) 

        EndIf


        BJ3->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound
