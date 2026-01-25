#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class PLSDaoBg9 from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    
EndClass

Method New(aFields) Class PLSDaoBg9
	_Super:New(aFields)
    self:cAlias := "BG9"
    self:cfieldOrder := "BG9_CODINT,BG9_CODIGO"
Return self

Method buscar() Class PLSDaoBg9
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		BG9->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class PLSDaoBg9
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class PLSDaoBg9

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BG9') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	BG9_FILIAL = '" + xFilial("BG9") + "' "

    cQuery += " AND BG9_CODINT = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BG9_CODINT")))
    cQuery += " AND BG9_CODIGO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BG9_CODIGO")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method insert() Class PLSDaoBg9
    Local lFound := !self:bscChaPrim()
	If lFound
        self:commit(.T.)
    EndIf
Return lFound

Method commit(lInclui) Class PLSDaoBg9

    Default lInclui := .F.

	If BG9->(RecLock("BG9",lInclui))
		
        BG9->BG9_FILIAL := xFilial("BG9")
        If lInclui
        
            BG9->BG9_CODINT := _Super:normalizeType(BG9->BG9_CODINT,self:getValue("BG9_CODINT")) 
            BG9->BG9_CODIGO := _Super:normalizeType(BG9->BG9_CODIGO,self:getValue("BG9_CODIGO")) 

        EndIf

        BG9->BG9_DESCRI := _Super:normalizeType(BG9->BG9_DESCRI,self:getValue("BG9_DESCRI")) 
        BG9->BG9_NREDUZ := _Super:normalizeType(BG9->BG9_NREDUZ,self:getValue("BG9_NREDUZ")) 
        BG9->BG9_PODREM := _Super:normalizeType(BG9->BG9_PODREM,self:getValue("BG9_PODREM")) 
        BG9->BG9_TIPO := _Super:normalizeType(BG9->BG9_TIPO,self:getValue("BG9_TIPO")) 
        BG9->BG9_EMPANT := _Super:normalizeType(BG9->BG9_EMPANT,self:getValue("BG9_EMPANT")) 
        BG9->BG9_CODCLI := _Super:normalizeType(BG9->BG9_CODCLI,self:getValue("BG9_CODCLI")) 
        BG9->BG9_LOJA := _Super:normalizeType(BG9->BG9_LOJA,self:getValue("BG9_LOJA")) 
        BG9->BG9_NATURE := _Super:normalizeType(BG9->BG9_NATURE,self:getValue("BG9_NATURE")) 
        BG9->BG9_CODFOR := _Super:normalizeType(BG9->BG9_CODFOR,self:getValue("BG9_CODFOR")) 
        BG9->BG9_LOJFOR := _Super:normalizeType(BG9->BG9_LOJFOR,self:getValue("BG9_LOJFOR")) 
        BG9->BG9_VENCTO := _Super:normalizeType(BG9->BG9_VENCTO,self:getValue("BG9_VENCTO")) 
        BG9->BG9_USO := _Super:normalizeType(BG9->BG9_USO,self:getValue("BG9_USO")) 
        BG9->BG9_MESREA := _Super:normalizeType(BG9->BG9_MESREA,self:getValue("BG9_MESREA")) 
        BG9->BG9_INDREA := _Super:normalizeType(BG9->BG9_INDREA,self:getValue("BG9_INDREA")) 
        BG9->BG9_VALFAI := _Super:normalizeType(BG9->BG9_VALFAI,self:getValue("BG9_VALFAI")) 
        BG9->BG9_TIPPAG := _Super:normalizeType(BG9->BG9_TIPPAG,self:getValue("BG9_TIPPAG")) 
        BG9->BG9_BCOCLI := _Super:normalizeType(BG9->BG9_BCOCLI,self:getValue("BG9_BCOCLI")) 
        BG9->BG9_AGECLI := _Super:normalizeType(BG9->BG9_AGECLI,self:getValue("BG9_AGECLI")) 
        BG9->BG9_CTACLI := _Super:normalizeType(BG9->BG9_CTACLI,self:getValue("BG9_CTACLI")) 
        BG9->BG9_PORTAD := _Super:normalizeType(BG9->BG9_PORTAD,self:getValue("BG9_PORTAD")) 
        BG9->BG9_AGEDEP := _Super:normalizeType(BG9->BG9_AGEDEP,self:getValue("BG9_AGEDEP")) 
        BG9->BG9_CTACOR := _Super:normalizeType(BG9->BG9_CTACOR,self:getValue("BG9_CTACOR")) 
        BG9->BG9_COBJUR := _Super:normalizeType(BG9->BG9_COBJUR,self:getValue("BG9_COBJUR")) 
        BG9->BG9_FILESP := _Super:normalizeType(BG9->BG9_FILESP,self:getValue("BG9_FILESP")) 
        BG9->BG9_TAXDIA := _Super:normalizeType(BG9->BG9_TAXDIA,self:getValue("BG9_TAXDIA")) 
        BG9->BG9_JURDIA := _Super:normalizeType(BG9->BG9_JURDIA,self:getValue("BG9_JURDIA")) 
        BG9->BG9_MAIORI := _Super:normalizeType(BG9->BG9_MAIORI,self:getValue("BG9_MAIORI")) 
        BG9->BG9_CODREG := _Super:normalizeType(BG9->BG9_CODREG,self:getValue("BG9_CODREG")) 
        BG9->BG9_DESREG := _Super:normalizeType(BG9->BG9_DESREG,self:getValue("BG9_DESREG")) 
        BG9->BG9_EMPFAT := _Super:normalizeType(BG9->BG9_EMPFAT,self:getValue("BG9_EMPFAT")) 
        BG9->BG9_FILFAT := _Super:normalizeType(BG9->BG9_FILFAT,self:getValue("BG9_FILFAT")) 
        BG9->BG9_DESEMP := _Super:normalizeType(BG9->BG9_DESEMP,self:getValue("BG9_DESEMP")) 
        BG9->BG9_HSPEMP := _Super:normalizeType(BG9->BG9_HSPEMP,self:getValue("BG9_HSPEMP")) 
        BG9->BG9_DIASIN := _Super:normalizeType(BG9->BG9_DIASIN,self:getValue("BG9_DIASIN")) 
        BG9->BG9_REPASS := _Super:normalizeType(BG9->BG9_REPASS,self:getValue("BG9_REPASS")) 
        BG9->BG9_CODSB1 := _Super:normalizeType(BG9->BG9_CODSB1,self:getValue("BG9_CODSB1")) 
        BG9->BG9_CODTES := _Super:normalizeType(BG9->BG9_CODTES,self:getValue("BG9_CODTES")) 
        BG9->BG9_COMAUT := _Super:normalizeType(BG9->BG9_COMAUT,self:getValue("BG9_COMAUT")) 

        BG9->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound
