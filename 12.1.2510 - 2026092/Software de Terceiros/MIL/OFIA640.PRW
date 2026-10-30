#Include 'FwMVCDef.ch'
#Include 'TOPCONN.CH'
#Include "Protheus.ch"
#INCLUDE "OFIA640.CH"

Static cTabVWD := "VWD"
Static cTabVWE := "VWE"

/*/{Protheus.doc} OFIA640
Rotina para geração de Remessa (Remito) em Funções de Oficina de acordo com a OS aberta.
@author Leandro Rodirgues
@since 15/07/2026
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Function OFIA640()
	
	Local aSize := FWGetDialogSize( oMainWnd )
	
	Private cCadastro := STR0001 // "Remessa de Maquina/Peças"
	Private aRotina	
	
	If cPaisLoc == "ARG" .AND. FWAliasInDic("VWD") .AND. FWAliasInDic("VWE")
		SetKey(VK_F12,{ || Pergunte("OA640",.T.,,,,.f.)})

		Pergunte("OA640",.f.)
	
		oDlgOA640 := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cCadastro, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )

		oWorkArea := FWUIWorkArea():New( oDlgOA640 )
		oWorkArea:CreateHorizontalBox( "LINE01", 60 )
		oWorkArea:SetBoxCols( "LINE01", { "OBJ1" } )
		oWorkArea:CreateHorizontalBox( "LINE02", 39 ) // -1 para nao estourar 100% da tela ( criando scroll lateral )
		oWorkArea:SetBoxCols( "LINE02", { "OBJ2" } )
		oWorkArea:Activate()

		oBrwVO1 := FwMBrowse():New()
		oBrwVO1:SetOwner(oWorkarea:GetPanel("OBJ1"))
		oBrwVO1:SetDescription(STR0002) // "Ordem de Serviço"
		oBrwVO1:SetAlias("VO1")		
		oBrwVO1:SetChgAll(.T.) //nao apresentar a tela para informar a filial
		oBrwVO1:SetMenuDef(' ')
		oBrwVO1:AddStatusColumns({|| OA6400057_coluna_status_os() }, {|| OA6400047_legenda_os() })
		oBrwVO1:AddButton(STR0023, {|| OA6400107_consulta_os()}) // "Consultar OS"
		oBrwVO1:lOptionReport := .f.
		if FunName() == "OFIXA120" 
			oBrwVO1:SetFilterDefault("VO1_FILIAL = '"+VO1->VO1_FILIAL+"' .AND. VO1_NUMOSV = '"+VO1->VO1_NUMOSV+"'")
		EndIf
		oBrwVO1:DisableLocate()
		oBrwVO1:ForceQuitButton()
		oBrwVO1:DisableDetails()		
		oBrwVO1:Activate()

		oBrwVWD := FwMBrowse():New()
		oBrwVWD:SetOwner(oWorkarea:GetPanel("OBJ2"))
		oBrwVWD:SetDescription(STR0003) // "Remessas"	
		oBrwVWD:SetAlias("VWD")		
		oBrwVWD:AddStatusColumns({|| OA6400017_coluna_status_remessa() }, {|| OA6400027_legenda_remessa() })
		oBrwVWD:SetMenuDef('OFIA640')
		oBrwVWD:DisableLocate()
		oBrwVWD:DisableDetails()
		oBrwVWD:SetAmbiente(.F.)
		oBrwVWD:SetWalkthru(.F.)
		oBrwVWD:SetUseFilter()
		oBrwVWD:lOptionReport := .f.
		oBrwVWD:Activate()

		oRelacOS:= FWBrwRelation():New()
		oRelacOS:AddRelation( oBrwVO1 , oBrwVWD , { { "VWD_FILOSV", "VO1_FILIAL" } , { "VWD_NUMOSV", "VO1_NUMOSV" } } )
		oRelacOS:Activate()

		VWD->(DbGoTop())

		oDlgOA640:Activate( , , , , , , ) //ativa a janela

		SetKey(VK_F12,Nil)
	Else
		FMX_HELP("OFIA640", STR0024) // "Rotina disponivel apenas para Argentina e dicionario de dados (tabelas) para o funcionmento correto da rotina inexistente."
	EndIf

Return NIL

Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.OFIA640' OPERATION 2 ACCESS 0 // "Visualizar"
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.OFIA640' OPERATION 3 ACCESS 0 // "Incluir"	
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.OFIA640' OPERATION 4 ACCESS 0 // "Alterar"
	ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.OFIA640' OPERATION 5 ACCESS 0 // "Excluir"
	ADD OPTION aRotina TITLE STR0008 ACTION 'OA6400117_gerar_documento(oBrwVWD)' OPERATION 4 ACCESS 0 // "Gerar Documento"
	ADD OPTION aRotina TITLE STR0009 ACTION 'OA6400137_cancelar_documento(oBrwVWD)' OPERATION 4 ACCESS 0 // "Cancelar Documento"
	
Return aRotina

/*/{Protheus.doc} ModelDef
@author Leandro Rodrigues
@since 15/07/2026
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function ModelDef()
	Local oStruVWD := FWFormStruct(1, cTabVWD)
	Local oStruVWE := FWFormStruct(1, cTabVWE)
	Local aRelation := {}
	Local oModel

	oStruVWD:SetProperty("VWD_CLIFAT", MODEL_FIELD_OBRIGAT, .t.)
	oStruVWD:SetProperty("VWD_LOJFAT", MODEL_FIELD_OBRIGAT, .t.)
		
	oStruVWE:SetProperty("VWE_QTDITE", MODEL_FIELD_OBRIGAT, .t.)
	oStruVWE:SetProperty("VWE_VALPEC", MODEL_FIELD_OBRIGAT, .t.)
	oStruVWE:SetProperty("VWE_CODTES", MODEL_FIELD_OBRIGAT, .t.)

	oStruVWE:AddTrigger("VWE_CODSB1", "VWE_GRUITE", { || .T. }, { | x | OA6400067_gatilho_produto( x ) } )
	oStruVWE:AddTrigger("VWE_QTDITE", "VWE_VALTOT", { || .T. }, { | x | OA6400077_gatilho_qtde_vlr( x ) } )
	oStruVWE:AddTrigger("VWE_VALPEC", "VWE_VALTOT", { || .T. }, { | x | OA6400077_gatilho_qtde_vlr( x ) } )
		
	oModel := MPFormModel():New("OFIA640M", /*bPre*/, /*bPos*/, /*bCommit*/, /*bCancel*/)
	oModel:AddFields("VWDMASTER", /*cOwner*/, oStruVWD)
	oModel:AddGrid("VWEDETAIL","VWDMASTER",oStruVWE,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad*/)
	oModel:SetDescription(STR0020) // "Remessa de Maquina/Peças" 
	oModel:GetModel("VWDMASTER"):SetDescription(STR0021) // "Dados Remessa" 
	oModel:GetModel("VWEDETAIL"):SetDescription(STR0022) // "Itens Remessa" 
	oModel:GetModel('VWEDETAIL'):SetUniqueLine({"VWE_CODSB1"}) 
	oModel:SetPrimaryKey({})

	oModel:AddCalc('CALCTOT_REM', 'VWDMASTER', 'VWEDETAIL', 'VWE_VALTOT' , 'TOTREM' , 'SUM',,,STR0025) // "Total Remessa"

	aAdd(aRelation, {"VWE_FILIAL", "FWxFilial('VWE')"} )
	aAdd(aRelation, {"VWE_FILIAL", "VWD_FILIAL"})
	aAdd(aRelation, {"VWE_CODVWD", "VWD_CODIGO"})
	
	oModel:SetRelation("VWEDETAIL", aRelation, VWE->(IndexKey(1)))

	oModel:InstallEvent("OFIA640EVDEF", /*cOwner*/, OFIA640EVDEF():New())

Return oModel

/*/{Protheus.doc} ViewDef
@author Leandro Rodrigues
@since 15/07/2026
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function ViewDef()
	Local oModel     := FWLoadModel("OFIA640")
	Local oStruVWD   := FWFormStruct(2, cTabVWD)
	Local oStruVWE   := FWFormStruct(2, cTabVWE)
	Local oCalcTOT   := FWCalcStruct(oModel:GetModel("CALCTOT_REM") )
	Local oView

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_VWD", oStruVWD, "VWDMASTER")
	oView:AddGrid("VIEW_VWE",  oStruVWE,  "VWEDETAIL")

	oView:CreateHorizontalBox("CABEC", 30)
	oView:CreateHorizontalBox("GRID", 60)
	oView:SetOwnerView("VIEW_VWD", "CABEC")
	oView:SetOwnerView("VIEW_VWE", "GRID")

	oView:EnableTitleView("VIEW_VWD", STR0021) // "Dados Remessa" 
	oView:EnableTitleView("VIEW_VWE", STR0022) // "Itens Remessa" 

	oStruVWD:RemoveField("VWD_CODIGO")
	oStruVWD:RemoveField("VWD_STATUS")

	oStruVWE:RemoveField("VWE_CODVWD")
	oStruVWE:RemoveField("VWE_CODIGO")

	oView:AddIncrementField("VIEW_VWE", "VWE_SEQUEN")

	oView:CreateHorizontalBox( 'BOXTOT', 10)
	oView:AddField("VIEW_TOT",oCalcTOT, 'CALCTOT_REM')
	oView:SetOwnerView('VIEW_TOT','BOXTOT')

	oView:SetAfterViewActivate({|| OA6400087_add_veiculo_grid()})

	oView:SetCloseOnOk({||.T.})
	
	oView:SetViewAction("ASKONCANCELSHOW", {|| .F.}) 	
	oView:SetModified(.t.)

	oView:showUpdateMsg(.f.)
	oView:showInsertMsg(.f.)

	oView:AddUserButton(STR0026,"",{|| OA6400087_add_veiculo_grid(.T.)}) // "Add Maquina Remessa"
    
Return oView

/*/{Protheus.doc} OA6400017_coluna_status_remessa
@author Leandro Rodrigues
@since 15/07/2026
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function OA6400017_coluna_status_remessa()
	
	Local cImgRPO := "BR_BRANCO" // Aberto
	
	Do Case
		Case VWD->VWD_STATUS == "2" //Gerado Documento
			cImgRpo := "BR_VERDE"
		Case VWD->VWD_STATUS == "3" //Cancelado
			cImgRpo := "BR_VERMELHO"		
	EndCase

Return cImgRPO

/*/{Protheus.doc} OA6400027_legenda_remessa
@author Leandro Rodrigues
@since 15/07/2026
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function OA6400027_legenda_remessa()
		
	Local aLegenda := {	{"BR_BRANCO"   , STR0010 }, ; // "Aberto"
						{"BR_VERDE"    , STR0011 }, ; // "Gerado Documento"
						{"BR_VERMELHO" , STR0012 } }  // "Cancelado Documento"

	BrwLegenda(STR0013,STR0014,aLegenda ) // "Status das Remessas" / "Legenda"
	
Return .T.

/*/{Protheus.doc} OA6400037VL
Validação (X3_VALID) do TES no Pergunte OA640 e no campo VWE_CODTES
@author Leandro Rodrigues
@since 15/07/2026
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Function OA6400037VL(cTes)
	Local lRet := .T.
		
	DBSelectArea("SF4")	
	SF4->(DbSetOrder(1))
	SF4->(DbSeek(xFilial("SF4") + cTes))
	if (SF4->F4_DUPLIC == "S" .or. SF4->F4_ESTOQUE == "S")
		FMX_HELP("OFIA640TES", STR0015) //"Utilize somente TES que não movimenta estoque e não gere financeiro."
		lRet := .F.
	EndIf

Return lRet

/*/{Protheus.doc} OA6400037_legenda_os
@author Leandro Rodrigues
@since 15/07/2026
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function OA6400047_legenda_os()

	Local aLegenda  := {{ 'BR_VERDE'   , STR0010   } ,;  // "Aberta"
						{ 'BR_AZUL'    , STR0016   } ,;  // "Liberada"
						{ 'BR_VERMELHO', STR0017   } ,;  // "Fechado"
						{ 'BR_PRETO'   , STR0018 } }     // "Cancelado"

	BrwLegenda(STR0019,STR0014 ,aLegenda)  // "Status das OS" / "Legenda"

Return .T.

/*/{Protheus.doc} OA6400057_coluna_status_os
@author Leandro Rodrigues
@since 15/07/2026
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function OA6400057_coluna_status_os()
	
	Local cImgRPO := "BR_VERDE" // Aberto
	
	Do Case
		Case VO1->VO1_STATUS == "D" // "Liberada"
			cImgRpo := "BR_AZUL"
		Case VO1->VO1_STATUS == "F" // "Fechado"
			cImgRpo := "BR_VERMELHO"		
		Case VO1->VO1_STATUS == "C" // "Cancelado"
			cImgRpo := "BR_PRETO"				
	EndCase

Return cImgRPO

/*/{Protheus.doc} OA6400067_gatilho_produto
@author Leandro Rodrigues
@since 15/07/2026
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function OA6400067_gatilho_produto(oParModel)
	Local cRet       := ""
	Local oModel     := oParModel:GetModel()
	Local oVWE       := oModel:GetModel("VWEDETAIL")
	Local cMV_GRUVEI := IIF(ExistFunc('FGX_GrupoVeic'),FGX_GrupoVeic(VV1->VV1_CHAINT), Left(GetMV("MV_GRUVEI")+Space(TamSX3("B1_GRUPO")[1]),TamSX3("B1_GRUPO")[1]))
	
	DBSelectArea("SB1")
	SB1->(DbSetOrder(1))
	If SB1->(DbSeek(FWxFilial("SB1") + oVWE:GetValue("VWE_CODSB1")))
		oVWE:LoadValue("VWE_CODITE", SB1->B1_CODITE)
		oVWE:LoadValue("VWE_DESITE", SB1->B1_DESC)
		IF AllTrim(cMV_GRUVEI) == AllTrim(SB1->B1_GRUPO)
			oVWE:LoadValue("VWE_VALPEC", FGX_VLRSUGV(SB1->B1_CODITE))
			oVWE:setValue("VWE_QTDITE", 1)
		Else
			oVWE:LoadValue("VWE_VALPEC", SB1->B1_PRV1)
		EndIf
		if !Empty(MV_PAR02) // MV do parametro da pergunte "OA640" da tecla F12 da rotina.
			oVWE:LoadValue("VWE_CODTES", MV_PAR02)
		EndIf
		cRet := SB1->B1_GRUPO
	EndIf

Return cRet

/*/{Protheus.doc} OA6400077_gatilho_qtde_vlr
@author Leandro Rodrigues
@since 15/07/2026
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function OA6400077_gatilho_qtde_vlr(oParModel)	
	Local oModel := oParModel:GetModel()
	Local oVWE   := oModel:GetModel("VWEDETAIL")
Return oVWE:GetValue("VWE_QTDITE") * oVWE:GetValue("VWE_VALPEC")

/*/{Protheus.doc} OA6400087_add_veiculo_grid
@author Leandro Rodrigues
@since 15/07/2026
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Function OA6400087_add_veiculo_grid(lButton)	
    Local oModel    := FWModelActive()
    Local nOper     := oModel:GetOperation()
    Local oView     := FWViewActive()   
	Local oVWE      := oModel:GetModel("VWEDETAIL") 
	Local oVeiculo  := DMS_Veiculo():New()
	Local cCodVeiSB1:= oVeiculo:GetB1_COD(VO1->VO1_CHAINT)	
	Local lTemVeic  := .F.
	Local nLinha    := 0
	
	Default lButton := .F.

	if lButton
		For nLinha := 1 To oVWE:Length()
			oVWE:GoLine(nLinha)
			if AllTrim(oVWE:GetValue("VWE_CODSB1")) == AllTrim(cCodVeiSB1)
				lTemVeic := .T.
			EndIf			
		Next
	EndIf
	
	if lTemVeic
		FWAlertWarning(STR0028, STR0027) // "Veiculo já existe na remessa! Em caso do registro deletado na grid, recupere e faça as alterações necessarias."  | "Atenção"
	Else
		If ! Empty(VO1->VO1_CHAINT) .AND. (nOper == 3 .OR. (nOper == 4 .AND. lButton))
			If FWAlertYesNo(STR0029, STR0027)  // "Deseja incluir a maquina da ordem de serviço na remessa?" | "Atenção"

				OA6400157_incluir_sb1(oVeiculo)

				If ! lButton
					If oVWE:CanClearData()
						oVWE:ClearData()
					EndIf
				EndIf

				oVWE:AddLine()
				oVWE:setValue("VWE_CODSB1", cCodVeiSB1)
				oView:Refresh()
			EndIf
		EndIf
	EndIf

	oVWE:GoLine(1)	
	oView:Refresh()

Return .T.

/*/{Protheus.doc} OA6400107_consulta_os
@author Leandro Rodrigues
@since 15/07/2026
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function OA6400107_consulta_os()

	INCLUI := .F.
	ALTERA := .F.

	FS_CONSOS()

Return

/*/{Protheus.doc} OA6400117_gerar_documento()
@author Leandro Rodrigues
@since 15/07/2026
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Function OA6400117_gerar_documento(oBrowse)

	Local oViewGer := Nil
			
	if Empty(MV_PAR03) // MV (Cond.Pagto) do parametro da pergunte "OA640" da tecla F12 da rotina.
		FMX_HELP("OFIA640F121",STR0042) // "Informe a condição de pagamento (F12) para gerar o documento."
	ElseIf Empty(MV_PAR04) // MV (Natureza) do parametro da pergunte "OA640" da tecla F12 da rotina.
		FMX_HELP("OFIA640F122",STR0043) // "Informe a natureza (F12) para gerar o documento."
	Else
		oViewGer := FWLoadView("OFIA640")
		
		oExecView := FWViewExec():New()
		oExecView:setTitle(STR0033) // "Geração do Documento"
		oExecView:setView(oViewGer)
		oExecView:setSource("OFIA640")
		oExecView:setCancel( { || .T. } )
		oExecView:setOperation(MODEL_OPERATION_UPDATE)	
		oExecView:openView(.T.)

		oBrowse:Refresh()
	EndIf
Return

/*/{Protheus.doc} OA6400127_gerando_documento()
@author Leandro Rodrigues
@since 15/07/2026
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Function OA6400127_gerando_documento()
	Local oModel   := FWModelActive()
	Local oVWD     := oModel:GetModel("VWDMASTER")
	Local oVWE     := oModel:GetModel("VWEDETAIL")
	Local aVetCb   := {}
	Local aVetIt   := {}	
	Local nMoeda   := oVWD:GetValue("VWD_MOEDA")	
	Local cVWDNUM  := ""
	Local cVWDSER  := ""
	Local nLinha   := 0
	Local aBkpMvs  := {}
	
	DBSelectArea("VAI")	
	VAI->(dbSetOrder(4))
	VAI->(MsSeek(xFilial("VAI") + __cUserID)) 	
	
	aVetCb := {	oVWD:GetValue("VWD_CLIFAT"),;
				oVWD:GetValue("VWD_LOJFAT"),;
				VAI->VAI_CODVEN,;
				MV_PAR03,; // Condição de Pagamento (F12)
				MV_PAR04,; // Natureza (F12)
				"",;
				"",;
				oVWD:GetValue("VWD_MENOTA"),;
				"";
			}

	For nLinha := 1 To oVWE:Length()
		oVWE:GoLine(nLinha)
		If ! oVWE:IsDeleted()
				aAdd(aVetIt,{;
						oVWE:GetValue("VWE_CODSB1"),;
						oVWE:GetValue("VWE_VALTOT"),;
				   		"",;
						oVWE:GetValue("VWE_QTDITE"),;
						oVWE:GetValue("VWE_VALPEC"),;
						oVWE:GetValue("VWE_CODTES") ;
						})
		EndIf
	Next
	
	aBkpMvs := NgSalvaMvPa() // Backup dos MV's atuais
	
	aNF := FMX_GERNFS(	aVetCb,;
						aVetIt,;
						.t.,;
						,; 
						,;
						Posicione("SA1", 1, FwxFilial("SA1") + oVWD:GetValue("VWD_CLIFAT") + oVWD:GetValue("VWD_LOJFAT"), "A1_TIPO"),;
						,;
						,;
						,;
						,;
						nMoeda,;
						,; 
						.T.)

	NgRetAuMVPa(aBkpMvs) // Restaurando MV's 

	cVWDNUM := aNF[1]
	cVWDSER := aNF[2]

	If Empty(cVWDNUM)
		Return .f.
	EndIf

	Reclock("VWD", .F.)
	VWD->VWD_NDOCTO := cVWDNUM
	VWD->VWD_SDOCTO := cVWDSER
	VWD->VWD_STATUS := "2"
	VWD->(MsUnlock())

Return .T.

/*/{Protheus.doc} OA6400137_cancelar_documento()
@author Leandro Rodrigues
@since 15/07/2026
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Function OA6400137_cancelar_documento(oBrowse)
	Local aBkpMvs  := {}
	
	IF VWD->VWD_STATUS == "2"
		if FWAlertYesNo(STR0034, STR0027) // "Deseja gerar o documento?" | "Atenção"
			aBkpMvs := NgSalvaMvPa() // Backup dos MV's atuais
			
			FWMsgRun(, {|| OA6400147_cancelando_documento() }, STR0035, STR0036) // "Aguarde" / "Processando cancelamento"
			
			NgRetAuMVPa(aBkpMvs) // Restaurando MV's 
			oBrowse:Refresh()
		EndIf
	Else
		FMX_HELP("OFIA640VLD2",STR0031) // "Documento não foi gerado para a remessa selecionada."
	EndIf
	
Return

/*/{Protheus.doc} OA6400147_cancelando_documento()
@author Leandro Rodrigues
@since 15/07/2026
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Function OA6400147_cancelando_documento()
	Local nX       := 0
	Local aCabs    := {}
	Local aItens   := {}
	Local cFunName := ""

	Private aCabsSF2  := FWSX3Util():GetAllFields("SF2", .F.)
	Private aItensSD2 := FWSX3Util():GetAllFields("SD2", .F.)

	DBSelectArea("SF2")
	SF2->(DbSetOrder(1))
	SF2->(DbSeek(VWD->VWD_FILOSV + VWD->VWD_NDOCTO + VWD->VWD_SDOCTO + VWD->VWD_CLIFAT + VWD->VWD_LOJFAT))

	aSize(aCabs, 0)
	aSize(aItens, 0)

	For nX := 1 to Len(aCabsSF2)
		aAdd(aCabs, {aCabsSF2[nX], &("SF2->"+aCabsSF2[nX]), Nil})
	Next nX

	SD2->(dbSetOrder(3))
	SD2->(dbSeek(SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))

	Do While !SD2->(Eof()) .And. SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA==SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA
		aAdd(aItens, {})
		For nX := 1 to Len(aItensSD2)
			aAdd(aItens[Len(aItens)], {aItensSD2[nX],&("SD2->"+aItensSD2[nX]), Nil})
		Next nX
		SD2->(dbSkip())
	Enddo

	lMSErroAuto := .F.

	cFunName := FunName()
	SetFunName("Mata462TN")

	MSExecAuto({|x,y,z| MATA462N(x,y,z)},aCabs,aItens,5) 
	
	SetFunName(cFunName)

	If lMsErroAuto
		MostraErro()
		MsUnlockAll()
		Return
	EndIf

	RecLock("VWD",.f.)
	VWD->VWD_STATUS := "3"
	VWD->(MsUnLock())

Return

/*/{Protheus.doc} OA6400157_incluir_sb1()
@author Leandro Rodrigues
@since 15/07/2026
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function OA6400157_incluir_sb1(oVeiculo)
	Local aArea      := GetArea()
	Local aAreaB1    := SB1->(GetArea())
	Local cMV_GRUVEI := IIF(ExistFunc('FGX_GrupoVeic'),FGX_GrupoVeic(VO1->VO1_CHAINT), Left(GetMV("MV_GRUVEI")+Space(TamSX3("B1_GRUPO")[1]),TamSX3("B1_GRUPO")[1]))

	// Criar maquina/veiculo na SB1
	DBSelectArea("SB1")
	SB1->(DBSetOrder(7))
	IF ! SB1->((DBSeek(xFilial("SB1") + cMV_GRUVEI + VO1->VO1_CHAINT)))
		SB1->(DBSetOrder(1))		
		DBSelectArea("VV1")
		VV1->(DbSetOrder(1))
		If VV1->(DbSeek(xFilial("VV1") + VO1->VO1_CHAINT)) // VV1->VV1_CHAINT
			RegToMemory("VV1", .F.) // Cria variaveis de Memoria que podem ser utilizadas nos PEs de criacao do SB1

			If ! oVeiculo:CriaPeca(VO1->VO1_CHAINT) // Inclui/Altera SB1 do Veiculo
				MostraErro()
				Help(" ",1,"ERROCADPRO") // Erro no Cadastro do Veiculo no SB1							
			Endif
			
		EndIf
	EndIf

	RestArea(aAreaB1)
	RestArea(aArea)
Return
