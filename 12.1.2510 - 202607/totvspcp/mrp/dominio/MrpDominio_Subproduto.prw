#INCLUDE 'protheus.ch'
#INCLUDE 'MrpDominio.ch'

Static snPosCdCmp
Static snPosCdPai
Static snPosDTIni
Static snPosDTFim
Static snPosFixa
Static snPosQtdBP
Static snPosQtdCm
Static snPosQtdPE
Static snPosFanta

/*/{Protheus.doc} MrpDominio_Subproduto
Regras de Negocio - Processamento de Subproduto
@author    brunno.costa
@since     24/03/2020
@version   12
/*/
CLASS MrpDominio_Subproduto FROM LongClassName

	//Declaracao de propriedades da classe
	DATA oDominio  AS OBJECT   //Instancia da camada de dominio

	METHOD new() CONSTRUCTOR
	METHOD calculaNecessidadePai(nQtdComp, nQtdBPai, aItemEstru)
	METHOD geraNecessidadePai(cFilAux, cComponente, aItemEstru, nPeriodo, nQtd)
	METHOD preparaStatics()
	METHOD processar(cFilAux, cComponente, cIDOpc, nPeriodo, nQtd)
	METHOD retornaPaiValido(cFilAux, cComponente, cIDOpc, nPeriodo, nQtd)
	METHOD recursaoFantasma(cFilAux, aItemEstru, cIDOpc, nPeriodo, nQtd, lInvalido)

ENDCLASS

/*/{Protheus.doc} new
Metodo construtor
@author    brunno.costa
@since     24/03/2020
@version   12.1.30
@param 01 - oDominio, objeto, instancia da classe de domínio do MRP
@return SELF - esta classe.
/*/
METHOD new(oDominio) CLASS MrpDominio_Subproduto
	Self:oDominio := oDominio

	//Prepara Varíáveis Statics
	Self:preparaStatics()

Return Self

/*/{Protheus.doc} processar
Identifica Produto Pai válido para esta condição de subproduto
@author    brunno.costa
@since     24/03/2020
@version   12.1.30
@param 01 - cFilAux    , caracter, código da filial para processamento
@param 02 - cComponente, caracter, código do componente subproduto
@param 03 - cIDOpc     , caracter, código do IDOpcional do subproduto
@param 04 - nPeriodo   , número  , período da necessidade do subproduto
@param 05 - nQtd       , número  , quantidade da necessidade do subproduto
@return lProcessado, lógico, indica se houve execução válida de SubProduto gerando necessidade de produção de um produto Pai
/*/
METHOD processar(cFilAux, cComponente, cIDOpc, nPeriodo, nQtd) CLASS MrpDominio_Subproduto
	Local lProcessado := .F.
	Local aItemEstru  := Self:retornaPaiValido(cFilAux, cComponente, cIDOpc, nPeriodo, @nQtd)

	If Empty(aItemEstru)
		lProcessado := .F.
	Else
		lProcessado := Self:geraNecessidadePai(cFilAux, cComponente, aItemEstru, nPeriodo, nQtd)
	EndIf

Return lProcessado

/*/{Protheus.doc} retornaPaiValido
Retorna Array da Estrutura Referente Pai Válido do SubProduto
@author    brunno.costa
@since     24/03/2020
@version   12.1.30
@param 01 - cFilAux    , caracter, código da filial para processamento
@param 02 - cComponente, caracter, código do componente subproduto
@param 03 - cIDOpc     , caracter, código do IDOpcional do subproduto
@param 04 - nPeriodo   , número  , período da necessidade do subproduto
@param 05 - nQtd       , número  , quantidade da necessidade do subproduto
@return aItemEstru, array, array com os dados da estrutura referente Pai Válido do SubProduto
/*/
METHOD retornaPaiValido(cFilAux, cComponente, cIDOpc, nPeriodo, nQtd) CLASS MrpDominio_Subproduto
	Local aItemEstru := {}
	Local aPaisEstru := {}
	Local cChaveSP   := cComponente
	Local cProduto
	Local dDataNec
	Local lInvalido  := .F.
	Local nInd       := 0
	Local nTotal     := 0
	Local oSubProdutos := Self:oDominio:oDados:oSubProdutos

	If Self:oDominio:oMultiEmp:utilizaMultiEmpresa()
		cChaveSP := Self:oDominio:oMultiEmp:getFilialTabela("T4N", cFilAux) + cComponente
	EndIf

	oSubProdutos:getRow(1, cChaveSP, Nil, @aPaisEstru)
	If aPaisEstru != Nil .AND. !Empty(aPaisEstru)
		dDataNec := Self:oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo)
		nTotal   := Len(aPaisEstru)
		For nInd := 1 to nTotal
			cProduto := aPaisEstru[nInd][snPosCdPai]
			If aPaisEstru[nInd][snPosDTIni] <= dDataNec .And. ;
			   dDataNec <= aPaisEstru[nInd][snPosDTFim] .And. ;
			   Self:oDominio:oSeletivos:consideraProduto(cFilAux, cProduto)

				aItemEstru := Self:recursaoFantasma(cFilAux, aPaisEstru[nInd], cIDOpc, nPeriodo, @nQtd, @lInvalido)
				If lInvalido
					aSize(aItemEstru, 0)
				Else
					Exit
				EndIf
			EndIf
		Next
	EndIf

Return aItemEstru

/*/{Protheus.doc} recursaoFantasma
Avalia necessidade de recursão da estrutura devido ocorrência de produto Pai Fantasma.
@author    brunno.costa
@since     24/03/2020
@version   12.1.30
@param 01 - cFilAux   , caracter, filial do componente subproduto
@param 02 - aItemEstru, caracter, array com os dados da estrutura referente Pai Válido do SubProduto
@param 03 - cIDOpc    , array   , IDOpcional do subproduto
@param 04 - nPeriodo  , número  , período da necessidade do subproduto
@param 05 - nQtd      , número  , quantidade da necessidade do subproduto
@param 06 - lInvalido , lógico  , retorna por referência se o subproduto está inválido
@return aItemEstru, caracter, array com os dados da estrutura referente Pai Válido do SubProduto
/*/
METHOD recursaoFantasma(cFilAux, aItemEstru, cIDOpc, nPeriodo, nQtd, lInvalido) CLASS MrpDominio_Subproduto
	Local aItemPai  := {}
	Local aItemAvo  := {}
	Local cChaveLog := ""
	Local cFantasma := aItemEstru[snPosCdPai]
	Local nQtdPai   := Self:calculaNecessidadePai(nQtd, aItemEstru)
	Local nQtdAvo   := 0
	Local oLogs     := Self:oDominio:oDados:oLogs

	If oLogs:logAtivado()
		cChaveLog := oLogs:montaChaveLog(cFilAux, aItemEstru[snPosCdCmp], cIDOpc, nPeriodo)
		oLogs:gravaLog("calculo", cChaveLog, {"Sera produzido " + cValToChar(nQtdPai) + " do produto " + RTrim(aItemEstru[snPosCdPai]) + " para atender a necessidade de " + cValToChar(nQtd) + " do subproduto " + RTrim(aItemEstru[snPosCdCmp])}, .F. /*lWrite*/)
	EndIf

	aItemPai := Self:retornaPaiValido(cFilAux, cFantasma, /*cIDOpc*/, nPeriodo, @nQtdPai)

	If aItemPai != Nil .AND. !Empty(aItemPai) .AND. aItemPai[snPosFanta] //Produto Pai Fantasma
		nQtdAvo  := Self:calculaNecessidadePai(nQtdPai, aItemPai)
		aItemAvo := Self:retornaPaiValido(cFilAux, cFantasma, /*cIDOpc*/, nPeriodo, @nQtdAvo)
		If aItemAvo == Nil .or. Empty(aItemAvo)
			lInvalido  := .T.
		Else
			aItemEstru := aItemAvo
			nQtd       := nQtdAvo
		EndIf
	EndIf

Return aItemEstru

/*/{Protheus.doc} geraNecessidadePai
Gera necessidade do produto Pai para atender este subproduto
@author    brunno.costa
@since     24/03/2020
@version   12.1.30
@param 01 - cFilAux    , caracter, código da filial para processamento
@param 02 - cComponente, caracter, código do componente subproduto
@param 03 - aItemEstru , array   , array com os dados da estrutura referente Pai Válido do SubProduto
@param 04 - nPeriodo   , número  , período da necessidade do subproduto
@param 05 - nQtd       , número  , quantidade da necessidade do subproduto
@return lProcessado, lógico, indica se houve execução válida de SubProduto gerando necessidade de produção de um produto Pai
/*/
METHOD geraNecessidadePai(cFilAux, cComponente, aItemEstru, nPeriodo, nQtd) CLASS MrpDominio_Subproduto
	Local lProcessado := .F.
	Local cProduto    := aItemEstru[snPosCdPai]
	Local dDataNec
	Local nNecPai     := Self:calculaNecessidadePai(nQtd, aItemEstru)
	If nNecPai > 0
		dDataNec := Self:oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo)
		Self:oDominio:oRastreio:incluiNecessidade(cFilAux, "SUBPRD", cComponente, cProduto, /*cIDOpc*/, /*cTRT*/, nNecPai, nPeriodo, /*cListOrig*/, /*cRegra*/, /*cOrdSubst*/)
		Self:oDominio:oDados:atualizaMatriz(cFilAux, dDataNec, cProduto, /*cIDOpc*/, {"MAT_SAIPRE"}, {nNecPai}, cProduto)
		Self:oDominio:periodoMaxComponentes(cFilAux, cProduto, (nPeriodo - 1))
		Self:oDOminio:oDados:gravaPeriodosProd(cFilAux + cProduto, nPeriodo, -1, (nPeriodo - 1))
		lProcessado := .T.
	EndIf
Return lProcessado

/*/{Protheus.doc} calculaNecessidadePai
Calcula a quantidade da necessidade correspondente ao produto Pai
@author    brunno.costa
@since     24/03/2020
@version   12.1.30
@param 01 - nQTdComp  , número, necessidade do componente
@param 02 - aItemEstru, array , array com os dados da estrutura referente Pai Válido do SubProduto
@return nNecPai, número, quantidade de necessidade correspondente do produto Pai
/*/
METHOD calculaNecessidadePai(nQtdComp, aItemEstru) CLASS MrpDominio_Subproduto
	Local lFixa      := aItemEstru[snPosFixa] == "1"
	Local nNecPai    := nQtdComp
	Local nQtdBPai   := IIf(aItemEstru[snPosQtdBP] <= 0, 1, aItemEstru[snPosQtdBP])
	Local nQtdCmpEst := aItemEstru[snPosQtdCm]
	Local nQtdPerda  := aItemEstru[snPosQtdPE]

	nNecPai := nQtdBPai / nQtdCmpEst

	If Self:oDominio:oParametros["calculoIndicePerdaMRP"] == "1"
		nNecPai := (nNecPai * (100 - nQtdPerda)) / 100
	Else
		nNecPai := (100 * nNecPai) / (nQtdPerda + 100)
	EndIf

	nNecPai := Abs(nNecPai)

	nNecPai := nQtdComp * nNecPai

	IF lFixa
		nNecPai := Int(nNecPai) + If(((nNecPai - Int(nNecPai)) > 0), 1, 0)
	EndIf

Return nNecPai

/*/{Protheus.doc} preparaStatics
Prepara Variáveis Statics
@author    brunno.costa
@since     25/03/2020
@version   12.1.30
/*/
METHOD preparaStatics() CLASS MrpDominio_Subproduto
	If snPosDTIni == Nil
		snPosDTIni := Self:oDominio:oDados:posicaoCampo("EST_VLDINI")
		snPosDTFim := Self:oDominio:oDados:posicaoCampo("EST_VLDFIM")
		snPosQtdBP := Self:oDominio:oDados:posicaoCampo("EST_QTDB")
		snPosQtdCm := Self:oDominio:oDados:posicaoCampo("EST_QTD")
		snPosQtdPE := Self:oDominio:oDados:posicaoCampo("EST_PERDA")
		snPosCdPai := Self:oDominio:oDados:posicaoCampo("EST_CODPAI")
		snPosCdCmp := Self:oDominio:oDados:posicaoCampo("EST_CODFIL")
		snPosFixa  := Self:oDominio:oDados:posicaoCampo("EST_FIXA")
		snPosFanta := Self:oDominio:oDados:posicaoCampo("EST_FANT")
	EndIf
Return
