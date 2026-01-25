#INCLUDE 'protheus.ch'
#INCLUDE 'MRPDominio.ch'

/*/{Protheus.doc} MrpDominio_Periodos
Regras de negocio MRP - Periodos
@author    marcelo.neumann
@since     10/06/2019
@version   1
/*/
CLASS MrpDominio_Periodos FROM LongNameClass

	DATA dPrimeiraUtil AS DATE
	DATA dUltimaData   AS DATE
	DATA nPrimeiroUtil AS NUMERIC
	DATA oDominio      AS OBJECT
	DATA oDatasUteis   AS OBJECT
	DATA oJsPeriodos   AS OBJECT

	METHOD new(oDominio) CONSTRUCTOR
	METHOD criarArrayPeriodos(dData, nTipo, nPeriodos)
	METHOD cargaPeriodosJson(lRecupera)
	METHOD buscaPeriodoDaData(cFilAux, dData, lMenorIgua, nTipoPer)
	METHOD buscaProximoDiaUtil(cFilAux, dDataPar)
	METHOD buscaDataPeriodo(cFilAux, dData, nTipo, dInicio)
	METHOD montaPeriodos(cFilAux, dData, nTipo, nPeriodos)
	METHOD proximaData(cFilAux, dData, nTipo, dInicio, lUsaCalend)
	METHOD primeiroPeriodoUtil(cFilAux)
	METHOD primeiraDataUtil(cFilAux)
	METHOD retornaArrayPeriodos(cFilAux, nTipoPer)
	METHOD retornaDataPeriodo(cFilAux, nPeriodo)
	METHOD ultimaDataDoMRP()
	METHOD validaPeriodos(cFilAux)
	METHOD verificaDataUtil(cFilAux, dData, lError)

ENDCLASS

/*/{Protheus.doc} new
Metodo construtor
@author    marcelo.neumann
@since     10/06/2019
@version   1
@param 01 - oDominio, numero  , objeto da camada de dominio
/*/
METHOD new(oDominio) CLASS MrpDominio_Periodos
	::oDominio      := oDominio
	::oDatasUteis   := JsonObject():New()
	::nPrimeiroUtil := 0
	::dPrimeiraUtil := Nil
	::dUltimaData   := Nil
	::oJsPeriodos   := Nil

	Self:cargaPeriodosJson(.T.)

Return Self

/*/{Protheus.doc} criarArrayPeriodos
Gera array de periodos
@author    marcelo.neumann
@since     25/04/2019
@version 1.0
@param 01 dData    , data  , indica a data inicial
@param 02 nTipo    , numero, indica o tipo de periodo a ser utilizado
@param 03 nPeriodos, numero, indica a quantidade de periodos a ser utilizada
/*/
METHOD criarArrayPeriodos(dData, nTipo, nPeriodos) CLASS MrpDominio_Periodos
	Local aFiliais  := {}
	Local aMontaPer := {}
	Local cErro     := ""
	Local cNewErro  := ""
	Local lUsaME    := .F.
	Local nIndex    := 0
	Local nTotal    := 0
	Local oMultiEmp := ::oDominio:oMultiEmp

	Default dData     := dDataBase
	Default nTipo     := 1
	Default nPeriodos := 30

	lUsaME := oMultiEmp:utilizaMultiEmpresa()

	If lUsaME
		nTotal := oMultiEmp:totalDeFiliais()

		For nIndex := 1 To oMultiEmp:totalDeFiliais()
			aAdd(aFiliais, oMultiEmp:filialPorIndice(nIndex))
		Next nIndex
	Else
		aAdd(aFiliais, "")
	EndIf

	::oJsPeriodos := JsonObject():New()
	nTotal        := Len(aFiliais)

	For nIndex := 1 To nTotal
		aMontaPer := Self:montaPeriodos(aFiliais[nIndex], dData, nTipo, nPeriodos)

		If Empty(aMontaPer[1])
			::oJsPeriodos[aFiliais[nIndex]] := aMontaPer[2]
		Else
			cErro := aMontaPer[1]
			Exit
		EndIf

		cNewErro := Self:validaPeriodos(aFiliais[nIndex])
		If !Empty(cNewErro)
			If !Empty(cErro)
				cErro += CHR(10)
			EndIf
			If lUsaME
				cErro += STR0176 + " " + AllTrim(aFiliais[nIndex]) + " " //"Filial"
			EndIf
			cErro += cNewErro
		EndIf
	Next nIndex

	If !Empty(cErro)
		Self:oDominio:oStatus:gravaErro("memoria", cErro)
	EndIf

	//Armazena o JSON de períodos na global, para recuperar durante o cálculo.
	Self:cargaPeriodosJson(.F.)

	aSize(aFiliais, 0)
Return

/*/{Protheus.doc} montaPeriodos
Gera array de periodos para a filial específica

@author    lucas.franca
@since     28/06/2021
@version 1.0
@param 01 - cFilAux  , caracter, código da filial
@param 02 - dData    , data    , indica a data inicial
@param 03 - nTipo    , numero  , indica o tipo de periodo a ser utilizado
@param 04 - nPeriodos, numero  , indica a quantidade de periodos a ser utilizada
@return aRet, array, aRet[1] - Erro ocorrido, aRet[2] - Array coms os periodos.
/*/
METHOD montaPeriodos(cFilAux, dData, nTipo, nPeriodos) CLASS MrpDominio_Periodos
	Local aPeriodos := {}
	Local aRet      := {}
	Local cMsgErro  := ""
	Local dInicio   := dData
	Local lOk       := .T.
	Local nIndex    := 0
	Local nLenPeri  := 0

	//Calcula a primeira data a ser verificada
	If nTipo <> 1
		dData := Self:buscaDataPeriodo(cFilAux, dData, nTipo, dInicio)
	EndIf

	//Carrega os demais períodos
	For nIndex := 1 To nPeriodos
		aAdd(aPeriodos, dData)

		dData := Self:proximaData(cFilAux, dData, nTipo, dInicio)
	Next nIndex

	If ExistBlock("P712PERI")
		nLenPeri := Len(aPeriodos)

		aPeriodos := ExecBlock("P712PERI", .F., .F., aPeriodos)
		aSort(aPeriodos)

		// Verifica se o array retornado tem todos os itens do tipo date
		For nIndex := 1 to Len(aPeriodos)
			If ValType(aPeriodos[nIndex]) != "D"
				cMsgErro := STR0180 	// "O array aPeriodos retornado contem itens diferente do tipo date."
				lOk := .F.
				Exit
			EndIf
		Next

		// Verifica se o array tem mesmo tamanho do original
		If lOk .and. Len(aPeriodos) != nLenPeri
			cMsgErro := STR0181 	// "Tamanho do array aPeriodos retornado difere do tamanho original."
			lOk := .F.
		EndIf
	EndIf

	aAdd(aRet, cMsgErro)
	aAdd(aRet, aPeriodos)

Return aRet

/*/{Protheus.doc} validaPeriodos
Executa validações nos períodos

@author    lucas.franca
@since     28/06/2021
@version 1.0
@param 01 - cFilAux  , caracter, código da filial
@return cErro, Character, Mensagem de erro caso ocorra.
/*/
METHOD validaPeriodos(cFilAux) CLASS MrpDominio_Periodos
	Local cErro       := ""
	Local cUteis      := ""
	Local dData       := Nil
	Local dDtLimite   := Nil
	Local lError      := .F.
	Local lExistUtil  := .F.

	//Se utiliza o calendário, valida se todas as datas existem no calendário
	If Self:oDominio:oParametros["nLeadTime"] <> 1
		dData     := Self:retornaDataPeriodo(cFilAux, 1)
		dDtLimite := Self:ultimaDataDoMRP()

		While dData <= dDtLimite .AND. dDtLimite != Nil
			cUteis := Self:oDominio:oDados:retornaCampo("CAL", 1, cFilAux + DToS(dData), "CAL_UTEIS", @lError)

			//Retorna erro se a data não existir no calendário
			If lError
				cErro := STR0099 + DToC(dData) + STR0100 //"Data " XX/XX/XX " nao encontrada no calendario do MRP."
				Exit
			ElseIf cUteis <> "00:00"
				lExistUtil := .T.
			EndIf
			dData++
		Enddo

		If !lExistUtil .And. !lError
			cErro := STR0141 + DToC(Self:retornaDataPeriodo(cFilAux, 1)) + STR0142 + DToC(dDtLimite) + "." //"Não existe dia útil no período de processamento informado: " + XX/XX/XX + " até " + XX/XX/XX
		EndIf
	EndIf

Return cErro

/*/{Protheus.doc} cargaPeriodosJson
Verifica se os períodos já foram gerados, e carrega da memória para a thread atual.

@author lucas.franca
@since 29/06/2021
@version 1.0
@param lRecupera, Logic, Identifica se deve recuperar da memória, ou salvar na memória.
@return Nil
/*/
METHOD cargaPeriodosJson(lRecupera) CLASS MrpDominio_Periodos
	Local aNames     := {}
	Local cJsPeriodo := ""
	Local lError     := .F.
	Local nIndName   := 0
	Local nTotName   := 0
	Local nIndPer    := 0
	Local nTotPer    := 0

	If lRecupera
		//Recupera da memória, e salva na thread atual.
		cJsPeriodo := Self:oDominio:oDados:oMatriz:getFlag("PERIODOS_PROCESSAMENTO", @lError)
		If !lError .And. !Empty(cJsPeriodo)
			Self:oJsPeriodos := JsonObject():New()
			Self:oJsPeriodos:FromJson(cJsPeriodo)

			aNames   := Self:oJsPeriodos:GetNames()
			nTotName := Len(aNames)
		EndIf
	Else
		//Salva da thread atual na memória.
		//Percorre os períodos e converte para o formato de data em JSON.
		aNames   := Self:oJsPeriodos:GetNames()
		nTotName := Len(aNames)
		For nIndName := 1 To nTotName
			nTotPer := Len(Self:oJsPeriodos[aNames[nIndName]])
			For nIndPer := 1 To nTotPer
				dData := Self:oJsPeriodos[aNames[nIndName]][nIndPer]
				Self:oJsPeriodos[aNames[nIndName]][nIndPer] := StrZero(Year(dData),4) + "-" + StrZero(Month(dData),2) + "-" + StrZero(Day(dData),2)
			Next nIndPer
		Next nIndName

		Self:oDominio:oDados:oMatriz:setFlag("PERIODOS_PROCESSAMENTO", Self:oJsPeriodos:ToJson())
	EndIf

	If !lError
		//Retorna os formatos de data para DATE
		For nIndName := 1 To nTotName
			nTotPer := Len(Self:oJsPeriodos[aNames[nIndName]])
			For nIndPer := 1 To nTotPer
				Self:oJsPeriodos[aNames[nIndName]][nIndPer] := StoD( StrTran(Self:oJsPeriodos[aNames[nIndName]][nIndPer], "-", "") )
			Next nIndPer
		Next nIndName
		aSize(aNames, 0)
	EndIf

Return

/*/{Protheus.doc} retornaDataPeriodo
Retorna a data do aPeriodos contino no JSON oJsPeriodos

@author ricardo.prandi
@since 05/07/2021
@version 1.0
@param 01 - cFilAux , character, código da filial
@param 02 - nPeriodo, numerico , número do período que será retornado
@param 03 - nTipoPer, numerico , tipo de período que deve ser considerado (default = periodo do mrp)
@return dData  , date     , data do período
/*/
METHOD retornaDataPeriodo(cFilAux, nPeriodo, nTipoPer) CLASS MrpDominio_Periodos
	Local aPeriodos := Nil

	Default nTipoPer := Self:oDominio:oParametros["nTipoPeriodos"]

	If nPeriodo == 0
		nPeriodo := 1
	EndIf

	aPeriodos := Self:retornaArrayPeriodos(cFilAux, nTipoPer)

Return aPeriodos[nPeriodo]

/*/{Protheus.doc} retornaArrayPeriodos
Retorna o aPeriodos da filial

@author marcelo.neumann
@since 05/07/2021
@version 1.0
@param 01 - cFilAux , character, código da filial
@param 02 - nTipoPer, numerico , tipo de período que deve ser considerado (default = periodo do mrp)
@return dData , date     , data do período
/*/
METHOD retornaArrayPeriodos(cFilAux, nTipoPer) CLASS MrpDominio_Periodos

	Local aPeriodos := {}
	Local aDados    := {}
	Local cChavePer := ""

	Default nTipoPer := Self:oDominio:oParametros["nTipoPeriodos"]

	If Empty(cFilAux)
		cFilAux := IIf(Self:oDominio:oMultiEmp:utilizaMultiEmpresa(), Self:oDominio:oMultiEmp:filialPorIndice(1), "")
	EndIf

	If Self:oJsPeriodos == Nil
		Self:cargaPeriodosJson(.T.)
	EndIf

	If Self:oJsPeriodos != Nil
		If nTipoPer == Self:oDominio:oParametros["nTipoPeriodos"]
			aPeriodos := Self:oJsPeriodos[cFilAux]
		Else
			/*
				Tipo de período do aPeriodos somente será diferente do
				parametrizado para o MRP (Self:oDominio:oParametros["nTipoPeriodos"])
				quando estiver sendo executada a validação para realizar a aglutinação de períodos
				para o produto, através das regras do campo MI_AGLUMRP.
			*/
			cChavePer := cValToChar(nTipoPer) + "_" + cFilAux
			If !Self:oJsPeriodos:HasProperty(cChavePer)
				//Ainda não foi criado o aPeriodos para o tipo de período necessário.
				//Irá criar e salvar no "oJsPeriodos".
				aDados := Self:montaPeriodos(cFilAux                              ,;
				                             Self:oDominio:oParametros["dDataIni"],;
				                             nTipoPer                             ,;
				                             Self:oDominio:oParametros["nPeriodos"])
				Self:oJsPeriodos[cChavePer] := aDados[2]
				aSize(aDados, 0)
			EndIf
			aPeriodos := Self:oJsPeriodos[cChavePer]
		EndIf
	EndIf

Return aPeriodos

/*/{Protheus.doc} buscaDataPeriodo
Identifica qual é a data que deve ser utilizada no período, considerando o calendário.
Utilizada para quando os períodos do MRP não são do tipo Diário.
Método utilizado durante a criação do aPeriodos.

@author lucas.franca
@since 10/10/2019
@version 1.0
@param 01 - cFilAux, character, código da filial
@param 02 - dData  , date     , Data atual que está sendo considerada.
@param 03 - nTipo  , numeric  , Tipo do processamento do MRP.
@param 04 - dInicio, date     , Data inicial do MRP
@return     dData  , date     , Data que deverá ser considerada para o período.
/*/
METHOD buscaDataPeriodo(cFilAux, dData, nTipo, dInicio) CLASS MrpDominio_Periodos

	//Somente processa caso utilize calendário e a data atual não é útil.
	If Self:oDominio:oParametros["nLeadTime"] != 1 .And. !Self:verificaDataUtil(cFilAux, dData)
		dData := Self:buscaProximoDiaUtil(cFilAux, dData)

		//A data do período é menor que a data de início do MRP.
		//Utiliza como data do período a data de início do MRP.
		If dData < dInicio
			dData := dInicio
		EndIf
	EndIf

Return dData

/*/{Protheus.doc} buscaPeriodoDaData
Identifica a posição da data no período, caso não exista, pode retornar o período anterior (requer ::aPeriodos ordenado)
@author brunno.costa
@since 04/06/2019
@version 1.0
@param 01 - cFilAux   , caracter, filial do período
@param 02 - dData     , array   , data para conversao
@param 03 - lMenorIgua, lógico  , indica se deve retornar o período anterior caso não exista um correspondente à data:
                                  true  -> retorna o período anterior (default)
								  false -> retorna 0 caso não encontre período para a data
@param 04 - nTipoPer  , numerico, tipo de período que deve ser considerado (default = periodo do mrp)
@return     nPosicao  , numerico, indica a posicao do array de períodos correpondente à data (dData)
/*/
METHOD buscaPeriodoDaData(cFilAux, dData, lMenorIgua, nTipoPer) CLASS MrpDominio_Periodos
	Local aPeriodos := Nil
	Local nInf      := 1 // limite inferior
    Local nMeio     := 0
	Local nPosicao  := 0
    Local nSup      := 0 // limite superior

	Default lMenorIgua := .T.
	Default nTipoPer   := Self:oDominio:oParametros["nTipoPeriodos"]

	aPeriodos := Self:retornaArrayPeriodos(cFilAux, nTipoPer)
	nSup      := Len(aPeriodos) //Limite superior

    While (nInf < nSup)
        nMeio := (nInf + nSup - 1 - Mod((nInf + nSup-1), 2)) / 2
		If (dData == aPeriodos[nMeio])
			nPosicao := nMeio
			Exit
        ElseIf (dData < aPeriodos[nMeio])
			nSup := nMeio - 1
        Else
			nInf := nMeio + 1
		EndIf
    Enddo

    If nInf == nSup
		nPosicao := nInf
	EndIf

	//Se estiver buscando o menor ou igual, verifica se a data realmente é menor ou igual que a do período
	If lMenorIgua .And. nPosicao == 0
		nPosicao := nSup
	EndIf

	//Se estiver buscando o menor ou igual, verifica se a data realmente é menor ou igual que a do período
	If lMenorIgua .And. nPosicao > 0
		If dData < aPeriodos[nPosicao]
			nPosicao--
		EndIf
	EndIf

Return nPosicao

/*/{Protheus.doc} buscaProximoDiaUtil
Busca o próximo dia útil no calendário MRP partindo da data enviada
@author marcelo.neumann
@since 24/06/2019
@version 1.0
@param 01 - cFilAux , Caracter, Código da filial
@param 02 - dDataPar, data    , data de partida para buscar o próximo dia útil
@return     dData   , data    , data do próximo dia útil de acordo com o calendário MRP
/*/
METHOD buscaProximoDiaUtil(cFilAux, dDataPar) CLASS MrpDominio_Periodos

	Local dData  := dDataPar
	Local lError := .F.

	//Verifica se a data possui hora de trabalho
	While !Self:verificaDataUtil(cFilAux, dData, @lError)
		If lError
			dData := dDataPar
			Exit
		EndIf
		dData++
	EndDo

Return dData

/*/{Protheus.doc} proximaData
Calcula e retorna qual será a próxima data de acordo com o tipo de processamento
@author marcelo.neumann
@since 11/07/2019
@version 1.0
@param 01 - cFilAux   , caracter, código da filial
@param 02 - dData     , data    , data de partida para buscar a próxima
@param 03 - nTipo     , numero  , indica o tipo de periodo a ser utilizado: 1- Diário
                                                                            2- Semanal
                                                                            3- Quinzenal
                                                                            4- Mensal
                                                                            5- Semestral
@param 04 - dInicio   , data    , Data inicial do processo do MRP
@param 05 - lUsaCalend, logico  , Indica que deve considerar datas do calendário
@return dData, data, próxima data de acordo com o tipo
/*/
METHOD proximaData(cFilAux, dData, nTipo, dInicio, lUsaCalend) CLASS MrpDominio_Periodos
	Local cMes As Character
	Local nAno As Numeric

	Default lUsaCalend := .T.

	Do Case
		Case nTipo == 1 //Diário
			dData++

		Case nTipo == 2 //Semanal
			dData += 7
			While Dow(dData) > 1
				dData--
			End

		Case nTipo == 3 //Quinzenal
			If Day(dData) < 15
				dData := FirstDate(dData) + 14
			Else
				dData := FirstDate(MonthSum(dData,1))
			EndIf

		Case nTipo == 4 //Mensal
			dData := FirstDate(MonthSum(dData,1))

		Case nTipo == 5 //Semestral
			nAno := Year(dData)
			cMes := "07"

			If Month(dData) >= 6
				nAno++
				cMes := "01"
			EndIf

			dData := CtoD("01/" + cMes + "/" + cValToChar(nAno))
	EndCase

	If lUsaCalend
		dData := Self:buscaDataPeriodo(cFilAux, dData, nTipo, dInicio)
	EndIf

Return dData

/*/{Protheus.doc} primeiroPeriodoUtil
Retorna qual é o primeiro período útil de acordo com o calendário, respeitando a parametrização de
utilização do calendário. Mantém o primeiro período salvo na variável nPrimeiroUtil para não fazer a busca
todas as vezes que este método for executado.

@author lucas.franca
@since 02/10/2019
@version 1.0
@param 01 - cFilAux, Character, Código da filial
@return Self:nPrimeiroUtil, Numeric, primeiro período útil de acordo com o calendário.
/*/
Method primeiroPeriodoUtil(cFilAux) CLASS MrpDominio_Periodos
	If Self:nPrimeiroUtil == 0
		If Self:oDominio:oParametros["nLeadTime"] <> 1
			Self:dPrimeiraUtil := Self:buscaProximoDiaUtil(cFilAux, Self:retornaDataPeriodo(cFilAux, 1))
			Self:nPrimeiroUtil := Self:buscaPeriodoDaData(cFilAux, Self:dPrimeiraUtil)
		Else
			Self:nPrimeiroUtil := 1
		EndIf
	EndIf
Return Self:nPrimeiroUtil

/*/{Protheus.doc} primeiraDataUtil
Retorna qual é a primeira data útil de acordo com o calendário, respeitando a parametrização de
utilização do calendário. Mantém o primeiro período salvo na variável dPrimeiraUtil para não fazer a busca
todas as vezes que este método for executado.

@author lucas.franca
@since 02/10/2019
@version 1.0
@param 01 - cFilAux, Character, Código da filial
@return Self:nPrimeiroUtil, Numeric, primeiro período útil de acordo com o calendário.
/*/
Method primeiraDataUtil(cFilAux) CLASS MrpDominio_Periodos
	If Self:dPrimeiraUtil == Nil
		Self:primeiroPeriodoUtil(cFilAux)
	EndIf
Return Self:dPrimeiraUtil

/*/{Protheus.doc} verificaDataUtil
Verifica no Calendário se determinada data é útil ou não, de acordo com
a parametrização nLeadTime.

@author lucas.franca
@since 02/10/2019
@version 1.0
@param 01 - cFilAux, Character, Código da filial
@param 02 - dData  , Date     , Data para verificação
@param 03 - lError , Logic    , Retorna por referência se houve erro na busca do calendário
@return lDataUtil, logic, .T. se a data dData for útil de acordo com o calendário.
/*/
Method verificaDataUtil(cFilAux, dData, lError) CLASS MrpDominio_Periodos
	Local cChaveData := ""
	Local cUteis     := ""
	Local lDataUtil  := .T.
	Default lError   := .F.

	If Self:oDominio:oParametros["nLeadTime"] <> 1
		cChaveData := cFilAux + DtoS(dData)
		If Self:oDatasUteis[cChaveData] == Nil
			cUteis := Self:oDominio:oDados:retornaCampo("CAL", 1, cChaveData, "CAL_UTEIS", @lError)
			If lError .Or. cUteis == "00:00"
				Self:oDatasUteis[cChaveData] := .F.
			Else
				Self:oDatasUteis[cChaveData] := .T.
			EndIf
		EndIf
		lDataUtil := Self:oDatasUteis[cChaveData]
	EndIf
Return lDataUtil

/*/{Protheus.doc} ultimaDataDoMRP
Retorna a última data que deve ser considerada no MRP.

@author lucas.franca
@since 11/10/2019
@version 1.0
@return dData, date, última data do MRP.
/*/
METHOD ultimaDataDoMRP() CLASS MrpDominio_Periodos
	Local aPeriodos := Self:retornaArrayPeriodos()
	Local dData     := Nil
	Local nLastPer  := Len(aPeriodos)

	If Self:dUltimaData == Nil .AND. nLastPer > 0
		If Self:oDominio:oParametros["nTipoPeriodos"] == 1 //Período diário
			//Irá utilizar como última data do MRP a mesma data do último período.
			Self:dUltimaData := aPeriodos[nLastPer]
		
		ElseIf Self:oDominio:oParametros["nTipoPeriodos"] == 2 //Período semanal
			//Irá utilizar como última data do MRP o último dia da última semana de processamento.
			Self:dUltimaData := aPeriodos[nLastPer]
			While Dow(Self:dUltimaData) < 7
				Self:dUltimaData++
			End
		
		ElseIf Self:oDominio:oParametros["nTipoPeriodos"] == 3 //Período quinzenal
			//Irá utilizar como última data do MRP o último dia da última quinzena de processamento.
			Self:dUltimaData := aPeriodos[nLastPer]
			If Day(Self:dUltimaData) < 15
				//Primeira quinzena do mês.
				While Day(Self:dUltimaData) < 14
					Self:dUltimaData++
				End
			Else
				//Segunda quinzena do mês. Utiliza último dia do mês
				Self:dUltimaData := FirstDate(MonthSum(Self:dUltimaData,1)) - 1
			EndIf
		
		ElseIf Self:oDominio:oParametros["nTipoPeriodos"] == 4 //Período mensal
			//Irá utilizar como última data do MRP o último dia do mês.
			Self:dUltimaData := aPeriodos[nLastPer]
			Self:dUltimaData := FirstDate(MonthSum(Self:dUltimaData,1)) - 1
		
		Else //Período semestral
			//Irá utilizar como última data do MRP o último dia do semestre.
			
			//Vai pegar o dia do próximo semestre (sem considerar o calendário) e depois subtrair
			//1 dia para retornar ao último dia do semestre atual
			Self:dUltimaData := Self:proximaData(""                                        ,;
			                                     aPeriodos[nLastPer]                       ,;
			                                     Self:oDominio:oParametros["nTipoPeriodos"],;
			                                     aPeriodos[nLastPer]                       ,;
			                                     .F.                                       )
			Self:dUltimaData -= 1
		EndIf
	EndIf

	dData := Self:dUltimaData

Return dData
