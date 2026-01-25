#Include "TECR988.ch"
#INCLUDE "TOTVS.CH"

Static oR988Sec1
Static oR988Sec4

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TECR988
Relatório de Postos Descobertos

@sample 	TECR988()
@return		oReport
@author 	Fernando Radu Muscalu
@since		05/10/2023
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TECR988()
Local cPerg		:= "TECR988"
Local oReport	:= Nil

If TRepInUse() 
	Pergunte(cPerg,.F.)		
	oReport := Rt988RDef(cPerg)
	oReport:PrintDialog()
EndIf

If ( Valtype(oR988Sec1) == "O" )
	oR988Sec1:Delete()
	FreeObj(oR988Sec1)
EndIf

If ( Valtype(oR988Sec4) == "O" )
	oR988Sec4:Delete()
	FreeObj(oR988Sec4)
EndIf

Return(.T.)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Rt988RDef
Monta as Sections para impressão do relatório

@sample Rt988RDef(cPerg)
@param 	cPerg 
@return oReport

@author 	Fernando Radu Muscalu
@since		05/10/2023
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function Rt988RDef(cPerg)

	Local oReport   := Nil				
	Local oSection1 := Nil				
	Local oSection2 := Nil				
	Local oSection3 := Nil
	Local oSection4 := Nil
	Local cAlias1   := GetNextAlias()

	oReport := TReport():New("TECR988",STR0001,cPerg,{|oReport| Rt988Print(oReport, cPerg, cAlias1)},STR0001)  //"Postos Descobertos"

	oSection1 := TRSection():New(oReport,STR0003,{"TFJ"},,,,,,,,,,3,,,.T.) //"Contrato"
	TRCell():New(oSection1,"TFJ_CONTRT"  ,"TFJ")
	TRCell():New(oSection1,"TFJ_CONREV"  ,"TFJ")

	oSection2 := TRSection():New(oSection1,STR0004,{"TFL"},,,,,,,,,,6,,,.T.) //"Locais de Atendimento"
	TRCell():New(oSection2,"TFL_LOCAL"  ,"TFL")
	TRCell():New(oSection2,"TFL_DESCRI" ,"TFL",STR0005) //"Descrição"

	oSection3 := TRSection():New(oSection2,STR0006,{"TFF"},,,,,,,,,,9,,,.T.) //"Postos"
	TRCell():New(oSection3,"TFF_COD"    ,"TFF",STR0007,) //"Cód. Posto"
	TRCell():New(oSection3,"ESCALA_DSC" ,     ,STR0008,/*Picture*/,(TamSX3("TDW_DESC")[1]),/*lPixel*/,{|| Posicione("TDW",1, xFilial("TDW")+PadR(Trim((cAlias1)->TFF_ESCALA), TamSx3("TDW_DESC")[1]),"TDW->TDW_DESC") }) //"Desc. Escala"
	TRCell():New(oSection3,"FUNCAO_DSC" ,     ,STR0009,/*Picture*/,(TamSX3("RJ_DESC")[1]) ,/*lPixel*/,{|| Posicione("SRJ",1, xFilial("SRJ")+PadR(Trim((cAlias1)->TFF_FUNCAO), TamSx3("RJ_DESC")[1]),"SRJ->RJ_DESC") }) //"Desc. Função"

	oSection4 := TRSection():New(oSection3,STR0018,{"SEC4"},,,,,,,,,,9,,,.T.) //"Agendas"
	oSection4:SetAutoSize(.T.)
	TRCell():New(oSection4,"DT_AGENDA" ,,STR0011,,10,,{|| (cAlias1)->DT_AGENDA})	//"Data Agenda" 
	TRCell():New(oSection4,"DIA_SEMANA",,STR0019,,10,,{||DiaSemana((cAlias1)->DT_AGENDA)})	//"Dia da Semana" 
	TRCell():New(oSection4,"TFF_QTDVEN","TFF",STR0010,,10,,,,,,,5,.F.) //"Qtd. Postos"
	TRCell():New(oSection4,"QTD_FLTEFV",     ,STR0012,,10,,{|| Transform((cAlias1)->QTD_FLTEFV,"@e 9,999,999")},"RIGHT",,"RIGHT",,5,.t.) //"Qtd. Falta de efetivo"
	TRCell():New(oSection4,"QTD_AUSEFV",     ,STR0013,,10,,{|| Transform((cAlias1)->QTD_AUSEFV,"@e 9,999,999")},"RIGHT",,"RIGHT",,5,.t.) //"Qtd. Falta do efetivo"
	TRCell():New(oSection4,"QTD_DESCOB",     ,STR0014,,10,,{|| Transform((cAlias1)->QTD_DESCOB,"@e 9,999,999")},"RIGHT",,"RIGHT",,5,.t.) //"Qtd. Falta do efetivo"

	TRFunction():New(oSection4:Cell("QTD_FLTEFV"),/*cID*/,"SUM",/*oBreak*/,STR0015,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,/*lEndReport*/,/*lEndPage*/) //"Soma qtdes de faltas de efetivo"
	TRFunction():New(oSection4:Cell("QTD_AUSEFV"),/*cID*/,"SUM",/*oBreak*/,STR0016,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,/*lEndReport*/,/*lEndPage*/) //"Soma qtdes de efetivos que faltaram"
	TRFunction():New(oSection4:Cell("QTD_DESCOB"),/*cID*/,"SUM",/*oBreak*/,STR0017,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,/*lEndReport*/,/*lEndPage*/) //"Soma qtdes de efetivos descobertos"

Return oReport

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Rt988Print
Monta a Query e imprime o relatorio de acordo com os parametros

@sample 	Rt988Print(oReport, cPerg, cAlias1)
@param		oReport, 	Object,	Instância da classe tReport
			cPerg, 		String,	Nome do grupo de perguntas
			cAlias1,	String,	Nome do alias da Query do relatório 
			
@return 	.T.
@author 	Fernando Radu Muscalu
@since		05/10/2023
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function Rt988Print(oReport, cPerg, cAlias1)

	Local oSection1 := oReport:Section(1)		
	Local oSection2 := oSection1:Section(1) 	
	Local oSection3 := oSection2:Section(1) 	
	Local oSection4 := oSection3:Section(1) 	
	Local cTable    := ""
	Local lContinua := .F.
	Local aFldConv  := {}
	Local cQuery    := Rt988QryCon()	//Busca pelos contratos, locais e postos //aR988GesEmp := oReport:GetGCList()
	Local aIndex    := {"TFJ_CODIGO","TFL_CODIGO","TFF_COD"}

	Aadd(aFldConv, {"TFJ_CONTRT", "C", TamSx3("TFJ_CONTRT")[1], 0})
	Aadd(aFldConv, {"TFJ_CONREV", "C", TamSx3("TFJ_CONREV")[1], 0})
	Aadd(aFldConv, {"TFL_LOCAL",  "C", TamSx3("TFL_LOCAL")[1], 0})
	Aadd(aFldConv, {"TFL_DESCRI", "C", TamSx3("ABS_DESCRI")[1], 0})
	Aadd(aFldConv, {"TFL_DTINI",  "D", TamSx3("TFL_DTINI")[1], 0})
	Aadd(aFldConv, {"TFL_DTFIM",  "D", TamSx3("TFL_DTFIM")[1], 0})
	Aadd(aFldConv, {"TFF_COD", "C", TamSx3("TFF_COD")[1], 0})
	Aadd(aFldConv, {"TFF_ESCALA", "C", TamSx3("TFF_ESCALA")[1], 0})
	Aadd(aFldConv, {"TFF_FUNCAO", "C", TamSx3("TFF_FUNCAO")[1], 0})
	
	aTamSX3 := TamSx3("TFF_QTDVEN")
	Aadd(aFldConv, {"TFF_QTDVEN", "N", aTamSX3[1], aTamSX3[2]})
	
	Aadd(aFldConv, {"TFF_PERINI", "D", TamSx3("TFF_PERINI")[1], 0})
	Aadd(aFldConv, {"TFF_PERFIM", "D", TamSx3("TFF_PERFIM")[1], 0})
	Aadd(aFldConv, {"TFL_CODPAI", "C", TamSx3("TFL_CODPAI")[1], 0})
	Aadd(aFldConv, {"TFJ_CODIGO", "C", TamSx3("TFJ_CODIGO")[1], 0})
	Aadd(aFldConv, {"TFF_CODPAI", "C", TamSx3("TFF_CODPAI")[1], 0})
	Aadd(aFldConv, {"TFF_CALEND", "C", TamSx3("TFF_CALEND")[1], 0})
	Aadd(aFldConv, {"TFL_CODIGO",  "C", TamSx3("TFL_CODIGO")[1], 0})

	lContinua := UpdateTable(@oR988Sec1,cQuery,"SEC1",aIndex,aFldConv)
	
	If ( lContinua )
	
		lContinua := CarregaDatas()		//Montas as datas (dia a dia) com as qtd de alocações e qtdes de faltas de efetivo ou ausência do efetivo

		If ( lContinua )
		
			cTable := "%" + oR988Sec4:GetRealName() + "%"

			BEGIN REPORT QUERY oSection1

			BeginSQL Alias cAlias1

				COLUMN DT_AGENDA AS DATE
				
				SELECT
					A.CONTRATO		TFJ_CONTRT,
					A.REVISAO		TFJ_CONREV,
					A.LOCAL_ORC		TFL_LOCAL,
					A.LOCAL_DESC	TFL_DESCRI,
					A.POSTO			TFF_COD,
					A.ESCALA		TFF_ESCALA,
					A.FUNCAO		TFF_FUNCAO,
					A.DT_AGENDA,
					A.QTD_POSTO TFF_QTDVEN,
					QTD_FLTEFV,
					QTD_AUSEFV,
					QTD_ALOCA,
					A.QTD_AUSEFV + QTD_FLTEFV QTD_DESCOB
				FROM
					%Exp:cTable% A
				WHERE
					( A.QTD_AUSEFV > 0 OR QTD_FLTEFV > 0 )
				ORDER BY
					A.CONTRATO,
					A.REVISAO,
					A.LOCAL_ORC,
					A.POSTO,
					A.DT_AGENDA
			EndSql

			END REPORT QUERY oSection1

			(cAlias1)->(DbGoTop())

			oSection2:SetParentQuery()
			oSection2:SetParentFilter({|cParam| (cAlias1)->(TFJ_CONTRT + TFJ_CONREV) == cParam},{|| (cAlias1)->(TFJ_CONTRT + TFJ_CONREV) })

			oSection3:SetParentQuery()
			oSection3:SetParentFilter({|cParam| (cAlias1)->TFL_LOCAL == cParam},{|| (cAlias1)->TFL_LOCAL })

			oSection4:SetParentQuery()
			oSection4:SetParentFilter({|cParam| (cAlias1)->TFF_COD == cParam},{|| (cAlias1)->TFF_COD })

			oSection1:Print()

			(cAlias1)->(DbCloseArea())

		EndIf

	EndIf

Return(.T.)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Rt988QryCon
Monta a tabela temporária que traz os contratos, locais e postos de acordo com parametrização do usuário

@sample 	Rt988QryCon()
@param		
@return 	Nenhum
@author 	Fernando Radu Muscalu
@since		05/10/2023
/*/
//--------------------------------------------------------------------------------------------------------------------
Function Rt988QryCon(cFilter as character)
	
	Local cDtRefDe		:= ""// DtOS(MV_PAR09)
	Local cDtRefAte		:= ""// DtOS(MV_PAR10)
	Local cQuery		:= ""
	Local nOrder        := 0
	Default cFilter     := ""

	cDtRefDe		:= DtOS(MV_PAR09)
	cDtRefAte		:= DtOS(MV_PAR10)

	cQuery += " SELECT TFJ_CONTRT,"
	cQuery +=        " TFJ_CONREV,"
	cQuery +=        " TFL_LOCAL,"
	cQuery +=        " A.ABS_DESCRI TFL_DESCRI,  "
	cQuery +=        " TFL_DTINI,"
	cQuery +=        " TFL_DTFIM,"
	cQuery +=        " TFF_COD,"
	cQuery +=        " TFF_ESCALA,"
	cQuery +=        " TFF_FUNCAO,"
	cQuery +=        " TFF_QTDVEN,"
	cQuery +=        " TFF_QTPREV,"
	cQuery +=        " TFF_PERINI,"
	cQuery +=        " TFF_PERFIM,"
	cQuery +=        " TFL_CODPAI,"
	cQuery +=        " TFJ_CODIGO,"
	cQuery +=        " TFF_CODPAI,"
	cQuery +=        " TFF_CALEND,"
	cQuery +=        " TFL_CODIGO,"
	cQuery +=        " TDW_DESC,"
	cQuery +=        " RJ_DESC"
	cQuery += " FROM ? TFJ "
	cQuery +=      " INNER JOIN ? TFL"
	cQuery +=              " ON ( "
	cQuery +=                  " TFL.TFL_FILIAL = ? "
	cQuery +=                  " AND TFL.TFL_CODPAI = TFJ_CODIGO  "
	cQuery +=                  " AND TFL.D_E_L_E_T_ = ' ' ) "
	cQuery +=      " INNER JOIN ? TFF"
	cQuery +=              " ON ( "
	cQuery +=                  " TFF.TFF_FILIAL = ? "
	cQuery +=                  " AND TFF.TFF_CODPAI = TFL.TFL_CODIGO  "
	cQuery +=                  " AND TFF.D_E_L_E_T_ = ' ' )"
	cQuery +=      " INNER JOIN ? A "
	cQuery +=              " ON ("
	cQuery +=                  " A.ABS_FILIAL = ? "
	cQuery +=                  " AND A.ABS_LOCAL = TFL.TFL_LOCAL "
	cQuery +=                  " AND A.D_E_L_E_T_ = ' ' )"
	cQuery +=     " INNER JOIN ? TDW "
	cQuery +=             " ON ("
	cQuery +=                 " TDW.TDW_FILIAL = ?"
	cQuery +=                 " AND TDW.TDW_COD = TFF.TFF_ESCALA"
	cQuery +=                 " AND TDW.D_E_L_E_T_ = ' ' )"
    cQuery +=     " INNER JOIN ? RJ "
	cQuery +=             " ON ("
	cQuery +=                 " RJ.RJ_FILIAL = ? "
	cQuery +=                 " AND RJ.RJ_FUNCAO = TFF.TFF_FUNCAO "
	cQuery +=                 " AND RJ.D_E_L_E_T_ = ' ' )"
	cQuery += " WHERE TFJ.TFJ_FILIAL = ? "
	cQuery +=       " AND TFJ.TFJ_CONTRT <> '  ' "
	cQuery +=       " AND TFF.TFF_ESCALA <> ' ' "
	cQuery +=       " AND TFJ.TFJ_STATUS = '1' "
	cQuery +=       " AND TFJ.D_E_L_E_T_ = ' ' "
	If TecBHasGvg()
		cQuery +=   " AND TFF.TFF_GERVAG <> '2' "
	EndIf
	cQuery +=       " AND TFL.TFL_LOCAL BETWEEN ? AND ? "
	cQuery +=       " AND TFF.TFF_ESCALA BETWEEN ? AND ? "
	cQuery +=       " AND TFJ.TFJ_CONTRT BETWEEN ? AND ? "
	cQuery +=       " AND TFF.TFF_COD BETWEEN ? AND ? "
	cQuery +=       " AND ( "
	cQuery +=             " ( TFF.TFF_PERINI BETWEEN ? AND ? "
	cQuery +=               " OR TFF.TFF_PERFIM BETWEEN ? AND ? "
	cQuery +=             " ) "
	cQuery +=               " OR ( ? BETWEEN TFF.TFF_PERINI AND TFF.TFF_PERFIM "
	cQuery +=                    " OR ? BETWEEN TFF.TFF_PERINI AND TFF.TFF_PERFIM ) "
	cQuery +=           " ) "
	cQuery +=       " AND TFF.TFF_DTENCE = ' ' "
	If !Empty(cFilter)
		cQuery +=   " AND ?"
	EndIf
	cQuery += "ORDER BY  "
	cQuery += "	TFJ_CODIGO, "
	cQuery += "	TFL_CODIGO, "
	cQuery += "	TFF_COD "
	
	nOrder := 1
	oQuery := FwPreparedStatement():New( cQuery )
	oQuery:SetNumeric( nOrder++, RetSQLName( "TFJ" ) )
	oQuery:SetNumeric( nOrder++, RetSQLName( "TFL" ) )
	oQuery:SetString(  nOrder++, FwxFilial( "TFJ" ) )
	oQuery:SetNumeric( nOrder++, RetSQLName( "TFF" ) )
	oQuery:SetString(  nOrder++, FwxFilial( "TFF" ) )
	oQuery:SetNumeric( nOrder++, RetSQLName( "ABS" ) )
	oQuery:SetString(  nOrder++, FwxFilial( "ABS" ) )
	oQuery:SetUnsafe(  nOrder++, RetSQLName( "TDW" ) )
	oQuery:SetString(  nOrder++, FwxFilial( "TDW" ) )
	oQuery:SetUnsafe(  nOrder++, RetSQLName( "SRJ" ) )
	oQuery:SetString(  nOrder++, FwxFilial( "SRJ" ) )
	oQuery:SetString(  nOrder++, FwxFilial( "TFJ" ) )
	oQuery:SetString(  nOrder++,  MV_PAR01 )
	oQuery:SetString(  nOrder++, MV_PAR02 )
	oQuery:SetString(  nOrder++, MV_PAR03 )
	oQuery:SetString(  nOrder++, MV_PAR04 )
	oQuery:SetString(  nOrder++, MV_PAR05 )
	oQuery:SetString(  nOrder++, MV_PAR06 )
	oQuery:SetString(  nOrder++, MV_PAR07 )
	oQuery:SetString(  nOrder++, MV_PAR08 )
	oQuery:SetString(  nOrder++, cDtRefDe )
	oQuery:SetString(  nOrder++, cDtRefAte )
	oQuery:SetString(  nOrder++, cDtRefDe )
	oQuery:SetString(  nOrder++, cDtRefAte )
	oQuery:SetString(  nOrder++, cDtRefDe )
	oQuery:SetString(  nOrder++, cDtRefAte )
	If !Empty(cFilter)
		oQuery:SetUnsafe(  nOrder++, cFilter )
	EndIf
	cQuery := oQuery:GetFixQuery()

Return cQuery

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CarregaDatas
Monta a tabela temporária que lista dia a dia com as qtdes de faltas e alocações

@sample 	CarregaDatas()
@param		
@return 	Nenhum
@author 	Fernando Radu Muscalu
@since		05/10/2023
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function CarregaDatas()
	
	Local cAlias  := oR988Sec1:GetAlias()
	Local lRet    := .F.
	Local lRetAux := .F.

	CreateTable(@oR988Sec4,"SEC4")

	(cAlias)->(DbGoTop())

	While ( (cAlias)->(!Eof()) )

		lRetAux := AtualizaAgendas(	(cAlias)->TFJ_CONTRT,;
									(cAlias)->TFJ_CONREV,;
									(cAlias)->TFL_LOCAL,;
									(cAlias)->TFF_COD,;
									(cAlias)->TFF_ESCALA,;
									(cAlias)->TFF_QTDVEN,;
									(cAlias)->TFL_DESCRI,;
									(cAlias)->TFF_FUNCAO,;
									(cAlias)->TFF_PERFIM,;
									(cAlias)->TFF_CALEND,;
									(cAlias)->TFF_PERINI )
		(cAlias)->(DbSkip())

		If ( lRetAux )
			lRet := .T.
		EndIf

	End While

Return(lRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AtualizaAgendas
Atualiza a tabela temporária, que lista dia a dia com as qtdes de faltas e alocações,
com os dias que não há agenda, para o período escolhido pelo usuário data de/até

@sample 	AtualizaAgendas(cContrato,cRevisao,cLocal,cPosto,cEscala,nQtdPosto,cLocalDesc,cFuncao)
@param		cContrato, string, código do contrato
			cRevisao, string, nro da revisão do contrato
			cLocal, string, código do local de atendimento
			cEscala, string, código da escala
			cPosto, string, códiigo do posto
			nQtdPosto, numeric, quantida prevista de vagas para o posto (cPosto)
			cLocalDesc, string, descricao do local de atendimento
			cFuncao, string, funcao desempenhada pelo atendente para o posto
			dFimPosto, data, período final do posto de atendimento
			cCalend, string, código do calendário de feriados
@return 	Nenhum
@author 	Fernando Radu Muscalu
@since		05/10/2023
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function AtualizaAgendas(cContrato,cRevisao,cLocal,cPosto,cEscala,nQtdPosto,cLocalDesc,cFuncao,dFimPosto,cCalend, dIniPosto)

	Local aQuantidades	:= {}

	Local cAlias	:= ""

	Local dData		:= MV_PAR09
	Local dDataFim	:= MV_PAR10

	Local lRet		:= .F.

	Default dFimPosto	:= MV_PAR10	
	Default dIniPosto	:= MV_PAR09	
	Default cCalend		:= ""	

	dDataFim := Iif(dFimPosto > MV_PAR10, MV_PAR10, dFimPosto)
	dData  := Iif(dIniPosto > MV_PAR09, dIniPosto, MV_PAR09)// 01/04 - 01/03

	cAlias := oR988Sec4:GetAlias()

	While ( dData <= dDataFim )

		aQuantidades := Rt988GetAg(DToS(dData),cContrato,cLocal,cPosto,cEscala,nQtdPosto,,cCalend)

		RecLock(cAlias,.T.)

			(cAlias)->VIA_RESULT:= '0' //Atualizado via inserção por Reclock()
			(cAlias)->CONTRATO	:= cContrato
			(cAlias)->REVISAO	:= cRevisao
			(cAlias)->LOCAL_ORC	:= cLocal
			(cAlias)->LOCAL_DESC:= cLocalDesc
			(cAlias)->POSTO		:= cPosto
			(cAlias)->ESCALA	:= cEscala
			(cAlias)->FUNCAO	:= cFuncao
			(cAlias)->DT_AGENDA	:= dData
			(cAlias)->QTD_POSTO	:= nQtdPosto
			(cAlias)->QTD_FLTEFV:= aQuantidades[1] //0	//nQtdPosto
			(cAlias)->QTD_AUSEFV:= aQuantidades[2] //0
			(cAlias)->QTD_ALOCA	:= aQuantidades[3] //0

		(cAlias)->(MsUnlock())
	
		dData++
		
		lRet := .t.

	End While

Return(lRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} UpdateTable
Atualiza a tabela temporária, que lista dia a dia com as qtdes de faltas e alocações,
com os dias que não há agenda, para o período escolhido pelo usuário data de/até

@sample 	UpdateTable(oTable,cQuery,cAlias,aIndex,aFields,lRemake)
@param		oTable, objeto, instância da classe FwTemporaryTable com a tabela do 
				resultado de dia a dia de alocação
			cQuery, string, query que irá ou criar ou atualizar os dados da tabela
				temporária
			aIndex, array, campos que irão indexar a tabela temporária
			aFields, array, estrutura dos campos que compõe a tabela temporária
			lRemake, boolean, .t. - recria a tabela temporária

@return 	Nenhum
@author 	Fernando Radu Muscalu
@since		05/10/2023
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function UpdateTable(oTable,cQuery,cAlias,aIndex,aFields)

	Local lRet		:= .F.
	Local lRemake 	:= Iif(ValType(oTable) == "U",.T.,.F.)

	Local nI		:= 0	
	
	//Monta o ResultSet que serrá jogada na temporarytable
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMP",.F.,.T.)
		
	For nI := 1 to len(aFields)
		TcSetField("TMP",aFields[nI][1],aFields[nI][2],aFields[nI][3],aFields[nI][4])
	Next nI

	If ( lRemake )

		oTable := FWTemporaryTable():New(cAlias)
		oTable:SetFields( aFields )
		oTable:AddIndex("INDEX1", aClone(aIndex) )
		oTable:Create()
	else
		oTable:Zap()
	EndIf

	TMP->(DbGotop())

		While ( TMP->(!EoF()) )

			Reclock(cAlias,.T.)

				For nI := 1 to Len(aFields)
					(cAlias)->&(aFields[nI,1]) := TMP->&(aFields[nI,1])
				Next nI

			(cAlias)->(MsUnlock())
			lRet := .T.
			TMP->(DbSkip())

		End While

	TMP->(DbCloseArea())

	(oTable:GetAlias())->(DbGoTop())

Return(lRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CreateTable
Cria a estrutura da tabela temporária das Agendas

@sample 	CreateTable(oTable, cAlias)
@param		oTable, objeto, instância da classe FwTemporaryTable 
			cAlias, string, alias da tabela temporária
@return 	Nenhum
@author 	Fernando Radu Muscalu
@since		11/10/2023
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function CreateTable(oTable, cAlias)

	Local aStruct	:= GetStruct()
	Local aIndex	:= {	"CONTRATO",;
							"REVISAO",;
							"LOCAL_ORC",;
							"POSTO",;
							"ESCALA",;
							"DT_AGENDA"}

	Default cAlias := GetNextAlias()

	If ( ValType(oTable) == "U" )
		oTable := FWTemporaryTable():New(cAlias)
		oTable:SetFields( aStruct )
		oTable:AddIndex("INDEX1", aClone(aIndex) )
		oTable:Create()
	Else
		oTable:Zap()
	EndIf

Return()

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetStruct
Monta estrutura da tabela temporária

@sample 	GetStruct()
@param					
@return 	Nenhum
@author 	Fernando Radu Muscalu
@since		11/10/2023
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function GetStruct()

	Local aTamQtd	:=  TamSX3("TFF_QTDVEN")
	Local aStruct	:= {}

	Aadd(aStruct, {"VIA_RESULT", "C", 1, 0})
	Aadd(aStruct, {"CONTRATO", 	"C", TamSx3("TFJ_CONTRT")[1], 0})
	Aadd(aStruct, {"REVISAO", 	"C", TamSx3("TFJ_CONREV")[1], 0})
	Aadd(aStruct, {"LOCAL_ORC", "C", TamSx3("TFL_LOCAL")[1], 0})
	Aadd(aStruct, {"LOCAL_DESC","C", TamSx3("ABS_DESCRI")[1], 0})
	Aadd(aStruct, {"POSTO", 	"C", TamSx3("TFF_COD")[1], 0})
	Aadd(aStruct, {"QTD_POSTO", "N", aTamQtd[1], aTamQtd[2]})
	Aadd(aStruct, {"ESCALA", 	"C", TamSx3("TGY_ESCALA")[1], 0})
	Aadd(aStruct, {"FUNCAO", 	"C", TamSx3("TFF_FUNCAO")[1], 0})
	Aadd(aStruct, {"DT_AGENDA", "D", 8, 0})
	Aadd(aStruct, {"QTD_FLTEFV","N", aTamQtd[1], aTamQtd[2]})
	Aadd(aStruct, {"QTD_AUSEFV","N", aTamQtd[1], aTamQtd[2]})
	Aadd(aStruct, {"QTD_ALOCA",	"N", aTamQtd[1], aTamQtd[2]})

Return(aStruct)
				
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Rt988GetAg
Busca as agendas da data para o posto, considerando a quantidade de postos vendidos

@sample Rt988GetAg(cData,cContrato,cLocal,cPosto,cEscala,nQtdPosto,cFilBusca)
@param	cData, string, Data da agenda
		cContrato, string, Código do Contrato
		cLocal, string, Código do Local de atendimento
		cPosto, string, Código do Posto de atendimento
		cEscala, string, Código da escala,
		nQtdPosto, numeric, quantidade de postos vendidos
		cFilBusca, string, Filial da busca das agendas.
@return 	Nenhum 
@author 	Fernando Radu Muscalu
@since		11/10/2023
/*/
//--------------------------------------------------------------------------------------------------------------------
Function Rt988GetAg(cData,cContrato,cLocal,cPosto,cEscala,nQtdPosto,cFilBusca,cCalend)
	Local cAlias      := GetNextAlias()
	Local cCodTec     := ""
	Local cTipoDia    := ""
	Local cQry        := ""
	Local cCodSubMty  := Space( FWSX3Util():GetFieldStruct( "ABR_CODSUB" )[3] )
	Local nDescoberto := 0
	Local nAusente    := 0
	Local nAlocado    := 0
	Local nOrder      := 1
	Local aQtdes      := Array(4)
	Local oQry        := Nil

	Default cFilBusca := XFilial("ABB")
	Default cCalend   := ""

	aFill(aQtdes,0)	

		cQry += "SELECT "
		cQry += "	DISTINCT "
		cQry += "	( "
		cQry += "		CASE WHEN  "
		cQry += "			A.ABR_CODSUB <> '?'  "
		cQry += "			AND A.STAT_ALOCA <> 'ALOCADO'  "
		cQry += "		THEN   "
		cQry += "			'ALOCADO'  "
		cQry += "		ELSE   "
		cQry += "			A.STAT_ALOCA  "
		cQry += "		END "
		cQry += "	) STAT_ALOCA, "
		cQry += "	A.ESCALA, "
		cQry += "	( "
		cQry += "		CASE WHEN  "
		cQry += "			A.ABR_CODSUB <> '?' "
		cQry += "		THEN   "
		cQry += "			A.ABR_CODSUB  "
		cQry += "		ELSE "
		cQry += "			A.ID_RECURSO "
		cQry += "		END "
		cQry += "	) ID_RECURSO "
		cQry += "FROM "
		cQry += "( "
		cQry += "	SELECT "
		cQry += "		( "
		cQry += "			CASE WHEN "
		cQry += "				COALESCE(ABR.ABR_DTINI, ' ') <> ' '  "
		cQry += "				AND COALESCE(ABN.ABN_TIPO, ' ') = '05' "
		cQry += "			THEN "
		cQry += "				'DESCOBERTO'  "
		cQry += "			WHEN "
		cQry += "				COALESCE(ABR.ABR_DTINI, ' ') <> ' '  "
		cQry += "				AND COALESCE(ABN.ABN_TIPO, ' ') = '01' "
		cQry += "			THEN "
		cQry += "				'AUSENTE'  "
		cQry += "			WHEN "
		cQry += "				ABB.ABB_ATIVO = '1' "
		cQry += "				OR (ABB.ABB_ATIVO = '2' AND ABR.ABR_CODSUB <> '?') "
		cQry += "			THEN "
		cQry += "				'ALOCADO' "
		cQry += "			END "
		cQry += "		) STAT_ALOCA,  "
		cQry += "		TGY.TGY_ESCALA ESCALA, "
		cQry += "		COALESCE(ABB.ABB_CODTEC, ABR.ABR_CODSUB) ID_RECURSO, "
		cQry += "		COALESCE(ABR.ABR_CODSUB, '?') ABR_CODSUB "
		cQry += "	FROM "
		cQry += "		? ABB "
		cQry += "	INNER JOIN "
		cQry += "		? ABQ "
		cQry += "	ON "
		cQry += "		ABQ.D_E_L_E_T_ = ' ' "
		cQry += "		AND ABQ.ABQ_FILIAL = ? "
		cQry += "		AND ABQ.ABQ_CONTRT = ? "
		cQry += "		AND ABQ.ABQ_CODTFF = ? "
		cQry += "		AND ABQ.ABQ_FILTFF = ABB.ABB_FILIAL "
		cQry += "		AND ABQ.ABQ_LOCAL  = ABB.ABB_LOCAL "
		cQry += "		AND ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM = ABB.ABB_IDCFAL "
		cQry += "	LEFT JOIN "
		cQry += "		? TGY   "
		cQry += "	ON "
		cQry += "		TGY.D_E_L_E_T_ = ' ' "
		cQry += "		AND TGY.TGY_FILIAL = ABB.ABB_FILIAL "
		cQry += "		AND ABB.ABB_CODTEC = TGY.TGY_ATEND "
		cQry += "		AND TGY.TGY_CODTFF = ABQ.ABQ_CODTFF "
		cQry += "		AND TGY.TGY_ESCALA = ? "
		cQry += "		AND TGY.TGY_ULTALO <> ' ' "
		cQry += "	LEFT JOIN  "
		cQry += "		? ABR  "
		cQry += "	ON  "
		cQry += "		ABR.D_E_L_E_T_ = ' '  "
		cQry += "		AND ABR.ABR_FILIAL = ABB.ABB_FILIAL  "
		cQry += "		AND ABR.ABR_AGENDA = ABB.ABB_CODIGO "
		cQry += "	LEFT JOIN  "
		cQry += "		? ABN "
		cQry += "	ON "
		cQry += "		ABN.D_E_L_E_T_ = ' ' "
		cQry += "		AND ABN.ABN_FILIAL = ? "
		cQry += "		AND ABN.ABN_CODIGO = ABR.ABR_MOTIVO "
		cQry += "		AND ABN.ABN_TIPO IN ('01','05') "
		cQry += "	WHERE "
		cQry += "		ABB.D_E_L_E_T_ = ' ' "
		cQry += "		AND ABB.ABB_FILIAL = ? "
		cQry += "		AND ABB.ABB_DTINI = ? "
		cQry += "		AND ABB.ABB_LOCAL = ? ) A "
		cQry += "WHERE "
		cQry += "	A.STAT_ALOCA <> ' ' "
		cQry += "ORDER BY  "
		cQry += "	ID_RECURSO "

	oQry := FwPreparedStatement():New( cQry )

	oQry:setNumeric( nOrder++, cCodSubMty )
	oQry:setNumeric( nOrder++, cCodSubMty )
	oQry:setNumeric( nOrder++, cCodSubMty )
	oQry:setNumeric( nOrder++, cCodSubMty )
	oQry:setNumeric( nOrder++, RetSqlName( "ABB" ) )
	oQry:setNumeric( nOrder++, RetSqlName( "ABQ" ) )
	oQry:setString( nOrder++, FwxFilial( "ABQ" ) )
	oQry:setString( nOrder++, cContrato )
	oQry:setString( nOrder++, cPosto )
	oQry:setNumeric( nOrder++, RetSqlName( "TGY" ) )
	oQry:setString( nOrder++, cEscala )
	oQry:setNumeric( nOrder++, RetSqlName( "ABR" ) )
	oQry:setNumeric( nOrder++, RetSqlName( "ABN" ) )
	oQry:setString( nOrder++, FwxFilial( "ABN" ) )
	oQry:setString( nOrder++, cFilBusca )
	oQry:setString( nOrder++, cData )
	oQry:setString( nOrder++, cLocal )

	cQry := ChangeQuery( oQry:GetFixQuery() )
	MPSysOpenQuery( cQry, cAlias )

	While ( (cAlias)->(!Eof()) )

		Do Case
			Case ( Alltrim((cAlias)->STAT_ALOCA) == 'AUSENTE' )
				nAusente++
			Case ( Alltrim((cAlias)->STAT_ALOCA) == 'ALOCADO' )
				nAlocado++
		End Case

		cCodTec := (cAlias)->ID_RECURSO

		(cAlias)->(DbSkip())

		If ( cCodTec <> (cAlias)->ID_RECURSO )
			//Se tem meia alocação, considera o dia alocado
			If ( nAlocado > 0  )

				nDescoberto := 0
				nAusente	:= 0

			EndIf

			aQtdes[2]	+= nAusente
			aQtdes[3]	+= nAlocado

			nDescoberto	:= 0
			nAusente	:= 0
			nAlocado	:= 0

		EndIf			

	End While 

	//Checa se há posto descoberto. Com isto, é necessário avaliar
	//se é um dia de folga
	If ( (nQtdPosto - (aQtdes[3]+aQtdes[2])) > 0 ) 

		cTipoDia := ChecaFolga(cEscala,cData,,cCalend)
		//Verifica se é uma data de folga, então trata-se como alocado, porque não deverá 
		//aparecer no relatório como posto descoberto
		If ( Alltrim(cTipoDia) == "FOLGA" .Or. Empty(cTipoDia) )
			aQtdes[3] := nQtdPosto
		EndIf

	EndIf

	//Para averiguar quantidades de descoberto, por falta de agenda
	//Qtd. Postos Descoberto = Qtd. Postos - (Qtd. Alocado + Qtd. Ausente)
	aQtdes[1] := nQtdPosto - (aQtdes[3]+aQtdes[2])

	(cAlias)->(DbCloseArea())
	oQry:Destroy()
	FwFreeObj( oQry )

Return(aQtdes)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ChecaFolga
Checa para o dia da semana, quando não encontrou agenda para o técnico, se há folga

@sample ChecaFolga(cEscala,cData,cFilBusca)
@param	cEscala, string, Código da escala,
		cData, string, Data da agenda
		cFilBusca, string, Filial da busca das agendas.
@return 	Nenhum 
@author 	Fernando Radu Muscalu
@since		11/10/2023
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ChecaFolga(cEscala,cData,cFilBusca,cCalend)

	Local cAlias		:= ""
	Local cQry			:= ""
	Local cDia			:= "0"
	Local cTipoDia		:= ""
	Local cSeqTurno		:= ""
	Local cRegra		:= "2-EXCECAO|3-FERIADO"
	Local dData			:= SToD("")
	Local lExFer		:= .F.
	Local oQry			:= Nil

	Default cFilBusca	:= XFilial("TDX")
	Default cCalend		:= ""

	dData  := SToD(cData)
	cDia   := cValToChar(DOW( dData ))

	// Verificar se considera excecao de Feriado Trabalhado
	lExFer := (TecHasPerg("MV_PAR11", "TECR988") .And. MV_PAR11 == 2)

	// 1. Dias da semana trabalhados

	cQry := "SELECT "
	cQry += " DISTINCT "
	cQry += " '1-PADRAO' REGRA, "
	cQry += " TDX.TDX_SEQTUR SEQ_TURNO, "
	cQry += " TGW.TGW_DIASEM DIA_SEM, "
	cQry += " ( "
	cQry += " 	CASE "
	cQry += " 		WHEN TGW.TGW_STATUS <> '2' THEN  "
	cQry += " 			'TRABALHADO' "
	cQry += " 		ELSE "
	cQry += " 			'FOLGA' "
	cQry += " 	END "
	cQry += " ) TIPO_DIA "
	cQry += " FROM ? TDX "

	// Config Escala
	cQry += " INNER JOIN ? TGW "
	cQry += "    ON TGW.TGW_FILIAL = TDX.TDX_FILIAL "
	cQry += "   AND TGW.TGW_EFETDX = TDX.TDX_COD "
	cQry += "   AND TGW.TGW_STATUS = '1' "
	cQry += "   AND TGW.TGW_DIASEM = ? "
	cQry += "   AND TGW.D_E_L_E_T_ = ' ' "

	// Escala
	cQry += " WHERE TDX.TDX_FILIAL = ? "
	cQry += "   AND TDX.TDX_CODTDW = ? "
	cQry += "   AND TDX.D_E_L_E_T_ = ' ' "

	// 2. Excecoes trabalhadas

	cQry += " UNION "

	cQry += " SELECT "
	cQry += " '2-EXCECAO' REGRA, "
	cQry += " TDX.TDX_SEQTUR SEQ_TURNO, "
	cQry += " TDY.TDY_DIASEM DIA_SEM, "
	cQry += " ( "
	cQry += " 	CASE "
	cQry += " 		WHEN TDY.TDY_HREXT = '2' "
	cQry += " 			OR (TDY.TDY_HREXT = '1' AND TDY.TDY_TRBFOL = '1') THEN "
	cQry += " 			'TRABALHADO' "
	cQry += " 		ELSE "
	cQry += " 			'FOLGA' "
	cQry += " 	END "
	cQry += " ) TIPO_DIA "
	cQry += " FROM ? TDX "

	// Excecoes Feriado
	cQry += " INNER JOIN ? TDY "
	cQry += "    ON TDY.TDY_FILIAL = TDX.TDX_FILIAL "
	cQry += "   AND TDY.TDY_CODTDX = TDX.TDX_COD "
	cQry += "   AND TDY.TDY_DIASEM = ? "
	cQry += "   AND TDY.TDY_FERIAD = '2' "
	cQry += "   AND TDY.D_E_L_E_T_ = ' ' "

	// Escala
	cQry += " WHERE TDX.TDX_FILIAL = ? "
	cQry += "   AND TDX.TDX_CODTDW = ? "
	cQry += "   AND TDX.D_E_L_E_T_ = ' ' "

	// 3. Verifica feriados trabalhados (se existe excecao para trabalhado)

	cQry += " UNION "

	cQry += " SELECT "
	cQry += " DISTINCT "
	cQry += " '3-FERIADO' REGRA, "
	cQry += " COALESCE(TDX.TDX_SEQTUR,' ') SEQ_TURNO, "
	cQry += " COALESCE(TDY.TDY_DIASEM,?) DIA_SEM, "
	cQry += " ( "
	cQry += " 	CASE "
	cQry += " 		WHEN	COALESCE(TDY.TDY_HREXT, ' ') = '2' "
	cQry += " 			OR (COALESCE(TDY.TDY_HREXT, ' ') = '1' AND COALESCE(TDY.TDY_TRBFOL,' ') = '1') "
	cQry += " 		THEN "
	cQry += " 			'TRABALHADO' "
	cQry += " 		ELSE "
	cQry += " 			'FOLGA' "
	cQry += " 	END "
	cQry += " ) TIPO_DIA "

	// Feriados
	cQry += " FROM ? AC0 "
	cQry += " INNER JOIN ? RR0 "
	cQry += "    ON RR0.RR0_FILIAL = AC0.AC0_FILIAL "
	cQry += "   AND RR0.RR0_CODCAL = AC0.AC0_CODIGO "
	cQry += " AND ( RR0.RR0_DATA = ? OR "
	cQry += "     ( RR0.RR0_MESDIA = ? AND RR0.RR0_FIXO = 'S' ))"
	cQry += "   AND RR0.D_E_L_E_T_ = ' ' "

	// Escala
	cQry += " INNER JOIN ? TDX "
	cQry += "    ON TDX.TDX_FILIAL = ? "
	cQry += "   AND TDX.TDX_CODTDW = ? "
	cQry += "   AND TDX.D_E_L_E_T_ = ' ' "

	// Excecoes Feriado
	cQry += " LEFT JOIN ? TDY "
	cQry += "    ON TDY.TDY_FILIAL = TDX.TDX_FILIAL "
	cQry += "   AND TDY.TDY_CODTDX = TDX.TDX_COD "
	cQry += "   AND TDY.TDY_DIASEM = ? "
	cQry += "   AND TDY.TDY_FERIAD = '1' "
	cQry += "   AND TDY.D_E_L_E_T_ = ' ' "

	cQry += " WHERE AC0.AC0_FILIAL = ? "
	cQry += "   AND AC0.AC0_CODIGO = ? "
	cQry += "   AND AC0.D_E_L_E_T_ = ' ' "

	cQry += " ORDER BY 1, 2, 3"

	oQry := FwPreparedStatement():New( cQry )

	// 1. Dias da semana trabalhados

	oQry:setNumeric(  1, RetSqlName( "TDX" ) )
	// Config Escala
	oQry:setNumeric(  2, RetSqlName( "TGW" ) )
	oQry:setString(   3, cDia )

	// Escala
	oQry:setString(   4, cFilBusca )
	oQry:setString(   5, cEscala )

	// 2. Excecoes trabalhadas

	// Excecoes Feriado
	oQry:setNumeric(  6, RetSqlName( "TDX" ) )
	oQry:setNumeric(  7, RetSqlName( "TDY" ) )
	oQry:setString(   8, cDia )

	// Escala
	oQry:setString(   9, cFilBusca )
	oQry:setString(  10, cEscala )

	// 3. Verifica feriados trabalhados

	// Feriados
	oQry:setString(  11, cDia )
	oQry:setNumeric( 12, RetSqlName( "AC0" ) )
	oQry:setNumeric( 13, RetSqlName( "RR0" ) )
	oQry:setString(  14, cData )
	oQry:setString(  15, MesDia(dData) )

	// Escala
	oQry:setNumeric( 16, RetSqlName( "TDX" ) )
	oQry:setString(  17, cFilBusca )
	oQry:setString(  18, cEscala )

	// Excecoes Feriado
	oQry:setNumeric( 19, RetSqlName( "TDY" ) )
	oQry:setString(  20, cDia )
	oQry:setString(  21, xFilial("AC0") )
	oQry:setString(  22, cCalend )

	cQry := oQry:GetFixQuery()
	cQry := ChangeQuery(cQry)
	cAlias := MPSysOpenQuery(cQry)

	//Varre a escala conforme as sequências existentes para o dia 
	//da semana informado na query
	While ( (cAlias)->(!Eof()) )

		If !(lExFer .And. (cAlias)->REGRA=="3-FERIADO" .And. (cAlias)->TIPO_DIA=="TRABALHADO")

			If Empty(cTipoDia)
				cTipoDia  := (cAlias)->TIPO_DIA
				cSeqTurno := (cAlias)->SEQ_TURNO
			Else
				//Excecao ou Feriado - sobreescreve regra anterior
				If (cAlias)->SEQ_TURNO == cSeqTurno .And. (cAlias)->REGRA $ cRegra
					cTipoDia := (cAlias)->TIPO_DIA
					Exit
				EndIf
			EndIf
		EndIf

		(cAlias)->(DbSkip())

	End While

	(cAlias)->(DbCloseArea())
	oQry:Destroy()
	FwFreeObj( oQry )

Return(cTipoDia)
