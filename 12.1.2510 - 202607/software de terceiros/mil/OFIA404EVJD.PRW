#include 'TOTVS.ch'
#include 'FWMVCDef.ch'
#include "FWEVENTVIEWCONSTS.CH"

CLASS OFIA404EVJD FROM FWModelEvent

	data lEnviar // Controla se o registro ja foi enviado para nao entrar em LOOP

	METHOD New() CONSTRUCTOR
	METHOD AfterTTS()
	METHOD DeActivate()
	METHOD FieldPreVld()

ENDCLASS

METHOD New() CLASS OFIA404EVJD
	self:lEnviar := .f.
RETURN

METHOD AfterTTS(oModel, cModelId) CLASS OFIA404EVJD
	self:lEnviar := .t.
RETURN .T.

METHOD FieldPreVld(oSubModel, cModelID, cAction, cId, xValue) CLASS OFIA404EVJD
	if cModelID == "VKBMASTER" .and. cAction == "SETVALUE" .and. cId $ "VKB_NOME/VKB_DESCRI/VKB_TYPE"
		oSubModel:loadValue("VKB_BBSYNC","0")
	endif
RETURN .T.


METHOD DeActivate(oModel) CLASS OFIA404EVJD
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
		OA4040033_TransmitirBlackBird("VKB",VKB->(Recno()),4,.f.)
	endif

	if nOperacao == MODEL_OPERATION_DELETE
		if VKB->VKB_BBINTG == "1" // Registro marcado como integrado
			OA4040053_ExcluirBlackBird("VKB",VKB->(Recno()),4,.f.)
		endif
	endif
RETURN


