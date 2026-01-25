#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class CenDaoCrit from CenDao

    Method New(aFields) Constructor
    Method buscar()
    Method delete()
    Method bscChaPrim()
    Method lmpCriticas()
    Method commit(lInclui)
    Method insCritGrp(cSelectGrp)
    Method bscCritBKT(oCltBKR)
    Method bscQtdCrit()
    Method ajuCriStatus(cCamposChave)

EndClass

Method New(aFields) Class CenDaoCrit
    _Super:New(aFields)
    self:cAlias := "B3F"
    self:cfieldOrder := "B3F_CDCOMP,B3F_CDOBRI,B3F_CHVORI,B3F_CODCRI,B3F_CODOPE,B3F_DESORI,B3F_IDEORI,B3F_ORICRI,B3F_ANO,B3F_TIPO"
Return self

Method buscar() Class CenDaoCrit
    Local lFound := .F.
    lFound := _Super:buscar()
    If lFound
        B3F->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoCrit
    Local lFound := .F.
    if self:bscChaPrim()
        lFound := _Super:delete()
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoCrit

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B3F') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	B3F_FILIAL = '" + xFilial("B3F") + "' "

    cQuery += " AND B3F_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND B3F_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND B3F_CHVORI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("originRegAcknowlegm")))
    cQuery += " AND B3F_CODCRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("reviewCode")))
    cQuery += " AND B3F_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND B3F_DESORI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("originDescription")))
    cQuery += " AND B3F_IDEORI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("originIdentKey")))
    cQuery += " AND B3F_ORICRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("reviewOrigin")))
    cQuery += " AND B3F_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitReferenceYear")))
    cQuery += " AND B3F_TIPO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("type")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()

return lFound

Method lmpCriticas() Class CenDaoCrit

    Local lFound := .F.
    Local cQuery := ""

    cQuery += " DELETE FROM " + RetSqlName('B3F') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	B3F_FILIAL = '" + xFilial("B3F") + "' "
    cQuery += " AND B3F_ORICRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("reviewOrigin")))
    If !Empty(self:getValue("operatorRecord"))
        cQuery += " AND B3F_CODOPE = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    EndIf
    If !Empty(self:getValue("reviewCode"))
        cQuery += " AND B3F_CODCRI = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("reviewCode")))
    EndIf
    If !Empty(self:getValue("originRegAcknowlegm"))
        cQuery += " AND B3F_CHVORI = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("originRegAcknowlegm")))
    EndIf
    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:execStatement()

return lFound

Method insCritGrp(cSelectGrp) Class CenDaoCrit

    Local lFound := .F.
    Local cQuery := ""

    cQuery += " INSERT INTO "+ RetSqlName('B3F') + " ( "
    cQuery += "     B3F_FILIAL "
    cQuery += "     ,B3F_CODOPE "
    cQuery += "     ,B3F_CDOBRI "
    cQuery += "     ,B3F_CDCOMP "
    cQuery += "     ,B3F_ANO "
    cQuery += "     ,B3F_ORICRI "
    cQuery += "     ,B3F_CHVORI "
    cQuery += "     ,B3F_CODCRI "
    cQuery += "     ,B3F_DESORI "
    cQuery += "     ,B3F_IDEORI "
    cQuery += "     ,B3F_TIPO "
    cQuery += "     ,B3F_CAMPOS "
    cQuery += "     ,B3F_SOLUCA "
    cQuery += "     ,B3F_STATUS "
    cQuery += "     ,B3F_CRIANS "
    cQuery += "     ,B3F_DESCRI "
    cQuery += "     ,R_E_C_N_O_ "
    cQuery += " ) "

    cQuery += cSelectGrp
    self:setQuery(cQuery)
    lFound := self:execStatement()

return lFound

Method commit(lInclui) Class CenDaoCrit

    Default lInclui := .F.

    If B3F->(RecLock("B3F",lInclui))

        B3F->B3F_FILIAL := xFilial("B3F")
        If lInclui

            B3F->B3F_CDCOMP := _Super:normalizeType(B3F->B3F_CDCOMP,self:getValue("commitmentCode")) /* Column B3F_CDCOMP */
            B3F->B3F_CDOBRI := _Super:normalizeType(B3F->B3F_CDOBRI,self:getValue("requirementCode")) /* Column B3F_CDOBRI */
            B3F->B3F_CHVORI := _Super:normalizeType(B3F->B3F_CHVORI,self:getValue("originRegAcknowlegm")) /* Column B3F_CHVORI */
            B3F->B3F_CODCRI := _Super:normalizeType(B3F->B3F_CODCRI,self:getValue("reviewCode")) /* Column B3F_CODCRI */
            B3F->B3F_CODOPE := _Super:normalizeType(B3F->B3F_CODOPE,self:getValue("operatorRecord")) /* Column B3F_CODOPE */
            B3F->B3F_DESORI := _Super:normalizeType(B3F->B3F_DESORI,self:getValue("originDescription")) /* Column B3F_DESORI */
            B3F->B3F_IDEORI := _Super:normalizeType(B3F->B3F_IDEORI,self:getValue("originIdentKey")) /* Column B3F_IDEORI */
            B3F->B3F_ORICRI := _Super:normalizeType(B3F->B3F_ORICRI,self:getValue("reviewOrigin")) /* Column B3F_ORICRI */
            B3F->B3F_ANO := _Super:normalizeType(B3F->B3F_ANO,self:getValue("commitReferenceYear")) /* Column B3F_ANO */
            B3F->B3F_TIPO := _Super:normalizeType(B3F->B3F_TIPO,self:getValue("type")) /* Column B3F_TIPO */

        EndIf

        B3F->B3F_CAMPOS := _Super:normalizeType(B3F->B3F_CAMPOS,self:getValue("affectedFields")) /* Column B3F_CAMPOS */
        B3F->B3F_SOLUCA := _Super:normalizeType(B3F->B3F_SOLUCA,self:getValue("suggestOfRevSolution")) /* Column B3F_SOLUCA */
        B3F->B3F_STATUS := _Super:normalizeType(B3F->B3F_STATUS,self:getValue("reviewStatus")) /* Column B3F_STATUS */
        B3F->B3F_CRIANS := _Super:normalizeType(B3F->B3F_CRIANS,self:getValue("ansCritCode")) /* Column B3F_CRIANS */
        B3F->B3F_DESCRI := _Super:normalizeType(B3F->B3F_DESCRI,self:getValue("reviewDescription")) /* Column B3F_DESCRI */

        B3F->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound


Method bscCritBKT(oCltBKR) Class CenDaoCrit

    Local lFound := .F.
    Local cQuery := ""

    cQuery := " SELECT B3F_CDCOMP, B3F_CDOBRI, B3F_CHVORI ,B3F_CODCRI, B3F_CODOPE, B3F_DESORI, B3F_IDEORI, "
    cQuery += " B3F_ORICRI, B3F_ANO, B3F_TIPO, B3F_CAMPOS, B3F_SOLUCA, B3F_STATUS, B3F_CRIANS ,B3F_DESCRI, 0 AS RECNO "
    cQuery += " FROM " + RetSqlName('B3F') + " B3F "
    cQuery += " INNER JOIN "+RetSqlName("BKR")+" BKR "
    cQuery += "     ON BKR_FILIAL = '"+xFilial("BKR")+"' "
    //cQuery += "     AND BKR.R_E_C_N_O_ = " + cValtoChar(nRecnoBKR)
    cQuery += "     AND BKR_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(oCltBKR:getValue("referenceYear")))
    cQuery += "     AND BKR_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(oCltBKR:getValue("commitmentCode")))
    cQuery += "     AND BKR_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(oCltBKR:getValue("requirementCode")))
    cQuery += "     AND BKR_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(oCltBKR:getValue("operatorRecord")))
    cQuery += "     AND BKR_NMGOPE = ? "
    aAdd(self:aMapBuilder, self:toString(oCltBKR:getValue("operatorFormNumber")))
    cQuery += "     AND BKR_DTPRGU = ? "
    aAdd(self:aMapBuilder, self:toString(oCltBKR:getValue("formProcDt")))
    cQuery += "     AND BKR_LOTE = ? "
    aAdd(self:aMapBuilder, self:toString(oCltBKR:getValue("batchCode")))

    cQuery += "     AND BKR.D_E_L_E_T_ = ' ' "
    cQuery += " INNER JOIN "+RetSqlName("BKS")+" BKS "
    cQuery += "		ON BKS_FILIAL = '"+xFilial("BKS")+"' "
    cQuery += "		AND BKS_CODOPE = BKR_CODOPE "
    cQuery += "		AND BKS_NMGOPE = BKR_NMGOPE "
    cQuery += "		AND BKS_CDOBRI = BKR_CDOBRI "
    cQuery += "		AND BKS_ANO    = BKR_ANO "
    cQuery += "		AND BKS_CDCOMP = BKR_CDCOMP "
    cQuery += "		AND BKS_LOTE   = BKR_LOTE "
    cQuery += "		AND BKS_DTPRGU = BKR_DTPRGU "
    cQuery += "		AND BKS.D_E_L_E_T_ = ' '  "

    cQuery += " INNER JOIN "+RetSqlName("BKT")+" BKT "
    cQuery += "		ON BKT_FILIAL = '"+xFilial("BKT")+"' "
    cQuery += "		AND BKT_CODOPE = BKR_CODOPE "
    cQuery += "		AND BKT_NMGOPE = BKR_NMGOPE "
    cQuery += "		AND BKT_CDOBRI = BKR_CDOBRI "
    cQuery += "		AND BKT_ANO    = BKR_ANO "
    cQuery += "		AND BKT_CDCOMP = BKR_CDCOMP "
    cQuery += "		AND BKT_LOTE   = BKR_LOTE "
    cQuery += "		AND BKT_DTPRGU = BKR_DTPRGU "
    cQuery += "		AND BKT_CODTAB = BKT_CODTAB "
    cQuery += "		AND BKT_CODPRO = BKS_CODPRO "
    cQuery += "		AND B3F_CHVORI = BKT.R_E_C_N_O_ "
    cQuery += "		AND BKS.D_E_L_E_T_ = ' '  "
    cQuery += " WHERE B3F_FILIAL = '"+xFilial("B3F")+"' "
    cQuery += " AND B3F_ORICRI = 'BKT' "
    cQuery += " AND B3F.D_E_L_E_T_ = ' '  "

    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()
    /*self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()
    If lFound
		B3F->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf*/

return lFound

Method bscQtdCrit() Class CenDaoCrit

    Local cQuery := ""
    Local nQuantidade := 0

    cQuery += " SELECT COUNT(*) QTD FROM  "+RetSqlName("B3F")+" B3F "
    cQuery += " WHERE 1=1 "
    cQuery += "     AND B3F_FILIAL = '"+xFilial("B3F")+"' "
    cQuery += "     AND B3F_CODOPE = '" + self:getValue("operatorRecord") + "'"
    cQuery += "     AND B3F_CDOBRI = '" + self:getValue("requirementCode") + "'"
    cQuery += "     AND B3F_ANO    = '" + self:getValue("commitReferenceYear") + "'"
    cQuery += "     AND B3F_CDCOMP = '" + self:getValue("commitmentCode") + "'"

    self:setQuery(self:queryBuilder(cQuery))
    lFound := self:executaQuery()
    If lFound
        nQuantidade := (self:getAliasTemp())->QTD
    EndIf

Return nQuantidade

Method ajuCriStatus(cCamposChave) Class CenDaoCrit
    Local cAlias := self:getValue("reviewOrigin")
    Local cQuery := ""
    Local lFound := .F.
    Default cCamposChave := ""

    If !Empty(cCamposChave)

        cQuery += " UPDATE "+RetSqlName(cAlias)+" "
        cQuery += " SET  "+cAlias+"_STATUS = '1' WHERE R_E_C_N_O_ IN ( SELECT "
        cQuery += " "+cAlias+".R_E_C_N_O_ AS RECNO FROM  "+RetSqlName("B3F")+" AS B3F "
        cQuery += " INNER JOIN "+RetSqlName(cAlias)+" AS " +cAlias+ " ON "
        cQuery += " B3F_FILIAL         = "+cAlias+"_FILIAL "
        cQuery += " AND B3F_CODOPE     = "+cAlias+"_CODOPE "
        cQuery += " AND B3F_CDOBRI     = "+cAlias+"_CODOBR "
        cQuery += " AND B3F_ANO        = "+cAlias+"_ANOCMP "
        cQuery += " AND B3F_CDCOMP     = "+cAlias+"_CDCOMP "
        cQuery += " AND B3F_IDEORI     = " +cCamposChave
        cQuery += " AND B2W.D_E_L_E_T_ = ' ' "
        cQuery += " WHERE B3F_ORICRI   = '"+cAlias+"' "
        cQuery += " AND B3F_CODCRI     = '"+self:getValue("reviewCode")+"' ) "
        cQuery += " AND D_E_L_E_T_     = ' ' "

        self:setQuery(self:queryBuilder(cQuery))
        lFound := self:execStatement()

    EndIf

Return lFound