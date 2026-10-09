#INCLUDE "TOTVS.ch"

/*/{Protheus.doc} AGDXSB5
	Função para buscar dados de um campo da tabela de complemento de produto conforme produto 
	@type function
	@version P12.1.2410 
	@author claudineia.reinert
	@since 12/17/2024
	@param cProduto, character, Código do produto
	@param cCampo, character, campo da tabela SB5. Ex: B5_COD
	@return variant, retorna o valor do campo na tabela SB5
/*/
Function AGDXSB5( cProduto, cCampo )
	Local aSaveArea 	:= GetArea()
	Local aAreaSB5 	:= SB5->(GetArea())
	Local xRet		:= CRIAVAR(cCampo)
	Local cAliasSB5  := "SB5"

	dbSelectArea(cAliasSB5)
	(cAliasSB5)->( dbSetOrder(1) )
	If (cAliasSB5)->(DbSeek(xFilial(cAliasSB5) + cProduto))
		If FieldPos(cCampo) > 0
			xRet :=	SB5->&cCampo
		EndIF
	EndIF

	RestArea(aAreaSB5)
	RestArea( aSaveArea )

Return( xRet )

/*/{Protheus.doc} AGDHELP
	Simplifica a execucao do comando help
	@type function
	@version P12.1.2410
	@author claudineia.reinert
	@since 17/12/2024
	@param cTitulo, character, Titulo da tela de help
	@param cMensagem, character, Mensagem do problema
	@param cSolucao, character, Mensagem de solução
/*/
Function AGDHELP(cTitulo, cMensagem, cSolucao)
	Default cSolucao := nil

	iF !Empty(cSolucao)
		Help(NIL, NIL, cTitulo, NIL, cMensagem, 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolucao})
	else
		Help(NIL, NIL, cTitulo, NIL, cMensagem, 1, 0)
	EndIf

Return

/*/{Protheus.doc} AGRXNOCOPY
Função que pega todos os campos do modelo e retorna-os em array unidimensional
Usado principalmente para o método SetFldNoCopy do modelo de dados
@type function
@version P12 
@author claudineia.reinert
@since 10/10/2025
@param oModel, object, objeto do modelo de dados
@return variant, retorna um array com os campos que não devem ser copiados
/*/
Function AGDXNOCOPY( oModel )
	Local nX    		:= 1
	Local aFieldsAux	:= oModel:GetStruct():aFields
	Local aFldNoCopy	:= {}

	for nX:=1 to len( aFieldsAux ) Step 1
		aAdd(aFldNoCopy , aFieldsAux [nX , 3] )
	next

Return aFldNoCopy
