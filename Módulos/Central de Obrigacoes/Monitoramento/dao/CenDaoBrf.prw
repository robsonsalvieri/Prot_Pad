#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class CenDaoBrf from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    
EndClass

Method New(aFields) Class CenDaoBrf
	_Super:New(aFields)
    self:cAlias := "BRF"
    self:cfieldOrder := "BRF_CODOPE,BRF_NMGOPE"
Return self

Method buscar() Class CenDaoBrf
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		BRF->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoBrf
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoBrf

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BRF') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	BRF_FILIAL = '" + xFilial("BRF") + "' "

    cQuery += " AND BRF_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BRF_NMGOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorFormNumber")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method commit(lInclui) Class CenDaoBrf

    Default lInclui := .F.

	If BRF->(RecLock("BRF",lInclui))
		
        BRF->BRF_FILIAL := xFilial("BRF")
        If lInclui
        
            BRF->BRF_CODOPE := _Super:normalizeType(BRF->BRF_CODOPE,self:getValue("operatorRecord")) /* Column BRF_CODOPE */
            BRF->BRF_NMGOPE := _Super:normalizeType(BRF->BRF_NMGOPE,self:getValue("operatorFormNumber")) /* Column BRF_NMGOPE */

        EndIf

        BRF->BRF_NMGPRE := _Super:normalizeType(BRF->BRF_NMGPRE,self:getValue("providerFormNumber")) /* Column BRF_NMGPRE */
        BRF->BRF_NMGPRI := _Super:normalizeType(BRF->BRF_NMGPRI,self:getValue("mainFormNumb")) /* Column BRF_NMGPRI */
        BRF->BRF_OREVAT := _Super:normalizeType(BRF->BRF_OREVAT,self:getValue("eventOrigin")) /* Column BRF_OREVAT */
        BRF->BRF_REGINT := _Super:normalizeType(BRF->BRF_REGINT,self:getValue("hospRegime")) /* Column BRF_REGINT */
        BRF->BRF_RGOPIN := _Super:normalizeType(BRF->BRF_RGOPIN,self:getValue("ansRecordNumber")) /* Column BRF_RGOPIN */
        BRF->BRF_SOLINT := _Super:normalizeType(BRF->BRF_SOLINT,self:getValue("hospitalizationRequest")) /* Column BRF_SOLINT */
        BRF->BRF_TIPADM := _Super:normalizeType(BRF->BRF_TIPADM,self:getValue("admissionType")) /* Column BRF_TIPADM */
        BRF->BRF_TIPATE := _Super:normalizeType(BRF->BRF_TIPATE,self:getValue("serviceType")) /* Column BRF_TIPATE */
        BRF->BRF_TIPCON := _Super:normalizeType(BRF->BRF_TIPCON,self:getValue("appointmentType")) /* Column BRF_TIPCON */
        BRF->BRF_TIPFAT := _Super:normalizeType(BRF->BRF_TIPFAT,self:getValue("invoicingTp")) /* Column BRF_TIPFAT */
        BRF->BRF_TIPINT := _Super:normalizeType(BRF->BRF_TIPINT,self:getValue("hospTp")) /* Column BRF_TIPINT */
        BRF->BRF_TPEVAT := _Super:normalizeType(BRF->BRF_TPEVAT,self:getValue("aEventType")) /* Column BRF_TPEVAT */
        BRF->BRF_VLTCOP := _Super:normalizeType(BRF->BRF_VLTCOP,self:getValue("coPaymentTotalValue")) /* Column BRF_VLTCOP */
        BRF->BRF_VLTDIA := _Super:normalizeType(BRF->BRF_VLTDIA,self:getValue("dailyRatesTotalValue")) /* Column BRF_VLTDIA */
        BRF->BRF_VLTFOR := _Super:normalizeType(BRF->BRF_VLTFOR,self:getValue("valuePaidSuppliers")) /* Column BRF_VLTFOR */
        BRF->BRF_VLTGLO := _Super:normalizeType(BRF->BRF_VLTGLO,self:getValue("formDisallowanceValue")) /* Column BRF_VLTGLO */
        BRF->BRF_VLTGUI := _Super:normalizeType(BRF->BRF_VLTGUI,self:getValue("valuePaidForm")) /* Column BRF_VLTGUI */
        BRF->BRF_VLTINF := _Super:normalizeType(BRF->BRF_VLTINF,self:getValue("totalValueEntered")) /* Column BRF_VLTINF */
        BRF->BRF_VLTMAT := _Super:normalizeType(BRF->BRF_VLTMAT,self:getValue("materialsTotalValue")) /* Column BRF_VLTMAT */
        BRF->BRF_VLTMED := _Super:normalizeType(BRF->BRF_VLTMED,self:getValue("medicationTotalValue")) /* Column BRF_VLTMED */
        BRF->BRF_VLTOPM := _Super:normalizeType(BRF->BRF_VLTOPM,self:getValue("totalOpmeValue")) /* Column BRF_VLTOPM */
        BRF->BRF_VLTPGP := _Super:normalizeType(BRF->BRF_VLTPGP,self:getValue("procedureTotalValuePai")) /* Column BRF_VLTPGP */
        BRF->BRF_VLTPRO := _Super:normalizeType(BRF->BRF_VLTPRO,self:getValue("valueProcessed")) /* Column BRF_VLTPRO */
        BRF->BRF_VLTTAX := _Super:normalizeType(BRF->BRF_VLTTAX,self:getValue("feesTotalValue")) /* Column BRF_VLTTAX */
        BRF->BRF_VLTTBP := _Super:normalizeType(BRF->BRF_VLTTBP,self:getValue("ownTableTotalValue")) /* Column BRF_VLTTBP */
        BRF->BRF_VTISPR := _Super:normalizeType(BRF->BRF_VTISPR,self:getValue("tissProviderVersion")) /* Column BRF_VTISPR */
        BRF->BRF_CPFCNP := _Super:normalizeType(BRF->BRF_CPFCNP,self:getValue("providerCpfCnpj")) /* Column BRF_CPFCNP */
        BRF->BRF_DATAUT := _Super:normalizeType(BRF->BRF_DATAUT,self:getValue("authorizationDate")) /* Column BRF_DATAUT */
        BRF->BRF_DATREA := _Super:normalizeType(BRF->BRF_DATREA,self:getValue("executionDate")) /* Column BRF_DATREA */
        BRF->BRF_DATSOL := _Super:normalizeType(BRF->BRF_DATSOL,self:getValue("requestDate")) /* Column BRF_DATSOL */
        BRF->BRF_DIAACP := _Super:normalizeType(BRF->BRF_DIAACP,self:getValue("escortDailyRates")) /* Column BRF_DIAACP */
        BRF->BRF_DIAUTI := _Super:normalizeType(BRF->BRF_DIAUTI,self:getValue("icuDailyRates")) /* Column BRF_DIAUTI */
        BRF->BRF_DTFIFT := _Super:normalizeType(BRF->BRF_DTFIFT,self:getValue("invoicingEndDate")) /* Column BRF_DTFIFT */
        BRF->BRF_DTINFT := _Super:normalizeType(BRF->BRF_DTINFT,self:getValue("invoicingStartDate")) /* Column BRF_DTINFT */
        BRF->BRF_DTPAGT := _Super:normalizeType(BRF->BRF_DTPAGT,self:getValue("paymentDt")) /* Column BRF_DTPAGT */
        BRF->BRF_DTPROT := _Super:normalizeType(BRF->BRF_DTPROT,self:getValue("collectionProtocolDate")) /* Column BRF_DTPROT */
        BRF->BRF_FORENV := _Super:normalizeType(BRF->BRF_FORENV,self:getValue("submissionMethod")) /* Column BRF_FORENV */
        BRF->BRF_IDEEXC := _Super:normalizeType(BRF->BRF_IDEEXC,self:getValue("executerId")) /* Column BRF_IDEEXC */
        BRF->BRF_IDEREE := _Super:normalizeType(BRF->BRF_IDEREE,self:getValue("refundId")) /* Column BRF_IDEREE */
        BRF->BRF_IDVLRP := _Super:normalizeType(BRF->BRF_IDVLRP,self:getValue("presetValueIdent")) /* Column BRF_IDVLRP */
        BRF->BRF_INAVIV := _Super:normalizeType(BRF->BRF_INAVIV,self:getValue("newborn")) /* Column BRF_INAVIV */
        BRF->BRF_INDACI := _Super:normalizeType(BRF->BRF_INDACI,self:getValue("indicAccident")) /* Column BRF_INDACI */
        BRF->BRF_MATRIC := _Super:normalizeType(BRF->BRF_MATRIC,self:getValue("registration")) /* Column BRF_MATRIC */
        BRF->BRF_MOTSAI := _Super:normalizeType(BRF->BRF_MOTSAI,self:getValue("outflowType")) /* Column BRF_MOTSAI */
        BRF->BRF_CBOS := _Super:normalizeType(BRF->BRF_CBOS,self:getValue("cboSCode")) /* Column BRF_CBOS */
        BRF->BRF_CDCID1 := _Super:normalizeType(BRF->BRF_CDCID1,self:getValue("icdDiagnosis1")) /* Column BRF_CDCID1 */
        BRF->BRF_CDCID2 := _Super:normalizeType(BRF->BRF_CDCID2,self:getValue("icdDiagnosis2")) /* Column BRF_CDCID2 */
        BRF->BRF_CDCID3 := _Super:normalizeType(BRF->BRF_CDCID3,self:getValue("icdDiagnosis3")) /* Column BRF_CDCID3 */
        BRF->BRF_CDCID4 := _Super:normalizeType(BRF->BRF_CDCID4,self:getValue("icdDiagnosis4")) /* Column BRF_CDCID4 */
        BRF->BRF_CDMNEX := _Super:normalizeType(BRF->BRF_CDMNEX,self:getValue("executingCityCode")) /* Column BRF_CDMNEX */
        BRF->BRF_CNES := _Super:normalizeType(BRF->BRF_CNES,self:getValue("cnes")) /* Column BRF_CNES */

        BRF->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound
