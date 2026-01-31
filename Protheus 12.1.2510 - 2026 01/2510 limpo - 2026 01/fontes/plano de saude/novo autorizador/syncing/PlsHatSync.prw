#include "TOTVS.CH"
#include "AutSysLog.CH"
#include "hatActions.ch"

#define __SIZEPAGE "30"

/*/{Protheus.doc} PlsHatSync
Funcao responsavel pela chamada das integracaos PLS x HAT 
@author  pls
@version P12
@since    11/03/2020
/*/
function PlsHatSync(nSyncId, lAuto, cJsonAuto)
	local oSyncHandler  := nil
	local lRet          := .t.
	Default lAuto       := .F.
	Default cJsonAuto   := ''

	oSyncHandler := SyncHandler():New(nSyncId, lAuto, cJsonAuto)

	// Seta o tamanho da pagina
	oSyncHandler:setPageSize(__SIZEPAGE)

	oSyncHandler:addExpand("healthProvider")
	oSyncHandler:addExpand("professional")
	oSyncHandler:addExpand("procedures.rejectionCauses")
	oSyncHandler:addExpand("beneficiary")
	oSyncHandler:addExpand("cbos")
	oSyncHandler:addExpand("rejectionCauses")
	oSyncHandler:addExpand("healthInsurance")

	do case
	case nSyncId == SYNC_AUTHORIZATIONS .or. nSyncId == SYNC_AUTHORIZATIONS + SYNC_CANCELLATIONS

		oSyncHandler:addExpand("medicalTeam")
		oSyncHandler:addExpand("requestedHospitalInfo")
		oSyncHandler:addExpand("authorizedHospitalInfo")
		oSyncHandler:addExpand("sourceAuthorization")
		oSyncHandler:addOrder("-authorizationId")

		if nSyncId == SYNC_AUTHORIZATIONS
			oSyncHandler:addQueryParam({"trackingStatus", "0"})
		else
			oSyncHandler:addQueryParam({"trackingStatus", "1"})
			oSyncHandler:addQueryParam({"authStatus", "C"}) // Pega só o que está cancelado
		endIf

	case nSyncId == SYNC_CLINICAL_ATTACHMENTS .or. nSyncId == SYNC_CLINICAL_ATTACHMENTS + SYNC_CANCELLATIONS

		oSyncHandler:addExpand("medicalTeam")
		oSyncHandler:addExpand("requestedHospitalInfo")
		oSyncHandler:addExpand("authorizedHospitalInfo")
		oSyncHandler:addExpand("sourceAuthorization")
		oSyncHandler:addOrder("-id")

		if nSyncId == SYNC_CLINICAL_ATTACHMENTS
			oSyncHandler:addQueryParam({"trackingStatus", "0"})
		else
			oSyncHandler:addQueryParam({"trackingStatus", "1"})
			oSyncHandler:addQueryParam({"cancel", "1"}) // Pega só o que está cancelado
		endIf

	case nSyncId == SYNC_TREATMENT_EXTENSIONS .or. nSyncId == SYNC_TREATMENT_EXTENSIONS + SYNC_CANCELLATIONS

		oSyncHandler:addOrder("-id")

		if nSyncId == SYNC_TREATMENT_EXTENSIONS
			oSyncHandler:addQueryParam({"trackingStatus", "0"})
		else
			oSyncHandler:addQueryParam({"trackingStatus", "1"})
			oSyncHandler:addQueryParam({"cancel", "1"}) // Pega só o que está cancelado
		endIf

	endCase

	lRet := oSyncHandler:setupRequest()
	if lRet
		lRet := oSyncHandler:initRequest()
		if lRet
			lRet := oSyncHandler:sync()
		endIf
	endIf

	oSyncHandler:destroy()

	FreeObj(oSyncHandler)
	oSyncHandler := nil

return lRet