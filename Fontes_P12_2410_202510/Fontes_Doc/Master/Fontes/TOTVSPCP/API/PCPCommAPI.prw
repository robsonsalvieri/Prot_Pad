#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

/*/{Protheus.doc} PCPCommAPI
API REST com métodos para realização de testes de configuração e comunicação
@type  WSCLASS
@author renan.roeder
@since 24/03/2023
@version P12.1.2310
/*/
WSRESTFUL PCPCommAPI DESCRIPTION "API REST com métodos para realização de testes de configuração e comunicação"

WSMETHOD GET WHOIS;
	DESCRIPTION "Método para teste de comunicação";
	WSSYNTAX "api/pcp/v1/pcpcommapi/whois";
	PATH "api/pcp/v1/pcpcommapi/whois";
    TTALK "v1"

END WSRESTFUL

WSMETHOD GET WHOIS WSSERVICE PCPCommAPI
    Local lRet := .T.

    ::SetContentType("application/json")
    ::SetResponse(JsonObject():New())
Return lRet
