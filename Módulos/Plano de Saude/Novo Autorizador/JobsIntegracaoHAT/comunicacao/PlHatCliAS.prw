#INCLUDE "TOTVS.CH"
#INCLUDE "PlsHatClient.ch"

class PlHatCliAS
    data enableLog as logical
    data fileName as character
    data result

    public method new() constructor

    public method downloadXml(url, token)
    public method getResult()
    public method log(message, level)

endclass

method new() class PlHatCliAS
    self:enableLog := GetNewPar("MV_PSVCLOG","0") == "1"
    self:fileName := "plsxmldownload.log"
    self:result := ""
return self

method downloadXml(url, token) class PlHatCliAS
    local content as character
    local error := ""
    local logMessage as character
    local statusCode := 0
    local success := .T.

    content := httpGet(url + token)
    statusCode := httpGetStatus(@error)

    if !empty(content) .and. !empty(statusCode)
        if statusCode >= STATUS_SUCCESS .and. statusCode < STATUS_REDIRECTION
            self:result := content
        else
            logMessage := "Erro ao realizar download do XML no storage.
            logMessage += " Resposta: [" + content + "]"
            logMessage += " HttpStatus: [" + cValToChar(statusCode) + "]"
            logMessage += " Descricao: [" + error + "]"
            self:log(logMessage)
            success := .F.
        endif
    else
        self:log("Erro desconhecido ao realizar download do XML no AzureStorage")
        success := .F.
    endif

return success

method getResult() class PlHatCliAS
return self:result

method log(message, level) class PlHatCliAS
	if self:enableLog
        PlsPtuLog(AllTrim(Str(ThreadID())) + ";" + ; 
                  FWTimeStamp(5) + ";" + ;
                  message, ;
                  self:fileName)
    endif
return
