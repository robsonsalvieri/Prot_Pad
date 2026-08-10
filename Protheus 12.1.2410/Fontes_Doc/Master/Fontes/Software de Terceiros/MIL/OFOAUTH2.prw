#include 'totvs.ch'

/*/{Protheus.doc} OFOAUTH2
	Controla o oauth2.0 dos modulos dms

	Só para documentar, a forma como identificamos o usuário é através do State que é gerado no momento da requisição
	ao receber o resultado do redirect a unica coisa que liga as requests é o state
	
	@type class
	@author Vinicius Gati
	@since 27/01/2025
/*/
Class OFOAUTH2
	data oSqlHlp
	data cTableName

	data nCipherId
	data cSecret

	Method New() CONSTRUCTOR
	Method AddQueue()
	Method GetToken()
	Method SaveToken()
	Method SaveRefresh()
	Method RenewTokens()
	Method AnyValidToken()
	Method GetValidToken()
	Method RemoveExpRefreshToken()

	Method _Criptografa()
	Method _Descriptografa()
EndClass

/*/{Protheus.doc} New
	Construtor que cria a tabela de auth do dms 
	@type method
	@since 27/01/2025
/*/
Method New() Class OFOAUTH2
	Local cCreate := ""
	Local cDb := TcGetDb()
	::oSqlHlp := DMS_SqlHelper():New()
	::cTableName := 'DMS_AUTH2'
	::nCipherId := 2
	::cSecret := GetEnv("DMS_AUTH_SECRET")

	if empty(::cSecret)
		::cSecret := "DMSAUTHSECRET"
		conout("Variável de ambiente DMS_AUTH_SECRET é obrigatória e não foi definida, seus dados estão em risco.")
	endif

	cCreate += "CREATE TABLE "+::cTableName+ "( "
	cCreate += "  CLIENT_ID           VARCHAR(250), "
	cCreate += "  DATA                VARCHAR(8), "
	cCreate += "  STATE               VARCHAR(1000), "
	cCreate += "  CODUSR              VARCHAR(6), "
	cCreate += "  SERVICE             VARCHAR(2), "
	cCreate += "  REFRESH_VALID_UNTIL VARCHAR(8),"

	if cDb == "ORACLE"
		cCreate += "  REFRESH CLOB, "
		cCreate += "  CODE    CLOB "
	elseif cDb == "POSTGRES"
		cCreate += "  REFRESH TEXT, "
		cCreate += "  CODE    TEXT "
	else
		cCreate += "  REFRESH VARCHAR(4096), "
		cCreate += "  CODE    VARCHAR(4096) "
	endif

	cCreate += ")"

	if ! ::oSqlHlp:ExistTable( ::cTableName )
		TcSqlExec(cCreate)
		TcSqlExec("CREATE INDEX "+::cTableName+"_idx_1 ON "+::cTableName+" (STATE, SERVICE)")
		TcSqlExec("CREATE INDEX "+::cTableName+"_idx_2 ON "+::cTableName+" (DATA)")
		TcSqlExec("CREATE INDEX "+::cTableName+"_idx_3 ON "+::cTableName+" (REFRESH_VALID_UNTIL)")
		TcSqlExec("CREATE INDEX "+::cTableName+"_idx_4 ON "+::cTableName+" (SERVICE, REFRESH)")
	endIf
Return SELF

/*/{Protheus.doc} AnyValidToken
	Descricao

	@type method
	@author Vinicius Gati
	@since 07/04/2025
/*/
Method AnyValidToken(cUsrId, nService, cClientId) Class OFOAUTH2
	Local cQuery := ""
	cQuery += "SELECT COUNT(*) FROM " + self:cTableName
	cQuery += " WHERE CODUSR = '" + cUsrId + "'"
	cQuery += " AND SERVICE = '" + cValToChar(nService) + "'"
	cQuery += " AND REFRESH_VALID_UNTIL >= '" + dToS(dDataBase) + "'"
	cQuery += " AND CLIENT_ID = '" + cClientId + "'"
Return FM_SQL(cQuery) > 0

/*/{Protheus.doc} GetValidToken
	Retorna os dados do token validos

	@type method
	@author Vinicius Gati
	@since 07/04/2025
/*/
Method GetValidToken(cUsrId, nService, cClientId) Class OFOAUTH2
	Local cQuery := ""
	Local aRegs
	Local jReg

	cQuery += " SELECT REFRESH, CODE, STATE, CLIENT_ID "
	cQuery += " FROM " + self:cTableName
	cQuery += " WHERE CODUSR = '" + cUsrId + "' "
	cQuery += " AND SERVICE = '" + cValToChar(nService) + "' "
	cQuery += " AND REFRESH_VALID_UNTIL >= '" + dToS(dDataBase) + "'"
	cQuery += " AND CLIENT_ID = '" + cClientId + "'"

	aRegs := ::oSqlHlp:GetSelectJson({"CODE", "STATE", "REFRESH", "CLIENT_ID"}, ::oSqlHlp:TopFunc(cQuery, 1))
	if len(aRegs) == 0
		Return nil
	endif
	jReg := aRegs[1]
	jReg["CODE"] := self:_Descriptografa(jReg["CODE"])
	jReg["STATE"] := self:_Descriptografa(jReg["STATE"])
	jReg["REFRESH"] := self:_Descriptografa(jReg["REFRESH"])
	jReg["CLIENT_ID"] := jReg["CLIENT_ID"]
Return jReg

/*/{Protheus.doc} AddQueue
	Da insert na tabela de auth para quando receber o callback gravar os tokens

	@type method
	@author Vinicius Gati
	@since 03/04/2025
/*/
Method AddQueue(cUsrId, cState, nService, cClientId) Class OFOAUTH2
    Default cUsrId := "000000"
Return TcSqlExec("INSERT INTO " + self:cTableName + " (CODUSR, DATA, STATE, SERVICE, CLIENT_ID) VALUES ('"+left(cUsrId, 6)+"','" + dToS(dDatabase) + "', '" + self:_Criptografa(cState) + "', '"+cValToChar(nService)+"', '"+cValToChar(cClientId)+"')") >= 0

/*/{Protheus.doc} RemoveExpRefreshToken
	Deleta uma informação de token quando o mesmo foi detectado como invalido ou expirado por outro processo

	@type method
	@author Vinicius Gati
	@since 08/04/2025
/*/
Method RemoveExpRefreshToken(nService, cRefresh) Class OFOAUTH2
	if empty(cRefresh)
		return .t.
	endif
Return TcSqlExec("DELETE FROM " + self:cTableName + " WHERE SERVICE = '" + cValToChar(nService) + "' AND REFRESH = '" + self:_Criptografa(cRefresh) + "' ") >= 0

/*/{Protheus.doc} GetToken
	Retorna o token do STATE caso já tenha sido recebido

	@type method
	@author Vinicius Gati
	@since 27/01/2025
/*/
Method GetToken(cState, cClientId) Class OFOAUTH2
	Local cQuery := ""
	Local cEncCode
	
	cQuery += "SELECT CODE FROM " + self:cTableName
	cQuery += " WHERE STATE = '" + self:_Criptografa(cState) + "'"
	cQuery += " AND CODE != ' ' "
	cQuery += " AND CLIENT_ID = '" + cClientId + "' "
	
	cEncCode := FM_SQL(cQuery)
	
	if empty(cEncCode)
		Return ""
	endIf
Return self:_Descriptografa(cEncCode)

/*/{Protheus.doc} SaveToken
	Insere registro gravando STATE e codigo

	@type method
	@author Vinicius Gati
	@since 27/01/2025
/*/
Method SaveToken(cCode, cState) Class OFOAUTH2
	Local cQuery := ""

	if empty(cState) .or. empty(cCode)
		Return .f.
	endif
	cState := StrTran(cState, "State ", "")
	
	cQuery += "UPDATE " + self:cTableName
	cQuery += " SET CODE = '" + self:_Criptografa(cCode) + "'"
	cQuery += " WHERE STATE = '" + self:_Criptografa(cState) + "'"
Return TcSqlExec(cQuery) >= 0

/*/{Protheus.doc} SaveRefresh
	Insere registro gravando STATE e refresh token
	Será salvo o token com 15 dias de validade pois segundo JD o refresh token é gerado com 30 dias de validade
	deixando assim uma faixa de segurança para atuação

	@type method
	@author Vinicius Gati
	@since 25/03/2025
/*/
Method SaveRefresh(cRefresh, cState) Class OFOAUTH2
	Local cQuery := ""
	
	if empty(cState) .or. empty(cRefresh)
		Return .f.
	endif
	
	cQuery += "UPDATE " + self:cTableName
	cQuery += " SET REFRESH = '" + self:_Criptografa(cRefresh) + "',"
	cQuery += " REFRESH_VALID_UNTIL = '" + dToS(dDataBase + 30) + "'"
	cQuery += " WHERE STATE = '" + self:_Criptografa(cState) + "'"
	
Return TcSqlExec(cQuery) >= 0

/*/{Protheus.doc} RenewTokens
	Renova os tokens de acordo com o refresh token e a data de expiracao
	Como temos um prazo grande de 30 dias vou usar 25 dias para renovar o token assim fica seguro

	@type method
	@author Vinicius Gati
	@since 28/03/2025
/*/
Method RenewTokens() Class OFOAUTH2
	Local cQuery := ""
	Local cAl := GetNextAlias()
	Local cUsrId, cState, nService, cRefresh
	Local oOkta := OFJDOkta():New()

	cQuery += "SELECT CODUSR, STATE, SERVICE, REFRESH "
	cQuery += "FROM " + self:cTableName
	cQuery += " WHERE REFRESH_VALID_UNTIL <= '" + dToS(dDataBase + 5) + "'"

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAl, .F. , .T. )
	dbSelectArea(cAl)
	while ! (cAl)->(eof())
		cUsrId  := alltrim((cAl)->(CODUSR))
		cState  := self:_Descriptografa((cAl)->(STATE))
		nService := val(alltrim((cAl)->(SERVICE)))
		cRefresh := self:_Descriptografa((cAl)->(REFRESH))

		oOkta:RefreshTheToken(cUsrId, cState, nService, cRefresh)
		(cAl)->(DBSkip())
	EndDo
	(cAl)->(DBCloseArea())
Return

/*/{Protheus.doc} _Criptografa
	Encripta o valor para ser salvo no banco

	@type method
	@author Vinicius Gati
	@since 26/03/2025
/*/
Method _Criptografa(cPlainText) Class OFOAUTH2
	if empty(cPlainText)
		Return ""
	endif
Return RC4Crypt(cPlainText, self:cSecret, .T.)

/*/{Protheus.doc} _Descriptografa
	Decripta o valor para o original

	@type method
	@author Vinicius Gati
	@since 26/03/2025
/*/
Method _Descriptografa(cCipherText) Class OFOAUTH2
	if empty(cCipherText)
		Return ""
	endif
Return RC4Crypt(alltrim(cCipherText), self:cSecret, .F., .T.)
