#include 'TOTVS.ch'
#include 'FWMVCDef.ch'
#include "FWEVENTVIEWCONSTS.CH"

CLASS VEIA072EVDEF FROM FWModelEvent
	Data lEnviar

	METHOD New() CONSTRUCTOR
	METHOD FieldPreVld()
ENDCLASS

METHOD NEW() CLASS VEIA072EVDEF

RETURN

METHOD FieldPreVld(oSubModel, cModelID, cAction, cId, xValue) CLASS VEIA072EVDEF
	if cModelID == "MODEL_VW0" .and. cAction == "SETVALUE"
		if empty( oSubModel:getValue("VW0_CODIGO") )
			oSubModel:loadValue( "VW0_USERID" , fwFldGet("VK9_USERID") )
			oSubModel:loadValue( "VW0_DATREG" , fwFldGet("VK9_DATREG") )
			oSubModel:loadValue( "VW0_HORREG" , fwFldGet("VK9_HORREG") )
			oSubModel:loadValue( "VW0_CODIGO" , GETSXENUM("VW0","VW0_CODIGO") )
		endif
	endif
RETURN .T.
