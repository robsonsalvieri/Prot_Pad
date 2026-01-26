#INCLUDE 'protheus.ch'
#INCLUDE 'topconn.ch'
/*/{PROTHEUS.DOC} LOCR042.PRW
ITUP BUSINESS - TOTVS RENTAL
RELATÓRIO DE FATURAMENTO
@TYPE FUNCTION
@AUTHOR ROSSANA
@SINCE 09/08/2024
/*/ 
Function LOCR042()

Private oReport   := Nil
Private oSection  := Nil
Private oSectionB := Nil
Private oSection1 := Nil

	If PergParam()
		processa({||ReportDef()},,"Gerando Relatório...")    
        oReport:PrintDialog()
    endif

Return

Static Function ReportDef()
Private cBranco := ""

	oReport := TReport():New("LOCR042","Histórico de Orçamento",/*cPerg*/,{|oReport| PrintReport(oReport)},"Impressão Relatório de Faturamento.")
	oReport:SetLandscape(.T.)
	
	oSection := TRSection():New( oReport , "Cliente", {"HST"}, , , , , , .t., .t.)

	TRCell():New( oSection, "FILIAL"     , "HST","FILIAL",,10,.f.)
	TRCell():New( oSection, "CLIENTE"    , "HST","CLIENTE",,10,.f.)
	TRCell():New( oSection, "NOMECLI"    , "HST","NOME",,50,.f.)
	TRCell():New( oSection, "PROJETO"    , "HST","PROJETO",,22,.f.)

	oSectionB := TRSection():New( oSection , " ",)

	TRCell():New( oSectionB, cBranco   ,  ," ",,10,.f.)

	oSection1 := TRSection():New( oSection , "Histórico de Orçamento", {"HST"} )
	TRCell():New( oSection1, "OCORRE"     , "HST","OCORRENCIA",,40,.f.)
	TRCell():New( oSection1, "OBRA"    	  , "HST","OBRA",,5,.f.)
	TRCell():New( oSection1, "EMISSAO"    , "HST","EMISSAO",,15,.f.)
	TRCell():New( oSection1, "PEDIDO"     , "HST","PEDIDO",,10,.f.)
	TRCell():New( oSection1, "NOTA"    	  , "HST","NOTA",,50,.f.)
	TRCell():New( oSection1, "PRODUTO"    , "HST","CODIGO",,50,.f.)
	TRCell():New( oSection1, "XDESCR"     , "HST","EQUIPAMENTO",,40,.f.)
	TRCell():New( oSection1, "PERIODO"    , "HST","PERIODO",,30,.f.)
	TRCell():New( oSection1, "QUANTIDADE" , "HST","QUANTIDADE  ", "@E 9,999,999",20,.f.)
	TRCell():New( oSection1, "VALLOC"     , "HST","VAL. LOCAÇÃO", "@E 9,999,999.99",20,.f.)
	TRCell():New( oSection1, "VALNF"      , "HST","VAL. NF     ", "@E 9,999,999.99",20,.f.)

Return


Static Function PrintReport(oReport)

Local cQuery   := ""
Local cQryFQZ  := ""
Local cQryFPZ  := ""
Local cAuxFil  := Criavar("FP0_FILIAL")
Local cAuxCli  := ""
Local cAuxPro  := ""
Local nCount   := 0

	cQuery := "SELECT * "
	cQuery += "FROM "+RetSQlName("FP0")+" FP0, "+RetSQlName("FP1")+" FP1," +RetSQlName("FPA")+" FPA "
	cQuery += "LEFT JOIN "+RetSQlName("SD2")+" SD2 "
	cQuery += "   ON SD2.D2_FILIAL  = FPA.FPA_FILIAL "
	cQuery += "  AND SD2.D2_DOC     = FPA.FPA_NFREM "
	cQuery += "  AND SD2.D2_ITEM    = FPA.FPA_ITEREM "
	cQuery += "  AND SD2.D2_SERIE   = FPA.FPA_SERREM "
	cQuery += "  AND SD2.D_E_L_E_T_ = '' "
	cQuery += "WHERE FPA.D_E_L_E_T_ = '' "
	cQuery += "  AND FP1.D_E_L_E_T_ = '' "
	cQuery += "  AND FP0.D_E_L_E_T_ = '' "
	cQuery += "  AND FP0.FP0_FILIAL = FPA.FPA_FILIAL "
	cQuery += "  AND FP0.FP0_PROJET = FPA.FPA_PROJET "
	cQuery += "  AND FP1.FP1_FILIAL = FPA.FPA_FILIAL "
	cQuery += "  AND FP1.FP1_PROJET = FPA.FPA_PROJET "
	cQuery += "  AND FP1.FP1_OBRA   = FPA.FPA_OBRA "
	cQuery += "  AND FP0.FP0_FILIAL BETWEEN  ? AND ? "
	cQuery += "  AND FP1.FP1_CLIORI BETWEEN  ? AND ? "
	cQuery += "  AND FP0.FP0_PROJET BETWEEN  ? AND ? "
	cQuery += "  AND FP1.FP1_OBRA   BETWEEN  ? AND ? "
	cQuery += "  AND FPA.FPA_PRODUT BETWEEN  ? AND ? "
	cQuery += "  AND FPA.FPA_GRUA   BETWEEN  ? AND ? "
	cQuery += "  AND FP0.FP0_DATINC BETWEEN  ? AND ? "
	cQuery += "ORDER BY FP1_CLIORI, FPA_PROJET, FPA_OBRA, FPA_SEQGRU"
	
	If Select("QRY") > 0
		Dbselectarea("QRY")
		QRY->(DbCloseArea())
	EndIF

	aBindParam := {MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,MV_PAR05,MV_PAR06,MV_PAR07,MV_PAR08,MV_PAR09,MV_PAR10,MV_PAR11,MV_PAR12,DTOS(MV_PAR13),DTOS(MV_PAR14)}

	cQuery := ChangeQuery(cQuery)
	MPSysOpenQuery(cQuery,"QRY",,,aBindParam)

	Hist_Struct()

	DbSelectArea("QRY")
	DbGoTop()
	While !Eof()
//---------------------------------------------------------------------------------------------------------------
		If !Empty(QRY->FPA_NFREM)
			RecLock("HST",.t.)
			HST->FILIAL		:= QRY->FP0_FILIAL
			If Empty(QRY->FPA_SEQSUB)
				HST->XORDEM	    	:= "1"
				HST->OCORRE	 		:= "REMESSA"
			Else
				HST->XORDEM	    	:= "4"
				HST->OCORRE	 		:= "REMESSA POR SUBSTITUIÇÃO"
			EndIf
			HST->CLIENTE		:= QRY->FP1_CLIORI
			HST->NOMECLI		:= POSICIONE("SA1",1,xFilial("SA1")+QRY->FP1_CLIORI+QRY->FP1_LOJORI,"A1_NOME")
			HST->PROJETO		:= QRY->FP0_PROJET
			HST->OBRA    		:= QRY->FP1_OBRA
			HST->EMISSAO   		:= Stod(QRY->FPA_DNFREM)
			HST->PEDIDO   		:= QRY->FPA_PEDIDO
			HST->NOTA   		:= AllTrim(QRY->FPA_NFREM) + "/" + AllTrim(QRY->FPA_SERREM)
			If Empty(QRY->FPA_GRUA)
				HST->PRODUTO  	:= QRY->FPA_PRODUT
				HST->XDESCR     := POSICIONE("SB1",1,xFilial("SB1")+QRY->FPA_PRODUT,"B1_DESC")
			Else
				HST->PRODUTO   	:= QRY->FPA_GRUA
				HST->XDESCR     := POSICIONE("ST9",1,xFilial("ST9")+QRY->FPA_GRUA,"T9_NOME")
			EndIf
			HST->PERIODO   		:= Dtoc(Stod(QRY->FPA_DTINI))+" a "+Dtoc(Stod(QRY->FPA_DTENRE))
			HST->QUANTIDADE   	:= QRY->FPA_QUANT
			HST->VALLOC   		:= QRY->FPA_VRHOR
			HST->VALNF   		:= QRY->D2_TOTAL
			MsUnLock()

//---------------------------------------------------------------------------------------------------------------

			cQryFQZ := "SELECT * "
			cQryFQZ += "  FROM "+RetSQlName("FQZ")+" FQZ, "+RetSQlName("SD1")+" SD1 "
			cQryFQZ += " WHERE FQZ.D_E_L_E_T_ = '' "
			cQryFQZ += "   AND SD1.D_E_L_E_T_ = '' "
			cQryFQZ += "   AND FQZ.FQZ_AS     = ? "
			cQryFQZ += "   AND SD1.D1_DOC     = FQZ.FQZ_DOC "
			cQryFQZ += "   AND SD1.D1_SERIE   = FQZ.FQZ_SERIE "
			cQryFQZ += "   AND SD1.D1_ITEM    = FQZ.FQZ_ITEM "
			cQryFQZ += "   AND SD1.D1_FORNECE = FQZ.FQZ_FORNE "
			cQryFQZ += "   AND SD1.D1_LOJA    = FQZ.FQZ_LOJA  "
			If Select("QRYFQZ") > 0
				Dbselectarea("QRYFQZ")
				QRYFQZ->(DbCloseArea())
			EndIF

			aBindParam := {QRY->FPA_AS}

			cQryFQZ := ChangeQuery(cQryFQZ)
			MPSysOpenQuery(cQryFQZ,"QRYFQZ",,,aBindParam)

			While !QRYFQZ->(Eof())
				RecLock("HST",.t.)
				HST->FILIAL		:= QRY->FP0_FILIAL
				If QRY->FPA_TIPOSE == "S"
					HST->XORDEM	    	:= "3"
					HST->OCORRE	 		:= "SUBSTITUIDO"
				Else
					HST->XORDEM 	    	:= "2"
					HST->OCORRE	 		:= "DEVOLUÇÃO"
				EndIf
				HST->CLIENTE		:= QRY->FP1_CLIORI
				HST->NOMECLI		:= POSICIONE("SA1",1,xFilial("SA1")+QRY->FP1_CLIORI+QRY->FP1_LOJORI,"A1_NOME")
				HST->PROJETO		:= QRY->FP0_PROJET
				HST->OBRA    		:= QRY->FP1_OBRA
				HST->EMISSAO   		:= Stod(QRYFQZ->FQZ_EMISS)
				HST->PEDIDO   		:= " "
				HST->NOTA   		:= AllTrim(QRYFQZ->FQZ_DOC) + "/" + AllTrim(QRYFQZ->FQZ_SERIE)
				If Empty(QRY->FPA_GRUA)
					HST->PRODUTO  	:= QRY->FPA_PRODUT
					HST->XDESCR     := POSICIONE("SB1",1,xFilial("SB1")+QRY->FPA_PRODUT,"B1_DESC")
				Else
					HST->PRODUTO   	:= QRY->FPA_GRUA
					HST->XDESCR     := POSICIONE("ST9",1,xFilial("ST9")+QRY->FPA_GRUA,"T9_NOME")
				EndIf
				HST->PERIODO   		:= Dtoc(Stod(QRYFQZ->FQZ_DTINI))+" a "+Dtoc(Stod(QRYFQZ->FQZ_RETIRA))
				HST->QUANTIDADE   	:= QRYFQZ->FQZ_QTD
				HST->VALLOC   		:= QRYFQZ->FQZ_VLRPRO
				HST->VALNF   		:= QRYFQZ->D1_TOTAL
				MsUnLock()
				QRYFQZ->(DbSkip())
			End
		EndIf

//---------------------------------------------------------------------------------------------------------------

			cQryFPZ := "SELECT * "
			cQryFPZ += "FROM "+RetSQlName("FPY")+" FPY, "+RetSQlName("FPZ")+" FPZ, "+RetSQlName("SC6")+" SC6 "
			cQryFPZ += "WHERE FPY.D_E_L_E_T_  = '' "
			cQryFPZ += "  AND FPZ.D_E_L_E_T_  = '' "
			cQryFPZ += "  AND SC6.D_E_L_E_T_  = '' "
			cQryFPZ += "  AND FPY.FPY_PROJET  = ? "
			cQryFPZ += "  AND FPZ.FPZ_PEDVEN  = FPY.FPY_PEDVEN "
			cQryFPZ += "  AND FPZ.FPZ_PROJET  = ? "
			cQryFPZ += "  AND FPZ.FPZ_AS      = ? "
			cQryFPZ += "  AND FPY.FPY_TIPFAT IN ('P','M')"
			cQryFPZ += "  AND SC6.C6_NUM      = FPZ.FPZ_PEDVEN "
			cQryFPZ += "  AND SC6.C6_ITEM     = FPZ.FPZ_ITEM "
			cQryFPZ += "  AND SC6.C6_NOTA <> ' '"
			If Select("QRYFPZ") > 0
				Dbselectarea("QRYFPZ")
				QRYFPZ->(DbCloseArea())
			EndIF

			aBindParam := {QRY->FPA_PROJET,QRY->FPA_PROJET,QRY->FPA_AS}

			cQryFPZ := ChangeQuery(cQryFPZ)
			MPSysOpenQuery(cQryFPZ,"QRYFPZ",,,aBindParam)

			While !QRYFPZ->(Eof())
				FPG->(DbSetOrder(1))
				RecLock("HST",.t.)
				HST->FILIAL		:= QRY->FP0_FILIAL
				If FPG->(DbSeek(QRY->FPA_FILIAL+QRY->FPA_PROJET+QRY->FPA_AS+QRY->FPA_OBRA))
					HST->XORDEM	    	:= "6"
					HST->OCORRE	 		:= "CUSTO EXTRA"
				Else
					If QRYFPZ->FPY_TIPFAT == "M"
						HST->XORDEM	    	:= "5"
						HST->OCORRE	 		:= "MEDIÇÃO"
					Else
						HST->XORDEM	    	:= "5"
						HST->OCORRE	 		:= "FATURAMENTO"
					EndIf
				EndIf
				HST->CLIENTE		:= QRY->FP1_CLIORI
				HST->NOMECLI		:= POSICIONE("SA1",1,xFilial("SA1")+QRY->FP1_CLIORI+QRY->FP1_LOJORI,"A1_NOME")
				HST->PROJETO		:= QRY->FP0_PROJET
				HST->OBRA    		:= QRY->FP1_OBRA
				HST->EMISSAO   		:= Stod(QRYFPZ->C6_DATFAT)
				HST->PEDIDO   		:= QRYFPZ->FPZ_PEDVEN
				HST->NOTA   		:= AllTrim(QRYFPZ->C6_NOTA) + "/" + AllTrim(QRYFPZ->C6_SERIE)
				If Empty(QRY->FPA_GRUA)
					HST->PRODUTO  	:= QRY->FPA_PRODUT
					HST->XDESCR     := POSICIONE("SB1",1,xFilial("SB1")+QRY->FPA_PRODUT,"B1_DESC")
				Else
					HST->PRODUTO   	:= QRY->FPA_GRUA
					HST->XDESCR     := POSICIONE("ST9",1,xFilial("ST9")+QRY->FPA_GRUA,"T9_NOME")
				EndIf
				HST->PERIODO   		:= QRYFPZ->FPZ_PERLOC
				HST->QUANTIDADE   	:= QRYFPZ->C6_QTDVEN
				HST->VALLOC   		:= QRYFPZ->C6_VALOR
				HST->VALNF   		:= QRYFPZ->C6_VALOR
				MsUnLock()
				QRYFPZ->(DbSkip())
			End
			

		DbSelectArea("QRY")
		DbSkip()
	End

	QRY->(DbCloseArea())

	DbSelectArea("HST")
//	Index on HST->CLIENTE+HST->PROJETO+HST->OBRA+Dtos(HST->EMISSAO) to HSTTEMP
	DbGoTop()
	While !Eof()

		cAuxFil := HST->FILIAL
		cAuxCli := HST->CLIENTE
		cAuxPro := HST->PROJETO
		nCount++

		oSection:Init(.t.)
		If nCount > 1
			oSection:PrintHeader()
		EndIf
		oSection:PrintLine()

		oSection1:Init(.t.)
		If nCount > 1
			oSection1:PrintHeader()
		EndIf
	
		While HST->FILIAL == cAuxFil .and. HST->CLIENTE == cAuxCli .and. HST->PROJETO == cAuxPro
			oSection1:Printline()
			HST->(DbSkip())
		EndDo	

		oSectionB:Init(.t.)
		oSectionB:PrintLine()

	End

	oSection:Finish()
	oSection1:Finish()
	oSectionB:Finish()
	HST->(DbCloseArea())

Return


Static Function Hist_Struct

Local aRegHist  := {}
Local _cFil     := Criavar("FP0_FILIAL")
Local nTamFil	:= Len(_cFil)

	oTempTable:= FWTemporaryTable():New("HST")

	AADD(aRegHist,{"FILIAL","C",nTamFil,0})
	AADD(aRegHist,{"CLIENTE","C",6,0})
	AADD(aRegHist,{"NOMECLI","C",40,0})
	AADD(aRegHist,{"XORDEM","C",1,0})
	AADD(aRegHist,{"OCORRE","C",50,0})
	AADD(aRegHist,{"PROJETO","C",22,0})
	AADD(aRegHist,{"OBRA","C",3,0})
	AADD(aRegHist,{"EMISSAO","D",10,0})
	AADD(aRegHist,{"PEDIDO","C",6,0})
	AADD(aRegHist,{"NOTA","C",14,0})
	AADD(aRegHist,{"PRODUTO","C",30,0})
	AADD(aRegHist,{"XDESCR","C",40,0})
	AADD(aRegHist,{"PERIODO","C",30,0})
	AADD(aRegHist,{"QUANTIDADE","N",18,0})
	AADD(aRegHist,{"VALLOC","N",18,2})
	AADD(aRegHist,{"VALNF","N",18,2})

	oTemptable:SetFields( aRegHist )
	oTempTable:AddIndex( "HSTIND", {"CLIENTE","PROJETO","OBRA","EMISSAO"})
	oTempTable:Create()

Return

Static Function PergParam()

LOCAL aPergs    := {}
LOCAL _cFilDe   := Criavar("FP0_FILIAL")
LOCAL _cFilAte  := Replicate("Z",Len(_cFilDe))
LOCAL _cCliDe   := SPACE(06)
LOCAL _cCliAte  := "ZZZZZZ"
LOCAL _cProjDe  := SPACE(22)
LOCAL _cProjAte := "ZZZZZZZZZZZZZZZZZZZZZZ"
LOCAL _cObraDe  := SPACE(3)
LOCAL _cObraAte := "ZZZ"
LOCAL _cProdDe  := SPACE(30)
LOCAL _cProdAte := "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"
LOCAL _cBemDe   := SPACE(16)
LOCAL _cBemAte  := "ZZZZZZZZZZZZZZZZ"
Local _dDtIni   := (Date())
Local _dDtFim   := (Date())
Local lRet 		:= .T.

AADD(APERGS ,{1,"Filial De",_CFILDE,"@!",".T.","SM0"  ,".T.", 50,.F.}) 
AADD(APERGS ,{1,"Filial Até",_CFILATE,"@!",".T.","SM0"  ,".T.", 50,.F.})
AADD(APERGS ,{1,"Cliente De",_CCLIDE,"@!",".T.","SA1"  ,".T.", 50,.F.}) 
AADD(APERGS ,{1,"Cliente Até",_CCLIATE,"@!",".T.","SA1"  ,".T.", 50,.F.})
AADD(APERGS ,{1,"Projeto De",_CPROJDE,"@!",".T.","FP0T"  ,".T.", 50,.F.}) 
AADD(APERGS ,{1,"Projeto Até",_CPROJATE,"@!",".T.","FP0T"  ,".T.", 50,.F.}) 
AADD(APERGS ,{1,"Obra De",_COBRADE,"@!",".T.",""  ,".T.", 50,.F.}) 
AADD(APERGS ,{1,"Obra Até",_COBRAATE,"@!",".T.",""  ,".T.", 50,.F.}) 
AADD(APERGS ,{1,"Produto De",_CPRODDE,"@!",".T.","SB1"  ,".T.", 50,.F.}) 
AADD(APERGS ,{1,"Produto Até",_CPRODATE,"@!",".T.","SB1"  ,".T.", 50,.F.}) 
AADD(APERGS ,{1,"Bem De",_CBEMDE,"@!",".T.","ST9"  ,".T.", 50,.F.}) 
AADD(APERGS ,{1,"Bem Até",_CBEMATE,"@!",".T.","ST9"  ,".T.", 50,.F.}) 
aAdd(APERGS, {1,"Data de ",_dDtIni,  "",             ".T.",        "",    ".T.", 80,  .T.})
aAdd(APERGS, {1,"Data Ate",_dDtFim,  "",             ".T.",        "",    ".T.", 80,  .T.})

If ParamBox(APERGS, "Informe os parâmetros") 
		LRET := .T.
ENDIF
*/
RETURN (LRET)

