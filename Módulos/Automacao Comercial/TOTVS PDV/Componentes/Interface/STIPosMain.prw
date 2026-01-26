#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "POSCSS.CH"
#INCLUDE "STIPOSMAIN.CH"
#INCLUDE "STPOS.CH"

Static oDlg
Static oView
Static oViewDetail
Static oViewRight
Static oGetDiscount
Static oGetSubTot
Static oGetQtde
Static oGetQtdBrinde
Static oSayTotal
Static oBrowse
Static oArea
Static oPOSDesk
Static oMdlPrin
Static oPanelMVC
Static oPanel1
Static oPanel2
Static nPanelActive	:= 0
Static lBtnActive	:= .F.
Static lHomolPaf	:= STBHomolPaf() //Homologação PAF-ECF

Static oBtnRegItem 	:= Nil
Static oBtnClient	:= Nil
Static oBtnCancItem	:= Nil
Static oBtnOrc		:= Nil
Static oBtnDesc		:= Nil
Static oBtnConProd	:= Nil

Static nAtivo		:= CSS_BTN_ATIVO
Static nNormal	:= CSS_BTN_NORMAL

Static cOperation   := "" 	//Operacao em execucao atual
Static cMsgPg 		:= "" 	//Mensagem que retorna no final da funcao
Static oSayPag 		:= Nil 	//Objeto Tsay de paginacao
Static oSemaforo 	:= Nil 	//Objeto semaforo de conexao
Static cLastPnlOpen := "" 	//Guarda ultimo panel chamado na troca de panels

Static lPdvOn		:= ExistFunc("STFPdvOn") .AND. STFPdvOn()
Static lClientHtml	:= GetCliHTML()

//-------------------------------------------------------------------
/*/{Protheus.doc} STIPosMain
Chamada principal para a tela do POS

@param
@author  Varejo
@version P11.8
@since   25/04/2013
@return
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STIPosMain()

Local 	aSemana			:= {STR0001,STR0002, STR0003, STR0004, STR0005, STR0006, STR0007}	// "Domingo","Segunda-Feira", "Terça-Feira", "Quarta-Feira", "Quinta-Feira", "Sexta-Feira", "Sábado"
Local 	oTimer			:= NIL																// Objeto Timer
Local 	nInterval		:= 60000															// 60.000 milisegundos 1 em 1 min
Local 	cCor			:= SuperGetMv( "MV_LJCOLOR",,"07334C")								// Cor da tela
Local 	aMenus			:= {}																// Itens do menu F2
Local	nI				:= 0																// Variavel de loop
Local   lOnlyMenuFiscal := .F.															// Se somente Menu Fiscal 
Local   lPafEcf		    := .F.															// Habilitar PAF-ECF
Local	lTestCon		:= IIf( ExistFunc("LjGetCPDV"), LjGetCPDV()[2] , .F. )			// Testar conexao
Local	lMvTestCon		:= SuperGetMv( "MV_LJTESTC",,.F. )									// Verifica se faz ou nao o teste de conexao
Local nTimeD			:= 60 * 1000 /*segundos*/ * 60 /*minutos*/  * 4 /*horas*/ //Todo: parametro de subida de dados 4 horas
Local nTimeU			:= 15 * 1000 /*segundos*/ * 60 /*minutos*///* 60 /*horas*/ //Todo: paramero de subida de dados 30 minutos
Local cIntegration		:= "" //Verifica a Integracao
Local lMobile			:= .F. //Verifica se é mobile
Local lIsPafNfce		:= .F.

//Seta que o TOTVS PDV é Online
If ExistFunc("STFPdvOn")
	STFSetOnPdv(STFPdvOn())
EndIf

//Valida o tamanho da tela.
aRes := GetScreenRes()

If ExistFunc("LjxAAjSX") //Função para alteração de dicionários
	LjxAAjSX()
EndIf

/* Inicialização */
If !STFStart()
	ClearGlbValue("lConnHost")
	ClearGlbValue("lPosOpen")
	Return
EndIf


LjGrvLog(/*cNumControl*/,"TOTVS PDV INICIADO",/*xVar*/)//Grava Log =====================================================================

lOnlyMenuFiscal := STFGetCfg( "lOnlyMenuFiscal" )
lPafEcf			:= STFGetCfg("lPafEcf")	// PAF-ECF
lIsPafNfce		:= STFGetCfg("lPAFNFCE")

LjGrvLog(/*cNumControl*/,"PAF-ECF",lPafEcf)//Grava Log =====================================================================
LjGrvLog(nil ,"PDV-ONLINE",lPdvOn)//Grava Log =====================================================================

// Abre a tela em fullscreen
FWVldFullScreen()

/* Carregar menus somente apos o STFStart */
aMenus := STBLstOperCashier()

POSBaseColor( cCor )

cIntegration	:= STFGetCfg( "cIntegration" , IIF(!SuperGetMv("MV_LJRMS",,.F.), "DEFAULT", "RMS" )) //Verifica a Integracao
If Valtype(cIntegration) <> "C"
	cIntegration := "DEFAULT"
EndIf 
LjGrvLog(/*cNumControl*/,"Tipo de Integração",cIntegration)//Grava Log =====================================================================

lMobile			:= STFGetCfg("lMobile", .F. ) //Verifica se é mobile

lMobile := ValType(lMobile) = "L" .AND. lMobile
LjGrvLog(/*cNumControl*/,"Modo mobile",lMobile)//Grava Log =====================================================================

//Verifica se fluxo de execucao de rotinas monitoradas foi interrompido
If FindFunction("STWFlowControl")
	STWFlowControl()
EndIf

DEFINE DIALOG oDlg TITLE STR0008 PIXEL STYLE nOr(WS_VISIBLE,WS_POPUP)  //Grafico Radar

	oDlg:nWidth := aRes[1]
	oDlg:nHeight := aRes[2]

	oPOSDesk := POSDesktop():New( oDlg )

	// Monta Menu principal
	oPOSDesk:SetTLMenu( STR0009, VK_F2 )   //"Menu"
	
	//Se nao for acesso soh ao menu fiscal carrega menus 
	If !STFGetCfg("lOnlyMenuFiscal")
		For nI := 1 To Len(aMenus)
			If Len(aMenus[nI]) > 4	
				oPOSDesk:AddTLMenuItem( aMenus[nI][2], &('{||' + 'STIPosSOpc("'+aMenus[nI][5]+'")' + ',' + aMenus[nI][3] + '}') )
				
			Else
				oPOSDesk:AddTLMenuItem( aMenus[nI][2], &('{||' + aMenus[nI][3] + '}') )
			EndIf
		Next nI
	Else
		For nI := 1 To Len(aMenus)
			If aMenus[nI][4] == "M" //item do Menu fiscal/Offline
				oPOSDesk:AddTLMenuItem( aMenus[nI][2], &('{||' + aMenus[nI][3] + '}') )
			EndIf
		Next nI
	EndIf

	oPOSDesk:AddTLMenuItem( STR0010, {|| STFExit() ,oDlg:End() } ) //"Sair"	
	
	If lMvTestCon .AND. cIntegration <> "FIRST"
		MsgRun(STR0027,'',{||STFTestRemoteExecute(lTestCon)})
	EndIf
	
	// Monta menu no canto superior direito
	If lPAFECF .OR. lIsPafNfce
		oPOSDesk:SetTRMenu( STR0011, VK_F12, {|| STBMenFis(.T., .T., !lOnlyMenuFiscal) } )   //"Menu Fiscal"
	Else	
		oPOSDesk:SetTRMenu( STR0012  , VK_F12 , {|| .T. } )    //"TOTVS PDV"
	EndIf

	//Seta informacoes gerais na tela
	oPOSDesk:SetTInfo( iif(lPdvOn,'PDV-ONLINE'+ " | ","") +STR0013 + " " + cEstacao + "    |    " + STR0014 + " " + cUserName )   //"PDV:"  ...  "Operador:"
	
	//Em versoes Mobile nao exibe essa opcao. Somente no Menu superior
	If ExistFunc("STFLatestMsg") .AND. !lMobile
		oPOSDesk:SetBInfo( STR0043 + Space(10) + aSemana[DoW(Date())] + " " + DToC(Date()) +" | " + Left(Time() ,5) )
	Else
		oPOSDesk:SetBInfo(Space(10) + AllTrim(aSemana[DoW(Date())]) + " " + AllTrim(DToC(Date())) +" | " + AllTrim(Left(Time() ,5)) )
	EndIf


	oPOSDesk:Activate()

	//Inicializa com a mensagem em branco
	oPOSDesk:SetBAlert( "" )
	
	If lMobile
	
		oBarBottom := oPOSDesk:GetPanelLogoBottom()
	
		//Versao demostrativa
		//Exibe label especifico
		If STFTypeOperation() == "DEMONSTRACAO"
			@ 003, 013  BUTTON oBtnBuy PROMPT STR0044 + CRLF + STR0045  SIZE 50,015   ACTION {|| FWAlertInfo( STR0045 + ":  fly01.com.br") } OF oBarBottom  PIXEL //"SAIBA COMO" ### "CONTRATAR" ### "Saiba como contratar em"
			oBtnBuy:Align := CONTROL_ALIGN_RIGHT
			oBtnBuy:SetCss(POSCSS( GetClassName(oBtnBuy), CSS_BTN_BUY) ) 
			oBarBottom:Refresh() 
		Else
			//Mobile Defualt não exibe label inferior
			oBarBottom:Hide()
		EndIf	
		
	EndIf
	
	oView := ViewDef()
	oView:SetOwner( oPOSDesk:GetDesktop() )
	oView:SetUseCursor(.F.)
	
	oTimer := TTimer():New(nInterval, {|| STITimeMsg(oPOSDesk,  AllTrim(aSemana[DoW(Date())]) ), lMobile  }, oDlg )
	oTimer:Activate()

	If  cIntegration == "FIRST" .and. FindFunction("STWDownData") 
		oTimerD := TTimer():New(nTimeD, {|| ConOut("Iniciando Job STWDownData " + Dtoc(Date()) + " " + Time() ),  StartJob("STWDownData", GetEnvServer(), .T., cEmpAnt, cFilAnt, STFGetStat("CODIGO"), "5", "T" ) }, oDlg )
		oTimerD:Activate()
	EndIf
	
	If  cIntegration == "FIRST" .and. FindFunction("STWUpData") 
		oTimerD := TTimer():New(nTimeU, {|| ConOut("Iniciando Job STWUpData " + Dtoc(Date()) + " " + Time()), StartJob("STWUpData", GetEnvServer(), .T., cEmpAnt, cFilAnt, STFGetStat("CODIGO"))}, oDlg )
		oTimerD:Activate()

		
	EndIf

ACTIVATE DIALOG oDlg CENTER ON INIT ( oView:Activate(), STIniPos(), IIF(STIShowPagGrid(),STIMsgPag(),)   ) VALID IIF(STFExit(), STIPosClDsk(), .F.)

Return .T.


//---------------------------------------
Static Function STIniPos()

	//Verifica a redução Z pendente 
	If STFGetCfg("lUseECF") .and. !STFGetCfg( "lOnlyMenuFiscal" )
		aRet :=	STFFireEvent(	ProcName(0)																,;		// Nome do processo
								"STChkZReduction"																,;		// Nome do evento
								{.T.} )   
	EndIf


Return

//-------------------------------------------------------------------
/*{Protheus.doc} STIBtnActivate
Ativa os botoes das operacoes e seta os respectivos atalhos

@param
@author  Varejo
@version P11.8
@since   25/04/2013
@return
@obs
@sample
*/
//-------------------------------------------------------------------
Function STIBtnActivate()

Local lAtvCnsPro	:= SuperGetMV("MV_LJTPSCH", .F., 0) <> 2 //0= legado; 1= codigo de barras; 2= bloqueia

/* Registro de item */
SetKey(VK_F3, {|| STIRegItemInterface() })

/* Selecao de cliente */
SetKey(VK_F4, {|| STICustomerSelection()})

/* Cancelamento de item */
SetKey(VK_F5, { || STICancelItem() } )

/* Importar orcamento */
SetKey(VK_F6, { || STIImportSale() } )

/* Desconto na venda */
SetKey(VK_F7, { || STIDiscountTotal() } )

/* Consulta de Produto */
If lAtvCnsPro
	SetKey(VK_F8, { || STIProdSearch() } ) 
Endif 
/* Histórico de mensagens - LOG  */
If FindFunction("STFLatestMsg")
    SetKey(VK_F10, { || STFLatestMsg() } )
EndIf

lBtnActive := .T.

Return

//-------------------------------------------------------------------
/*{Protheus.doc} STIBtnDeActivate
Remove os botoes das operacoes e remove os respectivos atalhos

@param
@author  Varejo
@version P11.8
@since   25/04/2013
@return
@obs
@sample
*/
//-------------------------------------------------------------------
Function STIBtnDeActivate()

Local lAtvCnsPro	:= SuperGetMV("MV_LJTPSCH", .F., 0) <> 2 //0= legado; 1= codigo de barras; 2= bloqueia

/* Registro de item */
SetKey(VK_F3, Nil )

/* Selecao de cliente */
SetKey(VK_F4, Nil )

/* Cancelamento de item */
SetKey(VK_F5, Nil )

/* Importar orcamento */
SetKey(VK_F6, Nil )

/* Desconto na venda */
SetKey(VK_F7, Nil )

/* Consulta de Produto */
If lAtvCnsPro
	SetKey(VK_F8, Nil )
Endif 
 
lBtnActive := .F.

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Model para a criacao da tela principal

@param
@author  Varejo
@version P11.8
@since   25/04/2013
@return
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruct0	//Estrutura do model
Local oStruDtl 	//Estrutura do grid

oStruct0 := FWFormModelStruct():New()
oStruct0:AddTable( "XXW", {"XXW_CODIGO"}, "Cadastro de Dashboard" )
oStruct0:AddIndex( 1,"01","XXW_CODIGO","Código","","",.T. )
oStruct0:AddField( "Código", "Código do Dashboard", "XXW_CODIGO", "C", 6, 0,/*bValid*/,/*bWhen*/,/*aValues*/,.T./*lObrigat*/,/*bInit*/,.T./*lKey*/,.T./*lNoUpd*/,/*lVirtual*/)

oMdlPrin:= MPFormModel():New("APCFG080",/*Pre-Validacao*/,/*Pos-Validacao*/)
oMdlPrin:AddFields("APCFG080_DASH", NIL, oStruct0,/*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/{|| {}})
   

oStruDtl := StructCupomVirtual()
oMdlPrin:AddGrid('CUP_GRID','APCFG080_DASH',oStruDtl)

oMdlPrin:SetOnlyQuery( "APCFG080_DASH" )
oMdlPrin:SetOperation(4)

Return oMdlPrin

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View principal do POS

@param
@author  Varejo
@version P11.8
@since   25/04/2013
@return
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

oView := FWFormView():New()

oView:Setmodel(ModelDef())

oView:CreateHorizontalBox( 'BOX3', 100)

//--------------------------------------------------------------------
// Área de operação
//--------------------------------------------------------------------
oView:CreateVerticalBox( 'BOX4', 50, 'BOX3')
 	//--------------------------------------------------------------------
	// OtherObject Area do Logo
	//--------------------------------------------------------------------
	oView:AddOtherObject('OTHEROBJECT6',{|o| STILogo(o) },,)
	oView:CreateHorizontalBox( 'BOX_OBJECT6', 130, 'BOX4', .T.)
	oView:SetOwnerView('OTHEROBJECT6','BOX_OBJECT6')

	//--------------------------------------------------------------------
	// OtherObject Menu de Botões
	//--------------------------------------------------------------------
	oView:AddOtherObject('OTHEROBJECT7',{|o| STIPnlAcoes(o) },,)
	oView:CreateHorizontalBox( 'BOX_OBJECT7', 100, 'BOX4')
	oView:SetOwnerView('OTHEROBJECT7','BOX_OBJECT7')

//--------------------------------------------------------------------
// Área do grid
//--------------------------------------------------------------------
oView:CreateVerticalBox( 'BOX5', 50, 'BOX3')

	oView:AddOtherObject('OTHEROBJECT9',{|o| SDTIDetalh(o) },,)
	oView:SetOwnerView('OTHEROBJECT9','BOX5')

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} StructCupomVirtual
Estrutura ModelGrid do Cupom Virtual

@param
@author  Varejo
@version P11.8
@since   29/03/2012
@return
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function StructCupomVirtual()

Local oStruct	:= FWFormModelStruct():New()	//Estrutura

oStruct:AddTable( "SL2" , { "L2_FILIAL" } , "Itens" )

oStruct:AddField(                           	;
                     "Item"  		   		,	; // [01] Titulo do campo
                     "Item"  		   		,	; // [02] Desc do campo
                     "L2_ITEM" 	 			,	; // [03] Id do Field
                     "C"              		,	; // [04] Tipo do campo
                     TamSX3("L2_ITEM")[1]	,	; // [05] Tamanho do campo
                     0                		, 	; // [06] Decimal do campo
                     Nil             		,	; // [07] Code-block de validacao do campo
                     Nil              		,	; // [08] Code-block de validacao When do campo
                     Nil 					, 	; // [09] Lista de valores permitido do campo
                     Nil 					, 	; // [10] Indica se o campo tem preenchimento obrigatorio
                     Nil              		, 	; // [11] Code-block de inicializacao do campo
                     NIL             		, 	; // [12] Indica se trata-se de um campo chave
                     NIL              		,  	; // [13] Indica se o campo pode receber valor em uma operacao de update.
               		 						,	) // [14] Indica se o campo e virtual

               							   		               							   		

oStruct:AddField(                           	;
                     "Cod."	   				,	; // [01] Titulo do campo
                     "Cod."	   				,	; // [02] Desc do campo
                     "L2_PRODUTO" 	 		,	; // [03] Id do Field
                     "C"              		,	; // [04] Tipo¤ do campo
                     TamSX3("L2_PRODUTO")[1],	; // [05] Tamanho do campo 
                     0                		, 	; // [06] Decimal do campo
                     Nil             		,	; // [07] Code-block de validacao do campo
                     Nil              		,	; // [08] Code-block de validacao When do campo
                     Nil 					, 	; // [09] Lista de valores permitido do campo
                     Nil 					, 	; // [10] Indica se o campo tem preenchimento obrigatorio
                     Nil              		, 	; // [11] Code-block de inicializacao do campo
                     NIL             		, 	; // [12] Indica se trata-se de um campo chave
                     NIL              		,  	; // [13] Indica se o campo pode receber valor em uma operacao de update.
               		 						,	) // [14] Indica se o campo e virtual


oStruct:AddField(                           	;
                     "Descrição"	   		,	; // [01] Titulo do campo
                     "Descrição"	   		,	; // [02] Desc do campo
                     "L2_DESCRI" 	 		,	; // [03] Id do Field
                     "C"              		,	; // [04] Tipo do campo
                     TamSX3("L2_DESCRI")[1] + 10,	; // [05] Tamanho do campo
                     0                		, 	; // [06] Decimal do? campo
                     Nil             		,	; // [07] Code-block de validacao do campo
                     Nil              		,	; // [08] Code-block de validacao When do campo
                     Nil 					, 	; // [09] Lista de valores permitido do campo
                     Nil 					, 	; // [10] Indica se o campo tem preenchimento obrigatorio
                     Nil              		, 	; // [11] Code-block de inicializacao do campo
                     NIL             		, 	; // [12] Indica se trata-se de um campo chave
                     NIL              		,  	; // [13] Indica se o campo pode receber valor em uma operacao de update.
               							   		) // [14] Indica se o campo e virtual

oStruct:AddField(                           	;
                     "Preço Un."	 		,	; // [01] Titulo do campo
                     "Preço Un."	   		,	; // [02] Desc do campo
                     "L2_VRUNIT" 	 		,	; // [03] Id do Field
                     "N"              		,	; // [04] Tipo do campo
                     TamSX3("L2_VRUNIT")[1],	; // [05] Tamanho do campo
                     2						, 	; // [06] Decimal do campo
                     Nil             		,	; // [07] Code-block de validacao do campo
                     Nil              		,	; // [08] Code-block de validacao When do campo
                     Nil 					, 	; // [09] Lista de valores permitido do campo
                     Nil 					, 	; // [10] Indica se o campo tem preenchimento obrigatorio
                     Nil              		, 	; // [11] Code-block de inicializacao do campo
                     NIL             		, 	; // [12] Indica se trata-se de um campo chave
                     NIL              		,  	; // [13] Indica se o campo pode receber valor em uma operacao de update.
               							   		) // [14] Indica se o campo e virtual

oStruct:AddField(                           	;
                     "Qtd"	 				,	; // [01] Titulo do campo
                     "Qtd"	   				,	; // [02] Desc do campo
                     "L2_QUANT" 	 		,	; // [03] Id do Field
                     "N"              		,	; // [04] Tipo do campo
                     TamSX3("L2_QUANT")[1],	; // [05] Tamanho do campo
                     2						, 	; // [06] Decimal do campo
                     Nil             		,	; // [07] Code-block de validacao do campo
                     Nil              		,	; // [08] Code-block de validacao When do campo
                     Nil 					, 	; // [09] Lista de valores permitido do campo
                     Nil 					, 	; // [10] Indica se o campo tem preenchimento obrigatorio
                     Nil              		, 	; // [11] Code-block de inicializacao do campo
                     NIL             		, 	; // [12] Indica se trata-se de um campo chave
                     NIL              		,  	; // [13] Indica se o campo pode receber valor em uma operacao de update.
               							   		) // [14] Indica se o campo e virtual
oStruct:AddField(                           	;
                     "Un. Medida" 			,	; // [01] Titulo do campo
                     "Un. Medida"   		,	; // [02] Desc do campo
                     "L2_UM" 	 			,	; // [03] Id do Field
                     "C"              		,	; // [04] Tipo d?o campo
                     TamSX3("L2_UM")[1]	,	; // [05] Tamanho do campo
                     0						,	; // [06] Decimal do campo
                     Nil             		,	; // [07] Code-block de validacao do campo
                     Nil              		,	; // [08] Code-block de validacao When do campo
                     Nil 					, 	; // [09] Lista de valores permitido do campo
                     Nil 					, 	; // [10] Indica se o campo tem preenchimento obrigatorio
                     Nil              		, 	; // [11] Code-block de inicializacao do campo
                     NIL             		, 	; // [12] Indica se trata-se de um campo chave
                     NIL              		,  	; // [13] Indica se o campo pode receber valor em uma operacao de update.
               							   		) // [14] Indica se o campo e virtual



oStruct:AddField(                           	;
                     "Desconto"				,	; // [01] Titulo do campo
                     "Desconto"		   		,	; // [02] Desc do campo
                     "L2_VALDESC" 	 		,	; // [03] Id do Field
                     "N"              		,	; // [04] Tipo do campo
                     TamSX3("L2_VALDESC")[1],	; // [05] Tamanho do campo
                     2						,	; // [06] Decimal do campo
                     Nil             		,	; // [07] Code-block de validacao do campo
                     Nil              		,	; // [08] Code-block de validacao When do campo
                     Nil 					, 	; // [09] Lista de valores permitido do campo
                     Nil 					, 	; // [10] Indica se o campo tem preenchimento obrigatorio
                     Nil              		, 	; // [11] Code-block de inicializacao do campo
                     NIL             		, 	; // [12] Indica se trata-se de um campo chave
                     NIL              		,  	; // [13] Indica se o campo pode receber valor em uma operacao de update.
               							   		) // [14] Indica se o campo e virtual

oStruct:AddField(                           	;
                     "Valor" 				,	; // [01] Titulo do campo
                     "Valor"   				,	; // [02] Desc do campo
                     "L2_VLRITEM" 	 		,	; // [03] Id do Field
                     "N"              		,	; // [04] Tipo d?o campo
                     TamSX3("L2_VLRITEM")[1],	; // [05] Tamanho do campo
                     2						,	; // [06] Decimal do campo
                     Nil             		,	; // [07] Code-block de validacao do campo
                     Nil              		,	; // [08] Code-block de validacao When do campo
                     Nil 					, 	; // [09] Lista de valores permitido do campo
                     Nil 					, 	; // [10] Indica se o campo tem preenchimento obrigatorio
                     Nil              		, 	; // [11] Code-block de inicializacao do campo
                     NIL             		, 	; // [12] Indica se trata-se de um campo chave
                     NIL              		,  	; // [13] Indica se o campo pode receber valor em uma operacao de update.
               							   		) // [14] Indica se o campo e virtual



Return(oStruct)


//-------------------------------------------------------------------
/*/{Protheus.doc} StructGridView
Estrutura da view

@param
@author  Varejo
@version P11.8
@since   25/04/2013
@return
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function StructGridView()

Local oStruct 		:= FWFormViewStruct():New()	// Estrutura
Local oPanelMVC		:= STIGetPanel()				// Objeto MVC
Local aPosicao := {}
Local nPos
Local nI
Local aBackup := {}

oStruct:AddField(                           		;
                     "L2_ITEM" 		  		,	; // [01] cIdField		ID do Field
                     "0"  		   				,	; // [02] cOrdem			Ordem do campo
                     "Item"		 				,	; // [03] cTitulo			Título do campo
                     "Item"	     		   		,	; // [04] cDescric		Descrição completa do campo
                     NIL				  		,	; // [05] aHelp			Array com o help dos campos
                     "C"		       			, 	; // [06] cType			Tipo
                     Nil             			,	; // [07] cPicture		Picture do Campo
                     Nil               	 	  	,	; // [08] bPictVar		Bloco de Picture var
                     Nil 						, 	; // [09] cLookup			Chave para ser usado no Looup
                     .F. 						, 	; // [10] lCanChange		Lógico dizendo se o campo pode ser alterado
                     Nil              			, 	; // [11] cFolder			Id da folder onde o Field está
                     NIL             			, 	; // [12] cGroup			Id do Group onde o field está
                     NIL             			, 	; // [13] aCaomboValues	Array com os valores do combo
                     NIL             			, 	; // [14] nMaxLenCombo	Tamanho máximo da maior opção do combo
                     NIL             			, 	; // [15] cIniBrow		Inicializador do Browse
                     NIL             			, 	; // [16] lVirtual		Indica se o campo é Virtual
                     NIL             			, 	; // [17] cPictVar		Picture Variável
                     NIL             	 		,	; // [18] lInsertLine	Indica pulo de linha após o campo
                     (oPanelMVC:nWidth / 2) * 0.12) // [19] nWidth Indica a largura fixa da coluna do grid

If STFGetCfg("lPafEcf") .AND. lHomolPaf
	oStruct:AddField(                           		;
	                     "L2_PRODUTO"	   			,	; // [01] cIdField		ID do Field
	                     "1"  		   				,	; // [02] cOrdem			Ordem do campo
	                     "Cod." 					,	; // [03] cTitulo			Título do campo
	                     "Cod."  				   	,	; // [04] cDescric		Descrição completa do campo
	                     NIL					  		,	; // [05] aHelp			Array com o help dos campos
	                     "C"		       			, 	; // [06] cType			Tipo
	                     Nil             			,	; // [07] cPicture		Picture do Campo
	                     Nil               	   	,	; // [08] bPictVar		Bloco de Picture var
	                     Nil 						, 	; // [09] cLookup			Chave para ser usado no Looup
	                     .F. 						, 	; // [10] lCanChange		Lógico dizendo se o campo pode ser alterado
	                     Nil              			, 	; // [11] cFolder			Id da folder onde o Field está
	                     NIL             			, 	; // [12] cGroup			Id do Group onde o field está
	                     NIL             			, 	; // [13] aCaomboValues	Array com os valores do combo
	                     NIL             			, 	; // [14] nMaxLenCombo	Tamanho máximo da maior opção do combo
	                     NIL             			, 	; // [15] cIniBrow		Inicializador do Browse
	                     NIL             			, 	; // [16] lVirtual		Indica se o campo é Virtual
	                     NIL             			, 	; // [17] cPictVar		Picture Variável
	                     NIL             	 		,	; // [18] lInsertLine	Indica pulo de linha após o campo
	                     (oPanelMVC:nWidth / 2) * 0.15) // [19] nWidth Indica a largura fixa da coluna do grid
EndIf

oStruct:AddField(                           		;
                     "L2_DESCRI"	   			,	; // [01] cIdField		ID do Field
                     "2"  		   				,	; // [02] cOrdem			Ordem do campo
                     "Descrição" 				,	; // [03] cTitulo			Título do campo
                     "Descrição"  		   		,	; // [04] cDescric		Descrição completa do campo
                     NIL					  		,	; // [05] aHelp			Array com o help dos campos
                     "C"		       			, 	; // [06] cType			Tipo
                     Nil             			,	; // [07] cPicture		Picture do Campo
                     Nil               	   	,	; // [08] bPictVar		Bloco de Picture var
                     Nil 						, 	; // [09] cLookup			Chave para ser usado no Looup
                     .F. 						, 	; // [10] lCanChange		Lógico dizendo se o campo pode ser alterado
                     Nil              			, 	; // [11] cFolder			Id da folder onde o Field está
                     NIL             			, 	; // [12] cGroup			Id do Group onde o field está
                     NIL             			, 	; // [13] aCaomboValues	Array com os valores do combo
                     NIL             			, 	; // [14] nMaxLenCombo	Tamanho máximo da maior opção do combo
                     NIL             			, 	; // [15] cIniBrow		Inicializador do Browse
                     NIL             			, 	; // [16] lVirtual		Indica se o campo é Virtual
                     NIL             			, 	; // [17] cPictVar		Picture Variável
                     NIL             	 		,	; // [18] lInsertLine	Indica pulo de linha após o campo
                     (oPanelMVC:nWidth / 2) * 0.48) // [19] nWidth Indica a largura fixa da coluna do grid

oStruct:AddField(                           		;
                     "L2_VRUNIT"	   			,	; // [01] cIdField		ID do Field
                     "3"  		   				,	; // [02] cOrdem			Ordem do campo
                     "Preço Un."	 				,	; // [03] cTitulo			Título do campo
                     "Preço"	  		   		,	; // [04] cDescric		Descrição completa do campo
                     NIL					  		,	; // [05] aHelp			Array com o help dos campos
                     "N"		       			, 	; // [06] cType			Tipo
                     PesqPict("SL2","L2_VRUNIT"),	; // [07] cPicture		Picture do Campo
                     Nil               	   	,	; // [08] bPictVar		Bloco de Picture var
                     Nil 						, 	; // [09] cLookup			Chave para ser usado no Looup
                     .F. 						, 	; // [10] lCanChange		Lógico dizendo se o campo pode ser alterado
                     Nil              			, 	; // [11] cFolder			Id da folder onde o Field está
                     NIL             			, 	; // [12] cGroup			Id do Group onde o field está
                     NIL             			, 	; // [13] aCaomboValues	Array com os valores do combo
                     NIL             			, 	; // [14] nMaxLenCombo	Tamanho máximo da maior opção do combo
                     NIL             			, 	; // [15] cIniBrow		Inicializador do Browse
                     NIL             			, 	; // [16] lVirtual		Indica se o campo é Virtual
                     NIL             			, 	; // [17] cPictVar		Picture Variável
                     NIL             	 		,	; // [18] lInsertLine	Indica pulo de linha após o campo
                     (oPanelMVC:nWidth / 2) * 0.34) // [19] nWidth Indica a largura fixa da coluna do grid

oStruct:AddField(                           		;
                     "L2_QUANT"		   			,	; // [01] cIdField		ID do Field
                     "4"  		   				,	; // [02] cOrdem			Ordem do campo
                     "Qtd"	 				,	; // [03] cTitulo			Título do campo
                     "Qtd"	  		   		,	; // [04] cDescric		Descrição completa do campo
                     NIL					  		,	; // [05] aHelp			Array com o help dos campos
                     "N"		       			, 	; // [06] cType			Tipo
                     PesqPictQt("L2_QUANT")	,	; // [07] cPicture		Picture do Campo
                     Nil               	   	,	; // [08] bPictVar		Bloco de Picture var
                     Nil 						, 	; // [09] cLookup			Chave para ser usado no Looup
                     .F. 						, 	; // [10] lCanChange		Lógico dizendo se o campo pode ser alterado
                     Nil              			, 	; // [11] cFolder			Id da folder onde o Field está
                     NIL             			, 	; // [12] cGroup			Id do Group onde o field está
                     NIL             			, 	; // [13] aCaomboValues	Array com os valores do combo
                     NIL             			, 	; // [14] nMaxLenCombo	Tamanho máximo da maior opção do combo
                     NIL             			, 	; // [15] cIniBrow		Inicializador do Browse
                     NIL             			, 	; // [16] lVirtual		Indica se o campo é Virtual
                     NIL             			, 	; // [17] cPictVar		Picture Variável
                     NIL             	 		,	; // [18] lInsertLine	Indica pulo de linha após o campo
                     (oPanelMVC:nWidth / 2) * 0.20) // [19] nWidth Indica a largura fixa da coluna do grid

If STFGetCfg("lPafEcf") .AND. lHomolPaf 
	oStruct:AddField(                           		;
	                     "L2_UM"		   		,	; // [01] cIdField		ID do Field
	                     "5"  		   				,	; // [02] cOrdem			Ordem do campo
	                     "Unid." 					,	; // [03] cTitulo			Título do campo
	                     "Unid."		  		   	,	; // [04] cDescric		Descrição completa do campo
	                     NIL					  		,	; // [05] aHelp			Array com o help dos campos
	                     "C"		       			, 	; // [06] cType			Tipo
	                     PesqPict("SL2","L2_UM"),	; // [07] cPicture		Picture do Campo
	                     Nil               	   	,	; // [08] bPictVar		Bloco de Picture var
	                     Nil 						, 	; // [09] cLookup			Chave para ser usado no Looup
	                     .F. 						, 	; // [10] lCanChange		Lógico dizendo se o campo pode ser alterado
	                     Nil              			, 	; // [11] cFolder			Id da folder onde o Field está
	                     NIL             			, 	; // [12] cGroup			Id do Group onde o field está
	                     NIL             			, 	; // [13] aCaomboValues	Array com os valores do combo
	                     NIL             			, 	; // [14] nMaxLenCombo	Tamanho máximo da maior opção do combo
	                     NIL             			, 	; // [15] cIniBrow		Inicializador do Browse
	                     NIL             			, 	; // [16] lVirtual		Indica se o campo é Virtual
	                     NIL             			, 	; // [17] cPictVar		Picture Variável
	                     NIL             	 		,	; // [18] lInsertLine	Indica pulo de linha após o campo
	                     (oPanelMVC:nWidth / 2) * 0.13) // [19] nWidth Indica a largura fixa da coluna do grid
EndIf	

oStruct:AddField(                           		;
                     "L2_VALDESC"		   		,	; // [01] cIdField		ID do Field
                     "6"  		   				,	; // [02] cOrdem			Ordem do campo
                     "Desc."	 				,	; // [03] cTitulo			Título do campo
                     "Desc."	  		   		,	; // [04] cDescric		Descrição completa do campo
                     NIL					  		,	; // [05] aHelp			Array com o help dos campos
                     "N"		       			, 	; // [06] cType			Tipo
                     PesqPict("SL2","L2_VALDESC"),	; // [07] cPicture		Picture do Campo
                     Nil               	   	,	; // [08] bPictVar		Bloco de Picture var
                     Nil 						, 	; // [09] cLookup			Chave para ser usado no Looup
                     .F. 						, 	; // [10] lCanChange		Lógico dizendo se o campo pode ser alterado
                     Nil              			, 	; // [11] cFolder			Id da folder onde o Field está
                     NIL             			, 	; // [12] cGroup			Id do Group onde o field está
                     NIL             			, 	; // [13] aCaomboValues	Array com os valores do combo
                     NIL             			, 	; // [14] nMaxLenCombo	Tamanho máximo da maior opção do combo
                     NIL             			, 	; // [15] cIniBrow		Inicializador do Browse
                     NIL             			, 	; // [16] lVirtual		Indica se o campo é Virtual
                     NIL             			, 	; // [17] cPictVar		Picture Variável
                     NIL             	 		,	; // [18] lInsertLine	Indica pulo de linha após o campo
                     (oPanelMVC:nWidth / 2) * 0.33) // [19] nWidth Indica a largura fixa da coluna do grid

oStruct:AddField(                           		;
                     "L2_VLRITEM"		   		,	; // [01] cIdField		ID do Field
                     "7"  		   				,	; // [02] cOrdem			Ordem do campo
                     "Valor" 					,	; // [03] cTitulo			Título do campo
                     "Valor"		  		   	,	; // [04] cDescric		Descrição completa do campo
                     NIL					  		,	; // [05] aHelp			Array com o help dos campos
                     "N"		       			, 	; // [06] cType			Tipo
                     PesqPict("SL2","L2_VLRITEM"),	; // [07] cPicture		Picture do Campo
                     Nil               	   	,	; // [08] bPictVar		Bloco de Picture var
                     Nil 						, 	; // [09] cLookup			Chave para ser usado no Looup
                     .F. 						, 	; // [10] lCanChange		Lógico dizendo se o campo pode ser alterado
                     Nil              			, 	; // [11] cFolder			Id da folder onde o Field está
                     NIL             			, 	; // [12] cGroup			Id do Group onde o field está
                     NIL             			, 	; // [13] aCaomboValues	Array com os valores do combo
                     NIL             			, 	; // [14] nMaxLenCombo	Tamanho máximo da maior opção do combo
                     NIL             			, 	; // [15] cIniBrow		Inicializador do Browse
                     NIL             			, 	; // [16] lVirtual		Indica se o campo é Virtual
                     NIL             			, 	; // [17] cPictVar		Picture Variável
                     NIL             	 		,	; // [18] lInsertLine	Indica pulo de linha após o campo
                     (oPanelMVC:nWidth / 2) * 0.32) // [19] nWidth Indica a largura fixa da coluna do grid

If ExistBlock("STCODB2")
	aBackup := oStruct:aFields
   for nI := 1 to len(oStruct:aFields)
		Aadd (aPosicao, {oStruct:aFields[nI][1], oStruct:aFields[nI][2]}  )
   Next nI
	aPosicao := ExecBlock("STCODB2",.F.,.F.,{aPosicao})
	If ValType(aPosicao) == "A" .AND. Len(aPosicao) >= 1
		for nI := 1 to len(aPosicao)
			nPos := aScan(oStruct:aFields,{|x| AllTrim(x[1]) == AllTrim(aPosicao[nI][1])})
			If nPos > 0
				oStruct:aFields[nPos][2] := aPosicao[ni][2]
			else
			   oStruct:aFields := aBackup
	    		MsgInfo("Erro no retorno do ponto de entrada STCODB2, posições incorretas" ,"Atenção") 
				Exit 
			EndIf
		Next nI
	EndIf
	
EndIf	

Return(oStruct)


//-------------------------------------------------------------------
/*/{Protheus.doc} STILogo
Exibe o logo da loja no topo da tela

@param
@author  Varejo
@version P11.8
@since   25/04/2013
@return
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function STILogo( o )

Local cCSS			:= ""										 //CSS Do logo
Local oLogo 		:= Nil    									 //Objeto de bitmap do logo principal
Local lMobile		:= STFGetCfg("lMobile", .F.)				 //Smart Client Mobile
Local oSayVDem		:= Nil 										 //Label Versao demostrativa
Local cClientDir	:= GetClientDir()							 //Caminho do diretorio do smartclient exe: "C:\totvs\bin\SmartClient\smartclient.ini"
Local lUnix 		:= IsSrvUnix()								 //Verifica se eh server linux
Local nPos 			:= Rat( IIf( lUnix, "/", "\" ), cClientDir ) //Posicao da ultima barra

Default o := Nil
   
If !( nPos == 0 )
	cClientDir := SubStr( cClientDir, 1, nPos )
EndIf

cCSS := POSCSS( GetClassName(o), CSS_PANEL_LOGO, "FFFFFF" )

//Busca o Logo no Diretório smartclient 
If File( cClientDir + "logopos.jpg" )
	
	o:SetCSS( cCSS )
		
	oLogo := TBitmap():New( 15,10,(o:nWidth/2)-(15),(o:nHeight/2)-(20),,,.T.,O,;
	{|| FWAlertInfo( STR0053  + CRLF + ; //"Melhor Resolução para o seu Logo."
	STR0054 + AllTrim(STR((o:nWidth)-(15*2))) + " x " + STR0055 + ;//"Largura: " + "Altura: " 
	 AllTrim(STR((o:nHeight)-(20*2))) + STR0056 ) },{||},.F.,.F.,,,.F.,,.T.)//" em Pixel."
	
	oLogo:Load( Nil , cClientDir + "logopos.jpg" )


//Em versoes Mobile o logo eh alterado
ElseIf ValType(lMobile) == "L" .AND. lMobile

	@ 011,005 REPOSITORY oLogo OF O NOBORDER SIZE o:nWidth/2-7 , o:nHeight/2-15 PIXEL 
	
	//Versao demostrativa exibe label especifico
	If STFTypeOperation() == "DEMONSTRACAO"
	   
		@ 000,000 SAY oSayVDem PROMPT STR0047 SIZE o:nClientHeight/2,15 CENTER OF oLogo PIXEL //"VERSÃO EXPERIMENTAÇÃO"   		
		oSayVDem:SetCSS( POSCSS (GetClassName(oSayVDem), CSS_LABEL_TRIAL))
		oSayVDem:Align := CONTROL_ALIGN_BOTTOM
	
	EndIf
	
	//Valida nome com espacos pois em algumas versoes o Wizard add imagem com espacos
	If oLogo:ExistBmp(PADR("LOGOPOS",20))
		ShowBitmap(oLogo,PADR("LOGOPOS",20),"")
	Else
		ShowBitmap(oLogo,"LOGOPOS","")	
	EndIf
		
	oLogo:lStretch := .T.
	
	o:SetCSS( cCSS )

Else

	o:SetCSS( cCSS )	

	@ 001,010 REPOSITORY oLogo OF O NOBORDER SIZE o:nWidth/2-20,o:nHeight/2-1 PIXEL
	//----------------------------------------------------------------------
	// Alteração feita para reaplicar o estilo pois a partir do binário
	// 131227A o CSS é aplicado no objeto ADVPL e não mais no objeto Qt.
	// Com isso o oLogo não consegue mais herdar o CSS do container.
	//----------------------------------------------------------------------
	oLogo:SetCSS( StrTran( cCSS, "TPanelCss", "TBitmap" ) )

	ShowBitmap(oLogo,"LOGOPOS","")	
		
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} STIPnlAcoes
Cria os box's das acoes com usuario

@param
@author  Varejo
@version P11.8
@since   25/04/2013
@return
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function STIPnlAcoes( o )

Local oTop			//Objeto de cabecalho
Local oContent	//Objeto de interacao com usuario

o:SetCSS( POSCSS (GetClassName(o), CSS_PANEL_CONTEXT ))

oArea := o

@ 000,000 BITMAP oTop RESOURCE "x.png" NOBORDER SIZE o:nWidth/2,070 OF o ADJUST PIXEL
oTop:SetCSS( POSCSS (GetClassName(oTop), CSS_PANEL_OPTION_TOP ))
oTop:ReadClientCoors(.T.,.T.)

STIMenuBtn(oTop)

oContent := tPanel():New(oTop:nHeight/2, 000, "", o,,,,,, o:nWidth/2, (o:nHeight-oTop:nHeight)/2)
oContent:SetCSS( POSCSS (GetClassName(oContent), CSS_PANEL_CONTENT ))
oContent:ReadClientCoors(.T.,.T.)
oContent:bLostFocus := {|| oBtnConfirm:SetFocus() } // Tratamento para não perder o foco do Cancelar VENDA
STIPnlCont(oContent)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} STIMenuBtn
Painel dos botoes

@param
@author  Varejo
@version P11.8
@since   25/04/2013
@return
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function STIMenuBtn( o )

Local nTop    	:= 10 	//Altura dos botoes
Local nLeft		:= 10 	//Horizontal dos botoes
Local nMargin 	:= 05	//Tamanho horizontal
Local nWidth				//Lagura dos botoes
Local nHeight				//Altura dos botoes
Local nX			:= 1	//Posicao horizontal dos botoes
Local nY			:= 1	//Posicao vertical dos botoes
Local lMobile		:= STFGetCfg( "lMobile" , .F. )
Local lExibAtalho	:= .T. //Valida se Exibe atalhos ex: F2, F5 etc  em versoes mobile nao exibe
Local lAtvCnsPro	:= SuperGetMV("MV_LJTPSCH", .F., 0) <> 2 //0= legado; 1= codigo de barras; 2= bloqueia


lMobile 		:= ValType(lMobile) == "L" .AND. lMobile
lExibAtalho	:= !lMobile

nWidth := o:nWidth-35
nWidth := (nWidth/2-nMargin*2)/3
nHeight := o:nHeight-30
nHeight := (nHeight/2-nMargin)/2

/* Registro de item */
@ nTop+(nX-1)*(nHeight+nMargin), nLeft+(nY-1)*(nWidth+nMargin) BUTTON oBtnRegItem PROMPT IIf(lExibAtalho,STR0015,STR0037) SIZE nWidth,nHeight ACTION {||STIRegItemInterface() } WHEN {|| lBtnActive } OF o PIXEL // "(F3) Reg. de item" ### "Registro de Item"
oBtnRegItem:SetCSS( POSCSS (GetClassName(oBtnRegItem), CSS_BTN_NORMAL )) 
oBtnRegItem:LCANGOTFOCUS := .F. 
nY := 2

/* Cliente */
@ nTop+(nX-1)*(nHeight+nMargin), nLeft+(nY-1)*(nWidth+nMargin) BUTTON oBtnClient PROMPT IIf(lExibAtalho,STR0016,STR0038) SIZE nWidth,nHeight ACTION {|| STICustomerSelection()} WHEN {|| IIF(STDPBLength("SL2") == 0, lBtnActive, .F. ) } OF o PIXEL
oBtnClient:SetCSS( POSCSS (GetClassName(oBtnClient), CSS_BTN_NORMAL ))
oBtnClient:LCANGOTFOCUS := .F.
nY := 3

/* Cancelamento de item */
@ nTop+(nX-1)*(nHeight+nMargin), nLeft+(nY-1)*(nWidth+nMargin) BUTTON oBtnCancItem PROMPT IIf(lExibAtalho,STR0017,STR0039) SIZE nWidth,nHeight ACTION {|| STICancelItem() } WHEN {|| IIF(STDPBLength("SL2") == 0, .F., lBtnActive) } OF o PIXEL
oBtnCancItem:SetCSS( POSCSS (GetClassName(oBtnCancItem), CSS_BTN_NORMAL )) 
oBtnCancItem:LCANGOTFOCUS := .F. 
nX := 2
nY := 1

/* Orçamento Ou Vendedor em versao mobile*/
@ nTop+(nX-1)*(nHeight+nMargin), nLeft+(nY-1)*(nWidth+nMargin) BUTTON oBtnOrc PROMPT IIf(lExibAtalho,STR0018,STR0040) SIZE nWidth,nHeight ACTION {|| IIf(lMobile,STISalesmanSelection(),STIImportSale()) } WHEN {|| lBtnActive } OF o PIXEL
oBtnOrc:SetCSS( POSCSS (GetClassName(oBtnOrc), CSS_BTN_NORMAL )) 
oBtnOrc:LCANGOTFOCUS := .F.
nY := 2

/* Desconto na venda */
@ nTop+(nX-1)*(nHeight+nMargin), nLeft+(nY-1)*(nWidth+nMargin) BUTTON oBtnDesc PROMPT IIf(lExibAtalho,STR0019,STR0041) SIZE nWidth,nHeight ACTION { || STIDiscountTotal() } WHEN {|| IIF(STDPBLength("SL2") == 0, .F., lBtnActive) } OF o PIXEL
oBtnDesc:SetCSS( POSCSS (GetClassName(oBtnDesc), CSS_BTN_NORMAL )) 
oBtnDesc:LCANGOTFOCUS := .F. 
nY := 3

/* Consulta de Produtos */
@ nTop+(nX-1)*(nHeight+nMargin), nLeft+(nY-1)*(nWidth+nMargin) BUTTON oBtnConProd PROMPT IIf(lExibAtalho,STR0020,STR0042) SIZE nWidth,nHeight ACTION { || STIProdSearch() } WHEN {|| (lBtnActive .AND. lAtvCnsPro) } OF o PIXEL
oBtnConProd:SetCSS( POSCSS (GetClassName(oBtnConProd), CSS_BTN_NORMAL )) 
oBtnConProd:LCANGOTFOCUS := .F.  

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} STIPnlCont
Abre a primeira tela de abertura de caixa

@param
@author  Varejo
@version P11.8
@since   25/04/2013
@return
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function STIPnlCont( oContent )

oContent:SetCSS( POSCSS (GetClassName(oContent), CSS_PANEL_CONTEXT )) 
STICreateObjects(oContent)

/* Abre a View de abertura de caixa */

//Se for somente menu fiscal nao abre a rotina inicial
If !STFGetCfg("lOnlyMenuFiscal")
	STIOpenCash()
EndIf


Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} SDTIDetalh
Criacao dos box's de detalhes, cabecalho, itens e rodape

@param
@author  Varejo
@version P11.8
@since   25/04/2013
@return
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function SDTIDetalh( o )

Local oTop			:= Nil //Objeto para cabecalho
Local oContent	:= Nil //Objeto para itens
Local oBottom		:= Nil //Objeto para rodape

oViewRight := o

@ 000,000 BITMAP oTop RESOURCE "x.png" NOBORDER SIZE 000,055 OF o ADJUST PIXEL
oTop:Align := CONTROL_ALIGN_TOP
oTop:SetCSS( POSCSS (GetClassName(oTop), CSS_PANEL_HEADER )) 
oTop:ReadClientCoors(.T.,.T.)

STICab( oTop )

@ 000,000 BITMAP oBottom RESOURCE "x.png" NOBORDER SIZE 000,055 OF o ADJUST PIXEL
oBottom:Align := CONTROL_ALIGN_BOTTOM
oBottom:SetCSS( POSCSS (GetClassName(oBottom), CSS_PANEL_FOOTER )) 
oBottom:ReadClientCoors(.T.,.T.)

STIRodape( oBottom )

@ 000,000 BITMAP oContent RESOURCE "x.png" NOBORDER SIZE 000,000 OF o ADJUST PIXEL
oContent:Align := CONTROL_ALIGN_ALLCLIENT
oContent:ReadClientCoors(.T.,.T.)

STIItens( oContent )

@ (o:nClientHeight/2)-50,4 BITMAP oSemaforo RESOURCE "FRTOFFLINE" NOBORDER SIZE 16,16 OF o ADJUST PIXEL
oSemaforo:ReadClientCoors(.T.,.T.)

STILoadSem() 
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} STICab
Cabeçalho da tela

@param
@author  Varejo
@version P11.8
@since   25/04/2013
@return
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function STICab( o )

Local nTop    := 10	//Altura do cabeçalho
Local nLeft	:= 10	//Horizontal do cabeçalho
Local oSay				//Objeto label
Local cNomeEmp		:= 	SM0->M0_NOMECOM		 // Nome da Empresa
Local cEndEmp		:= 	SM0->M0_ENDENT		// Endereço Empresa


@ nTop,nLeft SAY oSay PROMPT "<b>" + cNomeEmp + "</b><br>" + cEndEmp + "<br>" SIZE o:nWidth/2-35,40 CENTER OF o PIXEL HTML
oSay:SetCSS( POSCSS (GetClassName(oSay), CSS_LABEL_HEADER )) 
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} STIItens
Criação do grid dos itens

@param
@author  Varejo
@version P11.8
@since   25/04/2013
@return
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function STIItens( o )

Local oContent	//Conteudo do css
Local oStruGrd	//Estrutura da grid
Local lMobile 	:= STFGetCfg("lMobile", .F.)		//Smart Client Mobile
Local lExibScroll	:= .T.	//Exibe scroll na Grid
Local oCodProd	:= Iif(FindFunction("STIGetCodP"),STIGetCodP(),NIL) //Retorna o GET de digitacao do produto para poder dar foco no objeto na recuperacao da venda  

lMobile := ValType(lMobile) == "L" .AND. lMobile

lExibScroll := !lMobile

oContent := POSBrwContainer(o)

oViewDetail := FWFormView():New(oView)
oViewDetail:SetOwner(oContent)
oViewDetail:SetModel(oView:oModel)
oViewDetail:setUseCursor(.F.)
oViewDetail:SetOperation(oView:GetOperation())

// Grid com Paginação em Botoes
If STIShowPagGrid()
	oViewDetail:CreateHorizontalBox( 'BOX1', 90)
	oViewDetail:CreateHorizontalBox( 'BOX2', 10)
Else
	//Grid Padrao
	oViewDetail:CreateHorizontalBox( 'BOX1', 100)
EndIf

oStruGrd := StructGridView()
oViewDetail:AddGrid( 'VIEW_CUPOM' , oStruGrd, 'CUP_GRID' )
oViewDetail:SetOwnerView("VIEW_CUPOM","BOX1")
oViewDetail:SetViewProperty("VIEW_CUPOM","SETCSS",{POSCSS("TGRID", CSS_BROWSE)})
oViewDetail:SetViewProperty("VIEW_CUPOM","ENABLENEWGRID")
oViewDetail:SetViewProperty("VIEW_CUPOM","GRIDVSCROLL", {lExibScroll})
oViewDetail:SetViewProperty("VIEW_CUPOM","GRIDROWHEIGHT", {40})
oViewDetail:SetViewProperty("VIEW_CUPOM","GRIDCANGOTFOCUS", {.F.})
oViewDetail:SetViewProperty("VIEW_CUPOM","GRIDDOUBLECLICK", {{||.F.}}) 
oViewDetail:SetViewProperty( "*", "GRIDNOORDER")

// Grid com Paginação em Botoes
If STIShowPagGrid()
	oViewDetail:AddOtherObject('PAGPDV',  {|oPanel| STIObjPag(oPanel)} )
	oViewDetail:SetOwnerView("PAGPDV","BOX2")
	
	//Nao Exibe linhas na Grid
	If GetBuild() >= "7.00.131227A-20140123"
		oViewDetail:GetViewObj("VIEW_CUPOM")[3]:OBrowse:Browse():lShowGrid := .F.
	EndIf
EndIf	

oViewDetail:SetAfterViewActivate( {|oViewDetail| DesalbitaColChange(oViewDetail)})

oViewDetail:Activate()

If STBIsRecovered()
	STIGridCupRefresh()
	STIBtnActivate()
	STFMessage(ProcName(),"STOP",STR0021)  //"Venda recuperada com sucesso!"
	STFShowMessage(ProcName())

	//Apos a recuperacao da venda, o foco da get de produto era perdida, entao eh forcado o foco abaixo 
	If oCodProd <> NIL
		oCodProd:SetFocus()
	EndIf
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} STIRodape
Criação das barra dos totalizadores

@param
@author  Varejo
@version P11.8
@since   25/04/2013
@return
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function STIRodape( o )

Local nLeft := 020								// Posição esquerda
Local nTop := 001								// Posição superior
Local oGet										// Objeto Get
Local oSay										// Objeto Say
Local oTotal  	:= STFGetTot() 					//Recebe o Objeto totalizador
Local lMobile	:= STFGetCfg("lMobile" , .F. ) //PDV em Versao Mobile 
	
lMobile := ValType(lMobile) == "L" .AND. lMobile

@ nTop+2,nLeft SAY oSay PROMPT STR0022 SIZE 038,010 RIGHT OF o PIXEL HTML   //"Volumes:"
oSay:SetCSS( POSCSS (GetClassName(oSay), IIf(lMobile,CSS_LABEL_SUBTITLE,CSS_LABEL_NORMAL))) 

@ nTop,nLeft+oSay:nWidth/1.8 GET oGetQtde VAR STIQtdItens() SIZE 100,010 OF o PIXEL
oGetQtde:SetCSS( POSCSS (GetClassName(oGetQtde), IIf(lMobile,CSS_GET_TOTAL,CSS_GET_NORMAL)))  
oGetQtde:lActive := .F.

nTop += 11

@ nTop+2,nLeft SAY oSay PROMPT STR0023 SIZE 037,010 RIGHT OF o PIXEL HTML   //"Subtotal:"
oSay:SetCSS( POSCSS (GetClassName(oSay), IIf(lMobile,CSS_LABEL_SUBTITLE,CSS_LABEL_NORMAL)))

@ nTop,nLeft+oSay:nWidth/1.73 GET oGetSubTot VAR AllTrim(Str(oTotal:GetValue("L1_VALMERC"),12,2)) SIZE 100,010 OF o PIXEL
oGetSubTot:SetCSS( POSCSS (GetClassName(oGetSubTot), IIf(lMobile,CSS_GET_TOTAL,CSS_GET_NORMAL))) 
oGetSubTot:lActive := .F.

nTop += 11

@ nTop+2,nLeft SAY oSay PROMPT STR0024 SIZE 042,010 RIGHT OF o PIXEL HTML   //"Desconto:"
oSay:SetCSS( POSCSS (GetClassName(oSay), IIf(lMobile,CSS_LABEL_SUBTITLE,CSS_LABEL_NORMAL))) 

@ nTop,nLeft+oSay:nWidth/2 GET oGetDiscount VAR AllTrim(Str(oTotal:GetValue("L1_DESCONT"),12,2)) SIZE 100,010 OF o PIXEL
oGetDiscount:SetCSS( POSCSS (GetClassName(oGetDiscount), IIf(lMobile,CSS_GET_TOTAL,CSS_GET_NORMAL))) 
oGetDiscount:lActive := .F.

If FindFunction("STIQtdBrindes")
	nTop += 11
	@ nTop+2,nLeft SAY oSay PROMPT "Brinde(s):" SIZE 040,010 RIGHT OF o PIXEL HTML   //"Brinde(s):"  Leandro
	oSay:SetCSS( POSCSS (GetClassName(oSay), IIf(lMobile,CSS_LABEL_SUBTITLE,CSS_LABEL_NORMAL)))
	
	@ nTop,nLeft+oSay:nWidth/1.9 GET oGetQtdBrinde VAR STIQtdBrindes() SIZE 100,010 OF o PIXEL
	oGetQtdBrinde:SetCSS( POSCSS (GetClassName(oGetQtdBrinde), IIf(lMobile,CSS_GET_TOTAL,CSS_GET_NORMAL)))
	oGetQtdBrinde:lActive := .F.
EndIf

nTop := 006

@ nTop,o:nWidth/2-40 SAY oSay PROMPT STR0025 SIZE o:nWidth/2-35,40 OF o PIXEL HTML   //"Total"
oSay:SetCSS( POSCSS (GetClassName(oSay), IIf(lMobile,CSS_LABEL_SUBTITLE,CSS_LABEL_NORMAL))) //rafael

nTop += 10

@ nTop,o:nWidth/2-120 SAY oSayTotal PROMPT AllTrim(Str(oTotal:GetValue("L1_VLRTOT"),12,2)) SIZE 100,40 RIGHT OF o PIXEL HTML
oSayTotal:SetCSS( POSCSS (GetClassName(oSayTotal), CSS_LABEL_TOTAL)) 

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} STIGetDlg
Retorno do objeto oDlg

@param
@author  Varejo
@version P11.8
@since   25/04/2013
@return  oDlg - Objeto principal da tela
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STIGetDlg()
Return oArea

//-------------------------------------------------------------------
/*{Protheus.doc} STIGetRDlg
Retorno do objeto oViewRight

@param
@author  Varejo
@version P11.8
@since   25/04/2013
@return  oDlg - Objeto principal da tela
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STIGetRDlg()
Return oViewRight

//-------------------------------------------------------------------
/*{Protheus.doc} STIGetRDlg
Retorno do objeto oViewRight

@param
@author  Varejo
@version P11.8
@since   25/04/2013
@return  oDlg - Objeto principal da tela
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STISetRDlg()

oViewRight:FreeChildren()
SDTIDetalh(oViewRight)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} STIGetObjTela
Retorna o Objeto de Tela

@param
@author  Varejo
@version P11.8
@since   25/04/2013
@return  oPOSDesk
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STIGetObjTela()
Return oPOSDesk

//-------------------------------------------------------------------
/*/{Protheus.doc} STISetMsg
Seta mensagem de tela

@param   cMsg - Mensagem para exibicao
@author  Varejo
@version P11.8
@since   25/04/2013
@return
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STISetMsg(cMsg)

Default cMsg := ""

oPOSDesk:SetBAlert( cMsg )

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STIGridCupRefresh
Sincroniza a cesta com o grid do cupom virtual da interface

@param  
@author  Varejo
@version P11.8
@since   29/03/2012
@return
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STIGridCupRefresh(nItemDe,nItemAte)

Local oModelCesta		:= STDGPBModel()							// Model de venda
Local oModelSL2			:= oModelCesta:GetModel("SL2DETAIL")		// Model Itens Orc.
Local oModel			:= oMdlPrin									// Model principal
Local oModelCup			:= oModel:GetModel("CUP_GRID")				// Model Cup.Grid
Local oStruct			:= oModelCup:GetStruct()					// Model Estrutura
Local aFieldsCup		:= oStruct:aFields							// Objeto Estrutura Campos
Local nI				:= 0										// Contador I
Local nJ				:= 0										// Contador J
Local oGridView 		:= oViewDetail:GetViewObj("VIEW_CUPOM")[3]	// Objeto GridView
Local xValue														// Variável auxiliar

Default nItemDe			:= 1 										// Item Inicial que sera atualizado o cupom virtual da interface
Default nItemAte		:= oModelSL2:Length() 						// Item Final que sera atualizado o cupom virtual da interface

If nItemAte <= oModelSL2:Length()
	
	/* Sincroniza o Grid */
	For nI := nItemDe To nItemAte
	
		/* Posiciona */
		oModelSL2:GoLine(nI)
	
		If oModelCup:Length() < nI 
			/*Adiciona uma nova linha no modelo e no Grid*/
			oGridView:OBrowse:nAt := oGridView:OBrowse:nLen
			oModelCup:AddLine()
		Else
			oViewDetail:GoLine("CUP_GRID",nI)
			oGridView:OBrowse:nAt := nI
		EndIf 
	
		/* Sincroniza valores */
		For nJ := 1 To Len(aFieldsCup)
	
			If AllTrim(aFieldsCup[nJ][3]) == 'L2_DESCRI' .AND.  oModelSL2:IsDeleted(nI)
				xValue := SubStr(xValue + ' - CANCELADO',1,TamSX3("L2_DESCRI")[1] + 10)
			ElseIf AllTrim(aFieldsCup[nJ][3]) == 'L2_VRUNIT'
				xValue := oModelSL2:GetValue('L2_PRCTAB')
			Else
				xValue := oModelSL2:GetValue(aFieldsCup[nJ][3])		
			EndIf
			
			oModelCup:LoadValue( aFieldsCup[nJ][3] , xValue )
			oGridView:setValue(aFieldsCup[nJ][3],xValue ,nI)
	
		Next nJ
		
		/* Sincroniza deleção */
		If oModelSL2:IsDeleted(nI)
	
			oModelCup:GoLine(nI)
			oModelCup:DeleteLine( .F. , .T. )
			
		Else		
			
			oModelCup:GoLine(nI)
			If oModelCup:IsDeleted(nI)
	
				oModelCup:UnDeleteLine()
	
			EndIf		
	
		EndIf
		
	
	Next nI

EndIf

oGridView:Refresh(,.T.)

If  oModelSL2:Length() > oGridView:obrowse:obrowse:GetVisibleRows() 
	oGridView:oBrowse:gobottom()
EndIf
//Paginacao do Grid por botoes
If STIShowPagGrid()
	STIMsgPag()
EndIf	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} STIGetMdlPri
Retorna o model da cesta

@param
@author  Varejo
@version P11.8
@since   29/03/2012
@return
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STIGetMdlPri()
Return oMdlPrin

//-------------------------------------------------------------------
/*/{Protheus.doc} STICreateObjects
Cria os objetos principais da tela

@param
@author  Varejo
@version P11.8
@since   29/03/2012
@return
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STICreateObjects( oPanel )

Default oPanel		:= Nil

If oPanel <> Nil

	oPanelMVC := oPanel

	oPanel1	:= TPanel():New(00,00,"",oPanelMVC,,,,,,oPanelMVC:nWidth/2,oPanelMVC:nHeight/2)
	oPanel2	:= TPanel():New(00,00,"",oPanelMVC,,,,,,oPanelMVC:nWidth/2,oPanelMVC:nHeight/2)
	oPanel1:SetCSS( POSCSS (GetClassName(oPanel1), CSS_PANEL_CONTEXT)) 
	oPanel2:SetCSS( POSCSS (GetClassName(oPanel2), CSS_PANEL_CONTEXT)) 
EndIf

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STIGetPanel
Retorna o objeto do painel principal

@param
@author  Varejo
@version P11.8
@since   29/03/2012
@return
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STIGetPanel()
Return(oPanelMVC)

//-------------------------------------------------------------------
/*/{Protheus.doc} STIExchangePanel
Alterna os paineis do Contexto

@param   bPanel Bloco de construção do próximo panel
@author  Varejo
@version P11.8
@since   29/03/2012
@return
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STIExchangePanel( bPanel, lTtotal )
Local lItCkAct := ExistFunc("STIItCkAct") .And. STIItCkAct()

Default bPanel	:= {|| }
Default lTtotal := .F.

If SuperGetMv( "MV_LJCFSPG",,.F.) .AND. STDGPBasket("SL1","L1_VLRTOT") > 0 .AND. "STIPAYMENT" $ cLastPnlOpen 
	STFMessage(ProcName(),"NOYES",STR0057) //"Tem certeza que deseja sair e abandonar os pagamentos informados?"
	If !STFShowMessage(ProcName())
		Return Nil
	EndIf
EndIf

// -- Caso saia da tela de finalização de venda recupera os pagamentos do orçamento.
If "STIPAYMENT()" $ cLastPnlOpen .AND. STBIsImpOrc() .AND. !"STIPANDISCTOTAL()" $ Upper(GetCBSource(bPanel))
	STISetPayImp(.F.)
EndIf 

If "STIPANCONFCASH()" $ cLastPnlOpen
	STISetRDlg()
Endif 

cLastPnlOpen := Upper(GetCBSource(bPanel)) //Guarda ultimo panel chamado na troca de panels

Do Case
    Case lTtotal 
		//Nao é possivel utilizar a logica do nPanelActive = 0 ou igual 1 ou igual a 2 porque no momento de finalizar a Venda o nPanelActive é igual a 2 
		//porém quando o nPanelActive é igual 1 o sistema exibe a tela de brinde mas ocorre erro log no oPanel1 que não existe.
		// e quando o o nPanelActive é igual a 2 o sistema não exibe a tela de brinde e ocorre erro log no oPanel2 que não existe
		// por esse motivo foi criado essa consistencia:
		If ValType(oPanel1) == "O" .And. !lItCkAct
			oPanel1:FreeChildren()
			oPanel1 := Nil
		EndIf
		STIFocoReg()
		oPanel1 := EVal(bPanel)  
  
		oPanel1:Show()

		oPanel1:Refresh()

		nPanelActive := 2

	Case nPanelActive == 0

		If ValType(oPanel1) == "O" .And. !lItCkAct
			oPanel1:FreeChildren()
			oPanel1 := Nil
		EndIf

		oPanel1 := EVal(bPanel)
		nPanelActive := 1

	Case nPanelActive == 1

		If ValType(oPanel2) == "O" .And. !lItCkAct
			LjGrvLog("STIExchangePanel" , "Destroi oPanel2 Hparent: "+ Str(oPanel2:Hparent) + " oPanel2 Hwnd : " +  Str(oPanel2:Hwnd) )		
			oPanel2:FreeChildren()
			FReeobj(oPanel2)	
			LjGrvLog("STIExchangePanel" , "oPanel2  - "+ Iif (ValType(oPanel2) == "O", "Não foi possivel Destruir", "Destruiu"))
		EndIf

		oPanel2 := EVal(bPanel)  //O Panel2 é que exibe a tela de brinde e qdo a variavel nPanelActive é igual a 1 ele exibe  porem ocorre erro log no oPanel1
		LjGrvLog("STIExchangePanel" , "Constroi no oPanel2 - " + Upper(GetCBSource(bPanel)) + " - Hparent: "+ Str(oPanel2:Hparent) + " oPanel2 Hwnd : " +  Str(oPanel2:Hwnd) )
		oPanel2:Show()

		oPanel2:Refresh()

		If ValType(oPanel1) == "O" .And. !lItCkAct
			iF GetCliHTML() .AND. (oPanel2:Hparent < oPanel1:Hparent)
				LjGrvLog("STIExchangePanel" , "Destroi oPanel1 Hparent: "+ Str(oPanel1:Hparent) + " oPanel2 Hwnd : " +  Str(oPanel1:Hwnd) )
				oPanel1:FreeChildren()
				FreeObj(oPanel1)
				LjGrvLog("STIExchangePanel" , "oPanel1  - "+ Iif (ValType(oPanel1) == "O", (oPanel1:Hide(), "Não foi possivel Destruir"), "Destruiu"))
			Else
				oPanel1:Hide()
			Endif
		EndIf

		nPanelActive := 2

	Case nPanelActive == 2

		If ValType(oPanel1) == "O" .And. !lItCkAct
			LjGrvLog("STIExchangePanel" , "Destroi oPanel1 Hparent: "+ Str(oPanel1:Hparent) + " oPanel2 Hwnd : " +  Str(oPanel1:Hwnd) )
			oPanel1:FreeChildren()
			FreeObj(oPanel1)
			LjGrvLog("STIExchangePanel" , "oPanel1  - "+ Iif (ValType(oPanel1) == "O", "Não foi possivel Destruir", "Destruiu"))
		EndIf

		oPanel1 := EVal(bPanel)
		LjGrvLog("STIExchangePanel" , "Constroi oPanel1  - " + Upper(GetCBSource(bPanel)) + " - Hparent: "+ Str(oPanel1:Hparent) + " oPanel1 Hwnd : " +  Str(oPanel1:Hwnd) )
		oPanel1:Show()

		oPanel1:Refresh()

		If ValType(oPanel2) == "O" .And. !lItCkAct
			If GetCliHTML() .AND. (oPanel2:Hparent > oPanel1:Hparent)
				LjGrvLog("STIExchangePanel" , "Destroi oPanel2 Hparent: "+ Str(oPanel2:Hparent) + " oPanel2 Hwnd : " +  Str(oPanel2:Hwnd) )		
				oPanel2:FreeChildren()
				FreeObj(oPanel2)
				LjGrvLog("STIExchangePanel" , "oPanel2  - "+ Iif (ValType(oPanel2) == "O", (oPanel2:Hide(),"Não foi possivel Destruir"), "Destruiu"))
			Else
				oPanel2:Hide()
			Endif 
		EndIf
		
		nPanelActive := 1

EndCase

oPOSDesk:SetBAlert( "" )

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} STIQtdItens
Atualiza o contador de itens

@param
@author  Varejo
@version P11.8
@since   29/03/2012
@return
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STIQtdItens()

Local cRet 		:= ""								//Variavel de retorno
Local oModel		:= oMdlPrin 						//Model Principal
Local oModelCup	:= oModel:GetModel("CUP_GRID")	//Model do grid
Local nI			:= 0								//Variavel de loop
Local nQtdItens	:= 0								//Acumulador - Qtde.Itens

For nI := 1 To oModelCup:Length()
	oModelCup:GoLine(nI)
	If !oModelCup:IsDeleted()
		nQtdItens += oModelCup:GetValue('L2_QUANT')
	EndIf
Next nI

cRet := AllTrim(Str(nQtdItens)) + ' ' + STR0026    //Iten(s)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STIQtdBrindes
Atualiza o contador de brindes

@param
@author  Varejo
@version P11.8
@since   15/05/2014
@return
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STIQtdBrindes()
Local cRet 		:= "" //Variavel de retorno
Local oModel	:= STDGPBModel()
Local nQtdItens := If( AliasInDic("MGC"),STDPBLength("MGC"),0) // quantidade total de registros na cesta MGC 
Local nCont     := 0 // contador de brindes ok
Local nX        := 0 // variavel de controle

For nX := 1 to  nQtdItens
	If oModel:GetModel("MGCBRINDE"):acols[nX][13] == .F. // não esta deletado
		nCont:= nCont + 1
	Endif
Next nX

cRet := alltrim(str(nCont)+ ' ' + "Brindes")
		
Return cRet
//-------------------------------------------------------------------
/*/{Protheus.doc} STIFocuFirst
Na abertura da tela da um setfocus no primeiro get

@param
@author  Varejo
@version P11.8
@since   29/03/2012
@return
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STIFocusFirst()

Local oGetCash := Nil //Get da abertura de caixa

oGetCash := STIGetCash()
oGetCash:SetFocus()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} STIFocuFirst
Executa a atualização do rodape da mensagem
@param
@author  Varejo
@version P11.8
@since   29/03/2012
@return
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STITimeMsg(oObj, cSemana, lMobile)
	Default oObj := oPOSDesk
	Default cSemana := ""

	Default lMobile := .F.
	//Em versoes Mobile nao exibe essa opcao. Somente no Menu superior
   If FindFunction("STFLatestMsg") .AND. !lMobile 
	   oObj:SetBInfo( STR0043  + Space(10) +  AllTrim(cSemana) + " " + AllTrim(DToC(Date())) +" | " + AllTrim(Left(Time(), 5)) ) //"F10 - Log de Mensagens |"
   Else
	   oObj:SetBInfo(Space(10) + AllTrim(cSemana)     + " " + AllTrim(DToC(Date())) +" | " + AllTrim(Left(Time(), 5)) )
   EndIf
STILoadSem()  
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} STIChangeCssBtn
Faz a troca do CSS qdo clica em alguns dos botoes
@param
@author  Varejo
@version P11.8
@since   29/03/2012
@return
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STIChangeCssBtn(cButton)

Local aButtons 	:= {'oBtnRegItem','oBtnClient','oBtnCancItem','oBtnOrc','oBtnDesc','oBtnConProd'}	//Array com nome dos botes
Local nI			:= 0																							//Variavel de loop

Default cButton := ''


For nI := 1 To Len(aButtons)
	If Empty(cButton)
		IF !lClientHtml
			&(aButtons[nI] + ':SetCss(POSCSS(GetClassName('+ aButtons[nI] + '),nNormal))')
		Endif 
	Else
		If aButtons[nI] == cButton
			&(aButtons[nI] + ':SetCss(POSCSS(GetClassName('+ aButtons[nI] + '),nAtivo))')
		ElseIf !Empty(cButton)
			&(aButtons[nI] + ':SetCss(POSCSS(GetClassName('+ aButtons[nI] + '),nNormal))')
		EndIf
	EndIf

Next nI


Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} STIPosClDsk
Libera o objeto oPOSDesk que não está sendo liberado e está ocorrendo erro na função STIMessage
@param
@author  Varejo
@version P11.8
@since   17/09/2014
@return .t.
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function STIPosClDsk()

FreeObj(oPOSDesk)
oPOSDesk := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} STIPosGOpc
Retorna a Operação em execução atual.

@param   	
@author  Varejo
@version P11.8
@since   09/04/2015
@return  Operação em execução atual
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIPosGOpc()
Return cOperation

//-------------------------------------------------------------------
/*/{Protheus.doc} STIPosSOpc
Seta a Operação em execução atual.

@param   	
@author  Varejo
@version P11.8
@since   09/04/2015
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIPosSOpc(cOper)
cOperation := cOper
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} DesalbitaColChange
Altera propriedade da view pois e´ feito setvalue no view e o remote segura e dispara muitas
alteracoes e pode dar stackoverflow
@param   	
@author  Varejo
@version P11.8
@since   23/07/2015
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static function DesalbitaColChange(oViewDetail)
Local aViewInfo	:= aClone(oViewDetail:GetViewObj("VIEW_CUPOM"))
Local oGridView := aViewInfo[3]	// Objeto GridView

//Removido o controle de Coluna alterada, pois e´ feito setvalue no view e o remote segura e dispara muitas
//Alteracoes e pode dar stackoverflow
oGridView:oBrowse:oBrowse:bColumnChanged := {||.T.}

aViewInfo := aSize(aViewInfo,0)
aViewInfo := Nil

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STIShowPagGrid
Funcao que habilita paginacao por botoes na GRID
@param
@author  Varejo
@version P11.8
@since   22/06/2015
@return .T.
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STIShowPagGrid()

Local lMobile := STFGetCfg("lMobile", .F.)		//Smart Client Mobile
Local lRet		:= .F. 								//Retorno

//Versao Mobile exibe Grid com paginacao por botao
lRet := ValType(lMobile) == "L" .AND. lMobile

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STINext
Funcao de proximo da paginacao do grid
@param
@author  Varejo
@version P11.8
@since   22/06/2015
@return .T.
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STINext()

Local oGridView 	:= oViewDetail:GetViewObj("VIEW_CUPOM")[3]	//Objeto GridView
Local nItensGrid 	:= SuperGetMv('MV_LJQTITE',,0) 					//Qtde de itens que cabe na grid
Local nPos 		:= oGridView:OBrowse:nAt 						//Posicao atual do ponteiro na view
Local lMobile 	:= STFGetCfg("lMobile" , .F. ) 					//E mobile?

If nItensGrid == 0
	If lMobile
		nItensGrid := Val(Str(oGridView:OBrowse:OBrowse:nClientHeight / oGridView:OBrowse:nRowHeight - 2,2))
	Else
		nItensGrid := Val(Str(oGridView:OBrowse:OBrowse:nClientHeight / oGridView:OBrowse:nRowHeight - 1,2))
	EndIf  
EndIf

If nPos != STDPBLength("SL2") .AND. STDPBLength("SL2") > nItensGrid
	If nPos == 1 
		oGridView:OBrowse:nAt := nItensGrid + 1 
	Else
		If (nPos + nItensGrid) < STDPBLength("SL2")
			oGridView:OBrowse:nAt := nPos + nItensGrid
		Else
			oGridView:OBrowse:nAt := STDPBLength("SL2")
		EndIf 
	EndIf
	oGridView:OBrowse:Refresh(,.T.)
	STIMsgPag(oGridView)
EndIf

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} STIReturn
Funcao de retorno da paginacao do grid
@param
@author  Varejo
@version P11.8
@since   22/06/2015
@return .T.
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STIReturn()

Local oGridView := oViewDetail:GetViewObj("VIEW_CUPOM")[3]	// Objeto GridView
Local nPosItem := 0 //Posicao que ira mostrar no grid
Local nItensGrid := SuperGetMv('MV_LJQTITE',,0) //Qtde de itens que cabe na grid
Local nQtdeItens := 0 //Quantidade de itens
Local lMobile := STFGetCfg("lMobile" , .F. ) //E mobile?

If nItensGrid == 0
	If lMobile
		nItensGrid := Val(Str(oGridView:OBrowse:OBrowse:nClientHeight / oGridView:OBrowse:nRowHeight - 2,2))
	Else
		nItensGrid := Val(Str(oGridView:OBrowse:OBrowse:nClientHeight / oGridView:OBrowse:nRowHeight - 1,2))
	EndIf 
EndIf

nQtdeItens := nItensGrid * 2

If !(oGridView:OBrowse:nAt <= nItensGrid) .AND. STDPBLength("SL2") > nItensGrid
	If STDPBLength("SL2") <= nQtdeItens
		oGridView:OBrowse:nAt := 1
	Else
		nPosItem := oGridView:OBrowse:nAt - nItensGrid 
		If nPosItem < 0 .OR. nPosItem <= nItensGrid		
			oGridView:OBrowse:nAt := 1
		Else
			oGridView:OBrowse:nAt := nPosItem
		EndIf	
	EndIf	
	oGridView:OBrowse:Refresh(,.T.)
	STIMsgPag(oGridView)
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} STIMsgPag
Funcao que monta a mensagem da quantidade de itens (de/ate)
@param
@author  Varejo
@version P11.8
@since   22/06/2015
@return .T.
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function STIMsgPag(oGridView)

Local nNumIni := 0 //Numero inicial da paginacao
Local nNumFin := 0 //Numero final da paginacao
Local nItensGrid 	:= SuperGetMv('MV_LJQTITE',,0) //Qtde de itens que cabem na grid
Local lMobile 	:= STFGetCfg("lMobile" , .F. ) //E versao mobile?

Default oGridView := IIF(oGridView == Nil,oViewDetail:GetViewObj("VIEW_CUPOM")[3],oGridView)

If nItensGrid == 0
	If lMobile
		nItensGrid := Val(Str(oGridView:OBrowse:OBrowse:nClientHeight / oGridView:OBrowse:nRowHeight - 2,2))
	Else
		nItensGrid := Val(Str(oGridView:OBrowse:OBrowse:nClientHeight / oGridView:OBrowse:nRowHeight - 1,2))
	EndIf
EndIf

If oGridView <> Nil
	
	If ProcName(1) == "STIGRIDCUPREFRESH" .AND. STDPBLength("SL2") > nItensGrid 
		nNumIni := (oGridView:OBrowse:nAt - nItensGrid) + 1
	Else
		nNumIni := oGridView:OBrowse:nAt
	EndIf
	nNumFin := oGridView:OBrowse:nAt + (nItensGrid - 1) 
	
	If nNumFin > STDPBLength("SL2") .AND. STDPBLength("SL2") > 0 
		nNumFin := STDPBLength("SL2")
	ElseIf STDPBLength("SL2") == 0
		nNumIni := 0
		nNumFin := 0
	EndIf
	
	cMsgPg := STR0048 +  AllTrim(Str(nNumIni)) + "-" + AllTrim(Str(nNumFin)) + STR0049 + AllTrim(Str(STDPBLength("SL2"))) + STR0050  // "Mostrando " ### " de " ### " itens"
	
	oSayPag:Refresh()

EndIf

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} STIObjPag
Cria os objetos para paginacao da grid
@param
@author  Varejo
@version P11.8
@since   22/06/2015
@return .T.
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function STIObjPag(oPanel)

oPnlPag := TPanel():New(00,00,"",oPanel,,,,,,700,50)
@ 001, 030  BUTTON oBtnAnt PROMPT "< " + STR0051  SIZE 50,15 ACTION {|| STIReturn() } OF oPnlPag PIXEL 	//"Anterior"
@ 001, (oBtnAnt:nWidth/2) + 10  SAY oSayPag PROMPT cMsgPg SIZE 100,18 CENTER OF oPnlPag PIXEL HTML
@ 001, (oBtnAnt:nWidth/2) + (oSayPag:nWidth/2) + 15  BUTTON oBtnPro PROMPT STR0052 + " >"  SIZE 50,15 ACTION {|| STINext() } OF oPnlPag PIXEL		//"Próximo"


oSayPag:SetCSS( POSCSS (GetClassName(oSayPag), CSS_LABEL_HEADER ))
oBtnAnt:SetCSS( POSCSS (GetClassName(oBtnAnt), CSS_BTN_NORMAL ))
oBtnPro:SetCSS( POSCSS (GetClassName(oBtnPro), CSS_BTN_NORMAL ))

Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} STIFocoReg
Foaca no botão Reg.Item
@param
@author  Varejo
@version P11.8
@since   24/01/2017
@return
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STIFocoReg()
	oBtnRegItem:SetFocus()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} STIAtuRoda
Força a atualização do Rodapé
@param
@author  Varejo
@version P11.8
@since   24/01/2017
@return
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STIAtuRoda()
    oViewRight:Refresh()
Return
/*/{Protheus.doc} STILoadSem
Carrega imagem do semaforo de conexao com a Retaguarda
@param   lTestCon - Se testa conexao
@param   lOnline  - Se conectado
@author  alessandrosantos
@version P11.8
@since   22/06/2017
@return
@obs
@sample
/*/
//-------------------------------------------------------------------

Function STILoadSem(lTestCon, lOnline)

Default lTestCon := .T. //Verifica se faz teste de conexao 
Default lOnline  := .F. //Status para alteracao imagem

If ValType(oSemaforo) == "O"     
	//Testa conexao
	If lTestCon     
	    lOnline  := IIF(GetPvProfString(CSECAO, CCHAVE, '0', GetAdv97()) == '0', .F., .T.)
	EndIf
	
	//Carrega imagem
	If lOnline .OR. lPdvOn
	    oSemaforo:SetBMP("FRTONLINE") //Conectado
	Else
	    oSemaforo:SetBMP("FRTOFFLINE") //Sem conexao
	EndIf
	
	oSemaforo:Refresh()
EndIf

Return Nil

/*/{Protheus.doc} GetTpClient
	Retorna se o Client WebAgent
	@since 15/02/2024
	@author caio.okamoto
	@version 12.1.2310
	@return lCliHtml, lógico, se HTML = .T.
/*/
Function GetCliHTML()

Local cVerWebApp	:= ""
Local lCliHtml		:= .F. 

//Verifica se o SmartClient é via WebApp ou não.
GetRemoteType(@cVerWebApp) 
lCliHtml:= 'HTML' $ UPPER(cVerWebApp)

LjGrvLog("GetCliHTML","Acesso realizado pelo WebAgent versão do WebApp",cVerWebApp)

Return lCliHtml 


//-------------------------------------------------------------------
/*{Protheus.doc} StiMataObj
Elimina a instância dos objetos da tela antes de trocar de painal
@param oMainPanel, Object, Objeto da tela
@author 
@since 20/09/2024
@version 12
*/
//-------------------------------------------------------------------
Function StiMataObj(oMainPanel, cPanelAnt)

Default oMainPanel := Nil // Objeto que contem a tela.
Default cPanelAnt	:= "" //Não pode pegar a variável static cLastPnlOpen, sempre receber via parametro.

If lClientHtml .And. oMainPanel <> Nil 
	oMainPanel:FreeChildren()
	FreeObj(oMainPanel)
	oMainPanel:=NIL
Endif 

Return 

