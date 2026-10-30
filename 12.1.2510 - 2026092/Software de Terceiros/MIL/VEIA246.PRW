#include "PROTHEUS.CH"
#include "FWMVCDEF.CH"
#include "VEIA246.CH"

/*/{Protheus.doc} VEIA246
	Relacionamento Veículo x Opcional
	
	@type function
	@author Alecsandre Ferreira
	@since 11/07/2022
/*/
Function VEIA246()

	// Instanciamento da Classe de Browse
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('VQE')
	oBrowse:SetDescription(STR0001) // "Relacionamento Veículo x Opcional"
	oBrowse:Activate()

return .t.

/*/{Protheus.doc} ModelDef
	ModelDef
	
	@type function
	@author Alecsandre Ferreira
	@since 11/07/2022
/*/
static function ModelDef()
	Local oStrVQE  := FWFormStruct(1, 'VQE')

	oModel := MPFormModel():New('VEIA246')

	oModel:AddFields('MODEL_VQE',, oStrVQE, /*bpre*/, /*bpost*/)
	oModel:SetDescription(STR0001) // "Relacionamento Veículo x Opcional"
	oModel:GetModel('MODEL_VQE'):SetDescription(STR0001) // "Relacionamento Veículo x Opcional"
	oModel:SetPrimaryKey({'VQE_FILIAL', 'VQE_CODIGO'})

	oModel:InstallEvent("DEF",, VEIA246EVDEF():New())
	
return oModel

Static Function ViewDef()

	Local oModel := FWLoadModel( 'VEIA246' )
	Local oStrVQE := FWFormStruct( 2, 'VQE' )
	Local oView

	oView := FWFormView():New()
	oView:SetModel( oModel )

	oView:AddField('VIEW_VQE', oStrVQE, 'MODEL_VQE' )

Return oView

Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.VEIA246' OPERATION 2 ACCESS 0 // 'Visualizar'
	ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.VEIA246' OPERATION 3 ACCESS 0 // 'Incluir'
	ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.VEIA246' OPERATION 4 ACCESS 0 // 'Alterar'
	ADD OPTION aRotina Title STR0006 Action 'VIEWDEF.VEIA246' OPERATION 5 ACCESS 0 // 'Excluir'
	if GetNewPar("MV_MIL0006","") == "JD" .and. GetNewPar("MV_MIL0185",.F.)
		ADD OPTION aRotina Title STR0007 Action 'VA2460013_TransmitirBlackBird' OPERATION 4 ACCESS 0 // 'Transmitir Dynamics'
	endif
	//ADD OPTION aRotina Title 'Log Transmissão' Action 'VA0310033_LogTransmissao' OPERATION 9 ACCESS 0
Return aRotina


Function VA2460013_TransmitirBlackBird(cAlias,nReg,nOpc,lExibeHelp)

	Local oEqOpt
	Local oMessage

	Default lExibeHelp := .t.

	if OA2610123_integraDynamics(.f.) == .f.
		return .t.
	endif

	if VQE->VQE_BBSYNC == "1"
		if lExibeHelp
			FMX_HELP("VA246ERR001",STR0008) // "Registro já está sincronizado com a John Deere."
		endif
		return .t.
	endif

	Reclock("VQE",.f.)

	oEqOpt := OFSoEquipmentOption():New()
	oEqOpt := oEqOpt:FindByRecno( VQE->(recno()) )

	if VQE->VQE_BBINTG == "1"
		oMessage := OFSoEquipmentOptionUpdatedInDbsMessage():New(oEqOpt)
	else
		oMessage := OFSoEquipmentOptionAddedInDbsMessage():New(oEqOpt)
	endif

	FWMsgRun(, {|oSay| oMessage:Send() }, STR0009, STR0010 + " - " + VQE->VQE_BBRFID) // "John Deere - Dynamics" // Atualizando Opcional

	If oMessage:oSoRequest:GetHTTPResponse() == 200
		VQE->VQE_BBINTG := "1"
		VQE->VQE_BBSYNC := "1"
		if empty(VQE->VQE_BBDINC)
			VQE->VQE_BBDINC := FGX_Timestamp()
		endif
		VQE->VQE_BBDALT := FGX_Timestamp()
		VQE->(MsUnlock())

		if lExibeHelp
			MsgInfo(STR0011) // "Registro transmitido."
		endif
	Else

		VQE->(MsUnlock())

		MsgInfo(STR0012) // "Falha na transmissão do registro. Consulte o log de transmissão."

	EndIf


Return


Function VA2460023_ExcluirBlackbird(cAlias,nReg,nOpc,lExibeHelp)

	Local oEqOpt
	Local oMessage

	Default lExibeHelp := .t.

	if OA2610123_integraDynamics(.f.) == .f.
		return .t.
	endif

	if VQE->VQE_BBINTG <>"1"
		if lExibeHelp
			FMX_HELP("VA246ERR002",STR0013)
		endif
		Return .f.
	EndIf

	CursorWait()

	oEqOpt := OFSoEquipmentOption():New()
	oEqOpt := oEqOpt:FindByRecnoDel( VQE->(recno()) )

	oMessage := OFSoEquipmentOptionRemovedInDbsMessage():New(oEqOpt)

	FWMsgRun(, {|oSay| oMessage:Send() }, STR0009, STR0014 + " - " + VQE->VQE_BBRFID) // Removendo Opcional

	If oMessage:oSoRequest:GetHTTPResponse() == 200

		dbSelectArea("VQE")
		recLock("VQE",.F.,.T.)
		VQE->VQE_BBINTG := "0"
		VQE->VQE_BBDEL  := "1"
		msUnlock()

		CursorArrow()

		if lExibeHelp
			MsgInfo(STR0002) // "Registro excluido."
		endif
	Else
		MsgInfo(STR0012) // "Falha na transmissão do registro. Consulte o log de transmissão."
	EndIf


Return