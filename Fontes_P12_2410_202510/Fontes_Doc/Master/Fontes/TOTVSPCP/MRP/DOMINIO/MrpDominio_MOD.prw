#INCLUDE 'protheus.ch'
#INCLUDE 'MrpDominio.ch'

/*/{Protheus.doc} MrpDominio_MOD
Processamento de Produtos MOD
@author    brunno.costa
@since     25/04/2019
@version   1
/*/
CLASS MrpDominio_MOD FROM LongClassName
	METHOD new() CONSTRUCTOR
	METHOD campoCCustoNoDicionario()
	METHOD converteQuantidadeMOD(nG1Quant, nNecessPai, lQtdFixa, oParametros)
	METHOD produtoMOD(cFilAux, cProduto, oDados)
	METHOD retornaCondicaoProdutoMOD(aFields, oParametros)
ENDCLASS

/*/{Protheus.doc} new
Metodo construtor
@author    brunno.costa
@since     28/07/2020
@version   1
Return Self, objeto, instancia desta classe
/*/
METHOD new() CLASS MrpDominio_MOD
Return Self

/*/{Protheus.doc} retornaCondicaoProdutoMOD
Retorna a condição de produto MOD para SQL (CargaMemoria)
@author    brunno.costa
@since     28/07/2020
@version   1
@param 01, oParametros, objeto  , instancia do objeto Json de parametros
@param 02, cQuery     , caracter, query a ser adicionados os campos referentes a MOD (referência)
/*/
METHOD retornaCondicaoProdutoMOD(oParametros, cQuery) CLASS MrpDominio_MOD
	Local cBanco  := Upper(TcGetDb())
	Local cSubstr := IIf("MSSQL" $ cBanco, "SUBSTRING", "SUBSTR")

	cQuery += " CASE " + cSubstr + "(HWA.HWA_PROD, 1, 3) WHEN 'MOD' THEN" + ;
	            " 'T'"                                                    + ;
	          " ELSE"

	If oParametros["lUsesLaborProduct"] .AND. Self:campoCCustoNoDicionario()
		cQuery += " CASE HWA.HWA_CCUSTO WHEN ' ' THEN" + ;
		             " 'F'"                            + ;
		          " ELSE"                              + ;
		             " 'T'"                            + ;
		          " END"
	Else
		cQuery += " 'F'"
	EndIf

	cQuery += " END HWA_MOD,"

Return

/*/{Protheus.doc} campoCCustoNoDicionario
Verifica existencia do campo HWA_CCUSTO no dicionario de dados
@author    brunno.costa
@since     28/07/2020
@version   1
Return lReturn, logico, indica se possui o campo HWA_CCUSTO no dicionario
/*/
METHOD campoCCustoNoDicionario() CLASS MrpDominio_MOD
	Local nTamanho := GetSX3Cache("HWA_CCUSTO","X3_TAMANHO")
Return nTamanho != Nil .AND. nTamanho > 0

/*/{Protheus.doc} converteQuantidadeMOD
Converte a quantidade da necessidade de produto MOD
@author    brunno.costa
@since     28/07/2020
@version   1
@param 01, nG1Quant   , numero, quantidade do produto na estrutura
@param 02, nNecessPai , numero, necessidade do produto pai
@param 03, lQtdFixa   , logico, indicador de quantidade fixa na estrutura
@param 04, oParametros, objeto, instancia do objeto Json de parametros
@return nReturn, numero, quantidade da necessidade do protudo MOD convertida
/*/
METHOD converteQuantidadeMOD(nG1Quant, nNecessPai, lQtdFixa, oParametros) CLASS MrpDominio_MOD
	Local nReturn := nG1Quant

	If oParametros["cStandardTimeUnit"] == "N"        //MV_TPHR
		nReturn := Int(nG1Quant)
		nReturn += ((nG1Quant - nReturn) / 60) * 100
	EndIf

	If !lQtdFixa
		If oParametros["cUnitOfLaborInTheBOM"] != "H" //MV_UNIDMOD
			nReturn := nNecessPai / nReturn
		Else
			nReturn := nNecessPai * nReturn
		EndIf
	EndIf
Return nReturn

/*/{Protheus.doc} produtoMOD
Indica se o produto é MOD
@author    brunno.costa
@since     28/07/2020
@version   1
@param 01 cFilAux , caracter, codigo da filial para processamento
@param 01 cProduto, caracter, codigo do produto
@param 02 oDados  , objeto  , instancia da camada de dados
@return lMOD, logico, indica se o produto é MOD
/*/
METHOD produtoMOD(cFilAux, cProduto, oDados) CLASS MrpDominio_MOD
	Local cMOD      := ""
	Local cChavePrd := cFilAux + cProduto
	Local lAtual    := cChavePrd == oDados:oProdutos:cCurrentKey
	Local lMOD      := .F.
	Local lError    := .F.

	If !lAtual
		lMOD := oDados:oProdutos:getFlag("|MOD|"+cChavePrd+"|")
		If lMOD == Nil
			lMOD := .F.
		EndIf
	Else
		cMOD := oDados:retornaCampo("PRD", 1, cChavePrd, "PRD_MOD", @lError, lAtual, , /*lProximo*/, , , .F. /*lVarios*/)
		If lError .Or. Empty(cMOD)
			lMOD := .F.
		ElseIf cMOD == "T"
			lMOD := .T.
		EndIf
	EndIf
Return lMOD

