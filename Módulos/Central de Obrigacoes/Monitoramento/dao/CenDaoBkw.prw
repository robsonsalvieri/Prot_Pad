#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class CenDaoBkw from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    Method bscUltLote()
    Method bscLastArq() 
    Method bscGerXTE()

EndClass

Method New(aFields) Class CenDaoBkw
	_Super:New(aFields)
    self:cAlias := "BKW"
    self:cfieldOrder := "BKW_CODOPE,BKW_CODLOT"
Return self

Method buscar() Class CenDaoBkw
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		BKW->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoBkw
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoBkw

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BKW') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	BKW_FILIAL = '" + xFilial("BKW") + "' "

    cQuery += " AND BKW_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BKW_CODLOT = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("batchCode")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method insert() Class CenDaoBkw
    Local lFound := !self:bscChaPrim()
	If lFound
        self:commit(.T.)
    EndIf
Return lFound

Method commit(lInclui) Class CenDaoBkw

    Default lInclui := .F.

	If BKW->(RecLock("BKW",lInclui))
		
        BKW->BKW_FILIAL := xFilial("BKW")
        If lInclui
        
            BKW->BKW_CODOPE := _Super:normalizeType(BKW->BKW_CODOPE,self:getValue("operatorRecord")) /* Column BKW_CODOPE */
            BKW->BKW_CODLOT := _Super:normalizeType(BKW->BKW_CODLOT,self:getValue("batchCode")) /* Column BKW_CODLOT */

        EndIf

        BKW->BKW_CDOBRI := _Super:normalizeType(BKW->BKW_CDOBRI,self:getValue("requirementCode")) /* Column BKW_CDOBRI */
        BKW->BKW_CDCOMP := _Super:normalizeType(BKW->BKW_CDCOMP,self:getValue("commitmentCode")) /* Column BKW_CDCOMP */
        BKW->BKW_ANO    := _Super:normalizeType(BKW->BKW_ANO   ,self:getValue("referenceYear")) /* Column BKW_ANO    */
        BKW->BKW_STATUS := _Super:normalizeType(BKW->BKW_STATUS,self:getValue("status")) /* Column BKW_STATUS */
        BKW->BKW_FORREM := _Super:normalizeType(BKW->BKW_FORREM,self:getValue("remunerationType")) /* Column BKW_FORREM */
        BKW->BKW_ARQUIV := _Super:normalizeType(BKW->BKW_ARQUIV,self:getValue("file")) /* Column BKW_ARQUIV */
        BKW->BKW_DATPRO := _Super:normalizeType(BKW->BKW_DATPRO,self:getValue("processingDate")) /* Column BKW_DATPRO */
        BKW->BKW_HORPRO := _Super:normalizeType(BKW->BKW_HORPRO,self:getValue("processingTime")) /* Column BKW_HORPRO */
        BKW->BKW_VERSAO := _Super:normalizeType(BKW->BKW_VERSAO,self:getValue("version")) /* Column BKW_VERSAO */
        BKW->BKW_ERRXSD := _Super:normalizeType(BKW->BKW_ERRXSD,self:getValue("xsdError")) /* Column BKW_ERRXSD */
        BKW->BKW_REGINC := _Super:normalizeType(BKW->BKW_REGINC,self:getValue("includedRecords")) /* Column BKW_REGINC */
        BKW->BKW_REGALT := _Super:normalizeType(BKW->BKW_REGALT,self:getValue("changedRecords")) /* Column BKW_REGALT */
        BKW->BKW_REGEXC := _Super:normalizeType(BKW->BKW_REGEXC,self:getValue("deletedRecords")) /* Column BKW_REGEXC */
        BKW->BKW_REGERR := _Super:normalizeType(BKW->BKW_REGERR,self:getValue("incorrectRecords")) /* Column BKW_REGERR */

        BKW->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} bscUltLote
    Retorna a quantidade de guias de uma competencia aptas 
    para serem adicionadas em um lote

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method bscUltLote() Class CenDaoBKW

    Local cQuery   := ""
    Local cUltLote := ""
	
    cQuery := " SELECT MAX(BKW_CODLOT) MAX "
    cQuery += " FROM " + RetSqlName('BKW') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	BKW_FILIAL = '" + xFilial("BKW") + "' "
    cQuery += " AND BKW_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BKW_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND BKW_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND BKW_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND BKW_FORREM = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("remunerationType")))
    // Status = 1 -- Arquivo ainda não foi gerado
    cQuery += " AND BKW_STATUS = '1' "
    cQuery += " AND D_E_L_E_T_ = ' ' "

    self:setQuery(self:queryBuilder(cQuery))
	If self:executaQuery()
		cUltLote := (self:getAliasTemp())->MAX
    EndIf
    self:fechaQuery()

return cUltLote


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} bscLastArq
    Retorna a numeracao do ultimo lote gerado para o mes

    @type  Class
    @author renan.almeida
    @since 03/12/2019
/*/
//------------------------------------------------------------------------------------------
Method bscLastArq() Class CenDaoBKW

	Local cQuery  := ""
    Local cArquiv := ""

    cQuery := " SELECT MAX(BKW_ARQUIV) ARQUIV "
    cQuery += " FROM " + RetSqlName('BKW') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	BKW_FILIAL = '" + xFilial("BKW") + "' "
    cQuery += " AND BKW_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BKW_CDOBRI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    cQuery += " AND BKW_ANO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    cQuery += " AND BKW_CDCOMP = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    cQuery += " AND D_E_L_E_T_ = ' ' "
   
    self:setQuery(self:queryBuilder(cQuery))
	If self:executaQuery()
		cArquiv := (self:getAliasTemp())->ARQUIV
    EndIf
    self:fechaQuery()

return Alltrim(cArquiv)


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} bscGerXTE
    Busca os lotes para gerar o arquivo XTE

    @type  Class
    @author renan.almeida
    @since 20200120
/*/
//------------------------------------------------------------------------------------------
Method bscGerXTE() Class CenDaoBKW

    Local lFound := .F.
	Local cQuery := ""
   
    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BKW') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	BKW_FILIAL = '" + xFilial("BKW") + "' "

    cQuery += " AND BKW_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    If !Empty(self:getValue("requirementCode"))
        cQuery += " AND BKW_CDOBRI = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("requirementCode")))
    EndIf
    If !Empty(self:getValue("referenceYear"))
        cQuery += " AND BKW_ANO = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("referenceYear")))
    EndIf
    If !Empty(self:getValue("commitmentCode"))
        cQuery += " AND BKW_CDCOMP = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("commitmentCode")))
    EndIf
    If !Empty(self:getValue("remunerationType"))
        cQuery += " AND BKW_FORREM = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("remunerationType")))
    EndIf
    If !Empty(self:getValue("batchCode"))
        cQuery += " AND BKW_CODLOT = ? "
        aAdd(self:aMapBuilder, self:toString(self:getValue("batchCode")))
    EndIf

    cQuery += " AND ( (BKW_STATUS='1') OR (BKW_STATUS='2') OR (BKW_STATUS='3') ) "
    cQuery += " AND D_E_L_E_T_ = ' ' "

    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()
    If lFound 
		BKW->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
    
return lFound