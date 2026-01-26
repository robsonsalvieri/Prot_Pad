#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "PCPA152.CH"
#INCLUDE "PCPA152DEFS.CH"

#DEFINE IND_ATEMPO_DISPONIVEL 1
#DEFINE IND_ATEMPO_PARADO     2
#DEFINE IND_ATEMPO_EXTRA      3
#DEFINE IND_ATEMPO_EFETIVADA  4
#DEFINE IND_ATEMPO_BLOQUEADO  5
#DEFINE IND_ATEMPO_TOTAL      6
#DEFINE IND_ATEMPO_TAMANHO    6

Static _nTamMKSeq := GetSX3Cache("MK_SEQ", "X3_TAMANHO")
Static _lCampoAlt := GetSX3Cache("MR_ALTDISP", "X3_TAMANHO") > 0

/*/{Protheus.doc} PCPA152MANDIS
API Para manipulação dos dados da disponibilidade (SMR e SMK)

@type  WSCLASS
@author lucas.franca
@since 28/02/2023
@version P12
/*/
WSRESTFUL PCPA152MANDIS DESCRIPTION "PCPA152MANDIS" FORMAT APPLICATION_JSON
	WSDATA Page                AS INTEGER OPTIONAL
	WSDATA PageSize            AS INTEGER OPTIONAL
	WSDATA qtdRegistroExcluido AS INTEGER OPTIONAL
	WSDATA programacao         AS STRING  OPTIONAL
	WSDATA idDisponibilidade   AS STRING  OPTIONAL
	WSDATA dataInicial         AS STRING  OPTIONAL
	WSDATA dataFinal           AS STRING  OPTIONAL
	WSDATA recurso             AS STRING  OPTIONAL
	WSDATA centroTrabalho      AS STRING  OPTIONAL
	WSDATA retornaCT           AS BOOLEAN OPTIONAL

	WSMETHOD GET DISP;
		DESCRIPTION STR0110; //"Retorna a disponibilidade dos recursos"
		WSSYNTAX "/api/pcp/v1/pcpa152mandis/disponibilidade/{programacao}" ;
		PATH "/api/pcp/v1/pcpa152mandis/disponibilidade/{programacao}" ;
		TTALK "v1"

	WSMETHOD DELETE DISP;
		DESCRIPTION STR0111; //"Exclui a disponibilidade de um recurso em uma data"
		WSSYNTAX "/api/pcp/v1/pcpa152mandis/disponibilidade/{programacao}/{idDisponibilidade}" ;
		PATH "/api/pcp/v1/pcpa152mandis/disponibilidade/{programacao}/{idDisponibilidade}" ;
		TTALK "v1"

	WSMETHOD POST ADDDISP;
		DESCRIPTION STR0112; //"Inclui a disponibilidade de um recurso em uma data"
		WSSYNTAX "/api/pcp/v1/pcpa152mandis/disponibilidade/{programacao}" ;
		PATH "/api/pcp/v1/pcpa152mandis/disponibilidade/{programacao}" ;
		TTALK "v1"

	WSMETHOD POST UPDDISP;
		DESCRIPTION STR0113; //"Altera a disponibilidade de um recurso em uma data"
		WSSYNTAX "/api/pcp/v1/pcpa152mandis/disponibilidade/{programacao}/{idDisponibilidade}" ;
		PATH "/api/pcp/v1/pcpa152mandis/disponibilidade/{programacao}/{idDisponibilidade}" ;
		TTALK "v1"

	WSMETHOD GET RECURSOS;
		DESCRIPTION STR0216; //"Retorna os centros de trabalho com disponibilidade"
		WSSYNTAX "/api/pcp/v1/pcpa152mandis/recursos/{programacao}" ;
		PATH "/api/pcp/v1/pcpa152mandis/recursos/{programacao}" ;
		TTALK "v1"

	WSMETHOD POST VLDMULTI;
		DESCRIPTION STR0321; //"Valida se a alteração em lote conflitará acom alguma disponibilidade"
		WSSYNTAX "/api/pcp/v1/pcpa152mandis/dispemlote/valid/{programacao}" ;
		PATH "/api/pcp/v1/pcpa152mandis/dispemlote/valid/{programacao}" ;
		TTALK "v1"

	WSMETHOD POST UPDMULTI;
		DESCRIPTION STR0322; //"Altera a disponibilidade de recursos e datas em lotes"
		WSSYNTAX "/api/pcp/v1/pcpa152mandis/dispemlote/{programacao}" ;
		PATH "/api/pcp/v1/pcpa152mandis/dispemlote/{programacao}" ;
		TTALK "v1"

ENDWSRESTFUL

/*/{Protheus.doc} GET DISP /api/pcp/v1/pcpa152mandis/disponibilidade/{programacao}
Retorna a disponibilidade dos recursos

@type  WSMETHOD
@author lucas.franca
@since 28/02/2023
@version P12
@return lReturn, Logic, Identifica se processou corretamente os dados
/*/
WSMETHOD GET DISP PATHPARAM programacao QUERYPARAM Page, PageSize, qtdRegistroExcluido, dataInicial, dataFinal, recurso WSSERVICE PCPA152MANDIS
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152ManDis"), Break(oError)})
	Local lReturn   := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := getDisp(Self:programacao, Self:Page, Self:PageSize, Self:qtdRegistroExcluido, Self:dataInicial, Self:dataFinal, Self:recurso)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lReturn

/*/{Protheus.doc} getDisp
Busca os dados de disponibilidade

@type  Static Function
@author lucas.franca
@since 28/02/2023
@version P12
@param 01 cProg     , Caracter, Código da programação
@param 02 nPage     , Numeric , Página para consulta
@param 03 nPageSize , Numeric , Tamanho da página
@param 04 nQtdRegDel, Numeric , Quantidade de registros excluídos para considerar na paginação
@param 05 cDataIni  , Caracter, Data inicial para filtro dos dados
@param 06 cDataFim  , Caracter, Data final para filtro dos dados
@param 07 cRecurso  , Caracter, Código do recurso para filtro dos dados
@param 08 cIdDisp   , Caracter, ID da disponibilidade
@return aReturn, Array, Array com os dados de retorno da API
/*/
Static Function getDisp(cProg, nPage, nPageSize, nQtdRegDel, cDataIni, cDataFim, cRecurso, cIdDisp)
	Local aReturn   := {.T., 200, ""}
	Local cAlias    := getNextAlias()
	Local cChavePos := ""
	Local cFields   := ""
	Local cFrom     := ""
	Local cWhere    := ""
	Local cOrder    := ""
	Local nPos      := 0
	Local oJsRet    := JsonObject():New()
	Local oJsPos    := JsonObject():New()
	Local oJsDet    := Nil

	Default nPage      := 1
	Default nPageSize  := 20
	Default nQtdRegDel := 0
	Default cIdDisp    := ""

	cFields += /*SELECT*/"SMR.MR_DATDISP,"
	cFields +=          " SMR.MR_TEMPODI,"
	cFields +=          " SMR.MR_TEMPOBL,"
	cFields +=          " SMR.MR_TEMPOPA,"
	cFields +=          " SMR.MR_TEMPOEX,"
	cFields +=          " SMR.MR_TEMPOEF,"
	cFields +=          " SMR.MR_TEMPOTO,"
	cFields +=          " SMR.MR_DISP,"
	cFields +=          " SMK.MK_SEQ,"
	cFields +=          " SMK.MK_HRINI,"
	cFields +=          " SMK.MK_HRFIM,"
	cFields +=          " SMK.MK_TIPO,"
	cFields +=          " SMK.MK_BLOQUE,"
	cFields +=          " T4X.T4X_STATUS"
	cFrom :=     /*FROM*/ RetSqlName("SMR") + " SMR"
	cFrom +=      " INNER JOIN " + RetSqlName("SMK") + " SMK"
	cFrom +=         " ON SMK.MK_FILIAL  = '" + xFilial("SMK") + "'"
	cFrom +=        " AND SMK.MK_PROG    = SMR.MR_PROG"
	cFrom +=        " AND SMK.MK_DISP    = SMR.MR_DISP"
	cFrom +=        " AND SMK.D_E_L_E_T_ = ' '"
	cFrom +=      " INNER JOIN " + RetSqlName("T4X") + " T4X"
	cFrom +=         " ON T4X.T4X_FILIAL = '" + xFilial("T4X") + "'"
	cFrom +=        " AND T4X.T4X_PROG   = SMR.MR_PROG"
	cFrom +=        " AND T4X.D_E_L_E_T_ = ' '"
	cWhere := /*WHERE*/ " SMR.MR_FILIAL  = '" + xFilial("SMR")  + "'"
	cWhere +=       " AND SMR.MR_PROG    = '" + cProg           + "'"
	cWhere +=       " AND SMR.MR_TIPO    = '" + MR_TIPO_RECURSO + "'"
	cWhere +=       " AND SMR.MR_DATDISP <= '" + getDataLim(cProg) + "' "
	If _lCampoAlt
		cWhere +=   " AND SMR.MR_ALTDISP != '" + DELETOU_DISPONIBILIDADE + "'"
	EndIf
	cWhere +=       " AND SMR.D_E_L_E_T_ = ' '"

	If !Empty(cRecurso)
		cWhere +=   " AND SMR.MR_RECURSO IN " + inFilt(cRecurso)
	EndIf

	If !Empty(cDataIni)
		cWhere +=   " AND SMR.MR_DATDISP >= '" + StrTran(cDataIni, "-", "") + "'"
	EndIf

	If !Empty(cDataFim)
		cWhere +=   " AND SMR.MR_DATDISP <= '" + StrTran(cDataFim, "-", "") + "'"
	EndIf

	If !Empty(cIdDisp)
		cWhere +=   " AND SMR.MR_DISP = '" + cIdDisp + "'"
	EndIf

	cOrder += /*ORDER BY*/" SMR.MR_DATDISP, SMK.MK_SEQ"

	cFields := "%" + cFields + "%"
	cFrom   := "%" + cFrom   + "%"
	cWhere  := "%" + cWhere  + "%"
	cOrder  := "%" + cOrder  + "%"

	BeginSql Alias cAlias
		SELECT %Exp:cFields%
		  FROM %Exp:cFrom%
		 WHERE %Exp:cWhere%
		 ORDER BY %Exp:cOrder%
	EndSql

	If nPage > 1
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			nStart := qtdRegDisp(nStart, nQtdRegDel, cFrom, cWhere)
			(cAlias)->(dbSkip(nStart))
		EndIf
	EndIf

	oJsRet["items"] := {}
	While (cAlias)->(!Eof())
		cChavePos := (cAlias)->MR_DISP

		If oJsPos:HasProperty(cChavePos)
			nPos := oJsPos[cChavePos]
		Else
			aAdd(oJsRet["items"], JsonObject():New())
			nPos := Len(oJsRet["items"])

			//Verifica tamanho da página
			If nPos > nPageSize
				aSize(oJsRet["items"], nPos-1) //Remove último array que foi adicionado
				Exit
			EndIf

			oJsPos[cChavePos] := nPos

			oJsRet["items"][nPos]["idDisponibilidade"  ] := (cAlias)->MR_DISP
			oJsRet["items"][nPos]["dataDisponibilidade"] := PCPConvDat((cAlias)->MR_DATDISP, 4)
			oJsRet["items"][nPos]["horaDisponivel"     ] := __Min2Hrs((cAlias)->MR_TEMPODI, .T.)
			oJsRet["items"][nPos]["horaBloqueada"      ] := __Min2Hrs((cAlias)->MR_TEMPOBL, .T.)
			oJsRet["items"][nPos]["horaParada"         ] := __Min2Hrs((cAlias)->MR_TEMPOPA, .T.)
			oJsRet["items"][nPos]["horaExtra"          ] := __Min2Hrs((cAlias)->MR_TEMPOEX, .T.)
			oJsRet["items"][nPos]["horaEfetivada"      ] := __Min2Hrs((cAlias)->MR_TEMPOEF, .T.)
			oJsRet["items"][nPos]["horaTotal"          ] := __Min2Hrs((cAlias)->MR_TEMPOTO, .T.)
			oJsRet["items"][nPos]["detail"             ] := {}
			If (cAlias)->T4X_STATUS != STATUS_EFETIVADO
				oJsRet["items"][nPos]["actions"] := {"editar","excluir"}
			EndIf
		EndIf

		oJsDet := JsonObject():New()
		oJsDet["sequencia"         ] := Val((cAlias)->MK_SEQ)
		oJsDet["horaInicial"       ] := (cAlias)->MK_HRINI
		oJsDet["horaFinal"         ] := (cAlias)->MK_HRFIM
		oJsDet["tipo"              ] := (cAlias)->MK_TIPO
		oJsDet["tipoDescricao"     ] := PCPA152Disponibilidade():descricaoTipoHora((cAlias)->MK_TIPO)
		oJsDet["bloqueado"         ] := (cAlias)->MK_BLOQUE
		oJsDet["bloqueadoDescricao"] := Iif((cAlias)->MK_BLOQUE=="1",STR0050,STR0049) //"Sim" # "Não"

		aAdd(oJsRet["items"][nPos]["detail"], oJsDet)
		oJsDet := Nil

		(cAlias)->(dbSkip())
	End

	//Verifica se existem mais dados para retornar
	oJsRet["hasNext"] := (cAlias)->(!Eof())
	(cAlias)->(dbCloseArea())

	If nPos > 0
		aReturn[1] := .T.
		aReturn[2] := 200
		aReturn[3] := oJsRet:toJson()
	Else
		oJsRet["_messages"] := {JsonObject():New()}
		oJsRet["_messages"][1]["code"           ] := "404"
		oJsRet["_messages"][1]["message"        ] := STR0114 //"Não existem dados de disponibilidade que atendam aos filtros informados."
		oJsRet["_messages"][1]["detailedMessage"] := ""

		aReturn[3] := oJsRet:toJson()
	EndIf

	aSize(oJsRet["items"], 0)
	FreeObj(oJsRet)
	FreeObj(oJsPos)

Return aReturn

/*/{Protheus.doc} inFilt
Monta a condição de IN para filtro em query com base na string separada por ,

@type  Static Function
@author lucas.franca
@since 19/06/2023
@version P12
@param 01 cFiltro, Caracter, String de filtro com os itens separados por ,
@param 02 aFiltro, Array   , Array com os valores a serem filtrados
@return cInQuery, Caracter, String formatada para adicionar no filtro de IN da query.
/*/
Static Function inFilt(cFiltro, aFiltro)
	Local cInQuery := ""
	Local nIndex   := 0
	Local nTotal   := 0
	Default aFiltro := StrToKArr2(cFiltro, ",", .T.)

	nTotal   := Len(aFiltro)
	cInQuery += "("
	For nIndex := 1 To nTotal
		If Empty(aFiltro[nIndex]) .Or. aFiltro[nIndex] == "' '"
			aFiltro[nIndex] := " "
		EndIf
		cInQuery += "'" + aFiltro[nIndex] + "'"

		If nIndex != nTotal
			cInQuery += ", "
		EndIf
	Next
	cInQuery += ")"

	If !Empty(cFiltro)
		aSize(aFiltro, 0)
	EndIf

Return cInQuery

/*/{Protheus.doc} qtdRegDisp
Verifica qual é o registro correto para paginação dos dados, considerando o agrupamento
dos registros que é realizado por RECURSO + DATA.

@type  Static Function
@author lucas.franca
@since 01/03/2023
@version P12
@param 01 nStart    , Numeric , Posição para início dos dados agrupados
@param 02 nQtdRegDel, Numeric , Quantidade de registros excluídos para considerar na paginação
@oaram 03 cFrom     , Caracter, Condição "FROM" da query de busca dos dados
@oaram 04 cWhere    , Caracter, Condição "WHERE" da query de busca dos dados
@return nStart, Numeric, Nova posição para busca dos dados, sem o agrupamento
/*/
Static Function qtdRegDisp(nStart, nQtdRegDel, cFrom, cWhere)
	Local cAlias := GetNextAlias()
	Local cQuery := ""
	Local cBanco := TcGetDb()

	//Remove os caracteres % de controle do BeginSql, do início e do fim de cFrom e cWhere
	cFrom  := AllTrim(cFrom)
	cFrom  := Right(cFrom, Len(cFrom)-1)
	cFrom  := Left(cFrom, Len(cFrom)-1)
	cWhere := AllTrim(cWhere)
	cWhere := Right(cWhere, Len(cWhere)-1)
	cWhere := Left(cWhere, Len(cWhere)-1)

	cQuery := "SELECT SUM(TMP.TOTAL) AS TOTAL"
	If "MSSQL" $ cBanco
		cQuery += " FROM (SELECT TOP " + cValToChar(nStart)
	Else
		cQuery += " FROM (SELECT "
	EndIf
	cQuery +=          " SMR.MR_RECURSO, SMR.MR_DATDISP, COUNT(*) TOTAL"
	cQuery +=     " FROM " + cFrom
	cQuery +=    " WHERE " + cWhere
	cQuery +=    " GROUP BY SMR.MR_DATDISP, SMR.MR_RECURSO"
	cQuery +=    " ORDER BY SMR.MR_RECURSO, SMR.MR_DATDISP"

	If cBanco == "POSTGRES"
		cQuery += " LIMIT " + cValToChar( nStart )
	EndIf
	cQuery += ") TMP"

	If cBanco == "ORACLE"
		cQuery += " WHERE ROWNUM <= " + cValToChar( nStart )
	EndIf

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)
	If (cAlias)->TOTAL > nStart
		nStart := (cAlias)->TOTAL
	EndIf
	(cAlias)->(dbCloseArea())

	nStart -= nQtdRegDel
Return nStart

/*/{Protheus.doc} GET CT /api/pcp/v1/pcpa152mandis/recursos/{programacao}
Retorna a disponibilidade dos recursos

@type  WSMETHOD
@author lucas.franca
@since 14/06/2023
@version P12
@return lReturn, Logic, Identifica se processou corretamente os dados
/*/
WSMETHOD GET RECURSOS PATHPARAM programacao QUERYPARAM dataInicial, dataFinal, recurso, centroTrabalho, retornaCT WSSERVICE PCPA152MANDIS
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152ManDis"), Break(oError)})
	Local lReturn   := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := getRecursos(Self:programacao, Self:recurso, Self:centroTrabalho, Self:retornaCT)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lReturn

/*/{Protheus.doc} getRecursos
Faz a busca dos recursos e centros de trabalho que possuem disponibilidade

@type Static Function
@author lucas.franca
@since 14/06/2023
@version P12
@param 01 cProg     , Caracter, Código da programação
@param 02 cRecurso  , Caracter, Código do recurso para filtro dos dados
@param 03 cCentroTr , Caracter, Centro de trabalho para filtro dos dados
@param 04 lRetornaCT, Logic   , Indica se deve ser retornado o Centro de Trabalho
@return aReturn, Array, Array com os dados de retorno da API
/*/
Static Function getRecursos(cProg, cRecurso, cCentroTr, lRetornaCT)
	Local aReturn := {.T., 200, ""}
	Local cAlias  := GetNextAlias()
	Local cCTAnt  := ""
	Local cCodCT  := ""
	Local cCodRec := ""
	Local cDesCT  := ""
	Local cDesRec := ""
	Local cQuery  := ""
	Local nPos    := 0
	Local nPosCT  := 0
	Local oJsRecs := Nil
	Local oJsRet  := JsonObject():New()

	cQuery := "SELECT DISTINCT SMT.MT_RECURSO, SH1.H1_DESCRI"

	If lRetornaCT
		cQuery +=  ", SMT.MT_CTRAB, SHB.HB_NOME"
	EndIf

	cQuery +=  " FROM " + RetSqlName("SMT") + " SMT"
	cQuery +=  " LEFT JOIN " + RetSqlName("SH1") + " SH1"
	cQuery +=    " ON SH1.H1_FILIAL  = '" + xFilial("SH1") + "'"
	cQuery +=   " AND SH1.H1_CODIGO  = SMT.MT_RECURSO"
	cQuery +=   " AND SH1.D_E_L_E_T_ = ' '"

	If lRetornaCT
		cQuery += " LEFT JOIN " + RetSqlName("SHB") + " SHB"
		cQuery +=   " ON SHB.HB_FILIAL  = '" + xFilial("SHB") + "'"
		cQuery +=  " AND SHB.HB_COD     = SMT.MT_CTRAB"
		cQuery +=  " AND SHB.D_E_L_E_T_ = ' '"
	EndIf

	cQuery += " WHERE SMT.MT_FILIAL  = '" + xFilial("SMT") + "'"
	cQuery +=   " AND SMT.MT_PROG    = '" + cProg + "'"
	cQuery +=   " AND SMT.D_E_L_E_T_ = ' '"

	If !Empty(cRecurso)
		cQuery += " AND SMT.MT_RECURSO IN " + inFilt(cRecurso)
	EndIf

	If !Empty(cCentroTr)
		cQuery += " AND SMT.MT_CTRAB IN " + inFilt(cCentroTr)
	EndIf

	If lRetornaCT
		cQuery += " ORDER BY SMT.MT_CTRAB, SMT.MT_RECURSO"
	Else
		cQuery += " ORDER BY SMT.MT_RECURSO"
	EndIf

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)

	oJsRet["items"] := {}
	oJsRecs := oJsRet["items"]

	While (cAlias)->(!Eof())
		nPos++
		If lRetornaCT
			cCodCT := RTrim((cAlias)->MT_CTRAB)
			cDesCT := " - " + RTrim((cAlias)->HB_NOME)
			If Empty(cCodCT)
				cDesCT := STR0217 //"Centro de trabalho não definido"
			EndIf

			//Mudou o Centro de Trabalho
			If nPos == 1 .Or. cCTAnt <> (cAlias)->MT_CTRAB
				cCTAnt := (cAlias)->MT_CTRAB //utiliza (cAlias)->MT_CTRAB e não a variável cCodCT pois o RTrim pode causar erro nas comparações.
				nPos   := 1
				nPosCT++
				aAdd(oJsRet["items"], JsonObject():New())
				oJsRet["items"][nPosCT]["node"     ] := cCodCT + cDesCT
				oJsRet["items"][nPosCT]["codigo"   ] := cCodCT
				oJsRet["items"][nPosCT]["id"       ] := cCodCT
				oJsRet["items"][nPosCT]["recursos" ] := {}
				oJsRecs := oJsRet["items"][nPosCT]["recursos"]
			EndIf
		EndIf

		cCodRec := RTrim((cAlias)->MT_RECURSO)
		cDesRec := RTrim((cAlias)->H1_DESCRI)

		aAdd(oJsRecs, JsonObject():New())
		oJsRecs[nPos]["node"     ] := cCodRec + " - " + cDesRec
		oJsRecs[nPos]["codigo"   ] := cCodRec
		oJsRecs[nPos]["descricao"] := cDesRec
		oJsRecs[nPos]["id"       ] := cCodCT + "|" + cCodRec

		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())

	If nPos > 0
		aReturn[1] := .T.
		aReturn[2] := 200
		aReturn[3] := oJsRet:toJson()
	Else
		oJsRet["_messages"] := {JsonObject():New()}
		oJsRet["_messages"][1]["code"           ] := "404"
		oJsRet["_messages"][1]["message"        ] := STR0114 //"Não existem dados de disponibilidade que atendam aos filtros informados."
		oJsRet["_messages"][1]["detailedMessage"] := ""

		aReturn[3] := oJsRet:toJson()
	EndIf

	aSize(oJsRet["items"], 0)
	FreeObj(oJsRet)
	FreeObj(oJsRecs)

Return aReturn

/*/{Protheus.doc} DELETE DISP /api/pcp/v1/pcpa152mandis/disponibilidade/{programacao}/{idDisponibilidade}
Exclui a disponibilidade de um recurso

@type  WSMETHOD
@author lucas.franca
@since 28/02/2023
@version P12
@return lReturn, Logic, Identifica se processou corretamente os dados
/*/
WSMETHOD DELETE DISP PATHPARAM programacao, idDisponibilidade WSSERVICE PCPA152MANDIS
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152ManDis"), Break(oError)})
	Local lReturn   := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := delDisp(Self:programacao, Self:idDisponibilidade)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lReturn

/*/{Protheus.doc} delDisp
Faz a exclusão de uma disponibilidade

@type  Static Function
@author lucas.franca
@since 02/03/2023
@version P12
@param 01 cProg  , Caracter, Código da programação
@param 02 cIdDisp, Caracter, Código da disponibilidade
@return aReturn, Array, Array com os dados de retorno da API
/*/
Static Function delDisp(cProg, cIdDisp)
	Local aReturn  := {.T., 200, ""}
	Local cChaveMK := ""

	cProg   := PadR(cProg  , GetSX3Cache("MR_PROG", "X3_TAMANHO"))
	cIdDisp := PadR(cIdDisp, GetSX3Cache("MR_DISP", "X3_TAMANHO"))

	SMR->(dbSetOrder(1))
	If SMR->(dbSeek(xFilial("SMR") + cProg + cIdDisp))
		cChaveMK := xFilial("SMK") + cProg + cIdDisp
		BEGIN TRANSACTION

			//Deleta os registros da SMK
			deletaSMK(cChaveMK)

			//Deleta a SMR
			RecLock("SMR", .F.)
				If _lCampoAlt
					SMR->MR_TEMPODI := 0
					SMR->MR_TEMPOBL := 0
					SMR->MR_TEMPOPA := 0
					SMR->MR_TEMPOEX := 0
					SMR->MR_TEMPOEF := 0
					SMR->MR_TEMPOTO := 0
					SMR->MR_ALTDISP := DELETOU_DISPONIBILIDADE
				Else
					SMR->(dbDelete())
				EndIf
			SMR->(MsUnLock())

			PCPA152Process():atualizaPendenciaDeReprocessamento(cProg, REPROCESSAMENTO_PENDENTE)

		END TRANSACTION
	EndIf
Return aReturn

/*/{Protheus.doc} deletaSMK
Percorre a SMK e deleta os registros.

@type  Static Function
@author lucas.franca
@since 09/03/2023
@version P12
@param cChave, Caracter, Chave da tabela SMK para exclusão
@return Nil
/*/
Static Function deletaSMK(cChave)
	SMK->(dbSetOrder(1))
	While SMK->(dbSeek(cChave))
		RecLock("SMK", .F.)
			SMK->(dbDelete())
		SMK->(MsUnLock())
	End
Return Nil

/*/{Protheus.doc} POST UPDDISP /api/pcp/v1/pcpa152mandis/disponibilidade/{programacao}/{idDisponibilidade}
Altera a disponibilidade de um recurso em uma data.

@type  WSMETHOD
@author lucas.franca
@since 09/03/2023
@version P12
@return lReturn, Logic, Identifica se processou corretamente os dados
/*/
WSMETHOD POST UPDDISP PATHPARAM programacao, idDisponibilidade WSSERVICE PCPA152MANDIS
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152ManDis"), Break(oError)})
	Local lReturn   := .T.
	Local oBody     := JsonObject():New()

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		oBody:FromJson(Self:getContent())

		aReturn := updDisp(Self:programacao, Self:idDisponibilidade, oBody)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

	FreeObj(oBody)

Return lReturn

/*/{Protheus.doc} POST ADDDISP /api/pcp/v1/pcpa152mandis/disponibilidade/{programacao}
Adiciona a disponibilidade de um recurso em uma data.

@type  WSMETHOD
@author lucas.franca
@since 09/03/2023
@version P12
@return lReturn, Logic, Identifica se processou corretamente os dados
/*/
WSMETHOD POST ADDDISP PATHPARAM programacao WSSERVICE PCPA152MANDIS
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152ManDis"), Break(oError)})
	Local lReturn   := .T.
	Local oBody     := JsonObject():New()

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		oBody:FromJson(Self:getContent())

		aReturn := updDisp(Self:programacao, "", oBody)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

	FreeObj(oBody)

Return lReturn

/*/{Protheus.doc} updDisp
Faz a alteração dos registros da disponibilidade

@type  Static Function
@author lucas.franca
@since 09/03/2023
@version P12
@param 01 cProg  , Caracter  , Código da programação
@param 02 cIdDisp, Caracter  , ID da disponibilidade
@param 03 oDados , JsonObject, JSON com os dados recebidos para alteração
@return aReturn, Array, Array com os dados do processamento para retorno do rest
/*/
Static Function updDisp(cProg, cIdDisp, oDados)
	Local aReturn   := {.T., 200, ""}
	Local cAlias    := ""
	Local cFilSMK   := xFilial("SMK")
	Local cFilSMR   := ""
	Local lInclui   := Empty(cIdDisp)
	Local lContinua := .T.
	Local nTamDisp  := GetSX3Cache("MR_DISP", "X3_TAMANHO")
	Local nIndex    := 0
	Local nTotal    := Len(oDados["detalhes"])

	cProg   := PadR(cProg  , GetSX3Cache("MR_PROG", "X3_TAMANHO"))
	cIdDisp := PadR(cIdDisp, nTamDisp)

	ajustaTipo(oDados)

	If lInclui
		//Valida se os dados para inclusão estão corretos
		lContinua := validaInc(@aReturn, oDados, cProg, @lInclui, @cIdDisp)
		SMT->(dbSetOrder(1))
	EndIf

	SMR->(dbSetOrder(1))
	If lContinua .And. (lInclui .Or. SMR->(dbSeek(xFilial("SMR") + cProg + cIdDisp)))

		If lInclui
			cFilSMR    := xFilial("SMR")
			cIdDisp    := StrZero(0, nTamDisp)
			_cChavLock := "PCPA152_RESERVA_NOVO_IDDISP" + cProg

			//Faz lock para evitar gerar um ID duplicado
			While !lockByName(_cChavLock, .T., .F.)
				nIndex++
				If nIndex > 500
					_cChavLock := Nil
					aReturn[1] := .F.
					aReturn[2] := 500
					aReturn[3] := STR0115 //"Não foi possível gerar um novo ID para a inclusão da disponibilidade."
					Return aReturn
				EndIf
				Sleep(100)
			End

			//Busca última sequencia
			cAlias := GetNextAlias()
			BeginSql Alias cAlias
				SELECT MAX(SMR.MR_DISP) DISP
				  FROM %Table:SMR% SMR
				 WHERE SMR.MR_FILIAL = %Exp:cFilSMR%
				   AND SMR.MR_PROG   = %Exp:cProg%
				   AND SMR.%NotDel%
			EndSql
			If !Empty((cAlias)->(DISP))
				cIdDisp := (cAlias)->(DISP)
			EndIf
			(cAlias)->(dbCloseArea())

			cIdDisp := Soma1(cIdDisp)
		EndIf

		BEGIN TRANSACTION
			//Atualiza os totalizadores da SMR ou inclui o registro
			RecLock("SMR", lInclui)
				If lInclui
					SMR->MR_FILIAL  := xFilial("SMR")
					SMR->MR_PROG    := cProg
					SMR->MR_DISP    := cIdDisp
					SMR->MR_RECURSO := oDados["recurso"]
					SMR->MR_DATDISP := oDados["data"]
					SMR->MR_TIPO    := "1"
					SMR->MR_SITUACA := "1"
				EndIf

				SMR->MR_TEMPODI := __Hrs2Min(oDados["horaDisponivel"])
				SMR->MR_TEMPOBL := __Hrs2Min(oDados["horaBloqueada" ])
				SMR->MR_TEMPOPA := __Hrs2Min(oDados["horaParada"    ])
				SMR->MR_TEMPOEX := __Hrs2Min(oDados["horaExtra"     ])
				SMR->MR_TEMPOEF := __Hrs2Min(oDados["horaEfetivada" ])
				SMR->MR_TEMPOTO := __Hrs2Min(oDados["horaTotal"     ])
				If _lCampoAlt
					SMR->MR_ALTDISP := ALTEROU_DISPONIBILIDADE
				EndIf
			SMR->(MsUnLock())

			//Se for alteração, irá deletar os dados da SMK e inserir novamente.
			If lInclui == .F.
				deletaSMK(cFilSMK + cProg + cIdDisp)
			EndIf

			For nIndex := 1 To nTotal
				RecLock("SMK", .T.)
					SMK->MK_FILIAL  := cFilSMK
					SMK->MK_PROG    := cProg
					SMK->MK_DISP    := cIdDisp
					SMK->MK_DATDISP := SMR->MR_DATDISP
					SMK->MK_SEQ     := oDados["detalhes"][nIndex]["sequencia"  ]
					SMK->MK_HRINI   := oDados["detalhes"][nIndex]["horaInicial"]
					SMK->MK_HRFIM   := oDados["detalhes"][nIndex]["horaFinal"  ]
					SMK->MK_TIPO    := oDados["detalhes"][nIndex]["tipo"       ]
					SMK->MK_BLOQUE  := oDados["detalhes"][nIndex]["bloqueado"  ]
				SMK->(MsUnLock())
			Next nIndex

			If lInclui
				//Verifica necessidade de registrar tabela de CT x Recurso.
				If SMT->(dbSeek(xFilial("SMT") + cProg + oDados["recurso"] + oDados["centroTrab"])) == .F.
					RecLock("SMT", .T.)
						SMT->MT_FILIAL  := xFilial("SMT")
						SMT->MT_PROG    := cProg
						SMT->MT_CTRAB   := oDados["centroTrab"]
						SMT->MT_RECURSO := oDados["recurso"]
					SMT->(MsUnLock())
				EndIf
			EndIf

			PCPA152Process():atualizaPendenciaDeReprocessamento(cProg, REPROCESSAMENTO_PENDENTE)

		END TRANSACTION

		If lInclui
			unlockByName(_cChavLock, .T., .F.)
		EndIf

		//Recupera os dados do banco e monta o retorno para a API
		aReturn := getDisp(cProg, 1, 1, 0, Nil, Nil, Nil, cIdDisp)
	EndIf

Return aReturn

/*/{Protheus.doc} validaInc
Faz a validação dos dados para uma nova inclusão

@type  Static Function
@author lucas.franca
@since 14/03/2023
@version P12
@param 01 aReturn, Array   , Array para retorno da API em caso de erro
@param 02 oDados , Object  , Json recebido na API com os dados para inclusão
@param 03 cProg  , Caracter, Código da programação
@param 04 lInclui, Lógico  , Atualiza por referência a variavel de inclusão, caso haja o registro deletado na SMR.
@param 05 cIdDisp, Lógico  , Retorna por referência o id da disponibilidade que deve ser atualizado.
@return lRet, Logic, Indica se os dados estão válidos
/*/
Static Function validaInc(aReturn, oDados, cProg, lInclui, cIdDisp)
	Local cAlias  := GetNextAlias()
	Local cParam  := ""
	Local cData   := ""
	Local cRec    := ""
	Local cCampo  := ""
	Local lRet    := .T.
	Local oParam  := JsonObject():New()

	//Busca os parâmetros da T4Y para validação
	BeginSql Alias cAlias
		SELECT T4Y.T4Y_PARAM, T4Y.T4Y_VALOR, T4Y.T4Y_LISTA
		  FROM %Table:T4Y% T4Y
		 WHERE T4Y.T4Y_FILIAL = %xFilial:T4Y%
		   AND T4Y.T4Y_PROG   = %Exp:cProg%
		   AND T4Y.T4Y_PARAM IN ('dataInicial','dataFinal','dataRealFim')
		   AND T4Y.%NotDel%
	EndSql

	While (cAlias)->(!Eof())
		cParam := Trim((cAlias)->(T4Y_PARAM))
		oParam[cParam] := PCPConvDat(Trim( (cAlias)->T4Y_VALOR ), 1)
		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())

	If oParam:hasProperty("dataRealFim") .And. oParam["dataRealFim"] > oParam["dataFinal"]
		oParam["dataFinal"] := oParam["dataRealFim"]
	EndIf

	If oParam['dataInicial'] > oDados['data'] .Or. oParam['dataFinal'] < oDados['data']
		lRet       := .F.
		aReturn[2] := 400
		aReturn[3] := I18N(STR0116, {PCPConvDat( DtoS(oParam['dataInicial']), 4 ),PCPConvDat( DtoS(oParam['dataFinal']), 4 )})//"Data da disponibilidade deve estar dentro do período de processamento da programação. Início: #1[DATAINI]# Fim: #2[DATAFIM]#"
	EndIf

	If lRet
		cData := DtoS(oDados['data'])
		cRec  := oDados["recurso"]

		cCampo := "%" + Iif(_lCampoAlt, "MR_ALTDISP, MR_DISP", "1") + "%"

		BeginSql Alias cAlias
			SELECT %Exp:cCampo%
			  FROM %Table:SMR%
			 WHERE MR_FILIAL  = %xFilial:SMR%
			   AND MR_PROG    = %Exp:cProg%
			   AND MR_RECURSO = %Exp:cRec%
			   AND MR_DATDISP = %Exp:cData%
			   AND %NotDel%
		EndSql

		If (cAlias)->(!Eof())
			If _lCampoAlt .And. (cAlias)->MR_ALTDISP == DELETOU_DISPONIBILIDADE
				lInclui := .F.
				cIdDisp := (cAlias)->MR_DISP
			Else
				lRet       := .F.
				aReturn[2] := 400
				aReturn[3] := I18N(STR0118, {Trim(cRec), PCPConvDat(cData, 4)})//"Já existe disponibilidade para o recurso #1[RECURSO]# no dia #2[DATA]#. Utilize a opção de Alteração para manipular a disponibilidade."
			EndIf
		EndIf
		(cAlias)->(dbCloseArea())
	EndIf

	aReturn[1] := lRet
	FreeObj(oParam)
Return lRet

/*/{Protheus.doc} ajustaTipo
Ajusta o json com os tipos corretos para inserir/alterar a disponibilidade.
@type  Static Function
@author Lucas Fagundes
@since 22/09/2023
@version P12
@param oDados, Object, Json enviado pelo front para alterar/incluir uma disponibilidade. Retorna por referencia o json com os tipos ajustados.
@return Nil
/*/
Static Function ajustaTipo(oDados)
	Local nIndex   := 0
	Local nTamCT   := GetSX3Cache("MT_CTRAB", "X3_TAMANHO")
	Local nTamDets := Len(oDados["detalhes"])
	Local nTamRec  := GetSX3Cache("H1_CODIGO", "X3_TAMANHO")

	oDados["data"      ] := PCPConvDat(oDados["data"], 1)
	oDados["recurso"   ] := PadR(oDados["recurso"], nTamRec)
	oDados["centroTrab"] := PadR(oDados["centroTrab"], nTamCT)

	For nIndex := 1 To nTamDets
		oDados["detalhes"][nIndex]["sequencia"] := StrZero(oDados["detalhes"][nIndex]["sequencia"], _nTamMKSeq)
	Next

Return Nil

/*/{Protheus.doc} POST VLDMULTI /api/pcp/v1/pcpa152mandis/dispemlote/valid/{programacao}
Valida se a alteração em lote conflitará com alguma disponibilidade existente

@type WSMETHOD
@author marcelo.neumann
@since 20/09/2023
@version P12
@return lReturn, Lógico, Identifica se processou corretamente os dados
/*/
WSMETHOD POST VLDMULTI PATHPARAM programacao WSSERVICE PCPA152MANDIS
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152ManDis"), Break(oError)})
	Local lReturn   := .T.
	Local oBody     := JsonObject():New()

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		oBody:FromJson(Self:getContent())

		aReturn := vldMulti(Self:programacao, oBody, .T.)

		If aReturn[1]
			aReturn := vldMulti(Self:programacao, oBody,  .F.)
		EndIf
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

	FreeObj(oBody)

Return lReturn

/*/{Protheus.doc} vldMulti
Valida se a alteração em lote conflitará com alguma disponibilidade existente

@type Static Function
@author marcelo.neumann
@since 20/09/2023
@version P12
@param 01 cProg    , Caracter, Código da programação
@param 02 oDados   , Objeto  , JSON com os dados recebidos para alteração
@param 03 lEfetivas, Lógico  , Indica se a validação deve ser só de horas Efetivadas ou de todas
@return aReturn    , Array   , Array com os dados do processamento para retorno do rest
/*/
Static Function vldMulti(cProg, oDados, lEfetivas)
	Local aReturn   := {.T., 200, ""}
	Local cAlias    := ""
	Local cDataFim  := StrTran(oDados["dataFinal"], "-", "")
	Local cDataIni  := StrTran(oDados["dataInicial"], "-", "")
	Local cHoraFim  := ""
	Local cHoraIni  := ""
	Local cQuery    := ""
 	Local nIndex    := 1
	Local nTotal    := Len(oDados["detalhes"])
	Local oQuery    := Nil

	cProg  := PadR(cProg, GetSX3Cache("MR_PROG", "X3_TAMANHO"))

	cQuery := "SELECT SMR.MR_RECURSO"
	cQuery +=  " FROM " + RetSqlName("SMR") + " SMR"
	cQuery += " INNER JOIN " + RetSqlName("SMK") + " SMK"
	cQuery +=    " ON SMK.MK_FILIAL  = '" + xFilial("SMK") + "'"
	cQuery +=   " AND SMK.MK_PROG    = SMR.MR_PROG"
	cQuery +=   " AND SMK.MK_DATDISP = SMR.MR_DATDISP"
	cQuery +=   " AND SMK.MK_DISP    = SMR.MR_DISP"
	cQuery +=   " AND SMK.D_E_L_E_T_ = ' '"
    cQuery +=   " AND (( SMK.MK_HRINI >= ? AND SMK.MK_HRINI <  ? ) OR" // ? = 1-Início | 2-Fim
    cQuery +=        " ( SMK.MK_HRFIM >  ? AND SMK.MK_HRFIM <= ? ) OR" // ? = 3-Início | 4-Fim
    cQuery +=        " ( SMK.MK_HRINI <  ? AND SMK.MK_HRFIM >  ? ) OR" // ? = 5-Início | 6-Início
    cQuery +=        " ( SMK.MK_HRINI <  ? AND SMK.MK_HRFIM >  ? ))"   // ? = 7-Fim    | 8-Fim
	cQuery += " WHERE SMR.MR_FILIAL  = '" + xFilial("SMR")  + "'"
	cQuery +=   " AND SMR.MR_PROG    = '" + cProg           + "'"
	cQuery +=   " AND SMR.MR_TIPO    = '" + MR_TIPO_RECURSO + "'"
	cQuery +=   " AND SMR.MR_RECURSO IN " + inFilt( , oDados["recursos"])
	cQuery +=   " AND SMR.MR_DATDISP BETWEEN '" + cDataIni + "' AND '" + cDataFim + "'"
	cQuery +=   " AND SMR.D_E_L_E_T_ = ' '"

	If lEfetivas
		cQuery += " AND SMK.MK_TIPO = '4'"
	EndIf

	oQuery := FwExecStatement():New()
	oQuery:setQuery(cQuery)

	While nIndex <= nTotal
		cHoraIni := oDados["detalhes"][nIndex]["horaInicial"]
		cHoraFim := oDados["detalhes"][nIndex]["horaFinal"]

		oQuery:setString(1, cHoraIni) //MK_HRINI
		oQuery:setString(2, cHoraFim) //MK_HRINI
		oQuery:setString(3, cHoraIni) //MK_HRFIM
		oQuery:setString(4, cHoraFim) //MK_HRFIM
		oQuery:setString(5, cHoraIni) //MK_HRINI
		oQuery:setString(6, cHoraIni) //MK_HRFIM
		oQuery:setString(7, cHoraFim) //MK_HRINI
		oQuery:setString(8, cHoraFim) //MK_HRFIM

		cAlias := oQuery:OpenAlias()
		If (cAlias)->(!EoF())
			If lEfetivas
				aReturn[1] := .F.
				aReturn[2] := 404
				aReturn[3] := I18N(STR0363, {AllTrim((cAlias)->MR_RECURSO)}) //"Existem intervalos efetivados no recurso #1[RECURSO]# que não podem ser alterados."
			Else
				aReturn[1] := .T.
				aReturn[2] := 404
				aReturn[3] := ""
			EndIf
			(cAlias)->(dbCloseArea())
			Exit
		EndIf
		nIndex++
		(cAlias)->(dbCloseArea())
	End

	oQuery:destroy()

Return aReturn

/*/{Protheus.doc} POST UPDMULTI /api/pcp/v1/pcpa152mandis/dispemlote/{programacao}
Altera a disponibilidade de recursos e datas em lote

@type WSMETHOD
@author marcelo.neumann
@since 30/08/2023
@version P12
@return lReturn, Lógico, Identifica se processou corretamente os dados
/*/
WSMETHOD POST UPDMULTI PATHPARAM programacao WSSERVICE PCPA152MANDIS
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152ManDis"), Break(oError)})
	Local lReturn   := .T.
	Local oBody     := JsonObject():New()

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		oBody:FromJson(Self:getContent())

		BEGIN TRANSACTION
			aReturn := P152UpdMul(Self:programacao, oBody)
		END TRANSACTION
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

	FreeObj(oBody)

Return lReturn

/*/{Protheus.doc} P152UpdMul
Altera a disponibilidade de recursos e datas em lote

@type Function
@author marcelo.neumann
@since 30/08/2023
@version P12
@param 01 cProg , Caracter, Código da programação
@param 02 oDados, Objeto  , JSON com os dados recebidos para alteração
@return aReturn , Array   , Array com os dados do processamento para retorno do rest
/*/
Function P152UpdMul(cProg, oDados)
	Local aInsSMK    := {}
	Local aAddBulk   := {}
	Local aReturn    := {.T., 200, ""}
	Local aTempos    := {}
	Local cAliasSMR  := GetNextAlias()
	Local cChave     := ""
	Local cDataFim   := StrTran(oDados["dataFinal"], "-", "")
	Local cDataIni   := StrTran(oDados["dataInicial"], "-", "")
	Local cErro      := ""
	Local cFilSMK    := xFilial("SMK")
	Local cFilSMR    := xFilial("SMR")
	Local cSequencia := "000"
	Local cQryOrder  := ""
	Local cQrySelect := ""
	Local cQryWhere  := ""
	Local cQuery     := ""
	Local lMudouSMK  := .T.
	Local lSucesso   := .T.
	Local nIndDet    := 0
	Local nIndex     := 0
	Local nTotal     := Len(oDados["detalhes"])
	Local oAlteradas := JsonObject():New()
	Local oBulkSMK   := Nil
	Local oDispSMK   := JsonObject():New()
	Local oNovaDisp  := Nil

	SMK->(dbSetOrder(1))

	cProg := PadR(cProg, GetSX3Cache("MR_PROG", "X3_TAMANHO"))

	If !oDados:hasProperty("tipo")
		oDados["tipo"         ] := MR_TIPO_RECURSO
		oDados["seqFerramenta"] := ""
	EndIf

	//Busca os registros que serão alterados
	cQrySelect :=  "SELECT MR_DISP, MR_RECURSO, MR_DATDISP, MR_TEMPODI, MR_TEMPOBL, MR_TEMPOPA, MR_TEMPOEX, MR_TEMPOEF, MR_TEMPOTO, R_E_C_N_O_ RECNO, MR_TIPO
	cQrySelect +=   " FROM " + RetSqlName("SMR")
	cQryWhere  :=  " WHERE MR_FILIAL = '" + cFilSMR + "'"
	cQryWhere  +=    " AND MR_PROG = '"   + cProg   + "'"
	cQryWhere  +=    " AND MR_RECURSO IN " + inFilt( , oDados["recursos"])
	cQryWhere  +=    " AND MR_DATDISP BETWEEN '" + cDataIni + "' AND '" + cDataFim + "'"
 	cQryWhere  +=    " AND MR_TIPO = '" + oDados["tipo"] + "'"
	cQryWhere  +=    " AND D_E_L_E_T_ = ' '"
	If oDados["tipo"] == MR_TIPO_FERRAMENTA
		cQryWhere += " AND MR_SEQFER = '" + oDados["seqFerramenta"] + "'"
	EndIf
	cQryOrder  :=  " ORDER BY MR_RECURSO, MR_DATDISP"
	cQuery     := cQrySelect + cQryWhere + cQryOrder

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAliasSMR, .F., .F.)

	//Prepara objeto de inclusão dos novos intervalos
	oBulkSMK := FwBulk():New()
	oBulkSMK:setTable(RetSqlName("SMK"))
	oBulkSMK:setFields(PCPA152Disponibilidade():estruturaTabela("SMK"))

	While (cAliasSMR)->(!EoF())
		oAlteradas[(cAliasSMR)->MR_RECURSO + "_" + (cAliasSMR)->MR_DATDISP] := .T.
		iniTempos(@aTempos)

		cSequencia := StrZero(1, _nTamMKSeq)
		lMudouSMK  := .T.
		nIndDet    := 1
		oNovaDisp  := oDados["detalhes"][nIndDet]
		cChave     := cFilSMK + cProg + (cAliasSMR)->MR_DISP

		SMK->(dbSeek(cChave))

		While SMK->(!EoF()) .And. SMK->MK_FILIAL + SMK->MK_PROG + SMK->MK_DISP == cChave
			If lMudouSMK
				oDispSMK["MK_HRINI"] := SMK->MK_HRINI
				oDispSMK["MK_HRFIM"] := SMK->MK_HRFIM
				lMudouSMK            := .F.
			EndIf

			//A disponibilidade termina antes da nova (não fará nada)
			//  | SMK |
			//          |   NOVA    |
			If nIndDet > nTotal .Or. oDispSMK["MK_HRFIM"] <= oNovaDisp["horaInicial"]
				aInsSMK                   := Array(ARRAY_MK_TAMANHO)
				aInsSMK[ARRAY_MK_FILIAL ] := cFilSMK
				aInsSMK[ARRAY_MK_PROG   ] := cProg
				aInsSMK[ARRAY_MK_DISP   ] := (cAliasSMR)->MR_DISP
				aInsSMK[ARRAY_MK_SEQ    ] := cSequencia
				aInsSMK[ARRAY_MK_DATDISP] := (cAliasSMR)->MR_DATDISP
				aInsSMK[ARRAY_MK_HRINI  ] := oDispSMK["MK_HRINI"]
				aInsSMK[ARRAY_MK_HRFIM  ] := oDispSMK["MK_HRFIM"]
				aInsSMK[ARRAY_MK_TIPO   ] := SMK->MK_TIPO
				aInsSMK[ARRAY_MK_BLOQUE ] := SMK->MK_BLOQUE

				calcTempo(@aTempos, aInsSMK[ARRAY_MK_HRINI], aInsSMK[ARRAY_MK_HRFIM], aInsSMK[ARRAY_MK_TIPO], aInsSMK[ARRAY_MK_BLOQUE])

				aAdd(aAddBulk, aInsSMK)
				cSequencia := Soma1(cSequencia)
				lMudouSMK  := .T.
				SMK->(dbSkip())
				Loop
			EndIf

			//A disponibilidade inicia antes mas termina dentro ou depois do novo intervalo (será encerrada antes)
			//  |  SMK  |
			//  |  SMK           |
			//    |   NOVA    |
			If oDispSMK["MK_HRINI"] < oNovaDisp["horaInicial"]
				aInsSMK                   := Array(ARRAY_MK_TAMANHO)
				aInsSMK[ARRAY_MK_FILIAL ] := cFilSMK
				aInsSMK[ARRAY_MK_PROG   ] := cProg
				aInsSMK[ARRAY_MK_DISP   ] := (cAliasSMR)->MR_DISP
				aInsSMK[ARRAY_MK_SEQ    ] := cSequencia
				aInsSMK[ARRAY_MK_DATDISP] := (cAliasSMR)->MR_DATDISP
				aInsSMK[ARRAY_MK_HRINI  ] := oDispSMK["MK_HRINI"]
				aInsSMK[ARRAY_MK_HRFIM  ] := oNovaDisp["horaInicial"]
				aInsSMK[ARRAY_MK_TIPO   ] := SMK->MK_TIPO
				aInsSMK[ARRAY_MK_BLOQUE ] := SMK->MK_BLOQUE

				calcTempo(@aTempos, aInsSMK[ARRAY_MK_HRINI], aInsSMK[ARRAY_MK_HRFIM], aInsSMK[ARRAY_MK_TIPO], aInsSMK[ARRAY_MK_BLOQUE])

				aAdd(aAddBulk, aInsSMK)
				cSequencia := Soma1(cSequencia)

				If oDispSMK["MK_HRFIM"] <= oNovaDisp["horaFinal"]
					SMK->(dbSkip())
					lMudouSMK := .T.
					Loop
				EndIf
			EndIf

			//A disponibilidade está contida no novo intervalo (será excluída)
			//       | SMK |
			//    |   NOVA    |
			If oDispSMK["MK_HRINI"] >= oNovaDisp["horaInicial"] .And. ;
			   oDispSMK["MK_HRFIM"] <= oNovaDisp["horaFinal"  ]

				SMK->(dbSkip())
				lMudouSMK := .T.
				Loop
			EndIf

			//Insere o novo intervalo (ferramenta não insere disponibilidade)
			If oDados["tipo"] == MR_TIPO_RECURSO
				aInsSMK                   := Array(ARRAY_MK_TAMANHO)
				aInsSMK[ARRAY_MK_FILIAL ] := cFilSMK
				aInsSMK[ARRAY_MK_PROG   ] := cProg
				aInsSMK[ARRAY_MK_DISP   ] := (cAliasSMR)->MR_DISP
				aInsSMK[ARRAY_MK_SEQ    ] := cSequencia
				aInsSMK[ARRAY_MK_DATDISP] := (cAliasSMR)->MR_DATDISP
				aInsSMK[ARRAY_MK_HRINI  ] := oNovaDisp["horaInicial"]
				aInsSMK[ARRAY_MK_HRFIM  ] := oNovaDisp["horaFinal"  ]
				aInsSMK[ARRAY_MK_TIPO   ] := oNovaDisp["tipo"       ]
				aInsSMK[ARRAY_MK_BLOQUE ] := oNovaDisp["bloqueado"  ]

				calcTempo(@aTempos, aInsSMK[ARRAY_MK_HRINI], aInsSMK[ARRAY_MK_HRFIM], aInsSMK[ARRAY_MK_TIPO], aInsSMK[ARRAY_MK_BLOQUE])

				aAdd(aAddBulk, aInsSMK)
				cSequencia := Soma1(cSequencia)
			EndIf
			nIndDet++

			//A disponibilidade inicia antes ou dentro e termina depois do novo intervalo (será iniciada depois)
			//  |  SMK           |
			//           |  SMK  |
			//    |   NOVA   |
			If oDispSMK["MK_HRINI"] < oNovaDisp["horaFinal"] .And. ;
			   oDispSMK["MK_HRFIM"] > oNovaDisp["horaFinal"]

				If nIndDet > nTotal
					aInsSMK                   := Array(ARRAY_MK_TAMANHO)
					aInsSMK[ARRAY_MK_FILIAL ] := cFilSMK
					aInsSMK[ARRAY_MK_PROG   ] := cProg
					aInsSMK[ARRAY_MK_DISP   ] := (cAliasSMR)->MR_DISP
					aInsSMK[ARRAY_MK_SEQ    ] := cSequencia
					aInsSMK[ARRAY_MK_DATDISP] := (cAliasSMR)->MR_DATDISP
					aInsSMK[ARRAY_MK_HRINI  ] := oNovaDisp["horaFinal"]
					aInsSMK[ARRAY_MK_HRFIM  ] := oDispSMK["MK_HRFIM"]
					aInsSMK[ARRAY_MK_TIPO   ] := SMK->MK_TIPO
					aInsSMK[ARRAY_MK_BLOQUE ] := SMK->MK_BLOQUE

					calcTempo(@aTempos, aInsSMK[ARRAY_MK_HRINI], aInsSMK[ARRAY_MK_HRFIM], aInsSMK[ARRAY_MK_TIPO], aInsSMK[ARRAY_MK_BLOQUE])

					aAdd(aAddBulk, aInsSMK)
					cSequencia := Soma1(cSequencia)
					lMudouSMK  := .T.
					SMK->(dbSkip())
					Loop
				Else
					oDispSMK["MK_HRINI"] := oNovaDisp["horaFinal"]
				EndIf
			EndIf

			//A disponibilidade inicia depois da nova (só será inserida se não houver mais intervalo a ser validado)
			//                 |  SMK  |
			//    |   NOVA   |
			If oDispSMK["MK_HRINI"] > oNovaDisp["horaFinal"] .And. nIndDet > nTotal
				aInsSMK                   := Array(ARRAY_MK_TAMANHO)
				aInsSMK[ARRAY_MK_FILIAL ] := cFilSMK
				aInsSMK[ARRAY_MK_PROG   ] := cProg
				aInsSMK[ARRAY_MK_DISP   ] := (cAliasSMR)->MR_DISP
				aInsSMK[ARRAY_MK_SEQ    ] := cSequencia
				aInsSMK[ARRAY_MK_DATDISP] := (cAliasSMR)->MR_DATDISP
				aInsSMK[ARRAY_MK_HRINI  ] := oDispSMK["MK_HRINI"]
				aInsSMK[ARRAY_MK_HRFIM  ] := oDispSMK["MK_HRFIM"]
				aInsSMK[ARRAY_MK_TIPO   ] := SMK->MK_TIPO
				aInsSMK[ARRAY_MK_BLOQUE ] := SMK->MK_BLOQUE

				calcTempo(@aTempos, aInsSMK[ARRAY_MK_HRINI], aInsSMK[ARRAY_MK_HRFIM], aInsSMK[ARRAY_MK_TIPO], aInsSMK[ARRAY_MK_BLOQUE])

				aAdd(aAddBulk, aInsSMK)
				cSequencia := Soma1(cSequencia)
				SMK->(dbSkip())
				lMudouSMK := .T.
			EndIf

			If nIndDet <= nTotal
				oNovaDisp := oDados["detalhes"][nIndDet]
			EndIf
		End

		//Insere os novos intervalos que não foram inseridos anteriormente (iniciam após o último existente)
		For nIndex := nIndDet To nTotal
			//Ferramenta só insere quando há alguma indisponibilidade
			If oDados["tipo"] == MR_TIPO_FERRAMENTA .And. ;
			   oDados["detalhes"][nIndex]["tipo"     ] == HORA_DISPONIVEL .And. ;
			   oDados["detalhes"][nIndex]["bloqueado"] == HORA_NAO_BLOQUEADA
				Loop
			EndIf

			aInsSMK                   := Array(ARRAY_MK_TAMANHO)
			aInsSMK[ARRAY_MK_FILIAL ] := cFilSMK
			aInsSMK[ARRAY_MK_PROG   ] := cProg
			aInsSMK[ARRAY_MK_DISP   ] := (cAliasSMR)->MR_DISP
			aInsSMK[ARRAY_MK_SEQ    ] := cSequencia
			aInsSMK[ARRAY_MK_DATDISP] := (cAliasSMR)->MR_DATDISP
			aInsSMK[ARRAY_MK_HRINI  ] := oDados["detalhes"][nIndex]["horaInicial"]
			aInsSMK[ARRAY_MK_HRFIM  ] := oDados["detalhes"][nIndex]["horaFinal"  ]
			aInsSMK[ARRAY_MK_TIPO   ] := oDados["detalhes"][nIndex]["tipo"       ]
			aInsSMK[ARRAY_MK_BLOQUE ] := oDados["detalhes"][nIndex]["bloqueado"  ]

			calcTempo(@aTempos, aInsSMK[ARRAY_MK_HRINI], aInsSMK[ARRAY_MK_HRFIM], aInsSMK[ARRAY_MK_TIPO], aInsSMK[ARRAY_MK_BLOQUE])

			aAdd(aAddBulk, aInsSMK)
			cSequencia := Soma1(cSequencia)
		Next nIndex

		//Ajusta o totalizador da SMR
		SMR->(dbGoTo((cAliasSMR)->RECNO))
		If SMR->(Recno()) == (cAliasSMR)->RECNO
			RecLock("SMR", .F.)
				SMR->MR_TEMPODI := aTempos[IND_ATEMPO_DISPONIVEL]
				SMR->MR_TEMPOPA := aTempos[IND_ATEMPO_PARADO    ]
				SMR->MR_TEMPOEX := aTempos[IND_ATEMPO_EXTRA     ]
				SMR->MR_TEMPOEF := aTempos[IND_ATEMPO_EFETIVADA ]
				SMR->MR_TEMPOBL := aTempos[IND_ATEMPO_BLOQUEADO ]
				SMR->MR_TEMPOTO := aTempos[IND_ATEMPO_TOTAL     ]
			SMR->(MsUnLock())

			aSize(aTempos, 0)
		EndIf
		(cAliasSMR)->(dbSkip())
	End
	(cAliasSMR)->(dbCloseArea())

	//Apaga as disponibilidades encontradas
	If Val(cSequencia) > 0
		cQuery := "UPDATE " + RetSqlName("SMK")
		cQuery +=   " SET D_E_L_E_T_ = '*',"
		cQuery +=       " R_E_C_D_E_L_ = R_E_C_N_O_"
		cQuery += " WHERE MK_FILIAL  = '" + cFilSMR + "'"
		cQuery +=   " AND MK_PROG    = '" + cProg   + "'"
		cQuery +=   " AND MK_DATDISP BETWEEN '" + cDataIni + "' AND '" + cDataFim + "'"
		cQuery +=   " AND MK_DISP IN (SELECT MR_DISP"
		cQuery +=                     " FROM " + RetSqlName("SMR")
		cQuery +=                   /* WHERE */ cQryWhere + ")"
		cQuery +=   " AND D_E_L_E_T_ = ' '"

		If TCSQLExec(cQuery) < 0
			cErro := TcSqlError()
			lSucesso := .F.
		EndIf

		If lSucesso
			nTotal := Len(aAddBulk)
			For nIndex := 1 To nTotal
				If !oBulkSMK:addData(aAddBulk[nIndex])
					lSucesso := .F.
					Exit
				EndIf
			Next nIndex
		EndIf
		aSize(aAddBulk, 0)
	EndIf

	//Se for ferramenta e não houver hora parada, extra, bloqueada ou efetivada, deleta a SMR
	If lSucesso .And. oDados["tipo"] == MR_TIPO_FERRAMENTA
		cQuery := "UPDATE " + RetSqlName("SMR")
		cQuery +=   " SET D_E_L_E_T_ = '*',"
		cQuery +=       " R_E_C_D_E_L_ = R_E_C_N_O_"
		cQuery += /*WHERE*/ cQryWhere
		cQuery +=   " AND MR_TEMPOPA = 0"
		cQuery +=   " AND MR_TEMPOEX = 0"
		cQuery +=   " AND MR_TEMPOEF = 0"
		cQuery +=   " AND MR_TEMPOBL = 0"

		If TCSQLExec(cQuery) < 0
			cErro := TcSqlError()
			lSucesso := .F.
		EndIf
	EndIf

	If lSucesso .And. oDados["criaDisp"]
		lSucesso := criaDisp(cProg, oDados, oAlteradas, @oBulkSMK)
	EndIf

	If lSucesso
		lSucesso := oBulkSMK:close()
	EndIf

	If lSucesso
		PCPA152Process():atualizaPendenciaDeReprocessamento(cProg, REPROCESSAMENTO_PENDENTE)
	Else
		//Se deu erro, grava a mensagem de erro.
		aReturn[1] := .F.
		aReturn[2] := 500
		aReturn[3] := cErro

		If Empty(aReturn[3])
			aReturn[3] := oBulkSMK:GetError()
		EndIf

		DisarmTransaction()
		aSize(aInsSMK, 0)
	EndIf

	If oBulkSMK <> Nil
		oBulkSMK:destroy()
		FwFreeObj(oBulkSMK)
	EndIf

	If oNovaDisp <> Nil
		FreeObj(oNovaDisp)
	EndIf

	FreeObj(oAlteradas)
	FreeObj(oDispSMK)

Return aReturn

/*/{Protheus.doc} calcTempo
Calcula o tempo total (SMR) conforme o tipo e bloqueio de hora.

@type Static Function
@author marcelo.neumann
@since 30/08/2023
@version P12
@param 01 aTempos   , Array   , Array com os tempos totais para gravar na SMR
@param 02 cHoraIni  , Caracter, Horário inicial para calcular o tempo total de horas
@param 03 cHoraFim  , Caracter, Horário final para calcular o tempo total de horas
@param 04 nTipo     , Numérico, Indicador do tipo de hora: 1 - Disponível
                                                           2 - Parado
                                                           3 - Extra
                                                           4 - Efetivada
@param 05 nBloqueada, Numérico, Indica se é um horário bloqueado: 1 - Sim
                                                                  2 - Não
@return Nil
/*/
Static Function calcTempo(aTempos, cHoraIni, cHoraFim, nTipo, nBloqueada)
	Local nQtdMinut := __Hrs2Min(cHoraFim) - __Hrs2Min(cHoraIni)
/*
	Total Disponiveis = Horas Disponíveis + Horas Paradas
	Total Bloqueadas  = Horas Extras Bloqueadas + Horas Disponíveis Bloqueadas
	Total Paradas     = Horas Paradas (inclui Bloqueadas)
	Total Extra       = Horas Extras (inclui Bloqueadas)
	Total             = Horas Disponíveis + Horas Extras - Horas Bloqueadas - Horas Paradas
*/
	If nTipo == "1" //1 - Disponível
		aTempos[IND_ATEMPO_DISPONIVEL] += nQtdMinut
		If nBloqueada == "1"
			aTempos[IND_ATEMPO_BLOQUEADO] += nQtdMinut
		EndIf

	ElseIf nTipo == "2" //2 - Parado
		aTempos[IND_ATEMPO_DISPONIVEL] += nQtdMinut
		aTempos[IND_ATEMPO_PARADO    ] += nQtdMinut

	ElseIf nTipo == "3" //3 - Extra
		aTempos[IND_ATEMPO_EXTRA] += nQtdMinut
		If nBloqueada == "1"
			aTempos[IND_ATEMPO_BLOQUEADO] += nQtdMinut
		EndIf

	ElseIf nTipo == "4" //4 - Efetivada
		aTempos[IND_ATEMPO_DISPONIVEL] += nQtdMinut
		aTempos[IND_ATEMPO_EFETIVADA ] += nQtdMinut
	EndIf

	aTempos[IND_ATEMPO_TOTAL] := aTempos[IND_ATEMPO_DISPONIVEL] + aTempos[IND_ATEMPO_EXTRA] - aTempos[IND_ATEMPO_BLOQUEADO] - aTempos[IND_ATEMPO_PARADO] - aTempos[IND_ATEMPO_EFETIVADA]

Return

/*/{Protheus.doc} criaDisp
Cria o registro do recurso nas datas que não existia a disponibilidade

@type Static Function
@author marcelo.neumann
@since 30/08/2023
@version P12
@param 01 cProg     , Caracter, Código da programação
@param 02 oDados    , Objeto  , JSON com os dados recebidos para alteração
@param 03 oAlteradas, Objeto  , JSON com as disponibilidades que existem e foram alteradas
@param 04 oBulkSMK  , Objeto  , Objeto com os registros a serem inseridos na SMK
@return lSucesso    , Lógico  , Indica se criou com sucesso as disponibilidades
/*/
Static Function criaDisp(cProg, oDados, oAlteradas, oBulkSMK)
	Local aInsSMK    := {}
	Local aInsSMR    := {}
	Local aTempos    := {}
	Local cAliasMax  := ""
	Local cFilSMK    := xFilial("SMK")
	Local cFilSMR    := xFilial("SMR")
	Local cIdDisp    := ""
	Local cInRecurso := ""
	Local cRecurso   := ""
	Local dDataFim   := SToD( StrTran(oDados["dataFinal"  ], "-", "") )
	Local dIndData   := SToD( StrTran(oDados["dataInicial"], "-", "") )
	Local lCriouSMR  := .F.
	Local lSucesso   := .T.
	Local nIndDet    := 0
	Local nIndRec    := 0
	Local nTamDisp   := GetSX3Cache("MR_DISP", "X3_TAMANHO")
	Local nTotal     := Len(oDados["detalhes"])
	Local nTotRec    := Len(oDados["recursos"])
	Local oBulkSMR   := Nil
	Local oNewRecCT  := JsonObject():New()

	While dIndData <= dDataFim
		For nIndRec := 1 To nTotRec
			cRecurso := oDados["recursos"][nIndRec]

			If !oAlteradas:HasProperty(cRecurso + "_" + DToS(dIndData))
				iniTempos(@aTempos)

				//Busca última sequencia
				If !lCriouSMR
					lCriouSMR := .T.
					cAliasMax := GetNextAlias()
					BeginSql Alias cAliasMax
					  SELECT MAX(SMR.MR_DISP) DISP
					    FROM %Table:SMR% SMR
					   WHERE SMR.MR_FILIAL = %Exp:cFilSMR%
					     AND SMR.MR_PROG   = %Exp:cProg%
					     AND SMR.%NotDel%
					EndSql
					If Empty((cAliasMax)->(DISP))
						cIdDisp := StrZero(0, nTamDisp)
					Else
						cIdDisp := (cAliasMax)->(DISP)
					EndIf
					(cAliasMax)->(dbCloseArea())

					oBulkSMR := FwBulk():New()
					oBulkSMR:setTable(RetSqlName("SMR"))
					oBulkSMR:setFields(PCPA152Disponibilidade():estruturaTabela("SMR"))
				EndIf

				cIdDisp := Soma1(cIdDisp)

				For nIndDet := 1 To nTotal
					aInsSMK                   := Array(ARRAY_MK_TAMANHO)
					aInsSMK[ARRAY_MK_FILIAL ] := cFilSMK
					aInsSMK[ARRAY_MK_PROG   ] := cProg
					aInsSMK[ARRAY_MK_DISP   ] := cIdDisp
					aInsSMK[ARRAY_MK_SEQ    ] := StrZero(nIndDet, _nTamMKSeq)
					aInsSMK[ARRAY_MK_DATDISP] := dIndData
					aInsSMK[ARRAY_MK_HRINI  ] := oDados["detalhes"][nIndDet]["horaInicial"]
					aInsSMK[ARRAY_MK_HRFIM  ] := oDados["detalhes"][nIndDet]["horaFinal"  ]
					aInsSMK[ARRAY_MK_TIPO   ] := oDados["detalhes"][nIndDet]["tipo"       ]
					aInsSMK[ARRAY_MK_BLOQUE ] := oDados["detalhes"][nIndDet]["bloqueado"  ]

					calcTempo(@aTempos, aInsSMK[ARRAY_MK_HRINI], aInsSMK[ARRAY_MK_HRFIM], aInsSMK[ARRAY_MK_TIPO], aInsSMK[ARRAY_MK_BLOQUE])

					oBulkSMK:addData(aInsSMK)
				Next nIndDet

				//Inclui o registro na SMR
				aInsSMR                    := Array(ARRAY_MR_TAMANHO)
				aInsSMR[ARRAY_MR_FILIAL  ] := cFilSMR
				aInsSMR[ARRAY_MR_PROG    ] := cProg
				aInsSMR[ARRAY_MR_DISP    ] := cIdDisp
				aInsSMR[ARRAY_MR_RECURSO ] := cRecurso
				aInsSMR[ARRAY_MR_TIPO    ] := oDados["tipo"]
				aInsSMR[ARRAY_MR_CALEND  ] := ""
				aInsSMR[ARRAY_MR_DATDISP ] := dIndData
				aInsSMR[ARRAY_MR_SITUACA ] := "1"
				aInsSMR[ARRAY_MR_TEMPODI ] := aTempos[IND_ATEMPO_DISPONIVEL]
				aInsSMR[ARRAY_MR_TEMPOBL ] := aTempos[IND_ATEMPO_BLOQUEADO ]
				aInsSMR[ARRAY_MR_TEMPOPA ] := aTempos[IND_ATEMPO_PARADO    ]
				aInsSMR[ARRAY_MR_TEMPOEX ] := aTempos[IND_ATEMPO_EXTRA     ]
				aInsSMR[ARRAY_MR_TEMPOEF ] := aTempos[IND_ATEMPO_EFETIVADA ]
				aInsSMR[ARRAY_MR_TEMPOTO ] := aTempos[IND_ATEMPO_TOTAL     ]
				aInsSMR[ARRAY_MR_SEQFER  ] := oDados["seqFerramenta"]

				oBulkSMR:addData(aInsSMR)

				aSize(aTempos, 0)

				If !oNewRecCT:HasProperty(cRecurso)
					oNewRecCT[cRecurso] := .T.

					If Empty(cInRecurso)
						cInRecurso := "'" + cRecurso + "'"
					Else
						cInRecurso := cInRecurso + ",'" + cRecurso + "'"
					EndIf
				EndIf
			EndIf
		Next nIndRec

		dIndData++
	End

	If !Empty(cInRecurso)
		lSucesso := criaSMT(cProg, cInRecurso)
	EndIf

	If lSucesso .And. lCriouSMR
		lSucesso := oBulkSMR:close()
		oBulkSMR:destroy()
		FwFreeObj(oBulkSMR)
	EndIf

	FreeObj(oNewRecCT)
	aSize(aInsSMR, 0)
	aSize(aInsSMK, 0)

Return lSucesso

/*/{Protheus.doc} criaSMT
Pesquisa e insere o Centro de Trabalho do Recurso na tabela SMT

@type Static Function
@author marcelo.neumann
@since 30/08/2023
@version P12
@param 01 cProg     , Caracter, Código da programação
@param 02 cInRecurso, Caracter, Recursos a serem pesquisados para incluir na SMT
@return lSucesso    , Lógico  , Indica se criou com sucesso a tabela SMT
/*/
Static Function criaSMT(cProg, cInRecurso)
	Local aInsSMT  := {}
	Local cAlias   := GetNextAlias()
	Local cFilSMT  := xFilial("SMT")
	Local cQuery   := ""
	Local lSucesso := .T.
	Local oBulkSMT := Nil

	cAlias := GetNextAlias()

	//Grava Centro de Trabalho dos novos recursos na SMT
	cQuery := "SELECT SH1.H1_CODIGO, SH1.H1_CTRAB"
	cQuery +=  " FROM " + RetSqlName("SH1") + " SH1"
	cQuery += " WHERE SH1.H1_FILIAL  = '" + xFilial("SH1") + "'"
	cQuery +=   " AND SH1.D_E_L_E_T_ = ' '"
	cQuery +=   " AND SH1.H1_CODIGO IN (" + cInRecurso + ")"
	cQuery +=   " AND NOT EXISTS (SELECT 1"
	cQuery +=                     " FROM " + RetSqlName("SMT") + " SMT"
	cQuery +=                    " WHERE SMT.MT_FILIAL  = '" + xFilial("SMT") + "'"
	cQuery +=                      " AND SMT.MT_PROG    = '" + cProg + "'"
	cQuery +=                      " AND SMT.MT_RECURSO IN (" + cInRecurso + ")"
	cQuery +=                      " AND SMT.MT_RECURSO = SH1.H1_CODIGO"
	cQuery +=                      " AND SMT.D_E_L_E_T_ = ' ')"

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)

	If (cAlias)->(!EoF())
		oBulkSMT := FwBulk():New()
		oBulkSMT:setTable(RetSqlName("SMT"))
		oBulkSMT:setFields(PCPA152Disponibilidade():estruturaTabela("SMT"))
	EndIf

	While (cAlias)->(!EoF())
		//Inclui o registro na SMT
		aInsSMT                   := Array(ARRAY_MT_TAMANHO)
		aInsSMT[ARRAY_MT_FILIAL ] := cFilSMT
		aInsSMT[ARRAY_MT_PROG   ] := cProg
		aInsSMT[ARRAY_MT_RECURSO] := (cAlias)->H1_CODIGO
		aInsSMT[ARRAY_MT_CTRAB  ] := (cAlias)->H1_CTRAB

		oBulkSMT:addData(aInsSMT)
		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())

	If oBulkSMT <> Nil
		lSucesso := oBulkSMT:close()
		oBulkSMT:destroy()
		FwFreeObj(oBulkSMT)
		aSize(aInsSMT, 0)
	EndIf

Return lSucesso

/*/{Protheus.doc} iniTempos
Inicializa o array de controle dos tempos totais (SMR)

@type Static Function
@author marcelo.neumann
@since 20/11/2023
@version P12
@param aTempos, Array, Array a ser inicializada com valores 0 (zero)
@return Nil
/*/
Static Function iniTempos(aTempos)

	aTempos := Array(IND_ATEMPO_TAMANHO)
	aTempos[IND_ATEMPO_DISPONIVEL] := 0
	aTempos[IND_ATEMPO_PARADO    ] := 0
	aTempos[IND_ATEMPO_EXTRA     ] := 0
	aTempos[IND_ATEMPO_EFETIVADA ] := 0
	aTempos[IND_ATEMPO_BLOQUEADO ] := 0
	aTempos[IND_ATEMPO_TOTAL     ] := 0

Return

/*/{Protheus.doc} getDataLim
Retorna a data limite para busca da disponibilidade.
@type  Static Function
@author Lucas Fagundes
@since 14/01/2025
@version P12
@param cProg, Caracter, Programação que está sendo realizada a consulta.
@return cData, Caracter, Data limite para busca da disponibilidade.
/*/
Static Function getDataLim(cProg)
	Local cData    := ""
	Local cFimProg := Nil
	Local cUltAloc := Nil

	dbSelectArea("T4Y")
	T4Y->(dbSetOrder(2))

	T4Y->(dbSeek(xFilial("T4Y") + cProg + "dataFinal"))
	cFimProg := AllTrim(T4Y->T4Y_VALOR)

	T4Y->(dbSeek(xFilial("T4Y") + cProg + "dataRealFim"))
	cUltAloc := AllTrim(T4Y->T4Y_VALOR)

	cData := IIf(cUltAloc > cFimProg, PCPConvDat(cUltAloc, 6), PCPConvDat(cFimProg, 6))

Return cData
