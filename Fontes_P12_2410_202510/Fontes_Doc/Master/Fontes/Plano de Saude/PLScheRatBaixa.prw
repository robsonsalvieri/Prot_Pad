#Include "Protheus.ch"
#Include "TBICONN.ch"

//-----------------------------------------------------------------
/*/{Protheus.doc} PLScheRatBaixa
Schedule para gerar o rateio das baixas realizadas pelo Financeiro
em títulos do PLS

@type function
@author Vinicius Queiros Teixeira
@since 13/04/2021
@version Prothues 12
/*/
//-----------------------------------------------------------------
Function PLScheRatBaixa()

	Local nDiasAtras := MV_PAR01

	GeraLog(Replicate('*',50), .F.)
	GeraLog('Iniciando Job PLScheRatBaixa')
	Conout("Iniciando Job PLScheRatBaixa.")

	PLRatSeekBaixa(nDiasAtras)

	GeraLog('Finalizando Job PLScheRatBaixa')
	Conout("Finalizando Job PLScheRatBaixa.")
	GeraLog(Replicate('*',50), .F.)
	GeraLog('', .F.)   

	//Libera semaforo
	FreeUsedCode()

Return


//-----------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Schedule para job

@type function
@author vinicius.queiros
@since 19/10/2020
@version Protheus 12
/*/
//-----------------------------------------------------------------
Static Function SchedDef()
Return { "P","PLSQTDDIA",,{},""}


/*/{Protheus.doc} PLRatSeekBaixa
Busca as Baixas a serem gravadas na tabela B6U (Rateio)

@type function
@version 12.1.2410 
@author vinicius.queiros
@since 23/01/2024
@param nDiasAtras, numeric, quantidade de dias a realizar a busca
/*/
function PLRatSeekBaixa(nDiasAtras as numeric)

	local cQuery := "" as character
	local cAlias := "" as character
	local cFilialE1 := "" as character
	local cPrefixo := "" as character
	local cNumero := "" as character
	local cParcela := "" as character
	local cTipo := "" as character
	local dDataBaixa := ctod(" / / ") as date
	local cCliente := "" as character
	local cLoja := "" as character
	local cNumCobranca := "" as character
	local nValorBaixa := 0 as numeric
	local cSeqBaixa := "" as character
	local dDataInicial := ctod(" / / ") as date
	local dDataFinal := ctod(" / / ") as date
	local oExec as object

	default nDiasAtras := 0

	dDataInicial := dDataBase - nDiasAtras
	dDataFinal := dDataBase

	cAlias := getNextAlias()
	cQuery := " SELECT SE1.E1_FILIAL,SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_TIPO, SE1.E1_CLIENTE, SE1.E1_LOJA, SE1.E1_PLNUCOB, "
	cQuery += "        FK1.FK1_VALOR, FK1.FK1_SEQ, FK1.FK1_TPDOC, FK1.FK1_DATA, "
	cQuery += " ("
	cQuery += " SELECT SUM(VALOR) TOTAL FROM ( "
	cQuery += "   SELECT CASE WHEN FK6.FK6_TPDOC = 'DC' THEN FK6_VALMOV * -1 ELSE FK6_VALMOV END VALOR " // DC = Desconto
	cQuery += "   FROM " + retSqlName("FK6") + " FK6 "
	cQuery += "		WHERE FK6.FK6_FILIAL = FK1.FK1_FILIAL "
	cQuery += "		  AND FK6.FK6_IDORIG = FK1.FK1_IDFK1 "
	cQuery += "		  AND FK6.D_E_L_E_T_ = ' ') TOT_FK6 "
	cQuery += " ) VL_ACESS " // Valores Acessórios: Valor total (+juros), (+multa) e (-descontos)

	cQuery += " FROM " + retSqlName("FK1") + " FK1 "
	cQuery += " INNER JOIN " + retSqlName("FK7") + " FK7 "
	cQuery += "      ON FK7_FILIAL = '"+xFilial("FK7")+"' "
	cQuery += "     AND ((FK7_IDDOC = FK1_IDDOC) OR (FK7_IDDOC = FK1_IDCOMP AND SUBSTRING(FK1_ORIGEM, 1, 3) = 'FIN')) "
	cQuery += "     AND FK7_ALIAS = 'SE1' "
	cQuery += "     AND FK7.D_E_L_E_T_ = ' ' "

	cQuery += " INNER JOIN " + retSqlName("SE1") + " SE1 "
	cQuery += "    ON E1_FILIAL = FK7_FILTIT "
	cQuery += "		AND E1_PREFIXO = FK7_PREFIX "
	cQuery += "		AND E1_NUM = FK7_NUM "
	cQuery += "		AND E1_PARCELA = FK7_PARCEL "
	cQuery += "		AND E1_TIPO = FK7_TIPO "
	cQuery += "		AND E1_CLIENTE = FK7_CLIFOR "
	cQuery += "		AND E1_LOJA = FK7_LOJA "
	cQuery += "     AND E1_TIPO NOT IN " + formatIn(MVABATIM + "|" + MVIRABT + "|" + MVINABT + "|" + MVPAGANT, "|")
	cQuery += " 	AND SUBSTRING(E1_ORIGEM,1,3) = 'PLS' "
	cQuery += " 	AND E1_TITPAI = ' ' "
	cQuery += " 	AND SE1.D_E_L_E_T_ = ' ' "

	cQuery += " WHERE FK1_FILIAL = '" + xFilial("FK1") + "' "
	cQuery += "   AND FK1_DATA BETWEEN '" + dtos(dDataInicial) + "' AND '" + dtos(dDataFinal) + "' "
	cQuery += "   AND FK1_TPDOC IN ('BA','VL','BL','V2','ES') "
	cQuery += "   AND FK1_LA <> 'S' "
	cQuery += "   AND FK1.D_E_L_E_T_ = ' ' "

	cQuery += " ORDER BY E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA"

	oExec  := FwExecStatement():new(changeQuery(cQuery))
	cAlias := oExec:openAlias()

	while !(cAlias)->(eof())
		cFilialE1 := (cAlias)->E1_FILIAL
		cPrefixo := (cAlias)->E1_PREFIXO
		cNumero := (cAlias)->E1_NUM
		cParcela := (cAlias)->E1_PARCELA
		cTipo := (cAlias)->E1_TIPO
		dDataBaixa := SToD((cAlias)->FK1_DATA)
		cCliente := (cAlias)->E1_CLIENTE
		cLoja := (cAlias)->E1_LOJA
		cNumCobranca := (cAlias)->E1_PLNUCOB
		nValorBaixa := (cAlias)->FK1_VALOR
		cSeqBaixa := (cAlias)->FK1_SEQ

		geraLog("[ Titulo " + cPrefixo + cNumero + cParcela + cTipo + " ]")
		geraLog("- Seq. baixa: " + cSeqBaixa, .F.)
		geraLog("- Tipo doc: " + (cAlias)->FK1_TPDOC, .F.)
		geraLog("- Valor da baixa: " + cValToChar(nValorBaixa), .F.)
		geraLog("", .F.)

		if (cAlias)->FK1_TPDOC $ "BA/VL/BL/V2" // Baixas
			if !checkBaixaRateio(cPrefixo, cNumero, cParcela, cTipo, cSeqBaixa)

				if valType((cAlias)->VL_ACESS) == "N" .and. (cAlias)->VL_ACESS <> 0 // Quando houver valores acessórios (Juros, Multa e Desconto), subtrai do valor total
					nValorBaixa -= (cAlias)->VL_ACESS
				endif

				gravaRateioBaixa(cPrefixo, cNumero, cParcela, cTipo, dDataBaixa, cCliente, cLoja, cNumCobranca, nValorBaixa, cSeqBaixa)
			endif		
		endif

		geraLog("", .F.)

		(cAlias)->(dbSkip())
	enddo

	freeObj(oExec)

	(cAlias)->(dbCloseArea())

return

//-------------------------------------------------------------------
/*/{Protheus.doc} CheckEstornoBaixa
Verifica se o a baixa possui estorno no financeiro

@type function
@author Vinicius Queiros Teixeira
@since 13/04/2021
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function CheckEstornoBaixa(cFilialE1, cPrefixo, cNumero, cParcela, cTipo, cCliente, cLoja, cSeqBaixa)

	Local lRetorno := .F.
	Local nQtdRegistro := 0
	Local cChaveFK7 := ""
	Local cIdDoc := ""

	cChaveFK7 := cFilialE1+"|"+cPrefixo+"|"+cNumero+"|"+cParcela+"|"+cTipo+"|"+cCliente+"|"+cLoja

	cIdDoc := FinBuscaFK7(cChaveFK7, "SE1")

	If !Empty(cIdDoc)
		cQuery := " SELECT COUNT(*) CONTADOR FROM "+RetSQLName("FK1")+" FK1 "
		cQuery += " WHERE FK1.FK1_FILIAL = '" +xFilial("FK1")+"' "
		cQuery += "   AND FK1.FK1_IDDOC  = '"+cIdDoc+"' "
		cQuery += "   AND FK1.FK1_SEQ  = '"+cSeqBaixa+"' "
		cQuery += "   AND FK1.FK1_TPDOC = 'ES' "
		cQuery += "   AND FK1.D_E_L_E_T_ = ' ' "

		nQtdRegistro := MPSysExecScalar(cQuery, "CONTADOR")

		lRetorno := IIF(nQtdRegistro > 0, .T., .F.)
	EndIf

Return lRetorno

/*/{Protheus.doc} CheckBaixaRateio
Verifica se existe baixa grava na tabela B6U

@type function
@version 12.1.2410
@author vinicius.queiros
@since 1/23/2024
@param cPrefixo, character, prefixo do titulo
@param cNumero, character, numero do titulo
@param cParcela, character, parcela do titulo
@param cTipo, character, tipo do titulo
@param cSeqBaixa, character, sequencial da baixa no financeiro
@return logical, baixa do titulo já gravada no rateio (B6U)
/*/
static function CheckBaixaRateio(cPrefixo as character, cNumero as character, cParcela as character, cTipo as character, cSeqBaixa as character)

	local lRetorno := .F. as logical
	local nQtdRegistro as numeric
	local cQuery as character

	cQuery := " SELECT COUNT(*) CONTADOR FROM " + retSQLName("B6U") + " B6U "
	cQuery += " WHERE B6U.B6U_FILIAL = '" + xFilial("B6U") + "' "
	cQuery += "   AND B6U.B6U_PREFIX = '" + cPrefixo + "' "
	cQuery += "   AND B6U.B6U_NUMTIT = '" + cNumero + "' "
	cQuery += "   AND B6U.B6U_PARCEL = '" + cParcela + "' "
	cQuery += "   AND B6U.B6U_TIPTIT = '" + cTipo + "' "
	cQuery += "   AND B6U.B6U_SEQBAI = '" + cSeqBaixa + "' "
	cQuery += "   AND B6U.D_E_L_E_T_ = ' ' "

	nQtdRegistro := MPSysExecScalar(cQuery, "CONTADOR")

	lRetorno := iif(nQtdRegistro > 0, .T., .F.)

	if lRetorno
		geraLog("*** Baixa ja gravada na tabela B6U.", .F.)
	endif

return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaRateioBaixa
Realiza o rateio da baixa e a gravação na tabela B6U

@type function
@author Vinicius Queiros Teixeira
@since 08/04/2021
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function GravaRateioBaixa(cPrefixo, cNumero, cParcela, cTipo, dDataEmissao, cCliente, cLoja, cPlNumCob,;
								 nValorBaixa, cSeqBaixa)

	Local lRetorno := .F.
	Local cQuery := ""
	Local cAlias := ""
	Local cTipoTitulo := ""
	Local cOperadora := ""
	Local cNumCobranca := ""
	Local cTipoBaixa := ""
	Local nX := 0
	Local nPorcenRateio := 0
	Local nVlrRateio:= 0
	Local nBusca := 0
	Local nTotalRateio	:= 0
	Local nVltTotalTitulo := 0
	Local aLancamentos := {}
	Local aRateioBaixa := {}
	Local aRateioTotal := {}
	Local nValorDif := 0
	Local nTotalNCC := 0
	Local nVlrBase := 0

	Default nValorBaixa := 0
	Default cSeqBaixa := ""
	Default nRecno := 0

	cOperadora := SubStr(cPlNumCob, 1, 4)
	cNumCobranca := SubStr(cPlNumCob, 5)

	cAlias := GetNextAlias()
	cQuery := " SELECT BM1_VALOR, BM1_CODTIP, BM1_TIPTIT FROM " + RetSQLName("BM1") + " BM1 "
	cQuery += " WHERE BM1_FILIAL = '" + xFilial("BM1") + "'"
	cQuery += "	  AND BM1.BM1_PLNUCO = '"+cPlNumCob+"'"
	cQuery += "	  AND BM1.BM1_PREFIX = '"+cPrefixo+"'"
	cQuery += "	  AND BM1.BM1_NUMTIT = '"+cNumero+"'"
	cQuery += "	  AND BM1.BM1_PARCEL = '"+cParcela+"'"
	cQuery += "   AND BM1.D_E_L_E_T_= ' ' "
	cQuery += " ORDER BY BM1_CODTIP "

	DbUseArea(.T.,"TOPCONN",tcGenQry(,,cQuery),cAlias,.F.,.T.)

	While !(cAlias)->(Eof())

		If (cAlias)->BM1_TIPTIT <> "NCC"
			nBusca := Ascan(aLancamentos, {|x| x[1] == (cAlias)->BM1_CODTIP})
			If nBusca > 0
				aLancamentos[nBusca][2] += (cAlias)->BM1_VALOR
			Else
				aAdd(aLancamentos,{ (cAlias)->BM1_CODTIP, (cAlias)->BM1_VALOR })
			EndIf
			cTipoTitulo := (cAlias)->BM1_TIPTIT
			nVltTotalTitulo += (cAlias)->BM1_VALOR
		Else
			nTotalNCC += (cAlias)->BM1_VALOR
		EndIf

		(cAlias)->(DbSkip())
	EndDo

	(cAlias)->(DbCloseArea())

	If nValorBaixa > 0 .And. Len(aLancamentos) > 0
		geraLog("*** Rateio dos lancamentos ***", .F.)

		For nX := 1 To Len(aLancamentos)

			nPorcenRateio := ((aLancamentos[nX][2] * 100) / nVltTotalTitulo) / 100 // Porcentagem do lançamento sobre o valor do titulo
			nVlrRateio := Round(nPorcenRateio * nValorBaixa ,2) // Valor que corresponde a porcentagem do lançamento sobre a baixa

			If cTipo == "NCC"
				cTipoBaixa := "BAIXA-NCC"
				nVlrBase := Round(nPorcenRateio * nTotalNCC ,2) // Valor que corresponde a porcentagem do lançamento sobre o valor total da NCC
			Else
				cTipoBaixa := "BAIXA-TIT"
				nVlrBase := aLancamentos[nX][2]
			EndIf

			aAdd(aRateioBaixa, { cOperadora ,; 			// [1]  B6U_CODINT
				cNumCobranca ,; 		// [2]  B6U_NUMCOB
				aLancamentos[nX][1] ,; // [3]  B6U_CODTIP
				cPrefixo ,; 			// [4]  B6U_PREFIX
				cNumero ,; 			// [5]  B6U_NUMTIT
				cTipo ,; 				// [6]  B6U_TIPTIT
				cParcela ,; 			// [7]  B6U_PARCEL
				cTipoBaixa ,;			// [8]  B6U_IMPOST
				nVlrRateio ,;			// [9]  B6U_VALOR
				nVlrBase ,;	        // [10] B6U_VALBAS
				dDataEmissao ,;		// [11] B6U_DTEMIS
				cCliente ,;			// [12] B6U_CODIGO
				cLoja ,;				// [13] B6U_LOJA
				cTipoTitulo ,;			// [14] B6U_TIPBAS
				cSeqBaixa }) 			// [15] B6U_SEQBAI
			nTotalRateio += nVlrRateio

			geraLog("* Lancamento " + aLancamentos[nX][1] + " - tipo da baixa: " + cTipoBaixa + " - valor: " + cValToChar(nVlrRateio), .F.)
		Next nX

		geraLog("(=) Total dos lancamentos: " + cValToChar(nTotalRateio), .F.)

		geraLog("", .F.)

		// Quando houver diferença de centavos no rateio, adiciona/diminui do ultimo lançamento
		If nTotalRateio > 0
			nTotalRateio := nValorBaixa - nTotalRateio
		EndIf

		geraLog("(!=) Diferenca: " + cValToChar(nTotalRateio), .F.)

		If nTotalRateio <> 0 .And. Len(aRateioBaixa) > 0
			aRateioBaixa[Len(aRateioBaixa)][9] += nTotalRateio
		EndIf

		iif(nTotalRateio <> 0 .And. Len(aRateioBaixa) > 0, geraLog("* Diferenca adicionada no ultimo lancamento: ", .F.), nil)
		iif(nTotalRateio <> 0 .And. Len(aRateioBaixa) > 0, geraLog("Lancamento: " + aRateioBaixa[Len(aRateioBaixa)][3], .F.), nil)
		iif(nTotalRateio <> 0 .And. Len(aRateioBaixa) > 0, geraLog("(+) Novo valor: " + cValToChar(aRateioBaixa[Len(aRateioBaixa)][9]), .F.), nil)
	EndIf

	// Ajuste necessária devido a diferença de centavo nos lançamentos, apos realizar a ultima baixa do titulo
	aRateioTotal := PLRatTotal(cPrefixo, cNumero, cParcela, cTipo, cCliente, cLoja)

	If Len(aRateioTotal) > 0
		geraLog("", .F.)
		geraLog("* Calculando diferenca de valores (BM1 x B6U)", .F.)

		For nX := 1 To Len(aRateioBaixa)
			nBusca := Ascan(aRateioTotal, {|x| x[1] == aRateioBaixa[nX][3] })

			If nBusca > 0
				geraLog("", .F.)
				geraLog("*** Lancamento *** " + aRateioBaixa[nX][3], .F.)
				geraLog("Valor BM1: " + cValToChar(aRateioTotal[nBusca][2]), .F.)
				geraLog("Valor ja gravado na B6U: " + cValToChar(aRateioTotal[nBusca][3]), .F.)
				geraLog("Valor a ser gravado na B6U: " + cValToChar(aRateioBaixa[nX][9]), .F.)

				nValorDif := aRateioTotal[nBusca][2] - (aRateioTotal[nBusca][3] + aRateioBaixa[nX][9] )

				geraLog("(!=) Diferenca: " + cValToChar(nValorDif), .F.)

				If nValorDif <= 0.05 .and. nValorDif <> 0 // Se o valor for maior é porque o titulo não foi baixado totalmente					
					aRateioBaixa[nX][9] += nValorDif

					geraLog("(+) Novo valor do lancamento: " + cValToChar(aRateioBaixa[nX][9]), .F.)
				EndIf
			EndIf

		Next nX
	EndIf

	If Len(aRateioBaixa) > 0
		lRetorno := PLGrvRateio(aRateioBaixa)

		geraLog("", .F.)
		geraLog("(OK) Baixa gravada com sucesso na tabela B6U", .F.)
	EndIf

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} PLRatTotal
Busca o valor total do titulo e o valor baixado (Impostos+NCC+Baixas)

@type function
@author Vinicius Queiros Teixeira
@since 02/02/2021
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function PLRatTotal(cPrefixo, cNumero, cParcela, cTipoTit, cCliente, cLoja)

	Local cQuery := ""
	Local cAlias := ""
	Local nBusca := 0
	Local aTotalLanc := {}
	Local cTipo := ""
	Local cSeqBaixa := ""
	Local nValor := 0

	cAlias := GetNextAlias()
	cQuery := " SELECT * FROM "+RetSQLName("B6U")+" B6U "
	cQuery += " WHERE B6U.B6U_FILIAL = '"+xFilial("B6U")+"'"
	cQuery += "   AND B6U.B6U_PREFIX = '"+cPrefixo+"' "
	cQuery += "   AND B6U.B6U_NUMTIT = '"+cNumero+"' "
	cQuery += "   AND B6U.B6U_PARCEL = '"+cParcela+"' "
	If cTipoTit == "NCC"
		cQuery += " AND B6U.B6U_TIPTIT = '"+cTipoTit+"' "
	EndIf
	cQuery += " AND B6U.B6U_IMPOST <> 'TOTAL' "
	cQuery += " AND B6U.D_E_L_E_T_= ' ' "
	cQuery += " ORDER BY B6U_PREFIX,B6U_NUMTIT,B6U_PARCEL,B6U_CODTIP"

	DbUseArea(.T.,"TOPCONN",tcGenQry(,,cQuery),cAlias,.F.,.T.)

	While !(cAlias)->(Eof())

		nValor := 0
		cTipo := (cAlias)->B6U_TIPTIT
		cSeqBaixa := (cAlias)->B6U_SEQBAI

		If Alltrim((cAlias)->B6U_IMPOST) == "BAIXA-TIT" .Or. Alltrim((cAlias)->B6U_IMPOST) == "BAIXA-NCC"
			If !CheckEstornoBaixa(xFilial("SE1"), cPrefixo, cNumero, cParcela, cTipo, cCliente, cLoja, cSeqBaixa) // Verifica se a baixa não foi estornada
				nValor := (cAlias)->B6U_VALOR
			EndIf
		Else
			nValor := (cAlias)->B6U_VALOR
		EndIf

		nBusca := Ascan(aTotalLanc, {|x| x[1] == (cAlias)->B6U_CODTIP })
		If nBusca > 0
			aTotalLanc[nBusca][3] += nValor
			If (cAlias)->B6U_TIPTIT <> "NCC"
				aTotalLanc[nBusca][2] := (cAlias)->B6U_VALBAS
			EndIf
		Else
			aAdd(aTotalLanc,{(cAlias)->B6U_CODTIP,;  // Tipo de Lançamento
							 getBaseValueTitle(cPrefixo, cNumero, cParcela, (cAlias)->B6U_CODTIP) ,; // Valor Líquido (Esperado)
							 nValor }) 			  	 // Valor Baixado
		EndIf

		(cAlias)->(DbSkip())
	EndDo

	(cAlias)->(DbCloseArea())

Return aTotalLanc


//-----------------------------------------------------------------
/*/{Protheus.doc} GeraLog
Gera Log do Schedule de Rateio de Baixas

@type function
@author Vinicius Queiros Teixeira
@since 13/04/2021
@version Prothues 12
/*/
//-----------------------------------------------------------------
Static Function GeraLog(cMsg, lDateTime)

	Local cNameLog := "schedule_rateio_baixa.log"
	Local cDateTime := Substr(DTOS(Date()),7,2)+"/"+Substr(DTOS(Date()),5,2)+"/"+Substr(DTOS(Date()),1,4) + "-" + Time()

	Default cMsg := ""
	Default lDateTime := .T.

	If !Empty(cNameLog)
		If lDateTime
			PlsLogFil("["+cDateTime+"] " + cMsg, cNameLog)
		Else
			PlsLogFil(cMsg, cNameLog)
		EndIf
	EndIf

Return

/*/{Protheus.doc} getBaseValueTitle
Retorna o valor base (BM1_VALOR) do título principal para ser utilizado no calculo do rateio
@type function
@version 12.1.2410
@author vinicius.queiros
@since 24/01/2024
@param cPrefix, character, Prefixo do titulo
@param cNumber, character, Numero do titulo
@param cParcel, character, Parcela do titulo
@param cType, character, tipo de lançamento, exemplo: 101 (mensalidade)
@return numeric, Valor base do lançamento do titulo
/*/
static function getBaseValueTitle(cPrefix as character, cNumber as character, cParcel as character, cType as character)	

	local cQuery as character
	local oExec as object
	local cAlias as character
	local nBaseValue := 0 as numeric

	cQuery := " SELECT ? "
	cQuery += " FROM ? BM1 "
	cQuery += " WHERE BM1_FILIAL = ? "
	cQuery += "   AND BM1_PREFIX = ? "
	cQuery += "	  AND BM1_NUMTIT = ? "
	cQuery += "   AND BM1_PARCEL = ? "
	cQuery += "	  AND BM1_TIPTIT <> ? "
	cQuery += "	  AND BM1_CODTIP = ? "
	cQuery += "	  AND BM1.D_E_L_E_T_ = ? "

	oExec := FwExecStatement():new(cQuery)

	oExec:setUnsafe(1, "BM1_VALOR")
	oExec:setUnsafe(2, retSqlName("BM1"))
	oExec:setString(3, xFilial("BM1"))
	oExec:setString(4, cPrefix)
	oExec:setString(5, cNumber)
	oExec:setString(6, cParcel)
	oExec:setString(7, "NCC")
	oExec:setString(8, cType)
	oExec:setString(9, " ")

	cAlias := oExec:openAlias()

	while !(cAlias)->(eof())
		nBaseValue += (cAlias)->BM1_VALOR

		(cAlias)->(dbskip())
	enddo

	(cAlias)->(dbCloseArea())

	freeObj(oExec)

return nBaseValue
