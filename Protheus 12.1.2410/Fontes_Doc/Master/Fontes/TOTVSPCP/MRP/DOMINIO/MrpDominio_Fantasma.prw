#INCLUDE 'protheus.ch'
#INCLUDE 'MRPDominio.ch'

/*/{Protheus.doc} MrpDominio_Fantasma
Regras de negócio MRP - Produtos Fantasmas

@author    lucas.franca
@since     09/05/2019
@version   1
/*/
CLASS MrpDominio_Fantasma FROM LongClassName

	DATA oDominio AS Object //instância da camada de domínio

	METHOD new(oDominio) CONSTRUCTOR
	METHOD processaFantasma(cFilAux, cProduto, cComponent, nNecComp, nPeriodo, cIDOpcCmp, aBaixaPorOP, cList, oRastrPais, cCodPai, lExplodiu, dLTReal, cCodPrPais, cRevisao, cRoteiro)

ENDCLASS

/*/{Protheus.doc} new
Método construtor

@author    lucas.franca
@since     09/05/2019
@version   1
@param 01 - oDominio, Object, objeto da camada de domínio
/*/
METHOD new(oDominio) CLASS MrpDominio_Fantasma
	::oDominio := oDominio
Return Self

/*/{Protheus.doc} processaFantasma
Faz o processamento da explosão de estrutura do produto fantasma.

@author    lucas.franca
@since     09/05/2019
@version   1
@param 01 - cFilAux   , caracter, código da filial para processamento
@param 02 - cProduto  , Caracter, Código do produto pai da estrutura
@param 03 - cComponent, Caracter, Código do componente na estrutura
@param 04 - nNecComp  , Numérico, Quantidade da necessidade do produto fantasma.
@param 05 - nPeriodo  , Numérico, Período do MRP onde existe a necessidade do produto fantasma.
@param 06 - cIDOpcCmp , caracter, ID opcional do componente
@param 07 - aBaixaPorOP, array   , array com os dados de rastreabilidade origem (Documentos Pais)
								   {{1 - Id Rastreabilidade,;
								     2 - Documento Pai,;
								     3 - Quantidade Necessidade,;
								     4 - Quantidade Estoque,;
								     5 - Quantidade Baixa Estoque,;
								     6 - Quantidade Substituição},...}
@param 08 - cList     , caracter, chave produto + chr(13) + período referente chaves da aBaixaPorOP
@param 09 - oRastrPais, objeto  , objeto Json para controle/otimização das alterações de rastreabilidade no regitro Pai durante explosão na estrutura
@param 10 - cCodPai   , caracter, Código do produto pai do fantasma em processamento
@param 11 - lExplodiu , logico  , Variável de controle utilizada para identificar se explodiu a necessidade para algum componente. Uso interno e com recursividade (explodirEstrutura).
@param 12 - dLTReal    , date   , data real de início após aplicado o leadtime, sem reajustar aos períodos do MRP
@param 13 - cCodPrPais , caracter, controle de recursividade - registra a cadeia de produtos que iniciaram a explosão de forma recursiva (fantasmas)
@param 14 - cRevisao   , caracter , revisão do produto pai do fantasma em processamento
@param 15 - cRoteiro   , caracter , roteiro do produto pai do fantasma em processamento
@return Nil
/*/
METHOD processaFantasma(cFilAux   , cProduto, cComponent, nNecComp, nPeriodo  , cIDOpcCmp, aBaixaPorOP, cList,;
                        oRastrPais, cCodPai , lExplodiu , dLTReal , cCodPrPais, cRevisao, cRoteiro) CLASS MrpDominio_Fantasma
	Local nIndex     := 0
	Local nIndQbr    := 0
	Local nPosQtd    := 0
	Local nPosSub    := 0
	Local nPosQbr    := 0
	Local nTotal     := 0
	Local nTotalX    := 0
	Local nTotOPs    := 0
	Local nPerLead   := Nil
	Local dDataLead  := Nil
	Local dLTRealFan := Nil

	Default cList   := cProduto + chr(13) + cValToChar(nPeriodo)

	//Atualiza quantidade Pai no controle de rastreabilidade
	If aBaixaPorOP != Nil
		nTotal  := Len(aBaixaPorOP)
		nPosQtd := ::oDominio:oRastreio:getPosicao("ABAIXA_POS_QTD_PAI")
		nPosSub := ::oDominio:oRastreio:getPosicao("ABAIXA_POS_QTD_SUBSTITUICAO")
		nPosQbr := ::oDominio:oRastreio:getPosicao("ABAIXA_POS_QUEBRAS_QUANTIDADE")
		For nIndex := 1 to nTotal
			nTotOPs += aBaixaPorOP[nIndex][nPosQtd] - aBaixaPorOP[nIndex][nPosSub]
		Next

		For nIndex := 1 to nTotal
			aBaixaPorOP[nIndex][nPosQtd] := (aBaixaPorOP[nIndex][nPosQtd] * nNecComp) / nTotOPs

			//Ajusta totalização das quebras
			If nPosQbr <= Len(aBaixaPorOP[nIndex]) .AND. aBaixaPorOP[nIndex][nPosQbr] != Nil
				nTotalX := Len(aBaixaPorOP[nIndex][nPosQbr])
				For nIndQbr := 1 to nTotalX
					aBaixaPorOP[nIndex][nPosQbr][nIndQbr][1] := (aBaixaPorOP[nIndex][nPosQbr][nIndQbr][1] * nNecComp) / nTotOPs
				Next
			EndIf
		Next
	EndIf

	//Calcula LeadTime
	nPerLead  := nPeriodo
	dDataLead := ::oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo)
	::oDominio:oLeadTime:aplicar(cFilAux, cComponent, cIDOpcCmp, @nPerLead , @dDataLead, /*lTransfer*/, @dLTRealFan)  //Aplica o Lead Time do produto
	dLTReal := Min(dLTReal, dLTRealFan)

	//Explode a estrutura do produto fantasma de forma recursiva.
	cCodPrPais += RTrim(cComponent) + "|"
	::oDominio:explodirEstrutura(cFilAux      ,;
	                             cComponent   ,;
								 nNecComp     ,;
								 nPerLead     ,;
								 nPeriodo     ,;
								 cCodPai      ,;
								 cIDOpcCmp    ,;
								 aBaixaPorOP  ,;
								 IIf(::oDominio:oParametros["usaRevisaoPai"]=="1", cRevisao, ""),;
								 /*cRoteiro*/ ,;
								 /*cLocal*/   ,;
								 cList        ,;
								 @oRastrPais  ,;
								 /*cVersao*/  ,;
								 @lExplodiu   ,;
								 dLTReal      ,;
								 cCodPrPais   ,;
								 /*cNivelAtu*/,;
								 cRevisao     ,;
								 cRoteiro     )

Return Nil
