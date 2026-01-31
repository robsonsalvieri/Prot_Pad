#include "TBICONN.CH"
#include "TOTVS.CH"
#include "AutSysLog.CH"
#include "hatActions.ch"

#define ISJOBON "ISJOBON_SYNCHANDLER"
#define LOGHAT "ISLOG_SYNCHANDLER"
#define MAINTHREAD "NAME_THREAD_GLOBAL_SYNCHANDLER"
#define HASERROR "HASERROR_SYNCHANDLER"
#define PERSISTWORK "SYNCHANDLER_PERSISTE_WORK"

#define IDJOB 'SYNCHANDLER'
#define TYPEJOB 'IPC'
#define SESSIONKEY ''
#define TIMETHREADREVIEW 300
#define THREADMINSTART 0
#define THREADMAXSTART 10
#define THREADMINFREE 1
#define THREADINCREMENTFREE 1

/*/{Protheus.doc} SyncHandler
    Synchronizer que faz a ponte de dados HAT x PLS
    @type  Class
    @author pld
    @since 12/03/2021
/*/
Class SyncHandler

	Data lSuccess
	Data lHasNext
	Data nApiReference
	Data aHeader
	Data nCurrentItem
	Data nItemSize
	Data lCancel
	Data lAuto
	Data cJsonAuto

	Data oClient
	Data oLogger
	Data oRespBody

	Data cPath
	Data aFields
	Data aExpand
	Data aQueryParams
	Data aOrder
	Data cPage
	Data cPageSize
	Data cEndPoint
	Data cIdJob as string
	Data cFile

	Method New(nApiReference)

	Method sync()

	Method initJob()
	Method jobExec()

	Method setupRequest()
	Method initRequest()
	Method setupLogger()

	Method addField(cField)
	Method addExpand(cExpand)
	Method addQueryParam(aQueryParam)
	Method addOrder(cOrder)
	Method setPageSize(cPageSize)
	Method getDataFromClient()
	Method getPage()
	Method getPageSize(cPageSize)
	Method generatePath()
	Method isWorking()
	Method procAuto(cJson,cTrack,lCancelado)

	Method hasNext()
	Method hasItens()
	Method getNextItem()
	Method destroy()

EndClass

Method New(nApiReference, lAuto, cJsonAuto) Class SyncHandler
	local aData         := dataApiReference(nApiReference)
	default lAuto       := .F.
	default cJsonAuto   := ""

	self:lAuto          := lAuto
	self:cJsonAuto      := cJsonAuto
	self:nApiReference  := nApiReference
	self:aHeader        := {}
	self:aFields        := {}
	self:aExpand        := {}
	self:aQueryParams   := {}
	self:aOrder         := {}
	self:lSuccess       := .t.
	self:lHasNext       := .t.

	self:oClient        := nil
	self:oRespBody      := nil
	self:oLogger        := nil

	self:cPage          := '1' //sempre um porque os registros retornados ja serao processados pela tracitem.
	self:nCurrentItem   := 0
	self:nItemSize      := 0
	self:cEndPoint      := getNewPar("MV_PHATURL","")

	self:cFile  := aData[1]
	self:cPath  := aData[2]
	self:lCancel:= aData[3]

	self:setupLogger()

return self

Method sync() Class SyncHandler
	local cTrack     := ''
	local lCancelado := .f.
	local oItem      := nil
	local lContinua  := .t.

	while lContinua .and. self:hasNext() .and. self:getDataFromClient()

		while lContinua .and. self:hasItens()

			oItem := self:getNextItem()

			do case
			case self:nApiReference == SYNC_AUTHORIZATIONS .or. self:nApiReference == SYNC_AUTHORIZATIONS + SYNC_CANCELLATIONS

				cTrack := oItem["idOnHealthProvider"]

				if self:lCancel
					lCancelado := oItem["authorizationStatus"] == "9"
				endIf

			case self:nApiReference == SYNC_CLINICAL_ATTACHMENTS .or. self:nApiReference == SYNC_CLINICAL_ATTACHMENTS + SYNC_CANCELLATIONS

				cTrack := oItem["attachNumber"]

				if self:lCancel
					lCancelado := oItem["isCancelled"]
				endIf

			case self:nApiReference == SYNC_TREATMENT_EXTENSIONS .or. self:nApiReference == SYNC_TREATMENT_EXTENSIONS + SYNC_CANCELLATIONS

				cTrack := oItem["treatmentExtensionNumber"]

				if self:lCancel
					lCancelado := oItem["isCancelled"]
				endIf

			endCase

			if self:lAuto
				lContinua := self:procAuto(oItem:toJson(),cTrack,lCancelado)
			elseif ! self:lCancel
				lContinua := self:jobExec(oItem, .f., cTrack)
			elseIf lCancelado
				lContinua := self:jobExec(oItem, lCancelado, cTrack)
			endIf

		enddo

		chkThRead('MONITOR', self:nApiReference)

	endDo

	FreeObj(oItem)
	oItem := nil

return self:isWorking()

Method isWorking() Class SyncHandler
	local isWork := isWorkSync()

	if ! isWork
		clearGlbValue(LOGHAT)
		clearGlbValue(HASERROR + getGlbValue(MAINTHREAD))
		clearGlbValue(MAINTHREAD)
		clearGlbValue(PERSISTWORK + cValToChar(self:nApiReference))
	endIf

return isWork

Method initJob() Class SyncHandler
	local cServerIni            := GetAdv97()
	local cSessao               := 'JOBSRV'
	local cTypeJob              := GetPvProfString(cSessao, "TYPEJOB", TYPEJOB, cServerIni)
	local cSessionKey           := GetPvProfString(cSessao, "SESSIONKEY", SESSIONKEY, cServerIni)
	local cEnvServer            := GetPvProfString(cSessao, "ENVSERVER", GetEnvServer(), cServerIni)
	local nTimeThReadReview     := GetPvProfileInt(cSessao, "TIMETHREADREVIEW", TIMETHREADREVIEW, cServerIni)
	local nThReadMinStart       := GetPvProfileInt(cSessao, "THREADMINSTART", THREADMINSTART, cServerIni)
	local nThReadMaxStart       := GetPvProfileInt(cSessao, "THREADMAXSTART", THREADMAXSTART, cServerIni)
	local nThReadMinFree        := GetPvProfileInt(cSessao, "THREADMINFREE", THREADMINFREE, cServerIni)
	local nThReadIncrementFree  := GetPvProfileInt(cSessao, "THREADINCREMENTFREE", THREADINCREMENTFREE, cServerIni)

	self:cIdJob := GetPvProfString(cSessao, "IDJOB", IDJOB, cServerIni)

	if getGlbValue(ISJOBON) != 'true'

		ManualJob(  self:cIdJob,;
			cEnvServer,;
			cTypeJob,;
			'__JOBISTAR',;
			'__JOBSIPCG',;
			'__JOBISTOP',;
			cSessionKey,;
			nTimeThReadReview,;
			nThReadMinStart,;
			nThReadMaxStart,;
			nThReadMinFree,;
			nThReadIncrementFree)

		PutGlbValue(ISJOBON, 'true')

	endIf

return self:isWorking()

Method jobExec(oParam, lCancelado, cTrack) Class SyncHandler
	default lCancelado := .f.

	while !IpcGo(self:cIdJob, oParam:toJson(), lCancelado, self:nApiReference, self:cPath, cTrack, self:cFile, self:lAuto)

		loginf('[' + dataApiReference(self:nApiReference)[1] + '] - Aguardando processamento [' + cTrack  + ']...',self:cFile,,,.t.)
		sleep(500)

	endDo

return self:isWorking()

Method initRequest() Class SyncHandler
	local lSerialized   := .f.
	local cStatusCode   := ''
	local cMessage      := ''
	local cDetail       := ''
	local oJson         := nil

	self:lSuccess := iif(self:lAuto, .t. ,self:oClient:Get(self:aHeader))

	oJson         := JsonObject():New()
	lSerialized   := iif(self:lAuto, .t., empty(oJson:fromJson(self:oClient:GetResult())))

	if self:lSuccess

		self:lSuccess := lSerialized

		if lSerialized
			logInf("Comunicacao com o HAT estabelecida com sucesso",self:cFile)
		else
			logInf("Comunicacao nao estabelecida com o HAT",self:cFile)
		endif

	else

		cStatusCode := oJson["code"]
		cMessage    := oJson["message"]

		if empty(cStatusCode)

			cStatusCode := "500"
			cMessage    := '[' + dataApiReference(self:nApiReference)[1] + '] HealthCheck do servidor do HAT retornou StatusCode:' + cStatusCode
			cDetail     := iIf(valType(self:oClient:GetResult()) <> 'U', self:oClient:GetResult(), '') + ' - ' + iIf(valType(self:oClient:cInternalError) <> 'U', self:oClient:cInternalError, '')

			UserException(cMessage + iIf( ! empty(cDetail), CRLF + 'Detalhe: ' + cDetail, '' ))

		endIf

		logInf('[' + dataApiReference(self:nApiReference)[1] + '] - ' + cMessage + iIf( ! empty(cDetail), CRLF + 'Detalhe: ' + cDetail, '' ), self:cFile,,,.t.)

	endif

	FreeObj(oJson)
	oJson := nil

	if self:lSuccess
		self:lSuccess := self:isWorking()
	endIf

return self:lSuccess

Method setupRequest() Class SyncHandler
	local nX         := 0
	local aDadHeader := {}

	if ! empty(self:cEndPoint)

		if Substr(self:cEndPoint, len(self:cEndPoint),1) <> "/"
			self:cEndPoint += "/"
		endIf

		self:oClient := FWRest():New(self:cEndPoint)
		self:oClient:setPath("v1/healthcheck")

		aadd(aDadHeader,{"authorization",getNewPar("MV_PHATTOK","" )})
		aadd(aDadHeader,{"idTenant"     ,getNewPar("MV_PHATIDT","" )})
		aadd(aDadHeader,{"tenantName"   ,getNewPar("MV_PHATNMT","" )})

		for nX := 1 to len(aDadHeader)

			if empty(aDadHeader[nX,2])
				self:lSuccess := .f.
				exit
			else
				aAdd(self:aHeader,aDadHeader[nX,1] + ": " + aDadHeader[nX,2] )
			endIf

		next

		if ! self:lSuccess
			UserException("Nao foi possivel realizar a comunicacao com o HAT, dados do cabeaalho da requisicao estao incorretos.")
		else
			self:initJob()
		endIf

	endif

	if self:lSuccess
		self:lSuccess := self:isWorking()
	endIf

return self:lSuccess

Method setupLogger() Class SyncHandler
	local cThRead := allTrim(str(thReadID()))

	self:oLogger := logger():New()
	self:oLogger:setLevel(3)
	self:oLogger:setType(TYPE_SYSLOG)
	self:oLogger:setPath("")
	self:oLogger:setup()

	PutGlbValue(LOGHAT, iIF(GetNewPar("MV_PHATLOG","0") == "1", 'true', 'false'))

	PutGlbValue(MAINTHREAD, cThRead)
	PutGlbValue(HASERROR + cThRead, 'false')

return self:isWorking()

Method addField(cField) Class SyncHandler
	aAdd(self:aFields, cField)
return

Method addExpand(cExpand) Class SyncHandler
	aAdd(self:aExpand, cExpand)
return

Method addQueryParam(aQueryParam) Class SyncHandler
	aAdd(self:aQueryParams, aQueryParam)
return

Method addOrder(cOrder) Class SyncHandler
	aAdd(self:aOrder, cOrder)
return

Method setPageSize(cPageSize) Class SyncHandler
	self:cPageSize := cPageSize
return

Method getDataFromClient() Class SyncHandler
	local cStatusCode   := ''
	local cMessage      := ''
	local cDetail       := ''
	local lSerialized   := .F.

	if self:lSuccess

		if !self:lAuto
			self:oClient:setPath(self:cPath + "?" + self:getPage() + "&" + self:getPageSize() + self:generatePath())
		endIf

		self:lSuccess   := iif(self:lAuto, .t., self:oClient:Get(self:aHeader))
		self:oRespBody  := JsonObject():New()

		lSerialized     := iif(self:lAuto, empty(self:oRespBody:fromJson(self:cJsonAuto)), empty(self:oRespBody:fromJson(self:oClient:GetResult())))

		if self:lSuccess .and. valType(self:oRespBody["code"]) <> 'U'
			self:lSuccess := self:oRespBody["code"] == 200
		endIf

		if self:lSuccess

			if lSerialized

				self:nCurrentItem   := 1
				self:nItemSize      := len(self:oRespBody["items"])
				self:lSuccess       := iif(self:nItemSize > 0,.T.,.F.)
				self:lHasNext       := self:oRespBody["hasNext"]

			else

				self:lHasNext := .f.

				If !self:lAuto
					UserException("Erro ao serializar resposta da API")
				EndIf
			endif

		else

			self:lSuccess   := .f.
			self:lHasNext   := .f.
			cStatusCode     := self:oRespBody["code"]
			cMessage        := self:oRespBody["message"]

			if empty(cStatusCode)

				cStatusCode := "500"
				cMessage    := '[' + dataApiReference(self:nApiReference)[1] + '] - HealthCheck do servidor do HAT retornou StatusCode:' + cStatusCode
				cDetail     := iIf(valType(self:oClient:GetResult()) <> 'U', self:oClient:GetResult(), '') + ' - ' + iIf(valType(self:oClient:cInternalError) <> 'U', self:oClient:cInternalError, '')

				UserException(cMessage + iIf( ! empty(cDetail), CRLF + 'Detalhe: ' + cDetail, '' ))

			endIf

			loginf('[' + dataApiReference(self:nApiReference)[1] + '] - ' + cMessage + iIf( ! empty(cDetail), CRLF + 'Detalhe: ' + cDetail, '' ), self:cFile,,, .t.)

		endIf

	endif

	if self:lSuccess
		self:lSuccess := self:isWorking()
	endIf

return iIf(self:lAuto, .T., self:lSuccess)

Method getPage() Class SyncHandler
return "page=" + self:cPage

Method getPageSize() Class SyncHandler
return "pageSize=" + self:cPageSize

Method generatePath() Class SyncHandler
	Local cPath := ""
	Local nControl := 1
	Local nLenFields := len(self:aFields)
	Local nLenExpand := len(self:aExpand)
	Local nLenOrder := len(self:aOrder)
	Local nLenQueryParam := len(self:aQueryParams)

	// Aplica o parametro fields
	if nLenFields > 0
		cPath += "&fields="
		while nControl <= nLenFields
			cPath += self:aFields[nControl]
			iif(nControl < nLenFields,cPath += ",",nil)
			nControl++
		enddo
		nControl := 1
	endif

	// Aplica o parametro expand
	if nLenExpand > 0
		cPath += "&expand="
		while nControl <= nLenExpand
			cPath += self:aExpand[nControl]
			iif(nControl < nLenExpand,cPath += ",",nil)
			nControl++
		enddo
		nControl := 1
	endif

	// Aplica o parametro expand
	if nLenOrder > 0
		cPath += "&order="
		while nControl <= nLenOrder
			cPath += self:aOrder[nControl]
			iif(nControl < nLenOrder,cPath += ",",nil)
			nControl++
		enddo
		nControl := 1
	endif

	// Aplica os parametros queryString
	if nLenQueryParam > 0
		cPath += "&"
		while nControl <= nLenQueryParam
			cPath += self:aQueryParams[nControl][1] + "=" + self:aQueryParams[nControl][2]
			iif(nControl < nLenQueryParam,cPath += "&",nil)
			nControl++
		enddo
		nControl := 1
	endif

return cPath

Method hasNext() Class SyncHandler
return self:lHasNext

Method hasItens() Class SyncHandler
return self:nCurrentItem <= self:nItemSize .And. self:nCurrentItem > 0 .And. self:nItemSize > 0

Method getNextItem() Class SyncHandler
	Local oItem := self:oRespBody["items"][self:nCurrentItem]
	self:nCurrentItem++
return oItem

Method destroy() Class SyncHandler

	clearGlbValue(HASERROR + getGlbValue(MAINTHREAD))
	clearGlbValue(MAINTHREAD)
	clearGlbValue(PERSISTWORK + cValToChar(self:nApiReference))

	FreeObj(self:oRespBody)
	self:oRespBody := nil

	FreeObj(self:oLogger)
	self:oLogger := nil

	FreeObj(self:oClient)
	self:oClient := nil

	DelClassIntf()

return

Method procAuto(cJson,cTrack,lCancelado) Class SyncHandler

	Local oParam := JsonObject():New()
	Local oPersist
	Local lRet   := .T.

	oParam:fromJson(cJson)

	do case
	case self:nApiReference == SYNC_AUTHORIZATIONS .or. self:nApiReference == SYNC_AUTHORIZATIONS + SYNC_CANCELLATIONS
		oPersist := SyncAuthorizations():new(cTrack, self:cFile)
	case self:nApiReference == SYNC_CLINICAL_ATTACHMENTS .or. self:nApiReference == SYNC_CLINICAL_ATTACHMENTS + SYNC_CANCELLATIONS
		oPersist := SyncClinicalAttach():new(cTrack, self:cFile)
	case self:nApiReference == SYNC_TREATMENT_EXTENSIONS .or. self:nApiReference == SYNC_TREATMENT_EXTENSIONS + SYNC_CANCELLATIONS
		oPersist := SyncTreatmentExtensions():new(cTrack, self:cFile)
	endCase

	if ! lCancelado
		oPersist:persist(oParam,.T.)
	else
		oPersist:persistCancel(oParam,.T.)
	endIf

	FreeObj(oParam)
	oParam := nil

	FreeObj(oPersist)
	oPersist := nil

	if (self:nCurrentItem - 1) >= len(self:oRespBody["items"])
		lRet := .F.
	endIf

Return lRet


function __JOBISTAR()
	local cEnv    := getEnvServer()
	local cEmp    := allTrim(GetPvProfString(cEnv,"JEMP","",GetADV97()))
	local cFil    := allTrim(GetPvProfString(cEnv,"JFIL","",GetADV97()))
	local oBlock  := errorBlock( { |e| exceptErro(e) } )
	local lRet    := .t.

	BEGIN SEQUENCE

		nModulo := 33

		rpcSetType(3)
		lRet := rpcSetEnv(cEmp, cFil,,,'PLS', IDJOB)

		if ! lRet
			UserException('Ambiente JOBISTAR nao iniciado')
		endIf

		RECOVER
		lRet := .f.
		errorBlock(oBlock)
	END SEQUENCE

return lRet

function __JOBSIPCG(cJson, lCancelado, nApiReference, cPath, cTrack, cFile, lAuto)
	local oPersist  := nil
	local oTrack    := nil
	local oParam    := JsonObject():new()
	local oBlock    := errorBlock( { |e| exceptErro(e) } )
	local lRet      := .t.
	local cThRead   := allTrim(Str(thReadID()))

	BEGIN SEQUENCE

		nModulo := 33
		PutGlbValue(HASERROR + cThRead, 'false')

		oParam:fromJson(cJson)

		do case
		case nApiReference == SYNC_AUTHORIZATIONS .or. nApiReference == SYNC_AUTHORIZATIONS + SYNC_CANCELLATIONS
			oPersist := SyncAuthorizations():new(cTrack, cFile)
		case nApiReference == SYNC_CLINICAL_ATTACHMENTS .or. nApiReference == SYNC_CLINICAL_ATTACHMENTS + SYNC_CANCELLATIONS
			oPersist := SyncClinicalAttach():new(cTrack, cFile)
		case nApiReference == SYNC_TREATMENT_EXTENSIONS .or. nApiReference == SYNC_TREATMENT_EXTENSIONS + SYNC_CANCELLATIONS
			oPersist := SyncTreatmentExtensions():new(cTrack, cFile)
		endCase

		logInf('[' + cTrack + '] processando' + iIf(lCancelado,' - CANCELAMENTO',''), cFile)

		BEGIN TRANSACTION

			chkThRead('REGISTER', nApiReference, cTrack)

			if ! lCancelado
				lRet := oPersist:persist(oParam)
			else
				lRet := oPersist:persistCancel(oParam)
			endIf

			if !lRet
				DisarmTransaction()
			endIf

		END TRANSACTION

		logInf('[' + cTrack + '] mudando status' + iIf(lCancelado,' - CANCELAMENTO',''), cFile)

		oTrack  := SyncTrack():new(cPath, cTrack, cFile, nApiReference, lAuto)
		lRet    := oTrack:trackItem( iIf(lCancelado, iIf(lRet, '2', '4'), iIf(lRet, '1', '3')) )

		if ! lRet
			logInf('[' + cTrack + '] erro no processamento' + iIf(lCancelado,' - CANCELAMENTO',''), cFile)
		else
			logInf('[' + cTrack + '] processado com sucesso' + iIf(lCancelado,' - CANCELAMENTO',''), cFile)
		endIf

		FreeObj(oTrack)
		oTrack := nil

		FreeObj(oParam)
		oParam := nil

		FreeObj(oPersist)
		oPersist := nil

		RECOVER
		lRet := .f.
		errorBlock(oBlock)
	END SEQUENCE

return lRet

function __JOBISTOP()

	clearGlbValue(HASERROR + allTrim(Str(thReadID())))

	coNout('Saindo por inatividade de threads JOBISTOP')

	RPCClearEnv()

return .t.
