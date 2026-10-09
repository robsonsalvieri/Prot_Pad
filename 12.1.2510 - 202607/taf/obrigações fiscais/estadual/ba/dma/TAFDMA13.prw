#Include 'Protheus.ch' 

Function TAFDMA13( aWizard as array, aFiliais  as array )

	Local cTxtSys     := CriaTrab( , .F. ) + ".TXT"
	Local nHandle     := MsFCreate( cTxtSys )
	Local cStrTxt     := ""
	Local cData       := Substr(aWizard[1][2],4,4) + Substr(aWizard[1][2],1,2)
	Local cInscri     := StrZero(VAL( SubStr(AllTrim(aFiliais[5]),1,9)) ,9,0)

	Local nCompAtiv   := 0
	Local nAquisMat   := 0
	Local nTransAtiv  := 0
	Local nTransMat   := 0
	Local nEntRemes   := 0
	Local nOutrEnt    := 0
	Local nTotEntSaid := 0

	//fnDMAReg13 1 - CFOP
	//fnDMAReg13 2 - Data
	//fnDMAReg13 3 - Filial

	Begin Sequence
		//ENTRADAS
		nCompAtiv  := fnDMAReg13( "'1406','1551','2406','2551','3551'", cData, aFiliais )
		nAquisMat  := fnDMAReg13( "'1407', '1556', '2407', '2556', '3556','1557','1653'", cData, aFiliais )
		nTransAtiv := fnDMAReg13( "'1552','2552'", cData, aFiliais )
		nTransMat  := fnDMAReg13( "'1557','2557'", cData, aFiliais )
		nEntRemes  := fnDMAReg13( "'1414', '1415', '1901', '1902', '1903', '1904', '1915', '1916', '2414', '2415', '2901', '2902', '2903', '2904', '2915', '2916', '3949'", cData, aFiliais )
		nOutrEnt   := fnDMAReg13( "'1553','1554','1555','1905','1906','1907','1908','1909','1910','1911','1912','1913','1914','1917'," + ;
								"'1918','1919','1920','1921','1922','1923','1924','1925','1926','1949','2553','2554','2555','2905'," + ;
								"'2906','2907','2908','2909','2910','2911','2912','2913','2914','2922','2923','2924','2925','2949'," + ;
								"'3553','3930','3949'", cData, aFiliais )
								
		nTotEntSaid	:= nCompAtiv + nAquisMat + nTransAtiv + nTransMat + nEntRemes + nOutrEnt

		cStrTxt += "13"                             // 1  - Tipo
		cStrTxt += Substr( cData, 1, 4 )            // 2  - Ano de Referência
		cStrTxt += Substr( cData, 5, 2 )            // 3  - Mês de Referência
		cStrTxt += cInscri                          // 4  - inscrição estadual BA (9c)
		cStrTxt += "E"                              // 5  - Indicador de Operação
		cStrTxt += StrZero( nCompAtiv   * 100, 12 ) // 6  - Valor Compras para o Ativo Imobilizado
		cStrTxt += StrZero( nAquisMat   * 100, 12 ) // 7  - Valor Aquisição de Material para Uso ou Consumo
		cStrTxt += StrZero( nTransAtiv  * 100, 12 ) // 8  - Valor Transferências para o Ativo Imobilizado
		cStrTxt += StrZero( nTransMat   * 100, 12 ) // 9  - Valor Transferência de Material para uso ou consumo
		cStrTxt += StrZero( nEntRemes   * 100, 12 ) // 10 - Valor Entradas e Retorno e/ou saídas e remessas simbólicas de insumos para industrialização
		cStrTxt += StrZero( nOutrEnt    * 100, 12 ) // 11 - Valor outras entradas e aquisições de serviços e/ou saídas e prestações de serviços não especificados
		cStrTxt += StrZero( nTotEntSaid * 100, 12 )	// 12 - Valor Total de Entrada ou de Saída
		cStrTxt += CRLF

		//SAÍDAS
		nEntRemes := fnDMAReg13( "'5414','5415','5901','5902','5903','5904','5915','5916','6414','6415','6901','6902','6903','6904','6915','6916','7949'", cData, aFiliais )
		nOutrEnt  := fnDMAReg13( "'5412','5413','5551','5552','5553','5554','5555','5556','5557','5905','5906','5907','5908','5909'," + ;
								"'5910','5911','5912','5913','5914','5915','5916','5917','5918','5919','5920','5921','5922','5923'," + ;
								"'5924','5925','5926','5929','5932','6412','6413','6551','6552','6553','6554','6555','6556'," + ;
								"'6557','6905','6906','6907','6908','6909','6910','6911','6912','6913','6914','6915','6916','6917'," + ;
								"'6918','6919','6920','6921','6922','6923','6924','6925','6929','6932','6949','7551','7553','7556'," + ;
								"'7930','7949'", cData, aFiliais )

		nTotEntSaid	:= nEntRemes + nOutrEnt

		cStrTxt += "13"                             // 1  - Tipo
		cStrTxt += Substr( cData, 1, 4 )            // 2  - Ano de Referência
		cStrTxt += Substr( cData, 5, 2 )            // 3  - Mês de Referência
		cStrTxt += cInscri                          // 4  - inscrição estadual BA (9c)
		cStrTxt += "S"                              // 5  - Indicador de Operação
		cStrTxt += StrZero( 0           * 100, 12 )	// 6  - Valor Compras para o Ativo Imobilizado
		cStrTxt += StrZero( 0           * 100, 12 )	// 7  - Valor Aquisição de Material para Uso ou Consumo
		cStrTxt += StrZero( 0           * 100, 12 )	// 8  - Valor Transferências para o Ativo Imobilizado
		cStrTxt += StrZero( 0           * 100, 12 )	// 9  - Valor Transferência de Material para uso ou consumo
		cStrTxt += StrZero( nEntRemes   * 100, 12 )	// 10 - Valor Entradas e Retorno e/ou saídas e remessas simbólicas de insumos para industrialização
		cStrTxt += StrZero( nOutrEnt    * 100, 12 )	// 11 - Valor outras entradas e aquisições de serviços e/ou saídas e prestações de serviços não especificados
		cStrTxt += StrZero( nTotEntSaid	* 100, 12 )	// 12 - Valor Total de Entrada ou de Saída
		cStrTxt += CRLF

		IF cStrTxt != ""
			WrtStrTxt( nHandle, cStrTxt )
			GerTxtDMA( nHandle, cTxtSys, aFiliais[1] + "_TIPO13" )
		EndIF

		Recover
		lFound := .F.
	End Sequence

Return

Static Function fnDMAReg13( cCfop, cPeriodo, aFiliais )

	Local cStrQuery := ""
	Local cAlias1   := GetNextAlias()
	Local cRet      := NIL 
	Local cFilAux   := cFilAnt

	cFilAnt := aFiliais[1]

	cStrQuery := " SELECT "
	cStrQuery += " SUM(C2F_VLOPE) VLOPER "
	cStrQuery += " FROM " + RetSqlName('C2F') + " C2F "
	cStrQuery += " INNER JOIN " + RetSqlName('C20') + " C20 "
	cStrQuery += " 	ON C20.C20_FILIAL = '" + xFilial('C20') + "' " 
	cStrQuery += " 	AND C20.C20_CHVNF = C2F.C2F_CHVNF "
	cStrQuery += "  AND C20.D_E_L_E_T_ = '' "

	If "ORACLE" $ Upper(TcGetDB())
		cStrQuery += " AND SUBSTR(C20.C20_DTES,1,6)  = '" + cPeriodo + "' "
	Else
		cStrQuery += " AND SUBSTRING(C20.C20_DTES,1,6) = '" + cPeriodo + "' "
	Endif

	cStrQuery += " INNER JOIN " + RetSqlName('C0Y') + " C0Y "
	cStrQuery += " 	ON C0Y.C0Y_FILIAL = '" + xFilial('C0Y') + "' "
	cStrQuery += " 	AND C0Y.C0Y_ID = C2F.C2F_CFOP "
	cStrQuery += "  AND C0Y.C0Y_CODIGO IN (" + cCfop + ") "
	cStrQuery += "  AND C0Y.D_E_L_E_T_ = '' "
	cStrQuery += " WHERE C2F.C2F_FILIAL = '" + xFilial('C2F') +  "'"	
	cStrQuery += " 	AND C2F.C2F_CODTRI = '000002' "
	cStrQuery += " 	AND  C2F.D_E_L_E_T_ = '' "

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cStrQuery ), cAlias1, .T., .T. )
	DbSelectArea( cAlias1 )

	cRet := ( cAlias1 )->VLOPER

	( cAlias1 )->( DbCloseArea( ) )

	cFilAnt := cFilAux

Return cRet