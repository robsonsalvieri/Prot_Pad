#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2
#Define PROCESSING '0'
#Define PROCESSED '1'

#DEFINE MSSQL     "MSSQL"
#DEFINE POSTGRES  "POSTGRES"
#DEFINE ORACLE    "ORACLE"


Class PlsDaoB1R from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method delete()
    Method bscChaPrim()
    Method commit(lInclui, protocol)
    Method setProcessing()
    Method getMessage()
    Method setEndProc(nRecno)
    Method setExpired()
    Method GetProcess(cIdProc)
    
EndClass

Method New(aFields) Class PlsDaoB1R
	_Super:New(aFields)
    self:cAlias := "B1R"
    self:cfieldOrder := "B1R_PROTOC"
Return self

Method buscar() Class PlsDaoB1R
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		B1R->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class PlsDaoB1R
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class PlsDaoB1R

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B1R') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	B1R_FILIAL = '" + xFilial("B1R") + "' "

    cQuery += " AND B1R_PROTOC = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("protocol")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()
    If lFound 
		B1R->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

return lFound

Method commit(lInclui, protocol) Class PlsDaoB1R
    default lInclui := .F.
    
    if lInclui        
        protocol := B1R->(GetSXENum("B1R","B1R_PROTOC"))
    endif

	If B1R->(RecLock("B1R",lInclui))
		
        B1R->B1R_FILIAL := xFilial("B1R")
        If lInclui        
            B1R->B1R_PROTOC := _Super:normalizeType(B1R->B1R_PROTOC, protocol)
            B1R->(ConfirmSX8())
        EndIf
        B1R->B1R_HATARQ := _Super:normalizeType(B1R->B1R_HATARQ, self:getValue("fileUrl"))
        B1R->B1R_HATTOK := _Super:normalizeType(B1R->B1R_HATTOK, self:getValue("accessToken"))
        B1R->B1R_HATTIP := _Super:normalizeType(B1R->B1R_HATTIP, self:getValue("transactionType"))
        B1R->B1R_ORIGEM := _Super:normalizeType(B1R->B1R_ORIGEM, self:getValue("healthProviderId"))
        B1R->B1R_PROTOG := _Super:normalizeType(B1R->B1R_PROTOG, self:getValue("sourceProtocol"))
        B1R->B1R_PROTOI := _Super:normalizeType(B1R->B1R_PROTOI, self:getValue("generatedProtocol"))
        B1R->B1R_DATSUB := _Super:normalizeType(B1R->B1R_DATSUB, self:getValue("uploadDate"))
        B1R->B1R_STATUS := _Super:normalizeType(B1R->B1R_STATUS, self:getValue("status"))

        B1R->(MsUnlock())
        lFound := .T.
    EndIf

Return lFound

Method setProcessing() Class PlsDaoB1R

    Local cQuery := ""
    Local lFound := .F.

    If self:cDB <> POSTGRES

        cQuery := iif(self:cDB $ MSSQL," UPDATE TOP(1) "," UPDATE ")
        cQuery += " " + RetSqlName('B1R') + " "
        cQuery += " SET "
        cQuery += " B1R_PROCES = '" + PROCESSING + "' "
        cQuery += " , B1R_ROBOID ='"+self:toString(self:getValue("processId"))+"' "
        cQuery += " , B1R_ROBOHR = '" + DToS(Date()) + " " + Time() + "' "
        cQuery += " WHERE 1=1 "
        cQuery += " AND B1R_FILIAL = '" + xFilial( 'B1R' ) + "' "
	    cQuery += " AND B1R_STATUS = '0' "
	    cQuery += " AND B1R_HATARQ <> ' ' "
        cQuery += " AND B1R_PROCES <> '" + PROCESSED + "' "
        cQuery += " AND B1R_ROBOID = ' ' "

        If (self:cDB $ "ORACLE")
            cQuery += "	AND ROWNUM = 1 "
        EndIf
        cQuery += " AND D_E_L_E_T_ = ' ' "
    Else
        cQuery := " UPDATE " + RetSqlName('B1R') + " SET "
        cQuery += " B1R_PROCES = '" + PROCESSING + "' "
        cQuery += " , B1R_ROBOID ='"+self:toString(self:getValue("processId"))+"' "
        cQuery += " , B1R_ROBOHR = '" + DToS(Date()) + " " + Time() + "' "
        cQuery += " WHERE R_E_C_N_O_ = (SELECT R_E_C_N_O_ FROM  " + RetSqlName('B1R') + " WHERE  "
        cQuery += " B1R_FILIAL = '" + xFilial( 'B1R' ) + "' "
	    cQuery += " AND B1R_STATUS = '0' "
	    cQuery += " AND B1R_HATARQ <> ' ' "
        cQuery += " AND B1R_PROCES <> '" + PROCESSED + "' "
        cQuery += " AND B1R_ROBOID = ' ' "
        cQuery += " AND D_E_L_E_T_ = ' ' "
        cQuery += "	LIMIT 1 )"

    EndIf

    self:setQuery(cQuery)
    lFound := self:execStatement()

Return lFound

Method getMessage() Class PlsDaoB1R
    
    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B1R') + " "
	cQuery += " WHERE 1=1 "
    cQuery += " AND	B1R_FILIAL = '" + xFilial("B1R") + "' "
    cQuery += " AND B1R_PROCES = '" + PROCESSING + "' "
    cQuery += " AND B1R_ROBOID ='"+self:toString(self:getValue("processId"))+"' "
	
    self:setQuery(cQuery)
	lFound := self:executaQuery()
    If lFound
		B1R->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

return lFound

Method setEndProc(nRecno) Class PlsDaoB1R

    Local cQuery := ""
    Local lFound := .F.

    Default nRecno := 0

    If self:cDB <> POSTGRES

        cQuery := iif(self:cDB $ MSSQL," UPDATE TOP(1) "," UPDATE ")
        cQuery += " " + RetSqlName('B1R') + " "
        cQuery += " SET "
        cQuery += " B1R_PROCES = '" + PROCESSED + "' "
        cQuery += " WHERE 1=1 "
        cQuery += " AND R_E_C_N_O_ = '" + AllTrim(Str(nRecno)) + "' "

        If (self:cDB $ "ORACLE")
            cQuery += "	AND ROWNUM = 1 "
        EndIf

    Else
        cQuery := " UPDATE " + RetSqlName('B1R') + " SET "
        cQuery += " B1R_PROCES = '" + PROCESSED + "' "
        cQuery += " WHERE R_E_C_N_O_ = (SELECT R_E_C_N_O_ FROM  " + RetSqlName('B1R') + " "
        cQuery += " WHERE 1=1 "
        cQuery += " AND R_E_C_N_O_ = '" + AllTrim(Str(nRecno)) + "' "
        cQuery += "	LIMIT 1 )"

    EndIf

    self:setQuery(cQuery)
    lFound := self:execStatement()

Return lFound

Method setExpired() Class PlsDaoB1R
Return .T.

Method GetProcess(cIdProc) Class PlsDaoB1R
    
    Local cQuery    := ''
    Local lFound    := .F.
    Default cIdProc := ''
    
    cQuery := " SELECT  "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B1R') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	B1R_FILIAL = '" + xFilial("B1R") + "' "
    cQuery += " AND B1R_ROBOID = '"+ AllTrim(Str(cIdProc)) +"' "
    cQuery += " AND B1R_PROCES = '" + PROCESSED + "' "
	cQuery += " AND D_E_L_E_T_ = ' ' "
    
    self:setQuery(cQuery)
    lFound := self:executaQuery()
    If lFound
		B1R->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

Return lFound