#INCLUDE 'PROTHEUS.CH'
#INCLUDE "POSCSS.CH"
#INCLUDE "STPOS.CH"
#INCLUDE "STIRECESEL.CH"

Static oLst 			:= Nil 		//Listbox dos titulos
Static aLst	 			:= {} 		//Lista dos titulos
Static lIsRec			:= .F.		//Variavel que informa se e ou nao recebimento
Static nLargura			:= 0		//Largura
Static oMulta			:= Nil		//Get Multa
Static oJuros			:= Nil		//Get Juros
Static oDesconto		:= Nil		//Get Desconto
Static oVlrTot			:= Nil		//Get Total
Static oQtdTitSel		:= Nil		//Get Quant. Títulos Selecionados	
Static oVlrTotAPagar	:= Nil		//Get Total SELECIONADOS
Static oTotOrig			:= Nil		//Get Valor
Static nGetMulta		:= 0		//Variavel get da multa
Static nGetJuros		:= 0		//Variavel get de juros
Static nGetDesconto		:= 0		//Variavel get de desconto
Static nGetVlrTot		:= 0		//Variavel get de valor total
Static nGetQtdTitSel	:= 0		//Variavel get de quant. de títulos selecionados
Static nGetVlrAPagar	:= 0		//Variavel get de valor total dos SELECIONADOS
Static nGetTotOrig		:= 0		//Variavel get da valor
Static nGetVlrAcres		:= 0		//Variavel get de valor de acrescimo
Static oBtnOk			:= Nil		//Botao de baixar as parcelas
Static oObjRec 			:= Nil		//Retorna o objeto da classe do recebimento de titulo
Static aLista			:= {}		//Lista dos Titulos
Static aSelecionado  	:= {}		//Lista dos Titulos SELECIONADOS
Static lAtuValores		:= .F.		//Habilita a edição dos campos de multa/juros e desconto (Editavel = .T. / Bloqueado  = .F.)
Static lAtuValMulta		:= .F.		//Habilita a edição dos campos de multao (Editavel = .T. / Bloqueado  = .F.)
Static lAtuValJuros		:= .F.		//Habilita a edição dos campos de juroso (Editavel = .T. / Bloqueado  = .F.)
Static lAtuValDesconto	:= .F.		//Habilita a edição dos campos de desconto (Editavel = .T. / Bloqueado  = .F.)
Static lAtuValtotal		:= .F.		//Habilita a edição dos campos de Total (Editavel = .T. / Bloqueado  = .F.)


//--------------------------------------------------------
/*/{Protheus.doc} STIPnlSelRece
Abre o painel para selecao dos recebimento

@param   
@author  Varejo
@version P11.8
@since   14/08/2012
@return  
/*/
//--------------------------------------------------------
Function STIPnlSelRece()

STIBtnDeActivate()
STIChangeCssBtn()
STIExchangePanel( { ||  STIReceSel() } )

Return .T.

//--------------------------------------------------------
/*/{Protheus.doc} STIReceSel
Monta painel com opcoes para a selecao dos recebimentos

@param   
@author  Varejo
@version P11.8
@since   14/08/2012
@return  
/*/
//--------------------------------------------------------
Function STIReceSel()

Local oPanelMVC		:= STIGetPanel() 																				//Painel principal
Local oPanGetRece	:= TPanel():New(00,00,"",oPanelMVC,,,,,,oPanelMVC:nWidth/2,(oPanelMVC:nHeight)/2)	//Objeto do painel
Local nTamAltListBox	:= oPanelMVC:nHeight * 0.11	//Tamanho: Altura do ListBox
Local cTpOp			:= STIGetTpOp()					//Tipo de operacao
Local nList			:= 1							//Para o TListBox
Local bValid		:= {|| .T.}						//Valida baixa de titulo
Local bButon		:= {|| iIf(Eval(bValid),STIBaixaTit(),Nil)}	//Botão Baixa/Estorno
Local aSalesMan		:= IIF(FindFunction('STDFindSMan'),STDFindSMan(),{}) //Carrega o nome do vendedor
Local aCustomer		:= IIF(FindFunction('STDFindCust'),STDFindCust(),{}) //Carrega informacoes do cliente Nome/Cpf 
Local oSay15		:=	Nil
Local oSay16		:= Nil //Objeto TSay = Tipo

/* Sempre iniciar a operação de um Recebimento de Titulo com as informações zeradas */
nGetTotOrig		:= 0
nGetMulta		:= 0
nGetJuros		:= 0
nGetDesconto	:= 0
nGetVlrTot      := 0
nGetQtdTitSel	:= 0
nGetVlrAPagar	:= 0

STFRestart()

If FindFunction("STWValidRecep")
	bValid		:= {|| STWValidRecep(cTpOp,aLista,aSelecionado)}
EndIf

oObjRec 		:= STIRetObjTit()		
oLst 			:= Nil
nLargura		:= (oPanGetRece:nWidth / 2) - (2 * ((oPanGetRece:nWidth / 2) * 0.04))					//Largura

/* oSay1 - Recebimentos de títulos > Selecionar Títulos */
If cTpOp == 'R' 
	oSay1 := TSay():New(POSVERT_CAB,POSHOR_1,{||STR0001},oPanGetRece,,,,,,.T.,,,,) //"Recebimentos de títulos > Selecionar Títulos"
Else
	oSay1 := TSay():New(POSVERT_CAB,POSHOR_1,{||STR0002},oPanGetRece,,,,,,.T.,,,,) //"Estorno de títulos > Selecionar Títulos"
EndIf
oSay1:SetCSS( POSCSS (GetClassName(oSay1),CSS_BREADCUMB )) 

/* oSay14 - Filial */
oSay14 := TSay():New(POSVERT_LABEL1,POSHOR_1,{||STR0023},oPanGetRece,,,,,,.T.,,,,)  //"Filial"
oSay14:SetCSS( POSCSS (GetClassName(oSay14),CSS_BREADCUMB)) 

/* oSay2 - Prefixo */
oSay2 := TSay():New(POSVERT_LABEL1,POSHOR_1 * 4,{||STR0003},oPanGetRece,,,,,,.T.,,,,)  //"Prefixo"
oSay2:SetCSS( POSCSS (GetClassName(oSay2),CSS_BREADCUMB)) 

/* oSay9 - Titulo */
oSay9 := TSay():New(POSVERT_LABEL1,POSHOR_1 * 7,{||STR0004},oPanGetRece,,,,,,.T.,,,,) //"Titulo"
oSay9:SetCSS( POSCSS (GetClassName(oSay9),CSS_BREADCUMB)) 

/* oSay10 - Parcela */
oSay10 := TSay():New(POSVERT_LABEL1,POSHOR_1 * 10.0,{||STR0005},oPanGetRece,,,,,,.T.,,,,)  //"Parcela"
oSay10:SetCSS( POSCSS (GetClassName(oSay10),CSS_BREADCUMB)) 

/* oSay3 - Data */
oSay3 := TSay():New(POSVERT_LABEL1,POSHOR_1 * 12.7,{||STR0006},oPanGetRece,,,,,,.T.,,,,)  //"Vencimento"
oSay3:SetCSS( POSCSS (GetClassName(oSay3),CSS_BREADCUMB)) 

/* oSay4 - Valor */
oSay4 := TSay():New(POSVERT_LABEL1,POSHOR_1 * 16.3,{||STR0007},oPanGetRece,,,,,,.T.,,,,)  //"Valor"
oSay4:SetCSS( POSCSS (GetClassName(oSay4),CSS_BREADCUMB )) 

/* oSay15 - Acrescimo */
oSay15 := TSay():New(POSVERT_LABEL1,POSHOR_1 * 18.5,{||STR0025},oPanGetRece,,,,,,.T.,,,,)  //"Acrescimo"
oSay15:SetCSS( POSCSS (GetClassName(oSay4),CSS_BREADCUMB )) 

/* oSay16 - Tipo */
oSay16 := TSay():New(POSVERT_LABEL1,POSHOR_1 * 21.5,{||STR0026},oPanGetRece,,,,,,.T.,,,,)  //"Tipo"
oSay16:SetCSS( POSCSS (GetClassName(oSay16),CSS_BREADCUMB ))

/* oLst - Listbox com os titulos */
oLst := TListBox():Create(oPanGetRece, POSVERT_GET1, POSHOR_1, {|u|if(Pcount()>0,nList:=u,nList)},;
							 STIReceLst(), nLargura, nTamAltListBox,{|| STITitAtualiza()},;
							 ,,,.T.,,;
							 {|| (STIGetValues(),lAtuValores := .F.)},,,,;
							 ,,,,,)
oLst:SetCSS( POSCSS (GetClassName(oLst),CSS_LISTBOX ))  

If cTpOp == 'R'

		/* Botao atualizar valores */
	oButton := TButton():New(POSVERT_GET2 * 1.65,POSHOR_BTNFOCAL * 0.91,STR0012,oPanGetRece,{ || Iif(lAtuValores,(STIUpdTit(),lAtuValores := .F.),Nil) },LARGBTN * 0.90,ALTURABTN * 0.75,,,,.T.,,,,)  //"Atualizar Valores" 
	oButton:SetCSS( POSCSS (GetClassName(oButton),POSVERT_BTNFOCAL )) 

	/* Botao Edita valores */
	oEdtButton := TButton():New(POSVERT_GET2 * 2.00,POSHOR_BTNFOCAL * 0.91,STR0020,oPanGetRece,{ || (lAtuValores := STIVldFldRec()) },LARGBTN * 0.90,ALTURABTN * 0.75,,,,.T.,,,,)  //"Editar Valores" 
	oEdtButton:SetCSS( POSCSS (GetClassName(oEdtButton),POSVERT_BTNFOCAL )) 

	/* oSay13 - Valor */
	oSay13 := TSay():New(POSVERT_LABEL2 * 1.51,POSHOR_1,{||STR0022},oPanGetRece,,,,,,.T.,,,,)  //"Valor Original"

	oSay13:SetCSS( POSCSS (GetClassName(oSay13),CSS_BREADCUMB ))  
	
	/* Valor Original */
	oTotOrig := TGet():New(POSVERT_GET2 * 1.40,POSHOR_1,{|u| If(PCount()>0,nGetTotOrig:=u,nGetTotOrig)},oPanGetRece,(oPanelMVC:nWidth / 2) * 0.190,ALTURAGET,"@E 99,999,999.99" ,,,,,,,.T.,,,,,,,.T.,,,"nGetTotOrig")
	oTotOrig:SetCSS( POSCSS (GetClassName(oTotOrig),CSS_GET_FOCAL )) 

	/* oSay5 - Multa */
	oSay5 := TSay():New(POSVERT_LABEL2 * 1.51,POSHOR_1 * 6.3,{||STR0008},oPanGetRece,,,,,,.T.,,,,)  //"Multa"
	
	oSay5:SetCSS( POSCSS (GetClassName(oSay5),CSS_BREADCUMB ))  
	
	/* oMulta */
	oMulta := TGet():New(POSVERT_GET2 * 1.40,POSHOR_1 * 6.3,{|u| If(PCount()>0,nGetMulta:=u,nGetMulta)},oPanGetRece,(oPanelMVC:nWidth / 2) * 0.14,ALTURAGET,"@E 999.99",{|| STIAtuVlFinal()},,,,,,.T.,,,{|| lAtuValMulta },,,,,,,"nGetMulta")
	oMulta:SetCSS( POSCSS (GetClassName(oMulta),CSS_GET_FOCAL ))  
	
	/* oMulta - Atualiza valores*/
	oMulta:bLostFocus := { || STIAtlValView("MULTA") }
	
	/* oSay6 - Juros */
	oSay6 := TSay():New(POSVERT_LABEL2 * 1.51,POSHOR_1 * 10.5,{||STR0009},oPanGetRece,,,,,,.T.,,,,)  //"Juros"
	oSay6:SetCSS( POSCSS (GetClassName(oSay6),CSS_BREADCUMB ))  
	
	/* oJuros */
	oJuros := TGet():New(POSVERT_GET2 * 1.40,POSHOR_1 * 10.5	,{|u| If(PCount()>0,nGetJuros:=u,nGetJuros)},oPanGetRece,(oPanelMVC:nWidth / 2) * 0.14,ALTURAGET,"@E 999.99",{|| STIAtuVlFinal()},,,,,,.T.,,,{|| lAtuValJuros },,,,,,,"nGetJuros")
	oJuros:SetCSS( POSCSS (GetClassName(oJuros),CSS_GET_FOCAL ))
	
	/* oJuros - Atualiza valores*/
	oJuros:bLostFocus := { || STIAtlValView("JUROS") }
	
	/* oSay7 - Desconto */
	oSay7 := TSay():New(POSVERT_LABEL2 * 1.51,POSHOR_1 * 14.6,{||STR0010},oPanGetRece,,,,,,.T.,,,,)  //"Desconto"
	oSay7:SetCSS( POSCSS (GetClassName(oSay7),CSS_BREADCUMB )) 
	
	/* oDesconto */
	oDesconto := TGet():New(POSVERT_GET2 * 1.40,POSHOR_1 * 14.6,{|u| If(PCount()>0,nGetDesconto:=u,nGetDesconto)},oPanGetRece,(oPanelMVC:nWidth / 2) * 0.14,ALTURAGET,"@E 999.99",{|| STIAtuVlFinal()},,,,,,.T.,,,{|| lAtuValdesconto },,,,,,,"nGetDesconto")
	oDesconto:SetCSS( POSCSS (GetClassName(oDesconto),CSS_GET_FOCAL )) 
	
	/* oDesconto - Atualiza valores*/
	oDesconto:bLostFocus := { || STIAtlValView("DESCONTO") }
	
	/* oSay8 - Valor Final */
	oSay8 := TSay():New(POSVERT_LABEL2 * 1.51,POSHOR_1 * 18.6,{||STR0011},oPanGetRece,,,,,,.T.,,,,)  //"Valor Final"
	oSay8:SetCSS( POSCSS (GetClassName(oSay8),CSS_BREADCUMB )) 
	
	/* oVlrTot */
	oVlrTot := TGet():New(POSVERT_GET2 * 1.40,POSHOR_1 * 18.6,{|u| If(PCount()>0,nGetVlrTot:=u,nGetVlrTot)},oPanGetRece,(oPanelMVC:nWidth / 2) * 0.225,ALTURAGET, PesqPict("SE1","E1_VALOR") ,{|| STIVldVlFinal()},,,,,,.T.,,,{|| lAtuValTotal },,,,,,,"nGetVlrTot")
	oVlrTot:SetCSS( POSCSS (GetClassName(oVlrTot),CSS_GET_FOCAL )) 

	/* oDesconto - Atualiza valores*/
	oVlrTot:bLostFocus := { || STIAtlValView("VLRTOT") }

EndIf

/* oSay12 - Qtd. Tit. Sel. */
oSay12 := TSay():New(POSVERT_LABEL2 * iif(cTpOp == "R", 1.95, 1.51) ,POSHOR_1 * 1.0,{||STR0017},oPanGetRece,,,,,,.T.,,,,)  //"Qtd. Tit. Sel."
oSay12:SetCSS( POSCSS (GetClassName(oSay12),CSS_BREADCUMB )) 
	
/* oQtdTitSel */
oQtdTitSel := TGet():New(POSVERT_GET2 * iif(cTpOp == "R", 1.75, 1.40),POSHOR_1 * 1.0,{|u| If(PCount()>0,nGetQtdTitSel:=u,nGetQtdTitSel)},oPanGetRece,(oPanelMVC:nWidth / 2) * 0.14,ALTURAGET, "9999" ,,,,,,,.T.,,,,,,,.T.,,,"nGetQtdTitSel")
oQtdTitSel:SetCSS( POSCSS (GetClassName(oQtdTitSel),CSS_GET_FOCAL )) 
	
/* oSay11 - Total a Pagar */
oSay11 := TSay():New(POSVERT_LABEL2 * iif(cTpOp == "R", 1.95, 1.51),POSHOR_1 * 6.4,{||STR0018},oPanGetRece,,,,,,.T.,,,,)  //"Total a Pagar"
oSay11:SetCSS( POSCSS (GetClassName(oSay11),CSS_BREADCUMB )) 
	
/* oVlrTotAPagar */
oVlrTotAPagar := TGet():New(POSVERT_GET2 * iif(cTpOp == "R", 1.75, 1.40),POSHOR_1 * 6.4,{|u| If(PCount()>0,nGetVlrAPagar:=u,nGetVlrAPagar)},oPanGetRece,(oPanelMVC:nWidth / 2) * 0.225,ALTURAGET, PesqPict("SE1","E1_VALOR") ,,,,,,,.T.,,,,,,,.T.,,,"nGetVlrAPagar")
oVlrTotAPagar:SetCSS( POSCSS (GetClassName(oVlrTotAPagar),CSS_GET_FOCAL )) 

/* Identificacao do vendedor */
If Len(aSalesMan) > 0
	oLblSalesMan := TSay():New(POSVERT_LABEL7,POSHOR_1,{||STR0021 + " " + AllTrim(aSalesMan[1])},oPanGetRece,,,,,,.T.,,,,100) //"Vendedor(a):"
	oLblSalesMan:SetCSS( POSCSS (GetClassName(oLblSalesMan), CSS_BREADCUMB )) 
	
	LjGrvLog( /*cNumControl*/, "Nome do Vendedor", aSalesMan[1] )//Grava Log =====================================================================
EndIf

/* Identificacao do cliente */
If Len(aCustomer) > 0
	oLblCustomer := TSay():New(POSVERT_LABEL5,POSHOR_1,{||AllTrim(aCustomer[1])},oPanGetRece,,,,,,.T.,,,,100)
	oLblCustomer:SetCSS( POSCSS (GetClassName(oLblCustomer), CSS_BREADCUMB )) 
	
	oLblCpf := TSay():New(POSVERT_LABEL6,POSHOR_1,{||AllTrim(aCustomer[2])},oPanGetRece,,,,,,.T.,,,,100)
	oLblCpf:SetCSS( POSCSS (GetClassName(oLblCpf), CSS_BREADCUMB )) 
	
	LjGrvLog( /*cNumControl*/, "Nome do Cliente"	, aCustomer[1] )//Grava Log =====================================================================
	LjGrvLog( /*cNumControl*/, "CPF/CNPJ do Cliente", aCustomer[2] )//Grava Log =====================================================================	
EndIf
	
// Inicializa Variáveis
//STITitIni()
//
//STITitAtualiza()
//oLst:Select(1)
//oLst:SetFocus()

/* Botao baixar titulo */
If cTpOp == 'R'
	oBtnOk := TButton():New(POSVERT_BTNFOCAL,POSHOR_BTNFOCAL,STR0013+CRLF+"(CTRL+B)",oPanGetRece,bButon,LARGBTN,ALTURABTN,,,,.T.) //"Baixar Titulo"
	SetKey(2,{|| STIBaixaTit() })
Else
	oBtnOk := TButton():New(POSVERT_BTNFOCAL,POSHOR_BTNFOCAL,STR0014+CRLF+"(CTRL+E)",oPanGetRece,bButon,LARGBTN,ALTURABTN,,,,.T.) //"Estornar Titulo"
	SetKey(5,{|| STIBaixaTit() })
EndIf
oBtnOk:SetCSS( POSCSS (GetClassName(oBtnOk),CSS_BTN_FOCAL ))

Return oPanGetRece

//--------------------------------------------------------
/*/{Protheus.doc} STIReceLst
Formata a lista de titulos para exibir no listbox

@param   
@author  Varejo
@version P11.8
@since   14/08/2012
@return  
/*/
//--------------------------------------------------------
Function STIReceLst(lUpdate)

Local aRet		:= {}									// Array de Retorno
Local nX		:= 0									// Contador
Local nGetPos := 0									// Posição do TListBox 

Default lUpdate := .F.

aRet := {}
aLista		:= STIGetTitles()
If ValType(oLst) = "O"
	nGetPos	:= oLst:GetPos()
Else
	STISetTitSelecionado(0)
EndIf

For nX := 1 To Len(aLista)
	aAdd( aRet, STITitDescricao(nX) )
Next nX

If lUpdate
	If oLst:Len() = 0
		oLst:Reset()
		oLst:SetArray(aRet)
	Else
		oLst:Modify(aRet[nGetPos],nGetPos)
	EndIf
EndIf

Return aRet

//--------------------------------------------------------
/*/{Protheus.doc} STIUpdTit
Atualização de juros, multa e desconto no valor dos titulos

@param   
@author  Varejo
@version P11.8
@since   14/08/2012
@return  
/*/
//--------------------------------------------------------
Function STIUpdTit(lAtualiza	,nLine	,nDescTit	,nVlrTit,;
                   _nGetMulta	,_nGetJuros)

DEFAULT nLine	   := oLst:GetPos()		// Linha selecionada
DEFAULT nDescTit   := 0 
DEFAULT nVlrTit    := 0
DEFAULT lAtualiza  := .T.
DEFAULT _nGetMulta := 0
DEFAULT _nGetJuros := 0

/* Caso os valores abaixo estejam preenchidos, eh por que vieram do PE STIVALIDREC e ignoraram a informacao 
   do padrao que esta na tela.
*/

If nDescTit > 0 
	nGetDesconto := nDescTit
EndIf

If nVlrTit > 0 
	nGetVlrTot := nVlrTit
EndIf

If _nGetMulta > 0
	nGetMulta := _nGetMulta 
EndIf

If _nGetJuros > 0
	nGetJuros := _nGetJuros
EndIf

oObjRec:SetParcMulct(nLine, nGetMulta)
oObjRec:SetParcInterest(nLine, nGetJuros)
oObjRec:SetParcDiscount(nLine, nGetDesconto)
oObjRec:SetParcTotal(nLine, nGetVlrTot)

// Atualiza títulos selecionados na tela
STITitAtualiza(nLine)
oLst:Select(nLine)
oLst:Refresh()

Return .T.

//--------------------------------------------------------
/*/{Protheus.doc} STIBaixaTit
Realiza a baixa dos titulos

@param   
@author  Varejo
@version P11.8
@since   14/08/2012
@return  
/*/
//--------------------------------------------------------
Function STIBaixaTit()

Local nX 			:= 0 			//Variavel de loop
Local lRet			:= .T. 			//Variavel de retorno
Local cTpOp			:= STIGetTpOp()	//Tipo de operacao
Local nParcTotal	:= 0			// Total dos títulos
Local aNCCs 		:= STDGetNCCs("1") //NCCs do cliente
Local aNCCCli		:= {}
Local lSelNcc		:= ExistBlock("STSelNcc")		//Existe ponto de entrada para selecao da NCC?
Local lSTConfEst	:= ExistBlock("STConfEst")		//Existe ponto de entrada para o estorno de titulo
Local oEstTit		:= Nil							//Recebe o objeto dos titulos selecionados para o estorno

// Soma dos títulos selecionados
For nX := 1 to Len(aLista)
	If STIGetTitSelecionado(nX)
		nParcTotal := nParcTotal + oObjRec:GetParcTotal(nX)
		oObjRec:SetParcSelected(nX, .T.)
		AADD(aNCCCli,{aLista[nX][13],aLista[nX][14]}) /// Codigo de Cliente e Loja do Titulo
	EndIf 
Next

STFSetTot( 'L1_VLRTOT', nParcTotal )
	
If nParcTotal = 0
	lRet := .F.
	STFMessage(ProcName(0), "STOP", STR0019) //"Favor selecionar pelo menos um título!"
	STFShowMessage(ProcName(0))
Else
	If cTpOp == "R" .AND. !lSelNcc
		STFCleanMessage(ProcName(0))
		STBRemoteExecute("STDFindNCCModel", {aNCCCli[1][1],aNCCCli[1][2]},,, @aNCCs) // Busca NCCs do cliente na Retaguarda
		STDSetNCCs("1",aNCCs)
	EndIf
EndIf
	
If !Empty(nParcTotal) .AND. cTpOp == 'R' .AND. lRet
	
	lIsRec := .T.
	STIChangeCssBtn()
	If Len(aNCCs) > 0
		STIExchangePanel( { || STINCCSelection() } ) 
	Else
		STIExchangePanel( { || STIPayment() } )
	EndIf

ElseIf oLst:Len() > 0 .AND. !Empty(nParcTotal) .AND. cTpOp == 'E' .AND. lRet

	STFMessage(ProcName(0), "ALERT", STR0024 ) //"Aguarde. Realizando o estorno do título."
	STFShowMessage(ProcName(0))
	If oObjRec:ReverseDropTitles()
		oObjRec:Print()

		If lSTConfEst
			oEstTit := STIRetObjTit()
			ExecBlock("STConfEst",.F.,.F.,{oEstTit})
		EndIf 

		//Excluo o movimento da tabela MHK
		If ChkFile("MHJ") .AND. ChkFile("MHK")
			STIExcMHX(oObjRec)
		EndIf
		STIRegItemInterface()
		STFMessage(ProcName(0), "STOP", STR0016) //"Estorno realizado com sucesso."
		STFShowMessage(ProcName(0))
		STFRestart()
	Else
		//Necessario zerar o total para poder efetuar outras operações no caixa.
		STFSetTot( 'L1_VLRTOT', 0 )
		lRet := .F.
	EndIf
EndIf

Return lRet


//--------------------------------------------------------
/*/{Protheus.doc} STIGetRecTit
Retornar a variavel logica dizendo se e um recebimento de
titulo ou nao

@param   
@author  Varejo
@version P11.8
@since   14/08/2012
@return  
/*/
//--------------------------------------------------------
Function STIGetRecTit()
Return lIsRec


//--------------------------------------------------------
/*/{Protheus.doc} STISetRecTit
Alimenta a variavel lIsRec se .T. ou .F.

@param   
@author  Varejo
@version P11.8
@since   14/08/2012
@return  
/*/
//--------------------------------------------------------
Function STISetRecTit(lRec)
lIsRec := lRec
Return .T.


//--------------------------------------------------------
/*/{Protheus.doc} STIGetValues
Alimenta os gets com os valores de multa, juros e desconto

@param   
@author  Varejo
@version P11.8
@since   14/08/2012
@return  
/*/
//--------------------------------------------------------
Static Function STIGetValues()

Local nPosAnt := oLst:GetPos()		// Linha anterior

STITitDblClick()
oLst:Select(nPosAnt)
oLst:SetFocus()

Return .T.

//--------------------------------------------------------
/*/{Protheus.doc} STIAtlValView
Atualiza o valor total considerando juros, multa e desconto
somente em tela

@param   
@author  Varejo
@version P11.8
@since   14/08/2012
@return  
/*/
//--------------------------------------------------------
Static Function STIAtlValView(cField)

Local nTotAPagar	:= 0					// Calculo das parcelas
Local nX			:= 0					// Contador
Local nPosAnt	 	:= oLst:GetPos()		// Linha anterior
Local nNewValue		:= 0					// Valor a ser somado ou subtraido
Local lAterado		:= .F.					// Verifica se foi alterado o valor 

Default cField		:= ""					// Campo alterado (juros/multa/desconto)

If AllTrim(Upper(cField)) == "MULTA"
	nNewValue := nGetMulta - IIf(ValType(oObjRec:GetParcMulct(oLst:GetPos()))		== "N",oObjRec:GetParcMulct(oLst:GetPos()),0)
ElseIf AllTrim(Upper(cField)) == "JUROS"
	nNewValue := nGetJuros - IIf(ValType(oObjRec:GetParcInterest(oLst:GetPos())) 	== "N",oObjRec:GetParcInterest(oLst:GetPos()),0)
ElseIf AllTrim(Upper(cField)) == "VLRTOT"
	nNewValue := nGetVlrTot - IIf(ValType(oObjRec:GetParcTotal(oLst:GetPos())) 	== "N",oObjRec:GetParcTotal(oLst:GetPos()),0)
	nGetDesconto := 0
Else
	nNewValue := IIf(ValType(oObjRec:GetParcDiscount(oLst:GetPos())) 	== "N",oObjRec:GetParcDiscount(oLst:GetPos()),0) - nGetDesconto
EndIf

If nNewValue <> 0
	lAterado	:= .T.
EndIf

If lAterado

	nGetVlrTot := oObjRec:GetParcTotal(oLst:GetPos()) + nNewValue

	STIUpdTit(.F.)

	oVlrTot:CtrlRefresh()

	For nX := 1 to Len(aLista)
		If STIGetTitSelecionado(nX)
			nTotAPagar := nTotAPagar +	oObjRec:GetParcTotal(nX)	+;
										oObjRec:GetParcMulct(nX)	+;
										oObjRec:GetParcInterest(nX)	+;
										oObjRec:GetParcDiscount(nX)
		EndIf 
	Next
	nGetVlrAPagar := nTotAPagar
	oVlrTotAPagar:CtrlRefresh()
	
EndIf	
oLst:Select(nPosAnt)

Return .T.


//--------------------------------------------------------
/*/{Protheus.doc} STISetTitSelecionado
Gravo o conteúdo do array a partir do aLista
Determino se uma conta a receber está selecionada ou não
Se nPos = 0, limpo o conteúdo do array

@param   
@author  Varejo
@version P11.8
@since   12/02/2015
@return  
/*/
//--------------------------------------------------------
Function STISetTitSelecionado(nPos,lSel)

Local nX 	:= 0				// Contador
Local nRet	:= .F.				// Retorno

Default nPos			:= 0
Default lSel			:= .F.

If nPos = 0
	aSelecionado := {}
	For nX := 1 to Len(aLista)
		aAdd(aSelecionado,.F.)
	Next
	nRet := .T.
Elseif nPos <= Len(aSelecionado)
	aSelecionado[nPos] := lSel
	nRet := .T.
EndIf

Return nRet


//--------------------------------------------------------
/*/{Protheus.doc} STIGetTitSelecionado
Leio o conteúdo do array a partir da posição do aLista
Retorno se uma conta a receber está selecionado ou não

@param   
@author  Varejo
@version P11.8
@since   12/02/2015
@return  
/*/
//--------------------------------------------------------
Function STIGetTitSelecionado(nPos)

Local		lRet	:= .F.		// Atribuição
Default	nPos	:= 0		// Posição do elemento do array

If nPos > 0 .AND. nPos <= Len(aSelecionado)
	lRet := aSelecionado[nPos]
EndIf

Return lRet


//--------------------------------------------------------
/*/{Protheus.doc} STITitDblClick
Seleciono (ou não) o título, permitindo multiseleção

@param   
@author  Varejo
@version P11.8
@since   12/02/2015
@return  
/*/
//--------------------------------------------------------
Static Function STITitDblClick()

Local nGetPos := oLst:GetPos()			// Linha do título

STISetTitSelecionado(nGetPos,!aSelecionado[nGetPos])

oLst:Modify(STITitDescricao(nGetPos),nGetPos)

// Refresh da linha
oLst:Select(nGetPos)

Return .T.


//--------------------------------------------------------
/*/{Protheus.doc} STITitDescricao
Preenche no Listbox a descrição de cada linha

@param   
@author  Varejo
@version P11.8
@since   12/02/2015
@return  
/*/
//--------------------------------------------------------
Function STITitDescricao(nX)

Local	cRet			:= ""	// Retorno
Local	cSelecionado	:= ""	// Seleção do Título
Local	nValorTot		:= 0	// Valor total da parcela
Default	nX				:= 0	// Posição do elemento do array

If nX <= 0 .OR. nX > Len(aLista)
	cRet := ""
Else

	If nX <= 0 .OR. nX > Len(aSelecionado)
		cSelecionado := Space(3)
	Else
		cSelecionado := iif(aSelecionado[nX],"[+]",Space(3))
	EndIf

	//Valor total:
	nValorTot := aLista[nX,10]

	//Quando estorno deve exibe o valor total +juros +multa - desconto
	If AllTrim(STIGetTpOp()) == "E"
		nValorTot := aLista[nX,6]   // quando estorno pegar o valor original do titulo
		nValorTot += aLista[nX,7] + aLista[nX,8] + aLista[nX,17] - aLista[nX,9] 
	EndIf

	cRet := (	aLista[nX,15] + Space( (Int(nLargura * 0)) + (TamSX3("E1_FILIAL")[1] - Len(AllTrim(aLista[nX,14]))) ) +;
				aLista[nX,2] + Space( (Int(nLargura * 0.04)) + (TamSX3("E1_PREFIXO")[1] - Len(AllTrim(aLista[nX,2]))) ) +;
				aLista[nX,3] + Space( (Int(nLargura * 0.04)) + (TamSX3("E1_NUM")[1] - Len(AllTrim(aLista[nX,3]))) ) +;
				aLista[nX,4] + Space( (Int(nLargura * 0.05)) + (TamSX3("E1_PARCELA")[1] - Len(AllTrim(aLista[nX,4]))) ) +;
				Transform(aLista[nX][5],'') + Space( (Int(nLargura * 0.01)) + (TamSX3("E1_VENCTO")[1] - Len(AllTrim(aLista[nX,5]))) ) +;
				Str(nValorTot, 12,2) +;
				Space(4) + Str(aLista[nX,17], 12,2)) + Space( (Int(nLargura * 0.02)) + (TamSX3("E1_ACRESC")[1] - Len(AllTrim(aLista[nX,17]))) ) +;
				aLista[nX,11] + Space(2) + cSelecionado

EndIf
			
Return cRet


//--------------------------------------------------------
/*/{Protheus.doc} STITitAtualiza()
Alimenta os gets com os valores de multa, juros e desconto

@param   
@author  Varejo
@version P11.8
@since   13/02/2015
@return  
/*/
//--------------------------------------------------------
Static Function STITitAtualiza(nLine)

Local cTpOp		:= STIGetTpOp()			// Tipo de operacao
Local nX		:= 0					// Contador
Local nPosAnt	:= oLst:GetPos()		// Linha anterior
		
DEFAULT nLine	:= 0		
// Cenario aonde o cliente alterava um campo e ao inves de dar tab ja clicava em outro titulo no list 
If nLine > 0  // tem q mantar a mesma linha do titulo 
	nPosAnt := nLine 
EndIf

nGetMulta		:= 0
nGetJuros		:= 0
nGetDesconto	:= 0
nGetQtdTitSel	:= 0
nGetVlrTot		:= 0
nGetVlrAPagar	:= 0

If nPosAnt > 0
	nGetTotOrig 	:= oObjRec:GetParcOrig(nPosAnt)
	
	nGetMulta 		:= IIf(ValType(oObjRec:GetParcMulct(nPosAnt))		== "N",oObjRec:GetParcMulct(nPosAnt),0)
	nGetJuros 		:= IIf(ValType(oObjRec:GetParcInterest(nPosAnt)) 	== "N",oObjRec:GetParcInterest(nPosAnt),0)
	nGetDesconto 	:= IIf(ValType(oObjRec:GetParcDiscount(nPosAnt)) 	== "N",oObjRec:GetParcDiscount(nPosAnt),0)
	nGetVlrTot		:= IIf(ValType(oObjRec:GetParcTotal(nPosAnt))		== "N",oObjRec:GetParcTotal(nPosAnt),0)
	nGetVlrAcres	:= IIf(ValType(oObjRec:GetParcIncrease(nPosAnt))	== "N",oObjRec:GetParcIncrease(nPosAnt),0)
EndIf

For nX := 1 to Len(aLista)
	If STIGetTitSelecionado(nX)
		nGetQtdTitSel := nGetQtdTitSel + 1
		
		//Quando estorno deve mostrar o valor total + multa + juros - desconto
		If cTpOp == "E"
			nGetVlrAPagar := nGetVlrAPagar	+ IIf(ValType(oObjRec:GetParcValor(nX)) == "N",oObjRec:GetParcValor(nX),0)  //Quando estorno busca o valor origem do titulo
			nGetVlrAPagar += IIf(ValType(oObjRec:GetParcInterest(nX)) == "N",oObjRec:GetParcInterest(nX),nGetJuros)		//Juros da parcela
			nGetVlrAPagar += IIf(ValType(oObjRec:GetParcMulct(nX)) == "N",oObjRec:GetParcMulct(nX),nGetMulta)			//Multa da parcela
			nGetVlrAPagar -= IIf(ValType(oObjRec:GetParcDiscount(nX)) == "N",oObjRec:GetParcDiscount(nX),nGetDesconto)	//Desconto da parcela
			nGetVlrAPagar += IIf(ValType(oObjRec:GetParcIncrease(nPosAnt))	== "N",oObjRec:GetParcIncrease(nPosAnt),0)	//Acrescimo	da parcela
		Else
			nGetVlrAPagar	:= nGetVlrAPagar	+ IIf(ValType(oObjRec:GetParcTotal(nX)) == "N",oObjRec:GetParcTotal(nX),0)	
		EndIf
	EndIf
Next

If cTpOp == "R"  // Recebimento
	oMulta:CtrlRefresh()
	oJuros:CtrlRefresh()
	oDesconto:CtrlRefresh()
	oVlrTot:CtrlRefresh()
	oTotOrig:CtrlRefresh()
EndIf
oQtdTitSel:CtrlRefresh()
oVlrTotAPagar:CtrlRefresh()

oLst:Select(nPosAnt)

Return .T.


//--------------------------------------------------------
/*/{Protheus.doc} STITitIni()
Reinicializa variáveis de multa, juros, valores totais.

@param   
@author  Varejo
@version P11.8
@since   23/02/2015
@return  
/*/
//--------------------------------------------------------
Static Function STITitIni()

Local cTpOp	:= STIGetTpOp()			// Tipo de operação

nGetMulta		:= 0
nGetJuros		:= 0
nGetDesconto	:= 0
nGetQtdTitSel 	:= 0
nGetVlrTot		:= 0
nGetVlrAPagar	:= 0
lAtuValores		:= .F.		//Habilita a edição dos campos de multa/juros e desconto (Editavel = .T. / Bloqueado  = .F.)
lAtuValMulta	:= .F.		//Habilita a edição dos campos de multao (Editavel = .T. / Bloqueado  = .F.)
lAtuValJuros	:= .F.		//Habilita a edição dos campos de juroso (Editavel = .T. / Bloqueado  = .F.)
lAtuValDesconto	:= .F.		//Habilita a edição dos campos de desconto (Editavel = .T. / Bloqueado  = .F.)
lAtuValtotal	:= .F.		//Habilita a edição dos campos de Total (Editavel = .T. / Bloqueado  = .F.)

If cTpOp == "R"	// Recebimento
	oMulta:CtrlRefresh()
	oJuros:CtrlRefresh()
	oDesconto:CtrlRefresh()
	oVlrTot:CtrlRefresh()
	oTotOrig:CtrlRefresh()
EndIf	
oQtdTitSel:CtrlRefresh()
oVlrTotAPagar:CtrlRefresh()

Return .T.

//--------------------------------------------------------
/*/{Protheus.doc} STIVldFldRec()
Chamada da função responsavel por validar se habilita ou não 
os campos Multa,Juros e Descontos para edição para o titulo selecionado.

@param   objt - Objeto responsavel pela chamada
@author  Varejo
@version P11.8
@since   22/05/2015
@return  
/*/
//--------------------------------------------------------
Static Function STIVldFldRec()
Local lRet  := .T.

//habilita todos os botoes de edicao
lAtuValMulta := lAtuValJuros := lAtuValDesconto := lAtuValtotal := lRet

If FindFunction("STWVldFldRec")
	lRet := STWVldFldRec(aLista[oLst:GetPos()],@lAtuValMulta, @lAtuValJuros, @lAtuValDesconto,;
	 					 @lAtuValtotal		  , "R"	, aLista	   , aSelecionado)
EndIf

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc} STIVldVlFinal()
Chamada da função responsavel por validar se o valor informado no 
no campo Valor final esta correto

@author  Varejo
@version P11.8
@since   20/01/2016
@return  
/*/
//--------------------------------------------------------
Static Function STIVldVlFinal()
Local lRet := .T.
Local nVlrAdicio := ( nGetJuros + nGetMulta + nGetVlrAcres ) - nGetDesconto

If FindFunction("STWVldVlFinal")
	lRet := STWVldVlFinal(nGetVlrTot, nGetTotOrig , nVlrAdicio ) //Valor recebido do titulo maior que o valor do titulo.
EndIf

If lRet // Chamamos no final para atualizar os valores pois os caixas estavam esquecendo de clicar em atualiza valores
	STIUpdTit()
EndIf

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc} STIExcMHX()
Função responsavel por enviar os dados para exclusão nas tabelas MHJ e MHK
@Paran oObjRec - Objeto com os titulos a serem cancelados
@author  Varejo
@version P12.1.17
@since   25/06/2018
@return  
/*/
//--------------------------------------------------------
Static Function STIExcMHX(oObjRec)
Local nTamMHJ_PRXTIT := TAMSX3("MHJ_PRXTIT")[1]	//Variavel que armazena o tamanho do campo MHJ_PRXTIT
Local nTamMHJ_NUMTIT := TAMSX3("MHJ_NUMTIT")[1]	//Variavel que armazena o tamanho do campo MHJ_NUMTIT
Local nTamMHJ_PARTIT := TAMSX3("MHJ_PARTIT")[1]	//Variavel que armazena o tamanho do campo MHJ_PARTIT 
Local nX 			 := 0						// Variavel para For 
Local cChvDel		 := ""						//Chave para exclusão

If ExistFunc("STDGrvMHX")

	For nX := 1 To len(oObjRec:aListTitles[4]) //Pego a lista de titulos baixados
		If oObjRec:aListTitles[4][nX][1]
			//MHJ_FILIAL+MHJ_PRXTIT+MHJ_NUMTIT+MHJ_PARTIT  
			cChvDel := xFilial("MHJ") + PadR(oObjRec:aListTitles[4][nX][2],nTamMHJ_PRXTIT) + PadR(oObjRec:aListTitles[4][nX][3],nTamMHJ_NUMTIT) + PadR(oObjRec:aListTitles[4][nX][4],nTamMHJ_PARTIT)
			STDGrvMHX(,,cChvDel)
		EndIf
	Next nX

Else 
	LjGrvLog("STBIncMHX","Função STDGrvMHX não existe no RPO, a ausencia desta função implicara na conferência  de caixa.")
EndIf 

Return


//--------------------------------------------------------
/*/{Protheus.doc} STIAtuVlFinal()
Atualiza valor do campo "Valor Final" com base nos campos Valor Original, Multa, Juros, Desconto

@author  João Marcos Martins
@version P12
@since   16/08/2018
@return  
/*/
//--------------------------------------------------------
Static Function STIAtuVlFinal()
Local lRet			:= .T.
Local cCash			:= xNumCaixa()												// Caixa atual
Local nVlrAdicio	:= ( nGetJuros + nGetMulta + nGetVlrAcres ) - nGetDesconto	// Valores adicionais Multa, Jutos, Desconto	
Local nPercDesc		:= ( nGetDesconto * 100 ) / nGetTotOrig						// Percentual do desconto
Local lValidDesc	:= nPercDesc <= 99.99

If lValidDesc

	lValidDesc := STFPROFILE( 11 , cCash , nPercDesc , nGetDesconto , "T" )[1] // valida se caixa tem permissao para conceder o desconto informado

	If lValidDesc

		If FindFunction("STWVldVlFinal")
			lRet := STWVldVlFinal(nGetVlrTot, nGetTotOrig , nVlrAdicio ) //Valor recebido do titulo maior que o valor do titulo.
		EndIf

		If lRet // Chamamos no final para atualizar os valores pois os caixas estavam esquecendo de clicar em atualiza valores
		STIUpdTit(,,nGetDesconto,,nGetMulta,nGetJuros)
		STIAtlValView()
		EndIf

	EndIf

EndIf

If !lValidDesc
	STFMessage(ProcName(0), "STOP", STR0027) //"Valor de desconto informado MAIOR que o permitido para o caixa atual."
	STFShowMessage(ProcName(0))
	lRet := .F.
EndIf

Return lRet