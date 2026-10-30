#Include 'Protheus.ch'


Function TAFDMA16(aWizard as array, aFiliais as array)

	Local cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
	Local nHandle   	:= MsFCreate( cTxtSys )
	Local cStrTxt		:= ""
	Local cData 		:= Substr(aWizard[1][2],4,4) + Substr(aWizard[1][2],1,2)

	Local nIMCSSTAnt	:= 0
	Local nICMSSTRet	:= 0
	Local nICMSSTInd	:= 0
	Local nICMSSTImp	:= 0
	Local nValDifer	:= 0


	//fnDMAReg16 1 - Código de Receita
	//fnDMAReg16 2 - Data
	//fnDMAReg16 3 - Filial

	Begin Sequence

		nIMCSSTAnt := fnDMAReg16("'1145', '1129', '1072', '2141'", cData, aFiliais)
		nICMSSTRet := fnDMAReg16("'1006', '1103', '1632', '1014', '2133'", cData, aFiliais)
		nICMSSTInd := fnDMAReg16("'0903'", cData, aFiliais)
		nICMSSTImp := fnDMAReg16("'1187', '1218'", cData, aFiliais)
		nValDifer  := fnDMAReg16("'1959'", cData, aFiliais)

		cStrTxt += "16"                          	// 	Tipo
		cStrTxt += Substr(cData,1,4) 		 		// 	Ano de Referência
		cStrTxt += Substr(cData,5,2) 		 		// 	Mês de Referência
		cStrTxt += StrZero(VAL(aFiliais[5]),9,0)  // 	Inscrição Estadual
		cStrTxt += StrZero(nIMCSSTAnt	* 100, 12)	//	Valor ICMS Substituição Tributária por antecipação (Entradas)
		cStrTxt += StrZero(nICMSSTRet	* 100, 12)	//	Valor ICMS Substituição Tributária por retenção (saídas)
		cStrTxt += StrZero(nICMSSTInd	* 100, 12)	//	Valor ICMS Importação para Industrialização/ Comercialização
		cStrTxt += StrZero(nICMSSTImp	* 100, 12)	//	Valor ICMS Importação para imobilizado/ uso ou Consumo
		cStrTxt += StrZero(nValDifer	* 100, 12)	//	Valor diferimento
		cStrTxt += StrZero(0     	  	     , 12)	//	Valor do Imposto Recolhido - Conta Corrente -- não preencher
		cStrTxt += CRLF

		WrtStrTxt( nHandle, cStrTxt )
		GerTxtDMA( nHandle, cTxtSys, aFiliais[1] + "_TIPO16")

		Recover
		lFound := .F.
	End Sequence

Return

Static Function fnDMAReg16(cCodRec as char, cPeriodo as char, aFiliais  as array)

Local cStrQuery	:= ""
Local cAlias1	:= GetNextAlias()

Local aArray := {}

	cStrQuery := " SELECT SUM(C3N_VLROBR) VLROBR"
	cStrQuery +=	"   FROM " +  RetSqlName('C3J') + ' C3J, '
	cStrQuery +=					RetSqlName('C3N') + ' C3N  '
	cStrQuery += "  WHERE C3J.C3J_FILIAL             = '" + aFiliais[1] + "' "
	cStrQuery += "    AND SUBSTRING(C3J_DTINI,1,6)   = '" + cPeriodo + "' "
	cStrQuery += "    AND SUBSTRING(C3J_DTFIN,1,6)   = '" + cPeriodo + "' "
	cStrQuery += "    AND C3N.C3N_FILIAL             =  C3J.C3J_FILIAL "
	cStrQuery += "    AND C3N.C3N_ID 					=  C3J.C3J_ID "
	cStrQuery += "    AND C3N.C3N_CODREC				IN (" + cCodRec + ") "
	cStrQuery += "    AND C3J.D_E_L_E_T_ 				= '' "
	cStrQuery += "    AND C3N.D_E_L_E_T_ 				= '' "

	cStrQuery := ChangeQuery(cStrQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cStrQuery),cAlias1,.T.,.T.)
	DbSelectArea(cAlias1)

	Return (cAlias1)->VLROBR

	(cAlias1)->(DbCloseArea())

Return 0


