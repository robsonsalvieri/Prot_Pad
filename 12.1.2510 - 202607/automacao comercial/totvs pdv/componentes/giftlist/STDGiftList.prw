#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STDGIFTLIST.CH"   

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

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/{Protheus.doc} STDGLRtCol
Retorna a coluna do Grid
@param		nOpc - 1 - Retorno da linha / 2- Retorno da coluna
@param		cTarget - Campo
@param		nPosN -  Posicao do X3_CAMPO no array de cabecalho
@param		nPosL - Posicao da linha na lista (GD) 
@param		aHead - Header dos Dados
@param		aDados - Array de Dados
@param		lLegen - Array de dados utiliza legenda na primeira coluna?
@param		lTCBox - Retornar o valor de um campo alimentado com o valor de opcao de combobox
@author  	Varejo
@version 	P12
@since   	17/12/14
@return	uRet - Valor localizado
@obs     
@sample
/*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

Function STDGLRtCol(nOpc,cTarget,nPosN,nPosL,;
						aHead,aDados,lLegen,lTCBox)

Local uRet				:= ""		//retorno da funcao
Local nPos				:= 0		//posicionamento do campo
Local nDesloca		:= 0		//deslocamento
Local cTMP				:= ""		// temporario

Default nOpc			:= 1		//opcao de manipulacao
Default nPosN			:= 2		//posicao do campo
Default lLegen		:= .T.		//exibe legenda
Default lTCBox		:= .F.		//exibe box
Default cTarget      := ""
Default nPosL        := 0
Default aHead        := {}
Default aDados       := {}

Do Case
	Case nOpc == 1
		uRet := 0
	Otherwise
		uRet := ""
EndCase
If ValType(aHead) # "A" .OR. Len(aHead) == 0 .OR. ValType(aDados) # "A" .OR. Empty(cTarget) .OR. Empty(nPosL)
	Return uRet
Else
	//Se a opcao for de retorno de dado e o array de dados estiver vazio, sair
	If nOpc == 2 .AND. Len(aDados) == 0 
		Return uRet
	Endif
Endif
If lLegen
	nDesloca := 1
Endif


Do Case
	Case nOpc == 1
		If nPosN == 0
			uRet := aScan(aHead,{|x| Upper(AllTrim(x)) == Upper(AllTrim(cTarget))})
		Else
			uRet := aScan(aHead,{|x| Upper(AllTrim(x[nPosN])) == Upper(AllTrim(cTarget))})
		Endif
	Case nOpc == 2
		If nPosN == 0
			nPos := aScan(aHead,{|x| Upper(AllTrim(x)) == Upper(AllTrim(cTarget))})
		Else
			nPos := aScan(aHead,{|x| Upper(AllTrim(x[nPosN])) == Upper(AllTrim(cTarget))})
		Endif
		If nPos > 0
			If (uRet := aDados[nPosL][nPos + nDesloca]) == Nil
				uRet := ""
			Endif
		Endif
		//Caso se deseje retornar o valor original de um campo alimentado com os valores da combobox
		If lTCBox .AND. ValType(uRet) == "C" .AND. !Empty(uRet)
			If !Empty(cTMP := STDGLOpCmb(cTarget,uRet))
				uRet := cTMP
			Endif
		Endif
EndCase

Return uRet

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/{Protheus.doc} STDGLOpCmb
Funcao para retornar a opcao de lista selecionada a partir da
@param		cCampo - Nome do campo
@param		cDescOpc - Descricao da opcao  
@author  	Varejo
@version 	P12
@since   	17/12/14
@return	cRet -  Array com os dados encontrados 
@obs     
@sample
/*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Function STDGLOpCmb(cCampo,cDescOpc)

Local aAreaSX3		:= SX3->(GetArea())		//area do SX3
Local cTMP				:= ""						//manipulacao de dados na SX3
Local aTMP				:= {}                      //manipulacao de dados na SX3
Local cRet				:= ""                      //retorno da funcao
Local nTam				:= 0                       //tamanho dos campos

Default cCampo			:= ""                     //campo para busca
Default cDescOpc		:= ""                     //campo para retorno

If Empty(cCampo) .OR. Empty(cDescOpc)
	Return cRet
Endif
cDescOpc := AllTrim(cDescOpc)
DbSelectArea("SX3")
SX3->(DbSetOrder(2))
If SX3->(DbSeek(PadR(cCampo,Len(SX3->X3_CAMPO))))
	nTam := Len(SX3->X3_CBOX)
	If SX3->X3_TIPO == "C"
		If !Empty(cTMP := X3CBox())
			aTMP := RetSX3Box(cTMP,,,1)
			If (nPos := aScan(aTMP,{|x| PadR(Upper(x[3]),nTam) == PadR(Upper(cDescOpc),nTam)})) > 0
				cRet := aTMP[nPos][2]
			Endif
		Endif
	Endif
Endif
RestArea(aAreaSX3)

Return cRet

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/{Protheus.doc} STDGLIt
Funcao para retornar os dados do Item de Lista
@param		aDados02 - Dados do Array de Lista
@param		aMainCfg - Array de configurações da Lista
@param		aLstC02 - Lista de Campos
@param		lTCBox - Retornar valores combo?
@param		lListaItAb - Somente Lista itens abertos
@param		aCabBr - Cabeçalho do Browse
@param		aItRet - Array de Retorno dos Itens selecionados
@param		cNumLst - Numero da Lista
@param		cModoEnt - Array de Método de Entrega
@param		aCbxMet  - Combo de Método de Entrega
@author  	Varejo
@version 	P12
@since   	17/12/14
@return	aRet -  Array com os itens da Lista 
@obs     
@sample
/*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Function STDGLIt(aDados02, aMainCfg, aLstC02, lTCBox, ;
					lListaItAb, aCabBr, aItRet, cNumLst, ;
					cModoEnt, aCbxMet)
Local nI 			:= 0  //Contador
Local aRet 		:= {} //Retorno
Local cME2_Item 	:= "" //Item de Lista
Local nQtdDispo 	:= 0 //Quantidade Disponível
Local cTmp 		:= "" //Array temporario
Local nPosCol 	:= 0 //Posicao da coluna
Local nPos 		:= 0 //Posicao da Linha
Local nX 			:= 0 //Contador
Local aTmp 		:= {} //Array Temporario

For ni := 1 to Len(aDados02)
	//Se de origem de comprador, saltar
	If STDGLRtCol(2,"ME2_ORIGEM",0,ni,aLstC02,aDados02,.F.,lTCBox) # "O"
		Loop
	Endif
	
	cME2_Item := STDGLRtCol(2,"ME2_ITEM",0,ni,aLstC02,aDados02,.F.,lTCBox)
	//Determinar quantidade disponivel
	nQtdDispo := STDGLRtCol(2,"ME2_QTDSOL",0,ni,aLstC02,aDados02,.F.) - STDGLRtCol(2,"ME2_QTDATE",0,ni,aLstC02,aDados02,.F.)
	If nQtdDispo > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Estrutura do array de quantidades :  ³
		//³[01] Numero da lista                 ³
		//³[02] Item da lista                   ³
		//³[03] Quantidade utilizada            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ValType(aMainCfg[POS_MQTDU]) == "A" .AND. Len(aMainCfg[POS_MQTDU]) > 0
			For nx := 1 to Len(aMainCfg[POS_MQTDU])
				If Len(aMainCfg[POS_MQTDU][nx]) == 3
					If AllTrim(aMainCfg[POS_MQTDU][nx][1]) == AllTrim(cNumLst) .AND. AllTrim(aMainCfg[POS_MQTDU][nx][2]) == AllTrim(cME2_Item)
						If ValType(aTail(aMainCfg[POS_MQTDU][nx])) == "N" .AND. aTail(aMainCfg[POS_MQTDU][nx]) > 0
							nQtdDispo -= aTail(aMainCfg[POS_MQTDU][nx])
							Exit
						Endif
					Endif
				Endif
			Next nx
		Endif
	Endif
	If nQtdDispo < 0
		nQtdDispo := 0
	Endif
	//Somente itens em aberto
	If lListaItAb .AND. nQtdDispo <= 0
		Loop
	Endif
	//Pesquisar codigo de barras
	cTMP := STDGLRtCol(2,"ME2_PRODUT",0,ni,aLstC02,aDados02,.F.)
	cCodBar := GetAdvfVal("SB1","B1_CODBAR",xFilial("SB1") + cTMP,1)
	If Empty(cCodBar)
		cCodBar := GetAdvfVal("SLK","LK_CODBAR",xFilial("SLK") + cTMP,1)
	Endif
	
	
	aTmp := STDGLFRt(aCabBr, nI, aLstC02, aDados02, ;
						cTmp, cCodBar, nQtdDispo, cNumLst, ;
						cModoEnt, "", 0, aItRet, ;
						aCbxMet)
	
	aAdd(aRet, aClone(aTmp[1]))
		

Next ni
conout("cNumLst")
//Carrega os itens de lista inseridos
nX := aScan(aItRet, { | l | l[1] == cNumLst})
If nX > 0
	For nPos := 1 to Len(aItRet[nX, 05])
		If Empty(aItRet[nX, 05][nPos, 01]) //Item Inserido
			aTmp := Array(len(aLstC02))
			aTmp[STDGLGtCl("ME2_CODIGO", aCabBr) ] := cNumLst
			aTmp[STDGLGtCl("ME2_ITEM", aCabBr) ] := ""		
			aTmp[STDGLGtCl("ME2_DESCRI", aCabBr) ] := ""
			aTmp[STDGLGtCl("ME2_VALUNI", aCabBr) ] := 0
			aTmp[STDGLGtCl("ME2_UM", aCabBr)]  := ""				
			//aTmp[STDGLGtCl("B1_CODBAR", aCabBr) ]  := ""	
			
			aTmp[STDGLGtCl("ME2_PRODUT", aCabBr) ] := aItRet[nX, 05][nPos, 02]
			aTmp[STDGLGtCl("DISPO", aCabBr) ] := aItRet[nX, 05][nPos, 03]
			aTmp[STDGLGtCl("QTDE", aCabBr) ] := aItRet[nX, 05][nPos, 04]
			aTmp[STDGLGtCl("ME1_TIPO", aCabBr) ] :=  aItRet[nX, 05][nPos, 05]	
			aTmp[STDGLGtCl("MED_CODIGO", aCabBr) ]  := aItRet[nX, 05] [nPos, 07]

			
			aAdd(aRet, aClone(aTmp))
		EndIf
	Next nX
EndIf


Return aRet

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/{Protheus.doc} STDGLGtCl
Funcao para retornar o numero da coluna dado do Header
@param		cColuna - Nome do campo
@param		aBrowse - Array do Header do Browse
@author  	Varejo
@version 	P12
@since   	17/12/14
@return	nRet -  Posicao do Array 
@obs     
@sample
/*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

Function STDGLGtCl(cColuna, aBrowse)
Local nRet := 0

nRet := aScan(aBrowse, { |c| c[1] == cColuna})

Return nRet


//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/{Protheus.doc} STDGLFRt
Funcao para alimentar os dados do Grid de Itens
@param		aCabBr - Cabeçalho do Header do Grid
@param		nI - Linha do Grid
@param		aLstC02 - Campos do Grid
@param		aDados02 - Dados do Grid
@param		cCodProd - Codigo do Produto
@param		cCodBar - Codigo de Barras
@param		nQtdDispo - Quantidade Disponível
@param		cNumLst - Numero da Lista
@param		cModoEnt - Modo de Entrega
@param		cCodMens - Codigo da Mensagem
@param		nQtde - Quantidade
@param		aItRet - Itens selecionados da Lista
@param		aCbxMet - Array de Método de Entrega
@author  	Varejo
@version 	P12
@since   	17/12/14
@return	aRet -  Linha do Grid de Itens de Lista
@obs     
@sample
/*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Function STDGLFRt(aCabBr, nI, aLstC02, aDados02, ;
					cCodProd, cCodBar, nQtdDispo, cNumLst, ;
					cModoEnt, cCodMens, nQtde, aItRet, aCbxMet)
Local aRet := {}
Local nPos := 0
Local nX := 0

aAdd(aRet, Array(len(aCabBr)))
nPos := 1

aRet[nPos,STDGLGtCl("ME2_CODIGO", aCabBr) ] := cNumLst
aRet[nPos,STDGLGtCl("ME2_PRODUT", aCabBr) ] := cCodProd
aRet[nPos,STDGLGtCl("DISPO", aCabBr) ] := nQtdDispo
aRet[nPos,STDGLGtCl("QTDE", aCabBr) ] := nQtde
aRet[nPos,STDGLGtCl("MED_CODIGO", aCabBr) ]  := cCodMens
aRet[nPos, STDGLGtCl("ME1_TIPO", aCabBr) ] := cModoEnt	

If nI > 0	
	aRet[nPos, STDGLGtCl("ME2_ITEM", aCabBr)] := STDGLRtCol(2,"ME2_ITEM",0,ni,aLstC02,aDados02,.F.)

	aRet[nPos,STDGLGtCl("ME2_DESCRI", aCabBr) ] := STDGLRtCol(2,"ME2_DESCRI",0,ni,aLstC02,aDados02,.F.)
	aRet[nPos,STDGLGtCl("ME2_VALUNI", aCabBr) ] := STDGLRtCol(2,"ME2_VALUNI",0,ni,aLstC02,aDados02,.F.)
	aRet[nPos,STDGLGtCl("ME2_UM", aCabBr)]  := STDGLRtCol(2,"ME2_UM",0,ni,aLstC02,aDados02,.F.)

	nX := aScan(aItRet, { |l| l[1] == cNumLst})
	If nX > 0 .AND.  (nPosCol := aScan(aItRet[nX, 05], { |It| It[8] == cNumLst .and. It[1] == aRet[nPos , STDGLGtCl("ME2_ITEM", aCabBr)] .AND.  It[2] == aRet[nPos , STDGLGtCl("ME2_PRODUT", aCabBr)] }) ) > 0 
		aRet[nPos,STDGLGtCl("QTDE", aCabBr) ] := aItRet[nX, 05][nPosCol, 04]
		aRet[nPos,STDGLGtCl("MED_CODIGO", aCabBr) ] := aItRet[nX, 05][nPosCol, 07]
		If aCbxMet <> NIL .AND. Val(Left(aItRet[nX, 05][nPosCol, 05],1)) > 0
			aRet[nPos, STDGLGtCl("ME1_TIPO", aCabBr) ] := aCbxMet[Val(Left(aItRet[nX, 05][nPosCol, 05],1))]
		Else
			aRet[nPos, STDGLGtCl("ME1_TIPO", aCabBr) ] := aItRet[nX, 05][nPosCol, 05]
		EndIf
	EndIf
Else
	aRet[nPos, STDGLGtCl("ME2_ITEM", aCabBr)] := ""

	aRet[nPos,STDGLGtCl("ME2_DESCRI", aCabBr) ] := ""
	aRet[nPos,STDGLGtCl("ME2_VALUNI", aCabBr) ] := 0
	aRet[nPos,STDGLGtCl("ME2_UM", aCabBr)]  := ""

EndIf	

Return aRet

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/{Protheus.doc} STDGLLoIt
Função para retornar os itens da lista constantes na cesta
@param
@author  	Varejo
@version 	P12
@since   	17/12/14
@return	aItemLst -  Itens de Lista constantes na cesta
@obs     
@sample
/*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Function STDGLLoIt()
	Local oModelSale  	:= STDGPBModel() 	// Model de venda
	Local aItemLst := {}
	Local nItens := 0
	Local nX := 0
	Local   aLines      := FwSaveRows()
	
	oModelItem := oModelSale:GetModel("SL2DETAIL")
	nItens := oModelItem:Length()

	For nX := 1 to nItens
		oModelItem:GoLine(nItens)
		If !oModelItem:IsDeleted() .AND.  !Empty(oModelItem:GetValue("L2_CODLPRE"))

	
			aAdd(aItemLst,{	oModelItem:GetValue("L2_CODLPRE"),;		//Codigo da Lista
							oModelItem:GetValue("L2_ITLPRE"),;		//Item do Codigo da Lista 
							oModelItem:GetValue("L2_QUANT")})			//Quantidade do Item
		EndIf
	Next nX
	
FwRestRows(aLines)
	
Return aItemLst

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/{Protheus.doc} STDGLRetD
Função que realiza a chamada remota de pesquisa de dados na retaguarda remotamente
@param  cFunction - Rotina
@param  aParams - Parametros da rotina 
@param  aRetorno - Retorno
@author  	Varejo
@version 	P12
@since   	17/12/14
@return	lRet -  Retorno com sucesso
@obs     
@sample
/*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Function STDGLRetD( cFunction, aParams, aRetorno)
Local lRet := .F.
Default aParams := {}
Default aRetorno := {}


If !Empty(cFunction)
	lRet := STBRemoteExecute(cFunction,;
						aParams	,;
						Nil				,;
						.F. 			,;
						@aRetorno			) 

EndIf

Return lRet

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/{Protheus.doc} STDSearCodBar
Função que realiza a busca do produto pelo codigo de barras
@param  cCodSearch - Codigo de Barras/Produto
@param  cProduct - Codigo do Produto 
@param  oGrpPrd - Objeto grupo de produtos
@param  oGetCodBar - Objeto Codigo de Barras
@author  	Varejo
@version 	P11
@since   	02/04/15
@return	lRet -  Retorno com sucesso
@obs     
@sample
/*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

Function STDSearCodBar(cCodSearch, cProduct, oGrpPrd, oGetCodBar)

Local aArea		:= GetArea()	
Local aAreaSLK	:= SLK->(GetArea()) //Area do SLK
Local aAreaSB1	:= SB1->(GetArea()) //Area do SB1
Local lRet 		:= .F.
Local nPos			:= 0

Default cCodSearch 	:= Space(TamSx3("B1_CODBAR")[1])
Default cProduct 		:= Space(TamSx3("B1_COD")[1])
Default oGrpPrd 	 	:= Nil
Default oGetCodBar 	:= Nil

//Busca Codigo de Barras
If !Empty(cCodSearch)			
	//Busca Codigo do Produto
	Do Case
		Case !Empty(Posicione("SB1", 5, xFilial("SB1") + Padr(cCodSearch, TamSx3("B1_CODBAR")[1]), "B1_COD")) //Busca Codigo de Barras na SB1 		 
			cProduct := SB1->B1_COD
		Case !Empty(Posicione("SLK", 1, xFilial("SLK") + Padr(cCodSearch, TamSx3("LK_CODBAR")[1]), "LK_CODIGO")) //Busca Codigo de Barras na SLK 			
			cProduct := SLK->LK_CODIGO
		Case !Empty(Posicione("SB1", 1, xFilial("SB1") + Padr(cCodSearch, TamSx3("B1_COD")[1]), "B1_COD")) //Busca Codigo do Produto na SB1 			
			cProduct := SB1->B1_COD
		OtherWise
			cProduct := Space(TamSx3("B1_COD")[1])
	EndCase
				
	If !Empty(cProduct) 														
		//Posiciona no produto - Grid		
		nPos := aScan(oGrpPrd:oData:aArray,{|x,y| AllTrim(x[3]) == AllTrim(cProduct)})
		
		If nPos > 0
			oGrpPrd:nAt := nPos
			oGrpPrd:Refresh()
			lRet := .T.		
		Else
			cCodSearch := Space(TamSx3("B1_CODBAR")[1])
			STFMessage("STDSearCodBar1", "STOP", STR0001) //"Produto nao encontrado na Lista de Presentes" 
			STFShowMessage("STDSearCodBar1")				
			lRet := .F.				
		EndIf		
	Else
		cCodSearch := Space(TamSx3("B1_CODBAR")[1])
		oGetCodBar:Refresh()
		oGetCodBar:SetFocus()
		STFMessage("STDSearCodBar2", "STOP", STR0002) //"Codigo de Barras nao encontrado" 
		STFShowMessage("STDSearCodBar2")				
		lRet := .F.				
	EndIf
EndIf

//Restaura areas
RestArea(aAreaSLK)
RestArea(aAreaSB1)
RestArea(aArea)

Return lRet
