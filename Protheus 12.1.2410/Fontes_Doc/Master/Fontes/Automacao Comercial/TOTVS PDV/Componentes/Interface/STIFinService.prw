#INCLUDE 'Protheus.ch'
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"                            
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "POSCSS.CH"  
#INCLUDE "STIFINSERVICE.CH"
#INCLUDE "STPOS.CH"

Static oListProduct	:= Nil
Static oListService	:= Nil
Static oListResSF		:= Nil
Static lListWhen		:= .T.									//Indica se o listbox de selecao de pagamento é editavel
Static lDisableBtn	:= .T.									//Desabilita/Habilita os botoes de Limpar e Finalizar pagamentos

//-------------------------------------------------------------------
/*/{Protheus.doc} STIFinService
Apresenta tela de escolha dos serviços financeiros.

@param1   aFinItens		Array com os serviços financeiros da venda.
@param2   aCriticCli		Array que recebera as criticas cadastrais do cliente
@author  Varejo
@version P11.8
@since   02/07/2014
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIFinService(aFinItens, aCriticCli)

Local oPanelMVC	:= STIGetPanel()																			//Painel do MVC	//Painel de botoes
Local oPanService	:= TPanel():New(00,00,"",oPanelMVC,,,,,,oPanelMVC:nWidth/2,oPanelMVC:nHeight/2)	//Painel do pagamento
Local nAltura 	:= (oPanService:nHeight / 2) * 0.20 		 											//Altura
Local nCol			:= (oPanService:nWidth / 2)  * 0.03													//Coordenada horizontal
Local nLargura	:= (oPanService:nWidth / 2)  - (2 * nCol)												//Largura
Local oLblFinServ	:= Nil																						//Objeto de venda > pagamento
Local oLblProduct	:= Nil																						//Label de pagamento
Local oLblService	:= Nil																						//Label do Serviço
Local oSayRes		:= Nil																						//Label Generico do Resumo Financeiro
Local oLblTotSFi	:= Nil																						//Label do resultado total de Serv. Finan. 
Local oLblTotGer	:= Nil																						//Label do resultado total de Serv. Finan com o Total da Venda
Local oButton		:= Nil 																					//Botão Prosseguir
Local oBtnLimpar	:= Nil																						//Botão Limpar

Local oTotal		:= STFGetTot() 																			//Recebe o objeto do model para recuperar os valores
Local nLblTotSFi	:= 0																						//Total dos Serv. Financeiros selecionados 
Local nLblTotGer	:= oTotal:GetValue("L1_VLRTOT")															//Total dos Serviços com o Total da Venda

Local nSpace  	:= 40           																			//Tamanho de espaco entre uma informacao e outra
Local cPicDefault	:= "@E 9,999,999.99"																		//Picture padrao para valores
Local aProducts	:= STIFinProd(aFinItens, nSpace)														//List de Produtos
Local aServices	:= {{},{}}																					//List de Serviços {{Informações Tela},{Informações Processamento}}
Local aResSFi		:= {{},{}}																					//Resumo de Pagamento {{Informações Tela},{Informações Processamento}}

/* Variaveis do objeto -> oLblProduct */
Local nPosAltTpLbl	:= oPanelMVC:nHeight * 0.030														//Posicao: Altura do ListBox
 
/* Variaveis do objeto -> oListProduct */
Local nPosAltListBox := oPanelMVC:nHeight * 0.046														//Posicao: Altura do ListBox
Local nTamAltListBox	:= oPanelMVC:nHeight * 0.08															//Tamanho: Altura do ListBox

/* Variaveis do objeto -> oGrpPaym */
Local nPosAltGroup	:= oPanelMVC:nHeight/4.807															//Posicao: Altura do GroupBox
Local nTamAltGroup	:= oPanelMVC:nHeight/3.9588															//Tamanho: Altura do GroupBox
Local nTamLarGroup	:= oPanelMVC:nWidth  * 0.485														//Tamanho: Lagura do GroupBox 

/* Variaveis do objeto -> oLblGroup1 */
Local nPosAltLb1		:= oPanelMVC:nHeight * 0.178														//Posicao: Altura do Label1 GroupBox 
Local nPosHozLb1		:= oPanelMVC:nWidth  * 0.140														//Posicao: Horizontal do Label1 GroupBox
	
/* Cria um bloco de codigo para ser utilizado na tela do cheque qdo for chamado pela condicao de pagamento */
Local nPosHozPan	:= oPanelMVC:nWidth/76.2            													//Posicao horizontal do painel
Local nPosAltPan	:= oPanService:nHeight/4.807        													//Posicao: Altura do Painel
Local nTamLagPan	:= oPanService:nWidth/2.09836       													//Tamanho: Largura do Painel
Local nTamAltPan	:= oPanService:nHeight/3.4512       													//Tamanho: Altura do Painel
Local bCreatePan	:= {||TPanel():New(nPosAltPan,nPosHozPan,"",oPanService;
						,,,,,,nTamLagPan,nTamAltPan)}   // Bloco de codigo para criacao do Painel adicional

Default	 aFinItens	:= {}
Default	 aCriticCli	:= {}

ParamType 0 Var   	aFinItens 		As Array	Default 	{}
ParamType 1 Var   	aCriticCli 		As Array	Default 	{}

/* Limpa as mensagens das etapas anteriores ao pagamento */
STFCleanInterfaceMessage()

/* Label: Serviços Financeiros */
oLblFinServ := TSay():New(POSVERT_CAB, POSHOR_1, {||STR0001}, oPanService,,,,,,.T.,,,nLargura,11.5) //"Serviços Financeiros"
oLblFinServ:SetCSS( POSCSS (GetClassName(oLblFinServ), CSS_BREADCUMB )) 

/* Label: Selecione o Produto */
oLblProduct := TSay():New(POSVERT_LABEL1*0.8100, POSHOR_1, {||STR0002}, oPanService,,,,,,.T.,,,nLargura,8) //"Selecione o Produto"
oLblProduct:SetCSS( POSCSS (GetClassName(oLblProduct), CSS_LABEL_FOCAL )) 
/* ListBox dos Produtos */
oListProduct := TListBox():Create(oPanService, POSVERT_GET1*0.8100, POSHOR_1, Nil, aProducts, nLargura, nTamAltListBox,,,,,.T.,, ;
				{||lListWhen := .T., lDisableBtn := .T., STIAtuServ(aFinItens,nSpace,oListProduct,aProducts,oListService,@aServices)} ;
				,,,,{||lListWhen == .T.})
oListProduct:SetCSS( POSCSS (GetClassName(oListProduct), CSS_LISTBOX )) 
oListProduct:Reset()
oListProduct:SetArray(aProducts)
 
/* Label: Escolha do Serviço */
oLblService := TSay():New(POSVERT_LABEL1*2.6000, POSHOR_1, {||STR0003}, oPanService,,,,,,.T.,,,nLargura,8) //"Selecione o Serviço Vinculado"
oLblService:SetCSS( POSCSS (GetClassName(oLblService), CSS_LABEL_FOCAL )) 
/* ListBox dos Serviços */
oListService := TListBox():Create(oPanService, POSVERT_GET1*2.0000, POSHOR_1, Nil, aServices[01], nLargura, nTamAltListBox,,,,,.T.,, ;
				{||lListWhen := .T., lDisableBtn := .T., STIAtuRes(aFinItens,nSpace,oListService,aServices,oListResSF,@aResSFi,@nLblTotSFi,@nLblTotGer)} ;
				,,,,{||lListWhen == .T.})
oListService:SetCSS( POSCSS (GetClassName(oListService), CSS_LISTBOX )) 
oListService:Reset()
oListService:SetArray(aServices[01])

/* Label: Resumo do Serviço financeiro */
oLblResSF := TSay():New(oPanelMVC:nHeight/3.7000, POSHOR_1, {||STR0004}, oPanService,,,,,,.T.,,,nLargura,8) //"Resumo do Serviço Financeiro" 
oLblResSF:SetCSS( POSCSS (GetClassName(oLblResSF), CSS_LABEL_FOCAL )) 

/* Label: Serviço */
oSayRes := TSay():New(oPanelMVC:nHeight/3.4000, POSHOR_1 * 01.0, {||STR0005}, oPanService,,,,,,.T.,,,nLargura,8) //"Produto"
oSayRes:SetCSS( POSCSS (GetClassName(oSayRes), CSS_LABEL_FOCAL ))
/* Label: Serviço */
oSayRes := TSay():New(oPanelMVC:nHeight/3.4000, POSHOR_1 * 09.0, {||STR0006}, oPanService,,,,,,.T.,,,nLargura,8) //"Serviço"
oSayRes:SetCSS( POSCSS (GetClassName(oSayRes), CSS_LABEL_FOCAL ))
/* Label: Valor */
oSayRes := TSay():New(oPanelMVC:nHeight/3.4000, POSHOR_1 * 18.0, {||STR0007}, oPanService,,,,,,.T.,,,nLargura,8) //"Valor"
oSayRes:SetCSS( POSCSS (GetClassName(oSayRes), CSS_LABEL_FOCAL ))

/* ListBox dos resumos dos serviços */
oListResSF := TListBox():Create(oPanService, oPanelMVC:nHeight/3.1400, POSHOR_1, Nil, aResSFi[01], nLargura*0.81, nTamAltListBox,,,,,.T.,, ;
				{||.T.} ;
				,,,,{||.T.})
oListResSF:SetCSS( POSCSS (GetClassName(oListResSF),CSS_LISTBOX )) 
oListResSF:Reset()
oListResSF:SetArray(aResSFi[01])

/* Label: Rodape dos Resumos */
oSayRes := TSay():New(oPanelMVC:nHeight/3.4000, POSHOR_BTNFOCAL*0.630,{||STR0008},oPanService,,,,,,.T.,,,,) //"VLR SERVIÇOS:"
oSayRes:SetCSS( POSCSS (GetClassName(oSayRes), CSS_LABEL_NORMAL ))
oLblTotSFi := TSay():New(oPanelMVC:nHeight/3.1700, POSHOR_BTNFOCAL*0.500,{||nLblTotSFi}, oPanService,cPicDefault,,,,,.T.,,,,)
oLblTotSFi:SetCSS( POSCSS (GetClassName(oLblTotSFi), CSS_LABEL_FOCAL)) 
oSayRes := TSay():New(oPanelMVC:nHeight/2.9000, POSHOR_BTNFOCAL*0.630,{||STR0009},oPanService,,,,,,.T.,,,,) //"TOTAL GERAL:"
oSayRes:SetCSS( POSCSS (GetClassName(oSayRes), CSS_LABEL_NORMAL))  
oLblTotGer  := TSay():New(oPanelMVC:nHeight/2.7000, POSHOR_BTNFOCAL*0.500,{||nLblTotGer}, oPanService,cPicDefault,,,,,.T.,,,,)
oLblTotGer:SetCSS( POSCSS (GetClassName(oLblTotGer), CSS_LABEL_FOCAL)) 

/* Button para prosseguir */
oButton := TButton():New(POSVERT_BTNFOCAL,POSHOR_BTNFOCAL,STR0010+CRLF+"(CTRL+F)",oPanService,{ || STIConfSF(aFinItens, aCriticCli, aResSFi) }, ; //"Finalizar Venda"
							LARGBTN,ALTURABTN,,,,.T.,,,,{||lDisableBtn})						
oButton:SetCSS( POSCSS (GetClassName(oButton), CSS_BTN_FOCAL )) 

/* Limpar Resumo */
oBtnLimpar := TButton():New(POSVERT_BTNFOCAL,POSHOR_1,STR0011+CRLF+"(CTRL+L)",oPanService,{ || STIZeraSF(oListResSF,@aResSFi,@nLblTotSFi,@nLblTotGer,oTotal) }, LARGBTN,ALTURABTN,,,,.T.,,,,{||lDisableBtn}) //"Limpar Escolhas"
oBtnLimpar:SetCSS( POSCSS (GetClassName(oBtnLimpar), CSS_BTN_ATIVO )) 

SetKey(06, {|| STIConfSF(aFinItens, aCriticCli, aResSFi) })
SetKey(12, {|| STIZeraSF(oListResSF,@aResSFi,@nLblTotSFi,@nLblTotGer,oTotal) })

/* Posiciona no primeiro registro e seta o focus */
oListProduct:GoTop()
oListProduct:SetFocus()

Return oPanService

//-------------------------------------------------------------------
/*/{Protheus.doc} STIZeraSF
Zera todos os Serviços Financeiros escolhidos

@param		oListResSF		- Objeto ListBox do Resumo
@param		aResSFi		- Array com conteudo de Resumos 	
@param		nLblTotSFi		- Total dos Serv. Financeiros selecionados
@param		nLblTotGer		- Total dos Serviços com o Total da Venda
@param		oTotal			- Objeto do total
@author  	Vendas & CRM
@version 	P12
@since   	11/07/2014
@return  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIZeraSF(oListResSF,aResSFi,nLblTotSFi,nLblTotGer,oTotal)

// Limpas as variáveis do Label
nLblTotSFi	:= 0
nLblTotGer	:= oTotal:GetValue("L1_VLRTOT")
aResSFi 	:= {{},{}}
oListResSF:Reset()
oListResSF:SetArray(aResSFi[01])
oListResSF:SetFocus()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} STIConfSF
Confirmacao dos pagamentos

@param1   	aFinItens		Array com os serviços financeiros da venda
@param2   	aCriticCli		Array que armazenara criticas cadastrais do cliente
@param3   	aResSFi			Array que contem itens financeiros vinculados
@author  	Vendas & CRM
@version 	P12
@since   	06/02/2013
@return  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIConfSF( aFinItens, aCriticCli, aResSFi )

Local lRet 			:= .T.				//Variavel de retorno
Local cValPre		:= STBGetVales()
Local lSTWNxtTelaIt	:= ExistFunc("STWNxtTelaIt")

Default aFinItens		:= {}
Default aCriticCli	:= {}
Default aResSFi		:= {{},{}}

ParamType 0 Var   	aFinItens 		As Array	Default 	{}
ParamType 1 Var   	aCriticCli 	As Array	Default 	{}
ParamType 2 Var   	aResSFi 		As Array	Default 	{{},{}}

/* Efetua validacao do cliente se foi selecionado item vinculado ou se possuir servico avulso */
If Len(aResSFi[1]) > 0 .OR. aScan(aFinItens,{|xVar| xVar[06] == 0 .AND. xVar[08] == .F.}) > 0
	STBVldClient(aFinItens, @aCriticCli)
EndIf

If Len(aCriticCli) > 0 	
	/* Servico Financeiro - Mensagens da validacao do cliente */
	STIExchangePanel({|| STIFinClient(aCriticCli,aResSFi)})
Else
	/* Se nao houverem criticas ao cliente chama tela Forma de Pagamento */
	//Se existir Itens serviços Vinculados selecionados, registro sem imprimir no cupom.
	If Len(aResSFi[1]) > 0
		STIRegServFin(aResSFi)
	EndIf
	
	IIf(lSTWNxtTelaIt,STWNxtTelaIt(),STICallPayment())		
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STIFinProd
Retorna os Produto do Array Financeiro

@param1   aFinItens				Array Financeiro
@param2   nSpace					Espaços entre strings
@author  Varejo
@version P11.8
@since   02/07/2014
@return  aRet						Array dos Produtos
@obs     
@sample
/*/
//-------------------------------------------------------------------

Static Function STIFinProd(aFinItens, nSpace)

Local aRet  		:= {}                      	// Array de retorno
Local nI			:= 0							// Variavel do Laço
Local nItemAnt	:= 0							// Item Anterior
Local aItensAux	:= aFinItens					// Array Auxiliar

Default aFinItens	:= {}
Default nSpace	:= 1

ParamType 0 Var   	aFinItens 		As Array		Default 	{}
ParamType 1 Var 		nSpace	 		As Numeric	   	Default 	1

//Ordernar do menor para o maior Item 
ASORT(aItensAux,,,{ | x,y | x[06] < y[06] } )

For nI := 1 To Len(aItensAux)
	
	If (aItensAux[nI][06] <> 0) .AND. !(aItensAux[nI][08]) //Se item não for avulso e não for deletado

		If nItemAnt <> aItensAux[nI][06]
			aAdd(	aRet,	STRZERO(aItensAux[nI][06],2)				+SPACE(nSpace-LEN(STRZERO(aItensAux[nI][06],2)))		+ ;
							AllTrim(aItensAux[nI][04]) 	 		   		+SPACE(nSpace-LEN(AllTrim(aItensAux[nI][04])))  		+ ;
				   			Upper(AllTrim(aItensAux[nI][05]))																		)
			nItemAnt := aItensAux[nI][06]
		EndIf

	EndIf
Next nI

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STIAtuServ
Retorna e atualiza os serviços do Array Financeiro

@param		aFinItens		- Array com conteudo de Produtos e Serviços da Venda
@param		nSpace			- Espaços entre strings
@param		oListProduct	- Objeto ListBox de Produtos
@param		aProducts		- Array com conteudo de Produtos
@param		oListService	- Objeto ListBox de Serviços
@param		aServices		- Array com conteudo de Serviços
@author  	Varejo
@version 	P11.8
@since   	02/07/2014
@return  	Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STIAtuServ(aFinItens,nSpace,oListProduct,aProducts,oListService,aServices)

Local cItemProd	:= AllTrim( SubStr(oListProduct:aItems[oListProduct:nAt],1				,(1*nSpace)) ) 		// Item Produto atual
Local cCodProd	:= AllTrim( SubStr(oListProduct:aItems[oListProduct:nAt],(1*nSpace)+1	,(1*nSpace)) ) 		// Codigo Produto atual
Local cDescProd	:= AllTrim( SubStr(oListProduct:aItems[oListProduct:nAt],(2*nSpace)+1	,(1*nSpace)) ) 		// Descrição Produto atual
Local nItemProd	:= VAL(cItemProd)																				 		// Item Produto atual
Local nFor			:= 0																									// Variavel de Laço
Local aItensAux	:= aFinItens																							// Array Auxiliar
Local oTotal	   	:= STFGetTot() 																						// Totalizador 
Local lDesconto	:= oTotal:GetValue("L1_DESCONT") > 0

//Valida se existe desconto na venda
If lDesconto
	STFMessage("STIFinService","STOP", "Não é possível inserir Servicos Financeiros pois venda possui desconto") 
	STFShowMessage("STIFinService")
EndIf

/* Valida quantidade do produto vendido */ 
If STBVldQtdProd(nItemProd) .And. !lDesconto
	// Limpas as variáveis do Label
	aServices := {{},{}}

	//Ordernar do menor para o maior Item 
	ASORT(aItensAux,,,{ | x,y | x[06] < y[06] } )

	For nFor := 1 To Len(aItensAux)
	
		If aItensAux[nFor][06] == nItemProd //Somente os itens do produto selecionado
			If (aItensAux[nFor][06] <> 0) .AND. !(aItensAux[nFor][08]) //Se item não for avulso e não for deletado
	
				aAdd(	aServices[01],AllTrim(SUBSTR(aItensAux[nFor][01] ,1,nSPACE-7))	+SPACE(nSpace-LEN(AllTrim(SUBSTR(aItensAux[nFor][01] ,1,nSPACE-7))))	+ ;
										AllTrim(SUBSTR(aItensAux[nFor][02] ,1,nSPACE-7))	+SPACE(nSpace-LEN(AllTrim(SUBSTR(aItensAux[nFor][02] ,1,nSPACE-7))))	+ ;
					   					Alltrim(Transform(aItensAux[nFor][03], PesqPict("MBL","MBL_VALOR") ) )								)
				aAdd(	aServices[02],aItensAux[nFor])
				
			EndIf
		EndIf
	
	Next nFor

	oListService:Reset()
	oListService:SetArray(aServices[01])
	oListService:SetFocus()
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} STIAtuRes
Retorna e atualiza os Resumos do Array Financeiro

@param		aFinItens		- Array com conteudo de Produtos e Serviços da Venda
@param		nSpace			- Espaços entre strings
@param		oListService	- Objeto ListBox de Serviços
@param		aServices		- Array com conteudo de Serviços
@param		oListResSF		- Objeto ListBox do Resumo
@param		aResSFi		- Array com conteudo de Resumos
@param		nLblTotSFi		- Total dos Serv. Financeiros selecionados
@param		nLblTotGer		- Total dos Serviços com o Total da Venda
@author  	Varejo
@version 	P11.8
@since   	02/07/2014
@return  	Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STIAtuRes(aFinItens,nSpace,oListService,aServices,oListResSF,aResSFi,nLblTotSFi,nLblTotGer)

Local nPos			:= oListService:nAt																					// Posição atual
Local aItensAux	:= aServices																							// Array Auxiliar
Local cDescProd	:= aItensAux[02][nPos][05]																			// Descrição Produto Vendido
Local cCodServ	:= AllTrim( SubStr(oListService:aItems[oListService:nAt],1				,(1*nSpace)) ) 		// Codigo Serviço atual
Local cDescServ	:= AllTrim( SubStr(oListService:aItems[oListService:nAt],(1*nSpace)+1	,(1*nSpace)) ) 		// Descrição Serviço atual
Local cValServ	:= AllTrim( SubStr(oListService:aItems[oListService:nAt],(2*nSpace)+1	,(1*nSpace)) ) 		// Valor Serviço atual

aAdd(	aResSFi[01],	SUBSTR(cDescProd				+SPACE(nSpace-LEN(AllTrim(cDescProd))),1,20)	+ ;
						SPACE(3)																			+ ;
						SUBSTR(cDescServ				+SPACE(nSpace-LEN(AllTrim(cDescServ))),1,20)	+ ;
						SPACE(10)																			+ ;
	   					cValServ																			)
aAdd(	aResSFi[02],aItensAux[02][nPos])

nLblTotSFi += Val(StrTran(StrTran(cValServ,",",""),".",""))/100
nLblTotGer += Val(StrTran(StrTran(cValServ,",",""),".",""))/100

oListResSF:Reset()
oListResSF:SetArray(aResSFi[01])
oListResSF:SetFocus()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} STIFinClient
Apresenta tela das validacoes do cliente quando Servico Financeiro.

@param		aFinItens		Array com os serviços financeiros da venda
@param		aResSFi		Array com conteudo de Resumos 	
@author	Varejo
@version	P11.8
@since		02/07/2014
@return	Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIFinClient(aCriticCli, aResSFi )

Local oPanelMVC		:= STIGetPanel()																//Painel do MVC	//Painel de botoes
Local oPanClient	:= TPanel():New(00,00,"",oPanelMVC,,,,,,oPanelMVC:nWidth/2,oPanelMVC:nHeight/2)	//Painel do pagamento
Local nAltura 		:= (oPanClient:nHeight / 2) * 0.20 		 										//Altura
Local nCol			:= (oPanClient:nWidth / 2)  * 0.03												//Coordenada horizontal
Local nLargura		:= (oPanClient:nWidth / 2) - (2 * nCol)											//Largura
Local oLblCliServ	:= Nil																			//Objeto de venda > pagamento
Local oLblClient	:= Nil																			//Label de pagamento
Local nSpace  		:= 25           																//Tamanho de espaco entre uma informacao e outra

/* Variaveis do objeto -> oListClient */
Local nTamAltListBox	:= oPanelMVC:nHeight * 0.30													//Tamanho: Altura do ListBox

Default aCriticCli	:= {}
Default aResSFi		:= {{},{}}

ParamType 0 Var aCriticCli	As Array  		Default {}
ParamType 1 Var aResSFi 		As Array  		Default {{},{}}

/* Limpa as mensagens das etapas anteriores ao pagamento */
STFCleanInterfaceMessage()

nAjustCols 	:= nLargura
oPanBkpSF	:= oPanClient

/* Label: VAlidacao Cliente */
oLblCliServ := TSay():New(POSVERT_CAB, POSHOR_1, {||STR0012}, oPanClient,,,,,,.T.,,,nLargura,11.5) //"Validação Cliente"
oLblCliServ:SetCSS( POSCSS (GetClassName(oLblCliServ), CSS_BREADCUMB )) 

/* ListBox de Inconsistencias do Cliente */
oListClient := TListBox():Create(oPanClient, POSVERT_GET1*0.8100, POSHOR_1, Nil, aCriticCli, nLargura, nTamAltListBox,,,,,.T.,,,,,,{|| .T.})
oListClient:SetCSS( POSCSS (GetClassName(oListClient), CSS_LISTBOX )) 
oListClient:Reset()
oListClient:SetArray(aCriticCli)
 
/* Button para prosseguir */
oButton := TButton():New(POSVERT_BTNFOCAL,POSHOR_BTNFOCAL,STR0010+CRLF+"(CTRL+F)",oPanClient,{ || STIConfClient(aResSFi) }, ; //"Finalizar Venda" 
							LARGBTN,ALTURABTN,,,,.T.,,,,{||lDisableBtn})
oButton:SetCSS( POSCSS (GetClassName(oButton), CSS_BTN_FOCAL )) 

SetKey(06, {|| STIConfClient(aResSFi) })
SetKey(12, Nil) 

Return oPanClient
	
//-------------------------------------------------------------------
/*/{Protheus.doc} STIConfClient
Confirmacao dos pagamentos

@param1		aResSFi		Array com conteudo de Resumos 	
@author  	Vendas & CRM
@version 	P12
@since   	06/02/2013
@return  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIConfClient( aResSFi )
Local lSTWNxtTelaIt	:= ExistFunc("STWNxtTelaIt")

Default aResSFi	:= {{},{}}

ParamType 0 Var aResSFi 		As Array  		Default {{},{}}

If STBPermUser()
	/* Se existir Itens serviços Vinculados selecionados, registro sem imprimir no cupom */
	If Len(aResSFi[1]) > 0
		STIRegServFin(aResSFi)
	EndIf
	
	IIf(lSTWNxtTelaIt,STWNxtTelaIt(),STICallPayment())	
EndIf
	
Return Nil	

//-------------------------------------------------------------------
/*/{Protheus.doc} STIRegServFin
Registra itens de serviços financeiros 

@param1		aResSFi		Array com conteudo de Resumos 	
@author  	Vendas & CRM
@version 	P12
@since   	06/02/2013
@return  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIRegServFin( aResSFi )

//Local lContinue	:= STBPermUser() 				//Flag continua venda
Local nFor			:= 0							//Controle de Laço
Local nItemLine	:= 0							//Item de Venda
Local cCliCode	:= STDGPBasket("SL1","L1_CLIENTE")
Local cCliLoja	:= STDGPBasket("SL1","L1_LOJA")
Local nMoeda		:= 1
Local cCliType	:= STDGPBasket("SL1","L1_TIPOCLI")
Local cCodItem	:= ""
Local lRegistred	:= .F.
Local cTesPad	:= ""

Default aResSFi	:= {{},{}}

ParamType 0 Var aResSFi 		As Array  		Default {{},{}}

/* Se Usuario tem permissao chama Condicao de Pagamento */
//If lContinue
	//Se existir Itens serviços Vinculados selecionados, registro sem imprimir no cupom.
	For nFor := 1 To Len(aResSFi[2])
		nItemLine := STDPBLength("SL2") + 1
		cCodItem  := aResSFi[02][nFor][01]
		/*/
			Registra Item
		/*/
		
		//Busca TES do Servico Financeiro
		MG8->(dbSetOrder(2))
		
		If MG8->(dbSeek(xFilial("MG8") + cCodItem))
			cTesPad := MG8->MG8_TESSB1
		EndIf
		
		lRegistred := STWItemReg( 	;	
						nItemLine		, ;		// Item
   						cCodItem		, ;		// Codigo Prod
   						cCliCode 		, ;		// Codigo Cli
   						cCliLoja		, ;		// Loja Cli
						nMoeda 			, ;		// Moeda
						Nil 			, ;		// Valor desconto
	 				 	Nil				, ;		// Tipo desconto ( Percentual ou Valor )
	 					Nil				, ;		// Item adicional?
  						cTesPad 		, ;		// TES
  						cCliType 		, ;		// Tipo do cliente (A1_TIPO)
  						.F. 			, ;		// Registra item no cupom fiscal?
  						aResSFi[02][nFor][03], ;// Preço
  						Nil				, ;		// Tipo do Item
  						Nil				, ;		// Imprime CNPJ no cupom Fiscal
  						Nil				, ;		// Tela do POS está sendo apresentada
  						Nil				, ;		// Total dos segundos entre itens
  						.T.				)		//Indica finalização dos serviços na Venda
				  	
  		If lRegistred
  			/* Atualiza campos controle Servicos Financeiros vinculados*/
  			STDUpdServFin(StrZero(aResSFi[02][nFor][06], TamSx3("L2_ITEM")[1]), aResSFi[02][nFor][04])   						
			  			 		  			  			  			
  			/* Seta objeto Servico Finaneiro como selecionado */
  			STWItemFin(	5 						,;	//Tipo do Processo (1=Set - 2=Get - 3=Clear - 4=Del - 5=Sel) 
						cCodItem				,;	//Codigo Servico Financeiro			
						aResSFi[02][nFor][03]	,; 	//Valor do Servico Financeiro					
						aResSFi[02][nFor][04]	,;	//Codigo Produto Vendido			
						aResSFi[02][nFor][06]	,; 	//Item Produto Vendido
						""						)	//Tipo Item - Usado para importacao de Orcamento	  			  			
  		EndIf
  	Next nFor

	STIGridCupRefresh() // Sincroniza a Cesta com a interface			
//EndIf
	
Return Nil	
