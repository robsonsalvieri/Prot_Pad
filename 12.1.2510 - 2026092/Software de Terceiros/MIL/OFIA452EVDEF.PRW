#include 'TOTVS.ch'
#include 'FWMVCDef.ch'
#include "FWEVENTVIEWCONSTS.CH"

CLASS OFIA452EVDEF FROM FWModelEvent

	METHOD New() CONSTRUCTOR
	METHOD InTTS()

ENDCLASS


METHOD New() CLASS OFIA452EVDEF
RETURN .T.


// Chamado dentro da Transação de Gravação //
METHOD InTTS(oModel, cModelId) CLASS OFIA452EVDEF
Local oModVPY := oModel:GetModel("VPYMASTER")
Local cVPZCODEST := oModVPY:GetValue("VPY_CODEST")
// Grava a Movimentação de Estoque do Servico Especializado
OFIA453( cVPZCODEST , cVPZSERINT , cVPZFILMOV , cVPZTIPMOV , cVPZPORMOV , cVPZOPEMOV , nVPZQTDMOV , cVPZFILREL , cVPZCODREL )
RETURN
