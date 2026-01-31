#include 'TOTVS.ch'
#Include "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#include "FWEVENTVIEWCONSTS.CH"
#INCLUDE 'OFIA535.CH'
#INCLUDE 'TOPCONN.CH'

CLASS OFIA535EVDEF FROM FWModelEvent

	METHOD New() CONSTRUCTOR
	METHOD ModelPosVld()

ENDCLASS


METHOD New() CLASS OFIA535EVDEF

RETURN .T.

METHOD ModelPosVld(oModel, cModelId) CLASS OFIA535EVDEF

	Local lRet := .t.
	Local oModVBZ := oModel:GetModel("VBZMASTER")

	If oModel:GetOperation() == MODEL_OPERATION_INSERT .or. oModel:GetOperation() == MODEL_OPERATION_UPDATE

		If Empty( oModVBZ:GetValue("VBZ_PROGRM") + oModVBZ:GetValue("VBZ_CLIENT") + oModVBZ:GetValue("VBZ_TIPO") )
			FMX_HELP("OA535ERR001", STR0003, STR0004 + Alltrim(RetTitle("VBZ_PROGRM")) + "/" + Alltrim(RetTitle("VBZ_CLIENT")) + "/" + Alltrim( RetTitle("VBZ_TIPO") ) ) // "Campos não preenchidos" / "Informe um dos campos "
			lRet := .f.
		EndIf

	EndIf

RETURN lRet
