#Include 'Protheus.ch'
#INCLUDE "STPOS.CH"
#INCLUDE "POSCSS.CH"
#INCLUDE "STIVALETROCA.CH"

Static aCVTs := {} // Array dos itens que terão os cupons de vale troca
Static nTamItem := TamSX3("L2_ITEM")[1]

//-------------------------------------------------------------------
/*{Protheus.doc} STIValeTroca
Chama a tela de selecao de produtos para emissao do vale troca

@param
@author  Varejo
@version P11.8
@since   17/07/2013
@return  lRet			Retorno se executou corretamente a funcao
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STIValeTroca()

STFCleanInterfaceMessage()
STIExchangePanel({|| STIPanValeTroca() })

Return

//-------------------------------------------------------------------
/*{Protheus.doc} STIPanValeTroca
Cria o painel de Vale troca

@param
@author  Varejo
@version P11.8
@since   23/07/2012
@return  lRet			Retorno se executou corretamente a funcao
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function STIPanValeTroca()
Local oPanelMVC		:= STIGetDlg()		//Painel principal do dialog
Local oMainPanel 	:= TPanel():New(00,00,"",oPanelMVC,,,,,,oPanelMVC:nWidth/2,(oPanelMVC:nHeight)/2) //Painel vale troca

Local nLargGets		:= 90

Local oCab			:= Nil
Local nVertCab		:= oPanelMVC:nHeight/81.3		// Posicao vertical do cabecalho

Local oLblGetItem   := Nil

Local oGetItem      := Nil
Local cItem 	    := Space(nTamItem)				//Alteracao do conteudo do get

Local oLblProdutos  := Nil

Local oGetList		:= Nil							// TComboBox Escolha do campo a ser utilizado na busca
Local cGetList		:= ""							// Variável do Get

Local oBtnConfirm	:= Nil
Local oBtnCancel	:= Nil

Local nVertLbl1		:= oPanelMVC:nHeight/23.228		// Posicao vertical dos label da linha 1
Local nVertLbl2		:= oPanelMVC:nHeight/9.0333		// Posicao vertical dos label da linha 2

Local nVertGet1		:= oPanelMVC:nHeight/14.781		// Posicao vertical dos get da linha 1
Local nVertGet2		:= oPanelMVC:nHeight/7.3909		// Posicao vertical dos get da linha 2

Local oFontCod		:= TFont():New('Arial',,-16,.T.)
Local oListFont 	:= TFont():New("Courier New")

oMainPanel:SetCSS(POSCSS(GetClassName(oMainPanel),CSS_PANEL_CONTEXT))

oCab	:= TSay():New(nVertCab,POSHOR_1,{||STR0001},oMainPanel,,,,,,.T.,,,,) //"Vale Troca - Seleção de Produtos"
oCab:SetCSS( POSCSS (GetClassName(oCab), CSS_BREADCUMB )) 

oLblGetItem:= TSay():New(nVertLbl1,POSHOR_1,{||STR0002},oMainPanel,,,,,,.T.,,,,)  //"Digite o número do item"
oLblGetItem:SetCSS( POSCSS (GetClassName(oLblGetItem), CSS_LABEL_FOCAL )) 

@ nVertGet1,POSHOR_1 MSGET oGetItem VAR cItem SIZE nLargGets,ALTURAGET  PICTURE "@!" FONT oFontCod OF oMainPanel PIXEL
oGetItem:SetCSS( POSCSS (GetClassName(oGetItem), CSS_GET_FOCAL ))
oGetItem:bLostFocus := { ||  IIF( !Empty(AllTrim(cItem)),;
							 Eval({|| STISelectItem( Val(cItem), oGetList ), cItem := Space(nTamItem),oGetItem:SetFocus()}),oBtnConfirm:SetFocus())}

oLblProdutos:= TSay():New(nVertLbl2,POSHOR_1,{||STR0003},oMainPanel,,,,,,.T.,,,,)  // "Relação de produtos com vale troca:"
oLblProdutos:SetCSS( POSCSS (GetClassName(oLblProdutos), CSS_LABEL_FOCAL )) 

oGetList := TListBox():Create(oMainPanel, nVertGet2, POSHOR_1, {|u| If(PCount()>0,cGetList:=u,cGetList)}, , LARG_LIST_CONSULT , ALT_LIST_CONSULT ,,,,,.T.,,{||.T.},oListFont)
oGetList:SetCSS( POSCSS (GetClassName(oGetList), CSS_LISTBOX )) 

STILoadItensList( oGetList )

oBtnConfirm	:= TButton():New(	POSVERT_BTNFOCAL,POSHOR_BTNFOCAL,STR0004+CRLF+STR0005,oMainPanel,; //"Voltar para" ### "Registro de Itens"
							{ || Iif(ExistFunc("StiMataObj"),StiMataObj(oMainPanel),Nil), STIRegItemInterface(),STFCleanInterfaceMessage() }, LARGBTN,ALTURABTN,,,,.T. )

oBtnCancel	:= TButton():New(	POSVERT_BTNFOCAL,POSHOR_1,STR0006,oMainPanel,; //"Limpar Seleção"
							{ || aCVTs := {},oGetList:SetArray( aCVTs ) }, LARGBTN,ALTURABTN,,,,.T. )
						
						
oBtnConfirm:SetCSS( POSCSS (GetClassName(oBtnConfirm), CSS_BTN_FOCAL ))				
oBtnCancel:SetCSS( POSCSS (GetClassName(oBtnCancel), CSS_BTN_ATIVO )) 
oGetItem:SetFocus()

Return oMainPanel

//-------------------------------------------------------------------
/*{Protheus.doc} STISelectItem
Seleciona o item para o vale troca

@param
@author  Varejo
@version P11.8
@since   23/07/2012
@return  lRet			Retorno se executou corretamente a funcao
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function STISelectItem( nItem, oGetList )
Local cItem := ""

DEFAULT nItem := 0

cItem := StrZero( nItem, nTamItem, 0 )

oGetList:SetArray( {} )

If aScan( aCVTs, cItem ) == 0 

	If !STDPBIsDeleted( "SL2", nItem )
		Aadd( aCVTs, cItem )
		STFCleanInterfaceMessage()
	Else
		STFMessage( ProcName(), "STOP", STR0007 ) // "Este item foi cancelado!"
		STFShowMessage(ProcName())
	EndIf
	
Else	

	STFMessage( ProcName(), "STOP", STR0008 ) // "Item já selecionado!"
	STFShowMessage(ProcName())
	
EndIf

STILoadItensList( oGetList )

Return

//-------------------------------------------------------------------
/*{Protheus.doc} STISelectItem
Seleciona o item para o vale troca

@param
@author  Varejo
@version P11.8
@since   23/07/2012
@return  lRet			Retorno se executou corretamente a funcao
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function STILoadItensList( oGetList )
Local aItensList := {}
Local cItemList  := ""
Local nX         := 0

For nX := 1 To Len(aCVTs)

	cItemList := aCVTs[nX]
	Aadd( aItensList,STR0009+cItemList+" / "+STR0010+STDGPBasket( "SL2" , "L2_DESCRI" , Val(cItemList) ) ) // "Item nº " ### "Produto: "
	
Next nX

oGetList:SetArray( aItensList )

Return Nil

//-------------------------------------------------------------------
/*{Protheus.doc} STIGetCVTs
Retorna array com os itens que terao o vale troca impresso.

@author  Varejo
@version P11.8
@since   11/11/2013
@return  aCVTs	- array com os itens que terao o vale troca impresso
/*/
//-------------------------------------------------------------------
Function STIGetCVTs(  )

Return aCVTs

//-------------------------------------------------------------------
/*{Protheus.doc} STICVTClear
Limpa o array com os itens que terao o vale troca impresso.

@author  Varejo
@version P11.8
@since   11/11/2013
/*/
//-------------------------------------------------------------------
Function STICVTClear(  )

aCVTs := {}

Return 

