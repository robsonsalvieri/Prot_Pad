#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class CenDaoBwl from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    Method aglutEvent()
    
EndClass

Method New(aFields) Class CenDaoBwl
	_Super:New(aFields)
    self:cAlias := "BWL"
    self:cfieldOrder := "BWL_CODOPE,BWL_SEQGUI,BWL_SEQITE"
Return self

Method buscar() Class CenDaoBwl
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		BWL->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoBwl
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoBwl

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BWL') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	BWL_FILIAL = '" + xFilial("BWL") + "' "

    cQuery += " AND BWL_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BWL_SEQGUI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("formSequential")))
    cQuery += " AND BWL_SEQITE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("sequence")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method commit(lInclui) Class CenDaoBwl

    Default lInclui := .F.

	If BWL->(RecLock("BWL",lInclui))
		
        BWL->BWL_FILIAL := xFilial("BWL")
        If lInclui
        
            BWL->BWL_CODOPE := _Super:normalizeType(BWL->BWL_CODOPE,self:getValue("operatorRecord")) /* Column BWL_CODOPE */
            BWL->BWL_SEQGUI := _Super:normalizeType(BWL->BWL_SEQGUI,self:getValue("formSequential")) /* Column BWL_SEQGUI */
            BWL->BWL_SEQITE := _Super:normalizeType(BWL->BWL_SEQITE,self:getValue("sequence")) /* Column BWL_SEQITE */

        EndIf

        BWL->BWL_VLPGPR := _Super:normalizeType(BWL->BWL_VLPGPR,self:getValue("procedureValuePaid")) /* Column BWL_VLPGPR */
        BWL->BWL_VLRCOP := _Super:normalizeType(BWL->BWL_VLRCOP,self:getValue("coPaymentValue")) /* Column BWL_VLRCOP */
        BWL->BWL_CODPRO := _Super:normalizeType(BWL->BWL_CODPRO,self:getValue("procedureCode")) /* Column BWL_CODPRO */
        BWL->BWL_CODTAB := _Super:normalizeType(BWL->BWL_CODTAB,self:getValue("tableCode")) /* Column BWL_CODTAB */
        BWL->BWL_QTDINF := _Super:normalizeType(BWL->BWL_QTDINF,self:getValue("enteredQuantity")) /* Column BWL_QTDINF */
        BWL->BWL_CODGRU := _Super:normalizeType(BWL->BWL_CODGRU,self:getValue("procedureGroup")) /* Column BWL_CODGRU */

        BWL->(MsUnlock())
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
Method aglutEvent() Class CenDaoBwl

    Local lFound := .F.
	Local cQuery := ""

    //Algutina com o Group By todas as Querys
    cQuery += " SELECT BWL_CODOPE, ' ' AS BWL_SEQGUI, ' ' AS BWL_SEQITE, BWL_CODTAB, BWL_CODGRU, BWL_CODPRO,  "
    cQuery += "  0 AS RECNO,  "                 
    cQuery += " SUM(BWL_QTDINF) AS BWL_QTDINF, "
	cQuery += " SUM(BWL_VLPGPR) AS BWL_VLPGPR, "
	cQuery += " SUM(BWL_VLRCOP) AS BWL_VLRCOP "
  
    cQuery += " FROM ( "

    //Busca eventos nao consolidados e sem cadastro na B7Z
    cQuery += " SELECT BWL_CODOPE, ' ' AS BWL_SEQGUI, ' ' AS BWL_SEQITE, BWL_CODTAB, BWL_CODGRU, BWL_CODPRO, "
    cQuery += " BWL.R_E_C_N_O_ AS RECNO, BWL_QTDINF, BWL_VLPGPR, BWL_VLRCOP "
    cQuery += " FROM " + RetSqlName('BWL') + " BWL "
    cQuery += " LEFT JOIN " + RetSqlName('B7Z') + " B7Z " 
    cQuery += " ON B7Z_FILIAL = '"+xFilial("B7Z")+"' "
    cQuery += " AND B7Z_CODTAB = BWL_CODTAB "
    cQuery += " AND B7Z_CODPRO = BWL_CODPRO "
    cQuery += " AND B7Z.D_E_L_E_T_ = ' ' "
    cQuery += " WHERE BWL_FILIAL = '"+xFilial("BWL")+"' "
    cQuery += " AND BWL.BWL_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BWL.BWL_SEQGUI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("formSequential")))
    cQuery += " AND (B7Z.B7Z_FORENV = '1' OR B7Z.B7Z_CODPRO IS NULL) "
    cQuery += " AND BWL.D_E_L_E_T_ = ' ' "	

    //Busca eventos consolidados
    cQuery += " UNION "
    cQuery += " SELECT       
    cQuery += " BWL_CODOPE, ' ' AS BWL_SEQGUI, ' ' AS BWL_SEQITE, BWL_CODTAB, B7Z_CODGRU AS BWL_CODGRU, '' AS BWL_CODPRO, "
    cQuery += " BWL.R_E_C_N_O_ AS RECNO,  BWL_QTDINF, BWL_VLPGPR, BWL_VLRCOP "
    cQuery += " FROM " + RetSqlName('BWL') + " BWL "
    cQuery += " LEFT JOIN " + RetSqlName('B7Z') + " B7Z " 
    cQuery += " ON B7Z_FILIAL = '"+xFilial("B7Z")+"' "
    cQuery += " AND B7Z_CODTAB = BWL_CODTAB "
    cQuery += " AND B7Z_CODPRO = BWL_CODPRO "
    cQuery += " AND B7Z.D_E_L_E_T_ = ' ' "
    cQuery += " WHERE BWL_FILIAL = '"+xFilial("BWL")+"' "
    cQuery += " AND BWL.BWL_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BWL.BWL_SEQGUI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("formSequential")))
    cQuery += " AND (B7Z.B7Z_FORENV = '2') "
    cQuery += " AND BWL.D_E_L_E_T_ = ' ' "

    //Group By e Order By Geral                   
    cQuery += " ) GERAL "
    cQuery += " GROUP BY BWL_CODOPE, BWL_CODTAB, BWL_CODPRO, BWL_CODGRU " 
    cQuery += " ORDER BY BWL_CODGRU, BWL_CODTAB, BWL_CODPRO "

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
Method aglutEvent() Class CenDaoBWL

    Local lFound := .F.
	Local cQuery := ""
    
    cQuery += " SELECT * FROM ( "

    cQuery += " SELECT * FROM ( " 

    cQuery += " SELECT BWL_CODOPE, ' ' AS BWL_SEQGUI, MAX(BWL_SEQITE) AS BWL_SEQITE, BWL_CODTAB, B7Z_CODGRU AS BWL_CODGRU, BWL_CODPRO AS BWL_CODPRO, " 
	cQuery += " 0 AS RECNO, "
	cQuery += " SUM(BWL_QTDINF) AS BWL_QTDINF, "
    cQuery += " SUM(BWL_VLPGPR) AS BWL_VLPGPR, "
	cQuery += " SUM(BWL_VLRCOP) AS BWL_VLRCOP  "

    cQuery += " FROM " + RetSqlName('BWL') + " BWL "
    cQuery += " LEFT JOIN " + RetSqlName('B7Z') + " B7Z " 
    cQuery += "    ON B7Z_FILIAL = ' ' "
    cQuery += "    AND B7Z_CODTAB = BWL_CODTAB " 
    cQuery += "    AND B7Z_CODPRO = BWL_CODPRO " 
    cQuery += "    AND B7Z.D_E_L_E_T_ = ' ' "
      
    cQuery += " WHERE BWL_FILIAL = '"+xFilial("BWL")+"' "
    cQuery += " AND BWL.BWL_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BWL.BWL_SEQGUI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("formSequential")))
    cQuery += " AND BWL.D_E_L_E_T_ = ' ' "	

    cQuery += " GROUP BY  "
	cQuery += " BWL_CODOPE, "
	cQuery += " BWL_CODTAB, "
	cQuery += " BWL_CODPRO, "
	cQuery += " B7Z_CODGRU "

    cQuery += " ) AUX WHERE AUX.BWL_CODGRU IS NULL OR AUX.BWL_CODGRU = ' ' "

    //Union com itens consolidados
    cQuery += " UNION " 
  
    cQuery += " SELECT BWL_CODOPE, ' ' AS BWL_SEQGUI, ' ' AS BWL_SEQITE, BWL_CODTAB, B7Z_CODGRU AS BWL_CODGRU, ' ' AS BWL_CODPRO, " 
	cQuery += "	0 AS RECNO, " 
	cQuery += "	SUM(BWL_QTDINF) AS BWL_QTDINF, "
    cQuery += " SUM(BWL_VLPGPR) AS BWL_VLPGPR, "
	cQuery += " SUM(BWL_VLRCOP) AS BWL_VLRCOP  "

    cQuery += " FROM " + RetSqlName('BWL') + " BWL "
	cQuery += " INNER JOIN " + RetSqlName('B7Z') + " B7Z
	cQuery += "    ON B7Z_FILIAL = '"+xFilial("B7Z")+"' "
	cQuery += "    AND B7Z_CODTAB = BWL_CODTAB "
	cQuery += "    AND B7Z_CODPRO = BWL_CODPRO "
	cQuery += "    AND B7Z_CODGRU <> ' ' "
	cQuery += "    AND B7Z.D_E_L_E_T_ = ' ' "  
	cQuery += " WHERE BWL_FILIAL = '"+xFilial("BWL")+"' "
    cQuery += " AND BWL.BWL_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))
    cQuery += " AND BWL.BWL_SEQGUI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("formSequential")))
    cQuery += " AND BWL.D_E_L_E_T_ = ' ' "	
       
    cQuery += " GROUP BY  "
    cQuery += " BWL_CODOPE, "
    cQuery += " BWL_CODTAB, "
    cQuery += " B7Z_CODGRU "
  
    cQuery += " ) GERAL ORDER BY BWL_CODGRU, BWL_CODTAB, BWL_CODPRO "

    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound
*/
