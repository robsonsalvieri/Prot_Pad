#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class CenDaoBn0 from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    Method atuCodLote()
    Method bscCertXML() 
    Method delLote()

EndClass

Method New(aFields) Class CenDaoBn0
	_Super:New(aFields)
    self:cAlias := "BN0"
    self:cfieldOrder := "BN0_ANO,BN0_CDCOMP,BN0_CDOBRI,BN0_CODOPE,BN0_DTPRGU,BN0_LOTE,BN0_NMGOPE,BN0_TIPO,BN0_DECNUM"
Return self

Method buscar() Class CenDaoBn0
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		BN0->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoBn0
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoBn0

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BN0') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	BN0_FILIAL = '" + xFilial("BN0") + "' "

    cQuery += " AND BN0_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND BN0_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND BN0_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND BN0_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BN0_DTPRGU = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("formProcDt")))
    cQuery += " AND BN0_LOTE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("batchCode")))
    cQuery += " AND BN0_NMGOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorFormNumber")))
    cQuery += " AND BN0_TIPO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("certificateType")))
    cQuery += " AND BN0_DECNUM = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("certificateNumber")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method commit(lInclui) Class CenDaoBn0

    Default lInclui := .F.

	If BN0->(RecLock("BN0",lInclui))
		
        BN0->BN0_FILIAL := xFilial("BN0")
        If lInclui
        
            BN0->BN0_ANO := _Super:normalizeType(BN0->BN0_ANO,self:getValue("referenceYear")) /* Column BN0_ANO */
            BN0->BN0_CDCOMP := _Super:normalizeType(BN0->BN0_CDCOMP,self:getValue("commitmentCode")) /* Column BN0_CDCOMP */
            BN0->BN0_CDOBRI := _Super:normalizeType(BN0->BN0_CDOBRI,self:getValue("requirementCode")) /* Column BN0_CDOBRI */
            BN0->BN0_CODOPE := _Super:normalizeType(BN0->BN0_CODOPE,self:getValue("operatorRecord")) /* Column BN0_CODOPE */
            BN0->BN0_DTPRGU := _Super:normalizeType(BN0->BN0_DTPRGU,self:getValue("formProcDt")) /* Column BN0_DTPRGU */
            BN0->BN0_LOTE := _Super:normalizeType(BN0->BN0_LOTE,self:getValue("batchCode")) /* Column BN0_LOTE */
            BN0->BN0_NMGOPE := _Super:normalizeType(BN0->BN0_NMGOPE,self:getValue("operatorFormNumber")) /* Column BN0_NMGOPE */
            BN0->BN0_TIPO := _Super:normalizeType(BN0->BN0_TIPO,self:getValue("certificateType")) /* Column BN0_TIPO */
            BN0->BN0_DECNUM := _Super:normalizeType(BN0->BN0_DECNUM,self:getValue("certificateNumber")) /* Column BN0_DECNUM */

        EndIf


        BN0->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} atuCodLote
    Atualiza o numero do lote nas guias

    @type  Class
    @author renan.almeida
    @since 03/12/2019
/*/
//------------------------------------------------------------------------------------------
Method atuCodLote() Class CenDaoBN0

    Local cQuery := ""
    Local lFound := .F.

    cQuery += " UPDATE "+RetSqlName('BN0')+" SET BN0_LOTE = ? FROM "+RetSqlName('BN0')+" BN0 "
    aAdd(self:aMapBuilder, self:toString(self:getValue("batchCode")))
    cQuery += " INNER JOIN "+RetSqlName('BKR')+" BKR "
	cQuery += " ON  BKR.BKR_FILIAL = '"+xFilial("BKR")+"' "
	cQuery += " AND BKR.BKR_CODOPE = BN0.BN0_CODOPE "
	cQuery += " AND BKR.BKR_NMGOPE = BN0.BN0_NMGOPE "
	cQuery += " AND BKR.BKR_CDOBRI = BN0.BN0_CDOBRI "
	cQuery += " AND BKR.BKR_ANO    = BN0.BN0_ANO "
	cQuery += " AND BKR.BKR_CDCOMP = BN0.BN0_CDCOMP "
	cQuery += " AND BKR.BKR_LOTE   = ? "
    cQuery += " AND BKR.BKR_DTPRGU = BN0.BN0_DTPRGU "
    aAdd(self:aMapBuilder, self:toString(self:getValue("batchCode")))
	cQuery += " AND BKR.D_E_L_E_T_ = ' ' "

    cQuery += " WHERE "
	cQuery += " BN0.BN0_FILIAL = '"+xFilial("BN0")+"' "
    cQuery += " AND BN0.BN0_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BN0.BN0_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND BN0.BN0_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND BN0.BN0_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
	cQuery += " AND BN0.BN0_LOTE = ' ' "
    cQuery += " AND BN0.D_E_L_E_T_ = ' ' " 

    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:execStatement()

Return lFound


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} bscMovExcl
    Busca movimentacoes para realizar a exclusao

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method bscCertXML() Class CenDaoBN0

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BN0') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	BN0_FILIAL = '" + xFilial("BN0") + "' "
    cQuery += " AND BN0_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND BN0_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND BN0_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND BN0_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BN0_DTPRGU = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("formProcDt")))
    cQuery += " AND BN0_LOTE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("batchCode")))
    cQuery += " AND BN0_NMGOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorFormNumber")))
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY BN0_TIPO "

    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()
    If lFound 
		BN0->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
    
return lFound

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} delLote
    Atualiza o status do lote após ele ser deletado na BKW

    @type  Class
    @author vinicius.nicolau
    @since 03/08/2020
/*/
//------------------------------------------------------------------------------------------
Method delLote() Class CenDaoBn0

    Local cSql      := ""
    Local lFound    := .F.

    cSql := "UPDATE " + RetSqlName("BN0") + " "
    cSql += " SET BN0_LOTE = '' "
    cSql += " WHERE 1=1 "
    cSql += " AND BN0_FILIAL = '" + xFilial("BN0") + "' " 
    cSql += " AND BN0_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BN0_ANO")))
    cSql += " AND BN0_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BN0_CDCOMP")))
    cSql += " AND BN0_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BN0_CDOBRI")))
    cSql += " AND BN0_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BN0_CODOPE")))
    cSql += " AND BN0_LOTE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BN0_LOTE")))
    cSql += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')                                                                                                                                                          
    
    self:setQuery(self:queryBuilder(cSql))
    lFound := self:execStatement()

Return lFound