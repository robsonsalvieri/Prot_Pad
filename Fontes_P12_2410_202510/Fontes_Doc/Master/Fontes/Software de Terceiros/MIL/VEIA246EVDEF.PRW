#include 'TOTVS.ch'
#include 'FWMVCDef.ch'
#include "FWEVENTVIEWCONSTS.CH"

CLASS VEIA246EVDEF FROM FWModelEvent

	data lEnviar // Controla se o registro ja foi enviado para nao entrar em LOOP

	METHOD New() CONSTRUCTOR
	METHOD AfterTTS()
	METHOD FieldPreVld()
	METHOD DeActivate()

ENDCLASS

METHOD New() CLASS VEIA246EVDEF

	self:lEnviar := .f. 

RETURN

METHOD AfterTTS(oModel, cModelId) CLASS VEIA246EVDEF
	self:lEnviar := .t.
RETURN .T.

METHOD FieldPreVld(oSubModel, cModelID, cAction, cId, xValue) CLASS VEIA246EVDEF
	if cModelID == "MODEL_VQE" .and. cAction == "SETVALUE" .and. cId $ "VQE_CODPAC/VQE_CODVQD/"
		oSubModel:loadValue("VQE_BBSYNC","0")
	endif
RETURN .T.

METHOD DeActivate(oModel) CLASS VEIA246EVDEF

	local nOperacao

	if oModel:IsActive()
	else

		// Transmitir registro a John Deere 
		if self:lEnviar == .f.
			return
		endif

		if GetNewPar("MV_MIL0185",.f.) == .f. // Verifica se o ambiente esta integrado com o Blackbird
			return 
		endif 

		if GetNewPar("MV_MIL0186",.f.) == .f. // Verifica se transmiti automaticamente os registros para o Blackbird
			return 
		endif 
		//


		self:lEnviar := .f.
		nOperacao := oModel:GetOperation()

		//if nOperacao == MODEL_OPERATION_INSERT .or. nOperacao == MODEL_OPERATION_UPDATE
		//	VA2460013_TransmitirBlackBird("VQE",VQE->(Recno()),4,.f.)
		//	//
		//endif
//
		if nOperacao == MODEL_OPERATION_DELETE
			if VQE->VQE_BBINTG == "1" // Registro marcado como integrado 
				VA2460023_ExcluirBlackbird("VQE",VQE->(Recno()),4,.f.)
			endif
		endif

	endif
RETURN