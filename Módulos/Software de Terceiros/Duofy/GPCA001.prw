#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEditPanel.CH'
#INCLUDE 'gpca001.ch'

/*/{Protheus.doc} GPCA001
Cadastro Unificado do Posto - Browses

@type function
@version 1.0
@author Duofy
@since 01/08/2025
/*/
Function GPCA001()

	LjMsgRun(STR0001,,{|| GPCA001A() })

Return

Static Function GPCA001A()

	Local aCoors 		:= FWGetDialogSize( oMainWnd )
	Local cTitulo		:= STR0002
	Local oPanelUp
	Local oFWLayer
	Local oPanelLeft
	Local oPanelRight
	Local oBrowseTq
	Local oBrowseCn
	Local oBrowseUp
	Local oBrowseLeft
	Local oBrowseRight
	Local oTFolder
	Local oRelacA63
	Local oRelacA64
	Private oDlgPrinc

	DEFINE MSDIALOG oDlgPrinc Title cTitulo  From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel STYLE nOr(WS_VISIBLE, WS_POPUP)

	aTFolder := { STR0003, STR0004, STR0005 }
	oTFolder := TFolder():New(0, 0,aTFolder,,oDlgPrinc,,,,.T.,,aCoors[4]/2, aCoors[3]/2 )

	// Cria o conteiner onde serão colocados os browses
	oFWLayer := FWLayer():New()
	oFWLayer:Init( oTFolder:aDialogs[3], .F., .T. )

	////////////////////////// PAINEL SUPERIOR /////////////////////////////
	// Cria uma "linha" com 50% da tela
	oFWLayer:AddLine( 'UP', 50, .F. )

	// Na "linha" criada eu crio uma coluna com 100% da tamanho dela
	oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )

	// Pego o objeto desse pedaço do container
	oPanelUp := oFWLayer:GetColPanel( 'ALL', 'UP' )

	////////////////////////// PAINEL INFERIOR /////////////////////////////
	// Cria uma "linha" com 50% da tela
	oFWLayer:AddLine( 'DOWN', 50, .F. )

	// Na "linha" criada eu crio uma coluna com 49% da tamanho dela
	oFWLayer:AddCollumn( 'LEFT' , 49, .T., 'DOWN' )

	// Na "linha" criada eu crio uma coluna com 2% da tamanho dela, apenas para criar uma coluna separadora
	oFWLayer:AddCollumn( 'CENTER_COLUN', 2, .T., 'DOWN' )

	// Na "linha" criada eu crio uma coluna com 49% da tamanho dela
	oFWLayer:AddCollumn( 'RIGHT', 49, .T., 'DOWN' )

	// Pego o objeto do pedaço esquerdo
	oPanelLeft := oFWLayer:GetColPanel( 'LEFT' , 'DOWN' )

	// Pego o objeto do pedaço direito
	oPanelRight := oFWLayer:GetColPanel( 'RIGHT', 'DOWN' )

	////////////////////// MONTO O BROWSER DE TANQUES ////////////////////////
	oBrowseTq := FWmBrowse():New()
	oBrowseTq :SetOwner( oTFolder:aDialogs[1] )

	// Atribuo o título do Browser
	oBrowseTq:SetDescription( STR0003 )

	// Atribuo o nome da tabela
	oBrowseTq:SetAlias( 'A60' )

	// Habilito a visualização do Menu
	oBrowseTq:SetMenuDef( 'GPCA002' )

	// Desabilito o detalhamento do browser
	oBrowseTq:DisableDetails()

	oBrowseTq:SetProfileID( '1' )
	oBrowseTq:ForceQuitButton()

	//adiciona legenda no Browser
	oBrowseTq:AddLegend( "A60_STATUS == '1' .AND. (Empty(A60_DTDESA) .OR. A60_DTDESA >= Date())"	, "GREEN"	, STR0011)
	oBrowseTq:AddLegend( "A60_STATUS == '2' .OR. A60_DTDESA < Date()"	, "RED" 	, STR0012)

	oBrowseTq:Activate()

	////////////////////// MONTO O BROWSER DE CONCENTRADORAS ////////////////////////
	oBrowseCn := FWmBrowse():New()
	oBrowseCn :SetOwner( oTFolder:aDialogs[2] )

	// Atribuo o título do Browser
	oBrowseCn:SetDescription( STR0004 )

	// Atribuo o nome da tabela
	oBrowseCn:SetAlias( 'A61' )

	// Habilito a visualização do Menu
	oBrowseCn:SetMenuDef( 'GPCA004' )

	// Desabilito o detalhamento do browser
	oBrowseCn:DisableDetails()

	oBrowseCn:SetProfileID( '1' )
	oBrowseCn:ForceQuitButton()

	//adiciona legenda no Browser
	oBrowseCn:AddLegend( "A61_STATUS == '1'", "GREEN", STR0011)
	oBrowseCn:AddLegend( "A61_STATUS == '2'", "RED"  , STR0012)

	oBrowseCn:Activate()

	////////////////////// MONTO O BROWSER DE BOMBAS ////////////////////////
	oBrowseUp := FWMBrowse():New()
	oBrowseUp :SetOwner( oPanelUP )

	// Atribuo o título do Browser
	oBrowseUp :SetDescription( STR0006 )

	// Desabilito a visualização do Menu, pois o usuário não pode incluir um módulo individualmente
	oBrowseUp :SetMenuDef('GPCA003')

	// Desabilito o detalhamento do browser
	oBrowseUp:DisableDetails()

	// Atribuo o nome da tabela
	oBrowseUp:SetAlias( 'A62' )

	oBrowseUp:SetProfileID( '1' )
	oBrowseTq:ForceQuitButton()

	oBrowseUp:AddLegend( "A62_STATUS == '1'"	, "GREEN"	, STR0011)
	oBrowseUp:AddLegend( "A62_STATUS == '2'"	, "RED" 	, STR0012)

	oBrowseUp:Activate()

	////////////////////// MONTO O BROWSER DE BICOS ////////////////////////
	oBrowseLeft:= FWMBrowse():New()
	oBrowseLeft:SetOwner( oPanelLeft )

	// Atribuo o título do Browser
	oBrowseLeft:SetDescription( STR0007 )

	// Desabilito a visualização do Menu, pois o usuário não pode incluir um jazigo individualmente
	oBrowseLeft:SetMenuDef( '' )

	// Desabilito o detalhamento do browser
	oBrowseLeft:DisableDetails()

	// Atribuo o nome da tabela
	oBrowseLeft:SetAlias( 'A63' )

	oBrowseLeft:SetProfileID( '2' )

	// adiciona legenda no Browser
	oBrowseLeft:AddLegend( "A63_STATUS == '1' .and. (Empty(A63_DTDES) .or. A63_DTDES >= Date())"	, "GREEN"	, STR0011)
	oBrowseLeft:AddLegend( "A63_STATUS == '2' .OR. A63_DTDES < Date()"	, "RED" 	, STR0012)

	oBrowseLeft:Activate()


	////////////////////// MONTO O BROWSER DE LACRES ////////////////////////
	oBrowseRight:= FWMBrowse():New()
	oBrowseRight:SetOwner( oPanelRight )

	// Atribuo o título do Browser
	oBrowseRight:SetDescription( STR0008 )

	// Desabilito a visualização do Menu, pois o usuário não pode incluir um jazigo individualmente
	oBrowseRight:SetMenuDef( '' )

	// Desabilito o detalhamento do browser
	oBrowseRight:DisableDetails()

	// Atribuo o nome da tabela
	oBrowseRight:SetAlias( 'A64' )

	oBrowseRight:SetProfileID( '3' )

	oBrowseRight:Activate()


	////////////////////// DEFINO O RELACIONAMENTO ENTRE OS BROWSER's ////////////////////////
	oRelacA63:= FWBrwRelation():New()
	oRelacA63:AddRelation( oBrowseUp , oBrowseLeft , { { 'A63_FILIAL', 'A62_FILIAL' }, { 'A63_CODBOM' , 'A62_CODBOM' } } )
	oRelacA63:Activate()

	oRelacA64:= FWBrwRelation():New()
	oRelacA64:AddRelation( oBrowseUp, oBrowseRight, { { 'A64_FILIAL', 'A62_FILIAL' }, { 'A64_CODBOM', 'A62_CODBOM' }, { 'A64_CODMAN', 'Space(6)' } } )
	oRelacA64:Activate()

	Activate MsDialog oDlgPrinc Center

Return(Nil)

