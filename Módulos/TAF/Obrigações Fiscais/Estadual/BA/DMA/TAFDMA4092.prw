#Include 'Protheus.ch'

Function TAFDMA4092(aWizard as array, aFiliais as array, aArrayExc as array, aArrayDed as array)

	Local cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
	Local nHandle   := MsFCreate( cTxtSys )
	Local cStrTxt	:= ""
	Local cData 	:= Substr(aWizard[1][2],4,4) + Substr(aWizard[1][2],1,2)

	Local cNaturEx 	:= ""
	Local cNaturD 	:= ""
	Local cNaturND 	:= ""

	Local nX := 0

	Begin Sequence

		If "1" $ aWizard[3][3]
			For nX := 1 to Len(aArrayExc)
				If aArrayExc[nX,1] == aFiliais[1]
					cNaturEx += "'" + aArrayExc[nX,2] + "',"
				EndIf
			Next

			If (len(cNaturEx) > 0)
				cNaturEx := Substr(cNaturEx,1, len(cNaturEx) - 1)
			EndIf
		Endif

		If "1" $ aWizard[3][4]

			If (len(aArrayDed) > 0)
				For nX := 1 to Len(aArrayDed)
					If aArrayDed[nX,1] == aFiliais[1]
						If(aArrayDed[nX][2] == "S")
							cNaturD 	+= "'" + cValToChar(aArrayDed[nX][3]) + "' ,"
						Else
							cNaturND	+= "'" + cValToChar(aArrayDed[nX][3]) + "' ,"
						EndIf
					EndIf
				Next
			EndIf

			If(len(cNaturD) > 0)
				cNaturD := Substr(cNaturD,1,len(cNaturD) - 1)
			EndIf

			If(len(cNaturND) > 0)
				cNaturND := Substr(cNaturND,1,len(cNaturND) - 1)
			EndIf
		EndIf
		//fnDMARegAp 1 - Indicador de operação (0 - Normal/1 - Exceção/2 - Dedutível, não dedutível
		//fnDMARegAp 2 - Tipo (Registro)
		//fnDMARegAp 3 - CFOP
		//fnDMARegAp 4 - CST
		//fnDMARegAp 5 - Naturezas
		//fnDMARegAp 6 - Data
		//fnDMARegAp 7 - Filial

		//ENTRADAS DO ESTADO
		cStrTxt += fnDMARegAp(1, "40", "'1908', '1909', '1949'", "'41'", cNaturEx	, cData, aFiliais)
		cStrTxt += fnDMARegAp(0, "41", "'1901', '1902', '1903', '1915', '1916'", "'50'", "", cData, aFiliais)
		cStrTxt += fnDMARegAp(0, "42", "'1912', '1913'" , "'50'", "", cData, aFiliais)
		cStrTxt += fnDMARegAp(0, "43", "'1914'", "'50'" , "", cData, aFiliais)
		cStrTxt += fnDMARegAp(0, "44", "'1949'", "'50'", "", cData, aFiliais)
		cStrTxt += fnDMARegAp(0, "45", "'1414', '1415', '1904'", "'00', '10', '20', '60', '70'"	, "", cData, aFiliais)
		cStrTxt += fnDMARegAp(0, "46", "'1905', '1907'", "'00', '10', '20', '60', '70'", "", cData, aFiliais)
		cStrTxt += fnDMARegAp(0, "47", "'1920', '1921'", "'00', '10', '20', '60', '70'", "", cData, aFiliais)
		cStrTxt += fnDMARegAp(2, "48", "'1553', '1554', '1555', '1910', '1911', '1917', '1918', '1919', '1922', '1923', '1924', '1925', '1926', '1949'", "'40', '51', '90'", cNaturD, cData, aFiliais)
		cStrTxt += fnDMARegAp(2, "49", "'1451', '1452', '1949'", ""	, cNaturND, cData, aFiliais)
		//---------------------------------------------------------------------------------------

		//ENTRADAS DE OUTRAS UNIDADES DA FEDERAÇÃO
		cStrTxt += fnDMARegAp(1, "50", "'2908', '2909', '2949'", "'41'", cNaturEx	, cData, aFiliais)
		cStrTxt += fnDMARegAp(0, "51", "'2901', '2902', '2903', '2915', '2916'", "'50'", "", cData, aFiliais)
		cStrTxt += fnDMARegAp(0, "52", "'2912', '2913'", "'50'", ""	, cData, aFiliais)
		cStrTxt += fnDMARegAp(0, "53", "'2914'", "'50'", "", cData, aFiliais)
		cStrTxt += fnDMARegAp(0, "54", "'2949'", "'50'", "", cData, aFiliais)
		cStrTxt += fnDMARegAp(0, "55", "'2414', '2415', '2904'", "'00', '10', '20', '60', '70'", "", cData, aFiliais)
		cStrTxt += fnDMARegAp(0, "56", "'2905', '2907'", "'00', '10', '20', '60', '70'", "", cData, aFiliais)
		cStrTxt += fnDMARegAp(0, "57", "'2920', '2921'", "'00', '10', '20', '60', '70'", "", cData, aFiliais)
		cStrTxt += fnDMARegAp(2, "58", "'2553', '2554', '2555', '2910', '2911', '2917', '2918','2919', '2922', '2923', '2924', '2925', '2926', '2949'", "'40', '51', '90'", cNaturD, cData, aFiliais)
		cStrTxt += fnDMARegAp(2, "59", "'2949'", "", cNaturND, cData, aFiliais)
		//---------------------------------------------------------------------------------------

		//ENTRADAS DO EXTERIOR
		cStrTxt += fnDMARegAp(0, "60", "'3949'", "'41'", cNaturEx, cData, aFiliais)
		cStrTxt += fnDMARegAp(0, "61", "'3101', '3102', '3126', '3127'", "'50'", "", cData, aFiliais)
		cStrTxt += fnDMARegAp(0, "62", "'3949'", "'50', '90'", "", cData, aFiliais)
		cStrTxt += fnDMARegAp(2, "63", "'3553', '3930', '3949'", "'40', '51', '90'", cNaturD, cData, aFiliais)
		cStrTxt += fnDMARegAp(2, "64", "'3127', '3949'", "", cNaturND, cData, aFiliais)
		cStrTxt += fnDMARegAp(0, "65", "'5551', '5552', '5557', '5553', '5556'", "", "", cData, aFiliais)
		//---------------------------------------------------------------------------------------

		//SAÍDAS PARA O ESTADO
		cStrTxt += fnDMARegAp(1, "66", "'5908', '5909', '5949'", "'41'", cNaturEx, cData, aFiliais)
		cStrTxt += fnDMARegAp(0, "67", "'5901', '5902', '5903', '5915', '5916'"	, "'50'"		, ""		, cData, aFiliais)
		cStrTxt += fnDMARegAp(0, "68", "'5912', '5913'", "'50'", ""	, cData, aFiliais)
		cStrTxt += fnDMARegAp(0, "69", "'5914'", "'50'", "", cData, aFiliais)
		cStrTxt += fnDMARegAp(0, "70", "'5949'", "'50', '90'", "", cData, aFiliais)
		cStrTxt += fnDMARegAp(0, "71", "'5904', '5915', '5916'", "'00', '10', '20', '60', '70'"	, "", cData, aFiliais)
		cStrTxt += fnDMARegAp(0, "72", "'5905', '5906', '5907'", "'00', '10', '20', '60', '70'"	, "", cData, aFiliais)
		cStrTxt += fnDMARegAp(0, "73", "'5920', '5921'", "'00', '10', '20', '60', '70'", "", cData, aFiliais)
		cStrTxt += fnDMARegAp(2, "74", "'5554', '5555', '5910', '5911', '5917', '5918', '5919', '5922', '5923', '5924', '5925', '5926', '5929', '5932'", "'40', '51', '90','00'", cNaturD, cData, aFiliais)
		cStrTxt += fnDMARegAp(2, "75", "'5451', '5927', '5928', '5931', '5949'", "", cNaturND, cData, aFiliais)
		//---------------------------------------------------------------------------------------

		//SAÍDAS PARA OUTRAS UNIDADES DA FEDERAÇÃO
		cStrTxt += fnDMARegAp(0, "76", "'6412', '6413', '6551', '6552', '6553', '6556', '6557'"	,"", "", cData, aFiliais)
		cStrTxt += fnDMARegAp(1, "77", "'6908', '6909', '6949'", "'41'", cNaturEx	, cData, aFiliais)
		cStrTxt += fnDMARegAp(0, "78", "'6901', '6902', '6903', '6915', '6916'", "'50'", "", cData, aFiliais)
		cStrTxt += fnDMARegAp(0, "79", "'6912', '6913'", "'50'", ""	, cData, aFiliais)
		cStrTxt += fnDMARegAp(0, "80", "'6914'", "'50'", "", cData, aFiliais)
		cStrTxt += fnDMARegAp(0, "81", "'6949'", "'50', '90'", "", cData, aFiliais)
		cStrTxt += fnDMARegAp(0, "82", "'6904', '6414', '6415'", "'00', '10', '20', '60', '70'"	, "", cData, aFiliais)
		cStrTxt += fnDMARegAp(0, "83", "'6905', '6906', '6907'", "'00', '10', '20', '60', '70'"	, "", cData, aFiliais)
		cStrTxt += fnDMARegAp(0, "84", "'6920', '6921'", "'00', '10', '20', '60', '70'"	, "", cData, aFiliais)
		cStrTxt += fnDMARegAp(2, "85", "'6554', '6555', '6910', '6911', '6917', '6918', '6919', '6922', '6923', '6924', '6925', '6929', '6932', '6949'", "'40', '51', '90'", cNaturD, cData, aFiliais)
		cStrTxt += fnDMARegAp(2, "86", "'6931', '6949'", "", cNaturND, cData, aFiliais)
		//---------------------------------------------------------------------------------------

		//SAÍDAS PARA O EXTERIOR
		cStrTxt += fnDMARegAp(0, "87", "'7551', '7553', '7556', '7949'", "", "", cData, aFiliais)
		cStrTxt += fnDMARegAp(1, "88", "'7949'", "'41'", cNaturEx, cData, aFiliais)
		cStrTxt += fnDMARegAp(0, "89", "'7949'", "'90'", "", cData, aFiliais)
		cStrTxt += fnDMARegAp(0, "90", "'7949'", "'50'", "", cData, aFiliais)
		cStrTxt += fnDMARegAp(2, "91", "'7930', '7949'", "'40', '51', '90'", cNaturD, cData, aFiliais)
		cStrTxt += fnDMARegAp(2, "92", "'7949'", "", cNaturND, cData, aFiliais)
		//---------------------------------------------------------------------------------------

		WrtStrTxt( nHandle, cStrTxt )

		GerTxtDMA( nHandle, cTxtSys, aFiliais[1] + "_TIPO4092")

		Recover
		lFound := .F.
	End Sequence

Return

Static Function fnDMARegAp(nIndicOper as numeric, cTipo as char, cCfop as char, cCst as char, cNaturEx as char, cPeriodo as char, aFiliais as array)

	Local cStrQuery	:= ""
	Local cAliasApur	:= GetNextAlias()
	Local cStrTxt		:= ""

	cStrQuery += " SELECT SUM(C2F_BASE) BASE, SUM(C2F_VLISEN) VLISEN, SUM(C2F_VLOUTR) VLOUTR "
	cStrQuery += " FROM " + RetSqlName( "C35" ) + " C35 "
	cStrQuery += " INNER JOIN " + RetSqlName( "C20" ) + " C20 "
	cStrQuery += "     ON C35.C35_FILIAL = C20.C20_FILIAL "
	cStrQuery += "     AND C35.C35_CHVNF = C20.C20_CHVNF "

	If "ORACLE" $ Upper( TcGetDB( ) )
		cStrQuery += " AND SUBSTR(C20.C20_DTES,1,6)  = '" + cPeriodo + "' "
	Else
		cStrQuery += " AND SUBSTRING(C20.C20_DTES,1,6)	= '" + cPeriodo + "' "
	Endif

	cStrQuery += "     AND C35.D_E_L_E_T_ = C20.D_E_L_E_T_ "

		//valida o CST recebido por parametro
	If (cCst != "")
		cStrQuery += " INNER JOIN " + RetSqlName( "C14" ) + " C14 "
		cStrQuery += "     ON C35.C35_CST = C14.C14_ID "
		cStrQuery += "     AND C14.C14_CODIGO	IN (" + cCst  + ") "
		cStrQuery += "     AND C14.D_E_L_E_T_ = ' ' "
	EndIf

	cStrQuery += " INNER JOIN " + RetSqlName( "C30" ) + " C30 "
	cStrQuery += "     ON C35.C35_CHVNF = C30.C30_CHVNF "
	cStrQuery += "     AND C35.C35_NUMITE = C30.C30_NUMITE "
	cStrQuery += "     AND C35.C35_CODITE = C30.C30_CODITE "
	cStrQuery += "     AND C35.D_E_L_E_T_ = C30.D_E_L_E_T_ "

	If nIndicOper != 0

		/* 
			Essa variavel está sendo utilizada para receber as operações de natureza:

			Se nIndicOper == 1 -> Excessão
			Se nIndicOper == 2 -> Dedutiveis e não dedutíveis
		*/
		If !Empty( cNaturEx ) 

			cStrQuery += "     AND C30.C30_NATOPE "

			if nIndicOper == 1 // Excessão

				cStrQuery += " NOT IN (" + cNaturEx + ") "
			Else
				cStrQuery += " IN (" + cNaturEx + ") "
			EndIf
		Endif	
	EndIf

	cStrQuery += " INNER JOIN " + RetSqlName( "C0Y" ) + " C0Y "
    cStrQuery += "     ON C0Y.C0Y_ID = C30.C30_CFOP "
    cStrQuery += "     AND C0Y.D_E_L_E_T_ = ' ' "
	cStrQuery += " INNER JOIN " + RetSqlName( "C2F" ) + " C2F "
    cStrQuery += "     ON C35.C35_CHVNF = C2F.C2F_CHVNF "
    cStrQuery += "     AND C30.C30_CFOP = C2F.C2F_CFOP "
	cStrQuery += "     AND C30.C30_CODSER = C2F.C2F_CODSER "
	cStrQuery += "     AND C35.C35_CST = C2F.C2F_CST "
    cStrQuery += "     AND C35.C35_CODTRI = C2F.C2F_CODTRI "
    cStrQuery += "     AND C35.C35_ALIQ = C2F.C2F_ALIQ "
    cStrQuery += "     AND C35.C35_BASE = C2F.C2F_BASE "
    cStrQuery += "     AND C35.D_E_L_E_T_ = C2F.D_E_L_E_T_ "
	cStrQuery += " WHERE C35_FILIAL = '" + aFiliais[1] + "' "
    cStrQuery += "     AND C35.C35_CODTRI = '000002' "
    cStrQuery += "     AND C35.D_E_L_E_T_ = ' ' "
	cStrQuery += "     AND C0Y.C0Y_CODIGO  IN (" + cCfop + ") "
 
	cStrQuery := ChangeQuery(cStrQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cStrQuery),cAliasApur,.T.,.T.)
	DbSelectArea(cAliasApur)

	While (cAliasApur)->(!Eof())
		If (cAliasApur)->BASE > 0 .OR. (cAliasApur)->VLISEN > 0 .OR. (cAliasApur)->VLOUTR > 0
			cStrTxt := cTipo
			cStrTxt += Substr(cPeriodo,1,4) //Ano de Referência
			cStrTxt += Substr(cPeriodo,5,2) //Mês de Referência
			cStrTxt += StrZero(VAL( SubStr(AllTrim(aFiliais[5]),1,9)) ,9,0) //inscrição estadual BA (9c)
			cStrTxt += StrZero((cAliasApur)->BASE		* 100, 12)
			cStrTxt += StrZero((cAliasApur)->VLISEN	* 100, 12)
			cStrTxt += StrZero((cAliasApur)->VLOUTR	* 100, 12)
			cStrTxt += CRLF
		EndIf
		(cAliasApur)->(DbSkip())
	EndDo

Return cStrTxt