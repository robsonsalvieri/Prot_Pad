#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2
#Define PROCESSING '0'
#Define PROCESSED '1'

#DEFINE MSSQL     "MSSQL"
#DEFINE POSTGRES  "POSTGRES"
#DEFINE ORACLE    "ORACLE"


Class CenDaoBra from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method delete()
    Method bscChaPrim()
    Method commit(lInclui)
    Method setProcessing()
    Method getMessage()
    Method setEndProc(nRecno)
    Method setExpired()
    Method GetProcess(cIdProc)

EndClass

Method New(aFields) Class CenDaoBra
    _Super:New(aFields)
    self:cAlias := "BRA"
    self:cfieldOrder := "BRA_CODOPE,BRA_SEQGUI"
Return self

Method buscar() Class CenDaoBra
    Local lFound := .F.
    lFound := _Super:buscar()
    If lFound
        BRA->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoBra
    Local lFound := .F.
    if self:bscChaPrim()
        lFound := _Super:delete()
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoBra

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BRA') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	BRA_FILIAL = '" + xFilial("BRA") + "' "

    cQuery += " AND BRA_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BRA_SEQGUI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("formSequential")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()
    If lFound
        BRA->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

return lFound

Method commit(lInclui) Class CenDaoBra

    Default lInclui := .F.

    If BRA->(RecLock("BRA",lInclui))

        BRA->BRA_FILIAL := xFilial("BRA")
        If lInclui

            BRA->BRA_CODOPE := _Super:normalizeType(BRA->BRA_CODOPE,self:getValue("operatorRecord")) /* Column BRA_CODOPE */
            BRA->BRA_SEQGUI := _Super:normalizeType(BRA->BRA_SEQGUI,self:getValue("formSequential")) /* Column BRA_SEQGUI */

        EndIf

        BRA->BRA_SOLINT := _Super:normalizeType(BRA->BRA_SOLINT,self:getValue("hospitalizationRequest")) /* Column BRA_SOLINT */
        BRA->BRA_TIPADM := _Super:normalizeType(BRA->BRA_TIPADM,self:getValue("admissionType")) /* Column BRA_TIPADM */
        BRA->BRA_TIPATE := _Super:normalizeType(BRA->BRA_TIPATE,self:getValue("serviceType")) /* Column BRA_TIPATE */
        BRA->BRA_TIPCON := _Super:normalizeType(BRA->BRA_TIPCON,self:getValue("appointmentType")) /* Column BRA_TIPCON */
        BRA->BRA_TIPFAT := _Super:normalizeType(BRA->BRA_TIPFAT,self:getValue("invoicingTp")) /* Column BRA_TIPFAT */
        BRA->BRA_TIPINT := _Super:normalizeType(BRA->BRA_TIPINT,self:getValue("hospTp")) /* Column BRA_TIPINT */
        BRA->BRA_TPEVAT := _Super:normalizeType(BRA->BRA_TPEVAT,self:getValue("aEventType")) /* Column BRA_TPEVAT */
        BRA->BRA_VTISPR := _Super:normalizeType(BRA->BRA_VTISPR,self:getValue("tissProviderVersion")) /* Column BRA_VTISPR */
        BRA->BRA_CBOS := _Super:normalizeType(BRA->BRA_CBOS,self:getValue("cboSCode")) /* Column BRA_CBOS */
        BRA->BRA_CDCID1 := _Super:normalizeType(BRA->BRA_CDCID1,self:getValue("icdDiagnosis1")) /* Column BRA_CDCID1 */
        BRA->BRA_CDCID2 := _Super:normalizeType(BRA->BRA_CDCID2,self:getValue("icdDiagnosis2")) /* Column BRA_CDCID2 */
        BRA->BRA_CDCID3 := _Super:normalizeType(BRA->BRA_CDCID3,self:getValue("icdDiagnosis3")) /* Column BRA_CDCID3 */
        BRA->BRA_CDCID4 := _Super:normalizeType(BRA->BRA_CDCID4,self:getValue("icdDiagnosis4")) /* Column BRA_CDCID4 */
        BRA->BRA_CDMNEX := _Super:normalizeType(BRA->BRA_CDMNEX,self:getValue("executingCityCode")) /* Column BRA_CDMNEX */
        BRA->BRA_CNES := _Super:normalizeType(BRA->BRA_CNES,self:getValue("cnes")) /* Column BRA_CNES */
        BRA->BRA_CPFCNP := _Super:normalizeType(BRA->BRA_CPFCNP,self:getValue("providerCpfCnpj")) /* Column BRA_CPFCNP */
        BRA->BRA_DATAUT := _Super:normalizeType(BRA->BRA_DATAUT,self:getValue("authorizationDate")) /* Column BRA_DATAUT */
        BRA->BRA_DATINC := _Super:normalizeType(BRA->BRA_DATINC,self:getValue("inclusionDate")) /* Column BRA_DATINC */
        BRA->BRA_DATREA := _Super:normalizeType(BRA->BRA_DATREA,self:getValue("executionDate")) /* Column BRA_DATREA */
        BRA->BRA_DATSOL := _Super:normalizeType(BRA->BRA_DATSOL,self:getValue("requestDate")) /* Column BRA_DATSOL */
        BRA->BRA_DIAACP := _Super:normalizeType(BRA->BRA_DIAACP,self:getValue("escortDailyRates")) /* Column BRA_DIAACP */
        BRA->BRA_DIAUTI := _Super:normalizeType(BRA->BRA_DIAUTI,self:getValue("icuDailyRates")) /* Column BRA_DIAUTI */
        BRA->BRA_DTFIFT := _Super:normalizeType(BRA->BRA_DTFIFT,self:getValue("invoicingEndDate")) /* Column BRA_DTFIFT */
        BRA->BRA_DTINFT := _Super:normalizeType(BRA->BRA_DTINFT,self:getValue("invoicingStartDate")) /* Column BRA_DTINFT */
        BRA->BRA_DTPAGT := _Super:normalizeType(BRA->BRA_DTPAGT,self:getValue("paymentDt")) /* Column BRA_DTPAGT */
        BRA->BRA_DTPRGU := _Super:normalizeType(BRA->BRA_DTPRGU,self:getValue("formProcDt")) /* Column BRA_DTPRGU */
        BRA->BRA_DTPROT := _Super:normalizeType(BRA->BRA_DTPROT,self:getValue("collectionProtocolDate")) /* Column BRA_DTPROT */
        BRA->BRA_EXCLU := _Super:normalizeType(BRA->BRA_EXCLU,self:getValue("exclusionId")) /* Column BRA_EXCLU */
        BRA->BRA_FORENV := _Super:normalizeType(BRA->BRA_FORENV,self:getValue("submissionMethod")) /* Column BRA_FORENV */
        BRA->BRA_HORINC := _Super:normalizeType(BRA->BRA_HORINC,self:getValue("inclusionTime")) /* Column BRA_HORINC */
        BRA->BRA_IDEEXC := _Super:normalizeType(BRA->BRA_IDEEXC,self:getValue("executerId")) /* Column BRA_IDEEXC */
        BRA->BRA_IDEREE := _Super:normalizeType(BRA->BRA_IDEREE,self:getValue("refundId")) /* Column BRA_IDEREE */
        BRA->BRA_IDVLRP := _Super:normalizeType(BRA->BRA_IDVLRP,self:getValue("presetValueIdent")) /* Column BRA_IDVLRP */
        BRA->BRA_INAVIV := _Super:normalizeType(BRA->BRA_INAVIV,self:getValue("newborn")) /* Column BRA_INAVIV */
        BRA->BRA_INDACI := _Super:normalizeType(BRA->BRA_INDACI,self:getValue("indicAccident")) /* Column BRA_INDACI */
        BRA->BRA_MATRIC := _Super:normalizeType(BRA->BRA_MATRIC,self:getValue("registration")) /* Column BRA_MATRIC */
        BRA->BRA_MOTSAI := _Super:normalizeType(BRA->BRA_MOTSAI,self:getValue("outflowType")) /* Column BRA_MOTSAI */
        BRA->BRA_NMGOPE := _Super:normalizeType(BRA->BRA_NMGOPE,self:getValue("operatorFormNumber")) /* Column BRA_NMGOPE */
        BRA->BRA_NMGPRE := _Super:normalizeType(BRA->BRA_NMGPRE,self:getValue("providerFormNumber")) /* Column BRA_NMGPRE */
        BRA->BRA_NMGPRI := _Super:normalizeType(BRA->BRA_NMGPRI,self:getValue("mainFormNumb")) /* Column BRA_NMGPRI */
        BRA->BRA_OREVAT := _Super:normalizeType(BRA->BRA_OREVAT,self:getValue("eventOrigin")) /* Column BRA_OREVAT */
        BRA->BRA_PROCES := _Super:normalizeType(BRA->BRA_PROCES,self:getValue("processed")) /* Column BRA_PROCES */
        BRA->BRA_REGINT := _Super:normalizeType(BRA->BRA_REGINT,self:getValue("hospRegime")) /* Column BRA_REGINT */
        BRA->BRA_RGOPIN := _Super:normalizeType(BRA->BRA_RGOPIN,self:getValue("ansRecordNumber")) /* Column BRA_RGOPIN */
        BRA->BRA_ROBOID := _Super:normalizeType(BRA->BRA_ROBOID,self:getValue("roboId")) /* Column BRA_ROBOID */

        BRA->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound

Method setProcessing() Class CenDaoBra

    Local cQuery := ""
    Local lFound := .F.

    If self:cDB <> POSTGRES

        If self:cDB $ MSSQL
            cQuery := " UPDATE TOP(1) "
        Else
            cQuery := " UPDATE "

        EndIf

        cQuery += " " + RetSqlName('BRA') + " "
        cQuery += " SET "
        cQuery += " BRA_PROCES = '" + PROCESSING + "' "
        cQuery += " , BRA_ROBOID='"+self:toString(self:getValue("processId"))+"' "
        cQuery += " , BRA_ROBOHR = '" + DToS(Date()) + " " + Time() + "' "
        cQuery += " WHERE 1=1 "
        cQuery += " AND BRA_FILIAL = '" + xFilial( 'BRA' ) + "' "
        cQuery += " AND BRA_PROCES <> '" + PROCESSED + "' "
        cQuery += " AND BRA_ROBOID = '' "

        If (self:cDB $ "ORACLE")
            cQuery += "	AND ROWNUM = 1 "
        EndIf

        cQuery += " AND D_E_L_E_T_ = ' ' "

    Else
        cQuery := " UPDATE " + RetSqlName('BRA') + " SET "
        cQuery += " BRA_PROCES = '" + PROCESSING + "' "
        cQuery += " , BRA_ROBOID='"+self:toString(self:getValue("processId"))+"' "
        cQuery += " , BRA_ROBOHR = '" + DToS(Date()) + " " + Time() + "' "
        cQuery += " WHERE R_E_C_N_O_ = (SELECT R_E_C_N_O_ FROM  " + RetSqlName('BRA') + " WHERE  "
        cQuery += " BRA_FILIAL = '" + xFilial( 'BRA' ) + "' "
        cQuery += " AND BRA_PROCES <> '" + PROCESSED + "' "
        cQuery += " AND BRA_ROBOID = '' "
        cQuery += " AND D_E_L_E_T_ = ' ' "
        cQuery += "	LIMIT 1 )"

    EndIf

    self:setQuery(cQuery)
    lFound := self:execStatement()

Return lFound

Method getMessage() Class CenDaoBra

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BRA') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND BRA_PROCES = '" + PROCESSING + "' "
    cQuery += " AND BRA_ROBOID ='"+self:toString(self:getValue("processId"))+"' "

    self:setQuery(cQuery)
    lFound := self:executaQuery()
    If lFound
        BRA->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

return lFound

Method setEndProc(nRecno) Class CenDaoBra

    Local cQuery := ""
    Local lFound := .F.

    Default nRecno := 0

    If self:cDB <> POSTGRES

        If self:cDB $ MSSQL
            cQuery := " UPDATE TOP(1) "
        Else
            cQuery := " UPDATE "

        EndIf
        cQuery += " " + RetSqlName('BRA') + " "
        cQuery += " SET "
        cQuery += " BRA_PROCES = '" + PROCESSED + "' "
        cQuery += " WHERE 1=1 "
        cQuery += " AND R_E_C_N_O_ = '" + AllTrim(Str(nRecno)) + "' "

        If (self:cDB $ "ORACLE")
            cQuery += "	AND ROWNUM = 1 "
        EndIf

    Else
        cQuery := " UPDATE " + RetSqlName('BRA') + " SET "
        cQuery += " BRA_PROCES = '" + PROCESSED + "' "
        cQuery += " WHERE R_E_C_N_O_ = (SELECT R_E_C_N_O_ FROM  " + RetSqlName('BRA') + " "
        cQuery += " WHERE 1=1 "
        cQuery += " AND R_E_C_N_O_ = '" + AllTrim(Str(nRecno)) + "' "
        cQuery += "	LIMIT 1 )"

    EndIf

    self:setQuery(cQuery)
    lFound := self:execStatement()

Return lFound

Method setExpired() Class CenDaoBra

    Local cQuery := ""
    Local lFound := .F.

    cQuery := " UPDATE "
    cQuery += " " + RetSqlName('BRA') + " "
    cQuery += " SET "
    cQuery += " BRA_ROBOID = '' "
    cQuery += " ,BRA_PROCES = '" + PROCESSING + "' "
    cQuery += " WHERE 1=1 "
    cQuery += " AND BRA_ROBOID <> '' "
    cQuery += " AND BRA_PROCES = '" + PROCESSING + "' "
    cQuery += " AND BRA_ROBOHR <= '" + SubMinutos(Date(),Time(),2) + "' "
    cQuery += " AND BRA_ROBOHR <> ' ' "
    cQuery += " AND D_E_L_E_T_ = ' ' "

    self:setQuery(cQuery)
    lFound := self:execStatement()
Return lFound

Function SubMinutos(dData, cHora, nSubMinutes)
    Local nSecsInADay := 86400
    Local nHourInSec  := 0
    Local nHour  := 0
    Local nMinute  := 0
    Local nSeconds  := 0
    Local nSubSeconds := 0
    Local cResult := ""

    Default dData := Date()
    Default cHora := Time()
    Default nSubMinutes := 2

    nHour  := Val(SubStr(cHora, 1, 2))
    nMinute  := Val(SubStr(cHora, 4, 2))
    nSeconds  := Val(SubStr(cHora, 7, 2))

    nHourInSec := (nHour * 60 * 60) + (nMinute * 60) + nSeconds
    nSubSeconds := nSubMinutes * 60
    nSubInSec := nHourInSec - nSubSeconds

    If nSubInSec < 0
        dData := dData - 1
        nSubInSec := nSecsInADay + nSubInSec
    EndIf

    nHora := int(nSubInSec / 60 / 60)
    nMinutos :=  Int(((nSubInSec / 60 / 60) - nHora)*60)
    nSegundos := nSubInSec - ( (nHora * 60 * 60) + (nMinutos * 60) )
    If nSegundos >= 60
        nMinutos++
        nSegundos := 0
    EndIf

    cResult := DtoS(dData) + " " + AllTrim(StrZero(nHora,2)) + ":" + AllTrim(StrZero(nMinutos,2)) + ":" + AllTrim(StrZero(nSegundos,2))
Return cResult

Method GetProcess(cIdProc) Class CenDaoBRA

    Local cQuery    := ''
    Local lFound    := .F.
    Default cIdProc := ''

    cQuery := " SELECT  "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BRA') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	BRA_FILIAL = '" + xFilial("BRA") + "' "
    cQuery += " AND BRA_ROBOID = '"+ AllTrim(Str(cIdProc)) +"' "
    cQuery += " AND BRA_PROCES = '" + PROCESSED + "' "
    cQuery += " AND D_E_L_E_T_ = ' ' "

    self:setQuery(cQuery)
    lFound := self:executaQuery()
    If lFound
        BRA->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

Return lFound
