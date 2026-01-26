#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH" 
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "POSCSS.CH"     
#INCLUDE "STPOS.CH"
#INCLUDE "STIPAYMULTINEG.CH"

Static oMultNegoc		:= NIL					//Objeto de integraÁ„o da MultinegociaÁ„o
Static aItens 			:= {}					//Array com os itens da venda
Static aRules  			:= {}					//Array com as Regras de Multi NegociaÁ„o
Static nSaleVal	   		:= 0					//Carrega o valor da Venda
Static aPayForms    	:= {}					//Array com formas de pagamentos da Regra de Multi NegociaÁ„o
Static aBrwContent 		:= {}			  		//Conteudo do Browse da Direita
Static oBrwContent 		:= Nil  		       	//Objeto do Browse da Direita
Static aParcels	   		:= {} 					//Array com conteudo das parcelas de negociacao
Static cPicDefault		:= "@E 9,999,999.99"	//Picture padrao para valores
Static nValorBonif      := 0
Static lmultineg		:= .F.					//Verifica se teve desconto na multinegociaÁ„o
Static oTefMultNeg		:= Nil					//Forma de pagamento contida na multinegociacao
Static lvalidneg 		:= .F.					//Valida se teve transacao tef na multinegocicao
Static lMultNeg			:= .F.					//Indica se a venda foi paga com multinegociacao 
Static oPanelAdcMult	:= Nil 					// Objeto proveniente do opnlAdiconal do StiPayment

#DEFINE POS_TIPO		1						// Tipo
#DEFINE POS_QTDPARC	 	2						// Quantidade de Parcelas
#DEFINE POS_VLRPARC		3						// Valor Parcela
#DEFINE POS_VLRTOT 		4						// Valor Total
#DEFINE POS_VLRVEN 		5						// Valor atÈ Vencimento
#DEFINE POS_ACRESC 		6						// Acrescimo
#DEFINE POS_VENCIM 		7						// Data Vencimento

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIPnlMulti
Cria os objeto da tela principal

@param   	o - Objeto do painel Principal
@author		Varejo
@version	P12
@since		23/09/2013
@return		oContent
@obs
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Function STIPnlMulti( o )
 
@ 000,000 BITMAP oPanelAdcMult RESOURCE "x.png" NOBORDER SIZE 000,000 OF o ADJUST PIXEL
oPanelAdcMult:Align := CONTROL_ALIGN_ALLCLIENT
oPanelAdcMult:ReadClientCoors(.T.,.T.)

STIMultiNeg(oPanelAdcMult)

Return oPanelAdcMult

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIMultiNeg
Cria os objetos principais da tela

@param   	oPanel - Objeto do painel Principal
@author		Varejo
@version	P12
@since		23/09/2013
@return		NIL
@obs
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Static Function STIMultiNeg( oPanel )

Local oPanelMVC	:= NIL						//Painel de Fundo
Local oPanel1	:= NIL 						//Painel da Esquerda
Local oPanel2	:= NIL						//Painel da Direita
Local oPanel3	:= NIL						//Painel do Rodape
Local nLargura	:= oPanel:nWidth/2			//Largura padr„o dos paineis
Local nAltura	:= oPanel:nHeight/2			//Altura padr„o dos paineis

Default oPanel		:= Nil

If oPanel <> Nil
	//Fundo
	oPanelMVC := TPanel():New(00,00,"",oPanel,,,,,,nLargura,nAltura)
	oPanelMVC:Align := CONTROL_ALIGN_ALLCLIENT
	oPanelMVC:SetCSS( POSCSS (GetClassName(oPanelMVC), CSS_PANEL_CONTEXT )) 
	//Esquerda
	oPanel1	:= TPanel():New(00,00,"",oPanelMVC,,,,,,nLargura/2,nAltura)
	oPanel1:Align := CONTROL_ALIGN_LEFT
	oPanel1:SetCSS( POSCSS (GetClassName(oPanel1), CSS_PANEL_CONTEXT )) 
	//Direita
	oPanel2	:= TPanel():New(00,00,"",oPanelMVC,,,,,,nLargura/2,nAltura)
	oPanel2:Align := CONTROL_ALIGN_RIGHT
	oPanel2:SetCSS( POSCSS (GetClassName(oPanel2), CSS_PANEL_CONTEXT )) 
	//Rodape
	oPanel3	:= TPanel():New(00,00,"",oPanelMVC,,,,,,nLargura,nAltura/4.8)
	oPanel3:Align := CONTROL_ALIGN_BOTTOM
	oPanel3:SetCSS( POSCSS (GetClassName(oPanel3), CSS_PANEL_CONTEXT )) 
	
	STIPayMultiNeg(oPanel1,oPanel2,oPanel3)
	
EndIf

Return NIL

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIPayMultiNeg
Multi-NegociaÁ„o

@param   	oPnlAdconal - Objeto do painel adicional da Esquerda
@param   	oPnlAdconal - Objeto do painel adicional da Direita
@param   	oPnlAdconal - Objeto do painel adicional do Rodape
@author  	Varejo
@version 	P12
@since   	23/09/2013
@return  	oMainPanel
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Function STIPayMultiNeg(oPnlAdconal,oPnlRight,oPnlRodape)

Local oPanelMVC		:= oPnlAdconal   			   														//Painel principal do dialog
Local oMainPanel 	:= TPanel():New(00,00,"",oPanelMVC,,,,,,oPanelMVC:nWidth/2,(oPanelMVC:nHeight)/2)	//Painel de MultiNegociacao
Local oLblMulti		:= NIL																				//Objeto Label da Multi Negociacao
Local nSpace  		:= 25           																	//Tamanho de espaco entre uma informacao e outra

Local nAltura 		:= (oMainPanel:nHeight / 2) * 0.20 		//Altura
Local nCol			:= (oMainPanel:nWidth / 2) * 0.03		 	//Coordenada horizontal
Local nLargura		:= (oMainPanel:nWidth / 2) - (2 * nCol)	//Largura
Local nPosAltGroup	:= oPanelMVC:nHeight					  	//Posicao: Altura do GroupBox
Local nTamAltGroup	:= oPanelMVC:nHeight						//Tamanho: Altura do GroupBox
Local nTamLarGroup	:= (oPanelMVC:nWidth) * 0.485				//Tamanho: Lagura do GroupBox 
Local nTop 			:= POSVERT_GET1+65							//Valor do Top
Local nLeft 		:= 000										//Valor do Left
Local PosVerPay		:= POSHOR_1+20
Local nPosVerTit 	:= nPosAltGroup/20.500 						//Posicao inicial do titulo do painel da Esquerda para Direita
Local nPosVerGrp 	:= nPosAltGroup/12.500 			   			//Posicao inicial do Grupo do painel da Esquerda para Direita

/* Variaveis do objeto -> Regra */
Local oGrpRule	   		:= Nil 									//Objeto groupbox
Local oLblRules 		:= Nil             						//Objeto de Label Regra
Local oGetRules 		:= Nil              					//Objeto de Get Regra
Local cGetRules	   		:= ""									//Correspondente a regra
Local cCodAdmFin		:= ""									//Correspondente ao codigo da Adm. Financeira

/* Variaveis do objeto -> Formas de Pagamento */
Local oGrpPayForms 		:= Nil 									//Objeto groupbox
Local oLblPayForms		:= Nil									//Objeto de venda > Multi Negociacao
Local lLstPayForms		:= .T.		   							//Indica se o listbox de selecao de pagamento È editavel
Local oSayPayForms		:= Nil									//Objetos Label da Forma de Pagamento
Local oLblType			:= Nil									//Label do Tipo da Forma de Pagamento
Local oLblAdmFin		:= Nil									//Label da Adm. Financeira da Forma de Pagamento
Local oLblParc			:= Nil									//Label do Range de Parcelas da Forma de Pagamento
Local oLblRate			:= Nil									//Label dos Juros da Forma de Pagamento
Local oLblInputVal		:= Nil									//Label do Tipo da Forma de Pagamento
Local aLblPayForms		:= {"","","","","","",{}}				//Representa Tipo,DescAdmFin,Parcelas,Juros,Entrada,CodAdmFin*,Array1aParc*
Local oListPayForms		:= Nil    		      	   				//ListBox da Forma de Pagamento

/* Variaveis do objeto -> Entrada */
Local oGrpDownPay	:= Nil 										//Objeto groupbox
Local oLblDownPay	:= Nil										//Objeto Label de Entrada > Multi Negociacao
Local oListDownPay	:= Nil										//Objeto ListBox de Entrada > Multi Negociacao
Local aTypeDown		:= {}										//Conteudo dos tipos de Entrada
Local lLstDownPay	:= .T.		   								//Indica se o listbox de selecao do Tipo de Entrada e editavel
Local oSayDownPay	:= Nil										//Objetos Label da Entrada
Local nDownPay	   	:= 0										//Valor correspondente a Entrada
Local oDownPay		:= NIL										//Objeto Get correspondente a Entrada
Local oLblTotEntr	:= NIL										//Objeto Label do Total de Entrada
Local nLblTotEntr 	:= 0										//Valor correspondente ao Total de Entrada
Local oLblRestant	:= NIL										//Objeto Label do Total Restante
Local nLblRestante	:= 0										//Valor correspondente ao Valor Restante da Venda
Local oLblDPay01	:= NIL										//Objeto Label da Entrada 01
Local oLblDPay02	:= NIL										//Objeto Label da Entrada 02
Local oLblDPay03	:= NIL										//Objeto Label da Entrada 03
Local oLblDPay04	:= NIL										//Objeto Label da Entrada 04
Local oLblDPay05	:= NIL										//Objeto Label da Entrada 05
Local oLblDPay06	:= NIL										//Objeto Label da Entrada 06
Local oLblDPay07	:= NIL										//Objeto Label da Entrada 07
Local oLblDPay08	:= NIL										//Objeto Label da Entrada 08
Local aTpDownPay	:= {{"",""},{"",""},{"",""},{"",""},{"",""},{"",""},{"",""},{"",""}}	//Array com conteudo de 8 labels referentes a entrada
Local oBtnSimul		:= NIL																		//Objeto Botao Simular
Local oBtnClear		:= NIL																		//Objeto Botao Limpar

/* Variaveis do Resumo no Rodape */
Local oGrpRodape	:= Nil										//Objeto groupbox
Local oBtnCancel	:= NIL										//Objeto Botao Cancelar
Local oBtnConf		:= NIL										//Objeto Botao Confirma Negociacao
Local nRodVertBtn	:= 0	  									//Posicao Vertical do botao no Rodape
Local nRodHorBtn	:= 0										//Posicao Horizontoal do botao no Rodape

/* Variaveis do Painel da Direita da Multi-NegociaÁ„o */
Local aResume 		:= {"","","","","","","","",0,""}	  		//Representa label: Entrada,Qtd.Parc,Vencimento,Valor,Acrescimo,Total,Forma,AdminFin,Desconto
Local oDescVencto	:= NIL 										//Representa o objeto get de Desconto/Vencimento
Local xDescVencto	:= NIL 										//Vari·vel que representa o Desconto/Vencimento
Local lVisiDesVen	:= .F. 										//Indica se ser· visivel o get de Desconto/Vencimento

aPayForms 	:= {}
aBrwContent	:= {}
aParcels 	:= {}

/* Label: Multi-Negociacao */
oLblMulti := TSay():New(POSVERT_CAB, POSHOR_1, {||STR0045}, oMainPanel,,,,,,.T.,,,nLargura,13.5) //"Multi-NegociaÁ„o"
oLblMulti:SetCSS( POSCSS (GetClassName(oLblMulti), CSS_BREADCUMB )) 

/* Objeto TGroup do combo da Regra */
oGrpRule := TGroup():New(nPosAltGroup/26.507,POSHOR_1,nTamAltGroup/13.000,nTamLarGroup,'',oMainPanel,,5,.T.)
 /* Label e Get: Regra */
oLblRules := TSay():New(nPosVerTit, PosVerPay, {||STR0046}, oMainPanel,, ,,,,.T.,,,,8) //"Regra Multi NenociaÁ„o:"
oGetRules := TComboBox():New(nPosAltGroup/20.807, PosVerPay+100, {|u| If(PCount()>0,cGetRules:=u,cGetRules)}, aRules, oGrpRule:nWidth/4, ALTURAGET, ;
			oMainPanel, Nil , {|| aPayForms:=STDGetMBT(oGetRules,nSpace,oListPayForms) }, ;
			{|| STIAtuRules(oGetRules,oListDownPay,aTypeDown,oDownPay,@nDownPay,@aLblPayForms,oBtnSimul,@nLblTotEntr,@nLblRestante,@aTpDownPay,@aResume), ;
			oListPayForms:SetFocus()},,,.T.,, Nil, Nil,, Nil, Nil, Nil, Nil, "cGetRules",,,,)
oLblRules:SetCSS( POSCSS (GetClassName(oLblRules), CSS_BREADCUMB )) 
oGetRules:SetCSS( POSCSS (GetClassName(oGetRules), CSS_GET_FOCAL )) 

/* Objeto TGroup das Formas de Pagamento */
oGrpPayForms := TGroup():New(nPosVerGrp,POSHOR_1,nTamAltGroup/4.500,nTamLarGroup,'',oMainPanel,,5,.T.)
/* Label: Formas de Pagamento */
oLblPayForms := TSay():New(POSVERT_GET1, POSHOR_1+20, {||STR0047}, oMainPanel,,,,,,.T.,,,nLargura,11.5) //"Formas de Pagamento"
oLblPayForms:SetCSS( POSCSS (GetClassName(oLblPayForms), CSS_BREADCUMB )) 
/* ListBox das Formas de Pagamento */
oListPayForms := TListBox():Create(oMainPanel, POSVERT_GET1+13, POSHOR_1+20, Nil, aPayForms, nLargura-40, ALT_LIST_CONSULT/3.20,,,,,.T.,, ;
				{||lLstPayForms := .T.,STDLblPayForms(oListPayForms,@aLblPayForms,@aTypeDown,nSpace,nSaleVal), ;
				STIAtuObjEntr(oListDownPay,aTypeDown,oDownPay,@nDownPay,aLblPayForms,oBtnSimul,@nLblTotEntr,@nLblRestante,@aTpDownPay,@aResume)} ;
				,,,,{||lLstPayForms == .T.})
oListPayForms:SetCSS( POSCSS (GetClassName(oListPayForms), CSS_LISTBOX )) 
oListPayForms:Reset()
oListPayForms:SetArray(aPayForms)

nTop:= (nTamAltGroup/4.500+nPosVerGrp)*0.61
/* Label: Tipo */
@ nTop,nLeft+009 SAY oSayPayForms PROMPT STR0001 SIZE 040,010 RIGHT OF oMainPanel PIXEL HTML //"TIPO"
	oSayPayForms:SetCSS( POSCSS (GetClassName(oSayPayForms), CSS_LABEL_NORMAL )) 
oLblType := TSay():New(nTop+010, POSHOR_1+021, {||aLblPayForms[01]}, oMainPanel,,,,,,.T.,,,nLargura-140,8)
oLblType:SetCSS( POSCSS (GetClassName(oLblType), CSS_LABEL_FOCAL )) 
/* Label: Adm. Financeira */
@ nTop,nLeft+063 SAY oSayPayForms PROMPT STR0002 SIZE 040,010 RIGHT OF oMainPanel PIXEL HTML //"ADM. FINAN."
oSayPayForms:SetCSS( POSCSS (GetClassName(oSayPayForms), CSS_LABEL_NORMAL )) 
oLblAdmFin := TSay():New(nTop+010, POSHOR_1+048, {||aLblPayForms[02]}, oMainPanel,,,,,,.T.,,,nLargura-140,8)
oLblAdmFin:SetCSS( POSCSS (GetClassName(oLblAdmFin), CSS_LABEL_FOCAL )) 
/* Label: Parcelas */
@ nTop,nLeft+127 SAY oSayPayForms PROMPT STR0003 SIZE 040,010 RIGHT OF oMainPanel PIXEL HTML //"PARCELAS"
oSayPayForms:SetCSS( POSCSS (GetClassName(oSayPayForms), CSS_LABEL_NORMAL )) 
oLblParc := TSay():New(nTop+010, POSHOR_1+119, {||aLblPayForms[03]}, oMainPanel,,,,,,.T.,,,nLargura-140,8)
oLblParc:SetCSS( POSCSS (GetClassName(oLblParc), CSS_LABEL_FOCAL )) 
/* Label: Taxa de Juros */
@ nTop,nLeft+178 SAY oSayPayForms PROMPT STR0004 SIZE 040,010 RIGHT OF oMainPanel PIXEL HTML //"TX JUROS"
oSayPayForms:SetCSS( POSCSS (GetClassName(oSayPayForms), CSS_LABEL_NORMAL )) 
oLblRate := TSay():New(nTop+010, POSHOR_1+177, {||aLblPayForms[04]}, oMainPanel,,,,,,.T.,,,nLargura-140,8)
oLblRate:SetCSS( POSCSS (GetClassName(oLblRate), CSS_LABEL_FOCAL )) 
/* Label: Valor de Entrada */
@ nTop,nLeft+233 SAY oSayPayForms PROMPT STR0005 SIZE 070,010 RIGHT OF oMainPanel PIXEL HTML //"VALOR ENTRADA"
oSayPayForms:SetCSS( POSCSS (GetClassName(oSayPayForms), CSS_LABEL_NORMAL )) 
oLblInputVal := TSay():New(nTop+010, POSHOR_1+237, {||aLblPayForms[05]}, oMainPanel,,,,,,.T.,,,nLargura-140,8)
oLblInputVal:SetCSS( POSCSS (GetClassName(oLblInputVal), CSS_LABEL_FOCAL )) 


/* Objeto TGroup do ListBox da Entrada */
oGrpDownPay := TGroup():New(nPosAltGroup/4.400,POSHOR_1,nTamAltGroup/2.600,nTamLarGroup,'',oMainPanel,,5,.T.)
/* Label: Entrada */
oLblDownPay := TSay():New(POSVERT_GET3-010, PosVerPay, {||STR0006}, oMainPanel,,,,,,.T.,,,nLargura,11.5) //"Entrada"
oLblDownPay:SetCSS( POSCSS (GetClassName(oLblDownPay), CSS_BREADCUMB )) 
/* ListBox: Entrada */
oListDownPay := TListBox():Create(oMainPanel, POSVERT_GET3, POSHOR_1+020, Nil, aTypeDown, (nLargura)/3, (ALT_LIST_CONSULT/3.20)*0.75,,,,,.T.,, ;
				{||lLstDownPay := (aLblPayForms[05] <> Alltrim(Transform(0, cPicDefault))), ;
   				STBAtuLblEntr(oListDownPay,@aTpDownPay,oDownPay,nDownPay,@nLblTotEntr,@nLblRestante,nSaleVal)} ;
  				,,,,{||lLstDownPay == (aLblPayForms[05] <> Alltrim(Transform(0, cPicDefault)))})
oListDownPay:SetCSS( POSCSS (GetClassName(oListDownPay), CSS_LISTBOX )) 
oListDownPay:Reset()
oListDownPay:SetArray(aTypeDown)
/* Get: Entrada */
nTop := oGrpDownPay:NBOTTOM
oSayDownPay := TSay():New(nTop*0.415,PosVerPay,{||STR0006+":"},oMainPanel,,,,,,.T.,,,,) //"Entrada"
oSayDownPay:SetCSS( POSCSS(CSS_LABEL_FOCAL) )
oDownPay := TGet():New((nTop*0.415)-3,PosVerPay+30,{|u| If(PCount()>0,nDownPay:=u,nDownPay)},oMainPanel,(nLargura/3)-30,ALTURAGET,cPicDefault, ;
			,,,,,,.T.,,,{|| lLstDownPay == (aLblPayForms[05] <> Alltrim(Transform(0, cPicDefault)))},,,,nDownPay == 0/*ReadOnly*/,,,"nDownPay")
oDownPay:SetCSS( POSCSS (GetClassName(oDownPay), CSS_GET_FOCAL )) 
/* Label: Tipos de Entradas */
nTop := POSVERT_GET3
nLeft:= POSHOR_1
oLblDPay01 := TSay():New(nTop*1.000, nLeft*11.085, {||aTpDownPay[01][01]}, oMainPanel,,,,,,.T.,,,nLargura,11.5)
oLblDPay02 := TSay():New(nTop*1.057, nLeft*11.085, {||aTpDownPay[02][01]}, oMainPanel,,,,,,.T.,,,nLargura,11.5)
oLblDPay03 := TSay():New(nTop*1.115, nLeft*11.085, {||aTpDownPay[03][01]}, oMainPanel,,,,,,.T.,,,nLargura,11.5)
oLblDPay04 := TSay():New(nTop*1.173, nLeft*11.085, {||aTpDownPay[04][01]}, oMainPanel,,,,,,.T.,,,nLargura,11.5)
oLblDPay05 := TSay():New(nTop*1.230, nLeft*11.085, {||aTpDownPay[05][01]}, oMainPanel,,,,,,.T.,,,nLargura,11.5)
oLblDPay06 := TSay():New(nTop*1.288, nLeft*11.085, {||aTpDownPay[06][01]}, oMainPanel,,,,,,.T.,,,nLargura,11.5)
oLblDPay07 := TSay():New(nTop*1.345, nLeft*11.085, {||aTpDownPay[07][01]}, oMainPanel,,,,,,.T.,,,nLargura,11.5)
oLblDPay08 := TSay():New(nTop*1.403, nLeft*11.085, {||aTpDownPay[08][01]}, oMainPanel,,,,,,.T.,,,nLargura,11.5)
oLblDPay01:SetCSS( POSCSS (GetClassName(oLblDPay01), CSS_LABEL_FOCAL )) 
oLblDPay02:SetCSS( POSCSS (GetClassName(oLblDPay02), CSS_LABEL_FOCAL )) 
oLblDPay03:SetCSS( POSCSS (GetClassName(oLblDPay03), CSS_LABEL_FOCAL )) 
oLblDPay04:SetCSS( POSCSS (GetClassName(oLblDPay04), CSS_LABEL_FOCAL )) 
oLblDPay05:SetCSS( POSCSS (GetClassName(oLblDPay05), CSS_LABEL_FOCAL )) 
oLblDPay06:SetCSS( POSCSS (GetClassName(oLblDPay06), CSS_LABEL_FOCAL )) 
oLblDPay07:SetCSS( POSCSS (GetClassName(oLblDPay07), CSS_LABEL_FOCAL )) 
oLblDPay08:SetCSS( POSCSS (GetClassName(oLblDPay08), CSS_LABEL_FOCAL )) 
/* Label: Rodape das Entradas */
oSayDownPay := TSay():New(nTop*1.351, PosVerPay+000,{||STR0020},oMainPanel,,,,,,.T.,,,,) //"TOTAL ENTRADAS:"
oSayDownPay:SetCSS( POSCSS (GetClassName(oSayDownPay), CSS_LABEL_NORMAL )) 
oSayDownPay := TSay():New(nTop*1.351, PosVerPay+075,{||STR0021},oMainPanel,,,,,,.T.,,,,) //"RESTANTE:"
oSayDownPay:SetCSS( POSCSS (GetClassName(oSayDownPay), CSS_LABEL_NORMAL)) 
oLblTotEntr := TSay():New(nTop*1.409, PosVerPay+015,{||nLblTotEntr}, oMainPanel,cPicDefault,,,,,.T.,,,,)
oLblTotEntr:SetCSS( POSCSS (GetClassName(oLblTotEntr), CSS_LABEL_FOCAL)) 
oLblRestant  := TSay():New(nTop*1.409, PosVerPay+075,{||nLblRestante}, oMainPanel,cPicDefault,,,,,.T.,,,,)
oLblRestant:SetCSS( POSCSS (GetClassName(oLblRestant), CSS_LABEL_FOCAL)) 

/* Button: Adicionar Entradas */
oBtnClear	:= TButton():New(POSVERT_GET3,nTamLarGroup-LARGBTN-4,STR0022,oMainPanel, ;
				{|| STBAtuLblEntr(oListDownPay,@aTpDownPay,oDownPay,nDownPay,@nLblTotEntr,@nLblRestante,nSaleVal) }, ;
				LARGBTN,ALTURABTN,,,,.T.) //"Adicionar Entrada"
oBtnClear:SetCSS( POSCSS (GetClassName(oBtnClear), CSS_BTN_ATIVO)) 
/* Button: Simular */
oBtnSimul := TButton():New(POSVERT_GET3+056,nTamLarGroup-LARGBTN-4,STR0015,oMainPanel, ;
			{|| STBSimulMultiNeg(	oListPayForms,	oListDownPay,	@aTypeDown,		oDownPay,		@nDownPay,	@aLblPayForms, 	;
							   		oBtnSimul,		@nLblTotEntr,	@nLblRestante,	@aTpDownPay,	@aResume,	nSpace,			;
							   		nSaleVal,		aItens,			@oMultNegoc,	aBrwContent,	oBrwContent) }, ;			
			LARGBTN,ALTURABTN,,,,.T.) //"Simular"
oBtnSimul:SetCSS( POSCSS (GetClassName(oBtnSimul), CSS_BTN_FOCAL)) 


/* Objeto TGroup do Rodape da tela RESUMO */
oGrpRodape 	:= TGroup():New(oPnlRodape:nHeight/97,POSHOR_1,oPnlRodape:nHeight/2.150,nTamLarGroup*2.03,'',oPnlRodape,,5,.T.)
nRodVertBtn	:= (oGrpRodape:nHeight/2-ALTURABTN)/2
nRodHorBtn	:= (oGrpRodape:nWidth/2-LARGBTN)
/* Button: Cancelar */
oBtnCancel	:= TButton():New(nRodVertBtn,nRodHorBtn-LARGBTN-3,STR0023,oPnlRodape,{|| STIMultiCancel(oMainPanel), aItens := {}},LARGBTN,ALTURABTN,,,,.T.) //"Cancelar"
oBtnCancel:SetCSS( POSCSS (GetClassName(oBtnCancel), CSS_BTN_ATIVO)) 
/* Button: Confirmar NegociaÁ„o */
oBtnConf := TButton():New(nRodVertBtn,nRodHorBtn,STR0024,oPnlRodape, ;
			{|| STIMnConfirme(aResume,oMainPanel,aTypeDown,aTpDownPay,aLblPayForms)},LARGBTN,ALTURABTN,,,,.T.) //"Confirmar NegociaÁ„o"
oBtnConf:SetCSS( POSCSS (GetClassName(oBtnConf), CSS_BTN_FOCAL)) 

STIMnRightPnl(	oPnlRight,		nPosVerTit,		nPosVerGrp,		@aResume,		;
				@aLblPayForms,	@oDescVencto,	xDescVencto,	@lVisiDesVen,	;
				oBtnConf, 		oListPayForms,	oListDownPay,	@aTypeDown,		;
				oDownPay,		@nDownPay,		oBtnSimul,		@nLblTotEntr,	;
				@nLblRestante,	@aTpDownPay,	nSpace,			nSaleVal,		;
				aItens,			@oMultNegoc,	aBrwContent,	oBrwContent)
STIMnRodPanel(oPnlRodape,aResume,POSHOR_1+20)

oDownPay:lReadOnly := .T. // Inicio o get da Entrada somente leitura
oDownPay:CtrlRefresh()
oGetRules:SetFocus()

ModelDef()

Return(oMainPanel)

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIGetRules
Identifica se existem regras de muntinegociaÁ„o cadastradas

@param   	nValue - Valor da Venda
@author  	Varejo
@version 	P12
@since   	23/09/2013
@return  	aRet
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

Function STIGetRules(nValue)
Local aArea 		:= GetArea()							//Salva area atual
Local aRet  		:= {""}									//Variavel de Retorno
Local oModelCesta	:= STDGPBModel()						//Modelo de Itens de Venda
Local oModelSL2		:= oModelCesta:GetModel("SL2DETAIL")	//Modelo de Itens de Venda
Local aMn			:= {}									//Retorno das Multi-negociaÁıes possÌveis
Local nFor			:= 0									//Variavel de LaÁo
Local nX			:= 0									//Variavel de laÁo para itens

nSaleVal := nValue + nValorBonif

/* Faz a busca dos itens para verificar regras de multi negociaÁ„o*/
For nX := 1 To oModelSL2:Length()
	oModelSL2:GoLine(nX)
	If !oModelSL2:IsDeleted(nX)
		aAdd(aItens,{	oModelSL2:GetValue("L2_ITEM")   						,;  // Item
						AllTrim(oModelSL2:GetValue("L2_PRODUTO")) 				,;	// Cod Produto
						AllTrim(oModelSL2:GetValue("L2_PRODUTO")) 				,;	// Cod Barras
						AllTrim(oModelSL2:GetValue("L2_DESCRI"))  				,;	// Descricao
						oModelSL2:GetValue("L2_QUANT")   						,;	// Quantidade
						oModelSL2:GetValue("L2_VRUNIT")	 						,;	// Vlr Unit
						oModelSL2:GetValue("L2_VLRITEM")						,;	// Vlr Item
						oModelSL2:GetValue("L2_VALDESC") 						,;	// Vlr Desconto
						AllTrim(oModelSL2:GetValue("L2_SITTRIB")) 				,;	// Aliquota
						oModelSL2:GetValue("L2_VALIPI")  						,;	// IPI
						.F.										  				,;
						oModelSL2:GetValue("L2_ICMSRET") 						,;	// Valor Icms retido
						oModelSL2:GetValue("L2_BRICMS")  						,;	// Deducao Icms
						oModelSL2:GetValue("L2_ITEM")    						,;	// Cod. ANVISA
						.F.										  				,;	// .F.
						""										   				}) // .T.
	EndIf
Next nX

If !EMPTY(aItens)
	oMultNegoc := LJCMultNeg():New()
	oMultNegoc:GetMultNeg(aItens)
	
	If oMultNegoc:oDadosCab:Count() > 0
		
		aMn := LJ164MNeg(oMultNegoc)		
		For nFor := 1 To Len(aMn)
			Aadd(aRet,aMn[nFor][01]+" - "+aMn[nFor][02])
		Next nFor

	EndIf
EndIf

If Len(aRet) == 1
	STFMessage(ProcName(),"STOP",STR0025) //"Nao ha regra de negociaÁ„o ativo cadastrado."
	STFShowMessage(ProcName())	
EndIf

aRules := aRet

RestArea(aArea)

Return aRet

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIAtuRules
Atualiza os objetos a partir do combo de Regras

@param   	oGetRules 		- Objeto de Get Regra
@param   	oListDownPay 	- Objeto ListBox de Entrada > Multi Negociacao
@param   	aTypeDown 		- Conteudo dos tipos de Entrada
@param   	oDownPay 		- Objeto Get correspondente a Entrada
@param   	nDownPay 		- Valor correspondente a Entrada
@param   	aLblPayForms 	- Representa os Labels da Forma de Pagamento
@param   	oBtnSimul  		- Objeto Botao Simular
@param   	nLblTotEntr 	- Valor correspondente ao Total de Entrada
@param   	nLblRestante 	- Valor correspondente ao Valor Restante da Venda
@param   	aTpDownPay 		- Array com conteudo de 8 labels referentes a entrada
@param   	aResume			- Representa label: Entrada,Qtd.Parc,Vencimento,Valor,Acrescimo,Total,Forma,AdminFin,Desconto
@author  	Varejo
@version 	P12
@since   	23/09/2013
@return  	NIL
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

Static Function STIAtuRules(oGetRules,oListDownPay,aTypeDown,oDownPay,nDownPay,aLblPayForms,oBtnSimul,nLblTotEntr,nLblRestante,aTpDownPay,aResume)

aLblPayForms:={"","","","","","",{}}
aTypeDown := {}

STIAtuObjEntr(oListDownPay,aTypeDown,oDownPay,@nDownPay,aLblPayForms,oBtnSimul,@nLblTotEntr,@nLblRestante,@aTpDownPay,@aResume)

Return NIL

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIAtuObjEntr
Atualiza os objetos de Entrada

@param		oListDownPay	- Objeto ListBox de Entrada > Multi Negociacao
@param		aTypeDown		- Conteudo dos tipos de Entrada
@param		oDownPay		- Objeto Get correspondente a Entrada
@param		nDownPay		- Valor correspondente a Entrada
@param		aLblPayForms	- Representa os Labels da Forma de Pagamento
@param		oBtnSimul		- Objeto Botao Simular
@param		nLblTotEntr		- Valor correspondente ao Total de Entrada
@param		nLblRestante	- Valor correspondente ao Valor Restante da Venda
@param		aTpDownPay		- Array com conteudo de 8 labels referentes a entrada
@param		aResume			- Representa label: Entrada,Qtd.Parc,Vencimento,Valor,Acrescimo,Total,Forma,AdminFin,Desconto
@author  	Varejo
@version 	P12
@since   	23/09/2013
@return		NIL
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

Function STIAtuObjEntr(oListDownPay,aTypeDown,oDownPay,nDownPay,aLblPayForms,oBtnSimul,nLblTotEntr,nLblRestante,aTpDownPay,aResume)
Local lEntrada := !( EMPTY(aLblPayForms[05]) .OR. (aLblPayForms[05] == Alltrim(Transform(0, cPicDefault))) )	//Indica se tem entrada

oListDownPay:Reset()
oListDownPay:SetArray(aTypeDown)
oListDownPay:SetFocus()
oDownPay:lReadOnly := !lEntrada

nDownPay := IIF(EMPTY(aTypeDown),0,nDownPay)

If lEntrada
	oDownPay:SetFocus()
Else
	oBtnSimul:SetFocus()
EndIF

If !lEntrada
	STIMnClear(oListDownPay,aTypeDown,oDownPay,@nDownPay,aLblPayForms,oBtnSimul,@nLblTotEntr,@nLblRestante,@aTpDownPay,@aResume)
EndIf

STIMnClRight(@aResume,aLblPayForms,nLblTotEntr)

Return NIL

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIMnClear
Limpa a tela de Multi-Negociacao

@param		oListDownPay 	- Objeto ListBox de Entrada > Multi Negociacao
@param		aTypeDown 		- Conteudo dos tipos de Entrada
@param		oDownPay 		- Objeto Get correspondente a Entrada
@param		nDownPay 		- Valor correspondente a Entrada
@param		aLblPayForms 	- Representa os Labels da Forma de Pagamento
@param		oBtnSimul 		- Objeto Botao Simular
@param		nLblTotEntr 	- Valor correspondente ao Total de Entrada
@param		nLblRestante 	- Valor correspondente ao Valor Restante da Venda
@param		aTpDownPay 		- Array com conteudo de 8 labels referentes a entrada
@param		aResume 		- Representa label: Entrada,Qtd.Parc,Vencimento,Valor,Acrescimo,Total,Forma,AdminFin,Desconto
@author  	Varejo
@version 	P12
@since   	23/09/2013
@return		NIL
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

Static Function STIMnClear(oListDownPay,aTypeDown,oDownPay,nDownPay,aLblPayForms,oBtnSimul,nLblTotEntr,nLblRestante,aTpDownPay,aResume)
Local lEntrada := !( EMPTY(aLblPayForms[05]) .OR. (aLblPayForms[05] == Alltrim(Transform(0, cPicDefault))) )	//Indica se tem entrada

oListDownPay:Reset()
oListDownPay:SetArray(aTypeDown)
oListDownPay:SetFocus()
nDownPay := 0
oDownPay:lReadOnly := !lEntrada
If lEntrada
	oDownPay:SetFocus()
Else
	oBtnSimul:SetFocus()
EndIF
nLblTotEntr := 0
nLblRestante := 0
aTpDownPay	:= {{"",""},{"",""},{"",""},{"",""},{"",""},{"",""},{"",""},{"",""}}

STIMnClRight(@aResume,aLblPayForms,nLblTotEntr)

Return NIL

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*{Protheus.doc} STIMnRightPnl
Monta o painel da Direita da Multi-NegociaÁ„o
@param		oPanelMVC		- Painel padrao da direita - oPnlRight
@param		nPosVerTit		- Posicao inicial do titulo conforme painel da Esquerda
@param		nPosVerGrp		- Posicao inicial do Grupo conforme painel da Esquerda
@param 		aResume			- Representa label: Entrada,Qtd.Parc,Vencimento,Valor,Acrescimo,Total,Forma,AdminFin,Desconto
@param 		aLblPayForms	- Representa os Labels da Forma de Pagamento
@param 		oDescVencto		- Representa o objeto get de Desconto/Vencimento
@param 		xDescVencto		- Vari·vel que representa o Desconto/Vencimento
@param 		lVisiDesVen		- Indica se ser· visivel o get de Desconto/Vencimento
@param 		oBtnConf		- Botao de Confirmacao
@param   	oListPayForms	- ListBox da Forma de Pagamento
@param 		oListDownPay	- Objeto ListBox de Entrada > Multi Negociacao
@param 		aTypeDown		- Conteudo dos tipos de Entrada
@param 		oDownPay		- Objeto Get correspondente a Entrada
@param 		nDownPay		- Valor correspondente a Entrada
@param 		oBtnSimul		- Bot„o de SimulaÁ„o
@param 		nLblTotEntr		- Valor correspondente ao Total de Entrada
@param 		nLblRestante	- Valor correspondente ao Valor Restante da Venda
@param 		aTpDownPay		- Array com conteudo de 8 labels referentes a entrada
@param 		nSpace			- Tamanho de espaco entre uma informacao e outra
@param   	nSaleVal		- Valor da Venda
@param   	aItens			- Array com os itens da venda
@param   	oMultNegoc		- Objeto de integraÁ„o da MultinegociaÁ„o
@param   	aBrwContent		- Conteudo do Browse da Direita
@param   	oBrwContent		- Objeto do Browse da Direita
@author  	Varejo
@version 	P12
@since   	23/09/2013
@return  	NIL
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Static Function STIMnRightPnl(	oPanelMVC,		nPosVerTit,		nPosVerGrp,		aResume,		;
								aLblPayForms,	oDescVencto,	xDescVencto,	lVisiDesVen,	;
								oBtnConf,  		oListPayForms,	oListDownPay,	aTypeDown,		;
								oDownPay,		nDownPay,		oBtnSimul,		nLblTotEntr,	;
								nLblRestante,	aTpDownPay,		nSpace,			nSaleVal,		;
								aItens,			oMultNegoc,		aBrwContent,	oBrwContent)

Local oMainPanel 	:= TPanel():New(nPosVerGrp,10,"",oPanelMVC,,,,,,oPanelMVC:nWidth/2-20,(oPanelMVC:nHeight)/4) //Painel da direita da MultiNegociacao
Local oNewPanel1 	:= TPanel():New(nPosVerGrp-03,02					,"",oPanelMVC,,,,,,20,27) 					//Painel da Ajuste 1
Local oNewPanel2 	:= TPanel():New(nPosVerGrp-03,oPanelMVC:nWidth/2-30,"",oPanelMVC,,,,,,20,27) 					//Painel da Ajuste 2
Local oGrpRight		:= Nil 										//Objeto groupbox
Local oLblRigParc	:= NIL  									//Label de titulo do painel da direita
Local oLblDescVenc	:= NIL 										//Label dinamico relativo ao Desconto ou Vencimento
Local clblDescVenc 	:= ""										//Variavel dinamica relativa ao Desconto ou Vencimento
Local cPicDesVen	:= cPicDefault 								//Picture do Get de Desconto/Vencimento
Local oBtnVenc		:= NIL										//Botao de Vencimento
Local oBtnDesc		:= NIL										//Botao de Desconto
Local oSay			:= NIL										//Objeto Label
Local nLeft 		:= POSHOR_1+10								//Valor de Left
Local nTop 	   		:= nPosVerGrp-7								//Valor de Top
Local nCol			:= (oPanelMVC:nWidth / 2) * 0.03		 	//Coordenada horizontal
Local nLargura		:= (oPanelMVC:nWidth / 2) - (2 * nCol)		//Largura

/* Objeto TGroup da tela da direita */
oGrpRight := TGroup():New( oPanelMVC:nHeight/26.507,005,oPanelMVC:nHeight/3.02,oPanelMVC:nWidth*0.485,'',oPanelMVC,,5,.T.)

oLblRigParc := TSay():New(nPosVerTit, nLeft, {||STR0038}, oPanelMVC,,,,,,.T.,,,100,11.5) //"Parcelas"
oLblRigParc:SetCSS( POSCSS (GetClassName(oLblRigParc), CSS_BREADCUMB )) 

/* Objeto TGrid das Parcelas da tela Direita */
STIMnItens( oMainPanel, @aResume ,oBtnConf , aLblPayForms ) 

/* Label dinamico relativo ao Desconto ou Vencimento*/
nLeft 	:= 010
nTop 	:= POSVERT_GET4+5
oLblDescVenc := TSay():New(nTop+000, nLeft, {||clblDescVenc}, oPanelMVC,,,,,,.T.,,,nLargura-140,8)
oLblDescVenc:SetCSS( POSCSS (GetClassName(oLblDescVenc), CSS_LABEL_NORMAL )) 
/* Desconto e Vencimento*/
oDescVencto := TGet():New(nTop+010,nLeft,{|u| If(PCount()>0,xDescVencto:=u,xDescVencto)},oPanelMVC,(nLargura/3)-30,ALTURAGET,cPicDesVen,;
			{|| STITrigDesVen(	@clblDescVenc,	oDescVencto,	@xDescVencto,	@cPicDesVen,	;
								@aLblPayForms,	@aResume, 		oBtnVenc,  		oBtnDesc,		;
								oListPayForms,	oListDownPay,	@aTypeDown,		oDownPay,		;
								@nDownPay,		oBtnSimul,		@nLblTotEntr,	@nLblRestante,	;
								@aTpDownPay,	nSpace,			nSaleVal,		aItens,			;
								@oMultNegoc) } 					;
			,,,,,,.T.,,,,,,,/*ReadOnly*/,,,"xDescVencto")
oDescVencto:SetCSS( POSCSS (GetClassName(oDescVencto), CSS_GET_FOCAL )) 
/* Button: Desconto */
oBtnDesc := TButton():New(POSVERT_GET4+1,POSHOR_BTNFOCAL-10-LARGBTN-03,STR0032,oPanelMVC, ;			
			{|| STIMnDesconto(@clblDescVenc,oDescVencto,@xDescVencto,@cPicDesVen) },LARGBTN,ALTURABTN,,,,.T.) //"Desconto"
oBtnDesc:SetCSS( POSCSS (GetClassName(oBtnDesc), CSS_BTN_ATIVO )) 

/* Button: Vencimento */
oBtnVenc := TButton():New(POSVERT_GET4+1,POSHOR_BTNFOCAL-10,STR0033,oPanelMVC, ;
			{|| STIMnVencto(@clblDescVenc,oDescVencto,@xDescVencto,@cPicDesVen) },LARGBTN,ALTURABTN,,,,.T.) //"Alterar Vencimento"
oBtnVenc:SetCSS( POSCSS (GetClassName(oBtnVenc), CSS_BTN_ATIVO )) 

oDescVencto:lVisible := lVisiDesVen
oDescVencto:CtrlRefresh()

Return NIL

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIMnItens
CriaÁ„o do grid dos itens do painel da direita

@param		o		   		- Objeto para itens
@param		aResume	   		- Representa label: Entrada,Qtd.Parc,Vencimento,Valor,Acrescimo,Total,Forma,AdminFin
@param 		oBtnConf		- Botao de Confirmacao
@author  	Varejo
@version 	P12
@since   	23/09/2013
@return		NIL
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Static Function STIMnItens( o,aResume,oBtnConf, aLblPayForms  )

Local oContent		:= NIL							//Conteudo do css
Local oColumn		:= Nil							//Objeto do Grid
Local cPicTotal		:= PesqPict("SL1","L1_VLRTOT") 	//Picture do L1_VLRTOT
Local nX			:= 0							//Variavel de Laco

aBrwContent := {}

For nX := 1 To Len(aParcels)
	aAdd(aBrwContent,{ ;
		STRZERO(nX,2) +"-"+ aParcels[nX,POS_TIPO]		, ;
		STRZERO(aParcels[nX,POS_QTDPARC],2)				, ;
		aParcels[nX,POS_VLRPARC] 						, ;
		aParcels[nX,POS_VLRTOT]  						, ;
		aParcels[nX,POS_VLRVEN]  						, ;
		aParcels[nX,POS_ACRESC]  						, ;
   		DToC(aParcels[nX,POS_VENCIM])					})
Next nX

oContent := POSBrwContainer(o)

DEFINE FWBROWSE oBrwContent DATA ARRAY ARRAY aBrwContent DOUBLECLICK { || STIMnResume(@aResume,oBtnConf, Nil ,aLblPayForms )} NO LOCATE NO CONFIG NO REPORT OF oContent
	
	oBrwContent:nRowHeight := 25
	oBrwContent:SetVScroll(.F.)

	ADD COLUMN oColumn DATA {|| aBrwContent[oBrwContent:nAt][POS_TIPO] 		} 	TITLE STR0034	SIZE 008 OF oBrwContent //"Tipo"
	ADD COLUMN oColumn DATA {|| aBrwContent[oBrwContent:nAt][POS_QTDPARC] 	} 	TITLE STR0035	SIZE 008 OF oBrwContent //"Qtd.Parc"
	ADD COLUMN oColumn DATA {|| aBrwContent[oBrwContent:nAt][POS_VLRPARC] 	} 	TITLE STR0036	SIZE 008 OF oBrwContent //"Vlr.Parc"
	ADD COLUMN oColumn DATA {|| aBrwContent[oBrwContent:nAt][POS_VLRTOT] 	} 	TITLE STR0037	SIZE 008 OF oBrwContent //"Tot. Prazo"
	ADD COLUMN oColumn DATA {|| aBrwContent[oBrwContent:nAt][POS_VLRVEN] 	} 	TITLE STR0052	SIZE 008 OF oBrwContent //"Val Ate Venc"
	ADD COLUMN oColumn DATA {|| aBrwContent[oBrwContent:nAt][POS_ACRESC]	} 	TITLE STR0030	SIZE 008 OF oBrwContent //Acrescimo"
	ADD COLUMN oColumn DATA {|| aBrwContent[oBrwContent:nAt][POS_VENCIM]	} 	TITLE STR0039	SIZE 008 OF oBrwContent //"Venc. 1™ Parc."

ACTIVATE FWBROWSE oBrwContent

Return NIL

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIMnResume
Atualiza os labels de resumo do painel da direita

@param		aResume			- Representa label: Entrada,Qtd.Parc,Vencimento,Valor,Acrescimo,Total,Forma,AdminFin
@param 		oBtnConf		- Botao de Confirmacao
@param		cMsg			- String de Mensagem
@author  	Varejo
@version 	P12
@since   	23/09/2013
@return		NIL
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Static Function STIMnResume( aResume,oBtnConf,cMsg,aLblPayForms )
Local nQtMinPar := 0
Local nQtParc   := 0

Default cMsg := "" 	//String de Mensagem

aResume[02] := oBrwContent:ODATA:AARRAY[oBrwContent:nAt][POS_QTDPARC]
aResume[03] := oBrwContent:ODATA:AARRAY[oBrwContent:nAt][POS_VENCIM]
aResume[04] := oBrwContent:ODATA:AARRAY[oBrwContent:nAt][POS_VLRPARC]
aResume[05] := oBrwContent:ODATA:AARRAY[oBrwContent:nAt][POS_VLRVEN]
aResume[06] := oBrwContent:ODATA:AARRAY[oBrwContent:nAt][POS_VLRTOT]
aResume[10] := oBrwContent:ODATA:AARRAY[oBrwContent:nAt][POS_ACRESC]

If Len(aResume) > 0 .And. Len(aLblPayForms) > 0
	nQtMinPar :=  Val(SubStr(aLblPayForms[03], 1, 2))
	nQtParc   :=  Val(aResume[2])
	If nQtParc <  nQtMinPar 
		 STFMessage("STIMnConfirme","POPUP", STR0053)  // Quantidade de parcelas selecionada È inferior ao definido no cadastro
		 STFShowMessage("STIMnConfirme")		 
	EndIf 
EndIf 


If !EMPTY(cMsg)
	STFMessage(ProcName(),"STOP",cMsg)
	STFShowMessage(ProcName())	
	STFCleanMessage(ProcName())
EndIf

oBtnConf:SetFocus()

Return NIL


//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIMnClRight
Limpa a tela da direita de Multi-Negociacao

@param		aResume			- Representa label: Entrada,Qtd.Parc,Vencimento,Valor,Acrescimo,Total,Forma,AdminFin,Desconto
@param		aLblPayForms	- Representa os Labels da Forma de Pagamento
@param		nLblTotEntr  	- Valor correspondente ao Total de Entrada
@author  	Varejo
@version 	P12
@since   	23/09/2013
@return  	NIL
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

Function STIMnClRight(aResume,aLblPayForms,nLblTotEntr)

Default nLblTotEntr := 0	//Valor correspondente ao Total de Entrada

aResume := {Alltrim(Transform(nLblTotEntr, cPicDefault)),"","","","","",Alltrim(aLblPayForms[01]),Alltrim(aLblPayForms[06]),0,""}

aBrwContent := {}
oBrwContent:SetArray(aBrwContent)
oBrwContent:Refresh()

Return NIL

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*{Protheus.doc} STIMnVencto
Evento do Click do botao de Vencimento

@param		clblDescVenc	- Variavel dinamica relativa ao Desconto ou Vencimento
@param		oDescVencto		- Representa o objeto get de Desconto/Vencimento
@param		xDescVencto		- Vari·vel que representa o Desconto/Vencimento
@param		cPicDesVen		- Picture do Get de Desconto/Vencimento
@author  	Varejo
@version 	P12
@since   	23/09/2013
@return		NIL
@obs     
@sample
*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Static Function STIMnVencto( clblDescVenc,oDescVencto,xDescVencto,cPicDesVen )
Local lRet := .T.					//Variavel de Retorno

If EMPTY(aBrwContent)
	lRet := .F.
	STFMessage(ProcName(),"STOP",STR0040) //"FaÁa uma simulaÁ„o com as formas de pagamentos"
	STFShowMessage(ProcName())	
	STFCleanMessage(ProcName())
EndIF

If lRet
	clblDescVenc 	:= STR0041 //"Vencimento:"
	cPicDesVen 		:= "@D"
	xDescVencto		:= CToD(aBrwContent[01][06])
	oDescVencto:lVisible := .T.
	oDescVencto:CtrlRefresh()
	oDescVencto:SetFocus()
EndIF

Return NIL

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIMnDesconto
Evento do Click do botao de Desconto

@param		clblDescVenc	- Variavel dinamica relativa ao Desconto ou Vencimento
@param		oDescVencto		- Representa o objeto get de Desconto/Vencimento
@param		xDescVencto		- Vari·vel que representa o Desconto/Vencimento
@param		cPicDesVen		- Picture do Get de Desconto/Vencimento
@author  	Varejo
@version 	P12
@since   	23/09/2013
@return		NIL
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Static Function STIMnDesconto( clblDescVenc,oDescVencto,xDescVencto,cPicDesVen )
Local lRet := .T.  						//Variavel de Retorno

If EMPTY(aBrwContent)
	lRet := .F.
	STFMessage(ProcName(),"STOP",STR0040) //"FaÁa uma simulaÁ„o com as formas de pagamentos"
	STFShowMessage(ProcName())	
	STFCleanMessage(ProcName())
EndIF

If lRet
	clblDescVenc 	:= STR0042 //"Desconto:"
	cPicDesVen 		:= cPicDefault
	xDescVencto		:= 0
	oDescVencto:lVisible := .T.
	oDescVencto:CtrlRefresh()
	oDescVencto:SetFocus()
EndIF

Return NIL

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STITrigDesVen
Gatilho do objeto Get de Desconto/Vencimento

@param		clblDescVenc	- Variavel dinamica relativa ao Desconto ou Vencimento
@param		oDescVencto		- Representa o objeto get de Desconto/Vencimento
@param		xDescVencto		- Vari·vel que representa o Desconto/Vencimento
@param		cPicDesVen		- Picture do Get de Desconto/Vencimento
@param		aLblPayForms	- Representa os Labels da Forma de Pagamento
@param		aResume			- Representa label: Entrada,Qtd.Parc,Vencimento,Valor,Acrescimo,Total,Forma,AdminFin
@param		oBtnVenc		- Botao de Vencimento
@param		oBtnDesc		- Botao de Desconto
@param   	oListPayForms	- ListBox da Forma de Pagamento
@param 		oListDownPay	- Objeto ListBox de Entrada > Multi Negociacao
@param 		aTypeDown		- Conteudo dos tipos de Entrada
@param 		oDownPay		- Objeto Get correspondente a Entrada
@param 		nDownPay		- Valor correspondente a Entrada
@param 		oBtnSimul		- Bot„o de SimulaÁ„o
@param 		nLblTotEntr		- Valor correspondente ao Total de Entrada
@param 		nLblRestante	- Valor correspondente ao Valor Restante da Venda
@param 		aTpDownPay		- Array com conteudo de 8 labels referentes a entrada
@param 		nSpace			- Tamanho de espaco entre uma informacao e outra
@param   	nSaleVal		- Valor da Venda
@param   	aItens			- Array com os itens da venda
@param   	oMultNegoc		- Objeto de integraÁ„o da MultinegociaÁ„o
@author  	Varejo
@version 	P12
@since   	23/09/2013
@return  	lValid
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Static Function STITrigDesVen( 	clblDescVenc,	oDescVencto,	xDescVencto,	cPicDesVen, 	;
								aLblPayForms,	aResume,		oBtnVenc,		oBtnDesc,		;
								oListPayForms,	oListDownPay,	aTypeDown,		oDownPay,		;
								nDownPay,		oBtnSimul,		nLblTotEntr,	nLblRestante,	;
								aTpDownPay,		nSpace,			nSaleVal,		aItens,			;
								oMultNegoc)
								
Local lValid 		:= .F. 							//Variavel de ValidaÁ„o
Local nFor 			:= 0							//Variavel de LaÁo
Local oReasons		:= Nil							//ListBox de Motivo de Desconto
Local nDescOld		:= 0							//Armazena o descono antigo caso exista
Local nValAtVect	:= 0							//Valor total ate o vecimento
Local nValTotal		:= 0							//Valor tota.

If !EMPTY(aLblPayForms[07]) .AND. VALTYPE(xDescVencto) == "D" .AND. clblDescVenc == STR0041 //"Vencimento:"
	lValid := Lj764VlVen(xDescVencto, aLblPayForms[07][03])
	
	If lValid
		For nFor := 1 To Len(aBrwContent)
			aBrwContent[nFor][06] := DToC(xDescVencto) // Atualiza a Data
		Next nFor
		
		oBrwContent:SetArray(aBrwContent)
		oBrwContent:Refresh()
		
		If !EMPTY(aResume[03])
			aResume[03] := DToC(xDescVencto)
		EndIf
		
	EndIf
ElseIf EMPTY(aLblPayForms[07]) .AND. VALTYPE(xDescVencto) == "D" .AND. clblDescVenc == STR0041 //"Vencimento:"
	clblDescVenc 	:= ""
	cPicDesVen 		:= ""
	xDescVencto		:= NIL
	oDescVencto:lVisible := .F.
	oDescVencto:CtrlRefresh()
	oBtnVenc:SetFocus()
EndIf

If !EMPTY(aLblPayForms[07]) .AND. VALTYPE(xDescVencto) == "N" .AND. clblDescVenc == STR0042 //"Desconto:"

	If !EMPTY(aBrwContent) .AND. Val(StrTran(StrTran(aBrwContent[1][4],",",""),".",""))/100 > xDescVencto
		nDescOld	 := aResume[09]
		aResume[09]  := xDescVencto
		
		lValid := .T.
		// Verifica se teve desconto na multinegociaÁ„o
		lmultineg := .T.
		
		/* ConfirmaÁ„o desconto no total */
		If STITotDiscVal((aResume[09]),,oReasons)

			//Adiciono o desconto antigo caso exista
			nValAtVect := Val(StrTran(StrTran(aResume[05],".",""),",",".")) + nDescOld
			nValTotal  := Val(StrTran(StrTran(aResume[06],".",""),",",".")) + nDescOld
			
			If nValAtVect > 0 .AND. nValTotal > 0 
				//Tiro o valor do novo desconto do total
				aResume[05] := Alltrim(TRANSFORM(nValAtVect - aResume[09],"@E 999,999.99"))
				aResume[06] := Alltrim(TRANSFORM(nValTotal  - aResume[09],"@E 999,999.99"))
			EndIf 

			STBSimulMultiNeg(	oListPayForms,	oListDownPay,	@aTypeDown,		oDownPay,		;
								@nDownPay,		@aLblPayForms,	oBtnSimul,		@nLblTotEntr,	;
								@nLblRestante,	@aTpDownPay,	@aResume,		nSpace,			;
								nSaleVal,		aItens,			@oMultNegoc,	aBrwContent,	;
								oBrwContent,	.T.)			
		EndIf
		
	Else
		STFMessage(ProcName(),"STOP",STR0048) //"O Desconto n„o pode ser maior que o valor da venda."
		STFShowMessage(ProcName())
		STFCleanMessage(ProcName())
		lValid := .F.
	EndIf
	
ElseIf EMPTY(aLblPayForms[07]) .AND. VALTYPE(xDescVencto) == "N" .AND. clblDescVenc == STR0042 //"Desconto:"
	clblDescVenc 	:= ""
	cPicDesVen 		:= ""
	xDescVencto		:= NIL
	oDescVencto:lVisible := .F.
	oDescVencto:CtrlRefresh()
	oBtnVenc:SetFocus()
EndIf

If lValid
	clblDescVenc 	:= ""
	cPicDesVen 		:= ""
	xDescVencto		:= NIL
	oDescVencto:lVisible := .F.
	oDescVencto:CtrlRefresh()
	oBtnVenc:SetFocus()
Else
	oDescVencto:SetFocus()
EndIf

Return lValid

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*{Protheus.doc} STIMnRodPanel
Monta o painel do Rodape da Multi-NegociaÁ„o

@param		oPnlRodape		- Painel principal do Rodape
@param		aResume			- Representa label: Entrada,Qtd.Parc,Vencimento,Valor,Acrescimo,Total,Forma,AdminFin
@param		nLeft			- Valor da posicao da esquerda
@author  	Varejo
@version 	P12
@since   	23/09/2013
@return		NIL
@obs     
@sample
*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Static Function STIMnRodPanel(oPnlRodape,aResume,nLeft)

Local oLblResEntr 	:= NIL 			//Label Resumo da Entrada 
Local oLblQtdParc	:= NIL 			//Label Quantidade de Parcelas 
Local oLblVenParc 	:= NIL 			//Label Vencimento primeira parcela
Local oLblVlrParc	:= NIL 			//Label Valor da Parcela
Local oLblAcresci 	:= NIL 			//Label Valor do Acrescimo
Local oLblVlrTota	:= NIL			//Label Valor Total

Local nTop 	   		:= 009											//Valor de Top
Local oSay			:= NIL											//Objeto Label
Local nCol			:= (oPnlRodape:nWidth / 2) * 0.03		 		//Coordenada horizontal
Local nLargura		:= (oPnlRodape:nWidth / 2) - (2 * nCol)		//Largura

Default oPnlRodape	:= nil
Default aResume		:= {}
Default nLeft			:= 0

@ nTop,nLeft SAY oSay PROMPT STR0026 SIZE 50,40 OF oPnlRodape PIXEL HTML //"Resumo"
oSay:SetCSS( POSCSS (GetClassName(oSay), CSS_BREADCUMB )) 

nTop += 16
@ nTop,nLeft SAY oSay PROMPT STR0006 SIZE 50,40 OF oPnlRodape PIXEL HTML //"Entrada"
oSay:SetCSS( POSCSS (GetClassName(oSay), CSS_LABEL_NORMAL )) 
oLblResEntr := TSay():New(nTop+012, nLeft, {||aResume[01]}, oPnlRodape,,,,,,.T.,,,50,8)
oLblResEntr:SetCSS( POSCSS (GetClassName(oLblResEntr), CSS_LABEL_FOCAL )) 

nLeft += 65
@ nTop,nLeft SAY oSay PROMPT STR0027 SIZE 50,40 OF oPnlRodape PIXEL HTML //"Qtd.Parcelas"
oSay:SetCSS( POSCSS (GetClassName(oSay), CSS_LABEL_NORMAL )) 
oLblQtdParc := TSay():New(nTop+012, nLeft, {||aResume[02]}, oPnlRodape,,,,,,.T.,,,50,8)
oLblQtdParc:SetCSS( POSCSS (GetClassName(oLblQtdParc), CSS_LABEL_FOCAL )) 

nLeft += 65
@ nTop,nLeft SAY oSay PROMPT STR0028 SIZE 50,40 OF oPnlRodape PIXEL HTML //"Venc. 1™ Parcela"
oSay:SetCSS( POSCSS (GetClassName(oSay), CSS_LABEL_NORMAL )) 
oLblVenParc := TSay():New(nTop+012, nLeft, {||aResume[03]}, oPnlRodape,,,,,,.T.,,,50,8)
oLblVenParc:SetCSS( POSCSS (GetClassName(oLblVenParc), CSS_LABEL_FOCAL )) 

nLeft += 65
@ nTop,nLeft SAY oSay PROMPT STR0029 SIZE 50,40 OF oPnlRodape PIXEL HTML //"Valor Parcela"
oSay:SetCSS( POSCSS (GetClassName(oSay), CSS_LABEL_NORMAL)) 
oLblVlrParc := TSay():New(nTop+012, nLeft, {||aResume[04]}, oPnlRodape,,,,,,.T.,,,50,8)
oLblVlrParc:SetCSS( POSCSS (GetClassName(oLblVlrParc), CSS_LABEL_FOCAL)) 

nLeft += 65
@ nTop,nLeft SAY oSay PROMPT STR0052 SIZE 50,40 OF oPnlRodape PIXEL HTML //"Val Ate Venc"
oSay:SetCSS( POSCSS (GetClassName(oSay), CSS_LABEL_NORMAL)) 
oLblAcresci := TSay():New(nTop+012, nLeft, {||aResume[05]}, oPnlRodape,,,,,,.T.,,,50,8)
oLblAcresci:SetCSS( POSCSS (GetClassName(oLblAcresci), CSS_LABEL_FOCAL)) 

nLeft += 65
@ nTop,nLeft SAY oSay PROMPT STR0030 SIZE 50,40 OF oPnlRodape PIXEL HTML //"AcrÈscimo"
oSay:SetCSS( POSCSS (GetClassName(oSay), CSS_LABEL_NORMAL)) 
oLblAcresci := TSay():New(nTop+012, nLeft, {||aResume[10]}, oPnlRodape,,,,,,.T.,,,50,8)
oLblAcresci:SetCSS( POSCSS (GetClassName(oLblAcresci), CSS_LABEL_FOCAL)) 

nLeft += 65
@ nTop,nLeft SAY oSay PROMPT STR0031 SIZE 50 ,40 OF oPnlRodape PIXEL HTML //"Valor Total"
oSay:SetCSS( POSCSS (GetClassName(oSay), CSS_LABEL_NORMAL)) 
oLblVlrTota := TSay():New(nTop+012, nLeft, {||aResume[06]}, oPnlRodape,,,,,,.T.,,,50,8)
oLblVlrTota:SetCSS( POSCSS (GetClassName(oLblVlrTota), CSS_LABEL_FOCAL)) 

Return NIL


//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIMnConfirme
Confirma a Multi Negociacao escolhida

@param   	aResume		- Representa label: Entrada,Qtd.Parc,Vencimento,Valor,Acrescimo,Total,Forma,AdminFin
@param   	oMainPanel	- Painel de MultiNegociacao
@param   	aTypeDown	- Conteudo dos tipos de Entrada
@param   	aTpDownPay	- Array com conteudo de 8 labels referentes a entrada
@author  	Varejo
@version 	P12
@since   	23/09/2013
@return   	lRet
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Static Function STIMnConfirme( aResume,oMainPanel,aTypeDown,aTpDownPay,aLblPayForms )

Local lRet			:= .T.								//Variavel de Retorno
Local oMdl 			:= FwLoadModel("STIPayMultiNeg")	//Recupera o model ativo
Local oMdlGrd		:= oMdl:GetModel("MUNEGMASTER")		//Seta o model do grid
Local cValor		:= ""								//Valor da Venda apos multi-negociacao
Local nFor			:= 0								//Variavel de LaÁo
Local lEntrada		:= .F.								//Indica de eh entrada
Local lLimpaPag		:= .T.								//Indica de deve limpar pagamento em STIPayment
Local nAcresc		:= Val(StrTran(StrTran(aResume[10],",",""),".",""))/100
Local lMvLjIcmJ		:= ( Lj950Acres(SM0->M0_CGC) .OR. (SuperGetMV("MV_LJICMJR",,.F.) .AND. cPaisLoc == "BRA") ) //Indica se nao Incide ICMS sobre juros de operacoes Financeiras
Local oTotal		:= STFGetTot() 						// Totalizador
Local cEstado		:= SuperGetMV("MV_ESTADO") 			// Estado
Local nTotalMN		:= 0								// Total da Venda
Local nVLBonif		:= 0								// Consulta o STIGetBonif() 
Local aAcresc		:= {} 
Local lRecebTitle 	:= STIGetRecTit()					// Indica se eh recebimento de titulos
Local nQtMinPar     := 0								// Quantidade minima de parcelas
Local nQtParc		:= 0								// Quantidade de parcelas selecionadas

Default aResume		:= {}
Default oMainPanel	:= nil
Default aTypeDown	:= {}
Default aTpDownPay	:= {}
Default aLblPayForms := {} 


If Len(aResume) > 0 .And. Len(aLblPayForms) > 0
	nQtMinPar :=  Val(SubStr(aLblPayForms[03], 1, 2))
	nQtParc   :=  Val(aResume[2])
	If nQtParc <  nQtMinPar 
		 STFMessage("STIMnConfirme","POPUP", STR0053)  // Quantidade de parcelas selecionada È inferior ao definido no cadastro
		 STFShowMessage("STIMnConfirme")
		 lRet := .F.
	EndIf 
EndIf 

If lRet
	If FindFunction("STIGetBonif")
		nVLBonif := STIGetBonif(.F.)
	Endif
	
	oMdlGrd:DeActivate()
	oMdlGrd:Activate()
	
	// Pagamento com cart„o de crÈdito ou dÈbito
	If aResume[07] $ "CC|CD" .Or. aScan(aTpDownPay, {|x| AllTrim(x[2]) $ "CC/CD"}) > 0
		STITEFMultNeg(aResume,aTpDownPay)
		lvalidneg := .T.
		STIFMultNeg(.T.)
	Else
		lvalidneg := .F.
		STIFMultNeg(.F.)
	EndIf
	
	// Se os labels estiverem vazios retorno 
	If Empty(aResume[02]+aResume[03]+aResume[04]+aResume[05]+aResume[06])
		lRet := .F.
		STFMessage(ProcName(),"STOP",STR0043) //"Selecione uma NegociaÁ„o."
		STFShowMessage(ProcName())	
		STFCleanMessage(ProcName())
	EndIF
	
	If Empty(aBrwContent)
		lRet := .F.
		STFMessage(ProcName(),"STOP",STR0044) //"FaÁa uma simulaÁ„o com as formas de pagamentos."
		STFShowMessage(ProcName())	
		STFCleanMessage(ProcName())
	EndIF
	
	nTotalMN := ( Val(StrTran(StrTran(aResume[06],",",""),".",""))/100 ) + ( Val(StrTran(StrTran(aResume[01],",",""),".",""))/100 )
	If cEstado == "SP" .AND. nTotalMN > 10000
		STFMessage(ProcName(),"STOP",STR0050) //"N„o È permitido vendas acima de 10.000, redefina a multinegociaÁ„o para continuar!"
		STFShowMessage(ProcName())
		lRet := .F.
	EndIf
EndIf	

If lRet 
	For nFor := 1 To LEN(aTpDownPay) + 1 // Processa todas as Entradas e por fim processa a Negociacao escolhida.
	
	    //Entradas - Ser· todos FOR menos o ultimo
		If lRet .AND. nFor < LEN(aTpDownPay) + 1 .AND. !EMPTY(aTpDownPay[nFor][01])
			lEntrada := .T.		
			cValor := ALLTRIM( SUBSTR(aTpDownPay[nFor][01],At("-",aTpDownPay[nFor][01])+1,LEN(aTpDownPay[nFor][01])) )
			
			oMdlGrd:LoadValue( "L4_FILIAL"	, xFilial("MEX") )
			oMdlGrd:LoadValue( "L4_DATA"	, dDataBase )
			oMdlGrd:LoadValue( "L4_PARCELA"	, 1 ) //Uma parcela por tipo de Entrada
			oMdlGrd:LoadValue( "L4_ADMINIS"	, "" )
			oMdlGrd:LoadValue( "L4_VALOR"	, Val(StrTran(StrTran(cValor,",",""),".",""))/100 )
			oMdlGrd:LoadValue( "L4_ACRSFIN"	, 0 ) // N„o tem acrÈscimo para Entrada
		EndIF
		
		// Negociacao Escolhida - Ser· o ultimo FOR
	    If (lRet .OR. !lEntrada) .AND. nFor == LEN(aTpDownPay) + 1
		    lEntrada := .F.	
			lRet := .T.
			oMdlGrd:LoadValue( "L4_FILIAL"	, xFilial("MEX") )
			oMdlGrd:LoadValue( "L4_DATA"	, CToD(aResume[03]) )
			oMdlGrd:LoadValue( "L4_PARCELA"	, Val(aResume[02]) )
			oMdlGrd:LoadValue( "L4_ADMINIS"	, aResume[08] )
			oMdlGrd:LoadValue( "L4_FORMA"	, aResume[07] ) 
			If lMvLjIcmJ .And. !(Alltrim(aResume[07]) $ "CC/CD") 
				oMdlGrd:LoadValue( "L4_VALOR"	, Val(StrTran(StrTran(aResume[06],",",""),".",""))/100 - nAcresc )
				oMdlGrd:LoadValue( "L4_ACRSFIN"	, nAcresc ) // Se juros separado do total, gravo o acrÈscimo separado.
			Elseif lRecebTitle
				oMdlGrd:LoadValue( "L4_VALOR"	, Val(StrTran(StrTran(aResume[06],",",""),".",""))/100 - nAcresc )
				oMdlGrd:LoadValue( "L4_ACRSFIN"	, 0 )
			Else
				oMdlGrd:LoadValue( "L4_VALOR"	, Val(StrTran(StrTran(aResume[06],",",""),".",""))/100)
				oMdlGrd:LoadValue( "L4_ACRSFIN"	, 0 )
			EndIf
		EndIf
		
		//Validacoes
		If lRet .AND. oMdlGrd:GetValue("L4_VALOR") <= 0
			lRet := .F.
			STFMessage(ProcName(),"STOP",STR0016) //"O valor deve ser maior que zero"
			STFShowMessage(ProcName())	
			STFCleanMessage(ProcName())
		EndIf
		If lRet .AND. oMdlGrd:GetValue("L4_DATA") < dDataBase
			lRet := .F.
			STFMessage(ProcName(),"STOP",STR0017)// "A data de pagamento deve ser maior ou igual a data atual"
			STFShowMessage(ProcName())	
			STFCleanMessage(ProcName())
		EndIf	
		If lRet .AND. oMdlGrd:GetValue("L4_PARCELA") < 1
			lRet := .F.
			STFMessage(ProcName(),"STOP",STR0018) //"N∫ de parcelas n„o pode ser zero"
			STFShowMessage(ProcName())	
			STFCleanMessage(ProcName())
		EndIf		
		
		If lRet	

			If lLimpaPag		// Se nao limpou os pagamentos em STIPayment, deve ser limpo
				oPanelAdcMult:MovetoBottom()
				STIExchangePanel({|| STIPayment(.F.) })  // aqui o parametro eh falso para nao gerar forma de pagametno padrao quando vem da multnegociacao
				lLimpaPag := .F.
			EndIf
		
			If lEntrada .AND. !EMPTY(aTpDownPay[nFor][01])	// Se for entrada e Tiver entrada no array aTpDownPay
				//Para n„o chamar a tela de CC/CD com valor duplicado
				If !AllTrim(aTpDownPay[nFor][02]) $ "CC/CD/PX"
					STIAddPay(aTpDownPay[nFor][02], oMdlGrd, oMdlGrd:GetValue("L4_PARCELA"),.F.)
				EndIf

			ElseIf !lEntrada								// Se nao for entrada eh a Negociacao escolhida
				STBSetEnt()									//Limpa a entrada para recriar novamente quando existir
				If STDGetNCCs("2") > 0 // tem credito a considerar nas formas de pagamento
					STIAddPay("CR", Nil, 1, Nil, Nil, STDGetNCCs("2"))
				EndIf
				//Para n„o chamar a tela de CC/CD com valor duplicado
				If !AllTrim(aResume[07]) $ "CC/CD"
					STIAddPay(aResume[07], oMdlGrd, oMdlGrd:GetValue("L4_PARCELA"),.F.)					
				EndIf

				STIMultiCancel(oMainPanel,lRet)				// Passa neste ponto apenas na ultima vez (N„o Entrada) para finalizar a Multi-Negociacao
			EndIf

		EndIf	
	Next nFor
    If nVLBonif > 0
      //Atualiza o resumo de pagamentos = GD	
      STIAddPay("BF", Nil, 1, Nil, Nil, nVLBonif)     //Bonificacao
    Endif
EndIF

//Tratamento relacionado ao acrescimo da multinegociaÁ„o
If lRet .AND. (!lMvLjIcmJ .Or. (lMvLjIcmJ .And. (Alltrim(aResume[07]) $ "CC/CD"))) .AND. nAcresc > 0 .AND. !lRecebTitle
	aAcresc := STBDiscConvert(nAcresc, 'V' )
	STWAddIncrease(aAcresc[1], aAcresc[2])
	
	//Atualiza frete e acrescimo no STBValues()
	STBValues()
EndIf

If lRet
	STITEFMultNeg(,,.T.) //limpa variaveis staticas
	aItens := {} //Limpa a variavel depois que confirmar a multinegociacao
	STISetMult(.T.) //Eh multinegociacao
	oListTpPaym := STIGetLstB()
	oListTpPaym:bWhen :=  {||.F.}
EndIf	

Return lRet

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIMultiCancel
Cancela a Multi Negociacao

@param   	oMainPanel	- Painel de MultiNegociacao
@param   	lConfirm	- Representa se · confirmaÁ„o
@author  	Varejo
@version 	P12
@since   	23/09/2013
@return  	NIL	
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Static Function STIMultiCancel(oMainPanel,lConfirm)

Default oMainPanel := {}
Default lConfirm := .F.		// Representa se · confirmaÁ„o

STISetRDlg()
STIGridCupRefresh()

oPanelAdcMult:MovetoBottom()

if oPanelAdcMult <> nil
	oPanelAdcMult:FreeChildren() 
 	Freeobj(oPanelAdcMult)
Endif 

If !lConfirm
	STICallPayment()
	STIZeraPay()
EndIf


Return NIL

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STBMnAjustItens
Retornar a tela das formas de pagamento

@param   	aColsItens	- aCols de SL2
@param   	aHeadItens	- aHeaders de SL2
@author  	Vendas & CRM
@version 	P12
@since   	15/04/2013
@return  	
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Static Function STBMnAjustItens(aColsItens,aHeadItens)
Local aRet	:= {}					//Retorno da FunÁ„o
Local nFor	:= 0					//Laco For 

Default aColsItens := {}
Default aHeadItens := {}

For nFor := 1 TO LEN(aColsItens)
	aAdd(aRet,{					   		;
		Val(aColsItens[nFor][aScan( aHeadItens,{|x| x[2]=='L2_ITEM'} )	]) 	,	;	// Item
		aColsItens[nFor][aScan( aHeadItens,{|x| x[2]=='L2_PRODUTO'} )	]  	,	;	// Cod Produto
		aColsItens[nFor][aScan( aHeadItens,{|x| x[2]=='L2_PRODUTO'} )	] 	,	;	// Cod Barras
		aColsItens[nFor][aScan( aHeadItens,{|x| x[2]=='L2_DESCRI'} )	] 	,	;	// Descricao
		aColsItens[nFor][aScan( aHeadItens,{|x| x[2]=='L2_QUANT'} )	] 	,	;	// Quantidade
		aColsItens[nFor][aScan( aHeadItens,{|x| x[2]=='L2_VRUNIT'} )	] 	,	;	// Vlr Unit
		aColsItens[nFor][aScan( aHeadItens,{|x| x[2]=='L2_VLRITEM'} )	] 	,	;	// Vlr Item
		aColsItens[nFor][aScan( aHeadItens,{|x| x[2]=='L2_VALDESC'} )	] 	,	;	// Vlr Desconto
		aColsItens[nFor][aScan( aHeadItens,{|x| x[2]=='L2_SITTRIB'} )	]  	,	;	// Aliquota
		aColsItens[nFor][aScan( aHeadItens,{|x| x[2]=='L2_VALIPI'} )	]	,	;	// IPI
		.F.																	,	;	
		aColsItens[nFor][aScan( aHeadItens,{|x| x[2]=='L2_ICMSRET'} )	] 	,	;	// Valor Icms retido
		aColsItens[nFor][aScan( aHeadItens,{|x| x[2]=='L2_BRICMS'} )	]	,	;	// Deducao Icms
		Val(aColsItens[nFor][aScan( aHeadItens,{|x| x[2]=='L2_ITEM'} )	]) 	,	;	// Cod. ANVISA
		aColsItens[nFor][LEN(aColsItens[nFor])] 	   								,	;	// .F.
		aColsItens[nFor][LEN(aColsItens[nFor])-1]   									;	// .T.
		})
Next nFor

Return aRet

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} ModelDef
Monta a estrutura do model

@param   	
@author  	Varejo
@version 	P12
@since   	23/09/2013
@return  	oModel   - Retorno o Modelo de dados
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Static Function ModelDef()

Local oStruMst 	:= FWFormModelStruct():New() 	//Variavel para criar a estrutura da tabela
Local oModel 	:= Nil 							//Utilizada para carregar o model

oModel := MPFormModel():New('STIPayMultiNeg')
oModel:SetDescription(STR0009) //"Pagamento Multi-Negociado"

oStruMst:AddTable("SL4",{"L4_FILIAL"},STR0007) //"Pagamento"

oStruMst := STIStruMod(oStruMst)
oModel:AddFields( 'MUNEGMASTER', Nil, oStruMst)
oModel:GetModel ( 'MUNEGMASTER' ):SetDescription(STR0008) //"Selecionar Pagamento"

Return oModel


//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIStruMod
Monta a estrutura do model

@param   	oStruMst - Objeto para criar a estrutura da tabela
@author  	Varejo
@version 	P12
@since   	23/09/2013
@return  	oStruMst - Retorno da estrutura
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Static Function STIStruMod(oStruMst)

Default oStruMst 	:= Nil

oStruMst:AddField( 		STR0010		,; //[01] Titulo do campo	//"Filial"
						STR0010		,; //[02] Desc do campo		//"Filial"
						"L4_FILIAL"	,; //[03] Id do Field
						"C"				,; //[04] Tipo do campo
						8				,; //[05] Tamanho do campo
						0				,; //[06] Decimal do campo
						Nil				,; //[07] Code-block de validacao do campo
						Nil				,; //[08] Code-block de validacao When do campo
						Nil				,; //[09] Lista de valores permitido do campo
						Nil				,; //[10] Indica se o campo tem preenchimento obrigatorio
						Nil				,; //[11] Code-block de inicializacao do campo
						Nil				,; //[12] Indica se trata-se de um campo chave
						Nil				,; //[13] Indica se o campo pode receber valor em uma operacao de update.
						.F.				)  //[14] Indica se o campo e virtual

oStruMst:AddField( 		STR0051		,; //[01] Titulo do campo	//"Tipo"
						STR0051		,; //[02] Desc do campo		//"Tipo"
						"L4_FORMA"	,; //[03] Id do Field
						"C"			,; //[04] Tipo do campo
						2			,; //[05] Tamanho do campo
						0			,; //[06] Decimal do campo
						Nil			,; //[07] Code-block de validacao do campo
						Nil			,; //[08] Code-block de validacao When do campo
						Nil			,; //[09] Lista de valores permitido do campo
						.T.			,; //[10] Indica se o campo tem preenchimento obrigatorio
						Nil			,; //[11] Code-block de inicializacao do campo
						Nil			,; //[12] Indica se trata-se de um campo chave
						Nil			,; //[13] Indica se o campo pode receber valor em uma operacao de update
						.F.			)  //[14] Indica se o campo e virtual

oStruMst:AddField( 		STR0011		,; //[01] Titulo do campo	//"Valor"
						STR0011		,; //[02] Desc do campo		//"Valor"
						"L4_VALOR"	,; //[03] Id do Field
						"N"			,; //[04] Tipo do campo
						16			,; //[05] Tamanho do campo
						2			,; //[06] Decimal do campo
						Nil			,; //[07] Code-block de validacao do campo
						Nil			,; //[08] Code-block de validacao When do campo
						Nil			,; //[09] Lista de valores permitido do campo
						.T.			,; //[10] Indica se o campo tem preenchimento obrigatorio
						Nil			,; //[11] Code-block de inicializacao do campo
						Nil			,; //[12] Indica se trata-se de um campo chave
						Nil			,; //[13] Indica se o campo pode receber valor em uma operacao de update
						.F.			)  //[14] Indica se o campo e virtual
						
oStruMst:AddField( 		STR0014	,; //[01] Titulo do campo   //"Data do Orcamento"
						STR0014	,; //[02] Desc do campo		//"Data do Orcamento"
						"L4_DATA",; //[03] Id do Field
						"D"			,; //[04] Tipo do campo
						8			,; //[05] Tamanho do campo
						0			,; //[06] Decimal do campo
						Nil			,; //[07] Code-block de validacao do campo
						Nil			,; //[08] Code-block de validacao When do campo
						Nil			,; //[09] Lista de valores permitido do campo
						.T.			,; //[10] Indica se o campo tem preenchimento obrigatorio
						FwBuildFeature( STRUCT_FEATURE_INIPAD,"dDataBase" )			,; //[11] Code-block de inicializacao do campo
						Nil			,; //[12] Indica se trata-se de um campo chave
						Nil			,; //[13] Indica se o campo pode receber valor em uma operacao de update
						.F.			)  //[14] Indica se o campo e virtual			
						
oStruMst:AddField( 		STR0012	,; //[01] Titulo do campo	//"Num. Parcelas"
						STR0012	,; //[02] Desc do campo		//"Num. Parcelas"
						"L4_PARCELA",; //[03] Id do Field
						"N"			,; //[04] Tipo do campo
						2			,; //[05] Tamanho do campo
						0			,; //[06] Decimal do campo
						Nil			,; //[07] Code-block de validacao do campo
						Nil			,; //[08] Code-block de validacao When do campo
						Nil			,; //[09] Lista de valores permitido do campo
						.T.			,; //[10] Indica se o campo tem preenchimento obrigatorio
						FwBuildFeature( STRUCT_FEATURE_INIPAD,"1" )			,; //[11] Code-block de inicializacao do campo
						Nil			,; //[12] Indica se trata-se de um campo chave
						Nil			,; //[13] Indica se o campo pode receber valor em uma operacao de update
						.T.			)  //[14] Indica se o campo e virtual		
						
oStruMst:AddField( 		STR0013	,; //[01] Titulo do campo	//"Adm. Financeira"
						STR0013	,; //[02] Desc do campo		//"Adm. Financeira"
						"L4_ADMINIS",; //[03] Id do Field
						"C"			,; //[04] Tipo do campo
						20			,; //[05] Tamanho do campo
						0			,; //[06] Decimal do campo
						Nil			,; //[07] Code-block de validacao do campo
						Nil			,; //[08] Code-block de validacao When do campo
						Nil			,; //[09] Lista de valores permitido do campo
						.T.			,; //[10] Indica se o campo tem preenchimento obrigatorio
						Nil			,; //[11] Code-block de inicializacao do campo
						Nil			,; //[12] Indica se trata-se de um campo chave
						Nil			,; //[13] Indica se o campo pode receber valor em uma operacao de update
						.F.			)  //[14] Indica se o campo e virtual							

oStruMst:AddField(		STR0049	,; //[01] Titulo do campo 	//"Acres Fin"
						STR0049	,; //[02] Desc do campo  	//"Acres Fin"
						"L4_ACRSFIN"	,; //[03] Id do Field
						"N"				,; //[04] Tipo do campo
						6				,; //[05] Tamanho do campo
						2				,; //[06] Decimal do campo
						Nil				,; //[07] Code-block de validacao do campo
						Nil				,; //[08] Code-block de validacao When do campo
						Nil				,; //[09] Lista de valores permitido do campo
						Nil				,; //[10] Indica se o campo tem preenchimento obrigatorio
						Nil				,; //[11] Code-block de inicializacao do campo
						Nil				,; //[12] Indica se trata-se de um campo chave
						Nil				,; //[13] Indica se o campo pode receber valor em uma operacao de update
						.T.				)  //[14] Indica se o campo e virtual																					
Return oStruMst


//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIStruVie
Monta a estrutura do model

@param   	oStruMst - Objeto para criar a estrutura da tabela
@author  	Varejo
@version 	P12
@since   	23/09/2013
@return  	oStruMst - Retorno da estrutura
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Static Function STIStruVie(oStruMst)

Default oStruMst	:= Nil

oStruMst:AddField(	"L4_ADMINIS"	   		,; //[01] CIDFIELD - ID DO FIELD
						"01"				,; //[02] CORDEM - ORDEM DO CAMPO
						STR0013				,; //[03] CTITULO - TITULO DO CAMPO 			//"Adm. Financeira"
						STR0013				,; //[04] CDESCRIC - ESCRICAO COMPLETA DO CAMPO	//"Adm. Financeira"
						{}					,; //[05] AHELP - ARRAY COM O HELP DOS CAMPOS
						"C"					,; //[06] CTYPE - TIPO
						"@!"				,; //[07] CPICTURE - PICTURE DO CAMPO
						Nil					,; //[08] BPICTVAR - BLOCO DE PICTURE VAR
						""					,; //[09] CLOOKUP - CHAVE PARA SER USADO NO LOOKUP
						.T.					,; //[10] LCANCHANGE - LOGICO DIZENDO SE O CAMPO PODE SER ALTERADO
						Nil					,; //[11] CFOLDER - ID DA FOLDER ONDE O FIELD ESTA
						Nil					,; //[12] CGROUP - ID DO GROUP ONDE O FIELD ESTA
						Nil					,; //[13] ACOMBOVALUES - ARRAY COM OS VALORES DO COMBO
						Nil					,; //[14] NMAXLENCOMBO - TAMANHO MAXIMO DA MAIOR OPÁ„O DO COMBO
						Nil					,; //[15] CINIBROW - INICIALIZADOR DO BROWSE
						.F.					,; //[16] LVIRTUAL - INDICA SE O CAMPO È VIRTUAL
						Nil					)  //[17] CPICTVAR - PICTURE VARIAVEL

oStruMst:AddField( 	"L4_VALOR"		   		,; //[01] CIDFIELD - ID DO FIELD
						"02"				,; //[02] CORDEM - ORDEM DO CAMPO
						STR0011		  		,; //[03] CTITULO - TITULO DO CAMPO				//"Valor"
						STR0011		 		,; //[04] CDESCRIC - ESCRICAO COMPLETA DO CAMPO //"Valor"
						{}					,; //[05] AHELP - ARRAY COM O HELP DOS CAMPOS
						"N"					,; //[06] CTYPE - TIPO
						"@E 999,999.99"		,; //[07] CPICTURE - PICTURE DO CAMPO
						Nil					,; //[08] BPICTVAR - BLOCO DE PICTURE VAR
						""					,; //[09] CLOOKUP - CHAVE PARA SER USADO NO LOOKUP
						.T.					,; //[10] LCANCHANGE - LOGICO DIZENDO SE O CAMPO PODE SER ALTERADO
						Nil					,; //[11] CFOLDER - ID DA FOLDER ONDE O FIELD ESTA
						Nil					,; //[12] CGROUP - ID DO GROUP ONDE O FIELD ESTA
						Nil					,; //[13] ACOMBOVALUES - ARRAY COM OS VALORES DO COMBO
						Nil					,; //[14] NMAXLENCOMBO - TAMANHO MAXIMO DA MAIOR OPÁ„O DO COMBO
						Nil					,; //[15] CINIBROW - INICIALIZADOR DO BROWSE
						.F.					,; //[16] LVIRTUAL - INDICA SE O CAMPO È VIRTUAL
						Nil					)  //[17] CPICTVAR - PICTURE VARIAVEL
						
oStruMst:AddField(	"L4_DATA"				,; //[01] CIDFIELD - ID DO FIELD
						"03"				,; //[02] CORDEM - ORDEM DO CAMPO
						STR0014				,; //[03] CTITULO - TITULO DO CAMPO				//"Data do Orcamento"
						STR0014				,; //[04] CDESCRIC - ESCRICAO COMPLETA DO CAMPO	//"Data do Orcamento"
						{}					,; //[05] AHELP - ARRAY COM O HELP DOS CAMPOS
						"D"					,; //[06] CTYPE - TIPO
						""					,; //[07] CPICTURE - PICTURE DO CAMPO
						Nil					,; //[08] BPICTVAR - BLOCO DE PICTURE VAR
						""					,; //[09] CLOOKUP - CHAVE PARA SER USADO NO LOOKUP
						.T.					,; //[10] LCANCHANGE - LOGICO DIZENDO SE O CAMPO PODE SER ALTERADO
						Nil					,; //[11] CFOLDER - ID DA FOLDER ONDE O FIELD ESTA
						Nil					,; //[12] CGROUP - ID DO GROUP ONDE O FIELD ESTA
						Nil					,; //[13] ACOMBOVALUES - ARRAY COM OS VALORES DO COMBO
						Nil					,; //[14] NMAXLENCOMBO - TAMANHO MAXIMO DA MAIOR OPÁ„O DO COMBO
						Nil					,; //[15] CINIBROW - INICIALIZADOR DO BROWSE
						.F.					,; //[16] LVIRTUAL - INDICA SE O CAMPO È VIRTUAL
						Nil					)  //[17] CPICTVAR - PICTURE VARIAVEL		
						
oStruMst:AddField(	"L4_PARCELA"			,; //[01] CIDFIELD - ID DO FIELD
						"04"				,; //[02] CORDEM - ORDEM DO CAMPO
						STR0012				,; //[03] CTITULO - TITULO DO CAMPO 			//"Num. Parcelas"
						STR0012				,; //[04] CDESCRIC - ESCRICAO COMPLETA DO CAMPO	//"Num. Parcelas"
						{}					,; //[05] AHELP - ARRAY COM O HELP DOS CAMPOS
						"N"					,; //[06] CTYPE - TIPO
						"99"				,; //[07] CPICTURE - PICTURE DO CAMPO
						Nil					,; //[08] BPICTVAR - BLOCO DE PICTURE VAR
						""					,; //[09] CLOOKUP - CHAVE PARA SER USADO NO LOOKUP
						.T.					,; //[10] LCANCHANGE - LOGICO DIZENDO SE O CAMPO PODE SER ALTERADO
						Nil					,; //[11] CFOLDER - ID DA FOLDER ONDE O FIELD ESTA
						Nil					,; //[12] CGROUP - ID DO GROUP ONDE O FIELD ESTA
						Nil					,; //[13] ACOMBOVALUES - ARRAY COM OS VALORES DO COMBO
						Nil					,; //[14] NMAXLENCOMBO - TAMANHO MAXIMO DA MAIOR OPÁ„O DO COMBO
						Nil					,; //[15] CINIBROW - INICIALIZADOR DO BROWSE
						.F.					,; //[16] LVIRTUAL - INDICA SE O CAMPO È VIRTUAL
						Nil					)  //[17] CPICTVAR - PICTURE VARIAVEL																														
									
Return oStruMst

/*{Protheus.doc} STIDescMltNeg
Verifica se teve desconto na tela de multinegociaÁ„o

@param   	lRet			.T. 
@author  	Vendas & CRM
@version 	P11
@since   	05/08/2015
@return  	lmultineg
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIDescMltNeg(lRet)
DEFAULT lRet := .F.

lRet := lmultineg

Return lRet


//-------------------------------------------------------------------
/*{Protheus.doc} STITEFMultNeg
Retorna se a condiÁ„o de pagamento È do tipo CC ou CD

@param   	aResume
@author  	Vendas & CRM
@version 	P11
@since   	11/08/2015
@return  	oTefMultNeg
@obs     
@sample
/*/
//-------------------------------------------------------------------

Function STITEFMultNeg(aResume,aEntrada,lLimpa)
Local nI 			:= 0
Local cTpForma 		:= ""
Local nValor 		:= 0
Local nParcela 		:= 0

Default aResume		:= {}
Default aEntrada	:= {}
Default lLimpa		:= .F.

/* Estrutura do array
oTefMultNeg[1] = Tipo da forma de pagamento
oTefMultNeg[2] = Valor da forma de pagamento
oTefMultNeg[3] = Parcela da forma de pagamento
*/

If lLimpa
	oTefMultNeg := Nil
	lvalidneg	:= .F.
	STIFMultNeg(.F.)

ElseIf oTefMultNeg == Nil
	oTefMultNeg := {}
	//Pegando Entrada
	For nI := 1 To Len(aEntrada)
		cTpForma := AllTrim(aEntrada[nI][2])
		If !Empty(aEntrada[nI][1]) .And. cTpForma $ "CC/CD/PX"
			aEntrada[nI][01] := StrTran(aEntrada[nI][01],".","")  //removemos o ponto para o Val funcionar
			nValor	 := VAL(StrTran(ALLTRIM( SUBSTR(aEntrada[nI][01],At("-",aEntrada[nI][01])+1,LEN(aEntrada[nI][01])) ),",","."))
			nParcela := 1
			aAdd(oTefMultNeg, {cTpForma,nValor,nParcela,.T.})	
		EndIf
	Next
	
	If Len(aResume) > 1 .And. AllTrim(aResume[07]) $ "CC/CD"
		cTpForma := AllTrim(aResume[07])
		nValor	 := Val(StrTran(StrTran(aResume[06],'.',''),',','.'))
		nParcela := Val(StrTran(aResume[02],",","."))
		aAdd(oTefMultNeg, {cTpForma,nValor,nParcela,.F.})
	EndIf
	
EndIf

Return oTefMultNeg


//-------------------------------------------------------------------
/*{Protheus.doc} STIFMultNeg
Verifica se multinegocicao tem pagamento com CC ou CD

@param   	lRet			
@author  	Vendas & CRM
@version 	P11
@since   	11/08/2015
@return  	lvalidneg
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIFMultNeg(lRet)
Default lvalidneg := .F.

lRet := lvalidneg

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} STIGetMult
Retorna o conteudo da variavel lMultNeg

@param   				
@author  	Bruno Almeida
@version 	P12
@since   	04/02/2019
@return  	lMultNeg
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIGetMult()
Return lMultNeg

//-------------------------------------------------------------------
/*{Protheus.doc} STISetMult
Alimenta a variavel lMultNeg

@param		lNegoc   				
@author  	Bruno Almeida
@version 	P12
@since   	04/02/2019
@return  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STISetMult(lNegoc)

Default lNegoc := .F.

lMultNeg := lNegoc

Return lMultNeg

