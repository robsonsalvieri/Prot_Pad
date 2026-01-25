#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE STR0001 "Retorna JSON de exemplo de envio" 
#DEFINE STR0002 "Executa liberação do romaneio"
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} struct
Estrutura de dados para array.
@type 	   Estrutura
/*/
//------------------------------------------------------------------------------------------
WSRESTFUL freightrelease DESCRIPTION "Serviço específico para liberação de romaneio do módulo SIGAGFE - GESTÃO DE FRETE EMBARCADOR"

    WSMETHOD GET  DESCRIPTION STR0001 WSSYNTAX "/freightrelease" // PATH "/freightrelease"
    WSMETHOD POST DESCRIPTION STR0002 WSSYNTAX "/freightrelease" // PATH "/freightrelease"
  
END WSRESTFUL
//-------------------------------------------------------------------
/*/{Protheus.doc} GET EXAMPL
Retorna XML de exemplo
@author  Lucas Briesemeister    
/*/
//-------------------------------------------------------------------
WSMETHOD GET WSSERVICE freightrelease
    Local cJson as char

    ::SetContentType("application/json")

    cJson := StrExampleJson()
    ::SetResponse(cJson)

Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} POST ROMLST
Realiza a liberação de romaneios 
@author  Lucas Briesemeister    
/*/
//-------------------------------------------------------------------
WSMETHOD POST WSSERVICE freightrelease

    Local cManifest   as char
    Local cMsg        as char
    Local dData       as date
    Local cHora       as char
    Local cContent    as char
    Local oContent    as object
    Local aManifests  as array
    Local aReturn     as array
    Local oResponse   as object
    Local nI          as numeric
    Local cJson       as char

    nI           := 1
    cJson        := ""
    cManifest    := ""
    cMsg         := ""
    dData        := Date()
    cHora        := ""
    oResponse    := JsonObject():New()
    aManifests := {}

    ::SetContentType("application/json")

    cContent := ::GetContent()

    If FWJsonDeserialize(cContent, @oContent)

        aManifests := CheckContent(oContent)
    
        If Empty(aManifests)
            SetRestFault(400, GetResponseJson(aManifests, .T.))
            Return .F.
        EndIf
    Else
        SetRestFault(400, "Erro na estrutura do JSON enviado com problemas.")
        Return .F.
    EndIf

    DbSelectArea("GWN")
    GWN->(DbSetOrder(1))

    For nI := 1 To Len(aManifests)

        If aManifests[nI]:Status == "ok"
        
            If GWN->(DbSeek(FWxFilial("GWN")+aManifests[nI]:ManifestNumber))
                Begin Transaction
                    If !Empty(aManifests[nI]:TrackingCode)
                        If Reclock("GWN", .F.)
                            GWN->GWN_RASTR  := aManifests[nI]:TrackingCode
                            GWN->(MsUnlock())
                        EndIf
                    EndIf

                    If !Empty(aManifests[nI]:DepartureOdometer)
                        If Reclock("GWN", .F.)
                            GWN->GWN_HODSAI := aManifests[nI]:DepartureOdometer
                            GWN->(MsUnlock())
                        EndIf
                    EndIf
                    If GFEA050LIB(.T./*lAuto*/,@cMsg, aManifests[nI]:DepartureDate, aManifests[nI]:DepartureTime)
                        aManifests[nI]:Status  := "ok"
                        aManifests[nI]:Message := "Romaneio liberado com sucesso"
                    Else
                        aManifests[nI]:Status  := "error"
                        aManifests[nI]:Message := cMsg
                        DisarmTransaction()
                        Break
                    EndIf
                End Transaction
            Else
                aManifests[nI]:Status  := "error"
                aManifests[nI]:Message := "Romaneio número "+cValToChar(aManifests[nI]:ManifestNumber)+" não encontrado"
            EndIf
        EndIf
    Next nI

    cJson := GetResponseJson(aManifests)

    ::SetResponse(cJson)

Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} CheckContent(oJson)
Valida conteúdo do json e retorna dados adaptados em objeto Manisfest
@author  Lucas Briesemeister
/*/
//-------------------------------------------------------------------
Static Function CheckContent(oJson)
    
    Local nI         as numeric
    Local nX         as numeric
    Local aManifests as array
    Local aReturn    as array
    Local oManisfest as object

    nI := 1
    nX := 1
    aReturn := {}
    aError  := {}

    aManifests := oJson:CONTENT[1]:ITEMS[1]:MANIFEST

    For nI := 1 To Len(aManifests)

        oManisfest := ManifestRelease():New()
        
        oManisfest:Adapter(aManifests[nI]:ITEMS)

        If Empty(oManisfest:ManifestNumber)
            oManisfest:Message := "Campo número do romaneio da posição "+cValToChar(nI)+" não foi informado"   
        EndIf

        Aadd(aReturn, oManisfest)

    Next nI

Return aReturn
//-------------------------------------------------------------------
/*/{Protheus.doc} StringExJson()
Retorna estrutura do JSON esperado
@author  Lucas Briesemeister    
/*/
//-------------------------------------------------------------------
Static Function StrExampleJson()

    Local cJson      as char
    Local oResponse  as object 
    
    //só copiei e colei e alterei os campos
    oResponse  := JsonObject():New()

	oResponse["content"] := {}
	Aadd(oResponse["content"], JsonObject():New())

	oResponse["content"][1]["Items"] := {}
	Aadd(oResponse["content"][1]["Items"], JsonObject():New())

	oResponse["content"][1]["Items"][1]["Manifest"] := {}

	Aadd(oResponse["content"][1]["Items"][1]["Manifest"], JsonObject():New())
	oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"] := {}
	
	Aadd(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"], JsonObject():New())
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"])["id"] := "ManifestNumber"
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"])["length"] := TamSX3("GWN_NRROM")[1]
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"])["type"] := "string"
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"])["Description"] := "Número do Romaneio para liberação"
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"])["value"] := "10000"
	
	Aadd(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"], JsonObject():New())
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"])["id"] := "DepartureDate"
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"])["length"] := TamSX3("GWN_DTSAI")[1]
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"])["type"] := "date"
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"])["Description"] := "Data de saída"
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"])["value"] := "12/04/2019"

    Aadd(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"], JsonObject():New())
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"])["id"] := "DepartureTime"
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"])["length"] := TamSX3("GWN_HRSAI")[1]
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"])["type"] := "string"
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"])["Description"] := "Hora de saída"
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"])["value"] := "00:00"

    Aadd(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"], JsonObject():New())
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"])["id"] := "DepartureOdometer"
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"])["length"] := TamSX3("GWN_HODSAI")[1]
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"])["type"] := "number"
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"])["Description"] := "Odômetro de saída"
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"])["value"] := "50000"

    Aadd(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"], JsonObject():New())
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"])["id"] := "TrackingCode"
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"])["length"] := TamSX3("GWN_RASTR")[1]
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"])["type"] := "string"
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"])["Description"] := "Código de Rastreamento"
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"])["value"] := "OGH4545454X454"

	cJson := EncodeUTF8(oResponse:toJson())

Return cJson

//-------------------------------------------------------------------
/*/{Protheus.doc} function
description
@author  author
/*/
//-------------------------------------------------------------------
Static Function GetResponseJson(aManifests, lError)

    Local cJson      as char
    Local nI         as numeric
    Local oResponse  as object
    Local oManisfest as object

    Default lError := .F.

    nI := 1
    oResponse := JsonObject():New()

    oResponse["content"] := {}
	Aadd(oResponse["content"], JsonObject():New())

	oResponse["content"][1]["Items"] := {}
	Aadd(oResponse["content"][1]["Items"], JsonObject():New())

    If !lError
        oResponse["content"][1]["Items"][1]["Status"]	:= "ok" 
	    oResponse["content"][1]["Items"][1]["Message"]	:= "freightrelease: Liberação(ões) de Frete realizada(s). Verifique o Status de cada Romaneio."
    
        oResponse["content"][1]["Items"][1]["FreightReleases"] := {}

        For nI := 1 to Len(aManifests)

            Aadd(oResponse["content"][1]["Items"][1]["FreightReleases"], JsonObject():New())
            oResponse["content"][1]["Items"][1]["FreightReleases"][nI]["Items"] := {}
            
            Aadd(oResponse["content"][1]["Items"][1]["FreightReleases"][nI]["Items"], JsonObject():New())
            aTail(oResponse["content"][1]["Items"][1]["FreightReleases"][nI]["Items"])["id"] 		  := "ManifestNumber"
            aTail(oResponse["content"][1]["Items"][1]["FreightReleases"][nI]["Items"])["value"] 	  := aManifests[nI]:ManifestNumber
            aTail(oResponse["content"][1]["Items"][1]["FreightReleases"][nI]["Items"])["Description"] := "Número do Romaneio para liberação"
            aTail(oResponse["content"][1]["Items"][1]["FreightReleases"][nI]["Items"])["Message"] 	  := aManifests[nI]:Message
            aTail(oResponse["content"][1]["Items"][1]["FreightReleases"][nI]["Items"])["Status"]      := aManifests[nI]:Status

        Next

    Else
        oResponse["content"][1]["Items"][1]["Status"]	:= "erro" 
	    oResponse["content"][1]["Items"][1]["Message"]	:= "Problema na estrutura da requisição. Verifique os campos enviados"
    EndIf

    cJson := EncodeUTF8(oResponse:toJson())

Return cJson
//-------------------------------------------------------------------
/*/{Protheus.doc} Class Manifest
Guarda os dados de cada romaneio enviado
@author  Lucas Briesemeister
/*/
//-------------------------------------------------------------------
Class ManifestRelease from LongClassNames

    Data ManifestNumber
    Data DepartureDate
    Data DepartureTime
    Data DepartureOdometer
    Data TrackingCode
    Data Message
    Data Status

    Method New() Constructor
    Method Adapter()

EndClass

Method New(Id) Class ManifestRelease

    ::Status := "ok"

Return Self

Method Adapter(aItems) Class ManifestRelease

    Local nI   as numeric

    nI   := 1

    For nI := 1 To Len(aItems)

        If !Empty(aItems[nI]:ID)
            Do Case 
                Case Upper(aItems[nI]:ID) == "MANIFESTNUMBER"
                    ::ManifestNumber := PadR(aItems[nI]:VALUE, TamSX3("GWN_NRROM")[1])
                Case Upper(aItems[nI]:ID) == "DEPARTUREDATE"
                    If !Empty(aItems[nI]:VALUE)
                        ::DepartureDate := CToD(aItems[nI]:VALUE)
                    Else
                        ::DepartureDate := Date()
                    EndIf
                Case Upper(aItems[nI]:ID) == "DEPARTURETIME"
                    If !Empty(aItems[nI]:VALUE)
                        ::DepartureTime := aItems[nI]:VALUE
                    Else
                        ::DepartureTime := SubStr(Time(), 1, 5)
                    EndIf
                Case Upper(aItems[nI]:ID) == "DEPARTUREODOMETER"
                    ::DepartureOdometer :=  Val(PadR(aItems[nI]:VALUE,TamSX3("GWN_HODSAI")[1]))
                Case Upper(aItems[nI]:ID) == "TRACKINGCODE" 
                    ::TrackingCode := PadR(aItems[nI]:VALUE,TamSX3("GWN_RASTR")[1])
            EndCase
        EndIf

    Next nI
    
Return 