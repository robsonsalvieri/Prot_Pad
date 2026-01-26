#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#include "OFIA402.ch"

/*/{Protheus.doc} OFIA402
   Cadastro de Customer no Dynamics da John Deere
   
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@type function
/*/
Function OFIA402()
	Local oBrowse
	Local oTableAtt

	oBrowse := BrowseDef()

	oTableAtt := TableAttDef()

	oBrowse:SetAttach(.T.)
	oBrowse:SetViewsDefault(oTableAtt:aViews)

	oBrowse:ForceQuitButton()


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
	Local oStruVK7 := FWFormStruct( 1, 'VK7' )

	OA4020063_AddTrigger( oStruVK7 , FwStruTrigger("VK7_CODVK7","VK7_BTREID","VK7_REFID",.T.,"VK7",1,"xFilial('VK7') + FWFldGet('VK7_CODIGO')") )
	OA4020063_AddTrigger( oStruVK7 , FwStruTrigger("VK7_CODVK7","VK7_BTNUMB","VK7_CNUMB",.T.,"VK7",1,"xFilial('VK7') + FWFldGet('VK7_CODIGO')") )

	oModel := MPFormModel():New('OFIA402' )
	oModel:AddFields('MODEL_VK7', /*cOwner*/, oStruVK7 , /* <bPre > */ , /* <bPost > */ , /* <bLoad> */ )

	oModel:SetDescription( STR0002 ) // Clientes'
	oModel:GetModel( 'MODEL_VK7' ):SetDescription( STR0003 ) // Dados do Cliente
	
	oModel:InstallEvent("PADRAO",, OFIA402EVDEF():New())

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
	Local oModel := FWLoadModel( 'OFIA402' )
	Local oStruVK7 := FWFormStruct( 2, 'VK7' )

	/*
	oStruVK7:AddGroup('VK71',STR0003 + ' - John Deere','1',2)
	oStruVK7:AddGroup('VK72',STR0003 + ' - Protheus','2',2)

	oStruVK7:SetProperty("*", MVC_VIEW_GROUP_NUMBER, "VK71")
	oStruVK7:SetProperty("VK7_A1FIL"  , MVC_VIEW_GROUP_NUMBER, "VK72")
	oStruVK7:SetProperty("VK7_A1COD"  , MVC_VIEW_GROUP_NUMBER, "VK72")
	oStruVK7:SetProperty("VK7_A1LOJA" , MVC_VIEW_GROUP_NUMBER, "VK72")
	*/
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField('VIEW_VK7', oStruVK7, 'MODEL_VK7' )

	oView:CreateHorizontalBox( 'TELA_VK7' , 100 )

	oView:SetOwnerView('VIEW_VK7','TELA_VK7')

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

	ADD OPTION aRotina Title STR0006 Action 'VIEWDEF.OFIA402' OPERATION 2 ACCESS 0		// 'Visualizar'
	ADD OPTION aRotina Title STR0007 Action 'VIEWDEF.OFIA402' OPERATION 3 ACCESS 0		// 'Incluir'
	ADD OPTION aRotina Title STR0008 Action 'VIEWDEF.OFIA402' OPERATION 4 ACCESS 0		// 'Alterar'
	ADD OPTION aRotina Title STR0009 Action 'OA4020033_TransmitirBlackBird' OPERATION 4 ACCESS 0		// 'Transmitir'
	//ADD OPTION aRotina Title STR0010 Action 'OA4020043_CriarGrupo' OPERATION 4 ACCESS 0		// 'Criar Grupo'
	//ADD OPTION aRotina Title STR0011 Action 'OA4020015_DesfazerGrupo' OPERATION 4 ACCESS 0		// 'Desfazer Grupo'
	ADD OPTION aRotina Title STR0012 Action 'OA4020053_ExcluirBlackBird' OPERATION 4 ACCESS 0		// 'Excluir Registro'
//	ADD OPTION aRotina Title 'Excluir' Action 'VIEWDEF.OFIA402' OPERATION 5 ACCESS 0
	ADD OPTION aRotina Title STR0013 Action 'VIEWDEF.OFIA402' OPERATION 8 ACCESS 0		// 'Imprimir'
	ADD OPTION aRotina Title STR0014 Action 'VIEWDEF.OFIA402' OPERATION 9 ACCESS 0		// 'Copiar'
	ADD OPTION aRotina Title STR0015 Action 'OA4020073_LogTransmissao' OPERATION 2 ACCESS 0		// 'Log Transmissão'

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

	VK7->(dbSetOrder(4))

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('VK7')
	oBrowse:SetDescription( STR0001 ) // Cadastro de Clientes

	oBrowse:AddLegend( 'VK7->VK7_GROUP == "1"' , 'BR_AZUL'  , STR0016 ) // "Não possui cadastro na base da John Deere."		"Agrupador"
	oBrowse:AddLegend( 'VK7->VK7_GROUP == "0"' , 'BR_BRANCO', STR0017 ) // "Cliente possui cadastro válido na base da John Deere."		"Customer"

	oBrowse:AddStatusColumns( { || IIF(VK7->VK7_GROUP == "1" , " " , IIF( Empty(VK7->VK7_A1COD) , 'BR_VERMELHO','BR_VERDE' )) }, { || OA4020023_LegendaSA1() } )

	oBrowse:AddStatusColumns( { || IIF( VK7->VK7_BBINTG == "0" , 'BR_AMARELO','BR_VERDE' ) }, { || OA4020093_LegendaIntegracao() } )
	oBrowse:AddStatusColumns( { || IIF( VK7->VK7_BBSYNC == "0" , 'BR_AMARELO','BR_VERDE' ) }, { || OA4020103_LegendaSincronizacao() } )

	oBrowse:SetBlkBackColor( { || OA4020083_ColorDelete()} )

Return oBrowse

Static Function OA4020083_ColorDelete()
	if VK7->VK7_A1DEL == "1" .or. VK7->VK7_BBDEL == "1"
		//Return CLR_HGRAY
		//Return CLR_HRED
		Return CLR_RED
	endif
return Nil


Static Function TableAttDef()

	Local oAgrView
	Local oCustView

	local aFldView := FMX_COLBROWSE("VK7")

	oTableAtt := FWTableAtt():New()
	oTableAtt:SetAlias("VK7")

	oAgrView := FWDSView():New()
	oAgrView:SetName(STR0054)		// "Agrupador"
	oAgrView:SetID("AGRUPADOR")
	oAgrView:SetOrder(1)
	oAgrView:SetCollumns(aFldView)
	oAgrView:SetPublic( .T. )
	oAgrView:AddFilter(STR0054, "VK7_GROUP = '1'")	// "Agrupador"
	oAgrView:SetLegend(.t.)
	oTableAtt:AddView(oAgrView)

	oCustView := FWDSView():New()
	oCustView:SetName(STR0055)	// "Customer"
	oCustView:SetID("CUSTOMER")
	oCustView:SetOrder(1)
	oCustView:SetCollumns(aFldView)
	oCustView:SetPublic( .T. )
	oCustView:AddFilter(STR0055, "VK7_GROUP = '0'")	// "Customer"
	oCustView:SetLegend(.t.)
	oTableAtt:AddView(oCustView)

Return oTableAtt

Function OA4020013_ValidCodVK7(cCodVK7)
	Default cCodVK7 := FWFldGet("VK7_CODVK7")

	If Vazio()
		Return .t.
	EndIf

	If ! ExistCPO("VK7",cCodVK7,1)
		Return .f.
	EndIf

	cSQL := "SELECT VK7_GROUP FROM " + RetSQLName("VK7") + " WHERE VK7_FILIAL = '" + xFilial("VK7") + "' AND VK7_CODIGO = '" + cCodVK7 + "' AND D_E_L_E_T_ = ' '"

	If FM_SQL(cSQL) <> "1"
		FMX_HELP("OA402ERR1", STR0018, STR0019)		// "Customer informado não é agrupador."		"Selecione um registro gravado como agrupador."
		Return .f.
	EndIf

	//FWFldPut(cCampo,xConteudo,/*nLinha*/,/*oModel*/,.T.,.T.)
	//VK7_BTREID

Return .t.

Static Function OA4020063_AddTrigger(oAuxStru, aAuxTrigger)
	oAuxStru:AddTrigger(aAuxTrigger[1], aAuxTrigger[2], aAuxTrigger[3], aAuxTrigger[4])
Return

Function OA4020033_TransmitirBlackBird(cAlias,nReg,nOpc, lExibeHelp)

	Local oCustomer
	Local oCustomerIntg
	Local oMessage

	Default lExibeHelp := .t.

	if empty(VK7->VK7_REFID)
		if lExibeHelp
			Help(" ",1,"OBRIGAT",,RetTitle("VK7_REFID") ,3,1)
		endif
		return .f.
	endif

	if empty(VK7->VK7_CNUMB)
		if lExibeHelp
			Help(" ",1,"OBRIGAT",,RetTitle("VK7_CNUMB") ,3,1)
		endif
		return .f.
	endif

	if VK7->VK7_BBSYNC == "1"
		if lExibeHelp
			FMX_HELP("OA402ERR004", STR0020)	// "Registro já está sincronizado com a John Deere"
		endif
		return .t.
	endif
	
	// CursorWait()
	oModel := FWLoadModel("OFIA402")
	oModel:setOperation(MODEL_OPERATION_UPDATE)

   oModel:Activate()

	oCustomer := OFSoCustomer():New()
	oCustomerIntg := oCustomer:FindByRecno( VK7->(recno()) )

	if VK7->VK7_BBINTG == "1"
		oMessage := OFSoCustomerUpdatedInDbsMessage():New(oCustomerIntg)
	else
		oMessage := OFSoCustomerCreatedInDbsMessage():New(oCustomerIntg)
	endif

	if IsBlind() //FWGetRunSchedule()
		oMessage:Send()
	else
		FWMsgRun(, {|oSay| oMessage:Send() }, STR0021, STR0022 + VK7->VK7_REFID)	// "John Deere - Blackbird"		"Atualizando Customer - "
	endif

	If oMessage:oSoRequest:GetHTTPResponse() == 200
		oModel:SetValue("MODEL_VK7", "VK7_BBINTG", "1" )
		oModel:SetValue("MODEL_VK7", "VK7_BBSYNC", "1" )
		oModel:SetValue("MODEL_VK7", "VK7_BBDEL ", "0" )
		if empty(oModel:GetValue("MODEL_VK7","VK7_BBDINC"))
			oModel:SetValue("MODEL_VK7", "VK7_BBDINC", FGX_Timestamp() )
		endif
		oModel:SetValue("MODEL_VK7", "VK7_BBDALT", FGX_Timestamp() )

		If oModel:VldData()
			oModel:CommitData()
		endif
		oModel:DeActivate()
		// CursorArrow()

		if lExibeHelp .and. ! FunName() $ "OFIA264;BBLIMP"
			MsgInfo(STR0023)		// "Registro transmitido"
		endif
	Else
		if lExibeHelp
			MsgInfo(STR0024)		// "Falha na transmissão do registro. Consulte o log de transmissão."
		endif
	EndIf

	//oMessage:Delay()

	//oMessageClass := OFDMSMessage():New()
	//oMessageClass:Process()
	//aMessages := oMessageClass:WithInitialStatus():NotDeleted():Limit(10):Order("VK6_DATINC ASC")
	//varInfo("Mensagens", aMessages)

Return


//Function OA4020043_CriarGrupo(cAlias,nReg,nOpc)
//
//	Local oModelCust
//	Local oModelGrp
//	Local oModelAux
//	Local cSQL
//	Local cQAlias := "TVK7"
//	Local lRet := .f.
//	local oAux
//	local oStruct
//	local aAux
//	local nI
//
//	local nRecVK7 := 0
//	Local nRegGrp := 0
//
//	Local oSqlHelp := DMS_SqlHelper():New()
//
//	Local cVK7CNUMB := ""
//
//	// Verifica se ja existe um registro agrupador.
//	if !empty(VK7->VK7_CODVK7) .and. !empty(VK7->VK7_BTREID) .and. !empty(VK7->VK7_BTNUMB)
//		FMX_HELP("OA402ERR001", STR0025)		// "Registro já possui um registro agrupador."
//		return lRet
//	endif
//
//	// Verifica se ja existe um registro agrupador.
//	if VK7->VK7_GROUP == "1"
//		FMX_HELP("OA402ERR002",STR0026)	// "Registro já é um registro agrupador."
//		return lRet
//	endif
//
//	if VK7->VK7_BBDEL == "1"
//		FMX_HELP("OA402ERR006", STR0027)	// "Registro está marcado como deletado."
//		return lRet
//	EndIf
//
//	If ! MsgYesNo(STR0028)		// "Confirma geração do registro agrupador"
//		Return .t.
//	EndIf
//
//	nRecVK7 := VK7->(Recno())
//	
//	// CursorWait()
//	oModelCust := FWLoadModel("OFIA402")
//	oModelCust:setOperation(MODEL_OPERATION_UPDATE)
//
//	oModelCust:Activate()
//
//	cVK7CNUMB := Left(oModelCust:GetValue("MODEL_VK7", "VK7_CNUMB"), GetSX3Cache("A1_COD","X3_TAMANHO") )
//
//	if !OA4020045_QtdClienteNaoDeletado(cVK7CNUMB)
//		FMX_HELP("OA402ERR007",STR0029)		// "Para criação de um grupo é necessário que haja mais de uma filial para o cliente selecionado"
//		return lRet
//	EndIf
//
//	// Criar uma nova Model para criar o grupo
//	oModelGrp := FWLoadModel("OFIA402")
//
//	cQuery := "SELECT VK7.R_E_C_N_O_ AS REGVK7 "
//	cQuery += " FROM " + RetSQLName("VK7") + " VK7 "
//	cQuery += " WHERE VK7.VK7_FILIAL = '" + xFilial("VK7") + "' "
//	cQuery += 	" AND "+ oSqlHelp:CompatFunc('SUBSTR') +"(VK7.VK7_CNUMB, 1, " +cValtoChar(GetSX3Cache("A1_COD","X3_TAMANHO"))+ ") = '"+ cVK7CNUMB + "' "
//	cQuery += 	" AND VK7.VK7_GROUP = '1' "
//	cQuery += 	" AND VK7.D_E_L_E_T_ = ' '"
//
//	nRegGrp := FM_SQL(cQuery)
//	
//	If nRegGrp > 0
//		VK7->(DbGoTo(nRegGrp))
//		oModelGrp:setOperation(MODEL_OPERATION_UPDATE)
//	Else
//		oModelGrp:setOperation(MODEL_OPERATION_INSERT)
//	EndIf
//
//	oModelGrp:Activate()
//
//	Begin Transaction
//	Begin Sequence
//
//		If oModelGrp:GetOperation() == 3 // Inclusão
//			oAux := oModelGrp:GetModel( 'MODEL_VK7' )
//			oStruct := oAux:GetStruct()
//			aAux := oStruct:GetFields()
//
//			For nI := 1 To Len( aAux )
//
//				do case
//				case aAux[nI,3] == "VK7_GROUP"
//					oModelGrp:SetValue("MODEL_VK7", "VK7_GROUP"  , "1")
//
//				case aAux[nI,3] == "VK7_CNUMB"
//					oModelGrp:SetValue("MODEL_VK7", "VK7_CNUMB"  , cVK7CNUMB )
//
//				case allTrim(aAux[nI,3]) $ "VK7_TYPE/VK7_CPNAME/VK7_DOBUAS/VK7_FSNAME/VK7_LSNAME/VK7_EMAIL/VK7_PPHONE/VK7_FAXNUM/VK7_STATUS/VK7_MAEND1/VK7_MAEND2/VK7_MAEND3/VK7_MACIDA/VK7_MAESTA/VK7_MAPAIS/VK7_MACEP/VK7_PAEND1/VK7_PAEND2/VK7_PAEND3/VK7_PACIDA/VK7_PAESTA/VK7_PAPAIS/VK7_PACEP"
//					If !( lAux := oModelGrp:SetValue( 'MODEL_VK7', aAux[nI,3]  , oModelCust:GetValue("MODEL_VK7", aAux[nI,3]) ) )
//						lRet := .F.
//						Exit
//					EndIf
//				end case
//
//			Next
//
//			oModelGrp:SetValue("MODEL_VK7", "VK7_BBDEL" , "0"  )
//			oModelGrp:SetValue("MODEL_VK7", "VK7_BBDINC" , " "  ) // Limpa data de inclusao
//			
//			oModelGrp:SetValue("MODEL_VK7", "VK7_BBSYNC" , "0"  ) // Marca como nao sincronizado para enviar a JD
//
//			//Conout("Criando agrupador: " + oModelGrp:GetValue("MODEL_VK7","VK7_REFID") + " " + oModelGrp:GetValue("MODEL_VK7","VK7_CNUMB" ))
//
//		Else
//			oModelGrp:SetValue("MODEL_VK7", "VK7_BBINTG" , "0" ) // Marca como nao integrado para enviar a JD
//			oModelGrp:SetValue("MODEL_VK7", "VK7_BBSYNC" , "0"  ) // Marca como nao sincronizado para enviar a JD
//			oModelGrp:SetValue("MODEL_VK7", "VK7_BBDINC" , " " ) // Limpa data de inclusao
//			oModelGrp:SetValue("MODEL_VK7", "VK7_BBDEL" , "0") // Desmarca como deletado
//		EndIf
//		//
//		If ! ModCommit(oModelGrp)
//			Break
//		EndIf
//
//		c_CODIGO_Grupo := oModelGrp:GetValue("MODEL_VK7", "VK7_CODIGO" )
//		c_REFID_Grupo := oModelGrp:GetValue("MODEL_VK7", "VK7_REFID"  )
//		c_CNUMB_Grupo := oModelGrp:GetValue("MODEL_VK7", "VK7_CNUMB"  )
//
//		oModelGrp:DeActivate()
//
//		VK7->(dbGoTo(nRecVK7))
//
//		//ConOut(STR0030 + oModelCust:GetValue("MODEL_VK7","VK7_REFID") + " " + oModelCust:GetValue("MODEL_VK7","VK7_CNUMB" ))	// "Ajuste Customer: "
//
//		oModelCust:SetValue("MODEL_VK7", "VK7_CODVK7" , c_CODIGO_Grupo )
//		oModelCust:SetValue("MODEL_VK7", "VK7_BTREID" , c_REFID_Grupo )
//		oModelCust:SetValue("MODEL_VK7", "VK7_BTNUMB" , c_CNUMB_Grupo )
//		oModelCust:SetValue("MODEL_VK7", "VK7_BBSYNC" , "0"  ) // Marca como nao sincronizado para enviar a JD
//		If ! ModCommit(oModelCust)
//			Break
//		EndIf
//
//		c_A1FIL_Customer := oModelCust:GetValue('MODEL_VK7', 'VK7_A1FIL')
//		c_A1COD_Customer := oModelCust:GetValue('MODEL_VK7', 'VK7_A1COD')
//		c_A1LOJA_Customer := oModelCust:GetValue('MODEL_VK7', 'VK7_A1LOJA')
//
//		oModelCust:DeActivate()
//
//		// Ajusta outros customers que já estiverem na base
//		oModelAux := FWLoadModel("OFIA402")
//		cSQL := ;
//			"SELECT R_E_C_N_O_ VK7RECNO " +;
//			" FROM " + RetSQLName("VK7") + " VK7" +;
//			" WHERE VK7.VK7_FILIAL = '" + FWxFilial("VK7") + "'" + ;
//			" AND VK7.VK7_A1FIL = '" + c_A1FIL_Customer + "'" +;
//			" AND VK7.VK7_A1COD = '" + c_A1COD_Customer + "'" +;
//			" AND VK7.VK7_A1LOJA NOT IN (' ','" + c_A1LOJA_Customer + "') " +;
//			" AND VK7.D_E_L_E_T_ = ' ' " +;
//			" ORDER BY VK7.VK7_CODIGO "
//		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cQAlias, .F., .T. )
//		Do While !( cQAlias )->( Eof() )
//
//			oModelAux:setOperation(MODEL_OPERATION_UPDATE)
//
//			VK7->(dbGoTo(( cQAlias )->( VK7RECNO )))
//
//			//ConOut(STR0031 + VK7->VK7_REFID + " " + VK7->VK7_CNUMB)		// "Proc VK7: "
//
//			oModelAux:Activate()
//
//			oModelAux:SetValue("MODEL_VK7", "VK7_CODVK7" , c_CODIGO_Grupo )
//			oModelAux:SetValue("MODEL_VK7", "VK7_BTREID" , c_REFID_Grupo )
//			oModelAux:SetValue("MODEL_VK7", "VK7_BTNUMB" , c_CNUMB_Grupo )
//			oModelAux:SetValue("MODEL_VK7", "VK7_BBSYNC" , "0"  ) // Marca como nao sincronizado para enviar a JD
//
//			If ! ModCommit(oModelAux)
//				Break
//			endif
//
//			oModelAux:DeActivate()
//			(cQAlias)->(dbSkip())
//		EndDo
//		(cQAlias)->(dbCloseArea())
//		//
//
//	Recover
//		lRet := .f.
//
//	End Sequence
//	End Transaction
//
//	// CursorArrow()
//
//	//oMessage:Delay()
//
//	//oMessageClass := OFDMSMessage():New()
//	//oMessageClass:Process()
//	//aMessages := oMessageClass:WithInitialStatus():NotDeleted():Limit(10):Order("VK6_DATINC ASC")
//	//varInfo("Mensagens", aMessages)
//
//Return

//Static Function ModCommit(oAuxModel)
//
//	Local lRet
//	Local aErro
//
//	If ( lRet := oAuxModel:VldData() )
//		lRet := oAuxModel:CommitData()
//	EndIf
//
//	If ! lRet
//		// Se os dados não foram validados obtemos a descrição do erro para gerar LOG ou mensagem de aviso
//		aErro   := oModel:GetErrorMessage()
//
//		// A estrutura do vetor com erro é:
//		//  [1] Id do formulário de origem
//		//  [2] Id do campo de origem
//		//  [3] Id do formulário de erro
//		//  [4] Id do campo de erro
//		//  [5] Id do erro
//		//  [6] mensagem do erro
//		//  [7] mensagem da solução
//		//  [8] Valor atribuido
//		//  [9] Valor anterior
//
//		AutoGrLog( STR0032 + ' [' + AllToChar( aErro[1]  ) + ']' )	// "Id do formulário de origem:"
//		AutoGrLog( STR0033 + ' [' + AllToChar( aErro[2]  ) + ']' )	// "Id do campo de origem:     "
//		AutoGrLog( STR0034 + ' [' + AllToChar( aErro[3]  ) + ']' )	// "Id do formulário de erro:  "
//		AutoGrLog( STR0035 + ' [' + AllToChar( aErro[4]  ) + ']' )	// "Id do campo de erro:       "
//		AutoGrLog( STR0036 + ' [' + AllToChar( aErro[5]  ) + ']' )	// "Id do erro:                "
//		AutoGrLog( STR0037 + ' [' + AllToChar( aErro[6]  ) + ']' )	// "Mensagem do erro:          "
//		AutoGrLog( STR0038 + ' [' + AllToChar( aErro[7]  ) + ']' )	// "Mensagem da solução:       "
//		AutoGrLog( STR0039 + ' [' + AllToChar( aErro[8]  ) + ']' )	// "Valor atribuido:           "
//		AutoGrLog( STR0040 + ' [' + AllToChar( aErro[9]  ) + ']' )	// "Valor anterior:            "
//
//		MostraErro()
//
//	EndIf
//
//Return lRet


Function OA4020053_ExcluirBlackBird(cAlias,nReg,nOpc,lExibeHelp,lRemoveGroup)

	Local oCustomer
	Local oCustomerIntg
	Local oMessage

	Default lExibeHelp := .t.
	Default lRemoveGroup := .f.

	if VK7->VK7_BBINTG <>"1"
		if lExibeHelp
			FMX_HELP("OA402ERR003",STR0041)		// "Registro não esta integrado com o Blackbird."
		endif
		Return .f.
	EndIf

	if VK7->VK7_A1DEL == "0" .and. VK7->VK7_GROUP == "0"
		if lExibeHelp
			FMX_HELP("OA402ERR005",STR0042)	// "Registro do cliente deve ser excluido para remover o registro do blackbird."
		endif
		Return .f.
	EndIf

	if VK7->VK7_GROUP == "1" .and. ! lRemoveGroup
		if lExibeHelp
			FMX_HELP("OA402ERR010",STR0043,STR0044)		// "Não é permitido remover grupo através da opção Excluir"		"Selecione a opção correta no menu do Browse."
		endif
		Return .f.
	EndIf

	CursorWait()
	oModel := FWLoadModel("OFIA402")
	oModel:setOperation(MODEL_OPERATION_UPDATE)

	oModel:Activate()

	oCustomer := OFSoCustomer():New()
	oCustomerIntg := oCustomer:FindByRecno( VK7->(recno()) )

	oMessage := OFSoCustomerRemovedInDbsMessage():New(oCustomerIntg)
	oMessage:Send()

	If oMessage:oSoRequest:GetHTTPResponse() == 200
		oModel:SetValue("MODEL_VK7", "VK7_BBINTG", "0" )
		oModel:SetValue("MODEL_VK7", "VK7_BBDEL ", "1" )
		oModel:SetValue("MODEL_VK7", "VK7_BBDALT", FGX_Timestamp() )

		If oModel:VldData()
			oModel:CommitData()
		endif
		oModel:DeActivate()
		// CursorArrow()

		if lExibeHelp
			MsgInfo(STR0045)		// "Registro excluido."
		endif
	Else
		if lExibeHelp
			MsgInfo(STR0046)		// "Falha na transmissão do registro. Consulte o log de transmissão."
		endif
		Return .f.
	EndIf

	//oMessage:Delay()

	//oMessageClass := OFDMSMessage():New()
	//oMessageClass:Process()
	//aMessages := oMessageClass:WithInitialStatus():NotDeleted():Limit(10):Order("VK6_DATINC ASC")
	//varInfo("Mensagens", aMessages)

Return .t.


/*/{Protheus.doc} OA4020023_LegendaSA1
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 01/01/2022
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OA4020023_LegendaSA1()
	Local oLegenda  :=  FWLegend():New()

	oLegenda:Add( '', " " , STR0047 )		// "Registro Agrupador."
	oLegenda:Add( '', "BR_VERMELHO" , STR0004 ) // 'Não possui cadastro na base do Protheus.'
	oLegenda:Add( '', "BR_VERDE"    , STR0005 ) // 'Cliente possui cadastro válido na base do Protheus.'

	oLegenda:Activate()
	oLegenda:View()
	oLegenda:DeActivate()

Return Nil

Function OA4020073_LogTransmissao(cAlias,nReg,nOpc)

	local cOriKey := VK7->VK7_REFID

	OFIA262("@ VK5_ORITAB = 'VK7' AND VK5_ORIKEY = '" + cOriKey + "' ", "CUSTOMER")

Return

Static Function OA4020093_LegendaIntegracao()
	Local oLegenda  :=  FWLegend():New()

	oLegenda:Add( '', "BR_AMARELO" , STR0048 )	// "Registro NÃO integrado com o Blackbird."
	oLegenda:Add( '', "BR_VERDE"   , STR0049 )	// "Registro integrado com o Blackbird."

	oLegenda:Activate()
	oLegenda:View()
	oLegenda:DeActivate()

Return Nil

Static Function OA4020103_LegendaSincronizacao()
	Local oLegenda  :=  FWLegend():New()

	oLegenda:Add( '', "BR_AMARELO" , STR0050 )		// "Registro NÃO sincronizado com o Blackbird."
	oLegenda:Add( '', "BR_VERDE"   , STR0051 ) 		// "Registro sincronizado com o Blackbird."

	oLegenda:Activate()
	oLegenda:View()
	oLegenda:DeActivate()

Return Nil

/*/{Protheus.doc} OA4020015_DesfazerGrupo
//TODO Descrição auto-gerada.
@author Renato Vinicius
@since 17/06/2022
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
//Function OA4020015_DesfazerGrupo(cAlias,nReg,nOpc)
//
//	Local aVRegVK7 := {}
//	Local oModGrupo
//	Local nI := 0
//
//	If VK7->VK7_GROUP == "1"
//		OA4020025_LevantaClienteAgrupado(@aVRegVK7,VK7->VK7_CNUMB)
//	Else
//		FMX_HELP("OA402ERR009",STR0052,STR0053)		// "Para utilizar essa opção é necessário que selecione um registro de tipo Agrupador."		"Selecione um registro do tipo agrupador."
//		Return .f.
//	EndIf
//
//	If OA4020053_ExcluirBlackBird(cAlias,nReg,nOpc,,.t.)
//
//		oModGrupo := FWLoadModel("OFIA402")
//
//		For nI := 1 to Len(aVRegVK7)
//			VK7->(DbGoTo(aVRegVK7[nI]))
//
//			oModGrupo:setOperation(MODEL_OPERATION_UPDATE)
//
//			oModGrupo:Activate()
//
//			oModGrupo:SetValue("MODEL_VK7", "VK7_BTREID", "" )
//			oModGrupo:SetValue("MODEL_VK7", "VK7_BTNUMB", "" )
//			oModGrupo:SetValue("MODEL_VK7", "VK7_CODVK7", "" )
//			oModGrupo:SetValue("MODEL_VK7", "VK7_BBSYNC", "0" )
//
//			If oModGrupo:VldData()
//				oModGrupo:CommitData()
//			endif
//			oModGrupo:DeActivate()
//			// CursorArrow()
//		Next
//
//	Endif
//
//Return

/*/{Protheus.doc} OA4020025_LevantaClienteAgrupado
//TODO Descrição auto-gerada.
@author Renato Vinicius
@since 17/06/2022
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function OA4020025_LevantaClienteAgrupado(aVRegVK7,cVK7CNUMB)

	OA4020035_ClienteAgrupado(@aVRegVK7,.t.,,cVK7CNUMB)

Return

/*/{Protheus.doc} OA4020045_QtdClienteNaoDeletado
//TODO Descrição auto-gerada.
@author Renato Vinicius
@since 17/06/2022
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function OA4020045_QtdClienteNaoDeletado(cVK7CNUMB)

	Local nQtdCli := 0

	nQtdCli := OA4020035_ClienteAgrupado(,,.t.,cVK7CNUMB)

Return nQtdCli > 1 //Quantidade de clientes superior a 1

/*/{Protheus.doc} OA4020035_ClienteAgrupado
//TODO Descrição auto-gerada.
@author Renato Vinicius
@since 17/06/2022
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Function OA4020035_ClienteAgrupado(aVRegVK7,lCliAgrup,lCheckNReg,cVK7CNUMB)

	Local cQAlias := "TMPVK7"
	Local oSqlHelp := DMS_SqlHelper():New()

	Default lCheckNReg := .f.
	Default lCliAgrup  := .f.
	Default aVRegVK7   := {}
	Default cVK7CNUMB  := ""

	If lCheckNReg
		cQuery := "SELECT COUNT(*) "
	Else
		cQuery := "SELECT VK7.R_E_C_N_O_ AS REGVK7 "
	EndIf
	
	cQuery += " FROM " + RetSQLName("VK7") + " VK7 "
	cQuery += " WHERE VK7.VK7_FILIAL = '" + xFilial("VK7") + "' "
	cQuery += 	" AND "+ oSqlHelp:CompatFunc('SUBSTR') +"(VK7.VK7_CNUMB, 1, " +cValtoChar(GetSX3Cache("A1_COD","X3_TAMANHO"))+ ") = '" + cVK7CNUMB + "' "
	cQuery += 	" AND VK7.VK7_GROUP = '0' "

	If lCheckNReg
		cQuery += 	" AND VK7.VK7_BBDEL = '0' "
	EndIf
	
	If lCliAgrup
		cQuery += 	" AND VK7.VK7_BTREID <> ' '"
		cQuery += 	" AND VK7.VK7_BTNUMB <> ' '"
	Endif

	cQuery += 	" AND VK7.D_E_L_E_T_ = ' '"

	If lCheckNReg
		Return FM_SQL(cQuery)
	Else
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
	EndIf

	While !TMPVK7->(Eof())

		aAdd(aVRegVK7, TMPVK7->REGVK7)
		TMPVK7->(DbSkip())

	EndDo
	TMPVK7->(dbCloseArea())

Return .t.
