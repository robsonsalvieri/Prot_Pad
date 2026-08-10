#Include 'Protheus.ch'
#Include 'Parmtype.ch'
#INCLUDE "TOTVS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JoAuth2IManage
Classe responável por realizar a autenticação com Auth 2.0 para o iManage

@author Rebeca Facchinato Asunção
@since 06/09/2023
/*/
//-------------------------------------------------------------------
Class JoAuth2IManage From FWoAuth2Client
	Data aScopes as array

	Method New() constructor
	Method Destroy()
	Method SetScopes()
	Method SetAuthData()

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da classe oAuth2 para iManage

@param cConsumer - Indica o app key cadastrado no iManage
@param cSecret   - Indica o app secret cadastrado no iManage
@author Rebeca Facchinato Asunção
@since 06/09/2023
/*/
//-------------------------------------------------------------------
Method New(cConsumer, cSecret) Class JoAuth2IManage
Local cAuth_uri as character
Local cToken_uri as character
Local oURL as object
Local cServerImg := AllTrim(SuperGetMV('MV_JGEDSER',,''))  // Server do worksite
Local cTpClient  := AllTrim(SuperGetMV('MV_JIMNGTP',,'1'))  // Tipo de autenticação do iManage (Client Type) 1=Pública / 2=Confidencial
Local lType      := cTpClient == "1"

	cAuth_uri  := "https://" + cServerImg + "/auth/oauth2/authorize"
	cToken_uri := "https://" + cServerImg + "/auth/oauth2/token"
	oURL       := FwoAuth2Url():New(cAuth_uri, cToken_uri)

	_Super:New(cConsumer, cSecret, oURL)

	::SetGrantInUrl(.T.)
	::SetAuthInHeader(lType)
	::SetScopes({"user"})
	::SetQueryAuthorization()

Return self

//-------------------------------------------------------------------
/*/{Protheus.doc} Destroy
Destrói o objeto da classe

@author Rebeca Facchinato Asunção
@since 06/09/2023
/*/
//-------------------------------------------------------------------
Method Destroy() Class JoAuth2IManage
	::aScopes := aSize(::aScopes, 0)
Return _Super:Destroy()

//-------------------------------------------------------------------
/*/{Protheus.doc} SetScopes
Seta variáveis de escopo

@author Rebeca Facchinato Asunção
@since 06/09/2023
/*/
//-------------------------------------------------------------------
Method SetScopes(aScopes) Class JoAuth2IManage
Local cScope as character
Local nI as numeric

Default aScopes := {}

	::aScopes := aScopes
	
	For nI := 1 To Len(aScopes)
		If nI == 1
			cScope := "scope="+aScopes[nI]
		Else
			cScope += "," + aScopes[nI]
		EndIf
	Next nI

	::SetAuthOptions(cScope)

Return Len(aScopes) > 0
