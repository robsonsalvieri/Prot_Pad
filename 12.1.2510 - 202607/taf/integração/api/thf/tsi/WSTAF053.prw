#INCLUDE "RESTFUL.CH"
#INCLUDE "TOTVS.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} TSIUtilStamp
API TSILastStam - Retorna o stamp da V80
@author Renan Gomes
@since 21/07/2022
@version 1.0 
/*/
//------------------------------------------------------------------------------
WSRESTFUL TSIUtilStamp DESCRIPTION "API TSIUtilStamp - Realiza alterações na V80" FORMAT APPLICATION_JSON

WSDATA companyId  AS STRING
WSDATA branchCode AS STRING
WSDATA alias	  AS STRING
WSDATA dateStamp  AS STRING

WSMETHOD GET getLastStamp;
DESCRIPTION "Retorna o stamp do alias";
WSSYNTAX "/api/tsi/v1/TSIUtilStamp/getLastStamp/?{companyId}&{branchCode}&{alias}";
PATH "/api/tsi/v1/TSIUtilStamp/getLastStamp/";
TTALK "v1";

WSMETHOD POST updateStamp;
DESCRIPTION "Retorna todas as filiais do grupo de empresa logada";
WSSYNTAX "/api/tsi/v1/TSIUtilStamp/updateStamp/?{companyId}&{branchCode}&{alias}&{dateStamp}";
PATH "/api/tsi/v1/TSIUtilStamp/updateStamp/";
TTALK "v1";

END WSRESTFUL

//---------------------------------------------------------------------
/*/{Protheus.doc} GET
@type			method
@description	Retorna o stamp da V80 de acordo com o alias e companyId
@author			Renan Gomes
@since			21/07/2022
@return			lRet - Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD GET getLastStamp QUERYPARAM companyId,branchCode,alias WSRESTFUL TSIUtilStamp

Local lRet 			   as logical
Local nCodeError       as numeric
Local cMessage         as character
Local cDetailedMessage as character
Local aCompany		   as array
Local oResponse        as object
Local cEmpRequest	   as character
Local cFilRequest	   as character
Local lSubtrai         as logical
Local lCompiled        as logical

lRet 			 := .T.
nCodeError       := 404
cMessage         := EncodeUTF8("Empresa|Filial não informado no parâmetro 'companyId' ." )
cDetailedMessage := EncodeUTF8("Verifique o parâmetro 'companyId' enviado na requisição.")
aCompany		 := {}
oResponse        := JsonObject():New()
cEmpRequest	     := ""
cFilRequest	     := ""
lSubtrai		 := .F. //Pega o stamp completo sem subtrair segundos

self:SetContentType( "application/json" )

if Valtype(self:Getheader("Content-Advpr")) == 'U'
	lCompiled := .T.
else
	lCompiled := iif(self:Getheader("Content-Advpr")=='false',.F.,.T.)
endif

If self:companyId == Nil
	lRet := .F.
	SetRestFault(nCodeError,EncodeUTF8("Empresa|Filial não informado no parâmetro 'companyId' ." ),.T.,,EncodeUTF8("Verifique o parâmetro 'companyId' enviado na requisição."))
elseIf self:branchCode == Nil
	lRet := .F.
	SetRestFault(nCodeError,EncodeUTF8("Filial não informado no parâmetro 'branchCode' ." ),.T.,,EncodeUTF8("Verifique o parâmetro 'branchCode' enviado na requisição."))
elseIf self:alias == Nil .Or. Empty(self:alias)
	lRet := .F.
	SetRestFault(nCodeError,EncodeUTF8("Tabela não informada no parâmetro 'alias' ." ),.T.,,EncodeUTF8("Verifique o parâmetro 'alias' enviado na requisição."))
elseIf !( FindFunction("TsiAtuStamp") .And. FindFunction("TsiUltStamp") .And. FindFunction("TsiCompStamp") .And. lCompiled )
	lRet := .F.
	SetRestFault(404,EncodeUTF8("Função Indisponível no repositório TsiAtuStamp, TsiUltStamp, TsiCompStamp" ),.T.,,EncodeUTF8("Atualizar com o último pacote disponível na seção de downloads."))
Else
	aCompany := StrTokArr( self:companyId, "|" )
	If Len( aCompany ) < 2
		lRet := .F.
		SetRestFault(nCodeError,EncodeUTF8("Empresa|Filial inválida informado no parâmetro 'companyId' ." ),.T.,,cDetailedMessage)
	Else
		cEmpRequest := aCompany[1]

		If Alltrim(self:branchCode) == 'Todas'
			cFilRequest := aCompany[2]
		Else
			cFilRequest := PADR(alltrim(self:branchCode),FWSizeFilial())
		EndIf

		If PrepEnv( cEmpRequest, cFilRequest )
			oResponse["alias"] 		:= self:alias
			oResponse["branchCode"] := self:branchCode
			oResponse["stamp"]      := TsiUltStamp(self:alias,lSubtrai,,,,self:branchCode)
			self:SetResponse(oResponse:toJSON())			
		Else
			lRet := .F.
			cMessage := EncodeUTF8( "Falha na preparação do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + alltrim(cFilRequest) + "'." )
			SetRestFault(nCodeError,cMessage,.T.,,cDetailedMessage)
		EndIf
	Endif
Endif

FreeObj( oResponse )
oResponse := Nil
DelClassIntF()

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} POST
@type			method
@description	Atualiza o stamp da V80 de acordo com o alias e companyId
@author			Renan Gomes
@since			21/07/2022
@return			lRet - Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD POST updateStamp QUERYPARAM companyId,branchCode,alias,dateStamp WSRESTFUL TSIUtilStamp

Local lRet 			   as logical
Local nCodeError       as numeric
Local cMessage         as character
Local cDetailedMessage as character
Local aCompany		   as array
Local oResponse        as object
Local cEmpRequest	   as character
Local cFilRequest	   as character
Local cUltStamp		   as character
Local cStampAtu	       as character
Local lCompiled          as logical
lRet 			 := .T.
nCodeError       := 404
cMessage         := EncodeUTF8("Empresa|Filial não informado no parâmetro 'companyId' ." )
cDetailedMessage := EncodeUTF8("Verifique o parâmetro 'companyId' enviado na requisição.")
aCompany		 := {}
oResponse        := JsonObject():New()
cEmpRequest	     := ""
cFilRequest	     := ""
cUltStamp		 := ""
cStampAtu		 := ""

self:SetContentType( "application/json" )

if Valtype(self:Getheader("Content-Advpr")) == 'U'
	lCompiled := .T.
else
	lCompiled := iif(self:Getheader("Content-Advpr")=='false',.F.,.T.)
endif

If self:companyId == Nil
	lRet := .F.
	SetRestFault(404,EncodeUTF8("Empresa|Filial não informado no parâmetro 'companyId' ." ),.T.,,EncodeUTF8("Verifique o parâmetro 'companyId' enviado na requisição."))
elseIf self:branchCode == Nil
	lRet := .F.
	SetRestFault(404,EncodeUTF8("Filial não informado no parâmetro 'branchCode' ." ),.T.,,EncodeUTF8("Verifique o parâmetro 'branchCode' enviado na requisição."))
elseIf self:alias == Nil .Or. Empty( self:alias )
	lRet := .F.
	SetRestFault(404,EncodeUTF8("Tabela não informada no parâmetro 'alias' ." ),.T.,,EncodeUTF8("Verifique o parâmetro 'alias' enviado na requisição."))
elseIf !(FindFunction("TsiAtuStamp") .And. FindFunction("TsiUltStamp") .And. FindFunction("TsiCompStamp") .And. lCompiled)
	lRet := .F.
	SetRestFault(404,EncodeUTF8("Função Indisponível no repositório TsiAtuStamp, TsiUltStamp, TsiCompStamp" ),.T.,,EncodeUTF8("Atualizar com o último pacote disponível na seção de downloads."))
elseIf self:dateStamp == Nil .Or. Empty( self:dateStamp )
	lRet := .F.
	SetRestFault(404,EncodeUTF8("Data não informada no parâmetro 'dateStamp' ." ),.T.,,EncodeUTF8("Verifique o parâmetro 'dateStamp' enviado na requisição."))
Else
	aCompany := StrTokArr( self:companyId, "|" )
	If Len( aCompany ) < 2
		lRet := .F.
		SetRestFault(nCodeError,EncodeUTF8("Empresa|Filial inválida informado no parâmetro 'companyId' ." ),.T.,,cDetailedMessage)
	Else
		cEmpRequest := aCompany[1]

		If Alltrim(self:branchCode) == 'Todas'
			cFilRequest := aCompany[2]
		Else
			cFilRequest := PADR(alltrim(self:branchCode),FWSizeFilial())
		EndIf

		If PrepEnv( cEmpRequest, cFilRequest )
			cUltStamp := TsiFmtDate(self:dateStamp) + ' 00:00:00.000'
			cStampAtu := TsiUltStamp(self:alias,,,,,self:branchCode)
			if TsiCompStamp(cUltStamp,cStampAtu) //Se stamp novo for maior que stamp da V80, atualizo
				TSIAtuStamp(self:alias, cUltStamp,, self:branchCode)
				oResponse["sucess"]  := .T.
				oResponse["message"] :=  EncodeUTF8('Data de integração atualizada com sucesso para as notas fiscais')
			else
				oResponse["sucess"]  := .F.
				oResponse["message"] :=  EncodeUTF8('Data informada é menor que a data atual para o alias '+self:alias+'. Favor escolher uma data maior que '+cStampAtu)
			endif
			self:SetResponse(oResponse:toJSON())			
		Else
			lRet := .F.
			cMessage := EncodeUTF8( "Falha na preparação do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + alltrim(cFilRequest) + "'." )
			SetRestFault(nCodeError,cMessage,.T.,,cDetailedMessage)
		EndIf
	Endif
Endif
FreeObj( oResponse )
oResponse := Nil
DelClassIntF()
Return( lRet )
