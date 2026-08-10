#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "WSJURCONSULTIVO.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WSJurConsultivo
Métodos WS REST do Jurídico para consultivo.

@since 15/08/2025
/*/
//-------------------------------------------------------------------
WSRESTFUL JURCONSULTIVO DESCRIPTION STR0001 //"Métodos WS REST do Jurídico para consultivo"

	WSDATA correcao AS STRING

    WSMETHOD GET version      DESCRIPTION STR0002 PATH "version"    PRODUCES APPLICATION_JSON // 'Versão da API de consultivo'

    WSMETHOD POST SetFilter   DESCRIPTION STR0003 PATH "setfilter"  PRODUCES APPLICATION_JSON // 'Executa a pesquisa avançada de consultivo'
END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} version
Retorna a versão e permissões do webservice de consultivo - Usado para proteção de versão
@since 15/08/2025
@example [Sem Opcional] GET -> http://localhost:12173/rest/JURCONSULTIVO/version
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET version WSREST JURCONSULTIVO
Local oResponse := JsonObject():New()

	Self:SetContentType("application/json")
	
	oResponse['pesquisa-avancada'] := "true"
	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} POST SetFilter
Executa a pesquisa avançada de consultivo

@param correcao - Informa se sofrerá correção monetária ou não
@return lRet    - .T.

@since 15/08/2025

@example [Sem Opcional] POST -> http://localhost:12173/rest/JURCONSULTIVO/SetFilter
@param Body - {	"filters": [
							{"label":"Situacao: Em andamento",
							"value":"1",
							"field":"NSZ_SITUAC",
							"type":"COMBO",
							"condition":"000000131",
							"$id":"35a5527d-28ab-4f86-95ba-65182fc74772"}
							], 
				"count": 1, 
				"page": 1, 
				"pageSize": 20, 
				"target": "NTA"}
/*/
//-------------------------------------------------------------------
WSMETHOD POST SetFilter WSRECEIVE correcao WSREST JURCONSULTIVO
Local lRet       := .T.
Local lExporta   := .F.
Local lNoFilter  := .F.
Local lPDF       := .F.
Local lCorrige   := Self:correcao == 'true'
Local lAutRec    := InfoSX2('NQ3','X2_AUTREC') == '1'
Local oRequest   := JsonObject():New()
Local oResponse  := JsonObject():New()
Local cAlias     := GetNextAlias()
Local cBody      := Self:GetContent()
Local cUser      := __cUserID
Local cThread    := JGetSecao(cUser, SubStr(AllTrim(Str(ThreadId())),1,4))
Local cAssJur    := Self:GetHeader("TIPOASSJUR")
Local cAssuntos  := ""
Local cQuery     := ""
Local nTotal     := 0
Local nNumReg    := 0
Local nInsertNQ3 := 0
Local aSearchKey := {}
Local aPaginacao := {}
Local aSQL       := {}
Local aAuxFlt    := {}

	oRequest:fromJson(cBody)
	nTotal     := oRequest['count']
	lExporta   := oRequest['export'] == "true"
	aPaginacao := JStPagSize(Str(oRequest['page']), Str(oRequest['pageSize']))

	//-- Tratamento para exportação - Relatório de Pesquisa Avançada
	If lExporta
		lNoFilter  := oRequest['isNoFilter']
		lPDF       := !Empty(oRequest['codRel'])
	EndIf

	// Tratamento dos filtros
	aAuxFlt    := JPreFltQry(cBody)
	aSearchKey := aAuxFlt[1] // Palavras-chave
	aSQL       := aAuxFlt[2] // Filtros adicionais

	If !lExporta .And. nTotal > 0
        cQuery := GetQryFlt(aSearchKey, cAssJur, aSQL, .T.)
        MpSysOpenQuery(cQuery, cAlias)

        oResponse['consultas'] := {}
        oResponse['hasNext']   := .F.
        oResponse['cUserId']   := cUser

        While (cAlias)->(!Eof())
            nNumReg++
            // Controle de paginação
            If (aPaginacao[1] .and. nNumReg > aPaginacao[3]) 
                oResponse['hasNext'] := .T.
                Exit
            ElseIf (!aPaginacao[1] .Or. ;
                    (aPaginacao[1] .And. nNumReg > aPaginacao[2] .And. nNumReg <= aPaginacao[3])) 
                aAdd(oResponse['consultas'], JsonObject():New())
                aTail(oResponse['consultas'])['filialConsulta']     := (cAlias)->NSZ_FILIAL
                aTail(oResponse['consultas'])['codConsulta']        := (cAlias)->NSZ_COD
                aTail(oResponse['consultas'])['tipoSolic']          := JConvUTF8( (cAlias)->NYA_DESC )
				aTail(oResponse['consultas'])['codWF']              := (cAlias)->NSZ_CODWF
				aTail(oResponse['consultas'])['solicConsulta']      := JConvUTF8( (cAlias)->NSZ_SOLICI )
                aTail(oResponse['consultas'])['deptoConsulta']      := JConvUTF8( (cAlias)->X5_DESCRI )
                aTail(oResponse['consultas'])['areaConsulta']       := JConvUTF8( (cAlias)->NRB_DESC )
                aTail(oResponse['consultas'])['dtAberturaConsulta'] := (cAlias)->NSZ_DTINCL
            EndIf
            (cAlias)->(dbSkip())
        EndDo
        (cAlias)->(DbCloseArea())

        oResponse['length'] := JTSQtdSql(GetQryFlt(aSearchKey, cAssJur, aSQL, .F.))
	EndIf

	//-- Tratamento para exportação - Relatório de Pesquisa Avançada
	If lExporta .And. lAutRec
		If lPDF
			cAssuntos := JGetAssJur(GetQryFlt(aSearchKey, cAssJur, aSQL, .F., lExporta, .T.))
		EndIf
		cQuery := GetQryFlt(aSearchKey, cAssJur, aSQL, .F., lExporta, .F.)
		nInsertNQ3 := JLPInsertNQ3(xFilial("NQ3"), cUser, cThread, cQuery)
		If nInsertNQ3 > 0 
			If lCorrige  .And. ;
			!Empty(SuperGetMV('MV_JINDUSR', , "")) .And. ;
			!Empty(SuperGetMV('MV_JINDPSW', , ""))
				// Busca os índices utilizados nos contratos filtrados
				oResponse['listIndice'] := JGetUltAtuInd(, cThread, lAutRec)
			EndIf
		Else 
			nInsertNQ3 := 0
		EndIf
		oResponse['length']   := nInsertNQ3
		oResponse['hasNext']  := .F.
	EndIf

	oResponse['query']    := JConvUTF8(cQuery)
	oResponse['thread']   := cThread
	oResponse['assuntos'] := cAssuntos
	
	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetQryFlt
Monta a consulta para pesquisa avançada de consultivo

@Param aSearchKey - Array de palavras-chave para pesquisa
					{"searchKey01", "searchKey02", ...}
@Param cAssJur    - Código do assunto jurídico
@Param aSQL       - Array de filtros adicionais para pesquisa
					{
						{"NSZ_DETALH", "AND NSZT10.NSZ_DETALH LIKE '%TESTE%'},
						{"NSZ_SOLICI", "AND NSZT10.NSZ_SOLICI = 'TESTE'"},
					}
@Param lOrder     - Indica se a consulta será ordenada
@Param lExporta   - Indica se a consulta é para exportação
@Param lAssJur    - Define se irá buscar o tipo de assunto juridico

@return cQuery    - Consulta de pesquisa avançada de contratos

@since 15/08/2025
/*/
//-------------------------------------------------------------------
Static Function GetQryFlt(aSearchKey, cAssJur, aSQL, lOrder, lExporta, lAssJur)
Local cQuery     := ""
Local cExists    := ""
Local cSearchKey := ""
Local cTabelas   := "NSZ|NVE" // Tabelas em excessão
Local cUser      := __cUserID
Local cThread    := JGetSecao(cUser, SubsTr(AllTrim(Str(ThreadId())), 1, 4))
Local oQuery     := Nil
Local aParams    := {}
Local nI         := 0

Default cAssJur    := "005" 
Default aSearchKey := {}
Default aSQL       := {}
Default lOrder     := .T.
Default lExporta   := .F.
Default lAssJur    := .F.

	If lExporta
		cQuery := " SELECT DISTINCT '?' FILNQ3,"
		aAdd(aParams, {"U", xFilial('NQ3')})
		If lAssJur
			cQuery +=    " NSZ001.NSZ_TIPOAS NSZ_TIPOAS,"
		EndIf
		cQuery += 		 " NSZ001.NSZ_COD NSZ_COD,"
		cQuery +=		 " ?  USUARIO,"
		aAdd(aParams, {"C", cUser})
		cQuery += 		 " ? SECAO,"
		aAdd(aParams, {"C", cThread})
		cQuery += 		 " NSZ001.NSZ_FILIAL NSZ_FILIAL,"
		cQuery += 	 	 " ' ' D_E_L_E_T_"
	Else
		cQuery := " SELECT NSZ001.NSZ_FILIAL  NSZ_FILIAL,"
		cQuery +=        " NSZ001.NSZ_COD     NSZ_COD,"
		cQuery +=        " NYA.NYA_DESC       NYA_DESC,"
		cQuery +=        " NSZ001.NSZ_CODWF   NSZ_CODWF,"
		cQuery +=        " NSZ001.NSZ_SOLICI  NSZ_SOLICI,"
		cQuery +=        " SX5.X5_DESCRI      X5_DESCRI,"
		cQuery +=        " NRB.NRB_DESC       NRB_DESC,"
		cQuery +=        " NSZ001.NSZ_DTINCL  NSZ_DTINCL"
	EndIf
	cQuery += " FROM " + RetSqlName('NSZ') + " NSZ001"
	cQuery +=   " LEFT JOIN " + RetSqlName('NRB') + " NRB"
	cQuery +=     " ON ( NRB.NRB_COD = NSZ001.NSZ_CAREAJ"
	cQuery +=    " AND NRB.D_E_L_E_T_ = ' ' )"
	cQuery +=   " LEFT JOIN " + RetSqlName('NYA') + " NYA"
	cQuery +=     " ON ( NYA.NYA_COD = NSZ001.NSZ_CTPSOL"
	cQuery +=    " AND NYA.D_E_L_E_T_ = ' ' )"
	cQuery +=   " LEFT JOIN " + RetSqlName('SX5') + " SX5"
	cQuery +=     " ON ( SX5.X5_TABELA = 'JZ'"
	cQuery +=    " AND SX5.X5_CHAVE = NSZ001.NSZ_CDPSOL )"

	// Montagem de Joins dinâmicos pelos filtros adicionais
	cQuery += JQryJnFlt(aSQL, @cTabelas, cQuery)

	// Valida assunto jurídico e acessos do usuário
	cAssJur := WsJGetTpAss("'"+cAssJur+"'", .T.)
	cQuery += " WHERE ?"
	aAdd(aParams, {"U", JWhrWSNSZ(,,"NSZ001", cAssJur, .F.)}) 

	// Pesquisa por palavra-chave
	If !Empty(aSearchKey)
		For nI := 1 to Len(aSearchKey)
			cSearchKey := DecodeUTF8(aSearchKey[nI])
			cSearchKey := Lower(StrTran(JurLmpCpo( cSearchKey,.F. ),'#',''))
			// Cajuri
			cExists := " AND " + JurFormat("NSZ_COD", .T.,.T.) + " LIKE '%?%'"
			cExists := " AND (" + SUBSTR(JurGtExist(RetSqlName("NSZ"), cExists, "NSZ001.NSZ_FILIAL"), 5)
			cQuery  += cExists
			aAdd(aParams, {"U", cSearchKey})
			// Descrição
			cExists :=  " AND " + JurFormat("NSZ_DETALH", .T.,.T.) + " LIKE '%?%'"
			cExists :=  " OR " + SUBSTR(JurGtExist(RetSqlName("NSZ"), cExists, "NSZ001.NSZ_FILIAL"), 5)
			cQuery  += cExists
			aAdd(aParams, {"U", cSearchKey})
			// Tipo de solicitação
			cExists :=  " AND " + JurFormat("NYA_DESC", .T.,.T.) + " LIKE '%?%'"
			cExists :=  " OR " + SUBSTR(JurGtExist(RetSqlName("NYA"), cExists, "NSZ001.NSZ_FILIAL"), 5)
			cQuery  += cExists
			aAdd(aParams, {"U", cSearchKey})
			// Detalhes de encerramento
			cExists :=  " AND " + JurFormat("NSZ_DETENC", .T.,.T.) + " LIKE '%?%'"
			cExists :=  " OR " + SUBSTR(JurGtExist(RetSqlName("NSZ"), cExists, "NSZ001.NSZ_FILIAL"), 5)
			cQuery  += cExists
			aAdd(aParams, {"U", cSearchKey})
			// Código do Workflow
			cExists :=  " AND " + JurFormat("NSZ_CODWF", .T.,.T.) + " LIKE '%?%'"
			cExists :=  " OR " + SUBSTR(JurGtExist(RetSqlName("NSZ"), cExists, "NSZ001.NSZ_FILIAL"), 5)
			cQuery  += cExists
			aAdd(aParams, {"U", cSearchKey})
			// Solicitante
			cExists := " AND " + JurFormat("NSZ_SOLICI", .T.,.T.) + " LIKE '%?%')"
			cExists := " OR " + SUBSTR(JurGtExist(RetSqlName("NSZ"), cExists, "NSZ001.NSZ_FILIAL"), 5)
			cQuery  += cExists
			aAdd(aParams, {"U", cSearchKey})
		Next
	EndIf

	// Pesquisa por filtros adicionais
	cQuery += JWhrFltAdd(aSQL, AllTrim(RetSqlName("NSZ")), .F., cTabelas)

	If lOrder
		cQuery += " ORDER BY NSZ001.NSZ_DTINCL"
	EndIf

	oQuery := FWPreparedStatement():New(cQuery)
	oQuery := JQueryPSPr(oQuery, aParams)
	cQuery := oQuery:GetFixQuery()

	// Retirar espaços vazios do JURGTEXIST
	cQuery := StrTran(cQuery,",' '",",''")	
	cQuery := ChangeQuery(cQuery)

Return cQuery

