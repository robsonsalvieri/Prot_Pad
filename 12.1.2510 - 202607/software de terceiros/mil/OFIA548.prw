#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDef.ch"
#INCLUDE "OFIA548.ch"

//static lAuto := .f.

/*/{Protheus.doc} OFIA548

	Browse do modelo

	@author Renan Migliaris
	@since 28/11/2025
	@type function

	/*/
Function OFIA548()
	Local oBrwOFM440 := FWMBrowse():New()
	local aArea := FwGetArea()
	Private cCadastro := STR0001 //"Diário de Oficina"
	Private cFiltroVX5 := "049"
	Private lAuto := .f.

	dbSelectArea("VZW")

	oBrwOFM440:SetAlias("VZW")
	oBrwOFM440:SetDescription(cCadastro)

	oBrwOFM440:AddLegend( "VZW_ABERTO == .T.", "GREEN", STR0002 ) //"Aberto"
	oBrwOFM440:AddLegend( "VZW_ABERTO == .F.", "RED"  , STR0003 ) //"Fechado"
	oBrwOFM440:Activate()
	fwRestArea(aArea)
Return

/*/{Protheus.doc} mil_ver()

		MenuDef padrão da rotina

		@author Renan Migliaris
		@since  28/11/2025

	/*/
Static Function MenuDef()
	Local aRotina := {}
	Local lOfm440Bt := ExistBlock('OFM440BT')
	ADD OPTION aRotina Title STR0022 Action 'VIEWDEF.OFIA548' OPERATION 2 ACCESS 0 //'Visualizar'
	// ADD OPTION aRotina Title STR0023 Action 'VIEWDEF.OFIA548' OPERATION 3 ACCESS 0 //'Incluir'
	// ADD OPTION aRotina Title STR0024 Action 'VIEWDEF.OFIA548' OPERATION 4 ACCESS 0 //'Alterar'
	ADD OPTION aRotina Title STR0025 Action 'VIEWDEF.OFIA548' OPERATION 5 ACCESS 0 //'Excluir'
	// ADD OPTION aRotina Title STR0026 Action 'VIEWDEF.OFIA548' OPERATION 9 ACCESS 0 //'Copiar'
	If lOfm440Bt
		aRotina := ExecBlock("OFM440BT",.F.,.F.,{aRotina})
	Endif
Return aRotina

/*/{Protheus.doc} ModelDef

	Função ModelDef padrão

	@author Renan Migliaris
	@since 28/11/2025
	@version undefined
	@type function

	/*/
Static Function ModelDef()
	Local oStru := FWFormStruct( 1, 'VZW' )
	Local oStru2 := FWFormStruct( 1, 'VZY' )
	local oEveDef := OFIA548EVDEF():new(lAuto)

	oStru:SetProperty('VZW_FILIAL', MODEL_FIELD_NOUPD, .T.)
	oStru:SetProperty('VZW_CODIGO', MODEL_FIELD_NOUPD, .T.)
	oStru:SetProperty('VZW_DATABE', MODEL_FIELD_NOUPD, .T.)
	oStru:SetProperty('VZW_PLAVEI', MODEL_FIELD_NOUPD, .t.)
	oStru:SetProperty('VZW_CHASSI', MODEL_FIELD_NOUPD, .t.)
	oStru:SetProperty('VZW_DATABE', MODEL_FIELD_INIT, {|| date() })
	oStru:SetProperty('VZW_ABERTO', MODEL_FIELD_INIT, {|| .T.    })
	oStru:AddTrigger('VZW_CHASSI', 'VZW_CHAINT', {|| .t.}, {|oModel, cField, xValue, xOldValue| oEveDef:carregaChaInt(xValue)})
	// VZY
	oStru2:SetProperty('VZY_CODVZW', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD,"M->VZW_CODIGO"))

	oModel := MPFormModel():New('MODEL01')
	oModel:SetDescription(STR0001)
	oModel:AddFields('FRM01', /*cOwner*/, oStru, /*bPre*/,/*bPost*/, /*bLoad*/)
	oModel:GetModel('FRM01'):SetDescription(STR0004) //'Cabeçalho do diário'

	oModel:AddGrid( 'FRM02', 'FRM01', oStru2 )
	oModel:SetRelation('FRM02', {{'VZY_FILIAL',  'xFilial("VZY")'}, {'VZY_CODVZW', 'VZW_CODIGO'}}, VZY->(IndexKey(1)) )

	oModel:GetModel('FRM02'):SetDescription(STR0005) //'Eventos do diário'

	oModel:GetModel('FRM02'):SetUniqueLine({"VZY_FILIAL","VZY_CODIGO","VZY_CODVZW"})
	oModel:GetModel('FRM02'):SetOptional( .T. )

	oModel:InstallEvent("OFIA548EVDEF", /*cOwner*/, oEveDef)
Return oModel

/*/{Protheus.doc} ViewDef

	Função ViewDef padrão

	@author Renan Migliaris
	@since 27/06/2017
	@version undefined
	@type function

	/*/
Static Function ViewDef()
	Local oModel := FWLoadModel('OFIA548')
	Local oStru  := FWFormStruct( 2, 'VZW' )
	Local oStru2 := FWFormStruct( 2, 'VZY' )

	Private cFiltroVX5 := "049"

	oStru:SetProperty( 'VZW_DATFEC' , MVC_VIEW_CANCHANGE , .T. )
	oStru:RemoveField("VZW_FILIAL")
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( 'VIEW01', oStru, 'FRM01' )
	oView:AddGrid( 'VIEW02', oStru2, 'FRM02' )

	// definição de como será a tela
	oView:CreateHorizontalBox('CABEC'  , 40)
	oView:CreateHorizontalBox('FILHOS' , 60)

	oView:SetOwnerView('VIEW01', 'CABEC' )
	oView:SetOwnerView('VIEW02', 'FILHOS')

	oView:AddIncrementField( 'VIEW02', 'VZY_CODIGO' )
	oView:AddUserButton(STR0027,'CLIPS',{ |oView| OFIOC330( M->VZW_CHAINT) , oView:Refresh()}) ////"Ficha do Veículo"

Return oView

Function OA548001J_DadosVeiCompl(cCampo)
	Do Case
	Case cCampo == "VZW_DESMAR"
		VE1->(DBSetOrder(1))
		VE1->(MsSeek(xFilial("VE1")+VV1->VV1_CODMAR))
	Case cCampo == "VZW_DESMOD"
		VV2->(DBSetOrder(1))
		VV2->(DbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
	Case cCampo == "VZW_DESCOR"
		VVC->(DBSetOrder(1))
		VVC->(DbSeek(xFilial("VVC")+VV1->VV1_CODMAR+VV1->VV1_CORVEI))
	EndCase
Return

Function OA548004J_Relacao(cCampo)
	local lRet := .f.
	If !Empty(VZW->VZW_CHASSI) .and. VV1->VV1_CHASSI <> VZW->VZW_CHASSI
		VV1->(dbSetOrder(2))
		VV1->(DbSeek(xfilial('VV1')+VZW->VZW_CHASSI))
	ElseIf Empty(VZW->VZW_CHASSI)
		VV1->(dbSetOrder(9))
		VV1->(DbSeek(xfilial('VV1')+VZW->VZW_PLAVEI))
	EndIf

	OA548001J_DadosVeiCompl(cCampo)

	Do Case
	Case cCampo == "VZW_DESMAR"
		VE1->VE1_DESMAR
		lRet := .t.
	Case cCampo == "VZW_DESMOD"
		VV2->VV2_DESMOD
		lRet := .t.
	Case cCampo == "VZW_DESCOR"
		VVC->VVC_DESCRI
		lRet := .t.
	EndCase

Return lRet

/*/{Protheus.doc} OA548003J_Exist

	Retorna quantidade de acordo com critério

	@author Renan Migliaris
	@since 28/11/2025
	@version undefined
	@type function

	/*/
Function OA548003J_Exist(cTbl, cWhere)
Return FM_SQL("SELECT COUNT("+cTbl+"_FILIAL) FROM "+RetSqlName(cTbl)+" WHERE "+cTbl+"_FILIAL = '"+xfilial(cTbl)+"' AND D_E_L_E_T_ = ' ' AND " + cWhere) > 0

/*/{Protheus.doc} OA548009J_NomUsr
	Retorna o nome do usuario dos eventos do diario

	@author Renan Migliaris
	@since 28/11/2025
	@version undefined

	@type function
	/*/
Function OA548009J_NomUsr()

	Local oModel		:= FwModelActive()
	Local oMdlGrid		:= oModel
	Local cNomeUsr		:= ""

	oMdlGrid := oModel:GetModel("FRM02")

	If oMdlGrid:Length() == 0 .and. oModel:GetOperation() <> MODEL_OPERATION_INSERT
		cNomeUsr := UsrRetName( IIf( !Empty(VZY->VZY_CODUSU) , VZY->VZY_CODUSU , __cUserId ) )
	Else
		cNomeUsr := UsrRetName(__cUserId)
	EndIf

Return(cNomeUsr)

/*/{Protheus.doc} OA548022J_InicializadorPadrao
	Inicializador padrão do VZW_DESMAR, VZW_DESMOD e VZW_DESCOR
	Função para ser inserida no dicionário de dados e inicializar os campos virtuais
	@type  Static Function
	@author Renan Migliaris
	@since 01/12/2025
/*/
Function OA548022J_InicializadorPadrao(cCampo)
	cRetorno := ''

	If !Empty(VZW->VZW_CHASSI) .and. VV1->VV1_CHASSI <> VZW->VZW_CHASSI
		VV1->(dbSetOrder(2))
		VV1->(DbSeek(xfilial('VV1')+VZW->VZW_CHASSI))
	ElseIf Empty(VZW->VZW_CHASSI)
		VV1->(dbSetOrder(9))
		VV1->(DbSeek(xfilial('VV1')+VZW->VZW_PLAVEI))
	EndIf

	OA548001J_DadosVeiCompl(cCampo)

	Do Case
	Case cCampo == "VZW_DESMAR"
		cRetorno := VE1->VE1_DESMAR
	Case cCampo == "VZW_DESMOD"
		cRetorno := VV2->VV2_DESMOD
	Case cCampo == "VZW_DESCOR"
		cRetorno := VVC->VVC_DESCRI
	EndCase
Return cRetorno

/*/{Protheus.doc} nomeFunction
	(long_description)
	@type  Function
	@author user
	@since 20/04/2026
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function OA5480062_RegistraEventoDiarioOficina(cNumero, cOrigem, lDeletaEvento)

	Local lRet := .T.
	Local cCodVZW := ""
	Default lDeletaEvento := .F.

	If !FWAliasInDic("VZW")
		Return .T.
	Endif

	If lDeletaEvento
		cCodVZW := OA5480122_VerificaExistenciaDiario(cOrigem, cNumero)
		lRet := OA5480132_DeletaEvento(cCodVZW, cOrigem)
	Else
		lRet := OA5480152_IncluiEventoDiarioOficina(cNumero, cOrigem)
	Endif

Return lRet

/*/{Protheus.doc} OA5480062_ControleDeOrigem
	Funcao para geracao de registro automatico com base na origem

	@author Bruno Forcato
	@since 02/03/2026
/*/
Function OA5480152_IncluiEventoDiarioOficina(cNumero, cOrigem)
	Local aArea		:= GetArea()
	Local lRetorno	:= .T.
	local aRotAutoDiario := {}
	local aCab := {}
	local aItens := {}
	local aBkpRotina := {}
	local nOpc := 3
	local aErro := {}
	local oModelVZW 

	Private lAuto := .T.
	Private lMsErroAuto := .F.
	
	OA548016K_PreparaDiarioParaOrigem(cOrigem, cNumero)

	aRotAutoDiario := OA5480082_MontaCabecalhoDoDiario(cOrigem, cNumero)
	nOpc	:= aRotAutoDiario[1] // nOpc == 3 - Novo diário || nOpc == 4 - Alterar diário existente
	aCab	:= aRotAutoDiario[2]
	aItens 	:= aRotAutoDiario[3]

	if len(aItens) > 0		
		If Type("aRotina") <> "U" .and. ValType(aRotina) == "A"
			aBkpRotina := aClone(aRotina)
		EndIf

		aRotina := MenuDef()

		Begin Sequence
			oModelVZW := FWLoadModel('OFIA548')
			oModelVZW:GetModel('FRM01'):GetStruct():SetProperty('VZW_CODIGO', MODEL_FIELD_INIT, "")
			oModelVZW:GetModel('FRM02'):GetStruct():SetProperty('VZY_CODIGO', MODEL_FIELD_INIT, "")

			FWMVCRotAuto( oModelVZW, "VZW", nOpc, { {"FRM01", aCab}, {"FRM02", aItens} } )
			If lMsErroAuto
				lRetorno := .F.
				aErro := oModelVZW:GetErrorMessage(.T.)
				FMX_HELP(aErro[MODEL_MSGERR_ID],;
					STR0006 + CRLF + ; // "Não foi possível adicionar itens."
					aErro[MODEL_MSGERR_IDFIELDERR ] + CRLF +;
					aErro[MODEL_MSGERR_ID         ] + CRLF +;
					aErro[MODEL_MSGERR_MESSAGE    ])
				Break
			EndIf
		End Sequence

		If Len(aBkpRotina) <> 0
			aRotina := aClone(aBkpRotina)
		EndIf
	endif

	RestArea( aArea )

Return lRetorno

/*/{Protheus.doc} OA5480082_MontaCabecalhoDoDiario
	Funcao para montar o cabeçalho do diario

	@author Bruno Forcato
	@since 02/03/2026
/*/
Static Function OA5480082_MontaCabecalhoDoDiario(cOrigem,cNumero)
	Local aCabecalhoDiario := {}
	local cCodVZW := ''
	Local nOpc	:= 4 // Alterar diário existente
	local cUfFilial := ''
	local aTimeServer := ''
	local dDataDiario := dDatabase //FWTimeStamp() ou DATE()
	local cVO4Fechamento := ''
	local cVO3Fechamento := ''
	local lNovoDiario := .F.

	//recupera estado da filial para buscar data e hora local
	cUfFilial := alltrim(FWSM0Util():GetSM0Data(cEmpAnt, cFilAnt, {"M0_ESTCOB"})[1][2]) 
	if !empty(cUfFilial)
		aTimeServer := FWTimeUF(cUfFilial)
	endif
	if len(aTimeServer) > 0
		dDataDiario := aTimeServer[1]
	endif

	cCodVZW := OA5480122_VerificaExistenciaDiario(cOrigem,cNumero)
	if Empty(cCodVZW)
		cCodVZW := GetSXENum('VZW', 'VZW_CODIGO')
		ConfirmSx8()
		nOpc := 3 // Novo diário
		lNovoDiario := .T.
	endif

	AADD(aCabecalhoDiario, {"VZW_FILIAL", VSO->VSO_FILIAL, NIL})
	AADD(aCabecalhoDiario, {"VZW_CODIGO", cCodVZW, NIL})

	AADD(aCabecalhoDiario, {"VZW_PLAVEI", VV1->VV1_PLAVEI, NIL})
	AADD(aCabecalhoDiario, {"VZW_CHASSI", VV1->VV1_CHASSI, NIL})
	AADD(aCabecalhoDiario, {"VZW_CHAINT", VV1->VV1_CHAINT, NIL})

	Do Case
	Case cOrigem $ "001/002/005"

		If cOrigem $ "001/002"
			AADD(aCabecalhoDiario, {"VZW_ABERTO", .T., NIL})
			AADD(aCabecalhoDiario, {"VZW_DATABE", VSO->VSO_DATREG, NIL})

		Else
			AADD(aCabecalhoDiario, {"VZW_ABERTO", .F., NIL})
			AADD(aCabecalhoDiario, {"VZW_DATFEC", Date(), NIL})
		Endif

		AADD(aCabecalhoDiario, {"VZW_NUMAGE", VSO->VSO_NUMIDE, NIL})

	Case cOrigem $ "009"
		AADD(aCabecalhoDiario, {"VZW_ABERTO", .T., NIL})

		if lNovoDiario
			AADD(aCabecalhoDiario, {"VZW_DATABE", dDataDiario, NIL})
		endif		
		AADD(aCabecalhoDiario, {"VZW_NUMOSV", VO1->VO1_NUMOSV, NIL}) //VO1_NUMOSV
	Case cOrigem $ "010"
		AADD(aCabecalhoDiario, {"VZW_ABERTO", .T., NIL})

		if lNovoDiario
			AADD(aCabecalhoDiario, {"VZW_DATABE", dDataDiario, NIL}) //TODO: VN8
		endif
		AADD(aCabecalhoDiario, {"VZW_NUMORC", VS1->VS1_NUMORC, NIL})
	Case cOrigem $ "011"
		AADD(aCabecalhoDiario, {"VZW_ABERTO", .T., NIL})

		if lNovoDiario
			AADD(aCabecalhoDiario, {"VZW_DATABE", dDataDiario, NIL}) //VSW_DTHLIB
		endif
		AADD(aCabecalhoDiario, {"VZW_NUMORC", VS1->VS1_NUMORC, NIL})
	Case cOrigem $ "012"
		AADD(aCabecalhoDiario, {"VZW_ABERTO", .T., NIL})

		if lNovoDiario
			AADD(aCabecalhoDiario, {"VZW_DATABE", dDataDiario, NIL})
		endif
		AADD(aCabecalhoDiario, {"VZW_NUMORC", VS1->VS1_NUMORC, NIL})
	Case cOrigem $ "013"
		AADD(aCabecalhoDiario, {"VZW_ABERTO", .T., NIL})

		if lNovoDiario
			AADD(aCabecalhoDiario, {"VZW_DATABE", dDataDiario, NIL}) //VS1_DATAPR
		endif
		AADD(aCabecalhoDiario, {"VZW_NUMORC", VS1->VS1_NUMORC, NIL})
	Case cOrigem $ "018"
		cVO3Fechamento := OA548021F_RetornarMaxMin('MAX','VO3','VO3_DATFEC','VO3_NUMOSV',VO1->VO1_NUMOSV,'VO3_FILIAL')
		cVO4Fechamento := OA548021F_RetornarMaxMin('MAX','VO4','VO4_DATFEC','VO4_NUMOSV',VO1->VO1_NUMOSV,'VO4_FILIAL')
		dDataDiario := stod(IIf(cVO4Fechamento > cVO3Fechamento, cVO4Fechamento, cVO3Fechamento))
		AADD(aCabecalhoDiario, {"VZW_ABERTO", .F., NIL})
		AADD(aCabecalhoDiario, {"VZW_DATFAT", dDataDiario, NIL}) 
		AADD(aCabecalhoDiario, {"VZW_DATFEC", dDataDiario, NIL})
	Case cOrigem $ "020"
		AADD(aCabecalhoDiario, {"VZW_ABERTO", .f., NIL})
		AADD(aCabecalhoDiario, {"VZW_DATFEC", dDataDiario, NIL})
	EndCase

Return {nOpc, aCabecalhoDiario, OA5480092_MontaItensDiario(cCodVZW, cOrigem)}

/*/{Protheus.doc} OA5480092_MontaItensDiario
	Funcao para montar os itens do diario da oficina

	@author Bruno Forcato
	@since 04/03/2026
/*/
Static Function OA5480092_MontaItensDiario(cCodVZW, cOrigem)
	local nRegVZY := 0
	local nCont := 1
	Local aItensDiario := {}
	local aItem := {}
	local dDataVZY := dDataBase //Date()
	local nTimeVZY := OA548017F_FormatandoDatasTempos('VZY_TIMREG',time())	
	local aLiberacaoCredito := {}
	local cUfFilial := ''
	local aTimeServer := {}

	if OA5480102_VerificaExistenciaOrigem(cCodVZW, cOrigem)
		if !cOrigem $ '002.021'
			return {}
		endif

		//usado para deletar origem de alteração
		OA5480132_DeletaEvento(cCodVZW, cOrigem)
	endif

	//recupera estado da filial para buscar data e hora local
	cUfFilial := alltrim(FWSM0Util():GetSM0Data(cEmpAnt, cFilAnt, {"M0_ESTCOB"})[1][2]) 
	if !empty(cUfFilial)
		aTimeServer := FWTimeUF(cUfFilial)
	endif
	if len(aTimeServer) > 0
		dDataDiario := aTimeServer[1]
		dDataVZY := aTimeServer[1]
		nTimeVZY := OA548017F_FormatandoDatasTempos('VZY_TIMREG',aTimeServer[2])	
	endif

	AADD(aItem, {"VZY_CODIGO", GetSXENum('VZY', 'VZY_CODIGO'), NIL})
	AADD(aItem, {"VZY_FILIAL", VSO->VSO_FILIAL, NIL})
	AADD(aItem, {"VZY_CODVZW", cCodVZW, NIL})
	AADD(aItem, {"VZY_CODUSU", __cUserId, NIL})
	AADD(aItem, {"VZY_ORIGEM", cOrigem, Nil})
	ConfirmSx8()

	if cOrigem $ "001/002"
		AADD(aItem, {"VZY_DATREG", VSO->VSO_DATAGE, NIL})
		AADD(aItem, {"VZY_TIMREG", Val(VSO->VSO_HORAGE), NIL})
	elseif cOrigem == "005"
		AADD(aItem, {"VZY_DATREG", Date(), NIL})
		AADD(aItem, {"VZY_TIMREG", Val(Substr(Time(),1,2)+Substr(Time(),4,2)), NIL})
	elseif cOrigem == "009"
		AADD(aItem, {"VZY_OBSERV", STR0028, NIL})
		AADD(aItem, {"VZY_DATREG", VO1->VO1_DATABE, NIL})

		nTimeVZY := OA548017F_FormatandoDatasTempos('VZY_TIMREG', VO1->VO1_HORABE)
		AADD(aItem, {"VZY_TIMREG", nTimeVZY, NIL})
	elseif cOrigem == "010"
		aLiberacaoCredito := OA548024F_DataLiberacaoCredito(VS1->VS1_NUMORC,'3')
		AADD(aItem, {"VZY_OBSERV", STR0028, NIL})

		if len(aLiberacaoCredito) > 0
			dDataVZY := aLiberacaoCredito[1][1]
			nTimeVZY := aLiberacaoCredito[1][2]
			nTimeVZY := OA548017F_FormatandoDatasTempos('VZY_TIMREG', nTimeVZY)		
		endif
		
		AADD(aItem, {"VZY_DATREG", dDataVZY, NIL})
		AADD(aItem, {"VZY_TIMREG", nTimeVZY, NIL})				
	elseif cOrigem == "011"
		AADD(aItem, {"VZY_OBSERV", STR0028, NIL})
		
		dDataVZY := OA548017F_FormatandoDatasTempos('VZY_DATREG', VSW->VSW_DTHLIB)
		AADD(aItem, {"VZY_DATREG", dDataVZY, NIL})

		nTimeVZY := OA548017F_FormatandoDatasTempos('VZY_TIMREG', VSW->VSW_DTHLIB)
		AADD(aItem, {"VZY_TIMREG", nTimeVZY, NIL})
	elseif cOrigem == "012"
		AADD(aItem, {"VZY_OBSERV", STR0028, NIL})
		AADD(aItem, {"VZY_DATREG", VS1->VS1_DATORC, NIL})

		nTimeVZY := OA548017F_FormatandoDatasTempos('VZY_TIMREG', VS1->VS1_HORORC)
		AADD(aItem, {"VZY_TIMREG", nTimeVZY, NIL})
	elseif cOrigem == "013"
		AADD(aItem, {"VZY_OBSERV", STR0028, NIL})
		AADD(aItem, {"VZY_DATREG", VS1->VS1_DATAPR, NIL})

		nTimeVZY := OA548017F_FormatandoDatasTempos('VZY_TIMREG', VS1->VS1_HORAPR)
		AADD(aItem, {"VZY_TIMREG", nTimeVZY, NIL})
	ELSEIF cOrigem $ "018"
		AADD(aItem, {"VZY_OBSERV", STR0028, NIL})

		cVO4Fechamento := OA548021F_RetornarMaxMin('MAX','VO4','VO4_DATFEC','VO4_NUMOSV',VO1->VO1_NUMOSV,'VO4_FILIAL')
		cVO3Fechamento := OA548021F_RetornarMaxMin('MAX','VO3','VO3_DATFEC','VO3_NUMOSV',VO1->VO1_NUMOSV,'VO3_FILIAL')
		dDataVZY := stod(IIf(cVO4Fechamento > cVO3Fechamento, cVO4Fechamento, cVO3Fechamento))
		AADD(aItem, {"VZY_DATREG", dDataVZY, NIL})

		cVO4Fechamento := OA548021F_RetornarMaxMin('MAX','VO4','VO4_HORFEC','VO4_NUMOSV',VO1->VO1_NUMOSV,'VO4_FILIAL')
		cVO3Fechamento := OA548021F_RetornarMaxMin('MAX','VO3','VO3_HORFEC','VO3_NUMOSV',VO1->VO1_NUMOSV,'VO3_FILIAL')
		nTimeVZY := IIf(cVO4Fechamento > cVO3Fechamento, cVO4Fechamento, cVO3Fechamento)

		nTimeVZY := OA548017F_FormatandoDatasTempos('VZY_TIMREG', nTimeVZY)
		AADD(aItem, {"VZY_TIMREG", nTimeVZY, NIL})
	ELSEIF cOrigem $ "021"
		dDataVZY := IIF(empty(VO1->VO1_DTENTR),dDataVZY,VO1->VO1_DTENTR)
		nTimeVZY := IIF(empty(VO1->VO1_HRENTR),nTimeVZY,VO1->VO1_HRENTR)
		nTimeVZY := OA548017F_FormatandoDatasTempos('VZY_TIMREG',nTimeVZY)

		AADD(aItem, {"VZY_OBSERV", STR0028, NIL})
		AADD(aItem, {"VZY_DATREG",dDataVZY, NIL})
		AADD(aItem, {"VZY_TIMREG",nTimeVZY, NIL})		
	ELSEIF cOrigem $ "020"	
		AADD(aItem, {"VZY_OBSERV", STR0028, NIL})
		AADD(aItem, {"VZY_DATREG",dDataVZY, NIL})
		AADD(aItem, {"VZY_TIMREG",nTimeVZY, NIL})		
	endif

	AADD(aItensDiario, aItem)
	nRegVZY := OA5480112_QuantidadeItensVZY(cCodVZW)

	If nRegVZY > 0
		nOldLen := Len(aItensDiario)
		ASIZE(aItensDiario, nOldLen + nRegVZY)
//
		For nCont := nOldLen To 1 Step -1
			aItensDiario[nCont + nRegVZY] := aItensDiario[nCont]
		Next nCont
//
		For nCont := 1 To nRegVZY
			aItensDiario[nCont] := {}
		Next nCont
	EndIf
return aItensDiario

/*/{Protheus.doc} OA5480102_VerificaExistenciaOrigem
	Funcao para verificar se já existe origem do diario

	@author Bruno Forcato
	@since 02/03/2026
/*/
Static Function OA5480102_VerificaExistenciaOrigem(cCodVZW , cOrigem)
	cSQL := ;
		"SELECT COUNT(VZY.R_E_C_N_O_) " +;
		" FROM " + RetSQLName("VZY") + " VZY " +;
		"WHERE VZY_FILIAL = '" + xFilial("VZY") + "'" +;
		" AND VZY_CODVZW = '" + cCodVZW + "' " +;
		" AND VZY_ORIGEM = '" + cOrigem + "' " +;
		" AND D_E_L_E_T_ = ' '"
Return FM_SQL(cSQL) > 0

/*/{Protheus.doc} OA5480112_QuantidadeItensVZY
	Funcao para verificar quantidades de registro

	@author Bruno Forcato
	@since 02/03/2026
/*/
Static Function OA5480112_QuantidadeItensVZY(cCodVZW )
	cSQL := "SELECT COUNT(VZY.R_E_C_N_O_) " +;
		" FROM " + RetSQLName("VZY") + " VZY " +;
		"WHERE VZY_FILIAL = '" + xFilial("VZY") + "'" +;
		" AND VZY_CODVZW = '" + cCodVZW + "' " +;
		" AND D_E_L_E_T_ = ' '"
Return FM_SQL(cSQL)

/*/{Protheus.doc} OA5480122_VerificaExistenciaDiario
	Funcao para verificar se existe Diario ja cadastrado;
	E Posicionar as tabelas envolvidas no processo.

	@author Bruno Forcato
	@since 04/03/2026
/*/
Function OA5480122_VerificaExistenciaDiario(cOrigem, cNumero)
	Local cSQL     := ""
	Local aRet     := {}
	Local cAux     := ""
	Local cRetorno := ""
	Local cAncora  := ""
	Local nI       := 0
	Local aFiltros := {}

	Do Case
	Case cOrigem $ "001/002/005"
		OA548019F_VerificaExistenciaChave('VV1', VSO->VSO_GETKEY, 2)
		aRet := OA548020F_MapeamentoDiario(cNumero, 'VSO')
		If Len(aRet) > 0
			cAncora  := " AND VZW_NUMAGE = '" + aRet[1] + "'"
			aFiltros := { {"VZW_NUMOSV", aRet[2]}, {"VZW_NUMORC", aRet[3]} }
		EndIf

	Case cOrigem $ "009/018/020/021"
		OA548019F_VerificaExistenciaChave('VV1', VO1->VO1_CHAINT, 1)
		aRet := OA548020F_MapeamentoDiario(cNumero, 'VO1')
		If Len(aRet) > 0
			cAncora  := " AND VZW_NUMOSV = '" + aRet[2] + "'"
			aFiltros := { {"VZW_NUMAGE", aRet[1]}, {"VZW_NUMORC", aRet[3]} }
		EndIf

	Case cOrigem $ "010/011/012/013"
		OA548019F_VerificaExistenciaChave('VV1', VS1->VS1_CHAINT, 1)
		aRet := OA548020F_MapeamentoDiario(cNumero, 'VS1')
		If Len(aRet) > 0
			cAncora  := " AND VZW_NUMORC = '" + aRet[3] + "'"
			aFiltros := { {"VZW_NUMAGE", aRet[1]}, {"VZW_NUMOSV", aRet[2]} }
		EndIf
	EndCase

	cSQL := " SELECT VZW_CODIGO "                          +;
			" FROM " + RetSQLName("VZW")                   +;
			" WHERE VZW_FILIAL = '" + xFilial("VZW") + "'" +;
			"   AND D_E_L_E_T_ = ' '"

	cRetorno := FM_SQL(cSQL + cAncora)
	If Empty(cRetorno)
		cAncora := ''
	endif
	For nI := 1 To Len(aFiltros)
		If !Empty(aFiltros[nI][2])
			cAux := FM_SQL(cSQL + cAncora + " AND " + aFiltros[nI][1] + " = '" + aFiltros[nI][2] + "'")
			If !Empty(cAux)
				cRetorno := cAux
				cAncora  += " AND " + aFiltros[nI][1] + " = '" + aFiltros[nI][2] + "'"
			EndIf
		EndIf
	Next nI
Return cRetorno

/*/{Protheus.doc} OA5480132_DeletaEvento
	Funcao para deletar item do diario partindo da origem 

	@author Bruno Forcato
	@since 04/03/2026
/*/
static Function OA5480132_DeletaEvento(cCodVZW, cOrigem)
	Local cQuery     := ""
	Local cFixQuery  := ""
	Local oStatement := FWPreparedStatement():New()
	Local cAliasQry  := GetNextAlias()
	Local aArea      := GetArea()
	Local lOk        := .F.

	cQuery := " SELECT VZY.R_E_C_N_O_ "
	cQuery += "   FROM " + RetSqlName("VZY") + " VZY "
	cQuery += "  WHERE VZY_FILIAL = ? "
	cQuery += "    AND VZY_CODVZW = ? "
	cQuery += "    AND VZY_ORIGEM = ? "
	cQuery += "    AND D_E_L_E_T_ = ' ' "

	oStatement:SetQuery(cQuery)
	oStatement:SetString(1, FWxFilial("VZY"))
	oStatement:SetString(2, cCodVZW)
	oStatement:SetString(3, cOrigem)

	cFixQuery := oStatement:GetFixQuery()
	DbUseArea(.T., "TOPCONN", TcGenQry(,, cFixQuery), cAliasQry, .F., .T.)
	DbSelectArea("VZY")
	DbSetOrder(1)

	While !(cAliasQry)->(Eof())
		VZY->(DbGoto((cAliasQry)->R_E_C_N_O_))

		If !VZY->(Eof())
			If VZY->(RecLock("VZY", .F.))
				VZY->(DbDelete())
				VZY->(MsUnLock())
				lOk := .T.
			EndIf
		EndIf

		(cAliasQry)->(DbSkip())
	EndDo

	(cAliasQry)->(DbCloseArea())
	RestArea(aArea)
Return lOk

/*/{Protheus.doc} OA5480142_VerificaExistenciaOrigem
	Funcao para verificar se já existe origem do diario
	com base no agendamento

	@author Bruno Forcato
	@since 02/03/2026
/*/
Function OA5480142_VerificaExistenciaOrigem(cNumAge, cOrigem, cNumOsv, cNumOrc)
	Local cSQL := ""

	default cNumAge := ''
	default cOrigem := ''
	default cNumOsv := ''
	default cNumOrc := ''

	cSQL := ""
	cSQL += "SELECT COUNT(VZY.R_E_C_N_O_) "
	cSQL += " FROM " + RetSQLName("VZY") + " VZY "
	cSQL += " JOIN " + RetSQLName("VZW") + " VZW ON "
	cSQL += "       VZW.VZW_CODIGO = VZY.VZY_CODVZW "
	cSQL += "   AND VZW.VZW_FILIAL = VZY.VZY_FILIAL "
	cSQL += "   AND VZW.D_E_L_E_T_ = ' ' "
	cSQL += " WHERE VZY.VZY_FILIAL = '" + xFilial("VZY") + "' "
	if !empty(cNumAge)
		cSQL += "   AND VZW.VZW_NUMAGE = '" + cNumAge + "' "
	endif
	if !empty(cNumOsv)
		cSQL += "   AND VZW.VZW_NUMOSV = '" + cNumOsv + "' "
	endif
	if !empty(cNumOrc)		
		cSQL += "   AND VZW.VZW_NUMORC = '" + cNumOrc + "' "
	endif
	if !empty(cOrigem)
		cSQL += "   AND VZY.VZY_ORIGEM = '" + cOrigem + "' "
	endif
	cSQL += "   AND VZY.D_E_L_E_T_ = ' ' "
Return FM_SQL(cSQL) > 0

/*/{Protheus.doc} OA548005K_DataUltimoFechamento
	(long_description)
	@type  Static Function
	@author user
	@since 20/04/2026
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function OA548005K_DataUltimoFechamento(param_name)

Return cDateUltimoFechamento

/*/{Protheus.doc} OA548016K_PreparaDiarioParaOrigem
	(long_description)
	@type  Static Function
	@author user
	@since 20/04/2026
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function OA548016K_PreparaDiarioParaOrigem(cOrigem, cNumero)

    Local lRet := .T.
	Local cNumOrc := ""

    Do Case
        Case cOrigem == "002"
            lRet := OA5480152_IncluiEventoDiarioOficina(cNumero, "001")

        Case cOrigem == "005"
            lRet := OA5480152_IncluiEventoDiarioOficina(cNumero, "001")

        Case cOrigem == "009"
            If !Empty(VO1->VO1_NUMAGE)
                lRet := OA5480152_IncluiEventoDiarioOficina(VO1->VO1_NUMAGE, "001")
            EndIf

			cNumOrc := OA548025K_RetornaNroPrimeiroOrcamento(cNumero)
			If !Empty(cNumOrc)

				If OA548018F_HouveCredito(cNumOrc)
					lRet := OA5480152_IncluiEventoDiarioOficina(cNumOrc, "011")
				Endif

				OA5480152_IncluiEventoDiarioOficina(cNumOrc, "013")
			Endif

        Case cOrigem == "010"
            lRet := OA5480152_IncluiEventoDiarioOficina(cNumero, "012")

        Case cOrigem == "011"
            lRet := OA5480152_IncluiEventoDiarioOficina(cNumero, "010")

        Case cOrigem == "012"
			lRet := OA548023F_PrimeiraExportacao()
			
        Case cOrigem == "013"
            lRet := OA5480152_IncluiEventoDiarioOficina(cNumero, "012")

        Case cOrigem $ "018.020.021"
			lRet := OA5480152_IncluiEventoDiarioOficina(cNumero, "009")

    EndCase

Return lRet


/*/{Protheus.doc} OA548017F_FormatandoDatasTempos
	Formata valor buscado conforme o tipo do campo destino.
	Se cSetCampo for tipo Data extrai a data, se for Numerico extrai o time (HHMM).
	Motivo: Os valores extraidos nos diversos campos de busca nao possuem o mesmo tipo para data ou hora: 'C', 'N' ou 'D'.
	@type  Static Function
	@author Emanuel Bezerra
	@since 24/04/2026
	@version 1.0
	@param cSetCampo, Character, Campo destino (ex: "VZY_DATREG", "VZY_TIMREG")
	@param xValor,    Character, Valor bruto do campo origem
	@return xRet, Variado, Data ou Numerico conforme tipo do campo destino
/*/
Static Function OA548017F_FormatandoDatasTempos(cSetCampo, xValor)
	Local aArea := GetArea()

    Local aTamCampo := TamSX3(cSetCampo)
	Local cTipo  := ''
    Local xRet   := xValor
    Local cStr   := AllTrim(cValToChar(xValor))
    Local cData  := ""
    Local cTime  := ""
    Local cDia   := ""
    Local cMes   := ""
    Local cAno   := ""
	Local aFormatos := {}
	Local aFmt      := {}
	Local nI        := 0
	Local lOk       := .F.
	default cSetCampo := ''
	default xValor := ''

	if !empty(cSetCampo) .and. !empty(xValor)
		if len(aTamCampo) > 0
			cTipo := aTamCampo[3] //[1] - tamanho, [2] - casas decimais, [3] - 
		endif

		If cTipo == "D"
			// Isola a parte da data (antes do hífen se existir)
			If "-" $ cStr
				cData := AllTrim(Left(cStr, At("-", cStr) - 1))
			Else
				cData := cStr
			Endif

			xRet := CtoD("")

			// { nTamanho, nSep1Pos, nSep2Pos, nDiaIni, nMesIni, nAnoIni, nAnoTam }
			AAdd(aFormatos, { 10, 3, 6, 1, 4, 7, 4 })  // DD/MM/AAAA
			AAdd(aFormatos, {  8, 3, 6, 1, 4, 7, 2 })  // DD/MM/AA
			AAdd(aFormatos, {  8, 0, 0, 7, 5, 1, 4 })  // AAAAMMDD

			For nI := 1 To Len(aFormatos)
				aFmt := aFormatos[nI]

				lOk := Len(cData) == aFmt[1]

				If lOk .And. aFmt[2] > 0
					lOk := SubStr(cData, aFmt[2], 1) == "/" .And. SubStr(cData, aFmt[3], 1) == "/"
				EndIf

				If lOk
					cDia := SubStr(cData, aFmt[4], 2)
					cMes := SubStr(cData, aFmt[5], 2)
					cAno := SubStr(cData, aFmt[6], aFmt[7]) //AAAA
					cAno := IIF(aFmt[7] == 4, cAno, IIF(Val(cAno) <= Val(SubStr(DtoS(Date()),3,2)) + 10, "20"+cAno, "19"+cAno)) //Se o ano já tiver 4 dígitos mantém, se tiver 2 dígitos aplica a regra de prefixo
					
					xRet := CtoD(cDia+"/"+cMes+"/"+cAno)
					Exit
				EndIf
			Next nI

		ElseIf cTipo == "N"
			// Isola a parte do time (depois do hífen se existir)
			If "-" $ cStr
				cTime := AllTrim(SubStr(cStr, At("-", cStr) + 1))
			Else
				cTime := cStr
			Endif

			xRet := 0

			// HH:MM
			If Len(cTime) >= 5 .And. SubStr(cTime,3,1) == ":"
				xRet := Val(SubStr(cTime,1,2) + SubStr(cTime,4,2))

			// HHMM
			ElseIf Len(cTime) <= 4 
				xRet := Val(cTime)
			Endif
		Endif
	endif
	RestArea(aArea)

Return xRet

/*/{Protheus.doc} OA548018F_HouveCredito(VS1->VS1_NUMORC)
	Verifica se existe crédito no orçamento para definir a origem do evento no diário da oficina
	Retorna .T. se existir crédito e .F. caso contrário.
	@type  Function
	@author Emanuel Bezerra
	@since 06/05/2026
	/*/
Function OA548018F_HouveCredito(cNumOrc)
	local lRet := .f.
	local lAchouVS1 := .F.
	default cNumOrc := VS1->VS1_NUMORC

	lAchouVS1 := OA548019F_VerificaExistenciaChave('VS1', cNumOrc,1)

	if lAchouVS1 //.and. VS1->VS1_STATUS == 'F'
		lRet := OA548019F_VerificaExistenciaChave('VSW', cNumOrc,3) //VSW->(DbSeek(xFilial("VSW") + VS1->VS1_NUMORC))
	endif
Return lRet

/*/{Protheus.doc} OA548019F_VerificaExistenciaChave
	verifica a existencia da informação
	@type  Static Function
	@author Emanuel Bezerra
	@since 08/05/2026
/*/
Static Function OA548019F_VerificaExistenciaChave(cTab,cChave,nOrdem)
Local lRet := .f.

default cTab := ""
default cChave := ""
default nOrdem := 0

if !empty(cTab) .and. !empty(cChave) .and. nOrdem > 0
	dbSelectArea(cTab)
	(cTab)->(DBSetOrder(nOrdem))
	lRet := (cTab)->(DbSeek(xFilial(cTab) + cChave))
endif

Return lRet

/*/{Protheus.doc} OA548020F_MapeamentoDiario(cChave, cAlias)
	Verifica se existem todas as amarrações entre O.S, Orçamento e Agendamento, além de posicionar as tabelas envolvidas.
	Retorna os valores encontrados no relacionamento
	@type  Function
	@author Emanuel Bezerra
	@since 08/05/2026
	/*/
Function OA548020F_MapeamentoDiario(cChave, cAlias)
Local aArea := GetArea()

Local cNumAge     := ''
Local cNumOsv     := ''
Local cNumOrc     := ''
local aFiltros := {} //{{campo1,valor1},{campo2,valor2}}
local aColunas := {"VO1_NUMAGE","VO1_NUMOSV","VO1_NUMORC"}
local cAliasPonte := 'VO1' 
local cQuery := ""
local nI := 0
Local cFixQuery  := ""
Local oStatement := FWPreparedStatement():New()
Local cAliasQry  := nil

default cChave := ''
default cAlias := ''

If OA548019F_VerificaExistenciaChave(cAlias, cChave, 1)
	Do Case
	Case cAlias == 'VSO'
		cNumAge := AllTrim(VSO->VSO_NUMIDE)
		cNumOsv := AllTrim(VSO->VSO_NUMOSV) //SV - sempre vazio
		cNumOrc := AllTrim(VSO->VSO_NUMORC) //SV - sempre vazio		
		cAliasPonte := 'VO1' 
		aadd(aFiltros,{'VO1_FILIAL',FWxFilial("VO1")})	
		aadd(aFiltros,{'VO1_NUMAGE',cNumAge})	
	Case cAlias == 'VO1'
		cNumOsv := AllTrim(VO1->VO1_NUMOSV)
		cNumAge := AllTrim(VO1->VO1_NUMAGE)
		cNumOrc := OA548025K_RetornaNroPrimeiroOrcamento(VO1->VO1_NUMOSV)
	Case cAlias == 'VS1'
		cNumOrc := AllTrim(VS1->VS1_NUMORC)
		cNumAge := AllTrim(VS1->VS1_NUMAGE) //SV - sempre vazio
		cNumOsv := AllTrim(VS1->VS1_NUMOSV)	
		cAliasPonte := 'VO1'
		if !empty(cNumOsv)
			aadd(aFiltros,{'VO1_FILIAL',FWxFilial("VO1")})	
			aadd(aFiltros,{'VO1_NUMOSV',cNumOsv})
		endif		
	EndCase

	If len(aFiltros) > 0
		cQuery := " SELECT "
		For nI := 1 To Len(aColunas)
			cQuery += aColunas[nI]
			If nI < Len(aColunas)
				cQuery += ", "
			EndIf
		Next nI
		cQuery += " FROM " + RetSQLName(cAliasPonte)
		cQuery += " WHERE D_E_L_E_T_ = ' '"			
		For nI := 1 To Len(aFiltros)
			If Len(aFiltros[nI]) >= 2
				cValor := AllTrim(cValToChar(aFiltros[nI][2]))
				If !Empty(aFiltros[nI][1]) .And. !Empty(cValor)
					cQuery += " AND " + aFiltros[nI][1] + " = ? "
				EndIf
			EndIf
		Next nI
		oStatement:SetQuery(cQuery)
		For nI := 1 To Len(aFiltros)
			If Len(aFiltros[nI]) >= 2
				cValor := AllTrim(cValToChar(aFiltros[nI][2]))
				If !Empty(aFiltros[nI][1]) .And. !Empty(cValor)
					oStatement:SetString(nI, aFiltros[nI][2])
				EndIf
			EndIf
		Next nI
		cFixQuery := oStatement:GetFixQuery()
		cAliasQry := MPSysOpenQuery(cFixQuery) //dbusearea descontinuado
		(cAliasQry)->(dbGotop())
		While !(cAliasQry)->(Eof())
			If Empty(cNumAge)
				cNumAge := (cAliasQry)->&(aColunas[1]) //VO1_NUMAGE
			EndIf
			if Empty(cNumOsv)
				cNumOsv := (cAliasQry)->&(aColunas[2]) //VO1_NUMOSV
			endif
			(cAliasQry)->(dbSkip())
		enddo
		(cAliasQry)->(dbCloseArea())
	endif
EndIf
RestArea(aArea)

Return {cNumAge, cNumOsv, cNumOrc}

/*/{Protheus.doc} OA548021F_RetornarMaxMin
	Funcao para retornar o maior ou menor valor entre campos da VO3 / VO4
	@author Emanuel Bezerra
	@since 15/05/2026
	*/
static function OA548021F_RetornarMaxMin(cFuncao,cAlias,cCampo,cCampoFiltro,cNUMOSV,cFiltroFilial)
local sql := ""

default cFuncao := ''
default cAlias := ''
default cCampo := ''
default cNUMOSV := ''
default cCampoFiltro := ''
default cFiltroFilial := ''

if !empty(cAlias) .and. !empty(cCampo) .and. !empty(cNUMOSV) .and. !empty(cFuncao) .and. !empty(cCampoFiltro) .and. !empty(cFiltroFilial)
	sql := "SELECT "+cFuncao+"(" + cCampo + ") FROM " + RetSQLName(cAlias) + " WHERE " + cCampoFiltro + " = '" + cNUMOSV + "' AND " + cFiltroFilial + " = '" + FWxFilial(cAlias) + "' AND D_E_L_E_T_ = ' '"
endif

return AllTrim(cValToChar(FM_SQL(sql)))

/*/{Protheus.doc} OA548023F_PrimeiraExportacao
	Função que irá retornar a primeira exportação vinculada. Atualmente apenas o evento da primeira exportação para OS é gravado no diario.
	@type  Static Function
	@author Emanuel Bezerra
	@since 27/01/2026
	*/
static function OA548023F_PrimeiraExportacao()
Local aArea := GetArea()
local cNUMORC := VS1->VS1_NUMORC
Local cNUMOSV := VS1->VS1_NUMOSV
Local cTrocaOrc := ""
local lPrimeiraExportacao := .t.
local lRet := .t.
local lAlteraDiario := .f. 
local cCodVZW := ''
local lCodVZY := .f.
local lOrcErrado := .f.

if !empty(cNumOSV) .and. !empty(cNUMORC)

	cTrocaOrc := OA548025K_RetornaNroPrimeiroOrcamento(cNUMOSV)
	
	if !empty(cTrocaOrc)
		lPrimeiraExportacao := (cTrocaOrc == cNUMORC)
	endif
endif

cCodVZW := OA5480122_VerificaExistenciaDiario('012',cNUMORC)
cCodVZW := iif(!empty(cCodVZW),cCodVZW,OA5480122_VerificaExistenciaDiario('009',cNUMOSV))
if !empty(cCodVZW)
	OA548019F_VerificaExistenciaChave("VZW", cCodVZW, 1)
	lCodVZY := OA5480102_VerificaExistenciaOrigem(cCodVZW, '012')

	if lCodVZY
		lOrcErrado := (VZW->VZW_NUMORC != cNUMORC)
	endif
endif

if lPrimeiraExportacao .and. !empty(cTrocaOrc) .and. lOrcErrado
	lAlteraDiario := .T. 
endif

if lAlteraDiario 
	lRET010 := OA5480132_DeletaEvento(cCodVZW, '010')
	lRET011 := OA5480132_DeletaEvento(cCodVZW, '011')
	lRET012 := OA5480132_DeletaEvento(cCodVZW, '012')
	lRET013 := OA5480132_DeletaEvento(cCodVZW, '013')

	lRet := .t. //lRET010 .and. lRET011 .and. lRET012 .and. lRET013
else
	lRet :=  (lCodVZY .or. !lOrcErrado)
endif
RestArea(aArea)

Return lRet

/*/{Protheus.doc} OA548024F_DataLiberacaoCredito
	função para buscar a data de liberação de crédito do orçamento, caso exista, para ser utilizada na definição da data do evento no diário da oficina.
	@type  Static Function
	@author Emanuel Bezerra
	@since 31/01/2026
	*/
static function OA548024F_DataLiberacaoCredito(cNUMORC,cStatus)
Local aArea := GetArea()
local cQuery := ""
Local cFixQuery  := ""
Local oStatement := FWPreparedStatement():New()
Local cAliasQry  := ''
local aDataLibCredito := {}
local aAux := {}
default cNUMORC := ''
default cStatus := ''

if !empty(cNUMORC)
	cQuery := "SELECT * FROM " + RetSqlName("VN8") 
	cQuery += " WHERE D_E_L_E_T_ = ? AND VN8_FILIAL = ? AND VN8_NUMORC = ? " 
	if !empty(cStatus)
		cQuery += " AND VN8_STATUS = ? "
	endif

	oStatement:SetQuery(cQuery)
	oStatement:SetString(1,' ')
	oStatement:SetString(2,FWxFilial("VN8"))
	oStatement:SetString(3,cNUMORC)
	if !empty(cStatus)
		oStatement:SetString(4,cStatus)
	endif

	cFixQuery := oStatement:GetFixQuery()
	cAliasQry := MPSysOpenQuery(cFixQuery) //dbusearea descontinuado
	(cAliasQry)->(dbGotop())
	while !(cAliasQry)->(Eof())
		aAux := {}
		aadd(aAux, stod((cAliasQry)->VN8_DATSTA))
		aadd(aAux, (cAliasQry)->VN8_HORSTA)
		aadd(aDataLibCredito, aAux)
		(cAliasQry)->(dbSkip())
	enddo
	(cAliasQry)->(dbCloseArea())
	
endif
RestArea(aArea)

Return aDataLibCredito

/*/{Protheus.doc} OA548025K_RetornaNroPrimeiroOrcamento
	Função para retornar o nro do primeiro orçamento 
	exportado para a OS
	@type  Static Function
	@author Lucas Oliveira
	@since 01/06/2026
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Function OA548025K_RetornaNroPrimeiroOrcamento(cNUMOSV)

	Local cPrimeiroOrc  := ""
	Local cQuery		:= ""
	Local cAliasQry		:= ""
	Local oStatement := FWPreparedStatement():New()

	cQuery := "SELECT MIN(VS1_DEXPOS) VS1_DEXPOS, MIN(VS1_HEXPOS) VS1_HEXPOS, VS1_NUMORC FROM " + RetSqlName("VS1") + ;
		" WHERE D_E_L_E_T_ = ' ' AND VS1_FILIAL = ? AND VS1_NUMOSV = ? AND VS1_DEXPOS <> ? " + ;
		" GROUP BY VS1_NUMORC ORDER BY MIN(VS1_DEXPOS), MIN(VS1_HEXPOS)"

	oStatement:SetQuery(cQuery)
	oStatement:SetString(1, FWxFilial("VS1"))
	oStatement:SetString(2, cNUMOSV)
	oStatement:SetString(3, ' ')
	
	cQuery := oStatement:GetFixQuery()
	cAliasQry := MPSysOpenQuery(cQuery)
	(cAliasQry)->(dbGotop())
	if !(cAliasQry)->(EOF())
		cPrimeiroOrc := (cAliasQry)->VS1_NUMORC
	endif
	(cAliasQry)->(dbCloseArea())

Return cPrimeiroOrc