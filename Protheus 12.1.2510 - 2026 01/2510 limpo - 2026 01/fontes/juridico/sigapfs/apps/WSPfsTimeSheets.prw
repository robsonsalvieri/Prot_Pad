#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "WSPFSTIMESHEETS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WSPfsTimeSheets
Métodos WS para Time Sheets

@author Rebeca Facchinato Asunção
@since 29/01/2024
@version 1.0
/*/
//-------------------------------------------------------------------
WSRESTFUL WSPfsTimeSheets DESCRIPTION STR0001 // "Webservice para Time Sheets"

	WSDATA pageSize     as Number
	WSDATA page         as Number

	WSMETHOD POST ReValTS  DESCRIPTION STR0006 PATH "revalorizarTimeSheet" PRODUCES APPLICATION_JSON // "Revalorizar Time Sheet"
	WSMETHOD POST DivTS    DESCRIPTION STR0008 PATH "dividirTimeSheet"     PRODUCES APPLICATION_JSON // "Dividir Time Sheet"
	WSMETHOD POST tsFromWo DESCRIPTION STR0010 PATH "woTimeSheet"          PRODUCES APPLICATION_JSON // "Wo em lote de Timesheet"
	WSMETHOD POST tsOpLote DESCRIPTION STR0011 PATH "opLoteTimeSheet"      PRODUCES APPLICATION_JSON // "Operação em lote de Timesheet"

	WSMETHOD PUT ListTS DESCRIPTION STR0002 PATH "listaTimeSheets" PRODUCES APPLICATION_JSON // "Busca a lista de Time Sheets"
	WSMETHOD PUT lsNRC  DESCRIPTION STR0003 PATH "tipoAtividade"   PRODUCES APPLICATION_JSON // "Tipo de atividade de timesheet"
	WSMETHOD PUT lsNRZ  DESCRIPTION STR0004 PATH "tarefaEBilling"  PRODUCES APPLICATION_JSON // "Tarefa documento E-billing "

End WSRESTFUL	

//-------------------------------------------------------------------
/*/{Protheus.doc} PUT ListTS
Retorna a lista de Times heets de acordo com os filtros

@param pageSize - Quantidade de itens por página
@param page     - Número da página

@example POST -> http://localhost:12173/rest/WSPfsTimeSheets/listaTimeSheets?page=1&pageSize=10
@body - Exemplo de body da requisição:
			{
				"dataIni": "20200215",
				"dataFim": "20240222",
				"status": "1",
				"fatura": "415",
				"preFatura": "",
				"clienteCaso": [],
				"partLanc": "000196",
				"partRev": "000348"
				"codigoTS": "000000000835"
			}
@author Rebeca Facchinato Asunção
@since 29/01/2024
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD PUT ListTS QUERYPARAM pageSize, page WSREST WSPfsTimeSheets
Local oJsonBody   := JsonObject():new()
Local oResponse   := JsonObject():New()
Local oTS         := Nil
Local oQryTotalTS := Nil
Local cAlias      := GetNextAlias()
Local cQuery      := ""
Local cQryQtd     := ""
Local cGrpCli     := ""
Local cPartRev    := ""
Local cPartLan    := ""
Local lRet        := .T.
Local aParams     := {}
Local aAux        := {}
Local aClientes   := {}
Local nNumReg     := 0
Local nParam      := 0
Local nTotal      := 0
Local nI          := 0
Local lLojaAuto   := SuperGetMv("MV_JLOJAUT", .F., "2",) == '1' // Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local aPaginacao  := {}

Default Self:page     := 1
Default Self:pageSize := 10

	aPaginacao := JStPagSize(Self:page, Self:pageSize)
	cBody := StrTran(Self:GetContent(),CHR(10),"")
	oJsonBody:fromJson(cBody)

	If ValType(oJsonBody) <> "U"
		cQuery := WSPFSListTS(oJsonBody, lLojaAuto)

		// Guarda a query para buscar qtd de registros
		cQryQtd := cQuery

		cQuery += " ORDER BY NUE_DATATS DESC"
		cQuery := ChangeQuery(cQuery)

		aAdd(aParams, xFilial("NVE"))

		If oJsonBody:hasProperty('dataIni') .AND. !Empty(oJsonBody['dataIni']) .AND. !Empty(oJsonBody['dataFim'])
			aAdd(aParams, oJsonBody['dataIni'])
			aAdd(aParams, oJsonBody['dataFim'])
		EndIf

		If oJsonBody:hasProperty('status') .AND. oJsonBody['status'] $ "2|3"
			aAdd(aParams, oJsonBody['status'])
		EndIf

		If oJsonBody:hasProperty('fatura') .AND. !Empty(oJsonBody['fatura'])
			aAux := JSetZeroL(GetSx3Cache("NW0_CFATUR","X3_TAMANHO"), oJsonBody['fatura'])
			For nI := 1 To Len(aAux)
				aAdd(aParams, aAux[nI])
			Next nI
			aSize(aAux, 0)
		EndIf

		If oJsonBody:hasProperty('preFatura') .AND. !Empty(oJsonBody['preFatura'])
			aAux := JSetZeroL(GetSx3Cache("NW0_PRECNF","X3_TAMANHO"), oJsonBody['preFatura'])
			For nI := 1 To Len(aAux)
				aAdd(aParams, aAux[nI])
			Next nI
			aSize(aAux, 0)
		EndIf

		If oJsonBody:hasProperty('clienteCaso') .AND. !Empty(oJsonBody['clienteCaso'])
			aClientes := aClone(oJsonBody['clienteCaso'])

			// Fitro cliente e caso
			If Len(aClientes) > 0
				For nI := 1 To Len(aClientes)
					aAdd(aParams, aClientes[nI]['cliente'])

					If !lLojaAuto
						aAdd(aParams, aClientes[nI]['loja'])
					EndIf

					If !Empty(aClientes[nI]['caso'])
						aAdd(aParams, aClientes[nI]['caso'])
					EndIf
				Next nI
			EndIf
			aSize(aClientes, 0)
		EndIf

		If oJsonBody:hasProperty('partLanc') .AND. !Empty(oJsonBody['partLanc'])
			aAux := JSetZeroL(GetSx3Cache("RD0_CODIGO","X3_TAMANHO"), oJsonBody['partLanc'])
			For nI := 1 To Len(aAux)
				aAdd(aParams, aAux[nI])
			Next nI
			aSize(aAux, 0)
		EndIf

		If oJsonBody:hasProperty('partRev') .AND. !Empty(oJsonBody['partRev'])
			aAux := JSetZeroL(GetSx3Cache("RD0_CODIGO","X3_TAMANHO"), oJsonBody['partRev'])
			For nI := 1 To Len(aAux)
				aAdd(aParams, aAux[nI])
			Next nI
			aSize(aAux, 0)
		EndIf

		If oJsonBody:hasProperty('codigoTS') .AND. !Empty(oJsonBody['codigoTS'])
			aAux := JSetZeroL(GetSx3Cache("NUE_COD","X3_TAMANHO"), oJsonBody['codigoTS'])
			For nI := 1 To Len(aAux)
				aAdd(aParams, aAux[nI])
			Next nI
			aSize(aAux, 0)
		EndIf

		If VALTYPE(Self:page) == "C"
			Self:page := VAL(Self:page)
		EndIf

		If VALTYPE(Self:pageSize) == "C"
			Self:pageSize := VAL(Self:pageSize)
		EndIf

		oResponse['timeSheets'] := {}
		oResponse['hasNext'] := .F.

		oTS := FWPreparedStatement():New(cQuery)
		oQryTotalTS := FWPreparedStatement():New(cQryQtd)

		For nParam := 1 To Len(aParams)
			If ValType(aParams[nParam]) == "C"
				oTS:SetString(nParam, aParams[nParam])
				oQryTotalTS:SetString(nParam, aParams[nParam])
			EndIf
		Next nParam

		cQuery := oTS:GetFixQuery()

		MpSysOpenQuery(cQuery, cAlias)

		While (cAlias)->(!EoF())
			nNumReg++
			If (aPaginacao[1] .and. nNumReg > aPaginacao[3])
				oResponse['hasNext'] := .T.
				Exit
			ElseIf (!aPaginacao[1] .Or. ;
					(aPaginacao[1] .And. nNumReg > aPaginacao[2] .And. nNumReg <= aPaginacao[3]))

				aAdd(oResponse['timeSheets'], JSonObject():New())
				aTail(oResponse['timeSheets'])['pk']           := Encode64((cAlias)->NUE_FILIAL + (cAlias)->NUE_COD)
				aTail(oResponse['timeSheets'])['filial']       := (cAlias)->NUE_FILIAL
				aTail(oResponse['timeSheets'])['dataTS']       := (cAlias)->NUE_DATATS

				If !Empty((cAlias)->NUE_CGRPCL)
					cGrpCli := JConvUTF8((cAlias)->NUE_CGRPCL + " - " + (cAlias)->NUE_DGRPCL)
				EndIf

				aTail(oResponse['timeSheets'])['grupoTS'] := cGrpCli
				aTail(oResponse['timeSheets'])['cliente'] := Alltrim((cAlias)->NUE_CCLIEN)

				If !lLojaAuto
					aTail(oResponse['timeSheets'])['cliente'] := aTail(oResponse['timeSheets'])['cliente'] + " - " + (cAlias)->NUE_CLOJA
				EndIf

				aTail(oResponse['timeSheets'])['cliente'] += " - " + JConvUTF8((cAlias)->NUE_DCLIEN)

				If !Empty((cAlias)->NUE_SIGLA2)
					cPartRev := JConvUTF8(Alltrim((cAlias)->NUE_SIGLA2) + " - " + (cAlias)->NUE_DPART2)
				EndIf

				aTail(oResponse['timeSheets'])['caso']          := JConvUTF8(Alltrim((cAlias)->NUE_CCASO) + " - " + (cAlias)->NUE_DCASO)
				aTail(oResponse['timeSheets'])['partRevisado']  := cPartRev
				aTail(oResponse['timeSheets'])['situacao']      := (cAlias)->NUE_SITUAC
				aTail(oResponse['timeSheets'])['codigo']        := (cAlias)->NUE_COD

				If !Empty((cAlias)->NUE_SIGLA1)
					cPartLan := JConvUTF8(Alltrim((cAlias)->NUE_SIGLA1) + " - " + (cAlias)->NUE_DPART1)
				EndIf

				aTail(oResponse['timeSheets'])['partLancado']   := cPartLan
				aTail(oResponse['timeSheets'])['tipoAtividade'] := JConvUTF8(AllTrim((cAlias)->NUE_CATIVI) + " - " + (cAlias)->NUE_DATIVI)
				aTail(oResponse['timeSheets'])['descricao']     := JConvUTF8((cAlias)->NUE_DESCR)
				aTail(oResponse['timeSheets'])['codPreFatura']  := (cAlias)->NUE_CPREFT

				// Busca situação de faturamento do TimeSheet
				aTail(oResponse['timeSheets'])['faturamento']          := JWSTSNW0((cAlias)->NUE_COD)
				aTail(oResponse['timeSheets'])['codUsuarioInclusao']   := (cAlias)->NUE_CUSERA
				aTail(oResponse['timeSheets'])['siglaUsuarioInclusao'] := JConvUTF8(JA202DPART("1", (cAlias)->NUE_CUSERA))
				aTail(oResponse['timeSheets'])['NomeUsuarioInclusao']  := JConvUTF8(JA202DPART("2", (cAlias)->NUE_CUSERA))
				aTail(oResponse['timeSheets'])['utLancada']            := (cAlias)->NUE_UTL
				aTail(oResponse['timeSheets'])['utRevisada']           := (cAlias)->NUE_UTR
				aTail(oResponse['timeSheets'])['utProdutiva']          := (cAlias)->NUE_UTP
				aTail(oResponse['timeSheets'])['hhmmLancada']          := (cAlias)->NUE_HORAL
				aTail(oResponse['timeSheets'])['hhmmRevisada']         := (cAlias)->NUE_HORAR
				aTail(oResponse['timeSheets'])['hhmmProdutiva']        := (cAlias)->NUE_HORAP
				aTail(oResponse['timeSheets'])['tempoLancado']         := (cAlias)->NUE_TEMPOL
				aTail(oResponse['timeSheets'])['tempoRevisado']        := (cAlias)->NUE_TEMPOR
				aTail(oResponse['timeSheets'])['tempoProdutivo']       := (cAlias)->NUE_TEMPOP
			EndIf
			(cAlias)->( dbSkip() )
		EndDo
	EndIf

	nTotal := JTSQtdSql(oQryTotalTS:GetFixQuery())
	oResponse['total']   := nTotal
	oResponse['qtd']     := Len(oResponse['timeSheets'])

	(cAlias)->( DbCloseArea() )
	aSize(aParams, 0)
	aSize(aAux, 0)
	aSize(aClientes, 0)
	aParams   := Nil
	aAux      := Nil
	aClientes := Nil

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := Nil
	oJsonBody := Nil
	oTS       := Nil

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} WSPFSListTS
Monta a Query para buscar a lista de time sheets

@param oDados    - Objeto com os filtros selecionados
@param lLojaAuto - Indica se há configuração e loja automática
@author Rebeca Facchinato Asunção
@since 29/01/2024
/*/
//-------------------------------------------------------------------
Function WSPFSListTS(oDados, lLojaAuto)
Local cQuery     := ""
Local cDataIni   := oDados["dataIni"]
Local cDataFim   := oDados["dataFim"]
Local cStatus    := oDados["status"]
Local cFatura    := oDados["fatura"]
Local cPreFatura := oDados["preFatura"]
Local cPartLan   := oDados["partLanc"]
Local cPartRev   := oDados["partRev"]
Local cCodigoTS  := oDados["codigoTS"]
Local cCliAux    := ""
Local cLojAux    := ""
Local cCasAux    := ""
Local aClientes  := oDados["clienteCaso"]
Local aAux       := {}
Local nI         := 0
Local nTotal     := 0

	cQuery += " SELECT NUE_FILIAL,"
	cQuery +=        " NUE_DATATS,"
	cQuery +=        " NUE_CGRPCL,"
	cQuery +=        " COALESCE(ACY.ACY_DESCRI,' ') NUE_DGRPCL,"
	cQuery +=        " NUE_CCLIEN,"
	cQuery +=        " NUE_CLOJA,"
	cQuery +=        " A1_NOME NUE_DCLIEN,"
	cQuery +=        " NUE_CCASO,"
	cQuery +=        " NVE_TITULO NUE_DCASO,"
	cQuery +=        " COALESCE(RD0REV.RD0_SIGLA,' ') NUE_SIGLA2,"
	cQuery +=        " COALESCE(RD0REV.RD0_NOME,' ') NUE_DPART2,"
	cQuery +=        " NUE_SITUAC,"
	cQuery +=        " NUE_COD,"
	cQuery +=        " COALESCE(RD0LAN.RD0_SIGLA,' ') NUE_SIGLA1,"
	cQuery +=        " COALESCE(RD0LAN.RD0_NOME,' ') NUE_DPART1,"
	cQuery +=        " NUE_CATIVI,"
	cQuery +=        " NRC_DESC NUE_DATIVI,"
	cQuery +=        " NS7_NOME NUE_DESCR,"
	cQuery +=        " NUE_UTL,"
	cQuery +=        " NUE_UTR,"
	cQuery +=        " NUE_UTP,"
	cQuery +=        " NUE_HORAL,"
	cQuery +=        " NUE_HORAR,"
	cQuery +=        " NUE_HORAP,"
	cQuery +=        " NUE_TEMPOL,"
	cQuery +=        " NUE_TEMPOR,"
	cQuery +=        " NUE_TEMPOP,"
	cQuery +=        " NUE_CUSERA,"
	cQuery +=        " NUE_CPREFT"
	cQuery += " FROM " + RetSqlName("NUE") + " NUE"

	// Grupo de clientes"
	cQuery +=  " LEFT JOIN " + RetSqlName("ACY") + " ACY"
	cQuery +=       " ON (ACY.ACY_GRPVEN = NUE_CGRPCL"
	cQuery +=       " AND ACY.D_E_L_E_T_ = ' ' )"

	//  Cliente"
	cQuery +=  " INNER JOIN " + RetSqlName("SA1") + " SA1"
	cQuery +=     " ON (SA1.A1_COD = NUE.NUE_CCLIEN"
	cQuery +=    " AND SA1.A1_LOJA = NUE.NUE_CLOJA"
	cQuery +=    " AND SA1.D_E_L_E_T_ = ' ' )"

	//  Caso"
	cQuery +=  " INNER JOIN " + RetSqlName("NVE") + " NVE"
	cQuery +=     " ON (NVE.NVE_FILIAL = ?"
	cQuery +=    " AND NVE.NVE_CCLIEN = NUE.NUE_CCLIEN"
	cQuery +=    " AND NVE.NVE_LCLIEN = NUE.NUE_CLOJA"
	cQuery +=    " AND NVE.NVE_NUMCAS = NUE.NUE_CCASO"
	cQuery +=    " AND NVE.D_E_L_E_T_ = ' ' )"

	//  Participante revisado"
	cQuery +=  " LEFT JOIN " + RetSqlName("RD0") + " RD0REV"
	cQuery +=    " ON (RD0REV.RD0_CODIGO = NUE.NUE_CPART2"
	cQuery +=   " AND RD0REV.D_E_L_E_T_ = ' ')"

	//  Participante lançado  "
	cQuery +=  " LEFT JOIN " + RetSqlName("RD0") + " RD0LAN"
	cQuery +=    " ON (RD0LAN.RD0_CODIGO = NUE.NUE_CPART1"
	cQuery +=   " AND RD0LAN.D_E_L_E_T_ = ' ')"

	//  Atividade"
	cQuery +=  " INNER JOIN " + RetSqlName("NRC") + " NRC"
	cQuery +=  " ON(NRC.NRC_COD = NUE.NUE_CATIVI"
	cQuery +=  " AND NRC.D_E_L_E_T_ = ' ')"

	//  Escritório"
	cQuery +=  " INNER JOIN " + RetSqlName("NS7") + " NS7"
	cQuery +=     " ON (NS7.NS7_COD = NUE.NUE_CESCR"
	cQuery +=    " AND NS7.D_E_L_E_T_ = ' ')"
	cQuery += " WHERE NUE.D_E_L_E_T_ = ' '"

	// Filtro de datas
	If !Empty(cDataIni) .AND. !Empty(cDataFim)
		cQuery += " AND NUE_DATATS BETWEEN ? AND ?"
	EndIf

	// Filtro de situação
	If !Empty(cStatus)
		Do case
			Case cStatus == "1"  // Pendente
				cQuery += " AND (NUE_SITUAC = '1')"

			Case cStatus $ "2|3"  // Faturado / WO
				cQuery += " AND EXISTS ("
				cQuery +=               " SELECT NW0.NW0_CTS"
				cQuery +=                 " FROM " + RetSqlName("NW0") + " NW0"
				cQuery +=                " WHERE NW0.NW0_CTS = NUE.NUE_COD"
				cQuery +=                  " AND NW0.NW0_SITUAC = ?"
				cQuery +=                  " AND NW0.NW0_CANC <> '1'"   // Cancelado? 1=Sim / 2=Não
				cQuery +=                  " AND NW0.D_E_L_E_T_ = ' '"
				cQuery += " )"
		EndCase
	EndIf

	// Filtro Fatura / Pré fatura
	If !Empty(cFatura) .OR. !Empty(cPreFatura)
		cQuery += " AND EXISTS ("
		cQuery +=               " SELECT NW0.NW0_CTS"
		cQuery +=                 " FROM " + RetSqlName("NW0") + " NW0"
		cQuery +=                " WHERE NW0.NW0_CTS = NUE.NUE_COD"
		cQuery +=                  " AND NW0.D_E_L_E_T_ = ' '"

		// Fatura
		If !Empty(cFatura)
			aAux   := STRTOKARR(cFatura, ",")
			nTotal := Len(aAux)
			cQuery += " AND (NW0.NW0_CFATUR = ?"
			For nI := 1 To nTotal
				If nI > 1 .AND. nI <= nTotal
					cQuery +=  " OR NW0.NW0_CFATUR = ?"
				EndIf
			Next
			cQuery += " )"
		EndIf

		// Pre fatura
		If !Empty(cPreFatura)
			aAux   := STRTOKARR(cPreFatura, ",")
			nTotal := Len(aAux)
			cQuery += " AND (NW0.NW0_PRECNF = ?"
			For nI := 1 To nTotal
				If nI > 1 .AND. nI <= nTotal
					cQuery +=  " OR NW0.NW0_PRECNF = ?"
				EndIf
			Next
			cQuery += " )"
		EndIf

		cQuery += " )"
	EndIf

	// Fitro cliente
	If Len(aClientes) > 0
		cQuery += " AND ("
		For nI := 1 To Len(aClientes)

			If nI > 1 .AND. nI <= Len(aClientes)
				If cCliAux == aClientes[nI]["cliente"];
					.AND. cLojAux == aClientes[nI]["loja"];
					.AND. (Empty(cCasAux) .OR. Empty(aClientes[nI]["caso"]))
					cQuery += " AND "
				Else
					cQuery += " OR "
				EndIf 
			EndIf

			cQuery += " (NUE_CCLIEN = ?"

			If lLojaAuto
				cQuery += " AND NUE_CLOJA = '01'"
			Else
				cQuery += " AND NUE_CLOJA = ?"
			EndIf

			If !Empty(aClientes[nI]['caso'])
				cQuery += " AND  NUE_CCASO = ?"
			EndIf
			cQuery += ")"

			cCliAux := aClientes[nI]["cliente"]
			cLojAux := aClientes[nI]["loja"]
			cCasAux := aClientes[nI]["caso"]
		Next nI
		cQuery += ") "
	EndIf

	// Filtro Participante lançado
	If !Empty(cPartLan)
		aAux   := STRTOKARR(cPartLan, ",")
		nTotal := Len(aAux)
		cQuery += " AND (NUE.NUE_CPART1 = ?"
		For nI := 1 To nTotal
			If nI > 1 .AND. nI <= nTotal
				cQuery +=  " OR NUE.NUE_CPART1 = ?"
			EndIf
		Next
		cQuery += " )"
	EndIf

	// Filtro Participante revisado
	If !Empty(cPartRev)
		aAux   := STRTOKARR(cPartRev, ",")
		nTotal := Len(aAux)
		cQuery += " AND (NUE.NUE_CPART2 = ?"
		For nI := 1 To nTotal
			If nI > 1 .AND. nI <= nTotal
				cQuery +=  " OR NUE.NUE_CPART2 = ?"
			EndIf
		Next
		cQuery += " )"
	EndIf

	// Filtro Código do TimeSheet
	If !Empty(cCodigoTS)
		aAux   := STRTOKARR(cCodigoTS, ",")
		nTotal := Len(aAux)
		cQuery += " AND (NUE.NUE_COD = ?"
		For nI := 1 To nTotal
			If nI > 1 .AND. nI <= nTotal
				cQuery +=  " OR NUE.NUE_COD = ?"
			EndIf
		Next
		cQuery += " )"
	EndIf

Return cQuery


//-------------------------------------------------------------------
/*/{Protheus.doc} lsNRC
Busca os dados da NRC - Tipo de Atividade Time Sheet  

@Body - {
	cliente: {
		codigo: '',
		loja: ''
	},
	caso: '',
	searchKey: '',
	codigo: ''
}

@author Willian Yoshiaki Kazahaya
@since 29/02/2024
/*/
//-------------------------------------------------------------------
WSMETHOD PUT lsNRC WSREST WSPfsTimeSheets
Local lRet       := .T.
Local oJsonBody  := JsonObject():new()
Local oResponse  := JsonObject():New()
Local cAnoMes    := JSToFormat(DToS(Date()), 'YYYYMM')
Local cClien     := ""
Local cLoja      := ""
Local cCaso      := ""
Local cSearchKey := ""
Local cAliasQry  := ""
Local cQuery     := ""
Local nIndex     := 0
Local nI         := 0
Local aCpoSrch   := {"NRC_DESC"}

	cBody := StrTran(Self:GetContent(),CHR(10),"")
	oJsonBody:fromJson(cBody)

	cClien    := oJsonBody['cliente']['codigo']
	cLoja     := oJsonBody['cliente']['loja']
	cCaso     := oJsonBody['caso']
	cSearchKey:= oJsonBody['searchkey']
	cCodAtivi := oJsonBody['codigo']

	cQuery    := J144TpAtv(cClien, cLoja, cCaso, cAnoMes, cCodAtivi, .T.)
	
	if (!Empty(cSearchKey))
		cSearchKey := StrTran( JurLmpCpo( cSearchKey, .F., .F. ), '#', '' )
		For nI := 1 To Len(aCpoSrch)
			cQuery += " AND (LOWER(TRIM(" + aCpoSrch[nI] + ")) LIKE '%" + Lower(Trim(cSearchKey)) + "%' "
			cQuery +=  " OR LOWER(TRIM(" + JurFormat(aCpoSrch[nI], .T./*lAcentua*/) + ")) LIKE '%" + Lower(Trim(cSearchKey)) + "%'"
		Next nI
		cQuery +=  ")"
	EndIf

	oQuery    := FWPreparedStatement():New(cQuery)
	cAliasQry := MPSysOpenQuery(oQuery:GetFixQuery())

	oResponse := {}
	While (cAliasQry)->(!Eof())
		nIndex++
		aAdd(oResponse, JsonObject():New())
		oResponse[nIndex]['codigo']    := (cAliasQry)->NRC_COD
		oResponse[nIndex]['descricao'] := JConvUTF8((cAliasQry)->NRC_DESC)
		(cAliasQry)->(DbSkip())
	EndDo

	(cAliasQry)->(DbCloseArea())

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
	aSize(oResponse, 0)
	oResponse := Nil
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} lsNRZ
Busca os dados da NRZ - Tarefa E-billing

@Body - {
	documento: "", -- Código do Documento ( FK )
	fase: "",
	searchkey: "",
	codigo: ""
}

@author Willian Yoshiaki Kazahaya
@since 29/02/2024
/*/
//-------------------------------------------------------------------
WSMETHOD PUT lsNRZ WSREST WSPfsTimeSheets
Local lRet       := .T.
Local oJsonBody  := JsonObject():new()
Local oResponse  := JsonObject():New()
Local cDoc       := ""
Local cCodFase   := ""
Local cCodigo    := ""
Local cSearchKey := ""
Local cAliasQry  := ""
Local cQuery     := ""
Local nIndex     := 0
Local nI         := 0
Local aCpoSrch   := {"NRZ_DESC"}

	cBody := StrTran(Self:GetContent(),CHR(10),"")
	oJsonBody:fromJson(cBody)

	cDoc      := oJsonBody['documento']
	cCodFase  := oJsonBody['fase']
	cSearchKey:= oJsonBody['searchkey']
	
	cCodigo := oJsonBody['codigo']
	
	cQuery := " SELECT NRZ.NRZ_CTAREF, NRZ.NRZ_DESC, NRZ.R_E_C_N_O_ RECNO "
	cQuery +=   " FROM " + RetSqlName("NRZ") + " NRZ"
	cQuery +=  " INNER JOIN " + RetSqlName("NRY") + " NRY"
	cQuery +=     " ON (NRY.NRY_COD = NRZ.NRZ_CFASE
	cQuery +=    " AND NRY.D_E_L_E_T_ = ' ')
	cQuery +=  " WHERE NRZ.NRZ_FILIAL = '" + xFilial("NRZ") + "'"
	cQuery +=    " AND NRZ.NRZ_CDOC = '" + cDoc + "'"
	cQuery +=    " AND NRZ.D_E_L_E_T_ = ' ' "

	If !Empty(cCodigo)
		cQuery +=    "AND NRY.NRY_CFASE = '" + cCodFase + "'"
		cQuery +=    "AND NRZ.NRZ_CTAREF = '" + cCodigo + "'"
	Else
		cQuery +=    " AND NRZ.NRZ_CFASE = '" + cCodFase + "' "
	EndIf
	
	if (!Empty(cSearchKey))
		cSearchKey := StrTran( JurLmpCpo( cSearchKey, .F., .F. ), '#', '' )
		For nI := 1 To Len(aCpoSrch)
			cQuery += " AND (LOWER(TRIM(" + aCpoSrch[nI] + ")) LIKE '%" + Lower(Trim(cSearchKey)) + "%' "
			cQuery +=  " OR LOWER(TRIM(" + JurFormat(aCpoSrch[nI], .T./*lAcentua*/) + ")) LIKE '%" + Lower(Trim(cSearchKey)) + "%'"
		Next nI
		cQuery +=  ")"
	EndIf

	oQuery    := FWPreparedStatement():New(cQuery)
	cAliasQry := MPSysOpenQuery(oQuery:GetFixQuery())

	oResponse := {}
	While (cAliasQry)->(!Eof())
		nIndex++
		aAdd(oResponse, JsonObject():New())
		oResponse[nIndex]['codigo']    := (cAliasQry)->NRZ_CTAREF
		oResponse[nIndex]['descricao'] := JConvUTF8((cAliasQry)->NRZ_DESC)
		(cAliasQry)->(DbSkip())
	EndDo

	(cAliasQry)->(DbCloseArea())

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
	aSize(oResponse, 0)
	oResponse := Nil
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JTSQtdSql
Retorna a quantidade de registros da query.

@param cQuery  - Query principal executada

@author  Rebeca Facchinato Asunção
@since 22/02/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Function JTSQtdSql(cQuery)
Local aArea   := GetArea()
Local cAlias  := GetNextAlias()
Local oTS     := Nil
Local nQuant  := 0
Local cQryTot := ""

	cQryTot := "SELECT COUNT(1) QTD FROM ( ? ) QUANTIDADE"
	
	oTS := FWPreparedStatement():New(cQryTot)
	
	oTs:SetUnsafe(1, cQuery)

	cQryTot := oTS:GetFixQuery()
	MpSysOpenQuery(cQryTot, cAlias)

	If !(cAlias)->( Eof() )
		nQuant := (cAlias)->QTD
	EndIf
	(cAlias)->( DbCloseArea() )

	RestArea(aArea)
	cQryTot := ""

Return nQuant

//-------------------------------------------------------------------
/*/{Protheus.doc} JWSTSNW0
Retorna as informações de faturamento do time sheet

@param  cTimeSheet - Código do time sheet
@author  Rebeca Facchinato Asunção
@since 22/02/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JWSTSNW0(cTimeSheet)
Local cAlias    := GetNextAlias()
Local oNW0      := Nil
Local nIndexObj := 0
Local cQuery    := ""
Local cPreFat   := ""
Local cFatura   := ""
Local cCodEsc   := ""
Local cDescEsc  := ""
Local cWO       := ""
Local aInfoFat  := {}
Local aUsrFlds  := {}

	cQuery += " SELECT NW0_CODUSR,"
	cQuery +=        " NW0_PRECNF,"
	cQuery +=        " NW0_CFATUR,"
	cQuery +=        " NW0_CESCR,"
	cQuery +=        " NW0_CWO,"
	cQuery +=        " NW0_SITUAC,"
	cQuery +=        " NW0_CODUSR,"
	cQuery +=        " NS7_NOME"
	cQuery +=   " FROM " + RetSqlName("NW0") + " NW0"

	// Time sheet
	cQuery +=        " INNER JOIN " + RetSqlName("NUE") + " NUE"
	cQuery +=        " ON NUE.NUE_FILIAL = NW0.NW0_FILIAL"
	cQuery +=        " AND NUE.NUE_COD = NW0.NW0_CTS"
	cQuery +=        " AND NUE.D_E_L_E_T_ = ' '"

	// Escritório
	cQuery +=        " LEFT JOIN " + RetSqlName("NS7") + " NS7"
	cQuery +=        " ON NS7.NS7_FILIAL = NW0.NW0_FILIAL"
	cQuery +=        " AND NS7.NS7_COD = NW0.NW0_CESCR"
	cQuery +=        " AND NS7.D_E_L_E_T_ = ' '"

	cQuery +=  " WHERE NW0.D_E_L_E_T_ = ' '"
	cQuery +=    " AND NW0.NW0_CANC <> '1'"
	cQuery +=    " AND NW0.NW0_CTS = ?"

	cQuery := ChangeQuery(cQuery)

	oNW0 := FWPreparedStatement():New(cQuery)
	oNW0:SetString(1, cTimeSheet)

	cQuery := oNW0:GetFixQuery()
	MpSysOpenQuery(cQuery, cAlias)

	While (cAlias)->(!EoF())
		aUsrFlds := JurUsrFlds((cAlias)->NW0_CODUSR, {"RD0_NOME", "RD0_SIGLA"})
		nIndexObj++

		// Situação em pré fatura
		If !Empty((cAlias)->NW0_PRECNF)
			cPreFat := (cAlias)->NW0_PRECNF
		EndIf

		// Situação em fatura
		If !Empty((cAlias)->NW0_CFATUR)
			cFatura  := (cAlias)->NW0_CFATUR
			cCodEsc  := (cAlias)->NW0_CESCR
			cDescEsc := JConvUTF8((cAlias)->NS7_NOME)
		EndIf

		// Situação em WO
		If !Empty((cAlias)->NW0_CWO)
			cWO := (cAlias)->NW0_CWO
		EndIf

		aAdd(aInfoFat, JSonObject():New())
		aInfoFat[nIndexObj]['codUsuario']     := (cAlias)->NW0_CODUSR
		aInfoFat[nIndexObj]['codSituacao']    := (cAlias)->NW0_SITUAC
		aInfoFat[nIndexObj]['codPreFatura']   := cPreFat
		aInfoFat[nIndexObj]['codFatura']      := cFatura
		aInfoFat[nIndexObj]['codEscritorio']  := cCodEsc
		aInfoFat[nIndexObj]['descEscritorio'] := cDescEsc
		aInfoFat[nIndexObj]['codWO']          := cWO
		aInfoFat[nIndexObj]['codPart']        := (cAlias)->NW0_CODUSR
		aInfoFat[nIndexObj]['nomePart']       := JConvUTF8(aUsrFlds[1])
		aInfoFat[nIndexObj]['slgPart']        := aUsrFlds[2]

		cPreFat  := ""
		cFatura  := ""
		cCodEsc  := ""
		cDescEsc := ""
		cWO      := ""

		(cAlias)->( dbSkip() )
	EndDo

	(cAlias)->( DbCloseArea() )

Return aInfoFat

//-------------------------------------------------------------------
/*/{Protheus.doc} POST ReValTS
Retorna o status da revalorização do Time Sheet

@example POST -> http://localhost:12173/rest/WSPfsTimeSheets/revalorizarTimeSheet
@body - Exemplo de body da requisição:
			{
				"codigoTS": "000000000001"
			}
@author Bruno Henrique Silva Soares
@since 29/02/2024
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD POST ReValTS WSREST WSPfsTimeSheets
Local oJsonBody   := JsonObject():New()
Local oResponse   := JsonObject():New()
Local cBody       := Self:GetContent()
Local cMsg        := ""
Local lRet        := .T.
Local lReval      := .F.

	If !Empty(cBody)
		oJsonBody:FromJson(cBody)
	EndIf

	dbSelectArea("NUE")
	NUE -> (dbSetOrder(1))

	If NUE -> (dbSeek(xFilial("NUE") + oJsonBody["codigoTS"]))
		lReval := JA144REVAL(oJsonBody["codigoTS"], @cMsg)

		oResponse["revaloriza"] := lReval
		oResponse["message"]    := EncodeUTF8(cMsg)
		oResponse["codTS"]      := oJsonBody["codigoTS"]
		Self:SetResponse(oResponse:toJson())
		oResponse:fromJson("{}")
		oResponse := NIL

	Else
		lRet := .F.
		JRestError(400, I18N(STR0007, {oJsonBody["codigoTS"]})) // "O Time Sheet '#1' não foi encontrado"
	EndIf

	NUE -> (dbCloseArea())

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} POST DivTS
Retorna o código do novo Time Sheet após a divisão

@example POST -> http://localhost:12173/rest/WSPfsTimeSheets/dividirTimeSheet
@body - Exemplo de body da requisição:
			{
				"codigoTS": "000000000001",
				"grpCliente": "000001",
				"codCliente": "JLP001",
				"codLoja": "01",
				"codCaso": "000002",
				"sigPart": "CRS  ",
				"valAtuLan": 3.00000000,
				"valAtuRev": 3.00000000,
				"valNewLan": 1.50000000,
				"valNewRev": 1.50000000,
				"descricao": {
					"txtOld": "Descrição antiga",
					"txtNew": "Descrição nova"
				},
				"ebilling": {
					"fase": "001",
					"tarefa": "001",
					"atividade": "001",
					"doc": "001"
				}
			}
@author Bruno Henrique Silva Soares
@since 18/03/2024
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD POST DivTS WSREST WSPfsTimeSheets
Local oJsonBody := JsonObject():New()
Local oResponse := JsonObject():New()
Local aDesc     := {}
Local aEbil     := {}
Local cBody     := Self:GetContent()
Local cMsg      := ""
Local cNewCodTS := ""
Local lRet      := .T.

	If !Empty(cBody)
		oJsonBody:FromJson(cBody)
	EndIf

	dbSelectArea("NUE")
	NUE -> (dbSetOrder(1))

	If NUE -> (dbSeek(xFilial("NUE") + oJsonBody["codigoTS"]))
		If oJsonBody:hasProperty("descricao")
			Aadd(aDesc, DecodeUTF8(oJsonBody["descricao"]["txtOld"]))
			Aadd(aDesc, DecodeUTF8(oJsonBody["descricao"]["txtNew"]))
		EndIf

		If oJsonBody:hasProperty("ebilling")
			Aadd(aEbil, oJsonBody["ebilling"]["fase"])
			Aadd(aEbil, oJsonBody["ebilling"]["tarefa"])
			Aadd(aEbil, oJsonBody["ebilling"]["atividade"])
			Aadd(aEbil, oJsonBody["ebilling"]["doc"])
		EndIf

		cNewCodTS := JA144ETL(oJsonBody["grpCliente"], oJsonBody["codCliente"], oJsonBody["codLoja"], oJsonBody["codCaso"], ;
						oJsonBody["sigPart"], oJsonBody["valAtuLan"], oJsonBody["valAtuRev"], ;
						oJsonBody["valNewLan"], oJsonBody["valNewRev"],,,, @cMsg, aDesc, aEbil)

		oResponse["codOldTS"] := oJsonBody["codigoTS"]
		If ValType(&(cNewCodTS)) == "L"
			oResponse["message"]  := EncodeUTF8(cMsg)
		Else
			oResponse["codNewTS"] := cNewCodTS
		EndIf

		Self:SetResponse(oResponse:toJson())
		oResponse:fromJson("{}")
		oResponse := NIL

	Else
		lRet := .F.
		JRestError(400, I18N(STR0007, {oJsonBody["codigoTS"]})) // "O Time Sheet '#1' não foi encontrado"
	EndIf

	NUE -> (dbCloseArea())

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} POST woTimeSheet
Função POST para alterar em lote os timesheets para WO

@body {
    	"aCodTs": [
    	  "000000000007"      // Array de códigos dos TimeSheets
    	],
    	"cCodMotv": "001",    // Código motivo
    	"cMsgWo": "Teste api" // Mensagem do WO
	}

@author Victor Gonçalves
@since 09/04/2024
/*/
//-------------------------------------------------------------------
WSMETHOD POST tsFromWo WSREST WSPfsTimeSheets
Local lRet       := .T.
Local aResponse  := {}

 	JurSitLoad()	
 	aResponse := JurRtWoTs(Self, "JSON", "wo-ts")

	If !aResponse[1]
		SetRestFault(aResponse[2][1], EncodeUTF8(aResponse[2][2]), , aResponse[2][1], EncodeUTF8(aResponse[2][2]))
		lRet := .F.
	Else
		Self:SetResponse(FWJsonSerialize(aResponse[3], .F., .F., .T.))
		aSize(aResponse, 0)
		aResponse := NIL
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} POST tsOpLote
Função POST para alterar em lote os campos timesheets
@body {
	"loteTS": [
        {
            "codTs": "000000001612", //cod Timesheet
            "cliente": "",           //cod cliente
            "loja": "",              //cod loja
            "caso": "",              //cod caso
            "dataTs": "",            //data Timesheet
            "sigla": "",             //cod sigla
            "ativ": "",              //cod ativ
            "utr": "",               //cod utr
            "retif": "",             //cod retif
            "fase": "",              //cod fase
            "taref": "",             //cod taref
            "atvEbi": "",            //cod atvEbi
            "cobrar": "",            //cod cobrar
            "revisado":"1",          //cod revisado

            "cliOrigem": "VTREBI",   //cod Timesheet
            "lojaOrigem": "01",      //cod cliente origem
            "casoOrigem": "000001",  //cod caso origem
            "dataOrigem": "20240422" //data Timesheet origem
        },
    ]
}
@author Victor Gonçalves
@since 09/04/2024
/*/
//-------------------------------------------------------------------
WSMETHOD POST tsOpLote WSREST WSPfsTimeSheets
Local oBody      := Self:GetContent()
Local oJson      := JSonObject():New()
Local oRet       := JSonObject():New()
Local oResponse  := JSonObject():New()
Local oTsBlq     := JSonObject():New()
Local aTs        := {}
Local aFieldTs   := {}
Local aFieldTsOr := {}
Local nI         := 0

	DbSelectArea("NUE")
	NUE->( DbSetOrder( 1 ) ) //NUE_FILIAL+NUE_COD

	oJson:FromJSon(oBody)
	aTs := oJson['loteTS']
	
	For nI := 1 to Len(aTs)

		oTsBlq := J145VldBlq(aTs[nI]['codTs'],,,StoD(aTs[nI]['dataOrigem']))

		If oTsBlq["codRetorno"] == "1" // 1 = Não está bloqueado
			aFieldTs   := {}
			aFieldTsOr := {}

			Aadd(aFieldTs, aTs[nI]['codTs'])
			Aadd(aFieldTs, "") // grupo de cliente
			Aadd(aFieldTs, aTs[nI]['cliente'])
			Aadd(aFieldTs, aTs[nI]['loja'])
			Aadd(aFieldTs, aTs[nI]['caso'])
			Aadd(aFieldTs, StoD(aTs[nI]['dataTs']))
			Aadd(aFieldTs, aTs[nI]['sigla'])
			Aadd(aFieldTs, aTs[nI]['ativ'])
			Aadd(aFieldTs, aTs[nI]['utr'])
			Aadd(aFieldTs, aTs[nI]['retif'])
			Aadd(aFieldTs, aTs[nI]['fase'])
			Aadd(aFieldTs, aTs[nI]['taref'])
			Aadd(aFieldTs, aTs[nI]['atvEbi'])
			Aadd(aFieldTs, aTs[nI]['cobrar'])
			Aadd(aFieldTs, aTs[nI]['revisado'])

			Aadd(aFieldTsOr, aTs[nI]['cliOrigem'])
			Aadd(aFieldTsOr, aTs[nI]['lojaOrigem'])
			Aadd(aFieldTsOr, aTs[nI]['casoOrigem'])
			Aadd(aFieldTsOr, StoD(aTs[nI]['dataOrigem']))

			oRet := J145OpLtTs(aFieldTs,,,,aFieldTsOr,,.T.)
			
			If oRet['codRetorno'] == "1"
				If !oResponse:hasProperty("sucesso")
					oResponse["sucesso"] := {}
				EndIf
				Aadd(oResponse["sucesso"], oRet)
			Else
				If !oResponse:hasProperty("erro")
					oResponse["erro"] := {}
				EndIf
				Aadd(oResponse["erro"], oRet)
			EndIf
		Else
			If !oResponse:hasProperty("erro")
				oResponse["erro"] := {}
			EndIf

			Aadd(oResponse["erro"], oTsBlq)
		EndIF
		
	Next nI

	aSize(aTs,0)
	aSize(aFieldTs,0)
	aSize(aFieldTsOr,0)

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.
