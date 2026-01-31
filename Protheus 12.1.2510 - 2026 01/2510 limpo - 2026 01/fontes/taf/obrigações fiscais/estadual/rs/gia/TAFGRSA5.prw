#include 'protheus.ch'


STATIC nTotAnexoI 	as numeric
STATIC aAnexoVa		as array
STATIC aAnexoVb		as array
STATIC aAnexoVc		as array

Function TAFGRSA5(aFilial as Array, cDatIni as Char, cDatFim as Char, cCabecalho as Char)

Local nHandle   as Numeric
Local oError	as Object
Local cTxtSys  	as Char
Local cStrTxt 	as Char

Local cREG 		as Char

Local cSelect	as Char
Local cFrom		as Char
Local cWhere	as Char
Local cGroupBy 	as Char
Local cAlias1	as Char

Local nLin		as Numeric

//Apuração ICMS
Local nVlrCont  	as Numeric
Local nVlrBase  	as Numeric
Local nVlrImpCrd	as Numeric
Local nVlrIsenNt  	as Numeric
Local nVlrOutros  	as Numeric
Local nVlrExclu  	as Numeric


Local nReg			as Numeric
Local aAnexoV		as Array
Local nD1, nD2      as Numeric

Local nTotDeb   	as Numeric
Local nTotCont  	as Numeric

//*****************************
// *** INICIALIZA VARIAVEIS ***
//*****************************
cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
nHandle   	:= MsFCreate( cTxtSys )
cREG 		:= "X05"
cStrTxt 	:= ""
nTotAnexoI 	:= 0
aAnexoVa	:= {}
aAnexoVb	:= {}
aAnexoVc	:= {}

cAlias1		:= GetNextAlias()
cSelect		:= ""
cFrom		:= ""
cWhere		:= ""
cGroupBy 	:= ""

nReg		:= 0
aAnexoV		:= {}

nTotDeb 	:= 0
nTotCont 	:= 0


Begin Sequence
	//CriaTab()

	cSelect      := " C0Y.C0Y_CODIGO, "
	cSelect      += " SUM(C6Z.C6Z_VLCONT) 	AS C6Z_VLCONT, "
	cSelect      += " SUM(C6Z.C6Z_BASE) 	AS C6Z_BASE, "
	cSelect      += " SUM(C6Z.C6Z_IMPCRD)	AS C6Z_IMPCRD "

	cFrom        := RetSqlName("C2S") + " C2S, "
	cFrom        += RetSqlName("C6Z") + " C6Z, "
	cFrom        += RetSqlName("C0Y") + " C0Y "

	cWhere       := " 		C2S.D_E_L_E_T_ = '' "
	cWhere       += " AND 	C6Z.D_E_L_E_T_ = '' "
	cWhere       += " AND 	C0Y.D_E_L_E_T_ = '' "
	cWhere       += " AND 	C2S.C2S_FILIAL = '" + aFilial[1] + "' "
	cWhere       += " AND 	C6Z.C6Z_FILIAL = '" + aFilial[1] + "' "
	cWhere       += " AND 	C0Y.C0Y_FILIAL = '" + xFilial("C0Y") + "' "
	cWhere       += " AND 	C2S.C2S_TIPAPU = '0' "
	cWhere       += " AND 	C2S.C2S_INDAPU = ' ' "
	cWhere       += " AND 	C2S.C2S_DTINI  >= '" + cDatIni + "'
	cWhere       += " AND 	C2S.C2S_DTFIN  <= '" + cDatFim + "'
	cWhere       += " AND 	C2S.C2S_ID = C6Z.C6Z_ID "
	cWhere       += " AND 	C0Y.C0Y_ID = C6Z.C6Z_CFOP "
	cWhere       += " AND 	C0Y.C0Y_CODIGO BETWEEN '4000' AND '7999'" //Para CFOP de Saídas

	cGroupBy		 := " C0Y.C0Y_CODIGO"

	cSelect      := "%" + cSelect    + "%"
	cFrom        := "%" + cFrom      + "%"
	cWhere       := "%" + cWhere     + "%"
	cGroupBy      := "%" + cGroupBy    + "%"

	BeginSql Alias cAlias1

	       SELECT
	             %Exp:cSelect%
	       FROM
	             %Exp:cFrom%
	       WHERE
	             %Exp:cWhere%
	       GROUP BY
	             %Exp:cGroupBy%
	EndSql

	DbSelectArea(cAlias1)
	(cAlias1)->(DbGoTop())

	nLin := 1
	aAdd(aAnexoV, {})
	While (cAlias1)->(!EOF())
		nReg ++

	  	If nReg > 10
	  		nReg := 0
	  		aAdd(aAnexoV, {})
	  		nLin ++
	  	EndIf
	  	//Soma Total do Anexo V.a - ISENTAS E NÃO TRIBUTADAS
	  	nVlrIsNTr := 0
	  	nVlrIsNTr := AnexoVa((cAlias1)->C0Y_CODIGO, aFilial[1], cDatIni, cDatFim, "A")

	  	//Soma Total do Anexo V.b - OUTRAS
	  	nVlrOutros := 0
	  	nVlrOutros := AnexoVa((cAlias1)->C0Y_CODIGO, aFilial[1], cDatIni, cDatFim, "B")

	  	nVlrExclu := 0
	  	nVlrExclu := AnexoIc((cAlias1)->C0Y_CODIGO, aFilial[1], cDatIni, cDatFim)
		aAdd(aAnexoV[nLin], 	(cAlias1)->C0Y_CODIGO + ;
								StrZero( (cAlias1)->C6Z_VLCONT 	* 100, 13 ) + ;
								StrZero( (cAlias1)->C6Z_BASE 	* 100, 13 ) + ;
								StrZero( (cAlias1)->C6Z_IMPCRD 	* 100, 13 ) + ;
								StrZero( nVlrIsNTr 				* 100, 13 ) + ;
								StrZero( nVlrOutros				* 100, 13 ) + ;
								StrZero( nVlrExclu	 			* 100, 16 ))

		nTotCont += (cAlias1)->C6Z_VLCONT
		nTotDeb  += (cAlias1)->C6Z_IMPCRD

		(cAlias1)->( DbSkip() )
	EndDo
	(cAlias1)->(DbCloseArea())

	aAdd (aTotAnexo,{'AnexoV_Debitos',nTotDeb})
	aAdd (aTotAnexo,{'AnexoV_VlContabil',nTotCont})

//****************************
//* MONTA ANEXO V NO ARQUIVO *
//****************************
	For nD1 := 1 To len(aAnexoV)

		cStrTxt += cCabecalho						//Cabeçalho
		cStrTxt += StrZero(++nSeqGiaRS,4)			//Contador de Linha do Arquivo
		cStrTxt += PADR(Alltrim(cREG),4,"")			//Identificador do Registro

		cStrTxt += StrZero(len(aAnexoV[nD1]),2)

		For nD2 := 1 To len(aAnexoV[nD1])
			cStrTxt += aAnexoV[nD1, nD2]
		Next nD2
		cStrTxt += CRLF
	Next nD1
	aAdd (aTotAnexo,{'qtdAnexoV',nD2})

//*****************************
//* MONTA ANEXO Va NO ARQUIVO *
//*****************************
	nD1 := 0
	nD2 := 0
	For nD1 := 1 To len(aAnexoVa)

		cStrTxt += cCabecalho						//Cabeçalho
		cStrTxt += StrZero(++nSeqGiaRS,4)			//Contador de Linha do Arquivo
		cStrTxt += "X05A"							//Identificador do Registro - FIXO X05A

		cStrTxt += StrZero(len(aAnexoVa[nD1]),2)

		For nD2 := 1 To len(aAnexoVa[nD1])
			cStrTxt += aAnexoVa[nD1, nD2]
		Next nD2
		cStrTxt += CRLF
	Next nD1
	aAdd (aTotAnexo,{'qtdAnexoVa',nD2})

//*****************************
//* MONTA ANEXO Vb NO ARQUIVO *
//*****************************
	nD1 := 0
	nD2 := 0
	For nD1 := 1 To len(aAnexoVb)

		cStrTxt += cCabecalho						//Cabeçalho
		cStrTxt += StrZero(++nSeqGiaRS,4)				//Contador de Linha do Arquivo
		cStrTxt += "X05B"							//Identificador do Registro - FIXO X05A

		cStrTxt += StrZero(len(aAnexoVb[nD1]),2)

		For nD2 := 1 To len(aAnexoVb[nD1])
			cStrTxt += aAnexoVb[nD1, nD2]
		Next nD2
		cStrTxt += CRLF
	Next nD1
	aAdd (aTotAnexo,{'qtdAnexoVb',nD2})

//*****************************
//* MONTA ANEXO Vc NO ARQUIVO *
//*****************************
	nD1 := 0
	nD2 := 0
	For nD1 := 1 To len(aAnexoVc)

		cStrTxt += cCabecalho						//Cabeçalho
		cStrTxt += StrZero(++nSeqGiaRS,4)			//Contador de Linha do Arquivo
		cStrTxt += "X05C"							//Identificador do Registro - FIXO X01C

		cStrTxt += StrZero(len(aAnexoVc[nD1]),2)

		For nD2 := 1 To len(aAnexoVc[nD1])
			cStrTxt += aAnexoVc[nD1, nD2]
		Next nD2
		cStrTxt += CRLF
	Next nD1
	aAdd (aTotAnexo,{'qtdAnexoVc',nD2})

	WrtStrTxt( nHandle, cStrTxt )
	GerTxtGRS( nHandle, cTxtSys, aFilial[01] + "_" + cReg )

	Recover

	lFound := .F.

End Sequence

Return

Static Function AnexoVa(pCFOP, pFilial, pDatini, pDatFim, cTipAnexo)

Local cStrTxt1 as Char

Local cSelect	 as Char
Local cFrom		 as Char
Local cWhere	 as Char
Local cGroupBy 	 as Char
Local cNewAlias	 as Char
Local cMotInc	 as Char

Local nDifConBas as Numeric
Local nVlrBIO	 as Numeric
Local nVlrIO	 as Numeric
Local nLin		 as Numeric


//*****************************
// *** INICIALIZA VARIAVEIS ***
//*****************************
cStrTxt1 := ""
cMotInc	 := ""

cSelect		:= ""
cFrom		:= ""
cWhere		:= ""
cGroupBy	:= ""

nVlrAneAB	:= 0

nDifConBas 	:= 0
nVlrBIO 	:= 0
nVlrIO 		:= 0
nLin		:= 0


	cSelect := " CWZ.CWZ_CODMOT CWZ_CODMOT, "

	If cTipAnexo == "A"
		cSelect += "SUM(C35.C35_VLISEN) + SUM(C35.C35_VLNT) C35_SAIDA "
	ElseIf cTipAnexo == "B"
		cSelect += "SUM(C35.C35_VLOUTR) C35_VLOUTR "
	EndIF

	cFrom	:= RetSqlName("C20") + " C20, "
	cFrom   += RetSqlName("C35") + " C35, "
	cFrom   += RetSqlName("C30") + " C30, "
	cFrom   += RetSqlName("C0Y") + " C0Y, "
	cFrom   += RetSqlName("CWZ") + " CWZ "

	cWhere := " 	C20.C20_FILIAL  = '" + pFilial + "' "
	cWhere += "	AND C20.C20_DTDOC  >= '" + pDatIni + "' "
	cWhere += "	AND C20.C20_DTDOC  <= '" + pDatFim + "' "
	cWhere += " AND C20.C20_INDOPE  = '1' "
	cWhere += " AND C30.C30_FILIAL 	= C20.C20_FILIAL "
	cWhere += " AND C30.C30_CHVNF  	= C20.C20_CHVNF "
	cWhere += " AND C35.C35_FILIAL 	= C20.C20_FILIAL "
	cWhere += " AND C35.C35_CHVNF  	= C20.C20_CHVNF "
	cWhere += " AND C35.C35_NUMITE 	= C30.C30_NUMITE "
	cWhere += " AND C35.C35_CODITE 	= C30.C30_CODITE  "
	cWhere += " AND C30.C30_CFOP 	= C0Y.C0Y_ID "
	cWhere += " AND C0Y.C0Y_FILIAL  = '' "
	cWhere += " AND C0Y.C0Y_CODIGO 	= '" + pCFOP + "' "
	cWhere += " AND CWZ.CWZ_FILIAL 	= ' ' "
	cWhere += " AND CWZ.CWZ_ID     	= C35.C35_IDMINC "

	cGroupBy += " CWZ.CWZ_CODMOT "

	cSelect      := "%" + cSelect    + "%"
	cFrom        := "%" + cFrom      + "%"
	cWhere       := "%" + cWhere     + "%"
	cGroupBy     := "%" + cGroupBy   + "%"

	cNewAlias	:= GetNextAlias()
	BeginSql Alias cNewAlias

	       SELECT
	             %Exp:cSelect%
	       FROM
	             %Exp:cFrom%
	       WHERE
				%Exp:cWhere% AND
				C20.%NotDel% AND
				C30.%NotDel% AND
				C35.%NotDel% AND
				CWZ.%NotDel% AND
				C0Y.%NotDel%
	       GROUP BY
	             %Exp:cGroupBy%
	EndSql
	DbSelectArea(cNewAlias)
	(cNewAlias)->(DbGoTop())
	While (cNewAlias)->(!EOF())

		If cTipAnexo == "A"
			//********************************
			// *** MONTA ARRAY DO ANEXO Va ***
			//********************************
			If (cNewAlias)->C35_SAIDA != 0
				If Len(aAnexoVa) = 0
					aAdd(aAnexoVa, {})
				EndIf
				nLin := Len(aAnexoVa)

			  	If Len(aAnexoVa[nLin]) > 42
			  		aAdd(aAnexoV, {})
			  		nLin := Len(aAnexoVa)
			  	EndIf

			  	nVlrAneAB	:= (cNewAlias)->C35_SAIDA
			  	cMotInc 	:= Substr((cNewAlias)->CWZ_CODMOT, 3, 3)
				aAdd(aAnexoVa[nLin], pCFOP + cMotInc + StrZero( (cNewAlias)->C35_SAIDA * 100, 13 ) )
			EndIf
		ElseIf cTipAnexo == "B"
			//********************************
			// *** MONTA ARRAY DO ANEXO Vb ***
			//********************************
			If (cNewAlias)->C35_VLOUTR != 0
				If Len(aAnexoVb) = 0
					aAdd(aAnexoVb, {})
				EndIf
				nLin := Len(aAnexoVb)

			  	If Len(aAnexoVb[nLin]) > 42
			  		aAdd(aAnexoVb, {})
			  		nLin := Len(aAnexoVb)
			  	EndIf

			  	nVlrAneAB 	:= (cNewAlias)->C35_VLOUTR
			  	cMotInc 	:= Substr((cNewAlias)->CWZ_CODMOT,3,3)
				aAdd(aAnexoVb[nLin], pCFOP + cMotInc + StrZero( (cNewAlias)->C35_VLOUTR * 100, 13 ) )
			EndIf
		EndIF

		(cNewAlias)->( DbSkip() )
	EndDo


Return(nVlrAneAB)


Static Function AnexoIc(pCFOP, pFilial, pDatini, pDatFim)

Local cStrTxt1 as Char

Local cSelect	 as Char
Local cFrom		 as Char
Local cWhere	 as Char
Local cGroupBy 	 as Char
Local cNewAlias	 as Char

Local nVlrExc	 as Numeric
Local nDifConBas as Numeric
Local nVlrBIO	 as Numeric
Local nVlrIO	 as Numeric

Local nLin		as Numeric


//*****************************
// *** INICIALIZA VARIAVEIS ***
//*****************************
cStrTxt1 := ""

cSelect		:= ""
cFrom		:= ""
cWhere		:= ""

nVlrExc		:= 0
nDifConBas 	:= 0
nVlrBIO 	:= 0
nVlrIO 		:= 0
nLin		:= 0

	(cAliasCFOP)->( DbGoTop() )
	(cAliasCFOP)->( DbSetOrder(1) )

	If (cAliasCFOP)->( DbSeek(pCFOP) )

		While (cAliasCFOP)->( !EOF() ) .AND. (cAliasCFOP)->CFOP == pCFOP

			//1 - ICMS/ST
			If (cAliasCFOP)->CODAJU == "1"
				cSelect := ""
				cFrom 	:= ""
				cWhere	:= ""

				cSelect := " SUM(C7A.C7A_IMPCRD) C7A_IMPCRD "

				cFrom	:= RetSqlName("C3J") + " C3J, "
				cFrom   += RetSqlName("C7A") + " C7A, "
				cFrom   += RetSqlName("C0Y") + " C0Y "

				cWhere += " 	C3J.C3J_FILIAL  = '" + pFilial + "' "
				cWhere += " AND C7A.C7A_FILIAL  = '" + pFilial + "' "
				cWhere += " AND C0Y.C0Y_FILIAL  = '" + xFilial("C0Y") + "' "

				cWhere += " AND C3J.C3J_INDMOV	= '1' "
				cWhere += " AND C3J.C3J_ID		= C7A.C7A_ID"
				cWhere += " AND C3J.C3J_DTINI  >= '" + pDatIni + "'
				cWhere += " AND C3J.C3J_DTFIN  <= '" + pDatFim + "'
				cWhere += " AND C0Y.C0Y_ID		= C7A.C7A_CFOP "
				cWhere += " AND C0Y.C0Y_CODIGO 	= '" + pCFOP + "' "

				cSelect      := "%" + cSelect    + "%"
				cFrom        := "%" + cFrom      + "%"
				cWhere       := "%" + cWhere     + "%"

				cNewAlias	:= GetNextAlias()
				BeginSql Alias cNewAlias

				       SELECT
				             %Exp:cSelect%
				       FROM
				             %Exp:cFrom%
				       WHERE
							%Exp:cWhere% AND
							C3J.%NotDel% AND
							C7A.%NotDel% AND
							C0Y.%NotDel%
				EndSql
				DbSelectArea(cNewAlias)

				cStrTxt1 := ""
				If  (cNewAlias)->C7A_IMPCRD != 0

					If Len(aAnexoVc) = 0
						aAdd(aAnexoVc, {})
					EndIf
			  		nLin := Len(aAnexoVc)

					cStrTxt1 := pCFOP
					cStrTxt1 += PADL(AllTrim((cAliasCFOP)->CODAJU),3,"0")
					cStrTxt1 += StrZero( (cNewAlias)->C7A_IMPCRD * 100, 13 )
					cStrTxt1 += Space(60)
				EndIf

				nVlrExc += (cNewAlias)->C7A_IMPCRD
			EndIf
			//2 - IPI
			If (cAliasCFOP)->CODAJU == "2"
				cSelect := ""
				cFrom 	:= ""
				cWhere	:= ""

				cSelect := " SUM(C2P.C2P_VLIPI) C2P_VLIPI "

				cFrom	:= RetSqlName("C2N") + " C2N, "
				cFrom   += RetSqlName("C2P") + " C2P, "
				cFrom   += RetSqlName("C0Y") + " C0Y "

				cWhere += "     C2N.C2N_FILIAL  = '" + pFilial + "' "
				cWhere += " AND C2P.C2P_FILIAL  = '" + pFilial + "' "
				cWhere += " AND C0Y.C0Y_FILIAL  = '" + xFilial("C0Y") + "' "

				cWhere += " AND C2N.C2N_INDAPU	= '0' "
				cWhere += " AND C2N.C2N_ID		= C2P.C2P_ID"
				cWhere += " AND C2N.C2N_DTINI  >= '" + pDatIni + "'
				cWhere += " AND C2N.C2N_DTFIM  <= '" + pDatFim + "'
				cWhere += " AND C0Y.C0Y_ID 	    = C2P.C2P_CFOP "
				cWhere += " AND C0Y.C0Y_CODIGO = '" + pCFOP + "' "

				cSelect      := "%" + cSelect    + "%"
				cFrom        := "%" + cFrom      + "%"
				cWhere       := "%" + cWhere     + "%"

				cNewAlias	:= GetNextAlias()
				BeginSql Alias cNewAlias

				       SELECT
				             %Exp:cSelect%
				       FROM
				             %Exp:cFrom%
				       WHERE
				             %Exp:cWhere% AND
						     C2N.%NotDel% AND
						     C2P.%NotDel% AND
						     C0Y.%NotDel%
				EndSql
				DbSelectArea(cNewAlias)

				cStrTxt1 := ""
				If  (cNewAlias)->C2P_VLIPI != 0

					If Len(aAnexoVc) = 0
						aAdd(aAnexoVc, {})
					EndIf
			  		nLin := Len(aAnexoVc)

					cStrTxt1 := pCFOP
					cStrTxt1 += PADL(AllTrim((cAliasCFOP)->CODAJU),3,"0")
					cStrTxt1 += StrZero( (cNewAlias)->C2P_VLIPI * 100, 13 )
					cStrTxt1 += Space(60)
				EndIf
				nVlrExc += (cNewAlias)->C2P_VLIPI

			EndIf
			//3 - Frete sobre ativo ou uso/consumo
			If (cAliasCFOP)->CODAJU == "3"
				cSelect := ""
				cFrom 	:= ""
				cWhere	:= ""

				cSelect := " SUM(C20.C20_VLRFRT) C20_VLRFRT "

				cFrom +=			 RetSqlName( 'C20' ) + " C20, "
				cFrom +=			 RetSqlName( 'C2F' ) + " C2F, "
				cFrom +=			 RetSqlName( 'C0Y' ) + " C0Y  "

				cWhere += "     C20.C20_FILIAL	= '" + pFilial + "' "
				cWhere += " AND C2F.C2F_FILIAL	= '" + pFilial + "' "
				cWhere += " AND C0Y.C0Y_FILIAL  = '" + xFilial("C0Y") + "' "

				cWhere += " AND C20.C20_INDOPE	= '0' "
				cWhere += " AND C20.C20_CODSIT NOT IN('000003','000005','000006') "  //CANCELADA, INUTILIZADA E DENEGADA
				cWhere += " AND C20.C20_CHVNF	= C2F.C2F_CHVNF
				//cWhere += "	AND C2F.C2F_CODTRI	= '17' "
				cWhere += " AND C0Y.C0Y_ID		= C2F.C2F_CFOP
				cWhere += " AND C20.C20_DTDOC  >= '" + pDatIni + "'
				cWhere += " AND C20.C20_DTDOC  <= '" + pDatFim + "'
				cWhere += " AND C0Y.C0Y_CODIGO IN ('"+ pCFOP +"') "

				cSelect      := "%" + cSelect    + "%"
				cFrom        := "%" + cFrom      + "%"
				cWhere       := "%" + cWhere     + "%"

				cNewAlias	:= GetNextAlias()
				BeginSql Alias cNewAlias

				       SELECT
				             %Exp:cSelect%
				       FROM
				             %Exp:cFrom%
				       WHERE
				             %Exp:cWhere% AND
						     C20.%NotDel% AND
						     C2F.%NotDel% AND
						     C0Y.%NotDel%
				EndSql
				DbSelectArea(cNewAlias)

				cStrTxt1 := ""
				If  (cNewAlias)->C20_VLRFRT != 0

					If Len(aAnexoVc) = 0
						aAdd(aAnexoVc, {})
					EndIf
			  		nLin := Len(aAnexoVc)

					cStrTxt1 := pCFOP
					cStrTxt1 += PADL(AllTrim((cAliasCFOP)->CODAJU),3,"0")
					cStrTxt1 += StrZero( (cNewAlias)->C20_VLRFRT * 100, 13 )
					cStrTxt1 += Space(60)
				EndIf

				nVlrExc += (cNewAlias)->C20_VLRFRT

			EndIf
			//4 - Valor de referência
			If (cAliasCFOP)->CODAJU == "4"
				cSelect := ""
				cFrom 	:= ""
				cWhere	:= ""

				cSelect += " SUM(C6Z.C6Z_VLCONT) C6Z_VLCONT, "
				cSelect += " SUM(C6Z.C6Z_BASE) 	 C6Z_BASE "

				cFrom += RetSqlName( 'C6Z' ) + " C6Z, "
				cFrom += RetSqlName( 'C2S' ) + " C2S, "
				cFrom += RetSqlName( 'C0Y' ) + " C0Y  "

				cWhere += " 	C2S.C2S_FILIAL	= '" + pFilial + "' "
				cWhere += " AND C6Z.C6Z_FILIAL	= '" + pFilial + "' "
				cWhere += " AND C0Y.C0Y_FILIAL  = '" + xFilial("C0Y") + "' "

				cWhere += " AND C2S.C2S_TIPAPU	= '0'
				cWhere += " AND C2S.C2S_ID 		= C6Z.C6Z_ID "
				cWhere += " AND C0Y.C0Y_ID 		= C6Z.C6Z_CFOP "
				cWhere += " AND C2S.C2S_DTINI  >= '" + pDatIni + "'
				cWhere += " AND C2S.C2S_DTFIN  <= '" + pDatFim + "'
				cWhere += " AND C0Y.C0Y_CODIGO IN ('"+ pCFOP +"') "

				cSelect      := "%" + cSelect    + "%"
				cFrom        := "%" + cFrom      + "%"
				cWhere       := "%" + cWhere     + "%"

				cNewAlias	:= GetNextAlias()
				BeginSql Alias cNewAlias

				       SELECT
				             %Exp:cSelect%
				       FROM
				             %Exp:cFrom%
				       WHERE
				             %Exp:cWhere% AND
						     C2S.%NotDel% AND
						     C6Z.%NotDel% AND
						     C0Y.%NotDel%
				EndSql
				DbSelectArea(cNewAlias)

				cStrTxt1 := ""
				IF (cNewAlias)->C6Z_VLCONT < (cNewAlias)->C6Z_BASE
					nDifConBas := (cNewAlias)->C6Z_BASE - (cNewAlias)->C6Z_VLCONT

					If  nDifConBas != 0

						If Len(aAnexoVc) = 0
							aAdd(aAnexoVc, {})
						EndIf
				  		nLin := Len(aAnexoVc)

						cStrTxt1 := pCFOP
						cStrTxt1 += PADL(AllTrim((cAliasCFOP)->CODAJU),3,"0")
						cStrTxt1 += StrZero( nDifConBas * 100, 13 )
						cStrTxt1 += Space(60)
					EndIf
					nVlrExc += nDifConBas
				EndIf
			EndIf
			//5 - Soma das colunas (Base, Isentas/NT, Outras)
			If (cAliasCFOP)->CODAJU == "5"
				cSelect := ""
				cFrom 	:= ""
				cWhere	:= ""

				cSelect += " SUM(C6Z.C6Z_BASE) 	 C6Z_BASE, "
				cSelect += " SUM(C6Z.C6Z_ISENNT) C6Z_ISENNT, "
				cSelect += " SUM(C6Z.C6Z_OUTROS) C6Z_OUTROS "

				cFrom += RetSqlName( 'C6Z' ) + " C6Z, "
				cFrom += RetSqlName( 'C2S' ) + " C2S, "
				cFrom += RetSqlName( 'C0Y' ) + " C0Y  "

				cWhere += " 	C2S.C2S_FILIAL	= '" + pFilial + "' "
				cWhere += " AND C6Z.C6Z_FILIAL	= '" + pFilial + "' "
				cWhere += " AND C0Y.C0Y_FILIAL  = '" + xFilial("C0Y") + "' "

				cWhere += " AND C2S.C2S_TIPAPU	= '0'
				cWhere += " AND C2S.C2S_ID 		= C6Z.C6Z_ID "
				cWhere += " AND C0Y.C0Y_ID 		= C6Z.C6Z_CFOP "
				cWhere += " AND C2S.C2S_DTINI  >= '" + pDatIni + "'
				cWhere += " AND C2S.C2S_DTFIN  <= '" + pDatFim + "'
				cWhere += " AND C0Y.C0Y_CODIGO IN ('"+ pCFOP +"') "

				cSelect      := "%" + cSelect    + "%"
				cFrom        := "%" + cFrom      + "%"
				cWhere       := "%" + cWhere     + "%"

				cNewAlias	:= GetNextAlias()
				BeginSql Alias cNewAlias

				       SELECT
				             %Exp:cSelect%
				       FROM
				             %Exp:cFrom%
				       WHERE
				             %Exp:cWhere% AND
						     C6Z.%NotDel% AND
						     C2S.%NotDel% AND
						     C0Y.%NotDel%
				EndSql

				DbSelectArea(cNewAlias)
				nVlrBIO := (cNewAlias)->C6Z_BASE + (cNewAlias)->C6Z_ISENNT + (cNewAlias)->C6Z_OUTROS

				cStrTxt1 := ""
				If  nVlrBIO != 0

					If Len(aAnexoVc) = 0
						aAdd(aAnexoVc, {})
					EndIf
			  		nLin := Len(aAnexoVc)

					cStrTxt1 := pCFOP
					cStrTxt1 += PADL(AllTrim((cAliasCFOP)->CODAJU),3,"0")
					cStrTxt1 += StrZero( nVlrBIO * 100, 13 )
					cStrTxt1 += Space(60)
				EndIf

				nVlrExc += nVlrBIO

			EndIf

			//6 - Exclusões Parciais
			If (cAliasCFOP)->CODAJU == "6"
				cSelect := ""
				cFrom 	:= ""
				cWhere	:= ""

				cSelect += " SUM(C6Z.C6Z_ISENNT) C6Z_ISENNT, "
				cSelect += " SUM(C6Z.C6Z_OUTROS) C6Z_OUTROS "

				cFrom += RetSqlName( 'C6Z' ) + " C6Z, "
				cFrom += RetSqlName( 'C2S' ) + " C2S, "
				cFrom += RetSqlName( 'C0Y' ) + " C0Y  "

				cWhere += " 	C2S.C2S_FILIAL	= '" + pFilial + "' "
				cWhere += " AND C6Z.C6Z_FILIAL	= '" + pFilial + "' "
				cWhere += " AND C0Y.C0Y_FILIAL  = '" + xFilial("C0Y") + "' "

				cWhere += " AND C2S.C2S_TIPAPU	= '0'
				cWhere += " AND C2S.C2S_ID 		= C6Z.C6Z_ID "
				cWhere += " AND C0Y.C0Y_ID 		= C6Z.C6Z_CFOP "
				cWhere += " AND C2S.C2S_DTINI  >= '" + pDatIni + "'
				cWhere += " AND C2S.C2S_DTFIN  <= '" + pDatFim + "'
				cWhere += " AND C0Y.C0Y_CODIGO IN ('"+ pCFOP +"') "

				cSelect      := "%" + cSelect    + "%"
				cFrom        := "%" + cFrom      + "%"
				cWhere       := "%" + cWhere     + "%"

				cNewAlias	:= GetNextAlias()
				BeginSql Alias cNewAlias

				       SELECT
				             %Exp:cSelect%
				       FROM
				             %Exp:cFrom%
				       WHERE
				             %Exp:cWhere% AND
						     C6Z.%NotDel% AND
						     C2S.%NotDel% AND
						     C0Y.%NotDel%
				EndSql

				DbSelectArea(cNewAlias)
				nVlrIO := (cNewAlias)->C6Z_ISENNT + (cNewAlias)->C6Z_OUTROS

				cStrTxt1 := ""
				If  nVlrIO != 0

					If Len(aAnexoVc) = 0
						aAdd(aAnexoVc, {})
					EndIf
			  		nLin := Len(aAnexoVc)

					cStrTxt1 := pCFOP
					cStrTxt1 += PADL(AllTrim((cAliasCFOP)->CODAJU),3,"0")
					cStrTxt1 += StrZero( nVlrIO * 100, 13 )
					cStrTxt1 += Space(60)
				EndIf
				nVlrExc += nVlrIO
			EndIf

			If !Empty(cStrTxt1)
			  	If Len(aAnexoVc[nLin]) > 10
			  		aAdd(aAnexoVc, {})
			  		nLin := Len(aAnexoVc)
			  	EndIf

				aAdd(aAnexoVc[nLin], cStrTxt1 )
			EndIf
			(cAliasCFOP)->( DbSkip() )

		EndDo
	EndIf


Return(nVlrExc)

