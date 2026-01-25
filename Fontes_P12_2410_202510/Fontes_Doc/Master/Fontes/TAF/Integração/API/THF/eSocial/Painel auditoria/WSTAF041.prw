#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} EsocialAudit
@type			method
@description	Serviço do Painel de Auditoria do eSocial.
@author			Alexandre de Lima Santos
@since			03/08/2021
/*/
//---------------------------------------------------------------------
WSRESTFUL EsocialAudit DESCRIPTION "Serviço do Painel de Auditoria do eSocial" FORMAT APPLICATION_JSON

	WSDATA companyId	AS STRING
	WSDATA branches		AS STRING
	WSDATA period		AS STRING
	WSDATA eventCodes	AS STRING
	WSDATA status		AS STRING OPTIONAL
	WSDATA deadline		AS STRING
	WSDATA periodFrom	AS STRING
	WSDATA periodTo		AS STRING
	WSDATA requestId	AS STRING
	WSDATA page			AS INTEGER OPTIONAL
	WSDATA pageSize		AS INTEGER OPTIONAL

	WSMETHOD POST;
		DESCRIPTION "Método para iniciar o processamento do Painel de Auditoria do eSocial";
		WSSYNTAX "api/rh/esocial/v1/EsocialAudit/?{companyId}&{branches}&{period}&{eventCodes}&{status}&{deadline}&{periodFrom}&{periodTo}&{page}&{pageSize}";
		PATH "api/rh/esocial/v1/EsocialAudit/";
		TTALK "V1";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET status;
		DESCRIPTION "Método para consultar o percentual de execução do Painel de Auditoria do eSocial";
		WSSYNTAX "api/rh/esocial/v1/EsocialAudit/status/?{companyId}&{requestId}";
		PATH "api/rh/esocial/v1/EsocialAudit/status/";
		TTALK "v1";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET auditValues;
		DESCRIPTION "Método para consultar o resultado do Painel de Auditoria do eSocial";
		WSSYNTAX "api/rh/esocial/v1/EsocialAudit/auditValues?{companyId}&{requestId}&{status}&{page}&{pageSize}";
		PATH "api/rh/esocial/v1/EsocialAudit/auditValues";
		TTALK "v1";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET chartValues;
		DESCRIPTION "Método para consultar informações do gráfico do Painel de Auditoria do eSocial";
		WSSYNTAX "api/rh/esocial/v1/EsocialAudit/chartValues?{companyId}&{requestId}";
		PATH "api/rh/esocial/v1/EsocialAudit/chartValues";
		TTALK "v1";
		PRODUCES APPLICATION_JSON

END WSRESTFUL

//---------------------------------------------------------------------
/*/{Protheus.doc} POST
@type			method
@description	Método para iniciar o processamento do Painel de Auditoria do eSocial.
@author			Alexandre de Lima Santos
@since			03/08/2021
@return			lRet	-	Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD POST WSRESTFUL EsocialAudit

	Local oRequest		as object
	Local oResponse		as object
	Local cEmpRequest	as character
	Local cFilRequest	as character
	Local cRequestID	as character
	Local aCompany		as array
	Local lRet			as logical

	oRequest	:=	Nil
	oResponse	:=	Nil
	cEmpRequest	:=	""
	cFilRequest	:=	""
	cRequestID	:=	""
	aCompany	:=	{}
	lRet		:=	.T.

	If Empty( self:GetContent() )
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Corpo da requisição não enviado." ) )
	Else
		oRequest := JsonObject():New()
		oRequest:FromJson( self:GetContent() )

		If Empty( oRequest["companyId"] )
			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
		ElseIf Empty( oRequest["branches"] )
			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "Filiais não informado no parâmetro 'branches'." ) )
		ElseIf Empty( oRequest["period"] )
			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "Período não informado no parâmetro 'period'." ) )
		ElseIf Empty( oRequest["eventCodes"] )
			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "Eventos não informado no parâmetro 'eventCodes'." ) )
		ElseIf Empty( oRequest["status"] )
			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "Status de Transmissão não informado no parâmetro 'status'." ) )
		ElseIf Empty( oRequest["deadline"] )
			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "Status de Prazo não informado no parâmetro 'deadline'." ) )
		ElseIf Empty( oRequest["periodFrom"] )
			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "Data De não informado no parâmetro 'periodFrom'." ) )
		ElseIf Empty( oRequest["periodTo"] )
			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "Data Até não informado no parâmetro 'periodTo'." ) )
		Else
			aCompany := StrTokArr( oRequest["companyId"], "|" )

			If Len( aCompany ) < 2
				lRet := .F.
				SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
			Else
				cEmpRequest := aCompany[1]
				cFilRequest := aCompany[2]

				If PrepEnv( cEmpRequest, cFilRequest )
					cRequestID := CreateTicket( self:GetContent() )

					If Empty( cRequestID )
						lRet := .F.
						SetRestFault( 400, EncodeUTF8( "Não foi possível gerar o ticket de processamento no Protheus." ) )
					Else
						//Inicia o processamento, antes de devolver o ticket da requisição
						StartJob( "WS041EXEC", GetEnvServer(), .F., cEmpRequest, cFilRequest, cRequestID )

						oResponse := JsonObject():New()
						oResponse["requestId"] := cRequestID

						//Envia o ticket da requisição para o frontend
						self:SetResponse( oResponse:ToJson() )
					EndIf
				Else
					lRet := .F.
					SetRestFault( 400, EncodeUTF8( "Falha na preparação do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + cFilRequest + "'." ) )
				EndIf
			EndIf		
		EndIf
	EndIf

	FreeObj( oRequest )
	FreeObj( oResponse )

	oRequest := Nil
	oResponse := Nil

	DelClassIntF()

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} CreateTicket
@type			function
@description	Cria e armazena o ticket para a requisição.
@author			Alexandre de Lima Santos
@since			17/08/2021
@param			cBody		-	Corpo da requisição com os parâmetros desejados
@return			cRequestID	-	Identificador da Requisição
/*/
//---------------------------------------------------------------------
Static Function CreateTicket( cBody as character )

	Local oModelV3J		as object
	Local cRequestID	as character

	oModelV3J	:=	FWLoadModel( "TAFA531" )
	cRequestID	:=	FWuuId( "WSTAF041" )

	APILogAccess("EsocialAudit")

	oModelV3J:SetOperation( MODEL_OPERATION_INSERT )
	oModelV3J:Activate()

	oModelV3J:LoadValue( "MODEL_V3J", "V3J_ID"		, cRequestID )
	oModelV3J:LoadValue( "MODEL_V3J", "V3J_SERVIC"	, "EsocialAudit/auditValues" )
	oModelV3J:LoadValue( "MODEL_V3J", "V3J_METODO"	, "POST" )
	oModelV3J:LoadValue( "MODEL_V3J", "V3J_DTREQ"	, Date() )
	oModelV3J:LoadValue( "MODEL_V3J", "V3J_HRREQ"	, StrTran( Time(), ":", "" ) )
	oModelV3J:LoadValue( "MODEL_V3J", "V3J_STATUS"	, "1" )
	oModelV3J:LoadValue( "MODEL_V3J", "V3J_PERC"	, 1   )
	oModelV3J:LoadValue( "MODEL_V3J", "V3J_PARAMS"	, cBody )

	FWFormCommit( oModelV3J )

	oModelV3J:DeActivate()
	oModelV3J:Destroy()

Return( cRequestID )

//---------------------------------------------------------------------
/*/{Protheus.doc} status
@type			method
@description	Método para consultar o percentual de execução do Painel de Auditoria do eSocial.
@author			Alexandre de Lima Santos
@since			03/08/2021
@return			lRet	-	Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD GET status QUERYPARAM companyId, requestId WSRESTFUL EsocialAudit

	Local oResponse		as object
	Local cEmpRequest	as character
	Local cFilRequest	as character
	Local cRequestID	as character
	Local aCompany		as array
	Local lRet			as logical

	oResponse	:=	Nil
	cEmpRequest	:=	""
	cFilRequest	:=	""
	cRequestID	:=	""
	aCompany	:=	{}
	lRet		:=	.T.

	If self:companyId == Nil
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
	ElseIf self:requestId == Nil
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Identificação da Requisição não informada no parâmetro 'requestId'." ) )
	Else
		aCompany := StrTokArr( self:companyId, "|" )

		If Len( aCompany ) < 2
			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
		Else
			cEmpRequest := aCompany[1]
			cFilRequest := aCompany[2]

			If PrepEnv( cEmpRequest, cFilRequest )
				If ValidID( self:requestId )
					cRequestID := self:requestId

					If GetStatus( @oResponse, cRequestID )
						self:SetResponse( oResponse:toJson() )
					Else
						lRet := .F.
						SetRestFault( 400, EncodeUTF8( "O progresso do processamento não foi localizado." ) )
					EndIf
				Else
					lRet := .F.
					SetRestFault( 400, EncodeUTF8( "A Identificação da Requisição '" + self:requestId + "' informado no parâmetro 'requestId' não existe." ) )
				EndIf
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
/*/{Protheus.doc} ValidID
@type			function
@description	Verifica se o Identificador da Requisição é válido.
@author			Alexandre de Lima Santos
@since			03/08/2021
@param			cRequestID	-	Identificador da Requisição
@return			lRet		-	Indica se o Identificador da Requisição é válido
/*/
//---------------------------------------------------------------------
Static Function ValidID( cRequestID as character )

	Local lRet	as logical

	lRet	:=	.F.

	DBSelectArea( "V3J" )
	V3J->( DBSetOrder( 1 ) )
	lRet := V3J->( MsSeek( xFilial( "V3J" ) + cRequestID ) )

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} GetStatus
@type			function
@description	Executa a consulta do percentual de execução do processamento.
@author			Alexandre de Lima Santos
@since			03/08/2021
@param			oResponse	-	Objeto Json com o retorno do progresso da requisição
@param			cRequestID	-	Identificador da requisição
@return			lRet		-	Indica se o progresso do processamento foi localizado
/*/
//---------------------------------------------------------------------
Static Function GetStatus( oResponse as object, cRequestID as character )

	Local lRet	as logical

	lRet	:=	.F.

	DBSelectArea( "V3J" )
	V3J->( DBSetOrder( 1 ) )
	If V3J->( DBSeek( xFilial( "V3J" ) + cRequestID ) )
		lRet := .T.

		oResponse := JsonObject():New()

		oResponse["finished"]	:=	Iif( V3J->V3J_STATUS == "1", .F., .T. )
		oResponse["percent"]	:=	V3J->V3J_PERC
	EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} auditValues
@type			method
@description	Método para consultar resultado do Painel de Auditoria do eSocial.
@author			Alexandre de Lima Santos
@since			03/08/2021
@return			lRet	-	Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD GET auditValues QUERYPARAM companyId, requestId, status, page, pageSize WSRESTFUL EsocialAudit

	Local oResponse		as object
	Local cEmpRequest	as character
	Local cFilRequest	as character
	Local cRequestID	as character
	Local cStatus		as character
	Local nPage			as numeric
	Local nPageSize		as numeric
	Local aCompany		as array
	Local lRet			as logical

	oResponse	:=	JsonObject():New()
	cEmpRequest	:=	""
	cFilRequest	:=	""
	cRequestID	:=	""
	cStatus		:=	"1','2','3','4"
	nPage		:=	1
	nPageSize	:=	15
	aCompany	:=	{}
	lRet		:=	.T.

	If self:companyId == Nil
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
	ElseIf self:requestId == Nil
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Identificação da Requisição não informada no parâmetro 'requestId'." ) )
	Else
		aCompany := StrTokArr( self:companyId, "|" )

		If Len( aCompany ) < 2
			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
		Else
			cEmpRequest := aCompany[1]
			cFilRequest := aCompany[2]

			If PrepEnv( cEmpRequest, cFilRequest )
				If ValidID( self:requestId )
					cRequestID := self:requestId

					If self:status <> Nil .and. self:status <> ""
						cStatus = self:status
					EndIf

					If self:page <> Nil
						nPage := self:page
					EndIf

					If self:pageSize <> Nil
						nPageSize := self:pageSize
					EndIf

					GetDetails( @oResponse, cRequestID, cStatus, nPage, nPageSize )

					self:SetResponse( oResponse:toJson() )
				Else
					lRet := .F.
					SetRestFault( 400, EncodeUTF8( "A Identificação da Requisição '" + self:requestId + "' informado no parâmetro 'requestId' não existe." ) )
				EndIf
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
/*/{Protheus.doc} GetDetails
@type			function
@description	Retorna os registros analíticos com controle de paginação.
@author			Alexandre de Lima Santos
@since			03/08/2021
@param			oResponse	-	Objeto Json com o retorno do resultado da requisição
@param			cRequestID	-	Identificador da Requisição
@param			cStatus		-	Status da Transmissão
@param			nPage		-	Identificador da página solicitada
@param			nPageSize	-	Identificador do total de registros por página
/*/
//---------------------------------------------------------------------
Static Function GetDetails( oResponse as object, cRequestID as character, cStatus as character, nPage as numeric, nPageSize as numeric )

	Local oJson		as object
	Local cAliasQry	as character
	Local cDatabase	as character
	Local nStartReg	as numeric
	Local nFinalReg	as numeric
	Local aJson		as array
	Local lHasNext	as logical

	oJson		:=	Nil
	cAliasQry	:=	GetNextAlias()
	cDatabase	:=	TCGetDB()
	nStartReg	:=	0
	nFinalReg	:=	0
	aJson		:=	{}
	lHasNext	:=	.F.

	Default nPage		:=	30
	Default nPageSize	:=	0

	nStartReg := Iif( cDatabase == "OPENEDGE", ( nPage - 1 ) * nPageSize, ( ( nPage - 1 ) * nPageSize ) + 1 )
	nFinalReg := nPage * nPageSize

	If cDatabase == "OPENEDGE"
		BeginSQL Alias cAliasQry
			SELECT V45.R_E_C_N_O_ V45_RECNO
			FROM %table:V45% V45
			WHERE V45.V45_FILIAL = %xFilial:V45%
			AND V45.V45_ID = %exp:cRequestID%
			AND V45.V45_TIPO IN ( %exp:cStatus% )
			AND V45.%notDel%
			ORDER BY V45.V45_RECNO
			OFFSET %exp:nStartReg% ROWS FETCH NEXT %exp:nFinalReg% ROWS ONLY
		EndSQL
	Else
		BeginSQL Alias cAliasQry
			SELECT *
			FROM (
				SELECT ROW_NUMBER() OVER( ORDER BY V45.R_E_C_N_O_ ) LINE_NUMBER, V45.R_E_C_N_O_ V45_RECNO
				FROM %table:V45% V45
				WHERE V45.V45_FILIAL = %xFilial:V45%
				AND V45.V45_ID = %exp:cRequestID%
				AND V45.V45_TIPO IN ( %exp:cStatus% )
				AND V45.%notDel%
			) TAB
			WHERE LINE_NUMBER BETWEEN %exp:nStartReg% AND %exp:nFinalReg%
		EndSQL
	EndIf

	( cAliasQry )->( DBGoTop() )

	While ( cAliasQry )->( !Eof() )
		V45->( DBGoTo( ( cAliasQry )->V45_RECNO ) )

		oJson := JsonObject():New()
		oJson:FromJson( V45->V45_RESP )

		aAdd( aJson, oJson )

		FreeObj( oJson )
		oJson := Nil

		( cAliasQry )->( DBSkip() )
	EndDo

	( cAliasQry )->( DBCloseArea() )

	lHasNext := HasNext( cRequestID, cStatus, nFinalReg )

	oResponse["items"]		:=	aJson
	oResponse["hasNext"]	:=	lHasNext

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} HasNext
@type			function
@description	Retorna se há uma nova página de acordo com os parâmetros informados.
@author			Alexandre de Lima Santos
@since			03/08/2021
@param			cRequestID	-	Identificador da Requisição
@param			cStatus		-	Status da Transmissão
@param			nFinalReg	-	Identificador do último registro a ser retornado
@return			lHasNext	-	Indica se há existência de mais registros além dos retornados
/*/
//---------------------------------------------------------------------
Static Function HasNext( cRequestID as character, cStatus as character, nFinalReg as numeric )

	Local cAliasQry	as character
	Local cDatabase	as character
	Local lHasNext	as logical

	cAliasQry	:=	GetNextAlias()
	cDatabase	:=	TCGetDB()
	lHasNext	:=	.F.

	If cDatabase == "OPENEDGE"
		BeginSQL Alias cAliasQry
			SELECT COUNT( * ) MAX_LINE
			FROM (
				SELECT V45.R_E_C_N_O_
				FROM %table:V45% V45
				WHERE V45.V45_FILIAL = %xFilial:V45%
				AND V45.V45_ID = %exp:cRequestID%
				AND V45.V45_TIPO IN ( %exp:cStatus% )
				AND V45.%notDel%
			) TAB
		EndSQL
	Else
		BeginSQL Alias cAliasQry
			SELECT MAX( LINE_NUMBER ) MAX_LINE
			FROM (
				SELECT ROW_NUMBER() OVER( ORDER BY V45.R_E_C_N_O_ ) LINE_NUMBER
				FROM %table:V45% V45
				WHERE V45.V45_FILIAL = %xFilial:V45%
				AND V45.V45_ID = %exp:cRequestID%
				AND V45.V45_TIPO IN ( %exp:cStatus% )
				AND V45.%notDel%
			) TAB
		EndSQL
	EndIf

	( cAliasQry )->( DBGoTop() )
	If ( cAliasQry )->( !Eof() )
		If ( cAliasQry )->MAX_LINE > nFinalReg
			lHasNext := .T.
		EndIf
	EndIf

	( cAliasQry )->( DBCloseArea() )

Return( lHasNext )

//---------------------------------------------------------------------
/*/{Protheus.doc} chartValues
@type			method
@description	Método para consultar resultado do gráfico do Painel de Auditoria do eSocial.
@author			Fabio Santos de Mendonca
@since			17/11/2021
@return			lRet	-	Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD GET chartValues QUERYPARAM companyId, requestId WSRESTFUL EsocialAudit

	Local oResponse		as object
	Local cEmpRequest	as character
	Local cFilRequest	as character
	Local cRequestID	as character
	Local aCompany		as array
	Local lRet			as logical

	oResponse	:=	JsonObject():New()
	cEmpRequest	:=	""
	cFilRequest	:=	""
	cRequestID	:=	""
	aCompany	:=	{}
	lRet		:=	.T.

	If self:companyId == Nil
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
	ElseIf self:requestId == Nil
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Identificação da Requisição não informada no parâmetro 'requestId'." ) )
	Else
		aCompany := StrTokArr( self:companyId, "|" )

		If Len( aCompany ) < 2
			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
		Else
			cEmpRequest := aCompany[1]
			cFilRequest := aCompany[2]

			If PrepEnv( cEmpRequest, cFilRequest )
				If ValidID( self:requestId )
					cRequestID := self:requestId

					GetChartValues( @oResponse, cRequestID )

					self:SetResponse( oResponse:toJson() )
				Else
					lRet := .F.
					SetRestFault( 400, EncodeUTF8( "A Identificação da Requisição '" + self:requestId + "' informado no parâmetro 'requestId' não existe." ) )
				EndIf
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
/*/{Protheus.doc} GetChartValues
@type			function
@description	Retorna os registros sintéticos.
@author			Fabio Santos de Mendonca
@since			17/11/2021
@param			oResponse	-	Objeto Json com o retorno do resultado da requisição
@param			cRequestID	-	Identificador da Requisição
/*/
//---------------------------------------------------------------------
Static Function GetChartValues( oResponse as object, cRequestID as character )

	Local cAliasQry	as character

	cAliasQry	:=	GetNextAlias()

	BeginSQL Alias cAliasQry
		SELECT (
			SELECT COUNT( * )
			FROM %table:V45% V45
			WHERE V45.V45_FILIAL = V3J.V3J_FILIAL
			AND V45.V45_ID = V3J.V3J_ID
			AND V45.V45_TIPO = '1'
			AND V45.%notDel%
		) TRANSM_PRAZO,
			(
			SELECT COUNT( * )
			FROM %table:V45% V45
			WHERE V45.V45_FILIAL = V3J.V3J_FILIAL
			AND V45.V45_ID = V3J.V3J_ID
			AND V45.V45_TIPO = '2'
			AND V45.%notDel%
		) TRANSM_FORAPRAZO,
			(
			SELECT COUNT( * )
			FROM %table:V45% V45
			WHERE V45.V45_FILIAL = V3J.V3J_FILIAL
			AND V45.V45_ID = V3J.V3J_ID
			AND V45.V45_TIPO = '3'
			AND V45.%notDel%
		) NAOTRANSM_PRAZO,
			(
			SELECT COUNT( * )
			FROM %table:V45% V45
			WHERE V45.V45_FILIAL = V3J.V3J_FILIAL
			AND V45.V45_ID = V3J.V3J_ID
			AND V45.V45_TIPO = '4'
			AND V45.%notDel%
		) NAOTRANSM_FORAPRAZO
		FROM %table:V3J% V3J
		WHERE V3J.V3J_FILIAL = %xFilial:V3J%
		AND V3J.V3J_ID = %exp:cRequestID%
		AND V3J.%notDel%
	EndSQL

	( cAliasQry )->( DBGoTop() )
	If ( cAliasQry )->( !Eof() )
		oResponse["transmInDeadline"]		:=	( cAliasQry )->( TRANSM_PRAZO )
		oResponse["transmOutDeadline"]		:=	( cAliasQry )->( TRANSM_FORAPRAZO )
		oResponse["notTransmInDeadline"]	:=	( cAliasQry )->( NAOTRANSM_PRAZO )
		oResponse["notTransmOutDeadline"]	:=	( cAliasQry )->( NAOTRANSM_FORAPRAZO )
	Else
		oResponse["transmInDeadline"]		:=	0
		oResponse["transmOutDeadline"]		:=	0
		oResponse["notTransmInDeadline"]	:=	0
		oResponse["notTransmOutDeadline"]	:=	0
	EndIf

	( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} WS041EXEC
@type			function
@description	Executa a busca e processamento dos dados para retorno da requisição.
@author			Alexandre de Lima Santos
@since			12/08/2021
@param			cEmpRequest	-	Empresa indicada no parâmetro companyId
@param			cFilRequest	-	Filial indicada no parâmetro companyId
@param			cRequestID	-	Identificador da Requisição
/*/
//---------------------------------------------------------------------
Function WS041EXEC( cEmpRequest as character, cFilRequest as character, cRequestID as character )

	Local oRequest		as object
	Local oResponse		as object
	Local cAliasQry		as character
	Local cQuery		as character
	Local cObriEvt		as character
	Local cPeriodAux	as character
	Local cPeriod		as character
	Local cStatus		as character
	Local cDeadline		as character
	Local cPeriodFrom	as character
	Local cPeriodTo		as character
	Local cBranch		as character
	Local cEventCode	as character
	Local cEventID		as character
	Local cAlias		as character
	Local cMainField	as character
	Local cFilter		as character
	Local cHeader		as character
	Local cDate1200		as character
	Local cV70Item		as character
	Local cV71Item		as character
	Local cJoin			as character
	Local cTableJoin	as character
	Local cBancoDB      as character 
	Local nI			as numeric
	Local nJ			as numeric
	Local nK			as numeric
	Local nL			as numeric
	Local nTotal		as numeric
	Local nSeq			as numeric
	Local aBranches		as array
	Local aEventCodes	as array
	Local aV70			as array
	Local aV71			as array
	Local aResult		as array
	Local aResponse		as array
	Local lJoin			as logical
	

	oRequest	:=	Nil
	oResponse	:=	Nil
	cAliasQry	:=	""
	cQuery		:=	""
	cObriEvt	:=	"" //avaliar
	cPeriodAux	:=	""
	cPeriod		:=	""
	cStatus		:=	""
	cDeadline	:=	"" 
	cPeriodFrom	:=	""
	cPeriodTo	:=	""
	cBranch		:=	""
	cEventCode	:=	""
	cEventID	:=	""
	cAlias		:=	""
	cMainField	:=	""
	cFilter		:=	""
	cHeader		:=	""
	cDate1200	:=	""
	cV70Item	:=	""
	cV71Item	:=	""
	cJoin		:=	""
	cTableJoin	:=	""
	nI			:=	0
	nJ			:=	0
	nK			:=	0
	nL			:=	0
	nTotal		:=	0
	nSeq		:=	0
	aBranches	:=	{}
	aEventCodes	:=	{}
	aV70		:=	{}
	aV71		:=	{}
	aResult		:=	{}
	aResponse	:=	{}
	lJoin		:=	.F.

	RPCSetType( 3 )
	RPCSetEnv( cEmpRequest, cFilRequest,,, "TAF", "WSTAF041" )

	cBancoDB    :=  TCGetDB()

	DBSelectArea( "V3J" )
	V3J->( DBSetOrder( 1 ) )
	If V3J->( MsSeek( xFilial( "V3J" ) + PadR( cRequestID, TamSX3( "V3J_ID" )[1] ) ) )
		cObriEvt := SuperGetMV( "MV_TAFININ",, "" )

		oRequest := JsonObject():New()
		oRequest:FromJson( V3J->V3J_PARAMS )

		aBranches	:=	oRequest["branches"]
		cPeriodAux	:=	oRequest["period"]
		cPeriod		:=	oRequest["period"]//avaliar - pq duas variáveis recebem period
		aEventCodes	:=	oRequest["eventCodes"]
		cStatus		:=	oRequest["status"]
		cDeadline	:=	oRequest["deadline"]
		cPeriodFrom	:=	oRequest["periodFrom"]
		cPeriodTo	:=	oRequest["periodTo"]

		DBSelectArea( "V6Z" )
		V6Z->( DBSetOrder( 2 ) )

		For nI := 1 to Len( aBranches )
			For nJ := 1 to Len( aEventCodes )
				cBranch		:=	aBranches[nI]
				cEventCode	:=	aEventCodes[nJ]

				If V6Z->( MsSeek( xFilial( "V6Z" ) + cEventCode ) )
					cEventID := V6Z->V6Z_ID
				Else
					cEventID := ""
				EndIf

				aV70 := InfoV70( cEventID )
				aV71 := InfoV71( cEventID )

				lJoin := Len( aV71 ) > 0

				For nK := 1 to Len( aV70 )
					cAlias		:=	aV70[nK,6]
					cMainField	:=	aV70[nK,7]
					cFilter		:=	aV70[nK,8]
					cPeriod		:=	AnoMes( SToD( cPeriodAux ) )
					cHeader		:=	GetHeader( cEventCode, Iif(cEventCode == "S-2200", "C9V", cAlias), cMainField )
					
					If !SkipRule( cEventCode, aV70[nK,1], cPeriodAux )
					
						If Len( aV71 ) > 0
							lJoin := .F.

							For nL := 1 to Len( aV71 )
								cAliasQry	:=	GetNextAlias()
								cQuery := ""
								cQuery := "SELECT " + cHeader
								cQuery += "FROM " + RetSqlName( cAlias ) + " " + cAlias + " "

								cV70Item := aV71[nL,1]
								cV71Item := aV71[nL,2]

								If aV70[nK,1] == aV71[nL,1] .and. !SkipRule( cEventCode, aV70[nK,1], cPeriodAux, cV70Item, cV71Item )
									cJoin		:=	aV71[nL,3]
									cTableJoin	:=	aV71[nL,4]

									If cEventCode == "S-2200" .and. Alltrim( aV70[nK,1] ) $ "001|002|004|005"
										cQuery += "INNER JOIN " + RetSqlName( "C9V" ) + " C9V "
										cQuery += "   ON C9V.C9V_FILIAL = CUP_FILIAL "
										cQuery += "  AND C9V.C9V_ID = CUP_ID "
										cQuery += "  AND C9V.C9V_VERSAO = CUP_VERSAO "
										cQuery += "  AND C9V.C9V_ATIVO = '1' "
										cQuery += "  AND C9V.D_E_L_E_T_ = '' "

										If Alltrim ( aV70[nK,1] ) == "001"
											cQuery += "WHERE CUP.CUP_DTADMI BETWEEN '" + cPeriodFrom + "' AND '" + cPeriodTo + "' "
											cQuery += "  AND CUP.CUP_INSANT = '' "
											cQuery += "  AND CUP.CUP_DTEXER = '' "
											cQuery += "  AND CUP.CUP_DTADMI <= '" + DtoS( LastDate( MonthSub( SToD( cObriEvt ), 1 ) ) ) + "' "
										ElseIf Alltrim( aV70[nK,1] )== "002"
											cQuery += "WHERE CUP.CUP_DTADMI BETWEEN '" + cPeriodFrom + "' AND '" + cPeriodTo + "' "
											cQuery += "  AND CUP.CUP_INSANT = '' "
											cQuery += "  AND CUP.CUP_DTEXER = '' "
											cQuery += "  AND CUP.CUP_DTADMI >= '" + DToS( DaySum( SToD( cObriEvt ), 1 ) ) + "' "
										ElseIf ( Alltrim( aV70[nK,1] ) == "004" .AND. Alltrim( aV71[nL,2] ) == "002" )
											cQuery += "WHERE CUP.CUP_DTADMI BETWEEN '" + cPeriodFrom + "' AND '" + cPeriodTo + "' "
											cQuery += "  AND CUP.CUP_INSANT = '' "
											cQuery += "  AND CUP.CUP_DTEXER = '' "
											cQuery += "  AND EXISTS (	SELECT T3A.T3A_CPF "
											cQuery += "					FROM " + RetSqlName( "T3A" ) + " T3A "
											cQuery += "					WHERE T3A.T3A_CPF = C9V.C9V_CPF "
											cQuery += "					  AND T3A.D_E_L_E_T_ = '' ) "
										ElseIf Alltrim( aV70[nK,1] ) == "005"
											cQuery += "WHERE CUP.CUP_DTADMI BETWEEN '" + cPeriodFrom + "' AND '" + cPeriodTo + "' "
											cQuery += "  AND CUP.CUP_INSANT = '' "
											cQuery += "  AND CUP.CUP_DTEXER = '' "
											cQuery += "  AND CUP.CUP_DTADMI = '" + cObriEvt + "' "
										EndIf

										If aV70[nK,1] <> "004"
											cQuery += "  AND NOT EXISTS (	SELECT T3A.T3A_CPF "
											cQuery += "						FROM " + RetSqlName( "T3A" ) + " T3A "
											cQuery += "						WHERE T3A.T3A_CPF = C9V.C9V_CPF "
											cQuery += "						  AND T3A.D_E_L_E_T_ = '' ) "
										Endif
									ElseIf cEventCode == "S-2300"
										If aV70[nK,1] == "001"
											cQuery += "WHERE C9V.C9V_FILIAL = '" + cBranch + "' "
											cQuery += "  AND C9V.C9V_DTINIV BETWEEN '" + cPeriodFrom + "' AND '" + cPeriodTo + "' "
											cQuery += "  AND C9V.C9V_DTINIV >= '" + cObriEvt + "' "
											cQuery += "  AND C9V.C9V_NOMEVE = 'S2300' "
											cQuery += "  AND C9V.C9V_ATIVO = '1' "
											cQuery += "  AND C9V.D_E_L_E_T_ = '' "
										ElseIf aV70[nK,1] == "002"
											cQuery += "WHERE C9V.C9V_FILIAL = '" + cBranch + "' "
											cQuery += "  AND C9V.C9V_DTINIV BETWEEN '" + cPeriodFrom + "' AND '" + cPeriodTo + "' "
											cQuery += "  AND C9V.C9V_DTINIV < '" + cObriEvt + "' "
											cQuery += "  AND C9V.C9V_NOMEVE = 'S2300' "
											cQuery += "  AND C9V.C9V_ATIVO = '1' "
											cQuery += "  AND C9V.D_E_L_E_T_ = '' "
										EndIf
									ElseIf cEventCode == "S-2190"
										If aV70[nK,1] == "002"
											cQuery += "WHERE T3A.T3A_FILIAL = '" + cBranch + "' "
											cQuery += "  AND T3A.T3A_DTADMI BETWEEN '" + cPeriodFrom + "' AND '" + cPeriodTo + "' "
											cQuery += "  AND T3A.T3A_DTADMI <= '" + cObriEvt + "' "
											cQuery += "  AND T3A.T3A_ATIVO = '1' "
											cQuery += "  AND T3A.D_E_L_E_T_ = '' "
										EndIf	
							
									Else

										If cEventCode == "S-1260"
											cQuery += "INNER JOIN " + RetSqlName( "C92" ) + " C92 "
											cQuery += "   ON C92_ID = T1M_IDESTA "
										EndIf
										
										cQuery += "INNER JOIN " + RetSqlName( cTableJoin ) + " " + cTableJoin + " "
										cQuery += "   ON " + cJoin + " "
										cQuery += "WHERE " + cAlias + "." + cAlias + "_FILIAL = '" + cBranch + "' "

										If cEventCode $ "S-1200|S-1260" .And. Alltrim( aV71[nL,4] ) == "C1E"

											cQuery += "  AND " + cAlias + "." + cMainField + " = '" + cPeriodAux + "' 
											cQuery += "  AND " + cFilter

										Else

											cQuery += "  AND " + cAlias + "." + cMainField + " BETWEEN '" + cPeriodFrom + "' AND '" + cPeriodTo + "' "
											cQuery += "  AND " + cFilter

										EndIf

									EndIf				

									If cEventCode == "S-2300"
										cQuery += "  AND C9V.C9V_DTTRAN = '' "
									EndIf

									If cEventCode == "S-2200"
										cQuery += "  AND C9V.C9V_DTTRAN = '' "
										cQuery += "  AND C9V.C9V_FILIAL = '" + cBranch + "' "
										cQuery += "  AND C9V.C9V_STATUS IN ( " + StatusIN( cStatus ) + " ) "
									Else
										cQuery += "  AND " + cAlias + "." + cAlias + "_FILIAL = '" + cBranch + "' "
										cQuery += "  AND " + cAlias + "." + cAlias + "_STATUS IN ( " + StatusIN( cStatus ) + " ) "
									EndIf

									cQuery := ChangeQuery( cQuery )

									TCQuery cQuery New Alias (cAliasQry)

									( cAliasQry )->( DBGoTop() )
									While ( cAliasQry )->( !Eof() )
										aResult := GetData( cAliasQry, aV70[nK], cPeriodAux, cEventCode, cBranch, cAlias, cObriEvt )

										AddResponse( cDeadline, aResult, @aResponse )

										( cAliasQry )->( DBSkip() )
									EndDo

									lJoin := .T.
								EndIf
							Next nL
						EndIf

						If !lJoin
							cAliasQry	:=	GetNextAlias()
							cQuery := ""
							cQuery := "SELECT " + cHeader
							cQuery += "FROM " + RetSqlName( cAlias ) + " " + cAlias + " "

							If cEventCode == "S-2299" .and. ( Alltrim( aV70[nK,1] ) == "001" .OR. Alltrim( aV70[nK,1] ) == "002" )
								cQuery += "INNER JOIN " + RetSqlName( "CUP" ) + " CUP "
								cQuery += "   ON CUP.CUP_FILIAL = CMD.CMD_FILIAL "
								cQuery += "  AND CUP.CUP_ID = CMD.CMD_FUNC "
								cQuery += "  AND CUP.D_E_L_E_T_ = '' "

								cQuery += "INNER JOIN " + RetSqlName( "C9V" ) + " C9V "
								cQuery += "   ON C9V.C9V_FILIAL = CUP.CUP_FILIAL "
								cQuery += "  AND C9V.C9V_ID = CUP.CUP_ID "
								cQuery += "  AND C9V.C9V_VERSAO = CUP.CUP_VERSAO "
								cQuery += "  AND C9V.C9V_ATIVO = '1' "
								cQuery += "  AND C9V.D_E_L_E_T_ = '' "
							ElseIf cEventCode == "S-2200" .and. ( Alltrim( aV70[nK,1] ) == "003" .OR. Alltrim ( aV70[nK,1] ) == "006" )
								cQuery += "INNER JOIN " + RetSqlName( "C9V" ) + " C9V "
								cQuery += "   ON C9V.C9V_FILIAL = CUP.CUP_FILIAL "
								cQuery += "  AND C9V.C9V_ID = CUP.CUP_ID "
								cQuery += "  AND C9V.C9V_VERSAO = CUP.CUP_VERSAO "
								cQuery += "  AND C9V.C9V_ATIVO = '1' "
								cQuery += "  AND C9V.D_E_L_E_T_ = '' "
							ElseIf cEventCode == "S-2230" .and. Alltrim ( aV70[nK,1] ) == "005"
								cQuery += "INNER JOIN " + RetSqlName( "C8N" ) + " C8N "
								cQuery += "   ON C8N.C8N_ID = CM6.CM6_MOTVAF "

								If cBancoDB == "ORACLE"
									cQuery += "  AND ( C8N.C8N_VALIDA = '' OR C8N.C8N_VALIDA > SYSDATE ) "
								ElseIf cBancoDB == "INFORMIX"
									cQuery += "  AND ( C8N.C8N_VALIDA = '' OR C8N.C8N_VALIDA > DAY(CURRENT) ) "
								ElseIf cBancoDB == "POSTGRES"
									cQuery += "  AND ( C8N.C8N_VALIDA = '' OR C8N.C8N_VALIDA > '" + DTOS(Date()) + "' ) "								
								Else
									cQuery += "  AND ( C8N.C8N_VALIDA = '' OR C8N.C8N_VALIDA > GetDate() ) "
								EndIf 

								cQuery += "  AND C8N.D_E_L_E_T_ = '' "
							EndIf

							If cEventCode $ "S-1200|S-1202|S-1207|S-1210|S-1260|S-1270|S-1280|S-1295|S-1298|S-1299|S-2501|S-2555"
								cQuery += "WHERE " + cAlias + "." + cAlias + "_FILIAL = '" + cBranch + "' "
								cQuery += "  AND ( " + cAlias + "." + cMainField + " = '" + ( Left( cPeriod, 4 ) + Right( cPeriod, 2 ) ) + "' "
								cQuery += "		OR " + cAlias + "." + cMainField + " = '" + cPeriodAux + "' "

								If Len( cPeriodAux ) == 4
									cQuery += "		OR " + cAlias + "." + cMainField + " = '" + cDate1200 + "' "
								EndIf

								cQuery += "		OR " + cAlias + "." + cMainField + " = '" + ( Right( cPeriod, 2 ) + Left( cPeriod, 4 ) ) + "' ) "
								cQuery += "  AND " + cFilter + " "
							Else
								cQuery += "WHERE " + cAlias + "." + cAlias + "_FILIAL = '" + cBranch + "' "
								cQuery += "  AND " + cAlias + "." + cMainField + " BETWEEN '" + cPeriodFrom + "' AND '" + cPeriodTo + "' "
								cQuery += "  AND " + cFilter + " "
							EndIf

							If cEventCode == "S-2200" .and. ( Alltrim( aV70[nK,1] ) == "003" .OR. Alltrim( aV70[nK,1] ) == "006" )
								cQuery += "  AND NOT EXISTS (	SELECT T3A.T3A_CPF "
								cQuery += "						FROM " + RetSqlName( "T3A" ) + " T3A "
								cQuery += "						WHERE T3A.T3A_CPF = C9V.C9V_CPF "
								cQuery += "						  AND T3A.D_E_L_E_T_ = '' ) "

								If aV70[nK,1] == "006"
									cQuery += "  AND CUP.CUP_INSANT = '' "
								Else
									cQuery += "  AND CUP.CUP_DTEXER = '' "
								EndIf
							EndIf

							If cEventCode == "S-2190"
								cQuery += "  AND T3A.T3A_DTADMI > '" + cObriEvt + "' "
							ElseIf cEventCode == "S-2210" .and. aV70[nK,1] == "001"
								cQuery += "  AND CM0.CM0_TPCAT <> '3' "
							EndIf

							If cEventCode == "S-2300"
								cQuery += "  AND C9V.C9V_DTTRAN = '' "
							EndIf

							If cEventCode == "S-2200"
								cQuery += "  AND C9V.C9V_DTTRAN = '' "
								cQuery += "  AND C9V.C9V_FILIAL = '" + cBranch + "' "
								cQuery += "  AND C9V.C9V_STATUS IN ( " + StatusIN( cStatus ) + " ) "
							Else
								cQuery += "  AND " + cAlias + "." + cAlias + "_FILIAL = '" + cBranch + "' "
								cQuery += "  AND " + cAlias + "." + cAlias + "_STATUS IN ( " + StatusIN( cStatus ) + " ) "
							EndIf

							cQuery := ChangeQuery( cQuery )

							TCQuery cQuery New Alias (cAliasQry)

							( cAliasQry )->( DBGoTop() )
							While ( cAliasQry )->( !Eof() )
								aResult := GetData( cAliasQry, aV70[nK], cPeriodAux, cEventCode, cBranch, cAlias, cObriEvt )

								AddResponse( cDeadline, aResult, @aResponse )

								( cAliasQry )->( DBSkip() )
							EndDo

							lJoin := .F.
						EndIf
					EndIf
				Next nK
			Next nJ
		Next nI

		nTotal := Len( aResponse )

		For nI := 1 to nTotal

			oResponse := JsonObject():New()

			oResponse["branch"]						:= aResponse[nI,1]
			oResponse["eventDescription"]			:= aResponse[nI,2]
			oResponse["typeOrigin"]					:= aResponse[nI,3]
			oResponse["indApur"]					:= aResponse[nI,4]
			oResponse["periodEvent"]				:= aResponse[nI,5]
			oResponse["cpf"]						:= aResponse[nI,6]
			oResponse["registration"]				:= aResponse[nI,7]
			oResponse["name"]						:= aResponse[nI,8]
			oResponse["dateTrans"]					:= aResponse[nI,9]
			oResponse["deadline"]					:= aResponse[nI,10]
			oResponse["receipt"]					:= aResponse[nI,11]
			oResponse["status"]						:= aResponse[nI,12]
			oResponse["ruleDescription"]			:= aResponse[nI,14]
			oResponse["deadlineDescription"]		:= aResponse[nI,15]
			oResponse["transmissionObservation"]  	:= aResponse[nI,17]
			oResponse["establishment"]  			:= aResponse[nI,18]
			oResponse["processNumber"]  			:= aResponse[nI,19]

			nSeq ++

			SaveResult( cRequestID, oResponse:ToJson(), StrZero( nSeq, 6 ), cDeadline, aResponse[nI,12] )

			SetPercent( cRequestID, nI, nTotal )
		Next nI
	EndIf

	SetFinish( cRequestID )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} InfoV70
@type			function
@description	Retorna as informações da tabela de Mapeamento de Regras dos Prazos.
@author			Alexandre de Lima Santos
@since			13/08/2021
@param			cEventID	-	Identificador do Evento
@return			aV70		-	Mapeamento de Regras dos Prazos
/*/
//---------------------------------------------------------------------
Static Function InfoV70( cEventID as character )

	Local cAliasQry	as character
	Local cQuery	as character
	Local nCount	as numeric
	Local aV70		as array
	Local cBancoDB  as character 
	Local cFilt     as character


	cBancoDB    :=  TCGetDB()
	cAliasQry	:=	GetNextAlias()
	cQuery		:=	""
	cFilt       :=  ""
	nCount		:=	0
	aV70		:=	{}

	cQuery := "SELECT V70.V70_ITEM ITEM "
	cQuery += "     , V70.V70_CRTAPU CRTAPU "
	cQuery += "     , V70.V70_DIA DIA "
	cQuery += "     , V70.V70_MDCPRZ MDCPRZ "
	cQuery += "     , V70.V70_MESESP MESESP "
	cQuery += "     , V70.V70_TABREF TABREF "
	cQuery += "     , V70.V70_CMPREF CMPREF "

	If cBancoDB == "ORACLE"
		cQuery += "     , UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(V70.V70_FILTRO,2000,1) ) AS FILT "
	ElseIf cBancoDB == "OPENEDGE"
		cQuery += "		, CAST( V70.V70_FILTRO AS CHAR(2000)) AS FILT "
	ElseIf cBancoDB <> "INFORMIX"
		cQuery += "     , CAST( V70.V70_FILTRO AS CHAR( 2047 ) ) FILT "
	EndIf

	cQuery += "     , V70.V70_DSCPRZ DSCPRZ "
	cQuery += "     , V70.R_E_C_N_O_ V70RECNO "
	cQuery += "     , COUNT( V70.V70_ID ) REGISTROS_V70 "
	cQuery += "FROM " + RetSqlName( "V70" ) + " V70 "
	cQuery += "WHERE V70.V70_FILIAL = '" + xFilial( "V70" ) + "' "
	cQuery += "  AND V70.V70_ID = '" + cEventID + "' "
	cQuery += "  AND V70.D_E_L_E_T_ = '' "
	cQuery += "GROUP BY V70.V70_ITEM "
	cQuery += "       , V70.V70_CRTAPU "
	cQuery += "       , V70.V70_DIA "
	cQuery += "       , V70.V70_MDCPRZ "
	cQuery += "       , V70.V70_MESESP "
	cQuery += "       , V70.V70_TABREF "
	cQuery += "       , V70.V70_CMPREF "

	If cBancoDB == "ORACLE"
		cQuery += "   , UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(V70.V70_FILTRO,2000,1)) "
	ElseIf cBancoDB <> "INFORMIX"
		cQuery += "   , V70.V70_FILTRO "
	EndIf

	cQuery += "       , V70.R_E_C_N_O_ "
	cQuery += "       , V70.V70_DSCPRZ "

	cQuery := ChangeQuery( cQuery )

	TCQuery cQuery New Alias (cAliasQry)

	( cAliasQry )->( DBGoTop() )

	nCount := ( cAliasQry )->REGISTROS_V70
	
	If nCount > 0
		nCount := 0

		While ( cAliasQry )->( !Eof() )

			

			If cBancoDB $ "INFORMIX|POSTGRES"

				V70->( DBGoTo( ( cAliasQry )->V70RECNO ) )
				cFilt :=  V70->V70_FILTRO

				aAdd( aV70, {	( cAliasQry )->ITEM,;
								( cAliasQry )->CRTAPU,;
								( cAliasQry )->DIA,;
								( cAliasQry )->MDCPRZ,;
								( cAliasQry )->MESESP,;
								( cAliasQry )->TABREF,;
								( cAliasQry )->CMPREF,;
												cFilt,;
								( cAliasQry )->DSCPRZ } )
			Else
				aAdd( aV70, {	( cAliasQry )->ITEM,;
								( cAliasQry )->CRTAPU,;
								( cAliasQry )->DIA,;
								( cAliasQry )->MDCPRZ,;
								( cAliasQry )->MESESP,;
								( cAliasQry )->TABREF,;
								( cAliasQry )->CMPREF,;
								( cAliasQry )->FILT,;
								( cAliasQry )->DSCPRZ } )

			EndIf

			nCount ++

			( cAliasQry )->( DBSkip() )
		EndDo
	EndIf

	( cAliasQry )->( DBCloseArea() )

Return( aV70 )

//---------------------------------------------------------------------
/*/{Protheus.doc} InfoV71
@type			function
@description	Retorna as informações da tabela de Complemento de Regras dos Prazos.
@author			Alexandre de Lima Santos
@since			13/08/2021
@param			cEventID	-	Identificador do Evento
@return			aV71		-	Complemento de Regras dos Prazos
/*/
//---------------------------------------------------------------------
Static Function InfoV71( cEventID as character )

	Local cAliasQry	as character
	Local cQuery	as character
	Local nCount	as numeric
	Local aV71		as array
	Local cFiltV71  as character

	cAliasQry	:=	GetNextAlias()
	cBancoDB    :=  TCGetDB()
	cQuery		:=	""
	cFiltV71    :=  ""
	nCount		:=	0
	aV71		:=	{}

	cQuery := "SELECT V71.V71_ITEMTB ITEMTB "
	cQuery += "     , V71.V71_ITEM ITEM "

	If cBancoDB == "ORACLE"
		cQuery += "     , UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(V71.V71_JOIN ,2000,1) ) AS JOINTAB "
	ElseIf cBancoDB <> "INFORMIX"
		cQuery += "     , CAST( V71.V71_JOIN AS CHAR( 1024 ) ) JOINTAB "
	EndIf

	cQuery += "     , V71.V71_TBJOIN TBJOIN "
	cQuery += "     , V71.R_E_C_N_O_  V71RECNO "
	cQuery += "     , COUNT( V71.V71_ID ) REGISTROS_V71 "
	cQuery += "FROM " + RetSqlName( "V71" ) + " V71 "
	cQuery += "WHERE V71.V71_FILIAL = '" + xFilial( "V71" ) + "' "
	cQuery += "  AND V71.V71_ID = '" + cEventID + "' "
	cQuery += "  AND V71.D_E_L_E_T_ = '' "
	cQuery += "GROUP BY V71.V71_ITEMTB "
	cQuery += "       , V71.V71_ITEM "

	If cBancoDB == "ORACLE"
		cQuery += "     , UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(V71.V71_JOIN ,2000,1) ) "
	ElseIf cBancoDB <> "INFORMIX"
		cQuery += "       , V71.V71_JOIN "
	EndIf

	cQuery += "       , V71.R_E_C_N_O_ "
	cQuery += "       , V71.V71_TBJOIN "

	cQuery := ChangeQuery( cQuery )

	TCQuery cQuery New Alias (cAliasQry)

	( cAliasQry )->( DBGoTop() )

	nCount := ( cAliasQry )->REGISTROS_V71

	If nCount > 0
		nCount := 0

		While ( cAliasQry )->( !Eof() )

			If cBancoDB $ "INFORMIX|POSTGRES"

				V71->( DBGoTo( ( cAliasQry )->V71RECNO ) )
				cFiltV71 :=  V71->V71_JOIN

				If 'GETDATE()' $ UPPER(cFiltV71) .And. cBancoDB $ "INFORMIX"
					cFiltV71 := STRTRAN(UPPER(cFiltV71), 'GETDATE()', 'DAY(CURRENT)'  )
				Else
					cFiltV71 := STRTRAN(UPPER(cFiltV71), 'GETDATE()', "'" + DTOS(Date()) + "'" )
				EndIf

				aAdd( aV71, {	( cAliasQry )->ITEMTB,;
								( cAliasQry )->ITEM,;
											cFiltV71,;
								( cAliasQry )->TBJOIN } )

			ElseIf cBancoDB == "ORACLE"
				cFiltV71 := ( cAliasQry )->JOINTAB

				If 'GETDATE()' $ UPPER(cFiltV71)
					cFiltV71 := STRTRAN(UPPER(cFiltV71), 'GETDATE()', 'SYSDATE'  )
				EndIf

				aAdd( aV71, {	( cAliasQry )->ITEMTB,;
								( cAliasQry )->ITEM,;
											cFiltV71,;
								( cAliasQry )->TBJOIN } )

			Else
				aAdd( aV71, {	( cAliasQry )->ITEMTB,;
								( cAliasQry )->ITEM,;
								( cAliasQry )->JOINTAB,;
								( cAliasQry )->TBJOIN } )
			EndIf

			nCount ++

			( cAliasQry )->( DBSkip() )
		EndDo
	EndIf

	( cAliasQry )->( DBCloseArea() )

Return( aV71 )

//---------------------------------------------------------------------
/*/{Protheus.doc} GetHeader
@type			function
@description	Retorna os campos que deve ser utilizados no SELECT da consulta ao banco de dados.
@author			Alexandre de Lima Santos
@since			13/08/2021
@param			cEvent		-	Código do Evento
@param			cAlias		-	Tabela do Evento
@param			cMainField	-	avaliar
@return			cHeader		-	Campos para utilização no SELECT da consulta ao banco de dados
/*/
//---------------------------------------------------------------------
Static Function GetHeader( cEvent as character, cAlias as character, cMainField as character )

	Local cHeader	as character

	cHeader	:=	""

	cHeader := cAlias + "_FILIAL FILIAL "
	cHeader += " , " + cAlias + "_VERSAO VERSAO "
	cHeader += " , " + cAlias + "_DINSIS DINSIS "

	If cEvent == "S-2200"
		cHeader += " , '' EVENTO "
		cHeader += " , '' RECIBO "
	Else
		cHeader += " , " + cAlias + "_EVENTO EVENTO "
		cHeader += " , " + cAlias + "_STATUS STATUS "
		cHeader += " , " + cAlias + "_PROTUL RECIBO "
	EndIf

	If cEvent $ "S-2500|S-2501"
		cHeader += " , " + cAlias + "_NRPROC NRPROC "
	EndIf

	If cEvent $ "S-2555" .And. TAFAlsInDic( "T8I" )
		cHeader += " , " + cAlias + "_NRPROC NRPROC "
	EndIf

	If cEvent $ "S-2500"
		cHeader += " , " + cAlias + "_NMTRAB NMTRAB "
	EndIf

	If cEvent $ "S-2410|S-2416|S-2420"
		cHeader += " , " + cAlias + "_DTTRAN DTRANS "
	ElseIf cEvent $ "S-2501"
		cHeader += " , " + cAlias + "_DTRAN  DTRANS "
	ElseIf cEvent $ "S-2555" .And. TAFAlsInDic( "T8I" )
		cHeader += " , " + cAlias + "_DTRAN  DTRANS "	
	Else
		cHeader += " , " + cAlias + "_DTRANS DTRANS "
	EndIf

	If cEvent $ "S-1295|S-1299"
		cHeader += " , " + cAlias + "_IDRESP ID "
	Else
		cHeader += " , " + cAlias + "_ID ID "
	EndIf

	If cEvent $ "S-2190|S-2200|S-2300"
		cHeader += " , " + cAlias + "_ID TRABAL "
	ElseIf cEvent $ "S-1200|S-1202|S-2210|S-2399|S-2500"
		cHeader += " , " + cAlias + "_TRABAL TRABAL "
	ElseIf cEvent $ "S-2410|S-2416|S-2418|S-2420"
		cHeader += " , " + cAlias + "_BENEF TRABAL "
	ElseIf cEvent $ "S-2220|S-2230|S-2231|S-2240|S-2298|S-2299"
		cHeader += " , " + cAlias + "_FUNC TRABAL "
	ElseIf cEvent == "S-1210"
		cHeader += " , " + cAlias + "_BENEFI TRABAL "
	EndIf

	If cEvent $ "S-1207" .AND. TAFColumnPos("T62_IDBEN")
		cHeader += " , " + cAlias + "_IDBEN IDBEN "
	EndIf

	If cEvent $ "S-1200|S-1202|S-1207|S-1210|S-2300|S-2306"
		cHeader += " , " + cAlias + "_CPF CPF "
	ElseIf cEvent $ "S-2190|S-2200|S-2210|S-2220|S-2230|S-2240|S-2231|S-2298|S-2299|S-2399"
		cHeader += " , '' CPF "
	ElseIf cEvent $ "S-2500"
		cHeader += " , " + cAlias + "_CPFTRA CPF "
	EndIf

	cHeader += " , " + cMainField + " DTEVENT "

	If cEvent $ "S-1200|S-1210|S-2500"
		cHeader += " , " + cAlias + "_ORIEVE ORIEVE "
	ElseIf cEvent $ "S-1202|S-2210|S-2220|S-2240|S-2300"
		cHeader += " , " + cAlias + "_NOMEVE ORIEVE "
	ElseIf cEvent $ "S-2190|S-2200|S-2230|S-2231|S-2298|S-2299|S-2399"
		cHeader += " , '' ORIEVE "
	EndIf

	If cEvent $ "S-1200|S-1202|S-1207|S-1210|S-1260|S-1270|S-1280|S-1295|S-1299"
		cHeader += " , " + cAlias + "_INDAPU INDAPU "
	EndIf

	If cEvent == "S-1210"
		cHeader += " , " + cAlias + "_NOMER NOMER "
	EndIf

	If cEvent $ "S-1260|S-2500"
		cHeader += " , " + cAlias + "_NRINSC NRINSC "
	EndIf

	If cEvent == "S-2230"
		cHeader += " , " + cAlias + "_DTFAFA DTFAFA "
		cHeader += " , " + cAlias + "_XMLREC XMLREC "
	EndIf

	If cEvent == "S-2231"
		cHeader += " , " + cAlias + "_DTTERM DTEFIM "
	EndIf

	If cEvent == "S-2240"
		cHeader += " , " + cAlias + "_DTALT DTEVEALT "
	EndIf

Return( cHeader )

//---------------------------------------------------------------------
/*/{Protheus.doc} SkipRule
@type			function
@description	Indica se deve pular a regra para tratar como exceção.
@author			Alexandre de Lima Santos
@since			10/11/2021
@param			cEvent 		-	Código do Evento
@param			cItem		-	Item do Prazo
@param			cPeriod		-	Período
@param			cV70Item	-	Item do Prazo
@param			cV71Item	-	Item da Junção
@return			lRet		-	Indica se deve pular a regra para tratar como exceção
/*/
//---------------------------------------------------------------------
Static Function SkipRule( cEvent as character, cItem as character, cPeriod as character, cV70Item as character, cV71Item as character )

	Local lRet	as logical

	lRet	:=	.F.

	Default cV70Item	:=	""
	Default cV71Item	:=	""

	If cEvent == "S-2200" .and. AllTrim( cV70Item ) == "004" .and. AllTrim( cV71Item ) == "001" //cV70Item é a mesma coisa que cItem ?
		lRet := .T.
	ElseIf 	cEvent == "S-2555" .and. !TafColumnPos("T8I_NRPROC")	
		lRet := .T.	
	EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} GetData
@type			function
@description	
@author			Alexandre de Lima Santos
@since			19/08/2021
@param			cAliasQry	-	
@param			aV70		-	Mapeamento de Regras dos Prazos
@param			cPeriodAux	-	
@param			cEventCode	-	
@param			cBranch		-	
@param			cAlias		-	
@param			cObriEvt	-	
@return			aResponse	-	
/*/
//---------------------------------------------------------------------
Static Function GetData( cAliasQry as character, aV70 as array, cPeriodAux as character, cEventCode as character, cBranch as character, cAlias as character, cObriEvt as character )

	Local cTypeOrigin	as character
	Local cIndApur		as character
	Local cCpf			as character
	Local cNome			as character
	Local cMatric		as character
	Local cPeriod		as character
	Local cDtrans		as character
	Local cTimeLim		as character
	Local cPrazo		as character
	Local cRecibo		as character
	Local cDesc			as character
	Local cDesRegra		as character
	Local nPos			as numeric
	Local nTime			as numeric
	Local aEvent		as array
	Local aIndApu		as array
	Local aCM6			as array
	Local aResponse		as array
	Local lr2230		as logical
	Local cDesPrazo 	as character
	Local cNA           as character
	Local cIncAlt       as character
	Local cAjusRec		as character
	Local cNrinsc		as character
	Local cNrProc       as character

	cTypeOrigin	:=	""
	cIndApur	:=	""
	cCpf		:=	""
	cNome		:=	""
	cMatric		:=	""
	cPeriod		:=	""
	cDtrans		:=	""
	cTimeLim	:=	""
	cPrazo		:=	""
	cRecibo		:=	""
	cDesc		:=	""
	cDesRegra	:=	""
	cDesPrazo   := 	""
	cNA			:= "N/A"
	cIncAlt     := ""
	cAjusRec    := ""
	cNrinsc		:= ""
	cNrProc     := ""
	nPos		:=	0
	nTime		:=	0
	aEvent		:=	{}
	aIndApu		:=	{}
	aCM6		:=	{}
	aResponse	:=	{}
	lr2230		:=	.T.


	If cEventCode == "S-2200"
		aEvent := StrTokArr2( AllTrim( GetSX3Cache( "C9V_EVENTO", "X3_CBOX" ) ), ";" )
		cIncAlt := Posicione( "C9V", 2, xFilial( "C9V", cBranch ) + ( cAliasQry )->TRABAL + "1", "C9V_EVENTO" )
	Else
		aEvent := StrTokArr2( AllTrim( GetSX3Cache( cAlias + "_EVENTO", "X3_CBOX" ) ), ";" )
	EndIf

	If Empty(cIncAlt) 
		nPos := aScan( aEvent, { |x| AllTrim( SubStr( x, 1, At( "=", x ) - 1 ) ) == AllTrim( ( cAliasQry )->EVENTO ) } )
	Else
		nPos := aScan( aEvent, { |x| AllTrim( SubStr( x, 1, At( "=", x ) - 1 ) ) == AllTrim( cIncAlt ) } )
	EndIf

	If nPos > 0
		cTypeOrigin := EncodeUTF8( Upper( SubStr( aEvent[nPos], At( "=", aEvent[nPos] ) + 1, Len( aEvent[nPos] ) ) ) )
	EndIf

	If cEventCode $ "S-1200|S-1202|S-1207|S-1210|S-1260|S-1270|S-1280|S-1295|S-1299"
		aIndApu := StrTokArr2( AllTrim( GetSX3Cache( cAlias + "_INDAPU", "X3_CBOX" ) ), ";" )

		nPos := aScan( aIndApu, { |x| AllTrim( SubStr( x, 1, At( "=", x ) - 1 ) ) == AllTrim( ( cAliasQry )->INDAPU ) } )

		If nPos > 0
			cIndApur := EncodeUTF8( Upper( Substr( aIndApu[nPos], At( "=", aIndApu[nPos] ) + 1, Len( aIndApu[nPos] ) ) ) )
		EndIf
	EndIf

	If cEventCode == "S-1207"
		DBSelectArea( "V73" )
		V73->( DBSetOrder( 4 ) )
		If V73->( MsSeek( xFilial( "V73", cBranch ) + ( cAliasQry )->IDBEN + "1" ) )
			cCpf := AllTrim( Transform(( cAliasQry )->CPF, "@R 999.999.999-99" ) )
			cNome := EncodeUTF8( AllTrim( V73->V73_NOMEB ) )
		EndIf
	EndIf

	If cEventCode $ "S-1295|S-1299"
		DBSelectArea( "C2J" )
		C2J->( DBSetOrder( 5 ) )
		If C2J->( MsSeek( xFilial( "C2J", cBranch ) + ( cAliasQry )->ID ) )
			cCpf :=  AllTrim( Transform( C2J->C2J_CPF, "@R 999.999.999-99" ) )
			cNome := EncodeUTF8( AllTrim( C2J->C2J_NOME ) )
		EndIf
	EndIf

	If cEventCode $ "S-2400|S-2405"
		DBSelectArea( "V73" )
		V73->( DBSetOrder( 1 ) )
		If V73->( MsSeek( xFilial( "V73", cBranch ) + ( cAliasQry )->ID ) )
			cCpf := AllTrim( Transform( V73->V73_CPFBEN, "@R 999.999.999-99" ) )
			cNome := EncodeUTF8( AllTrim( V73->V73_NOMEB ) )
		EndIf
	EndIf

	If cEventCode $ "S-2410|S-2416|S-2418|S-2420"
		DBSelectArea( cAlias )
		( cAlias )->( DBSetOrder( 2 ) )
		If ( cAlias )->( MsSeek( xFilial( cAlias, cBranch ) + ( cAliasQry )->ID + ( cAliasQry )->VERSAO + "1" ) )
			cCpf := AllTrim( Transform( ( cAlias )->&( cAlias + "_CPFBEN" ), "@R 999.999.999-99" ) )
			cNome := EncodeUTF8( Posicione( "V73", 1, xFilial( "V73", cBranch ) + ( cAliasQry )->TRABAL, "V73_NOMEB" ) )
			cMatric := ( cAlias )->&( cAlias + "_MATRIC" )
		EndIf
	EndIf

	If Len( ( cAliasQry )->DTEVENT ) <= 6
		cPeriod := Right( ( cAliasQry )->DTEVENT, 2 ) + "/" + Left( ( cAliasQry )->DTEVENT, 4 )
	Else
		cPeriod := DToC( SToD( ( cAliasQry )->DTEVENT ) )
	EndIf

	If cEventCode $ "S-1200|S-1202|S-1210|S-2190|S-2200|S-2210|S-2220|S-2230|S-2231|S-2240|S-2298|S-2299|S-2300|S-2399"
		If ( cAliasQry )->ORIEVE == "S2190" .or. cEventCode == "S-2190"
			DBSelectArea( "T3A" )
			T3A->( DBSetOrder( 3 ) )
			If T3A->( MsSeek( xFilial( "T3A", cBranch ) + ( cAliasQry )->TRABAL + "1" ) )
				cCpf := AllTrim( Transform( Iif( Empty( ( cAliasQry )->CPF ), T3A->T3A_CPF, ( cAliasQry )->CPF ), "@R 999.999.999-99" ) )
				cNome := EncodeUTF8("TRABALHADOR PRELIMINAR")
				cMatric := EncodeUTF8(AllTrim( T3A->T3A_MATRIC ))
			EndIf

		ElseIf ( cAliasQry )->ORIEVE == "S2400"
			DBSelectArea( "V73" )
			V73->( DBSetOrder( 1 ) )
			If V73->( MsSeek( xFilial( "V73", cBranch ) + ( cAliasQry )->TRABAL) )
				cCpf := AllTrim( Transform( V73->V73_CPFBEN, "@R 999.999.999-99" ) )
				cNome := EncodeUTF8(AllTrim( V73->V73_NOMEB ))
			EndIf

		ElseIf ( cAliasQry )->ORIEVE == "S1202"

			DBSelectArea( cAlias )
			( cAlias )->( DBSetOrder( 1 ) )

			If Empty( ( cAliasQry )->TRABAL )

				If ( cAlias )->( MsSeek( xFilial( cAlias, cBranch ) + ( cAliasQry )->ID + ( cAliasQry )->VERSAO ) )
					cCpf := AllTrim( Transform( ( cAlias )->&( cAlias + "_CPF" ), "@R 999.999.999-99" ) )
					cNome := EncodeUTF8( ( cAlias )->&( cAlias + "_NOME" ) )
				EndIf 	
			Else

				DBSelectArea( "C9V" )
				C9V->( DBSetOrder( 2 ) )

				If C9V->( MsSeek( xFilial( "C9V", cBranch ) + ( cAliasQry )->TRABAL + "1" ) )

					cCpf := AllTrim( Transform( Iif( Empty( ( cAliasQry )->CPF ), C9V->C9V_CPF, ( cAliasQry )->CPF ), "@R 999.999.999-99" ) )
					cNome := EncodeUTF8( AllTrim( C9V->C9V_NOME ) )

					If Empty( C9V->C9V_MATRIC )
						cMatric := AllTrim( C9V->C9V_MATTSV )
					Else
						cMatric := AllTrim( C9V->C9V_MATRIC )
					EndIf
				
					If C9V->C9V_STATUS == "4"
						cDtrans := dTOS( C9V->C9V_DTRANS ) 
						cRecibo := C9V->C9V_PROTUL
					EndIf
				EndIf
			EndIf	
		Else

			DBSelectArea( "C9V" )
			C9V->( DBSetOrder( 2 ) )
			If C9V->( MsSeek( xFilial( "C9V", cBranch ) + ( cAliasQry )->TRABAL + "1" ) )
				cCpf := AllTrim( Transform( Iif( Empty( ( cAliasQry )->CPF ), C9V->C9V_CPF, ( cAliasQry )->CPF ), "@R 999.999.999-99" ) )
				cNome := EncodeUTF8( AllTrim( C9V->C9V_NOME ) )

				If Empty( C9V->C9V_MATRIC )
					cMatric := AllTrim( C9V->C9V_MATTSV )
				Else
					cMatric := AllTrim( C9V->C9V_MATRIC )
				EndIf
				
				If C9V->C9V_STATUS == "4"
					cDtrans := dTOS( C9V->C9V_DTRANS ) 
					cRecibo := C9V->C9V_PROTUL
				EndIf
			Else
				If cEventCode == "S-1210"
					cCpf := AllTrim( Transform( ( cAliasQry )->CPF, "@R 999.999.999-99" ) )
					cNome := EncodeUTF8( AllTrim( ( cAliasQry )->NOMER ) )
				Else
					C9V->( DBSetOrder( 3 ) )
					If C9V->( MsSeek( xFilial( "C9V", cBranch ) + ( cAliasQry )->CPF + "1" ) )
						cCpf := AllTrim( Transform( C9V->C9V_CPF, "@R 999.999.999-99" ) )
						cNome := EncodeUTF8( AllTrim( C9V->C9V_NOME ) )

						If Empty( C9V->C9V_MATRIC )
							cMatric := AllTrim( C9V->C9V_MATTSV )
						Else
							cMatric := AllTrim( C9V->C9V_MATRIC )
						EndIf
						
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	If cEventCode $ "S-2205|S-2206|S-2306|S-2221"
		DBSelectArea( cAlias )
		( cAlias )->( DBSetOrder( 1 ) )
		If ( cAlias )->( MsSeek( xFilial( cAlias, cBranch ) + ( cAliasQry )->ID + ( cAliasQry )->VERSAO + "1" ) ) .and. cEventCode <> "S-2306"
			cCpf := AllTrim( Transform( ( cAlias )->&( cAlias + "_CPF" ), "@R 999.999.999-99" ) )
			If !cEventCode $ "S-2221" 
				cNome := EncodeUTF8( ( cAlias )->&( cAlias + "_NOME" ) )
			Else
				C9V->( DBSetOrder( 3 ) )
				T3A->( DBSetOrder( 2 ) )
				If C9V->( MsSeek( xFilial( "C9V", cBranch ) + ( cAlias )->&( cAlias + "_CPF" ) ) )
					cNome 	:= EncodeUTF8( AllTrim( C9V->C9V_NOME ) )

					If C9V->C9V_NOMEVE == "S2200"
						cMatric := C9V->C9V_MATRIC
					Else
						cMatric := C9V->C9V_MATTSV
					EndIf
				ElseIf 	T3A->( MsSeek( xFilial( "T3A", cBranch ) + ( cAlias )->&( cAlias + "_CPF" ) ) )
					cNome 	:= "TRABALHADOR PRELIMINAR"
					cMatric := T3A->T3A_MATRIC
					
				EndIf		
			EndIf	

			DBSelectArea( "C9V" )
			C9V->( DBSetOrder( 2 ) )
			If C9V->( MsSeek( xFilial( "C9V", cBranch ) + ( cAliasQry )->ID + "1" ) )
				If C9V->C9V_NOMEVE == "S2200"
					cMatric := C9V->C9V_MATRIC
				Else
					cMatric := C9V->C9V_MATTSV
				EndIf
			EndIf
		Else
			If ( cAlias )->( MsSeek( xFilial( cAlias, cBranch ) + ( cAliasQry )->ID + ( cAliasQry )->VERSAO ) )
				cCpf := AllTrim( Transform( ( cAlias )->&( cAlias + "_CPF" ), "@R 999.999.999-99" ) )
				cNome := EncodeUTF8( ( cAlias )->&( cAlias + "_NOME" ) )
				cMatric := ( cAlias )->&( cAlias + "_MATTSV" )
			EndIf
		EndIf
	EndIf
	
	If cEventCode $ "S-2500"
		cCpf  	:= AllTrim( Transform( ( cAliasQry )->CPF, "@R 999.999.999-99" ) )
		cNome 	:= EncodeUTF8( ( cAliasQry )->NMTRAB )

		( "C9V" )->( DBSetOrder( 2 ) )
		If ( "C9V" )->( MsSeek( xFilial( "C9V", cBranch ) + ( cAliasQry )->TRABAL + "1" ) )
			If C9V->C9V_NOMEVE == "S2200"
				cMatric := C9V->C9V_MATRIC
			Else
				cMatric := C9V->C9V_MATTSV
			EndIf
		EndIf
	EndIf

	If cEventCode $ "S-2500|S-2501|S-2555"
		cNrProc := ( cAliasQry )->NRPROC
	EndIf

	If Empty(cCpf)
		cCpf := cNA
	EndIf

	If Empty(cNome)
		cNome := cNA
	EndIf

	If Empty(cMatric)
		cMatric := cNA
	EndIf

	If cEventCode != "S-2200"

		If ( cAliasQry )->STATUS == "4"
			cDtrans := ( cAliasQry )->DTRANS 
		Else
			cDtrans := ""
		EndIf

	EndIf

	If AllTrim( aV70[5] ) $ "12" .and. cEventCode $ "S-1200|S-1202|S-1207|S-1280|S-1295|S-1299"
		
		cTimeLim := DToS( SToD( ( cPeriodAux + "12" + RTrim( aV70[3] ) ) ) )

	ElseIf cEventCode $ "S-1200|S-1202|S-1207|S-1210|S-1260|S-1270|S-1280|S-1295|S-1298|S-1299" 	
		
		cTimeLim := DToS( calcTime( MonthSum( SToD( ( cPeriodAux + RTrim( aV70[3] ) ) ), 1 ), cEventCode, Alltrim( aV70[1] ), SToD(cObriEvt ) ) )
	
	Else

		If !( cEventCode $ "S-2190|S-2210|S-2221" )
		    
			cTimeLim := DToS( calcTime( MonthSum( SToD( ( cPeriodAux + RTrim( aV70[3] ) ) ), 1 ), cEventCode , Alltrim( aV70[1] ), SToD(cObriEvt ) ) )
	
		EndIf
		
	EndIf

	If cEventCode == "S-2190"
		
		If aV70[1] == "001"
			cTimeLim := DToS( DaySub( SToD( ( ( cAliasQry )->DTEVENT ) ), 1 ) )
		Else
			cTimeLim := cObriEvt
		EndIf

	ElseIf cEventCode == "S-2206"

		If aV70[1] == "002"
			cTimeLim := DToS( DataValida( DaySum( SToD( ( cAliasQry )->DTEVENT ), 1 ), .T. ) )
		EndIf

	ElseIf cEventCode == "S-2210"

		If aV70[1] == "001"
			cTimeLim := DToS( DataValida( DaySum( SToD( ( cAliasQry )->DTEVENT ), 1 ), .T. ) )
		Else
			cTimeLim := ( cAliasQry )->DTEVENT
		EndIf

	ElseIf cEventCode == "S-2240" .and. aV70[1] == "002"

		cTimeLim := DToS( MonthSum( SToD( Left( ( cAliasQry )->DTEVEALT, 6 ) + RTrim( aV70[3] ) ), 1 ) )

	ElseIf cEventCode == "S-2299" .and. aV70[1] == "001"

		cTimeLim := DToS( calcTime( DaySum( SToD( ( cAliasQry )->DTEVENT ), 10 ), cEventCode, Alltrim( aV70[1] ), SToD(cObriEvt ) ) )

	ElseIf cEventCode == "S-2200"

		If aV70[1] == "001"

			cTimeLim := DToS( calcTime( LastDate( MonthSum( SToD( cObriEvt ), 1 ) ),cEventCode, Alltrim( aV70[1] ), SToD(cObriEvt ) ) )

		ElseIf aV70[1] == "002"

			cTimeLim := DToS( calcTime( DaySub( SToD( ( cAliasQry )->DTEVENT ), 1 ),cEventCode, Alltrim( aV70[1] ), SToD(cObriEvt ) ) )

		ElseIf aV70[1] == "005"

			cTimeLim := ( cAliasQry )->DTEVENT

		EndIf

	ElseIf cEventCode == "S-2300"

		If aV70[1] == "001"

			cTimeLim := DToS( CalcTime( MonthSum( SToD( ( SubStr( (cAliasQry )->DTEVENT, 1, 6 ) + "15" ) ), 1 ), cEventCode, Alltrim( aV70[1] ), SToD(cObriEvt ) ) ) 

		ElseIf aV70[1] == "002"

			cTimeLim := DToS( LastDate( MonthSum( SToD( cObriEvt ), 1 ) ) )

		EndIf

	ElseIf cEventCode == "S-2221" .and. aV70[1] == "001"

		cTimeLim := DToS( calcTime( MonthSum( SToD( ( cPeriodAux + RTrim( aV70[3] ) ) ), 1 ), cEventCode , Alltrim( aV70[1] ), SToD(cObriEvt ) ) )

	ElseIf cEventCode == "S-2230"

		If ( cAliasQry )->XMLREC == "INIC" .or. ( cAliasQry )->XMLREC == "COMP"

			If aV70[1] $ "001|005"

				aCM6 := Next2230( ( cAliasQry )->TRABAL, ( cAliasQry )->DTEVENT,, aV70 )

				If Len( aCM6 ) > 0

					nTime := Iif(!Empty(aCM6[1,3]),DateDiffDay( SToD( ( cAliasQry )->DTEVENT ), SToD( aCM6[1,3] )),DateDiffDay( SToD( ( cAliasQry )->DTEVENT ), SToD( aCM6[1,4] ) ))

					If nTime <= 15
						lr2230 := .T.
						cTimeLim := DToS( calcTime( MonthSum( SToD( Left( ( cAliasQry )->DTEVENT, 6 ) + RTrim( aV70[3] ) ), 1 ), cEventCode, Alltrim( aV70[1] ), SToD(cObriEvt ) ) )
					Else
						lr2230 := .F.
					EndIf

				EndIf

			ElseIf aV70[1] == "002"

				aCM6 := Next2230( ( cAliasQry )->TRABAL, ( cAliasQry )->DTEVENT,, aV70 )

				If Len( aCM6 ) > 0

					nTime := DateDiffDay( SToD( ( cAliasQry )->DTEVENT ), SToD( aCM6[1,3] ) )

					If nTime >= 3 .and. nTime <= 15
						cTimeLim := DToS( calcTime( MonthSum( SToD( Left( ( cAliasQry )->DTEVENT, 6 ) + RTrim( aV70[3] ) ), 1 ), cEventCode, Alltrim( aV70[1] ), SToD(cObriEvt ) ) )
					Else
						cTimeLim := DToS( calcTime( MonthSum( SToD( Left( ( cAliasQry )->DTEVENT, 6 ) + "15" ), 1 ) ), cEventCode, Alltrim( aV70[1] ), SToD(cObriEvt ) )
					EndIf

				EndIf

			ElseIf aV70[1] == "003" .And. !Empty( ( cAliasQry )->DTFAFA )

				aCM6 := Next2230( ( cAliasQry )->TRABAL, ( cAliasQry )->DTEVENT,, aV70 )

				If Len( aCM6 ) > 0

					nTime := DateDiffDay( SToD( ( cAliasQry )->DTEVENT ), SToD( aCM6[1,3] ) )

					If nTime > 15
						lr2230 := .T.
						cTimeLim := DToS( calcTime( DaySum( SToD( ( cAliasQry )->DTEVENT ), 15 ), cEventCode, Alltrim( aV70[1] ), SToD(cObriEvt ) ) )
					Else
						lr2230 := .F.
					EndIf
				EndIf

			ElseIf aV70[1] == "004"

				aCM6 := Next2230( ( cAliasQry )->TRABAL, DToS( DaySub( SToD( ( cAliasQry )->DTEVENT ), 59 ) ),, aV70 )

				If Len( aCM6 ) > 0
					lr2230 := .T.
					cTimeLim := DToS( calcTime( DaySum( SToD( ( cAliasQry )->DTEVENT ), 15 ), cEventCode, Alltrim( aV70[1] ), SToD(cObriEvt ) ) )
				Else
					lr2230 := .F.
				EndIf

			ElseIf aV70[1] == "007"

				lr2230 := .T.

			ElseIf aV70[1] == "008"

				lr2230 := .T.
				cTimeLim := DToS( calcTime( DaySum( SToD( ( cAliasQry )->DTEVENT ), 90 ), cEventCode, Alltrim( aV70[1] ), SToD(cObriEvt ) ) )

				If !Empty( cDtrans ) .and. cDtrans > cTimeLim
					cPrazo := "1"
				ElseIf !Empty( cDtrans ) .and. cDtrans <= cTimeLim
					cPrazo := "2"
				ElseIf Empty( cDtrans ) .and. DToS( Date() ) > cTimeLim
					cPrazo := "3"
				Else
					cPrazo := "4"
				EndIf

			ElseIf aV70[1] == "009"

				aCM6 := Next2230( ( cAliasQry )->TRABAL, DToS( DaySub( SToD( ( cAliasQry )->DTEVENT ), 59 ) ),, aV70 )

				If Len(aCM6) > 0
					cTimeLim := DToS( calcTime( DaySum( SToD( ( cAliasQry )->DTEVENT ), 1 ), cEventCode, Alltrim( aV70[1] ), SToD(cObriEvt ) ) )
				EndIf 
			EndIf

		ElseIf ( cAliasQry )->XMLREC == "TERM"
			lr2230 := .T.
			cTimeLim := DToS( calcTime( MonthSum( SToD( Left( ( cAliasQry )->DTFAFA, 6 ) + RTrim( aV70[3] ) ), 1 ), cEventCode, Alltrim( aV70[1] ), SToD(cObriEvt ) ) )
		EndIf

		if Empty(cTimeLim)
			cTimeLim := cNA
		EndIf

		If lr2230 .and. ( ( cAliasQry )->XMLREC == "INIC" .or. ( cAliasQry )->XMLREC == "COMP" ) .and. aV70[1] <> "008"
			If !Empty( cDtrans ) .and. cDtrans <= cTimeLim
				cPrazo := "1"
			ElseIf !Empty( cDtrans ) .and. cDtrans > cTimeLim
				cPrazo := "2"
			ElseIf Empty( cDtrans ) .and. DToS( Date() ) <= cTimeLim
				cPrazo := "3"
			Else
				cPrazo := "4"
			EndIf
		ElseIf lr2230 .and. ( cAliasQry )->XMLREC == "TERM"
			If !Empty( ( cAliasQry )->DTFAFA ) .and. ( cAliasQry )->DTFAFA <= cTimeLim
				cPrazo := "1"
			ElseIf !Empty( ( cAliasQry )->DTFAFA ) .and. ( cAliasQry )->DTFAFA > cTimeLim
				cPrazo := "2"
			ElseIf Empty( ( cAliasQry )->DTFAFA ) .and. DToS( Date() ) <= cTimeLim
				cPrazo := "3"
			Else
				cPrazo := "4"
			EndIf
		EndIf
	EndIf

	If cEventCode <> "S-2230"
		If !Empty( cDtrans ) .and. cDtrans <= cTimeLim
			cPrazo := "1"
		ElseIf !Empty( cDtrans ) .and. cDtrans > cTimeLim
			cPrazo := "2"
		ElseIf Empty( cDtrans ) .and. DToS( Date() ) <= cTimeLim
			cPrazo := "3"
		Else
			cPrazo := "4"
		EndIf
	EndIf

	if Empty(cPrazo)
		cPrazo := cNA
	EndIf

	cDesc := EncodeUTF8( Posicione( "C8E", 2, xFilial( "C8E" ) + cEventCode, "C8E->( AllTrim( C8E_CODIGO ) + ' - ' + AllTrim( C8E_DESCRI ) )" ) )
	cTimeLim := DToC( SToD( cTimeLim ) )

	If cEventCode != "S-2200"
		cRecibo := Iif(!Empty(AllTrim( ( cAliasQry )->RECIBO )),AllTrim( ( cAliasQry )->RECIBO ), cNA)
	EndIf

	cDesRegra := EncodeUTF8( aV70[2] )
	cDesPrazo := EncodeUTF8( aV70[9] )


	If cEventCode != "S-2200"
		If Empty( ( cAliasQry )->DTRANS ) .AND. ( cAliasQry )->STATUS  == "4" 
			cAjusRec := EncodeUTF8("Neste evento foi utilizado a funcionalidade de ajuste de recibo, sua data de transmissão não foi informada e pode gerar divergencias.")
			cPrazo := "1"
		Else
			cAjusRec := cNA
		EndIf
	Else
		If Empty( ( cAliasQry )->DTRANS ) .AND. Posicione( "C9V", 2, xFilial( "C9V", cBranch ) + ( cAliasQry )->TRABAL + "1", "C9V_STATUS" )  == "4" 
			cAjusRec := EncodeUTF8("Neste evento foi utilizado a funcionalidade de ajuste de recibo, sua data de transmissão não foi informada e pode gerar divergencias.")
			cPrazo := "1"
		Else
			cAjusRec := cNA
		EndIf
	EndIf

	If Empty(cDesc)
		cDesc := cNA
	EndIf

	If Empty(cRecibo)
		cRecibo := cNA
	EndIf

	If Empty(cDesRegra)
		cDesRegra := cNA
	EndIf

	If Empty(cDesPrazo)
		cDesPrazo := cNA
	EndIf

	If Empty(cDtrans)
		cDtrans := cNA
	Else
		If cEventCode != "S-2200"
			cDtrans := DToC( SToD( ( cAliasQry )->DTRANS ) )
		Else
			cDtrans := DToC( SToD( cDtrans ) )
		EndIf
	EndIf

	If Empty(cTypeOrigin)
		cTypeOrigin := cNA
	EndIf

	If Empty(cIndApur)
		cIndApur := cNA
	EndIf

	If Empty(cPeriod)
		cPeriod := cNA
	EndIf


	If cEventCode $ "S-1260|S-2500"
		cNrinsc := AllTrim(( cAliasQry )->NRINSC)
	Else
		cNrinsc := ""
	EndIf
	
	If Empty(cNrinsc)
		cNrinsc := cNA
	EndIf

	aResponse := {	cBranch,;
					cDesc,;
					cTypeOrigin,;
					cIndApur,;
					cPeriod,;
					cCpf,;
					cMatric,;
					cNome,;
					cDtrans,;
					cTimeLim,;
					cRecibo,;
					cPrazo,;
					lr2230,;
					alltrim(cDesRegra),;
					alltrim(cDesPrazo),;
					lr2230,;
					cAjusRec,;
					cNrinsc,;
					cNrProc }

Return( aResponse )

//---------------------------------------------------------------------
/*/{Protheus.doc} Next2230
@type			function
@description	Retorna as informações relativas ao Evento de Afastamento Temporário
@author			Alexandre de Lima Santos
@since			10/11/2021
@param			cIDEmployee	-	Identificador do Trabalhador
@param			cPeriodFrom	-	Data De
@param			cPeriodTo	-	Data Até
@param			aV70		-	Mapeamento de Regras dos Prazos
@param			lAfast		-	Avaliar
@return			aCM6		-	Informações relativas ao Evento de Afastamento Temporário
/*/
//---------------------------------------------------------------------
Static Function Next2230( cIDEmployee as character, cPeriodFrom as character, cPeriodTo as character, aV70 as array, lAfast as logical )

	Local cAliasQry	as character
	Local cQuery	as character
	Local cBancoDB  as character
	Local nCount	as numeric
	Local aCM6		as array

	cAliasQry	:=	GetNextAlias()
	cQuery		:=	""
	cBancoDB    :=  TCGetDB()
	nCount		:=	0
	aCM6		:=	{}

	Default cPeriodTo	:=	""
	Default	lAfast		:=	.T. //avaliar

	cQuery := "SELECT CM6.CM6_ID ID "
	cQuery += "     , CM6.CM6_XMLREC XMLREC "
	cQuery += "     , CM6.CM6_DTFAFA DTFAFA "
	cQuery += "     , CM6.CM6_DTAFAS DTAFAS "
	cQuery += "     , CM6.CM6_ATIVO ATIVO "
	cQuery += "     , CM6.CM6_STATUS STATUS "
	cQuery += "     , CM6.CM6_DTRANS DTRANS "
	cQuery += "     , CM6.CM6_MOTVAF MOTVAF "
	cQuery += "     , COUNT( CM6.CM6_ID ) REGISTROS_CM6 "
	cQuery += "FROM " + RetSqlName( "CM6" ) + " CM6 "

	If aV70[1] $ "001|002|003|004|005"
		cQuery += "INNER JOIN " + RetSqlName( "C8N" ) + " C8N "
		cQuery += "   ON C8N.C8N_ID = CM6.CM6_MOTVAF "

		If cBancoDB == "ORACLE"
			cQuery += "  AND ( C8N.C8N_VALIDA = '' OR C8N.C8N_VALIDA > SYSDATE ) "
		ElseIf cBancoDB == "INFORMIX"
			cQuery += "  AND ( C8N.C8N_VALIDA = '' OR C8N.C8N_VALIDA > DAY(CURRENT) ) "	
		ElseIf cBancoDB == "POSTGRES"
			cQuery += "  AND ( C8N.C8N_VALIDA = '' OR C8N.C8N_VALIDA > '" + DTOS(Date()) + "' ) "	
		Else
			cQuery += "  AND ( C8N.C8N_VALIDA = '' OR C8N.C8N_VALIDA > GetDate() ) "
		EndIf

		If aV70[1] $ "001|003|004"
			cQuery += "  AND C8N.C8N_CODIGO = '01' "
		ElseIf aV70[1] == "002"
			cQuery += "  AND C8N.C8N_CODIGO = '03' "
		ElseIf aV70[1] == "005"
			cQuery += "  AND C8N.C8N_CODIGO NOT IN ( '01', '03' ) "
		EndIf

		cQuery += "  AND C8N.D_E_L_E_T_ = '' "
	EndIf

	cQuery += "WHERE CM6.CM6_FUNC = '" + cIDEmployee + "' "

	If	aV70[1] $ "001|002|003"
		cQuery += "  AND ( CM6.CM6_DTAFAS >= '" + cPeriodFrom + "' OR CM6.CM6_DTFAFA > '" + cPeriodFrom + "' ) "
		cQuery += "  AND CM6.CM6_INFMTV IN ( '', '2' ) "
	ElseIf aV70[1] == "004" .and. lAfast
		cQuery += "  AND ( CM6.CM6_DTAFAS > '" + cPeriodFrom + "' OR CM6.CM6_DTFAFA > '" + cPeriodFrom + "' ) "
		cQuery += "  AND CM6.CM6_INFMTV IN ( '', '2' ) "
	ElseIf aV70[1] == "004" .and. !lAfast
		cQuery += "  AND ( CM6.CM6_DTAFAS >= '" + cPeriodFrom + "' OR CM6.CM6_DTFAFA <= '" + cPeriodTo + "' ) "
		cQuery += "  AND CM6.CM6_INFMTV IN ( '', '1', '2' ) "
	ElseIf aV70[1] == "005"
		cQuery += "  AND CM6.CM6_DTFAFA > '" + cPeriodFrom + "' "
		cQuery += "  AND CM6.CM6_EVENTO <> 'R' "
		cQuery += "  AND CM6.CM6_INFMTV <> '1' "
	Else
		cQuery += "  AND CM6.CM6_DTFAFA > '" + cPeriodFrom + "' "
	EndIf

	cQuery += "  AND CM6.CM6_ATIVO = '1' "
	cQuery += "  AND CM6.D_E_L_E_T_ = '' "

	cQuery += "GROUP BY CM6.CM6_ID "
	cQuery += "       , CM6.CM6_XMLREC "
	cQuery += "       , CM6.CM6_DTFAFA "
	cQuery += "       , CM6.CM6_DTAFAS "
	cQuery += "       , CM6.CM6_ATIVO "
	cQuery += "       , CM6.CM6_STATUS "
	cQuery += "       , CM6.CM6_DTRANS "
	cQuery += "       , CM6.CM6_MOTVAF "

	cQuery := ChangeQuery( cQuery )

	TCQuery cQuery New Alias (cAliasQry)

	( cAliasQry )->( DBGoTop() )

	nCount := ( cAliasQry )->REGISTROS_CM6
	If nCount > 0
		nCount := 0

		While ( cAliasQry )->( !Eof() )
			aAdd( aCM6, {	( cAliasQry )->ID,;
							( cAliasQry )->XMLREC,;
							( cAliasQry )->DTFAFA,;
							( cAliasQry )->DTAFAS,;
							( cAliasQry )->ATIVO,;
							( cAliasQry )->STATUS,;
							( cAliasQry )->DTRANS,;
							( cAliasQry )->MOTVAF } )

			nCount ++

			( cAliasQry )->( DBSkip() )
		EndDo
	EndIf

	If aV70[1] == "004" .And. lAfast 

		aCM6 := Next2230( cIDEmployee, cPeriodFrom, DToS( DaySum( SToD( cPeriodFrom ), 60 ) ), aV70, .F. )
		nCount ++

	ElseIf aV70[1] == "004" .and. !lAfast

		If !SomaPer04( aCM6 )
			aCM6 := {}
		EndIf

	EndIf

	( cAliasQry )->( DBCloseArea() )

Return( aCM6 )

//---------------------------------------------------------------------
/*/{Protheus.doc} SomaPer04 - avaliar
@type			function
@description	avaliar
@author			Alexandre de Lima Santos
@since			23/11/2021
@param			aCM6	-	Informações relativas ao Evento de Afastamento Temporário
@return			lRule	-	avaliar
/*/
//---------------------------------------------------------------------
Static Function SomaPer04( aCM6 as array )

	Local cStartDate	as character
	Local cFinalDate	as character
	Local nCalcDate		as numeric
	Local nI			as numeric
	Local lRule			as logical

	cStartDate	:=	""
	cFinalDate	:=	""
	nCalcDate	:=	0
	nI			:=	0
	lRule		:=	.T.

	For nI := 1 to Len( aCM6 )
		If aCM6[nI,2] == "INIC"
			cStartDate := aCM6[nI,4]
		ElseIf aCM6[nI,2] == "TERM"
			cFinalDate := aCM6[nI,3]
		ElseIf aCM6[nI,2] == "COMP"
			cStartDate := aCM6[nI,4]
			cFinalDate := aCM6[nI,3]
		EndIf

		If !Empty( cStartDate ) .and. !Empty( cFinalDate )
			nCalcDate += DateDiffDay( SToD( cStartDate ), SToD( cFinalDate ) ) + 1
			cStartDate := ""
			cFinalDate := ""
		EndIf
	Next nI

	If nCalcDate <> 0
		If nCalcDate > 15
			lRule := .T.
		Else
			lRule := .F.
		EndIf
	EndIf

Return( lRule )

//---------------------------------------------------------------------
/*/{Protheus.doc} SaveResult
@type			function
@description	Grava o item do resultado da requisição.
@author			Alexandre de Lima Santos
@since			13/08/2021
@param			cRequestID	-	Identificador da Requisição
@param			cResponse	-	Resposta da Requisição para armazenamento
@param			cSequence	-	Sequência da Resposta da Requisição
@param			cDeadline	-	Status de Prazo
@param			cType		-	Status de Transmissão
/*/
//---------------------------------------------------------------------
Static Function SaveResult( cRequestID as character, cResponse as character, cSequence as character, cDeadline as character, cType as character )

	If RecLock( "V45", .T. )
		V45->V45_ID		:=	cRequestID
		V45->V45_RESP	:=	cResponse
		V45->V45_SEQ	:=	cSequence
		V45->V45_DIVERG	:=	cDeadline
		V45->V45_TIPO	:=	cType
		V45->( MsUnlock() )
	EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} SetPercent
@type			function
@description	Incrementa o percentual de processamento da requisição.
@author			Alexandre de Lima Santos
@since			13/08/2021
@param			cRequestID	-	Identificador da Requisição
@param			nItem		-	Item em processamento
@param			nTotal		-	Total de itens para processamento
/*/
//---------------------------------------------------------------------
Static Function SetPercent( cRequestID as character, nItem as numeric, nTotal as numeric )

	Local nPercent	as numeric
	Local aAreaV3J	as array

	nPercent	:=	1
	aAreaV3J	:=	V3J->( GetArea() )

	DBSelectArea( "V3J" )
	V3J->( DBSetOrder( 1 ) )
	If V3J->( MsSeek( xFilial( "V3J" ) + cRequestID ) )
		nPercent := Int( ( nItem / nTotal ) * 100 )

		If nPercent > 1 .AND. RecLock( "V3J", .F. )
			V3J->V3J_PERC := nPercent
			V3J->( MsUnlock() )
		EndIf
	EndIf

	RestArea( aAreaV3J )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} SetFinish
@type			function
@description	Indica a finalização do processamento da requisição.
@author			Alexandre de Lima Santos
@since			13/08/2021
@param			cRequestID	-	Identificador da Requisição
/*/
//---------------------------------------------------------------------
Static Function SetFinish( cRequestID as character )

	Local oModelV3J	as object
	Local aAreaV3J	as array

	oModelV3J	:=	FWLoadModel( "TAFA531" )
	aAreaV3J	:=	V3J->( GetArea() )

	DBSelectArea( "V3J" )
	V3J->( DBSetOrder( 1 ) )
	If V3J->( MsSeek( xFilial( "V3J" ) + cRequestID ) )
		oModelV3J:SetOperation( MODEL_OPERATION_UPDATE )
		oModelV3J:Activate()

		oModelV3J:LoadValue( "MODEL_V3J", "V3J_STATUS", "2" )
		oModelV3J:LoadValue( "MODEL_V3J", "V3J_DTRESP", Date() )
		oModelV3J:LoadValue( "MODEL_V3J", "V3J_HRRESP", StrTran( Time(), ":", "" ) )
		oModelV3J:LoadValue( "MODEL_V3J", "V3J_PERC", 100 )

		FWFormCommit( oModelV3J )

		oModelV3J:DeActivate()
	EndIf

	oModelV3J:Destroy()

	RestArea( aAreaV3J )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} StatusIN
@type			function
@description	Indica os status que devem ser inseridos na consulta ao banco de dados.
@author			Alexandre de Lima Santos
@since			07/12/2021
@param			cStatus		-	Status da Transmissão ( 1 = Transmitido, 2 = Não Transmitido, 3 = Ambos )
@return			cStatusIN	-	Status formatado para condição IN da consulta ao banco de dados
/*/
//---------------------------------------------------------------------
Static Function StatusIN( cStatus )

	Local cStatusIN	as character

	cStatusIN	:=	""

	If cStatus == "1"
		cStatusIN := "'4'"
	ElseIf cStatus == "2"
		cStatusIN := "'', '1', '2', '3'"
	Else
		cStatusIN := "'', '1', '2', '3', '4'"
	EndIf

Return( cStatusIN )

//---------------------------------------------------------------------
/*/{Protheus.doc} AddResponse
@type			function
@description	Indica se o registro pode ou não ser incluído na resposta do Json considerando o prazo.
@author			Alexandre de Lima Santos
@since			07/12/2021
@param			cDeadline	-	Status de Prazo ( 1 = Dentro do Prazo, 2 = Fora do Prazo, 3 = Ambos )
@param			aResult		-	Registros correspondentes as regras
@param			aResponse	-	Preenchido de acordo com o prazo que o cliente filtrou
/*/
//---------------------------------------------------------------------
Static Function AddResponse( cDeadline, aResult, aResponse )

	If cDeadline == "3" .and. aResult[13]
		aAdd( aResponse, aResult )
	ElseIf cDeadline == "1"
		If aResult[12] $ "1|3" .and. aResult[13]
			aAdd( aResponse, aResult )
		EndIf
	Else
		If aResult[12] $ "2|4" .and. aResult[13]
			aAdd( aResponse, aResult )
		EndIf
	EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} calcTime
@type			function
@description	Retorna o dia valido caso o prazo de envio caia nos feriados ou fim de semana.
@author			Alexandre de Lima Santos
@since			30/01/2024
@param			dData	-	dData a ser validata e atualizada no retorno da função
@param			cEvento -	Evento a qual corresponde a data enviada.]
@param          cRegra  -   Regra a qual o evento pertence 
@param          dObriEvt-   data do inicio da obrigatoriedade dos eventos ao eSocial.
/*/
//---------------------------------------------------------------------
Function calcTime( dData as date, cEvento as character, cRegra as character, dObriEvt as date )

    Default dData := dDataBase
	Default cObriEvt := ""
	Default cEvento := ""
	Default cRegra := ""
	

	If cEvento $ "S-1200|S-1260|S-1299|S-2206" 
		
		If cRegra == "001"
    		dData := DataValida(dData, .T.)
		Else
			dData := DataValida(dData, .F.)
		EndIf

	ElseIf cEvento $ "S-2299|S-2221" .AND. cRegra == "001"
		dData := DataValida(dData, .F.)
	ElseIf !cEvento $ "S-2418"
		dData := DataValida(dData, .T.)
	EndIf

Return dData
