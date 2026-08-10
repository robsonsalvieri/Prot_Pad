#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "RHNP06.CH"

STATIC  cMeurhLog := GetConfig("RESTCONFIG","meurhLog", "0")
Private cMRrhKeyTree := ""


WSRESTFUL Timesheet DESCRIPTION EncodeUTF8(STR0001) //"Serviço de Ponto e Abonos"

WSDATA employeeId		As String Optional
WSDATA WsNull 			As String Optional
WSDATA isDivergent    	As String Optional
WSDATA id				As String Optional
WSDATA initPeriod		As String Optional
WSDATA endPeriod		As String Optional
WSDATA referenceDate	As String Optional
WSDATA latitude     	As String Optional
WSDATA longitude    	As String Optional


//****************************** GETs ***********************************

//"Retorna o espelho de ponto do colaborador."
WSMETHOD GET clockings DESCRIPTION EncodeUTF8(STR0004) ;
PATH "/clockings/{employeeId}" PRODUCES 'application/json;charset=utf-8'

//Retorna os períodos de ponto disponíveis para o usuário.
WSMETHOD GET GetPeriods DESCRIPTION EncodeUTF8(STR0008) ;
PATH "/periods/{employeeId}" PRODUCES 'application/json;charset=utf-8'

//Saldos - Retorna os saldos de horas do período do colaborador.
WSMETHOD GET GetBalanceSummary DESCRIPTION EncodeUTF8(STR0009) ;
PATH "/balanceSummary/{employeeId}" PRODUCES 'application/json;charset=utf-8'

//Resumo do Periodo - Retorna o resumo do total das ocorrências do período do colaborador.
WSMETHOD GET GetTotSummPeriod DESCRIPTION EncodeUTF8(STR0010) ;
PATH "/occurrencesTotalSummaryPeriod/{employeeId}" PRODUCES 'application/json;charset=utf-8'

//Resumo diario - Retorna as ocorrências de ponto do colaborador.
WSMETHOD GET GetOccurrences DESCRIPTION EncodeUTF8(STR0011) ;
PATH "/occurrences/{employeeId}" PRODUCES 'application/json;charset=utf-8' ;
TTALK "v2"

//Retorna os motivos da batida.
WSMETHOD GET GetClockTypes DESCRIPTION EncodeUTF8(STR0011) ;
PATH "/clockingsReasonTypes" PRODUCES 'application/json;charset=utf-8'

//Retorna os motivos da batida com parâmetro.
WSMETHOD GET TypesClock DESCRIPTION EncodeUTF8(STR0011) ;
WSSYNTAX "/clockingsReasonTypes/{employeeId}";
PATH  "/clockingsReasonTypes/{employeeId}" PRODUCES 'application/json;charset=utf-8';

//Retorna arquivo PDF do espelho do ponto
WSMETHOD GET gFileClocking DESCRIPTION EncodeUTF8(STR0011) ;
PATH "/clockings/report/{employeeId}" PRODUCES 'application/json;charset=utf-8' ;
TTALK "v2"

//"Retorna as batidas de ponto por Geolocalização funcionário"
WSMETHOD GET geolocation DESCRIPTION EncodeUTF8(STR0017) ;
PATH "/clockingsGeolocation/{employeeId}" PRODUCES 'application/json;charset=utf-8'

//"Retorna as batidas de ponto do dia atual"
WSMETHOD GET todayClockings DESCRIPTION EncodeUTF8(STR0019) ;
PATH "/todayClockings/{employeeId}/{latitude}/{longitude}" PRODUCES 'application/json;charset=utf-8'

//"Retorna a data e hora atuais do servidor com base no fuso horário do usuário"
WSMETHOD GET currentTime DESCRIPTION EncodeUTF8(STR0020) ;
PATH "/clockingsGeolocation/currentTime/{latitude}/{longitude}" PRODUCES 'application/json;charset=utf-8'

//"Retorna os motivos para desconsiderar batidas"
WSMETHOD GET disconsider DESCRIPTION EncodeUTF8(STR0022) ;
PATH "/disconsiderReasons/" PRODUCES 'application/json;charset=utf-8'

//Método que retorna a lista das solicitações de Abono.
WSMETHOD GET GetListAllowance DESCRIPTION EncodeUTF8(STR0051) ;
PATH "/allowances/{employeeId}" PRODUCES 'application/json;charset=utf-8' ;
TTALK "v2"

//"Retorna os tipos de abonos cadastrados e disponíveis no ERP para uso no APP - MEU RH. com parâmetro employeeId"
WSMETHOD GET TypeAllowances DESCRIPTION EncodeUTF8(STR0002) ;
WSSYNTAX "/allowancesTypes/{employeeId}";
PATH  "/allowancesTypes/{employeeId}" PRODUCES 'application/json;charset=utf-8';

//"Retorna informações do arquivo de anexo da solicitação de abono"
WSMETHOD GET fInfoFileAllowance DESCRIPTION EncodeUTF8(STR0085) ;
PATH "/timesheet/allowances/file/info/{allowanceId}" PRODUCES 'application/json;charset=utf-8'

//"Retorna o arquivo de anexo da solicitação de abono"
WSMETHOD GET fDownFileAllowance DESCRIPTION EncodeUTF8(STR0086) ;
PATH "/timesheet/allowances/file/download/{allowanceId}/{fileExtension}" PRODUCES 'image/jpeg;charset=utf-8'

//"Retorna o arquivo .pdf do extrato de horas"
WSMETHOD GET GetHoursExtract DESCRIPTION EncodeUTF8(STR0114) ;
PATH "/timesheet/clockings/hoursExtract/{employeeID}" PRODUCES 'image/jpeg;charset=utf-8' ;
TTALK "v2"

//"Retorna as ocorrências de férias, afastamentos e feriados do espelho de ponto do funcionário."
WSMETHOD GET OccasionalDays ;
DESCRIPTION EncodeUTF8(STR0091) ;
WSSYNTAX "/occasionalDays/{employeeId}";
PATH  "/occasionalDays/{employeeId}" ;
PRODUCES 'application/json;charset=utf-8';

//""Retorna o horário padrão do funcionário"
WSMETHOD GET mySchedule ;
DESCRIPTION EncodeUTF8(STR0117) ;
WSSYNTAX "/clockings/mySchedule/{employeeId}";
PATH  "/clockings/mySchedule/{employeeId}" ;
PRODUCES 'application/json;charset=utf-8';

//****************************** POSTs ***********************************

//"Método que inclui uma solicitação de Abono."
WSMETHOD POST SetAllowanceRequest DESCRIPTION EncodeUTF8(STR0003) ;
PATH "/allowances/{employeeId}" PRODUCES 'application/json;charset=utf-8'

//"Inclusão de batidas do espelho de ponto."
WSMETHOD POST SetClocking DESCRIPTION EncodeUTF8(STR0004) ;
PATH "/clocking/{employeeId}" PRODUCES 'application/json;charset=utf-8' ;
TTALK "v2"

//"Inclusão de batida 373 no ponto"
WSMETHOD POST geolocation DESCRIPTION EncodeUTF8(STR0017) ;
PATH "/clockingsGeolocation/{employeeId}" PRODUCES 'application/json;charset=utf-8' ;
TTALK "v2"

//"Inclusão de batidas do espelho de ponto"
WSMETHOD POST SetVariousClockings DESCRIPTION EncodeUTF8(STR0016) ;
PATH "/clockings/{employeeId}" PRODUCES 'application/json;charset=utf-8' ;
TTALK "v2"

WSMETHOD POST GlobalClockings 	;
DESCRIPTION EncodeUTF8(STR0132)	; // "Edição global das marcações de ponto"
PATH "/globalClockings/{employeeId}";
PRODUCES 'application/json;charset=utf-8' ;
TTALK "v2"


//****************************** PUTs ***********************************

//"Atualiza as batidas de ponto por Geolocalização funcionário"
WSMETHOD PUT geolocation DESCRIPTION EncodeUTF8("") ;
PATH "/clockingsGeolocation/{employeeId}" PRODUCES 'application/json;charset=utf-8'

//"Atualiza varias batidas do espelho do ponto"
WSMETHOD PUT editVariousClockings DESCRIPTION EncodeUTF8(STR0023) ;
PATH "/clockings/{employeeId}" PRODUCES 'application/json;charset=utf-8' ;
TTALK "v2"

//"Atualiza uma batida do espelho do ponto"
WSMETHOD PUT editOneClockings DESCRIPTION EncodeUTF8(STR0028) ;
PATH "/clocking/{employeeId}/{id}" PRODUCES 'application/json;charset=utf-8' ;
TTALK "v2"

//"Atualiza uma solicitação de abono"
WSMETHOD PUT editAllowance DESCRIPTION EncodeUTF8(STR0060) ;
PATH "/allowances/{employeeId}/{id}" PRODUCES 'application/json;charset=utf-8' ;
TTALK "v2"


//****************************** DELETEs ***********************************

//"Exclusão da batida do espelho do ponto"
WSMETHOD DELETE dClocking DESCRIPTION EncodeUTF8(STR0057) ;  
WSSYNTAX "/timesheet/clocking/{employeeId}/{id}" ;
PATH "/clocking/{employeeId}/{id}" PRODUCES 'application/json;charset=utf-8'

//"Exclusão da solicitação de abono"
WSMETHOD DELETE dAllowance DESCRIPTION EncodeUTF8(STR0058) ;
WSSYNTAX "/timesheet/allowances/{employeeId}/{id}" ;
PATH "/allowances/{employeeId}/{id}" PRODUCES 'application/json;charset=utf-8'

END WSRESTFUL


WSMETHOD GET GetClockTypes PATHPARAM employeeId WSREST Timesheet

	Local oItem			:= JsonObject():New()
	Local aData			:= {}
	Local aDataLogin	:= {}
	Local cToken	 	:= ""
	Local cKeyId	 	:= ""
	Local cBranchVld	:= ""

	::SetContentType("application/json")
	::SetHeader('Access-Control-Allow-Credentials' , "true")

	cToken  	:= Self:GetHeader('Authorization')
	cKeyId  	:= Self:GetHeader('keyId')
	aDataLogin	:= GetDataLogin(cToken,,cKeyId)

	If Len(aDataLogin) > 0
		cBranchVld  := aDataLogin[5]
	EndIf

	If !Empty(cBranchVld)
		aData := fGetClockType(cEmpAnt, cBranchVld)
	EndIf

	oItem["items"] 	  := aData
	oItem["hasNext"]  := .F.

	cJson := oItem:toJson()
	::SetResponse(cJson)

Return(.T.)

WSMETHOD GET TypesClock PATHPARAM employeeId WSREST Timesheet

	Local oItem			:= JsonObject():New()
	Local aData			:= {}
	Local aDataLogin    := {}
	Local cToken	 	:= ""
	Local cKeyId	 	:= ""
	Local cMatSRA		:= ""
	Local cBranchVld	:= ""
	Local cEmp          := cEmpAnt

	::SetContentType("application/json")
	::SetHeader('Access-Control-Allow-Credentials' , "true")

	If( !Empty(Self:employeeId) .And. !("current" $ Self:employeeId) )
		aIdFunc	:= STRTOKARR( Self:employeeId, "|" )
		If Len( aIdFunc ) > 1
			cBranchVld	:= aIdFunc[1]
			cMatSRA		:= aIdFunc[2]
			cEmp	    := If( Len(aIdFunc)>2, aIdFunc[3], "" )
		EndIf
	Else
		cToken      := Self:GetHeader('Authorization')
		cKeyId  	:= Self:GetHeader('keyId')
		aDataLogin 	:= GetDataLogin(cToken, .T., cKeyId)
		If Len(aDataLogin) > 0
			cMatSRA    := aDataLogin[1]
			cBranchVld := aDataLogin[5]
		EndIf
	EndIf

	If !Empty(cEmp) .And. !Empty(cBranchVld) .And. !Empty(cMatSRA)
		aData := GetDataForJob( "13", {cEmp, cBranchVld,  Nil}, cEmp )
	EndIf

	oItem["items"] 	  := aData
	oItem["hasNext"]  := .F.

	cJson := oItem:toJson()
	::SetResponse(cJson)

Return(.T.)

// -------------------------------------------------------------------
// Retorna o arquivo PDF do espelho do ponto
// -------------------------------------------------------------------
WSMETHOD GET gFileClocking PATHPARAM employeeId WSREST Timesheet

	Local aQryParam 	:= Self:aQueryString
	Local aLog 			:= {}
	Local aIdFunc		:= {}
	Local aIdPer		:= {}
	Local aDataLogin	:= {}
	Local aProcFun		:= {}
	Local cToken		:= ""
	Local cKeyId		:= ""
	Local cIdPer		:= ""
	Local cBranchVld	:= ""
	Local cMatSRA		:= ""
	Local cLogin		:= ""
	Local cRD0Cod		:= ""
	Local cIniPer		:= ""
	Local cEndPer		:= ""
	Local cArqLocal		:= ""
	Local cFileName		:= ""
	Local cFile			:= ""
	Local cPDF			:= ".PDF"
	Local cEmpFunc		:= cEmpAnt
	Local nX			:= 0
	Local lRet			:= .T.
	Local lHabil		:= .T.
	Local lDemit		:= .F.
	Local lRobot		:= .F.
	Local lSucess		:= .F.
	Local lCentury		:= __SetCentury()
	Local cRoutine		:= "W_PWSA290.APW" //Listagem de Marcações

	DEFAULT Self:initPeriod	:= ""
	DEFAULT Self:endPeriod	:= ""
	DEFAULT Self:id			:= ""

	//Define o ano com 4 digitos
	If !lCentury
		SET CENTURY ON
	EndIf

	::SetContentType("application/json")
	::SetHeader('Access-Control-Allow-Credentials' , "true")

	cToken		:= Self:GetHeader('Authorization')
	cKeyId  	:= Self:GetHeader('keyId')

	aDataLogin := GetDataLogin(cToken, .T., cKeyId)
	If Len(aDataLogin) > 0
	cMatSRA      := aDataLogin[1]
	cBranchVld   := aDataLogin[5]
	cLogin       := aDataLogin[2]
	cRD0Cod      := aDataLogin[3]
	lDemit       := aDataLogin[6]
	EndIf

	If !( "current" $ Self:employeeId )
		aIdFunc := STRTOKARR( Self:employeeId, "|" )
		If Len(aIdFunc) > 0
			If ( cBranchVld == aIdFunc[1] .And. cMatSRA == aIdFunc[2] ) // Se for o usuário acessando seus proprios dados, valida a permissão individual
				//Valida Permissionamento
				fPermission(cBranchVld, cLogin, cRD0Cod, "downloadShareClocking", @lHabil)
				If !lHabil .Or. lDemit
					SetRestFault(400, EncodeUTF8( STR0068 )) //"Permissão negada aos serviços do espelho de ponto!"
					Return (.F.)  
				EndIf
			Else
				//Valida Permissionamento
				fPermission(cBranchVld, cLogin, cRD0Cod, "teamManagementDownloadShareClocking", @lHabil)
				If !lHabil .Or. lDemit
					SetRestFault(400, EncodeUTF8( STR0068 )) //"Permissão negada aos serviços do espelho de ponto!"
					Return (.F.)
				ElseIf getPermission(cBranchVld, cMatSRA, aIdFunc[1], aIdFunc[2], , aIdFunc[3], cRoutine)
					cBranchVld	:= aIdFunc[1]
					cMatSRA		:= aIdFunc[2]
					cEmpFunc	:= aIdFunc[3]
				Else
					SetRestFault(400, EncodeUTF8( STR0077 ) ) // Você está tentando acessar dados de um funcionário que não faz parte do seu time.
					Return (.F.)
				EndIf
			EndIf
		EndIf
	Else
		//Valida Permissionamento
		fPermission(cBranchVld, cLogin, cRD0Cod, "timesheet", @lHabil)
		If !lHabil .Or. lDemit
			SetRestFault(400, EncodeUTF8( STR0068 )) //"Permissão negada aos serviços do espelho de ponto!"
			Return (.F.)  
		EndIf
	EndIf

	//Obtem o periodo da queryparam que veio na requisicao
	If !Empty(cMatSRA) .And. !Empty(cBranchVld)

		For nX := 1 To Len( aQryParam )
			If UPPER(aQryParam[nX,1]) == "INITPERIOD"
				cIniPer := Format8601( .T., aQryParam[nX,2],,.T.)
			ElseIf UPPER(aQryParam[nX,1]) == "ENDPERIOD"
				cEndPer := Format8601( .T., aQryParam[nX,2],,.T.)
			ElseIf UPPER(aQryParam[nX,1]) == "EXECROBO"
				lRobot := .T.
			EndIf
		Next

		If !Empty(Self:id)
			cIdPer := rc4crypt( Self:id, "MeuRH#PeriodoId", .F., .T. )
			aIdPer := STRTOKARR( cIdPer, "|" )
			If Len(aIdPer) > 0
				aAdd( aProcFun, {aIdPer[1], aIdPer[2]} )
				If Val(aIdPer[3]) > 1
					aAdd( aProcFun, {cBranchVld, cMatSRA} )
				EndIf
			EndIf
		Else
			aAdd( aProcFun, {cBranchVld, cMatSRA} )		
		EndIf

		cFileName 	:= AllTrim(cBranchVld) + "_" + AllTrim(cMatSRA) + "_CLOCK_"
		cArqLocal 	:= GetSrvProfString ("STARTPATH","")

		If !(cEmpFunc == cEmpAnt)
			cFile := GetDataForJob( "5", {cEmpFunc, cBranchVld, cMatSRA, cIniPer, cEndPer, cFileName, aProcFun}, cEmpFunc )
		Else
			cFile := FileClocking( cEmpFunc, cBranchVld, cMatSRA, cIniPer, cEndPer, cFileName, aProcFun )
		EndIf

	EndIf

	//Se algum erro impediu a geracao do arquivo, faz a geracao de um arquivo PDF com a mensagem do erro.
	If Empty( cFile )

		aAdd( aLog, STR0046 ) //"Durante o processamento ocorreram erros que impediram a gravação dos dados. Contate o administrador do sistema."
		aAdd( aLog, "" )
		aAdd( aLog, STR0047 ) //"Possíveis causas do problema:"
		aAdd( aLog, "- " + STR0048 ) //"Inexistência de marcações no período solicitado."
		aAdd( aLog, "- " + STR0049 ) //"Dado incorreto no período de apontamento solicitado."

		fPDFMakeFileMessage( aLog, cFileName, @cFile )
	Else
		lSucess := .T.
	EndIf  

	//Exclui arquivos temporarios que nao foram eliminados no termino do processamento (REL/PDF) 
	fExcFileMRH( cArqLocal + cFileName + '*' )

	If lRobot
		cFile := If( lSucess, "ARQUIVO_GERADO", "")
	EndIf

	::SetHeader("Content-Disposition", "attachment; filename=" + cFileName + cPDF)
	::SetResponse(cFile)

	If !lCentury
		SET CENTURY OFF
	EndIf

Return( lRet )


WSMETHOD POST SetClocking PATHPARAM employeeId WSREST Timesheet
	
	Local oItem			:= JsonObject():New()
	Local aUrlParam		:= ::aUrlParms
	Local cBody			:= DecodeUTF8(::GetContent())
	Local cToken		:= ""
	Local cKeyId		:= ""
	Local cBranchVld	:= ""
	Local cMatSRA		:= ""
	Local cLogin		:= ""
	Local cRD0Cod		:= ""
	Local cMsgLog		:= ""
	Local cJson			:= ""
	Local cEmpFunc		:= cEmpAnt
	Local lRet			:= .F.
	Local lHabil		:= .T.
	Local lDemit		:= .F.
	Local lRobot		:= .F.
	Local aDataRet		:= {}
	Local aIdFunc		:= {}
	Local aDataLogin	:= {}

	::SetHeader('Access-Control-Allow-Credentials' , "true")
	cToken		:= Self:GetHeader('Authorization')
	cKeyId  	:= Self:GetHeader('keyId')

	aDataLogin := GetDataLogin(cToken, .T., cKeyId)
	If Len(aDataLogin) > 0
		cMatSRA      := aDataLogin[1]
		cBranchVld   := aDataLogin[5]
		cLogin       := aDataLogin[2]
		cRD0Cod      := aDataLogin[3]
		lDemit       := aDataLogin[6]
	EndIf	

	//Verifica se eh o gestor que esta fazendo a solicitacao
	If !( "current" $ Self:employeeId )
		aIdFunc := STRTOKARR( Self:employeeId, "|" )
		If Len(aIdFunc) > 0
			If ( cBranchVld == aIdFunc[1] .And. cMatSRA == aIdFunc[2] )
				//Valida Permissionamento
				fPermission(cBranchVld, cLogin, cRD0Cod, "clockingRegister", @lHabil)
				If !lHabil .Or. lDemit
					SetRestFault(400, EncodeUTF8( STR0066 )) //"Permissão negada aos serviços de marcação de ponto!"
					Return (.F.)  
				EndIf
			Else
				//Valida Permissionamento
				fPermission(cBranchVld, cLogin, cRD0Cod, "teamManagementTimesheet", @lHabil)
				If !lHabil .Or. lDemit
					SetRestFault(400, EncodeUTF8( STR0066 )) //"Permissão negada aos serviços de marcação de ponto!"
					Return (.F.)  
				EndIf
			EndIf
			cBranchVld 	:= aIdFunc[1]
			cMatSRA 	:= aIdFunc[2]
			cEmpFunc 	:= aIdFunc[3]
		EndIf
	Else
		//Valida Permissionamento
		fPermission(cBranchVld, cLogin, cRD0Cod, "clockingRegister", @lHabil)
		If !lHabil .Or. lDemit
			SetRestFault(400, EncodeUTF8( STR0066 )) //"Permissão negada aos serviços de marcação de ponto!"
			Return (.F.)  
		EndIf
	EndIf

	If cEmpFunc == cEmpAnt
		aDataRet := fSetClocking(aUrlParam, cBody, aDataLogin, aIdFunc, cBranchVld)
	Else
		aDataRet := GetDataForJob( "6", {aUrlParam, cBody, aDataLogin, aIdFunc, cBranchVld}, cEmpFunc )
	EndIf

	If Len(aDataRet) > 0
		lRet	:= aDataRet[1]
		cMsgLog	:= aDataRet[2]
		lRobot	:= aDataRet[3]
	EndIf

	If lRet
		oItem:FromJson(cBody)
		cJson := oItem:ToJson()
		::SetResponse(cJson)
	Else
		If lRobot
			lRet := .T.
			oItem["errorCode"] 		:= "400"
			oItem["errorMessage"] 	:= cMsgLog
			cJson := oItem:ToJson()
			Self:SetResponse(cJson)
		Else
			SetRestFault(400, EncodeUTF8(cMsgLog))
		EndIf
	EndIf

	FreeObj(oItem)

Return lRet



WSMETHOD GET GetOccurrences PATHPARAM employeeId WSREST Timesheet

	Local oItem		 	:= JsonObject():New()
	Local oItemDetail	:= JsonObject():New()
	Local aData			:= {}
	Local aEventos		:= {}
	Local aIdFunc		:= {}
	Local aIdPer		:= {}
	Local aDataLogin	:= {}
	Local cJson			:= ""
	Local cToken        := ""
	Local cKeyId        := ""
	Local cBranchVld	:= ""
	Local cMatSRA		:= ""
	Local cLogin		:= ""
	Local cRD0Cod		:= ""
	Local cIdPer		:= ""
	Local cEmpFunc		:= cEmpAnt
	Local nX			:= 0
	Local nSaldo		:= 0
	Local lSexagenal	:= .T. //SuperGetMv("MV_HORASDE",, "N") == "S" //Desabilitado porque o App existe somente sexagenal
	Local lDemit      := .F.
	Local lHabil      := .T.
	Local cRoutine 		:= "W_PWSA290.APW" //Listagem de Marcações

	DEFAULT Self:referenceDate	:= Ctod("//")
	DEFAULT Self:id				:= ""

	Self:SetHeader('Access-Control-Allow-Credentials' , "true")

	cToken		:= Self:GetHeader('Authorization')
	cKeyId  	:= Self:GetHeader('keyId')

	aDataLogin := GetDataLogin(cToken, .T., cKeyId)
	If Len(aDataLogin) > 0
		cMatSRA    := aDataLogin[1]
		cLogin     := aDataLogin[2]
		cRD0Cod    := aDataLogin[3]
		cBranchVld := aDataLogin[5]
		lDemit     := aDataLogin[6]
	EndIf

	If !( "current" $ Self:employeeId )
		aIdFunc := STRTOKARR( Self:employeeId, "|" )
		If Len(aIdFunc) > 0
			If ( cBranchVld	== aIdFunc[1] .And. cMatSRA	== aIdFunc[2] )
				//Valida Permissionamento
				fPermission(cBranchVld, cLogin, cRD0Cod, "timesheet", @lHabil, cMatSRA, .T.)
				If !lHabil .Or. lDemit
					SetRestFault(400, EncodeUTF8( STR0068 )) //"Permissão negada aos serviços do espelho de ponto!"
					Return (.F.)  
				EndIf
			Else
				//Valida Permissionamento
				fPermission(cBranchVld, cLogin, cRD0Cod, "teamManagementTimesheet", @lHabil)
				If !lHabil .Or. lDemit
					SetRestFault(400, EncodeUTF8( STR0068 )) //"Permissão negada aos serviços do espelho de ponto!"
					Return (.F.)  
				ElseIf getPermission(cBranchVld, cMatSRA, aIdFunc[1], aIdFunc[2], , aIdFunc[3], cRoutine)
					cBranchVld	:= aIdFunc[1]
					cMatSRA		:= aIdFunc[2]
					cEmpFunc	:= aIdFunc[3]
				Else
					SetRestFault(400, EncodeUTF8( STR0077 )) //"Você está tentando acessar dados de um funcionário que não faz parte do seu time."
					Return (.F.)
				EndIf
			EndIf
		EndIf
	Else
		//Valida Permissionamento
		fPermission(cBranchVld, cLogin, cRD0Cod, "timesheet", @lHabil, cMatSRA, .T.)
		If !lHabil .Or. lDemit
			SetRestFault(400, EncodeUTF8( STR0068 )) //"Permissão negada aos serviços do espelho de ponto!"
			Return (.F.)  
		EndIf
	EndIf

	If !Empty(Self:referenceDate)

		If !Empty(Self:id)
			cIdPer := rc4crypt( Self:id, "MeuRH#PeriodoId", .F., .T. )
			aIdPer := STRTOKARR( cIdPer, "|" )
			If Len(aIdPer) > 0
				cBranchVld := aIdPer[1]
				cMatSRA := aIdPer[2]			
			EndIf
		EndIf	
		
		aEventos := fSumOccurPer( cEmpFunc, cBranchVld, cMatSRA, Self:referenceDate, Self:referenceDate, lSexagenal )
		
		If !Empty(aEventos)
			
			For nX := 1 To Len(aEventos)
				nSaldo := aEventos[nX,3]
				nSaldo := If( lSexagenal, nSaldo, fConvHr( nSaldo, "D", .T., 2 ) )
				oItemDetail	:= JsonObject():New()
				oItemDetail["id"] 				:= cValToChar(nX)
				oItemDetail["date"] 			:= Self:referenceDate
				oItemDetail["referenceDate"]	:= Self:referenceDate
				oItemDetail["total"]			:= HourToMs( StrZero(nSaldo,5,2) ) 
				oItemDetail["description"] 		:= EncodeUTF8(aEventos[nX,2])
				aAdd( aData, oItemDetail )				
			Next nX

		EndIf
		
	EndIf

	oItem["hasNext"] 	:= CtoD( Format8601(.T.,Self:initPeriod) )
	oItem["items"]		:= aData

	cJson := oItem:ToJson()
	::SetResponse(cJson)

Return(.T.)


WSMETHOD GET GetTotSummPeriod PATHPARAM employeeId WSREST Timesheet

	Local oItem		 	:= JsonObject():New()
	Local oItemDetail	:= JsonObject():New()
	Local aData			:= {}
	Local aDataLogin	:= {}
	Local aEventos		:= {}
	Local aIdPer		:= {}
	Local cJson			:= ""
	Local cToken		:= ""
	Local cBranchVld	:= ""
	Local cMatSRA		:= ""
	Local cIdPer		:= ""
	Local cEmpFunc		:= cEmpAnt
	Local nX			:= 0
	Local nSaldo		:= 0
	Local lSexagenal	:= .T. //SuperGetMv("MV_HORASDE",, "N") == "S" //Desabilitado porque o App existe somente sexagenal

	DEFAULT Self:initPeriod	:= ""
	DEFAULT Self:endPeriod	:= ""
	DEFAULT Self:id			:= ""

	Self:SetHeader('Access-Control-Allow-Credentials' , "true")

	If !Empty(Self:initPeriod) .And. !Empty(Self:endPeriod)
		
		If ( "current" $ Self:employeeId )
			cToken		:= Self:GetHeader('Authorization')
			cKeyId  	:= Self:GetHeader('keyId')
			aDataLogin 	:= GetDataLogin(cToken,,cKeyId)

			If Len(aDataLogin) > 0
				cMatSRA     := aDataLogin[1]
				cBranchVld  := aDataLogin[5]
			EndIf
		Else
			aIdFunc := STRTOKARR(Self:employeeId, "|")
			If Len(aIdFunc) > 0
				cBranchVld := aIdFunc[1]
				cMatSRA	   := aIdFunc[2]
				cEmpFunc   := aIdFunc[3]
			EndIf
		EndIf

		If !Empty(Self:id)
			cIdPer := rc4crypt( Self:id, "MeuRH#PeriodoId", .F., .T. )
			aIdPer := STRTOKARR( cIdPer, "|" )
			If Len(aIdPer) > 0
				cBranchVld := aIdPer[1]
				cMatSRA := aIdPer[2]			
			EndIf
		EndIf	
		
		aEventos := fSumOccurPer( cEmpFunc, cBranchVld, cMatSRA, Self:initPeriod, Self:endPeriod, lSexagenal )
		
		If !Empty(aEventos)
			
			For nX := 1 To Len(aEventos)
				nSaldo := aEventos[nX,3]
				nSaldo := If( lSexagenal, nSaldo, fConvHr( nSaldo, "D", .T., 2 ) )
				oItemDetail	:= JsonObject():New()
				oItemDetail["id"] 			:= cValToChar(nX)
				oItemDetail["description"] 	:= EncodeUTF8(aEventos[nX,2])
				oItemDetail["value"]		:= If(nSaldo < 100.00, StrTran( StrZero(nSaldo,5,2), ".", ":" ), StrTran( StrZero(nSaldo,6,2), ".", ":" )) 
				aAdd( aData, oItemDetail )				
			Next nX

		EndIf
		
	EndIf

	oItem["initPeriod"] 				:= Self:initPeriod
	oItem["endPeriod"]  				:= Self:endPeriod
	oItem["occurrencesTotalSummary"]	:= aData

	cJson := oItem:ToJson()
	Self:SetResponse(cJson)

Return(.T.)


WSMETHOD GET GetBalanceSummary PATHPARAM employeeId WSREST Timesheet

	Local oItem		 	:= JsonObject():New()
	Local aEventos		:= {}
	Local aIdFunc		:= {}
	Local aDataLogin    := {}
	Local cJson			:= ""
	Local cToken		:= ""
	Local cKeyId		:= ""
	Local cBranchVld	:= ""
	Local cMatSRA		:= ""
	Local cIniPer		:= ""
	Local cFimPer		:= ""
	Local cRD0Cod       := ""
	Local cLogin        := ""
	Local cRoutine 		:= "W_PWSA300.APW" //Banco de horas
	Local cEmpAtu		:= cEmpAnt
	Local lHabil        := .T.

	::SetHeader('Access-Control-Allow-Credentials' , "true")

	DEFAULT Self:initPeriod	:= ""
	DEFAULT Self:endPeriod	:= ""

	cToken		:= Self:GetHeader('Authorization')
	cKeyId  	:= Self:GetHeader('keyId')
	aDataLogin := GetDataLogin(cToken, .T., cKeyId)
	If Len(aDataLogin) > 0
	cMatSRA    := aDataLogin[1]
	cLogin     := aDataLogin[2]
	cRD0Cod    := aDataLogin[3]
	cBranchVld := aDataLogin[5]
	EndIf

	// Valida permissão ao saldo do banco de horas.
	fPermission(cBranchVld, cLogin, cRD0Cod, "balanceSummary", @lHabil)

	If !Empty(cBranchVld) .And. !Empty(cMatSRA) .And. lHabil

		//Atualiza as variáveis, caso seja acesso do gestor e verifica permissões.
		If !( "current" $ Self:employeeId )
			aIdFunc := STRTOKARR( Self:employeeId, "|" )
			If Len(aIdFunc) > 0
				If getPermission(cBranchVld, cMatSRA, aIdFunc[1], aIdFunc[2], , aIdFunc[3], cRoutine)
					cBranchVld	:= aIdFunc[1]
					cMatSRA		:= aIdFunc[2]
					cEmpAtu		:= aIdFunc[3]
				Else
					lHabil := .F.				
				EndIf
			EndIf
		EndIf

		If lHabil
			//Se nao vier o periodo na requisicao considera o que estiver aberto no ponto
			If Empty(Self:initPeriod) .Or. Empty(Self:endPeriod) 
				aPeriods := GetDataForJob( "1", {cBranchVld, cMatSRA, Nil}, cEmpAtu )
				If Len(aPeriods) > 0
					cIniPer := dToS( aPeriods[1,1] )
					cFimPer := dToS( aPeriods[1,2] )
				EndIf
			Else
				cIniPer := Self:initPeriod
				cFimPer := Self:endPeriod		
			EndIf
			
			aEventos := GetDataForJob( "4", {cBranchVld, cMatSRA, cIniPer, cFimPer, .T.}, cEmpAtu )
			
			If !Empty(aEventos)
				oItem["previous"] := HourToMs( cValToChar( Abs(aEventos[1]) ) ) * If( aEventos[1] > 0, 1, -1 )
				oItem["current"]  := HourToMs( cValToChar( Abs(aEventos[3]) ) ) * If( aEventos[3] > 0, 1, -1 )
				oItem["next"] 	  := HourToMs( cValToChar( Abs(aEventos[2]) ) ) * If( aEventos[2] > 0, 1, -1 )
			EndIf		
		EndIf
	EndIf

	cJson := oItem:toJson()
	::SetResponse(cJson)

Return(.T.)


WSMETHOD GET GetPeriods PATHPARAM employeeId WSREST Timesheet

	Local oItem		 	:= NIL
	Local oItemDetail	:= NIL
	Local oMessages	  	:= NIL
	Local cJson			:= ""
	Local cIdPer		:= ""
	Local cMatSRA		:= ""
	Local cBranchVld	:= ""
	Local cToken	  	:= ""
	Local cKeyId	  	:= ""
	Local cEmpAtu		:= cEmpAnt
	Local aQryParam		:= Self:aQueryString
	Local aData			:= {}
	Local aPerAux		:= {}
	Local aPeriods		:= {}
	Local aMessages		:= {}
	Local aIdFunc		:= {}
	Local aTransf		:= {}
	Local aDataLogin	:= {}
	Local nLenQP		:= Len(aQryParam)
	Local initPeriod    := Ctod("//")
	Local endPeriod     := Ctod("//")
	Local nPer			:= 0
	Local nX			:= 0
	Local lAuth    		:= .T.
	Local lTransFil		:= .F.
	Local lPerAtual		:= .F.

	Private dDtRobot    := cTod("//")

	::SetHeader('Access-Control-Allow-Credentials' , "true")

	If ( "current" $ Self:employeeId )
		cToken  := Self:GetHeader('Authorization')
		cKeyId 	:= Self:GetHeader('keyId')
		aDataLogin := GetDataLogin(cToken, .T., cKeyId)
		If Len(aDataLogin) > 0
			cMatSRA    := aDataLogin[1]
			cBranchVld := aDataLogin[5]
		EndIf
	Else
		aIdFunc := STRTOKARR( Self:employeeId, "|" )
		If Len(aIdFunc) > 0
			cBranchVld := aIdFunc[1]
			cMatSRA	   := aIdFunc[2]
			cEmpAtu	   := aIdFunc[3]
		EndIf
	EndIf

	If Empty(cMatSRA) .Or. Empty(cBranchVld)
		oMessages := JsonObject():New()
		oMessages["type"]   := "error"
		oMessages["code"]   := "401"
		oMessages["detail"] := EncodeUTF8(STR0006) //"Dados inválidos."

		Aadd(aMessages,oMessages)
		lAuth := .F.
	EndIf

	//Obtem a data do queryparam que existe apenas na automação de testes
	If nLenQP > 0
		For nX := 1 To nLenQP
			If UPPER(aQryParam[nX,1]) == "DDATEROBOT"
				dDtRobot := sToD( aQryParam[nX,2] )
			EndIf
		Next
	EndIf

	aPerAux	:= GetDataForJob( "1", {cBranchVld, , 6}, cEmpAtu )
	nPer	:= Len(aPerAux)
	aIdFunc := {cBranchVld, cMatSRA, cEmpAtu}

	If nPer > 0 .And. fTransfFil( @aTransf )
		//Ordena as transferencias por data a partir da mais recente
		ASORT(aTransf, , , { | x,y | x[7] > y[7] } )
		For nX := 1 To Len(aTransf)
			//Se houve transferência de filial ou matrícula em data igual ou superior ao periodo mais antigo exibido no Meu RH
			If aTransf[nX,2] <> aTransf[nX,5] .And. aTransf[nX,7] >= aPerAux[1,1]
				lTransFil := .T.
				Exit
			EndIf
		Next nX
	EndIf

	For nX := 1 To nPer
		cIdPer		:= ""
		initPeriod 	:= aPerAux[nX,1]
		endPeriod   := aPerAux[nX,2]
		lPerAtual	:= nX == nPer

		//Verifica se o range de períodos será alterado conforme os dados de transferencia
		If lTransFil
			cIdPer  := fChkPerTransf( aIdFunc, @initPeriod, @endPeriod, aTransf, @aPeriods, lPerAtual )
		EndIf

		aAdd( aPeriods, {initPeriod, endPeriod, lPerAtual, cIdPer} )
	Next nX

	ASORT(aPeriods, , , { | x,y | x[1] < y[1] } )

	nPer := Len(aPeriods)

	For nX := 1 To nPer
		oItemDetail					:= JsonObject():New()
		oItemDetail["initDate"]		:= formatGMT( DTOC(aPeriods[nX,1]) )
		oItemDetail["endDate"]		:= formatGMT( DTOC(aPeriods[nX,2]) )
		oItemDetail["actualPeriod"]	:= aPeriods[nX,3]
		oItemDetail["id"]			:= aPeriods[nX,4]
		aAdd( aData, oItemDetail )
	Next nX

	oItem := JsonObject():New()
	oItem["items"] 	  := aData
	oItem["hasNext"]  := .F.

	cJson := oItem:ToJson()
	::SetResponse(cJson)

	FreeObj(oItem)
	FreeObj(oItemDetail)

Return(.T.)


WSMETHOD GET TypeAllowances WSREST Timesheet

	Local oItem			:= JsonObject():New()
	Local aData			:= {}
	Local aDataLogin	:= {}
	Local cEmp          := cEmpAnt
	Local cToken		:= ""
	Local cKeyId		:= ""
	Local cBranchVld	:= ""

	::SetContentType("application/json")
	::SetHeader('Access-Control-Allow-Credentials' , "true")

	If( !Empty(Self:employeeId) .And. !("current" $ Self:employeeId) )
		aIdFunc	:= STRTOKARR( Self:employeeId, "|" )
		If Len( aIdFunc ) > 1
			cBranchVld	:= aIdFunc[1]
			cEmp	    := If( Len(aIdFunc) > 2, aIdFunc[3], "" )
		EndIf
	Else
		cToken      := Self:GetHeader('Authorization')
		cKeyId 		:= Self:GetHeader('keyId')
		aDataLogin 	:= GetDataLogin(cToken, .T., cKeyId)
		If Len(aDataLogin) > 0
			cBranchVld := aDataLogin[5]
		EndIf
	EndIf

	If !Empty(cEmp) .And. !Empty(cBranchVld)
		aData := GetDataForJob( "14", {cEmp, cBranchVld}, cEmp )
	EndIf

	oItem["items"] 	  := aData
	oItem["hasNext"]  := .T.

	cJson := oItem:ToJson()
	::SetResponse(cJson)

Return(.T.)


WSMETHOD GET GetListAllowance PATHPARAM employeeId WSREST Timesheet
	Local oItem			:= JsonObject():New()
	Local aData			:= {}
	Local aDataLogin	:= {}
	Local cJson			:= ""
	Local cPage			:= ""
	Local cPageSize		:= ""
	Local cStatus		:= ""
	Local cToken        := ""
	Local cKeyId        := ""
	Local cLogin		:= ""
	Local cBranchVld	:= ""
	Local cMatSRA		:= ""
	Local cRD0Cod		:= ""
	Local cEmpFunc		:= cEmpAnt
	Local nX			:= 0
	Local nTipo			:= 3
	Local lNext        	:= .F.
	Local lDemit        := .F.
	Local lHabil        := .T.
	Local aIdFunc       := {}
	Local aQryParam		:= Self:aQueryString
	Local cRoutine		:= "W_PWSA160.APW" //Justificativas pré-abono

	Self:SetHeader('Access-Control-Allow-Credentials' , "true")

	cToken		:= Self:GetHeader('Authorization')
	cKeyId 		:= Self:GetHeader('keyId')

	aDataLogin := GetDataLogin(cToken, .T., cKeyId)
	If Len(aDataLogin) > 0
	cMatSRA    := aDataLogin[1]
	cLogin     := aDataLogin[2]
	cRD0Cod    := aDataLogin[3]
	cBranchVld := aDataLogin[5]
	lDemit     := aDataLogin[6]
	EndIf

	If Len(::aUrlParms) > 0 .And. !Empty(::aUrlParms[2]) .And. !("current" $ ::aUrlParms[2])
		aIdFunc := STRTOKARR( ::aUrlParms[2], "|" )
		If Len(aIdFunc) > 1
			If ( cBranchVld	== aIdFunc[1] .And. cMatSRA == aIdFunc[2] )
				//Valida Permissionamento
				fPermission(cBranchVld, cLogin, cRD0Cod, "allowance", @lHabil)
				If !lHabil .Or. lDemit
					SetRestFault(400, EncodeUTF8( STR0065 )) //"Permissão negada aos serviços de abono!"
					Return (.F.)  
				EndIf
			Else
				//Valida Permissionamento
				fPermission(cBranchVld, cLogin, cRD0Cod, "teamManagementAllowance", @lHabil)
				If !lHabil .Or. lDemit
					SetRestFault(400, EncodeUTF8( STR0065 )) //"Permissão negada aos serviços de abono!"
					Return (.F.) 
				//valida se o solicitante da requisição pode ter acesso as informações
				ElseIf getPermission(cBranchVld, cMatSRA, aIdFunc[1], aIdFunc[2], , aIdFunc[3], cRoutine)
					cBranchVld	:= aIdFunc[1]
					cMatSRA		:= aIdFunc[2]
					cEmpFunc 	:= aIdFunc[3]
				Else
					SetRestFault(400, EncodeUTF8( STR0077 )) //"Você está tentando acessar dados de um funcionário que não faz parte do seu time."
					Return (.F.)
				EndIf
			EndIf	
		EndIf
	Else
		//Valida Permissionamento
		fPermission(cBranchVld, cLogin, cRD0Cod, "allowance", @lHabil)
		If !lHabil .Or. lDemit
			SetRestFault(400, EncodeUTF8( STR0065 )) //"Permissão negada aos serviços de abono!"
			Return (.F.)  
		EndIf
	EndIf

	If !Empty(cBranchVld) .And. !Empty(cMatSRA)
		For nX := 1 To Len( aQryParam )
			Do Case
				Case UPPER(aQryParam[nX,1]) == "PAGE"
					cPage		:= aQryParam[nX,2] 
				Case UPPER(aQryParam[nX,1]) == "PAGESIZE"
					cPageSize	:= aQryParam[nX,2]
				Case UPPER(aQryParam[nX,1]) == "STATUS"
					cStatus		:= aQryParam[nX,2]
			End Case
		Next

		//1 = Pendentes de aprovacao (status pending)
		//2 = Aprovados ou Reprovados (status notpending)
		//3 = Todos (status vazio)
		nTipo := If( Empty(cStatus), 3, If( cStatus == "notpending", 2, 1 ) )
		
		aData := fGetListAllowance( nTipo, cBranchVld, cMatSRA, cEmpFunc, Nil, cPage, cPageSize, @lNext, aDataLogin ) 
	EndIf

	oItem["hasNext"]  := lNext
	oItem["items"]    := aData

	cJson := oItem:ToJson()
	Self:SetResponse(cJson)

	FreeObj(oItem)

Return (.T.)


WSMETHOD GET fInfoFileAllowance WSREST Timesheet

	Local oItem      := JsonObject():New()
	Local aUrlParam  := Self:aUrlParms
	Local nLenParms  := Len(aUrlParam)
	Local cNameArq   := ""
	Local cType      := ""
	Local cMsg       := ""
	Local cId        := ""
	Local cFilRH3    := ""
	Local cCodRH3    := ""
	Local cToken     := ""
	Local cKeyId     := ""
	Local cBranchVld := ""
	Local cMatSRA    := ""
	Local cLogin     := ""
	Local cRD0Cod	 := ""
	Local aDataLogin := {}
	Local lRet		 := .T.

	Self:SetHeader('Access-Control-Allow-Credentials', "true")

	cToken		:= Self:GetHeader('Authorization')
	cKeyId 		:= Self:GetHeader('keyId')
	aDataLogin 	:= GetDataLogin(cToken, .T., cKeyId)
	If Len( aDataLogin ) > 0
		cMatSRA     := aDataLogin[1]
		cLogin		:= aDataLogin[2]
		cRD0Cod		:= aDataLogin[3]
		cBranchVld	:= aDataLogin[5]
		lDemit      := aDataLogin[6]
	EndIf

	If nLenParms == 4 .And. !Empty(aUrlParam[4])
		cId      := rc4crypt( aUrlParam[4], "MeuRH#Allowance", .F., .T. )
		aIdFunc  := STRTOKARR( cId, "|" )
		If Len(aIdFunc) >= 4
			cFilRH3 := aIdFunc[1]
			cCodRH3 := aIdFunc[4]
		EndIf				
	EndIf

	If !Empty(cFilRH3) .And. !Empty(cCodRH3)

		//Dados do anexo a partir do banco de conhecimento
		cRet := fInfBcoFile( 1, cFilRH3, cCodRH3, cBranchVld, cMatSRA, @cNameArq, @cType, @cMsg )
		
		//Dados do anexo a partir do repositorio de imagens (quando nao localiza no BC p/ nao afetar o historico)
		If Empty(cRet)
			cMsg := ""
			cRet := fMedImg( 1, cFilRH3, cCodRH3, cBranchVld, cMatSRA, @cNameArq, @cType, @cMsg )
		EndIf
		
		lRet := Empty(cMsg)
	Else
		cMsg := EncodeUTF8( STR0061 ) //"Informações da requisição não recebida"
		lRet := .F.
	EndIf

	If lRet
		oItem["type"]    := cType
		oItem["name"]    := cNameArq
		oItem["content"] := cRet

		cJson := oItem:ToJson()
		Self:SetResponse(cJson)
	Else
		SetRestFault(400, cMsg)
	EndIf

	FreeObj(oItem)

Return( lRet )


WSMETHOD GET fDownFileAllowance WSREST Timesheet

	Local aUrlParam  := Self:aUrlParms
	Local nLenParms  := Len(aUrlParam)
	Local cNameArq   := ""
	Local cType      := ""
	Local cMsg       := ""
	Local cId        := ""
	Local cFilRH3    := ""
	Local cCodRH3    := ""
	Local cToken     := ""
	Local cKeyId     := ""
	Local cBranchVld := ""
	Local cMatSRA    := ""
	Local cLogin     := ""
	Local cRD0Cod	 := ""
	Local cRoutine   := "viewAttachmentAllowance"
	Local aArea      := {}
	Local aDataLogin := {}
	Local aIdFunc    := {}	
	Local lRet		 := .T.
	Local lHabil     := .T.
	Local lDemit     := .F.

	Self:SetHeader('Access-Control-Allow-Credentials', "true")

	cToken		:= Self:GetHeader('Authorization')
	cKeyId 		:= Self:GetHeader('keyId')
	aDataLogin 	:= GetDataLogin(cToken, .T., cKeyId)
	If Len( aDataLogin ) > 0
		cMatSRA     := aDataLogin[1]
		cLogin		:= aDataLogin[2]
		cRD0Cod		:= aDataLogin[3]
		cBranchVld	:= aDataLogin[5]
		lDemit     := aDataLogin[6]
	EndIf

	If nLenParms >= 4 .And. !Empty(aUrlParam[4])
		cId		:= rc4crypt( aUrlParam[4], "MeuRH#Allowance", .F., .T. )
		aIdFunc	:= STRTOKARR( cId, "|" )
		cFilRH3 := aIdFunc[1]
		cCodRH3 := aIdFunc[4]
	EndIf

	If !Empty(cFilRH3) .And. !Empty(cCodRH3)

		aArea := GetArea()
		DbSelectArea("RH3")
		DbSetOrder(1)
		If RH3->( dbSeek( cFilRH3 + cCodRH3 ) )
			//Verifica se o anexo esta sendo acessado pelo gestor
			If !(RH3->RH3_FILIAL+RH3_MAT+RH3_EMP) == (cBranchVld+cMatSRA+cEmpAnt)
				cRoutine := "teamManagementViewAttachmentAllowance"
			EndIf
		EndIf

		//Valida Permissionamento
		fPermission(cBranchVld, cLogin, cRD0Cod, cRoutine, @lHabil)
		If !lHabil .Or. lDemit
			SetRestFault(400, EncodeUTF8( STR0084 )) //"Permissão negada aos serviços de anexo do abono"
			RestArea(aArea)
			Return (.F.)
		EndIf

		//Dados do anexo a partir do banco de conhecimento
		cRet := fInfBcoFile( 2, cFilRH3, cCodRH3, cBranchVld, cMatSRA, @cNameArq, @cType, @cMsg )
		
		//Dados do anexo a partir do repositorio de imagens (quando nao localiza no BC p/ nao afetar o historico)
		If Empty(cRet)
			cMsg := ""
			cRet := fMedImg( 2, cFilRH3, cCodRH3, cBranchVld, cMatSRA, @cNameArq, @cType, @cMsg )
		EndIf

		lRet := Empty(cMsg)
		RestArea(aArea)
	Else
		cMsg := EncodeUTF8( STR0061 ) //"Informações da requisição não recebida"
		lRet := .F.
	EndIf

	If lRet
		Self:SetHeader("Content-Disposition", "attachment; filename=" + cNameArq )
		Self:SetResponse(cRet)
	Else
		SetRestFault(400, cMsg)
	EndIf

Return( lRet )


WSMETHOD POST SetAllowanceRequest PATHPARAM employeeId WSREST Timesheet

	Local cBody			:= ::GetContent()
	Local aUrlParam		:= ::aUrlParms
	Local oItem			:= JsonObject():New()
	Local oItemDetail	:= JsonObject():New()
	Local cJson			:= ""
	Local cStatus		:= ""
	Local cToken		:= ""
	Local cKeyId		:= ""
	Local cBranchVld	:= ""
	Local cMatSRA		:= ""
	Local cLogin		:= ""
	Local cRD0Cod		:= ""
	Local lHabil		:= .T.
	Local lDemit		:= .F.
	Local aDataLogin	:= {}
	Local aIdFunc		:= {}
	Local cRoutine		:= "W_PWSA160.APW" //Justificativas pré-abono

	::SetHeader('Access-Control-Allow-Credentials' , "true")

	cToken		:= Self:GetHeader('Authorization')
	cKeyId 		:= Self:GetHeader('keyId')

	aDataLogin := GetDataLogin(cToken, .T., cKeyId)
	If Len(aDataLogin) > 0
	cMatSRA      := aDataLogin[1]
	cBranchVld   := aDataLogin[5]
	cLogin       := aDataLogin[2]
	cRD0Cod      := aDataLogin[3]
	lDemit       := aDataLogin[6]
	EndIf

	//Verifica se eh o gestor que esta fazendo a solicitacao
	If !( "current" $ Self:employeeId )
		aIdFunc := STRTOKARR( Self:employeeId, "|" )
		If Len(aIdFunc) > 0
			If ( cBranchVld == aIdFunc[1] .And. cMatSRA == aIdFunc[2] )
				//Valida Permissionamento
				fPermission(cBranchVld, cLogin, cRD0Cod, "allowance", @lHabil)
				If !lHabil .Or. lDemit
					SetRestFault(400, EncodeUTF8( STR0065 )) //"Permissão negada aos serviços de abono!"
					Return (.F.)  
				EndIf
			Else
				//Valida Permissionamento
				fPermission(cBranchVld, cLogin, cRD0Cod, "teamManagementAllowance", @lHabil)
				If !lHabil .Or. lDemit
					SetRestFault(400, EncodeUTF8( STR0065 )) //"Permissão negada aos serviços de abono!"
					Return (.F.)  
				ElseIf !getPermission(cBranchVld, cMatSRA, aIdFunc[1], aIdFunc[2], , aIdFunc[3], cRoutine)
					SetRestFault(400, EncodeUTF8( STR0077 )) //"Você está tentando acessar dados de um funcionário que não faz parte do seu time."
					Return (.F.)  
				EndIf
			EndIf
		EndIf
	Else
		//Valida Permissionamento
		fPermission(cBranchVld, cLogin, cRD0Cod, "allowance", @lHabil)
		If !lHabil .Or. lDemit
			SetRestFault(400, EncodeUTF8( STR0065 )) //"Permissão negada aos serviços de abono!"
			Return (.F.)  
		EndIf
	EndIf

	AllowanceRequest(aUrlParam,DecodeUTF8(cBody),@oItem,@oItemDetail,cToken,@cStatus,aIdFunc,cKeyId)

	If !Empty(cStatus)
		::SetHeader('Status', cStatus)
	EndIf

	cJson := oItem:ToJson()
	::SetResponse(cJson)

Return (.T.)


WSMETHOD GET clockings PATHPARAM employeeId WSREST Timesheet

	Local oItem		 	:= JsonObject():New()
	Local oMessages	  	:= JsonObject():New()
	Local nX			:= 0
	Local nY			:= 0
	Local lAuth    		:= .T.
	Local lDemit      	:= .F.
	Local lHabil      	:= .T.
	Local lDivergent	:= .F.
	Local lOnlyDiv 		:= .F.
	Local cToken        := ""
	Local cKeyId        := ""
	Local cIdPer		:= ""
	Local cBranchVld	:= ""
	Local cMatSRA		:= ""
	Local cLogin		:= ""
	Local cRD0Cod		:= ""
	Local cWsName		:= ""
	Local cEmpAtu		:= cEmpAnt
	Local aDataLogin	:= {}
	Local aMessages		:= {}
	Local aIdFunc		:= {}
	Local aData			:= {}
	Local aDataAux		:= {}
	Local aPeriods		:= {}
	Local aIdPer		:= {}
	Local aProcFun		:= {}
	Local initPeriod    := StoD( Format8601(.T.,Self:initPeriod,,.T.) )
	Local endPeriod     := StoD( Format8601(.T.,Self:endPeriod,,.T.) )
	Local aQryParam		:= Self:aQueryString
	Local cRoutine		:= "W_PWSA290.APW" //Listagem de Marcações

	DEFAULT Self:id		:= ""

	::SetHeader('Access-Control-Allow-Credentials' , "true")

	cToken		:= Self:GetHeader('Authorization')
	cKeyId 		:= Self:GetHeader('keyId')

	aDataLogin := GetDataLogin(cToken, .T., cKeyId)
	If Len(aDataLogin) > 0
		cMatSRA    := aDataLogin[1]
		cLogin     := aDataLogin[2]
		cRD0Cod    := aDataLogin[3]
		cBranchVld := aDataLogin[5]
		lDemit     := aDataLogin[6]
	EndIf

	//Obtem o periodo da queryparam que veio na requisicao
	For nX := 1 To Len( aQryParam )
		If UPPER(aQryParam[nX,1]) == "ISDIVERGENT"
			lDivergent := UPPER(aQryParam[nX,2]) == "TRUE"
		ElseIf UPPER(aQryParam[nX,1]) == "ISONLYDIVERGENCES"
			lOnlyDiv := UPPER(aQryParam[nX,2]) == "TRUE"
		EndIf
	Next

	If !( "current" $ Self:employeeId )
		aIdFunc := STRTOKARR( Self:employeeId, "|" )
		If Len(aIdFunc) > 0
			If ( cBranchVld	== aIdFunc[1] .And. cMatSRA	== aIdFunc[2] .And. cEmpAtu == aIdFunc[3])
				//Valida Permissionamento
				cWsName := If( lDivergent, "divergentClockingView", "timesheet" )
				fPermission(cBranchVld, cLogin, cRD0Cod, cWsName, @lHabil)
				If !lHabil .Or. lDemit
					SetRestFault(400, EncodeUTF8( STR0068 )) //"Permissão negada aos serviços do espelho de ponto!"
					Return (.F.)  
				EndIf
			Else
				//Valida Permissionamento
				cWsName := If( lDivergent, "teamManagementDivergentClockingView", "teamManagementTimesheet" )
				fPermission(cBranchVld, cLogin, cRD0Cod, cWsName, @lHabil, cMatSRA)
				If !lHabil .Or. lDemit
					SetRestFault(400, EncodeUTF8( STR0068 )) //"Permissão negada aos serviços do espelho de ponto!"
					Return (.F.)  
				ElseIf getPermission(cBranchVld, cMatSRA, aIdFunc[1], aIdFunc[2], , aIdFunc[3], cRoutine)
					cBranchVld	:= aIdFunc[1]
					cMatSRA		:= aIdFunc[2]
					cEmpAtu		:= aIdFunc[3]
				Else
					SetRestFault(400, EncodeUTF8( STR0077 )) //"Você está tentando acessar dados de um funcionário que não faz parte do seu time."
					Return (.F.)
				EndIf
			EndIf
		EndIf
	Else
		//Valida Permissionamento
		cWsName := If( lDivergent, "divergentClockingView", "timesheet" )
		fPermission(cBranchVld, cLogin, cRD0Cod, cWsName, @lHabil)
		If !lHabil .Or. lDemit
			SetRestFault(400, EncodeUTF8( STR0068 )) //"Permissão negada aos serviços do espelho de ponto!"
			Return (.F.)  
		EndIf
	EndIf

	If Empty(cMatSRA) .Or. Empty(cBranchVld)

		oMessages["type"]   := "error"
		oMessages["code"]   := "401"
		oMessages["detail"] := EncodeUTF8(STR0006) //"Dados inválidos."

		Aadd(aMessages,oMessages)
		lAuth := .F.

	EndIf

	If lAuth
		If( Empty(initPeriod) .And. Empty(endPeriod) )
			aPeriods := GetDataForJob( "1", {cBranchVld, cMatSRA, Nil}, cEmpAtu )
			If Len(aPeriods) > 0
				initPeriod 	:= aPeriods[1,1]
				endPeriod   := aPeriods[1,2]
			EndIf
		EndIf

		If !Empty(Self:id)
			cIdPer := rc4crypt( Self:id, "MeuRH#PeriodoId", .F., .T. )
			aIdPer := STRTOKARR( cIdPer, "|" )
			If Len(aIdPer) > 0
				aAdd( aProcFun, {aIdPer[1], aIdPer[2]} )
				If Val(aIdPer[3]) > 1
					aAdd( aProcFun, {cBranchVld, cMatSRA} )
				EndIf
			EndIf
		Else
			aAdd( aProcFun, {cBranchVld, cMatSRA} )
		EndIf	

		For nX := 1 To Len(aProcFun)
			If !(cEmpAnt == cEmpAtu)
				aDataAux := GetDataForJob( "3", {aProcFun[nX,1], aProcFun[nX,2], initPeriod, endPeriod, lDivergent, lOnlyDiv}, cEmpAtu )
			Else
				aDataAux := getClockings( aProcFun[nX,1], aProcFun[nX,2], initPeriod, endPeriod, lDivergent, NIL, NIL, NIL, lOnlyDiv)
			EndIf
			For nY := 1 To Len(aDataAux)
				aAdd( aData, aDataAux[nY] )
			Next nY
		Next nX
	EndIf

	// - Por por padrão todo objeto tem
	// - data: contendo a estrutura do JSON
	// - messages: para determinados avisos
	// - length: informativo sobre o tamanho.
	oItem["initPeriod"]	:= formatGMT( DTOC(initPeriod) )
	oItem["endPeriod"]	:= formatGMT( DTOC(endPeriod) )
	oItem["clockings"]	:= aData

	cJson := oItem:ToJson()
	::SetResponse(cJson)

	FreeObj(oItem)

Return(.T.)


WSMETHOD POST geolocation PATHPARAM employeeId WSREST Timesheet

    Local cBody			:= self:GetContent()
	Local cToken        := ""
	Local cKeyId        := ""
	Local cBranchVld	:= ""
	Local cMatSRA		:= ""
	Local cLogin		:= ""
	Local cRD0Cod		:= ""
    Local cMsg			:= ""
    Local lRet			:= .F.
	Local lDemit      := .F.
	Local lHabil      := .T.
	Local aDataLogin	:= {}
    Local oItem
    Local oItemDetail

    ::SetHeader('Access-Control-Allow-Credentials' , "true")

	cToken		:= Self:GetHeader('Authorization')
	cKeyId 		:= Self:GetHeader('keyId')
	
	aDataLogin := GetDataLogin(cToken, .T., cKeyId)
	If Len(aDataLogin) > 0
		cMatSRA    := aDataLogin[1]
		cLogin     := aDataLogin[2]
		cRD0Cod    := aDataLogin[3]
		cBranchVld := aDataLogin[5]
		lDemit     := aDataLogin[6]
	EndIf

	//Valida Permissionamento
	fPermission(cBranchVld, cLogin, cRD0Cod, "clockingGeoRegister", @lHabil)
	If !lHabil .Or. lDemit
		SetRestFault(400, EncodeUTF8( STR0067 )) //"Permissão negada aos serviços de marcação por geolocalização!"
		Return (.F.)  
	EndIf

    lRet := fSetGeoClocking( DecodeUTF8(cBody), @oItem, @oItemDetail, cToken, @cMsg, cKeyId )

    If lRet
        cJson := oItemDetail:ToJson()
        ::SetResponse(cJson)
	Else
        SetRestFault(400, cMsg)
	EndIf

Return( lRet )


//"Retorna as batidas de ponto do dia atual"
WSMETHOD GET todayClockings PATHPARAM employeeId, latitude, longitude WSREST Timesheet
    Local oItem		 	:= JsonObject():New()
    Local aData		 	:= {}
	Local aDataLogin	:= {}
	Local cToken        := ""
	Local cKeyId        := ""
	Local cBranchVld	:= ""
	Local cMatSRA		:= ""
	Local cLogin		:= ""
	Local cRD0Cod		:= ""
	Local lDemit    := .F.
	Local lHabil    := .T.

    ::SetHeader('Access-Control-Allow-Credentials' , "true")

	cToken		:= Self:GetHeader('Authorization')
	cKeyId 		:= Self:GetHeader('keyId')

	aDataLogin := GetDataLogin(cToken, .T., cKeyId)
	If Len(aDataLogin) > 0
		cMatSRA    := aDataLogin[1]
		cLogin     := aDataLogin[2]
		cRD0Cod    := aDataLogin[3]
		cBranchVld := aDataLogin[5]
		lDemit     := aDataLogin[6]
	EndIf	

	//Valida Permissionamento
	fPermission(cBranchVld, cLogin, cRD0Cod, "clockingGeoRegister", @lHabil)
	If !lHabil .Or. lDemit
		SetRestFault(400, EncodeUTF8( STR0067 )) //"Permissão negada aos serviços de marcação por geolocalização!"
		Return (.F.)  
	EndIf

    If !Empty(cMatSRA) .And. !Empty(cBranchVld)
        aData := GetDayClocks(cBranchVld, cMatSRA)
    EndIf

    oItem["hasNext"] 	:= .F.
    oItem["items"]		:= aData

    cJson := oItem:ToJson()
    ::SetResponse(cJson)

Return .T.

// Retorna a data e hora atuais do servidor com base no fuso horário do usuário
WSMETHOD GET currentTime PATHPARAM latitude, longitude WSREST Timesheet
    Local oItem 		:= JsonObject():New()
	Local aHorTmz 		:= {}
	Local aDataLogin	:= {}
	Local cToken        := ""
	Local cKeyId        := ""
	Local cBranchVld	:= ""
	Local cMatSRA		:= ""
	Local cLogin		:= ""
	Local cRD0Cod		:= ""
	Local cTimezone		:= ""
	Local cMsg			:= ""
	Local lRet 			:= .T.
	Local lHabil    := .T.
	Local lDemit    := .F.
	Local nX 			:= 0

    ::SetHeader('Access-Control-Allow-Credentials' , "true")

	cToken		:= Self:GetHeader('Authorization')
	cKeyId 		:= Self:GetHeader('keyId')

	aDataLogin := GetDataLogin(cToken, .T., cKeyId)
	If Len(aDataLogin) > 0
		cMatSRA    := aDataLogin[1]
		cLogin     := aDataLogin[2]
		cRD0Cod    := aDataLogin[3]
		cBranchVld := aDataLogin[5]
		lDemit     := aDataLogin[6]
	EndIf

	//Valida Permissionamento
	fPermission(cBranchVld, cLogin, cRD0Cod, "clockingGeoRegister", @lHabil)
	If !lHabil .Or. lDemit
		SetRestFault(400, EncodeUTF8( STR0067 )) //"Permissão negada aos serviços de marcação por geolocalização!"
		Return (.F.)  
	EndIf

	For nX := 1 To Len( Self:aQueryString )
		If UPPER(Self:aQueryString[nX,1]) == "TIMEZONE"
			cTimezone := Self:aQueryString[nX,2]
		EndIf
	Next

	//Verifica se o dia mudou para atualizar a variável dDataBase
	FwDateUpd(.F., .T.)
	
	If cMeurhLog == "1"
		Conout("<<< " + OEMToAnsi(STR0124) + ": " + ; // "A apuração do timezone (fuso horário) será iniciado."
		STR0121 + " : " + AlLTrim(Str(ThreadID())) + " >>> ") // Thread
	EndIf
	

	If !empty(cTimezone)
		If cMeurhLog == "1"
			Conout("<<< " +	STR0097 + " : " + cBranchVld + " - " + ; // Filial
			OEMToAnsi(STR0100) + " : " + cMatSRA + " - " + ; // Matricula
			STR0121 + " : " + AlLTrim(Str(ThreadID())) + " >>> ") // Thread
		EndIf
		aHorTmz := fGetTimezone( val(cTimezone) )
		If empty(aHorTmz)
			lRet := .F.
			cMsg :=  EncodeUTF8(STR0064) //"Ocorreu um problema na verificação do timezone para marcação"
		Else
		    oItem["actualDate"] := aHorTmz[1]
    		oItem["actualTime"] := aHorTmz[2]
		EndIf
	Else
	    oItem["actualDate"] := FwTimeStamp(6, dDataBase, "12:00:00" )
    	oItem["actualTime"] := Seconds()*1000 // O formato esperado é miliseconds.

		If cMeurhLog == "1"
			Conout("<<< " + OEMToAnsi(STR0123) + " - " + ; // Não foi informado timezone na requisição
			STR0097 + " : " + cBranchVld + " - " + ; // Filial
			OEMToAnsi(STR0100) + " : " + cMatSRA + " - " + ; // Matricula
			STR0121 + " : " + AlLTrim(Str(ThreadID())) + " >>> ") // Thread
		EndIf
	EndIf

	If  lRet
		cJson := oItem:ToJson()
		::SetResponse(cJson)
	Else
		SetRestFault(400, cMsg)
	EndIf

Return lRet

WSMETHOD GET disconsider WSREST Timesheet

    Local oItem		 	:= JsonObject():New()
    Local cToken        := ""
    Local cKeyId        := ""
    Local cMatSRA       := ""
    Local cBranchVld    := ""
    Local cType         := "2" //-- Motivos de Rejeição
    Local aData         := {}
	Local aDataLogin	:= {}

    ::SetContentType("application/json")
    ::SetHeader('Access-Control-Allow-Credentials' , "true")

    cToken  := Self:GetHeader('Authorization')
	cKeyId 	:= Self:GetHeader('keyId')

	aDataLogin 	:= GetDataLogin(cToken,,cKeyId)
	If Len(aDataLogin) > 0
		cMatSRA     := aDataLogin[1]
		cBranchVld  := aDataLogin[5]
	EndIf

    If !Empty(cMatSRA) .And. !Empty(cBranchVld)
        aData := fGetClockType(cEmpAnt, cBranchVld, cType)
    EndIf

    oItem["items"] 	 := aData
    oItem["hasNext"] := .F.

    cJson := oItem:toJson()

    ::SetResponse(cJson)

Return .T.


WSMETHOD GET geolocation PATHPARAM employeeId WSREST Timesheet

	Local oItem			:= JsonObject():New()
	Local cBranchVld	:= ""
	Local cToken		:= ""
	Local cKeyId		:= ""
	Local cLogin		:= ""
	Local cRD0Cod		:= ""
	Local cMatTeam		:= ""
	Local cFilTeam		:= ""
	Local cEmpTeam		:= ""
	Local lDemit		:= .F.
	Local lHabil		:= .T.
	Local aDataLogin	:= {}
	Local aDataFunc		:= {}
	Local aPeriods		:= {}
	Local aData			:= {}
	Local initPeriod	:= CtoD( Format8601(.T.,Self:initPeriod) )
	Local endPeriod		:= CtoD( Format8601(.T.,Self:endPeriod) )

	::SetHeader('Access-Control-Allow-Credentials' , "true")

	cToken		:= Self:GetHeader('Authorization')
	cKeyId 		:= Self:GetHeader('keyId')

	aDataLogin  := GetDataLogin(cToken, .T., cKeyId)
	If Len(aDataLogin) > 0
		cBranchVld := aDataLogin[5]
		cLogin     := aDataLogin[2]
		cRD0Cod    := aDataLogin[3]	
		lDemit     := aDataLogin[6]
	EndIf

	//Valida Permissionamento
	fPermission(cBranchVld, cLogin, cRD0Cod, "clockingGeoDisconsider", @lHabil)
	If !lHabil .Or. lDemit
		SetRestFault(400, EncodeUTF8( STR0067 )) //"Permissão negada aos serviços de marcação por geolocalização!"
		Return (.F.)  
	EndIf

	If "|" $ Self:employeeId
	aDataFunc := STRTOKARR( Self:employeeId, "|" )
	If Len(aDataFunc) > 0
		cFilTeam := aDataFunc[1]
		cMatTeam := aDataFunc[2]	    
		cEmpTeam := If( Len(aDataFunc) > 2, aDataFunc[3], cEmpAnt ) 
		EndIf
	Else
		cFilTeam := cBranchVld
		cMatTeam := Self:employeeId
		cEmpTeam := cEmpAnt
	EndIf

	If !Empty(cMatTeam) .And. !Empty(cFilTeam)

		If( Empty(initPeriod) .And. Empty(endPeriod) )
			
			aPeriods := GetDataForJob( "1", {cFilTeam, cMatTeam, Nil}, cEmpTeam )
			
			If Len(aPeriods) > 0
				initPeriod 	:= aPeriods[1,1]
				endPeriod   := aPeriods[1,2]
			EndIf
		EndIf

		aData := getGeoClockings(cFilTeam,cMatTeam,initPeriod,endPeriod,cEmpTeam)
	EndIf

	oItem["hasNext"] 	:= .F.
	oItem["items"]		:= aData

	cJson := oItem:ToJson()
	::SetResponse(cJson)

Return .T.

WSMETHOD PUT geolocation PATHPARAM employeeId WSREST Timesheet

	Local oItem			:= &("JsonObject():New()")
	Local cBranchVld	:= ""
	Local cToken	  	:= ""
	Local cKeyId	  	:= ""
	Local cLogin		:= ""
	Local cRD0Cod		:= ""
	Local cMsg			:= ""
	Local cFilTeam		:= ""
	Local cMatTeam		:= ""
	Local cEmpTeam		:= cEmpAnt
	Local cBody			:= self:GetContent()
	Local lHabil		:= .T.
	Local lDemit		:= .F.
	Local lRet			:= .F.
	Local aDataLogin	:= {}
	Local aIdFunc		:= {}

	::SetHeader('Access-Control-Allow-Credentials' , "true")

	cToken		:= Self:GetHeader('Authorization')
	cKeyId 		:= Self:GetHeader('keyId')

	If "|" $ Self:employeeId
		aIdFunc := STRTOKARR( Self:employeeId, "|" )
		nDataId := Len( aIdFunc )
		If nDataId > 1
			cFilTeam := aIdFunc[1]
			cMatTeam := aIdFunc[2]		
			cEmpTeam := If( nDataId > 2, aIdFunc[3], cEmpTeam )
		EndIf	
	Else
		cMatTeam := Self:employeeId
		cFilTeam := cBranchVld
	EndIf

	aDataLogin  := GetDataLogin(cToken, .T., cKeyId)
	If Len(aDataLogin) > 0
		cBranchVld	:= aDataLogin[5]
		cLogin		:= aDataLogin[2]
		cRD0Cod		:= aDataLogin[3]
		lDemit		:= aDataLogin[6]
	EndIf   

	//Valida Permissionamento
	fPermission(cBranchVld, cLogin, cRD0Cod, "clockingGeoDesconsider", @lHabil)
	If !lHabil .Or. lDemit
		SetRestFault(400, EncodeUTF8( STR0067 )) //"Permissão negada aos serviços de marcação por geolocalização!"
		Return (.F.)  
	EndIf

	If !Empty(cMatTeam) .And. !Empty(cFilTeam)
		If( lRet := UpdGeoClock(cFilTeam, cMatTeam, cBody, @oItem, @cMsg, cEmpTeam ) )
			cJson := oItem:ToJson()
			::SetResponse(cJson)
		Else
			SetRestFault(400, cMsg )
		EndIf
	Else
		cMsg := EncodeUTF8(STR0036) //"Essa batida não foi desconsiderada porque não foram localizados os dados da requisição original."
		SetRestFault(400, cMsg )
	EndIf

Return( lRet )


WSMETHOD PUT EditVariousClockings PATHPARAM employeeId WSREST Timesheet
	Local aUrlParam		:= ::aUrlParms
	Local cBody			:= DecodeUTF8(::GetContent())
	Local oItem			:= JsonObject():New()
	Local oResponse		:= JsonObject():New()
	Local cToken		:= ""
	Local cKeyId		:= ""
	Local cBranchVld	:= ""
	Local cMatSRA		:= ""
	Local cLogin		:= ""
	Local cRD0Cod		:= ""
	Local cMsgLog		:= ""
	Local cJson			:= ""
	Local cEmpFunc		:= cEmpAnt
	Local lRet			:= .T.
	Local lHabil		:= .T.
	Local lDemit		:= .F.
	Local aIdFunc		:= {}
	Local aDataLogin	:= {}

	::SetHeader('Access-Control-Allow-Credentials' , "true")

	cToken		:= Self:GetHeader('Authorization')
	cKeyId 		:= Self:GetHeader('keyId')

	aDataLogin := GetDataLogin(cToken, .T., cKeyId)
	If Len(aDataLogin) > 0
		cMatSRA      := aDataLogin[1]
		cBranchVld   := aDataLogin[5]
		cLogin       := aDataLogin[2]
		cRD0Cod      := aDataLogin[3]
		lDemit       := aDataLogin[6]
	EndIf

	If !( "current" $ Self:employeeId )
		aIdFunc := STRTOKARR( Self:employeeId, "|" )
		If Len(aIdFunc) > 0
			cEmpFunc := aIdFunc[3]
			If ( cBranchVld == aIdFunc[1] .And. cMatSRA == aIdFunc[2] )
				//Valida Permissionamento
				fPermission(cBranchVld, cLogin, cRD0Cod, "clockingUpdate", @lHabil)
				If !lHabil .Or. lDemit
					SetRestFault(400, EncodeUTF8( STR0066 )) //"Permissão negada aos serviços de marcação de ponto!"
					Return (.F.)  
				EndIf
			Else
				//Valida Permissionamento
				fPermission(cBranchVld, cLogin, cRD0Cod, "teamManagementTimesheet", @lHabil)
				If !lHabil .Or. lDemit
					SetRestFault(400, EncodeUTF8( STR0066 )) //"Permissão negada aos serviços de marcação de ponto!"
					Return (.F.)  
				EndIf
			EndIf
		EndIf
	Else
		//Valida Permissionamento
		fPermission(cBranchVld, cLogin, cRD0Cod, "clockingUpdate", @lHabil)
		If !lHabil .Or. lDemit
			SetRestFault(400, EncodeUTF8( STR0066 )) //"Permissão negada aos serviços de marcação de ponto!"
			Return (.F.)  
		EndIf
	EndIf

	If cEmpFunc == cEmpAnt
		cMsgLog := fEditClocking(aUrlParam, cBody, aIdFunc, cBranchVld, cMatSRA, cEmpAnt)
	Else
		cMsgLog := GetDataForJob( "7", {aUrlParam, cBody, aIdFunc, cBranchVld, cMatSRA, cEmpAnt}, cEmpFunc )
	EndIf

	If Empty(cMsgLog)
		oItem:FromJson(cBody)
		oResponse["date"]		:= oItem["date"]
		oResponse["clockings"]	:= oItem["clockings"]
		
		cJson := oResponse:ToJson()
		::SetResponse(cJson)
	Else
		lRet := .F.
		SetRestFault(400, EncodeUTF8(cMsgLog))
	EndIf

	FreeObj(oItem)
	FreeObj(oResponse)

Return lRet


WSMETHOD POST SetVariousClockings PATHPARAM employeeId WSREST Timesheet
	Local aUrlParam		:= ::aUrlParms
	Local cBody			:= DecodeUTF8(::GetContent())
	Local oItem			:= JsonObject():New()
	Local cToken		:= ""
	Local cKeyId		:= ""
	Local cBranchVld	:= ""
	Local cMatSRA		:= ""
	Local cLogin		:= ""
	Local cRD0Cod		:= ""
	Local cMsgLog		:= ""
	Local cJson         := ""
	Local cEmpFunc		:= cEmpAnt
	Local lHabil		:= .T.
	Local lDemit		:= .F.
	Local lRet			:= .F.
	Local lRobot		:= .F.
	Local aDataRet		:= {}
	Local aIdFunc       := {}
	Local aDataLogin	:= {}

	::SetHeader('Access-Control-Allow-Credentials' , "true")
	cToken		:= Self:GetHeader('Authorization')
	cKeyId 		:= Self:GetHeader('keyId')

	aDataLogin := GetDataLogin(cToken, .T., cKeyId)
	If Len(aDataLogin) > 0
		cMatSRA      := aDataLogin[1]
		cBranchVld   := aDataLogin[5]
		cLogin       := aDataLogin[2]
		cRD0Cod      := aDataLogin[3]
		lDemit       := aDataLogin[6]
	EndIf	

	//Verifica se eh o gestor que esta fazendo a solicitacao
	If !( "current" $ Self:employeeId )
		aIdFunc := STRTOKARR( Self:employeeId, "|" )
		If Len(aIdFunc) > 0
			If ( cBranchVld == aIdFunc[1] .And. cMatSRA == aIdFunc[2] )
				//Valida Permissionamento
				fPermission(cBranchVld, cLogin, cRD0Cod, "clockingRegister", @lHabil)
				If !lHabil .Or. lDemit
					SetRestFault(400, EncodeUTF8( STR0066 )) //"Permissão negada aos serviços de marcação de ponto!"
					Return (.F.)  
				EndIf
			Else
				//Valida Permissionamento
				fPermission(cBranchVld, cLogin, cRD0Cod, "teamManagementTimesheet", @lHabil)
				If !lHabil .Or. lDemit
					SetRestFault(400, EncodeUTF8( STR0066 )) //"Permissão negada aos serviços de marcação de ponto!"
					Return (.F.)  
				EndIf
			EndIf
			cBranchVld 	:= aIdFunc[1]
			cMatSRA 	:= aIdFunc[2]
			cEmpFunc 	:= aIdFunc[3]
		EndIf	
	Else
		//Valida Permissionamento
		fPermission(cBranchVld, cLogin, cRD0Cod, "clockingRegister", @lHabil)
		If !lHabil .Or. lDemit
			SetRestFault(400, EncodeUTF8( STR0066 )) //"Permissão negada aos serviços de marcação de ponto!"
			Return (.F.)  
		EndIf
	EndIf

	If cEmpFunc == cEmpAnt
		aDataRet := fSetClocking(aUrlParam, cBody, aDataLogin, aIdFunc, cBranchVld)
	Else
		aDataRet := GetDataForJob( "6", {aUrlParam, cBody, aDataLogin, aIdFunc, cBranchVld}, cEmpFunc )
	EndIf

	If Len(aDataRet) > 0
		lRet	:= aDataRet[1]
		cMsgLog	:= aDataRet[2]
		lRobot	:= aDataRet[3]
	EndIf

	If lRet
		oItem:FromJson(cBody)
		cJson := oItem:ToJson()
		::SetResponse(cJson)
	Else
		If lRobot
			lRet := .T.
			oItem["errorCode"] 		:= "400"
			oItem["errorMessage"] 	:= cMsgLog
			cJson := oItem:ToJson()
			Self:SetResponse(cJson)
		Else
			SetRestFault(400, EncodeUTF8(cMsgLog))
		EndIf
	EndIf
Return lRet

WSMETHOD POST globalClockings PATHPARAM employeeId WSREST Timesheet
	Local cBody			:= DecodeUTF8(::GetContent())
	Local cToken		:= ""
	Local cKeyId		:= ""
	Local cBranchVld	:= ""
	Local cLogin		:= ""
	Local cRD0Cod		:= ""
	Local cJson         := ""
	Local cEmpToReq		:= cEmpAnt
	Local lHabil		:= .F.
	Local lDemit		:= .F.
	Local lGestor		:= .F.
	Local oRet			:= NIL
	Local aRequest		:= {}
	Local aIdFunc       := {}
	Local aDataLogin	:= {}

	::SetHeader('Access-Control-Allow-Credentials' , "true")
	cToken		:= Self:GetHeader('Authorization')
	cKeyId 		:= Self:GetHeader('keyId')

	aDataLogin := GetDataLogin(cToken, .T., cKeyId)
	If Len(aDataLogin) > 0
		cBranchVld 	 := cFilToReq := aDataLogin[5]	
		cMatSRA	   	 := cMatToReq := aDataLogin[1]
		cRD0Cod	   	 := aDataLogin[3]
		cLogin       := aDataLogin[2]
		lDemit       := aDataLogin[6]
	EndIf	

	//Verifica se eh o gestor que esta fazendo a solicitacao
	If !( "current" $ Self:employeeId )
		aIdFunc := STRTOKARR( Self:employeeId, "|" )
		If Len(aIdFunc) > 0
			//Valida Permissionamento
			fPermission(cBranchVld, cLogin, cRD0Cod, "teamManagementGlobalClockings", @lHabil)
			If !lHabil .Or. lDemit
				SetRestFault(400, EncodeUTF8( STR0133 )) //"Permissão negada ao serviços de marcação global de ponto"
				Return (.F.)  
			EndIf
			cFilToReq := aIdFunc[1]
			cMatToReq := aIdFunc[2]
			cEmpToReq := aIdFunc[3]
			lGestor	  := .T.
		EndIf	
	Else
		//Valida Permissionamento
		fPermission(cBranchVld, cLogin, cRD0Cod, "globalClockings", @lHabil)
		If !lHabil .Or. lDemit
			SetRestFault(400, EncodeUTF8( STR0133 )) //"Permissão negada ao serviços de marcação global de ponto"
			Return (.F.)  
		EndIf
	EndIf

	aRequest := {;
				cEmpAnt,;		// 01 - Empresa da Pessoa Logada.
				cBranchVld,;	// 02 - Filial da Pessoa Logada.
				cMatSRA,;		// 03 - Matricula Da Pessoa Logada.
				cEmpToReq,;		// 04 - Empresa Da Pessoa que Recebeu a Solicitação.
				cFilToReq,;		// 05 - Filial Da Pessoa que Recebeu a Solicitação
				cMatToReq,;		// 06 - Matricula Da Pessoa que Recebeu a Solicitação
				cRD0Cod,;		// 07 - Codigo da RD0 da Pessoa Logada.
				lGestor }		// 08 - Gestor fazendo ação para funcionario? = .T. = Sim, .F. = Não.

	oRet  := JsonObject():New()
	oRet  := GetDataForJob( "23", {cBody, aRequest }, cEmpToReq )
	cJson := oRet:ToJson()

	::SetResponse(cJson)

Return .T.

WSMETHOD PUT EditOneClockings PATHPARAM employeeId WSREST Timesheet
	Local aUrlParam			:= ::aUrlParms
	Local cBody				:= DecodeUTF8(::GetContent())
	Local oItem				:= JsonObject():New()
	Local cToken			:= ""
	Local cKeyId			:= ""
	Local cBranchVld		:= ""
	Local cMatSRA			:= ""
	Local cLogin			:= ""
	Local cRD0Cod			:= ""
	Local cMsgLog			:= ""
	Local cJson				:= ""
	Local cEmpFunc			:= cEmpAnt
	Local lRet				:= .T.
	Local lHabil			:= .T.
	Local lDemit			:= .F.
	Local aIdFunc			:= {}
	Local aDataLogin		:= {}

	::SetHeader('Access-Control-Allow-Credentials' , "true")

	cToken := Self:GetHeader('Authorization')
	cKeyId := Self:GetHeader('keyId')

	aDataLogin := GetDataLogin(cToken, .T., cKeyId)
	If Len(aDataLogin) > 0
		cMatSRA      := aDataLogin[1]
		cBranchVld   := aDataLogin[5]
		cLogin       := aDataLogin[2]
		cRD0Cod      := aDataLogin[3]
		lDemit       := aDataLogin[6]
	EndIf	

	If !( "current" $ Self:employeeId )
		aIdFunc := STRTOKARR( Self:employeeId, "|" )

		If Len(aIdFunc) > 0
			cEmpFunc := aIdFunc[3]
			If ( cBranchVld == aIdFunc[1] .And. cMatSRA == aIdFunc[2] ) 
				//Valida Permissionamento
				fPermission(cBranchVld, cLogin, cRD0Cod, "clockingUpdate", @lHabil)
				If !lHabil .Or. lDemit
					SetRestFault(400, EncodeUTF8( STR0066 )) //"Permissão negada aos serviços de marcação de ponto!"
					Return (.F.)  
				EndIf
			Else
				//Valida Permissionamento
				fPermission(cBranchVld, cLogin, cRD0Cod, "teamManagementTimesheet", @lHabil)
				If !lHabil .Or. lDemit
					SetRestFault(400, EncodeUTF8( STR0066 )) //"Permissão negada aos serviços de marcação de ponto!"
					Return (.F.)  
				EndIf
			EndIf
		EndIf
	Else
		//Valida Permissionamento
		fPermission(cBranchVld, cLogin, cRD0Cod, "clockingUpdate", @lHabil)
		If !lHabil .Or. lDemit
			SetRestFault(400, EncodeUTF8( STR0066 )) //"Permissão negada aos serviços de marcação de ponto!"
			Return (.F.)  
		EndIf
	EndIf

	If cEmpFunc == cEmpAnt
		cMsgLog := fEditClocking(aUrlParam, cBody, aIdFunc, cBranchVld, cMatSRA, cEmpAnt)
	Else
		cMsgLog := GetDataForJob( "7", {aUrlParam, cBody, aIdFunc, cBranchVld, cMatSRA, cEmpAnt}, cEmpFunc )
	EndIf

	If Empty(cMsgLog)
		oItem:FromJson(cBody)
		cJson := oItem:ToJson()
		::SetResponse(cJson)
	Else
		lRet := .F.
		SetRestFault(400, EncodeUTF8(cMsgLog))
	EndIf

	FreeObj(oItem)

Return lRet


WSMETHOD DELETE dClocking WSREST Timesheet

	Local lRet			:= .T.
	Local lHabil		:= .T.
	Local lDemit		:= .F.
	Local aUrlParam		:= Self:aUrlParms
	Local cCodigo		:= ""
	Local cToken		:= ""
	Local cKeyId		:= ""
	Local cBranchVld	:= ""
	Local cMatSRA		:= ""
	Local cLogin		:= ""
	Local cRD0Cod		:= ""
	Local aIdFunc		:= {}
	Local aDataLogin	:= {}
	Local aRet			:= { .F., ""}
		
	::SetContentType("application/json")
	::SetHeader('Access-Control-Allow-Credentials' , "true")

	cToken		:= Self:GetHeader('Authorization')
	cKeyId 		:= Self:GetHeader('keyId')

	aDataLogin := GetDataLogin(cToken, .T., cKeyId)
	If Len(aDataLogin) > 0
		cMatSRA      := aDataLogin[1]
		cBranchVld   := aDataLogin[5]
		cLogin       := aDataLogin[2]
		cRD0Cod      := aDataLogin[3]
		lDemit       := aDataLogin[6]
	EndIf	

	If !( "current" $ Self:employeeId )
		aIdFunc := STRTOKARR( Self:employeeId, "|" )

		If Len(aIdFunc) > 0
			If ( cBranchVld == aIdFunc[1] .And. cMatSRA == aIdFunc[2] ) 
				//Valida Permissionamento
				fPermission(cBranchVld, cLogin, cRD0Cod, "clockingUpdate", @lHabil)
				If !lHabil .Or. lDemit
					SetRestFault(400, EncodeUTF8( STR0066 )) //"Permissão negada aos serviços de marcação de ponto!"
					Return (.F.)  
				EndIf
			Else
				//Valida Permissionamento
				fPermission(cBranchVld, cLogin, cRD0Cod, "teamManagementTimesheet", @lHabil)
				If !lHabil .Or. lDemit
					SetRestFault(400, EncodeUTF8( STR0066 )) //"Permissão negada aos serviços de marcação de ponto!"
					Return (.F.)  
				EndIf
			EndIf
			cBranchVld 	:= aIdFunc[1]
			cMatSRA 	:= aIdFunc[2]		
		EndIf
	Else
		//Valida Permissionamento
		fPermission(cBranchVld, cLogin, cRD0Cod, "clockingUpdate", @lHabil)
		If !lHabil .Or. lDemit
			SetRestFault(400, EncodeUTF8( STR0066 )) //"Permissão negada aos serviços de marcação de ponto!"
			Return (.F.)  
		EndIf
	EndIf

	If AT("|", aUrlParam[3]) > 0
		cCodigo := STRTOKARR( aUrlParam[3] , "|" )[2]
		aRet := DelBatida(cBranchVld, cMatSRA, cCodigo, aDataLogin)
	Else
		aRet[2] := EncodeUTF8(STR0033) //"Essa batida não pode ser excluída. O seu Tipo ou Status atual não permite a exclusão."
	EndIf
	
	If aRet[1]
	   	HttpSetStatus(204)
   	Else	
	   	lRet := .F.
		SetRestFault(400, aRet[2])
	EndIf  
Return lRet


WSMETHOD DELETE dAllowance WSREST Timesheet

	Local aUrlParam		:= Self:aUrlParms
	Local aDataLogin	:= {}
	Local lRet			:= .F.
	Local lHabil		:= .T.
	Local lDemit		:= .F.
	Local cId			:= ""
	Local cFilRH3		:= ""
	Local cCodRH3		:= ""
	Local cErro			:= ""
	Local cToken		:= ""
	Local cBranchVld	:= ""
	Local cMatSRA		:= ""
	Local cLogin		:= ""
	Local cRD0Cod		:= ""
	Local cChvRH4		:= ""
	Local cRoutine		:= "W_PWSA160.APW" //Justificativas pré-abono

	::SetContentType("application/json")
	::SetHeader('Access-Control-Allow-Credentials' , "true")

	cToken		:= Self:GetHeader('Authorization')
	cKeyId 		:= Self:GetHeader('keyId')

	aDataLogin := GetDataLogin(cToken, .T., cKeyId)
	If Len(aDataLogin) > 0
		cMatSRA      := aDataLogin[1]
		cBranchVld   := aDataLogin[5]
		cLogin       := aDataLogin[2]
		cRD0Cod      := aDataLogin[3]
		lDemit       := aDataLogin[6]
	EndIf

	If Len(Self:aUrlParms) >= 3 .And. !Empty(Self:aUrlParms[3])
		cId 	:= rc4crypt( aUrlParam[3], "MeuRH#Allowance", .F., .T. )
		aIdFunc	:= STRTOKARR( cId, "|" )
		If Len(aIdFunc) >= 4
			cFilRH3 := aIdFunc[1]
			cCodRH3 := aIdFunc[4]
			lRet	:= .T.
		EndIf
	Else
		cErro := EncodeUTF8(STR0056) //"parâmetros invalidos na requisição!"
	EndIf

	If lRet 
		If !("current" $ Self:aUrlParms[2] )
			If Len(aIdFunc) > 1
				If ( cBranchVld == aIdFunc[1] .And. cMatSRA == aIdFunc[2] )
					//Valida Permissionamento
					fPermission(cBranchVld, cLogin, cRD0Cod, "allowance", @lHabil)
					If !lHabil .Or. lDemit
						SetRestFault(400, EncodeUTF8( STR0065 )) //"Permissão negada aos serviços de abono!"
						Return (.F.)  
					EndIf
				Else
					fPermission(cBranchVld, cLogin, cRD0Cod, "teamManagementAllowance", @lHabil)
					If !lHabil .Or. lDemit
						SetRestFault(400, EncodeUTF8( STR0065 )) //"Permissão negada aos serviços de abono!"
						Return (.F.)  
					//valida se o solicitante da requisição pode ter acesso as informações
					ElseIf !getPermission(cBranchVld, cMatSRA, aIdFunc[1], aIdFunc[2], , aIdFunc[3], cRoutine)
						lRet     := .F.
						cErro    := EncodeUTF8(STR0052) //"usuário não autorizado para exclusão da solicitação!"
					EndIf
				EndIf	
			EndIf
		Else
			//Valida Permissionamento
			fPermission(cBranchVld, cLogin, cRD0Cod, "allowance", @lHabil)
			If !lHabil .Or. lDemit
				SetRestFault(400, EncodeUTF8( STR0065 )) //"Permissão negada aos serviços de abono!"
				Return (.F.)  
			EndIf
		EndIf
	EndIf

	If lRet
		
		Begin Transaction
		DbSelectArea("RH3")
		DBSetOrder(1)
		If RH3->( dbSeek( cFilRH3 + cCodRH3 )) //Filial+Cod RH3

			//confirma se o registro ponterado é da solicitação desejada
			If !(RH3->RH3_CODIGO == cCodRH3)
				lRet  := .F.
				cErro := EncodeUTF8(STR0055) //"solicitação de abono não localizada!"
			Endif

			If lRet .and. (RH3->RH3_STATUS == '2' .or. RH3->RH3_STATUS == '3' .or. RH3->RH3_TIPO != '8')
				lRet  := .F.
				cErro := EncodeUTF8(STR0053) //"não será possível excluir a solicitação!"
			Else
				If  !empty(RH3->RH3_FILINI+RH3->RH3_MATINI)
						If	(RH3->RH3_FILINI + RH3->RH3_MATINI) != (cBranchVld + cMatSRA)
						lRet  := .F.
						cErro := EncodeUTF8(STR0054) //"usuário sem permissão para excluir a solicitação!"
						EndIf
				ElseIf RH3->RH3_MAT != cMatSRA
						lRet  := .F.
						cErro := EncodeUTF8(STR0054) //"usuário sem permissão para excluir a solicitação!"
				EndIf

				//Valida movimentação do workflow
				If lRet 
					cErro := EncodeUTF8( fVldWkf(RH3->RH3_FILIAL+RH3->RH3_CODIGO, RH3->RH3_CODIGO, "D") )

					If !empty(cErro)
						lRet := .F.
					EndIf
				EndIf

				If lRet
					cChvRH4 := xFilial("RH4",cFilRH3) + cCodRH3
					//elimina registro inicial(seq 001) do histórico RGK
					DelRGKRDY(cFilRH3, RH3->RH3_MAT, cCodRH3)

					//Processa eliminação da solicitação
					DbSelectArea("RH3")
					RecLock( "RH3", .F. )
					RH3->( dbDelete() )
					RH3->( MsUnlock() )

					DbSelectArea("RH4")
					DBSetOrder(1)
					If RH4->( dbSeek( cFilRH3 + cCodRH3 ) )
						While RH4->(!Eof()) .AND. RH4->(RH4_FILIAL + RH4_CODIGO) == cChvRH4
							RecLock( "RH4", .F. )
							RH4->( dbDelete() )
							RH4->( MsUnlock() )	             
							RH4->( dbSkip() )
						EndDo
					EndIf

				EndIF   
			EndIf
		Else
			lRet  := .F.
			cErro := EncodeUTF8(STR0055) //"solicitação de abono não localizada!"
		EndIf	

		End Transaction
	EndIf

	If lRet
		HttpSetStatus(204)
	Else	
		lRet := .F.
		SetRestFault(400, cErro)
	EndIf

Return lRet


WSMETHOD PUT editAllowance WSREST Timesheet

	Local aUrlParam		:= Self:aUrlParms
	Local aDataLogin	:= {}
	Local aIdFunc		:= {}
	Local lBitMap		:= RH3->(ColumnPos("RH3_BITMAP")) > 0
	Local lRet			:= .F.
	Local lDemit		:= .F.
	Local lHabil		:= .T.
	Local lExist		:= ChkFile("RDX")
	Local cErro			:= ""
	Local cToken		:= ""
	Local cKeyId		:= ""
	Local cBranchVld	:= ""
	Local cId			:= ""
	Local cEmpToReq     := cEmpAnt
	Local cFilToReq		:= ""
	Local cMatToReq		:= ""
	Local cLogin		:= ""
	Local cRD0Cod		:= ""
	Local cRoutine		:= "W_PWSA160.APW" //Justificativas pré-abono

	Local cJustify		:= ""
	Local cReason		:= ""
	Local cReasonDesc	:= ""
	Local cInitDate		:= ""
	Local cEndDate		:= ""
	Local cNameArq		:= ""
	Local cFilRH3  		:= ""
	Local cCodRH3  		:= ""
	Local cFileType		:= ""
	Local cFileContent	:= ""
	Local cBkpMod		:= cModulo
	Local aMsToHour		:= {}
	Local aPeriods      := {}

	Local dDtIniPonMes	:= Ctod("//")

	Local cBody			:= ::GetContent()
	Local oItemDetail	:= JsonObject():New()

	::SetContentType("application/json")
	::SetHeader('Access-Control-Allow-Credentials' , "true")

	cToken		:= Self:GetHeader('Authorization')
	cKeyId 		:= Self:GetHeader('keyId')

	aDataLogin := GetDataLogin(cToken, .T., cKeyId)
	If Len(aDataLogin) > 0
		cLogin       := aDataLogin[2]
		cRD0Cod      := aDataLogin[3]
		lDemit       := aDataLogin[6]
		cMatSRA      := cMatToReq := aDataLogin[1]
		cBranchVld   := cFilToReq := aDataLogin[5]
	EndIf

	cModulo := "GPE" // Atribui o módulo GPE para consultar corretamente as fotos no banco de dados.

	If Len(Self:aUrlParms) >= 3 .And. !Empty(Self:aUrlParms[3])
		cId 	:= rc4crypt( aUrlParam[3], "MeuRH#Allowance", .F., .T. )
		aIdFunc	:= STRTOKARR( cId, "|" )
		If Len(aIdFunc) >= 4
			cFilRH3 := aIdFunc[1]
			cCodRH3 := aIdFunc[4]
			lRet    := .T.
		EndIf
	EndIf

	If lRet
		If !( "current" $ Self:aUrlParms[2] )
			If ( cBranchVld == aIdFunc[1] .And. cMatSRA == aIdFunc[2] )
				fPermission(cBranchVld, cLogin, cRD0Cod, "allowance", @lHabil)
				If !lHabil .Or. lDemit
					SetRestFault(400, EncodeUTF8( STR0065 )) //"Permissão negada aos serviços de abono!"
					Return (.F.)  
				EndIf
			Else
				//Valida Permissionamento
				fPermission(cBranchVld, cLogin, cRD0Cod, "teamManagementAllowance", @lHabil)
				If !lHabil .Or. lDemit
					SetRestFault(400, EncodeUTF8( STR0065 )) //"Permissão negada aos serviços de abono!"
					Return (.F.)  
					
				//valida se o solicitante da requisição pode ter acesso as informações
				ElseIf !getPermission(cBranchVld, cMatSRA, aIdFunc[1], aIdFunc[2], , aIdFunc[3], cRoutine)
					lRet  := .F.
					cErro := EncodeUTF8(STR0052) //"usuário não autorizado para exclusão da solicitação!"
				EndIf
			EndIf	
		Else
			//Valida Permissionamento
			fPermission(cBranchVld, cLogin, cRD0Cod, "allowance", @lHabil)
			If !lHabil .Or. lDemit
				SetRestFault(400, EncodeUTF8( STR0065 )) //"Permissão negada aos serviços de abono!"
				Return (.F.)  
			EndIf
		EndIf
	EndIf

	If Empty(cBody)
		lRet  := .F.
		cErro := EncodeUTF8(STR0061) //"Informações da requisição não recebida"
	EndIf

	If lRet
		DbSelectArea("RH3")
		DBSetOrder(1)
		If RH3->( dbSeek( cFilRH3 + cCodRH3 ) ) //Filial+Cod RH3

			//confirma se o registro ponterado é da solicitação desejada
			If !(RH3->RH3_CODIGO == cCodRH3)
				lRet  := .F.
				cErro := EncodeUTF8(STR0055) //"solicitação de abono não localizada!"
			Endif

			If lRet .and. (RH3->RH3_STATUS == '2' .or. RH3->RH3_STATUS == '3' .or. RH3->RH3_TIPO != '8')
				lRet  := .F.
				cErro := EncodeUTF8(STR0062) //"não será possível atualizar a solicitação!"
			Else
				If  !empty(RH3->RH3_FILINI+RH3->RH3_MATINI)
					If	(RH3->RH3_FILINI + RH3->RH3_MATINI) != (cBranchVld + cMatSRA)
						lRet  := .F.
						cErro := EncodeUTF8(STR0063) //"usuário sem permissão para alterar a solicitação!"
					EndIf
				ElseIf RH3->RH3_MAT != cMatSRA
					lRet  := .F.
					cErro := EncodeUTF8(STR0063) //"usuário sem permissão para alterar a solicitação!"
				EndIf

				//Valida movimentação do workflow
				If lRet 
					cErro := EncodeUTF8( fVldWkf(RH3->RH3_FILIAL+RH3->RH3_CODIGO, RH3->RH3_CODIGO, "U") )

					If !empty(cErro)
						lRet := .F.
					EndIf
				EndIf
			EndIf
		Else
			lRet  := .F.
			cErro := EncodeUTF8(STR0055) //"solicitação de abono não localizada!"
		EndIf	

		If lRet  
			oItemDetail:FromJson(cBody)
			cInitDate   := Iif(oItemDetail:hasProperty("initDate"),Format8601(.T.,oItemDetail["initDate"]),"")
			cEndDate    := Iif(oItemDetail:hasProperty("endDate"),Format8601(.T.,oItemDetail["endDate"]),"")
			aMsToHour   := milisSecondsToHour(oItemDetail["initHour"],oItemDetail["endHour"])
			cReason     := Iif(oItemDetail:hasProperty("allowanceType"),oItemDetail["allowanceType"]["id"]," ")
			cReasonDesc := Iif(oItemDetail:hasProperty("allowanceType"),oItemDetail["allowanceType"]["description"]," ")
			cJustify    := oItemDetail["justify"]

			If !ValType( oItemDetail["file"] ) == "U"
				cFileType	:= oItemDetail["file"]["type"]
				cFileContent:= oItemDetail["file"]["content"]
			EndIf

			//Verifica se a data inicial do abono é anterior ao período aberto.
			aPeriods := GetDataForJob( "1", {cFilToReq, , 1}, cEmpToReq )
			If Len(aPeriods) > 0
				dDtIniPonMes := aPeriods[1,1]
			EndIf

			If(cToD(cInitDate) < dDtIniPonMes .Or. Empty(dDtIniPonMes))
				lRet  := .F.
				cErro := EncodeUTF8(STR0088) //"Data inicial anterior ao período aberto"
			Else
				//Verifica se não existe abono cadastrado para a mesma data e hora
				If GetJustification( cFilToReq, cMatToReq, CToD(cInitDate), CToD(cEndDate), aMsToHour[1], aMsToHour[2], cCodRH3 )
					//efetua atualização RH4
					Begin Transaction
						DBSelectArea("RH4")
						DBSetOrder(1)
						RH4->(DbSeek(RH3->(RH3_FILIAL + RH3_CODIGO)))

						While RH4->(RH4_FILIAL + RH4_CODIGO) == RH3->(RH3_FILIAL + RH3_CODIGO) .And. !RH4->(Eof())

							RecLock("RH4", .F.)
								If AllTrim(RH4->RH4_CAMPO) == "RF0_DTPREI"
									RH4->RH4_VALANT := RH4->RH4_VALNOV
									RH4->RH4_VALNOV := cInitDate
								ElseIf AllTrim(RH4->RH4_CAMPO) == "RF0_DTPREF"
									RH4->RH4_VALANT := RH4->RH4_VALNOV
									RH4->RH4_VALNOV := cEndDate
								ElseIf AllTrim(RH4->RH4_CAMPO) == "RF0_HORINI"
									RH4->RH4_VALANT := RH4->RH4_VALNOV
									RH4->RH4_VALNOV := alltrim(str( noround(aMsToHour[1], 2) ))
								ElseIf AllTrim(RH4->RH4_CAMPO) == "RF0_HORFIM"
									RH4->RH4_VALANT := RH4->RH4_VALNOV
									RH4->RH4_VALNOV := alltrim(str( noround(aMsToHour[2], 2) ))
								ElseIf AllTrim(RH4->RH4_CAMPO) == "RF0_CODABO"
									RH4->RH4_VALANT := RH4->RH4_VALNOV
									RH4->RH4_VALNOV := cReason
								ElseIf AllTrim(RH4->RH4_CAMPO) == "TMP_ABOND"
									RH4->RH4_VALANT := RH4->RH4_VALNOV
									RH4->RH4_VALNOV := DecodeUTF8( cReasonDesc )
								ElseIf AllTrim(RH4->RH4_CAMPO) == "RF0_HORTAB"
									RH4->RH4_VALANT := RH4->RH4_VALNOV
									If empty(aMsToHour[1]) 
										RH4->RH4_VALNOV := "S"
									Else
										RH4->RH4_VALNOV := "N"
									EndIf	
								EndIf
							MsUnLock()

							RH4->(DbSkip())
						EndDo

						//Atualiza RGK                    
						If !empty(cJustify)
							DBSelectArea("RGK")
							DBSetOrder(1) //RGK_FILIAL +RGK_MAT +RGK_CODIGO +RGK_SEQUEN +RGK_DATA
							If RGK->(DbSeek( xFilial("RGK",RH3->RH3_FILIAL) + RH3->RH3_MAT + RH3->RH3_CODIGO , .T. ))
								If lExist
									DBSelectArea("RDX")
									DBSetOrder(2) //RDX_FILTAB +RDX_CHAVE +RDX_SEQ
									If RDX->(DbSeek( RGK->RGK_FILIAL + RGK->RGK_CODCON +'001' ))
										RecLock("RDX", .F.)
										RDX->RDX_TEXTO := DecodeUTF8( alltrim(cJustify) )
										MsUnLock()
									EndIf
								EndIf
								DBSelectArea("RDY")
								DBSetOrder(2) //RDY_FILTAB +RDY_CHAVE +RDY_SEQ
								If RDY->(DbSeek( RGK->RGK_FILIAL + RGK->RGK_CODCON +'001' ))
									RecLock("RDY", .F.)
									RDY->RDY_TEXTO := DecodeUTF8( alltrim(cJustify) )
									MsUnLock()
								EndIf
							EndIf	
						EndIf

						//Atualiza registro de imagem se houver
						If lBitMap
							If !Empty(cFileType) .And. !Empty(cFileContent)
								cNameArq := RH3->RH3_FILIAL +"_"+ RH3->RH3_CODIGO
								If !fSetBcoFile( cFileContent, cNameArq, cFileType, @cErro, RH3->RH3_EMP )
									lRet := .F.
									Break
								EndIf
							EndIf
							If lRet
								RH3->( RecLock("RH3", .F.) )
								RH3->RH3_BITMAP := cNameArq
								RH3->( MsUnLock() )
							EndIf
						EndIf

					End Transaction
				Else
					lRet  := .F.
					cErro := EncodeUTF8(STR0007) //"Já existe abono cadastrado para essa data/hora"
				EndIf
			EndIf
		EndIf
	EndIf
		
	If lRet
		HttpSetStatus(204)
	Else	
		lRet := .F.
		SetRestFault(400, cErro)
	EndIf  

	FreeObj(oItemDetail)

	cModulo := cBkpMod

Return lRet

WSMETHOD GET occasionalDays PATHPARAM employeeId WSREST Timesheet

	Local oItem		 	:= JsonObject():New()
	Local lHabil      	:= .T.
	Local cJson			:= ""
	Local cToken        := ""
	Local cKeyId        := ""
	Local cBranchVld	:= ""
	Local cMatSRA		:= ""
	Local cLogin		:= ""
	Local cRD0Cod		:= ""
	Local cEmpAtu		:= cEmpAnt
	Local aDataLogin	:= {}
	Local aIdFunc		:= {}
	Local initPeriod    := StoD( Format8601(.T.,Self:initPeriod,,.T.) )
	Local endPeriod     := StoD( Format8601(.T.,Self:endPeriod,,.T.) )

	DEFAULT Self:id		:= ""

	::SetHeader('Access-Control-Allow-Credentials' , "true")

	cToken		:= Self:GetHeader('Authorization')
	cKeyId 		:= Self:GetHeader('keyId')

	aDataLogin := GetDataLogin(cToken, .T., cKeyId)
	If Len(aDataLogin) > 0
		cMatSRA    := aDataLogin[1]
		cLogin     := aDataLogin[2]
		cRD0Cod    := aDataLogin[3]
		cBranchVld := aDataLogin[5]
	EndIf

	If !( "current" $ Self:employeeId )
		aIdFunc := STRTOKARR( Self:employeeId, "|" )
		If Len(aIdFunc) > 0
			//Valida Permissionamento
			fPermission(cBranchVld, cLogin, cRD0Cod, "teamManagementTimesheet", @lHabil, cMatSRA)
			cBranchVld	:= aIdFunc[1]
			cMatSRA		:= aIdFunc[2]
			cEmpAtu		:= aIdFunc[3]
		EndIf
	Else
		//Valida Permissionamento
		fPermission(cBranchVld, cLogin, cRD0Cod, "timesheet", @lHabil)
	EndIf

	If lHabil
		If !(cEmpAnt == cEmpAtu)
			oItem := GetDataForJob( "16", {cBranchVld, cMatSRA, initPeriod, endPeriod }, cEmpAtu )
		Else
			oItem := fMontaOcc( cBranchVld, cMatSRA, initPeriod, endPeriod )
		EndIf
	EndIf

	cJson := oItem:ToJson()
	::SetResponse(cJson)

	FreeObj( oItem )

Return .T.

//"Retorna o arquivo .pdf do extrato de horas"
// Rota: /timesheet/clockings/hoursExtract/{employeeID}
WSMETHOD GET GetHoursExtract PATHPARAM employeeId WSREST Timesheet

	Local aDataLogin	:= {}
	Local aFile         := {}
	Local aIdFunc       := {}
	Local aParams       := {"","","","",""}
	Local cToken        := ""
	Local cKeyId        := ""
	Local cBranchToken	:= ""
	Local cEmpToken     := cEmpAnt
	Local cErrFileName  := ""
	Local cFileError    := ""
	Local cMatToken		:= ""
	Local cLoginToken   := ""
	Local cRD0CodToken  := ""
	Local cEmpParam     := ""
	Local cBranchParam  := ""
	Local cMatParam     := ""
	Local cRestFault    := ""
	Local dInicio       := Ctod("//")
	Local dFim          := Ctod("//")
	Local lRet          := .T.
	Local lDemit        := .F.
	Local lPathParam    := .F. //Verifica se é o pathParam foi informado.
	Local lMesmoFunc    := .F. //Verifica se é um funcionário solicitando dados de outro.

	DEFAULT Self:initPeriod := ""
	DEFAULT Self:endPeriod  := ""
	
	::SetHeader('Access-Control-Allow-Credentials' , "true")

	cToken := Self:GetHeader('Authorization')
	cKeyId := Self:GetHeader('keyId')

	//Dados do Token
	aDataLogin := GetDataLogin(cToken, .T., cKeyId)

	//Valida se o token veio no formato correto.
	lRet       := Len(aDataLogin) > 5
	cRestFault := If(!lRet, STR0092, cRestFault) //"Permissão negada ao serviço de extrato de horas!"

	If lRet
		cMatToken    := aDataLogin[1]
		cLoginToken  := aDataLogin[2]
		cRD0CodToken := aDataLogin[3]
		cBranchToken := aDataLogin[5]
		lDemit       := aDataLogin[6]
	EndIf

	//Verifica se o funcionário foi demitido.
	If lRet
		lRet       := !lDemit
		cRestFault := If(!lRet .And. Empty(cRestFault), STR0092, cRestFault) //"Permissão negada ao serviço de extrato de horas!"	
	EndIf

	//Busca dados do pathParam, caso tenha sido preenchido.
	If lRet
		//Verifica se os dados do solicitação vieram via PathParam.
		lPathParam := !("current" $ Self:employeeId)
		//Busca os dados no PathParam
		If lPathParam
			aIdFunc := STRTOKARR( Self:employeeId, "|" )
			//Verifica se os dados vieram corretamente
			lRet := Len(aIdFunc) > 2
			If lRet
				cBranchParam := aIdFunc[1]
				cMatParam    := aIdFunc[2]
				cEmpParam    := aIdFunc[3]
				lMesmoFunc   := (cBranchToken == cBranchParam .And. cMatToken == cMatParam .And. cEmpAnt == cEmpParam)
			EndIf
		EndIf
		cRestFault := If(!lRet .And. Empty(cRestFault), STR0093, cRestFault) //Dados enviados inválidos!
	EndIf

	//Validação das permissões.
	If lRet
		//Funcionário solicitando para ele mesmo, ou gestor solicitando para ele mesmo.
		If !lPathParam .Or. (lPathParam .And. lMesmoFunc)
			//Valida Permissionamento
			fPermission(cBranchToken, cLoginToken, cRD0CodToken, "hoursExtract", @lRet)
			cRestFault := If(!lRet .And. Empty(cRestFault), STR0092, cRestFault) //"Permissão negada ao serviço de extrato de horas!"
			If lRet
				aParams[1] := cBranchToken
				aParams[2] := cMatToken
				aParams[3] := cEmpToken
			EndIf
		//Funcionário (gestor ou não) solicitando para outro funcionário.
		Else
			//Valida Permissionamento do solicitante.
			fPermission(cBranchToken, cLoginToken, cRD0CodToken, "teamManagementHoursExtract", @lRet)
			cRestFault := If(!lRet .And. Empty(cRestFault), STR0092, cRestFault) //"Permissão negada ao serviço de extrato de horas!"
			If(lRet)
				//Caso tenha permissionamento, verifica se o funcionário solicitante tem acesso ao funcionário solicitado.
				lRet       := getPermission(cBranchToken, cMatToken, cBranchParam, cMatParam, cEmpToken, cEmpParam)
				cRestFault := If(!lRet .And. Empty(cRestFault), STR0077, cRestFault) // Você está tentando acessar dados de um funcionário que não faz parte do seu time.
				If lRet
					aParams[1] := cBranchParam
					aParams[2] := cMatParam
					aParams[3] := cEmpParam
				EndIf		
			EndIf
		EndIf		
	EndIf

	//Caso tenha permissão, busca dados do QueryParam.
	//Caso QueryParam não seja informado, ou informado fora do padrão, deixa dInicio e dFim em branco.
	//Valida se os parâmetros estão preenchidos corretamente(filial, matrícula, empresa)
	If lRet
		dInicio := If(lPathParam, CTOD(Format8601(.T., Self:initPeriod, .F., .F.)), dInicio)
		dFim    := CTOD(Format8601(.T., Self:endPeriod, .F., .F.))
		aParams[4] := dInicio
		aParams[5] := dFim
		lRet       := (Len(aParams) == 5 .And. !Empty(aParams[1]) .And. !Empty(aParams[2]) .And. !Empty(aParams[3]))
		cRestFault := If(!lRet .And. Empty(cRestFault), STR0094, cRestFault) //Problemas na geração do extrato de horas!
	EndIf

	//Se estiver tudo correto faz a chamada da função/JOB.
	If lRet
		//Chamada do JOB - Chama fMrhExtBh ou U_fExtBHoras(RHNPMEURH) via RDMAKE
		//aFile[1] - Conteúdo do PDF - Caractere.
		//aFile[2] - Nome do arquivo PDF - Caractere.
		//aFile[3] - Indica se houve erro na geração do arquivo - Lógico
		//aFile[4] - Mensagem de erro - Caractere
		aFile := GetDataForJob("19", aParams, aParams[3])
		//Verifica se o objeto oFile foi gerado corretamente.
		lRet       := (aFile != Nil .And. Len(aFile) == 4)
		cRestFault := If(!lRet .And. Empty(cRestFault), STR0094, cRestFault) //Problemas na geração do extrato de horas!

		If lRet
			lRet       := !aFile[3]
			cRestFault := If(!lRet .And. Empty(cRestFault) .And. !Empty(aFile[4]), aFile[4], cRestFault)	
		EndIf	
	EndIf


	//Valida se o arquivo foi gerado corretamente.
	If lRet
		lRet       := (!Empty(aFile[1]) .And. !Empty(aFile[2]))
		cRestFault := If(!lRet .And. Empty(cRestFault), STR0094, cRestFault) //Problemas na geração do extrato de horas!		
	EndIf

	//Caso tenha ocorrido tudo com sucesso, devolve o PDF para o usuário.
	If lRet
		Self:SetHeader("Content-Disposition", "attachment; filename=" + aFile[2])
		Self:SetResponse(aFile[1])
	//Caso tenha ocorrido algum erro de permissão ou geração de arquivo.
	//Gera um PDF com a mensagem de erro informada.
	Else
		//Nome do arquivo de erro, FIL_MAT, vindo do parâmetro ou do token.
		cErrFileName := If(!Empty(cBranchParam) .And. !Empty(cMatParam), AllTrim(cBranchParam) + "_" + AllTrim(cMatParam), cErrFileName)
		cErrFileName := If(!Empty(cBranchToken) .And. !Empty(cMatToken) .And. Empty(cErrFileName), AllTrim(cBranchToken) + "_" + AllTrim(cMatToken), cErrFileName)
		cErrFileName := StrTran(cErrFileName, " ", "_")
		fPDFMakeFileMessage({cRestFault}, cErrFileName, @cFileError)
		cErrFileName += ".pdf"
		Self:SetHeader("Content-Disposition", "attachment; filename=" + cErrFileName)
		Self:SetResponse(cFileError)
	EndIf
	
Return lRet

//Retorna o Meu horário do funcionário
WSMETHOD GET mySchedule PATHPARAM employeeId WSREST Timesheet

	Local aDataLogin	:= {}
	Local aIdFunc       := {}
	Local cToken        := ""
	Local cKeyId        := ""
	Local cBranchToken	:= ""
	Local cEmpToken     := cEmpAnt
	Local cMatToken		:= ""
	Local cLoginToken   := ""
	Local cRD0CodToken  := ""
	Local cEmpParam     := ""
	Local cBranchParam  := ""
	Local cMatParam     := ""
	Local cEmp          := ""
	Local cFil          := ""
	Local cMat          := ""
	Local cRestFault    := ""
	Local dInicio       := Ctod("//")
	Local dFim          := Ctod("//")
	Local lRet          := .T.
	Local lDemit        := .F.
	Local lPathParam    := .F. //Verifica se é o pathParam foi informado.
	Local lMesmoFunc    := .F. //Verifica se é um funcionário solicitando dados de outro funcionário.
	Local oMySchedule   := Nil

	DEFAULT Self:initPeriod := ""
	DEFAULT Self:endPeriod  := ""
	
	::SetHeader('Access-Control-Allow-Credentials' , "true")

	cToken := Self:GetHeader('Authorization')
	cKeyId := Self:GetHeader('keyId')

	//Dados do Token
	aDataLogin := GetDataLogin(cToken, .T., cKeyId)

	//Valida se o token veio no formato correto.
	lRet       := Len(aDataLogin) > 5
	cRestFault := If(!lRet, STR0093, cRestFault) // Dados enviados inválidos!

	If lRet
		cMatToken    := aDataLogin[1]
		cLoginToken  := aDataLogin[2]
		cRD0CodToken := aDataLogin[3]
		cBranchToken := aDataLogin[5]
		lDemit       := aDataLogin[6]
	EndIf

	//Verifica se o funcionário foi demitido.
	If lRet
		lRet       := !lDemit
		cRestFault := If(!lRet .And. Empty(cRestFault), STR0115, cRestFault) //"Permissão negada ao serviço Meu horário!"	
	EndIf

	//Busca dados do pathParam, caso tenha sido preenchido.
	If lRet
		//Verifica se os dados do solicitação vieram via PathParam.
		lPathParam := !("current" $ Self:employeeId)
		//Busca os dados no PathParam
		If lPathParam
			aIdFunc := STRTOKARR( Self:employeeId, "|" )
			//Verifica se os dados vieram corretamente
			lRet := Len(aIdFunc) > 2
			If lRet
				cBranchParam := aIdFunc[1]
				cMatParam    := aIdFunc[2]
				cEmpParam    := aIdFunc[3]
				lMesmoFunc   := (cBranchToken == cBranchParam .And. cMatToken == cMatParam .And. cEmpAnt == cEmpParam)
			EndIf
		EndIf
		cRestFault := If(!lRet .And. Empty(cRestFault), STR0093, cRestFault) //Dados enviados inválidos!
	EndIf

	//Validação das permissões.
	If lRet
		//Funcionário solicitando para ele mesmo, ou gestor solicitando para ele mesmo.
		If (!lPathParam .Or. (lPathParam .And. lMesmoFunc))
			//Valida Permissionamento do solicitante.
			fPermission(cBranchToken, cLoginToken, cRD0CodToken, "mySchedule", @lRet)
			cRestFault := If(!lRet .And. Empty(cRestFault), STR0115, cRestFault) //"Permissão negada ao serviço Meu horário!"
			If lRet
				cFil := cBranchToken
				cMat := cMatToken
				cEmp := cEmpToken
			EndIf
		//Funcionário (gestor ou não) solicitando para outro funcionário.
		Else
			//Valida Permissionamento do solicitante.
			fPermission(cBranchToken, cLoginToken, cRD0CodToken, "myScheduleManager", @lRet)
			cRestFault := If(!lRet .And. Empty(cRestFault), STR0115, cRestFault) //"Permissão negada ao serviço Meu horário!"
			If lRet
				//Verifica se o funcionário solicitante tem acesso ao funcionário solicitado.
				lRet       := getPermission(cBranchToken, cMatToken, cBranchParam, cMatParam, cEmpToken, cEmpParam)
				cRestFault := If(!lRet .And. Empty(cRestFault), STR0077, cRestFault) // Você está tentando acessar dados de um funcionário que não faz parte do seu time.
				If lRet
					cFil := cBranchParam
					cMat := cMatParam
					cEmp := cEmpParam
				EndIf						
			EndIf
		EndIf				
	EndIf

	If lRet
		dInicio      := CTOD(Format8601(.T., Self:initPeriod, .F., .F.))
		dFim         := CTOD(Format8601(.T., Self:endPeriod, .F., .F.))

		// Chama a fGetMySchedule(RHNP06f) via JOB
		oMySchedule  := JsonObject():New()
		oMySchedule  := GetDataForJob( "20", {cEmp, cFil, cMat, dInicio, dFim}, cEmp)
		//Proteção contra problemas no JOB, caso retorne Nil.
		lRet         := !(ValType(oMySchedule) == "U") 
		cRestFault   := If(!lRet .And. Empty(cRestFault), STR0118, cRestFault) //Problemas na consulta do Meu horário
		If lRet
			lRet       := oMySchedule:hasProperty("success") .And. oMySchedule["success"]
			cRestFault := If(!lRet .And. Empty(cRestFault), oMySchedule['error'], cRestFault)
		EndIf
	EndIf

	If lRet
		oMySchedule:DelName("success")
		cJson := oMySchedule:toJson()
		::SetResponse(cJson)
		FreeObj(oMySchedule)
	Else
		SetRestFault(400, EncodeUTF8(cRestFault))	
	EndIf

Return(lRet)
