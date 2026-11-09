#include 'totvs.ch'
#include "POSCSS.CH"
#include "STPOS.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} STIRSelCus()
Funcao responsavel pela criacao do Painel de selecao de clientes.

@param	  aCadCli - Array com listagem de cadastros que o Cliente possui que será apresentada para seleção na tela. 
@author  Joao Marcos Martins
@version 12.1.17
@since   08/03/2018
@return  aRet
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STIRSelCus(aCadCli)

Local oPanelMVC		:= STIGetPanel()					//Painel principal
Local oPanGetCust		:= TPanel():New(00,00,"",oPanelMVC,,,,,,oPanelMVC:nWidth/2,(oPanelMVC:nHeight)/2) //Objeto do painel
Local nTamAltListBox	:= oPanelMVC:nHeight * 0.19		//Tamanho: Altura do ListBox
Local nList			:= 1								//Para o TListBox
Local bOk				:= {|| STDCallCustTit( nList ) }// Envia linha selecionada
Local oLst	  			:= Nil // Objeto do ListBox
Local oSay1			:= Nil
Local oSay2			:= Nil
Local oBtnOk         := Nil // Objeto do Botão "Selecionar"
Local nLargura       := (oPanGetCust:nWidth / 2) - (2 * ((oPanGetCust:nWidth / 2) * 0.04)) //Largura do ListBox

/*oSay1 - "Recebimentos de títulos > Selecionar Cliente"*/
oSay1 := TSay():New(POSVERT_CAB,POSHOR_1,{||"Recebimentos de títulos > Selecionar Cliente"/*STR000X*/},oPanGetCust,,,,,,.T.,,,,) //"Recebimentos de títulos > Selecionar Cliente"
oSay1:SetCSS( POSCSS (GetClassName(oSay1),CSS_BREADCUMB )) 

/* oSay2 - "Nome / Código / Loja / CPF/CNPJ" */
oSay2 := TSay():New(POSVERT_LABEL1,POSHOR_1,{||/*STR00X*/"Código / Loja / Nome / CPF/CNPJ"},oPanGetCust,,,,,,.T.,,,,) // "Código / Loja / Nome / CPF/CNPJ"
oSay2:SetCSS( POSCSS (GetClassName(oSay2),CSS_BREADCUMB)) 

/* oLst - Listbox com os cadastros do cliente */
oLst := TListBox():Create(oPanGetCust, POSVERT_GET1, POSHOR_1, {|u|if(Pcount()>0,nList:=u,nList)}, aCadCli, nLargura, nTamAltListBox,,;
							 ,,,.T.,,bOk/*Acao ao clicar duas vezes*/,,,,,,,,,)
oLst:SetCSS( POSCSS (GetClassName(oLst),CSS_LISTBOX ))  

oLst:Select(1)
oLst:SetFocus()

/* Botao Seleciona Cliente */
oBtnOk := TButton():New(POSVERT_BTNFOCAL,POSHOR_BTNFOCAL,/*STR00XX*/"Selecionar",oPanGetCust,bOk,LARGBTN,ALTURABTN,,,,.T.) //"Selecionar"
oBtnOk:SetCSS( POSCSS (GetClassName(oBtnOk),CSS_BTN_FOCAL ))

Return oPanGetCust

//--------------------------------------------------------
/*/{Protheus.doc} STIPnlSelCust
Abre o painel para selecao do Cliente

@param   aCadCli - Array com listagem de cadastros que o Cliente possui que serão apresentada para seleção na tela.    
@author  João Marcos Martins
@version 12.1.17
@since   09/03/2018
@return  
/*/
//--------------------------------------------------------
Function STIPnlSelCust(aCadCli)

STIChangeCssBtn()
STIBtnDeActivate()
STIExchangePanel( { ||  STIRSelCus(aCadCli) } )

Return .T.