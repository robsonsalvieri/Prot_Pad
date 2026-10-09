#INCLUDE "TOTVS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "TECR960.CH"

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TECR960()
Relatório de Ficha de Localização

@sample 	TECR960()
@return		oReport, 	Object,	Objeto do relatório de Ficha de Localização

@author 	Kaique Schiller
@since		27/05/2019
/*/

//--------------------------------------------------------------------------------------------------------------------
Function TECR960()
	Local oReport   := Nil
	Private cAlias1 := GetNextAlias()
	Private cPerg   := "TECR960"

	If TRepInUse()
		Pergunte(cPerg,.F.)
		oReport := Rt960RDef()
		oReport:SetLandScape()
		oReport:PrintDialog()
	EndIf

Return(.T.)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Rt960RDef()
Ficha de Localização - monta as Sections para impressão do relatório

@sample Rt960RDef()
@return oReport

@author 	Kaique Schiller
@since		29/05/2019
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function Rt960RDef()
	Local oReport		:= Nil
	Local oSection1 	:= Nil
	Local oSection2 	:= Nil

	oReport   := TReport():New("TECR960",STR0001,cPerg,{|oReport| Rt960Print(oReport)},STR0001) //"Ficha de Localização"

	oSection1 := TRSection():New(oReport	,FwX2Nome("TGY") ,{"AA1"},,,,,,,,,,,,,.T.)
	DEFINE CELL NAME "TGY_ATEND"  OF oSection1 ALIAS "AA1"
	DEFINE CELL NAME "TGY_NOMTEC" OF oSection1 TITLE STR0005 SIZE (TamSX3("AA1_NOMTEC")[1]) BLOCK {|| Posicione("AA1",1, xFilial("AA1")+PadR(Trim((cAlias1)->TGY_ATEND), TamSx3("AA1_NOMTEC")[1]),"AA1->AA1_NOMTEC") } 	//"Nome Atend."

	oSection2 := TRSection():New(oSection1	,FwX2Nome("TGY") ,{"TGY","ABS","SRJ"},,,,,,,,,,3,,,.T.)
	DEFINE CELL NAME "ABS_LOCAL"		OF oSection2 ALIAS "ABS" TITLE STR0006 //"Código Local"
	DEFINE CELL NAME "ABS_DESCRI"		OF oSection2 ALIAS "ABS"
	DEFINE CELL NAME "ABS_CODIGO"		OF oSection2 ALIAS "ABS" TITLE STR0007 //"Código Cliente"
	DEFINE CELL NAME "ABS_LOJA"			OF oSection2 ALIAS "ABS"
	DEFINE CELL NAME "ABS_NOMECLI"  	OF oSection2 TITLE STR0008 SIZE (TamSX3("A1_NOME")[1]) BLOCK {|| Posicione("SA1",1, xFilial("SA1")+PadR(Trim((cAlias1)->(ABS_CODIGO+ABS_LOJA)), TamSx3("A1_NOME")[1]),"SA1->A1_NOME") } //"Nome Cliente"
	DEFINE CELL NAME "TGY_ESCALA"		OF oSection2 ALIAS "TGY"
	DEFINE CELL NAME "TGY_TURNO"		OF oSection2 ALIAS "TGY"
	DEFINE CELL NAME "TGY_CODTFF"		OF oSection2 ALIAS "TGY" TITLE STR0004
	DEFINE CELL NAME "RJ_DESC"  		OF oSection2 TITLE STR0009 SIZE (TamSX3("RJ_DESC")[1]) BLOCK {|| Posicione("SRJ",1, xFilial("SRJ")+PadR(Trim((cAlias1)->(TFF_FUNCAO)), TamSx3("RJ_DESC")[1]),"SRJ->RJ_DESC") } //"Desc. Func."
	DEFINE CELL NAME "TGY_DTINI"		OF oSection2 ALIAS "TGY"
	DEFINE CELL NAME "TGY_ULTALO"		OF oSection2 ALIAS "TGY"
	DEFINE CELL NAME "TGY_ENTRA1"		OF oSection2 ALIAS "TGY" TITLE STR0002 BLOCK {|| At960HrAlc("E", cAlias1) } //"Hr. Entrada"
	DEFINE CELL NAME "TGY_SAIDA1"		OF oSection2 ALIAS "TGY" TITLE STR0003 BLOCK {|| At960HrAlc("S", cAlias1) } //"Hr. Saída"
	DEFINE CELL NAME "COBERTURA"		OF oSection2 ALIAS "TGY" TITLE STR0010 //"Cobertura" 

Return oReport

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Rt960Print()
Endereço de Cliente - monta a Query e imprime o relatorio de acordo com os parametros

@sample 	Rt960Print(oReport)

@param		oReport, 	Object,	Objeto do relatório de postos vagos
			
@return 	Nenhum

@author 	Kaique Schiller
@since		29/05/2019
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function Rt960Print(oReport)
	Local cNao      := STR0012
	Local cQuery    := ''
	Local cSim      := STR0011
	Local nNum      := 1
	Local oExec     := Nil
	Local oSection1 := oReport:Section(1)
	Local oSection2 := oSection1:Section(1)

	cQuery := "SELECT  "
	cQuery +=     "TGY.TGY_ATEND      AS TGY_ATEND, "
	cQuery +=     "TGY.TGY_ESCALA     AS TGY_ESCALA, "
	cQuery +=     "TGY.TGY_TURNO      AS TGY_TURNO, "
	cQuery +=     "TGY.TGY_SEQ        AS TGY_SEQ, "
	cQuery +=     "ABS.ABS_CODIGO, "
	cQuery +=     "ABS.ABS_LOJA, "
	cQuery +=     "ABS.ABS_LOCAL, "
	cQuery +=     "ABS.ABS_DESCRI, "
	cQuery +=     "TGY.TGY_DTINI      AS TGY_DTINI, "
	cQuery +=     "TGY.TGY_ULTALO     AS TGY_ULTALO, "
	cQuery +=     "TGY.TGY_DTFIM      AS TGY_DTFIM, "
	cQuery +=     "TGY.TGY_ENTRA1, "
	cQuery +=     "TGY.TGY_SAIDA1, "
	cQuery +=     "TGY.TGY_ENTRA2, "
	cQuery +=     "TGY.TGY_SAIDA2, "
	cQuery +=     "TGY.TGY_ENTRA3, "
	cQuery +=     "TGY.TGY_SAIDA3, "
	cQuery +=     "TGY.TGY_ENTRA4, "
	cQuery +=     "TGY.TGY_SAIDA4, "
	cQuery +=     "TGY.TGY_CODTFF, "
	cQuery +=     "TFF.TFF_FUNCAO, "
	cQuery +=     "?                  AS COBERTURA "
	cQuery += "FROM ? TGY "
	cQuery +=     "INNER JOIN ? TFF ON TFF.TFF_FILIAL = ? "
	cQuery +=                           "AND TFF.TFF_COD = TGY.TGY_CODTFF "
	cQuery +=                           "AND TFF.D_E_L_E_T_ = ' ' "
	cQuery +=     "INNER JOIN ? TFL ON TFL.TFL_FILIAL = ? "
	cQuery +=                           "AND TFL.TFL_CODIGO = TFF.TFF_CODPAI "
	cQuery +=                           "AND TFL.D_E_L_E_T_ = ' ' "
	cQuery +=     "INNER JOIN ? TFJ ON TFJ.TFJ_FILIAL = ? "
	cQuery +=                           "AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI "
	cQuery +=                           "AND TFJ.D_E_L_E_T_ = ' ' "
	cQuery +=     "INNER JOIN ? ABS ON ABS.ABS_FILIAL = ? "
	cQuery +=                           "AND ABS.ABS_LOCAL = TFL.TFL_LOCAL "
	cQuery +=                           "AND ABS.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE TGY.TGY_FILIAL = ? "
	cQuery +=     "AND TGY.D_E_L_E_T_ = ' ' "
	cQuery +=     "AND TGY.TGY_ATEND  BETWEEN ? AND ? "
	cQuery +=     "AND TGY.TGY_ULTALO BETWEEN ? AND ?  "
	cQuery +=     "AND TFL.TFL_LOCAL  BETWEEN ? AND ?  "
	cQuery +=     "AND TFF.TFF_FUNCAO BETWEEN ? AND ?  "
	cQuery +=     "AND TFJ.TFJ_CONTRT BETWEEN ? AND ?  "
	cQuery += "UNION ALL "
	cQuery += "SELECT  "
	cQuery +=     "TGZ.TGZ_ATEND     AS TGY_ATEND, "
	cQuery +=     "TGZ.TGZ_ESCALA    AS TGY_ESCALA, "
	cQuery +=     "TGZ.TGZ_TURNO     AS TGY_TURNO, "
	cQuery +=     "TGZ.TGZ_SEQ       AS TGY_SEQ, "
	cQuery +=     "ABS.ABS_CODIGO, "
	cQuery +=     "ABS.ABS_LOJA, "
	cQuery +=     "ABS.ABS_LOCAL, "
	cQuery +=     "ABS.ABS_DESCRI, "
	cQuery +=     "TGZ.TGZ_DTINI     AS TGY_DTINI, "
	cQuery +=     "TGZ.TGZ_DTFIM     AS TGY_ULTALO, "
	cQuery +=     "TGZ.TGZ_DTFIM     AS TGY_DTFIM, "
	cQuery +=     "' '               AS TGY_ENTRA1, "
	cQuery +=     "' '               AS TGY_SAIDA1, "
	cQuery +=     "' '               AS TGY_ENTRA2, "
	cQuery +=     "' '               AS TGY_SAIDA2, "
	cQuery +=     "' '               AS TGY_ENTRA3, "
	cQuery +=     "' '               AS TGY_SAIDA3, "
	cQuery +=     "' '               AS TGY_ENTRA4, "
	cQuery +=     "' '               AS TGY_SAIDA4, "
	cQuery +=     "TGZ.TGZ_CODTFF, "
	cQuery +=     "TFF.TFF_FUNCAO, "
	cQuery +=     "?                 AS COBERTURA "
	cQuery += "FROM ? TGZ "
	cQuery +=     "INNER JOIN ? TFF ON TFF.TFF_FILIAL = ? "
	cQuery +=                           "AND TFF.TFF_COD = TGZ.TGZ_CODTFF "
	cQuery +=                           "AND TFF.D_E_L_E_T_ = ' ' "
	cQuery +=     "INNER JOIN ? TFL ON TFL.TFL_FILIAL = ? "
	cQuery +=                           "AND TFL.TFL_CODIGO = TFF.TFF_CODPAI "
	cQuery +=                           "AND TFL.D_E_L_E_T_ = ' ' "
	cQuery +=     "INNER JOIN ? TFJ ON TFJ.TFJ_FILIAL = ? "
	cQuery +=                           "AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI "
	cQuery +=                           "AND TFJ.D_E_L_E_T_ = ' ' "
	cQuery +=     "INNER JOIN ? ABS ON ABS.ABS_FILIAL = ? "
	cQuery +=                           "AND ABS.ABS_LOCAL = TFL.TFL_LOCAL "
	cQuery +=                           "AND ABS.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE TGZ.TGZ_FILIAL = ? "
	cQuery +=     "AND TGZ.D_E_L_E_T_ = ' ' "
	cQuery +=     "AND TGZ.TGZ_ATEND   BETWEEN ? AND ? "
	cQuery +=     "AND ( TGZ.TGZ_DTINI BETWEEN ? AND ?  "
	cQuery +=        "OR TGZ.TGZ_DTFIM BETWEEN ? AND ?  ) "
	cQuery +=     "AND TFL.TFL_LOCAL   BETWEEN ? AND ?  "
	cQuery +=     "AND TFF.TFF_FUNCAO  BETWEEN ? AND ?  "
	cQuery +=     "AND TFJ.TFJ_CONTRT  BETWEEN ? AND ?  "
	cQuery += "ORDER BY TGY_ATEND, TGY_DTINI "

	cQuery := ChangeQuery( cQuery )
	oExec := FwExecStatement():New(cQuery)

	oExec:SetString( nNum++, cNao )
	oExec:SetUnsafe( nNum++, RetSqlName("TGY") )
	oExec:SetUnsafe( nNum++, RetSqlName("TFF") )
	oExec:SetString( nNum++, FwxFilial("TFF") )
	oExec:SetUnsafe( nNum++, RetSqlName("TFL") )
	oExec:SetString( nNum++, FwxFilial("TFL") )
	oExec:SetUnsafe( nNum++, RetSqlName("TFJ") )
	oExec:SetString( nNum++, FwxFilial("TFJ") )
	oExec:SetUnsafe( nNum++, RetSqlName("ABS") )
	oExec:SetString( nNum++, FwxFilial("ABS") )
	oExec:SetString( nNum++, FwxFilial("TGY") )
	oExec:SetString( nNum++, MV_PAR01 ) // Atendente De
	oExec:SetString( nNum++, MV_PAR02 ) // Atendente Até
	oExec:SetDate(   nNum++, MV_PAR03 ) // Data De
	oExec:SetDate(   nNum++, MV_PAR04 ) // Data Até
	oExec:SetString( nNum++, MV_PAR05 ) // Local De
	oExec:SetString( nNum++, MV_PAR06 ) // Local Até
	oExec:SetString( nNum++, MV_PAR07 ) // Função De
	oExec:SetString( nNum++, MV_PAR08 ) // Função Até
	oExec:SetString( nNum++, MV_PAR09 ) // Contrato De
	oExec:SetString( nNum++, MV_PAR10 ) // Contrato Até
	oExec:SetString( nNum++, cSim )
	oExec:SetUnsafe( nNum++, RetSqlName("TGZ") )
	oExec:SetUnsafe( nNum++, RetSqlName("TFF") )
	oExec:SetString( nNum++, FwxFilial("TFF") )
	oExec:SetUnsafe( nNum++, RetSqlName("TFL") )
	oExec:SetString( nNum++, FwxFilial("TFL") )
	oExec:SetUnsafe( nNum++, RetSqlName("TFJ") )
	oExec:SetString( nNum++, FwxFilial("TFJ") )
	oExec:SetUnsafe( nNum++, RetSqlName("ABS") )
	oExec:SetString( nNum++, FwxFilial("ABS") )
	oExec:SetString( nNum++, FwxFilial("TGZ") )
	oExec:SetString( nNum++, MV_PAR01 ) // Atendente De
	oExec:SetString( nNum++, MV_PAR02 ) // Atendente Até
	oExec:SetDate(   nNum++, MV_PAR03 ) // Data De => TGZ_DTINI
	oExec:SetDate(   nNum++, MV_PAR04 ) // Data Até
	oExec:SetDate(   nNum++, MV_PAR03 ) // Data De => TGZ_DTFIM
	oExec:SetDate(   nNum++, MV_PAR04 ) // Data Até
	oExec:SetString( nNum++, MV_PAR05 ) // Local De
	oExec:SetString( nNum++, MV_PAR06 ) // Local Até
	oExec:SetString( nNum++, MV_PAR07 ) // Função De
	oExec:SetString( nNum++, MV_PAR08 ) // Função Até
	oExec:SetString( nNum++, MV_PAR09 ) // Contrato De
	oExec:SetString( nNum++, MV_PAR10 ) // Contrato Até

	cQuery := oExec:GetFixQuery()
	oSection1:SetQuery(cAlias1, cQuery)
	oSection1:SetParentQuery(.F.)
	oExec:Destroy()
	FwFreeObj(oExec)

	DBSelectArea(cAlias1)
	(cAlias1)->(DbGoTop())

	oSection2:SetParentQuery()
	oSection2:SetParentFilter({|cParam| (cAlias1)->TGY_ATEND == cParam},{|| (cAlias1)->TGY_ATEND })

	oSection1:Print()

	(cAlias1)->(DbCloseArea())
			
Return(.T.)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At960HrAlc()
Seleciona o horário de entrada e saida do posto.

@sample 	At960HrAlc(cTip,cAlias1)

@param		cTip, 		String,	E = Entrada, S = Saida.
			cAlias1,	String,	Nome do alias da Query do relatório 
			
@return 	Nenhum

@author 	Kaique Schiller
@since		29/05/2019
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At960HrAlc(cTip, cAlias1)
	Local cAliasTemp := ""
	Local cCodEftv   := ""
	Local cDiaSem    := ""
	Local cEscala    := ""
	Local cQuery     := ""
	Local cSeq       := ""
	Local cTurno     := ""
	Local nNum       := 1
	Local nX         := 0
	Local oExec      := Nil
	Local xHrRet     := ""

	//Verifica se existe horário flexivel na TGY caracter.
	If cTip == "E" .And. !Empty((cAlias1)->TGY_ENTRA1)
		xHrRet := (cAlias1)->TGY_ENTRA1

	Elseif cTip == "S"
		For nX := 1 to 4
			If !Empty(&("(cAlias1)->TGY_SAIDA" + cValToChar(nX)))
				xHrRet := &("(cAlias1)->TGY_SAIDA" + cValToChar(nX))
			EndIf
		Next nX
	Endif

	If Empty(xHrRet)

		//Verifica qual é o primeiro horário da escala conforme o turno e a sequencia.
		cEscala := (cAlias1)->TGY_ESCALA
		cTurno  := (cAlias1)->TGY_TURNO
		cSeq	:= (cAlias1)->TGY_SEQ

		cQuery := "SELECT 	TGW.TGW_HORINI, "
		cQuery +=     "TGW.TGW_HORFIM, "
		cQuery +=     "TGW.TGW_HORFIM, "
		cQuery +=     "TGW.TGW_DIASEM, "
		cQuery +=     "TGW.TGW_EFETDX "
		cQuery += "FROM ? TGW "
		cQuery +=     "INNER JOIN ? TDX ON TDX.TDX_FILIAL = ? "
		cQuery +=         "AND TDX.TDX_CODTDW = ? "
		cQuery +=         "AND TDX.TDX_TURNO  = ? "
		cQuery +=         "AND TDX.TDX_SEQTUR = ? "
		cQuery +=         "AND TDX.TDX_COD    = TGW.TGW_EFETDX "
		cQuery +=         "AND TDX.D_E_L_E_T_ = ' ' "
		cQuery += "WHERE TGW.TGW_FILIAL = ? "
		cQuery +=     "AND TGW.D_E_L_E_T_ = ' ' "
		cQuery += "ORDER BY TGW.TGW_FILIAL,TGW.TGW_EFETDX,TGW.TGW_DIASEM,TGW_HORINI "

		cQuery := ChangeQuery(cQuery)
		oExec := FwExecStatement():New(cQuery)

		oExec:SetUnsafe( nNum++, RetSqlName("TGW") )
		oExec:SetUnsafe( nNum++, RetSqlName("TDX") )
		oExec:SetString( nNum++, FwxFilial("TDX") )
		oExec:SetString( nNum++, cEscala )
		oExec:SetString( nNum++, cTurno )
		oExec:SetString( nNum++, cSeq )
		oExec:SetString( nNum++, FwxFilial("TGW") )

		cAliasTemp := oExec:OpenAlias()
		oExec:Destroy()
		FwFreeObj(oExec)

		DBSelectArea(cAliasTemp)
		(cAliasTemp)->(DbGoTop())

		cDiaSem  := (cAliasTemp)->TGW_DIASEM
		cCodEftv := (cAliasTemp)->TGW_EFETDX

		While (cAliasTemp)->(!EOF()) .And. cDiaSem == (cAliasTemp)->TGW_DIASEM .And. cCodEftv == (cAliasTemp)->TGW_EFETDX
			If cTip == "E"
				xHrRet :=  (cAliasTemp)->TGW_HORINI
				Exit

			Elseif cTip == "S"
				xHrRet :=  (cAliasTemp)->TGW_HORFIM
			Endif
		
			(cAliasTemp)->(dbSkip())
		EndDo

		(cAliasTemp)->(dbCloseArea())

		If Empty(xHrRet)

			cAliasTemp := GetNextAlias()

			cQuery := "SELECT 	SPJ.PJ_ENTRA1, SPJ.PJ_SAIDA1, "
			cQuery +=     "SPJ.PJ_ENTRA2, SPJ.PJ_SAIDA2, "
			cQuery +=     "SPJ.PJ_ENTRA3, SPJ.PJ_SAIDA3, "
			cQuery +=     "SPJ.PJ_ENTRA4, SPJ.PJ_SAIDA4 "
			cQuery += "FROM ? SPJ "
			cQuery += "WHERE SPJ.PJ_FILIAL = ? "
			cQuery +=     "AND SPJ.PJ_TURNO = ? "
			cQuery +=     "AND SPJ.PJ_SEMANA = ? "
			cQuery +=     "AND SPJ.PJ_TPDIA = 'S' "
			cQuery +=     "AND SPJ.D_E_L_E_T_ = ' ' "
			cQuery += "ORDER BY SPJ.PJ_FILIAL,SPJ.PJ_TURNO,SPJ.PJ_SEMANA,SPJ.PJ_DIA "

			cQuery := ChangeQuery(cQuery)
			oExec := FwExecStatement():New(cQuery)

			nNum := 1
			oExec:SetUnsafe( nNum++, RetSqlName("SPJ") )
			oExec:SetString( nNum++, FwxFilial("SPJ") )
			oExec:SetString( nNum++, cTurno )
			oExec:SetString( nNum++, cSeq )

			cAliasTemp := oExec:OpenAlias()
			oExec:Destroy()
			FwFreeObj(oExec)

			DBSelectArea(cAliasTemp)
			(cAliasTemp)->(DbGoTop())

			If (cAliasTemp)->(!EOF())
				For nX := 1 To 4
					If cTip == "E"
						xHrRet :=  cValtoChar((cAliasTemp)->PJ_ENTRA1)
						Exit
					Elseif cTip == "S" .And. &("(cAliasTemp)->PJ_SAIDA"+cValtoChar(nX)) <> 0
						xHrRet :=  cValToChar(&("(cAliasTemp)->PJ_SAIDA"+cValtoChar(nX)))
					Endif
				Next nX
			Endif
			(cAliasTemp)->(dbCloseArea())
		Endif
	Endif

	If Valtype(xHrRet) == "C"
		xHrRet := Val(xHrRet)
	Endif

	xHrRet := Atr960CvHr(xHrRet)

Return xHrRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Atr960CvHr
Realiza conversão de hora para formato utilizado pela rotina

@since 03/06/2019
@author Kaique Schiller
@param nHora, numérico, Hora no formato Inteiro
@return String, Hora em String no formato utilizado pela rotina
/*/
//--------------------------------------------------------------------------------------------------------------------
Function Atr960CvHr(nHoras)
	Local nHora := Int(nHoras)
	Local nMinuto := (nHoras - nHora)*100

Return(StrZero(nHora, 2) + ":" + StrZero(nMinuto, 2))
