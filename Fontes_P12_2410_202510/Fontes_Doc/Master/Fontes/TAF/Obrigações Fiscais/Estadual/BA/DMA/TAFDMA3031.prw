#Include 'Protheus.ch' 

Function TAFDMA3031(aWizard as array, aFiliais as array)

	Local cTxtSys  	    := CriaTrab( , .F. ) + ".TXT"
	Local nHandle   	:= MsFCreate( cTxtSys )
	Local cStrTxt		:= ""
	Local lInscrUnic	:= (If (("1" $ aWizard[2][3]),.T.,.F.))
	Local cData 	   	:= ""

	If(!lInscrUnic)
		Return
	EndIf

	Begin Sequence

		cData := Substr(aWizard[1][2],4,4) + Substr(aWizard[1][2],1,2)

		cStrTxt		:= DMAReg3031("0", cData, aFiliais)
		cStrTxt		+= DMAReg3031("1", cData, aFiliais)

		If cStrTxt != ""
			WrtStrTxt( nHandle, cStrTxt )
			GerTxtDMA( nHandle, cTxtSys, aFiliais[1] + "_TIPO3031")
		EndIf

		Recover
		lFound := .F.
	End Sequence

Return

Static Function DMAReg3031(cIndOper as char, cPeriodo as char, aFiliais as array)

Local cStrQuery	:= ""
Local cAlias1	:= GetNextAlias()
Local cStrTxt	:= ""
Local cFilAux 	:= cFilAnt

cFilAnt := aFiliais[1]

cStrQuery := " SELECT "
cStrQuery += "  	T2D.T2D_CODMUN CODMUN, "
cStrQuery += "  	SUM(C2F.C2F_BASE) BASE, "
cStrQuery += "  	SUM(C2F.C2F_VLISEN) VLISEN "
cStrQuery += "  FROM " + RetSqlName('C20') + " C20 "
cStrQuery += "  	INNER JOIN " + RetSqlName('C2F') + " C2F ON C2F.C2F_FILIAL = '" + xFilial('C2F') + "' AND C2F.C2F_CHVNF = C20.C20_CHVNF AND C2F.C2F_CODTRI = '000002' AND C2F.D_E_L_E_T_ = '' "
cStrQuery += "  	INNER JOIN " + RetSqlName('C1H') + " C1H ON C1H.C1H_FILIAL = '" + xFilial('C1H') + "' AND C1H.C1H_ID = C20.C20_CODPAR AND C1H.C1H_UF = '000005' AND C1H.D_E_L_E_T_ = '' "	
cStrQuery += "  	INNER JOIN " + RetSqlName('T2D') + " T2D ON T2D.T2D_FILIAL = '" + xFilial('T2D') + "' AND T2D.T2D_IDMUN = C1H.C1H_CODMUN AND T2D.T2D_TPCLAS = 'DMABA' AND T2D.D_E_L_E_T_ = '' "
cStrQuery += "  WHERE C20.D_E_L_E_T_ = '' "
cStrQuery += "		AND C20.C20_FILIAL  = '" + xFilial('C20') + "' "
cStrQuery += "  	AND C20.C20_INDOPE  = '" + cIndOper + "' "
If "ORACLE" $ Upper(TcGetDB())
	cStrQuery += " AND SUBSTR(C20.C20_DTES,1,6)  = '" + cPeriodo + "' "
Else
	cStrQuery += " AND SUBSTRING(C20.C20_DTES,1,6)  = '" + cPeriodo + "' "
Endif
cStrQuery += "  GROUP BY T2D.T2D_CODMUN "

cStrQuery := ChangeQuery(cStrQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cStrQuery),cAlias1,.T.,.T.)
DbSelectArea(cAlias1)

While (cAlias1)->(!Eof())

	If (cAlias1)->BASE > 0 .OR. (cAlias1)->VLISEN > 0
		cStrTxt += (If ((cIndOper == "0"),"30","31"))
		cStrTxt += Substr(cPeriodo,1,4) //Ano de Referência
		cStrTxt += Substr(cPeriodo,5,2) //Mês de Referência
		cStrTxt += StrZero(VAL( SubStr(AllTrim(aFiliais[5]),1,9)) ,9,0) //inscrição estadual BA (9c)
		cStrTxt += (If ((cIndOper == "0"),"E","S"))
		cStrTxt += StrZero(VAL((cAlias1)->CODMUN),5,0)
		cStrTxt += StrZero((cAlias1)->BASE		* 100, 12)
		cStrTxt += StrZero((cAlias1)->VLISEN	* 100, 12)
		cStrTxt += StrZero((cAlias1)->VLISEN	* 100, 12)
		cStrTxt += CRLF
	EndIf
	(cAlias1)->(DbSkip())
EndDo

cFilAnt := cFilAux

Return cStrTxt