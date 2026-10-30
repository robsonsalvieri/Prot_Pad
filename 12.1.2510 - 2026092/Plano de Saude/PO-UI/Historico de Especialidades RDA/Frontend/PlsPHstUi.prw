#Include "TOTVS.CH"
#Include "PLSPHSTUI.CH"

Static aBlvUiCtx := {"", "", "", "", ""}

////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} ABRHSTUI
Prepara o contexto da especialidade e chama a aplicacao de historico.
@since 06/04/2026
@param cCodigo, caractere, Codigo da RDA.
@param cCodInt, caractere, Codigo da interna.
@param cCodLoc, caractere, Codigo do local.
@param cCodEsp, caractere, Codigo da especialidade.
@param cCodSub, caractere, Codigo da subespecialidade.
@return Nil, nil, Nao retorna valor.
/*/
Static Function ABRHSTUI(cCodigo, cCodInt, cCodLoc, cCodEsp )
	
	Default cCodigo := ""
	Default cCodInt := ""
	Default cCodLoc := ""
	Default cCodEsp := ""

	aBlvUiCtx := { ;
		AllTrim(cCodigo), ;
		AllTrim(cCodInt), ;
		AllTrim(cCodLoc), ;
		AllTrim(cCodEsp) }

	FwCallApp("PlsPHstUi")
Return

////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} HSTESPUI
Abre a interface de historico da especialidade selecionada no browse.
@since 06/04/2026
@param oBrw, objeto, Browse com a especialidade posicionada.
@param cCodigo, caractere, Codigo da RDA.
@param cCodInt, caractere, Codigo da interna.
@param cCodLoc, caractere, Codigo do local.
@param cCodEsp, caractere, Codigo da especialidade.
@param cCodSub, caractere, Codigo da subespecialidade.
@return lRet, logico, Indica se a abertura do historico foi iniciada.
/*/
Function HSTESPUI(oBrw, cCodigo, cCodInt, cCodLoc, cCodEsp)
	
	Local nLine   := 0
	Local nPosInt := 0
	Local nPosLoc := 0
	Local nPosEsp := 0
	Local nPosDel := 0
	Local cRunInt := AllTrim(cCodInt)
	Local cRunLoc := AllTrim(cCodLoc)
	Local cRunEsp := AllTrim(cCodEsp)
	Local lDelete := .F.

	Default cCodigo := ""
	Default cCodInt := ""
	Default cCodLoc := ""
	Default cCodEsp := ""

	If ValType(oBrw) == "O" .And. ValType(oBrw:aCols) == "A" .And. Len(oBrw:aCols) > 0
		
		 nLine := BUSLINHA(oBrw)

		If nLine > 0 .And. nLine <= Len(oBrw:aCols)
			 
			 nPosInt := POSCAMPO(oBrw, "BAX_CODINT")
			 nPosLoc := POSCAMPO(oBrw, "BAX_CODLOC")
			 nPosEsp := POSCAMPO(oBrw, "BAX_CODESP")
			 nPosDel := IIf(ValType(oBrw:aHeader) == "A", Len(oBrw:aHeader) + 1, 0)

			If nPosInt > 0
				 cRunInt := VALCOLUN(oBrw, nLine, nPosInt)
			EndIf

			If nPosLoc > 0
				 cRunLoc := VALCOLUN(oBrw, nLine, nPosLoc)
			EndIf

			If nPosEsp > 0
				 cRunEsp := VALCOLUN(oBrw, nLine, nPosEsp)
			EndIf

			If nPosDel > 0 .And. nPosDel <= Len(oBrw:aCols[nLine]) .And. ValType(oBrw:aCols[nLine, nPosDel]) == "L"
				 lDelete := oBrw:aCols[nLine, nPosDel]
			EndIf
		EndIf
	EndIf

	If lDelete .OR. Empty(cRunEsp)
		MsgInfo(STR0001) //"Selecione uma especialidade válida para consultar o histórico."
		Return .F.
	EndIf

	If Empty(AllTrim(cCodigo)) .Or. Empty(cRunInt) .Or. Empty(cRunLoc)
		MsgInfo(STR0002) //"Não foi possível identificar a RDA posicionada"
		Return .F.
	EndIf

	ABRHSTUI(AllTrim(cCodigo), cRunInt, cRunLoc, cRunEsp)

Return .T.


////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} BUSLINHA
Recupera a linha atual do browse e aplica fallback para a primeira linha.
@since 06/04/2026
@param oBrw, objeto, Browse que sera inspecionado.
@return nLine, numerico, Numero da linha posicionada.
/*/
Static Function BUSLINHA(oBrw)
	Local nLine := 0

	Begin Sequence
		 nLine := oBrw:Linha()
	Recover
		 nLine := 0
	End Sequence

	If nLine <= 0 .And. ValType(oBrw:aCols) == "A" .And. Len(oBrw:aCols) > 0
		 nLine := 1
	EndIf

Return nLine

////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} POSCAMPO
Localiza a posicao de um campo no cabecalho do browse informado.
@since 06/04/2026
@param oBrw, objeto, Browse que contem o cabecalho.
@param cField, caractere, Nome do campo a ser localizado.
@return nPos, numerico, Posicao do campo no cabecalho.
/*/
Static Function POSCAMPO(oBrw, cField)
	Local nPos := 0

	Default cField := ""

	If ValType(oBrw) <> "O" .Or. ValType(oBrw:aHeader) <> "A" .Or. Empty(cField)
		Return 0
	EndIf

    nPos := GdFieldPos(cField, oBrw:aHeader)
	
	If nPos <= 0
		nPos := oBrw:PLRETPOS(cField, .F., oBrw:aHeader)
	EndIf

Return nPos

////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} VALCOLUN
Retorna o valor textual de uma coluna da linha atual do browse.
@since 06/04/2026
@param oBrw, objeto, Browse que contem os dados.
@param nLine, numerico, Numero da linha desejada.
@param nPos, numerico, Posicao da coluna desejada.
@return cValue, caractere, Valor da coluna convertido para caractere.
/*/
Static Function VALCOLUN(oBrw, nLine, nPos)
	
	Local cValue := ""
	Local xValue := Nil

	If ValType(oBrw) == "O" .And. ValType(oBrw:aCols) == "A" .And. ;
	   nLine > 0 .And. nLine <= Len(oBrw:aCols) .And. ;
	   nPos > 0 .And. nPos <= Len(oBrw:aCols[nLine])
	   
	   xValue := oBrw:aCols[nLine, nPos]
	   cValue := AllTrim(cValToChar(xValue))
	EndIf

Return cValue

////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} JsToAdvpl
Processa as acoes recebidas do canal web e devolve os payloads necessarios.
@since 06/04/2026
@param oWebChannel, objeto, Canal de comunicacao entre o front-end e o AdvPL.
@param cType, caractere, Acao solicitada pelo front-end.
@param cContent, caractere, Conteudo serializado enviado na requisicao.
@return lRet, logico, Indica que a acao foi tratada.
/*/
Static Function JsToAdvpl(oWebChannel, cType, cContent)
	
	Local cAction := Upper(AllTrim(cType))

	Default cContent := ""

	Do Case
		Case cAction == "REQUESTCONTEXT"
			oWebChannel:AdvplToJs("blvHistoryContext", GETCONTX())
	
		Case cAction == "LOADSPECIALTIES"
			oWebChannel:AdvplToJs("blvHistorySpecialties", PAYESPEC(SPLITFLT(cContent)))
	
		Case cAction == "LOADHISTORY"
			oWebChannel:AdvplToJs("blvHistoryData", PAYHIST(SPLITFLT(cContent)))
	EndCase

Return .T.

////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} NORMFILT
Normaliza o filtro recebido e aplica o contexto atual quando necessario.
@since 06/04/2026
@param aFilter, array, Filtro com os identificadores da consulta.
@return aFilter, array, Filtro normalizado para processamento.
/*/
Static Function NORMFILT(aFilter)
	
	aFilter[1] := AllTrim(aFilter[1])
	aFilter[2] := AllTrim(aFilter[2])
	aFilter[3] := AllTrim(aFilter[3])
	aFilter[4] := AllTrim(aFilter[4])
	aFilter[5] := AllTrim(aFilter[5])

	If Empty(aFilter[1]) .And. Empty(aFilter[2]) .And. Empty(aFilter[3]) .And. Empty(aFilter[4]) .And. Empty(aFilter[5])
		aFilter := { ;
			AllTrim(aBlvUiCtx[1]), ;
			AllTrim(aBlvUiCtx[2]), ;
			AllTrim(aBlvUiCtx[3]), ;
			AllTrim(aBlvUiCtx[4]), ;
			AllTrim(aBlvUiCtx[5]) }
	EndIf

Return aFilter

////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} PAYESPEC
Monta o payload JSON com as especialidades vinculadas a RDA informada.
@since 06/04/2026
@param aFilter, array, Filtro com os identificadores da consulta.
@return cRet, caractere, JSON com as especialidades encontradas.
/*/
Static Function PAYESPEC(aFilter)
	
	Local oResp     := JsonObject():New()
	Local aItems    := {}

	aFilter := NORMFILT(aFilter)

	oResp["message"] := ""
	oResp["items"] := {}

	If Empty(aFilter[1]) .Or. Empty(aFilter[2]) .Or. Empty(aFilter[3])
		oResp["message"] := STR0002 //"Não foi possível identificar a RDA posicionada"
		Return oResp:ToJson()
	EndIf

	aItems := LSTESPGR(aFilter)
	oResp["items"] := aItems
	oResp["message"] := IIf(Len(aItems) > 0, "", STR0003) //"Nenhuma especialidade vinculada foi encontrada para a RDA posicionada"

Return oResp:ToJson()

////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} PAYHIST
Monta o payload JSON com o historico da especialidade selecionada.
@since 06/04/2026
@param aFilter, array, Filtro com os identificadores da consulta.
@return cRet, caractere, JSON com periodos e alteracoes da especialidade.
/*/
Static Function PAYHIST(aFilter)
	
	Local oResp        := NOVRESP()
	Local oFilt        := JsonObject():New()
	Local aChangesJson := {}
	Local aPeriodsJson := {}

	aFilter := NORMFILT(aFilter)

	oFilt["codigo"] := aFilter[1]
	oFilt["codint"] := aFilter[2]
	oFilt["codloc"] := aFilter[3]
	oFilt["codesp"] := aFilter[4]
	oFilt["codsub"] := aFilter[5]
	oResp["filter"] := oFilt

	If Empty(aFilter[1]) .Or. Empty(aFilter[2]) .Or. Empty(aFilter[3]) .Or. Empty(aFilter[4])
		oResp["message"] := STR0004 //"Selecione uma especialidade válida para consultar o histórico"
		Return oResp:ToJson()
	EndIf

	LERHIST(aFilter, @aPeriodsJson, @aChangesJson)
	
	oResp["success"] := Len(aChangesJson) > 0 .Or. Len(aPeriodsJson) > 0
	oResp["message"] := IIf(oResp["success"], "", STR0005) //"Nenhum historico encontrado para a chave informada"
	oResp["periods"] := aPeriodsJson
	oResp["changes"] := aChangesJson

Return oResp:ToJson()

////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} LSTESPGR
Lista as especialidades vinculadas a RDA para exibicao no historico.
@since 06/04/2026
@param aFilter, array, Filtro com os identificadores da consulta.
@return aItems, array, Lista de especialidades montada para o front-end.
/*/
Static Function LSTESPGR(aFilter)
	
	Local aItems   := {}
	Local cCodigo  := aFilter[1]
	Local cCodInt  := aFilter[2]
	Local cCodLoc  := aFilter[3]
	Local cNomeRda := BUSRDANM(cCodigo)
	Local cDesEsp  := ""
	Local cCodSub  := ""
	Local xCodBlo  := Nil
	Local xDatBlo  := Nil
	Local nPosBlo  := 0
	Local nPosDat  := 0

	BAX->(DbSetOrder(1))
	nPosBlo := BAX->(FieldPos("BAX_CODBLO"))
	nPosDat := BAX->(FieldPos("BAX_DATBLO"))

	If BAX->(MsSeek(xFilial("BAX") + cCodigo))
		
		While !BAX->(Eof()) .And. BAX->(BAX_FILIAL + BAX_CODIGO) == xFilial("BAX") + cCodigo
			
			If BAX->BAX_CODINT == cCodInt .And. BAX->BAX_CODLOC == cCodLoc
				
				cCodSub := IIf(BAX->(FieldPos("BAX_CODSUB")) > 0, AllTrim(BAX->BAX_CODSUB), "")
				cDesEsp := BUSESPDS(BAX->BAX_CODINT, BAX->BAX_CODESP)
				xCodBlo := IIf(nPosBlo > 0, BAX->(FieldGet(nPosBlo)), Nil)
				xDatBlo := IIf(nPosDat > 0, BAX->(FieldGet(nPosDat)), Nil)

				If Empty(CONVDATA(xCodBlo)) .And. !Empty(CONVDATA(xDatBlo))
					xCodBlo := xDatBlo
				EndIf

				AAdd(aItems, OBJESPEC( ;
					STATUAL(xCodBlo), ;
					cCodigo, ;
					cNomeRda, ;
					AllTrim(BAX->BAX_CODESP), ;
					cDesEsp, ;
					AllTrim(BAX->BAX_CODINT), ;
					AllTrim(BAX->BAX_CODLOC), ;
					cCodSub, ;
					DATATXT(CONVDATA(xCodBlo))))
			EndIf

			BAX->(DbSkip())
		EndDo
	EndIf

Return aItems

////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} BUSRDANM
Busca o nome da RDA a partir do codigo informado.
@since 06/04/2026
@param cCodigo, caractere, Codigo da RDA.
@return cNome, caractere, Nome da RDA encontrada.
/*/
Static Function BUSRDANM(cCodigo)
	
	Local cNome := ""

	If Empty(cCodigo)
		Return ""
	EndIf

	cNome := AllTrim(Posicione("BAU", 1, xFilial("BAU") + cCodigo, "BAU_NOME"))
	
Return cNome

////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} BUSESPDS
Busca a descricao da especialidade selecionada.
@since 06/04/2026
@param cCodInt, caractere, Codigo da interna.
@param cCodEsp, caractere, Codigo da especialidade.
@return cDesc, caractere, Descricao da especialidade.
/*/
Static Function BUSESPDS(cCodInt, cCodEsp)
	
	If !Empty(cCodEsp)
		
	    cDesc := AllTrim(Posicione("BAQ", 1, xFilial("BAQ") + AllTrim(cCodInt) + AllTrim(cCodEsp), "BAQ_DESCRI"))
	EndIf

Return cDesc

////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} STATUAL
Determina o status atual da especialidade com base na data de bloqueio.
@since 06/04/2026
@param xCodBlo, qualquer, Valor que representa a data de bloqueio.
@return cStatus, caractere, Status atual da especialidade.
/*/
Static Function STATUAL(xCodBlo)
	
	Local dCodBlo := CONVDATA(xCodBlo)

	If !Empty(dCodBlo) .And. dCodBlo <= dDataBase
		Return "BLOQUEADO"
	EndIf

Return "ATIVO"

////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} CONVDATA
Converte valores de data em formatos distintos para o tipo data do AdvPL.
@since 06/04/2026
@param xValue, qualquer, Valor a ser convertido para data.
@return dDate, data, Data convertida ou data vazia quando invalida.
/*/
Static Function CONVDATA(xValue)
	
	Local dDate  := CToD("")
	Local cValue := ""
	Local nYear  := 0

	If Empty(xValue)
		Return dDate
	EndIf

	If ValType(xValue) == "D"
		Return xValue
	EndIf

	cValue := AllTrim(cValToChar(xValue))
	cValue := StrTran(cValue, "-", "")
	cValue := StrTran(cValue, "/", "")
	cValue := StrTran(cValue, ".", "")
	cValue := StrTran(cValue, " ", "")

	If Len(cValue) <> 8
		Return dDate
	EndIf

	nYear := Val(SubStr(cValue, 1, 4))

	If nYear >= 1900
		Return StoD(cValue)
	EndIf

Return StoD(SubStr(cValue, 5, 4) + SubStr(cValue, 3, 2) + SubStr(cValue, 1, 2))

////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} OBJESPEC
Monta o objeto JSON com os dados resumidos da especialidade.
@since 06/04/2026
@param cStatus, caractere, Status atual da especialidade.
@param cCodigo, caractere, Codigo da RDA.
@param cNomeRda, caractere, Nome da RDA.
@param cCodEsp, caractere, Codigo da especialidade.
@param cDescricao, caractere, Descricao da especialidade.
@param cCodInt, caractere, Codigo da interna.
@param cCodLoc, caractere, Codigo do local.
@param cCodSub, caractere, Codigo da subespecialidade.
@param cDataBloqueio, caractere, Data de bloqueio formatada para exibicao.
@return oItem, objeto, Objeto JSON com os dados da especialidade.
/*/
Static Function OBJESPEC(cStatus, cCodigo, cNomeRda, cCodEsp, cDescricao, cCodInt, cCodLoc, cCodSub, cDataBloqueio)
	
	Local oItem := JsonObject():New()

	oItem["status"]                 := cStatus
	oItem["codigo"]                 := cCodigo
	oItem["nomeRda"]                := cNomeRda
	oItem["codesp"]                 := cCodEsp
	oItem["descricaoEspecialidade"] := cDescricao
	oItem["codint"] 			    := cCodInt
	oItem["codloc"] 			    := cCodLoc
	oItem["codsub"] 			    := cCodSub
	oItem["dataBloqueio"] 			:= cDataBloqueio

Return oItem

////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} LERHIST
Le o historico da especialidade e separa os dados em periodos e alteracoes.
@since 06/04/2026
@param aFilter, array, Filtro com os identificadores da consulta.
@param aPeriodsJson, array, Array por referencia que recebera os periodos.
@param aChangesJson, array, Array por referencia que recebera as alteracoes.
@return lRet, logico, Indica se a leitura do historico foi realizada.
/*/
Static Function LERHIST(aFilter, aPeriodsJson, aChangesJson)
	
	Local aRows      := {}
	Local aCodes     := {}
	Local aRow       := {}
	Local aUsrCache  := {}
	Local cCodigo    := AllTrim(aFilter[1])
	Local cCodInt    := AllTrim(aFilter[2])
	Local cCodLoc    := AllTrim(aFilter[3])
	Local cCodEsp    := ""
	Local cEspAnt    := ""
	Local cEspNov    := ""
	Local cUsrCod    := ""
	Local cUsrNom    := ""
	Local cSql       := ""
	Local cTpTable   := ""
	Local lAddCode   := .T.
	Local nI         := 0
	Local nLnRows    := 0
	Local oStatement := FWExecStatement():New()

	Default aFilter      := {}
	Default aPeriodsJson := {}
	Default aChangesJson := {}
	
	If Empty(aFilter) .Or. Len(aFilter) < 4
		Return {}
	EndIf

	cCodEsp := AllTrim(aFilter[4])

	If Empty(cCodigo) .Or. Empty(cCodInt) .Or. Empty(cCodLoc) .Or. Empty(cCodEsp)
		Return {}
	EndIf

	cSql += " SELECT BLV_DATALT, BLV_HORALT, BLV_CAMPO, BLV_VALANT, BLV_VALNOV, "
	cSql += "        BLV_USUARI, BLV_EVENTO, BLV_SEQ  , BLV_TPEVTO, BLV_TPCAM, "
	cSql += "        BLV_CESPAT, BLV_CESPNO "
	cSql += " FROM " + RetSqlName("BLV")
	cSql += " WHERE BLV_FILIAL = ? "
	cSql += " AND BLV_CODIGO   = ? "
	cSql += " AND BLV_CODINT   = ? "
	cSql += " AND BLV_CODLOC   = ? "
	cSql += " AND D_E_L_E_T_   = ? "
	cSql += " ORDER BY BLV_DATALT, BLV_HORALT, BLV_EVENTO, BLV_SEQ "

	oStatement:SetQuery(cSql)
	oStatement:SetString(1, xFilial("BLV"))
	oStatement:SetString(2, cCodigo)
	oStatement:SetString(3, cCodInt)
	oStatement:SetString(4, cCodLoc)
	oStatement:SetString(5, " ")
	cTpTable := oStatement:OpenAlias()

	While !(cTpTable)->(Eof())

		AAdd(aRows, { ;
			(cTpTable)->BLV_DATALT, ;
			(cTpTable)->BLV_HORALT, ;
			(cTpTable)->BLV_CAMPO, ;
			(cTpTable)->BLV_VALANT, ;
			(cTpTable)->BLV_VALNOV, ;
			(cTpTable)->BLV_USUARI, ;
			(cTpTable)->BLV_EVENTO, ;
			(cTpTable)->BLV_SEQ, ;
			(cTpTable)->BLV_TPEVTO, ;
			(cTpTable)->BLV_TPCAM, ;
			(cTpTable)->BLV_CESPAT, ;
			(cTpTable)->BLV_CESPNO })

		(cTpTable)->(DbSkip())
	EndDo

	(cTpTable)->(DbCloseArea())
	oStatement:Destroy()

	AAdd(aCodes, cCodEsp)
	nLnRows := Len(aRows)

	Do While lAddCode
		lAddCode := .F.

		For nI := 1 To nLnRows
			aRow := aRows[nI]

			If aRow[3] <> "BAX_CODESP"
				Loop
			EndIf

			cEspAnt := AllTrim(aRow[11])
			cEspNov := AllTrim(aRow[12])

			If Empty(cEspAnt) .Or. Empty(cEspNov) .Or. cEspAnt == cEspNov
				Loop
			EndIf

			If AScan(aCodes, {|cItem| cItem == cEspNov}) > 0 .And. AScan(aCodes, {|cItem| cItem == cEspAnt}) == 0
				AAdd(aCodes, cEspAnt)
				lAddCode := .T.
			EndIf
		Next
	EndDo

	For nI := 1 To nLnRows
		aRow := aRows[nI]
		cEspAnt := AllTrim(aRow[11])
		cEspNov := AllTrim(aRow[12])

		If AScan(aCodes, {|cItem| cItem == cEspAnt .Or. cItem == cEspNov}) == 0
			Loop
		EndIf

		cUsrCod := AllTrim(aRow[6])
		cUsrNom := NOMEUSR(cUsrCod, @aUsrCache)

		If aRow[3] == "BAX_DATBLO"
			AAdd(aPeriodsJson, OBJPERIO( ;
				AllTrim(aRow[11]), ;
				STATHIS(aRow[5]), ;
				STRDATA(aRow[4]), ;
				STRDATA(aRow[5]), ;
				DATATXT(aRow[1]), ;
				aRow[2], ;
				cUsrCod, ;
				cUsrNom))
		Else
			AAdd(aChangesJson, OBJCHANG( ;
				AllTrim(aRow[11]), ;
				aRow[1], ;
				aRow[2], ;
				aRow[3], ;
				aRow[4], ;
				aRow[5], ;
				cUsrCod, ;
				aRow[7], ;
				aRow[8], ;
				aRow[9], ;
				aRow[10]))
		EndIf
	Next

Return 
////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} SQLVALUE
Escapa e envolve um valor caractere para uso em comandos SQL.
@since 06/04/2026
@param cValue, caractere, Valor que sera convertido para literal SQL.
@return cRet, caractere, Valor formatado para uso em SQL.
/*/
Static Function SQLVALUE(cValue)
	Default cValue := ""

Return "'" + StrTran(cValue, "'", "''") + "'"

////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} NOMEUSR
Resolve o nome do usuario e reutiliza um cache para evitar consultas repetidas.
@since 06/04/2026
@param cUsrCod, caractere, Codigo do usuario.
@param aUsrCache, array, Cache com os usuarios ja resolvidos.
@return cUsrNom, caractere, Nome do usuario informado.
/*/
Static Function NOMEUSR(cUsrCod, aUsrCache)
	
	Local cUsrNom := ""
	Local nCache  := 0

	Default cUsrCod := ""
	Default aUsrCache := {}

	If Empty(cUsrCod)
		Return ""
	EndIf

	nCache := AScan(aUsrCache, {|x| x[1] == cUsrCod})

	If nCache > 0
		Return aUsrCache[nCache][2]
	EndIf

	cUsrNom := AllTrim(UsrRetName(cUsrCod))

	AAdd(aUsrCache, {cUsrCod, cUsrNom})

Return cUsrNom

////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} STATHIS
Retorna o status historico a partir da data de bloqueio informada.
@since 06/04/2026
@param cDatBlo, caractere, Data de bloqueio do evento.
@return cStatus, caractere, Status derivado da data de bloqueio.
/*/
Static Function STATHIS(cDatBlo)
Return STATUAL(cDatBlo)

////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} OBJCHANG
Monta o objeto JSON com os detalhes de uma alteracao de historico.
@since 06/04/2026
@param cCodEsp, caractere, Codigo da especialidade do historico.
@param dData, data, Data da alteracao.
@param cHora, caractere, Hora da alteracao.
@param cCampo, caractere, Campo alterado.
@param cValorAnt, caractere, Valor anterior do campo.
@param cValorNov, caractere, Novo valor do campo.
@param cUsrCod, caractere, Codigo do usuario responsavel.
@param cEvento, caractere, Codigo do evento.
@param nSeq, numerico, Sequencia do evento.
@param cTipoEvt, caractere, Tipo do evento registrado.
@param cTipoCampo, caractere, Tipo do campo alterado.
@return oItem, objeto, Objeto JSON com os dados da alteracao.
/*/
Static Function OBJCHANG(cCodEsp, dData, cHora, cCampo, cValorAnt, cValorNov, cUsrCod, cEvento, nSeq, cTipoEvt, cTipoCampo)
	
	Local oItem := JsonObject():New()

	Default cCodEsp    := ""
	Default dData      := CTOD("")
	Default cHora      := ""
	Default cCampo     := ""
	Default cValorAnt  := ""
	Default cValorNov  := ""
	Default cUsrCod    := ""
	Default cEvento    := ""
	Default cTipoEvt   := ""
	Default cTipoCampo := ""
	Default nSeq       := 0

	oItem["codEspecialidade"] := AllTrim(cCodEsp)
	oItem["data"]             := DATATXT(dData)
	oItem["hora"]             := cHora
	oItem["dataHora"]         := DATETIME(dData, cHora)
	oItem["campo"]            := cCampo
	oItem["descricaoCampo"]   := DESCAMP(cCampo)
	oItem["campoLabel"]       := ROTCAMPO(cCampo)
	oItem["valorAnterior"]    := FMTVALOR(cTipoCampo, cValorAnt)
	oItem["valorNovo"]        := FMTVALOR(cTipoCampo, cValorNov)
	oItem["usuario"]          := cUsrCod
	oItem["nomeUsuario"]      := NOMEUSR(cUsrCod)
	oItem["evento"]           := cEvento
	oItem["sequencia"]        := nSeq
	oItem["tipoEvento"]       := cTipoEvt
	oItem["tipoEventoLabel"]  := ROTEVTO(cTipoEvt)
	oItem["tipoCampo"]        := cTipoCampo
	oItem["tipoCampoLabel"]   := ROTTPCAM(cTipoCampo)
	oItem["destaqueStatus"]   := .F.
	oItem["statusResultante"] := ""

Return oItem

////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} LERCHANG
Le o historico bruto da tabela BLV e separa alteracoes e eventos de status.
@since 06/04/2026
@param aFilter, array, Filtro com os identificadores da consulta.
@param aChangesRaw, array, Array por referencia que recebera as alteracoes brutas.
@param aStatusRaw, array, Array por referencia que recebera os eventos de status.
@return Nil, nil, Nao retorna valor.
/*/
Static Function LERCHANG(aFilter, aChangesRaw, aStatusRaw)
	
	Local cCodigo    := AllTrim(aFilter[1])
	Local cCodInt    := AllTrim(aFilter[2])
	Local cCodLoc    := AllTrim(aFilter[3])
	Local cCodEsp    := AllTrim(aFilter[4])
	Local cSql       := ""
	Local cTpTable   := ""
	Local lMatch     := .F.
	Local oStatement := FWExecStatement():New()

	Default aChangesRaw := {}
	Default aStatusRaw  := {}

	If Empty(cCodigo) .Or. Empty(cCodInt) .Or. Empty(cCodLoc) .Or. Empty(cCodEsp)
		Return
	EndIf

	cSql += " SELECT BLV_DATALT, BLV_HORALT, BLV_CAMPO, BLV_VALANT, BLV_VALNOV, "
	cSql += "        BLV_USUARI, BLV_EVENTO, BLV_SEQ  , BLV_TPEVTO, BLV_TPCAM, "
	cSql += "        BLV_CESPAT, BLV_CESPNO "
	cSql += " FROM " + RetSqlName("BLV")
	cSql += " WHERE BLV_FILIAL = ? "
	cSql += " AND BLV_CODIGO   = ? "
	cSql += " AND BLV_CODINT   = ? "
	cSql += " AND BLV_CODLOC   = ? "
	cSql += " AND D_E_L_E_T_   = ? "
	cSql += " ORDER BY BLV_DATALT, BLV_HORALT, BLV_EVENTO, BLV_SEQ "

	oStatement:SetQuery(cSql)
	oStatement:SetString(1, xFilial("BLV"))
	oStatement:SetString(2, cCodigo)
	oStatement:SetString(3, cCodInt)
	oStatement:SetString(4, cCodLoc)
	oStatement:SetString(5, " ")
	cTpTable := oStatement:OpenAlias()

	If !Empty(cTpTable)
		While !(cTpTable)->(Eof())
			
			lMatch := AllTrim((cTpTable)->BLV_CESPAT) == cCodEsp .Or. AllTrim((cTpTable)->BLV_CESPNO) == cCodEsp

			If lMatch
				
				AAdd(aChangesRaw, { ;
					(cTpTable)->BLV_DATALT, ;
					(cTpTable)->BLV_HORALT, ;
					(cTpTable)->BLV_CAMPO, ;
					(cTpTable)->BLV_VALANT, ;
					(cTpTable)->BLV_VALNOV, ;
					(cTpTable)->BLV_USUARI, ;
					(cTpTable)->BLV_EVENTO, ;
					(cTpTable)->BLV_SEQ, ;
					(cTpTable)->BLV_TPEVTO, ;
					(cTpTable)->BLV_TPCAM, ;
					(cTpTable)->BLV_CAMPO == "BAX_DATBLO" })

				If (cTpTable)->BLV_CAMPO == "BAX_DATBLO"
					
					AAdd(aStatusRaw, { ;
						(cTpTable)->BLV_DATALT, ;
						(cTpTable)->BLV_HORALT, ;
						(cTpTable)->BLV_VALANT, ;
						(cTpTable)->BLV_VALNOV, ;
						(cTpTable)->BLV_USUARI, ;
						(cTpTable)->BLV_EVENTO })
				EndIf
			EndIf

			(cTpTable)->(DbSkip())
		EndDo

		(cTpTable)->(DbCloseArea())
	EndIf

	oStatement:Destroy()

Return

////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} MONTPERD
Monta a lista de periodos a partir dos eventos brutos de status.
@since 06/04/2026
@param aStatusRaw, array, Eventos brutos de mudanca de status.
@return aPeriods, array, Lista de periodos pronta para serializacao.
/*/
Static Function MONTPERD(aStatusRaw)
	
	Local aPeriods  := {}
	Local nI        := 0
	Local aEvent    := {}
	Local cValAnt   := ""
	Local cValNov   := ""
	Local cStatus   := ""
	Local cUsrCod   := ""
	Local cUsrNom   := ""
	Local aUsrCache := {}
	Local nCache    := 0
	Local nLnStatus := 0

	Default aStatusRaw := {}

	nLnStatus := Len(aStatusRaw)

	For nI := 1 To nLnStatus
		
		aEvent  := aStatusRaw[nI]
		cValAnt := AllTrim(aEvent[3])
		cValNov := AllTrim(aEvent[4])
		cStatus := IIf(Empty(cValAnt), "ATIVO","BLOQUEADO")
		cUsrCod := AllTrim(aEvent[5])
		cUsrNom := ""

		If !Empty(cUsrCod)
			
			nCache := AScan(aUsrCache, {|x| x[1] == cUsrCod})
			
			If nCache > 0
				cUsrNom := aUsrCache[nCache][2]
			Else
				
				cUsrNom := AllTrim(UsrRetName(cUsrCod))
				AAdd(aUsrCache, {cUsrCod, cUsrNom})
			EndIf
		EndIf

		AAdd(aPeriods, OBJPERIO( ;
			"", ;
			cStatus, ;
			STRDATA(aEvent[3]), ;
			STRDATA(aEvent[4]), ;
			DATATXT(aEvent[1]), ;
			aEvent[2], ;
			cUsrCod, ;
			cUsrNom))
	Next

Return aPeriods

////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} LISTCHJS
Converte a lista de alteracoes brutas para objetos JSON de exibicao.
@since 06/04/2026
@param aChangesRaw, array, Alteracoes brutas lidas do historico.
@return aJson, array, Lista de objetos JSON com as alteracoes.
/*/
Static Function LISTCHJS(aChangesRaw)
	
	Local aJson     := {}
	Local nI        := 0
	Local nLnChang  := 0
	Local aItem     := {}
	Local oItem     := JsonObject():New()
	Local aUsrCache := {}
	Local cUsrNom   := ""

	Default aChangesRaw := {}

	nLnChang  := Len(aChangesRaw)

	For nI := 1 To nLnChang
		
		aItem := aChangesRaw[nI]

		If aItem[3] == "BAX_DATBLO"
			Loop
		EndIf

		oItem := JsonObject():New()
		oItem["data"]             := DATATXT(aItem[1])
		oItem["hora"]             := aItem[2]
		oItem["dataHora"]         := DATETIME(aItem[1], aItem[2])
		oItem["campo"]            := aItem[3]
		oItem["descricaoCampo"]   := DESCAMP(aItem[3])
		oItem["campoLabel"]       := ROTCAMPO(aItem[3])
		oItem["valorAnterior"]    := FMTVALOR(aItem[10], aItem[4])
		oItem["valorNovo"]        := FMTVALOR(aItem[10], aItem[5])
		
		oItem["usuario"]          := aItem[6]
		cUsrNom := NOMEUSR(aItem[6], @aUsrCache)
		
		oItem["nomeUsuario"]      := cUsrNom
		oItem["evento"]           := aItem[7]
		oItem["sequencia"]        := aItem[8]
		oItem["tipoEvento"]       := aItem[9]
		oItem["tipoEventoLabel"]  := ROTEVTO(aItem[9])
		oItem["tipoCampo"]        := aItem[10]
		oItem["tipoCampoLabel"]   := ROTTPCAM(aItem[10])
		oItem["destaqueStatus"]   := aItem[11]
		oItem["statusResultante"] := IIf(aItem[11], STATBLOQ(aItem[5]), "")

		AAdd(aJson, oItem)
	Next

Return aJson

////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} OBJPERIO
Monta o objeto JSON com os dados de um periodo de status da especialidade.
@since 06/04/2026
@param cCodEsp, caractere, Codigo da especialidade do historico.
@param cStatus, caractere, Status resultante do periodo.
@param cValorAnt, caractere, Valor anterior do status.
@param cValorNov, caractere, Valor atualizado do status.
@param cDataAlt, caractere, Data da alteracao formatada.
@param cHoraAlt, caractere, Hora da alteracao.
@param cUsrCod, caractere, Codigo do usuario responsavel.
@param cUsrNom, caractere, Nome do usuario responsavel.
@return oPeriod, objeto, Objeto JSON com os dados do periodo.
/*/
Static Function OBJPERIO(cCodEsp, cStatus, cValorAnt, cValorNov, cDataAlt, cHoraAlt, cUsrCod, cUsrNom)
	
	Local oPeriod := JsonObject():New()

	oPeriod["codEspecialidade"] := AllTrim(cCodEsp)
	oPeriod["status"]          := cStatus
	oPeriod["valorAnterior"]   := cValorAnt
	oPeriod["valorAtualizado"] := cValorNov
	oPeriod["dataAlteracao"]   := cDataAlt
	oPeriod["horaAlteracao"]   := cHoraAlt
	oPeriod["codUsuario"]      := cUsrCod
	oPeriod["nomeUsuario"]     := cUsrNom

Return oPeriod

////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} NOVRESP
Cria o objeto padrao de resposta utilizado pelo historico da especialidade.
@since 06/04/2026
@return oResp, objeto, Objeto JSON inicializado com a estrutura padrao.
/*/
Static Function NOVRESP()
	Local oResp := JsonObject():New()
	Local oFilt := JsonObject():New()

	oFilt["codigo"] := ""
	oFilt["codint"] := ""
	oFilt["codloc"] := ""
	oFilt["codesp"] := ""
	oFilt["codsub"] := ""

	oResp["success"] := .F.
	oResp["message"] := ""
	oResp["filter"] := oFilt
	oResp["periods"] := {}
	oResp["changes"] := {}

Return oResp

////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} ROTCAMPO
Traduz o nome tecnico do campo para um rotulo amigavel.
@since 06/04/2026
@param cCampo, caractere, Nome tecnico do campo.
@return cRotulo, caractere, Rotulo amigavel do campo.
/*/
Static Function ROTCAMPO(cCampo)
	
	Local cDescri := ""

	Default cCampo := ""
	
	Do Case
		Case cCampo == "BAX_CODESP"
			cDescri := "Especialidade"
		
		Case cCampo == "BAX_DATINC"
			cDescri :=  "Data de Inclusão"
		
		Case cCampo == "BAX_DATBLO"
			cDescri := "Data de Bloqueio"
		
		Case cCampo == "BAX_GUIMED"
			cDescri := "Guia médico"
		
		Case cCampo == "BAX_VALCH"
			cDescri := "Valor CH"
		
		Case cCampo == "BAX_VIGDE"
			cDescri := "Inicio da vigência"
		
		Case cCampo == "BAX_FORMUL"
			cDescri := "Formula"
		
		Case cCampo == "BAX_EXPRES"
			cDescri := "Expressão"
		
		Case cCampo == "BAX_CONESP"
			cDescri := "Consulta especial"
		
		Case cCampo == "BAX_LIMATM"
			cDescri := "Limita atendimento"
		
		Case cCampo == "BAX_ORDPES"
			cDescri := "Ordem pesquisa"
		
		Case cCampo == "BAX_ESPPRI"
			cDescri := "Especialidade principal"
		
		Case cCampo == "BAX_BANDA"
			cDescri := "Banda"
		
		Case cCampo == "BAX_UCO"
			cDescri := "UCO"
		
		Case cCampo == "BAX_CODREA"
			cDescri := "Código da regra"
		
		Case cCampo == "BAX_RECREA"
			cDescri := "Regra de autorização"
		
		Case cCampo == "BAX_AUPREV"
			cDescri := "Autorização prévia"
		
		Case cCampo == "BAX_LIDIAR"
			cDescri := "Limiar"
	EndCase

Return cDescri

////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} DESCAMP
Busca a descricao do campo no SX3 e aplica fallback para o rotulo padrao.
@since 06/04/2026
@param cCampo, caractere, Nome tecnico do campo.
@return cDesc, caractere, Descricao do campo para exibicao.
/*/
Static Function DESCAMP(cCampo)
	
	Local cDesc := ""

	Default cCampo := ""

	If Empty(cCampo)
		Return ""
	EndIf

	cDesc := AllTrim(GetSX3Cache(cCampo, "X3_TITULO"))

	If Empty(cDesc)
		cDesc := ROTCAMPO(cCampo)
	EndIf

Return cDesc

////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} ROTEVTO
Traduz o tipo do evento historico para um texto amigavel.
@since 06/04/2026
@param cTipo, caractere, Tipo do evento registrado.
@return cRotulo, caractere, Descricao do tipo de evento.
/*/
Static Function ROTEVTO(cTipo)
	
	Local cEvnt := ""

	Do Case
		Case cTipo == "1" 
			cEvnt := "Inclusão"
		
		Case cTipo == "2" 
			cEvnt := "Alteração"
	EndCase

Return cEvnt

////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} ROTTPCAM
Traduz o tipo do campo historico para um texto amigavel.
@since 06/04/2026
@param cTipo, caractere, Tipo do campo registrado.
@return cRotulo, caractere, Descricao do tipo de campo.
/*/
Static Function ROTTPCAM(cTipo)
	
	Local cTpCmpo := ""

	Do Case
		Case cTipo == "1"
			cTpCmpo := "Caracter"
		
		Case cTipo == "2"
			cTpCmpo := "Data"
		
		Case cTipo == "3"
			cTpCmpo := "Numérico"
	EndCase

Return cTpCmpo

////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} ORDCHANG
Ordena a lista de alteracoes brutas pela chave cronologica do evento.
@since 06/04/2026
@param aChangesRaw, array, Lista de alteracoes que sera ordenada.
@return Nil, nil, Nao retorna valor.
/*/
Static Function ORDCHANG(aChangesRaw)
	
	If Len(aChangesRaw) > 1
		ASort(aChangesRaw,,, {|x, y| CHAVEORD(x[1], x[2], x[7], x[8]) < CHAVEORD(y[1], y[2], y[7], y[8]) })
	EndIf
Return

////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} ORDSTATS
Ordena a lista de status brutos pela chave cronologica do evento.
@since 06/04/2026
@param aStatusRaw, array, Lista de eventos de status que sera ordenada.
@return Nil, nil, Nao retorna valor.
/*/
Static Function ORDSTATS(aStatusRaw)
	
	If Len(aStatusRaw) > 1
		ASort(aStatusRaw,,, {|x, y| CHAVEORD(x[1], x[2], x[6], 0) < CHAVEORD(y[1], y[2], y[6], 0) })
	EndIf
Return

////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} CHAVEORD
Monta a chave usada para ordenar eventos do historico.
@since 06/04/2026
@param dData, data, Data do evento.
@param cHora, caractere, Hora do evento.
@param cEvento, caractere, Codigo do evento.
@param nSeq, numerico, Sequencia do evento.
@return cChave, caractere, Chave de ordenacao cronologica.
/*/
Static Function CHAVEORD(dData, cHora, cEvento, nSeq)
Return Dtos(dData) + cHora + cEvento + StrZero(nSeq, 6)

////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} STATBLOQ
Retorna o status de bloqueio com base na data informada.
@since 06/04/2026
@param cDatBlo, caractere, Data de bloqueio do evento.
@return cStatus, caractere, Status derivado da data de bloqueio.
/*/
Static Function STATBLOQ(cDatBlo)
Return STATUAL(cDatBlo)

////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} DATBASE
Define a data base da especialidade usando inclusao, bloqueio ou a data atual.
@since 06/04/2026
@param dDatInc, data, Data de inclusao da especialidade.
@param dDatBlo, data, Data de bloqueio da especialidade.
@return dRet, data, Data base escolhida para a especialidade.
/*/
Static Function DATBASE(dDatInc, dDatBlo)
	
	If !Empty(dDatInc)
		Return dDatInc
	EndIf

	If !Empty(dDatBlo)
		Return dDatBlo
	EndIf

Return dDataBase

////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} DIASENTR
Calcula a quantidade de dias entre duas datas validas.
@since 06/04/2026
@param dStart, data, Data inicial do intervalo.
@param dEnd, data, Data final do intervalo.
@return nDias, numerico, Quantidade de dias entre as datas.
/*/
Static Function DIASENTR(dStart, dEnd)
	
	If Empty(dStart) .Or. Empty(dEnd) .Or. dEnd < dStart
		Return 0
	EndIf

Return dEnd - dStart

////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} DATATXT
Formata uma data para o padrao textual AAAA-MM-DD.
@since 06/04/2026
@param dDate, qualquer, Data ou conteudo equivalente a ser formatado.
@return cDate, caractere, Data formatada para exibicao.
/*/
Static Function DATATXT(dDate)
	
	Local cDate := ""

	If Empty(dDate)
		Return ""
	EndIf

	If ValType(dDate) == "D"
		cDate := Dtos(dDate)
	
	ElseIf ValType(dDate) == "C"
		cDate := AllTrim(dDate)
		cDate := StrTran(cDate, "-", "")
		cDate := StrTran(cDate, "/", "")
	Else
		Return ""
	EndIf

	If Len(cDate) <> 8
		Return ""
	EndIf

Return SubStr(cDate, 1, 4) + "-" + SubStr(cDate, 5, 2) + "-" + SubStr(cDate, 7, 2)

////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} DATACHAV
Converte uma data em chave textual no formato AAAAMMDD.
@since 06/04/2026
@param dDate, data, Data que sera convertida.
@return cChave, caractere, Chave textual da data.
/*/
Static Function DATACHAV(dDate)
	
	If Empty(dDate)
		Return ""
	EndIf

Return Dtos(dDate)

////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} STRDATA
Normaliza uma data recebida como texto ou tipo data para o formato AAAA-MM-DD.
@since 06/04/2026
@param cValue, qualquer, Valor de data que sera normalizado.
@return cDate, caractere, Data normalizada para texto.
/*/
Static Function STRDATA(cValue)
	
	Local cDate := ""

	If ValType(cValue) == "D"
		Return DATATXT(cValue)
	EndIf

	cDate := AllTrim(cValue)

	If Len(cDate) == 8
		Return SubStr(cDate, 1, 4) + "-" + SubStr(cDate, 5, 2) + "-" + SubStr(cDate, 7, 2)
	EndIf

Return cDate

////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} DATETIME
Monta a representacao textual de data e hora do evento.
@since 06/04/2026
@param dDate, data, Data do evento.
@param cTime, caractere, Hora do evento.
@return cDateTime, caractere, Data e hora concatenadas.
/*/
Static Function DATETIME(dDate, cTime)
	
	Local cDate := DATATXT(dDate)

Return AllTrim(cDate + " " + AllTrim(cTime))

////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} FMTVALOR
Formata o valor do historico conforme o tipo do campo informado.
@since 06/04/2026
@param cType, caractere, Tipo do campo historico.
@param cValue, caractere, Valor do campo a ser formatado.
@return cRet, caractere, Valor tratado para exibicao.
/*/
Static Function FMTVALOR(cType, cValue)
	
	If cType == "2" //data
		Return STRDATA(cValue)
	EndIf

Return AllTrim(cValue)

////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} GETCONTX
Serializa o contexto atual da consulta para envio ao front-end.
@since 06/04/2026
@return cContext, caractere, Contexto atual separado por pipe.
/*/
Static Function GETCONTX()
Return aBlvUiCtx[1] + "|" + aBlvUiCtx[2] + "|" + aBlvUiCtx[3] + "|" + aBlvUiCtx[4]

////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} SPLITFLT
Separa o filtro serializado em ate cinco partes.
@since 06/04/2026
@param cContent, caractere, Conteudo serializado do filtro.
@return aParts, array, Partes do filtro separadas por pipe.
/*/
Static Function SPLITFLT(cContent)
	
	Local aParts := {"", "", "", "", ""}
	Local cWork  := cContent
	Local nAt    := 0
	Local nIndex := 1

	Default cContent := ""

	For nIndex := 1 To 5
		nAt := At("|", cWork)

		If nAt > 0
			aParts[nIndex] := SubStr(cWork, 1, nAt - 1)
			cWork := SubStr(cWork, nAt + 1)
		Else
			aParts[nIndex] := cWork
			Exit
		EndIf
	Next

Return aParts
