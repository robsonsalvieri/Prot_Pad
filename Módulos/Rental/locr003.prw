#INCLUDE "locr003.ch"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPRINTSETUP.CH"

#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
//#INCLUDE "TBICONN.CH"
//#INCLUDE "PROTHEUS.CH"

/*/{PROTHEUS.DOC} LOCR003.PRW
ITUP BUSINESS - TOTVS RENTAL
DEMONSTRATIVO DE FATURAMENTO
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
		10/09/2025, VALTENIO OLIVEIRA, AJUSTADO ESPACO NOS D_E_L_E_T_ = ' ',  
		para atender Base Oracle
/*/
FUNCTION LOCR003()
LOCAL   _AAREAOLD := GETAREA()
LOCAL   _AAREASM0 := SM0->(GETAREA())
Local cFilBkp	:= cFilAnt
PRIVATE CPERG   := "LOCP013"
Private c_Local := GetTempPath()

	IF PERGPARAM(CPERG)
		//Valida se o usuário pode acessar informações da filial indicada
		If LOCR00101(MV_PAR04, NIL)
			DBSELECTAREA("SM0")
			SM0->(DBSETORDER(1))
			IF SM0->(DBSEEK(CEMPANT+MV_PAR04))
				cFilAnt := MV_PAR04
				PROCESSA({|| IMPREL() } , STR0001 , STR0002 , .T.)  //"IMPRIMINDO FATURA..."###"AGUARDE..."
				//devolve a filial
				cFilAnt := cFilBkp
			ENDIF
		EndIf
	ENDIF

	SM0->(RESTAREA( _AAREASM0 ))
	RESTAREA( _AAREAOLD )

RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ IMPREL    º AUTOR ³ IT UP CONSULTORIA  º DATA ³ 03/08/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ DEFINICAO DO LAYOUT DO RELATORIO                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION IMPREL()
Local _CTIPO		:= ""
Local _APRODUTOS  	:= {}
Local _DDTINI		:= STOD("")
Local _DDTFIM		:= STOD("")
Local _CCONTRATO  	:= ""
Local _CEMPRESA   	:= ""
Local _COBSFAT   	:= ""
Local CCNPJ			:= ""
Local CEND			:= ""
Local CBAIRRO		:= ""
Local CCIDADE		:= ""
Local CCEP			:= ""
Local CUF			:= ""
Local CTEL			:= ""
Local CFAX			:= ""
Local cPeriodo  	:= ""
Local cChave 		:= ""
Local CLOGO			:= ""
Local CARQUIVO   	:= ""
Local _CQUERY      	:= ""
Local cAsPedido		:= ""
Local I           	:= 0
Local NLIN        	:= 10
Local _NTOTAL      	:= 0
Local _NVALOR      	:= 0
Local nTamLin   	:= 10
Local AAREASM0		:= {}
Local aAreaSC6  	:= SC6->(GetArea())
Local aAreaFPA  	:= FPA->(GetArea())
Local OREPORT
Local OBRUSH      	:= TBRUSH():NEW("",CLR_HGRAY)
Local LADJUSTTOLEGACY := .F.
Local LDISABLESETUP   := .t.//DENNIS CALABREZ - CHAMADO 30566 08/03/23 - ALTERADO PARA .T., POIS ESTAVA COM PROBLEMAS COM O TOTVS PRINTER PARA A GERAÇÃO DO ARQUIVO DE IMPRESSÃO
Local lLocr003A 	:= ExistBlock("LOCR003A")
Local lMvLocBac		:= SuperGetMv("MV_LOCBAC",.F.,.F.) //Integração com Módulo de Locações SIGALOC
Local oStatement
Local aObra         := {}
Local lGera			:= .F.
Local cVar 			:= ""
Local xT
Local cDescLogo		:= ""
Local cGrpCompany	:= ""
Local cCodEmpGrp	:= ""
Local cUnitGrp		:= ""
Local cFilGrp		:= ""
Local cCmpUsr       := GetMv("MV_CMPUSR",,"")
Local _cFinalQuery 	:= ""
Local aBindParam 	:= {}

Local nPos1   	:= 0
Local cBloco1 	:= ""
Local cBloco2 	:= ""
Local cAuxVar 	:= ""
Local _TextoTes	:= ""

PRIVATE NMINLEFT   	:= 10
PRIVATE NMAXWIDTH 	:= 584
PRIVATE NMAXHEIGHT	:= 2900
PRIVATE NMEIO		:= ((NMAXWIDTH+NMINLEFT)/2)

	CARQUIVO := STR0003 + ALLTRIM(MV_PAR01) + " - " + ALLTRIM(MV_PAR02) + "_" + DTOS(DATE()) + ".PDF" //"FATURA "

	OREPORT := FWMSPRINTER():NEW(CARQUIVO , IMP_PDF , LADJUSTTOLEGACY , c_local, LDISABLESETUP, , , , , , .f., .f.)

	OREPORT:SETPORTRAIT()
	OREPORT:SETPAPERSIZE(9)
	OREPORT:SETVIEWPDF( .T. )

	//"TIMES NEW ROMAN"
	OFONT1    := TFONTEX():NEW(OREPORT,"COURIER",10,10,.T.,.T.,.F.)// 1
	OFONT2    := TFONTEX():NEW(OREPORT,"COURIER",08,08,.F.,.F.,.F.)// 1
	OFONT3    := TFONTEX():NEW(OREPORT,"COURIER",12,12,.T.,.T.,.F.)// 1
	OFONT4    := TFONTEX():NEW(OREPORT,"COURIER",12,12,.F.,.F.,.F.)// 1

	// --> BUSCA AS INFORMACOES DAS FILIAIS.
	AAREASM0 := SM0->(GETAREA())
	DBSELECTAREA("SM0")
	SM0->(DBSETORDER(1))
	IF SM0->(DBSEEK(CEMPANT+MV_PAR04))
		CEND     := ALLTRIM(SM0->M0_ENDCOB)
		CBAIRRO  := ALLTRIM(SM0->M0_BAIRCOB)
		CCIDADE  := ALLTRIM(SM0->M0_CIDCOB)
		CCEP     := SUBSTR(SM0->M0_CEPCOB,1,5) + '-' + SUBSTR(SM0->M0_CEPCOB,6,3)
		CUF	     := ALLTRIM(SM0->M0_ESTCOB)
		CTEL     := "(" + SUBSTR(SM0->M0_TEL,4,2) + ") " + SUBSTR(SM0->M0_TEL,7,4) + "-" + SUBSTR(SM0->M0_TEL,11,4)
		IF EMPTY(ALLTRIM(SM0->M0_FAX))
			CFAX := ""
		ELSE
			CFAX := "(" + SUBSTR(SM0->M0_FAX,4,2) + ") " + SUBSTR(SM0->M0_FAX,7,4) + "-" + SUBSTR(SM0->M0_FAX,11,4)
		ENDIF
		CCNPJ    := SUBSTR(SM0->M0_CGC,1,2) + "." + SUBSTR(SM0->M0_CGC,3,3) + "." + SUBSTR(SM0->M0_CGC,6,3) + "/" +;
					SUBSTR(SM0->M0_CGC,9,4) + "-" + SUBSTR(SM0->M0_CGC,13,2)
	ENDIF
	SM0->(RESTAREA(AAREASM0))

	cGrpCompany	:= AllTrim(FWGrpCompany())
	cCodEmpGrp	:= AllTrim(FWCodEmp())
	cUnitGrp	:= AllTrim(FWUnitBusiness())
	cFilGrp		:= AllTrim(FWFilial())
	If !Empty(cUnitGrp)
		cDescLogo	:= cGrpCompany + cCodEmpGrp + cUnitGrp + cFilGrp
	Else
		cDescLogo	:= cEmpAnt + cFilAnt
	EndIf
	CLOGO := GETSRVPROFSTRING("STARTPATH","") + "LOGO" + cDescLogo + ".jpg"

	IF SELECT("TRBFAT") > 0
		TRBFAT->(DBCLOSEAREA())
	ENDIF

	oStatement := FwExecStatement():New()


	_CQUERY := " SELECT F2_FILIAL FILIAL, F2_SERIE SERIE, F2_DOC NUMFAT, F2_EMISSAO EMISSAO, MAX(COALESCE(F4_TEXTO,?)) F4_TEXTO, MAX(C6_NUM) PEDIDO, "  //'LOCAÇÃO DE BENS MÓVEIS'
	_CQUERY += " 	   RTRIM(LTRIM(A1_NOME)) RAZSOC, A1_END A1_END, A1_BAIRRO, A1_MUN, A1_EST, A1_CEP, A1_CGC, D2_TES, "
	_CQUERY += " 	   CASE WHEN A1_INSCR = ''"
	_CQUERY += " 			THEN 'ISENTO'"
	_CQUERY += " 			ELSE A1_INSCR   END A1_INSCR , SE1NF.E1_VENCTO VENCTO,"
	_CQUERY += " 	   F2_VALBRUT, F2_DESCONT, SUM(COALESCE(SE1IMP.E1_VALOR,0)) VALRET,"
	_CQUERY += " 	   F2_VALBRUT - COALESCE(F2_DESCONT,0) - SUM(COALESCE(SE1IMP.E1_VALOR,0)) - SE1NF.E1_IRRF TOTAL,"
	_CQUERY += " 	   CASE WHEN A1_ENDCOB = ''"
	_CQUERY += " 			THEN A1_END"
	_CQUERY += " 			ELSE A1_ENDCOB  END A1_ENDCOB  , "
	_CQUERY += " 	   CASE WHEN A1_BAIRROC = ''"
	_CQUERY += " 			THEN A1_BAIRRO"
	_CQUERY += " 			ELSE A1_BAIRROC END A1_BAIRROC , "
	_CQUERY += " 	   CASE WHEN A1_MUNC = ''"
	_CQUERY += " 			THEN A1_MUN"
	_CQUERY += " 			ELSE A1_MUNC    END A1_MUNC    , "
	_CQUERY += " 	   CASE WHEN A1_ESTC = ''"
	_CQUERY += " 			THEN A1_EST"
	_CQUERY += " 			ELSE A1_ESTC    END A1_ESTC    , "
	_CQUERY += " 	   CASE WHEN A1_CEPC = ''"
	_CQUERY += " 			THEN A1_CEP ELSE A1_CEPC END A1_CEPC,"
	_CQUERY += " 	   CASE WHEN A1_ENDENT = ''"
	_CQUERY += " 			THEN A1_END"
	_CQUERY += " 			ELSE A1_ENDENT  END A1_ENDENT  , "
	_CQUERY += " 	   CASE WHEN A1_BAIRROE = ''"
	_CQUERY += " 			THEN A1_BAIRRO"
	_CQUERY += " 			ELSE A1_BAIRROE END A1_BAIRROE , "
	_CQUERY += " 	   CASE WHEN A1_MUNE = ''"
	_CQUERY += " 			THEN A1_MUN"
	_CQUERY += " 			ELSE A1_MUNE    END A1_MUNE    , "
	_CQUERY += " 	   CASE WHEN A1_ESTE = ''"
	_CQUERY += " 			THEN A1_EST"
	_CQUERY += " 			ELSE A1_ESTE    END A1_ESTE    , "
	_CQUERY += " 	   CASE WHEN A1_CEPE = ''"
	_CQUERY += " 			THEN A1_CEP ELSE A1_CEPE END A1_CEPE, "
	_CQUERY += " 		A6_COD, A6_AGENCIA, A6_DVAGE, A6_NUMCON, A6_DVCTA, SE1NF.E1_IRRF IRFAT, FPZ_PROJET"
	_CQUERY += "		FROM " + RETSQLNAME("SF2") + " SF2 "
	_CQUERY += "        INNER JOIN " + RETSQLNAME("SA1") + " SA1    ON  SF2.F2_CLIENTE = A1_COD       AND  SF2.F2_LOJA = SA1.A1_LOJA "
	_CQUERY += "                                                    AND SA1.D_E_L_E_T_ = ' ' "
	If !empty(alltrim(xFilial("SA1")))
		_cQuery += " AND SA1.A1_FILIAL = '"+xFilial("SA1")+"' "
	EndIF
	_CQUERY += "        INNER JOIN " + RETSQLNAME("SD2") + " SD2    ON  SD2.D2_FILIAL  = F2_FILIAL    AND  SD2.D2_DOC  = F2_DOC "
	_CQUERY += "                                                    AND SD2.D2_SERIE   = F2_SERIE "
	_CQUERY += "                                                    AND SD2.D_E_L_E_T_ = ' ' "
	_CQUERY += " 	    INNER JOIN " + RETSQLNAME("SC6") + " SC6    ON  SC6.C6_FILIAL  = F2_FILIAL    AND  SC6.C6_NOTA = F2_DOC "
	_CQUERY += "                                                    AND SC6.C6_SERIE   = F2_SERIE     AND  SC6.C6_ITEM = D2_ITEM "
	_CQUERY += "                                                    AND SC6.D_E_L_E_T_ = ' ' "
	_CQUERY += " 	    INNER JOIN " + RETSQLNAME("FPZ") + " FPZ    ON  FPZ.FPZ_FILIAL = SC6.C6_FILIAL "
	_CQUERY += "                                                    AND FPZ.FPZ_PEDVEN = SC6.C6_NUM    "
	_CQUERY += "                                                    AND FPZ.FPZ_ITEM   = SC6.C6_ITEM   "
	_CQUERY += "                                                    AND FPZ.D_E_L_E_T_ = ' ' "
	_CQUERY += "        LEFT  JOIN " + RETSQLNAME("SF4") + " SF4    ON  SF4.F4_CODIGO  = D2_TES "
	_CQUERY += "                                                    AND SF4.D_E_L_E_T_ = ' ' "
	_CQUERY += "        LEFT  JOIN " + RETSQLNAME("SE1") + " SE1NF  ON  F2_FILIAL = SE1NF.E1_FILIAL   AND  F2_DOC = SE1NF.E1_NUM "
	_CQUERY += "                                                    AND F2_SERIE  = SE1NF.E1_PREFIXO "
	_CQUERY += "                                                    AND SE1NF.E1_TIPO  = 'NF' "
	_CQUERY += "                                                    AND SE1NF.D_E_L_E_T_ = ' ' "
	_CQUERY += " 	    LEFT  JOIN " + RETSQLNAME("SE1") + " SE1IMP ON  F2_FILIAL = SE1IMP.E1_FILIAL  AND  F2_DOC = SE1IMP.E1_NUM "
	_CQUERY += "                                                    AND F2_SERIE  = SE1IMP.E1_PREFIXO "
	_CQUERY += "                                                    AND SE1IMP.E1_TIPO IN ('IR-','CS-','PI-','CF-','IS-','IN-')"
	_CQUERY += "                                                    AND SE1IMP.D_E_L_E_T_ = ' ' "
	_CQUERY += " 	    LEFT  JOIN " + RETSQLNAME("SA6") + " SA6    ON  SA6.A6_FILIAL  = SE1NF.E1_FILIAL "
	_CQUERY += "                                                    AND SA6.A6_COD     = SE1NF.E1_PORTADO "
	_CQUERY += "                                                    AND SA6.A6_AGENCIA = SE1NF.E1_AGEDEP "
	_CQUERY += "                                                    AND SA6.A6_NUMCON  = SE1NF.E1_CONTA "
	_CQUERY += "                                                    AND SA6.D_E_L_E_T_ = ' ' "
	_CQUERY += " WHERE  F2_FILIAL = '" + XFILIAL("SF2") + "'"
	_CQUERY += "   AND  F2_DOC BETWEEN ? AND ? "  // inject 2 e 3
	_CQUERY += "   AND  F2_SERIE = ? " // inject 4
	_CQUERY += "   AND  SF2.D_E_L_E_T_ = ' '"
	_CQUERY += "   AND  SF2.F2_TIPO NOT IN ('D','B') "

	_CQUERY += "  GROUP BY F2_FILIAL, F2_SERIE, F2_DOC , F2_EMISSAO ,  A1_NOME, A1_END , A1_BAIRRO, A1_MUN, A1_EST, A1_CEP, A1_CGC, A1_INSCR , SE1NF.E1_VENCTO,"
	_CQUERY += " 		  F2_VALBRUT, F2_DESCONT, A1_ENDCOB, A1_BAIRROC, A1_MUNC, A1_ESTC, A1_CEPC, D2_TES, " 
	_CQUERY += " 		  A1_ENDENT, A1_BAIRROE, A1_MUNE, A1_ESTE, A1_CEPE, A6_COD, A6_AGENCIA, A6_DVAGE, A6_NUMCON, A6_DVCTA, SE1NF.E1_IRRF, FPZ_PROJET "

//--------------------------------------------------------------------------------------------------------------------------------------

	_CQUERY += " UNION ALL "

	_CQUERY += " SELECT F2_FILIAL FILIAL, F2_SERIE SERIE, F2_DOC NUMFAT, F2_EMISSAO EMISSAO, MAX(COALESCE(F4_TEXTO,?)) F4_TEXTO, MAX(C6_NUM) PEDIDO,"  //'LOCAÇÃO DE BENS MÓVEIS' // inject 5
	_CQUERY += " 	   RTRIM(LTRIM(A2_NOME)) RAZSOC, A2_END A1_END, A2_BAIRRO A1_BAIRRO, A2_MUN A1_MUN, A2_EST A1_EST, A2_CEP A1_CEP, A2_CGC A1_CGC, D2_TES, "
	_CQUERY += " 	   CASE WHEN A2_INSCR = ''"
	_CQUERY += " 			THEN 'ISENTO'"
	_CQUERY += " 			ELSE A2_INSCR END A2_INSCR, SE1NF.E1_VENCTO VENCTO,"
	_CQUERY += " 	   F2_VALBRUT, F2_DESCONT, SUM(COALESCE(SE1IMP.E1_VALOR,0)) VALRET,"
	_CQUERY += " 	   F2_VALBRUT - COALESCE(F2_DESCONT,0) - SUM(COALESCE(SE1IMP.E1_VALOR,0)) - SE1NF.E1_IRRF TOTAL,"
	_CQUERY += " 	   CASE WHEN A2_END = ''"
	_CQUERY += " 			THEN A2_END"
	_CQUERY += " 			ELSE A2_END END A1_ENDCOB,"
	_CQUERY += " 	   CASE WHEN A2_BAIRRO = ''"
	_CQUERY += " 			THEN A2_BAIRRO"
	_CQUERY += " 			ELSE A2_BAIRRO END A1_BAIRROC,"
	_CQUERY += " 	   CASE WHEN A2_MUN = ''"
	_CQUERY += " 			THEN A2_MUN"
	_CQUERY += " 			ELSE A2_MUN END A1_MUNC,"
	_CQUERY += " 	   CASE WHEN A2_EST = ''"
	_CQUERY += " 			THEN A2_EST"
	_CQUERY += " 			ELSE A2_EST END A1_ESTC,"
	_CQUERY += " 	   CASE WHEN A2_CEP = ''"
	_CQUERY += " 			THEN A2_CEP ELSE A2_CEP END A1_CEPC,"
	_CQUERY += " 	   CASE WHEN A2_END = ''"
	_CQUERY += " 			THEN A2_END"
	_CQUERY += " 			ELSE A2_END END A1_ENDENT,"
	_CQUERY += " 	   CASE WHEN A2_BAIRRO = ''"
	_CQUERY += " 			THEN A2_BAIRRO"
	_CQUERY += " 			ELSE A2_BAIRRO END A1_BAIRROE,"
	_CQUERY += " 	   CASE WHEN A2_MUN = ''"
	_CQUERY += " 			THEN A2_MUN"
	_CQUERY += " 			ELSE A2_MUN END A1_MUNE,"
	_CQUERY += " 	   CASE WHEN A2_EST = ''"
	_CQUERY += " 			THEN A2_EST"
	_CQUERY += " 			ELSE A2_EST END A1_ESTE,"
	_CQUERY += " 	   CASE WHEN A2_CEP = ''"
	_CQUERY += " 			THEN A2_CEP ELSE A2_CEP END A1_CEPE, "
	_CQUERY += " 		A6_COD, A6_AGENCIA, A6_DVAGE, A6_NUMCON, A6_DVCTA, SE1NF.E1_IRRF IRFAT, FPZ_PROJET"
	_CQUERY += "   FROM " + RETSQLNAME("SF2") + " SF2 INNER JOIN " + RETSQLNAME("SA2") + " SA2"
	_CQUERY += "     ON F2_CLIENTE = A2_COD"
	_CQUERY += "    AND F2_LOJA    = A2_LOJA"
	_CQUERY += "    AND SA2.D_E_L_E_T_ = ' '"
	_CQUERY += "        INNER JOIN " + RETSQLNAME("SD2") + " SD2"
	_CQUERY += "     ON D2_FILIAL = F2_FILIAL"
	_CQUERY += "    AND D2_DOC    = F2_DOC"
	_CQUERY += "    AND D2_SERIE  = F2_SERIE"
	_CQUERY += "    AND SD2.D_E_L_E_T_ = ' '"
	_CQUERY += " 	   INNER JOIN " + RETSQLNAME("SC6") + " SC6"
	_CQUERY += " 	ON C6_FILIAL = F2_FILIAL"
	_CQUERY += "    AND C6_NOTA   = F2_DOC"
	_CQUERY += "    AND C6_SERIE  = F2_SERIE"
	_CQUERY += "    AND C6_ITEM   = D2_ITEM"
	_CQUERY += "    AND SC6.D_E_L_E_T_ = ' '"
	_CQUERY += " 	    INNER JOIN " + RETSQLNAME("FPZ") + " FPZ    ON  FPZ.FPZ_FILIAL = SC6.C6_FILIAL "
	_CQUERY += "                                                    AND FPZ.FPZ_PEDVEN = SC6.C6_NUM    "
	_CQUERY += "                                                    AND FPZ.FPZ_ITEM   = SC6.C6_ITEM   "
	_CQUERY += "                                                    AND FPZ.D_E_L_E_T_ = ' ' "
	_CQUERY += "        LEFT JOIN " + RETSQLNAME("SF4") + " SF4"
	_CQUERY += "     ON F4_CODIGO = D2_TES"
	_CQUERY += "    AND SF4.D_E_L_E_T_ = ' '"
	_CQUERY += "        LEFT JOIN " + RETSQLNAME("SE1") + " SE1NF"
	_CQUERY += "     ON F2_FILIAL = SE1NF.E1_FILIAL"
	_CQUERY += "    AND F2_DOC    = SE1NF.E1_NUM"
	_CQUERY += "    AND F2_SERIE  = SE1NF.E1_PREFIXO"
	_CQUERY += "    AND SE1NF.E1_TIPO  = 'NF'"
	_CQUERY += "    AND SE1NF.D_E_L_E_T_ = ' '"
	_CQUERY += " 	   LEFT JOIN " + RETSQLNAME("SE1") + " SE1IMP"
	_CQUERY += "     ON F2_FILIAL = SE1IMP.E1_FILIAL"
	_CQUERY += "    AND F2_DOC    = SE1IMP.E1_NUM"
	_CQUERY += "    AND F2_SERIE  = SE1IMP.E1_PREFIXO"
	_CQUERY += "    AND SE1IMP.E1_TIPO   IN ('IR-','CS-','PI-','CF-','IS-','IN-')"
	_CQUERY += "    AND SE1IMP.D_E_L_E_T_ = ' '"
	_CQUERY += " 	   LEFT JOIN " + RETSQLNAME("SA6") + " SA6"
	_CQUERY += "     ON A6_FILIAL  = SE1NF.E1_FILIAL"
	_CQUERY += "    AND A6_COD     = SE1NF.E1_PORTADO"
	_CQUERY += "    AND A6_AGENCIA = SE1NF.E1_AGEDEP"
	_CQUERY += "    AND A6_NUMCON  = SE1NF.E1_CONTA"
	_CQUERY += "    AND SA6.D_E_L_E_T_ = ' '"
	_CQUERY += "  WHERE F2_FILIAL = '" + XFILIAL("SF2") + "'"
	_CQUERY += "    AND F2_DOC BETWEEN ? AND ? " // inject 6 e 7
	_CQUERY += "    AND F2_SERIE = ? " // inject 8
	_CQUERY += "    AND SF2.D_E_L_E_T_ = ' '"
	_CQUERY += "    AND SF2.F2_TIPO IN ('D','B') "
	_CQUERY += "  GROUP BY F2_FILIAL , F2_SERIE, F2_DOC, F2_EMISSAO, A2_NOME, A2_END, A2_BAIRRO, A2_MUN, A2_EST, A2_CEP, A2_CGC, A2_INSCR, "
	_CQUERY += " 		  SE1NF.E1_VENCTO, F2_VALBRUT, F2_DESCONT , A2_END, A2_BAIRRO, A2_MUN, A2_EST, A2_CEP, D2_TES, " 
	_CQUERY += " 		  A2_END, A2_BAIRRO, A2_MUN, A2_EST, A2_CEP, A6_COD, A6_AGENCIA, A6_DVAGE, A6_NUMCON, A6_DVCTA, SE1NF.E1_IRRF, FPZ_PROJET"

	_CQUERY += "  ORDER BY EMISSAO, NUMFAT"

	//Seta as variaveis da query
	oStatement:SetQuery(_CQUERY)
	oStatement:SetString(1, STR0004     ) //'LOCAÇÃO DE BENS MÓVEIS'
	oStatement:SetString(2, MV_PAR01    )
	oStatement:SetString(3, MV_PAR02    )
	oStatement:SetString(4, MV_PAR03    )
	oStatement:SetString(5, STR0004     ) //'LOCAÇÃO DE BENS MÓVEIS'
	oStatement:SetString(6, MV_PAR01    )
	oStatement:SetString(7, MV_PAR02    )
	oStatement:SetString(8, MV_PAR03    )
*/

	_cFinalQuery := ""
	_cFinalQuery := ChangeQuery(oStatement:GetFixQuery())

	MpSysOpenQuery(_cFinalQuery,"TRBFAT")

//--------------------------------------------------------------------------------------------------------------------------------------

	DbSelectArea("TRBFAT")
	DbGotop()
	WHILE TRBFAT->(!EOF())
		aBindParam := {}
		_CQUERY := "SELECT  SUM(E1_VALOR) VALRET2 "
		_CQUERY += "FROM "+RETSQLNAME("SE1")+" SE1TMP1  "
		_CQUERY += "WHERE SE1TMP1.E1_FILIAL  = '"+XFILIAL("SE1")+"' "
		_CQUERY += "  AND SE1TMP1.E1_NUM     = ? "
		Aadd(aBindParam , TRBFAT->NUMFAT )
		_CQUERY += "  AND SE1TMP1.E1_PREFIXO = ? "
		Aadd(aBindParam , TRBFAT->SERIE )
		_CQUERY += "  AND SE1TMP1.E1_TIPO IN ('IR-','CS-','PI-','CF-','IS-','IN-')
		_CQUERY += "  AND SE1TMP1.D_E_L_E_T_ = ' '"

		_cQuery := ChangeQuery (_CQUERY)
		MPSysOpenQuery(_CQUERY,"TRBDIV",,,aBindParam)

		IF TRBDIV->(!EOF())
			_NVALOR := TRBDIV->VALRET2
		ENDIF

		TRBDIV->(DBCLOSEAREA())

		INCPROC()

		OREPORT:STARTPAGE()

		_COBSFAT   := "" // removido da 94 ALLTRIM(POSICIONE("SC5",1,XFILIAL("SC5")+TRBFAT->PEDIDO,"C5_XOBSFAT"))

		_CTIPO	   := ""
		_CCONTRATO := ""
		_CEMPRESA  := ""
		_APRODUTOS := {}
		_DDTINI	   := STOD("")
		_DDTFIM	   := STOD("")

		NLIN := 25

		// --> MONTA AS CAIXAS

		// --> CABEÇALHO
		OREPORT:BOX( NLIN, NMINLEFT, NLIN+50, NMAXWIDTH,"-1" )
		NLIN +=  50 			// NLIN TOTAL:  75

		// --> INFORMAÇÕES DO PRESTADOR DO SERVIÇO
		OREPORT:BOX( NLIN, NMINLEFT, NLIN+90, NMEIO     )
		OREPORT:BOX( NLIN, NMEIO   , NLIN+90, NMAXWIDTH )
		NLIN += 105 			// NLIN TOTAL: 180

		// --> INFORMAÇÕES DO TOMADOR DO SERVIÇO
		OREPORT:BOX( NLIN, NMINLEFT, NLIN+90, NMAXWIDTH )
		NLIN += 102 			// NLIN TOTAL: 282

		// --> SERVIÇOS
		//OREPORT:BOX( NLIN, NMINLEFT, NLIN+410, NMAXWIDTH )
		NLIN += 420 			// NLIN TOTAL: 702

		// FRANK 27/10/20
		//OREPORT:BOX( NLIN, NMINLEFT, NLIN+85, NMINLEFT+85 )
		//OREPORT:BOX( NLIN, NMINLEFT+85, NLIN+85, NMAXWIDTH )
		// --> INICIA A IMPRESSÃO DAS INFORMAÇÕES
		NLIN :=  30

		OREPORT:FILLRECT( {NLIN, NMINLEFT+3, NLIN+10,NMAXWIDTH }, OBRUSH)
		NLIN +=  15 			// NLIN TOTAL: 45

		OREPORT:FILLRECT( {NLIN, NMINLEFT+3, NLIN+10,NMAXWIDTH }, OBRUSH)
		NLIN +=  15 			// NLIN TOTAL: 60

		OREPORT:FILLRECT( {NLIN, NMINLEFT+3, NLIN+10,NMAXWIDTH }, OBRUSH)
		NLIN :=  38

		OREPORT:SAYBITMAP(NLIN-8,NMINLEFT+3,CLOGO,0098,0040 )

		OREPORT:SAY( NLIN, NMEIO-(len(STR0005)/2), STR0005, OFONT3:OFONT ) //"FATURA"

		_CEMPRESA := ALLTRIM(SM0->M0_NOMECOM)
		XT  := MLCOUNT(_CEMPRESA,30)
		FOR I:=1 TO XT
			OREPORT:SAY( NLIN, NMINLEFT+103, MEMOLINE(_CEMPRESA ,30, I ), OFONT4:OFONT )
			NLIN +=  15
		NEXT I

		NLIN :=  53 			// NLIN TOTAL: 53

		OREPORT:SAY( NLIN, NMEIO- (len(alltrim(TRBFAT->NUMFAT))/2), alltrim(TRBFAT->NUMFAT), OFONT3:OFONT )
		NLIN +=  40 			// NLIN TOTAL: 93

		OREPORT:SAY( NLIN, NMINLEFT+10, STR0006, OFONT1:OFONT ) //"ENDEREÇO: "
		OREPORT:SAY( NLIN, NMINLEFT+60, substr(CEND,1,51 ), OFONT2:OFONT )
		
		//Card DSERLOCA-8532 Valtenio Oliveira buscar o Texto da TES
		_TextoTes:= POSICIONE("SF4",1,XFILIAL("SF4")+TRBFAT->D2_TES,"F4_TEXTO")
		
		OREPORT:SAY( NLIN, NMEIO+10, STR0007, OFONT1:OFONT ) //"NATUREZA OPERAÇÃO: "
		//OREPORT:SAY( NLIN, NMEIO+108, ALLTRIM(TRBFAT->F4_TEXTO), OFONT2:OFONT )
		OREPORT:SAY( NLIN, NMEIO+108, ALLTRIM(_TextoTes), OFONT2:OFONT )
		NLIN +=  15 			// NLIN TOTAL: 108

		OREPORT:SAY( NLIN, NMINLEFT+10, STR0008, OFONT1:OFONT ) //"BAIRRO: "
		OREPORT:SAY( NLIN, NMINLEFT+50, substr(CBAIRRO,1,20), OFONT2:OFONT )

		OREPORT:SAY( NLIN, NMEIO+10, STR0032, OFONT1:OFONT ) //STR0032 //"CONTRATO: "
		OREPORT:SAY( NLIN, NMEIO+108, ALLTRIM(TRBFAT->FPZ_PROJET), OFONT2:OFONT )
		
		OREPORT:SAY( NLIN, ((NMINLEFT+NMEIO)/2), STR0009, OFONT1:OFONT ) //"CIDADE: "
		OREPORT:SAY( NLIN, ((NMINLEFT+NMEIO)/2)+35, substr(CCIDADE,1,24), OFONT2:OFONT )

		NLIN +=  15 			// NLIN TOTAL: 123

		OREPORT:SAY( NLIN, NMINLEFT+10, STR0010, OFONT1:OFONT ) //"CEP: "
		OREPORT:SAY( NLIN, NMINLEFT+50, CCEP, OFONT2:OFONT )

		OREPORT:SAY( NLIN, ((NMINLEFT+NMEIO)/2), STR0011, OFONT1:OFONT ) //"UF: "
		OREPORT:SAY( NLIN, ((NMINLEFT+NMEIO)/2)+30, CUF, OFONT2:OFONT )
		NLIN +=  15 			// NLIN TOTAL: 138

		OREPORT:SAY( NLIN, NMINLEFT+10, STR0012, OFONT1:OFONT ) //"FONE: "
		OREPORT:SAY( NLIN, NMINLEFT+50, CTEL, OFONT2:OFONT )

		OREPORT:SAY( NLIN, ((NMINLEFT+NMEIO)/2), STR0013, OFONT1:OFONT ) //"FAX: "
		OREPORT:SAY( NLIN, ((NMINLEFT+NMEIO)/2)+30, CFAX, OFONT2:OFONT )

		OREPORT:SAY( NLIN, NMEIO+10, STR0014, OFONT1:OFONT ) //"DATA EMISSÃO: "
		OREPORT:SAY( NLIN, NMEIO+80, DTOC(STOD(TRBFAT->EMISSAO)), OFONT2:OFONT )
		NLIN +=  15 			// NLIN TOTAL: 153

		OREPORT:SAY( NLIN, NMINLEFT+10, STR0015, OFONT1:OFONT ) //"CNPJ: "
		OREPORT:SAY( NLIN, NMINLEFT+50, CCNPJ, OFONT2:OFONT )

		OREPORT:SAY( NLIN, ((NMINLEFT+NMEIO)/2), STR0016, OFONT1:OFONT ) //"CCM: "
		OREPORT:SAY( NLIN, ((NMINLEFT+NMEIO)/2)+30, ALLTRIM(SM0->M0_INSCM), OFONT2:OFONT )

		OREPORT:SAY( NLIN, NMEIO+10, STR0017, OFONT1:OFONT ) //"NÚMERO PEDIDO: "
		OREPORT:SAY( NLIN, NMEIO+80, TRBFAT->PEDIDO, OFONT2:OFONT )
		NLIN +=  25 			// NLIN TOTAL: 178

		OREPORT:FILLRECT( {NLIN-10, 0010, NLIN,NMAXWIDTH }, OBRUSH)
		OREPORT:SAY( NLIN-1, NMEIO-30, STR0018, OFONT3:OFONT ) //"DESTINATÁRIO"
		NLIN +=  18 			// NLIN TOTAL: 196

		OREPORT:SAY( NLIN, NMINLEFT+10, STR0019, OFONT1:OFONT ) //"RAZÃO SOCIAL: "
		OREPORT:SAY( NLIN, NMINLEFT+75, ALLTRIM(TRBFAT->RAZSOC), OFONT2:OFONT )
		NLIN +=  15 			// NLIN TOTAL: 211

		OREPORT:SAY( NLIN, NMINLEFT+10, STR0006, OFONT1:OFONT ) //"ENDEREÇO: "
		OREPORT:SAY( NLIN, NMINLEFT+60, ALLTRIM(TRBFAT->A1_END), OFONT2:OFONT )
		NLIN +=  15 			// NLIN TOTAL: 226

		OREPORT:SAY( NLIN, NMINLEFT+10, STR0008, OFONT1:OFONT ) //"BAIRRO: "
		OREPORT:SAY( NLIN, NMINLEFT+50, substr(TRBFAT->A1_BAIRRO,1,35), OFONT2:OFONT )

		OREPORT:SAY( NLIN, NMEIO-80, STR0020, OFONT1:OFONT ) //"MUNICÍPIO: "
		OREPORT:SAY( NLIN, NMEIO-26, substr(TRBFAT->A1_MUN,1,38), OFONT2:OFONT )

		OREPORT:SAY( NLIN, ((NMEIO+NMAXWIDTH)/2), STR0011, OFONT1:OFONT ) //"UF: "
		OREPORT:SAY( NLIN, ((NMEIO+NMAXWIDTH)/2)+20, ALLTRIM(TRBFAT->A1_EST), OFONT2:OFONT )

		OREPORT:SAY( NLIN, ((NMEIO+NMAXWIDTH)/2)+60, STR0010, OFONT1:OFONT ) //"CEP: "
		OREPORT:SAY( NLIN, ((NMEIO+NMAXWIDTH)/2)+80, ALLTRIM(Transform(TRBFAT->A1_CEP, "@R 99999-999")), OFONT2:OFONT )
		NLIN +=  15 			// NLIN TOTAL: 241

		OREPORT:SAY( NLIN, NMINLEFT+10, STR0015, OFONT1:OFONT ) //"CNPJ: "
		OREPORT:SAY( NLIN, NMINLEFT+60, Alltrim(Transform(TRBFAT->A1_CGC, "@!R NN.NNN.NNN/NNNN-99")), OFONT2:OFONT )

		OREPORT:SAY( NLIN, NMEIO-80, STR0021, OFONT1:OFONT ) //"INSCRIÇÃO ESTADUAL: "
		OREPORT:SAY( NLIN, NMEIO+15, ALLTRIM(TRBFAT->A1_INSCR), OFONT2:OFONT )
		NLIN +=  15 			// NLIN TOTAL: 256

		OREPORT:SAY( NLIN, NMINLEFT+10, STR0022, OFONT1:OFONT ) //"VENCTO: "
		OREPORT:SAY( NLIN, NMINLEFT+60, DTOC(STOD(TRBFAT->VENCTO)), OFONT2:OFONT )
		NLIN +=  25 			// NLIN TOTAL: 281

				
		IF SELECT("TRBPRD") > 0
			TRBPRD->(DBCLOSEAREA())
		ENDIF

		//Montando a consulta dos pedidos
		oStatement := NIL
		oStatement := FWPreparedStatement():New()
		_CQUERY := " SELECT CASE WHEN MAX(COALESCE(FPN_COD, '')) = ''"
		_CQUERY += " 			THEN CASE WHEN FP0_MINPFT = '1'"
		_CQUERY += " 					  THEN '2'"
		_CQUERY += " 					  ELSE '1' END"
		_CQUERY += " 			ELSE '3' END TIPO,"
		_CQUERY += " 	   C6_FILIAL,C6_NUM, C6_ITEM, C6_SERIE,C6_PRODUTO,"
		_CQUERY += " 	   C6_QTDVEN, C6_PRCVEN, C6_VALOR, C6_VALDESC "
		_CQUERY += "   FROM " + RETSQLNAME("SC5") + " SC5 "
		_CQUERY += " INNER JOIN " + RETSQLNAME("SC6") + " SC6 "
		_CQUERY += "     ON C5_FILIAL = C6_FILIAL"
		_CQUERY += "    AND C5_NUM    = C6_NUM"
		_CQUERY += "    AND SC6.D_E_L_E_T_ = ' '"

		If lMvLocBac

			_CQUERY += " INNER JOIN " + RetSqlName("FPY") + " FPY ON "
			_CQUERY += " FPY.FPY_FILIAL = '" + xFilial("FPY") +  "' "
			_CQUERY += " 	AND FPY.D_E_L_E_T_ = ' ' "
			_CQUERY += " 	AND FPY_PEDVEN = C5_NUM "
		EndIf

		_CQUERY += " LEFT JOIN " + RETSQLNAME("FPN") + " ZLF "
		_CQUERY += "     ON C5_FILIAL = FPN_FILIAL"
		_CQUERY += "    AND C5_NUM    = FPN_NUMPV"
		_CQUERY += "    AND ZLF.D_E_L_E_T_ = ' '"
		_CQUERY += " LEFT JOIN " + RETSQLNAME("FP0") + " ZA0 "
		_CQUERY += "     ON FP0_FILIAL = ? "
		_CQUERY += "    AND FP0_PROJET = ? "
		_CQUERY += "    AND ZA0.D_E_L_E_T_ = ' '"
		_CQUERY += "  WHERE C5_FILIAL = '" + XFILIAL("SC5") + "'"
		_CQUERY += "    AND C6_NOTA   = ? " 
		_CQUERY += "    AND C6_SERIE  = ? " 
		_CQUERY += "    AND SC5.D_E_L_E_T_ = ' '"
		_CQUERY += "  GROUP BY FP0_MINPFT, C6_FILIAL, C6_NUM, C6_ITEM, C6_SERIE, C6_QTDVEN, "
		_CQUERY += "  		C6_PRCVEN, C6_VALOR, C6_VALDESC, FP0_PROJET, "
		_CQUERY += "  		C6_PRODUTO "
		_CQUERY += "  ORDER BY C6_FILIAL, C6_NUM, C6_ITEM"

		//Seta as variaveis da query
		oStatement:SetQuery(_CQUERY)
		oStatement:SetString(1, TRBFAT->FILIAL  )
		oStatement:SetString(2, TRBFAT->FPZ_PROJET )
		oStatement:SetString(3, TRBFAT->NUMFAT  )
		oStatement:SetString(4, MV_PAR03    	)

		//Recupera a consulta já com os parâmetros injetados
		_CQUERY := oStatement:GetFixQuery()
		_cQuery := ChangeQuery(_cQuery)
		TCQUERY _CQUERY NEW ALIAS "TRBPRD"

		_APRODUTOS := {}
		_NTOTAL := 0 


		WHILE TRBPRD->(!EOF())

/*			IF !EMPTY(ALLTRIM(TRBPRD->DTINI))
				IF EMPTY(_DDTINI) .OR. STOD(TRBPRD->DTINI) < _DDTINI
					_DDTINI := STOD(TRBPRD->DTINI)
				ENDIF
			ENDIF

			IF !EMPTY(ALLTRIM(TRBPRD->DTFIM))
				IF STOD(TRBPRD->DTFIM) > _DDTFIM
					_DDTFIM := STOD(TRBPRD->DTFIM)
				ENDIF
			ENDIF
*/
			_CTIPO     := TRBPRD->TIPO
			_CCONTRATO := ALLTRIM(TRBFAT->FPZ_PROJET)
//			_CPRODUTO  := ALLTRIM(TRBPRD->FPA_DESGRU)+' '+ALLTRIM(TRBPRD->FPA_GRUA)+' '+ALLTRIM(TRBPRD->FPA_CARAC)
//			XT  := MLCOUNT(_CPRODUTO,65)

			SB1->(DBSETORDER(1))
			SB1->(DBSEEK(XFILIAL("SB1")+TRBPRD->C6_PRODUTO))
			FPZ->(dbSetOrder(1)) //FPZ_FILIAL+FPZ_PEDVEN+FPZ_PROJET+FPZ_ITEM
			If FPZ->(dbSeek(xFilial("FPZ")+TRBPRD->C6_NUM+TRBFAT->FPZ_PROJET+TRBPRD->C6_ITEM))
				AADD(_APRODUTOS,{TRBPRD->C6_ITEM,SB1->B1_DESC,CVALTOCHAR(TRBPRD->C6_QTDVEN),TRANSFORM(FPZ->FPZ_VALUNI,"@E 9,999,999,999.99"),TRANSFORM(FPZ->FPZ_TOTAL ,"@E 9,999,999,999.99"),FPZ->FPZ_PERLOC ,FPZ->FPZ_FROTA   })
				_NTOTAL += FPZ->FPZ_TOTAL 
				_NTOTAL += TRBPRD->C6_VALDESC
			Else
				AADD(_APRODUTOS,{TRBPRD->C6_ITEM,SB1->B1_DESC,CVALTOCHAR(TRBPRD->C6_QTDVEN),TRANSFORM(TRBPRD->C6_PRCVEN,"@E 9,999,999,999.99"),TRANSFORM((TRBPRD->C6_VALOR + TRBPRD->C6_VAlDESC),"@E 9,999,999,999.99")," " ," "  })
				_NTOTAL += TRBPRD->C6_VALOR 
				_NTOTAL += TRBPRD->C6_VALDESC
			EndIf

			TRBPRD->(DBSKIP())
		ENDDO

		TRBPRD->(DBCLOSEAREA())

		OREPORT:FILLRECT( {NLIN-10, 0010, NLIN,NMAXWIDTH }, OBRUSH)

		IF _CTIPO == "2"
			OREPORT:SAY( NLIN-2, NMINLEFT+10, STR0023, OFONT1:OFONT ) //"ITEM"
			OREPORT:SAY( NLIN-2, NMINLEFT+40, STR0024, OFONT1:OFONT )	 //"DESCRIMINAÇÃO/ESPECIFICAÇÃO"

			OREPORT:SAY( NLIN-2, NMEIO+20, STR0025, OFONT1:OFONT ) //"PERÍODO"

			OREPORT:SAY( NLIN-2, NMEIO+130, STR0026, OFONT1:OFONT ) //"QTD."

			OREPORT:SAY( NLIN-2,((NMEIO+NMAXWIDTH)/2)+13, STR0027, OFONT1:OFONT ) //"PREÇO UNITÁRIO"
			OREPORT:SAY( NLIN-2,((NMEIO+NMAXWIDTH)/2)+90, STR0028, OFONT1:OFONT ) //"PREÇO TOTAL"
		ELSE
			OREPORT:SAY( NLIN-2, NMINLEFT+10, STR0024, OFONT1:OFONT )	 //"DESCRIMINAÇÃO/ESPECIFICAÇÃO"

		ENDIF
		NLIN +=  15 		// 296


		DO CASE
		CASE _CTIPO == "1"
			//SIGALOC94-812 - 16/06/2023 - Jose Eulalio - PE para substituir as informações de LOCAÇÃO DE EQUIPAMENTO
			If lLocr003A
				NLIN := ExecBlock("LOCR003A" , .T. , .T. , {NLIN,TRBFAT->PEDIDO,_CCONTRATO,OREPORT})
			Else
				IF EMPTY(ALLTRIM(DTOS(_DDTINI))) .OR. EMPTY(ALLTRIM(DTOS(_DDTFIM)))
					OREPORT:SAY( NLIN-1, NMINLEFT+10, STR0029 , OFONT2:OFONT ) //"LOCAÇÃO DE EQUIPAMENTOS - "
				ELSE
					OREPORT:SAY( NLIN-1, NMINLEFT+10, STR0029 + DTOC(_DDTINI) + STR0030 + DTOC(_DDTFIM), OFONT2:OFONT ) //"LOCAÇÃO DE EQUIPAMENTOS - "###" A "
				ENDIF
				NLIN += nTamLin
				//imprime equipamento, numero de serie e periodo
				SC6->(DbSetOrder(1)) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
				If SC6->(DbSeek(xFilial("SC6") + TRBFAT->PEDIDO))
					FPA->(DbSetOrder(3)) //FPA_FILIAL+FPA_AS+FPA_VIAGEM
					FPY->(dbSetOrder(1)) //FPY_FILIAL+FPY_PEDVEN+FPY_PROJET
					FPZ->(dbSetOrder(1)) //FPZ_FILIAL+FPZ_PEDVEN+FPZ_PROJET+FPZ_ITEM
					cChave := SC6->(C6_FILIAL + C6_NUM)
					FPY->(dbSeek(xFilial("FPY")+SC6->C6_NUM))
					While !SC6->(Eof()) .And. SC6->(C6_FILIAL + C6_NUM) == cChave
						If lMvLocBac
							FPZ->(dbSeek(xFilial("FPZ")+SC6->C6_NUM+FPY->FPY_PROJET+SC6->C6_ITEM)) // Rossana 11/11
							cAsPedido	:= FPZ->FPZ_AS
							cPeriodo  	:= FPZ->FPZ_PERLOC
						Else
							cAsPedido	:= SC6->C6_XAS
							cPeriodo  	:= SC6->C6_XPERLOC
						EndIf
						FPA->(DbSetOrder(3))
						If FPA->(DbSeek(xFilial("FPA") + cAsPedido))
							oReport:SAY( NLIN-1, 020, "Equipamento: " + AllTrim(FPA->FPA_GRUA)    , oFont2:oFont )
							oReport:SAY( NLIN-1, 220, "Num.Serie: "   + AllTrim(SC6->C6_NUMSERI)  , oFont2:oFont )
							oReport:SAY( NLIN-1, 360, "Periodo: "     + AllTrim(cPeriodo)         , oFont2:oFont )
							NLIN += nTamLin
						EndIf
						SC6->(DbSkip())
					EndDo
				EndIf
			EndIf
			NLIN += 10 		// 311
		CASE _CTIPO == "2" .or. _CTIPO == "3"
			FOR I := 1 TO LEN(_APRODUTOS)
				OREPORT:SAY( NLIN-1, NMINLEFT+10, _APRODUTOS[I,1], OFONT2:OFONT )
				OREPORT:SAY( NLIN-1, NMINLEFT+40, AllTrim(_APRODUTOS[I,2])+"/"+AllTrim(_APRODUTOS[I,7]), OFONT2:OFONT )

				OREPORT:SAY( NLIN-1, NMEIO+20, _APRODUTOS[I,6], OFONT2:OFONT )

				OREPORT:SAY( NLIN-1, NMEIO+130, _APRODUTOS[I,3], OFONT2:OFONT )

				OREPORT:SAY( NLIN-1,((NMEIO+NMAXWIDTH)/2)+10, _APRODUTOS[I,4], OFONT2:OFONT )
				OREPORT:SAY( NLIN-1,((NMEIO+NMAXWIDTH)/2)+74, _APRODUTOS[I,5], OFONT2:OFONT )
				NLIN += 10 	// 311
//				IF NLIN > 800
				IF NLIN > 750
					OREPORT:ENDPAGE()
					OREPORT:STARTPAGE()
					NLIN := 25
//---------------------------------------------------------------------------------------------------------------------

		// --> CABEÇALHO
					OREPORT:BOX( NLIN, NMINLEFT, NLIN+50, NMAXWIDTH,"-1" )
					NLIN +=  50 			// NLIN TOTAL:  75

		// --> INFORMAÇÕES DO PRESTADOR DO SERVIÇO
					OREPORT:BOX( NLIN, NMINLEFT, NLIN+90, NMEIO     )
					OREPORT:BOX( NLIN, NMEIO   , NLIN+90, NMAXWIDTH )
					NLIN += 105 			// NLIN TOTAL: 180

		// --> INFORMAÇÕES DO TOMADOR DO SERVIÇO
					OREPORT:BOX( NLIN, NMINLEFT, NLIN+90, NMAXWIDTH )
					NLIN += 102 			// NLIN TOTAL: 282

					NLIN += 420 			// NLIN TOTAL: 702

					NLIN :=  30

					OREPORT:FILLRECT( {NLIN, NMINLEFT+3, NLIN+10,NMAXWIDTH }, OBRUSH)
					NLIN +=  15 			// NLIN TOTAL: 45

					OREPORT:FILLRECT( {NLIN, NMINLEFT+3, NLIN+10,NMAXWIDTH }, OBRUSH)
					NLIN +=  15 			// NLIN TOTAL: 60

					OREPORT:FILLRECT( {NLIN, NMINLEFT+3, NLIN+10,NMAXWIDTH }, OBRUSH)
					NLIN :=  38	

					OREPORT:SAYBITMAP(NLIN-8,NMINLEFT+3,CLOGO,0098,0040 )

					OREPORT:SAY( NLIN, NMEIO-(len(STR0005)/2), STR0005, OFONT3:OFONT ) //"FATURA"

					NLIN :=  53 			// NLIN TOTAL: 53

					OREPORT:SAY( NLIN, NMEIO- (len(alltrim(TRBFAT->NUMFAT))/2), alltrim(TRBFAT->NUMFAT), OFONT3:OFONT )
					NLIN +=  40 			// NLIN TOTAL: 93

					OREPORT:SAY( NLIN, NMINLEFT+10, STR0006, OFONT1:OFONT ) //"ENDEREÇO: "
					OREPORT:SAY( NLIN, NMINLEFT+60, substr(CEND,1,51 ), OFONT2:OFONT )
					
					//Card DSERLOCA-8532 Valtenio Oliveira buscar o Texto da TES
					_TextoTes:= POSICIONE("SF4",1,XFILIAL("SF4")+TRBFAT->D2_TES,"F4_TEXTO")

					OREPORT:SAY( NLIN, NMEIO+10, STR0007, OFONT1:OFONT ) //"NATUREZA OPERAÇÃO: "
					//OREPORT:SAY( NLIN, NMEIO+108, ALLTRIM(TRBFAT->F4_TEXTO), OFONT2:OFONT )
					OREPORT:SAY( NLIN, NMEIO+108, ALLTRIM(_TextoTes), OFONT2:OFONT )
					NLIN +=  15 			// NLIN TOTAL: 108

					OREPORT:SAY( NLIN, NMINLEFT+10, STR0008, OFONT1:OFONT ) //"BAIRRO: "
					OREPORT:SAY( NLIN, NMINLEFT+50, substr(CBAIRRO,1,20), OFONT2:OFONT )

					OREPORT:SAY( NLIN, NMEIO+10, STR0032, OFONT1:OFONT ) //STR0032 //"CONTRATO: "
					OREPORT:SAY( NLIN, NMEIO+108, ALLTRIM(TRBFAT->FPZ_PROJET), OFONT2:OFONT )
			
					OREPORT:SAY( NLIN, ((NMINLEFT+NMEIO)/2), STR0009, OFONT1:OFONT ) //"CIDADE: "
					OREPORT:SAY( NLIN, ((NMINLEFT+NMEIO)/2)+35, substr(CCIDADE,1,24), OFONT2:OFONT )

					NLIN +=  15 			// NLIN TOTAL: 123

					OREPORT:SAY( NLIN, NMINLEFT+10, STR0010, OFONT1:OFONT ) //"CEP: "
					OREPORT:SAY( NLIN, NMINLEFT+50, CCEP, OFONT2:OFONT )

					OREPORT:SAY( NLIN, ((NMINLEFT+NMEIO)/2), STR0011, OFONT1:OFONT ) //"UF: "
					OREPORT:SAY( NLIN, ((NMINLEFT+NMEIO)/2)+30, CUF, OFONT2:OFONT )
					NLIN +=  15 			// NLIN TOTAL: 138

					OREPORT:SAY( NLIN, NMINLEFT+10, STR0012, OFONT1:OFONT ) //"FONE: "
					OREPORT:SAY( NLIN, NMINLEFT+50, CTEL, OFONT2:OFONT )

					OREPORT:SAY( NLIN, ((NMINLEFT+NMEIO)/2), STR0013, OFONT1:OFONT ) //"FAX: "
					OREPORT:SAY( NLIN, ((NMINLEFT+NMEIO)/2)+30, CFAX, OFONT2:OFONT )

					OREPORT:SAY( NLIN, NMEIO+10, STR0014, OFONT1:OFONT ) //"DATA EMISSÃO: "
					OREPORT:SAY( NLIN, NMEIO+80, DTOC(STOD(TRBFAT->EMISSAO)), OFONT2:OFONT )
					NLIN +=  15 			// NLIN TOTAL: 153
					OREPORT:SAY( NLIN, NMINLEFT+10, STR0015, OFONT1:OFONT ) //"CNPJ: "
					OREPORT:SAY( NLIN, NMINLEFT+50, CCNPJ, OFONT2:OFONT )

					OREPORT:SAY( NLIN, ((NMINLEFT+NMEIO)/2), STR0016, OFONT1:OFONT ) //"CCM: "
					OREPORT:SAY( NLIN, ((NMINLEFT+NMEIO)/2)+30, ALLTRIM(SM0->M0_INSCM), OFONT2:OFONT )

					OREPORT:SAY( NLIN, NMEIO+10, STR0017, OFONT1:OFONT ) //"NÚMERO PEDIDO: "
					OREPORT:SAY( NLIN, NMEIO+80, TRBFAT->PEDIDO, OFONT2:OFONT )
					NLIN +=  25 			// NLIN TOTAL: 178

					OREPORT:FILLRECT( {NLIN-10, 0010, NLIN,NMAXWIDTH }, OBRUSH)
					OREPORT:SAY( NLIN-1, NMEIO-30, STR0018, OFONT3:OFONT ) //"DESTINATÁRIO"
					NLIN +=  18 			// NLIN TOTAL: 196

					OREPORT:SAY( NLIN, NMINLEFT+10, STR0019, OFONT1:OFONT ) //"RAZÃO SOCIAL: "
					OREPORT:SAY( NLIN, NMINLEFT+75, ALLTRIM(TRBFAT->RAZSOC), OFONT2:OFONT )
					NLIN +=  15 			// NLIN TOTAL: 211

					OREPORT:SAY( NLIN, NMINLEFT+10, STR0006, OFONT1:OFONT ) //"ENDEREÇO: "
					OREPORT:SAY( NLIN, NMINLEFT+60, ALLTRIM(TRBFAT->A1_END), OFONT2:OFONT )
					NLIN +=  15 			// NLIN TOTAL: 226

					OREPORT:SAY( NLIN, NMINLEFT+10, STR0008, OFONT1:OFONT ) //"BAIRRO: "
					OREPORT:SAY( NLIN, NMINLEFT+50, substr(TRBFAT->A1_BAIRRO,1,35), OFONT2:OFONT )

					OREPORT:SAY( NLIN, NMEIO-80, STR0020, OFONT1:OFONT ) //"MUNICÍPIO: "
					OREPORT:SAY( NLIN, NMEIO-26, substr(TRBFAT->A1_MUN,1,38), OFONT2:OFONT )

					OREPORT:SAY( NLIN, ((NMEIO+NMAXWIDTH)/2), STR0011, OFONT1:OFONT ) //"UF: "
					OREPORT:SAY( NLIN, ((NMEIO+NMAXWIDTH)/2)+20, ALLTRIM(TRBFAT->A1_EST), OFONT2:OFONT )

					OREPORT:SAY( NLIN, ((NMEIO+NMAXWIDTH)/2)+60, STR0010, OFONT1:OFONT ) //"CEP: "
					OREPORT:SAY( NLIN, ((NMEIO+NMAXWIDTH)/2)+80, ALLTRIM(Transform(TRBFAT->A1_CEP, "@R 99999-99")), OFONT2:OFONT )
					NLIN +=  15 			// NLIN TOTAL: 241

					OREPORT:SAY( NLIN, NMINLEFT+10, STR0015, OFONT1:OFONT ) //"CNPJ: "
					OREPORT:SAY( NLIN, NMINLEFT+60, Alltrim(Transform(TRBFAT->A1_CGC, "@!R NN.NNN.NNN/NNNN-99")), OFONT2:OFONT )

					OREPORT:SAY( NLIN, NMEIO-80, STR0021, OFONT1:OFONT ) //"INSCRIÇÃO ESTADUAL: "
					OREPORT:SAY( NLIN, NMEIO+15, ALLTRIM(TRBFAT->A1_INSCR), OFONT2:OFONT )
					NLIN +=  15 			// NLIN TOTAL: 256

					OREPORT:SAY( NLIN, NMINLEFT+10, STR0022, OFONT1:OFONT ) //"VENCTO: "
					OREPORT:SAY( NLIN, NMINLEFT+60, DTOC(STOD(TRBFAT->VENCTO)), OFONT2:OFONT )
				//	OREPORT:SAY( NLIN, NMINLEFT+100, TRANSFORM(TRBFAT->F2_VALBRUT,"@E 9,999,999,999.99"), OFONT2:OFONT ) COMENTADO POR GUILHERME CORONADO
					NLIN +=  25 			// NLIN TOTAL: 281

					OREPORT:FILLRECT( {NLIN-10, 0010, NLIN,NMAXWIDTH }, OBRUSH)

					IF _CTIPO == "2"
						OREPORT:SAY( NLIN-2, NMINLEFT+10, STR0023, OFONT1:OFONT ) //"ITEM"
						OREPORT:SAY( NLIN-2, NMINLEFT+40, STR0024, OFONT1:OFONT )	 //"DESCRIMINAÇÃO/ESPECIFICAÇÃO"

						OREPORT:SAY( NLIN-2, NMEIO-10, STR0025, OFONT1:OFONT ) //"PERÍODO"

						OREPORT:SAY( NLIN-2, NMEIO+94, STR0026, OFONT1:OFONT ) //"QTD."
						OREPORT:SAY( NLIN-2,((NMEIO+NMAXWIDTH)/2)-20, STR0027, OFONT1:OFONT ) //"PREÇO UNITÁRIO"
						OREPORT:SAY( NLIN-2,((NMEIO+NMAXWIDTH)/2)+90, STR0028, OFONT1:OFONT ) //"PREÇO TOTAL"
//					ELSE
//						OREPORT:SAY( NLIN-2, NMINLEFT+10, STR0024, OFONT1:OFONT )	 //"DESCRIMINAÇÃO/ESPECIFICAÇÃO"

					ENDIF
					NLIN +=  15 		// 296

//---------------------------------------------------------------------------------------------------------------------
				ENDIF
			NEXT
/*
		CASE _CTIPO == "3"
			OREPORT:SAY( NLIN-1, NMINLEFT+10, STR0031, OFONT2:OFONT ) //"COMPLEMENTO DE LOCAÇÃO"
			NLIN +=  10 	// 311 */
		ENDCASE

		//IF NLIN < 455
		//	NLIN := 465
		//ELSE
			NLIN +=  20
		//ENDIF

		// Frank em 10/10/23 card 1182
		// 1. Pegar o conteúdo de todos os FP1_OBSFAT envolvidos
		// 2. Completar com o conteúdo do MV_CMPUSR
		// a cada FP1 e conteúdo do parâmetro pular linha chr(13)+chr(10)
		_cObsFat := ""
		SC6->(dbSetOrder(1))
		aObra := {}
		SC6->(dbSeek(xFilial("SC6")+TRBFAT->PEDIDO))
		While !SC6->(Eof()) .and. SC6->(C6_FILIAL+C6_NUM) == xFilial("SC6")+TRBFAT->PEDIDO
			If lMvLocBac
				FPZ->(dbSetOrder(1))
				FPZ->(dbSeek(xFilial("FPZ")+TRBFAT->PEDIDO))
				lGera := .F.
				While !FPZ->(Eof()) .and. FPZ->FPZ_PEDVEN == TRBFAT->PEDIDO
					If FPZ->FPZ_ITEM == SC6->C6_ITEM
						lGera := .T.
						Exit
					EndIF
					FPZ->(dbSkip())
				EndDo
				If lGera
					FPY->(dbSetOrder(1))
					If FPY->(dbSeek(xFilial("FPY")+TRBFAT->PEDIDO))
						If alltrim(FPY->FPY_STATUS) <> "1"
							lGera := .F.
						EndIf
					EndIf
				EndIf

				if lGera
					FPA->(dbSetOrder(3))
					If FPA->(dbSeek(xFilial("FPA")+FPZ->FPZ_AS))
						FP1->(dbSetOrder(1))
						If FP1->(dbSeek(xFilial("FP1")+FPA->FPA_PROJET+FPA->FPA_OBRA))
							lGera := .T.
							For xT := 1 to len(aObra)
								If aObra[xT,1] == FP1->FP1_OBRA
									lGera := .F.
								EndIf
							Next
							If lGera
								aadd(aObra,{FP1->FP1_OBRA,FP1->FP1_OBSFAT})
							EndIf
						EndIF
					EndIf
				EndIf
			Else
				FPA->(dbSetOrder(3))
				If FPA->(dbSeek(xFilial("FPA")+SC6->C6_XAS))
					FP1->(dbSetOrder(1))
					If FP1->(dbSeek(xFilial("FP1")+FPA->FPA_PROJET+FPA->FPA_OBRA))
						lGera := .T.
						For xT := 1 to len(aObra)
							If aObra[xT,1] == FP1->FP1_OBRA
								lGera := .F.
							EndIf
						Next
						If lGera
							aadd(aObra,{FP1->FP1_OBRA,FP1->FP1_OBSFAT})
						EndIf
					EndIF
				EndIf
			EndIF
			SC6->(dbSkip())
		EndDo
		For xT := 1 to len(aObra)
			_cObsFat += aObra[xT,2]
			_cObsFat += chr(13)+chr(10)
		Next
		nPos1   := 0
		cBloco1 := ""
		cBloco2 := ""
		cAuxVar := ""

		SC5->(dbSetOrder(1))
		SC5->(dbSeek(xFilial("SC5")+TRBFAT->PEDIDO))
		If !empty(cCmpUsr)
			If "|" $ cCmpUsr
				nPos1  		:= AT("|",cCmpUsr) 
				cAuxVar		:= SubStr(cCmpUsr,1,nPos1-1)  
				cVar 		:= "SC5->"+alltrim(cAuxVar)
				_cObsFat	+= &(cVar)+chr(13)+chr(10)
				cBloco1		:= SubStr(cCmpUsr,nPos1+1,Len(cCmpUsr)-nPos1) 
				While .t.
					If "|" $ cBloco1
						nPos1  		:= AT("|",cBloco1) 
						cAuxVar		:= SubStr(cBloco1,1,nPos1-1)  
						cVar 		:= "SC5->"+alltrim(cAuxVar)
						_cObsFat 	+= &(cVar)+chr(13)+chr(10)
						cBloco2		:= SubStr(cBloco1,nPos1+1,Len(cBloco1)-nPos1)   
						cBloco1		:= ""
						cBloco1		:= cBloco2  
						cBloco2		:= ""			
					Else
						If !Empty(AllTrim(cBloco1))
							cVar 	 := "SC5->"+alltrim(cBloco1)
							_cObsFat += &(cVar)+chr(13)+chr(10)
							Exit
						Else
							Exit
						EndIf
					EndIf
				End
			Else
				cVar := "SC5->"+alltrim(cCmpUsr)
				_cObsFat += &(cVar)+chr(13)+chr(10)
			EndIf
		EndIf
		_cObsFat += chr(13)+chr(10)

		XT  := MLCOUNT(ALLTRIM(_COBSFAT),90)
		FOR I:=1 TO XT
			OREPORT:SAY( NLIN-1, NMINLEFT+10, MEMOLINE(_COBSFAT ,90, I ), OFONT2:OFONT )
			NLIN +=  10
		NEXT

		//NLIN := 505 		// 505

		IF _CTIPO == "1" .AND. !EMPTY(_CCONTRATO)
			OREPORT:SAY( NLIN-1, NMINLEFT+10, STR0032 + _CCONTRATO, OFONT2:OFONT )	 //"CONTRATO: "
		ENDIF
		NLIN +=  15 		// 520

		IF _CTIPO <> "3" .AND. !EMPTY(ALLTRIM(TRBFAT->A6_COD))
//			OREPORT:SAY( NLIN-1, NMINLEFT+10, STR0033 + ALLTRIM(TRBFAT->A6_COD) + " AG " + ALLTRIM(TRBFAT->AGENCIA) + " CC " + ALLTRIM(TRBFAT->CONTA), OFONT2:OFONT )		 //"PAGAMENTO ATRAVÉS DE DEPÓSITO BANCÁRIO "
			OREPORT:SAY( NLIN-1, NMINLEFT+10, STR0033 + ALLTRIM(TRBFAT->A6_COD) + " AG " + ALLTRIM(TRBFAT->A6_AGENCIA) + '-' + ALLTRIM(TRBFAT->A6_DVAGE) + " CC " + ALLTRIM(TRBFAT->A6_NUMCON ) + '-' + ALLTRIM(TRBFAT->A6_DVCTA)  , OFONT2:OFONT )		 //"PAGAMENTO ATRAVÉS DE DEPÓSITO BANCÁRIO "
		ENDIF
		NLIN +=  15 		// 535


		OREPORT:SAY( NLIN-1, NMINLEFT+10, STR0034, OFONT1:OFONT ) //'"OPERAÇÃO NÃO SUJEITA A EMISSÃO DE NOTA FISCAL DE SERVIÇOS-VETADA A COBRANÇA DE ISS CONF.'
		//OREPORT:SAY( NLIN-1, ((NMEIO+NMAXWIDTH)/2)+20, 'OPERAÇÃO NÃO SUJEITA A EMISSÃO DE NOTA FISCAL DE SERVIÇOS-VETADA A COBRANÇA DE ISS CONF.', OFONT1:OFONT )
		//OREPORT:SAY( NLIN-1, ((NMEIO+NMAXWIDTH)/2)+82, TRANSFORM(TRBFAT->F2_VALBRUT,"@E 9,999,999,999.99"), OFONT2:OFONT )
		OREPORT:SAY( NLIN-1, ((NMEIO+NMAXWIDTH)/2)+82, TRANSFORM(_NTOTAL,"@E 9,999,999,999.99"), OFONT2:OFONT )
		NLIN +=  15 		// 550

		OREPORT:SAY( NLIN-6, NMINLEFT+10, 'LEI COMPLEMENTAR 116/03', OFONT1:OFONT )
			//OREPORT:SAY( NLIN-1, ((NMEIO+NMAXWIDTH)/2), STR0035, OFONT1:OFONT ) //"IMPOSTOS RETIDOS:"
			OREPORT:SAY( NLIN-1, ((NMEIO+NMAXWIDTH)/2), "IMPOSTOS RETIDOS:", OFONT1:OFONT )
			// --> CORRECAO DO VALOR DOS IMPOSTOS RETIDOS NA EMISSAO DO RELATORIO   (*INICIO*)
		//	OREPORT:SAY( NLIN-1, ((NMEIO+NMAXWIDTH)/2)+90, TRANSFORM(TRBFAT->VALRET+TRBFAT->IRFAT,"@E 9,999,999,999.99"), OFONT2:OFONT )
			OREPORT:SAY( NLIN-1, ((NMEIO+NMAXWIDTH)/2)+82, TRANSFORM(_NVALOR,"@E 9,999,999,999.99"), OFONT2:OFONT )
			// --> CORRECAO DO VALOR DOS IMPOSTOS RETIDOS NA EMISSAO DO RELATORIO   (*FINAL* )
		NLIN +=  15 		// 565
		OREPORT:SAY( NLIN-1, ((NMEIO+NMAXWIDTH)/2)+35, STR0036, OFONT1:OFONT ) //"DESCONTO:"
		OREPORT:SAY( NLIN-1, ((NMEIO+NMAXWIDTH)/2)+35, "DESCONTO:", OFONT1:OFONT )
		OREPORT:SAY( NLIN-1, ((NMEIO+NMAXWIDTH)/2)+82, TRANSFORM(TRBFAT->F2_DESCONT,"@E 9,999,999,999.99"), OFONT2:OFONT ) // Rossana 
		NLIN +=  15 		// 580
		OREPORT:SAY( NLIN-1, ((NMEIO+NMAXWIDTH)/2)+50, STR0037, OFONT1:OFONT )  //"TOTAL:"
		OREPORT:SAY( NLIN-1, ((NMEIO+NMAXWIDTH)/2)+50, "TOTAL:", OFONT1:OFONT )
		// --> CORRECAO DO VALOR DOS IMPOSTOS RETIDOS NA EMISSAO DO RELATORIO   (*INICIO*)
		//	OREPORT:SAY( NLIN-1, ((NMEIO+NMAXWIDTH)/2)+90, TRANSFORM(TRBFAT>TOTAL-,"@E 9,999,999,999.99"), OFONT2:OFONT )
		//	OREPORT:SAY( NLIN-1, ((NMEIO+NMAXWIDTH)/2)+82, TRANSFORM(TRBFAT->F2_VALBRUT - TRBFAT->F2_DESCONT - _NVALOR,"@E 9,999,999,999.99"), OFONT2:OFONT ) // Rossana 
		//Ajuste do valor Desconto duplicado Card - Valtenio Oliveira
		//OREPORT:SAY( NLIN-1, ((NMEIO+NMAXWIDTH)/2)+82, TRANSFORM(_NTOTAL - TRBFAT->F2_DESCONT - _NVALOR,"@E 9,999,999,999.99"), OFONT2:OFONT ) // Rossana 
		OREPORT:SAY( NLIN-1, ((NMEIO+NMAXWIDTH)/2)+82, TRANSFORM(_NTOTAL - TRBFAT->F2_DESCONT -_NVALOR,"@E 9,999,999,999.99"), OFONT2:OFONT ) // Rossana 
		// --> CORRECAO DO VALOR DOS IMPOSTOS RETIDOS NA EMISSAO DO RELATORIO   (*FINAL* )
		NLIN +=  30 		// 610
		OREPORT:SAY( NLIN-1, NMINLEFT+10, STR0038, OFONT1:OFONT ) //"ENDEREÇO COBRANÇA"
		OREPORT:SAY( NLIN-1, NMINLEFT+10, "ENDEREÇO COBRANÇA", OFONT1:OFONT )
		NLIN +=  15 		// 625
		OREPORT:SAY( NLIN-1, NMINLEFT+10, STR0006 + ALLTRIM(TRBFAT->A1_ENDCOB) + " / " + TRBFAT->A1_BAIRROC, OFONT2:OFONT ) //"ENDEREÇO: "
		OREPORT:SAY( NLIN-1, NMINLEFT+10, "ENDEREÇO: " + ALLTRIM(TRBFAT->A1_ENDCOB) + " / " + TRBFAT->A1_BAIRROC, OFONT2:OFONT )
		NLIN +=  15 		// 640
		OREPORT:SAY( NLIN-1, NMINLEFT+10, STR0009 + ALLTRIM(TRBFAT->A1_MUNC) + "/" + TRBFAT->A1_ESTC + STR0039 + ALLTRIM(Transform(TRBFAT->A1_CEPC, "@R 99999-999")), OFONT2:OFONT ) //"CIDADE: "###"  CEP: "
		OREPORT:SAY( NLIN-1, NMINLEFT+10, "CIDADE: " + ALLTRIM(TRBFAT->A1_MUNC) + "/" + TRBFAT->A1_ESTC + "  CEP: " + ALLTRIM(Transform(TRBFAT->A1_CEPC, "@R 99999-999")), OFONT2:OFONT )
		NLIN +=  15 		// 655
		OREPORT:SAY( NLIN-1, NMINLEFT+10, STR0040, OFONT1:OFONT ) //"ENDEREÇO ENTREGA"
		OREPORT:SAY( NLIN-1, NMINLEFT+10, "ENDEREÇO ENTREGA", OFONT1:OFONT )
		NLIN +=  15 		// 670
		OREPORT:SAY( NLIN-1, NMINLEFT+10, STR0006 + ALLTRIM(TRBFAT->A1_ENDENT) + " / " + ALLTRIM(TRBFAT->A1_BAIRROE) + ", " +ALLTRIM(TRBFAT->A1_MUNE) + ", " + TRBFAT->A1_ESTE + ", " + ALLTRIM(Transform(TRBFAT->A1_CEPE, "@R 99999-999")), OFONT2:OFONT ) //"ENDEREÇO: "
		OREPORT:SAY( NLIN-1, NMINLEFT+10, "ENDEREÇO: " + ALLTRIM(TRBFAT->A1_ENDENT) + " / " + ALLTRIM(TRBFAT->A1_BAIRROE) + ", " +ALLTRIM(TRBFAT->A1_MUNE) + ", " + TRBFAT->A1_ESTE + ", " + ALLTRIM(Transform(TRBFAT->A1_CEPE, "@R 99999-999")), OFONT2:OFONT )
		NLIN +=  15 		// 685

	//	OREPORT:SAY( NLIN-1, NMINLEFT+10, "NUM. PEDIDO DO CLIENTE", OFONT1:OFONT )
		//NLIN := 725 		// 725
		OREPORT:SAY( NLIN-1, NMINLEFT+20, STR0041, OFONT2:OFONT ) //"Nº FATURA"
		OREPORT:SAY( NLIN-1, NMINLEFT+100, STR0042 + ALLTRIM(SM0->M0_NOMECOM) + STR0043, OFONT2:OFONT ) //"RECEBI(EMOS) DE "###", OS SERVIÇOS CONSTANTES"
		OREPORT:SAY( NLIN-1, NMINLEFT+100, "RECEBI(EMOS) DE " + ALLTRIM(SM0->M0_NOMECOM) + ", OS SERVIÇOS CONSTANTES", OFONT2:OFONT )
		NLIN +=  30 		// 755

		OREPORT:SAY( NLIN-1, NMINLEFT+100, ALLTRIM(SM0->M0_CIDCOB) + " " + REPLICATE("_",7) + STR0044 + REPLICATE("_",30) + STR0045 + REPLICATE("_",10), OFONT2:OFONT ) //" , DE "###", DE "
		OREPORT:SAY( NLIN-1, NMINLEFT+100, ALLTRIM(SM0->M0_CIDCOB) + " " + REPLICATE("_",7) + " , DE " + REPLICATE("_",30) + ", DE " + REPLICATE("_",10), OFONT2:OFONT )
		OREPORT:SAY( NLIN-1, ((NMEIO+NMAXWIDTH)/2)-15, REPLICATE("_",40), OFONT2:OFONT )
		NLIN +=  15 		// 770
		OREPORT:SAY( NLIN-1, ((NMEIO+NMAXWIDTH)/2)+30, STR0046, OFONT2:OFONT ) //"ASSINATURA"
		OREPORT:SAY( NLIN-1, ((NMEIO+NMAXWIDTH)/2)+30, "ASSINATURA", OFONT2:OFONT )

		OREPORT:ENDPAGE()

		_NTOTAL := 0
		_NVALOR := 0

		TRBFAT->(DBSKIP())
	ENDDO

	TRBFAT->(DBCLOSEAREA())

	RestArea(aAreaSC6)
	RestArea(aAreaFPA)

	OREPORT:SETVIEWPDF( .T. )
	OREPORT:PREVIEW()
	FREEOBJ(OREPORT)
	OREPORT := NIL

	oStatement:Destroy()
	FwFreeObj(oStatement)

RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ PERGPARAM º AUTOR ³ IT UP CONSULTORIA  º DATA ³ 03/08/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ PERGUNTA DO RELATÓRIO.                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION PERGPARAM(CPERG)
LOCAL APERGS  := {}
LOCAL _CNOTAI := IIF(FIELDPOS("F2_DOC")>0	,SPACE(GETSX3CACHE("F2_DOC","X3_TAMANHO"))			,SPACE(09)			)
LOCAL _CNOTAF := IIF(FIELDPOS("F2_DOC")>0	,REPLICATE("Z",GETSX3CACHE("F2_DOC","X3_TAMANHO"))	,REPLICATE("Z",09)	)
LOCAL _CSERIE := IIF(FIELDPOS("F2_SERIE")>0	,SPACE(GETSX3CACHE("F2_SERIE","X3_TAMANHO"))		,SPACE(03)			)
LOCAL _CFILIAL:= SPACE(Len(cFilAnt))
LOCAL ARET    := {}
LOCAL LRET    := .F.

	AADD( APERGS ,{1,STR0047	,_CNOTAI ,"@!",".T.","SF2"  ,".T.", 50,.F.}) //"NOTA FISCAL DE: "
	AADD( APERGS ,{1,STR0048	,_CNOTAF ,"@!",".T.","SF2"  ,".T.", 50,.F.}) //"NOTA FISCAL ATÉ: "
	AADD( APERGS ,{1,STR0049    ,_CSERIE ,"@!",".T.","SERNF",".T.", 50,.F.}) //"SÉRIE: "
	AADD( APERGS ,{1,STR0050    ,_CFILIAL,"@!",".T.","SM0"  ,".T.", 50,.F.}) //"FILIAL: "
	//AADD( APERGS ,{1,STR0050         ,_CFILIAL,"@!",".T.","SM0"  ,".T.", 50,.F.})
	IF PARAMBOX(APERGS , STR0051 , ARET , /*4*/ , /*5*/ , /*6*/ , /*7*/ , /*8*/ , /*9*/ , /*10*/ , .F.)  //"PARAMETROS "
		MV_PAR01 := ARET[1] 	// NOTA FISCAL INICIAL
		MV_PAR02 := ARET[2] 	// NOTA FISCAL FINAL
		MV_PAR03 := ARET[3] 	// SÉRIE
		MV_PAR04 := ARET[4] 	// FILIAL
		LRET := .T.
	ENDIF

RETURN (LRET)

//-------------------------------------------------------------------
/*/{Protheus.doc} LOCR00101
@description	Valida se o usuário pode acessar informações da filial indicada
@see			https://tdn.totvs.com/display/public/framework/FWLoadSM0
@author			José Eulálio
@since     		03/08/2023
/*/
//-------------------------------------------------------------------
Function LOCR00101(cCodFil, lHelp)
Local lRet      := .F.
Local aLoadSm0	:= FWLoadSM0()
Local nPosFil	:= aScan(aLoadSm0, {|x| x[2] == cCodFil })

Default lHelp	:= .F.

	//se localizou a filial informada
	If nPosFil > 0
		//se o usuario tem acesso à filial
		If aLoadSm0[nPosFil][11] .And. !lHelp
			lRet := .T.
		Else
			Help(NIL, NIL, "LOCR003_01", NIL, "Ação não permitida", 1, 0, NIL, NIL, NIL, NIL, NIL, { "Seu usuário não tem permissão para acessar informações da Filial indicada."}) // "Ação não permitida" #### "Seu usuário não tem permissão para acessar informações da Filial indicada."
		EndIf
	Else
		Help(NIL, NIL, "LOCR003_02", NIL, "Filial não localizada", 1, 0, NIL, NIL, NIL, NIL, NIL, { "Informe uma Filial válida no campo referente."}) // "Filial não localizada" #### Informe uma Filial válida no campo referente.
	EndIf

Return lRet
