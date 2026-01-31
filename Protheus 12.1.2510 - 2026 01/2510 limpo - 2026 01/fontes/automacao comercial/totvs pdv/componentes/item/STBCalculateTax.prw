#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "MATXDEF.CH"

Static aGrupTrib  := {}	// Armazena valores por alíquotas para rateio pelo método de impressora fiscal

//-------------------------------------------------------------------
/*/{Protheus.doc} STBTaxIni
Inicializa o Calculo das operacoes Fiscais

@param cCliForCod			Codigo Cliente/Fornecedor
@param cCliForLoja			Loja do Cliente/Fornecedor 
@param cCliOrFor			C:Cliente ou F:Fornecedor	
@param cTypeNF			 	Tipo da NF
@param lFooterTax			Permite Incluir Impostos no Rodape
@param cAlias				Alias do Cadastro de Produtos	
@param cRoutine				Nome da rotina que esta utilizando a funcao
@param lCalcIpi				Define se calcula IPI
@author  Varejo
@version P11.8
@since   04/04/2012
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBTaxIni(	cCliForCod	, cCliForLoja 	, cCliOrFor	, cTypeNF	,;
					lFooterTax	, cAlias		, cRoutine	, lCalcIpi	,;
					cCliType	, cTpFrete		, lEmiteNFe)

Local lCfgTrib := If(FindFunction("LjCfgTrib"), LjCfgTrib(), .F.) //Verifica se Configurador de Tributos esta habilitado

Default cCliForCod 		:= ""				// Codigo Cliente/Fornecedor
Default cCliForLoja		:= ""				// Loja do Cliente/Fornecedor 
Default cCliOrFor		:= ""				// C:Cliente ou F:Fornecedor	
Default cTypeNF 		:= ""				// Tipo da NF
Default lFooterTax		:= .F.				// Permite Incluir Impostos no Rodape
Default cAlias			:= ""				// Alias do Cadastro de Produtos	
Default cRoutine		:= ""				// Nome da rotina que esta utilizando a funcao
Default lCalcIpi		:= .F.				// Define se calcula IPI
Default cCliType		:= ""				// Tipo do Cliente
Default cTpFrete		:= ""				// Tipo de Frete (Via importação de Orçamento)
Default lEmiteNFe		:= .F.   			// Esse parametro somente vem quando a rotina é chamada na seleção de cliente.

LjGrvLog( "MaFisIni", "Inicio")

// Inicializa o Calculo das operacoes Fiscais 	
MaFisIni(	cCliForCod		,;	// 01-Codigo Cliente/Fornecedor
			cCliForLoja		,;	// 02-Loja do Cliente/Fornecedor
			cCliOrFor		,;	// 03-C:Cliente , F:Fornecedor
			cTypeNF			,; 	// 04-Tipo da NF( "N","D","B","C","P","I","S" ) 
			cCliType		,;	// 05-Tipo do Cliente/Fornecedor
			Nil				,;	// 06-Relacao de Impostos que suportados no arquivo
			Nil				,;	// 07-Tipo de complemento
			lFooterTax		,;	// 08-Permite Incluir Impostos no Rodape .T./.F.
			cAlias			,;	// 09-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
			cRoutine     	,;	// 10-Nome da rotina que esta utilizando a funcao
			Nil				,;	// 11-Tipo de documento
			Nil				,;	// 12-Especie do documento 
			Nil				,;	// 13-Codigo e Loja do Prospect 
			Nil				,;	// 14-Grupo Cliente
			Nil				,;	// 15-Recolhe ISS
			Nil				,;	// 16-Codigo do cliente de entrega na nota fiscal de saida
			Nil				,;	// 17-Loja do cliente de entrega na nota fiscal de saida
			Nil				,;	// 18-Informacoes do transportador [01]-UF,[02]-TPTRANS
			lEmiteNFe		,;	// 19- No momento o PDV nao emite NF , por isso sempre falso   
			lCalcIpi		,;  // 20-Define se calcula IPI (SIGALOJA)
			Nil				,;  // 21-Pedido de Venda
			Nil				,;  // 22-Cliente do Faturamento
			Nil				,;  // 23-Loja do cliente do faturamento
			Nil				,;  // 24-Total do Pedido
			Nil				,;  // 25-Data de emissão do documento
			cTpFrete		,;  // 26-Tipo de Frete
			Nil				,;  // 27-Indica se Calcula (PIS,COFINS,CSLL), independete da TES estar configurada para Gerar Duplicata (F4_DUPLIC)
			Nil				,;  // 28-Indica se Calcula (INSS), independete da TES estar configurada para Gerar Duplicata (F4_DUPLIC)
			Nil				,;  // 29-Indica se Calcula (IRRF), independete da TES estar configurada para Gerar Duplicata (F4_DUPLIC)
			Nil				,;  // 30-Tipo de Complemento
			Nil				,;  // 31-Cliente de destino de transporte (Notas de entrada de transporte )
			Nil				,;  // 32-Loja de destino de transporte (Notas de entrada de transporte )
			lCfgTrib		)   // 33-Flag para indicar se os tributos genéricos devem ou não ser calculados - deve ser passado como .T. somente após a preparação da rotina para gravação, 
								// visualização e exclusão dos tributos genéricos.
				
// Atualiza Total			
STFRefTot()

LjGrvLog( "MaFisIni", "Final")
			
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STBTaxAdd
Inicializa o Calculo das operacoes Fiscais por item

@param cItemCode		Codigo do Produto
@param cTES				Codigo do TES  
@param nQuantity		Quantidade	
@param nPrice			Preco Unitario
@param nDiscount		Valor do Desconto
@param nItemTotal		Valor Total do Item
@author  Varejo
@version P11.8
@since   04/04/2012
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBTaxAdd(	cItemCode, cTES			, nQuantity, nPrice, ;
					nDiscount, nItemTotal	)

Default cItemCode 		:= ""				// 	Codigo do Produto
Default cTES			:= ""				// Codigo do TES  
Default nQuantity		:= 0				// Quantidade	
Default nPrice 			:= 0				// 	Preco Unitario
Default nDiscount		:= 0				// Valor do Desconto
Default nItemTotal		:= 0				// Valor Total do Item

LjGrvLog( "MaFisAdd", "Inicio")
// Inicializa o Calculo das operacoes Fiscais por item 
MaFisAdd(	cItemCode				,;	// 01-Codigo do Produto 		( Obrigatorio 		)
          	cTES					,; 	// 02-Codigo do TES 			( Opcional 			)
          	nQuantity    			,;	// 03-Quantidade 				( Obrigatorio 		)
          	nPrice					,;	// 04-Preco Unitario 			( Obrigatorio 		)
          	nDiscount  				,;	// 05-Valor do Desconto			( Opcional 			)
          	""             			,;	// 06-Numero da NF Original 	( Devolucao/Benef 	)
          	""       				,;	// 07-Serie da NF Original 		( Devolucao/Benef 	)
          	0               		,;	// 08-RecNo da NF Original 		( No arq SD1/SD2	)
          	0               		,;	// 09-Valor do Frete do Item  	( Opcional			)
          	0               		,;	// 10-Valor da Despesa do item 	( Opcional 			)
          	0               		,;	// 11-Valor do Seguro do item 	( Opcional 			)
          	0               		,;	// 12-Valor do Frete Autonomo 	( Opcional			)
     		nItemTotal				,;	// 13-Valor da Mercadoria 		( Obrigatorio 		)
          	0 						)	// 14-Valor da Embalagem 		( Opcional 			)

// Atualiza Total			
STFRefTot()
LjGrvLog( "MaFisAdd", "Final")     	
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STBTaxRet
Retorna os impostos calculados

@param 	nItem					Item
@param 	cField					Campo  
@author  Varejo
@version P11.8
@since   04/04/2012
@return  nRet - Imposto do item calculado
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBTaxRet(	nItem, cField ) 	

Local nRet 			:= 0							// Retorna imposto
Local lRecebTitle 	:= STIGetRecTit()			    // Indica se eh recebimento de titulos
Local oTotal      	:= STFGetTot() 					// Totalizador
Local nTotSale    	:= oTotal:GetValue("L1_VLRTOT")	// Valor total da venda

Default nItem 		:= 0				// 	Item
Default cField		:= ""				// Campo 

// Se for Recebimento de Titulo retorna o valor total (L1_VLRTOT)
If lRecebTitle .AND. cField = "NF_TOTAL"
	nRet := nTotSale
Else // Retorna os impostos calculados pela MATXFIS
	nRet := MaFisRet(	nItem,	cField	)
EndIf

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBTaxAlt
Altera os valores de impostos e bases do item

@param cField			Campo
@param nValue			Valor
@param nItem				Linha do Item nas funcoes fiscais  
@author  Varejo
@version P11.8
@since   04/04/2012
@return  nRet - Imposto do item alterado .T. ou .F.
@obs     	
@sample
/*/
//-------------------------------------------------------------------
Function STBTaxAlt (	cField,	nValue	,	nItem	) 

Local lRet 			:= .F.				// Retorno

Default cField 		:= ""				// 	Campo
Default nValue		:= 0				// Valor 
Default nItem		:= 0				// Item

LjGrvLog( "MaFisAlt", "Inicio")
//Altera os valores de impostos e bases do item
lRet := MaFisAlt(	cField		,	nValue,	nItem )
	
// Atualiza Total			
STFRefTot()	

LjGrvLog( "MaFisAlt", "Final")
			
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STBTaxDel
Marca/Desmarca o item especificado como deletado

@param 	nItem				Item
@param 	lDeleted			Marca se o item esta Deletado  
@author  Varejo
@version P11.8
@since   01/06/2012
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBTaxDel(	nItem	, lDeleted ) 	

Local nX 				:= 0
Local aSATTrib			:= {}																			//Tributação Produto SAT
Local lExistGetTriSat 	:= LjUseSat() .AND. (ExistFunc("LjGetTriSat") .AND. ExistFunc("LjSetTriSat"))	//Armazenamento para XML SAT

Default nItem 			:= 0				// Item
Default lDeleted		:= .F.				// Marca se o item esta Deletado

/*/
	Marca/Desmarca o item especificado como deletado
	lDelete := ( .T. Item Deletado ) , ( .F. Item Ativo )
/*/
LjGrvLog( "MaFisDel", "Inicio") 
MaFisDel( nItem , lDeleted)
LjGrvLog( "MaFisDel", "Final") 

If lExistGetTriSat
	//Array de tributações do SAT
	aSATTrib := LjGetTriSat()		//Tributação produto SAT
	For nX := 1 to Len(aSatTrib)
		
		// O procedimento abaixo elimina toda a linha que foi marcada como "deletado" e redimensiona todo o array.
		// Isto serve para envio de alguns impostos para o XML SAT, como PIS, COFINS, CST...
		If nX <= Len(aSatTrib)
			//Elemento 1 é o número do item no grid TOTVSPDV. Como não há como recuperar um item deletado, é deletado também neste array.
			If aSatTrib[nX][1] = nItem		
				aDel(aSatTrib,nX)
				aSize(aSatTrib,Len(aSatTrib)-1)
				nX--
				Loop
			EndIf
		EndIf
	Next
	LjSetTriSat(aSATTrib)
EndIf

// Atualiza Total			
STFRefTot()
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} STBTaxFoun
Verifica se o item ja existe na relacao de itens ja incluidos

@param 	cField				Campo
@param 	nItem				Item  
@author  Varejo
@version P11.8
@since   04/04/2012
@return  lRet - encontrou item .T. ou .F.
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBTaxFoun(	cField, nItem	) 	

Local 	lRet 			:= .F.				// Retorno

Default cField		:= ""				// Campo 
Default nItem 		:= 0				// 	Item

// Verifica se o item ja existe na relacao de itens ja incluidos
If Empty(cField) .AND. Empty(nItem)
	lRet := MaFisFound()
Else
	lRet := MaFisFound(cField,nItem)	
EndIf		

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBTaxIniL
Rotina inicializacao do item da funcao Fiscal

@param 	nItemLine		Numero do Item
@param 	lReversal		Indica se o item deve ser estornado caso exista
@param cItemCode		Codigo do Produto
@param cTES			Codigo do TES  
@param nQuantity		Quantidade	
@param nPrice			Preco Unitario
@param nDiscount		Valor do Desconto
@param nItemTotal		Valor Total do Item   
@author  Varejo
@version P11.8
@since   04/04/2012
@return  lRet - Inicializou item .T. ou .F.
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBTaxIniL(	nItemLine	,	lReversal	,	cItemCode	, cTES 			, ;
						nQuantity	,	nPrice		, 	nDiscount	, nItemTotal		)  	
						
Local lRet 				:= .F.		// Retorno
Local aItemLoad			:= {}		// Array iniload da matxfis

Default nItemLine 		:= 0		// Item do Array que deve ser inicializado
Default lReversal		:= .F.		// Indica se o item deve ser estornado caso exista
Default cItemCode 		:= ""		// Codigo do Produto
Default cTES			:= ""		// Codigo do TES  
Default nQuantity		:= 0		// Quantidade	
Default nPrice 			:= 0		// Preco Unitario
Default nDiscount		:= 0		// Valor do Desconto
Default nItemTotal		:= 0		// Valor Total do Item

LjGrvLog( "MaFisIniLoad", "Inicio") 

Aadd( aItemLoad , cItemCode							) // IT_PRODUTO
Aadd( aItemLoad , cTES								) // IT_TES 
Aadd( aItemLoad , ""								) // IT_CODISS 
Aadd( aItemLoad , nQuantity							) // IT_QUANT 
Aadd( aItemLoad , Space(TamSx3("D1_NFORI")[1])		) // IT_SERIORI 
Aadd( aItemLoad , Space(TamSx3("D1_SERIORI")[1])	) // IT_RECNOSB1 
Aadd( aItemLoad , 0									) // IT_RECNOSF4 
Aadd( aItemLoad , 0		 							) // IT_RECORI 
Aadd( aItemLoad , Nil								) // IT_LOTECTL 
Aadd( aItemLoad , ""								) // IT_NUMLOTE
Aadd( aItemLoad , ""								) // Sub-Lote Produto
Aadd( aItemLoad , Space(Len(cItemCode))				) // Codigo do Produto Fiscal 
Aadd( aItemLoad , 0 				 				) // Recno do Produto Fiscal		

// Rotina inicializacao do item da funcao Fiscal
If !MaFisFound("IT",nItemLine)
	lRet := MaFisIniLoad(	nItemLine	,	aItemLoad	,	lReversal	)
Else
	MaFisAlt("IT_PRODUTO",cItemCode,nItemLine)	
EndIf

MaFisTes( cTES , 0 , nItemLine ) // Carrega a TES para a MATXFIS

MaFisLoad( "IT_VALMERC" , nItemTotal , nItemLine )

MaFisLoad( "IT_PRCUNI" , nPrice , nItemLine )

MaFisLoad( "IT_DESCONTO" , nDiscount , nItemLine )

MaFisRecal( "" , nItemLine ) // Dispara o calculo do item

MaFisEndLoad( nItemLine , 2 ) // Fecha o calculo do item e atualiza os totalizadores do cabeçalho

// Atualiza Total			
STFRefTot()

LjGrvLog( "MaFisIniLoad", "Final", nItemLine) 
			
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBTaxLoad
Rotina inicializacao do item da funcao Fiscal

@param cField			Campo
@param nValue			Valor
@param nItem				Item  
@author  Varejo
@version P11.8
@since   04/04/2012
@return  lRet - Inicializou item funcao fiscal .T. ou .F.
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBTaxLoad(	cField	,	nValue	,	nItem	) 	

Local lRet 			:= .F.				// Retorno

Default cField 		:= ""				// Campo
Default nValue		:= 0				// Valor 
Default nItem		:= 0				// Item

LjGrvLog( "MaFisLoad", "Inicio") 

// Rotina inicializacao do item da funcao Fiscal
lRet := MaFisLoad(		cField	,	nValue	,	nItem	)		
		
LjGrvLog( "MaFisLoad", "Final") 

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBTaxRef
Executa o calculo dos valores do item da NF

@param cReference			Referencia
@param cRoutine				Identificador do arquivo
@param cValue				Valor da Referencia  
@author  Varejo
@version P11.8
@since   04/04/2012
@return  lRet - MetoExecutado com sucesso .T. ou .F.
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBTaxRef (	cReference	, cRoutine	,	cValue) 

Local lRet 			:= .F.				// Retorno

Default cReference 	:= ""				// Campo
Default cRoutine	:= ""				// Valor 
Default cValue		:= ""				// Item

lRet := MaFisRef (	cReference	, cRoutine	,	cValue	)

Return lRet
			

//-------------------------------------------------------------------
/*/{Protheus.doc} STBTaxSave
Salva a NF atual em uma area temporaria

@param   
@author  Varejo
@version P11.8
@since   04/04/2012
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBTaxSave() 	

// Salva a NF atual em uma area temporaria
MaFisSave()	

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STBTaxEnd
Finaliza a carga dos itens Fiscais

@param   
@author  Varejo
@version P11.8
@since   04/04/2012
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBTaxEnd() 	

// Finaliza a carga dos itens Fiscais
MaFisEnd()			

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STBTaxTES
Rotina busca TES do Produto considerando Tes Padrao,
TES do Cadastro de produtos e TES Inteligente.

@param nDocImpOut  	Documento de 1-Entrada / 2-Saida     
@param cTypeOper 		Tipo de Operacao Tabela "DF" do SX5    
@param cCliForCod 		Codigo do Cliente ou Fornecedor
@param	 cCliForLoja 	Loja do Cliente ou Fornecedor            
@param cTipoCF 			Tipo Cliente ou Fornecedor								                
@param cItem 	 		Codigo Item
@param cField 			Campo
@param cTESItem 		TES do Item (Produto)   
@author  Varejo
@version P11.8
@since   04/04/2012
@return  cRetTES - Retorna TES
@obs     
@sample
/*/
//-------------------------------------------------------------------
 
Function STBTaxTES(	nDocImpOut	,	cTypeOper	,	cCliForCod	,	cCliForLoja	,;
						cCliOrFor	,	cItem		,	cField		,	cTESItem		,;
						lListProd) 	

Local cSmartTES 		:= ""								// TES Inteligente
Local cRetTES 			:= ""								// Retorno codigo da TES
Local cTESList			:= SuperGetMV("MV_LJLPTSV",,"")		// Tipo de Entrada/Saida padrao para o Pedido de Venda
Local cTpOperLst		:= SuperGetMV("MV_LJLPTIV",,"")		// Tipo da Operacao para o Pedido de Venda (TES Inteligente)
Local xRet				:= "" 								// Retorno de MacroExecução da Lista

	
Default nDocImpOut 		:= 0 		// Documento de 1-Entrada / 2-Saida     
Default cTypeOper 		:= ""		// Tipo de Operacao Tabela "DF" do SX5    
Default cCliForCod 		:= ""		// Codigo do Cliente ou Fornecedor
Default cCliForLoja 	:= ""		// Loja do Cliente ou Fornecedor            
Default cCliOrFor 		:= ""		// Tipo Cliente ou Fornecedor								                
Default cItem 			:= ""		// Codigo Item
Default cField 			:= ""		// Campo 
Default cTESItem		:= ""		// TES do Item   
Default lListProd		:= .F.		// Produto Lista
	
LjGrvLog( "MaTesInt", "Inicio", cItem)
If !lListProd  
	//Retorna o conteudo do parâmetro MV_LJOPTES
	If ExisteSx6("MV_LJOPTES") .And. ExistFunc("LjOpTESInt")
		cTypeOper := LjOpTESInt()
	EndIf

	// Busca TES inteligente
	cSmartTES := MaTesInt(	nDocImpOut	,	cTypeOper	,	cCliForCod	,	cCliForLoja	,;
								cCliOrFor	,	cItem		,	cField							)
Else
	If !Empty(cTpOperLst)
		If Substr(cTpOperLst,1,1)= "&"
		   		xRet  := &(SubStr(cTpOperLst,2,Len(cTpOperLst))) 	
		   		If ValType(xRet) == "C"
		   	 		cTpOperLst  := xRet
		   		EndIf 		
		EndIf
	EndIf
	
	If !Empty(cTpOperLst)
	
		cSmartTES := MaTesInt(	nDocImpOut	,	cTpOperLst	,	cCliForCod	,	cCliForLoja	,;
								cCliOrFor	,	cItem		,	cField							)
	EndIf
EndIf

	
/*/
Prioridades da utilizacao da TES:	
1 - TES Inteligente
2 - TES do Item (se Lista)
3 - TES do Item (Produto)
4 - TES Padrao	
/*/			

If !Empty(cSmartTES)
	//	TES Inteligente
	cRetTES := cSmartTES
ElseIf lListProd .AND. !Empty(cTESList)
	cRetTES := cTESList
ElseIf !Empty(cTESItem)
	// TES do Item
	cRetTES := cTESItem
Else
	// TES Padrao
	cRetTES :=	SuperGetMV("MV_TESSAI",,"501") 
EndIf

LjGrvLog( "MaTesInt", "Final", cItem)	
	
Return cRetTES

//-------------------------------------------------------------------
/*/{Protheus.doc} STBTaxSit
Verifica a situacao tributaria do item

@param 	nItem			Numero do item na venda 					                
 
@author  Varejo
@version P11.8
@since   04/04/2012
@return  cSitTrib - Retorna Situacao tributaria do Item
@obs     Usar este metodo somente apos ter adicionado o item 
		  nas funcoes fiscais			
@sample
/*/
//-------------------------------------------------------------------
Function STBTaxSit( nItem )
Local cTaxSit	:= ""			// Situacao tributaria do Item
Local cClasfis	:= ""			// Classificacao fiscal
Local nAliqRed 	:= 0			// Valor da aliq reduzida
Local lEmitNFCe	:= STBGetNFCE()	// valida se é NFC-e ou não
Local lEmitSAT	:= STFGetCfg("lUseSAT",.F.)
Local nAliqISS	:= 0
Local aDadoTES	:= {}
Local lAlqIssIse:= .F.

Default	nItem	:= 0			// Numero do item na venda

//tratamento para verificar se está no modo SAT
lEmitSAT := IIf( ValType(lEmitSAT) == "U", .F., lEmitSAT)
	
/*/
	Verifica se o item ja existe nas funcoes fiscais 
/*/
If STBTaxFoun("IT",nItem)
		
	/*
		TABELA - CODIGO DE SITUACAO TRIBUTARIA DO ICMS	
			
		CODIGO  	-  	DESCRICAO
		00			-	Tributada integralmente
		10			-	Tributada e com cobranca do ICMS por substituicao tributaria
		20			-	Com reducao de base de calculo
		30			-	Isenta ou nao tributada e com cobrança do ICMS por substituicao tributaria
		40			-	Isenta
		41			-	Nao tributada
		50			-	Suspensao
		51			-	Diferimento
		60			-	ICMS cobrado anteriormente por substituicao tributaria
		70			-	Com reducao de base de calculo e cobrança do ICMS por substituicao tributaria
		90			-	Outros
	*/
		
	// Pega classificacao fiscal		
	cClasfis := SubStr(STBTaxRet(nItem,"IT_CLASFIS"),2,2)		
	aDadoTES := STBTaxRet(nItem,"IT_TS")
	
	/*Segundo regras do Fiscal para considerar a isenção de ISS
	é necessário a regra abaixo para que não seja feito nenhum calculo*/
	If aDadoTES[03] == "N" .And. aDadoTES[20] == "N" 
		/*
			Foi avaliado somente permitir a configuração dos tipos 07 e 06
			no caso do Isento pois os outros tipos se referem a modalidades
			que não são comumente usadas no PDV
		*/
		If aDadoTES[21] == "I" .And. ( ( AllTrim(aDadoTES[112]) $ "07|06" ) .Or. (Empty(AllTrim(aDadoTES[112]))))
			If AllTrim(aDadoTES[112]) == "07" //Nao tributado
				cTaxSit := "NS"
			ElseIf AllTrim(aDadoTES[112]) == "06" //Isento
				cTaxSit := "IS1" 
			Else                          
				//Caso não esteja configurado, considero isento
				cTaxSit := "IS1" //Isento
			EndIf
			lAlqIssIse := .T.
		ElseIf aDadoTES[21] == "O"
			cTaxSit := "NS"
			lAlqIssIse := .T.
		EndIf
	EndIf
	
	If !lAlqIssIse
		If AllTrim(aDadoTES[20])  == "S" // Verifica se ISS
			nAliqISS := STBTaxRet(nItem,"IT_ALIQISS")
			If nAliqISS > 0
				cTaxSit := "S" + AllTrim (Str(nAliqISS,5,2 ))
			Else
				cTaxSit := "S" + AllTrim (Str(SuperGetMv("MV_ALIQISS"),5,2 ))
			EndIf
			
		ElseIf lEmitNFCe .AND. !lEmitSAT
			cTaxSit := AllTrim( Str(STBTaxRet(nItem,"IT_ALIQICM"),5,2) )
		Else
			Do Case
				Case cClasfis == "40" // Verifica se e Isento("I")
					cTaxSit := "I"
					
				Case cClasfis == "41" // Verifica se e Nao sujeito a ICMS("N")
					cTaxSit := "N"
					
				Case cClasfis == "60" // Verifica se e Substituicao tributaria (Icms Solidario)("F")
					cTaxSit := "F"
							
				Case cClasfis $ "00|10|20|70" // Verifica se e alguma forma tributada ICMS("T")
					cTaxSit := "T" + AllTrim(Str(STBTaxRet(nItem,"IT_ALIQICM"),5,2))
					
					//Caso possua reducao de base vai buscar a aliquota reduzida
					If cClasfis $ "20|70" 
						nAliqRed := STDAlqRed() // Vai verificar se o produto possui aliquota reduzida la na SB0
						If nAliqRed > 0
							cTaxSit := "T" + AllTrim(Str(nAliqRed, 5,2))
						EndIf	
					EndIf	
				
				OtherWise 
					// Se nao Caiu em nenhum dos casos
					// Pode nao ter preenchido o campo classificacao fiscal da TES. 
					// Sera considerado tributado caso tenha aliquota
					If !Empty( AllTrim(Str(STBTaxRet(nItem,"IT_ALIQICM"),5,2)) )
						cTaxSit := "T" + AllTrim(Str(STBTaxRet(nItem,"IT_ALIQICM"),5,2))
					EndIf
			EndCase
		EndIf
	EndIf
EndIf

Return cTaxSit

//-------------------------------------------------------------------
/*/{Protheus.doc} STBStAdjust
Ajusta a string que vai gravar o tipo de tributacao do item

@param 	cSitTrib			Situacao tributaria do item 
@author  Varejo
@version P11.8
@since   29/11/2012
@return  cSitTrib			Situacao tributaria do item ajustada
/*/
//-------------------------------------------------------------------
Function STBStAdjust( cSitTrib )
Local cSitSFT			:= ""	 	// Situacao tributaria
Local cAliqIcm		:= ""		// Aliquota 

Default cSitTrib 	:= ""		// Situacao tributaria

//No caso de Tributado , tem que ser da mesma aliquota 
If "T" $ cSitTrib 

	cAliqIcm	:= StrTran(cSitTrib," ","")
	cSitSFT 	:= StrTran(cAliqIcm,".","") 
	cSitSFT 	:= SubStr(cSitSFT,2,Len(cSitSFT))
	cAliqIcm	:= SubStr(cAliqIcm,2,Len(cAliqIcm))
	
	If Len(cSitSFT) == 1 .OR. Len(SubStr(cAliqIcm,1,At(".",cAliqIcm)-1)) == 1
		cSitSFT := "0"+cSitSFT
	EndIf
	
	cSitTrib := "T"+PadR(cSitSFT,4,"0")
	
ElseIf "S" $ cSitTrib
	
	If SubStr(cSitTrib,1,1) $ "F#I#N" // FS1 - NS1 - IS1
		cSitTrib	:= cSitTrib
	Else
		cAliqIcm	:= StrTran(cSitTrib," ","")
		cSitSFT 	:= StrTran(cAliqIcm,".","") 
		cSitSFT 	:= SubStr(cSitSFT,2,Len(cSitSFT))
		cAliqIcm	:= SubStr(cAliqIcm,2,Len(cAliqIcm))
		
		If Len(cSitSFT) == 1 .OR. Len(SubStr(cAliqIcm,1,At(".",cAliqIcm)-1)) == 1
			cSitSFT := "0"+cSitSFT
		EndIf
		cSitTrib := "S"+PadR( cSitSFT ,4,"0")
	EndIf
		
ElseIf SubStr(cSitTrib,1,Len(cSitTrib)) $ "F#I#N"

	cSitTrib += "1"
		  
EndIf

Return cSitTrib 

//-------------------------------------------------------------------
/*/{Protheus.doc} STBStartTax
Inicia funções fiscais ao inicializr o sistema

@author  Varejo
@version P11.8
@since   29/11/2012
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------	
Function STBStartTax()

Local cCliCode			:= STDGPBasket("SL1","L1_CLIENTE")		// Código do Cliente		
Local cCliLoja			:= STDGPBasket("SL1","L1_LOJA")			// Loja do Cliente
Local cCliType			:= STDGPBasket("SL1","L1_TIPOCLI")		// Tipo do Cliente

If !(STBTaxFoun())

	STBTaxIni(	cCliCode	,	cCliLoja 	,	"C"			,	"S"		,;
				.F.			,	"SB1"		,	"LOJA701"	,	.T.		,;
				cCliType	)
				
EndIf

Return Nil
	
	
//-------------------------------------------------------------------
/*/{Protheus.doc} STBTaxGrupTrib
Armazena valores para Rateio do desconto e acréscimo no Total por alíquota 
de acordo com o método das impressoras fiscais. (Chamada pela MATXFIS)

@param aNfCab				Cabeçalho Nota Fiscal
@param aNfItem				Itens Nota Fiscal 
@param nItem				Numero do Item	
@param cReferencia	 	Referencia
@author  Varejo
@version P11.8
@since   29/11/2012
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------	
Function STBTaxGrupTrib( aNfCab , aNfItem , nItem , cReferencia )

Local nPosAliq   := 0	// Posicao aliquota ICMS no array aGrupTrib

Default aNfCab 		:= {}
Default aNfItem 	:= {}
Default nItem		:= 0
Default cReferencia	:= ""

If Len(aNfCab) > 0 .AND. Len(aNfItem) > 0 .AND. nItem > 0 .AND. !Empty(cReferencia)

	// 1º Passo: Agrupar e armazenar todos os valores por alíquota
	nPosAliq := aScan( aGrupTrib , { |x| x[1] == aNfItem[nItem][IT_ALIQICM] } )
	If nPosAliq > 0
		If aNfItem[nItem][IT_TOTAL] == aGrupTrib[nPosAliq][04] //Item de mesmo valor, adiciona item para depois distribur o residuo entre os itens
			aAdd( aGrupTrib[nPosAliq][03], nItem )
		Else
			If (cReferencia == "IT_DESCTOT")
				If aNfItem[nItem][IT_TOTAL] > aGrupTrib[nPosAliq][04] 
		   			aGrupTrib[nPosAliq][03] := {nItem}
			   		aGrupTrib[nPosAliq][04] := aNfItem[nItem][IT_TOTAL]
			 	EndIf
		  	ElseIf (cReferencia == "IT_ACRESCI")
		  		If aNfItem[nItem][IT_TOTAL] < aGrupTrib[nPosAliq][04] 
			   		aGrupTrib[nPosAliq][03] := {nItem}
			   		aGrupTrib[nPosAliq][04] := aNfItem[nItem][IT_TOTAL]
				EndIf
		 	EndIf
		EndIf	
		aGrupTrib[nPosAliq][02] += aNfItem[nItem][IT_TOTAL]
		aAdd( aGrupTrib[nPosAliq][05], { nItem , aNfItem[nItem][IT_TOTAL] , 0 } )
	Else
		aAdd( aGrupTrib , {} )
		nPosAliq := Len(aGrupTrib)
		aAdd (aGrupTrib[nPosAliq], aNfItem[nItem][IT_ALIQICM]	   			)	//01 - Tipo Tributacao 
		aAdd (aGrupTrib[nPosAliq], aNfItem[nItem][IT_TOTAL]	   				)	//02 - Valor da Soma dos itens desta Tributacao
		aAdd (aGrupTrib[nPosAliq], {nItem}					   		 			)	//03 - Posicao do item de Maior/Menor Valor
		aAdd (aGrupTrib[nPosAliq], aNfItem[nItem][IT_TOTAL]	   				)	//04 - Valor Maior/Menor
		aAdd (aGrupTrib[nPosAliq], {{nItem,aNfItem[nItem][IT_TOTAL],0}}	)	//05 - Posicao do Item ; Valor dos itens desta Tributacao SEM descontos ou acrescimos proporcionalizados ; L2_ITEM jah COM descontos ou acrescimos proporcionalizados
		aAdd (aGrupTrib[nPosAliq], 0   							  				)	//06 - Valor de Desconto ou Acrescimo relacionado a esta Tributacao (de acordo com a regra de rateio da impressora)
	EndIf
EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} STBTaxRateio
Rateia Desconto e Acréscimo pelo mesmo método que as impressoras fiscais

@param aNfCab				Cabeçalho Nota Fiscal
@param aNfItem				Itens Nota Fiscal 
@param aPosCpo				Posição campo de referência	
@param cReferencia	 	Referencia
@param nDecimais			Decimais
@author  Varejo
@version P11.8
@since   29/11/2012
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------	
Function STBTaxRateio( 	aNfCab 	, aNfItem	, aPosCpo , cReferencia ,;
							 nDecimais )

Local nAcumula   		:= 0	// Acumula os descontos/acrescimos rateados
Local nResiduo   		:= 0	// Armazena resíduo do rateio
Local nItResiduo 		:= 0	// Residuo de 0.1 a aplicar no item
Local nJ				:= 0	// Contador
Local nX				:= 0	// Contador
Local nPercEfet  		:= 0	// Percentual efetivo do rateio pelo método de impressora fiscal
Local nPercProd  		:= 0	// Percentual do produto em relação ao total da alíquota
Local nImpDecimais		:= 2	// Decimais utilizadas de acordo com a impressora. Ex: Epson = 15 ; Bematech = 2
Local nPosMaiorItem		:= 0	// Posicao do maior item do grupo de tributacao em relacao a todo array.
Local nPosItArrMaior 	:= 0	// Posicao do maior item em relacao ao array do grupo de tributacao especifico
Local nMaiorAliq     	:= 1	// Maior aliquota dentre os grupos de tributacao
Local nPercProduto   	:= 0	// Precentual do produto em relacao a seu valor sobre o desconto do grupo de tributacao
Local lEmitSAT			:= STFGetCfg("lUseSAT",.F.)	// Verifica se eh venda em estacao SAT

Default aNfCab 		:= {}
Default aNfItem 	:= {}
Default aPosCpo		:= ""
Default cReferencia	:= ""
Default nDecimais	:= 2

nImpDecimais := STBTaxDec('2') // 1 = Grava no  ini , 2 = Recupera informacao do ini

If Len(aNfCab) > 0 .AND. Len(aNfItem) > 0 .AND. Len(aPosCpo) > 0 .AND. Len(aGrupTrib) > 0

	// 2º Passo: Calcula o Percentual efetivo do Desconto ou do Acrescimo (truncado em duas casas decimais)   
	If (cReferencia == "IT_DESCTOT")
		nPercEfet := NoRound( (( aNfCab[NF_DESCTOT] / aNfCab[NF_TOTAL] ) * 100), nImpDecimais ) / 100
	ElseIf (cReferencia == "IT_ACRESCI")
		nPercEfet := NoRound( (( aNfCab[NF_ACRESCI] / aNfCab[NF_TOTAL] ) * 100), nImpDecimais) / 100
	EndIf  
		
	// Calcula e Acumula os valores aplicando o percentual efetivo no total por alíquotas
	For nX := 1 To Len(aGrupTrib)
		
		aGrupTrib[nX][06] := NoRound( aGrupTrib[nX][02] * nPercEfet, 2 )
	    
	    nAcumula += aGrupTrib[nX][06]   
				
	Next nX
	
	// Calculo do residuo
	If (cReferencia == "IT_DESCTOT")
		nResiduo := aNfCab[NF_DESCTOT] - nAcumula			
	ElseIf (cReferencia == "IT_ACRESCI")
		nResiduo := aNfCab[NF_ACRESCI] - nAcumula
	EndIf 
	
	// Verifica qual a alíquota que tem maior valor total
	If Abs(nResiduo) > 0
		aGrupTrib := aSort( aGrupTrib ,,,{|x,y| x[2] > y[2]}) // Ordena por ordem crescente de totais por alíquotas			
		nMaiorAliq := 1
		//Se os valores dos grupos de aliquota forem iguais, o residuo ira sempre para a maior aliquota.
		For nX := 1 To Len(aGrupTrib)
			If Len(aGrupTrib) >= nX	 + 1  
				If aGrupTrib[nX][2] == aGrupTrib[nX+1][2] // Valores iguais
			    	If aGrupTrib[nX+1][1] > aGrupTrib[nX][1]
			    		nMaiorAliq := nX + 1
			    	EndIf
			 	Else
			 		Exit
			 	EndIf
			EndIf
		Next nX
	EndIf
	
	// Atribui resíduo para alíquota de maior valor total
	If nMaiorAliq > 0 .AND.  nResiduo <> 0
		aGrupTrib[nMaiorAliq][6] += nResiduo
	EndIf	
	
	// Laço de Ajuste dos Itens
	For nX := 1 To Len(aGrupTrib)
	
		nAcumula	:= 0
		nResiduo	:= 0
		
		// Percorre todos os itens deste grupo de Tributacao para acertar os valores de Desconto ou Acrescimo de cada item
		For nJ := 1 To Len(aGrupTrib[nX][05])
		
			//Calcula a proporcionalizacao de Acrescimo ou Desconto para este item
  			nPercProduto := aGrupTrib[nX][05][nJ][02] / aGrupTrib[nX][02] // Valor do Item pelo total da alíquota    
		      
			//Calcula o valor de Acrescimo ou Desconto para este item
			If lEmitSAT
				// Arredondamento conforme a regra do SAT
				aGrupTrib[nX][05][nJ][03] := LjArredSat( (aGrupTrib[nX][06] * nPercProduto) , nDecimais  )
			Else
				aGrupTrib[nX][05][nJ][03] := NoRound( (aGrupTrib[nX][06] * nPercProduto) , nDecimais  ) 
			EndIf

			
			// Atribui à referência do Item
			aNfItem[aGrupTrib[nX][05][nJ][01]][Val(aPosCpo)] := aGrupTrib[nX][05][nJ][03]
			
			nAcumula += aNfItem[aGrupTrib[nX][05][nJ][01]][Val(aPosCpo)]
			
		Next nJ
		
		// Calculo do residuo
		If (cReferencia == "IT_DESCTOT")
			nResiduo := aGrupTrib[nX][6] - nAcumula			
		ElseIf (cReferencia == "IT_ACRESCI")
			nResiduo := aGrupTrib[nX][6] - nAcumula
		EndIf
		
		// Aplica o resíduo no Item de Maior/Menor Valor (posição 3 do aGrupTrib) 
		If Abs(nResiduo) > 0
			nPosMaiorItem 	:= 0	
			nPosItArrMaior   	:= 0
			nPosMaiorItem 	:= aGrupTrib[nX][03][1]	 
			nPosItArrMaior 	:= aScan( aGrupTrib[nX][5] , { |x| x[1] == nPosMaiorItem } )

			If  nPosItArrMaior > 0
				aGrupTrib[nX][05][nPosItArrMaior][03] += nResiduo
				aNfItem[aGrupTrib[nX][05][nPosItArrMaior][01]][Val(aPosCpo)] := aGrupTrib[nX][05][nPosItArrMaior][03]
			EndIf
				
		EndIf
	
	Next nX		
	
EndIf

aGrupTrib := {}

Return Nil

//-------------------------------------------------------------------	
/*/{Protheus.doc} STBTaxDec
Grava e recupera no sigaloja.ini o numero de decimais utilizados 
nos ecfs para os calculos de rateio de desconto 
@param cTypeOper	 	Tipo de operacao 1= Grava | 2= Recupera

@author  Varejo
@version P11.8
@since   29/05/2014
@return  nRet - Casas decimais que são usadas na regra do ECF
@obs     
@sample
/*/
//-------------------------------------------------------------------	
Function STBTaxDec(cTypeOper)

Local cDecimais	:= "2"  //Padrao bematech Sweda, de decimais para truncamento de valor no calculo no ECF  
Local cEcf			:= STFGetStation( 'IMPFISC' )
Local lAutomato     := If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)
Local cGetCliDir	:= If(lAutomato,"",GetClientDir())
Local nRet			:= 2   //Retorno Padrao 

Default cTypeOper	:= "0" 

If cTypeOper == "1"
	// grava a informação no sigaloja.ini para ser utilizada na regra de desconto e rateio no FRTA271G, igual ao do ECF
	If 'EPSON' $ cEcf  .OR. 'ITAU' $ cEcf  
		cDecimais := "15" 
	EndIf

	WritePProString( "Decimais ECF", "Decimais", cDecimais , cGetCliDir + "SIGALOJA.INI" )
	
ElseIf cTypeOper == "2" 
	cDecimais 	:= GetPvProfString("Decimais ECF", "Decimais", " ", cGetCliDir + "SIGALOJA.INI" )	// Ler qtd decimais usada no ECF. Informacao grv na inicalizacao do sistema
EndIF

If !Empty(cDecimais) .AND. Val(cDecimais) > 0 
	nRet := Val( cDecimais ) 
EndIf	

Return nRet

/*/{Protheus.doc} STBEmiteNF
	chama a rotina LjNFFimVd() para definir se emite NF-e 
	@type  Function
	@author caio.okamoto
	@since 07/07/2023
	@version 12
	@param cCliCod, 	caractere, 	código do cliente
	@param cCliLoja, 	caractere, 	código da loja onde cliente está cadastrado
	@return lEmiteNFe, 	lógico, 	.T. se emite NF-e
	/*/
Function STBEmiteNF(cCliCod, cCliLoja)
Local lCliPadrao	:= .F.
Local lMVFISNOTA	:= SuperGetMV("MV_FISNOTA",.F.,.F.) .AND. !Empty(AllTrim( SuperGetMV("MV_LOJANF",.F.,"UNI"))) .AND. SuperGetMv("MV_LJLBNT",.F.,0)>0
Local lEmiteNFe		:= .F.

Default cCliCod		:= ""
Default cCliLoja	:= ""

If !STFGetCfg("lPafEcf") 

	lCliPadrao:= (AllTrim(cCliCod)+AllTrim(cCliLoja)) == ( AllTrim( SuperGetMV("MV_CLIPAD", .F., "") ) + AllTrim( SuperGetMV("MV_LOJAPAD", .F., "") ) )

	If lMVFISNOTA .and. !lCliPadrao
		lEmiteNFe := LjNFFimVd(.T., .F., .F.)		//Altera para emissao de Nota Fiscal
	EndIf 

EndIf

Return lEmiteNFe

/*/{Protheus.doc} STBGetTax
Retorna informacoes dos tributos utilizados no Configurador de tributos

@type function
@author Alessandro Santos
@since 19/04/2025
@version P12

@param nItem, numérico, Item a ser consultado

@return json, Informacoes dos tributos do Configurador de Tributos
/*/
Function STBGetTax(cIdTrib as character, nItem as numeric) as json

Local lCfgTrib  := If(FindFunction("LjCfgTrib"), LjCfgTrib(), .F.) //Verifica se Configurador de Tributos esta habilitado
Local jCfgTaxes := JsonObject():New()

Default cIdTrib := ""

If lCfgTrib	
	jCfgTaxes := LjCfgTaxes(cIdTrib, nItem)
EndIf

Return jCfgTaxes

/*/{Protheus.doc} STBVerTotTax
Verifica se tributo soma ou subtrai no total da venda

@type function
@author Alessandro Santos
@since 19/04/2025
@version P12

@param cIdTributo, caracter, Id do tributo
@param nTpVerif, numérico, Soma ou subtrai no total

@return lógico, Acao realizada no total
/*/
Function STBVerTotTax(cIdTributo as character, nTpVerif as numeric) as logical

Local lCfgTrib as logical
Local lRet as logical 

lCfgTrib := If(FindFunction("LjCfgTrib"), LjCfgTrib(), .F.) //Verifica se Configurador de Tributos esta habilitado
lRet := .F.

If lCfgTrib
	lRet := LjCfgAgreg(cIdTributo, nTpVerif)
EndIf

Return lRet
