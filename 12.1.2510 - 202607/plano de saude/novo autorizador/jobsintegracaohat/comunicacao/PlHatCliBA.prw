#INCLUDE "TOTVS.CH"
#INCLUDE "PlsHatClient.ch"

class PlHatCliBA from PlHatCli

    public method new() constructor

    public method get()
    public method put(resourceId, requestBody)

endclass

method new() class PlHatCliBA
    _Super:new()
    self:apiVersion := "v1/"
    self:endpoint := "batchesAuthorization"
return self

method get() class PlHatCliBA
    local httpResult := ""
    local parseError := .F.

    if self:success
        self:responseBody := JsonObject():new()
        self:httpClient:setChkStatus(.F.)
        self:httpClient:setPath(self:endpoint + "?" + self:getPage() + "&" + self:getPageSize() + self:generatePath())
        self:httpClient:get(self:requestHeader)
        httpResult := decodeUtf8(self:httpClient:getResult())
        self:statusCode := val(self:httpClient:oResponseH:cStatusCode)
        if !empty(self:statusCode) .and. !empty(httpResult)
            if self:statusCode >= STATUS_SUCCESS .and. self:statusCode < STATUS_REDIRECTION
                self:responseBody:fromJson(httpResult)
                parseError := !(empty(self:responseBody:fromJson(httpResult)))
                if parseError
                    self:log("Erro ao interpretar retorno do HAT")
                    self:success := .F.
                else
                    self:hasNext := self:responseBody["hasNext"]
                    self:page := Soma1(self:page)
                endif
            elseif self:statusCode >= STATUS_CLIENT_ERROR .and. self:statusCode < STATUS_SERVER_ERROR
                if self:statusCode == STATUS_NOT_FOUND
                    self:log("Nenhum lote disponivel para processamento no momento")
                else
                    self:responseBody:fromJson(httpResult)
                    parseError := !(empty(self:responseBody:fromJson(httpResult)))
                    if parseError
                        self:log("Erro desconhecido na solicitação realizada ao HAT pelo PLS")
                    else
                        self:log("Erro na solicitação realizada ao HAT pelo PLS: [" + self:responseBody["message"] + "]")
                    endif
                endif
                self:success := .F.
            elseif self:statusCode >= STATUS_SERVER_ERROR
                self:responseBody:fromJson(httpResult)
                parseError := !(empty(self:responseBody:fromJson(httpResult)))
                if parseError
                    self:log("Erro desconhecido na API do HAT")
                else
                    self:log("Erro na API do HAT: [" + self:responseBody["message"] + "]")
                endif
                self:success := .F.
            endif
        elseif !empty(httpResult)
            self:log("Erro desconhecido: [" + httpResult + "]")
            self:success := .F.
        else
            self:log("Erro desconhecido na API do HAT")
            self:success := .F.
        endif
    endif

return self:success

method put(resourceId, requestBody) class PlHatCliBA
    local httpResult := ""
    local parseError := .F.

    if self:success
        self:responseBody := JsonObject():new()
        self:httpClient:setChkStatus(.F.)
        self:httpClient:setPath(self:endpoint + "/" + resourceId + "?" + self:generatePath())
        self:httpClient:put(self:requestHeader, requestBody:toJson())
        httpResult := decodeUtf8(self:httpClient:getResult())
        self:statusCode := val(self:httpClient:oResponseH:cStatusCode)
        if !empty(self:statusCode) .and. !empty(httpResult)
            if self:statusCode >= STATUS_SUCCESS .and. self:statusCode < STATUS_REDIRECTION
                self:responseBody:fromJson(httpResult)
                parseError := !(empty(self:responseBody:fromJson(httpResult)))
                if parseError
                    self:log("Erro ao interpretar retorno do HAT")
                    self:success := .F.
                endif
            elseif self:statusCode >= STATUS_CLIENT_ERROR .and. self:statusCode < STATUS_SERVER_ERROR
                self:responseBody:fromJson(httpResult)
                parseError := !(empty(self:responseBody:fromJson(httpResult)))
                if parseError
                    self:log("Erro desconhecido na solicitação realizada ao HAT pelo PLS")
                else
                    self:log("Erro na solicitação realizada ao HAT pelo PLS: [" + self:responseBody["message"] + "]")
                endif
            elseif self:statusCode >= STATUS_SERVER_ERROR
                self:responseBody:fromJson(httpResult)
                parseError := !(empty(self:responseBody:fromJson(httpResult)))
                if parseError
                    self:log("Erro desconhecido na API do HAT")
                else
                    self:log("Erro na API do HAT: [" + self:responseBody["message"] + "]")
                endif
                self:success := .F.
            endif
        elseif !empty(httpResult)
            self:log("Erro desconhecido: [" + httpResult + "]")
            self:success := .F.
        else
            self:log("Erro desconhecido na API do HAT")
            self:success := .F.
        endif
    endif

return self:success
