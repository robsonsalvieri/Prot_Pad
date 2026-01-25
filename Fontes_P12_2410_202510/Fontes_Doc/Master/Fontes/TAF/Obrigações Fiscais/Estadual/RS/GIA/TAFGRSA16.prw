#include 'protheus.ch'
#include 'parmtype.ch'


STATIC aAnexoXVI as Array
STATIC cAtoDec	 as Char
STATIC nCusto	 as Numeric
STATIC qtdAnexoXVI as Numeric

Function TAFGRSA16(aFilial as Array, cDatIni as Char, cDatFim as Char, cCabecalho as Char)

Local cTxtSys  	as Char
Local cStrTxt 	as Char
Local cREG 		as Char
Local cCFOP		as Char
Local cTipReg	as Char
Local cAtoDec	as Char

Local nHandle   as Numeric

Local aTipOBri	as Array

//*****************************
// *** INICIALIZA VARIAVEIS ***
//*****************************
cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
nHandle   	:= MsFCreate( cTxtSys )
cREG 		:= "X16"
cStrTxt 	:= ""

cCFOP		:= ""

nCusto 		:= 0
qtdAnexoXVI := 0

aAnexoXVI 	:= {}

//Regimes em que o Contribuinte esteve enquadrado
//05 - Regime especial
cTipReg := POSICIONE("T39",2,aFilial[1] + Substr(cDatIni,1,4),"T39_TIPREG")
cAtoDec := POSICIONE("T39",2,aFilial[1] + Substr(cDatIni,1,4),"T39_ATODEC")

Begin Sequence

	If cTipReg != "05"
		cCFOP := "'5351', '5352', '5353', '5354', '5355', '5356', '5357', '5359', '6351', '6352', '6353', '6354', '6355', '6356', '6357', '6359'"
		BuscaInfo(cCFOP, aFilial[1], cDatIni, cDatFim, "1")
		MontaArq("01", @cStrTxt, cCabecalho)

		cCFOP := "'5252', '5253', '5254', '5255', '5256', '5257', '5258'"
		BuscaInfo(cCFOP, aFilial[1], cDatIni, cDatFim, "1")
		MontaArq("02", @cStrTxt, cCabecalho)

		cCFOP := "'5301', '5302', '5303', '5304', '5305', '5306', '5307', '6301', '6302', '6303', '6304', '6305', '6306', '6307', '7301'"
		BuscaInfo(cCFOP, aFilial[1], cDatIni, cDatFim, "1")
		MontaArq("03", @cStrTxt, cCabecalho)

		/*
		Linha 18: Para períodos a partir de 04/2016 não é permitido a
		importação de Natureza 4 (Água) no Anexo XVI. Campo: Anexo XVI: Natureza
		do Anexo

		cCFOP := "'5101', '5102'"
		BuscaInfo(cCFOP, aFilial[1], cDatIni, cDatFim, "1")
		MontaArq("04", @cStrTxt, cCabecalho)
		*/

		cCFOP := "'5103', '5104', '6103', '6104'"
		BuscaInfo(cCFOP, aFilial[1], cDatIni, cDatFim, "1")
		MontaArq("05", @cStrTxt, cCabecalho)

		cCFOP := "'5251', '6251', '7251'"
		BuscaInfo(cCFOP, aFilial[1], cDatIni, cDatFim, "1")
		MontaArq("06", @cStrTxt, cCabecalho)

	Else
		cCFOP := ""
		BuscaInfo(cCFOP, aFilial[1], cDatIni, cDatFim, "1")
		BuscaInfo(cCFOP, aFilial[1], cDatIni, cDatFim, "0")
		MontaArq("09", @cStrTxt, cCabecalho)
	EndIf
//****************************************
//*** GERAÇÃO DO ARQUIVO TEXTO PARCIAL ***
//****************************************
	WrtStrTxt( nHandle, cStrTxt )

	GerTxtGRS( nHandle, cTxtSys, aFilial[01] + "_" + cReg )

	Recover

	lFound := .F.

End Sequence

Return

Static Function BuscaInfo(pCFOP as char, pFilial as char, pDatini as char, pDatFim as char, pTipOp as Char)

Local cSelect	 	as Char
Local cFrom			as Char
Local cWhere 		as Char
Local cGroupBy 		as Char
Local cNewAlias 	as Char

//*****************************
// *** INICIALIZA VARIAVEIS ***
//*****************************
cSelect		:= ""
cFrom		:= ""
cWhere		:= ""
cGroupBy	:= ""
cNewAlias	:= ""

nCusto 		:= 0


	cSelect += " T2D.T2D_CODMUN T2D_CODMUN, "
	cSelect += " SUM(C35.C35_VLISEN) 	+ "
	cSelect += " SUM(C35.C35_VLNT) 		+ "
	cSelect += " SUM(C35.C35_VLOUTR) C35_TOT "

	cFrom	:= RetSqlName("C20") + " C20, "
	cFrom   += RetSqlName("C35") + " C35, "
	cFrom   += RetSqlName("C30") + " C30, "
	If pTipOP == "1" .AND. !Empty(pCFOP)
		cFrom   += RetSqlName("C0Y") + " C0Y, "
	EndIf
	cFrom   += RetSqlName("C1H") + " C1H, "
	cFrom   += RetSqlName("T2D") + " T2D "

	cWhere := " 	C20.C20_FILIAL  = '" + pFilial + "' "
	cWhere += " AND C20.C20_CHVNF	= C30.C30_CHVNF "
	cWhere += " AND C20.C20_FILIAL  = C30.C30_FILIAL "
	cWhere += " AND C30.C30_FILIAL  = C35.C35_FILIAL "
	cWhere += " AND C30.C30_CHVNF   = C35.C35_CHVNF "
	cWhere += " AND C30.C30_NUMITE  = C35.C35_NUMITE "
	cWhere += " AND C30.C30_CODITE  = C35.C35_CODITE "
	cWhere += "	AND C20.C20_DTDOC  >= '" + pDatIni + "' "
	cWhere += "	AND C20.C20_DTDOC  <= '" + pDatFim + "' "
	cWhere += " AND C20.C20_INDOPE  = '" + pTipOP + "' "
	cWhere += " AND C20.C20_FILIAL = C1H.C1H_FILIAL "
	cWhere += " AND C20.C20_CODPAR = C1H.C1H_ID	"
	cWhere += " AND C20.C20_CODSIT NOT IN('000003','000005','000006') "  //CANCELADA, INUTILIZADA E DENEGADA
	cWhere += " AND C1H.C1H_CODMUN = T2D.T2D_IDMUN "
	cWhere += " AND T2D.T2D_TPCLAS = 'GIARS' "
	cWhere += " AND C35.C35_CODTRI = '000002' ""
	If pTipOP == "1" .AND. !Empty(pCFOP)
		cWhere += " AND C0Y.C0Y_ID 		= C30.C30_CFOP "
		cWhere += " AND C0Y.C0Y_FILIAL  = '' "
		cWhere += " AND C0Y.C0Y_CODIGO 	IN (" + pCFOP + ") "
	EndIf

	cGroupBy += " T2D.T2D_CODMUN "

	cSelect      := "%" + cSelect    + "%"
	cFrom        := "%" + cFrom      + "%"
	cWhere       := "%" + cWhere     + "%"
	cGroupBy     := "%" + cGroupBy   + "%"

	cNewAlias	:= GetNextAlias()

	If pTipOP == "1" .AND. !Empty(pCFOP)
		BeginSql Alias cNewAlias

		       SELECT
		             %Exp:cSelect%
		       FROM
		             %Exp:cFrom%
		       WHERE
					%Exp:cWhere% AND
					C20.%NotDel% AND
					C30.%NotDel% AND
					C0Y.%NotDel% AND
					C35.%NotDel%
		       GROUP BY
		             %Exp:cGroupBy%
		EndSql
	Else
		BeginSql Alias cNewAlias

		       SELECT
		             %Exp:cSelect%
		       FROM
		             %Exp:cFrom%
		       WHERE
					%Exp:cWhere% AND
					C20.%NotDel% AND
					C30.%NotDel% AND
					C35.%NotDel%
		       GROUP BY
		             %Exp:cGroupBy%
		EndSql
	EndIf
	DbSelectArea(cNewAlias)
	(cNewAlias)->(DbGoTop())

	While (cNewAlias)->(!EOF())
		IF !Empty((cNewAlias)->C35_TOT)
			If pTipOP == "1"
				aAdd(aAnexoXVI, {PADL( AllTrim((cNewAlias)->T2D_CODMUN), 3, "0" ), StrZero( (cNewAlias)->C35_TOT * 100, 16 ) })
			Else
				nCusto := (cNewAlias)->C35_TOT
			EndIf
		EndIf
		(cNewAlias)->(DbSkip())
	EndDo

Return()

Static Function MontaArq(pTipAnexo, cStrTxt, pCabecalho)

Local nQtdInic 	as Numeric
Local nX		as Numeric
Local nLinha	as Numeric
//*****************************
// *** INICIALIZA VARIAVEIS ***
//*****************************
nQtdInic	:= 0
nX			:= 0
nLinha 		:= 1

	If Empty(Len(aAnexoXVI))
		Return
	EndIf

	nQtdInic := (If ((len(aAnexoXVI) > 40), 40, len(aAnexoXVI)))

	cStrTxt += pCabecalho
	cStrTxt += StrZero(++nSeqGiaRS, 4)
	cStrTxt += "X16 "
	cStrTxt += pTipAnexo
	cStrTxt += PADL(AllTrim(cAtoDec),8,"0")
	cStrTxt += StrZero( nCusto * 100, 16 )
	cStrTxt += StrZero(nQtdInic, 2) //Qtd Linha

	For nX := 1 To Len(aAnexoXVI)
			cStrTxt += aAnexoXVI[nX,1]
			cStrTxt += aAnexoXVI[nX,2]
			If (nX % 40 == 0)
				nLinha++
				cStrTxt += CRLF
				cStrTxt := pCabecalho
				cStrTxt += StrZero(++nSeqGiaRS, 4)
				cStrTxt += "X16 "
				cStrTxt += pTipAnexo
				cStrTxt += PADL(AllTrim(cAtoDec),8,"0")
				cStrTxt += StrZero( nCusto * 100, 16 )
				cStrTxt += (If ((len(aAnexoXVI) - (40 * nLinha) > 0), "40", StrZero(len(aAnexoXVI) - nX, 2))) //Qtd Linha
			EndIf
	Next nX
	cStrTxt += CRLF

	qtdAnexoXVI += Len(aAnexoXVI)

	aAdd (aTotAnexo,{'qtdAnexoXVI',nX})
	aAnexoXVI := {}
Return
