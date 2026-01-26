#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "OFIA401.CH"

/*/{Protheus.doc} OFIA401

	Relacao Custacts x Contatos Relacionados

@author rubens.takahashi
@since 02/08/2019
@version 1.0
@type function
/*/
Function OFIA401()
	Local oBrowse

	oBrowse := BrowseDef()
	oBrowse:Activate()

Return


/*/{Protheus.doc} ModelDef
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ModelDef()
	Local oStruVK8 := FWFormStruct( 1, 'VK8' )

	//OA4010063_AddTrigger( oStruVK8 , FwStruTrigger("VK8_CODVK8","VK8_BTREID","VK8_REFID",.T.,"VK8",1,"xFilial('VK8') + FWFldGet('VK8_CODIGO')") )
	//OA4010063_AddTrigger( oStruVK8 , FwStruTrigger("VK8_CODVK8","VK8_BTNUMB","VK8_CNUMB",.T.,"VK8",1,"xFilial('VK8') + FWFldGet('VK8_CODIGO')") )

	oModel := MPFormModel():New('OFIA401' )
	oModel:AddFields('MODEL_VK8', /*cOwner*/, oStruVK8 , /* <bPre > */ , /* <bPost > */ , /* <bLoad> */ )

	oModel:SetDescription( STR0002 ) // Contatos
	oModel:GetModel( 'MODEL_VK8' ):SetDescription( STR0003 ) // Dados do Contato - Blackbird

	//oModel:InstallEvent("OFIA401LOG", /*cOwner*/, MVCLOGEV():New("OFIA401") ) // CONSOLE.LOG para verificar as chamadas dos eventos
	oModel:InstallEvent("PADRAO",, OFIA401EVDEF():New())
	
Return oModel

/*/{Protheus.doc} ViewDef
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ViewDef()

	Local oView
	Local oModel := FWLoadModel( 'OFIA401' )
	Local oStruVK8 := FWFormStruct( 2, 'VK8' )

	/*
	oStruVK8:AddGroup('VK81',STR0003 + ' - John Deere','1',2)
	oStruVK8:AddGroup('VK82',STR0003 + ' - Protheus','2',2)

	oStruVK8:SetProperty("*", MVC_VIEW_GROUP_NUMBER, "VK81")
	oStruVK8:SetProperty("VK8_A1FIL"  , MVC_VIEW_GROUP_NUMBER, "VK82")
	oStruVK8:SetProperty("VK8_A1COD"  , MVC_VIEW_GROUP_NUMBER, "VK82")
	oStruVK8:SetProperty("VK8_A1LOJA" , MVC_VIEW_GROUP_NUMBER, "VK82")
	*/
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField('VIEW_VK8', oStruVK8, 'MODEL_VK8' )

	oView:CreateHorizontalBox( 'TELA_VK8' , 100 )

	oView:SetOwnerView('VIEW_VK8','TELA_VK8')

Return oView

/*/{Protheus.doc} MenuDef
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.OFIA401' OPERATION 2 ACCESS 0		// Visualizar
	ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.OFIA401' OPERATION 3 ACCESS 0	// Incluir
	ADD OPTION aRotina Title STR0006 Action 'VIEWDEF.OFIA401' OPERATION 4 ACCESS 0	// Alterar
	ADD OPTION aRotina Title STR0007 Action 'OA4010033_TransmitirBlackBird' OPERATION 4 ACCESS 0	// Transmitir
	ADD OPTION aRotina Title STR0008 Action 'OA4010053_ExcluirBlackBird' OPERATION 4 ACCESS 0	// Excluir Registro
	ADD OPTION aRotina Title STR0009 Action 'VIEWDEF.OFIA401' OPERATION 8 ACCESS 0	// Imprimir
	ADD OPTION aRotina Title STR0010 Action 'VIEWDEF.OFIA401' OPERATION 9 ACCESS 0	// Copiar
	ADD OPTION aRotina Title STR0011 Action 'OA4010073_LogTransmissao' OPERATION 9 ACCESS 0	// Log Transmissão

Return aRotina

/*/{Protheus.doc} BrowseDef
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function BrowseDef()

	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('VK8')
	oBrowse:SetDescription( STR0001 ) // Cadastro de Contatos

	//oBrowse:AddLegend( 'VK8->VK8_BBSYNC == "0"' , 'BR_AMARELO', "Não sincronizado" )
	//oBrowse:AddLegend( 'VK8->VK8_BBSYNC == "1"' , 'BR_VERDE'  , "Sincronizado" ) 

	oBrowse:AddStatusColumns( { || IIF( VK8->VK8_BBSYNC == "0" , 'BR_AMARELO','BR_VERDE' ) }, { || OA4010043_LegendaVK8() } )
	oBrowse:AddStatusColumns( { || IIF( VK8->VK8_U5SYNC == "0" , 'BR_AMARELO','BR_VERDE' ) }, { || OA4010023_LegendaSU5() } )
	
	oBrowse:SetBlkBackColor( { || OA4010083_ColorDelete()} )

Return oBrowse

Static Function OA4010083_ColorDelete()
	if VK8->VK8_AC8DEL == "1"
		//Return CLR_HGRAY
		//Return CLR_HRED
		Return CLR_RED
	endif
return Nil


//Function OA4010013_ValidCodVK8(cCodVK8)
	//Default cCodVK8 := FWFldGet("VK8_CODVK8")

	//If Vazio()
		//Return .t.
	//EndIf

	//If ! ExistCPO("VK8",cCodVK8,1)
		//Return .f.
	//EndIf

	//FWFldPut(cCampo,xConteudo,/*nLinha*/,/*oModel*/,.T.,.T.)
	

//Return .t.

//Static Function OA4010063_AddTrigger(oAuxStru, aAuxTrigger)
	//oAuxStru:AddTrigger(aAuxTrigger[1], aAuxTrigger[2], aAuxTrigger[3], aAuxTrigger[4])
//Return

Function OA4010033_TransmitirBlackBird(cAlias,nReg,nOpc,lExibeHelp)

	Local oContact
	Local oContactIntg
	Local oMessage

	Default lExibeHelp := .t.

	//Conout(" ")
	//Conout("OA4010033_TransmitirBlackBird")
	//Conout(" ")

	if empty(VK8->VK8_REFID)
		if lExibeHelp
			Help(" ",1,"OBRIGAT",,RetTitle("VK8_REFID") ,3,1)
		endif
		return .f.
	endif

	if empty(VK8->VK8_CODVK7)
		if lExibeHelp
			FMX_HELP("OA401ERR001", STR0012, STR0013)	// "Código do customer não informado."	"Informe um código de customer válido."
		endif
		return .f.
	endif

	if VK8->VK8_BBSYNC == "1"
		if lExibeHelp
			FMX_HELP("OA401ERR002", STR0014)	// "Registro já está sincronizado com a John Deere."
		endif
		return .t.
	endif

	cSQL := "SELECT VK7_BBINTG FROM " + RetSQLName("VK7") + " WHERE VK7_FILIAL = '" + xFilial("VK7") + "' AND VK7_CODIGO = '" + VK8->VK8_CODVK7 + "' AND D_E_L_E_T_ = ' '"
	if FM_SQL(cSQL) <> "1"
		if lExibeHelp
			FMX_HELP("OA401ERR003", STR0015, STR0016 )	// "Registro do customer não transmitido."	"Transmita o registro do customer antes de enviar o registro de contact."
		endif
		return .t.
	endif

	CursorWait()

	oContact := OFSoContact():New()
	oContactIntg := oContact:FindByRecno( VK8->(recno()) )

	if VK8->VK8_BBINTG == "1"
		oMessage := OFSoContactUpdatedInDbsMessage():New(oContactIntg)
	else
		oMessage := OFSoContactCreatedInDbsMessage():New(oContactIntg)
	endif

	FWMsgRun(, {|oSay| oMessage:Send() }, STR0017, STR0018 + VK8->VK8_REFID)	// "John Deere - Blackbird"		"Atualizando Contato - "

	If oMessage:oSoRequest:GetHTTPResponse() == 200
		oModel := FWLoadModel("OFIA401")
		oModel:setOperation(MODEL_OPERATION_UPDATE)

		//Conout("OA4010033_TransmitirBlackBird - " + STR0019)		// Carregando Model "
		oModel:Activate()
		//Conout("OA4010033_TransmitirBlackBird - " + STR0020)		// Model Carrregada"

		oModel:SetValue("MODEL_VK8", "VK8_BBINTG", "1" )
		oModel:SetValue("MODEL_VK8", "VK8_BBSYNC", "1" )
		oModel:SetValue("MODEL_VK8", "VK8_BBDEL" , "0" )
		if empty(oModel:GetValue("MODEL_VK8","VK8_BBDINC"))
			oModel:SetValue("MODEL_VK8", "VK8_BBDINC", FGX_Timestamp() )
		endif
		oModel:SetValue("MODEL_VK8", "VK8_BBDALT", FGX_Timestamp() )

		If oModel:VldData()
			oModel:CommitData()
		endif
		oModel:DeActivate()
		CursorArrow()

		if lExibeHelp .and. FunName() <> "OFIA264"
			MsgInfo(STR0021)		// "Registro transmitido"
		endif
	Else

		CursorArrow()

		MsgInfo(STR0022)	// "Falha na transmissão do registro. Consulte o log de transmissão."
	EndIf

	//oMessage:Delay()

	//oMessageClass := OFDMSMessage():New()
	//oMessageClass:Process()
	//aMessages := oMessageClass:WithInitialStatus():NotDeleted():Limit(10):Order("VK6_DATINC ASC")
	//varInfo("Mensagens", aMessages)

Return


//Static Function ModCommit(oAuxModel)

	//Local lRet
	//Local aErro

	//If ( lRet := oAuxModel:VldData() )
		//lRet := oAuxModel:CommitData()
	//EndIf

	//If ! lRet
		// Se os dados não foram validados obtemos a descrição do erro para gerar LOG ou mensagem de aviso
		//aErro   := oModel:GetErrorMessage()

		// A estrutura do vetor com erro é:
		//  [1] Id do formulário de origem
		//  [2] Id do campo de origem
		//  [3] Id do formulário de erro
		//  [4] Id do campo de erro
		//  [5] Id do erro
		//  [6] mensagem do erro
		//  [7] mensagem da solução
		//  [8] Valor atribuido
		//  [9] Valor anterior

		//AutoGrLog( STR0023 + ' [' + AllToChar( aErro[1]  ) + ']' )	// "Id do formulário de origem:"
		//AutoGrLog( STR0024 + ' [' + AllToChar( aErro[2]  ) + ']' )	// "Id do campo de origem:     "
		//AutoGrLog( STR0025 + ' [' + AllToChar( aErro[3]  ) + ']' )	// "Id do formulário de erro:  "
		//AutoGr+Log( STR0026 + ' [' + AllToChar( aErro[4]  ) + ']' )	// "Id do campo de erro:       "
		//AutoGrLog( STR0027 + ' [' + AllToChar( aErro[5]  ) + ']' )	// "Id do erro:                "
		//AutoGrLog( STR0028 + ' [' + AllToChar( aErro[6]  ) + ']' )	// "Mensagem do erro:          "
		//AutoGrLog( STR0029 + ' [' + AllToChar( aErro[7]  ) + ']' )	// "Mensagem da solução:       "
		//AutoGrLog( STR0030 + ' [' + AllToChar( aErro[8]  ) + ']' )	// "Valor atribuido:           "
		//AutoGrLog( STR0031 + ' [' + AllToChar( aErro[9]  ) + ']' )	// "Valor anterior:            "

		//MostraErro()

	//EndIf

//Return lRet


Function OA4010053_ExcluirBlackBird(cAlias,nReg,nOpc,lExibeHelp)

	Local oContact
	Local oContactIntg
	Local oMessage

	Default lExibeHelp := .t.

	if VK8->VK8_BBINTG <>"1"
		if lExibeHelp
			FMX_HELP("OFIA401ERR03",STR0031)		// "Registro não esta integrado com o Blackbird."
		endif
		Return .f.
	EndIf

	CursorWait()

	oContact := OFSoContact():New()
	oContactIntg := oContact:FindByRecno( VK8->(recno()) )

	oMessage := OFSoContactRemovedInDbsMessage():New(oContactIntg)
	oMessage:Send()

	If oMessage:oSoRequest:GetHTTPResponse() == 200

		oModel := FWLoadModel("OFIA401")
		oModel:setOperation(MODEL_OPERATION_UPDATE)

		oModel:Activate()

		oModel:SetValue("MODEL_VK8", "VK8_BBINTG", "0" )
		oModel:SetValue("MODEL_VK8", "VK8_BBDEL" , "1" )
		oModel:SetValue("MODEL_VK8", "VK8_BBDALT", FGX_Timestamp() )

		If oModel:VldData()
			oModel:CommitData()
		endif
		oModel:DeActivate()
		CursorArrow()

		if lExibeHelp
			MsgInfo(STR0032)	// "Registro excluido."
		endif
	Else
		if lExibeHelp
			MsgInfo(STR0033)	// "Falha na transmissão do registro. Consulte o log de transmissão."
		endif
	EndIf

	//oMessage:Delay()

	//oMessageClass := OFDMSMessage():New()
	//oMessageClass:Process()
	//aMessages := oMessageClass:WithInitialStatus():NotDeleted():Limit(10):Order("VK6_DATINC ASC")
	//varInfo("Mensagens", aMessages)

Return


/*/{Protheus.doc} OA4010023_LegendaSU5
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 01/01/2022
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OA4010023_LegendaSU5()
	Local oLegenda  :=  FWLegend():New()

	oLegenda:Add( '', "BR_AMARELO" , STR0034 )		// "Não sincronizado com o Protheus"
	oLegenda:Add( '', "BR_VERDE"   , STR0035 )		// "Sincronizado com o Protheus"

	oLegenda:Activate()
	oLegenda:View()
	oLegenda:DeActivate()

Return Nil

Static Function OA4010043_LegendaVK8
	Local oLegenda  :=  FWLegend():New()

	oLegenda:Add( '', "BR_AMARELO" , STR0036 )		// "Não sincronizado com o Blackbird"
	oLegenda:Add( '', "BR_VERDE"   , STR0037 )		// "Sincronizado com o Blackbird"

	oLegenda:Activate()
	oLegenda:View()
	oLegenda:DeActivate()

Return Nil


Function OA4010073_LogTransmissao(cAlias,nReg,nOpc)

	local cOriKey := VK8->VK8_REFID

	OFIA262("@ VK5_ORITAB = 'VK8' AND VK5_ORIKEY = '" + cOriKey + "' ", "CONTACT")

Return
