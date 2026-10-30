#INCLUDE 'protheus.ch'
#INCLUDE 'topconn.ch'
/*/{PROTHEUS.DOC} LOCR040.PRW
ITUP BUSINESS - TOTVS RENTAL
RELATÓRIO DE FATURAMENTO SINTÉTICO
@TYPE FUNCTION
@AUTHOR DENNIS CALABREZ
@SINCE 04/07/2024 
/*/ 
Function LOCR040()

Private oReport := Nil
Private oSecCab := Nil
PRIVATE OBREAK
	
   if PERGPARAM()
        cData1   := MV_PAR01
        cData2   := MV_PAR02
		processa({||ReportDef()},,"Gerando Relatório de Faturamento...")    
        oReport:PrintDialog()
    endif
	
	//ReportDef()
	//oReport:PrintDialog()
Return

/*/{Protheus.doc} ReportDef
ReportDef
@type Static function
@version 25.10
@author Dennis Calabrez
@since 11/08/2026
/*/
Static Function ReportDef()

	oReport := TReport():New("LOCR040","Relatório de Faturamento",/*cPerg*/,{|oReport| PrintReport(oReport)},"Impressão Relatório de Faturamento.")
	oReport:SetLandscape(.T.)
	
	oSecCab := TRSection():New( oReport , "Faturamento", {"QRY"} )
	
    If MV_PAR12 == 1 .OR. MV_PAR12 == 2 //FATURADOS E NÃO FATURADOS
		TRCell():New( oSecCab, "FPY_PROJET"     , "QRY","PROJETO")
		TRCell():New( oSecCab, "FP0_CLI"   		, "QRY","CLIENTE")
		TRCell():New( oSecCab, "FP0_CLINOM"    	, "QRY","NOME CLIENTE")
		TRCell():New( oSecCab, "FP0_CLINOM"    	, "QRY","NOME CLIENTE")
		TRCell():New( oSecCab, "FP1_ESTORI"    	, "QRY","UF OBRA")
		TRCell():New( oSecCab, "C5_EMISSAO"    	, "QRY","EMIS. PED")
		TRCell():New( oSecCab, "FPY_PEDVEN"     , "QRY","PEDIDO")
		TRCell():New( oSecCab, "FPY_TIPFAT"     , "QRY","TIP FATURA.")
		TRCell():New( oSecCab, "C6_VALOR"   	, "QRY","VALOR PEDIDO", "@E 9,999,999.99")
		TRCell():New( oSecCab, "C5_CLIENTE"    	, "QRY","CLI. FATURA")
		TRCell():New( oSecCab, "F2_EMISSAO"     , "QRY","EMIS. FATURA")
		TRCell():New( oSecCab, "F2_DOC"      	, "QRY","FATURA")
		TRCell():New( oSecCab, "F2_SERIE"      	, "QRY","SERIE FATURA")
		TRCell():New( oSecCab, "D2_TOTAL"      	, "QRY","VALOR FATURA")
		TRCell():New( oSecCab, "E1_VENCTO"      , "QRY","VENCTO FATURA")  
	ElseIf MV_PAR12 == 3 //AMBOS
		TRCell():New( oSecCab, "FPY_PROJET"     , "QRY","PROJETO")
		TRCell():New( oSecCab, "FP0_CLI"    	, "QRY","CLIENTE")
		TRCell():New( oSecCab, "FP0_CLINOM"    	, "QRY","NOME CLIENTE")
		TRCell():New( oSecCab, "FP1_ESTORI"    	, "QRY","UF OBRA")
		TRCell():New( oSecCab, "C5_EMISSAO"    	, "QRY","EMIS. PED")
		TRCell():New( oSecCab, "FPY_PEDVEN"     , "QRY","PEDIDO")
		TRCell():New( oSecCab, "FPY_TIPFAT"     , "QRY","TIP FATURA.")
		TRCell():New( oSecCab, "C6_VALOR"      , "QRY","VALOR PEDIDO", "@E 9,999,999.99")
		TRCell():New( oSecCab, "C5_CLIENTE"    	, "QRY","CLI. FATURA")
		TRCell():New( oSecCab, "E1_EMISSAO"     , "QRY","EMIS. FATURA")
		TRCell():New( oSecCab, "E1_NUM"      	, "QRY","FATURA")
		TRCell():New( oSecCab, "E1_PREFIXO"    	, "QRY","SERIE FATURA")
		TRCell():New( oSecCab, "D2_TOTAL"      	, "QRY","VALOR FATURA")
		TRCell():New( oSecCab, "E1_VENCTO"      , "QRY","VENCTO FATURA")
	EndIf
	If MV_PAR12 == 1 .OR. MV_PAR12 == 2 //FATURADOS E NÃO FATURADOS     
		TRFunction():New(oSecCab:Cell("D2_TOTAL"),/*cId*/,"SUM"     ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F.           ,.T.           ,.F.        ,oSecCab)
		TRFunction():New(oSecCab:Cell("C6_VALOR"),/*cId*/,"SUM"    ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F.           ,.T.           ,.F.        ,oSecCab)
    ElseIf MV_PAR12 == 3
		TRFunction():New(oSecCab:Cell("D2_TOTAL"),/*cId*/,"SUM"     ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F.           ,.T.           ,.F.        ,oSecCab)
		TRFunction():New(oSecCab:Cell("C6_VALOR"),/*cId*/,"SUM"    ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F.           ,.T.           ,.F.        ,oSecCab)	
	EndIf
Return

/*/{Protheus.doc} PrintReport
PrintReport
@type Static function
@version 25.10
@author Dennis Calabrez
@since 11/08/2026
/*/
Static Function PrintReport(oReport)

Local cQuery := ""
Local aBindParam := {}

	If MV_PAR12 == 1 //FATURADOS
		cQuery := "SELECT C5.C5_NUM,C5.C5_NOTA,C5.C5_EMISSAO,C5.C5_CLIENTE, FPY.FPY_PROJET,FPY.FPY_PEDVEN,FPY.FPY_TIPFAT,E1.E1_EMISSAO,E1.E1_PREFIXO,E1.E1_VENCTO, "
		cQuery += "F2.F2_DOC,F2.F2_SERIE,F2.F2_EMISSAO,F2.F2_VALBRUT,FP0.FP0_CLI,FP0.FP0_CLINOM,SUM(C6.C6_VALOR) C6_VALOR,D2.D2_TOTAL,FP1.FP1_ESTORI "
		cQuery += "FROM "+RetSQlName("SC5")+" C5 INNER JOIN "+RetSQlName("SC6")+" C6 ON C6.C6_FILIAL=C5.C5_FILIAL AND C6.C6_NUM=C5.C5_NUM AND C6.D_E_L_E_T_=''  "
		cQuery += "LEFT JOIN "+RetSQlName("SF2")+" F2 ON F2.F2_FILIAL=C5.C5_FILIAL AND F2.F2_DOC=C5.C5_NOTA AND F2.F2_SERIE=C5.C5_SERIE AND C5.D_E_L_E_T_=' ' "
		cQuery += "LEFT JOIN (SELECT D2_FILIAL,D2_DOC,D2_SERIE,SUM(D2_TOTAL) D2_TOTAL FROM "+RetSQlName("SD2")+" WHERE D_E_L_E_T_=' ' GROUP BY D2_FILIAL,D2_DOC,D2_SERIE) D2 ON D2.D2_FILIAL=F2.F2_FILIAL AND D2.D2_DOC=F2.F2_DOC AND D2.D2_SERIE=F2.F2_SERIE "
		cQuery += "LEFT JOIN "+RetSQlName("FPY")+" FPY ON FPY.FPY_FILIAL=C5.C5_FILIAL AND FPY.FPY_PEDVEN=C5.C5_NUM AND FPY.D_E_L_E_T_=' ' "
		cQuery += "LEFT JOIN "+RetSQlName("SE1")+" E1 ON E1.E1_FILIAL=F2.F2_FILIAL AND E1.E1_NUM=F2.F2_DOC AND E1.E1_PREFIXO=F2.F2_SERIE AND E1.E1_CLIENTE=F2.F2_CLIENTE AND "
		cQuery += "E1.E1_LOJA=F2.F2_LOJA AND F2.F2_DUPL=E1.E1_NUM AND E1.D_E_L_E_T_='' AND F2.D_E_L_E_T_='' "
		cQuery += "INNER JOIN "+RetSQlName("FP0")+" FP0 ON FP0.FP0_FILIAL = FPY.FPY_FILIAL AND FP0.FP0_PROJET = FPY.FPY_PROJET AND FP0.D_E_L_E_T_='' "
		cQuery += "INNER JOIN "+RetSQlName("FP1")+" FP1 ON FP1.FP1_FILIAL = FPY.FPY_FILIAL AND FP1.FP1_PROJET = FPY.FPY_PROJET AND FP1.D_E_L_E_T_='' "
		cQuery += "WHERE C5.C5_EMISSAO BETWEEN  ? AND ? "
		cQuery += "AND F2.F2_EMISSAO BETWEEN  ? AND ? "
		cQuery += "AND C5.C5_CLIENTE BETWEEN  ? AND ? "
		cQuery += "AND FPY.FPY_PROJET BETWEEN  ? AND ? "
		cQuery += "AND F2.F2_SERIE BETWEEN  ? AND ? "
		cQuery += "AND FPY.FPY_TIPFAT <> 'R' "
		cQuery += "AND C5.C5_NOTA <> ' ' "
		if !empty(MV_PAR11)
			cQuery += " AND FP1.FP1_ESTORI = ? "
		endif
		cQuery += "GROUP BY FPY.FPY_PROJET,C5.C5_CLIENTE,C5.C5_NUM,C5.C5_NOTA,C5.C5_EMISSAO,FPY.FPY_PEDVEN,FPY.FPY_TIPFAT,E1.E1_EMISSAO,E1.E1_VENCTO, F2.F2_DOC,"
		cQuery += "F2.F2_EMISSAO,F2.F2_VALBRUT,FP0.FP0_CLI,FP0.FP0_CLINOM,D2.D2_TOTAL,E1.E1_PREFIXO,F2.F2_SERIE,FP1.FP1_ESTORI "
		cQuery += "ORDER BY FPY.FPY_PROJET,C5.C5_CLIENTE,C5.C5_NUM,C5.C5_NOTA,C5.C5_EMISSAO,FPY.FPY_PEDVEN,FPY.FPY_TIPFAT,E1.E1_EMISSAO,E1.E1_VENCTO, F2.F2_DOC,"
		cQuery += "F2.F2_EMISSAO,F2.F2_VALBRUT,FP0.FP0_CLI,FP0.FP0_CLINOM"
	EndIf 	

	If MV_PAR12 == 2 //Não FATURADOS
		cQuery := "SELECT C5.C5_NUM,C5.C5_NOTA,C5.C5_EMISSAO,C5.C5_CLIENTE,SUM(C6.C6_VALOR) C6_VALOR ,FPY.FPY_PROJET,FPY.FPY_PEDVEN,FPY.FPY_TIPFAT, "
		cQuery += "FP0.FP0_CLI,FP0.FP0_CLINOM,0 D2_TOTAL,FP1.FP1_ESTORI "
		cQuery += "FROM "+RetSQlName("SC5")+" C5 INNER JOIN "+RetSQlName("SC6")+" C6 ON C6.C6_FILIAL=C5.C5_FILIAL AND C6.C6_NUM=C5.C5_NUM AND C6.D_E_L_E_T_=''  "
		cQuery += "LEFT JOIN "+RetSQlName("FPY")+" FPY ON FPY.FPY_FILIAL=C5.C5_FILIAL AND FPY.FPY_PEDVEN=C5.C5_NUM AND FPY.D_E_L_E_T_=' ' "
		cQuery += "INNER JOIN "+RetSQlName("FP0")+" FP0 ON FP0.FP0_FILIAL = FPY.FPY_FILIAL AND FP0.FP0_PROJET = FPY.FPY_PROJET AND FP0.D_E_L_E_T_='' "
		cQuery += "INNER JOIN "+RetSQlName("FP1")+" FP1 ON FP1.FP1_FILIAL = FPY.FPY_FILIAL AND FP1.FP1_PROJET = FPY.FPY_PROJET AND FP1.D_E_L_E_T_='' "
		cQuery += "WHERE C5.C5_EMISSAO BETWEEN  ? AND ? "
		cQuery += "AND C5.C5_CLIENTE BETWEEN  ? AND ? "
		cQuery += "AND FPY.FPY_PROJET BETWEEN  ? AND ? "
		cQuery += "AND FPY.FPY_TIPFAT <> 'R' "
		cQuery += "AND C5.C5_NOTA = ' ' "
		if !empty(MV_PAR11)
			cQuery += " AND FP1.FP1_ESTORI = ? "
		endif		
		cQuery += "GROUP BY FPY.FPY_PROJET,C5.C5_CLIENTE,C5.C5_NUM,C5.C5_NOTA,C5.C5_EMISSAO,FPY.FPY_PEDVEN,FPY.FPY_TIPFAT,FP0.FP0_CLI,FP0.FP0_CLINOM,FP1.FP1_ESTORI "
		cQuery += "ORDER BY FPY.FPY_PROJET,C5.C5_CLIENTE,C5.C5_NUM,C5.C5_NOTA,C5.C5_EMISSAO,FPY.FPY_PEDVEN,FPY.FPY_TIPFAT,FP0.FP0_CLI,FP0.FP0_CLINOM"
	EndIf

	If MV_PAR12 == 3 //AMBOS

		cQuery := "SELECT C5.C5_NUM,C5.C5_NOTA,C5.C5_SERIE,C5.C5_EMISSAO,C5.C5_CLIENTE,FPY.FPY_PROJET,FPY.FPY_PEDVEN,FPY.FPY_TIPFAT, "
		cQuery += "FP0.FP0_CLI,E1.E1_EMISSAO,E1.E1_VENCTO,E1.E1_NUM,E1.E1_PREFIXO,FP0.FP0_CLINOM,SUM(C6.C6_VALOR) C6_VALOR,D2.D2_TOTAL,FP1.FP1_ESTORI " // DSERLOCA-13089
		cQuery += "FROM "+RetSQlName("SC5")+" C5 "
		cQuery += "INNER JOIN "+RetSQlName("SC6")+" C6 ON C6.C6_FILIAL=C5.C5_FILIAL AND C6.C6_NUM=C5.C5_NUM AND C6.D_E_L_E_T_='' "
		cQuery += "LEFT JOIN "+RetSQlName("SF2")+" F2 ON F2.F2_FILIAL=C5.C5_FILIAL AND F2.F2_DOC=C5.C5_NOTA AND F2.F2_SERIE=C5.C5_SERIE AND F2.D_E_L_E_T_=' ' "
		cQuery += "LEFT JOIN (SELECT D2_FILIAL,D2_DOC,D2_SERIE,SUM(D2_TOTAL) D2_TOTAL FROM "+RetSQlName("SD2")+" WHERE D_E_L_E_T_=' ' GROUP BY D2_FILIAL,D2_DOC,D2_SERIE) D2 "
		cQuery += "ON D2.D2_FILIAL=F2.F2_FILIAL AND D2.D2_DOC=F2.F2_DOC AND D2.D2_SERIE=F2.F2_SERIE " // DSERLOCA-13089
		cQuery += "LEFT JOIN "+RetSQlName("FPY")+" FPY ON FPY.FPY_FILIAL=C5.C5_FILIAL AND FPY.FPY_PEDVEN=C5.C5_NUM AND FPY.D_E_L_E_T_=' ' "
		cQuery += "INNER JOIN "+RetSQlName("FP0")+" FP0 ON FP0.FP0_FILIAL=FPY.FPY_FILIAL AND FP0.FP0_PROJET=FPY.FPY_PROJET AND FP0.D_E_L_E_T_='' "
		cQuery += "INNER JOIN "+RetSQlName("FP1")+" FP1 ON FP1.FP1_FILIAL=FPY.FPY_FILIAL AND FP1.FP1_PROJET=FPY.FPY_PROJET AND FP1.D_E_L_E_T_='' "
		cQuery += "LEFT JOIN (SELECT E1_FILIAL,E1_NUM,E1_PREFIXO,E1_CLIENTE,E1_LOJA,E1_EMISSAO,E1_VENCTO, "
		cQuery += "ROW_NUMBER() OVER (PARTITION BY E1_FILIAL,E1_NUM,E1_PREFIXO,E1_CLIENTE,E1_LOJA ORDER BY E1_PARCELA) RN "
		cQuery += "FROM "+RetSQlName("SE1")+" WHERE D_E_L_E_T_='') E1 " // DSERLOCA-13089
		cQuery += "ON E1.E1_FILIAL=F2.F2_FILIAL AND E1.E1_NUM=F2.F2_DOC AND E1.E1_PREFIXO=F2.F2_SERIE " // DSERLOCA-13089
		cQuery += "AND E1.E1_CLIENTE=F2.F2_CLIENTE AND E1.E1_LOJA=F2.F2_LOJA AND E1.RN=1 " // DSERLOCA-13089
		cQuery += "WHERE C5.C5_EMISSAO BETWEEN ? AND ? "
		cQuery += "AND F2.F2_EMISSAO BETWEEN ? AND ? "
		cQuery += "AND C5.C5_CLIENTE BETWEEN ? AND ? "
		cQuery += "AND FPY.FPY_PROJET BETWEEN ? AND ? "
		cQuery += "AND F2.F2_SERIE BETWEEN ? AND ? "
		cQuery += "AND FPY.FPY_TIPFAT <> 'R' "
		cQuery += "AND C5.C5_NOTA <> ' ' "
		if !empty(MV_PAR11)
			cQuery += "AND FP1.FP1_ESTORI = ? "
		endif
		cQuery += "GROUP BY C5.C5_NUM,C5.C5_NOTA,C5.C5_SERIE,C5.C5_EMISSAO,C5.C5_CLIENTE,FPY.FPY_PROJET,FPY.FPY_PEDVEN,FPY.FPY_TIPFAT, "
		cQuery += "FP0.FP0_CLI,E1.E1_EMISSAO,E1.E1_VENCTO,E1.E1_NUM,E1.E1_PREFIXO,FP0.FP0_CLINOM,D2.D2_TOTAL,FP1.FP1_ESTORI " // DSERLOCA-13089

		cQuery += "UNION ALL "

		cQuery += "SELECT C5.C5_NUM,C5.C5_NOTA,C5.C5_SERIE,C5.C5_EMISSAO,C5.C5_CLIENTE,FPY.FPY_PROJET,FPY.FPY_PEDVEN,FPY.FPY_TIPFAT, "
		cQuery += "FP0.FP0_CLI,NULL E1_EMISSAO,NULL E1_VENCTO,NULL E1_NUM,NULL E1_PREFIXO,FP0.FP0_CLINOM,SUM(C6.C6_VALOR) C6_VALOR,0 D2_TOTAL,FP1.FP1_ESTORI " // DSERLOCA-13089
		cQuery += "FROM "+RetSQlName("SC5")+" C5 "
		cQuery += "INNER JOIN "+RetSQlName("SC6")+" C6 ON C6.C6_FILIAL=C5.C5_FILIAL AND C6.C6_NUM=C5.C5_NUM AND C6.D_E_L_E_T_='' "
		cQuery += "LEFT JOIN "+RetSQlName("FPY")+" FPY ON FPY.FPY_FILIAL=C5.C5_FILIAL AND FPY.FPY_PEDVEN=C5.C5_NUM AND FPY.D_E_L_E_T_=' ' "
		cQuery += "INNER JOIN "+RetSQlName("FP0")+" FP0 ON FP0.FP0_FILIAL=FPY.FPY_FILIAL AND FP0.FP0_PROJET=FPY.FPY_PROJET AND FP0.D_E_L_E_T_='' "
		cQuery += "INNER JOIN "+RetSQlName("FP1")+" FP1 ON FP1.FP1_FILIAL=FPY.FPY_FILIAL AND FP1.FP1_PROJET=FPY.FPY_PROJET AND FP1.D_E_L_E_T_='' "
		cQuery += "WHERE C5.C5_EMISSAO BETWEEN ? AND ? "
		cQuery += "AND C5.C5_CLIENTE BETWEEN ? AND ? "
		cQuery += "AND FPY.FPY_PROJET BETWEEN ? AND ? "
		cQuery += "AND FPY.FPY_TIPFAT <> 'R' "
		cQuery += "AND C5.C5_NOTA = ' ' "
		if !empty(MV_PAR11)
			cQuery += "AND FP1.FP1_ESTORI = ? "
		endif
		cQuery += "GROUP BY C5.C5_NUM,C5.C5_NOTA,C5.C5_SERIE,C5.C5_EMISSAO,C5.C5_CLIENTE,FPY.FPY_PROJET,FPY.FPY_PEDVEN,FPY.FPY_TIPFAT, "
		cQuery += "FP0.FP0_CLI,FP0.FP0_CLINOM,FP1.FP1_ESTORI "

		cQuery += "ORDER BY FPY_PROJET,C5_CLIENTE,C5_NUM,C5_NOTA,C5_EMISSAO,FPY_PEDVEN,FPY_TIPFAT,FP0_CLI,FP0_CLINOM"
	EndIf
	
	cQuery := ChangeQuery(cQuery)

	If MV_PAR12 == 1
		aBindParam := {DTOS(MV_PAR01),DTOS(MV_PAR02),DTOS(MV_PAR03),DTOS(MV_PAR04),MV_PAR05,MV_PAR06,MV_PAR07,MV_PAR08,MV_PAR09,MV_PAR10,MV_PAR11}
	ElseIf MV_PAR12 == 2
		aBindParam := {DTOS(MV_PAR01),DTOS(MV_PAR02),MV_PAR05,MV_PAR06,MV_PAR07,MV_PAR08,MV_PAR11}
	ElseIf MV_PAR12 == 3
		// DSERLOCA-13089 - aBindParam remontado dinamicamente: o parametro FP1_ESTORI so
		// existe na query quando MV_PAR11 nao esta vazio (ver "if !empty(MV_PAR11)" acima).
		// Antes, o array sempre incluia esse valor mesmo sem o "?" correspondente, o que
		// deslocava a posicao de todos os parametros do 2o SELECT (nao faturados) dentro
		// do UNION ALL e zerava aquele resultado quando MV_PAR11 estava vazio.
		aBindParam := {DTOS(MV_PAR01),DTOS(MV_PAR02),DTOS(MV_PAR03),DTOS(MV_PAR04),MV_PAR05,MV_PAR06,MV_PAR07,MV_PAR08,MV_PAR09,MV_PAR10} // DSERLOCA-13089
		if !empty(MV_PAR11)
			aAdd(aBindParam, MV_PAR11) // DSERLOCA-13089
		endif
		aAdd(aBindParam, DTOS(MV_PAR01)) // DSERLOCA-13089
		aAdd(aBindParam, DTOS(MV_PAR02)) // DSERLOCA-13089
		aAdd(aBindParam, MV_PAR05) // DSERLOCA-13089
		aAdd(aBindParam, MV_PAR06) // DSERLOCA-13089
		aAdd(aBindParam, MV_PAR07) // DSERLOCA-13089
		aAdd(aBindParam, MV_PAR08) // DSERLOCA-13089
		if !empty(MV_PAR11)
			aAdd(aBindParam, MV_PAR11) // DSERLOCA-13089
		endif
	EndIf	

	MPSysOpenQuery(cQuery,"QRY",,,aBindParam)
	//TcQuery cQuery New Alias "QRY"

	//oSecCab:BeginQuery()
	//oSecCab:EndQuery({{"QRY"},cQuery})
	TCSetField("QRY", "C5_EMISSAO", "D", 8, 0)
	If MV_PAR12 == 1
		TCSetField("QRY", "F2_EMISSAO", "D", 8, 0)
	EndIf
	If MV_PAR12 <> 2
		TCSetField("QRY", "E1_VENCTO",  "D", 8, 0)
		TCSetField("QRY", "E1_EMISSAO", "D", 8, 0)
	EndIf
	oSecCab:Print()

Return

/*/{Protheus.doc} PERGPARAM
PERGPARAM
@type Static function
@version 25.10
@author Dennis Calabrez
@since 11/08/2026
/*/
STATIC FUNCTION PERGPARAM(CPERG)

LOCAL APERGS  := {}
LOCAL _CCLIDE := IIF(FIELDPOS("C5_CLIENTE")>0,SPACE(GETSX3CACHE("C5_CLIENTE","X3_TAMANHO")),SPACE(06))
LOCAL _CCLIAT := IIF(FIELDPOS("C5_CLIENTE")>0,REPLICATE("Z",GETSX3CACHE("C5_CLIENTE","X3_TAMANHO")),REPLICATE("Z",06))
LOCAL _CPRODE := IIF(FIELDPOS("FPY_PROJET")>0,SPACE(GETSX3CACHE("FPY_PROJET","X3_TAMANHO")),SPACE(22))
LOCAL _CPROAT := IIF(FIELDPOS("FPY_PROJET")>0,REPLICATE("Z",GETSX3CACHE("FPY_PROJET","X3_TAMANHO")),REPLICATE("Z",22))
LOCAL LRET    := .F.
Local dEmDe   := (Date())
Local dEmAte  := (Date())
Local dVcDe   := (Date())
Local dVcAte  := (Date())
Local nTipo   := 1
Local cSerieD := space(TamSX3("F2_SERIE")[1])
Local cSerieA := space(TamSX3("F2_SERIE")[1])
Local cUFObra := space(TamSX3("FP1_ESTORI")[1])


aAdd(APERGS, {1,"Emissão PV De",dEmDe,  "",             ".T.",        "",    ".T.", 80,  .F.})
aAdd(APERGS, {1,"Emissão PV Até",dEmAte,  "",             ".T.",        "",    ".T.", 80,  .T.})
aAdd(APERGS, {1,"Emissão NF De",dVcDe,  "",             ".T.",        "",    ".T.", 80,  .F.})
aAdd(APERGS, {1,"Emissão NF Até",dVcAte,  "",             ".T.",        "",    ".T.", 80,  .T.})
AADD(APERGS ,{1,"Cliente De",_CCLIDE,"@!",".T.","SA1"  ,".T.", 50,.F.}) 
AADD(APERGS ,{1,"Cliente Até",_CCLIAT,"@!",".T.","SA1"  ,".T.", 50,.F.})
AADD(APERGS ,{1,"Projeto De",_CPRODE,"@!",".T.","FP0"  ,".T.", 50,.F.}) 
AADD(APERGS ,{1,"Projeto Até",_CPROAT,"@!",".T.","FP0"  ,".T.", 50,.F.}) 
AADD(APERGS ,{1,"Serie De",cSerieD,"@!",".T.",""  ,".T.", 50,.F.}) 
AADD(APERGS ,{1,"Serie Até",cSerieA,"@!",".T.",""  ,".T.", 50,.F.})
AADD(APERGS ,{1,"UF Obra",cUFObra,"@!",".T.",""  ,".T.", 20,.F.}) 


AADD(APERGS, {2,"Somente Faturados",nTipo, {"1=Sim","2=Não","3=Ambos"},     122, ".T.", .F.})

If ParamBox(APERGS, "Informe os parâmetros") 
	
 		IF VALTYPE( MV_PAR12 ) == "C"
			IF "1" $  ALLTRIM(MV_PAR12) 
				MV_PAR12 := 1
			ELSEIF "2" $ ALLTRIM(MV_PAR12) 
				MV_PAR12 := 2
			ELSEIF "3" $ ALLTRIM(MV_PAR12) 
				MV_PAR12 := 3				
			ENDIF
		END
	LRET := .T.
ENDIF

RETURN (LRET)

