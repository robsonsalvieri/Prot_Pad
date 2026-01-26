#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2
#Define PROCESSING '0'
#Define PROCESSED '1'
#Define MSSQL     "MSSQL"
#Define POSTGRES  "POSTGRES"
#Define ORACLE    "ORACLE"

Class CenDaoB9T from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method commit()
    Method delete()
    Method bscChaPrim()
    Method bscMovPend()
    Method bscMovProc()
    Method bscUltChv()
    Method bscMovExcl()
    Method getQtdIdVPre()
    Method setProcessing()
    Method getMessage()
    Method setEndProc(nRecno)
    Method setExpired()
    Method GetKeyAPI()
    Method bscAddLote()
    Method qtdGuiComp()
    Method atuCodLote(nQtdReg)
    Method atuStaANS(cStatAtu,cStatCond)
    Method staPosLot()
    Method delLote()

EndClass

Method New(aFields) Class CenDaoB9T
    _Super:New(aFields)
    self:cAlias := "B9T"
    self:cfieldOrder := "B9T_ANO,B9T_CDCOMP,B9T_CDOBRI,B9T_CODOPE,B9T_COMCOB,B9T_CPFCNP,B9T_LOTE,B9T_RGOPIN,B9T_IDVLRP,B9T_CNES,B9T_CDMNPR"
Return self

Method buscar() Class CenDaoB9T
    Local lFound := .F.
    lFound := _Super:buscar()
    If lFound
        B9T->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoB9T
    Local lFound := .F.
    if self:bscChaPrim()
        lFound := _Super:delete()
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoB9T

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B9T') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	B9T_FILIAL = '" + xFilial("B9T") + "' "

    cQuery += " AND B9T_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND B9T_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND B9T_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND B9T_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND B9T_COMCOB = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("periodCover")))
    cQuery += " AND B9T_CPFCNP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerCpfCnpj")))
    cQuery += " AND B9T_LOTE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("batchCode")))
    cQuery += " AND B9T_RGOPIN = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("ansRecordNumber")))
    cQuery += " AND B9T_IDVLRP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("presetValueIdent")))
    cQuery += " AND B9T_CNES = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("cnes")))
    cQuery += " AND B9T_CDMNPR = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("cityOfProvider")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()

return lFound

Method commit(lInclui) Class CenDaoB9T

    Default lInclui := .F.

    If B9T->(RecLock("B9T",lInclui))

        B9T->B9T_FILIAL := xFilial("B9T")
        If lInclui

            B9T->B9T_ANO := _Super:normalizeType(B9T->B9T_ANO,self:getValue("referenceYear")) /* Column B9T_ANO */
            B9T->B9T_CDCOMP := _Super:normalizeType(B9T->B9T_CDCOMP,self:getValue("commitmentCode")) /* Column B9T_CDCOMP */
            B9T->B9T_CDOBRI := _Super:normalizeType(B9T->B9T_CDOBRI,self:getValue("requirementCode")) /* Column B9T_CDOBRI */
            B9T->B9T_CODOPE := _Super:normalizeType(B9T->B9T_CODOPE,self:getValue("operatorRecord")) /* Column B9T_CODOPE */
            B9T->B9T_COMCOB := _Super:normalizeType(B9T->B9T_COMCOB,self:getValue("periodCover")) /* Column B9T_COMCOB */
            B9T->B9T_CPFCNP := _Super:normalizeType(B9T->B9T_CPFCNP,self:getValue("providerCpfCnpj")) /* Column B9T_CPFCNP */
            B9T->B9T_LOTE := _Super:normalizeType(B9T->B9T_LOTE,self:getValue("batchCode")) /* Column B9T_LOTE */
            B9T->B9T_RGOPIN := _Super:normalizeType(B9T->B9T_RGOPIN,self:getValue("ansRecordNumber")) /* Column B9T_RGOPIN */
            B9T->B9T_IDVLRP := _Super:normalizeType(B9T->B9T_IDVLRP,self:getValue("presetValueIdent")) /* Column B9T_IDVLRP */
            B9T->B9T_CNES := _Super:normalizeType(B9T->B9T_CNES,self:getValue("cnes")) /* Column B9T_CNES */
            B9T->B9T_CDMNPR := _Super:normalizeType(B9T->B9T_CDMNPR,self:getValue("cityOfProvider")) /* Column B9T_CDMNPR */

        EndIf

        B9T->B9T_STATUS := _Super:normalizeType(B9T->B9T_STATUS,self:getValue("status")) /* Column B9T_STATUS */
        B9T->B9T_TPRGMN := _Super:normalizeType(B9T->B9T_TPRGMN,self:getValue("monitoringRecordType")) /* Column B9T_TPRGMN */
        B9T->B9T_VLRPRE := _Super:normalizeType(B9T->B9T_VLRPRE,self:getValue("presetValue")) /* Column B9T_VLRPRE */
        B9T->B9T_DATPRO := _Super:normalizeType(B9T->B9T_DATPRO,self:getValue("processingDate")) /* Column B9T_DATPRO */
        B9T->B9T_HORPRO := _Super:normalizeType(B9T->B9T_HORPRO,self:getValue("processingTime")) /* Column B9T_HORPRO */
        B9T->B9T_IDEPRE := _Super:normalizeType(B9T->B9T_IDEPRE,self:getValue("providerIdentifier")) /* Column B9T_IDEPRE */
        B9T->B9T_DATINC := _Super:normalizeType(B9T->B9T_DATINC,self:getValue("inclusionDate")) /* Column B9T_DATINC */
        B9T->B9T_HORINC := _Super:normalizeType(B9T->B9T_HORINC,self:getValue("inclusionTime")) /* Column B9T_HORINC */

        B9T->(MsUnlock())
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
Method bscMovPend() Class CenDaoB9T

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B9T') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	B9T_FILIAL = '" + xFilial("B9T") + "' "

    cQuery += " AND B9T_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND B9T_CNES = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("cnes")))
    cQuery += " AND B9T_CPFCNP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerCpfCnpj")))
    cQuery += " AND B9T_COMCOB = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("periodCover")))
    cQuery += " AND B9T_CDMNPR = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("cityOfProvider")))
    cQuery += " AND B9T_RGOPIN = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("ansRecordNumber")))
    cQuery += " AND B9T_IDVLRP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("presetValueIdent")))
    cQuery += " AND B9T_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND B9T_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND B9T_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))

    cQuery += " AND ((B9T_STATUS='') OR (B9T_STATUS='1') OR (B9T_STATUS='2') OR (B9T_STATUS='3') OR (B9T_STATUS='7')) " //1=Pendente Envio;2=Criticado;3=Pronto para o Envio;7=Pendente Geração de Arquivo
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY B9T_DATPRO DESC, B9T_HORPRO DESC "

    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()
    If lFound
        B9T->(DbGoto((self:getAliasTemp())->RECNO))
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
Method bscMovProc() Class CenDaoB9T

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B9T') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	B9T_FILIAL = '" + xFilial("B9T") + "' "

    cQuery += " AND B9T_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND B9T_CNES = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("cnes")))
    cQuery += " AND B9T_CPFCNP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerCpfCnpj")))
    cQuery += " AND B9T_COMCOB = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("periodCover")))
    cQuery += " AND B9T_CDMNPR = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("cityOfProvider")))
    cQuery += " AND B9T_RGOPIN = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("ansRecordNumber")))
    cQuery += " AND B9T_IDVLRP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("presetValueIdent")))
    cQuery += " AND B9T_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND B9T_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND B9T_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))

    cQuery += " AND ((B9T_STATUS='4') OR (B9T_STATUS='6') OR (B9T_STATUS='8') ) " //4=Em processamento ANS;5=Criticado pela ANS;6=Finalizado
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY B9T_DATPRO DESC, B9T_HORPRO DESC "

    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()
    If lFound
        B9T->(DbGoto((self:getAliasTemp())->RECNO))
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
Method bscUltChv() Class CenDaoB9T

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B9T') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	B9T_FILIAL = '" + xFilial("B9T") + "' "

    cQuery += " AND B9T_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND B9T_CNES = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("cnes")))
    cQuery += " AND B9T_CPFCNP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerCpfCnpj")))
    cQuery += " AND B9T_COMCOB = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("periodCover")))
    cQuery += " AND B9T_CDMNPR = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("cityOfProvider")))
    cQuery += " AND B9T_RGOPIN = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("ansRecordNumber")))
    cQuery += " AND B9T_IDVLRP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("presetValueIdent")))
    cQuery += " AND B9T_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))

    if !Empty(self:getValue("referenceYear"))
        cQuery += " AND B9T_ANO = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    endIf

    if !Empty(self:getValue("commitmentCode"))
        cQuery += " AND B9T_CDCOMP = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    endIf

    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY B9T_DATPRO DESC, B9T_HORPRO DESC "

    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()
    If lFound
        B9T->(DbGoto((self:getAliasTemp())->RECNO))
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
Method bscMovExcl() Class CenDaoB9T

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B9T') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	B9T_FILIAL = '" + xFilial("B9T") + "' "

    cQuery += " AND B9T_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND B9T_CNES = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("cnes")))
    cQuery += " AND B9T_CPFCNP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerCpfCnpj")))
    cQuery += " AND B9T_CDMNPR = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("cityOfProvider")))
    cQuery += " AND B9T_RGOPIN = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("ansRecordNumber")))
    cQuery += " AND B9T_IDVLRP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("presetValueIdent")))
    cQuery += " AND B9T_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))

    if !Empty(self:getValue("periodCover"))
        cQuery += " AND B9T_COMCOB = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("periodCover")))
    endIf

    cQuery += " AND B9T_STATUS <> '5' " //5=Criticado pela ANS
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY B9T_DATPRO DESC, B9T_HORPRO DESC "

    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()
    If lFound
        B9T->(DbGoto((self:getAliasTemp())->RECNO))
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
Method getQtdIdVPre() Class CenDaoB9T

    Local nTotal := 0
    Local cQuery := ""

    cQuery := " SELECT Count(1) TOTAL "
    cQuery += " FROM " + RetSqlName('B9T') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	B9T_FILIAL = '" + xFilial("B9T") + "' "
    cQuery += " AND B9T_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND B9T_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND B9T_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND B9T_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND B9T_TPRGMN = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("monitoringRecordType")))
    cQuery += " AND B9T_IDVLRP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("presetValueIdent")))
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY B9T_FILIAL, B9T_CODOPE, B9T_CDOBRI, B9T_ANO, B9T_CDCOMP, B9T_TPRGMN,  B9T_IDVLRP "

    self:setQuery(self:queryBuilder(cQuery))
    If self:executaQuery()
        nTotal := (self:getAliasTemp())->TOTAL
    EndIf
    self:fechaQuery()

return nTotal

Method setProcessing() Class CenDaoB9T

    Local cQuery := ""
    Local lFound := .F.

    If self:cDB <> POSTGRES

        If self:cDB $ MSSQL
            cQuery := " UPDATE TOP(1) "
        Else
            cQuery := " UPDATE "

        EndIf

        cQuery += " " + RetSqlName('B9T') + " "
        cQuery += " SET "
        cQuery += " B9T_PROCES = '" + PROCESSING + "' "
        cQuery += " , B9T_ROBOID='"+self:toString(self:getValue("processId"))+"' "
        cQuery += " , B9T_ROBOHR = '" + DToS(Date()) + " " + Time() + "' "
        cQuery += " WHERE 1=1 "
        cQuery += " AND B9T_FILIAL = '" + xFilial( 'B9T' ) + "' "
        cQuery += " AND B9T_PROCES <> '" + PROCESSED + "' "
        cQuery += " AND B9T_ROBOID = '' "

        If (self:cDB $ "ORACLE")
            cQuery += "	AND ROWNUM = 1 "
        EndIf

        cQuery += " AND D_E_L_E_T_ = ' ' "

    Else
        cQuery := " UPDATE " + RetSqlName('B9T') + " SET "
        cQuery += " B9T_PROCES = '" + PROCESSING + "' "
        cQuery += " , B9T_ROBOID='"+self:toString(self:getValue("processId"))+"' "
        cQuery += " , B9T_ROBOHR = '" + DToS(Date()) + " " + Time() + "' "
        cQuery += " WHERE R_E_C_N_O_ = (SELECT R_E_C_N_O_ FROM  " + RetSqlName('B9T') + " WHERE  "
        cQuery += " B9T_FILIAL = '" + xFilial( 'B9T' ) + "' "
        cQuery += " AND B9T_PROCES <> '" + PROCESSED + "' "
        cQuery += " AND B9T_ROBOID = '' "
        cQuery += " AND D_E_L_E_T_ = ' ' "
        cQuery += "	LIMIT 1 )"

    EndIf

    self:setQuery(cQuery)
    lFound := self:execStatement()

Return lFound

Method getMessage() Class CenDaoB9T

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B9T') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND B9T_PROCES = '" + PROCESSING + "' "
    cQuery += " AND B9T_ROBOID ='"+self:toString(self:getValue("processId"))+"' "

    self:setQuery(cQuery)
    lFound := self:executaQuery()
    If lFound
        B9T->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

return lFound

Method setEndProc(nRecno) Class CenDaoB9T

    Local cQuery := ""
    Local lFound := .F.

    Default nRecno := 0

    If self:cDB <> POSTGRES

        If self:cDB $ MSSQL
            cQuery := " UPDATE TOP(1) "
        Else
            cQuery := " UPDATE "

        EndIf
        cQuery += " " + RetSqlName('B9T') + " "
        cQuery += " SET "
        cQuery += " B9T_PROCES = '" + PROCESSED + "' "
        cQuery += " WHERE 1=1 "
        cQuery += " AND R_E_C_N_O_ = '" + AllTrim(Str(nRecno)) + "' "

        If (self:cDB $ "ORACLE")
            cQuery += "	AND ROWNUM = 1 "
        EndIf

    Else
        cQuery := " UPDATE " + RetSqlName('B9T') + " SET "
        cQuery += " B9T_PROCES = '" + PROCESSED + "' "
        cQuery += " WHERE R_E_C_N_O_ = (SELECT R_E_C_N_O_ FROM  " + RetSqlName('B9T') + " "
        cQuery += " WHERE 1=1 "
        cQuery += " AND R_E_C_N_O_ = '" + AllTrim(Str(nRecno)) + "' "
        cQuery += "	LIMIT 1 )"

    EndIf

    self:setQuery(cQuery)
    lFound := self:execStatement()

Return lFound

Method setExpired() Class CenDaoB9T

    Local cQuery := ""
    Local lFound := .F.

    cQuery := " UPDATE "
    cQuery += " " + RetSqlName('B9T') + " "
    cQuery += " SET "
    cQuery += " B9T_ROBOID = '' "
    cQuery += " ,B9T_PROCES = '" + PROCESSING + "' "
    cQuery += " WHERE 1=1 "
    cQuery += " AND B9T_ROBOID <> '' "
    cQuery += " AND B9T_PROCES = '" + PROCESSING + "' "
    cQuery += " AND B9T_ROBOHR <= '" + SubMinutos(Date(),Time(),2) + "' "
    cQuery += " AND B9T_ROBOHR <> ' ' "
    cQuery += " AND D_E_L_E_T_ = ' ' "

    self:setQuery(cQuery)
    lFound := self:execStatement()
Return lFound

Method GetKeyAPI() Class CenDaoB9T

    Local cQuery    := ''
    Local lFound    := .F.

    cQuery := " SELECT  "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B9T') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	B9T_FILIAL = '" + xFilial("B9T") + "' "
    cQuery += " AND B9T_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND B9T_NMGPRE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("providerFormNumber")))
    cQuery += " AND B9T_MATRIC = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("registration")))
    cQuery += " AND B9T_DTPRGU = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("formProcDt")))
    cQuery += " AND D_E_L_E_T_ = ' ' "

    self:setQuery(self:queryBuilder(cQuery))
    lFound  :=  self:executaQuery()

Return lFound

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} bscAddLote
    Busca guias para adicionar no lote

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method bscAddLote() Class CenDaoB9T

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT B9T_CDOBRI, B9T_ANO, B9T_CDCOMP, 0 AS RECNO "
    cQuery += " FROM " + RetSqlName('B9T') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	B9T_FILIAL = '" + xFilial("B9T") + "' "

    cQuery += " AND B9T_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))

    cQuery += " AND B9T_STATUS = '2' "
    cQuery += " AND B9T_LOTE   = ' ' "
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY B9T_CDOBRI, B9T_ANO, B9T_CDCOMP "

    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()
    If lFound
        B9T->(DbGoto((self:getAliasTemp())->RECNO))
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
Method qtdGuiComp() Class CenDaoB9T

    Local nTotal := 0
    Local cQuery := ""

    cQuery := " SELECT COUNT(1) TOTAL "
    cQuery += " FROM " + RetSqlName('B9T') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	B9T_FILIAL = '" + xFilial("B9T") + "' "
    cQuery += " AND B9T_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND B9T_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND B9T_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND B9T_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND B9T_LOTE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("batchCode")))
    cQuery += " AND B9T_STATUS = '2' "
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY B9T_FILIAL, B9T_CODOPE, B9T_CDOBRI, B9T_ANO, B9T_CDCOMP "

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
Method atuCodLote(nQtdReg) Class CenDaoB9T

    Local cQuery := ""
    Local lFound := .F.


    If self:cDB <> POSTGRES
        If self:cDB $ MSSQL
            cQuery := " UPDATE TOP("+cValtoChar(nQtdReg)+") "
        Else
            cQuery := " UPDATE "

        EndIf

        cQuery += " " + RetSqlName('B9T') + " "
        cQuery += " SET B9T_STATUS = '7', "
        cQuery += " B9T_LOTE = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("batchCode")))
        cQuery += " WHERE 1=1 "
        cQuery += " AND B9T_FILIAL = '" + xFilial( 'B9T' ) + "' "
        cQuery += " AND B9T_CODOPE = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
        cQuery += " AND B9T_CDOBRI = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
        cQuery += " AND B9T_ANO = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
        cQuery += " AND B9T_CDCOMP = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
        cQuery += " AND B9T_LOTE = ' ' "
        cQuery += " AND B9T_STATUS = '2' "
        cQuery += " AND D_E_L_E_T_ = ' ' "

        If (self:cDB $ "ORACLE")
            cQuery += "	AND ROWNUM = 1 "
        EndIf
    Else

        cQuery := " UPDATE " + RetSqlName('B9T') + " "
        cQuery += " SET B9T_STATUS = '7', B9T_LOTE = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("batchCode")))
        cQuery += " WHERE R_E_C_N_O_ =  (SELECT R_E_C_N_O_ FROM " + RetSqlName('B9T') + " "
        cQuery += " WHERE B9T_FILIAL = '" + xFilial( 'B9T' ) + "' "
        cQuery += " AND B9T_CODOPE = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
        cQuery += " AND B9T_CDOBRI = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
        cQuery += " AND B9T_ANO = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
        cQuery += " AND B9T_CDCOMP = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
        cQuery += " AND B9T_LOTE = ' ' "
        cQuery += " AND B9T_STATUS = '2' "
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
Method atuStaANS(cStatAtu,cStatCond) Class CenDaoB9T

    Local cQuery      := ""
    Local lFound      := .F.
    Default cStatAtu  := "6"
    Default cStatCond := "5"

    cQuery := " UPDATE "
    cQuery += " " + RetSqlName('B9T') + " "
    cQuery += " SET "
    cQuery += " B9T_STATUS = ? "
    aAdd(self:aMapBuilder, cStatAtu )
    cQuery += " WHERE 1=1 "
    cQuery += " AND B9T_FILIAL = '" + xFilial( 'B9T' ) + "' "
    cQuery += " AND B9T_LOTE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("batchCode")))
    cQuery += " AND B9T_STATUS NOT IN ('"+cStatCond+"') "
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
Method staPosLot() Class CenDaoB9T

    Local cQuery := ""
    Local lFound := .F.

    cQuery := " UPDATE " + RetSqlName('B9T') + " "
    cQuery += " SET "
    cQuery += " B9T_STATUS = '8' "
    cQuery += " WHERE 1=1 "
    cQuery += " AND B9T_FILIAL = '" + xFilial( 'B9T' ) + "' "
    cQuery += " AND B9T_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND B9T_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND B9T_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND B9T_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND B9T_LOTE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("batchCode")))
    cQuery += " AND B9T_STATUS = '7' "
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
Method delLote() Class CenDaoB9T

    Local cSql      := ""
    Local lFound    := .F.

    cSql := "UPDATE " + RetSqlName("B9T") + " "
    cSql += " SET B9T_LOTE = '', B9T_STATUS = '2' "
    cSql += " WHERE 1=1 "
    cSql += " AND B9T_FILIAL = '" + xFilial("B9T") + "' "
    cSql += " AND B9T_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("B9T_ANO")))
    cSql += " AND B9T_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("B9T_CDCOMP")))
    cSql += " AND B9T_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("B9T_CDOBRI")))
    cSql += " AND B9T_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("B9T_CODOPE")))
    cSql += " AND B9T_LOTE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("B9T_LOTE")))
    cSql += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')

    self:setQuery(self:queryBuilder(cSql))
    lFound := self:execStatement()

Return lFound
