#INCLUDE 'protheus.ch'
#INCLUDE 'topconn.ch'
/*/{PROTHEUS.DOC} LOCR040.PRW
ITUP BUSINESS - TOTVS RENTAL
RELATÓRIO DE FATURAMENTO
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

Static Function ReportDef()

	oReport := TReport():New("LOCR040","Relatório de Faturamento",/*cPerg*/,{|oReport| PrintReport(oReport)},"Impressão Relatório de Faturamento.")
	oReport:SetLandscape(.T.)
	
	oSecCab := TRSection():New( oReport , "Faturamento", {"QRY"} )
	
    If MV_PAR09 == 1 .OR. MV_PAR09 == 2 //FATURADOS E NÃO FATURADOS
		TRCell():New( oSecCab, "FPY_PROJET"     , "QRY","PROJETO")
		TRCell():New( oSecCab, "FP0_CLI"   		, "QRY","CLIENTE")
		TRCell():New( oSecCab, "FP0_CLINOM"    	, "QRY","NOME CLIENTE")
		TRCell():New( oSecCab, "C5_EMISSAO"    	, "QRY","EMIS. PED")
		TRCell():New( oSecCab, "FPY_PEDVEN"     , "QRY","PEDIDO")
		TRCell():New( oSecCab, "FPY_TIPFAT"     , "QRY","TIP FATURA.")
		TRCell():New( oSecCab, "PED_VALOR"   	, "QRY","VALOR PEDIDO", "@E 9,999,999.99")
		TRCell():New( oSecCab, "C5_CLIENTE"    	, "QRY","CLI. FATURA")
		TRCell():New( oSecCab, "F2_EMISSAO"     , "QRY","EMIS. FATURA")
		TRCell():New( oSecCab, "F2_DOC"      	, "QRY","FATURA")
		TRCell():New( oSecCab, "E1_VALOR"      	, "QRY","VALOR FATURA")
		TRCell():New( oSecCab, "E1_VENCTO"      , "QRY","VENCTO FATURA")
	ElseIf MV_PAR09 == 3 //AMBOS
		TRCell():New( oSecCab, "FPY_PROJET"     , "QRY","PROJETO")
		TRCell():New( oSecCab, "FP0_CLI"    	, "QRY","CLIENTE")
		TRCell():New( oSecCab, "FP0_CLINOM"    	, "QRY","NOME CLIENTE")
		TRCell():New( oSecCab, "C5_EMISSAO"    	, "QRY","EMIS. PED")
		TRCell():New( oSecCab, "FPY_PEDVEN"     , "QRY","PEDIDO")
		TRCell():New( oSecCab, "FPY_TIPFAT"     , "QRY","TIP FATURA.")
		TRCell():New( oSecCab, "PED_VALOR"      , "QRY","VALOR PEDIDO", "@E 9,999,999.99")
		TRCell():New( oSecCab, "C5_CLIENTE"    	, "QRY","CLI. FATURA")
		TRCell():New( oSecCab, "E1_EMISSAO"     , "QRY","EMIS. FATURA")
		TRCell():New( oSecCab, "E1_NUM"      	, "QRY","FATURA")
		TRCell():New( oSecCab, "E1_VALOR"      	, "QRY","VALOR FATURA")
		TRCell():New( oSecCab, "E1_VENCTO"      , "QRY","VENCTO FATURA")
	EndIf	
	//TRFunction():New(oSecCab:Cell("F2_VALBRUT"),/*cId*/,"SUM"     ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F.           ,.T.           ,.F.        ,oSecCab)
Return

Static Function PrintReport(oReport)

Local cQuery := Nil

Local oTotPed
Local oTotFat

	oTotFat := TRFUNCTION():NEW(oSecCab:CELL("E1_VALOR") ,"Total Fatura","SUM",oBreak,,,, .T., .F.,.F. ) //"TOTAL  "

	If MV_PAR09 == 1 //FATURADOS
		cQuery := "SELECT C5.C5_NUM,C5.C5_NOTA,C5.C5_EMISSAO,C5.C5_CLIENTE,FPY.FPY_PROJET,FPY.FPY_PEDVEN,FPY.FPY_TIPFAT,E1.E1_EMISSAO,E1.E1_VENCTO,E1.E1_VALOR, "
		cQuery += "F2.F2_DOC,F2.F2_EMISSAO,F2.F2_VALBRUT,FP0.FP0_CLI,FP0.FP0_CLINOM,SUM(C6.C6_VALOR+C6.C6_VALDESC) PED_VALOR "
		cQuery += "FROM "+RetSQlName("SC5")+" C5 INNER JOIN "+RetSQlName("SC6")+" C6 ON C6.C6_FILIAL=C5.C5_FILIAL AND C6.C6_NUM=C5.C5_NUM AND C6.D_E_L_E_T_=''  "
		cQuery += "LEFT JOIN "+RetSQlName("SF2")+" F2 ON F2.F2_FILIAL=C5.C5_FILIAL AND F2.F2_DOC=C5.C5_NOTA AND F2.F2_SERIE=C5.C5_SERIE AND C5.D_E_L_E_T_=' ' "
		cQuery += "LEFT JOIN "+RetSQlName("FPY")+" FPY ON FPY.FPY_FILIAL=C5.C5_FILIAL AND FPY.FPY_PEDVEN=C5.C5_NUM AND FPY.D_E_L_E_T_=' ' "
		cQuery += "LEFT JOIN "+RetSQlName("SE1")+" E1 ON E1.E1_FILIAL=F2.F2_FILIAL AND E1.E1_NUM=F2.F2_DOC AND E1.E1_PREFIXO=F2.F2_SERIE AND E1.E1_CLIENTE=F2.F2_CLIENTE AND "
		cQuery += "E1.E1_LOJA=F2.F2_LOJA AND F2.F2_DUPL=E1.E1_NUM AND E1.D_E_L_E_T_='' AND F2.D_E_L_E_T_='' "
		cQuery += "INNER JOIN "+RetSQlName("FP0")+" FP0 ON FP0.FP0_FILIAL = FPY.FPY_FILIAL AND FP0.FP0_PROJET = FPY.FPY_PROJET AND FP0.D_E_L_E_T_='' "
		cQuery += "WHERE C5.C5_EMISSAO BETWEEN  ? AND ? "
		cQuery += "AND F2.F2_EMISSAO BETWEEN  ? AND ? "
		cQuery += "AND C5.C5_CLIENTE BETWEEN  ? AND ? "
		cQuery += "AND FPY.FPY_PROJET BETWEEN  ? AND ? "
		cQuery += "AND FPY.FPY_TIPFAT <> 'R' "
		cQuery += "AND C5.C5_NOTA <> ' ' "
		cQuery += "GROUP BY FPY.FPY_PROJET,C5.C5_CLIENTE,C5.C5_NUM,C5.C5_NOTA,C5.C5_EMISSAO,FPY.FPY_PEDVEN,FPY.FPY_TIPFAT,E1.E1_EMISSAO,E1.E1_VENCTO,E1.E1_VALOR, F2.F2_DOC,"
		cQuery += "F2.F2_EMISSAO,F2.F2_VALBRUT,FP0.FP0_CLI,FP0.FP0_CLINOM"
		cQuery += "ORDER BY FPY.FPY_PROJET,C5.C5_CLIENTE,C5.C5_NUM,C5.C5_NOTA,C5.C5_EMISSAO,FPY.FPY_PEDVEN,FPY.FPY_TIPFAT,E1.E1_EMISSAO,E1.E1_VENCTO,E1.E1_VALOR, F2.F2_DOC,"
		cQuery += "F2.F2_EMISSAO,F2.F2_VALBRUT,FP0.FP0_CLI,FP0.FP0_CLINOM"
	EndIf 	

	If MV_PAR09 == 2 //NÃO FATURADOS
		cQuery := "SELECT C5.C5_NUM,C5.C5_NOTA,C5.C5_EMISSAO,C5.C5_CLIENTE,SUM(C6.C6_VALOR+C6.C6_VALDESC) PED_VALOR ,FPY.FPY_PROJET,FPY.FPY_PEDVEN,FPY.FPY_TIPFAT, "
		cQuery += "FP0.FP0_CLI,FP0.FP0_CLINOM "
		cQuery += "FROM "+RetSQlName("SC5")+" C5 INNER JOIN "+RetSQlName("SC6")+" C6 ON C6.C6_FILIAL=C5.C5_FILIAL AND C6.C6_NUM=C5.C5_NUM AND C6.D_E_L_E_T_=''  "
		cQuery += "LEFT JOIN "+RetSQlName("FPY")+" FPY ON FPY.FPY_FILIAL=C5.C5_FILIAL AND FPY.FPY_PEDVEN=C5.C5_NUM AND FPY.D_E_L_E_T_=' ' "
		cQuery += "INNER JOIN "+RetSQlName("FP0")+" FP0 ON FP0.FP0_FILIAL = FPY.FPY_FILIAL AND FP0.FP0_PROJET = FPY.FPY_PROJET AND FP0.D_E_L_E_T_='' "
		cQuery += "WHERE C5.C5_EMISSAO BETWEEN  ? AND ? "
		cQuery += "AND C5.C5_CLIENTE BETWEEN  ? AND ? "
		cQuery += "AND FPY.FPY_PROJET BETWEEN  ? AND ? "
		cQuery += "AND FPY.FPY_TIPFAT <> 'R' "
		cQuery += "AND C5.C5_NOTA = ' ' "
		cQuery += "GROUP BY FPY.FPY_PROJET,C5.C5_CLIENTE,C5.C5_NUM,C5.C5_NOTA,C5.C5_EMISSAO,FPY.FPY_PEDVEN,FPY.FPY_TIPFAT,FP0.FP0_CLI,FP0.FP0_CLINOM"
		cQuery += "ORDER BY FPY.FPY_PROJET,C5.C5_CLIENTE,C5.C5_NUM,C5.C5_NOTA,C5.C5_EMISSAO,FPY.FPY_PEDVEN,FPY.FPY_TIPFAT,FP0.FP0_CLI,FP0.FP0_CLINOM"
	EndIf 		

	If MV_PAR09 == 3 //AMBOS
		cQuery := "SELECT C5.C5_NUM,C5.C5_NOTA,C5.C5_EMISSAO,C5.C5_CLIENTE,FPY.FPY_PROJET,FPY.FPY_PEDVEN,FPY.FPY_TIPFAT, "
		cQuery += "FP0.FP0_CLI,E1.E1_EMISSAO,E1.E1_VENCTO,E1.E1_VALOR,E1_NUM,FP0.FP0_CLINOM,SUM(C6.C6_VALOR+C6.C6_VALDESC) PED_VALOR "
		cQuery += "FROM "+RetSQlName("SC5")+" C5 INNER JOIN "+RetSQlName("SC6")+" C6 ON C6.C6_FILIAL=C5.C5_FILIAL AND C6.C6_NUM=C5.C5_NUM AND C6.D_E_L_E_T_=''  "
		cQuery += "LEFT JOIN "+RetSQlName("FPY")+" FPY ON FPY.FPY_FILIAL=C5.C5_FILIAL AND FPY.FPY_PEDVEN=C5.C5_NUM AND FPY.D_E_L_E_T_=' ' "
		cQuery += "INNER JOIN "+RetSQlName("FP0")+" FP0 ON FP0.FP0_FILIAL = FPY.FPY_FILIAL AND FP0.FP0_PROJET = FPY.FPY_PROJET AND FP0.D_E_L_E_T_='' "
		cQuery += "LEFT JOIN "+RetSQlName("SE1")+" E1 ON E1.E1_FILIAL=C5.C5_FILIAL AND E1.E1_NUM=C5.C5_NOTA AND E1.E1_PREFIXO=C5.C5_SERIE AND E1.E1_CLIENTE=C5.C5_CLIENTE AND "
		cQuery += "E1.E1_LOJA=C5.C5_LOJACLI AND E1.D_E_L_E_T_='' "		
		cQuery += "WHERE C5.C5_EMISSAO BETWEEN  ? AND ? "
		cQuery += "AND C5.C5_CLIENTE BETWEEN  ? AND ? "
		cQuery += "AND FPY.FPY_PROJET BETWEEN  ? AND ? "
		cQuery += "AND FPY.FPY_TIPFAT <> 'R' "
		cQuery += "GROUP BY FPY.FPY_PROJET,C5.C5_CLIENTE,C5.C5_NUM,C5.C5_NOTA,C5.C5_EMISSAO,FPY.FPY_PEDVEN,FPY.FPY_TIPFAT, FP0.FP0_CLI,E1.E1_EMISSAO,"
		cQuery += "E1.E1_VENCTO,E1.E1_VALOR,E1_NUM,FP0.FP0_CLINOM"
		cQuery += "ORDER BY FPY.FPY_PROJET,C5.C5_CLIENTE,C5.C5_NUM,C5.C5_NOTA,C5.C5_EMISSAO,FPY.FPY_PEDVEN,FPY.FPY_TIPFAT, FP0.FP0_CLI,E1.E1_EMISSAO,"
		cQuery += "E1.E1_VENCTO,E1.E1_VALOR,E1_NUM,FP0.FP0_CLINOM"
	EndIf 			
	
	If Select("QRY") > 0
		Dbselectarea("QRY")
		QRY->(DbCloseArea())
	EndIF
	cQuery := ChangeQuery(cQuery)

	If MV_PAR09 == 1
		aBindParam := {DTOS(MV_PAR01),DTOS(MV_PAR02),DTOS(MV_PAR03),DTOS(MV_PAR04),MV_PAR05,MV_PAR06,MV_PAR07,MV_PAR08}
	else
		aBindParam := {DTOS(MV_PAR01),DTOS(MV_PAR02),MV_PAR05,MV_PAR06,MV_PAR07,MV_PAR08}
	EndIf	

	MPSysOpenQuery(cQuery,"QRY",,,aBindParam)
	//TcQuery cQuery New Alias "QRY"
	
	oSecCab:BeginQuery()
	//oSecCab:EndQuery({{"QRY"},cQuery})
    TCSetField("QRY", "C5_EMISSAO", "D", 8, 0)
    TCSetField("QRY", "F2_EMISSAO", "D", 8, 0)
    TCSetField("QRY", "E1_VENCTO",  "D", 8, 0)
	TCSetField("QRY", "E1_EMISSAO", "D", 8, 0)
	oSecCab:Print()

Return

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

aAdd(APERGS, {1,"Emissão PV De",dEmDe,  "",             ".T.",        "",    ".T.", 80,  .F.})
aAdd(APERGS, {1,"Emissão PV Até",dEmAte,  "",             ".T.",        "",    ".T.", 80,  .T.})
aAdd(APERGS, {1,"Emissão NF De",dVcDe,  "",             ".T.",        "",    ".T.", 80,  .F.})
aAdd(APERGS, {1,"Emissão NF Até",dVcAte,  "",             ".T.",        "",    ".T.", 80,  .T.})
AADD(APERGS ,{1,"Cliente De",_CCLIDE,"@!",".T.","SA1"  ,".T.", 50,.F.}) 
AADD(APERGS ,{1,"Cliente Até",_CCLIAT,"@!",".T.","SA1"  ,".T.", 50,.F.})
AADD(APERGS ,{1,"Projeto De",_CPRODE,"@!",".T.","FP0"  ,".T.", 50,.F.}) 
AADD(APERGS ,{1,"Projeto Até",_CPROAT,"@!",".T.","FP0"  ,".T.", 50,.F.}) 
AADD(APERGS, {2,"Somente Faturados",nTipo, {"1=Sim","2=Não","3=Ambos"},     122, ".T.", .F.})

If ParamBox(APERGS, "Informe os parâmetros") 
	
 		IF VALTYPE( MV_PAR09 ) == "C"
			IF "1" $  ALLTRIM(MV_PAR09) 
				MV_PAR09 := 1
			ELSEIF "2" $ ALLTRIM(MV_PAR09) 
				MV_PAR09 := 2
			ELSEIF "3" $ ALLTRIM(MV_PAR09) 
				MV_PAR09 := 3				
			ENDIF
		END
	LRET := .T.
ENDIF

RETURN (LRET)

