#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2
#Define PROCESSING '0'
#Define PROCESSED '1'
#Define MSSQL     "MSSQL"
#Define POSTGRES  "POSTGRES"
#Define ORACLE    "ORACLE"

Class CenDaoBks from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method commit()
    Method delete()
    Method bscChaPrim()
    Method bscVlrPag(aDatProc)
    Method bscLastEve(aDatProc)
    Method bscTotCop()
    Method bscTotInf()
    Method bscTotFor()
    Method qtdGrupo()
    Method qtdProcGui()
    Method setProcessing()
    Method getMessage()
    Method setEndProc(nRecno)
    Method setExpired()
    Method atuCodLote()
    Method qtdProcFa()
    Method contGuia()
    Method delLote()
    Method VerCritBKR(cOperadora,cObri,cAno,cComp,cGuia)

EndClass

Method New(aFields) Class CenDaoBks
    _Super:New(aFields)
    self:cAlias := "BKS"
    self:cfieldOrder := "BKS_CODGRU,BKS_CODOPE,BKS_CODPRO,BKS_CODTAB,BKS_DTPRGU,BKS_LOTE,BKS_NMGOPE,BKS_ANO,BKS_CDCOMP,BKS_CDDENT,BKS_CDFACE,BKS_CDOBRI,BKS_CDREGI"
Return self

Method buscar() Class CenDaoBks
    Local lFound := .F.
    lFound := _Super:buscar()
    If lFound
        BKS->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoBks
    Local lFound := .F.
    if self:bscChaPrim()
        lFound := _Super:delete()
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoBks

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BKS') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	BKS_FILIAL = '" + xFilial("BKS") + "' "

    cQuery += " AND BKS_CODGRU = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("procedureGroup")))
    cQuery += " AND BKS_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BKS_CODPRO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("procedureCode")))
    cQuery += " AND BKS_CODTAB = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("tableCode")))
    cQuery += " AND BKS_DTPRGU = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("formProcDt")))
    cQuery += " AND BKS_LOTE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("batchCode")))
    cQuery += " AND BKS_NMGOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorFormNumber")))
    cQuery += " AND BKS_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND BKS_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND BKS_CDDENT = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("toothCode")))
    cQuery += " AND BKS_CDFACE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("toothFaceCode")))
    cQuery += " AND BKS_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND BKS_CDREGI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("regionCode")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()

return lFound

Method commit(lInclui) Class CenDaoBks

    local cForEnv := GetAdvFVal("B7Z","B7Z_FORENV",xFilial("B7Z")+self:getValue("tableCode")+self:getValue("procedureCode"),1,"")
    local cCodGru := Iif(cForEnv=='2',;
        GetAdvFVal("B7Z","B7Z_CODGRU",xFilial("B7Z")+self:getValue("tableCode")+self:getValue("procedureCode"),1,""),;
        '')

    Default lInclui := .F.

    If BKS->(RecLock("BKS",lInclui))

        BKS->BKS_FILIAL := xFilial("BKS")
        If lInclui

            BKS->BKS_CODGRU := cCodGru //_Super:normalizeType(BKS->BKS_CODGRU,self:getValue("procedureGroup")) /* Column BKS_CODGRU */
            BKS->BKS_CODOPE := _Super:normalizeType(BKS->BKS_CODOPE,self:getValue("operatorRecord")) /* Column BKS_CODOPE */
            BKS->BKS_CODPRO := _Super:normalizeType(BKS->BKS_CODPRO,self:getValue("procedureCode")) /* Column BKS_CODPRO */
            BKS->BKS_CODTAB := _Super:normalizeType(BKS->BKS_CODTAB,self:getValue("tableCode")) /* Column BKS_CODTAB */
            BKS->BKS_DTPRGU := _Super:normalizeType(BKS->BKS_DTPRGU,self:getValue("formProcDt")) /* Column BKS_DTPRGU */
            BKS->BKS_LOTE := _Super:normalizeType(BKS->BKS_LOTE,self:getValue("batchCode")) /* Column BKS_LOTE */
            BKS->BKS_NMGOPE := _Super:normalizeType(BKS->BKS_NMGOPE,self:getValue("operatorFormNumber")) /* Column BKS_NMGOPE */
            BKS->BKS_ANO := _Super:normalizeType(BKS->BKS_ANO,self:getValue("referenceYear")) /* Column BKS_ANO */
            BKS->BKS_CDCOMP := _Super:normalizeType(BKS->BKS_CDCOMP,self:getValue("commitmentCode")) /* Column BKS_CDCOMP */
            BKS->BKS_CDDENT := _Super:normalizeType(BKS->BKS_CDDENT,self:getValue("toothCode")) /* Column BKS_CDDENT */
            BKS->BKS_CDFACE := _Super:normalizeType(BKS->BKS_CDFACE,self:getValue("toothFaceCode")) /* Column BKS_CDFACE */
            BKS->BKS_CDOBRI := _Super:normalizeType(BKS->BKS_CDOBRI,self:getValue("requirementCode")) /* Column BKS_CDOBRI */
            BKS->BKS_CDREGI := _Super:normalizeType(BKS->BKS_CDREGI,self:getValue("regionCode")) /* Column BKS_CDREGI */

        EndIf

        BKS->BKS_STATUS := _Super:normalizeType(BKS->BKS_STATUS,self:getValue("status")) /* Column BKS_STATUS */
        BKS->BKS_CNPJFR := _Super:normalizeType(BKS->BKS_CNPJFR,self:getValue("supplierCnpj")) /* Column BKS_CNPJFR */
        BKS->BKS_PACOTE := _Super:normalizeType(BKS->BKS_PACOTE,self:getValue("package")) /* Column BKS_PACOTE */
        BKS->BKS_QTDINF := _Super:normalizeType(BKS->BKS_QTDINF,self:getValue("enteredQuantity")) /* Column BKS_QTDINF */
        BKS->BKS_QTDPAG := _Super:normalizeType(BKS->BKS_QTDPAG,self:getValue("quantityPaid")) /* Column BKS_QTDPAG */
        BKS->BKS_VLPGPR := _Super:normalizeType(BKS->BKS_VLPGPR,self:getValue("procedureValuePaid")) /* Column BKS_VLPGPR */
        BKS->BKS_VLRCOP := _Super:normalizeType(BKS->BKS_VLRCOP,self:getValue("coPaymentValue")) /* Column BKS_VLRCOP */
        BKS->BKS_VLRGLO := _Super:normalizeType(BKS->BKS_VLRGLO,self:getValue("disallVl")) /* Column BKS_VLRGLO */
        BKS->BKS_VLRINF := _Super:normalizeType(BKS->BKS_VLRINF,self:getValue("valueEntered")) /* Column BKS_VLRINF */
        BKS->BKS_VLRPGF := _Super:normalizeType(BKS->BKS_VLRPGF,self:getValue("valuePaidSupplier")) /* Column BKS_VLRPGF */
        BKS->BKS_TIPEVE := _Super:normalizeType(BKS->BKS_TIPEVE,self:getValue("eventType")) /* Column BKS_TIPEVE */

        BKS->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} bscQtdPag
    Retorna os valores de uma transacao ja paga

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method bscVlrPag(aDatProc) Class CenDaoBKS

    Local lFound := .F.
    Local cQuery := ""
    Local nX     := 0
    Local cStr   := ""

    Default aDatProc := {}

    for nX := 1 to len(aDatProc)
        cStr += "'" + aDatProc[nX] + "'" + iif(nX < len(aDatProc),",","")
    next

    cQuery := " SELECT BKS_CODGRU, BKS_CODTAB, BKS_CODPRO, BKS_CDDENT, BKS_CDREGI, BKS_CDFACE, SUM(BKS_VLPGPR) AS BKS_VLPGPR, 0 AS RECNO, "
    cQuery += " ' ' AS BKS_CODOPE, ' ' AS BKS_DTPRGU, ' ' AS BKS_LOTE, ' ' AS BKS_NMGOPE, ' ' AS BKS_ANO, ' ' AS BKS_CDCOMP, "
    cQuery += " ' ' AS BKS_CDOBRI, ' ' AS BKS_CNPJFR, ' ' AS BKS_PACOTE, ' ' AS BKS_STATUS, 0 AS BKS_QTDINF, 0 AS BKS_QTDPAG, 0 AS BKS_VLRCOP, "
    cQuery += " 0 AS BKS_VLRGLO, 0 AS BKS_VLRINF, 0 AS BKS_VLRPGF, ' ' AS BKS_TIPEVE "

    cQuery += " FROM " + RetSqlName('BKS') + " BKS "
    cQuery += " INNER JOIN " + RetSqlName('BKR') + " BKR "
    cQuery += "    ON BKR_FILIAL = '" + xFilial("BKR") + "' "
    cQuery += "     AND	BKR_NMGOPE = BKS_NMGOPE "
    cQuery += "	    AND BKR_CDOBRI = BKS_CDOBRI "
    cQuery += "	    AND BKR_ANO    = BKS_ANO "
    cQuery += "	    AND BKR_CDCOMP = BKS_CDCOMP "
    cQuery += "	    AND BKR_LOTE   = BKS_LOTE "
    cQuery += "	    AND BKR_DTPRGU = BKS_DTPRGU "
    if !Empty(cStr)
        cQuery += "	    AND BKR_DTPRGU NOT IN ("+cStr+") "
    endIf
    cQuery += "	    AND BKR_DTPAGT <> ' ' "
    cQuery += " 	AND BKR.D_E_L_E_T_ = ' ' "

    cQuery += " WHERE BKS_FILIAL = '" + xFilial("BKS") + "' "
    cQuery += " AND BKS_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BKS_NMGOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorFormNumber")))
    cQuery += " AND BKS_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND BKS.D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY BKS_CODGRU, BKS_CODTAB, BKS_CODPRO, BKS_CDDENT, BKS_CDREGI, BKS_CDFACE "

    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()

return lFound


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} bscLastEve
    Retorna os valores de uma transacao ja paga

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method bscLastEve(aDatProc) Class CenDaoBks

    Local lFound := .F.
    Local cQuery := ""
    Local nX     := 0
    Local cStr   := ""

    Default aDatProc := {}

    for nX := 1 to len(aDatProc)
        cStr += "'" + aDatProc[nX] + "'" + iif(nX < len(aDatProc),",","")
    next

    cQuery := " SELECT BKS_CODGRU, BKS_CODOPE, BKS_CODPRO, BKS_CODTAB, BKS_DTPRGU, BKS_LOTE, BKS_NMGOPE, BKS_ANO, BKS_CDCOMP, BKS_CDDENT, BKS_CDFACE, "
    cQuery += " BKS_CDOBRI, BKS_CDREGI, BKS_CNPJFR, BKS_PACOTE, BKS_QTDINF, BKS_QTDPAG, BKS_VLPGPR, BKS_VLRCOP, BKS_VLRGLO, BKS_VLRINF, BKS_VLRPGF, "
    cQuery += " BKS_TIPEVE, BKS_STATUS, 0 AS RECNO "
    cQuery += " FROM " + RetSqlName('BKS') + " BKS "
    cQuery += " INNER JOIN " + RetSqlName('BKR') + " BKR "
    cQuery += "    ON BKR_FILIAL = '" + xFilial("BKR") + "' "
    cQuery += "     AND	BKR_NMGOPE = BKS_NMGOPE "
    cQuery += "	    AND BKR_CDOBRI = BKS_CDOBRI "
    cQuery += "	    AND BKR_ANO    = BKS_ANO "
    cQuery += "	    AND BKR_CDCOMP = BKS_CDCOMP "
    cQuery += "	    AND BKR_LOTE   = BKS_LOTE "
    cQuery += "	    AND BKR_DTPRGU = BKS_DTPRGU "
    if !Empty(cStr)
        cQuery += "	    AND BKR_DTPRGU NOT IN ("+cStr+") "
    endIf
    cQuery += " 	AND BKR.D_E_L_E_T_ = ' ' "

    cQuery += " WHERE BKS_FILIAL = '" + xFilial("BKS") + "' "
    cQuery += " AND BKS_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BKS_NMGOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorFormNumber")))
    cQuery += " AND BKS_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND BKS.D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY BKS_CODGRU, BKS_CODTAB, BKS_CODPRO, BKS_CDDENT, BKS_CDREGI, BKS_CDFACE, BKR_DTPRGU DESC, BKR_DATPRO DESC, BKR_HORPRO DESC "

    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()

return lFound


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} bscTotCop
    Soma o total da co-participação da guia

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method bscTotCop() Class CenDaoBKS

    Local nTotal := 0
    Local cQuery := ""

    cQuery := " SELECT SUM(BKS_VLRCOP)  TOTAL "
    cQuery += " FROM " + RetSqlName('BKS') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	BKS_FILIAL = '" + xFilial("BKS") + "' "
    cQuery += " AND BKS_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BKS_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND BKS_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND BKS_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND BKS_NMGOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorFormNumber")))
    cQuery += " AND BKS_LOTE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("batchCode")))
    cQuery += " AND BKS_DTPRGU = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("formProcDt")))
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY BKS_FILIAL, BKS_CODOPE, BKS_CDOBRI, BKS_ANO, BKS_CDCOMP, BKS_NMGOPE, BKS_LOTE, BKS_DTPRGU "

    self:setQuery(self:queryBuilder(cQuery))
    If self:executaQuery()
        nTotal := (self:getAliasTemp())->TOTAL
    EndIf
    self:fechaQuery()

return nTotal
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} bscTotInf
    Soma o total do Valor informado na guia

    @type  Class
    @author Hermiro Júnior
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method bscTotInf() Class CenDaoBKS

    Local nTotal        := 0
    Local cQuery := ""

    cQuery := " SELECT SUM(BKS_VLRINF)  TOTAL "
    cQuery += " FROM " + RetSqlName('BKS') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	BKS_FILIAL = '" + xFilial("BKS") + "' "
    cQuery += " AND BKS_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BKS_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND BKS_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND BKS_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND BKS_NMGOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorFormNumber")))
    cQuery += " AND BKS_LOTE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("batchCode")))
    cQuery += " AND BKS_DTPRGU = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("formProcDt")))
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY BKS_FILIAL, BKS_CODOPE, BKS_CDOBRI, BKS_ANO, BKS_CDCOMP, BKS_NMGOPE, BKS_LOTE, BKS_DTPRGU "

    self:setQuery(self:queryBuilder(cQuery))
    If self:executaQuery()
        nTotal := (self:getAliasTemp())->TOTAL
    EndIf
    self:fechaQuery()

Return nTotal
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} bscTotFor
    Soma o total do Valor informado na guia

    @type  Class
    @author Hermiro Júnior
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method bscTotFor() Class CenDaoBKS

    Local nTotal        := 0
    Local cQuery := ""

    cQuery := " SELECT SUM(BKS_VLRPGF)  TOTAL "
    cQuery += " FROM " + RetSqlName('BKS') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	BKS_FILIAL = '" + xFilial("BKS") + "' "
    cQuery += " AND BKS_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BKS_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND BKS_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND BKS_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND BKS_NMGOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorFormNumber")))
    cQuery += " AND BKS_LOTE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("batchCode")))
    cQuery += " AND BKS_DTPRGU = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("formProcDt")))
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY BKS_FILIAL, BKS_CODOPE, BKS_CDOBRI, BKS_ANO, BKS_CDCOMP, BKS_NMGOPE, BKS_LOTE, BKS_DTPRGU "

    self:setQuery(self:queryBuilder(cQuery))
    If self:executaQuery()
        nTotal := (self:getAliasTemp())->TOTAL
    EndIf
    self:fechaQuery()

Return nTotal

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} qtdGrupo
    Retorna a quantidade de registros com mesmo grupo

    @type  Class
    @author everton.mateus
    @since 03/12/2019
/*/
//------------------------------------------------------------------------------------------
Method qtdGrupo() Class CenDaoBKS

    Local nTotal := 0
    Local cQuery := ""

    cQuery := " SELECT COUNT(1) TOTAL "
    cQuery += " FROM " + RetSqlName('BKS') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	BKS_FILIAL = '" + xFilial("BKS") + "' "
    cQuery += " AND BKS_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BKS_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND BKS_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND BKS_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND BKS_NMGOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorFormNumber")))
    cQuery += " AND BKS_DTPRGU = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("formProcDt")))
    cQuery += " AND BKS_CODGRU = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("procedureGroup")))
    cQuery += " AND BKS_CODTAB = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("tableCode")))
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY BKS_FILIAL, BKS_CODOPE, BKS_CDOBRI, BKS_ANO, BKS_CDCOMP, BKS_NMGOPE, BKS_DTPRGU, BKS_CODGRU, BKS_CODTAB "

    self:setQuery(self:queryBuilder(cQuery))
    If self:executaQuery()
        nTotal := (self:getAliasTemp())->TOTAL
    EndIf
    self:fechaQuery()

return nTotal

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} qtdProcGui
    Retorna a quantidade de registros com mesmo procedimento

    @type  Class
    @author everton.mateus
    @since 03/12/2019
/*/
//------------------------------------------------------------------------------------------
Method qtdProcGui() Class CenDaoBKS

    Local nTotal := 0
    Local cQuery := ""

    cQuery := " SELECT COUNT(1) TOTAL "
    cQuery += " FROM " + RetSqlName('BKS') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	BKS_FILIAL = '" + xFilial("BKS") + "' "
    cQuery += " AND BKS_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BKS_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND BKS_NMGOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorFormNumber")))
    cQuery += " AND BKS_CODGRU = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("procedureGroup")))
    cQuery += " AND BKS_CODTAB = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("tableCode")))
    cQuery += " AND BKS_CODPRO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("procedureCode")))
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY BKS_FILIAL, BKS_CODOPE, BKS_CDOBRI,  BKS_NMGOPE,  BKS_CODGRU, BKS_CODTAB, BKS_CODPRO "

    self:setQuery(self:queryBuilder(cQuery))
    If self:executaQuery()
        nTotal := (self:getAliasTemp())->TOTAL
    EndIf
    self:fechaQuery()

return nTotal

Method setProcessing() Class CenDaoBKS

    Local cQuery := ""
    Local lFound := .F.

    If self:cDB <> POSTGRES

        If self:cDB $ MSSQL
            cQuery := " UPDATE TOP(1) "
        Else
            cQuery := " UPDATE "

        EndIf

        cQuery += " " + RetSqlName('BKS') + " "
        cQuery += " SET "
        cQuery += " BKS_PROCES = '" + PROCESSING + "' "
        cQuery += " , BKS_ROBOID='"+self:toString(self:getValue("processId"))+"' "
        cQuery += " , BKS_ROBOHR = '" + DToS(Date()) + " " + Time() + "' "
        cQuery += " WHERE 1=1 "
        cQuery += " AND BKS_FILIAL = '" + xFilial( 'BKS' ) + "' "
        cQuery += " AND BKS_PROCES <> '" + PROCESSED + "' "
        cQuery += " AND BKS_ROBOID = '' "

        If (self:cDB $ "ORACLE")
            cQuery += "	AND ROWNUM = 1 "
        EndIf

        cQuery += " AND D_E_L_E_T_ = ' ' "

    Else
        cQuery := " UPDATE " + RetSqlName('BKS') + " SET "
        cQuery += " BKS_PROCES = '" + PROCESSING + "' "
        cQuery += " , BKS_ROBOID='"+self:toString(self:getValue("processId"))+"' "
        cQuery += " , BKS_ROBOHR = '" + DToS(Date()) + " " + Time() + "' "
        cQuery += " WHERE R_E_C_N_O_ = (SELECT R_E_C_N_O_ FROM  " + RetSqlName('BKS') + " WHERE  "
        cQuery += " BKS_FILIAL = '" + xFilial( 'BKS' ) + "' "
        cQuery += " AND BKS_PROCES <> '" + PROCESSED + "' "
        cQuery += " AND BKS_ROBOID = '' "
        cQuery += " AND D_E_L_E_T_ = ' ' "
        cQuery += "	LIMIT 1 )"

    EndIf

    self:setQuery(cQuery)
    lFound := self:execStatement()

Return lFound

Method getMessage() Class CenDaoBKS

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BKS') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND BKS_PROCES = '" + PROCESSING + "' "
    cQuery += " AND BKS_ROBOID ='"+self:toString(self:getValue("processId"))+"' "

    self:setQuery(cQuery)
    lFound := self:executaQuery()
    If lFound
        BKS->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

return lFound

Method setEndProc(nRecno) Class CenDaoBKS

    Local cQuery := ""
    Local lFound := .F.

    Default nRecno := 0

    If self:cDB <> POSTGRES

        If self:cDB $ MSSQL
            cQuery := " UPDATE TOP(1) "
        Else
            cQuery := " UPDATE "

        EndIf
        cQuery += " " + RetSqlName('BKS') + " "
        cQuery += " SET "
        cQuery += " BKS_PROCES = '" + PROCESSED + "' "
        cQuery += " WHERE 1=1 "
        cQuery += " AND R_E_C_N_O_ = '" + AllTrim(Str(nRecno)) + "' "

        If (self:cDB $ "ORACLE")
            cQuery += "	AND ROWNUM = 1 "
        EndIf

    Else
        cQuery := " UPDATE " + RetSqlName('BKS') + " SET "
        cQuery += " BKS_PROCES = '" + PROCESSED + "' "
        cQuery += " WHERE R_E_C_N_O_ = (SELECT R_E_C_N_O_ FROM  " + RetSqlName('BKS') + " "
        cQuery += " WHERE 1=1 "
        cQuery += " AND R_E_C_N_O_ = '" + AllTrim(Str(nRecno)) + "' "
        cQuery += "	LIMIT 1 )"

    EndIf

    self:setQuery(cQuery)
    lFound := self:execStatement()

Return lFound

Method setExpired() Class CenDaoBKS

    Local cQuery := ""
    Local lFound := .F.

    cQuery := " UPDATE "
    cQuery += " " + RetSqlName('BKS') + " "
    cQuery += " SET "
    cQuery += " BKS_ROBOID = '' "
    cQuery += " ,BKS_PROCES = '" + PROCESSING + "' "
    cQuery += " WHERE 1=1 "
    cQuery += " AND BKS_ROBOID <> '' "
    cQuery += " AND BKS_PROCES = '" + PROCESSING + "' "
    cQuery += " AND BKS_ROBOHR <= '" + SubMinutos(Date(),Time(),2) + "' "
    cQuery += " AND BKS_ROBOHR <> ' ' "
    cQuery += " AND D_E_L_E_T_ = ' ' "

    self:setQuery(cQuery)
    lFound := self:execStatement()
Return lFound


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} atuCodLote
    Atualiza o numero do lote nas guias

    @type  Class
    @author renan.almeida
    @since 03/12/2019
/*/
//------------------------------------------------------------------------------------------
Method atuCodLote() Class CenDaoBKS

    Local cQuery := ""
    Local lFound := .F.

    cQuery += " UPDATE "+RetSqlName('BKS')+" SET BKS_LOTE = ? FROM "+RetSqlName('BKS')+" BKS "
    aAdd(self:aMapBuilder, self:toString(self:getValue("batchCode")))
    cQuery += " INNER JOIN "+RetSqlName('BKR')+" BKR "
    cQuery += " ON  BKR.BKR_FILIAL = '"+xFilial("BKR")+"' "
    cQuery += " AND BKR.BKR_CODOPE = BKS.BKS_CODOPE "
    cQuery += " AND BKR.BKR_NMGOPE = BKS.BKS_NMGOPE "
    cQuery += " AND BKR.BKR_CDOBRI = BKS.BKS_CDOBRI "
    cQuery += " AND BKR.BKR_ANO    = BKS.BKS_ANO "
    cQuery += " AND BKR.BKR_CDCOMP = BKS.BKS_CDCOMP "
    cQuery += " AND BKR.BKR_LOTE   = ? "
    cQuery += " AND BKR.BKR_DTPRGU = BKS.BKS_DTPRGU "
    aAdd(self:aMapBuilder, self:toString(self:getValue("batchCode")))
    cQuery += " AND BKR.D_E_L_E_T_ = ' ' "

    cQuery += " WHERE "
    cQuery += " BKS.BKS_FILIAL = '"+xFilial("BKS")+"' "
    cQuery += " AND BKS.BKS_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BKS.BKS_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND BKS.BKS_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND BKS.BKS_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND BKS.BKS_LOTE = ' ' "
    cQuery += " AND BKS.D_E_L_E_T_ = ' ' "

    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:execStatement()

Return lFound

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} qtdProcFa
    Retorna se há alguma face diferente para guias

    @type  Class
    @author jose.paulo
    @since 07/07/2020
/*/
//------------------------------------------------------------------------------------------
Method qtdProcFa() Class CenDaoBKS

    Local nTotal := 0
    Local cQuery := ""

    cQuery := " SELECT COUNT(1) TOTAL "
    cQuery += " FROM " + RetSqlName('BKS') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	BKS_FILIAL = '" + xFilial("BKS") + "' "
    cQuery += " AND BKS_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BKS_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND BKS_NMGOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorFormNumber")))
    cQuery += " AND BKS_CODTAB = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("tableCode")))
    cQuery += " AND BKS_CODPRO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("procedureCode")))
    cQuery += " AND BKS_CDDENT = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("toothCode")))
    cQuery += " AND BKS_CDREGI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("regionCode")))
    cQuery += " AND BKS_CDFACE <> ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("toothFaceCode")))


    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY BKS_FILIAL, BKS_CODOPE, BKS_CDOBRI,   BKS_NMGOPE,  BKS_CODTAB, BKS_CODPRO, BKS_CDDENT, BKS_CDREGI, BKS_CDFACE "

    self:setQuery(self:queryBuilder(cQuery))
    If self:executaQuery()
        nTotal := (self:getAliasTemp())->TOTAL
    EndIf
    self:fechaQuery()

return nTotal

Method contGuia() Class CenDaoBKS

    Local nTotal := 0
    Local cQuery

    cQuery := " SELECT COUNT(1) TOTAL "
    cQuery += " FROM " + RetSqlName("BKR")
    cQuery += " WHERE 1=1 "
    cQuery += " AND	BKR_FILIAL = '" + xFilial("BKR") + "' "
    cQuery += " AND BKR_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BKR_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND BKR_NMGOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorFormNumber")))

    cQuery += " AND D_E_L_E_T_ = ' ' "

    self:setQuery(self:queryBuilder(cQuery))
    If self:executaQuery()
        nTotal := (self:getAliasTemp())->TOTAL
    EndIf
    self:fechaQuery()

return nTotal

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} delLote
    Atualiza o status do lote após ele ser deletado na BKW

    @type  Class
    @author vinicius.nicolau
    @since 03/08/2020
/*/
//------------------------------------------------------------------------------------------
Method delLote() Class CenDaoBks

    Local cSql      := ""
    Local lFound    := .F.

    cSql := "UPDATE " + RetSqlName("BKS") + " "
    cSql += " SET BKS_LOTE = '', BKS_STATUS = '2'  "
    cSql += " WHERE 1=1 "
    cSql += " AND BKS_FILIAL = '" + xFilial("BKS") + "' "
    cSql += " AND BKS_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BKS_ANO")))
    cSql += " AND BKS_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BKS_CDCOMP")))
    cSql += " AND BKS_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BKS_CDOBRI")))
    cSql += " AND BKS_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BKS_CODOPE")))
    cSql += " AND BKS_LOTE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BKS_LOTE")))
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
Method VerCritBKR(cOperadora,cObri,cAno,cComp,cGuia) Class CenDaoBks

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
