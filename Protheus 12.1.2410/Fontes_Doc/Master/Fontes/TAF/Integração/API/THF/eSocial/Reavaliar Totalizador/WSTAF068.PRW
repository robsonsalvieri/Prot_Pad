#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "APWEBSRV.CH"


#DEFINE paramStsNaoProcessados		 aParamES[1]
#DEFINE paramStsValidos		 		 aParamES[2]
#DEFINE paramStsInvalidos			 aParamES[3]
#DEFINE paramStsSemRetorno			 aParamES[4]
#DEFINE paramStsConsistente		 	 aParamES[5]
#DEFINE paramStsInconsistente		 aParamES[6]
#DEFINE paramVisao					 aParamES[7]
#DEFINE paramEtvTabelas				 aParamES[8]
#DEFINE paramEtvIniciais			 aParamES[9]
#DEFINE paramEtvPeriodicos			 aParamES[10]
#DEFINE paramEtvNaoPeriodicos		 aParamES[11]
#DEFINE paramDataInicial		 	 aParamES[12]
#DEFINE paramDataFim				 aParamES[13]
#DEFINE paramFiliais				 aParamES[14]
#DEFINE paramTAFKEY					 aParamES[15]


#DEFINE EVENTOS_INICIAIS 			 aLegEvts[1]
#DEFINE EVENTO_INICIAL_VINCULO		 aLegEvts[2]
#DEFINE EVENTOS_MENSAIS   			 aLegEvts[3]
#DEFINE EVENTOS_EVENTUAIS			 aLegEvts[4]

Static __aSocRot := Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} TotReport
@type			method
@description	Serviço do Painel do Reavaliar Totalizador
@author			Daniele Sakamoto
@since			29/11/2024
/*/
//---------------------------------------------------------------------
WSRESTFUL ReevaluateTotalizers DESCRIPTION "Serviço do Painel do Reavaliar Totalizador" FORMAT APPLICATION_JSON

	WSDATA companyId    		AS STRING
	WSDATA branches     		AS ARRAY OF STRING 
    WSDATA period				AS STRING
	WSDATA eventCodes			AS STRING 
	WSDATA periodFrom			AS STRING
	WSDATA periodTo				AS STRING
	WSDATA requestId			AS STRING
	WSDATA page					AS INTEGER OPTIONAL
	WSDATA pageSize				AS INTEGER OPTIONAL
	WSDATA forceTotalizers		AS BOOLEAN OPTIONAL


	WSMETHOD POST;
		DESCRIPTION "Método para iniciar o processamento do Painel do Reavaliar Totalizador";
		WSSYNTAX "api/rh/esocial/v1/ReevaluateTotalizers/?{companyId}&{branches}&{period}&{eventCodes}&{periodFrom}&{periodTo}&{forceTotalizers}";
		PATH "api/rh/esocial/v1/ReevaluateTotalizers/";
		TTALK "v1";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET status;
		DESCRIPTION "Método para consultar o percentual de execução do Painel do Reavaliar Totalizador";
		WSSYNTAX "api/rh/esocial/v1/ReevaluateTotalizers/status/?{companyId}&{requestId}";
		PATH "api/rh/esocial/v1/ReevaluateTotalizers/status/";
		TTALK "v1";
		PRODUCES APPLICATION_JSON	

	WSMETHOD POST totValues;
		DESCRIPTION "Método para consultar o percentual de execução do Painel do Reavaliar Totalizador";
		WSSYNTAX "api/rh/esocial/v1/ReevaluateTotalizers/totValues/?{companyId}&{requestId}";
		PATH "api/rh/esocial/v1/ReevaluateTotalizers/totValues/";
		TTALK "v1";
		PRODUCES APPLICATION_JSON	

	
	
END WSRESTFUL

//---------------------------------------------------------------------
/*/{Protheus.doc} POST
@type			method
@description	Método para iniciar o processamento do Painel do Reavaliar Totalizador
@author			Daniele Sakamoto
@since			29/11/2024
@return			lRet	-	Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD POST WSRESTFUL ReevaluateTotalizers

	Local aCompany    as array
	Local cEmpRequest as character
	Local cFilRequest as character
	Local cRequestID  as character
	Local lRet        as logical
	Local lRobo       as logical
	Local oRequest    as object
	Local oResponse   as object
	
	aCompany    := {}
	cEmpRequest := ""
	cFilRequest := ""
	cRequestID  := ""
	lRet        := .T.
	oRequest    := Nil
	oResponse   := Nil

	If Empty( ::GetContent() )
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
					lRobo 		:= ASCAN(oRequest["branches"], "WSTAF068") > 0

					If Empty( cRequestID ) .Or. lRobo
						lRet := .F.
						SetRestFault( 400, EncodeUTF8( "Não foi possível gerar o ticket de processamento no Protheus." ) )
					Else
						StartJob( "WS068EXEC", GetEnvServer(), .F., cEmpRequest, cFilRequest, cRequestID )

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
/*/{Protheus.doc} status
@type			method
@description	Método para consultar o percentual de execução do Painel do Reavaliar Totalizador
@author			Daniele Sakamoto
@since			29/11/2024
@param			companyId	-	Identificador da Empresa|Filial da requisição
@param			requestId	-	Identificador do processamento
@return			lRet		-	Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD GET status QUERYPARAM companyId, requestId WSRESTFUL ReevaluateTotalizers

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
/*/{Protheus.doc} POST
@type			method
@description	Método para consultar o Reavaliar Totalizador de acordo 
				com evento selecionado e período.
@author			Daniele Sakamoto
@since			29/11/2024
@return			lRet	-	Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD POST totValues WSRESTFUL ReevaluateTotalizers

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
/*/{Protheus.doc} WS068EXEC
@type			function
@description	Executa a busca e processamento dos dados para retorno da requisição do totalizador
@author			Daniele Sakamoto / Lucas Passos
@since			29/11/2024
@param			cEmpRequest	-	Empresa indicada no parâmetro companyId
@param			cFilRequest	-	Filial indicada no parâmetro companyId
@param			cRequestID	-	Identificador da Requisição
/*/
//---------------------------------------------------------------------
Function WS068EXEC( cEmpRequest as character, cFilRequest as character, cRequestID as character)

	Local oRequest			as object
	Local oResponse			as object
	Local oAuxCont			as object
	Local aEventCodes		as array
	Local aEventQry			as array
	Local aEvents			as array
	Local aBranches			as array
	Local aFil 			    as array
	Local aTotal			as array
	Local cAliasQry			as character
	Local cQuery			as character
	Local cCatNumber		as character
	Local cBranch			as character
	Local cEvent			as character
	Local cName				as character
	Local cPeriod			as character
	Local cPeriodFrom		as character
	Local cPeriodTo			as character
	Local cStatus			as character
	Local cEvtOri			as character
	Local lForce			as logical
	Local nI				as numeric
	Local nX				as numeric 
	Local nJ				as numeric 
	Local nT				as numeric 
	Local nTotal			as numeric
	Local nSeq				as numeric	
	Local nTotIni           as numeric
	Local nTotFin           as numeric
	Local oTabFilSel  		as object 

	Private aParamES		:= Array(17)
    Private aEventosParm    := {}
    Private aLegEvts		:= {}

	Default cEmpRequest	:= ""
	Default cFilRequest	:= ""
	Default cRequestID	:= ""

	oRequest			:= Nil
	oResponse			:= JsonObject():New()
	oAuxCont			:= JsonObject():New()
	aEventCodes	    	:= {}
	aEvents				:= {}
	aEventQry			:= {}
	aBranches         	:= {}	
	aTotal				:= {}
	aTotalAux		    := {}
	cAliasQry			:= ""	
	cQuery				:= ""	
	cCatNumber			:= ""
	cBranch				:= ""
	cEvent				:= ""
	cName				:= ""
	cPeriod		    	:= ""
	cPeriodFrom			:= ""
	cPeriodTo			:= ""
	cStatus				:= ""
	cEvtOri				:= ""
	lForce				:= .F.
	nI					:=	0
	nX                  :=  0
	nJ 					:=  0
	nTotal				:=	0
	nSeq				:=	0	
	nT                  :=  0 
	nTotIni 			:=  0
	nTotFin 			:=  0
	nTotal5001			:= 0
	nTotal5003			:= 0
	oTabFilSel          := Nil

	RPCSetType( 3 )
	RPCSetEnv( cEmpRequest, cFilRequest,,, "TAF", "WSTAF068" )

	aLegEvts := { {01,"C"};
    ,{02,"I"};
    ,{03,"M"};
    ,{04,"E"};
    }
    aParamES[1]		:=	.T.			//paramStsNaoProcessados
    aParamES[2]		:=	.T.			//paramStsValidos
    aParamES[3]		:=	.T.			//paramStsInvalidos
    aParamES[4]		:=	.T.			//paramStsSemRetorno
    aParamES[5]		:=	.T.			//paramStsConsistente
    aParamES[6]		:=	.T.			//paramStsInconsistente
    aParamES[7]		:=	1			//paramVisao
    aParamES[8]		:=	.T.			//paramEtvTabelas
    aParamES[9]		:=	.T.			//paramEtvIniciais ** Descontinuado **
    aParamES[10]	:=	.T.			//paramEtvPeriodicos
    aParamES[11]	:=	.T.			//paramEtvNaoPeriodicos
    aParamES[12]	:=	dDatabase	//paramDataInicial
    aParamES[13]	:=	dDatabase	//paramDataFim
    aParamES[14]	:=	{}			//paramFiliais
    aParamES[15]	:=	{}			//paramTAFKEY
    aParamES[16]	:=	'TODOS'		//paramERPOwner
    aParamES[17]    :=  .F.

    FRetEvts()
	InitStatic()

	DBSelectArea( "V3J" )
	V3J->( DBSetOrder( 1 ) )
	If V3J->( MsSeek( xFilial( "V3J" ) + PadR( cRequestID, TamSX3( "V3J_ID" )[1] ) ) )

		oRequest := JsonObject():New()
		oRequest:FromJson( V3J->V3J_PARAMS )

		aFil        := oRequest["branches"]
		cBranch     := ArrTokStr( oRequest["branches"], "','" )
		cPeriod		:=	oRequest["period"]
		aEventCodes	:=	oRequest["eventCodes"]
		cStatus		:=	oRequest["status"]
		cPeriodFrom	:=	oRequest["periodFrom"]
		cPeriodTo	:=	oRequest["periodTo"]
		lForce		:=  oRequest["forceTotalizers"]

		//Dê/para dos eventos que geram totalizadores com os eventos dos Totalizadores
		For nJ := 1 to Len(aEventCodes)

			cEvents := aEventCodes[nJ]

			If cEvents $ "|S-1200|S-2299|S-2399|"
				aadd(aEvents, cEvents + "S-5001")
				aadd(aEvents, cEvents + "S-5003")

				aadd(aEventQry,TAFRotinas(cEvents ,4,.F.,2))

			ElseIf cEvents $ "|S-1210|"
				aadd(aEvents,"S-5002")
				aadd(aEventQry,TAFRotinas(cEvents ,4,.F.,2))

			ElseIf cEvents $ "|S-1299|"
				aadd(aEvents,"S-5011")
				aadd(aEvents,"S-5012")
				aadd(aEvents,"S-5013")

				aadd(aEventQry,TAFRotinas(cEvents ,4,.F.,2))

			ElseIf cEvents $ "|S-2500|"
				aadd(aEvents,"S-5503")

				aadd(aEventQry,TAFRotinas(cEvents ,4,.F.,2))

			ElseIf cEvents $ "|S-2501|S-2555|"
				aadd(aEvents,"S-5501")

				aadd(aEventQry,TAFRotinas(cEvents ,4,.F.,2))
			EndIf

		Next nJ

		oResponse["totalizersInitial"] := JsonObject():New()
		oAuxCont["auxiliarInitial"]	   := JsonObject():New()

		For nX := 1 To Len( aEvents )
    
			ASORT(aEvents)

			If len(aEvents[nX]) > 6
				cEvent      := subsTr(aEvents[nX],7,12)
				cEvtOri     := subsTr(aEvents[nX],1,6)
			Else
				cEvent      := aEvents[nX]
				cEvtOri     := ""
			EndIf 

			nPosEvent   := aScan(__aSocRot, {|x| x[4] == cEvent })
			cTableEvent := __aSocRot[nPosEvent][3]

			WS068Event(@oResponse, cPeriod, cBranch, cTableEvent, cEvent, cPeriodFrom, cPeriodTo, .T., cEvtOri, @oAuxCont)

			cEvtOri     := ""
    	Next nX

		aTotalAux := oAuxCont["auxiliarInitial"]:GetNames()
		If Len(aTotalAux) > 0 
			For nT := 1 to Len(aTotalAux)

				If "tot5001" $ aTotalAux[nT] 
					nTotal5001 += Val(oAuxCont["auxiliarInitial"]:GetJsonText(aTotalAux[nT]))
				Else
					nTotal5003 += Val(oAuxCont["auxiliarInitial"]:GetJsonText(aTotalAux[nT]))
				EndIf 
			Next

			oResponse["totalizersInitial"]["tot5001"] := cValToChar(nTotal5001)
			oResponse["totalizersInitial"]["tot5003"] := cValToChar(nTotal5003)
		EndIf

		//Realiza a soma para gerar o total de totalizadores antes de realizar o Reavalir Totalizador
		aTotal := oResponse["totalizersInitial"]:GetNames()
		If Len(aTotal) > 0 
			For nT := 1 to Len(aTotal)
				nTotIni += Val(oResponse["totalizersInitial"]:GetJsonText(aTotal[nT]))
			Next

			oResponse["totalizersInitial"]["total"] := cValToChar(nTotIni)
		endIf

		aRetConsulta := GetQuery(aFil, cPeriod, cPeriodFrom, cPeriodTo, aEventQry, lForce, cEmpRequest)

		oResponse["totalizersFinal"] := JsonObject():New()
		oAuxCont["auxiliarFinal"]	 := JsonObject():New()


		For nX := 1 To Len( aEvents )
    
			ASORT(aEvents)

			If len(aEvents[nX]) > 6
				cEvent      := subsTr(aEvents[nX],7,12)
				cEvtOri     := subsTr(aEvents[nX],1,6)
			Else
				cEvent      := aEvents[nX]
				cEvtOri     := ""
			EndIf 

			nPosEvent   := aScan(__aSocRot, {|x| x[4] == cEvent })
			cTableEvent := __aSocRot[nPosEvent][3]

			WS068Event(@oResponse, cPeriod, cBranch, cTableEvent, cEvent, cPeriodFrom, cPeriodTo,.F., cEvtOri, @oAuxCont)


			cEvtOri     := ""
    	Next nX

		aTotalAux := oAuxCont["auxiliarFinal"]:GetNames()

		nTotal5001 := 0
		nTotal5003 := 0

		If Len(aTotalAux) > 0 
			For nT := 1 to Len(aTotalAux)

				If "tot5001" $ aTotalAux[nT] 
					nTotal5001 += Val(oAuxCont["auxiliarFinal"]:GetJsonText(aTotalAux[nT]))
				Else
					nTotal5003 += Val(oAuxCont["auxiliarFinal"]:GetJsonText(aTotalAux[nT]))
				EndIf 
			Next

			oResponse["totalizersFinal"]["tot5001"] := cValToChar(nTotal5001)
			oResponse["totalizersFinal"]["tot5003"] := cValToChar(nTotal5003)
		EndIf
		
		//Realiza a soma para gerar o total de totalizadores depois de realizar o Reavalir Totalizador
		aTotal := oResponse["totalizersFinal"]:GetNames()
		If Len(aTotal) > 0 
			For nT := 1 to Len(aTotal)
				nTotFin += Val(oResponse["totalizersFinal"]:GetJsonText(aTotal[nT]))
			Next

			oResponse["totalizersFinal"]["total"] := cValToChar(nTotFin)
		endIf

		oResponse["recordsReevaluated"] := JsonObject():New()
	
		nTotal := Len(aRetConsulta)

		For nI := 1 to nTotal
			SaveResult( cRequestID, oResponse:ToJson(), StrZero( nSeq, 6 ) )
			SetPercent( cRequestID, nI, nTotal )
		Next nI

	EndIf

	SetFinish( cRequestID )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} InitStatic
Inicializa as variáveis státics

@author Daniele Sakamoto
@since 29/11/2024
/*/
//-------------------------------------------------------------------
Static Function InitStatic()

    lLayAtivo := TafLayESoc(,.T.)

    If __aSocRot == Nil
       __aSocRot := TAFRotinas(,, .T., 2, lLayAtivo)
    EndIf

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} CreateTicket
@type			function
@description	Cria e armazena o ticket para a requisição
@author			Fabio Mendonça / Lucas Passos
@since			29/11/2024
@param			cBody		-	Corpo da requisição com os parâmetros desejados
@return			cRequestID	-	Identificador da Requisição
/*/
//---------------------------------------------------------------------
Static Function CreateTicket( cBody as character )

	Local oModelV3J		as object
	Local cRequestID	as character

	Default cBody	:= ""

	cRequestID	:=	FWuuId( "WSTAF068" )	

	APILogAccess("ReevaluateTotalizers")


	If cRequestID <> Nil .And. !Empty( cRequestID )

		oModelV3J	:=	FWLoadModel( "TAFA531" )
		oModelV3J:SetOperation( MODEL_OPERATION_INSERT )
		oModelV3J:Activate()

		oModelV3J:LoadValue( "MODEL_V3J", "V3J_ID"		, cRequestID 					   )
		oModelV3J:LoadValue( "MODEL_V3J", "V3J_SERVIC"	, "ReevaluateTotalizers/totValues" )
		oModelV3J:LoadValue( "MODEL_V3J", "V3J_METODO"	, "POST" 						   )
		oModelV3J:LoadValue( "MODEL_V3J", "V3J_DTREQ"	, Date() 						   )
		oModelV3J:LoadValue( "MODEL_V3J", "V3J_HRREQ"	, StrTran( Time(), ":", "" ) 	   )
		oModelV3J:LoadValue( "MODEL_V3J", "V3J_STATUS"	, "1" 							   )
		oModelV3J:LoadValue( "MODEL_V3J", "V3J_PERC"	, 1   							   )
		oModelV3J:LoadValue( "MODEL_V3J", "V3J_PARAMS"	, cBody 						   )

		FWFormCommit( oModelV3J )

		oModelV3J:DeActivate()
		oModelV3J:Destroy()

	EndIf

Return( cRequestID )

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidID
@type			function
@description	Verifica se o Identificador da Requisição é válido
@author			Daniele Sakamoto / Lucas Passos
@since			29/11/2024
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
@author			Daniele Sakamoto / Lucas Passos
@since			29/11/2024
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
/*/{Protheus.doc} HasNext
@type			function
@description	Retorna se há uma nova página de acordo com os parâmetros informados
@author			Daniele Sakamoto / Lucas Passos
@since			12/12/2024
@param			cRequestID	-	Identificador da Requisição
@param			nFinalReg	-	Identificador do último registro a ser retornado
@return			lHasNext	-	Indica se há existência de mais registros além dos retornados
/*/
//---------------------------------------------------------------------
Static Function HasNext( cRequestID as character, nFinalReg as numeric )

	Local cAliasQry	as character
	Local lHasNext	as logical

	Default cRequestID 	:= ""
	Default nFinalReg	:= 0

	cAliasQry	:=	GetNextAlias()
	lHasNext	:=	.F.


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
@author			Daniele Sakamoto / Lucas Passos
@since			29/11/2024
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
@author			Daniele Sakamoto / Lucas Passos
@since			29/11/2024
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
@author			Daniele Sakamoto / Lucas Passos
@since			29/11/2024
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

//---------------------------------------------------------------------
/*/{Protheus.doc} GetQuery
    Realiza o processso de reavaliar o totalizador

    @author Daniele Sakamoto/Lucas Passos
    @since 29/11/2024
    @version 1.0

    @param aFil 			- Idenfificador da Filial
    @param cPeriod 			- Identificador do período
	@param cPeriodFrom 		- Identificador do período De
	@param cPeriodTo 		- Identificador do período Até
    @param aEventCodes 		- Identificador dos eventos
    @param lForce 			- Identificador se será forçado o totalizador
	@param cEmpRequest 		- Identifica da empresa
    
    @return aRetConsulta - Retorna o processamento do TAFProc5Tss()
/*/
//---------------------------------------------------------------------
Static Function GetQuery(aFil as array, cPeriod as character, cPeriodFrom as character, cPeriodTo as character, aEventCodes as array, lForce as logical, cEmpRequest as Character)

    Local aRetConsulta  as array
	Local dDtIni     	as Date
    Local dDtFim    	as Date
	Local lEnd    		as Logical
	
	Default aFil			:= {}
	Default cPeriod			:= ""
	Default cPeriodFrom		:= ""
	Default cPeriodTo		:= ""
	Default aEventCodes		:= {}
	Default cId				:= ""
	Default cVersao			:= ""
	Default aResponse		:= {}

	aRetConsulta  	:= {}
    dDtIni      	:= SToD(cPeriodFrom)
    dDtFim      	:= SToD(cPeriodTo)
	lEnd    		:= .F.
	
	If lForce
		TafGrvTot(RETINFEMP(cEmpRequest,aFil), dDtIni, dDtFim, aEventCodes )
	EndIf

	aRetConsulta := TAFProc5Tss(.F., aEventCodes, '4',,, lEnd,, RETINFEMP(cEmpRequest,aFil), dDtIni, dDtFim,,,,,,,,, )
			
Return aRetConsulta

//-------------------------------------------------------------------
/*/{Protheus.doc} TafGrvTot
Força os registros a Reavaliar os totalizadores determinando período e evento.

@type function
@author Daniele Sakamoto/Lucas Passos
@since 29/11/2024
@version 1.0

@param aFiliais 	- Idenfificador da Filial
@param dDtIni 		- Identificador da data inicio 
@param dDtFim 		- Identificador da data final
@param aEvents 		- Identificador dos eventos

/*/
//-------------------------------------------------------------------
Static Function TafGrvTot( aFiliais as array, dDtIni as Date, dDtFim as Date, aEvents as Array )

	Local cQuery   as Character
	Local cUpdate  as Character
	Local cWhere   as Character
	Local lForce   as Logical
	Local nDtForce as Numeric
	Local nI       as Numeric
	Local nX       as Numeric

	Default aFiliais	:= {}
	Default dDtIni		:= ""
	Default dDtFim		:= ""
	Default aEvents		:= {}

	cQuery   := ""
	cUpdate  := ""
	cWhere   := ""
	lForce   := .T.
	nDtForce := 0
	nI       := 0
	nX       := 0


	nDtForce := dDtFim - dDtIni

	If nDtForce > 31 
		lForce := .F.
	EndIf

	If lForce

		For nI := 1 To Len(aFiliais)

			For nX := 1 To Len(aEvents)

				cUpdate := "UPDATE "+ RetSqlName( aEvents[nX][3] ) + " SET " + aEvents[nX][3] + "_GRVTOT = 'F' "
				cWhere	:= "WHERE " + aEvents[nX][3] + "_FILIAL = '" + aFiliais[nI][2] + "' "

				If aEvents[nX][3] $ "C91|T3P|T72|CUO|V7C|" //S-1200, S-1210, S-1295, S-1299 E S-2501
				
					cWhere  += "AND " + aEvents[nX][3] + "_PERAPU BETWEEN '" + SubStr(DToS(dDtIni),1,6) + "' AND '" + SubStr(DToS(dDtFim),1,6) + "' "
				
				ElseIf aEvents[nX][3] $ "CMD" //S-2299

					cWhere  += "AND " + aEvents[nX][3] + "_DTDESL BETWEEN '" + DToS(dDtIni) + "' AND '" + DToS(dDtFim) + "' "
				
				ElseIf aEvents[nX][3] $ "T92" //S-2399

					cWhere  += "AND " + aEvents[nX][3] + "_DTERAV BETWEEN '" + DToS(dDtIni) + "' AND '" + DToS(dDtFim) + "' "

				ElseIf aEvents[nX][3] $ "V9U" //S-2500
					cWhere  += "AND " + aEvents[nX][3] + "_DINSIS BETWEEN '" + DToS(dDtIni) + "' AND '" + DToS(dDtFim) + "' "
				EndIf

				cWhere	+= "AND " + aEvents[nX][3] + "_STATUS = '4' "
				cWhere	+= "AND " + aEvents[nX][3] + "_ATIVO = '1' "
				cWhere	+= "AND D_E_L_E_T_ = ' ' "

				cQuery := cUpdate + cWhere

				TCSqlExec( cQuery )

			Next nX

		Next nI

	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} WS068Event

@description Faz a query da quantidade de um determinado evento do 
             totalizador
@author Daniele Sakamoto/Lucas Passos
@since 03/12/2024
/*/
//-------------------------------------------------------------------
Static Function WS068Event(oResponse as object, cPeriod as character, cInFiliais as character, cTableEvent as character, cEvent as character, cPeriodFrom as character, cPeriodTo as character, lInitial as Logical, cEvtOri as character, oAuxCont as object)

    Local cQuery        as Character
    Local cWorkAlias    as Character
    Local cEventDesc    as Character
	Local cIdEvtOrig    as character

	Default oResponse		:= Nil
	Default oAuxCont		:= Nil
	Default cPeriod			:= ""
	Default cInFiliais		:= ""
	Default cTableEvent		:= ""
	Default cEvent			:= ""
	Default cPeriodFrom 	:= ""
	Default cPeriodTo		:= ""
	Default cEvtOri			:= ""
	Default lInitial		:= .F.

	cQuery        := ""
    cWorkAlias    := GetNextAlias()
    cEventDesc    := Posicione("C8E", 2, xFilial("C8E") + cEvent, "C8E_DESPRT")
	cIdEvtOrig    := ""

	If cEvtOri == "S-1200"
		cIdEvtOrig := "000011"
	ElseIf cEvtOri == "S-2299"
		cIdEvtOrig := "000033"
	ElseIf cEvtOri == "S-2399"
		cIdEvtOrig := "000036"
	EndIf 
    
	cQuery := " SELECT COUNT(" + cTableEvent + "_PERAPU) QTD "
	cQuery += " FROM " + RetSQLName(cTableEvent)
	cQuery += " WHERE " + cTableEvent + "_FILIAL IN ( '" + cInFiliais + "' ) "
	cQuery += " AND " + cTableEvent + "_ATIVO = '1' "

	If !Empty(cPeriod)

		If cEvent $ "S-5003|S-5013"
			cQuery += " AND " + cTableEvent + "_PERAPU = '" + Right(cPeriod, 2) + Left(cPeriod, 4) + "' "

		ElseIf cEvent $ "S-5503|"
			cQuery += " AND " + cTableEvent + "_DTRECP BETWEEN '" + cPeriodFrom + "' AND '" + cPeriodTo + "' "
		Else
			cQuery += " AND " + cTableEvent + "_PERAPU = '" + cPeriod + "' "
		EndIf

		If !Empty(cIdEvtOrig) .and. cTableEvent $ "T2M|V2P"
			cQuery += " AND " + cTableEvent + "_IDEVEN = '" + cIdEvtOrig + "' "
		EndIf 

	EndIf

	cQuery += " AND D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery( cQuery )
	TCQuery cQuery New Alias (cWorkAlias)

	buildEventInfo(@oResponse, cEvent, cEventDesc, (cWorkAlias)->QTD, lInitial, cIdEvtOrig, @oAuxCont)

	(cWorkAlias)->( dbCloseArea() )

Return


//---------------------------------------------------------------------
/*/{Protheus.doc} buildEventInfo
    Constrói bloco de informações referentes aos itens dos eventos pro retorno JSON
   
    @author Daniele Sakamoto/Lucas Passos
    @since 29/11/2024
    @version 1.0
    @param oResponse, Array de Objetos, Objeto JSON de retorno da API
    @param cEventCode, String, Código do Evento
    @param cEventDesc, String, Descrição do Evento
    @param nTotal, Numérico, Quantidade de Eventos
	@param lInitial, Lógico, Informa se é Totalizador Inicial
    @return void
/*/
//---------------------------------------------------------------------
Static Function buildEventInfo(oResponse as object, cEventCode as character, cEventDesc as character, nTotal as numeric, lInitial as Logical, cIdEvtOrig as character, oAuxCont as object)

	Local cCode  	as Character

	Default oResponse		:= Nil
	Default oAuxCont        := Nil
	Default cEventCode		:= ""
	Default cEventDesc		:= ""
	Default nTotal			:= 0
	Default lInitial		:= .F.
	Default cIdEvtOrig      := ""


	cCode := Substr(cEventCode, 3)

	If lInitial

		If Empty(cIdEvtOrig)
			oResponse["totalizersInitial"]["tot"+ cCode]    :=  cValToChar(nTotal)
		Else
			oAuxCont["auxiliarInitial"]["tot"+ cCode + "|ori" + cIdEvtOrig]	:=  cValToChar(nTotal)
		EndIf 
	Else
		If Empty(cIdEvtOrig)
			oResponse["totalizersFinal"]["tot"+ cCode]  :=  cValToChar(nTotal)
		Else
			oAuxCont["auxiliarFinal"]["tot"+ cCode + "|ori" + cIdEvtOrig]	:=  cValToChar(nTotal)
		EndIf 
	EndIf 
Return 

//---------------------------------------------------------------------
/*/{Protheus.doc} GetDetails
@type			function
@description	Retorna os registros analíticos com controle de paginação
@author			Daniele Sakamoto / Lucas Passos
@since			29/11/2024
@param			oResponse	-	Objeto Json com o retorno do resultado da requisição
@param			cRequestID	-	Identificador da Requisição
@param			nPage		-	Identificador da página solicitada
@param			nPageSize	-	Identificador do total de registros por página
/*/
//---------------------------------------------------------------------
Static Function GetDetails( oResponse as object, cRequestID as character, aSequencial as array, nPage as numeric, nPageSize as numeric )

	Local oJson		as object
	Local cAliasQry	as character
	Local cFilter	as character
	Local cPage		as character
	Local nStartReg	as numeric
	Local nFinalReg	as numeric
	Local aJson		as array
	Local lHasNext	as logical

	Default oResponse		:= Nil
	Default cRequestID		:= ""
	Default aSequencial		:=	{}
	Default nPage			:=	1
	Default nPageSize		:=	0

	oJson		:=	Nil
	cAliasQry	:=	GetNextAlias()
	cPage		:= 	"%%"
	nStartReg	:=	0
	nFinalReg	:=	0
	aJson		:=	{}
	lHasNext	:=	.F.
	cFilter		:=  "%AND V45.V45_ID = '" + cRequestID + "'%"

	If nPageSize > 0 
		nStartReg :=  (( nPage - 1 ) * nPageSize) + 1 
		nFinalReg := nPage * nPageSize
		cPage := "%WHERE LINE_NUMBER BETWEEN " + Alltrim(str(nStartReg)) + " AND " + AllTrim(str(nFinalReg)) + "%"
	EndIf

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
