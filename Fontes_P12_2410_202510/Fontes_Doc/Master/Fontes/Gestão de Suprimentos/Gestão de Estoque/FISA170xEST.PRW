#INCLUDE "protheus.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA170EST
Função que cria tree da regra de custo no configurador de tributos.
Esta função é chamada através da funcao MONTRATREE() do fonte FISA170.PRW

@type Function

@param   aNodes   	,array	   ,array com nós e item que vai compor o tree, passado por referencia
@param   cTreeNivel	,character	,Nivel do tree do objeto DbTree
@param   cPosTree		,character	,Posição no do tree do objeto DbTree
@param   aImageTree	,array	   ,array com 2 posicoes, onde a aImageTree[1] nome da imagem do tree estiver aberto e a aImageTree[2] nome da imagem do tree estiver fechado
@param   aImageItem	,array	   ,array com 2 posicoes, onde a aImageItem[1] nome da imagem do item estiver aberto e a aImageItem[2] nome da imagem do item estiver fechado

@param sempre .T., logico

@author reynaldo
@since 28/08/2024
@version 12.1.2410

/*/
//-------------------------------------------------------------------
Function FISA170EST(aNodes as array, cTreeNivel as character, cPosTree as character, aImageTree as array, aImageItem as array)

	aadd(aNodes, {cTreeNivel,        cPosTree,        "", "Regras Estoque/Custos", aImageTree[1], aImageTree[2]})
	aadd(aNodes, {soma1(cTreeNivel), soma1(cPosTree), "", "Regra de Custo",        aImageItem[1], aImageItem[2]})

Return .T.
