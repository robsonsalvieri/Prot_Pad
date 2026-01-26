#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class CenDaoB5P from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    
EndClass

Method New(aFields) Class CenDaoB5P
	_Super:New(aFields)
    self:cAlias := "B5P"
    self:cfieldOrder := "B5P_CDCMGU,B5P_CDCMER,B5P_CODOPE,B5P_CMPLOT,B5P_NUMLOT,B5P_NMGOPE,B5P_CODPAD,B5P_CODPRO,B5P_CODGRU"
Return self

Method buscar() Class CenDaoB5P
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		B5P->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoB5P
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoB5P

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B5P') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	B5P_FILIAL = '" + xFilial("B5P") + "' "

    cQuery += " AND B5P_CDCMGU = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("formFieldIdentifier")))
    cQuery += " AND B5P_CDCMER = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("errorCode")))
    cQuery += " AND B5P_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("ansRegister")))
    cQuery += " AND B5P_CMPLOT = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("batchPeriod")))
    cQuery += " AND B5P_NUMLOT = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("batchNumber")))
    cQuery += " AND B5P_NMGOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorFormNumber")))
    cQuery += " AND B5P_CODPAD = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("tableCode")))
    cQuery += " AND B5P_CODPRO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("procedureCode")))
    cQuery += " AND B5P_CODGRU = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("procedureGroup")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method insert() Class CenDaoB5P
    Local lFound := !self:bscChaPrim()
	If lFound
        self:commit(.T.)
    EndIf
Return lFound

Method commit(lInclui) Class CenDaoB5P

    Default lInclui := .F.

	If B5P->(RecLock("B5P",lInclui))
		
        B5P->B5P_FILIAL := xFilial("B5P")
        If lInclui
        
            B5P->B5P_CDCMGU := _Super:normalizeType(B5P->B5P_CDCMGU,self:getValue("formFieldIdentifier")) /* Column B5P_CDCMGU */
            B5P->B5P_CDCMER := _Super:normalizeType(B5P->B5P_CDCMER,self:getValue("errorCode")) /* Column B5P_CDCMER */
            B5P->B5P_CODOPE := _Super:normalizeType(B5P->B5P_CODOPE,self:getValue("ansRegister")) /* Column B5P_CODOPE */
            B5P->B5P_CMPLOT := _Super:normalizeType(B5P->B5P_CMPLOT,self:getValue("batchPeriod")) /* Column B5P_CMPLOT */
            B5P->B5P_NUMLOT := _Super:normalizeType(B5P->B5P_NUMLOT,self:getValue("batchNumber")) /* Column B5P_NUMLOT */
            B5P->B5P_NMGOPE := _Super:normalizeType(B5P->B5P_NMGOPE,self:getValue("operatorFormNumber")) /* Column B5P_NMGOPE */
            B5P->B5P_CODPAD := _Super:normalizeType(B5P->B5P_CODPAD,self:getValue("tableCode")) /* Column B5P_CODPAD */
            B5P->B5P_CODPRO := _Super:normalizeType(B5P->B5P_CODPRO,self:getValue("procedureCode")) /* Column B5P_CODPRO */
            B5P->B5P_CODGRU := _Super:normalizeType(B5P->B5P_CODGRU,self:getValue("procedureGroup")) /* Column B5P_CODGRU */
            B5P->B5P_CNES   := _Super:normalizeType(B5P->B5P_CODGRU,self:getValue("cnes"))           /* Column B5P_CNES */
            B5P->B5P_CPFCGC := _Super:normalizeType(B5P->B5P_CODGRU,self:getValue("providerCpfCnpj"))/* Column B5P_CPFCGC */

        EndIf
        B5P->B5P_CONCAM := _Super:normalizeType(B5P->B5P_CONCAM,self:getValue("fieldContent"))   /* Column B5P_CONCAM */
        B5P->B5P_DESERR := _Super:normalizeType(B5P->B5P_DESERR,self:getValue("errorDescription")) /* Column B5P_DESERR */
        B5P->B5P_NIVERR := _Super:normalizeType(B5P->B5P_NIVERR,self:getValue("errorLevel")) /* Column B5P_NIVERR */
        B5P->B5P_NMGPRE := _Super:normalizeType(B5P->B5P_NMGPRE,self:getValue("providerFormNumber")) /* Column B5P_NMGPRE */
        B5P->B5P_IDREEM := _Super:normalizeType(B5P->B5P_IDREEM,self:getValue("refundIdentifier")) /* Column B5P_IDREEM */
        B5P->B5P_DATPRO := _Super:normalizeType(B5P->B5P_DATPRO,self:getValue("processingDate")) /* Column B5P_DATPRO */
        B5P->B5P_CDDENT := _Super:normalizeType(B5P->B5P_CDDENT,self:getValue("toothCode")) /* Column B5P_CDDENT */
        B5P->B5P_CDFACE := _Super:normalizeType(B5P->B5P_CDFACE,self:getValue("toothFaceCode")) /* Column B5P_CDFACE */
        B5P->B5P_CDREGI := _Super:normalizeType(B5P->B5P_CDREGI,self:getValue("regionCode")) /* Column B5P_CDREGI */

        B5P->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound
