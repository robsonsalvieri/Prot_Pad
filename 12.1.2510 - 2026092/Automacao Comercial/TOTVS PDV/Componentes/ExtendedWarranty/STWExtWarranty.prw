#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STPOS.CH"
#INCLUDE "STWFINDITEM.CH"

Static oGarEstItens := nil //Objeto para armazenamento de informacoes de Itens Servicos Financeiros


//-------------------------------------------------------------------
/*/{Protheus.doc} STWItemGarEst
Function Armazena, Retorna ou Limpa Item Garantia Estendida em Array

@param   nTipoProc		Tipo do Processo (1=Set - 2=Get - 3=Clear)
@param   cCodGarEst		Produto Garantia
@param   nPriceGarEst		Valor do Produto Garantia
@param   cCodItem			Produto da Venda
@param   nItemLine		Item do Produto da Venda
@param   cTypeItem		Tipo do Item - Usado na importacao de orcamento
@author  Varejo
@version P11.8
@since   20.12.2016
@return  lRet				Garantia Estendida Avulso
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STWItemGarEst( nTipoProc		, cCodGarEst	, nPriceGarEst	, cCodItem,;
							 nItemLine		, cTypeItem	, nPriceItem		, cSerieItem	)

Local xRet				:= Nil	// Retorno da função

Default nTipoProc		:= 1 	//Tipo do Processo (1=Set - 2=Get - 3=Clear - 4=Del - 5=Sel)
Default cCodGarEst		:= "" 	//Produto Servico
Default nPriceGarEst	:= 0 	//Valor do Produto Servico
Default cCodItem		:= "" 	//Produto da Venda
Default nItemLine		:= 0 	//Item do Produto da Venda
Default cTypeItem		:= "" 	//Tipo do Item - Usado na importacao de orcamento
Default nPriceItem		:= 0 	//Valor do Produto da Venda
Default cSerieItem		:= ""	//Série do Produto da Venda

/*
	Inicializando objeto
*/
If oGarEstItens = nil
	oGarEstItens := Adm_Item_ExtWarranty():New()
EndIf

/*
	Armazena Item Garantia Estendida
*/
If Valtype(oGarEstItens) <> "U" //Valida se objeto foi instanciado
	If nTipoProc == 1
		xRet := oGarEstItens:SetGarEst(cCodGarEst, nPriceGarEst, cCodItem, nItemLine,;
									 cTypeItem, nPriceItem, cSerieItem)
	ElseIf nTipoProc == 2
		xRet := oGarEstItens:GetGarEst(nItemLine)
	ElseIf nTipoProc == 3 
		xRet := oGarEstItens:ClearGarEst()
	ElseIf nTipoProc == 4
		xRet := oGarEstItens:DelGarEst(cCodGarEst, cCodItem, nItemLine)
	ElseIf nTipoProc == 5
		xRet := oGarEstItens:SelGarEst(cCodGarEst, cCodItem, nItemLine, nPriceGarEst)
	EndIf
EndIf

Return xRet 


//-------------------------------------------------------------------
/*/{Protheus.doc} STWPrintGarEst
Funcao para impressao de relatorios gerenciais Garantia Estendida

@param   
@author  Varejo
@version P11.8
@since   20.12.2016
@return  				
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STWPrintGarEst()

Local aRelGE	:= {}										//Array para passagem de parâmetro de função rdMake
Local nVias		:= 2										//Número de vias
Local nCont		:= 0										//Contador
Local cTexto	:= ""										//Texto
Local cImpRGer	:= SuperGetMV("MV_RELGART",,"U_LOJR600A") 
Local aGarItens := STWItemGarEst(2)							//Tipo do Processo (1=Set - 2=Get - 3=Clear - 4=Del - 5=Sel)
Local cNomeCli 	:= POSICIONE("SA1", 1, xFilial("SA1") + STDGPBasket( "SL1" , "L1_CLIENTE" ) + STDGPBasket( "SL1" , "L1_LOJA" ), "A1_NOME")//Retorna o nome do Cliente
 
If ExistFunc("STDPrintGarEst")
	For nCont := 1 To Len(aGarItens) 
		/* Garantia Estendida habilitada e selecionada */
		If !aGarItens[nCont][8] .And. aGarItens[nCont][9]
			/* Alimenta Rdmake dos Relatorios */
			STDPrintGarEst(aGarItens[nCont], @aRelGE)
		EndIf		
	Next nCont
EndIf
 
/*
	Efetua a impressao
*/ 

If FindFunction(cImpRGer)		//Chamar função RDMAKE    	
	For nCont := 1 To Len(aRelGE)
		cTexto := chr(16) +;
					 &cImpRGer.(aRelGE[nCont][1],;		//Código do produto comum
					 			aRelGE[nCont][2],;		//Descrição do produto comum
					 			aRelGE[nCont][3],;		//Valor do produto comum
					 			aRelGE[nCont][4],;		//Número da série do produto comum
								aRelGE[nCont][5],;		//Código do produto garantia
								aRelGE[nCont][6],;		//Descrição do produto garantia
								aRelGE[nCont][7],;		//Valor do produto garantia
								cNomeCli,;				//Nome do cliente
								1,;						//Número da moeda
								.F.,;					//Se é um serviço financeiro
								.T.)					//Se é um POS PDV
		//Relatorio da conferencia de caixa
		STWManagReportPrint( cTexto ,nVias )
	Next nCont 
Else
	LjGrvLog("STWPrintGarEst","Função "+cImpRGer+" não encontrada, portanto, não será impresso o relatório gerencial no cupom.")
EndIf
 
Return Nil  
