#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class PLSDaoBt5 from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    
EndClass

Method New(aFields) Class PLSDaoBt5
	_Super:New(aFields)
    self:cAlias := "BT5"
    self:cfieldOrder := "BT5_CODINT,BT5_CODIGO,BT5_NUMCON,BT5_VERSAO"
Return self

Method buscar() Class PLSDaoBt5
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		BT5->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class PLSDaoBt5
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class PLSDaoBt5

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BT5') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	BT5_FILIAL = '" + xFilial("BT5") + "' "

    cQuery += " AND BT5_CODINT = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BT5_CODINT")))
    cQuery += " AND BT5_CODIGO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BT5_CODIGO")))
    cQuery += " AND BT5_NUMCON = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BT5_NUMCON")))
    cQuery += " AND BT5_VERSAO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("BT5_VERSAO")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method insert() Class PLSDaoBt5
    Local lFound := !self:bscChaPrim()
	If lFound
        self:commit(.T.)
    EndIf
Return lFound

Method commit(lInclui) Class PLSDaoBt5

    Default lInclui := .F.

	If BT5->(RecLock("BT5",lInclui))
		
        BT5->BT5_FILIAL := xFilial("BT5")
        If lInclui
        
            BT5->BT5_CODINT := _Super:normalizeType(BT5->BT5_CODINT,self:getValue("BT5_CODINT")) 
            BT5->BT5_CODIGO := _Super:normalizeType(BT5->BT5_CODIGO,self:getValue("BT5_CODIGO")) 
            BT5->BT5_NUMCON := _Super:normalizeType(BT5->BT5_NUMCON,self:getValue("BT5_NUMCON")) 
            BT5->BT5_VERSAO := _Super:normalizeType(BT5->BT5_VERSAO,self:getValue("BT5_VERSAO")) 

        EndIf

        BT5->BT5_DATCON := _Super:normalizeType(BT5->BT5_DATCON,self:getValue("BT5_DATCON")) 
        BT5->BT5_TIPCON := _Super:normalizeType(BT5->BT5_TIPCON,self:getValue("BT5_TIPCON")) 
        BT5->BT5_ANTCON := _Super:normalizeType(BT5->BT5_ANTCON,self:getValue("BT5_ANTCON")) 
        BT5->BT5_COBNIV := _Super:normalizeType(BT5->BT5_COBNIV,self:getValue("BT5_COBNIV")) 
        BT5->BT5_CODCLI := _Super:normalizeType(BT5->BT5_CODCLI,self:getValue("BT5_CODCLI")) 
        BT5->BT5_LOJA := _Super:normalizeType(BT5->BT5_LOJA,self:getValue("BT5_LOJA")) 
        BT5->BT5_NOME := _Super:normalizeType(BT5->BT5_NOME,self:getValue("BT5_NOME")) 
        BT5->BT5_NATURE := _Super:normalizeType(BT5->BT5_NATURE,self:getValue("BT5_NATURE")) 
        BT5->BT5_CODFOR := _Super:normalizeType(BT5->BT5_CODFOR,self:getValue("BT5_CODFOR")) 
        BT5->BT5_LOJFOR := _Super:normalizeType(BT5->BT5_LOJFOR,self:getValue("BT5_LOJFOR")) 
        BT5->BT5_VENCTO := _Super:normalizeType(BT5->BT5_VENCTO,self:getValue("BT5_VENCTO")) 
        BT5->BT5_INTERC := _Super:normalizeType(BT5->BT5_INTERC,self:getValue("BT5_INTERC")) 
        BT5->BT5_MODPAG := _Super:normalizeType(BT5->BT5_MODPAG,self:getValue("BT5_MODPAG")) 
        BT5->BT5_TIPOIN := _Super:normalizeType(BT5->BT5_TIPOIN,self:getValue("BT5_TIPOIN")) 
        BT5->BT5_ALLOPE := _Super:normalizeType(BT5->BT5_ALLOPE,self:getValue("BT5_ALLOPE")) 
        BT5->BT5_OPEINT := _Super:normalizeType(BT5->BT5_OPEINT,self:getValue("BT5_OPEINT")) 
        BT5->BT5_IMPORT := _Super:normalizeType(BT5->BT5_IMPORT,self:getValue("BT5_IMPORT")) 
        BT5->BT5_INFANS := _Super:normalizeType(BT5->BT5_INFANS,self:getValue("BT5_INFANS")) 
        BT5->BT5_TIPPAG := _Super:normalizeType(BT5->BT5_TIPPAG,self:getValue("BT5_TIPPAG")) 
        BT5->BT5_BCOCLI := _Super:normalizeType(BT5->BT5_BCOCLI,self:getValue("BT5_BCOCLI")) 
        BT5->BT5_AGECLI := _Super:normalizeType(BT5->BT5_AGECLI,self:getValue("BT5_AGECLI")) 
        BT5->BT5_CTACLI := _Super:normalizeType(BT5->BT5_CTACLI,self:getValue("BT5_CTACLI")) 
        BT5->BT5_PORTAD := _Super:normalizeType(BT5->BT5_PORTAD,self:getValue("BT5_PORTAD")) 
        BT5->BT5_AGEDEP := _Super:normalizeType(BT5->BT5_AGEDEP,self:getValue("BT5_AGEDEP")) 
        BT5->BT5_CTACOR := _Super:normalizeType(BT5->BT5_CTACOR,self:getValue("BT5_CTACOR")) 
        BT5->BT5_COBJUR := _Super:normalizeType(BT5->BT5_COBJUR,self:getValue("BT5_COBJUR")) 
        BT5->BT5_TAXDIA := _Super:normalizeType(BT5->BT5_TAXDIA,self:getValue("BT5_TAXDIA")) 
        BT5->BT5_JURDIA := _Super:normalizeType(BT5->BT5_JURDIA,self:getValue("BT5_JURDIA")) 
        BT5->BT5_MAIORI := _Super:normalizeType(BT5->BT5_MAIORI,self:getValue("BT5_MAIORI")) 
        BT5->BT5_PODREM := _Super:normalizeType(BT5->BT5_PODREM,self:getValue("BT5_PODREM")) 
        BT5->BT5_DIASIN := _Super:normalizeType(BT5->BT5_DIASIN,self:getValue("BT5_DIASIN")) 
        BT5->BT5_CODTES := _Super:normalizeType(BT5->BT5_CODTES,self:getValue("BT5_CODTES")) 
        BT5->BT5_CODSB1 := _Super:normalizeType(BT5->BT5_CODSB1,self:getValue("BT5_CODSB1")) 
        BT5->BT5_CODANS := _Super:normalizeType(BT5->BT5_CODANS,self:getValue("BT5_CODANS")) 
        BT5->BT5_CODOPE := _Super:normalizeType(BT5->BT5_CODOPE,self:getValue("BT5_CODOPE")) 
        BT5->BT5_COMAUT := _Super:normalizeType(BT5->BT5_COMAUT,self:getValue("BT5_COMAUT")) 
        BT5->BT5_AGR309 := _Super:normalizeType(BT5->BT5_AGR309,self:getValue("BT5_AGR309")) 

        BT5->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound
