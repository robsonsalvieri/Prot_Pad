#Include 'Protheus.ch'
#INCLUDE "STPOS.CH"
#INCLUDE "POSCSS.CH"
#INCLUDE "STISUPPLYBLEEDING.CH"

#DEFINE TYPEOPERATION 		1        			// 01 - Tipo da rotina: (1) Sangria / Entrada de troco (2)
#DEFINE CASHIER_ORIGIN 		2         			// 02 - Codigo do caixa de origem
#DEFINE CASHIER_DESTINY 	3 	        		// 03 - Codigo do caixa de destino
#DEFINE VALUE_MONEY 		4 					// 04 - Valor em dinheiro
#DEFINE VALUE_CHECK  		5     				// 05 - Valor em cheque
#DEFINE VALUE_CREDITCARD	6       			// 06 - Valor em cartao de credito
#DEFINE VALUE_DEBITCARD 	7 					// 07 - Valor em cartao de debito
#DEFINE VALUE_FINANCED 		8    				// 08 - Valor em financiado
#DEFINE VALUE_COVENANT 		9         			// 09 - Valor em convenio
#DEFINE VALUE_COUPONS 		10 					// 10 - Valor em vales
#DEFINE VALUE_OTHERS 		11         			// 11 - Valor em outros
#DEFINE AGENCY    		   12         			// 12 - Numero da agencia  
#DEFINE DV_AGENC     		13         			// 13 - Digito da agencia   
#DEFINE ACCOUNT             14 					// 14 - Numero da conta   
#DEFINE DV_ACCOUNT          15 					// 15 - Digito da conta   
#DEFINE VALUE_PD 			16         			// 16 - Pagamento Digital
#DEFINE VALUE_PIX 			17         			// 17 - PIX

//-------------------------------------------------------------------
/*{Protheus.doc} STISupplyBleeding
Verifica se caixa existe(tratamento multi-moeda).
O portador do titulo(caixa) sera definido pela moeda

@param lOnlyMoney - Operacao apenas em dinheiro
@author  Varejo
@version P11.8
@since   23/07/2012
@return  lRet			Retorno se executou corretamente a funcao
@obs
@sample
/*/
//-------------------------------------------------------------------

Function STISupplyBleeding( cOption, lOnlyMoney )

Local nMV_LJ350MV := SuperGetMv("MV_LJ350MV",,.T.) // Na rotina de sangria de caixa, para habilitar os campos que permitirão edição. 1 = Apenas dinheiro; 2 = Todos

Default lOnlyMoney := .F. //Somente Dinheiro

IIF(nMV_LJ350MV == 1, lOnlyMoney := .T., )

If (STFProFile(5)[1])
	If cOption == "1" //Sangria
		STIExchangePanel( { || STIPanSupplyBleeding(lOnlyMoney) } )
	ElseIf cOption == "2"//Suprimento/Troco
		STIExchangePanel( { || STICashierSupply() } )
	EndIf
Else
	STFMessage(ProcName(),"STOP",STR0021) //"Usuario sem permissao para realizar Sangria / Entrada de Troco."
	STFShowMessage(ProcName())
EndIf

Return

//-------------------------------------------------------------------
/*{Protheus.doc} STIPanSupplyBleeding
Interface de sangria de suprimentos
@param lOnlyMoney - Sangria apenas em dinheiro
@author Vendas CRM
@since 26/04/2013
@version 11.80
@return oMainPanel - Objeto contendo o painel principal de selecao de clientes.
*/
//-------------------------------------------------------------------
Static Function STIPanSupplyBleeding(lOnlyMoney)
Local oPanelMVC		:= STIGetDlg()		//Painel principal do dialog
Local oMainPanel 	:= TPanel():New(00,00,"",oPanelMVC,,,,,,oPanelMVC:nWidth/2,(oPanelMVC:nHeight)/2) //Painel Abertura de Caixa

Local nLargGets		:= 160

Local oCab			:= Nil

Local oLblDestino	:= Nil
Local oLblBanco		:= Nil
Local oDestino		:= Nil

Local oLblDinheiro	:= Nil
Local oDinheiro		:= Nil
Local nDinheiro 	:= 0					//Alteracao do conteudo do get

Local oLblCheque	:= Nil
Local oCheque		:= Nil
Local nCheque 		:= 0					//Alteracao do conteudo do get

Local oLblCDebito	:= Nil
Local oCDebito		:= Nil
Local nCDebito 		:= 0					//Alteracao do conteudo do get

Local oLblCCredito	:= Nil
Local oCCredito		:= Nil
Local nCCredito 	:= 0					//Alteracao do conteudo do get

Local oLblFinanciado:= Nil
Local oFinanciado	:= Nil
Local nFinanciado 	:= 0					//Alteracao do conteudo do get

Local oLblConven	:= Nil
Local oConven		:= Nil
Local nConven 		:= 0					//Alteracao do conteudo do get

Local oLblVales		:= Nil
Local oVales		:= Nil
Local nVales 		:= 0					//Alteracao do conteudo do get

Local oLblOutros	:= Nil
Local oOutros		:= Nil
Local nOutros 		:= 0					//Alteracao do conteudo do get

Local oLblPD		:= Nil
Local oPD			:= Nil
Local nPD			:= 0
Local nPIX			:= 0

Local oBtnConfirm	:= Nil
Local oBtnCancel	:= Nil

Local aStation		:= STBInfoEst(	1, .T. )
Local cSeparator	:= ") "
Local aCaixas		:= STIGetSA6(aStation[1])
Local aAuxCaixas	:= {}
Local nX			:= 0
Local nTamSA6		:= 0							//Tamanho do codigo do caixa
Local cComboCx		:= "" 							//Variavel de combo de caixas

Local nVertCab		:= oPanelMVC:nHeight/81.3		// Posicao vertical do cabecalho
Local nVertLbl1		:= oPanelMVC:nHeight/23.228		// Posicao vertical dos label da linha 1
Local nVertLbl2		:= oPanelMVC:nHeight/18.228		// Posicao vertical dos label da linha 2
Local nVertLbl3		:= oPanelMVC:nHeight/9.0333		// Posicao vertical dos label da linha 3
Local nVertLbl4		:= oPanelMVC:nHeight/5.6068		// Posicao vertical dos label da linha 4
Local nVertLbl5		:= oPanelMVC:nHeight/4.065		// Posicao vertical dos label da linha 5
Local nVertLbl6		:= oPanelMVC:nHeight/3.18823	// Posicao vertical dos label da linha 6
Local nVertLbl7		:= oPanelMVC:nHeight/2.700		// Posicao vertical dos label da linha 6
Local nVertGet1		:= oPanelMVC:nHeight/14.781		// Posicao vertical dos get da linha 1
Local nVertGet2		:= oPanelMVC:nHeight/7.3909		// Posicao vertical dos get da linha 2
Local nVertGet3		:= oPanelMVC:nHeight/4.92727	// Posicao vertical dos get da linha 3
Local nVertGet4		:= oPanelMVC:nHeight/3.69545	// Posicao vertical dos get da linha 4
Local nVertGet5		:= oPanelMVC:nHeight/2.95636	// Posicao vertical dos get da linha 5
Local nVertGet6		:= oPanelMVC:nHeight/2.51782	// Posicao vertical dos get da linha 5
Local lAlterCx		:= !(SuperGetMv( "MV_LJALTCX",,.T.))
Local lMobile		:= STFGetCfg( "lMobile" , .F. )	// Versao mobile
Local nCaixas	:= 0
Local nRes := 0

Default lOnlyMoney := .F. //Somente Dinheiro

nRes			:= GetScreenRes()[1]	// Recupera Largura atual da tela
Do Case
	Case nRes <= 1023 
			nLargGets := 80
	Case  nRes <= 1679  
			nLargGets := 100
EndCase

lMobile := ValType(lMobile) == "L" .AND. lMobile

If Findfunction( 'STBCashList' )
   aAuxCaixas := STBCashList()
Else
	nTamSA6 :=  At("/", "MV_CXLOJA") -1 
	If nTamSA6 <= 0
		nTamSA6 := SA6->(TamSx3("A6_COD"))[1]
	EndIf
	
	cComboCx := Left(GetMv("MV_CXLOJA"),nTamSA6 )
	
	For nCaixas := 1 to len(aCaixas)
		AADD(aAuxCaixas,aCaixas[nCaixas][1][1])
	Next
EndIf

oMainPanel:SetCSS( POSCSS (GetClassName(oMainPanel), CSS_PANEL_CONTEXT ))

oCab	:= TSay():New(nVertCab,POSHOR_1,{||STR0001+aStation[1]},oMainPanel,,,,,,.T.,,,,) //"Sangria de Caixa | Caixa Origem: "
oCab:SetCSS( POSCSS (GetClassName(oCab), CSS_BREADCUMB )) 

oLblDestino:= TSay():New(nVertLbl1,POSHOR_1,{||STR0002},oMainPanel,,,,,,.T.,,,,) //"Caixa Destino"
oLblDestino:SetCSS( POSCSS (GetClassName(oLblDestino), CSS_LABEL_FOCAL )) 

oLblBanco:= TSay():New(nVertLbl2,POSHOR_1,{||STR0022},oMainPanel,,,,,,.T.,,,,)//"Codigo | Agencia | Dv. Agencia | Conta | DV. Conta"
oLblBanco:SetCSS( POSCSS (GetClassName(oLblDestino), CSS_LABEL_FOCAL )) 

oDestino := TComboBox():Create(oMainPanel, {|u| if( Pcount( )>0, cComboCx := u, cComboCx) },  nVertGet1, POSHOR_1, ;
									aAuxCaixas, nLargGets, ALTURAGET,,;
									,,,,;
									.T.,,,,;
									,,,,;
									,cComboCx)

oDestino:SetCSS( POSCSS (GetClassName(oDestino), IIF(lMobile ,CSS_COMBOBOX ,CSS_LISTBOX) )) 
oDestino:lReadOnly := lAlterCx

oLblDinheiro:= TSay():New(nVertLbl3,POSHOR_1,{||STR0003},oMainPanel,,,,,,.T.,,,,) ////"Dinheiro"
oLblDinheiro:SetCSS( POSCSS (GetClassName(oLblDinheiro), CSS_LABEL_FOCAL )) 

@ nVertGet2,POSHOR_1 MSGET oDinheiro  VAR nDinheiro  SIZE nLargGets,ALTURAGET PICTURE "@E 99,999,999.99" OF oMainPanel PIXEL
oDinheiro:SetCSS( POSCSS (GetClassName(oDinheiro), CSS_GET_FOCAL )) 
oDinheiro:lNoButton := .T. //nao mostra calculadora 

If !lOnlyMoney

	oLblCheque:= TSay():New(nVertLbl3,POSHOR_2,{||STR0004},oMainPanel,,,,,,.T.,,,,) //"Cheques"
	oLblCheque:SetCSS( POSCSS (GetClassName(oLblCheque), CSS_LABEL_FOCAL )) 

	@ nVertGet2,POSHOR_2 MSGET oCheque  VAR nCheque  SIZE nLargGets,ALTURAGET PICTURE "@E 99,999,999.99" OF oMainPanel PIXEL
	oCheque:SetCSS( POSCSS (GetClassName(oCheque), CSS_GET_FOCAL )) 

	oLblCDebito:= TSay():New(nVertLbl4,POSHOR_1,{||STR0005},oMainPanel,,,,,,.T.,,,,) //"Cartão Débito"
	oLblCDebito:SetCSS( POSCSS (GetClassName(oLblCDebito),CSS_LABEL_FOCAL)) 

	@ nVertGet3,POSHOR_1 MSGET oCDebito VAR nCDebito SIZE nLargGets,ALTURAGET PICTURE "@E 99,999,999.99" OF oMainPanel PIXEL
	oCDebito:SetCSS( POSCSS (GetClassName(oCDebito),CSS_GET_FOCAL)) 

	oLblCCredito:= TSay():New(nVertLbl4,POSHOR_2,{||STR0006},oMainPanel,,,,,,.T.,,,,) ////"Cartão Crédito"
	oLblCCredito:SetCSS( POSCSS (GetClassName(oLblCCredito),CSS_LABEL_FOCAL)) 

	@ nVertGet3,POSHOR_2 MSGET oCCredito VAR nCCredito SIZE nLargGets,ALTURAGET PICTURE "@E 99,999,999.99" OF oMainPanel PIXEL
	oCCredito:SetCSS( POSCSS (GetClassName(oCCredito), CSS_GET_FOCAL)) 

	oLblFinanciado:= TSay():New(nVertLbl5,POSHOR_1,{||STR0007},oMainPanel,,,,,,.T.,,,,) //"Financiado"
	oLblFinanciado:SetCSS( POSCSS (GetClassName(oLblFinanciado), CSS_LABEL_FOCAL)) 

	@ nVertGet4,POSHOR_1 MSGET oFinanciado  VAR nFinanciado  SIZE nLargGets,ALTURAGET PICTURE "@E 99,999,999.99" OF oMainPanel PIXEL
	oFinanciado:SetCSS( POSCSS (GetClassName(oFinanciado), CSS_GET_FOCAL)) 

	oLblConven:= TSay():New(nVertLbl5,POSHOR_2,{||STR0008},oMainPanel,,,,,,.T.,,,,) //"Convênio"
	oLblConven:SetCSS( POSCSS (GetClassName(oLblConven), CSS_LABEL_FOCAL)) 

	@ nVertGet4,POSHOR_2 MSGET oConven  VAR nConven  SIZE nLargGets,ALTURAGET PICTURE "@E 99,999,999.99" OF oMainPanel PIXEL
	oConven:SetCSS( POSCSS (GetClassName(oConven), CSS_GET_FOCAL)) 

	oLblVales:= TSay():New(nVertLbl6,POSHOR_1,{||STR0009},oMainPanel,,,,,,.T.,,,,) //"Vales"
	oLblVales:SetCSS( POSCSS (GetClassName(oLblVales), CSS_LABEL_FOCAL)) 

	@ nVertGet5,POSHOR_1 MSGET oVales VAR nVales SIZE nLargGets,ALTURAGET PICTURE "@E 99,999,999.99" OF oMainPanel PIXEL
	oVales:SetCSS( POSCSS (GetClassName(oVales), CSS_GET_FOCAL)) 

	oLblPD:= TSay():New(nVertLbl6,POSHOR_2,{||STR0023 },oMainPanel,,,,,,.T.,,,,) //"Pagamento Digital"
	oLblPD:SetCSS( POSCSS (GetClassName(oLblPD), CSS_LABEL_FOCAL)) 

	@ nVertGet5,POSHOR_2 MSGET oPD VAR nPD SIZE nLargGets,ALTURAGET PICTURE "@E 99,999,999.99" OF oMainPanel PIXEL
	oPD:SetCSS( POSCSS (GetClassName(oPD), CSS_GET_FOCAL)) 

	oLblPIX:= TSay():New(nVertLbl7,POSHOR_1,{||STR0024},oMainPanel,,,,,,.T.,,,,) //"PIX"
	oLblPIX:SetCSS( POSCSS (GetClassName(oLblPD), CSS_LABEL_FOCAL)) 

	@ nVertGet6,POSHOR_1 MSGET oPIX VAR nPIX SIZE nLargGets,ALTURAGET PICTURE "@E 99,999,999.99" OF oMainPanel PIXEL
	oPIX:SetCSS( POSCSS (GetClassName(oPIX), CSS_GET_FOCAL)) 

	oLblOutros:= TSay():New(nVertLbl7,POSHOR_2,{||STR0010},oMainPanel,,,,,,.T.,,,,) //"Outros"
	oLblOutros:SetCSS( POSCSS (GetClassName(oLblOutros), CSS_LABEL_FOCAL)) 

	@ nVertGet6,POSHOR_2 MSGET oOutros VAR nOutros SIZE nLargGets,ALTURAGET PICTURE "@E 99,999,999.99" OF oMainPanel PIXEL
	oOutros:SetCSS( POSCSS (GetClassName(oOutros), CSS_GET_FOCAL)) 

EndIf

oBtnConfirm	:= TButton():New(	POSVERT_BTNFOCAL,;
							POSHOR_BTNFOCAL	,;
							STR0011,;    //"Confirmar"
							oMainPanel	,;
							{|| STIConfirmBleeding(1,cComboCx,nDinheiro, nCheque, nCDebito, nCCredito,nFinanciado,nConven,nVales,nOutros,aCaixas,nPD,nPIX, oMainPanel)},;
							LARGBTN			,;
							ALTURABTN		,;
							,,,.T.,;
							,,,{|| !Empty(cComboCx)})

oBtnCancel := TButton():New(	POSVERT_BTNFOCAL,POSHOR_1,STR0020,oMainPanel,{ || Iif(ExistFunc("StiMataObj"),StiMataObj(oMainPanel),Nil), IIf(STBOpenCash(), STIRegItemInterface(), STIExchangePanel( { || STIPanOpenCash() } )) }, ; //"Cancelar"
								LARGBTN,ALTURABTN,,,,.T.	)

						
oBtnConfirm:SetCSS( POSCSS (GetClassName(oBtnConfirm), CSS_BTN_FOCAL)) 
							
oBtnCancel:SetCSS( POSCSS (GetClassName(oBtnCancel), CSS_BTN_NORMAL)) 

oDestino:SetFocus()

Return(oMainPanel)

//-------------------------------------------------------------------
/*{Protheus.doc} STIPanSupplyBleeding
Interface de suprimentacao de caixa

@author Vendas CRM
@since 26/04/2013
@version 11.80
@return oMainPanel - Objeto contendo o painel principal de selecao de clientes.
*/
//-------------------------------------------------------------------

Static Function STICashierSupply()
Local oPanelMVC		:= STIGetDlg()		//Painel principal do dialog
Local oMainPanel 	:= TPanel():New(00,00,"",oPanelMVC,,,,,,oPanelMVC:nWidth/2,(oPanelMVC:nHeight)/2) //Painel Abertura de Caixa

Local nLargGets		:= 90

Local oCab			:= Nil

Local oLblOrigem	:= Nil
Local oOrigem		:= Nil

Local oLblDinheiro	:= Nil
Local oDinheiro		:= Nil
Local nDinheiro 	:= 0					//Alteracao do conteudo do get

Local aStation		:= STBInfoEst(	1, .T. )
Local cSeparator	:= ") "
Local aCaixas		:= STIGetSA6(aStation[1])
Local aAuxCaixas	:= {}
Local nX			:= 0

Local oBtnConfirm	:= Nil
Local oBtnCancel	:= Nil
Local nTamSA6		:= 0	
Local cComboCx		:= "" 
Local lMobile		:= STFGetCfg( "lMobile" , .F. )	//versao mobile
Local lAlterCx		:= SuperGetMv("MV_LJALTCX",,.T.) //permite ou não a seleção do caixa de origem do suprimento de caixa.


Local nCaixas 		:= 0
lMobile := ValType(lMobile) == "L" .AND. lMobile

If Findfunction( 'STBCashList' )
   aAuxCaixas := STBCashList()
Else      
	nTamSA6 :=  At("/", "MV_CXLOJA") -1 
	If nTamSA6 <= 0
		nTamSA6 := SA6->(TamSx3("A6_COD"))[1]
	EndIf
	
	cComboCx := Left(GetMv("MV_CXLOJA"),nTamSA6 )
	
	For nCaixas := 1 to len(aCaixas)
		AADD(aAuxCaixas,aCaixas[nCaixas][1][1])
	Next
EndIf

oMainPanel:SetCSS( POSCSS (GetClassName(oMainPanel), CSS_PANEL_CONTEXT ))

oCab	:= TSay():New(10,POSHOR_1,{||STR0012+aStation[1]},oMainPanel,,,,,,.T.,,,,) //"Suprimento de Caixa | Caixa Destino: "
oCab:SetCSS( POSCSS (GetClassName(oCab), CSS_BREADCUMB)) 

oLblOrigem:= TSay():New(35,POSHOR_1,{||STR0013},oMainPanel,,,,,,.T.,,,,)  //"Caixa Origem"
oLblOrigem:SetCSS( POSCSS (GetClassName(oLblOrigem), CSS_LABEL_FOCAL)) 

oOrigem := TComboBox():Create(oMainPanel, {|u| if( Pcount( )>0, cComboCx := u, cComboCx) },  55, POSHOR_1, ;
									aAuxCaixas, nLargGets, ALTURAGET,,;
									,,,,;
									.T.,,,,;
									,,,,;
									,cComboCx)
oOrigem:SetCSS( POSCSS (GetClassName(oOrigem), IIF(lMobile ,CSS_COMBOBOX ,CSS_LISTBOX) )) 
oOrigem:lReadOnly := !lAlterCx	


oLblDinheiro:= TSay():New(90,POSHOR_1,{||STR0014},oMainPanel,,,,,,.T.,,,,)  //"Dinheiro"
oLblDinheiro:SetCSS( POSCSS (GetClassName(oLblDinheiro), CSS_LABEL_FOCAL)) 

@ 110,POSHOR_1 MSGET oDinheiro  VAR nDinheiro  SIZE nLargGets,ALTURAGET PICTURE "@E 99,999,999.99" OF oMainPanel PIXEL
oDinheiro:SetCSS( POSCSS (GetClassName(oDinheiro), CSS_GET_FOCAL)) 
oDinheiro:lNoButton := .T. //nao mostra calculadora 

oBtnConfirm	:= TButton():New(	POSVERT_BTNFOCAL,;
							POSHOR_BTNFOCAL	,;
							STR0011,;  //"Confirmar"
							oMainPanel	,;
							{|| STIConfirmBleeding(2,cComboCx,nDinheiro,,,,,,,,aCaixas,,,oMainPanel)},;
							LARGBTN			,;
							ALTURABTN		,;
							,,,.T.,;
							,,,{|| !Empty(cComboCx)})
							
oBtnCancel := TButton():New(	POSVERT_BTNFOCAL,POSHOR_1,STR0020,oMainPanel,{ || IIf(STBOpenCash(),STIRegItemInterface(),STIExchangePanel( { || STIPanOpenCash() } )), Iif(ExistFunc("STIMataObj"),STIMataObj(oMainPanel),Nil) }, ; //"Cancelar"
								LARGBTN,ALTURABTN,,,,.T.	)
							
oBtnConfirm:SetCSS( POSCSS (GetClassName(oBtnConfirm), CSS_BTN_FOCAL)) 
oBtnCancel:SetCSS( POSCSS (GetClassName(oBtnCancel),CSS_BTN_NORMAL)) 

oOrigem:SetFocus()

Return oMainPanel

//-------------------------------------------------------------------
/*{Protheus.doc} STIConfirmBleeding
Funcao responsavel pela criacao do Painel de selecao de clientes.

@author Vendas CRM
@since 26/04/2013
@version 11.80
@return oMainPanel - Objeto contendo o painel principal de selecao de clientes.
*/
//-------------------------------------------------------------------

Static Function STIConfirmBleeding(nOpc,cCaixa,nDinheiro, nCheque, nCDebito, nCCredito,nFinanciado,nConven,nVales,nOutros,aCaixas,nPD,nPIX, oMainPanel)
Local nCurrency		:= STBGetCurrency()
Local aValues		:= Array(17)
Local lRet			:= .T.
Local aStation		:= STBInfoEst(	1, .T. )
local nCaixas		:= 0				//Variavel de loop
Local cAgencia 		:= ""				//Variavel que armazena a Agencia recebita pelo aCaixas
Local cDvage		:= ""				//Variavel que armazena o Digito da agencia recebita pelo aCaixas
Local cConta		:= ""				//Variavel que armazena a Conta recebita pelo aCaixas
Local cDvConta		:= ""				//Variavel que armazena o Digito da conta recebita pelo aCaixas

DEFAULT nCheque		:= 0
DEFAULT nCDebito	:= 0
DEFAULT nCCredito	:= 0
DEFAULT nFinanciado	:= 0
DEFAULT nConven		:= 0
DEFAULT nVales		:= 0
DEFAULT nOutros		:= 0
Default aCaixas 	:= {}
Default nPD			:= 0
Default nPIX		:= 0
Default oMainPanel	:= Nil 

If !Empty(cCaixa)
	
	For nCaixas :=  1 to len(aCaixas)
		If AllTrim(cCaixa) == AllTrim(aCaixas[nCaixas][1][1])
			cAgencia := aCaixas[nCaixas][2][1]
			cDvage	 := aCaixas[nCaixas][2][2]
			cConta   := aCaixas[nCaixas][2][3]
			cDvConta := aCaixas[nCaixas][2][4]
			Exit
		EndIf
	Next

	cCaixa := SubSTR(cCaixa,1,TamSX3("A6_COD")[1])//Extraio apenas o A6_COD
	
	If AllTrim(Upper(cCaixa)) <> AllTrim(Upper(aStation[1]))
		aValues[TYPEOPERATION]		:= nOpc
		aValues[VALUE_MONEY]		:= nDinheiro
		If nOpc == 1
			aValues[CASHIER_ORIGIN]		:= aStation[1]
			aValues[CASHIER_DESTINY]	:= cCaixa
			aValues[VALUE_CHECK]		:= nCheque
			aValues[VALUE_CREDITCARD]	:= nCCredito
			aValues[VALUE_DEBITCARD]	:= nCDebito
			aValues[VALUE_FINANCED]		:= nFinanciado
			aValues[VALUE_COVENANT]		:= nConven
			aValues[VALUE_COUPONS]		:= nVales
			aValues[VALUE_OTHERS]		:= nOutros
			aValues[VALUE_PD]			:= nPd
			aValues[VALUE_PIX]			:= nPIX
		ElseIf nOpc == 2
			aValues[CASHIER_ORIGIN]		:= cCaixa
			aValues[CASHIER_DESTINY]	:= aStation[1]
		EndIf
		
		aValues[AGENCY] 	:= cAgencia
		aValues[DV_AGENCY]	:= cDvage
		aValues[ACCOUNT]	:= cConta
		aValues[DV_ACCOUNT]	:= cDvConta
				
		lRet := STWSupplyBleeding( nOpc , aValues , nCurrency )

		If lRet
			If nOpc == 1
				STFMessage(ProcName(),"STOP",STR0015) //"Sangria realizada com sucesso"
			ElseIf nOpc == 2
				STFMessage(ProcName(),"STOP",STR0016) //"Suprimentação de caixa realizada com sucesso"
			EndIf
		Else
			STFMessage(ProcName(),"STOP",STR0017) //"Não foi possivel realizar a operação"
		EndIf
	Else
		lRet := .F.
		STFMessage(ProcName(),"STOP",STR0018) //"O caixa destino e origem são iguais!"
	EndIf
Else
	lRet := .F.
	STFMessage(ProcName(),"STOP",STR0019) //"Informe o caixa destino!"
EndIf

STFShowMessage(ProcName())

If lRet 
	Iif(ExistFunc("StiMataObj"),StiMataObj(oMainPanel),Nil)
	STIRegItemInterface()
EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} STIGetSA6
Retorna todos os caixas cadastrados na SA6, com exceçao do caixa que esta sendo utilizado.

@param cUsedCashier	- Caixa atual.
@author Vendas CRM
@since 26/04/2013
@version 11.80
@return aRet - Array que contem os codigos dos caixas que podem ser utilizados.
*/
//-------------------------------------------------------------------

Function STIGetSA6(cUsedCashier)
Local aArea 	:= GetArea()
Local aRet		:= {}
Local cCxFil	:= xFilial("SA6")

DEFAULT cUsedCashier := ""

DbSelectArea("SA6")
SA6->(DbSetOrder(1))
SA6->(DbGoTop())

While SA6->(!EOF())

	If AllTrim(SA6->A6_COD) <> AllTrim(cUsedCashier) .AND. SA6->A6_FILIAL == cCxFil
		Aadd(aRet,{{SA6->A6_COD + " | " + SA6->A6_AGENCIA + " | " + SA6->A6_DVAGE + " | " + SA6->A6_NUMCON + " | " + SA6->A6_DVCTA},{SA6->A6_AGENCIA,SA6->A6_DVAGE,SA6->A6_NUMCON,SA6->A6_DVCTA}})
	EndIf

	SA6->(DbSkip())
End

RestArea(aArea)

Return aRet



