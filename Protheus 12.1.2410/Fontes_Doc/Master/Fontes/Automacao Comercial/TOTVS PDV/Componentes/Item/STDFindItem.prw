#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STPOS.CH"
#INCLUDE "STDFindItem.CH"

Static aStartProds //Array contendo os produtos em memória

//-------------------------------------------------------------------
/*/{Protheus.doc} STDFindItem
Busca Item na tabela de produtos

@param   cCodeReceived			Codigo recebido/digitado
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aRet						Array com informações do Item
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDFindItem( cCodeReceived, lPAFECF, 		lHomolPaf )
Local			aArea			:= GetArea() 							// Guarda area atual
Local 			lFindItem 		:= .F.									// Encontrou Item?
Local 			aRet 			:= {}									// Retorno
Local			nTamProd		:= TamSx3("B1_COD")[1] 					// Tamanho codigo produto
Local 			nTamCodBar		:= TamSx3("B1_CODBAR")[1] 				// Tamanho codigo de barra
Local 			cLOCPAD 		:= ""
Local 			cORIGEM 		:= ""
Local 			cCODISS       	:= "" 
Local 			cTS				:= ""

Default		cCodeReceived	:= ""										// Codigo recebido/digitado
Default 	lPAFECF			:= StbIsPaf()
Default		lHomolPaf		:= StbHomolPaf()

//Inicializa variaveis de retorno
aRet := STDIniRet()
/*
	Procura na SB1 pelo Indice 1 ( B1_FILIAL + B1_COD )
*/		
DbSelectArea("SB1")
SB1->(DbSetOrder(1))	//B1_FILIAL+B1_COD
If 	DbSeek( xFilial("SB1") + Padr(cCodeReceived,nTamProd))
	lFindItem := .T.   
EndIf	

/*
	Se nao achou o Item	
	Procura na SB1 pelo Indice 5 ( B1_FILIAL + B1_CODBAR )
*/	
If	(!lFindItem)	
	DbSelectArea("SB1")
	DbSetOrder(5) //B1_FILIAL+B1_CODBAR
	If 	DbSeek	( xFilial("SB1") + Padr(cCodeReceived,nTamCodBar) )		
	lFindItem := .T.   		   						
	EndIf												
EndIf	

/*
	Se achou o Item	
	Verifica se o item esta bloqueado e atribui variaveis de retorno
*/	
If	lFindItem
	/*Tratamento para Quantidade para itens que não tenham quantidade na tabela SLK*/
	If STBGetQuant(2) > 0
		STBSetQuant(STBGetQuant(2),1) 	//Retomo a Qtd de backup a Qtd oficial
		STBSetQuant(0,2) 				//Zero o Qtd de backup
	EndIf 

	aRet[ITEM_ENCONTRADO]	:= .T.					//	01 - Encontrou Item?
	aRet[ITEM_CODIGO] 		:= SB1->B1_COD			// 02 - Codigo do Item encontrado
	aRet[ITEM_CODBAR] 		:= SB1->B1_CODBAR		// 03 - Codigo de barras do Item encontrado
	
	If SB1->B1_MSBLQL=="1"		
		aRet[ITEM_BLOQUEADO]:= .T. 					// 04 - O item esta bloqueado para venda
	EndIf

	cLOCPAD 				:= RetFldProd(SB1->B1_COD,"B1_LOCPAD")
	cORIGEM 				:= RetFldProd(SB1->B1_COD,"B1_ORIGEM")
	cCODISS       			:= RetFldProd(SB1->B1_COD,"B1_CODISS")
	cTS						:= RetFldProd(SB1->B1_COD,"B1_TS")

	aRet[ITEM_TES] 			:= Iif(Empty(cTS), SB1->B1_TS, cTS)				// 06 - TES do item
	aRet[ITEM_BALANCA] 		:= SB1->B1_BALANCA								// 07 - Tipo produto de balanca
	aRet[ITEM_DESCRICAO] 	:= SB1->B1_DESC									// 08 - Descrição do item
	aRet[ITEM_UNID_MEDIDA] 	:= SB1->B1_UM									// 09 - Unidade de Medida do item
	aRet[ITEM_ARMAZEMPAD] 	:= Iif(Empty(cLOCPAD), SB1->B1_LOCPAD, cLOCPAD)	// 10 - Armazem Padrão do item
	aRet[ITEM_TIPO]			:= SB1->B1_TIPO									// 11 - Tipo do Produto
	aRet[ITEM_ORIGEM] 		:=  Iif(Empty(cOrigem), SB1->B1_ORIGEM, cOrigem)// 11 - Código Origem
	aRet[ITEM_CODISS] 		:=  Iif(Empty(cCodISS), SB1->B1_CODISS, cCodISS)// 12 - Codigo ISS
	aRet[ITEM_POSIPI] 		:= SB1->B1_POSIPI								// 13 - POSIPI
	aRet[ITEM_INT_ICM]		:=	SB1->B1_INT_ICM   							// 14 - INT_ICM
	aRet[ITEM_EX_NCM]		:= SB1->B1_EX_NCM								// 20 - Extensao NCN
	aRet[ITEM_RECNO]		:= SB1->(RECNO())								// 24 - Recno do Produto na tabela SB1

	If lPAFECF
		STDVlItPAF(@aRet,lHomolPAF)
	EndIf
		
EndIf

//Restaura area anterior	
RestArea(aArea)
			
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STDFItemCB
Busca Item na tabela de codigos de barras

@param   cCodeReceived			Codigo recebido/digitado
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aRet						Array com informações do Item
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDFItemCB( cCodeReceived, lPAFECF,lHomolPaf)
Local aArea			:= GetArea() 							// Guarda area atual
Local lFindItem 	:= .F.									// Encontrou Item?
Local aRet 			:= {}									// Retorno
Local nTamCodBar	:= TamSx3("LK_CODBAR")[1]				// Tamanho do Codigo de barras
Local lCpoTotImp 	:= SB1->(ColumnPos("B1_IMPNCM")) > 0	// Lei dos impostos
Local nVlrImpNCM 	:= 0 									// Valor do imposto vindo a partir do codigo da NCM - Lei dos impostos
Local cLOCPAD 		:= ""
Local cORIGEM 		:= ""
Local cCODISS       := ""
Local nIMPNCM 		:= 0 
Local cTS			:= ""									// TES do item
Local lIsItemOrc	:= Iif( ExistFunc("STBGItemOrc"), STBGItemOrc(), .F.) //Quando os itens do Orçamento estiverem sendo registrados, essa rotina retorna .T., quando finaliza, retorna .F.

Default cCodeReceived	:= ""								// Codigo recebido/digitado
Default lPAFECF			:= StbIsPaf()
Default	lHomolPaf		:= StbHomolPaf()

//Inicializa variaveis de retorno
aRet := STDIniRet()
	
/*
	Procura Pela SLK Indice 1 ( LK_FILIAL + LK_CODBAR )
*/
If !lIsItemOrc //Quando é chamada pela importação de orçamento não pode consultar Cod Barra, pois o parametro Codigo é L2_Cod e não L2_CodBar
	
	DbSelectArea("SLK")
	DbSetOrder(1)	//LK_FILIAL + LK_CODBAR
	If 	DbSeek( xFilial("SLK") + Padr(cCodeReceived,nTamCodBar))

		LjGrvLog( "STDFItemCB", "Achou SLK ",SLK->LK_CODIGO)

		/*
			Se achou o Item na SLK Busca na tabela SB1
			Procura Pelo SB1 Indice 1 ( B1_FILIAL + B1_COD )							
		*/
		DbSelectArea("SB1")
		DbSetOrder(1)	//B1_FILIAL+B1_COD
		If 	DbSeek	( xFilial("SB1") + SLK->LK_CODIGO )
		lFindItem := .T.   
		LjGrvLog( "STDFItemCB", "Achou SB1 ",SB1->B1_COD	)
		EndIf
				
	EndIf	
				
	/*
		Se achou o Item	
		Verifica se o item esta bloqueado e atribui variaveis de retorno
	*/	
	If	lFindItem
		
		aRet[ITEM_ENCONTRADO]	:= .T.					// 01 - Encontrou Item?
		aRet[ITEM_CODIGO] 		:= SB1->B1_COD			// 02 - Codigo do Item encontrado
		aRet[ITEM_CODBAR] 		:= SLK->LK_CODBAR		// 03 - Codigo de barras do Item encontrado
		
		If SB1->B1_MSBLQL=="1"		
			aRet[ITEM_BLOQUEADO] := .T. 				// 04 - O item esta bloqueado para venda
		EndIf
		
		/*
			Se alterar a quantidade do item pela quantidade 
			encontrada na	tabela de codigo de barras  
		*/
		If SLK->LK_QUANT > 1
			STBSetQuant(1) 
			aRet[ITEM_QTDE] := ( Iif (STBGetQuant(2) == 0,1,STBGetQuant(2)) * SLK->LK_QUANT )  // 05 - Quantidade do item 
		Else 
			If (STBGetQuant(2) > 0 .And. STBGetQuant(2) < 1) .Or. STBGetQuant(2) > 1 //Se a quantidade for 1 indica que ja realizou o ajuste
				STBSetQuant(STBGetQuant(2)) 
				STBSetQuant(1,2)
			EndIf 
		EndIf	
		
		cLOCPAD 				:= RetFldProd(SB1->B1_COD,"B1_LOCPAD")
		cORIGEM 				:= RetFldProd(SB1->B1_COD,"B1_ORIGEM")
		cCODISS       			:= RetFldProd(SB1->B1_COD,"B1_CODISS")
		aRet[ITEM_BALANCA] 		:= SB1->B1_BALANCA								// 07 - Tipo produto de balanca
		aRet[ITEM_DESCRICAO] 	:= SB1->B1_DESC									// 08 - Descrição do item
		aRet[ITEM_UNID_MEDIDA] 	:= SB1->B1_UM									// 09 - Unidade de Medida do item
		aRet[ITEM_ARMAZEMPAD] 	:= Iif(Empty(cLOCPAD), SB1->B1_LOCPAD, cLOCPAD)	// 10 - Armazem Padrão do item
		aRet[ITEM_TIPO]			:= SB1->B1_TIPO									// 11 - Tipo do Produto
		aRet[ITEM_CODISS] 		:= Iif(Empty(cCodISS), SB1->B1_CODISS, cCodISS) // 12 - Codigo ISS
		aRet[ITEM_POSIPI] 		:= SB1->B1_POSIPI								// 13 - POSIPI
		aRet[ITEM_INT_ICM]		:= SB1->B1_INT_ICM   							// 14 - INT_ICM
		aRet[ITEM_ORIGEM] 		:= Iif(Empty(cORIGEM), SB1->B1_ORIGEM, cORIGEM) // 16 - Código Origem
		aRet[ITEM_EX_NCM]		:= SB1->B1_EX_NCM								// 20 - Extensao NCN	
				
		If SB1->B1_MSBLQL=="1"		
			aRet[ITEM_BLOQUEADO]:= .T. 											// 04 - O item esta bloqueado para venda
		EndIf

		cTS				:= RetFldProd(SB1->B1_COD,"B1_TS")
		aRet[ITEM_TES] 	:= Iif(Empty(cTS), SB1->B1_TS, cTS)						// 06 - TES do item

		If lPAFECF
			STDVlItPAF(@aRet,lHomolPAF)                    
		EndIf
		
		//Lei dos impostos
		If lCpoTotImp    
			nIMPNCM		:= RetFldProd(SB1->B1_COD,"B1_IMPNCM")
			nVlrImpNCM		:= Iif(Empty(nIMPNCM ), SB1->B1_IMPNCM, nIMPNCM ) 
		EndIf		

		If nVlrImpNCM ==0 .AND. !Empty(SB1->B1_POSIPI)
			cCodISS 	:= Iif(Empty(cCodISS), SB1->B1_CODISS, cCodISS)
			nVlrImpNCM	:= Lj7BuscaImp(SB1->B1_POSIPI,!Empty(cCodISS),.F.)
		EndIf		

		aRet[ITEM_TOTIMP]  := nVlrImpNCM
		aRet[ITEM_RECNO]   := SB1->(RECNO())									// 24 - Recno do Produto na tabela SB1
	EndIf					
Endif 
//Restaura area anterior	
RestArea(aArea)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STDFItemBal
Busca se e etiqueta criada na balanca

@param   cCodeReceived			Codigo recebido/digitado
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aRet						Array com informações do Item
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDFItemBal( cCodeReceived )
Local	aArea		:= GetArea() 	// Guarda area atual
Local	lFindItem 	:= .F.			// Encontrou Item?
Local	aRet 		:= {}			// Retorno
Local	cCodProBal	:= ""			// Codigo do Item da balanca
Local	cInfProBal	:= ""			// Peso/quantidade do Item da balanca
Local	nItemQtde 	:= 0			// Quantidade do Item lido na etiqueta	
Local	cB1_Balanca := ""

Default	cCodeReceived := ""			// Codigo recebido/digitado

//Inicializa variaveis de retorno
aRet := STDIniRet()

/*
	Verifica se e etiqueta criada na balanca
*/

//Separa o codigo recebido para fazer validacao da balanca
cCodProBal := Substr(cCodeReceived,2,6)	//Codigo do Item da balanca
cInfProBal := SubStr(cCodeReceived,8,5)	//Peso/quantidade do Item da balanca
 
/*
	Procura Pelo SB1 Indice 1 ( B1_FILIAL + B1_COD ) ou Pelo SB1 Indice 5 ( B1_FILIAL + B1_CODBAR )
*/
SB1->(DbSelectArea("SB1"))
SB1->(DbSetOrder(1))//B1_FILIAL+B1_COD
If !(SB1->(DbSeek(xFilial("SB1") + cCodProBal)))
	SB1->(DbSetOrder(5))//B1_FILIAL+B1_CODBAR
	SB1->(DbSeek(xFilial("SB1") + cCodProBal ))
EndIf 

cB1_Balanca := AllTrim(SB1->B1_BALANCA)

If ( (AllTrim(cCodProBal) == Alltrim(SB1->B1_COD) .OR. AllTrim(cCodProBal) == Alltrim(SB1->B1_CODBAR) ) .AND. ( cB1_Balanca $ "123") )
		
	lFindItem 			:= .T. 	
		
	/*
		SB1->B1_BALANCA
		Indica se o produto e pesavel na balança e 
		quais as informacoes que virao na Etiqueta: 
		0 - Nao usa balanca
		1 - Codigo + Preco 
		2 - Codigo + Peso 
		3 - Codigo + Unidade
	*/		
	Do Case

		/* ATENCAO!
			No Caso do B1_BALANCA == "1" 
			sera tratado apos pegar o preco do item
		*/			
	
		Case ( cB1_Balanca == "2" )			// 2 - Quantidade (Peso)
						
			// Verifica se e item de balanca para pegar peso - ( Quantidade = Peso )           			
			If  AllTrim(SB1->B1_UM) $ "G|MG|KG"
				nItemQtde := ( Val(cInfProBal) / 1000 )
			Else				
				STBBalQuant()							
			EndIf
			
		Case ( cB1_Balanca == "3" ) 		// 3 - Quantidade (Unidade)
		
			nItemQtde := Val(cInfProBal)
		
	Endcase

EndIf


/*
	Se achou o Item	
	Verifica se o item esta bloqueado e atribui variaveis de retorno
*/	
If	lFindItem

	aRet[ITEM_ENCONTRADO]	:= .T.					// 01 - Encontrou Item?
	aRet[ITEM_CODIGO] 		:= SB1->B1_COD			// 02 - Codigo do Item encontrado
	aRet[ITEM_CODBAR] 		:= SB1->B1_CODBAR		// 03 - Codigo de barras do Item encontrado
	
	If SB1->B1_MSBLQL=="1"		
		aRet[ITEM_BLOQUEADO] := .T. 				// 04 - O item esta bloqueado para venda
	EndIf
	
	/*
		Se alterar a quantidade do item pela quantidade 
		encontrada na	tabela de codigo de barras  
	*/
	If nItemQtde > 0
		aRet[ITEM_QTDE] 		:= nItemQtde			// 05 - Quantidade do item 
	EndIf	
	cLOCPAD 	:= RetFldProd(SB1->B1_COD,"B1_LOCPAD")
	cTS		 	:= RetFldProd(SB1->B1_COD,"B1_TS") 
	cCODISS 	:= RetFldProd(SB1->B1_COD,"B1_CODISS")
	cORIGEM 	:= RetFldProd(SB1->B1_COD,"B1_ORIGEM")
	
	aRet[ITEM_TES] 			:= Iif(Empty(cTS), SB1->B1_TS, cTS)			// 06 - TES do item
	aRet[ITEM_BALANCA] 		:= SB1->B1_BALANCA	// 07 - Tipo produto de balanca
	aRet[ITEM_DESCRICAO] 	:= SB1->B1_DESC		// 08 - Descrição do item
	aRet[ITEM_UNID_MEDIDA] 	:= SB1->B1_UM			// 09 - Unidade de Medida do item
	aRet[ITEM_ARMAZEMPAD] 	:= Iif(Empty(cLOCPAD), SB1->B1_LOCPAD, cLOCPAD)	// 10 - Armazem Padrão do item
	aRet[ITEM_TIPO]			:= SB1->B1_TIPO		// 11 - Tipo do Produto
	aRet[ITEM_CODISS] 		:= Iif(Empty(cCODISS), SB1->B1_CODISS, cCODISS) 	// 12 - Codigo ISS
	aRet[ITEM_POSIPI] 		:= SB1->B1_POSIPI		// 13 - POSIPI
	aRet[ITEM_INT_ICM]		:= SB1->B1_INT_ICM  	// 14 - INT_ICM
	aRet[ITEM_ORIGEM] 		:= Iif(Empty(cORIGEM), SB1->B1_ORIGEM, cORIGEM)	// 16 - Código Origem
	aRet[ITEM_EX_NCM]		:= SB1->B1_EX_NCM		// 20 - Extensao NCN
	
EndIf	
	
//Restaura area anterior	
RestArea(aArea)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STDIniRet
Inicializa Variaveis de retorno

@param   nenhum
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aRet						Array com informações do Item
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STDIniRet() 
Local aRet	:= Array(ITEM_TOTAL_ARRAY)	//  Retorno

//Inicializa variaveis de retorno
aRet[ITEM_ENCONTRADO]	:= .F.			// 01 - Encontrou Item?
aRet[ITEM_CODIGO] 		:= ""			// 02 - Codigo do Item encontrado
aRet[ITEM_CODBAR] 		:= ""			// 03 - Codigo de barras do Item encontrado
aRet[ITEM_BLOQUEADO] 	:= .F. 			// 04 - O item esta bloqueado para venda
aRet[ITEM_QTDE] 		:= 0			// 05 - Quantidade do item 
aRet[ITEM_TES] 			:= ""			// 06 - TES do item
aRet[ITEM_BALANCA] 		:= ""			// 07 - Tipo produto de balanca
aRet[ITEM_DESCRICAO] 	:= ""			// 08 - Descrição do item
aRet[ITEM_UNID_MEDIDA] 	:= ""			// 09 - Unidade de Medida do item
aRet[ITEM_ARMAZEMPAD] 	:= ""			// 10 - Armazem Padrão do item
aRet[ITEM_TIPO] 		:= ""			// 11 - Tipo do item
aRet[ITEM_SITTRIB] 		:= ""			// 12 - ST do item
aRet[ITEM_IAT] 			:= ""			// 13 - IAT do item
aRet[ITEM_IPPT] 		:= ""			// 14 - PPT do item
aRet[ITEM_TOTIMP]		:= ""			// 15 - Impostos - Lei dos impostos	
aRet[ITEM_ORIGEM] 		:= ""			// 16 - Código Origem
aRet[ITEM_CODISS] 		:= ""			// 17 - Código ISS
aRet[ITEM_POSIPI] 		:= ""			// 18 - POSIPI
aRet[ITEM_INT_ICM]		:= 0			// 19 - ICM
aRet[ITEM_EX_NCM]		:= "" 			// 20 - Extensao do codigo NCM			
aRet[ITEM_TOTFED]		:= 0			// 21 - Impostos - Lei dos impostos Federal	
aRet[ITEM_TOTEST]		:= 0			// 22 - Impostos - Lei dos impostos Estadual	
aRet[ITEM_TOTMUN]		:= 0			// 23 - Impostos - Lei dos impostos Municipal	
aRet[ITEM_RECNO]		:= 0			// 24 - Recno do Produto na tabela SB1

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STBGetTESInfo
Pega informacoes da TES
@param  cField - Informacao que quer recuperar da TES
@param  cTES   - Codigo da TES 
@author  Varejo
@version P11.8
@since   29/11/2012
@return  Retorna informacoes da TES
@obs     
@sample
/*/
//-------------------------------------------------------------------	
Function STBGetTESInfo( cField , cTES )
Local			aArea				:= GetArea() 	// Guarda area atual
Local 			uRet				:=	Nil			// Retorno

Default cField 		:= ""
Default cTES 		:= ""

If !Empty(cField) .AND. !Empty(cField)

	SF4->(DbSeek(xFilial("SF4")+cTES))

	DBSelectArea("SF4")
	DBSetOrder(1)//F4_FILIAL+F4_CODIGO
	If DbSeek( xFilial("SF4")+cTES )
		uRet := SF4->&(cField)	
	EndIf
			
EndIf

//Restaura area anterior	
RestArea(aArea)	

Return uRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STDFindProd
Realiza a busca de Produtos
@param  cField - Informacao que quer recuperar da TES
@param  cTES   - Codigo da TES 
@author  Varejo
@version P11.8
@since   29/11/2012
@return  Retorna informacoes da TES
@obs     
@sample
/*/
//-------------------------------------------------------------------	
Function STDFindProd( 	cFilter, 	cCliCode,		cCliLoja, 		nMoeda, ;
						nLimitRegs, 	lPAFECF, 		lHomolPAF, 	aRecno, cSearchFields)
Local aProdSort		:= {} 										// -- Array com os produtos ordenados 
Local aProducts	    := {}										// -- Array com os produtos
Local aArea 	    := GetArea()								// -- Area Atual
Local aAreaSB1 	    := SB1->(GetArea())							// -- Area da tabela SB1
Local cMoedaSimb	:= SuperGetMV("MV_SIMB" + Str(nMoeda,1))	// -- Moeda atual	
Local nPrice		:= 0										// -- Variavel utilizada para armazenar o preço do produto
Local nMV_LJPEATU 	:=  SuperGetMV("MV_LJPEATU",,0)				// -- Define aonde será buscado o cliente (0=Pesquisa Local, 1=Pesquisa preferencialmente Local se falar pesquisa na retaguarda, 2=Pesquisa somente na retaguarda)
Local aRet			:= {}										// -- Variavel de retorno	
Local aProdSeek		:= {}										// -- Variavel com os produtos buscados
Local nProd			:= 0										// -- Variavel de controle "For"
Local uResult		:= Nil										// -- Resultado da função remote execute 
Local lRet			:= .F.										// -- Retorno da execução da função remoe execute
Local lLocalSearch	:= .F.										// -- Indica se a busca foi feita localmente ou se foi feita na retaguarda.
Local aAux			:= Array(ITEM_TOTAL_ARRAY)					// -- Array Auxiliar utilizado em ambientes PAF-EC
Local cSitTrib		:= ""										// -- Situação tributaria do produto
Local lSTDPrcKit	:= ExistFunc("STDPrcKit")					// -- Verifica a existencia da função STDPrcKit

Default cFilter 		:= ""									// -- Campo a ser buscado
Default cCliCode 		:= SuperGetMV("MV_CLIPAD",, "")			// -- Cliente padrao
Default cCliLoja 		:= SuperGetMV("MV_LOJAPAD",, "")		// -- Loja Cliente Padrão
Default nMoeda 			:= STBGetCurrency()						// -- Moeda corrente 
Default nLimitRegs		:= SuperGetMV("MV_LJQTDPL",,20)			// -- Limite de registro a seram buscados 
Default lPAFECF			:= StbIsPaf()							// -- Indica se é PAF ECF
Default lHomolPAF		:= StbHomolPaf()   						// -- Indica se é Homologação PAF
Default aRecno			:= {}									// -- REcno dos registros encontrados
Default cSearchFields 	:= ""									// -- Campos que serão utilizados na busca.

cFilter := AllTrim(cFilter)

If "*" $ cFilter 
	cFilter := Replace(cFilter,"*","")
EndIf

If nMV_LJPEATU == 0		// -- Pesquisa Somente local
	LjGrvLog( ProcName(),"Parametro MV_LJPEATU = 0, as busca serão realizadas apenas no PDV")
	
	STFMessage(ProcName(), "RUN", STR0001  ,{ || aRet := STDSearchP(cFilter,nLimitRegs,cSearchFields) }) // -- "Procurando produtos no PDV..."
	STFShowMessage(ProcName())
	
	aProdSeek 		:= aRet
	lLocalSearch	:= .T.

ElseIf nMV_LJPEATU == 2 // -- Pesquisa Somente na retaguarda
	LjGrvLog( ProcName(),"Parametro MV_LJPEATU = 2, as busca serão realizadas apenas na Retaguarda")
	
	aParam := {cFilter,nLimitRegs,cSearchFields}

	STFMessage(ProcName(), "RUN", STR0003 ,{ || lRet := STBRemoteExecute("STDSearchP", aParam,,, @uResult) }) // -- "Procurando produtos na retaguarda..."
	STFShowMessage(ProcName())
	
	If lRet
		aProdSeek 		:= uResult
	Else
		LjGrvLog( ProcName(),"Sem comunicação com o servidor.")
		STFMessage(ProcName(),"STOP",STR0004) // -- "Sem comunicação com o servidor."
		STFShowMessage(ProcName())
	EndIf 
Else

	LjGrvLog( ProcName(),"Parametro MV_LJPEATU = 1, as busca serão realizadas no PDV e caso nenhum produto seja encontrado será realizada uma nova busca na retaguarda")
	
	STFMessage(ProcName(), "RUN", STR0001  ,{ || aRet := STDSearchP(cFilter,nLimitRegs,cSearchFields) }) // -- "Procurando produtos no PDV..."
	STFShowMessage(ProcName())
	
	aProdSeek 		:= aRet

	If Len(aProdSeek) == 0 
		
		// -- Se não encontrou nenhum produto realiza a busca na retaguarda.
		STFMessage(ProcName(),"YESNO",STR0005) // -- produto não encontrado na base local. Deseja realizar a busca no servidor?
		
		LjGrvLog( ProcName(),"Nenhum produto encontrado nas busca no PDV.")
		
		If STFShowMessage(ProcName())
			LjGrvLog( ProcName(),"Usuario optou por realizar nova busca na retaguarda")
			
			aParam := {cFilter,nLimitRegs,cSearchFields}
			
			STFMessage(ProcName(), "RUN", STR0003  ,{ || lRet := STBRemoteExecute("STDSearchP", aParam,,, @uResult) }) // -- "Procurando produtos na retaguarda..."
			STFShowMessage(ProcName())
			
			If lRet
				aProdSeek 		:= uResult
			Else
				LjGrvLog( ProcName(),"Sem comunicação com o servidor.")
				STFMessage(ProcName(),"STOP",STR0004) // -- "Sem comunicação com o servidor."
				STFShowMessage(ProcName())
			EndIf 
		Else
			LjGrvLog( ProcName(),"Nenhum produto encontrado nas busca no PDV e o usuario optou por não realizar buscas na retaguarda.")
		EndIf 
	Else
		// -- Achou o produto Localmente
		lLocalSearch	:= .T.
	EndIf 
	
EndIf 

If Len(aProdSeek) == 0
	LjGrvLog( ProcName(),"Nenhum produto encontrado.")
	STFMessage(ProcName(),"STOP",STR0002) // -- Nenhum produto encontrado.
	STFShowMessage(ProcName())
EndIf

DbSelectArea("SB1")
SB1->(DbSetOrder(1)) //B1_FILIAL+B1_COD

For nProd := 1 To Len(aProdSeek)
	
	If lLocalSearch .Or. SB1->( DbSeek(xFilial("SB1") + aProdSeek[nProd][2]) )

		If lSTDPrcKit .AND. aProdSeek[nProd][7] == "KT"
			nPrice 	:= STDPrcKit( aProdSeek[nProd][2], cCliCode, Nil, cCliLoja, nMoeda)
		Else 
			nPrice 	:= STWFormPr( aProdSeek[nProd][2], cCliCode, Nil, cCliLoja, nMoeda)
		Endif 
		
		If nPrice > 0
			If !lPAFECF
				aAdd(aProducts,{AllTrim(aProdSeek[nProd][1])										+ " / " +;
								AllTrim(aProdSeek[nProd][2])										+ " / "	+;
								cMoedaSimb+AllTrim(Transform(nPrice,PesqPict("SL1","L1_VLRTOT")))			,;
								aProdSeek[nProd][1] 														,;
								Iif(lLocalSearch,aProdSeek[nProd][6],SB1->(Recno()))						})
			Else
				STDVlItPAF( @aAux, lHomolPAF, .F. )
				cSitTrib := aAux[ITEM_SITTRIB]
												
				aAdd(aProducts,{AllTrim(aProdSeek[nProd][1])												+ " / "	+;
								AllTrim(aProdSeek[nProd][2]) 												+ " / "	+;
								cMoedaSimb+AllTrim(Transform(nPrice,PesqPict("SL1","L1_VLRTOT")))			+ " / "	+;
								AllTrim(aProdSeek[nProd][3]) 												+ " / "	+;
								AllTrim(cSitTrib)  															+ " / " +;
								AllTrim(aProdSeek[nProd][4]) 												+ " / " +; 
								AllTrim(aProdSeek[nProd][5])														,;
								aProdSeek[nProd][2]																	,;
								Iif(lLocalSearch,aProdSeek[nProd][6],SB1->(Recno())) 								})           
			EndIf
		EndIf 
	Else
		LjGrvLog( ProcName(),"o Produto:" + aProdSeek[nProd][2] + " Descrição: " + aProdSeek[nProd][1] + " Não Foi encontrado localmente, por esse motivo será ignorado." )
	EndIf 
Next

//Ordena pelo código
ASort(aProducts,,, { |x, y| x[2] < y[2] } )

//Redimensiona o array 
AEval( aProducts, { |a|  aAdd( aProdSort, a[1] ) }) 
AEval( aProducts, { |a|  aAdd( aRecno   , a[3] ) }) 

RestArea(aAreaSB1)
RestArea(aArea)

Return aProdSort

//-------------------------------------------------------------------
/*/{Protheus.doc} STDStartProd
Funcao utilizada para fazer o posicionamento da SB1, com o intuito de evitar lentidoes na pesquisa de produtos
@param  lIncre - Define se esta sendo chamado pela carga incremental e nesse caso 
		 incrementa o Array (.T.), caso contrario e tratado pelo start
@param  lAdic   - //Define se na carga incremental, esta sendo criado 
		 um registro no cadastro de produto ou excluindo o mesmo
@author  Varejo
@version P11.8
@since   29/11/2012
@return  Retorna informacoes da TES
@obs     
@sample
/*/
//-------------------------------------------------------------------	
Function STDStartProd(lIncre,lAdic)

Local aArea 		:= GetArea()			//Guarda area		
Local aAreaSX3	:= SX3->( GetArea() )//Guarda area	SX3
Local nSec 		:= 0					//Controle de tempo
Local aProds 		:= {}					//array de produtos
Local dDtAtuPrd	:= cTod("  /  /  ")	//data atualizacao
Local nDiasVld	:= SuperGetMV("MV_LJDVLCP",,1)		//Parametro com a quantidade de dias que a variavel Global fica ativa
Local nPos			:= 0					//Variavel usada como ponteiro do array
Local cPesq		:= ""					//Chave da pesquisa contendo todos os campos

//Define se esta sendo chamado pela carga incremental e nesse caso incrementa o Array (.T.), caso contrario e tratado pelo start
Default lIncre		:= .F.

//Define se na carga incremental, esta sendo criado um registro no cadastro de produto ou excluindo o mesmo			 
Default lAdic		:= .T.

//Verifica se a variavel global da consulta de produto será realizada por JOB 1=Sim e 2=Nao
If  (SuperGetMV("MV_LJAJCP",,"2") == "1")

	//Verifica se ja existe conteudo na variavel Global
	If !GetGlbVars("TotvsPDV",@aProds,@dDtAtuPrd)
		//Funcao que concatena todos os campos para criar uma descricao unica para pesquisa  
		cPesq := STDConcPesq()
		
		aProds := {}
		
		nSec := Seconds()
		
		DbSelectArea("SB1")
		SB1->(DbSetOrder(3)) // B1_FILIAL + B1_DESC
		SB1->(DbSeek(xFilial("SB1"))) //Posiciona no primeiro registro
		
		If SB1->(!EOF())
			SB1->(DbGoTo(SB1->(LastRec())+1))
			SB1->(DbSkip(-1))
		EndIf
		
		While SB1->(!BOF())		
			If SB1->B1_MSBLQL <> '1'
				Aadd(aProds,{&(cPesq), SB1->(Recno())})
			EndIf
			SB1->(DbSkip(-1))
		End
		
		dDtAtuPrd := Date()
		
		//Atualiza a variavel Global
		PutGlbVars("TotvsPDV",aProds,dDtAtuPrd)
		
		nSec := Seconds() - nSec

	Else
		//Verifica se a data de criacao do parametro eh superior ao parametrizado
		If Date() >= (dDtAtuPrd + nDiasVld)
			//Zero a variavel global
			ClearGlbValue("TotvsPDV")
			
			//Chamo a rotina novamente, mas com as variaveis globais zeradas para que crie novamente os registros
			STDStartProd() 
		ElseIf lIncre
			If lAdic
				
				cPesq := STDConcPesq()
				
				//Adiciona o novo registro posicionado no produto
				If aScan(aProds,{|x| x[2] == SB1->(Recno()) }) == 0
					Aadd(aProds,{&(cPesq), SB1->(Recno())})
					
					dDtAtuPrd := Date()
					
					//Atualiza a variavel Global
					PutGlbVars("TotvsPDV",aProds,dDtAtuPrd)
				EndIf
			Else
				//Exclui o registro posicionado no produto
				If (nPos := aScan(aProds,{|x| x[2] == SB1->(Recno()) })) <> 0
					ADel( aProds, nPos )
					ASize( aProds, Len(aProds) - 1 ) 				
					
					dDtAtuPrd := Date()
					
					//Atualiza a variavel Global
					PutGlbVars("TotvsPDV",aProds,dDtAtuPrd)			
				EndIf			
			EndIf
		EndIf 
	EndIf
	
	aStartProds := aClone(aProds)
	
Else

    //Nao utiliza variavel global
	If ValType(aStartProds) <> "A"
		aStartProds := {}
		cPesq := STDConcPesq()
		
		nSec := Seconds()
		
		DbSelectArea("SB1")
		SB1->(DbSetOrder(3)) // B1_FILIAL + B1_DESC
		SB1->(DbSeek(xFilial("SB1"))) //Posiciona no primeiro registro
		
		If SB1->(!EOF())
			SB1->(DbGoTo(SB1->(LastRec())+1))
			SB1->(DbSkip(-1))
		EndIf

		While SB1->(!BOF()) 
			
			If SB1->B1_MSBLQL <> '1'
				//Aadd(aStartProds,{SB1->B1_DESC, SB1->(Recno())})
				Aadd(aStartProds,{ &(cPesq) , SB1->(Recno()) })
			EndIf
			SB1->(DbSkip(-1))

		End
		
	EndIf
	

EndIf


ConOut(cValTochar(len(aStartProds)))
nSec := Seconds()

ASort(aStartProds,,, { |x, y| x[1] < y[1] } )
nSec := Seconds()-nSec

RestArea(aArea)
RestArea(aAreaSX3)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} STDIsPrdLike
Realiza a pesquisa por apenas parte do codigo do produto.

@param  cCodProd - Codigo do Produto
@author  Varejo
@version P11.8
@since   06/08/2014
@return  Retorna array com os produtos encontrados
@obs     
@sample
/*/
//-------------------------------------------------------------------	
Function STDIsPrdLike(cCodProd)

Local aArea := GetArea()  // Guarda a area
Local aRet  := {}        // Retorno da funcao

DEFAULT cCodProd := ""

cCodProd := AllTrim( cCodProd )

DbSelectArea("SB1")
SB1->(DbSetOrder(1))

If DbSeek(xFilial("SB1") + cCodProd)

	While !EOF() .And. (xFilial("SB1") + cCodProd) == (SB1->B1_FILIAL + SubStr(SB1->B1_COD, 1, Len(cCodProd)))        
		AAdd(aRet, SB1->(Recno()))
		SB1->(DbSkip())           
	End
	
EndIf

RestArea( aArea )

Return aRet


//-------------------------------------------------------------------	
/*/{Protheus.doc} STDJobCPrd
Funcao para iniciar um JOB para que nele gere as informacoes da 
funcao STDStartProd
@param  cEmpAnt - Empresa
@param  cFilAnt - Filial
@author  Varejo
@version P11.8
@since   29/11/2012
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------	
Function STDJobCPrd(cEmp_Ant, cFil_Ant)


Local lJob := .F.  //Usa Job

Default cEmp_Ant := ""
Default cFil_Ant := ""
 
If !Empty(cEmp_Ant) .And. Type("cEmp_Ant") == "U"
	RpcSetType(3)
	RpcSetEnv(cEmp_Ant, cFil_Ant)					
	lJob := .T.
EndIf

STDStartProd()

If lJob
	Reset Environment
EndIf

Return Nil


//-------------------------------------------------------------------	
/*/{Protheus.doc} STDConcPesq
Funcao que busca todos os campos que serao usados para concatenar uma 
unica descricao para pesquisa da consulta de produto
@author  Varejo
@version P11.8
@since   29/11/2012
@return  cPesq - campos Adicionais da pesquisa de produto
@obs     
@sample
/*/
//-------------------------------------------------------------------	
Static Function STDConcPesq( )

//Parametro contendo os campos que serao concatenados ao B1_DESC para pesquisa.
//O separador dos campos sera o "|" (Pipe)
Local cCmpBscP		:= SuperGetMV("MV_LJCMP",,"")
Local cPesq			:= ""			//Campos que serao usados para concatenar a pesquisa
Local nI				:= 0			//Contador para laco
Local aCmpBscP		:= {}			//Array para conter os campos personalizados para pesquisa
Local nTot				:= 0			//Limitador do laco
Local aArea 			:= GetArea()  // Guarda a area

cPesq := "Alltrim(SB1->B1_DESC) + '|'"

//Verifica se existe algum campo que sera acrescentado a regra de busca
If !Empty(cCmpBscP)

	//monta em array os campos personalizados a busca, a partir do limitador "|"		
	aCmpBscP := StrToKarr(cCmpBscP,"|")
	
	//Analiso o array com os campos personalizados da busca para saber a quantidade de campos 	
	If Len(aCmpBscP) > 2
		nTot := 2
	Else
		nTot := Len(aCmpBscP) 
	EndIf
	
	dbSelectArea("SX3")
	dbSetorder(2)
	For nI := 1 to nTot
		//Valida se os campos sao validos
		If SX3->( dbSeek( Alltrim(aCmpBscP[nI]) ) )
			//Valida se pertence a tabela de produtos e se o tipo do campo eh caracter
			If	SX3->X3_ARQUIVO == "SB1" .And. SX3->X3_TIPO == "C"
				cPesq += " + Alltrim(SB1->" + Alltrim(SX3->X3_CAMPO) + ") + '|'"
			EndIf
		EndIf
	Next nI

EndIf

RestArea( aArea )

Return cPesq

//-------------------------------------------------------------------
/*/{Protheus.doc} STDAlqRed
Retorna a aliquota reduzida do campo SB0
@since   18/03/2015
/*/
//-------------------------------------------------------------------	
Function STDAlqRed()

Local nAliq := 0

DbSelectArea("SB0")
SB0->(DbSetOrder(1))  // Fil + COD
If SB0->(DbSeek(xFilial("SB0")+ SB1->B1_COD))
	nAliq := SB0->B0_ALIQRED
EndIf

Return nAliq

//-------------------------------------------------------------------
/*/{Protheus.doc} STDVlItPAF
Validação dos itens especifica para o PAF

@param   aRet, array , contendo os dados do item
@param   lHomolPAF, lógico , tratamento especial quando em Homol
@author  Julio.Nery
@version P12
@since   08/10/2019
@return  NIL, nenhum
/*/
//-------------------------------------------------------------------
Function STDVlItPAF(aRet,lHomolPAF, lGravaSB1)
Local cMD5Sb1  := ""
Local nPICM    := 0
Local nALIQISS := 0
Local nRecnoSB1:= 0
Local lAlqIssIs:= .F.

Default lGravaSB1 := .T. // Indica se grava os campos B1_IAT e B1_IPPT da SB1

aRet[ITEM_SITTRIB]  := 	STBFMSitTrib(SB1->B1_COD, "", "SB1")
lAlqIssIs := (aRet[ITEM_SITTRIB] $ "FS|NS|IS")

// Situacao tributaria
If lHomolPAF
	//deve mostrar caso seja feita alteração no Banco de Dados - TESTE BLOCO VII
	If !lAlqIssIs
		nPICM		:= RetFldProd(SB1->B1_COD,"B1_PICM") 
		nPICM		:= Iif(Empty(nPICM), SB1->B1_PICM, nPICM)
		If nPICM> 0
			aRet[ITEM_SITTRIB]  := AllTrim(aRet[ITEM_SITTRIB] ) +  StrZero(nPICM, 5,2) 
		Else
			nALIQISS			:= RetFldProd(SB1->B1_COD,"B1_ALIQISS") 
			nALIQISS 			:= Iif(Empty(nALIQISS), SB1->B1_ALIQISS, nALIQISS)
			aRet[ITEM_SITTRIB]	:= AllTrim(aRet[ITEM_SITTRIB] ) + StrZero(nALIQISS, 5,2)
		EndIf
	EndIf
EndIf 
	
If !lAlqIssIs .And. !(SubStr(aRet[ITEM_SITTRIB] ,1,1) == "T" .OR. SubStr(aRet[ITEM_SITTRIB] ,1,1) == "S")
	aRet[ITEM_SITTRIB]  := SubStr(aRet[ITEM_SITTRIB],1,1) 
EndIf

If ( Empty( AllTrim( SB1->B1_IPPT )) .Or. Empty( AllTrim( SB1->B1_IAT )) ) .AND. lGravaSB1
	Conout(" Campo B1_IPPT/B1_IAT em branco, por ser obrigatório no PAF-ECF preenchido com conteúdo padrão ")
	LjGrvLog( NIL ," Campo B1_IPPT/B1_IAT em branco, por ser obrigatório no PAF-ECF preenchido com conteúdo padrão")
	
	nRecnoSB1 := SB1->(Recno())
	
	RecLock("SB1",.F.)
	
	If Empty( AllTrim( SB1->B1_IPPT ))
		REPLACE SB1->B1_IPPT WITH "T"
	EndIf
	
	REPLACE SB1->B1_IAT	WITH IIf( SuperGetMV("MV_ARREFAT",,"N") == "S", "A", "T" )
	SB1->(MsUnlock())
	
	cMD5Sb1 := STxPafMd5("SB1")
	
	RecLock("SB1",.F.)
	REPLACE SB1->B1_PAFMD5 WITH cMD5Sb1
	SB1->(MsUnlock())
	
	SB1->(DbGoTo(nRecnoSB1))
EndIf
									
If lGravaSB1								
	aRet[ITEM_IAT]	:= SB1->B1_IAT
	aRet[ITEM_IPPT] := SB1->B1_IPPT
Else
	aRet[ITEM_IAT]	:= IIf( SuperGetMV("MV_ARREFAT",,"N") == "S", "A", "T" )
	aRet[ITEM_IPPT] := "T"
EndIf

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} STDSearchP
Função responsavel por realizar busca de um determinado Produto atraves do conteudo informado na variavel cWhatSearch

@author  	Lucas Novais
@version 	P12.1.27
@since   	13/03/2020
@param   	cWhatSearch, Caracter, Conteudo a ser buscado
@param   	nLimitRegs, Numérico, Limite de produtos buscado
@param   	cSearchFields, Caracter, Campos a serem utiliados na query para busca
@return		Array, Retorna informações sobre os produtos buscado		  
/*/
//-------------------------------------------------------------------

Function STDSearchP(cWhatSearch,nLimitRegs,cSearchFields)
Local cSGBD				:= ""				// -- Banco de dados atulizado (Para embientes TOP) 
Local cAliasQuery 		:= ""				// -- Alias utilizado para query
Local cStartQuery		:= ""				// -- Variavel para montagem de Query
Local cBodyQuery		:= ""				// -- Variavel para montagem de Query
Local cEndQuery			:= ""				// -- Variavel para montagem de Query
Local cFullQuery		:= ""				// -- Variavel para montagem de Query
Local aProduct			:= {}				// -- Variavel utilizada para retorno com as informações dos produtos	
Local nSearch			:= 0				// -- Variavel utilizada no Seek
Local cFilter			:= ""				// -- Variavel utilizada no Filtro
Local aSearchFields		:= {}				// -- Variavel utilizada na monstagem dos campos que serão buscados
Local aOrderSeek		:= {{1,"SB1->B1_COD"},{3,"SB1->B1_DESC"},{5,"SB1->B1_CODBAR"}}
Local nSeek				:= 0
Local lFind				:= .F.	

Default cWhatSearch		:= ""				// -- Parametro com a informação que será buscada
Default nLimitRegs		:= 25				// -- Limite da busca	
Default cSearchFields	:= ""				//-- Campos default que serão buscados caso o parametro seja false

#IFDEF TOP 

	If Empty(cSearchFields)
		cSearchFields	:= "B1_COD|B1_DESC"
	EndIf 

	cSGBD 		:= AllTrim(Upper(TcGetDb()))
	cAliasQuery	:= GetNextAlias()

	cStartQuery += " SELECT " 
	
	If cSGBD 		$ "MSSQL|SYBASE" 	
		cStartQuery 	+= " TOP " + AllTrim(Str(nLimitRegs))
	ElseIf cSGBD 	$ "INFORMIX"	 
		cStartQuery 	+= "FIRST " + AllTrim(Str(nLimitRegs))
	EndIf 
	
	cStartQuery += 	"B1_DESC,B1_COD,B1_UM,B1_IAT,B1_IPPT, R_E_C_N_O_ , B1_TIPO" 
	
	cBodyQuery 	+= " FROM " + RetSQLName("SB1") + " SB1 "
	cBodyQuery	+= " WHERE SB1.B1_FILIAL = '" + xFilial("SB1") + "' "

	If cSGBD 		$ "MSSQL"
		cSearchFields 	:= Replace(cSearchFields,"|",",")
		cBodyQuery		+= " AND CONCAT(" + cSearchFields + ") LIKE '%" + cWhatSearch + "%' "
	Else 
		cSearchFields 	:= Replace(cSearchFields,"|","||")
		cBodyQuery		+= " AND " + cSearchFields + " LIKE '%" + cWhatSearch + "%' "
	EndIF 

	cBodyQuery	+= " AND SB1.B1_MSBLQL <> '1' "
	cBodyQuery	+= " AND SB1.D_E_L_E_T_ = ' ' "

	If cSGBD 		$ "ORACLE" 
		cBodyQuery 		+= " AND ROWNUM <= " + AllTrim(Str(nLimitRegs))
	ElseIf cSGBD 	$ "DB2"	
		cEndQuery 		+= "FETCH FIRST " + AllTrim(Str(nLimitRegs)) + " ROWS ONLY"
	ElseIf cSGBD 	$ "POSTGRES|MYSQL|SQLITE" 
		cEndQuery 		+= " LIMIT " + AllTrim(Str(nLimitRegs))
	EndIf

	cFullQuery 	:= ChangeQuery(cStartQuery + cBodyQuery + cEndQuery)
	
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cFullQuery),cAliasQuery,.T.,.T.)

	While (cAliasQuery)->(!EOF())
		aAdd(aProduct, {(cAliasQuery)->B1_DESC,(cAliasQuery)->B1_COD,(cAliasQuery)->B1_UM,(cAliasQuery)->B1_IAT,(cAliasQuery)->B1_IPPT,(cAliasQuery)->R_E_C_N_O_,(cAliasQuery)->B1_TIPO})
		(cAliasQuery)->(DbSkip())
	End

#ELSE

	DbSelectArea("SB1")
	
	If Empty(cSearchFields)
		For nSeek := 1 To len(aOrderSeek)
			SB1->(DbSetOrder(aOrderSeek[nSeek][1]))
			If SB1->(dbSeek(xFilial("SB1") + cWhatSearch))
				lFind := .T.
				Exit
			EndIf 
		Next
	Else
		If Empty(cSearchFields)
			cSearchFields	:= "B1_COD|B1_DESC"
		EndIf 

		// -- Montagem do Filtro
		aSearchFields := StrToKarr(cSearchFields,"|")
		cFilter	:= " ("
		
		For nSearch := 1 To len(aSearchFields)
			cFilter += "'" + cWhatSearch + "' $ " + aSearchFields[nSearch] 
			If len(aSearchFields) <> nSearch
				cFilter += " .OR. "
			EndIf 
		Next 

		cFilter += ") .AND. SB1->B1_MSBLQL <> '1' "
		
		// -- Execução do Filtro 
		SB1->(DbSetFilter({ || &cFilter }, cFilter))
		SB1->(DbGoTop())
		lFind := .T.
	EndIf 

	If lFind 
		While SB1->(!EOF()) .AND. Len(aProduct) < nLimitRegs .AND. IIf(nSeek > 0, cWhatSearch $ &(aOrderSeek[nSeek][2]),.T.)
			aAdd(aProduct, {SB1->B1_DESC,SB1->B1_COD,SB1->B1_UM,SB1->B1_IAT,SB1->B1_IPPT,Recno(), SB1->B1_TIPO})
			SB1->(DbSkip())
		End
	EndIf

	SB1->(DBClearFilter())

#ENDIF

Return aProduct
