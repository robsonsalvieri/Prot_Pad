#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class PrjDaoBI9 from CenDao

    Method new(aFields) Constructor

    Method buscar()
    Method delete()
    Method bscChaPrim()
    Method commit(lInclui)
    
EndClass

Method new(aFields) Class PrjDaoBI9
	_Super:new(aFields)
    self:cAlias := "BI9"
    self:cfieldOrder := "BI9_CODIGO,BI9_VERDIS"
Return self

Method buscar() Class PrjDaoBI9
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		BI9->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class PrjDaoBI9
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class PrjDaoBI9

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BI9') + " "
	cQuery += " WHERE BI9_FILIAL = '" + xFilial("BI9") + "' "

    cQuery += " AND BI9_CODIGO = ? "
    cQuery += " AND BI9_VERDIS = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BI9_CODIGO")))
    aAdd(self:aMapBuilder, self:toString(self:getValue("BI9_VERDIS")))
    
    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method commit(lInclui) Class PrjDaoBI9
    Local lFound := .T.
    Default lInclui := .F.

    If self:getValue("BI9_ATIVO") == "1" .OR. !lInclui
        If BI9->(RecLock("BI9",lInclui))
            
            BI9->BI9_FILIAL := xFilial("BI9")
            BI9->BI9_CODIGO := _Super:normalizeType(BI9->BI9_CODIGO,self:getValue("BI9_CODIGO"))
            BI9->BI9_VERDIS := _Super:normalizeType(BI9->BI9_VERDIS,self:getValue("BI9_VERDIS"))
            BI9->BI9_STATAU := _Super:normalizeType(BI9->BI9_STATAU,self:getValue("BI9_STATAU"))
            BI9->BI9_ATIVO := _Super:normalizeType(BI9->BI9_ATIVO,self:getValue("BI9_ATIVO"))
            BI9->BI9_DESERR := _Super:normalizeType(BI9->BI9_DESERR,self:getValue("BI9_DESERR"))
            BI9->(MsUnlock())
        EndIf
    Endif

Return lFound
