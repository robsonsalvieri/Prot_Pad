#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class CenDaoBrg from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    Method bscEveHist()
    
EndClass

Method New(aFields) Class CenDaoBrg
	_Super:New(aFields)
    self:cAlias := "BRG"
    self:cfieldOrder := "BRG_CODGRU,BRG_CODOPE,BRG_CODPRO,BRG_CODTAB,BRG_NMGOPE,BRG_CDDENT,BRG_CDFACE,BRG_CDREGI"
Return self

Method buscar() Class CenDaoBrg
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		BRG->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoBrg
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoBrg

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BRG') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	BRG_FILIAL = '" + xFilial("BRG") + "' "

    cQuery += " AND BRG_CODGRU = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("procedureGroup")))
    cQuery += " AND BRG_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BRG_CODPRO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("procedureCode")))
    cQuery += " AND BRG_CODTAB = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("tableCode")))
    cQuery += " AND BRG_NMGOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorFormNumber")))
    cQuery += " AND BRG_CDDENT = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("toothCode")))
    cQuery += " AND BRG_CDFACE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("toothFaceCode")))
    cQuery += " AND BRG_CDREGI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("regionCode")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method commit(lInclui) Class CenDaoBrg

    Default lInclui := .F.

	If BRG->(RecLock("BRG",lInclui))
		
        BRG->BRG_FILIAL := xFilial("BRG")
        If lInclui
        
            BRG->BRG_CODGRU := _Super:normalizeType(BRG->BRG_CODGRU,self:getValue("procedureGroup")) /* Column BRG_CODGRU */
            BRG->BRG_CODOPE := _Super:normalizeType(BRG->BRG_CODOPE,self:getValue("operatorRecord")) /* Column BRG_CODOPE */
            BRG->BRG_CODPRO := _Super:normalizeType(BRG->BRG_CODPRO,self:getValue("procedureCode")) /* Column BRG_CODPRO */
            BRG->BRG_CODTAB := _Super:normalizeType(BRG->BRG_CODTAB,self:getValue("tableCode")) /* Column BRG_CODTAB */
            BRG->BRG_NMGOPE := _Super:normalizeType(BRG->BRG_NMGOPE,self:getValue("operatorFormNumber")) /* Column BRG_NMGOPE */
            BRG->BRG_CDDENT := _Super:normalizeType(BRG->BRG_CDDENT,self:getValue("toothCode")) /* Column BRG_CDDENT */
            BRG->BRG_CDFACE := _Super:normalizeType(BRG->BRG_CDFACE,self:getValue("toothFaceCode")) /* Column BRG_CDFACE */
            BRG->BRG_CDREGI := _Super:normalizeType(BRG->BRG_CDREGI,self:getValue("regionCode")) /* Column BRG_CDREGI */

        EndIf

        BRG->BRG_CNPJFR := _Super:normalizeType(BRG->BRG_CNPJFR,self:getValue("supplierCnpj")) /* Column BRG_CNPJFR */
        BRG->BRG_PACOTE := _Super:normalizeType(BRG->BRG_PACOTE,self:getValue("package")) /* Column BRG_PACOTE */
        BRG->BRG_QTDINF := _Super:normalizeType(BRG->BRG_QTDINF,self:getValue("enteredQuantity")) /* Column BRG_QTDINF */
        BRG->BRG_QTDPAG := _Super:normalizeType(BRG->BRG_QTDPAG,self:getValue("quantityPaid")) /* Column BRG_QTDPAG */
        BRG->BRG_VLPGPR := _Super:normalizeType(BRG->BRG_VLPGPR,self:getValue("procedureValuePaid")) /* Column BRG_VLPGPR */
        BRG->BRG_VLRCOP := _Super:normalizeType(BRG->BRG_VLRCOP,self:getValue("coPaymentValue")) /* Column BRG_VLRCOP */
        BRG->BRG_VLRGLO := _Super:normalizeType(BRG->BRG_VLRGLO,self:getValue("disallVl")) /* Column BRG_VLRGLO */
        BRG->BRG_VLRINF := _Super:normalizeType(BRG->BRG_VLRINF,self:getValue("valueEntered")) /* Column BRG_VLRINF */
        BRG->BRG_VLRPGF := _Super:normalizeType(BRG->BRG_VLRPGF,self:getValue("valuePaidSupplier")) /* Column BRG_VLRPGF */
        BRG->BRG_TIPEVE := _Super:normalizeType(BRG->BRG_TIPEVE,self:getValue("eventType")) /* Column BRG_TIPEVE */

        BRG->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} bscEveHist
    Busca eventos do historico de uma guia

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method bscEveHist() Class CenDaoBRG

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BRG') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	BRG_FILIAL = '" + xFilial("BRG") + "' "

    cQuery += " AND BRG_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BRG_NMGOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorFormNumber")))

    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY BRG_CODGRU, BRG_CODTAB, BRG_CODPRO, BRG_CDDENT, BRG_CDREGI, BRG_CDFACE "

    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()
    If lFound 
		BRG->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
    
return lFound
