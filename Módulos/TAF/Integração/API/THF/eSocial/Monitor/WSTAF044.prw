#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFEsocialXMLMessage
@type			method
@description	Serviço para obter XML de um Evento do eSocial.
@author			Felipe C. Seolin
@since			06/10/2021
/*/
//---------------------------------------------------------------------
WSRESTFUL TAFEsocialXMLMessage DESCRIPTION "Consulta do XML de um Evento do eSocial" FORMAT APPLICATION_JSON

WSDATA companyId	AS STRING
WSDATA id			AS STRING

WSMETHOD GET;
	DESCRIPTION "Método para obter o XML de um Evento do eSocial";
	WSSYNTAX "api/rh/esocial/v1/TAFEsocialXMLMessage/?{companyId}&{id}";
	PATH "api/rh/esocial/v1/TAFEsocialXMLMessage/";
	TTALK "v1";
	PRODUCES APPLICATION_JSON

END WSRESTFUL

//---------------------------------------------------------------------
/*/{Protheus.doc} GET
@type			method
@description	Método para obter o XML de um Evento do eSocial
@author			Felipe C. Seolin
@since			06/10/2021
@return			lRet	-	Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD GET QUERYPARAM companyId, id WSRESTFUL TAFEsocialXMLMessage

Local oResponse		as object
Local cEmpRequest	as character
Local cFilRequest	as character
Local aCompany		as array
Local aResponse		as array
Local lRet			as logical

oResponse	:=	JsonObject():New()
cEmpRequest	:=	""
cFilRequest	:=	""
aCompany	:=	{}
aResponse	:=	{}
lRet		:=	.T.

If self:companyId == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
ElseIf self:id == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Identificador do Registro não informado no parâmetro 'id'." ) )
Else
	aCompany := StrTokArr( self:companyId, "|" )

	If Len( aCompany ) < 2
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
	Else
		cEmpRequest := aCompany[1]
		cFilRequest := aCompany[2]

		If PrepEnv( cEmpRequest, cFilRequest )
			If GetXML( self:id, @aResponse )
				oResponse["xmlType"]	:=	aResponse[2]
				oResponse["xmlMessage"]	:=	Encode64( aResponse[3] )

				self:SetResponse( oResponse:ToJson() )
			Else
				lRet := .F.
				SetRestFault( 400, EncodeUTF8( aResponse[1] ) )
			EndIf
		Else
			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "Falha na preparação do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + cFilRequest + "'." ) )
		EndIf
	EndIf
EndIf

oResponse := Nil
FreeObj( oResponse )
DelClassIntF()

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} GetXML
@type			function
@description	Realiza a busca do XML do Evento do eSocial.
@author			Felipe C. Seolin
@since			06/10/2021
@param			cID			-	Identificador do Registro contendo Filial|Evento|ID|Versão
@param			aResponse	-	Resposta contendo Mensagem de Erro, Evento e XML
/*/
//---------------------------------------------------------------------
Static Function GetXML( cID, aResponse )

Local cFilEvt	as character
Local cEvento	as character
Local cChave	as character
Local cAlias	as character
Local cFunction	as character
Local cXML		as character
Local nIndex	as numeric
Local aRotinas	as array
Local aKey		as array
Local lRet		as logical
Local cFilBkp	as character

cFilEvt		:=	""
cEvento		:=	""
cChave		:=	""
cAlias		:=	""
cFunction	:=	""
cXML		:=	""
cFilBkp		:=	cFilAnt
nIndex		:=	0
aRotinas	:=	{}
aKey		:=	{}
lRet		:=	.T.

aKey := StrTokArr( cID, "|" )

If Len( aKey ) >= 4
	cFilEvt := aKey[1]
	cFilAnt := cFilEvt
	cEvento := SubStr( aKey[2], 1, 1 ) + "-" + SubStr( aKey[2], 2 )
	cChave := aKey[3] + aKey[4]

	aRotinas := TAFRotinas( cEvento, 4, .F., 2 )

	If Len( aRotinas ) >= 8
		cAlias := aRotinas[3]
		cFunction := aRotinas[8]

		nIndex := TAFGetIDIndex( cAlias )

		DBSelectArea( cAlias )
		( cAlias )->( DBSetOrder( nIndex ) )
		If ( cAlias )->( MsSeek( xFilial( cAlias, cFilEvt ) + cChave ) )
			cXML := &cFunction.( cAlias, ( cAlias )->( Recno() ),, .T.,,, .F. )

			aAdd( aResponse, "" )
			aAdd( aResponse, cEvento )
			aAdd( aResponse, cXML )
		Else
			lRet := .F.
			aAdd( aResponse, "Registro '" + cChave + "' não localizado para busca do XML." )
		EndIf
	Else
		lRet := .F.
		aAdd( aResponse, "Evento '" + cEvento + "' não localizado no TAFRotinas." )
	EndIf

	cFilAnt := cFilBkp

Else
	lRet := .F.
	aAdd( aResponse, "Identificador do Registro '" + cID + "' não possui estrutura esperada com Filial|Evento|ID|Versão." )
EndIf

Return( lRet )
