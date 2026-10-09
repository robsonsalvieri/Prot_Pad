#INCLUDE "PROTHEUS.CH"

Static __aBestFit := {} As Array
Static __nBFSobra := 0  As Numeric
Static __nBFQtLot := 0  As Numeric
Static __nBFDtKey := "" As Character
Static __aPrep    := {} As Array

//------------------------------------------------------------------
/*/{Protheus.doc} E016TEscoa
Determina os critérios de escoamento de lote

@type   Function
@author cruz.rafael / Squad Retail
@since  11/03/2026
@param  cProduto , character, Produto de referência
@return cDescr   , character, Descrição do tipo de Escoamento
/*/
//------------------------------------------------------------------
Function E016TEscoa(cProduto)
	Local cTpEsc   as Character
	Local cDescr   as Character
	Local aArea    as Array
	Local aAreaD4Z as Array

	Default cProduto := ""

	cDescr := ""

	If FwAliasInDic("D4Z") .And. !Empty(cProduto)

		aArea    := FwGetArea()
		aAreaD4Z := D4Z->(FwGetArea())

		dbSelectArea("D4Z")
		D4Z->(dbSetOrder(1))

		If D4Z->(MsSeek(FWxFilial("D4Z") + cProduto))
			cTpEsc := RetFldProd(cProduto, "D4Z_ESLOTE", "D4Z")

			Do Case
				Case cTpEsc == "1"
					cDescr := "FEFO" // Escoamento por Dt. Validade da menor data de vencimento para a maior
				Case cTpEsc == "2"
					cDescr := "FIFO" // Escoamento por Dt. Entrada da menor data de entrada para a maior
				Case cTpEsc == "3"
					cDescr := "BESTFIT" // Escoamento por enquadramento do saldo com a quantidade
			EndCase
		EndIf

		FwRestArea(aAreaD4Z)
		FwRestArea(aArea)
	EndIf

Return cDescr

//------------------------------------------------------------------
/*/{Protheus.doc} E016QrySB8
Determina os critérios de escoamento de lote

@type   Function
@author cruz.rafael / Squad Retail
@since  11/03/2026
@param  cAliasSB8 , character, Alias da query da SB8
@param  cCodPro   , character, Produto de referência
@param  nQtd      , numeric  , Quantidade requerida
@param  lBaixaEmp , logical  , Baixar empenhos
@param  lConsVenc , logical  , Considerar vencimento
@param  lEmpPrev  , logical  , Considerar empenhos previstos
@param  dDataRef  , date     , Data de referência
@param  lSaldo    , logical  , Considerar saldo
@param  lMVPerdInf, logical  , Considerar movimentação perdida
@param  cOP       , character, Operação
@param  nPercPrM  , numeric  , Percentual de prejuizo
@param  nQtdeOri  , numeric  , Quantidade original
@param  l650      , logical  , Considerar 650
@param  l650Auto  , logical  , Considerar 650 automatico
@param  cBaseQuery, character, Base da query
@param  cBFOrderBy, character, Ordenação da query
@param  aSetPorLot, array    , Campos da query
@param  aBindParam, array    , Parâmetros da query
@return cAliasSB8 , character, Alias da query da SB8
/*/
//------------------------------------------------------------------
Function E016QrySB8(cAliasSB8, cCodPro, nQtd, lBaixaEmp, lConsVenc, lEmpPrev, dDataRef, lSaldo, lMVPerdInf, cOP, nPercPrM, nQtdeOri, l650, l650Auto, cBaseQuery, cBFOrderBy, aSetPorLot, aBindParam)
	Local aBFPlan as Array
	Local cQuery  as Character
	Local cOrder  as Character
	Local nQry    as Numeric
	Local oQrySB8 as Object

	Default cAliasSB8  := ""
	Default cCodPro    := ""
	Default nQtd       := 0
	Default lBaixaEmp  := .F.
	Default lConsVenc  := .F.
	Default lEmpPrev   := .F.
	Default dDataRef   := Nil
	Default lSaldo     := .F.
	Default lMVPerdInf := .F.
	Default cOP        := ""
	Default nPercPrM   := 0
	Default nQtdeOri   := 0
	Default l650       := .F.
	Default l650Auto   := .F.
	Default cBaseQuery := ""
	Default cBFOrderBy := ""
	Default aSetPorLot := {}
	Default aBindParam := {}

	aBFPlan := E016BFPlan(cAliasSB8, cCodPro, nQtd, lBaixaEmp, lConsVenc, lEmpPrev, dDataRef, lSaldo, lMVPerdInf, cOP, nPercPrM, nQtdeOri, l650, l650Auto)

	If Len(aBFPlan) > 0
		(cAliasSB8)->(dbCloseArea())
		cOrder := E016BFOrd(aBFPlan, cBFOrderBy)
		cQuery := (cBaseQuery + cOrder)

		// Define um identificador para a query
		oQrySB8 := E016GetQry(cQuery)

		oQrySB8:setFields( aSetPorLot )

		For nQry := 1 To Len(aBindParam)
			oQrySB8:setString(nQry, aBindParam[nQry])
		Next nQry

		cAliasSB8 := oQrySB8:openAlias(cAliasSB8)
		oQrySB8:doTcSetField(cAliasSB8)
		dbSelectArea(cAliasSB8)
	EndIf

Return cAliasSB8

//------------------------------------------------------------------
/*/{Protheus.doc} E016GetQry
Obtém o objeto (FwExecStatement) de query preparada para a expressão SQL informada.

@type   Static function
@author cruz.rafael / Squad Retail
@since  17/03/2026
@param  cQuery, Character, Expressão SQL
@return oPrepared, Object, Objeto de query preparada
/*/
//------------------------------------------------------------------
Static Function E016GetQry(cQuery)
	Local oPrepared as Object
	Local nPosPrep  as Numeric
	Local cMD5      as Character
	
	Default cQuery := ""

	cMD5 := MD5(cQuery)
	If (nPosPrep := Ascan(__aPrep,{|x| x[2] == cMD5})) == 0
		cQuery := ChangeQuery(cQuery)
		Aadd(__aPrep,{FwExecStatement():New(cQuery), cMD5})
		nPosPrep := Len(__aPrep)
	Endif

	oPrepared := __aPrep[nPosPrep][1]

Return oPrepared


//------------------------------------------------------------------
/*/{Protheus.doc} E016BFPlan
Monta o plano Best Fit de lotes com base no saldo disponível do SB8

@type   Static Function
@author cruz.rafael / Squad Retail
@since  17/03/2026
@param  cAliasSB8 , character, Alias da query da SB8
@param  cProduto  , character, Produto de referência
@param  nQtd      , numeric  , Quantidade requerida
@param  lBaixaEmp , logical  , Baixar empenhos
@param  lConsVenc , logical  , Considerar vencimento
@param  lEmpPrev  , logical  , Considerar empenhos previstos
@param  dDataRef  , date     , Data de referência
@param  lSaldo    , logical  , Considerar saldo
@param  lMVPerdInf, logical  , Considerar movimentação perdida
@param  cOP       , character, Operação
@param  nPercPrM  , numeric  , Percentual de prejuizo
@param  nQtdeOri  , numeric  , Quantidade original
@param  l650      , logical  , Considerar 650
@param  l650Auto  , logical  , Considerar 650 automatico
@return aPlano    , array    , Recnos do SB8 ordenados conforme Best Fit
/*/
//------------------------------------------------------------------
Static Function E016BFPlan(cAliasSB8, cProduto, nQtd, lBaixaEmp, lConsVenc, lEmpPrev, dDataRef, lSaldo, lMVPerdInf, cOP, nPercPrM, nQtdeOri, l650, l650Auto)
	Local aLotesOK  as Array
	Local aPlano    as Array
	Local cFilSB8   as Character
	Local lLocalCQ  as Logical
	Local nRecSB8   as Numeric
	Local nSaldoSB8 as Numeric

	Default cAliasSB8  := ""
	Default cProduto   := ""
	Default nQtd       := 0
	Default lBaixaEmp  := .F.
	Default lConsVenc  := .F.
	Default lEmpPrev   := .F.
	Default dDataRef   := Nil
	Default lSaldo     := .F.
	Default lMVPerdInf := .F.
	Default cOP        := Nil
	Default nPercPrM   := 0
	Default nQtdeOri   := 0
	Default l650       := .F.
	Default l650Auto   := .F.

	aLotesOK  := {}
	aPlano    := {}
	cFilSB8   := xFilial("SB8")

	If !Empty(cAliasSB8) .OR. QtdComp(nQtd, .T.) > 0
		While (cAliasSB8)->(!Eof()) .And. cFilSB8 == (cAliasSB8)->B8_FILIAL .And. cProduto == (cAliasSB8)->B8_PRODUTO
			nRecSB8   := (cAliasSB8)->SB8RECNO
			lLocalCQ  := (l650 .Or. l650Auto) .And. AlmoxCq() == (cAliasSB8)->B8_LOCAL
			nSaldoSB8 := SB8Saldo(lBaixaEmp, lConsVenc, NIL, NIL, cAliasSB8, lEmpPrev, NIL, dDataRef, lSaldo, IIf(lMVPerdInf, cOP, Nil), nPercPrM, nQtdeOri)

			If QtdComp(nSaldoSB8,.T.) > 0 .And. If(ValType(dDataRef) == "D",(cAliasSB8)->B8_DATA <= dDataRef, .T.) .And. !lLocalCQ
				aAdd(aLotesOK, {nRecSB8, nSaldoSB8, (cAliasSB8)->B8_DATA, (cAliasSB8)->B8_DTVALID})
			EndIf

			While (cAliasSB8)->(!Eof()) .And. (cAliasSB8)->SB8RECNO == nRecSB8 // JBM - Precisa desse while dentro do outro? A query vai retornar o mesmo recno mais de uma vez?
				(cAliasSB8)->(dbSkip())
			EndDo
		EndDo

		aPlano := E016Order(aLotesOK, nQtd)
	EndIf

Return aPlano

//------------------------------------------------------------------
/*/{Protheus.doc} E016Order
Calcula a ordem ideal de consumo dos lotes para o critério Best Fit

@type   Static function
@author cruz.rafael / Squad Retail
@since  17/03/2026
@param  aLotesOK, array  , Candidatos de lote
@param  nQtd    , numeric, Quantidade requerida
@return aPlano  , array  , Recnos do SB8 na ordem de consumo
/*/
//------------------------------------------------------------------
Static Function E016Order(aLotesOK, nQtd)
	Local aPlano as Array
	Local aUnico as Array
	Local aCombo as Array
	Local lCont  as Logical
	Local nX     as Numeric

	Default aLotesOK := {}
	Default nQtd     := 0

	aPlano := {}
	nX     := 0
	lCont  := .T.

	If !Empty(aLotesOK) .OR. QtdComp(nQtd,.T.) > 0
		aUnico := E016BFUni(aLotesOK, nQtd) // Primeiro tenta encontrar um lote único que atenda a quantidade requerida
		If Len(aUnico) > 0
			aAdd(aPlano, aUnico[1])
			lCont := .F.
		EndIf
	
		If lCont
			aCombo := E016BFCmb(aLotesOK, nQtd) // Caso não encontre um lote único, busca pela melhor combinação de lotes
			If Len(aCombo) > 0
				aSort(aCombo,,, {|x,y| IIf(x[2] == y[2], IIf(x[3] == y[3], x[1] < y[1], x[3] < y[3]), x[2] > y[2])})
				For nX := 1 To Len(aCombo)
					aAdd(aPlano, aCombo[nX][1])
				Next nX
			EndIf
		EndIf
	EndIf

Return aPlano

//------------------------------------------------------------------
/*/{Protheus.doc} E016BFUni
Seleciona o melhor lote único para atendimento integral do pedido

@type   Static function
@author cruz.rafael / Squad Retail
@since  17/03/2026
@param  aLotesOK, array  , Candidatos de lote
@param  nQtd    , numeric, Quantidade requerida
@return aBest   , array  , Lote selecionado
/*/
//------------------------------------------------------------------
Static Function E016BFUni(aLotesOK, nQtd)
	Local aBest    as Array
	Local nBestDif as Numeric
	Local nDif     as Numeric
	Local nX       as Numeric

	Default aLotesOK := {}
	Default nQtd     := 0

	aBest    := {}
	nBestDif := 0
	nDif     := 0
	nX       := 0

	For nX := 1 To Len(aLotesOK)
		If QtdComp(aLotesOK[nX][2] - nQtd, .T.) >= 0
			nDif := aLotesOK[nX][2] - nQtd
			If Empty(aBest) .Or. nDif < nBestDif .Or. ;
				(nDif == nBestDif .And. aLotesOK[nX][3] < aBest[3]) .Or. ;
				(nDif == nBestDif .And. aLotesOK[nX][3] == aBest[3] .And. aLotesOK[nX][1] < aBest[1])
				aBest    := aClone(aLotesOK[nX])
				nBestDif := nDif
			EndIf
		EndIf
	Next nX

Return aBest

//------------------------------------------------------------------
/*/{Protheus.doc} E016BFCmb
Seleciona a melhor combinação de lotes para o critério Best Fit

@type   Static function
@author cruz.rafael / Squad Retail
@since  17/03/2026
@param  aLotesOK, array, Candidatos de lote
@param  nQtd, numeric, Quantidade requerida
@return array, Combinação selecionada
/*/
//------------------------------------------------------------------
Static Function E016BFCmb(aLotesOK, nQtd)
	Local aWork   as Array
	Local aAtual  as Array
	Local aSufixo as Array
	Local nX      as Numeric

	Default aLotesOK := {}
	Default nQtd     := 0

	__aBestFit := {}
	__nBFSobra := -1
	__nBFQtLot := 0
	__nBFDtKey := ""

	aWork   := {}
	aAtual  := {}
	aSufixo := {}
	nX      := 0
	
	For nX := 1 To Len(aLotesOK)
		If QtdComp(aLotesOK[nX][2] - nQtd,.T.) < 0
			aAdd(aWork, aClone(aLotesOK[nX]))
		EndIf
	Next nX

	If !Empty(aWork)
		aSort(aWork,,, {|x,y| IIf(x[2] == y[2], IIf(x[3] == y[3], x[1] < y[1], x[3] < y[3]), x[2] > y[2])})
		aSufixo := Array(Len(aWork) + 1)
		aSufixo[Len(aWork) + 1] := 0
		For nX := Len(aWork) To 1 Step -1
			aSufixo[nX] := aSufixo[nX + 1] + aWork[nX][2]
		Next nX
	EndIf
	
	E016BscLot(aWork, 1, nQtd, 0, aAtual, aSufixo)

Return __aBestFit

//------------------------------------------------------------------
/*/{Protheus.doc} E016BscLot
Busca recursivamente a melhor combinação de lotes para Best Fit

@type   Static function
@author cruz.rafael / Squad Retail
@since  17/03/2026
@param  aLotesOK, array  , Candidatos elegíveis
@param  nPos    , numeric, Posição atual
@param  nQtd    , numeric, Quantidade requerida
@param  nSoma   , numeric, Soma corrente
@param  aAtual  , array  , Combinação corrente
@param  aSufixo , array  , Soma restante por posição
@return nil
/*/
//------------------------------------------------------------------
Static Function E016BscLot(aLotesOK, nPos, nQtd, nSoma, aAtual, aSufixo)
	Local cAtualKey as Character
	Local lCont     as Logical
	Local nSobra    as Numeric
	Local nTamAtual as Numeric

	cAtualKey := ""
	lCont     := .T.
	nSobra    := 0
	nTamAtual := Len(aAtual)

	If QtdComp(nSoma - nQtd, .T.) >= 0
		nSobra := nSoma - nQtd
		cAtualKey := E016DtKey(aAtual)

		If __nBFSobra < 0 .Or. ;
			nSobra < __nBFSobra .Or. ;
			(nSobra == __nBFSobra .And. nTamAtual < __nBFQtLot) .Or. ;
			(nSobra == __nBFSobra .And. nTamAtual == __nBFQtLot .And. cAtualKey < __nBFDtKey)
			__aBestFit := {}
			AEval(aAtual, {|x| aAdd(__aBestFit, aClone(x))})
			__nBFSobra := nSobra
			__nBFQtLot := nTamAtual
			__nBFDtKey := cAtualKey
		EndIf
	EndIf

	If nPos > Len(aLotesOK)
		lCont := .F.
	EndIf

	If lCont
		If QtdComp((nSoma + aSufixo[nPos]) - nQtd,.T.) < 0
			If __nBFSobra == 0 .And. Len(aAtual) >= __nBFQtLot .And. __nBFQtLot > 0
				lCont := .F.
			EndIf
		EndIf
	EndIf

	If lCont
		aAdd(aAtual, aClone(aLotesOK[nPos]))
		E016BscLot(aLotesOK, nPos + 1, nQtd, nSoma + aLotesOK[nPos][2], aAtual, aSufixo)
		aSize(aAtual, Len(aAtual) - 1)

		E016BscLot(aLotesOK, nPos + 1, nQtd, nSoma, aAtual, aSufixo)
	EndIf

Return Nil

//------------------------------------------------------------------
/*/{Protheus.doc} E016DtKey
Gera chave de desempate por data de entrada para combinação Best Fit

@type   Static function
@author cruz.rafael / Squad Retail
@since  17/03/2026
@param  aCombo, array    , Combinação avaliada
@return cKey  , character, Chave de ordenação por data
/*/
//------------------------------------------------------------------
Static Function E016DtKey(aCombo)
	Local aOrd as Array
	Local cKey as Character
	Local nX   as Numeric

	Default aCombo := {}

	aOrd  := {}
	cKey  := ""
	nX    := 0

	AEval(aCombo, {|x| aAdd(aOrd, aClone(x))})
	aSort(aOrd,,, {|x,y| IIf(x[3] == y[3], x[1] < y[1], x[3] < y[3])})

	For nX := 1 To Len(aOrd)
		cKey += DToS(aOrd[nX][3]) + StrZero(aOrd[nX][1],10)
	Next nX

Return cKey

//------------------------------------------------------------------
/*/{Protheus.doc} E016BFOrd
Monta a cláusula ORDER BY para priorizar os lotes escolhidos no Best Fit

@type   Static function
@author cruz.rafael / Squad Retail
@since  17/03/2026
@param  aPlano  , array, Recnos do SB8 priorizados
@param  cOrdBase, character, Ordenação base complementar
@return cOrder  , character, Cláusula ORDER BY
/*/
//------------------------------------------------------------------
Static Function E016BFOrd(aPlano, cOrdBase)
	Local cOrder as Character
	Local nX     as Numeric

	Default aPlano   := {}
	Default cOrdBase := ""

	cOrder := "ORDER BY CASE SB8.R_E_C_N_O_"
	nX     := 0

	For nX := 1 To Len(aPlano)
		cOrder += " WHEN " + AllTrim(Str(aPlano[nX])) + " THEN " + AllTrim(Str(nX))
	Next nX

	cOrder += " ELSE 999999 END"
	If !Empty(cOrdBase)
		cOrder += "," + cOrdBase
	EndIf

Return cOrder
