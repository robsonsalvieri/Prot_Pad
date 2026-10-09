#include "totvs.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "VEIC150.CH"

static oConsMovBrwStru
//static aBrwFldVV1

/*/{Protheus.doc} VEIC150
	Consulta Movimentacao e Reserva de Equipamentos - John Deere - Blackbird

	@author rubens.takahashi
	@since 18/11/2022
	@version 1.0
	@return ${return}, ${return_description}
	@type function
/*/
Function VEIC150()
	Local oBrowse

	VC1500013_ConfigBrowse()
	oBrowse := BrowseDef()
	oBrowse:Activate()
	VC1500073_Fim()
Return

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
	oBrowse:SetAlias('VV1')
	oBrowse:SetDescription( STR0001 )	// "Consulta de Movimentação - Equipment"
	cFilterDefault := "@ (EXISTS (SELECT FILTRO.R_E_C_N_O_ FROM " + RetSQLName("VK9") + " FILTRO WHERE FILTRO.VK9_FILIAL = '" + xFilial("VK9") + "' AND VK9_CHASSI = VV1_CHASSI AND FILTRO.D_E_L_E_T_ = ' ')) "
	oBrowse:SetFilterDefault(cFilterDefault)
Return oBrowse


Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina Title STR0002 Action 'VC1500043_BrowseMovimentacao' OPERATION 2 ACCESS 0	// 'Visualizar'
Return aRotina

Function VC1500043_BrowseMovimentacao(cAlias,nReg,nOpc)
	VC1500023_AtuBrowseConsulta()
	VC1500033_MontaTela(VV1->VV1_CHASSI)
Return


Function VC1500083_ConsultaMovExterno(cChaint, cChassi)
	local nOrdVV1 := VV1->(IndexOrd())

	default cChaint := ""
	default cChassi := ""
	
	if !empty(cChaint)
		VV1->(dbSetOrder(1))
		lExistVV1 := VV1->(msSeek(xFilial("VV1") + cChaInt))
	endif

	if !empty(cChassi)
		VV1->(dbSetOrder(2))
		lExistVV1 := VV1->(msSeek(xFilial("VV1") + cChassi))
	endif

	VV1->(dbSetOrder(nOrdVV1))
	if ! lExistVV1
		return .t.
	endif

	VC1500013_ConfigBrowse()
	VC1500023_AtuBrowseConsulta()
	VC1500033_MontaTela(VV1->VV1_CHASSI)
	VC1500073_Fim()
Return

Function VC1500073_Fim()
	oConsMovBrwStru:DelTrabTmp()
Return


Static Function VC1500013_ConfigBrowse()
	local aCampos := {;
		"VK9_CODIGO",;
		"VK9_DATREG",;
		"VK9_HORREG",;
		"TIPO_REG",;
		"VW0_SITVEI",;
		"VW0_ULTMOV",;
		"VK9_BBEQTY",;
		"VK9_BBSTTY",;
		"VK9_BBINST",;
		"VK9_BBSTST",;
		"VK9_LOCRID",;
		"VK9_SOLCID",;
		"VK9_BBYARD",;
		"VK9_FILATE",;
		"VK9_NUMATE",;
		"VK9_OPER",;
		"VW0_PROATU",;
		"VW0_LJPATU",;
		"VW0_CODIGO",;
		"VW0_ESTVEI",;
		"VW0_BBINTG",;
		"VW0_OPMENT",;
		"VW0_FILENT",;
		"VW0_TRACPA",;
		"VW0_STENT" ,;
		"VW0_SERENT",;
		"VW0_NFENT" ,;
		"VW0_OPMSAI",;
		"VW0_FILSAI",;
		"VW0_NUMTRA",;
		"VW0_STSAI" ,;
		"VW0_SERSAI",;
		"VW0_NFSAI";
	}
	local nCntFor 

	oConsMovBrwStru := OFBrowseStruct():New({"VW0", "VK9"})

	for nCntFor := 1 to Len(aCampos)
		if aCampos[nCntFor] == "TIPO_REG"
			oConsMovBrwStru:AddFieldManual( DMS_DataContainer():New({;
													{ 'cIdField' , 'TIPO_REG' },;
													{ 'cTitulo' , STR0003  },; // 'Tipo Reg.'	'Descr. Opcional'
													{ 'cTipo' , 'C' },;
													{ 'nTamanho' , 15 },;
													{ 'nDecimal' , 0 },;
													{ 'cPicture' , '@!' } } ) )
		else
			oConsMovBrwStru:AddField( alltrim(aCampos[nCntFor]) )
		endif
	next nCntFor
	oConsMovBrwStru:CriaTabTmp()
Return

Function VC1500023_AtuBrowseConsulta()
	Local cSQL

	local cSTR0004 := STR0004	// 'RESERVA'
	local cSTR0005 := STR0005	// 'MOVIMENTAÇÃO'

	cSQL := "SELECT " + ;
		"VK9_CODIGO, " +;
		"VK9_DATREG, " +;
		"VK9_HORREG, " +;
		"CASE WHEN VW0_CODIGO IS NULL THEN '" + cSTR0004 + "' ELSE '" + cSTR0005 + "' END TIPO_REG, " +;		// 'RESERVA'		'MOVIMENTAÇÃO'
		"COALESCE(VW0_SITVEI, ' ') VW0_SITVEI , " +;
		"COALESCE(VW0_ULTMOV, ' ') VW0_ULTMOV , " +;
		"VK9_BBEQTY, " +;
		"VK9_BBSTTY, " +;
		"VK9_BBINST, " +;
		"VK9_BBSTST, " +;
		"VK9_LOCRID, " +;
		"VK9_SOLCID, " +;
		"VK9_BBYARD, " +;
		"VK9_FILATE, " +;
		"VK9_NUMATE, " +;
		"VK9_OPER, " +;
		"COALESCE(VW0_PROATU, ' ') VW0_PROATU, " +;
		"COALESCE(VW0_LJPATU, ' ') VW0_LJPATU, " +;
		"COALESCE(VW0_CODIGO, ' ') VW0_CODIGO, " +;
		"COALESCE(VW0_ESTVEI, ' ') VW0_ESTVEI, " +;
		"COALESCE(VW0_BBINTG, ' ') VW0_BBINTG, " +;
		"COALESCE(VW0_OPMENT, ' ') VW0_OPMENT, " +;
		"COALESCE(VW0_FILENT, ' ') VW0_FILENT, " +;
		"COALESCE(VW0_TRACPA, ' ') VW0_TRACPA, " +;
		"COALESCE(VW0_STENT , ' ') VW0_STENT , " +;
		"COALESCE(VW0_SERENT, ' ') VW0_SERENT, " +;
		"COALESCE(VW0_NFENT , ' ') VW0_NFENT , " +;
		"COALESCE(VW0_OPMSAI, ' ') VW0_OPMSAI, " +;
		"COALESCE(VW0_FILSAI, ' ') VW0_FILSAI, " +;
		"COALESCE(VW0_NUMTRA, ' ') VW0_NUMTRA, " +;
		"COALESCE(VW0_STSAI , ' ') VW0_STSAI , " +;
		"COALESCE(VW0_SERSAI, ' ') VW0_SERSAI, " +;
		"COALESCE(VW0_NFSAI , ' ') VW0_NFSAI   " +;
		" FROM " + RetSQLName("VK9") + " VK9 " + ;
		       " LEFT JOIN " + RetSQLName("VW0") + " VW0 " + ;
		       " ON VW0.VW0_FILIAL = '" + xFilial("VW0") + "' AND VW0.VW0_CODVK9 = VK9.VK9_CODIGO AND VW0.D_E_L_E_T_ = ' '" + ;
		" WHERE VK9.VK9_FILIAL = '" + xFilial("VK9") + "'" +;
		  " AND VK9.VK9_CHASSI = '" + VV1->VV1_CHASSI + "'" +;
		  " AND VK9.D_E_L_E_T_ = ' '"+;
		" ORDER BY VK9_DATREG, VK9_HORREG"

	oConsMovBrwStru:LoadData( cSQL , .t. )

	dbSelectArea(oConsMovBrwStru:GetAlias())
	dbGoTop()
Return

Function VC1500053_AtualizaBrowse()
	VC1500023_AtuBrowseConsulta()
	oBrwVW0VK9:GoTop(.t.)
	oBrwVW0VK9:Refresh(.t.)
Return

Static Function VC1500033_MontaTela(cChassi)
	Local aCoors  := FWGetDialogSize( oMainWnd )
	Private oDlgPrinc
	Private oBrwVV1
	Private oBrwVW0
	Private oBrwVK9
	Private oRelacVV1VW0
	Private oRelacVV1VK9

	DEFINE MSDIALOG oDlgPrinc TITLE STR0006 + cChassi FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] STYLE nOR(WS_VISIBLE,WS_POPUP) PIXEL	// "Consulta Movimentação - "

	oBrwVW0VK9:= FWMBrowse():New()
	oBrwVW0VK9:SetDescription( STR0007 ) // 'Movimentação'
	oBrwVW0VK9:DisableDetails()
	oBrwVW0VK9:setMenuDef(" ")

	oConsMovBrwStru:SetBrwOwner(oBrwVW0VK9)

	oBrwVW0VK9:AddButton(STR0002,{ || VC1500063_Visualizar() } )	// "Visualizar"
	oBrwVW0VK9:AddButton(STR0008,{ || VC1500053_AtualizaBrowse() } )	// "Atualizar"

	oBrwVW0VK9:SetUseFilter( .T. ) 

	oBrwVW0VK9:SetUseFilter()
	oBrwVW0VK9:SetWalkThru(.F.)
	oBrwVW0VK9:SetAmbiente(.F.)
	oBrwVW0VK9:DisableDetails()

	cAuxAlias := oConsMovBrwStru:GetAlias()
	oBrwVW0VK9:AddLegend( cAuxAlias + '->VW0_STSAI == "0" .OR. ' + cAuxAlias + '->VW0_STENT == "0"' , 'BR_VERMELHO', STR0009 )	// "Movimento Cancelado"
	oBrwVW0VK9:AddLegend( cAuxAlias + '->VW0_STSAI == "1" .OR. ' + cAuxAlias + '->VW0_STENT == "1"' , 'BR_VERDE'   , STR0010 ) 	// "Movimento Válido"

	oBrwVW0VK9:AddStatusColumns( { || IIF( VW0_BBINTG == "1" , "PMSRELA","" ) }, { || VA0710013_Legenda() } )

	oConsMovBrwStru:AddBrwColumn()

	oBrwVW0VK9:SetAlias(oConsMovBrwStru:GetAlias())
	oBrwVW0VK9:SetOwner(oDlgPrinc)

	dbselectArea(oConsMovBrwStru:GetAlias())

	oBrwVW0VK9:Activate()

	ACTIVATE MSDIALOG oDlgPrinc
Return

//Static Function MontaTela()
//	Local aCoors  := FWGetDialogSize(oMainWnd)
//	local aFolders
//	Private oDlgPrinc
//	Private oBrwVV1
//	Private oBrwVW0
//	Private oBrwVK9
//	Private oRelacVV1VW0
//	Private oRelacVV1VK9
//
//	Define MsDialog oDlgPrinc Title STR0001 From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel STYLE nOr(WS_VISIBLE,WS_POPUP)
//
//	aFolders := {}
//	AAdd( aFolders , "Equipment")
//	AAdd( aFolders , "Movimentação")
//	oFldVC150 := TFolder():New(1,1,aFolders,,oDlgPrinc,,,,.T.,.F.,100,100)
//	oFldVC150:Align:= CONTROL_ALIGN_ALLCLIENT
//
//	oBrwVV1:= FWmBrowse():New()
//	oBrwVV1:SetOwner( oFldVC150:aDialogs[1] )
//	oBrwVV1:SetDescription( "Equipamentos" )
//	oBrwVV1:SetAlias( 'VV1' )
//	oBrwVV1:SetMenuDef( '' )
//	oBrwVV1:SetProfileID( '1' )
//	oBrwVV1:DisableDetails()
//	oBrwVV1:DisableReport()
//	oBrwVV1:DisableConfig()
//	oBrwVV1:DisableSaveConfig()
//	oBrwVV1:ForceQuitButton()
//	if aBrwFldVV1 == nil
//		aBrwFldVV1 := {}
//		aAuxStru := FWFormStruct(3,"VV1")
//	
//		AADD( aBrwFldVV1 , "VV1_FILIAL" )
//		AADD( aBrwFldVV1 , "VV1_RESERV" )
//		AADD( aBrwFldVV1 , "VV1_FILENT" )
//		AADD( aBrwFldVV1 , "VV1_FILSAI" )
//		AADD( aBrwFldVV1 , "VV1_ULTMOV" )
//		AADD( aBrwFldVV1 , "VV1_BBRFID" )
//		AADD( aBrwFldVV1 , "VV1_BBINTG" )
//		AADD( aBrwFldVV1 , "VV1_BBSYNC" )
//		AADD( aBrwFldVV1 , "VV1_BBDINC" )
//		AADD( aBrwFldVV1 , "VV1_BBDALT" )
//		AADD( aBrwFldVV1 , "VV1_BBDEL " )
//		AADD( aBrwFldVV1 , "VV1_BBEQTY" )
//		AADD( aBrwFldVV1 , "VV1_BBSTTY" )
//		AADD( aBrwFldVV1 , "VV1_BBINST" )
//		AADD( aBrwFldVV1 , "VV1_BBSTST" )
//		AADD( aBrwFldVV1 , "VV1_LOCRID" )
//		AADD( aBrwFldVV1 , "VV1_SOLCID" )
//		AADD( aBrwFldVV1 , "VV1_BBYARD" )
//		AADD( aBrwFldVV1 , "VV1_CHASSI" )
//		AADD( aBrwFldVV1 , "VV1_MODVEI" )
//		AADD( aBrwFldVV1 , "VV1_SEGMOD" )
//		AADD( aBrwFldVV1 , "VV1_FABMOD" )
//		AADD( aBrwFldVV1 , "VV1_CARROC" )
//		AADD( aBrwFldVV1 , "VV1_ESTVEI" )
//		AADD( aBrwFldVV1 , "VV1_SITVEI" )
//		AADD( aBrwFldVV1 , "VV1_TIPOPE" )
//		AADD( aBrwFldVV1 , "VV1_PROATU" )
//		AADD( aBrwFldVV1 , "VV1_LJPATU" )
//	endif
//	oBrwVV1:SetOnlyFields(aBrwFldVV1)
//	cFilterDefault := "@ (NOT EXISTS (SELECT FILTRO.R_E_C_N_O_ FROM " + RetSQLName("VK9") + " FILTRO WHERE FILTRO.VK9_FILIAL = '" + xFilial("VK9") + "' AND VK9_CHASSI = VV1_CHASSI AND FILTRO.D_E_L_E_T_ = ' ')) "
//	oBrwVV1:SetFilterDefault(cFilterDefault)
//	oBrwVV1:Activate()
//
//	ACTIVATE MSDIALOG oDlgPrinc
//Return

Function VC1500063_Visualizar(cAlias,nReg,nOpc)
	local cAlBrowse := oConsMovBrwStru:GetAlias()
	local cAuxAlias := Alias()

	dbSelectArea("VK9")
	VK9->(dbSetOrder(1))
	VK9->(dbSeek(xFilial("VK9") + (cAlBrowse)->(VK9_CODIGO)))

	if empty((cAlBrowse)->(VW0_CODIGO))
		VA0720043_ViewVK9Reserva()
	else
		VA0720033_ViewVW0Movimentacao()
	endif

	if !empty(cAuxAlias)
		dbselectarea(cAuxAlias)
	endif
Return
