#include 'TOTVS.ch'
#include 'FWMVCDef.ch'
#include "FWEVENTVIEWCONSTS.CH"

CLASS OFIA509EVDEF FROM FWModelEvent

	METHOD New() CONSTRUCTOR
	METHOD Activate()

ENDCLASS

// New //
METHOD New() CLASS OFIA509EVDEF
RETURN .T.

// Abertura TELA //
METHOD Activate(oModel, lCopy) CLASS OFIA509EVDEF
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE // Alterar
		oModel:LoadValue( "BASE", "NUMERO_ORCAMENTO", oModel:GetValue( "BASE", "NUMERO_ORCAMENTO" ) ) // Somente para nao aparecer mensagem que nao teve alteração no Formulario
	EndIf
RETURN .T.