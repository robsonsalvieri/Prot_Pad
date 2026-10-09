#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "VEIA073.CH"

static oDMSSQL430


/*/{Protheus.doc} VEIA073
	Controle de Atualização de KM/Horimetro de veículo

	@author rubens.takahashi
	@since 19/04/2022
	@version 1.0
	@return ${return}, ${return_description}
	@type function
/*/
Function VEIA073()
	Local oBrowse
	Private cMotivo := "000026" // Varivel utilizada na consulta padrao de motivos (VS0)

	oBrowse := BrowseDef()
	oBrowse:Activate()
Return

/*/{Protheus.doc} ModelDef
	@author rubens.takahashi
	@since 19/04/2022
	@version 1.0
	@return ${return}, ${return_description}
	@type function
/*/
Static Function ModelDef()
	local oModel := FWLoadModel("VEIA071")
	local oStruVO0 := FWFormStruct( 1, 'VO0' )
	local oStruVW0 := oModel:GetModel("MODEL_VW0"):GetStruct()

	oStruVW0:DeActivate()
	AddTrigger( oStruVW0 , FwStruTrigger("VW0_CHAINT","VW0_CHAINT","VA0730063_Trigger(fwFldGet('VW0_CHAINT'))",.F.) )
	oStruVW0:Activate()

	oStruVO0:SetProperty('VO0_CODVW0',MODEL_FIELD_OBRIGAT,.f.)

	AddTrigger( oStruVO0 , FwStruTrigger("VO0_CHAINT","VO0_BBINTG","VA0730033_SetSync()",.F.,"",0,"") )
	AddTrigger( oStruVO0 , FwStruTrigger("VO0_DATA","VO0_BBINTG","VA0730033_SetSync()",.F.,"",0,"") )
	AddTrigger( oStruVO0 , FwStruTrigger("VO0_HORA","VO0_BBINTG","VA0730033_SetSync()",.F.,"",0,"") )

	oModel:AddFields('MODEL_VO0', 'MODEL_VW0', oStruVO0 , /* <bPre > */ , /* <bPost > */ , /* <bLoad> */ )

	oModel:GetModel( 'MODEL_VO0' ):SetDescription(STR0002)	// 'Log Atualização de Equipment'

	oModel:SetRelation('MODEL_VO0', { { 'VO0_FILIAL' , 'xFilial("VO0")' } , { 'VO0_CODVW0' , 'VW0_CODIGO' } } , 'VO0_FILIAL+VO0_CODVW0' )



//	local oModel := FWLoadModel("VEIA071")
//	Local oStruVO0 := FWFormStruct( 1, 'VO0' )
//
//	oStruVO0:SetProperty('VO0_CODVW0',MODEL_FIELD_OBRIGAT,.f.)
//
//	//AddTrigger( oStruVO0 , FwStruTrigger("VO0_CHASSI","VO0_CHAINT","VV1->VV1_CHAINT",.T.,"VV1",2,"xFilial('VV1') + FWFldGet('VO0_CHASSI')") )
//	//AddTrigger( oStruVO0 , FwStruTrigger("VO0_MOTIVO","VO0_DESMOT","VS0->VS0_DESMOT",.T.,"VS0",1,"xFilial('VS0')+'000026'+FWFldGet('VO0_MOTIVO')") )
//
//	//AddTrigger( oStruVO0 , FwStruTrigger("VO0_CHASSI","VO0_BBINTG","VA0730033_SetSync()",.F.,"",0,"") )
//	//AddTrigger( oStruVO0 , FwStruTrigger("VO0_DATA","VO0_BBINTG","VA0730033_SetSync()",.F.,"",0,"") )
//	//AddTrigger( oStruVO0 , FwStruTrigger("VO0_HORA","VO0_BBINTG","VA0730033_SetSync()",.F.,"",0,"") )
//
//	oModel:AddFields('MODEL_VO0', 'MODEL_VW0', oStruVO0 , /* <bPre > */ , /* <bPost > */ , /* <bLoad> */ )
//
//	oModel:SetDescription( 'LOG' )
//	oModel:GetModel( 'MODEL_VO0' ):SetDescription('Log Atualização de KM/Horímetro')
//
//	oModel:SetRelation('MODEL_VO0', { { 'VO0_FILIAL' , 'xFilial("VO0")' } , { 'VO0_CODVW0' , 'VW0_CODIGO' } } , 'VO0_FILIAL+VO0_CODVW0' )
//
	oModel:InstallEvent("PADRAO",, VEIA073EVDEF():New())
	// oModel:InstallEvent("LOGEV",, MVCLogEv():New("VEIA073"))

Return oModel

Static Function AddTrigger(oAuxStru, aAuxTrigger)
	oAuxStru:AddTrigger(aAuxTrigger[1], aAuxTrigger[2], aAuxTrigger[3], aAuxTrigger[4])
Return

Function VA0730063_Trigger(cParChaint)
	local oModel := FWModelActive()
	//local oVW0
	//local cChaInt

	//conout("tstTrigger - " + cValToChar(cParChaint))

	if oModel:GetID() == "VEIA071" .And. oModel:IsActive()
		//oVW0 := oModel:GetModel("MODEL_VW0")
		//cChaint := oVW0:GetValue("VW0_CHAINT")

		//conout("tstTrigger - cChaint " + cValToChar(cChaint))
		FWFldPut("VO0_CHAINT",cParChaint,/*nLinha*/,oModel,.T.,.F.)

	endif
Return


/*/{Protheus.doc} ViewDef
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 19/04/2022
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ViewDef()
	Local oView
	Local oModel := FWLoadModel( 'VEIA073' )
//	Local oStruVW0 := FWFormStruct( 2, 'VW0' , { |cField| ! (AllTrim(Upper(cField)) ! $ "VW0_KILOME/VW0_HORTRI/VW0_DATA/VW0_HORA/VW0_ORIGEM/VW0_FILOSV/VW0_NUMOSV/VW0_FILPRO/VW0_PROATU/VW0_LJPATU/VW0_FILENT/VW0_TRACPA/VW0_FILSAI/VW0_NUMTRA") })
	Local oStruVW0 := FWFormStruct( 2, 'VW0' , { |cField| AllTrim(Upper(cField)) $ "VW0_FILIAL/VW0_CODIGO/VW0_USERID/VW0_DATREG/VW0_HORREG/VW0_ROTINA/VW0_CHASSI/VW0_CHAINT" })
	//Local oStruVO0 := FWFormStruct( 2, 'VO0' , { |cField| ! (AllTrim(Upper(cField)) $ "VO0_CODVW0") })
	Local oStruVO0 := FWFormStruct( 2, 'VO0' , { |cField| AllTrim(Upper(cField)) $ "VO0_KILOME/VO0_HORTRI/VO0_DATA/VO0_HORA/VO0_ORIGEM/VO0_MOTIVO/VO0_OBSERV" })
	//Local oStruVO0 := FWFormStruct( 2, 'VO0')

	oView := FWFormView():New()
	oView:SetModel( oModel )

	oView:SetContinuousForm(.T.)

	oView:CreateHorizontalBox( 'TELA_VW0' , 10 )
	oView:AddField('1VIEW_VW0', oStruVW0, 'MODEL_VW0' )
	oView:SetOwnerView('1VIEW_VW0','TELA_VW0')
	//oView:EnableTitleView("1VIEW_VW0", FwX2Nome("VW0"))

	//oView:CreateHorizontalBox( 'TELA_VO0' , 40 )
	oView:AddField('2VIEW_VO0', oStruVO0, 'MODEL_VO0' )
	oView:SetOwnerView('2VIEW_VO0','TELA_VW0')
	//oView:EnableTitleView("2VIEW_VO0", FwX2Nome("VO0"))

Return oView

/*/{Protheus.doc} MenuDef
	@author rubens.takahashi
	@since 19/04/2022
	@version 1.0
	@return ${return}, ${return_description}
	@type function
/*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.VEIA073' OPERATION 2 ACCESS 0	// 'Visualizar'
	ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.VEIA073' OPERATION 3 ACCESS 0	// 'Incluir'
	ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.VEIA073' OPERATION 4 ACCESS 0	// 'Alterar'
	if OA2610123_integraDynamics(.f.)
		ADD OPTION aRotina Title STR0006 Action 'VA0730013_TransmitirBlackBird' OPERATION 4 ACCESS 0	// 'Transmitir'
	endif

Return aRotina

/*/{Protheus.doc} BrowseDef
	@author rubens.takahashi
	@since 19/04/2022
	@version 1.0
	@return ${return}, ${return_description}
	@type function
/*/
Static Function BrowseDef()
	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('VW0')
	oBrowse:SetDescription( STR0001 )
	//oBrowse:ColumnsFields({;
	//	"VW0_CODIGO", "VW0_CHASSI", "VW0_CHAINT", "VW0_DATREG", "VW0_HORREG", "VW0_KILOME", "VW0_HORTRI", "VW0_DATA  ", "VW0_HORA  ", "VW0_ORIGEM", "VW0_FILOSV", "VW0_NUMOSV";
	//})
	oBrowse:SetFilterDefault("@ EXISTS ( SELECT VO0.VO0_CODVW0 FROM " + RetSQLName("VO0") + " VO0 WHERE VO0.VO0_FILIAL = VW0_FILIAL AND VO0.VO0_CODVW0 = VW0_CODIGO AND VO0.D_E_L_E_T_ = ' ' ) ")
Return oBrowse




Function VA0730013_TransmitirBlackBird(cAlias,nReg,nOpc,lExibeHelp)
	Local oEqMeter
	Local oMessage
	Default lExibeHelp := .t.

	//	Conout(" ")
	//	Conout("VA0730013_TransmitirBlackBird")
	//	Conout(" ")

	if OA2610123_integraDynamics(.f.) == .f.
		Return .t.
	endif

	VO0->(dbSetOrder(3))
	VO0->(dbSeek(FWxFilial("VO0") + VW0->VW0_CODIGO))
	VO0->(dbSetOrder(1))


	if VO0->VO0_BBINTG == "1"
		if lExibeHelp
			FMX_HELP("VA073ERR001",STR0007)	// "Registro já está integrado com o Blackbird."
		endif
		Return .f.
	EndIf

	if VO0->VO0_BBINTG == "2"
		if lExibeHelp
			FMX_HELP("VA073ERR002",STR0008)	// "Registro não pode ser enviado ao Blackbird."
		endif
		Return .f.
	EndIf

	CursorWait()

	oEqMeter := OFSoEquipmentMeter():New()
	oEqMeter := oEqMeter:FindByRecno( VO0->(recno()) )

	oMessage := OFSoEquipmentMeterUpdatedInDbsMessage():New(oEqMeter)
	FWMsgRun(, {|oSay| oMessage:Send() }, STR0009, STR0010 + VO0->VO0_BBRFID)	// "John Deere - Blackbird"		"Atualizando KM/Horimetro - "

	If oMessage:oSoRequest:GetHTTPResponse() == 200

		oModel := FWLoadModel("VEIA073")
		oModel:setOperation(MODEL_OPERATION_UPDATE)

//		Conout("VA0310013_TransmitirBlackBird - Carregando Model ")
		oModel:Activate()
//		Conout("VA0310013_TransmitirBlackBird - Model Carrregada")

		oModel:SetValue("MODEL_VO0", "VO0_BBINTG", "1" )
		if empty(oModel:GetValue("MODEL_VO0","VO0_BBDINC"))
			oModel:SetValue("MODEL_VO0", "VO0_BBDINC", FGX_Timestamp() )
		endif

		If oModel:VldData()
			oModel:CommitData()
		endif

		oModel:DeActivate()
		
		CursorArrow()

		if lExibeHelp
			MsgInfo(STR0011)	// "Registro transmitido"
		endif
	Else

		CursorArrow()

		if lExibeHelp
			MsgInfo(STR0012)	// "Falha na transmissão do registro. Consulte o log de transmissão."
		endif
	EndIf
Return


Function VA0730023_CheckLast(cChaInt)
	local cQuery
	local cAuxAlias := "TVO0LAST"
	local cDateLast := ""
	local nHourLast := 0

	cQuery := "SELECT COUNT(*) FROM " + RetSQLName("VO0") + " VO0 WHERE VO0_FILIAL = '" + xFilial("VO0") + "' AND VO0_CHAINT = '" + cChaInt + "' AND VO0_BBINTG = '0' AND D_E_L_E_T_ = ' ' "
	if fm_sql(cQuery) == 0
		return .t.
	endif

	VA0730043_LastDateHour(cChaInt, cDateLast, nHourLast)

	cQuery := "SELECT VO0.R_E_C_N_O_ VO0RECNO " +;
		 " FROM " + RetSQLName("VO0") + " VO0 " +;
		" WHERE VO0_FILIAL = '" + xFilial("VO0") + "'" +;
		  " AND VO0_CHAINT = '" + cChaInt + "'" +;
		  " AND VO0_BBINTG = '0' " +;
		  " AND ( VO0.VO0_DATA <> '" + cDateLast + "'" +;
		         " OR VO0.VO0_HORA <> " + alltrim(str(nHourLast)) + " )" +;
		  " AND D_E_L_E_T_ = ' ' "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAuxAlias , .F., .T. )
	while ! (cAuxAlias)->(Eof())
		VO0->(dbGoTo((cAuxAlias)->VO0RECNO))

		RecLock("VO0",.F.,.T.)
		VO0->VO0_BBINTG := "2"
		VO0->(MsUnLock())

		(cAuxAlias)->(dbSkip())
	end
	(cAuxAlias)->(dbCloseArea())

	cQuery := "SELECT VO0.R_E_C_N_O_ VO0RECNO " +;
		 " FROM " + RetSQLName("VO0") + " VO0 " +;
		" WHERE VO0_FILIAL = '" + xFilial("VO0") + "'" +;
		  " AND VO0_CHAINT = '" + cChaInt + "'" +;
		  " AND VO0_BBINTG = '0' " +;
		  " AND VO0.VO0_DATA = '" + cDateLast + "'" +;
		  " AND VO0.VO0_HORA = " + alltrim(str(nHourLast)) +;
		  " AND D_E_L_E_T_ = ' ' "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAuxAlias , .F., .T. )
	If !(cAuxAlias)->(Eof())

		VO0->(dbGoTo((cAuxAlias)->VO0RECNO))

		dbSelectArea("VO0")
		VA0730013_TransmitirBlackBird("VO0",VO0->(Recno()),4,.f.)
	end
	(cAuxAlias)->(dbCloseArea())

	dbSelectArea("VV1")
Return


Function VA0730033_SetSync()
	Local oModel    := FWModelActive()
	Local nOper     := oModel:GetOperation()

	local cVO0BBINTG := FWFldGet("VO0_BBINTG")

	If nOper <> MODEL_OPERATION_INSERT
		return cVO0BBINTG
	endif

	if VA0730053_isLast(FWFldGet("VO0_CHAINT"), FWFldGet("VO0_DATA"), FWFldGet("VO0_HORA"))
		return "0"
	endif
Return "2"

Function VA0730043_LastDateHour(cChaInt, cDateLast, nHourLast)

	local cAuxAlias := "TVO0LAST"
	local cQuery
	local lRetorno := .f.

	if oDMSSQL430 == NIL
		oDMSSQL430 := DMS_SqlHelper():New()
	endif

	cQuery := ;
		"SELECT VO0.VO0_DATA, VO0.VO0_HORA " +;
		 " FROM " + RetSQLName("VO0") + " VO0 " +;
		" WHERE VO0_FILIAL = '" + xFilial("VO0") + "'" +;
		  " AND VO0_CHAINT = '" + cChaInt + "'" +;
		  " AND D_E_L_E_T_ = ' '" +;
		" ORDER BY VO0.VO0_DATA DESC, VO0.VO0_HORA DESC"
	cQuery := oDMSSQL430:TOPFunc(cQuery,1)
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAuxAlias , .F., .T. )
	If !(cAuxAlias)->(Eof())
		cDateLast := (cAuxAlias)->VO0_DATA
		nHourLast := (cAuxAlias)->VO0_HORA
		lRetorno := .t.
	End
	(cAuxAlias)->(dbCloseArea())

return lRetorno

Function VA0730053_isLast(cChaInt, dVO0DATA, nVO0HORA)
	local cDateLast := ""
	local nHourLast := 0
	local dateLast

	VA0730043_LastDateHour(cChaInt, @cDateLast, @nHourLast)

	if empty(cDateLast)
		return .t.
	endif

	dateLast := StoD(cDateLast)

	if dVO0DATA > dateLast
		return .t.
	endif

	if dVO0DATA == dateLast .and. nVO0HORA > nHourLast
		return .t.
	endif
return .f.
