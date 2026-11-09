#INCLUDE "WMSA391.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#include "RWMAKE.CH"
#INCLUDE "APVT100.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

#DEFINE WMSA39101 "WMSA39101"

Static oBrwDCT, oBrwDCU, oBrwDCV
//--------------------------------------------------
/*/{Protheus.doc} WMSA391
Monitor de Montagem de Vomule
@author felipe.m
@since 07/05/2015
@version 1.0
/*/
//--------------------------------------------------
Function WMSA391()
Local nTime := SuperGetMV('MV_WMSREFS', .F., 10) // Tempo em Segundos para Refresh da tela de Execucao de Servicos (Default = 10 segundos)
Local oBrowse

	If Pergunte('WMSA390',.T.)
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias("DCS")
		oBrowse:SetMenuDef("WMSA391")
		oBrowse:SetDescription(STR0001) // Montagem de Volume
		oBrowse:DisableDetails()
		oBrowse:SetAmbiente(.F.)
		oBrowse:SetWalkThru(.F.)
		oBrowse:SetFixedBrowse(.T.)
		oBrowse:SetFilterDefault("@"+Filtro())
		oBrowse:AddLegend("DCS->DCS_STATUS=='1'", "RED"   , STR0002) // Nao Iniciado
		oBrowse:AddLegend("DCS->DCS_STATUS=='2'", "YELLOW", STR0003) // Em Andamento
		oBrowse:AddLegend("DCS->DCS_STATUS=='3'", "GREEN" , STR0004) // Finalizado
		oBrowse:SetParam({|| SelFiltro(oBrowse) })
		oBrowse:SetTimer({|| RefreshBrw(oBrowse) }, Iif(nTime<=0, 3600, nTime) * 1000)
		oBrowse:SetIniWindow({||oBrowse:oTimer:lActive := (MV_PAR07 < 4)})
		oBrowse:SetProfileID('DCS')
		oBrowse:Activate()
	EndIf
Return Nil
//-------------------------------------------------------------------//
//-------------------------Funcao MenuDEF----------------------------//
//-------------------------------------------------------------------//
Static Function MenuDef()
Local aRotina := {}
	ADD OPTION aRotina TITLE STR0005 ACTION "WMS391Mtor()"	OPERATION 2 ACCESS 0 // Monitor
	ADD OPTION aRotina TITLE STR0006 ACTION "WMSR420"       OPERATION 9 ACCESS 0 // Relatório CheckOut
Return aRotina
//-------------------------------------------------------------------//
//-------------------------Funcao ModelDef---------------------------//
//-------------------------------------------------------------------//
Static Function ModelDef()
Local oModel   := MPFormModel():New('WMSA391',{|oModel| BeforeCMdl(oModel) },{|oModel| ValidMdl(oModel) },{|oModel| CommitMdl(oModel) })
Local oStr1    := FWFormStruct(1,'DCS')
Local oStr2    := FWFormStruct(1,'DCT')
Local oStr3    := FWFormStruct(1,'DCU')
Local oStr4    := FWFormStruct(1,'DCV')
Local aTrigger := {}
Local bStatusDCT  := {||,Iif(DCT->DCT_STATUS=="1",'BR_VERMELHO',Iif(DCT->DCT_STATUS=="2",'BR_AMARELO','BR_VERDE'))}
Local bStatusDCV  := {||,Iif(DCV->DCV_STATUS=="1",'BR_AMARELO',Iif(DCV->DCV_STATUS=="3",'BR_VERMELHO','BR_AZUL'))}

	oStr1:SetProperty('*',MODEL_FIELD_OBRIGAT,.F.)
	oStr2:SetProperty('*',MODEL_FIELD_OBRIGAT,.F.)
	oStr3:SetProperty('*',MODEL_FIELD_OBRIGAT,.F.)
	oStr4:SetProperty('*',MODEL_FIELD_OBRIGAT,.F.)

	// oStr2:AddField(< cTitulo >, < cTooltip >, < cIdField >, < cTipo >, < nTamanho >, [ nDecimal ], [ bValid ], [ bWhen ], [ aValues ], [ lObrigat ], [ bInit ], < lKey >, [ lNoUpd ], [ lVirtual ], [ cValid ])
	oStr2:AddField("", "", 'DCT_VSTATUS', 'C', 11, 0,,,,,bStatusDCT,,,.T.) // Status // Situação da montagem de volumes
	oStr4:AddField("", "", 'DCV_VSTATUS', 'C', 11, 0,,,,,bStatusDCV,,,.T.) // Status // Situação da montagem de volumes

	oModel:AddFields('A391DCS',,oStr1)
	oModel:AddGrid('A391DCT','A391DCS',oStr2)
	oModel:SetRelation('A391DCT', { { 'DCT_FILIAL', 'xFilial("DCT")' }, { 'DCT_CODMNT', 'DCS_CODMNT' }, { 'DCT_CARGA', 'DCS_CARGA' }, { 'DCT_PEDIDO', 'DCS_PEDIDO' } }, DCT->(IndexKey(2)) )

	oModel:AddGrid('A391DCU','A391DCS',oStr3)
	oModel:SetRelation('A391DCU', { { 'DCU_FILIAL', 'xFilial("DCU")' }, { 'DCU_CARGA', 'DCS_CARGA' }, { 'DCU_PEDIDO', 'DCS_PEDIDO' }, { 'DCU_CODMNT', 'DCS_CODMNT' } }, DCU->(IndexKey(2)) )

	oModel:addGrid('A391DCV','A391DCU',oStr4)
	oModel:SetRelation('A391DCV', { { 'DCV_FILIAL', 'xFilial("DCV")' }, { 'DCV_CODMNT', 'DCU_CODMNT' }, { 'DCV_CARGA', 'DCU_CARGA' }, { 'DCV_PEDIDO', 'DCU_PEDIDO' }, { 'DCV_CODVOL', 'DCU_CODVOL' } }, DCV->(IndexKey(3)) )

	oModel:SetPrimaryKey({'DCS_FILIAL', 'DCS_CARGA','DCS_PEDIDO','DCS_CODMNT'})

	oModel:GetModel('A391DCT'):SetOptional(.T.)
	oModel:GetModel('A391DCU'):SetOptional(.T.)
	oModel:GetModel('A391DCV'):SetOptional(.T.)

	oModel:SetActivate({|oModel| ActiveMdl(oModel) })
Return oModel
//-------------------------------------------------------------------//
//-------------------------Funcao ViewDef----------------------------//
//-------------------------------------------------------------------//
Static Function ViewDef()
Local oModel := ModelDef()
Local oView  := FWFormView():New()
Local oStr1  := FWFormStruct(2,'DCS')
Local oStr2  := FWFormStruct(2,'DCT')
Local oStr3  := FWFormStruct(2,'DCU')
Local oStr4  := FWFormStruct(2,'DCV')

	oStr1:SetProperty('*',MVC_VIEW_CANCHANGE,.F.)
	oStr2:SetProperty('*',MVC_VIEW_CANCHANGE,.F.)
	oStr3:SetProperty('*',MVC_VIEW_CANCHANGE,.F.)
	oStr4:SetProperty('*',MVC_VIEW_CANCHANGE,.F.)

	oStr2:AddField('DCT_VSTATUS', '01',"","", , 'GET', '@BMP', Nil, /*cLookUp*/,.F., /*cFolder*/, /*cGroup*/, /*aComboValues*/, /*nMaxLenCombo*/, /*cIniBrow*/, .T.) //Situação da montagem de volumes
	oStr2:RemoveField('DCT_STATUS')
	oStr4:AddField('DCV_VSTATUS', '01',"","", , 'GET', '@BMP', Nil, /*cLookUp*/,.F., /*cFolder*/, /*cGroup*/, /*aComboValues*/, /*nMaxLenCombo*/, /*cIniBrow*/, .T.) //Situação da montagem de volumes
	oStr4:RemoveField('DCV_STATUS')

	oView:SetModel(oModel)
	oView:AddField('VIEW_DCS', oStr1, 'A391DCS')
	oView:AddGrid( 'VIEW_DCT', oStr2, 'A391DCT')
	oView:AddGrid( 'VIEW_DCU', oStr3, 'A391DCU')
	oView:AddGrid( 'VIEW_DCV', oStr4, 'A391DCV')

	oView:CreateFolder( 'FOLDER1')
	oView:AddSheet('FOLDER1','SHEET1',STR0007) // Documentos
	oView:AddSheet('FOLDER1','SHEET2',STR0008) // Volume

	oView:CreateHorizontalBox( 'BOXDCS', 20, /*owner*/, /*lUsePixel*/, 'FOLDER1', 'SHEET1')
	oView:CreateHorizontalBox( 'BOXDCT', 80, /*owner*/, /*lUsePixel*/, 'FOLDER1', 'SHEET1')
	oView:CreateHorizontalBox( 'BOXDCU', 30, /*owner*/, /*lUsePixel*/, 'FOLDER1', 'SHEET2')
	oView:CreateHorizontalBox( 'BOXDCV', 70, /*owner*/, /*lUsePixel*/, 'FOLDER1', 'SHEET2')

	oView:SetOwnerView('VIEW_DCS','BOXDCS')
	oView:SetOwnerView('VIEW_DCT','BOXDCT')
	oView:SetOwnerView('VIEW_DCU','BOXDCU')
	oView:SetOwnerView('VIEW_DCV','BOXDCV')

	oView:EnableTitleView('VIEW_DCS', STR0001) // Montagem de Volume
	oView:EnableTitleView('VIEW_DCT', STR0010) // Documentos Montagem
	oView:EnableTitleView('VIEW_DCU', STR0008) // Volume
	oView:EnableTitleView('VIEW_DCV', STR0011) // Itens Volume
Return oView
//-------------------------------------------------------------------//
//--------------------Filtro default do programa---------------------//
//-------------------------------------------------------------------//
Static Function Filtro()
Local cFiltro := ""
	cFiltro := " DCS_CARGA >= '"+MV_PAR01+"' AND DCS_CARGA <= '"+MV_PAR02+"'"
	cFiltro += " AND DCS_PEDIDO >= '"+MV_PAR03+"' AND DCS_PEDIDO <= '"+MV_PAR04+"'"
	cFiltro += " AND DCS_DATA >= '"+DTOS(MV_PAR05)+"' AND DCS_DATA <= '"+DTOS(MV_PAR06)+"'"
Return cFiltro
//-------------------------------------------------------------------//
//--------------------Seleção do filtro tecla F12--------------------//
//-------------------------------------------------------------------//
Static Function SelFiltro(oBrowse)
Local nPos := oBrowse:At()
Local lRet := .T.
	If (lRet := Pergunte('WMSA390',.T.))
		oBrowse:oTimer:lActive := (MV_PAR07 < 4)
		oBrowse:SetFilterDefault("@"+Filtro())
		oBrowse:Refresh()
	EndIf
Return lRet
//-------------------------------------------------------------------//
//------------Refresh do Browse para Recarregar a Tela---------------//
//-------------------------------------------------------------------//
Static Function RefreshBrw(oBrowse)
Local nPos := oBrowse:At()
	If MV_PAR07 == 1
		oBrowse:Refresh(.T.)
	ElseIf MV_PAR07 == 2
		oBrowse:Refresh(.F.)
		oBrowse:GoBottom()
	Else
		oBrowse:Refresh(.F.)
		oBrowse:GoTo(nPos)
	EndIf
Return .T.

Function WMSA391MNT()
Return WMS391Mtor(2)

//-------------------------------------------------------------------//
//-----------------------------Monitor-------------------------------//
//-------------------------------------------------------------------//
Function WMS391Mtor(nAcao)
Local aCoors := FWGetDialogSize(oMainWnd)
Local oSize,oDlg, oMaster, oFolder
Local oLayer,oPanelLeft,oPanelRight,oRelation
Local aFolders := {}
Local aButtons := {}
Local aPosSize := {}
Local nTime    := SuperGetMV('MV_WMSREFS', .F., 10) // Tempo em Segundos para Refresh da tela de Execucao de Servicos (Default = 10 segundos)
Local oTimer   := Nil
Local nOpcA    := 0
Default nAcao := 1

	// Calcula as dimensoes dos objetos
	oSize := FwDefSize():New( .T. )  // Com enchoicebar

	// Cria Enchoice
	oSize:AddObject( "MASTER", 100, 85, .T., .F. ) // Adiciona enchoice
	oSize:AddObject( "DETAIL", 100, 60, .T., .T. ) // Adiciona enchoice

	// Dispara o calculo
	oSize:Process()

	// Desenha a dialog
	DEFINE MSDIALOG oDlg TITLE STR0012 FROM ; // Monitor de Volume
		  oSize:aWindSize[1],oSize:aWindSize[2] TO ;
		  oSize:aWindSize[3],oSize:aWindSize[4] PIXEL

	// Cria as variáveis de memória usadas pela Enchoice
	// Monta a Enchoice
	aPosSize := {oSize:GetDimension("MASTER","LININI"),;
					oSize:GetDimension("MASTER","COLINI"),;
					oSize:GetDimension("MASTER","LINEND"),;
					oSize:GetDimension("MASTER","COLEND")}
	oMaster := MsMGet():New("DCS",DCS->(Recno()),2,,,,,aPosSize,,3,,,,oDlg)

	aFolders := {STR0007,STR0008} // Documentos // Volume

	// Monta o Objeto Folder
	aPosSize := {oSize:GetDimension("DETAIL","LININI"),; // Pos.x
					oSize:GetDimension("DETAIL","COLINI"),; // Pos.y
					oSize:GetDimension("DETAIL","XSIZE"),;  // Size.x
					oSize:GetDimension("DETAIL","YSIZE")}   // Size.y
	oFolder := TFolder():New(aPosSize[1],aPosSize[2],aFolders,aFolders,oDlg,,,,.T.,.T.,aPosSize[3],aPosSize[4])

	// Define Browse Documento (DCT)
	oBrwDCT := FWMBrowse():New()
	oBrwDCT:SetOwner(oFolder:aDialogs[1])
	oBrwDCT:SetDescription(STR0013) // Itens dos Docs. na Mont. Volume
	oBrwDCT:SetAlias('DCT')
	oBrwDCT:SetFilterDefault("@ DCT_FILIAL = '"+xFilial('DCT')+"' AND DCT_CODMNT = '"+DCS->DCS_CODMNT+"'")
	oBrwDCT:SetMenuDef('')
	If nAcao == 1
		oBrwDCT:AddButton(STR0014, {|| oTimer:DeActivate(), WmA391Esto(), oTimer:Activate()},, 4, 0) // Estornar Documento
	EndIf
	oBrwDCT:AddLegend("DCT->DCT_STATUS=='1'", "RED"   , STR0002) // Nao Iniciado
	oBrwDCT:AddLegend("DCT->DCT_STATUS=='2'", "YELLOW", STR0003) // Em Andamento
	oBrwDCT:AddLegend("DCT->DCT_STATUS=='3'", "GREEN" , STR0004) // Finalizado
	oBrwDCT:SetAmbiente(.F.)
	oBrwDCT:SetWalkThru(.F.)
	oBrwDCT:DisableDetails()
	oBrwDCT:SetFixedBrowse(.T.)
	oBrwDCT:SetProfileID('DCT')
	oBrwDCT:Activate()

	oLayer := FWLayer():New()
	oLayer:Init(oFolder:aDialogs[2],.F.,.T.)

	oLayer:AddCollumn("LEFT",50,.F.)
	oLayer:AddCollumn("RIGHT",50,.F.)

	oPanelLeft := oLayer:GetColPanel('LEFT')
	oPanelRight := oLayer:GetColPanel('RIGHT')

	// Define Browse Volume (DCU)
	oBrwDCU := FWMBrowse():New()
	oBrwDCU:SetOwner(oPanelLeft)
	oBrwDCU:SetDescription(STR0008) // Volume
	oBrwDCU:SetAlias('DCU')
	oBrwDCU:SetFilterDefault("@ DCU_FILIAL = '"+xFilial('DCU')+"' AND DCU_CODMNT = '"+DCS->DCS_CODMNT+"'")
	If nAcao == 1
		oBrwDCU:SetMenuDef('WMSA391B')
	Else
		oBrwDCU:SetMenuDef('')
	EndIf
	oBrwDCU:SetAmbiente(.F.)
	oBrwDCU:SetWalkThru(.F.)
	oBrwDCU:DisableDetails()
	oBrwDCU:SetFixedBrowse(.T.)
	oBrwDCU:SetProfileID('DCU')
	oBrwDCU:Activate()

	// Define Browse Produtos (DCV)
	oBrwDCV := FWMarkBrowse():New()
	oBrwDCV:SetOwner(oPanelRight)
	oBrwDCV:SetDescription(STR0011) // Itens do Volume
	oBrwDCV:SetAlias('DCV')
	If nAcao == 1
		oBrwDCV:SetMenuDef('WMSA391C')
	Else
		oBrwDCV:SetMenuDef('')
	EndIf
	oBrwDCV:AddLegend("DCV->DCV_STATUS=='1'", "YELLOW", STR0015) // Nao Liberado
	oBrwDCV:AddLegend("DCV->DCV_STATUS=='2'", "BLUE"  , STR0016) // Liberado
	oBrwDCV:AddLegend("DCV->DCV_STATUS=='3'", "RED"   , STR0035) // Separação Em Andamento
	oBrwDCV:SetAmbiente(.F.)
	oBrwDCV:SetWalkThru(.F.)
	oBrwDCV:DisableDetails()
	oBrwDCV:SetFixedBrowse(.T.)
	oBrwDCV:SetProfileID('DCV')
	oBrwDCV:Activate()

	// Relacionamento browse Itens com Pedidos
	oRelation := FWBrwRelation():New()
	oRelation:AddRelation(oBrwDCU,oBrwDCV,{ {"DCV_FILIAL","xFilial('DCV')"},{"DCV_CODVOL","DCU_CODVOL"} })
	oRelation:Activate()

	oTimer:= TTimer():New((Iif(nTime <= 0, 3600, nTime) * 1000),{|| WMSA391REF() },oDlg)
	oTimer:Activate()

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpcA := 1,oDlg:End()},{|| nOpcA := 2,oDlg:End()},,aButtons)
Return Nil
//-------------------------------------------------------------------//
//-------Função responsável por efetuar a atualização da tela--------//
//-------------------------------------------------------------------//
Function WMSA391REF()
	oBrwDCT:Refresh()
	oBrwDCU:Refresh()
	oBrwDCV:Refresh()
Return .T.
//-------------------------------------------------------------------//
//------------Força a modificação do model para o commit-------------//
//-------------------------------------------------------------------//
Static Function BeforeCMdl(oModel)
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		oModel:LMODIFY := .T.
	EndIf
Return .T.
//-------------------------------------------------------------------//
//-----Realiza alguma alteração no modelo para chamar o ValidMdl-----//
//-------------------------------------------------------------------//
Static Function ActiveMdl(oModel)
	oModel:GetModel("A391DCT"):SetValue("DCT_STATUS", oModel:GetModel("A391DCT"):GetValue("DCT_STATUS"))
Return .T.
//---------------------------------------------------------------------------//
//------Validação para impedir o estorno caso algum item esteja faturado-----//
//---------------------------------------------------------------------------//
Static Function ValidMdl(oModel)
Local lRet := .T.
Local cQuery := ""
Local nI := 0
Local oModelDCS := oModel:GetModel("A391DCS")
Local oModelDCU := oModel:GetModel("A391DCU")
Local oModelDCV := oModel:GetModel("A391DCV")
Local cAliasQry := ""
	// Validação do Estorno por Documento
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		// Valida apenas quanto não 'Libera o estorno do volume' (DCS_LIBEST)
		If oModelDCS:GetValue("DCS_LIBEST") == "2"
			// Procura se algum SC9 possui o campo Nota Fiscal preenchido
			cQuery := " SELECT SC9.C9_NFISCAL"
			cQuery +=   " FROM "+RetSqlName("SC9")+" SC9,"
			cQuery +=            RetSQLName("D0I")+" D0I"
			cQuery +=  " WHERE SC9.C9_FILIAL   = '"+xFilial("SC9")+"'"
			If WmsCarga(oModelDCS:GetValue("DCS_CARGA"))
				cQuery += " AND SC9.C9_CARGA    = '"+oModelDCS:GetValue("DCS_CARGA")+"'"
			EndIf
			cQuery +=    " AND SC9.C9_PEDIDO   = '"+oModelDCS:GetValue("DCS_PEDIDO")+"'"
			cQuery +=    " AND SC9.D_E_L_E_T_  = ' '"
			cQuery +=    " AND D0I.D0I_FILIAL  = '"+xFilial("D0I")+"'"
			cQuery +=    " AND D0I.D0I_CODMNT  = '"+oModelDCS:GetValue("DCS_CODMNT")+"'"
			cQuery +=    " AND D0I.D0I_IDDCF   = SC9.C9_IDDCF"
			cQuery +=    " AND D0I.D_E_L_E_T_  = ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()
			DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
			If (cAliasQry)->(Eof())
				oModel:SetErrorMessage("A391DCT",,"A391DCT",,,WmsFmtMsg(STR0036,{{"[VAR01]",oModelDCS:GetValue("DCS_CODMNT")}}),) // Não foi possível encontrar a liberação de pedidos referente à Montagem de Volumes [VAR01]. Caso tenha sido feita a exclusão do faturamento com a opção de retorno do pedido para Carteira, não será permitido estornar os processos WMS.
				lRet := .F.
			EndIf
			While !(cAliasQry)->(Eof())
				If !Empty((cAliasQry)->C9_NFISCAL)
					oModel:SetErrorMessage("A391DCT",,"A391DCT",,,STR0017,) // Documento não pode ser estornado, pois possui item faturado!
					lRet := .F.
				EndIf
				(cAliasQry)->(DbSkip())
			EndDo
			(cAliasQry)->(dbCloseArea())
		EndIf
		If lRet
			cQuery := " SELECT 1 "
			cQuery +=   " FROM "+RetSqlName("D00")
			cQuery +=  " WHERE D00_FILIAL = '"+xFilial("D00")+"'"
			cQuery +=    " AND D00_CARGA = '"+oModelDCS:GetValue("DCS_CARGA")+"'"
			cQuery +=    " AND D00_PEDIDO = '"+oModelDCS:GetValue("DCS_PEDIDO")+"'"
			cQuery +=    " AND D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()
			DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
			If (cAliasQry)->(!Eof())
				oModel:SetErrorMessage("A391DCT", ,"A391DCT",,,STR0030,STR0031) // Documento não pode ser estornado, pois possui endereçamento! // Estorne primeiramente o endereçamento.
				lRet := .F.
			EndIf
			(cAliasQry)->(dbCloseArea())
			If lRet .And. oModelDCS:GetValue("DCS_LIBEST") == "2"
				For nI := 1 To oModelDCU:Length()
					oModelDCU:GoLine(nI)
					If oModelDCV:GetValue("DCV_STATUS",1) == "2"
						If oModelDCS:GetValue("DCS_LIBPED") <> "6"
							oModel:SetErrorMessage("A391DCV", ,"A391DCV",,,STR0032,STR0033+"'"+oModelDCS:GetValue("DCS_LIBPED")+"'.") // Documento já está liberado e não pode ser estornado por esta rotina (DC5_LIBPED). // Liberação está definida como DC5_LIBPED =
							lRet := .F.
							Exit
						EndIf
					EndIf
				Next nI
			EndIf
		EndIf
	EndIf
Return lRet
//-------------------------------------------------------------------//
//--------------Realiza o commit do modelo de dados------------------//
//-------------------------------------------------------------------//
Static Function CommitMdl(oModel)
Local lRet := .T.

	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		lRet := FwFormCommit(oModel,,,,{|oModel| bInTTSAtuMVC(oModel)})
	EndIf
Return lRet
//-------------------------------------------------------------------//
//--------------Confirmação do estorno do documento------------------//
//-------------------------------------------------------------------//
Static Function bInTTSAtuMVC(oModel)
Local oModelDCS := oModel:GetModel("A391DCS")
	WmA391GrvE(2,;                                 // nAcao
				oModelDCS:GetValue("DCS_CARGA") ,; // cCarga
				oModelDCS:GetValue("DCS_PEDIDO"),; // cPedido
				,;                                 // cCodVol
				,;                                 // cPrdOri
				,;                                 // cProduto
				,;                                 // cLote
				,;                                 // cSubLote
				oModelDCS:GetValue("DCS_CODMNT"),; // cCodMnt
				,;                                 // nQtdEst
				,;                                 // nRecDCV
				oModelDCS:GetValue("DCS_LIBPED"))  // cLibPed
Return .T.
//-------------------------------------------------------------------//
//-------Função que chama o Estorno do Documento da Montgem----------//
//------quando o usuário está utilizando o sistema via Desktop-------//
//-------------------------------------------------------------------//
Static Function WmA391Esto()
Local aAreaAnt := GetArea()
Local lRet := .T.

	If !DCS->(WMSA391VIC(DCS_CODMNT,DCS_CARGA,DCS_PEDIDO))
		WmsMessage(STR0034,WMSA39101) // "Carga/Pedido possui conferência de expedição, estorne a conferência primeiramente!"
		lRet := .F.
	EndIf

	If lRet
		FWExecView(STR0012,"WMSA391",4,,{||.T.},,,,{||.T.}) // Monitor de Volume
	EndIf

	WMSA391REF()
	RestArea(aAreaAnt)
Return
//-------------------------------------------------------------------//
//----------Estorno por Documento/Volume/Intens do Volume------------//
//-------------------------------------------------------------------//
Function WmA391GrvE(nAcao,cCarga,cPedido,cCodVol,cPrdOri,cProduto,cLote,cSubLote,cCodMnt,nQtdEst,nRecDCV,cLibPed)
Local lRet        := .T.
Local lQtdEst     := .T.
Local lCarga      := WmsCarga(cCarga)
Local oMntVolItem := Nil
Local aAreaDCS    := DCS->(GetArea())
Local aAreaDCT    := DCT->(GetArea())
Local aAreaDCU    := DCU->(GetArea())
Local aAreaDCV    := DCV->(GetArea())
Local cQuery      := ''
Local cAliasQry   := ''
Local nQuant      := 0

Default cCarga   := PadR(cCarga,TamSx3("DCV_CARGA")[1])
Default cPedido  := PadR(cPedido,TamSx3("DCV_PEDIDO")[1])
Default cCodVol  := PadR(cCodVol,TamSx3("DCV_CODVOL")[1])
Default cPrdOri  := PadR(cPrdOri,TamSx3("DCV_PRDORI")[1])
Default cProduto := PadR(cProduto,TamSx3("DCV_CODPRO")[1])
Default cLote    := PadR(cLote,TamSx3("DCV_LOTE")[1])
Default cSubLote := PadR(cSubLote,TamSx3("DCV_SUBLOT")[1])
Default cCodMnt  := PadR(cCodMnt,TamSx3("DCV_CODMNT")[1])
Default nQtdEst  := 0
Default nRecDCV  := 0

	// Verifica se veio quantidade a ser estornada
	lQtdEst := QtdComp(nQtdEst) > 0

	Begin Transaction
		// Liberação do pedido somente quando possui
		If cLibPed $ '5|6'
			// ----------nAcao-----------
			// Estornar Documento
			cQuery := "SELECT DCV.R_E_C_N_O_ RECNODCV"
			cQuery +=  " FROM "+RetSQLName("DCV")+" DCV"
			cQuery += " WHERE DCV.DCV_FILIAL = '"+xFilial("DCV")+"'"
			If lCarga
				cQuery += " AND DCV.DCV_CARGA = '"+cCarga+"'"
			EndIf
			cQuery +=   " AND DCV.DCV_PEDIDO = '"+cPedido+"'"
			cQuery +=   " AND DCV.DCV_CODMNT = '"+cCodMnt+"'"
			cQuery +=   " AND DCV.DCV_STATUS = '2'"
			cQuery +=   " AND DCV.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()
			dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
			Do While (cAliasQry)->(!Eof())
				DCV->(dbGoTo((cAliasQry)->RECNODCV))
				RecLock('DCV',.F.)
				DCV->DCV_STATUS := "1" // Bloqueado
				DCV->(MsUnlock())
				(cAliasQry)->(dbSkip())
			EndDo
			(cAliasQry)->(dbCloseArea())
			// Busca pedidos para bloquear
			cQuery := " SELECT DISTINCT SC9.R_E_C_N_O_ RECNOSC9"
			cQuery +=   " FROM "+RetSQLName("DCT")+" DCT"
			cQuery +=  " INNER JOIN "+RetSQLName("D0I")+" D0I"
			cQuery +=     " ON D0I.D0I_FILIAL = '"+xFilial("D0I")+"'"
			cQuery +=    " AND D0I.D0I_CODMNT = DCT.DCT_CODMNT"
			cQuery +=    " AND D0I.D_E_L_E_T_ = ' '"
			cQuery +="   INNER JOIN "+RetSQLName("SC9")+" SC9"
			cQuery +=     " ON SC9.C9_FILIAL = '"+xFilial("SC9")+"'"
			cQuery +=    " AND SC9.C9_IDDCF = D0I.D0I_IDDCF"
			If lCarga
				cQuery +=" AND SC9.C9_CARGA = DCT.DCT_CARGA"
			EndIf
			cQuery +=    " AND SC9.C9_PEDIDO = DCT.DCT_PEDIDO"
			cQuery +=    " AND SC9.C9_NFISCAL = '"+Space(TamSx3("C9_NFISCAL")[1])+"'"
			cQuery +=    " AND SC9.C9_BLWMS = '05'"
			cQuery +=    " AND SC9.D_E_L_E_T_ = ' '"
			cQuery +=  " WHERE DCT.DCT_FILIAL = '"+xFilial("DCT")+"'"
			If lCarga
				cQuery +=" AND DCT.DCT_CARGA = '"+cCarga+"'"
			EndIf
			cQuery +=    " AND DCT.DCT_PEDIDO = '"+cPedido+"'"
			cQuery +=    " AND DCT.DCT_CODMNT = '"+cCodMnt+"'"
			cQuery +=    " AND DCT.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()
			DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
			Do While (cAliasQry)->(!Eof())
				SC9->(dbGoTo((cAliasQry)->RECNOSC9))
				RecLock('SC9',.F.)
				SC9->C9_BLWMS := '01' // Bloqueio Wms
				SC9->(MsUnlock())
				(cAliasQry)->(dbSkip())
			EndDo
			(cAliasQry)->(dbCloseArea())
		EndIf
		If lRet
			// ----------nAcao-----------
			// [1] - Estornar Volume
			// [2] - Estornar Documento
			// [3] - Estornar Produto Volume
			cQuery := " SELECT DCV.R_E_C_N_O_ RECNODCV"
			cQuery +=   " FROM "+RetSqlName("DCV")+" DCV"
			cQuery +=  " WHERE "
			If nAcao == 3 .And. nRecDCV > 0
				cQuery +=     " DCV.R_E_C_N_O_ = "+cValtoChar(nRecDCV)
			Else
				cQuery +=     " DCV.DCV_FILIAL = '"+xFilial("DCV")+"'"
				cQuery += " AND DCV.DCV_CODMNT = '"+cCodMnt+"'"
				If lCarga
					cQuery += " AND DCV.DCV_CARGA = '"+cCarga+"'"
				EndIf
				cQuery += " AND DCV.DCV_PEDIDO = '"+cPedido+"'"
				If nAcao == 1 .Or. nAcao == 3
					cQuery += " AND DCV.DCV_CODVOL = '"+cCodVol+"'"
				EndIf
				If nAcao == 3
					cQuery += " AND DCV.DCV_PRDORI = '"+cPrdOri+"'"
					cQuery += " AND DCV.DCV_CODPRO = '"+cProduto+"'"
					cQuery += " AND DCV.DCV_LOTE   = '"+cLote+"'"
					cQuery += " AND DCV.DCV_SUBLOT = '"+cSubLote+"'"
				EndIf
				cQuery +=    " AND DCV.D_E_L_E_T_ = ' '"
				cQuery +=  " ORDER BY DCV.DCV_CODVOL,DCV_ITEM,DCV.DCV_PRDORI, DCV.DCV_CODPRO"
			EndIf
			cQuery := ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()
			dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)

			DCT->(DbSetOrder(1)) // DCT_FILIAL+DCT_CODMNT+DCT_CARGA+DCT_PEDIDO+DCT_PRDORI+DCT_CODPRO+DCT_LOTE+DCT_SUBLOT
			DCU->(DbSetOrder(2)) // DCU_FILIAL+DCU_CARGA+DCU_PEDIDO+DCU_CODMNT+DCU_CODVOL
			DCV->(DbSetOrder(3)) // DCV_FILIAL+DCV_CODMNT+DCV_CARGA+DCV_PEDIDO+DCV_CODVOL

			(cAliasQry)->(DbGoTop())
			While (cAliasQry)->(!Eof()) .And. Iif(lQtdEst,QtdComp(nQtdEst)>0,.T.)
				// Posiciona nos registros DCV correspondentes
				DCV->(DbGoTo((cAliasQry)->(RECNODCV)))
				// Calcula a quantidade a ser estornada
				If lQtdEst
					If QtdComp(nQtdEst) >= QtdComp(DCV->DCV_QUANT)
						nQuant := DCV->DCV_QUANT
					Else
						nQuant := nQtdEst
					EndIf
					nQtdEst -= nQuant
				Else
					nQuant := DCV->DCV_QUANT
				EndIf
				// Atualiza as quantidades e status dos Itens do Documento (DCT)
				If oMntVolItem == Nil
					oMntVolItem := WMSDTCMontagemVolumeItens():New()
				EndIf
				oMntVolItem:SetCarga(cCarga)
				oMntVolItem:SetPedido(cPedido)
				oMntVolItem:SetProduto(DCV->DCV_CODPRO)
				oMntVolItem:SetLoteCtl(DCV->DCV_LOTE)
				oMntVolItem:SetNumLote(DCV->DCV_SUBLOT)
				oMntVolItem:SetPrdOri(DCV->DCV_PRDORI)
				// Busca o codigo da montagem de volume
				oMntVolItem:SetCodMnt(DCV->DCV_CODMNT)
				If oMntVolItem:LoadData()
					oMntVolItem:SetQtdEmb(oMntVolItem:GetQtdEmb() - nQuant)
					oMntVolItem:UpdateDCT()
				EndIf
				// Deleta o item do volume
				cCodVol := DCV->DCV_CODVOL
				RecLock('DCV',.F.)
				If QtdComp(DCV->DCV_QUANT - nQuant) == QtdComp(0)
					DCV->(DbDelete())
				Else
					DCV->DCV_QUANT -= nQuant
				EndIf
				DCV->(MsUnlock())
				// Se não existirem mais itens no volume, deleta o volume
				If !DCV->(dbSeek(xFilial('DCV')+cCodMnt+cCarga+cPedido+cCodVol))
					If DCU->(DbSeek(xFilial('DCU')+cCarga+cPedido+cCodMnt+cCodVol))
						RecLock('DCU',.F.)
						DCU->(DbDelete())
						DCU->(MsUnlock())
					EndIf
				EndIf
				(cAliasQry)->(DbSkip())
			EndDo
		EndIf
		If !lRet
			Disarmtransaction()
		EndIf
	End Transaction
	(cAliasQry)->(DbCloseArea())

	RestArea(aAreaDCV)
	RestArea(aAreaDCU)
	RestArea(aAreaDCT)
	RestArea(aAreaDCS)
Return
/*
Verifica se o volume ou o documento possui conferência realizada.
*/
Function WMSA391VIC(cCodMnt,cCarga,cPedido,cVolume)
Local lRet     := .T.
Local cQuery   := ""
Local cAliasDCU:= ""

Default cCodMnt := ""
Default cVolume := ""

	//Verifica se o volume ou o documento possui conferência realizada.
	Do Case
		Case !Empty(cVolume)
			cQuery := " SELECT DCU_CODVOL"
			cQuery +=   " FROM "+RetSqlName('DCU')
			cQuery +=  " WHERE DCU_FILIAL = '"+xFilial('DCU')+"'"
			cQuery +=    " AND DCU_CODVOL = '"+cVolume+"'"
			cQuery +=    " AND DCU_CODMNT = '"+cCodMnt+"'"
			cQuery +=    " AND DCU_STCONF = '2'" //Conferido
			cQuery +=    " AND D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasDCU := GetNextAlias()
			dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDCU,.F.,.T.)
			If (cAliasDCU)->(!Eof())
				lRet := .F.
			EndIf
			(cAliasDCU)->(dbCloseArea())
		OtherWise
			cQuery := " SELECT DCU.DCU_CODVOL"
			cQuery +=   " FROM "+RetSqlName('DCS')+" DCS"
			cQuery +=  " INNER JOIN "+RetSqlName('DCU')+" DCU"
			cQuery +=     " ON DCU.DCU_FILIAL = '"+xFilial('DCU')+"'"
			cQuery +=    " AND DCU.DCU_CARGA  = DCS.DCS_CARGA"
			cQuery +=    " AND DCU.DCU_PEDIDO = DCS.DCS_PEDIDO"
			cQuery +=    " AND DCU.DCU_CODMNT = DCS.DCS_CODMNT"
			cQuery +=    " AND DCU.DCU_STCONF = '2'" //Conferido
			cQuery +=    " AND DCU.D_E_L_E_T_ = ' '"
			cQuery +=  " WHERE DCS.DCS_FILIAL = '"+xFilial('DCU')+"'"
			cQuery +=    " AND DCS.DCS_CODMNT = '"+cCodMnt+"'"
			cQuery +=    " AND DCS.DCS_CARGA  = '"+cCarga+"'"
			cQuery +=    " AND DCS.DCS_PEDIDO = '"+cPedido+"'"
			cQuery +=    " AND DCS.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasDCU := GetNextAlias()
			dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDCU,.F.,.T.)
			If (cAliasDCU)->(!Eof())
				lRet := .F.
			EndIf
			(cAliasDCU)->(dbCloseArea())
	EndCase
Return lRet
