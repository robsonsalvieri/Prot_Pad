#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH" 
#INCLUDE "TAFTICKET.CH"
#INCLUDE "TAFTCKDEF.CH"  
#INCLUDE "TAFCSS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE MB_ICONHAND		16

STATIC	aLayXAlias	:=	{}

/*/{Protheus.doc} TafMonVLote
Cria os objetos conforme Visão por Lote
@type function
@author Evandro dos Santos O. Teixeira
@since 25/07/2016
@version 1.0
@param lInteg 	- Determina que devem ser criados os objetos para o monitor de Integração.
@param lValid	- Detrmina que devem ser criados os objetos para o monitor de Validação.
@param oParent	- Objeto Pai para a criação das interfaces
@param aParamT	- Array com os parâmetros de Filtro
@param oDlgMon	- Dialog do Container 
@param lBackPar - Determina que a chamada do parâmetro foi feita pelo monitor
@return Nil 
@obs Este fonte é o antigo TafTICKET
/*/
Function TafMonVLote(lInteg,lValid,oParent,aParamT,oDlgMon,lBackPar,cCodFil, cCodFil2)

	Local oLayer  := Nil
	Local lNewC1E := SuperGetMv("MV_TAFCFGE", .F., .F.)

	Default cCodFil2 := ""
	
	
	oPanFundo  := TPanel():New(00,00,"",oParent,,.F.,.F.,,,00,00,.F.,.F.)
	oPanFundo:Align := CONTROL_ALIGN_ALLCLIENT
	If Val(GetVersao(.F.)) > 10 .And. Val(GetVersao(.F.)) < 12 
		oPanFundo:setCSS(QLABEL_AZUL_C)
	EndIf

	
	oLayer := FWLayer():New()
	oLayer:Init(oPanFundo)

	If lValid
		If lNewC1E
			oLayer:AddLine( "LINE01", 85 )
			oLayer:AddLine( "LINE02", 10 )
			FPanel05( oLayer:GetLinePanel("LINE01"),aParamT,cCodFil, cCodFil2 ) //Contrução do Painel de Monitor de Validação
			FPanelMSG( oLayer:GetLinePanel("LINE02") )
		Else
			FPanel05(oPanFundo,aParamT,cCodFil, cCodFil2 ) //Contrução do Painel de Monitor de Validação
		EndIf
	Else
		oLayer:AddLine( "LINE01", 36 )
		oLayer:AddLine( "LINE02", 49 )
		oLayer:AddLine( "LINE03", 10 )
	
		oLayer:AddCollumn( "BOX02", 50,, "LINE01" )
		oLayer:AddCollumn( "BOX03", 50,, "LINE01" )
		
		oLayer:AddWindow( "BOX02", "PANEL02", STR0003, 100, .F.,,, "LINE01" ) //"Gráfico Ticket - Por Lote"
		oLayer:AddWindow( "BOX03", "PANEL03", STR0004, 100, .F.,,, "LINE01" ) //"Gráfico Ticket - Por Registro"

		FPanel02( oLayer:GetWinPanel( "BOX02", "PANEL02", "LINE01" ),aParamT,cCodFil) //Contrução do Painel de Gráfico Ticket - Por Lote
		FPanel03( oLayer:GetWinPanel( "BOX03", "PANEL03", "LINE01" ),aParamT,cCodFil) //Contrução do Painel de Gráfico Ticket - Por Registro
		FPanel04( oLayer:GetLinePanel("LINE02"),aParamT,cCodFil) //Contrução do Painel de Monitor de Integração
		
		If lNewC1E
			FPanelMSG( oLayer:GetLinePanel("LINE03") )
		EndIf
	EndIf

Return Nil 

//---------------------------------------------------------------------
/*/{Protheus.doc} FPanel02

Painel de Gráfico Ticket - Por Lote.

@Param		oPanel	->	Janela para criação de interface
@Param		aParamT -> Parâmetros de Filtro

@Author	Felipe C. Seolin
@Since		06/04/2015
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function FPanel02( oPanel,aParamT,cCodFil)

Local nI		as numeric
Local aSeries	as array

nI		:=	0
aSeries	:=	FGetSeries( "PANEL02",aParamT,cCodFil)

oChart01 := FWChartFactory():New()
oChart01:SetOwner( oPanel )
oChart01:SetChartDefault( NEWPIECHART )
oChart01:SetLegend( CONTROL_ALIGN_LEFT )

For nI := 1 to Len( aSeries )
	oChart01:AddSerie( aSeries[nI,1], aSeries[nI,2] )
Next nI

oChart01:Activate()

TAFEncArr( @aSeries )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} FPanel03

Painel de Gráfico Ticket - Por Registro.

@Param		oPanel	->	Janela para criação de interface
@Param 		aParamT -> Parâmetros de Filtro

@Author	Felipe C. Seolin
@Since		06/04/2015
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function FPanel03( oPanel,aParamT,cCodFil)

Local nI		as numeric
Local aSeries	as array

nI		:=	0
aSeries	:=	FGetSeries( "PANEL03",aParamT,cCodFil)

oChart02 := FWChartFactory():New()
oChart02:SetOwner( oPanel )
oChart02:SetChartDefault( NEWPIECHART )
oChart02:SetLegend( CONTROL_ALIGN_LEFT )

For nI := 1 to Len( aSeries )
	oChart02:AddSerie( aSeries[nI,1], aSeries[nI,2] )
Next nI

oChart02:Activate()

TAFEncArr( @aSeries )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} FPanel04

Painel de Monitor de Integração.

@Param		oPanel	->	Janela para criação de interface
@Param 		aParamT -> Parâmetros de Filtro

@Author	Felipe C. Seolin
@Since		07/04/2015
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function FPanel04( oPanel,aParamT,cCodFil)

Local cAlias		:=	""
Local cSql			:=	FGetQuery( "PANEL04",,,,,aParamT,cCodFil)
Local nI			:=	0
Local aStruct		:=	FGetStruct( "PANEL04", @cAlias, cSql )
Local bExpandir		:=	{ || Iif( ( oBrowse01:Alias() )->( !Eof() ), Processa( { || FBrwView( oBrowse01,,aParamT,cCodFil ), STR0007, STR0014 } ), ) } //##"Processando" ##"Construindo Interface"
Local bExcluir		:=	{ || Iif( ( oBrowse01:Alias() )->( !Eof() ), FDirect( oBrowse01,aParamT,cCodFil), ) }
Local bAtualizar	:=	{ || Processa( { || FUpdPanel(,,.T.,,aParamT,cCodFil), STR0007, STR0020 } ) } //##"Processando" ##"Atualizando Informações"

oBrowse01 := FWFormBrowse():New()
oBrowse01:SetOwner( oPanel )
oBrowse01:SetDataTable()
oBrowse01:SetAlias( cAlias )
oBrowse01:SetTemporary()
oBrowse01:DisableDetails()
oBrowse01:DisableReport()
oBrowse01:DisableConfig()
oBrowse01:SetSeek()
oBrowse01:SetUseFilter(.T.)
oBrowse01:SetFieldFilter(aStruct[3])
oBrowse01:SetDBFFilter() 
oBrowse01:SetDoubleClick( bExpandir )

For nI := 1 to Len( aStruct[1] )
	oBrowse01:AddLegend( aStruct[1,nI,1], aStruct[1,nI,2], aStruct[1,nI,3] )
Next nI

oBrowse01:SetColumns( aStruct[2] )

oBrowse01:AddButton( STR0017, bExcluir ) //"Excluir"
oBrowse01:AddButton( STR0018, bExpandir ) //"Expandir"
oBrowse01:AddButton( STR0019, bAtualizar ) //"Atualizar"

oBrowse01:Activate()

TAFEncArr( @aStruct )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} FDirect

Direciona a operação desejado pelo usuário.

@Param		oBrowse01	- Browse em execução.

@Author	Felipe C. Seolin
@Since		19/12/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function FDirect( oBrowse01,aParamT,cCodFil )

Local cAlias		as character
Local nOperation	as numeric
Local lExec		as logical

cAlias		:=	oBrowse01:Alias()
nOperation	:=	0
lExec		:=	FSelect( @nOperation )

If lExec
	If nOperation == 1 //Excluir Ticket e Registros da Base
		If MsgYesNo( STR0155, STR0103 ) //##"Esta opção excluirá o Ticket e todos os registros pertencentes a ele permanentemente da base de dados. Deseja confirmar a operação?" ##"Atenção"
			Processa( { || (TAFDelTicket( { ( cAlias )->TAFTICKET },,.T. ), FUpdPanel(.T.,.T.,.T.,.T.,aParamT,cCodFil) ), STR0007, STR0163 } ) //##"Processando" ##"Executando Rotina de Exclusão"
		EndIf
	ElseIf nOperation == 2 //Excluir apenas os Registros da Base
		Processa( { || ( FBrwMark( oBrowse01, aParamT, cCodFil ), FUpdPanel(.T., .T., .T.,.T.,aParamT,cCodFil) ), STR0007, STR0014 } ) //##"Processando" ##"Construindo Interface"
	EndIf
EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} FSelect

Interface de seleção da opção de exclusão do Ticket.

@Param		nOperation	- Operação a ser executada

@Return	lRet		- Indica se a interface foi encerrada por ação em botão

@Author	Felipe C. Seolin
@Since		19/12/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function FSelect( nOperation )

Local oDialog		as object
Local oMultiGet	as object
Local cEnter		as character
Local cTexto		as character
Local nTop			as numeric
Local nLeft		as numeric
Local aSize		as array
Local aRadio		as array
Local aTexto		as array
Local lRet			as logical

oDialog	:=	Nil
oMultiGet	:=	Nil
cEnter		:=	Chr( 13 ) + Chr( 10 )
cTexto		:=	""
nTop		:=	0
nLeft		:=	0
aSize		:=	FWGetDialogSize( oMainWnd )
aRadio		:=	{}
aTexto		:=	{}
lRet		:=	.F.

nTop		:=	( aSize[1] + aSize[3] ) / 5
nLeft		:=	( aSize[2] + aSize[4] ) / 5

aAdd( aRadio, STR0156 ) //"Excluir Ticket e Registros da Base de Dados"
aAdd( aRadio, STR0157 ) //"Excluir apenas os Registros da Base de Dados"

aAdd( aTexto, STR0156 + cEnter + cEnter + STR0158 ) //##"Excluir Ticket e Registros da Base de Dados" ##"Selecionando esta opção, o Ticket será excluído, assim como todos os registros pertencentes a ele."
aAdd( aTexto, STR0157 + cEnter + cEnter + STR0159 ) //##"Excluir apenas os Registros da Base de Dados" ##"Selecionando esta opção, o Ticket permanecerá na base de dados, mas todos os registros pertencentes a ele serão excluídos."

oDialog := MsDialog():New( nTop, nLeft, 420, 800, STR0017,,,,,,,,, .T.,,,, .F. ) //"Excluir"

TRadMenu():New( 010, 010, aRadio, { |x| Iif( PCount() == 0, nOperation, nOperation := x ) }, oDialog,, { || cTexto := aTexto[nOperation], oMultiGet:Refresh() },,,,,, 200, 030,,,, .T. )

oMultiGet := TMultiGet():New( 035, 010, { || cTexto }, oDialog, 160, 050,, .T. ,,,, .T.,,,,,, .T.,,,,, .T. )

TButton():New( 095, 100, STR0160, oDialog, { || Iif( lRet := ValidOk( nOperation ), oDialog:End(), ) }, 030, 012,,,, .T. ) //"Confirmar"
TButton():New( 095, 140, STR0161, oDialog, { || oDialog:End() }, 030, 012,,,, .T. ) //"Cancelar"

oDialog:Activate()

TAFEncArr( @aSize )
TAFEncArr( @aRadio )
TAFEncArr( @aTexto )

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidOk

Validação da seleção da opção de exclusão do Ticket.

@Param		nOperation	- Item selecionado

@Return	lRet		- Indica se todas as condições foram respeitadas

@Author	Felipe C. Seolin
@Since		19/12/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function ValidOk( nOperation )

Local lRet	as logical

lRet	:=	.T.

If nOperation <= 0
	MsgInfo( STR0162 ) //"Selecione uma operação para confirmar."
	lRet := .F.
EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} FPanel05

Painel de Monitor de Validação.

@Param		oPanel	->	Janela para criação de interface
@param		aParamT -> Parâmetros de Filtro

@Author	Felipe C. Seolin
@Since		13/04/2015
@Version	1.0
/*/
//---------------------------------------------------------------------

Static Function FPanel05( oPanel,aParamT,cCodFil, cCodFil2 )

Local cAlias		as character
Local cSql			as character
Local nI			as numeric
Local aStruct		as array
Local bVisual		as codeblock
Local bUpdate		as codeblock
Local bUpdView	as codeblock

Default	cCodFil2	:= ""

cAlias		:=	""

cSql		:=	FGetQuery( "PANEL05",,,,,aParamT,cCodFil, cCodFil2 )

nI			:=	0
aStruct	:=	FGetStruct( "PANEL05", @cAlias, cSql )
bVisual	:=	{ || Iif( ( oBrowse02:Alias() )->( !Eof() ), Processa( { |lOk| ( lOk := FMonGoToView( "VALIDACAO", 1, oBrowse02 ), Iif( lOk, FUpdPanel(,,,.T.,aParamT,cCodFil), ) ), STR0007, STR0014 } ), ) } //##"Processando" ##"Construindo Interface"
bUpdate	:=	{ || Iif( ( oBrowse02:Alias() )->( !Eof() ), Processa( { |lOk| ( lOk := FMonGoToView( "VALIDACAO", 4, oBrowse02 ), Iif( lOk, FUpdPanel(,,,.T.,aParamT,cCodFil), ) ), STR0007, STR0014 } ), ) } //##"Processando" ##"Construindo Interface"
bUpdView	:=	{ || Processa( {||FUpdPanel(,,,.T.,aParamT,cCodFil), STR0007, STR0020 } ) } //##"Processando" ##"Atualizando Informações"

oBrowse02 := FWFormBrowse():New()
oBrowse02:SetOwner( oPanel )
oBrowse02:SetDataTable()
oBrowse02:SetAlias( cAlias )
oBrowse02:SetTemporary()
oBrowse02:DisableDetails()
oBrowse02:DisableReport()
oBrowse02:DisableConfig()
oBrowse02:SetSeek()
oBrowse02:SetDBFFilter()
oBrowse02:SetUseFilter()

For nI := 1 to Len( aStruct[1] )
	oBrowse02:AddLegend( aStruct[1,nI,1], aStruct[1,nI,2], aStruct[1,nI,3] )
Next nI

oBrowse02:SetColumns( aStruct[2] )

oBrowse02:AddButton( STR0021, bVisual ) //"Visualizar"
oBrowse02:AddButton( STR0022, bUpdate ) //"Corrigir"
oBrowse02:AddButton( STR0019, bUpdView ) //"Atualizar"

oBrowse02:Activate()

TAFEncArr( @aStruct )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} FUpdPanel

Atualiza as informações dos painéis de acordo com filtro corrente.

@Param		lRefresh1	->	Informa se deve atualizar Painel de Gráfico Ticket - Por Lote
			lRefresh2	->	Informa se deve atualizar Painel de Gráfico Ticket - Por Registro
			lRefresh3	->	Informa se deve atualizar Painel de Monitor de Integração
			lRefresh4	->	Informa se deve atualizar Painel de Monitor de Validação
			aParamT	->  Parametros de Filtro
			lUpdBrw 	->  Informa que a opereção é de atualização

@Author	Felipe C. Seolin
@Since		14/04/2015
@Version	1.0
/*/
//---------------------------------------------------------------------
Function FUpdPanel( lRefresh1, lRefresh2, lRefresh3, lRefresh4,aParamT,cCodFil)

Local cAlias	as character
Local cSql		as character
Local nRegua	as numeric
Local nI		as numeric
Local aSeries	as array

Default lRefresh1	:=	.F.
Default lRefresh2	:=	.F.
Default lRefresh3	:=	.F.
Default lRefresh4	:=	.F.

cAlias	:=	""
cSql	:=	""
nRegua	:=	0
nI		:=	0
aSeries	:=	{}

If lRefresh3 .and. ValType( oBrowse01 ) == "U"
	lRefresh3 := .F.
ElseIf lRefresh4 .and. ValType( oBrowse02 ) == "U"
	lRefresh4 := .F.
EndIf

If lRefresh1
	nRegua += 1
EndIf

If lRefresh2
	nRegua += 1
EndIf

If lRefresh3
	nRegua += 1
EndIf

If lRefresh4
	nRegua += 1
EndIf

ProcRegua( nRegua )

//--------------------------------------------------
// Atualiza Painel de Gráfico Ticket - Por Lote
//--------------------------------------------------
If lRefresh1
	aSeries := FGetSeries( "PANEL02",aParamT,cCodFil )

	oChart01:DeActivate()

	For nI := 1 to Len( aSeries )
		oChart01:AddSerie( aSeries[nI,1], aSeries[nI,2] )
	Next nI

	oChart01:Activate()

	IncProc()
EndIf

//--------------------------------------------------
// Atualiza Painel de Gráfico Ticket - Por Registro
//--------------------------------------------------
If lRefresh2
	aSeries := FGetSeries( "PANEL03",aParamT,cCodFil )

	oChart02:DeActivate()

	For nI := 1 to Len( aSeries )
		oChart02:AddSerie( aSeries[nI,1], aSeries[nI,2] )
	Next nI

	oChart02:Activate()

	IncProc()
EndIf

//--------------------------------------------------
// Atualiza Monitor de Integração
//--------------------------------------------------
If lRefresh3
	cSql := FGetQuery( "PANEL04" ,,,,,aParamT,cCodFil )
	FGetStruct( "PANEL04", @cAlias, cSql,.T. )
	oBrowse01:Refresh(.T.)
	oBrowse01:GoTop()
	IncProc()
EndIf

//--------------------------------------------------
// Atualiza Monitor de Validação
//--------------------------------------------------
If lRefresh4
	cSql := FGetQuery( "PANEL05" ,,,,,aParamT,cCodFil )
	FGetStruct( "PANEL05", @cAlias, cSql ,.T.)
	oBrowse02:Refresh(.T.)
	IncProc()
EndIf

TAFEncArr( @aSeries )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} FGetSeries

Intervalos e valores dos gráficos.

@Param		cPanel		->	Indica o painel desejado para retorno de estrutura

@Return	aSeries	->	Array com os intervalos e valores do gráfico

@Author	Felipe C. Seolin
@Since		06/04/2015
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function FGetSeries( cPanel,aParamT,cCodFil )

Local cAlias	as character
Local cSql		as character
Local nCount1	as numeric
Local nCount2	as numeric
Local nCount3	as numeric
Local nCount4	as numeric
Local aSeries	as array

cAlias	:=	GetNextAlias()
cSql	:=	""
nCount1	:=	0
nCount2	:=	0
nCount3	:=	0
nCount4	:=	0
aSeries	:=	{}

cSql := FGetQuery( cPanel,,,,,aParamT,cCodFil )

DBUseArea( .T., "TOPCONN", TCGenQry( ,, cSql ), cAlias )

If cPanel == "PANEL02"
	
	While ( cAlias )->( !Eof() )

		If ( cAlias )->TAFSTATUS == "3"
			nCount1 += ( cAlias )->NCOUNT
		Else
			nCount2 += ( cAlias )->NCOUNT
		EndIf

		( cAlias )->( DBSkip() )
	EndDo

	aAdd( aSeries, { STR0023, nCount1 } ) //"Integrados"
	aAdd( aSeries, { STR0024, nCount2 } ) //"Pendentes"

ElseIf cPanel == "PANEL03"

	While ( cAlias )->( !Eof() )

		If ( cAlias )->TAFSTATUS == "1"
			nCount1 += ( cAlias )->NCOUNT
		ElseIf ( cAlias )->TAFSTATUS == "2"
			nCount2 += ( cAlias )->NCOUNT
		ElseIf ( cAlias )->TAFSTATUS == "3"
			nCount3 += ( cAlias )->NCOUNT
		Else
			nCount4 += ( cAlias )->NCOUNT
		EndIf

		( cAlias )->( DBSkip() )
	EndDo

	aAdd( aSeries, { STR0025, nCount1 } ) //"Incluídos"
	aAdd( aSeries, { STR0026, nCount2 } ) //"Alterados"
	aAdd( aSeries, { STR0027, nCount3 } ) //"Excluídos"
	aAdd( aSeries, { STR0028, nCount4 } ) //"Inconsistentes"

EndIf

( cAlias )->( DBCloseArea() )

Return( aSeries )

//---------------------------------------------------------------------
/*/{Protheus.doc} FBrwView

Interface com detalhes do Ticket e opções de manipular dados.

@Param		oBrowse01	->	Browse em execução
@param		aParamT	-> Parâmetros de Filtro

@Author	Felipe C. Seolin
@Since		16/04/2015
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function FBrwView( oBrowse01,cTicket,aParamT,cCodFil )

Local oDlg			as object
Local oBrowse		as object
Local cAliasMon	as character
Local cAlias		as character
Local cSql			as character
Local nTop			as numeric
Local nLeft		as numeric
Local nI			as numeric
Local aSize		as array
Local aStruct		as array
Local bShowReg	as codeblock
Local bFilReg		as codeblock
Local bViewVis	as codeblock
Local bViewUpd	as codeblock
Local bViewExc	as codeblock
Local bDebug		as codeblock
Local bReinteg		as codeblock
Local bAtualizar		as codeblock

Default cTicket := ""

oDlg			:=	Nil
oBrowse			:=	Nil
cAliasMon		:=	oBrowse01:Alias()
cAlias			:=	""
cSql			:=	""
nTop			:=	0
nLeft			:=	0
nI				:=	0
aSize			:=	FWGetDialogSize( oMainWnd )
aStruct			:=	{}
bShowReg		:=	{||}
bFilReg			:=	{||}
bViewVis		:=	{||}
bViewUpd		:=	{||}
bViewExc		:=	{||}
bDebug			:=	{||}
bReinteg		:=	{||}
bAtualizar	:=	{ || Processa( { || FUpdPanel(,,.T.,,aParamT,cCodFil), STR0007, STR0020 } ) } //##"Processando" ##"Atualizando Informações"

If Empty(cTicket)
	cTicket := ( cAliasMon )->TAFTICKET
EndIf

cSql	:= FGetQuery( "PANELTICKET", cTicket,,,,aParamT,cCodFil )
aStruct	:= FGetStruct( "PANELTICKET", @cAlias, cSql )

//-----------------------------------------------------------------------------
// Avalia se há registros a serem exibidos, caso contrário, apresenta mensagem
//-----------------------------------------------------------------------------
If (cAlias)->(LastRec()) > 0
	bShowReg	:=	{ || Iif( ( oBrowse:Alias() )->( !Eof() ), Processa( { || FShowReg( oBrowse ), STR0007, STR0031 } ), ) } //##"Processando" ##"Buscando Informações"
	bFilReg	:=	{ || Iif( ( oBrowse:Alias() )->( !Eof() ), Processa( { || FBrwFiltro( @oBrowse, cTicket, aParamT, cCodFil ), STR0007, STR0031 } ), ) } //##"Processando" ##"Buscando Informações"
	bViewVis	:=	{ || Processa( { || Iif( ( oBrowse:Alias() )->TAFSTATUS $ "1|2|6",;
													FMonGoToView( "INTEGRACAO", 1, oBrowse ),;
													Iif( ( oBrowse:Alias() )->TAFSTATUS == "3",;
															Aviso( STR0034, STR0035, { STR0036 }, 3 ),;
															Aviso( STR0037, STR0038, { STR0036 }, 3 ) ) ), STR0007, STR0014 } ) } //#STR0034#"Registro Excluído" #STR0035#"Este registro foi excluído do TAF. Não é possível realizar operações." #STR0036#"Fechar" #STR0037#"Registro Não Integrado" #STR0038#"Este registro não foi integrado ao TAF. Verifique a inconsistência informada e realize a correção." #STR0036#"Fechar" #STR0007#"Processando" #STR0014#"Construindo Interface"
	bViewUpd	:=	{ || Processa( { || Iif( ( oBrowse:Alias() )->TAFSTATUS $ "1|2|6",;
													( FMonGoToView( "INTEGRACAO", 4, oBrowse ),;
														cSql := FGetQuery( "PANELTICKET", cTicket,,,,aParamT,cCodFil),;
														FGetStruct( "PANELTICKET", @cAlias, cSql ),;
														oBrowse:Refresh(.T.) ),;
													Iif( ( oBrowse:Alias() )->TAFSTATUS == "3",;
															Aviso( STR0034, STR0035, { STR0036 }, 3 ),;
															Aviso( STR0037, STR0038, { STR0036 }, 3 ) ) ), STR0007, STR0014 } ) } //#STR0034#"Registro Excluído" #STR0035#"Este registro foi excluído do TAF. Não é possível realizar operações." #STR0036#"Fechar" #STR0037#"Registro Não Integrado" #STR0038#"Este registro não foi integrado ao TAF. Verifique a inconsistência informada e realize a correção." #STR0036#"Fechar" #STR0007#"Processando" #STR0014#"Construindo Interface"
	bViewExc	:=	{ || Processa( { || Iif( ( oBrowse:Alias() )->TAFSTATUS $ "1|2|6",;
													( FMonGoToView( "INTEGRACAO", 5, oBrowse ),;
														cSql := FGetQuery( "PANELTICKET", cTicket,,,,aParamT,cCodFil ),;
														FGetStruct( "PANELTICKET", @cAlias, cSql ),;
														oBrowse:GoTop(),;
														oBrowse:Refresh(.T.) ),;
													Iif( ( oBrowse:Alias() )->TAFSTATUS == "3",;
															Aviso( STR0034, STR0035, { STR0036 }, 3 ),;
															Aviso( STR0037, STR0038, { STR0036 }, 3 ) ) ), STR0007, STR0014 } ) } //#STR0034#"Registro Excluído" #STR0035#"Este registro foi excluído do TAF. Não é possível realizar operações." #STR0036#"Fechar" #STR0037#"Registro Não Integrado" #STR0038#"Este registro não foi integrado ao TAF. Verifique a inconsistência informada e realize a correção." #STR0036#"Fechar" #STR0007#"Processando" #STR0014#"Construindo Interface"
	bDebug		:=	{ || Iif( ( oBrowse:Alias() )->( !Eof() ) .and. ( oBrowse:Alias() )->TAFSTATUS == "9" .and. ( oBrowse:Alias() )->TAFCODERR == "000005",;
							  		Processa( { || FDebug( oBrowse ), STR0007, STR0031 } ),;
									Aviso( STR0083, STR0084, { STR0036 }, 3 ) ) } //##"Operação inválida" ##"Não há informações a serem depuradas neste registro!" ##"Fechar"

	bReinteg		:=	{ || Processa( { || ( FReinteg( oBrowse ),;
 										oDlg:End(), Eval(bAtualizar) ), STR0007, STR0031 } ) }

 	nTop	:=	( aSize[1] + aSize[3] ) / 5
 	nLeft	:=	( aSize[2] + aSize[4] ) / 5

 	oDlg := MsDialog():New( nTop, nLeft, aSize[3], aSize[4], STR0029,,,,,,,,, .T.,,,, .F. ) //"Gerenciador do Ticket"

 	oBrowse := FWFormBrowse():New()
	oBrowse:SetProfileId("TAFAMonVLote")
 	oBrowse:SetOwner( oDlg )
 	oBrowse:SetDataTable()
 	oBrowse:SetAlias( cAlias )
 	oBrowse:SetTemporary()
 	oBrowse:DisableDetails()
 	oBrowse:DisableReport()
 	oBrowse:DisableConfig()
 	oBrowse:SetSeek()
 	oBrowse:SetDBFFilter() 
    oBrowse:SetFieldFilter(aStruct[ 3 ])  
 	oBrowse:SetUseFilter( .T. )
 	oBrowse:SetDoubleClick( bShowReg )

 	For nI := 1 to Len( aStruct[1] )
 		oBrowse:AddLegend( aStruct[1,nI,1], aStruct[1,nI,2], aStruct[1,nI,3] )
 	Next nI

 	oBrowse:SetColumns( aStruct[2] )

 	oBrowse:AddButton( STR0021, bViewVis ) //"Visualizar"
 	oBrowse:AddButton( STR0032, bViewUpd ) //"Alterar"
 	oBrowse:AddButton( STR0017, bViewExc ) //"Excluir"
 	oBrowse:AddButton( STR0033, bShowReg ) //"Exibir Mensagem"
 	oBrowse:AddButton( STR0056, bFilReg ) //"Filtrar"
 	oBrowse:AddButton( STR0085, bDebug ) //"Depurar"
 	oBrowse:AddButton( "Habilitar re-integração", bReinteg ) //"Habilitar re-integração"


 	oBrowse:Activate()

 	oDlg:Activate()

Else
	Aviso( STR0207, STR0233, { STR0036 }, 2 )	//'Atenção'###"Não há informações para apresentação. Verifique se o ticket selecionado não está pendente de processamento."###"Fechar"
EndIf

TAFEncArr( @aSize )
TAFEncArr( @aStruct )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} FDebug

Exibe a mensagem de depuração do registro posicionado.

@Param		oBrowse	->	Browse em execução

@Author	Felipe C. Seolin
@Since		15/03/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function FDebug( oBrowse )

Local oModal		as object
Local cDuplic		as character
Local cAlias		as character
Local cLayout		as character
Local nRecnoST2	as numeric
Local aAreaST2	as array

oModal		:=	Nil
cDuplic	:=	FGetDuplic( oBrowse )
cAlias		:=	oBrowse:Alias()
cLayout	:= ""
nRecnoST2	:=	( cAlias )->RECNOST2
aAreaST2	:=	( cST2Alias )->( GetArea() )


//Posiciono o registro
( cST2Alias )->( DBGoTo( nRecnoST2 ) )

//Recebo o layout do registro
cLayout :=( cST2Alias )->TAFTPREG


//Verifico se o usuário corrente tem acesso a rotina
If FPerAcess(,Alltrim(cLayout))

	oModal := FWDialogModal():New()
	oModal:SetTitle( STR0085 ) //"Depurar"
	oModal:SetFreeArea( 250, 250 )
	oModal:SetEscClose( .T. )
	oModal:SetBackground( .T. )
	oModal:CreateDialog()
	oModal:AddCloseButton()

	TMultiGet():New( 030, 020, { || cDuplic }, oModal:GetPanelMain(), 210, 190,, .T. ,,,, .T.,,,,,, .T.,,,,, .T. )
	
	oModal:Activate()

EndIf

RestArea( aAreaST2 )

Return()
//---------------------------------------------------------------------

//---------------------------------------------------------------------
/*/{Protheus.doc} FReinteg

Funcao responsavel por permitir reprocessar registros nao integrados para o TAF (Proc2).
	Esta re-integração gera um novo ticket na TAFST2 somente com os registros filtrados no browse, e possibilita chamar
	automaticamente o Proc2

@Param		oBrowse	->	Browse em execução

@Author	Gustavo G. Rueda
@Since		29/11/2017
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function FReinteg( oBrowse )
Local nRecnoST2	as numeric
Local aAreaST2	as array
Local cAlias	as character
Local oProcess	as object
Local nCtdRegs	as	numeric
Local lUpdate	as	logical
Local lMthr		as	logical
Local aCmpsST2	as	array
Local aStrST2	as	array
Local cTicket	as	character
Local dDate		as	Date
Local cTime		as	character
Local nX		as 	numeric
Local cSql      as  character
Local nCount	as  numeric // Variável criada para contagem do botão "Habilitar re-integração".
Local cAliasQry := ''
Local cSqlUp    as  character 
Local cNomeUser := Alltrim(UsrRetName(__CUSERID)) // Variável criada para obter o nome do usuário logado.

If MsgYesNo('Confirma processamento dos registros filtrados? Esta ação irá habilitar os registros para uma re-integração.' , 'Atenção')

	lUpdate		:=	.F.
	cAlias		:=	oBrowse:Alias()
	nCtdRegs	:=	( cAlias )->( RecCount() )
	aAreaST2	:=	( cST2Alias )->( GetArea() )
	lMthr		:=	Iif( nCtdRegs >400, .T., .F. )		//Menos de 400 registros não compensa subir as threads, o tempo eh o mesmo de processar o movimento em mono-thread
	aCmpsST2	:=	{}
	cTicket		:=	TAFGTicket()
	dDate		:=	Date()
	cTime		:=	Time()
	aStrST2		:=	xTAFGetStru( 'TAFST2' )
	nCount		:=  0  

	nRecnoST2	:=	( cAlias )->RECNOST2
	
	//Posiciono o registro
	( cST2Alias )->( dbGoTo( nRecnoST2 ) )

	If ( cST2Alias )->( !Eof() )

		If ( cST2Alias )->( TAFSTATUS == '3' .And. !Empty( TAFIDTHRD ) )

			cSql := "SELECT COUNT(*) REGISTROS_ST2 "
			cSql += "FROM TAFXERP "  
			cSql += "INNER JOIN TAFST2 TAFST2 "
			cSql += "   ON TAFST2.TAFFIL     = '" + ( cST2Alias )->TAFFIL + "' "
			cSql += "  AND TAFST2.TAFKEY     = TAFXERP.TAFKEY "
			cSql += "  AND TAFST2.TAFTICKET  = TAFXERP.TAFTICKET "
			cSql += "  AND TAFST2.TAFKEY     = '" + ( cST2Alias )->TAFKEY + "' "
			cSql += "  AND TAFST2.TAFTICKET  = '" + ( cST2Alias )->TAFTICKET + "' "
			cSql += "  AND TAFST2.D_E_L_E_T_ = ' ' "
			cSql += "WHERE TAFXERP.TAFSTATUS NOT IN ( '1', '2' ) "
			cSql += "  AND TAFXERP.D_E_L_E_T_ = ' ' "

			cAliasQry := getNextAlias()  
			/*VALIDAÇÃO PARA VERIFICAR QUANTOS REGISTROS RETORNARAM DA QUERY ACIMA*/
			TCQuery cSql New Alias &cAliasQry // Crio um Alias para o cSql
			nCount := (cAliasQry)->(REGISTROS_ST2) // Verifico se registros>0, se sim, faço update

			If nCount > 0
				cSqlUp := "UPDATE TAFST2 "
				cSqlUp += "SET TAFSTATUS='1' "
				cSqlUp += "  , TAFIDTHRD=' ' "
				cSqlUp += "	 , TAFOWNER='TAF' "
				cSqlUp += "  , TAFUSER= '" + cNomeUser + "' "
				cSqlUp += "WHERE TAFFIL     = '" + ( cST2Alias )->TAFFIL + "' "
				cSqlUp += "  AND TAFKEY     = '" + ( cST2Alias )->TAFKEY + "' "
				cSqlUp += "  AND TAFTICKET  = '" + ( cST2Alias )->TAFTICKET + "' "
				cSqlUp += "  AND D_E_L_E_T_ = ' ' "

				If TCSQLExec( cSqlUp ) < 0
					MessageBox( TCSQLError(), "", MB_ICONHAND )
				EndIf 
					If Select( cAliasQry ) > 0
						( cAliasQry)->( DbCloseArea() )
					EndIf
				lUpdate := .T.

			EndIf
		EndIf
	EndIf
		
	( cAlias )->( dbSkip() )
	RestArea( aAreaST2 )

	//Caso tenham registros pendentes de integração, pergunto e processo o Proc2 se solicitado
	If lUpdate 
		If MsgYesNo(STR0206 , STR0207)	//'Registros habilitados com sucesso, efetuar a re-integração agora?'###'Atenção'
			oProcess := TAFProgress():New( { || ProcReinteg( @oProcess, nCtdRegs, lMthr ) }, STR0208 )	//"Processando Integração"
			oProcess:Activate()
		EndIf
	Else
		Aviso( STR0207, STR0209, { STR0036 }, 3 )	//'Atenção'###'Não foi encontrado informações para re-integração.'
	EndIf
EndIf
Return 	{ cTicket, dDate, cTime }
//---------------------------------------------------------------------
/*/{Protheus.doc} ProcReinteg

Funcao responsavel pela re-integração, chamada automatica do Proc2

@Param		oProcess	->	Obj da regua de processamento
			nCtdRegs	->	Quantidade de registros do Set2Process
			lMThr		->	Flag de uso de multi-thread no processamento da integração

@Author	Gustavo G. Rueda
@Since		29/11/2017
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function ProcReinteg( oProcess, nCtdRegs, lMthr )
Local lOk		as logical

lOk			:=	.T.

//Set1 e Inc1
oProcess:Set1Progress( nCtdRegs )
oProcess:Inc1Progress( STR0210 )	//'Executando re-integração das informações'
ProcessMessages() 
Sleep(300) 

//Set2 e Inc2
oProcess:Set2Progress( nCtdRegs )
oProcess:Inc2Progress( STR0007 )	//'Processando...'
ProcessMessages() 
Sleep(300) 

TAFAInteg( , 2,, @lOk, .T., @oProcess, , lMThr )

 
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} FBrwMark

Interface com detalhes do Ticket e opção para exclusão em massa.

@Param		oBrowse01	->	Browse em execução
@param 		aPamamT	-> Parâmetros de Filtro

@Author	Felipe C. Seolin
@Since		16/04/2015
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function FBrwMark( oBrowse01, aParamT,cCodFil )

Local oDlg			as object
Local oBrowse		as object
Local cAliasMon	as character
Local cAliasBrw	as character
Local cAlias		as character
Local cMark		as character
Local nMark	 	as numeric
Local cMsg			as char
Local cSql			as character
Local cLayout		as character
Local nTop			as numeric
Local nLeft		as numeric
Local nI			as numeric
Local aSize		as array
Local aStruct		as array
Local aAreaST2	as array
Local bDblClick	as codeblock
Local bMarkExc	as codeblock

Default oBrowse01 := Nil

oDlg		:=	Nil
oBrowse	:=	Nil
cAliasMon	:=	oBrowse01:Alias()
cAliasBrw	:= ""
cAlias		:= ""
cMsg	  	:= ""
nMark		:= 0
cMark		:=	GetMark()
cLayout	:= ""
aAreaST2	:= {}

cSql		:=	FGetQuery( "PANELMARK", ( cAliasMon )->TAFTICKET, cMark,,, aParamT, cCodFil )
nTop		:=	0
nLeft		:=	0
nI			:=	0
aSize		:=	FWGetDialogSize( oMainWnd )
aStruct	:=	FGetStruct( "PANELMARK", @cAlias, cSql )
bDblClick	:=	{ || Iif( ( oBrowse:Alias() )->( !Eof() ), Processa( { || FMonGoToView( "INTEGRACAO", 1, oBrowse ), STR0007, STR0014 } ), ) } //##"Processando" ##"Construindo Interface"
bMarkExc	:=	{ || Iif( ( oBrowse:Alias() )->( !Eof() .and. MsgYesNo( STR0102, STR0103 ) ),;
						Processa( { || ( FMarkExc( oBrowse, cMark ),;
							cSql := FGetQuery( "PANELMARK", ( cAliasMon )->TAFTICKET, cMark,,, aParamT, cCodFil ),;
							FGetStruct( "PANELMARK", @cAlias, cSql ),;
							oBrowse:SetAlias( cAlias ),;
							oBrowse:GoTop(),;
							oBrowse:Refresh(),;
							oDlg:End() ), STR0007, STR0030 } ),;
						) } //##"Processando" ##"Excluindo Informações"

If ( cAlias )->( !Eof() )

	aAreaST2	:=	( cST2Alias )->( GetArea() )

	//Posiciono no registro na TAFST2
	( cST2Alias )->( DBSetOrder( 5 ) )
	( cST2Alias )->( MsSeek( ( cAliasMon )->TAFTICKET ) ) 
	
	//Recebo o layout do registro
	cLayout := Alltrim((cST2Alias)->TAFTPREG)
	
	//Se o registro for igual a T001, pulo e recebo o próximo
	If cLayout == "T001"
		( cST2Alias )->( DbSkip() )
		cLayout := Alltrim((cST2Alias)->TAFTPREG)
	EndIf


	nTop	:=	( aSize[1] + aSize[3] ) / 5
	nLeft	:=	( aSize[2] + aSize[4] ) / 5

	oDlg := MsDialog():New( nTop, nLeft, aSize[3], aSize[4], STR0029,,,,,,,,, .T.,,,, .F. ) //"Gerenciador do Ticket"

	oBrowse := FWMarkBrowse():New()
	oBrowse:SetColumns( aStruct[2] )
	oBrowse:SetOwner( oDlg )
	oBrowse:SetDataTable()
	oBrowse:SetAlias( cAlias )
	oBrowse:SetMenuDef( "" )
	oBrowse:SetWalkThru( .F. )
	oBrowse:SetAmbiente( .F. )
	oBrowse:DisableReport()
	oBrowse:DisableConfig()
	oBrowse:SetSeek( .T. )
	oBrowse:SetDBFFilter()
	oBrowse:SetUseFilter()
	oBrowse:SetDoubleClick( bDblClick )

	For nI := 1 to Len( aStruct[1] )
		oBrowse:AddLegend( aStruct[1,nI,1], aStruct[1,nI,2], aStruct[1,nI,3] )
	Next nI

	oBrowse:SetFieldMark( "MARK" )
	oBrowse:SetValid( {|| FPerAcess(cAliasBrw,cLayout,@cMsg,@nMark)} ) //Verifico se o usuário corrente tem acesso a rotina
	oBrowse:SetAllMark( { || FMarkAll( oBrowse ) } )	
	oBrowse:AddButton( STR0017, bMarkExc ) //"Excluir"
	oBrowse:Activate()
	cAliasBrw := oBrowse:Alias()

	oDlg:Activate()

	RestArea( aAreaST2 )

Else
	Help( ,, "HELP",, STR0164, 1, 0 ) //"Não existem dados para exclusão do Ticket selecionado."
EndIf

TAFEncArr( @aSize )
TAFEncArr( @aStruct )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} FMarkAll

Inverte a indicação de seleção de todos registros do Browse.

@Param		oBrowse	->	Objeto contendo campo de seleção

@Return	Nil

@Author	Felipe C. Seolin
@Since		15/04/2015
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function FMarkAll( oBrowse )

Local cAlias	as character
Local cMark	as character
Local nRecno	as numeric

cAlias	:=	oBrowse:Alias()
cMark	:=	oBrowse:Mark()
nRecno	:=	( cAlias )->( Recno() )

lMarkAll	:= .T.

( cAlias )->( DBGoTop() )

While ( cAlias )->( !Eof() )

	If RecLock( cAlias, .F. )
		( cAlias )->MARK := Iif( ( cAlias )->MARK == cMark, "  ", cMark )
		( cAlias )->( MsUnlock() )
	EndIf

	( cAlias )->( DBSkip() )
EndDo

( cAlias )->( DBGoTo( nRecno ) )

oBrowse:Refresh()

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} FMarkExc

Realiza a exclusão dos registros selecionados da base do TAF, inclusive
as informações de validação destes registros na tabela CU0. 

@Param		oBrowse	->	Objeto contendo campo de seleção

@Return	Nil

@Author	Felipe C. Seolin
@Since		16/04/2015
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function FMarkExc( oBrowse )

Local oProcess	as object
Local cAlias		as character
Local cAliasBrw	as character
Local cLayout		as character
Local cEscopo		as character
Local cMark		as character
Local nRecno		as numeric
Local aArea		as array
Local aInfo		as array
Local aRegExc		as array
Local aCU0			as array
Local lEnd			as logical

oProcess	:=	Nil
cAlias		:=	""
cAliasBrw	:=	oBrowse:Alias()
cLayout	:=	""
cEscopo	:=	""
cMark		:=	oBrowse:Mark()
nRecno		:=	0
aArea		:=	( cXERPAlias )->( GetArea() )
aInfo		:=	{}
aRegExc	:=	{}
aCU0		:=	{}
lEnd		:=	.F.

( cAliasBrw )->( DBGoTop() )

While ( cAliasBrw )->( !Eof() )

	If ( cAliasBrw )->MARK == cMark

		cAlias := ( cAliasBrw )->TAFALIAS
		nRecno := ( cAliasBrw )->TAFRECNO

		aInfo := TAFRotinas( cAlias, 3, .F., 0 )
		cLayout := aInfo[4]
		cEscopo := aInfo[5]

		aAdd( aRegExc, { cLayout, cAlias, nRecno, cEscopo, aInfo[1] , ( cAliasBrw )->RECNOXERP } )

		( cXERPAlias )->( DBGoTo( ( cAliasBrw )->RECNOXERP ) )
		//TafGrvTick( cXERPAlias, "2",,,,, "3" )
		aSort( aRegExc,,, { |x,y| x[1] > y[1] } )
		aAdd( aCU0, { cAlias, nRecno } )

	EndIf

	( cAliasBrw )->( DBSkip() )
EndDo

If !Empty( aRegExc )
	//oProcess := TAFProgress():New( { |lEnd| TAFExcReg( @lEnd, @oProcess, aRegExc ) }, STR0030 ) //"Excluindo Informações"
	oProcess := TAFProgress():New( { |lEnd| TAFExcReg2( @lEnd, @oProcess, aRegExc ,.f.,.f.,.f.,cXERPAlias, .T.) }, STR0030 ) //"Excluindo Informações"
	oProcess:Activate()

	GravaCU0( 3, aCU0 )
EndIf

( cAliasBrw )->( DBGoTop() )

RestArea( aArea )

TAFEncArr( @aArea )
TAFEncArr( @aInfo )
TAFEncArr( @aRegExc )
TAFEncArr( @aCU0 )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} FGetStatus

Verifica a descrição a ser exibida de acordo com status e
código de erro para cada registro submetido à integração.

@Param		cCodErro	->	Indica o código de erro para registros inconsistentes
			cStatus	->	Indica o status do registro

@Author	Felipe C. Seolin
@Since		15/04/2015
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TafStatusInt( cCodErro, cStatus )

Local cMensagem	as char
Local nPos		as numeric

cMensagem	:=	""
nPos		:=	0

If Empty( cCodErro )
	If cStatus == "1"
		cMensagem := STR0039 //"Registro Incluído com Sucesso"
	ElseIf cStatus == "2"
		cMensagem := STR0040 //"Registro Alterado com Sucesso"
	ElseIf cStatus == "3"
		cMensagem := STR0041 //"Registro Excluído com Sucesso"
	ElseIf cStatus == "6"
		cMensagem := STR0242 //"Registro Inalterado (ID de Integração Única Localizado)"
	EndIf
Else

	If ( nPos := aScan( aCodErro, { |x| x[1] == cCodErro } ) ) > 0
		cMensagem := aCodErro[nPos,2]
	EndIf

	//Acrescenta string informativa sobre registro da fila de integração
	If cStatus == "4"
		cMensagem := STR0188 + cMensagem //'Retornado para Fila. Motivo: ' 
	Endif

EndIf

Return( cMensagem )

//---------------------------------------------------------------------
/*/{Protheus.doc} FShowReg

Exibe a mensagem de integração referente à um registro da tabela TAFST2.

@Param		oBrowse	->	Browse em execução

@Author	Felipe C. Seolin
@Since		17/04/2015
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function FShowReg( oBrowse )

Local oModal		as object
Local cMsg			as character
Local cErro			as character
Local cAlias		as character
Local cLayout		as character
Local nRecnoST2		as numeric
Local nRecnoXERP	as numeric
Local aAreaST2		as array
Local aAreaXERP		as array

Local cTempPath := "" 
Local cFile 	:= ""
Local cTpLayout	:= ""
Local cTafKey	:= ""

Local lNewDialog := .F.

Default oBrowse	:= Nil

oModal		:=	Nil
cMsg		:=	""
cErro		:=	""
cAlias		:=	oBrowse:Alias()
cLayout		:= ""
nRecnoST2	:=	( cAlias )->RECNOST2
nRecnoXERP	:=	( cAlias )->RECNOXERP
aAreaST2	:=	( cST2Alias )->( GetArea() )
aAreaXERP	:=	( cXERPAlias )->( GetArea() )

//Posiciono o registro
( cXERPAlias )->( DBGoTo( nRecnoXERP ) )
cErro := ( cXERPAlias )->TAFERR

//Posiciono o registro
( cST2Alias )->( DBGoTo( nRecnoST2 ) )
cMsg := ( cST2Alias )->TAFMSG

//Recebo o tipo da mensagem
cTpLayout :=( cST2Alias )->TAFCODMSG

//TafKey
cTafKey :=( cST2Alias )->TAFKEY

// Se o XML passar de 1mb, abro uma nova tela
If AllTrim(cTpLayout) == "2" .And. Len(cMsg) > 1048575
	lNewDialog := .T.
EndIf	

If lNewDialog
	cTempPath 	:= GetTempPath(.T.)
	cFile 		:= cTempPath + Dtos(dDataBase) + "_" + "XmlView.xml'
	oFileXML := FCREATE(cFile)

	If oFileXML>0
		FWrite(ofileXML, cMsg)
		FClose(ofileXML)
	EndIf
EndIF

//Recebo o layout do registro
cLayout := ( cST2Alias )->TAFTPREG

//Verifico se o usuário corrente tem acesso a rotina
If FPerAcess(,Alltrim(cLayout))

	If lNewDialog

		oDlg := TDialog():New(150,150,700,900,STR0042,,,,,,,,,.T.)
		
		If Empty( cErro )
			oXml := TXMLViewer():New(05, 05, oDlg , cFile, 370, 250, .T. )
			TButton():New( 258 , 05 , STR0234 , oDlg ,{|| CopiaXml(cFile,cTafKey), .T. } , 40 , 13 ,,,,.T.,.F.,,.T.,,,.F.)	//Gerar XML
		Else
			TMultiGet():New( 005, 005, { || cErro }, oDlg, 369, 040,, .T. ,,,, .T.,,,,,, .T.,,,,, .T. )
			oXml := TXMLViewer():New(50, 05, oDlg , cFile, 370, 205, .T. )
			TButton():New( 258 , 05 , STR0234 , oDlg ,{|| CopiaXml(cFile,cTafKey), .T. } , 40 , 13 ,,,,.T.,.F.,,.T.,,,.F.)	//Gerar XML
		EndIf
		
		If oXml:setXML(cFile)
			Alert(STR0235) //"O arquivo XML não foi gerado corretamente!"
		Else	
			oDlg:Activate()
		EndIf

	Else
		oModal := FWDialogModal():New()
		oModal:SetTitle( STR0042 ) //"Mensagem de Integração"
		oModal:SetFreeArea( 250, 250 )
		oModal:SetEscClose( .T. )
		oModal:SetBackground( .T. )
		oModal:CreateDialog()
		oModal:AddCloseButton()

		//Nos casos em que exista mensagem de erro do registro, a tela exibe as duas informações
		If Empty( cErro )
			TMultiGet():New( 030, 020, { || cMsg }, oModal:GetPanelMain(), 210, 190,, .T. ,,,, .T.,,,,,, .T.,,,,, .T. )
		Else
			TSay():New( 010, 020, { || STR0087 }, oModal:GetPanelMain(),,,,,, .T.,,, 210, 010 ) //"Ocorrência(s) de erro"
			TMultiGet():New( 020, 020, { || cErro }, oModal:GetPanelMain(), 210, 095,, .T. ,,,, .T.,,,,,, .T.,,,,, .T. )
			TSay():New( 125, 020, { || STR0088 }, oModal:GetPanelMain(),,,,,, .T.,,, 210, 010 ) //"Mensagem"
			TMultiGet():New( 135, 020, { || cMsg }, oModal:GetPanelMain(), 210, 095,, .T. ,,,, .T.,,,,,, .T.,,,,, .T. )
		EndIf

		oModal:Activate()

	EndIF	

EndIf

If lNewDialog
	//Apaga o arquivo da pasta temporaria
	FErase(cFile)
EndIf

RestArea( aAreaST2 )
RestArea( aAreaXERP )

TAFEncArr( @aAreaST2 )
TAFEncArr( @aAreaXERP )


Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} FBrwFiltro

Cria interface para seleção do filtro usado na tela de detalhes do Ticket

@Param		oBrowse	->	Objeto Browse referente a dela de detalhes do Ticket
			cTicket	->	Código do Ticket

@Author	Paulo V.B. Santana
@Since		01/10/2015
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function FBrwFiltro( oBrowse, cTicket, aParamT, cCodFil )

Local oDlg			as object
Local oBrwFil		as object
Local cAliasMon	as character
Local cAlias		as character
Local cMark		as character
Local cSqlMon		as character
Local cSql			as character
Local nTop			as numeric
Local nLeft			as numeric
Local nI			as numeric
Local aSize			as array
Local aStruct		as array
Local bMarkFil	as codeblock

oDlg		:=	Nil
oBrwFil		:=	Nil
cAliasMon	:=	""
cAlias		:=	""
cMark		:=	GetMark()
cSqlMon		:=	""
cSql		:=	FGetQuery( "PANELFILTRO", cTicket, cMark ,,,aParamT,cCodFil)
nTop		:=	0
nLeft		:=	0
nI			:=	0
aSize		:= FWGetDialogSize( oMainWnd )
aStruct		:= FGetStruct( "PANELFILTRO", @cAlias, cSql )
bMarkFil	:=	{ || Processa( { ||	( cStatus := FStatSel( oBrwFil ),;
												cCodErr := FRetErr( oBrwFil ),;
												cSqlMon := FGetQuery( "PANELTICKET", cTicket,, cStatus, cCodErr,aParamT,cCodFil ),;
												FGetStruct( "PANELTICKET", @cAliasMon, cSqlMon ),;
												oBrowse:SetAlias( cAliasMon ),;
												oBrowse:GoTop(),;
												oBrowse:Refresh(),;
												oDlg:End() ),;
												STR0007, STR0008 } ) } //##"Processando" ##"Aplicando Filtros"

nTop	:=	( aSize[1] + aSize[3] ) / 2
nLeft	:=	( aSize[2] + aSize[4] ) / 2

oDlg := MsDialog():New( nTop, nLeft, aSize[3], aSize[4], STR0055,,,,,,,,, .T.,,,, .F. ) //"Status do Registro

oBrwFil := FWMarkBrowse():New()
oBrwFil:SetOwner( oDlg )
oBrwFil:SetDataTable()
oBrwFil:SetAlias( cAlias )
oBrwFil:SetMenuDef( "" )
oBrwFil:SetWalkThru( .F. )
oBrwFil:SetAmbiente( .F. ) 
oBrwFil:DisableReport()
oBrwFil:DisableConfig()

For nI := 1 to Len( aStruct[1] )
	oBrwFil:AddLegend( aStruct[1,nI,1], aStruct[1,nI,2], aStruct[1,nI,3] )
Next nI

oBrwFil:SetFieldMark( "MARK" )
oBrwFil:SetAllMark( { || FMarkAll( oBrwFil ) } )
oBrwFil:SetColumns( aStruct[2] )
oBrwFil:SetUseFilter( .F. )

oBrwFil:AddButton( STR0056, bMarkFil ) //"Filtrar"

oBrwFil:Activate()

oDlg:Activate()

TAFEncArr( @aSize )
TAFEncArr( @aStruct )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} FStatSel

Rotina para retornar o Status selecionado

@Param		oBrowse	->	Objeto Browse contendo o Mark do filtro

@Return	cStatus	->	Status selecionado

@Author	Paulo V.B. Santana
@Since		05/10/2015
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function FStatSel( oBrowse )

Local cAlias	as character
Local cMark	as character
Local cStatus	as character
Local nRecno	as numeric

cAlias	:=	oBrowse:Alias()
cMark	:=	oBrowse:Mark()
cStatus	:=	""
nRecno	:=	( cAlias )->( Recno() )

( cAlias )->( DBGoTop() )

While ( cAlias )->( !Eof() )
	If ( cAlias )->MARK == cMark
		If !Empty( ( cAlias )->TAFSTATUS )
			cStatus += ( cAlias )->TAFSTATUS + "', '"
		EndIf
	EndIf

	( cAlias )->( DBSkip() )
EndDo

cStatus := SubStr( cStatus, 1 , Len( cStatus ) - 4 )

( cAlias )->( DBGoTo( nRecno ) )

Return( cStatus )

//---------------------------------------------------------------------
/*/{Protheus.doc} FRetErr

Rotina para retornar o Status Selecionados

@Param		oBrowse	->	Objeto Browse contendo o Mark do filtro

@Return	cCodErr	->	Erro selecionado

@Author	Paulo V.B. Santana
@Since		05/10/2015
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function FRetErr( oBrowse )

Local cAlias	as character
Local cMark	    as character
Local cCodErr	as character
Local nRecno	as numeric

cAlias	:=	oBrowse:Alias()
cMark	:=	oBrowse:Mark()
cCodErr	:=	""
nRecno	:=	( cAlias )->( Recno() )

( cAlias )->( DBGoTop() )

While ( cAlias )->( !Eof() )
	If ( cAlias )->MARK == cMark
		If !Empty( ( cAlias )->TAFCODERR )
			cCodErr += ( cAlias )->TAFCODERR + "', '"
		EndIf
	EndIf
	( cAlias )->( DBSkip() )
EndDo

cCodErr := SubStr( cCodErr, 1 , Len( cCodErr ) - 4 )

( cAlias )->( DBGoTo( nRecno ) )

Return( cCodErr )

//---------------------------------------------------------------------
/*/{Protheus.doc} FRetDescr

Rotina para retornar a descrição do status do Ticket

@Param		cStatus	->	Indica o status do registro

@Return	cDescr		->	Descrição do status do registro na TAFXERP

@Author	Paulo V.B. Santana
@Since		05/10/2015
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function FRetDescr( cStatus )

Local cDescr	as character

cDescr	:=	""

If AllTrim( cStatus ) == "1"
	cDescr := STR0039 //"Registro Incluído com Sucesso"
ElseIf AllTrim( cStatus ) == "2"
	cDescr := STR0040 //"Registro Alterado com Sucesso"
ElseIf AllTrim( cStatus ) == "3"
	cDescr := STR0041 //"Registro Excluído com Sucesso"
ElseIf AllTrim( cStatus ) == "6"
	cDescr := STR0242 //"Registro Inalterado (ID de Integração Única Localizado)"
ElseIf AllTrim( cStatus ) == "7"
	cDescr := STR0227 //"Registro não integrado devido erro de Predecessão"
ElseIf AllTrim( cStatus ) == "8"
	cDescr := STR0066 //"Filial não cadastrada no Cadastro de Complemento de Empresa do TAF"
ElseIf AllTrim( cStatus ) == "9"
	cDescr := STR0067 //"Processo de Integração Abortado"
EndIf

Return( cDescr )

//---------------------------------------------------------------------
/*/{Protheus.doc} FMonGoToView

Executa interface para manutenção de informações nos cadastros do TAF.

@Param		cMonitor	->	Indica o monitor da operação executada
			nOpc		->	Indica a operação a ser realizada
			oBrowse	->	Browse em execução
			nRedView	->  Percentual de redução da view

@Author	Felipe C. Seolin
@Since		14/04/2015
@Version	1.0
/*/
//---------------------------------------------------------------------
Function FMonGoToView( cMonitor, nOpc, oBrowse, nRedView)

Local cAliasMon	    as character
Local cAlias		as character
Local cRotina		as character
Local cValidF3	    as character
Local cEscopo		as character
Local nRecno		as numeric

Local nI			as numeric
Local nOk			as numeric
Local aButtons	    as array
Local aLogErro	    as array
Local aArea		    as array
Local aCU0			as array
Local aInfo		    as array
Local lRet			as logical

//Variavel necessária para a abertura do evento S-2399
Private lPainel 	as logical
Private nOperView	as numeric

Default nRedView := 25

cAliasMon	:=	oBrowse:Alias()
cAlias		:=	""
cRotina	:=	""
cValidF3	:=	""
cEscopo	:=	""
nRecno		:=	0
nOperation	:=	0
nI			:=	0
nOk			:=	0
aButtons	:=	{ { .T., Nil }, { .T., Nil }, { .T., Nil }, { .T., Nil }, { .T., Nil }, { .T., Nil }, { .T., Nil }, { .T., Nil }, { .T., Nil }, { .T., Nil }, { .T., Nil }, { .T., Nil }, { .T., Nil }, { .T., Nil } }
aLogErro	:=	{}
aArea		:=	{}
aCU0		:=	{}
aInfo		:=	{}
lRet		:=	.F.

If cMonitor == "VALIDACAO"

	If nOpc == 1
		cAlias := "CU0"
		nRecno := ( cAliasMon )->RECNO
	ElseIf nOpc == 4
		cAlias := ( cAliasMon )->CU0_ALIAS
		nRecno := ( cAliasMon )->CU0_RECNO
	EndIf

ElseIf cMonitor == "INTEGRACAO"

	cAlias := ( cAliasMon )->TAFALIAS
	nRecno := ( cAliasMon )->TAFRECNO

EndIf

//Posiciono no registro
DBSelectArea( cAlias )
( cAlias )->( DBGoTo( nRecno ) )

//Verifico se o registro foi posicionado com sucesso
If ( cAlias )->(!Eof()) //!Empty( (cAlias)->&(cAlias + "_ID") )  
	
	//Tratamento para a tabela C9V/C91 que possui varios eventos vinculados e assim pode ter o retorno incorreto no TAFROTINAS, passando o evento garanto
	//que o cadastro a ser executado pelo EXECVIEW é o correto (E-Social)
	If cAlias == 'C9V' .or. cAlias =='C91' 
		cNomEve := ( Left((cAlias)->&(cAlias+"_NOMEVE"),1) + '-' + Substring((cAlias)->&(cAlias+"_NOMEVE"),2,Len((cAlias)->&(cAlias+"_NOMEVE")) ) ) 
		aInfo := TAFRotinas( cNomEve, 4, .F., 0 )

		If cNomEve == "S-2399"
			lPainel := .T.
		EndIf
		
	elseif cAlias == 'CU0'
		aadd( aInfo, 'TAFMONVIEW' )
	Else
		aInfo := TAFRotinas( cAlias, 3, .F., 0 )
	Endif
		
	//Recebo a rotina
	cRotina := aInfo[1] 
	

	//Verifico se o usuário corrente tem acesso a rotina
	If cAlias == 'CU0' .or. UserAccess(cRotina) 
	
		If cMonitor == "INTEGRACAO"
		
			If ( cAlias )->( Deleted() )
		
				Aviso( STR0051, STR0052, { STR0036 }, 3 ) //#STR0034#"Registro Não Encontrado" #STR0035#"O registro selecionado se refere a um registro que não existe na base de dados." #STR0036#"Fechar"
		
				aAdd( aCU0, { cAlias, nRecno } )
				GravaCU0( 3, aCU0 )
		
				lRet := .T.
		
			Else
				//Visualizar
				If nOpc == 1
					nOperView := MODEL_OPERATION_VIEW
				//Alterar
				ElseIf nOpc == 4
					nOperView := MODEL_OPERATION_UPDATE
				//Excluir
				ElseIf nOpc == 5
					nOperView := MODEL_OPERATION_DELETE
				EndIf
				
                If nOpc == 5 .and. cAlias == "C9V"
                    nOk := FWExecView( STR0005, cRotina, nOperView,,,, nRedView, aButtons ) //"Monitor de Integração"

                ElseIf !"C9V"$cAlias
                    nOk := FWExecView( STR0005, cRotina, nOperView,,,, nRedView, aButtons ) //"Monitor de Integração"

				Else
					nOk := AltCadTrab()
				EndIf
		
				If nOk == 0
		
					aArea := ( cXERPAlias )->( GetArea() )
		
					( cXERPAlias )->( DBGoTo( ( cAliasMon )->RECNOXERP ) )
		
					If nOpc == 4
						TafGrvTick( cXERPAlias, "2",,,,, "2" )
		
						aAdd( aCU0, { cAlias, nRecno } )
						GravaCU0( 3, aCU0 )

						if len(aInfo) >= 2 .And. ValType( aInfo[2] ) == "U"
							if ValType( aInfo[1] ) == "C" .And. ValType( aInfo[3] ) == "C" .And. Upper(AllTrim(aInfo[3])) == "T71"
								cRotina := aInfo[1]
							endif
						else //demais casos
							cRotina := aInfo[2]
						endif						
						cEscopo := aInfo[5]

						If !Empty(cRotina)
							aLogErro := &cRotina.( cAlias, nRecno,, .T. )
						EndIf	
		
						If !Empty( aLogErro )
							aCU0 := {}
							For nI := 1 to Len( aLogErro )
								cValidF3 := Iif( cEscopo == "3", xVldECFStr( aLogErro[nI,2] ), xValStrEr( aLogErro[nI,2] ) )
								aAdd( aCU0, { aLogErro[nI,3], aLogErro[nI,4], "1", aLogErro[nI,2], cValidF3, "", "3", aLogErro[nI,1], Iif( Len( aLogErro[nI] ) == 5, aLogErro[nI,5], "" ) } )
							Next nI
		
							GravaCU0( 1, aCU0,,,, .T. )
						EndIf
		
						lRet := .T.
		
					ElseIf nOpc == 5
						TafGrvTick( cXERPAlias, "2",,,,, "3" )
		
						aAdd( aCU0, { cAlias, nRecno } )
						GravaCU0( 3, aCU0 )
		
						lRet := .T.
					EndIf
		
					RestArea( 	aArea )
		
				EndIf
		
			EndIf
		
			( cAlias )->( DBCloseArea() )
		
		ElseIf cMonitor == "VALIDACAO"
		
			If cAlias == "CU0"
				DBSelectArea( cAlias )
				( cAlias )->( DBGoTo( nRecno ) )
		
				cAlias := CU0->CU0_ALIAS
				nRecno := CU0->CU0_RECNO
			EndIf
		
			DBSelectArea( cAlias )
			( cAlias )->( DBGoTo( nRecno ) )
		
			If ( cAlias )->( Deleted() )
		
				Aviso( STR0051, STR0052, { STR0036 }, 3 ) //#STR0034#"Registro Não Encontrado" #STR0035#"O registro selecionado se refere a um registro que não existe na base de dados." #STR0036#"Fechar"
		
				aAdd( aCU0, { cAlias, nRecno } )
				GravaCU0( 3, aCU0 )
		
				lRet := .T.
		
			Else
		
				//Visualizar
				If nOpc == 1
					nOperation := MODEL_OPERATION_VIEW
					cRotina := "TAFMONVIEW"
				//Corrigir
				ElseIf nOpc == 4
					nOperation := MODEL_OPERATION_UPDATE
				EndIf
				
				If !"C9V"$cAlias
					nOk := FWExecView( STR0006, cRotina, nOperation,,{|| .T.},, nRedView, aButtons ) //"Monitor de Validação"			
				Else
					nOk := AltCadTrab()
				EndIf
		
				If nOk == 0
		
					If nOpc == 4

						aAdd( aCU0, { cAlias, nRecno } )

						GravaCU0( 3, aCU0 )

						if 	len(aInfo) >= 5 .And. ValType( aInfo[2] ) == "U" .And. ValType( aInfo[1] ) == "C" ;
							.And. ValType( aInfo[3] ) == "C" .And. Upper(AllTrim(aInfo[3])) == "T71"
							cRotina := aInfo[1]
						else
							cRotina := aInfo[2]
						endif
						cEscopo := aInfo[5]

						if ValType( aInfo[3] ) == "C" 
							//apos confirmar a alteracao, nao se viu necessario abrir o cadastro da autocontida inteira, 
							//mesmo sendo um modelo aberto para o T71 CEST
							if Upper(AllTrim(aInfo[3])) <> "T71" .and. !Empty(cRotina)
								aLogErro := &cRotina.( cAlias, nRecno,, .T. )
							endif
						else //demais casos
							aLogErro := &cRotina.( cAlias, nRecno,, .T. )
						endif

						If !Empty( aLogErro )
							aCU0 := {}
							For nI := 1 to Len( aLogErro )
								cValidF3 := Iif( cEscopo == "3", xVldECFStr( aLogErro[nI,2] ), xValStrEr( aLogErro[nI,2] ) )
								aAdd( aCU0, { aLogErro[nI,3], aLogErro[nI,4], "1", aLogErro[nI,2], cValidF3, "", "3", aLogErro[nI,1], Iif( Len( aLogErro[nI] ) == 5, aLogErro[nI,5], "" ) } )
							Next nI
		
							GravaCU0( 1, aCU0,,,, .T. )
						EndIf
		
						lRet := .T.
		
					EndIf
		
				EndIf
		
			EndIf
		
			( cAlias )->( DBCloseArea() )
		
		EndIf
		
	EndIf

Else

	Aviso( STR0051, STR0052, { STR0036 }, 3 ) //#STR0034#"Registro Não Encontrado" #STR0035#"O registro selecionado se refere a um registro que não existe na base de dados." #STR0036#"Fechar"

	lRet := .T.

EndIf

TAFEncArr( @aButtons )
TAFEncArr( @aArea )
TAFEncArr( @aCU0 )

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} FGetStruct

Estrutura para construção das interfaces.

@Param		cPanel		->	Indica o painel desejado para retorno de estrutura
			cAlias		->	Alias para utilização como referência
			cSql		->	Estrutura da consulta

@Return	aStruct	->	Array com a estrutura para objeto Browse
								[4] - Array de Legendas
								[5] - Array de Colunas( Campos )

@Author	Felipe C. Seolin
@Since		24/04/2015
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function FGetStruct( cPanel, cAlias, cSql,lUpdBrw )

Local cBancoDB	as character
Local aStruct		as array
Local aField		as array
Local aLegend		as array
Local aIndex		as array
Local aColumn		as array
Local aDicion		as array
Local nX := 0

Default lUpdBrw := .F.

cBancoDB	:=	Upper( AllTrim( TCGetDB() ) )
aStruct		:=	{}
aField		:=	{}
aLegend		:=	{}
aIndex		:=	{}
aColumn		:=	{}
aDicion		:= 	{}

//----------------------------------------------
// Estrutura para criação de arquivo temporário
// [01] - Nome
// [02] - Tipo
// [03] - Tamanho
// [04] - Decimal
// [05] - Descrição
// [06] - Picture
// [07] - Indica exibição na Browse
// [08] - Indica índice de ordenação
//----------------------------------------------
If cPanel == "PANEL04"

	//If !( cBancoDB $ "POSTGRES|OPENEDGE" )
		aAdd( aField, { "LEGEND"	, "C", 01, 0, STR0068, "", .F., "" } ) //"Legenda"
	//EndIf
	aAdd( aField, { "FILIAL"	, "C", 40, 0, "Filial", "", .T., "" } ) //"Ticket"
	aAdd( aField, { "TAFTICKET"	, "C", 36, 0, STR0069, "", .T., "1" } ) //"Ticket"
	aAdd( aField, { "TAFDATA"	, "D", 08, 0, STR0070, "", .T., "2" } ) //"Data"
	aAdd( aField, { "TAFHORA"	, "C", 08, 0, STR0071, "", .T., "" } ) //"Hora"

	If !lUpdBrw
		aAdd( aIndex, "FILIAL" )
		aAdd( aIndex, "DTOS(TAFDATA)+TAFHORA" )
		aAdd( aIndex, "TAFTICKET" )

	//If !( cBancoDB $ "POSTGRES|OPENEDGE" )
		aAdd( aLegend, { { || LEGEND == "1" }, "YELLOW"	, STR0016 } ) //"Ticket Pendente"
		aAdd( aLegend, { { || LEGEND == "2" }, "RED"		, STR0090 } ) //"Ticket com Inconsistência(s)"
		aAdd( aLegend, { { || LEGEND == "3" }, "GREEN"	, STR0015 } ) //"Ticket Integrado"
	//EndIf

		aColumn := FGetColumn( aField )
	EndIf
	
ElseIf cPanel == "PANEL05"
	aAdd( aField, { "CU0_FILIAL"	, "C", TamSX3( "CU0_FILIAL" )[1]	, TamSX3( "CU0_FILIAL" )[2]	, Eval( { || SX3->( MsSeek( "CU0_FILIAL" ) ), X3Titulo() } )	, PesqPict( "CU0", "CU0_FILIAL" )	, .T., "" } )
	aAdd( aField, { "CU0_DTOCOR"	, "D", TamSX3( "CU0_DTOCOR" )[1]	, TamSX3( "CU0_DTOCOR" )[2]	, Eval( { || SX3->( MsSeek( "CU0_DTOCOR" ) ), X3Titulo() } )	, PesqPict( "CU0", "CU0_DTOCOR" )	, .T., "1" } )
	aAdd( aField, { "CU0_MENU"		, "C", 80								, 0								, STR0072																, ""									, .T., "2" } ) //"Menu"
	aAdd( aField, { "CU0_CPOERR"	, "C", TamSX3( "CU0_CPOERR" )[1]	, TamSX3( "CU0_CPOERR" )[2]	, Eval( { || SX3->( MsSeek( "CU0_CPOERR" ) ), X3Titulo() } )	, PesqPict( "CU0", "CU0_CPOERR" )	, .T., "" } )
	aAdd( aField, { "CU0_DESCRI"	, "C", 220								, 0								, STR0091																, ""									, .T., "" } ) //"Descrição"
	aAdd( aField, { "CU0_ERRO"		, "C", 220								, 0								, STR0073																, ""									, .T., "" } ) //"Erro"
	aAdd( aField, { "CU0_ALIAS"		, "C", TamSX3( "CU0_ALIAS" )[1]		, TamSX3( "CU0_ALIAS" )[2]	, Eval( { || SX3->( MsSeek( "CU0_ALIAS" ) ), X3Titulo() } )		, PesqPict( "CU0", "CU0_ALIAS" )	, .F., "" } )
	aAdd( aField, { "CU0_RECNO"		, "N", TamSX3( "CU0_RECNO" )[1]		, TamSX3( "CU0_RECNO" )[2]	, Eval( { || SX3->( MsSeek( "CU0_RECNO" ) ), X3Titulo() } )		, PesqPict( "CU0", "CU0_RECNO" )	, .F., "" } )
	aAdd( aField, { "RECNO"			, "N", 008								, 0								, STR0074																, ""									, .F., "" } ) //"Recno"

	If !lUpdBrw
		aAdd( aIndex, "CU0_FILIAL" )
		aAdd( aIndex, "CU0_DTOCOR" )
		aAdd( aIndex, "CU0_MENU" )

		aColumn := FGetColumn( aField )
	EndIf

	DBSelectArea( "CU0" )

ElseIf cPanel == "PANELTICKET"

	aAdd( aField, { "TAFSTATUS"	, "C", 001, 0, STR0068,, .F., "" } ) //"Legenda"
	aAdd( aField, { "TAFKEY"		, "C", 100, 0, STR0075,, .T., "1"} ) //"Chave"
	aAdd( aField, { "TAFTPREG"	, "C", 040, 0, STR0093,, .T., "" } ) //"Cadastro"
	aAdd( aField, { "TAFCODERR"	, "C", 006, 0, STR0076,, .T., "" } ) //"Status"
	aAdd( aField, { "RECNOST2"	, "N", 008, 0, STR0077,, .F., "" } ) //"Recno ST2"
	aAdd( aField, { "TAFALIAS"	, "C", 003, 0, STR0078,, .F., "" } ) //"Alias"
	aAdd( aField, { "TAFRECNO"	, "N", 008, 0, STR0074,, .F., "" } ) //"Recno"
	aAdd( aField, { "RECNOXERP"	, "N", 008, 0, STR0079,, .F., "" } ) //"Recno XERP"

	If !lUpdBrw
		aAdd( aIndex, "TAFKEY" )
	
		aAdd( aLegend, { { || TAFSTATUS == "1" }						, "GREEN"	, STR0047 } ) //"Inclusão"
		aAdd( aLegend, { { || TAFSTATUS == "2" }						, "YELLOW"	, STR0048 } ) //"Alteração"
		aAdd( aLegend, { { || TAFSTATUS == "3" }						, "GRAY"	, STR0049 } ) //"Exclusão"
		aAdd( aLegend, { { || TAFSTATUS == "4" }						, "ORANGE"	, STR0190 } ) //"Fila de Integração"
		aAdd( aLegend, { { || TAFSTATUS == "5" }						, "BLUE"	, STR0191 } ) //"Exclusão direta (eSocial)"
		aAdd( aLegend, { { || TAFSTATUS == "6" }						, "WHITE"	, STR0242 } ) //"Registro Inalterado (ID de Integração Única Localizado)"
		aAdd( aLegend, { { || TAFSTATUS == "7" }						, "BROWN"	, STR0228 } ) //"Predecessão"
		aAdd( aLegend, { { || TAFSTATUS == "8" .or. TAFSTATUS == "9" }	, "RED"		, STR0050 } ) //"Inconsistência"

		aColumn := FGetColumn( aField )
	EndIf

ElseIf cPanel == "PANELMARK"

	aAdd( aField, { "MARK"		, "C", 002, 0, STR0080,, .F., ""  } ) //"Mark"
	aAdd( aField, { "TAFSTATUS"	, "C", 001, 0, STR0068,, .F., ""  } ) //"Legenda"
	aAdd( aField, { "TAFKEY"	, "C", 100, 0, STR0075,, .T., "1" } ) //"Chave"
	aAdd( aField, { "TAFTPREG"	, "C", 040, 0, STR0093,, .T., ""  } ) //"Cadastro"
	aAdd( aField, { "TAFCODERR"	, "C", 006, 0, STR0076,, .T., ""  } ) //"Status"
	aAdd( aField, { "RECNOST2"	, "N", 008, 0, STR0077,, .F., ""  } ) //"Recno ST2"
	aAdd( aField, { "TAFALIAS"	, "C", 003, 0, STR0078,, .F., ""  } ) //"Alias"
	aAdd( aField, { "TAFRECNO"	, "N", 008, 0, STR0074,, .F., ""  } ) //"Recno"
	aAdd( aField, { "RECNOXERP"	, "N", 008, 0, STR0079,, .F., ""  } ) //"Recno XERP"

	If !lUpdBrw	
		aAdd( aIndex, "TAFKEY" )
		
		aAdd( aLegend, { { || TAFSTATUS == "1" }, "GREEN" , STR0047 } ) //"Inclusão"
		aAdd( aLegend, { { || TAFSTATUS == "2" }, "YELLOW", STR0048 } ) //"Alteração"

		aColumn := FGetColumn( aField )
	EndIf
	
ElseIf cPanel == "PANELFILTRO"

	aAdd( aField, { "MARK"		, "C", 002, 0, STR0080,, .F., "" } ) //"Mark"
	aAdd( aField, { "TAFSTATUS"	, "C", 001, 0, STR0076,, .T., "" } ) //"Status"
	aAdd( aField, { "TAFCODERR"	, "C", 006, 0, STR0081,, .T., "1" } ) //"Tipo de Inconsistência"

	If !lUpdBrw
		aAdd( aIndex, "TAFCODERR" )
		aColumn := FGetColumn( aField )
	EndIf

EndIf

//-------------------------------------------
// Cria e popula arquivo de dados temporário
//-------------------------------------------
FBuildTemp( cPanel, @cAlias, cSql, aField, aIndex,lUpdBrw )

//----------------------
// Estrutura dos campos
//----------------------

For nX := 1 To Len(aColumn)
					//1 Nome do Campo  2 Titulo           3 Tipo de Dado  4 Tamanho        5 Decimal        6 Picture
	aAdd(aDicion,{ afield[nX+1][1]	, aColumn[nX]:cTitle, aColumn[nX]:cType, aColumn[nX]:nSize,aColumn[nX]:nDecimal, aColumn[nX]:xPicture} )	             
Next nX

//----------------------
// Estrutura de colunas
//----------------------
If !lUpdBrw
	aAdd( aStruct, aClone( aLegend ) )
	aAdd( aStruct, aClone( aColumn ) )
	aAdd( aStruct, aClone( aDicion) )
EndIf

//---------------------------------
// Limpeza de variáveis em memória
//---------------------------------
TAFEncArr( @aField )
TAFEncArr( @aLegend )
TAFEncArr( @aIndex )
TAFEncArr( @aColumn )

Return( aStruct )

//---------------------------------------------------------------------
/*/{Protheus.doc} FGetColumn

Carrega estrutura de colunas da uma Browse.

@Param		aStruct	->	Array com a estrutura de campos

@Return	aColumns	->	Array com a estrutura de colunas objeto Browse

@Author	Felipe C. Seolin
@Since		10/11/2015
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function FGetColumn( aStruct )

Local cCombo		as character
Local nPos			as numeric
Local nI			as numeric
Local aColumns		as array
Local aCombo		as array

cCombo		:=	""
nPos		:=	0
nI			:=	0
aColumns	:=	{}
aCombo		:=	{}

For nI := 1 to Len( aStruct )
	If aStruct[nI,7]

		nPos ++

		aAdd( aColumns, FWBrwColumn():New() )

		If aStruct[nI,1] == "TAFCODERR"
			aColumns[nPos]:SetData( { || Iif( !Empty( TAFCODERR ), TAFCODERR + " - ", "" ) + TafStatusInt( TAFCODERR, TAFSTATUS ) } )
		ElseIf aStruct[nI,1] == "TAFSTATUS"
			aColumns[nPos]:SetData( { || TAFSTATUS + " - " + FRetDescr( TAFSTATUS ) } )
		Else
			aColumns[nPos]:SetData( &( "{ || " + aStruct[nI,1] + " }" ) )
		EndIf

		aColumns[nPos]:SetTitle( aStruct[nI,5] )
		aColumns[nPos]:SetSize( aStruct[nI,3] )
		aColumns[nPos]:SetDecimal( aStruct[nI,4] )
		aColumns[nPos]:SetPicture( aStruct[nI,6] )
		aColumns[nPos]:SetType( aStruct[nI,2] )
		aColumns[nPos]:SetAlign( Iif( aStruct[nI,2] == "N", 2, 1 ) )

		If aStruct[nI,2] == "C"
			DBSelectArea( "SX3" )
			SX3->( DBSetOrder( 2 ) )
			If SX3->( MsSeek( aStruct[nI,1] ) )
				cCombo := X3Cbox()
			EndIf

			If !Empty( cCombo )
				aCombo := StrToKarr( cCombo, ";" )
				aColumns[nPos]:SetOptions( aCombo )
			EndIf
		EndIf

	EndIf
Next nI

Return( aColumns )

//---------------------------------------------------------------------
/*/{Protheus.doc} FColOrd

Funcionalidade para ordenação em coluna do Browse.

@Param		oBrw	->	Objeto contendo colunas do Browse

@Return	Nil

@Author	Felipe C. Seolin
@Since		18/11/2015
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function FColOrd( oBrw )

Local cAlias	as character
Local nI		as numeric
Local nInd		as numeric 
Local nIndKey	as numeric

cAlias	:=	oBrw:Alias()
nI		:=	0
nInd	:=	( cAlias )->( DBOrderInfo( 9 ) ) //DBOI_OrderCount 
nIndKey	:=	( cAlias )->( IndexOrd() )

For nI := 1 to nInd
	If nI == nIndKey
		oBrw:SetHeaderImage( nI + 1, "VCRIGHT" )
	Else
		( cAlias )->( DBSetOrder( nI ) )
		oBrw:SetHeaderImage( nI + 1, "VCDOWN" )
	EndIf
Next nI

oBrowse01:Refresh()
oBrowse02:Refresh()

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} FBuildTemp

Funcionalidade para ordenação em coluna do Browse.

@Param		cPanel		->	Indica o painel desejado para retorno de estrutura
			cAlias		->	Alias para utilização como referência
			cSql		->	Estrutura da consulta
			aField		->	Campos para tabela temporária
			aIndex		->	Índices para tabela temporária
			lUpdBrw 	->  Informa que a opereção é de atualização

@Return	Nil

@Author	Felipe C. Seolin
@Since		23/11/2015
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function FBuildTemp( cPanel, cAlias, cSql, aField, aIndex,lUpdBrw )

Local cAliasQry	as character
Local cIndex		as character
Local cMenu		as character
Local cErro		as character
Local cSqlInto		as character
Local cSqlDel		as character
Local cNameTable	as character
Local nI		as numeric
Local nX		as numeric
Local nPos		as numeric
Local nPos1		as numeric
Local nPos2		as numeric
Local nPosPanel		as numeric
Local aTemp		as array
Local aAux		as array
Local xConteudo
Local oTempTable 	as object
Local lVirgula   	as logical
Local cBancoDB as character

Default lUpdBrw := .F.

cBancoDB	:=	Upper( AllTrim( TCGetDB() ) )
cAliasQry	:=	GetNextAlias()
cIndex		:=	""
cMenu		:=	""
cErro		:=	""
cSqlInto	:=	""
cNameTable	:=  ""
nI			:=	0
nPos		:=	0
nPos1		:=	0
nPos2		:=	0
nPosPanel	:=	0
aTemp		:=	{}
aAux		:=	{}
xConteudo	:=	Nil
oTempTable 	:=  Nil 

For nI := 1 to Len( aField )
	aAdd( aTemp, { aField[nI,1], aField[nI,2], aField[nI,3], aField[nI,4] } )
Next nI

If lUpdBrw

	nPosPanel	:= aScan(aArqTemp,{|p|p[1] == cPanel})
	cNameTable	:= aArqTemp[nPosPanel][4]
	cAlias		:= aArqTemp[nPosPanel][3]

	If cBancoDB $ "POSTGRES|OPENEDGE|MSSQL"
		cSqlDel := "DELETE FROM "+ cNameTable
	Else
		cSqlDel := "DELETE "+ cNameTable
	EndIf
	If TCSQLExec (cSqlDel) < 0
		MessageBox(TCSQLError(),"",MB_ICONHAND)
	EndIf	
Else
	
	cAlias := GetNextAlias()
	oTempTable := FWTemporaryTable():New(cAlias)
	oTempTable:SetFields(aTemp)
	
	For nI := 1 To Len(aIndex)
	
		aAux := StrTran( aIndex[nI]	, "DTOS("		, "" )
		aAux := StrTran( aAux		, "STR("		, "" )
		aAux := StrTran( aAux		, "DESCEND("	, "" )
		aAux := StrTran( aAux		, ")"			, "" )
		
		aAux := StrTokArr(aAux,"+")
		
		oTempTable:AddIndex("cIndex" + AllTrim(Str(nI)),aAux) 
		aAux := {}
	Next nI	
		
	oTempTable:Create()

	aAdd(aArqTemp,{cPanel,oTempTable,cAlias, oTempTable:GetRealName()})
	
EndIf

/*+--------------------------------------------------------------+
  | Data:24.05.2017	     	                                 |
  | Responsável: Evandro dos Santos Oliveira             	 |
  | Descrição da Alteração: Modificado função de criação         |
  | da tabela temporária .. todos os browses estão utilizando    |
  | o arquivo no banco; o Painel 5 é o unico que está gravando   |
  | os registros via RecLock por que é necessário tratar os      |
  | dados antes da inserção.		   	 	         |
  +--------------------------------------------------------------+*/ 	
If cPanel == "PANEL05"

	TCQuery cSql New Alias &cAliasQry
	TCSetField( cAliasQry, "CU0_DTOCOR", "D", 8, 0 )

	While ( cAliasQry )->( !Eof() )
	
		If cPanel == "PANEL05"
			CU0->( DBGoTo( ( cAliasQry )->RECNO ) )
	
			aAux := StrToKArr( CU0->CU0_DCODER, "-" )
	
			For nI := 1 to Len( aAux )
				If nI == 1
					cMenu := aAux[nI]
				ElseIf nI == 3
					cErro := aAux[nI]
				ElseIf nI > 3
					cErro += "-" + aAux[nI]
				EndIf
			Next nI
		EndIf
	
		dbSelectArea(cAlias)
		If RecLock(cAlias, .T. )
	
			For nI := 1 to Len( aTemp )
				nPos1 := ( cAlias )->( FieldPos( aTemp[nI,1] ) )
	
				If aTemp[nI,1] == "CU0_MENU"
					xConteudo := AllTrim( cMenu )
				ElseIf aTemp[nI,1] == "CU0_ERRO"
					xConteudo := AllTrim( cErro )
				ElseIf aTemp[nI,1] == "MARK"
					xConteudo := "  "
				ElseIf aTemp[nI,1] == "CU0_DESCRI"
					xConteudo := AllTrim( Eval( { || SX3->( MsSeek( AllTrim( ( cAliasQry )->CU0_CPOERR ) ) ), X3Descric() } ) )
				ElseIf aTemp[nI,1] == "TAFTPREG"
					xConteudo := FGetX2Nome( AllTrim( ( cAliasQry )->TAFTPREG ) )
				Else
					nPos2 := ( cAliasQry )->( FieldPos( aTemp[nI,1] ) )
					xConteudo := ( cAliasQry )->( FieldGet( nPos2 ) )
				EndIf
	
				( cAlias )->( FieldPut( nPos1, xConteudo ) )
			Next nI
	
			( cAlias )->( MsUnLock(), DBCommit() )
		EndIf
	
		( cAliasQry )->( DBSkip() )
	EndDo
	
	( cAliasQry )->( DBCloseArea() )
	
	If cPanel == "PANEL05"
		CU0->( DBCloseArea() )
	EndIf
	
	( cAlias )->( DBGoTop() )
Else
	If Empty(cNameTable)
 		cSqlInto := "INSERT INTO " + oTempTable:GetRealName() 
	Else
		cSqlInto := "INSERT INTO " + cNameTable
	EndIf

 	cSqlInto += "("
	For nX := 1 To Len(aField)
		IIf (lVirgula,cSqlInto += ",",lVirgula := .T.)
		cSqlInto += aField[nX][1]
	Next nX
 	cSqlInto += ") "

 	If "INFORMIX" $ Upper( AllTrim( TCGetDB() ) )
 		cSqlInto += "SELECT * FROM (" + cSql + ")"
 	Else
 		cSqlInto += cSql
 	EndIf

	If TCSQLExec (cSqlInto) < 0
		MessageBox(TCSQLError(),"",MB_ICONHAND)
	EndIf	

	(cAlias)->(dBGoTop())
EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} FGetQuery

Construção de consultas para os diversos painéis.

@Param		cPanel		->	Indica o painel desejado para retorno de estrutura
			cTicket	->	Identificação do Ticket para filtro na consulta
			cMark		->	Marca utilizada para identificar seleção
			cStatus	->	Filtro de status do registro
			cCodErr	->	Filtro de código do erro do registro
			aParamT	-> 	Parâmetros de Filtro
			
@Param		cSql		->	Estrutura da consulta

@Author	Felipe C. Seolin
@Since		09/04/2015
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function FGetQuery( cPanel, cTicket, cMark, cStatus, cCodErr , aParamT,cCodFil, cCodFil2)

Local cSql			:= ""
Local cBancoDB		:= Upper( AllTrim( TCGetDB() ) )
Local cIsNull		:= ""
Local lCR9Priority	:= GetNewPar( "MV_TAFCFGE", .F. )

Default	cCodFil2 := " "

If cBancoDB == "INFORMIX|ORACLE|"
	cIsNull	:= "NVL"
ElseIf cBancoDB $ "POSTGRES|OPENEDGE"
	cIsNull := "ifnull" 
ElseIf cBancoDB $ "DB2"
	cIsNull := "COALESCE"
Else
	cIsNull := "ISNULL"	
EndIf

/*+--------------------------------------------------------------------+
  | Obs:							       | 
  | A ordem do SELECT deve ser a mesma do array de campos na FGetStruct|
  | para permitir a utilização do INSET INTO (SELECT ... ) na função   |
  | FBuildTemp.                                                        |
  +--------------------------------------------------------------------+*/ 	
If cPanel == "PANEL02"

	cSql := "SELECT TAFST2.TAFSTATUS, COUNT( DISTINCT TAFTICKET ) NCOUNT "
	cSql += "FROM TAFST2 TAFST2 "
	cSql += "WHERE TAFST2.D_E_L_E_T_ = ' ' "
	cSql += "  AND TAFST2.TAFFIL IN(" + cCodFil + ") "

	If !Empty( DToS( paramDataInicio ) + DToS( paramDataFinal ) )
		cSql += "  AND TAFST2.TAFDATA BETWEEN '" + DToS( paramDataInicio ) +  "' AND '" + DToS( paramDataFinal ) +  "' "
	EndIf

	//Validação do escopo do registro a ser apresentado
	If aParamT[6] == 1
		cSql += " AND TAFST2.TAFCODMSG = '2' "
	Else
		cSql += " AND TAFST2.TAFCODMSG = '1' "
	EndIf

	cSql += "GROUP BY TAFST2.TAFSTATUS "

ElseIf cPanel == "PANEL03"

	cSql := "SELECT TAFXERP.TAFSTATUS, COUNT(*) NCOUNT "
	cSql += "FROM TAFXERP TAFXERP "
	cSql += "INNER JOIN TAFST2 TAFST2 "
	cSql += "  ON TAFST2.TAFFIL IN(" + cCodFil + ") "
	cSql += " AND TAFST2.TAFKEY = TAFXERP.TAFKEY "
	cSql += " AND TAFST2.TAFTICKET = TAFXERP.TAFTICKET "
	cSql += " AND TAFST2.D_E_L_E_T_ = ' ' "
	cSql += "WHERE TAFXERP.D_E_L_E_T_ = ' ' "

	If !Empty( DToS( paramDataInicio ) + DToS( paramDataFinal ) )
		cSql += "  AND TAFXERP.TAFDATA BETWEEN '" + DToS( paramDataInicio ) +  "' AND '" + DToS( paramDataFinal ) +  "' "
	EndIf

	//Validação do escopo do registro a ser apresentado
	If aParamT[6] == 1
		cSql += " AND TAFST2.TAFCODMSG = '2' "
	Else
		cSql += " AND TAFST2.TAFCODMSG = '1' "
	EndIf

	cSql += "GROUP BY TAFXERP.TAFSTATUS "

ElseIf cPanel == "PANEL04"

	If cBancoDB $ "OPENEDGE"

		cSql += "SELECT DISTINCT "
		cSql += "   CASE "
		cSql += "      WHEN MIN(TAFXERPB.TAFSTATUS) IN  ( '1', '2' ) "
		cSql += "      THEN '1'  "
		cSql += "      WHEN MIN(TAFXERPB.TAFSTATUS) NOT IN ('1', '2', '3', '4', '5', '6') "
		cSql += "      THEN '2'  "
		cSql += "      ELSE '3'  END LEGEND,  "
		cSql += "   CASE "
		cSql += "      WHEN C1EA.C1E_FILTAF IS NOT NULL  "
		cSql += "	   THEN C1EA.C1E_FILTAF  "
		cSql += "      WHEN C1EB.C1E_FILTAF IS NOT NULL  "
        cSql += "      THEN C1EB.C1E_FILTAF "
		cSql += " 	   ELSE CR9.CR9_CODFIL END C1E_FILTAF, "
		cSql += " TAFST2A.TAFTICKET, TAFST2A.TAFDATA, TAFST2A.TAFHORA  "
		cSql += " FROM "
		cSql += "   TAFST2 TAFST2A  "
		cSql += "   INNER JOIN "
		cSql += "      TAFXERP TAFXERPB  "
		cSql += "      ON TAFXERPB.TAFKEY = TAFST2A.TAFKEY  "
		cSql += "      AND TAFXERPB.D_E_L_E_T_ = ' '  "
		cSql += "   LEFT JOIN "
		cSql += "      " + RetSqlName('C1E') + " C1EA  "
		cSql += "      ON C1EA.C1E_FILIAL = '         '  "
		cSql += "      AND C1EA.C1E_ATIVO = '1'  "
		cSql += "      AND C1EA.D_E_L_E_T_ = ' '  "
		cSql += "      AND C1EA.C1E_CODFIL = TAFST2A.TAFFIL  "
		cSql += "   LEFT JOIN " 
		cSql += "		" + RetSqlName("C1E") + " C1EB 
		cSql += " 		ON C1EB.C1E_FILIAL = '"+ xFilial('C1E') + "' "
		cSql += "		AND C1EB.C1E_ATIVO = '1' "
		cSql += "		AND C1EB.D_E_L_E_T_ = ' ' "
		cSql += "   LEFT JOIN "
		cSql += "      " + RetSqlName('CR9') + " CR9  "
		cSql += "      ON CR9.D_E_L_E_T_ = ' '  "
		cSql += "      AND CR9.CR9_ATIVO = '1'  "
		cSql += "      AND CR9.CR9_CODFIL = TAFST2A.TAFFIL  "
		cSql += "WHERE "
		cSql += "   TAFST2A.D_E_L_E_T_ = ' '  "
		cSql += "   AND TAFST2A.TAFFIL IN  (" + cCodFil + ") "

		If !Empty( DToS( paramDataInicio ) + DToS( paramDataFinal ) )
			cSql += "  AND TAFST2A.TAFDATA BETWEEN '" + DToS( paramDataInicio ) +  "' AND '" + DToS( paramDataFinal ) +  "' " 
		EndIf

		//Validação do escopo do registro a ser apresentado
		If aParamT[6] == 1
			cSql += " AND TAFST2A.TAFCODMSG = '2' "
		Else
			cSql += " AND TAFST2A.TAFCODMSG = '1' "
		EndIf

		cSql += "GROUP BY TAFST2A.TAFFIL,TAFST2A.TAFTICKET, TAFST2A.TAFDATA, TAFST2A.TAFHORA, TAFXERPB.TAFSTATUS, C1EB.C1E_FILTAF, C1EA.C1E_FILTAF, CR9.CR9_CODFIL "
		cSql += "ORDER BY TAFST2A.TAFDATA, TAFST2A.TAFHORA, TAFST2A.TAFTICKET "

	Else
		cSql += " SELECT "
		//If !( cBancoDB $ "POSTGRES|OPENEDGE" )
			cSql += "CASE ( SELECT DISTINCT '1' "
			cSql += "              FROM TAFST2 TAFST2B "
			cSql += "			   WHERE TAFST2B.TAFFIL IN(" + cCodFil + ") "
			cSql += "				AND TAFST2A.TAFTICKET = TAFST2B.TAFTICKET "
			cSql += "		    	AND TAFST2B.TAFSTATUS IN ( '1', '2' ) "
			cSql += "				AND TAFST2B.D_E_L_E_T_ = ' ' ) "
			cSql += "       WHEN '1' THEN '1' "
			cSql += "       ELSE ( CASE ( SELECT DISTINCT '2' "
			cSql += "                     FROM TAFST2 SUBST2 "
			cSql += "                     INNER JOIN TAFXERP TAFXERPB "
			cSql += "                     ON SUBST2.TAFTICKET = TAFXERPB.TAFTICKET "
			cSql += "                     	AND SUBST2.TAFKEY = TAFXERPB.TAFKEY "
			cSql += "                     	AND SUBST2.D_E_L_E_T_ = TAFXERPB.D_E_L_E_T_ "
			cSql += "                     	AND TAFXERPB.TAFSTATUS IN ( '7', '8', '9' ) "
			cSql += " 					  	WHERE SUBST2.TAFFIL IN(" + cCodFil + ") "
			cSql += " 					  		AND SUBST2.TAFTICKET = TAFST2A.TAFTICKET "
			cSql += " 					  		AND SUBST2.D_E_L_E_T_ = ' ' ) "
			cSql += "              WHEN '2' THEN '2' "
			cSql += "              ELSE '3' "
			cSql += "              END ) "
			cSql += "       END AS LEGEND, "
			
			//Validação do escopo do registro a ser apresentado
			If lCR9Priority .And. aParamT[6] == 1
				cSql += "       ISNULL( (SELECT DISTINCT CASE "
				cSql += "                         WHEN C1E.C1E_FILTAF IS NOT NULL THEN C1E.C1E_FILTAF "
				cSql += "                         ELSE (SELECT DISTINCT min(C1E.C1E_FILTAF) "
				cSql += "                               FROM " + RetSqlName('CR9') + " CR9 "
				cSql += "                                      LEFT JOIN " + RetSqlName("C1E") + " C1E "
				cSql += "                                             ON C1E.C1E_FILIAL = '"+ xFilial('C1E') +"' "
				cSql += "                                                AND C1E.C1E_ID = CR9.CR9_ID "
				cSql += "                                                AND C1E.D_E_L_E_T_ = ' ' AND C1E_ATIVO = '1' "
				cSql += "                               WHERE  CR9.D_E_L_E_T_ = ' ' AND CR9_ATIVO = '1'  "
				cSql += "                                      AND CR9.CR9_CODFIL = TAFST2A.TAFFIL) "
				cSql += "                       END "
				cSql += "       FROM TAFST2 ST2 "
				cSql += " LEFT JOIN " + RetSQLName("CR9") + " CR9 "
				cSql += " ON  CR9.CR9_FILIAL = '" + xFilial("CR9") + "' "
				cSql += " 	AND  CR9.CR9_CODFIL = TAFST2A.TAFFIL "
				cSql += " 	AND  CR9.CR9_ATIVO = '1' "
				cSql += " 	AND  CR9.D_E_L_E_T_ = ' ' "
				cSql += " INNER JOIN " + RetSqlName('C1E') + " C1E "
				cSql += " 	ON  C1E.C1E_FILIAL = CR9.CR9_FILIAL"
				cSql += "  	AND C1E.C1E_ID = CR9.CR9_ID "
				cSql += "	AND C1E.C1E_ATIVO = '1' "
				cSql += "   AND C1E.D_E_L_E_T_ = ' ' "
				cSql += " ), 
				cSql += "( SELECT MIN(C1E.C1E_FILTAF)
				cSql += " 	FROM TAFST2 ST2
				cSql += " 	INNER JOIN " + RetSQLName("C1E") + " C1E "
				cSql += " 	ON C1E.C1E_FILIAL = '" + xFilial("C1E") + "' "
				
				
				If cBancoDB <> "POSTGRES"
					cSql += "    AND C1E.C1E_CODFIL = ST2.TAFFIL "
					cSql += "    AND C1E.D_E_L_E_T_ = ' ' AND C1E_ATIVO = '1' "
					cSql += "    WHERE ST2.D_E_L_E_T_ = ' ' AND ST2.TAFFIL IN(" + cCodFil + ") "
				Else
					cSql += "    AND C1E.C1E_CODFIL = TAFST2A.TAFFIL "
					cSql += "    AND C1E.D_E_L_E_T_ = ' ' AND C1E_ATIVO = '1' "
				EndIf
				
				cSql += " )) "
				cSql += " C1E_FILTAF "
			Else
				cSql += "       (SELECT DISTINCT CASE "
				cSql += "                         WHEN C1E.C1E_FILTAF IS NOT NULL THEN C1E.C1E_FILTAF "
				cSql += "                         ELSE (SELECT DISTINCT min(C1E.C1E_FILTAF) "
				cSql += "                               FROM " + RetSqlName('CR9') + " CR9 "
				cSql += "                                      LEFT JOIN " + RetSqlName("C1E") + " C1E "
				cSql += "                                             ON C1E.C1E_FILIAL = '"+ xFilial('C1E') +"' "
				cSql += "                                                AND C1E.C1E_ID = CR9.CR9_ID "
				cSql += "                                                AND C1E.D_E_L_E_T_ = ' ' AND C1E_ATIVO = '1' "
				cSql += "                               WHERE  CR9.D_E_L_E_T_ = ' ' AND CR9_ATIVO = '1'  "
				cSql += "                                      AND CR9.CR9_CODFIL = TAFST2A.TAFFIL) "
				cSql += "                       END "
				cSql += "       FROM TAFST2 ST2 "
				cSql += "    LEFT JOIN " + RetSqlName('C1E') + " C1E "
				cSql += "    ON  C1E.C1E_FILIAL = '" + xFilial('C1E') + "' "

				If cBancoDB <> "POSTGRES"
					cSql += "    AND C1E.C1E_CODFIL = ST2.TAFFIL "
					cSql += "    AND C1E.D_E_L_E_T_ = ' ' AND C1E_ATIVO = '1' "
					cSql += "    WHERE ST2.D_E_L_E_T_ = ' ' AND ST2.TAFFIL = TAFST2A.TAFFIL "
				Else
					cSql += "    AND C1E.C1E_CODFIL = TAFST2A.TAFFIL "
					cSql += "    AND C1E.D_E_L_E_T_ = ' ' AND C1E_ATIVO = '1' "
				EndIf

				cSql += " ) "
				cSql += " C1E_FILTAF "
			EndIf

		//EndIf

		cSql += ",TAFST2A.TAFTICKET "
		cSql += ",TAFST2A.TAFDATA "
		cSql += ",TAFST2A.TAFHORA "

		cSql += "FROM TAFST2 TAFST2A "

		cSql += "WHERE TAFST2A.D_E_L_E_T_ = ' ' "
		cSql += " AND TAFST2A.TAFFIL IN(" + cCodFil + ") "

		If !Empty( DToS( paramDataInicio ) + DToS( paramDataFinal ) )
			cSql += "  AND TAFST2A.TAFDATA BETWEEN '" + DToS( paramDataInicio ) +  "' AND '" + DToS( paramDataFinal ) +  "' " 
		EndIf

		//Validação do escopo do registro a ser apresentado
		If aParamT[6] == 1
			cSql += " AND TAFST2A.TAFCODMSG = '2' "
		Else
			cSql += " AND TAFST2A.TAFCODMSG = '1' "
		EndIf

		cSql += "GROUP BY TAFST2A.TAFFIL, TAFST2A.TAFTICKET, TAFST2A.TAFDATA, TAFST2A.TAFHORA "
		cSql += "ORDER BY TAFST2A.TAFDATA, TAFST2A.TAFHORA, TAFST2A.TAFTICKET "
	EndIf

ElseIf cPanel == "PANEL05"

	cSql := " SELECT "
	cSql += " CU0.CU0_FILIAL"
	cSql += ",CU0.CU0_DTOCOR"
	cSql += ",CU0.CU0_CPOERR"
	cSql += ",CU0.CU0_ALIAS"
	cSql += ",CU0.CU0_RECNO"
	cSql += ",CU0.R_E_C_N_O_ RECNO"
	cSql += " FROM " + RetSqlName( "CU0" ) + " CU0 "
	if !empty(cCodFil2)
		cSql += " WHERE CU0.CU0_FILIAL IN(" + cCodFil2 + ") "
	else
		cSql += " WHERE CU0.CU0_FILIAL = '" + xFilial( "CU0" ) + "' "
	endif
	cSql += " AND CU0.D_E_L_E_T_ = ' ' "

	If !Empty( DToS( paramDataInicio ) + DToS( paramDataFinal ) )
		cSql += "  AND CU0.CU0_DTOCOR BETWEEN '" + DToS( paramDataInicio ) +  "' AND '" + DToS( paramDataFinal ) +  "' "
	EndIf

ElseIf cPanel == "PANELTICKET"

	cSql := " SELECT TAFXERP.TAFSTATUS,"  
	cSql += cIsNull + "(TAFXERP.TAFKEY, ' ') TAFKEY,"
	cSql += cIsNull + "(TAFST2.TAFTPREG,' ') TAFTPREG,"
	cSql += cIsNull + "(TAFXERP.TAFCODERR,' ') TAFCODERR,"
	cSql += cIsNull + "(TAFST2.R_E_C_N_O_,0) RECNOST2,"
	cSql += cIsNull + "(TAFXERP.TAFALIAS, ' ') TAFALIAS,"
	cSql += cIsNull + "(TAFXERP.TAFRECNO,0) TAFRECNO,"
	cSql += cIsNull + "(TAFXERP.R_E_C_N_O_,0) RECNOXERP"
	cSql += " FROM TAFXERP TAFXERP "
	cSql += " INNER JOIN TAFST2 TAFST2 "
	cSql += " ON TAFST2.TAFFIL IN(" + cCodFil + ") "
	cSql += " AND TAFST2.TAFKEY = TAFXERP.TAFKEY "
	cSql += " AND TAFST2.TAFTICKET = TAFXERP.TAFTICKET "
	cSql += " AND TAFST2.D_E_L_E_T_ = ' ' "
	cSql += "WHERE TAFXERP.TAFTICKET = '" + cTicket + "' "
	cSql += "  AND TAFXERP.D_E_L_E_T_ = ' ' "

	If !Empty( cStatus )
		cSql += "  AND TAFXERP.TAFSTATUS IN ( '" + cStatus + "' ) "
	EndIf

	If !Empty( cCodErr )
		cSql += "  AND TAFXERP.TAFCODERR IN ( '" + cCodErr + "' ) "
	EndIf

	//Validação do escopo do registro a ser apresentado
	If aParamT[6] == 1
		cSql += " AND TAFST2.TAFCODMSG = '2' "
	Else
		cSql += " AND TAFST2.TAFCODMSG = '1' "
	EndIf	

ElseIf cPanel == "PANELMARK"

	cSql := "SELECT '" + Space( Len( cMark ) ) + "' MARK"
	cSql += ",TAFXERP.TAFSTATUS" 
	cSql += ",TAFXERP.TAFKEY"
	cSql += ",TAFST2.TAFTPREG TAFTPREG"
	cSql += ",TAFXERP.TAFCODERR"
	cSql += ",TAFST2.R_E_C_N_O_ RECNOST2"
	cSql += ",TAFXERP.TAFALIAS"
	cSql += ",TAFXERP.TAFRECNO"
	cSql += ",TAFXERP.R_E_C_N_O_ RECNOXERP"

	cSql += " FROM TAFXERP TAFXERP "
	cSql += " LEFT JOIN TAFST2 TAFST2 "
	cSql += " ON TAFST2.TAFFIL IN(" + cCodFil + ") "
	cSql += " AND TAFST2.TAFKEY = TAFXERP.TAFKEY "
	cSql += " AND TAFST2.TAFTICKET = TAFXERP.TAFTICKET "
	cSql += " AND TAFST2.D_E_L_E_T_ = ' ' "
	cSql += " WHERE TAFXERP.TAFTICKET = '" + cTicket + "' "
	cSql += " AND TAFXERP.TAFSTATUS IN ( '1', '2' ) "
	cSql += " AND TAFXERP.TAFALIAS <> 'C1E' "	//Desconsidero o que foi integrado para a C1E para evitar que o Compl. Empresa seja excluído
	cSql += " AND TAFXERP.D_E_L_E_T_ = ' ' "

	//Validação do escopo do registro a ser apresentado
	If aParamT[6] == 1
		cSql += " AND TAFST2.TAFCODMSG = '2' "
	Else
		cSql += " AND TAFST2.TAFCODMSG = '1' "
	EndIf

ElseIf cPanel == "PANELFILTRO"

	cSql := " SELECT '" + Space( Len( cMark ) ) + "' MARK"
	cSql += ",TAFXERP.TAFSTATUS"
	cSql += ",TAFXERP.TAFCODERR"
	cSql += " FROM TAFXERP TAFXERP "
	cSql += " LEFT JOIN TAFST2 TAFST2 "
	cSql += " ON TAFST2.TAFFIL IN(" + cCodFil + ") "
	cSql += " AND TAFST2.TAFKEY = TAFXERP.TAFKEY "
	cSql += " AND TAFST2.TAFTICKET = TAFXERP.TAFTICKET "
	cSql += " AND TAFST2.D_E_L_E_T_ = ' ' "
	cSql += "WHERE TAFXERP.TAFTICKET = '" + cTicket + "' "

	//Validação do escopo do registro a ser apresentado
	If aParamT[6] == 1
		cSql += " AND TAFST2.TAFCODMSG = '2' "
	Else
		cSql += " AND TAFST2.TAFCODMSG = '1' "
	EndIf


	cSql += "GROUP BY TAFXERP.TAFSTATUS, TAFXERP.TAFCODERR "
	cSql += "ORDER BY TAFXERP.TAFSTATUS, TAFXERP.TAFCODERR "

EndIf


If "INFORMIX" $ Upper( AllTrim( TCGetDB() ) )
	cSql := "SELECT * FROM (" + cSql + ") SUB1"
EndIf

If !( cPanel $ "PANEL04|PANELTICKET|PANELMARK|PANELFILTRO" .and. TCGetDB() == "DB2" ) 
	cSql := ChangeQuery( cSql )
EndIf

Return( cSql )


//---------------------------------------------------------------------
/*/{Protheus.doc} FGetX2Nome

Função que retornar a descrição da tabela

@Param	cTAFTpReg	->	Código no Layout TOTVS ( conteúdo TAFTPREG )

@Return	cX2Nome		->	Descrição da tabela

@Author	Luccas Curcio
@Since	06/04/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function FGetX2Nome( cTAFTpReg )

Local cX2Nome		as character
Local cAliasTAF	as character
Local nPosRot		as numeric
Local aRotinas	as array

Default	cTAFTpReg	:=	""
Default	aLayXAlias	:=	{}

cX2Nome		:=	""
cAliasTAF	:=	""
nPosRot		:=	0
aRotinas	:=	{}

//Caso o Layout não tenha sido informado, retorno mensagem de cadastro não encontrado no TAF
If Empty( cTAFTpReg )
	cX2Nome	:=	STR0092	//"Cadastro não encontrado"

//Caso exista o Layout, utilizo-o para encontrar o Alias do TAF e retornar a descrição utilizando FWX2Nome
Else
	
	//Procuro o alias inicialmente no array estático que possui a relação layout x alias
	If ( nPos := aScan( aLayXAlias , { |x| x[ 1 ] == cTAFTpReg  } ) ) > 0
		cAliasTAF	:=	aLayXAlias[ nPos , 2]
	
	//Se não encontrar utilizo o TAFROTINAS para buscar o alias
	Else
		aRotinas	:=	TAFRotinas( , , .T. )
		
		If ( nPos := aScan( aRotinas , { |x| x[ 4 ] ==  cTAFTpReg } ) ) > 0
			cAliasTAF	:=	aRotinas[ nPos , 3 ]
			
			//Adiciono o layout x alias no array estático
			aAdd( aLayXAlias , { cTAFTpReg , cAliasTAF } )
		Endif
	Endif
	
	If !( Empty( cAliasTAF ) )
		//Se encontrar o alias, busco a descrição através da função FWX2Nome
		If Empty( cX2Nome	:=	FWX2Nome( cAliasTAF ) )
			cX2Nome	:=	STR0096 //"Tabela não encontrada"
		Endif
	Endif
	
Endif

//Se não encontrar a tabela ou descrição da tabela através da FWX2Nome, utiliza o próprio nome do Layout TOTVS
If Empty( cX2Nome )
	cX2Nome	:=	cTAFTpReg
Endif

Return( cX2Nome )


//---------------------------------------------------------------------
/*/{Protheus.doc} CopiaXml

Copia o xml para a pasta System

@Author	Fabio V Santana
@Since		13/09/2018
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function CopiaXml(cFile,cTafKey)

Local cStartPath	:=	GetSrvProfString( "StartPath" , "" )
Local lRet 			:= .F.
Local cNomeArq		:= AllTrim(StrTran(UPPER(cTafKey), ".XML","")) + "_" + Dtos(dDataBase) + ".Xml"

//Tratamento para Linux onde a barra eh invertida
If GetRemoteType() == 2
	If !Empty( cStartPath ) .and. ( SubStr( cStartPath, Len( cStartPath ), 1 ) <> "/" )
		cStartPath +=	"/"
	EndIf
Else
	If !Empty(cStartPath) .and. ( SubStr( cStartPath, Len( cStartPath ), 1 ) <> "\" )
		cStartPath +=	"\"
	EndIf
EndIf

lRet := _copyfile( cFile, cStartPath + cNomeArq)

If lRet 
	MsgAlert(STR0236 + CRLF + CRLF + cNomeArq) //"Xml gerado na pasta System."
Else
	MsgAlert(STR0237 + CRLF + STR0238) //"Não foi possível a gravação do XML na pasta System." + "Verifique as permissões de gravação em disco."
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FPanelMSG
Apresenta a mensagem de possível inconsistência
@author  Victor A. Barbosa
@since   07/02/2019
@version 1
/*/
//-------------------------------------------------------------------
Function FPanelMSG(oOwner)

Local oFont 	:= TFont():New('Arial',,-16,.T.)
Local cMsgInfo	:= '<font size="3" color="#FF0000">Devido ao parametro MV_TACFGE estar habilitado, a coluna filial irá demonstrar a informação de acordo com o cadastro de complemento de empresas atual.</font>'

TSay():New(01,01,{||cMsgInfo},oOwner,,oFont,,,,.T.,,,700,20,,,,,,.T.)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} UserAccess
Analisa permissão de acesso de rotinas do TAF, para tratar rotinas 
encapsuladas sem acesso através do menu.
@author Ricardo Lovrenovic
@since  14/08/2020
@version 1
/*/
//-------------------------------------------------------------------

Static Function UserAccess(cRotina)

Local	lRet 	:=	.T.

Default cRotina :=	""


	If cRotina $ "TAFA275|TAFA276|TAFA279"
		lRet :=	FPerAcess(,,,,"TAFA421") 
	Else 
		lRet :=	FPerAcess(,,,,cRotina) 
	EndIf


Return(lRet)