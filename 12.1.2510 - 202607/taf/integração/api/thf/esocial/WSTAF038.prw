#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH" 
#INCLUDE "RESTFUL.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} certificateValidity
API para retornar informacoes do Certificado Digital do TSS. 
Utiliza-se o consumo do método CFGSTATUSCERTIFICATE da API SPEDCFGNFE do WS do 
TSS configurado no parametro MV_TAFSURL.

@author     Fabio Santos de Mendonça
@since      07/06/2021
@version    1.0 
/*/
//------------------------------------------------------------------------------
WSRESTFUL certificateValidity DESCRIPTION "API eSocial - Consulta Dados do Certificado Digital do TSS" FORMAT APPLICATION_JSON

    WSDATA companyId        AS STRING

    WSMETHOD GET;
        DESCRIPTION "Retorna dados do Certificado Digital parametrizado no TSS";
        WSSYNTAX "/api/rh/esocial/v1/certificateValidity/?{companyId}"; 
        PATH "/api/rh/esocial/v1/certificateValidity/"; 
        TTALK "v1";
        PRODUCES APPLICATION_JSON 
 
END WSRESTFUL 

//------------------------------------------------------------------------------
/*/{Protheus.doc} QUERYPARAM

Método GET para retornar dados do Certificado Digital no TSS apontado 
pelo parametro MV_TAFSURL

@author     Fabio Santos de Mendonça
@since      07/06/2021
@version    1.0
/*/
//------------------------------------------------------------------------------
WSMETHOD GET QUERYPARAM companyId WSRESTFUL certificateValidity

    Local lRet        := .T.
    Local oResponse   := JsonObject():New()
    local aResponse   := {}
    Local cEmpRequest := ""
	Local cFilRequest := ""
    Local cToken      := 'TOTVS'

    Local aCompany		:=	{}

    If self:companyId == Nil
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
	Else
		aCompany := StrTokArr( self:companyId, "|" )

		If Len( aCompany ) < 2
			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
		Else
			cEmpRequest := aCompany[1]
			cFilRequest := aCompany[2]

			If PrepEnv( cEmpRequest, cFilRequest )
            
                // Recupera informacoes do Certificado Digital
                aResponse   := certificadosTSS(cToken) 
                If aResponse[len(aResponse)][1]

                    oResponse["certificateType"] := aResponse[1][2]
                    oResponse["issuer"]          := aResponse[1][3]
                    oResponse["subject"]         := aResponse[1][4]
                    oResponse["validFrom"]       := aResponse[1][5]
                    oResponse["validTo"]         := aResponse[1][6]
                    oResponse["version"]         := aResponse[1][7]

                    ::SetResponse(oResponse:ToJson())
                Else
                    
                    lRet := .F.
                    SetRestFault(400, EncodeUTF8(aResponse[1][2]),,,;
                                    EncodeUTF8(aResponse[1][3]))
                EndIf        
                

            Else
				lRet := .F.
				SetRestFault( 400, EncodeUTF8( "Falha na preparação do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + cFilRequest + "'." ) )
			EndIf
		EndIf
    EndIf

    oResponse := Nil
    FreeObj(oResponse)
    DelClassIntF()

Return lRet 


//------------------------------------------------------------------------------
/*/{Protheus.doc} certificadosTSS

Recupera data do Certificado parametrizado no servidor TSS apontado pelo
parâmetro MV_TAFSURL

@param      userToken		- Token de conexão
@return   	aRet -  [status de retorno]
                    [mensagem erro/certificateType]
                    [mensagem detalhada erro/issuer]
                    [subject]
                    [validFrom]
                    [validTo]
                    [version]

@author 	Fabio Mendonça
@version	12.1.23 / Superior
@Since		07/06/2021
/*/
//------------------------------------------------------------------------------
Static Function certificadosTSS(userToken)

	Local cURLTSS	:= ""
	Local oWS
	Local aRet 		:= {} 
	Local nIndex
    Local cIdEnt    := AllTrim(TAFRIdEnt(,,,,,.T.))

    If FindFunction( "TAFGetUrlTSS" )
	    cURLTSS := PadR( TAFGetUrlTSS(), 250 )
    Else
	    cURLTSS := PadR( GetNewPar( "MV_TAFSURL", "http://" ), 250 )
    EndIf

	// Instancia e Parametriza WS de SPEDCFGNFe
	oWs            := WsSpedCfgNFe():New()
	oWs:cUserToken := userToken
	oWs:cID_ENT    := cIdEnt		
	oWS:_URL       := allTrim(cURLTSS) + "/SPEDCFGNFe.apw"
	
	// Verifica Conexão
	If oWs:CFGCONNECT()
		// Executa método WS de CFGStatusCertificate
		If oWs:CFGStatusCertificate()
			// Checa se XML de retorno possui certificados 
			If Len(oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE) > 0
				For nIndex := 1 To Len(oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE)
					aAdd(aRet, {.T.,;
                                cValToChar(oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE[nIndex]:NCERTIFICATETYPE),;
                                oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE[nIndex]:CISSUER,;
                                oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE[nIndex]:CSUBJECT,;
                                DTOS(oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE[nIndex]:DVALIDFROM),;
                                DTOS(oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE[nIndex]:DVALIDTO),;
                                oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE[nIndex]:CVERSION})
				Next nIndex
			Else
                aAdd(aRet, {.T.,,,,,,})
			EndIf
        Else
            aAdd(aRet, {.F., "Nao foi possivel obter informacoes de Certificados",;
                            "Endpoint CFGSTATUSCERTIFICATE da API SPEDCFGNFE falhou ou retornou vazio."})  
		EndIf
	Else
		aAdd(aRet, {.F., "TSS nao pode ser conectado.",;
                        "A tentativa de conexao na API SPEDCFGNFE falhou. Favor verificar: Query Params informados." +;
                        " TSS ativo. Parametros Protheus com conteudos validos."})  
	EndIf

Return aRet
