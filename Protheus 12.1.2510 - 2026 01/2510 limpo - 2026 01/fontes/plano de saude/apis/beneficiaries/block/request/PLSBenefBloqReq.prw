#Include "PROTHEUS.CH"
#Include "RESTFUL.CH"
#Include "PLSBENEFBLOQSRV.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSBenefBloqReq
Classe para realizar a solicitação de bloqueio dos beneficiários

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 13/06/2022
/*/
//------------------------------------------------------------------- 
Class PLSBenefBloqReq From CenRequest 

    Data oRest As Object
    Data cMatriculaSolicitante As String
    Data lBloqFamilia As Boolean
    Data aBloqBeneficiarios As Array
 
    Method New(oRest) CONSTRUCTOR
    Method Post()
    Method Get()
    Method InitRequest()
    Method GetBeneficiariosBody()
    Method ProcessPost()
    Method ProcessGet()
   
EndClass


//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da classe

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 13/06/2022
/*/
//------------------------------------------------------------------- 
Method New(oRest) Class PLSBenefBloqReq

    _Super:New()

    self:oRest := oRest

    Self:cMatriculaSolicitante := ""
    Self:lBloqFamilia := .F.
    Self:aBloqBeneficiarios := {}

Return Self


//-------------------------------------------------------------------
/*/{Protheus.doc} Post
Adiciona um novo protocolo de bloqueio para o beneficiário

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 13/06/2022
/*/
//------------------------------------------------------------------- 
Method Post() Class PLSBenefBloqReq

    If Self:InitRequest("POST")
        Self:ProcessPost()
    Endif

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Get
Retorna um protocolo de bloqueio do beneficiário

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 20/06/2022
/*/
//------------------------------------------------------------------- 
Method Get() Class PLSBenefBloqReq

    If Self:InitRequest("GET")
        Self:ProcessGet()
    Endif

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} InitRequest
Valida a inicialização dos verbos utilizados na classe

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 14/06/2022
/*/
//------------------------------------------------------------------- 
Method InitRequest(cVerbo) Class PLSBenefBloqReq

    Local lInitRequest := .T.
    Local cBody := ""
    Local oJson := JsonObject():New()

    Default cVerbo := ""

    Do Case
        Case cVerbo == "POST"
            
            If Empty(self:oRest:subscriberId)
                lInitRequest := .F.
                Self:lSuccess := .F.
                Self:nStatus := 400
                Self:nFault := "BL01"
                Self:cFaultDesc := STR0001 // "Obrigatório informar a matricula do beneficiário como parâmetro."
                Self:cFaultDetail := STR0002 // "Parâmetro subscriberId não informado no Endpoint da requisição."
            Else    
                Self:cMatriculaSolicitante := self:oRest:subscriberId

                cBody := self:oRest:GetContent()
                If !Empty(cBody)
                    oJson:FromJson(cBody)

                    Self:lBloqFamilia := IIf(ValType(oJson["familyBlock"]) == "L", oJson["familyBlock"], .F.)
                    Self:aBloqBeneficiarios := Self:GetBeneficiariosBody(oJson)

                Else
                    aAdd(Self:aBloqBeneficiarios, Self:cMatriculaSolicitante)
                EndIf
            EndIf

        Case cVerbo == "GET"

            If Empty(self:oRest:subscriberId)
                lInitRequest := .F.
                Self:lSuccess := .F.
                Self:nStatus := 400
                Self:nFault := "BL01"
                Self:cFaultDesc := STR0001 // "Obrigatório informar a matricula do beneficiário como parâmetro no Endpoint."
                Self:cFaultDetail := STR0002 // "Parâmetro subscriberId não informado no Endpoint da requisição."
            Else    
                Self:cMatriculaSolicitante := self:oRest:subscriberId
            EndIf
    EndCase   

Return lInitRequest


//-------------------------------------------------------------------
/*/{Protheus.doc} InitRequest
Retornar os beneficiários que serão bloqueados, inclusive o solicitante

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 14/06/2022
/*/
//------------------------------------------------------------------- 
Method GetBeneficiariosBody(oJson) Class PLSBenefBloqReq

    Local aBloqBeneficiarios := {}
    Local nX := 0 

    aAdd(aBloqBeneficiarios, Self:cMatriculaSolicitante)

    If ValType(oJson["beneficiaries"]) == "A" .And. Len(oJson["beneficiaries"]) > 0

        For nX := 1 To Len(oJson["beneficiaries"])

            If ValType(oJson["beneficiaries"][nX]["subscriberId"]) == "C"
                aAdd(aBloqBeneficiarios, oJson["beneficiaries"][nX]["subscriberId"])
            EndIf 

        Next nX

    EndIf

Return aBloqBeneficiarios


//-------------------------------------------------------------------
/*/{Protheus.doc} ProcessPost
Processa a solicitação de bloqueio

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 15/06/2022
/*/
//------------------------------------------------------------------- 
Method ProcessPost() Class PLSBenefBloqReq
    
    Local lProcess := .T.
    Local oService := PLSBenefBloqSrv():New()
    Local oError := Nil

    If oService:AddProtocolBloq(Self:cMatriculaSolicitante, Self:lBloqFamilia, Self:aBloqBeneficiarios)
        Self:lSuccess := .T.
        Self:cResponse := oService:GetResult()
        Self:nStatus := oService:GetStatusCode()
    Else
        oError := oService:GetError()
        Self:lSuccess := .F.
        Self:nFault := oError["code"]
        Self:nStatus := oError["status"]
        Self:cFaultDesc := oError["message"]
        Self:cFaultDetail := oError["detailedMessage"]
        lProcess := .F.
    EndIf

Return lProcess


//-------------------------------------------------------------------
/*/{Protheus.doc} ProcessGet
Processa o retorno da solicitação de bloqueio do beneficiário

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 20/06/2022
/*/
//------------------------------------------------------------------- 
Method ProcessGet() Class PLSBenefBloqReq

    Local lProcess := .T.
    Local oService := PLSBenefBloqSrv():New()
    Local oError := Nil

    If oService:RetProtocolBloq(Self:cMatriculaSolicitante)
        Self:lSuccess := .T.
        Self:cResponse := oService:GetResult()
        Self:nStatus := oService:GetStatusCode()
    Else
        oError := oService:GetError()
        Self:lSuccess := .F.
        Self:nFault := oError["code"]
        Self:nStatus := oError["status"]
        Self:cFaultDesc := oError["message"]
        Self:cFaultDetail := oError["detailedMessage"]
        lProcess := .F.
    EndIf

Return lProcess