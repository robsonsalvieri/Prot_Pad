#include 'TOTVS.ch'
#Include "PROTHEUS.CH"
#include 'FWMVCDef.ch'
#include "FWEVENTVIEWCONSTS.CH"

CLASS OFIA485EVDEF FROM FWModelEvent

	METHOD New() CONSTRUCTOR
	METHOD GridLinePreVld()

ENDCLASS


METHOD New() CLASS OFIA485EVDEF

RETURN .T.


METHOD GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) CLASS OFIA485EVDEF

If cModelID == "MODSDF" .and. cAction == "SETVALUE" .and. Upper(cId) == "CDTIPPED"
	oModel := FWModelActive()
	oModSug := oModel:GetModel('MODSFJ' )
	OA4850155_TipoPedido( oModSug:GetValue( "SFJTIPPED" ), oModSug:GetValue( "SFJCODSUG" ) )
EndIf

RETURN .T.
