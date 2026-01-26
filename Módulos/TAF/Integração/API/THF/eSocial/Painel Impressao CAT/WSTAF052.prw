#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "APWEBSRV.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} CatReport
@type			method
@description	Serviço do Painel de Impressão da CAT
@author			Fabio Mendonça / Lucas Passos
@since			12/07/2022
/*/
//---------------------------------------------------------------------
WSRESTFUL CatReport DESCRIPTION "Serviço do Painel de Impressão da CAT" FORMAT APPLICATION_JSON

	WSDATA companyId    as STRING
	WSDATA branches     as ARRAY OF STRING
	WSDATA key			as ARRAY OF STRING
	WSDATA sequencial   as ARRAY OF STRING OPTIONAL
	WSDATA cpf          as STRING OPTIONAL
	WSDATA catNumber    as STRING OPTIONAL
	WSDATA name         as STRING OPTIONAL
	WSDATA periodFrom   as STRING OPTIONAL
	WSDATA periodTo     as STRING OPTIONAL	
	WSDATA requestId    as STRING		
	WSDATA page         as INTEGER OPTIONAL
	WSDATA pageSize     as INTEGER OPTIONAL

	WSMETHOD POST;
		DESCRIPTION "Método para iniciar o processamento do Painel de Impressão da CAT";
		WSSYNTAX "api/rh/esocial/v1/CatReport/?{companyId}&{branches}";
		PATH "api/rh/esocial/v1/CatReport/";
		TTALK "V1";
		PRODUCES APPLICATION_JSON
	
	WSMETHOD POST catValues;
		DESCRIPTION "Método para consultar o resultado do Painel de Impressão da CAT";
		WSSYNTAX "api/rh/esocial/v1/CatReport/catValues?{companyId}&{requestId}";
		PATH "api/rh/esocial/v1/CatReport/catValues";
		TTALK "v1";
		PRODUCES APPLICATION_JSON
	
	WSMETHOD POST catMonitorValues;
		DESCRIPTION "Método para consultar o resultado do Painel do e-Social para impressão PDF";
		WSSYNTAX "api/rh/esocial/v1/CatReport/catMonitorValues?{companyId}&{key}";
		PATH "api/rh/esocial/v1/CatReport/catMonitorValues";
		TTALK "v1";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET status;
		DESCRIPTION "Método para consultar o percentual de execução do Painel de Impressão da CAT";
		WSSYNTAX "api/rh/esocial/v1/CatReport/status/?{companyId}&{requestId}";
		PATH "api/rh/esocial/v1/CatReport/status/";
		TTALK "v1";
		PRODUCES APPLICATION_JSON	
	
END WSRESTFUL

//---------------------------------------------------------------------
/*/{Protheus.doc} POST
@type			method
@description	Método para iniciar o processamento do Painel de Impressão da CAT
@author			Fabio Mendonça / Lucas Passos
@since			12/07/2022
@return			lRet	-	Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD POST WSRESTFUL CatReport

	Local aCompany    as array
	Local cEmpRequest as character
	Local cFilRequest as character
	Local cIdUser     as character
	Local cRequestID  as character
	Local lRet        as logical
	Local lRobo       as logical
	Local oRequest    as object
	Local oResponse   as object

	aCompany    := {}
	cEmpRequest := ""
	cFilRequest := ""
	cIdUser     := RetCodUsr()
	cRequestID  := ""
	lRet        := .T.
	oRequest    := Nil
	oResponse   := Nil

	If Empty( ::GetContent() )
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Corpo da requisição não enviado." ) )
	Else
		oRequest := JsonObject():New()
		oRequest:FromJson( ::GetContent() )

		If Empty( oRequest["companyId"] )
			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
		ElseIf Empty( oRequest["branches"] )
			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "Filiais não informadas no parâmetro 'branches'." ) )
		Else
			aCompany := StrTokArr( oRequest["companyId"], "|" )

			If Len( aCompany ) < 2
				lRet := .F.
				SetRestFault( 400, EncodeUTF8( "Empresa ou Filial informado incorretamente no parâmetro 'companyId'." ) )
			Else
				cEmpRequest := aCompany[1]
				cFilRequest := aCompany[2]

				If PrepEnv( cEmpRequest, cFilRequest )
					cRequestID 	:= CreateTicket( ::GetContent() )
					lRobo 		:= ASCAN(oRequest["branches"], "WSTAF052") > 0

					If Empty( cRequestID ) .Or. lRobo
						lRet := .F.
						SetRestFault( 400, EncodeUTF8( "Não foi possível gerar o ticket de processamento no Protheus." ) )
					Else
						StartJob( "WS052EXEC", GetEnvServer(), .F., cEmpRequest, cFilRequest, cRequestID, cIdUser )

						oResponse := JsonObject():New()
						oResponse["requestId"] := cRequestID

						::SetResponse( oResponse:ToJson() )
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
/*/{Protheus.doc} POST
@type			method
@description	Método para retornar os campos para imprimir Cat
@author			Karyna Martins/Silas Gomes
@since			29/08/2022
@return			lRet	-	Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD POST catValues WSRESTFUL CatReport

	Local oRequest		as object
	Local oResponse		as object
	Local cEmpRequest	as character
	Local cFilRequest	as character
	Local cRequestID	as character
	Local aCompany		as array
	Local aSequencial	as array
	Local nPage			as numeric
	Local nPageSize		as numeric
	Local lRet			as logical	

	oRequest	:=	Nil
	oResponse	:=	JsonObject():New()
	cEmpRequest	:=	""
	cFilRequest	:=	""
	cRequestID	:=	""
	aCompany	:=	{}
	aSequencial	:= 	{}
	nPage		:=	1	
	nPageSize	:=  0
	lRet		:=	.T.

	If Empty( ::GetContent() )
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Corpo da requisição não enviado." ) )
	Else
		oRequest := JsonObject():New()
		oRequest:FromJson( ::GetContent() )

		If Empty( oRequest["companyId"] )
			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
		Else
			aCompany := StrTokArr( oRequest["companyId"], "|" )

			If Len( aCompany ) < 2
				lRet := .F.
				SetRestFault( 400, EncodeUTF8( "Empresa ou Filial informado incorretamente no parâmetro 'companyId'." ) )
			Else
				cEmpRequest := aCompany[1]
				cFilRequest := aCompany[2]

				If PrepEnv( cEmpRequest, cFilRequest )

					If ValidID(oRequest["requestId"])
						cRequestID := oRequest["requestId"]
						
						If !Empty( oRequest["sequencial"] )
							aSequencial  := oRequest["sequencial"]
						EndIf

						If !Empty( oRequest["pageSize"] ) .AND. oRequest["pageSize"] > 1
							nPageSize := oRequest["pageSize"]						
						EndIf
						
						If !Empty( oRequest["page"] ) .AND. oRequest["page"] > 1
							nPage := oRequest["page"]
						EndIf

						GetDetails( @oResponse, cRequestID, aSequencial, nPage, nPageSize )

						::SetResponse( oResponse:toJson() )
					Else
						lRet := .F.
						SetRestFault( 400, EncodeUTF8( "A Identificação da Requisição '" + oRequest["requestId"] + "' informado no parâmetro 'requestId' não existe." ) )
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
/*/{Protheus.doc} POST catMonitorValues
@type			method
@description	Método para retornar os campos para imprimir Cat
@author			Karyna Martins/Silas Gomes
@since			29/08/2022
@return			lRet	-	Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD POST catMonitorValues WSRESTFUL CatReport

	Local oRequest		as object
	Local oResponse		as object
	Local cEmpRequest	as character
	Local cFilRequest	as character
	Local cRequestID	as character
	Local aCompany		as array	
	Local aKey			as array
	Local lRet			as logical	

	oRequest	:=	Nil
	oResponse	:=	JsonObject():New()
	cEmpRequest	:=	""
	cFilRequest	:=	""
	cRequestID	:=	""
	aCompany	:=	{}
	aKey		:= 	{}
	lRet		:=	.T.

	If Empty( ::GetContent() )
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Corpo da requisição não enviado." ) )
	Else
		oRequest := JsonObject():New()
		oRequest:FromJson( ::GetContent() )

		If Empty( oRequest["companyId"] )
			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
		Else
			aCompany := StrTokArr( oRequest["companyId"], "|" )

			If Len( aCompany ) < 2
				lRet := .F.
				SetRestFault( 400, EncodeUTF8( "Empresa ou Filial informado incorretamente no parâmetro 'companyId'." ) )
			Else
				cEmpRequest := aCompany[1]
				cFilRequest := aCompany[2]

				If PrepEnv( cEmpRequest, cFilRequest )

					If !Empty(oRequest["key"])

						aKey	:= oRequest["key"]

						If GetMonitor( @oResponse, aKey)
							::SetResponse( oResponse:toJson() )
						Else
							lRet := .F.
							SetRestFault( 400, EncodeUTF8( "O progresso do processamento não foi localizado." ) )
						EndIf

					Else
						lRet := .F.
						SetRestFault( 400, EncodeUTF8( "Número do recibo não informado!" ) )
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
/*/{Protheus.doc} status
@type			method
@description	Método para consultar o percentual de execução do Painel de Impressão da CAT
@author			Fabio Mendonça / Lucas Passos
@since			12/07/2022
@param			companyId	-	Identificador da Empresa|Filial da requisição
@param			requestId	-	Identificador do processamento
@return			lRet		-	Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD GET status QUERYPARAM companyId, requestId WSRESTFUL CatReport

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

	If ::companyId == Nil
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
	ElseIf ::requestId == Nil
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Identificação da Requisição não informada no parâmetro 'requestId'." ) )
	Else
		aCompany := StrTokArr( ::companyId, "|" )

		If Len( aCompany ) < 2
			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "Empresa ou Filial informado incorretamente no parâmetro 'companyId'." ) )
		Else
			cEmpRequest := aCompany[1]
			cFilRequest := aCompany[2]

			If PrepEnv( cEmpRequest, cFilRequest )
				If ValidID( ::requestId )
					cRequestID := ::requestId

					If GetStatus( @oResponse, cRequestID )
						::SetResponse( oResponse:toJson() )
					Else
						lRet := .F.
						SetRestFault( 400, EncodeUTF8( "O progresso do processamento não foi localizado." ) )
					EndIf
				Else
					lRet := .F.
					SetRestFault( 400, EncodeUTF8( "A Identificação da Requisição '" + ::requestId + "' informado no parâmetro 'requestId' não existe." ) )
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
/*/{Protheus.doc} WS052EXEC
@type			function
@description	Executa a busca e processamento dos dados para retorno da requisição
@author			Fabio Mendonça / Lucas Passos
@since			12/07/2022
@param			cEmpRequest	-	Empresa indicada no parâmetro companyId
@param			cFilRequest	-	Filial indicada no parâmetro companyId
@param			cRequestID	-	Identificador da Requisição
/*/
//---------------------------------------------------------------------
Function WS052EXEC( cEmpRequest as character, cFilRequest as character, cRequestID as character, cIdUser )

	Local oRequest		as object
	Local oResponse		as object
	Local aResponse		as array
	Local cAliasQry		as character
	Local cQuery		as character
	Local cCatNumber	as character
	Local cBranch		as character
	Local cCPF			as character
	Local cName			as character
	Local cPeriodFrom	as character
	Local cPeriodTo		as character
	Local nI			as numeric
	Local nTotal		as numeric
	Local nSeq			as numeric

	Default cEmpRequest	:= ""
	Default cFilRequest	:= ""
	Default cRequestID	:= ""

	oRequest		:= Nil
	oResponse		:= Nil
	aResponse		:= {}	
	cAliasQry		:= ""	
	cQuery			:= ""	
	cCatNumber		:= ""
	cBranch			:= ""
	cCPF			:= ""
	cName			:= ""
	cPeriodFrom		:= ""
	cPeriodTo		:= ""
	nI				:=	0
	nTotal			:=	0
	nSeq			:=	0	

	RPCSetType( 3 )
	RPCSetEnv( cEmpRequest, cFilRequest,,, "TAF", "WSTAF052" )

	DBSelectArea( "V3J" )
	V3J->( DBSetOrder( 1 ) )
	If V3J->( MsSeek( xFilial( "V3J" ) + PadR( cRequestID, TamSX3( "V3J_ID" )[1] ) ) )

		oRequest := JsonObject():New()
		oRequest:FromJson( V3J->V3J_PARAMS )

		cBranch       	:= ArrTokStr( oRequest["branches"], "','" )
		cCPF          	:= oRequest["cpf"]
		cName         	:= oRequest["name"]
		cCatNumber    	:= oRequest["catNumber"]
		cPeriodFrom   	:= oRequest["periodFrom"]
		cPeriodTo     	:= oRequest["periodTo"]

		GetQuery(cBranch, cCPF, cName, cCatNumber, cPeriodFrom, cPeriodTo, @aResponse,,,cIdUser)

		nTotal := Len( aResponse )
		For nI := 1 to nTotal

			GetResponse(aResponse, nI, @nSeq, @oResponse)
			SaveResult( cRequestID, oResponse:ToJson(), StrZero( nSeq, 6 ) )
			SetPercent( cRequestID, nI, nTotal )

		Next nI
	EndIf

	SetFinish( cRequestID )

Return


//---------------------------------------------------------------------
/*/{Protheus.doc} CreateTicket
@type			function
@description	Cria e armazena o ticket para a requisição
@author			Fabio Mendonça / Lucas Passos
@since			12/07/2022
@param			cBody		-	Corpo da requisição com os parâmetros desejados
@return			cRequestID	-	Identificador da Requisição
/*/
//---------------------------------------------------------------------
Static Function CreateTicket( cBody as character )

	Local oModelV3J		as object
	Local cRequestID	as character

	Default cBody	:= ""

	cRequestID	:=	FWuuId( "WSTAF052" )	

	If FindFunction("APILogAccess")
		APILogAccess("CatReport")
	EndIf 

	If cRequestID <> Nil .And. !Empty( cRequestID )

		oModelV3J	:=	FWLoadModel( "TAFA531" )
		oModelV3J:SetOperation( MODEL_OPERATION_INSERT )
		oModelV3J:Activate()

		oModelV3J:LoadValue( "MODEL_V3J", "V3J_ID"		, cRequestID 					)
		oModelV3J:LoadValue( "MODEL_V3J", "V3J_SERVIC"	, "CatReport/values" 			)
		oModelV3J:LoadValue( "MODEL_V3J", "V3J_METODO"	, "POST" 						)
		oModelV3J:LoadValue( "MODEL_V3J", "V3J_DTREQ"	, Date() 						)
		oModelV3J:LoadValue( "MODEL_V3J", "V3J_HRREQ"	, StrTran( Time(), ":", "" ) 	)
		oModelV3J:LoadValue( "MODEL_V3J", "V3J_STATUS"	, "1" 							)
		oModelV3J:LoadValue( "MODEL_V3J", "V3J_PERC"	, 1   							)
		oModelV3J:LoadValue( "MODEL_V3J", "V3J_PARAMS"	, cBody 						)

		FWFormCommit( oModelV3J )

		oModelV3J:DeActivate()
		oModelV3J:Destroy()

	EndIf

Return( cRequestID )

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidID
@type			function
@description	Verifica se o Identificador da Requisição é válido
@author			Fabio Mendonça / Lucas Passos
@since			12/07/2022
@param			cRequestID	-	Identificador da Requisição
@return			lRet		-	Indica se o Identificador da Requisição é válido
/*/
//---------------------------------------------------------------------
Static Function ValidID( cRequestID as character )

	Local lRet	as logical

	Default cRequestID := ""

	lRet	:=	.F.

	DBSelectArea( "V3J" )
	V3J->( DBSetOrder( 1 ) )
	lRet := V3J->( MsSeek( xFilial( "V3J" ) + cRequestID ) )

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} GetStatus
@type			function
@description	Executa a consulta do percentual de execução do processamento
@author			Fabio Mendonça / Lucas Passos
@since			12/07/2022
@param			oResponse	-	Objeto Json com o retorno do progresso da requisição
@param			cRequestID	-	Identificador da requisição
@return			lRet		-	Indica se o progresso do processamento foi localizado
/*/
//---------------------------------------------------------------------
Static Function GetStatus( oResponse as object, cRequestID as character )

	Local lRet	as logical

	Default oResponse	:= Nil
	Default cRequestID	:= ""

	lRet	:=	.F.

	DBSelectArea( "V3J" )
	V3J->( DBSetOrder( 1 ) )
	If V3J->( DBSeek( xFilial( "V3J" ) + cRequestID ) )
		lRet := .T.
		
		oResponse := JsonObject():New()

		oResponse["percent"]	:=	V3J->V3J_PERC

		If V3J->V3J_PERC == 100
			oResponse["finished"]	:= .T.	
		Else
			oResponse["finished"]	:= .F.
		EndIf
		
	EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} GetDetails
@type			function
@description	Retorna os registros analíticos com controle de paginação
@author			Fabio Mendonça / Lucas Passos
@since			12/07/2022
@param			oResponse	-	Objeto Json com o retorno do resultado da requisição
@param			cRequestID	-	Identificador da Requisição
@param			nPage		-	Identificador da página solicitada
@param			nPageSize	-	Identificador do total de registros por página
/*/
//---------------------------------------------------------------------
Static Function GetDetails( oResponse as object, cRequestID as character, aSequencial as array, nPage as numeric, nPageSize as numeric )

	Local oJson		as object
	Local cAliasQry	as character
	Local cDatabase	as character
	Local cFilter	as character
	Local cPage		as character
	Local nStartReg	as numeric
	Local nFinalReg	as numeric
	Local aJson		as array
	Local lHasNext	as logical

	Default oResponse	:= Nil
	Default cRequestID	:= ""
	Default aSequencial	:=	{}
	Default nPage		:=	1
	Default nPageSize	:=	0

	oJson		:=	Nil
	cAliasQry	:=	GetNextAlias()
	cDatabase	:=	TCGetDB()
	cPage		:= 	"%%"
	nStartReg	:=	0
	nFinalReg	:=	0
	aJson		:=	{}
	lHasNext	:=	.F.
	cFilter		:=  "%AND V45.V45_ID = '" + cRequestID + "'%"

	If nPageSize > 0 
		nStartReg := Iif( cDatabase == "OPENEDGE", ( nPage - 1 ) * nPageSize, ( ( nPage - 1 ) * nPageSize ) + 1 )
		nFinalReg := nPage * nPageSize

		If cDatabase == "OPENEDGE"
			cPage := "%OFFSET " + Alltrim(str(nStartReg)) + " ROWS FETCH NEXT " + AllTrim(str(nFinalReg)) + " ROWS ONLY%"
		Else
			cPage := "%WHERE LINE_NUMBER BETWEEN " + Alltrim(str(nStartReg)) + " AND " + AllTrim(str(nFinalReg)) + "%"
		EndIf
	EndIf

	If len(aSequencial)>0
		cFilter	:= "%AND V45.V45_ID = '" + cRequestID + "' AND V45.V45_SEQ in ('" + ArrTokStr( aSequencial, "','" ) + "') %"
	EndIf

	If cDatabase == "OPENEDGE"
		BeginSQL Alias cAliasQry
			SELECT V45.R_E_C_N_O_ V45_RECNO
			FROM %table:V45% V45
			WHERE V45.V45_FILIAL = %xFilial:V45%			
			%exp:cFilter%
			AND V45.%notDel%
			ORDER BY V45.R_E_C_N_O_
			%exp:cPage%
		EndSQL
	Else
		BeginSQL Alias cAliasQry
			SELECT *
			FROM (
				SELECT ROW_NUMBER() OVER( ORDER BY V45.R_E_C_N_O_ ) LINE_NUMBER, V45.R_E_C_N_O_ V45_RECNO
				FROM %table:V45% V45
				WHERE V45.V45_FILIAL = %xFilial:V45%				
				%exp:cFilter%
				AND V45.%notDel%
			) TAB
			%exp:cPage%
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

	lHasNext := HasNext( cRequestID, nFinalReg )

	oResponse["items"]		:=	aJson
	oResponse["hasNext"]	:=	lHasNext

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} GetMonitor
@type			function
@description	Retorna os registros analíticos com controle de paginação
@author			Karyna Martins / Silas Gomes
@since			02/09/2022
@param			oResponse	-	Objeto Json com o retorno do resultado da requisição
@param			aKey		-	Identificador da Chave

/*/
//---------------------------------------------------------------------
Static Function GetMonitor( oResponse as object, aKey as array)

	Local oJson		as object
	Local aResponse	as array
	Local aJson		as array
	Local aChave	as array
	Local cBranch	as character	
	Local cId		as character
	Local cVersao	as character
	Local nI		as numeric
	Local nX		as numeric
	Local nSeq		as numeric
	Local nTotal	as numeric
	Local lRet		as logical
	Local lHasNext	as logical
	Local cIdUser   as Character

	Default oResponse	:=	Nil	
	Default aKey		:= 	{}

	oJson		:= Nil
	aResponse	:= {}
	aJson		:= {}
	aChave		:= {}
	cBranch		:= ""
	cId			:= ""
	cVersao		:= ""
	nI			:= 0
	nX			:= 0
	nSeq		:= 0
	nTotal		:= 0
	lRet		:= .F.
	lHasNext	:= .F.
	cIdUser     := RetCodUsr()

	If FindFunction("APILogAccess")
		APILogAccess("CatReport", "Detail")
	EndIf 

	For nX := 1 to len(aKey)

		If !Empty(cBranch)
			cBranch += "','" 
			cId 	+= "','" 
			cVersao += "','" 
		EndIf

		aChave 	:= StrTokArr( aKey[nX], "|" )

		cBranch += aChave[1]
		cId 	+= aChave[3]
		cVersao += aChave[4]

	Next nX	

	If GetQuery( cBranch,,,,,, @aResponse, cId, cVersao, cIdUser )

		nTotal := Len( aResponse )
		For nI := 1 to nTotal

			GetResponse(aResponse, nI, @nSeq, @oJson)
			aAdd( aJson, oJson )			

		Next nI	
		
		lRet := .T.
	
	EndIf
	
	oResponse["items"]		:=	aJson
	oResponse["hasNext"]	:=	lHasNext

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} GetData
@type			function
@description	Realiza o tratamento dos dados trazidos pelo ResultSet da query principal
@author			Fabio Mendonça / Lucas Passos
@since			14/07/2022
@param			cAliasQry	-	Referência para ResultSet da query principal
@return			aResponse	-	Array com dados tratados
/*/
//---------------------------------------------------------------------
Static Function GetData( cAliasQry as Character, cIdUser as Character )

	Local aEmpregador      as Array
	Local aResponse        as Array
	Local cAccDate         as Character
	Local cAccTime         as Character
	Local cAccType         as Character
	Local cAffParts        as Character
	Local cArea            as Character
	Local cBirthDate       as Character
	Local cCategCode       as Character
	Local cCatIni          as Character
	Local cCatNumber       as Character
	Local cCatType         as Character
	Local cCauserAg        as Character
	Local cCBO             as Character
	Local cCBOId           as Character
	Local cCGC             as Character
	Local cCivilStatus     as Character
	Local cCmpArea         as Character
	Local cCnae            as Character
	Local cCodCid          as Character
	Local cCodCountry      as Character
	Local cCodLesion       as Character
	Local cCountry         as Character
	Local cCounty          as Character
	Local cCPF             as Character
	Local cCrm             as Character
	Local cDayWork         as Character
	Local cDeathDate       as Character
	Local cDeathInd        as Character
	Local cDiagnostic      as Character
	Local cDurationTre     as Character
	Local cEventType       as Character
	Local cGender          as Character
	Local cIdProf          as Character
	Local cIndHosp         as Character
	Local cInfoMed         as Character
	Local cLatera          as Character
	Local cName            as Character
	Local cNote            as Character
	Local cObserv          as Character
	Local cOriginCatNumber as Character
	Local cPlace           as Character
	Local cPlaceDate       as Character
	Local cPlaceInsc       as Character
	Local cPlaceType       as Character
	Local cPolice          as Character
	Local cPredecessorType as Character
	Local cReceiving       as Character
	Local cRegistration    as Character
	Local cRemoval         as Character
	Local cServiceDate     as Character
	Local cServiceHour     as Character
	Local cSituation       as Character
	Local cSocialReason    as Character
	Local cSocSecurity     as Character
	Local cTpInsc          as Character
	Local cUF              as Character
	Local cUfProf          as Character
	Local cWasRemoval      as Character
	Local cWorkHour        as Character

	Default cAliasQry := ""

	cPredecessorType := AllTrim( ( cAliasQry )->NOMEVE )

	cAccDate         := ConvertDate( (cAliasQry )->DTACID, cIdUser )
	cAccTime         := AllTrim( Transform( ( cAliasQry )->HRACID, "@R 99:99" ) )
	cAccType         := GetCBoxOpt( "CM0_TIPACI", ( cAliasQry )->TIPACI , .F. )
	cArea            := ""
	cBirthDate       := ConvertDate( Iif( cPredecessorType == "S2190", ( cAliasQry )->DATANA , ( cAliasQry )->DTNASC ), cIdUser )
	cCategCode       := PosicionaTab( "C87", 1, xFilial( "C87" ) + ( cAliasQry )->CODCAT, "C87_CODIGO" )
	cCatIni          := GetCBoxOpt( "CM0_INICAT", ( cAliasQry )->INICAT , .F. )
	cCatNumber       := AllTrim( ( cAliasQry )->PROTUL )
	cCatType         := GetCBoxOpt( "CM0_TPCAT" , ( cAliasQry )->TPCAT , .F. )
	cCivilStatus     := GetCBoxOpt( "C9V_ESTCIV" , AllTrim( ( cAliasQry )->ESTCIVIL ) , .F. )
	cCmpArea         := ""
	cCodCountry      := PosicionaTab("C08",3,xFilial("C08") + AllTrim( ( cAliasQry )->CODPAI ), "C08_CODIGO")
	cCountry         := AllTrim( Posicione("C08",3,xFilial("C08") + AllTrim( ( cAliasQry )->CODPAI ), "C08_DESCRI") )
	cCounty          := ""
	cCPF             := AllTrim( Transform( ( cAliasQry )->CPF, "@R 999.999.999-99" ) )
	cDayWork         := ""
	cDeathDate       := ConvertDate( ( cAliasQry )->DTOBIT, cIdUser )
	cEventType       := GetCBoxOpt( "CM0_EVENTO", ( cAliasQry )->EVENTO , .F. )
	cGender          := GetCBoxOpt( "C9V_SEXO" , AllTrim( ( cAliasQry )->SEXO ) , .F. )
	cName            := EncodeUTF8( AllTrim( ( cAliasQry )->NOME ) )
	cOriginCatNumber := AllTrim( ( cAliasQry )->NRCATORI )
	cPlace           := EncodeUTF8( AllTrim( ( cAliasQry )->DESLOC ) )
	cPlaceDate       := ""
	cPlaceInsc       := ""
	cPlaceType       := GetCBoxOpt( "CM0_TPLOC" , AllTrim( ( cAliasQry )->TPLOC ) , .F. )
	cRemoval         := GetCBoxOpt( "CM0_INDAFA" , AllTrim( ( cAliasQry )->INDAFA ) , .F. )
	cSocSecurity     := ""
	cUF              := ""
	cWasRemoval      := ""
	cWorkHour        := AllTrim( Transform( ( cAliasQry )->HRTRAB, "@R 99:99" ) )

	If TafColumnPos("CM0_TIPREV")
		cSocSecurity := GetCBoxOpt( "CM0_TIPREV", ( cAliasQry )->FILPREV, .F.)
	EndIf
	
	If cCodCountry == '01058' 

		cPlaceInsc		:= Transform( AllTrim( ( cAliasQry )->NRIACI ), "@R! NN.NNN.NNN/NNNN-99" )
		cUF				:= AllTrim( PosicionaTab("C09",3,xFilial("C09") + AllTrim( ( cAliasQry )->UF ), "C09_UF") )
		cCounty			:= AllTrim( PosicionaTab("C07",3,xFilial("C07") + AllTrim( ( cAliasQry )->CODMUN ), "C07_DESCRI") )

	EndIf
	
	cAffParts  := AllTrim( PosicionaTab("C8I",1,xFilial("C8I") + AllTrim( ( cAliasQry )->CODPAR ), "C8I_CODIGO", "C8I_DESCRI") )
    cCauserAg  := AllTrim( PosicionaTab("C8J",1,xFilial("C8J") + AllTrim( ( cAliasQry )->CODAGE ), "C8J_CODIGO", "C8J_DESCRI") )
	cDeathInd  := GetCBoxOpt( "CM0_INDOBI" , AllTrim( ( cAliasQry )->INDOBI ) , .F. )
	cLatera    := GetCBoxOpt( "CM1_LATERA" , AllTrim( ( cAliasQry )->LATERA ) , .F. )
	cPolice    := GetCBoxOpt( "CM0_COMPOL" , AllTrim( ( cAliasQry )->COMPOL ) , .F. )
	cSituation := AllTrim( PosicionaTab("C8L",1,xFilial("C8L") + AllTrim( ( cAliasQry )->CODSIT ), "C8L_CODIGO", "C8L_DESCRI") )

	CM0->( DBGoTo( ( cAliasQry )->CM0RECNO ) )
	cNote := EncodeUTF8( AllTrim( CM0->CM0_OBSMEM ))

	cCodCid      := AllTrim( PosicionaTab("CMM",1,xFilial("CMM") + AllTrim( ( cAliasQry )->CODCID ), "CMM_CODIGO", "CMM_DESCRI") )
	cCodLesion   := AllTrim( PosicionaTab("C8M",1,xFilial("C8M") + AllTrim( ( cAliasQry )->NATLES ), "C8M_CODIGO", "C8M_DESCRI") )
	cCrm         := AllTrim( ( cAliasQry )->CRM )
	cDiagnostic  := EncodeUTF8( AllTrim( ( cAliasQry )->DIAPRO ) )
	cDurationTre := AllTrim( ( cAliasQry )->DURTRA )
	cIdProf      := EncodeUTF8( AllTrim( ( cAliasQry )->NOMEMED ) )
	cIndHosp     := GetCBoxOpt( "CM0_INDINT" , AllTrim( ( cAliasQry )->INDINT ) , .F. )
	cObserv      := EncodeUTF8( AllTrim( ( cAliasQry )->OBSERV ) )
	cReceiving   := ConvertDate( ( cAliasQry )->DTRECP, cIdUser )
	cServiceDate := ConvertDate( ( cAliasQry )->DTATEN, cIdUser )
	cServiceHour := AllTrim( Transform( ( cAliasQry )->HRATEN, "@R 99:99" ) )
	cUfProf      := AllTrim( PosicionaTab("C09",3,xFilial("C09") + AllTrim( ( cAliasQry )->UFMED ), "C09_UF") )
	cInfoMed	 := cIdProf + ", CRM " + cCrm + " " + cUfProf
	  
	If cPredecessorType == "S2190"

		cName 		  := ""
		cRegistration := AllTrim( ( cAliasQry )->MATPRE )
		cCBO 		  := AllTrim( PosicionaTab("C8Z",1,XFILIAL("C8Z") + AllTrim( ( cAliasQry )->CODCBO ), "C8Z_CODIGO", "C8Z_DESCRI") )
		cCmpArea	  := AllTrim( ( cAliasQry )->NATATV )			

	ElseIf cPredecessorType == "S2200"

		cRegistration := AllTrim( ( cAliasQry )->MATTRA )

		If !EMPTY(( cAliasQry )->CBOCAR )

			cCBO := AllTrim( PosicionaTab("C8Z", 1, XFILIAL("C8Z") + AllTrim( ( cAliasQry )->CBOCAR ), "C8Z_CODIGO", "C8Z_DESCRI") )

		ElseIf !EMPTY(( cAliasQry )->CBO_2_5)

			cCBOId := AllTrim( PosicionaTab("C8V", 4, XFILIAL("C8V", ( cAliasQry )->FILIAL ) + ( cAliasQry )->CBO_2_5 + "1" , "C8V_CODCBO") )
			cCBO   := AllTrim( PosicionaTab("C8Z", 1, XFILIAL("C8Z") + cCBOId, "C8Z_CODIGO", "C8Z_DESCRI") )

		EndIf

		cCmpArea := AllTrim( ( cAliasQry )->NATUATV )
		
	Else

		cRegistration := AllTrim( ( cAliasQry )->MATTSV )
		cCBO 		  := AllTrim( PosicionaTab("C8Z",1,XFILIAL("C8Z") + AllTrim( ( cAliasQry )->CBOCARG ), "C8Z_CODIGO", "C8Z_DESCRI") )
		cCmpArea	  := AllTrim( ( cAliasQry )->NATATIV )

	EndIf

	If cCmpArea == '1'
		cArea := 'Urbana'
	ElseIf cCmpArea == '2'
		cArea := 'Rural'
	EndIf	
	
	aEmpregador := InfoEmpregador("CM0")

	cTpInsc := GetCBoxOpt( "CM0_INSACI", aEmpregador[1])
	
	If cTpInsc == "CNPJ"
		cCGC := Transform( aEmpregador[2], "@R! NN.NNN.NNN/NNNN-99" )
	Else
		cCGC := Transform( aEmpregador[2], "@R 999.999.999-99" )
	EndIf 

	cSocialReason := aEmpregador[3]
	cCnae		  := aEmpregador[4]
	cPlaceDate	  := EncodeUTF8( aEmpregador[5] ) + " - " + cServiceDate 

	If TafColumnPos("CM0_ULTTRB")

		cDayWork	:= ConvertDate( ( cAliasQry )->ULTTRB, cIdUser ) 
		cWasRemoval := GetCBoxOpt( "CM0_HAFAS"	, AllTrim( ( cAliasQry )->HAFAS )	, .F. )
		
	EndIf

	aResponse  := {	( cAliasQry )->FILIAL,;
					cCatNumber,;
					cCategCode,;
					cAccDate,;
					cAccTime,;
					cAccType,;
					cCatType,;
					cEventType,;
					cDeathDate,;
					cOriginCatNumber,;
					cCPF,;
					cName,;
					cRegistration,;
					cPredecessorType,;
					cCatIni,;
					cTpInsc,;
					cCGC,;
					cSocialReason,;
					cCnae,;
					cGender,;
					cCivilStatus,;
					cBirthDate,;
					cCBO,;
					cArea,;
					cWorkHour,;
					cRemoval,;
					cPlace,;
					cPlaceType,;
					cCountry,;
					cPlaceInsc,;
					cUF,;
					cCounty,;
					cAffParts,;
					cLatera,;
					cCauserAg,;
					cSituation,;
					cPolice,;	
					cDeathInd,;
					cNote,;
					cServiceDate,;
					cServiceHour,;
					cIndHosp,;
					cDurationTre,;
					cCodLesion,;	
					cDiagnostic,;
					cCodCid,;
					cObserv,;
					cInfoMed,;
					cDayWork,;
					cWasRemoval,;
					cReceiving,;
					cPlaceDate,;
					cSocSecurity;
					}

Return( aResponse )

//---------------------------------------------------------------------
/*/{Protheus.doc} HasNext
@type			function
@description	Retorna se há uma nova página de acordo com os parâmetros informados
@author			Fabio Mendonça / Lucas Passos
@since			12/07/2022
@param			cRequestID	-	Identificador da Requisição
@param			nFinalReg	-	Identificador do último registro a ser retornado
@return			lHasNext	-	Indica se há existência de mais registros além dos retornados
/*/
//---------------------------------------------------------------------
Static Function HasNext( cRequestID as character, nFinalReg as numeric )

	Local cAliasQry	as character
	Local cDatabase	as character
	Local lHasNext	as logical

	Default cRequestID 	:= ""
	Default nFinalReg	:= 0

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
/*/{Protheus.doc} SaveResult
@type			function
@description	Grava o item do resultado da requisição
@author			Fabio Mendonça / Lucas Passos
@since			14/07/2022
@param			cRequestID	-	Identificador da Requisição
@param			cResponse	-	Resposta da Requisição para armazenamento
@param			cSequence	-	Sequência da Resposta da Requisição
/*/
//---------------------------------------------------------------------
Static Function SaveResult( cRequestID as character, cResponse as character, cSequence as character )

	Default cRequestID	:= ""
	Default cResponse	:= ""
	Default cSequence	:= ""

	If RecLock( "V45", .T. )
		V45->V45_ID		:=	cRequestID
		V45->V45_RESP	:=	cResponse
		V45->V45_SEQ	:=	cSequence
		V45->( MsUnlock() )
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} SetPercent
@type			function
@description	Incrementa o percentual de processamento da requisição
@author			Fabio Mendonça / Lucas Passos
@since			14/07/2022
@param			cRequestID	-	Identificador da Requisição
@param			nItem		-	Item em processamento
@param			nTotal		-	Total de itens para processamento
/*/
//---------------------------------------------------------------------
Static Function SetPercent( cRequestID as character, nItem as numeric, nTotal as numeric )

	Local nPercent	as numeric
	Local aAreaV3J	as array

	Default cRequestID 	:= ""
	Default nItem		:= 0
	Default nTotal		:= 0

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

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} SetFinish
@type			function
@description	Indica a finalização do processamento da requisição
@author			Fabio Mendonça / Lucas Passos
@since			14/07/2022
@param			cRequestID	-	Identificador da Requisição
/*/
//---------------------------------------------------------------------
Static Function SetFinish( cRequestID as character )

	Local oModelV3J	as object
	Local aAreaV3J	as array

	Default cRequestID	:= ""

	oModelV3J	:=	FWLoadModel( "TAFA531" )
	aAreaV3J	:=	V3J->( GetArea() )

	DBSelectArea( "V3J" )
	V3J->( DBSetOrder( 1 ) )
	If V3J->( MsSeek( xFilial( "V3J" ) + cRequestID ) )
		oModelV3J:SetOperation( MODEL_OPERATION_UPDATE )
		oModelV3J:Activate()

		oModelV3J:LoadValue( "MODEL_V3J", "V3J_STATUS", "2" 						)
		oModelV3J:LoadValue( "MODEL_V3J", "V3J_DTRESP", Date() 						)
		oModelV3J:LoadValue( "MODEL_V3J", "V3J_HRRESP", StrTran( Time(), ":", "" ) 	)
		oModelV3J:LoadValue( "MODEL_V3J", "V3J_PERC", 100 							)

		FWFormCommit( oModelV3J )

		oModelV3J:DeActivate()
	EndIf

	oModelV3J:Destroy()

	RestArea( aAreaV3J )

Return

/*/{Protheus.doc} GetCBoxOpt
    Obtém a descrição da opção gravada no Campo Combo passado por parâmetro

    @author Fabio Mendonça
    @since 14/07/2022
    @version 1.0

    @param cCBoxField, string, Campo ComboBox desejado
    @param cSearchedOpt, string, Opção (flag) escolhida no Campo Combo
    @param lUpper, boolean, Se retorno será maiúsculo
    @param lAccent, boolean, Se retorno conterá acentos
    
    @return cRet, string, Descrição da opção gravada no Campo Combo
/*/
Static Function GetCBoxOpt( cCBoxField as character, cSearchedOpt as character, lUpper as logical, lAccent as logical )

    Local aCBoxOpt 	as array
    Local nPos 		as numeric
    Local cRet 		as character
    
    Default cCBoxField      :=  ""
    Default cSearchedOpt    :=  ""
    Default lUpper          :=  .T.
    Default lAccent         :=  .F.

	aCBoxOpt  :=  {}
    nPos      :=  0
    cRet      :=  ""

    aCBoxOpt    := StrTokArr2( AllTrim( GetSx3Cache( cCBoxField, "X3_CBOX" ) ), ";" )
    nPos        := AScan( aCBoxOpt, { |x| AllTrim( SubStr( x, 1, At( "=", x ) - 1 ) ) == cSearchedOpt } )     

    If nPos > 0

        cRet    :=  Substr( aCBoxOpt[nPos], At( "=", aCBoxOpt[nPos] ) + 1, Len( aCBoxOpt[nPos] ) )

        If lUpper
            cRet    :=  Upper( cRet )
        EndIf

         If lAccent
            cRet    :=  FwNoAccent( cRet )
        EndIf

    EndIf
    
Return EncodeUTF8( cRet )

/*/{Protheus.doc} GetQuery
    Obtém a descrição da opção gravada no Campo Combo passado por parâmetro

    @author Fabio Mendonça
    @since 14/07/2022
    @version 1.0

    @param cBranch 			- Idenfificador da Filial
    @param cCPF 			- Identificador do CPF
    @param cName 			- Identificador do nome
    @param cCatNumber 		- Identificador do número da CAT (Protul)
	@param cPeriodFrom 		- Identificador do período De
	@param cPeriodTo 		- Identificador do período Até
	@param aResponse 		- Identifica o Json de retorno
	@param cId 				- Identifica o ID da tabela
	@param cVersao 			- Identifica a versão da tabela
    
    @return lRet - Retorna lógico
/*/
Static Function GetQuery(cBranch as character, cCPF as character, cName as character, cCatNumber as character, cPeriodFrom as character, cPeriodTo as character, aResponse as array, cId as character, cVersao as character, cIdUser as Character)

	Local cAliasQry  as character
	Local cBancoDB   as character 
	Local cArqT1V    as character 
	Local cArqT1U    as character
	Local cTableT1U  as character	
	Local cTableT1V  as character
	Local lRet		 as logical
	Local lUseTemp	 as logical 

	Default cBranch			:= ""
	Default cCPF			:= ""
	Default cName			:= ""
	Default cCatNumber		:= ""
	Default cPeriodFrom		:= ""
	Default cPeriodTo		:= ""
	Default cId				:= ""
	Default cVersao			:= ""
	Default aResponse		:= {}

	cAliasQry	:=	GetNextAlias()
	cBancoDB    :=  Upper(AllTrim(TCGetDB()))
	lRet		:= .T.
	lUseTemp	:= .F. 
	cArqT1V     := ""
	cArqT1U     := ""
	cTableT1U   := ""	
	cTableT1V   := ""

	If TAFisBDLegacy() .And. cBancoDB == 'ORACLE'
		lRet := createTempFunc(@cArqT1V,@cArqT1U,@cTableT1U,@cTableT1V,cBranch,cName,cCPF,cCatNumber,cPeriodFrom,cPeriodTo,cId,cVersao)
		lUseTemp := .T. 
	EndIf

	If lRet 
					
		cQuery	:= " SELECT DISTINCT "
		cQuery	+= "  CM0.CM0_FILIAL AS FILIAL "
		cQuery	+= " ,CM0.CM0_NOMEVE AS NOMEVE "		
		cQuery  += " ,CM0.CM0_PROTUL AS PROTUL "		
		cQuery  += " ,CM0.CM0_DTACID AS DTACID "
		cQuery  += " ,CM0.CM0_HRACID AS HRACID "
		cQuery  += " ,CM0.CM0_TIPACI AS TIPACI "
		cQuery  += " ,CM0.CM0_TPCAT AS TPCAT "
		cQuery  += " ,CM0.CM0_INICAT AS INICAT "
		cQuery  += " ,CM0.CM0_EVENTO AS EVENTO "
		cQuery  += " ,CM0.CM0_DTOBIT AS DTOBIT "
		cQuery  += " ,CM0.CM0_PROTPN AS NRCATORI "
		cQuery  += " ,CM0.CM0_HRTRAB AS HRTRAB "
		cQuery  += " ,CM0.CM0_INDAFA AS INDAFA "
		cQuery  += " ,CM0.CM0_DESLOC AS DESLOC "
		cQuery  += " ,CM0.CM0_TPLOC AS TPLOC "
		cQuery  += " ,CM0.CM0_NRIACI AS NRIACI "
		cQuery  += " ,CM0.CM0_UF AS UF "
		cQuery  += " ,CM0.CM0_CODPAI AS CODPAI "
		cQuery  += " ,CM0.CM0_CODMUN AS CODMUN "
		cQuery  += " ,CM0.CM0_CODSIT AS CODSIT "
		cQuery  += " ,CM0.CM0_COMPOL AS COMPOL "
		cQuery  += " ,CM0.CM0_INDOBI AS INDOBI "
		cQuery	+= " ,CM0.CM0_CODCID AS CODCID "
		cQuery	+= " ,CM0.CM0_IDPROF AS IDPROF "
		cQuery	+= " ,CM0.CM0_OBSERV AS OBSERV "
		cQuery  += " ,CM0.CM0_DTATEN AS DTATEN "	   
		cQuery  += " ,CM0.CM0_HRATEN AS HRATEN "
		cQuery  += " ,CM0.CM0_INDINT AS INDINT "
		cQuery  += " ,CM0.CM0_DURTRA AS DURTRA "
		cQuery  += " ,CM0.CM0_NATLES AS NATLES "
		cQuery  += " ,CM0.CM0_DIAPRO AS DIAPRO "
			
		If TafColumnPos("CM0_ULTTRB")
			cQuery  += " ,CM0.CM0_ULTTRB AS ULTTRB "
			cQuery  += " ,CM0.CM0_HAFAS AS HAFAS "		
		EndIf

		If TafColumnPos("CM0_TIPREV")
			cQuery  += " ,CM0.CM0_TIPREV AS FILPREV "
		EndIf

		cQuery  += " ,CM0.CM0_DTRECP AS DTRECP "
		cQuery  += " ,CM0.R_E_C_N_O_ AS CM0RECNO "

		If cBancoDB != 'INFORMIX'
			cQuery  += " ,COALESCE(CUP.CUP_CODCAT, C9V.C9V_CATCI, T3A.T3A_CODCAT) AS CODCAT "
			cQuery  += " ,COALESCE(C9V.C9V_CPF, T3A.T3A_CPF) AS CPF "
		Else
			cQuery  += " ,ISNULL(CUP.CUP_CODCAT, ISNULL(C9V.C9V_CATCI, ISNULL(T3A.T3A_CODCAT, 0 ))) AS CODCAT "
			cQuery  += " ,ISNULL(C9V.C9V_CPF, ISNULL(T3A.T3A_CPF, 0)) AS CPF "
		EndIf
		
		If lUseTemp
			cQuery  += " ,COALESCE(" + cTableT1U + ".NOMETRAB, C9V.C9V_NOME) AS NOME "
		ElseIf cBancoDB == 'INFORMIX'
			cQuery  += " ,ISNULL(T1U.T1U_NOME, ISNULL(C9V.C9V_NOME, 0)) AS NOME "
		Else
			cQuery  += " ,COALESCE(T1U.T1U_NOME, C9V.C9V_NOME) AS NOME "
		EndIf 

		cQuery  += " ,C9V.C9V_SEXO AS SEXO "
		cQuery  += IIf(cBancoDB != 'INFORMIX'," ,COALESCE(T1U.T1U_ESTCIV, C9V.C9V_ESTCIV) AS ESTCIVIL "," ,ISNULL(T1U.T1U_ESTCIV, ISNULL(C9V.C9V_ESTCIV, 0)) AS ESTCIVIL ")
		cQuery  += " ,C9V.C9V_DTNASC AS DTNASC "
		cQuery 	+= " ,C9V.C9V_MATRIC AS MATTRA "
		cQuery 	+= " ,C9V.C9V_MATTSV AS MATTSV "
		cQuery 	+= " ,C9V.C9V_NATATV AS NATATIV "
		cQuery 	+= " ,T3A.T3A_MATRIC AS MATPRE "
		cQuery 	+= " ,T3A.T3A_DTNASC AS DATANA "
		cQuery 	+= " ,T3A.T3A_CODCBO AS CODCBO "
		cQuery 	+= " ,T3A.T3A_NATATV AS NATATV "

		If lUseTemp
			cQuery 	+= " ,COALESCE(" + cTableT1V + ".CBOCAR, CUP.CUP_CBOCAR) AS CBOCAR "
			cQuery 	+= " ,COALESCE(" + cTableT1V + ".CODCGO, CUP.CUP_CODCGO) AS CBO_2_5 "
		ElseIf cBancoDB == 'INFORMIX'
			cQuery 	+= " ,ISNULL(T1V.T1V_CBOCAR, ISNULL(CUP.CUP_CBOCAR, 0)) AS CBOCAR "
			cQuery 	+= " ,ISNULL(T1V.T1V_CODCGO, ISNULL(CUP.CUP_CODCGO,0)) AS CBO_2_5 "
		Else
			cQuery 	+= " ,COALESCE(T1V.T1V_CBOCAR, CUP.CUP_CBOCAR) AS CBOCAR "
			cQuery 	+= " ,COALESCE(T1V.T1V_CODCGO, CUP.CUP_CODCGO) AS CBO_2_5 "
		EndIf 

		cQuery 	+= " ,CUP.CUP_NATATV AS NATUATV "
		cQuery 	+= " ,CUU.CUU_CBOCAR AS CBOCARG "
		cQuery 	+= " ,CM1.CM1_CODPAR AS CODPAR "
		cQuery 	+= " ,CM1.CM1_LATERA AS LATERA "
		cQuery 	+= " ,CM2.CM2_CODAGE AS CODAGE "
		cQuery	+= " ,CM7.CM7_NOME AS NOMEMED "
		cQuery	+= " ,CM7.CM7_NRIOC AS CRM "
		cQuery	+= " ,CM7.CM7_NRIUF AS UFMED "

		cQuery 	+= " FROM " + RetSqlName( "CM0" ) + " CM0 "					
		cQuery	+= " LEFT JOIN	" + RetSqlName( "C9V" ) + " C9V "
		cQuery	+= " ON C9V.C9V_FILIAL = CM0.CM0_FILIAL "
		cQuery	+= " AND C9V.C9V_ID = CM0.CM0_TRABAL "
		cQuery	+= " AND C9V.C9V_ATIVO = '1' "
		cQuery	+= " AND C9V.D_E_L_E_T_ = '' "

		If lUseTemp
			cQuery	+= " LEFT JOIN " + cTableT1V + " ON C9V.R_E_C_N_O_ = " + cTableT1V + ".RECNO " 
		Else 
			cQuery	+= " LEFT JOIN " + RetSqlName( "T1V" ) + " T1V "
			cQuery	+= " ON CM0.CM0_DTACID >= T1V.T1V_DTALT " 
			cQuery	+= " AND T1V.T1V_FILIAL = C9V.C9V_FILIAL "
			cQuery	+= " AND T1V.T1V_ID = C9V.C9V_ID "
			cQuery	+= " AND T1V.T1V_CPF = C9V.C9V_CPF "
			cQuery	+= " AND T1V.T1V_ATIVO = '1' "
			cQuery	+= " AND T1V.D_E_L_E_T_ = '' "
			cQuery	+= " AND T1V.T1V_DTALT = (   "
			cQuery	+= " SELECT MAX(T1V.T1V_DTALT) T1V_DTALT FROM " + RetSqlName( "T1V" ) + " T1V "
			cQuery	+= " WHERE T1V.T1V_DTALT <= CM0.CM0_DTACID "
			cQuery	+= " AND T1V.T1V_FILIAL = C9V.C9V_FILIAL "
			cQuery	+= " AND T1V.T1V_ID = C9V.C9V_ID "
			cQuery	+= " AND T1V.T1V_CPF = C9V.C9V_CPF "
			cQuery	+= " AND T1V.T1V_ATIVO = '1' "
			cQuery	+= " AND T1V.D_E_L_E_T_ = '' ) "
		EndIf 

		cQuery	+= " LEFT JOIN " + RetSqlName( "T3A" ) + " T3A "
		cQuery	+= " ON T3A.T3A_FILIAL = CM0.CM0_FILIAL "
		cQuery	+= " AND T3A.T3A_ID = CM0.CM0_TRABAL "
		cQuery	+= " AND T3A.T3A_ATIVO = '1' "
		cQuery	+= " AND T3A.D_E_L_E_T_ = '' "

		cQuery	+= " LEFT JOIN " + RetSqlName( "CUP" ) + " CUP "
		cQuery	+= " ON CUP.CUP_FILIAL = C9V.C9V_FILIAL "
		cQuery	+= " AND CUP.CUP_ID = C9V.C9V_ID "
		cQuery	+= " AND CUP.CUP_VERSAO = C9V.C9V_VERSAO "
		cQuery	+= " AND CUP.D_E_L_E_T_ = '' "

		cQuery	+= " LEFT JOIN " + RetSqlName( "CUU" ) + " CUU "
		cQuery	+= " ON CUU.CUU_FILIAL = C9V.C9V_FILIAL "
		cQuery	+= " AND CUU.CUU_ID = C9V.C9V_ID "
		cQuery	+= " AND CUU.CUU_VERSAO = C9V.C9V_VERSAO "
		cQuery	+= " AND CUU.D_E_L_E_T_ = '' "

		If lUseTemp
			cQuery	+= " LEFT JOIN " + cTableT1U + " ON C9V.R_E_C_N_O_ = " + cTableT1U + ".RECNO " 
		Else 
			cQuery	+= " LEFT JOIN " + RetSqlName( "T1U" ) + " T1U "
			cQuery	+= " ON T1U.T1U_ID = C9V.C9V_ID "
			cQuery	+= " AND T1U.T1U_FILIAL = C9V.C9V_FILIAL "
			cQuery	+= " AND T1U.T1U_ATIVO = '1' "
			cQuery	+= " AND T1U.D_E_L_E_T_ = '' "
			cQuery	+= " AND T1U.T1U_DTALT= (   "
			cQuery	+= " SELECT MAX(T1U.T1U_DTALT) T1U_DTALT FROM " + RetSqlName( "T1U" ) + " T1U "
			cQuery	+= " WHERE T1U.T1U_DTALT <= CM0.CM0_DTACID "
			cQuery	+= " AND T1U.T1U_FILIAL = C9V.C9V_FILIAL "
			cQuery	+= " AND T1U.T1U_ID = C9V.C9V_ID "
			cQuery	+= " AND T1U.T1U_CPF = C9V.C9V_CPF "
			cQuery	+= " AND T1U.T1U_ATIVO = '1' "
			cQuery	+= " AND T1U.D_E_L_E_T_ = '' ) "
		EndIf 

		cQuery	+= " LEFT JOIN " + RetSqlName( "CM1" ) + " CM1 "
		cQuery	+= " ON CM1.CM1_FILIAL = CM0.CM0_FILIAL "
		cQuery	+= " AND CM1.CM1_ID = CM0.CM0_ID "
		cQuery	+= " AND CM1.CM1_VERSAO = CM0.CM0_VERSAO "
		cQuery	+= " AND CM1.D_E_L_E_T_ = '' "

		cQuery	+= " LEFT JOIN " + RetSqlName( "CM2" ) + " CM2 "
		cQuery	+= " ON CM2.CM2_FILIAL = CM0.CM0_FILIAL "
		cQuery	+= " AND CM2.CM2_ID = CM0.CM0_ID "
		cQuery	+= " AND CM2.CM2_VERSAO = CM0.CM0_VERSAO "
		cQuery	+= " AND CM2.D_E_L_E_T_ = '' "

		cQuery	+= " LEFT JOIN " + RetSqlName( "CM7" ) + " CM7 "
		cQuery	+= " ON CM7.CM7_ID = CM0.CM0_IDPROF "
		cQuery	+= " AND CM7.D_E_L_E_T_ = '' "
		cQuery	+= " WHERE " 
		cQuery	+= " CM0.CM0_FILIAL IN ('" + cBranch + "') "

		If cName != Nil .And. !Empty( cName )
			cName := DecodeUTF8( cName )
			cQuery	+= " AND ( UPPER(C9V.C9V_NOME) LIKE '%" + AllTrim( Upper( cName ) ) + "%' "

			If lUseTemp
				cQuery 	+= " OR UPPER(" + cTableT1U + ".NOMETRAB) LIKE '%" + AllTrim( Upper( cName ) ) + "%') "
			Else 
				cQuery 	+= " OR UPPER(T1U.T1U_NOME) LIKE '%" + AllTrim( Upper( cName ) ) + "%') "
			EndIf
			
		EndIf

		If cCPF != Nil .And. !Empty( cCPF )
			cQuery	+= " AND (C9V.C9V_CPF = '" + cCPF + "' "
			cQuery	+= " OR T3A.T3A_CPF = '" + cCPF + "') "
		EndIf

		If cCatNumber != Nil .And. !Empty( cCatNumber )
			cQuery	+= " AND CM0.CM0_PROTUL IN ('" + cCatNumber + "') "
		EndIf

		If cPeriodFrom == Nil .Or. Empty( cPeriodFrom )
			cPeriodFrom := ""
		EndIf
		
		If cPeriodTo == Nil .Or. Empty( cPeriodTo )
			cPeriodTo := "ZZZ"
		EndIf

		If !Empty(cId) .And. !Empty(cVersao)
			cQuery	+= " AND CM0.CM0_ID IN ('" + cId + "') "
			cQuery	+= " AND CM0.CM0_VERSAO IN ('" + cVersao + "') "
		EndIf
		
		cQuery	+= " AND CM0.CM0_DTACID BETWEEN '" + cPeriodFrom + "'  AND '" + cPeriodTo + "' "
		cQuery	+= " AND CM0.CM0_ATIVO = '1' "
		cQuery	+= " AND CM0.CM0_STATUS = '4' "
		cQuery	+= " AND CM0.D_E_L_E_T_ = '' "
		cQuery	+= " ORDER BY CM0.CM0_DTACID DESC "

		cQuery := ChangeQuery( cQuery )
		TCQuery cQuery New Alias ( cAliasQry )

		( cAliasQry )->( DBGoTop() )	

		lRet := IIf(Eof(),.F.,.T.)
		While ( cAliasQry )->( !Eof() )
			aAdd( aResponse, GetData( cAliasQry, cIdUser ) )
			( cAliasQry )->( DBSkip() )
		EndDo
		( cAliasQry )->( DBCloseArea() )
	EndIf 

	If lUseTemp 
		IIf(!Empty(cArqT1V),cArqT1V:Delete(),)
		IIf(!Empty(cArqT1U),cArqT1U:Delete(),)
	EndIf 

Return lRet

/*/{Protheus.doc} createTempFunc
    Cria uma tabela temporaria com a ultima alteracao de cadastro
	do trabalhador
    @author Evandro dos Santos Oliveira
    @since 27/04/2023
    @version 1.0

    @param cArqT1V 		- Nome da Variavel de Criacao da TempTable T1V (referencia)
    @param cArqT1U 		- Nome da Variavel de Criacao da TempTable T1U (referencia)
    @param cTableT1U 	- Nome da Tabela Temporaria T1U (referencia)
    @param cTableT1V 	- Nome da Tabela Temporaria T1V (referencia)
	@param cBranch 		- Codigo das filiais
	@param cName 		- Identificador do nome
    @param cCPF 		- Identificador do CPF
    @param cCatNumber 	- Identificador do número da CAT (Protul)
	@param cPeriodFrom 	- Identificador do período De
	@param cPeriodTo 	- Identificador do período Até
	@param cId 			- Identifica o ID da tabela
	@param cVersao 		- Identifica a versão da tabela
    
    @return lRet - Retorna lógico
/*/
Static Function createTempFunc(cArqT1V as character,cArqT1U as character,cTableT1U as character,cTableT1V as character,cBranch as character,cName as character,cCPF as character,cCatNumber as character,cPeriodFrom as character,cPeriodTo as character,cId as character,cVersao as character)

	Local cSqlT1V    as character 
	Local cSqlT1U    as character
	Local aStruT1V	 as array 
	Local aStruT1U   as array 
	Local lCreteTemp as logical 

	Default cArqT1V   	:= ""
	Default cArqT1U   	:= ""
	Default cTableT1U 	:= ""
	Default cTableT1V 	:= ""
	Default cBranch   	:= ""
	Default cName   	:= ""
	Default cCPF   		:= ""
	Default cCatNumber  := ""
	Default cPeriodFrom := ""
	Default cPeriodTo   := ""
	Default cId   		:= ""
	Default cVersao   	:= ""

	aStruT1V := {}
	aStruT1U := {}
	lCreteTemp := .T. 

	If Select('tempt1ucat')
		tempt1ucat->(dbCloseArea())
	EndIf 

	If Select('tempt1vcat')
		tempt1vcat->(dbCloseArea())
	EndIf 	

	aAdd(aStruT1V,{ "IDTRAB"  		, "C",  GetSx3Cache("T1V_ID"  	, "X3_TAMANHO"), 0})
	aAdd(aStruT1V,{ "RECNO"  		, "N",  16, 0})
	aAdd(aStruT1V,{ "NOMETRAB"  	, "C",  GetSx3Cache("T1V_NOME"	, "X3_TAMANHO"), 0})
	aAdd(aStruT1V,{ "CBOCAR"  		, "C",  GetSx3Cache("T1V_CBOCAR", "X3_TAMANHO"), 0})
	aAdd(aStruT1V,{ "CODCGO"  		, "C",  GetSx3Cache("T1V_CODCGO", "X3_TAMANHO"), 0})

	cArqT1V := FWTemporaryTable():New('tempt1ucat')
	cArqT1V:SetFields(aStruT1V)
	cArqT1V:AddIndex("I1",{"RECNO"})
	cArqT1V:Create()
	cTableT1V := cArqT1V:GetRealName() 

	If cPeriodFrom == Nil .Or. Empty( cPeriodFrom )
		cPeriodFrom := ""
	EndIf

	If cPeriodTo == Nil .Or. Empty( cPeriodTo )
		cPeriodTo := "ZZZ"
	EndIf

	cSqlT1V := "INSERT INTO " + cTableT1V
	cSqlT1V += " " 
	cSqlT1V += "(IDTRAB,RECNO,NOMETRAB,CBOCAR,CODCGO) " 
	cSqlT1V += " " 
	cSqlT1V += "("
	cSqlT1V += "SELECT MAXDATA.T1V_ID AS IDTRAB "
	cSqlT1V += ",C9VA.R_E_C_N_O_ AS RECNO " 
	cSqlT1V += ",T1VA.T1V_NOME AS NOMETRAB " 
	cSqlT1V += ",T1VA.T1V_CBOCAR AS CBOCAR" 
	cSqlT1V += ",T1VA.T1V_CODCGO AS CODCGO " 
	cSqlT1V += "FROM ("
	cSqlT1V += "SELECT T1V.T1V_ID, MAX(T1V_DTALT) MDATA "
   	cSqlT1V += "FROM " + RetSqlName('T1V') + " T1V, " + RetSqlName('CM0') + " CM0 " 
    cSqlT1V += "WHERE T1V.T1V_FILIAL = CM0.CM0_FILIAL "
    cSqlT1V += "AND T1V.T1V_ID = CM0.CM0_TRABAL "
    cSqlT1V += "AND T1V.T1V_ATIVO = '1' "
    cSqlT1V += "AND T1V.D_E_L_E_T_ = ' ' " 
	cSqlT1V += "AND T1V.T1V_DTALT <= CM0.CM0_DTACID " 

	If !Empty(cBranch)
		cSqlT1V	+= "AND CM0.CM0_FILIAL IN ('" + cBranch + "') "
	EndIf 

	If !Empty(cId) .And. !Empty(cVersao)
		cSqlT1V	+= " AND CM0.CM0_ID IN ('" + cId + "') "
		cSqlT1V	+= " AND CM0.CM0_VERSAO IN ('" + cVersao + "') "
	EndIf

	If cCatNumber != Nil .And. !Empty( cCatNumber )
		cSqlT1V	+= " AND CM0.CM0_PROTUL IN ('" + cCatNumber + "') "
	EndIf

    cSqlT1V += "AND CM0.CM0_ATIVO = '1' " 
    cSqlT1V += "AND CM0.D_E_L_E_T_ = ' '  "
	cSqlT1V	+= "AND CM0.CM0_DTACID BETWEEN '" + cPeriodFrom + "'  AND '" + cPeriodTo + "' "

	cSqlT1V += "GROUP BY T1V_ID " 
	cSqlT1V += ") MAXDATA "
	cSqlT1V += "INNER JOIN " + RetSqlName('T1V') + " T1VA "
	cSqlT1V += "ON T1VA.T1V_ID = MAXDATA.T1V_ID " 
	cSqlT1V += "AND T1VA.T1V_ATIVO = '1' "
	cSqlT1V += "AND T1VA.T1V_DTALT = MAXDATA.MDATA "
    cSqlT1V += "AND T1VA.T1V_ATIVO = '1' " 
    cSqlT1V += "AND T1VA.D_E_L_E_T_ = ' ' " 
 	cSqlT1V += "LEFT JOIN " + RetSqlName('C9V') + " C9VA "
	cSqlT1V += "ON C9VA.C9V_FILIAL = T1VA.T1V_FILIAL "
	cSqlT1V += "AND C9VA.C9V_ID = T1VA.T1V_ID "
	cSqlT1V += "AND C9VA.C9V_ATIVO = '1' AND C9VA.D_E_L_E_T_ = ' ' " 
	cSqlT1V	+= "LEFT JOIN " + RetSqlName( "T3A" ) + " T3A "
	cSqlT1V	+= "ON T3A.T3A_FILIAL = T1VA.T1V_FILIAL "
	cSqlT1V	+= "AND T3A.T3A_ID = T1VA.T1V_ID "
	cSqlT1V	+= "AND T3A.T3A_ATIVO = '1' "
	cSqlT1V	+= "AND T3A.D_E_L_E_T_ = '' "

	If cCPF != Nil .And. !Empty( cCPF )
		cSqlT1V	+= " AND (C9VA.C9V_CPF = '" + cCPF + "' "
		cSqlT1V	+= " OR T3A.T3A_CPF = '" + cCPF + "') "
	EndIf		

	cSqlT1V += ")"

	If TCSQLExec (cSqlT1V) < 0
		TafConOut(TCSQLError())
		TafConOut(cSqlT1V)
		lCreteTemp := .F. 
	EndIf

	TAFEncArr(@aStruT1V)

	If lCreteTemp

		aAdd(aStruT1U,{ "IDTRAB"  		, "C",  GetSx3Cache("T1U_ID"  	, "X3_TAMANHO"), 0})
		aAdd(aStruT1U,{ "RECNO"  		, "N",  16, 0})
		aAdd(aStruT1U,{ "NOMETRAB"  	, "C",  GetSx3Cache("T1U_NOME"	, "X3_TAMANHO"), 0})

		cArqT1U := FWTemporaryTable():New('tempt1vcat')
		cArqT1U:SetFields(aStruT1U)
		cArqT1U:AddIndex("I1",{"RECNO"})
		cArqT1U:Create()
		cTableT1U := cArqT1U:GetRealName() 

		cSqlT1U := "INSERT INTO " + cTableT1U
		cSqlT1U += " " 
		cSqlT1U += "(IDTRAB,RECNO,NOMETRAB) " 
		cSqlT1U += " " 
		cSqlT1U += "("
		cSqlT1U += "SELECT MAXDATA.T1U_ID AS IDTRAB "
		cSqlT1U += ",C9VA.R_E_C_N_O_ AS RECNO " 
		cSqlT1U += ",T1UA.T1U_NOME AS NOMETRAB " 
		cSqlT1U += "FROM ( "
		cSqlT1U += "SELECT T1U.T1U_ID, MAX(T1U_DTALT) MDATA "
		cSqlT1U += "FROM " + RetSqlName('T1U') + " T1U, " + RetSqlName('CM0') + " CM0 "
		cSqlT1U += "WHERE T1U.T1U_DTALT <= CM0.CM0_DTACID " 
		cSqlT1U += "AND T1U.T1U_FILIAL = CM0.CM0_FILIAL " 
		cSqlT1U += "AND T1U.T1U_ID = CM0.CM0_TRABAL " 
		cSqlT1U += "AND T1U.T1U_ATIVO = '1' " 
		cSqlT1U += "AND T1U.D_E_L_E_T_ = ' ' " 

		If !Empty(cBranch)
			cSqlT1U	+= "AND CM0.CM0_FILIAL IN ('" + cBranch + "') "
		EndIf 

		If !Empty(cId) .And. !Empty(cVersao)
			cSqlT1U	+= " AND CM0.CM0_ID IN ('" + cId + "') "
			cSqlT1U	+= " AND CM0.CM0_VERSAO IN ('" + cVersao + "') "
		EndIf

		If cCatNumber != Nil .And. !Empty( cCatNumber )
			cSqlT1U	+= " AND CM0.CM0_PROTUL IN ('" + cCatNumber + "') "
		EndIf

		cSqlT1U += "AND CM0.CM0_ATIVO = '1' " 
		cSqlT1U += "AND CM0.D_E_L_E_T_ = ' '  "
		cSqlT1U	+= "AND CM0.CM0_DTACID BETWEEN '" + cPeriodFrom + "'  AND '" + cPeriodTo + "' "

		cSqlT1U += "AND CM0.CM0_ATIVO = '1' " 
		cSqlT1U += "AND CM0.D_E_L_E_T_ = ' ' " 
		cSqlT1U += "GROUP BY T1U_ID " 
		cSqlT1U += ") MAXDATA INNER JOIN " + RetSqlName('T1U' ) + " T1UA " 
		cSqlT1U += "ON T1UA.T1U_ID = MAXDATA.T1U_ID " 
		cSqlT1U += "AND T1UA.T1U_ATIVO = '1' " 
		cSqlT1U += "AND T1UA.T1U_DTALT = MAXDATA.MDATA " 
		cSqlT1U += "AND T1UA.T1U_ATIVO = '1' " 
		cSqlT1U += "AND T1UA.D_E_L_E_T_ = ' ' " 
		cSqlT1U += "INNER JOIN " + RetSqlName('C9V') + " C9VA "
		cSqlT1U += "ON C9VA.C9V_FILIAL = T1UA.T1U_FILIAL " 
		cSqlT1U += "AND C9VA.C9V_ID = T1UA.T1U_ID  " 
		cSqlT1U += "AND C9VA.C9V_ATIVO = '1' " 
		cSqlT1U += "AND C9VA.D_E_L_E_T_ = ' ' " 
		cSqlT1U	+= "LEFT JOIN " + RetSqlName( "T3A" ) + " T3A "
		cSqlT1U	+= "ON T3A.T3A_FILIAL = T1UA.T1U_FILIAL "
		cSqlT1U	+= "AND T3A.T3A_ID = T1UA.T1U_ID  "
		cSqlT1U	+= "AND T3A.T3A_ATIVO = '1' "
		cSqlT1U	+= "AND T3A.D_E_L_E_T_ = '' "

		If cCPF != Nil .And. !Empty( cCPF )
			cSqlT1U	+= " AND (C9VA.C9V_CPF = '" + cCPF + "' "
			cSqlT1U	+= " OR T3A.T3A_CPF = '" + cCPF + "') "
		EndIf		

		If cName != Nil .And. !Empty( cName )
			cName := DecodeUTF8( cName )
			cSqlT1U	+= " AND ( UPPER(C9V.C9V_NOME) LIKE '%" + AllTrim( Upper( cName ) ) + "%' "
			cSqlT1U += " OR UPPER(T1U.T1U_NOME) LIKE '%" + AllTrim( Upper( cName ) ) + "%') "
		EndIf

		cSqlT1U += ")"

		If TCSQLExec (cSqlT1U) < 0
			TafConOut(TCSQLError())
			TafConOut(cSqlT1U)
		EndIf

		TAFEncArr(@aStruT1U)
	EndIf 

Return lCreteTemp 

/*/{Protheus.doc} GetResponse
    Identifica o Json de retorno oResponse

    @author Silas Gomes/Karyna Martins
    @since 29/08/2022
    @version 1.0

    @param aResponse	- Identifica o array de retorno com Json
	@param nI			- Identifica o indice do array
	@param nSeq			- Identifica o sequencial 
	@param oResponse    - Identifica o objeto de retorno 
/*/
Static Function GetResponse(aResponse as array, nI as numeric, nSeq as numeric, oResponse as object)
	
	Default aResponse	:= {}
	Default nI			:= 1
	Default nSeq		:= 0
	Default oResponse	:= Nil

	oResponse                               := JsonObject():New()
	oResponse["branch"]                     := aResponse[nI, 1]
	oResponse["catNumber"]                  := aResponse[nI, 2]
	oResponse["categCode"]                  := aResponse[nI, 3]
	oResponse["accidentDate"]               := aResponse[nI, 4]
	oResponse["accidentTime"]               := aResponse[nI, 5]
	oResponse["accidentType"]               := aResponse[nI, 6]
	oResponse["catType"]                    := aResponse[nI, 7]
	oResponse["eventType"]                  := aResponse[nI, 8]
	oResponse["deathDate"]                  := aResponse[nI, 9]
	oResponse["originCatNumber"]            := aResponse[nI,10]
	oResponse["cpf"]                        := aResponse[nI,11]
	oResponse["name"]                       := aResponse[nI,12]
	oResponse["registration"]               := aResponse[nI,13]
	oResponse["predecessorType"]            := aResponse[nI,14]
	oResponse["initialCat"]                 := aResponse[nI,15]
	oResponse["inscriptionType"]            := aResponse[nI,16]
	oResponse["inscriptionNumber"]          := aResponse[nI,17]
	oResponse["socialReason"]               := aResponse[nI,18]
	oResponse["cnae"]                       := aResponse[nI,19]
	oResponse["gender"]                     := aResponse[nI,20]
	oResponse["civilStatus"]                := aResponse[nI,21]
	oResponse["birthDate"]                  := aResponse[nI,22]
	oResponse["cbo"]                        := aResponse[nI,23]
	oResponse["area"]                       := aResponse[nI,24]
	oResponse["workHour"]                   := aResponse[nI,25]
	oResponse["removal"]                    := aResponse[nI,26]
	oResponse["place"]                      := aResponse[nI,27]
	oResponse["placeType"]                  := aResponse[nI,28]
	oResponse["country"]                    := aResponse[nI,29]
	oResponse["inscriptionPlace"]           := aResponse[nI,30]
	oResponse["uf"]                         := aResponse[nI,31]
	oResponse["county"]                     := aResponse[nI,32]
	oResponse["affectedParts"]              := aResponse[nI,33]
	oResponse["laterality"]                 := aResponse[nI,34]
	oResponse["causerAgent"]                := aResponse[nI,35]
	oResponse["situation"]                  := aResponse[nI,36]
	oResponse["police"]                     := aResponse[nI,37]
	oResponse["deathSign"]                  := aResponse[nI,38]
	oResponse["note"]                       := aResponse[nI,39]
	oResponse["serviceDate"]                := aResponse[nI,40]
	oResponse["serviceHour"]                := aResponse[nI,41]
	oResponse["hospitalization"]            := aResponse[nI,42]
	oResponse["treatmentDuration"]          := aResponse[nI,43]
	oResponse["lesion"]                     := aResponse[nI,44]
	oResponse["probableDiagnosis"]          := aResponse[nI,45]
	oResponse["codeCid"]                    := aResponse[nI,46]
	oResponse["observation"]                := aResponse[nI,47]
	oResponse["doctorInformation"]          := aResponse[nI,48]
	oResponse["lastDayWorked"]              := aResponse[nI,49]
	oResponse["thereWasRemoval"]            := aResponse[nI,50]
	oResponse["receivingDate"]              := aResponse[nI,51]
	oResponse["placeDate"]                  := aResponse[nI,52]
	oResponse["affilitationSocialSecurity"] := aResponse[nI,53]

	nSeq ++
	oResponse["key"]				:=	StrZero( nSeq, 6 )

Return

/*/{Protheus.doc} InfoEmpregador
    Obtém as informações do empregador

    @author Silas Gomes/Karyna Martins
    @since 29/08/2022
    @version 1.0

    @param cAlias - Campo ComboBox desejado
       
    @return aEmpregador - Descrição da opção gravada no Campo Combo
/*/
Static Function InfoEmpregador(cAlias as character)

	Local aEmpregador 	as array
	Local cCGC			as character
	Local cTpInscr		as character
	Local cNomeCom		as character
	Local cCnae			as character
	Local cCidEst		as character

	Default cAlias	:= ""

	If VldTabTAF( cAlias ) == "EEE" .And. AllTrim((cAlias)->&(cAlias+"_FILIAL")) <> AllTrim(SM0->M0_CODFIL)
		SM0->(DbSetOrder(1))
		SM0->(MsSeek( cEmpAnt + (cAlias)->&(cAlias+"_FILIAL") ))
	EndIf

	cCGC     := AllTrim(SM0->M0_CGC)
	cTpInscr := IIf(Len(cCgc) == 14,"1","2")
	cNomeCom := AllTrim(SM0->M0_NOMECOM)
	cCnae	 := AllTrim(SM0->M0_CNAE)
	cCidEst	 := AllTrim(SM0->M0_CIDENT) + " " + AllTrim(SM0->M0_ESTENT)
	
	aEmpregador  := { cTpInscr, cCGC, cNomeCom, cCnae, cCidEst}

Return aEmpregador

/*/{Protheus.doc} PosicionaTab
    Obtém as informações do empregador

    @author Silas Gomes/Karyna Martins
    @since 01/09/2022
    @version 1.0

    @param cAlias, string, Campo ComboBox desejado
	@param nInd, string, Campo ComboBox desejado
	@param cChave, string, Campo ComboBox desejado
	@param cCampo1, string, Campo ComboBox desejado
	@param cCampo2, string, Campo ComboBox desejado
       
    @return cRet - Descrição da opção gravada no Campo Combo
/*/
Static Function PosicionaTab(cAlias as character, nInd as numeric, cChave as character, cCampo1 as character, cCampo2 as character)

	Local cRet as character

	Default cAlias 	:= ""
	Default nInd   	:= 0
	Default cChave 	:= ""
	Default cCampo1	:= ""
	Default cCampo2	:= ""

	cRet := ""

	(cAlias)->(DbSetOrder(nInd))
	If (cAlias)->(MsSeek(cChave))
		If Empty(cCampo2)
			cRet := (cAlias)->&(cCampo1)
		Else
			cRet := (cAlias)->&(cCampo1) + " - " + (cAlias)->&(cCampo2)
		EndIf
	EndIf

Return EncodeUTF8(cRet)
