#INCLUDE 'protheus.ch'
#INCLUDE 'MRPDominio.ch'

#DEFINE IND_HORA   '1'
#DEFINE IND_DIA    '2'
#DEFINE IND_SEMANA '3'
#DEFINE IND_MES    '4'
#DEFINE IND_ANO    '5'

/*/{Protheus.doc} MrpDominio_LeadTime
Regras de negocio MRP - Lead Time

@author brunno.costa
@since 25/04/2019
@version 1
/*/
CLASS MrpDominio_LeadTime FROM LongClassName

	DATA oDominio  AS OBJECT

	METHOD new() CONSTRUCTOR
	METHOD aplicar(cFilAux, cProduto, cIdOpc, nPeriodo, dLeadTime, lTransfer, dLTReal)
	METHOD calcLeadTime(cFilAux, aRetPrazo, dLeadTime, lError)
	METHOD buscaUtilAnterior(cFilAux, dData)

ENDCLASS

/*/{Protheus.doc} new
Metodo construtor

@author brunno.costa
@since 25/04/2019
@version 1
@param oDominio, numero, objeto da camada de dominio
/*/
METHOD new(oDominio) CLASS MrpDominio_LeadTime
	Self:oDominio  := oDominio
Return Self

/*/{Protheus.doc} aplicar
Aplica o lead time do produto

@author marcelo.neumann
@since 07/06/2019
@version 1
@param 01 cFilAux  , caracter, código da filial
@param 02 cProduto , caracter, produto para aplicar o lead time
@param 03 cIdOpc   , caracter, id opcional do produto
@param 04 nPeriodo , numero  , periodo atual do produto - retornado por referencia
@param 05 dLeadTime, data    , data atual do produto - retornado por referencia considerando calendário
@param 06 lTransfer, lógico  , indica se calcula lead time de transferência.
@param 07 dLTReal  , data    , retorna por referência a data real após aplicar o leadtime, sem considerar o ajuste para o primeiro período (quando necessário).
@return   lReturn  , logico  , indica se houve erro na aplicação do lead time
/*/
METHOD aplicar(cFilAux, cProduto, cIdOpc, nPeriodo, dLeadTime, lTransfer, dLTReal) CLASS MrpDominio_LeadTime
	Local aRetPrazo  := {}
	Local cChaveLog  := ""
	Local cChaveProd := ""
	Local cCmpPrazo  := "PRD_PE"
	Local lError     := .F.
	Local lLogAtivo  := ::oDominio:oDados:oLogs:logAtivado()
	Local lReturn    := .T.
	Default cIdOpc    := ""
	Default lTransfer := .F.

	cChaveProd := cFilAux + cProduto + IIf(Empty(cIDOpc), "","|" + cIDOpc)

	If lTransfer
		cCmpPrazo := "PRD_LTTRAN"
	EndIf

	dLTReal := dLeadTime

	//Busca o Prazo de Entrega e o Tipo para calcular o lead time
	aRetPrazo := ::oDominio:oDados:retornaCampo("PRD", 1, cChaveProd, {cCmpPrazo, "PRD_TIPE"}, @lError, , , , , , .T. /*lVarios*/)

	If lError
		Return .F.
	EndIf

	//Se não foi informado o Prazo do produto, não calcula
	If aRetPrazo[1] == NIL .Or. aRetPrazo[1] == 0
		Return .T.
	EndIf

	//Transforma o prazo em dias
	If aRetPrazo[2] == IND_MES
		aRetPrazo[1] *= 30

	ElseIf aRetPrazo[2] == IND_SEMANA
		aRetPrazo[1] *= 7

	ElseIf aRetPrazo[2] == IND_ANO
		aRetPrazo[1] *= 365
	EndIf

	::calcLeadTime(cFilAux, aRetPrazo, @dLeadTime, @lError)

	If lError
		lReturn  := .F.
		nPeriodo := 0
	Else
		If lLogAtivo
			cChaveLog := ::oDominio:oDados:oLogs:montaChaveLog(cFilAux, cProduto, cIdOpc, nPeriodo)
			::oDominio:oDados:oLogs:gravaLog("calculo", cChaveLog, {"Produto com leadtime de " + IIf(lTransfer, "transferencia", "producao") + " (antecipacao de " + cValToChar(aRetPrazo[1]) + " dias)", ;
			                                                        "Data de inicio alterada de " + DToC(::oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo)) + " para " + DToC(dLeadTime)}, .F. /*lWrite*/)
		EndIf

		nPeriodo := ::oDominio:oPeriodos:buscaPeriodoDaData(cFilAux, dLeadTime)
		dLTReal := dLeadTime
	EndIf

	//Caso chegue à uma data que não está dentro do período de processamento, usa o primeiro período
	If nPeriodo <= 0
		nPeriodo := 1

		If lLogAtivo
			cChaveLog := ::oDominio:oDados:oLogs:montaChaveLog(cFilAux, cProduto, cIdOpc, nPeriodo)
			::oDominio:oDados:oLogs:gravaLog("calculo", cChaveLog, {"A aplicacao do leadtime resultou em um periodo anterior ao processamento. Sera considerado o primeiro periodo (" + DToC(::oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo)) + ")"}, .F. /*lWrite*/)
		EndIf
	EndIf

	dLeadTime := ::oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo)

Return lReturn

/*/{Protheus.doc} calcLeadTime
Calcula o lead time do produto

@author douglas.heydt
@since 19/08/2019
@version 1
@param 01 cFilAux  , caracter, código da filial
@param 02 aRetPrazo, array   , Array contendo o lead time do produto, e em que medida está expresso
@param 03 dLeadTime, data    , data atual do produto, retornado por referencia considerando calendário
@param 04 lError   , logico  , informa a ocorrência de erros no processo
/*/
METHOD calcLeadTime(cFilAux, aRetPrazo, dLeadTime, lError) CLASS MrpDominio_LeadTime
	Local cHoraDia
	Local dPrimData := Nil
	Local nPosPeri
	Local nSub
	Local nSaldoMinu
	Local nIndex
	Local nMinutDia
	Local nCont    := 1
	Local oDominio := Self:oDominio

	If oDominio:oParametros["nLeadTime"] == 1 //Não considera o calendário
		If aRetPrazo[2] == IND_HORA
			If MOD(aRetPrazo[1],24) > 0
				nSub := Int(aRetPrazo[1]/24) +1
			Else
				nSub := Int(aRetPrazo[1]/24)
			EndIf
			dLeadTime   := DaySub(dLeadTime, (nSub-1)) //O dia da demanda deve ser utilizado
		Else
			dLeadTime   := DaySub(dLeadTime,aRetPrazo[1])
		EndIf

	ElseIf oDominio:oParametros["nLeadTime"] == 2 //Dias Corridos (considera calendário)

		If aRetPrazo[2] == IND_HORA
			nSaldoMinu := Hrs2Min(cValToChar(aRetPrazo[1])+":00")
			nPosPeri := oDominio:oPeriodos:buscaPeriodoDaData(cFilAux, dLeadTime)

			For nIndex := nPosPeri To 1 Step -1
				cHoraDia := oDominio:oDados:retornaCampo("CAL", 1, cFilAux + DToS(oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nIndex)), "CAL_UTEIS", @lError)
				nMinutDia := Hrs2Min(cValToChar(cHoraDia))
				nSaldoMinu -= nMinutDia

				If nSaldoMinu <= 0
					dLeadTime := oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nIndex)
					Exit
				EndIf
			Next nIndex
		Else
			dPrimData := oDominio:oPeriodos:primeiraDataUtil(cFilAux)
			dLeadTime   := DaySub(dLeadTime, (aRetPrazo[1]))

			//Caso a data calculada seja um dia sem expediente, procura uma data possível
			dLeadTime := Self:buscaUtilAnterior(cFilAux, dLeadTime)
		EndIf

	ElseIf oDominio:oParametros["nLeadTime"] == 3 //Dias úteis (considera calendário)

		If aRetPrazo[2] == IND_HORA
			nSaldoMinu := Hrs2Min(cValToChar(aRetPrazo[1])+":00")
			nPosPeri := oDominio:oPeriodos:buscaPeriodoDaData(cFilAux, dLeadTime)

			For nIndex := nPosPeri To 1 Step -1
				cHoraDia := oDominio:oDados:retornaCampo("CAL", 1, cFilAux + DToS(oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nIndex)), "CAL_UTEIS", @lError)
				nMinutDia := Hrs2Min(cValToChar(cHoraDia))

				nSaldoMinu -= nMinutDia

				If nSaldoMinu <= 0
					dLeadTime := oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nIndex)
					Exit
				EndIf
			Next nIndex
		Else
			nPosPeri := oDominio:oPeriodos:buscaPeriodoDaData(cFilAux, dLeadTime)

			While nCont <= aRetPrazo[1]
				dLeadTime := ::buscaUtilAnterior(cFilAux, dLeadTime)
				dLeadTime--
				nCont++
			EndDo

			//Caso a data calculada seja um dia sem expediente, procura uma data possível
			dLeadTime := Self:buscaUtilAnterior(cFilAux, dLeadTime)

			nPosPeri := oDominio:oPeriodos:buscaPeriodoDaData(cFilAux, dLeadTime)

			//Se o período dessa demanda com o lead time for menor que o primeiro período útil
			//do MRP, irá utilizar sempre o primeiro período útil.
			If nPosPeri < oDominio:oPeriodos:primeiroPeriodoUtil(cFilAux)
				nPosPeri := oDominio:oPeriodos:primeiroPeriodoUtil(cFilAux)
			EndIf

			dLeadTime := oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nPosPeri)
		EndIf
	EndIf

Return

/*/{Protheus.doc} buscaUtilAnterior
Busca o primeiro dia útil exatamente anterior à data parâmetro no calendário MRP

@author douglas.heydt
@since 27/08/2019
@version 1.0
@param 01 cFilAux, caracter, código da filial
@param 02 dData  , data    , data de partida para buscar o próximo dia útil
@return dData    , data    , data do próximo dia útil de acordo com o calendário MRP
/*/
METHOD buscaUtilAnterior(cFilAux, dData) CLASS MrpDominio_LeadTime
	Local dPrimData := Self:oDominio:oPeriodos:primeiraDataUtil(cFilAux)

	If dData < dPrimData
		//A data recebida é menor que a primeira data útil do MRP.
		//Retorna a primeira data útil.
		dData := dPrimData
	Else
		//Verifica se a data possui hora de trabalho
		While !::oDominio:oPeriodos:verificaDataUtil(cFilAux, dData)
			//Se não possuir hora de trabalho, pega a data anterior.
			dData--
			If dData <= dPrimData
				//Se a data for menor que a primeira data útil do MRP, retorna a primeira data útil.
				dData := dPrimData
				Exit
			EndIf
		EndDo
	EndIf
Return dData
