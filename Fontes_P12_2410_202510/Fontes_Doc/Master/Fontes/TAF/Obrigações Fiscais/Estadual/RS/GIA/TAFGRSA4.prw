#include 'protheus.ch'

Function TAFGRSA4(aFilial, cDatIni, cDatFim, cCabecalho)

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
Local nTotalAnx  as numeric
Local dIni       as date
Local dFim       as date
Local cQryAls  := GetNextAlias()

Begin Sequence
	cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
	nHandle   	:= MsFCreate( cTxtSys )

	nCont := 0
	nTotalAnx := 0
	nQtdReg   := 0
	cReg := "X04"
	aLinhas := {}
	cLinha  := ""

	VlDevGuia(cDatIni, cDatFim, cQryAls)
	dbSelectArea(cQryAls)

	while (cQryAls)->( !eof() )

		If(nCont == 19)
			aAdd(aLinhas,{nCont, cLinha})
			cLinha := ""
			nCont  := 0
		EndIf

		dIni := CTOD("01/"+ SubStr((cQryAls)->C0R_DTVCT,5,2) + "/" + SubStr((cQryAls)->C0R_DTVCT,1,4))
		dFim := LastDay(dIni)

		cLinha += Strzero(Day(dIni),2) + Strzero(Day(dFim),2) + Strzero(Month(dIni),2) +  Strzero(Year(dIni),4)
		cLinha += FormatData(STOD((cQryAls)->C0R_DTVCT),.F.,5)
		cLinha += StrTran(StrZero((cQryAls)->C2U_VLDEV, 14, 2),".","")
		cLinha += StrTran(StrZero((cQryAls)->C0R_VLDA, 14, 2),".","")
		nCont++
		nQtdReg++
		nTotalAnx += (cQryAls)->C0R_VLDA - (cQryAls)->C2U_VLDEV

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
		cStrTxt += "X04 "
		cStrTxt += StrZero(aLinhas[nI][1], 2, 0)
		cStrTxt += aLinhas[nI][2]

		cStrTxt += CRLF
		WrtStrTxt( nHandle, cStrTxt)
	Next

	aAdd(aTotAnexo,{"AnexoIV_Compens",nTotalAnx})
	aAdd(aTotAnexo,{"qtdAnexoIV",nQtdReg})

	GerTxtGRS( nHandle, cTxtSys, aFilial[1] + "_" + cReg)

Recover
	lFound := .F.

End Sequence


Return

//---------------------------------------------------------------------
/*/{Protheus.doc} VlDevGuia

Busca informações referente as Guias de Recolhimento

@Param 	cDtIni ->	Data Inicial do período de processamento
		cDtFim ->	Data Final do período de processamento
		cQryAls -> Alias
@Author Rafael Völtz
@Since 12/08/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function VlDevGuia(cDtIni, cDtFim, cQryAls)
 Local cStrQuery  := ""

	cStrQuery += " SELECT C0R.C0R_PERIOD	C0R_PERIOD,"
	cStrQuery +=   		" C0R.C0R_DTVCT		C0R_DTVCT, "
	cStrQuery +=   		" C2U.C2U_VLDEV     C2U_VLDEV, "
	cStrQuery +=   		" C0R.C0R_VLDA      C0R_VLDA "
	cStrQuery +=   " FROM " + RetSqlName('C2S') + " C2S, "
	cStrQuery +=              RetSqlName('C2T') + " C2T, "
	cStrQuery +=              RetSqlName('C2U') + " C2U, "
	cStrQuery +=              RetSqlName('C0R') + " C0R, "
	cStrQuery +=              RetSqlName('CHY') + " CHY  "
	cStrQuery += "  WHERE C2S.C2S_FILIAL = '" + xFilial("C2S") + "' "
	cStrQuery +=   "  AND C2S.C2S_DTINI  >= '" + cDtIni + "'"
	cStrQuery +=   "  AND C2S.C2S_DTFIN  <= '" + cDtFim + "'"
	cStrQuery +=   "  AND C2S.C2S_TIPAPU = '0' "
	cStrQuery +=   "  AND C2T.C2T_FILIAL = C2S.C2S_FILIAL"
	cStrQuery +=   "  AND C2T.C2T_ID     = C2S.C2S_ID"
	cStrQuery +=   "  AND C2T.C2T_IDSUBI = CHY.CHY_ID"
	cStrQuery +=   "  AND CHY.CHY_FILIAL = '" + xFilial("CHY") + "' "
	cStrQuery +=   "  AND CHY.CHY_CODIGO = '00805'"
	cStrQuery +=   "  AND C2U.C2U_FILIAL = C2T.C2T_FILIAL"
	cStrQuery +=   "  AND C2U.C2U_ID     = C2T.C2T_ID"
	cStrQuery +=   "  AND C2U.C2U_CODAJU = C2T.C2T_CODAJU"
	cStrQuery +=   "  AND C0R.C0R_FILIAL = C2U.C2U_FILIAL"
	cStrQuery +=   "  AND C0R.C0R_ID     = C2U.C2U_DOCARR"
	cStrQuery +=   "  AND C2S.D_E_L_E_T_ = ''"
	cStrQuery +=   "  AND C2T.D_E_L_E_T_ = ''"
	cStrQuery +=   "  AND C2U.D_E_L_E_T_ = ''"
	cStrQuery +=   "  AND C0R.D_E_L_E_T_ = ''"
	cStrQuery +=   "  AND CHY.D_E_L_E_T_ = ''"

	cStrQuery := ChangeQuery(cStrQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cStrQuery),cQryAls,.T.,.T.)

Return
