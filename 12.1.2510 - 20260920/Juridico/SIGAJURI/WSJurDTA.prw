#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "WSJURDTA.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WSJurDTA
Métodos WS REST do Jurídico para configuração do DTA IA..

@since 20/02/2026
/*/
//-------------------------------------------------------------------
WSRESTFUL JURDTA DESCRIPTION STR0001 //"Métodos WS REST do Jurídico para configuração do DTA IA."

	WSMETHOD GET vldUserDTA DESCRIPTION STR0002 PATH "validUserDTA" PRODUCES APPLICATION_JSON // "Valida se o usuário tem acesso ao DTA IA."

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} vldUserDTA
Valida se o usuário tem acesso ao DTA IA.

@since 20/02/2026
@example GET -> http://localhost:12173/rest/JURDTA/validUserDTA
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET vldUserDTA WSREST JURDTA
Local oResponse  := JsonObject():New()
Local aVldIniDTA := J268VldLDt()
Local cToken     := ""

	If !Empty(aVldIniDTA[2])
		cToken := Encode64("sigajuri:!:"+aVldIniDTA[2]+":!:dta")
	EndIf

	Self:SetContentType("application/json")
	oResponse["UserDTA"]         := aVldIniDTA[1]
	oResponse["InfoDTA"]         := cToken
	oResponse["hasUploadBucket"] := .T. // Proteção para versões desatualizadas do DTA IA

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

