#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "OFIA404.CH"


/*/{Protheus.doc} OFIA404
	Cadastro de Franchise

	@author Marcos Vieira
	@since 08/05/2025
	@version 1.0
	@type function
/*/
Function OFIA404()
	Local oBrowse

	oBrowse := FWMBrowse():New()

	oBrowse:SetAlias("VKB")
	oBrowse:SetDescription(STR0001)

	//Desabilita os detalhes que são habilitados para o Browse quando o usuãrio navega nos registros pelo Grid
	oBrowse:DisableDetails()
	oBrowse:Activate()
Return



/*/{Protheus.doc} MenuDef
	@author Marcos Vieira
	@since 08/05/2025
	@version 1.0
	@return ${return}, ${return_description}
	@type function
/*/
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina Title STR0002 Action 'VIEWDEF.OFIA404' OPERATION 2 ACCESS 0		// 'Visualizar'
	ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.OFIA404' OPERATION 3 ACCESS 0		// 'Incluir'
	ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.OFIA404' OPERATION 4 ACCESS 0		// 'Alterar'
	ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.OFIA404' OPERATION 5 ACCESS 0		// 'Excluir'

	If OA2610123_integraDynamics(.f.)
		ADD OPTION aRotina Title STR0007 Action 'OA4040033_TransmitirBlackBird' OPERATION 4 ACCESS 0	// 'Transmitir'
		ADD OPTION aRotina Title STR0008 Action 'OA4040053_ExcluirBlackBird' 	OPERATION 4 ACCESS 0	// 'Excluir Registro'
		ADD OPTION aRotina Title STR0009 Action 'OA4040073_LogTransmissao' 		OPERATION 2 ACCESS 0	// 'Log Transmissão'
	EndIf

Return aRotina



/*/{Protheus.doc} ModelDef
	@author Marcos Vieira
	@since 08/05/2025
	@version 1.0
	@return ${return}, ${return_description}
	@type function
/*/
Static Function ModelDef()

	Local oModel	:= Nil
	Local oStrVKB	:= FWFormStruct( 1, 'VKB' )

	oModel := MPFormModel():New('OFIA404',/*bPreValidacao*/,/*bPosValid*/,/*bCommit*/,/*bCancel*/)

	oModel:AddFields("VKBMASTER", /*cOwner*/, oStrVKB, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
	oModel:SetPrimaryKey({"VKB_FILIAL","VKB_COD"})

	oModel:SetDescription( STR0006 )	//Franchise
	oModel:GetModel("VKBMASTER"):SetDescription( STR0006 )	//Franchise

	If OA2610123_integraDynamics(.F.)
		oModel:InstallEvent("PADRAO",, OFIA404EVJD():New())
	EndIf

Return oModel



/*/{Protheus.doc} ViewDef
	@author Marcos Vieira
	@since 08/05/2025
	@version 1.0
	@return ${return}, ${return_description}
	@type function
/*/
Static Function ViewDef()

	Local oView
	Local oModel 	:= FWLoadModel( 'OFIA404' )
	Local oStrVKB 	:= FWFormStruct( 2, 'VKB' )

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField('VIEW_VKB', oStrVKB,'VKBMASTER' )

	oView:CreateHorizontalBox('TELA_VKB', 100 )
	oView:SetOwnerView('VIEW_VKB','TELA_VKB')

Return oView




Function OA4040033_TransmitirBlackBird(cAlias,nReg,nOpc,lExibeHelp)

	Local oFranq
	Local oFranqIntg
	Local oMessage
	Local cOperation

	Default lExibeHelp := .t.

	if OA2610123_integraDynamics(.f.) == .f.
		return .t.
	endif

	if VKB->VKB_BBSYNC == "1"
		if lExibeHelp
			FMX_HELP("OA002ERR001",STR0010) // "Registro já está sincronizado com a John Deere."
		endif
		return .t.
	endif

	CursorWait()

	oFranq := OFSoFranchise():New()
	oFranqIntg := oFranq:FindByRecno( VKB->(recno()) )

	if VKB->VKB_BBINTG == "0"
		cOperation := 'added'
	else
		cOperation := 'modified'
	endif
	oMessage := OFSoFranchiseRefDataChangedInDbsMessage():New()
	oMessage:setOperation(cOperation)
	oMessage:SetFranchise(oFranqIntg)

	FWMsgRun(, {|oSay| oMessage:Send() }, STR0011, STR0012 + VKB->VKB_REFID)	// "John Deere - Blackbird"		"Atualizando Banco - "

	If oMessage:oSoRequest:GetHTTPResponse() == 200

		oModel := FWLoadModel("OFIA404")
		oModel:setOperation(MODEL_OPERATION_UPDATE)
		oModel:Activate()

		oModel:SetValue("VKBMASTER", "VKB_BBINTG", "1" )
		oModel:SetValue("VKBMASTER", "VKB_BBSYNC", "1" )

		if empty(oModel:GetValue("VKBMASTER","VKB_BBDINC"))
			oModel:SetValue("VKBMASTER", "VKB_BBDINC", FGX_Timestamp() )
		endif

		oModel:SetValue("VKBMASTER", "VKB_BBDALT", FGX_Timestamp() )

		If oModel:VldData()
			oModel:CommitData()
		endif
		oModel:DeActivate()

		CursorArrow()
		if lExibeHelp
			MsgInfo(STR0013)	// "Registro transmitido"
		endif
	Else

		CursorArrow()

		if lExibeHelp
			MsgInfo(STR0014)	// "Falha na transmissão do registro. Consulte o log de transmissão."
		endif

		aErro := { STR0015,,, cValToChar( oMessage:oSoRequest:GetHTTPResponse() ),5, STR0014 } // "Falha na transmissão" // "Falha na transmissão do registro. Consulte o log de transmissão."

		return .f.
	EndIf

Return



Function OA4040053_ExcluirBlackBird(cAlias,nReg,nOpc,lExibeHelp)

	Local oFranq
	Local oFranqIntg
	Local oMessage
	Local nRecVKB := nReg

	Default lExibeHelp := .t.

	VKB->(dbGoTo(nRecVKB))

	if OA2610123_integraDynamics(.f.) == .f.
		return .t.
	endif

	if VKB->VKB_BBINTG <>"1"
		if lExibeHelp
			FMX_HELP("OA031ERR002",STR0016)		// "Registro não esta integrado com o Blackbird."
		endif
		Return .f.
	EndIf

	CursorWait()

	VKB->(dbGoTo(nRecVKB))

	oFranq := OFSoFranchise():New()
	oFranqIntg := oFranq:FindByRecnoDel( VKB->(recno()) )

	oMessage := OFSoFranchiseRefDataChangedInDbsMessage():New(oFranqIntg)
	oMessage:setOperation('removed')

	FWMsgRun(, {|oSay| oMessage:Send() }, STR0011, STR0017 + VKB->VKB_REFID) // "John Deere - Blackbird" "Removendo Banco - "

	If oMessage:oSoRequest:GetHTTPResponse() == 200

		dbSelectArea("VKB")
		recLock("VKB",.F.,.T.)
		VKB->VKB_BBINTG := "0"
		VKB->VKB_BBDEL := "1"
		msUnlock()

		CursorArrow()

		if lExibeHelp
			MsgInfo(STR0018)	// "Registro excluido."
		endif
	Else
		if lExibeHelp
			MsgInfo(STR0014)	// "Falha na transmissão do registro. Consulte o log de transmissão."
		endif
	EndIf

	CursorArrow()

Return




Function OA4040073_LogTransmissao(cAlias,nReg,nOpc,lExibeHelp)

	local cOriKey := VKB->VKB_REFID

	OFIA262("@ VK5_ORITAB = 'VKB' AND VK5_ORIKEY = '" + cOriKey + "' ", "Franchise")

Return
