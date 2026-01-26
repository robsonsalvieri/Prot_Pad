#INCLUDE "Protheus.ch"
#INCLUDE "POSCSS.CH"
#INCLUDE "STPOS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "STIGIFTLIST.CH"

#DEFINE POS_MMODO			1				//Modo de abertura
#DEFINE POS_MRET			2       		//Modo de retorno
#DEFINE POS_MTPL			3				//Tipo da lista
#DEFINE POS_MNL			4				//Numero da lista (Filtro ME1)
#DEFINE POS_MONL			5				//Online
#DEFINE POS_MLNOM			6				//Entrar com nomes dos presenteadores
#DEFINE POS_MLENVM		7				//Enviar mensagem
#DEFINE POS_MLITAB		8				//Listar itens em aberto
#DEFINE POS_MORI			9				//Origem da lista (filtro ME1)
#DEFINE POS_MFILT			10				//Filtro (ME2)
#DEFINE POS_MMULT			11				//Multi-selecao
#DEFINE POS_MMTOD			12				//Marcar todos
#DEFINE POS_MQTDU			13				//Quantidade utilizada
#DEFINE POS_MLAQTD		14				//Alterar quantidade
#DEFINE POS_MAME			15				//Alterar modo de entrega
#DEFINE POS_MTPEVE		16				//Tipo de evento (filtro ME1)
#DEFINE POS_MSTAT			17	  			//Status da lista (filtro ME1)

Static aMainCFG := {}					//ConfiguraÁıes da Lista de Eventos
Static oGetContGen		:= NIL							//Conteudo do css
Static oBrwConten 		:= Nil  		       	//Objeto do Browse da Direita
Static lIncluirPrd		:= .F.				// Verifica qual opÁ„o selecionado - Incluir Produto ou alterar Quant.


//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIGiftList
FunÁ„o Principal da Lista de Presentes

@param   	
@author		Varejo
@version	P11.8
@since		16/12/14
@return	nil
@obs
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Function STIGiftList()
Local oPanel := nil
	oGetContGen		:= NIL	
	oBrwConten 		:= Nil
	aMainCFG := {}
	STIExchangePanel({ || STIPnlGList(oPanel ) } )
Return

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIPnlGList
Cria o objeto da tela principal

@param   	o - Objeto do painel Principal
@author	Varejo
@version	P11.8
@since		16/12/14
@return	oGetCrtUtent
@obs
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Function STIPnlGList( o )

	Local oGetCrtUtent 			//Objeto de interacao com usuario
	Local aItemLst := {}			//Array dos Itens de Lista da Venda
		
	aItemLst := STDGLLoIt()

	Private aBrDados := {}
	@ 000,000 BITMAP oGetCrtUtent RESOURCE "x.png" NOBORDER SIZE 000,000 OF o ADJUST PIXEL
	oGetCrtUtent:Align := CONTROL_ALIGN_ALLCLIENT
	oGetCrtUtent:ReadClientCoors(.T.,.T.)

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥Alimentar a variavel principal de configuracoes  ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	aMainCfg := Array(17)
	aMainCfg[POS_MMODO]		:= 2
	aMainCfg[POS_MRET]		:= 3
	aMainCfg[POS_MTPL]		:= nil
	aMainCfg[POS_MNL]			:= nil
	aMainCfg[POS_MONL]		:= .f.
	aMainCfg[POS_MLNOM]		:= .f.
	aMainCfg[POS_MLENVM]		:= .T.
	aMainCfg[POS_MLITAB]		:= .T.
	aMainCfg[POS_MORI]		:= NIL
	aMainCfg[POS_MFILT]		:= NIL
	aMainCfg[POS_MMULT]		:=.T.
	aMainCfg[POS_MMTOD]		:= .T.
	aMainCfg[POS_MQTDU]		:= aItemLst
	aMainCfg[POS_MLAQTD]		:= .T.
	aMainCfg[POS_MAME]		:= .T.
	aMainCfg[POS_MTPEVE]		:= niL
	aMainCfg[POS_MSTAT]		:= 1

	STIGList(oGetCrtUtent)

Return oGetCrtUtent

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIGList
Cria os objetos principais da tela

@param   	oPanel - Objeto do painel Principal
@author	Varejo
@version	P11.8
@since		16/12/14
@return	NIL
@obs
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Static Function STIGList( oPanel )

	Local oPanelMVC	:= NIL						//Painel de Fundo
	Local oPanel1		:= NIL 						//Painel da Esquerda
	Local oPanel2		:= NIL						//Painel da Direita
	Local nLargura	:= oPanel:nWidth/2			//Largura padr„o dos paineis
	Local nAltura		:= oPanel:nHeight/2			//Altura padr„o dos paineis

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
		oPanel2	:= TPanel():New(00,nLargura/2+1,"",oPanelMVC,,,,,,nLargura/2-1,nAltura)
		oPanel2:Align := CONTROL_ALIGN_RIGHT
		oPanel2:SetCSS( POSCSS (GetClassName(oPanel2), CSS_PANEL_CONTEXT ))
	
		STIGftList( oPanel1,oPanel2, oPanelMVC)	
	EndIf

Return NIL

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIGftList
Panel Principal da Lista de Presentes
@param   	oPnlAdconal - Objeto do painel adicional da Esquerda
@param   	oPnlRight - Objeto do painel adicional da Direita
@author  	Varejo
@version 	P12
@since   	23/09/2013
@return  	oMainPanel
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Function STIGftList(oPnlAdconal,oPanel2, oPanel)

	Local oPanelMVC		:= oPnlAdconal   			   														//Painel principal do dialog
	Local oMainPanel 		:= TPanel():New(00,00,"",oPanelMVC,,,,,,oPanelMVC:nWidth/2,(oPanelMVC:nHeight)/2)	//Painel de MultiNegociacao
	Local oPanelMVC2 		:= oPanel2																			//Segundo Panel
	Local oPnlRight 		:= NIL																				//Panel da Direita
	Local oLblLista		:= NIL																				//Objeto Label da Lista

	Local nAltura 		:= (oMainPanel:nHeight / 4) * 0.20 		//Altura
	Local nCol				:= (oMainPanel:nWidth / 4) * 0.03		 	//Coordenada horizontal
	Local nLargura		:= (oMainPanel:nWidth / 4) - (2 * nCol)	//Largura
	Local nPosAltGroup	:= oPanelMVC:nHeight /4					  	//Posicao: Altura do GroupBox
	Local nTamAltGroup	:= oPanelMVC:nHeight/4 				//Tamanho: Altura do GroupBox
	Local nTamLarGroup	:= (oPanelMVC:nWidth) * 0.485				//Tamanho: Lagura do GroupBox
	Local nTop 			:= POSVERT_GET1+65							//Valor do Top
	Local nLeft 			:= 000										//Valor do Left
	Local PosVerPay		:= POSHOR_1+10							//Posicao Vertical
	Local nPosVerTit 	:= nPosAltGroup/20.500 						//Posicao inicial do titulo do painel da Esquerda para Direita
	Local nPosVerGrp 	:= nPosAltGroup/12.500 			   			//Posicao inicial do Grupo do painel da Esquerda para Direita


	/* Variaveis do objeto -> Grupo  Filtro*/
	Local oGrpFilt	   		:= Nil 									//Objeto groupbox
	/* Variaveis do objeto -> Filtro*/
	Local oLblFilt 		:= Nil             						//Objeto de Label Regra
	Local oGetFilt 		:= Nil              					//Objeto de Get Regra
	Local nNumCols 		:= 200
	Local cGetCrit   		:= SPACE(	nNumCols)								//Correspondente a regra
	Local aFilters		:= {}									//Correspondente a lista de filtros
	Local aLstOpc			:= {STR0001,STR0002,STR0003,STR0004,STR0005}			//Lista de opcoes de pesquisa"1=N˙mero da lista"#"2=Atores"#"3=Data do evento"#"4=Local do evento"#"5=Nome do organizador"}
													// numero de 						
	/* Variaveis do objeto -> Criterio*/
	Local oGrpCrit	   	:= Nil 									//Objeto groupbox
	Local oLblCrit 		:= Nil             						//Objeto de Label Regra
	Local oGetCrit		:= Nil              					//Objeto de Get Regra
	Local cGetFilt 	   	:= ""									//Correspondente a regra
	Local aFiltCmp		:= {"ME1_CODIGO","MEE_NOME","ME1_DTEVEN","ME1_LOCAL","A1_NOME"}//Campos da lista de opcao de pesquisa
							
	Local aLstFilC 		:= {} //lista dos filtros

	/*label e Combo: Criterios Utilizados */
	Local LblCrtUt 		:= NIL
	Local oLstCrtUt 		:= NIL
	Local aCrtUt 			:= {}

	/* botıes */
	Local oBtnAdic 		:= NIL //Bot„o Adicionar
	Local oBtnRemov 		:= NIL	//Bot„o Remover
	Local oBtnSearch 		:= NIL	//Bot„o Pesquisar
	/* Variaveis do objeto -> Grupo  Filtro - Final */


	/* Variaveis do objeto -> Grupo de Listas  - inicio */
	/* Objeto TGroup do Resultado da Lista */
	Local oGrpList := NIL
	//Objetos direita
	Local nAltura2 		:= (oPanelMVC2:nHeight / 4) * 0.20 		//Altura
	Local nCol2			:= (oPanelMVC2:nWidth / 4) * 0.03		 	//Coordenada horizontal
	Local nLargura2		:= (oPanelMVC2:nWidth / 4) - (2 * nCol)	//Largura
	Local nPosAltGr2		:= oPanelMVC2:nHeight /4					  	//Posicao: Altura do GroupBox
	Local nTamAltGr2		:= oPanelMVC2:nHeight/4 				//Tamanho: Altura do GroupBox
	Local nTamLarGr2		:= nTamLarGroup + 5				//Tamanho: Lagura do GroupBox
	Local nTop2 			:= POSVERT_GET1+65							//Valor do Top
	Local nLeft2 			:= 000										//Valor do Left
	Local nPosVerTit2 	:= nPosAltGr2/20.500 						//Posicao inicial do titulo do painel da Esquerda para Direita
	Local nPosVerGrp2 	:= nPosAltGr2/12.500//Posicao inicial do Grupo do painel da Esquerda para Direita

	/* Label e Grid: Lista de Eventos */
	Local oLblList		:= NIL //Label
	Local aListas 		:= {} //lista de Eventos
	Local aDados01 		:= {} //Dados de Retorno da Lista
	Local aHeader01 		:= {} //Header da Lista
	Local aAuxCombo		:= RetSx3Box( Posicione("SX3", 2, PadR("ME1_STATUS",10), "X3CBox()" ),,, 1 )	//Array contendo os status da consulta
	Local aCoorGrdL 		:= {} //Coordenadas do grid da lista
	Local aLstCmp01 		:= {} //Lista de campos do ME1
	Local aLstCmpNL		:= {"MEH_CODLIS","MEE_CODLIS"} //Campos nao Listados
//	Local oObj 			:= NIL //
	Local oSecPanel 		:= NIL	 //Segundo Panel
	Local oGrdList 		:= NIL // Grid da Lista de Eventos
	Local oBtnSel 		:= NIL //Bot„o Selecionar
	Local oBtnAtor 		:= NIL //Bot„o Atores
	Local oBtnEntr 		:= NIL //Bot„o Entregas
	Local PosVerPay2 		:= (PosVerPay + nTamLarGroup)  //Posicao Veritical
	Local lPosicionado 	:= .T. //Posicionado no Grid de Lista
	
	/* Variaveis do objeto -> Grupo de Listas  - Final */
	/* Variaveis do objeto -> Itens de Listas   - Inicial */
	Local oPnlPrd 		:= NIL //Panel de Itens
	Local oPnlGrdP 		:= NIL //Panel do Grid de Itens
	/* Objeto TGroup da dos Produtos */
	Local oGrpPrd 		:= NIL //Grupo de Produtos
	Local oGrdPrd 		:= NIl //Grid de Produtos
	/* Label e Combo: Produtos */
	Local oLblPrd			:= NIL //Label de Produtos
	Local oBtnInc 		:= NIL //Bot„o Incluir
	Local oBtnConf 		:= NIL //Bot„o confirmar
	Local oGetProd 		:= NIL //Get de Produto
	Local cGetProd 		:= ME2->(space(TamSX3("ME2_PRODUT")[1])) //Variavel do Get de Produto
	Local oLblProd 		:= NIL //Label do Produto
	Local oLblQtde 		:= NIL //Label da Quantidade
	Local oLblMet 		:= NIL //Label Metodo de Entrega
	Local oGetQtde 		:= NIL //Get Quantidade
	Local oCbxMet 		:= nil //Combo Metodo de Entrega
	Local oLblCodBar		:= Nil //Label Codigo de Barras
	Local oGetCodBar		:= Nil //Get Codigo de Barras
	Local aCbxMet 		:= {} //Array do Combo dos MÈtodos de Entrega
	Local nGetQtde 		:= 0 //Variavel Quantidade
	Local cGetCodBar 		:= Space(TamSx3("B1_CODBAR")[1]) //Variavel CÛdigo de Barras
	Local cGetMet 		:= ME1->(TamSx3("ME1_TIPO")[1]) //Variavel Metodo de Entrega
	Local cPictQtde 		:= ME2->(GetSX3Cache("ME2_QTDSOL","X3_PICTURE")) //Picture Quantidade
	Local aHeader02 		:= {} //Header do Grid de Produtos
	Local aDados02 		:= {} //Dados do Grid de Produtos
	Local aLstC02 		:= {} //Campos de Consulta do Grid
	Local aItRet 			:= {} //Itens de Lista Retornados
	Local aMsgRet 		:= {} //Mensagens Retornadas
	Local cTexto 			:= ""	//Texto 1 do Label de Entrada: 
	Local cTexto2 		:= "" //Texto 2 do Label Entrada
	Local cTexto3 		:= "" //Texto 2 do Label Entrada		

	Local bListSel := {} //bloco de Selecao da Lista de Eventos

	/* Label e Grid: Lista de Eventos  - final*/


	/* Label e Grid: Mensagens/Atores/Entregas */
	Local oGrpGen 		:= NIL	//Grupo de Atores/Entregas
	Local oLblGen 		:= NIL //Lagel de Atores/Entregas
	Local oPnlGen 		:= NIL	//Panel de Atores/Entregas
	Local oGrdGen  		:= NIL	//Grid de Atores/Entregas
	Local aHeader03 		:= {} //Objeto Lista de Mensagens/header
	Local aLstC03 		:= {}	//Lista de Campos de Mensagens
	Local aDados03 		:= {}	//Dados de Mensagens
	Local aDados04 		:= {}	//Dados de Atores/Entregas
	Local cTextoGen 		:= ""	//Texto GenÈrico
	/* Button: Selecionar*/
	Local oBtnCnc 		:= NIL	//Bot„o Cancelar
	Local cTextoBtn 		:= ""	//Texto do Bot„o	Cancelar
	Local oBtnCnf 		:= NIL //Bot„o confirmar
	Local lGrdMsgAtv := .T. //Grid de Mensagens Ativas
	Local aAreaSX3		:= SX3->(GetArea())
	/* Label e Grid: Mensagens/Atores/Entregas - Final */

	//Busca as estruturas do Grid

	STIGlEstr(aLstCmpNL, "ME1", @aHeader01, @aLstCmp01,;
				"ME1_STATUS")
				
				
	
	STIGlEstr(aLstCmpNL, "ME2", @aHeader02, @aLstC02,;
				"")  



	STIGlEstr(aLstCmpNL, "MED", @aHeader03, @aLstC03,;
				"") 

	RestArea(aAreaSX3)
		
	/* Label: Lista de Eventos */
	oLblLista := TSay():New(POSVERT_CAB, POSHOR_1, {||STR0010}, oMainPanel,,,,,,.T.,,,nLargura,13.5) //"Lista de Presentes"
	oLblLista:SetCSS( POSCSS (GetClassName(oLblLista), CSS_BREADCUMB ))

	/* Objeto TGroup da Pesquisa da Lista */
	oGrpFilt := TGroup():New(nPosAltGroup/13+5,POSHOR_1,nTamAltGroup, nTamLarGroup,'',oMainPanel,,5,.T.)
	/* Label e Combo: Regra */
	oLblFilt:= TSay():New( POSVERT_GET1*0.50, PosVerPay, {|| STR0011 }, oMainPanel,,,,,,.T.,,,nLargura,8) //"Pesquisa"
	oLblFilt:SetCSS( POSCSS (GetClassName(oLblFilt), CSS_BREADCUMB ))
	oGetFilt := TComboBox():New(POSVERT_GET1*0.70, PosVerPay, {|u| If(PCount()>0,cGetFilt:=u,cGetFilt)}, aLstOpc, (LARG_LIST_CONSULT*0.6)	 , ALTURAGET, ;
		oGrpFilt, Nil , {||cGetCrit := Space(nNumCols),oGetCrit:Picture := STIGPesPic(1,cGetFilt,aFiltCmp),oGetCrit:Refresh(),oGetFilt:SetFocus()  }/*Change*/,;
		/*Valid*/,,,.T.,,,,/*When*/,,,,,"cGetFilt")
	oGetFilt:SetCSS( POSCSS (GetClassName(oGetFilt), CSS_GET_FOCAL )) 


	/*label e Combo: Criterio*/
	oLblCrit:= TSay():New( POSVERT_GET1*0.90, PosVerPay, {|| STR0012 }, oMainPanel,,,,,,.T.,,,nLargura,8) //"CritÈrio"
	oLblCrit:SetCSS( POSCSS (GetClassName(oLblCrit), CSS_BREADCUMB ))
	oGetCrit := TGet():New(POSVERT_GET1*1.1,PosVerPay,{|u| If(PCount()>0,cGetCrit:=u,cGetCrit)},oMainPanel,;
								LARG_LIST_CONSULT*0.6,ALTURAGET,STIGPesPic(1,cGetFilt,aFiltCmp), ;
								/*valid*/,,,/*font*/,,,.T.,,,/*when*/,,,/*change*/,.F.,.F.,,"cGetCrit")
	oGetCrit:SetCSS( POSCSS (GetClassName(oGetCrit), CSS_GET_FOCAL )) 



	/*label e lista: Criterios Utilizados */
	oLblCrtUt:= TSay():New( POSVERT_GET1*1.3+1, PosVerPay, {|| STR0013 }, oMainPanel,, ,,,,.T.,,,,8) //"CritÈrios Utilizados"
	/* ListBox dos criterios */
	oLblCrtUt:SetCSS( POSCSS (GetClassName(oLblCrtUt), CSS_BREADCUMB ))
	oLstCrtUt := TListBox():Create(oMainPanel, POSVERT_GET1*1.5, PosVerPay, Nil, ;
					aCrtUt,LARG_LIST_CONSULT*0.6, ALT_LIST_CONSULT/2,,,,,.T.,, {|| } ,,,,{|| })

	oLstCrtUt:SetCSS( POSCSS (GetClassName(oLstCrtUt), CSS_LISTBOX ))
	oLstCrtUt:Reset()
	oLstCrtUt:SetArray(aCrtUt)


	/* Button: Adicionar*/
	oBtnAdic := TButton():New(POSVERT_LABEL1*0.75,nTamLarGroup - ( LARGBTN + 15) ,STR0014,oMainPanel, ; //"Adicionar"
									{|| IIf(Val(cGetFilt) = 0 .OR. !STIGLBAdd( aLstOpc[Val(cGetFilt)],aFiltCmp[Val(cGetFilt)],cGetCrit,@aLstFilC,;
																					@oLstCrtUt, nNumCols, @aCrtUt),.T.,cGetCrit := Space(nNumCols)),;
										oGetCrit:SetFocus(),oLstCrtUt:Select(Len(oLstCrtUt:aItems))}, LARGBTN,ALTURABTN,,;
									,,.T.,,;
									,,{ || Val(cGetFilt) > 0  } ) 
	oBtnAdic:SetCSS( POSCSS (GetClassName(oBtnAdic), CSS_BTN_ATIVO))

	/* Button: Remover*/
	oBtnRemov := TButton():New(POSVERT_LABEL1 * 1.50 , nTamLarGroup - ( LARGBTN + 15) ,STR0015 ,oMainPanel, ; //"Remover"
									{|| STIGLBDel(@oLstCrtUt,oLstCrtUt:nAt,@aLstFilC, @aCrtUt) }, LARGBTN,ALTURABTN,,;
									,,.T.,,;
									,,{ || Len(aCrtUt) > 0 }) 
	oBtnRemov:SetCSS( POSCSS (GetClassName(oBtnRemov), CSS_BTN_NORMAL))

	/* Button: Pesquisar*/
	oBtnSearch := TButton():New( POSVERT_LABEL1 * 2.25 ,nTamLarGroup  - ( LARGBTN + 15) ,STR0016,oMainPanel, ; //"Pesquisar"
									{|| STWGLSearch(  xFilial("ME1_FILIAL")    ,aHeader01,aLstFilC,@aDados01,;
														oSecPanel     , @oGrdList  , aMainCfg), oGetCodBar:SetFocus() }, LARGBTN,ALTURABTN,,;
										,,.T.,,;
										,,{ ||  Len(aLstFilC) > 0 })
	oBtnSearch:SetCSS( POSCSS (GetClassName(oBtnSearch), CSS_BTN_NORMAL))
	

	/* Objeto TGroup do Resultado da Lista */
	oGrpList := TGroup():New(POSVERT_GET1*1.55 + (ALT_LIST_CONSULT/2)+5,POSHOR_1 /*POSHOR_1*/,oPanelMVC:nHeight*0.5, nTamLarGroup ,'',oMainPanel,,5,.T.)

	/* Label e Combo: "Lista de Eventos Localizadas */
	oLblList:= TSay():New( POSVERT_GET1*1.55 + (ALT_LIST_CONSULT/2)+15, PosVerPay, {|| STR0017 }, oMainPanel,,,,,,.T.,,,nLargura,8) //"Lista de Eventos Localizadas
	oLblList:SetCSS( POSCSS (GetClassName(oLblList), CSS_BREADCUMB ))

	aCoorGrdL := {POSVERT_GET1*1.55 + (ALT_LIST_CONSULT/2)+30,; //Linha
					PosVerPay,; //coluna
					LARG_LIST_CONSULT*0.7,; //tamanho
					ALT_LIST_CONSULT*0.90} //altura


	oSecPanel := TPanel():New(aCoorGrdL[01],aCoorGrdL[02],"",oMainPanel,,,,,,aCoorGrdL[03],aCoorGrdL[04])	//Painel do Grid de Listas


	STIGLGrid( oSecPanel, @aDados01, aHeader01, aAuxCombo, ;
				@oGrdList, "aDados01[oBrwConten:nAt]", @aLstCmp01, @aItRet, ;
				@aMsgRet, aMainCfg, aLstC02, aLstC03, ;
				aHeader02, @aDados02, @oPnlGrdP, @oGrpPrd, ;
				@oCbxMet, @aCbxMet , @oGrpGen, @aDados03, ;
				@lGrdMsgAtv,@cTextoGen, @oLblGen,aHeader03, ;
				@oPnlGen, @cTextoBtn, @oBtnCnc, @oBtnCnf, ;
				@lPosicionado, @oBtnConf)


	/* Button: Selcionar*/
	bListSel := {||  STWGLItSearch( STDGLRtCol(2,"ME1_CODIGO",1,oGrdList:nAt,aHeader01,aDados01, .f., .f.), aDados01, aLstCmp01, @aItRet,;
		@aMsgRet, aMainCfg, aLstC02, aLstC03, ;
		aHeader02, @aDados02, @oPnlGrdP, @oGrpPrd,;
		@oCbxMet, @aCbxMet , @oGrpGen, @aDados03,;
		oGrdList:nAt, @lGrdMsgAtv, @cTextoGen, @oLblGen,;
		aHeader03, aAuxCombo, @oPnlGen, @cTextoBtn, ;
		@oBtnCnc, @oBtnCnf, @lPosicionado, @oBtnConf)  }
	oBtnSel := TButton():New(aCoorGrdL[01] ,nTamLarGroup - ( LARGBTN + 15) ,STR0018 ,oMainPanel, ; //"Selecionar"
		bListSel, LARGBTN,ALTURABTN,,;
		,,.T.,,;
		,,{ || CONOUT(CVALTOCHAR(LEN(ADADOS01))),  Len(aDados01) > 0 } ) //"Adicionar"
	oBtnSel:SetCSS( POSCSS (GetClassName(oBtnSel), CSS_BTN_ATIVO))

	/* Button: Atores*/
	oBtnAtor := TButton():New(aCoorGrdL[01] +  ALTURABTN + 5, nTamLarGroup - ( LARGBTN + 15) ,STR0019,oMainPanel, ; //"Atores"
									{|| STWGLAtEnt( @lGrdMsgAtv, 2, STDGLRtCol(2,"ME1_CODIGO",1,oGrdList:nAt,aHeader01,aDados01, .f., .f.),STDGLRtCol(2,"ME1_TIPO",1,oGrdList:nAt,aHeader01,aDados01, .f., .f.), ;
													oPnlGen, @aDados04, @oGrpGen, @cTextoGen,;
													@oLblGen, @cTextoBtn, @oBtnCnc, @oBtnCnf)  }, LARGBTN,ALTURABTN,,;
									,,.T.,,;
									,, {|| Len(aDados01) > 0  } )
	oBtnAtor:SetCSS( POSCSS (GetClassName(oBtnAtor), CSS_BTN_NORMAL))

	/* Button: Entrega*/
	oBtnEntr := TButton():New(aCoorGrdL[01] +  (ALTURABTN + 5)*2 ,nTamLarGroup  - ( LARGBTN + 15) ,STR0020,oMainPanel, ; //"Entrega"
		{|| STWGLAtEnt( @lGrdMsgAtv, 1, STDGLRtCol(2,"ME1_CODIGO",1,oGrdList:nAt,aHeader01,aDados01, .f., .f.),STDGLRtCol(2,"ME1_TIPO",1,oGrdList:nAt,aHeader01,aDados01, .f., .t.), ;
						oPnlGen, @aDados04, @oGrpGen, @cTextoGen,;
						@oLblGen, @cTextoBtn, @oBtnCnc, @oBtnCnf )}, LARGBTN,ALTURABTN,,;
						,,.T.,,;
						,, {|| Len(aDados01) > 0  } )
	oBtnEntr:SetCSS( POSCSS (GetClassName(oBtnEntr), CSS_BTN_NORMAL))


	//Lado Direito
	/* Panel de Group - Produtos */
	oPnlRight = TPanel():New(00, 00,"",oPanelMVC2,,,,,,oPanelMVC2:nWidth/2,(oPanelMVC2:nHeight)/2)

	/* Objeto TGroup da dos Produtos */
	oGrpProd := TGroup():New(nPosAltGroup/13+5,POSHOR_1,(oPnlRight:nHeight/2)*0.55 + 13, (oPnlRight:nWidth/2)*0.98,'',oPnlRight,,5,.T.)

 
	/* Label e Combo: Produtos */

	oLblPrd:= TSay():New( POSVERT_GET1*0.40, PosVerPay, {|| STR0021 }, oPnlRight,,,,,,.T.,,,nLargura,8) //"Produtos"
	oLblPrd:SetCSS( POSCSS (GetClassName(oLblPrd), CSS_BREADCUMB ))


	/*Panel do Grid de Produtos*/
	oPnlGrdP := TPanel():New(POSVERT_GET1*0.55,PosVerPay-10,"",oPnlRight,,,,,,(oPnlRight:nWidth/2)*0.9,((oPnlRight:nHeight/2)*0.55)*0.6 )	//Painel de Produtos
		
		
	/*Controles Produtos/Quantidade/MÈtodo de Entrega
	//Produtos*/	
	/*CÛdigo de Barras*/
	oLblCodBar:= TSay():New( POSVERT_GET1*2.5 - 13, PosVerPay, {||STR0030}, oPnlRight,,,,,,.T.,,,nLargura,8) //"CÛdigo de Barras"
	oLblCodBar:SetCSS( POSCSS (GetClassName(oLblCodBar), CSS_BREADCUMB  ))	
	oGetCodBar := TGet():New(POSVERT_GET1*2.5,(PosVerPay)-1,{|u| If(PCount()>0,cGetCodBar:=u,cGetCodBar)},oPnlRight,;
								LARG_GET_VALOR * 2,ALTURAGET,"@!",{ || .T. } ,;
								,,,,,.T.,,,{|| },,,,.f.,,,"cGetCodBar")
	oGetCodBar:SetCSS( POSCSS (GetClassName(oGetCodBar), CSS_GET_FOCAL ))	
	oGetCodBar:lVisible := aMainCfg[POS_MAME]
	oGetCodBar:Refresh()
	
	/*Perda de foco do campo Codigo de Barras*/		
	oGetCodBar:bLostFocus := {|| STDSearCodBar(@cGetCodBar, @cGetProd, oGrpPrd, oGetCodBar)}

	If !aMainCfg[POS_MLAQTD]
		cTexto := STR0022
	Else
		cTexto := ""
	EndIf
	oLblProd:= TSay():New( POSVERT_GET1*2.5 + 18, PosVerPay, {||cTexto }, oPnlRight,,,,,,.T.,,,nLargura,8)
	oLblProd:SetCSS( POSCSS (GetClassName(oLblProd), CSS_BREADCUMB  ))
	
 	@ POSVERT_GET1*2.75 + 15,PosVerPay MSGET oGetProd VAR cGetProd F3 "SB1" SIZE LARG_GET_VALOR, ALTURAGET OF oPnlRight PIXEL HASBUTTON			
	oGetProd:SetCSS( POSCSS (GetClassName(oGetProd), CSS_GET_FOCAL ))
	oGetProd:lVisible := .F.
	oGetProd:Refresh()

	/*Quantidade*/
	If aMainCfg[POS_MLAQTD]
		cTexto3 := STR0023 //"Quantidade"
	EndIf
	oLblProd:Refresh()
	oLblQtde := TSay():New( POSVERT_GET1*2.5 + 18, PosVerPay + LARG_GET_VALOR + 7, {||cTexto3 }, oPnlRight,,,,,,.T.,,,nLargura,8)
	oLblQtde:SetCSS( POSCSS (GetClassName(oLblQtde), CSS_BREADCUMB  ))
	
	oGetQtde := TGet():New((POSVERT_GET1*2.75) + 15,(PosVerPay)-1 + LARG_GET_VALOR + 7,{|u| If(PCount()>0,nGetQtde:=u,nGetQtde)},oPnlRight,;
								LARG_GET_VALOR,ALTURAGET,cPictQtde,{ || .t. } ,;
								,,,,,.T.,,,{|| },,,,.f.,,,"nGetQtde")
	oGetQtde:SetCSS( POSCSS (GetClassName(oGetQtde), CSS_GET_FOCAL ))
	oGetQtde:lVisible := .T.
	oGetQtde:Refresh()
		
	/*MÈtodo de Entrega*/
	If aMainCfg[POS_MAME]
		cTexto2 := STR0020 // "Entrega"
	EndIf
	oLblMet:= TSay():New( (POSVERT_GET1*2.6) + 17, (PosVerPay) + LARG_GET_VALOR*2 + 17, {||cTexto2 }, oPnlRight,,,,,,.T.,,,nLargura,8)
	oLblMet:SetCSS( POSCSS (GetClassName(oLblMet), CSS_BREADCUMB  ))


	oCbxMet := TComboBox():New((POSVERT_GET1*2.8) + 17, (PosVerPay-1) + LARG_GET_VALOR*2 + 17 , {|u| If(PCount()>0,cGetMet:=u,cGetMet)}, aCbxMet,;
									 LARG_GET_VALOR	 , ALTURAGET+4, oPnlRight, Nil , ;
									 {|| }/*Change*/,/*Valid*/,,,.T.,,,,/*When*/,,,,,"cGetMet")
	oCbxMet:SetCSS( POSCSS (GetClassName(oCbxMet), CSS_GET_FOCAL )) 
	oCbxMet:lVisible := aMainCfg[POS_MAME]
	oCbxMet:Refresh() 

	/*Attiva os controles Quantidade e MÈtodo de Entrega*/
	If (!aMainCfg[POS_MLAQTD] .AND. !aMainCfg[POS_MAME])
		STIGLAtvCrtl(1, @cTexto,@oLblProd, @cTexto2, @cTexto3,;
						@oLblMet,@oGetProd, @oGetQtde,@oCbxMet  )
	EndIf


	/*Monta o Grid de Produtos*/
	STIGLGdIt( oPnlGrdP, @aDados02, aHeader02,@oGrpPrd, ;
				"aDados02[oBrwConten2:nAt]" , @cTexto,@oLblProd, @cTexto2, @cTexto3,;
				@oLblMet,@oGetProd, @oGetQtde, @oCbxMet, ;
				@nGetQtde, @cGetMet, @lGrdMsgAtv, @aCbxMet  ) 


	/* Button: Confirmar  Quantidade/Inclusao de Produto */
	oBtnConf := TButton():New(POSVERT_GET1*2.1 + 15 ,  (PosVerPay) + LARG_GET_VALOR*2 + 10 , STR0024,oPnlRight, ; //"Confirmar"
		{|| STBGLConf(oGetQtde,nGetQtde,oCbxMet, cGetMet,;
						oGetProd,  cGetProd  , @aItRet,@aDados02, ;
						aHeader02, @oGrpPrd, aDados03, aHeader03,;
						STDGLRtCol(2,"ME1_CODIGO",1,oGrdList:nAt,aHeader01,aDados01, .f., .f.), STDGLRtCol(2,"ME1_EXTRA",1,oGrdList:nAt,aHeader01,aDados01,.F.,.T.), aCbxMet, lGrdMsgAtv,;
						aMainCFG, .T., cGetCodBar ) }, LARGBTN*0.6,ALTURABTN,,;
						,,.T., ,,;
						,,{ || .T.  })
	oBtnConf:SetCSS( POSCSS (GetClassName(oBtnConf), CSS_BTN_ATIVO))



	/* Button: Incluir*/
	oBtnInc := TButton():New(POSVERT_GET1*2.1 + 15, (PosVerPay) + LARG_GET_VALOR*2 + LARGBTN*0.6 + 15  ,STR0025,oPnlRight, ; //"Incluir"
								{|| STIGLAtvCrtl(1, @cTexto,@oLblProd, @cTexto2, @cTexto3,;
								@oLblMet,@oGetProd, @oGetQtde,@oCbxMet  )  }, ;
								LARGBTN*0.6,ALTURABTN,,,,.T.) //"Adicionar"
	oBtnInc:SetCSS( POSCSS (GetClassName(oBtnInc), CSS_BTN_NORMAL))


	/*Grupo de Mensagens/Atores/Entregas
	/* Objeto TGroup da dos Produtos */
	oGrpGen := TGroup():New(  ((oPnlRight:nHeight/2)*0.55)+17,POSHOR_1,(oPnlRight:nHeight/2)*0.98, (oPnlRight:nWidth/2)*0.98,'',oPnlRight,,5,.T.)
	cTextoGen := STR0026 //"Mensagens"
	oLblGen= TSay():New( ((oPnlRight:nHeight/2)*0.55)+20, PosVerPay, {||cTextoGen}, oPnlRight,,,,,,.T.,,,nLargura,8)
	oLblGen:SetCSS( POSCSS (GetClassName(oLblGen), CSS_BREADCUMB  ))

	/* 	Panel para o Grid  de Mensagens/Atores/Entregas */
	oPnlGen := TPanel():New( ((oPnlRight:nHeight/2)*0.55)+30,PosVerPay,"",oPnlRight,,,,,,LARG_LIST_CONSULT*0.7,((oPnlRight:nHeight/2)*0.45)*0.8)


	/*Grid de Mensagens/Atores/Entregas*/
	STIGLGdGe( oPnlGen, @aDados03, aHeader03, aAuxCombo, ;
				@oGrpGen,"aDados03[oBrwConten3:nAt]", .t.)

	/* Button: Cancelar*/
	cTextoBtn := STR0027 //"Cancelar" 
	
	oBtnCnc := TButton():New( ((oPnlRight:nHeight/2)*0.55)+30 ,((oPnlRight:nWidth/2)*0.98) - ( LARGBTN + 15) ,cTextoBtn,oPnlRight, ;
								{|| STIGLBtCan(@lGrdMsgAtv, @oPnlGen, @aDados03, aHeader03, ;
												aAuxCombo, @oGrpGen,@cTextoGen, @oLblGen, ;
												@cTextoBtn, @oBtnCnc, @oBtnCnf) }, LARGBTN,ALTURABTN,,,,.T.) //Cancelar
	oBtnCnc:SetCSS( POSCSS (GetClassName(oBtnCnc), CSS_BTN_ATIVO))

	/* Button: Filizar*/
	oBtnCnf := TButton():New((( (oPnlRight:nHeight/2)*0.55)+30) +  ALTURABTN*2 + 5, ((oPnlRight:nWidth/2)*0.98) - ( LARGBTN + 15) ,STR0028 ,oPnlRight, ; //"Finalizar"
								{||STWGLBtCnf(@aItRet) , aMainCFG := nil }, LARGBTN,ALTURABTN,,,,.T.) 
	oBtnCnf:SetCSS( POSCSS (GetClassName(oBtnCnf), CSS_BTN_FOCAL))


Return(oMainPanel)




//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIGLGrid
CriaÁ„o do grid das Listas de Presentes
@param		o		   		- Panel Principal
@param		aDados01	- Dados da Lista
@param		aHeader01 - Header da Lista
@param		aAuxCombo - Combo de Status da Lista
@param		oBrwConten - Browse
@param		cCampo - Campo do Grid
@param		aLstCmp01 - Lista de Campos da Tabela
@param		aItRet -  Item de Retorno a Lista de Presentes
@param		aMsgRet - Mensagens da Lista
@param		aMainCfg - ConfiguraÁıes da Lista 
@param		aLstC02 - Lista de Campos - Itens da Lista
@param		aLstC03 - Lista de Campos -  Mensagens
@param		aHeader02 - Header dos Itens da Lista
@param		aDados02 - Dados da Lista
@param		oPnlGrdP - Panel do Grid de itens da Lista
@param		oGrpPrd - Panel do Grid de Produtos
@param		oCbxMet - Combo de MÈtodos de Entrega
@param		aCbxMet - Array de MÈtodos de Entrega
@param		oGrpGen - Grupo de Atores/Entregas/mensagens
@param		aDados03 - Dados das Mensagens
@param		lGrdMsgAtv - Grid de Mensagem Ativa
@param		cTextoGen - Texto GenÈrico
@param		oLblGen - Label GenÈrico
@param		aHeader03 - Header de Mesagens
@param		oPnlGen - Panel GenÈrico
@param		cTextoBtn - Texto do Bot„o cancelart
@param		oBtnCnc - Bot„o cancelar
@param		oBtnCnf - Bot„o Finalizar
@param		lPosicionado - Posicionado no Grid de Lista
@param		oBtnConf - Bot„o Confirmar 
@author  	Varejo
@version 	P12
@since   	17/12/14
@return	oBrwConten - Browse
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Static Function STIGLGrid( 	o,aDados01,aHeader01, aAuxCombo, ;
						oBrwConten, cCampo, aLstCmp01,aItRet, ;
						aMsgRet, aMainCfg, aLstC02, aLstC03, ;
						aHeader02, aDados02, oPnlGrdP, oGrpPrd, ;
						oCbxMet, aCbxMet , oGrpGen, aDados03, ;
						lGrdMsgAtv,cTextoGen, oLblGen,aHeader03, ;
						oPnlGen, cTextoBtn, oBtnCnc, oBtnCnf,;
						lPosicionado, oBtnConf) 


	Local oGetCrtUt		:= NIL							//Conteudo do css
	Local oColumn			:= Nil							//Objeto do Grid
	Local cPicTotal		:= PesqPict("SL1","L1_VLRTOT") 	//Picture do L1_VLRTOT
	Local nX				:= 0							//Variavel de Laco
	Local aLegenda 		:= {}							//Legenda do Grid
	Local aCores 			:= {}							//Cores do Grid
	Local nI 				:= 0							//Contador 2
	Local nPosStatus 		:= aScan(aHeader01, { |h| h[1] == "ME1_STATUS"}) //Campo de Status
	Local cTmp				:= ""							//Temporario - Campo
	Local cTmp2 			:= ""							//Temporario - TÌtulo
	Local bListSel :=  {|| STWGLItSearch( STDGLRtCol(2,"ME1_CODIGO",1,oBrwConten:nAt,aHeader01,aDados01, .f., .f.), aDados01, aLstCmp01, @aItRet,;
							@aMsgRet, aMainCfg, aLstC02, aLstC03, ;
							aHeader02, @aDados02, @oPnlGrdP, @oGrpPrd,;
							@oCbxMet, @aCbxMet , @oGrpGen, @aDados03,;
							oBrwConten:nAt, @lGrdMsgAtv, @cTextoGen, @oLblGen,;
							aHeader03, aAuxCombo, @oPnlGen, @cTextoBtn, ;
							@oBtnCnc, @oBtnCnf, @lPosicionado)  } //Bot„o de SeleÁ„o

	Default cCampo := "aDados01[oBrwConten:nAt]"


	If Len(aAuxCombo) > 0
		aAdd(aLegenda,{"ENABLE"		,aAuxCombo[1][3]})	//Credito Liberado
		aAdd(aLegenda,{"DISABLE"	,aAuxCombo[2][3]})	//Debito
	
		//Adiciono as regras de cores no array a Cores
		aAdd(aCores,{{"ME1_STATUS", 'ME1_STATUS == "' + Alltrim(aAuxCombo[1,3]) + '"'},aLegenda[1][1]})
		aAdd(aCores,{{"ME1_STATUS", 'ME1_STATUS == "' + Alltrim(aAuxCombo[2,3]) + '"'},aLegenda[2][1]})
	EndIf

	For nX := 1 To Len(aDados01)

		For nI := 1 to Len(aHeader01)


			cTmp := aHeader01[nI][2]
			If !Empty(cTmp)
				Do Case
				Case aHeader01[nI][5] == "N"
					aDados01[nX, nI] :=  AllTrim(Transform(aDados01[nX, nI], cTmp))
				Otherwise
					aDados01[nX, nI] := Transform(aDados01[nX, nI], cTmp)
				EndCase
			Endif



		Next nI

	Next nX

	oGetCrtUt := POSBrwContainer(o)

	cTmp := ""


	DEFINE FWBROWSE oBrwConten DATA ARRAY ARRAY aDados01 CHANGE { || lPosicionado := .F., IIf(ValType(oBtnConf) == "O", oBtnConf:Refresh(), ) }  NO LOCATE  NO CONFIG NO REPORT OF oGetCrtUt
	
	
	oBrwConten:nRowHeight := 25
	oBrwConten:SetVScroll(.T.)
	oBrwConten:SetDoubleClick(bListSel)
	
	For nI := 1 to Len(aHeader01)
		If nI <> nPosStatus
			//Campo
			cTmp := &("{|| " + cCampo + "[" + AllTrim(Str(nI)) + "] }")
			cTmp2 := &("'"+AllTrim(aHeader01[nI, 03]) +"'")
			ADD COLUMN oColumn DATA cTmp	TITLE cTmp2	SIZE 008 OF oBrwConten 
		Else
			//Legenda
			cTmp := &("{ || IIf( " + cCampo +" [" + AllTrim(Str(nI)) + "] == '" + Alltrim(aAuxCombo[1,3]) + "','"+ aLegenda[1][1]+"','"+aLegenda[2][1] + "') }")
			ADD STATUSCOLUMN oColumn DATA cTmp DOUBLECLICK { || .T.  } OF oBrwConten
		
		EndIf
	Next nI

	ACTIVATE FWBROWSE oBrwConten

Return oBrwConten


//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIGLGdIt
CriaÁ„o do grid dos itens das Listas de Presentes
@param		o		   		- Panel Principal
@param		aDados02	- Dados dos itens da Lista
@param		aHeader02 - Header dos itens Lista
@param		oBrwConten2 - Browse
@param		cCampo - Campo do Grid
@param		cTexto - Texto 1 - Quantidade /Produto
@param		oLblProd - Label do Texto Produto
@param		cTexto2 - Texto 2 - MÈtodo de Entrega
@param		cTexto3 - Texto 3 - Quantidade
@param		oLblMet - Label do MÈtodo de Entrega
@param		oGetProd - Objeto Get de Produto
@param		oGetQtde - Objeto Get de Quantidade
@param		oCbxMet - Objeto Combo de MÈtodo de Entrega
@param		nGetQtde - Objeto Quantidade
@param		cGetMetMet - Variavel MÈtodo de Entrega
@param		lGrdMsgAtv - Grid de Mensagem Ativa
@param		aCbxMet  - Arry de MÈtodos de Entrega
@author  	Varejo
@version 	P12
@since   	17/12/14
@return	oBrwConten2 - Browse
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Static Function STIGLGdIt( o,aDados02,aHeader02, oBrwConten2, ;
							cCampo, cTexto,oLblProd, cTexto2, cTexto3, ;
							oLblMet,oGetProd, oGetQtde, oCbxMet, ;
							nGetQtde, cGetMetMet, lGrdMsgAtv, aCbxMet)

	Local oGetCrtUt	:= NIL						//Conteudo
	Local oColumn		:= Nil						//Objeto do Grid
	Local nX			:= 0						//Variavel de Laco
	Local nI 			:= 0						//Variaval do LaÁo
	Local cTmp			:= ""						//Tempor·rio Coluna
	Local cTmp2 		:= ""						//Tempor·rio TÌtulo
	Local bDblClick 	:= { ||  STIGLAtvCrtl(2, @cTexto,@oLblProd, @cTexto2, @cTexto3, ;
												@oLblMet,@oGetProd, @oGetQtde, @oCbxMet  ), ;
												STIGPrdCg( @nGetQtde, oBrwConten2, aHeader02,aDados02, ;
												@cGetMetMet, @oGetQtde, @oCbxMet ),;
												lGrdMsgAtv := .T. } //Duplo Click do Browse
	Local bChange 	:= { || STIGPrdCg( @nGetQtde, oBrwConten2, aHeader02,aDados02, ;
												@cGetMetMet, @oGetQtde, @oCbxMet ) } //Change do Browse


	Default cCampo := "aDados02[oBrwConten2:nAt]"

	For nX := 1 To Len(aDados02)

		For nI := 1 to Len(aHeader02)


			cTmp := aHeader02[nI][2]
			If !Empty(cTmp)
				Do Case
				Case aHeader02[nI][5] == "N"
					aDados02[nX, nI] :=  AllTrim(Transform(aDados02[nX, nI], cTmp))
				Otherwise
					aDados02[nX, nI] := Transform(aDados02[nX, nI], cTmp)
				EndCase
			Endif



		Next nI

	Next nX

	oGetCrtUt := POSBrwContainer(o)

	cTmp := ""


	DEFINE FWBROWSE oBrwConten2 DATA ARRAY ARRAY aDados02 CHANGE bChange DOUBLECLICK bDblClick  NO LOCATE  NO CONFIG NO REPORT OF oGetCrtUt
	
	oBrwConten2:nRowHeight := 25
	oBrwConten2:SetVScroll(.T.)
	For nI := 1 to Len(aHeader02)
		cTmp := &("{|| " + cCampo + "[" + AllTrim(Str(nI)) + "] }")
		cTmp2 := &("'"+AllTrim(aHeader02[nI, 03]) +"'")
		ADD COLUMN oColumn DATA cTmp	TITLE cTmp2	SIZE 008 OF oBrwConten2 //"Tipo"
	Next nI

	ACTIVATE FWBROWSE oBrwConten2

Return oBrwConten2



//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIGLGdGe
CriaÁ„o do grid de Mensagens
@param		o		   		- Panel Principal
@param		aDados03	- Dados do Grid
@param		aHeader03 - Header Grid
@param     aAuxCombo - Array de Legenda
@param		oBrwConten3 - Browse
@param		cCampo - Campo do Grid
@param		lCriaCont -Cria o Container?
@author  	Varejo
@version 	P12
@since   	17/12/14
@return	oBrwConten3 - Browse
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Function STIGLGdGe( o,aDados03,aHeader03, aAuxCombo, ;
					oBrwConten3, cCampo, lCriaCont)


	Local oColumn		:= Nil							//Objeto do Grid
	Local nX			:= 0							//Variavel de Laco
	Local aLegenda 	:= {}							//Legenda
	Local aCores	 	:= {}							//Cores da Legenda
	Local nI 			:= 0							//Variavel de LaÁo
	Local nPosStatus := 0							//Posicao do campo Legenda
	Local cTmp			:= ""							//Tempor·rio Campo
	Local cTmp2		:= ""							//Tempor·rio TÌtulo
	Local bDblClick 	:= { || .T. }					//Duplo Clique
	Local cArray 		:=  ""							//Vari·vel do Campo do Grid



	Default cCampo := "aDados03[oBrwConten3:nAt]"
	Default lCriaCont := .F.
	
	cArray := Left(cCampo, At("[", cCampo) -1)
	
	If cArray == "aDados03"
		bDblClick := { ||  STIGlAltSt( @aDados03, oBrwConten3:nAt, nPosStatus, @oBrwConten3, ;
											aHeader03) }	
		nPosStatus := aScan(aHeader03, { |h| h[1] == "SEL"})
	EndIf

	//Incrementa o array de Legenda com os status disponiveis
	If Len(aAuxCombo) > 0
		aAdd(aLegenda,{"ENABLE"		,aAuxCombo[1][3]})	//Credito Liberado
		aAdd(aLegenda,{"DISABLE"	,aAuxCombo[2][3]})	//Debito
	
		//Adiciono as regras de cores no array a Cores
		aAdd(aCores,{{"SEL", 'SEL"' + Alltrim(aAuxCombo[1,3]) + '"'},aLegenda[1][1]})
		aAdd(aCores,{{"SEL", 'SEL"' + Alltrim(aAuxCombo[2,3]) + '"'},aLegenda[2][1]})
	EndIf

	For nX := 1 To Len(aDados03)

		For nI := 1 to Len(aHeader03)


			cTmp := aHeader03[nI][2]
			If !Empty(cTmp)
				Do Case
				Case aHeader03[nI][5] == "N"
					aDados03[nX, nI] := AllTrim(Transform(aDados03[nX, nI], cTmp))
				Otherwise
					aDados03[nX, nI] := Transform(aDados03[nX, nI], cTmp)
				EndCase
			Endif



		Next nI

	Next nX

	If lCriaCont
		oGetContGen := POSBrwContainer(o)
	Else
		If ValType(oBrwConten3) == "O"
			oBrwConten3:DeActivate(.t.)
		EndIf
	EndIf

	cTmp := ""

	DEFINE FWBROWSE oBrwConten3 DATA ARRAY ARRAY aDados03 DOUBLECLICK bDblClick   NO LOCATE  NO CONFIG NO REPORT OF oGetContGen
	
	oBrwConten3:nRowHeight := 25
	oBrwConten3:SetVScroll(.T.)
	For nI := 1 to Len(aHeader03)
		If nI <> nPosStatus
			cTmp := &("{|| " + cCampo + "[" + AllTrim(Str(nI)) + "] }")
			cTmp2 := &("'"+AllTrim(aHeader03[nI, 03]) +"'")
			ADD COLUMN oColumn DATA cTmp	TITLE cTmp2	SIZE 008 OF oBrwConten3 //"Tipo"
		Else
			cTmp := &("{ || IIf( " + cCampo +" [" + AllTrim(Str(nI)) + "] == '1','"+ aLegenda[1][1]+"','"+aLegenda[2][1] + "') }")

			ADD STATUSCOLUMN oColumn DATA cTmp DOUBLECLICK { || .T.  } OF oBrwConten3
		
		EndIf
	Next 

	ACTIVATE FWBROWSE oBrwConten3

Return oBrwConten3




//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIGLGd2Gen
CriaÁ„o do grid de Atores/Entregas
@param		o		   		- Panel Principal
@param		aDados04	- Dados do Grid
@param		aHeader04 - Header Grid
@param		oBrwConten3 - Browse
@param		cCampo - Campo do Grid
@param		lCriaCont -Cria o Container?
@author  	Varejo
@version 	P12
@since   	17/12/14
@return	oBrwConten3 - Browse
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

Function STIGLGd2Gen( o,aDados04,aHeader04, oBrwConten3, cCampo, lCriaCont)


	Local oColumn		:= Nil							//Objeto do Grid
	Local nX			:= 0							//Variavel de Laco
	Local nI 			:= 0							//Variavel de LaÁo	
	Local cTmp			:= ""							//Temporario Campo	
	Local cTmp2 		:= ""							//Temporario Header
	Local aTitulos 	:= {}
	Local cArray 		:=  ""


	//Incrementa o array de Legenda com os status disponiveis
	Default cCampo := "aDados04[oBrwConten3:nAt]"
	Default lCriaCont := .F.
	
	cArray := Left(cCampo, At("[", cCampo) -1)


	For nX := 1 To Len(aDados04)

		For nI := 1 to Len(aHeader04)


			cTmp := aHeader04[nI][2]
			If !Empty(cTmp)
				Do Case
				Case aHeader04[nI][5] == "N"
					aDados04[nX, nI] := AllTrim(Transform(aDados04[nX, nI], cTmp))
				Otherwise
					aDados04[nX, nI] := Transform(aDados04[nX, nI], cTmp)
				EndCase
			Endif



		Next nI

	Next nX

	If lCriaCont
		oGetContGen := POSBrwContainer(o)
	Else
		If ValType(oBrwConten3) == "O"
			oBrwConten3:DeActivate(.t.)
		EndIf
	EndIf

	cTmp := ""

	DEFINE FWBROWSE oBrwConten3 DATA ARRAY ARRAY aDados04  NO LOCATE  NO CONFIG NO REPORT OF oGetContGen
	
	oBrwConten3:nRowHeight := 25
	oBrwConten3:SetVScroll(.T.)
	For nI := 1 to Len(aHeader04)
			cTmp := &("{|| " + cCampo + "[" + AllTrim(Str(nI)) + "] }")
			cTmp2 := &("'"+AllTrim(aHeader04[nI, 03]) +"'")
			ADD COLUMN oColumn DATA cTmp	TITLE cTmp2	SIZE 008 OF oBrwConten3 //"Tipo"
	Next nI

	ACTIVATE FWBROWSE oBrwConten3

Return oBrwConten3



//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIGPesPic
Funcao para retornar mascara de formatacao e incializacao de campos de acordo com o seu tipo de dados
@param		nModo - Modo operacao 1. Picture 2. Inicializacao
@param		nOpcFiltro	- Posicao da combo de tipos de filtros  
@param		aLstOpcFieldC - Dados da lista de filtros 
@author  	Varejo
@version 	P12
@since   	17/12/14
@return	cPict - Picture
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Static Function STIGPesPic(nModo,nOpcFiltro,aLstOpcFieldC)

	Local cPict            	:= "" 						// mascara do campo
	Local cBaseHex			:= "A"						// base hexadec
	Local cTipo				:= ""						// tipo campo

	Default nModo				:= 1						// modo de manipulacao
	Default nOpcFiltro		:= 0						// opcao de filtro
	Default aLstOpcFieldC	:= {}						// array com campos lista

	Do Case
	Case nModo == 1
		cPict := "@!"
	Otherwise
		cPict := Space(250)
	EndCase
	If Empty(nOpcFiltro) .OR. ValType(aLstOpcFieldC) == "U" .OR. Len(aLstOpcFieldC) == 0
		Return cPict
	Endif
	
	//Tratamento da posicao passada
	nOpcFiltro := AllToChar(nOpcFiltro)
	If IsAlpha(nOpcFiltro)
		nOpcFiltro := Upper(nOpcFiltro)
		nOpcFiltro := Asc(cBaseHex) - (Asc(nOpcFiltro) - Asc(cBaseHex))
	Else
		nOpcFiltro := Val(nOpcFiltro)
	Endif
	If nOpcFiltro > Len(aLstOpcFieldC)
		Return cPict
	Endif
	Do Case
	Case nModo == 1
		If Empty(cPict := GetSX3Cache(aLstOpcFieldC[nOpcFiltro],"X3_PICTURE"))
			cPict := "@!"
		Endif
	Otherwise
		cTipo := GetSX3Cache(aLstOpcFieldC[nOpcFiltro],"X3_TIPO")
		Do Case
		Case cTipo == "D"
			cPict := CtoD("")
		Case cTipo == "N"
			cPict := 0
		Otherwise
			cPict := Space(250)
		EndCase
	EndCase

Return cPict



//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIGLBAdd
Funcao para adicionar o CritÈrio de Busca na Lista 
@param		cFieldC - Campo
@param		cFieldP - Nome do Campo 
@param		cFiltro - Filtro
@param		aLstFilC - Array de Lista
@param		nNumCols - Numero de Colunas da Lista
@param		aCrtUt - Array da ListBox
@author  	Varejo
@version 	P12
@since   	17/12/14
@return	lRet - Sucesso
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Static Function STIGLBAdd( cFieldC,cFieldP,cFiltro,aLstFilC,;
							oGetCrtUt, nNumCols, aCrtUt)

	Local lRet			:= .T.					//Variavel de retorno
	Local cCriterio	:= ""					//criterio de manipulacao
	Local ni			:= 0					//contagem do FOR

	Default cFieldC		:= ""					//campos
	Default cFieldP		:= ""					//campos
	Default cFiltro		:= ""					//filtro
	Default aLstFilC	:= {}					//array lista
	Default oGetCrtUt		:= NILL					//objeto da lista
	Default nNumCols := 200
						                                     
	If Empty(cFieldC) .OR. Empty(cFieldP) .OR. Empty(cFiltro) .OR. ValType(aLstFilC) # "A" .OR. ValType(oGetCrtUt) # "O"
		Return !lRet
	Endif

	//Adicionar ao array de controle
	If Empty(cCriterio := STBGLQyCr(cFieldP,,cFiltro))
		Return !lRet
	Endif
	For ni := 1 to Len(aLstFilC)
		If PadR(Upper(RTrim(aLstFilC[ni][3])),nNumCols) == PadR(Upper(RTrim(cCriterio)),nNumCols)
			STFMessage("STIGLBAdd", "STOP",STR0029) //"Este critÈrio j· foi utilizado!" 
			STFShowMessage("STIGLBAdd")
			Return !lRet
		Endif
	Next ni
	//Adicionar item ao listbox
	aAdd(aCrtUt,Substr(cFieldC,3,Len(cFieldC)) + " = " + cFiltro)
	oGetCrtUt:SetArray(aCrtUt)
	
	//Atualizar a lista de filtros
	aAdd(aLstFilC,{GetSX3Cache(cFieldP,"X3_ARQUIVO"),;	//Alias
	cFieldP,;								//Nome do campo
	cCriterio,;							//Criterio de pesquisa
	Len(oGetCrtUt:aItems)})				//Posicao na lista de pesquisa

Return lRet


//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIGLBDel
Funcao para Excluir o CritÈrio de Busca na Lista 
@param		oList - Objeto ListBox
@param		nPos - Item de Lista 
@param		aLstFilC - Array de Lista
@param		aCrtUt - Array da ListBox
@author  	Varejo
@version 	P12
@since   	17/12/14
@return	lRet - Sucesso
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Static Function STIGLBDel(oList,nPos,aLstFilC, aCrtUt)

	Local lRet			:= .T.				 //variavel de retorn
	Local lAtLista	:= .T.              //alteracao na lista
	Local ni			:= 0                //contagem do for
	Local nPos02		:= 0                //posicao do campo

	Default nPos		:= 0				//posicao do campo
	Default aLstFilC	:= {}              //array de lista
	Default oList		:= NIL            //objeto da lista

	If Empty(nPos) .OR. ValType(aLstFilC) # "A" .OR. Len(aLstFilC) == 0
		Return !lRet
	Endif
	If oList == Nil
		lAtLista := !lAtLista
	Endif
	//Remover item da lista de filtros
	If nPos > Len(aLstFilC)
		Return !lRet
	Endif
	If (nPos02 := aScan(aLstFilC,{|x| aTail(x) == nPos})) > 0
		aDel(aLstFilC,nPos02)
		aSize(aLstFilC,Len(aLstFilC) - 1)
	Else
		Return !lRet
	Endif
	//Reordenar posicao da lista
	If Len(aLstFilC) > 0
		For ni := 1 to Len(aLstFilC)
			If aTail(aLstFilC[ni]) > nPos
				aTail(aLstFilC[ni])--
			Endif
		Next ni
	Endif
	//Atualizar lista
	If lAtLista
		If nPos > 0
			
			aDel(aCrtUt, nPos)
			aSize(aCrtUt, Len(aCrtUt)-1)
			oList:SetArray(aCrtUt)
			//Reposicionar
			If oList:Len() > 1
				oList:nAt := 1
				oList:Select(1)
			Endif
		EndIf
	Endif

Return lRet

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIGLAtvCrtl
Funcao para Ativar o Campos para EdiÁ„o do Grid de Itens de Lista
@param		nOpc  - OpÁ„o 1 - InclusÁao de Item 2 - AlteraÁ„o de Quantidade
@param		cTexto - Texto Produto/Quantidade
@param		oLblProd - Label do Texto 1
@param		cTexto2 - Texto 2 - MÈtodo de Entrga
@param		cTexto3 - Texto 3 - Quantidade
@param		oLblMet - Label do MÈtodo de Entrega
@param		oGetProd - Get de Produto
@param		oGetQtde - Get de Quantidade
@param		oCbxMet - Objeto Combo de MÈtodo de Entrega
@author  	Varejo
@version 	P12
@since   	17/12/14
@return	NIl
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Static Function STIGLAtvCrtl(nOpc, cTexto,oLblProd, cTexto2, cTexto3, ;
								oLblMet,oGetProd, oGetQtde, oCbxMet  )	
				
	If Valtype(oCbxMet) = "O"
		
		If nOpc == 1 .OR. (!aMainCfg[POS_MLAQTD] .AND. !aMainCfg[POS_MAME]) //Inclus„o de Produto
			cTexto := STR0022 //"Produto"
			cTexto2 := ""
	
			oGetProd:lVisible := .T.
			oGetQtde:lVisible := .T. // Default .F.
			If aMainCfg[POS_MAME]
				cTexto2 := STR0020 //"Entrega
				oCbxMet:lVisible := .T.
			Else
				cTexto2 := ""
				oCbxMet:lVisible := .F.				
			EndIf			
	
		Else //nOpc == 2 - AlteraÁ„o da Quantidade do Item

			If aMainCfg[POS_MLAQTD] 
				cTexto := "" //"Quantidade"
				oGetQtde:lVisible := .T.
			Else
				cTexto := ""
				oCbxMet:lVisible := .F.
			EndIf

			If aMainCfg[POS_MAME]
				cTexto2 := STR0020 //"Entrega"
				oCbxMet:lVisible := .T.
			Else
				cTexto2 := ""
				oCbxMet:lVisible := .F.				
			EndIf
			oGetProd:lVisible := .F.
	
		EndIf

		oLblProd:Refresh()
		oLblMet:Refresh()
		oGetProd:Refresh()
		oCbxMet:Refresh()
		oGetQtde:Refresh()
	EndIf
	
	// Grava a opÁ„o selecionado para validar inclus„o de produto n„o cadastrado na lista
	If nOpc == 1
		lIncluirPrd := .T.
		STIGlIncProd(lIncluirPrd)
	ElseIf nOpc == 2	
		lIncluirPrd := .F.
		STIGlIncProd(lIncluirPrd)
	EndIf
	
Return


//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIGlAltSt
Funcao para alterar o Status do Grid de Mensagens
@param		aDados03  - Dados das Mensagens
@param		nPos - PosiÁ„o do Grid de Mensagens
@param		nPosStatus - Posicao do Campo Status
@param		oBrwConten3 - Grid de Mensagens
@param		aHeader03 - Header de Mensagens
@author  	Varejo
@version 	P12
@since   	17/12/14
@return	NIl
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Static Function  STIGlAltSt( aDados03, nPos, nPosStatus, oBrwConten3, ;
								aHeader03)
	Local cValor := ""
	Local lHabilita := .F.
	Local nX := 0

	If  AllTrim(STDGLRtCol(2,"SEL",1,nPos,aHeader03,aDados03,.F.,.F.)) = "1"
		cRet := ""
	Else
		cValor := "1"
	EndIf
	
	lHabilita := cValor == "1"
	
	If lHabilita
		//Desabilita os demais
		For nX := 1 to Len(aDados03)
			aDados03[nX, nPosStatus] := ""
		Next
	EndIf
	
	aDados03[nPos, nPosStatus] := cValor
	oBrwConten3:Refresh()
	
Return

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIGLBtCan
Funcao do bot„o de cancelamento do Grid Mensagens/Atores Entregas
@param		lGrdMsgAtv - Panel de Mensagens ativo
@param		oPnlGen - Panel do Grid
@param		aDados03 - Dados de Mensagens
@param		aHeader03 - Header de Mensagens
@param		aAuxCombo - Array de Status
@param		oGrpGen - Grupo GenÈrico
@param		cTextoGen - Texto GenÈrico
@param		oLblGen - Label GenÈrico
@param		cTextoBtn - Texto do bot„o
@param		oBtnCnc - Bot„o Cancelar
@param		oBtnCnf - Bot„o Confirmar
@author  	Varejo
@version 	P12
@since   	17/12/14
@return	NIl
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Static Function  STIGLBtCan(lGrdMsgAtv, oPnlGen, aDados03, aHeader03, ;
								aAuxCombo, oGrpGen, cTextoGen, oLblGen, ;
								cTextoBtn, oBtnCnc, oBtnCnf)

If lGrdMsgAtv 
	//Grid de Mensagens Ativo - Encerra o Panel
	aMainCFG := nil
	STIExchangePanel( { || STIPanItemRegister() } )	
Else
	//Grid de Atores/Entregas - Chama o Grid de Mensagens
	STWGLGdGe( @oPnlGen, @aDados03, @aHeader03, aAuxCombo, ;
				@oGrpGen,  @lGrdMsgAtv, @cTextoGen, @oLblGen, ;
				@cTextoBtn, @oBtnCnc, @oBtnCnf)
EndIf

Return

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc}STIGPrdCg
Funcao de MudanÁa do Grid de Itens de Lista
@param		 nGetQtde - Quantidade
@param		oBrwConten2 - Browse de Itens
@param		aHeader02 - Header de Itens
@param		aDados02 - Dados dos Itens
@param		cGetMetMet - MÈtodo de Entrega
@param		oGetQtde - Get de Quantidade
@param		oCbxMet - Combo de MÈtodo de Entrega
@author  	Varejo
@version 	P12
@since   	17/12/14
@return	NIl
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Static Function STIGPrdCg( nGetQtde, oBrwConten2, aHeader02, aDados02, ;
								cGetMetMet, oGetQtde, oCbxMet)
	
	Local cGetTmp := STDGLRtCol(2,"ME1_TIPO",1,oBrwConten2:nAt,aHeader02,aDados02,.F.,.F.)

	nGetQtde := STDGLRtCol(2,"QTDE",1,oBrwConten2:nAt,aHeader02,aDados02,.F.,.F.) 		
	nGetQtde := IIF(ValType(nGetQtde) == "N" .And. nGetQtde == 0, 1, nGetQtde)
		
	
	If !IsDigit(Substr(cGetTmp,1,1))
		cGetMetMet := cGetTmp 
	Else
		cGetMetMet := Substr(cGetTmp,1,1)
	EndIf
	oGetQtde:Refresh()
	oCbxMet:Refresh()
	STFCleanInterfaceMessage()

Return 

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIGlEstr
REtorna a Estrutura do Grid 
@param		 aLstCmpNL - Campos n„o listados
@param		cAlias - Alias
@param		aHeade - Header
@param		cCampo - Campo Status
@author  	Varejo
@version 	P12
@since   	17/12/14
@return	NIl
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

Static Function STIGlEstr(aLstCmpNL, cAlias, aHeader, aLstCmp, ;
								cCampo) 


If cAlias = "MED
	aAdd(aHeader, { "SEL", GetSX3Cache( "ME1_STATUS", "X3_PICTURE"), STR0009, 6 , GetSX3Cache( "ME1_STATUS", "X3_TIPO")}) //"Selecionado" 
EndIf
		
If !Empty(cCampo)
	aAdd(aLstCmp, cCampo)
	aAdd(aHeader,{})
EndIf

SX3->(DbSeek(cAlias))
While !SX3->(Eof()) .AND. SX3->X3_ARQUIVO == cAlias
	If 	X3Uso(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL .AND. aScan(aLstCmpNL,{|x| x == Upper(AllTrim(SX3->X3_CAMPO))}) == 0 .AND. ;
			SX3->X3_CONTEXT <> "V" .AND. ( cAlias = "MED" .OR. SX3->X3_TIPO <> "M")
		If SX3->X3_CAMPO <> cCampo 
			aAdd(aLstCmp,SX3->X3_CAMPO)
			//Cabecalho para a GD de lista
			aAdd(aHeader,{SX3->X3_CAMPO,SX3->X3_PICTURE,AllTrim(X3Titulo()),SX3->X3_TAMANHO,SX3->X3_TIPO})
		Else
			aHeader[1] := {SX3->X3_CAMPO,SX3->X3_PICTURE,AllTrim(X3Titulo()),SX3->X3_TAMANHO,SX3->X3_TIPO}
		EndIf
	Endif
	SX3->(DbSkip())
EndDo

If cAlias = "ME2"
	aHeader := {}
	aAdd(aHeader,{"ME2_CODIGO"		,GetSX3Cache("ME2_CODIGO","X3_PICTURE"),RetTitle("ME2_CODIGO"),,	GetSX3Cache("ME2_CODIGO","X3_TIPO")})
	aAdd(aHeader,{"ME2_ITEM"		,GetSX3Cache("ME2_ITEM","X3_PICTURE"),RetTitle("ME2_ITEM"),,	GetSX3Cache("ME2_ITEM","X3_TIPO")})
	aAdd(aHeader,{"ME2_PRODUT"		,GetSX3Cache("ME2_PRODUT","X3_PICTURE"),RetTitle("ME2_PRODUT"),,GetSX3Cache("ME2_PRODUT","X3_TIPO")})
	aAdd(aHeader,{"ME2_DESCRI"		,GetSX3Cache("ME2_DESCRI","X3_PICTURE"),RetTitle("ME2_DESCRI"),,GetSX3Cache("ME2_DESCRI","X3_TIPO")})
	aAdd(aHeader,{"DISPO"	,GetSX3Cache("ME2_QTDSOL","X3_PICTURE"),STR0006	,,GetSX3Cache("ME2_QTDSOL","X3_TIPO")}) //"Disponivel"	
	aAdd(aHeader,{"QTDE"		,GetSX3Cache("ME2_QTDSOL","X3_PICTURE"),STR0007	,,GetSX3Cache("ME2_QTDSOL","X3_TIPO")}) //"Quantidade"
	aAdd(aHeader,{"ME1_TIPO"	,GetSX3Cache("ME1_TIPO","X3_PICTURE"),STR0008	,"aCbxMet",GetSX3Cache("ME1_TIPO","X3_TIPO")}) //"Modo entrega"
	aAdd(aHeader,{"ME2_VALUNI"		,GetSX3Cache("ME1_TIPO","X3_PICTURE"),RetTitle("ME2_VALUNI")	,,GetSX3Cache("ME1_TIPO","X3_TIPO")})
	aAdd(aHeader,{"ME2_UM"		,GetSX3Cache("ME2_UM","X3_PICTURE"),RetTitle("ME2_UM")	,,GetSX3Cache("ME2_UM","X3_TIPO")})	
	aAdd(aHeader,{"MED_CODIGO"	,GetSX3Cache("ME2_UM","X3_PICTURE"),RetTitle("MED_CODIGO"),,GetSX3Cache("ME2_UM","X3_TIPO")})
EndIf

Return


//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIGlEstr
Verifica qual a opÁ„o selecionada - 1: Inclusao de Item, 2: AlteraÁ„o
Para validaÁ„o na inclus„o de produto fora da lista de presente
@param		lRet
@author  	Varejo
@version 	P12
@since   	02/08/15
@return		lRet
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

Function STIGlIncProd(lRet)
Default lIncluirPrd := .F.

lRet := lIncluirPrd

Return(lRet)


