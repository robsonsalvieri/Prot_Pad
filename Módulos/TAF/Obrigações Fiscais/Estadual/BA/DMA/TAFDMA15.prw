#Include 'Protheus.ch'


Function TAFDMA15(aWizard as array, aFiliais as array)

Local cTxtSys  	    := CriaTrab( , .F. ) + ".TXT"
Local nHandle   	:= MsFCreate( cTxtSys )
Local cStrTxt		:= ""
Local cData 		:= Substr(aWizard[1][2],4,4) + Substr(aWizard[1][2],1,2)

Local nValCtaDed	:= 0
Local nValImpRec	:= 0
Local nValTotDeb	:= 0
Local nValTotCre	:= 0
Local nValSdoDev	:= 0
Local nValSdoCre	:= 0
Local nValDifAlq	:= 0

Begin Sequence

	DbSelectArea("C2S")
	C2S->(DbSetOrder(1)) // C2S_FILIAL + C2S_TIPAPU 
	If C2S->(DbSeek(xFilial("C2S") + '0' )) // 0 - Apuração
		While C2S->(!EOF()) .AND. xFilial("C2S") == aFiliais[1]

			If (!(	Substr(DtoS(C2S->C2S_DTINI),1,6) == cData .AND. ;
					Substr(DtoS(C2S->C2S_DTFIN),1,6) == cData))
				C2S->(dbSkip())
				Loop
			Endif

			nValCtaDed := C2S->C2S_TOTDED
			nValImpRec := C2S->C2S_TOTREC
		C2S->(dbSkip())
		EndDo
	EndIf

	nValTotDeb := fnDMAReg15("1", cData, aFiliais)
	nValTotCre := fnDMAReg15("0", cData, aFiliais)
	nValDifAlq := fnDMAAlqDf(cData, aFiliais)

    nValTotDeb := nValTotDeb + nValDifAlq // Seguindo as regras do validador o total de débito é: Saídas Tributadas + Outros Débitos + Estorno de Crédito + Diferença de Alíquota.

	nValSdoDev := (If((nValTotDeb > nValTotCre), nValTotDeb - nValTotCre, 0))
	nValSdoCre := (If((nValTotCre > nValTotDeb), nValTotCre - nValTotDeb, 0))

	cStrTxt += "15"                                              // 1- Tipo
	cStrTxt += Substr( cData, 1, 4 )                             // 2 - Ano de Referência
	cStrTxt += Substr( cData, 5, 2 )                             // 3 - Mês de Referência
	cStrTxt += StrZero( VAL( aFiliais[5]), 9, 0 )                // 4 - Inscrição Estadual
	cStrTxt += StrZero( nValCtaDed * 100, 12 )				     // 5 - Valor Conta Corrente Deduções
	cStrTxt += StrZero( fnValNegt( nValImpRec ) * 100, 12 )      // 6 - Valor Conta Corrente Imposto a Recolher
	cStrTxt += StrZero( ( nValTotDeb ) * 100, 12 )               // 7 - Valor Total do Débito
	cStrTxt += StrZero( nValTotCre * 100, 12 )                   // 8 - Valor Total de Crédito
	cStrTxt += StrZero( fnValNegt( nValSdoDev ) * 100, 12 )      // 9 - Valor do saldo Devedor
	cStrTxt += StrZero( fnValNegt( nValSdoCre ) * 100, 12 )      // 10 - Valor do saldo Credor
	cStrTxt += StrZero( nValDifAlq * 100, 12 )                   // 11 - Valor de Diferencial de Alíquota
	cStrTxt += CRLF

	WrtStrTxt( nHandle, cStrTxt )
	GerTxtDMA( nHandle, cTxtSys, aFiliais[1] + "_TIPO15")

	Recover
	lFound := .F.
End Sequence

Return

Static Function fnValNegt(nValor as numeric)

If nValor < 0
	Return nValor * -1
EndIf

return nValor

Static Function fnDMAReg15(cIndOper as char, cPeriodo as char, aFiliais as array)
Local nRet := 0

DbSelectArea("C2S")		
C2S->(DbSetOrder(2))
If C2S->(DbSeek(xFilial("C2S")))
	While C2S->(!EOF()) .AND. xFilial("C2S") == aFiliais[1]
					
		If (!(	Substr(DtoS(C2S->C2S_DTINI),1,6) == cPeriodo .AND. ;
				Substr(DtoS(C2S->C2S_DTFIN),1,6) == cPeriodo))
			C2S->(dbSkip())
			Loop
		Endif

		if cIndOper == '0' // Crédito
			nRet := C2S->(C2S_TOTCRE + C2S_TAJUCR + C2S_ESTDEB )
		else
			nRet := C2S->(C2S_TOTDEB + C2S_TAJUDB + C2S_ESTCRE )
		endif	
		
		C2S->(dbSkip())
	EndDo
EndIf		

Return nRet

Static Function fnDMAAlqDf(cPeriodo as char, aFiliais as array)
	Local cStrQuery	:= ""
	Local cNovoAlias  := GetNextAlias()
	Local nValor := 0

	cStrQuery += " SELECT "
	cStrQuery += "     SUM( C2T.C2T_VLRAJU ) C2T_VLRAJU "
	cStrQuery += " FROM " + RetSqlName( "C2T" ) + " C2T "
	cStrQuery += " INNER JOIN " + RetSqlName( "C2S" ) + " C2S "
	cStrQuery += "     ON C2T.C2T_ID = C2S.C2S_ID "
	cStrQuery += "     AND C2T.C2T_FILIAL = C2S.C2S_FILIAL "
	cStrQuery += "     AND C2T.D_E_L_E_T_ = C2S.D_E_L_E_T_ "
	cStrQuery += " INNER JOIN " + RetSqlName( "C1A" ) + " C1A "
	cStrQuery += "     ON C2T.C2T_CODAJU = C1A.C1A_ID  "
	cStrQuery += "     AND C2T.D_E_L_E_T_ = C1A.D_E_L_E_T_ "
	cStrQuery += " WHERE C2S.C2S_FILIAL = '" + aFiliais[1] + "' "
	cStrQuery += "     AND SUBSTRING( C2S.C2S_DTFIN, 1, 6 ) = '" + cPeriodo + "' "

	/*
		Estrutura do código de lançamento de ajuste:

		BA050002

		BA   - UF
		0    - Tipo Apuração ( 0-ICMS, 1-ICMS ST, 2-ICMS DIFAL, 3-FCP DIFAL )
		5    - Utilização ( 0-Outros debitos, 1-Estorno de creditos, 2-Outros creditos, 3-Estorno de debitos, 4-Deduções, 5-Debitos especiais, 9-Controle de creditos )
		0002 - Sequência do código de lançamento

		Foi considerado os códigos de lançamentos com o Tipo de apuração ICMS e Utilização outros débitos e debitos especiais devido esses códigos conterem a palavra "Diferencial"
	*/
	cStrQuery += "     AND ( SUBSTRING( C1A_CODIGO, 1, 4 ) = 'BA00' OR SUBSTRING( C1A_CODIGO, 1, 4 ) = 'BA05' ) "
	cStrQuery += "     AND C2T.D_E_L_E_T_ = ' ' "

	cStrQuery := ChangeQuery(cStrQuery)

	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cStrQuery),cNovoAlias,.T.,.T.)
	DbSelectArea(cNovoAlias)

	While (cNovoAlias)->(!Eof())
		nValor += (cNovoAlias)->C2T_VLRAJU
		(cNovoAlias)->(DbSkip())
	EndDo

Return nValor