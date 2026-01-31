#Include 'Protheus.ch' 

Function TAFDMA1011(aWizard, aFiliais)

Local cTxtSys		:= CriaTrab( , .F. ) + ".TXT"
Local nHandle   	:= MsFCreate( cTxtSys )
Local cStrTxt		:= ""
Local cData 		:= Substr(aWizard[1][2],4,4) + Substr(aWizard[1][2],1,2)
Private nTotOpe 	:= 0
Private nTotBase	:= 0
Private nTotIsen	:= 0
Private nTotOutr	:= 0

Begin Sequence


	//Entradas Do Estado
	cStrTxt := fnDMAReg10("10", "0", "01", "1101,1102,1111,1113,1116,1117,1118,1120,1121,1122,1124,1125,1126,1401,1403,1501,1651,1652",  cData, aFiliais) //compras
	cStrTxt += fnDMAReg10("10", "0", "02", "1151, 1152, 1153, 1154, 1408, 1409, 1658, 1659", cData, aFiliais) //Transferências
	cStrTxt += fnDMAReg10("10", "0", "03", "1201,1202,1203,1204,1205,1206,1207,1208,1209,1410,1411,1503,1504,1660,1661,1662",  cData, aFiliais) //Devoluções/Anulações
	cStrTxt += fnDMAReg10("10", "0", "04", "1251,1252,1253,1254,1255,1256,1257",  cData, aFiliais) //Energia Elétrica
	cStrTxt += fnDMAReg10("10", "0", "05", "1301,1302,1303,1304,1305,1306",  cData, aFiliais) //Comunicações
	cStrTxt += fnDMAReg10("10", "0", "06", "1351,1352,1353,1354,1355,1356,1360,1931,1932",  cData, aFiliais) //Transportes
	cStrTxt += fnDMAReg10("10", "0", "07", "1406,1551,1552,1553,1554,1555,1604",  cData, aFiliais) //Ativo Imobilizado
	cStrTxt += fnDMAReg10("10", "0", "08", "1407,1556,1557,1653",  cData, aFiliais) //Mat. Para Uso ou Consumo
	cStrTxt += fnDMAReg10("10", "0", "09", "1414,1415,1451,1452,1901,1902,1903,1904,1905,1906,1907,1908,1909,1910,1911,1912,1913,1914,1915,1916,1917,1918,1919,1920,1921,1922,1923,1924,1925,1926,1933,1663,1664,1949",  cData, aFiliais) //Outras

	//Entradas De Outras Unidades da Federação
	cStrTxt += fnDMAReg10("10", "1", "01", "2101,2102,2111,2113,2116,2117,2118,2120,2121,2122,2124,2125,2126,2401,2403,2501,2651,2652",  cData, aFiliais) //compras
	cStrTxt += fnDMAReg10("10", "1", "02", "2151,2152,2153,2154,2408,2409,2658,2659", cData, aFiliais) //Transferências
	cStrTxt += fnDMAReg10("10", "1", "03", "2201,2202,2203,2204,2205,2206,2207,2208,2209,2410,2411,2503,2504,2660,2661,2662",  cData, aFiliais) //Devoluções/Anulações
	cStrTxt += fnDMAReg10("10", "1", "04", "2251,2252,2253,2254,2255,2256,2257",  cData, aFiliais) //Energia Elétrica
	cStrTxt += fnDMAReg10("10", "1", "05", "2301,2302,2303,2304,2305,2306",  cData, aFiliais) //Comunicações
	cStrTxt += fnDMAReg10("10", "1", "06", "2351,2352,2353,2354,2355,2356,2931,2932",  cData, aFiliais) //Transportes
	cStrTxt += fnDMAReg10("10", "1", "07", "2406,2551,2552,2553,2554,2555",  cData, aFiliais) //Ativo Imobilizado
	cStrTxt += fnDMAReg10("10", "1", "08", "2407,2556,2557,2653",  cData, aFiliais) //Mat. Para Uso ou Consumo
	cStrTxt += fnDMAReg10("10", "1", "09", "2414,2415,2505,2901,2902,2903,2904,2905,2906,2907,2908,2909,2910,2911,2912,2913,2914,2915,2916,2917,2918,2919,2920,2921,2922,2923,2924,2925,2663,2664,2949,2933",  cData, aFiliais) //Outras

	// Entradas de Exportação
	cStrTxt += fnDMAReg10("10", "2", "01", "3101 ,3102 ,3126 ,3127 ,3651 ,3652, 3653",  cData, aFiliais) //compras
	cStrTxt += fnDMAReg10("10", "2", "02", "3201 ,3202 ,3205 ,3206 ,3207 ,3211 ,3503",  cData, aFiliais) //Devoluções/Anulações
	cStrTxt += fnDMAReg10("10", "2", "03", "3251 ,3301 ,3351 ,3352 ,3353 ,3354 ,3355 ,3356",  cData, aFiliais) //Comunicações
	cStrTxt += fnDMAReg10("10", "2", "04", "3551 ,3553",  cData, aFiliais) //Ativo Imobilizado
	cStrTxt += fnDMAReg10("10", "2", "05", "3556, 3653",  cData, aFiliais) //Mat. Para Uso ou Consumo
	cStrTxt += fnDMAReg10("10", "2", "06", "3930 ,3949",  cData, aFiliais) //Outras

	//Gera linha de totais dos registros 10 
	cStrTxt += TotDma1011( '10', cData, aFiliais )

	//Zero as variaveis para totalizar o 11
	nTotOpe := 0
	nTotBase := 0
	nTotIsen := 0
	nTotOutr := 0

	//Saídas Para dentro do Estado
	cStrTxt += fnDMAReg10("11", "0", "01", "5101 ,5102 ,5103 ,5104 ,5105 ,5106 ,5111 ,5112 ,5113 ,5114 ,5115 ,5116 ,5117 ,5118 ,5119 ,5120 ,5122 ,5123 ,5124 ,5125 ,5401 ,5402 ,5403 ,5405 ,5501 ,5502 ,5651 ,5652 ,5653 ,5654 ,5655 ,5656 ,5933",  cData, aFiliais) //vendas
	cStrTxt += fnDMAReg10("11", "0", "02", "5151 ,5152 ,5153 ,5155 ,5156 ,5408 ,5409 ,5552 ,5557 ,5658 ,5659", cData, aFiliais) //Transferências
	cStrTxt += fnDMAReg10("11", "0", "03", "5201 ,5202 ,5205 ,5206 ,5207 ,5208 ,5209 ,5210 ,5410 ,5411 ,5412 ,5413 ,5503 ,5553 ,5556 ,5660 ,5661 ,5662",  cData, aFiliais) //Devoluções/Anulações
	cStrTxt += fnDMAReg10("11", "0", "04", "5251 ,5252 ,5253 ,5254 ,5255 ,5256 ,5257 ,5258",  cData, aFiliais) //Energia Elétrica
	cStrTxt += fnDMAReg10("11", "0", "05", "5301 ,5302 ,5303 ,5304 ,5305 ,5306 ,5307",  cData, aFiliais) //Comunicações
	cStrTxt += fnDMAReg10("11", "0", "06", "5351 ,5352 ,5353 ,5354 ,5355 ,5356 ,5357 ,5359 ,5360",  cData, aFiliais) //Transportes
	cStrTxt += fnDMAReg10("11", "0", "07", "5414 ,5415 ,5451 ,5505 ,5551 ,5554 ,5555 ,5901 ,5902 ,5903 ,5904 ,5905 ,5906 ,5907 ,5908 ,5909 ,5910 ,5911 ,5912 ,5913 ,5914 ,5915 ,5916 ,5917 ,5918 ,5919 ,5920 ,5921 ,5922 ,5923 ,5924 ,5925 ,5926 ,5927 ,5928 ,5929 ,5931 ,5932 ,5934 ,5949 ,5657 ,5663 ,5664 ,5665 ,5666",  cData, aFiliais) //Outras

	//Saídas Para Outras Unidades da Federação
	cStrTxt += fnDMAReg10("11", "1", "01", "6101 ,6102 ,6103 ,6104 ,6105 ,6106 ,6107 ,6108 ,6109 ,6110 ,6111 ,6112 ,6113 ,6114 ,6115 ,6116 ,6117 ,6118 ,6119 ,6120 ,6122 ,6123 ,6124 ,6125 ,6401 ,6402 ,6403 ,6404 ,6501 ,6502 ,6651 ,6652 ,6653 ,6654 ,6655 ,6656",  cData, aFiliais) //vendas
	cStrTxt += fnDMAReg10("11", "1", "02", "6151 ,6152 ,6153 ,6155 ,6156 ,6408 ,6409 ,6552 ,6557 ,6658 ,6659", cData, aFiliais) //Transferências
	cStrTxt += fnDMAReg10("11", "1", "03", "6201 ,6202 ,6205 ,6206 ,6207 ,6208 ,6209 ,6210 ,6410 ,6411 ,6412 ,6413 ,6503 ,6553 ,6556 ,6660 ,6661 ,6662",  cData, aFiliais) //Devoluções/Anulações
	cStrTxt += fnDMAReg10("11", "1", "04", "6251 ,6252 ,6253 ,6254 ,6255 ,6256 ,6257 ,6258",  cData, aFiliais) //Energia Elétrica
	cStrTxt += fnDMAReg10("11", "1", "05", "6301 ,6302 ,6303 ,6304 ,6305 ,6306 ,6307",  cData, aFiliais) //Comunicações
	cStrTxt += fnDMAReg10("11", "1", "06", "6351 ,6352 ,6353 ,6354 ,6355 ,6356 ,6357 ,6359 ,6360",  cData, aFiliais) //Transportes
	cStrTxt += fnDMAReg10("11", "1", "07", "6414 ,6415 ,6504 ,6551 ,6554 ,6555 ,6901 ,6902 ,6903 ,6904 ,6905 ,6906 ,6907 ,6908 ,6909 ,6910 ,6911 ,6912 ,6913 ,6914 ,6915 ,6916 ,6917 ,6918 ,6919 ,6920 ,6921 ,6922 ,6923 ,6924 ,6925 ,6929 ,6931 ,6932 ,6949 ,6657 ,6663 ,6664 ,6665 ,6666",  cData, aFiliais) //Outras

	// Saídas para o Exterior
	cStrTxt += fnDMAReg10("11", "2", "01", "7101 ,7102 ,7105 ,7106 ,7127 ,7651 ,7654",  cData, aFiliais) //vendas
	cStrTxt += fnDMAReg10("11", "2", "02", "7201 ,7202 ,7205 ,7206 ,7207 ,7210 ,7211 ,7553 ,7556",  cData, aFiliais) //Devoluções/Anulações
	cStrTxt += fnDMAReg10("11", "2", "03", "7251 ,7301 ,7358",  cData, aFiliais) //Comunicações
	cStrTxt += fnDMAReg10("11", "2", "04", "7501 ,7551 ,7930 ,7949",  cData, aFiliais) //Outras

	//Gera linha de totais dos registros 11
	cStrTxt += TotDma1011( '11', cData, aFiliais )
	
	WrtStrTxt( nHandle, cStrTxt )
	GerTxtDMA( nHandle, cTxtSys, aFiliais[1] + "_TIPO1011")

	Recover
	lFound := .F.

End Sequence

Return

Static Function fnDMAReg10(cTipo, cNumDet, cTipoDet, cCfop, cPeriodo, aFiliais)

Local cStrQuery	:= ""
Local cAlias10	:= GetNextAlias()
Local cStrTxt	:= ""
Local cIndOper  := (If ((cTipo == "10"),"0","1"))
Local cFilAux	:= cFilAnt

//Coloca os CFOPS passados por parâmetro entre aspas simples para que funcione na clausula "IN" da query.
cCfop := "'" + strtran(cCfop,",","','") + "'"

cFilAnt = aFiliais[1]

cStrQuery := " SELECT "
cStrQuery += "		SUM(C2F.C2F_VLOPE) VLOPE, "
cStrQuery += "		SUM(C2F.C2F_BASE) BASE, "
cStrQuery += "		SUM(C2F.C2F_VLISEN) VLISEN, "
cStrQuery += "		SUM(C2F.C2F_VLOUTR) VLOUTR "
cStrQuery += " FROM " + RetSqlName('C20') + " C20 "
cStrQuery += "		INNER JOIN " + RetSqlName('C1H') + " C1H ON C1H.C1H_FILIAL = '" + xFilial('C1H') + "' AND C1H.C1H_ID = C20.C20_CODPAR AND "

If cNumDet == "0"
	cStrQuery += " C1H.C1H_UF = '000005' "
Else
	cStrQuery += " C1H.C1H_UF != '000005' "
EndIF

cStrQuery += "	AND C1H.D_E_L_E_T_ = '' "
cStrQuery += "		INNER JOIN " + RetSqlName('C2F') + " C2F ON C2F.C2F_FILIAL = '" + xFilial('C2F') + "' AND C2F.C2F_CHVNF = C20.C20_CHVNF AND C2F.C2F_CODTRI = '000002' AND C2F.D_E_L_E_T_ = '' "
cStrQuery += "		INNER JOIN " + RetSqlName('C0Y') + " C0Y ON C0Y.C0Y_FILIAL = '" + xFilial('C0Y') + "' AND C0Y.C0Y_ID = C2F.C2F_CFOP AND C0Y.C0Y_CODIGO IN (" + cCfop + ") AND C0Y.D_E_L_E_T_ = '' "
cStrQuery += " WHERE  C20.D_E_L_E_T_ = '' "
cStrQuery += "		AND C20.C20_FILIAL =  '" + xFilial('C20') + "' "
cStrQuery += "		AND C20.C20_INDOPE    			   = '" + cIndOper + "' "

If "ORACLE" $ Upper(TcGetDB())
	cStrQuery += "    AND SUBSTR(C20.C20_DTES,1,6)  = '" + cPeriodo + "' "
Else
	cStrQuery += "    AND SUBSTRING(C20.C20_DTES,1,6)  = '" + cPeriodo + "' "
Endif

cStrQuery := ChangeQuery(cStrQuery) 

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cStrQuery),cAlias10,.T.,.T.)
DbSelectArea(cAlias10)

While (cAlias10)->(!Eof())
	If (cAlias10)->VLOPE > 0 .OR. (cAlias10)->VLISEN > 0 .OR. (cAlias10)->VLOUTR > 0

		cStrTxt += cTipo                          // Tipo
		cStrTxt += Substr(cPeriodo,1,4) 		 	// Ano de Referência
		cStrTxt += Substr(cPeriodo,5,2) 		 	// Mês de Referência
		cStrTxt += StrZero(VAL( SubStr(AllTrim(aFiliais[5]),1,9)) ,9,0) //inscrição estadual BA (9c)
		cStrTxt += (If ((cTipo == "10"),"E","S")) // Status de entrada/saída
		cStrTxt += cNumDet                        // Número do Detalhamento
		cStrTxt += cTipoDet                       // Tipo do Detalhamento
		cStrTxt += StrZero((cAlias10)->VLOPE * 100, 12) //Valor Contábil
		cStrTxt += StrZero((cAlias10)->BASE   * 100, 12) //Valor Base
		cStrTxt += StrZero((cAlias10)->VLISEN * 100, 12) //Valor Isentas
		cStrTxt += StrZero((cAlias10)->VLOUTR * 100, 12) //Valor Outras
		cStrTxt += CRLF

		nTotOpe += (cAlias10)->VLOPE * 100
		nTotBase += (cAlias10)->BASE   * 100
		nTotIsen += (cAlias10)->VLISEN * 100
		nTotOutr += (cAlias10)->VLOUTR * 100			
	
	EndIf
	
	(cAlias10)->(DbSkip())

EndDo

cFilAnt := cFilAux

Return cStrTxt

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TAFDMA1011

Esta rotina tem como objetivo realizar a criação....

@Param cVersion = Versão
    nTotOpe = Valor Contábil
    nTotBase = Valor Base
    nTotIsen = Valor Isentas
    nTotOutr = Valor Outras

@Author Carlos Eduardo Nonato Da Silva
@Since 22/02/2018
@Version 1.0

@Return ( lRet )

/*/
//--------------------------------------------------------------------------------------------------
Static Function TotDma1011(cTipo, cPeriodo, aFiliais)
Local cStrTxt := ''

cStrTxt := cTipo                         // Tipo
cStrTxt += Substr(cPeriodo,1,4) 		 // Ano de Referência
cStrTxt += Substr(cPeriodo,5,2) 		 // Mês de Referência
cStrTxt += StrZero(VAL( SubStr(AllTrim(aFiliais[5]),1,9)) ,9,0) //inscrição estadual BA (9c)
cStrTxt += (If ((cTipo == "10"),"E","S"))// Status de entrada/saída			
cStrTxt += "9"                         	 // Número do Detalhamento
cStrTxt += "99"                       	 // Tipo do Detalhamento
cStrTxt += StrZero(nTotOpe, 12) //Valor Contábil
cStrTxt += StrZero(nTotBase, 12) //Valor Base
cStrTxt += StrZero(nTotIsen, 12) //Valor Isentas
cStrTxt += StrZero(nTotOutr, 12) //Valor Outras
cStrTxt += CRLF	

Return cStrTxt
