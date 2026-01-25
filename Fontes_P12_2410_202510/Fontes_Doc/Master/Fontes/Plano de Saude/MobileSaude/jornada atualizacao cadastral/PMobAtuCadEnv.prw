#Include "PROTHEUS.CH"
#Include "PMobAtuCad.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PMobAtuCadEnv
Classe para comunicar com a mobile saúde para atualizar o protocolo 
da atualização cadastral do beneficiario 
 
@author Vinicius Queiros Teixeira
@since 18/03/2021
@version Prothues 12
/*/
//-------------------------------------------------------------------
Class PMobAtuCadEnv From PlsRest

    Data cErrorMessage
    Data aAutomacao
    Data lGravaLog 
	Data cArquivoLog

    Method New(aAutomacao) CONSTRUCTOR
    Method MontaFormData(nIdOperadora, cMsHash, cMatricula, cProtocolo, cStatus, cObservacao)
    Method PostApi()
    Method GetMessageError()
    Method ImpLogApi(cMensagem, lTime)

EndClass


//----------------------------------------------------------
/*/{Protheus.doc} New
Construtor da Classe

@author Vinicius Queiros Teixeira
@since 18/03/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method New(aAutomacao) Class PMobAtuCadEnv

    Default aAutomacao := {}

    _Super:New()

    Self:cErrorMessage := ""
    Self:aAutomacao := aAutomacao
    Self:lGravaLog := .T.
	Self:cArquivoLog := "pls_mobile_api_atualizacao_cadastral.log"
        
Return


//----------------------------------------------------------
/*/{Protheus.doc} MontaFormData
Monta o FormData de atualização de protocolo de acordo com os 
parametros

@author Vinicius Queiros Teixeira
@since 18/03/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method MontaFormData(nIdOperadora, cMsHash, cMatricula, cProtocolo, cStatus, cObservacao) Class PMobAtuCadEnv

    Local oAtualizaProtocolo := JsonObject():New()
    Local oAuxMontJson := PMobJornMod():New()
    Local oStatus := Nil
    Local lOk := .T.

    Default nIdOperadora := 0
    Default cMsHash := ""
    Default cMatricula := ""
    Default cProtocolo := ""
    Default cStatus := ""
    Default cObservacao := ""

    oAtualizaProtocolo["id_operadora"] := oAuxMontJson:SetAtributo(nIdOperadora, "String")
    oAtualizaProtocolo["mshash"] := oAuxMontJson:SetAtributo(cMsHash, "String")
    oAtualizaProtocolo["matricula"] := oAuxMontJson:SetAtributo(cMatricula, "String")
    oAtualizaProtocolo["protocolo"] := oAuxMontJson:SetAtributo(cProtocolo, "String")

    Self:ImpLogApi("Atualizando status do protocolo: "+oAtualizaProtocolo["protocolo"])
	Self:ImpLogApi("", .F.)
    
    // Realiza o De/para do Status da Mobile
    oStatus := oAuxMontJson:GetDeParaCampo("status", "BBA_STATUS", "", cStatus)

    If oStatus["status"] 
        oAtualizaProtocolo["status"] := oAuxMontJson:SetAtributo(oStatus["dados"]["valorExterno"], "String")
    Else
        Self:cErrorMessage := STR0004 // "Status não configurado no cadastro de de/para, portanto não pode ser utilizado."
    EndIf

    If !Empty(cObservacao)
        oAtualizaProtocolo["observacao"] := oAuxMontJson:SetAtributo(cObservacao, "String")
    EndIf

    If !Empty(Self:cErrorMessage)
        lOk := .F.
        Self:ImpLogApi("*** Falha na montagem do form-data: "+Self:cErrorMessage, .F.)
        Self:ImpLogApi("", .F.)
        Self:ImpLogApi(Replicate("=", 100), .F.)
    Else    
        _Super:SetHeadPar("Content-Type", "multipart/form-data")

        _Super:SetJsonFormData("id_operadora", oAtualizaProtocolo["id_operadora"])
        _Super:SetJsonFormData("matricula", oAtualizaProtocolo["matricula"])
        _Super:SetJsonFormData("status", oAtualizaProtocolo["status"])
        _Super:SetJsonFormData("mshash", oAtualizaProtocolo["mshash"])
        _Super:SetJsonFormData("protocolo", oAtualizaProtocolo["protocolo"], .T.)

        Self:ImpLogApi("*** Form-data montado com sucesso!", .F.)
        Self:ImpLogApi("", .F.)
    EndIf

    FreeObj(oAtualizaProtocolo)
    oAtualizaProtocolo := Nil

Return lOk


//----------------------------------------------------------
/*/{Protheus.doc} PostApi
Realiza o envio do Metodo POST para a Api da Mobile Saúde

@author Vinicius Queiros Teixeira
@since 18/03/2022
@version Prothues 12
/*/
//----------------------------------------------------------
Method PostApi() Class PMobAtuCadEnv

    Local lRetorno := .F.
    Local oResponse := JsonObject():New()

    Self:ImpLogApi("*** Dados da comunicação", .F.)
    Self:ImpLogApi("*** JSON: "+Self:cJson, .F.)
    Self:ImpLogApi("*** EndPoint: "+Self:cEndPoint, .F.)

    If !Empty(Self:cJson) .And. !Empty(Self:cEndPoint)

        If Len(Self:aAutomacao) > 0
            Self:lSucess := .T.
            Self:cRespJson := Self:aAutomacao[2] 
        Else
            _Super:comunPost()
        EndIf

        If Self:lSucess
            oResponse:FromJSON(Self:cRespJson)

            Self:ImpLogApi("*** Comunicação realizada com sucesso! ", .F.)
            Self:ImpLogApi("*** JSON de retorno: "+Self:cRespJson, .F.)

            If ValType(oResponse["status"]) == "L" .And. oResponse["status"]
                lRetorno := .T.
            Else
                Self:cErrorMessage := IIf(ValType(oResponse["msg"]) == "C", STR0005+DecodeUtf8(oResponse["msg"]), "") // "Mensagem de error: "
            EndIf
        Else
            Self:ImpLogApi("*** Falha na comunicação: "+Self:cError, .F.)                 
        EndIf
    EndIf

    Self:ImpLogApi("", .F.)
    Self:ImpLogApi(Replicate("=", 100), .F.)

Return lRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} GetMessage
Retorna mensagens de erro

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 18/03/2022
/*/
//------------------------------------------------------------------- 
Method GetMessageError() Class PMobAtuCadEnv
Return Self:cErrorMessage


//-------------------------------------------------------------------
/*/{Protheus.doc} ImpLogApi
Imprime Log da API

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 22/06/2022
/*/
//------------------------------------------------------------------- 
Method ImpLogApi(cMensagem, lTime) Class PMobAtuCadEnv

    Default cMensagem := ""
    Default lTime := .T.

    If Self:lGravaLog .And. !Empty(Self:cArquivoLog)	
		
		If lTime 
			PlsLogFil("["+Time()+"]"+cMensagem, Self:cArquivoLog)
		Else
			PlsLogFil(cMensagem, Self:cArquivoLog)
		EndIf
    
    EndIf

Return