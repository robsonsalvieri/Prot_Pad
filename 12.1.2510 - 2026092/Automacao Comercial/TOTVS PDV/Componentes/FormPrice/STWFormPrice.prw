#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//--------------------------------------------------------
/*/{Protheus.doc} STWFormPr
Workflow do componente formacao de preco

1o. Pesquisa o preco nas tabelas de preco DA0 e DA1
2o. Caso nao retorna o preco na primeira opcao, pesquisa o preco na SB0
3o. Por ultimo, caso nao retorne o preco em nenhuma das opcoes, pesquisa na SB1

@param   	cItemCode Codigo do item
@param		cCustomer Codigo do cliente
@param		cFil Codigo da filial
@param		cStore Codigo da loja
@param		nMoeda Moeda
@author  	Varejo
@version 	P11.8
@since   	15/05/2012
@return  	nRet - Preco
@obs     
@sample
/*/
//--------------------------------------------------------
Function STWFormPr( cItemCode, cCustomer, cFil, cStore,	nMoeda, nQtde	)

Local nRet 		:= 0	//Retorno do preco
Local lFinServ	:= AliasIndic("MG8") .AND. SuperGetMV("MV_LJCSF",,.F.)	// Define se habilita o controle de servicos financeiros
Local lCenVen		:= SuperGetMv("MV_LJCNVDA",,.F.)							//Cenario de vendas
Local aAreaSB1	:= SB1->(GetArea())												// Guarda area atual do SB1  

Default cItemCode 	:= ""
Default cCustomer 	:= "" 
Default cFil	  		:= ""
Default cStore		:= ""
Default nMoeda		:= 0
Default nQtde			:= 1

ParamType 0 Var cItemCode 	As Character 	Default ""
ParamType 1 Var cCustomer  As Character 	Default ""
ParamType 2 Var cFil			As Character 	Default ""
ParamType 3 Var cStore		As Character 	Default ""
ParamType 4 Var nMoeda		As Numeric 	Default 0
ParamType 5 Var nQtde		As Numeric		Default 1


cItemCode := PadR(cItemCode,TamSx3("B1_COD")[1])

If STBGetPric() == 0
	
	/* Tratamento Servico Financeiro */
	If lFinServ
		//Verifica se produto serviço é com Vinculado. Se for fixo, seu preço será do processo normal ( DA0-DA1 / SB0 / SB1 ).
		nRet := STWServPrice( cItemCode, cFil )
	EndIf
	
	If nRet == 0
		If lCenVen
			nRet := STBValTbPr( 	cItemCode, cCustomer, cFil, cStore,nMoeda, nQtde )
		EndIf							
	
		If nRet == 0
	
			nRet := STDValPrDf( cItemCode )	
		
			If nRet == 0		
				nRet := STDPrecoB1( cItemCode )
			EndIf 
		EndIf
	EndIf
Else
	nRet := STBGetPric() 	
	STBSetPric(0)
EndIf

If nRet <> -999
	//Faz arredondamento do preço
	nRet := STBRound(nRet) //Padrao de decimais "MV_CENT"+ Moeda corrente
EndIf

RestArea(aAreaSB1)

Return nRet

