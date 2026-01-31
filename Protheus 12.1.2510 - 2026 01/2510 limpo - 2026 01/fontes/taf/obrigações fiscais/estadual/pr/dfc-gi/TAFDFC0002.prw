#Include 'Protheus.ch'

Function TAFDFC0002(aWizard, nCont)

Local cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
Local nHandle   	:= MsFCreate( cTxtSys )
Local cStrTxt 	:= ""
Local cReg		 	:= "2"
Local aMsg			:= {}
Local cCfop		:= ""
Local nI			:= 0


Begin Sequence
	// QUADRO: 17 - ENTRADAS DE MERCADORIAS E SERVIÇOS

	//Trecho de código fonte para alimentar linha 801
	//**************** INICIO ***********************
	cCfop  := ""
	Param1 := 1101
	Param2 := 1126
	While Param1 <= Param2
		cCfop += cValtoChar(Param1) + ","
		Param1 ++
	EndDo
	cCfop += "1401, 1403, 1651, 1652, 1653"

	CriaSelect(cReg, aWizard, cCfop, '801', '826', '851', '876', @cStrTxt, @nCont) //Função Para montar select de soma das CFOP / MONTA ARQUIVO

	//Trecho de código fonte para alimentar linha 801
	//***************** FIM *************************

	//Trecho de código fonte para alimentar linha 802
	//**************** INICIO ***********************
	cCfop  := ""
	Param1 := 1201
	Param2 := 1209
	While Param1 <= Param2
		cCfop += cValtoChar(Param1) + ","
		Param1 ++
	EndDo

	Param1 := 1658
	Param2 := 1662
	While Param1 <= Param2
		cCfop += cValtoChar(Param1) + ","
		Param1 ++
	EndDo
	cCfop += "1151, 1152, 1154, 1408, 1409, 1410, 1411"

	CriaSelect(cReg, aWizard, cCfop, '802', '827', '852', '877', @cStrTxt, @nCont) //Função Para montar select de soma das CFOP / MONTA ARQUIVO

	//Trecho de código fonte para alimentar linha 802
	//***************** FIM *************************


	//Trecho de código fonte para alimentar linha 803
	//**************** INICIO ***********************
	cCfop := ""
	cCfop += "1251, 1252, 1253, 1254, 1255, 1256, 1257, 1153"
	CriaSelect(cReg, aWizard, cCfop, '803', '828', '853', '878', @cStrTxt, @nCont) //Função Para montar select de soma das CFOP / MONTA ARQUIVO

	//Trecho de código fonte para alimentar linha 803
	//***************** FIM *************************

	//Trecho de código fonte para alimentar linha 804
	//**************** INICIO ***********************
	cCfop := ""
	cCfop += "1301, 1302, 1303, 1304, 1305, 1306"
	CriaSelect(cReg, aWizard, cCfop, '804', '829', '854', '879', @cStrTxt, @nCont) //Função Para montar select de soma das CFOP / MONTA ARQUIVO

	//Trecho de código fonte para alimentar linha 804
	//***************** FIM *************************

	//Trecho de código fonte para alimentar linha 805
	//**************** INICIO ***********************
	cCfop := ""
	cCfop += "1351, 1352, 1353, 1354, 1355, 1356, 1360, 1931, 1932"
	CriaSelect(cReg, aWizard, cCfop, '805', '830', '855', '880', @cStrTxt, @nCont) //Função Para montar select de soma das CFOP / MONTA ARQUIVO

	//Trecho de código fonte para alimentar linha 805
	//***************** FIM *************************

	//Trecho de código fonte para alimentar linha 806
	//**************** INICIO ***********************
	cCfop := ""
	cCfop += "1128, 1406, 1407, 1551, 1552, 1553, 1554, 1555, 1556, 1557"
	CriaSelect(cReg, aWizard, cCfop, '806', '831', '856', '881', @cStrTxt, @nCont) //Função Para montar select de soma das CFOP / MONTA ARQUIVO

	//Trecho de código fonte para alimentar linha 806
	//***************** FIM *************************

	//Trecho de código fonte para alimentar linha 807
	//**************** INICIO ***********************
	cCfop := ""
	cCfop += "1451, 1452, 1501, 1502, 1503, 1504, 1910, 1911"
	CriaSelect(cReg, aWizard, cCfop, '807', '832', '857', '882', @cStrTxt, @nCont) //Função Para montar select de soma das CFOP / MONTA ARQUIVO

	//Trecho de código fonte para alimentar linha 807
	//***************** FIM *************************

	//Trecho de código fonte para alimentar linha 808
	//**************** INICIO ***********************
	cCfop := ""
	cCfop += "1601, 1602, 1603, 1604, 1605, 1414, 1415, 1505, 1506, 1901, 1902 ,1903, 1904, 1905, 1906, 1907, 1908, 1909"

	Param1 := 1912
	Param2 := 1926
	While Param1 <= Param2
		cCfop += cValtoChar(Param1) + ","
		Param1 ++
	EndDo

	Param1 := 1663
	Param2 := 1664
	While Param1 <= Param2
		cCfop += cValtoChar(Param1) + ","
		Param1 ++
	EndDo

	cCfop += "1933, 1934, 1949"
	CriaSelect(cReg, aWizard, cCfop, '808', '833', '858', '883', @cStrTxt, @nCont) //Função Para montar select de soma das CFOP / MONTA ARQUIVO

	//Trecho de código fonte para alimentar linha 808
	//***************** FIM *************************

	//Trecho de código fonte para alimentar linha 809
	//**************** INICIO ***********************
	cCfop := ""
	Param1 := 2101
	Param2 := 2126
	While Param1 <= Param2
		cCfop += cValtoChar(Param1) + ","
		Param1 ++
	EndDo

	Param1 := 2408
	Param2 := 2411
	While Param1 <= Param2
		cCfop += cValtoChar(Param1) + ","
		Param1 ++
	EndDo

	Param1 := 2201
	Param2 := 2209
	While Param1 <= Param2
		cCfop += cValtoChar(Param1) + ","
		Param1 ++
	EndDo

	Param1 := 2651
	Param2 := 2662
	While Param1 <= Param2
		cCfop += cValtoChar(Param1) + ","
		Param1 ++
	EndDo

	cCfop += "2401, 2403, 2151, 2152, 2154"
	CriaSelect(cReg, aWizard, cCfop, '809', '834', '859', '884', @cStrTxt, @nCont) //Função Para montar select de soma das CFOP / MONTA ARQUIVO

	//Trecho de código fonte para alimentar linha 809
	//***************** FIM *************************

	//Trecho de código fonte para alimentar linha 810
	//**************** INICIO ***********************
	cCfop := ""
	cCfop += "2251, 2252, 2253, 2254, 2255, 2256, 2257, 1153"
	CriaSelect(cReg, aWizard, cCfop, '810', '835', '860', '885', @cStrTxt, @nCont) //Função Para montar select de soma das CFOP / MONTA ARQUIVO

	//Trecho de código fonte para alimentar linha 810
	//***************** FIM *************************

	//Trecho de código fonte para alimentar linha 811
	//**************** INICIO ***********************
	cCfop := ""
	cCfop += "2301, 2302, 2303, 2304, 2305, 2306"
	CriaSelect(cReg, aWizard, cCfop, '811', '836', '861', '886', @cStrTxt, @nCont) //Função Para montar select de soma das CFOP / MONTA ARQUIVO

	//Trecho de código fonte para alimentar linha 811
	//***************** FIM *************************

	//Trecho de código fonte para alimentar linha 812
	//**************** INICIO ***********************
	cCfop := ""
	cCfop += "2351, 2352, 2353, 2354, 2355, 2356, 2931, 2932"
	CriaSelect(cReg, aWizard, cCfop, '812', '837', '862', '887', @cStrTxt, @nCont) //Função Para montar select de soma das CFOP / MONTA ARQUIVO

	//Trecho de código fonte para alimentar linha 812
	//***************** FIM *************************

	//Trecho de código fonte para alimentar linha 813
	//**************** INICIO ***********************
	cCfop := ""
	cCfop += "2128, 2406, 2407, 2551, 2552, 2553, 2554, 2555, 2556, 2557"
	CriaSelect(cReg, aWizard, cCfop, '813', '838', '863', '888', @cStrTxt, @nCont) //Função Para montar select de soma das CFOP / MONTA ARQUIVO

	//Trecho de código fonte para alimentar linha 813
	//***************** FIM *************************

	//Trecho de código fonte para alimentar linha 814
	//**************** INICIO ***********************
	cCfop := ""
	cCfop += "2501, 2502, 2503, 2504, 2910, 2911"
	CriaSelect(cReg, aWizard, cCfop, '814', '839', '864', '889', @cStrTxt, @nCont) //Função Para montar select de soma das CFOP / MONTA ARQUIVO

	//Trecho de código fonte para alimentar linha 814
	//***************** FIM *************************

	//Trecho de código fonte para alimentar linha 815
	//**************** INICIO ***********************
	cCfop := ""

	Param1 := 2912
	Param2 := 2925
	While Param1 <= Param2
		cCfop += cValtoChar(Param1) + ","
		Param1 ++
	EndDo

	cCfop += "2603, 2414, 2415, 2505, 2506, 2901, 2902, 2903, 2904, 2905, 2906, 2907, 2908, 2909, 2933, 2934, 2949, 2663, 2664"
	CriaSelect(cReg, aWizard, cCfop, '815', '840', '865', '890', @cStrTxt, @nCont) //Função Para montar select de soma das CFOP / MONTA ARQUIVO

	//Trecho de código fonte para alimentar linha 815
	//***************** FIM *************************

	//Trecho de código fonte para alimentar linha 816
	//**************** INICIO ***********************
	cCfop := ""
	Param1 := 3101
	Param2 := 3126
	While Param1 <= Param2
		cCfop += cValtoChar(Param1) + ","
		Param1 ++
	EndDo

	cCfop += "3201, 3202, 3203,3203, 3204, 3205, 3206, 3207, 3503, 3651, 3652, 3653"
	CriaSelect(cReg, aWizard, cCfop,'816' ,'841', '866', '891', @cStrTxt, @nCont) //Função Para montar select de soma das CFOP / MONTA ARQUIVO

	//Trecho de código fonte para alimentar linha 816
	//***************** FIM *************************

	//Trecho de código fonte para alimentar linha 817
	//**************** INICIO ***********************
	cCfop := ""
	cCfop += "3251"
	CriaSelect(cReg, aWizard, cCfop,'817', '842', '867', '892', @cStrTxt, @nCont)  //Função Para montar select de soma das CFOP / MONTA ARQUIVO

	//Trecho de código fonte para alimentar linha 817
	//***************** FIM *************************

	//Trecho de código fonte para alimentar linha 818
	//**************** INICIO ***********************
	cCfop := ""
	cCfop += "3301"
	CriaSelect(cReg, aWizard, cCfop, '818', '843', '868', '893', @cStrTxt, @nCont)  //Função Para montar select de soma das CFOP / MONTA ARQUIVO

	//Trecho de código fonte para alimentar linha 818
	//***************** FIM *************************

	//Trecho de código fonte para alimentar linha 819
	//**************** INICIO ***********************
	cCfop := ""
	cCfop += "3351, 3352, 3353, 3354, 3355, 3356"
	CriaSelect(cReg, aWizard, cCfop,'819', '844', '869', '894', @cStrTxt, @nCont) //Função Para montar select de soma das CFOP / MONTA ARQUIVO

	//Trecho de código fonte para alimentar linha 819
	//***************** FIM *************************

	//Trecho de código fonte para alimentar linha 820
	//**************** INICIO ***********************
	cCfop := ""
	cCfop += "3128, 3551, 3552, 3553, 3554, 3555, 3556"
	CriaSelect(cReg, aWizard, cCfop,'820', '845', '870', '895', @cStrTxt, @nCont) //Função Para montar select de soma das CFOP / MONTA ARQUIVO

	//Trecho de código fonte para alimentar linha 820
	//***************** FIM *************************

	//Trecho de código fonte para alimentar linha 821
	//**************** INICIO ***********************
	cCfop := ""
	cCfop += "3127, 3211"
	CriaSelect(cReg, aWizard, cCfop,'821', '846', '871', '896', @cStrTxt, @nCont) //Função Para montar select de soma das CFOP / MONTA ARQUIVO

	//Trecho de código fonte para alimentar linha 821
	//***************** FIM *************************

	//Trecho de código fonte para alimentar linha 822
	//**************** INICIO ***********************
	cCfop := ""
	cCfop += "3930, 3949"
	CriaSelect(cReg, aWizard, cCfop,'822', '847', '872', '897', @cStrTxt, @nCont) //Função Para montar select de soma das CFOP / MONTA ARQUIVO

	//Trecho de código fonte para alimentar linha 822
	//***************** FIM *************************

	//Linha 823 X-Estoque 01/01
	BuscaValEst(cReg,'823',aWizard[1][5],@cStrTxt)

	// QUADRO: 18 - SAÍDAS DE MERCADORIAS E SERVIÇOS
	//Trecho de código fonte para alimentar linha 901
	//**************** INICIO ***********************
	cCfop := ""
	Param1 := 5101
	Param2 := 5125
	While Param1 <= Param2
		cCfop += cValtoChar(Param1) + ","
		Param1 ++
	EndDo

	Param1 := 5401
	Param2 := 5411
	While Param1 <= Param2
		cCfop += cValtoChar(Param1) + ","
		Param1 ++
	EndDo

	Param1 := 5201
	Param2 := 5210
	While Param1 <= Param2
		cCfop += cValtoChar(Param1) + ","
		Param1 ++
	EndDo

	Param1 := 5651
	Param2 := 5656
	While Param1 <= Param2
		cCfop += cValtoChar(Param1) + ","
		Param1 ++
	EndDo

	Param1 := 5658
	Param2 := 5662
	While Param1 <= Param2
		cCfop += cValtoChar(Param1) + ","
		Param1 ++
	EndDo

	cCfop += "5667, 5151, 5152, 5155, 5156"
	CriaSelect(cReg, aWizard, cCfop, '901', '926', '951', '976', @cStrTxt, @nCont) //Função Para montar select de soma das CFOP / MONTA ARQUIVO

	//Trecho de código fonte para alimentar linha 901
	//***************** FIM *************************

	//Trecho de código fonte para alimentar linha 902
	//**************** INICIO ***********************
	cCfop := ""
	Param1 := 5251
	Param2 := 5258
	While Param1 <= Param2
		cCfop += cValtoChar(Param1) + ","
		Param1 ++
	EndDo
	cCfop += "5153"
	CriaSelect(cReg, aWizard, cCfop,'902', '927', '952', '977', @cStrTxt, @nCont) //Função Para montar select de soma das CFOP / MONTA ARQUIVO

	//Trecho de código fonte para alimentar linha 902
	//***************** FIM *************************

	//Trecho de código fonte para alimentar linha 903
	//**************** INICIO ***********************
	cCfop := ""
	cCfop += "5301, 5302, 5303, 5304, 5305,5306, 5157"
	CriaSelect(cReg, aWizard, cCfop,'903', '928', '953', '978', @cStrTxt, @nCont) //Função Para montar select de soma das CFOP / MONTA ARQUIVO

	//Trecho de código fonte para alimentar linha 903
	//***************** FIM *************************

	//Trecho de código fonte para alimentar linha 904
	//**************** INICIO ***********************
	cCfop := ""
	cCfop += "5351, 5352, 5353, 5354, 5355, 5356, 5357, 5360, 5931, 5932, 5359"
	CriaSelect(cReg, aWizard, cCfop,'904', '929', '954', '979', @cStrTxt, @nCont) //Função Para montar select de soma das CFOP / MONTA ARQUIVO

	//Trecho de código fonte para alimentar linha 904
	//***************** FIM *************************

	//Trecho de código fonte para alimentar linha 905
	//**************** INICIO ***********************
	cCfop := ""
	cCfop += "5412, 5413, 5551, 5552, 5553, 5554, 5555, 5556, 5557"
	CriaSelect(cReg, aWizard, cCfop,'905', '930', '955', '980', @cStrTxt, @nCont) //Função Para montar select de soma das CFOP / MONTA ARQUIVO

	//Trecho de código fonte para alimentar linha 905
	//***************** FIM *************************

    //Trecho de código fonte para alimentar linha 906
    //**************** INICIO ***********************
	cCfop := ""
	cCfop += "5451, 5501, 5502, 5503, 5910, 5911, 5527, 5628"
	CriaSelect(cReg, aWizard, cCfop,'906', '931', '956', '981', @cStrTxt, @nCont) //Função Para montar select de soma das CFOP / MONTA ARQUIVO

    //Trecho de código fonte para alimentar linha 906
    //***************** FIM *************************

    //Trecho de código fonte para alimentar linha 907
    //**************** INICIO ***********************
	cCfop := ""
    Param1 := 5901
    Param2 := 5909
    While Param1 <= Param2
		cCfop += cValtoChar(Param1) + ","
       Param1 ++
    EndDo

    Param1 := 5912
    Param2 := 5926
    While Param1 <= Param2
       cCfop += cValtoChar(Param1) + ","
       Param1 ++
    EndDo
    cCfop += "5414, 5415, 5504, 5505, 5601, 5602, 5603, 5604, 5605, 5606, 5929, 5549, 5657, 5663, 5666, 5933, 5934"
    CriaSelect(cReg, aWizard, cCfop,'907', '932', '957', '982', @cStrTxt, @nCont) //Função Para montar select de soma das CFOP / MONTA ARQUIVO

    //Trecho de código fonte para alimentar linha 907
    //***************** FIM *************************

    //Trecho de código fonte para alimentar linha 908
    //**************** INICIO ***********************
	cCfop := ""
	Param1 := 6101
	Param2 := 6125
	While Param1 <= Param2
		cCfop += cValtoChar(Param1) + ","
		Param1 ++
	EndDo
	Param1 := 6401
	Param2 := 6411
	While Param1 <= Param2
	    cCfop += cValtoChar(Param1) + ","
	    Param1 ++
	EndDo

	Param1 := 6201
	Param2 := 6210
	While Param1 <= Param2
	      cCfop += cValtoChar(Param1) + ","
	      Param1 ++
	EndDo

	cCfop += "6667, 6151, 6152, 6155, 6156, 6651, 6652, 6653, 6654, 6655, 6656, 6658, 6659, 6660, 6661, 6662"
	CriaSelect(cReg, aWizard, cCfop,'908', '933', '958', '983', @cStrTxt, @nCont) //Função Para montar select de soma das CFOP / MONTA ARQUIVO

    //Trecho de código fonte para alimentar linha 908
    //***************** FIM *************************

    //Trecho de código fonte para alimentar linha 909
    //**************** INICIO ***********************
	cCfop := ""
	cCfop += "6251, 6252, 6253, 6254, 6255, 6256, 6257, 6258, 6153"
	CriaSelect(cReg, aWizard, cCfop,'909', '934', '959', '984', @cStrTxt, @nCont) //Função Para montar select de soma das CFOP / MONTA ARQUIVO

    //Trecho de código fonte para alimentar linha 909
    //***************** FIM *************************

    //Trecho de código fonte para alimentar linha 910
    //**************** INICIO ***********************
	cCfop := ""
	cCfop += "6301, 6302, 6303, 6304, 6305, 6306"
	CriaSelect(cReg, aWizard, cCfop,'910', '935', '960', '985', @cStrTxt, @nCont) //Função Para montar select de soma das CFOP / MONTA ARQUIVO

    //Trecho de código fonte para alimentar linha 910
    //***************** FIM *************************

    //Trecho de código fonte para alimentar linha 911
    //**************** INICIO ***********************
	cCfop := ""
	cCfop += "6351, 6352, 6353, 6354, 6355, 6356, 6357, 6360, 6931, 6932, 6959, 6360"
	CriaSelect(cReg, aWizard, cCfop,'911', '936', '961', '986', @cStrTxt, @nCont) //Função Para montar select de soma das CFOP / MONTA ARQUIVO

    //Trecho de código fonte para alimentar linha 911
    //***************** FIM *************************

    //Trecho de código fonte para alimentar linha 912
    //**************** INICIO ***********************
	cCfop := ""
	cCfop += "6551, 6552, 6553, 6554, 6555, 6556, 6412, 6413, 6557"
	CriaSelect(cReg, aWizard, cCfop,'912', '937', '962', '987', @cStrTxt, @nCont) //Função Para montar select de soma das CFOP / MONTA ARQUIVO

    //Trecho de código fonte para alimentar linha 912
    //***************** FIM *************************

    //Trecho de código fonte para alimentar linha 913
    //**************** INICIO ***********************
	cCfop := ""
	cCfop += "6501, 6502, 6503, 6910,6911"
	CriaSelect(cReg, aWizard, cCfop,'913', '938', '963', '988', @cStrTxt, @nCont) //Função Para montar select de soma das CFOP / MONTA ARQUIVO

    //Trecho de código fonte para alimentar linha 913
    //***************** FIM *************************

    //Trecho de código fonte para alimentar linha 914
    //**************** INICIO ***********************
	cCfop := ""
    Param1 := 6901
    Param2 := 6909
    While Param1 <= Param2
       cCfop += cValtoChar(Param1) + ","
       Param1 ++
    EndDo

    Param1 := 6912
    Param2 := 6929
    While Param1 <= Param2
       cCfop += cValtoChar(Param1) + ","
       Param1 ++
    EndDo

    Param1 := 6663
    Param2 := 6666
    While Param1 <= Param2
       cCfop += cValtoChar(Param1) + ","
       Param1 ++
    EndDo
    cCfop += "6657, 6949, 6414, 6415, 6504, 6505, 6933, 6934"
    CriaSelect(cReg, aWizard, cCfop,'914', '939', '964', '989', @cStrTxt, @nCont) //Função Para montar select de soma das CFOP / MONTA ARQUIVO

    //Trecho de código fonte para alimentar linha 914
    //***************** FIM *************************

    //Trecho de código fonte para alimentar linha 915
    //**************** INICIO ***********************
	cCfop := ""
	cCfop += "7101, 7102, 7103, 7104, 7105, 7106, 7651, 7652, 7653, 7654, 7127, 7501, 7667"
	CriaSelect(cReg, aWizard, cCfop,'915', '940', '965', '990', @cStrTxt, @nCont) //Função Para montar select de soma das CFOP / MONTA ARQUIVO

    //Trecho de código fonte para alimentar linha 915
    //***************** FIM *************************

    //Trecho de código fonte para alimentar linha 916
    //**************** INICIO ***********************
   	cCfop := ""
	cCfop += "7201, 7202, 7203, 7204, 7205, 7206, 7207, 7208, 7209, 7210, 7211"
	CriaSelect(cReg, aWizard, cCfop,'916', '941', '966', '991', @cStrTxt, @nCont) //Função Para montar select de soma das CFOP / MONTA ARQUIVO

	//Trecho de código fonte para alimentar linha 916
	//***************** FIM *************************

	//Trecho de código fonte para alimentar linha 917
	//**************** INICIO ***********************
	cCfop := ""
	cCfop += "7251"
	CriaSelect(cReg, aWizard, cCfop,'917', '942', '967', '992', @cStrTxt, @nCont) //Função Para montar select de soma das CFOP / MONTA ARQUIVO

    //Trecho de código fonte para alimentar linha 917
    //***************** FIM *************************

	//Trecho de código fonte para alimentar linha 918
	//**************** INICIO ***********************
	cCfop := ""
	cCfop += "7301"
	CriaSelect(cReg, aWizard, cCfop,'918', '943', '968', '993', @cStrTxt, @nCont) //Função Para montar select de soma das CFOP / MONTA ARQUIVO

	//Trecho de código fonte para alimentar linha 918
	//***************** FIM *************************

	//Trecho de código fonte para alimentar linha 919
	//**************** INICIO ***********************
	cCfop := ""
	cCfop += "7358"
	CriaSelect(cReg, aWizard, cCfop,'919', '944', '969', '994', @cStrTxt, @nCont) //Função Para montar select de soma das CFOP / MONTA ARQUIVO

	//Trecho de código fonte para alimentar linha 919
	//***************** FIM *************************

	//Trecho de código fonte para alimentar linha 920
	//**************** INICIO ***********************
	cCfop := ""
	cCfop += "7551, 7552, 7553, 7554, 7555, 7556, 7930, 7949"
	CriaSelect(cReg, aWizard, cCfop,'920', '945', '970', '995', @cStrTxt, @nCont) //Função Para montar select de soma das CFOP / MONTA ARQUIVO

	//Trecho de código fonte para alimentar linha 920
	//***************** FIM *************************

	// QUADRO: 19 - EXCLUSÃO E INCLUSÃO DO VALOR CONTABIL DAS ENTRADAS
	//Trecho de código fonte para alimentar linha 672
	//**************** INICIO ***********************
	cCfop := ""
	cCfop += "1414, 2414, 1415, 2415, 1904, 2904"
	CriaSelect(cReg, aWizard, cCfop, '672', '', '', '', @cStrTxt, @nCont, '680', @aMsg) //Função Para montar select de soma das CFOP / MONTA ARQUIVO

	//Trecho de código fonte para alimentar linha 672
	//***************** FIM *************************

	//Linha 823 U-Estoque 31/12
	BuscaValEst(cReg,'921',aWizard[1][5],@cStrTxt)

	// QUADRO: 20 - EXCLUSÃO E INCLUSÃO DO VALOR CONTABIL DAS ENTRADAS
	//Trecho de código fonte para alimentar linha 682
	//**************** INICIO ***********************
	cCfop := ""
	cCfop += "5414, 6414, 5415, 6415, 5904, 6904, 5657, 6657"
	CriaSelect(cReg, aWizard, cCfop, '682', '', '', '', @cStrTxt, @nCont, '690', @aMsg) //Função Para montar select de soma das CFOP / MONTA ARQUIVO

	//Trecho de código fonte para alimentar linha 682
	//***************** FIM *************************


	// QUADRO: 22 - Valores por Municípios

	CriaVlMun(cReg,aWizard[1][5],@cStrTxt, @nCont)


	//***************** FIM *************************



	// QUADRO: 23 - DETALHAMENTO DE VALORES
	//**************** INICIO ***********************
	For nI := 1 to Len(aMsg)
		cStrTxt += aMsg[nI] + CRLF
	Next nI
	//***************** FIM *************************

	//cStrTxt += CRLF

	WrtStrTxt( nHandle, cStrTxt )

	GerTxtDFPR( nHandle, cTxtSys, cReg )

	Recover
	lFound := .F.

End Sequence
Return


Static Function CriaSelect(cReg, aWizard, cCfops, linha1, linha2, linha3, linha4, cStrTxt, nCont, linhaTot, aMsg)

Local cQuery		:= ""
Local cNovoAlias	:= GetNextAlias()
Local cDatIni		:= aWizard[1][5] + "0101"
Local cDatFin		:= aWizard[1][5] + "1231"


Begin Sequence 
	cQuery := " SELECT SUM(C6Z.C6Z_VLCONT) C6Z_VLCONT, SUM(C6Z.C6Z_BASE) C6Z_BASE, SUM(C6Z.C6Z_ISENNT) C6Z_ISENNT, SUM(C6Z.C6Z_OUTROS) C6Z_OUTROS "
	cQuery += " FROM " + RetSqlName('C6Z') + " C6Z "
	cQuery += " JOIN " + RetSqlName('C2S') + " C2S ON ( C2S.C2S_ID = C6Z.C6Z_ID )
	cQuery += " JOIN " + RetSqlName('C0Y') + " C0Y ON ( C0Y.C0Y_ID = C6Z.C6Z_CFOP )
	cQuery += " WHERE C6Z.C6Z_FILIAL = '" + xFilial("C6Z") + "' " 
	cQuery += " AND C2S.C2S_FILIAL = '" + xFilial("C2S") + "' " 
	cQuery += " AND C2S.C2S_DTINI >= '" + cDatIni + "' " 
	cQuery += " AND C2S.C2S_DTFIN <= '" + cDatFin + "' " 
	cQuery += " AND C0Y.C0Y_CODIGO IN ( " + cCfops + ") " 
	cQuery += " AND C2S.D_E_L_E_T_ <> '*' "
	cQuery += " AND C6Z.D_E_L_E_T_ <> '*' "
	cQuery += " AND C0Y.D_E_L_E_T_ <> '*' "
End Sequence 

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cNovoAlias,.T.,.T.)
	DbSelectArea(cNovoAlias)
	While !Eof()
		If (cNovoAlias)->C6Z_VLCONT != 0 .OR. (cNovoAlias)->C6Z_BASE != 0 .OR. (cNovoAlias)->C6Z_ISENNT != 0 .OR. (cNovoAlias)->C6Z_OUTROS != 0
			IF !Empty(linha1)
				cStrTxt += cReg + linha1 + '0' + StrZero(int((cNovoAlias)->C6Z_VLCONT),15)	+ CRLF
				nCont ++
				//Tratamento para quadro 19/20
				If !Empty(linha1) .AND. Empty(linha2) .AND. Empty(linha3) .AND. Empty(linha4) .AND. !Empty(linhaTot)
					cStrTxt += cReg + linhaTot + '0' + StrZero(Int((cNovoAlias)->C6Z_VLCONT),15)	+ CRLF
					nCont ++

					IF linhaTot == '680'
						Aadd(aMsg, 'Quadro 19: INCLUSAO DO VALOR CONTABIL DAS ENTRADAS DOS CFOPS: ' + cCfops + ' COM VALOR DE: ' + StrZero(int((cNovoAlias)->C6Z_VLCONT),15))
					ELSEIF linhaTot == '690'
						Aadd(aMsg, 'Quadro 20: INCLUSAO DO VALOR CONTABIL DAS SAIDAS DOS CFOPS: ' + cCfops + ' COM VALOR DE: ' + StrZero(int((cNovoAlias)->C6Z_VLCONT),15))
					ENDIF
				ENDIF
			ENDIF
			IF !Empty(linha2)
				cStrTxt += cReg + linha2 + '0' + StrZero(int((cNovoAlias)->C6Z_BASE),15)		+ CRLF
				nCont ++
			ENDIF
			IF !Empty(linha3)
				cStrTxt += cReg + linha3 + '0' + StrZero(int((cNovoAlias)->C6Z_ISENNT),15)	+ CRLF
				nCont ++
			ENDIF
			IF !Empty(linha4)
				cStrTxt += cReg + linha4 + '0' + StrZero(int((cNovoAlias)->C6Z_OUTROS),15)	+ CRLF
				nCont ++
			ENDIF
		EndIf
		(cNovoAlias)->(DbSkip())
	EndDo
	DbCloseArea()

Return

Static Function BuscaValEst(cReg, cEst, nAno, cStrTxt )

local cEst                    //identificador de estoque final e inicial
Local cQuery		:= ""
Local cNovoAlias	:= GetNextAlias()
Local cDat


	If cEst == '921'
		nAno	:= cValtoChar(val(nAno) -1)
	EndIf
	cDat	:= nAno + '1231'

	Begin Sequence 
		cQuery := " SELECT CSAA.c5a_vinv ValEstoq "
		cQuery += " FROM " + RetSqlName('C5A') + " CSAA "
		cQuery += " WHERE CSAA.C5A_DTINV = (select MAX(CSAB.C5A_DTINV)
		cQuery += " FROM " + RetSqlName('C5A') + " CSAB "
       cQuery += " WHERE CSAB.C5A_DTINV <= '" + cDat + "' "              //Último dia do ano
       cQuery += " AND CSAB.D_E_L_E_T_ <> '*' "
       cQuery += " AND CSAB.C5A_MOTINV = '000001')"	                  //somente estoque final código '000001'
		cQuery += " AND CSAA.D_E_L_E_T_ <> '*' "

	End Sequence 

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cNovoAlias,.T.,.T.)
	DbSelectArea(cNovoAlias)
	While !Eof()
		cStrTxt += cReg + cEst + '0' + StrZero(int((cNovoAlias)->ValEstoq),15)		+ CRLF
		(cNovoAlias)->(DbSkip())
	EndDo
	DbCloseArea()

Return

Static Function CriaVlMun(cReg, nAno, cStrTxt, nCont)

Local cDatIni 		:= nAno + '0101'          //Primeiro dia do ano
Local cDatFin 		:= nAno + '1231'          //Último dia do ano
Local cNovoAlias		:= GetNextAlias()
Local vTot				:= 0

	Begin Sequence 
		cQuery := " SELECT SUM(C4X_VALOR) VALOR, C4X_CODMUN CODMUN "
		cQuery += " FROM " + RetSqlName('C4X') + ' C4X '
		cQuery += " WHERE  C4X_CODMUN IS NOT NULL "
		cQuery += "   AND  C4X_CODMUN <> ' ' "
       cQuery += "   AND  C4X_PERIOD between '" + cDatIni + "' and '" + cDatFin + "'"
       cQuery += "   AND  C4X_UF = '000019'"
       cQuery += "   AND  D_E_L_E_T_ <> '*' "
       cQuery += " GROUP BY C4X_CODMUN "
	End Sequence 

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cNovoAlias,.T.,.T.)
	DbSelectArea(cNovoAlias)
	While !Eof()
		//POSICIONE("C07",3,xFilial("C07")+(cNovoAlias)->CODMUN,"C07_MUNDPR")
		POSICIONE("T2D",2,xFilial("T2D")+ (cNovoAlias)->CODMUN + "MUNPR","T2D_CODMUN")
		cStrTxt	+= cReg + Substr(cValtoChar(T2D->T2D_CODMUN),1,4) +  StrZero(int((cNovoAlias)->VALOR),15) + CRLF
		vTot		+= (cNovoAlias)->VALOR
		nCont 		++
		(cNovoAlias)->(DbSkip())
	EndDo
	cStrTxt 	+= cReg + '5999' +  StrZero(int(vTot),15) + CRLF
	nCont		++
	DbCloseArea()
Return
