#include 'TOTVS.ch'
#include 'FWMVCDef.ch'
#include "FWEVENTVIEWCONSTS.CH"
#include "OFIA401EVDEF.ch"

CLASS OFIA401EVDEF FROM FWModelEvent

	data lEnviar // Controla se o registro ja foi enviado para nao entrar em LOOP

	METHOD New() CONSTRUCTOR
	METHOD AfterTTS()
	METHOD DeActivate()

ENDCLASS

METHOD New() CLASS OFIA401EVDEF

	self:lEnviar := .f. 


RETURN

METHOD AfterTTS(oModel, cModelId) CLASS OFIA401EVDEF
	self:lEnviar := .t.
RETURN .T.

METHOD DeActivate(oModel) CLASS OFIA401EVDEF

	local nOperacao

	if oModel:IsActive()
	else

		if GetNewPar("MV_MIL0185",.f.) == .f. // Verifica se o ambiente esta integrado com o Blackbird
			return 
		endif 
		
		nOperacao := oModel:GetOperation()
		if nOperacao == MODEL_OPERATION_INSERT .or. nOperacao == MODEL_OPERATION_UPDATE .or. nOperacao == MODEL_OPERATION_DELETE

			//Conout(STR0001 + cValToChar(self:lEnviar))	// "Transmissao do VK8 - "

			// Transmitir registro a John Deere 
			if self:lEnviar .and. GetNewPar("MV_MIL0186",.f.)

				self:lEnviar := .f.

				if VK8->VK8_AC8DEL == "1"
					if VK8->VK8_BBINTG == "1"
						//Conout(STR0002)		// "Chamada da rotina de transmissao de EXCLUSAO automatica"
						OA4010053_ExcluirBlackBird("VK8",VK8->(Recno()),4,.f.)
					endif
				else
					//Conout(STR0003)	// "Chamada da rotina de transmissao automatica"
					OA4010033_TransmitirBlackBird("VK8",VK8->(Recno()),4,.f.)
				endif
			endif
			//
		endif
	endif
RETURN
