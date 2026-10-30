#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STPOS.CH"
#INCLUDE "STWFINSERVICE.CH"

Static oFinItens := Adm_Item_FinService():New() //Objeto para armazenamento de informacoes de Itens Servicos Financeiros

//-------------------------------------------------------------------
/*/{Protheus.doc} STWValidService
Function Valida Item de Serviço.

@param   nType					Tipo de Validação
@param   aInfoItem			Array do Item
@param   cProductCode			Código do Produto
@param   cCliCode				Código do Cliente
@param   cCliStore			Loja do Cliente
@author  Varejo
@version P11.8
@since   11/06/2014
@return  lRet					Validação do Item
@obs     	nType == 01 		Valida se o produto serviço é Avulso (.T.) ou Vinculado (.F.)
			nType == 02 		Valida se o produto por Faixa de Preço
			nType == 03 		Valida se o cliente não for padrão para serviço financeiro
@sample
/*/
//-------------------------------------------------------------------
Function STWValidService( 	nType, 	aInfoItem, 	cProductCode, 	cCliCode,; 
								cCliStore )
 
Local 			lRet 				:= .F.			// Retorno  

Default		nType				:= 1			// Tipo de Validação (1-Avulso?)
Default		aInfoItem			:= {}			// Array com informação do item
Default		cProductCode		:= ""			// Código do Produto
Default		cCliCode			:= ""			// Código do Cliente
Default		cCliStore			:= ""			// Loja do Cliente

ParamType 0 Var nType	 		As Numeric	   	Default 1
ParamType 1 Var aInfoItem 		As Array	   	Default {}
ParamType 2 Var cProductCode	As Character 	Default ""
ParamType 3 Var cCliCode			As Character 	Default ""
ParamType 4 Var cCliStore		As Character 	Default ""


Do Case
	
	Case nType == 1 //Retorna se o produto serviço é avulso (.T.) ou vinculado (.F.)
			
		If !EMPTY(aInfoItem) .AND. !EMPTY(aInfoItem[ITEM_CODIGO])
			lRet := STBIsBulkServ(aInfoItem[ITEM_CODIGO])
		EndIf
		
	Case nType == 2 //Retorna se o produto serviço é por Faixa de Preço
			
		If !EMPTY(aInfoItem) .AND. !EMPTY(aInfoItem[ITEM_CODIGO])
			lRet := STBIsPriceRange(aInfoItem[ITEM_CODIGO])
		EndIf
	
	Case nType == 3 //Valida se o cliente não for padrão para serviço financeiro
		
		lRet := !( AllTrim(cCliCode) == SuperGetMv("MV_CLIPAD") .AND. AllTrim(cCliStore) == SuperGetMV("MV_LOJAPAD") )
		
	OtherWise
	 
		lRet := .F.
		
EndCase
				
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWServPrice
Function Retorna preco de serviço quando faixa de preço.

@param   cItemCode			Produto
@param   cFil					Filial
@author  Varejo
@version P11.8
@since   11/06/2014
@return  nRet					Preço do serviço
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STWServPrice( cItemCode, cFil )

Local 			aInfoItem			:= {}								//Array do Produto de Serviço
Local 			lFinServ    		:= AliasIndic("MG8") .AND. SuperGetMV("MV_LJCSF",,.F.)	// Define se habilita o controle de servicos financeiros
Local 			lContinua			:= lFinServ							//Define se continua o processo
Local 			cServType	   		:= SuperGetMv("MV_LJTPSF",,"SF")	// Define o tipo do produto de servico financeiro
Local 			nRet				:= 0								//Retorna o preço da faixa de preço
Local 			cProdCode			:= ""								//Codigo Produto da Venda
Local 			cGroupCode			:= ""								//Grupo Produto da Venda
Local 			nProdPrice			:= 0								//Preco Produto da Venda

Default 		cItemCode 			:= ""
Default 		cFil	  			:= ""

ParamType 0 Var cItemCode 	As Character 	Default ""
ParamType 1 Var cFil			As Character 	Default ""

If lContinua
	
	//Verifica se é produto serviço financeiro.
	lContinua := Posicione("SB1", 1, xFilial("SB1" + cItemCode), "B1_TIPO") == cServType
		 
	//Verifica se o produto é Vinculado e por Faixa de Preço.
	If lContinua
		aInfoItem 	:= STDProdServ(cItemCode)
		
		//Vinculado?		Avulso (.T.) ou Vinculado (.F.)
		lContinua 		:= !( STWValidService(1,aInfoItem) )
		
		//Caso sim, busca preço pela faixa de preço do produto Vinculado.
		//Mesmo quando precificação for Fixo, o preço virá da tabela de Faixa de Preço com registro unico (MBL).
		If lContinua
			//Busca codigo/grupo/Preco do produto da venda
			STDProdInfo( @cProdCode, @cGroupCode, @nProdPrice )
						
			nRet := STDServPrice( aInfoItem[3], cProdCode, cGroupCode, nProdPrice )
		EndIf 
	EndIf	

EndIf

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STWItemFin
Function Armazena, Retorna ou Limpa Item Servico Financeiro em Array

@param   nTipoProc		Tipo do Processo (1=Set - 2=Get - 3=Clear)
@param   cCodServFin		Produto Servico
@param   nPriceServFin	Valor do Produto Servico
@param   cCodItem			Produto da Venda
@param   nItemLine		Item do Produto da Venda
@param   cTypeItem		Tipo do Item - Usado na importacao de orcamento
@author  Varejo
@version P11.8
@since   01/07/2014
@return  lRet				Servico Financeiro Avulso
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STWItemFin( nTipoProc, cCodServFin, nPriceServFin, cCodItem, nItemLine, cTypeItem )

Local xRet			:= Nil									// Retorno da função

Default nTipoProc		:= 1 	//Tipo do Processo (1=Set - 2=Get - 3=Clear - 4=Del - 5=Sel)
Default	 cCodServFin	:= "" 	//Produto Servico
Default	 nPriceServFin	:= 0 	//Valor do Produto Servico
Default cCodItem		:= "" 	//Produto da Venda
Default	 nItemLine		:= 0 	//Item do Produto da Venda
Default cTypeItem		:= "" 	//Tipo do Item - Usado na importacao de orcamento

ParamType 0 Var nTipoProc 		As Numeric 	Default 0
ParamType 1 Var cCodServFin		As Character 	Default ""
ParamType 2 Var nPriceServFin 	As Numeric 	Default 0
ParamType 3 Var cCodItem			As Character 	Default ""
ParamType 4 Var nItemLine 		As Numeric 	Default 0
ParamType 5 Var cTypeItem 		As Character 	Default ""

/*
	Armazena Item Servico Financeiro
*/
If Valtype(oFinItens) <> "U" //Valida se objeto foi instanciado
	If nTipoProc == 1
		xRet := oFinItens:SetServFin(cCodServFin, nPriceServFin, cCodItem, nItemLine, cTypeItem)
	ElseIf nTipoProc == 2
		xRet := oFinItens:GetServFin(nItemLine)
	ElseIf nTipoProc == 3 
		xRet := oFinItens:ClearServFin()
	ElseIf nTipoProc == 4
		xRet := oFinItens:DelServFin(cCodServFin, cCodItem, nItemLine)
	ElseIf nTipoProc == 5
		xRet := oFinItens:SelServFin(cCodServFin, cCodItem, nItemLine, nPriceServFin)
	EndIf
EndIf

Return xRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} STWItemFin
Funcao para impressao de relatorios gerenciais Servico Financeiro

@param   
@author  Varejo
@version P11.8
@since   23/07/2014
@return  				
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STWPrintServ()

Local aRelSF		:= {}
Local nVias			:= 2
Local nCont			:= 0
Local cTexto		:= ""
Local cImpRGer		:= "" 
Local aFinItens 	:= STWItemFin(2)	//Tipo do Processo (1=Set - 2=Get - 3=Clear - 4=Del - 5=Sel)
 
If ExistFunc("STDPrintServ")
	For nCont := 1 To Len(aFinItens) 
		/* Servico Financeiro habilitado e selecionado */
		If !aFinItens[nCont][8] .And. aFinItens[nCont][9]
			/* Alimenta Rdmake dos Relatorios */
			STDPrintServ(aFinItens[nCont], @aRelSF) 
		EndIf		
	Next nCont
EndIf
 
/*
	Efetua a impressao
*/ 
For nCont := 1 To Len(aRelSF)
	cImpRGer := aRelSF[nCont][8]
	
	If FindFunction(cImpRGer)    	
    	If cImpRGer == SuperGetMV("MV_RELGART",,"U_LOJR600A")
 			cTexto := chr(16) + &cImpRGer.(aRelSF[nCont][1],aRelSF[nCont][2],aRelSF[nCont][3],aRelSF[nCont][4],;
   						aRelSF[nCont][5],aRelSF[nCont][6],aRelSF[nCont][7],SA1->A1_NOME,1,.T.,.T.)                  
		Else 
			cTexto := chr(16) + &cImpRGer.(SL1->L1_NUM, Nil)
		EndIf
		//Relatorio da conferencia de caixa
		STWManagReportPrint( cTexto ,nVias )
	EndIf
Next nCont 
 
Return Nil  

//-------------------------------------------------------------------
/*/{Protheus.doc} STWFindServ
Funcao para busca de Servicos Financeiros vinculados

@param1   
@author  Varejo
@version P11.8
@since   02/05/2015
@return  				
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STWFindServ()

Local aFinItens 	:= {}	//Array que contera os Servicos Financeiros vinculados
Local aCriticCli	:= {}	//Array que contera as criticas ao cadastro do cliente
Local lSTWNxtTelaIt	:= ExistFunc("STWNxtTelaIt")

//Verifica se existem Servicos Financeiros Vinculados
aFinItens := STWItemFin(2)	//Tipo do Processo (1=Set - 2=Get - 3=Clear)
		  
// Apresento tela para escolha de serviços quando existir serviços Vinculados (xVar[06]) e não deletados (xVar[08])
// Quando a posição 06 do array estiver 0, significa que não é serviço Vinculado á um produto.
If LEN(aFinItens) > 0 .AND. aScan(aFinItens,{|xVar| xVar[06] <> 0;
					 .AND. xVar[07] <> "IMP" .AND. xVar[08] == .F.}) > 0
	STIExchangePanel( { || STIFinService(aFinItens, aCriticCli) } )
ElseIf LEN(aFinItens) > 0 .AND. aScan(aFinItens,{|xVar| xVar[06] == 0;
					 .AND. xVar[07] <> "IMP" .AND. xVar[08] == .F.}) > 0
	/* Efetua validacao do cliente */
	STBVldClient(aFinItens, aCriticCli)
			
	If Len(aCriticCli) > 0 
		/* Servico Financeiro - Mensagens da validacao do cliente */
		STIExchangePanel({|| STIFinClient(aCriticCli)})					
	Else
		IIf(lSTWNxtTelaIt,STWNxtTelaIt(),STICallPayment())	
	EndIf
Else
	IIf(lSTWNxtTelaIt,STWNxtTelaIt(),STICallPayment())				
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} STWFindTot
Funcao para busca do Totalizador Nao Fiscal

@param   
@author  Varejo
@version P11.8
@since   10/05/2015
@return Totalizador Nao Fiscal Servicos Financeiros  				
@obs     
@sample
/*/
//-------------------------------------------------------------------

Function STWFindTot()

Local cRet 	:= "" 			  	//Totalizador Nao Fiscal
Local aRet 	:= {} 			 	//Array com informacoes Nao Fiscais
Local aDados 	:= {Space(30)} 	//Dados de retorno da funcao  

//Verifica se utiliza TotvsApi
aRet := STFFireEvent(ProcName(0)	,;
      					"STRetTypePrt",;	
				   		aDados)  

//Busca Totalizador Nao Fiscal		
If Len(aRet) > 0 .AND. aRet[1] == 0 .AND. Len(aDados) > 0 .AND. ValType(aDados[1]) == "C"
	If aDados[1] == "TOTVSAPI" //TotvsApi
		cRet := GetPvProfString("Microsiga", "TotalizadorPedido", "RECEBER", GetClientDir() + "TOTVSAPI.INI")
	Else //SigaLoja
		cRet := GetPvProfString("Microsiga", "TotalizadorPedido", "RECEBER", GetClientDir() + "SIGALOJA.INI")
	EndIf
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STWDescServ
Funcao para validar desconto no Total quando venda possui Servicos Financeiros

@param   
@author  Varejo
@version P11.8
@since   12/05/2015
@return Se Permite desconto no total  				
@obs     
@sample
/*/
//-------------------------------------------------------------------

Function STWDescServ()

Local lRet 		:= .T.				//Retorno da validacao
Local nI			:= 0				//Contador
Local aLines 		:= FwSaveRows()	//Array de linhas
Local oModelCesta	:= STDGPBModel()	//Model da cesta
Local oModelItens := oModelCesta:GetModel("SL2DETAIL") //Model com os itens da cesta

/* Verifica se existem Servicos Financeiros na Cesta */
For nI := 1 To oModelItens:Length()
	/* Posiciona na linha do produto cobertura*/
	oModelItens:GoLine(nI)

	/* Verifica quantidade do produto cobertura */
	If STBIsFinService(oModelItens:GetValue("L2_PRODUTO")) .And. !oModelItens:IsDeleted()
		lRet := .F.
		
		STFMessage("STITotalDiscount","STOP", STR0001) //#"Não é possível desconto na venda pois contem Servicos Financeiros" 
		STFShowMessage("STITotalDiscount")
		
		Exit
	EndIf		
Next nI

FwRestRows(aLines)

Return lRet
