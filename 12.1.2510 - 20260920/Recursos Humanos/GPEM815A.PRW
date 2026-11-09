#INCLUDE "PROTHEUS.CH"

Function GPEM815A()
    //Executa o app do Credito do Trabalhador
    FwCallApp("gpem815")
Return


//---------------------------------------------------------------------
/*/{Protheus.doc} JsToAdvpl
@type			function
@description	Bloco de código que receberá as chamadas JavaScript.
@author			caio.kretzer
@since			09/01/2025
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function JsToAdvpl( oWebChannel, cType, cContent )

	Local cContext     := ""
	Local cJsonCompany := ""
	Local cJsonContext := ""
	Local cParamsIni   := ""
	Local lMiddleware  := SuperGetMv("MV_MID",, .F.)	as Logical
	Local cUrlTSS      := ""
	Local cEnvironme   := ""
	Local cUrlTAF      := ""

    cContext := "credtrab"

	If cType == "preLoad"
		cJsonCompany := '{ "company_code" : "' + FWGrpCompany() + '", "branch_code" : "' + FWCodFil() + '" }'
		cJsonContext := '{ "context" : "' + cContext + '" }'

		cParamsIni := '{'
		cParamsIni += ' "urlTAF" : "' + cUrlTAF + '",'
		If lMiddleware
			cUrlTSS    := AllTrim(SuperGetMv("MV_GPEMURL",, "")) // URL de comunicação com o Middleware no SIGAGPE
			cEnvironme := AllTrim(SuperGetMv("MV_GPEAMBE",, "")) // Identificação do Ambiente e-Social 1-Produção, 3-Produção restrita-dados fictícios;
			cParamsIni += ' "isMiddleware" : true,'
		else
			cParamsIni += ' "isMiddleware" : false,'
		EndIf
		cParamsIni += ' "urlTSS" : "' + cUrlTSS + '",'
		cParamsIni += ' "environment" : "' + cEnvironme + '"'
		cParamsIni += ' }'

		oWebChannel:AdvPLToJS( "setCompany", cJsonCompany )
		oWebChannel:AdvPLToJS( "setContext", cJsonContext )
		oWebChannel:AdvPLToJS( "paramsInit", cParamsIni )
	EndIf

Return()
