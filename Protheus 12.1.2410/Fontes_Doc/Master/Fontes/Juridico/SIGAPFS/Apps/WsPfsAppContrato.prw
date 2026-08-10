#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "WSPFSAPPCONTRATO.CH"

WSRESTFUL WSPfsAppContrato DESCRIPTION STR0001 // "Webservice App PFS - Contrato"
	WSDATA chaveContrato    AS STRING
	WSDATA valorDig         AS STRING
	WSDATA filtraAtivo      AS STRING
	WSDATA filtercpo        AS STRING
	WSDATA filterinfo       AS STRING
	WSDATA page             AS NUMBER
	WSDATA pageSize         AS NUMBER
	WSDATA filtraFilial     AS BOOLEAN
	WSDATA count            AS BOOLEAN
	WSDATA lCancSmartUI     AS BOOLEAN
	WSDATA lParcPos         AS BOOLEAN
	WSDATA lWoValido        AS BOOLEAN
	WSDATA cargaAplicacao   AS BOOLEAN

	// Metodos GET
	WSMETHOD GET GrdContratos     DESCRIPTION STR0002 PATH "grid"                            WSSYNTAX "grid"                            PRODUCES APPLICATION_JSON // "Retorna dados de Grid de Contratos"
	WSMETHOD GET GetDetContrato   DESCRIPTION STR0003 PATH "detcontrato/{chaveContrato}"     WSSYNTAX "detcontrato/{chaveContrato}"     PRODUCES APPLICATION_JSON // "Retorna o detalhe do contrato (NT0)"
	WSMETHOD GET PagCtr           DESCRIPTION STR0004 PATH "pagadores/{chaveContrato}"       WSSYNTAX "pagadores/{chaveContrato}"       PRODUCES APPLICATION_JSON // "Retorna dados dos pagadores do contrato(NXP)"
	WSMETHOD GET GrdAtDpNaoCobCtr DESCRIPTION STR0005 PATH "atdpnaocob/{chaveContrato}"      WSSYNTAX "atdpnaocob/{chaveContrato}"      PRODUCES APPLICATION_JSON // "Retorna dados da Grid de tipos de atividades e tipos de despesas não cobráveis do contrato (NTJ, NTK)"
	WSMETHOD GET GetTituloIdioma  DESCRIPTION STR0006 PATH "tituloporidioma/{chaveContrato}" WSSYNTAX "tituloporidioma/{chaveContrato}" PRODUCES APPLICATION_JSON // "Retorna dados da tabela de título do contrato por idioma (NT5)"
	WSMETHOD GET TemPre           DESCRIPTION STR0025 PATH "temPrefatura/{chaveContrato}"    WSSYNTAX "temPrefatura/{chaveContrato}"    PRODUCES APPLICATION_JSON // "Retorna pré-fatura vinculada ao contrato"
	WSMETHOD GET NUTCas           DESCRIPTION STR0023 PATH "casosvinc/{chaveContrato}"       WSSYNTAX "casosvinc/{chaveContrato}"       PRODUCES APPLICATION_JSON // "Lista os casos vinculados ao contrato"
	WSMETHOD GET NW3Ctr           DESCRIPTION STR0024 PATH "ctrvinc/{chaveContrato}"         WSSYNTAX "ctrvinc/{chaveContrato}"         PRODUCES APPLICATION_JSON // "Lista os contratos vinculados ao contrato"
	WSMETHOD GET lsCtr            DESCRIPTION STR0026 PATH "listaContrato"                   WSSYNTAX "listaContrato"                   PRODUCES APPLICATION_JSON // "Busca a lista de contratos"
	WSMETHOD GET CtrSJuncao       DESCRIPTION STR0029 PATH "ctrsemjuncao"                    WSSYNTAX "ctrsemjuncao"                    PRODUCES APPLICATION_JSON // "Busca os contratos que não estão em Junções"
	WSMETHOD GET FaturamentoParc  DESCRIPTION STR0041 PATH "faturamentoParc/{chaveContrato}" WSSYNTAX "faturamentoParc"                 PRODUCES APPLICATION_JSON // "Busca os dados de faturamento das parcelas" (NWE)

	// Método POST
	WSMETHOD POST RevTS           DESCRIPTION STR0007 PATH "revalorizar"                     WSSYNTAX "revalorizar"                     PRODUCES APPLICATION_JSON // "Revaloriza timesheets dos contratos"
	WSMETHOD POST TpHon           DESCRIPTION STR0028 PATH "tipoHonorario"                   WSSYNTAX "tipoHonorario"                   PRODUCES APPLICATION_JSON // "Retorna tipo de honorário, conforme código de honorário informado."
	WSMETHOD POST JParc           DESCRIPTION STR0030 PATH "parcelar"                        WSSYNTAX "parcelar"                        PRODUCES APPLICATION_JSON // "Parcelar"
	WSMETHOD POST WoFix           DESCRIPTION STR0031 PATH "woFixo"                          WSSYNTAX "woFixo"                          PRODUCES APPLICATION_JSON // "Efetua WO na parcela de Fixo."
	WSMETHOD POST CalFx           DESCRIPTION STR0032 PATH "calculafaixa"                    WSSYNTAX "calculafaixa"                    PRODUCES APPLICATION_JSON // "Função do botão CALCULAR para contratos fixos com faixa de valor."
	WSMETHOD POST CorrigeVlr      DESCRIPTION STR0033 PATH "correcaomonetaria"               WSSYNTAX "correcaomonetaria"               PRODUCES APPLICATION_JSON // "Função do botão Corrigir Valor para correção monetária para contratos fixos."
	WSMETHOD POST DeletNT1        DESCRIPTION STR0034 PATH "deleteparcNT1"                   WSSYNTAX "deleteparcNT1"                   PRODUCES APPLICATION_JSON // "Valida se a parcela pode ser excluída."
END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} GET GrdContratos
Consulta de Grid de Contratos


@example GET -> http://127.0.0.1:9090/rest/WSPfsAppContrato/grid

@param valorDig        - Valor digitado no campo
@param filtraFilial    - Indica se filtra Filial com xFilial
@param page            - Numero da pagina
@param pagesize        - Quantidade de itens na pagina

@author Victor Hayashi
@since  26/12/2023
/*/
//-------------------------------------------------------------------
WSMETHOD GET GrdContratos QUERYPARAM valorDig, filtraFilial, page, pageSize, count WSREST WSPfsAppContrato
Local oResponse      := JSonObject():New()
Local oContrato      := Nil
Local aArea          := GetArea()
Local cSearchKey     := Self:valorDig
Local lFiltFil       := Self:filtraFilial
Local nPage          := Self:page
Local nPageSize      := Self:pageSize
Local lCount         := Self:count
Local cAliasContrato := ""
Local cQuery         := ""
Local cTipo          := ""
Local cMemoCst       := ""
Local nQtdRegIni     := 0
Local nQtdRegFim     := 0
Local nParam         := 0
Local nIndexJSon     := 0
Local nQtdReg        := 0
Local nX             := 0
Local aCustomFlds    := JGtExtFlds("NT0", .F., .T., .F. )[1]
Local aQuery         := {}
Local aParams        := {}
Local lHasNext       := .F.

Default nPage      := 1
Default nPageSize  := 10
Default lFiltFil   := .F.
Default lCount     := .F.

	If ValType(nPageSize) == "C"
		nPageSize := Val(nPageSize)
	EndIf

	If ValType(nPage) == "C"
		nPage := Val(nPage)
	EndIf

	nQtdRegIni := ((nPage) * nPageSize) - nPageSize
	nQtdRegFim := (nPage * nPageSize)

	// Monta a Query
	aQuery     := JQryContrato(cSearchKey, ""/*cCodigo*/, lFiltFil, .T., lCount, ""/*cIdInd*/, aCustomFlds)
	cQuery     := ChangeQuery(aQuery[1])
	aParams    := aQuery[2]
	cAliasContrato := GetNextAlias()

	oContrato  := FWPreparedStatement():New(cQuery)

	For nParam := 1 To Len(aParams)
		If aParams[nParam][2] == "C"
			oContrato:SetString(nParam, aParams[nParam][1])
		ElseIf aParams[nParam][2] == "U"
			oContrato:SetUnsafe(nParam, aParams[nParam][1])
		EndIf
	Next

	cQuery := oContrato:GetFixQuery()

	MpSysOpenQuery(cQuery, cAliasContrato)

	If lCount
		If !(cAliasContrato)->(Eof())
			// indicadores
		EndIf
	Else
		oResponse['contrato'] := {}
		// Monta o response
		While !(cAliasContrato)->(Eof()) .And. nQtdReg < nQtdRegFim + 1
			nQtdReg++
			// Verifica se o registro esta no range da pagina
			If (nQtdReg > nQtdRegIni .AND. nQtdReg <= nQtdRegFim)
				nIndexJSon++

				Aadd(oResponse['contrato'], JsonObject():New())
				aTail(oResponse['contrato']) := setDadosContrato( cAliasContrato )
				//------ CAMPOS ADICIONAIS
				If !Empty(aCustomFlds)
					For nX := 1 to Len(aCustomFlds)
						If getSx3Cache(aCustomFlds[nX][1], 'X3_CONTEXT') == "R" .And. getSx3Cache(aCustomFlds[nX][1] ,'X3_BROWSE') == "S"
							cTipo := getSx3Cache(aCustomFlds[nX][1] ,'X3_TIPO')
							If cTipo == 'N'
								oResponse['contrato'][nIndexJSon][aCustomFlds[nX][1]] := JConvUTF8(cValToChar((cAliasContrato)->(FieldGet(FieldPos(aCustomFlds[nX][1])))))
							ElseIf cTipo == 'M'
								// Obtenção das informações dos campos MEMO
								NT0->(DbSetOrder(1)) // NT0_FILIAL, NT0_COD
								If (NT0->(DbSeek((cAliasContrato)->NT0_FILIAL + (cAliasContrato)->NT0_COD)))
									cMemoCst := NT0->(FieldGet(FieldPos(aCustomFlds[nX][1])))
									oResponse['contrato'][nIndexJSon][aCustomFlds[nX][1]] := JConvUTF8(cMemoCst)
								EndIf
							Else
								oResponse['contrato'][nIndexJSon][aCustomFlds[nX][1]] := JConvUTF8((cAliasContrato)->(FieldGet(FieldPos(aCustomFlds[nX][1]))))
							EndIf
						EndIf
					Next nX
				EndIf

			ElseIf (nQtdReg == nQtdRegFim + 1)
				lHasNext := .T.
			EndIf

			(cAliasContrato)->(dbSkip())
		EndDo

		// Verifica se ha uma proxima pagina
		oResponse['hasNext'] := lHasNext
	EndIf

	// Limpa o objeto FWPreparedStatement
	oContrato:Destroy()

	(cAliasContrato)->(dbCloseArea())
	Self:SetResponse( FWJsonSerialize(oResponse, .F., .F., .T.) )
	oResponse:fromJson("{}")
	oResponse := NIL

	JurFreeArr(@aQuery)
	JurFreeArr(@aParams)

	RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} setDadosContrato( cAliasContrato )
Define o response para os dados do contrato

@param - cAliasContrato - Alias da query

@author Willian Kazahaya
@since  01/09/2023
/*/
//-------------------------------------------------------------------
Static Function setDadosContrato( cAliasContrato )
Local oResponse  := JSonObject():New()
Local lLojaAuto  := SuperGetMv("MV_JLOJAUT", .F., "2",) == '1' // Indica se a Loja do contrato deve ser preenchida automaticamente. (1-Sim; 2-Nao)
Local nIndFilSA1 := 0
Local cFilSA1    := ""
Local aFiliais   := UsrFilial()

	nIndFilSA1 := aScan(aFiliais, {|x| AllTrim((cAliasContrato)->A1_FILIAL) $ x['filial'] })
	cFilSA1    := IIf(nIndFilSA1 == 0, cFilAnt, aFiliais[nIndFilSA1]['filial'])

	oResponse['filialDoRegistro']  := JConvUTF8((cAliasContrato)->NT0_FILIAL)
	oResponse['chave']             := Encode64((cAliasContrato)->NT0_FILIAL + (cAliasContrato)->NT0_COD)
	oResponse['filialCliente']     := JConvUTF8(cFilSA1)
	oResponse['codigoCliente']     := JConvUTF8((cAliasContrato)->NT0_CCLIEN)
	If !lLojaAuto
		oResponse['codigoCliente'] += "/" + (cAliasContrato)->NT0_CLOJA
	EndIf
	oResponse['nomeCliente']       := JConvUTF8((cAliasContrato)->A1_NOME)
	oResponse['codContrato']       := JConvUTF8((cAliasContrato)->NT0_COD)
	oResponse['descContrato']      := JConvUTF8((cAliasContrato)->NT0_NOME)
	oResponse['situacao']          := JConvUTF8((cAliasContrato)->NT0_SIT)
	oResponse['codTpHon']          := JConvUTF8((cAliasContrato)->NT0_CTPHON)
	oResponse['descTpHon']         := JConvUTF8((cAliasContrato)->NRA_DESC)
	oResponse['cobHora']           := JConvUTF8((cAliasContrato)->NRA_COBRAH)
	oResponse['cobDespesa']        := JConvUTF8((cAliasContrato)->NT0_DESPES)
	oResponse['cobServTab']        := JConvUTF8((cAliasContrato)->NT0_SERTAB)
	oResponse['codigoSocio']       := JConvUTF8((cAliasContrato)->NT0_CPART1)
	oResponse['nomeSocio']         := JConvUTF8((cAliasContrato)->RD0_NOME)
	oResponse['siglaSocio']        := JConvUTF8((cAliasContrato)->RD0_SIGLA)
	oResponse['ativo']             := JConvUTF8((cAliasContrato)->NT0_ATIVO)
	oResponse["dataIniVig"]        := JConvUTF8((cAliasContrato)->NT0_DTVIGI)
	oResponse["dataFimVig"]        := JConvUTF8((cAliasContrato)->NT0_DTVIGF)
	oResponse['pagadores']         := JGetPag((cAliasContrato)->(NT0_FILIAL), (cAliasContrato)->NT0_COD, .T.)

	// Dados de junção
	If !Empty((cAliasContrato)->NW2_COD)
		oResponse["pkJuncao"] := Encode64((cAliasContrato)->NW2_FILIAL + (cAliasContrato)->NW2_COD)
	Else
		oResponse["pkJuncao"] := ""
	EndIf
	oResponse["filialJuncao"] := (cAliasContrato)->NW2_FILIAL
	oResponse["codJuncao"]    := JConvUTF8((cAliasContrato)->NW2_COD)
	oResponse["descJuncao"]   := JConvUTF8((cAliasContrato)->NW2_DESC)

Return oResponse

//-------------------------------------------------------------------
/*/{Protheus.doc} UsrFilial
Filial do usuario

@author Willian Kazahaya
@since  01/09/2023
/*/
//-------------------------------------------------------------------
Static Function UsrFilial()
Local aFiliais := FWLoadSM0()
Local aJson    := {}
Local nI       := 0
Local nPos     := 0

	For nI := 1 To Len(aFiliais)
		If aFiliais[nI][11] .And. aFiliais[nI][1] == cEmpAnt // Retorna as filiais que o usuÃ¡rio tem acesso da empresa logada.
			Aadd(aJson,JsonObject():new())
			nPos := Len(aJson)
			aJson[nPos]['empresa']   := aFiliais[nI][1]
			aJson[nPos]['filial']    := aFiliais[nI][2]
			aJson[nPos]['descricao'] := aFiliais[nI][7]
		EndIf
	Next nI

Return aJson

//-------------------------------------------------------------------
/*/{Protheus.doc} JQryContrato
Monta a query de Contrato

@param cSearchKey  - Valor digitado no campo
@param cCodigo     - Numero do contrato
@param lFiltFil    - Indica se ira filtrar pela filial logada
@param lFilAdc     - Indica se tera o filtro adicional
@param lCount      - Indica se a query vai apenas trazer a quantidade de registros
@param cIdInd      - Indica o tipo de filtro que sera feito, conforme o indicador
@parma lRetVinJunc - Remove os contratos vinculados a junções


@return {cQuery, aParams} - cQuery - Query de busca dos contratos
                            aParams - Parametros para o FWPreparedStatement

@author Victor Hayashi
@since  21/12/2023
/*/
//-------------------------------------------------------------------
Static Function JQryContrato(cSearchKey, cCodigo, lFiltFil, lFilAdc, lCount, cIdInd, aCustomFlds, lRetVinJunc)
Local cQuery        := ""
Local cQrySel       := ""
Local cQryFrm       := ""
Local cQryWhr       := ""
Local cQryOrd       := ""
Local cCpoCstFlds   := ""
Local nI            := 0
Local nQtd          := 0
Local aParams       := {}

Default cCodigo     := ""
Default cIdInd      := ""
Default lFiltFil    := .F.
Default lFilAdc     := .F.
Default lCount      := .F.
Default lRetVinJunc := .F.

	// Pega os campos customizados
	For nI := 1 to Len(aCustomFlds)
		If getSx3Cache(aCustomFlds[nI][1], 'X3_CONTEXT') == "R" .And. getSx3Cache(aCustomFlds[nI][1] ,'X3_BROWSE') == "S"
			cCpoCstFlds += aCustomFlds[nI][1] + "," // Como o campo é adicionado sempre no começo da query não precisa tratar a ultima posição
		EndIf
	Next nI

	cQrySel += " SELECT ?"
	aAdd(aParams, {cCpoCstFlds, "U"})

	cQrySel +=       " NT0.NT0_FILIAL,"
	cQrySel +=       " NT0.NT0_COD,"
	cQrySel +=       " NT0.NT0_NOME,"
	cQrySel +=       " NT0.NT0_CCLIEN,"
	cQrySel +=       " NT0.NT0_CLOJA,"
	cQrySel +=       " SA1.A1_FILIAL,"
	cQrySel +=       " SA1.A1_NOME,"
	cQrySel +=       " NT0.NT0_SIT,"
	cQrySel +=       " NT0.NT0_CTPHON,"
	cQrySel +=       " NRA.NRA_DESC,"
	cQrySel +=       " NRA.NRA_COBRAH,"
	cQrySel +=       " NT0.NT0_DESPES,"
	cQrySel +=       " NT0.NT0_SERTAB,"
	cQrySel +=       " NT0.NT0_CPART1,"
	cQrySel +=       " RD0.RD0_NOME,"
	cQrySel +=       " RD0.RD0_SIGLA,"
	cQrySel +=       " NT0.NT0_ATIVO,"
	cQrySel +=       " NT0.NT0_DTVIGI,"
	cQrySel +=       " NT0.NT0_DTVIGF,"
	cQrySel +=       " COALESCE(NW2.NW2_FILIAL, ' ') NW2_FILIAL,"
	cQrySel +=       " COALESCE(NW2.NW2_COD, ' ') NW2_COD,"
	cQrySel +=       " COALESCE(NW2.NW2_DESC, ' ') NW2_DESC"
	cQryFrm +=  " FROM " + RetSqlName("NT0") + " NT0"
	cQryFrm += " INNER JOIN " + RetSqlName("SA1") + " SA1"
	cQryFrm +=    " ON SA1.A1_COD = NT0.NT0_CCLIEN"
	cQryFrm +=   " AND SA1.A1_LOJA = NT0.NT0_CLOJA"
	cQryFrm +=   " AND SA1.D_E_L_E_T_ = ' '"
	cQryFrm += " INNER JOIN " + RetSqlName("RD0") + " RD0"
	cQryFrm +=    " ON (RD0.RD0_CODIGO = NT0.NT0_CPART1"
	cQryFrm +=   " AND RD0.D_E_L_E_T_ = ' ' )"
	cQryFrm += " INNER JOIN " + RetSqlName("NRA") + " NRA"
	cQryFrm +=    " ON NRA.NRA_FILIAL = ' '"
	cQryFrm +=   " AND NRA.NRA_COD = NT0.NT0_CTPHON"
	cQryFrm +=   " AND NRA.D_E_L_E_T_ = ' '"

	// Dados de junção
	cQryFrm +=  " LEFT JOIN " + RetSqlName("NW3") + " NW3"
	cQryFrm +=    " ON NW3.NW3_FILIAL = NT0.NT0_FILIAL"
	cQryFrm +=   " AND NW3.NW3_CCONTR = NT0.NT0_COD"
	cQryFrm +=   " AND NW3.D_E_L_E_T_ = ' ' "
	cQryFrm +=  " LEFT JOIN " + RetSqlName("NW2") + " NW2"
	cQryFrm +=    " ON NW2.NW2_FILIAL = NW3.NW3_FILIAL"
	cQryFrm +=   " AND NW2.NW2_COD = NW3.NW3_CJCONT"
	cQryFrm +=   " AND NW2.D_E_L_E_T_ = ' '"
	cQryFrm += " WHERE NT0.D_E_L_E_T_ = ' '"

	// Pesquisa por valor digitado
	If !Empty(cSearchKey)
		cSearchKey := "%" + Lower(StrTran(JurLmpCpo( cSearchKey,.F. ),'#','')) + "%"
		
		cQryWhr += " AND ( LOWER(NT0_COD) LIKE ?" // "%" + cSearchKey + "%"
		cQryWhr +=        " OR LOWER(NT0_NOME) LIKE ?" // "%" + cSearchKey + "%"
		cQryWhr +=        " OR LOWER(NRA_DESC) LIKE ?" // "%" + cSearchKey + "%"
		cQryWhr +=        " OR " + JurFormat("NT0_CCLIEN", .T., .T.) + " LIKE ?" // "%" + cSearchKey + "%"
		cQryWhr +=        " OR " + JurFormat("NT0_CTPHON", .T., .T.) + " LIKE ?" // "%" + cSearchKey + "%"

		nQtd := 5
		
		If lFilAdc
			cQryWhr +=    " OR LOWER(A1_NOME) LIKE ?" // "%" + cSearchKey + "%"
			cQryWhr +=    " OR LOWER(A1_NREDUZ)  LIKE ?" // "%" + cSearchKey + "%"
			cQryWhr +=    " OR " + JurFormat("NT0_CLOJA" , .T.,.T. ) + " LIKE ?" // "%" + cSearchKey + "%"

			nQtd += 3
		EndIf

		For nI := 1 To nQtd
			aAdd(aParams, {"%" + cSearchKey + "%", "C"})
		Next

		If !Empty(aCustomFlds)
			For nI := 1 to Len(aCustomFlds)
				If getSx3Cache(aCustomFlds[nI][1], 'X3_CONTEXT') == "R"
					cQryWhr +=    " OR ? LIKE ?" // "%" + cSearchKey + "%"
					aAdd(aParams, {aCustomFlds[nI][1], "U"})
					aAdd(aParams, {"%" + cSearchKey + "%", "C"})
				EndIf
			Next nI
		EndIf

		cQryWhr += ")"
	EndIf

	if (lRetVinJunc)
		cQryWhr += " AND COALESCE(NW2.NW2_COD, ' ') = ' '"
	EndIf

	If !lCount // Pro count nao precisa fazer ORDER BY
		cQryOrd +=  " ORDER BY NT0.NT0_COD"
	EndIf

	cQuery := cQrySel + cQryFrm + cQryWhr + cQryOrd


Return {cQuery, aParams}

//-------------------------------------------------------------------
/*/{Protheus.doc} GET GetDetContrato
Busca as informacoes do contrato.

@example GET -> http://127.0.0.1:9090/rest/WSPfsAppContrato/detcontrato/{chaveContrato}

@author Victor Hayashi
@since 22/10/2023
/*/
//-------------------------------------------------------------------
WSMETHOD GET GetDetContrato PATHPARAM chaveContrato QUERYPARAM WSREST WSPfsAppContrato
Local oResponse   := JSonObject():New() // Objto de Resposta da requisicao
Local oContrato   := Nil // Objeto de query do contrato
Local cChaveContr := Decode64(Self:chaveContrato) // Chave do Contrato (NT0_FILIAL + NT0_COD)
Local nTamFilial  := TamSX3("NT0_FILIAL")[1] // Tamanho do campo Filial
Local nTamCodCtr  := TamSX3("NT0_COD"    )[1] // Tamanho do campo Codigo Cliente
Local cFilContr   := Substr(cChaveContr, 1, nTamFilial) // Filial do Contrato
Local cCodContr   := Substr(cChaveContr, nTamFilial + 1, nTamCodCtr) // Codigo do Contrato
Local cQuery      := "" // Query para pegar as informacoes do contrato
Local cServico    := "" // Frase de Servico(NT0_SERVIC)
Local cObservacao := "" // Observação (NT0_OBS)
Local cDscTpServ  := "" // Descrição do tipo de Serviço
Local cCpoCstFlds := "" // Campos customizados para o SELECT
Local cTipo       := "" // Tipo do campo customizado
Local cMemoCst    := "" // Conteudo do campo memo customizado
Local cAliasNT0   := GetNextAlias() // Alias para a query de contratos
Local nParam      := 0 // contador para os parametros da query
Local nTpServ     := 0 // Posicao do tipo de serviço na tabela DZ da SX5
Local nX          := 0 // Contador para varrer os arrays de tabelas
Local aSx5DZ      := FWGetSX5("DZ") // Traz os registros da tabela DZ na SX5
Local lRet        := .T.
Local aCustomFlds := JGtExtFlds("NT0", .F., .T., .F. )[1]

	// Pega os campos customizados
	For nX := 1 to Len(aCustomFlds)
		If getSx3Cache(aCustomFlds[nX][1], 'X3_CONTEXT') == "R"
			cCpoCstFlds += aCustomFlds[nX][1] + "," // Como o campo é adicionado sempre no começo da query não precisa tratar a ultima posição
		EndIf
	Next nX

	cQuery := " SELECT ?" // cCpoCstFlds
	cQuery +=        " NT0.NT0_FILIAL,"
	//---------------- PESSOAS
	cQuery +=        " NT0.NT0_CGRPCL,"
	cQuery +=        " ACY.ACY_DESCRI,"
	cQuery +=        " NT0.NT0_CCLIEN,"
	cQuery +=        " NT0.NT0_CLOJA,"
	cQuery +=        " SA1.A1_NOME,"
	cQuery +=        " NT0.NT0_USRINC,"
	cQuery +=        " NT0.NT0_CPART1,"
	cQuery +=        " RD0.RD0_SIGLA,"
	cQuery +=        " RD0.RD0_NOME,"
	//---------------- CONTRATO
	cQuery +=        " NT0.NT0_CONTR,"
	cQuery +=        " NT0.NT0_REV,"
	cQuery +=        " NT0.NT0_DISCAS,"
	cQuery +=        " NT0.NT0_NOME,"
	cQuery +=        " NT0.NT0_COD,"
	cQuery +=        " NT0.NT0_SIT,"
	cQuery +=        " NT0.NT0_DTINC,"
	cQuery +=        " NT0.NT0_DTVIGI,"
	cQuery +=        " NT0.NT0_DTVIGF,"
	//---------------- FATURAMENTO
	cQuery +=        " NT0.NT0_TITFAT,"
	cQuery +=        " NT0.NT0_COPFAT,"
	cQuery +=        " NT0.NT0_DIAEMI,"
	cQuery +=        " NT0.NT0_DESPAD,"
	cQuery +=        " NT0.NT0_CESCR,"
	cQuery +=        " NS7.NS7_NOME,"
	cQuery +=        " NT0.NT0_CMOE,"
	cQuery +=        " CTO.CTO_DESC,"
	cQuery +=        " NT0.NT0_RELPRE,"
	cQuery +=        " NZO.NZO_DESC,"
	cQuery +=        " NT0.NT0_CTPHON,"
	cQuery +=        " NRA.NRA_DESC,"
	cQuery +=        " NT0.NT0_CIDIO,"
	//---------------- COBRANCA
	cQuery +=        " NT0.NT0_CCLICM,"
	cQuery +=        " NT0.NT0_CLOJCM,"
	cQuery +=        " CLICM.A1_NOME NOME_CLICM,"
	cQuery +=        " NT0.NT0_CCASCM,"
	cQuery +=        " NT0.NT0_TPSERV,"// DZ
	cQuery +=        " NT0.NT0_TPFECH,"
	cQuery +=        " OHU.OHU_DESCRI,"
	cQuery +=        " NT0.NT0_ATIVO,"
	cQuery +=        " NT0.NT0_CASMAE,"
	cQuery +=        " NT0.NT0_ENCD,"
	cQuery +=        " NT0.NT0_DESPES,"
	cQuery +=        " NT0.NT0_ENCT,"
	If NT0->(ColumnPos("NT0_SUGPLD")) > 0 // @12.1.2310
		cQuery +=        " NT0.NT0_SUGPLD,"
	EndIf
	cQuery +=        " NT0.NT0_SERTAB,"
	cQuery +=        " NT0.NT0_ENCH"
	cQuery +=   " FROM " + RetSqlName("NT0") + " NT0"
	cQuery +=  " INNER JOIN " + RetSqlName("SA1") + " SA1"
	cQuery +=     " ON SA1.A1_COD = NT0.NT0_CCLIEN"
	cQuery +=    " AND SA1.A1_LOJA = NT0.NT0_CLOJA"
	cQuery +=    " AND SA1.D_E_L_E_T_ = ' '"
	cQuery +=   " LEFT JOIN " + RetSqlName("ACY") + " ACY"
	cQuery +=     " ON ACY.ACY_FILIAL = SA1.A1_FILIAL"
	cQuery +=    " AND ACY.ACY_GRPVEN = NT0.NT0_CGRPCL"
	cQuery +=    " AND ACY.D_E_L_E_T_ = ' '"
	cQuery +=   " LEFT JOIN " + RetSqlName("RD0") + " RD0"
	cQuery +=     " ON RD0_FILIAL = ?" // xFilial("RD0")
	cQuery +=    " AND RD0_CODIGO = NT0.NT0_CPART1"
	cQuery +=    " AND RD0.D_E_L_E_T_ = ' '"
	cQuery +=   " LEFT JOIN " + RetSqlName("NS7") + " NS7"
	cQuery +=     " ON NS7.NS7_FILIAL = ?" // xFilial("NS7")
	cQuery +=    " AND NS7.NS7_COD = NT0.NT0_CESCR"
	cQuery +=    " AND NS7.D_E_L_E_T_ = ' '"
	cQuery +=   " LEFT JOIN " + RetSqlName("CTO") + " CTO"
	cQuery +=     " ON CTO.CTO_FILIAL = ?" // xFilial("CTO")
	cQuery +=    " AND CTO.CTO_MOEDA = NT0.NT0_CMOE"
	cQuery +=    " AND CTO.D_E_L_E_T_ = ' '"
	cQuery +=   " LEFT JOIN " + RetSqlName("NZO") + " NZO"
	cQuery +=     " ON NZO.NZO_FILIAL = ?" // xFilial("NZO")
	cQuery +=    " AND NZO.NZO_COD = NT0.NT0_RELPRE"
	cQuery +=    " AND NZO.D_E_L_E_T_ = ' '"
	cQuery +=   " LEFT JOIN " + RetSqlName("NRA") + " NRA"
	cQuery +=     " ON NRA.NRA_FILIAL  = ?" // xFilial("NRA")
	cQuery +=    " AND NRA.NRA_COD = NT0.NT0_CTPHON"
	cQuery +=    " AND NRA.D_E_L_E_T_ = ' '"
	cQuery +=   " LEFT JOIN " + RetSqlName("SA1") + " CLICM"
	cQuery +=     " ON CLICM.A1_COD = NT0.NT0_CCLICM"
	cQuery +=    " AND CLICM.A1_LOJA = NT0.NT0_CLOJCM"
	cQuery +=    " AND CLICM.D_E_L_E_T_ = ' '"
	cQuery +=   " LEFT JOIN " + RetSqlName("OHU") + " OHU"
	cQuery +=     " ON OHU.OHU_FILIAL = ?" // xFilial("OHU")
	cQuery +=    " AND OHU.OHU_CODIGO = NT0.NT0_TPFECH"
	cQuery +=    " AND OHU.OHU_MSBLQL <> '1'"
	cQuery +=    " AND OHU.D_E_L_E_T_ = ' '
	cQuery +=  " WHERE NT0.NT0_FILIAL = ?" //cFilContr
	cQuery +=    " AND NT0.NT0_COD = ?" // cCodContr
	cQuery +=    " AND NT0.D_E_L_E_T_ = ' '"

	oContrato := FWPreparedStatement():New(cQuery)

	oContrato:SetUnsafe(++nParam, cCpoCstFlds)
	oContrato:SetString(++nParam, xFilial("RD0"))
	oContrato:SetString(++nParam, xFilial("NS7"))
	oContrato:SetString(++nParam, xFilial("CTO"))
	oContrato:SetString(++nParam, xFilial("NZO"))
	oContrato:SetString(++nParam, xFilial("NRA"))
	oContrato:SetString(++nParam, xFilial("OHU"))
	oContrato:SetString(++nParam, cFilContr)
	oContrato:SetString(++nParam, cCodContr)
	cQuery := oContrato:GetFixQuery()

	MpSysOpenQuery(cQuery, cAliasNT0)

	oResponse['contrato'] := {}
	If (cAliasNT0)->(!Eof())
		// Criacao do Objeto JSON
		aAdd(oResponse["contrato"], JsonObject():New())

		// Obtenção das informações dos campos MEMO
		NT0->(DbSetOrder(1)) // NT0_FILIAL, NT0_COD
		If (NT0->(DbSeek((cAliasNT0)->(NT0_FILIAL) + (cAliasNT0)->(NT0_COD))))
			cServico    := NT0->NT0_SERVIC
			cObservacao := NT0->NT0_OBS
		EndIf

		// Obtenção da descrição do tipo de serviço
		nTpServ := AScan(aSx5DZ, {|x| AllTrim(x[3]) == AllTrim((cAliasNT0)->NT0_TPSERV)})
		If nTpServ > 0
			cDscTpServ := aSx5DZ[nTpServ][4]
		EndIf

		// Chave do Registro
		oResponse["contrato"][1]["chaveNT0"]      := JConvUTF8((cAliasNT0)->(NT0_FILIAL) + (cAliasNT0)->(NT0_COD))
		//------ PESSOAS
		oResponse["contrato"][1]["codGrpCli"]     := JConvUTF8((cAliasNT0)->NT0_CGRPCL)
		oResponse["contrato"][1]["descGrpCli"]    := JConvUTF8((cAliasNT0)->ACY_DESCRI)
		oResponse["contrato"][1]["codCliente"]    := JConvUTF8((cAliasNT0)->NT0_CCLIEN)
		oResponse["contrato"][1]["lojaCliente"]   := JConvUTF8((cAliasNT0)->NT0_CLOJA)
		oResponse["contrato"][1]["nomeCliente"]   := JConvUTF8((cAliasNT0)->A1_NOME)
		oResponse["contrato"][1]["usrInclusao"]   := JConvUTF8((cAliasNT0)->NT0_USRINC)
		oResponse["contrato"][1]["codSocio"]      := JConvUTF8((cAliasNT0)->NT0_CPART1)
		oResponse["contrato"][1]["siglaSocio"]    := JConvUTF8((cAliasNT0)->RD0_SIGLA)
		oResponse["contrato"][1]["nomeSocio"]     := JConvUTF8((cAliasNT0)->RD0_NOME)
		oResponse["contrato"][1]["observacao"]    := JConvUTF8(cObservacao) // Campo Memo
		//------ CONTRATO
		oResponse["contrato"][1]["descContrato"]  := JConvUTF8((cAliasNT0)->NT0_CONTR) // Descricão do Contrato? 1-SIM/2-NAO
		oResponse["contrato"][1]["revisado"]      := JConvUTF8((cAliasNT0)->NT0_REV) // 1-SIM/2-NAO
		oResponse["contrato"][1]["discrCaso"]     := JConvUTF8((cAliasNT0)->NT0_DISCAS) // Descricão de Discrimina Caso na fatura? 1-SIM/2-NAO
		oResponse["contrato"][1]["nomeContrato"]  := JConvUTF8((cAliasNT0)->NT0_NOME)
		oResponse["contrato"][1]["codContrato"]   := JConvUTF8((cAliasNT0)->NT0_COD)
		oResponse["contrato"][1]["situacaoContr"] := JConvUTF8((cAliasNT0)->NT0_SIT)
		oResponse["contrato"][1]["dataInclusao"]  := JConvUTF8((cAliasNT0)->NT0_DTINC)
		oResponse["contrato"][1]["dataIniVig"]    := JConvUTF8((cAliasNT0)->NT0_DTVIGI) // Data de inicio da vigencia
		oResponse["contrato"][1]["dataFimVig"]    := JConvUTF8((cAliasNT0)->NT0_DTVIGF) // Data de termino da vigencia
		//------ FATURAMENTO
		oResponse["contrato"][1]["tituloFatura"]  := JConvUTF8((cAliasNT0)->NT0_TITFAT)
		oResponse["contrato"][1]["copiaFatura"]   := JConvUTF8((cAliasNT0)->NT0_COPFAT)
		oResponse["contrato"][1]["diaMaxEmissao"] := JConvUTF8(cValToChar((cAliasNT0)->NT0_DIAEMI))
		oResponse["contrato"][1]["descontLinear"] := JConvUTF8(cValToChar((cAliasNT0)->NT0_DESPAD))
		oResponse["contrato"][1]["codEscr"]       := JConvUTF8((cAliasNT0)->NT0_CESCR)
		oResponse["contrato"][1]["nomeEscr"]      := JConvUTF8((cAliasNT0)->NS7_NOME)
		oResponse["contrato"][1]["codMoeda"]      := JConvUTF8((cAliasNT0)->NT0_CMOE)
		oResponse["contrato"][1]["descMoeda"]     := JConvUTF8((cAliasNT0)->CTO_DESC)
		oResponse["contrato"][1]["codRelPre"]     := JConvUTF8((cAliasNT0)->NT0_RELPRE)
		oResponse["contrato"][1]["descRelPre"]    := JConvUTF8((cAliasNT0)->NZO_DESC)
		oResponse["contrato"][1]["codTpHon"]      := JConvUTF8((cAliasNT0)->NT0_CTPHON)
		oResponse["contrato"][1]["descTpHon"]     := JConvUTF8((cAliasNT0)->NRA_DESC)
		oResponse["contrato"][1]["idiomaPF"]      := JConvUTF8((cAliasNT0)->NT0_CIDIO)
		//------ COBRANCA
		oResponse["contrato"][1]["codCliCasM"]    := JConvUTF8((cAliasNT0)->NT0_CCLICM)
		oResponse["contrato"][1]["lojaCliCasM"]   := JConvUTF8((cAliasNT0)->NT0_CLOJCM)
		oResponse["contrato"][1]["nomeCliCasM"]   := JConvUTF8((cAliasNT0)->NOME_CLICM)
		oResponse["contrato"][1]["codCasoMae"]    := JConvUTF8((cAliasNT0)->NT0_CCASCM)
		oResponse["contrato"][1]["fraseServico"]  := JConvUTF8(cServico) // Campo Memo
		oResponse["contrato"][1]["codTpServ"]     := JConvUTF8((cAliasNT0)->NT0_TPSERV)
		oResponse["contrato"][1]["descTpServ"]    := JConvUTF8(cDscTpServ) // Descrição do Tipo de Serviço
		oResponse["contrato"][1]["codTpFech"]     := JConvUTF8((cAliasNT0)->NT0_TPFECH)
		oResponse["contrato"][1]["descTpFech"]    := JConvUTF8((cAliasNT0)->OHU_DESCRI)
		oResponse["contrato"][1]["ativo"]         := JConvUTF8((cAliasNT0)->NT0_ATIVO) // 1-SIM/2-NAO
		oResponse["contrato"][1]["alocacaoUnif"]  := JConvUTF8((cAliasNT0)->NT0_CASMAE) // Alocacao Unificafa? 1-SIM/2-NAO
		oResponse["contrato"][1]["encCobDesp"]    := JConvUTF8((cAliasNT0)->NT0_ENCD) // Encaminha Cobranca de Despesa? 1-SIM/2-NAO
		oResponse["contrato"][1]["cobDesp"]       := JConvUTF8((cAliasNT0)->NT0_DESPES) // 1-SIM/2-NAO
		oResponse["contrato"][1]["encCobTab"]     := JConvUTF8((cAliasNT0)->NT0_ENCT) // Encaminha Cobranca de Tabelado? 1-SIM/2-NAO
		oResponse["contrato"][1]["cobTab"]        := JConvUTF8((cAliasNT0)->NT0_SERTAB) // 1-SIM/2-NAO
		oResponse["contrato"][1]["encCobHon"]     := JConvUTF8((cAliasNT0)->NT0_ENCH) // Encaminha Cobranca de Honorarios? 1-SIM/2-NAO
		If NT0->(ColumnPos("NT0_SUGPLD")) > 0 // @12.1.2310
			oResponse["contrato"][1]["sugereLD"]      := JConvUTF8((cAliasNT0)->NT0_SUGPLD) // Sugere Contrato no LD? (1=Sim/2=Não)
		EndIf
		//------ CAMPOS ADICIONAIS
		If !Empty(aCustomFlds)
			For nX := 1 to Len(aCustomFlds)
				If getSx3Cache(aCustomFlds[nX][1], 'X3_CONTEXT') == "R"
					cTipo := getSx3Cache(aCustomFlds[nX][1], 'X3_TIPO')
					If cTipo == 'N'
						oResponse["contrato"][1][aCustomFlds[nX][1]]     := JConvUTF8(cValToChar((cAliasNT0)->(FieldGet(FieldPos(aCustomFlds[nX][1])))))
					ElseIf cTipo == 'M'
						// Obtenção das informações dos campos MEMO
						NT0->(DbSetOrder(1)) // NT0_FILIAL, NT0_COD
						If (NT0->(DbSeek((cAliasNT0)->NT0_FILIAL + (cAliasNT0)->NT0_COD)))
							cMemoCst := NT0->(FieldGet(FieldPos(aCustomFlds[nX][1])))
							oResponse["contrato"][1][aCustomFlds[nX][1]] := JConvUTF8(cMemoCst)
						EndIf
					Else
						oResponse["contrato"][1][aCustomFlds[nX][1]]     := JConvUTF8((cAliasNT0)->(FieldGet(FieldPos(aCustomFlds[nX][1]))))
					EndIf
				EndIf
			Next nX
		EndIf

	EndIf
	
	(cAliasNT0)->( dbCloseArea() )

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GET PagCtr
Consulta de Pagadores do Contrato

@example GET -> http://127.0.0.1:9090/rest/WSPfsAppContrato/pagadores/{chaveContrato}
@param chaveContrato - Chave do Contrato (Filial + Codigo Contrato)

@author Victor Hayashi
@since  22/12/2023
/*/
//-------------------------------------------------------------------
WSMethod GET PagCtr PATHPARAM chaveContrato WSREST WSPfsAppContrato
Local oResponse  := JSonObject():New()
Local cChaveCtr  := Decode64(Self:chaveContrato)
Local nTamFilial := TamSX3("NT0_FILIAL")[1]
Local nTamCodCtr := TamSX3("NT0_COD")[1]
Local cFilCtr    := Substr(cChaveCtr, 1, nTamFilial)
Local cCodCtr    := Substr(cChaveCtr, nTamFilial + 1, nTamCodCtr)


	oResponse := {}
	Aadd(oResponse, JsonObject():New())

	oResponse := JGetPag(cFilCtr, cCodCtr)

	Self:SetResponse( FWJsonSerialize(oResponse, .F., .F., .T.) )
	oResponse := Nil

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JGetPag
Consulta de Pagadores do Contrato (Usado no complemento do Browse)

@param cFilCtr  - Filial do Contrato
@param cFilCtr  - Codigo do Contrato

@return aPagadores - Array com as informacoes dos pagadores do contrato

@author Victor Hayashi/Reginaldo Borges
@since  22/12/2023
/*/
//-------------------------------------------------------------------
Static Function JGetPag(cFilCtr, cCodCtr, lBrowse)
Local oPagadores  := Nil
Local cAliasQry   := GetNextAlias()
Local cQuery      := ""
Local cCpoCstFlds := "" // Campos customizados para o SELECT
Local cTipo       := ""
Local cMemoCst    := ""
Local nX          := 0 // Contador para varrer os arrays de tabelas
Local nIndJson    := 0
Local nParam      := 0
Local nCountReg   := 0
Local aPagadores  := {}
Local aCustomFlds := JGtExtFlds("NXP", .F., .T., .F. )[1]

Default lBrowse := .F.

	cFilCtr := Padr(cFilCtr, TamSx3("NT0_FILIAL")[1])
	cCodCtr := Padr(cCodCtr, TamSx3("NT0_COD")[1])

	// Pega os campos customizados
	For nX := 1 to Len(aCustomFlds)
		If getSx3Cache(aCustomFlds[nX][1], 'X3_CONTEXT') == "R"
			If lBrowse
				If getSx3Cache(aCustomFlds[nX][1], 'X3_BROWSE') == "S"
					cCpoCstFlds += aCustomFlds[nX][1] + "," // Como o campo é adicionado sempre no começo da query não precisa tratar a ultima posição
				EndIf
			Else
				cCpoCstFlds += aCustomFlds[nX][1] + "," // Como o campo é adicionado sempre no começo da query não precisa tratar a ultima posição
			EndIf
		EndIf
	Next nX

	cQuery := " SELECT ?"
	cQuery +=        " NXP_FILIAL,"
	cQuery +=        " NXP_CCONTR,"
	cQuery +=        " NXP_CJCONT,"
	cQuery +=        " NXP_CLIPG,"
	cQuery +=        " NXP_LOJAPG,"
	cQuery +=        " SA1.A1_NOME,"
	cQuery +=        " NXP_PERCEN,"
	cQuery +=        " NXP_DESPAD,"
	cQuery +=        " NXP_CCONT,"
	cQuery +=        " SU5.U5_CONTAT,"
	cQuery +=        " NXP_FPAGTO,"
	cQuery +=        " NXP_CCDPGT,"
	cQuery +=        " SE4.E4_DESCRI,"
	cQuery +=        " NXP_CBANCO,"
	cQuery +=        " NXP_CAGENC,"
	cQuery +=        " NXP_CCONTA,"
	cQuery +=        " SA6.A6_NOME,"
	cQuery +=        " SA6.A6_NOMEAGE,"
	cQuery +=        " NXP_CMOE,"
	cQuery +=        " CTO.CTO_DESC,"
	cQuery +=        " NXP_CRELAT,"
	cQuery +=        " NRJ.NRJ_DESC,"
	cQuery +=        " NXP.NXP_CIDIO,"
	cQuery +=        " NR1A.NR1_DESC NR1DESC1,"
	cQuery +=        " NXP.NXP_CIDIO2,"
	cQuery +=        " NR1B.NR1_DESC NR1DESC2,"
	cQuery +=        " NXP_CCARTA,"
	cQuery +=        " NRG.NRG_DESC,"
	cQuery +=        " NXP_TXADM,"
	cQuery +=        " NXP_GROSUP,"
	cQuery +=        " NXP_GROSHN,"
	cQuery +=        " NXP_PERCGH,"
	cQuery +=        " NXP_TXPERM,"
	cQuery +=        " NXP_PJUROS,"
	cQuery +=        " NXP_DESFIN,"
	cQuery +=        " NXP_DIADES,"
	cQuery +=        " NXP_DIADES,"
	cQuery +=        " NXP_TPDESC,"
	cQuery +=        " NXP_CNATPG,"
	cQuery +=        " SED.ED_DESCRIC,"
	cQuery +=        " NXP_EMAIL,"
	cQuery +=        " NXP_EMLMIN"
	cQuery +=   " FROM "+ RetSqlName("NXP") + " NXP"
	cQuery +=  " INNER JOIN " + RetSqlName("SA1") + " SA1"
	cQuery +=     " ON SA1.A1_COD = NXP.NXP_CLIPG"
	cQuery +=    " AND SA1.A1_LOJA = NXP.NXP_LOJAPG"
	cQuery +=    " AND SA1.D_E_L_E_T_ = ' '"
	cQuery +=  " INNER JOIN " + RetSqlName("SU5") + " SU5"
	cQuery +=     " ON SU5.U5_FILIAL = ?" // U5_FILIAL
	cQuery +=    " AND SU5.U5_CODCONT = NXP.NXP_CCONT"
	cQuery +=    " AND SU5.D_E_L_E_T_ = ' '"
	cQuery +=   " LEFT JOIN "+ RetSqlName("SE4") + " SE4"
	cQuery +=     " ON SE4.E4_FILIAL = ?" // E4_FILIAL
	cQuery +=    " AND SE4.E4_CODIGO = NXP.NXP_CCDPGT"
	cQuery +=    " AND SE4.D_E_L_E_T_ = ' '"
	cQuery +=  " INNER JOIN "+ RetSqlName("SA6") + " SA6"
	cQuery +=     " ON SA6.A6_FILIAL = ?" // E6_FILIAL
	cQuery +=    " AND SA6.A6_COD = NXP.NXP_CBANCO"
	cQuery +=    " AND SA6.A6_NUMCON = NXP.NXP_CCONTA"
	cQuery +=    " AND SA6.A6_AGENCIA = NXP.NXP_CAGENC"
	cQuery +=    " AND SA6.D_E_L_E_T_ = ' '"
	cQuery +=  " INNER JOIN "+ RetSqlName("CTO") + " CTO"
	cQuery +=     " ON CTO.CTO_FILIAL = ?" // CT0_FILIAL
	cQuery +=    " AND CTO.CTO_MOEDA = NXP.NXP_CMOE"
	cQuery +=    " AND CTO.D_E_L_E_T_ = ' '"
	cQuery +=  " INNER JOIN "+ RetSqlName("NRJ") + " NRJ"
	cQuery +=     " ON NRJ.NRJ_FILIAL = ?" // NRJ_FILIAL
	cQuery +=    " AND NRJ.NRJ_COD = NXP.NXP_CRELAT"
	cQuery +=    " AND NRJ.D_E_L_E_T_ = ' '"
	cQuery +=  " INNER JOIN "+ RetSqlName("NR1") + " NR1A"
	cQuery +=     " ON NR1A.NR1_FILIAL =  ? " // NR1_FILIAL
	cQuery +=    " AND NR1A.NR1_COD = NXP.NXP_CIDIO"
	cQuery +=    " AND NR1A.D_E_L_E_T_ = ' '"
	cQuery +=  " INNER JOIN "+ RetSqlName("NR1") + " NR1B"
	cQuery +=     " ON NR1B.NR1_FILIAL = ?" // NR1_FILIAL
	cQuery +=    " AND NR1B.NR1_COD = NXP.NXP_CIDIO2"
	cQuery +=    " AND NR1B.D_E_L_E_T_ = ' '"
	cQuery +=  " INNER JOIN "+ RetSqlName("NRG") + " NRG"
	cQuery +=     " ON NRG.NRG_FILIAL = ?" // NR1_FILIAL
	cQuery +=    " AND NRG.NRG_COD = NXP.NXP_CCARTA"
	cQuery +=    " AND NRG.D_E_L_E_T_ = ' '"
	cQuery +=   " LEFT JOIN "+ RetSqlName("SED") + " SED"
	cQuery +=     " ON SED.ED_FILIAL = ?" // ED_FILIAL
	cQuery +=    " AND SED.ED_CODIGO = NXP.NXP_CNATPG"
	cQuery +=    " AND SED.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE NXP.NXP_FILIAL = ?" // NT0_FILIAL
	cQuery +=    " AND NXP.NXP_CCONTR = ?" // NT0_COD
	cQuery +=    " AND NXP.D_E_L_E_T_ = ' '"

	oPagadores := FWPreparedStatement():New(cQuery)

	oPagadores:SetUnsafe(++nParam, cCpoCstFlds)    // Campos Customizados
	oPagadores:SetString(++nParam, xFilial("SU5")) // Contatos
	oPagadores:SetString(++nParam, xFilial("SE4")) // Condições de Pagamentos
	oPagadores:SetString(++nParam, xFilial("SA6")) // Bancos
	oPagadores:SetString(++nParam, xFilial("CTO")) // Moedas
	oPagadores:SetString(++nParam, xFilial("NRJ")) // Tipos de Relatórios de Faturamento
	oPagadores:SetString(++nParam, xFilial("NR1")) // Idiomas de Faturamento
	oPagadores:SetString(++nParam, xFilial("NR1")) // Idiomas de Faturamento
	oPagadores:SetString(++nParam, xFilial("NRG")) // Tipos de Carta de Cobrança
	oPagadores:SetString(++nParam, xFilial("SED")) // Naturezas
	oPagadores:SetString(++nParam, cFilCtr)        // Filial do Contrato
	oPagadores:SetString(++nParam, cCodCtr)        // Código do Contrato

	cQuery := oPagadores:GetFixQuery()

	MpSysOpenQuery(cQuery, cAliasQry)

	While ((cAliasQry)->(!Eof()))
		++nCountReg
		nIndJson++
		aAdd(aPagadores, JSonObject():New())

		aPagadores[nIndJson]['chaveNXP']           := Encode64((cAliasQry)->NXP_FILIAL + (cAliasQry)->NXP_CLIPG + (cAliasQry)->NXP_LOJAPG + (cAliasQry)->NXP_CCONTR + (cAliasQry)->NXP_CJCONT) //NXP_FILIAL, NXP_CLIPG, NXP_LOJAPG, NXP_CCONTR, NXP_CJCONT
		aPagadores[nIndJson]['codCliente']         := JConvUTF8((cAliasQry)->NXP_CLIPG + "/" + (cAliasQry)->NXP_LOJAPG)
		aPagadores[nIndJson]['nomeCliente']        := JConvUTF8((cAliasQry)->A1_NOME)
		aPagadores[nIndJson]['percentual']         := JConvUTF8(cValToChar((cAliasQry)->NXP_PERCEN))
		aPagadores[nIndJson]['descontoPadrao']     := JConvUTF8(cValToChar((cAliasQry)->NXP_DESPAD))
		aPagadores[nIndJson]['codigoContato']      := JConvUTF8((cAliasQry)->NXP_CCONT)
		aPagadores[nIndJson]['nomeContato']        := JConvUTF8((cAliasQry)->U5_CONTAT)
		aPagadores[nIndJson]['formaPagamento']     := JConvUTF8((cAliasQry)->NXP_FPAGTO)
		aPagadores[nIndJson]['condicaoPagamento']  := JConvUTF8((cAliasQry)->NXP_CCDPGT)
		aPagadores[nIndJson]['descrCondPagamento'] := JConvUTF8((cAliasQry)->E4_DESCRI)
		aPagadores[nIndJson]['codigoBanco']        := JConvUTF8((cAliasQry)->NXP_CBANCO)
		aPagadores[nIndJson]['codigoAgencia']      := JConvUTF8((cAliasQry)->NXP_CAGENC)
		aPagadores[nIndJson]['codigoContaBanco']   := JConvUTF8((cAliasQry)->NXP_CCONTA)
		aPagadores[nIndJson]['nomeBanco']          := JConvUTF8((cAliasQry)->A6_NOME)
		aPagadores[nIndJson]['nomeAgencia']        := JConvUTF8((cAliasQry)->A6_NOMEAGE)
		aPagadores[nIndJson]['codigoMoeda']        := JConvUTF8((cAliasQry)->NXP_CMOE)
		aPagadores[nIndJson]['descMoeda']          := JConvUTF8((cAliasQry)->CTO_DESC)
		aPagadores[nIndJson]['codigoRelatorio']    := JConvUTF8((cAliasQry)->NXP_CRELAT)
		aPagadores[nIndJson]['descricaoRelatorio'] := JConvUTF8((cAliasQry)->NRJ_DESC)
		aPagadores[nIndJson]['codigoIdioma']       := JConvUTF8((cAliasQry)->NXP_CIDIO)
		aPagadores[nIndJson]['descricaoIdioma']    := JConvUTF8((cAliasQry)->NR1DESC1)
		aPagadores[nIndJson]['codigoIdioma2']      := JConvUTF8((cAliasQry)->NXP_CIDIO2)
		aPagadores[nIndJson]['descricaoIdioma2']   := JConvUTF8((cAliasQry)->NR1DESC2)
		aPagadores[nIndJson]['codigoCarta']        := JConvUTF8((cAliasQry)->NXP_CCARTA)
		aPagadores[nIndJson]['descricaoCarta']     := JConvUTF8((cAliasQry)->NRG_DESC)
		aPagadores[nIndJson]['taxaAdministrativa'] := JConvUTF8(cValToChar((cAliasQry)->NXP_TXADM))
		aPagadores[nIndJson]['grosupDespesas']     := JConvUTF8(cValToChar((cAliasQry)->NXP_GROSUP))
		aPagadores[nIndJson]['grosupHonorarios']   := JConvUTF8((cAliasQry)->NXP_GROSHN)
		aPagadores[nIndJson]['percentGrosHonor']   := JConvUTF8(cValToChar((cAliasQry)->NXP_PERCGH))
		aPagadores[nIndJson]['taxaPermanencia']    := JConvUTF8(cValToChar((cAliasQry)->NXP_TXPERM))
		aPagadores[nIndJson]['percentJurosDiario'] := JConvUTF8(cValToChar((cAliasQry)->NXP_PJUROS))
		aPagadores[nIndJson]['descontoFinanceiro'] := JConvUTF8(cValToChar((cAliasQry)->NXP_DESFIN))
		aPagadores[nIndJson]['diasDesconto']       := JConvUTF8(cValToChar((cAliasQry)->NXP_DIADES))
		aPagadores[nIndJson]['tipoDesconto']       := JConvUTF8((cAliasQry)->NXP_TPDESC)
		aPagadores[nIndJson]['codigoNatureza']     := JConvUTF8((cAliasQry)->NXP_CNATPG)
		aPagadores[nIndJson]['descNatureza']       := JConvUTF8((cAliasQry)->ED_DESCRIC)
		aPagadores[nIndJson]['emailEnvio']         := JConvUTF8((cAliasQry)->NXP_EMAIL)
		aPagadores[nIndJson]['emailMinuta']        := JConvUTF8((cAliasQry)->NXP_EMLMIN)

		//------ CAMPOS ADICIONAIS
		If !Empty(aCustomFlds)
			For nX := 1 to Len(aCustomFlds)
				If getSx3Cache(aCustomFlds[nX][1], 'X3_CONTEXT') == "R"
					cTipo := getSx3Cache(aCustomFlds[nX][1], 'X3_TIPO')
					If cTipo == 'N'
						aPagadores[nIndJson][aCustomFlds[nX][1]]     := JConvUTF8(cValToChar((cAliasQry)->(FieldGet(FieldPos(aCustomFlds[nX][1])))))
					ElseIf cTipo == 'M'
						// Obtenção das informações dos campos MEMO
						NXP->(DbSetOrder(1)) // NXP_FILIAL, NXP_CJCONT, NXP_CLIPG, NXP_LOJAPG
						If (NXP->(DbSeek((cAliasQry)->NXP_FILIAL + (cAliasQry)->NXP_CJCONT + (cAliasQry)->NXP_CLIPG + (cAliasQry)->NXP_LOJAPG)))
							cMemoCst := NXP->(FieldGet(FieldPos(aCustomFlds[nX][1])))
							aPagadores[nIndJson][aCustomFlds[nX][1]] := JConvUTF8(cMemoCst)
						EndIf
					Else
						aPagadores[nIndJson][aCustomFlds[nX][1]]     := JConvUTF8((cAliasQry)->(FieldGet(FieldPos(aCustomFlds[nX][1]))))
					EndIf
				EndIf
			Next nX
		EndIf

		(cAliasQry)->(dbSkip())
	EndDo

	// Limpa o objeto FWPreparedStatement
	oPagadores:Destroy()

	(cAliasQry)->(dbCloseArea())

Return aPagadores

//-------------------------------------------------------------------
/*/{Protheus.doc} GET GrdAtDpNaoCobCtr
Consulta de Grid de tipos de atividades e tipos de despesas não cobráveis (NTK e NTJ)

@example GET -> http://127.0.0.1:9090/rest/WSPfsAppContrato/atdpnaocob/{chaveContrato}
@param chaveContrato - Chave do Contrato (Filial + Codigo do Contrato)

@author Victor Hayashi
@since  26/12/2023
/*/
//-------------------------------------------------------------------
WSMethod GET GrdAtDpNaoCobCtr PATHPARAM chaveContrato WSREST WSPfsAppContrato
Local oResponse   := JSonObject():New()
Local cChaveContr := Decode64(Self:chaveContrato)
Local nTamFilial  := TamSX3("NT0_FILIAL")[1]
Local nTamCodCtr  := TamSX3("NT0_COD")[1]
Local cFilCtr     := Substr(cChaveContr, 1, nTamFilial)
Local cCodCtr     := Substr(cChaveContr, nTamFilial + 1, nTamCodCtr)

	oResponse := {}
	Aadd(oResponse, JsonObject():New())

	oResponse := JGtNCobCtr(cFilCtr, cCodCtr)

	Self:SetResponse( FWJsonSerialize(oResponse, .F., .F., .T.) )
	oResponse := Nil

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JGtNCobCtr
Consulta de Grid de tipos de atividades e tipos de despesas não cobráveis

@param cFilCtr   - Filial do Contrato
@param cCodCtr   - Código do contrato

@author Victor Hayashi
@since  26/12/2023
/*/
//-------------------------------------------------------------------
Static Function JGtNCobCtr(cFilCtr, cCodCtr)
Local oNCobCtr    := Nil
Local aTpAtDpNCob := {}
Local cQuery      := ""
Local cAliasQry   := ""
Local nIndJson    := 0
Local nParam      := 0

	cFilCtr := Padr(cFilCtr,TamSx3("NT0_FILIAL")[1])
	cCodCtr := Padr(cCodCtr,TamSx3("NT0_COD")[1])

	cQuery := " SELECT * FROM ("
	cQuery +=        " SELECT '1' TIPO, NTJ.NTJ_FILIAL FILIAL, NTJ.NTJ_CCONTR CONTRATO, NTJ.NTJ_CTPATV CODTPATIDES, NRC.NRC_DESC DESTPATIDES"
	cQuery +=          " FROM " + RetSqlName("NTJ") + " NTJ"
	cQuery +=         " INNER JOIN " + RetSqlName("NRC") + " NRC"
	cQuery +=            " ON NRC.NRC_FILIAL = NTJ.NTJ_FILIAL"
	cQuery +=           " AND NRC.NRC_COD = NTJ.NTJ_CTPATV"
	cQuery +=           " AND NRC.NRC_ATIVO = '1'"
	cQuery +=           " AND NRC.D_E_L_E_T_ = ' '"
	cQuery +=         " WHERE NTJ.NTJ_FILIAL = ?"
	cQuery +=           " AND NTJ.NTJ_CCONTR = ?"
	cQuery +=           " AND NTJ.D_E_L_E_T_ = ' '"
	cQuery +=         " UNION ALL"
	cQuery +=        " SELECT '2' TIPO, NTK.NTK_FILIAL FILIAL, NTK.NTK_CCONTR CONTRATO, NTK.NTK_CTPDSP CODTPATIDES, NRH.NRH_DESC DESTPATIDES"
	cQuery +=          " FROM " + RetSqlName("NTK") + " NTK"
	cQuery +=         " INNER JOIN " + RetSqlName("NRH") + " NRH"
	cQuery +=            " ON NRH.NRH_FILIAL = NTK.NTK_FILIAL"
	cQuery +=           " AND NRH.NRH_COD = NTK.NTK_CTPDSP"
	cQuery +=           " AND NRH.NRH_ATIVO = '1'"
	cQuery +=           " AND NRH.D_E_L_E_T_ = ' '"
	cQuery +=         " WHERE NTK.NTK_FILIAL = ?"
	cQuery +=           " AND NTK.NTK_CCONTR = ?"
	cQuery +=           " AND NTK.D_E_L_E_T_ = ' ') A"

	cAliasQry := GetNextAlias()

	oNCobCtr := FWPreparedStatement():New(cQuery)

	oNCobCtr:SetString(++nParam, cFilCtr)
	oNCobCtr:SetString(++nParam, cCodCtr)
	oNCobCtr:SetString(++nParam, cFilCtr)
	oNCobCtr:SetString(++nParam, cCodCtr)

	cQuery := oNCobCtr:GetFixQuery()

	MpSysOpenQuery(cQuery, cAliasQry)

	While ((cAliasQry)->(!Eof()))
		nIndJson++
		aAdd(aTpAtDpNCob, JSonObject():New())

		aTpAtDpNCob[nIndJson]['chaveNTJTNK']       := Encode64((cAliasQry)->FILIAL + (cAliasQry)->CONTRATO + (cAliasQry)->CODTPATIDES)
		aTpAtDpNCob[nIndJson]['contrato']          := JConvUTF8((cAliasQry)->CONTRATO)
		aTpAtDpNCob[nIndJson]['tipo']              := JConvUTF8((cAliasQry)->TIPO)
		aTpAtDpNCob[nIndJson]['codtpativdesp']     := JConvUTF8((cAliasQry)->CODTPATIDES)
		aTpAtDpNCob[nIndJson]['destpativdesp']     := JConvUTF8((cAliasQry)->DESTPATIDES)

		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())

Return aTpAtDpNCob

//-------------------------------------------------------------------
/*/{Protheus.doc} GET GetTituloIdioma
Retorna dados daa tabela de título do contrato por idioma (NT5)

@example GET -> http://127.0.0.1:9090/rest/WSPfsAppContrato/tituloporidioma/{chaveContrato}
@param chaveContrato - Chave do Contrato (Filial + Codigo do Contrato)

@author Victor Hayashi
@since  26/12/2023
/*/
//-------------------------------------------------------------------
WSMethod GET GetTituloIdioma PATHPARAM chaveContrato WSREST WSPfsAppContrato
Local oResponse  := JSonObject():New()
Local cChaveContr := Decode64(Self:chaveContrato)
Local nTamFilial  := TamSX3("NT0_FILIAL")[1]
Local nTamCodCtr  := TamSX3("NT0_COD")[1]
Local cFilCtr     := Substr(cChaveContr, 1, nTamFilial)
Local cCodCtr     := Substr(cChaveContr, nTamFilial + 1, nTamCodCtr)

	oResponse := {}
	Aadd(oResponse, JsonObject():New())

	oResponse := JGtTitIdioma(cFilCtr, cCodCtr)

	Self:SetResponse( FWJsonSerialize(oResponse, .F., .F., .T.) )
	oResponse := Nil

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JGtTitIdioma
Consulta Grid de título do Contrato por idioma (NT5)

@param cFilCtr   - Filial do Contrato
@param cCodCtr   - Código do contrato

@author Victor Hayashi
@since  26/12/2023
/*/
//-------------------------------------------------------------------
Static Function JGtTitIdioma(cFilCtr, cCodCtr)
Local oTitIdioma  := Nil
Local aTitIdioma  := {}
Local aCustomFlds := JGtExtFlds("NT5", .F., .T., .F. )[1]
Local cTipo       := ""
Local cMemoCst    := ""
Local cQuery      := ""
Local cAliasQry   := ""
Local cCpoCstFlds := "" // Campos customizados para o SELECT
Local nX          := 0 // Contador para varrer os arrays de tabelas
Local nIndJson    := 0
Local nParam      := 0

	cFilCtr := Padr(cFilCtr,TamSx3("NT0_FILIAL")[1])
	cCodCtr := Padr(cCodCtr,TamSx3("NT0_COD")[1])

	// Pega os campos customizados
	For nX := 1 to Len(aCustomFlds)
		If getSx3Cache(aCustomFlds[nX][1], 'X3_CONTEXT') == "R"
			cCpoCstFlds += aCustomFlds[nX][1] + "," // Como o campo é adicionado sempre no começo da query não precisa tratar a ultima posição
		EndIf
	Next nX

	cQuery := " SELECT ?"
	cQuery +=        " NT5.NT5_FILIAL,"
	cQuery +=        " NT5.NT5_COD,"
	cQuery +=        " NT5.NT5_CCONTR,"
	cQuery +=        " NT0.NT0_NOME,"
	cQuery +=        " NT5.NT5_CIDIOM,"
	cQuery +=        " NR1.NR1_DESC,"
	cQuery +=        " NT5.NT5_TITULO,"
	cQuery +=        " NT5.NT5_REV"
	cQuery +=   " FROM " + RetSqlName("NT5") + " NT5"
	cQuery +=   " LEFT JOIN " + RetSqlName("NR1") + " NR1"
	cQuery +=     " ON NR1.NR1_FILIAL = ?"
	cQuery +=    " AND NR1.NR1_COD = NT5.NT5_CIDIOM"
	cQuery +=    " AND NR1.D_E_L_E_T_ = ' '"
	cQuery +=   " INNER JOIN " + RetSqlName("NT0") + " NT0"
	cQuery +=     " ON NT0.NT0_FILIAL = NT5.NT5_FILIAL"
	cQuery +=    " AND NT0.NT0_COD = NT5.NT5_CCONTR"
	cQuery +=    " AND NT0.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE NT5.NT5_FILIAL = ?"
	cQuery +=    " AND NT5.NT5_CCONTR = ?"
	cQuery +=    " AND NT5.D_E_L_E_T_ = ' '"

	cAliasQry := GetNextAlias()

	oTitIdioma := FWPreparedStatement():New(cQuery)
	oTitIdioma:SetUnsafe(++nParam, cCpoCstFlds)
	oTitIdioma:SetString(++nParam, xFilial("NR1"))
	oTitIdioma:SetString(++nParam, cFilCtr)
	oTitIdioma:SetString(++nParam, cCodCtr)

	cQuery := oTitIdioma:GetFixQuery()
	MpSysOpenQuery(cQuery, cAliasQry)

	While ((cAliasQry)->(!Eof()))
		nIndJson++
		aAdd(aTitIdioma, JSonObject():New())

		aTitIdioma[nIndJson]['chaveNT5']          := Encode64((cAliasQry)->(NT5_FILIAL + NT5_COD))
		aTitIdioma[nIndJson]['contrato']          := JConvUTF8((cAliasQry)->NT5_CCONTR)
		aTitIdioma[nIndJson]['tituloContrato']    := JConvUTF8((cAliasQry)->NT0_NOME)
		aTitIdioma[nIndJson]['codigoIdioma']      := JConvUTF8((cAliasQry)->NT5_CIDIOM)
		aTitIdioma[nIndJson]['descricaoIdioma']   := JConvUTF8((cAliasQry)->NR1_DESC)
		aTitIdioma[nIndJson]['titulo']            := JConvUTF8((cAliasQry)->NT5_TITULO)
		aTitIdioma[nIndJson]['revisado']          := JConvUTF8((cAliasQry)->NT5_REV)

		//------ CAMPOS ADICIONAIS
		If !Empty(aCustomFlds)
			For nX := 1 to Len(aCustomFlds)
				cTipo := getSx3Cache(aCustomFlds[nX][1], 'X3_TIPO')
				If getSx3Cache(aCustomFlds[nX][1], 'X3_CONTEXT') == "R"
					If cTipo == 'N'
						aTitIdioma[nIndJson][aCustomFlds[nX][1]]     := JConvUTF8(cValToChar((cAliasQry)->(FieldGet(FieldPos(aCustomFlds[nX][1])))))
					ElseIf cTipo == 'M'
						// Obtenção das informações dos campos MEMO
						NT5->(DbSetOrder(1)) // NT5_FILIAL, NT5_COD
						If (NT5->(DbSeek((cAliasQry)->(NT5_FILIAL + NT5_COD))))
							cMemoCst := NT5->(FieldGet(FieldPos(aCustomFlds[nX][1])))
							aTitIdioma[nIndJson][aCustomFlds[nX][1]] := JConvUTF8(cMemoCst)
						EndIf
					Else
						aTitIdioma[nIndJson][aCustomFlds[nX][1]] := JConvUTF8((cAliasQry)->(FieldGet(FieldPos(aCustomFlds[nX][1]))))
					EndIf
				EndIf
			Next nX
		EndIf

		(cAliasQry)->(dbSkip())
	EndDo

	(cAliasQry)->(dbCloseArea())

Return aTitIdioma

//-------------------------------------------------------------------
/*/{Protheus.doc} GET TemPre
Retorna Pré-Fatura vincualda ao Contrato.

@example GET -> http://127.0.0.1:9090/rest/WSPfsAppContrato/temPrefatura/{chaveContrato}
@param chaveContrato, Chave do Contrato (Filial + Codigo do Contrato)

@author Reginaldo Borges
@since  26/01/2024
/*/
//-------------------------------------------------------------------
WSMethod GET TemPre PATHPARAM chaveContrato WSREST WSPfsAppContrato
Local oResponse   := JSonObject():New()
Local cChaveContr := Decode64(Self:chaveContrato)
Local nTamFilial  := TamSX3("NT0_FILIAL")[1]
Local nTamCodCtr  := TamSX3("NT0_COD")[1]
Local cFilCtr     := Substr(cChaveContr, 1, nTamFilial)
Local cCodCtr     := Substr(cChaveContr, nTamFilial + 1, nTamCodCtr)

	oResponse := {}
	Aadd(oResponse, JsonObject():New())

	oResponse := JPrefatura(cFilCtr, cCodCtr)

	Self:SetResponse( FWJsonSerialize(oResponse, .F., .F., .T.) )
	oResponse := Nil

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JPrefatura
Consulta Pré-Fatura vinculada ao Contrato.

@param cFilCtr, Filial do Contrato
@param cCodCtr, Código do contrato

@author Reginaldo Borges
@since  26/01/2024
/*/
//-------------------------------------------------------------------
Static Function JPrefatura(cFilCtr, cCodCtr)
Local oContrPre     := Nil
Local cQuery        := ""
Local nIndJson      := 0
Local nParam        := 0
Local nCont         := 0
Local aTemPrefatura := {}
Local cAliasQry     := GetNextAlias()

	cFilCtr := Padr(cFilCtr,TamSx3("NT0_FILIAL")[1])
	cCodCtr := Padr(cCodCtr,TamSx3("NT0_COD")[1])

	// Time Sheets não vinculados a pré-faturas ou minutas
	cQuery    := " SELECT NUE_COD, NUE_CPREFT, '2' TEMMINUTA, ? CONTRATO "
	cQuery    +=   " FROM " + RetSqlName("NUE") + " NUE "
	cQuery    +=  " WHERE NUE.D_E_L_E_T_ = ' ' "
	cQuery    +=    " AND NUE.NUE_FILIAL = ? "
	cQuery    +=    " AND NUE.NUE_SITUAC = '1' "
	cQuery    +=    " AND NUE.NUE_CPREFT = ? " // '" + Space(TamSx3('NUE_CPREFT')[1]) + "'
	cQuery    +=    " AND EXISTS ( SELECT NUT.R_E_C_N_O_ "
	cQuery    +=                   " FROM " + RetSqlName("NUT") + " NUT "
	cQuery    +=                  " WHERE NUT.D_E_L_E_T_ = ' ' "
	cQuery    +=                    " AND NUT.NUT_FILIAL = ? "
	cQuery    +=                    " AND NUT.NUT_CCONTR = ? "
	cQuery    +=                    " AND NUT.NUT_CCLIEN = NUE.NUE_CCLIEN "
	cQuery    +=                    " AND NUT.NUT_CLOJA  = NUE.NUE_CLOJA "
	cQuery    +=                    " AND NUT.NUT_CCASO  = NUE.NUE_CCASO ) "
	cQuery    +=  " UNION "
	// Time Sheets vinculados somente a pré-faturas
	cQuery    += " SELECT NUE_COD, NUE_CPREFT, '2' TEMMINUTA, ? CONTRATO "
	cQuery    +=   " FROM " + RetSqlName("NUE") + " NUE "
	cQuery    +=  " WHERE NUE.D_E_L_E_T_ = ' ' "
	cQuery    +=    " AND NUE.NUE_FILIAL = ? "
	cQuery    +=    " AND NUE.NUE_SITUAC = '1' "
	cQuery    +=    " AND NUE.NUE_CPREFT > ? "
	cQuery    +=    " AND EXISTS ( SELECT NUT.R_E_C_N_O_ "
	cQuery    +=                   " FROM " + RetSqlName("NUT") + " NUT "
	cQuery    +=                  " WHERE NUT.D_E_L_E_T_ = ' ' "
	cQuery    +=                    " AND NUT.NUT_FILIAL = ? "
	cQuery    +=                    " AND NUT.NUT_CCONTR = ? "
	cQuery    +=                    " AND NUT.NUT_CCLIEN = NUE.NUE_CCLIEN "
	cQuery    +=                    " AND NUT.NUT_CLOJA  = NUE.NUE_CLOJA "
	cQuery    +=                    " AND NUT.NUT_CCASO  = NUE.NUE_CCASO ) "
	cQuery    +=                    " AND NOT EXISTS (SELECT 1 "
	cQuery    +=                                      " FROM " + RetSqlName("NXA") + " NXA "
	cQuery    +=                                     " WHERE NXA.NXA_FILIAL = NUE.NUE_FILIAL"
	cQuery    +=                                       " AND NXA.NXA_CPREFT = NUE.NUE_CPREFT"
	cQuery    +=                                       " AND NXA.NXA_SITUAC = '1'"
	cQuery    +=                                       " AND NXA.NXA_TIPO IN ('MP', 'MS', 'MF')"
	cQuery    +=                                       " AND NXA.D_E_L_E_T_ = ' ')"
	cQuery    +=  " UNION "
	// Time Sheets vinculados a minutas de pré-faturas e minutas sócio
	cQuery    += " SELECT NUE_COD, NUE_CPREFT, '1' TEMMINUTA, ? CONTRATO "
	cQuery    +=   " FROM " + RetSqlName("NUE") + " NUE "
	cQuery    +=  " WHERE NUE.D_E_L_E_T_ = ' ' "
	cQuery    +=    " AND NUE.NUE_FILIAL = ? "
	cQuery    +=    " AND NUE.NUE_SITUAC = '1' "
	cQuery    +=    " AND NUE.NUE_CPREFT > ? "
	cQuery    +=    " AND EXISTS  (SELECT NUT.R_E_C_N_O_ "
	cQuery    +=                   " FROM " + RetSqlName("NUT") + " NUT "
	cQuery    +=                  " WHERE NUT.D_E_L_E_T_ = ' ' "
	cQuery    +=                    " AND NUT.NUT_FILIAL = ? "
	cQuery    +=                    " AND NUT.NUT_CCONTR = ? "
	cQuery    +=                    " AND NUT.NUT_CCLIEN = NUE.NUE_CCLIEN "
	cQuery    +=                    " AND NUT.NUT_CLOJA  = NUE.NUE_CLOJA "
	cQuery    +=                    " AND NUT.NUT_CCASO  = NUE.NUE_CCASO) "
	cQuery    +=                    " AND EXISTS (SELECT 1 "
	cQuery    +=                                  " FROM " + RetSqlName("NXA") + " NXA "
	cQuery    +=                                 " WHERE NXA.NXA_FILIAL = NUE.NUE_FILIAL"
	cQuery    +=                                   " AND NXA.NXA_CPREFT = NUE.NUE_CPREFT"
	cQuery    +=                                   " AND NXA.NXA_SITUAC = '1'"
	cQuery    +=                                   " AND NXA.NXA_TIPO IN ('MP', 'MS')"
	cQuery    +=                                   " AND NXA.D_E_L_E_T_ = ' ')"
	cQuery    +=  " ORDER BY TEMMINUTA"

	oContrPre := FWPreparedStatement():New(cQuery)

	For nCont := 1 To 3
		oContrPre:SetString(++nParam, cCodCtr)
		oContrPre:SetString(++nParam, cFilCtr)
		oContrPre:SetString(++nParam, Space(TamSx3('NUE_CPREFT')[1]) )
		oContrPre:SetString(++nParam, cFilCtr)
		oContrPre:SetString(++nParam, cCodCtr)
	Next nCont

	cQuery := oContrPre:GetFixQuery()

	MpSysOpenQuery(cQuery, cAliasQry)

	While !(cAliasQry)->(Eof())
		nIndJson++
		aAdd(aTemPrefatura, JSonObject():New())

		aTemPrefatura[nIndJson]['contrato']  := JConvUTF8((cAliasQry)->CONTRATO)
		aTemPrefatura[nIndJson]['timeSheet'] := JConvUTF8((cAliasQry)->NUE_COD)
		aTemPrefatura[nIndJson]['preFatura'] := JConvUTF8((cAliasQry)->NUE_CPREFT)
		aTemPrefatura[nIndJson]['temMinuta'] := JConvUTF8((cAliasQry)->TEMMINUTA)

		(cAliasQry)->(dbSkip())
	EndDo
	
	// Limpa o objeto FWPreparedStatement
	oContrPre:Destroy()

	(cAliasQry)->(dbCloseArea())

Return aTemPrefatura

//-----------------------------------------------------------------------
/*/{Protheus.doc} POST RevTS
Revaloriza os time sheets dos casos

@param lCancSmartUI, Se cancela pré-fatura vinculada ao contrato

@example POST -> http://127.0.0.1:9090/rest/WSPfsAppContrato/revalorizar

/*/
//-----------------------------------------------------------------------
WSMETHOD POST RevTS QUERYPARAM lCancSmartUI WSREST WSPfsAppContrato
Local lCancSmartUI := Self:lCancSmartUI
Local oResponse    := JPOSTReval(Self:GetContent(), lCancSmartUI)
Local lRet         := oResponse <> Nil

	If lRet
		Self:SetResponse(FWJsonSerialize(oResponse))
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JPOSTReval
Revaloriza os time sheets dos contratos

@param cBody       , Body da requisição
@param lCancSmartUI, Se cancela pré-fatura vinculada ao contrato
@param oReval      , Estrutura Json de mensagens de retorno

@author Reginaldo Borges
@since  24/01/2024
/*/
//-------------------------------------------------------------------
Static Function JPOSTReval(cBody, lCancSmartUI)
Local oJsonBody := JsonObject(): New()
Local oReval    := JsonObject(): New()

	oJsonBody:fromJson(cBody)

	If ValType(oJsonBody) == "J" .And. Len(oJsonBody["contratos"]) > 0
		oReval["legenda"]   := JRevLegend()         // Estrutura de legendas
		oReval["contratos"] := JRevDados(oJSonBody, lCancSmartUI) // Dados dos contratos
	EndIf

Return oReval

//-------------------------------------------------------------------
/*/{Protheus.doc} JRevLegend
Monta estrutura do JSON com a legenda usada na tela de revalorização

@return aLegenda - Array com a estrutura Json de legenda

@author Reginaldo Borges
@since  24/01/2024
/*/
//-------------------------------------------------------------------
Static Function JRevLegend()
Local aLegenda := {}

	aAdd(aLegenda, JsonObject():New())
	aLegenda[1]["legenda"]  := JConvUTF8("1") // Erro
	aLegenda[1]["status"]   := JConvUTF8("1")
	aLegenda[1]["situacao"] := JConvUTF8(STR0009) // "Erro na revalorização do(s) timesheet(s) do(s) contrato(s)."

	aAdd(aLegenda, JSonObject():New())
	aLegenda[2]["legenda"]  := JConvUTF8("2") // Informação
	aLegenda[2]["status"]   := JConvUTF8("2")
	aLegenda[2]["situacao"] := JConvUTF8(STR0010) // "Não há dados para revalorização de timesheet(s) do(s) contrato(s)."

	aAdd(aLegenda, JSonObject():New())
	aLegenda[3]["legenda"]  := JConvUTF8("3") // Sucesso
	aLegenda[3]["status"]   := JConvUTF8("3")
	aLegenda[3]["situacao"] := JConvUTF8(STR0015) // "Timesheet(s) do(s) contrato(s) revalorizado(s) com sucesso."

	aAdd(aLegenda, JSonObject():New())
	aLegenda[4]["legenda"]  := JConvUTF8("2") // Informação
	aLegenda[4]["status"]   := JConvUTF8("4")
	aLegenda[4]["situacao"] := JConvUTF8(STR0011) // "Não foi possível revalorizar o(s) timesheet(s) do(s) contrato(s) devido a vínculo com pré-fatura(s) em revisão."

	aAdd(aLegenda, JSonObject():New())
	aLegenda[5]["legenda"]  := JConvUTF8("2") // Informação
	aLegenda[5]["status"]   := JConvUTF8("5")
	aLegenda[5]["situacao"] := JConvUTF8(STR0014) // "Alguns timesheets não foram revalorizados. Você não tem permissão para alterar os seguintes timesheets."

	aAdd(aLegenda, JSonObject():New())
	aLegenda[6]["legenda"]  := JConvUTF8("2") // Informação
	aLegenda[6]["status"]   := JConvUTF8("6")
	aLegenda[6]["situacao"] := JConvUTF8(STR0013) // "Não foi possível revalorizar os timesheet(s) do(s) contrato(s) por falta de permissão para alterar e revalorizar timesheet(s)."

	aAdd(aLegenda, JSonObject():New())
	aLegenda[7]["legenda"]  := JConvUTF8("2") // Informação
	aLegenda[7]["status"]   := JConvUTF8("7")
	aLegenda[7]["situacao"] := JConvUTF8(STR0012) // "Os Time Sheets não foram revalorizados."

Return aLegenda

//-------------------------------------------------------------------
/*/{Protheus.doc} JRevDados
Monta estrutura do JSON com os dados da revalorização

@param oJSonBody   , Corpo da requisição em formato JSON
@param lCancSmartUI, Se cancela pré-fatura vinculada ao contrato
@return aDados     , Array com a estrutura JSON de dados dos contratos

@author Reginaldo Borges
@since  24/01/2024
/*/
//-------------------------------------------------------------------
Static Function JRevDados(oJSonBody, lCancSmartUI)
Local aArea        := GetArea()
Local aAreaNT0     := NT0->(GetArea())
Local aDados       := {}
Local nContrato    := 0
Local nIndReval    := 0
Local cChaveContr  := ""
Local cMensagem    := ""
Local cStatus      := ""
Local cStatusBkp   := ""
Local cLegenda     := ""
Local lStatusUnico := .T.
Local lLojaAuto    := SuperGetMv("MV_JLOJAUT", .F., "2",) == '1' // Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)

	NT0->(DbSetOrder(1)) // NT0_FILIAL + NT0_COD

	For nContrato := 1 To Len(oJSonBody["contratos"])
		cChaveContr := Decode64(oJSonBody["contratos"][nContrato]["pk"])
		
		If NT0->(dbSeek(cChaveContr))
			cStatusBkp := cStatus
			cStatus    := ""
			JA096REVTS(NT0->(NT0_COD), .T., .T., lCancSmartUI, @cStatus, @cMensagem)

			// Avalia se todos as revalorizações tiveram o mesmo Status de retorno
			If lStatusUnico
				lStatusUnico := Empty(cStatusBkp) .Or. cStatusBkp == cStatus
			EndIf

			If !Empty(cMensagem)
				nIndReval++
				aAdd(aDados, JSonObject():New())

				// cLegenda
				// 1-Erro
				// 2-Informação (falta de dados ou validação)
				// 3-Sucesso

				// Para o FRONTEND, os status 4, 5, 6 e 7 serão considerados como 2-Informação (falta de dados ou validação)
				cLegenda := IIf(cStatus $ "2|4|5|6|7", "2", cStatus)

				aDados[nIndReval]["cliente"]  := JConvUTF8(NT0->(NT0_CCLIEN) + IIf(!lLojaAuto, "/" + NT0->(NT0_CLOJA), ""))
				aDados[nIndReval]["contrato"] := JConvUTF8(NT0->(NT0_COD))
				aDados[nIndReval]["situacao"] := JConvUTF8(cMensagem)
				aDados[nIndReval]["legenda"]  := JConvUTF8(cLegenda)
				aDados[nIndReval]["status"]   := JConvUTF8(cStatus)
			EndIf
		EndIf
	Next
	
	// Se em todas as execuções o status e mensagem foi a mesma, o sistema apresentará uma mensagem única genérica
	// ao invés de gerar o log para todos os registros
	If lStatusUnico
		aDados := JRevStsUni(cStatus)
	EndIf

	RestArea(aAreaNT0)
	RestArea(aArea)

Return aDados

//-------------------------------------------------------------------
/*/{Protheus.doc} JRevStsUni
Monta mensagem de revalorização quando o status de todas as 
revalorizações foi o mesmo

@param cStatus - Status da revalorização

@param aReval - Array com a estrutura Json de mensagens de retorno

@author Reginaldo Borges
@since  26/01/2024
/*/
//-------------------------------------------------------------------
Static Function JRevStsUni(cStatus)
Local cMensagem := ""
Local aReval    := {}

	// cStatus - Usada para identificar o tipo de mensagem que será apresentada no front
	If cStatus == "1"
		cMensagem := STR0016 // "Houve erro na revalorização dos Timesheets dos contratos selecionados."
	ElseIf cStatus == "2"
		cMensagem := STR0017 // "Não há dados para revalorização de Timesheets dos contratos selecionados."
	ElseIf cStatus == "3"
		cMensagem := STR0018 // "Timesheets revalorizados com sucesso para os contratos selecionados."
	ElseIf cStatus == "4"
		cMensagem := STR0019 // "Não foi possível revalorizar os Timesheets dos contratos selecionados devido a vínculo com pré-fatura em revisão."
	ElseIf cStatus == "5"
		cMensagem := STR0020 // "Não foi possível revalorizar os Timesheets dos contratos selecionados por falta de permissão para alterar e revalorizar os Timesheets."
	ElseIf cStatus == "6"
		cMensagem := STR0021 // "Não foi possível revalorizar alguns dos Timesheets dos contratos selecionados. Usuário sem  de permissão para alterar os Timesheets."
	ElseIf cStatus == "7"
		cMensagem := STR0022 // "Os Timesheets dos contratos selecionados não foram revalorizados."
	EndIf

	// cLegenda
	// 1-Erro
	// 2-Informação (falta de dados ou validação)
	// 3-Sucesso

	// Para o FRONTEND, os status 4, 5, 6 e 7 serão considerados como 2-Informação (falta de dados ou validação)
	If cStatus $ "2|4|5|6|7"
		cLegenda := "2"
	Else
		cLegenda := cStatus
	EndIf

	aAdd(aReval, JSonObject():New())
	aReval[1]["cliente"]  := ""
	aReval[1]["contrato"] := ""
	aReval[1]["situacao"] := JConvUTF8(cMensagem)
	aReval[1]["legenda"]  := JConvUTF8(cLegenda)
	aReval[1]["status"]   := JConvUTF8(cStatus)

Return aReval

//-------------------------------------------------------------------
/*/{Protheus.doc} GET NUTCas
Retorna uma lista com os casos vinculados ao contrato.

@example GET -> http://127.0.0.1:9090/rest/WSPfsAppContrato/casosvinc/{chaveContr}
@param chaveContr - Chave do Contrato (Filial + Codigo do Contrato)

@author Victor Hayashi
@since  26/12/2023
/*/
//-------------------------------------------------------------------
WSMethod GET NUTCas PATHPARAM chaveContrato QUERYPARAM valorDig, pageSize, page, count WSREST WSPfsAppContrato
Local oResponse   := JSonObject():New()
Local lCount      := Iif(Empty(Self:count), .F., Self:count)
Local cChaveContr := Decode64(Self:chaveContrato)
Local cSearchKey  := Self:valorDig
Local nPage       := Iif(Empty(Self:page), 1, Val(Self:page))
Local nPageSize   := Iif(Empty(Self:pageSize), 5, Val(Self:pageSize))
Local nTamFilial  := TamSX3("NT0_FILIAL")[1]
Local nTamCodCtr  := TamSX3("NT0_COD")[1]
Local cFilCtr     := Substr(cChaveContr, 1, nTamFilial)
Local cCodCtr     := Substr(cChaveContr, nTamFilial + 1, nTamCodCtr)
Local aResult     := {}

	oResponse['casos'] := {}
	Aadd(oResponse['casos'], JsonObject():New())

	aResult := JCasxContr(cFilCtr, cCodCtr, cSearchKey, nPage, nPageSize, lCount)

	oResponse['casos']   := aResult[1]

	If !lCount
		oResponse['hasNext'] := aResult[2]
	EndIf

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
	oResponse := Nil

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JCasxContr
Lista com os casos x contr

@param cFilCtr   , Filial do Contrato
@param cCodCtr   , Código do contrato
@param cSearchKey, String com a pesquisa
@param nPage     , Valor da pagina atual
@param nPageSize , Quantidade de resgitro por pagina
@param lCount    , Indica se o retorno é o total de registros ou os registros

@author Reginaldo Borges
@since  26/01/2024
/*/
//-------------------------------------------------------------------
Static Function JCasxContr(cFilCtr, cCodCtr, cSearchKey, nPage, nPageSize, lCount)
Local oCasoCtr    := Nil
Local cTpDtBase   :=  AllTrim(Upper(TCGetDB()))
Local cQuery      := ""
Local cCpoCstFlds := "" // Campos customizados para o SELECT
Local cTipo       := ""
Local cMemoCst    := ""
Local nIndJson    := 0
Local nParam      := 0
Local nCont       := 0
Local nQtdReg     := 0
Local nQtdRegIni  := 0
Local nQtdRegFim  := 0
Local nX          := 0 // Contador para varrer os arrays de tabelas
Local cAliasQry   := GetNextAlias()
Local aCasos      := {}
Local aRet        := {}
Local lHasNext    := .F.
Local aCustomFlds := {}

	cFilCtr := Padr(cFilCtr,TamSx3("NT0_FILIAL")[1])
	cCodCtr := Padr(cCodCtr,TamSx3("NT0_COD")[1])

	// Retorno
	If lCount
		cQuery := " SELECT COUNT(*) TOTAL"
	Else
		// Pega os campos customizados
		aCustomFlds := JGtExtFlds("NUT", .F., .T., .F. )[1]

		For nX := 1 to Len(aCustomFlds)
			If getSx3Cache(aCustomFlds[nX][1], 'X3_CONTEXT') == "R"
				cCpoCstFlds += aCustomFlds[nX][1] + "," // Como o campo é adicionado sempre no começo da query não precisa tratar a ultima posição
			EndIf
		Next nX

		cQuery := " SELECT ?"
		cQuery +=        " NUT.NUT_FILIAL,"
		cQuery +=        " NUT.NUT_CCONTR,"
		cQuery +=        " NVE.NVE_CCLIEN,"
		cQuery +=        " NVE.NVE_LCLIEN,"
		cQuery +=        " SA1.A1_NOME,"
		cQuery +=        " NVE.NVE_NUMCAS,"
		cQuery +=        " NVE.NVE_TITULO,"
		cQuery +=        " NVE.NVE_CPART1,"
		cQuery +=        " RD0.RD0_SIGLA,"
		cQuery +=        " RD0.RD0_NOME"
	EndIf

	cQuery +=   " FROM " + RetSqlName("NUT") + " NUT"
	cQuery +=  " INNER JOIN " + RetSqlName("NVE") + " NVE"
	cQuery +=     " ON NVE.NVE_FILIAL = NUT.NUT_FILIAL"
	cQuery +=    " AND NVE.NVE_CCLIEN = NUT.NUT_CCLIEN"
	cQuery +=    " AND NVE.NVE_LCLIEN = NUT.NUT_CLOJA"
	cQuery +=    " AND NVE.NVE_NUMCAS = NUT.NUT_CCASO"
	cQuery +=    " AND NVE.D_E_L_E_T_ = ' '"
	cQuery +=  " INNER JOIN " + RetSqlName("RD0") + "  RD0"
	cQuery +=     " ON (RD0.RD0_CODIGO = NVE.NVE_CPART1"
	cQuery +=    " AND RD0.RD0_FILIAL = ?" // xFilial("RD0")
	cQuery +=    " AND RD0.D_E_L_E_T_ = ' ' )"
	cQuery +=  " INNER JOIN " + RetSqlName("SA1") + " SA1"
	cQuery +=     " ON SA1.A1_FILIAL = ?" // xFilial("SA1")
	cQuery +=    " AND SA1.A1_COD = NVE.NVE_CCLIEN"
	cQuery +=    " AND SA1.A1_LOJA = NVE.NVE_LCLIEN"
	cQuery +=    " AND SA1.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE NUT.NUT_FILIAL = ?"
	cQuery +=    " AND NUT.NUT_CCONTR = ?"
	cQuery +=    " AND NUT.D_E_L_E_T_ = ' '"

	If !lCount
		// Monta o filtro informado
		If !Empty(cSearchKey)
			cSearchKey := "%" + Lower(StrTran(JurLmpCpo( cSearchKey,.F. ),'#','')) + "%"
			cQuery += " AND ( LOWER(NVE_CCLIEN) LIKE ?" // "%" + cSearchKey + "%"
			cQuery +=        " OR LOWER(NVE_LCLIEN) LIKE ?" // "%" + cSearchKey + "%"
			cQuery +=        " OR ? LIKE ?" // "%" + cSearchKey + "%"
			cQuery +=        " OR ? LIKE ?" // "%" + cSearchKey + "%"
			cQuery +=        " OR ? LIKE ?" // "%" + cSearchKey + "%"
			cQuery +=        " OR ? LIKE ?" // "%" + cSearchKey + "%"
			cQuery +=        " OR ? LIKE ?" // "%" + cSearchKey + "%"
			cQuery +=        " OR ? LIKE ?" // "%" + cSearchKey + "%"
			cQuery +=        " OR ? LIKE ?" // "%" + cSearchKey + "%"

			//------ CAMPOS ADICIONAIS
			If !Empty(aCustomFlds)
				For nX := 1 to Len(aCustomFlds)
					If getSx3Cache(aCustomFlds[nX][1], 'X3_CONTEXT') == "R"
						cQuery += " OR ? LIKE ?" // "%" + cSearchKey + "%"
					EndIf
				Next nX
			EndIf

			cQuery +=  ")"
		EndIf

	EndIf

	oCasoCtr := FWPreparedStatement():New(cQuery)

	If !lCount
		oCasoCtr:SetUnsafe(++nParam, cCpoCstFlds)
	Endif

	oCasoCtr:SetString(++nParam, xFilial("RD0"))
	oCasoCtr:SetString(++nParam, xFilial("SA1"))
	oCasoCtr:SetString(++nParam, cFilCtr)
	oCasoCtr:SetString(++nParam, cCodCtr)

	If !lCount .And. !Empty(cSearchKey)
		For nCont := 1 To 2
			oCasoCtr:SetString(++nParam, cSearchKey)
		Next nCont


		oCasoCtr:SetUnsafe(++nParam, JurFormat("A1_NOME", .T.,.T.))
		oCasoCtr:SetString(++nParam, cSearchKey)
		oCasoCtr:SetUnsafe(++nParam, JurFormat("A1_NREDUZ", .T.,.T.))
		oCasoCtr:SetString(++nParam, cSearchKey)
		oCasoCtr:SetUnsafe(++nParam, JurFormat("NVE_TITULO", .T.,.T.))
		oCasoCtr:SetString(++nParam, cSearchKey)
		oCasoCtr:SetUnsafe(++nParam, JurFormat("NVE_NUMCAS", .T.,.T.))
		oCasoCtr:SetString(++nParam, cSearchKey)
		oCasoCtr:SetUnsafe(++nParam, JurFormat("RD0_SIGLA", .T.,.T.))
		oCasoCtr:SetString(++nParam, cSearchKey)
		oCasoCtr:SetUnsafe(++nParam, JurFormat("RD0_NOME", .T.,.T.))
		oCasoCtr:SetString(++nParam, cSearchKey)

		If cTpDtBase == "ORACLE"
			oCasoCtr:SetUnsafe(++nParam, JurFormat("NVE_CCLIEN||NVE_LCLIEN||NVE_NUMCAS", .T.,.T.))
		ElseIf cTpDtBase == "MSSQL"
			oCasoCtr:SetUnsafe(++nParam, JurFormat("NVE_CCLIEN+NVE_LCLIEN+NVE_NUMCAS", .T.,.T.))
		EndIf

		oCasoCtr:SetString(++nParam, cSearchKey)

		//------ CAMPOS ADICIONAIS
		If !Empty(aCustomFlds)
			For nX := 1 to Len(aCustomFlds)
				If getSx3Cache(aCustomFlds[nX][1], 'X3_CONTEXT') == "R"
					oCasoCtr:SetUnsafe(++nParam, aCustomFlds[nX][1])
					oCasoCtr:SetString(++nParam, cSearchKey)
				EndIf
			Next nX
		EndIf

	EndIf

	cQuery := oCasoCtr:GetFixQuery()

	MpSysOpenQuery(cQuery, cAliasQry)

	nQtdRegIni := ((nPage) * nPageSize) - nPageSize
	nQtdRegFim := (nPage * nPageSize)

	While !(cAliasQry)->(Eof()) .And. nQtdReg < nQtdRegFim + 1
		nQtdReg++
		// Verifica se o registro está no range da pagina
		If (nQtdReg > nQtdRegIni .AND. nQtdReg <= nQtdRegFim)
			nIndJson++
			aAdd(aCasos, JSonObject():New())

			If lCount
				aCasos[nIndJson]['totalReg']    := JConvUTF8(cValToChar((cAliasQry)->TOTAL))
			Else

				aCasos[nIndJson]['chaveNUT']    := Encode64((cAliasQry)->NUT_FILIAL + (cAliasQry)->NVE_CCLIEN + (cAliasQry)->NVE_LCLIEN + (cAliasQry)->NUT_CCONTR + (cAliasQry)->NVE_NUMCAS) // NUT_FILIAL + NUT_CCONTR + NUT_CCASO
				aCasos[nIndJson]['codCliente']  := JConvUTF8((cAliasQry)->NVE_CCLIEN)
				aCasos[nIndJson]['lojaCliente'] := JConvUTF8((cAliasQry)->NVE_LCLIEN)
				aCasos[nIndJson]['nomeCliente'] := JConvUTF8((cAliasQry)->A1_NOME)
				aCasos[nIndJson]['codCaso']     := JConvUTF8((cAliasQry)->NVE_NUMCAS)
				aCasos[nIndJson]['tituloCaso']  := JConvUTF8((cAliasQry)->NVE_TITULO)
				aCasos[nIndJson]['codSocio']    := JConvUTF8((cAliasQry)->NVE_CPART1)
				aCasos[nIndJson]['nomeSocio']   := JConvUTF8((cAliasQry)->RD0_NOME)
				aCasos[nIndJson]['siglaSocio']  := JConvUTF8((cAliasQry)->RD0_SIGLA)

				//------ CAMPOS ADICIONAIS
				If !Empty(aCustomFlds)
					For nX := 1 to Len(aCustomFlds)
						If getSx3Cache(aCustomFlds[nX][1], 'X3_CONTEXT') == "R"
							cTipo := getSx3Cache(aCustomFlds[nX][1], 'X3_TIPO')
							If cTipo == 'N'
								aCasos[nIndJson][aCustomFlds[nX][1]]     := JConvUTF8(cValToChar((cAliasQry)->(FieldGet(FieldPos(aCustomFlds[nX][1])))))
							ElseIf cTipo == 'M'
								// Obtenção das informações dos campos MEMO
								NUT->(DbSetOrder(3)) // NUT_FILIAL, NUT_CCONTR, NUT_CCLIEN, NUT_CLOJA, NUT_CCASO
								If (NUT->(DbSeek((cAliasQry)->NUT_FILIAL + (cAliasQry)->NUT_CCONTR + (cAliasQry)->NVE_CCLIEN + (cAliasQry)->NVE_LCLIEN + (cAliasQry)->NVE_NUMCAS)))
									cMemoCst := NUT->(FieldGet(FieldPos(aCustomFlds[nX][1])))
									aCasos[nIndJson][aCustomFlds[nX][1]] := JConvUTF8(cMemoCst)
								EndIf
							Else
								aCasos[nIndJson][aCustomFlds[nX][1]]     := JConvUTF8((cAliasQry)->(FieldGet(FieldPos(aCustomFlds[nX][1]))))
							EndIf
						EndIf
					Next nX
				EndIf

			EndIf
		ElseIf (nQtdReg == nQtdRegFim + 1)
			lHasNext := .T.
		EndIf

		(cAliasQry)->(dbSkip())
	EndDo

	If lCount
		aRet := {aCasos}
	Else
		aRet := {aCasos, lHasNext}
	EndIf

	(cAliasQry)->(dbCloseArea())

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GET NW3Ctr
Retorna uma lista com os casos vinculados ao contrato.

@example GET -> http://127.0.0.1:9090/rest/WSPfsAppContrato/ctrvinc/{chaveContr}
@param chaveContr - Chave do Contrato (Filial + Codigo do Contrato)

@author Victor Hayashi
@since  26/12/2023
/*/
//-------------------------------------------------------------------
WSMethod GET NW3Ctr PATHPARAM chaveContrato QUERYPARAM valorDig, pageSize, page WSREST WSPfsAppContrato
Local oResponse   := JSonObject():New()
Local cChaveContr := Decode64(Self:chaveContrato)
Local cSearchKey  := Self:valorDig
Local nPage       := Iif(Empty(Self:page), 1, Val(Self:page))
Local nPageSize   := Iif(Empty(Self:pageSize), 5, Val(Self:pageSize))
Local nTamFilial  := TamSX3("NT0_FILIAL")[1]
Local nTamCodCtr  := TamSX3("NT0_COD")[1]
Local cFilCtr     := Substr(cChaveContr, 1, nTamFilial)
Local cCodCtr     := Substr(cChaveContr, nTamFilial + 1, nTamCodCtr)
Local aResult     := {}

	oResponse['juncao'] := {}
	Aadd(oResponse['juncao'], JsonObject():New())

	aResult := JJuncxCtr(cFilCtr, cCodCtr, cSearchKey, nPage, nPageSize)
	oResponse['juncao']  := aResult[1]
	oResponse['hasNext'] := aResult[2]

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
	oResponse := Nil

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} JJuncxCtr
Lista com os casos x contr

@param cFilCtr, Filial do Contrato
@param cCodCtr, Código do contrato

@author Reginaldo Borges
@since  26/01/2024
/*/
//-------------------------------------------------------------------
Static Function JJuncxCtr(cFilCtr, cCodCtr, cSearchKey, nPage, nPageSize)
Local oJuncCtr    := Nil
Local cQuery      := ""
Local cCpoCstFlds := "" // Campos customizados para o SELECT
Local cTipo       := ""
Local nIndJson    := 0
Local nParam      := 0
Local nQtdReg     := 0
Local nQtdRegIni  := 0
Local nQtdRegFim  := 0
Local nX          := 0 // Contador para varrer os arrays de tabelas
Local nY          := 0 // Contador para varrer os arrays de campos
Local cAliasQry   := GetNextAlias()
Local aCustomFlds := JGtExtFlds("NW2|NW3", .F., .T., .F. )
Local aJuncCtr    := {}
Local aRet        := {}
Local lHasNext    := .F.

	cFilCtr := Padr(cFilCtr,TamSx3("NT0_FILIAL")[1])
	cCodCtr := Padr(cCodCtr,TamSx3("NT0_COD")[1])

	// Pega os campos customizados
	For nX := 1 to Len(aCustomFlds)
		For nY := 1 to Len(aCustomFlds[nX])
			If getSx3Cache(aCustomFlds[nX][nY][1], 'X3_CONTEXT') == "R"
				cCpoCstFlds += aCustomFlds[nX][nY][1] + "," // Como o campo é adicionado sempre no começo da query não precisa tratar a ultima posição
			EndIf
		Next nY
	Next nX

	cQuery := " SELECT ?"
	cQuery +=        " NW3.NW3_CJCONT,"
	cQuery +=        " NW2.NW2_DESC,"
	cQuery +=        " NW3.NW3_CCONTR,"
	cQuery +=        " NT0.NT0_NOME"
	cQuery +=   " FROM " + RetSqlName("NW3") + " NW3"
	cQuery +=  " INNER JOIN " + RetSqlName("NW2") + " NW2"
	cQuery +=     " ON NW2.NW2_FILIAL = NW3.NW3_FILIAL"
	cQuery +=    " AND NW2.NW2_COD = NW3.NW3_CJCONT"
	cQuery +=    " AND NW2.D_E_L_E_T_ = ' '"
	cQuery +=  " INNER JOIN " + RetSqlName("NT0") + " NT0"
	cQuery +=     " ON NT0.NT0_FILIAL = NW3.NW3_FILIAL"
	cQuery +=    " AND NT0.NT0_COD = NW3.NW3_CCONTR"
	cQuery +=    " AND NT0.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE NW3.NW3_FILIAL = ?" // xFilial("NW3")
	cQuery +=    " AND NW3.NW3_CJCONT = "
	cQuery +=          " (SELECT SUB.NW3_CJCONT"
	cQuery +=             " FROM " + RetSqlName("NW3") + " SUB"
	cQuery +=            " WHERE SUB.NW3_FILIAL = ?" // cFilCtr
	cQuery +=              " AND SUB.NW3_CCONTR = ?" // cCodCtr
	cQuery +=              " AND SUB.D_E_L_E_T_ = ' ')"
	cQuery +=    " AND NW3.D_E_L_E_T_ = ' '"

	// Monta o filtro informado
	If !Empty(cSearchKey)
		cSearchKey := "%" + Lower(StrTran(JurLmpCpo( cSearchKey,.F. ),'#','')) + "%"
		cQuery += " AND ( LOWER(NW3_CJCONT) LIKE ?" // cSearchKey
		cQuery +=        " OR LOWER(NW3_CCONTR) LIKE ?" // cSearchKey
		cQuery +=        " OR ? LIKE ?" // JurFormat("NW2_DESC", .T.,.T.) # cSearchKey
		cQuery +=        " OR ? LIKE ?" // JurFormat("NT0_NOME", .T.,.T.) # cSearchKey
		cQuery +=  ")"
	EndIf

	cQuery += " ORDER BY NW3_FILIAL, NW3_CJCONT, NW3_CCONTR"

	oJuncCtr := FWPreparedStatement():New(cQuery)

	oJuncCtr:SetUnsafe(++nParam, cCpoCstFlds)
	oJuncCtr:SetString(++nParam, xFilial("RD0"))
	oJuncCtr:SetString(++nParam, cFilCtr)
	oJuncCtr:SetString(++nParam, cCodCtr)


	If !Empty(cSearchKey)
		oJuncCtr:SetString(++nParam, cSearchKey)
		oJuncCtr:SetString(++nParam, cSearchKey)
		oJuncCtr:SetString(++nParam, JurFormat("NW2_DESC", .T.,.T.))
		oJuncCtr:SetString(++nParam, cSearchKey)
		oJuncCtr:SetString(++nParam, JurFormat("NT0_NOME" , .T.,.T.))
		oJuncCtr:SetString(++nParam, cSearchKey)
	EndIf

	cQuery := oJuncCtr:GetFixQuery()

	MpSysOpenQuery(cQuery, cAliasQry)

	nQtdRegIni := ((nPage) * nPageSize) - nPageSize
	nQtdRegFim := (nPage * nPageSize)

	While !(cAliasQry)->(Eof()) .And. nQtdReg < nQtdRegFim + 1
		nQtdReg++
		// Verifica se o registro está no range da pagina
		If (nQtdReg > nQtdRegIni .AND. nQtdReg <= nQtdRegFim)
			nIndJson++
			aAdd(aJuncCtr, JSonObject():New())

			aJuncCtr[nIndJson]['codJunc']   := JConvUTF8((cAliasQry)->NW3_CJCONT)
			aJuncCtr[nIndJson]['descJunc']  := JConvUTF8((cAliasQry)->NW2_DESC)
			aJuncCtr[nIndJson]['codContr']  := JConvUTF8((cAliasQry)->NW3_CCONTR)
			aJuncCtr[nIndJson]['descContr'] := JConvUTF8((cAliasQry)->NT0_NOME)

		//------ CAMPOS ADICIONAIS
		If !Empty(aCustomFlds)
			For nX := 1 to Len(aCustomFlds)
				For nY := 1 to Len(aCustomFlds[nX])
						If getSx3Cache(aCustomFlds[nX][nY][1], 'X3_CONTEXT') == "R"
							cTipo := getSx3Cache(aCustomFlds[nX][nY][1], 'X3_TIPO')
							If cTipo == 'N'
								aJuncCtr[nIndJson][aCustomFlds[nX][nY][1]] := JConvUTF8(cValToChar((cAliasQry)->(FieldGet(FieldPos(aCustomFlds[nX][nY][1])))))
							ElseIf cTipo == 'M'
								// Obtenção das informações dos campos MEMO
								If Substr(aCustomFlds[nX][nY][1],1,3) == "NW2"
									NW2->(DbSetOrder(1)) // NW2_FILIAL, NW2_COD
									If (NW2->(DbSeek(xFilial("NW2") + (cAliasQry)->NW3_CJCONT)))
										cMemoCst := NW2->(FieldGet(FieldPos(aCustomFlds[nX][nY][1])))
									EndIf
								Else
									NW3->(DbSetOrder(1)) // NW3_FILIAL, NW3_CJCONT, NW3_CCONTR
									If (NW3->(DbSeek(xFilial("NW3") + (cAliasQry)->NW3_CJCONT + (cAliasQry)->NW3_CCONTR)))
										cMemoCst := NW3->(FieldGet(FieldPos(aCustomFlds[nX][nY][1])))
									EndIf
								EndIf
								aJuncCtr[nIndJson][aCustomFlds[nX][nY][1]] := JConvUTF8(cMemoCst)
							Else
								aJuncCtr[nIndJson][aCustomFlds[nX][nY][1]] := JConvUTF8((cAliasQry)->(FieldGet(FieldPos(aCustomFlds[nX][nY][1]))))
							EndIf
						EndIf
				Next nY
			Next nX
		EndIf

		ElseIf (nQtdReg == nQtdRegFim + 1)
			lHasNext := .T.
		EndIf

		(cAliasQry)->(dbSkip())
	EndDo

	(cAliasQry)->(dbCloseArea())

	aRet := {aJuncCtr, lHasNext}

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GET lsCtr
Busca a lista de clientes cadastrados.

@example GET -> http://127.0.0.1:9090/rest/WSPfsAppContrato/listaContrato

@param valorDig    - QueryParam - valor digitado pelo usuario para pesquisa
@param filtraAtivo - QueryParam - indica se deve filtrar apenas os registros ativos e desbloqueados
@param filtercpo   - QueryParam - indica os campos adicionais do filtro (obs mesma ordem dos valores em filterinfo)
@param filterinfo  - QueryParam - indica as informações adicionais para serem filtradas (obs mesma ordem dos valores em filtercpo)
@param pageSize    - QueryParam - Quantidade de registros que retornarão da api

@author Victor Hayashi
@since  07/03/2024
/*/
//-------------------------------------------------------------------
WSMethod GET lsCtr QUERYPARAM valorDig, filtraAtivo, filtercpo, filterinfo, pageSize WSREST WSPfsAppContrato
Local oResponse   := JSonObject():New() // Objeto JSON de retorno
Local oContrato   := Nil // Objeto de Query do cliente
Local cSearchKey  := Self:valorDig // Valor digitado para busca de cliente
Local cQuery      := "" // Armazena a query de clientes
Local cFilSA1     := ""
Local cAliasQry   := GetNextAlias() // Alias para a query
Local cTpDtBase   := AllTrim(Upper(TCGetDB())) // Tipo de database do sistema
Local lFilAtivo   := Self:filtraAtivo == 'true' // Indica se será filtrado apenas clientes ativos/desbloqueados
Local aCpoFiltro  := Iif(Empty(Self:filtercpo), {}, StrToArray(Self:filtercpo, ",")) // Campos da clausula 'WHERE'
Local aInfFiltro  := Iif(Empty(Self:filterinfo), {}, StrToArray(Self:filterinfo, ",")) // Valores da clausula 'WHERE'
Local aFiliais    := UsrFilial()
Local nPage       := Iif(Empty(Self:pageSize), 10, Val(Self:pageSize)) // Quantidade de registros que retornarão da api
Local nParam      := 0 // Contador para o Bind Parameters
Local nX          := 0 // Contador para o For
Local nIndJson    := 0 // Indice do Obj Json
Local nIndFilSA1  := 0
Local lLojaAuto   := SuperGetMv("MV_JLOJAUT", .F., "2",) == '1' // Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)

	cQuery := " SELECT NT0.NT0_FILIAL,"
	cQuery +=        " NT0.NT0_COD,"
	cQuery +=        " NT0.NT0_NOME,"
	cQuery +=        " NT0.NT0_CCLIEN,"
	cQuery +=        " NT0.NT0_CLOJA,"
	cQuery +=        " SA1.A1_FILIAL,"
	cQuery +=        " SA1.A1_NOME,"
	cQuery +=        " NT0.NT0_SIT,"
	cQuery +=        " NT0.NT0_CTPHON,"
	cQuery +=        " NRA.NRA_DESC,"
	cQuery +=        " NRA.NRA_COBRAH,"
	cQuery +=        " NT0.NT0_DESPES,"
	cQuery +=        " NT0.NT0_SERTAB,"
	cQuery +=        " NT0.NT0_CPART1,"
	cQuery +=        " RD0.RD0_NOME,"
	cQuery +=        " RD0.RD0_SIGLA,"
	cQuery +=        " NT0.NT0_ATIVO,"
	cQuery +=        " NT0.NT0_DTVIGI,"
	cQuery +=        " NT0.NT0_DTVIGF"
	cQuery +=  " FROM " + RetSqlName("NT0") + " NT0"
	cQuery += " INNER JOIN " + RetSqlName("SA1") + " SA1"
	cQuery +=    " ON SA1.A1_COD = NT0.NT0_CCLIEN"
	cQuery +=   " AND SA1.A1_LOJA = NT0.NT0_CLOJA"
	cQuery +=   " AND SA1.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN " + RetSqlName("RD0") + " RD0"
	cQuery +=    " ON (RD0.RD0_CODIGO = NT0.NT0_CPART1"
	cQuery +=   " AND RD0.D_E_L_E_T_ = ' ' )"
	cQuery += " INNER JOIN " + RetSqlName("NRA") + " NRA"
	cQuery +=    " ON NRA.NRA_FILIAL = ' '"
	cQuery +=   " AND NRA.NRA_COD = NT0.NT0_CTPHON"
	cQuery +=   " AND NRA.D_E_L_E_T_ = ' '"
	cQuery += " WHERE NT0.D_E_L_E_T_ = ' '"

	// Filtra os registros bloqueados/inativos
	If (lFilAtivo)
		cQuery +=    " AND NT0.NT0_ATIVO = '1'"
	EndIf

	// Monta os filtros informados
	For nX := 1 to Len(aCpoFiltro)
		cQuery +=  " AND ? = ?"
	Next nX

	// Pesquisa por valor digitado
	If !Empty(cSearchKey)
		cSearchKey := "%" + Lower(StrTran(JurLmpCpo( cSearchKey,.F. ),'#','')) + "%"
		
		cQuery += " AND ( LOWER(NT0.NT0_COD) LIKE ?" // "%" + cSearchKey + "%"
		cQuery +=        " OR ? LIKE ?" // "%" + cSearchKey + "%"
		cQuery +=        " OR ? LIKE ?" // "%" + cSearchKey + "%"
		cQuery +=        " OR ? LIKE ?" // "%" + cSearchKey + "%"
		cQuery += ")"
	EndIf

	cQuery +=  " ORDER BY NT0.NT0_COD"

	oContrato := FWPreparedStatement():New(cQuery)

	// Campos e valores da clausula 'WHERE'
	For nX := 1 To Len(aCpoFiltro)
		oContrato:SetUnsafe(++nParam, aCpoFiltro[nX])
		oContrato:SetString(++nParam, aInfFiltro[nX])
	Next nX
	
	// Informações digitadas pelo usuario
	If !Empty(cSearchKey)
		oContrato:SetString(++nParam, cSearchKey)
		oContrato:SetUnsafe(++nParam, JurFormat("NT0_NOME", .T.,.T.))
		oContrato:SetString(++nParam, cSearchKey)
		oContrato:SetUnsafe(++nParam, JurFormat("A1_NOME", .T.,.T.))
		oContrato:SetString(++nParam, cSearchKey)
		If cTpDtBase == "ORACLE"
			oContrato:SetUnsafe(++nParam, JurFormat("NT0_CCLIEN||NT0_CLOJA", .T.,.T.))
		ElseIf cTpDtBase == "MSSQL"
			oContrato:SetUnsafe(++nParam, JurFormat("NT0_CCLIEN+NT0_CLOJA", .T.,.T.))
		EndIf
			oContrato:SetString(++nParam, cSearchKey)
	EndIf

	cQuery := oContrato:GetFixQuery()

	MpSysOpenQuery(cQuery, cAliasQry)

	oResponse['contrato'] := {}

	While !(cAliasQry)->(Eof()) .And. nIndJson < nPage
		nIndJson++
		nIndFilSA1 := aScan(aFiliais, {|x| AllTrim((cAliasQry)->A1_FILIAL) $ x['filial'] })
		cFilSA1    := IIf(nIndFilSA1 == 0, cFilAnt, aFiliais[nIndFilSA1]['filial'])
		aAdd(oResponse["contrato"], JsonObject():New())

		oResponse['contrato'][nIndJson]['filialDoRegistro']  := JConvUTF8((cAliasQry)->NT0_FILIAL)
		oResponse['contrato'][nIndJson]['chave']             := Encode64((cAliasQry)->NT0_FILIAL + (cAliasQry)->NT0_COD)
		oResponse['contrato'][nIndJson]['filialCliente']     := JConvUTF8(cFilSA1)
		oResponse['contrato'][nIndJson]['codigoCliente']     := JConvUTF8((cAliasQry)->NT0_CCLIEN)
		If !lLojaAuto
			oResponse['contrato'][nIndJson]['codigoCliente'] := oResponse['contrato'][nIndJson]['codigoCliente'] + "/" + (cAliasQry)->NT0_CLOJA
		EndIf
		oResponse['contrato'][nIndJson]['nomeCliente']       := JConvUTF8((cAliasQry)->A1_NOME)
		oResponse['contrato'][nIndJson]['codContrato']       := JConvUTF8((cAliasQry)->NT0_COD)
		oResponse['contrato'][nIndJson]['descContrato']      := JConvUTF8((cAliasQry)->NT0_NOME)
		oResponse['contrato'][nIndJson]['situacao']          := JConvUTF8((cAliasQry)->NT0_SIT)
		oResponse['contrato'][nIndJson]['codTpHon']          := JConvUTF8((cAliasQry)->NT0_CTPHON)
		oResponse['contrato'][nIndJson]['descTpHon']         := JConvUTF8((cAliasQry)->NRA_DESC)
		oResponse['contrato'][nIndJson]['cobHora']           := JConvUTF8((cAliasQry)->NRA_COBRAH)
		oResponse['contrato'][nIndJson]['cobDespesa']        := JConvUTF8((cAliasQry)->NT0_DESPES)
		oResponse['contrato'][nIndJson]['cobServTab']        := JConvUTF8((cAliasQry)->NT0_SERTAB)
		oResponse['contrato'][nIndJson]['codigoSocio']       := JConvUTF8((cAliasQry)->NT0_CPART1)
		oResponse['contrato'][nIndJson]['nomeSocio']         := JConvUTF8((cAliasQry)->RD0_NOME)
		oResponse['contrato'][nIndJson]['siglaSocio']        := JConvUTF8((cAliasQry)->RD0_SIGLA)
		oResponse['contrato'][nIndJson]['ativo']             := JConvUTF8((cAliasQry)->NT0_ATIVO)
		oResponse["contrato"][nIndJson]["dataIniVig"]        := JConvUTF8((cAliasQry)->NT0_DTVIGI)
		oResponse["contrato"][nIndJson]["dataFimVig"]        := JConvUTF8((cAliasQry)->NT0_DTVIGF)
		oResponse['contrato'][nIndJson]['pagadores']         := JGetPag((cAliasQry)->(NT0_FILIAL), (cAliasQry)->NT0_COD)

		(cAliasQry)->(dbSkip())
	EndDo

	(cAliasQry)->(dbCloseArea())

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
	oResponse:FromJSon("{}")
	oResponse := Nil

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} POST tpHon
Retona se o tipo de honorário cobra hora e qual o tipo de honorário 
conforme o código de honorário informado. 
Na alteração de honorário, verifica a existência de parcelas e faixas
e retorna as mensagens e um lógico para no front ser tomada a decissão
de exclusão das parcelas e faixas, quando a situação da pré-fatura permitir.

@param cargaAplicacao, Indica se é a primeira carga da aplicação(Sim=true/Não=false)

@example POST -> http://127.0.0.1:9090/rest/WSPfsAppContrato/tipoHonorario
@example Body
{
    "NT0_COD": "000247", // enviar o valor somente se não for inclusão
    "NT0_NOME": "Contrato para review",
    "NT0_CCLIEN": "RSB001",
    "NT0_CLOJA": "01",
    "NT0_CTPHON": "003",
    "NT0_CASPRO": "1",
    "NT0_TPFX": "",
    "NT0_FXENCM": "2",
    "NT0_FXABM": "2",
    "NUT": [
        {
            "NUT_CCLIEN": "RSB001",
            "NUT_CLOJA": "01",
            "NUT_CCASO": "000036"
        }
    ],
    "NTR": [
        {
            "NTR_VLINI": 0,
            "NTR_VLFIM": 1,
            "NTR_TPVL": "1",
            "NTR_VALOR": 0
        }
    ],
    "NT1": [
        {
            "NT1_DATAIN": "20220201",
            "NT1_DATAFI": "20220228",
            "NT1_CMOEDA": "01",
            "NT1_DATAAT": "20220526",
            "NT1_DATAVE": "20220526",
            "NT1_DESCRI": "Parcela 0001",
            "NT1_QTDADE": 0, // Considera o valor digitado apenas quando o parâmetro MV_JQTDAUT for igual a "2"
            "NT1_SITUAC": "1",
            "NT1_PARC": "0001",
            "NT1_SEQUEN": "00002255",
            "NT1_CPREFT": "00001327"
        },
        {
            "NT1_DATAIN": "20220301",
            "NT1_DATAFI": "20220331",
            "NT1_CMOEDA": "01",
            "NT1_DATAAT": "20220626",
            "NT1_DATAVE": "20220626",
            "NT1_DESCRI": "Parcela 0002",
            "NT1_QTDADE": 0, // Considera o valor digitado apenas quando o parâmetro MV_JQTDAUT for igual a "2"
            "NT1_SITUAC": "1",
            "NT1_PARC": "0001",
            "NT1_SEQUEN": "00002256",
            "NT1_CPREFT": ""
        }
    ]
}

@author Reginaldo Borges
@since  15/05/2024
/*/
//-------------------------------------------------------------------
WSMethod POST tpHon QUERYPARAM cargaAplicacao WSREST WSPfsAppContrato
Local oResponse  := JSonObject():New()
Local oJSonBody  := JsonObject():New()
Local cBody      := StrTran(Self:GetContent(),CHR(10),"")
Local lCargAplic := Self:cargaAplicacao
Local oTipoHon   := Nil
Local oModel096  := Nil // Modelo completo de contratos
Local oModelNT0  := Nil // Cabeçalho contrato
Local oModelNUT  := Nil // Casos vinculados ao contrato
Local oModelNTR  := Nil // Faixas de valores do contrato
Local oModelNT1  := Nil // Parcelas de fixo do contrato
Local cTipHon    := ""
Local cQuery     := ""
Local cMsgParc   := ""
Local cMsgFaixa  := ""
Local cAliasQry  := GetNextAlias()
Local nParam     := 0
Local nLine      := 0
Local nLenNUT    := 0
Local nLenNTR    := 0
Local nLenNT1    := 0
Local lCobraHora := .F. // Cobra Hora
Local lLimFatu   := .F. // Limite por Fatura
Local lLimGeral  := .F. // Limite Geral
Local lFixoPart  := .F. // Fixo Partido
Local lFixoOcor  := .F. // Fixo Ocorrencia
Local lFixoPreD  := .F. // Fixo Pré Definido
Local lvldMisto  := .F. // Variavel Auxiliar para validar a configuração de Misto
Local lMisto     := .F. // Misto
Local lvldMin    := .F. // Variavel Auxiliar para validar a configuração de Minimo
Local lMinimo    := .F. // Minimo
Local lQtdCasPrc := .F. // Faixa Valor (Casos/Processos)
Local lVldDec    := .F. // Variavel Auxiliar para validar o uso decimal no campo NTR_VLINI / NTR_VLFIM
Local lInteiro   := .F. // Indica se será usado somente numeros inteiros no campo NTR_VLINI / NTR_VLFIM
Local lVldFxVal  := .F.  // Variavel Auxiliar para validar a configuração de Faixa Valor
Local lFxValor   := .F. // Faixa Valor

	oJSonBody:fromJson(cBody)

	cTipHon := oJsonBody:getJsonObject("NT0_CTPHON")

	lCobraHora := J096CHon(cTipHon)

	cQuery := " SELECT NRA.NRA_COBRAF, NRA.NRA_COBRAH, NRA.NRA_PARCAT, NTH.NTH_CAMPO, NTH.NTH_VISIV, NTH.NTH_VLPAD, NTH.NTH_OBRIGA "
	cQuery +=   " FROM " + RetSqlName("NRA") + " NRA"
	cQuery +=  " INNER JOIN " + RetSqlName("NTH") + " NTH"
	cQuery +=     " ON NTH.NTH_FILIAL = ?"
	cQuery +=    " AND NTH.NTH_CTPHON = NRA.NRA_COD"
	cQuery +=    " AND NTH.NTH_CAMPO IN ('NT0_VLRLIF', 'NT0_VLRLI', 'NT0_PARFIX', 'NT0_QTPARC','NT0_PEREX', 'NT0_TPCEXC', 'NT0_CASPRO', 'NT0_FXABM', 'NT0_FXENCM','NT0_CALFX')"
	cQuery +=    " AND NTH.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE NRA.NRA_FILIAL = ?"
	cQuery +=    " AND NRA.NRA_COD = ?"
	cQuery +=    " AND NRA.D_E_L_E_T_ = ' '"
	cQuery +=    " ORDER BY NTH_CAMPO"

	oTipoHon :=  FWPreparedStatement():New(cQuery)

	oTipoHon:SetString(++nParam, xFilial("NTH"))
	oTipoHon:SetString(++nParam, xFilial("NRA"))
	oTipoHon:SetString(++nParam, cTipHon)

	cQuery := oTipoHon:GetFixQuery()

	MpSysOpenQuery(cQuery, cAliasQry)

	oResponse := {}
	Aadd(oResponse, JsonObject():New())

	While !(cAliasQry)->(Eof())
		Do Case
			Case AllTrim((cAliasQry)->NTH_CAMPO) = "NT0_VLRLIF" .And. (cAliasQry)->NTH_VISIV = '1'
				lLimFatu := .T.
			Case AllTrim((cAliasQry)->NTH_CAMPO) = "NT0_VLRLI" .And. (cAliasQry)->NTH_VISIV = '1'
				lLimGeral := .T.
			Case AllTrim((cAliasQry)->NTH_CAMPO) = "NT0_PARFIX" .And. (cAliasQry)->NTH_VLPAD = '1' .And. (cAliasQry)->NRA_COBRAF = '1' .And. (cAliasQry)->NRA_PARCAT = '1'
				lFixoPart := .T.
			Case AllTrim((cAliasQry)->NTH_CAMPO) = "NT0_QTPARC" .And. (cAliasQry)->NTH_VISIV = '2' .And. (cAliasQry)->NRA_COBRAF = '1' .And. (cAliasQry)->NRA_PARCAT = '2'
				lFixoOcor := .T.
			Case AllTrim((cAliasQry)->NTH_CAMPO) = "NT0_QTPARC" .And. (cAliasQry)->NTH_VISIV = '1' .And. (cAliasQry)->NRA_COBRAF = '1' .And. (cAliasQry)->NRA_PARCAT = '2'
				lFixoPreD :=  .T.
			Case AllTrim((cAliasQry)->NTH_CAMPO) = "NT0_PEREX" .And. (cAliasQry)->NTH_VISIV = '1' .And. (cAliasQry)->NRA_COBRAF = '1'.And.  (cAliasQry)->NRA_COBRAH = '1'
				lvldMisto := .T.
			Case lvldMisto .And. AllTrim((cAliasQry)->NTH_CAMPO) = "NT0_TPCEXC" .And. (cAliasQry)->NTH_VISIV = '1'
				lMisto := .T.
			Case AllTrim((cAliasQry)->NTH_CAMPO) = "NT0_PEREX" .And. (cAliasQry)->NTH_VISIV = '2' .And. (cAliasQry)->NRA_COBRAF = '1'.And.  (cAliasQry)->NRA_COBRAH = '1'
				lvldMin := .T.
			Case lvldMin .And. AllTrim((cAliasQry)->NTH_CAMPO) = "NT0_TPCEXC" .And. (cAliasQry)->NTH_VISIV = '1'
				lMinimo := .T.
			Case AllTrim((cAliasQry)->NTH_CAMPO) = "NT0_CASPRO" .And. (cAliasQry)->NTH_OBRIGA = '1'
				lQtdCasPrc := .T.
			Case AllTrim((cAliasQry)->NTH_CAMPO) = "NT0_FXABM" .And. (cAliasQry)->NTH_VISIV = '1'
				lVldDec := .T.
			Case lVldDec .And. AllTrim((cAliasQry)->NTH_CAMPO) = "NT0_FXENCM" .And. (cAliasQry)->NTH_VISIV = '1'
				lInteiro := .T.
			Case AllTrim((cAliasQry)->NTH_CAMPO) = "NT0_CALFX" .And. (cAliasQry)->NTH_OBRIGA = '1'
				lVldFxVal := .T.
			Case lVldFxVal .And. AllTrim((cAliasQry)->NTH_CAMPO) = "NT0_CASPRO" .And. (cAliasQry)->NTH_OBRIGA = '2'
				lFxValor := .T.
			OtherWise
		EndCase
		(cAliasQry)->(dbSkip())
	EndDo

	oResponse[1]["cobraHora"]         := lCobraHora 
	oResponse[1]["limiteFatura"]      := lLimFatu
	oResponse[1]["limiteGeral"]       := lLimGeral
	oResponse[1]["fixoPartido"]       := lFixoPart
	oResponse[1]["fixoPorOcorrencia"] := lFixoOcor
	oResponse[1]["fixoPreDefinido"]   := lFixoPreD
	oResponse[1]["misto"]             := lMisto
	oResponse[1]["minimo"]            := lMinimo
	oResponse[1]["faixaQtdCasProc"]   := lQtdCasPrc
	oResponse[1]["faixaValor"]        := lFxValor
	oResponse[1]["usaInteiro"]        := lInteiro

	If !lCargAplic

		oModel096 := FWLoadModel("JURA096")
		oModel096:SetOperation(MODEL_OPERATION_INSERT)
		oModel096:Activate()

		oModelNT0 := oModel096:GetModel("NT0MASTER")
		oModelNUT := oModel096:GetModel("NUTDETAIL")
		oModelNTR := oModel096:GetModel("NTRDETAIL")
		oModelNT1 := oModel096:GetModel("NT1DETAIL")

		// Cabeçalho do contrato e da aba de Faixa de Valores e Parcela de Fixo
		If !Empty(oJsonBody:getJsonObject("NT0_COD"))
			oModelNT0:LoadValue("NT0_COD", oJsonBody:getJsonObject("NT0_COD"))
		EndIf
		oModelNT0:SetValue("NT0_NOME", oJsonBody:getJsonObject("NT0_NOME"))
		oModelNT0:SetValue("NT0_CCLIEN", oJsonBody:getJsonObject("NT0_CCLIEN"))
		oModelNT0:SetValue("NT0_CLOJA", oJsonBody:getJsonObject("NT0_CLOJA"))
		oModelNT0:LoadValue("NT0_CTPHON", oJsonBody:getJsonObject("NT0_CTPHON"))
		// Campos da aba da faixa de valores
		oModelNT0:SetValue("NT0_CASPRO", oJsonBody:getJsonObject("NT0_CASPRO")) // Qtdade por: 1-Casos; 2-Processos
		oModelNT0:SetValue("NT0_TPFX", oJsonBody:getJsonObject("NT0_TPFX")) // Tipo de Faixa: 1-Tabela Estática; 2-Tabela Progressiva
		oModelNT0:SetValue("NT0_FXENCM", oJsonBody:getJsonObject("NT0_FXENCM")) // Enc período? 1-Sim; 2-Não
		oModelNT0:SetValue("NT0_FXABM", oJsonBody:getJsonObject("NT0_FXABM")) // Aber períod? 1-Sim; 2-Não

		// Casos vinculados ao contrato
		nLenNUT := Len(oJsonBody:getJsonObject("NUT"))
		For nLine := 1 To nLenNUT
			IIf(nLine > 1, oModelNUT:AddLine(), Nil)
			oModelNUT:SetValue("NUT_CCLIEN", oJsonBody:getJsonObject("NUT")[nLine]["NUT_CCLIEN"])
			oModelNUT:SetValue("NUT_CLOJA" , oJsonBody:getJsonObject("NUT")[nLine]["NUT_CLOJA"])
			oModelNUT:SetValue("NUT_CCASO" , oJsonBody:getJsonObject("NUT")[nLine]["NUT_CCASO"])
		Next nLine

		// Faixas de valores do contrato
		nLenNTR := Len(oJsonBody:getJsonObject("NTR"))
		For nLine := 1 To nLenNTR
			IIf(nLine > 1, oModelNTR:AddLine(), Nil)
			oModelNTR:SetValue("NTR_VLINI", oJsonBody:getJsonObject("NTR")[nLine]["NTR_VLINI"])
			oModelNTR:SetValue("NTR_VLFIM", oJsonBody:getJsonObject("NTR")[nLine]["NTR_VLFIM"])
			oModelNTR:SetValue("NTR_TPVL" , oJsonBody:getJsonObject("NTR")[nLine]["NTR_TPVL"])
			oModelNTR:SetValue("NTR_VALOR", oJsonBody:getJsonObject("NTR")[nLine]["NTR_VALOR"])
		Next nLine

		// Parcela de Fixo pendente do contrato
		nLenNT1 := Len(oJsonBody:getJsonObject("NT1"))
		For nLine := 1 To nLenNT1
			IIf(nLine > 1, oModelNT1:AddLine(), Nil)
			oModelNT1:SetValue("NT1_DATAIN", SToD(oJsonBody:getJsonObject("NT1")[nLine]["NT1_DATAIN"]))
			oModelNT1:SetValue("NT1_DATAFI", SToD(oJsonBody:getJsonObject("NT1")[nLine]["NT1_DATAFI"]))
			oModelNT1:SetValue("NT1_CMOEDA", oJsonBody:getJsonObject("NT1")[nLine]["NT1_CMOEDA"])
			oModelNT1:SetValue("NT1_DATAAT", SToD(oJsonBody:getJsonObject("NT1")[nLine]["NT1_DATAAT"]))
			oModelNT1:SetValue("NT1_DATAVE", SToD(oJsonBody:getJsonObject("NT1")[nLine]["NT1_DATAVE"]))
			oModelNT1:SetValue("NT1_DESCRI", oJsonBody:getJsonObject("NT1")[nLine]["NT1_DESCRI"])
			oModelNT1:SetValue("NT1_QTDADE", oJsonBody:getJsonObject("NT1")[nLine]["NT1_QTDADE"]) // Considera o valor digitado apenas quando o parâmetro MV_JQTDAUT for igual a "2"
			oModelNT1:SetValue("NT1_SITUAC", oJsonBody:getJsonObject("NT1")[nLine]["NT1_SITUAC"]) // Considera o valor digitado apenas quando o parâmetro MV_JQTDAUT for igual a "2"
			oModelNT1:SetValue("NT1_PARC"  , oJsonBody:getJsonObject("NT1")[nLine]["NT1_PARC"])   // Considera o valor digitado apenas quando o parâmetro MV_JQTDAUT for igual a "2"
			oModelNT1:SetValue("NT1_SEQUEN", oJsonBody:getJsonObject("NT1")[nLine]["NT1_SEQUEN"]) // Considera o valor digitado apenas quando o parâmetro MV_JQTDAUT for igual a "2"
			oModelNT1:SetValue("NT1_CPREFT", oJsonBody:getJsonObject("NT1")[nLine]["NT1_CPREFT"]) // Considera o valor digitado apenas quando o parâmetro MV_JQTDAUT for igual a "2"
		Next nLine

		lRet := J096VTpHon(oModel096, .T., @cMsgParc, @cMsgFaixa) // Valida os tipos de honorarios já informados e apaga as informacões geradas pelo usuario caso ele mude o tipo de honorario

		// Complementa response com retorno do modelo
		oResponse[1]["alertMsgParc"]  := JConvUTF8(cMsgParc)
		oResponse[1]["alertMsgFaixa"] := JConvUTF8(cMsgFaixa)
		oResponse[1]["lAlteraTpHon"]  := IIf(lRet, 'true', 'false')

		oModel096:DeActivate()
		oModel096:Destroy()
	EndIf

		Self:SetResponse( FWJsonSerialize(oResponse, .F., .F., .T.) )
		aSize(oResponse, 0)
		oResponse := Nil

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET CtrSJuncao
Busca os contratos que não estão vinculados a junções

@example GET -> http://127.0.0.1:9090/rest/WSPFSAPPCONTRATO/ctrsemjuncao

@author Willian Kazahaya
@since  11/06/2024
/*/
//-------------------------------------------------------------------
WSMETHOD GET CtrSJuncao QUERYPARAM valorDig, pageSize WSREST WsPfsAppContrato
Local oResponse   := JSonObject():New()
Local aArea       := GetArea()
Local cSearchKey  := Self:valorDig
Local nPageSize   := 10
Local nParam      := 0
Local cAlsContrat := ""
Local aParams     := {}
Local aQuery      := {}
Local nIndexJSon  := 0

	If (Self:pageSize != Nil)
		nPageSize := Val(Self:pageSize)
	EndIf

	aQuery  := JQryContrato(cSearchKey, , , .T., .F., "", {}, .T.)
	cQuery  := ChangeQuery(aQuery[1])
	aParams := aQuery[2]

	oContrato := FWPreparedStatement():New(cQuery)

	For nParam := 1 To Len(aParams)
		If aParams[nParam][2] == "C"
			oContrato:SetString(nParam, aParams[nParam][1])
		ElseIf aParams[nParam][2] == "U"
			oContrato:SetUnsafe(nParam, aParams[nParam][1])
		EndIf
	Next

	cQuery := oContrato:GetFixQuery()

	cAlsContrat := GetNextAlias()
	MpSysOpenQuery(cQuery, cAlsContrat)

	oResponse['contrato'] := {}
	// Monta o response
	While !(cAlsContrat)->(Eof()) .And. nIndexJSon < 10
		nIndexJSon++
		aAdd(oResponse['contrato'], JsonObject():New())
		aTail(oResponse['contrato']) := setDadosContrato( cAlsContrat )
		(cAlsContrat)->(dbSkip())
	EndDo

	(cAlsContrat)->(dbCloseArea())
	Self:SetResponse( FWJsonSerialize(oResponse, .F., .F., .T.) )
	oResponse:fromJson("{}")
	oResponse := NIL

	JurFreeArr(@aQuery)
	JurFreeArr(@aParams)

	RestArea(aArea)
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} POST JParc
Efetua 

@example POST -> http://127.0.0.1:9090/rest/WSPfsAppContrato/parcelar

@author Victor Hayashi
@since  17/06/2024
/*/
//-------------------------------------------------------------------
WSMETHOD POST JParc PATHPARAM chaveContrato WSREST WsPfsAppContrato
Local oResponse := JsonObject():New()
Local oJSonBody := JsonObject():New()
Local aRespNT1  := {}
Local aNT1Inf   := {}
Local aAuxNT1   := {}
Local aInfoApi  := {}
Local aParcNT1  := {}
Local cBody     := ""
Local cMsgRet   := ""
Local nQtdParc  := 0
Local nX        := 0
Local nBotaoAtv := 0 // 1 = Condições de Faturamento de Fixo; 2 = Faixa de Valores
Local lRet      := .T.

	cBody  := StrTran(Self:GetContent(),CHR(10),"")
	oJSonBody:fromJson(cBody)
	aNT1Inf   := oJsonBody:getJsonObject("NT1")
	nBotaoAtv := Val(oJsonBody:getJsonObject("codBtn"))
	nQtdParc  := Len(oJsonBody:getJsonObject("NT1"))

	If nQtdParc > 0
		// Define o Array Auxiliar
		aAuxNT1 := Array( nQtdParc , 6)

		For nX := 1 to Len (oJsonBody:getJsonObject("NT1"))
			aAdd(aAuxNT1, { oJsonBody:getJsonObject("NT1")[nX]["NT1_SITUAC"],; // [01]
							oJsonBody:getJsonObject("NT1")[nX]["NT1_CTPFTU"],; // [02]
							oJsonBody:getJsonObject("NT1")[nX]["NT1_PARC"  ],; // [03]
							oJsonBody:getJsonObject("NT1")[nX]["NT1_DATAIN"],; // [04]
							oJsonBody:getJsonObject("NT1")[nX]["NT1_DATAVE"],; // [05]
							oJsonBody:getJsonObject("NT1")[nX]["NT1_SEQUEN"],; // [06]
			})
		Next nX
	EndIf

	aInfoApi := {   oJsonBody["NT0_CTPHON"],; // [01]
					oJsonBody["NT0_ENCH"]  ,; // [02]
					oJsonBody["NT0_QTPARC"],; // [03]
					oJsonBody["NT0_PERFIX"],; // [04]
					oJsonBody["NT0_PERCD"] ,; // [05]
					oJsonBody["NT0_PEREX"] ,; // [06]
					oJsonBody["NT0_VLRBAS"],; // [07]
					oJsonBody["NT0_FIXEXC"],; // [08]
					oJsonBody["NT0_CMOEF"] ,; // [09]
					oJsonBody["NT0_DTREFI"],; // [10]
					oJsonBody["NT0_DESPAR"],; // [11]
					oJsonBody["NT0_CIDIO"] ,; // [12]
					oJsonBody["NT0_DTVENC"],; // [13]
					oJsonBody["NT0_DTVIGI"],; // [14]
					oJsonBody["NT0_DTVIGF"],; // [15]
					aAuxNT1;                  // [16]
		}

	// Função para Criar as parcelas
	lRet := J096Parcela(Nil, nBotaoAtv, aInfoApi, @cMsgRet, aParcNT1)
	
	If Empty(cMsgRet)

		For nX := 1 to Len (aParcNT1)
			aAdd(aRespNT1,{ aParcNT1[nX][01],;            // 01 - NT1_PARC
						    aParcNT1[nX][02],;            // 02 - NT1_CTPFTU
						    aParcNT1[nX][03],;            // 03 - NT1_DATAIN
						    aParcNT1[nX][04],;            // 04 - NT1_DATAFI
						    aParcNT1[nX][05],;            // 05 - NT1_VALORB
						    aParcNT1[nX][06],;            // 06 - NT1_VALORA
						    aParcNT1[nX][07],;            // 07 - NT1_DATAAT
						    aParcNT1[nX][08],;            // 08 - NT1_DATAVE
						    Encode64(aParcNT1[nX][09]),;  // 09 - NT1_DESCRI
						    aParcNT1[nX][10],;            // 10 - NT1_CMOEDA
						    aParcNT1[nX][11],;            // 11 - NT1_SITUAC
							JConvUTF8(aParcNT1[nX][12]);  // 12 - NT1_DMOEDA
						  })
		Next nX

		oResponse['status']   := '1' // Parcelas foram geradas
		oResponse['parcelas'] := aRespNT1
		oResponse['message']  := ""
	Else
		oResponse['status']   := '2' // Parcelas não foram geradas
		oResponse['parcelas'] := {}
		oResponse['message']  := JConvUTF8(cMsgRet)
	EndIf

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

	// Limpeza dos Objetos e Arrays
	oResponse:fromJson("{}")
	oResponse := NIL
	JurFreeArr(@aRespNT1)
	JurFreeArr(@aNT1Inf )
	JurFreeArr(@aAuxNT1 )
	JurFreeArr(@aInfoApi)
	JurFreeArr(@aParcNT1)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} POST WoFix
Efetua WO na parcela de Fixo.

@example POST -> http://127.0.0.1:9090/rest/WsPfsAppContrato/woFixo

@body {
        "infoApi": [
            {
                "codContr": "000368",
                "codSeqParc": "00002599",
                "cSituacao": "1",
                "cMsgWo": "Teste api WO na parcela de Fixo",
                "cCodMotWo": "001",
                "codPreFat": ""
            }
        ]
    }

@author Reginaldo Borges
@since  17/06/2024
/*/
//-------------------------------------------------------------------
WSMETHOD POST WoFix PATHPARAM lWoValido WSREST WsPfsAppContrato
Local oResponse := JsonObject():New()
Local oJSonBody := JsonObject():New()
Local cBody     := StrTran(Self:GetContent(),CHR(10),"")
Local lWoValido := Iif(Empty(Self:lWoValido), .F., Self:lWoValido)
Local ncountWO  := 0
Local cMsgErro  := ""
Local cImpedeWO := ""
Local lRet      := .T.
Local aBody     := {}
Local aInfoApi  := {}
Local aObsWO    := {}
Local aNovaNT1  := {}

	oJSonBody:fromJson(cBody)
	aBody := oJsonBody:getJsonObject("infoApi")

	aInfoApi  := {aBody[1]["codContr"], aBody[1]["codSeqParc"], aBody[1]["cSituacao"], aBody[1]["codPreFat"]}
	If !lWoValido
		JurSitLoad()
		lRet := J96WOLanc(aBody[1]["codPreFat"], aBody[1]["codSeqParc"], '', .F., aBody[1]["codContr"], .T., lWoValido, @cMsgErro, @cImpedeWO) // Efetua as validações e alterações WO na parcela de Fixo

		oResponse := {}
		Aadd(oResponse, JsonObject():New())
		If lRet
			oResponse[1]["lValWO"]   := "true"
		Else
			oResponse[1]["lValWO"]    := "false"
			oResponse[1]["lImpedeWO"] := cImpedeWO
			oResponse[1]["cMsgErro"]  := JConvUTF8(cMsgErro)
		EndIf

		Self:SetResponse( FWJsonSerialize(oResponse, .F., .F., .T.) )
		aSize(oResponse, 0)
		oResponse := Nil

		Return .T.
	Endif

	If lRet
		aAdd(aObsWO, aBody[1]["cMsgWo"])
		aAdd(aObsWO, aBody[1]["cCodMotv"])
		ncountWO  := J96WOFixo(Nil, aObsWO, aInfoApi, @aNovaNT1, .T., lWoValido) // Função responsável por efetuar WO na parcela de Fixo
		oResponse['parcela']:= {}
		Aadd(oResponse['parcela'], JsonObject():New())

		If ncountWO > 0
			oResponse['parcela'][1]['lWo'] := "true"
				oResponse['parcela'][1]['novaParcela']:= {}
			If Len(aNovaNT1) > 0
				aAdd(oresponse['parcela'][1]['novaParcela'], JsonObject():New())
				oResponse['parcela'][1]['novaParcela'][1]['codContrato']     := JConvUTF8(aNovaNT1[1][1])
				oResponse['parcela'][1]['novaParcela'][1]['codSeqParcela']   := JConvUTF8(aNovaNT1[1][2])
				oResponse['parcela'][1]['novaParcela'][1]['codParcela']      := JConvUTF8(aNovaNT1[1][3])
				oResponse['parcela'][1]['novaParcela'][1]['dataRefIncial']   := JConvUTF8(DToS(aNovaNT1[1][4]))
				oResponse['parcela'][1]['novaParcela'][1]['dataRefFinal']    := JConvUTF8(DToS(aNovaNT1[1][5]))
				oResponse['parcela'][1]['novaParcela'][1]['dataAtual']       := JConvUTF8(DToS(aNovaNT1[1][6]))
				oResponse['parcela'][1]['novaParcela'][1]['dataVencimento']  := JConvUTF8(DToS(aNovaNT1[1][9]))
				oResponse['parcela'][1]['novaParcela'][1]['descricao']       := JConvUTF8(aNovaNT1[1][10])
				oResponse['parcela'][1]['novaParcela'][1]['situacao']        := JConvUTF8(aNovaNT1[1][11])
				oResponse['parcela'][1]['novaParcela'][1]['codTipoFatura']   := JConvUTF8(aNovaNT1[1][12])
				oResponse['parcela'][1]['novaParcela'][1]['descTipoFatura']  := AllTrim(JurGetDados("NR9", 1, xFilial("NR9") + JConvUTF8(aNovaNT1[1][12]), "NRA_DESC") )
				oResponse['parcela'][1]['novaParcela'][1]['codMoeda']        := JConvUTF8(aNovaNT1[1][13])
				oResponse['parcela'][1]['novaParcela'][1]['descMoeda']       := AllTrim(JurGetDados("CTO", 1, xFilial("CTO") + JConvUTF8(aNovaNT1[1][13]), "CTO_SIMB") )
				oResponse['parcela'][1]['novaParcela'][1]['valorBase']       := JConvUTF8(cValTochar(aNovaNT1[1][7]))
				oResponse['parcela'][1]['novaParcela'][1]['valorAtualizado'] := JConvUTF8(cValTochar(aNovaNT1[1][8]))
			EndIf
		EndIf
		Self:SetResponse( FWJsonSerialize(oResponse, .F., .F., .T.) )
		oResponse:FromJSon("{}")
		oResponse := Nil
	EndIf

Return .T.

//-----------------------------------------------------------------------
/*/{Protheus.doc} POST CalFx
API para simular e retonar o valor da parcela de fixo considerando
a faixa de valor por quantidade de casos ou processos.

@example POST -> http://127.0.0.1:9090/rest/WSPfsAppContrato/calculafaixa
@example Body
	{
		"NT0_COD": "", // enviar o valor somente se não for inclusão
		"NT0_NOME": "SIMULACAO",
		"NT0_CCLIEN": "000001",
		"NT0_CLOJA": "00",
		"NT0_CTPHON": "018",
		"NT0_CASPRO": "1",
		"NT0_TPFX": "1",
		"NT0_FXENCM": "1",
		"NT0_FXABM": "1",
		"NUT": [
					{
					"NUT_CCLIEN": "000001",
					"NUT_CLOJA": "00",
					"NUT_CCASO": "000122"
					},
					{
					"NUT_CCLIEN": "000001",
					"NUT_CLOJA": "00",
					"NUT_CCASO": "000123"
					}
				],
		"NTR": [
					{
					"NTR_VLINI": 0,
					"NTR_VLFIM": 1,
					"NTR_TPVL": "1",
					"NTR_VALOR": 1000
					},
					{
					"NTR_VLINI": 2,
					"NTR_VLFIM": 999999999999,
					"NTR_TPVL": "1",
					"NTR_VALOR": 1500
					}
				],
		"NT1": {
				"NT1_DATAIN": "20240101"
				"NT1_DATAFI": "20240131"
				"NT1_CMOEDA": "01",
				"NT1_DATAAT": "20240620"
				"NT1_DATAVE": "20240531"
				"NT1_DESCRI": "Primeira Parcela",
				"NT1_QTDADE": 5 // Considera o valor digitado apenas quando o parâmetro MV_JQTDAUT for igual a "2"
				}
	}

@return Response Body
	{
		"quantity": 3,
		"fixQuotaValue": 10,
		"quotaDescription": "",
		"alertMessage": ""
	}

@author Jonatas Martins
@since  20/06/2024
@obs    Função utulizada para os tipo de honorários de fixo com faixa
        de valor, tipos de honorários: 018 - 032 - 035 - 036
/*/
//-----------------------------------------------------------------------
WSMethod POST CalFx QUERYPARAM WSREST WSPfsAppContrato
Local oResponse  := JSonObject():New()
Local oJSonBody  := JsonObject():New()
Local cBody      := StrTran(Self:GetContent(), CHR(10), "")
Local cMsg       := ""
Local oModel096  := Nil // Modelo completo de contratos
Local oModelNT0  := Nil // Cabeçalho contrato
Local oModelNUT  := Nil // Casos vinculados ao contrato
Local oModelNTR  := Nil // Faixas de valores do contrato
Local oModelNT1  := Nil // Parcelas de fixo do contrato
Local nLine      := 0
Local nLenNUT    := 0
Local nLenNTR    := 0
Local nValParc   := 0

	oJSonBody:fromJson(cBody)

	oModel096 := FWLoadModel("JURA096")
	oModel096:SetOperation(MODEL_OPERATION_INSERT)
	oModel096:Activate()

	oModelNT0 := oModel096:GetModel("NT0MASTER")
	oModelNUT := oModel096:GetModel("NUTDETAIL")
	oModelNTR := oModel096:GetModel("NTRDETAIL")
	oModelNT1 := oModel096:GetModel("NT1DETAIL")

	// Cabeçalho do contrato e da aba de Faixa de Valores e Parcela de Fixo
	If !Empty(oJsonBody:getJsonObject("NT0_COD"))
		oModelNT0:LoadValue("NT0_COD", oJsonBody:getJsonObject("NT0_COD"))
	EndIf
	oModelNT0:SetValue("NT0_NOME", oJsonBody:getJsonObject("NT0_NOME"))
	oModelNT0:SetValue("NT0_CCLIEN", oJsonBody:getJsonObject("NT0_CCLIEN"))
	oModelNT0:SetValue("NT0_CLOJA", oJsonBody:getJsonObject("NT0_CLOJA"))
	oModelNT0:SetValue("NT0_CTPHON", oJsonBody:getJsonObject("NT0_CTPHON"))
	// Campos da aba da faixa de valores
	oModelNT0:SetValue("NT0_CASPRO", oJsonBody:getJsonObject("NT0_CASPRO")) // Qtdade por: 1-Casos; 2-Processos
	oModelNT0:SetValue("NT0_TPFX", oJsonBody:getJsonObject("NT0_TPFX")) // Tipo de Faixa: 1-Tabela Estática; 2-Tabela Progressiva
	oModelNT0:SetValue("NT0_FXENCM", oJsonBody:getJsonObject("NT0_FXENCM")) // Enc período? 1-Sim; 2-Não
	oModelNT0:SetValue("NT0_FXABM", oJsonBody:getJsonObject("NT0_FXABM")) // Aber períod? 1-Sim; 2-Não

	// Casos vinculados ao contrato
	nLenNUT := Len(oJsonBody:getJsonObject("NUT"))
	For nLine := 1 To nLenNUT
		IIF(nLine > 1, oModelNUT:AddLine(), Nil)
		oModelNUT:SetValue("NUT_CCLIEN", oJsonBody:getJsonObject("NUT")[nLine]["NUT_CCLIEN"])
		oModelNUT:SetValue("NUT_CLOJA" , oJsonBody:getJsonObject("NUT")[nLine]["NUT_CLOJA"])
		oModelNUT:SetValue("NUT_CCASO" , oJsonBody:getJsonObject("NUT")[nLine]["NUT_CCASO"])
	Next nLine

	// Faixas de valores do contrato
	nLenNTR := Len(oJsonBody:getJsonObject("NTR"))
	For nLine := 1 To nLenNTR
		IIF(nLine > 1, oModelNTR:AddLine(), Nil)
		oModelNTR:SetValue("NTR_VLINI", oJsonBody:getJsonObject("NTR")[nLine]["NTR_VLINI"])
		oModelNTR:SetValue("NTR_VLFIM", oJsonBody:getJsonObject("NTR")[nLine]["NTR_VLFIM"])
		oModelNTR:SetValue("NTR_TPVL" , oJsonBody:getJsonObject("NTR")[nLine]["NTR_TPVL"])
		oModelNTR:SetValue("NTR_VALOR", oJsonBody:getJsonObject("NTR")[nLine]["NTR_VALOR"])
	Next nLine

	// Parcela de Fixo pendente do contrato
	oModelNT1:SetValue("NT1_DATAIN", SToD(oJsonBody:getJsonObject("NT1")["NT1_DATAIN"]))
	oModelNT1:SetValue("NT1_DATAFI", SToD(oJsonBody:getJsonObject("NT1")["NT1_DATAFI"]))
	oModelNT1:SetValue("NT1_CMOEDA", oJsonBody:getJsonObject("NT1")["NT1_CMOEDA"])
	oModelNT1:SetValue("NT1_DATAAT", SToD(oJsonBody:getJsonObject("NT1")["NT1_DATAAT"]))
	oModelNT1:SetValue("NT1_DATAVE", SToD(oJsonBody:getJsonObject("NT1")["NT1_DATAVE"]))
	oModelNT1:SetValue("NT1_DESCRI", Decode64(oJsonBody:getJsonObject("NT1")["NT1_DESCRI"]))
	oModelNT1:SetValue("NT1_QTDADE", oJsonBody:getJsonObject("NT1")["NT1_QTDADE"]) // Considera o valor digitado apenas quando o parâmetro MV_JQTDAUT for igual a "2"

	nValParc := J96CalcCDF(oModel096,, .T., @cMsg)

	// Response
	oResponse["quantity"] := oModelNT1:GetValue('NT1_QTDADE')
	oResponse["fixQuotaValue"] := nValParc
	oResponse["quotaDescription"] := Encode64(oModelNT1:GetValue('NT1_DESCRI'))
	oResponse["alertMessage"] := JConvUTF8(cMsg)

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
	oResponse := Nil

	oModel096:DeActivate()
	oModel096:Destroy()

Return .T.

//-----------------------------------------------------------------------
/*/{Protheus.doc} POST CorrigeVlr
API para simular e retonar o valor do contrato ou parcela com base
no índice de correção monetária.

@param lCancSmartUI, Se cancela pré-fatura vinculada ao contrato
@param lParcPos    , Se está corrigindo o valor apenas da parcela posicionada

@example POST -> http://127.0.0.1:9090/rest/WSPfsAppContrato/correcaomonetaria
@example Body
	{
		"NT0_COD": "000112",
		"NT0_CTPHON": "003",
		"NT0_TPCORR": "2",
		"NT0_VLRBAS": 1000,
		"NT0_CASPRO": "1",
		"NT0_CMOEF": "01",
		"NT0_DTBASE": "20240101",
		"NT0_PERCOR": 1,
		"NT0_CINDIC": "05",
		"NT0_FIXEXC": "1",
		"NT0_PEREX": 0,
		"NT0_PERFIX": 1,
		"NT0_PERCD": 0,
    "NT1": [
        {
            "NT1_PARC": "0002",
            "NT1_DATAIN": "20240201",
            "NT1_DATAFI": "20240229",
            "NT1_DESCRI": "Descrição padrão",
            "NT1_SITUAC": "1",
            "NT1_CMOEDA": "01",
            "NT1_DATAVE": "20240731",
            "NT1_CPREFT": "00000726",
            "NT1_VALORB": 2000
        },
        {
            "NT1_PARC": "0001",
            "NT1_DATAIN": "20240101",
            "NT1_DATAFI": "20240131",
            "NT1_DESCRI": "Parcela 0001 - Contrato 000112",
            "NT1_SITUAC": "1",
            "NT1_CMOEDA": "01",
            "NT1_DATAVE": "20240630",
            "NT1_CPREFT": "00000725",
            "NT1_VALORB": 1000
        },
        {
            "NT1_PARC": "0003",
            "NT1_DATAIN": "20240301",
            "NT1_DATAFI": "20240331",
            "NT1_DESCRI": "Parcela 3",
            "NT1_SITUAC": "1",
            "NT1_CMOEDA": "01",
            "NT1_DATAVE": "20240731",
            "NT1_CPREFT": "00000728",
            "NT1_VALORB": 3000
        }
    ]
}

@return Response Body
{
	"vlrBaseAtualNT0": 1001.84135008,
	"alertMessage": "A parcela '0003' está vinculada a pré-fatura '00000728' com a situação 'Minuta Emitida' e não poderá ser alterada!"
	"mostraTelaMsg": .T.
	"parcelas": [
		[
			"numeroParcela": "0003",
			"valorAtualizadoNT1": 3000,
			"legenda": "1",
			"status":"3",
			"codPreFatura": "00000728",
			"msgAgrupada": "Parcelas que estão vinculadas a pré-faturas com situação 'Minuta Emitida' não poderá ser alterada.",
			"msgParcela": "A parcela '0003' está vinculada a pré-fatura '00000728' com a situação 'Minuta Emitida' e não poderá ser alterada!"
		],
		[
			"numeroParcela": "0002",
			"valorAtualizadoNT1": 1001.84135008
		],
		[
			"numeroParcela": "0001",
			"valorAtualizadoNT1": 1001.74117597,
		]
	]
	"dataAtual": "20240719"
}

@author Abner Fogaça
@since  05/07/2024
/*/
//-----------------------------------------------------------------------
WSMethod POST CorrigeVlr QUERYPARAM lCancSmartUI, lParcPos WSREST WSPfsAppContrato
Local oResponse    := JSonObject():New()
Local oJSonBody    := JsonObject():New()
Local cBody        := StrTran(Self:GetContent(), CHR(10), "")
Local lCancSmartUI := Self:lCancSmartUI
Local lParcPos     := Self:lParcPos
Local lRet         := .T.
Local lExibeTela   := .F.
Local lParcAuto    := .F. //Indica se a geração das parcelas é automática ou manual
Local cTpHon       := ""
Local cMsgPrefat   := ""
Local cMsg         := ""
Local cMoedaNac    := SuperGetMv('MV_JMOENAC',, '01')
Local oModel096    := Nil // Modelo completo de contratos
Local oModelNT0    := Nil // Cabeçalho contrato
Local oModelNT1    := Nil // Parcelas de fixo do contrato
Local nLine        := 0
Local nLenNT1      := 0
Local nParcela     := 0
Local nPosParc     := 0
Local aRespNT1     := {}
Local aMsgParc     := {}

	oJSonBody:fromJson(cBody)
	cTpHon    := oJsonBody:getJsonObject("NT0_CTPHON")
	lParcAuto := J96TPHPAut(cTpHon)
	oModel096 := FWLoadModel("JURA096")
	oModel096:SetOperation(MODEL_OPERATION_INSERT)
	oModel096:Activate()

	oModelNT0 := oModel096:GetModel("NT0MASTER")
	oModelNT1 := oModel096:GetModel("NT1DETAIL")

	// Cabeçalho do contrato e da aba de Faixa de Valores e Parcela de Fixo
	If !Empty(oJsonBody:getJsonObject("NT0_COD"))
		oModelNT0:LoadValue("NT0_COD", oJsonBody:getJsonObject("NT0_COD"))
	EndIf
	oModelNT0:SetValue("NT0_CTPHON", cTpHon)
	oModelNT0:SetValue("NT0_TPCORR", oJsonBody:getJsonObject("NT0_TPCORR"))
	oModelNT0:SetValue("NT0_VLRBAS", oJsonBody:getJsonObject("NT0_VLRBAS"))
	oModelNT0:SetValue("NT0_CMOEF", oJsonBody:getJsonObject("NT0_CMOEF"))
	oModelNT0:SetValue("NT0_DTBASE", SToD(oJsonBody:getJsonObject("NT0_DTBASE")))
	oModelNT0:SetValue("NT0_PERCOR", oJsonBody:getJsonObject("NT0_PERCOR"))
	oModelNT0:SetValue("NT0_CINDIC", oJsonBody:getJsonObject("NT0_CINDIC"))
	oModelNT0:SetValue("NT0_FIXEXC", oJsonBody:getJsonObject("NT0_FIXEXC"))
	If !Empty(oJsonBody:getJsonObject("NT0_PEREX"))
		oModelNT0:SetValue("NT0_PEREX", oJsonBody:getJsonObject("NT0_PEREX"))
	EndIf
	oModelNT0:SetValue("NT0_PERFIX", oJsonBody:getJsonObject("NT0_PERFIX"))
	If !Empty(oJsonBody:getJsonObject("NT0_PERCD"))
		oModelNT0:SetValue("NT0_PERCD", oJsonBody:getJsonObject("NT0_PERCD"))
	EndIf

	// Parcelas de fixo (NT1)
	nLenNT1 := Len(oJsonBody:getJsonObject("NT1"))
	For nLine := 1 To nLenNT1
		IIF(nLine > 1, oModelNT1:AddLine(), Nil)
		oModelNT1:SetValue("NT1_PARC", oJsonBody:getJsonObject("NT1")[nLine]["NT1_PARC"])
		oModelNT1:SetValue("NT1_DATAIN", SToD(oJsonBody:getJsonObject("NT1")[nLine]["NT1_DATAIN"]))
		oModelNT1:SetValue("NT1_DATAFI", SToD(oJsonBody:getJsonObject("NT1")[nLine]["NT1_DATAFI"]))
		oModelNT1:SetValue("NT1_DESCRI", DecodeUtf8(oJsonBody:getJsonObject("NT1")[nLine]["NT1_DESCRI"]))
		oModelNT1:SetValue("NT1_SITUAC", oJsonBody:getJsonObject("NT1")[nLine]["NT1_SITUAC"])
		oModelNT1:SetValue("NT1_CMOEDA", oJsonBody:getJsonObject("NT1")[nLine]["NT1_CMOEDA"])
		oModelNT1:SetValue("NT1_DATAVE", SToD(oJsonBody:getJsonObject("NT1")[nLine]["NT1_DATAVE"]))
		oModelNT1:SetValue("NT1_VALORB", oJsonBody:getJsonObject("NT1")[nLine]["NT1_VALORB"])
		oModelNT1:SetValue("NT1_CPREFT", oJsonBody:getJsonObject("NT1")[nLine]["NT1_CPREFT"])
	Next nLine

	If lParcAuto .And. !lParcPos
		For nParcela := 1 To oModelNT1:GetQtdLine()
			lRet := J96VerPreFat(oModel096, nParcela, lCancSmartUI, .T., @cMsgPrefat, @cMsg, @aMsgParc)
			If !Empty(cMsgPrefat) .And. !lCancSmartUI
				oResponse["prefatMessage"] := cMsgPrefat
				oResponse["alertMessage"]  := cMsg

				Self:SetResponse(FWHttpEncode(FWJsonSerialize(oResponse, .F., .F., .T.)))
				oResponse := Nil
				Return .T.
			EndIf
			If FindFunction("J96Corrige") .And. lRet
				J96Corrige(oModelNT0, oModelNT1, nParcela, .T., lParcAuto, @cMsg, cMoedaNac)
			EndIf
		Next nParcela
	Else
		lRet := J96VerPreFat(oModel096, oModelNT1:GetLine(), lCancSmartUI, .T., @cMsgPrefat, @cMsg, @aMsgParc)
		If !Empty(cMsgPrefat) .And. !lCancSmartUI
			oResponse["prefatMessage"] := cMsgPrefat
			oResponse["alertMessage"]  := cMsg

			Self:SetResponse(FWHttpEncode(FWJsonSerialize(oResponse, .F., .F., .T.)))
			oResponse := Nil
			Return .T.
		EndIf

		If FindFunction("J96Corrige") .And. lRet
			J96Corrige(oModelNT0, oModelNT1, oModelNT1:GetLine(), .T., lParcAuto, @cMsg, cMoedaNac)
		EndIf
	EndIf

	oResponse["vlrBaseAtualNT0"] := oModelNT0:GetValue('NT0_VALORA')
	oResponse["alertMessage"]    := cMsg
	If Len(aMsgParc) > 0
		lExibeTela := .T.
		oResponse["mostraTelaMsg"] := .T.
	EndIf

	For nParcela := 1 To oModelNT1:GetQtdLine()
		If !Empty(oModelNT1:GetValue('NT1_CPREFT', nParcela)) // Só retorna para o FrondEnd as parcelas fixas que tem vínculo com pré-faturas.
			aAdd(aRespNT1, JsonObject():New())
			nLenNT1 := Len(aRespNT1)
			aRespNT1[nLenNT1]['numeroParcela'] := oModelNT1:GetValue('NT1_PARC', nParcela)
			aRespNT1[nLenNT1]['valorAtualizadoNT1'] := oModelNT1:GetValue('NT1_VALORA', nParcela)
			If lExibeTela
				nPosParc := aScan(aMsgParc, {|parcela| parcela["numeroParcela"] == oModelNT1:GetValue('NT1_PARC', nParcela)})
				If nPosParc > 0
					aRespNT1[nLenNT1]['legenda']      := aMsgParc[nPosParc]["legenda"]
					aRespNT1[nLenNT1]['status']       := aMsgParc[nPosParc]["status"]
					aRespNT1[nLenNT1]['codPreFatura'] := aMsgParc[nPosParc]["codPreFatura"]
					aRespNT1[nLenNT1]['situacao']     := aMsgParc[nPosParc]["situacao"]
					aRespNT1[nLenNT1]['msgParcela']   := aMsgParc[nPosParc]["msgParcela"]
				EndIf
			EndIf
		EndIf
	Next nParcela
	oResponse['parcelas']  := aRespNT1
	oResponse['dataAtual'] := DtoS(Date())

	Self:SetResponse(FWHttpEncode(FWJsonSerialize(oResponse, .F., .F., .T.)))

	oResponse := Nil

	oModel096:DeActivate()
	oModel096:Destroy()

Return .T.

//-----------------------------------------------------------------------
/*/{Protheus.doc} POST CorrigeVlr
API para simular e retonar o valor do contrato ou parcela com base
no índice de correção monetária.

@param lCancSmartUI, Se cancela pré-fatura vinculada ao contrato
@param lParcPos    , Se está corrigindo o valor apenas da parcela posicionada

@example POST -> http://127.0.0.1:9090/rest/WSPfsAppContrato/DeletNT1
@example Body
{
    "NT0_CTPHON": "001",
    "NT0_CMOEF": "01",
    "NT0_VLRBAS": 1000,
    "NT1": [
        {
            "NT1_PARC": "0012",
            "NT1_DESCRI": "Descrição padrão",
            "NT1_SEQUEN": "00000033",
            "NT1_VALORB": 100,
            "NT1_QTDADE": 0,
            "NT1_CPREFT": "00000075",
            "NT1_SITUAC": "1",
            "NT1_CMOEDA": "01"
        }
    ]
}

@return Response Body
{
    "canDelete": false,
    "message": "A parcela '0012' está vinculada a pré-fatura '00000075' com a situação 'Em Revisão' e não poderá ser alterada!"
}

@author Abner Fogaça
@since  05/07/2024
/*/
//-----------------------------------------------------------------------
WSMethod POST DeletNT1 WSREST WSPfsAppContrato
Local oResponse    := JSonObject():New()
Local oJSonBody    := JsonObject():New()
Local cBody        := StrTran(Self:GetContent(), CHR(10), "")
Local lRet         := .T.
Local cMsg         := ""
Local oModel096    := Nil // Modelo completo de contratos
Local oModelNT0    := Nil // Cabeçalho contrato
Local oModelNT1    := Nil // Parcelas de fixo do contrato

	// Criação do objeto JSON a partir do body da requisição
	oJSonBody:fromJson(cBody)

	// Montagem do modelo "fake"
	oModel096 := FWLoadModel("JURA096")
	oModel096:SetOperation(MODEL_OPERATION_INSERT)
	oModel096:Activate()

	oModelNT0 := oModel096:GetModel("NT0MASTER")
	oModelNT1 := oModel096:GetModel("NT1DETAIL")

	// Cabeçalho do contrato e da aba de Faixa de Valores e Parcela de Fixo
	oModelNT0:SetValue("NT0_CTPHON", oJsonBody:getJsonObject("NT0_CTPHON"))
	oModelNT0:SetValue("NT0_VLRBAS", oJsonBody:getJsonObject("NT0_VLRBAS"))
	oModelNT0:SetValue("NT0_CMOEF", oJsonBody:getJsonObject("NT0_CMOEF"))

	// Parcelas de fixo (NT1)
	oModelNT1:SetValue("NT1_PARC"  , oJsonBody:getJsonObject("NT1")[1]["NT1_PARC"])
	oModelNT1:SetValue("NT1_DESCRI", DecodeUtf8(oJsonBody:getJsonObject("NT1")[1]["NT1_DESCRI"]))
	oModelNT1:SetValue("NT1_SEQUEN", oJsonBody:getJsonObject("NT1")[1]["NT1_SEQUEN"])
	oModelNT1:SetValue("NT1_VALORB", oJsonBody:getJsonObject("NT1")[1]["NT1_VALORB"])
	oModelNT1:SetValue("NT1_QTDADE", oJsonBody:getJsonObject("NT1")[1]["NT1_QTDADE"])
	oModelNT1:SetValue("NT1_CPREFT", oJsonBody:getJsonObject("NT1")[1]["NT1_CPREFT"])
	oModelNT1:SetValue("NT1_SITUAC", oJsonBody:getJsonObject("NT1")[1]["NT1_SITUAC"])
	oModelNT1:SetValue("NT1_CMOEDA", oJsonBody:getJsonObject("NT1")[1]["NT1_CMOEDA"])

	// Valida a exclusão
	lRet := JA096VE(Nil, 1, "DELETE", /*cCampo*/, /*xComp*/, /*xValue*/, @cMsg, .T.)

	// Monta o response
	oResponse["canDelete"] := lRet
	oResponse["message"]   := cMsg

	Self:SetResponse(FWHttpEncode(FWJsonSerialize(oResponse, .F., .F., .T.)))

	// Limpa as variaveis
	oResponse := Nil

	oModel096:DeActivate()
	oModel096:Destroy()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} faturamentoParc
Consulta a situacação atual de faturamento das parcelas com base na
tabela NWE (Faturamento Fixo).

@example GET -> http://127.0.0.1:9090/rest/WSPfsAppContrato/faturamentoParc/{chaveContrato}

@param chaveContrato - Chave do Contrato (Filial + Codigo Contrato)

@return Response Body
[
    {
        "codSeqParcela": "00000302",
        "numeroParcela": "0007",
        "statusAtual": [
            {
                "situacaoAtual": "Não há dados de faturamento para esta parcela."
            }
        ],
        "statusHistorico": []
    }
    {
        "codSeqParcela": "00000300",
        "numeroParcela": "0006",
        "statusAtual": [
            {
                "situacaoAtual": "Vinculada na pré-fatura 00000736 emitida em 07/08/2024 pelo usuário JAX-JACQUES e na situação 'Análise.'"
            }
        ],
        "statusHistorico": []
    },
    {
        "codSeqParcela": "00000177",
        "numeroParcela": "0005",
        "situacaoAtual": [
            {
               "situacaoAtual": "Vinculada no WO 00000077 gerado pelo usuário MJQ-MARIA JOANA QUEIROZ, com percentual de 60%."
            },
            {
               "situacaoAtual": "Vinculada na fatura SP/000000881 emitida em 31/07/2024 pelo usuário BNA-BERNARDO NEVES ALCANTARA, com percentual de 40%."
            }
        ],
        "statusHistorico": [
            {
                "historico": "Vinculada na fatura SP/000000880 emitida em 31/07/2024 pelo usuário CDF-CRISTIANO DIAS, com percentual de 60%."
            },
            {
                "historico": "Vinculada na pré-fatura 00000735 emitida em 07/08/2024 pelo usuário BNA-BERNARDO NEVES ALCANTARA e na situação 'Fatura Emitida.'"
            },
            {
                "historico": "Vinculada na pré-fatura 00000734 emitida em 07/08/2024 pelo usuário SLM-SAMUEL LIMA DE MORAES e na situação 'Substituída/Cancelada.'"
            },
            {
                "historico": "Vinculada na pré-fatura 00000733 emitida em 07/08/2024 pelo usuário TST-TIAGO SOUZA TAVARES e na situação 'Substituída/Cancelada.'"
            },
            {
                "historico": "Vinculada na pré-fatura 00000732 emitida em 07/08/2024 pelo usuário SLM-SAMUEL LIMA DE MORAES e na situação 'Substituída/Cancelada.'"
            },
            {
                "historico": "Vinculada na fatura SP/000000879 emitida direto pela fila em 23/07/2024 pelo usuário BNA-BERNARDO NEVES ALCANTARA."
            },
            {
                "historico": "Vinculada na fatura SP/000000878 emitida direto pela fila em 23/07/2024 pelo usuário CDF-CRISTIANO DIAS."
            },
            {
                "historico": "Vinculada na pré-fatura 00000731 emitida em 23/07/2024 pelo usuário MON-MONICA e na situação 'Substituída/Cancelada.'"
            },
            {
                "historico": "Vinculada na pré-fatura 00000730 emitida em 23/07/2024 pelo usuário CDF-CRISTIANO DIAS e na situação 'Substituída/Cancelada.'"
            }
        ]
    }
]

@author Abner Fogaça de Oliveira
@since  07/08/2024
/*/
//-------------------------------------------------------------------
WSMethod GET faturamentoParc PATHPARAM chaveContrato WSREST WSPfsAppContrato
Local oResponse  := JSonObject():New()
Local cChaveCtr  := Decode64(Self:chaveContrato)
Local nTamFilial := TamSX3("NT0_FILIAL")[1]
Local nTamCodCtr := TamSX3("NT0_COD")[1]
Local cFilCtr    := Substr(cChaveCtr, 1, nTamFilial)
Local cCodCtr    := Substr(cChaveCtr, nTamFilial + 1, nTamCodCtr)

	oResponse := {}
	Aadd(oResponse, JsonObject():New())

	oResponse := JGetFatParc(cFilCtr, cCodCtr)

	Self:SetResponse(FWHttpEncode(FWJsonSerialize(oResponse, .F., .F., .T.)))
	oResponse := Nil

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JGetFatParc
Monta o body com base no faturamento das parcelas de fixo.

@param cFilCtr  - Filial do Contrato
@param cCodCtr  - Codigo do Contrato

@author Abner Fogaça de Oliveira
@since  07/08/2024
/*/
//-------------------------------------------------------------------
Static Function JGetFatParc(cFilCtr, cCodCtr)
Local oNT1Parc    := Nil
Local oNWEParc    := Nil
Local cAliasNT1   := GetNextAlias()
Local cAliasNWE   := ""
Local cQuery      := ""
Local cMsgSitAtu  := ""
Local cMsgHist    := ""
Local cCodSeqNT1  := ""
Local cUsuario    := ""
Local cCodFatura  := ""
Local nIndJson    := 0
Local nIndNWE     := 0
Local nIndMsg     := 0
Local nParam      := 0
Local lMultiPayer := .F.
Local aMsgAtual   := {}
Local aMsgHist    := {}
Local aHistorFat  := {}

	cFilCtr := Padr(cFilCtr, TamSx3("NT1_FILIAL")[1])
	cCodCtr := Padr(cCodCtr, TamSx3("NT0_COD")[1])

	cQuery := " SELECT "
	cQuery +=        " NT1.NT1_SEQUEN,"
	cQuery +=        " NT1.NT1_PARC"
	cQuery +=   " FROM "+ RetSqlName("NT1") + " NT1"
	cQuery +=  " WHERE NT1.NT1_FILIAL = ?" // cFilCtr
	cQuery +=    " AND NT1.NT1_CCONTR = ?" // cCodCtr
	cQuery +=    " AND NT1.D_E_L_E_T_ = ' '"
	cQuery +=  " ORDER BY NT1.NT1_SEQUEN DESC"

	oNT1Parc := FWPreparedStatement():New(cQuery)

	oNT1Parc:SetString(++nParam, cFilCtr) // Filial do Contrato
	oNT1Parc:SetString(++nParam, cCodCtr) // Código do Contrato

	cQuery := oNT1Parc:GetFixQuery()

	MpSysOpenQuery(cQuery, cAliasNT1)

	While ((cAliasNT1)->(!Eof()))
		aAdd(aHistorFat, JSonObject():New())
		nIndJson  := Len(aHistorFat)
		cAliasNWE  := GetNextAlias()
		cCodSeqNT1 := (cAliasNT1)->(NT1_SEQUEN)
		cCodParNT1 := (cAliasNT1)->(NT1_PARC)
		aMsgAtual  := {}
		aMsgHist   := {}
		
		cQuery := " SELECT "
		cQuery +=        " NWE.R_E_C_N_O_ NWERECNO,"
		cQuery +=        " NWE.NWE_CFIXO,"
		cQuery +=        " NWE.NWE_SITUAC,"
		cQuery +=        " NX0.NX0_DTEMI,"
		cQuery +=        " NWE.NWE_PRECNF,"
		cQuery +=        " NX0.NX0_SITUAC,"
		cQuery +=        " NXA.NXA_DTEMI,"
		cQuery +=        " NWE.NWE_CESCR,"
		cQuery +=        " NWE.NWE_CFATUR,"
		cQuery +=        " NXA.NXA_CFILA,"
		cQuery +=        " NXA.NXA_PERFAT,"
		cQuery +=        " NXA.NXA_CPREFT,"
		cQuery +=        " NWE.NWE_CWO,"
		cQuery +=        " NWE.NWE_CANC,"
		cQuery +=        " NWE.NWE_CODUSR,"
		cQuery +=        " RD0.RD0_SIGLA,"
		cQuery +=        " RD0.RD0_NOME"
		cQuery +=   " FROM "+ RetSqlName("NWE") + " NWE"
		cQuery +=   " LEFT JOIN " + RetSqlName("RD0") + " RD0"
		cQuery +=     " ON RD0.RD0_FILIAL = NWE.NWE_FILIAL"
		cQuery +=    " AND RD0.RD0_USER = NWE.NWE_CODUSR"
		cQuery +=    " AND RD0.D_E_L_E_T_ = ' '"
		cQuery +=   " LEFT JOIN " + RetSqlName("NX0") + " NX0"
		cQuery +=     " ON NX0.NX0_FILIAL = NWE.NWE_FILIAL"
		cQuery +=    " AND NX0.NX0_COD = NWE.NWE_PRECNF"
		cQuery +=    " AND NX0.D_E_L_E_T_ = ' '"
		cQuery +=   " LEFT JOIN " + RetSqlName("NXA") + " NXA"
		cQuery +=     " ON NXA.NXA_FILIAL = NWE.NWE_FILIAL"
		cQuery +=    " AND NXA.NXA_CESCR = NWE.NWE_CESCR"
		cQuery +=    " AND NXA.NXA_COD = NWE.NWE_CFATUR"
		cQuery +=    " AND NXA.D_E_L_E_T_ = ' '"
		cQuery +=  " WHERE NWE.NWE_FILIAL = ?" // cFilCtr
		cQuery +=    " AND NWE.NWE_CFIXO = ?"  // cCodSeqNT1
		cQuery +=    " AND NWE.D_E_L_E_T_ = ' '"
		cQuery +=  " ORDER BY NWE.NWE_CANC DESC, NWE.R_E_C_N_O_ DESC"

		oNWEParc := FWPreparedStatement():New(cQuery)

		oNWEParc:SetString(1, cFilCtr)    // Filial do Contrato
		oNWEParc:SetString(2, cCodSeqNT1) // Sequencia da parcela

		cQuery := oNWEParc:GetFixQuery()

		MpSysOpenQuery(cQuery, cAliasNWE)

		If (cAliasNWE)->(Eof())
			aHistorFat[nIndJson]['codSeqParcela'] := cCodSeqNT1
			aHistorFat[nIndJson]['numeroParcela'] := cCodParNT1
			cMsgSitAtu := STR0041 // "Não há dados de faturamento para esta parcela."
			Aadd(aMsgAtual, JSonObject():New())
			nIndMsg := Len(aMsgAtual)
			aMsgAtual[nIndMsg]['situacaoAtual'] := cMsgSitAtu
		EndIf
		
		nIndNWE := 0
		
		While (cAliasNWE)->(!Eof())
			aHistorFat[nIndJson]['codSeqParcela'] := cCodSeqNT1
			aHistorFat[nIndJson]['numeroParcela'] := cCodParNT1
			
			//------ Mensagem da situação atual (utilizado no grid).
			cCodFatura  := Alltrim((cAliasNWE)->NWE_CESCR) + "/" + Alltrim((cAliasNWE)->NWE_CFATUR)
			cUsuario    := Alltrim((cAliasNWE)->RD0_SIGLA) + "-" + Alltrim((cAliasNWE)->RD0_NOME)
			lMultiPayer := !Empty((cAliasNWE)->NWE_CFATUR) .And. (cAliasNWE)->NXA_PERFAT < 100
			If (cAliasNWE)->NWE_CANC = "2"
				If !Empty((cAliasNWE)->NWE_PRECNF)
					cMsgSitAtu := I18N(STR0035, {(cAliasNWE)->NWE_PRECNF, SToD((cAliasNWE)->NX0_DTEMI), cUsuario, Tabela("JS", (cAliasNWE)->NX0_SITUAC, .F.)}) // "Vinculada na pré-fatura #1 emitida em #2 pelo usuário #3 e na situação '#4.'"
				ElseIf !lMultiPayer .And. !Empty((cAliasNWE)->NWE_CFATUR) .And. !Empty((cAliasNWE)->NXA_CFILA) .And. Empty((cAliasNWE)->NWE_CWO) .And. Empty((cAliasNWE)->NXA_CPREFT)
					cMsgSitAtu := I18N(STR0036, {cCodFatura, StoD((cAliasNWE)->NXA_DTEMI), cUsuario, (cAliasNWE)->NXA_CPREFT}) // "Vinculada na fatura #1 emitida direto pela fila em #2 pelo usuário #3."
				ElseIf !lMultiPayer .And. !Empty((cAliasNWE)->NWE_CFATUR) .And. Empty((cAliasNWE)->NWE_CWO) .And. !Empty((cAliasNWE)->NXA_CPREFT)
					cMsgSitAtu := I18N(STR0037, {cCodFatura, SToD((cAliasNWE)->NXA_DTEMI), cUsuario, (cAliasNWE)->NXA_CPREFT}) // "Vinculada na fatura #1 emitida em #2 pelo usuário #3, com origem na pré-fatura #4."
				ElseIf lMultiPayer .And. Empty((cAliasNWE)->NWE_CWO)
					cMsgSitAtu := I18N(STR0038, {cCodFatura, SToD((cAliasNWE)->NXA_DTEMI), cUsuario, (cAliasNWE)->NXA_PERFAT}) // "Vinculada na fatura #1 emitida em #2 pelo usuário #3, com percentual de #4%."
				ElseIf !lMultiPayer .And. !Empty((cAliasNWE)->NWE_CWO)
					cMsgSitAtu := I18N(STR0039, {(cAliasNWE)->NWE_CWO, cUsuario}) // "Vinculada no WO #1 gerado pelo usuário #2."
				ElseIf lMultiPayer .And. !Empty((cAliasNWE)->NWE_CWO)
					cMsgSitAtu := I18N(STR0040, {(cAliasNWE)->NWE_CWO, cUsuario, (cAliasNWE)->NXA_PERFAT}) // "Vinculada no WO #1 gerado pelo usuário #2, com percentual de #3%."
				EndIf
			//------ Histórico da NWE (utilizado no Slide)
			Else
				If !Empty((cAliasNWE)->NWE_PRECNF)
					cMsgHist := I18N(STR0035, {(cAliasNWE)->NWE_PRECNF, SToD((cAliasNWE)->NX0_DTEMI), cUsuario, Tabela("JS", (cAliasNWE)->NX0_SITUAC, .F.)}) // "Vinculada na pré-fatura #1 emitida em #2 pelo usuário #3 e na situação '#4.'"
				ElseIf !lMultiPayer .And. !Empty((cAliasNWE)->NWE_CFATUR) .And. !Empty((cAliasNWE)->NXA_CFILA) .And. Empty((cAliasNWE)->NWE_CWO) .And. Empty((cAliasNWE)->NXA_CPREFT)
					cMsgHist := I18N(STR0036, {cCodFatura, StoD((cAliasNWE)->NXA_DTEMI), cUsuario, (cAliasNWE)->NXA_CPREFT}) // "Vinculada na fatura #1 emitida direto pela fila em #2 pelo usuário #3."
				ElseIf !lMultiPayer .And. !Empty((cAliasNWE)->NWE_CFATUR) .And. Empty((cAliasNWE)->NWE_CWO) .And. !Empty((cAliasNWE)->NXA_CPREFT)
					cMsgHist := I18N(STR0037, {cCodFatura, SToD((cAliasNWE)->NXA_DTEMI), cUsuario, (cAliasNWE)->NXA_CPREFT}) // "Vinculada na fatura #1 emitida em #2 pelo usuário #3, com origem na pré-fatura #4."
				ElseIf lMultiPayer .And. Empty((cAliasNWE)->NWE_CWO)
					cMsgHist := I18N(STR0038, {cCodFatura, SToD((cAliasNWE)->NXA_DTEMI), cUsuario, (cAliasNWE)->NXA_PERFAT}) // "Vinculada na fatura #1 emitida em #2 pelo usuário #3, com percentual de #4%."
				ElseIf !lMultiPayer .And. !Empty((cAliasNWE)->NWE_CWO)
					cMsgHist := I18N(STR0039, {(cAliasNWE)->NWE_CWO, cUsuario}) // "Vinculada no WO #1 gerado pelo usuário #2."
				ElseIf lMultiPayer .And. !Empty((cAliasNWE)->NWE_CWO)
					cMsgHist := I18N(STR0040, {(cAliasNWE)->NWE_CWO, cUsuario, (cAliasNWE)->NXA_PERFAT}) // "Vinculada no WO #1 gerado pelo usuário #2, com percentual de #3%."
				EndIf
			EndIf
			
			If !Empty(cMsgHist)
				Aadd(aMsgHist, JSonObject():New())
				nIndNWE := Len(aMsgHist)
				aMsgHist[nIndNWE]['historico'] := cMsgHist
			EndIf
			If !Empty(cMsgSitAtu)
				Aadd(aMsgAtual, JSonObject():New())
				nIndNWE := Len(aMsgAtual)
				aMsgAtual[nIndNWE]['situacaoAtual'] := cMsgSitAtu
			EndIf
			cMsgSitAtu := "" // Limpa a variável para não exibir mensagens duplicadas caso a parcela esteja vinculada a faturas multipagadores
			cMsgHist   := ""
			(cAliasNWE)->(dbSkip())
		EndDo
		
		If Len(aMsgAtual) == 0 // Quando nenhuma linha da NWE está com o campo NWE_CANC = 2
			Aadd(aMsgAtual, JSonObject():New())
			aMsgAtual[1]['situacaoAtual'] := STR0041 // "Não há dados de faturamento para esta parcela."
		Endif
		aHistorFat[nIndJson]['statusAtual']     := aMsgAtual
		aHistorFat[nIndJson]['statusHistorico'] := aMsgHist

		(cAliasNWE)->(DbCloseArea())
		(cAliasNT1)->(DbSkip())
	EndDo
	// Limpa o objeto FWPreparedStatement
	oNT1Parc:Destroy()
	If Valtype(oNWEParc) == 'O'
		oNWEParc:Destroy()
	EndIf
	(cAliasNT1)->(DbCloseArea())

Return aHistorFat
