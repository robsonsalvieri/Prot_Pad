#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class CenDaoColi from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    
EndClass

Method New(aFields) Class CenDaoColi
	_Super:New(aFields)
    self:cAlias := "B8T"
    self:cfieldOrder := "B8T_CNPJ,B8T_CODOPE"
Return self

Method buscar() Class CenDaoColi
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		B8T->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoColi
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoColi

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B8T') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	B8T_FILIAL = '" + xFilial("B8T") + "' "

    cQuery += " AND B8T_CNPJ = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("legalEntityNatRegister")))
    cQuery += " AND B8T_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerRegister")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method insert() Class CenDaoColi
    Local lFound := !self:bscChaPrim()
	If lFound
        self:commit(.T.)
    EndIf
Return lFound

Method commit(lInclui) Class CenDaoColi

    Default lInclui := .F.

	If B8T->(RecLock("B8T",lInclui))
		
        B8T->B8T_FILIAL := xFilial("B8T")
        If lInclui
        
            B8T->B8T_CNPJ := _Super:normalizeType(B8T->B8T_CNPJ,self:getValue("legalEntityNatRegister")) /* Column B8T_CNPJ */
            B8T->B8T_CODOPE := _Super:normalizeType(B8T->B8T_CODOPE,self:getValue("providerRegister")) /* Column B8T_CODOPE */

        EndIf

        B8T->B8T_QTDACO := _Super:normalizeType(B8T->B8T_QTDACO,self:getValue("quantityOfActions")) /* Column B8T_QTDACO */
        B8T->B8T_RAZSOC := _Super:normalizeType(B8T->B8T_RAZSOC,self:getValue("companyName")) /* Column B8T_RAZSOC */
        B8T->B8T_TOTACO := _Super:normalizeType(B8T->B8T_TOTACO,self:getValue("totalOfActionsOrQuota")) /* Column B8T_TOTACO */
        B8T->B8T_TPPART := _Super:normalizeType(B8T->B8T_TPPART,self:getValue("typeOfShare")) /* Column B8T_TPPART */
        B8T->B8T_CLAEMP := _Super:normalizeType(B8T->B8T_CLAEMP,self:getValue("companyClassification")) /* Column B8T_CLAEMP */

        B8T->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound
