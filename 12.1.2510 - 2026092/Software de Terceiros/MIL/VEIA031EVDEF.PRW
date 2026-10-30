#include 'TOTVS.ch'
#include 'FWMVCDef.ch'
#include "FWEVENTVIEWCONSTS.CH"

CLASS VEIA031EVDEF FROM FWModelEvent
	data lEnviar // Controla se o registro ja foi enviado para nao entrar em LOOP
	data lIntegDynamics

	METHOD New() CONSTRUCTOR
	METHOD AfterTTS()
	METHOD FieldPreVld()
	METHOD DeActivate()
ENDCLASS

METHOD New() CLASS VEIA031EVDEF
	self:lEnviar := .f.
	self:lIntegDynamics := OA2610123_integraDynamics(.F.)
RETURN

METHOD AfterTTS(oModel, cModelId) CLASS VEIA031EVDEF
	if self:lIntegDynamics
		self:lEnviar := .t.
	endif
RETURN .T.

METHOD FieldPreVld(oSubModel, cModelID, cAction, cId, xValue) CLASS VEIA031EVDEF
	if self:lIntegDynamics
		if cModelID == "MODEL_VE1" .and. cAction == "SETVALUE" .and. cId $ "VE1_CODMAR/VE1_DESMAR"
			oSubModel:loadValue("VE1_BBSYNC","0")
		endif
	endif
RETURN .T.

METHOD DeActivate(oModel) CLASS VEIA031EVDEF
	local nOperacao





	// Transmitir registro a John Deere 
	if self:lEnviar == .f.
		return
	endif

	if GetNewPar("MV_MIL0186",.f.) == .f. // Verifica se transmiti automaticamente os registros para o Blackbird
		return 
	endif 
	//

	self:lEnviar := .f.
	nOperacao := oModel:GetOperation()
	if nOperacao == MODEL_OPERATION_INSERT .or. nOperacao == MODEL_OPERATION_UPDATE

//		Conout("Transmissao do VE1 - " + cValToChar(self:lEnviar))

//		Conout("Chamada da rotina de transmissao automatica")
		VA0310013_TransmitirBlackBird("VE1",VE1->(Recno()),4,.f.)
		//
	endif

	if nOperacao == MODEL_OPERATION_DELETE
		if VE1->VE1_BBINTG == "1" // Registro marcado como integrado 
//			Conout("Chamada da rotina de transmissao de EXCLUSAO automatica")
			VA0310023_ExcluirBlackbird("VE1",VE1->(Recno()),4,.f.)
		endif
	endif
RETURN
