#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#include "RWMAKE.CH"
#INCLUDE "APVT100.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "WMSA412.CH"

#DEFINE WMSA41201 "WMSA41201"
#DEFINE WMSA41202 "WMSA41202"
#DEFINE WMSA41203 "WMSA41203"
#DEFINE WMSA41204 "WMSA41204"
#DEFINE WMSA41205 "WMSA41205"
#DEFINE WMSA41206 "WMSA41206"
#DEFINE WMSA41207 "WMSA41207"
#DEFINE WMSA41208 "WMSA41208"
#DEFINE WMSA41209 "WMSA41209"
#DEFINE WMSA41210 "WMSA41210"
#DEFINE WMSA41211 "WMSA41211"
#DEFINE WMSA41212 "WMSA41212"
#DEFINE WMSA41213 "WMSA41213"
#DEFINE WMSA41214 "WMSA41214"
#DEFINE WMSA41215 "WMSA41215"
#DEFINE WMSA41216 "WMSA41216"
#DEFINE WMSA41217 "WMSA41217"
#DEFINE WMSA41218 "WMSA41218"
#DEFINE WMSA41219 "WMSA41219"
#DEFINE WMSA41220 "WMSA41220"
#DEFINE WMSA41221 "WMSA41221"
#DEFINE WMSA41222 "WMSA41222"

Static oBrwD02, oBrwD03, oBrwD04, oBrwDCU, oBrwDCV

//--------------------------------------------------
/*/{Protheus.doc} WMSA412
Monitor de Conferência de Expedição
@author amanda.vieira
@since 23/12/2016
@version 1.0
/*/
//--------------------------------------------------
Function WMSA412()
Local nTime     := SuperGetMV('MV_WMSREFS', .F., 10) // Tempo em Segundos para Refresh da tela de Execucao de Servicos (Default = 10 segundos)
Local oBrowse
	
	If Pergunte('WMSA412',.T.)
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias("D01")
		oBrowse:SetMenuDef("WMSA412")
		oBrowse:SetDescription(STR0001) //Conferência de Expedição
		oBrowse:DisableDetails()
		oBrowse:SetAmbiente(.F.)
		oBrowse:SetWalkThru(.F.)
		oBrowse:SetFixedBrowse(.T.)
		oBrowse:SetFilterDefault("@"+Filtro())
		oBrowse:AddLegend("D01->D01_STATUS=='1'", "RED"   , STR0002) //Aguardando Conferência
		oBrowse:AddLegend("D01->D01_STATUS=='2'", "YELLOW", STR0003) //Conferência em Andamento
		oBrowse:AddLegend("D01->D01_STATUS=='3'", "GREEN" , STR0004) //Conferido
		oBrowse:SetParam({|| SelFiltro(oBrowse) })
		oBrowse:SetTimer({|| RefreshBrw(oBrowse) }, Iif(nTime<=0, 3600, nTime) * 1000)
		oBrowse:SetIniWindow({||oBrowse:oTimer:lActive := (MV_PAR08 < 4)})
		oBrowse:SetProfileID('D01')
		oBrowse:Activate()
	EndIf
Return Nil
//-------------------------------------------------------------------//
//-------------------------Funcao MenuDEF----------------------------//
//-------------------------------------------------------------------//
Static Function MenuDef()
Local aRotina := {}
	ADD OPTION aRotina TITLE STR0055 ACTION "WMS412Mtor()" OPERATION 2 ACCESS 0 //Monitor
Return aRotina
//-------------------------------------------------------------------//
//-------------------------Funcao ModelDef---------------------------//
//-------------------------------------------------------------------//
Static Function ModelDef()
Local oModel     := MPFormModel():New('WMSA412',/*{|oModel| BeforeCMdl(oModel) }*/,/*{|oModel| ValidMdl(oModel) }*/,/*{|oModel| CommitMdl(oModel)}*/)
Local oStrD01    := FWFormStruct(1,'D01')
Local oStrD02    := FWFormStruct(1,'D02')
Local oStrD03    := FWFormStruct(1,'D03')
Local oStrD04    := FWFormStruct(1,'D04')
Local aTrigger   := {}
Local bStatusD02 := {||,Iif(D02->D02_STATUS=="1",'BR_VERMELHO',Iif(D02->D02_STATUS=="2",'BR_AMARELO','BR_VERDE'))}
Local cCodPro    := D02->D02_CODPRO
Local cLote      := D02->D02_LOTE
Local cSubLot    := D02->D02_SUBLOT

	oStrD01:SetProperty('*',MODEL_FIELD_OBRIGAT,.F.)
	oStrD02:SetProperty('*',MODEL_FIELD_OBRIGAT,.F.)
	oStrD03:SetProperty('*',MODEL_FIELD_OBRIGAT,.F.)
	oStrD04:SetProperty('*',MODEL_FIELD_OBRIGAT,.F.)

	// oStr2:AddField(< cTitulo >, < cTooltip >, < cIdField >, < cTipo >, < nTamanho >, [ nDecimal ], [ bValid ], [ bWhen ], [ aValues ], [ lObrigat ], [ bInit ], < lKey >, [ lNoUpd ], [ lVirtual ], [ cValid ])
	oStrD02:AddField("", "", 'STATUS', 'C', 11, 0,,,,,bStatusD02,,,.T.) //Status //Status da Conferencia

	oModel:AddFields('A412D01',,oStrD01)
	oModel:AddGrid('A412D02','A412D01',oStrD02)
	oModel:SetRelation('A412D02', { { 'D02_FILIAL', 'xFilial("D02")' }, { 'D02_CODEXP', 'D01_CODEXP' }, { 'D02_CARGA', 'D01_CARGA' }, { 'D02_PEDIDO', 'D01_PEDIDO' } }, D02->(IndexKey(1)) )

	oModel:AddGrid('A412D03','A412D01',oStrD03)
	oModel:SetRelation('A412D03', { { 'D03_FILIAL', 'xFilial("D03")' }, { 'D03_CODEXP', 'D01_CODEXP' }, { 'D03_CARGA', 'D01_CARGA' }, { 'D03_PEDIDO', 'D01_PEDIDO' } }, D03->(IndexKey(1)) )

	oModel:addGrid('A412D04','A412D03',oStrD04)
	oModel:SetRelation('A412D04', { { 'D04_FILIAL', 'xFilial("D04")' }, { 'D04_CODEXP', 'D03_CODEXP' }, { 'D04_CARGA', 'D03_CARGA' }, { 'D04_PEDIDO', 'D03_PEDIDO' }, { 'D04_CODOPE', 'D03_CODOPE' } }, D04->(IndexKey(1)) )

	oModel:SetPrimaryKey({'D01_FILIAL', 'D01_CARGA','D01_PEDIDO','D01_CODEXP'})

	If IsInCallStack('EstConfPrd')
		oModel:GetModel( 'A412D02' ):SetLoadFilter({{'D02_CODPRO' ,"'"+cCodPro+"'",1},{'D02_LOTE' ,"'"+cLote+"'",1},{'D02_SUBLOT' ,"'"+cSubLot+"'",1}})
	EndIf

	oModel:GetModel('A412D02'):SetNoInsertLine( .T. )
	oModel:GetModel('A412D02'):SetNoDeleteLine( .T. )
	oModel:GetModel('A412D02'):SetNoUpdateLine( .T. )
	oModel:GetModel('A412D02'):SetOptional(.T.)

	oModel:GetModel('A412D03'):SetNoInsertLine( .T. )
	oModel:GetModel('A412D03'):SetNoDeleteLine( .T. )
	oModel:GetModel('A412D03'):SetNoUpdateLine( .T. )
	oModel:GetModel('A412D03'):SetOptional(.T.)

	oModel:GetModel('A412D04'):SetNoInsertLine( .T. )
	oModel:GetModel('A412D04'):SetNoDeleteLine( .T. )
	oModel:GetModel('A412D04'):SetNoUpdateLine( .T. )
	oModel:GetModel('A412D04'):SetOptional(.T.)

	oModel:SetActivate({|oModel| ActiveMdl(oModel) })
Return oModel
//-------------------------------------------------------------------//
//-------------------------Funcao ViewDef----------------------------//
//-------------------------------------------------------------------//
Static Function ViewDef()
Local oModel  := ModelDef()
Local oView   := FWFormView():New()
Local oStrD01 := FWFormStruct(2,'D01')
Local oStrD02 := FWFormStruct(2,'D02')
Local oStrD03 := FWFormStruct(2,'D03')
Local oStrD04 := FWFormStruct(2,'D04')

	oStrD01:SetProperty('*',MVC_VIEW_CANCHANGE,.F.)
	oStrD02:SetProperty('*',MVC_VIEW_CANCHANGE,.F.)
	oStrD03:SetProperty('*',MVC_VIEW_CANCHANGE,.F.)
	oStrD04:SetProperty('*',MVC_VIEW_CANCHANGE,.F.)

	oStrD02:AddField('STATUS', '01',"","", , 'GET', '@BMP', Nil, /*cLookUp*/,.F., /*cFolder*/, /*cGroup*/, /*aComboValues*/, /*nMaxLenCombo*/, /*cIniBrow*/, .T.) //Status da Conferencia
	oStrD02:RemoveField('D02_STATUS')

	oView:SetModel(oModel)
	oView:AddField('VIEW_D01', oStrD01, 'A412D01')
	oView:AddGrid( 'VIEW_D02', oStrD02, 'A412D02')
	oView:AddGrid( 'VIEW_D03', oStrD03, 'A412D03')
	oView:AddGrid( 'VIEW_D04', oStrD04, 'A412D04')

	oView:CreateFolder( 'FOLDER1')
	oView:AddSheet('FOLDER1','SHEET1',STR0005)  //Documentos
	oView:AddSheet('FOLDER1','SHEET2',STR0006) //Conferência

	oView:CreateHorizontalBox( 'BOXD01',20, /*owner*/, /*lUsePixel*/, 'FOLDER1', 'SHEET1')
	oView:CreateHorizontalBox( 'BOXD02',80, /*owner*/, /*lUsePixel*/, 'FOLDER1', 'SHEET1')
	oView:CreateHorizontalBox( 'BOXD03',30, /*owner*/, /*lUsePixel*/, 'FOLDER1', 'SHEET2')
	oView:CreateHorizontalBox( 'BOXD04',70, /*owner*/, /*lUsePixel*/, 'FOLDER1', 'SHEET2')

	oView:SetOwnerView('VIEW_D01','BOXD01')
	oView:SetOwnerView('VIEW_D02','BOXD02')
	oView:SetOwnerView('VIEW_D03','BOXD03')
	oView:SetOwnerView('VIEW_D04','BOXD04')

	oView:EnableTitleView('VIEW_D01',STR0007) //Conferência de Carga/Pedido
	oView:EnableTitleView('VIEW_D02',STR0008) //Itens Conferidos
	oView:EnableTitleView('VIEW_D03',STR0009) //Operadores da Conferência
	oView:EnableTitleView('VIEW_D04',STR0010) //Itens Conferidos por Operador
Return oView
//-------------------------------------------------------------------//
//--------------------Filtro default do programa---------------------//
//-------------------------------------------------------------------//
Static Function Filtro()
Local cFiltro := ""
	cFiltro := "     D01_CARGA  >= '"+   MV_PAR01   +"' AND D01_CARGA  <= '"+MV_PAR02+"'"
	cFiltro += " AND D01_PEDIDO >= '"+   MV_PAR03   +"' AND D01_PEDIDO <= '"+MV_PAR04+"'"
	cFiltro += " AND D01_DATA   >= '"+DTOS(MV_PAR05)+"' AND D01_DATA   <= '"+DTOS(MV_PAR06)+"'"
Return cFiltro
//-------------------------------------------------------------------//
//--------------------Seleção do filtro tecla F12--------------------//
//-------------------------------------------------------------------//
Static Function SelFiltro(oBrowse)
Local lRet := .T.

	If (lRet := Pergunte('WMSA412',.T.))
		oBrowse:oTimer:lActive := (MV_PAR08 < 4)
		oBrowse:SetFilterDefault("@"+Filtro())
		oBrowse:Refresh(.T.)
	EndIf
Return lRet
//-------------------------------------------------------------------//
//------------Refresh do Browse para Recarregar a Tela---------------//
//-------------------------------------------------------------------//
Static Function RefreshBrw(oBrowse)
Local nPos := oBrowse:At()
	If MV_PAR08 == 1
		oBrowse:Refresh(.T.)
	ElseIf MV_PAR08 == 2
		oBrowse:Refresh(.F.)
		oBrowse:GoBottom()
	Else
		oBrowse:Refresh(.F.)
		oBrowse:GoTo(nPos)
	EndIf
Return .T.

Function WMSA412MNT()
Return WMS412Mtor(2)
//-------------------------------------------------------------------//
//-----------------------------Monitor-------------------------------//
//-------------------------------------------------------------------//
Function WMS412Mtor(nAcao)
Local aCoors     := FWGetDialogSize(oMainWnd)
Local oSize      := Nil
Local oDlg       := Nil
Local oMaster    := Nil
Local oFolder    := Nil
Local oLayer     := Nil
Local oPanelLeft := Nil
Local oPanelRight:= Nil
Local oRelation  := Nil
Local aFolders   := {}
Local aButtons   := {}
Local aPosSize   := {}
Local nTime      := SuperGetMV('MV_WMSREFS', .F., 10) // Tempo em Segundos para Refresh da tela de Execucao de Servicos (Default = 10 segundos)
Local oTimer     := Nil
Local nOpcA      := 0
Default nAcao := 1

	// Calcula as dimensoes dos objetos
	oSize := FwDefSize():New( .T. )  // Com enchoicebar

	// Cria Enchoice
	oSize:AddObject( "MASTER", 100, 85, .T., .F. ) // Adiciona enchoice
	oSize:AddObject( "DETAIL", 100, 60, .T., .T. ) // Adiciona enchoice

	// Dispara o calculo
	oSize:Process()

	// Desenha a dialog
	DEFINE MSDIALOG oDlg TITLE STR0011 FROM ; //Monitor Conferência de Expedição
		  oSize:aWindSize[1],oSize:aWindSize[2] TO ;
		  oSize:aWindSize[3],oSize:aWindSize[4] PIXEL

	// Cria as variáveis de memória usadas pela Enchoice
	// Monta a Enchoice
	aPosSize := {oSize:GetDimension("MASTER","LININI"),;
				  oSize:GetDimension("MASTER","COLINI"),;
				  oSize:GetDimension("MASTER","LINEND"),;
				  oSize:GetDimension("MASTER","COLEND")}
	oMaster := MsMGet():New("D01",D01->(Recno()),2,,,,,aPosSize,,3,,,,oDlg)

	aFolders := {STR0012,STR0053,STR0054} // Documento // Itens Conferidos // Volumes Conferidos

	// Monta o Objeto Folder
	aPosSize := {oSize:GetDimension("DETAIL","LININI"),; // Pos.x
	             oSize:GetDimension("DETAIL","COLINI"),; // Pos.y
	             oSize:GetDimension("DETAIL","XSIZE"),;  // Size.x
	             oSize:GetDimension("DETAIL","YSIZE")}   // Size.y
	oFolder := TFolder():New(aPosSize[1],aPosSize[2],aFolders,aFolders,oDlg,,,,.T.,.T.,aPosSize[3],aPosSize[4])

	// Define Browse Documento (D02)
	oBrwD02 := FWMBrowse():New()
	oBrwD02:SetOwner(oFolder:aDialogs[1])
	oBrwD02:SetDescription(STR0014) //Itens dos Docs. na Conf. Expedição
	oBrwD02:SetAlias('D02')
	oBrwD02:SetFilterDefault("@ D02_FILIAL = '"+xFilial('D02')+"' AND D02_CODEXP = '"+D01->D01_CODEXP+"'")
	oBrwD02:SetMenuDef('')
	If nAcao == 1
		oBrwD02:AddButton(STR0015, {|| oTimer:DeActivate(), EstConfer(), oTimer:Activate()},, 4, 0)  //Estornar Produto
		oBrwD02:AddButton(STR0016, {|| oTimer:DeActivate(), EstConfPrd(), oTimer:Activate()},, 4, 0) //Estornar Produto
		oBrwD02:AddButton(STR0017, {|| oTimer:DeActivate(), LibFatManu(), oTimer:Activate()},, 4, 0) //Liberação Fat. Manual
	EndIf
	oBrwD02:AddLegend("D02->D02_STATUS=='1'", "RED"   ,STR0002) //Aguardando Conferência
	oBrwD02:AddLegend("D02->D02_STATUS=='2'", "YELLOW",STR0003) //Conferencia em Andamento
	oBrwD02:AddLegend("D02->D02_STATUS=='3'", "GREEN" ,STR0004) //Finalizado
	oBrwD02:DisableDetails()
	oBrwD02:SetAmbiente(.F.)
	oBrwD02:SetWalkThru(.F.)
	oBrwD02:SetFixedBrowse(.T.)
	oBrwD02:SetProfileID('D02')
	oBrwD02:Activate()

	//Layer Conferência
	oLayer := FWLayer():New()
	oLayer:Init(oFolder:aDialogs[2],.F.,.T.)

	oLayer:AddCollumn("LEFT",50,.F.)
	oLayer:AddCollumn("RIGHT",50,.F.)

	oPanelLeft := oLayer:GetColPanel('LEFT')
	oPanelRight := oLayer:GetColPanel('RIGHT')

	// Define Browse Operadores (D03)
	oBrwD03 := FWMBrowse():New()
	oBrwD03:SetOwner(oPanelLeft)
	oBrwD03:SetDescription(STR0018) //Operadores
	oBrwD03:SetAlias('D03')
	oBrwD03:SetFilterDefault("@ D03_FILIAL = '"+xFilial('D03')+"' AND D03_CODEXP = '"+D01->D01_CODEXP+"'")
	oBrwD03:SetMenuDef('')
	If nAcao == 1
		oBrwD03:AddButton(STR0019, {|| oTimer:DeActivate(), EstConfOpe(), oTimer:Activate()},, 4, 0) //Estornar Conf. Operador
	EndIf
	oBrwD03:SetAmbiente(.F.)
	oBrwD03:SetWalkThru(.F.)
	oBrwD03:DisableDetails()
	oBrwD03:SetFixedBrowse(.T.)
	oBrwD03:SetProfileID('D03')
	oBrwD03:Activate()

	// Define Browse Produtos (D04)
	oBrwD04 := FWMarkBrowse():New()
	oBrwD04:SetOwner(oPanelRight)
	oBrwD04:SetAlias('D04')
	oBrwD04:SetMenuDef('')
	oBrwD04:SetAmbiente(.F.)
	oBrwD04:SetWalkThru(.F.)
	oBrwD04:DisableDetails()
	oBrwD04:SetFixedBrowse(.T.)
	oBrwD04:SetDescription(STR0020) //Itens Conferidos
	oBrwD04:SetProfileID('D04')
	oBrwD04:Activate()

	// Relacionamento browse Itens com Operadores
	oRelation := FWBrwRelation():New()
	oRelation:AddRelation(oBrwD03,oBrwD04,{ {"D04_FILIAL","xFilial('D04')"},{"D04_CODEXP","D03_CODEXP"},{"D04_CARGA","D03_CARGA"},{"D04_PEDIDO","D03_PEDIDO"},{"D04_CODOPE","D03_CODOPE"}})
	oRelation:Activate()

	//Layer Conferência
	oLayer := FWLayer():New()
	oLayer:Init(oFolder:aDialogs[3],.F.,.T.)

	oLayer:AddCollumn("LEFT",50,.F.)
	oLayer:AddCollumn("RIGHT",50,.F.)

	oPanelLeft := oLayer:GetColPanel('LEFT')
	oPanelRight := oLayer:GetColPanel('RIGHT')

	// Define Browse Volume (DCU)
	oBrwDCU := FWMBrowse():New()
	oBrwDCU:SetOwner(oPanelLeft)
	oBrwDCU:SetDescription(STR0045) //Volume
	oBrwDCU:SetAlias('DCU')
	oBrwDCU:SetFilterDefault("@ DCU_FILIAL = '"+xFilial('DCU')+"' AND DCU_CODMNT = '"+FiltraCdMnt()+"' AND DCU_STCONF = '2'")
	oBrwDCU:SetMenuDef('')
	If nAcao == 1
		oBrwDCU:AddButton(STR0052, {|oBrwDCU| oTimer:DeActivate(), EstVolume(oBrwDCU), oTimer:Activate()},, 4, 0) //Estorna Conf. Volume
	EndIf
	oBrwDCU:SetAmbiente(.F.)
	oBrwDCU:SetWalkThru(.F.)
	oBrwDCU:DisableDetails()
	oBrwDCU:SetFixedBrowse(.T.)
	oBrwDCU:SetProfileID('DCU')
	oBrwDCU:Activate()

	// Define Browse Produtos (DCV)
	oBrwDCV := FWMBrowse():New()
	oBrwDCV:SetOwner(oPanelRight)
	oBrwDCV:SetAlias('DCV')
	oBrwDCV:SetAmbiente(.F.)
	oBrwDCV:SetWalkThru(.F.)
	oBrwDCV:SetMenuDef('')
	oBrwDCV:DisableDetails()
	oBrwDCV:SetFixedBrowse(.T.)
	oBrwDCV:SetDescription(STR0048) //Itens do Volume
	oBrwDCV:SetProfileID('DCV')
	oBrwDCV:Activate()

	// Relacionamento Browse Itens com Volumes
	oRelation := FWBrwRelation():New()
	oRelation:AddRelation(oBrwDCU,oBrwDCV,{ {"DCV_FILIAL","xFilial('DCV')"},{"DCV_CODVOL","DCU_CODVOL"} })
	oRelation:Activate()

	oTimer:= TTimer():New((Iif(nTime <= 0, 3600, nTime) * 1000),{|| WMSA412REF() },oDlg)
	oTimer:Activate()

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpcA := 1,oDlg:End()},{|| nOpcA := 2,oDlg:End()},,aButtons)
Return Nil
//----------------------------------------------------------
/*/{Protheus.doc} WMSA412REF
Função responsável por efetuar a atualização da tela
@author Amanda Rosa Vieira
@version P11
@Since   26/12/2016
@version 2.0
/*/
//----------------------------------------------------------
Static Function WMSA412REF()
	oBrwD02:Refresh()
	oBrwD03:Refresh()
	oBrwD04:Refresh()
	oBrwDCU:Refresh()
	oBrwDCV:Refresh()
Return .T.
//----------------------------------------------------------
/*/{Protheus.doc} EstConfer
Função responsável por estornar toda a conferência
@author Amanda Rosa Vieira
@version P11
@Since   26/12/2016
@version 2.0
/*/
//----------------------------------------------------------
Static Function EstConfer()
Local lRet     := .T.
Local lOk      := .F.
Local aAreaD01 := D02->(GetArea())
Local aAreaD02 := D02->(GetArea())
Local aAreaD03 := D02->(GetArea())
Local aAreaD04 := D04->(GetArea())
Local aAreaDCU := DCU->(GetArea())
Local aAreaSC9 := SC9->(GetArea())
Local aDados   := {}
Local cAliasD04:= Nil

	If D01->D01_STATUS == "1"
		WmsMessage(STR0021,WMSA41206) //Status da conferência não permite o estorno!
		lRet := .F.
	EndIf
	//Valida se não possui volume
	If lRet
		//Valida se o pedido já encontra-se faturado
		If A412VldFat(D01->D01_CODEXP,D01->D01_CARGA,D01->D01_PEDIDO)
			FWExecView(STR0022,"WMSA412",4,,,{||lOk := .T.},,,{||.T.}) //Conferência de Expedição
		EndIf
	EndIf
	If lOk
		Begin Transaction
			//Monta array para chamar função de estorno
			cAliasD04 := GetNextAlias()
			BeginSql Alias cAliasD04
				SELECT D04_CODPRO,
						D04_QTCONF,
						D04_CARGA,
						D04_PEDIDO,
						D04_LOTE,
						D04_SUBLOT,
						D04_ITEM,
						D04_SEQUEN,
						D04_PRDORI,
						D04_CODEXP
				FROM %Table:D04% D04
				WHERE D04.D04_FILIAL = %xFilial:D04%
				AND D04.D04_CODEXP = %Exp:D01->D01_CODEXP%
				AND D04.D04_CARGA = %Exp:D01->D01_CARGA%
				AND D04.D04_PEDIDO = %Exp:D01->D01_PEDIDO%
				AND D04.%NotDel%
			EndSql
			Do While (cAliasD04)->(!EoF())
				AAdd(aDados,{(cAliasD04)->D04_CODPRO,;    //Código do produto
								0,;                       //Quantidade já conferida
								(cAliasD04)->D04_QTCONF,; //Quantidade do Produto
								(cAliasD04)->D04_CARGA,;  //Carga
								(cAliasD04)->D04_PEDIDO,; //Pedido
								(cAliasD04)->D04_LOTE,;   //Lote
								(cAliasD04)->D04_SUBLOT,; //Sub-lote
								(cAliasD04)->D04_ITEM,;   //Item
								(cAliasD04)->D04_SEQUEN,; //Sequência
								(cAliasD04)->D04_PRDORI,; //Produto Origem
								"" ,;                     //Código do Volume
								(cAliasD04)->D04_CODEXP}) //Código de Expedição

				(cAliasD04)->(dbSkip())
			EndDo
			(cAliasD04)->(dbCloseArea())
			WMS102GrvE(,,,,,,,,,,,aDados)
		End Transaction
	EndIf
	RestArea(aAreaD01)
	RestArea(aAreaD02)
	RestArea(aAreaD03)
	RestArea(aAreaD04)
	RestArea(aAreaDCU)
	RestArea(aAreaSC9)
	WMSA412REF()
Return
//----------------------------------------------------------
/*/{Protheus.doc} EstConfPrd
Função responsável por estornar a conferência do produto
@author Amanda Rosa Vieira
@version P11
@Since   26/12/2016
@version 2.0
/*/
//----------------------------------------------------------
Static Function EstConfPrd()
local lRet      := .T.
Local lOk       := .F.
Local aAreaD01  := D01->(GetArea())
Local aAreaD02  := D02->(GetArea())
Local aAreaD03  := D03->(GetArea())
Local aAreaD04  := D03->(GetArea())
Local aAreaDCU  := DCU->(GetArea())
Local aAreaSC9  := SC9->(GetArea())
Local aDados    := {}
Local oProdComp := Nil
Local cAliasD04 := Nil
Local nRecnoD02 := D02->(Recno())
	If D02->D02_STATUS == '1'
		WmsMessage(STR0022,WMSA41207) //Status da conferência não permite o estorno!
		lRet := .F.
	EndIf
	If lRet
		If A412VldFat(D01->D01_CODEXP,D01->D01_CARGA,D01->D01_PEDIDO)
			FWExecView(STR0023,"WMSA412",4,,,{||lOk := .T.},,,{||.T.}) //Conferência de Expedição Produto
		EndIf
	EndIF
	If lOk
		Begin Transaction
			D02->(dbGoTo(nRecnoD02))
			// Verifica se o produto é um pai
			oProdComp:= WMSDTCProdutoComponente():New()
			oProdComp:SetProduto(D02->D02_CODPRO)
			oProdComp:SetPrdOri(D02->D02_PRDORI)
			lPai := oProdComp:IsDad()
			//Ajusta status da conferência da tabela de produtos por operador
			cAliasD04  := GetNextAlias()
			If !Empty(D02->D02_CARGA)
				If lPai
					BeginSql Alias cAliasD04
						SELECT D04_CODPRO,
								D04_QTCONF,
								D04_CARGA,
								D04_PEDIDO,
								D04_LOTE,
								D04_SUBLOT,
								D04_ITEM,
								D04_SEQUEN,
								D04_PRDORI,
								D04_CODEXP
						FROM %Table:D04% D04
						WHERE D04.D04_FILIAL = %xFilial:D04%
						AND D04.D04_CODEXP = %Exp:D02->D02_CODEXP%
						AND D04.D04_CARGA = %Exp:D02->D02_CARGA%
						AND D04.D04_PEDIDO = %Exp:D02->D02_PEDIDO%
						AND D04.D04_PRDORI = %Exp:D02->D02_PRDORI%
						AND D04.D04_LOTE = %Exp:D02->D02_LOTE%
						AND D04.D04_SUBLOT = %Exp:D02->D02_SUBLOT%
						AND D04.%NotDel%
					EndSql
				Else
					BeginSql Alias cAliasD04
						SELECT D04_CODPRO,
								D04_QTCONF,
								D04_CARGA,
								D04_PEDIDO,
								D04_LOTE,
								D04_SUBLOT,
								D04_ITEM,
								D04_SEQUEN,
								D04_PRDORI,
								D04_CODEXP
						FROM %Table:D04% D04
						WHERE D04.D04_FILIAL = %xFilial:D04%
						AND D04.D04_CODEXP = %Exp:D02->D02_CODEXP%
						AND D04.D04_CARGA = %Exp:D02->D02_CARGA%
						AND D04.D04_PEDIDO = %Exp:D02->D02_PEDIDO%
						AND D04.D04_PRDORI = %Exp:D02->D02_PRDORI%
						AND D04.D04_CODPRO = %Exp:D02->D02_CODPRO%
						AND D04.D04_LOTE = %Exp:D02->D02_LOTE%
						AND D04.D04_SUBLOT = %Exp:D02->D02_SUBLOT%
						AND D04.%NotDel%
					EndSql
				EndIf
			Else
				If lPai
					BeginSql Alias cAliasD04
						SELECT D04_CODPRO,
								D04_QTCONF,
								D04_CARGA,
								D04_PEDIDO,
								D04_LOTE,
								D04_SUBLOT,
								D04_ITEM,
								D04_SEQUEN,
								D04_PRDORI,
								D04_CODEXP
						FROM %Table:D04% D04
						WHERE D04.D04_FILIAL = %xFilial:D04%
						AND D04.D04_CODEXP = %Exp:D02->D02_CODEXP%
						AND D04.D04_PEDIDO = %Exp:D02->D02_PEDIDO%
						AND D04.D04_PRDORI = %Exp:D02->D02_PRDORI%
						AND D04.D04_LOTE = %Exp:D02->D02_LOTE%
						AND D04.D04_SUBLOT = %Exp:D02->D02_SUBLOT%
						AND D04.%NotDel%
					EndSql
				Else
					BeginSql Alias cAliasD04
						SELECT D04_CODPRO,
								D04_QTCONF,
								D04_CARGA,
								D04_PEDIDO,
								D04_LOTE,
								D04_SUBLOT,
								D04_ITEM,
								D04_SEQUEN,
								D04_PRDORI,
								D04_CODEXP
						FROM %Table:D04% D04
						WHERE D04.D04_FILIAL = %xFilial:D04%
						AND D04.D04_CODEXP = %Exp:D02->D02_CODEXP%
						AND D04.D04_PEDIDO = %Exp:D02->D02_PEDIDO%
						AND D04.D04_PRDORI = %Exp:D02->D02_PRDORI%
						AND D04.D04_CODPRO = %Exp:D02->D02_CODPRO%
						AND D04.D04_LOTE = %Exp:D02->D02_LOTE%
						AND D04.D04_SUBLOT = %Exp:D02->D02_SUBLOT%
						AND D04.%NotDel%
					EndSql
				EndIf
			EndIf
			Do While (cAliasD04)->(!EoF())
				AAdd(aDados,{(cAliasD04)->D04_CODPRO,;    //Código do produto
								0,;                       //Quantidade já conferida
								(cAliasD04)->D04_QTCONF,; //Quantidade do Produto
								(cAliasD04)->D04_CARGA,;  //Carga
								(cAliasD04)->D04_PEDIDO,; //Pedido
								(cAliasD04)->D04_LOTE,;   //Lote
								(cAliasD04)->D04_SUBLOT,; //Sub-lote
								(cAliasD04)->D04_ITEM,;   //Item
								(cAliasD04)->D04_SEQUEN,; //Sequência
								(cAliasD04)->D04_PRDORI,; //Produto Origem
								"" ,;                     //Código do Volume
								(cAliasD04)->D04_CODEXP}) //Código de Expedição
				(cAliasD04)->(dbSkip())
			EndDo
			(cAliasD04)->(dbCloseArea())
			WMS102GrvE(,,,,,,,,,,,aDados)
		End Transaction
	EndIf
	RestArea(aAreaD01)
	RestArea(aAreaD02)
	RestArea(aAreaD03)
	RestArea(aAreaD04)
	RestArea(aAreaDCU)
	RestArea(aAreaSC9)
	WMSA412REF()
Return
//----------------------------------------------------------
/*/{Protheus.doc} EstConfOpe
Função responsável por estornar as conferências do operador
@author Amanda Rosa Vieira
@version P11
@Since   26/12/2016
@version 2.0
/*/
//----------------------------------------------------------
Static Function EstConfOpe()
Local aAreaAnt := GetArea()
Local lRet     := .T.

	If D01->D01_STATUS == '1' //Aguardando Conferência
		WmsMessage(STR0021,WMSA41220) //Status da conferência não permite o estorno!
		lRet := .F.
	EndIf
	If lRet
		//Valida se a conferência foi realizada por volume e se o pedido encontra-se liberado
		lRet := A412VldFat(D01->D01_CODEXP,D01->D01_CARGA,D01->D01_PEDIDO)
	EndIf
	If lRet
		FWExecView(STR0024,"WMSA412A",4,,{||.T.},,,,{||.T.}) //Conferência de Expedição Operador
	EndIf
	WMSA412REF()
	RestArea(aAreaAnt)
Return
//----------------------------------------------------------
/*/{Protheus.doc} ActiveMdl
Realiza alguma alteração no modelo
@author Amanda Rosa Vieira
@version P11
@Since   26/12/2016
@version 2.0
/*/
//----------------------------------------------------------
Static Function ActiveMdl(oModel)
	oModel:GetModel('A412D02'):SetNoUpdateLine( .F. )
	oModel:GetModel("A412D02"):SetValue("D02_QTORIG", oModel:GetModel("A412D02"):GetValue("D02_QTORIG"))
	oModel:GetModel('A412D02'):SetNoUpdateLine( .T. )
Return .T.
//----------------------------------------------------------
/*/{Protheus.doc} LibFatManu
Liberação para faturamento manual
@author Amanda Rosa Vieira
@version P11
@Since   26/12/2016
@version 2.0
/*/
//----------------------------------------------------------
Static Function LibFatManu()
Local lRet      := .T.
Local lCarga    := WmsCarga(D01->D01_CARGA)
Local aAreaSC9  := SC9->(GetArea())
Local cAliasD01 := Nil
Local cAliasSC9 := Nil
	If D01->D01_LIBPED != '4'
		WmsMessage(STR0025,WMSA41201,5,,,STR0026) // A liberação do pedido para o faturamento não está parametrizada para ser manual. // Verifique a parametrização do serviço de expedição no cadastro de Serviços x Tarefas (DC5).
		lRet := .F.
	Else
		cAliasD01 := GetNextAlias()
		If lCarga
			BeginSql Alias cAliasD01
				SELECT D01.D01_LIBPED,
						D01.D01_STATUS
				FROM %Table:D01% D01
				WHERE D01.D01_FILIAL = %xFilial:D01%
				AND D01.D01_CARGA  = %Exp:D01->D01_CARGA%
				AND D01.D01_CODEXP = %Exp:D01->D01_CODEXP%
				AND D01.D01_PEDIDO = %Exp:D01->D01_PEDIDO%
				AND D01.D01_STATUS <> '3'
				AND D01.%NotDel%
			EndSql
		Else
			BeginSql Alias cAliasD01
				SELECT D01.D01_LIBPED,
						D01.D01_STATUS
				FROM %Table:D01% D01
				WHERE D01.D01_FILIAL = %xFilial:D01%
				AND D01.D01_CODEXP = %Exp:D01->D01_CODEXP%
				AND D01.D01_PEDIDO = %Exp:D01->D01_PEDIDO%
				AND D01.D01_STATUS <> '3'
				AND D01.%NotDel%
			EndSql
		EndIf
		If (cAliasD01)->(!EoF())
			WmsMessage(STR0027,WMSA41202,5,,,STR0028) //Primeiro confira todos os produtos da carga/pedido para realizar a liberação.
			lRet := .F.
		EndIf
		(cAliasD01)->(dbCloseArea())
	EndIf
	If lRet
		cAliasSC9 := GetNextAlias()
		If lCarga
			BeginSql Alias cAliasSC9
				SELECT SC9.R_E_C_N_O_ RECNOSC9,
						SC9.C9_BLWMS
				FROM %Table:SC9% SC9
				WHERE SC9.C9_FILIAL = %xFilial:SC9%
				AND SC9.C9_CARGA  = %Exp:D01->D01_CARGA%
				AND SC9.C9_PEDIDO = %Exp:D01->D01_PEDIDO%
				AND SC9.C9_NFISCAL = '  '
				AND SC9.C9_BLWMS   = '01'
				AND SC9.%NotDel%
			EndSql
		Else
			BeginSql Alias cAliasSC9
				SELECT SC9.R_E_C_N_O_ RECNOSC9,
						SC9.C9_BLWMS
				FROM %Table:SC9% SC9
				WHERE SC9.C9_FILIAL = %xFilial:SC9%
				AND SC9.C9_PEDIDO = %Exp:D01->D01_PEDIDO%
				AND SC9.C9_NFISCAL = '  '
				AND SC9.C9_BLWMS   = '01'
				AND SC9.%NotDel%
			EndSql
		EndIf
		If (cAliasSC9)->(EoF())
			WmsMessage(STR0035,WMSA41203,5,,,"") //O pedido/carga já encontra-se liberado ou faturado.
			lRet := .F.
		Else
			If WmsMessage(IIf(lCarga,WmsFmtMsg(STR0029,{{"[VAR01]",D01->D01_CARGA}}),WmsFmtMsg(STR0030,{{"[VAR01]",D01->D01_PEDIDO}})),WMSA41205,3) //Confirma liberação da carga [VAR01]? //Confirma liberação do pedido [VAR01]?
				Do While (cAliasSC9)->(!EoF())
					SC9->(DbGoTo((cAliasSC9)->RECNOSC9))
					RecLock("SC9",.F.)
					SC9->C9_BLWMS := "05"
					SC9->(MsUnLock())
					(cAliasSC9)->(dbSkip())
				EndDo
				(cAliasSC9)->(dbCloseArea())
				WmsMessage(Iif(lCarga,WmsFmtMsg(STR0031,{{"[VAR01]",D01->D01_CARGA}}),WmsFmtMsg(STR0032,{{"[VAR01]",D01->D01_PEDIDO}})),WMSA41204) //Carga [VAR01] liberada. //Pedido [VAR01] liberado.
			EndIf
		EndIf
	EndIf
	RestArea(aAreaSC9)
Return .T.
//----------------------------------------------------------
/*/{Protheus.doc} A412VldFat
Valida se a Carga/Pedido/Volume encontra-se faturado
@author Amanda Rosa Vieira
@version P11
@Since   26/12/2016
@version 2.0
/*/
//----------------------------------------------------------
Function A412VldFat(cCodExp,cCarga,cPedido,lColetor,cVolume)
Local lRet      := .T.
Local aAreaAnt  := GetArea()
Local cAliasQry := Nil

	If !Empty(cVolume)
		//Valida se algum pedido do volume encontra-se faturado
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT D04.D04_PEDIDO
			FROM %Table:DCV% DCV
			INNER JOIN %Table:D04% D04
			ON D04.D04_FILIAL = %xFilial:D04%
			AND D04.D04_PEDIDO = DCV.DCV_PEDIDO
			AND D04.D04_ITEM = DCV.DCV_ITEM
			AND D04.D04_SEQUEN = DCV.DCV_SEQUEN
			AND D04.D04_PRDORI = DCV.DCV_PRDORI
			AND D04.%NotDel%
			INNER JOIN %Table:SC9% SC9
			ON SC9.C9_FILIAL = %xFilial:SC9%
			AND SC9.C9_PEDIDO = DCV.DCV_PEDIDO
			AND SC9.C9_ITEM = DCV.DCV_ITEM
			AND SC9.C9_SEQUEN = DCV.DCV_SEQUEN
			AND SC9.C9_PRODUTO = DCV.DCV_PRDORI
			AND SC9.C9_NFISCAL <> '  '
			AND SC9.%NotDel%
			INNER JOIN %Table:D0H% D0H
			ON D0H.D0H_FILIAL = %xFilial:D0H%
			AND D0H.D0H_CODEXP = D04.D04_CODEXP
			AND D0H.D0H_IDDCF = SC9.C9_IDDCF
			AND D0H.%NotDel%
			INNER JOIN %Table:DCS% DCS
			ON DCS.DCS_FILIAL = %xFilial:DCS%
			AND DCS.DCS_CODMNT = DCV.DCV_CODMNT
			AND DCS.DCS_CARGA = DCV.DCV_CARGA
			AND DCS.DCS_PEDIDO = DCV.DCV_PEDIDO
			AND DCS.DCS_LIBEST = '2' // Somente se não permite estorno
			AND DCS.%NotDel%
			WHERE DCV.DCV_FILIAL = %xFilial:DCV%
			AND DCV.DCV_CODVOL = %Exp:cVolume%
			AND DCV.%NotDel%
		EndSql
		If (cAliasQry)->(!EoF())
			WMSVTAviso(WMSA41215,WmsFmtMsg(STR0043,{{"[VAR01]",(cAliasQry)->D04_PEDIDO},{"[VAR02]",cVolume}}))//"O pedido [VAR01] do volume [VAR02] já encontra-se faturado."
			lRet := .F.
		EndIf
	Else
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT D04_ITEM,D04_SEQUEN
			FROM %Table:D04% D04
			INNER JOIN %Table:SC9% SC9
			ON SC9.C9_FILIAL = %xFilial:SC9%
			AND SC9.C9_PEDIDO = D04.D04_PEDIDO
			AND SC9.C9_ITEM = D04.D04_ITEM
			AND SC9.C9_SEQUEN  = D04.D04_SEQUEN
			AND SC9.C9_PRODUTO = D04.D04_PRDORI
			AND SC9.C9_NFISCAL <> '  '
			AND SC9.%NotDel%
			INNER JOIN %Table:D0H% D0H
			ON D0H.D0H_FILIAL = %xFilial:D0H%
			AND D0H.D0H_CODEXP = D04.D04_CODEXP
			AND D0H.D0H_IDDCF = SC9.C9_IDDCF
			AND D0H.%NotDel%
			INNER JOIN %Table:D01% D01
			ON D01.D01_FILIAL = %xFilial:D01%
			AND D01.D01_CODEXP = D04.D04_CODEXP
			AND D01.D01_CARGA = D04.D04_CARGA
			AND D01.D01_PEDIDO = D04.D04_PEDIDO
			AND D01.D01_LIBEST = '2' // Somente se não permite estorno
			AND D01.%NotDel%
			WHERE D04.D04_FILIAL = %xFilial:D04%
			AND D04.D04_CODEXP = %Exp:cCodExp%
			AND D04.D04_CARGA = %Exp:cCarga%
			AND D04.D04_PEDIDO = %Exp:cPedido%
			AND D04.%NotDel%
		EndSql
		If (cAliasQry)->(!EoF())
			IF lColetor
				WMSVTAviso(WMSA41212,STR0039) //Não é possível realizar o estorno para pedidos já faturados e que a liberação ocorreu na Conferência de Expedição.
			Else
				WmsMessage(STR0039,WMSA41209,5,,,STR0042) //Não é possível realizar o estorno para pedidos já faturados e que a liberação ocorreu na Conferência de Expedição.// Estorne o Faturamento
			EndIf
			lRet := .F.
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf
	RestArea(aAreaAnt)
Return lRet
//----------------------------------------------------------
/*/{Protheus.doc} EstVolume
Função responsável por estornar as conferências do operador
@author Amanda Rosa Vieira
@version P11
@Since   26/12/2016
@version 2.0
/*/
//----------------------------------------------------------
Static Function EstVolume(oBrwDCU)
Local aAreaAnt := GetArea()
Local lRet     := .T.

	If DCU->DCU_STCONF == '1' //Não Conferido
		WmsMessage(STR0049,WMSA41221) //O volume ainda não foi conferido, portanto não pode ser estornado!
		lRet := .F.
	ElseIf DCU->DCU_STCONF == '2'
		//Valida se algum pedido do volume já encontra-se faturado e impede o estorno
		lRet := A412VldFat(D01->D01_CODEXP,D01->D01_CARGA,D01->D01_PEDIDO)
	Else
		WmsMessage(STR0050,WMSA41222) //Não existe volume montado para a conferência!
		lRet := .F.
	EndIf

	If lRet
		FWExecView(STR0051,"WMSA412B",4,,{||.T.},,,,{||.T.}) //Conferência de Expedição Volume
	EndIf

	WMSA412REF()
	RestArea(aAreaAnt)
Return
//----------------------------------------------------------
/*/{Protheus.doc} FiltraCdMnt
Função responsável por buscar código de montagem que será utilizado no filtro da DCU
@author Amanda Rosa Vieira
@version P11
@Since   12/01/2017
@version 2.0
/*/
//----------------------------------------------------------
Static Function FiltraCdMnt()
Local cAliasDCU := GetNextAlias()
Local cCodMnt   := ""
	BeginSql Alias cAliasDCU
		SELECT DCV.DCV_CODMNT
		FROM %Table:D04% D04
		INNER JOIN %Table:DCV% DCV
		ON DCV.DCV_FILIAL = %xFilial:DCV%
		AND DCV.DCV_CARGA = D04.D04_CARGA
		AND DCV.DCV_PEDIDO = D04.D04_PEDIDO
		AND DCV.DCV_ITEM = D04.D04_ITEM
		AND DCV.DCV_SEQUEN = D04.D04_SEQUEN
		AND DCV.DCV_CODPRO = D04.D04_CODPRO
		AND DCV.%NotDel%
		WHERE D04.D04_FILIAL = %xFilial:D04%
		AND D04.D04_CODEXP = %Exp:D01->D01_CODEXP%
		AND D04.D04_CARGA  = %Exp:D01->D01_CARGA%
		AND D04.D04_PEDIDO = %Exp:D01->D01_PEDIDO%
		AND D04.%NotDel%
	EndSql
	If (cAliasDCU)->(!EoF())
		cCodMnt   := (cAliasDCU)->DCV_CODMNT
	EndIf
	(cAliasDCU)->(dbCloseArea())
Return cCodMnt
