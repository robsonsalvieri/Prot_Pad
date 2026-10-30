#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "WMSA324.CH"

#DEFINE WMSA32401 "WMSA32401"

//--------------------------------------------------
/*/{Protheus.doc} WMSA324
Monitor de Plano de Distribuição
@author amanda.vieira
@since 23/12/2016
@version 1.0
/*/
//--------------------------------------------------
Function WMSA324()
Private nTime     := SuperGetMV('MV_WMSREFS', .F., 10) // Tempo em Segundos para Refresh da tela de Execucao de Servicos (Default = 10 segundos)
Private oBrowse
Private oBrwD0M
Private oTimer

	// Permite efetuar validações, apresentar mensagem e abortar o programa quando desejado
	If !WMSChkPrg(FunName(),"1")
		Return Nil
	EndIf

	If Pergunte('WMSA324',.T.)
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias("D0L")
		oBrowse:SetMenuDef("WMSA324")
		oBrowse:SetDescription(STR0001) // Plano de Distribuição
		oBrowse:DisableDetails()
		oBrowse:SetAmbiente(.F.)
		oBrowse:SetWalkThru(.F.)
		oBrowse:SetFixedBrowse(.T.)
		oBrowse:SetFilterDefault("@"+Filtro())
		oBrowse:SetParam({|| SelFiltro(oBrowse) })
		oBrowse:SetTimer({|| RefreshBrw(oBrowse) }, Iif(nTime<=0, 3600, nTime) * 1000)
		oBrowse:SetIniWindow({||oBrowse:oTimer:lActive := (MV_PAR06 < 4)})
		oBrowse:AddLegend("D0L->D0L_STATUS=='1'",'GREEN' , STR0002) // Aberta
		oBrowse:AddLegend("D0L->D0L_STATUS=='2'",'YELLOW', STR0003) // Em andamento
		oBrowse:AddLegend("D0L->D0L_STATUS=='3'",'BLUE'  , STR0004) // Distribuida
		//oBrowse:AddLegend("D0L->D0L_STATUS=='4'",'WHITE' , STR0005) // Cancelada
		oBrowse:SetProfileID('D0L')
		oBrowse:Activate()
	EndIf

Return Nil

//-------------------------------------------------------------------//
//-------------------------Funcao MenuDEF----------------------------//
//-------------------------------------------------------------------//
Static Function MenuDef()
Local aRotina := {}
	ADD OPTION aRotina TITLE STR0006 ACTION "WMS324Mtor()"				  OPERATION 2 ACCESS 0 // Monitor
	ADD OPTION aRotina TITLE STR0009 ACTION "WMSA324MEN(2)"               OPERATION 3 ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE STR0010 ACTION "WMSA324MEN(3)"               OPERATION 4 ACCESS 0 // Alterar
	ADD OPTION aRotina TITLE STR0011 ACTION "WMSA324MEN(4)"               OPERATION 5 ACCESS 0 // Excluir
Return aRotina

//-------------------------------------------------------------------//
//-------------------------Funcao ModelDef---------------------------//
//-------------------------------------------------------------------//
Static Function ModelDef()
Local oModel    := MPFormModel():New('WMSA324')
Local oStrD0L   := FWFormStruct(1,'D0L')
Local oStrD0M   := FWFormStruct(1,'D0M')
Local oWmsEvent := WMSModelEventWMSA324():New() // Evento de validação e commit customizados

	oStrD0M:SetProperty('D0M_CODPLN',MODEL_FIELD_OBRIGAT,.F.)
	oStrD0M:SetProperty('D0M_QTDDE2',MODEL_FIELD_OBRIGAT,.F.)

	oStrD0M:AddTrigger('D0M_PRODUT','D0M_DPROD',{||.T.},{|| Posicione('SB1',1,xFilial('SB1')+M->D0M_PRODUT,'B1_DESC')})

	oModel:AddFields('A324D0L',,oStrD0L)
	oModel:AddGrid('A324D0M','A324D0L',oStrD0M)
	oModel:SetRelation('A324D0M', { { 'D0M_FILIAL', 'xFilial("D0M")' }, { 'D0M_CODPLN', 'D0L_CODPLN'} }, D0M->(IndexKey(1)) )
	oModel:SetPrimaryKey({'D0L_FILIAL','D0L_CODPLN'})

	oModel:InstallEvent("WMSW324", /*cOwner*/, oWmsEvent)

Return oModel

//-------------------------------------------------------------------//
//-------------------------Funcao ViewDef----------------------------//
//-------------------------------------------------------------------//
Static Function ViewDef()
Local oModel  := ModelDef()
Local oView   := FWFormView():New()
Local oStrD0L := FWFormStruct(2,'D0L')
Local oStrD0M := FWFormStruct(2,'D0M')

	oStrD0L:SetProperty('*'         ,MVC_VIEW_CANCHANGE,.F.)
	oStrD0M:SetProperty('D0M_QTDDE2',MVC_VIEW_CANCHANGE,.F.)
	oStrD0M:SetProperty('D0M_QTDDIS',MVC_VIEW_CANCHANGE,.F.)
	oStrD0M:SetProperty('D0M_QTDDI2',MVC_VIEW_CANCHANGE,.F.)
	oStrD0M:RemoveField('D0M_CODPLN')

	oView:SetModel(oModel)
	oView:AddField('VIEW_D0L', oStrD0L, 'A324D0L')
	oView:AddGrid( 'VIEW_D0M', oStrD0M, 'A324D0M')

	oView:CreateFolder( 'FOLDER1')
	oView:AddSheet('FOLDER1','SHEET1',STR0007) // Lançamentos Demanda

	oView:CreateHorizontalBox( 'BOXD0L',20, /*owner*/, /*lUsePixel*/, 'FOLDER1', 'SHEET1')
	oView:CreateHorizontalBox( 'BOXD0M',80, /*owner*/, /*lUsePixel*/, 'FOLDER1', 'SHEET1')

	oView:SetOwnerView('VIEW_D0L','BOXD0L')
	oView:SetOwnerView('VIEW_D0M','BOXD0M')

	oView:EnableTitleView('VIEW_D0L',STR0001) // Plano distribuição
	oView:EnableTitleView('VIEW_D0M',STR0007) // Lançamentos Demanda

	oView:AddIncrementField('VIEW_D0M','D0M_ITEM')

Return oView

//-------------------------------------------------------------------//
//--------------------Função chamada do MenuDef----------------------//
//-------------------------------------------------------------------//
Function WMSA324MEN(nPos)
Local aRotina := MenuDef()

	nOperation := aRotina[nPos][4]

	If nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_DELETE
		If D0L->D0L_STATUS == "3"
			WmsMessage(STR0008,WMSA32401,1) // "Não é permitido alterar ou excluir Planos de Distribuição com situação igual a 3 - Distribuído."
			Return .F.
		EndIf
	EndIf

	FWExecView(aRotina[nPos][1],"WMSA324",aRotina[nPos][4],,{ || .T. },{ || .T. },0,,{ || .T. },,, )

Return .T.

//-------------------------------------------------------------------//
//--------------------Filtro default do programa---------------------//
//-------------------------------------------------------------------//
Static Function Filtro()
Local cFiltro := ""
	cFiltro :=     " D0L_CODPLN >= '"+MV_PAR01+      "' AND D0L_CODPLN <= '"+MV_PAR02+"'"
	cFiltro += " AND D0L_DATGER >= '"+DTOS(MV_PAR03)+"' AND D0L_DATGER <= '"+DTOS(MV_PAR04)+"'"

	If MV_PAR05 != 5
		cFiltro += " AND D0L_STATUS = '"+AllTrim(Str(MV_PAR05))+"' "
	EndIf
Return cFiltro

//-------------------------------------------------------------------//
//-----------------------------Monitor-------------------------------//
//-------------------------------------------------------------------//
Function WMS324Mtor()
Local oSize      := Nil
Local oDlg       := Nil
Local oMaster    := Nil
Local oFolder    := Nil
Local aFolders   := {}
Local aButtons   := {}
Local aPosSize   := {}
Local nTime      := SuperGetMV('MV_WMSREFS', .F., 10) // Tempo em Segundos para Refresh da tela de Execucao de Servicos (Default = 10 segundos)
Local nOpcA      := 0

	// Calcula as dimensoes dos objetos
	oSize := FwDefSize():New( .T. )  // Com enchoicebar

	// Cria Enchoice
	oSize:AddObject( "MASTER", 100, 60, .T., .F. ) // Adiciona enchoice
	oSize:AddObject( "DETAIL", 100, 80, .T., .T. ) // Adiciona enchoice

	// Dispara o calculo
	oSize:Process()

	// Desenha a dialog
	DEFINE MSDIALOG oDlg TITLE STR0001  FROM ; // Plano de distribuição
		  oSize:aWindSize[1],oSize:aWindSize[2] TO ;
		  oSize:aWindSize[3],oSize:aWindSize[4] PIXEL

	// Cria as variáveis de memória usadas pela Enchoice
	// Monta a Enchoice
	aPosSize := {oSize:GetDimension("MASTER","LININI"),;
				  oSize:GetDimension("MASTER","COLINI"),;
				  oSize:GetDimension("MASTER","LINEND"),;
				  oSize:GetDimension("MASTER","COLEND")}
	oMaster := MsMGet():New("D0L",D0L->(Recno()),2,,,,,aPosSize,,3,,,,oDlg)

	aFolders := {STR0007} // Lançamentos Demanda

	// Monta o Objeto Folder
	aPosSize := {oSize:GetDimension("DETAIL","LININI"),; // Pos.x
	             oSize:GetDimension("DETAIL","COLINI"),; // Pos.y
	             oSize:GetDimension("DETAIL","XSIZE"),;  // Size.x
	             oSize:GetDimension("DETAIL","YSIZE")}   // Size.y
	oFolder := TFolder():New(aPosSize[1],aPosSize[2],aFolders,aFolders,oDlg,,,,.T.,.T.,aPosSize[3],aPosSize[4])

	// Define Browse Documento (D0M)
	oBrwD0M := FWMBrowse():New()
	oBrwD0M:SetOwner(oFolder:aDialogs[1])
	oBrwD0M:SetDescription(STR0007) // Lançamentos Demanda
	oBrwD0M:SetAlias('D0M')
	oBrwD0M:SetAmbiente(.F.)
	oBrwD0M:SetWalkThru(.F.)
	oBrwD0M:SetMenuDef('')
	oBrwD0M:DisableDetails()
	oBrwD0M:SetFixedBrowse(.T.)
	oBrwD0M:SetProfileID('D0M')
	oBrwD0M:SetFilterDefault(" D0M_FILIAL == '"+xFilial('D0M')+"' .AND. D0M_CODPLN == '"+D0L->D0L_CODPLN+"'")
	oBrwD0M:Activate()

	oTimer:= TTimer():New((Iif(nTime <= 0, 3600, nTime) * 1000),{|| WMSA324REF() },oDlg)
	oTimer:Activate()

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpcA := 1,oDlg:End()},{|| nOpcA := 2,oDlg:End()},,aButtons)
Return Nil

//----------------------------------------------------------
/*/{Protheus.doc} WMSA324REF
Função responsável por efetuar a atualização da tela
@author Amanda Rosa Vieira
@version P11
@Since   26/12/2016
@version 2.0
/*/
//----------------------------------------------------------
Static Function WMSA324REF()
	If oBrowse != Nil
		oBrowse:Refresh()
	EndIf
	If oBrwD0M != Nil
		oBrwD0M:Refresh()
	EndIf
Return .T.

//-------------------------------------------------------------------//
//--------------------Seleção do filtro tecla F12--------------------//
//-------------------------------------------------------------------//
Static Function SelFiltro(oBrowse)
Local lRet := .T.

	If (lRet := Pergunte('WMSA324',.T.))
		oBrowse:oTimer:lActive := (MV_PAR06 < 4)
		oBrowse:SetFilterDefault("@"+Filtro())
		oBrowse:Refresh(.T.)
	EndIf

Return lRet

//-------------------------------------------------------------------//
//------------Refresh do Browse para Recarregar a Tela---------------//
//-------------------------------------------------------------------//
Static Function RefreshBrw(oBrowse)
Local nPos := oBrowse:At()

	Pergunte('WMSA324', .F.)
	oBrowse:SetFilterDefault("@"+Filtro())
	If MV_PAR06 == 1
		oBrowse:Refresh(.T.)
	ElseIf MV_PAR06 == 2
		oBrowse:Refresh(.F.)
		oBrowse:GoBottom()
	Else
		oBrowse:Refresh(.F.)
		oBrowse:GoTo(nPos)
	EndIf

Return .T.
