#INCLUDE 'protheus.ch'
#INCLUDE 'topconn.ch'
/*/{PROTHEUS.DOC} LOCR040.PRW
ITUP BUSINESS - TOTVS RENTAL
RELATÓRIO DE FATURAMENTO ANALÍTICO
@TYPE FUNCTION
@AUTHOR DENNIS CALABREZ
@SINCE 04/07/2024
/*/
Function LOCR041()
Private oReport := Nil
Private oSecCab := Nil
Private nDias := 0
PRIVATE OBREAK

   if PERGPARAM()
        cData1   := MV_PAR01
        cData2   := MV_PAR02
		processa({||ReportDef()},,"Gerando Relatório de Faturamento Analítico...")
        oReport:PrintDialog()
    endif

	//ReportDef()
	//oReport:PrintDialog()
Return

Static Function ReportDef()

	oReport := TReport():New("LOCR041","Relatório de Faturamento Analítico",/*cPerg*/,{|oReport| PrintReport(oReport)},"Impressão Relatório de Faturamento Analítico.")
	oReport:SetLandscape(.T.)

	oSecCab := TRSection():New( oReport , "Faturamento", {"QRY"} )
	oSecCab:SetColSpace(0)    //Define o espaçamento entre as colunas

		TRCell():New( oSecCab, "C5_FILIAL"     	, "QRY","FILIAL")
		TRCell():New( oSecCab, "FPY_PROJET"    	, "QRY","PROJETO")
		TRCell():New( oSecCab, "FP0_CLI"    	, "QRY","CLIENTE")
		TRCell():New( oSecCab, "FP0_CLINOM"   	, "QRY","NOME CLIENTE")
        TRCell():New( oSecCab, "FPZ_FROTA"    	, "QRY","EQUIPAMENTO")
		TRCell():New( oSecCab, "T9_NOME"    	, "QRY","DESC. EQUIPAMENTO ")
		TRCell():New( oSecCab, "C5_EMISSAO"    	, "QRY","EMIS. PED")
		TRCell():New( oSecCab, "FPY_PEDVEN"     , "QRY","PEDIDO")
		TRCell():New( oSecCab, "FPY_TIPFAT"     , "QRY","TIP FATURA.")
		TRCell():New( oSecCab, "C6_VALOR"      	, "QRY","VALOR PEDIDO")
		TRCell():New( oSecCab, "FPA_GERAEM"     , "QRY","GERA EM")
		TRCell():New( oSecCab, "DIAS", "QRY","DIAS PENDENTES",,,,{|| DiasPend()})
		TRCell():New( oSecCab, "C5_CLIENTE"     , "QRY","CLI. FATURA")
		TRCell():New( oSecCab, "F2_EMISSAO"     , "QRY","EMIS. FATURA")
		TRCell():New( oSecCab, "F2_DOC"      	, "QRY","FATURA")
//		TRCell():New( oSecCab, "E1_VALOR"       , "QRY","VLR FATURA")
		TRCell():New( oSecCab, "D2_TOTAL"       , "QRY","VALOR FATURA")
		TRCell():New( oSecCab, "E1_VENCTO"      , "QRY","VENCTO FATURA")

Return

Static Function DiasPend()

Local nDias := 0

	If !Empty(QRY->FPA_GERAEM)
		If !Empty(QRY->F2_EMISSAO) .and. QRY->FPA_GERAEM > QRY->F2_EMISSAO
			nDias := QRY->FPA_GERAEM - QRY->F2_EMISSAO
		EndIf
	EndIf

Return nDias

Static Function PrintReport(oReport)

	Local cQuery := Nil
	Local aBindParam := {}
	Local oTotPed
	Local oTotFat

    	oTotPed := TRFUNCTION():NEW(oSecCab:CELL("C6_VALOR") ,"Total Pedido","SUM",oBreak,,,, .T., .F.,.F. ) //"TOTAL  "
		oTotFat := TRFUNCTION():NEW(oSecCab:CELL("D2_TOTAL") ,"Total Fatura","SUM",oBreak,,,, .T., .F.,.F. ) //"TOTAL  "

		cQuery := "SELECT C5.C5_FILIAL, C6.C6_NUM,C6.C6_NOTA,C6.C6_CLI,C6.C6_VALOR,FPZ.FPZ_PROJET,FPZ.FPZ_PEDVEN, FPA.FPA_GERAEM, F2.F2_EMISSAO,"
		cQuery += " CASE WHEN FPZ.FPZ_FROTA = '' THEN FPA.FPA_PRODUT"
		cQuery += " ELSE FPZ.FPZ_FROTA  END FPZ_FROTA,"
		cQuery += " FPY.FPY_TIPFAT,E1.E1_EMISSAO,E1.E1_VENCTO,E1.E1_VALOR, F2.F2_DOC, "
		cQuery += " F2.F2_EMISSAO,FPY.FPY_PROJET,FP0.FP0_CLI,FP0.FP0_CLINOM,C5.C5_EMISSAO,C5.C5_CLIENTE,FPY.FPY_PEDVEN,
		cQuery += " CASE WHEN FPZ.FPZ_FROTA = '' THEN C6.C6_DESCRI"
		cQuery += " ELSE T9.T9_NOME  END T9_NOME,"
		cQuery += " C6.C6_PRODUTO,FPA.FPA_GERAEM,D2.D2_TOTAL, "
		cQuery += "CASE "
		cQuery += "WHEN FPA.FPA_GERAEM = '' THEN 0 "
		cQuery += "WHEN FPA.FPA_GERAEM  <> '' THEN 0 "
		cQuery += "END DIAS "
		cQuery += "FROM "+RetSQlName("SC5")+" C5 INNER JOIN "+RetSQlName("SC6")+" C6 ON C6.C6_FILIAL=C5.C5_FILIAL AND C6.C6_NUM=C5.C5_NUM AND C6.D_E_L_E_T_=''  "
		cQuery += "LEFT JOIN "+RetSQlName("SF2")+" F2 ON F2.F2_FILIAL=C5.C5_FILIAL AND F2.F2_DOC=C5.C5_NOTA AND F2.F2_SERIE=C5.C5_SERIE AND C5.D_E_L_E_T_=' ' "
		cQuery += "LEFT JOIN "+RetSQlName("SD2")+" D2 ON D2.D2_FILIAL=C6.C6_FILIAL AND D2.D2_DOC=C6.C6_NOTA AND D2.D2_SERIE=C6.C6_SERIE AND C6.D_E_L_E_T_=' ' AND D2.D2_ITEM =C6.C6_ITEM "
		cQuery += "LEFT JOIN "+RetSQlName("FPY")+" FPY ON FPY.FPY_FILIAL=C5.C5_FILIAL AND FPY.FPY_PEDVEN=C5.C5_NUM AND FPY.D_E_L_E_T_=' ' "
		cQuery += "LEFT JOIN "+RetSQlName("SE1")+" E1 ON E1.E1_FILIAL=F2.F2_FILIAL AND E1.E1_NUM=F2.F2_DOC AND E1.E1_PREFIXO=F2.F2_SERIE AND E1.E1_CLIENTE=F2.F2_CLIENTE AND "
		cQuery += "E1.E1_LOJA=F2.F2_LOJA AND F2.F2_DUPL=E1.E1_NUM AND E1.D_E_L_E_T_='' AND F2.D_E_L_E_T_='' "
		cQuery += "INNER JOIN "+RetSQlName("FP0")+" FP0 ON FP0.FP0_FILIAL = FPY.FPY_FILIAL AND FP0.FP0_PROJET = FPY.FPY_PROJET AND FP0.D_E_L_E_T_='' "
        cQuery += "INNER JOIN "+RetSQlName("FPZ")+" FPZ ON FPZ.FPZ_FILIAL=C6.C6_FILIAL AND FPZ.FPZ_PEDVEN=C6.C6_NUM AND FPZ.FPZ_ITEM=C6.C6_ITEM AND FPZ.D_E_L_E_T_=' ' "
		cQuery += "LEFT JOIN "+RetSQlName("FPA")+" FPA ON FPA.FPA_FILIAL=FPY.FPY_FILIAL AND FPA.FPA_PROJET=FPY.FPY_PROJET AND FPA.FPA_AS = FPZ.FPZ_AS AND FPA.D_E_L_E_T_=' ' "
		cQuery += "LEFT JOIN "+RetSQlName("ST9")+" T9 ON T9.T9_FILIAL=FPZ.FPZ_FILIAL AND T9.T9_CODBEM=FPZ.FPZ_FROTA AND T9.D_E_L_E_T_=' ' "
		cQuery += "WHERE C5.C5_FILIAL BETWEEN  ? AND ?  "
		Aadd(aBindParam, MV_PAR01)
		Aadd(aBindParam, MV_PAR02)
		cQuery += "AND FPZ.FPZ_FROTA BETWEEN  ? AND ?  "
		Aadd(aBindParam, MV_PAR03)
		Aadd(aBindParam, MV_PAR04)
		cQuery += "AND C5.C5_EMISSAO BETWEEN  ? AND ? "
		Aadd(aBindParam, DTOS(MV_PAR05))
		Aadd(aBindParam, DTOS(MV_PAR06))
		if MV_PAR13 = 1 // Só faturados
			cQuery += "AND D2.D2_EMISSAO BETWEEN  ? AND ? "
			Aadd(aBindParam, DTOS(MV_PAR07))
			Aadd(aBindParam, DTOS(MV_PAR08))
		endif
		cQuery += "AND C5.C5_CLIENTE BETWEEN  ? AND ? "
		Aadd(aBindParam, MV_PAR09)
		Aadd(aBindParam, MV_PAR10)
		cQuery += "AND FPY.FPY_PROJET BETWEEN  ? AND ? "
		Aadd(aBindParam, MV_PAR11)
		Aadd(aBindParam, MV_PAR12)
		cQuery += "AND FPY.FPY_TIPFAT <> 'R' "
		if MV_PAR13 = 1
			cQuery += "AND C5.C5_NOTA <> ' ' "
		elseif MV_PAR13 = 2
			cQuery += "AND C5.C5_NOTA = ' ' "
		endif

	cQuery := ChangeQuery(cQuery)

	MPSysOpenQuery(cQuery,"QRY",,,aBindParam)
	//TcQuery cQuery New Alias "QRY"

	oSecCab:BeginQuery()
	//oSecCab:EndQuery({{"QRY"},cQuery})
    TCSetField("QRY", "C5_EMISSAO", "D", 8, 0)
    TCSetField("QRY", "F2_EMISSAO", "D", 8, 0)
    TCSetField("QRY", "E1_VENCTO",  "D", 8, 0)
	TCSetField("QRY", "E1_EMISSAO", "D", 8, 0)
	TCSetField("QRY", "FPA_GERAEM", "D", 8, 0)

	oSecCab:Print()

Return

STATIC FUNCTION PERGPARAM(CPERG)
LOCAL APERGS  := {}
LOCAL _cFilDe   := Criavar("FP0_FILIAL")
LOCAL _cFilAte  := Replicate("Z",Len(_cFilDe))
LOCAL _CCLIDE := IIF(FIELDPOS("C5_CLIENTE")>0,SPACE(GETSX3CACHE("C5_CLIENTE","X3_TAMANHO")),SPACE(06))
LOCAL _CCLIAT := IIF(FIELDPOS("C5_CLIENTE")>0,REPLICATE("Z",GETSX3CACHE("C5_CLIENTE","X3_TAMANHO")),REPLICATE("Z",06))
LOCAL _CPRODE := IIF(FIELDPOS("FPY_PROJET")>0,SPACE(GETSX3CACHE("FPY_PROJET","X3_TAMANHO")),SPACE(22))
LOCAL _CPROAT := IIF(FIELDPOS("FPY_PROJET")>0,REPLICATE("Z",GETSX3CACHE("FPY_PROJET","X3_TAMANHO")),REPLICATE("Z",22))
LOCAL _CBEMDE := IIF(FIELDPOS("FPZ_FROTA")>0,SPACE(GETSX3CACHE("FPZ_FROTA","X3_TAMANHO")),SPACE(16))
LOCAL _CBEMAT := IIF(FIELDPOS("FPZ_FROTA")>0,REPLICATE("Z",GETSX3CACHE("FPZ_FROTA","X3_TAMANHO")),REPLICATE("Z",16))
LOCAL LRET    := .F.
Local dEmDe   := (Date())
Local dEmAte  := (Date())
Local dVcDe   := (Date())
Local dVcAte  := (Date())
Local nTipo   

AADD(APERGS ,{1,"Filial De",_CFILDE,"@!",".T.","SM0"  ,".T.", 50,.F.}) 
AADD(APERGS ,{1,"Filial Até",_CFILATE,"@!",".T.","SM0"  ,".T.", 50,.F.})
AADD(APERGS ,{1,"Equipamento De",_CBEMDE,"@!",".T.","ST9"  ,".T.", 50,.F.})
AADD(APERGS ,{1,"Equipamento Até",_CBEMAT,"@!",".T.","ST9"  ,".T.", 50,.F.})
aAdd(APERGS, {1,"Emissão PV De", dEmDe,  "",".T.","",    ".T.", 80,  .F.})
aAdd(APERGS, {1,"Emissão PV Até",dEmAte, "",".T.","",    ".T.", 80,  .F.})
aAdd(APERGS, {1,"Emissão NF De",dVcDe,  "",             ".T.",        "",    ".T.", 80,  .F.})
aAdd(APERGS, {1,"Emissão NF Até",dVcAte,  "",             ".T.",        "",    ".T.", 80,  .F.})
AADD(APERGS ,{1,"Cliente De",_CCLIDE,"@!",".T.","SA1"  ,".T.", 50,.F.})
AADD(APERGS ,{1,"Cliente Até",_CCLIAT,"@!",".T.","SA1"  ,".T.", 50,.F.})
AADD(APERGS ,{1,"Projeto De",_CPRODE,"@!",".T.","FP0"  ,".T.", 50,.F.})
AADD(APERGS ,{1,"Projeto Até",_CPROAT,"@!",".T.","FP0"  ,".T.", 50,.F.})
AADD(APERGS, {2,"Somente Faturados",nTipo, {"1=Sim","2=Não","3=Ambos"},     122, ".T.", .F.})

If ParamBox(APERGS, "Informe os parâmetros")

 		IF VALTYPE( MV_PAR13 ) == "C"
			IF "1" $  ALLTRIM(MV_PAR13)
				MV_PAR13 := 1
			ELSEIF "2" $ ALLTRIM(MV_PAR13)
				MV_PAR13 := 2
			ELSEIF "3" $ ALLTRIM(MV_PAR13)
				MV_PAR13 := 3
			ENDIF
		END
	LRET := .T.
ENDIF

RETURN (LRET)

