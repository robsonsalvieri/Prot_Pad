#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "POSCSS.CH"  
#INCLUDE "STIMULTIMEDIAREGISTER.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} STIMultiMedia
Interface Registro de Mídia

@param   
@author  Vendas & CRM
@version P12
@since   29/03/2012
@return  Nil 
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIMultiMedia()            

Local aMidias			:= STDMRGet()						// Armazena Midias Cadastradas

If Len(aMidias) > 0

	STIExchangePanel( { || STIPanMultiMedia() } )

Else

	STFMessage("STIMultimedia","STOP",STR0001) //"Não existe nenhum registro de mídia cadastrado"
	STFShowMessage("STIMultimedia","STOP",STR0001)	 //"Não existe nenhum registro de mídia cadastrado"

EndIf

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STIPanMultiMedia
Contexto Registro de Mídia

@param   	
@author  Vendas & CRM
@version P12
@since   29/03/2012
@return  oPanMultiMedia			Painel Registro de Mídia
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIPanMultiMedia()

Local oPanMultiMedia	:= Nil					// Painel Registro de Mídia
Local oPanGetMedia	:= Nil					// Painel Get Seleção de Midia
Local oPanBtnSale  	:= Nil					// Painel de Botões da Venda
Local oMedia			:= Nil					// ListBox para Seleção de Mídia
Local oButton			:= Nil					// Botao "Adicionar Midias"
Local aMidias			:= {}					// Armazena Midias para seleção
Local oPanelMVC		:= STIGetDlg() 			// Dialog da tela principal

/*/
	Título - "Orçamento"
/*/
Local nPosLb1Alt		:= oPanelMVC:nHeight/2 * 0.02 //Posicao: Altura
Local nPosLb1Hoz		:= oPanelMVC:nWidth/2 * 0.039 //Posicao: Horizontal
/*/
	Título - "Seleção de Mídia"
/*/
Local nPosLb2Alt		:= (oPanelMVC:nHeight/2 * 0.02) * 3.7 //Posicao: Altura
Local nPosLb2Hoz		:= oPanelMVC:nWidth/2 * 0.039 //Posicao: Horizontal
/*/
	ListBox
/*/
Local nLisVerPerc		:= 6 					// Pencentual de Posição Vertical do ListBox
Local nLisHorPerc		:= 0.039				// Pencentual de Posição Horizontal do ListBox
Local nLisHeiPerc		:= 0.11				// Percentual de Altura do ListBox

/*/
	Botão "Adicionar Mídia"
/*/
Local nBtnWidPerc		:= oPanelMVC:nWidth/2 * 0.25			// Percentual de Largura do Botão "Adicionar Mídia"
Local nBtnHeiPerc		:= oPanelMVC:nHeight/2 * 0.07			// Percentual de Altura do Botão "Adicionar Mídia"
Local nBtnVerPerc		:= (oPanelMVC:nHeight/2 * 0.02) * 14				// Percentual da Posição Vertical do Botão "Adicionar Mídia"
Local nBtnHorPerc		:= oPanelMVC:nWidth/2 * 0.40			// Percentual da Posição Horizontal do Botão "Adicionar Mídia"
/*/
	Botão "Cancelar"
/*/
Local nBtnCWidPerc		:= oPanelMVC:nWidth/2 * 0.25			// Percentual de Largura do Botão "Adicionar Mídia"
Local nBtnCHeiPerc		:= oPanelMVC:nHeight/2 * 0.07			// Percentual de Altura do Botão "Adicionar Mídia"
Local nBtnCVerPerc		:= (oPanelMVC:nHeight/2 * 0.02) * 14				// Percentual da Posição Vertical do Botão "Adicionar Mídia"
Local nBtnCHorPerc		:= oPanelMVC:nWidth/2 * 0.71			// Percentual da Posição Horizontal do Botão "Adicionar Mídia"
/*/
	Panel 
/*/
Local nPosPnlHoz := ((oPanelMVC:nHeight/2)/2 * 0.2) + 135 //Posicao: horizontal do painel


/*/
	Panel Get de Mídia
/*/
oPanGetMedia := TPanel():New(nPosPnlHoz,00,"",Nil,,,,,,(oPanelMVC:nWidth/2),(oPanelMVC:nHeight/2) * 0.60)
oPanGetMedia:SetCSS( POSCSS (GetClassName(oPanGetMedia), CSS_PANEL_CONTEXT )) 

/*/
	Busca Mídias Cadastradas para seleção
/*/
aMidias := STIGetMedias()

/*/
	Objetos
/*/
oSay1 := TSay():New(nPosLb1Alt,nPosLb1Hoz,{||STR0002},oPanGetMedia,,,,,,.T.,,,,) //"Vendas > Registro de Mídia"
oSay2 := TSay():New(nPosLb2Alt,nPosLb1Hoz,{||STR0003},oPanGetMedia,,,,,,.T.,,,,) //"Seleção de Mídia"
oSay1:SetCSS( POSCSS (GetClassName(oSay1), CSS_BREADCUMB )) 
oSay2:SetCSS( POSCSS (GetClassName(oSay2), CSS_LABEL_FOCAL )) 

oMedia := TListBox():Create(oPanGetMedia, (oPanelMVC:nHeight/2 * 0.02) * nLisVerPerc, oPanelMVC:nWidth/2 * nLisHorPerc, Nil, aMidias, ( oPanelMVC:nWidth/2  - (2*nLisHorPerc*oPanelMVC:nWidth/2) ),oPanelMVC:nHeight/2 * nLisHeiPerc,,,,,.T.,,{ || oButton:SetFocus() })
oMedia:SetCSS( POSCSS (GetClassName(oMedia), CSS_LISTBOX )) 

oButton := TButton():New(	nBtnVerPerc,nBtnHorPerc,STR0004,oPanGetMedia,{ || STISetMedia( oMedia ) }, ; //"Adicionar Mídia"
								nBtnWidPerc,nBtnHeiPerc,,,,.T.)  
oButton:SetCSS( POSCSS (GetClassName(oButton), CSS_BTN_FOCAL )) 


oBtnCanc := TButton():New(	nBtnCVerPerc,nBtnCHorPerc,STR0005,oPanGetMedia,{ || STIExchangePanel( { || STIPanItemRegister() } ) }, ; //"Cancelar"
								nBtnCWidPerc,nBtnCHeiPerc,,,,.T.)   
oBtnCanc:SetCSS( POSCSS (GetClassName(oBtnCanc), CSS_BTN_FOCAL )) 

oMedia:GoTop()
oMedia:SetFocus()
	
Return oPanGetMedia


//-------------------------------------------------------------------
/*/{Protheus.doc} STIGetMedias
Busca Midias para seleção na interface

@param   	
@author  Vendas & CRM
@version P12
@since   29/03/2012
@return  aMidias				Retorna Midias para seleção		
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIGetMedias()

Local aMidias			:= {}				// Retorna Midias para seleção		
Local aDataMidias		:= STDMRGet()		// Armazena Midias Cadastradas
Local nI				:= 0				// Contador
                               
/*/
	Prepara as mídias cadastradas para seleção
/*/
For nI := 1 To Len(aDataMidias)

	AADD( aMidias , cValToChar(nI) + " - " + aDataMidias[nI][2] )

Next nI

Return aMidias


//-------------------------------------------------------------------
/*/{Protheus.doc} STISetMedia
Adicionar Midia

@param   oMedia					ListBox Registro de Midia   	
@author  Vendas & CRM
@version P12
@since   29/03/2012
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STISetMedia( oMedia )

Local cCodMidia		:= ""	   		// Código de Midia a ser adicionado
Local aDataMidias	:= STDMRGet()	// Armazena Midias Cadastradas

Default oMedia		:= Nil

If oMedia <> Nil

	If oMedia:GetPos() > 0
		
		cCodMidia := aDataMidias[oMedia:GetPos()][1]
	
		STBMRSetMedia( cCodMidia )
		
		STIExchangePanel( { || STIPanItemRegister() } )
	
	Else
		
		STFMessage("STIMultiMedia","STOP",STR0006) //"Mídia não adicionada"
		STFShowMessage("STIMultiMedia")
		
	EndIf

EndIf

Return

