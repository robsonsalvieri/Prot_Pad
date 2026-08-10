#Include 'Protheus.ch'
#INCLUDE 'FWBROWSE.CH'
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"                            
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "POSCSS.CH"
#INCLUDE "STPOS.CH" 
#INCLUDE "STIPRODSEARCH.CH" 

Static aRecno		:= {}
Static nTpSrchPro	:= SuperGetMV("MV_LJTPSCH", .F., 0)  
Static lOnlyCodBar	:= (nTpSrchPro==1)
Static lHomolPaf	:= STBHomolPaf()
Static lDisableBtn 	:= .F.
Static cGetProduct	:= Iif(lOnlyCodBar, Space(TamSx3("LK_CODBAR")[1]), Space(40))				// Variável do Get 
Static cPictValUnit	:= PesqPict("SL2","L2_VRUNIT")
Static oLblProdDados:= Nil
Static oLblProdVal	:= Nil						// Variável para armazenar o valor do produto
Static oMainPanel   := Nil


//-------------------------------------------------------------------
/*{Protheus.doc} STIProdSearch
Funcao responsavel por chamar a troca do painel atual pelo painel de selecao de produtos.

@author Vendas CRM
@since 26/04/2013
@version 11.80

*/
//-------------------------------------------------------------------

Function STIProdSearch()

Local lMobile := STFGetCfg("lMobile", .F.)		//Smart Client Mobile
	
STIChangeCssBtn("oBtnConProd")

If ValType(lMobile) == "L" .AND. lMobile
	//Tela especifica versao mobile
	STIExchangePanel( { || STIPanMobProdSearch() } )
Else
	//Tela Padrao
STIExchangePanel( { || STIPanProdSearch() } )
EndIf

Return

//-------------------------------------------------------------------
/*{Protheus.doc} STIPanProdSearch
Funcao responsavel pela criacao do Painel de selecao de produtos.

@author Vendas CRM
@since 26/04/2013
@version 11.80
@return oMainPanel - Objeto contendo o painel principal de selecao de clientes.
*/
//-------------------------------------------------------------------
Static Function STIPanProdSearch()

Local oPanelMVC  		:= STIGetPanel()				// Objeto do Panel onde a interface de selecao de clientes sera criada

Local oLblCab			:= Nil							// Objeto do label "Seleção de Cliente"
Local oLblSearch		:= NIl							// Objeto do label "Digite aqui para filtrar"

/*/
	Get Combo de Busca
/*/
Local oGetList			:= Nil							// TComboBox Escolha do campo a ser utilizado na busca
Local cGetList			:= ""							// Variável do Get


/*/
	Get de Busca
/*/
Local oGetSearch		:= Nil							// TGet Cancelamento de Item
Local lPAFECF 			:= STFGetCfg("lPafEcf")


/*/
	Botão "Selecionar Cliente"
/*/
Local oButton			:= Nil							// Botao "Selecionar Cliente"

Local oListFont 		:= TFont():New("Courier New") 	// Fonte utilizada no listbox
Local oLblList			:= Nil
Local bConfirm			:= { || STIConfirmProd(oGetList), SetKey(19, {|| .F.})}
Local cLabelCons		:= STR0003 + IIF(!lPAFECF, "", STR0012) /// UN / Sit Trib/ IAT / IPPT 
Local oImg              := Nil
Local oLblInfProd       := Nil
Local cDados			:= "Descrição do Produto" + CRLF + CRLF + CRLF + "Código"
Local lBusca			:= .F. //Executou a busca do componente
Local CValor			:= CRLF + CRLF + CRLF + "Valor"
Local oLblValProd		:= Nil
Local cPathImg  		:= AllTrim(SuperGetMV("MV_LJIMAGE", .F., ""))	 // Caminho da imagem do produto Opcional
Local cColor 			:= Nil
Local cMascara 			:= "@" + Iif(lOnlyCodBar,  Padr("R",TamSx3("LK_CODBAR")[1],"9"), "!")

cGetProduct	:= Iif(lOnlyCodBar, Space(TamSx3("LK_CODBAR")[1]), Space(40))

If oMainPanel <> Nil 
	LjGrvLog("STIProdSearch" , "Dextroi oMainPanel Hparent: "+ Str(oMainPanel:Hparent) + " oPanel1 Hwnd : " +  Str(oMainPanel:Hwnd) )
	oMainPanel:FreeChildren()
	FreeObj(oMainPanel)
Endif 

oMainPanel 		:= TPanel():New(00,00,"",oPanelMVC,,,,,,oPanelMVC:nWidth/2,(oPanelMVC:nHeight)/2) // Painel de Get de Consulta

If ExistBlock("STClrBProd")
	cColor := ExecBlock("STClrBProd",.F.,.F.)

	If !Empty(cColor) .AND. ValType( cColor) == "C"
		oMainPanel:SetCSS("QFrame{ background-color: " + cColor + "}")
	EndIf 

EndIf

/*/
	Objetos
/*/

oLblCab:= TSay():New(POSVERT_CAB,POSHOR_1,{||Iif(lOnlyCodBar, STR0022, STR0001)},oMainPanel,,,,,,.T.,,,,)  //"Consulta de Produtos"
oLblCab:SetCSS( POSCSS (GetClassName(oLblCab), CSS_BREADCUMB )) 

oLblSearch := TSay():New(oPanelMVC:nHeight/26.92,POSHOR_1, {||STR0002}, oMainPanel,,,,,,.T.)  //'Pesquisar Produto:'
oLblSearch:SetCSS( POSCSS (GetClassName(oLblSearch), CSS_LABEL_FOCAL )) 
                                                
oGetSearch:= TGet():New(	oPanelMVC:nHeight/14.955,POSHOR_1,{|u| If(PCount()>0,(lBusca := .F.,cGetProduct:=u), cGetProduct)}, ;
							oMainPanel,120 ,ALTURAGET,cMascara,,,,,,,.T.,,,,,,,,,,"cGetProduct") //colocar o valid
oGetSearch:SetCSS( POSCSS (GetClassName(oGetSearch), CSS_GET_NORMAL )) 
oGetSearch:bLostFocus 	:= { || If(!lBusca, STLostFocus(oGetSearch,oGetList,@cGetProduct, @lBusca), IIf(oGetList:Len() > 1,(oGetList:SetFocus(),Nil),oButton:SetFocus()))}

oLblList := TSay():New(oPanelMVC:nHeight/8.412,POSHOR_1, {|| cLabelCons }, oMainPanel,,,,,,.T.)  //'Descrição / Código / Valor'
oLblList:SetCSS( POSCSS (GetClassName(oLblList), CSS_LABEL_FOCAL )) 

oGetList := TListBox():Create(oMainPanel, oPanelMVC:nHeight/6.73, POSHOR_1, {|u| If(PCount()>0,cGetList:=u,cGetList)}, , LARG_LIST_CONSULT , oPanelMVC:nHeight/9 ,{|o| IF(lBusca,  STIChangeInfo( o, oImg ), ) },,,,.T.,,bConfirm,oListFont)
oGetList:SetCSS( POSCSS (GetClassName(oGetList), CSS_LISTBOX )) 

oLblInfProd := TSay():New(oPanelMVC:nHeight/3.6378,POSHOR_1,{||cDados},oMainPanel,,,,,,.T.,,,,80)	// Descrição e Código do Produto
oLblInfProd:SetCSS( POSCSS (GetClassName(oLblInfProd), CSS_LABEL_NORMAL )) 

oLblValProd := TSay():New(oPanelMVC:nHeight/3.6378,POSHOR_1+130,{||cValor},oMainPanel,,,,,,.T.,,,,100)	// Valor do Produto
oLblValProd:SetCSS( POSCSS (GetClassName(oLblValProd), CSS_LABEL_NORMAL )) 

//Verifica se usa foto de arquivo 
If Empty(cPathImg)
	@ oPanelMVC:nHeight/3.6378,oPanelMVC:nWidth/3.01886 REPOSITORY oImg OF oMainPanel NOBORDER SIZE 100,100 PIXEL
Else
	oImg := TBitmap():New( oPanelMVC:nHeight/3.6378,oPanelMVC:nWidth/3.01886,100,100,,"",.T.,oMainPanel,{||},,.F.,.F.,,,.F.,,.T.,,.F.)
	oImg:lStretch:= .T.
EndIf
oImg:lVisibleControl := .F.

oButton	:= TButton():New(	POSVERT_BTNFOCAL,POSHOR_BTNFOCAL,STR0004+CRLF+STR0014,oMainPanel,bConfirm, ;  //"Selecionar Produto" + "CTRL+S"
							LARGBTN,ALTURABTN,,,,.T.,,,,{||IIF(Len(aRecno) > 0, .T., .F.)})
oButton:SetCSS( POSCSS (GetClassName(oButton), CSS_BTN_FOCAL )) 

oButCan	:= TButton():New(	POSVERT_BTNFOCAL,POSHOR_1,STR0013+CRLF+STR0015,oMainPanel,{|| STIRetItem() }, ;  //"Cancela Pesquisa" + "(CTRL+A)"
							LARGBTN,ALTURABTN,,,,.T.,,,,{||.T.})
oButCan:SetCSS( POSCSS (GetClassName(oButCan), CSS_BTN_FOCAL )) 

SetKey(19, bConfirm)
SetKey(1, {|| STIRetItem() })

oGetSearch:SetFocus()
If GetFocus() <> oGetSearch:HWND
    oGetSearch:SetFocus()
Endif 


Return oMainPanel


//-------------------------------------------------------------------
/*{Protheus.doc} STIPanMobProdSearch
Funcao responsavel pela criacao do Painel de selecao de produtos versao Mobile.

@author Vendas CRM
@since 26/04/2013
@version 11.80
@return oMainPanel - Objeto contendo o painel principal de selecao
*/
//-------------------------------------------------------------------
Static Function STIPanMobProdSearch()
	
Local oPanelMVC  			:= STIGetPanel()				// Objeto do Panel onde a interface de selecao de produtos sera criada
Local oLblCab				:= Nil							// Objeto do label "Seleção de produtos"
Local oLblSearch			:= NIl							// Objeto do label "Digite aqui para filtrar"
Local oGetList			:= Nil							// TComboBox Escolha do campo a ser utilizado na busca
Local cGetList			:= ""							// Variável do Get
Local oGetSearch			:= Nil							// TGet busca do item
Local oGetQtde			:= Nil							// TGet quantidade do item
Local oGetVlrDesc			:= Nil							// TGet Valor desconto
Local oGetPercDesc		:= Nil							// TGet percentual de desconto
Local nGetQtde			:= 1							// Quantidade
Local nGetVlrDesc			:= 0							// Valor de desconto
Local nGetPercDesc		:= 0 							// Percentual de desconto
Local oButton				:= Nil							// Botao "Selecionar produto"
Local oListFont 			:= TFont():New("Courier New") // Fonte utilizada no listbox
Local oLblList			:= Nil							// Objeto list
Local bConfirm			:= { || } 						//Bloco de confirmacao
Local cLabelCons			:= STR0003 					 	// UN / Sit Trib/ IAT / IPPT
Local lBusca				:= .F. 							//Valida se Executou a busca do componente
Local oButPesq			:= Nil 							//Botao pesquisar
Local oLblQuantidade		:= Nil 							//Label quantidade
Local oLblVlrDesc			:= Nil 							//Label desconto valor
Local oLblPercDesc		:= Nil 							//Label desconto percentual
Local oLblSimbPerc		:= Nil 							//Label simbolo desconto percentual
Local lFindAll			:= .T.								//Busca em todos os registros caso deixe o get em branco
Local oButCan				:= Nil							   	//Botao Cancelar

bConfirm			:= { || STIConfirmProd( oGetList ,;
												IIF(nGetQtde > 0 .AND. nGetQtde <= 999,AllTrim(STR(nGetQtde))+"*","") + ; // Quantidade do item
												IIF(nGetVlrDesc > 0 , AllTrim(STR(nGetVlrDesc)) + "-" , IIF(nGetPercDesc > 0 , AllTrim(STR(nGetPercDesc)) + "%" , "" ) ) ) ; // Valor de desconto
												, SetKey(19, {|| .F.}) }

oMainPanel 		:= TPanel():New(00,00,"",oPanelMVC,,,,,,oPanelMVC:nWidth/2,(oPanelMVC:nHeight)/2) // Painel de Get de Consulta

oLblCab:= TSay():New(POSVERT_CAB,POSHOR_1,{||STR0001},oMainPanel,,,,,,.T.,,,,)  //"Consulta de Produtos"
oLblCab:SetCSS( POSCSS (GetClassName(oLblCab), CSS_BREADCUMB ))

oLblSearch := TSay():New(oPanelMVC:nHeight/26.92,POSHOR_1, {||STR0002}, oMainPanel,,,,,,.T.)  //'Pesquisar Produto:'
oLblSearch:SetCSS( POSCSS (GetClassName(oLblSearch), CSS_LABEL_FOCAL ))

//Get de Produtos
oGetSearch:= TGet():New(	oPanelMVC:nHeight/14.955,POSHOR_1,{|u| If(PCount()>0,(lBusca := .F.,cGetProduct:=u), cGetProduct)}, ;
oMainPanel,120 ,ALTURAGET,"@!",,,,,,,.T.,,,,,,,,,,"cGetProduct")
oGetSearch:SetCSS( POSCSS (GetClassName(oGetSearch), CSS_GET_NORMAL ))

//"Botao pesquisar"
oButPesq	:= TButton():New(	oPanelMVC:nHeight/14.955,POSHOR_1+130,"",oMainPanel,{ || If(!lBusca, STLostFocus(oGetSearch,oGetList,@cGetProduct, @lBusca , lFindAll ), .T. )},20,20,,,,.T.,,,,)
oButPesq:SetCSS( POSCSS (GetClassName(oButPesq), CSS_BTN_LUPA ))


oLblList := TSay():New(oPanelMVC:nHeight/8.412,POSHOR_1, {|| cLabelCons }, oMainPanel,,,,,,.T.)  //'Descrição / Código / Valor'
oLblList:SetCSS( POSCSS (GetClassName(oLblList), CSS_LABEL_FOCAL ))

oGetList := TListBox():Create(oMainPanel, oPanelMVC:nHeight/6.73, POSHOR_1, {|u| If(PCount()>0,cGetList:=u,cGetList)}, , LARG_LIST_CONSULT , oPanelMVC:nHeight/7 ,{|| },,,,.T.,,bConfirm,oListFont)
oGetList:SetCSS( POSCSS (GetClassName(oGetList), CSS_LISTBOX ))

//Get de Quantidade
oLblQuantidade := TSay():New(oPanelMVC:nHeight/3.3,POSHOR_1,{||STR0017},oMainPanel,,,,,,.T.,,,,100)//"Quantidade"
oLblQuantidade:SetCSS( POSCSS (GetClassName(oLblQuantidade), CSS_LABEL_NORMAL ))


oGetQtde:= TGet():New(	oPanelMVC:nHeight/3,POSHOR_1,{|u| If(PCount()>0,nGetQtde:=u,nGetQtde)}, ;
	oMainPanel,40 ,ALTURAGET,"@E 999",{|| nGetQtde > 0 .AND. nGetQtde <= 999 },,,,,,.T.,,,,,,,,,,"nGetQtde",,,,,.T.)
oGetQtde:SetCSS( POSCSS (GetClassName(oGetQtde), CSS_GET_NORMAL ))


//Get de valor de desconto
oLblVlrDesc := TSay():New(oPanelMVC:nHeight/3.3,oPanelMVC:nWidth/7,{||STR0018},oMainPanel,,,,,,.T.,,,,100)//"Valor de Desconto"
oLblVlrDesc:SetCSS( POSCSS (GetClassName(oLblVlrDesc), CSS_LABEL_NORMAL ))

oGetVlrDesc:= TGet():New(	oPanelMVC:nHeight/3,oPanelMVC:nWidth/7,{|u| If(PCount()>0,nGetVlrDesc:=u,nGetVlrDesc)}, ;
	oMainPanel,60 ,ALTURAGET,"@E 999,999.99",,,,,,,.T.,,,,,,,,,,"nGetVlrDesc",,,,,.T.)
oGetVlrDesc:SetCSS( POSCSS (GetClassName(oGetVlrDesc), CSS_GET_NORMAL ))

//percentual de Desconto
oLblPercDesc := TSay():New(oPanelMVC:nHeight/3.3,oPanelMVC:nWidth/3.5,{||STR0019},oMainPanel,,,,,,.T.,,,,100)//"Percentual de Desconto"
oLblPercDesc:SetCSS( POSCSS (GetClassName(oLblPercDesc), CSS_LABEL_NORMAL ))

oGetPercDesc:= TGet():New(	oPanelMVC:nHeight/3,oPanelMVC:nWidth/3.5,{|u| If(PCount()>0,nGetPercDesc:=u,nGetPercDesc)}, ;
	oMainPanel,60 ,ALTURAGET,"@E 99.99",,,,,,,.T.,,,,,,,,,,"nGetPercDesc",,,,,.T.)
oGetPercDesc:SetCSS( POSCSS (GetClassName(oGetPercDesc), CSS_GET_NORMAL ))

oLblSimbPerc := TSay():New(oPanelMVC:nHeight/2.9, oPanelMVC:nWidth/3.5 + ((oGetPercDesc:nWidth/2) + 3 ) ,{||"%"},oMainPanel,,,,,,.T.,,,,100)
oLblSimbPerc:SetCSS( POSCSS (GetClassName(oLblSimbPerc), CSS_LABEL_NORMAL ))

//Selecioanr produto							
oButton	:= TButton():New(	POSVERT_BTNFOCAL,POSHOR_BTNFOCAL ,STR0004,oMainPanel,bConfirm, ;  //"Selecionar Produto"
								LARGBTN,ALTURABTN,,,,.T.,,,,{||IIF(Len(aRecno) > 0, .T., .F.)})								
oButton:SetCSS( POSCSS (GetClassName(oButton), CSS_BTN_FOCAL ))

//Cancelar
oButCan	:= TButton():New(	POSVERT_BTNFOCAL,POSHOR_1,STR0013,oMainPanel,{|| STIRetItem() }, ;  //"Cancela Pesquisa"
LARGBTN,ALTURABTN,,,,.T.,,,,{||.T.})
oButCan:SetCSS( POSCSS (GetClassName(oButCan), CSS_BTN_NORMAL ))

SetKey(19, bConfirm)
SetKey(1, {|| STIRetItem() })

oGetSearch:SetFocus()
	
Return oMainPanel


//-------------------------------------------------------------------
/*{Protheus.doc} STISearchProd
Responsavel pela criaçao do filtro que sera passado ao Browse, com base nas informacoes digitadas pelo usuario.

@param cGetProduct   - String digitada pelo usuario utilizada para pesquisar o produto.
@param cGetList      - Campo que será utilizado para pesquisa.
@param lFindAll      - Busca todos os registros e traz os primeiros que achar
@author Vendas CRM
@since 26/04/2013
@version 11.80
*/
//-------------------------------------------------------------------
Static Function STISearchProd(cGetProduct, oGetList, oGetSearch , lFindAll )
Local aArea			:= GetArea()
Local nSec1, nSec2
Local nLimit		:= SuperGetMV("MV_LJQTDPL",,20)
Local lMinGetSize	:= Len(AllTrim(oGetSearch:cText)) >= 3 .Or. ( Len(oGetSearch:cText) < 3 .AND. SubStr(oGetSearch:cText,1,1) $ "0123456789" )
Local aInfoItem 	:= {}
Local aProducts		:= {}
Local nMoeda		:= STBGetCurrency()
Local oCliModel		:= STDGCliModel()					// Model do Cliente	
Local cCliCode  	:= oCliModel:GetValue("SA1MASTER","A1_COD")
Local cCliLoja  	:= oCliModel:GetValue("SA1MASTER","A1_LOJA")
Local cMoedaSimb	:= SuperGetMV( "MV_SIMB" + Str(nMoeda ,1 ) ) 
Local cFilter 		:= IIF(FindFunction("STDIsPrdLike"), AllTrim(cGetProduct), "'" + AllTrim(cGetProduct) + "' $ AllTrim(SB1->B1_DESC) .AND. SB1->B1_MSBLQL<>'1'") 	// Filtro que será utilizado para pesquisar o cliente desejado.
Local lRet			:= .T.   
Local lPAFECF 		:= STFGetCfg("lPafEcf")
Local cMsgAlert 	:= ""
Local nPrice		:= 0
Local cFields		:= SuperGetMV("MV_LJCMP",,"")	

Default  lFindAll := .F. //Busca todos os registros e traz os primeiros que achar 

nSec1 := Seconds()
oGetList:Reset()
aRecno := {}


If !Empty(cGetProduct) .OR. lFindAll
	
	STFMessage(ProcName(),"STOP",STR0016) //"Pesquisando produto. Aguarde..."
	STFShowMessage(ProcName())
	
	CursorWait()
	
	/*	Busca item na base de dados */
	aInfoItem	:= STWFindItem( cGetProduct, lPAFECF, lHomolPaf, lOnlyCodBar )
		
	// Encontrou o item?
	If !lFindAll .AND. aInfoItem[ITEM_ENCONTRADO]
		If !aInfoItem[ITEM_BLOQUEADO]

			If  ExistFunc("STDPrcKit") .AND. aInfoItem[ITEM_TIPO] == "KT"
				nPrice 	:= STDPrcKit( 	aInfoItem[ITEM_CODIGO]	, cCliCode	, Nil 	, cCliLoja	,;
									nMoeda )
			Else
				nPrice 	:= STWFormPr( 	aInfoItem[ITEM_CODIGO]	, cCliCode	, Nil 	, cCliLoja	,;
									nMoeda ) 
				nPrice 	:= STBArred( nPrice * Iif(Empty(aInfoItem[ITEM_QTDE]),1, aInfoItem[ITEM_QTDE])) 
			Endif

			If nPrice > 0
				nPrice := STBRound( nPrice )
				aAdd(aRecno,SB1->(Recno()))
				If !lPAFECF
					aAdd(aProducts,AllTrim(aInfoItem[ITEM_DESCRICAO])+" / "+AllTrim(aInfoItem[ITEM_CODIGO])+" / "+cMoedaSimb+AllTrim(Transform(nPrice,PesqPict("SL1","L1_VLRTOT"))))
				Else
					aAdd(aProducts,AllTrim(aInfoItem[ITEM_DESCRICAO])+" / "+;
									AllTrim(aInfoItem[ITEM_CODIGO])+" / "+;
									cMoedaSimb+AllTrim(Transform(nPrice,PesqPict("SL1","L1_VLRTOT")))+" / "+;
   									AllTrim(aInfoItem[ITEM_UNID_MEDIDA] ) +" / "+;
   									AllTrim(aInfoItem[ITEM_SITTRIB])  + " / "+;
   							   		AllTrim(aInfoItem[ITEM_IAT]) +" / "+; 
   							   		AllTrim(aInfoItem[ITEM_IPPT])) //

				EndIf
			EndIf		
		EndIf
	ElseIf (lMinGetSize .OR. lFindAll) .AND. !lOnlyCodBar
	
		If FindFunction("STDFindProd")
			aProducts := STDFindProd( cFilter, 		cCliCode, 		cCliLoja, nMoeda, ;
										nLimit, 		lPAFECF, 		lHomolPaf,	@aRecno, cFields)
		Else
			ConOut("Atualizar o fonte STDFindItem")
		EndIf
		
	Else
		lRet := .F.
		cMsgAlert := STR0005 //"É necessário digitar pelo menos 3 caracteres."
	EndIf
EndIf

oGetList:SetArray(aProducts)

nSec2 := Seconds()-nSec1

Conout("-------------------------")
ConOut("O tempo de pesquisa foi de "+AllTrim(Str(nSec2))+" segundos.")
Conout("-------------------------")

If lMinGetSize
	If nPrice == -999
		cMsgAlert := STR0020 + CHR(13)+CHR(10) + STR0021  //"Tabela de preço fora de vigência."  "Verifique o código da tabela contido no parâmetro MV_TABPAD"
		lRet := .F.
	ElseIf Len(aProducts) == 0
		cMsgAlert := STR0006 //"Nenhum produto encontrado."
		lRet := .F.
	Else
		If Len(aProducts) == nLimit
			cMsgAlert := STR0007+" "+AllTrim(Str(Len(aProducts)))+" "+STR0008 //"O resultado foi limitado a" .. "produtos. Refine sua busca se for necessário."
		ElseIf Len(aProducts) == 1
			cMsgAlert := STR0009 //"1 produto foi encontrado."			
		Else
			cMsgAlert := STR0010+" "+AllTrim(Str(Len(aProducts)))+" "+STR0011 //"Foram encontrados" .. "produtos."
		EndIf
		
		oGetList:SetFocus()
		oGetList:GoTop()

	EndIf
EndIf

STFCleanInterfaceMessage()

If !Empty(cMsgAlert)
	STFMessage(ProcName(),"STOP",cMsgAlert) //Exibe mensagem de alerta ao usuário
	STFShowMessage(ProcName())
EndIf

CoNout(Time())
RestArea(aArea)
CursorArrow()

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} STIConfirmProd
Responsavel por registrar o produto selecionado na venda.

@param oGetList     - Objeto da lista de produtos
@param cQtdDesc     - Texto para desconto e quantidade funciona idem ao get de produtos
@author Vendas CRM
@since 26/04/2013
@version 11.80
*/
//-------------------------------------------------------------------
Static Function STIConfirmProd( oGetList , cQtdDesc)
Local nRecno	:= 0
Local nTotItem  := oGetList:Len()
Local nPos		:= oGetList:GetPos()
Local lGrvPesq :=  AliasInDic("MFL") .AND. SuperGetMV("MV_LJGRVCS", .F., 0) == 1 //Valida se grava Consulta de produtos

Default cQtdDesc := ""

If Empty(cQtdDesc)
	cQtdDesc := AllTrim(STIGetProd())
EndIf
If nPos > 0
	nRecno := aRecno[nPos]
	cGetProduct := Iif(lOnlyCodBar, Space(TamSx3("LK_CODBAR")[1]), Space(40))
	SB1->(DbGoTo(nRecno))
	
	If  !(SuperGetMV("MV_LJMTDIT",,.F.) .AND. ("%" $ cQtdDesc .Or. "-" $ cQtdDesc))
		STIRegItemInterface(,.F.)
	EndIf 

	STIItemregister(cQtdDesc + SB1->B1_COD)
	
	// Grava Consulta na tabela MFL
	If lGrvPesq  // Se existir tabela MFL - Consulta de Preco pelo PDV 
		STIRecProdMFL({{SB1->B1_COD}})
	EndIf
	aRecno := {}
ElseIf nPos == 0 .And. nTotItem > 0 // Caso exista um item no ListBox mas ele não esteja posicionado, força o foco no objeto oGetList para atualizar a tela e não deixar o botão "Selecionar Produto" travado pelo mouse
    oGetList:SetFocus()      
EndIf

Return .T.

//-------------------------------------------------------------------
/*{Protheus.doc} STIRetItem
Quando clicar em cancelar volta para a tela de registro de item

@param 
@author  Vendas CRM
@since   26/04/2013
@version 11.80
*/
//-------------------------------------------------------------------
Static Function STIRetItem()
CursorArrow()
cGetProduct := Iif(lOnlyCodBar, Space(TamSx3("LK_CODBAR")[1]), Space(40))
STIRegItemInterface()
Return .T.

//-------------------------------------------------------------------
/*{Protheus.doc} STIChangeInfo
Troca a imagem e as informacoes do produto ao rolar a lista de produtos.

@param 
@author  Vendas CRM
@since   26/04/2013
@version 11.80
*/
//-------------------------------------------------------------------
Static Function STIChangeInfo( oList, oImg )
Local nRecno	:= 0                                            // Recno do produto na SB1
Local nPos		:= oList:GetPos()                               // Linha posicionada da listbox
Local aArea     := GetArea()                                    // Guarda area corrente
Local nMoeda    := STBGetCurrency()                             // Moeda corrente
Local cMoedaSimb:= SuperGetMV( "MV_SIMB" + Str(nMoeda ,1 ) ) 	// Simbolo da moeda corrente
Local cProdData := ""                                           // Dados do produto
Local oPanelMVC := STIGetPanel()                                // Panel onde serao exibidas as informacoes do produto
Local nPrice    := 0                                            // Preco do produto
Local cProdVal  := ""
Local cPathImg  := AllTrim(SuperGetMV("MV_LJIMAGE", .F., ""))	 // Caminho da imagem Opcional 
Local cExtImg  	:= AllTrim(SuperGetMV("MV_LJIMGEX", .F., ".jpg"))// extensão da imagem Opcional 
Local cMVLJB1COD:= AllTrim(SuperGetMV("MV_LJB1COD",,"B1_COD")) 	//Campo que será utilizado para consulta da imagem do produto 
Local cNomeImg  := ""

If nPos > 0 .AND. nPos <= Len(aRecno)
	nRecno := aRecno[nPos]
	cGetProduct := Iif(lOnlyCodBar, Space(TamSx3("LK_CODBAR")[1]), Space(40))
	SB1->(DbGoTo(nRecno))
	
	nPrice 	:= STWFormPr( SB1->B1_COD, STDGPBasket( "SL1", "L1_CLIENTE" ), Nil, STDGPBasket( "SL1" , "L1_LOJA" ), nMoeda )
	
	cProdData := SB1->B1_DESC+CRLF+CRLF+CRLF+AllTrim(SB1->B1_COD)
	cProdVal  := CRLF+CRLF+CRLF+cMoedaSimb+AllTrim(Transform(nPrice,PesqPict("SL1","L1_VLRTOT")))
	
	If ValType(oLblProdDados) <> "U"
		oLblProdDados:SetText(cProdData)
		oLblProdVal:SetText(cProdVal)
	Else
		oLblProdDados:= TSay():New(oPanelMVC:nHeight/3.6378+10,POSHOR_1,{||cProdData},oMainPanel,,,,,,.T.,,,,33)
		oLblProdDados:SetCSS( POSCSS (GetClassName(oLblProdDados), CSS_LABEL_FOCAL ))
				
		oLblProdVal := TSay():New(oPanelMVC:nHeight/3.6378+10,POSHOR_1+130,{||cProdVal},oMainPanel,,,,,,.T.,,,,33)
		oLblProdVal:SetCSS( POSCSS (GetClassName(oLblProdVal), CSS_LABEL_FOCAL )) 
	EndIf

	//Verifica se usa foto de arquivo 
	If Empty(cPathImg)
		cNomeImg := AllTrim(SB1->B1_BITMAP)
		If !Empty(cNomeImg) .And. oImg:ExistBmp(cNomeImg)
			ShowBitmap(oImg,cNomeImg,"SEMFOTO")
			oImg:lVisibleControl := .T.
		Else
			oImg:lVisibleControl := .F.
		EndIf
	Else
		cNomeImg := AllTrim(SB1->&(cMVLJB1COD))
		If oImg:Load( Nil ,cPathImg + cNomeImg + cExtImg )
			oImg:lVisibleControl := .T.
		ElseIf ValType(oImg) == "O"			
			oImg:SetEmpty()
			oImg:lVisibleControl := .F.
		EndIf		
	EndIf

EndIf

RestArea(aArea)

Return
//-------------------------------------------------------------------
/*{Protheus.doc} STLostFocus
Rotina executada ao mudar o foco do componente

@param oGetSearch - Objeto contento o componente que será executada a rotina de perda de foco 
@param oGetList     - Objeto da lista de produtos
@param lFindAll      - Busca todos os registros e traz os primeiros que achar
@author  Vendas CRM
@since   20/08/2014
@version 11.80
*/
//-------------------------------------------------------------------
Static Function STLostFocus(oGetSearch,oGetList, cGetProduct, lBusca ,;
								lFindAll)

Default  lFindAll := .F. //Busca todos os registros e traz os primeiros que achar

lBusca := .T.
If !Empty(cGetProduct) .OR. ( Empty(cGetProduct) .AND. lFindAll)
	IF !STISearchProd(cGetProduct, oGetList, oGetSearch ,lFindAll )
		cGetProduct:= Iif(lOnlyCodBar, Space(TamSx3("LK_CODBAR")[1]), Space(40))
		oGetSearch:SetFocus()
	EndIf
EndIf

Return .T.

