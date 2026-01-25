#include "TBICONN.CH"
#include "TOTVS.CH"

/*/{Protheus.doc} SyncTrack
    Atualiza status do item
    @type  Class
    @author pld
    @since 12/03/2021
/*/
Class SyncTrack

	Data lAuto
	Data lSuccess
	Data cPath
	Data cEndPoint
	Data aHeader
	Data cTrack
	Data cFile
	Data nApiReference

	Method New(cPath, cTrack)
	Method trackItem(cStatus)

EndClass

Method New(cPath, cTrack, cFile, nApiReference, lAuto) Class SyncTrack
	local nX         := 1
	local aDadHeader := {}

	self:lAuto          := lAuto
	self:nApiReference  := nApiReference
	self:aHeader        := {}
	self:lSuccess       := .t.
	self:cEndPoint      := getNewPar("MV_PHATURL","")
	self:cPath          := cPath
	self:cTrack         := cTrack
	self:cFile          := cFile

	if ! empty(self:cEndPoint)

		if substr(self:cEndPoint, len(self:cEndPoint),1) <> "/"
			self:cEndPoint += "/"
		endIf

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

	else
		self:lSuccess := .f.
	endIf

	if ! self:lSuccess
		UserException('SyncTrack falhou')
	endIf

return self


Method trackItem(cStatus) Class SyncTrack
	local cJson         := ''
	local oJson         := nil
	local oClient       := nil
	local cStatusCode   := ''
	local cMessage      := ''
	local cDetail       := ''

	cJson := '{ "trackingStatus": "' + cStatus + '" }'

	oClient := FWRest():New(self:cEndPoint)
	oClient:setPath( self:cPath + '/' + self:cTrack)

	self:lSuccess := iif(self:lAuto, .t., oClient:put(self:aHeader, cJson))

	if self:lSuccess
		logInf('[' + self:cTrack + '] status atualizado', self:cFile)
	else

		oJson := JsonObject():New()
		oJson:fromJson(oClient:GetResult())

		cStatusCode := oJson["code"]
		cMessage    := oJson["message"]

		if empty(cStatusCode)

			cStatusCode := '500'
			cMessage    := '[' + dataApiReference(self:nApiReference)[1] + ' - ' + self:cTrack + '] HealthCheck do servidor do HAT retornou StatusCode:' + cStatusCode
			cDetail     := iIf(valType(oClient:getResult()) <> 'U', oClient:getResult(), '') + ' - ' + iIf(valType(oClient:cInternalError) <> 'U', oClient:cInternalError, '')

			UserException(cMessage + iIf( ! empty(cDetail), CRLF + 'Detalhe: ' + cDetail, '' ))

		endIf

		loginf('[' + dataApiReference(self:nApiReference)[1] + ' - ' + self:cTrack + '] ' + cMessage + iIf( ! empty(cDetail), CRLF + 'Detalhe: ' + cDetail, '' ), self:cFile,,, .t.)

		FreeObj(oJson)
		oJson := nil

	endIf

	chkThRead('CHECK', self:nApiReference, self:cTrack)

	FreeObj(oClient)
	oClient := nil

return self:lSuccess
