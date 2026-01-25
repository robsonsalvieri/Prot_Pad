#INCLUDE "PROTHEUS.CH"
#INCLUDE "FATA902.CH"

#DEFINE ITEMSDETAILS "itemsDetails"
#DEFINE HEADERITEMS  "headerItems"
#DEFINE FIELDSINFO   "fieldsInfo"
#DEFINE CARDSINFO    "cardsInfo"

//-------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} vEndPntsDB
Funcao que valida a estrutura JSON de retorno dos endpoints do DashBoard informados conforme o parametro aEndPoints 
@param cBody      , caracter , Body da requisição realizada 
@param cURL       , character, URL do server a ser acessado pelos endPoints
@param aEndPoints , array    , Lista dos endpoints e suas respectivas estruturas para serem validadas
@param cAuth      , character, Conteudo do usuário e senha para HTTP Basic Authentication
@author Rafael Mota Previdi
@since 11/01/2021
@return aValid, array, Array indicando o endPoint e quais validacoes nao foram atendidas
@version Protheus 12
/*/
//-------------------------------------------------------------------------------------------------------------------
Function vEndPntsDB(cBody, cURL, aEndPoints, cAuth)
  Local jBody      := JsonObject():new()
  Local aValid     := {}
  Local cErrorJson := ""
  Local nEndPnt    := 0
  Local nQtdEndPnt := Len(aEndPoints)
  Local cEndPntID  := ""
  Local cEndPnt    := ""
  Local cMetEndPnt := ""
  Local aAtt       := {}

  Default cBody      := ""
  Default aEndPoints := {}

  // Obter os endpoints informados no Json
  cErrorJson := jBody:fromJson(DecodeUtf8(cBody))
  If !Empty(cErrorJson)
    For nEndPnt := 1 To nQtdEndPnt
        cEndPntID := aEndPoints[nEndPnt][1]
        EPnotVld(cEndPntID, STR0001 + cEndPntID + STR0002, @aValid) //#"O endpoint " # " informado não pode ser validado."
    Next nEndPnt

    FWFreeObj(jBody)
    Return aValid
  EndIf
  
  // Verificar o preenchimento, testar e validar os endpoints
  For nEndPnt := 1 To nQtdEndPnt
    cEndPntID  := aEndPoints[nEndPnt][1]
    cMetEndPnt := aEndPoints[nEndPnt][2]
    aAtt       := aEndPoints[nEndPnt][3]
    cEndPnt    := jBody[cEndPntID]    
    // Verificar o preenchimento
    If EndPntFill(cEndPnt, cEndPntID, @aValid)
        // Testar e validar os endpoints
        vldEndPnt(aAtt, cEndPnt, cEndPntID, cMetEndPnt, cURL, @aValid, cAuth)
    EndIf
  Next nEndPnt

  FreeObj(aAtt)
Return aValid

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EndPntFill
Funcao que valida se o endpoint informado no parametro foi preenchido
@param cEndPoint, character, Endpoint a ser validado          
@param cIdEndPnt, character, Identificador do Endpoint a ser validado          
@param aValid   , array    , Array indicando se o endpoint informado esta valido e o qual problema detectado
@author Rafael Mota Previdi
@since 11/01/2021
@return lFilled , boolean  , Indica se o endpoint foi preenchido ou nao
@version Protheus 12
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function EndPntFill(cEndPoint, cIdEndPnt, aValid)
  Local lFilled := .T.

  Default cIDEndPnt := ""
  Default cIdEndPnt := ""

  If Empty(cEndPoint)
    EPnotVld(cIdEndPnt, STR0001 + cIdEndPnt + STR0003, @aValid) //#"O endpoint " #" não foi preenchido no seu respectivo atributo informado no body da requisição."
    lFilled := .F.
  EndIf
Return lFilled

//-----------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} vldEndPnt
Funcao que ira testar e validar o endpoint conforme o parametro de atributos (aAtt) informado
@param aAtt      , array    , Array com os atributos a serem validados pela funcao
@param cEndPoint , character, URI do Endpoint a ser requisitado          
@param cIdEndPnt , character, Identificador do Endpoint a ser validado
@param cMethod   , character, Metodo a ser chamado no endpoint informado
@param cURL      , character, URL do server a ser acessado pelo endPoint           
@param aValid    , array    , Array indicando se o endpoint informado esta valido e o qual problema detectado
@param cAuth     , character, Conteudo do usuário e senha para HTTP Basic Authentication
@author Rafael Mota Previdi
@since 11/01/2021
@return Nil
@version Protheus 12
/*/
//-----------------------------------------------------------------------------------------------------------------
Static Function vldEndPnt(aAtt, cEndPoint, cIDEndPnt, cMethod, cURL, aValid, cAuth)
  Local oJson   := Nil

  Default cEndPoint := ""

  // Retirar a barra do inicio do endPoint, pois ela nao pode atrapalhar na montagem da URI na proxima funcao
  If (Substr(cEndPoint, 1, 1) == "/")
    cEndPoint := Substr(cEndPoint, 2)
  EndIf
  
  // Testar o endpoint
  oJson := TstEndPnt(cEndPoint, cIDEndPnt, cMethod, cURL, @aValid, cAuth)
  If (oJson:toJson() == "{}")
    FWFreeObj(oJson)
    Return Nil
  EndIf
  
  // Validar o Json de retorno da requisicao no endPoint
  VldJSON(oJson, aAtt, cIDEndPnt, @aValid)

  FWFreeObj(oJson)
Return Nil
//------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TstEndPnt
Funcao que realiza uma requisicao conforme o endPoint e metodos informados 
@param cEndPoint , character, URI do Endpoint a ser requisitado       
@param cIdEndPnt , character, Identificador do Endpoint a ser validado   
@param cMethod   , character, Metodo a ser chamado no endpoint informado
@param cURL      , character, URL do server a ser acessado pelo endPoint           
@param aValid    , array    , Array indicando se o endpoint informado esta valido e o qual problema detectado
@param cAuth     , character, Conteudo do usuário e senha para HTTP Basic Authentication
@author Rafael Mota Previdi
@since 11/01/2021
@return oResponse, JsonObject, Json do Response da requisicao
@version Protheus 12
/*/
//------------------------------------------------------------------------------------------------------------
Static Function TstEndPnt(cEndPoint, cIDEndPnt, cMethod, cURL, aValid, cAuth)
  Local oResponse   := JsonObject():New()
  Local oRestClient := Nil
  Local aHeader     := {}
  Local cErrorJson  := ""
  Local cErrorReq   := ""

  Default cEndPoint := ""
  Default cMethod   := ""
  Default cURL      := ""
 
  oRestClient := FWRest():New(cURL)
  oRestClient:setPath(cEndPoint)
  aAdd(aHeader,"Content-Type: application/json")
  aAdd(aHeader,"Authorization: " + cAuth)
  
  Do Case
    Case cMethod == "GET"
      If (oRestClient:Get(aHeader))
        cErrorJson := oResponse:fromJson(EncodeUTF8(oRestClient:GetResult()))
      Else
        cErrorReq := oRestClient:GetLastError()
      EndIf
    Case cMethod == "POST"
      If (oRestClient:Post(aHeader))
        cErrorJson := oResponse:fromJson(EncodeUTF8(oRestClient:GetResult()))
      Else
        cErrorReq := oRestClient:GetLastError()
      EndIf
    Otherwise
      FWFreeObj(oRestClient)
      FWFreeObj(aHeader)
      Return oResponse
  End Case

  If !Empty(cErrorJson)
    EPnotVld(cIdEndPnt, STR0004 + cEndPoint + STR0005 + cErrorJson + ".", @aValid) //#"A conversão do response do endpoint "  #" para um objeto JSON falhou - "
  EndIf

  If !Empty(cErrorReq)
    EPnotVld(cIdEndPnt, STR0006 + cEndPoint + " - " + cErrorReq + ".", @aValid) //#"Ocorreu um erro na requisição do endpoint "
  EndIf

  FWFreeObj(oRestClient)
  FWFreeObj(aHeader)
Return oResponse

//-----------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} VldJSON
Funcao que realiza uma validacao no retorno da requisição referente 
ao endpoint informado nos parametros desta funcao
@param oJson      , character, JSON a ser avaliado
@param aAttribute , array    , Array com os atributos a serem verificados
@param cIdEndPnt  , character, Identificador do Endpoint a ser validado   
@param aValid     , array    , Array indicando se o endpoint informado esta valido e o qual problema detectado
@author Rafael Mota Previdi
@since 11/01/2021
@return Nil
@version Protheus 12
/*/
//-----------------------------------------------------------------------------------------------------------------
Static Function VldJSON(oJson, aAttribute, cIDEndPnt, aValid)
  Local nAtt        := 0
  Local nQtdAtt     := 0
  Local aAttribut2  := {}
  Local nObj        := 0
  Local nQtdObj     := 0
  Local oAuxJson    := Nil
  Local cAttribute  := ""
  Local cType       := ""

  Default oJson      := JsonObject():new()
  Default aAttribute := {}

  nQtdAtt := Len(aAttribute)
  For nAtt := 1 To nQtdAtt
    cAttribute := aAttribute[nAtt][1]
    cType      := aAttribute[nAtt][2]
    VldJSONAtt(oJson, cAttribute, cType, cIDEndPnt, @aValid)

    If (Len(aAttribute[nAtt]) < 3)
      // Vai para o proximo atributo, pq ele nao tem sub-atributos
      Loop
    EndIf

    // Tratamento de sub-atributos
    If cType == "A" .And. ValType(oJson[cAttribute]) == "A"
      nQtdObj := Len(oJson[cAttribute])
      For nObj := 1 To nQtdObj
        aAttribut2 := aAttribute[nAtt][3]
        oAuxJson := oJson[cAttribute][nObj]
        VldJSON(oAuxJson, aAttribut2, cIDEndPnt, @aValid)
        FWFreeObj(oAuxJson)
        FWFreeObj(aAttribut2)
      Next nObj
    EndIf
  Next nAtt

Return Nil

//------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} VldJSONAtt
Funcao que realiza uma validacao em cada atributo do Json e dados informados nos parametros (nome e tipo)
@param oJson      , character, JSON a ser avaliado
@param cAttribute , character, Atributo a ser verificado
@param cType      , character, Tipo do atributo a ser verificado
@param cIDEndPnt  , character, ID do endpoint que esta chamando a funcao
@param aValid     , array    , Array indicando se o endpoint informado esta valido e o qual problema detectado
@author Rafael Mota Previdi
@since 11/01/2021
@return Nil
@version Protheus 12
/*/
//------------------------------------------------------------------------------------------------------------
Static Function VldJSONAtt(oJson, cAttribute, cType, cIDEndPnt, aValid)
  Default oJson      := JsonObject():New()
  Default cAttribute := ""
  Default cType      := ""
  Default cIDEndPnt  := ""

  If !oJson:HasProperty(cAttribute)
    EPnotVld(cIdEndPnt, STR0007 + cAttribute + STR0008 + cIDEndPnt + STR0009, @aValid) //#"O atributo " #" não existe no JSON retornado pelo endPoint " #" Informado."
    Return Nil
  EndIf

  If !(ValType(oJson[cAttribute]) == cType)
    EPnotVld(cIdEndPnt, STR0007 + cAttribute + STR0010 + cIDEndPnt + STR0011 + cType + STR0012, @aValid) //#"O atributo " #" do endPoint " #" não é do tipo " #" (Considerado pela função ValType do AdvPL)."
  EndIf
Return Nil

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EPnotVld
Funcao que recebe o identificador do endPoint e a mensagem da validação não atendida
@param cIDEndPnt  , character, ID do endpoint que esta chamando a funcao
@param cMessage   , character, Mensagem referente a validacao nao atendida
@param aValid     , array    , Array contendo as validacoes nao atendidas e que vai ser preenchido
@author Rafael Mota Previdi
@since 11/01/2021
@version Protheus 12
@return Nil
/*/
//-------------------------------------------------------------------------------------------------
Function EPnotVld(cIDEndPnt, cMessage, aValid)
  Default cIDEndPnt := ""
  Default cMessage  := ""
  Default aValid    := {}

  AAdd(aValid, {400, EncodeUtf8(STR0013 + cIDEndPnt), EncodeUtf8(cMessage), "", {} }) //#"Erro no endpoint "
Return Nil
