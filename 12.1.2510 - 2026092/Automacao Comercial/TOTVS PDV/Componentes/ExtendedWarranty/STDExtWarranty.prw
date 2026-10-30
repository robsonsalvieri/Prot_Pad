#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STPOS.CH"
#INCLUDE "STDFINSERVICE.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} STDPrintGarEst
Function para Buscar alimentar Rdmake dos Relatorios Gerenciais - Garantia Estendida

@param   aSelIten		Array com o item selecionado de Garantia Estendida
@param   aRelSF			Array que contera os itens selecionados para impressao  
@author  Varejo
@version P11.8
@since   20/12/2016
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDPrintGarEst(aSelItem, aRelGE)

Default	 aSelItem 	:= {}	 
Default	 aRelGE 	:= {}

If Len(aSelItem) >= 11		//Se houver total do item vinculado à garantia

	/* Array com informacoes para impressao */ 
	aAdd(aRelGE,;
		{aSelItem[4],;			//Código de Produto Comum
	 	aSelItem[5],;				//Descrição do Produto Comum
	 	Str(a410Arred(aSelItem[10] * 1,"L2_VLRITEM"), TamSx3("L2_VLRITEM")[1],TamSx3("L2_VLRITEM")[2]),;	//Preço do Produto Comum
		aSelItem[11],;			//Série do produto comum
		aSelItem[1],;				//Código da Garantia Utilizada
		aSelItem[2],;				//Descrição da Garantia Utilizada
	 	Str(a410Arred(aSelItem[3] * 1,"L2_VLRITEM"), TamSx3("L2_VLRITEM")[1],TamSx3("L2_VLRITEM")[2]),;	//Valor da Garantia Utilizada
	  	})
Else
	LjGrvLog("STDPrintGarEst","Array aSelItem é menor que 11 elementos")
EndIf
		
Return Nil	



//-------------------------------------------------------------------
/*/{Protheus.doc} STDGeProdVin
Function para retornar o código do produto vinculado, e o seu valor, a partir do STDGPBasket.

@param   cProdGar			Produto Garantia
@author  Varejo
@version P11.8
@since   21/12/2016
@return  cProduto			Produto Comum que vai utilizar aquele Produto Garantia
@return  nVlrItem			Valor do produto comum que será impresso no cupom gerencial
@return  cSerie			Série do Produto Comum que vai utilizar aquele Produto Garantia
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDGEProdVin(cProdGar,cItemProdVin)

Local	nX			:= 0				//Contador
Local	cProduto	:= ""				//Produto Garantia
Local	nVlrItem	:= 0				//Valor do Item
Local 	cSerie		:= ""				//Serie do Produto

For nX := 1 To STDPBLength("SL2")

	//Pesquiso, pelo Produto Garantia (cProdGar), qual produto comum é vinculado ao produto garantia (L2_GARANT).
	If cProdGar == STDGPBasket( "SL2" , "L2_GARANT" , nX ) .AND.;
							cItemProdVin == STDGPBasket( "SL2", "L2_ITEM", nX )
		cProduto	:= STDGPBasket( "SL2" , "L2_PRODUTO" , nX )
		nVlrItem	:= STDGPBasket( "SL2" , "L2_VLRITEM" , nX )
		cSerie		:= STDGPBasket( "SL2" , "L2_NSERIE"  , nX )
		Loop
	EndIf
	
Next nX		//Retorno dados do produto comum (vinculado)

Return {cProduto, nVlrItem, cSerie}
