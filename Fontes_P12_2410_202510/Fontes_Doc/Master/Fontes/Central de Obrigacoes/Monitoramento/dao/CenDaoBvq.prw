#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2
#Define PROCESSING '0'
#Define PROCESSED '1'

#Define MSSQL     "MSSQL"
#Define POSTGRES  "POSTGRES"
#Define ORACLE    "ORACLE"

Class CenDaoBvq from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method commit()
    Method delete()
    Method bscChaPrim()
    Method bscMovPend()
    Method bscMovExcl()
    Method bscMovProc()
    Method bscUltChv()
    Method getQtdNmPre()
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
    Method VerCritBVT(cOperadora,cObri,cAno,cComp,cGuia)

EndClass

Method New(aFields) Class CenDaoBvq
    _Super:New(aFields)
    self:cAlias := "BVQ"
    self:cfieldOrder := "BVQ_ANO,BVQ_CDCOMP,BVQ_CDOBRI,BVQ_CODOPE,BVQ_DTPRGU,BVQ_LOTE,BVQ_NMGPRE"
Return self

Method buscar() Class CenDaoBvq
    Local lFound := .F.
    lFound := _Super:buscar()
    If lFound
        BVQ->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoBvq
    Local lFound := .F.
    if self:bscChaPrim()
        lFound := _Super:delete()
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoBvq

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BVQ') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	BVQ_FILIAL = '" + xFilial("BVQ") + "' "

    cQuery += " AND BVQ_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND BVQ_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND BVQ_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND BVQ_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BVQ_DTPRGU = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("formProcDt")))
    cQuery += " AND BVQ_LOTE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("batchCode")))
    cQuery += " AND BVQ_NMGPRE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerFormNumber")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()

return lFound

Method commit(lInclui) Class CenDaoBvq

    Default lInclui := .F.

    If BVQ->(RecLock("BVQ",lInclui))

        BVQ->BVQ_FILIAL := xFilial("BVQ")
        If lInclui

            BVQ->BVQ_ANO := _Super:normalizeType(BVQ->BVQ_ANO,self:getValue("referenceYear")) /* Column BVQ_ANO */
            BVQ->BVQ_CDCOMP := _Super:normalizeType(BVQ->BVQ_CDCOMP,self:getValue("commitmentCode")) /* Column BVQ_CDCOMP */
            BVQ->BVQ_CDOBRI := _Super:normalizeType(BVQ->BVQ_CDOBRI,self:getValue("requirementCode")) /* Column BVQ_CDOBRI */
            BVQ->BVQ_CODOPE := _Super:normalizeType(BVQ->BVQ_CODOPE,self:getValue("operatorRecord")) /* Column BVQ_CODOPE */
            BVQ->BVQ_DTPRGU := _Super:normalizeType(BVQ->BVQ_DTPRGU,self:getValue("formProcDt")) /* Column BVQ_DTPRGU */
            BVQ->BVQ_LOTE := _Super:normalizeType(BVQ->BVQ_LOTE,self:getValue("batchCode")) /* Column BVQ_LOTE */
            BVQ->BVQ_NMGPRE := _Super:normalizeType(BVQ->BVQ_NMGPRE,self:getValue("providerFormNumber")) /* Column BVQ_NMGPRE */

        EndIf

        BVQ->BVQ_STATUS := _Super:normalizeType(BVQ->BVQ_STATUS,self:getValue("status")) /* Column BVQ_STATUS */
        BVQ->BVQ_TPRGMN := _Super:normalizeType(BVQ->BVQ_TPRGMN,self:getValue("monitoringRecordType")) /* Column BVQ_TPRGMN */
        BVQ->BVQ_VLTCOP := _Super:normalizeType(BVQ->BVQ_VLTCOP,self:getValue("coPaymentTotalValue")) /* Column BVQ_VLTCOP */
        BVQ->BVQ_VLTGUI := _Super:normalizeType(BVQ->BVQ_VLTGUI,self:getValue("valuePaidForm")) /* Column BVQ_VLTGUI */
        BVQ->BVQ_VLTTBP := _Super:normalizeType(BVQ->BVQ_VLTTBP,self:getValue("ownTableTotalValue")) /* Column BVQ_VLTTBP */
        BVQ->BVQ_MATRIC := _Super:normalizeType(BVQ->BVQ_MATRIC,self:getValue("registration")) /* Column BVQ_MATRIC */
        BVQ->BVQ_HORPRO := _Super:normalizeType(BVQ->BVQ_HORPRO,self:getValue("processingTime")) /* Column BVQ_HORPRO */
        BVQ->BVQ_DATPRO := _Super:normalizeType(BVQ->BVQ_DATPRO,self:getValue("processingDate")) /* Column BVQ_DATPRO */
        BVQ->BVQ_DATINC := _Super:normalizeType(BVQ->BVQ_DATINC,self:getValue("inclusionDate")) /* Column BVQ_DATINC */
        BVQ->BVQ_HORINC := _Super:normalizeType(BVQ->BVQ_HORINC,self:getValue("inclusionTime")) /* Column BVQ_HORINC */

        BVQ->(MsUnlock())
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
Method bscMovPend() Class CenDaoBVQ

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BVQ') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	BVQ_FILIAL = '" + xFilial("BVQ") + "' "

    cQuery += " AND BVQ_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BVQ_NMGPRE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerFormNumber")))
    cQuery += " AND BVQ_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND BVQ_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND BVQ_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))


    //1=Pendente Envio;2=Criticado;3=Pronto para o Envio
    cQuery += " AND ((BVQ_STATUS='') "
    cQuery += " OR  (BVQ_STATUS='1') "
    cQuery += " OR  (BVQ_STATUS='2') "
    cQuery += " OR  (BVQ_STATUS='3') "
    cQuery += " OR  (BVQ_STATUS='7'))"
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY BVQ_DATPRO DESC, BVQ_HORPRO DESC "

    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()
    If lFound
        BVQ->(DbGoto((self:getAliasTemp())->RECNO))
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
Method bscMovExcl() Class CenDaoBVQ

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BVQ') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	BVQ_FILIAL = '" + xFilial("BVQ") + "' "

    cQuery += " AND BVQ_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BVQ_NMGPRE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerFormNumber")))
    cQuery += " AND BVQ_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    if !Empty(self:getValue("formProcDt"))
        cQuery += " AND BVQ_DTPRGU = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("formProcDt")))
    EndIf
    cQuery += " AND BVQ_STATUS <> '5' " //5=Criticado pela ANS
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY BVQ_DATPRO DESC, BVQ_HORPRO DESC "

    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()
    If lFound
        BVQ->(DbGoto((self:getAliasTemp())->RECNO))
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
Method bscMovProc() Class CenDaoBVQ

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BVQ') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	BVQ_FILIAL = '" + xFilial("BVQ") + "' "

    cQuery += " AND BVQ_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BVQ_NMGPRE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerFormNumber")))
    cQuery += " AND BVQ_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND BVQ_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND BVQ_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND BVQ_DTPRGU = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("formProcDt")))

    cQuery += " AND ( (BVQ_STATUS='4') OR (BVQ_STATUS='6') OR (BVQ_STATUS='8') ) " //4=Em processamento ANS;5=Criticado pela ANS;6=Finalizado
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY BVQ_DATPRO DESC, BVQ_HORPRO DESC "

    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()
    If lFound
        BVQ->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

return lFound


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} bscUltChv
    Verifica se a ultima transacao da chave ANS e uma exclusao

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method bscUltChv() Class CenDaoBVQ

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BVQ') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	BVQ_FILIAL = '" + xFilial("BVQ") + "' "

    cQuery += " AND BVQ_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BVQ_NMGPRE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerFormNumber")))
    cQuery += " AND BVQ_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))

    if !empty(self:getValue("referenceYear"))
        cQuery += " AND BVQ_ANO = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    endIf

    if !empty(self:getValue("commitmentCode"))
        cQuery += " AND BVQ_CDCOMP = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    endIf

    cQuery += " AND BVQ_DTPRGU = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("formProcDt")))

    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY BVQ_DATPRO DESC, BVQ_HORPRO DESC "

    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()
    If lFound
        BVQ->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

return lFound


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} getQtdIdVPre
    Retorna a quantidade de registros com o mesmo tipo de registro e ID de valor pré-estabelecido

    @type  method
    @author everton.mateus
    @since 28/11/2019
/*/
//------------------------------------------------------------------------------------------
Method getQtdNmPre() Class CenDaoBVQ

    Local nTotal := 0
    Local cQuery := ""

    cQuery := " SELECT Count(1) TOTAL "
    cQuery += " FROM " + RetSqlName('BVQ') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	BVQ_FILIAL = '" + xFilial("BVQ") + "' "
    cQuery += " AND BVQ_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BVQ_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND BVQ_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND BVQ_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND BVQ_TPRGMN = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("monitoringRecordType")))
    cQuery += " AND BVQ_NMGPRE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerFormNumber")))
    cQuery += " AND BVQ_LOTE = ' ' AND D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY BVQ_FILIAL, BVQ_CODOPE, BVQ_CDOBRI, BVQ_ANO, BVQ_CDCOMP, BVQ_TPRGMN,  BVQ_NMGPRE "

    self:setQuery(self:queryBuilder(cQuery))
    If self:executaQuery()
        nTotal := (self:getAliasTemp())->TOTAL
    EndIf
    self:fechaQuery()

return nTotal

Method setProcessing() Class CenDaoBVQ

    Local cQuery := ""
    Local lFound := .F.

    If self:cDB <> POSTGRES

        If self:cDB $ MSSQL
            cQuery := " UPDATE TOP(1) "
        Else
            cQuery := " UPDATE "

        EndIf

        cQuery += " " + RetSqlName('BVQ') + " "
        cQuery += " SET "
        cQuery += " BVQ_PROCES = '" + PROCESSING + "' "
        cQuery += " , BVQ_ROBOID='"+self:toString(self:getValue("processId"))+"' "
        cQuery += " , BVQ_ROBOHR = '" + DToS(Date()) + " " + Time() + "' "
        cQuery += " WHERE 1=1 "
        cQuery += " AND BVQ_FILIAL = '" + xFilial( 'BVQ' ) + "' "
        cQuery += " AND BVQ_PROCES <> '" + PROCESSED + "' "
        cQuery += " AND BVQ_ROBOID = '' "

        If (self:cDB $ "ORACLE")
            cQuery += "	AND ROWNUM = 1 "
        EndIf

        cQuery += " AND D_E_L_E_T_ = ' ' "

    Else
        cQuery := " UPDATE " + RetSqlName('BVQ') + " SET "
        cQuery += " BVQ_PROCES = '" + PROCESSING + "' "
        cQuery += " , BVQ_ROBOID='"+self:toString(self:getValue("processId"))+"' "
        cQuery += " , BVQ_ROBOHR = '" + DToS(Date()) + " " + Time() + "' "
        cQuery += " WHERE R_E_C_N_O_ = (SELECT R_E_C_N_O_ FROM  " + RetSqlName('BVQ') + " WHERE  "
        cQuery += " BVQ_FILIAL = '" + xFilial( 'BVQ' ) + "' "
        cQuery += " AND BVQ_PROCES <> '" + PROCESSED + "' "
        cQuery += " AND BVQ_ROBOID = '' "
        cQuery += " AND D_E_L_E_T_ = ' ' "
        cQuery += "	LIMIT 1 )"

    EndIf

    self:setQuery(cQuery)
    lFound := self:execStatement()

Return lFound

Method getMessage() Class CenDaoBVQ

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BVQ') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND BVQ_PROCES = '" + PROCESSING + "' "
    cQuery += " AND BVQ_ROBOID ='"+self:toString(self:getValue("processId"))+"' "

    self:setQuery(cQuery)
    lFound := self:executaQuery()
    If lFound
        BVQ->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

return lFound

Method setEndProc(nRecno) Class CenDaoBVQ

    Local cQuery := ""
    Local lFound := .F.

    Default nRecno := 0

    If self:cDB <> POSTGRES

        If self:cDB $ MSSQL
            cQuery := " UPDATE TOP(1) "
        Else
            cQuery := " UPDATE "

        EndIf
        cQuery += " " + RetSqlName('BVQ') + " "
        cQuery += " SET "
        cQuery += " BVQ_PROCES = '" + PROCESSED + "' "
        cQuery += " WHERE 1=1 "
        cQuery += " AND R_E_C_N_O_ = '" + AllTrim(Str(nRecno)) + "' "

        If (self:cDB $ "ORACLE")
            cQuery += "	AND ROWNUM = 1 "
        EndIf

    Else
        cQuery := " UPDATE " + RetSqlName('BVQ') + " SET "
        cQuery += " BVQ_PROCES = '" + PROCESSED + "' "
        cQuery += " WHERE R_E_C_N_O_ = (SELECT R_E_C_N_O_ FROM  " + RetSqlName('BVQ') + " "
        cQuery += " WHERE 1=1 "
        cQuery += " AND R_E_C_N_O_ = '" + AllTrim(Str(nRecno)) + "' "
        cQuery += "	LIMIT 1 )"

    EndIf

    self:setQuery(cQuery)
    lFound := self:execStatement()

Return lFound

Method setExpired() Class CenDaoBVQ

    Local cQuery := ""
    Local lFound := .F.

    cQuery := " UPDATE "
    cQuery += " " + RetSqlName('BVQ') + " "
    cQuery += " SET "
    cQuery += " BVQ_ROBOID = '' "
    cQuery += " ,BVQ_PROCES = '" + PROCESSING + "' "
    cQuery += " WHERE 1=1 "
    cQuery += " AND BVQ_ROBOID <> '' "
    cQuery += " AND BVQ_PROCES = '" + PROCESSING + "' "
    cQuery += " AND BVQ_ROBOHR <= '" + SubMinutos(Date(),Time(),2) + "' "
    cQuery += " AND BVQ_ROBOHR <> ' ' "
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
Method bscAddLote() Class CenDaoBVQ

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT BVQ_CDOBRI, BVQ_ANO, BVQ_CDCOMP, 0 AS RECNO "
    cQuery += " FROM " + RetSqlName('BVQ') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	BVQ_FILIAL = '" + xFilial("BVQ") + "' "

    cQuery += " AND BVQ_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))

    cQuery += " AND BVQ_STATUS = '2' "
    cQuery += " AND BVQ_LOTE   = ' ' "
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY BVQ_CDOBRI, BVQ_ANO, BVQ_CDCOMP "

    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()
    If lFound
        BVQ->(DbGoto((self:getAliasTemp())->RECNO))
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
Method qtdGuiComp() Class CenDaoBVQ

    Local nTotal := 0
    Local cQuery := ""

    cQuery := " SELECT COUNT(1) TOTAL "
    cQuery += " FROM " + RetSqlName('BVQ') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	BVQ_FILIAL = '" + xFilial("BVQ") + "' "
    cQuery += " AND BVQ_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BVQ_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND BVQ_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND BVQ_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND BVQ_LOTE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("batchCode")))
    cQuery += " AND BVQ_STATUS = '2' "
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY BVQ_FILIAL, BVQ_CODOPE, BVQ_CDOBRI, BVQ_ANO, BVQ_CDCOMP "

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
Method atuCodLote(nQtdReg) Class CenDaoBVQ

    Local cQuery := ""
    Local lFound := .F.

    If self:cDB <> POSTGRES
        If self:cDB $ MSSQL
            cQuery := " UPDATE TOP("+cValtoChar(nQtdReg)+") "
        Else
            cQuery := " UPDATE "

        EndIf

        cQuery += " " + RetSqlName('BVQ') + " "
        cQuery += " SET BVQ_STATUS = '7', "
        cQuery += " BVQ_LOTE = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("batchCode")))
        cQuery += " WHERE 1=1 "
        cQuery += " AND BVQ_FILIAL = '" + xFilial( 'BVQ' ) + "' "
        cQuery += " AND BVQ_CODOPE = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
        cQuery += " AND BVQ_CDOBRI = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
        cQuery += " AND BVQ_ANO = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
        cQuery += " AND BVQ_CDCOMP = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
        cQuery += " AND BVQ_LOTE = ' ' "
        cQuery += " AND BVQ_STATUS = '2' "
        cQuery += " AND D_E_L_E_T_ = ' ' "

        If (self:cDB $ "ORACLE")
            cQuery += "	AND ROWNUM = 1 "
        EndIf
    Else

        cQuery := " UPDATE " + RetSqlName('BVQ') + " "
        cQuery += " SET BVQ_STATUS = '7', BVQ_LOTE = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("batchCode")))
        cQuery += " WHERE R_E_C_N_O_ =  (SELECT R_E_C_N_O_ FROM " + RetSqlName('BVQ') + " "
        cQuery += " WHERE BVQ_FILIAL = '" + xFilial( 'BVQ' ) + "' "
        cQuery += " AND BVQ_CODOPE = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
        cQuery += " AND BVQ_CDOBRI = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
        cQuery += " AND BVQ_ANO = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
        cQuery += " AND BVQ_CDCOMP = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
        cQuery += " AND BVQ_LOTE = ' ' "
        cQuery += " AND BVQ_STATUS = '2' "
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
Method atuStaANS(cStatAtu,cStatCond) Class CenDaoBVQ

    Local cQuery      := ""
    Local lFound      := .F.
    Default cStatAtu  := "6"
    Default cStatCond := "5"

    cQuery := " UPDATE "
    cQuery += " " + RetSqlName('BVQ') + " "
    cQuery += " SET "
    cQuery += " BVQ_STATUS = ? "
    aAdd(self:aMapBuilder, cStatAtu )
    cQuery += " WHERE 1=1 "
    cQuery += " AND BVQ_FILIAL = '" + xFilial( 'BVQ' ) + "' "
    cQuery += " AND BVQ_LOTE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("batchCode")))
    cQuery += " AND BVQ_STATUS NOT IN ('"+cStatCond+"') "
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
Method staPosLot() Class CenDaoBVQ

    Local cQuery := ""
    Local lFound := .F.

    cQuery := " UPDATE " + RetSqlName('BVQ') + " "
    cQuery += " SET "
    cQuery += " BVQ_STATUS = '8' "
    cQuery += " WHERE 1=1 "
    cQuery += " AND BVQ_FILIAL = '" + xFilial( 'BVQ' ) + "' "
    cQuery += " AND BVQ_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BVQ_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND BVQ_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND BVQ_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND BVQ_LOTE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("batchCode")))
    cQuery += " AND BVQ_STATUS = '7' "
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
Method delLote() Class CenDaoBvq

    Local cSql      := ""
    Local lFound    := .F.

    cSql := "UPDATE " + RetSqlName("BVQ") + " "
    cSql += " SET BVQ_LOTE = '', BVQ_STATUS = '2' "
    cSql += " WHERE 1=1 "
    cSql += " AND BVQ_FILIAL = '" + xFilial("BVQ") + "' "
    cSql += " AND BVQ_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BVQ_ANO")))
    cSql += " AND BVQ_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BVQ_CDCOMP")))
    cSql += " AND BVQ_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BVQ_CDOBRI")))
    cSql += " AND BVQ_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BVQ_CODOPE")))
    cSql += " AND BVQ_LOTE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BVQ_LOTE")))
    cSql += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')

    self:setQuery(self:queryBuilder(cSql))
    lFound := self:execStatement()

Return lFound

Method VerCritBVT(cOperadora,cObri,cAno,cComp,cGuia) Class CenDaoBvq

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