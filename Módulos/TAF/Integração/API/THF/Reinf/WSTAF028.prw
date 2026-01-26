#INCLUDE "TOTVS.CH" 
#INCLUDE "RESTFUL.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} ReinfEvents
@type			method
@description	Serviço para obter a lista de eventos da Reinf.
@author			Leticia Campos da Silva
@since			17/09/2020
/*/
//---------------------------------------------------------------------
WSRESTFUL ReinfEvents DESCRIPTION "Consulta da lista de eventos da Reinf" FORMAT APPLICATION_JSON

WSDATA companyId AS STRING
WSDATA groupType AS INTEGER

WSMETHOD GET;
	DESCRIPTION "Método para obter a lista de eventos da Reinf";
	WSSYNTAX "api/taf/reinf/v1/reinfEvents/?{companyId}";
	PATH "api/taf/reinf/v1/reinfEvents/";
	TTALK "v1";
	PRODUCES APPLICATION_JSON

END WSRESTFUL

//---------------------------------------------------------------------
/*/{Protheus.doc} GET
@type			method
@description	Método para obter a lista de eventos da Reinf.
@author			Leticia Campos da Silva
@since			17/09/2020
@return			lRet - Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD GET QUERYPARAM companyId, groupType WSRESTFUL ReinfEvents

Local aEvents		as array
Local aCompany		as array
Local cEmpRequest	as character
Local cFilRequest	as character
Local lRet			as logical
Local oResponse		as object

aEvents		:=	{}
aCompany	:=	{}
cEmpRequest	:=	""
cFilRequest	:=	""
lRet		:=	.T.
oResponse	:=	JsonObject():New()

self:SetContentType( "application/json" )

If self:companyId == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
elseif self:groupType == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Tipo do Grupo não informado no parâmetro 'groupType'." ) )
Else
	aCompany := StrTokArr( self:companyId, "|" )

	If Len( aCompany ) < 2
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
	Else
		cEmpRequest := aCompany[1]
		cFilRequest := aCompany[2]

		If PrepEnv( cEmpRequest, cFilRequest )
			aEvents := EventsReinf( cValToChar(self:groupType) )

			lRet := .T.
			oResponse["eventsReinf"] := aEvents[1]
			oResponse["readyBloc40"] := aEvents[2]
			self:SetResponse( oResponse:ToJson() )
		Else
			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "Falha na preparação do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + cFilRequest + "'." ) )
		EndIf
	EndIf
EndIf

FreeObj( oResponse )
oResponse := Nil
DelClassIntF()

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} EventsReinf
@type			function
@description	Retorna o array com os eventos da Reinf para exibir na lista do Painel Reinf
@author			Karen Honda
@since			30/03/2021
@return			aRet - Lista de eventos da Reinf
/*/
//---------------------------------------------------------------------
Static Function EventsReinf( cTypeGroup as character ) as array

Local aRet				as array
Local lReinf20			as logical
Local cEvtTot			as character
Local cEvtTotContrib	as character

cEvtTot			:=  GetTotalizerEventCode("evtTot")
cEvtTotContrib	:=	GetTotalizerEventCode("evtTotContrib")

Default cTypeGroup := "1" //1=Todos;2=Bloco20;3-Bloco40

aRet := {}

//evento comum em qualquer uma das opcoes 1=Todos;2=Bloco20;3-Bloco40
aAdd( aRet, "R-1000" )
aAdd( aRet, "R-1070" )
aAdd( aRet, "R-9000" )

//verifico nesse ponto, pois ja passou no PrepEnv
lReinf20 := TAFAlsInDic("V5C") .And. TAFAlsInDic("V4Q") .And. TAFAlsInDic("V4N") .And. TAFAlsInDic("V3W");
			.And. TAFAlsInDic("V3U") .And. TAFAlsInDic("V3X")  .And. TAFAlsInDic("V4F") .And. TAFAlsInDic("V3Z") .And. TAFAlsInDic("V4K") .And. TAFAlsInDic("V4A") .And. TAFAlsInDic("V4B");
			.And. AllTrim( StrTran( SuperGetMV( "MV_TAFVLRE", .F., "" ), "_", "" ) ) >= "20100"

if cTypeGroup $ ("12") //1=Todos;2=Bloco20
	aAdd( aRet, "R-2010" 		)
	aAdd( aRet, "R-2020" 		)
	aAdd( aRet, "R-2030" 		)
	aAdd( aRet, "R-2040" 		)
	aAdd( aRet, "R-2050" 		)
	aAdd( aRet, "R-2060" 		)
	aAdd( aRet, "R-3010" 		)
	aAdd( aRet, "R-2055" 		)
	aAdd( aRet, cEvtTot 		)
	aAdd( aRet, cEvtTotContrib 	)

endif

if cTypeGroup $ ("13") //1=Todos;3-Bloco40
	if lReinf20
		aAdd( aRet, "R-1050" )
		aAdd( aRet, "R-4010" )
		aAdd( aRet, "R-4020" )
		aAdd( aRet, "R-4040" )
		aAdd( aRet, "R-4080" )
		aAdd( aRet, "R-9005" )
		aAdd( aRet, "R-9015" )
	endif
endif

aSort( aRet )

Return({ aRet, lReinf20 })
