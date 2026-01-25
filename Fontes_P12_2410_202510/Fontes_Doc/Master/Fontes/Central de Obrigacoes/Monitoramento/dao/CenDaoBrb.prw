#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class CenDaoBrb from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    Method aglutEvent()
    
EndClass

Method New(aFields) Class CenDaoBrb
	_Super:New(aFields)
    self:cAlias := "BRB"
    self:cfieldOrder := "BRB_CODOPE,BRB_SEQGUI,BRB_SEQITE"
Return self

Method buscar() Class CenDaoBrb
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		BRB->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoBrb
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoBrb

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BRB') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	BRB_FILIAL = '" + xFilial("BRB") + "' "

    cQuery += " AND BRB_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BRB_SEQGUI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("formSequential")))
    cQuery += " AND BRB_SEQITE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("sequence")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method commit(lInclui) Class CenDaoBrb

    Default lInclui := .F.

	If BRB->(RecLock("BRB",lInclui))
		
        BRB->BRB_FILIAL := xFilial("BRB")
        If lInclui
        
            BRB->BRB_CODOPE := _Super:normalizeType(BRB->BRB_CODOPE,self:getValue("operatorRecord")) /* Column BRB_CODOPE */
            BRB->BRB_SEQGUI := _Super:normalizeType(BRB->BRB_SEQGUI,self:getValue("formSequential")) /* Column BRB_SEQGUI */
            BRB->BRB_SEQITE := _Super:normalizeType(BRB->BRB_SEQITE,self:getValue("sequence")) /* Column BRB_SEQITE */

        EndIf

        BRB->BRB_VLPGPR := _Super:normalizeType(BRB->BRB_VLPGPR,self:getValue("procedureValuePaid")) /* Column BRB_VLPGPR */
        BRB->BRB_VLRCOP := _Super:normalizeType(BRB->BRB_VLRCOP,self:getValue("coPaymentValue")) /* Column BRB_VLRCOP */
        BRB->BRB_VLRGLO := _Super:normalizeType(BRB->BRB_VLRGLO,self:getValue("disallVl")) /* Column BRB_VLRGLO */
        BRB->BRB_VLRINF := _Super:normalizeType(BRB->BRB_VLRINF,self:getValue("valueEntered")) /* Column BRB_VLRINF */
        BRB->BRB_VLRPGF := _Super:normalizeType(BRB->BRB_VLRPGF,self:getValue("valuePaidSupplier")) /* Column BRB_VLRPGF */
        BRB->BRB_CODPRO := _Super:normalizeType(BRB->BRB_CODPRO,self:getValue("procedureCode")) /* Column BRB_CODPRO */
        BRB->BRB_CODTAB := _Super:normalizeType(BRB->BRB_CODTAB,self:getValue("tableCode")) /* Column BRB_CODTAB */
        BRB->BRB_PACOTE := _Super:normalizeType(BRB->BRB_PACOTE,self:getValue("package")) /* Column BRB_PACOTE */
        BRB->BRB_QTDINF := _Super:normalizeType(BRB->BRB_QTDINF,self:getValue("enteredQuantity")) /* Column BRB_QTDINF */
        BRB->BRB_QTDPAG := _Super:normalizeType(BRB->BRB_QTDPAG,self:getValue("quantityPaid")) /* Column BRB_QTDPAG */
        BRB->BRB_CDDENT := _Super:normalizeType(BRB->BRB_CDDENT,self:getValue("toothCode")) /* Column BRB_CDDENT */
        BRB->BRB_CDFACE := _Super:normalizeType(BRB->BRB_CDFACE,self:getValue("toothFaceCode")) /* Column BRB_CDFACE */
        BRB->BRB_CDREGI := _Super:normalizeType(BRB->BRB_CDREGI,self:getValue("regionCode")) /* Column BRB_CDREGI */
        BRB->BRB_CNPJFR := _Super:normalizeType(BRB->BRB_CNPJFR,self:getValue("supplierCnpj")) /* Column BRB_CNPJFR */
        BRB->BRB_CODGRU := _Super:normalizeType(BRB->BRB_CODGRU,self:getValue("procedureGroup")) /* Column BRB_CODGRU */

        BRB->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} aglutEvent
    Aglutina eventos enviados para a API

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method aglutEvent() Class CenDaoBrb

    Local lFound := .F.
	Local cQuery := ""

    //Algutina com o Group By todas as Querys
    cQuery += " SELECT BRB_CODOPE, ' ' AS BRB_SEQGUI, MIN(BRB_SEQITE) AS BRB_SEQITE, BRB_CODTAB, BRB_CODGRU, BRB_CODPRO, BRB_CDDENT, "
    cQuery += " BRB_CDREGI, BRB_CDFACE, BRB_CNPJFR, 0 AS RECNO, BRB_PACOTE, "                 
    cQuery += " SUM(BRB_QTDINF) AS BRB_QTDINF, "
    cQuery += " SUM(BRB_VLRINF) AS BRB_VLRINF, "
    cQuery += " SUM(BRB_QTDPAG) AS BRB_QTDPAG, "
    cQuery += " SUM(BRB_VLPGPR) AS BRB_VLPGPR, "
    cQuery += " SUM(BRB_VLRPGF) AS BRB_VLRPGF, "
    cQuery += " SUM(BRB_VLRCOP) AS BRB_VLRCOP, "
    cQuery += " SUM(BRB_VLRGLO) AS BRB_VLRGLO  "
    cQuery += " FROM ( "

    //Busca eventos nao consolidados e sem cadastro na B7Z
    cQuery += " SELECT BRB_CODOPE, ' ' AS BRB_SEQGUI, BRB_SEQITE, BRB_CODTAB, BRB_CODGRU, BRB_CODPRO, "
    cQuery += " BRB_CDDENT, BRB_CDREGI, BRB_CDFACE, BRB_CNPJFR, BRB.R_E_C_N_O_ AS RECNO, BRB_PACOTE, BRB_QTDINF, BRB_VLRINF, BRB_QTDPAG, "
    cQuery += " BRB_VLPGPR, BRB_VLRPGF, BRB_VLRCOP, BRB_VLRGLO "
    cQuery += " FROM " + RetSqlName('BRB') + " BRB "
    cQuery += " LEFT JOIN " + RetSqlName('B7Z') + " B7Z " 
    cQuery += " ON B7Z_FILIAL = '"+xFilial("B7Z")+"' "
    cQuery += " AND B7Z_CODTAB = BRB_CODTAB "
    cQuery += " AND B7Z_CODPRO = BRB_CODPRO "
    cQuery += " AND B7Z.D_E_L_E_T_ = ' ' "
    cQuery += " WHERE BRB_FILIAL = '"+xFilial("BRB")+"' "
    cQuery += " AND BRB.BRB_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BRB.BRB_SEQGUI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("formSequential")))
    cQuery += " AND (B7Z.B7Z_FORENV = '1' OR B7Z.B7Z_CODPRO IS NULL) "
    cQuery += " AND BRB.D_E_L_E_T_ = ' ' "	

    //Busca eventos consolidados
    cQuery += " UNION "
    cQuery += " SELECT       
    cQuery += " BRB_CODOPE, ' ' AS BRB_SEQGUI, BRB_SEQITE, BRB_CODTAB, B7Z_CODGRU AS BRB_CODGRU, '' AS BRB_CODPRO, " //' ' AS BRB_CODPRO
    cQuery += " BRB_CDDENT, BRB_CDREGI, BRB_CDFACE, BRB_CNPJFR, BRB.R_E_C_N_O_ AS RECNO, BRB_PACOTE, BRB_QTDINF, BRB_VLRINF, BRB_QTDPAG, "
    cQuery += " BRB_VLPGPR, BRB_VLRPGF, BRB_VLRCOP, BRB_VLRGLO "
    cQuery += " FROM " + RetSqlName('BRB') + " BRB "
    cQuery += " LEFT JOIN " + RetSqlName('B7Z') + " B7Z " 
    cQuery += " ON B7Z_FILIAL = '"+xFilial("B7Z")+"' "
    cQuery += " AND B7Z_CODTAB = BRB_CODTAB "
    cQuery += " AND B7Z_CODPRO = BRB_CODPRO "
    cQuery += " AND B7Z.D_E_L_E_T_ = ' ' "
    cQuery += " WHERE BRB_FILIAL = '"+xFilial("BRB")+"' "
    cQuery += " AND BRB.BRB_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BRB.BRB_SEQGUI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("formSequential")))
    cQuery += " AND (B7Z.B7Z_FORENV = '2') "
    cQuery += " AND BRB.D_E_L_E_T_ = ' ' "

    //Group By e Order By Geral                   
    cQuery += " ) GERAL "
    cQuery += " GROUP BY BRB_CODOPE, BRB_CODTAB, BRB_CODPRO, BRB_CODGRU, BRB_CDDENT, BRB_CDREGI, BRB_CDFACE, BRB_CNPJFR, BRB_PACOTE" 
    cQuery += " ORDER BY BRB_CODGRU, BRB_CODTAB, BRB_CODPRO, BRB_CDDENT, BRB_CDREGI, BRB_CDFACE "

    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} aglutEvent
    Aglutina eventos enviados para a API

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
/*
Method aglutEvent() Class CenDaoBrb

    Local lFound := .F.
	Local cQuery := ""
    
    cQuery += " SELECT * FROM ( "

    cQuery += " SELECT * FROM ( " 

    cQuery += " SELECT BRB_CODOPE, ' ' AS BRB_SEQGUI, MAX(BRB_SEQITE) AS BRB_SEQITE, BRB_CODTAB, B7Z_CODGRU AS BRB_CODGRU, BRB_CODPRO AS BRB_CODPRO, BRB_CDDENT, " 
	cQuery += " BRB_CDREGI, BRB_CDFACE, BRB_CNPJFR, 0 AS RECNO, BRB_PACOTE, "
	cQuery += " SUM(BRB_QTDINF) AS BRB_QTDINF, SUM(BRB_VLRINF) AS BRB_VLRINF, "
    cQuery += " SUM(BRB_QTDPAG) AS BRB_QTDPAG, SUM(BRB_VLPGPR) AS BRB_VLPGPR, SUM(BRB_VLRPGF) AS BRB_VLRPGF, "
	cQuery += " SUM(BRB_VLRCOP) AS BRB_VLRCOP, SUM(BRB_VLRGLO) AS BRB_VLRGLO "

    cQuery += " FROM " + RetSqlName('BRB') + " BRB "
    cQuery += " LEFT JOIN " + RetSqlName('B7Z') + " B7Z " 
    cQuery += "    ON B7Z_FILIAL = ' ' "
    cQuery += "    AND B7Z_CODTAB = BRB_CODTAB " 
    cQuery += "    AND B7Z_CODPRO = BRB_CODPRO " 
    cQuery += "    AND B7Z.D_E_L_E_T_ = ' ' "
      
    cQuery += " WHERE BRB_FILIAL = '"+xFilial("BRB")+"' "
    cQuery += " AND BRB.BRB_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BRB.BRB_SEQGUI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("formSequential")))
    cQuery += " AND BRB.D_E_L_E_T_ = ' ' "	

    cQuery += " GROUP BY  "
	cQuery += " BRB_CODOPE, "
	cQuery += " BRB_CODTAB, "
	cQuery += " BRB_CODPRO, "
	cQuery += " B7Z_CODGRU, "
	cQuery += " BRB_CDDENT, "
	cQuery += " BRB_CDREGI, "
	cQuery += " BRB_CDFACE, "
	cQuery += " BRB_CNPJFR, "
    cQuery += " BRB_PACOTE "

    cQuery += " ) AUX WHERE AUX.BRB_CODGRU IS NULL OR AUX.BRB_CODGRU = ' ' "

    //Union com itens consolidados
    cQuery += " UNION " 
  
    cQuery += " SELECT BRB_CODOPE, ' ' AS BRB_SEQGUI, BRB_SEQITE, BRB_CODTAB, B7Z_CODGRU AS BRB_CODGRU, ' ' AS BRB_CODPRO, BRB_CDDENT, " 
	cQuery += "	BRB_CDREGI, BRB_CDFACE, BRB_CNPJFR, 0 AS RECNO,  BRB_PACOTE, " 
	cQuery += "	SUM(BRB_QTDINF) AS BRB_QTDINF, SUM(BRB_VLRINF) AS BRB_VLRINF, "
    cQuery += " SUM(BRB_QTDPAG) AS BRB_QTDPAG, SUM(BRB_VLPGPR) AS BRB_VLPGPR, SUM(BRB_VLRPGF) AS BRB_VLRPGF, "
	cQuery += " SUM(BRB_VLRCOP) AS BRB_VLRCOP, SUM(BRB_VLRGLO) AS BRB_VLRGLO  "

    cQuery += " FROM " + RetSqlName('BRB') + " BRB "
	cQuery += " INNER JOIN " + RetSqlName('B7Z') + " B7Z
	cQuery += "    ON B7Z_FILIAL = '"+xFilial("B7Z")+"' "
	cQuery += "    AND B7Z_CODTAB = BRB_CODTAB "
	cQuery += "    AND B7Z_CODPRO = BRB_CODPRO "
	cQuery += "    AND B7Z_CODGRU <> ' ' "
	cQuery += "    AND B7Z.D_E_L_E_T_ = ' ' "  
	cQuery += " WHERE BRB_FILIAL = '"+xFilial("BRB")+"' "
    cQuery += " AND BRB.BRB_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BRB.BRB_SEQGUI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("formSequential")))
    cQuery += " AND BRB.D_E_L_E_T_ = ' ' "	
       
    cQuery += " GROUP BY  "
    cQuery += " BRB_CODOPE, "
    cQuery += " BRB_CODTAB, "
    cQuery += " BRB_CDDENT, "
    cQuery += " BRB_CDREGI, "
    cQuery += " BRB_CDFACE, "
    cQuery += " B7Z_CODGRU, "
    cQuery += " BRB_CNPJFR,  "
    cQuery += " BRB_PACOTE  "

    cQuery += " ) GERAL ORDER BY BRB_CODGRU, BRB_CODTAB, BRB_CODPRO, BRB_CDDENT, BRB_CDREGI, BRB_CDFACE "

    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound
*/
