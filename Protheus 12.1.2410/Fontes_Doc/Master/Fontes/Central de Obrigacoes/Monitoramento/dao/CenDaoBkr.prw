#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2
#Define PROCESSING '0'
#Define PROCESSED '1'
#Define MSSQL     "MSSQL"
#Define POSTGRES  "POSTGRES"
#Define ORACLE    "ORACLE"

Class CenDaoBkr from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method commit()
    Method delete()
    Method bscChaPrim()
    Method bscMovPend()
    Method bscMovProc()
    Method bscMovExcl()
    Method bscUltMov(aTransExc)
    Method bscQtdPag(aDatProc)
    Method bscUltChv()
    Method bscTpGuia()
    Method setProcessing()
    Method getMessage()
    Method setEndProc(nRecno)
    Method setExpired()
    Method bscAddLote()
    Method qtdGuiComp()
    Method atuCodLote(nQtdReg)
    Method atuStaANS(cStatAtu,cStatCond)
    Method staPosLot()
    Method delLote()
    Method VerCritBKR(cOperadora,cObri,cAno,cComp,cGuia)

EndClass

Method New(aFields) Class CenDaoBkr
    _Super:New(aFields)
    self:cAlias := "BKR"
    self:cfieldOrder := "BKR_ANO,BKR_CDCOMP,BKR_CDOBRI,BKR_CODOPE,BKR_NMGOPE,BKR_DTPRGU,BKR_LOTE"
Return self

Method buscar() Class CenDaoBkr
    Local lFound := .F.
    lFound := _Super:buscar()
    If lFound
        BKR->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoBkr
    Local lFound := .F.
    if self:bscChaPrim()
        lFound := _Super:delete()
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoBkr

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BKR') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	BKR_FILIAL = '" + xFilial("BKR") + "' "

    cQuery += " AND BKR_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND BKR_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND BKR_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND BKR_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BKR_NMGOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorFormNumber")))
    cQuery += " AND BKR_DTPRGU = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("formProcDt")))
    cQuery += " AND BKR_LOTE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("batchCode")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()

return lFound

Method commit(lInclui) Class CenDaoBkr

    Local cCodTiss := AllTrim(GetAdvFVal("B2R","B2R_CDTERM",xFilial("B2R")+self:getValue("tissProviderVersion"),4,""))

    Default lInclui := .F.

    If BKR->(RecLock("BKR",lInclui))

        BKR->BKR_FILIAL := xFilial("BKR")
        If lInclui

            BKR->BKR_ANO := _Super:normalizeType(BKR->BKR_ANO,self:getValue("referenceYear")) /* Column BKR_ANO */
            BKR->BKR_CDCOMP := _Super:normalizeType(BKR->BKR_CDCOMP,self:getValue("commitmentCode")) /* Column BKR_CDCOMP */
            BKR->BKR_CDOBRI := _Super:normalizeType(BKR->BKR_CDOBRI,self:getValue("requirementCode")) /* Column BKR_CDOBRI */
            BKR->BKR_CODOPE := _Super:normalizeType(BKR->BKR_CODOPE,self:getValue("operatorRecord")) /* Column BKR_CODOPE */
            BKR->BKR_NMGOPE := _Super:normalizeType(BKR->BKR_NMGOPE,self:getValue("operatorFormNumber")) /* Column BKR_NMGOPE */
            BKR->BKR_DTPRGU := _Super:normalizeType(BKR->BKR_DTPRGU,self:getValue("formProcDt")) /* Column BKR_DTPRGU */
            BKR->BKR_LOTE := _Super:normalizeType(BKR->BKR_LOTE,self:getValue("batchCode")) /* Column BKR_LOTE */

        EndIf

        BKR->BKR_MATRIC := _Super:normalizeType(BKR->BKR_MATRIC,self:getValue("registration")) /* Column BKR_MATRIC */
        BKR->BKR_MOTSAI := _Super:normalizeType(BKR->BKR_MOTSAI,self:getValue("outflowType")) /* Column BKR_MOTSAI */
        BKR->BKR_DTPROT := _Super:normalizeType(BKR->BKR_DTPROT,self:getValue("collectionProtocolDate")) /* Column BKR_DTPROT */
        BKR->BKR_FORENV := _Super:normalizeType(BKR->BKR_FORENV,self:getValue("submissionMethod")) /* Column BKR_FORENV */
        BKR->BKR_HORINC := _Super:normalizeType(BKR->BKR_HORINC,self:getValue("inclusionTime")) /* Column BKR_HORINC */
        BKR->BKR_HORPRO := _Super:normalizeType(BKR->BKR_HORPRO,self:getValue("processingTime")) /* Column BKR_HORPRO */
        BKR->BKR_IDEEXC := _Super:normalizeType(BKR->BKR_IDEEXC,self:getValue("executerId")) /* Column BKR_IDEEXC */
        BKR->BKR_IDEREE := _Super:normalizeType(BKR->BKR_IDEREE,self:getValue("refundId")) /* Column BKR_IDEREE */
        BKR->BKR_IDVLRP := _Super:normalizeType(BKR->BKR_IDVLRP,self:getValue("presetValueIdent")) /* Column BKR_IDVLRP */
        BKR->BKR_INAVIV := _Super:normalizeType(BKR->BKR_INAVIV,self:getValue("newborn")) /* Column BKR_INAVIV */
        BKR->BKR_INDACI := _Super:normalizeType(BKR->BKR_INDACI,self:getValue("indicAccident")) /* Column BKR_INDACI */
        BKR->BKR_NMGPRE := _Super:normalizeType(BKR->BKR_NMGPRE,self:getValue("providerFormNumber")) /* Column BKR_NMGPRE */
        BKR->BKR_NMGPRI := _Super:normalizeType(BKR->BKR_NMGPRI,self:getValue("mainFormNumb")) /* Column BKR_NMGPRI */
        BKR->BKR_OREVAT := _Super:normalizeType(BKR->BKR_OREVAT,self:getValue("eventOrigin")) /* Column BKR_OREVAT */
        BKR->BKR_REGINT := _Super:normalizeType(BKR->BKR_REGINT,self:getValue("hospRegime")) /* Column BKR_REGINT */
        BKR->BKR_RGOPIN := _Super:normalizeType(BKR->BKR_RGOPIN,self:getValue("ansRecordNumber")) /* Column BKR_RGOPIN */
        BKR->BKR_SOLINT := _Super:normalizeType(BKR->BKR_SOLINT,self:getValue("hospitalizationRequest")) /* Column BKR_SOLINT */
        BKR->BKR_STATUS := _Super:normalizeType(BKR->BKR_STATUS,self:getValue("status")) /* Column BKR_STATUS */
        BKR->BKR_TIPADM := _Super:normalizeType(BKR->BKR_TIPADM,self:getValue("admissionType")) /* Column BKR_TIPADM */
        BKR->BKR_TIPATE := _Super:normalizeType(BKR->BKR_TIPATE,self:getValue("serviceType")) /* Column BKR_TIPATE */
        BKR->BKR_TIPCON := _Super:normalizeType(BKR->BKR_TIPCON,self:getValue("appointmentType")) /* Column BKR_TIPCON */
        BKR->BKR_TIPFAT := _Super:normalizeType(BKR->BKR_TIPFAT,self:getValue("invoicingTp")) /* Column BKR_TIPFAT */
        BKR->BKR_TIPINT := _Super:normalizeType(BKR->BKR_TIPINT,self:getValue("hospTp")) /* Column BKR_TIPINT */
        BKR->BKR_TPEVAT := _Super:normalizeType(BKR->BKR_TPEVAT,self:getValue("aEventType")) /* Column BKR_TPEVAT */
        BKR->BKR_TPRGMN := _Super:normalizeType(BKR->BKR_TPRGMN,self:getValue("monitoringRecordType")) /* Column BKR_TPRGMN */
        BKR->BKR_VLTCOP := _Super:normalizeType(BKR->BKR_VLTCOP,self:getValue("coPaymentTotalValue")) /* Column BKR_VLTCOP */
        BKR->BKR_VLTDIA := _Super:normalizeType(BKR->BKR_VLTDIA,self:getValue("dailyRatesTotalValue")) /* Column BKR_VLTDIA */
        BKR->BKR_VLTFOR := _Super:normalizeType(BKR->BKR_VLTFOR,self:getValue("valuePaidSuppliers")) /* Column BKR_VLTFOR */
        BKR->BKR_VLTGLO := _Super:normalizeType(BKR->BKR_VLTGLO,self:getValue("formDisallowanceValue")) /* Column BKR_VLTGLO */
        BKR->BKR_VLTGUI := _Super:normalizeType(BKR->BKR_VLTGUI,self:getValue("valuePaidForm")) /* Column BKR_VLTGUI */
        BKR->BKR_VLTINF := _Super:normalizeType(BKR->BKR_VLTINF,self:getValue("totalValueEntered")) /* Column BKR_VLTINF */
        BKR->BKR_VLTMAT := _Super:normalizeType(BKR->BKR_VLTMAT,self:getValue("materialsTotalValue")) /* Column BKR_VLTMAT */
        BKR->BKR_VLTMED := _Super:normalizeType(BKR->BKR_VLTMED,self:getValue("medicationTotalValue")) /* Column BKR_VLTMED */
        BKR->BKR_VLTOPM := _Super:normalizeType(BKR->BKR_VLTOPM,self:getValue("totalOpmeValue")) /* Column BKR_VLTOPM */
        BKR->BKR_VLTPGP := _Super:normalizeType(BKR->BKR_VLTPGP,self:getValue("procedureTotalValuePai")) /* Column BKR_VLTPGP */
        BKR->BKR_VLTPRO := _Super:normalizeType(BKR->BKR_VLTPRO,self:getValue("valueProcessed")) /* Column BKR_VLTPRO */
        BKR->BKR_VLTTAX := _Super:normalizeType(BKR->BKR_VLTTAX,self:getValue("feesTotalValue")) /* Column BKR_VLTTAX */
        BKR->BKR_VLTTBP := _Super:normalizeType(BKR->BKR_VLTTBP,self:getValue("ownTableTotalValue")) /* Column BKR_VLTTBP */
        BKR->BKR_VTISPR := cCodTiss //_Super:normalizeType(BKR->BKR_VTISPR,self:getValue("tissProviderVersion")) /* Column BKR_VTISPR */
        BKR->BKR_CPFCNP := _Super:normalizeType(BKR->BKR_CPFCNP,self:getValue("providerCpfCnpj")) /* Column BKR_CPFCNP */
        BKR->BKR_DATAUT := _Super:normalizeType(BKR->BKR_DATAUT,self:getValue("authorizationDate")) /* Column BKR_DATAUT */
        BKR->BKR_DATINC := _Super:normalizeType(BKR->BKR_DATINC,self:getValue("inclusionDate")) /* Column BKR_DATINC */
        BKR->BKR_DATPRO := _Super:normalizeType(BKR->BKR_DATPRO,self:getValue("processingDate")) /* Column BKR_DATPRO */
        BKR->BKR_DATREA := _Super:normalizeType(BKR->BKR_DATREA,self:getValue("executionDate")) /* Column BKR_DATREA */
        BKR->BKR_DATSOL := _Super:normalizeType(BKR->BKR_DATSOL,self:getValue("requestDate")) /* Column BKR_DATSOL */
        BKR->BKR_DIAACP := _Super:normalizeType(BKR->BKR_DIAACP,self:getValue("escortDailyRates")) /* Column BKR_DIAACP */
        BKR->BKR_DIAUTI := _Super:normalizeType(BKR->BKR_DIAUTI,self:getValue("icuDailyRates")) /* Column BKR_DIAUTI */
        BKR->BKR_DTFIFT := _Super:normalizeType(BKR->BKR_DTFIFT,self:getValue("invoicingEndDate")) /* Column BKR_DTFIFT */
        BKR->BKR_DTINFT := _Super:normalizeType(BKR->BKR_DTINFT,self:getValue("invoicingStartDate")) /* Column BKR_DTINFT */
        BKR->BKR_DTPAGT := _Super:normalizeType(BKR->BKR_DTPAGT,self:getValue("paymentDt")) /* Column BKR_DTPAGT */
        BKR->BKR_CNES := _Super:normalizeType(BKR->BKR_CNES,self:getValue("cnes")) /* Column BKR_CNES */
        BKR->BKR_CDMNEX := _Super:normalizeType(BKR->BKR_CDMNEX,self:getValue("executingCityCode")) /* Column BKR_CDMNEX */
        BKR->BKR_CBOS := _Super:normalizeType(BKR->BKR_CBOS,self:getValue("cboSCode")) /* Column BKR_CBOS */
        BKR->BKR_CDCID1 := _Super:normalizeType(BKR->BKR_CDCID1,self:getValue("icdDiagnosis1")) /* Column BKR_CDCID1 */
        BKR->BKR_CDCID2 := _Super:normalizeType(BKR->BKR_CDCID2,self:getValue("icdDiagnosis2")) /* Column BKR_CDCID2 */
        BKR->BKR_CDCID3 := _Super:normalizeType(BKR->BKR_CDCID3,self:getValue("icdDiagnosis3")) /* Column BKR_CDCID3 */
        BKR->BKR_CDCID4 := _Super:normalizeType(BKR->BKR_CDCID4,self:getValue("icdDiagnosis4")) /* Column BKR_CDCID4 */

        BKR->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} bscMovPend
    Busca movimentacoes com a chave principal nao processadas

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method bscMovPend() Class CenDaoBkr

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BKR') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	BKR_FILIAL = '" + xFilial("BKR") + "' "

    cQuery += " AND BKR_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BKR_NMGOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorFormNumber")))
    cQuery += " AND BKR_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND BKR_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND BKR_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))

    //1=Pendente Validação;2=Pronto para o Envio;3=Criticado;7=Pendente Geração do Arquivo
    cQuery += " AND ((BKR_STATUS='') OR (BKR_STATUS='1') OR (BKR_STATUS='2') OR (BKR_STATUS='3') OR (BKR_STATUS='7')) "
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY BKR_DATPRO DESC, BKR_HORPRO DESC "

    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()
    If lFound
        BKR->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

return lFound

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} bscMovProc
    Busca movimentacoes com a chave principal ja processadas

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method bscMovProc() Class CenDaoBkr

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BKR') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	BKR_FILIAL = '" + xFilial("BKR") + "' "

    cQuery += " AND BKR_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BKR_NMGOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorFormNumber")))
    cQuery += " AND BKR_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND BKR_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND BKR_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND BKR_DTPRGU = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("formProcDt")))

    cQuery += " AND BKR_STATUS IN ( '4','6','8') " //4=Em processamento ANS;5=Criticado pela ANS;6=Finalizado;8=Arquivo gerado
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY BKR_DATPRO DESC, BKR_HORPRO DESC "

    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()
    If lFound
        BKR->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

return lFound


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} bscMovExcl
    Busca movimentacoes para realizar a exclusao

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method bscMovExcl() Class CenDaoBkr

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BKR') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	BKR_FILIAL = '" + xFilial("BKR") + "' "

    cQuery += " AND BKR_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BKR_NMGOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorFormNumber")))
    cQuery += " AND BKR_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    if !Empty(self:getValue("formProcDt"))
        cQuery += " AND BKR_DTPRGU = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("formProcDt")))
    EndIf
    cQuery += " AND BKR_STATUS <> '5' " //5=Criticado pela ANS
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY BKR_DATPRO DESC, BKR_HORPRO DESC "

    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()
    If lFound
        BKR->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

return lFound


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} bscUltMov
    Busca ultima movimentacao de uma guia para refazer o historico

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method bscUltMov(aDatProc) Class CenDaoBkr

    Local lFound := .F.
    Local cQuery := ""
    Local cStr   := ""
    Local nX     := 0
    Default aDatProc := {}

    for nX := 1 to len(aDatProc)
        cStr += "'" + aDatProc[nX] + "'" + iif(nX < len(aDatProc),",","")
    next

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BKR') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	BKR_FILIAL = '" + xFilial("BKR") + "' "

    cQuery += " AND BKR_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BKR_NMGOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorFormNumber")))
    cQuery += " AND BKR_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))

    if !Empty(cStr)
        cQuery += "	AND BKR_DTPRGU NOT IN ("+cStr+") "
    endIf

    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY BKR_DTPRGU DESC, BKR_DATPRO DESC, BKR_HORPRO DESC "

    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()
    If lFound
        BKR->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

return lFound


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} bscQtdPag
    Busca ultima movimentacao de uma guia para refazer o historico

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method bscQtdPag(aDatProc) Class CenDaoBkr

    Local lFound := .F.
    Local cQuery := ""
    Local nX     := 0
    Local cStr   := ""
    Local lVariosPag := .F.
    Default aDatProc := {}

    for nX := 1 to len(aDatProc)
        cStr += "'" + aDatProc[nX] + "'" + iif(nX < len(aDatProc),",","")
    next

    cQuery := " SELECT COUNT(BKR_DTPRGU) COUNT "
    cQuery += " FROM " + RetSqlName('BKR') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	BKR_FILIAL = '" + xFilial("BKR") + "' "

    cQuery += " AND BKR_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BKR_NMGOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorFormNumber")))
    cQuery += " AND BKR_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND BKR_TPRGMN <> '3' "
    if !Empty(cStr)
        cQuery += " AND BKR_DTPRGU NOT IN ("+cStr+") "
    endIf
    cQuery += "	AND BKR_DTPAGT <> ' ' "
    cQuery += " AND D_E_L_E_T_ = ' ' "

    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()
    lVariosPag := (lFound .And. &(self:getAliasTemp()+"->COUNT") > 1)
    self:fechaQuery()

return lVariosPag


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} bscUltChv
    Verifica se a ultima transacao da chave ANS e uma exclusao

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method bscUltChv() Class CenDaoBkr

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BKR') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	BKR_FILIAL = '" + xFilial("BKR") + "' "

    cQuery += " AND BKR_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BKR_NMGOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorFormNumber")))
    cQuery += " AND BKR_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))

    if !empty(self:getValue("referenceYear"))
        cQuery += " AND BKR_ANO = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    endIf

    if !empty(self:getValue("commitmentCode"))
        cQuery += " AND BKR_CDCOMP = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    endIf

    cQuery += " AND BKR_DTPRGU = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("formProcDt")))

    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY BKR_DATPRO DESC, BKR_HORPRO DESC "

    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()
    If lFound
        BKR->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

return lFound
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} bscTpGuia
    Busca movimentacoes baseadas no Tipo de Guia.

    @type  Class
    @author Hermiro Júnior
    @since 04/12/2019
/*/
//------------------------------------------------------------------------------------------
Method bscTpGuia(cTpGuia) Class CenDaoBkr

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BKR') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	BKR_FILIAL = '" + xFilial("BKR") + "' "

    cQuery += " AND BKR_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BKR_NMGOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorFormNumber")))
    cQuery += " AND BKR_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND BKR_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND BKR_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND BKR_DTPRGU = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("formProcDt")))

    cQuery += " AND BKR_TPEVAT  = '"+cTpGuia+"' "
    cQuery += " AND D_E_L_E_T_ = ' ' "

    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()
    If lFound
        BKR->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

return lFound

Method setProcessing() Class CenDaoBKR

    Local cQuery := ""
    Local lFound := .F.

    If self:cDB <> POSTGRES

        If self:cDB $ MSSQL
            cQuery := " UPDATE TOP(1) "
        Else
            cQuery := " UPDATE "

        EndIf

        cQuery += " " + RetSqlName('BKR') + " "
        cQuery += " SET "
        cQuery += " BKR_PROCES = '" + PROCESSING + "' "
        cQuery += " , BKR_ROBOID='"+self:toString(self:getValue("processId"))+"' "
        cQuery += " , BKR_ROBOHR = '" + DToS(Date()) + " " + Time() + "' "
        cQuery += " WHERE 1=1 "
        cQuery += " AND BKR_FILIAL = '" + xFilial( 'BKR' ) + "' "
        cQuery += " AND BKR_PROCES <> '" + PROCESSED + "' "
        cQuery += " AND BKR_ROBOID = '' "

        If (self:cDB $ "ORACLE")
            cQuery += "	AND ROWNUM = 1 "
        EndIf

        cQuery += " AND D_E_L_E_T_ = ' ' "

    Else
        cQuery := " UPDATE " + RetSqlName('BKR') + " SET "
        cQuery += " BKR_PROCES = '" + PROCESSING + "' "
        cQuery += " , BKR_ROBOID='"+self:toString(self:getValue("processId"))+"' "
        cQuery += " , BKR_ROBOHR = '" + DToS(Date()) + " " + Time() + "' "
        cQuery += " WHERE R_E_C_N_O_ = (SELECT R_E_C_N_O_ FROM  " + RetSqlName('BKR') + " WHERE  "
        cQuery += " BKR_FILIAL = '" + xFilial( 'BKR' ) + "' "
        cQuery += " AND BKR_PROCES <> '" + PROCESSED + "' "
        cQuery += " AND BKR_ROBOID = '' "
        cQuery += " AND D_E_L_E_T_ = ' ' "
        cQuery += "	LIMIT 1 )"

    EndIf

    self:setQuery(cQuery)
    lFound := self:execStatement()

Return lFound

Method getMessage() Class CenDaoBKR

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BKR') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND BKR_PROCES = '" + PROCESSING + "' "
    cQuery += " AND BKR_ROBOID ='"+self:toString(self:getValue("processId"))+"' "

    self:setQuery(cQuery)
    lFound := self:executaQuery()
    If lFound
        BKR->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

return lFound

Method setEndProc(nRecno) Class CenDaoBKR

    Local cQuery := ""
    Local lFound := .F.

    Default nRecno := 0

    If self:cDB <> POSTGRES

        If self:cDB $ MSSQL
            cQuery := " UPDATE TOP(1) "
        Else
            cQuery := " UPDATE "

        EndIf
        cQuery += " " + RetSqlName('BKR') + " "
        cQuery += " SET "
        cQuery += " BKR_PROCES = '" + PROCESSED + "' "
        cQuery += " WHERE 1=1 "
        cQuery += " AND R_E_C_N_O_ = '" + AllTrim(Str(nRecno)) + "' "

        If (self:cDB $ "ORACLE")
            cQuery += "	AND ROWNUM = 1 "
        EndIf

    Else
        cQuery := " UPDATE " + RetSqlName('BKR') + " SET "
        cQuery += " BKR_PROCES = '" + PROCESSED + "' "
        cQuery += " WHERE R_E_C_N_O_ = (SELECT R_E_C_N_O_ FROM  " + RetSqlName('BKR') + " "
        cQuery += " WHERE 1=1 "
        cQuery += " AND R_E_C_N_O_ = '" + AllTrim(Str(nRecno)) + "' "
        cQuery += "	LIMIT 1 )"

    EndIf

    self:setQuery(cQuery)
    lFound := self:execStatement()

Return lFound

Method setExpired() Class CenDaoBKR

    Local cQuery := ""
    Local lFound := .F.

    cQuery := " UPDATE "
    cQuery += " " + RetSqlName('BKR') + " "
    cQuery += " SET "
    cQuery += " BKR_ROBOID = '' "
    cQuery += " ,BKR_PROCES = '" + PROCESSING + "' "
    cQuery += " WHERE 1=1 "
    cQuery += " AND BKR_ROBOID <> '' "
    cQuery += " AND BKR_PROCES = '" + PROCESSING + "' "
    cQuery += " AND BKR_ROBOHR <= '" + SubMinutos(Date(),Time(),2) + "' "
    cQuery += " AND BKR_ROBOHR <> ' ' "
    cQuery += " AND D_E_L_E_T_ = ' ' "

    self:setQuery(cQuery)
    lFound := self:execStatement()
Return lFound

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} bscAddLote
    Busca guias para adicionar no lote

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method bscAddLote() Class CenDaoBkr

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT BKR_CDOBRI, BKR_ANO, BKR_CDCOMP, 0 AS RECNO "
    cQuery += " FROM " + RetSqlName('BKR') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	BKR_FILIAL = '" + xFilial("BKR") + "' "

    cQuery += " AND BKR_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))

    cQuery += " AND BKR_STATUS = '2' "
    cQuery += " AND BKR_LOTE   = ' ' "
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY BKR_CDOBRI, BKR_ANO, BKR_CDCOMP "

    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()
    If lFound
        BKR->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

return lFound


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} qtdGuiComp
    Retorna a quantidade de guias de uma competencia aptas
    para serem adicionadas em um lote

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method qtdGuiComp() Class CenDaoBkr

    Local nTotal := 0
    Local cQuery := ""

    cQuery := " SELECT COUNT(1) TOTAL "
    cQuery += " FROM " + RetSqlName('BKR') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	BKR_FILIAL = '" + xFilial("BKR") + "' "
    cQuery += " AND BKR_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BKR_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND BKR_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND BKR_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND BKR_LOTE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("batchCode")))
    cQuery += " AND BKR_STATUS = '2' "
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY BKR_FILIAL, BKR_CODOPE, BKR_CDOBRI, BKR_ANO, BKR_CDCOMP "

    self:setQuery(self:queryBuilder(cQuery))
    If self:executaQuery()
        nTotal := (self:getAliasTemp())->TOTAL
    EndIf
    self:fechaQuery()

return nTotal


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} atuCodLote
    Atualiza o numero do lote nas guias

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method atuCodLote(nQtdReg) Class CenDaoBkr

    Local cQuery := ""
    Local lFound := .F.

    If self:cDB <> POSTGRES
        If self:cDB $ MSSQL
            cQuery := " UPDATE TOP("+cValtoChar(nQtdReg)+") "
        Else
            cQuery := " UPDATE "

        EndIf

        cQuery += " " + RetSqlName('BKR') + " "
        cQuery += " SET BKR_STATUS = '7', "
        cQuery += " BKR_LOTE = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("batchCode")))
        cQuery += " WHERE 1=1 "
        cQuery += " AND BKR_FILIAL = '" + xFilial( 'BKR' ) + "' "
        cQuery += " AND BKR_CODOPE = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
        cQuery += " AND BKR_CDOBRI = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
        cQuery += " AND BKR_ANO = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
        cQuery += " AND BKR_CDCOMP = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
        cQuery += " AND BKR_LOTE = ' ' "
        cQuery += " AND BKR_STATUS = '2' "
        cQuery += " AND D_E_L_E_T_ = ' ' "

        If (self:cDB $ "ORACLE")
            cQuery += "	AND ROWNUM = 1 "
        EndIf
    Else

        cQuery := " UPDATE " + RetSqlName('BKR') + " "
        cQuery += " SET BKR_STATUS = '7', BKR_LOTE = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("batchCode")))
        cQuery += " WHERE R_E_C_N_O_ =  (SELECT R_E_C_N_O_ FROM " + RetSqlName('BKR') + " "
        cQuery += " WHERE BKR_FILIAL = '" + xFilial( 'BKR' ) + "' "
        cQuery += " AND BKR_CODOPE = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
        cQuery += " AND BKR_CDOBRI = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
        cQuery += " AND BKR_ANO = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
        cQuery += " AND BKR_CDCOMP = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
        cQuery += " AND BKR_LOTE = ' ' "
        cQuery += " AND BKR_STATUS = '2' "
        cQuery += " AND D_E_L_E_T_ = ' ' "
        cQuery += "	LIMIT ("+cValtoChar(nQtdReg)+"))"

    EndIf

    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:execStatement()

Return lFound


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} atuStaANS
    Atualiza o status do lote nas guias

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method atuStaANS(cStatAtu,cStatCond) Class CenDaoBkr

    Local cQuery      := ""
    Local lFound      := .F.
    Default cStatAtu  := "6"
    Default cStatCond := "5"

    cQuery := " UPDATE "
    cQuery += " " + RetSqlName('BKR') + " "
    cQuery += " SET "
    cQuery += " BKR_STATUS = ? "
    aAdd(self:aMapBuilder, cStatAtu )
    cQuery += " WHERE 1=1 "
    cQuery += " AND BKR_FILIAL = '" + xFilial( 'BKR' ) + "' "
    cQuery += " AND BKR_LOTE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("batchCode")))
    cQuery += " AND BKR_STATUS NOT IN ('"+cStatCond+"') "
    cQuery += " AND D_E_L_E_T_ = ' ' "

    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:execStatement()

Return lFound


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} atuStaANS
    Atualiza o status após geração do arquivo XTE

    @type  Class
    @author jose.paulo
    @since 3/08/2020
/*/
//------------------------------------------------------------------------------------------
Method staPosLot() Class CenDaoBkr

    Local cQuery := ""
    Local lFound := .F.

    cQuery := " UPDATE " + RetSqlName('BKR') + " "
    cQuery += " SET "
    cQuery += " BKR_STATUS = '8' "
    cQuery += " WHERE 1=1 "
    cQuery += " AND BKR_FILIAL = '" + xFilial( 'BKR' ) + "' "
    cQuery += " AND BKR_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BKR_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND BKR_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND BKR_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND BKR_LOTE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("batchCode")))
    cQuery += " AND BKR_STATUS = '7' "
    cQuery += " AND D_E_L_E_T_ = ' ' "

    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:execStatement()

Return lFound

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} delLote
    Atualiza o status do lote após ele ser deletado na BKW

    @type  Class
    @author vinicius.nicolau
    @since 03/08/2020
/*/
//------------------------------------------------------------------------------------------
Method delLote() Class CenDaoBkr

    Local cSql      := ""
    Local lFound    := .F.

    cSql := "UPDATE " + RetSqlName("BKR") + " "
    cSql += " SET BKR_LOTE = '' , BKR_STATUS = '2' "
    cSql += " WHERE 1=1 "
    cSql += " AND BKR_FILIAL = '" + xFilial("BKR") + "' "
    cSql += " AND BKR_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BKR_ANO")))
    cSql += " AND BKR_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BKR_CDCOMP")))
    cSql += " AND BKR_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BKR_CDOBRI")))
    cSql += " AND BKR_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BKR_CODOPE")))
    cSql += " AND BKR_LOTE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BKR_LOTE")))
    cSql += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')

    self:setQuery(self:queryBuilder(cSql))
    lFound := self:execStatement()

Return lFound

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} VerCritBKR
    Retorna a quantidade de registros com critica

    @type  Class
    @author jose.paulo
    @since 12/08/2020
/*/
//------------------------------------------------------------------------------------------
Method VerCritBKR(cOperadora,cObri,cAno,cComp,cGuia) Class CenDaoBkr

    Local nRecno := 0
    Local cQuery := ""

    If !Empty(cOperadora) .And. !Empty(cObri) .And. !Empty(cAno) .And. !Empty(cComp) .And. !Empty(cGuia)
        cQuery := " SELECT R_E_C_N_O_  RECNO "
        cQuery += " FROM " + RetSqlName('BKR') + " "
        cQuery += " WHERE 1=1 "
        cQuery += " AND	BKR_FILIAL = '" + xFilial("BKR") + "' "
        cQuery += " AND BKR_CODOPE = '" +cOperadora+"' "
        cQuery += " AND BKR_CDOBRI = '" +cObri+"' "
        cQuery += " AND BKR_ANO =    '" +cAno+"' "
        cQuery += " AND BKR_CDCOMP = '" +cComp+"' "
        cQuery += " AND BKR_NMGOPE = '" +cGuia+"' "
        cQuery += " AND BKR_STATUS = '2' AND D_E_L_E_T_ = ' ' "

        self:setQuery(self:queryBuilder(cQuery))
        If self:executaQuery()
            nRecno := (self:getAliasTemp())->RECNO
        EndIf
        self:fechaQuery()
    endIf

return nRecno
