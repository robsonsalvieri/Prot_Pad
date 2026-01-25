#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class CenDaoCcop from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    
EndClass

Method New(aFields) Class CenDaoCcop
	_Super:New(aFields)
    self:cAlias := "BUW"
    self:cfieldOrder := "BUW_CDCOMP,BUW_CODOBR,BUW_CODOPE,BUW_DENOMI,BUW_DTCOMP,BUW_TIPO,BUW_ANOCMP"
Return self

Method buscar() Class CenDaoCcop
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		BUW->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoCcop
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoCcop

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BUW') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	BUW_FILIAL = '" + xFilial("BUW") + "' "

    cQuery += " AND BUW_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND BUW_CODOBR = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("obligationCode")))
    cQuery += " AND BUW_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerRegister")))
    cQuery += " AND BUW_DENOMI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("taxName")))
    cQuery += " AND BUW_DTCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("periodDate")))
    cQuery += " AND BUW_TIPO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("taxType")))
    cQuery += " AND BUW_ANOCMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentYear")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method insert() Class CenDaoCcop
    Local lFound := !self:bscChaPrim()
	If lFound
        self:commit(.T.)
    EndIf
Return lFound

Method commit(lInclui) Class CenDaoCcop

    Default lInclui := .F.

	If BUW->(RecLock("BUW",lInclui))
		
        BUW->BUW_FILIAL := xFilial("BUW")
        If lInclui
        
            BUW->BUW_CDCOMP := _Super:normalizeType(BUW->BUW_CDCOMP,self:getValue("commitmentCode")) /* Column BUW_CDCOMP */
            BUW->BUW_CODOBR := _Super:normalizeType(BUW->BUW_CODOBR,self:getValue("obligationCode")) /* Column BUW_CODOBR */
            BUW->BUW_CODOPE := _Super:normalizeType(BUW->BUW_CODOPE,self:getValue("providerRegister")) /* Column BUW_CODOPE */
            BUW->BUW_DENOMI := _Super:normalizeType(BUW->BUW_DENOMI,self:getValue("taxName")) /* Column BUW_DENOMI */
            BUW->BUW_DTCOMP := _Super:normalizeType(BUW->BUW_DTCOMP,self:getValue("periodDate")) /* Column BUW_DTCOMP */
            BUW->BUW_TIPO := _Super:normalizeType(BUW->BUW_TIPO,self:getValue("taxType")) /* Column BUW_TIPO */
            BUW->BUW_ANOCMP := _Super:normalizeType(BUW->BUW_ANOCMP,self:getValue("commitmentYear")) /* Column BUW_ANOCMP */

        EndIf

        BUW->BUW_ATUMON := _Super:normalizeType(BUW->BUW_ATUMON,self:getValue("monetaryUpdate")) /* Column BUW_ATUMON */
        BUW->BUW_VLPGTR := _Super:normalizeType(BUW->BUW_VLPGTR,self:getValue("amtPaidTrimester")) /* Column BUW_VLPGTR */
        BUW->BUW_VLRFIN := _Super:normalizeType(BUW->BUW_VLRFIN,self:getValue("totalAmtFinanced")) /* Column BUW_VLRFIN */
        BUW->BUW_VLRPAG := _Super:normalizeType(BUW->BUW_VLRPAG,self:getValue("totalAmtPaid")) /* Column BUW_VLRPAG */
        BUW->BUW_DTREFI := _Super:normalizeType(BUW->BUW_DTREFI,self:getValue("dateAdhesionToRefis")) /* Column BUW_DTREFI */
        BUW->BUW_NUMPAR := _Super:normalizeType(BUW->BUW_NUMPAR,self:getValue("numberOfInstallments")) /* Column BUW_NUMPAR */
        BUW->BUW_QTPAIN := _Super:normalizeType(BUW->BUW_QTPAIN,self:getValue("numbDueInstallments")) /* Column BUW_QTPAIN */
        BUW->BUW_QTPAPG := _Super:normalizeType(BUW->BUW_QTPAPG,self:getValue("numbOfPaidInstallm")) /* Column BUW_QTPAPG */
        BUW->BUW_REFERE := _Super:normalizeType(BUW->BUW_REFERE,self:getValue("trimester")) /* Column BUW_REFERE */
        BUW->BUW_SLDFIN := _Super:normalizeType(BUW->BUW_SLDFIN,self:getValue("trimesterFinalBalance")) /* Column BUW_SLDFIN */
        BUW->BUW_SLDINI := _Super:normalizeType(BUW->BUW_SLDINI,self:getValue("trimesterInitialBalance")) /* Column BUW_SLDINI */
        BUW->BUW_STATUS := _Super:normalizeType(BUW->BUW_STATUS,self:getValue("status")) /* Column BUW_STATUS */

        BUW->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound
