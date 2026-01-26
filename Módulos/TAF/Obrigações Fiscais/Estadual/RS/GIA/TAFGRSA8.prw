#include 'protheus.ch'

Function TAFGRSA8(aWizard as array, aFilial as array, cDatIni as char, cDatFim as char, cCabecalho as char)

Local cTxtSys  	as char
Local nHandle   as numeric
Local cREG 		as char
Local lFound    as logical
Local cStrTxt   as char
Local nI	     as numeric
Local nCont      as numeric
Local nQtdReg    as numeric
Local cLinha     as char
Local aLinhas    as array
Local dIni       as date
Local dFim       as date
Local nTotAnxIC  as numeric
Local nTotAnxST  as numeric
Local nTotAnxFCP as numeric
Local nTotAnxFST as numeric
Local cQryAls  := GetNextAlias()

Begin Sequence
	cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
	nHandle   	:= MsFCreate( cTxtSys )

	dIni := CTOD("01/"+ SubStr(aWizard[1,3],1,2) + "/" + cValToChar(aWizard[1,4]))
	dFim := LastDay(dIni)
	nCont := 0
	nTotAnxIC  := 0
    nTotAnxST  := 0
    nTotAnxFCP := 0
    nTotAnxFST := 0
	nQtdReg   := 0
	cReg := "X08"

	/* -------------- ANEXO VIII -------------- */
	aLinhas := {}
	cLinha  := ""
	guiaNoMes(aFilial[7], dIni, dFim, "VIII", cQryAls)
	dbSelectArea(cQryAls)

	while (cQryAls)->( !eof() )

		If(nCont == 11)
			aAdd(aLinhas,{nCont, cLinha})
			cLinha := ""
			nCont  := 0
		EndIf

		cLinha += Substr(cDatIni,7,2)
		cLinha += Substr(cDatFim,7,2)
		cLinha += FormatData(STOD((cQryAls)->C0R_DTVCT),.F.,5)
		cLinha += StrTran(StrZero((cQryAls)->ICMS, 14, 2),".","")
		cLinha += StrTran(StrZero((cQryAls)->ICMSST, 14, 2),".","")
		cLinha += IIF(Empty(aWizard[1][9]),Replicate("0",10),aWizard[1][9])
		cLinha += StrTran(StrZero((cQryAls)->AMPARA, 14, 2),".","")
		cLinha += StrTran(StrZero((cQryAls)->AMPARAST, 14, 2),".","")
		nCont++
		nQtdReg++
		nTotAnxIC  += (cQryAls)->ICMS
		nTotAnxST  += (cQryAls)->ICMSST
		nTotAnxFCP += (cQryAls)->AMPARA
		nTotAnxFST += (cQryAls)->AMPARAST

		(cQryAls)->( dbSkip() )
	enddo
	(cQryAls)->( dbCloseArea() )

	If nCont > 0
		aAdd(aLinhas,{nCont, cLinha})
		nCont := 0
	EndIF

	For nI := 1 to Len(aLinhas)
		nSeqGIARS++

		cStrTxt := cCabecalho
		cStrTxt += StrZero(nSeqGIARS,4,0)
		cStrTxt += "X08 "
		cStrTxt += StrZero(aLinhas[nI][1], 2, 0)
		cStrTxt += aLinhas[nI][2]

		cStrTxt += CRLF
		WrtStrTxt( nHandle, cStrTxt)
	Next

	aAdd(aTotAnexo,{"AnexoVIII_PgtoMesRef_ICMS",nTotAnxIC})
	aAdd(aTotAnexo,{"AnexoVIII_PgtoMesRef_ST",nTotAnxST})
	aAdd(aTotAnexo,{"AnexoVIII_PgtoMesRef_FCP",nTotAnxFCP})
	aAdd(aTotAnexo,{"AnexoVIII_PgtoMesRef_FCPST",nTotAnxFST})
	aAdd(aTotAnexo,{"AnexoVIII_PgtoMesRef",(nTotAnxIC + nTotAnxST + nTotAnxFCP + nTotAnxFST)})
	aAdd(aTotAnexo,{"qtdAnexoVIII",nQtdReg})

	/* -------------- ANEXO IX -------------- */
	aLinhas := {}
	cLinha  := ""
	nTotAnxIC  := 0
    nTotAnxST  := 0
    nTotAnxFCP := 0
    nTotAnxFST := 0
	nQtdReg   := 0
	guiaNoMes(aFilial[7], dIni, dFim, "IX", cQryAls)
	dbSelectArea(cQryAls)

	while (cQryAls)->( !eof() )

		If(nCont == 13)
			aAdd(aLinhas,{nCont, cLinha})
			cLinha := ""
			nCont  := 0
		EndIf

		cLinha += Substr((cQryAls)->C0R_DTVCT,7,2)
		cLinha += StrTran(StrZero((cQryAls)->ICMS, 14, 2),".","")
		cLinha += StrTran(StrZero((cQryAls)->ICMSST, 14, 2),".","")
		cLinha += IIF(Empty(aWizard[1][9]),Replicate("0",10),aWizard[1][9])
		cLinha += StrTran(StrZero((cQryAls)->AMPARA, 14, 2),".","")
		cLinha += StrTran(StrZero((cQryAls)->AMPARAST, 14, 2),".","")
		nCont++
		nQtdReg++
		nTotAnxIC  += (cQryAls)->ICMS
		nTotAnxST  += (cQryAls)->ICMSST
		nTotAnxFCP += (cQryAls)->AMPARA
		nTotAnxFST += (cQryAls)->AMPARAST

		(cQryAls)->( dbSkip() )
	enddo
	(cQryAls)->( dbCloseArea() )

	If nCont > 0
		aAdd(aLinhas,{nCont, cLinha})
		nCont := 0
	EndIF

	For nI := 1 to Len(aLinhas)
		nSeqGIARS++

		cStrTxt := cCabecalho
		cStrTxt += StrZero(nSeqGIARS,4,0)
		cStrTxt += "X09 "
		cStrTxt += StrZero(aLinhas[nI][1], 2, 0)
		cStrTxt += aLinhas[nI][2]

		cStrTxt += CRLF
		WrtStrTxt( nHandle, cStrTxt)
	Next

	aAdd(aTotAnexo,{"AnexoIX_PgtoVenc_ICMS",nTotAnxIC})
	aAdd(aTotAnexo,{"AnexoIX_PgtoVenc_ST",nTotAnxST})
	aAdd(aTotAnexo,{"AnexoIX_PgtoVenc_FCP",nTotAnxFCP})
	aAdd(aTotAnexo,{"AnexoIX_PgtoVenc_FST",nTotAnxFST})
	aAdd(aTotAnexo,{"AnexoIX_PgtoVenc",(nTotAnxIC + nTotAnxST + nTotAnxFCP + nTotAnxFST)})
	aAdd(aTotAnexo,{"qtdAnexoIX",nQtdReg})

	/* -------------- ANEXO X -------------- */
	aLinhas := {}
	cLinha  := ""
	nTotAnxIC  := 0
    nTotAnxST  := 0
    nTotAnxFCP := 0
    nTotAnxFST := 0
	nQtdReg   := 0
	guiaNoMes(aFilial[7], dIni, dFim, "X", cQryAls)

	dbSelectArea(cQryAls)
	while (cQryAls)->( !eof() )

		If(nCont == 11)
			aAdd(aLinhas,{nCont, cLinha})
			cLinha := ""
			nCont  := 0
		EndIf

		cLinha += Substr(cDatIni,7,2)
		cLinha += Substr(cDatFim,7,2)
		cLinha += FormatData(STOD((cQryAls)->C0R_DTVCT),.F.,5)
		cLinha += StrTran(StrZero((cQryAls)->ICMS, 14, 2),".","")
		cLinha += StrTran(StrZero((cQryAls)->ICMSST, 14, 2),".","")
		cLinha += IIF(Empty(aWizard[1][9]),Replicate("0",10),aWizard[1][9])
		cLinha += StrTran(StrZero((cQryAls)->AMPARA, 14, 2),".","")
		cLinha += StrTran(StrZero((cQryAls)->AMPARAST, 14, 2),".","")
		nCont++
		nQtdReg++
		nTotAnxIC  += (cQryAls)->ICMS
		nTotAnxST  += (cQryAls)->ICMSST
		nTotAnxFCP += (cQryAls)->AMPARA
		nTotAnxFST += (cQryAls)->AMPARAST

		(cQryAls)->( dbSkip() )
	enddo
	(cQryAls)->( dbCloseArea() )

	If nCont > 0
		aAdd(aLinhas,{nCont, cLinha})
		nCont := 0
	EndIF

	For nI := 1 to Len(aLinhas)
		nSeqGIARS++

		cStrTxt := cCabecalho
		cStrTxt += StrZero(nSeqGIARS,4,0)
		cStrTxt += "X10 "
		cStrTxt += StrZero(aLinhas[nI][1], 2, 0)
		cStrTxt += aLinhas[nI][2]

		cStrTxt += CRLF
		WrtStrTxt( nHandle, cStrTxt)
	Next

	aAdd(aTotAnexo,{"AnexoX_ICMS",nTotAnxIC})
	aAdd(aTotAnexo,{"AnexoX_ST",nTotAnxST})
	aAdd(aTotAnexo,{"AnexoX_FCP",nTotAnxFCP})
	aAdd(aTotAnexo,{"AnexoX_FST",nTotAnxFST})
	aAdd(aTotAnexo,{"qtdAnexoX",nQtdReg})

	GerTxtGRS( nHandle, cTxtSys, aFilial[1] + "_" + cReg)

Recover
	lFound := .F.

End Sequence


Return

//---------------------------------------------------------------------
/*/{Protheus.doc} guiaNoMes

Busca informações referente as Guias de Recolhimento

@Param 	cPerIni ->	Data Inicial do período de processamento
		cPerFim ->	Data Final do período de processamento
@Author Rafael Völtz
@Since 12/08/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function guiaNoMes(pUF as Char, dIni as Date, dFim as Date, cAnexo as Char, cQryAls as Char)
 Local cSelect  := ""
 Local cWhere   := ""
 Local cOrderBy := ""
 Local cGroupBy := ""
 Local cPeriodo := StrZero(Month(dIni),2,0) + cValToChar(Year(dIni))

	cSelect  := "% C0R.C0R_DTVCT C0R_DTVCT,"
	cSelect  += "  SUM(CASE WHEN C0R.C0R_TPIMPO = '01' THEN C0R.C0R_VLDA END) ICMS, "
	cSelect  += "  SUM(CASE WHEN C0R.C0R_TPIMPO = '02' THEN C0R.C0R_VLDA END) ICMSST, "
	cSelect  += "  SUM(CASE WHEN C0R.C0R_TPIMPO = '03' THEN C0R.C0R_VLDA END) AMPARA, "
	cSelect  += "  SUM(CASE WHEN C0R.C0R_TPIMPO = '04' THEN C0R.C0R_VLDA END) AMPARAST %"

	cWhere  := "% C0R.C0R_FILIAL = '" + xFilial("C0R") + "' AND "
	cWhere  += "  C0R.C0R_PERIOD = '"+ cPeriodo +"' AND "
	cWhere  += "  C0R.C0R_UF     = '" + pUF + "' AND "

	IF (cAnexo == "VIII")
		//data de pagamento e data de vencimento estejam dentro do período de referência da GIA
		cWhere  += " C0R.C0R_DTPGT BETWEEN '" + DTOS(dIni) + "' AND '" + DTOS(dFim) + "' AND "
		cWhere  += " C0R.C0R_DTVCT BETWEEN '" + DTOS(dIni) + "' AND '" + DTOS(dFim) + "' AND "
		cWhere  += " C0R.C0R_TPREC = '1' AND %"	 //Normal
	ElseIf(cAnexo == "IX")
		//data de vencimento estejam dentro do período de referência da GIA e a data de pagamento no mês seguinte
		cWhere  += " C0R.C0R_DTPGT BETWEEN '" + dtos(TAFSomaMes(dIni,1)) + "' AND '" + dtos(TAFSomaMes(dFim,1)) + "' AND "
		cWhere  += " C0R.C0R_DTVCT BETWEEN '" + dtos(dIni) + "' AND '" + dtos(dFim) + "' AND "
		cWhere  += " C0R.C0R_TPREC = '2' AND %" //Fato gerador
	ElseIf(cAnexo == "X")
		//data de vencimento e data de pagamento estejam no mês seguinte ao período de referência
		cWhere  += " C0R.C0R_DTPGT BETWEEN '" + dtos(TAFSomaMes(dIni,1)) + "' AND '" + dtos(TAFSomaMes(dFim,1)) + "' AND "
		cWhere  += " C0R.C0R_DTVCT BETWEEN '" + dtos(TAFSomaMes(dIni,1)) + "' AND '" + dtos(TAFSomaMes(dFim,1)) + "' AND "
		cWhere  += " C0R.C0R_TPREC = '1' AND %"
	EndIf

	cGroupBy := "% C0R.C0R_DTVCT %"
	cOrderBy := "% C0R.C0R_DTVCT %"

	BeginSql Alias cQryAls

		SELECT
		%Exp:cSelect%

		FROM
		%Table:C0R% C0R

		WHERE
		%Exp:cWhere%
		C0R.%NotDel%

		GROUP BY
		%Exp:cGroupBy%

		ORDER BY
		%Exp:cOrderBy%
	EndSql

Return 