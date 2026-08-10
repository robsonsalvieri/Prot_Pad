#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2
#Define PROCESSING '0'
#Define PROCESSED '1'
#Define MSSQL     "MSSQL"
#Define POSTGRES  "POSTGRES"
#Define ORACLE    "ORACLE"

Class CenDaoBVZ from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method commit()
    Method delete()
    Method bscChaPrim()
    Method bscMovPend()
    Method bscMovProc()
    Method bscUltChv()
    Method bscMovExcl()
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

EndClass

Method New(aFields) Class CenDaoBVZ
    _Super:New(aFields)
    self:cAlias := "BVZ"
    self:cfieldOrder := "BVZ_ANO,BVZ_CDCOMP,BVZ_CDOBRI,BVZ_CODOPE,BVZ_CPFCNP,BVZ_DTPROC,BVZ_LOTE"
Return self

Method buscar() Class CenDaoBVZ
    Local lFound := .F.
    lFound := _Super:buscar()
    If lFound
        BVZ->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoBVZ
    Local lFound := .F.
    if self:bscChaPrim()
        lFound := _Super:delete()
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoBVZ

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BVZ') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	BVZ_FILIAL = '" + xFilial("BVZ") + "' "

    cQuery += " AND BVZ_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND BVZ_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND BVZ_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND BVZ_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BVZ_CPFCNP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerCpfCnpj")))
    cQuery += " AND BVZ_DTPROC = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("formProcDt")))
    cQuery += " AND BVZ_LOTE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("batchCode")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()

return lFound

Method commit(lInclui) Class CenDaoBVZ

    Default lInclui := .F.

    If BVZ->(RecLock("BVZ",lInclui))

        BVZ->BVZ_FILIAL := xFilial("BVZ")
        If lInclui

            BVZ->BVZ_ANO := _Super:normalizeType(BVZ->BVZ_ANO,self:getValue("referenceYear")) /* Column BVZ_ANO */
            BVZ->BVZ_CDCOMP := _Super:normalizeType(BVZ->BVZ_CDCOMP,self:getValue("commitmentCode")) /* Column BVZ_CDCOMP */
            BVZ->BVZ_CDOBRI := _Super:normalizeType(BVZ->BVZ_CDOBRI,self:getValue("requirementCode")) /* Column BVZ_CDOBRI */
            BVZ->BVZ_CODOPE := _Super:normalizeType(BVZ->BVZ_CODOPE,self:getValue("operatorRecord")) /* Column BVZ_CODOPE */
            BVZ->BVZ_CPFCNP := _Super:normalizeType(BVZ->BVZ_CPFCNP,self:getValue("providerCpfCnpj")) /* Column BVZ_CPFCNP */
            BVZ->BVZ_DTPROC := _Super:normalizeType(BVZ->BVZ_DTPROC,self:getValue("formProcDt")) /* Column BVZ_DTPROC */
            BVZ->BVZ_LOTE := _Super:normalizeType(BVZ->BVZ_LOTE,self:getValue("batchCode")) /* Column BVZ_LOTE */

        EndIf

        BVZ->BVZ_STATUS := _Super:normalizeType(BVZ->BVZ_STATUS,self:getValue("status")) /* Column BVZ_STATUS */
        BVZ->BVZ_TPRGMN := _Super:normalizeType(BVZ->BVZ_TPRGMN,self:getValue("monitoringRecordType")) /* Column BVZ_TPRGMN */
        BVZ->BVZ_VLTGLO := _Super:normalizeType(BVZ->BVZ_VLTGLO,self:getValue("totalDisallowValue")) /* Column BVZ_VLTGLO */
        BVZ->BVZ_VLTINF := _Super:normalizeType(BVZ->BVZ_VLTINF,self:getValue("totalValueEntered")) /* Column BVZ_VLTINF */
        BVZ->BVZ_VLTPAG := _Super:normalizeType(BVZ->BVZ_VLTPAG,self:getValue("totalValuePaid")) /* Column BVZ_VLTPAG */
        BVZ->BVZ_HORINC := _Super:normalizeType(BVZ->BVZ_HORINC,self:getValue("inclusionTime")) /* Column BVZ_HORINC */
        BVZ->BVZ_HORPRO := _Super:normalizeType(BVZ->BVZ_HORPRO,self:getValue("processingTime")) /* Column BVZ_HORPRO */
        BVZ->BVZ_IDEREC := _Super:normalizeType(BVZ->BVZ_IDEREC,self:getValue("identReceipt")) /* Column BVZ_IDEREC */
        BVZ->BVZ_DATINC := _Super:normalizeType(BVZ->BVZ_DATINC,self:getValue("inclusionDate")) /* Column BVZ_DATINC */
        BVZ->BVZ_DATPRO := _Super:normalizeType(BVZ->BVZ_DATPRO,self:getValue("processingDate")) /* Column BVZ_DATPRO */

        BVZ->(MsUnlock())
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
Method bscMovPend() Class CenDaoBVZ

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BVZ') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	BVZ_FILIAL = '" + xFilial("BVZ") + "' "

    cQuery += " AND BVZ_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BVZ_CPFCNP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerCpfCnpj")))
    cQuery += " AND BVZ_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND BVZ_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND BVZ_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))

    //1=Pendente Envio;2=Criticado;3=Pronto para o Envio;7=Pendente Geração de Arquivo
    cQuery += " AND ( (BVZ_STATUS='') "
    cQuery += " OR  (BVZ_STATUS='1') "
    cQuery += " OR  (BVZ_STATUS='2') "
    cQuery += " OR  (BVZ_STATUS='3') "
    cQuery += " OR  (BVZ_STATUS='7') )"
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY BVZ_DATPRO DESC, BVZ_HORPRO DESC "

    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()
    If lFound
        BVZ->(DbGoto((self:getAliasTemp())->RECNO))
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
Method bscMovProc() Class CenDaoBVZ

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BVZ') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	BVZ_FILIAL = '" + xFilial("BVZ") + "' "

    cQuery += " AND BVZ_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BVZ_CPFCNP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerCpfCnpj")))
    cQuery += " AND BVZ_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND BVZ_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND BVZ_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND BVZ_DTPROC = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("formProcDt")))

    cQuery += " AND ( (BVZ_STATUS='4') OR (BVZ_STATUS='6') OR (BVZ_STATUS='8') ) " //4=Em processamento ANS;5=Criticado pela ANS;6=Finalizado;
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY BVZ_DATPRO DESC, BVZ_HORPRO DESC "

    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()
    If lFound
        BVZ->(DbGoto((self:getAliasTemp())->RECNO))
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
Method bscUltChv() Class CenDaoBVZ

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BVZ') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	BVZ_FILIAL = '" + xFilial("BVZ") + "' "

    cQuery += " AND BVZ_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BVZ_CPFCNP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerCpfCnpj")))
    cQuery += " AND BVZ_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))

    if !empty(self:getValue("referenceYear"))
        cQuery += " AND BVZ_ANO = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    endIf

    if !empty(self:getValue("commitmentCode"))
        cQuery += " AND BVZ_CDCOMP = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    endIf

    cQuery += " AND BVZ_DTPROC = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("formProcDt")))

    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY BVZ_DATPRO DESC, BVZ_HORPRO DESC "

    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()
    If lFound
        BVZ->(DbGoto((self:getAliasTemp())->RECNO))
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
Method bscMovExcl() Class CenDaoBVZ

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BVZ') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	BVZ_FILIAL = '" + xFilial("BVZ") + "' "

    cQuery += " AND BVZ_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BVZ_CPFCNP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerCpfCnpj")))
    cQuery += " AND BVZ_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    if !Empty(self:getValue("formProcDt"))
        cQuery += " AND BVZ_DTPROC = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("formProcDt")))
    EndIf
    cQuery += " AND BVZ_STATUS <> '5' " //5=Criticado pela ANS
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY BVZ_DATPRO DESC, BVZ_HORPRO DESC "

    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()
    If lFound
        BVZ->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

return lFound

Method setProcessing() Class CenDaoBVZ

    Local cQuery := ""
    Local lFound := .F.

    If self:cDB <> POSTGRES

        If self:cDB $ MSSQL
            cQuery := " UPDATE TOP(1) "
        Else
            cQuery := " UPDATE "

        EndIf

        cQuery += " " + RetSqlName('BVZ') + " "
        cQuery += " SET "
        cQuery += " BVZ_PROCES = '" + PROCESSING + "' "
        cQuery += " , BVZ_ROBOID='"+self:toString(self:getValue("processId"))+"' "
        cQuery += " , BVZ_ROBOHR = '" + DToS(Date()) + " " + Time() + "' "
        cQuery += " WHERE 1=1 "
        cQuery += " AND BVZ_FILIAL = '" + xFilial( 'BVZ' ) + "' "
        cQuery += " AND BVZ_PROCES <> '" + PROCESSED + "' "
        cQuery += " AND BVZ_ROBOID = '' "

        If (self:cDB $ "ORACLE")
            cQuery += "	AND ROWNUM = 1 "
        EndIf

        cQuery += " AND D_E_L_E_T_ = ' ' "

    Else
        cQuery := " UPDATE " + RetSqlName('BVZ') + " SET "
        cQuery += " BVZ_PROCES = '" + PROCESSING + "' "
        cQuery += " , BVZ_ROBOID='"+self:toString(self:getValue("processId"))+"' "
        cQuery += " , BVZ_ROBOHR = '" + DToS(Date()) + " " + Time() + "' "
        cQuery += " WHERE R_E_C_N_O_ = (SELECT R_E_C_N_O_ FROM  " + RetSqlName('BVZ') + " WHERE  "
        cQuery += " BVZ_FILIAL = '" + xFilial( 'BVZ' ) + "' "
        cQuery += " AND BVZ_PROCES <> '" + PROCESSED + "' "
        cQuery += " AND BVZ_ROBOID = '' "
        cQuery += " AND D_E_L_E_T_ = ' ' "
        cQuery += "	LIMIT 1 )"

    EndIf

    self:setQuery(cQuery)
    lFound := self:execStatement()

Return lFound

Method getMessage() Class CenDaoBVZ

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BVZ') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND BVZ_PROCES = '" + PROCESSING + "' "
    cQuery += " AND BVZ_ROBOID ='"+self:toString(self:getValue("processId"))+"' "

    self:setQuery(cQuery)
    lFound := self:executaQuery()
    If lFound
        BVZ->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

return lFound

Method setEndProc(nRecno) Class CenDaoBVZ

    Local cQuery := ""
    Local lFound := .F.

    Default nRecno := 0

    If self:cDB <> POSTGRES

        If self:cDB $ MSSQL
            cQuery := " UPDATE TOP(1) "
        Else
            cQuery := " UPDATE "

        EndIf
        cQuery += " " + RetSqlName('BVZ') + " "
        cQuery += " SET "
        cQuery += " BVZ_PROCES = '" + PROCESSED + "' "
        cQuery += " WHERE 1=1 "
        cQuery += " AND R_E_C_N_O_ = '" + AllTrim(Str(nRecno)) + "' "

        If (self:cDB $ "ORACLE")
            cQuery += "	AND ROWNUM = 1 "
        EndIf

    Else
        cQuery := " UPDATE " + RetSqlName('BVZ') + " SET "
        cQuery += " BVZ_PROCES = '" + PROCESSED + "' "
        cQuery += " WHERE R_E_C_N_O_ = (SELECT R_E_C_N_O_ FROM  " + RetSqlName('BVZ') + " "
        cQuery += " WHERE 1=1 "
        cQuery += " AND R_E_C_N_O_ = '" + AllTrim(Str(nRecno)) + "' "
        cQuery += "	LIMIT 1 )"

    EndIf

    self:setQuery(cQuery)
    lFound := self:execStatement()

Return lFound

Method setExpired() Class CenDaoBVZ

    Local cQuery := ""
    Local lFound := .F.

    cQuery := " UPDATE "
    cQuery += " " + RetSqlName('BVZ') + " "
    cQuery += " SET "
    cQuery += " BVZ_ROBOID = '' "
    cQuery += " ,BVZ_PROCES = '" + PROCESSING + "' "
    cQuery += " WHERE 1=1 "
    cQuery += " AND BVZ_ROBOID <> '' "
    cQuery += " AND BVZ_PROCES = '" + PROCESSING + "' "
    cQuery += " AND BVZ_ROBOHR <= '" + SubMinutos(Date(),Time(),2) + "' "
    cQuery += " AND BVZ_ROBOHR <> ' ' "
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
Method bscAddLote() Class CenDaoBVZ

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT BVZ_CDOBRI, BVZ_ANO, BVZ_CDCOMP, 0 AS RECNO "
    cQuery += " FROM " + RetSqlName('BVZ') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	BVZ_FILIAL = '" + xFilial("BVZ") + "' "

    cQuery += " AND BVZ_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))

    cQuery += " AND BVZ_STATUS = '2' "
    cQuery += " AND BVZ_LOTE   = ' ' "
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY BVZ_CDOBRI, BVZ_ANO, BVZ_CDCOMP "

    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()
    If lFound
        BVZ->(DbGoto((self:getAliasTemp())->RECNO))
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
Method qtdGuiComp() Class CenDaoBVZ

    Local nTotal := 0
    Local cQuery := ""

    cQuery := " SELECT COUNT(1) TOTAL "
    cQuery += " FROM " + RetSqlName('BVZ') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	BVZ_FILIAL = '" + xFilial("BVZ") + "' "
    cQuery += " AND BVZ_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BVZ_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND BVZ_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND BVZ_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND BVZ_LOTE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("batchCode")))
    cQuery += " AND BVZ_STATUS = '2' "
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY BVZ_FILIAL, BVZ_CODOPE, BVZ_CDOBRI, BVZ_ANO, BVZ_CDCOMP "

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
Method atuCodLote(nQtdReg) Class CenDaoBVZ

    Local cQuery := ""
    Local lFound := .F.

    If self:cDB <> POSTGRES
        If self:cDB $ MSSQL
            cQuery := " UPDATE TOP("+cValtoChar(nQtdReg)+") "
        Else
            cQuery := " UPDATE "

        EndIf

        cQuery += " " + RetSqlName('BVZ') + " "
        cQuery += " SET BVZ_STATUS = '7', "
        cQuery += " BVZ_LOTE = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("batchCode")))
        cQuery += " WHERE 1=1 "
        cQuery += " AND BVZ_FILIAL = '" + xFilial( 'BVZ' ) + "' "
        cQuery += " AND BVZ_CODOPE = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
        cQuery += " AND BVZ_CDOBRI = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
        cQuery += " AND BVZ_ANO = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
        cQuery += " AND BVZ_CDCOMP = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
        cQuery += " AND BVZ_LOTE = ' ' "
        cQuery += " AND BVZ_STATUS = '2' "
        cQuery += " AND D_E_L_E_T_ = ' ' "

        If (self:cDB $ "ORACLE")
            cQuery += "	AND ROWNUM = 1 "
        EndIf
    Else

        cQuery := " UPDATE " + RetSqlName('BVZ') + " "
        cQuery += " SET BVZ_STATUS = '7', BVZ_LOTE = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("batchCode")))
        cQuery += " WHERE R_E_C_N_O_ =  (SELECT R_E_C_N_O_ FROM " + RetSqlName('BVZ') + " "
        cQuery += " WHERE BVZ_FILIAL = '" + xFilial( 'BVZ' ) + "' "
        cQuery += " AND BVZ_CODOPE = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
        cQuery += " AND BVZ_CDOBRI = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
        cQuery += " AND BVZ_ANO = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
        cQuery += " AND BVZ_CDCOMP = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
        cQuery += " AND BVZ_LOTE = ' ' "
        cQuery += " AND BVZ_STATUS = '2' "
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
Method atuStaANS(cStatAtu,cStatCond) Class CenDaoBVZ

    Local cQuery      := ""
    Local lFound      := .F.
    Default cStatAtu  := "6"
    Default cStatCond := "5"

    cQuery := " UPDATE "
    cQuery += " " + RetSqlName('BVZ') + " "
    cQuery += " SET "
    cQuery += " BVZ_STATUS = ? "
    aAdd(self:aMapBuilder, cStatAtu )
    cQuery += " WHERE 1=1 "
    cQuery += " AND BVZ_FILIAL = '" + xFilial( 'BVZ' ) + "' "
    cQuery += " AND BVZ_LOTE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("batchCode")))
    cQuery += " AND BVZ_STATUS NOT IN ('"+cStatCond+"') "
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
Method staPosLot() Class CenDaoBVZ

    Local cQuery := ""
    Local lFound := .F.

    cQuery := " UPDATE " + RetSqlName('BVZ') + " "
    cQuery += " SET "
    cQuery += " BVZ_STATUS = '8' "
    cQuery += " WHERE 1=1 "
    cQuery += " AND BVZ_FILIAL = '" + xFilial( 'BVZ' ) + "' "
    cQuery += " AND BVZ_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BVZ_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND BVZ_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND BVZ_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND BVZ_LOTE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("batchCode")))
    cQuery += " AND BVZ_STATUS = '7' "
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
Method delLote() Class CenDaoBvz

    Local cSql      := ""
    Local lFound    := .F.

    cSql := "UPDATE " + RetSqlName("BVZ") + " "
    cSql += " SET BVZ_LOTE = '' , BVZ_STATUS = '2' "
    cSql += " WHERE 1=1 "
    cSql += " AND BVZ_FILIAL = '" + xFilial("BVZ") + "' "
    cSql += " AND BVZ_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BVZ_ANO")))
    cSql += " AND BVZ_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BVZ_CDCOMP")))
    cSql += " AND BVZ_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BVZ_CDOBRI")))
    cSql += " AND BVZ_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BVZ_CODOPE")))
    cSql += " AND BVZ_LOTE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BVZ_LOTE")))
    cSql += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')

    self:setQuery(self:queryBuilder(cSql))
    lFound := self:execStatement()

Return lFound
