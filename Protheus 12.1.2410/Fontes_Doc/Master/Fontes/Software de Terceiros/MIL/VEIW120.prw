#INCLUDE 'totvs.ch'
#INCLUDE 'restful.ch'
#Include "TopConn.ch"
#INCLUDE "VEIW120.ch"

WSRESTFUL dms_api_checklist DESCRIPTION STR0001 //Integração REST para o CHECKLIST
 WSDATA id AS STRING
 WSDATA code AS STRING
 WSDATA type AS STRING 
 WSDATA codeVRX AS STRING
 WSDATA searchNew AS STRING
 WSDATA pageSize AS NUMBER
 WSDATA page AS NUMBER
 WSDATA search AS STRING
 WSDATA filter AS STRING
 WSDATA isCombo AS LOGICAL
 WSDATA codeIntVRZ AS STRING
 WSDATA iTestEnv AS STRING

 WSMETHOD GET CHECKLIST   DESCRIPTION STR0002  WSSYNTAX "/dms_api_checklist/checklist?{page, pageSize, search, filter, type}" PATH "/dms_api_checklist/checklist" PRODUCES APPLICATION_JSON //Consultar as checklists criadas
  WSMETHOD GET ONE_CHECKLIST DESCRIPTION STR0002  WSSYNTAX "/dms_api_checklist/checklist/edit?{id}" PATH "/dms_api_checklist/checklist/edit" //Consultar as checklists criadas
 WSMETHOD POST CHECKLIST  DESCRIPTION STR0003  WSSYNTAX "/dms_api_checklist/checklist" PATH "/dms_api_checklist/checklist" //Receber Checklist para ser criada
 WSMETHOD PUT TOGGLE_ACTIVE DESCRIPTION STR0015 WSSYNTAX "/dms_api_checklist/checklist/toggle_active?{codeVRX}" PATH '/dms_api_checklist/checklist/toggle_active' //Troca o status de ativado/Desativado do checklist

 WSMETHOD GET RESPONSE  DESCRIPTION STR0004  WSSYNTAX "/dms_api_checklist/response?{page, pageSize, search, codeIntVRZ}" PATH "/dms_api_checklist/response" //Consultar as checklists respondidas criadas
 WSMETHOD POST RESPONSE DESCRIPTION STR0005  WSSYNTAX "/dms_api_checklist/response" PATH "/dms_api_checklist/response" //Cadastra as respostas da checklist
 
END WSRESTFUL

WSMETHOD GET CHECKLIST WSRECEIVE page, pageSize, search, filter, type WSSERVICE dms_api_checklist
return getChecklistList(self:page, self:pageSize, self:search, self:filter, self, self:type, self:iTestEnv)

WSMETHOD GET RESPONSE WSRECEIVE page, pageSize, search, codeIntVRZ WSSERVICE dms_api_checklist
return getResponseList(self:page, self:pageSize, self:search, self, self:codeIntVRZ, self:iTestEnv)

WSMETHOD GET ONE_CHECKLIST WSRECEIVE id WSSERVICE dms_api_checklist
    local oResponse       := JsonObject():New()
    local oChecklistClass   := VEChecklistClass():New()

    ::SetContentType("application/json")
    
    oChecklistClass := oChecklistClass:AndEq("VRX_TABELA","093")
    oChecklistClass := oChecklistClass:AndEq("VRX_FILIAL", xFilial("VRX"))
    oChecklistClass := oChecklistClass:AndEq("VRX_CODIGO", self:id)

    oResponse['items'] := oChecklistClass:First()
    oResponse['items'] := oResponse['items']:ToJsonApi()

    HandleResponse(oResponse, 200,"achado com sucesso, " + STR0008) //checklists
    ::setResponse(oResponse:toJson())
Return .t.

WSMETHOD POST CHECKLIST WSSERVICE dms_api_checklist
 	local oContent      := {}
	local oResponse     := JsonObject():New()
    local oChecklistClass := VEChecklistClass():New()

    ::SetContentType("application/json")
    oContent := JsonObject():New()
	oContent:FromJson(::GetContent())
    
    oChecklistClass:MassAssign(oContent)
    oChecklistClass:Set("VRX_DADOS", oContent['VRX_DADOS']:ToJson())
    oChecklistClass:Set("VRX_HASH", MD5( oContent['VRX_DADOS']:ToJson() + " MIL", 2))
    
     if oChecklistClass:Save()
     	oResponse['checklist'] := oChecklistClass:Last()
		oResponse['checklist'] := oResponse['checklist']:ToJsonData()
    else
        Return HandleBadResponse(oResponse, 400, STR0009) //Informações inválidas, tente novamente!
    endif

    HandleResponse(oResponse, 201, STR0010) //Checklist criada com sucesso!
    ::setResponse(oResponse:ToJson())
Return .t.

WSMETHOD POST RESPONSE WSSERVICE dms_api_checklist
 	local oContent      := {}
	local oResponse     := JsonObject():New()
    local oChecklistClass := VEChecklistResponseClass():New()

    ::SetContentType("application/json")
    oContent := JsonObject():New()
	oContent:FromJson(::GetContent())


    oChecklistClass:MassAssign(oContent)
    CONOUT( oContent['VRZ_DADOS']:ToJson())
    oChecklistClass:Set("VRZ_DADOS", oContent['VRZ_DADOS']:ToJson())

     if oChecklistClass:Save()
     	oResponse['checklist'] := oChecklistClass:Last()
		oResponse['checklist'] := oResponse['checklist']:ToJsonData()
    else
        Return HandleBadResponse(oResponse, 400, STR0009) //Informações inválidas, tente novamente!
    endif

    oResponse['id'] := oChecklistClass:Get("VRZ_CODIGO")

    HandleResponse(oResponse, 201, STR0012) //resposta criada com sucesso!
    ::setResponse(oResponse:ToJson())
Return .t.

WSMETHOD PUT TOGGLE_ACTIVE WSRECEIVE codeVRX WSSERVICE dms_api_checklist
    local oResponse       := JsonObject():New()
    local oChecklistClass   := VEChecklistClass():New()
    local cMessage := ""

    if empty(self:codeVRX)
        return HandleBadResponse(oResponse, 400, STR0016) //Bad Request, codigo VRX informado é invalido
    endif

    oChecklistClass := oChecklistClass:AndEq("VRX_CODIGO", self:codeVRX):first()

    if ! oChecklistClass:Persistido()
        return HandleBadResponse(oResponse, 404, STR0017) //Não foi possível encontrar o checklist, tente novamente
    endif

    oChecklistClass:ToggleActive()

    cMessage := IIF(oChecklistClass:Get("VRX_ATUAL") == "1", STR0019, STR0020) //Checklist ativado com sucesso ou Checklist desativado com sucesso
    HandleResponse(oResponse, 200, cMessage)
    ::setResponse(oResponse:ToJson())
Return .t.


Static Function HandleResponse(oResponse, nCode, cMessage)
    oResponse['code'] := nCode
    oResponse['message'] := cMessage
Return .t.

Static Function HandleBadResponse(oResponse, nCode, cMessage)
    oResponse['code'] := nCode
    oResponse['message'] := cMessage

    SetRestFault(nCode, cMessage)
return .f.

Static Function getChecklistList( page, pagesize, search, filter, OWS, cType, iTestEnv)
   Local lRet  as logical
   Local oProd as object
   DEFAULT page      := 1 
   DEFAULT pagesize  := 10
   DEFAULT search    := ""
   DEFAULT iTestEnv  := .f.
   lRet        := .T.
   oProd := ChecklistAdapter():new( 'GET' ) 

   oProd:setPage(page)
   oProd:setPageSize(pagesize)
   CONOUT(filter)
   oProd:GetListChecklist(search, filter, cType)

   If !oProd:lOk .OR. !empty(iTestEnv)
       SetRestFault(oProd:GetCode(),oProd:GetMessage())
       lRet := .F.
   Else
       oWS:SetResponse(oProd:getJSONResponse())
   EndIf

   oProd:DeActivate()
   oProd := nil  
Return lRet

Static Function getResponseList( page, pagesize, search, OWS, codeIntVRZ, iTestEnv)
   Local lRet  as logical
   Local oProd as object
   DEFAULT page      := 1 
   DEFAULT pagesize  := 10
   DEFAULT search    := ""
   DEFAULT iTestEnv  := .f.
   lRet        := .T.
   oProd := ChecklistAdapter():new( 'GET' ) 

   oProd:setPage(page)
   oProd:setPageSize(pagesize)
   oProd:GetListResponse(search, codeIntVRZ)

   If !oProd:lOk .OR. !empty(iTestEnv)
       SetRestFault(oProd:GetCode(),oProd:GetMessage())
       lRet := .F.
   Else
       oWS:SetResponse(oProd:getJSONResponse())
   EndIf

   oProd:DeActivate()
   oProd := nil  
Return lRet