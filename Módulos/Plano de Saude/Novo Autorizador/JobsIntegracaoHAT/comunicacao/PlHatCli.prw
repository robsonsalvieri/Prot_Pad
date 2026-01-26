#INCLUDE "TOTVS.CH"
#INCLUDE "PlsHatClient.ch"

class PlHatCli
    data apiVersion as character
    data enableLog as logical
    data endpoint as character
    data error as object
    data expand as array
    data fields as array
    data fileName as character
    data hasNext as logical
    data httpClient as object
    data order as array
    data page as character
    data pageSize as character
    data queryParams as array
    data requestHeader as array
    data responseBody as object
    data statusCode as numeric
    data success as logical

    public method new() constructor

    public method destroy()
    public method generatePath()
    public method getPage()
    public method getPageSize()
    public method getResponseBody()
    public method hasNext()
    public method log()
    public method pushExpand(expand)
    public method pushField(field)
    public method pushOrder(order)
    public method pushQueryParam(queryparam)
    public method setPageSize(pagesize)
    public method setup()
    public method getStatusCode()
    public method reset()

endclass

method new() class PlHatCli
    self:apiVersion := "v1/"
    self:expand := {}
    self:fields := {}
    self:hasNext := .T.
    self:order := {}
    self:page := "1"
    self:pageSize := "10"
    self:queryParams := {}
    self:requestHeader := {}
    self:enableLog := GetNewPar("MV_PSVCLOG","0") == "1"
    self:fileName := "plsxmldownload.log"
return self

method destroy() class PlHatCli
return

method generatePath() class PlHatCli
    local path := ""
    local control := 1
    local lenFields := len(self:fields)
    local lenExpand := len(self:expand)
    local lenOrder := len(self:order)
    local lenQueryParam := len(self:queryParams)

    // Aplica o parametro fields
    if lenFields > 0
        path += "&fields="
        while control <= lenFields
            path += self:fields[control]
            iif(control < lenFields,path += ",",nil)
            control++
        enddo
        control := 1
    endif

    // Aplica o parametro expand
    if lenExpand > 0
        path += "&expand="
        while control <= lenExpand
            path += self:expand[control]
            iif(control < lenExpand,path += ",",nil)
            control++
        enddo
        control := 1
    endif

    // Aplica o parametro expand
    if lenOrder > 0
        path += "&order="
        while control <= lenOrder
            path += self:order[control]
            iif(control < lenOrder,path += ",",nil)
            control++
        enddo
        control := 1
    endif

    // Aplica os parametros queryString
    if lenQueryParam > 0
        path += "&"
        while control <= lenQueryParam
            path += self:queryParams[control][1] + "=" + self:queryParams[control][2]
            iif(control < lenQueryParam,path += "&",nil)
            control++
        enddo
        control := 1
    endif

return path

method getPage() class PlHatCli
return "page=" + self:page

method getPageSize() class PlHatCli
return "pageSize=" + self:pageSize

method getResponseBody() class PlHatCli
return self:responseBody

method hasNext() class PlHatCli
return self:hasNext

method log(message, level) class PlHatCli
	if self:enableLog
        PlsPtuLog(AllTrim(Str(ThreadID())) + ";" + ; 
                  FWTimeStamp(5) + ";" + ;
                  message, ;
                  self:fileName)
    endif
return

method pushExpand(expand) Class PlHatCli
return aAdd(self:expand, expand)

method pushField(field) Class PlHatCli
return aAdd(self:fields, field)

method pushOrder(order) Class PlHatCli
return aAdd(self:order, order)

method pushQueryParam(queryparam) Class PlHatCli
return aAdd(self:queryparams, queryparam)

method setPageSize(pagesize) Class PlHatCli
return self:pagesize := pagesize

method setup() class PlHatCli
    local headerConfig := PLGDadHead()
    local hatUrl as character
    local response as object

    self:requestHeader := {}
    aAdd(self:requestHeader,headerConfig[AUTHORIZATION][NAME] + ": " + headerConfig[AUTHORIZATION][VALUE])
    aAdd(self:requestHeader,headerConfig[IDTENANT][NAME] + ": " + headerConfig[IDTENANT][VALUE])
    aAdd(self:requestHeader,headerConfig[TENANTNAME][NAME] + ": " + headerConfig[TENANTNAME][VALUE])

    hatUrl := GetNewPar("MV_PHATURL","")
    if !empty(hatUrl) .and. substr(hatUrl, len(hatUrl),1) <> "/"
        hatUrl += "/"
    elseif empty(hatUrl)
        self:log("Endpoint das APIs do HAT nao configurado, verifique o parâmetro MV_PHATURL")
        self:success := .F.
    endif

    self:httpClient := FwRest():new(hatUrl + self:apiVersion)
    self:httpClient:setPath("healthcheck")

    if self:httpClient:get(self:requestHeader)
        response := JsonObject():New()
        if empty(response:fromJson(self:httpClient:GetResult()))
            self:success := response["REST"] == "OK" .and.;
                            response["REDIS"] == "OK" .and.;
                            response["BANCO"] == "OK"
            if !(self:success)
                self:log("Erro ao se comunicar com a API de healthCheck do HAT, algum recurso pode estar indisponível no momento")
            endif
        else
            self:log("Erro ao se comunicar com a API de healthCheck do HAT, nao foi possível interpretar a resposta")
            self:success := .F.
        endif
    else
        self:log("Erro ao se comunicar com a API de healthCheck do HAT, nao foi possível obter resposta")
        self:success := .F.
    endif

return self:success

method getStatusCode() class PlHatCli
return self:statusCode

method reset() class PlHatCli
    PlsFreArr(@self:expand)
    PlsFreArr(@self:fields)
    PlsFreArr(@self:order)
    PlsFreArr(@self:queryParams)
    self:hasNext := .T.
    self:page := "1"
    self:pageSize := "10"
    self:success := .T.
return
