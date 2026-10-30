#Include 'Protheus.ch'
#INCLUDE 'FWBROWSE.CH'
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "POSCSS.CH"
#INCLUDE "STPOS.CH"
#INCLUDE "STISALESMANSELECTION.CH"

Static aRecno 		:= {}
Static lVendSel		:= .F. //Indica se a tela de vendedor ja foi solicitada

//-------------------------------------------------------------------
/*{Protheus.doc} STISalesmanSelection
Funcao responsavel por chamar a troca do painel atual pelo painel de selecao de Vendedores.
@param
@author Varejo
@version 11.80
@since 10/09/2013
@return
*/
//-------------------------------------------------------------------

Function STISalesmanSelection()

STIExchangePanel( { || STIPaSalesmanSelection() } )

Return

//-------------------------------------------------------------------
/*{Protheus.doc} STIPaSalesmanSelection
Funcao responsavel pela criacao do Painel de selecao de Vendedores.
@param
@author Varejo
@version 11.80
@since 10/09/2013
@return oMainPanel - Objeto contendo o painel principal de selecao de Vendedores.
*/
//-------------------------------------------------------------------

Function STIPaSalesmanSelection()
Local oPanItCancel		:= Nil 							// Painel Cancelamento de Venda
Local oPanBtnSale  		:= Nil							// Painel de Botões da Venda
Local oPanelMVC  		:= STIGetPanel()				// Objeto do Panel onde a interface de selecao de Vendedores sera criada
Local oMainPanel 		:= TPanel():New(00,00,"",oPanelMVC,,,,,,oPanelMVC:nWidth/2,(oPanelMVC:nHeight)/2) // Painel de Get de Consulta

Local oLblCab			:= Nil							// Objeto do label "Seleção de Vendedor"

/*/
	Get Combo de Busca
/*/
Local oLblList			:= Nil
Local oGetList			:= Nil							// TComboBox Escolha do campo a ser utilizado na busca
Local cGetList			:= ""							// Variável do Get


Local oLblCPFList		:= Nil							// Label do ComboBox
Local oGetCPFList		:= Nil							// TComboBox Escolha do campo a ser utilizado na busca
Local cGetCPFList		:= ""							// Variável do Get

/*/
	Get de Busca
/*/
Local oLblSearch		:= Nil							// Label do ComboBox
Local oGetSearch		:= Nil							// TGet busca
Local cGetSalesman		:= Space(40)					// Variável do Get
Local nGetVerPerc		:= oMainPanel:nHeight/2 * 0.1	// Percentual da Posição Vertical do Get
Local nGetHorPerc		:= oMainPanel:nWidth/2 * 0.5	// Percentual da Posição Horizontal do Get
Local nGetHeiPerc		:= 0.03							// Percentual de Altura do Get

/*/
	Botão "Selecionar Vendedor"
/*/
Local oButton			:= Nil							// Botao "Selecionar Vendedor"
Local nBtnWidPerc		:= 0.25			   				// Percentual de Largura do Botão "Selecionar Vendedor"
Local nBtnHeiPerc		:= 0.08			  		 		// Percentual de Altura do Botão "Selecionar Vendedor"
Local nBtnVerPerc		:= 0.8			   				// Percentual da Posição Vertical do Botão "Selecionar Vendedor"
Local nBtnHorPerc		:= 0.65			 		  		// Percentual da Posição Horizontal do Botão "Selecionar Vendedor"

/*
	Posicoes do oSalesmanPanel
*/
Local nCustPanHor		:= 15						// Posicao horizontal de oSalesmanPanel
Local nCustPanVer		:= oMainPanel:nHeight/2 * 0.3	// Posicao vertical de oSalesmanPanel

Local oListFont 		:= TFont():New("Courier New") 	// Fonte utilizada no listbox
Local oSalesmanPanel	:= Nil 							// Objeto do panel onde será criado o Browse com as informacoes do Vendedor.

Local bConfirm			:= { || STIFilSalesmanData(oGetList,oGetSearch)}
Local oButCan			:= Nil 	//Botao cancelar
Local oButPesq		:= Nil 	//Botao pesquisar
Local lMobile 		:= STFGetCfg("lMobile", .F.)		//Smart Client Mobile
/*/
	Objetos
/*/

oLblCab:= TSay():New(POSVERT_CAB,POSHOR_1,{||STR0001},oMainPanel,,,,,,.T.,,,,) //"Seleção de Vendedor"
oLblCab:SetCSS( POSCSS (GetClassName(oLblCab), CSS_BREADCUMB )) 

oLblSearch := TSay():New(POSVERT_LABEL1,POSHOR_1, {||STR0002}, oMainPanel,,,,,,.T.) //"Pesquisar Vendedor:"

oGetSearch:= TGet():New(POSVERT_GET1,POSHOR_1,{|u| If(PCount()>0,cGetSalesman:=u,cGetSalesman)},;
						oMainPanel,120 ,ALTURAGET,"@!",{|| If( Empty(cGetSalesman), oButton:SetFocus(), Nil ) },,,,,,.T.,,,,,,,,,,"cGetSalesman")
oGetSearch:SetCSS( POSCSS (GetClassName(oGetSearch), CSS_GET_NORMAL )) 
oGetSearch:bLostFocus := { || IIF( !STISalManFilter(cGetSalesman,oGetList,aRecno),oGetSearch:SetFocus(),Nil)}

//Botao pesquisar para versao mobile
If ValType(lMobile) == "L" .AND. lMobile 
	oButPesq	:= TButton():New(	POSVERT_GET1,POSHOR_1+130,"",oMainPanel,, ;
									20,20,,,,.T.,,,,{||.T.})
	oButPesq:SetCSS( POSCSS (GetClassName(oButPesq), CSS_BTN_LUPA )) 
EndIf	

oLblSearch:SetCSS( POSCSS (GetClassName(oLblSearch),CSS_LABEL_FOCAL )) 

oLblList := TSay():New(POSVERT_LABEL2,POSHOR_1, {||STR0003}, oMainPanel,,,,,,.T.) //"Código / Nome / CPF/CNPJ"
oLblList:SetCSS( POSCSS (GetClassName(oLblList),CSS_LABEL_FOCAL )) 

//ListBox 
oGetList := TListBox():Create(oMainPanel, POSVERT_GET2, POSHOR_1, {|u| If(PCount()>0,cGetList:=u,cGetList)}, , LARG_LIST_CONSULT , ALT_LIST_CONSULT,,,,,.T.,,bConfirm,oListFont)
oGetList:SetCSS( POSCSS (GetClassName(oGetList),CSS_LISTBOX )) 

oButton	:= TButton():New(	POSVERT_BTNFOCAL,POSHOR_BTNFOCAL,STR0004,oMainPanel,bConfirm, ;
							LARGBTN,ALTURABTN,,,,.T.) //"Selecionar Vendedor"

oButton:SetCSS( POSCSS (GetClassName(oButton),CSS_BTN_FOCAL )) 

oButCan	:= TButton():New(	POSVERT_BTNFOCAL,POSHOR_1,STR0007,oMainPanel,{|| STIRegItemInterface() }, ;  //"Cancelar"
							LARGBTN,ALTURABTN,,,,.T.,,,,{||.T.})
oButCan:SetCSS( POSCSS (GetClassName(oButCan), CSS_BTN_NORMAL )) 

oGetSearch:SetFocus()

Return oMainPanel

//-------------------------------------------------------------------
/* {Protheus.doc} STIFilSalesmanData
Funcao responsavel por setar os dados do Vendedor selecionado na tabela SL1, além de carregar um model com as informações do Vendedor
@param oGetList      	- Objeto de escolha do campo a ser utilizado na busca
@author Varejo
@version 11.80
@since 10/09/2013
@return
*/
//-------------------------------------------------------------------

Function STIFilSalesmanData(oGetList,oGetSearch)
Local oModelVen := Nil								// Model do Vendedor selecionado
Local nPos			:= oGetList:GetPos()               	// Posicao da selecao
Local nRecno		:= 0                               	// Recno do Registro
Local cVenPad		:= SuperGetMv( "MV_VENDPAD" )		// Vendedor Padrao
Local nAtuVen  	:= SuperGetMv("MV_LJATVEN",,0)		// Define se atualiza L2_VEND apos trocar vendedor
Local lSTValidVen	:= ExistBlock("STValidVen")		//Ponto de entrada para validar o vendedor
Local lNext		:= .T.								//Logico dizendo se continua o processamento ou nao
Local cCodVen		:= ''								//Codigo do vendedor para o ponto de entrada
Local aRetValid	:= {}								//Retorno do ponto de entrada
Local cFrase		:= ''								//Frase a ser exibida do ponto de entrada
Local nTotItSL2		:= 0
Local nItem			:= 0

If lSTValidVen
	If nPos > 0 .AND. !Empty(aRecno)
		nRecno	:= aRecno[nPos]
		SA3->(DbGoTo(nRecno))
		cCodVen := SA3->A3_COD 
	Else
		cCodVen := cVenPad
	EndIf
	aRetValid := ExecBlock("STValidVen",.F.,.F.,{cCodVen})	
	lNext 	:= aRetValid[1]
	cFrase := aRetValid[2]
EndIf

If lNext
	If nPos > 0 .AND. !EMPTY(aRecno)
		nRecno	:= aRecno[nPos]
		SA3->(DbGoTo(nRecno))

		oModelVen := STWSalesmanSelection(SA3->A3_COD)
		STDSPBasket("SL1","L1_VEND"	 ,oModelVen:GetValue("SA3MASTER","A3_COD"))
		STDSPBasket("SL1","L1_VEND2" ,oModelVen:GetValue("SA3MASTER","A3_SUPER"))
		STDSPBasket("SL1","L1_VEND3" ,oModelVen:GetValue("SA3MASTER","A3_GEREN"))
		STDSPBasket("SL1","L1_COMIS" ,STDGComission( oModelVen:GetValue("SA3MASTER","A3_COD") ))
				
		If nAtuVen == 1
			nTotItSL2 := STDPBLength("SL2")
	       For nItem := 1 to nTotItSL2
				If Empty(STDGPBasket("SL2","L2_NUMORIG", nItem)) //Valida se o item e de um orcamento importado, nao permitindo alterar o vendedor 
					STDSPBasket( "SL2", "L2_VEND", oModelVen:GetValue("SA3MASTER","A3_COD"), nItem  )
					STDSaveSale(nItem)
				EndIf
			Next
		EndIf
				         	
		STISSelVend(.T.) //Indica que a tela de vendedor ja foi solicitada, para nao solicitar mais nesta venda.
		STFMessage(ProcName(),"STOP",STR0005) //"Vendedor Selecionado"
		STFShowMessage(ProcName())
	Else
		STDSPBasket("SL1","L1_VEND"	,cVenPad)
		STFMessage(ProcName(),"STOP",STR0006) //"Nenhum Vendedor foi selecionado. Será utilizado o Vendedor padrão."
		STFShowMessage(ProcName())
		STFCleanMessage(ProcName())
	EndIf
	
	aRecno := {}
	
	STIBtnActivate() //Ativa os botoes da tela
	STIExchangePanel( { ||  STIPanItemRegister() } )
Else
	STFMessage(ProcName(),"STOP",cFrase) 
	STFShowMessage(ProcName())
	oGetSearch:SetFocus()
EndIf


Return


//-------------------------------------------------------------------
/*{Protheus.doc} STIGSelVend
Retorna o valor da variavel static lVendSel, que indica se a tela de vendedor ja foi solicitada.

@author  	Vendas & CRM
@version 	P11.8
@since   	19/01/2016
@return  	lVendSel - Indica se a tela de vendedor ja foi solicitada
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIGSelVend()
Return lVendSel

//-------------------------------------------------------------------
/*{Protheus.doc} STISSelVend
Controla o valor da variavel static lVendSel, que indica se a tela de vendedor ja foi solicitada.

@param   	lSet .T. -> Vendedor ja selecionado (nao apresenta mais a tela de vendedor)
				 .F. -> Vendedor nao selecionado ainda (apresentar tela para seleção) 
@author  	Vendas & CRM
@version 	P11.8
@since   	19/01/2016
@return  	Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STISSelVend(lSet)
lVendSel := lSet
Return Nil
