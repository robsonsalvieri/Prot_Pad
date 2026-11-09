#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH" 
#INCLUDE "RESTFUL.CH"
#INCLUDE "WSTAF037.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} statusEnvironmentSocial
Método GET para retornar o status do ambiente do TAF eSocial e versão do Layout, 

@author Melkzminely Siqueira Silva
@since 18/02/2021
@version 1.0 
/*/
//------------------------------------------------------------------------------
WSRESTFUL statusEnvironmentSocial DESCRIPTION "API eSocial - Consulta status do ambiente e versão do Layout" FORMAT APPLICATION_JSON

    WSDATA companyId AS STRING

    WSMETHOD GET;
        DESCRIPTION "Retorna o status do ambiente do TAF eSocial e versão do Layout, parametrizado no Protheus.";
        WSSYNTAX "/api/rh/esocial/v1/statusEnvironmentSocial/?{companyId}"; 
        PATH "/api/rh/esocial/v1/statusEnvironmentSocial/"; 
        TTALK "v1";
        PRODUCES APPLICATION_JSON 
 
END WSRESTFUL 

//------------------------------------------------------------------------------
/*/{Protheus.doc} statusEnvironmentSocial
Método GET para retornar o status do ambiente do TAF eSocial e versão do Layout, 
parametrizado no Protheus.

@author Melkzminely Siqueira Silva
@since 18/02/2021
@version 1.0 
/*/
//------------------------------------------------------------------------------
WSMETHOD GET QUERYPARAM companyId WSRESTFUL statusEnvironmentSocial

    Local cResponse := ""
    Local lRet		:= .T.
	Local aInfoTSS	:= {}
    Local oResponse := Nil

    ::SetContentType("application/json")

    // Inicialização variáveis do tipo object
    oResponse := JsonObject():New()
    
    // Valida a existência da filial no TAF, tabela C1E
    If PrepEnvFil(::companyId)

		If Findfunction("GetInfoTSS")
			aInfoTSS := GetInfoTSS()
		EndIf

        oResponse["statusEnvironmentSocial"]:= Iif(AllTrim(GetMv("MV_TAFAMBE")) == "1", "production", "restrictedProduction")
        oResponse["versionLayoutSocial"] 	:= "layout_" + AllTrim(GetMv("MV_TAFVLES"))
        oResponse["tssEntity"] 			    := EncodeUTF8(aInfoTSS[1])
		oResponse["versionTSS"]				:= EncodeUTF8(aInfoTSS[2])
		
        cResponse := FWJsonSerialize(oResponse, .T., .T.,, .F.) 
        
        ::SetResponse(cResponse)

    Else

        lRet := .F.

    Endif

    FreeObj(oResponse)

Return lRet 

//------------------------------------------------------------------------------
/*/{Protheus.doc} PrepEnvFil
Prepara o ambiente de acordo com o parâmetro 'companyId'.

@author Melkzminely Siqueira Silva
@since 18/02/2021
@version 1.0
/*/
//------------------------------------------------------------------------------
Static Function PrepEnvFil(companyId)

    Local aCompany		:= {}
    Local cEmpRequest	:= ""
    Local cFilRequest	:= ""
    Local lAmbiente		:= .T.
    Local lRet			:= .T.

    If companyId == Nil

        lRet := .F.
        SetRestFault(400, EncodeUTF8("Empresa|Filial não informado no parâmetro 'companyId'."))

    Else

        aCompany := StrTokArr(companyId, "|")

        If Len( aCompany ) < 2

            lRet := .F.
            SetRestFault(400, EncodeUTF8("Empresa|Filial não informado no parâmetro 'companyId'."))

        Else

            cEmpRequest := aCompany[1]
            cFilRequest := aCompany[2]

            If Type( "cEmpAnt" ) == "U" .OR. Type( "cFilAnt" ) == "U"

                RPCClearEnv()
                RPCSetType(3)
                RPCSetEnv(cEmpRequest, cFilRequest,,, "TAF")

            ElseIf cEmpAnt <> cEmpRequest

                If FWFilExist(cEmpRequest, cFilRequest)

                    RPCClearEnv()
                    RPCSetType(3)
                    RPCSetEnv(cEmpRequest, cFilRequest,,, "TAF")

                Else

                    lAmbiente := .F.

                EndIf

            ElseIf cFilAnt <> cFilRequest

                cFilAnt := cFilRequest

            EndIf

            If !lAmbiente .AND. !FWFilExist(cEmpRequest, cFilRequest)

                lRet := .F.
                SetRestFault(400, EncodeUTF8("Falha na preparação do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + cFilRequest + "'."))
            
            EndIf

        EndIf

    EndIf

Return lRet
