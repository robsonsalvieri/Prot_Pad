#include 'TOTVS.ch'
#include 'FWMVCDef.ch'
#include "FWEVENTVIEWCONSTS.CH"
#include "OFIA402EVDEF.ch"

CLASS OFIA402EVDEF FROM FWModelEvent

	data lEnviar // Controla se o registro ja foi enviado para nao entrar em LOOP

	METHOD New() CONSTRUCTOR
	METHOD Before()
	METHOD AfterTTS()
	METHOD DeActivate()

ENDCLASS

METHOD New() CLASS OFIA402EVDEF
	self:lEnviar := .f.

RETURN

METHOD Before(oSubModel, cModelId, cAlias, lNewRecord) CLASS OFIA402EVDEF
	if cModelId == "MODEL_VK7"
		if type("lVEEvSO") == "L" .and. GetNewPar("MV_MIL0185",.f.) .and. lVEEvSO
			oSubModel:loadValue( "VK7_BBINTG", "1" )
			oSubModel:loadValue( "VK7_BBSYNC", "1" )
			oSubModel:loadValue( "VK7_BBDEL ", "0" )
			if empty(oSubModel:GetValue("VK7_BBDINC"))
				oSubModel:loadValue( "VK7_BBDINC", FGX_Timestamp() )
			endif
			oSubModel:loadValue( "VK7_BBDALT", FGX_Timestamp() )
		endif
	endif
RETURN .T.


METHOD AfterTTS(oModel, cModelId) CLASS OFIA402EVDEF
	self:lEnviar := .t.

	//ConOut(STR0001 + oModel:GetValue("MODEL_VK7","VK7_REFID") + " " + oModel:GetValue("MODEL_VK7","VK7_CNUMB" ))	// "AfterTTS: "

RETURN .T.


METHOD DeActivate(oModel) CLASS OFIA402EVDEF

	local nOperacao

	if self:lEnviar == .f.
		return
	endif

	if GetNewPar("MV_MIL0185",.f.) == .f. // Verifica se o ambiente esta integrado com o Blackbird
		return 
	endif 

	if type("lVEEvSO") == "L" .and. GetNewPar("MV_MIL0186",.f.) .and. lVEEvSO
		//conout(STR0002)		// "==========> Evitando envio de dados ao SO via global var"
		return .t.
	endif

	if oModel:IsActive()
	else

		nOperacao := oModel:GetOperation()
		if nOperacao == MODEL_OPERATION_INSERT .or. nOperacao == MODEL_OPERATION_UPDATE .or. nOperacao == MODEL_OPERATION_DELETE

			//ConOut(STR0003 + VK7->VK7_REFID + " " + VK7->VK7_CNUMB )	// "Enviar Customer: "

			// Transmitir registro a John Deere 
			if self:lEnviar .and. GetNewPar("MV_MIL0186",.f.) 

				self:lEnviar := .f.

				if VK7->VK7_A1DEL == "1"
					if VK7->VK7_BBINTG == "1"
						//CONOUT("___  __             __          ___    __            ___      __             __        __ ")
						//CONOUT(" |  |__)  /\  |\ | /__`  |\/| |  |  | |__)    __    |__  \_/ /  ` |    |  | /__`  /\  /  \")
						//CONOUT(" |  |  \ /~~\ | \| .__/  |  | |  |  | |  \          |___ / \ \__, |___ \__/ .__/ /~~\ \__/")
						//CONOUT("                                                                                          ")
						OA4020053_Excluir("VK7",VK7->(Recno()),4,.f.)
					endif
				else
					//if nOperacao == MODEL_OPERATION_INSERT .or. VK7->VK7_BBINTG == "0"
					//	Conout("___  __             __          ___    __                   __             __        __  ")
					//	Conout(" |  |__)  /\  |\ | /__`  |\/| |  |  | |__)    __    | |\ | /  ` |    |  | /__`  /\  /  \ ")
					//	Conout(" |  |  \ /~~\ | \| .__/  |  | |  |  | |  \          | | \| \__, |___ \__/ .__/ /~~\ \__/ ")
					//	Conout("                                                                                         ")
					//else
					//	Conout(" ___  __             __          ___    __                     ___  ___  __        __        __  ")
					//	Conout("  |  |__)  /\  |\ | /__`  |\/| |  |  | |__)    __     /\  |     |  |__  |__)  /\  /  `  /\  /  \ ")
					//	Conout("  |  |  \ /~~\ | \| .__/  |  | |  |  | |  \          /~~\ |___  |  |___ |  \ /~~\ \__, /~~\ \__/ ")
					//	Conout("                                                                                                 ")
					//endif
					OA4020033_TransmitirBlackBird("VK7",VK7->(Recno()),4,.f.)
				endif

			endif
			//
		endif
	endif

RETURN
