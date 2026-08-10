#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class CenDaoB5I from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    
EndClass

Method New(aFields) Class CenDaoB5I
	_Super:New(aFields)
    self:cAlias := "B5I"
    self:cfieldOrder := "B5I_CODOPE,B5I_CMPLOT,B5I_NUMLOT"
Return self

Method buscar() Class CenDaoB5I
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		B5I->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoB5I
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoB5I

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B5I') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	B5I_FILIAL = '" + xFilial("B5I") + "' "

    cQuery += " AND B5I_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("ansRegister")))
    cQuery += " AND B5I_CMPLOT = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("batchPeriod")))
    cQuery += " AND B5I_NUMLOT = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("batchNumber")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method insert() Class CenDaoB5I
    Local lFound := !self:bscChaPrim()
	If lFound
        self:commit(.T.)
    EndIf
Return lFound

Method commit(lInclui) Class CenDaoB5I

    Default lInclui := .F.

	If B5I->(RecLock("B5I",lInclui))
		
        B5I->B5I_FILIAL := xFilial("B5I")
        If lInclui
        
            B5I->B5I_CODOPE := _Super:normalizeType(B5I->B5I_CODOPE,self:getValue("ansRegister")) /* Column B5I_CODOPE */
            B5I->B5I_CMPLOT := _Super:normalizeType(B5I->B5I_CMPLOT,self:getValue("batchPeriod")) /* Column B5I_CMPLOT */
            B5I->B5I_NUMLOT := _Super:normalizeType(B5I->B5I_NUMLOT,self:getValue("batchNumber")) /* Column B5I_NUMLOT */

        EndIf

        B5I->B5I_TPTRAN := _Super:normalizeType(B5I->B5I_TPTRAN,self:getValue("transactionType")) /* Column B5I_TPTRAN */
        B5I->B5I_DATPRO := _Super:normalizeType(B5I->B5I_DATPRO,self:getValue("processingDate")) /* Column B5I_DATPRO */
        B5I->B5I_HORPRO := _Super:normalizeType(B5I->B5I_HORPRO,self:getValue("processingTime")) /* Column B5I_HORPRO */
        B5I->B5I_VERPAD := _Super:normalizeType(B5I->B5I_VERPAD,self:getValue("defaultVersion")) /* Column B5I_VERPAD */
        B5I->B5I_ARQUIV := _Super:normalizeType(B5I->B5I_ARQUIV,self:getValue("qualityFile")) /* Column B5I_ARQUIV */
        B5I->B5I_STATUS := _Super:normalizeType(B5I->B5I_STATUS,self:getValue("status")) /* Column B5I_STATUS */

        B5I->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound
