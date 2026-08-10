#include 'totvs.ch'
#include 'restful.ch'
#include 'VEIW112.CH'

/*/{Protheus.doc} REST do Service Operations versao 1.0
	REST para manuseio de dms_api_so_1_0
	
	@type function
	@author Vinicius Gati
	@since 30/06/2021
/*/
WSRESTFUL dms_api_so_1_0 DESCRIPTION STR0001 // "INTEGRAÇÃO PROTHEUS X BLACKBOX - JOHN DEERE"
	WSMETHOD POST   DESCRIPTION STR0002 WSSYNTAX "/dms_api_so_1_0/{service}/{action}" // "POST Blackbox"
END WSRESTFUL

/*/{Protheus.doc} POST
	Busca os dms_api_dcp_1_0
	
	@type function
	@author Vinicius Gati
	@since 30/10/2018
/*/
WSMETHOD POST WSSERVICE dms_api_so_1_0
	local cMessage := alltrim(::aURLParms[2])
	local cEntity := alltrim(::aURLParms[1])
	local oResponse
	local cContent
	local oReq := OFSoRequestReceived():New(cMessage, ::GetContent())
	//Conout(" ")
	//ConOut(" __   __   __  ___           __   ___  __          __   ___     __   __   ___  __       ___    __        __  ")
	//ConOut("|__) /  \ /__`  |     __    /__` |__  |__) \  / | /  ` |__     /  \ |__) |__  |__)  /\   |  | /  \ |\ | /__` ")
	//ConOut("|    \__/ .__/  |           .__/ |___ |  \  \/  | \__, |___    \__/ |    |___ |  \ /~~\  |  | \__/ | \| .__/ ")
	//ConOut("                                                                                                             ")
	//Conout(" ")
	//ConOut(cMessage)
	//Conout(" ")
	// Conout(" BODY: " + ::GetContent())

	oReq:save()

	conout(cvaltochar(HTTPHeader("tenantId")))
	if empty(HTTPHeader("tenantId"))
		::SetResponse(' { "message": "tenantId not found" } ')
		HttpSetStatus(404)
		return .t.
	endif


	if ! empty(HTTPHeader("Content-Encoding"))
		conout("encoding : " + HTTPHeader("Content-Encoding"))
		if 'utf' $ HTTPHeader("Content-Encoding")
			cContent := FGX_GetFromSoJson(::GetContent())
		endif
	else
		cContent := ::GetContent()
	endif

	do case
		case cEntity == "Customer"
			oService := OFSoCustomerService():New()
			oResponse := oService:Process(::aUrlParms, cContent, HTTPHeader("X-Gateway-Properties"))
		case cEntity == "Contact"
			oService := OFSoContactService():New()
			oResponse := oService:Process(::aUrlParms, cContent, HTTPHeader("X-Gateway-Properties"))
		case cEntity == "Equipment"
			if "EquipmentModel" $ cMessage
				oService  := OFSoModelService():New()
				oResponse := oService:Process(::aUrlParms, cContent, HTTPHeader("X-Gateway-Properties"))
			else
				oService := OFSoEquipmentService():New()
				oResponse := oService:Process(::aUrlParms, cContent, HTTPHeader("X-Gateway-Properties"))
			endif
	end case

	if valtype(oResponse) == "O"
		::SetResponse(oResponse:ToJson())
		HttpSetStatus(oResponse:nCode)
		return .t.
	elseif valtype(oResponse) == "J"
		::SetResponse(oResponse:ToJson())
		if oResponse:HasProperty("code")
			HttpSetStatus(oResponse["code"])
		else
			HttpSetStatus(200)
		endif
		return .t.
	elseif valtype(oResponse) == "C"
		::SetResponse(oResponse)
		return .t.
	endif

	::SetResponse('{"code": 404, "message": "No response found"}')
	HttpSetStatus(404)
return .t.
