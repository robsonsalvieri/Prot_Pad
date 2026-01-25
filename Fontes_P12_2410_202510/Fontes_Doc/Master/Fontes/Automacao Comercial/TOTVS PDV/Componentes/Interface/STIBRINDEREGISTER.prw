#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"                            
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "POSCSS.CH"
#INCLUDE "STPOS.CH" 
#INCLUDE "STICUSTOMERSELECTION.CH"
#INCLUDE "STIBRINDEREGISTER.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} STIPanBrindeSelection
Funcao responsavel pela criacao do Painel de selecao de brindes.

@author Vendas CRM
@since 13/05/2014
@version
@return oMainPanel - Objeto contendo o painel principal de selecao de brindes
/*/
//-------------------------------------------------------------------

Function STIPanBrindeSelection(cCodReg,cItemGrid,cProd,aProducts,;
											lItem, cForma,oPnlAdconal)               

Local oPanelMVC  		:= STIGetPanel()				// Objeto do Panel onde a interface de selecao de  brinde sera criada
Local oMainPanel 		:= TPanel():New(00,00,"",oPanelMVC,,,,,,;
													oPanelMVC:nWidth/2,(oPanelMVC:nHeight)/2) // Painel de Get de Consulta
Local oLblCab			:= Nil							// Objeto do label 
Local oLblProd  		:= Nil							// Objeto do label 
Local oLblList			:= Nil
Local oGetList			:= Nil							// TComboBox Escolha do campo a ser utilizado na busca - Get Combo de Busca
Local cGetList			:= ""							// Variável do Get - Get Combo de Busca
Local oLblSearch		:= NIl							// Objeto do label "Digite aqui para filtrar"
Local oListFont 		:= TFont():New("Courier New") 	// Fonte utilizada no listbox
Local oBtnOk	   		:= Nil         				    //Objeto do botao Ok
Local oBtnCa			:= Nil              			//Objeto do botao Cancelar
Local bConfirm			:= {}						//Botão de Confirmação
Local cGetCustomer		:= ""						//Qual vendedor
Local nSaldo 			:= 0                             // saldo do brinde em estoque
Local nCustPanHor		:= 15						     // Posicao horizontal de oCustomerPanel
Local cInfo             := ""                            // texto informativo sobre a obrigatoriedade de forma de pagamento 
Local cReturn           := ""						// Variável de retorno

Default lItem   	:= .T.
Default cForma  	:= ""   // Forma de pagamento obrigatoria para adquirir o brinde
Default oPnlAdconal := Nil  // Objeto do Resumo de Pagamento
Default lItem       := .T.


If !Empty(cForma)
  cInfo := STR0001 + cForma +STR0002 //"Pague com a forma de pagamento " ##" e ganhe 1 brinde abaixo: "
Endif

/*/
	Objetos
/*/
If lItem
	oLblCab:= TSay():New(POSVERT_CAB,POSHOR_1,{||STR0003},oMainPanel,,,,,,.T.,,,,) //"Escolha 1 Brinde, ref. ao produto: "

	cReturn   := oMainPanel

	If !Empty(cProd)
		cGetCustomer:= alltrim(cProd)+" - "+Posicione( "SB1",1,xFilial( "SB1" )+cProd,"SB1->B1_DESC" )// Variável do Get
		oLblProd:= TSay():New(POSVERT_CAB+10,POSHOR_1,{||cGetCustomer},oMainPanel,,,,,,.T.,CLR_BLUE,CLR_BLUE,,)
		oLblProd:SetCSS( POSCSS (GetClassName(oLblProd), CSS_BREADCUMB )) 
	Endif	
Else
	If Empty(cInfo)
		oLblCab:= TSay():New(POSVERT_CAB+10,POSHOR_1,{||STR0004},oMainPanel,,,,,,.T.,,,,)	//"Escolha 1 Brinde: "
	Else
	    oLblCab:= TSay():New(POSVERT_CAB+10,POSHOR_1,{||cInfo},oMainPanel,,,,,,.T.,,,,)	
	Endif	
	cReturn   := .T.
Endif	
oLblCab:SetCSS( POSCSS (GetClassName(oLblCab), CSS_BREADCUMB )) 

	
If Empty(cForma)
	oLblList := TSay():New(POSVERT_LABEL2 -35 ,POSHOR_1, {||STR0005}, oMainPanel,,,,,,.T.)//'Código /Brinde '
Else
	oLblList := TSay():New(POSVERT_LABEL2 -15 ,POSHOR_1, {||STR0005}, oMainPanel,,,,,,.T.)//'Código /Brinde '
Endif	
oLblList:SetCSS( POSCSS (GetClassName(oLblList), CSS_LABEL_FOCAL )) 
	
If !Empty(cForma)
  bConfirm	:= { || STIConfirmBrind(oGetList,cCodReg,cItemGrid+"MB8",cProd,.F., .T.,cForma, oMainPanel)}
Else
  bConfirm	:= { || STIConfirmBrind(oGetList,cCodReg,cItemGrid+"MB2",cProd,lItem, .T.)}
Endif

If Empty(cForma)
	oGetList := TListBox():Create(oMainPanel, POSVERT_GET2-30, POSHOR_1, Nil, aProducts, LARG_LIST_CONSULT , ALT_LIST_CONSULT ,,,,,.T.,,bConfirm,oListFont)
Else
	oGetList := TListBox():Create(oMainPanel, POSVERT_GET2-50, POSHOR_1, Nil, aProducts, LARG_LIST_CONSULT , ALT_LIST_CONSULT ,,,,,.T.,,bConfirm,oListFont)
Endif	
oGetList:SetCSS( POSCSS (GetClassName(oGetList), CSS_LISTBOX )) 

/* Button: OK */
oBtnOk	 := TButton():New(	POSVERT_BTNFOCAL,POSHOR_BTNFOCAL,STR0006,oMainPanel,bConfirm, LARGBTN,ALTURABTN,,,,.T.)//"Selecionar Brinde"
oBtnOk:SetCSS(POSCSS(CSS_BTN_FOCAL))

/* Button: Cancelar */
If !Empty(cForma)
	oBtnCa	:= TButton():New(POSVERT_BTNFOCAL,POSHOR_1,STR0007,oMainPanel,{|| STIPayment() },LARGBTN,ALTURABTN,,,,.T.) //'Cancelar
	oBtnCa:SetCSS( POSCSS(CSS_BTN_ATIVO))
Endif	

Return cReturn //oMainPanel => nao pode retornar o objeto porque no botão cancelar o sistema trava! 


//-------------------------------------------------------------------
/*/{Protheus.doc} STICreateBrowse
Responsavel por criar o Browse com as informacoes dos brinde.

@param oGetList - Objeto que contem a lista de brindes.
@author Vendas CRM
@since 13/05/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function STIConfirmBrind(oGetList,cCodReg,cItemGrid,cProd,lItem,lExibe,cForma,oMPanel2)

Local aArea	:= GetArea()				// Posicionamento atual da tabela 
Local nRecno	:= 0						// Número do registro
Local nPos		:= oGetList:GetPos()		// Posição da lista
Local oCliModel	:= STDGCliModel() // Model do Cliente	
Local cNUM 		:= 0 //Numero de 
Local cSERIE	:= 0 //Numero de Serie
Local cPRODUT   := 0 //codigo do produto
Local cITEM 	:= 0 //codigo do item
Local cBRINDE	:= 0 //codigo do brinde
Local cEMISSA   := 0 //data de emissão do brinde
Local cCAIXA	:= 0 //codigo do caixa
Local cREGRA	:= 0 //codigo da regra utilizado
Local oModel 	:= STDGPBModel()			// Model da venda
Local nBrindes  := 1 //quantidade de brindes que o cliente ira receber do mesmo produto
Local nItemLine	:= STDPBLength("MGC") + 1	// Linha do grid
Local cPosGride := "" //posicao do gride de produtos comprados
Local nX        := 0  //contador
Local cDOC      := "" //codigo da nota fiscal
Local nValueTotal := STFSaleTotal() //Valor total da venda
Local nTotal    := STFSaleTotal()	// Valor total da venda

//Criação de tela auxiliar
Local oPanel     	:= STIGetPanel()	   // Objeto do Panel onde a interface sera criada - Painel filho
Local nPosHozPan	:= oPanel:nWidth/80    // Posicao horizontal do painel - Painel Pai
Local nPosAltPan	:= 0                   // Posicao: Altura do Painel
Local nTamLagPan	:= 310      		   // Tamanho: Largura do Painel
Local nTamAltPan	:= 200       		   // Tamanho: Altura do Painel
Local bCreatePan	:= {||TPanel():New(nPosAltPan,nPosHozPan,"",oPanel,;
									,,,,,nTamLagPan,nTamAltPan)}   // Bloco de codigo para criacao do Painel adicional	

Default lExibe := .T.
Default cForma := ""
Default oMPanel2        := Nil


If !Empty(cForma)
  nPosAltPan	:= oMPanel2:nHeight/20 // Posicao: Altura do Painel
Endif

If nPos > 0
	
    
	cNUM       := oModel:GetValue("SL1MASTER" , "L1_NUM")
	cSERIE     := oModel:GetValue("SL1MASTER" , "L1_SERIE") 
	cDOC       := oModel:GetValue("SL1MASTER" , "L1_DOC") 
	cBRINDE    := alltrim(SubStr(oGetList:aitems[nPos],1, 3 ))
	cPosGride  := STDGPBasket( "SL2" , "L2_ITEM" )

	//Seta a regra da quantidade de brindes que o cliente recebera do mesmo produto
	DbSelectArea("MGB")
	MGB->(DbSetOrder(2)) //MGB_FILIAL+MGB_CODREG+MGB_CODPRO
	If MGB->(DbSeek(xFilial("MGB")+cCodReg+cItemGrid+PadR(cBRINDE,TamSx3("MGB_CODPRO")[1])))	
		nBrindes:= MGB->MGB_QTDPRO		
	Endif	

	
	For nX := 1 to nBrindes
	
		If nItemLine > 1
			/*/
				Para o primeiro item nao realizar addline, pois o grid já traz linah em branco
			/*/
			STDPBAddLine("MGC")
		EndIf
		
		STDSPBasket("MGC","MGC_FILIAL"	, xFilial("MGC"))
		STDSPBasket("MGC","MGC_NUM"	    , cNUM)
		STDSPBasket("MGC","MGC_PRODUT"	, alltrim(cProd))
		STDSPBasket("MGC","MGC_ITEM"	, cPosGride)
		STDSPBasket("MGC","MGC_BRINDE"	, cBRINDE)
		STDSPBasket("MGC","MGC_EMISSA"	, dDataBase)
		STDSPBasket("MGC","MGC_SERIE"	, cSERIE)
		STDSPBasket("MGC","MGC_CAIXA"	, xNumCaixa())
		STDSPBasket("MGC","MGC_REGRA"	, cCodReg) 
		STDSPBasket("MGC","MGC_SITUA"   , "00") 
		STDSPBasket("MGC","MGC_DOC"     , cDOC) 		
		STDSPBasket("MGC","MGC_PGTO"    , cForma) //necessario para poder excluir quando o cliente mudar de forma de pagto

	Next

Endif	                                           

If lExibe
	If lItem //Exibe tela de itens de produtos
	  STIExchangePanel( { ||  STIPanItemRegister() } ) 
	Else
	
		If Empty(cForma)
			STIPayment(.F.) 
		   	STIAddPay("R$", Nil, 1, Nil, Nil,nTotal)//Total da venda
		Else
			STIPayment(.F.)                               
	 
	 		oPnlAdconal := Eval(bCreatePan)
	
			Do Case
				Case(cForma == "R$")
					// Tela de dinheiro 
					STIPayCash(oPnlAdconal)
				Case (cForma == "CC") .Or.  (cForma == "CD")
					// Tela do Cartao 
					STIPayCard(oPnlAdconal, cForma, nValueTotal) 	
			    Case (cForma == "FI")
			    	// Tela de Finaciamento
			    	STIPayFinancial(oPnlAdconal, "FI")		   
			    Case (cForma == "FID")	
				    // Tela de Fidelidade
				    STIPayShopCard(oPnlAdconal)      
				Case (cForma == "CH")
					// Telado do cheque 
					STIPayCheck(oPnlAdconal, "") 
				Case (cForma == "VP")
					// Tela do vale presente 
					STIPayGiftV(oPnlAdconal) 
				Case (cForma == "CP")
					// Tela da condicao de pagamento 
					STIPayCdPg(oPnlAdconal) 
				Case (cForma == "MN")
					// Tela da condicao de pagamento 
					STIExchangePanel({|| STIPnlMulti(Nil) })
				Case (cForma == "NB")
					// Tela da Nota de Crédito Cód. Barras 
					STIPayNCCBC(oPnlAdconal)
			  EndCase	   
	    Endif
	    
	Endif	
Endif	
	
RestArea(aArea)
Return .T. 

//-------------------------------------------------------------------
/*/{Protheus.doc} STBPrintBrinde
Imprime relatorio gerencial da conferencia de caixa

@param 	
@author  	Varejo
@version 	P11.8
@since   	18/06/2014
@return  	.T.
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBPrintBrinde()
Local oModel	:= STDGPBModel()
Local nQtdItens := STDPBLength("MGC") // quantidade total de registros na cesta MGC 
Local nX        := 0   // variavel de controle  de loop
Local cTexto 	:= ''  // Conteudo do relatorio
Local cProd     := ""  // Codigo do produto
Local nQtd      := 0   // Quantidade de produtos(brindes ou bonificados)  

For nX := 1 to  nQtdItens
	If oModel:GetModel("MGCBRINDE"):acols[nX][13] == .F.
		If !Empty(oModel:GetModel("MGCBRINDE"):acols[nX][5])
	      nQtd := nQtd + 1
		Endif
	Endif
Next nX		
	

If nQtd <> 0
	cTexto := CRLF + CRLF 
	cTexto += STR0008 + '.....: ' 	+ dtoc(oModel:GetModel("MGCBRINDE"):acols[1][6]) + CRLF //"Data"
	cTexto += STR0009 + '.....: ' 	+ oModel:GetModel("MGCBRINDE"):acols[1][8]   + CRLF //"Caixa"
	cTexto += CRLF + CRLF
	cTexto += STR0010 + ' |'+ STR0011 + '                   ' + CRLF//"Brinde"##"Descrição"
	cTexto += CRLF
	 	
	For nX := 1 to  nQtdItens
		If oModel:GetModel("MGCBRINDE"):acols[nX][13] == .F. // não esta deletado
			cProd:= oModel:GetModel("MGCBRINDE"):acols[nX][5]
			cTexto += alltrim(cProd) + '|' + Posicione( "SB1",1,xFilial( "SB1" )+cProd,"SB1->B1_DESC" ) + Space(3)  + CRLF			
			cProd:= ""
		Endif
	Next nX
	
	cTexto += CRLF + CRLF
	cTexto += STR0012 + '.....: ' + AllTrim(str(nQtd)) //"Total"
	
	//Relatorio da conferencia de caixa
	STWManagReportPrint( cTexto ,1 )
Endif
	
Return Nil


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
/*
Function STIQtdBrindes()
Local cRet 		:= "" 												//Variavel de retorno
Local oModel	:= STDGPBModel()										// Model de venda
Local nQtdItens := If( AliasInDic("MGC"),STDPBLength("MGC"),0) // quantidade total de registros na cesta MGC 
Local nCont     := 0 												// Contador de brindes ok
Local nX        := 0 												// variavel de controle

For nX := 1 to  nQtdItens
	If oModel:GetModel("MGCBRINDE"):acols[nX][13] == .F. // não esta deletado
		nCont:= nCont + 1
	Endif
Next nX

cRet := alltrim(str(nCont)+ ' ' + "Brindes")
		
Return cRet
/*
