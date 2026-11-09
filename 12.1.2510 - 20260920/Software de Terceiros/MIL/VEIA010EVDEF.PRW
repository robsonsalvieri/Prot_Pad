#include 'TOTVS.ch'
#include 'FWMVCDef.ch'
#include "FWEVENTVIEWCONSTS.CH"

CLASS VEIA010EVDEF FROM FWModelEvent

	Data cEVENTO   // Evento

	METHOD New() CONSTRUCTOR
    METHOD VldActivate()
	METHOD ModelPosVld()

ENDCLASS

// New //
METHOD New() CLASS VEIA010EVDEF
    ::cEVENTO := ""
RETURN .T.

//Validação antes da abertura da tela
METHOD VldActivate(oModel, cModelId) CLASS VEIA010EVDEF	
If Type("cCodEve") <> "U" 
    ::cEVENTO := cCodEve // Codigo do Evento
EndIf
RETURN .t.

// Tudo OK da Tela //
METHOD ModelPosVld(oModel, cId) CLASS VEIA010EVDEF
	Local nCntFor := 0
	Local oModAux
	If !Empty(::cEVENTO) .and. ( oModel:GetOperation() == MODEL_OPERATION_INSERT .or. oModel:GetOperation() == MODEL_OPERATION_UPDATE ) // Incluir ou Alterar
		oModAux := oModel:GetModel("VEUMASTER")
        oModAux:LoadValue( "VEU_EVENTO" , ::cEVENTO )
		oModAux := oModel:GetModel("VEUDETAIL")
		For nCntFor := 1 to oModAux:Length()
			oModAux:GoLine(nCntFor)
			If Empty(oModAux:GetValue("VEU_EVENTO"))
				oModAux:LoadValue( "VEU_EVENTO" , ::cEVENTO )
			EndIf
		Next
	EndIf
RETURN .t.