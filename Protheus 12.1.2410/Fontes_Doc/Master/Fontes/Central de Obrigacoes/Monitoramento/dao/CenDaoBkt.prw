#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2
#Define PROCESSING '0'
#Define PROCESSED '1'
#Define MSSQL     "MSSQL"
#Define POSTGRES  "POSTGRES"
#Define ORACLE    "ORACLE"

Class CenDaoBkt from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method commit()
    Method delete()
    Method bscChaPrim()
    Method bscCodPac()
    Method setProcessing()
    Method getMessage()
    Method setEndProc(nRecno)
    Method setExpired()
    Method atuCodLote()
    Method delLote()

EndClass

Method New(aFields) Class CenDaoBkt
    _Super:New(aFields)
    self:cAlias := "BKT"
    self:cfieldOrder := "BKT_ANO,BKT_CDCOMP,BKT_CDOBRI,BKT_CDPRIT,BKT_CDTBIT,BKT_CODOPE,BKT_CODPRO,BKT_CODTAB,BKT_DTPRGU,BKT_LOTE,BKT_NMGOPE"
Return self

Method buscar() Class CenDaoBkt
    Local lFound := .F.
    lFound := _Super:buscar()
    If lFound
        BKT->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoBkt
    Local lFound := .F.
    if self:bscChaPrim()
        lFound := _Super:delete()
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoBkt

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BKT') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	BKT_FILIAL = '" + xFilial("BKT") + "' "

    cQuery += " AND BKT_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND BKT_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND BKT_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND BKT_CDPRIT = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("itemProCode")))
    cQuery += " AND BKT_CDTBIT = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("itemTableCode")))
    cQuery += " AND BKT_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BKT_CODPRO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("procedureCode")))
    cQuery += " AND BKT_CODTAB = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("tableCode")))
    cQuery += " AND BKT_DTPRGU = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("formProcDt")))
    cQuery += " AND BKT_LOTE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("batchCode")))
    cQuery += " AND BKT_NMGOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorFormNumber")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()

return lFound

Method commit(lInclui) Class CenDaoBkt

    Default lInclui := .F.

    If BKT->(RecLock("BKT",lInclui))

        BKT->BKT_FILIAL := xFilial("BKT")
        If lInclui

            BKT->BKT_ANO := _Super:normalizeType(BKT->BKT_ANO,self:getValue("referenceYear")) /* Column BKT_ANO */
            BKT->BKT_CDCOMP := _Super:normalizeType(BKT->BKT_CDCOMP,self:getValue("commitmentCode")) /* Column BKT_CDCOMP */
            BKT->BKT_CDOBRI := _Super:normalizeType(BKT->BKT_CDOBRI,self:getValue("requirementCode")) /* Column BKT_CDOBRI */
            BKT->BKT_CDPRIT := _Super:normalizeType(BKT->BKT_CDPRIT,self:getValue("itemProCode")) /* Column BKT_CDPRIT */
            BKT->BKT_CDTBIT := _Super:normalizeType(BKT->BKT_CDTBIT,self:getValue("itemTableCode")) /* Column BKT_CDTBIT */
            BKT->BKT_CODOPE := _Super:normalizeType(BKT->BKT_CODOPE,self:getValue("operatorRecord")) /* Column BKT_CODOPE */
            BKT->BKT_CODPRO := _Super:normalizeType(BKT->BKT_CODPRO,self:getValue("procedureCode")) /* Column BKT_CODPRO */
            BKT->BKT_CODTAB := _Super:normalizeType(BKT->BKT_CODTAB,self:getValue("tableCode")) /* Column BKT_CODTAB */
            BKT->BKT_DTPRGU := _Super:normalizeType(BKT->BKT_DTPRGU,self:getValue("formProcDt")) /* Column BKT_DTPRGU */
            BKT->BKT_LOTE := _Super:normalizeType(BKT->BKT_LOTE,self:getValue("batchCode")) /* Column BKT_LOTE */
            BKT->BKT_NMGOPE := _Super:normalizeType(BKT->BKT_NMGOPE,self:getValue("operatorFormNumber")) /* Column BKT_NMGOPE */
            BKT->BKT_STATUS := _Super:normalizeType(BKT->BKT_STATUS,self:getValue("status")) /* Column BKT_STATUS */

        EndIf

        BKT->BKT_QTPRPC := _Super:normalizeType(BKT->BKT_QTPRPC,self:getValue("packageQuantity")) /* Column BKT_QTPRPC */

        BKT->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} bscCodPac
    Busca movimentacoes baseadas no Tipo de Guia.

    @type  Class
    @author Hermiro Júnior
    @since 04/12/2019
/*/
//------------------------------------------------------------------------------------------
Method bscCodPac() Class CenDaoBkt

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BKT') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	BKT_FILIAL = '" + xFilial("BKT") + "' "
    cQuery += " AND BKT_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BKT_NMGOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorFormNumber")))
    cQuery += " AND BKT_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND BKT_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND BKT_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND BKT_LOTE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("batchCode")))
    cQuery += " AND BKT_DTPRGU = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("formProcDt")))
    cQuery 	+= "AND ((BKT_CDTBIT='18') OR (BKT_CDTBIT='19') OR (BKT_CDTBIT='20') OR (BKT_CDTBIT='22')) "
    cQuery += " AND D_E_L_E_T_ = ' ' "

    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()
    If lFound
        BKT->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

return lFound

Method setProcessing() Class CenDaoBKT

    Local cQuery := ""
    Local lFound := .F.

    If self:cDB <> POSTGRES

        If self:cDB $ MSSQL
            cQuery := " UPDATE TOP(1) "
        Else
            cQuery := " UPDATE "

        EndIf

        cQuery += " " + RetSqlName('BKT') + " "
        cQuery += " SET "
        cQuery += " BKT_PROCES = '" + PROCESSING + "' "
        cQuery += " , BKT_ROBOID='"+self:toString(self:getValue("processId"))+"' "
        cQuery += " , BKT_ROBOHR = '" + DToS(Date()) + " " + Time() + "' "
        cQuery += " WHERE 1=1 "
        cQuery += " AND BKT_FILIAL = '" + xFilial( 'BKT' ) + "' "
        cQuery += " AND BKT_PROCES <> '" + PROCESSED + "' "
        cQuery += " AND BKT_ROBOID = '' "

        If (self:cDB $ "ORACLE")
            cQuery += "	AND ROWNUM = 1 "
        EndIf

        cQuery += " AND D_E_L_E_T_ = ' ' "

    Else
        cQuery := " UPDATE " + RetSqlName('BKT') + " SET "
        cQuery += " BKT_PROCES = '" + PROCESSING + "' "
        cQuery += " , BKT_ROBOID='"+self:toString(self:getValue("processId"))+"' "
        cQuery += " , BKT_ROBOHR = '" + DToS(Date()) + " " + Time() + "' "
        cQuery += " WHERE R_E_C_N_O_ = (SELECT R_E_C_N_O_ FROM  " + RetSqlName('BKT') + " WHERE  "
        cQuery += " BKT_FILIAL = '" + xFilial( 'BKT' ) + "' "
        cQuery += " AND BKT_PROCES <> '" + PROCESSED + "' "
        cQuery += " AND BKT_ROBOID = '' "
        cQuery += " AND D_E_L_E_T_ = ' ' "
        cQuery += "	LIMIT 1 )"

    EndIf

    self:setQuery(cQuery)
    lFound := self:execStatement()

Return lFound

Method getMessage() Class CenDaoBKT

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BKT') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND BKT_PROCES = '" + PROCESSING + "' "
    cQuery += " AND BKT_ROBOID ='"+self:toString(self:getValue("processId"))+"' "

    self:setQuery(cQuery)
    lFound := self:executaQuery()
    If lFound
        BKT->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

return lFound

Method setEndProc(nRecno) Class CenDaoBKT

    Local cQuery := ""
    Local lFound := .F.

    Default nRecno := 0

    If self:cDB <> POSTGRES

        If self:cDB $ MSSQL
            cQuery := " UPDATE TOP(1) "
        Else
            cQuery := " UPDATE "

        EndIf
        cQuery += " " + RetSqlName('BKT') + " "
        cQuery += " SET "
        cQuery += " BKT_PROCES = '" + PROCESSED + "' "
        cQuery += " WHERE 1=1 "
        cQuery += " AND R_E_C_N_O_ = '" + AllTrim(Str(nRecno)) + "' "

        If (self:cDB $ "ORACLE")
            cQuery += "	AND ROWNUM = 1 "
        EndIf

    Else
        cQuery := " UPDATE " + RetSqlName('BKT') + " SET "
        cQuery += " BKT_PROCES = '" + PROCESSED + "' "
        cQuery += " WHERE R_E_C_N_O_ = (SELECT R_E_C_N_O_ FROM  " + RetSqlName('BKT') + " "
        cQuery += " WHERE 1=1 "
        cQuery += " AND R_E_C_N_O_ = '" + AllTrim(Str(nRecno)) + "' "
        cQuery += "	LIMIT 1 )"

    EndIf

    self:setQuery(cQuery)
    lFound := self:execStatement()

Return lFound

Method setExpired() Class CenDaoBKT

    Local cQuery := ""
    Local lFound := .F.

    cQuery := " UPDATE "
    cQuery += " " + RetSqlName('BKT') + " "
    cQuery += " SET "
    cQuery += " BKT_ROBOID = '' "
    cQuery += " ,BKT_PROCES = '" + PROCESSING + "' "
    cQuery += " WHERE 1=1 "
    cQuery += " AND BKT_ROBOID <> '' "
    cQuery += " AND BKT_PROCES = '" + PROCESSING + "' "
    cQuery += " AND BKT_ROBOHR <= '" + SubMinutos(Date(),Time(),2) + "' "
    cQuery += " AND BKT_ROBOHR <> ' ' "
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
Method atuCodLote() Class CenDaoBkt

    Local cQuery := ""
    Local lFound := .F.

    cQuery += " UPDATE "+RetSqlName('BKT')+" SET BKT_LOTE = ? FROM "+RetSqlName('BKT')+" BKT "
    aAdd(self:aMapBuilder, self:toString(self:getValue("batchCode")))
    cQuery += " INNER JOIN "+RetSqlName('BKR')+" BKR "
    cQuery += " ON  BKR.BKR_FILIAL = '"+xFilial("BKR")+"' "
    cQuery += " AND BKR.BKR_CODOPE = BKT.BKT_CODOPE "
    cQuery += " AND BKR.BKR_NMGOPE = BKT.BKT_NMGOPE "
    cQuery += " AND BKR.BKR_CDOBRI = BKT.BKT_CDOBRI "
    cQuery += " AND BKR.BKR_ANO    = BKT.BKT_ANO "
    cQuery += " AND BKR.BKR_CDCOMP = BKT.BKT_CDCOMP "
    cQuery += " AND BKR.BKR_LOTE   = ? "
    cQuery += " AND BKR.BKR_DTPRGU = BKT.BKT_DTPRGU "
    aAdd(self:aMapBuilder, self:toString(self:getValue("batchCode")))
    cQuery += " AND BKR.D_E_L_E_T_ = ' ' "

    cQuery += " WHERE "
    cQuery += " BKT.BKT_FILIAL = '"+xFilial("BKT")+"' "
    cQuery += " AND BKT.BKT_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BKT.BKT_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND BKT.BKT_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND BKT.BKT_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND BKT.BKT_LOTE = ' ' "
    cQuery += " AND BKT.D_E_L_E_T_ = ' ' "

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
Method delLote() Class CenDaoBkt

    Local cSql      := ""
    Local lFound    := .F.

    cSql := "UPDATE " + RetSqlName("BKT") + " "
    cSql += " SET BKT_LOTE = '', BKT_STATUS = '2'  "
    cSql += " WHERE 1=1 "
    cSql += " AND BKT_FILIAL = '" + xFilial("BKT") + "' "
    cSql += " AND BKT_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BKT_ANO")))
    cSql += " AND BKT_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BKT_CDCOMP")))
    cSql += " AND BKT_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BKT_CDOBRI")))
    cSql += " AND BKT_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BKT_CODOPE")))
    cSql += " AND BKT_LOTE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BKT_LOTE")))
    cSql += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')

    self:setQuery(self:queryBuilder(cSql))
    lFound := self:execStatement()

Return lFound