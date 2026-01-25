#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

Static aBfPrdVal := {}			//Static para acumular o valor da bonificação por produto, utilizado em STBAcPrdBf() e STBDistrBf()   

//--------------------------------------------------------
/*{Protheus.doc} STBBonusSales
Verifica se a bonificacao passada por parametro sera contemplada
@param		cRegraBon		Codigo da regra de bonificacao
@param		cTesBonus		TES para Bonificacao
@param		cCodProd		Codigo do produto
@author  Varejo
@version P11.8
@since   23/07/2012
@return  .T. se a bonificacao se aplica / .F. Se houve falha em algum processo
@obs     
@sample
*/
//--------------------------------------------------------
Function STBBonusSales(cRegraBon,cTesBonus,cCodProd)

Local aArea 		:= GetArea()                                               // Guarda area corrente
Local lContinua		:= .T.                                                     // Verifica se continua o processamento
Local lBonifica 	:= .T.                                                     // Retorno da funcao - Verifica se a regra de bonificao sera aplicada
Local cCliente		:= STDGPBasket( "SL1" , "L1_CLIENTE" )                     // Codigo do cliente na venda
Local cLoja			:= STDGPBasket( "SL1" , "L1_LOJA" )                        // Codigo da loja do cliente na venda
Local cCondPag		:= STDGPBasket( "SL1" , "L1_CONDPG" )                      // Condicao de pagamento da venda
Local cFormPg		:= STDGPBasket( "SL1" , "L1_FORMPG" )                      // Forma de pagamento da venda
Local nQuantTotal	:= 0                                                       // Quantidade total do item
Local nQuantItem    := STDGPBasket( "SL2" , "L2_QUANT", STDPBLength( "SL2" ) ) // Quantidade do item lancado
Local nQuantVerf    := 0                                                       // Quantidade ja existente na venda
Local cGrpClient	:= ""                                                      // Grupo de clientes
Local lAccBonus     := SuperGetMv("MV_TPBONUS",.F.,.T.)                        // Indica se a regra de bonificacao sera acumulada ou nao
Local aUsedRules    := STDBSGetRules( )                                        // Array contendo as regras de bonificacao ja utilizadas na venda
Local nPosRegra     := 0                                                       // Posicao da regra dentro do array de regras utilizadas
Local nTimesUsed    := 0                                                       // Numero de vezes que a regra foi utilizada
Local nLote         := 0                                                       // numero de produtos que devem ser comprados para validar a regra
Local nX			:= 0                                                       // Contador do For

Default cRegraBon	:= ""	// Codigo da regra de bonificacao
Default cTesBonus	:= SuperGetMv("MV_BONUSTS")	// Codigo da regra de bonificacao
Default cCodProd	:= ""	// Codigo do produto que esta sendo registrado.

ParamType 0 Var cRegraBon 	AS Character	Default ""
ParamType 1 Var cTesBonus 	AS Character	Default SuperGetMv("MV_BONUSTS")
ParamType 2 Var cCodProd   	AS Character	Default ""

If Len(aUsedRules) > 0
	nPosRegra := aScan(aUsedRules,{|x| AllTrim(x[1]) == AllTrim(cRegraBon)})
	If nPosRegra > 0
		If !lAccBonus // Caso a bonificacao nao seja cumulativa, verifico se a regra ja foi utilizada.
			lContinua := .F.
		Else
			nTimesUsed := aUsedRules[nPosRegra,2]
		EndIf
	EndIf
EndIf

If lContinua
	//Verifica se a tes eh valida
	If Empty(cTesBonus)
		lContinua := .F.
	Else
		//Trata se parâmetro for numerico
		If ValType(cTesBonus) == "N"
			cTesBonus := AllTrim(cValToChar(cTesBonus))
		ElseIf ValType(cTesBonus) == "C"
			cTesBonus := AllTrim(cTesBonus)
		EndIf
		
		dbSelectArea("SF4")
		dbSetOrder(1)
		If SubStr(cTesBonus,1,3) <= "500" .Or. !DbSeek(xFilial("SF4")+cTesBonus)
			lContinua := .F.	
		EndIf
	EndIf
EndIf

If lContinua
	DbSelectArea("ACQ")
	ACQ->(DbSetOrder(1))
	If ACQ->(DbSeek(xFilial("ACQ")+cRegraBon))
		
		// Verifico se a venda se enquadra nos parametros mais basicos da regra de bonificacao
		If ((AllTrim(ACQ->ACQ_CODCLI) == AllTrim(cCliente) .Or. Empty(ACQ->ACQ_CODCLI) ).And.;
				(AllTrim(ACQ->ACQ_LOJA) == AllTrim(cLoja) .Or. Empty(ACQ->ACQ_LOJA) ) .And.;
				(AllTrim(ACQ->ACQ_CONDPG) == AllTrim(cCondPag) .Or. Empty(ACQ->ACQ_CONDPG) ) .And.;
				(AllTrim(ACQ->ACQ_FORMPG) == AllTrim(cFormPg) .Or. Empty(ACQ->ACQ_FORMPG)))
				
			cGrpClient := ACQ->ACQ_GRPVEN
				
			If !Empty(cGrpClient)
				// Avalio se o Grupo de clientes esta preenchido na regra de bonificacao e se o cliente se enquadra
				If cGrpClient != Posicione("SA1",1,xFilial("ACQ")+cCliente+cLoja,"A1_GRPVEN")
					lBonifica := .F.
				EndIf
			EndIf
						
			If lBonifica
				// Verificacao da data e hora
				lBonifica := STBVldDateBonus()
			EndIf
			
			If lBonifica
				// Verificacao de quantidade	
				
				If !Empty(ACQ->ACQ_LOTE)
					nLote := ACQ->ACQ_LOTE
				EndIf
				
				If ACQ->ACQ_TPRGBN == "1" 
					/* 
					Verifica se todos os itens da regra de bonificacao estao na venda e se atende a regra.			
					*/	
				
					// Caso ACQ_LOTE esteja preenchido no cabecalho, somente ele sera considerado.
					// Caso contrario, sera feita a busca pelo lote de cada item.
					lBonifica := STBItensBonus( cRegraBon, ACQ->ACQ_LOTE, nTimesUsed )
					
				ElseIf ACQ->ACQ_TPRGBN == "2"   
					// Caso haja a necessidade de comprar Somente Um dos produtos bonificadores.			
					nQuantTotal := STDQuantProd(cCodProd)				
					
					If Empty(nLote) // Caso o lote de quantidade do cabecalho nao tenha sido preenchido
						nLote := STDBSGtQtd( cRegraBon, cCodProd )
					EndIf
					
					If nLote > nQuantTotal
						lBonifica := .F.
					ElseIf nQuantTotal > nLote  // Caso a quantidade total do produto seja maior que o numero do lote, verifico se a regra foi contemplada novamente.
					
						/*
							Abaixo, nQuantVerf recebe o resto (caso exista) da regra de bonificacao, mais os itens recem lancados.
							Isso é necessario para reavaliar se a regra sera aplicada.
						*/
						nQuantVerf := ((nQuantTotal - nQuantItem)%nLote)+nQuantItem 
						lBonifica := .F.
						For nX := 1 To nQuantVerf
							If	nX % nLote == 0
								lBonifica := .T.
								Exit
							EndIf					
						Next nX
					EndIf
				EndIf
			EndIf		
		Else
			lBonifica := .F.			
		EndIf
	EndIf
Else
	lBonifica := .F.
EndIf

If lBonifica

	If nPosRegra > 0 // Caso a regra ja tenha sido utilizada na venda, incrementa o contador do numero de vezes que a regra foi aplicada
		aUsedRules[nPosRegra,2] := nTimesUsed+1
	Else
		Aadd(aUsedRules,{cRegraBon,1,cCodProd})
	EndIf
	
	STDBS7Rules( aUsedRules )

EndIf

RestArea(aArea)

Return lBonifica


//--------------------------------------------------------
/*{Protheus.doc} STBVldDateBonus
Avalia se a venda esta dentro da data e hora especificada para contemplar a regra da bonificacao.
@author  Varejo
@version P11.8
@since   21/08/2012
@return  lRet - retorna se Validou a bonificacaoa bonificacao 
@obs     
@sample
*/
//--------------------------------------------------------
Static Function STBVldDateBonus()

Local lRet 		:= .F.						// Retorno
Local cHoraAtual	:= SUBSTR(Time(), 1, 5) // Pego apenas as horas e minutos atuais.

//Caso o tipo de horario seja unico (Regra eh valida da hora inicial do primeiro dia até a hora final do último dia)	
If ACQ->ACQ_TPHORA == "1" 	
	
	// Caso a data atual esteja entre a Data Inicial e a Data Final da Regra de Bonificacao
	If dDataBase > ACQ->ACQ_DATDE .And. (dDataBase < ACQ->ACQ_DATATE .Or. Empty(ACQ->ACQ_DATATE)) 	
		lRet := .T.
	
	//Caso a data atual seja maior que a data inicial e a data final esteja em branco.
	ElseIf dDataBase > ACQ->ACQ_DATDE .AND. Empty(ACQ->ACQ_DATATE) 				
		lRet := .T.
	
	// Caso a Data atual seja igual a Data Inicial da Regra de Bonificacao	
	ElseIf dDataBase == ACQ->ACQ_DATDE 
	
		//Se a hora atual for maior ou igual que a hora inicial da Regra de Bonificacao
		If cHoraAtual >= ACQ->ACQ_HORADE 	
			lRet := .T.
		EndIf
		
	// Caso a Data atual seja igual a Data Final da Regra de Bonificacao
	ElseIf dDataBase == ACQ->ACQ_DATATE 	
	
		//Se a hora atual for menor ou igual que a hora final da Regra de Bonificacao
		If cHoraAtual <= ACQ->ACQ_HORATE 	
			lRet := .T.
		EndIf	
	EndIf

/* 
	Caso o tipo de horario seja recorrente (Regra valida do dia inicial ao final, somente durante os horarios
	que estiverem entre o horario inicial e o horario final).
*/	
ElseIf ACQ->ACQ_TPHORA == "2"
			
	// Caso a data atual seja maior ou igual a data inicial da regra da bonificacao
	If dDataBase >= ACQ->ACQ_DATDE 
											
		// Caso a data atual seja menor ou igual a data final da regra da bonificacao, ou caso a data final esteja vazia
		If dDataBase <= ACQ->ACQ_DATATE .OR. Empty(ACQ->ACQ_DATATE)	
													
			// Caso a hora atual seja maior ou igual que a hora inicial E menor ou igual que a hora final da regra da bonificacao	
			If cHoraAtual >= ACQ->ACQ_HORADE .AND. cHoraAtual <= ACQ->ACQ_HORATE																				
				lRet := .T.
			EndIf				
		EndIf
	EndIf													
EndIf

Return lRet


//--------------------------------------------------------
/*{Protheus.doc} STBItensBonus
Verifica se todos os produtos foram comprados e se a quantidade atende a regra de bonificacao

@param   cRegraBon - Codigo da regra da bonificacao
@param   nLoteCab  - Conteudo do campo lote do cabecalho. Se vier zerado, sera considerado o lote de cada item.
@author  Varejo
@version P11.8
@since   22/08/2012
@return  .T. se atende a bonificacao / .F. Se nao atende a bonificacao
@obs     
@sample
*/
//--------------------------------------------------------
Function STBItensBonus( cRegraBon, nLoteCab, nTimesUsed )

Local aArea		        := GetArea()	// Guarda area
Local lRet 		        := .T.			// Retorno
Local nQuant	        := 0			// Quantidade
Local nLote		        := 0			// Lote
Local lLoteCab	        := .F.			// Lote Cabechalho
Local nX                := 0            // Contador do For
Local lAchou            := .F.          // Verifica se o item foi encontrado

DEFAULT cRegraBon	:= ""
DEFAULT nLoteCab	:= 0

ParamType 0 Var cRegraBon AS Character	Default ""
ParamType 1 Var nLoteCab  AS Numeric	Default 0

If !Empty(nLoteCab) //Se algum valor for passado, somente o nLoteCab sera considerado.
	lLoteCab := .T.
EndIf

DbSelectArea("ACR")
ACR->(DbSetOrder(1))
If ACR->(MsSeek(xFilial("ACR")+cRegraBon))

	// Quando o cabecalho esta preenchido, a quantidade de todos os itens que fazem parte da regra
	// de bonificacao devem ser maior do que o lote do cabecalho.	
	If lLoteCab 
				 
		While !EOF() .AND. ACR->ACR_FILIAL == xFilial("ACR") .AND. ACR->ACR_CODREG == cRegraBon
			
			lAchou := .F.
			
			For nX := 1 To STDPBLength("SL2")
				
				If ACR->ACR_CODPRO == STDGPBasket( "SL2" , "L2_PRODUTO" , nX ) // Verifica se o produto existe na cesta
					lAchou := .T.
					nQuant += STDQuantProd(ACR->ACR_CODPRO)
					Exit
				EndIf
				
			Next nX
			
			If !lAchou
				Exit
			EndIf
			
			ACR->(DbSkip())
		EndDo
		
		If !lAchou	
			lRet := .F.
		EndIf
		
		If lRet .AND. nLoteCab > nQuant
			lRet := .F.
		EndIf
		
	Else
		While !EOF() .AND. ACR->ACR_FILIAL == xFilial("ACR") .AND. ACR->ACR_CODREG == cRegraBon
		
			nQuant := STDQuantProd(ACR->ACR_CODPRO)
			nLote  := ACR->ACR_LOTE
			
			If nTimesUsed > 0
				nLote := nLote * (nTimesUsed+1)
			EndIf
			
			If nLote > nQuant
				lRet := .F.
				Exit
			EndIf
			ACR->(DbSkip())
			
		EndDo 
	EndIf
EndIf

RestArea(aArea)

Return lRet

//--------------------------------------------------------
/*{Protheus.doc} STBPrdSale
Essa função tem por objetivo verificar quais os itens lancados
na venda e retornar um array contendo o codigo do produto e a
quantidade vendida.

@author  Bruno Almeida
@version P12
@since   21/08/2019
@return  aItens
		{ 1: Produto SL2,
		  2: Quantidade SL2,
		  3: Quantidade MB8 que será lido em STBPrdBonf(),
		  4: Array lido em STDPesqMGB()
		    {1: Produto MGB, 2: Quantidade MGB},
		  5: Categoria (Se Houver)
		}
*/
//--------------------------------------------------------
Function STBPrdSale()

Local oModelCesta 	:= STDGPBModel() //Model completo da cesta de vendas
Local oItens 		:= oModelCesta:GetModel('SL2DETAIL') //Model somente da SL2
Local aItens		:= {} //Array contendo todos os itens da venda agrupados por item
Local nIt			:= 0 //Posicao do item no array
Local nX			:= 0 //Variavel de loop
Local cCateg		:= ""	//Código da Categoria

For nX := 1 To oItens:Length()
	oItens:GoLine(nX)
	If !oItens:IsDeleted()
		nIt := aScan(aItens, {|x| AllTrim(x[1]) == AllTrim(oItens:GetValue('L2_PRODUTO')) })
		If nIt > 0
			aItens[nIt][2] += oItens:GetValue('L2_QUANT')
		Else	//Categoria, se houver
			cCateg := STBCdCt(oItens:GetValue('L2_PRODUTO'))
			If Empty(cCateg)	//Produto
				aAdd(aItens,{oItens:GetValue('L2_PRODUTO'), oItens:GetValue('L2_QUANT'), 0, {}, ""})
			Else				//Categoria
				nIt := aScan(aItens, {|x| AllTrim(x[5]) == Alltrim(cCateg) })			//Pesquisa por Categoria
				IF nIt > 0
					aItens[nIt][2] += oItens:GetValue('L2_QUANT')
				Else
					aAdd(aItens,{"", oItens:GetValue('L2_QUANT'), 0, {}, cCateg})
				EndIf
			EndIf
		EndIf
	EndIf
Next nX

Return aItens

//--------------------------------------------------------
/*{Protheus.doc} STBPrdBonf
Essa função tem por objetivo verificar dos itens que foram vendidos,
quais o cliente tem direito de ganhar a bonificacao.

@author  Bruno Almeida
@version P12
@since   21/08/2019
@return  Nil
*/
//--------------------------------------------------------
Function STBPrdBonf()

Local aItens	:= STBPrdSale() //Retorna as qtd dos produtos/categorias da venda aglutinados
Local aRegras	:= IIF(ExistFunc('STDPesqMei'),STDPesqMei(),{}) //Busca as regras ativas
Local lFunc		:= ExistFunc('STDPesqMb8') .AND. ExistFunc('STDPesqMgb')
Local aProdBoni	:= {} //Guarda os produtos 
Local nX		:= 0 //Variavel de loop
Local nI		:= 0 //Variavel de loop

//Verifica quais as regras que estao ativas
If lFunc
	For nX := 1 To Len(aRegras)
 		For nI := 1 To Len(aItens)

			If (aItens[nI][3] = 0)  //Se aItens[nI][3] tiver maior que 0, não entra, pois já preencheu sua quantidade na MB8 e seu produto vinculado
				//Verifica se para cada item da venda contém uma regra de bonificacao
				If STDPesqMb8(aRegras[nX], aItens[nI][1], aItens[nI][5])		//aItens[nI][1]=Produto lançado e aItens[nI][2]=Qtde. lançada. aItens[nI][5]=Categoria.
					aProdBoni := STDPesqMgb(aRegras[nX], PadL(MB8->MB8_REFGRD, TamSX3("MB8_REFGRD")[1], "0") + "MB8")
					aItens[nI][3] := MB8->MB8_QTDPRO
					aItens[nI][4] := aProdBoni
				EndIf
			EndIf

		Next nI
	Next nX
EndIf

Return aItens

//--------------------------------------------------------
/*{Protheus.doc} STBValBonf
Essa função tem por objetivo verificar retornar o valor
que sera bonificado.

@author  Bruno Almeida
@version P12
@since   21/08/2019
@return  nValBonfTot (Valor total bonificado)
*/
//--------------------------------------------------------
Function STBValBonf()

Local aItens 		:= STBPrdBonf()			//Aglutinado por Produto/Categoria com seu valor bonificado
Local nX			:= 0	//Variavel de loop
Local nI			:= 0	//Variavel de loop
Local nValBonfTot	:= 0	//Retorna o valor que sera bonificado
Local cProd			:= ''	//Recebe o codido do produto
Local nQtdBonificar := 0	//Quantidade que sera bonificado
Local nQtdBonfIt	:= 0	//Quantidade Bonificada por Item
Local nValBonfIt	:= 0	//Valor Bonificado por Item
Local lTemCateg		:= .F.	//O produto bonificado CONSTA no produto que pertence a uma CATEGORIA

STBAcZrBf()	//Zera valor por produto bonificado

//Verifica o valor total da bonificacao
For nX := 1 To Len(aItens)

	If Len(aItens[nX]) > 3 

		For nI := 1 To Len(aItens[nX][4])

			cProd := AllTrim(aItens[nX][4][nI][1])

			If !Empty(cProd)
				nIt := aScan(aItens, {|x| AllTrim(x[1]) == AllTrim(cProd) })
				lTemCateg := Iif(nIt == 0 .AND. !Empty(aItens[nX][5]), STBConstCt(aItens[nX][5],cProd), .F.)			//O produto bonificado CONSTA no produto que pertence a uma CATEGORIA

				If (nIt > 0) .OR. lTemCateg

					If (Alltrim(aItens[nX][1]) == cProd .AND. Empty(aItens[nX][5]));		//Se for O MESMO PRODUTO tanto bonificador como bonificado, a fórmula abaixo calculará a qtd. bonificada. Ex: Se 10 e bonificou 1: Eu teria que vender manualmente 11 e não 10 para atingir 1 bonificação.
																	.OR. (lTemCateg)		//Idem para Categoria
						nQtdBonfIt := STBBfSamePrd(aItens[nX][2],aItens[nX][3],aItens[nX][4][nI][2])
					Else
						nQtdBonificar := Int(aItens[nX][2] / aItens[nX][3]) * aItens[nX][4][nI][2]		//Quantidade do item vendido SL2 / Quantidade do item bonificado MB8 * a Quantidade Máxima da Bonificação por item relacionado MGB
						nQtdBonfIt := IIF(nQtdBonificar > aItens[nIt][2], aItens[nIt][2], nQtdBonificar)
					EndIf
					nValBonfIt := STBSearchPrice(aItens[nX][4][nI][1]) * nQtdBonfIt 					
					
					If nQtdBonfIt > 0

						nValBonfTot += nValBonfIt
						STBAcPrdBf(cProd,nQtdBonfIt,nValBonfIt)		//Aglutino o valor bonificado por aquele produto						

					EndIf

				EndIf
			EndIf

		Next nI

	EndIf

Next nX

STBDistrBf() //Distribuir o valor bonificado na SL2

Return nValBonfTot

//--------------------------------------------------------
/*{Protheus.doc} STBFormBf
Funcao responsavel em incluir a forma de pagamento bonificacao
na tela de pagamento
OBS: Entrará somente se foi validado na Regra de Desconto.

@author  Bruno Almeida
@version P12
@since   21/08/2019
@return  lRet (se nVlBonif > 0)
*/
//--------------------------------------------------------
Function STBFormBf()

Local nVlBonif 	:= 0
Local lRet      := .F.

If GetAPOInfo("STFTOTALUPDATE.PRW")[4] >= Ctod("19/12/2019")
	nVlBonif 	:= STBValBonf()
	STFSetTot( "L1_BONIF", nVlBonif )
	If nVlBonif > 0
		lRet := .T.
	EndIf
EndIf

Return lRet


//--------------------------------------------------------
/*{Protheus.doc} STBAcZrBf()
Funcao responsavel em zerar a variável statica de valor da bonificação por produto
OBS: Entrará somente se foi validado na Regra de Desconto.

@author  Marisa Cruz
@version P12
@since   10/01/2020
@return  nil
*/
//--------------------------------------------------------
Function STBAcZrBf()

aBfPrdVal := {}

Return nil


//--------------------------------------------------------
/*{Protheus.doc} STBAcPrdBf()
Funcao responsavel em acumular a variável statica de valor da bonificação por produto
OBS: Entrará somente se foi validado na Regra de Desconto.

Composição do elemento em aBfPrdVal:
1-Produto
2-Quantidade a bonificar em STBAcPrdBF() antes de distribuir em STBDistrBF()
3-Valor total a bonificar em STBAcPrdBF() antes de distribuir em STBDistrBF()
4-Quantidade a bonificar após distribuir em STBDistrBF()
5-Valor total a bonificar após distribuir em STBDistrBF()
Para os itens 4 e 5, é válido para cálculo de SALDO TOTAL.

@author  Marisa Cruz
@version P12
@since   10/01/2020
@return  nil
*/
//--------------------------------------------------------
Function STBAcPrdBf(cProd,nQtdBonfIt,nValBonfIt)

Local nPosProd := 0


Default nQtdBonfIt := 0
Default nValBonfIt := 0

nPosProd := aScan(aBfPrdVal,{|x| AllTrim(x[1]) == AllTrim(cProd)})	//Pesquiso o produto na static
If nPosProd > 0
	aBfPrdVal[nPosProd][2] += nQtdBonfIt 
	aBfPrdVal[nPosProd][3] += nValBonfIt
Else
	aAdd(aBfPrdVal, {cProd,nQtdBonfIt,nValBonfIt,0,0})
EndIf

Return nil


//--------------------------------------------------------
/*{Protheus.doc} STBDistrBf()
Funcao responsavel em distribuir os valores bonificados por produto na SL2
OBS: Entrará somente se foi validado na Regra de Desconto.

Composição do elemento em aBfPrdVal:
1-Produto
2-Quantidade a bonificar em STBAcPrdBF() antes de distribuir em STBDistrBF()
3-Valor total a bonificar em STBAcPrdBF() antes de distribuir em STBDistrBF()
4-Quantidade a bonificar após distribuir em STBDistrBF()
5-Valor total a bonificar após distribuir em STBDistrBF()
Para os itens 4 e 5, é válido para cálculo de SALDO TOTAL.

@author  Marisa Cruz
@version P12
@since   10/01/2020
@return  nil
*/
//--------------------------------------------------------
Function STBDistrBf()

Local oModelCesta 	:= STDGPBModel() //Model completo da cesta de vendas
Local oItens 		:= oModelCesta:GetModel('SL2DETAIL') //Model somente da SL2
Local nItQuant   := 0
Local nItValor   := 0
Local nSldQuant  := 0
Local nSldValor  := 0
Local nX         := 0
Local lVazio	 := .F.

//Revisão de bonificação por item em SL2
For nX := 1 To oItens:Length()
	lVazio := .F.
	oItens:GoLine(nX)
	
	nPos := Ascan(aBfPrdVal, {|x| Alltrim(x[1]) = Alltrim(oItens:GetValue('L2_PRODUTO')) })
	If nPos > 0		//O item do produto foi bonificado
		nItQuant := oItens:GetValue('L2_QUANT')
		nItValor := oItens:GetValue('L2_VLRITEM')
		nSldQuant := aBfPrdVal[nPos][2]-aBfPrdVal[nPos][4]
		nSldValor := aBfPrdVal[nPos][3]-aBfPrdVal[nPos][5]
		
		If nSldQuant > 0 //Gravo só se tiver saldo
			STDSPBasket( "SL2" , "L2_PREMIO" , "B" , nX )
			If nSldQuant < nItQuant											
				STDSPBasket( "SL2" , "L2_VLDESRE", nSldValor, nX )			//Atribuo o Saldo do valor da bonificação
				aBfPrdVal[nPos][4] := aBfPrdVal[nPos][4] + nSldQuant		//Assinalo como Produto Bonificado
				aBfPrdVal[nPos][5] := aBfPrdVal[nPos][5] + nSldValor		//Por enquanto, utilizaremos em L2_VLDESCR a gravação do valor bonificado
			Else															
				STDSPBasket( "SL2" , "L2_VLDESRE", nItValor, nX )			//Atribuo o valor do item
				aBfPrdVal[nPos][4] := aBfPrdVal[nPos][4] + nItQuant			//Assinalo como Produto Bonificado
				aBfPrdVal[nPos][5] := aBfPrdVal[nPos][5] + nItValor			//Por enquanto, utilizaremos em L2_VLDESCR a gravação do valor bonificado
			EndIf
		Else
			lVazio := .T.		//Item sem bonificação
		EndIf
	Else
		lVazio := .T.			//Item sem bonificação
	EndIf
		
	If lVazio															//Se item não foi vendido como bonificado, gravo em branco
		STDSPBasket( "SL2" , "L2_PREMIO" , "" , nX )					//Assinalo como Produto Bonificado
		STDSPBasket( "SL2" , "L2_VLDESRE",  0 , nX )					//Por enquanto, utilizaremos em L2_VLDESCR a gravação do valor bonificado
	EndIf
	
Next nX

Return nil


//--------------------------------------------------------
/*{Protheus.doc} STBBfSamePrd()
Utilizado somente se o produto bonificado tem correlação com o MESMO produto
OBS: Entrará somente se foi validado na Regra de Desconto.

Exemplo:
A cada 50 celulares, o 51º será bonificado.
Logo, deverá lançar 51 celulares para receber automaticamente 1 produto bonificado.

Caso a cada 100 unidades, ganha 5 de bonificação, obedeceremos a seguinte escala:
* Lembrando que temos que lançar 105 para receber 5 de bonificação *
Se lançou 100 (entradas 100,100,5), retorna 0.
Se lançou 101 (entradas 101,100,5), retorna 1.
Se lançou 102 (entradas 102,100,5), retorna 2.
Se lançou 103 (entradas 103,100,5), retorna 3.
Se lançou 104 (entradas 104,100,5), retorna 4.
Se lançou 105 (entradas 105,100,5), retorna 5.
Se lançou 106 até 205, recebe 5.
Se lançou 206 (entradas 206,100,5), retorna 6.
Se lançou 207 (entradas 207,100,5), retorna 7.
Se lançou 208 (entradas 208,100,5), retorna 8.
Se lançou 209 (entradas 209,100,5), retorna 9.
Se lançou 210 (entradas 210,100,5), retorna 10.
Se lançou 211 até 310, recebe 10.
Se lançou 311 (entradas 311,100,5), retorna 11.
Se lançou 312 (entradas 312,100,5), retorna 12.
Se lançou 313 (entradas 313,100,5), retorna 13.
Se lançou 314 (entradas 314,100,5), retorna 14.
Se lançou 315 (entradas 315,100,5), retorna 15.

@author  Marisa Cruz
@version P12
@since   16/01/2020
@return  nRet (a qtd. bonificada)
*/
//--------------------------------------------------------
Static Function STBBfSamePrd(nQtdVend,nQtdaBonfMB8,nQtdBonfMGB)

Local nResto 			:= 0		//O resto da divisão da quantidade da venda sobre a quantidade bonificada
Local nMb8maisMgb 		:= 0		//Soma da quantidade a bonificar MB8 + quantidade bonificada MGB

Default nQtdVend 		:= 0		//Quantidade de item vendido SL2
Default nQtdaBonfMB8 	:= 0		//Quantidade A BONIFICAR MB8
Default nQtdBonfMGB 	:= 0		//Quantidade BONIFICADA MGB

nMb8maisMgb := nQtdaBonfMB8+nQtdBonfMGB //Somo as duas quantidades: a bonificar MB8 e a bonificada MGB

nRet := Int(nQtdVend / nMb8maisMgb) * nQtdBonfMGB
nResto := nQtdVend % nMb8maisMgb  //Resto de qtd. vendida e nMb8maisMgb

If nResto > nQtdaBonfMB8
	nRet := nRet + (nResto-nQtdaBonfMB8)
EndIf

Return nRet


//--------------------------------------------------------
/*{Protheus.doc} STBCdCt
Retorna o primeiro código da categoria daquele produto mencionado

@author  marisa.cruz
@version P12
@since   22.07.2020
@params  cCodProd, Carácter, Código do Produto 
@return  cCodCat, carácter, Código da Categoria
*/
//--------------------------------------------------------
Static Function STBCdCt(cCodProd)

Local cCodCat 		:= ""
Local aArea 		:= GetArea()
Local cGrupo 		:= ""

Default cCodProd 	:= ""

DbSelectArea("ACV")                              
DbSetOrder(5) //ACV_FILIAL+ACV_CODPRO+ACV_CATEGO

If ACV->(DbSeek(xFilial("ACV")+PadR(Alltrim(cCodProd),TamSx3("ACV_CODPRO")[1])))
	cCodCat := ACV->ACV_CATEGO
Else
	DbSelectArea("SB1")
	SB1->(DbSetOrder(1)) //B1_FILIAL + B1_COD
	If SB1->(DbSeek(xFilial("SB1") + PadR(AllTrim(cCodProd), TamSx3("ACV_CODPRO")[1])))
		
		cGrupo := SB1->B1_GRUPO
		ACV->(DbSetOrder(2)) //ACV_FILIAL + ACV_GRUPO + ACV_CODPRO + ACV_CATEGO
		
		If ACV->(DbSeek(xFilial("ACV") + PadR(Alltrim(cGrupo),TamSx3("ACV_GRUPO")[1])))
        	cCodCat := ACV->ACV_CATEGO
		EndIf
    EndIf
EndIf

RestArea( aArea )
Return cCodCat


//--------------------------------------------------------
/*{Protheus.doc} STBConstCt
Verifica se o produto faz parte da categoria

@author  marisa.cruz
@version P12
@since   22.07.2020
@params  cCodCat, Carácter, Código da Categoria
@params  cCodProd, Carácter, Código do Produto 
@return  lRet, Lógico, Se o produto pertence à categoria
*/
//--------------------------------------------------------
Function STBConstCt(cCodCat, cCodProd)

Local lRet 			:= .F.
Local aArea 		:= GetArea()
Local cGrupo 		:= ""

Default cCodCat 	:= ""
Default cCodProd 	:= ""

DbSelectArea("ACV")                              
DbSetOrder(5) //ACV_FILIAL+ACV_CODPRO+ACV_CATEGO

If ACV->(DbSeek(xFilial("ACV")+PadR(Alltrim(cCodProd),TamSx3("ACV_CODPRO")[1])+PadR(Alltrim(cCodCat),TamSx3("ACV_CATEGO")[1])))	//Verifica se o produto faz parte da categoria
	lRet := .T.
Else
	DbSelectArea("SB1")
	SB1->(DbSetOrder(1)) //B1_FILIAL + B1_COD
	If SB1->(DbSeek(xFilial("SB1") + PadR(AllTrim(cCodProd), TamSx3("ACV_CODPRO")[1])))
		
		cGrupo := SB1->B1_GRUPO
		ACV->(DbSetOrder(2)) //ACV_FILIAL + ACV_GRUPO + ACV_CODPRO + ACV_CATEGO

		If ACV->(DbSeek(xFilial("ACV") + PadR(Alltrim(cGrupo),TamSx3("ACV_GRUPO")[1])))
        	lRet := .T.
		EndIf
    EndIf
EndIf

RestArea( aArea )

Return lRet
