#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2
#Define PROCESSING '0'
#Define PROCESSED '1'
#Define MSSQL     "MSSQL"
#Define POSTGRES  "POSTGRES"
#Define ORACLE    "ORACLE"

Class CenDaoBvt from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method commit()
    Method delete()
    Method bscChaPrim()
    Method bscUltEve()
    Method bscTotCop()
    Method bscTotPgGui()
    Method qtdGrupo()
    Method qtdProcGui()
    Method setProcessing()
    Method getMessage()
    Method setEndProc(nRecno)
    Method setExpired()
    Method atuCodLote()
    Method delLote()
    Method VerCritBVT(cOperadora,cObri,cAno,cComp,cGuia)

EndClass

Method New(aFields) Class CenDaoBvt
    _Super:New(aFields)
    self:cAlias := "BVT"
    self:cfieldOrder := "BVT_ANO,BVT_CDCOMP,BVT_CDOBRI,BVT_CODGRU,BVT_CODOPE,BVT_CODPRO,BVT_CODTAB,BVT_DTPRGU,BVT_LOTE,BVT_NMGPRE"
Return self

Method buscar() Class CenDaoBvt
    Local lFound := .F.
    lFound := _Super:buscar()
    If lFound
        BVT->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoBvt
    Local lFound := .F.
    if self:bscChaPrim()
        lFound := _Super:delete()
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoBvt

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BVT') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	BVT_FILIAL = '" + xFilial("BVT") + "' "

    cQuery += " AND BVT_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND BVT_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND BVT_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND BVT_CODGRU = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("procedureGroup")))
    cQuery += " AND BVT_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BVT_CODPRO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("procedureCode")))
    cQuery += " AND BVT_CODTAB = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("tableCode")))
    cQuery += " AND BVT_DTPRGU = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("formProcDt")))
    cQuery += " AND BVT_LOTE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("batchCode")))
    cQuery += " AND BVT_NMGPRE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerFormNumber")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()

return lFound

Method commit(lInclui) Class CenDaoBvt

    local cForEnv := GetAdvFVal("B7Z","B7Z_FORENV",xFilial("B7Z")+self:getValue("tableCode")+self:getValue("procedureCode"),1,"")
    local cCodGru := Iif(cForEnv=='2',;
        GetAdvFVal("B7Z","B7Z_CODGRU",xFilial("B7Z")+self:getValue("tableCode")+self:getValue("procedureCode"),1,""),;
        '')

    Default lInclui := .F.

    If BVT->(RecLock("BVT",lInclui))

        BVT->BVT_FILIAL := xFilial("BVT")
        If lInclui

            BVT->BVT_ANO := _Super:normalizeType(BVT->BVT_ANO,self:getValue("referenceYear")) /* Column BVT_ANO */
            BVT->BVT_CDCOMP := _Super:normalizeType(BVT->BVT_CDCOMP,self:getValue("commitmentCode")) /* Column BVT_CDCOMP */
            BVT->BVT_CDOBRI := _Super:normalizeType(BVT->BVT_CDOBRI,self:getValue("requirementCode")) /* Column BVT_CDOBRI */
            BVT->BVT_CODGRU := cCodGru //_Super:normalizeType(BVT->BVT_CODGRU,self:getValue("procedureGroup")) /* Column BVT_CODGRU */
            BVT->BVT_CODOPE := _Super:normalizeType(BVT->BVT_CODOPE,self:getValue("operatorRecord")) /* Column BVT_CODOPE */
            BVT->BVT_CODPRO := _Super:normalizeType(BVT->BVT_CODPRO,self:getValue("procedureCode")) /* Column BVT_CODPRO */
            BVT->BVT_CODTAB := _Super:normalizeType(BVT->BVT_CODTAB,self:getValue("tableCode")) /* Column BVT_CODTAB */
            BVT->BVT_DTPRGU := _Super:normalizeType(BVT->BVT_DTPRGU,self:getValue("formProcDt")) /* Column BVT_DTPRGU */
            BVT->BVT_LOTE := _Super:normalizeType(BVT->BVT_LOTE,self:getValue("batchCode")) /* Column BVT_LOTE */
            BVT->BVT_NMGPRE := _Super:normalizeType(BVT->BVT_NMGPRE,self:getValue("providerFormNumber")) /* Column BVT_NMGPRE */

        EndIf
        BVT->BVT_STATUS := _Super:normalizeType(BVT->BVT_STATUS,self:getValue("status")) /* Column BVT_STATUS */
        BVT->BVT_QTDINF := _Super:normalizeType(BVT->BVT_QTDINF,self:getValue("enteredQuantity")) /* Column BVT_QTDINF */
        BVT->BVT_VLPGPR := _Super:normalizeType(BVT->BVT_VLPGPR,self:getValue("procedureValuePaid")) /* Column BVT_VLPGPR */
        BVT->BVT_VLRCOP := _Super:normalizeType(BVT->BVT_VLRCOP,self:getValue("coPaymentValue")) /* Column BVT_VLRCOP */

        BVT->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} bscUltChv
    Verifica se a ultima transacao da chave ANS e uma exclusao

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method bscUltEve() Class CenDaoBVT

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BVT') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	BVT_FILIAL = '" + xFilial("BVT") + "' "

    cQuery += " AND BVT_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BVT_NMGPRE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerFormNumber")))
    cQuery += " AND BVT_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))

    if !empty(self:getValue("referenceYear"))
        cQuery += " AND BVT_ANO = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    endIf

    if !empty(self:getValue("commitmentCode"))
        cQuery += " AND BVT_CDCOMP = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    endIf

    cQuery += " AND BVT_DTPRGU = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("formProcDt")))

    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY BVT_CODGRU, BVT_CODTAB, BVT_CODPRO "

    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()
    If lFound
        BVT->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

return lFound

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} bscTotCop
    Soma o total da co-participação da guia

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method bscTotCop() Class CenDaoBVT

    Local nTotal := 0
    Local cQuery := ""

    cQuery := " SELECT SUM(BVT_VLRCOP)  TOTAL "
    cQuery += " FROM " + RetSqlName('BVT') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	BVT_FILIAL = '" + xFilial("BVT") + "' "
    cQuery += " AND BVT_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BVT_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND BVT_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND BVT_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND BVT_NMGPRE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerFormNumber")))
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY BVT_FILIAL, BVT_CODOPE, BVT_CDOBRI, BVT_ANO, BVT_CDCOMP, BVT_NMGPRE "

    self:setQuery(self:queryBuilder(cQuery))
    If self:executaQuery()
        nTotal := (self:getAliasTemp())->TOTAL
    EndIf
    self:fechaQuery()

return nTotal
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} bscTotPgGui
    Soma o total pago da guia

    @type  Class
    @author everton.mateus
    @since 03/12/2019
/*/
//------------------------------------------------------------------------------------------
Method bscTotPgGui() Class CenDaoBVT

    Local nTotal := 0
    Local cQuery := ""

    cQuery := " SELECT SUM(BVT_VLPGPR)  TOTAL "
    cQuery += " FROM " + RetSqlName('BVT') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	BVT_FILIAL = '" + xFilial("BVT") + "' "
    cQuery += " AND BVT_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BVT_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND BVT_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND BVT_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND BVT_NMGPRE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerFormNumber")))
    cQuery += " AND BVT_LOTE = ' ' AND D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY BVT_FILIAL, BVT_CODOPE, BVT_CDOBRI, BVT_ANO, BVT_CDCOMP, BVT_NMGPRE "

    self:setQuery(self:queryBuilder(cQuery))
    If self:executaQuery()
        nTotal := (self:getAliasTemp())->TOTAL
    EndIf
    self:fechaQuery()

return nTotal

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} qtdGrupo
    Retorna a quantidade de registros com mesmo grupo

    @type  Class
    @author everton.mateus
    @since 03/12/2019
/*/
//------------------------------------------------------------------------------------------
Method qtdGrupo() Class CenDaoBVT

    Local nTotal := 0
    Local cQuery := ""

    cQuery := " SELECT COUNT(1) TOTAL "
    cQuery += " FROM " + RetSqlName('BVT') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	BVT_FILIAL = '" + xFilial("BVT") + "' "
    cQuery += " AND BVT_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BVT_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND BVT_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND BVT_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND BVT_NMGPRE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerFormNumber")))
    cQuery += " AND BVT_DTPRGU = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("formProcDt")))
    cQuery += " AND BVT_CODGRU = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("procedureGroup")))
    cQuery += " AND BVT_CODTAB = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("tableCode")))
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY BVT_FILIAL, BVT_CODOPE, BVT_CDOBRI, BVT_ANO, BVT_CDCOMP, BVT_NMGPRE, BVT_DTPRGU, BVT_CODGRU, BVT_CODTAB "

    self:setQuery(self:queryBuilder(cQuery))
    If self:executaQuery()
        nTotal := (self:getAliasTemp())->TOTAL
    EndIf
    self:fechaQuery()

return nTotal

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} qtdProcGui
    Retorna a quantidade de procedimentos iguais na guia

    @type  Class
    @author everton.mateus
    @since 03/12/2019
/*/
//------------------------------------------------------------------------------------------
Method qtdProcGui() Class CenDaoBVT

    Local nTotal := 0
    Local cQuery := ""

    cQuery := " SELECT COUNT(1) TOTAL "
    cQuery += " FROM " + RetSqlName('BVT') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	BVT_FILIAL = '" + xFilial("BVT") + "' "
    cQuery += " AND BVT_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BVT_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND BVT_NMGPRE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerFormNumber")))
    cQuery += " AND BVT_CODGRU = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("procedureGroup")))
    cQuery += " AND BVT_CODTAB = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("tableCode")))
    cQuery += " AND BVT_CODPRO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("procedureCode")))
    cQuery += " AND BVT_LOTE = ' ' "
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY BVT_FILIAL, BVT_CODOPE, BVT_CDOBRI,  BVT_NMGPRE, BVT_CODGRU, BVT_CODTAB, BVT_CODPRO "

    self:setQuery(self:queryBuilder(cQuery))
    If self:executaQuery()
        nTotal := (self:getAliasTemp())->TOTAL
    EndIf
    self:fechaQuery()

return nTotal

Method setProcessing() Class CenDaoBVT

    Local cQuery := ""
    Local lFound := .F.

    If self:cDB <> POSTGRES

        If self:cDB $ MSSQL
            cQuery := " UPDATE TOP(1) "
        Else
            cQuery := " UPDATE "

        EndIf

        cQuery += " " + RetSqlName('BVT') + " "
        cQuery += " SET "
        cQuery += " BVT_PROCES = '" + PROCESSING + "' "
        cQuery += " , BVT_ROBOID='"+self:toString(self:getValue("processId"))+"' "
        cQuery += " , BVT_ROBOHR = '" + DToS(Date()) + " " + Time() + "' "
        cQuery += " WHERE 1=1 "
        cQuery += " AND BVT_FILIAL = '" + xFilial( 'BVT' ) + "' "
        cQuery += " AND BVT_PROCES <> '" + PROCESSED + "' "
        cQuery += " AND BVT_ROBOID = '' "

        If (self:cDB $ "ORACLE")
            cQuery += "	AND ROWNUM = 1 "
        EndIf

        cQuery += " AND D_E_L_E_T_ = ' ' "

    Else
        cQuery := " UPDATE " + RetSqlName('BVT') + " SET "
        cQuery += " BVT_PROCES = '" + PROCESSING + "' "
        cQuery += " , BVT_ROBOID='"+self:toString(self:getValue("processId"))+"' "
        cQuery += " , BVT_ROBOHR = '" + DToS(Date()) + " " + Time() + "' "
        cQuery += " WHERE R_E_C_N_O_ = (SELECT R_E_C_N_O_ FROM  " + RetSqlName('BVT') + " WHERE  "
        cQuery += " BVT_FILIAL = '" + xFilial( 'BVT' ) + "' "
        cQuery += " AND BVT_PROCES <> '" + PROCESSED + "' "
        cQuery += " AND BVT_ROBOID = '' "
        cQuery += " AND D_E_L_E_T_ = ' ' "
        cQuery += "	LIMIT 1 )"

    EndIf

    self:setQuery(cQuery)
    lFound := self:execStatement()

Return lFound

Method getMessage() Class CenDaoBVT

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BVT') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND BVT_PROCES = '" + PROCESSING + "' "
    cQuery += " AND BVT_ROBOID ='"+self:toString(self:getValue("processId"))+"' "

    self:setQuery(cQuery)
    lFound := self:executaQuery()
    If lFound
        BVT->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

return lFound

Method setEndProc(nRecno) Class CenDaoBVT

    Local cQuery := ""
    Local lFound := .F.

    Default nRecno := 0

    If self:cDB <> POSTGRES

        If self:cDB $ MSSQL
            cQuery := " UPDATE TOP(1) "
        Else
            cQuery := " UPDATE "

        EndIf
        cQuery += " " + RetSqlName('BVT') + " "
        cQuery += " SET "
        cQuery += " BVT_PROCES = '" + PROCESSED + "' "
        cQuery += " WHERE 1=1 "
        cQuery += " AND R_E_C_N_O_ = '" + AllTrim(Str(nRecno)) + "' "

        If (self:cDB $ "ORACLE")
            cQuery += "	AND ROWNUM = 1 "
        EndIf

    Else
        cQuery := " UPDATE " + RetSqlName('BVT') + " SET "
        cQuery += " BVT_PROCES = '" + PROCESSED + "' "
        cQuery += " WHERE R_E_C_N_O_ = (SELECT R_E_C_N_O_ FROM  " + RetSqlName('BVT') + " "
        cQuery += " WHERE 1=1 "
        cQuery += " AND R_E_C_N_O_ = '" + AllTrim(Str(nRecno)) + "' "
        cQuery += "	LIMIT 1 )"

    EndIf

    self:setQuery(cQuery)
    lFound := self:execStatement()

Return lFound

Method setExpired() Class CenDaoBVT

    Local cQuery := ""
    Local lFound := .F.

    cQuery := " UPDATE "
    cQuery += " " + RetSqlName('BVT') + " "
    cQuery += " SET "
    cQuery += " BVT_ROBOID = '' "
    cQuery += " ,BVT_PROCES = '" + PROCESSING + "' "
    cQuery += " WHERE 1=1 "
    cQuery += " AND BVT_ROBOID <> '' "
    cQuery += " AND BVT_PROCES = '" + PROCESSING + "' "
    cQuery += " AND BVT_ROBOHR <= '" + SubMinutos(Date(),Time(),2) + "' "
    cQuery += " AND BVT_ROBOHR <> ' ' "
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
Method atuCodLote() Class CenDaoBVT

    Local cQuery := ""
    Local lFound := .F.

    cQuery += " UPDATE "+RetSqlName('BVT')+" SET BVT_LOTE = ? FROM "+RetSqlName('BVT')+" BVT "
    aAdd(self:aMapBuilder, self:toString(self:getValue("batchCode")))
    cQuery += " INNER JOIN "+RetSqlName('BVQ')+" BVQ "
    cQuery += " ON  BVQ.BVQ_FILIAL = '"+xFilial("BVQ")+"' "
    cQuery += " AND BVQ.BVQ_CODOPE = BVT.BVT_CODOPE "
    cQuery += " AND BVQ.BVQ_NMGPRE = BVT.BVT_NMGPRE "
    cQuery += " AND BVQ.BVQ_CDOBRI = BVT.BVT_CDOBRI "
    cQuery += " AND BVQ.BVQ_ANO    = BVT.BVT_ANO "
    cQuery += " AND BVQ.BVQ_CDCOMP = BVT.BVT_CDCOMP "
    cQuery += " AND BVQ.BVQ_LOTE   = ? "
    cQuery += " AND BVQ.BVQ_DTPRGU = BVT.BVT_DTPRGU "
    aAdd(self:aMapBuilder, self:toString(self:getValue("batchCode")))
    cQuery += " AND BVQ.D_E_L_E_T_ = ' ' "

    cQuery += " WHERE "
    cQuery += " BVT.BVT_FILIAL = '"+xFilial("BVT")+"' "
    cQuery += " AND BVT.BVT_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BVT.BVT_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND BVT.BVT_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND BVT.BVT_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND BVT.BVT_LOTE = ' ' "
    cQuery += " AND BVT.D_E_L_E_T_ = ' ' "

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
Method delLote() Class CenDaoBvt

    Local cSql      := ""
    Local lFound    := .F.

    cSql := "UPDATE " + RetSqlName("BVT") + " "
    cSql += " SET BVT_LOTE = '' , BVT_STATUS = '2' "
    cSql += " WHERE 1=1 "
    cSql += " AND BVT_FILIAL = '" + xFilial("BVT") + "' "
    cSql += " AND BVT_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BVT_ANO")))
    cSql += " AND BVT_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BVT_CDCOMP")))
    cSql += " AND BVT_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BVT_CDOBRI")))
    cSql += " AND BVT_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BVT_CODOPE")))
    cSql += " AND BVT_LOTE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BVT_LOTE")))
    cSql += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')

    self:setQuery(self:queryBuilder(cSql))
    lFound := self:execStatement()

Return lFound



Method VerCritBVT(cOperadora,cObri,cAno,cComp,cGuia) Class CenDaoBvt

    Local lFound := .F.
    Local cQuery := ""
    Local nRecno   := 0

    If !Empty(cOperadora) .And. !Empty(cObri) .And. !Empty(cAno) .And. !Empty(cComp) .And. !Empty(cGuia)
        cQuery := " SELECT R_E_C_N_O_ RECNO "
        cQuery += " FROM " + RetSqlName('BVQ') + " "
        cQuery += " WHERE 1=1 "
        cQuery += " AND	BVQ_FILIAL = '" + xFilial("BVQ") + "' "
        cQuery += " AND BVQ_ANO    = '"+ cAno + "' "
        cQuery += " AND BVQ_CDCOMP = '"+ cComp + "' "
        cQuery += " AND BVQ_CDOBRI = '"+ cObri + "' "
        cQuery += " AND BVQ_CODOPE = '"+ cOperadora + "' "
        cQuery += " AND BVQ_NMGPRE = '"+ cGuia + "' "
        cQuery += " AND BVQ_STATUS = '2' AND D_E_L_E_T_ = ' ' "

        self:setQuery(self:queryBuilder(cQuery))
        If self:executaQuery()
            nRecno := (self:getAliasTemp())->RECNO
        EndIf
        self:fechaQuery()
    endIf

return nRecno
