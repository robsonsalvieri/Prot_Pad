#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class CenDaoResp from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    
EndClass

Method New(aFields) Class CenDaoResp
	_Super:New(aFields)
    self:cAlias := "B8Y"
    self:cfieldOrder := "B8Y_CODOPE,B8Y_CPFCNP,B8Y_TPPESS,B8Y_TPRESP"
Return self

Method buscar() Class CenDaoResp
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		B8Y->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoResp
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoResp

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B8Y') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	B8Y_FILIAL = '" + xFilial("B8Y") + "' "

    cQuery += " AND B8Y_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerRegister")))
    cQuery += " AND B8Y_CPFCNP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("cpfCnpj")))
    cQuery += " AND B8Y_TPPESS = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("responsibleLeOrIndivid")))
    cQuery += " AND B8Y_TPRESP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("responsibilityType")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method insert() Class CenDaoResp
    Local lFound := !self:bscChaPrim()
	If lFound
        self:commit(.T.)
    EndIf
Return lFound

Method commit(lInclui) Class CenDaoResp

    Default lInclui := .F.

	If B8Y->(RecLock("B8Y",lInclui))
		
        B8Y->B8Y_FILIAL := xFilial("B8Y")
        If lInclui
        
            B8Y->B8Y_CODOPE := _Super:normalizeType(B8Y->B8Y_CODOPE,self:getValue("providerRegister")) /* Column B8Y_CODOPE */
            B8Y->B8Y_CPFCNP := _Super:normalizeType(B8Y->B8Y_CPFCNP,self:getValue("cpfCnpj")) /* Column B8Y_CPFCNP */
            B8Y->B8Y_TPPESS := _Super:normalizeType(B8Y->B8Y_TPPESS,self:getValue("responsibleLeOrIndivid")) /* Column B8Y_TPPESS */
            B8Y->B8Y_TPRESP := _Super:normalizeType(B8Y->B8Y_TPRESP,self:getValue("responsibilityType")) /* Column B8Y_TPRESP */

        EndIf

        B8Y->B8Y_NOMRAZ := _Super:normalizeType(B8Y->B8Y_NOMRAZ,self:getValue("nameCorporateName")) /* Column B8Y_NOMRAZ */
        B8Y->B8Y_NUMREG := _Super:normalizeType(B8Y->B8Y_NUMREG,self:getValue("recordNumber")) /* Column B8Y_NUMREG */

        B8Y->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound
