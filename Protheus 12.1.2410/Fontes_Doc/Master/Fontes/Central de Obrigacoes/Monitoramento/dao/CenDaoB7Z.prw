#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class CenDaoB7Z from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    
EndClass

Method New(aFields) Class CenDaoB7Z
	_Super:New(aFields)
    self:cAlias := "B7Z"
    self:cfieldOrder := "B7Z_CODPRO,B7Z_CODTAB"
Return self

Method buscar() Class CenDaoB7Z
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		B7Z->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoB7Z
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoB7Z

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B7Z') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	B7Z_FILIAL = '" + xFilial("B7Z") + "' "

    cQuery += " AND B7Z_CODPRO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("procedureCode")))
    cQuery += " AND B7Z_CODTAB = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("tableCode")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method commit(lInclui) Class CenDaoB7Z

    Default lInclui := .F.

	If B7Z->(RecLock("B7Z",lInclui))
		
        B7Z->B7Z_FILIAL := xFilial("B7Z")
        If lInclui
        
            B7Z->B7Z_CODPRO := _Super:normalizeType(B7Z->B7Z_CODPRO,self:getValue("procedureCode")) /* Column B7Z_CODPRO */
            B7Z->B7Z_CODTAB := _Super:normalizeType(B7Z->B7Z_CODTAB,self:getValue("tableCode")) /* Column B7Z_CODTAB */

        EndIf

        B7Z->B7Z_FORENV := _Super:normalizeType(B7Z->B7Z_FORENV,self:getValue("submissionMethod")) /* Column B7Z_FORENV */
        B7Z->B7Z_TIPEVE := _Super:normalizeType(B7Z->B7Z_TIPEVE,self:getValue("eventType")) /* Column B7Z_TIPEVE */
        B7Z->B7Z_CODGRU := _Super:normalizeType(B7Z->B7Z_CODGRU,self:getValue("procedureGroup")) /* Column B7Z_CODGRU */

        B7Z->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound
