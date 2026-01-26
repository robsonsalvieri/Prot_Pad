#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2
#Define HAT_PENDENTE_ENVIO '0'
#Define PROCESSING '0'
#Define PROCESSED '1'

#DEFINE MSSQL     "MSSQL"
#DEFINE POSTGRES  "POSTGRES"
#DEFINE ORACLE    "ORACLE"


Class PlsDaoBNV from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method delete()
    Method bscChaPrim()
    Method commit(lInclui)
    Method setProcessing()
    Method getMessage()
    Method setEndProc(nRecno)
    Method setExpired()
    Method GetProcess(cIdProc)
    
EndClass

Method New(aFields) Class PlsDaoBNV
	_Super:New(aFields)
    self:cAlias := "BNV"
    self:cfieldOrder := "BNV_CODIGO"
Return self

Method buscar() Class PlsDaoBNV
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		BNV->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class PlsDaoBNV
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class PlsDaoBNV

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BNV') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	BNV_FILIAL = '" + xFilial("BNV") + "' "

    cQuery += " AND BNV_CODOPE = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("operatorRecord")))

    cQuery += " AND BNV_CODIGO = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("code")))
 
    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()
    If lFound 
		BNV->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

return lFound

Method commit(lInclui) Class PlsDaoBNV

    Default lInclui := .F.

	If BNV->(RecLock("BNV",lInclui))
		
        BNV->BNV_FILIAL := xFilial("BNV")
        If lInclui        
            BNV->BNV_CODIGO := _Super:normalizeType(BNV->BNV_CODIGO,self:getValue("code"))
        EndIf

        BNV->BNV_CODTRA := _Super:normalizeType(BNV->BNV_CODTRA,self:getValue("transactionCode"))
        BNV->BNV_CHAVE  := _Super:normalizeType(BNV->BNV_CHAVE ,self:getValue("key"))
        BNV->BNV_STATUS := _Super:normalizeType(BNV->BNV_STATUS,self:getValue("status"))
        BNV->BNV_ALIAS  := _Super:normalizeType(BNV->BNV_ALIAS ,self:getValue("alias"))
        BNV->BNV_CAMPOS := _Super:normalizeType(BNV->BNV_CAMPOS,self:getValue("fields"))
        BNV->BNV_DATCRI := _Super:normalizeType(BNV->BNV_DATCRI,self:getValue("creationDate"))
        BNV->BNV_HORCRI := _Super:normalizeType(BNV->BNV_HORCRI,self:getValue("creationTime"))
        BNV->BNV_PEDSUB := _Super:normalizeType(BNV->BNV_PEDSUB,self:getValue("substOrder"))
        //BNV->BNV_JSON   := _Super:normalizeType(BNV->BNV_JSON  ,self:getValue("json"))
        BNV->BNV_TOKEN  := _Super:normalizeType(BNV->BNV_TOKEN ,self:getValue("token"))
        BNV->BNV_IDINT  := _Super:normalizeType(BNV->BNV_IDINT ,self:getValue("integrationID"))
        BNV->BNV_CODOPE := _Super:normalizeType(BNV->BNV_CODOPE,self:getValue("operatorRecord"))
        BNV->BNV_ROBOID := _Super:normalizeType(BNV->BNV_ROBOID,self:getValue("roboId"))
        BNV->BNV_QTDTRY := _Super:normalizeType(BNV->BNV_QTDTRY,self:getValue("numberAttempts"))
        BNV->(MsUnlock())
        lFound := .T.
    EndIf

Return lFound

Method setProcessing() Class PlsDaoBNV

    Local cCodOpe := self:toString(self:getValue("operatorRecord"))
    Local cQuery := ""
    Local lFound := .F.

    If self:cDB <> POSTGRES

        cQuery := iif(self:cDB $ MSSQL," UPDATE TOP(1) "," UPDATE ")
        cQuery += " " + RetSqlName('BNV') + " "
        cQuery += " SET "
        cQuery += " BNV_PROCES = '" + PROCESSING + "' "
        cQuery += " , BNV_ROBOID ='"+self:toString(self:getValue("processId"))+"' "
        cQuery += " , BNV_ROBOHR = '" + DToS(Date()) + " " + Time() + "' "
        cQuery += " WHERE 1=1 "
        cQuery += " AND BNV_FILIAL = '" + xFilial( 'BNV' ) + "' "
        if !Empty(cCodOpe)
            cQuery += " AND BNV_CODOPE = '"+cCodOpe+"' "
        endIf
        cQuery += " AND BNV_STATUS = '" + HAT_PENDENTE_ENVIO + "' "
        cQuery += " AND BNV_PROCES <> '" + PROCESSED + "' "
        cQuery += " AND BNV_ROBOID = ' ' "

        If (self:cDB $ "ORACLE")
            cQuery += "	AND ROWNUM = 1 "
        EndIf
        cQuery += " AND D_E_L_E_T_ = ' ' "
    Else
        cQuery := " UPDATE " + RetSqlName('BNV') + " SET "
        cQuery += " BNV_PROCES = '" + PROCESSING + "' "
        cQuery += " , BNV_ROBOID ='"+self:toString(self:getValue("processId"))+"' "
        cQuery += " , BNV_ROBOHR = '" + DToS(Date()) + " " + Time() + "' "
        cQuery += " WHERE R_E_C_N_O_ = (SELECT R_E_C_N_O_ FROM  " + RetSqlName('BNV') + " WHERE  "
        cQuery += " BNV_FILIAL = '" + xFilial( 'BNV' ) + "' "
        if !Empty(cCodOpe)
            cQuery += " AND BNV_CODOPE = '"+cCodOpe+"' "
        endIf
        cQuery += " AND BNV_STATUS = '" + HAT_PENDENTE_ENVIO + "' "
        cQuery += " AND BNV_PROCES <> '" + PROCESSED + "' "
        cQuery += " AND BNV_ROBOID = ' ' "
        cQuery += " AND D_E_L_E_T_ = ' ' "
        cQuery += "	LIMIT 1 )"

    EndIf

    self:setQuery(cQuery)
    lFound := self:execStatement()

Return lFound

Method getMessage() Class PlsDaoBNV
    
    Local cCodOpe := self:toString(self:getValue("operatorRecord"))
    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BNV') + " "
	cQuery += " WHERE 1=1 "
    cQuery += " AND	BNV_FILIAL = '" + xFilial("BNV") + "' "
    if !Empty(cCodOpe)
        cQuery += " AND BNV_CODOPE = '"+cCodOpe+"' "
    endIf
    cQuery += " AND BNV_PROCES = '" + PROCESSING + "' "
    cQuery += " AND BNV_ROBOID ='"+self:toString(self:getValue("processId"))+"' "
	
    self:setQuery(cQuery)
	lFound := self:executaQuery()
    If lFound
		BNV->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

return lFound

Method setEndProc(nRecno) Class PlsDaoBNV

    Local cQuery := ""
    Local lFound := .F.

    Default nRecno := 0

    If self:cDB <> POSTGRES

        cQuery := iif(self:cDB $ MSSQL," UPDATE TOP(1) "," UPDATE ")
        cQuery += " " + RetSqlName('BNV') + " "
        cQuery += " SET "
        cQuery += " BNV_PROCES = '" + PROCESSED + "' "
        cQuery += " WHERE 1=1 "
        cQuery += " AND R_E_C_N_O_ = '" + AllTrim(Str(nRecno)) + "' "

        If (self:cDB $ "ORACLE")
            cQuery += "	AND ROWNUM = 1 "
        EndIf

    Else
        cQuery := " UPDATE " + RetSqlName('BNV') + " SET "
        cQuery += " BNV_PROCES = '" + PROCESSED + "' "
        cQuery += " WHERE R_E_C_N_O_ = (SELECT R_E_C_N_O_ FROM  " + RetSqlName('BNV') + " "
        cQuery += " WHERE 1=1 "
        cQuery += " AND R_E_C_N_O_ = '" + AllTrim(Str(nRecno)) + "' "
        cQuery += "	LIMIT 1 )"

    EndIf

    self:setQuery(cQuery)
    lFound := self:execStatement()
 
Return lFound

Method setExpired() Class PlsDaoBNV

    Local cCodOpe   := self:toString(self:getValue("operatorRecord"))
    Local nTimePost := 0
    Local nTimeGet  := 0
    Local cTimePost := ""
    Local cTimeGet  := ""
    Local cQtdTry   := ""
    Local cQuery    := ""
    Local lFound    := .F.

    BA0->(DbSetOrder(1)) 
    if !Empty(cCodOpe) .And. BA0->(DbSeek(xFilial("BA0")+cCodOpe))
        nTimePost := BA0->BA0_HATMIP
        nTimeGet  := BA0->BA0_HATMIG
        cQtdTry   := cValToChar(BA0->BA0_HATTRY)
    endIf

    nTimePost := iif(nTimePost==0,2,nTimePost) //Se nao informado, padrao de Post e 2 minutos
    nTimeGet  := iif(nTimeGet ==0,5,nTimeGet)  //Se nao informado, padrao de Get e 5 minutos
    cQtdTry   := iif(empty(cQtdTry),"5",cQtdTry) //Se nao informado, padrao de Try e 5

    cTimePost := SubMinutos(Date(),Time(),nTimePost)
    cTimeGet  := SubMinutos(Date(),Time(),nTimeGet)
 
    cQuery := " UPDATE "
    cQuery += " " + RetSqlName('BNV') + " "
    cQuery += " SET "
    cQuery += " BNV_ROBOID = ' ' "
    cQuery += " ,BNV_PROCES = '" + PROCESSING + "' "
    cQuery += " ,BNV_ROBOHR = ' ' "
    cQuery += " ,BNV_STATUS = '" + HAT_PENDENTE_ENVIO + "' "
    cQuery += " WHERE 1=1 "
    cQuery += " AND	BNV_FILIAL = '" + xFilial("BNV") + "'
    if !Empty(cCodOpe)
        cQuery += " AND BNV_CODOPE = '"+cCodOpe+"' "
    endIf
    cQuery += " AND BNV_ROBOHR <> ' ' "
    cQuery += " AND ( "
    cQuery += "   ( BNV_ROBOID <> ' ' AND BNV_PROCES = '" + PROCESSING + "' AND BNV_ROBOHR <= '" + cTimePost + "') OR " //Registros com falha de processamento
    cQuery += "   ( BNV_STATUS IN (' ','0','1','2') AND BNV_QTDTRY < "+cQtdTry+" AND BNV_ROBOHR <= '" + cTimePost + "')) " //Reseta para Post
	//Removido trecho pois nao vamos mais fazer Get para verificar se processou corretamente
    //cQuery += "  OR ( BNV_STATUS IN ('3','4') AND BNV_QTDTRY < "+cQtdTry+" AND BNV_ROBOHR <= '" + cTimeGet  + "')) " //Reseta para Get
	cQuery += " AND D_E_L_E_T_ = ' ' "
    
    self:setQuery(cQuery)
    lFound := self:execStatement()

Return lFound

Method GetProcess(cIdProc) Class PlsDaoBNV
    
    Local cCodOpe   := self:toString(self:getValue("operatorRecord"))
    Local cQuery    := ''
    Local lFound    := .F.
    Default cIdProc := ''
    
    cQuery := " SELECT  "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('BNV') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	BNV_FILIAL = '" + xFilial("BNV") + "' "
    if !Empty(cCodOpe)
        cQuery += " AND BNV_CODOPE = '"+cCodOpe+"' "
    endIf
    cQuery += " AND BNV_ROBOID = '"+ AllTrim(Str(cIdProc)) +"' "
    cQuery += " AND BNV_PROCES = '" + PROCESSED + "' "
	cQuery += " AND D_E_L_E_T_ = ' ' "
    
    self:setQuery(cQuery)
    lFound := self:executaQuery()
    If lFound
		BNV->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

Return lFound
