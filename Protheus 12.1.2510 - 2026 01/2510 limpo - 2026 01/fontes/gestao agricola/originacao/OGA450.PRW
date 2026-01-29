#INCLUDE "OGA450.ch"
#include "protheus.ch"
#INCLUDE "PRCONST.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEDITPANEL.CH"
#INCLUDE "SIGAWIN.CH"

Static __lnewNeg		:= SuperGetMv('MV_AGRO002', , .F.) // Parametro de utilização do novo modelo de negocio

/** {Protheus.doc} OGA450
Tela de gestor de entidade.

@param: 	pcCodEnt - Código da entidade
@param: 	pcLojEnt - Loja da entidade
@author: 	Marlon Richard Trettin
@since: 	17/10/14
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGA450( pcCodEnt, pcLojEnt)

	Local aCords 	 := FWGetDialogSize( oMainWnd )
	Local oDlg		 := Nil
	Local oFwLayer   := Nil
	Local oPnEnt	 := Nil
	Local oPnSld	 := Nil
	Local oPnCtr	 := Nil
	Local nX         := 0
	Local oBtnAtual
    Local oNomEnt := NIL
	Local oNomLoj := NIL
	Local aRetTRB := {} // Variável que recebe o retorno da criação das tabelas temporárias

	//--- Definição da estrutura da tabela temporária de Saldos ---//
	//[n][01] Nome do campo
	//[n][02] Tipo
	//[n][03] Tamanho
	//[n][04] Decimal
	//[n][05] Titulo
	//[n][06] Picture
	Local aEstruSld := { { "S_FILIAL", "C", TamSX3( "NJR_FILIAL" )[ 1 ], 0 , RetTitle( "NJR_FILIAL" )	, PesqPict("NJR","NJR_FILIAL") },;
	{ "S_TIPO",	"C", TamSX3( "NJR_TIPO" )[ 1 ]	, 0 , RetTitle( "NJR_TIPO" )		, "@" },;
	{ "S_DESTIP", "C", 20 							, 0 , RetTitle( "NJR_TIPO" )		, "@" },;
	{ "S_LOJA",	"C", TamSX3( "NJR_LOJENT" )[ 1 ], 0 , RetTitle( "NJR_LOJENT" )	, "@" },;
	{ "S_CODSAF", "C", TamSX3( "NJR_CODSAF" )[ 1 ], 0 , RetTitle( "NJR_CODSAF" )	, PesqPict("NJR","NJR_CODSAF") },;
	{ "S_CODPRO", "C", TamSX3( "NJR_CODPRO" )[ 1 ], 0 , RetTitle( "NJR_CODPRO" )	, PesqPict("NJR","NJR_CODPRO") },;
	{ "S_DESPRO", "C", TamSX3( "NJR_DESPRO" )[ 1 ], 0 , RetTitle( "NJR_DESPRO" )	, PesqPict("NJR","NJR_DESPRO") },;
	{ "S_UM1PRO", "C", TamSX3( "NJR_UM1PRO" )[ 1 ], 0 , RetTitle( "NJR_UM1PRO" )	, PesqPict("NJR","NJR_UM1PRO") },;
	{ "S_QTDCTR", "N", 19, 2 , RetTitle( "NJR_QTDCTR" ),	"@E 999,999,999,999" },;
	{ "S_QTDFIX", "N", 19, 2 , RetTitle( "NN8_QTDFIX" ),	"@E 999,999,999,999" },;
	{ "S_QTENFX", "N", 19, 2 , STR0016					  ,	"@E 999,999,999,999" },; //Qtd. Ent. Fix.
	{ "S_QTDAFX", "N", 19, 2 , STR0007					  ,	"@E 999,999,999,999" },; // Qtd. a Fixar
	{ "S_QSLFCO", "N", 19, 2 , RetTitle( "NJR_QSLFCO" ),	"@E 999,999,999,999" },;
	{ "S_SLDFIS", "N", 19, 2 , RetTitle( "NJR_SLDFIS" ),	"@E 999,999,999,999" },;
	{ "S_QTEFCO", "N", 19, 2 , RetTitle( "NJR_QTEFCO" ),	"@E 999,999,999,999" },;
	{ "S_QTEFIS", "N", 19, 2 , RetTitle( "NJR_QTEFIS" ),	"@E 999,999,999,999" },;
	{ "S_QTSFCO", "N", 19, 2 , RetTitle( "NJR_QTSFCO" ),	"@E 999,999,999,999" },;
	{ "S_QTSFIS", "N", 19, 2 , RetTitle( "NJR_QTSFIS" ),	"@E 999,999,999,999" },;
	{ "S_DIFFIS", "N", 19, 2 , STR0008                 ,	"@E 999,999,999,999" },; // Dif. Fiscal	
    { "S_QTDRES", "N", 19, 2 , RetTitle( "NJR_QTDRES" ),	"@E 999,999,999,999" },;
	{ "S_QTDROM", "N", 19, 2 , STR0071                 ,    "@E 999,999,999,999" },; //"Qtd.Rom.Pend." 
    { "S_QTDTRF", "N", 19, 2 , STR0004                 ,	"@E 999,999,999,999" } }

	Local aCpBrwSld := {}
	Local aIndSld := { "S_FILIAL+S_TIPO+S_LOJA+S_CODSAF+S_CODPRO+S_UM1PRO", "S_FILIAL+S_LOJA+S_TIPO+S_CODSAF+S_CODPRO" } // Definição dos índices

	//--- Definição da estrutura da tabela temporária de Contratos ---//
	//[n][01] Nome do campo
	//[n][02] Tipo
	//[n][03] Tamanho
	//[n][04] Decimal
	//[n][05] Titulo
	//[n][06] Picture
	Local aEstruCtr := { { "C_FILIAL", "C", TamSX3( "NJR_FILIAL" )[ 1 ], 0 , RetTitle( "NJR_FILIAL" ), PesqPict("NJR","NJR_FILIAL") },;
	{ "C_MODELO", "C", TamSX3( "NJR_MODELO" )[ 1 ], 0 , RetTitle( "NJR_MODELO" ), PesqPict("NJR","NJR_MODELO") },;
	{ "C_STATUS", "C", TamSX3( "NJR_STATUS" )[ 1 ], 0 , RetTitle( "NJR_STATUS" ), PesqPict("NJR","NJR_STATUS") },;
	{ "C_CODCTR", "C", TamSX3( "NJR_CODCTR" )[ 1 ], 0 , RetTitle( "NJR_CODCTR" ), PesqPict("NJR","NJR_CODCTR") },;
	{ "C_DESCRI", "C", TamSX3( "NJR_DESCRI" )[ 1 ], 0 , RetTitle( "NJR_DESCRI" ), PesqPict("NJR","NJR_DESCRI") },;
	{ "C_DATA",	"D", 8 , 0 , RetTitle( "NJR_DATA" ), 	"@D" },;
	{ "C_DATINI", "D", 8 , 0 , RetTitle( "NNY_DATINI" ),	"@D" },;
	{ "C_DATFIM", "D", 8 , 0 , RetTitle( "NNY_DATFIM" ),	"@D" },;
	{ "C_QTDCTR", "N", 19, 2 , RetTitle( "NJR_QTDCTR" ),	"@E 999,999,999,999" },;
	{ "C_QTDFIX", "N", 19, 2 , RetTitle( "NN8_QTDFIX" ),	"@E 999,999,999,999" },;
	{ "C_QTENFX", "N", 19, 2 , STR0016                 ,	"@E 999,999,999,999" },; //Qtd. Ent. Fix.
	{ "C_QTDAFX", "N", 19, 2 , STR0007                 ,	"@E 999,999,999,999" },; // Qtd. a Fixar
	{ "C_QSLFCO", "N", 19, 2 , RetTitle( "NJR_QSLFCO" ),	"@E 999,999,999,999" },;
	{ "C_SLDFIS", "N", 19, 2 , RetTitle( "NJR_SLDFIS" ),	"@E 999,999,999,999" },;
	{ "C_QTEFCO", "N", 19, 2 , RetTitle( "NJR_QTEFCO" ),	"@E 999,999,999,999" },;
	{ "C_QTEFIS", "N", 19, 2 , RetTitle( "NJR_QTEFIS" ),	"@E 999,999,999,999" },;
	{ "C_QTSFCO", "N", 19, 2 , RetTitle( "NJR_QTSFCO" ),	"@E 999,999,999,999" },;
	{ "C_QTSFIS", "N", 19, 2 , RetTitle( "NJR_QTSFIS" ),	"@E 999,999,999,999" },;
	{ "C_DIFFIS", "N", 19, 2 , STR0008                 ,	"@E 999,999,999,999" },; // Dif. Fiscal
	{ "C_QTDRES", "N", 19, 2 , RetTitle( "NJR_QTDRES" ),	"@E 999,999,999,999" },;
	{ "C_QTDROM", "N", 19, 2 , STR0071                 ,    "@E 999,999,999,999" },; //"Qtd.Rom.Pend." 
    { "C_QTDTRF", "N", 19, 2 , STR0004                 ,	"@E 999,999,999,999" },;
	{ "C_RECNO",  "N", 10, 0, "RECNO", "@ 9999999999"} }

	Local aCpBrwCtr 	:= {}
	Local aIndCtr 		:= { "C_FILIAL+C_CODCTR" } // Definição dos índices
	
	//--- Variáveis de acesso às tabelas temporárias ---//
	Private cAliasSld
	Private cTrabSld
	Private cAliasCtr
	Private cTrabCtr
	Private oBrwSld, oBrwCtr
	Private aIndice1, aIndice2

	Private cNoFldSLD	:= "S_TIPO"
	Private cNoFldCTR	:= "C_FILIAL,C_MODELO,C_STATUS,C_RECNO"

	//--- Variáveis de parâmetros de entrada da tela ---//
	Private cCodEnt := Space( TamSX3("NJ0_CODENT")[1] )
	Private cLojEnt := Space( TamSX3("NJ0_LOJENT")[1] )
	Private cNomEnt := Space( TamSX3("NJ0_NOME")[1] )
	Private cNomLoj := Space( TamSX3("NJ0_NOMLOJ")[1] )

	Private aRotAux
    Private cDCodEnt := Space( TamSX3("NJ0_CODENT")[1] )
	Private cDLojEnt := Space( TamSX3("NJ0_LOJENT")[1] )
	Private cDNomEnt := Space( TamSX3("NJ0_NOME")[1] )
	
	cCodEnt := iIf( Empty( pcCodEnt ), cCodEnt, pcCodEnt )
	cLojEnt := iIf( Empty( pcLojEnt ), cLojEnt, pcLojEnt )
	ValEntidade( cCodEnt, cLojEnt ) // Retorna o valor para as variáveis cNomEnt e cLojEnt

	//--- Criação das tabelas temporárias ---//

	// Tabela temporária de Saldos
	aRetTRB := AGRCRIATRB( , aEstruSld, aIndSld, FunName(), .T. )

	cTrabSld 	:= aRetTRB[3] //Nome do arquivo temporário
	cAliasSld 	:= aRetTRB[4] //Nome do alias do arquivo temporario
	aCpBrwSld	:= aRetTRB[5] //Matriz com a estrutura do arquivo temporario + label e picutre

	aIndice1	:= AGRINDICONS(aIndSld, aCpBrwSld )

	// Tabela temporária de Contratos
	aRetTRB := AGRCRIATRB( , aEstruCtr, aIndCtr, FunName(), .T. )

	cTrabCtr 	:= aRetTRB[3] //Nome do arquivo temporário
	cAliasCtr 	:= aRetTRB[4] //Nome do alias do arquivo temporario
	aCpBrwCtr	:= aRetTRB[5] //Matriz com a estrutura do arquivo temporario + label e picutre

	aIndice2	:= AGRINDICONS(aIndCtr, aCpBrwCtr )
     
    //--- Montagem da tela ---//

    oDlg := TDialog():New( aCords[ 1 ], aCords[ 2 ], aCords[ 3 ], aCords[ 4 ], STR0001, , , , , CLR_BLACK, CLR_WHITE, , , .t. ) //"Gestão de Contratos de Compras / Vendas / Armazenagem"

    //--- Layers ---//
    oFwLayer := FwLayer():New()
    oFwLayer:Init( oDlg, .f., .t. )

    // Entidade
    oFWLayer:AddLine( 'LinEntidade', 10, .T. )
    oFWLayer:AddCollumn( 'ColEntidade', 100, .T., 'LinEntidade' )
    oPnEnt := oFWLayer:GetColPanel( 'ColEntidade', 'LinEntidade' )

    // Saldos
    oFWLayer:AddLine( 'LinSaldo', 40, .F. )
    oFWLayer:AddCollumn( 'ColSaldo', 100, .T., 'LinSaldo' )
    oPnSld := oFWLayer:GetColPanel( 'ColSaldo', 'LinSaldo' )

    // Contratos
    oFWLayer:AddLine( 'LinContrato', 50, .F. )
    oFWLayer:AddCollumn( 'ColContrato', 100, .T., 'LinContrato' )
    oPnCtr := oFWLayer:GetColPanel( 'ColContrato', 'LinContrato' )

    // Entidade
    @ 003,005  Say STR0005 COLOR CLR_BLUE Pixel Of oPnEnt //"Entidade"
    @ 001,030  MSGET cCodEnt Picture PesqPict("NJ0","NJ0_CODENT") F3 "NJ0" VALID ValEntidade(cCodEnt,) 			WHEN .T. SIZE 060,010 PIXEL OF oPnEnt
    @ 001,090  MSGET cLojEnt Picture PesqPict("NJ0","NJ0_LOJENT") F3 "NJ0" VALID ValEntidade(cCodEnt,cLojEnt).Or.Empty(cLojEnt) WHEN .T. SIZE 020,010 PIXEL OF oPnEnt 
    @ 001,115  MSGET oNomEnt Var cNomEnt Picture PesqPict("NJ0","NJ0_NOME")   														WHEN .F. SIZE 120,010 PIXEL OF oPnEnt OBFUSCATED AGRLGPD("NJ0_NOME")
    @ 001,235  MSGET oNomLoj Var cNomLoj Picture PesqPict("NJ0","NJ0_NOMLOJ")   													WHEN .F. SIZE 120,010 PIXEL OF oPnEnt OBFUSCATED AGRLGPD("NJ0_NOME")
    // Botão Atualizar
    @ 001,360 BUTTON oBtnAtual PROMPT STR0006	 SIZE 35,012 PIXEL OF oPnEnt ACTION ( A450LoadSld(),A450LoadCtr() ) //"Atualizar"

    DEFINE FWFORMBROWSE oBrwSld DATA TABLE ALIAS cAliasSLD DESCRIPTION STR0002 OF oPnSld //"Saldos"
    oBrwSld:SetTemporary(.T.)
    oBrwSld:SetdbFFilter(.T.)
    oBrwSld:SetUseFilter(.T.)
    oBrwSld:SetFieldFilter(AGRITEMCBRW(aCpBrwSld))
    oBrwSld:SetSeek(,aIndice1)
    oBrwSld:AddLegend( "S_TIPO=='1'", "RED"   ,	X3CboxDesc( "NJR_TIPO", "1" ) ) //Compra
    oBrwSld:AddLegend( "S_TIPO=='2'", "GREEN" ,	X3CboxDesc( "NJR_TIPO", "2" ) ) //Venda
    oBrwSld:AddLegend( "S_TIPO=='3'", "ORANGE",	X3CboxDesc( "NJR_TIPO", "3" ) ) //Armazenagem de 3o.
    oBrwSld:AddLegend( "S_TIPO=='4'", "YELLOW",	X3CboxDesc( "NJR_TIPO", "4" ) ) //Armazenagem em 3o.
    For nx := 1 To Len(aCpBrwSld)
        If !( aCpBrwSld[nX,1] $ cNoFldSLD )
            nTamCpoIDX	:= 1
            If !(aCpBrwSld[nX,2] == "C")
                nTamCpoIDX	:= 0.40			// Indice para Manipulação do tamanho do campo (0.50 Indica que irá utilizar 50 % do tamanho )
            EndIF
            ADD COLUMN oColumn 	DATA 	&('{||'+aCpBrwSld[nX,1]+'}');
            Title	aCpBrwSld[nX,5];
            SIZE	aCpBrwSld[nX,3] * nTamCpoIDX;
            PICTURE	aCpBrwSld[nX,6];
            Align	IIf(aCpBrwSld[nX,2] == "N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT);
            Of oBrwSld
        EndIf
    Next nx
    oBrwSld:bChange := {|| A450LoadCtr() }
    oBrwSld:DisableDetails()
    //		oBrwSld:AddButton(STR0019,	{|| OGA440( cCodEnt, cLojEnt ) },,,,,,'40') //"Movimentações"
    oBrwSld:AddButton(STR0017,  {|| OGA450A(cCodEnt,cLojEnt,(cAliasSLD)->S_CODSAF,(cAliasSLD)->S_CODPRO, (cAliasSLD)->S_TIPO ) },,,,,,'41') 	//"Trf. Mul. Origens"
    oBrwSld:AddButton(STR0009,	{|| OGA280( cCodEnt, cLojEnt ) },,,,,,'42') //"Contr. Compra"
    oBrwSld:AddButton(STR0010,	{|| OGA290( cCodEnt, cLojEnt ) },,,,,,'43') //"Contr. Venda"
    oBrwSld:AddButton(STR0011,	{|| OGA260( cCodEnt, cLojEnt ) },,,,,,'44') //"Contr. Depósito de 3º"
    oBrwSld:AddButton(STR0012,	{|| OGA270( cCodEnt, cLojEnt ) },,,,,,'45') //"Contr. Depósito em 3º"
    oBrwSld:AddButton(STR0018,	{|| OGA261A( cCodEnt, cLojEnt ) },,,,,,'46') //"Serviços.Armaz"
    oBrwSld:AddButton(STR0022,	{|| fVGrafSLD() },,,,,,'47') //"Gráfico"
    ACTIVATE FWFORMBROWSE oBrwSld

    DEFINE FWFORMBROWSE oBrwCtr DATA TABLE ALIAS cAliasCTR DESCRIPTION STR0003 OF oPnCtr //"Contratos"
    oBrwCtr:SetTemporary(.T.)
    oBrwCtr:SetdbFFilter(.T.)
    oBrwCtr:SetUseFilter(.T.)
    oBrwCtr:SetSeek(,aIndice2)
    oBrwCtr:SetFieldFilter(AGRITEMCBRW(aCpBrwCtr))
    oBrwCtr:AddLegend( "C_MODELO=='1'"						, "WHITE"		, X3CboxDesc( "NJR_MODELO", "1" ) ) //Pré-Contrato
    oBrwCtr:AddLegend( "C_MODELO<>'1' .And. C_STATUS=='P'"	, "BLUE"		, X3CboxDesc( "NJR_STATUS", "P" ) ) //Previsto
    oBrwCtr:AddLegend( "C_MODELO<>'1' .And. C_STATUS=='A'"	, "GREEN"		, X3CboxDesc( "NJR_STATUS", "A" ) ) //Aberto
    oBrwCtr:AddLegend( "C_MODELO<>'1' .And. C_STATUS=='I'"	, "YELLOW"		, X3CboxDesc( "NJR_STATUS", "I" ) ) //Iniciado
    oBrwCtr:AddLegend( "C_MODELO<>'1' .And. C_STATUS=='E'"	, "BR_CANCEL"	, X3CboxDesc( "NJR_STATUS", "E" ) ) //Cancelado
    oBrwCtr:AddLegend( "C_MODELO<>'1' .And. C_STATUS=='F'"	, "RED"		, X3CboxDesc( "NJR_STATUS", "F" ) ) //Finalizado
    For nX := 1 To Len(aCpBrwCtr)
        If !( aCpBrwCtr[nX,1] $ cNoFldCTR )
            nTamCpoIDX	:= 1
            If !(aCpBrwCtr[nX,2] == "C")
                nTamCpoIDX	:= 0.40			// Indice para Manipulação do tamanho do campo (0.50 Indica que irá utilizar 50 % do tamanho )
            EndIF
            ADD COLUMN oColumn	DATA 	&('{||'+aCpBrwCtr[nX,1]+'}');
            Title 	aCpBrwCtr[nX,5];
            SIZE 	aCpBrwCtr[nX,3] * nTamCpoIDX;
            PICTURE aCpBrwCtr[nX,6];
            Align	IIf(aCpBrwCtr[nX,2] == "N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT);
            Of oBrwCtr
        EndIf
    Next nX
    oBrwCtr:DisableDetails()
    oBrwCtr:AddButton(STR0013,	{|| oDlg:End()                        },,,,,,'31')	//"Sair"
    oBrwCtr:AddButton(STR0020,	{|| OGC003( (cAliasCTR)->C_CODCTR )   },,,,,,'33')	//"Romaneios"
    oBrwCtr:AddButton(STR0021,	{|| OGX001VCtr( (cAliasCTR)->C_RECNO )},,,,,,'32')	//"Visualizar"
    oBrwCtr:AddButton(STR0014,	{|| At430Btn( (cAliasCTR)->C_CODCTR ) },,,,,,'30')	//"Financeiro"
    oBrwCtr:AddButton(STR0015,  {|| iIf( OGA450B(cCodEnt, cLojEnt, cNomEnt, cAliasCTR), A450LoadSld(), NIL ) }	,,,,,,'34') 	//"Transferência"
    oBrwCtr:AddButton(STR0022,  {|| fVGrafCTR()                       },,,,,,'35') //"Gráfico"

    If __lnewNeg
        oBrwCtr:AddButton(STR0056,  {|| OGA450C((cAliasCTR)->C_FILIAL,(cAliasCTR)->C_CODCTR)},,,,,,'37') //"Pendências"
    EndIf

    ACTIVATE FWFORMBROWSE oBrwCtr
    oDlg:Activate( , , , .t., { || .t. }, , { || } )

	//--- Apaga as tabelas temporárias ---//
	AGRDELETRB( cAliasSLD, cTrabSLD )
	AGRDELETRB( cAliasCTR, cTrabCTR )

Return( )

/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Marlon Richard Trettin
@since: 	25/07/2013
@Uso: 		SIGAAGR
*/
Static Function MenuDef()
	Local aRotina := {}

	aAdd( aRotina, { "DUMMY"	, "PesqBrw"   , 0, 1, 0, .t. } )

Return( aRotina )

/** {Protheus.doc} At430Btn
Ações do botão de FINANCEIRO

@param: 	Nil
@return:	nil
@author: 	SIGAAGR
@since: 	25/07/2013
@Uso: 		OGA010 - Entidades
*/
Static Function At430Btn( pcCodCtr )
	Local cCh1TrbSld	:=	( oBrwSld:Alias() )->(S_FILIAL+S_TIPO+S_LOJA+S_CODSAF+S_CODPRO+S_UM1PRO) //Indice 1 		do TRB de Saldos
	Local cCh1TrbCtr	:=	( oBrwCtr:Alias() )->(C_FILIAL+C_CODCTR) //Indice Unico 	do TRB de Contratos
    Local nRecnoSld		:= 0
	Local nRecnoCtr		:= 0    
    
	OGA430( pcCodCtr)			//Chamando a Função que Cuida da parte FinanceiraFixação

	//Reposicionando os Registros pois no Re-load Ele Volta sempre para O Inicio
	A450LoadSld()				// Fazendo um Re-load nos Dados , Ira posicionar na 1a. linha de kda Browse de Saldos
	dBSelectArea( cAliasSld )
	( cAliasSld )->(DbSetOrder(1))
	( cAliasSld )->(DbSeek( cCh1TrbSld ))
	nRecnoSld := ( cAliasSld )->( recno() )	
	
	oBrwSld:fwbrowse():Goto(nRecnoSld,.t.)	

	A450LoadCtr()			// Fazendo um Re-load nos Dados , Ira posicionar na 1a. linha de kda Browse de Ctratos
	dBSelectArea( cAliasCtr )
	( cAliasCtr )->(DbSetOrder(1))
	( cAliasCtr )->(DbSeek( cCh1TrbCtr ))
	nRecnoCtr := ( cAliasCtr )->( recno() )	
	
	oBrwCtr:fwbrowse():Goto(nRecnoCtr,.t.)	
	
	// Browses Reposicionados

Return()

/** {Protheus.doc} ValEntidade()
Valida a entidade

@param: 	pcEntidade		Recebe cCodEnt sozinho ou acompanhado de cLojEnt
@author: 	Marlon Richard Trettin
@since: 	28/10/14
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function ValEntidade( pcCodEnt, pcLojEnt )

	DbSelectArea( "NJ0" )
	DbSetOrder( 1 )
	If DbSeek( xFilial( "NJ0" ) + pcCodEnt + iIf( !Empty( AllTrim( pcLojEnt ) ), pcLojEnt, "" ) )
		cNomEnt  := NJ0->( NJ0_NOME )

		If !Empty(cDCodEnt)
			cDNomEnt := NJ0->( NJ0_NOME )
		EndIf

		If !Empty( AllTrim( pcLojEnt ) )
			cNomLoj := NJ0->( NJ0_NOMLOJ )
		Else
			cNomLoj := Space( TamSX3( "NJ0_NOMLOJ" )[1] )
		EndIf
	Else
		Return( .F. )
	EndIf

Return( .T. )

/** {Protheus.doc}
()
Carrega dados da tabela temporária de Saldos.

@param: 	Nil
@author: 	Marlon Richard Trettin
@since: 	28/10/14
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function A450LoadSld()

	Local aAreaAtu	 	:= GetArea()
	Local cAliasQry	    := GetNextAlias()
	Local cFiltro 		:= ""

	//--- Apaga conteúdo anterior da tabela temporária SLD ---//
	fZapTRB( cAliasSLD )

	cFiltro := " AND NJR_CODENT = '" + cCodEnt + "'"
	If !Empty( AllTrim( cLojEnt ) )
		cFiltro += " AND NJR_LOJENT = '" + cLojEnt + "'"
		cNoFldSLD	:= "S_TIPO,S_LOJA"
	EndIf
	cFiltro := "%" + cFiltro + "%"

	//--- Query para trazer os saldos ---//
	BeginSql Alias cAliasQry

		SELECT NJR_FILIAL
		,NJR_TIPO
		,NJR_CODENT
		,NJR_LOJENT
		,NJR_CODSAF
		,NJR_CODPRO
		,NJR_UM1PRO
		,NJR_QTDCTR
		,NJR_QTEFCO
		,NJR_QTEFIS
		,NJR_QTSFCO
		,NJR_QTSFIS
		,NJR_QTDRES
		,NJR_QSLFCO
		,NJR_SLDFIS
		,(SELECT SUM(NN8_QTDFIX) from %Table:NN8% NN8
		where NN8.%notDel%
		AND NN8_FILIAL = %XFilial:NN8%
		AND NN8_CODCTR = NJR_CODCTR
		AND NN8_TIPOFX = '1') as NN8_QTDFIX
		,(SELECT SUM(NN8_QTDENT) from %Table:NN8% NN8
		where NN8.%notDel%
		AND NN8_FILIAL = %XFilial:NN8%
		AND NN8_CODCTR = NJR_CODCTR
		AND NN8_TIPOFX = '1') as NN8_QTDENT
        ,(SELECT SUM(NJJ_PSLIQU)  
            FROM %table:NJJ% NJJ
	        INNER JOIN %table:NJM% NJM ON NJM.NJM_FILIAL = NJJ.NJJ_FILIAL AND NJM.NJM_CODROM = NJJ.NJJ_CODROM AND NJM.%notDel%
	        WHERE NJJ.NJJ_FILIAL = %xFilial:NJJ%
	          AND NJJ.NJJ_STATUS IN ("0", "1") //Pendente, Completo, Atualizado
	          AND NJM.NJM_CODCTR = NJR.NJR_CODCTR
	          AND NJM.NJM_TIPO   IN ( "6", "7", "8", "9")
	          AND NJJ.%notDel%) as NJJ_PSLIQU
		FROM %Table:NJR% NJR
		WHERE NJR.%notDel%
		AND NJR_FILIAL = %XFilial:NJR%
		%exp:cFiltro%

	EndSQL

	/*Alteração conforme SQL server e soma das diferenças conforme o contrato*/
	DbselectArea( cAliasQry )
	DbGoTop()
	While ( cAliasQry )->( !Eof() )
		/*Verifica se existe agrupamento e soma se for o caso*/
		DbSelectArea( cAliasSLD )
		if (cAliasSLD)->(dbSeek( ( cAliasQry )->NJR_FILIAL  + ( cAliasQry )->NJR_TIPO + ( cAliasQry )->NJR_LOJENT + ( cAliasQry )->NJR_CODSAF + ( cAliasQry )->NJR_CODPRO + ( cAliasQry )->NJR_UM1PRO))
			//update
			RecLock( cAliasSLD, .F. )
			( cAliasSLD )->S_QTDCTR 	+= ( cAliasQry )->NJR_QTDCTR
			( cAliasSLD )->S_QTDFIX 	+= ( cAliasQry )->NN8_QTDFIX
			( cAliasSLD )->S_QTENFX 	+= ( cAliasQry )->NN8_QTDENT
			( cAliasSLD )->S_QTDAFX 	+= ( cAliasQry )->NJR_QTDCTR - ( cAliasQry )->NN8_QTDFIX
			( cAliasSLD )->S_QSLFCO 	+= ( cAliasQry )->NJR_QSLFCO
			( cAliasSLD )->S_SLDFIS 	+= ( cAliasQry )->NJR_SLDFIS
			( cAliasSLD )->S_QTEFCO 	+= ( cAliasQry )->NJR_QTEFCO
			( cAliasSLD )->S_QTEFIS 	+= ( cAliasQry )->NJR_QTEFIS
			( cAliasSLD )->S_QTSFCO 	+= ( cAliasQry )->NJR_QTSFCO
			( cAliasSLD )->S_QTSFIS 	+= ( cAliasQry )->NJR_QTSFIS
			( cAliasSLD )->S_QTDRES 	+= ( cAliasQry )->NJR_QTDRES
			( cAliasSLD )->S_DIFFIS 	+= ( cAliasQry )->NJR_QTEFCO - ( cAliasQry )->NJR_QTEFIS

			If ( cAliasQry )->NJR_TIPO $ "1|3"
				If (( cAliasQry )->NJR_QTEFCO - 	( cAliasQry )->NJR_QTSFCO - ( cAliasQry )->NN8_QTDFIX -( cAliasQry )->NJR_QTDRES) < 0
					( cAliasSLD )->S_QTDTRF 	+= ( cAliasQry )->NJR_QTEFCO - 	( cAliasQry )->NJR_QTSFCO - ( cAliasQry )->NJR_QTDRES - ( cAliasQry )->NJJ_PSLIQU
				Else
					( cAliasSLD )->S_QTDTRF 	+= ( cAliasQry )->NJR_QTEFCO - 	( cAliasQry )->NJR_QTSFCO - ( cAliasQry )->NN8_QTDFIX - ( cAliasQry )->NJR_QTDRES - ( cAliasQry )->NJJ_PSLIQU
				Endif
			Else
				If ( ( cAliasQry )->NJR_QTSFCO - ( cAliasQry )->NJR_QTEFCO - ( cAliasQry )->NN8_QTDFIX -( cAliasQry )->NJR_QTDRES) < 0
					( cAliasSLD )->S_QTDTRF 	+= ( cAliasQry )->NJR_QTSFCO - ( cAliasQry )->NJR_QTEFCO - 	( cAliasQry )->NJR_QTDRES - ( cAliasQry )->NJJ_PSLIQU
				Else
					( cAliasSLD )->S_QTDTRF 	+= ( cAliasQry )->NJR_QTSFCO - ( cAliasQry )->NJR_QTEFCO - 	( cAliasQry )->NN8_QTDFIX - ( cAliasQry )->NJR_QTDRES - ( cAliasQry )->NJJ_PSLIQU
				Endif
			Endif
            
            ( cAliasSLD )->S_QTDROM += ( cAliasQry )->NJJ_PSLIQU
			
            ( cAliasSLD )->( MsUnLock() )
		else
			//new
			RecLock( cAliasSLD, .T. )
			( cAliasSLD )->S_FILIAL 	:= ( cAliasQry )->NJR_FILIAL
			( cAliasSLD )->S_LOJA 	    := ( cAliasQry )->NJR_LOJENT
			( cAliasSLD )->S_TIPO 	    := ( cAliasQry )->NJR_TIPO
			( cAliasSLD )->S_DESTIP 	:= X3CboxDesc( "NJR_TIPO", ( cAliasQry )->NJR_TIPO )
			( cAliasSLD )->S_CODSAF 	:= ( cAliasQry )->NJR_CODSAF
			( cAliasSLD )->S_CODPRO 	:= ( cAliasQry )->NJR_CODPRO
			( cAliasSLD )->S_DESPRO 	:= Posicione('SB1',1,xFilial('SB1')+( cAliasQry )->NJR_CODPRO,'B1_DESC')
			( cAliasSLD )->S_UM1PRO 	:= ( cAliasQry )->NJR_UM1PRO
			( cAliasSLD )->S_QTDCTR 	:= ( cAliasQry )->NJR_QTDCTR
			( cAliasSLD )->S_QTDFIX 	:= ( cAliasQry )->NN8_QTDFIX
			( cAliasSLD )->S_QTENFX 	:= ( cAliasQry )->NN8_QTDENT
			( cAliasSLD )->S_QTDAFX 	:= ( cAliasQry )->NJR_QTDCTR - ( cAliasQry )->NN8_QTDFIX
			( cAliasSLD )->S_QSLFCO 	:= ( cAliasQry )->NJR_QSLFCO
			( cAliasSLD )->S_SLDFIS 	:= ( cAliasQry )->NJR_SLDFIS
			( cAliasSLD )->S_QTEFCO 	:= ( cAliasQry )->NJR_QTEFCO
			( cAliasSLD )->S_QTEFIS 	:= ( cAliasQry )->NJR_QTEFIS
			( cAliasSLD )->S_QTSFCO 	:= ( cAliasQry )->NJR_QTSFCO
			( cAliasSLD )->S_QTSFIS 	:= ( cAliasQry )->NJR_QTSFIS
			( cAliasSLD )->S_QTDRES 	:= ( cAliasQry )->NJR_QTDRES
			( cAliasSLD )->S_DIFFIS 	:= ( cAliasQry )->NJR_QTEFCO - ( cAliasQry )->NJR_QTEFIS

			If ( cAliasQry )->NJR_TIPO $ "1|3"
				If (( cAliasQry )->NJR_QTEFCO - 	( cAliasQry )->NJR_QTSFCO - ( cAliasQry )->NN8_QTDFIX -( cAliasQry )->NJR_QTDRES) < 0
					( cAliasSLD )->S_QTDTRF 	:= ( cAliasQry )->NJR_QTEFCO - 	( cAliasQry )->NJR_QTSFCO - ( cAliasQry )->NJR_QTDRES - ( cAliasQry )->NJJ_PSLIQU
				Else
					( cAliasSLD )->S_QTDTRF 	:= ( cAliasQry )->NJR_QTEFCO - 	( cAliasQry )->NJR_QTSFCO - ( cAliasQry )->NN8_QTDFIX - ( cAliasQry )->NJR_QTDRES - ( cAliasQry )->NJJ_PSLIQU
				Endif
			Else
				If ( ( cAliasQry )->NJR_QTSFCO - ( cAliasQry )->NJR_QTEFCO - ( cAliasQry )->NN8_QTDFIX -( cAliasQry )->NJR_QTDRES) < 0
					( cAliasSLD )->S_QTDTRF 	:= ( cAliasQry )->NJR_QTSFCO - ( cAliasQry )->NJR_QTEFCO - 	( cAliasQry )->NJR_QTDRES - ( cAliasQry )->NJJ_PSLIQU
				Else
					( cAliasSLD )->S_QTDTRF 	:= ( cAliasQry )->NJR_QTSFCO - ( cAliasQry )->NJR_QTEFCO - 	( cAliasQry )->NN8_QTDFIX - ( cAliasQry )->NJR_QTDRES - ( cAliasQry )->NJJ_PSLIQU
				Endif
			Endif
            
            ( cAliasSLD )->S_QTDROM := ( cAliasQry )->NJJ_PSLIQU
			
            ( cAliasSLD )->( MsUnLock() )
		endIF

		( cAliasQry )->( DbSkip() )
	EndDo
	( cAliasQry )->( DbCloseArea() )
    
    If Type("oBrwSld") <> "U"
        oBrwSld:Refresh(.T.)
    EndIf	
	
	RestArea( aAreaAtu )
Return

/** {Protheus.doc} A450LoadCtr
Carrega dados da tabela temporária de Contratos.

@param: 	Nil
@author: 	Marlon Richard Trettin
@since: 	23/10/14
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function A450LoadCtr()

	Local aAreaAtu	:= GetArea()
	Local cAliasQry	:= GetNextAlias()
	Local cTipo		:= ( cAliasSLD )->S_TIPO
	Local cCodSaf 	:= ( cAliasSLD )->S_CODSAF
	Local cCodPro 	:= ( cAliasSLD )->S_CODPRO
	Local cAuxLoj		:= ( cAliasSLD )->S_LOJA

	//--- Apaga conteúdo anterior da tabela temporária CTR ---//
	fZapTRB( cAliasCTR )

	//--- Query para trazer os Contratos ---//
	BeginSql Alias cAliasQry

		SELECT NJR_FILIAL
		,NJR_TIPO
		,NJR_MODELO
		,NJR_STATUS
		,NJR_CODCTR
		,NJR_DESCRI
		,NJR_DATA
		,NJR.R_E_C_N_O_ AS NJR_RECNO
		,(SELECT MIN(NNY_DATINI) FROM %Table:NNY% NNY
		WHERE NNY.%notDel% AND NNY_FILIAL=NJR_FILIAL AND NNY_CODCTR=NJR_CODCTR) AS NNY_DATINI
		,(SELECT MAX(NNY_DATFIM) FROM %Table:NNY% NNY
		WHERE NNY.%notDel% AND NNY_FILIAL=NJR_FILIAL AND NNY_CODCTR=NJR_CODCTR) AS NNY_DATFIM
        ,(SELECT SUM(NJJ_PSLIQU)  
            FROM %table:NJJ% NJJ
	        INNER JOIN %table:NJM% NJM ON NJM.NJM_FILIAL = NJJ.NJJ_FILIAL AND NJM.NJM_CODROM = NJJ.NJJ_CODROM AND NJM.%notDel%
	        WHERE NJJ.NJJ_FILIAL = %xFilial:NJJ%
	          AND NJJ.NJJ_STATUS IN ("0", "1") //Pendente, Completo, Atualizado
	          AND NJM.NJM_CODCTR = NJR.NJR_CODCTR
	          AND NJM.NJM_TIPO   IN ( "6", "7", "8", "9")
	          AND NJJ.%notDel%) as NJJ_PSLIQU
		,MAX(NJR_QTDCTR) as NJR_QTDCTR
		,MAX(NJR_QTEFCO) as NJR_QTEFCO
		,MAX(NJR_QTEFIS) as NJR_QTEFIS
		,MAX(NJR_QTSFCO) as NJR_QTSFCO
		,MAX(NJR_QTSFIS) as NJR_QTSFIS
		,MAX(NJR_QTDRES) as NJR_QTDRES
		,MAX(NJR_QSLFCO) as NJR_QSLFCO
		,MAX(NJR_SLDFIS) as NJR_SLDFIS
		,SUM(NN8_QTDFIX) as NN8_QTDFIX
		,SUM(NN8_QTDENT) as NN8_QTDENT
		FROM %Table:NJR% NJR
		LEFT JOIN %Table:NN8% NN8  ON NN8.%notDel%
		AND NN8_FILIAL = %XFilial:NN8%
		AND NN8_CODCTR = NJR_CODCTR
		AND NN8_TIPOFX = '1'
		WHERE NJR.%notDel%
		AND NJR_FILIAL = %XFilial:NJR%
		AND NJR_CODENT = %exp:cCodEnt%
		AND NJR_LOJENT = %exp:cAuxLoj%
		AND NJR_TIPO   = %exp:cTipo%
		AND NJR_CODSAF = %exp:cCodSaf%
		AND NJR_CODPRO = %exp:cCodPro%
		GROUP BY  NJR_FILIAL
		,NJR_TIPO
		,NJR_MODELO
		,NJR_STATUS
		,NJR_CODCTR
		,NJR_DESCRI
		,NJR_DATA
		,NJR.R_E_C_N_O_

	EndSQL

	DbselectArea( cAliasQry )
	DbGoTop()
	While ( cAliasQry )->( !Eof() )

		RecLock( cAliasCTR, .T. )
		( cAliasCTR )->C_FILIAL 	:= ( cAliasQry )->NJR_FILIAL
		( cAliasCTR )->C_MODELO 	:= ( cAliasQry )->NJR_MODELO
		( cAliasCTR )->C_STATUS 	:= ( cAliasQry )->NJR_STATUS
		( cAliasCTR )->C_CODCTR 	:= ( cAliasQry )->NJR_CODCTR
		( cAliasCTR )->C_DESCRI 	:= ( cAliasQry )->NJR_DESCRI
		( cAliasCTR )->C_DATA	:= StoD( ( cAliasQry )->NJR_DATA )
		( cAliasCTR )->C_DATINI 	:= StoD( ( cAliasQry )->NNY_DATINI )
		( cAliasCTR )->C_DATFIM 	:= StoD( ( cAliasQry )->NNY_DATFIM )
		( cAliasCTR )->C_QTDCTR 	:= ( cAliasQry )->NJR_QTDCTR
		( cAliasCTR )->C_QTDFIX 	:= ( cAliasQry )->NN8_QTDFIX
		( cAliasCTR )->C_QTENFX 	:= ( cAliasQry )->NN8_QTDENT
		( cAliasCTR )->C_QTDAFX 	:= ( cAliasQry )->NJR_QTDCTR - ( cAliasQry )->NN8_QTDFIX
		( cAliasCTR )->C_QSLFCO 	:= ( cAliasQry )->NJR_QSLFCO
		( cAliasCTR )->C_SLDFIS 	:= ( cAliasQry )->NJR_SLDFIS
		( cAliasCTR )->C_QTEFCO 	:= ( cAliasQry )->NJR_QTEFCO
		( cAliasCTR )->C_QTEFIS 	:= ( cAliasQry )->NJR_QTEFIS
		( cAliasCTR )->C_QTSFCO 	:= ( cAliasQry )->NJR_QTSFCO
		( cAliasCTR )->C_QTSFIS 	:= ( cAliasQry )->NJR_QTSFIS
		( cAliasCTR )->C_QTDRES 	:= ( cAliasQry )->NJR_QTDRES
		( cAliasCTR )->C_DIFFIS 	:= ( cAliasQry )->NJR_QTEFCO - ( cAliasQry )->NJR_QTEFIS
		( cAliasCTR )->C_RECNO 	:= ( cAliasQry )->NJR_RECNO

		If ( cAliasQry )->NJR_TIPO $ "1|3"
			If (( cAliasQry )->NJR_QTEFCO - ( cAliasQry )->NJR_QTSFCO - ( cAliasQry )->NN8_QTDFIX -( cAliasQry )->NJR_QTDRES) < 0
				( cAliasCTR )->C_QTDTRF 	:= ( cAliasQry )->NJR_QTEFCO - 	( cAliasQry )->NJR_QTSFCO - ( cAliasQry )->NJR_QTDRES
			Else
				( cAliasCTR )->C_QTDTRF 	:= ( cAliasQry )->NJR_QTEFCO - 	( cAliasQry )->NJR_QTSFCO - ( cAliasQry )->NN8_QTDFIX - ( cAliasQry )->NJR_QTDRES
			Endif
		Else
			If ( ( cAliasQry )->NJR_QTSFCO - ( cAliasQry )->NJR_QTEFCO - ( cAliasQry )->NN8_QTDFIX -( cAliasQry )->NJR_QTDRES) < 0
				( cAliasCTR )->C_QTDTRF 	:= ( cAliasQry )->NJR_QTSFCO - ( cAliasQry )->NJR_QTEFCO - 	( cAliasQry )->NJR_QTDRES
			Else
				( cAliasCTR )->C_QTDTRF 	:= ( cAliasQry )->NJR_QTSFCO - ( cAliasQry )->NJR_QTEFCO - 	( cAliasQry )->NN8_QTDFIX - ( cAliasQry )->NJR_QTDRES
			Endif
		Endif

        ( cAliasCTR )->C_QTDROM := ( cAliasQry )->NJJ_PSLIQU
        ( cAliasCTR )->C_QTDTRF -= ( cAliasQry )->NJJ_PSLIQU

		( cAliasCTR )->( MsUnLock() )

		( cAliasQry )->( DbSkip() )
	EndDo
	( cAliasQry )->( DbCloseArea() )	
	
    If Type("oBrwCtr") <> "U"
        oBrwCtr:Refresh(.T.)
    EndIf

	RestArea( aAreaAtu )
Return

/** {Protheus.doc} fZapTRB
Apaga todos os dados de uma tabela temporária.

@param: 	Nil
@author: 	Marlon Richard Trettin
@since: 	29/10/14
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function fZapTRB( pcAliasTRB )
	Local aAreaAtu	 	:= GetArea()

	If Select( pcAliasTRB ) > 0
		DbSelectArea( pcAliasTRB )
		Zap
	Endif

	RestArea( aAreaAtu )
Return

Static Function fVGrafSLD()
	Local aValues := {}
	Local cTitulo := STR0002 + " " + STR0003 + " " + AllTrim( (cAliasSLD)->S_DESTIP ) + Chr(13) +; //"Saldos"##"Contratos"
	AllTrim( (cAliasSLD)->S_CODSAF ) + " " + AllTrim( (cAliasSLD)->S_DESPRO )

	aAdd( aValues, { RetTitle( "NJR_QTDCTR" ), (cAliasSLD)->S_QTDCTR } )
	If (cAliasSLD)->S_TIPO $ "1|2"
		aAdd( aValues, { RetTitle( "NN8_QTDFIX" ), (cAliasSLD)->S_QTDFIX } )
		aAdd( aValues, { STR0016, (cAliasSLD)->S_QTENFX } )	//Qtd. Ent. Fix.
		aAdd( aValues, { STR0007, (cAliasSLD)->S_QTDAFX } )	//Qtd. a Fixar
	EndIf
	aAdd( aValues, { RetTitle( "NJR_QSLFCO" ), (cAliasSLD)->S_QSLFCO } )
	aAdd( aValues, { RetTitle( "NJR_SLDFIS" ), (cAliasSLD)->S_SLDFIS } )
	aAdd( aValues, { RetTitle( "NJR_QTEFCO" ), (cAliasSLD)->S_QTEFCO } )
	aAdd( aValues, { RetTitle( "NJR_QTEFIS" ), (cAliasSLD)->S_QTEFIS } )
	aAdd( aValues, { RetTitle( "NJR_QTSFCO" ), (cAliasSLD)->S_QTSFCO } )
	aAdd( aValues, { RetTitle( "NJR_QTSFIS" ), (cAliasSLD)->S_QTSFIS } )
	aAdd( aValues, { STR0008, (cAliasSLD)->S_DIFFIS } )	// Dif. Fiscal
	aAdd( aValues, { RetTitle( "NJR_QTDRES" ), (cAliasSLD)->S_QTDRES } )
	aAdd( aValues, { STR0004, (cAliasSLD)->S_QTDTRF } )	
	
    AgrCriaChart( cTitulo, aValues, "@E 999,999,999,999" )	
	
Return NIL

Static Function fVGrafCTR()
	Local aValues := {}
	Local cTitulo := AllTrim( (cAliasCTR)->C_CODCTR ) + " - " + AllTrim( (cAliasCTR)->C_DESCRI )

	aAdd( aValues, { RetTitle( "NJR_QTDCTR" ), (cAliasCTR)->C_QTDCTR } )
	If (cAliasSLD)->S_TIPO $ "1|2"
		aAdd( aValues, { RetTitle( "NN8_QTDFIX" ), (cAliasCTR)->C_QTDFIX } )
		aAdd( aValues, { STR0016, (cAliasCTR)->C_QTENFX } )	//Qtd. Ent. Fix.
		aAdd( aValues, { STR0007, (cAliasCTR)->C_QTDAFX } )	//Qtd. a Fixar
	EndIf
	aAdd( aValues, { RetTitle( "NJR_QSLFCO" ), (cAliasCTR)->C_QSLFCO } )
	aAdd( aValues, { RetTitle( "NJR_SLDFIS" ), (cAliasCTR)->C_SLDFIS } )
	aAdd( aValues, { RetTitle( "NJR_QTEFCO" ), (cAliasCTR)->C_QTEFCO } )
	aAdd( aValues, { RetTitle( "NJR_QTEFIS" ), (cAliasCTR)->C_QTEFIS } )
	aAdd( aValues, { RetTitle( "NJR_QTSFCO" ), (cAliasCTR)->C_QTSFCO } )
	aAdd( aValues, { RetTitle( "NJR_QTSFIS" ), (cAliasCTR)->C_QTSFIS } )
	aAdd( aValues, { STR0008, (cAliasCTR)->C_DIFFIS } )	// Dif. Fiscal
	aAdd( aValues, { RetTitle( "NJR_QTDRES" ), (cAliasCTR)->C_QTDRES } )
	aAdd( aValues, { STR0004, (cAliasCTR)->C_QTDTRF } )
	
	AgrCriaChart( cTitulo, aValues, "@E 999,999,999,999" )	

Return NIL

Function AgrCriaChart( pcTitulo, paValues, pcPict )
	Local oFWChart
	Local oDlg
	Local aCords 	 := FWGetDialogSize( oMainWnd )
	Local aButtons := {}
	Local nX := 0

	//	aAdd( aButtons, { "SELECTALL", {|| oFWChart := oFWChart:getInstance( BARCHART ) }, 		"Barras", 			"Barras" } )
	//	aAdd( aButtons, { "SELECTALL", {|| oFWChart := oFWChart:getInstance( BARCOMPCHART ) }, 	"Barras Comp.", 	"Barras Comp." } )
	//	aAdd( aButtons, { "SELECTALL", {|| oFWChart := oFWChart:getInstance( LINECHART ) }, 	"Linhas", 			"Linhas" } )
	//	aAdd( aButtons, { "SELECTALL", {|| oFWChart := oFWChart:getInstance( PIECHART ) }, 		"Pizza", 			"Pizza" } )
	/* Valores do getInstance:
	BARCHART  		- cria objeto FWChartBar
	BARCOMPCHART 	- cria objeto FWChartBarComp
	LINECHART 		- cria objeto FWChartLine
	PIECHART 		- cria objeto FWChartPie
	*/

	DEFINE MSDIALOG oDlg FROM  aCords[ 1 ]+30, aCords[ 2 ]+30 TO aCords[ 3 ]-30, aCords[ 4 ]-30 TITLE pcTitulo PIXEL

	oFWChart := FWChartFactory():New()
	oFWChart := oFWChart:getInstance( BARCHART ) // cria objeto FWChartBar
	oFWChart:init( oDLG, .F. )
	oFWChart:setTitle( pcTitulo, CONTROL_ALIGN_CENTER )
	oFWChart:setLegend( CONTROL_ALIGN_LEFT )
	oFWChart:setMask( " *@* " )
	oFWChart:setPicture( pcPict )
	For nX := 1 to Len( paValues )
		oFWChart:addSerie( paValues[ nX, 1 ], paValues[ nX, 2 ] )
	Next nX
	oFWChart:build()

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar( oDlg, {|| oDlg:End() }, {|| oDlg:End() }, , @aButtons )

Return

/*/{Protheus.doc} OGA450ALCF
	Gera Alçada para Notas de Crédito ou Débito no Financeiro
	@type  Static Function
	@author filipe.olegini
	@since 29/06/2018
	@param oModelNxC, objeto, pbjeto a ser atualizado
	@see (links_or_references)
/*/
Function OGA450ALCF(cOpc as Char, aDados as array )
	Local aArea		as array
	Local cGrpAprov	as char
	Local nValor    as numeric
	Local cNatureza as char
	Local nTxMoed   as numeric
	Local cDocumen  as char
	Local cItem     as char
	Local cTp       as Char
	Local lAlc      as logical
	Local cCodCad   as char
	Local cRegra    as Char
	Local cFilCtr   as char
	Local cCodCtr   as char

	aArea		:= NJR->(GetArea())
	cGrpAprov	:= SuperGetMv("MV_AGRO016")

	cFilCtr     := aDados[1]
	cCodCtr     := aDados[2]
	cCodCad     := aDados[3]
	cRegra      := aDados[4]
	cNatureza   := aDados[5]
	nValor      := aDados[6]
	cObserva    := aDados[7]

	If cOpc == "D"
		If ValType(aDados[8]) == 'D'
			dVencto     := aDados[8]
		Else
			dVencto     := stod(aDados[8])
		EndIf
	Endif

	NJR->(DbSetOrder(1))
	NJR->(dbSeek(cFilCtr + cCodCtr))

	nTxMoed		:= OGA450COT( NJR->NJR_MOEDA, dDataBase ) //busca a taxa da moeda
	cItem       := OGA450JAE(NJR->NJR_CODCTR, cOpc) //busca parcelas
	cDocumen    := NJR->NJR_CODCTR + AllTrim(cItem)
	lRet        := .T.

	//valida a regra fiscal
	N9A->(DbSetOrder(1))
	If !N9A->(DbSeek(NJR->NJR_FILIAL + NJR->NJR_CODCTR + cCodCad + cRegra ))
		Help( , , STR0054, , STR0055, 1, 0 )
		Return {lRet, STR0055,"", "",.F.} //"Regra Fiscal não encontrado para o contrato."
	endif

	If !Empty(cGrpAprov) //se o parametro estiver em branco ou vazio nao utiliza a alçada

		IF cOpc = "C"
			cTp := "A3"
		elseif cOpc = "D"
			cTp := "A4"
		EndIf

		If Empty(nValor) .OR. Empty(cNatureza)
			MsgInfo(STR0026,STR0027)// Campos obrigatórios não informados // Atenção
			Return {lRet, STR0057,"", "", .F.} //Valor ou natureza não preenchidos.
		Else
			MsAguarde( {|| lAlc := MaAlcDoc({cDocumen, cTp, nValor,,,cGrpAprov,,NJR->NJR_MOEDA, nTxMoed, dDataBase, ""}, dDataBase,1) },STR0058,STR0059 )
			//chamar a função de gerar NxC e gravar a N8L
			BEGIN Transaction

				dbSelectArea("NBX")
				dbSetOrder(1)
				If !dbSeek(FwXFilial("NBX")+NJR->NJR_CODCTR+cDocumen+cTp+cItem)
					If RecLock("NBX", .T.)
						NBX->NBX_FILIAL := FwXFilial("NBX")
						NBX->NBX_CODCTR := NJR->NJR_CODCTR
						NBX->NBX_DOC    := cDocumen
						NBX->NBX_TIPO   := cTp
						If cOpc = "C"
							NBX->NBX_ITEM   := "001"        //neste tipo de documento é fixo
						ElseIf cOpc = "D"
							NBX->NBX_ITEM   := AllTrim(cItem)
						EndIf
						NBX->NBX_ORIGEM := "OGA450"
						If cOpc = "C"
							NBX->NBX_DATA   := ddatabase
						Else
							NBX->NBX_DATA   := dVencto
						EndIf
						NBX->NBX_VALOR  := nValor
						NBX->NBX_USUARI := RetCodUsr()
						NBX->NBX_STATUS := "P"
						NBX->NBX_NATURE := cNatureza
						NBX->NBX_HISTOR := cObserva
						NBX->NBX_CODCAD := cCodCad
						NBX->NBX_SEQPRI := cRegra
						NBX->(MsUnlock())
					EndIf

					If lAlc
						If cOpc = "C"
							lRet := (A450GERTIT(FwXfilial("NJR"), NJR->NJR_CODCTR, cDocumen, AllTrim(cItem), nValor, cObserva, 'A' ) )
						elseif cOpc = "D"
							lRet := (A450GERNDC(FwXfilial("NJR"), NJR->NJR_CODCTR, cDocumen,AllTrim(cItem), nValor, dVencto, cObserva, 'A' ) )
						Endif
					Else
						lRet := .T.
						If cOpc = "C"
							Help('', 1, "OGA450NCCG") //Solicitação para gerar uma Nota de Crédito Cliente (A3) ecaminhada para aprovação. #A liberação deverá ser feita pelo Responsável definido no Grupo de Aprovação Cadastrado.
						elseif cOpc = "D"
							Help('', 1, "OGA450NDCG") //Solicitação para gerar uma Nota de Débito Cliente (A4) ecaminhada para aprovação. #A liberação deverá ser feita pelo Responsável definido no Grupo de Aprovação Cadastrado.
						EndIf
					EndIf

				Else
					MsgInfo(STR0048, STR0027 )   //"Não foi possivel abrir a tabela NBX para gravação"  //Atencao
					lRet := .F.
				EndIf

				If !lRet
					DisarmTransaction()
				Else
					MsgInfo(STR0065+cDocumen,STR0066) //"Numero do documento gerado:  ## Titulo Gerado! "
				EndIF
			END Transaction
		EndIf
	Else
		Help('',1, "OGA450MV16EMPT") //Parametro MV_AGRO016 não prenchido. # Para realizar a confirmação é necessário vincular no parametro MV_AGRO016 o grupo de aprovação.
		lRet    := .F.
	EndIf

	RestArea(aArea)

Return {lRet, "",cDocumen, "", lAlc}

/*{Protheus.doc} OGA450COT
	//Função que retorna a taxa da moeda
	@type  Static Function
	@author filipe.olegini
	@since 29/06/2018
	@version 1.0
	@type function
*/
Static Function OGA450COT( nMoeda as numeric, dDtTaxa as date)
	Local nTxaComp as numeric

	nTxaComp  := 1

	//verifica se for moeda diferente de 1 busca a taxa da modea informada
	If nMoeda <> 1

		DBSelectArea("SM2")
		SM2->(DBSetOrder(1) )
		If SM2->(DbSeek(DtoS(dDtTaxa)))
			nTxaComp 	:= &('SM2->M2_TXMOED'+ STRZERO(nMoeda,1) )
		EndIf
	Else
		nTxaComp := 1
	EndIf

Return (nTxaComp)

/*{Protheus.doc} OGA450JAE
	//Função que verifica se ja existe uma NCC gerada e retorna a proxima numeração
	@type  Static Function
	@author filipe.olegini
	@since 29/06/2018
	@version 1.0
	@type function
*/
Static Function OGA450JAE( cCodCtr as char, cOpc as Char)
	Local cRet      as char
	Local cQuery    as char
	Local cAliasQry as char

	cRet      := ""
	cQuery    := ""
	cAliasQry := GetNextAlias()

	If Select(cAliasQry) <> 0
		(cAliasQry)->(dbCloseArea())
	EndIf

	cQuery := " SELECT MAX(NBX_ITEM) AS ITEM"
	cQuery += " FROM " + RetSqlName('NBX')
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " AND NBX_FILIAL = '" + FWxFilial('NBX') + "' "
	cQuery += " AND NBX_CODCTR   = '" + cCodCtr + "' "
	If cOpc = "C"  //NCC
		cQuery += " AND NBX_TIPO = 'A3' "
	elseif cOpc = "D"   //NDC
		cQuery += " AND NBX_TIPO = 'A4' "
	EndIf

	cQuery := ChangeQuery(cQuery)

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	If (cAliasQry)->(!Eof())
		cRet := (cAliasQry)->ITEM
		If Empty(cRet)
			cRet := "001"
		Else
			cRet := Soma1(cRet)
		EndIf
	Else
		cRet := "001"
	EndIf

	(cAliasQry)->(dbCloseArea())

Return cRet

/*/{Protheus.doc} A450GERTIT
	Função para gerar o titulo dos documentos do tipo A3. Chamado na função AGRXFUN1
	@type  Function
	@author filipe.olegini
	@since 23/07/2018
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Function A450GERTIT(cFilCtr as char, cCodCtr as char, cDoc as char, cItem as char, nValor as Numeric, cObserva as char, cStAlc as char)
	Local aAreaNBX      as array
	Local aAreaNJR      as array
	Local aAreaNC8      as array
	Local cPrefixo      as char
	Local cParcela      as char
	Local cFilTit       as char
	Local lNBX          as logical
	Local lRet    	    as Logical

	Private lMsErroAuto as logical

	Default cItem := ""
	Default nValor := 0
	Default cObserva := ""
	Default cStAlc   := ""

	aAreaNBX    := NBX->(GetArea())
	aAreaNJR    := NJR->(GetArea())
	aAreaNC8    := NC8->(GetArea())

	lNBX := .F.
	lRet := .F.
	//AGRXCOM8(cNumDoc, cTipDoc, cRecno)
	If FWISINCALLSTACK("AGRXCOM8")
		If SELECT("NBX") = 0
			DBSelectArea("NBX")
			lNBX := .T.
		EndIf
		NBX->(DbSetOrder(1))
		NBX->(DbGoTop())
		If NBX->(DbSeek( FwXFilial("NBX") + cCodCtr + PadR(AllTrim(cDoc),TamSx3('NBX_DOC')[1]) + "A3"   ) )
			cItem    := NBX->NBX_ITEM
			nValor   := NBX->NBX_VALOR
			cObserva := NBX->NBX_HISTOR
		Else
			MsgInfo(STR0047, STR0027 )   //"Documento não encontrado na tabela NBX"
			Return .F.
		EndIF
	EndIf

	cPrefixo    := SuperGetMV("MV_AGRO031", .F., "A3")
	cParcela    := StrZero(Val(cItem),2)
	cFilTit     := ""

	lMsErroAuto := .F.

	NBX->(DbSetOrder(1)) //NBX_FILIAL+NBX_CODCTR+NBX_DOC+NBX_TIPO+NBX_ITEM
	If NBX->(DbSeek(xFilial("NBX") + cCodCtr + PadR(cDoc, TamSX3("NBX_DOC")[1] )+ "A3" + cItem ))

		N9A->(DbSetOrder(1))
		If N9A->(DbSeek(cFilCtr + cCodCtr + NBX->NBX_CODCAD + NBX->NBX_SEQPRI ))
			//coloca a filial conforme a regra fiscal
			cFilTit := N9A->N9A_FILORG
		endif

		If cStAlc == "A"

			NJR->(DbSetOrder(1))
			NJR->(DbSeek(cFilCtr+cCodCtr))

			//grava as variáveis e grava N8L
			aN8lVinc := {}
			aAdd( aN8lVinc, { "N8L_FILIAL"  , FwXfilial('N8L') 	} )
			aAdd( aN8lVinc, { "N8L_FILORI"  , iif(!empty(cFilTit),cFilTit,FwXfilial('N8L')) } ) //usa a mesma filial da N8L
			aAdd( aN8lVinc, { "N8L_PREFIX"  , cPrefixo          } ) //é Utilizado tipo de documento da alçada
			aAdd( aN8lVinc, { "N8L_NUM"     , cDoc              } ) //código do contrato
			aAdd( aN8lVinc, { "N8L_PARCEL"  , cParcela          } ) //usa parcela em BRANCO
			aAdd( aN8lVinc, { "N8L_TIPO"    , "NCC"		        } ) //Fixo NCC que é o tipo que está sendo gerado
			aAdd( aN8lVinc, { "N8L_CODCTR"  , cCodCtr           } )
			aAdd( aN8lVinc, { "N8L_SAFRA"  	, NJR->NJR_CODSAF	} )
			aAdd( aN8lVinc, { "N8L_CODROM"  , ""	            } )
			aAdd( aN8lVinc, { "N8L_ITEROM" 	, ""	            } )
			aAdd( aN8lVinc, { "N8L_CODFIX" 	, ""				} )
			aAdd( aN8lVinc, { "N8L_CODOTR"  , ""				} )
			aAdd( aN8lVinc, { "N8L_ORPGRC" 	, ""				} )
			aAdd( aN8lVinc, { "N8L_ORIGEM"  , "OGA450"			} )
			aAdd( aN8lVinc, { "N8L_HISTOR"  , cObserva			} )

			lRet := fAgrVncRec ({aN8lVinc}, 3 )  	//Incluir

			If lRet
				//gera titulo na SE1
				aFina040 := {}
				aAdd( aFina040, { "E1_FILIAL"  , FwXfilial('SE1'), Nil } )
				aAdd( aFina040, { "E1_PREFIXO" , cPrefixo        , Nil } )
				aAdd( aFina040, { "E1_NUM"     , cDoc            , Nil } )
				aAdd( aFina040, { "E1_PARCELA" , cParcela        , Nil } )
				aAdd( aFina040, { "E1_TIPO"    , "NCC"           , Nil } )
				aAdd( aFina040, { "E1_CLIENTE" , Posicione("NJ0",1,FwXFilial("NJ0") + NJR->NJR_CODENT + NJR->NJR_LOJENT,"NJ0_CODCLI"), Nil } )
				aAdd( aFina040, { "E1_LOJA"    , Posicione("NJ0",1,FwXFilial("NJ0") + NJR->NJR_CODENT + NJR->NJR_LOJENT,"NJ0_LOJCLI"), Nil } )
				aAdd( aFina040, { "E1_NATUREZ" , NBX->NBX_NATURE , Nil } )
				aAdd( aFina040, { "E1_EMISSAO" , ddatabase       , Nil } )
				aAdd( aFina040, { "E1_VENCTO"  , ddatabase       , Nil } )
				aAdd( aFina040, { "E1_VALOR"   , nValor          , Nil } )
				aAdd( aFina040, { "E1_MOEDA"   , NJR->NJR_MOEDA  , Nil } )
				aAdd( aFina040, { "E1_VLCRUZ"  , nValor  , Nil } )
				aAdd( aFina040, { "E1_CCUSTO"  , Posicione("SB1",1,FwXFilial("SB1") + NJR->NJR_CODPRO ,"B1_CC") , Nil } )
				If "1,3" $ SuperGetMv("MV_ITMCLVL")
					aAdd( aFina040, { "E1_CLVL"    , NJR->NJR_CODSAF , Nil } )
				EndIf
				aAdd( aFina040, { "E1_HIST"    , cObserva        , Nil } )
				aAdd( aFina040, { "E1_ORIGEM"  , "OGA450"        , Nil } )
				aAdd( aFina040, { "E1_FILORIG" , iif(!empty(cFilTit),cFilTit,FwXfilial('N8L')), Nil } )

				//Cria ponto de entrada
				If ExistBlock("OG450NCC")
					aRetPeSE1 := ExecBlock("OG450NCC",.F.,.F.,{aFina040, cFilCtr + cCodCtr})
					If ValType( aRetPeSE1 ) == "A"
						aFina040 := aClone(aRetPeSE1)
					EndIf
				EndIf

				MsExecAuto( { |x,y| Fina040( x, y ) }, aFina040, 3)

				If lMsErroAuto
					MostraErro()
					lRet := .F.
				EndIf

				If RecLock("NBX",.F.)
					NBX->NBX_FILNUM := FwXfilial('SE1')
					NBX->NBX_NUM    := cDoc
					NBX->NBX_PREFIX := cPrefixo
					NBX->NBX_PARCEL := cParcela
					NBX->NBX_TIPNUM   := "NCC"
					NBX->NBX_STATUS := "A"
					NBX->(MsUnLock())
				EndIf

			EndIf
		EndIf
		
		IF lNBX
			NBX->(DbCloseArea())
		EndIF
	EndIf

	NBX->(DbSetOrder(1))
	NBX->(DbGoTop())
	If NBX->(DbSeek( FwXFilial("NBX") + cCodCtr + PadR(AllTrim(cDoc),TamSx3('NBX_DOC')[1]) + "A3"   ) )
		NC8->(dbSetOrder(2)) //NC8_FILIAL+NC8_FILCTR+NC8_CODCTR+NC8_CODCAD+NC8_REGRA+NC8_DOC+NC8_SERIE+NC8_TPDOC
		If NC8->(DbSeek(cFilTit + cFilCtr + NBX->NBX_CODCTR + NBX->NBX_CODCAD + NBX->NBX_SEQPRI + PADR(NBX->NBX_DOC, TamSX3("NC8_DOC")[1]) + SPACE(TamSX3("NC8_SERIE" )[1]) + PADR("NCC", TamSX3("NC8_TPDOC")[1]) ))
			While NC8->(!Eof()) .and. ;
			(cFilTit + cFilCtr + NBX->NBX_CODCTR + NBX->NBX_CODCAD + NBX->NBX_SEQPRI + PADR(NBX->NBX_DOC, TamSX3("NC8_DOC")[1]) + SPACE(TamSX3("NC8_SERIE" )[1]) + PADR("NCC", TamSX3("NC8_TPDOC")[1]) ) == NC8->(NC8_FILIAL+NC8_FILCTR+NC8_CODCTR+NC8_CODCAD+NC8_REGRA+NC8_DOC+NC8_SERIE+NC8_TPDOC)
				If RecLock("NC8", .F.)
					Iif(cStAlc == 'R', NC8->NC8_STATUS := '1', NC8->NC8_STATUS := '2')
					NC8->(MsUnLock())
				EndIf
				NC8->(DbSkip())
				lRet := .T.
			EndDo
		EndIf
	EndIf

	If !lRet 
		Help( ,, STR0027,,STR0070, 1, 0 )  //"AJUDA",,Não foi possível realizar a geração do título NCC.
	EndIf

	RestArea(aAreaNBX)
	RestArea(aAreaNJR)
	RestArea(aAreaNC8)


Return lRet

/*/{Protheus.doc} A450GERNDC
	Função para gerar o titulo dos documentos do tipo A4. Chamado na função AGRXFUN1
	@type  Function
	@author marcelo ferrari / Filipe Olegini
	@since 23/07/2018
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Function A450GERNDC(cFilCtr as char, cCodCtr as char, cDoc as char, cItem as char, nValor as Numeric, dVencto as Date, cObserva as char, cStAlc as char)
	Local aAreaNBX      as array
	Local aAreaNJR      as array
	Local aAreaNC8      as array
	Local cPrefixo      as char
	Local cParcela      as char
	Local lRet          as Logical
	Local lNBX          as logical
	Local cFilTit       as char

	Private lMsErroAuto as logical

	Default cItem := ""
	Default nValor := 0
	Default dVencto := dDataBase
	Default cObserva := ""
	Default cStAlc  := ""

	cFilTit     := FwXFilial("SE1")
	lRet        := .F.

	aAreaNBX    := NBX->(GetArea())
	aAreaNJR    := NJR->(GetArea())
	aAreaNC8    := NC8->(GetArea())

	lNBX := .F.
	//AGRXCOM8(cNumDoc, cTipDoc, cRecno)
	If FWISINCALLSTACK("AGRXCOM8")
		If SELECT("NBX") = 0
			DBSelectArea("NBX")
		EndIf
		NBX->(DbSetOrder(1))
		NBX->(DbGoTop())
		If NBX->(DbSeek( FwXFilial("NBX") + cCodCtr + PadR(AllTrim(cDoc),TamSx3('NBX_DOC')[1]) + "A4"   ) )
			cItem  := NBX->NBX_ITEM
			nValor := NBX->NBX_VALOR
			dVencto := NBX->NBX_DATA
			cObserva := NBX->NBX_HISTOR
		Else
			MsgInfo(STR0047, STR0027 )     //"Não foi possivel abrir a tabela NBX para gravação"
			Return .F.
		EndIF
	EndIf

	cPrefixo    := SuperGetMV("MV_AGRO032", .F., "A4")
	cParcela    := StrZero(Val(cItem),2)

	lMsErroAuto := .F.

	NBX->(DbSetOrder(1)) //NBX_FILIAL+NBX_CODCTR+NBX_DOC+NBX_TIPO+NBX_ITEM
	If NBX->(DbSeek(xFilial("NBX") + cCodCtr + PadR(cDoc, TamSX3("NBX_DOC")[1] )+ "A4" + cItem ))

		N9A->(DbSetOrder(1))
		If N9A->(DbSeek(cFilCtr + cCodCtr + NBX->NBX_CODCAD + NBX->NBX_SEQPRI ))
			//coloca a filial conforme a regra fiscal
			cFilTit := N9A->N9A_FILORG
		endif

		If cStAlc == "A"
			NJR->(DbSetOrder(1))
			NJR->(DbSeek(cFilCtr+cCodCtr))

			//grava as variáveis e grava N8L
			aN8MVinc := {}
			aAdd( aN8MVinc, { "N8M_FILIAL"  , FwXfilial('N8M') 	} )
			aAdd( aN8MVinc, { "N8M_FILORI"  , iif(!empty(cFilTit),cFilTit,FwXfilial('N8M'))} ) //usa a mesma filial da N8L
			aAdd( aN8MVinc, { "N8M_PREFIX"  , cPrefixo          } ) //é Utilizado tipo de documento da alçada
			aAdd( aN8MVinc, { "N8M_NUM"     , cDoc              } ) //código do contrato
			aAdd( aN8MVinc, { "N8M_PARCEL"  , cParcela          } ) //usa parcela em BRANCO
			aAdd( aN8MVinc, { "N8M_TIPO"    , "NDC"		        } ) //Fixo NCC que é o tipo que está sendo gerado
			aAdd( aN8MVinc, { "N8M_CODCTR"  , cCodCtr           } )
			aAdd( aN8MVinc, { "N8M_CODSAF"  	, NJR->NJR_CODSAF	} )
			aAdd( aN8MVinc, { "N8M_FORNEC"  , Posicione("NJ0",1,FwXFilial("NJ0") + NJR->NJR_CODENT + NJR->NJR_LOJENT,"NJ0_CODCLI")	} )
			aAdd( aN8MVinc, { "N8M_LOJA"    , Posicione("NJ0",1,FwXFilial("NJ0") + NJR->NJR_CODENT + NJR->NJR_LOJENT,"NJ0_LOJCLI") } )
			aAdd( aN8MVinc, { "N8M_ORIGEM"  , "OGA450"			} )
			aAdd( aN8MVinc, { "N8M_HISTOR"  , cObserva			} )

			lRet := fAgrVncPag ({aN8MVinc}, 3 )  	//Incluir

			If lRet
				//gera titulo na SE1
				aFina040 := {}
				aAdd( aFina040, { "E1_FILIAL"  , FwXfilial('SE1'), Nil } )
				aAdd( aFina040, { "E1_PREFIXO" , cPrefixo        , Nil } )
				aAdd( aFina040, { "E1_NUM"     , cDoc            , Nil } )
				aAdd( aFina040, { "E1_PARCELA" , cParcela        , Nil } )
				aAdd( aFina040, { "E1_TIPO"    , "NDC"           , Nil } )
				aAdd( aFina040, { "E1_CLIENTE" , Posicione("NJ0",1,FwXFilial("NJ0") + NJR->NJR_CODENT + NJR->NJR_LOJENT,"NJ0_CODCLI"), Nil } )
				aAdd( aFina040, { "E1_LOJA"    , Posicione("NJ0",1,FwXFilial("NJ0") + NJR->NJR_CODENT + NJR->NJR_LOJENT,"NJ0_LOJCLI"), Nil } )
				aAdd( aFina040, { "E1_NATUREZ" , NBX->NBX_NATURE , Nil } )
				aAdd( aFina040, { "E1_EMISSAO" , ddatabase       , Nil } )
				aAdd( aFina040, { "E1_VENCTO"  , ddatabase       , Nil } )
				aAdd( aFina040, { "E1_VALOR"   , nValor          , Nil } )
				aAdd( aFina040, { "E1_MOEDA"   , NJR->NJR_MOEDA  , Nil } )
				aAdd( aFina040, { "E1_VLCRUZ"  , nValor  , Nil } )
				aAdd( aFina040, { "E1_CCUSTO"  , Posicione("SB1",1,FwXFilial("SB1") + NJR->NJR_CODPRO ,"B1_CC") , Nil } )
				If "1,3" $ SuperGetMv("MV_ITMCLVL")
					aAdd( aFina040, { "E1_CLVL"    , NJR->NJR_CODSAF , Nil } )
				EndIf
				aAdd( aFina040, { "E1_HIST"    , cObserva        , Nil } )
				aAdd( aFina040, { "E1_ORIGEM"  , "OGA450"        , Nil } )
				aAdd( aFina040, { "E1_FILORIG" , iif(!empty(cFilTit),cFilTit,FwXfilial('N8L')), Nil } )

				//Cria ponto de entrada
				If ExistBlock("OG450NDC")
					aRetPeSE2 := ExecBlock("OG450NDC",.F.,.F.,{aFina040, cFilCtr + cCodCtr})
					If ValType( aRetPeSE2 ) == "A"
						aFina040 := aClone(aRetPeSE2)
					EndIf
				EndIf

				//ordena os arrays de acordo com o dicionário para passar para rotina automarica
				aFina040   := FWVetByDic(aFina040	, 'SE1', .F.)

				MsExecAuto( { |x,y| Fina040( x, y ) }, aFina040, 3)

				If lMsErroAuto
					MostraErro()
					lRet := .F.
				EndIf

				If RecLock("NBX",.F.)
					NBX->NBX_FILNUM := FwXfilial('SE1')
					NBX->NBX_NUM    := cDoc
					NBX->NBX_PREFIX := cPrefixo
					NBX->NBX_PARCEL := cParcela
					NBX->NBX_TIPNUM := "NDC"
					NBX->NBX_STATUS := "A"
					NBX->(MsUnLock())
				EndIf
			EndIf
		EndIf
	EndIf
	
	IF lNBX
		NBX->(DbCloseArea())
	EndIF

	If lRet
		NBX->(DbSetOrder(1))
		NBX->(DbGoTop())
		If NBX->(DbSeek( FwXFilial("NBX") + cCodCtr + PadR(AllTrim(cDoc),TamSx3('NBX_DOC')[1]) + "A4"   ) )
			NC8->(dbSetOrder(2)) //NC8_FILIAL+NC8_FILCTR+NC8_CODCTR+NC8_CODCAD+NC8_REGRA+NC8_DOC+NC8_SERIE+NC8_TPDOC
			If NC8->(DbSeek(cFilTit + cFilCtr + NBX->NBX_CODCTR + NBX->NBX_CODCAD + NBX->NBX_SEQPRI + PADR(NBX->NBX_DOC, TamSX3("NC8_DOC")[1]) + SPACE(TamSX3("NC8_SERIE" )[1]) + PADR("NDC", TamSX3("NC8_TPDOC")[1]) ))
				While NC8->(!Eof()) .and. ;
				(cFilTit + cFilCtr + NBX->NBX_CODCTR + NBX->NBX_CODCAD + NBX->NBX_SEQPRI + PADR(NBX->NBX_DOC, TamSX3("NC8_DOC")[1]) + SPACE(TamSX3("NC8_SERIE" )[1]) + PADR("NDC", TamSX3("NC8_TPDOC")[1]) ) == NC8->(NC8_FILIAL+NC8_FILCTR+NC8_CODCTR+NC8_CODCAD+NC8_REGRA+NC8_DOC+NC8_SERIE+NC8_TPDOC)
					If RecLock("NC8", .F.)
						Iif(cStAlc == 'R', NC8->NC8_STATUS := '1', NC8->NC8_STATUS := '2')
						NC8->(MsUnLock())
					EndIf
					NC8->(DbSkip())
					lRet := .t.
				EndDo
			EndIf
		EndIf
	EndIf

	If !lRet 
		Help( ,, STR0027,,STR0069, 1, 0 )  //"AJUDA",,Não foi possível realizar a geração do título NDC.
	EndIf

	RestArea(aAreaNBX)
	RestArea(aAreaNJR)
	RestArea(aAreaNC8)

Return lRet


/*{Protheus.doc} A450LoFixa
	//Função para carregar os dados da temp da tela de Fixaxoes de acordo com os romaneios marcados
	@type  Static Function
	@author filipe.olegini
	@since 16/07/2018
	@param cfilCtr, char, filial do contrato
	@param cCodCtr, char, código do contrato
	@param cItem, char, Item da regra fiscal
	@param cSeqPri, sequencia da regra fiscal
	@see (links_or_references)
/*/
Static Function A450LoFixa(cfilCtr as char, cCodCtr as char, cItem as char, cSeqPri as char)
	Local cQuery    as char
	Local cAliasQry as char

	cQuery    := ""
	cAliasQry := GetNextAlias()

	If Select(cAliasQry) <> 0
		(cAliasQry)->(dbCloseArea())
	EndIf

	cQuery := " SELECT N8D.N8D_FILIAL, N8D.N8D_CODCTR, N8D.N8D_ITEMFX, N8D.N8D_ORDEM, "
	cQuery +=       "N8D.N8D_CODCAD, N8D.N8D_REGRA, N8D_QTDVNC, N8D_QTDFAT, N8D_VALOR,"
	cQuery +=       "N9A.N9A_DATINI, N9A.N9A_DATFIM "
	cQuery += " FROM " + RetSqlName('N8D') + " N8D"
	cQuery += " INNER JOIN " + RetSqlName('N9A') + " N9A ON ( "
	cQuery +=       " N8D.N8D_FILORG = N9A.N9A_FILIAL AND "
	cQuery +=       " N8D.N8D_CODCTR = N9A.N9A_CODCTR AND "
	cQuery +=       " N8D.N8D_ITEMFX = N9A.N9A_ITEM AND "
	cQuery +=       " N9A.D_E_L_E_T_ = ' ') "
	cQuery += " WHERE N8D.D_E_L_E_T_ = '' "
	cQuery += " AND N8D_FILIAL = '" + cfilCtr + "' "
	cQuery += " AND N8D_CODCTR = '" + cCodCtr + "' "
	cQuery += " AND N8D_CODCAD = '" + cItem + "' "
	cQuery += " AND N8D_REGRA  = '" + cSeqPri + "' "
	cQuery += " AND N8D_QTDVNC <> N8D_QTDFAT "

	cQuery := ChangeQuery(cQuery)

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	While (cAliasQry)->(!Eof())

		If RecLock((_cAliasBr2),.T.)
			(_cAliasBr2)->MARK   := "1"
			(_cAliasBr2)->FILIAL := (cAliasQry)->N8D_FILIAL
			(_cAliasBr2)->CODCTR := (cAliasQry)->N8D_CODCTR
			(_cAliasBr2)->DTINI  := STOD((cAliasQry)->N9A_DATINI)
			(_cAliasBr2)->DTFIM  := STOD((cAliasQry)->N9A_DATFIM)
			(_cAliasBr2)->ITEMFX := (cAliasQry)->N8D_ITEMFX
			(_cAliasBr2)->CODCAD := (cAliasQry)->N8D_CODCAD
			(_cAliasBr2)->REGRA  := (cAliasQry)->N8D_REGRA
			(_cAliasBr2)->ORDEM  := (cAliasQry)->N8D_ORDEM
			(_cAliasBr2)->QTDVNC := (cAliasQry)->N8D_QTDVNC
			(_cAliasBr2)->QTDFAT := (cAliasQry)->N8D_QTDFAT
			(_cAliasBr2)->DIFERE := (cAliasQry)->N8D_QTDVNC - (cAliasQry)->N8D_QTDFAT
			(_cAliasBr2)->VALOR  := (cAliasQry)->N8D_VALOR
			(_cAliasBr2)->(MsUnLock())
		EndIf

		(cAliasQry)->(DbSkip())
	EndDo

	(cAliasQry)->(dbCloseArea())

Return .T.

/*{Protheus.doc} A450LoPrev
	//Função para carregar os dados da temp da tela de PRevisoes de acordo com o browser marcado
	@type  Static Function
	@author filipe.olegini
	@since 16/07/2018
	@param cfilCtr, char, filial do contrato
	@param cCodCtr, char, código do contrato
	@param cItem, char, Item da regra fiscal
	@param cSeqPri, sequencia da regra fiscal
	@see (links_or_references)
/*/
Static Function A450LoPrev(cfilCtr as char, cCodCtr as char, cItem as char, cSeqPri as char)
	Local cQuery    as char
	Local cAliasQry as char

	cQuery    := ""
	cAliasQry := GetNextAlias()

	If Select(cAliasQry) <> 0
		(cAliasQry)->(dbCloseArea())
	EndIf

	cQuery := " SELECT NN7.NN7_FILIAL,NN7.NN7_CODCTR,NN7.NN7_ITEM,NN7.NN7_PARCEL,N9J.N9J_ITEMPE,N9J.N9J_ITEMRF,"
	cQuery +=        " NN7.NN7_DTVENC,NN7.NN7_VALOR,NN7.NN7_VLTEMI,NN7.NN7_VLSALD, NNY.NNY_MESEMB  "
	cQuery +=   " FROM " + RetSqlName('NN7') + " NN7 "
	cQuery +=  " INNER JOIN " + RetSqlName('N9J') + " N9J ON (N9J.N9J_FILIAL = NN7.NN7_FILIAL AND "
	cQuery +=                                               " N9J.N9J_CODCTR = NN7.NN7_CODCTR AND "
	cQuery +=                                               " N9J.N9J_SEQPF = NN7.NN7_ITEM AND "
	cQuery +=                                               " N9J.D_E_L_E_T_ = NN7.D_E_L_E_T_) "
	cQuery +=  "  INNER JOIN " + RetSqlName('NNY') + " NNY ON (NNY.NNY_FILIAL = NN7.NN7_FILIAL AND "
	cQuery +=                                               " NNY.NNY_CODCTR = NN7.NN7_CODCTR AND "
	cQuery +=                                               " NNY.NNY_ITEM = N9J.N9J_ITEMPE AND "
	cQuery +=                                               " NNY.D_E_L_E_T_ = ' ')"
	cQuery +=  " WHERE NN7.D_E_L_E_T_ = '' "
	cQuery +=    " AND NN7.NN7_FILIAL = '" + cfilCtr + "' "
	cQuery +=    " AND NN7.NN7_CODCTR = '" + cCodCtr + "' "
	cQuery +=    " AND N9J.N9J_ITEMPE = '" + cItem + "' "
	cQuery +=    " AND N9J.N9J_ITEMRF = '" + cSeqPri + "' "
	cQuery +=    " AND NN7.NN7_VLSALD > 0 "

	cQuery := ChangeQuery(cQuery)

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	While (cAliasQry)->(!Eof())

		If RecLock((_cAliasBr3),.T.)
			(_cAliasBr3)->MARK   := "1"
			(_cAliasBr3)->FILIAL := (cAliasQry)->NN7_FILIAL
			(_cAliasBr3)->CODCTR := (cAliasQry)->NN7_CODCTR
			(_cAliasBr3)->CODCAD := (cAliasQry)->N9J_ITEMPE
			(_cAliasBr3)->MESEMB := (cAliasQry)->NNY_MESEMB
			(_cAliasBr3)->REGRA  := (cAliasQry)->N9J_ITEMRF
			(_cAliasBr3)->ITEM   := (cAliasQry)->NN7_ITEM
			(_cAliasBr3)->PARCEL := (cAliasQry)->NN7_PARCEL
			(_cAliasBr3)->DATAV  := StoD((cAliasQry)->NN7_DTVENC)
			(_cAliasBr3)->VALOR  := (cAliasQry)->NN7_VALOR
			(_cAliasBr3)->VLTEMI := (cAliasQry)->NN7_VLTEMI
			(_cAliasBr3)->SALDO  := (cAliasQry)->NN7_VLSALD
			(_cAliasBr3)->(MsUnLock())
		EndIf

		(cAliasQry)->(DbSkip())
	EndDo

	(cAliasQry)->(dbCloseArea())

	Return .T.

/*{Protheus.doc} A450LoChk
	//Função chamada no mark do browser 1 que faz o load das temporarias de fixacao e previsao e atualiza os browser delas
	@type  Static Function
	@author filipe.olegini
	@since 16/07/2018
	@param cfilCtr, char, filial do contrato
	@param cCodCtr, char, código do contrato
	@param cAliasAtu, char, alias da tabela que será atualizado
	@param oBro1Refr, objeto, objeto do browser que será atualizado
	@param oBro2Refr, objeto, objeto do browser que será atualizado
	@param oBro3Refr, objeto, objeto do browser que será atualizado
	@param nLinha, numerico, numero da linha do browser 1 para ser posicionada
	@see (links_or_references)
/*/
Static Function A450LoChk(cfilCtr as char, cCodCtr as char, cAliasAtu as char, oBro1Refr as object, oBro2Refr as object, oBro3Refr as object, nLinha as numeric)
	Local aAreaAtu  as array
	Local aRegra    as array
	Local nPos      as numeric
	Local nX        as numeric

	aAreaAtu :=  (cAliasAtu)->(GetArea())
	aRegra   := {}

	//atualiza o browser marcado
	dbSelectArea(cAliasAtu)
	If RecLock((cAliasAtu),.F.)
		(cAliasAtu)->MARK := IIF((cAliasAtu)->MARK  == "1", "", "1")
		(cAliasAtu)->(MsUnlock())
	Endif

	//busca as regras para trazer os dados das previsões e fixaçoes
	(cAliasAtu)->(DbGoTop())
	While (cAliasAtu)->(!EOF())
		//somente os marcados
		If (cAliasAtu)->MARK == "1"
			nPos := aScan(aRegra, {|x| AllTrim(x[1]) == AllTrim((cAliasAtu)->ITEM) .AND.;
			AllTrim(x[2]) == AllTrim((cAliasAtu)->SEQPRI) } )
			If nPos = 0
				aAdd(aRegra, {(cAliasAtu)->ITEM, (cAliasAtu)->SEQPRI})
			EndIf

		EndIf

		(cAliasAtu)->(DbSkip())
	EndDo

	////deleta os registros
	dBSelectArea((_cAliasBr2))
	ZAP

	dBSelectArea((_cAliasBr3))
	ZAP

	_nCompFat   := 0
	_nSldPrev   := 0
	_nTotalFat  := 0
	_nTotalQtd  := 0

	For nX := 1 To Len(aRegra)

		//busca fixacoes
		A450LoFixa(cfilCtr, cCodCtr, aRegra[nX][1], aRegra[nX][2])

		//busca previsoes
		A450LoPrev(cfilCtr, cCodCtr, aRegra[nX][1], aRegra[nX][2])

	Next

	//*********************************
	//Atualiza campos totalizadores
	//*********************************

	//Total Faturado / Complemento de nota
	(_cAliasBr1)->(DbGoTop())
	While (_cAliasBr1)->(!Eof())
		If (_cAliasBr1)->MARK == '1'
			_nTotalFat  += (_cAliasBr1)->VALDOC
			_nCompFat  += (_cAliasBr1)->VALNFC
		EndIf
		(_cAliasBr1)->(DbSkip())

	EndDo

	//Total de quantidade faturada
	(_cAliasBr2)->(DbGoTop())
	While (_cAliasBr2)->(!Eof())
		_nTotalQtd  += (_cAliasBr2)->QTDFAT
		(_cAliasBr2)->(DbSkip())

	EndDo

	//Total do saldo das previsões
	(_cAliasBr3)->(DbGoTop())
	While (_cAliasBr3)->(!Eof())
		_nSldPrev  += (_cAliasBr3)->SALDO
		(_cAliasBr3)->(DbSkip())

	EndDo

	RestArea(aAreaAtu)

	//atualiza o browser de fixaxao e previsao
	oBro2Refr:UpdateBrowse()
	oBro3Refr:UpdateBrowse()

	//atualiza o browser de romaneios
	oBro1Refr:UpdateBrowse()
	oBro1Refr:SetFocus()
	oBro1Refr:GoColumn(1) //posiciona sempre na primeira coluna
	oBro1Refr:GoTo(nLinha) //volta pra linha que estava antes de fazer o while na temp

Return .T.

/*/{Protheus.doc} A450ChkBr3
	//Função para atualizar totais conforme marca/desmarca
	@type  Static Function
	@author mauricio.joao
	@since 31/07/2018
	@param cAliasAtu, char, alias da tabela que será atualizada
	@param oBroRefr, objeto, objeto do browser que será atualizado
	@see (links_or_references)
/*/
Static Function A450ChkBr3(cAliasAtu as char, oBroRefr as object)

	aAreaBr3    := (_cAliasBr3)->(GetArea())

	dbSelectArea(cAliasAtu)
	If RecLock((cAliasAtu),.F.)
		(cAliasAtu)->MARK := IIF((cAliasAtu)->MARK  == "1", "", "1")
		(cAliasAtu)->(MsUnlock())
	Endif

	_nSldPrev := 0

	//Total do saldo das previsões
	(cAliasAtu)->(DbGoTop())
	While (cAliasAtu)->(!Eof())
		If (cAliasAtu)->MARK == '1'
			_nSldPrev  += (cAliasAtu)->SALDO

		EndIf
		(cAliasAtu)->(DbSkip())

	EndDo

	//testa e atualiza o browser
	If Type("oBroRefr") <> "U"
		oBroRefr:UpdateBrowse()
	EndIf

	RestArea(aAreaBr3)

Return .T.

/*/{Protheus.doc} A450Chk
	//Função marcar e desmarcar apenas
	@type  Static Function
	@author filipe.olegini
	@since 16/07/2018
	@param cAliasAtu, char, alias da tabela que será atualizada
	@param oBroRefr, objeto, objeto do browser que será atualizado
	@see (links_or_references)
/*/
Static Function A450Chk(cAliasAtu as char, oBroRefr as object)

	dbSelectArea(cAliasAtu)
	If RecLock((cAliasAtu),.F.)
		(cAliasAtu)->MARK := IIF((cAliasAtu)->MARK  == "1", "", "1")
		(cAliasAtu)->(MsUnlock())
	Endif		

    //testa e atualiza o browser
    If Type("oBroRefr") <> "U"
        oBroRefr:UpdateBrowse()
    EndIf
	

Return .T.

/*/{Protheus.doc} OGA450ANN7
	Função para atualizar o saldo da NN7
	@type  Static Function
	@author filipe.olegini
	@since 17/07/2018
	@param cFilNN7, char, Filial do contrato
	@param cCodCtr, char, código do contrato
	@param cItem, char, Item da sequencia da NN7
	@param nValorBx, numeric, valor para baixar na NN7
	@see (links_or_references)
/*/
Static Function OGA450ANN7(cFilNN7 as char, cCodCtr as char, cItem, nValorBx as numeric )
	Local aAreaNN7  as array

	aAreaNN7 := NN7->(GetArea())

	NN7->(dbSetOrder(1)) //NN7_FILIAL+NN7_CODCTR+NN7_ITEM
	If NN7->(dbSeek(cFilNN7 + cCodCtr + cItem))
		If RecLock("NN7",.F.)
			NN7->NN7_VLTEMI += nValorBx
			NN7->NN7_VLTNCO += nValorBx
			NN7->NN7_VLSALD := 0
			NN7->NN7_STSTIT := "2"
			NN7->(MsUnlock())
		EndIf
	EndIf

	RestArea(aAreaNN7)

Return .T.

/*/{Protheus.doc} OGA450AN8D
	Função para atualizar o saldo da N8D e NN8
	@type  Static Function
	@author filipe.olegini
	@since 17/07/2018
	@param cFilFix, char, filial do contrato
	@param cCodCtr, char, código do contrato
	@param cOrdem, char, codigo da ordem da N8D
	@param cItemFix, char, código da fixacao da NN8
	@see (links_or_references)
/*/
Static Function OGA450AN8D(cFilFix as char, cCodCtr as char, cOrdem as char, cItemFix as char )
	Local aAreaN8D  as array
	Local aAreaNN8  as array

	aAreaN8D    := N8D->(GetArea())
	aAreaNN8    := NN8->(GetArea())

	//consome as quantidades totais da N8D
	N8D->(dbSetOrder(1) )//N8D_FILIAL+N8D_CODCTR+N8D_ORDEM
	If N8D->(dbSeek(cFilFix + cCodCtr + cOrdem))
		If RecLock("N8D",.F.)
			N8D->N8D_QTDFAT := N8D->N8D_QTDVNC
			N8D->(MsUnLock())
		EndIf
	EndIf

	//consome as quantidades totais da NN8
	NN8->(dbSetOrder(1)) //NN8_FILIAL+NN8_CODCTR+NN8_ITEMFX
	If NN8->(dbSeek(cFilFix + cCodCtr + cItemFix))
		If RecLock("NN8",.F.)
			NN8->NN8_QTDENT := NN8->NN8_QTDFIX
			NN8->(MsUnLock())
		Endif
	EndIf

	RestArea(aAreaNN8)
	RestArea(aAreaN8D)

Return .T.

/*{Protheus.doc} OGA450INFC
//Função que exibe a tela com os dados do romaneio e o usuário informa o valor para gerar o complemento de preço
@type  Function
@author filipe.olegini
@since 16/07/2018
@version 1.0
@type function
*/
Function OGA450INFC()
	Local aArea         := GetArea()
	Local oSize         := Nil
	Local oMStru        := FwFormModelStruct():New()
	Local oVStru        := FwFormViewStruct():New()
	Local oModel        := FwFormModel():New("OGA450CPAR", , , {|| .T.}, {|| .T.}) // Instancia um modelo
	Local oView         := FwFormView():New() // Instancia uma View
	Local oViewExec     := FWViewExec():New() // Instancia um Executor de View
	Local nWidth        := 0
	Local nHeight       := 0
	Local nValor        := 0
	Local bInit         := {|| 0 }
	Local aButtons 	    := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T., STR0037},{.T., STR0038},{.F., Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} // # "Confirmar" # "Cancelar"

	oSize   := FwDefSize():New(.T.) // Considera a enchoice bar

	nWidth  := (oSize:AWINDSIZE[4] * 0.15) // 15% da largura total da tela
	nHeight := (oSize:AWINDSIZE[3] * 0.15) // 15% da altura total da tela

	oMStru:AddField(STR0031	                            ,;  	// [01] C Titulo do campo // # "Valor NF COMPL
	STR0031	                            ,;   	// [02] C ToolTip do campo // # "Valor NF COMPL
	"VALORPARC" 		                ,;    	// [03] C identificador (ID) do Field
	TamSX3("E1_VALOR" )[3] 		        ,;    	// [04] C Tipo do campo
	TamSX3("E1_VALOR" )[1] 			    ,;    	// [05] N Tamanho do campo
	TamSX3("E1_VALOR" )[2] 		        ,;    	// [06] N Decimal do campo
	Nil                                 ,;    	// [07] B Code-block de validacao do campo
	Nil					                ,;     	// [08] B Code-block de validacao When do campo
	Nil 				                ,;    	// [09] A Lista de valores permitido do campo
	.T. 				                ,;  	// [10] L Indica se o campo tem preenchimento obrigatorio
	bInit		                        ,;   	// [11] B Code-block de inicializacao do campo
	Nil 				                ,;  	// [12] L Indica se trata de um campo chave
	.T. )    	                                // [13] L Indica se o campo pode receber valor em uma operacaoo de update.

	oVStru:AddField("VALORPARC"	                        ,;  	// [01] C Id do Campo
	"01"	                            ,;   	// [02] C Ordem
	STR0031 		                    ,;    	// [03] C Titulo do campo // # "Valor NF COMPL
	STR0031                         	,;    	// [04] C Descrição do campo // # "Valor NF COMPL
	{STR0031} 	                        ,;    	// [05] A Array com Help // # "Valor NF COMPL
	TamSX3("E1_VALOR" )[3] 				,;    	// [06] C Tipo do campo
	PesqPict("SE1","E1_VALOR") 		    ,;    	// [07] C Picture
	Nil					                ,;     	// [08] B Bloco de Picture Var
	Nil 				                ,;    	// [09] C Consulta F3
	.T. 				                ,;  	// [10] L Indica se o campo é evitável
	Nil		                            ,;   	// [11] C Pasta do campo
	Nil 				                ,;  	// [12] C Agrupamento do campo
	Nil 				                ,;     	// [13] A Lista de valores permitido do campo (Combo)
	Nil                                 ,;      // [14] N Tamanho Maximo da maior opção do combo
	Nil                                 ,;      // [15] C Inicializador de Browse
	Nil                                 ,;      // [16] L Indica se o campo é virtual
	Nil )                                       // [17] C Picture Variável

	oModel:SetDescription(STR0032) // Gera Nota Fiscal de Complemento.
	oModel:AddFields("FIELDVPARC", , oMStru) // Pre requisito para criacao de uma view
	oModel:GetModel("FIELDVPARC"):SetDescription(STR0031) // # Valor NF Cpl
	oModel:SetPrimaryKey({"VALORPARC"})

	oView:SetModel(oModel)
	oView:AddField("VIEWVPARC", oVStru, "FIELDVPARC")

	oView:CreateHorizontalBox("BOXVIEWVPARC", 100)
	oView:SetOwnerView("VIEWVPARC", "BOXVIEWVPARC")

	oView:SetViewProperty("VIEWVPARC", "SETLAYOUT", {FF_LAYOUT_VERT_DESCR_TOP, 1}) // Seta o layout de forma vertical com 1 coluna

	oViewExec:SetView(oView)
	oViewExec:setOperation(MODEL_OPERATION_INSERT)
	oViewExec:SetButtons(aButtons)
	oViewExec:SetTitle(STR0032) // # gera nota fiscal de complemento
	oViewExec:SetOk({|| OGA450INOK(oModel, oView, @nValor) })
	oViewExec:SetCloseOnOk({|| .T.})
	oViewExec:SetSize(nHeight, nWidth)

	oViewExec:openView(.F.)

	RestArea(aArea)

Return nValor

/*{Protheus.doc} OGA450INOK
	//Função de OK da tela de valor
	@type  Function
	@author filipe.olegini
	@since 16/07/2018
	@version 1.0
	@type function
*/

Static Function OGA450INOK(oModel as object, oView as object, nValor as numeric)

	nValor := oModel:GetModel("FIELDVPARC"):GetValue("VALORPARC")

	oView:SetModified(.F.)
	oView:ButtonCancelAction()

Return .F. //retornar falso sempre

/*/{Protheus.doc} fWhenObs()
	Bloqueia o campo observação caso o tipo de devolução for 1 - Ao cliente
	@type  Static Function
	@author mauricio.joao
	@since 23/11/2018
	@version 1.0
	@param oModelNxC, object, modelo nxc
	@return lRet, Logical, define se bloqueia ou não o campo
/*/
Static Function fWhenObs(oModelNxC as object, cOpc as char)

	Local lRet as logical
	Local cDev as char

	//load de variaveis
	lRet := .T.

	If cOpc == 'C'
		cDev := oModelNxC:GetModel('FIELDNxC'):GetValue('DEVVAL')

		//se for devolução ele bloqueia a edição do campo observação
		If cDev == '1'
			lRet := .F.
		Else
			lRet := .T.
		EndIf
	EndIf

Return lRet
