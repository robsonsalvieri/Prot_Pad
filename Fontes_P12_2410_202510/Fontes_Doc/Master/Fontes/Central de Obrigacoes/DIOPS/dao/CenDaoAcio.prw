#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class CenDaoAcio from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    
EndClass

Method New(aFields) Class CenDaoAcio
	_Super:New(aFields)
    self:cAlias := "B8S"
    self:cfieldOrder := "B8S_CODOPE,B8S_CPFCNP"
Return self

Method buscar() Class CenDaoAcio
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		B8S->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoAcio
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoAcio

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B8S') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	B8S_FILIAL = '" + xFilial("B8S") + "' "

    cQuery += " AND B8S_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerRegister")))
    cQuery += " AND B8S_CPFCNP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("shareholderSCpfCnpj")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method insert() Class CenDaoAcio
    Local lFound := !self:bscChaPrim()
	If lFound
        self:commit(.T.)
    EndIf
Return lFound

Method commit(lInclui) Class CenDaoAcio

    Default lInclui := .F.

	If B8S->(RecLock("B8S",lInclui))
		
        B8S->B8S_FILIAL := xFilial("B8S")
        If lInclui
        
            B8S->B8S_CODOPE := _Super:normalizeType(B8S->B8S_CODOPE,self:getValue("providerRegister")) /* Column B8S_CODOPE */
            B8S->B8S_CPFCNP := _Super:normalizeType(B8S->B8S_CPFCNP,self:getValue("shareholderSCpfCnpj")) /* Column B8S_CPFCNP */

        EndIf

        B8S->B8S_NOMRAZ := _Super:normalizeType(B8S->B8S_NOMRAZ,self:getValue("corporateName")) /* Column B8S_NOMRAZ */
        B8S->B8S_QTDQUO := _Super:normalizeType(B8S->B8S_QTDQUO,self:getValue("numberOfShares")) /* Column B8S_QTDQUO */
        B8S->B8S_TPACIO := _Super:normalizeType(B8S->B8S_TPACIO,self:getValue("shareholderType")) /* Column B8S_TPACIO */

        B8S->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound
