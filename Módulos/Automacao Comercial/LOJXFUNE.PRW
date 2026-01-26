#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJXFUNE.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "DIRECTRY.CH"

Static lCalcCab		:= .T.
Static lCenVenda 	:= SuperGetMv("MV_LJCNVDA",,.F.)
Static aUltTab		:= {}
Static aUltTabCli 	:= {}
Static aDesProCom	:= {} 
Static aTabXPreco	:= {}
Static aTabelas		:= {}
Static lNovRegDesc	:= SuperGetMv("MV_LJRGDES",,.F.) .AND. RGVldTable()		// Validacao da Nova Regra de Desconto Ativa
Static lRgAcumul	:= .T.													// Regra de Desconto acumulativa
Static lLJ7108      := ExistBlock("LJ7108") 								// PE para customizar a tabela de preco
Static cMvLjTGar	:= SuperGetMV("MV_LJTPGAR",,"GE")						// Tipo de Garantia Estendida
Static cMvLjRetVl	:= SuperGetMV("MV_LJRETVL",,"3") 						// 1=Retorna o menor preco de uma tabela | 2=Retorna o maior preco de uma tabela | 3=Considera preco da tabela configurada no parametro MV_TABPAD
Static lSFinanc		:= SuperGetMV("MV_LJCSF",,.F.)							// Validação do Conceito Servico Financeiro
Static cMvLjTSF		:= SuperGetMV("MV_LJTPSF",,"SF")						// Tipo de servico financeiro
Static cMV_TABPAD 	:= SuperGetMv("MV_TABPAD")								// Código da Tabela de Preço Padr?o
Static lLjCnVB0		:= SuperGetMv("MV_LJCNVB0",,.F.)						// Retorna preço da SB0 na ausência do preço do Produto na DA0 e DA1
Static lMVLJECOMM 	:= SuperGetMV("MV_LJECOMM",,.F.)						// Integraç?o com e-commerce
Static cMV_CLIPAD	:= SuperGetMV("MV_CLIPAD")       					 	// Cliente padrao
Static cMV_LOJAPAD	:= SuperGetMV("MV_LOJAPAD")       						// Loja do cliente padrao
Static cNumCaixa	:= xNumCaixa()											// Numero do Caixa Logado no sistema
Static aPeLJ7108	:= {}													// Controla o retorno do PE LJ7108 para não executá-lo diversas vezes. Deve executar apenas 1 vez para cada item da venda.
Static aRetMTabPr	:= {}													// Controla o retorno da função MaTabPrVen para não executá-la diversas vezes para resgatar o preço do mesmo produto.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjRgrDesc ºAutor  ³Vendas CRM          º Data ³  27/10/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Avaliacao das regras de desconto para utilizacao na venda   º±±
±±º          ³assistida e venda balcao                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1: Produto                                              º±±
±±º          ³ExpC2: Cliente                                              º±±
±±º          ³ExpC3: Loja                                                 º±±
±±º          ³ExpC4: Tabela                                               º±±
±±º          ³ExpN5: Faixa de desconto                                    º±±
±±º          ³ExpN6: Tipo de Desconto                                     º±±
±±º          ³       1 - Desconto por Item                                º±±
±±º          ³       2 - Desconto por Total                               º±±
±±º          ³ExpA7: Array contendo a seguinte estrutura :                º±±
±±º          ³       [n][1] : Codigo do produto                           º±±
±±º          ³       [n][2] : Grupo  do produto                           º±±
±±º          ³       [n][3] : Quantidade                                  º±±
±±º          ³       Devem ser passados tods os produtos e as suas Qtdes. º±±
±±º          ³       para ocalculo de descontos escalaveis.               º±±
±±º          ³ExpA8: Array contendo as regras que NAO devem ser considera-º±±
±±º          ³       das.                                                 º±±
±±³          ³ExpC9: Codigo da Regra de Desconto usada.	    			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ExpN1: Percentual de Desconto da Regra                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJA701                                                     º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjRgrDesc(	cProduto	,cCliente	,cLoja		,cTabPreco	,;
					nFaixa		,nTipo		,aProds		,aExc		,;
					cCodRegDe	,nVlrItem	,cTipoProd	, lPrdRegDes,;
					lRdTotIt	)

Local aArea			:= GetArea()
Local nDesc			:= 0   
Local dDatTerm      := ""
Local aAreaACO		:= {}
Local nPosCpoIt     := 0
Local nPosItem      := 0
Local nVlrIt		:= 0
Local nPosVlItem    := 0
Local lDesProCom    := 0
Local nUnitario		:= 0 	// Valor Unitario do item
Local nPosUnit		:= 0 	// Posicao do campo UNITARIO
Local cCondPg		:= ""

Default cProduto	:= "" 	// Produto que será realizada a busca do desconto
Default cCliente	:= ""	// Informacoes do Cliente
Default cLoja		:= ""	// Loja.
Default cTabPreco	:= ""	// Tabela de Preço.
Default cCodRegDe	:= ""	// Codigo da Regra de Desconto.
Default aProds		:= {}	// Produtos.                  
Default aExc		:= {}	// Execução.
Default nFaixa		:= 0	// Faixa.
Default nTipo		:= 0	// Tipo.
Default nVlrItem	:= 0	// Valor do Item caso seja Front Loja.
Default cTipoProd 	:= ""	// Tipo de produto na venda, Saldao ou Mostruario
Default lPrdRegDes	:= .F.	// Indica se o produto possui alguma Regra de Desconto, independente da quantidade       
Default lRdTotIt	:= .F.	// Indica que é chamado pela nova regra de desconto por item

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quando o desconto for por item, precisa do valor unitario ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nTipo == 1)
	If nModulo == 23 //se vier do Front Loja
		nUnitario := nVlrItem / nFaixa
	Else
		nPosUnit := aScan(aHeader,{|x| AllTrim(x[2]) == "LR_VRUNIT"   })  //posicao do campo UNITARIO
		nUnitario 	:= aCols[n][nPosUnit]
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Nao serao consideradas as condicoes e formas de pagamento.³
//³Por serem definidas somente no final do processo da venda ³
//³concomitante, nos modulos SIGALOJA e SIGAFRT, estes       ³
//³campos nao serao considerados nos criterios para aplicacao³
//³das Regras de Desconto.                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (lNovRegDesc .And. lCenVenda)      
	
	If nTipo == 1  // Desconto Item
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Validacao do modulo para verificar o tipo de produto      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		If nModulo == 12 .Or. nModulo == 5		//Venda Assistida
			cTipoProd := IIF( "LR_VDMOST" $ ReadVar(), M->LR_VDMOST, GdFieldGet("LR_VDMOST",n) )
		EndIf

		nDesc := RGDesIte(cProduto, cCliente, cTipoProd, cLoja, , nFaixa, , @lPrdRegDes, lRdTotIt)				
		
	Else    // Desconto Total  

		// Guardar a variável de Regra Acumulativa para processar as regras de desconto por total,
		// depois devolver
		nDesc := RGDesTol(.F., aTotais[1,2], Nil, Nil, cCliente, cLoja)

	EndIf			
Else
	If nModulo == 12 .Or. nModulo == 5
		cCondPg := M->LQ_CONDPG
		If Empty(cCondPg)
			cCondPg := SuperGetMv("MV_CONDPAD")	
		EndIf 
	EndIf

	nDesc := MaRgrDesc(cProduto,cCliente,cLoja,cTabPreco,nFaixa,cCondPg,/*cFormPg*/,nTipo,aProds,aExc, @cCodRegDe, nUnitario) 	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Rotina responsável por alimentar o Array "ADesProcom"³
	//³com informações dos Produtos que fazem parte     	³
	//³da regra de negocio, como: Codigo +        			³
	//³valor do desconto + Data Validade do Desconto.   	³
	//³Somente realiza, caso o Cliente nao seja o Padrao    ³
	If lCenVenda .AND. !Empty(nDesc)  

	    aAreaACO := ACO->(GetArea())
	    DbSelectArea("ACO")                     //TABELA ACO - REGRA DE DESCONTO
	    ACO->(DbSetOrder(1)) 							//ACO_FILIAL+ACO_CODREG
	    If ACO->(DbSeek(xFilial("ACO")+cCodRegDe))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Realiza a Rotina de Desconto na Proxima Venda, somente     ³
			//³caso esteja selecionada no Lançamento da Regra de          ³
			//³Desconto e Se o Cliente Utilizado no Momento for Diferente ³
			//³do Cliente Padrão                                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lDesProCom 		:= ACO->ACO_DESCPR 
			If lDesProCom .AND. (cCliente+cLoja <> cMV_CLIPAD+cMV_LOJAPAD )
				dDatTerm	:= ACO->ACO_DATATE
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Busca a ordem de lancamento do Item caso seja Loja através do LR_Item no aCols  ³
				//³e caso seja Front, através do L2_Item, para armazenamento no array com as infos ³
				//³dos produtos e posteriormente seja utilizado no momento para Deleção do Item.   ³
	 			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nModulo <> 23
					nPosCpoIt	:= aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_ITEM"})][2]		// Numero da Posicao do item.	
					nPosVlItem	:= aScan(aHeader,{|x| AllTrim(x[2]) == "LR_VLRITEM"}) 						// Numero da Posicao do Valor do item.
					nPosItem    := aCols[n][nPosCpoIt]                                                     // Posicao de Lancamento do item.
					nVlrIt	    := aCols[n][nPosVlItem]                                                    // Valor do Item para o Calculo.
				Else
					nVlrIt      := nVlrItem  // Valor do Item do Front Loja
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Preenche no array aDesProCom os Produtos com as infos:      ³
				//³Valor do Desconto, Data Limite, Posiçao do Item, somente se ³
				//³este item esteja com desconto atribuído através da Regra de ³
				//³Desconconto do Cenário de Vendas.                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(nDesc)    
					AAdd(aDesProCom, {cProduto,nVlrIt,nDesc,dDatTerm,nPosItem} )
	   		 		nDesc := 0
				EndIf
	    	EndIf
	    EndIf
	EndIf
EndIf
RestArea(aArea)

Return nDesc

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjGetCVar º Autor ³	Vendas & Crm     º Data ³  20/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Transporta o valor da variavel aDesProCom.				  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ Nil                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA701                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjGetCVar()
Return aDesProCom

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ºLjSetCVar º Autor º	Vendas & Crm     º Data º  24/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³															  º±±
±±º			 ³Atualiza o valor da variavel aDesProCom enviado por outros  º±±
±±º			 ³fontes				  									  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ Nil                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA701                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjSetCVar(aSetVal)
Default aSetVal:= {}

aDesProCom := aClone(aSetVal)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOJXFUNE  ºAutor  ³Microsiga           º Data ³  28/10/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Aplica o desconto no item de acordo com a regra de negocios º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - Codigo do produto                                   º±±
±±º          ³ExpC2 - Codigo do cliente                                   º±±
±±º          ³ExpC3 - Loja do cliente                                     º±±
±±º          ³ExpN4 - Quantidade vendida                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA701                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjDescItem( cProduto , cCliente	, cLoja, nQuant,; 
					 cCodRegDe, nVlDesReg	, lScCsPreco)
Local cBkReadV		:= ""								   			    	// Backup da variavel __ReadVar
Local nRegDesc		:= 0								  			     	// Valor do desconto calculado pela regra
Local nPosDesc		:= Ascan(aHeader,{|x| AllTrim((x[2]))=="LR_DESC"})  	// Posicao do percentual de desconto
Local lVAssConc	 	:= SuperGetMV("MV_LJVACC", ,.F.) .Or. LjVassConc(1)    	// Indica se o cliente utiliza a Vda Assistida Concomitante
Local lRet			:= .F.												    // Indica se houve desconto atraves da regra 
Local cTabPreco		:= LjXETabPre(cCliente,cLoja) 						    // Parametro da tabela de preco padrao

Default nQuant      := 0    
Default cCodRegDe   := ""													// Codigo da Regra de desconto usada
Default nVlDesReg   := 0													// Valor de desconto consedido pela regra de desconto
Default lScCsPreco	:= .F.													// Usado na integracao Protheus x SIAC. Indica se o Protheus 
																			//utiliza a consulta WS para consultar o preco no SIAC Store

If !IsInCallStack("LJ7VALCLI")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calcula o desconto a partir da regra de descontos - ITENS³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nRegDesc := LjRgrDesc(cProduto,cCliente,cLoja,cTabPreco,nQuant,1,/*aProds*/,/*aExc*/, @cCodRegDe)
EndIf

nVlDesReg := nRegDesc

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se houver desconto, aciona a rotina Lj7VlItem() novamente,³
//³para executar o calculo do desconto, a partir do campo    ³
//³M->LR_DESC.                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nRegDesc > 0
	
	cBkReadV			:= __ReadVar
	__ReadVar			:= "M->LR_DESC"
	M->LR_DESC			:= nRegDesc
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Na venda concomitante, o valor de desconto deve ser ³
	//³registrado apos a funcao Lj7VlItem().               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lVAssConc
		aCols[n][nPosDesc]	:= nRegDesc
	Else
		aCols[n][nPosDesc]	:= 0
	EndIf
	
	Lj7VlItem(3,.T.)

	If lVAssConc
		aCols[n][nPosDesc]	:= nRegDesc
	EndIf
	
	__ReadVar	:= cBkReadV
	lRet		:= .T.  
	
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjDescCab ºAutor  ³Vendas CRM          º Data ³  10/28/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcula o desconto a partir da regra de descontos - TOTAL   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJA701                                                     º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjDescCab(	cProduto, cCliente	, cLoja		, aCols		,;
					aHeader	, nFaixa	, lConsulta	, nRegDesc )

Local aProds		:= {}
Local lRegDesc      := .F. 
Local nX			:= 0
Local nPosProd		:= aScan(aHeader,{|x| AllTrim(x[2]) == "LR_PRODUTO"})	// Posicao do codigo do produto
Local nPosQuant		:= aScan(aHeader,{|x| AllTrim(x[2]) == "LR_QUANT"})	// Posicao da Quantidade
Local nPosVlItem	:= aScan(aHeader,{|x| AllTrim(x[2]) == "LR_VLRITEM"})	// Posicao do Valor do item
Local cTabPreco		:= LjXETabPre(cCliente,cLoja) 							//parametro da tabela de preco padrao

Default lConsulta	:= .F.

nRegDesc := 0 

LjGrvLog( NIL, " Inicio da função LjDescCab - Regra de Desconto no Total")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o desconto no total foi ajustado manualmente, nao havera    ³
//³mais controle de desconto por regra nos totais para esta venda.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lCalcCab
	lRegDesc := Nil
	LjGrvLog( NIL, " Desconto foi ajustado manualmente - não pode aplicar a Regra de Desconto",lCalcCab)
Else
	/*Cria lista de produtos da venda para a rotina 
	de regra de	descontos na estrutura:                                   
	{{cProduto,cGrupo,nQuantidade};                           
	{cProduto,cGrupo,nQuantidade}}*/	
	SB1->( DbSetOrder(1) )
	For nX := 1 to Len(aCols)
		If !aTail(aCols[nX])
			SB1->( DbSeek(xFilial("SB1")+aCols[nX][nPosProd]) )
			AAdd(aProds,{aCols[nX][nPosProd],;
						SB1->B1_GRUPO,;
						aCols[nX][nPosQuant]})
		EndIf
	Next nX
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se ha desconto para toda a venda e aplica-o³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aProds) > 0
		
		nRegDesc := LjRgrDesc(cProduto,cCliente,cLoja,cTabPreco,nFaixa,2,aProds,/*aExc*/)
		
		If nRegDesc > 0 .OR. ( (!lNovRegDesc .Or. nRegDesc == 0) .AND. Lj7T_DescV(2) > 0 )
			If !lConsulta
				/***** Aplica o desconto *******/
				LJ7VldDesc( Nil, nRegDesc)
			EndIf
			                                                 
			lRegDesc := .T.
		EndIf		
	EndIf
EndIf

LjGrvLog( NIL, " Regra de Desconto no Total - Valor ",nRegDesc)
LjGrvLog( NIL, " Regra de Desconto no Total - Tem Regra?",lRegDesc)
LjGrvLog( NIL, " Regra de Desconto no Total - Consulta de Regra?", lConsulta)
LjGrvLog( NIL, " Final da função LjDescCab - Regra de Desconto no Total")

Return lRegDesc

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjDescRst ºAutor  ³Vendas CRM          º Data ³  28/10/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Reinicia as variaveis estaticas de controle das funcoes paraº±±
±±º          ³manipulacao de regras de desconto.                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJA701                                                     º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjDescRst()

lCalcCab	:= .T.
LjSetRAcumul(.T.)  // Reinicia como .T. ao (re)começar a venda assistida 

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjDescOff ºAutor  ³Vendas CRM          º Data ³  28/10/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Desabilita o calculo de descontos para o total da venda     º±±
±±º          ³atraves das regras de desconto para a venda atual           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJA701                                                     º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjDescOff()
lCalcCab	:= .F.
Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjxeTPrecoºAutor	³Vendas CRM			 º Data ³  30/10/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o preco de venda da tabela de precos padrao		  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1: Produto                                              º±±
±±º          ³ExpC2: Codigo do Cliente                                    º±±
±±º          ³ExpC3: Codigo da Loja                                       º±±
±±º          ³ExpN4: Moeda                                                º±±
±±º          ³ExpN5: Quantidade do Item                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ExpN1: Valor de venda do produto encontrado na tabela       º±±
±±ºUso       ³LOJA701 e FRTA271                                           º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjxeTPreco(cProduto, cCliente, cLoja, nMoeda, ;
							nQtdade, cTabPadIn)

Local nRet 			:= 0							// Variavel de retorno do preco
Local cTabPrecos    := LjXETabPre(cCliente,cLoja)	// Parametro da tabela de preco padrao
Local nPosQuant		:= 0							// Posicao da Quantidade
Local nPosVlUnit	:= 0							// Posicao do Valor unitario do item
Local nPosProd		:= 0							// Posicao do Codigo do Produto
Local nPosItCob		:= 0
Local nPosEnvelo    := 0                            // Posicao do codigo do envelope
Local nX			:= 0							// Variavel de controle de For
Local aValores		:= {}
Local lGE			:= LjUP104ok() 					// Validação do Conceito Garantia Estendida
Local aRet			:= {} 							// Retorno preco servico
Local cTabPad		:= IIF(!lLJ7108, Alltrim(cMV_TABPAD),cTabPrecos)	//Para manter o legado foi realizado protecao para uso do PE, porem, rotina LjXETabPre ja retorna MV_TABPAD quando nao utiliza o PE
Local laPosCpo 		:= Iif(Type("aPosCpo") == "A" .AND. Len(aPosCpo)>0, .T., .F.)	// Verifica se a chamada da função foi a partir do fonte LOJC060

Default nQtdade 	:= 1 
Default cTabPadIn	:= IIF(nModulo == 23,cMV_TABPAD,Lj7DefTab())
                            
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³SigaPhoto e produto for uma revelacao, o valor unitario |
//³vira das funcoes especificas do SigaPhoto.              |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If nModulo == 72
	nPosVlUnit	:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_VRUNIT"})][2]
	nPosEnvelo	:= Ascan(aPosCpoDet, { |x| Upper (Alltrim (x[1])) == "LR_ENVELO"})
	
	If SB1->(FieldPos("B1_ESPECIF")) > 0  .AND. nPosEnvelo > 0
		If ALLTRIM(SB1->B1_ESPECIF) == "R"
			nRet := aCols[n][nPosVlUnit]
		EndIf
	Else
		Conout(STR0010) //"Para utilização do modulo SIGAPHOTO é necessario a criação dos campos B1_ESPECIF e LR_ENVELO."
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica preço do produto de Garantia ou Serviço.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nRet == 0 
	If laPosCpo .AND. lGE .AND. (nModulo == 12) .AND. (SB1->B1_TIPO == cMvLjTGar)
		nRet   := Lj7ImpVlr(cProduto,NIL,NIL, cCliente, cLoja, nMoeda) 				          
	ElseIf laPosCpo .AND. lSFinanc .AND. (nModulo == 12) .AND. (SB1->B1_TIPO == cMvLjTSF)
		MG8->(DbSetOrder(2))
		 
		If (MG8->(DbSeek(xFilial("MG8")+cProduto)) .AND. MG8->MG8_TPXPRD == "1")
			nPosQuant	:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_QUANT"})][2]	// Posicao da Quantidade
			nPosVlUnit	:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_VRUNIT"})][2]	// Posicao do Valor unitario do item
			nPosProd	:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_PRODUTO"})][2]	// Posicao do Codigo do Produto
			nPosItCob	:= IIf(SLR->(FieldPos("LR_ITEMCOB")) > 0, aScan(aPosCpo,{|x| Upper(Alltrim(x[1])) == "LR_ITEMCOB"}) ,0)
					
			//Servico financeiro - Carrega Preco									
			If aCols[n][nPosVlUnit] == 0 .AND. nPosItCob > 0 .AND. !Empty(aCols[n][nPosItCob]) 				 				
				nRet:= LjSfVl(cProduto,0,aCols[Val(aCols[n][nPosItCob])][nPosVlUnit], @aRet, .F., aCols[Val(aCols[n][nPosItCob])][nPosProd])				
			Else
				nRet:= aCols[n][nPosVlUnit]*aCols[n][nPosQuant]
			EndIf					
		EndIf						          
	EndIf
	
	If nRet == 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica o se esta ativo o Cenario de Vendas³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lCenVenda	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Considerada sempre a quantidade 1                           ³
			//³retorna o valor convertido pela moeda da tabela de preco DA1³
			//³se nao encontrar tabela de preco, retorna valor do B0_PRN   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cMvLjRetVl == "3"
				nRet := GetMaTabPr(cTabPad, cProduto, 1, cCliente, cLoja, nMoeda)
			EndIf						
			
			If cMvLjRetVl <> "3" .OR. nRet == 0
				nRet := GetMaTabPr(cTabPrecos, cProduto, 1, cCliente, cLoja, nMoeda)
			EndIf		
		Else                      
			nRet := GetAdvFVal("SB0", "B0_PRV" + cTabPadIn, xFilial("SB0") + cProduto, 1, 0)
		EndIf 
	   

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Apos verificar a variavel estatica, analisa se existe mais de ³
		//³uma tabela de preco ativa. Agora, verifica no MaTabPrVen      ³
		//³se existe preco para esse produto                             ³
		// Chama a função ljFilTab para filtrar e processar somente as
		// ativas. Havia situações onde havia 300 tabelas de preco, mas apenas
		// 20 ativas, o que gerava demora na busca do preço
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lCenVenda .And. !lLJ7108
			If Len(aTabelas) > 0
				aTabXPreco := aClone(aTabelas)
				ljFilTab(@aTabXPreco,cProduto,nQtdade)
			EndIf
			
			For nX := 1 To Len(aTabXPreco)
				nRet := GetMaTabPr(aTabXPreco[nX], cProduto, nQtdade, cCliente, cLoja, nMoeda)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Armazena no array aValores os possiveis valores para ser ³
				//³praticado para um produto. Esse array sera utilizado para³
				//³avaliar, caso o produto pertenca a mais de uma tabela de ³
				//³preco, para saber qual sera praticada.                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nRet > 0
					aAdd(aValores,nRet)
				EndIf
			Next nX	
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Sendo o aValores maior que um, significa que existe mais de ³
			//³um preco possivel para um unico produto na venda            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Len(aValores) > 0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Retornando os valores, ordena do menor para o maior para ³
				//³ser tomada a decisao posteriormente                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aSort(aValores)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica o parametro MV_LJRETVL e caso esteja "1"      ³
				//³signiifca que utilizara o menor preco encontrado. Caso ³
				//³contrario, utiliza o maior preco.                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cMvLjRetVl == "1"
					nRet := aValores[1]
				Else
					nRet := aValores[Len(aValores)]	  				
				EndIf
			EndIf
		EndIf
	
	EndIf 
Else                                                      
	nRet := Posicione("SB0",1,xFilial("SB0")+cProduto,"SB0->B0_PRV"+cTabPadIn) 
EndIf

Return nRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjxeValPreºAutor	³Vendas CRM			 º Data ³  30/10/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida se a tabela de preco existe e se o valor e maior	  º±±
±±º          ³do que zero.                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1: Codigo da tabela de preco padrao                     º±±
±±º          ³ExpC2: Codigo do Produto                                    º±±
±±º          ³ExpC3: Codigo do Cliente                                    º±±
±±º          ³ExpC4: Codigo da Loja                                   	  º±±
±±º          ³ExpN5: Moeda                                                º±±
±±º          ³ExpN6: Quantidade do Item                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ExpL1: Retorno logico para a validacao do preco             º±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjxeValPre(nPrecoTab, cProduto, cCliente, cLoja,;
					nMoeda   , nQtdade , lProdON, nValIpiEC, ;
					lTabIPI)

Local lRet 			:= .T.  	// Variavel de retorno
Local aArea			:= {}		// Armazena area atual (alias, order e recno)
Local aAreaDA0		:= {}		// Armazena area do DA0 (alias, order e recno)
Local cTabPrecos    := ""		// Parametro da tabela de preco padrao
Local lFtvdVer12	:= LjFTVD() // Verficar se a chamada foi realizada pelo Venda Direta
Local cMsgPdZero 	:= ""  		// Mensagem a ser apresentada qdo. produto estiver com preco zerado
Local lECommerce 	:= lMVLJECOMM .And. LJ862ECAuto() //Funcao auto pela Exportacao.
Local lECCia		:= lMVLJECOMM .And. SuperGetMV("MV_LJECOMO",,.F.) .AND. Lj901Auto()
Local aAreaSB1		:= {}
Local aAreaSF4		:= {}
Local nValIPIEn    	:= 0    
Local cTabPad		:= ""
Local nIteracao 	:= 1     
Local lAutoExC		:= IsBlind() .OR. If(Type("lAutoExec") == "L", lAutoExec, .F.)
Local aAreaSB1B		:= {}
Local dDataSB0		:= Ctod(Space(08))	// Guarda o campo SB0->B0_DATAX

Default nPrecoTab 	:= 0
Default cProduto    := ""
Default cCliente	:= cMV_CLIPAD
Default cLoja		:= cMV_LOJAPAD
Default nMoeda		:= 1
Default nQtdade 	:= 1
DEFAULT lProdON 	:= .F.   
DEFAULT nValIpiEC	:= 0 
DEFAULT lTabIPI		:= .F.

// Não deve validar tabela de preço quando integração EAI
// Pois deve respeitar o preco recebido
If IsInCallStack("LOJI701")
	Return .T.
EndIf

aArea		:= GetArea()
cTabPrecos  := LjXETabPre(cCliente,cLoja) 

If lCenVenda
       	
	aAreaDA0 := DA0->(GetArea())
	
	DbSelectArea("DA1")
	DA1->(DbSetOrder(1))  //DA1_FILIAL+DA1_CODTAB  

	If DA1->(DbSeek(xFilial("DA1")+cTabPrecos))          	
        If lECCia
        
        	lRet := Lj901APrc( @nPrecoTab)
			LjGrvLog("", "Validando preço Cenario de Vendas " + cValToChar(nPrecoTab) + " Retorno " + cValToChar(lRet))

		ElseIf (lNovRegDesc .And. nModulo <> 23)

			// Se o produto for garantia e houver faixa de preco 
			If SB1->B1_TIPO == cMvLjTGar
				nPrecoTab := LjxeTPreco(cProduto, cCliente, cLoja, nMoeda, nQtdade, cTabPrecos) 
			Endif	

			If nPrecoTab == 0
				nPrecoTab := RGDesIteVlProd(cProduto, , ,cCliente, cLoja)
			EndIf 
			
			//Se não atender nenhuma condição e o lLjCnVB0 estiver configurado para buscar o preço na tabela SB0    
			If lLjCnVB0 .AND. nPrecoTab == 0
				nPrecoTab := LjPrecoSB0(cProduto)
			EndIf 

			If nPrecoTab == 0 
				nPrecoTab := LjxeTPreco(cProduto, cCliente, cLoja, nMoeda, nQtdade, cTabPrecos) 
			EndIf

			If nPrecoTab == 0 
				//STR0011 - "Para regra de desconto ser aplicada, deve constar o produto "
				//STR0012 - " na tabela de preço: "
				If !lAutoExC					
					MsgAlert(STR0011 + cProduto + CRLF + STR0012 + cTabPrecos)						
				Else
					Help( " ", 1, "Help",, STR0011 + cProduto + STR0012 + cTabPrecos, 1, 0 )	
				EndIf				
				lRet := .F.
			EndIf			
		Else
			If nQtdade == 0
				nQtdade := 1
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Realiza a busca do preco do produto na Tabela de Precos³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ               
			nPrecoTab := LjXETPreco(cProduto, cCliente, cLoja, nMoeda, nQtdade, cTabPrecos)

			//Se não atender nenhuma condição e o lLjCnVB0 estiver configurado para buscar o preço na tabela SB0    
			If lLjCnVB0 .AND. nPrecoTab == 0
				nPrecoTab := LjPrecoSB0(cProduto)
			EndIf 
	
		  	If nPrecoTab == 0 
				//"Preço do produto zerado ou não cadastrado na tabela de preços "
				cMsgPdZero := STR0007 + If(cMvLjRetVl=="3",cTabPrecos,"")
				
				If !lAutoExC					
					MsgAlert(cMsgPdZero)					
				Else
					Help( " ", 1, "Help",, cMsgPdZero, 1, 0 )	
				EndIf				
				lRet := .F.
			EndIf
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Caso o preco retorne zero, atualiza o valor default de ³
			//³acordo com o produto cadastro                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nPrecoTab == 0 .AND. nModulo == 23
				DbSelectArea("SBI")
				DbSetOrder(1)
				If DbSeek(xFilial("SBI")+cProduto)
					nPrecoTab := SBI->BI_PRV
				EndIf
			ElseIf nPrecoTab == 0 .AND. (nModulo == 12 .OR. nModulo == 72)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifica se retorna o valor default do SB1 (conforme range³
					//³a regra do Cenario de Vendas), ou do SB0                  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lLjCnVB0
						DbSelectArea("SB0") 
						DbSetOrder(1)
						If DbSeek(xFilial("SB0")+cProduto)
							If  lECommerce
								cTabPrecos := AllTrim(SuperGetMV("MV_LJECOMT",,cMV_TABPAD))
								nPrecoTab  := SB0->(&("B0_PRV"+AllTrim(cTabPrecos)))
							Else
								nPrecoTab := SB0->B0_PRV1
							EndIf	
						EndIf
					Else
						DbSelectArea("SB1") 
						DbSetOrder(1)
						If MsSeek(xFilial("SB1")+cProduto)
							nPrecoTab := SB1->B1_PRV1
						EndIf						
					EndIf 
			EndIf
		EndIf
	Else  
		//Se não atender nenhuma condição e o lLjCnVB0 estiver configurado para buscar o preço na tabela SB0    	
		If lLjCnVB0 .AND. nPrecoTab == 0
			nPrecoTab := LjPrecoSB0(cProduto)
		Endif	

		If nPrecoTab == 0
			If !lAutoExC
				MsgAlert(STR0001) //"Tabela de preco invalida no parametro MV_TABPAD"
			Else 
				ConOut(STR0001)//"Tabela de preco invalida no parametro MV_TABPAD"
				Help( " ", 1, "Help",, STR0001, 1, 0 )			
			EndIf
			lRet := .F.
		EndIf 	
    EndIf  

	If nPrecoTab == 0 .And. Empty(cMsgPdZero)
		//"Preço do produto zerado ou não cadastrado na tabela de preços "
		cMsgPdZero := STR0007 + If(cMvLjRetVl=="3",cTabPrecos,"")
		If !lAutoExC
			MsgAlert(cMsgPdZero)
		Else
			ConOut(cMsgPdZero)
			Help( " ", 1, "Help",, cMsgPdZero, 1, 0 )
		EndIf
		lRet := .F.
	EndIf		  

	RestArea(aAreaDA0)		

Else            
	If (nModulo <> 23 .AND. !IsInCallStack("Crd240Criterio") .AND. !IsInCallStack("Frt080Prod") .AND. !lFtvdVer12) .OR. ;
		(nModulo <> 23 .AND. !IsInCallStack("Crd240Criterio") .AND. lFtvdVer12)
			
		//Faz 2 iteracoes para tentar buscar o preco do produto.
		//A primeira vez tenta buscar o preço considerando a tabela selecionado pelo usuario na tela caso ele altera a tabela de preco através das teclas [Ctrl + C] 
		//Na segunda vez tenta buscar o preço considerando a tabela padrao MV_TABPAD
		While nIteracao <= 2
					
			If lECCia
        		lRet := Lj901APrc( @nPrecoTab)
        		LjGrvLog("", "Validando preço sem cenário de vendas 1 " + cValToChar(nPrecoTab) + " Retorno " + cValToChar(lRet))        		       		
        		Exit
        	EndIf
			
			DbSelectArea( "SB0" )
			DbSetOrder( 1 )  
			
	        If lTabIPI 
	        	cTabPad := AllTrim(SuperGetMV("MV_LJECOMT",,cMV_TABPAD))
	        Else
	        	If nIteracao == 2
	        		cTabPad := cMV_TABPAD
	        	Else
					cTabPad := Lj7DefTab()
	        	EndIf
	        EndIf
			
			If SB0->(FieldPos("B0_PRV" + cTabPad)) > 0		
				dDataSB0 := Posicione("SB0",1,xFilial("SB0")+cProduto,"SB0->B0_DATA"+cTabPad) 
				If !lCenVenda .AND. lRet .AND. SB0->(FieldPos("B0_DATA" + cTabPad)) > 0 .AND.;
					!Empty(dDataSB0) .AND. (dDataSB0 < dDataBase)
					If !lAutoExC
						Help("", 1, STR0013,,;    // "ForaPrazo"
									STR0014 + cTabPad + STR0015 + cTabPad + " " + Dtoc(&("SB0->B0_DATA"+ cTabPad)) +")." + CHR(10)+CHR(13), 1, 0,,,,,;  // "Este Produto está configurado com o campo Data de Promoção " + # + " vencido (Tabela "
								,{STR0016 + cTabPad + STR0017 + cTabPad + STR0018} )   //"Será necessário selecionar outra Tabela de Preços ou configurar o campo Promoção " # ") novamente, com uma data válida."

						If MsgYesNo("Deseja prosseguir e informar uma outra Tabela de Preço?", "Atenção")					
							aAreaSB1B := SB1->(GetArea())
							lRet := LJ7TABELA(cProduto)
							RestArea(aAreaSB1B)	
							cTabPad := Lj7DefTab()
							If lRet
								MsgAlert(STR0019 + cTabPad + " ) "+ STR0020 ,;  //"A Tabela de Preços(Tabela: " + # + " ) " + " será a Tabela de Preços Vigente para os próximos Itens."
								STR0021 + "!!!")  // "Atenção!!!"
							EndIf								
						Else
							lRet := .F.
						EndIf	
					EndIf
				EndIf					
				If lRet	
					nPrecoTab := LjXETPreco(cProduto, cCliente, cLoja, nMoeda, Nil, cTabPad) 
				EndIf	
			Else         
				If !lAutoExC
					MsgAlert(STR0001) //"Tabela de preco invalida no parametro MV_TABPAD"
				Else
					Help( " ", 1, "Help",, STR0001, 1, 0 )
				EndIf
				lRet := .F.
				Exit
			EndIf
	
			If lRet .And. nPrecoTab == 0
				DbSelectArea("SB0")
				DbSetOrder(1)
				If !(DbSeek( xFilial("SB0") + cProduto) )
					Help( " ", 1, "NOPRECO" )
					lRet := .F.
					Exit
			        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			        //³Valida para alguns estados se aceita produto sem preco³
			        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Else
					If LjAnalisaLeg(2)[1] .AND. lRet .AND. &("SB0->B0_PRV"+ cTabPad) == 0 
						If !LjProdGar(cProduto,cTabPad) // verifica se a garantia, caso sim,cadastra o preco e libera
							If nIteracao == 2												
						    	LjMsgLeg(LjAnalisaLeg(2))	   
						    	lRet := .F.
						    Else
								nIteracao++
								Loop
						    EndIf
		                EndIf
					Else
						Exit
					EndIf
				EndIf
			Else
				Exit
			EndIf
		
		End
		
	Else
		If nModulo = 12
			DbSelectArea("SB1")
			SB1->( DbSetOrder(1) )	//B1_FILIAL + B1_COD
			If SB1->( DbSeek(xFilial("SB1") + cProduto) )
				If lECCia
        
        			lRet := Lj901APrc( @nPrecoTab)
        			LjGrvLog("", "Validando preço sem cenário de vendas 2 " + cValToChar(nPrecoTab) + " Retorno " + cValToChar(lRet))
				
				ElseIf  lECommerce .AND. !lECCia  //Obter o preco da Tabela e-Commerce
				    SB0->( DbSetOrder(1) )  //B0_FILIAL+B0_COD
				    If  SB0->( DbSeek(xFilial("SB0")+cProduto) )
						cTabPrecos := AllTrim(SuperGetMV("MV_LJECOMT",,cMV_TABPAD))
						nPrecoTab  := SB0->(&("B0_PRV"+AllTrim(cTabPrecos)))
					EndIf	
				Else
					nPrecoTab := SB1->B1_PRV1
					If nPrecoTab == 0
					    nPrecoTab := LjGetB0Prv(cProduto, cTabPrecos)
					EndIf
				EndIf	
			EndIf
		Else
			lProdON := lProdON .Or. SuperGetMV("MV_LJPRDON", ,.F.)
			DbSelectArea("SBI")
			DbSetOrder(1)
			If DbSeek(xFilial("SBI")+cProduto)
				nPrecoTab := SBI->BI_PRV
			ElseIf nModulo == 23 .And. lProdON	//Verifica se esta ativa no Front, a Consulta on-line de Produtos direto na retaguarda
				cTabPrecos := AllTrim(cMV_TABPAD)
				DbSelectArea("SB0")
				DbSetOrder(1)
				If DbSeek(xFilial("SB0")+cProduto)
					If  lECommerce //Obter o preca da Tabela e-Commerce
						cTabPrecos := AllTrim(SuperGetMV("MV_LJECOMT",,cMV_TABPAD))
						nPrecoTab  := SB0->(&("B0_PRV"+AllTrim(cTabPrecos)))
					Else
						nPrecoTab := SB0->(&("B0_PRV"+AllTrim(cTabPrecos))) 
					EndIf	
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

If ( nPrecoTab > 0 .And. ( (lECommerce .and. SuperGetMV("MV_LJIPENP",, .F.) .AND. !lECCia)  .Or. lTabIPI)) .And. !IsInCallStack("LJ861JBPC")
	aAreaSB1 := SB1->(GetArea())                                                                                                                                         
	
		If SB1->(DbSeek(xFilial("SB1")+cProduto ) ) .AND. SB1->B1_IPI > 0 
			//Busca na TES de pedido se está sinalizado para calcular IPI				
			aAreaSF4 := SF4->(GetArea())
			//Busca a TES do Item		 				
			   
			SF4->(DbSetOrder(1)	)
			If SF4->(DbSeek(xFilial("SF4") + SuperGetMV("MV_LJTESPE", NIL, "501") ))  .AND. SF4->(!Empty(F4_IPI) .AND. F4_IPI <> "N") 

				//Abate o IPI do Preco Cheio do Produto
           						
        			nValIPIEn := ljfnEGetIpi(nPrecoTab, SLR->(TamSX3("LR_VALIPI")[2]), SuperGetMV("MV_RNDIPI",,.F.))
        			
        			nPrecoTab -=  nValIPIEn
					
					nValIpiEC :=  nValIPIEn								
			
			EndIf				
			
			RestArea(aAreaSF4)   
			
		EndIf			
	RestArea(aAreaSB1)	
	
EndIf   

RestArea(aArea)
	
Return lRet

/*/{Protheus.doc} LjPrecoSB0
	Funcao para retornar o preço dos produtos da tabela SB0
	@author SIGALOJA
	@since date 05/05/2020
	@version P12.1.25
	@param Codigo do Produto
	@return Preço do Produto
/*/
 Function LjPrecoSB0(cProduto)
Local lECommerce 	:= lMVLJECOMM .And. LJ862ECAuto() //Funcao auto pela Exportacao.
Local cTabPrecos	:= ""
Local nPrecoTab		:= 0

DbSelectArea("SB0") 
DbSetOrder(1)
If DbSeek(xFilial("SB0")+cProduto)
	If  lECommerce
		cTabPrecos := AllTrim(SuperGetMV("MV_LJECOMT",,cMV_TABPAD))
		nPrecoTab  := SB0->(&("B0_PRV"+AllTrim(cTabPrecos)))
	Else
		nPrecoTab := SB0->B0_PRV1
	EndIf	
EndIf
Return(nPrecoTab)

//==============================================================================
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjxeRBonusºAutor  ³Vendas CRM          º Data ³  05/11/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Encapsulamento da funcao de regra de descontos do cenario deº±±
±±º          ³vendas                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpA1: aCols da GetDados                                    º±±
±±º          ³ExpA2: [1] Posicao do codigo do produto                     º±±
±±º          ³       [2] Posicao da Quantidade                            º±±
±±º          ³       [3] Posicao da TES                                   º±±
±±º          ³ExpC3: Cliente                                              º±±
±±º          ³ExpC4: Loja                                                 º±±
±±º          ³ExpC5: Tabela                                               º±±
±±º          ³ExpC6: Condicao de Pagamento                                º±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±± 
±±ºRetorno   ³ExpA1: Array com a seguinte estrutura:                      º±± 
±±º          ³       [1] Codigo do Produto                                º±± 
±±º          ³       [2] Quantidade                                       º±± 
±±º          ³       [3] TES                                              º±± 
±±º          ³       [4] Regra aplicada                                   º±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±± 
±±ºUso       ³SIGALOJA                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjxeRBonus(aPar1,aPar2,cCliente,cLoja,cTabPreco,cCondPg)

Local aArea	:= GetArea()
Local aRet	:= {}

aRet := FtRgrBonus(aPar1,aPar2,cCliente,cLoja,cTabPreco,cCondPg,/*cFormPg*/,/*aRecACQ*/)

RestArea(aArea)

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjTelaBon ºAutor  ³Vendas CRM          º Data ³  18/11/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Apresenta a tela com os produtos bonificados para conferen- º±±
±±º          ³cia do caixa.                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpA1: Lista dos produtos bonificados                       º±±
±±º          ³       1 - Codigo do produto                                º±±
±±º          ³       2 - Descricao do produto                             º±±
±±º          ³       3 - Quantidade bonificada                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGALOJA                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjTelaBon(aBonus)

Local aArea		:= GetArea()				// Armazena o posicionamento atual do alias corrente
Local aAreaPRD	:= {}						// Armazena o posicionamento atual do alias de produtos
Local aLbx 		:= {}						// Array associado ao ListBox
Local nX		:= 0						// Auxiliar de Loop
Local cFilPRD	:= ""						// Codigo da filial corrente
Local cCpoDesc	:= ""						// Nome do campo que contem a descricao
Local cAliasPRD	:= ""						// Alias da tabela de produtos
Local oDlg		:= Nil						// Objeto da tela
Local oLbx		:= Nil						// Objeto do ListBox
Local oOk 		:= Nil						// Objeto do botao OK
Local oFont1	:= Nil						// Objeto da fonte do dialog

If Len(aBonus) == 0
	Return Nil
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define qual tabela contem dados do produto de acordo com³
//³o modulo utilizado                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nModulo == 23
	cAliasPRD	:= "SBI"
	cCpoDesc	:= "BI_DESC"
Else
	cAliasPRD	:= "SB1"
	cCpoDesc	:= "B1_DESC"
EndIf

aAreaPRD	:= (cAliasPRD)->(GetArea())
cFilPRD		:= xFilial(cAliasPRD)

(cAliasPRD)->(DbSetOrder(1))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta a lista de produtos exibidos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to Len(aBonus)
	(cAliasPRD)->(DbSeek(cFilPRD+aBonus[nX][1]))
	Aadd(aLbx,{	AllTrim(aBonus[nX][1]),;
				AllTrim(Capital((cAliasPRD)->&(cCpoDesc))),;
				Transform(aBonus[nX][2],X3Picture('L2_QUANT'))})
Next nX	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da interface³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE FONT oFont1 NAME "Arial" SIZE 10,17 BOLD

DEFINE MSDIALOG oDlg TITLE STR0002 FROM 0,0 TO 328,386 PIXEL //"Bonificação"

	@ 004,004 Say STR0003 Size 179,012 COLOR CLR_BLUE PIXEL OF oDlg FONT oFont1	//"Produtos bonificados para esta venda:"

	@ 017,004 TO 147,191 LABEL "" PIXEL OF oDlg

	@ 025,009 ListBox oLbx Fields HEADER STR0004,STR0005,STR0006 COLSIZES 25,25,15 Size 177,115 Of oDlg Pixel //"Produto"###"Descrição"###"Quantidade"

	oLbx:SetArray(aLbx)
	oLbx:bLine	:= {||{	aLbx[oLbx:nAT,01],;
						aLbx[oLbx:nAT,02],;
						aLbx[oLbx:nAT,03]}}

	DEFINE SBUTTON oOk FROM 150,164 TYPE 1 Action(oDlg:End()) ENABLE OF oDlg
	oOk:SetFocus()

ACTIVATE MSDIALOG oDlg CENTERED

RestArea(aAreaPRD)
RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjOpcDesc ºAutor  ³Vendas CRM          º Data ³  27/03/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se o caixa pode conceder descontos quando o cenarioº±±
±±º          ³de vendas esta ativo                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGALOJA                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjOpcDesc(cCaixa)

Local lRet		:= .T.
Local aArea		:= GetArea()
Local aAreaSLF	:= SLF->(GetArea())

Default cCaixa 	:= cNumCaixa

If lCenVenda

	DbSelectArea("SLF")
	SLF->(DbSetOrder(1)) //LF_FILIAL+LF_COD  
	
	If SLF->(MsSeek(xFilial("SLF")+cCaixa))
		lRet := SLF->LF_OPCDESC <> 1 
	EndIf

EndIf

RestArea(aAreaSLF)
RestArea(aArea)

Return lRet
                  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjXEMoeda ºAutor  ³Vendas CRM          º Data ³  27/03/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega a moeda 											  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGALOJA                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//
Function LjXEMoeda(cProduto, nQtde, cCliente, cLoja)
Local nRet 		:=  1

	If lCenVenda	                
		//nRet	:= DA1->DA1_MOEDA		
	Else
		nRet	:=	Max(&("SB0->B0_MOEDA" + Lj7DefTab()),1)
	EndIf

Return nRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ7Bonus  ºAutor  ³Vendas CRM          º Data ³  05/11/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Executa o processamento das regras de bonificacao do cena-  º±±
±±º          ³rio de vendas                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJA701                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJ7Bonus(nOpc,lTefPendCS,aTefBKPCS,aBonus)

Local aArea		:= GetArea()	   		 							// Armazena o posicionamento atual
Local nX		:= 0			   		 							// Auxiliar de loop 
Local aColsBon	:= {}					  							// aCols enviado a funcao de regra de descontos
Local aPosCpos	:= {1,2,3}											// Posicao dos campos codigo, quant. e TES no aColsBon
Local nPItem	:= aScan(aHeader,{|x|AllTrim(x[2])=="LR_ITEM"})	// Posicao do campo Item
Local nPProduto	:= aScan(aHeader,{|x|AllTrim(x[2])=="LR_PRODUTO"})	// Posicao do campo Codigo
Local nPQuant	:= aScan(aHeader,{|x|AllTrim(x[2])=="LR_QUANT"})	// Posicao do campo Quantidade
Local nPTotItem	:= aScan(aHeader,{|x|AllTrim(x[2])=="LR_VLRITEM"})	// Posicao do campo Total do item
Local nPTES		:= aScan(aHeaderDet,{|x|AllTrim(x[2])=="LR_TES"})	// Posicao do campo TES
Local nPos		:= 0												// Indice de pesquisa no aColsBon
Local cCondPg	:= M->LQ_CONDPG										// Condicao de pagamento utilizada
Local cTabPreco	:= LjXETabPre(M->LQ_CLIENTE,M->LQ_LOJA)			// Tabela de precos utilizada
Local nTamItem	:= TamSX3("LR_ITEM")[1]								// Tamanho do campo LR_ITEM
Local cItem		:= StrZero(0,nTamItem)								// Item do aCols para controle dos novos itens
Local cCampo	:= ""												// Nome do campo do aCols
Local cBkReadVar:= __ReadVar										// Backup da variavel __ReadVar
Local nValDesc	:= 0												// Valor de desconto do item
Local cTesOri	:= ""												// TES original do produto
Local nAnt		:= N												// Armazena em qual linha a getdados estava posicionada
Local nValDscAnt:= Lj7T_DescV(2)									// Valor do desconto atual aplicado ao total da venda
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Sintetiza os produtos validos em um acols simplificado para a³
//³rotina de regra de bonificacao                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to Len(aCols)
	If !aTail(aCols[nX]) .AND. !Empty(aCols[nX][nPProduto])
		If (nPos:= aScan(aColsBon,{|x|x[1] == aCols[nX][nPProduto] .AND. x[3] == aColsDet[nX][nPTES]})) == 0
			AAdd(aColsBon,{aCols[nX][nPProduto],aCols[nX][nPQuant],aColsDet[nX][nPTES],.F.})
		Else
			aColsBon[nPos][2] += aCols[nX][nPQuant]
		EndIf
	EndIf
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processa a regra de bonificacao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aColsBon) > 0
	aBonus	:= LjxeRBonus(aColsBon,aPosCpos,M->LQ_CLIENTE,M->LQ_LOJA,cTabPreco,cCondPg)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se nao houver bonus, aborta o processamento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aBonus) == 0
	RestArea(aArea)
	Return .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica qual o maior item da venda³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to Len(aCols)
	If aCols[nX][nPItem] > cItem
		cItem := aCols[nX][nPItem]
	EndIf
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³'Clona' uma linha em branco do aCols, limpando seus valores.   ³
//³Esta linha sera usada para referencia ao adicionar novos itens.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aLinRef	:= aClone(aCols[1])

For nX := 1 to Len(aHeader)  

	cCampo	:= AllTrim(aHeader[nX][2])
	
	If !(cCampo $ "L2_REC_WT/L2_ALI_WT")
		aLinRef[nX] := CriaVar(cCampo,.F.)
	ElseIf cCampo == "L2_ALI_WT"
		aLinRef[nX] := "SL2"
	ElseIf cCampo == "L2_REC_WT"
		aLinRef[nX] := 0
	EndIf      
	
Next nX

//Limpa a marca de linha deletada
aLinRef[Len(aHeader)+1] := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Adiciona os produtos bonificados na venda³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to Len(aBonus)

	cItem := Soma1(cItem)
	
	AAdd(aCols,aClone(aLinRef)) 
	
	N := Len(aCols)     
	
	oGetVA:oBrowse:nAt := N
	oGetVA:oBrowse:Refresh()
	
	aCols[N][nPItem]	:= cItem

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processa a acao de digitacao do campo quantidade³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCols[N][nPQuant]	:= aBonus[nX][2]
	M->LR_QUANT			:= aBonus[nX][2]
	__ReadVar			:= "M->LR_QUANT" 
	
	Lj7VlItem( 1 , .T. )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processa a acao de digitacao do campo quantidade³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	aCols[N][nPProduto]	:= aBonus[nX][1]	
	M->LR_PRODUTO		:= aBonus[nX][1]
	__ReadVar			:= "M->LR_PRODUTO" 
	
	Lj7Prod(,.T.)

	//----------------------------------
	// Ajusta a TES do produto
	// aBonus[nX][3] - Valor retornado da função FtRgrBonus
	// aBonus[nX][3] - Código da TES configurada no parâmetro MV_BONUSTS
	If ValType(aBonus[nX][3]) == "C"
		aColsDet[n][nPTES] 	:= aBonus[nX][3] 
		cTesOri				:= aColsDet[n][nPTES] 
	EndIf	
	
	If cPaisLoc <> "MEX"
		Lj7AltTes(aBonus[nX][3], @lTefPendCS, @aTefBKPCS)
	EndIf

	If cPaisLoc <> "BRA" .AND. cTesOri <> aColsDet[n][nPTES]
		Lj7RecalImp(n,2,"IT_TES",Nil,cTesOri)
	EndIf
	
	//Tratar totalizacao para desconto no total
	nValDesc	+= aCols[N][nPTotItem]

Next nX

oGetVA:oBrowse:Refresh()

If nValDesc > 0
	LJ7VldDesc( Nil, Nil, nValDesc + nValDscAnt, Nil , .T. )
EndIf

__ReadVar	:= cBkReadVar 

N := nAnt
oGetVa:oBrowse:nAt := N
oGetVa:oBrowse:Refresh()

RestArea(aArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjXETabPreºAutor  ³Microsiga           º Data ³  07/01/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna a tabela de precos utilizada para o cliente         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - Codigo do cliente                                   º±±
±±º          ³ExpC2 - Loja do cliente                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJXFUNE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjXETabPre(cCliente,cLoja)

Local aArea			:= {}		// Posicionamento atual
Local aAreaSA1		:= {}		// Posicionamento atual da SA1
Local aAreaDA0		:= {}		// Posicionamento atual da SA1
Local cTabRet		:= ""		// Parametro da tabela de preco padrao
Local lTabEspCli	:= .F.		// Indica se utiliza a tabela do cliente  
Local lECCia		:= lMVLJECOMM .And. SuperGetMV("MV_LJECOMO",,.F.) .AND. ( IsInCallStack("LOJA901A") )//Funcao auto pela Exportacao.
Local cChvCtrlPE 	:= "" 		// Chave de Controle para execução do PE LJ7108
Local nPosCtrlPE	:= 0
Local cRetLJ7108	:= Nil
Local nPosCpoIte 	:= 0
Local nPosCpoPrd 	:= 0
Local nPosCpoTab 	:= 0
Local cItem 		:= ""
Local cCodProd		:= ""
Local lLRTABELA		:= IsInCallStack("Lj7LinOk") .Or. IsInCallStack("Lj7PrepDel") //Se a chamada é da troca de linha da Getdados ou deleção do item, considera a tabela do item

Default cCliente 	:= ""
Default cLoja		:= ""

If lECCia  .And. ValType( M->LQ_TABELA ) == "C"
	cTabRet :=  M->LQ_TABELA
Else
	// Otimiza busca, retornando o valor ja conhecido
	If lLRTABELA .And. Type("aPosCpoDet") == "A" .And. Type("aColsDet") == "A"
		nPosCpoTab 	:= Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_TABELA"})
		cTabRet 	:= aColsDet[n][nPosCpoTab]
	EndIf
	
	If Empty(cTabRet)
		lLRTABELA := .F.
		// Otimiza busca, retornando o valor ja conhecido
		If Len(aUltTab) >= 3 .AND. aUltTab[1] == cCliente .AND. aUltTab[2] == cLoja
			cTabRet := aUltTab[3]
		Else

			cTabRet		:= Pad(cMV_TABPAD,TamSx3("DA0_CODTAB")[1])	 			// Parametro da tabela de preco padrao	
			lTabEspCli	:= SuperGetMv("MV_CONFCLI",,"N")=="S"	// Indica se utiliza a tabela do cliente

			aUltTabCli := {}
			
			//Localiza o cliente se permitir utilizar a tabela definida no cliente (MV_CONFCLI)
			If lCenVenda 
				
				If lTabEspCli

					aArea		:= GetArea()
					aAreaSA1	:= SA1->(Getarea())
					aAreaDA0	:= DA0->(Getarea())
					
					DbSelectArea("SA1")
					SA1->(DbSetOrder(1))
					
					DbSelectArea("DA0")
					DA0->(DbSetOrder(1))

					If SA1->(DbSeek(xFilial("SA1")+cCliente+cLoja)) .AND. !Empty(SA1->A1_TABELA)
						//Localiza a tabela
						If 	DA0->(DbSeek(xFilial("DA0")+SA1->A1_TABELA))
							//Valida a tabela
							If 	(DA0->DA0_ATIVO == "2") .Or.;
								(DA0->DA0_TPHORA == "1" .And. !(SubtHoras(dDataBase,Time(),If(Empty(DA0->DA0_DATATE),dDataBase,DA0->DA0_DATATE),DA0->DA0_HORATE) >= 0 .And.;
								SubtHoras(DA0->DA0_DATDE,DA0->DA0_HORADE,dDataBase,Time()) >= 0)) .Or.;
								(DA0->DA0_TPHORA == "2" .And. !(dDataBase >= DA0->DA0_DATDE .And. dDataBase <= If(Empty(DA0->DA0_DATATE),dDataBase,DA0->DA0_DATATE) .And.;
								(SubStr(Time(),1,5) >= DA0->DA0_HORADE .And. SubStr(Time(),1,5) <= DA0->DA0_HORATE)))
							
								MsgStop(STR0008+" (" + AllTrim(SA1->A1_TABELA) + ") "+STR0009) //"A tabela de preços definida para este cliente"###"está fora de vigência"
							Else
								cTabRet := Pad(SA1->A1_TABELA,TamSx3("DA0_CODTAB")[1])		
								aUltTabCli := {cCliente, cLoja, cTabRet}
							EndIf
						EndIf
					EndIf

					RestArea(aAreaDA0)
					RestArea(aAreaSA1)
					RestArea(aArea)

				EndIf

				If Empty(cTabRet)
					cTabRet	:= cMV_TABPAD
					cTabRet	:= Pad(cTabRet,TamSx3("DA0_CODTAB")[1])
				EndIf
			EndIf

		EndIf
	EndIf
EndIf

If lLJ7108
	If Type("aPosCpo") == "A" .And. !lLRTABELA
		If !IsInCallStack("LOJPESQ") //Verifica se nao foi chamada da tela de pesquisa unificada de produto 
			//Verifica se já foi chamado o PE LJ7108. Caso positivo, somente retorna a mesma informação já retornada anteriormente pelo PE.
			nPosCpoIte 	:= aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_ITEM"})][2]	 // Posicao do item
			nPosCpoPrd 	:= aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_PRODUTO"})][2] // Posicao do Codigo do Produto
			cItem 		:= IIf(Len(aCols)>=n,aCols[n][nPosCpoIte],cItem)
			If "LR_PRODUTO" $ ReadVar()
				cCodProd := M->LR_PRODUTO
			Else
				cCodProd := IIf(Len(aCols)>=n,aCols[n][nPosCpoPrd],cCodProd)
			EndIf
		EndIf

		cChvCtrlPE := xFilial("SL1") + M->LQ_NUM + M->LQ_CLIENTE + M->LQ_LOJA

		//Verifica se ainda é ou não a mesma venda e mesmo cliente
		If Len(aPeLJ7108) > 0 .And. aPeLJ7108[1] == cChvCtrlPE
			//Se encontrar informação já retornada do PE LJ7108 para o mesmo item da venda e produto, apenas retorna o conteúdo para não executar novamente o PE.
			If !Empty(cItem) .And. !Empty(cCodProd) .And. ( nPosCtrlPE := aScan( aPeLJ7108[2], {|x| x[1] == cItem + cCodProd } ) ) > 0
				cRetLJ7108 := aPeLJ7108[2][nPosCtrlPE][2]
				LjGrvLog(M->LQ_NUM,"Considera o retorno do Ponto de Entrada LJ7108 executado anteriormente. Tabela Retornada:", cRetLJ7108)
			EndIf
		Else
			aPeLJ7108 := {cChvCtrlPE, {}}
		EndIf
		
		If cRetLJ7108 == Nil
			LjGrvLog(M->LQ_NUM,"Antes da Chamada do Ponto de Entrada LJ7108. Tabela de preço:", cTabRet)
			cRetLJ7108 := ExecBlock( "LJ7108", .F., .F., {cTabRet, aPosCpo} )
			LjGrvLog(M->LQ_NUM,"Apos a Chamada do Ponto de Entrada LJ7108. Tabela de preço retornada:", cRetLJ7108)
			If !Empty(cItem) .And. !Empty(cCodProd) .And. !Empty(cRetLJ7108)
				aAdd( aPeLJ7108[2], { cItem + cCodProd, cRetLJ7108 } )
			EndIf
		EndIf

		If ValType(cRetLJ7108) == "C"
			cTabRet	:= Pad(cRetLJ7108,TamSx3("DA0_CODTAB")[1])
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Armazena valor retornado para possivel consulta posterior³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aUltTab := {cCliente, cLoja, cTabRet}
LjGrvLog( Nil,"Tabela de preço utilizada:", cTabRet)
Return cTabRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjxFindTabºAutor  ³Microsiga           º Data ³  15/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que valida se existe tabela de preco ativa para o diaº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³NIL                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³NIL                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FRTA271A,                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjxFindTab(cCliente, cLoja)

Local lContinua := .T.	// Se continua a rotina apos validacao do IndexKey() do DA0 
Local cTabClient:= ""
Local cSeekDA0 	:= ""
Local cFilDA0 	:= ""

Default cCliente:= ""
Default cLoja 	:= ""

If Len(aUltTabCli) > 0 .AND. aUltTabCli[1] == cCliente .AND. aUltTabCli[2] == cLoja
	cTabClient := aUltTabCli[3]
ElseIf cMvLjRetVl == "3" //Considera tabela configurada no parametro MV_TABPAD
	lContinua := .F.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se nao existir o indice, retorna o MV_TABPAD³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aTabelas,Pad(cMV_TABPAD,TamSx3("DA0_CODTAB")[1]))
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Existindo o indice "2" realiza as validacoes necessarias³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lContinua
	DbSelectArea("DA0")
	
	cFilDA0 := xFilial("DA0")

	If !Empty(cTabClient)
		//Neste caso foi definida uma tabela especifica configurada para o cliente no campo A1_TABELA
		DA0->(DbSetOrder(1)) //DA0_FILIAL+DA0_CODTAB
		cSeekDA0 := cTabClient
	Else
		DA0->(DbSetOrder(2)) //DA0_FILIAL+DA0_ATIVO+DA0_DATDE+DA0_DATATE
		cSeekDA0 := "1"
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Busca as tabelas ativas ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If DA0->( DbSeek(cFilDA0 + cSeekDA0) )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se existes tabelas ativas para a data atual³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While DA0->( !EOF() ) .AND. DA0->DA0_FILIAL == cFilDA0 .AND. DA0->DA0_ATIVO == "1"
			If (dDataBase >= DA0->DA0_DATDE) .AND. (dDataBase <= If(Empty(DA0->DA0_DATATE),dDataBase,DA0->DA0_DATATE))
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Avalia efetivamente se existe tabela de preco ativa para³
				//³a data e hora atual, considerando se o DA0_TPHORA       ³
				//³eh igual a "1" ou "2"                                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If 	(DA0->DA0_TPHORA == "1" 																					.AND.	;
					(SubtHoras(dDataBase,Time(),If(Empty(DA0->DA0_DATATE),dDataBase,DA0->DA0_DATATE),DA0->DA0_HORATE) >= 0 	.AND.	;
					 SubtHoras(DA0->DA0_DATDE,DA0->DA0_HORADE,dDataBase,Time()) >= 0)) 										.OR.	;
					(DA0->DA0_TPHORA == "2" 																					.AND.	;
					(dDataBase >= DA0->DA0_DATDE .And. dDataBase <= If(Empty(DA0->DA0_DATATE),dDataBase,DA0->DA0_DATATE) 		.AND.	;
					(SubStr(Time(),1,5) >= DA0->DA0_HORADE .And. SubStr(Time(),1,5) <= DA0->DA0_HORATE)))
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se entrou a(s) tabela(s) alimenta o array static³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Aadd(aTabelas,DA0->DA0_CODTAB)
				EndIf
			EndIf
			
			//Neste caso existe uma tabela especifica configurada para o cliente no campo A1_TABELA, entao abandona o laco
			If !Empty(cTabClient)
				Exit
			EndIf
			DA0->(DbSkip())
		End
	EndIf
EndIf

Return NIL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjxClFindTºAutor  ³Microsiga           º Data ³  15/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que limpa o array estatico aTabXPreco e aTabelas     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³NIL                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³NIL                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FRTA271A,                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjxClFindT()
aTabXPreco 	:= {}
aTabelas	:= {}
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjxEMod   ºAutor  ³Vendas CRM          º Data ³  29/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que verifica se a tabela e exclusiva ou compartilhadaº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cTab = Alias da tabela                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³lRet = Retorna .T. para tabela compartilhada                º±±
±±º          ³       Retorna .F. para tabela exclusiva                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJXFUNE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjxEMod(cTab)
Local lRet := .F. //Retorno

Default cTab 	:= ""

//Verifica o modo de acesso por unidade de negócio e filial
If FWModeAccess(cTab,2) == "C" .And. FWModeAccess(cTab,3) == "C"
	lRet := .T.
Else              
	lRet := .F.	
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjxEDtoC   ºAutor  ³Vendas CRM          º Data ³  31/05/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ 																	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³cRet : retorna data transformada em tipo caracter           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJXFUNB                                                    º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjxEDtoC( xValor )
Local cValor := ""

 If ValType(xValor) == "D"
 	cValor :=	Dtos(xValor)
ElseIf ValType(xValor) == "C"
 	If Empty(AllTrim(xValor))
 		cValor := ""
 	Else
 		cValor := Dtos(stod(xValor))
 	EndIf
EndIf

Return cValor

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjxELeCria  ºAutor  ³Vendas CRM          º Data ³  12/04/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cria e le arquivo contando infos ECF							º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³lRet = cria arquivo que guarda informações do ECF           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJXFUNB                                                    º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjxELeCria( lCria , aConteudoTXT)
Local cPathSmart	:= "" 
Local cNomeArq	:= "DTECF.LOJ"
Local nHandleTXT	:= 0
Local nX			:= 0
Local cConteudo	:= ""
Local cVarTXT		:= ""
Local cDadoTXT	:= ""
Local aTXT			:= {}
Local lRet			:= .T.

DEFAULT lCria			:=	.F.
DEFAULT aConteudoTXT	:=	{}

cPathSmart := GetClientDir()

If lCria .AND. Len(aConteudoTXT) > 0	
	If File(cPathSmart + cNomeArq)
		FErase(cPathSmart + cNomeArq)
	EndIf
	nHandleTXT := FCREATE( cPathSmart + "Dado.TXT", FC_NORMAL )
	
	If nHandleTXT < 0
		Conout(" LOJXFUNE -> Erro ao criar arquivo " + cPathSmart + cNomeArq) //"Erro ao criar arquivo "			
	Else
		cConteudo := ""
		For nX := 1 to Len(aConteudoTXT)
			If aConteudoTXT[nX][1] == "PDV" //Campo numerico
				cConteudo += aConteudoTXT[nX][1] + "|" + IIf(empty(AllTrim(aConteudoTXT[nX][2])), "0" ,aConteudoTXT[nX][2]) + CHR(10)	 
			Else
				cConteudo += aConteudoTXT[nX][1] + "|" + IIf(empty(AllTrim(aConteudoTXT[nX][2])), "  " ,aConteudoTXT[nX][2]) + CHR(10)
			EndIf	
		Next nX		
		FWRITE( nHandleTXT, cConteudo, LEN( cConteudo ) )
		FCLOSE( nHandleTXT )
		FRENAME(cPathSmart + "Dado.TXT" ,cPathSmart + cNomeArq)
		FERASE(cPathSmart + "Dado.TXT")
		Conout(" LOJXFUNE - LjxELeCria -> Arquivo " + cPathSmart + cNomeArq + " Gerado com Sucesso")
	EndIf

ElseIf !lCria
	
	aTXT := LjxReadFile( cPathSmart , cNomeArq, 0, .F. ) //Pega conteudo de cFile , no caminho cPathDLLArq com indice 0 e permite a deleção do arquivo 

	If ValType(aTXT) == "A" .AND. Len(aTXT) > 1
		aConteudoTXT := {}
		For nX := 1 To Len(aTXT)
			If !Empty(AllTrim(aTXT[nX]))				
				cVarTXT	:= Substr(aTXT[nX] ,1,At("|",aTXT[nX])-1)
				cDadoTXT	:= Substr(aTXT[nX] ,At("|",aTXT[nX])+1,Len(aTXT[nX]))
				If cVarTXT == "PDV" //Campo numerico
					Aadd( aConteudoTXT , {cVarTXT,Val(cDadoTXT)})
				Else				
					Aadd( aConteudoTXT , {cVarTXT,cDadoTXT} )
				EndIf	
			EndIf							
		Next nX				
	EndIf
EndIf	

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjxER04PDV   ºAutor  ³Vendas CRM          º Data ³  31/05/13º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ 																	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³cRet =  cabeçalho da venda cancelada no PDV                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJXFUNB                                                    º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjxER04PDV(lReducao, cSeriePDV , cMfAdic ,cModelo, nUsuEcf, dDataIni, dDataFim)
Local cConteudo	:=	""
Local cModeloAux	:= cModelo
Local nAcrescimo 	:= 0

DbSelectArea("SA1")
SA1->(DbSetOrder(1))

DbSelectArea("SL1")
SL1->(DbSetOrder(1)) //L1_FILIAL+L1_NUM

DbSelectArea("MDZ")
MDZ->(DbSetOrder(1)) //MDZ_FILIAL+DtoS(MDZ_DATA)
MDZ->(DbSeek(xFilial("MDZ")+DtoS(dDataIni),.T.))
			
While !MDZ->(Eof()) .AND. MDZ->MDZ_FILIAL == xFilial("MDZ") .AND. MDZ->MDZ_DATA <= dDataFim
	If AllTrim(MDZ->MDZ_SIMBOL) == "R4" 
		If (MDZ->MDZ_SITUA == "OK") .AND. !Empty(AllTrim(MDZ->MDZ_TIPO)) .AND. ;
			SL1->(DbSeek(xFilial("SL1")+AllTrim(MDZ->MDZ_TIPO))) //Colocado para armazenar no campo MDZ_TIPO o num do orcamento

			cConteudo += "R04"						 								// 01 - Tipo
			cConteudo += PADR( cSeriePDV , 20 ) 									// 02 - Numero de fabricacao do ECF
			cConteudo += PADR( cMfAdic	 , 01 )	   								// 03 - Letra indicativa de MF adicional
			
			cModeloAux := PADR( cModelo, 20)			// Modelo do ECF				
			nAcrescimo := SL1->L1_VLRTOT - SL1->L1_VALBRUT
			
			cConteudo += cModeloAux										// 04 - Modelo do ECF	
			cConteudo += StrZero( nUsuEcf		   	   	   		, 02 ) // 05 - No. de ordem do usuario do ECF relativo a respectiva Reducao Z 
			cConteudo += StrZero(Val(MDZ->MDZ_CCF) , 06 )				// 06 - CCF, CVC ou CBP, conforme o documento
			cConteudo += StrZero(Val(MDZ->MDZ_COO) , 06 )  			// 07 - COO (Contador de Ordem de Operacao) 
			cConteudo += PADR(DtoS(SL1->L1_EMISSAO)	, 08 ) 	   	// 08 - Data de inicio da emissao 
			cConteudo += StrTran(StrZero(0,15,2),'.')					// 09 - Subtotal do Documento 
			cConteudo += StrTran(StrZero(SL1->L1_DESCONT,14,2),'.')	// 10 - Desconto sobre subtotal 
			cConteudo += PADR( IIf(SL1->L1_DESCONT > 0, "V", " "), 01 )		// 11 - Indicador do Tipo de Desconto sobre subtotal
			cConteudo += StrTran(StrZero(nAcrescimo,14,2),'.')				// 12 - Acrescimo sobre subtotal 
			cConteudo += PADR(IIf(nAcrescimo > 0, "V" , " "), 01 )	   		// 13 - Indicador do Tipo de Acrescimo sobre subtotal 
			cConteudo += StrTran(StrZero(0,15,2),'.')							//14 - Valor Total Liquido
			cConteudo += PADR(If(SL1->L1_STORC == "C","S","N"), 01 ) 		// 15 - Indicador de Cancelamento 
			cConteudo += StrTran(StrZero(0,14,2),'.')							//16 - Cancelamento de Acrescimo no Subtotal 
			cConteudo += PADR( IIf(nAcrescimo > 0, "A" , IIf(SL1->L1_DESCONT > 0, "D", " ")) , 01 )		// 17 - Ordem de aplicacao de Desconto e Acrescimo 
			cConteudo += PADR( MDZ->MDZ_NOMCLI, 40 )					// 18 - Nome do adquirente
			cConteudo += StrZero(Val(MDZ->MDZ_CGCCLI),14)				// 19 - CPF/CNPJ do adquirente
			cConteudo += CHR(13) + CHR(10)
		EndIf	
	EndIf
	MDZ->(DbSkip())
EndDo

//*******************************************************************************************************
//Efetua pesquisa na SL1- caso qdo orçamentos vieram da retaguarda,foram impressos e cancelados no PDV
//*******************************************************************************************************
SL1->(DbSetOrder(4)) //L1_FILIAL+DtoS(L1_EMISSAO)
SL1->(DbSeek(xFilial("SL1")+DtoS(dDataIni),.T.))
While !SL1->(Eof()) .AND. SL1->L1_FILIAL == xFilial("SL1") .AND. SL1->L1_EMISSAO <= dDataFim
	If (SL1->L1_STORC == "C") .AND. !Empty(AllTrim(SL1->L1_NUMORC))
		
		cConteudo += "R04"						 								// 01 - Tipo
		cConteudo += PADR( cSeriePDV , 20 ) 									// 02 - Numero de fabricacao do ECF
		cConteudo += PADR( cMfAdic	 , 01 )	   								// 03 - Letra indicativa de MF adicional			
		
		cModeloAux := PADR( cModelo, 20)			// Modelo do ECF
		nAcrescimo := SL1->L1_VLRTOT - SL1->L1_VALBRUT
		cConteudo += cModeloAux							// 04 - Modelo do ECF	
		cConteudo += StrZero( nUsuEcf		   	   	   		, 02 )	// 05 - No. de ordem do usuario do ECF relativo a respectiva Reducao Z		
		cConteudo += StrZero(Val(SL1->L1_CONTDOC) , 06 )			// 06 - CCF, CVC ou CBP, conforme o documento
		cConteudo += StrZero(Val(SL1->L1_DOC) , 06 )  			// 07 - COO (Contador de Ordem de Operacao) 
		cConteudo += PADR(DtoS(SL1->L1_EMISSAO)	, 08 ) 	   		// 08 - Data de inicio da emissao 
		cConteudo += StrTran(StrZero(SL1->L1_VALBRUT,15,2),'.')	// 09 - Subtotal do Documento 
		cConteudo += StrTran(StrZero(SL1->L1_DESCONT,14,2),'.')	// 10 - Desconto sobre subtotal
		 
		cConteudo += PADR( IIf(SL1->L1_DESCONT > 0, "V", " "), 01 )	   				// 11 - Indicador do Tipo de Desconto sobre subtotal
		cConteudo += StrTran(StrZero(nAcrescimo,14,2),'.')	// 12 - Acrescimo sobre subtotal 
		cConteudo += PADR(IIf(nAcrescimo > 0, "V" , " "), 01 )	   				// 13 - Indicador do Tipo de Acrescimo sobre subtotal 
		cConteudo += StrTran(StrZero(0,15,2),'.')//14 - Valor Total Liquido
		cConteudo += PADR("S", 01 )	     // 15 - Indicador de Cancelamento 
		cConteudo += StrTran(StrZero(0,14,2),'.')//16 - Cancelamento de Acrescimo no Subtotal 
		cConteudo += PADR( IIf(nAcrescimo > 0, "A" , IIf(SL1->L1_DESCONT > 0, "D", " ")) , 01 )				// 17 - Ordem de aplicacao de Desconto e Acrescimo		
		
		If SA1->(MsSeek(xFilial("SA1")+SL1->L1_CLIENTE+SL1->L1_LOJA))		 
			cConteudo += PADR( AllTrim(SA1->A1_NOME), 40 )				// 18 - Nome do adquirente
			cConteudo += StrZero(Val(AllTrim(SA1->A1_CGC)),14)			// 19 - CPF/CNPJ do adquirente
		Else
			cConteudo += PADR( " ", 40 )				// 18 - Nome do adquirente
			cConteudo += StrZero(0,14)			// 19 - CPF/CNPJ do adquirente
		EndIf
			
		cConteudo += CHR(13) + CHR(10)		
	EndIf
	SL1->(DbSkip())
EndDo

//***********************************************************************************************************************************
//Efetua pesquisa na SL1- caso qdo orçamentos vieram da retaguarda,foram impressos e cancelados no PDV, como cancelar o útlimo cupom
//***********************************************************************************************************************************
SET DELETED OFF
SL1->(DbSetOrder(4)) //L1_FILIAL+DtoS(L1_EMISSAO)
SL1->(DbSeek(xFilial("SL1")+DtoS(dDataIni),.T.))
While !SL1->(Eof()) .AND. SL1->L1_FILIAL == xFilial("SL1") .AND. SL1->L1_EMISSAO <= dDataFim
	If (SL1->(Deleted())) .AND. !Empty(AllTrim(SL1->L1_DOC)) .AND. !Empty(AllTrim(SL1->L1_NUMCFIS))
		
		cConteudo += "R04"						 								// 01 - Tipo
		cConteudo += PADR( cSeriePDV , 20 ) 									// 02 - Numero de fabricacao do ECF
		cConteudo += PADR( cMfAdic	 , 01 )	   								// 03 - Letra indicativa de MF adicional			
		
		cModeloAux := PADR( cModelo, 20)			// Modelo do ECF
		nAcrescimo := SL1->L1_VLRTOT - SL1->L1_VALBRUT
		cConteudo += cModeloAux							// 04 - Modelo do ECF	
		cConteudo += StrZero( nUsuEcf		   	   	   		, 02 )	// 05 - No. de ordem do usuario do ECF relativo a respectiva Reducao Z		
		cConteudo += StrZero(Val(SL1->L1_CONTDOC) , 06 )			// 06 - CCF, CVC ou CBP, conforme o documento
		cConteudo += StrZero(Val(SL1->L1_DOC) , 06 )  			// 07 - COO (Contador de Ordem de Operacao) 
		cConteudo += PADR(DtoS(SL1->L1_EMISSAO)	, 08 ) 	   		// 08 - Data de inicio da emissao 
		cConteudo += StrTran(StrZero(SL1->L1_VALBRUT,15,2),'.')	// 09 - Subtotal do Documento 
		cConteudo += StrTran(StrZero(SL1->L1_DESCONT,14,2),'.')	// 10 - Desconto sobre subtotal
		cConteudo += PADR( IIf(SL1->L1_DESCONT > 0, "V", " "), 01 )	   				// 11 - Indicador do Tipo de Desconto sobre subtotal
		cConteudo += StrTran(StrZero(nAcrescimo,14,2),'.')	// 12 - Acrescimo sobre subtotal 
		cConteudo += PADR(IIf(nAcrescimo > 0, "V" , " "), 01 )	   				// 13 - Indicador do Tipo de Acrescimo sobre subtotal 
		cConteudo += StrTran(StrZero(0,15,2),'.')//14 - Valor Total Liquido
		cConteudo += PADR("S", 01 )	     // 15 - Indicador de Cancelamento 
		cConteudo += StrTran(StrZero(0,14,2),'.')//16 - Cancelamento de Acrescimo no Subtotal 
		cConteudo += PADR( IIf(nAcrescimo > 0, "A" , IIf(SL1->L1_DESCONT > 0, "D", " ")) , 01 )				// 17 - Ordem de aplicacao de Desconto e Acrescimo		
		
		If SA1->(MsSeek(xFilial("SA1")+SL1->L1_CLIENTE+SL1->L1_LOJA))		 
			cConteudo += PADR( AllTrim(SA1->A1_NOME), 40 )				// 18 - Nome do adquirente
			cConteudo += StrZero(Val(AllTrim(SA1->A1_CGC)),14)			// 19 - CPF/CNPJ do adquirente
		Else
			cConteudo += PADR( " ", 40 )				// 18 - Nome do adquirente
			cConteudo += StrZero(0,14)			// 19 - CPF/CNPJ do adquirente
		EndIf
			
		cConteudo += CHR(13) + CHR(10)		
	EndIf
	SL1->(DbSkip())
EndDo
SET DELETED ON

Return cConteudo


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjxER05PDV   ºAutor  ³Vendas CRM         º Data ³  31/05/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ 																	 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³cRet = itens da venda para o mov por ECF	                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJXFUNB                                                    º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjxER05PDV(lReducao, cSeriePDV , cMfAdic ,cModelo, nUsuEcf, dDataIni, dDataFim)
Local cConteudo	:= ""
Local cModeloAux	:= ""
Local cRet			:= ""
Local lCancelado	:= .F.

DbSelectArea("SL2")
SL2->(DbSetOrder(1)) //L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO

DbSelectArea("MDZ")
MDZ->(DbSetOrder(1)) //MDZ_FILIAL+DtoS(MDZ_DATA)
MDZ->(DbSeek(xFilial("MDZ")+DtoS(dDataIni),.T.))
	
While !MDZ->(Eof()) .AND. MDZ->MDZ_FILIAL == xFilial("MDZ") .AND. MDZ->MDZ_DATA <= dDataFim
	If AllTrim(MDZ->MDZ_SIMBOL) == "R4"
		If (MDZ->MDZ_SITUA == "OK") .AND. !Empty(AllTrim(MDZ->MDZ_TIPO)) .AND. ;
			SL2->(DbSeek(xFilial("SL2")+AllTrim(MDZ->MDZ_TIPO))) //Colocado para armazenar no campo MDZ_TIPO o num do orcamento
			
			While !SL2->(Eof()) .AND. (SL2->L2_FILIAL+AllTrim(SL2->L2_NUM) == xFilial("SL2")+AllTrim(MDZ->MDZ_TIPO))
				
				cModeloAux := PADR( cModelo, 20)			// Modelo do ECF
				cConteudo += "R05"											 								// 01 - Tipo
				cConteudo += PADR( cSeriePDV		  	  	   		, 20 ) 									// 02 - Numero de fabricacao do ECF
				cConteudo += PADR( cMfAdic			  	  	   		, 01 )	   								// 03 - Letra indicativa de MF adicional			
				cConteudo += cModeloAux							// 04 - Modelo do ECF	
				cConteudo += StrZero( nUsuEcf	, 02 ) 					// 05 - No. de ordem do usuario do ECF relativo a respectiva Reducao Z 
				cConteudo += StrZero(Val(MDZ->MDZ_COO)	,06 )				// 06 - COO (Contador de Ordem de Operacao) 
				cConteudo += StrZero(Val(MDZ->MDZ_CCF),06 )				// 07 - CCF, CVC ou CBP, conforme o documento
				cConteudo += StrZero(Val(SL2->L2_ITEM)	,03 )				// 08 - Numero do item
				cConteudo += PADR( SL2->L2_PRODUTO	,14 )				// 09 - Codigo do Produto ou Servico
				cConteudo += PADR( SL2->L2_DESCRI	,100)				// 10 - Descricao
				cConteudo += StrZero(SL2->L2_QUANT * &("1" + Replicate("0",TamSx3("L2_VRUNIT")[2])),07 )				// 11 - Quantidade
				cConteudo += PADR( SL2->L2_UM	,03 )				// 12 - Unidade
				cConteudo += StrZero(SL2->L2_PRCTAB * &("1" + Replicate("0",TamSX3("L2_QUANT")[2]))	,08 )				// 13 - Valor unitario
				cConteudo += StrTran(StrZero(SL2->L2_VALDESC,9,2),'.')	// 14 - Desconto sobre item 
				cConteudo += StrTran(StrZero(0,9,2),'.')	// 15 - Acrescimo sobre item 
				cConteudo += StrTran(StrZero(SL2->L2_VLRITEM,15,2),'.')		// 16 - Valor total liquido
				cRet	:= AllTrim(SL2->L2_SITTRIB)
				LjBuscaTot( @cRet )
				cConteudo += PADR( cRet ,07 )				// 17 - Totalizador parcial 
				
				lCancelado := (SL2->L2_VENDIDO == "N")
				
				cConteudo += PADR(IIf(lCancelado,"S","N"), 01 )		// 18 - Indicador de cancelamento 
				cConteudo += StrZero(0,07 )	// 19 - Quantidade cancelada somente cancelado parcial
				cConteudo += StrTran(StrZero(0,14,2),'.')	// 20 - Valor cancelado somente se cancelado parcial
				cConteudo += StrTran(StrZero(0,14,2),'.')	// 21 - Cancelamento de acrescimo no item 
				cConteudo += PADR("A"	,01 )	   			// 22 - Indicador de Arredondamento ou Truncamento(IAT) 
				cConteudo += PADR("T"   	,01 )	   			// 23 - Indicador de Producao Propria ou de Terceiro(IPPT) 
				cConteudo += StrZero(TamSX3("L2_QUANT")[2]	,01 )				// 24 - Casas decimais da quantidade
				cConteudo += StrZero(TamSx3("L2_VRUNIT")[2]	,01 )				// 25 - Casas decimais de valor unitario
				cConteudo += CHR(13) + CHR(10)
				SL2->(DbSkip())
			EndDo
		EndIf	
	EndIf
	MDZ->(DbSkip())
EndDo


DbSelectArea("SL1")
SL1->(DbSetOrder(4)) //L1_FILIAL+DtoS(L1_EMISSAO)
SL1->(DbSeek(xFilial("SL1")+DtoS(dDataIni),.T.))

SL2->(DbSetOrder(1))

While !SL1->(Eof()) .AND. SL1->L1_FILIAL == xFilial("SL1") .AND. SL1->L1_EMISSAO <= dDataFim
	If (SL1->L1_STORC == "C") .AND. !Empty(AllTrim(SL1->L1_NUMORC))
		If SL2->(MsSeek(xFilial("SL2")+AllTrim(SL1->L1_NUM)))
			While !SL2->(Eof()) .AND. (SL2->L2_FILIAL+AllTrim(SL2->L2_NUM) == xFilial("SL2")+AllTrim(SL1->L1_NUM))
				
				cModeloAux := PADR( cModelo, 20)			// Modelo do ECF
				cConteudo += "R05"											 								// 01 - Tipo
				cConteudo += PADR( cSeriePDV	, 20 ) 									// 02 - Numero de fabricacao do ECF
				cConteudo += PADR( cMfAdic		, 01 )	   								// 03 - Letra indicativa de MF adicional			
				cConteudo += cModeloAux							// 04 - Modelo do ECF	
				cConteudo += StrZero( nUsuEcf	, 02 ) 					// 05 - No. de ordem do usuario do ECF relativo a respectiva Reducao Z 
				cConteudo += StrZero(0,06 )				// 06 - COO (Contador de Ordem de Operacao) 
				cConteudo += StrZero(0,06 )				// 07 - CCF, CVC ou CBP, conforme o documento
				cConteudo += StrZero(Val(SL2->L2_ITEM)	,03 )				// 08 - Numero do item
				cConteudo += PADR( SL2->L2_PRODUTO	,14 )				// 09 - Codigo do Produto ou Servico
				cConteudo += PADR( SL2->L2_DESCRI	,100)				// 10 - Descricao
				cConteudo += StrZero(SL2->L2_QUANT * &("1" + Replicate("0",TamSx3("L2_VRUNIT")[2])),07 )				// 11 - Quantidade
				cConteudo += PADR( SL2->L2_UM	,03 )				// 12 - Unidade
				cConteudo += StrZero(SL2->L2_PRCTAB * &("1" + Replicate("0",TamSX3("L2_QUANT")[2]))	,08 )				// 13 - Valor unitario
				cConteudo += StrTran(StrZero(SL2->L2_VALDESC,9,2),'.')	// 14 - Desconto sobre item 
				cConteudo += StrTran(StrZero(0,9,2),'.')	// 15 - Acrescimo sobre item 
				cConteudo += StrTran(StrZero(SL2->L2_VLRITEM,15,2),'.')		// 16 - Valor total liquido
				cRet	:= AllTrim(SL2->L2_SITTRIB)
				LjBuscaTot( @cRet )
				cConteudo += PADR(cRet							,07 )				// 17 - Totalizador parcial 
				cConteudo += PADR(IIf(SL2->L2_VENDIDO == "N","S","N"), 01 )		// 18 - Indicador de cancelamento 
				cConteudo += StrZero(0,07 )				// 19 - Quantidade cancelada
				cConteudo += StrTran(StrZero(0,14,2),'.')	// 20 - Valor cancelado
				cConteudo += StrTran(StrZero(0,14,2),'.')	// 21 - Cancelamento de acrescimo no item 
				cConteudo += PADR("A"	,01 )	   			// 22 - Indicador de Arredondamento ou Truncamento(IAT) 
				cConteudo += PADR("T"   		,01 )	   			// 23 - Indicador de Producao Propria ou de Terceiro(IPPT) 
				cConteudo += StrZero(TamSX3("L2_QUANT")[2]	,01 )				// 24 - Casas decimais da quantidade
				cConteudo += StrZero(TamSx3("L2_VRUNIT")[2]	,01 )				// 25 - Casas decimais de valor unitario
				cConteudo += CHR(13) + CHR(10)
				
				SL2->(DbSkip())
			EndDo
		EndIf
	EndIf
	SL1->(DbSkip())
EndDo

//***********************************************************************************************************************************
//Efetua pesquisa na SL1 e SL2 - caso qdo orçamentos vieram da retaguarda,foram impressos e cancelados no PDV, como cancelar o útlimo cupom
//***********************************************************************************************************************************
SET DELETED OFF
DbSelectArea("SL1")
SL1->(DbSetOrder(4)) //L1_FILIAL+DtoS(L1_EMISSAO)
SL1->(DbSeek(xFilial("SL1")+DtoS(dDataIni),.T.))

DbSelectArea("SL2")
SL2->(DbSetOrder(1))

While !SL1->(Eof()) .AND. SL1->L1_FILIAL == xFilial("SL1") .AND. SL1->L1_EMISSAO <= dDataFim
	If (SL1->(Deleted())) .AND. !Empty(AllTrim(SL1->L1_DOC)) .AND. !Empty(AllTrim(SL1->L1_NUMCFIS))
		If SL2->(MsSeek(xFilial("SL2")+AllTrim(SL1->L1_NUM)))
			While !SL2->(Eof()) .AND. (SL2->L2_FILIAL+AllTrim(SL2->L2_NUM) == xFilial("SL2")+AllTrim(SL1->L1_NUM))
				
				If AllTrim(SL2->L2_VENDIDO) == "S" .AND. !Empty(SL2->L2_DOC) .AND. !Empty(SL2->L2_SERIE) .AND. !Empty(SL2->L2_PDV)
					cModeloAux := PADR( cModelo, 20)			// Modelo do ECF
					cConteudo += "R05"											 								// 01 - Tipo
					cConteudo += PADR( cSeriePDV	, 20 ) 									// 02 - Numero de fabricacao do ECF
					cConteudo += PADR( cMfAdic		, 01 )	   								// 03 - Letra indicativa de MF adicional			
					cConteudo += cModeloAux							// 04 - Modelo do ECF	
					cConteudo += StrZero( nUsuEcf	, 02 ) 					// 05 - No. de ordem do usuario do ECF relativo a respectiva Reducao Z 
					cConteudo += StrZero(0,06 )				// 06 - COO (Contador de Ordem de Operacao) 
					cConteudo += StrZero(0,06 )				// 07 - CCF, CVC ou CBP, conforme o documento
					cConteudo += StrZero(Val(SL2->L2_ITEM)	,03 )				// 08 - Numero do item
					cConteudo += PADR( SL2->L2_PRODUTO	,14 )				// 09 - Codigo do Produto ou Servico
					cConteudo += PADR( SL2->L2_DESCRI	,100)				// 10 - Descricao
					cConteudo += StrZero(SL2->L2_QUANT * &("1" + Replicate("0",TamSx3("L2_VRUNIT")[2])),07 )				// 11 - Quantidade
					cConteudo += PADR( SL2->L2_UM	,03 )				// 12 - Unidade
					cConteudo += StrZero(SL2->L2_PRCTAB * &("1" + Replicate("0",TamSX3("L2_QUANT")[2]))	,08 )				// 13 - Valor unitario
					cConteudo += StrTran(StrZero(SL2->L2_VALDESC,9,2),'.')	// 14 - Desconto sobre item 
					cConteudo += StrTran(StrZero(0,9,2),'.')	// 15 - Acrescimo sobre item 
					cConteudo += StrTran(StrZero(SL2->L2_VLRITEM,15,2),'.')		// 16 - Valor total liquido
					cRet	:= AllTrim(SL2->L2_SITTRIB)
					LjBuscaTot( @cRet )
					cConteudo += PADR(cRet							,07 )				// 17 - Totalizador parcial 
					cConteudo += PADR(IIf(SL2->L2_VENDIDO == "N","S","N"), 01 )		// 18 - Indicador de cancelamento 
					cConteudo += StrZero(0,07 )				// 19 - Quantidade cancelada
					cConteudo += StrTran(StrZero(0,14,2),'.')	// 20 - Valor cancelado
					cConteudo += StrTran(StrZero(0,14,2),'.')	// 21 - Cancelamento de acrescimo no item 
					cConteudo += PADR("A"	,01 )	   			// 22 - Indicador de Arredondamento ou Truncamento(IAT) 
					cConteudo += PADR("T"   		,01 )	   			// 23 - Indicador de Producao Propria ou de Terceiro(IPPT) 
					cConteudo += StrZero(TamSX3("L2_QUANT")[2]	,01 )				// 24 - Casas decimais da quantidade
					cConteudo += StrZero(TamSx3("L2_VRUNIT")[2]	,01 )				// 25 - Casas decimais de valor unitario
					cConteudo += CHR(13) + CHR(10)
				EndIf
				
				SL2->(DbSkip())
			EndDo
		EndIf
	EndIf
	SL1->(DbSkip())
EndDo	
SET DELETED ON


Return cConteudo

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjxER07PDV   ºAutor  ³Vendas CRM         º Data ³  31/05/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ 																	 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³cRet = valor da venda para o mov por ECF	                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJXFUNB                                                    º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjxER07PDV(lReducao, cSeriePDV , cMfAdic ,cModelo, nUsuEcf, dDataIni, dDataFim) 
Local cConteudo	:=	""
Local cModeloAux	:= cModelo
Local cRet			:= ""

//*****************************************************************************************
//Efetua pesquisa na SL1 - caso qdo orçamentos vieram e foram impressos e cancelados no PDV
//*****************************************************************************************
DbSelectArea("SL1")
SL1->(DbSetOrder(4)) //L1_FILIAL+DtoS(L1_EMISSAO)
SL1->(DbSeek(xFilial("SL1")+DtoS(dDataIni),.T.))

DbSelectArea("SL4")
SL4->(DbSetOrder(1)) //L4_FILIAL+L4_NUM+L4_ORIGEM

While !SL1->(Eof()) .AND. SL1->L1_FILIAL == xFilial("SL1") .AND. SL1->L1_EMISSAO <= dDataFim
	If (SL1->L1_STORC == "C") .AND. !Empty(AllTrim(SL1->L1_NUMORC)) .AND. Empty(AllTrim(SL1->L1_NUMCFIS))	
		If SL4->(MsSeek(xFilial("SL4")+AllTrim(SL1->L1_NUM)))
			While !SL4->(Eof()) .AND. (SL4->L4_FILIAL+SL4->L4_NUM == xFilial("SL4")+SL1->L1_NUM)
				
				cModeloAux := PADR( cModelo, 20)			// Modelo do ECF
				
				If Empty(AllTrim(SL4->L4_INSTITU))					
					cRet := Posicione("SX5", 1, xFilial("SX5")+ "24" + SubStr(AllTrim(SL4->L4_FORMA), 1, 2), "X5_DESCRI")
				Else					
					cRet := Posicione("SX5", 1, xFilial("SX5")+ "24" +( AllTrim(SL4->L4_FORMA) + "-" + AllTrim(SL4->L4_INSTITU), 1, 2), "X5_DESCRI")
				Endif	
							 
				cConteudo += "R07"							// 01 - Tipo
				cConteudo += PADR( cSeriePDV 		, 20 )	// 02 - Numero de fabricação do ECF
				cConteudo += PADR( cMfAdic	  		, 01 )	// 03 - Letra indicativa de MF adicional				
				cConteudo += cModeloAux						// 04 - Modelo do ECF	
				cConteudo += StrZero( nUsuEcf , 02 )		// 05 - No. de ordem do usuario do ECF relativo a respectiva Reducao Z 
				cConteudo += StrZero( Val(SL1->L1_DOC) , 06 )		// 06 - COO (Contador de Ordem de Operacao) 
				cConteudo += StrZero( Val(SL1->L1_DOC), 06 )	// 07 - Numero do Contador de Cupom Fiscal relativo ao respectivo Cupom Fiscal emitido
				cConteudo += StrZero( Val(SL1->L1_CONTONF), 06 )			// 08 - Numero do Contador Geral Não Fiscal relativo ao respectivo Comprovante Não Fiscal emitido
				cConteudo += PADR( cRet	, 15 )		   						// 09 - Descricao do totalizador parcial de meio de pagamento
				cConteudo += StrTran(StrZero( SL4->L4_VALOR, 14, 2),'.')	// 10 - Valor do pagamento efetuado, com duas casas decimais
				cConteudo += PADR("S", 01 )   // 11 - Informar "S" ou "N", conforme tenha ocorrido ou não, o estorno do pagamento, ou “P” para estorno parcial do pagamento
				cConteudo += StrZero( 0	, 13 ) 	  							// 12 - Valor do estorno efetuado, com duas casas decimais				
				cConteudo += CHR(13) + CHR(10)
				
				SL4->(DbSkip())			
			EndDo
		Endif			
	EndIf
	SL1->(DbSkip())
EndDo


//***********************************************************************************************************************************
//Efetua pesquisa na SL1 e SL2 - caso qdo orçamentos vieram da retaguarda,foram impressos e cancelados no PDV, como cancelar o útlimo cupom
//***********************************************************************************************************************************
SET DELETED OFF
DbSelectArea("SL1")
SL1->(DbSetOrder(4)) //L1_FILIAL+DtoS(L1_EMISSAO)
SL1->(DbSeek(xFilial("SL1")+DtoS(dDataIni),.T.))

DbSelectArea("SL4")
SL4->(DbSetOrder(1)) //L4_FILIAL+L4_NUM+L4_ORIGEM

While !SL1->(Eof()) .AND. SL1->L1_FILIAL == xFilial("SL1") .AND. SL1->L1_EMISSAO <= dDataFim
	If (SL1->(Deleted())) .AND. !Empty(AllTrim(SL1->L1_DOC)) .AND. !Empty(AllTrim(SL1->L1_NUMCFIS))
		If SL4->(MsSeek(xFilial("SL4")+AllTrim(SL1->L1_NUM)))
			While !SL4->(Eof()) .AND. (SL4->L4_FILIAL+SL4->L4_NUM == xFilial("SL4")+SL1->L1_NUM)
				
				cModeloAux := PADR( cModelo, 20)			// Modelo do ECF
				
				If Empty(AllTrim(SL4->L4_INSTITU))					
					cRet := Posicione("SX5", 1, xFilial("SX5")+ "24" + SubStr(AllTrim(SL4->L4_FORMA), 1, 2), "X5_DESCRI")
				Else					
					cRet := Posicione("SX5", 1, xFilial("SX5")+ "24" +( AllTrim(SL4->L4_FORMA) + "-" + AllTrim(SL4->L4_INSTITU), 1, 2), "X5_DESCRI")
				Endif	
							 
				cConteudo += "R07"							// 01 - Tipo
				cConteudo += PADR( cSeriePDV 		, 20 )	// 02 - Numero de fabricação do ECF
				cConteudo += PADR( cMfAdic	  		, 01 )	// 03 - Letra indicativa de MF adicional				
				cConteudo += cModeloAux						// 04 - Modelo do ECF	
				cConteudo += StrZero( nUsuEcf , 02 )		// 05 - No. de ordem do usuario do ECF relativo a respectiva Reducao Z 
				cConteudo += StrZero( Val(SL1->L1_DOC) , 06 )		// 06 - COO (Contador de Ordem de Operacao) 
				cConteudo += StrZero( Val(SL1->L1_DOC), 06 )	// 07 - Numero do Contador de Cupom Fiscal relativo ao respectivo Cupom Fiscal emitido
				cConteudo += StrZero( Val(SL1->L1_CONTONF), 06 )			// 08 - Numero do Contador Geral Não Fiscal relativo ao respectivo Comprovante Não Fiscal emitido
				cConteudo += PADR( cRet	, 15 )		   						// 09 - Descricao do totalizador parcial de meio de pagamento
				cConteudo += StrTran(StrZero( SL4->L4_VALOR, 14, 2),'.')	// 10 - Valor do pagamento efetuado, com duas casas decimais
				cConteudo += PADR("S", 01 )   //*Uso como padrão o "S" pois trata-se de um registro deletado* -> 11 - Informar "S" ou "N", conforme tenha ocorrido ou não, o estorno do pagamento, ou “P” para estorno parcial do pagamento
				cConteudo += StrZero( 0	, 13 ) 	  							// 12 - Valor do estorno efetuado, com duas casas decimais				
				cConteudo += CHR(13) + CHR(10)
				
				SL4->(DbSkip())			
			EndDo
		Endif			
	EndIf
	SL1->(DbSkip())
EndDo
SET DELETED ON

Return cConteudo

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjxEPItDel   ºAutor  ³Vendas CRM         º Data ³  31/05/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ 																	 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³cRet = item cancelado na venda do PDV	                  	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJXFUNB                                                    º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjxEPItDel(cSeriePDV ,cCooDoc,lReducao, cMfAdic ,cModelo, nUsuEcf)
Local cIndice		:= ""
Local cConteudo	:= ""
Local cRet			:= ""
Local cSerie		:= AllTrim(LjGetStation("LG_SERIE"))
Local cModeloAux	:= cModelo
Local nCount		:= 0

SET DELETED OFF

DbSelectArea("SL1")
DbSelectArea("SL2")
SL2->(dbsetorder(3))
SL1->(dbsetorder(1))

cIndice := xFilial('SL2')+AllTrim(cSerie)+AllTrim(cCooDoc)
SL2->(MsSeek(cIndice))

//Aqui somente selecione itens que foram deletados e o cupom finalizado
While !SL2->(Eof()) .AND. (SL2->(L2_FILIAL+AllTrim(L2_SERIE)+AllTrim(L2_DOC)) == cIndice)	 
	If (SL1->(MsSeek(xFilial("SL1")+SL2->L2_NUM))) .AND. !(SL1->(Deleted())) .AND. !(SL1->L1_STORC == "C") ; 
		.AND. (!Empty(AllTrim(SL1->L1_DOC))) .AND. AllTrim(SL2->L2_DOC) == AllTrim(cCooDoc) .AND. SL2->L2_VENDIDO == "N"
		
		cModeloAux := PADR( cModelo, 20)			// Modelo do ECF
		
		cConteudo := "R05"								// 01 - Tipo
		cConteudo += PADR( cSeriePDV 	   		, 20 ) // 02 - Numero de fabricacao do ECF
		cConteudo += PADR( cMfAdic			  	, 01 )	// 03 - Letra indicativa de MF adicional		
		cConteudo += cModeloAux							// 04 - Modelo do ECF	
		cConteudo += StrZero( nUsuEcf	, 02 ) 									// 05 - No. de ordem do usuario do ECF relativo a respectiva Reducao Z
		cConteudo += StrZero(Val(SL2->L2_DOC)	,06 )				// 06 - COO (Contador de Ordem de Operacao) 
		cConteudo += StrZero(Val(SL1->L1_CONTDOC),06 )				// 07 - CCF, CVC ou CBP, conforme o documento
		cConteudo += StrZero(Val(SL2->L2_ITEM)	,03 )				// 08 - Numero do item
		cConteudo += PADR( SL2->L2_PRODUTO		,14 )				// 09 - Codigo do Produto ou Servico
		cConteudo += PADR( SL2->L2_DESCRI	,100)				// 10 - Descricao
		cConteudo += StrZero(SL2->L2_QUANT * &("1" + Replicate("0",TamSX3("L2_QUANT")[2])),07 )				// 11 - Quantidade
		cConteudo += PADR( SL2->L2_UM	,03 )				// 12 - Unidade
		cConteudo += StrZero(SL2->L2_PRCTAB * &("1" + Replicate("0",TamSX3("L2_VRUNIT")[2]))	,08 )				// 13 - Valor unitario
		cConteudo += StrTran(StrTran(StrZero(SL2->L2_VALDESC,9,2),'-','0'),'.')	// 14 - Desconto sobre item 
		cConteudo += StrTran(StrTran(StrZero(0,9,2),'-','0'),'.')	// 15 - Acrescimo sobre item 
		cConteudo += StrTran(StrTran(StrZero(SL2->L2_VLRITEM,15,2),'-','0'),'.')		// 16 - Valor total liquido
		
		cRet := AllTrim(SL2->L2_SITTRIB)
		LjBuscaTot( @cRet )
		
		cConteudo += PADR( cRet	,07 )				// 17 - Totalizador parcial 
		cConteudo += PADR(IIf(AllTrim(SL2->L2_VENDIDO) == "N","S","N"), 01 )		// 18 - Indicador de cancelamento 
		cConteudo += StrZero(0,07 )				// 19 - Quantidade cancelada
		cConteudo += StrTran(StrTran(StrZero(0,14,2),'-','0'),'.')	// 20 - Valor cancelado
		cConteudo += StrTran(StrZero(0,14,2),'.')	// 21 - Cancelamento de acrescimo no item 
		cConteudo += PADR("A"	,01 )	   			// 22 - Indicador de Arredondamento ou Truncamento(IAT) 
		cConteudo += PADR("T"	,01 )	   			// 23 - Indicador de Producao Propria ou de Terceiro(IPPT) 
		cConteudo += StrZero(TamSX3("L2_QUANT")[2]	,01 )				// 24 - Casas decimais da quantidade
		cConteudo += StrZero(TamSx3("L2_VRUNIT")[2]	,01 )				// 25 - Casas decimais de valor unitario		
		
		cConteudo += CHR(13) + CHR(10)			
	EndIf
	nCount := Val( SL2->L2_ITEM )
	SL2->(DbSkip())
EndDo	

SET DELETED ON

Return cConteudo


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GetRgAcumul ºAutor  ³ Vendas Clientes        º Data ³ 02/09/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Retorna a variavel logica (static) lRgAcumul						º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Logico											             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjGetRAcumul()
Return lRgAcumul

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SetRgAcumulº Autor  ³ Vendas Clientes        º Data ³ 02/09/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Atribui valor a variavel logica (static) lRgAcumul			 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ 													             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjSetRAcumul(lAlterado)
	lRgAcumul := lAlterado
Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjfnEGetIpi ºAutor  ³ Vendas Clientes        º Data ³ 02/09/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Calcula o Valor do IPI a ser descontado do preço de venda    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ 													            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjfnEGetIpi(nPrecoTab, nCasasIPI, lMVRNDIPI, nAliquota)
	
Local nValIPIEn := 0

Default nAliquota := SB1->B1_IPI

nValIPIEn	:= (nPrecoTab  /(1 +(nAliquota/100) )) * ( nAliquota/100)	//Apura a Base do IPI

If lMVRNDIPI		
	nValIPIEn := Round(nValIPIEn,nCasasIPI)     //Trabalha com arredondamento
Else
	nValIPIEn := NoRound(nValIPIEn,nCasasIPI)   //Trabalha com truncamento
EndIf
           						

Return(nValIPIEn)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjProdGar  ºAutor  ³ Vendas Clientes       º Data ³ 16/01/14 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Caso o produto garantia nao tenha preco ele inclui          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjProdGar(cProduto,cTabPad)
Local lRet 		:= .F.

DEFAULT cProduto:= ""
DEFAULT cTabPad	:= "1"

SB1->(dbSetorder(1))
If SB1->(dbSeek(xFilial("SB1")+cProduto)) .AND. AllTrim(SB1->B1_TIPO) == AllTrim(cMvLjTGar)
	// Caso seja um produto garantia e nao possua preco, preenche com um valor qualquer para nao exigir 
	// que tenha SB0 cadastrado , pois a garantia nao pega o preco do SB0
	RecLock("SB0",.F.)	
	REPLACE &("SB0->B0_PRV"+cTabPad)	WITH 1
	SB0->(MsUnlock())
	lRet := .T.
EndIf
	
Return(lRet)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ljFilTab  ºAutor  ³ Vendas Clientes       º Data ³ 16/10/15  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Filta as tabela de preço ativas                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ljFilTab(aTabXPreco,cProduto,nQtdade)

Local aArea  		:= GetArea() // Salva a area atual
Local cQuery 		:=  ""       // Texto SQL que é enviado para o comando TCGenQry
Local cAliasDA1 	:= "DA1"
Local _aTabsPrecos 	:= {}

DEFAULT aTabXPreco	:= {}
DEFAULT cProduto	:= "1"
DEFAULT nQtdade		:= 0 

#IFDEF TOP

	cAliasDA1 := GetNextAlias()

	cQuery := " SELECT DA1_CODTAB FROM  " + RetSqlName("DA1")+ " DA1" + ; 
			  " WHERE DA1.DA1_FILIAL = '" + xFilial("DA1") + "'" +;
			  " AND DA1.DA1_CODPRO   = '" + cProduto + "'" +; 
			  " AND DA1.DA1_QTDLOT >=  "  + Alltrim(Str(nQtdade)) +;
			  " AND DA1.DA1_ATIVO = '1' AND DA1.D_E_L_E_T_ = ' ' ORDER BY  DA1_CODTAB "

	cQuery := ChangeQuery(cQuery)
		
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasDA1, .F., .T.)

	If !Empty(Alltrim((cAliasDA1)->DA1_CODTAB))
		While (cAliasDA1)->(!EOf()) 
			If Ascan(aTabXPreco,{|x| x == Alltrim((cAliasDA1)->DA1_CODTAB)} ) > 0 
				aAdd(_aTabsPrecos, Alltrim((cAliasDA1)->DA1_CODTAB) )
			EndIf	
		(cAliasDA1)->(dbSkip())
		End	

		aTabXPreco := _aTabsPrecos

	EndIF
    (cAliasDA1)->(DbCloseArea())
    

#ENDIF
    	
RestArea(aArea)

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJValCenVdºAutor  ³Vendas CRM          º Data ³  24/12/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faz a validacao dos campos que nao sao necessarios para o   º±±
±±º          ³modulo de loja.                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CENARIO DE VENDAS                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJValCenVd()  
/*Função foi mantida pois é chamada em fontes do faturamento para não gerar
erro e por conta do Projeto SOYUZ o conteúdo da rotina não pode mais ser 
executado, pois atualizava o dicionário com o sistema em execução.*/
Return Nil


/*/{Protheus.doc} LjxValEst
	função responsavel por validar se o faturamento devera validar o estoque mesmo com reserva.
	Obs: essa função foi criada pelo motivo do loja permitir a reserva negativa
	@type  Function
	@author Lucas Novais	
	@since 18/01/2018
	@version 12.1.17
	@param 
	@return lValida
	@example
	If LjxValEst(SC5->S5_ORCRES)
		//Executa comando
	Endif 
/*/
Function LjxValEst(cC5OrcRes)
Local lValida	:= .F.
Local cLJPVLIB	:= SuperGetMV("MV_LJPVLIB",,"1")
Local cESTNEG	:= SuperGetMV("MV_ESTNEG",,"N")

Default cC5OrcRes  := ""

lValida :=  !Empty(cC5OrcRes) .AND. cLJPVLIB == "2" .AND. cESTNEG == "N"

Return lValida

//-----------------------------------------------------------
/*/{Protheus.doc} LjADLSeek
@type Function
@description Realiza a busca na tabela ADL, utilizada durante a Workarea, onde o filtro na tabela ADL impede a busca completa.
             Obs.: Essa Função foi clonada do fonte fata520B pelo fato do faturamento estar retirando o tratamento do Ifdef top 
             Função original ADLSeek
@param cFilADL 		- Filial da ADL
       cCodVend 	- Codigo do vendedor
       cFilEnt 		- Filial da entidade
       cEnt 		- Alias da entidade
       cCodigo 		- Codigo da entidade
       cLoja 		- Loja da entidade
@author Rene Julian
@return	nRec - Retorno do registro encontrado na tabela ADL.
@since 25/07/2018
@version P12.1.17
/*/
//-----------------------------------------------------------
Function LjADLSeek(cFilADL	, cCodVend	, cFilEnt	, cEnt	,;
						cCodigo	, cLoja		)

Local aArea		:= GetArea()
Local cQuery	:= ""
Local cAliasTmp	:= "ADLSEE" 
Local nRec		:= 0


#IFDEF TOP
	If Select(cAliasTmp) > 0
		(cAliasTmp)->(DbCloseArea())	
	EndIf
	
	cQuery	:= "SELECT R_E_C_N_O_ AS RECN FROM "+RetSqlName("ADL")
	cQuery	+= " WHERE ADL_FILIAL ='"+cFilADL+"' AND ADL_VEND = '"+cCodVend+"' AND ADL_FILENT = '"+cFilEnt+"'"
	cQuery	+= " AND ADL_ENTIDA = '"+cEnt+"' AND ADL_CODENT = '"+cCodigo+"' AND ADL_LOJENT = '"+cLoja+"' AND D_E_L_E_T_ = ' '"
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.F.,.T.)
	dbGoTop()	                 
	
	If !Eof()
		nRec :=(cAliasTmp)->RECN
	End	

	(cAliasTmp)->(DbCloseArea())
#ELSE
	DbSelectarea("ADL")
	DbSetOrder(5)
	If DbSeek(xFilial("ADL")+cCodVend)
		While !ADL->(Eof()) 
			If ADL->ADL_FILIAL == cFilADL  .And. ADL->ADL_VEND == cCodVend .And. ADL->ADL_FILENT == cFilEnt .And. ;
		       ADL->ADL_ENTIDA ==  cEnt .And. ADL->ADL_CODENT ==  cCodigo .And. ADL->ADL_LOJENT == cLoja
			
				nRec := ADL->(Recno())
				Exit 
			EndIf
			
			DbSkip()
		End	
	EndIf
	
#ENDIF
	
RestArea(aArea)

Return nRec

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetMaTabPr
Executa a função MaTabPrVen para busca do preço do produto na tabela de Preço DA0/DA1.

@type       Function
@author     Alberto Deviciente
@since      17/01/2022
@version    12

@param cCodTab, Caractere, Código da Tabela de Preço
@param cProduto, Caractere, Código do Produto
@param nQtdade, Numérico, Quantidade
@param cCliente, Caractere, Código do Cliente
@param cLoja, Caractere, Loja do Cliente
@param nMoeda, Numérico, Código da Moeda a ser considerada

@return nRet, Numérico, Preço do Produto retornado da função MaTabPrVen.
/*/
//-------------------------------------------------------------------------------------
Static Function GetMaTabPr(cCodTab, cProduto, nQtdade, cCliente, cLoja, nMoeda)
Local nRet 			:= 0
Local cChvCtrPrc	:= "" // Chave de Controle para não executar a função MaTabPrVen para buscar o preço do mesmo produto diversas vezes.
Local nPosCtrl		:= 0
Local nPosCpoIte	:= 0
Local nPosCpoQtd	:= 0
Local cItem 		:= ""
Local nQtdAtu 		:= nQtdade //Quantidade Atual do Item
Local lIsVenda 		:= Type("M->LQ_NUM") == "C" //Identifica se foi chamado da Venda Assistida/Venda Direta
Local nPosCpoPrd	:= 0
Local cCodProd 		:= ""

If lIsVenda
	If Type("aPosCpo") == "A"
		nPosCpoIte 	:= aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_ITEM"})][2]	 // Posicao do item
		nPosCpoQtd 	:= aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_QUANT"})][2]	 // Posicao da Quantidade
		nPosCpoPrd	:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_PRODUTO"})][2] // Posicao do Codigo do Produto
		cItem     	:= aCols[n][nPosCpoIte]
		nQtdAtu     := aCols[n][nPosCpoQtd]
		cCodProd	:= aCols[n][nPosCpoPrd]
		If "LR_QUANT" $ ReadVar()
			nQtdAtu := M->LR_QUANT //Considera a Quantidade Atual lançada para fazer o controle de chamada da função MaTabPrVen. Caso seja igual, não chama novamente.
		EndIf

		If Empty(cCodProd) .And. Len(aCols) == 1
			//Se for o primeiro item que tiver sendo registrado, reinicia o array estático
			aRetMTabPr	:= {}
			//Limpa o conteudo do array estático com os precos da ultima tabela de preco, utilizada na função MaTabPrVen
			MaReleTabPrc()
		EndIf
	EndIf

	cChvCtrPrc := xFilial("SL1") + M->LQ_NUM + cCliente + cLoja

	//Verifica se já foi chamada a função MaTabPrVen. Caso positivo, somente retorna a mesma informação já retornada anteriormente.
	If Len(aRetMTabPr) > 0 .And. aRetMTabPr[1] == cChvCtrPrc //Verifica se ainda é ou não a mesma venda e mesmo cliente
		//Se encontrar informação já retornada da função MaTabPrVen para os mesmos parâmetros já enviados anteriormente, apenas retorna o conteúdo já conhecido para não executar a função novamente. Melhorando assim a performance do sistema.
		If ( nPosCtrl := aScan( aRetMTabPr[2], {|x| x[1] == cCodTab + cItem + cProduto + cCliente + cLoja } ) ) > 0
			If aRetMTabPr[2][nPosCtrl][2] == nQtdAtu
				nRet := aRetMTabPr[2][nPosCtrl][3]
			EndIf
		EndIf
	Else
		aRetMTabPr := {cChvCtrPrc, {}}
	EndIf
EndIf

If nRet == 0
	LjGrvLog(Nil ,"Antes da Chamada da Funcao MaTabPrVen")
	nRet := MaTabPrVen( cCodTab, cProduto, nQtdade, cCliente, cLoja, nMoeda )
	LjGrvLog(Nil ,"Apos a Chamada da Funcao MaTabPrVen. Retorno:",nRet)

	If lIsVenda
		If nPosCtrl > 0 //Se o item/produto já está no array de controle, atualiza a quantidade e o preço.
			aRetMTabPr[2][nPosCtrl][2] := nQtdAtu
			aRetMTabPr[2][nPosCtrl][3] := nRet
		Else
			aAdd( aRetMTabPr[2], { cCodTab + cItem + cProduto + cCliente + cLoja, nQtdAtu, nRet } )
		EndIf
	EndIf
EndIf

Return nRet
