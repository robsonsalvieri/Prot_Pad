#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STWBONUSSALES.CH"   
//-------------------------------------------------------------------
/*{Protheus.doc} STBBonusSales
Executa as rotinas de Cenário de Vendas
@param   oProdModel 		Objeto Model	
@author  	Varejo
@version 	P11.8
@since   	23/07/2012
@return  lBonifica - .T. se foi executada sem erros / .F. Se houve falha em algum processo
@obs     	
@sample
*/
//-------------------------------------------------------------------
Function STWBonusSales( nItemLine )

Local aArea 		:= GetArea()                                            // Guarda a area corrente
Local oCliModel     := STDGCliModel()                                       // Model com as informacoes do cliente
Local lBonifica		:= .F.                                                  // Indica se a regra de bonificacao sera aplicada
Local cCodigo 		:= STDGPBasket( "SL2" , "L2_PRODUTO" , nItemLine )      // Codigo do produto que esta sendo lancado
Local cTesBonus 	:= ""                                                   // TES da bonificacao
Local cRegraBon		:= ""                                                   // Codigo da regra de bonificacao
Local cBonusTd		:= ""                                                   // Indica se sera utilizada mais de uma regra de bonificacao.
Local cProdBon		:= ""                                                   // Codigo do produto bonificado.
Local cTypeDesc		:= "V"                                                  // Tipo de desconto (percentual)
Local lAddItem		:= .T.                                                  // Passado para o ItemReg. Indica que o item a ser registrado eh um item adicional.
Local aRegras       := STDBSFilter( nItemLine )                             // Array com as regras de bonificacao que o item lancado faz parte
Local nX            := 0                                                    // Contador do For
Local nItens        := 0                                                    // Numero de itens que serao bonificados
Local nValDesc      := 0                                                    // Valor do desconto ( deixará o produto bonificado com o valor de R$0,01 )
Local nPrice 		:= 0                                                    // Preco do produto bonificado
Local nQuant        := 0                                                    // Quantidade que sera lancada do produto bonificado
Local nResto        := 0.01                                                 // Resto que sobrara como valor do produto bonificado

For nX := 1 To Len(aRegras)

	DbSeek(aRegras[nX])
	
	cProdBon 	:= ""
	
	cBonusTd 	:= SuperGetMv( "MV_BONUSTD",.F.,"2" )
	cTesBonus	:= SuperGetMv( "MV_BONUSTS" )
	
	cRegraBon 	:= ACR->ACR_CODREG
	
	// verifica se a regra sera contemplada.
	lBonifica	:= STBBonusSales( cRegraBon, cTesBonus, cCodigo )
	
	If lBonifica 	
		
		nItens++
		cProdBon := STDBonusProduto( cRegraBon ) // Funcao que retorna o codigo do produto que sera bonificado
		
		If !Empty(cProdBon)
		
			nQuant := STDSetBonusQuantidade( cRegraBon ) // Funcao que seta a quantidade que sera bonificada.									
				 
			nPrice := STWFormPr( 	cProdBon	, oCliModel:GetValue("SA1MASTER","A1_COD")	, Nil 	, oCliModel:GetValue("SA1MASTER","A1_LOJA")	,;
									STBGetCurrency()					       )
								
			nValDesc := (nPrice*nQuant) - nResto	// Calcula o valor do item bonificado para sobrar o valor de 1 centavo				
									
			STBSetItDiscount( nValDesc , cTypeDesc )
			If !STWItemReg( nItemLine+nItens, cProdBon,Nil,Nil,STBGetCurrency(),nValDesc,cTypeDesc,lAddItem,cTesBonus,,,,"BON" )
				// Havendo falha no registro do item, gera nova mensagem e aborta a emissão dos demais
				STFMessage("STBKitSales", "STOP", STR0001) // "Não foi possível registrar os itens que compoem o kit."
				Exit
			Else
				STWTotDisc( nResto , "V" , "" , .T. )
				STDSPBasket( "SL2" , "L2_BONIFICADOR" , .T. , nItemLine )
			EndIf
			
		EndIf
		
		// Caso o conteudo do parametro MV_BONUSTD seja 2 nao sera processada mais nenhuma regra
		If cBonusTd == "2"
			Exit
		EndIf
	
	EndIf	
			
Next nX

RestArea(aArea)

Return lBonifica

