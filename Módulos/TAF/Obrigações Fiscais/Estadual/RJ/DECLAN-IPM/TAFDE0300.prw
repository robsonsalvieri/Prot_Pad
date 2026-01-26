#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFDE0300
Gera o reguitro 0300 da DECLANN-IPM
@parametro aWizard, nValor, nCont
@author 
@since 
@version 1.0
@Altered by Pister in 31/10/2024 Refatoração
/*/ 
//-------------------------------------------------------------------- 

Function TAFDE0300(aWizard, nValor, nCont)

Local nPos     	as numeric
Local aJusNat  	as array
Local aValor    as array
Local nValorAju as numeric

Local cTxtSys    := CriaTrab( , .F. ) + ".TXT"
Local nHandle    := MsFCreate( cTxtSys )
Local cStrTxt    := ""
Local cAliasQry  := GetNextAlias()
Local cAnoReg 	 := LTRIM(Substr(aWizard[2][1],1,4))
Local cAnoAnt	 := LTRIM(STR(VAL(cAnoReg)-1))
Local cPerEstIn1 := ""
Local cPerEstIn2 := ""
Local cPerEstFn1 := ""
Local cPerEstFn2 := ""
Local cRegime1	 := ""
Local cRegime2	 := ""
Local cAliasEst  := GetNextAlias()
Local cAliasReg1 := GetNextAlias()
Local cAliasReg2 := GetNextAlias()

Private cTipRegim := ""

Begin Sequence
	aJusNat   := {}
	nPos      := 0
	aValor    := {}
	nValorAju := 0
	cStrTxt   := ""
	cTipRegim := "N"

	DbSelectArea("T39")
	DbSetOrder(2)
	If DbSeek(xFilial("T39") + Substr(aWizard[2][1],1,4))                                                                                                   
		//Regime do Registro	- N = Normal, Estimativa e Outros;S = Simples Nacional
		If T39->T39_TIPREG == '2'
			cTipRegim := "N"		
		Else
			cTipRegim := "S"			
		EndIf
	EndIf

	BeginSql Alias cAliasQry
	  SELECT T54_CHAVE,
	         T57_VLCHAV
	    FROM %table:T56% T56
	      INNER JOIN %table:T57% T57 ON T57.T57_FILIAL = T56.T56_FILIAL AND T57.T57_ID = T56.T56_ID
	      INNER JOIN %table:T54% T54 ON T54.T54_FILIAL = %xfilial:T54%  AND T54.T54_ID = T57.T57_IDCHAV
	      INNER JOIN %table:C09% C09 ON C09.C09_FILIAL = %xfilial:C09%  AND C09.C09_ID = T56.T56_IDUF
	    WHERE T56.T56_FILIAL = %xfilial:T56%
	      AND T56.T56_DTINI >= %Exp:aWizard[2,1]+"0101"%
	      AND T56.T56_DTFIN <= %Exp:aWizard[2,1]+"1231"%
	      AND C09.C09_UF 	  =  %Exp:'RJ'%
	      AND T54.T54_CHAVE IN ( %Exp:"IPI_ENTR_MAT_PR"% , 				//Item 3
	      						 %Exp:"IMPTO_ENTR_RETID"% , 			//Item 5
	      						 %Exp:"IPI_NAO_INTEG_BC_ICMS_SAID"% , 	//Item 8
	      						 %Exp:"IPI_INTEG_BC_ICMS_SAID"% , 		//Item 9
	      						 %Exp:"IMPTO_SAID_RETID"%  				//Item 11
	      						 )
	      AND T56.%NotDel%
	      AND T57.%NotDel%
	      AND C09.%NotDel%
	EndSql

	aAdd(aJusNat, {10, getLinDecl("00010", 0)})
	aAdd(aJusNat, {25, getLinDecl("00025", 0)})
	aAdd(aJusNat, {5,  getLinDecl("00005", 0)})
	aAdd(aJusNat, {29, getLinDecl("00029", 0)})
	aAdd(aJusNat, {24, getLinDecl("00024", 0)})

	While (cAliasQry)->(!Eof())
		aNatur := {}
		aNatur := StrToKArr( (cAliasQry)->T57_VLCHAV, ";" )
	    For nPos := 1 To Len(aNatur)
	    	If (Empty(AllTrim(aNatur[nPos])))
	    		ADel(aNatur, nPos)
			EndIf
	    Next nPos
	    
	    If Empty(aNatur[1])
	    	(cAliasQry)->(DbSkip())
			Loop
		EndIf
		cNatur := getStrNatur( aNatur )

	    Do Case
	    	Case Alltrim((cAliasQry)->T54_CHAVE) == "IPI_ENTR_MAT_PR" //00010
	    		nValorAju := getDeclAjNat(cNatur, aWizard[2,1], "05")
	    		nValor    += nValorAju
    			aJusNat[1][2] :=  getLinDecl("00010", nValorAju)
	    	Case Alltrim((cAliasQry)->T54_CHAVE) == "IMPTO_ENTR_RETID" //00025
	    		nValorAju := getDeclAjNat(cNatur, aWizard[2,1], "04")
	    		nValor    += nValorAju
    			aJusNat[2][2]  := getLinDecl("00025", nValorAju)
	    	Case Alltrim((cAliasQry)->T54_CHAVE) == "IPI_NAO_INTEG_BC_ICMS_SAID" //00005
	    		nValorAju := getDeclAjNat(cNatur, aWizard[2,1], "05")
	    		nValor    += nValorAju
	    		aJusNat[3][2]  := getLinDecl("00005", nValorAju)
	    	Case Alltrim((cAliasQry)->T54_CHAVE) == "IPI_INTEG_BC_ICMS_SAID" //00029
	    		nValorAju := getDeclAjNat(cNatur, aWizard[2,1], "05")
	    		nValor    += nValorAju
    			aJusNat[4][2]  := getLinDecl("00029", nValorAju)
	    	Case Alltrim((cAliasQry)->T54_CHAVE) == "IMPTO_SAID_RETID" //00024
	    		nValorAju := getDeclAjNat(cNatur, aWizard[2,1], "04")
	    		nValor    += nValorAju
    			aJusNat[5][2]  := getLinDecl("00024", nValorAju)
	    EndCase
	    (cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())

	//"00007"
	aValor    := getDeclAjCfop("1406', '2406', '1551', '2551', '3551', '1552', '2552', '1553', '2553', '3553', '1554', '2554', '1555', '2555", aWizard[2,1])
	nValorAju := 0
	nValor    += aValor[1, 1]

	cStrTxt += getLinDecl("00007", aValor[1, 1])
	cStrTxt := addContLin(cStrTxt, @nCont)

	//"00008"
	aValor    := getDeclAjCfop("1407', '2407', '1556', '2556', '1557', '2557", aWizard[2,1])
	nValorAju := 0
	nValor    += aValor[1, 1]

	cStrTxt += getLinDecl("00008", aValor[1, 1])
	cStrTxt := addContLin(cStrTxt, @nCont)

	//"00010"
	if Len(aJusNat) > 0
		nPos := aScan( aJusNat, {|x| x[1] == 10 })
		If nPos > 0
			cStrTxt += aJusNat[nPos][2]
			cStrTxt := addContLin(cStrTxt, @nCont)
		EndIf
	EndIf

	//"00036"
	aValor    := getDeclAjCfop("1949', '2949', '3949", aWizard[2,1])
	nValorAju := 0
	If (Len(aValor) > 0)
		nValorAju := aValor[1, 1] - aValor[2, 1]
	EndIf

	cCfop := "1126', '2126', '3126', '1128', '2128', '3128', '1154', '2154', '2415', '1904', '2904', "
	cCfop += "'1414', '2414', '1415', '1505', '1506', '2505', '2506', '1601', '1602', '1603', '1604', '1605', '1663', '1664', "	
	cCfop += "'2663', '2664', '1901', '1902', '1903', '2901', '2902', '2903', '1905', '1906', '1907', '1908', '1909', '2905', " 
	cCfop += "'2906', '2907', '2908', '2909', '1912', '1913', '1914', '1915', '1916', '1917', '1918', '1919', '1920', '1921', " 
	cCfop += "'1922', '1923', '1924', '1925', '2912', '2913', '2914', '2915', '2916', '2917', '2918', '2919', '2920', '2921', " 
	cCfop += "'2922', '2923', '2924', '2925', '1926', '1933', '2933', '3930 "

	aValor := getDeclAjCfop(cCfop, aWizard[2,1])
	If (Len(aValor) > 0)
		nValorAju  += aValor[1, 1]
	EndIf

	nValor  += nValorAju
	cStrTxt += getLinDecl("00036", nValorAju)
	cStrTxt := addContLin(cStrTxt, @nCont)

	//"00025"
	if Len(aJusNat) > 0
		nPos := aScan( aJusNat, {|x| x[1] == 25 })
		If nPos > 0
			cStrTxt += aJusNat[nPos][2]
			cStrTxt := addContLin(cStrTxt, @nCont)
		EndIf
	EndIf

	//"00002"
	aValor     := getDeclAjCfop("5412', '6412', '5551', '6551', '7551', '5552', '6552', '5553', '6553', '7553', '5554', '5555', '6554', '6555", aWizard[2,1])
	nValorAju  := 0
	nValor     += aValor[1, 1]

	cStrTxt += getLinDecl("00002", aValor[1, 1])
	cStrTxt := addContLin(cStrTxt, @nCont)

	//"00003"
	aValor     := getDeclAjCfop("5413', '6413', '5556', '6556', '7556', '5557', '6557", aWizard[2,1])
	nValorAju  := 0
	nValor     += aValor[1, 1]

	cStrTxt += getLinDecl("00003", aValor[1, 1])
	cStrTxt := addContLin(cStrTxt, @nCont)

	//"00005"
	if Len(aJusNat) > 0
		nPos := aScan( aJusNat, {|x| x[1] == 5 } )
		If nPos > 0
			cStrTxt += aJusNat[nPos][2]
			cStrTxt := addContLin(cStrTxt, @nCont)
		EndIf
	EndIf

	//"00029"
	if Len(aJusNat) > 0
		nPos := aScan( aJusNat, {|x| x[1] == 29 } )
		If nPos > 0
			cStrTxt += aJusNat[nPos][2]
			cStrTxt := addContLin(cStrTxt, @nCont)
		EndIf
	EndIf

	//"00037"
	aValor     := getDeclAjCfop("5949', '6949', '7949", aWizard[2,1])
	nValorAju  := 0
	If (Len(aValor) > 0)
		nValorAju := aValor[1, 1] - aValor[2, 1]
	EndIf

	cCfop := "5210', '6210', '7210', '5414', '6414', '5415', '6415', '5657',"
	cCfop += "'6657', '5904', '6904', '5504', '5505', '6504', '6505', '5601', '5602', '5605', '5606',"
	cCfop += "'5663', '5664', '5665', '5666', '6663', '6664', '6665', '6666', '5901', '5902', '5903',"
	cCfop += "'6901', '6902', '6903', '5905', '5906', '5907', '5908', '5909', '6905', '6906', '6907', '6908', '6909', '5912',"
	cCfop += "'5913', '5914', '5915', '5916', '5917', '5918', '5919', '5920', '5921', '5922', '5923', '5924', '6912', "
	cCfop += "'5913', '5914', '5915', '5916', '5917', '5918', '5919', '5920', '5921', '5922', '5923', '5924', "
	cCfop += "'6913', '6914', '6915', '6916', '6917', '6918', '6919', '6920', '6921', '6922', '6923', '6924', "
	cCfop += "'6925', '5926', '5929', '6929', '5933', '6933', '7930"

	aValor := getDeclAjCfop(cCfop, aWizard[2,1])
	If (Len(aValor) > 0)
		nValorAju += aValor[1, 1]
	EndIf

	nValor  += nValorAju
	cStrTxt += getLinDecl("00037", nValorAju)
	cStrTxt := addContLin(cStrTxt, @nCont)

	//"00024"
	if Len(aJusNat) > 0
		nPos := aScan( aJusNat, {|x| x[1] == 24 } )
		If nPos > 0
			cStrTxt += aJusNat[nPos][2]
			cStrTxt := addContLin(cStrTxt, @nCont)
		EndIf
	EndIf

	//=========================== I N V E N T A R I O ===========================
	/* Regime da Empresa - Inventário (Estoque Inicial) */
	BeginSql Alias cAliasReg1
		SELECT T39_TIPREG TP_REG
		  FROM %table:T39% T39
		 WHERE T39.T39_FILIAL = %xFilial:T39%
		   AND T39.T39_ANOREF = %Exp:cAnoAnt%
		   AND T39.%NotDel%
		ORDER BY T39_PERFIN DESC
	EndSql

	cRegime1 := "N"

	If !(cAliasReg1)->(Eof())
		If (cAliasReg1)->TP_REG != '2'
			cRegime1 := "S"
		EndIf
	EndIf

	/* Regime da Empresa - Inventário (Estoque Final) */
	BeginSql Alias cAliasReg2
		SELECT T39_TIPREG TP_REG
		  FROM %table:T39% T39
		 WHERE T39.T39_FILIAL = %xFilial:T39%
		   AND T39.T39_ANOREF = %Exp:cAnoReg%
		   AND T39.%NotDel%
		ORDER BY T39_PERFIN DESC
	EndSql

	cRegime2 = "N"

	If !(cAliasReg2)->(Eof())
		If (cAliasReg2)->TP_REG != '2'
			cRegime2 := "S"
		EndIf
	EndIf

	/* Estoque Inicial */
	cPerEstIn1	:= cAnoAnt+'0101'
	cPerEstIn2	:= cAnoAnt+'1231'

	/* Estoque Final */
	cPerEstFn1	:= cAnoReg+'0101'
	cPerEstFn2	:= cAnoReg+'1231'

	If aWizard[2][10] == "1 - Sim"
		cWhereCpl := "% AND  C2M.C2M_CODIGO IN ('00','01','02','03','04','05','06','10', '99') "
		cWhereCpl += "%"
	Else
		cWhereCpl := "% AND  C2M.C2M_CODIGO IN ('00','01','02','03','04','05','06','10') %"
	EndIf

	BeginSql Alias cAliasEst
		SELECT 1 IND_EST, /* Estoque Inicial */
			SUM(C5B.C5B_VITEM) VAL_INVENT
  		FROM %table:C5B% C5B
   		INNER JOIN %table:C5A% C5A ON C5A.C5A_FILIAL = C5B.C5B_FILIAL AND C5A.C5A_ID = C5B.C5B_ID AND C5A.%NotDel%
   		INNER JOIN %table:C1L% C1L ON C1L.C1L_FILIAL = C5B.C5B_FILIAL AND C1L.C1L_ID = C5B.C5B_CODITE AND C1L.%NotDel%
   		INNER JOIN %table:C2M% C2M ON C2M.C2M_ID     = C1L.C1L_TIPITE AND C2M.%NotDel%
 		 WHERE C5A.C5A_FILIAL = %xFilial:C5A%
 		   AND C5A.C5A_DTINV BETWEEN %Exp:cPerEstIn1% AND %Exp:cPerEstIn2%
 		   AND C5B.C5B_INDPRO <> 2
   		   AND C5B.%NotDel%
   		   %Exp: cWhereCpl %
   		UNION
   		SELECT 2 IND_EST, /* Estoque Final */
   				SUM(C5B.C5B_VITEM) VAL_INVENT
  		  FROM %table:C5B% C5B
   		INNER JOIN %table:C5A% C5A ON C5A.C5A_FILIAL = C5B.C5B_FILIAL AND C5A.C5A_ID = C5B.C5B_ID AND C5A.%NotDel%
   		INNER JOIN %table:C1L% C1L ON C1L.C1L_FILIAL = C5B.C5B_FILIAL AND C1L.C1L_ID = C5B.C5B_CODITE AND C1L.%NotDel%
   		INNER JOIN %table:C2M% C2M ON C2M.C2M_ID     = C1L.C1L_TIPITE AND C2M.%NotDel%
 		 WHERE C5A.C5A_FILIAL = %xFilial:C5A%
 		   AND C5A.C5A_DTINV BETWEEN %Exp:cPerEstFn1% AND %Exp:cPerEstFn2%
 		   AND C5B.C5B_INDPRO <> 2
   		   AND C5B.%NotDel%
   		   %Exp: cWhereCpl %
	EndSql

	While !(cAliasEst)->(Eof())
		cStrTxt += "0300"			 //Tipo - Valor Fixo: 0300
		cStrTxt += "000000000000001" //Número Seqüencial da Declaração - Valor Fixo: 000000000000001

		//Regime do Registro - N = Normal, Estimativa e Outros; S = Simples Nacional
		If (cAliasEst)->IND_EST = 1
			cStrTxt += cRegime1
		Else
			cStrTxt += cRegime2
		EndIf

		If (cAliasEst)->IND_EST = 1
			cStrTxt += "00013" //Código do Ajuste - Estoque Inicial
		Else
			cStrTxt += "00014" //Código do Ajuste - Estoque Final
		EndIf

		nValor  += (cAliasEst)->VAL_INVENT
		cStrTxt += StrTran(StrZero((cAliasEst)->VAL_INVENT,16,2),".","") //Valor do Ajuste
		cStrTxt += SPACE(315) //Filler - Preencher com espaços em branco

		nCont++
		cStrTxt += StrZero(nCont,5) //Número da linha
		cStrTxt += CRLF

		(cAliasEst)->(DbSkip())
	EndDo
	(cAliasEst)->(DbCloseArea())

	/* Ajuste 00031: não foi prevista implementação */
	cStrTxt += getLinDecl("00031", 0)
	cStrTxt := addContLin(cStrTxt, @nCont)

	WrtStrTxt( nHandle, cStrTxt )

	GerTxtDERJ( nHandle, cTxtSys, "0300" )

	Recover
	lFound := .F.
End Sequence

Return

Static Function getStrNatur (aNatur as array)

	Local cNatur as char
	Local nPos   as Numeric

	cNatur := ""
	For nPos := 1 To Len(aNatur)
		cNatur += "'" + AllTrim(aNatur[nPos]) + "',"
	Next nPos
	cNatur := Substr(cNatur, 2, Len(cNatur) - 3)

Return cNatur

Static Function getLinDecl(cCodAjust as char, nValorAju as numeric)

	Local cStrTxt as char

	cStrTxt := ""
	cStrTxt += "0300" //Tipo - Valor Fixo: 0200
	cStrTxt += "000000000000001" //Número Seqüencial da Declaração - Valor Fixo: 000000000000001
	cStrTxt += cTipRegim
	cStrTxt += cCodAjust
	cStrTxt += StrTran(StrZero(nValorAju, 16, 2),".","")
	cStrTxt := Left(cStrTxt,48) + space(315) //Filler - Preencher com espaços em branco

Return cStrTxt

Static Function addContLin(cStrTxt as char, nCont as Numeric)

	nCont++
 	cStrTxt += StrZero(nCont,5) //Número da linha - Número da linha
 	cStrTxt += CRLF

Return cStrTxt

Static Function getDeclAjCfop(cCfop as char, cPeriodo as char)

	Local cAliasCFOP := GetNextAlias()
	Local aArray 	 := {}

	BeginSql Alias cAliasCFOP
		SELECT SUM(C6Z.C6Z_VLCONT) VLCONTBL,
		       SUM(C6Z.C6Z_BASE) VLBASE
		  FROM %table:C2S% C2S
		   INNER JOIN %table:C6Z% C6Z ON C6Z.C6Z_FILIAL = C2S.C2S_FILIAL AND C6Z.C6Z_ID = C2S.C2S_ID AND C6Z.%NotDel%
		   INNER JOIN %table:C0Y% C0Y ON C0Y.C0Y_FILIAL = %xFilial:C0Y% AND C0Y.C0Y_ID = C6Z.C6Z_CFOP AND C0Y.C0Y_CODIGO IN (%Exp:cCfop%) AND C0Y.%NotDel%
		WHERE C2S.C2S_FILIAL = %xFilial:C2S%
		  AND SUBSTRING(C2S.C2S_DTINI,1,4) = %Exp:cPeriodo%
		  AND C2S.%NotDel%
	EndSql

	While !(cAliasCFOP)->(Eof())
		aAdd(aArray, { (cAliasCFOP)->VLCONTBL } )
		aAdd(aArray, { (cAliasCFOP)->VLBASE } )
		(cAliasCFOP)->(DbSkip())
	EndDo
	(cAliasCFOP)->(DbCloseArea())

Return aArray

Static Function getDeclAjNat(cNatur as char, cPeriodo as char, cImpto as char)

	Local cAliasNatu := GetNextAlias()
	Local nValorAju  := 0

	If Empty(cNatur)
		Return 0
	EndIf

	If cImpto == '04'
		BeginSql Alias cAliasNatu
			SELECT	SUM(T6V.T6V_IMPCRD) IMPCRD
			  FROM %table:C3J% C3J
			   INNER JOIN %table:T6V% T6V ON T6V.T6V_FILIAL = C3J.C3J_FILIAL AND T6V.T6V_ID = C3J.C3J_ID AND T6V.%NotDel%
			   INNER JOIN %table:C1N% C1N ON C1N.C1N_FILIAL = T6V.T6V_FILIAL AND C1N.C1N_ID = T6V.T6V_NATOPE AND C1N.C1N_CODNAT IN (%Exp:cNatur%) AND C1N.%NotDel%
			WHERE C3J.C3J_FILIAL = %xFilial:C3J%
			  AND SUBSTRING(C3J.C3J_DTINI,1,4) = %Exp:cPeriodo%
			  AND C3J.%NotDel%
		EndSql
	Else
		BeginSql Alias cAliasNatu
			SELECT	SUM(T6X.T6X_IMPCRD) IMPCRD
			  FROM %table:C2N% C2N
			   INNER JOIN %table:T6X% T6X ON T6X.T6X_FILIAL = C2N.C2N_FILIAL AND T6X.T6X_ID = C2N.C2N_ID AND T6X.%NotDel%
			   INNER JOIN %table:C1N% C1N ON C1N.C1N_FILIAL = T6X.T6X_FILIAL AND C1N.C1N_ID = T6X.T6X_NATOPE AND C1N.C1N_CODNAT IN (%Exp:cNatur%) AND C1N.%NotDel%
			WHERE C2N.C2N_FILIAL = %xFilial:C2N%
			  AND SUBSTRING(C2N.C2N_DTINI,1,4) = %Exp:cPeriodo%
			  AND C2N.%NotDel%
		EndSql
	EndIf

	While !(cAliasNatu)->(Eof())
		nValorAju := (cAliasNatu)->IMPCRD
		(cAliasNatu)->(DbSkip())
	EndDo
	(cAliasNatu)->(DbCloseArea())

Return nValorAju
