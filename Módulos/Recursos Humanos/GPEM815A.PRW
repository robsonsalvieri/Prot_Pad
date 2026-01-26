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

	Local cContext 		:= ""
	Local cJsonCompany  := ""
	Local cJsonContext  := ""

    cContext := "credtrab"

	If cType == "preLoad"
		cJsonCompany := '{ "company_code" : "' + FWGrpCompany() + '", "branch_code" : "' + FWCodFil() + '" }'
		cJsonContext := '{ "context" : "' + cContext + '" }'

		oWebChannel:AdvPLToJS( "setCompany", cJsonCompany )
		oWebChannel:AdvPLToJS( "setContext", cJsonContext )
	EndIf
	
Return()
