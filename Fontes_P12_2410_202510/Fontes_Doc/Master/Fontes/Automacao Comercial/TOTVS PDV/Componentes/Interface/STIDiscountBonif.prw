#INCLUDE "Protheus.ch"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "POSCSS.CH"  
#INCLUDE "STPOS.CH"
#INCLUDE "StiDiscountBonif.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} STIDscBonf()
Interface para decisão: a)Bonificação, b)Desconto.
Isto ocorrerá quando escolheu bonificação e desct total ao mesmo tempo.
OBS: Entrará somente se Regra de Desconto validada anteriormente.
@type function

@author Marisa V. N. Cruz
@since 18/12/2019
@version P12

@param nil

@return oPanBonif {Objeto para retorno em STIExchangePanel}
/*/
//-------------------------------------------------------------------
Function STIDscBonf()

Local oPanelMVC  		:= STIGetPanel()				// Objeto do Panel onde a interface de selecao de clientes sera criada

Local oLblAviso		:= Nil              //Objeto de Label Aviso
Local oLblDescri	:= Nil              //Objeto de Label Descrição
Local oLblBonif		:= Nil              //Objeto de Label Bonificação
Local oGetBonif		:= Nil              //Objeto de Get Bonificação
Local oLblDesc		:= Nil              //Objeto de Label Desconto
Local oGetDesc		:= Nil              //Objeto de Get Desconto

Local oBtnBonif		:= Nil               //Objeto do botao Ok
Local oBtnDesc		:= Nil               //Objeto do botao Cancelar

Local oTotal        := STFGetTot()      // Recebe o Objeto totalizador
Local nBonif		:= 0				//Valor Bonificação
Local nDesconto		:= 0				//Valor Desconto

oPanBonif		:= TPanel():New(00,00,"",oPanelMVC,,,,,,oPanelMVC:nWidth/2,oPanelMVC:nHeight/2) 	//Painel do pagamento
nAltura			:= (oPanBonif:nHeight / 2) * 0.20 		 										//Altura
nCol			:= (oPanBonif:nWidth / 2) * 0.03													//Coordenada horizontal
nLargura		:= (oPanBonif:nWidth / 2) - (2 * nCol)											//Largura

nPosHozPan		:= oPanelMVC:nWidth/76.2            							//Posicao horizontal do painel
nPosAltPan		:= oPanBonif:nHeight/4.807        							//Posicao: Altura do Painel
nTamLagPan		:= oPanBonif:nWidth/2.09836       							//Tamanho: Largura do Painel
nTamAltPan		:= oPanBonif:nHeight/3.4512       							//Tamanho: Altura do Painel
bCreatePan		:= {||TPanel():New(nPosAltPan,nPosHozPan,"",oPanBonif;
												,,,,,,nTamLagPan,nTamAltPan)}   // Bloco de codigo para criacao do Painel adicional

If GetAPOInfo("STFTOTALUPDATE.PRW")[4] >= Ctod("19/12/2019")
	nBonif			:= oTotal:GetValue("L1_BONIF")		//Valor Bonificação
EndIf
nDesconto		:= oTotal:GetValue("L1_DESCONT")	//Valor Desconto

/* Label: Aviso */
oLblAviso := TSay():New(POSVERT_CAB, POSHOR_1, {|| STR0001}, oPanBonif,,,,,,.T.,,,nLargura,11.5) //"Atenção!"
oLblAviso:SetCSS( POSCSS (GetClassName(oLblAviso), CSS_BREADCUMB )) 

/* Label: Descrição do aviso */
oLblDescri := TSay():New(POSVERT_LABEL1	, POSHOR_1, {|| STR0002 + " " + STR0003}, oPanBonif,,,,,,.T.,,,nLargura,40) //"Foi identificado que existe desconto e bonificação nesta venda."###"Escolha apenas uma das opções a ser aplicada:"
oLblDescri:SetCSS( POSCSS (GetClassName(oLblDescri), CSS_LABEL_FOCAL )) 

 /* Label e Get: Bonificação/Desconto */
oLblBonif := TSay():New(POSVERT_LABEL3-20, POSHOR_1, {|| STR0004 + "R$ " + Alltrim(Transform( nBonif, "@E 999999.99"))}, oPanBonif,, ,,,,.T.,,,nLargura,25) //"Bonificação: "
oLblBonif:SetCSS( POSCSS (GetClassName(oLblBonif), CSS_LABEL_ALERT ))

oLblDesc := TSay():New(POSVERT_LABEL3, POSHOR_1, {|| STR0005 + "R$ " + Alltrim(Transform( nDesconto, "@E 999999.99"))}, oPanBonif,, ,,,,.T.,,,nLargura,25) //"Desconto:"
oLblDesc:SetCSS( POSCSS (GetClassName(oLblDesc), CSS_LABEL_ALERT ))

/* Button: Bonificação */
oBtnBonif := TButton():New(POSVERT_BTNFOCAL,POSHOR_BTNFOCAL,STR0006+CRLF+"(Ctrl+B)",oPanBonif,{|| STIOkBonif()},LARGBTN,ALTURABTN,,,,.T.) //"Bonificação" 

/* Button: Desconto */
oBtnDesc	:= TButton():New(POSVERT_BTNFOCAL,POSHOR_BTNFOCAL-90,STR0007+CRLF+"(Ctrl+D)",oPanBonif,{|| STIOkDisc() },LARGBTN,ALTURABTN,,,,.T.) //"Desconto"

oBtnBonif:SetCSS( POSCSS (GetClassName(oBtnBonif), CSS_BTN_FOCAL ))
oBtnDesc:SetCSS( POSCSS (GetClassName(oBtnDesc), CSS_BTN_FOCAL )) 

SetKey(2, {|| STIOkBonif("Atalho")})		//Ativo CTRL+B
SetKey(4, {|| STIOkDisc("Atalho")})			//Ativo CTRL+D
LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), STR0002 )
LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), STR0003 )
LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), STR0004 + " Valor: " + Str(nBonif) )
LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), STR0005 + " Valor: " + Str(nDesconto) )

oBtnBonif:SetFocus()

Return oPanBonif


//-------------------------------------------------------------------
/*/{Protheus.doc} STIOkBonif()
Escolhido Bonificação, deixando de escolher o Desconto Total.
Ocorre após Interface para decisão: a)Bonificação, b)Desconto em STIDscBonif()
e escolheu a opção A.
@type function

@author Marisa V. N. Cruz
@since 18/12/2019
@version P12

@param nil

@return nil
/*/
//-------------------------------------------------------------------
Function STIOkBonif()

LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "Opção escolhida: Bonificação" )

SetKey(2, Nil)				//Desativo CTRL+B
SetKey(4, Nil)				//Desativo CTRL+D

STIClearDisc(.T.)			//Anulo desconto
STIExchPay()

Return nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STIOkDisc()
Escolhido Desconto, deixando de escolher a Bonificação.
Ocorre após Interface para decisão: a)Bonificação, b)Desconto em STIDscBonif()
e escolheu a opção B.
@type function

@author Marisa V. N. Cruz
@since 18/12/2019
@version P12

@param nil

@return nil
/*/
//-------------------------------------------------------------------
Function STIOkDisc()

LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "Opção escolhida: Desconto" )

SetKey(2, Nil)				//Desativo CTRL+B
SetKey(4, Nil)				//Desativo CTRL+D

If GetAPOInfo("STFTOTALUPDATE.PRW")[4] >= Ctod("19/12/2019")
	STFSetTot( "L1_BONIF", 0 )	//Anulo bonificação
EndIf			
STIExchPay()

Return nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STIExchPay()
Chamo direto o STIPayment()
Caso ocorra bonificação e desconto ao mesmo tempo, eu chamo a Tela de NCC - o STINCCSelection() antes.
@type function

@author Marisa V. N. Cruz
@since 18/12/2019
@version P12

@param nil

@return nil
/*/
//-------------------------------------------------------------------
Function STIExchPay()
Local aNCCs 		:= STDGetNCCs("1")

If Len(aNCCs) > 0
	//Carrego a tela de NCC
	STIExchangePanel( { || STINCCSelection() } )
Else
	//Carrego os paineis para os demais pagamentos
	STIExchangePanel( { || STIPayment() } )
EndIf

Return nil