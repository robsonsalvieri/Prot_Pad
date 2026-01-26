#include 'TOTVS.ch'
#include 'FWMVCDef.ch'
#include "FWEVENTVIEWCONSTS.CH"
#include "VEIA030EVDEF.ch"

CLASS VEIA030EVDEF FROM FWModelEvent

	data lEnviar // Controla se o registro ja foi enviado para nao entrar em LOOP
	data nRecVV2
	data lIntegDynamics

	METHOD New() CONSTRUCTOR
	METHOD VldActivate()
	METHOD AfterTTS()
	METHOD DeActivate()
	METHOD FieldPreVld()
	METHOD ModelPosVld()

ENDCLASS

METHOD New() CLASS VEIA030EVDEF
	self:lEnviar := .f.
	self:lIntegDynamics := OA2610123_integraDynamics(.F.)
RETURN

METHOD VldActivate(oModel, cModelId) CLASS VEIA030EVDEF
	nOperacao := oModel:GetOperation()
	if nOperacao == MODEL_OPERATION_UPDATE .or. nOperacao == MODEL_OPERATION_DELETE
		self:nRecVV2 := VV2->(Recno())
	endif
RETURN .T.

METHOD AfterTTS(oModel, cModelId) CLASS VEIA030EVDEF
	if self:lIntegDynamics
		self:lEnviar := .t.
	endif
RETURN .T.

METHOD FieldPreVld(oSubModel, cModelID, cAction, cId, xValue) CLASS VEIA030EVDEF
	if self:lIntegDynamics
		if cModelID == "MODEL_VV2" .and. cAction == "SETVALUE" .and. cId $ "VV2_DESMOD/"
			oSubModel:loadValue("VV2_BBSYNC","0")
		endif
	endif
RETURN .T.


METHOD DeActivate(oModel) CLASS VEIA030EVDEF

	local nOperacao

	if oModel:IsActive()
	else

		// Transmitir registro a John Deere 
		if self:lEnviar == .f.
			return
		endif

		if GetNewPar("MV_MIL0186",.f.) == .f. // Verifica se transmiti automaticamente os registros para o Blackbird
			return 
		endif 
		//

		nOperacao := oModel:GetOperation()
		if nOperacao == MODEL_OPERATION_INSERT 
			self:nRecVV2 := VV2->(Recno())
		endif

		//Conout(STR0001 + cValToChar(self:lEnviar) + STR0002 + cvaltochar(self:nRecVV2))	// "Transmissao do VV2 - "		" recno "

		self:lEnviar := .f.
		if nOperacao == MODEL_OPERATION_INSERT .or. nOperacao == MODEL_OPERATION_UPDATE
			Conout(STR0003)	// "Chamada da rotina de transmissao automatica"
			VA0300033_TransmitirBlackBird("VV2",self:nRecVV2,4,.f.)
		endif

		if nOperacao == MODEL_OPERATION_DELETE
			if VV2->VV2_BBINTG == "1" // Registro marcado como integrado
				Conout(STR0004)	// "Chamada da rotina de transmissao de EXCLUSAO automatica"
				VA0300053_ExcluirBlackbird("VV2",self:nRecVV2,4,.f.)
			endif
		endif

	endif
RETURN

/*/{Protheus.doc} ModelPosVld
	...

	@type method
	@author Vinicius Gati
	@since 07/10/2022
/*/
Method ModelPosVld(oModel, cModelId) Class VEIA030EVDEF
	local cQuery := ""
	local oModVV2
	If cModelId == "VEIA030" .and. oModel:GetOperation() == MODEL_OPERATION_INSERT
		oModVV2 := oModel:GetModel("MODEL_VV2")
		cQuery += " SELECT count(VV2_FILIAL) FROM "  + RetSqlName("VV2")
		cQuery += "  WHERE VV2_FILIAL = '"+cValToChar(oModVV2:GetValue("VV2_FILIAL"))+"' "
		cQuery += "    AND VV2_CODMAR = '"+cValToChar(oModVV2:GetValue("VV2_CODMAR"))+"' "
		cQuery += "    AND VV2_MODVEI = '"+cValToChar(oModVV2:GetValue("VV2_MODVEI"))+"' " 
		cQuery += "    AND VV2_SEGMOD = '"+cValToChar(oModVV2:GetValue("VV2_SEGMOD"))+"' "
		cQuery += "    AND D_E_L_E_T_ = ' ' "
		If fm_sql(cQuery) > 0
			Help(,,'DUPL_VV2',,STR0004, 1, 0)	// "Chamada da rotina de transmissao de EXCLUSAO automatica"
			Return .f.
		EndIf
	EndIf
Return .t.
