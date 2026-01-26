#Include "locr017.ch"
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "RWMAKE.ch"

/*/
{PROTHEUS.DOC} LOCR017.PRW
ITUP BUSINESS - TOTVS RENTAL
RELATÓRIO DE FATURAMENTO
@TYPE    FUNCTION
@AUTHOR  FRANK ZWARG FUGA
@SINCE   03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/
// ======================================================================= \\
Function LOCR017()
// ======================================================================= \\

// --> DECLARACAO DE VARIAVEIS
Local   cDESC1      := STR0001 													// "ESTE PROGRAMA TEM COMO OBJETIVO IMPRIMIR RELATORIO "
Local   cDESC2      := STR0002 													// "DE ACORDO COM OS PARAMETROS INFORMADOS PELO USUARIO."
Local   cDESC3      := STR0003 													// "RELATÓRIO DE FATURAMENTO "
Local   TITULO      := STR0004 													// "RELATORIO DE FATURAMENTO"
Local   cPERG       := "LOCR017" 												// "LOCP045"
Local   CABEC1      := ""
Local   CABEC2      := ""
Local   nLin        := 80
Local   IMPRIME

Private aORD        := {STR0005,STR0006,STR0007,STR0008,STR0009} 				// "FILIAL" ### "PROJETO" ### "GESTOR" ### "OBRA" ### "EQUIPAMENTO"
Private lEND        := .F.
Private lABORTPRINT := .F.
Private lIMITE      := 220
Private TAMANHO     := "G"
Private NOMEPROG    := "LOCR017" 												// COLOQUE AQUI O NOME DO PROGRAMA PARA IMPRESSAO NO CABECALHO
Private nTIPO       := 15
Private aReturn     := {"ZEBRADO" , 1 , "ADMINISTRACAO" , 1 , 2 , 1 , "" , 1}
Private nLastKey    := 0
Private CBTXT       := Space(10)
Private CBCONT      := 00
Private CONTFL      := 01
Private M_PAG       := 01
Private WNREL       := NOMEPROG 												// COLOQUE AQUI O NOME DO ARQUIVO USADO PARA IMPRESSAO EM DISCO
Private cString     := "FP0"

Private nMVPAR17    := 0

	If !Locr017A()
		Return
	endif
	IMPRIME := .T.

	//ValidPerg(cPerg)
	Pergunte(cPerg,.F.)

	//nMVPAR17 := MV_PAR17 															// --> 1=LOCACAO (FPA)   /   2=EQUIPAMENTO (FP4)
	nMVPAR17 := 1 																	// --> Forçar sempre 1=LOCACAO, em Set/2021 é o único disponivel para o RENTAL

	// --> MONTA A INTERFACE PADRAO COM O USUARIO...
	WNREL := SetPrint(cString , NOMEPROG , cPERG , @TITULO , cDESC1 , cDESC2 , cDESC3 , .T. , aORD , .T. , TAMANHO , , .F.)

	If nLastKey == 27
		Return
	EndIf

	SetDefault(aReturn , cString)

	If nLastKey == 27
		Return
	EndIf

	nTIPO := Iif(aReturn[4]==1 , 15 , 18)

	// --> PROCESSAMENTO. RPTSTATUS MONTA JANELA COM A REGUA DE PROCESSAMENTO.
	RptStatus({|| RUNREPORT(CABEC1 , CABEC2 , TITULO , nLin) } , TITULO)

Return



// ======================================================================= \\
Static Function RUNREPORT(CABEC1 , CABEC2 , TITULO , nLin)
// ======================================================================= \\

//Local   cCOND    := aReturn[7]
//Local   cFILATU  := GetMV("MV_LOCX149" , , xFILIAL("SC6"))
Local _cNOBRA   := ""
Local _cMUOBR   := ""
Local _cESOBR   := ""
Local CALIASX1  := GETNEXTALIAS()
Local lMvLocBac	:= SuperGetMv("MV_LOCBAC",.F.,.F.) //Integração com Módulo de Locações SIGALOC
Local cTipFat   := ""
Local CQUERYX

Private _cFILIAL := cCodVen := ""
Private cPROJ    := cOBRA   := cSEQTRA := cEQUIPTO := ""
Private nTotalG  := nTotalT := 0
Private cNumPV   := cNumNF  := CSERIE  := dEmissao := dVencto := ""

	_cTPFILT := "" //STR0012 														// "LOCACAO"      (FPA)

	TITULO := STR0014 + DtoC(MV_PAR15) + STR0015 + DtoC(MV_PAR16) + "" + _cTPFILT 	// "RELATORIO DE FATURAMENTO - DE: "###" ATÉ: "###" - POR "

	//						//	         1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
	//						//	1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	CABEC1 := STR0017 	// "FILIAL  AUT. SERVIÇO                    CLIENTE                                     MUNICIPIO             UF    EQUIPAMENTO                 NRO NF           VLR.NF.      DATA NF.       VENCTO.       MEDIÇÃO"

	TAMANHO := "G"

	// --> GERA VOLUME DE DADOS PARA IMPRESSÃO.  (QUERY)
	QRYLOCR17()

	dbSelectArea("TRB")

	// --> SETREGUA -> INDICA QUANTOS REGISTROS SERAO PROCESSADOS PARA A REGUA.
	SetRegua(LastRec())
	dbGoTop()

	cCodVen   := TRB->FP0_VENDED
	cNumNFANT := ""
	cNumNF    := ""
	_cProject := ""

	While TRB->(!Eof())

		INCREGUA()

		// --> VERIFICA O CANCELAMENTO PELO USUARIO...
		/*
		If     TRB->FP0_REVISA == "00"
			_cProject := TRB->FP0_PROJET
			If TRB->FP0_STATUS == "A"  												// REVISADO   (1=Digitado ; 2=Em Aprovacao ; 3=Aprovado ; 4=Nao Aprovado ; 5=Fechado ; 6=Cancelado ; 7=Rejeitado ; 8=Finalizado)
				dbSelectArea("TRB")
				dbSkip()
				Loop
			EndIf

		ElseIf TRB->FP0_STATUS == "5"
			If SubStr(_cProject,1,11) <> SubStr(TRB->FP0_PROJET,1,11)
				dbSelectArea("FP0")
				dbSetOrder(1)
				If dbSeek(TRB->FP0_FILIAL+SubStr(TRB->FP0_PROJET,1,11))
					If FP0->FP0_DATINC < MV_PAR15  .Or.  FP0->FP0_DATINC > MV_PAR16
						dbSelectArea("TRB")
						dbSkip()
						Loop
					EndIf
				EndIf
			EndIf
			dbSelectArea("TRB")

		Else
			dbSelectArea("TRB")
			dbSkip()
			Loop

		EndIf
		*/

		//If cNumNFANT == TRB->FPN_COD
		//	TRB->(dbSkip())
		//	Loop
		//EndIf
		//cNumNFANT := TRB->FPN_COD

		//If !Empty(cCOND)
		//	If !&cCOND
		//		(CALIASX1)->(dbSkip())
		//		Loop
		//	EndIf
		//EndIf


		cAs := TRB->FPA_AS
		lTem := .F.
		nValor := 0
		If !lMvLocBac

			/*
			+TRB->FP0_FILIAL+
			+TRB->FPA_AS+
			*/

			CQUERYX   := " SELECT C6_NUM, C6_VALOR "
			CQUERYX   += " FROM "+RETSQLNAME("SC6")+" SC6 (NOLOCK) "
			CQUERYX   += " WHERE  C6_FILIAL  =  ? "
			CQUERYX   += "   AND  C6_XAS     =  ? "
			CQUERYX   += "   AND  SC6.D_E_L_E_T_ = '' "
			CQUERYX := CHANGEQUERY(CQUERYX)
			aBindParam := {TRB->FP0_FILIAL,TRB->FPA_AS}
			CALIASX1 := MPSysOpenQuery(CQUERYX,,,,aBindParam)
			//DBUSEAREA(.T.,"TOPCONN", TCGENQRY(,,CQUERYX),CALIASX1, .F., .T.)
		Else
			/*
			+TRB->FPA_AS+
			+TRB->FP0_FILIAL+
			*/
			CQUERYX := " SELECT C6_NUM, C6_VALOR "
			CQUERYX += " FROM "+RETSQLNAME("SC6")+" SC6 (NOLOCK) "
			CQUERYX += " INNER JOIN " + RETSQLNAME("FPZ") + " FPZ ON FPZ_FILIAL = C6_FILIAL AND FPZ_PEDVEN = C6_NUM "
			CQUERYX += " AND FPZ.D_E_L_E_T_ = '' AND FPZ_ITEM = C6_ITEM AND FPZ_AS <> '' AND FPZ_AS = ? "
			CQUERYX += " INNER JOIN " + RETSQLNAME("FPY") + " FPY ON FPY_FILIAL =  C6_FILIAL AND FPY_PEDVEN = C6_NUM "
			CQUERYX += " AND FPY.D_E_L_E_T_ = '' AND FPY_STATUS <> '2' "
			CQUERYX += " WHERE  C6_FILIAL  =  ? "
			CQUERYX += "   AND  SC6.D_E_L_E_T_ = '' "
			CQUERYX := CHANGEQUERY(CQUERYX)
			aBindParam := {TRB->FPA_AS,TRB->FP0_FILIAL }
			CALIASX1 := MPSysOpenQuery(CQUERYX,,,,aBindParam)
			//DBUSEAREA(.T.,"TOPCONN", TCGENQRY(,,CQUERYX),CALIASX1, .F., .T.)
		EndIF
		While !(CALIASX1)->(Eof())
			SC5->(dbSetOrder(1))
			SC5->(dbSeek(TRB->FP0_FILIAL+(CALIASX1)->C6_NUM))
			cTipo := ""

			If !lMvLocBac
				If SC5->C5_XTIPFAT == "R" .or. empty(SC5->C5_XTIPFAT)
					(CALIASX1)->(dbSkip())
					Loop
				EndIF
				If SC5->C5_XTIPFAT == "P"
					cTipo := "Fat.Automatico"
				EndIF
				If SC5->C5_XTIPFAT == "M"
					cTipo := "Medicao"
				EndIF
			Else
				cTipFat := ""
				FPZ->(dbSetOrder(1))
				If FPY->(dbSeek(xFilial("FPY")+SC5->C5_NUM))
					If FPY->FPY_STATUS <> "2"
						cTipFat := FPY->FPY_TIPFAT
					EndIF
				EndIF

				If cTipFat == "R" .or. empty(cTipFat)
					(CALIASX1)->(dbSkip())
					Loop
				EndIF
				If cTipFat == "P"
					cTipo := "Fat.Automatico"
				EndIF
				If cTipFat == "M"
					cTipo := "Medicao"
				EndIF
			EndIF

			cNumPV := (CALIASX1)->C6_NUM
			nValor := (CALIASX1)->C6_VALOR

			cNumNF   := Posicione("SC6" , 1 , TRB->FP0_FILIAL+ cNumPV         , "C6_NOTA"   )
			CSERIE   := Posicione("SC6" , 1 , TRB->FP0_FILIAL+ cNumPV         , "C6_SERIE"  )
			dEmissao := Posicione("SF2" , 1 , xFilial("SF2") + cNumNF+CSERIE  , "F2_EMISSAO")
			dVencto  := Posicione("SE1" , 1 , xFilial("SE1") + CSERIE+cNumNF  , "E1_VENCTO" )

			If empty(cNumNF)
				(CALIASX1)->(dbSkip())
				Loop
			EndIF

			If empty(dEmissao)
				(CALIASX1)->(dbSkip())
				Loop
			EndIF

			If dEmissao < MV_PAR15  .Or.  dEmissao > MV_PAR16
				(CALIASX1)->(dbSkip())
				Loop
			EndIf

			// --> IMPRESSAO DO CABECALHO DO RELATORIO. . .
			If nLin > 55 																// SALTO DE PÁGINA. NESTE CASO O FORMULARIO TEM 55 LINHAS...
				CABEC(TITULO , CABEC1 , CABEC2 , NOMEPROG , TAMANHO , nTIPO)
				nLin := 9
				If     aReturn[8] == 1													// --> Ordem: FILIAL
					@ nLin, 00 PSay STR0020+TRB->FP0_FILIAL 							// "FILIAL: "
				ElseIf aReturn[8] == 2													// --> Ordem: PROJETO
					@ nLin, 00 PSay STR0021+TRB->FP0_PROJET 							// "PROJETO: "
				ElseIf aReturn[8] == 3													// --> Ordem: GESTOR
					@ nLin, 00 PSay STR0022+TRB->FP0_VENDED+" - "+Posicione("SA3",1,xFilial("SA3")+TRB->FP0_VENDED , "A3_NOME") 				// "GESTOR: "
				ElseIf aReturn[8] == 4													// --> Ordem: OBRA
					_cNOBRA  := Posicione("FP1" , 1 , TRB->(FP0_FILIAL+FP0_PROJET+FPA_OBRA) , "FP1_NOMORI")
					_cMUOBR  := Posicione("FP1" , 1 , TRB->(FP0_FILIAL+FP0_PROJET+FPA_OBRA) , "FP1_MUNORI")
					_cESOBR  := Posicione("FP1" , 1 , TRB->(FP0_FILIAL+FP0_PROJET+FPA_OBRA) , "FP1_ESTORI")
					@ nLin, 00 PSay STR0023+TRB->FPA_OBRA + " - " + SubStr(_cNOBRA,1,20)+ " - " + SubStr(_cMUOBR,1,20) + " - " + _cESOBR 	// "OBRA: "
				ElseIf aReturn[8] == 5													// --> Ordem: EQUIPAMENTO
					@ nLin, 00 PSay STR0024+TRB->FPA_GRUA							// "EQUIPTO.: "
				EndIf
				nLin++
			EndIf

			// REGRAS DE IMPRESSAO
			nREC := 0

			If     aReturn[8] == 1														// --> Ordem: FILIAL
				If _cFILIAL <> TRB->FP0_FILIAL
					QUEBRR17(@nLin)
				EndIf
			ElseIf aReturn[8] == 2														// --> Ordem: PROJETO
				If cPROJ    <> TRB->FP0_PROJET
					QUEBRR17(@nLin)
				EndIf
			ElseIf aReturn[8] == 3														// --> Ordem: GESTOR
				If cCodVen  <> TRB->FP0_VENDED
					QUEBRR17(@nLin)
				EndIf
			ElseIf aReturn[8] == 4														// --> Ordem: OBRA
				If cOBRA <> TRB->FPA_OBRA
					QUEBRR17(@nLin)
				EndIf
			ElseIf aReturn[8] == 5														// --> Ordem: EQUIPAMENTO
				If cEQUIPTO <> TRB->FPA_GRUA
					QUEBRR17(@nLin)
				EndIf
			EndIf

			_cNOBRA := Posicione("FP1" , 1 , TRB->(FP0_FILIAL+FP0_PROJET+FPA_OBRA) , "FP1_NOMORI")
			_cMUOBR := Posicione("FP1" , 1 , TRB->(FP0_FILIAL+FP0_PROJET+FPA_OBRA) , "FP1_MUNORI")
			_cESOBR := Posicione("FP1" , 1 , TRB->(FP0_FILIAL+FP0_PROJET+FPA_OBRA) , "FP1_ESTORI")

			@ nLin,002 PSay TRB->FP0_FILIAL
			@ nLin,009 PSay TRB->FPA_AS
			@ nLin,040 PSay SubStr(TRB->FP0_CLINOM,1,40)
			@ nLin,084 PSay SubStr(_cMUOBR,1,20) 										// 108
			@ nLin,106 PSay _cESOBR 													// 133

// TROCAR T9_CODFA POR T9_CODFAMI
// DSERLOCA - 2448 - Rossana - 13/03/24

			dbSelectArea("ST9")
			dbSetOrder(1)
			If dbSeek(xFilial("ST9")+TRB->FPA_GRUA)
				If !Empty(ST9->T9_CODFAMI)
					@ nLin,112 PSay ST9->T9_CODFAMI
				Else
					@ nLin,112 PSay SubStr(TRB->FPA_GRUA,1,26)
				EndIf
			EndIf

			@ nLin,140 PSay cNumNF
			@ nLin,150 PSay Transform(nValor, PesqPict("FPN","FPN_VALTOT"))

			nTotalG += nValor
			nTotalT += nValor

			@ nLin,170 PSay DtoC(dEmissao)
			@ nLin,185 PSay DtoC(dVencto)

			@ nLin,200 PSay cTipo

			nLin := nLin+1

			(CALIASX1)->(dbSkip())
		EndDo
		(CALIASX1)->(DBCLOSEAREA())

		//If lAbortPrint
		//	@ nLin,00 PSay STR0019 													// "*** CANCELADO PELO OPERADOR ***"
		//	Exit
		//EndIf

		dbSelectArea("TRB")
		dbSkip()

	EndDo

	nLin := nLin+1
	@ nLin,000 PSay __PRTTHINLINE()
	nLin := nLin+1
	@ nLin,000 PSay __PRTRIGHT(STR0025+Transform(nTotalG , "@E 9,999,999,999,999.99"  ) ) 		// "VALOR TOTAL : "
	nLin := nLin+1
	@ nLin,000 PSay __PRTTHINLINE()
	nLin := nLin+1
	@ nLin,000 PSay __PRTRIGHT(STR0026+Transform(nTotalT , "@E 999,999,999,999,999.99") ) 		// "TOTAL GERAL : "
	nLin := nLin+1
	@ nLin,000 PSay __PRTTHINLINE()
	nLin := nLin+1

	// --> FINALIZA A EXECUCAO DO RELATORIO...                                 ³
	If Select("TRB") > 0
		dbSelectArea("TRB")
		dbCloseArea()
	EndIf

	Set Device To Screen

	// --> SE IMPRESSAO EM DISCO, CHAMA O GERENCIADOR DE IMPRESSAO...
	If aReturn[5]==1
		DBCOMMITALL()
		Set Printer To
		OurSpool(WNREL)
	EndIf

	MS_FLUSH()

Return



// ======================================================================= \\
static Function QRYLOCR17()
// ======================================================================= \\
// --> FUNCAO PARA MONTAR OS TRANSPORTES E TIPOS DE TANSPORTES
Local cQuery

	If Select("TRB") > 0
		dbSelectArea("TRB")
		dbCloseArea()
	EndIf
	/*
	FP0 - PROJETOS
	FP1 - OBRAS
	FP4 - EQUIPAMENTO X PROJETO
	FPA - LOCACAO X PROJETO
	FPN - MEDICAO
	FPY - FATURAMENTO AUTOMATICO
	FPZ - FATURAMENTO AUTOMATICO - ITENS
	*/

	/*
	+     MV_PAR01 +
	+     MV_PAR02 +
	+     MV_PAR03 +
	+     MV_PAR04 +
	+     MV_PAR05 +
	+     MV_PAR07 +
	+     MV_PAR06 +
	+     MV_PAR08 +
	+     MV_PAR09 +
	+     MV_PAR10 +
	+DtoS(MV_PAR15)+
	+DtoS(MV_PAR16)+
	+MV_PAR11+
	+MV_PAR12+
	+MV_PAR13+
	+MV_PAR14+
	*/

	cQuery     := " SELECT DISTINCT FP0_FILIAL , FP0_PROJET , FP0_REVISA , FP0_TIPOSE , FP0_STATUS , FP0_DATINC , FP0_CLI    , FP0_LOJA   , FP0_CLINOM , "
	cQuery     += "                 FP0_VENDED , "
	cQuery += "                 FPA_OBRA   , FPA_SEQGRU , FPA_GRUA, FPA_AS   "
	cQuery += " FROM   "+ RetSQLName("FP0") + " FP0 "                         /* FP0 = PROJETOS */
	cQuery += "        INNER JOIN " + RetSQLName("FPA") + " FPA ON FPA_PROJET = FP0_PROJET AND FP0_FILIAL = FPA_FILIAL "
	cQuery     += " WHERE  FP0_FILIAL BETWEEN ? AND ? "
	cQuery     += "   AND  FP0_PROJET BETWEEN ? AND ? "
	cQuery     += "   AND  FP0_CLI    BETWEEN ? AND ? "
	cQuery     += "   AND  FP0_LOJA   BETWEEN ? AND ? "
	cQuery     += "   AND  FP0_VENDED BETWEEN ? AND ? "
	cQuery     += "   AND  FP0.D_E_L_E_T_ = ' ' "
	cQuery     += "   AND FP0_DATINC BETWEEN ? AND ? "
	cQuery += "   AND  FP0_PROJET = FPA_PROJET "
	cQuery += "   AND  FPA_OBRA   BETWEEN ? AND ? "
	cQuery += "   AND  FPA_GRUA   BETWEEN ? AND ? "
	cQuery += "   AND  FPA_AS <> '' "
	cQuery += "   AND  FPA_GRUA   NOT IN ('OPERADOR') "
	cQuery += "   AND  FPA.D_E_L_E_T_ = ' ' "
	// TIPO SERVICO
	cQuery += "   AND  FP0_TIPOSE = 'L' "
	// ORDEM DO RELATORIO
	// FILIAL / PROJETO / GESTOR / OBRA / EQUIPTO
	If     aReturn[8] == 1															// --> Ordem: FILIAL
		cQuery += " ORDER BY FP0_FILIAL , FP0_PROJET , FP0_REVISA"
	ElseIf aReturn[8] == 2															// --> Ordem: PROJETO
		cQuery += " ORDER BY FP0_PROJET , FP0_REVISA"
	ElseIf aReturn[8] == 3															// --> Ordem: GESTOR
		cQuery += " ORDER BY FP0_VENDED , FP0_PROJET , FP0_REVISA"
	ElseIf aReturn[8] == 4															// --> Ordem: OBRA
		cQuery += " ORDER BY FP0_PROJET , FP0_REVISA , FPA_OBRA"
	ElseIf aReturn[8] == 5															// --> Ordem: EQUIPAMENTO
		//cQuery += " ORDER BY FP0_PROJET , FP0_REVISA , FPA_SEQGRU , FPA_GRUA   , FPN_COD "        + CRLF
		cQuery += " ORDER BY FP0_PROJET , FP0_REVISA , FPA_SEQGRU , FPA_GRUA   "
	EndIf
	cQuery := ChangeQuery(cQuery)

	aBindParam := {	MV_PAR01,;
					MV_PAR02,;
					MV_PAR03,;
					MV_PAR04,;
					MV_PAR05,;
					MV_PAR07,;
					MV_PAR06,;
					MV_PAR08,;
					MV_PAR09,;
					MV_PAR10,;
					DtoS(MV_PAR15),;
					DtoS(MV_PAR16),;
					MV_PAR11,;
					MV_PAR12,;
					MV_PAR13,;
					MV_PAR14}
	MPSysOpenQuery(cQuery,"TRB",,,aBindParam)
	//TcQuery cQuery NEW ALIAS "TRB"

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ QUEBRR17 º AUTOR ³ IT UP BUSINESS     º DATA ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function QUEBRR17(nLin)

	nLin := nLin+1
	If nTotalG > 0
		@ nLin,000 PSay  __PRTTHINLINE()
		nLin := nLin+1
		@ nLin,000 PSay  __PRTRIGHT(STR0025+Transform(nTotalG , "@E 9,999,999,999,999.99") ) 								// "VALOR TOTAL : "
		nLin := nLin+1
		@ nLin,000 PSay  __PRTTHINLINE()
		nLin := nLin+2
	EndIF

	If     aReturn[8] == 1															// --> Ordem: GESTOR
		@ nLin, 00 PSay STR0020+TRB->FP0_FILIAL 									// "FILIAL: "
		_cFILIAL := TRB->FP0_FILIAL
	ElseIf aReturn[8] == 2															// --> Ordem: PROJETO
		@ nLin, 00 PSay STR0021+TRB->FP0_PROJET 									// "PROJETO: "
		cPROJ    := TRB->FP0_PROJET
	ElseIf aReturn[8] == 3															// --> Ordem: GESTOR
		@ nLin, 00 PSay STR0022+TRB->FP0_VENDED+" - "+Posicione("SA3",1,xFilial("SA3")+TRB->FP0_VENDED , "A3_NOME") 	// "GESTOR: "
		cCodVen  := TRB->FP0_VENDED
	ElseIf aReturn[8] == 4															// --> Ordem: OBRA
		@ nLin, 00 PSay STR0023+TRB->FPA_OBRA 									// "OBRA: "
		cOBRA := TRB->FPA_OBRA
	ElseIf aReturn[8] == 5															// --> Ordem: EQUIPAMENTO
		@ nLin, 00 PSay STR0024+TRB->FPA_GRUA 									// "EQUIPTO.: "
		cEQUIPTO := TRB->FPA_GRUA
	EndIf

	nLin := nLin + 1

	nTotalG := 0

Return nLin



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³VALIDPERG º AUTOR ³ IT UP BUSINESS     º DATA ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//Static Function VALIDPERG(cPERG)
/*
Local _sAlias := Alias()
Local aRegs   := {}
Local I , J
Local nTF     := Len(cFilAnt)

cPERG := PadR(cPERG , 10)

//         {GRUPO,ORDEM,PERGUNT            ,PERSPA              ,PERENG              ,VARIAVEL,TIP,TAM,DEC,PRESEL,GSC,VALID                                    ,VAR01     ,DEF01,DEFSPA1,DEFENG1,CNT01,VAR02,DEF02,DEFSPA2,DEFENG2,CNT02,VAR03,DEF03,DEFSPA3,DEFENG3,CNT03,VAR04,DEF04,DEFSPA4,DEFENG4,CNT04,VAR05,DEF05,DEFSPA5,DEFENG5,CNT05,F3,PYME,GRPSXG,HELP,PICTURE})
aAdd(aRegs,{cPERG,"01" ,"Filial de ?"      ,"¿De sucursal ?"     ,"From Branch ?"    ,"MV_CH1","C",nTF,0  ,0     ,"G",""                                       ,"MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","",""    ,"S","","",""})
aAdd(aRegs,{cPERG,"02" ,"Filial Ate ?"     ,"¿A Sucursal ?"      ,"To Branch ?"      ,"MV_CH2","C",nTF,0  ,0     ,"G","NaoVazio() .And. (MV_PAR02 >= MV_PAR01)","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","",""    ,"S","","",""})
aAdd(aRegs,{cPERG,"03" ,"Projeto de ?"     ,"¿De Proyecto ?"     ,"From Project ?"   ,"MV_CH3","C",16 ,0  ,0     ,"G",""                                       ,"MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","FP0T","S","","",""})
aAdd(aRegs,{cPERG,"04" ,"Projeto ate ?"    ,"¿A Proyecto ?"      ,"To Project ?"     ,"MV_CH4","C",16 ,0  ,0     ,"G","NaoVazio() .And. (MV_PAR04 >= MV_PAR03)","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","FP0T","S","","",""})
aAdd(aRegs,{cPERG,"05" ,"Cliente de ?"     ,"¿De Cliente ?"      ,"From Customer ?"  ,"MV_CH5","C",06 ,0  ,0     ,"G",""                                       ,"MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","SA1" ,"S","","",""})
aAdd(aRegs,{cPERG,"06" ,"Loja de ?"        ,"¿De Tienda ?"       ,"From store ?"     ,"MV_CH6","C",02 ,0  ,0     ,"G",""                                       ,"MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","",""    ,"S","","",""})
aAdd(aRegs,{cPERG,"07" ,"Cliente ate ?"    ,"¿A Cliente ?"       ,"To Customer ?"    ,"MV_CH7","C",06 ,0  ,0     ,"G","NaoVazio() .And. (MV_PAR07 >= MV_PAR05)","MV_PAR07","","","","","","","","","","","","","","","","","","","","","","","","","SA1" ,"S","","",""})
aAdd(aRegs,{cPERG,"08" ,"Loja ate ?"       ,"¿A Tienda ?"        ,"To store ?"       ,"MV_CH8","C",02 ,0  ,0     ,"G","NaoVazio() .And. (MV_PAR08 >= MV_PAR06)","MV_PAR08","","","","","","","","","","","","","","","","","","","","","","","","",""    ,"S","","",""})
aAdd(aRegs,{cPERG,"09" ,"Gestor de ?"      ,"¿De Administrador ?","From Manager ?"   ,"MV_CH9","C",06 ,0  ,0     ,"G",""                                       ,"MV_PAR09","","","","","","","","","","","","","","","","","","","","","","","","","SA3" ,"S","","",""})
aAdd(aRegs,{cPERG,"10" ,"Gestor Ate ?"     ,"¿A Administrador ?" ,"To Manager ?"     ,"MV_CHA","C",06 ,0  ,0     ,"G","NaoVazio() .And. (MV_PAR10 >= MV_PAR09)","MV_PAR10","","","","","","","","","","","","","","","","","","","","","","","","","SA3" ,"S","","",""})
aAdd(aRegs,{cPERG,"11" ,"Obra de ?"        ,"¿De Obra ?"         ,"From work ?"      ,"MV_CHB","C",03 ,0  ,0     ,"G",""                                       ,"MV_PAR11","","","","","","","","","","","","","","","","","","","","","","","","",""    ,"S","","",""})
aAdd(aRegs,{cPERG,"12" ,"Obra Ate ?"       ,"¿A Obra ?"          ,"To Work ?"        ,"MV_CHC","C",03 ,0  ,0     ,"G","NaoVazio() .And. (MV_PAR12 >= MV_PAR11)","MV_PAR12","","","","","","","","","","","","","","","","","","","","","","","","",""    ,"S","","",""})
aAdd(aRegs,{cPERG,"13" ,"Equipamento de ?" ,"¿De Equipamiento ?" ,"From Equipment ?" ,"MV_CHD","C",16 ,0  ,0     ,"G",""                                       ,"MV_PAR13","","","","","","","","","","","","","","","","","","","","","","","","","ST9" ,"S","","",""})
aAdd(aRegs,{cPERG,"14" ,"Equipamento Ate ?","¿A Equipamiento ?"  ,"To Equipment ?"   ,"MV_CHE","C",16 ,0  ,0     ,"G","NaoVazio() .And. (MV_PAR14 >= MV_PAR13)","MV_PAR14","","","","","","","","","","","","","","","","","","","","","","","","","ST9" ,"S","","",""})
aAdd(aRegs,{cPERG,"15" ,"Periodo de ?"     ,"¿De Período ?"      ,"From period ?"    ,"MV_CHF","D",08 ,0  ,0     ,"G",""                                       ,"MV_PAR15","","","","","","","","","","","","","","","","","","","","","","","","",""    ,"S","","",""})
aAdd(aRegs,{cPERG,"16" ,"Periodo ate ?"    ,"¿A Período ?"       ,"To period ?"      ,"MV_CHG","D",08 ,0  ,0     ,"G","NaoVazio() .And. (MV_PAR16 >= MV_PAR15)","MV_PAR16","","","","","","","","","","","","","","","","","","","","","","","","",""    ,"S","","",""})
//dd(aRegs,{cPERG,"17" ,"Tipo de Servico ?","¿Tipo de servicio ?","Type of Service ?","MV_CHH","N",01 ,0  ,0     ,"C",""                                       ,"MV_PAR17","Locacao","Asignación","Rental","","","Equipamento","Equipamiento","Equipment","","","","","","","","","","","","","","","","","","S","","",""})

For I:=1 To Len(aRegs)
	If !SX1->(dbSeek(cPERG+aRegs[I,2]))
		RecLock("SX1",.T.)
		For J:=1 To FCount()
			If J <= Len(aRegs[I])
				FIELDPUT(J,aRegs[I,J])
			EndIf
		Next J
		MsUnLock()
	EndIf
Next I

dbSelectArea(_SALIAS)
*/
//Return

Static Function LOCR017A()

if FindFunction("LOCR040")
	Aviso("ATENÇÂO", "O relatório LOCR017 está sendo descontinuado em seu lugar utilize o LOCR040 !"+CRLF+"Atualize o menu do modulo de locação para utilizar o novo relatório.",{"Ok"})
	Return .F.
else
	Return .T.
endif
