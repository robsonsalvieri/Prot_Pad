#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "POSCSS.CH"
#INCLUDE "STIREASONFORDISCOUNT.CH"

#Define cMTDesIt	"1"		//Motivo de Desconto Item
#Define cMTDesTo	"2"		//Motivo de Desconto Total 
#Define cMTDesAm	"3"		//Motivo de Desconto Ambos 

Static aReasons			:= {}		// Armazena Motivo de Desconto Interface
Static cReasonSelected	:= ""		// Armazena Código de Motivo de Desconto Selecionado
Static cObs				:= ""		// Observacao do Motivo de Desconto (conforme tabela MDT)
//-------------------------------------------------------------------
/*/{Protheus.doc} STIGetReason
Retorna o Motivo de Desconto selecionado

@param 	
@author  Vendas & CRM
@version P12
@since   29/03/2012
@return  cReasonSelected		Retorna o Motivo de Desconto selecionado
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIGetReason()

Return cReasonSelected

//-------------------------------------------------------------------
/*/{Protheus.doc} STIGetObsReason
Retorna Descrição do Motivo de Desconto selecionado

@param 	
@author  Vendas & CRM
@version P12
@since   08/08/2019
@return  cObs		Retorna DEscrição do Motivo de Desconto selecionado
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIGetObsReason()

Return cObs

//-------------------------------------------------------------------
/*/{Protheus.doc} STIReasons
Define os motivos de desconto a serem apresentados na interface

@param 	
@author  Vendas & CRM
@version P12
@since   29/03/2012
@return  aReasons			Retorna os Motivos de Desconto a serem apresentados na interface  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIReasons()

Local aDataReasons	:= {}		// Armazena os motivos de desconto cadastrados
Local nI			:= 0		// Contador

If Len(aReasons) <= 0

	/*/
		Busca Registros multimidia cadastrados
	/*/
	aDataReasons := STDRFDGet(cMTDesIt)
	
	For nI := 1 To Len(aDataReasons)
	
		AADD( aReasons , cValToChar(nI) + " - " + aDataReasons[nI][2] )
	
	Next nI
	
EndIf
	
Return aReasons
	

//-------------------------------------------------------------------
/*/{Protheus.doc} STISetReason
Armazena o Motivo de Desconto Selecionado

@param	 oReasons			ListBox de Motivo de Desconto 	
@author  Vendas & CRM
@version P12
@since   29/03/2012
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STISetReason(oReasons,nItemLine,cCodItem,cTesPad,nTotItem,oPanReasonD)

Local cSelected		:= ""		// Armazena a Opção selecionada no ListBox
Local nSelected		:= 0		// Armazena posição numérica da opção selecionada
Local aDataReasons	:= {}		// Armazena os motivos de desconto cadastrados
Local cType			:= "VALOR"	//Tipo de Desconto - 'VALOR' para desconto no Total e 'ITEM' para desconto no item. 

Default oReasons	:= Nil
Default nItemLine	:= 0
Default cCodItem	:= ""
Default cTesPad		:= "" 
Default nTotItem	:= 0
Default oPanReasonD := Nil 

If oReasons <> Nil .AND. oReasons:lvisiblecontrol == .T. 
		
	cSelected		:= oReasons:GetSelText()
	cSelected		:= SubStr( cSelected , 1 , 1 )
	
	nSelected		:= Val(cSelected)
	
	aDataReasons	:= STDRFDGet(cMTDesIt)
	
	cReasonSelected	:= aDataReasons[nSelected][1]
	cObs			:= aDataReasons[nSelected][2] 
	

	If !(cReasonSelected == "")
	
		If !Empty(cCodItem) .AND. nItemLine > 0 
			STWSetRegIt(nItemLine,cCodItem,cTesPad,nTotItem)
			cType := "ITEM"

			Iif(ExistFunc("StiMataObj"),StiMataObj(oPanReasonD),Nil)
			
			STIExchangePanel( { || STIPanItemRegister() })
		Else
			STDAddReason( nItemLine	, cReasonSelected , cObs ,	cCodItem , cType )
		EndIf


	EndIf
	 	
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} STIReasonD
Monta a Tela contendo todos os motivos validos

@param	 oReasons			ListBox de Motivo de Desconto 	
@author  Vendas & CRM
@version P12
@since   12/09/2014
@return  oPanReasonD
@obs     
@sample
/*/
//-------------------------------------------------------------------

Function STIReasonD(nItemLine,cCodItem,cTesPad,nTotItem)
Local aReasonD		:= STIReasons()									//Retorna um array contendo todos os Motivos cadastrados
Local lRet			:= .T.												//Variavel de retorno da funcao
Local oReasonD		:= Nil												//ListBox para Motivos de Desconto
Local oPanReasonD	:= Nil												//Panel para os Motivos de Desconto
Local oPanelMVC	:= STIGetDlg() 									//Dialog da tela principal
Local oButton		:= Nil												//Botao Confirma
Local oBtnCanc		:= Nil												//Botao Cancela

//Botão "Adicionar Mídia"
Local nBtnWidPerc		:= oPanelMVC:nWidth/2 * 0.25					//Percentual de Largura do Botão "Adicionar Mídia"
Local nBtnHeiPerc		:= oPanelMVC:nHeight/2 * 0.07				//Percentual de Altura do Botão "Adicionar Mídia"
Local nBtnVerPerc		:= (oPanelMVC:nHeight/2 * 0.02) * 14		//Percentual da Posição Vertical do Botão "Adicionar Mídia"
Local nBtnHorPerc		:= oPanelMVC:nWidth/2 * 0.40					//Percentual da Posição Horizontal do Botão "Adicionar Mídia"

//Botão "Cancelar"
Local nBtnCWidPerc		:= oPanelMVC:nWidth/2 * 0.25				//Percentual de Largura do Botão "Adicionar Mídia"
Local nBtnCHeiPerc		:= oPanelMVC:nHeight/2 * 0.07			//Percentual de Altura do Botão "Adicionar Mídia"
Local nBtnCVerPerc		:= (oPanelMVC:nHeight/2 * 0.02) * 14	//Percentual da Posição Vertical do Botão "Adicionar Mídia"
Local nBtnCHorPerc		:= oPanelMVC:nWidth/2 * 0.71				//Percentual da Posição Horizontal do Botão "Adicionar Mídia"

//Objetos TSAY
Local nPosLb1Alt		:= oPanelMVC:nHeight/2 * 0.02 				//Posicao: Altura
Local nPosLb1Hoz		:= oPanelMVC:nWidth/2 * 0.039 				//Posicao: Horizontal
Local nPosLb2Alt		:= (oPanelMVC:nHeight/2 * 0.02) * 3.7 		//Posicao: Altura
Local nPosLb2Hoz		:= oPanelMVC:nWidth/2 * 0.039 				//Posicao: Horizontal

//Panel 
Local nPosPnlHoz := ((oPanelMVC:nHeight/2)/2 * 0.2) + 135 		//Posicao: horizontal do painel

//ListBox
Local nLisVerPerc		:= 6 											//Pencentual de Posição Vertical do ListBox
Local nLisHorPerc		:= 0.039										//Pencentual de Posição Horizontal do ListBox
Local nLisHeiPerc		:= 0.11											//Percentual de Altura do ListBox

//Panel Get de Mídia
oPanReasonD := TPanel():New(nPosPnlHoz,00,"",Nil,,,,,,(oPanelMVC:nWidth/2),(oPanelMVC:nHeight/2) * 0.60)
oPanReasonD:SetCSS( POSCSS (GetClassName(oPanReasonD), CSS_PANEL_CONTEXT )) 

//Objetos
oSay1 := TSay():New(nPosLb1Alt,nPosLb1Hoz,{|| "Vendas > Motivos de Desconto"},oPanReasonD,,,,,,.T.,,,,)
oSay2 := TSay():New(nPosLb2Alt,nPosLb1Hoz,{|| " Selecione o Motivo:"},oPanReasonD,,,,,,.T.,,,,)
oSay1:SetCSS( POSCSS (GetClassName(oSay1), CSS_BREADCUMB )) 
oSay2:SetCSS( POSCSS (GetClassName(oSay2), CSS_LABEL_FOCAL )) 

//			 TListBox():Create(oWnd,nRow,nCol,bSetGet,aItems,nWidth,nHeight,bChange,bValid,nClrFore,nClrBack,lPixel,uParam13,bLDBLClick,oFont,uParam16,uParam17,bWhen,uParam19,uParam20,uParam21,uParam22,bRClick) --> oObjeto
oReasonD := TListBox():Create(oPanReasonD, (oPanelMVC:nHeight/2 * 0.02) * nLisVerPerc, oPanelMVC:nWidth/2 * nLisHorPerc, Nil   , aReasonD, ( oPanelMVC:nWidth/2  - (2*nLisHorPerc*oPanelMVC:nWidth/2) ),oPanelMVC:nHeight/2 * nLisHeiPerc,,,,,.T.,,{ || oButton:SetFocus() })
oReasonD:SetCSS( POSCSS (GetClassName(oReasonD), CSS_LISTBOX ))

oButton := TButton():New(nBtnVerPerc,nBtnHorPerc,"Confirma",oPanReasonD,{ || Iif(STISelReason(oReasonD),STISetReason(oReasonD,nItemLine,cCodItem,cTesPad,nTotItem,oPanReasonD),Nil) },nBtnWidPerc,nBtnHeiPerc,,,,.T.)  
oButton:SetCSS( POSCSS (GetClassName(oButton), CSS_BTN_FOCAL )) 

oBtnCanc := TButton():New(	nBtnCVerPerc,nBtnCHorPerc,"Cancelar",oPanReasonD,{ || Iif(ExistFunc("StiMataObj"),StiMataObj(oPanReasonD),Nil),STIExchangePanel( { || STIPanItemRegister() } ) },nBtnCWidPerc,nBtnCHeiPerc,,,,.T.)   
oBtnCanc:SetCSS( POSCSS (GetClassName(oBtnCanc), CSS_BTN_FOCAL )) 

oButton:SetFocus()

Return oPanReasonD

//-------------------------------------------------------------------
/*/{Protheus.doc} STICleReason
Limpa a variavel statica cReasonSelected

@param 	
@author  Lucas Novais (lnovais)
@version P12+
@since   16/04/2019
@return  Nill
@obs     
@sample
/*/
//-------------------------------------------------------------------

Function STICleReason()

cReasonSelected := ""
cObs:=""

return

//-------------------------------------------------------------------
/*/{Protheus.doc} STISelReason
Valida se é possivel prosseguir com o registro do item caso o motivo de desconto esteja ativo.

@param 	
@author  Lucas Novais (lnovais)
@version P12+
@since   23/04/2019
@return  lRet - Indica se é possivel prosseguir.
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STISelReason(oReasons)
Local lRet := .F.

If oReasons <> Nil .AND. oReasons:NAT == 0
	lRet := .F.
	STFMessage("STISelReason","STOP",STR0001) //"obrigatório selecionar o Motivo de Desconto"
	STFShowMessage("STISelReason")
Else
	lRet := .T.
EndIf

Return lRet
