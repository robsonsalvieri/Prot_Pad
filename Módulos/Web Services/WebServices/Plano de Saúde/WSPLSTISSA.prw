#include "PROTHEUS.CH"
#include "ERROR.CH"
#include "XMLXFUN.CH"
#include "fileIO.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} tissLoteAnexo 
WebService Lote Anexo

@author  Lucas Nonato
@version P12
@since   21/10/2022
/*/
function tissLoteAnexo(cAuto)
local cSoap     := ""
local cXml      := HttpOtherContent()
local aRetObj   := {}
local cEnv      := GetEnvServer()
local cEmp      := AllTrim(GetPvProfString(cEnv,"JEMP","",GetADV97()))
local cFil      := AllTrim(GetPvProfString(cEnv,"JFIL","",GetADV97()))
local oTiss		:= nil

default cAuto 	:= ""

if !empty(cAuto)
    cXml := cAuto
endif

if empty(cXml)
    return ProcOnLine("protocoloRecebimentoAnexo")
endif

if !empty(cEmp) 
     
	RpcSetEnv( cEmp,cFil,,,cEnv,,) 
   
    HttpCtType( "text/xml; charset="+'UTF-8' )

	oTiss := PLSSvcLoteAnexo():new()
	oTiss:cVersao	:= Substr(cXml,At("Padrao>", cXml) + Len("Padrao>"),7)
     
	aRetObj := VldWSLoteG(cXml,"tissWebServicesV" + StrTran(oTiss:cVersao, ".", "_") + ".xsd",'LOTEANEXOWS' )
	 
	oTiss:lSuccess 	:= aRetObj[1]
	oTiss:cError   	:= aRetObj[2]
	oTiss:cXml    	:= aRetObj[3]
	oTiss:cNS     	:= aRetObj[4]
    
	// Se tudo ok, processa o arquivo	
	if oTiss:lSuccess
	
		cSoap += '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">' + Chr(10)
   		cSoap += '<s:Body>' + chr(10)
		cSoap += '<'+oTiss:cNS+':protocoloRecebimentoAnexoWS xmlns:'+oTiss:cNS+'="http://www.ans.gov.br/padroes/tiss/schemas">' + chr(10)
	
		cSoap += oTiss:processa() + chr(10)
		
		cSoap += '</'+oTiss:cNS+':protocoloRecebimentoAnexoWS>' + chr(10)
		cSoap += '</s:Body>' + chr(10)
		cSoap += '</s:Envelope>'
        
	else
		cSoap := "Erro ao carregar o Soap: " + oTiss:cError 
	endif  
else
    cSoap := "A ENVIRONMENT [" + cEnv + "] não tem declarada as variaveis cEmp e cFil." 
endif

return cSoap 