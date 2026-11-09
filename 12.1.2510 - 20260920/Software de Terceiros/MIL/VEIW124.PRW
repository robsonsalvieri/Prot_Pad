#INCLUDE 'totvs.ch'
#INCLUDE 'restful.ch'
#INCLUDE 'VEIW124.ch'


WSRESTFUL dms_api_oauth DESCRIPTION "Endpoints oauth DMS" //Endpoints oauth DMS
	WSDATA code AS STRING // token recebido para acessar apis
	WSDATA state AS STRING  // state que liga com a conta que está fazendo login

	WSMETHOD GET  OAUTH DESCRIPTION "DMS OAUTH2 API"  WSSYNTAX "/dms_api_oauth/oauth2?{code, state}" PATH "/dms_api_oauth/oauth2" // DMS OAUTH2 API GET|POST pois depende como eles mandam o redirect não tenho certeza
	WSMETHOD POST OAUTH DESCRIPTION "DMS OAUTH2 API"  WSSYNTAX "/dms_api_oauth/oauth2?{code, state}" PATH "/dms_api_oauth/oauth2" // DMS OAUTH2 API GET|POST pois depende como eles mandam o redirect não tenho certeza 
END WSRESTFUL


WSMETHOD GET  OAUTH WSRECEIVE code, state WSSERVICE dms_api_oauth
	local oAuth

	::SetContentType("application/json")

	nHandle := TCGetConn()
	if nHandle < 0
		nHandle := TCLink()
	endif

	If nHandle < 0
		::setResponse('{ "status": 500 , "error": "'+STR0001+'" }')
		HttpSetStatus(500)
		return .t.
	Else
		conout( "Conectado com " + TcGetDB() )
	Endif

	oAuth := OFOAUTH2():New()

	if ! empty(self:code) .and. ! empty(self:state)
		oAuth:SaveToken(self:code, self:state)
		::setResponse('{ "status": 200, "message": "'+STR0002+'" }')
		HttpSetStatus(200)
		return .t.
	endif
	HttpSetStatus(404)
Return .t.

WSMETHOD POST OAUTH WSRECEIVE code, state WSSERVICE dms_api_oauth
	local oAuth

	::SetContentType("application/json")

	nHandle := TCGetConn()
	if nHandle < 0
		nHandle := TCLink()
	endif

	If nHandle < 0
		::setResponse('{ "status": 500 , "error": "'+STR0001+'" }')
		HttpSetStatus(500)
		return .t.
	Else
		conout( "Conectado com " + TcGetDB() )
	Endif

	oAuth := OFOAUTH2():New()

	if ! empty(self:code) .and. ! empty(self:state)
		oAuth:SaveToken(self:code, self:state)
		::setResponse('{ "status": 200, "message": "'+STR0002+'" }')
		HttpSetStatus(200)
		return .t.
	endif
	HttpSetStatus(404)
Return .t.
