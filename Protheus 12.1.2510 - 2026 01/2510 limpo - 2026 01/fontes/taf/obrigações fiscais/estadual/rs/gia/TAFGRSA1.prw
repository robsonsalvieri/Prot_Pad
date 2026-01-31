#include 'protheus.ch'

STATIC aAnexoIc	as array

Function TAFGRSA1(aFilial as Array, cDatIni as Char, cDatFim as Char, cCabecalho as Char)

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

Local nTotCred  	as Numeric
Local nTotCont  	as Numeric


Local nReg			as Numeric
Local aAnexoI		as Array
Local nD1, nD2      as Numeric


//*****************************
// *** INICIALIZA VARIAVEIS ***
//*****************************
cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
nHandle   	:= MsFCreate( cTxtSys )
cREG 		:= "X01"
cStrTxt 	:= ""
aAnexoIc	:= {}

cAlias1	:= GetNextAlias()
cSelect		:= ""
cFrom		:= ""
cWhere		:= ""
cGroupBy 	:= ""

nReg		:= 0
nTotCred 	:= 0
nTotCont 	:= 0
aAnexoI		:= {}


Begin Sequence
	//CriaTab()

	cSelect      := " C0Y.C0Y_CODIGO, "
	cSelect      += " SUM(C6Z.C6Z_VLCONT) 	AS C6Z_VLCONT, "
	cSelect      += " SUM(C6Z.C6Z_BASE) 	AS C6Z_BASE, "
	cSelect      += " SUM(C6Z.C6Z_IMPCRD)	AS C6Z_IMPCRD, "
	cSelect      += " SUM(C6Z.C6Z_ISENNT)	AS C6Z_ISENNT, "
	cSelect      += " SUM(C6Z.C6Z_OUTROS)	AS C6Z_OUTROS "

	cFrom        := RetSqlName("C2S") + " C2S, "
	cFrom        += RetSqlName("C6Z") + " C6Z, "
	cFrom        += RetSqlName("C0Y") + " C0Y "

	cWhere       += "       C2S.C2S_FILIAL = '" + aFilial[1] + "' "
	cWhere       += " AND 	C6Z.C6Z_FILIAL = '" + aFilial[1] + "' "
	cWhere       += " AND 	C0Y.C0Y_FILIAL = '" + xFilial("C0Y") + "' "
	cWhere       += " AND 	C2S.C2S_TIPAPU = '0' "
	cWhere       += " AND 	C2S.C2S_INDAPU = ' ' "
	cWhere       += " AND 	C2S.C2S_DTINI  >= '" + cDatIni + "'
	cWhere       += " AND 	C2S.C2S_DTFIN  <= '" + cDatFim + "'
	cWhere       += " AND 	C2S.C2S_ID = C6Z.C6Z_ID "
	cWhere       += " AND 	C0Y.C0Y_ID = C6Z.C6Z_CFOP "
	cWhere       += " AND 	C0Y.C0Y_CODIGO BETWEEN '1000' AND '3999'" //Para CFOP de Entrada

	cGoupBy		 := " C0Y.C0Y_CODIGO "

	cSelect      := "%" + cSelect    + "%"
	cFrom        := "%" + cFrom      + "%"
	cWhere       := "%" + cWhere     + "%"
	cGoupBy      := "%" + cGoupBy    + "%"

	BeginSql Alias cAlias1

	       SELECT
	             %Exp:cSelect%
	       FROM
	             %Exp:cFrom%
	       WHERE
				%Exp:cWhere% AND
				C2S.%NotDel% AND
				C6Z.%NotDel% AND
				C0Y.%NotDel%
	       GROUP BY
	             %Exp:cGoupBy%
	EndSql

	DbSelectArea(cAlias1)
	(cAlias1)->(DbGoTop())

	nLin := 1
	aAdd(aAnexoI, {})
	While (cAlias1)->(!EOF())
		nReg ++

	  	If nReg > 10
	  		nReg := 0
	  		aAdd(aAnexoI, {})
	  		nLin ++
	  	EndIf
	  	nVlrExclu := 0
	  	nVlrExclu := AnexoIc((cAlias1)->C0Y_CODIGO, aFilial[1], cDatIni, cDatFim, nReg)
		aAdd(aAnexoI[nLin], 	(cAlias1)->C0Y_CODIGO + ;
								StrZero( (cAlias1)->C6Z_VLCONT 	* 100, 13 ) + ;
								StrZero( (cAlias1)->C6Z_BASE 	* 100, 13 ) + ;
								StrZero( (cAlias1)->C6Z_IMPCRD 	* 100, 13 ) + ;
								StrZero( (cAlias1)->C6Z_ISENNT 	* 100, 13 ) + ;
								StrZero( (cAlias1)->C6Z_OUTROS 	* 100, 13 ) + ;
								StrZero( nVlrExclu	 			* 100, 16 ))

		nTotCred += (cAlias1)->C6Z_IMPCRD
		nTotCont += (cAlias1)->C6Z_VLCONT

		(cAlias1)->( DbSkip() )
	EndDo
	(cAlias1)->(DbCloseArea())

	aAdd (aTotAnexo,{'AnexoI_Creditos',nTotCred})
	aAdd (aTotAnexo,{'AnexoI_VlContabil',nTotCont})

//****************************
//* MONTA ANEXO I NO ARQUIVO *
//****************************
	For nD1 := 1 To len(aAnexoI)

		cStrTxt += cCabecalho						//Cabeçalho
		cStrTxt += StrZero(++nSeqGiaRS,4)			//Contador de Linha do Arquivo
		cStrTxt += PADR(Alltrim(cREG),4,"")			//Identificador do Registro - FIXO X01

		cStrTxt += StrZero(len(aAnexoI[nD1]),2)

		For nD2 := 1 To len(aAnexoI[nD1])
			cStrTxt += aAnexoI[nD1, nD2]
		Next nD2
		cStrTxt += CRLF
	Next nD1

	aAdd (aTotAnexo,{'qtdAnexoI',nD2})

//*****************************
//* MONTA ANEXO Ic NO ARQUIVO *
//*****************************
	nD1 := 0
	nD2 := 0
	For nD1 := 1 To len(aAnexoIc)

		cStrTxt += cCabecalho						//Cabeçalho
		cStrTxt += StrZero(++nSeqGiaRS,4)			//Contador de Linha do Arquivo
		cStrTxt += "X01C"							//Identificador do Registro - FIXO X01C

		cStrTxt += StrZero(len(aAnexoIc[nD1]),2)

		For nD2 := 1 To len(aAnexoIc[nD1])
			cStrTxt += aAnexoIc[nD1, nD2]
		Next nD2
		cStrTxt += CRLF
	Next nD1

	aAdd (aTotAnexo,{'qtdAnexoIc',nD2})

	WrtStrTxt( nHandle, cStrTxt )

	GerTxtGRS( nHandle, cTxtSys, aFilial[01] + "_" + cReg )

	Recover

	lFound := .F.

End Sequence

Return

Static Function AnexoIc(pCFOP as Char, pFilial as Char, pDatini as Char, pDatFim as Char)

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

	//dbSelectArea(cAliasCFOP)
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

					If Len(aAnexoIc) = 0
						aAdd(aAnexoIc, {})
					EndIf
			  		nLin := Len(aAnexoIc)

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

				cWhere += " 	C2N.C2N_FILIAL  = '" + pFilial + "' "
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

					If Len(aAnexoIc) = 0
						aAdd(aAnexoIc, {})
					EndIf
			  		nLin := Len(aAnexoIc)

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

				cWhere += " 	C20.C20_FILIAL	= '" + pFilial + "' "
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

					If Len(aAnexoIc) = 0
						aAdd(aAnexoIc, {})
					EndIf
			  		nLin := Len(aAnexoIc)

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

						If Len(aAnexoIc) = 0
							aAdd(aAnexoIc, {})
						EndIf
				  		nLin := Len(aAnexoIc)

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

				cWhere += "     C2S.C2S_FILIAL	= '" + pFilial + "' "
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
				nVlrBIO := (cNewAlias)->C6Z_BASE + (cNewAlias)->C6Z_ISENNT + (cNewAlias)->C6Z_OUTROS

				cStrTxt1 := ""
				If  nVlrBIO != 0

					If Len(aAnexoIc) = 0
						aAdd(aAnexoIc, {})
					EndIf
			  		nLin := Len(aAnexoIc)

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
							C2S.%NotDel% AND
							C6Z.%NotDel% AND
							C0Y.%NotDel%
				EndSql

				DbSelectArea(cNewAlias)
				nVlrIO := (cNewAlias)->C6Z_ISENNT + (cNewAlias)->C6Z_OUTROS

				cStrTxt1 := ""
				If  nVlrIO != 0

					If Len(aAnexoIc) = 0
						aAdd(aAnexoIc, {})
					EndIf
			  		nLin := Len(aAnexoIc)

					cStrTxt1 := pCFOP
					cStrTxt1 += PADL(AllTrim((cAliasCFOP)->CODAJU),3,"0")
					cStrTxt1 += StrZero( nVlrIO * 100, 13 )
					cStrTxt1 += Space(60)
				EndIf
				nVlrExc += nVlrIO
			EndIf

			If !Empty(cStrTxt1)
			  	If Len(aAnexoIc[nLin]) > 10
			  		aAdd(aAnexoIc, {})
			  		nLin := Len(aAnexoIc)
			  	EndIf

				aAdd(aAnexoIc[nLin], cStrTxt1 )
			EndIf
			(cAliasCFOP)->( DbSkip() )

		EndDo
	EndIf

Return(nVlrExc)

