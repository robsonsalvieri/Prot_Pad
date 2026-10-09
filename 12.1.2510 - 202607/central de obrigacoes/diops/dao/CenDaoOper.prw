#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class CenDaoOper from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    
EndClass

Method New(aFields) Class CenDaoOper
	_Super:New(aFields)
    self:cAlias := "B8M"
    self:cfieldOrder := "B8M_CNPJOP,B8M_CODOPE"
Return self

Method buscar() Class CenDaoOper
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		B8M->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoOper
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoOper

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B8M') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	B8M_FILIAL = '" + xFilial("B8M") + "' "

    cQuery += " AND B8M_CNPJOP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorCnpj")))
    cQuery += " AND B8M_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerRegister")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method insert() Class CenDaoOper
    Local lFound := !self:bscChaPrim()
	If lFound
        self:commit(.T.)
    EndIf
Return lFound

Method commit(lInclui) Class CenDaoOper

    Default lInclui := .F.

	If B8M->(RecLock("B8M",lInclui))
		
        B8M->B8M_FILIAL := xFilial("B8M")
        If lInclui
        
            B8M->B8M_CNPJOP := _Super:normalizeType(B8M->B8M_CNPJOP,self:getValue("operatorCnpj")) /* Column B8M_CNPJOP */
            B8M->B8M_CODOPE := _Super:normalizeType(B8M->B8M_CODOPE,self:getValue("providerRegister")) /* Column B8M_CODOPE */

        EndIf

        B8M->B8M_MODALI := _Super:normalizeType(B8M->B8M_MODALI,self:getValue("operatorMode")) /* Column B8M_MODALI */
        B8M->B8M_NATJUR := _Super:normalizeType(B8M->B8M_NATJUR,self:getValue("legalNature")) /* Column B8M_NATJUR */
        B8M->B8M_NOMFAN := _Super:normalizeType(B8M->B8M_NOMFAN,self:getValue("tradeName")) /* Column B8M_NOMFAN */
        B8M->B8M_RAZSOC := _Super:normalizeType(B8M->B8M_RAZSOC,self:getValue("corporateName")) /* Column B8M_RAZSOC */
        B8M->B8M_SEGMEN := _Super:normalizeType(B8M->B8M_SEGMEN,self:getValue("operatorSegmentation")) /* Column B8M_SEGMEN */

        B8M->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound
