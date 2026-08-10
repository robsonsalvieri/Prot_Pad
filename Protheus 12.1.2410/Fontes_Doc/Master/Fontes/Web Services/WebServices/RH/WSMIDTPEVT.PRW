#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWAdapterEAI.ch"
#INCLUDE "WSMIDTPEVT.CH"


/*/{Protheus.doc} WSRESTFUL GPEEsocialEvents
API de retorno dos eventos utilizados no eSocial
@author  Hugo de Oliveira
@since   06/11/2019
@version 12.1.25
/*/
WSRESTFUL GPEEsocialEvents DESCRIPTION oEmToAnsi( STR0001 ) FORMAT APPLICATION_JSON
	WSMETHOD GET DESCRIPTION oEmToAnsi( STR0002 ); 
	WSSYNTAX "api/rh/esocial/v1/GPEEsocialEvents/"; 
	PATH "api/rh/esocial/v1/GPEEsocialEvents/"; 
	TTALK "v1"; 
	PRODUCES APPLICATION_JSON
END WSRESTFUL


/*/{Protheus.doc} WSMETHOD GET
Retorna o código e a descrição dos eventos utilizados no eSocial
@author  Hugo de Oliveira
@since   06/11/2019
@version 12.1.25
/*/
WSMETHOD GET WSRESTFUL GPEEsocialEvents
	Local oData
	Local oItems
	Local cRet		:= ""
	Local nX 		:= 1
	Local aCode 	:= {}
	Local aDesc 	:= {}
	Local aItems 	:= {}
	Local lRet		:= .T.

	aCode := fSetCode()
	aDesc := fSetDesc()
	
	// Montagem dos itens
	For nX := 1 TO LEN( aCode )
		oData 						:= JsonObject():new()
		oData["eventCode"] 			:= aCode[nX]
		oData["eventDescription"]	:= aDesc[nX]
		
		AADD(aItems, oData)
		FreeObj( oData )
	NEXT nX
	
	oItems			:= JsonObject():new()
	oItems["items"] := aItems
	cRet 			:= fCompress(@oItems)
	
	::SetResponse( cRet )
RETURN lRet


/*/{Protheus.doc} function fSetCode
Seta o código dos eventos
@author  Hugo de Oliveira
@since   06/11/2019
@version 12.1.25
/*/
Static Function fSetCode()
	Local aCode := {}
	
	// Códigos
	AADD( aCode, "S-1000" )
	AADD( aCode, "S-1005" )
	AADD( aCode, "S-1010" )
	AADD( aCode, "S-1020" )
	AADD( aCode, "S-1030" )
	AADD( aCode, "S-1035" )
	AADD( aCode, "S-1040" )
	AADD( aCode, "S-1050" )
	AADD( aCode, "S-1060" )
	AADD( aCode, "S-1070" )
	AADD( aCode, "S-1200" )
	AADD( aCode, "S-1210" )
	AADD( aCode, "S-1280" )
	AADD( aCode, "S-1295" )
	AADD( aCode, "S-1298" )
	AADD( aCode, "S-1299" )
	AADD( aCode, "S-1300" )
	AADD( aCode, "S-2190" )
	AADD( aCode, "S-2200" )
	AADD( aCode, "S-2205" )
	AADD( aCode, "S-2206" )
	AADD( aCode, "S-2210" )
	AADD( aCode, "S-2220" )
	AADD( aCode, "S-2221" )
	AADD( aCode, "S-2230" )
	AADD( aCode, "S-2240" )
	AADD( aCode, "S-2250" )
	AADD( aCode, "S-2260" )
	AADD( aCode, "S-2298" )
	AADD( aCode, "S-2299" )
	AADD( aCode, "S-2300" )
	AADD( aCode, "S-2306" )
	AADD( aCode, "S-2399" )
	AADD( aCode, "S-2500" )
	AADD( aCode, "S-2501" )
	AADD( aCode, "S-2555" )
	AADD( aCode, "S-3000" )
	AADD( aCode, "S-3500" )
Return aCode


/*/{Protheus.doc} function fSetDesc
Seta a descrição dos eventos
@author  Hugo de Oliveira
@since   06/11/2019
@version 12.1.25
/*/
Static Function fSetDesc()
	Local aDesc := {}
	
	// Descrições
	AADD( aDesc, oEmToAnsi( STR0006 ) )
	AADD( aDesc, oEmToAnsi( STR0007 ) )
	AADD( aDesc, oEmToAnsi( STR0008 ) )
	AADD( aDesc, oEmToAnsi( STR0009 ) )
	AADD( aDesc, oEmToAnsi( STR0010 ) )
	AADD( aDesc, oEmToAnsi( STR0011 ) )
	AADD( aDesc, oEmToAnsi( STR0012 ) )
	AADD( aDesc, oEmToAnsi( STR0013 ) )
	AADD( aDesc, oEmToAnsi( STR0014 ) )
	AADD( aDesc, oEmToAnsi( STR0015 ) )
	AADD( aDesc, oEmToAnsi( STR0016 ) )
	AADD( aDesc, oEmToAnsi( STR0017 ) )
	AADD( aDesc, oEmToAnsi( STR0018 ) )
	AADD( aDesc, oEmToAnsi( STR0019 ) )
	AADD( aDesc, oEmToAnsi( STR0020 ) )
	AADD( aDesc, oEmToAnsi( STR0021 ) )
	AADD( aDesc, oEmToAnsi( STR0022 ) )
	AADD( aDesc, oEmToAnsi( STR0023 ) )
	AADD( aDesc, oEmToAnsi( STR0024 ) )
	AADD( aDesc, oEmToAnsi( STR0025 ) )
	AADD( aDesc, oEmToAnsi( STR0026 ) )
	AADD( aDesc, oEmToAnsi( STR0027 ) )
	AADD( aDesc, oEmToAnsi( STR0028 ) )
	AADD( aDesc, oEmToAnsi( STR0044 ) )
	AADD( aDesc, oEmToAnsi( STR0029 ) )
	AADD( aDesc, oEmToAnsi( STR0038 ) )
	AADD( aDesc, oEmToAnsi( STR0030 ) )
	AADD( aDesc, oEmToAnsi( STR0031 ) )
	AADD( aDesc, oEmToAnsi( STR0037 ) )
	AADD( aDesc, oEmToAnsi( STR0032 ) )
	AADD( aDesc, oEmToAnsi( STR0033 ) )
	AADD( aDesc, oEmToAnsi( STR0034 ) )
	AADD( aDesc, oEmToAnsi( STR0035 ) )
	AADD( aDesc, oEmToAnsi( STR0039 ) )
	AADD( aDesc, oEmToAnsi( STR0040 ) )
	AADD( aDesc, oEmToAnsi( STR0042 ) ) 
	AADD( aDesc, oEmToAnsi( STR0036 ) )
	AADD( aDesc, oEmToAnsi( STR0043 ) ) 
Return aDesc


/*/{Protheus.doc} function fCompress
Compacta o objeto JSON
@author  Hugo de Oliveira
@since   06/11/2019
@version 12.1.25
/*/
Static Function fCompress(oObj)
	Local cJson    := ""
	Local cComp    := ""
	Local lCompact := .F.
	
	// Set gzip format to Json Object
	cJson := oObj:toJSON()
	cJson := EncodeUTF8(cJson)

	If Type("::GetHeader('Accept-Encoding')") != "U"  .and. 'GZIP' $ Upper(::GetHeader('Accept-Encoding') )
		lCompact := .T.
	EndIf
	
	If(lCompact)
		::SetHeader('Content-Encoding','gzip')
		GzStrComp(cJson, @cComp, @nLenComp )
	Else
		cComp := cJson
	Endif
Return cComp


