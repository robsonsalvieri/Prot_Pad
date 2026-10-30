#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE 'FWBROWSE.CH'
#INCLUDE "POSCSS.CH"   
#INCLUDE "STPOS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STIITEMREGISTER.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"                            
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "STIPAYNCCBC.CH"
#INCLUDE "STPOS.CH"
#INCLUDE "STIBONIFSELECTION.CH"    

Static oLblSelTotal		:= Nil					// Objeto do label que informa o valor total das Bonificacoes selecionadas.		
Static oLblTotalVend	:= Nil					// Label que informa o restante para pagamento																
Static aBonificacoes    := {}

//-------------------------------------------------------------------
/*/{Protheus.doc} STIBONIFSelection
Responsavel por montar a interface de apresentacao de Bonificacoes

@author Vendas CRM
@since 26/06/2014
@version 11.80
@return oMainPanel - Objeto contendo o painel de visualizacao das bonificacoes

/*/
//-------------------------------------------------------------------

Function STIBONIFSelection(nValueItem,cCodReg,cItemGrid,cProd,;
									aBonifCli, lPgto,cForma,oPnlAdconal)
Local oPanelMVC  		:= STIGetPanel()				// Objeto do Panel onde a interface de selecao de clientes sera criada
Local oMainPanel 		:= TPanel():New(00,00,"",oPanelMVC,,,,,,;
									oPanelMVC:nWidth/2,(oPanelMVC:nHeight)/2) // Painel de Get de Consulta

/*
	Declaracao dos Objetos
*/
Local oLblCab			:= Nil							// Objeto do label "Bonificações do Cliente"
Local oLblList			:= NIl							// Objeto do label "Digite aqui para filtrar"
Local oListPanel		:= Nil 							// Objeto do panel onde será criado o Browse com as bonificacoes do cliente.
Local oListBonif		:= Nil							// Objeto do tipo TListBox, que exibe as bonificacoes do cliente.
Local oLblCliTotal		:= Nil							// Objeto do label que informa o valor total das bonificacoes do cliente.
Local oTotal  			:= STFGetTot() 					// Recebe o Objeto totalizador	

/*
	Variaveis de posicionamento de objetos
*/
Local nPosVerCab		:= 0.015						// Posicao Horizontal do Say "Bonificações do Cliente"
Local nPosVerPanListBox	:= oMainPanel:nHeight/2 * 0.0666// Posicao vertical do objeto TPanel oListPanel
Local nPosVerTListBox	:= oMainPanel:nHeight/2 * 0.05	// Posicao vertical do Say oLblList
Local nListPosHor		:= oMainPanel:nWidth/2 * 0.05	// Posicao Horizontal do objeto TListBox oListBonif


/*/
	Botão "Selecionar Cliente"
/*/
Local oButton			:= Nil							// Botao "Selecionar Cliente"
Local nBtnWidPerc		:= 0.25			   				// Percentual de Largura do Botão "Selecionar Cliente"
Local nBtnHeiPerc		:= 0.08			  		 		// Percentual de Altura do Botão "Selecionar Cliente"
Local nBtnVerPerc		:= 0.8			   				// Percentual da Posição Vertical do Botão "Selecionar Cliente"
Local nBtnHorPerc		:= 0.65			 		  		// Percentual da Posição Horizontal do Botão "Selecionar Cliente"

Local aListBonif			:= {}						// Itens do objeto oListBonif
Local nX				:= 0							// Contador do FOR
Local oListFont 		:= TFont():New("Courier New") 	// Fonte utilizada no listbox

Local nSaldoBonif		:= 0							// Total das Bonificacoes do cliente
Local nTotalSel			:= 0							// Total das Bonificacoes selecionadas
Local oTotFont			:= TFont():New( "Arial"	,Nil,-13,Nil,.T. )	// Objeto da fonte dos totalizadores

Local nValor            := 0                            // Valor do produto 
Local nVTBonif          := 0                            // Valor total da bonificacao
Local cReturn           := ""                           // Objeto de retorno
Local cInfo             := ""								// Informação para a tela
Local nTamProd		:= SB1->(TamSx3("B1_COD")[1])
Local cProdBonif		:= "" //Produto bonificacao

Default nValueItem		:= 0				// Valor do Item
Default cCodReg			:= ""				// Código do Registro
Default cItemGrid			:= ""				// Item do Grid
Default cProd				:= ""				// Produto
Default aBonifCli			:= {}				// Array para Bonificação do Cliente
Default lPgto  			:= .F.          // Valida a forma de pagamento 
Default cForma 			:= ""           // Forma de pagamento a ser validado
Default oPnlAdconal     := Nil          // Objeto do Resumo de Pagamento

For nX := 1 To Len(aBonifCli)
	If Len(aBonifCli[nX]) < 6
		aSize(aBonifCli[nX], 6)
		
		cProdBonif := AllTrim(SubStr(aBonifCli[nX,01],1, nTamProd )) //Lê o codigo do produto selecionado ref. a bonificacao
		If Rat('-', cProdBonif) > 0 //Retira o traco no final do codigo do produt
			cProdBonif := Left(cProdBonif, Rat('-', cProdBonif)-1)
		EndIf
		aBonifCli[nX, 05] := cProdBonif
		aBonifCli[nX, 06] := .F.
	EndIf

	If !Empty(aBonifCli[nX,2])//Valor do produto possui desconto em Porcentagem
		 nValor := aBonifCli[nX,4] - ((aBonifCli[nX,4] / 100) * aBonifCli[nX,2])
	 	 If nValor > 0
	 	  	aAdd(aListBonif,aBonifCli[nX,1]+STR0001+AllTrim(Str(aBonifCli[nX,4]))+STR0002;
	 	  								+AllTrim(str(nValor)))//" Valor bonificado De :"##" Para:"
	 	 Endif 
	Else
	 	If !Empty(aBonifCli[nX,3])//Valor do produto possui desconto em Valor
			nValor := (aBonifCli[nX,4] - aBonifCli[nX,3])
		 	If nValor > 0
			 	aAdd(aListBonif,aBonifCli[nX,1]+STR0001+AllTrim(Str(aBonifCli[nX,4]))+STR0002;
			 							+AllTrim(str(nValor)))//" Valor bonificado De :"##" Para:"
			Endif	
		Else
	   		//valor cheio do produto
		    nValor := aBonifCli[nX,4] 
	    	If nValor > 0	
		    	aAdd(aListBonif,aBonifCli[nX,1]+STR0001+AllTrim(Str(aBonifCli[nX,4])))	 //" Valor bonificado De :"
		    Endif	
	 	Endif
	Endif

Next nX
	
If !Empty(cForma)
	cInfo := STR0003+ cForma +STR0004//"Pague com "##" e compre produtos bonificados: "
Else
	cInfo := STR0005
Endif

If !Empty(aListBonif)
	/*/
		Cabecalho da tela "
	/*/
	oLblCab:= TSay():New(POSVERT_CAB,POSHOR_1,{||cInfo},oMainPanel,,,,,,.T.,,,,) 
	oLblCab:SetCSS( POSCSS (GetClassName(oLblCab), CSS_BREADCUMB )) 	 
	
	/* Instancia do Painel do ListBox  */
	oListPanel := TPanel():New(nPosVerPanListBox,000,"",oMainPanel,;
									,,,,;
									,oMainPanel:nWidth/2.15,oMainPanel:nHeight/5)
	
	/* Instancia do Label do ListBox  */
	oLblList:= TSay():New(000,nListPosHor,{||STR0006},oListPanel,,;
									oTotFont,,,,.T.,,,,)//"Selecione a bonificação desejada e clique em 'Avançar'"
	oLblList:SetCSS( POSCSS (GetClassName(oLblList), CSS_LABEL_FOCAL )) 
	
	/* Instancia do ListBox  */
	oListBonif := TListBox():Create(oListPanel, nPosVerTListBox, nListPosHor, Nil,;
									 aListBonif, oListPanel:nWidth/2.2, oListPanel:nHeight/2.5,,;
									 ,,,.T.,;
									 ,{||STISelectBonif(oListBonif,@aBonifCli)},oListFont)
	oListBonif:SetCSS( POSCSS (GetClassName(oListBonif), CSS_LISTBOX )) 
	
	/* Instancia do Label que informa o restante a ser pago na venda */                
	oLblTotalVend := TSay():New(oMainPanel:nHeight/4, nListPosHor,;
							 {||STR0007+ AllTrim(Str(oTotal:GetValue("L1_VLRTOT"),12,2)) +STR0008},;
							  oMainPanel,,oTotFont,,;
							  ,,.T.,,;
							  ,,10)//"Restam " ##" para pagamento."
	oLblTotalVend:SetCSS( POSCSS (GetClassName(oLblTotalVend), CSS_LABEL_FOCAL )) 
	
	/* Instancia do botao "Avançar" */
	oButton	:= TButton():New(	POSVERT_BTNFOCAL,POSHOR_BTNFOCAL,STR0009,oMainPanel,;
							{ || STIBONIFBasket(oListBonif,aBonifCli, lPgto,cForma,;
								oMainPanel) }, LARGBTN,ALTURABTN,,,,.T.) //"Avançar"
	oButton:SetCSS( POSCSS (GetClassName(oButton), CSS_BTN_FOCAL )) 
	
	/* Button: Cancelar */
	If !Empty(cForma)
		oBtnCa := TButton():New(POSVERT_BTNFOCAL,POSHOR_1,STR0010,oMainPanel,{|| STIPayment() },LARGBTN,ALTURABTN,,,,.T.) //"Cancelar"
		oBtnCa:SetCSS( POSCSS(CSS_BTN_ATIVO))
	Endif	
	
Else
   STIExchangePanel( { || STIPayment() } ) //Exibe tela de pagamento									
Endif
//Return oMainPanel => nao pode usar esse tipo de retorno porque no Cancela ocorre travamento da tela nao permitindo selecionar nenhuma forma de pagamento
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} STIBONIFBasket
Responsavel por inserir o produto bonificado na cesta 

@author Vendas CRM
@since 26/06/2014
@version 11.80
@return Nil

/*/
//-------------------------------------------------------------------
Function STIBONIFBasket(oListBonif,aBonifCli, lPgto,cForma,oMPanel2)
Local nItemLine	  := STDPBLength("SL2") + 1 // para acrescentar mais uma linha na cesta
Local cCliCode	  := STDGPBasket("SL1","L1_CLIENTE")			// Código do Cliente
Local cCliLoja	  := STDGPBasket("SL1","L1_LOJA")				// Código da Loja
Local cCliType	  := STDGPBasket("SL1","L1_TIPOCLI")			// Tipo do Cliente
Local nPos		  := oListBonif:GetPos()								// Posição da Lista de Bonificação
Local nVLBonif    := STIGetBonif(.F.)								// Obter Valor da Bonificação
Local lRegistred  := .F. // verifica se o produto foi inserido na cesta
Local nSecItem    := Seconds()  // Inicia os segundos iniciais entre um item e o outro logo apos a inclusão do CPF
Local nMoeda	  := 1  // Moeda padrao
Local nTotItem    := 0  // Subtrai os segundos atuais com o ultimo tempo registrado do item anterior
Local nValueTotal := 0  // valor total com a bonificacao 
Local nVLDesc     := 0  // valor do desconto
Local nVaLor      := 0  // valor do produto com bonificacao
Local cProdBonif  := "" // produto bonificado 
Local cTPDesc     := "" // tipo de desconto

//Criação de tela auxiliar
Local oPanel     	:= STIGetPanel()	// Objeto do Panel onde a interface sera criada - Painel filho
Local nPosHozPan	:= oPanel:nWidth/80 // Posicao horizontal do painel - Painel Pai
Local nPosAltPan	:= 0                // Posicao: Altura do Painel
Local nTamLagPan	:= 310      		// Tamanho: Largura do Painel
Local nTamAltPan	:= 200      		// Tamanho: Altura do Painel
Local bCreatePan	:= {||TPanel():New(nPosAltPan,nPosHozPan,"",oPanel,,,,,,nTamLagPan,nTamAltPan)}   // Bloco de codigo para criacao do Painel adicional	
Local nC 			:= 1

Default oListBonif		:= nil				// Objeto Lista de Bonificação
Default aBonifCli			:= {}				// Array Bonificação Cliente
Default lPgto  			:= .F.          // Valida a forma de pagamento
Default cForma 			:= ""           // Forma de pagamento a ser validado
Default oMPanel2        := Nil

If !Empty(oMPanel2)
 	nPosAltPan	:= oMPanel2:nHeight/20       // Posicao: Altura do Painel
Endif

For nC := 1 to len(aBonifCli)

	//verifica se o Produto foi marcado
	If aBonifCli[nC, 06] //Item selecionado?

		nTotItem += seconds() - nSecItem  
		cProdBonif := aBonifCli[nPos,5] //Produto retornado no Array
		
		If !Empty(aBonifCli[nPos,2])//Valor do produto possui desconto em Porcentagem
			 nVLDesc := (aBonifCli[nPos,4] / 100) * aBonifCli[nPos,2]
			 nVaLor  := aBonifCli[nPos,4] - nVLDesc
			 cTPDesc := "P"
		Else
			 If !Empty(aBonifCli[nPos,3])//Valor do produto possui desconto em Valor
				 nVaLor := aBonifCli[nPos,4] -  aBonifCli[nPos,3]
				 cTPDesc := "V"
			 Endif
		Endif                                                
			 
		If nVaLor == 0 //Importante
			nVaLor :=  aBonifCli[nPos,4]
		Endif  
		
		aAdd(aBonificacoes ,{cProdBonif,nVaLor,nItemLine,alltrim(cForma)})
		
		/*/
			Registra Item
		/*/            
		lRegistred := STWItemReg( 	nItemLine		, ;		// Item
		    			cProdBonif		, ;		// Codigo Prod bonificado
		   				cCliCode 		, ;		// Codigo Cli
		   				cCliLoja		, ;		// Loja Cli
						nMoeda 	      	, ;		// Moeda
						nil				, ;		// Valor desconto 
		 				cTPDesc   		, ;		// Tipo desconto ( Percentual ou Valor ) - Tipo de desconto, se "V" - Valor ou "P" - Percentual
		 				Nil 			, ;		// Item adicional?
		  				Nil 			, ;		// TES
		  				cCliType 		, ;		// Tipo do cliente (A1_TIPO)
		  				Nil 			, ;		// Registra item no cupom fiscal?
		  				nVaLor			, ;		// Preço
		  				Nil				, ;		// Tipo do Item
		  				Nil				, ;		// Imprime CNPJ no cupom Fiscal
		  				Nil				, ;		// Tela do POS está sendo apresentada
		  				nTotItem        , ;     // Total dos segundos entre itens
		  				Nil				, ;		// Servico financeiro 
		  				.T.		)		        // Produto bonificado
		  						
		nSecItem := Seconds()   // Inicia os segundos iniciais entre um item e o outro logo apos a inclusão do ultimo item
		
		STIGridCupRefresh() // Sincroniza a Cesta com a interface
		
		If !lPgto
		  STIExchangePanel( { || STIPanItemRegister() } ) //Exibe tela de selecao de itens
		
		Else
		
		STIPayment(.F.) //Inclui a Bonificacao 	  
		
	    nVLBonif   := STIGetBonif(.F.)  
	
		nValueTotal := STFSaleTotal() - nVLBonif
		  
		If nVLBonif > 0                                    
		     //Atualiza o resumo de pagamentos = GD	
		     If cForma <> "MN" 
		     	STIAddPay("BF", Nil, 1, Nil, Nil, nVLBonif)     //Bonificacao
		     Endif
		     
		     If !Empty(cForma)
			     oPnlAdconal := Eval(bCreatePan)
			  	 
			  	 Do Case
					Case(cForma == "R$")
						/* Tela de dinheiro */                       
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
						/* Telado do cheque */
						STIPayCheck(oPnlAdconal, "") 
					Case (cForma == "VP")
						/* Tela do vale presente */
						STIPayGiftV(oPnlAdconal) 
					Case (cForma == "CP")
						/* Tela da condicao de pagamento */
						STIPayCdPg(oPnlAdconal) 
					Case (cForma == "MN")
						/* Tela da multi negociacao */
						STIExchangePanel({|| STIPnlMulti(Nil) })
					Case (cForma == "NB")
						/* Tela da Nota de Crédito Cód. Barras */
						STIPayNCCBC(oPnlAdconal)
				    OtherWise  	
		   				STIPayFinancial(oPnlAdconal, cForma)
				  EndCase
		     Endif
		   Endif  
		Endif
		Exit
	EndIf	

Next nC
	
Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} STISelectBonif
Responsavel por realizar a marcacao do item selecionado

@aparam oListNCCs - Objeto do tipo TListBox responsavel por apresentar
os produtos bonificados
@author Vendas CRM
@since 26/06/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function STISelectBonif(oListBonif,aBonifCli)

Local nLine 		:= 0											// Linha da Lista de Bonificação
Local cTextSelection:= STR0011//"Item Selecionado - "		// Texto do Item Selecionado	
Local nTam := Len(cTextSelection)
Local lDesmarca	:= .F.
Local nC := 0	

Default oListBonif := nil
Default aBonifCli := {}

nLine := oListBonif:nAt

If nLine > 0
	If !aBonifCli[nLine, 06] //Para evitar que o mesmo item seja selecionado mais de uma vez. 
		oListBonif:Modify(cTextSelection+oListBonif:GetSelText(),nLine)	// Modifica o texto para informar que a NCC foi selecionada
		aBonifCli[nLine, 06] := .T.
		lDesmarca	:= .T.
	Else
		oListBonif:Modify(Substr(oListBonif:GetSelText(),nTam+1),nLine)
		aBonifCli[nLine, 06] := .F.
	Endif

	//Demarca os demais
	If lDesmarca
		For nC := 1 to Len(aBonifCli)
			If aBonifCli[nC, 06] .AND. nC <> nLine
				oListBonif:Select( nC )
				oListBonif:Modify(Substr(oListBonif:GetSelText(),nTam+1),nC)
				aBonifCli[nC, 06] := .F.			
			EndIf
		Next nC
		
		//oListBonif:nAt := nLine
		oListBonif:Select( nLine )
	EndIf	
EndIf



Return


//-------------------------------------------------------------------
/*/{Protheus.doc} STIGetBonif
Retorna o valor total dos produtos bonificados

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	01/07/2014
@return  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIGetBonif(lZera)
Local nVLTotal := 0
Local nX       := 0

Default lZera := .F.

If !lZera
	For nX:= 1 to len(aBonificacoes)
		nVLTotal +=  aBonificacoes[nX][2]	
	Next
Else
	aBonificacoes := {}
Endif	

Return nVLTotal



//-------------------------------------------------------------------
/*/{Protheus.doc} STIAtuTotal
Atualiza o array total 
@param   	
@author  	Vendas & CRM
@version 	P12
@since   	01/07/2014
@return  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIAtuTotal(cForma,cValor)

Default cForma := ""
Default cValor := ""

aAdd(aBonificacoes,{cForma,cValor}	)

Return Nil



//-------------------------------------------------------------------
/*/{Protheus.doc} STDDelBonificacao
Function Exclui item do array de Bonificacoes

@author  Varejo
@version P11.8
@since   22/07/2014
@return  lRet				Retorna se deletou com sucesso
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDDelBonificacao(cPosGride,lCheca ) 
Local nX 		 := 0   // contador
Local lRet 		 := .F.	// Retorna se deletou
Local cGetProd   := ""

Default cPosGride := 0
Default lCheca    := .F. //Checa se o brinde é por forma de pagto, que no caso só pode existir 1 brinde por Forma de Pagto e no caso 
                      // da Forma de Pgto ser limpa e ja exista um brinde incluido é ncessario excluí-lo da cesto 

//Cancelar o item 
If !lCheca
	For nX := 1 to  len(aBonificacoes)
		If aBonificacoes[nX][3] == cPosGride 
	   	    aBonificacoes[nX][2] := 0
	   		lRet := .T.
		Endif
	Next nX 
Else
	For nX := 1 to  len(aBonificacoes)
		If aBonificacoes[nX][4] <> ""                      
	   	    aBonificacoes[nX][2] := 0
	   		lRet := .T.
	   		cGetProd :=  PADL(aBonificacoes[nX][3],2,"0")//Excluido o item da Cesta para atualizar o valor total da venda
	   		STWItemCancel(cGetProd)	   		
		Endif
	Next nX 
Endif	

Return lRet

