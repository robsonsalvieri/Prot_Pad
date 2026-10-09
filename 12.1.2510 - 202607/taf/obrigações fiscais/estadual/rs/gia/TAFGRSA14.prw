#include 'protheus.ch'

Function TAFGRSA14(aWizard, aFilial, cDatIni, cDatFim, cCabecalho)


Local oError	as object
Local cTxtSys  	as char
Local nHandle   as numeric
Local cREG 		as char
Local nQtdReg   as numeric
Local lFound    as logical
Local cStrTxt   as char
Local cLinha    as char
Local aLinha    as array
Local aAjustes  as array
Local nI        as char
Local nTotalAnx as numeric

Begin Sequence
	cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
	nHandle   	:= MsFCreate( cTxtSys )
	cREG		:= "X14"
	lFound      := .T.
	nQtdReg     := 0
	nCont       := 0
	cLinha      := ""
	nTotalAnx   := 0
	aLinha := {}

	/* --------------------- Anexo XIV – Outros Créditos --------------------- */
	aAjustes := OutrDebCre(cDatIni, cDatFim, "0", aFilial[7], "'00600' AND '00698'")

	While nQtdReg < Len(aAjustes)
		nQtdReg++
		If(nCont == 10)
			aAdd(aLinha,{nCont, cLinha})
			cLinha := ""
			nCont  := 0
		EndIf

		cLinha += StrZero(Val(Substr(aAjustes[nQtdReg][1],4,2)),3)
		cLinha += StrTran(StrZero(aAjustes[nQtdReg][2], 14, 2),".","")
		cLinha += IIF(Empty(Alltrim(aAjustes[nQtdReg][3])),SPACE(60),aAjustes[nQtdReg][3])
		nCont++
		nTotalAnx += aAjustes[nQtdReg][2]
	EndDo

	If nCont > 0
		aAdd(aLinha,{nCont, cLinha})
		nCont := 0
	EndIF

	For nI := 1 to Len(aLinha)
		nSeqGIARS++

		cStrTxt := cCabecalho
		cStrTxt += StrZero(nSeqGIARS,4,0)
		cStrTxt += PADR("X14",4)
		cStrTxt += StrZero(aLinha[nI][1], 2, 0)
		cStrTxt += aLinha[nI][2]

		cStrTxt += CRLF
		WrtStrTxt( nHandle, cStrTxt)
	Next

	aAdd(aTotAnexo,{"AnexoXIV_OutrosCre",nTotalAnx})
	aAdd(aTotAnexo,{"qtdAnexoXIV",nQtdReg})

	/* --------------------- Anexo XV – Outros Débitos --------------------- */
	aAjustes := OutrDebCre(cDatIni, cDatFim, "1", aFilial[7], "'00200' AND '00298'")
	nQtdReg	  := 0
	nTotalAnx := 0
	aLinha    := {}
	cLinha    := ""

	While nQtdReg < Len(aAjustes)
		nQtdReg++
		If(nCont == 10)
			aAdd(aLinha,{nCont, cLinha})
			cLinha := ""
			nCont  := 0
		EndIf

		cLinha += StrZero(Val(Substr(aAjustes[nQtdReg][1],4,2)),3)
		cLinha += StrTran(StrZero(aAjustes[nQtdReg][2], 14, 2),".","")
		cLinha += IIF(Empty(Alltrim(aAjustes[nQtdReg][3])),SPACE(60),aAjustes[nQtdReg][3])
		nCont++
		nTotalAnx += aAjustes[nQtdReg][2]
	EndDo

	If nCont > 0
		aAdd(aLinha,{nCont, cLinha})
		nCont := 0
	EndIF

	For nI := 1 to Len(aLinha)
		nSeqGIARS++

		cStrTxt := cCabecalho
		cStrTxt += StrZero(nSeqGIARS,4,0)
		cStrTxt += PADR("X15",4)
		cStrTxt += StrZero(aLinha[nI][1], 2, 0)
		cStrTxt += aLinha[nI][2]

		cStrTxt += CRLF
		WrtStrTxt( nHandle, cStrTxt)
	Next

	aAdd(aTotAnexo,{"AnexoXV_OutrosDeb",nTotalAnx})
	aAdd(aTotAnexo,{"qtdAnexoVX",nQtdReg})

	GerTxtGRS( nHandle, cTxtSys, aFilial[1] +"_" + cReg)

Recover
	lFound := .F.

End Sequence

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} CrDebImpor

Retorno os valores de Crédito e Débito referente a Exportação e Importação
respectivamente

@Param 	cPerIni ->	 Data Inicial do período de processamento
		cPerFim ->	 Data Final do período de processamento
		cTipOpe ->   E-Entrada; S-Saída
		cUFID 	-> 	 UF da empresa corrente
		cCondSubIt-> Condição para filtro do subitem

@Return nTot -> Valor total de crédito ou débito
@Author Rafael Völtz
@Since 12/08/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function OutrDebCre(cDtIni, cDtFim, cTipOpe, cUFID, cCondSubIt)
	Local cQryAls 	:= GetNextAlias()
	Local cStrQuery := ""
	Local cDescAju99 := ""
	Local nValAju99  := 0
	Local aRet       := {}

	cStrQuery += " SELECT CHY.CHY_CODIGO CHY_CODIGO, "
	cStrQuery +=   		" SUM(C2D.C2D_VLICM) VLR_AJUS "
	cStrQuery +=   " FROM " + RetSqlName('C20') + " C20, "
	cStrQuery +=              RetSqlName('C2D') + " C2D, "
	cStrQuery +=              RetSqlName('CHY') + " CHY  "
	cStrQuery += "  WHERE C20.C20_FILIAL = '" + xFilial("C20") + "' "
	cStrQuery +=   "  AND C20.C20_DTDOC  BETWEEN '" + cDtIni + "' AND '" + cDtFim + "'"
	cStrQuery +=   "  AND C20.C20_INDOPE = '"+ cTipOpe + "'"
	cStrQuery +=   "  AND C20.C20_CODSIT NOT IN('000003','000005','000006') "  //CANCELADA, INUTILIZADA E DENEGADA
	cStrQuery +=   "  AND C20.C20_FILIAL = C2D.C2D_FILIAL "
	cStrQuery +=   "  AND C20.C20_CHVNF  = C2D.C2D_CHVNF "
	cStrQuery +=   "  AND CHY.CHY_FILIAL = '" + xFilial("CHY") + "' "
	cStrQuery +=   "  AND CHY.CHY_ID     = C2D.C2D_IDSUBI "
	cStrQuery +=   "  AND CHY.CHY_IDUF   = '" + cUFID + "'"
	cStrQuery +=   "  AND CHY.CHY_CODIGO BETWEEN " + cCondSubIt
	cStrQuery +=   "  AND C20.D_E_L_E_T_ = ''"
	cStrQuery +=   "  AND C2D.D_E_L_E_T_ = ''"
	cStrQuery +=   "  AND CHY.D_E_L_E_T_ = ''"
	cStrQuery +=   "  GROUP BY CHY.CHY_CODIGO "

	cStrQuery := ChangeQuery(cStrQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cStrQuery),cQryAls,.T.,.T.)

	While !(cQryAls)->(EoF())
		aAdd(aRet, {(cQryAls)->CHY_CODIGO, (cQryAls)->VLR_AJUS, ""})
		(cQryAls)->(dbSkip())
	EndDo

	(cQryAls)->( dbCloseArea() )

	cStrQuery := " SELECT C2D.R_E_C_N_O_ RECORD, "
	cStrQuery +=   		" SUM(C2D.C2D_VLICM) VLR_AJUS "
	cStrQuery +=   " FROM " + RetSqlName('C20') + " C20, "
	cStrQuery +=              RetSqlName('C2D') + " C2D, "
	cStrQuery +=              RetSqlName('CHY') + " CHY  "
	cStrQuery += "  WHERE C20.C20_FILIAL = '" + xFilial("C20") + "' "
	cStrQuery +=   "  AND C20.C20_DTDOC  BETWEEN '" + cDtIni + "' AND '" + cDtFim + "'"
	cStrQuery +=   "  AND C20.C20_INDOPE = '"+ cTipOpe + "'"
	cStrQuery +=   "  AND C20.C20_CODSIT NOT IN('000003','000005','000006') "  //CANCELADA, INUTILIZADA E DENEGADA
	cStrQuery +=   "  AND C20.C20_FILIAL = C2D.C2D_FILIAL "
	cStrQuery +=   "  AND C20.C20_CHVNF  = C2D.C2D_CHVNF "
	cStrQuery +=   "  AND CHY.CHY_FILIAL = '" + xFilial("CHY") + "' "
	cStrQuery +=   "  AND CHY.CHY_ID     = C2D.C2D_IDSUBI "
	cStrQuery +=   "  AND CHY.CHY_IDUF   = '" + cUFID + "'"
	cStrQuery +=   "  AND CHY.CHY_CODIGO = " + IIF(cCondSubIt $ ("00600"), '00699', '00299')
	cStrQuery +=   "  AND C20.D_E_L_E_T_ = ''"
	cStrQuery +=   "  AND C2D.D_E_L_E_T_ = ''"
	cStrQuery +=   "  AND CHY.D_E_L_E_T_ = ''"
	cStrQuery +=   "  GROUP BY C2D.R_E_C_N_O_"

	cStrQuery := ChangeQuery(cStrQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cStrQuery),cQryAls,.T.,.T.)
	DbSelectArea("C2D")

	While !(cQryAls)->(EoF())
		C2D->(dbGoTo((cQryAls)->RECORD))
		nValAju99  += C2D->C2D_VLICM
		cDescAju99 += C2D->C2D_DESCRI + " "

		(cQryAls)->(dbSkip())
	EndDo

	If (nValAju99 > 0)
		aAdd(aRet, {IIF(cCondSubIt $ ("00600"), '00699', '00299'), nValAju99, cDescAju99})
	EndIf

	(cQryAls)->( dbCloseArea() )

Return aRet


