#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "VEIA031.CH"

/*/{Protheus.doc} VEIA031
Cadastro de Marca - MVC
@author Rubens
@since 28/11/2018
@version 1.0

@type function
/*/
Function VEIA031()
	Local oBrowse

	Conout("VEIA031")

	Private cFiltroVX5 := "028"

	// Instanciamento da Classe de Browse
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('VE1')
	oBrowse:SetDescription(STR0001) // 'Cadastro de Marcas'
	oBrowse:Activate()

Return


Static Function ModelDef()
	
	Local oModel

	Local oStruVE1 := FWFormStruct( 1, 'VE1' )
	
	oModel := MPFormModel():New('VEIA031' )

	oModel:AddFields( 'MODEL_VE1', /*cOwner*/, oStruVE1)

	oModel:SetDescription( STR0002 ) // "Modelo de dados da Marca"
	oModel:GetModel( 'MODEL_VE1' ):SetDescription( STR0003 ) // 'Dados da Marca' 

	oModel:SetPrimaryKey( { 'VE1_FILIAL', 'VE1_CODMAR' } )

//	Conout(" ")
//	Conout("VEIA031 - ModelDef")
//	Conout(" ")

	oModel:InstallEvent("PADRAO",, VEIA031EVDEF():New())

Return oModel

Static Function ViewDef()

	Local oModel := FWLoadModel( 'VEIA031' )
	Local oStruVE1 := FWFormStruct( 2, 'VE1' )
	Local oView

	oView := FWFormView():New()
	oView:SetModel( oModel )
	
	oView:AddField( 'VIEW_VE1', oStruVE1, 'MODEL_VE1' )

Return oView

Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.VEIA031' OPERATION 2 ACCESS 0 // 'Visualizar'
	ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.VEIA031' OPERATION 3 ACCESS 0 // 'Incluir'
	ADD OPTION aRotina Title STR0006 Action 'VIEWDEF.VEIA031' OPERATION 4 ACCESS 0 // 'Alterar'
	ADD OPTION aRotina Title STR0007 Action 'VIEWDEF.VEIA031' OPERATION 5 ACCESS 0 // 'Excluir'
	if OA2610123_integraDynamics(.f.)
		ADD OPTION aRotina Title STR0008 Action 'VA0310013_TransmitirBlackBird' OPERATION 4 ACCESS 0	// 'Transmitir'
		ADD OPTION aRotina Title STR0009 Action 'VA0310023_ExcluirBlackbird' OPERATION 4 ACCESS 0	// 'Excluir Blackbird'
		ADD OPTION aRotina Title STR0010 Action 'VA0310033_LogTransmissao' OPERATION 9 ACCESS 0	// 'Log Transmissão'
	endif
Return aRotina


Function VA0310013_TransmitirBlackBird(cAlias,nReg,nOpc,lExibeHelp, aErro)

	Local oEqMake
	Local oEqMakeIntg
	Local oMessage

	Default lExibeHelp := .t.

//	Conout(" ")
//	Conout("VA0310013_TransmitirBlackBird")
//	Conout(" ")

	if OA2610123_integraDynamics(.f.) == .f.
		return .t.
	endif

	if empty(VE1->VE1_BBRFID)
		reclock("VE1",.f.)
		VE1->VE1_BBRFID := FWUUIDV4(.t.)
		VE1->(MSUnlock())
	endif

	if VE1->VE1_BBSYNC == "1"
		if lExibeHelp
			FMX_HELP("VA031ERR001",STR0011)	// "Registro já está sincronizado com a John Deere."
		endif
		return .t.
	endif

	CursorWait()

	oEqMake := OFSoEquipmentMake():New()
	oEqMakeIntg := oEqMake:FindByRecno( VE1->(recno()) )

	if VE1->VE1_BBINTG == "1"
		oMessage := OFSoEquipmentMakeUpdatedInDbsMessage():New(oEqMakeIntg)
	else
		oMessage := OFSoEquipmentMakeCreatedInDbsMessage():New(oEqMakeIntg)
	endif

	FWMsgRun(, {|oSay| oMessage:Send() }, STR0012, STR0013 + VE1->VE1_BBRFID)	// "John Deere - Blackbird"		"Atualizando Marca - "

	If oMessage:oSoRequest:GetHTTPResponse() == 200

		oModel := FWLoadModel("VEIA031")
		oModel:setOperation(MODEL_OPERATION_UPDATE)

//		Conout("VA0310013_TransmitirBlackBird - Carregando Model ")
		oModel:Activate()


//		Conout("VA0310013_TransmitirBlackBird - Model Carrregada")

		oModel:SetValue("MODEL_VE1", "VE1_BBINTG", "1" )
		oModel:SetValue("MODEL_VE1", "VE1_BBSYNC", "1" )

		if empty(oModel:GetValue("MODEL_VE1","VE1_BBDINC"))
			oModel:SetValue("MODEL_VE1", "VE1_BBDINC", FGX_Timestamp() )
		endif

		oModel:SetValue("MODEL_VE1", "VE1_BBDALT", FGX_Timestamp() )

		iIf ((!oModel:VldData() .and. !oModel:CommitData()),aErro := oModel:GetErrorMessage(),)




		oModel:DeActivate()

		CursorArrow()
		if lExibeHelp
			MsgInfo(STR0014)	// "Registro transmitido"
		endif
	Else

		CursorArrow()

		if lExibeHelp
			MsgInfo(STR0015)	// "Falha na transmissão do registro. Consulte o log de transmissão."
		endif

		aErro := { STR0019,,, cValToChar( oMessage:oSoRequest:GetHTTPResponse() ),5, STR0015 } // "Falha na transmissão" // "Falha na transmissão do registro. Consulte o log de transmissão."

		return .f.
	EndIf


Return .t.


Function VA0310023_ExcluirBlackbird(cAlias,nReg,nOpc,lExibeHelp)

	Local oEqMake
	Local oEqMakeIntg
	Local oMessage

	Default lExibeHelp := .t.

	if OA2610123_integraDynamics(.f.) == .f.
		return .t.
	endif

	if VE1->VE1_BBINTG <>"1"
		if lExibeHelp
			FMX_HELP("VA031ERR002",STR0016)	// "Registro não esta integrado com o Blackbird."
		endif
		Return .f.
	EndIf

	CursorWait()

	oEqMake := OFSoEquipmentMake():New()
	oEqMakeIntg := oEqMake:FindByRecnoDel( VE1->(recno()) )

	oMessage := OFSoEquipmentMakeRemovedInDbsMessage():New(oEqMakeIntg)

	FWMsgRun(, {|oSay| oMessage:Send() }, STR0012, STR0017 + VE1->VE1_BBRFID)	// "John Deere - Blackbird"		"Removendo Marca - "

	If oMessage:oSoRequest:GetHTTPResponse() == 200

		dbSelectArea("VE1")
		recLock("VE1",.F.,.T.)
		VE1->VE1_BBINTG := "0"
		VE1->VE1_BBDEL := "1"
		msUnlock()

		CursorArrow()

		if lExibeHelp
			MsgInfo(STR0018)	// "Registro excluido."
		endif
	Else
		if lExibeHelp
			MsgInfo(STR0015)	// "Falha na transmissão do registro. Consulte o log de transmissão."
		endif
	EndIf

Return


Function VA0310033_LogTransmissao(cAlias,nReg,nOpc,lExibeHelp)

	local cOriKey := VE1->VE1_BBRFID

	OFIA262("@ VK5_ORITAB = 'VE1' AND VK5_ORIKEY = '" + cOriKey + "' ", "MAKE")

Return
