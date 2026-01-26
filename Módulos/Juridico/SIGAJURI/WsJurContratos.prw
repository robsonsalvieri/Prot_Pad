#INCLUDE "WSJurContratos.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "SHELL.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WSJurContratos
Métodos WS REST do Jurídico para contratos.

@since 17/12/2021
/*/
//-------------------------------------------------------------------

WSRESTFUL JURCONTRATOS DESCRIPTION STR0005// WS Jurídico contratos

	WSDATA filial       AS STRING
	WSDATA codContrato  AS STRING
	WSDATA cTipoAditivo AS STRING
	WSDATA correcao     AS STRING
	WSDATA pageSize     AS Integer

	WSMETHOD GET DetContrato  DESCRIPTION STR0001 PATH "contract/{filial}/{codContrato}"    PRODUCES APPLICATION_JSON // 'Detalhes de contrato'
	WSMETHOD GET aditivos     DESCRIPTION STR0002 PATH "aditivos/{filial}/{codContrato}"    PRODUCES APPLICATION_JSON // 'Aditivos do contrato'
	WSMETHOD GET version      DESCRIPTION STR0006 PATH "version"                            PRODUCES APPLICATION_JSON // 'Versão da API de contratos'

	WSMETHOD POST SetFilter   DESCRIPTION STR0007 PATH "setfilter"                          PRODUCES APPLICATION_JSON // 'Executa a pesquisa avançada de contratos'
    WSMETHOD POST RltDot      DESCRIPTION STR0008 PATH "relDot"                             PRODUCES APPLICATION_JSON // 'Executa a geração da minuta do contrato'

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} version
Retorna a versão e permissões do webserviço de contratos - Usado para proteção de versão
@since 03/06/2025
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET version WSREST JURCONTRATOS
Local oResponse := JsonObject():New()

	Self:SetContentType("application/json")
	
	UpdNVHTpAssJur();

	oResponse['pesquisa-avancada'] := "true"
	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET DetContrato
Detalhes do Contrato

@param filial      - Filial do contrato
@param codContrato - Código do contrato

@since 16/12/21
@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/JURCONTRATOS/contract/{filial}/{codContrato}

/*/
//-------------------------------------------------------------------
WSMETHOD GET DetContrato PATHPARAM filial, codContrato WSREST JURCONTRATOS

Local oResponse  := JsonObject():New()
Local cAlias     := ""
Local cQuery     := ""
Local cForCorre  := ""
Local cTpContr   := ""
Local cDeptSolic := ""
Local cFormPgto  := ""
Local lRet       := .T.
Local cFilCont   := Self:filial
Local cContrato  := Self:codContrato

	If JVldRestri("006", "'14'" /*Processos*/, 2 /*visualizar*/)

		Self:SetContentType("application/json")

		cQuery := WSJDetCon(cFilCont, cContrato)
		cAlias := GetNextAlias()

		DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

		If !(cAlias)->(Eof())
			oResponse['DetailContract'] := {}
			Aadd(oResponse['DetailContract'], JsonObject():New())

			cForCorre  := IIF( !Empty((cAlias)->NSZ_CFCORR), JurGetDados('NW7', 1, xFilial('NW7') + (cAlias)->NSZ_CFCORR, 'NW7_DESC'), '' )
			cTpContr   := IIF( !Empty((cAlias)->NSZ_CODCON), JurGetDados('NY0', 1, xFilial('NY0') + (cAlias)->NSZ_CODCON, 'NY0_DESC'), '' )
			cDeptSolic := IIF( !Empty((cAlias)->NSZ_CDPSOL), SetaDescX5('JZ', (cAlias)->NSZ_CDPSOL ) , '' )
			cFormPgto  := IIF( !Empty((cAlias)->NSZ_CODCON), JurGetDados('NSZ', 1, cFilCont + cContrato , 'NSZ_FPGTO'), '' )

			oResponse['DetailContract'][1]['nomeCliente']             := JConvUTF8( (cAlias)->A1_NOME )
			oResponse['DetailContract'][1]['poloAtivo']               := JConvUTF8( (cAlias)->NSZ_PATIVO )
			oResponse['DetailContract'][1]['poloPassivo']             := JConvUTF8( (cAlias)->NSZ_PPASSI )
			oResponse['DetailContract'][1]['responsavel']             := JConvUTF8( (cAlias)->RD0_NOME )
			oResponse['DetailContract'][1]['formaPgto']               := JConvUTF8( cFormPgto )
			oResponse['DetailContract'][1]['renovacaoAutomatica']     := (cAlias)->NSZ_RENOVA
			oResponse['DetailContract'][1]['numeroContrato']          := JConvUTF8( (cAlias)->NSZ_NUMCON )
			oResponse['DetailContract'][1]['dataInclusao']            := (cAlias)->NSZ_DTINCL
			oResponse['DetailContract'][1]['solicitante']             := JConvUTF8( (cAlias)->NSZ_SOLICI )
			oResponse['DetailContract'][1]['areaJuridica']            := JConvUTF8( (cAlias)->NRB_DESC )
			oResponse['DetailContract'][1]['situacao']                := (cAlias)->NSZ_SITUAC
			oResponse['DetailContract'][1]['departamentoSolicitante'] := cDeptSolic
			oResponse['DetailContract'][1]['valorContrato']           := (cAlias)->NSZ_VLCONT
			oResponse['DetailContract'][1]['inicioVigencia']          := (cAlias)->NSZ_DTINVI
			oResponse['DetailContract'][1]['fimVigencia']             := (cAlias)->NSZ_DTTMVI
			oResponse['DetailContract'][1]['formaCorrecao']           := JConvUTF8( cForCorre )
			oResponse['DetailContract'][1]['valorContratoAtu']        := (cAlias)->NSZ_VACONT
			oResponse['DetailContract'][1]['codFluig']                := JConvUTF8(  (cAlias)->NSZ_CODWF )
			oResponse['DetailContract'][1]['detalhes']                := JConvUTF8( (cAlias)->NSZ_DETALH )
			oResponse['DetailContract'][1]['observacoes']             := JConvUTF8( (cAlias)->NSZ_OBSERV )
			oResponse['DetailContract'][1]['tipoContrato']            := JConvUTF8( cTpContr )
			oResponse['DetailContract'][1]['tipoAssunto']             := (cAlias)->NSZ_TIPOAS
		EndIf

		(cAlias)->( DbCloseArea() )

		Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
	
	Else
		lRet := .F.
		ConOut(STR0003) // Sem permissão para GET em processos
		SetRestFault(403, STR0004) // 2: Acesso negado

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} WSJDetCon
Realiza a query para busca dos detalhes do contrato

@param cFilCont  - Filial do contrato
@param cContrato - Código do contrato
@since 17/12/21
/*/
//-------------------------------------------------------------------
Static Function WSJDetCon( cFilCont, cContrato )

Local cQrySelect := ""
Local cQryFrom   := ""
Local cQryWhere  := ""
Local cQuery     := ""

	cQrySelect := " SELECT SA1.A1_NOME     A1_NOME, "
	cQrySelect +=        " NSZ.NSZ_PATIVO  NSZ_PATIVO, "
	cQrySelect +=        " NSZ.NSZ_PPASSI  NSZ_PPASSI, "
	cQrySelect +=        " RD01.RD0_NOME    RD0_NOME, "
	cQrySelect +=        " NSZ.NSZ_RENOVA  NSZ_RENOVA, "
	cQrySelect +=        " NSZ.NSZ_NUMCON  NSZ_NUMCON, "
	cQrySelect +=        " NSZ.NSZ_DTINCL  NSZ_DTINCL, "
	cQrySelect +=        " NSZ.NSZ_SOLICI  NSZ_SOLICI, "
	cQrySelect +=        " NRB.NRB_DESC    NRB_DESC, "
	cQrySelect +=        " NSZ.NSZ_SITUAC  NSZ_SITUAC, "
	cQrySelect +=        " NSZ.NSZ_CDPSOL  NSZ_CDPSOL, "
	cQrySelect +=        " NSZ.NSZ_VLCONT  NSZ_VLCONT, "
	cQrySelect +=        " NSZ.NSZ_DTINVI  NSZ_DTINVI, "
	cQrySelect +=        " NSZ.NSZ_DTTMVI  NSZ_DTTMVI, "
	cQrySelect +=        " NSZ.NSZ_CFCORR  NSZ_CFCORR, "
	cQrySelect +=        " NSZ.NSZ_VACONT  NSZ_VACONT, "
	cQrySelect +=        " NSZ.NSZ_CODWF   NSZ_CODWF, "
	cQrySelect +=        " NSZ.NSZ_CODCON  NSZ_CODCON, "
	cQrySelect +=        " NSZ.NSZ_TIPOAS  NSZ_TIPOAS, "

	If (Upper(TcGetDb())) == "ORACLE"
		cQrySelect +=    " TO_CHAR(SUBSTR(NSZ.NSZ_DETALH,1,4000))  NSZ_DETALH, "
		cQrySelect +=    " TO_CHAR(SUBSTR(NSZ.NSZ_OBSERV,1,4000))  NSZ_OBSERV "
	Else
		cQrySelect +=    " CAST(NSZ.NSZ_DETALH AS VARCHAR(4000))  NSZ_DETALH, "
		cQrySelect +=    " CAST(NSZ.NSZ_OBSERV AS VARCHAR(4000))  NSZ_OBSERV "
	Endif

	cQryFrom :=        " FROM " + RetSqlName('NSZ') + " NSZ "
	cQryFrom +=   " LEFT JOIN " + RetSqlName('NVE') + " NVE "
	cQryFrom +=          " ON ( NVE.NVE_NUMCAS = NSZ.NSZ_NUMCAS ) "
	cQryFrom +=         " AND ( NVE.NVE_CCLIEN = NSZ.NSZ_CCLIEN ) "
	cQryFrom +=         " AND ( NVE.NVE_LCLIEN = NSZ.NSZ_LCLIEN ) "
	cQryFrom +=         " AND ( NVE.NVE_FILIAL = '" + xFilial('NVE') + "' ) "
	cQryFrom +=         " AND ( NVE.D_E_L_E_T_ = ' ' ) "

	// Cliente
	cQryFrom +=     " INNER JOIN " + RetSqlName("SA1") + " SA1 "
	cQryFrom +=            " ON " + JQryFilial("NSZ","SA1","NSZ","SA1") + " "
	cQryFrom +=                   " AND (SA1.A1_COD = NSZ.NSZ_CCLIEN) "
	cQryFrom +=                   " AND (SA1.A1_LOJA = NSZ.NSZ_LCLIEN) "
	cQryFrom +=                   " AND (SA1.D_E_L_E_T_ = ' ') "

	// Responsavel
	cQryFrom +=     " LEFT JOIN " + RetSqlName('RD0') + " RD01 ON (RD01.RD0_CODIGO = NSZ.NSZ_CPART1) "
	cQryFrom +=                     " AND (RD01.RD0_FILIAL = '" + xFilial("RD0") + "') "
	cQryFrom +=                     " AND (RD01.D_E_L_E_T_ = ' ') "

	// Área juridica
	cQryFrom +=    " LEFT JOIN " + RetSqlName('NRB') + " NRB  ON (NRB.NRB_COD = NSZ.NSZ_CAREAJ) "
	cQryFrom +=                    " AND (NRB.NRB_FILIAL = '" + xFilial("NRB") + "') "
	cQryFrom +=                    " AND (NRB.D_E_L_E_T_ = ' ') "

	cQryWhere  += " WHERE NSZ.NSZ_FILIAL = '" + cFilCont + "' "
	cQryWhere  += " AND NSZ.NSZ_COD = '" + cContrato + "' "
	cQryWhere  += " AND NSZ.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery( cQrySelect + cQryFrom + cQryWhere )
	cQuery := StrTran(cQuery,",' '",",''")

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} GET aditivos
Obtem os aditivos do Contrato

@param filial      - Filial do contrato
@param codContrato - Código do contrato

@since 17/12/21
@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/JURCONTRATOS/aditivos/{filial}/{codContrato}

/*/
//-------------------------------------------------------------------
WSMETHOD GET aditivos PATHPARAM filial, codContrato,cTipoAditivo,pageSize WSREST JURCONTRATOS

Local oResponse     := JsonObject():New()
Local cAlias        := GetNextAlias()
Local cQuery        := ""
Local cFilCont      := Self:filial
Local cContrato     := Self:codContrato
Local cTipoAditivo  := Self:cTipoAditivo
Local nPageSize     := iIF (Empty(Self:pageSize),3,Self:pageSize)
Local nCount        := 0

	Self:SetContentType("application/json")

	cQuery := WSJAditivos(cFilCont, cContrato,cTipoAditivo)

	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery ), cAlias, .F., .F. )

	If !(cAlias)->(Eof())
		oResponse['aditivos'] := {}
		While !(cAlias)->(Eof())
			nCount++
			If nPageSize >= nCount
				Aadd(oResponse['aditivos'], JsonObject():New())

				Atail(oResponse['aditivos'])['codigo']         := (cAlias)->NXY_COD
				Atail(oResponse['aditivos'])['codTipo']        := Alltrim( (cAlias)->NXY_CTIPO )
				Atail(oResponse['aditivos'])['descTipo']       := JConvUTF8( (cAlias)->NXZ_DESC )
				Atail(oResponse['aditivos'])['inicioVigencia'] := Alltrim( (cAlias)->NXY_DTINVI )
				Atail(oResponse['aditivos'])['fimVigencia']    := Alltrim( (cAlias)->NXY_DTTMVI )
				Atail(oResponse['aditivos'])['valor']          := (cAlias)->NXY_VLADIT

			EndIf
			(cAlias)->(DbSkip())
		End
	EndIf 

	(cAlias)->( DbCloseArea())

	oResponse["total"]   := nCount
	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} WSJAditivos
Realiza a query para busca dos aditivos do contrato

@param cFilCont  - Filial do contrato
@param cContrato - Código do contrato
@since 17/12/21
/*/
//-------------------------------------------------------------------
Static Function WSJAditivos( cFilCont, cContrato, cTipoAditivo )
Local cQrySelect := ""
Local cQryFrom   := ""
Local cQryWhere  := ""
Local cQuery     := ""
Local cOrder     := " ORDER BY NSZ_DTADIT DESC "

Default cTipoAditivo := ''

	cQrySelect := " SELECT NXY_CTIPO,  "
	cQrySelect +=        " NXZ_DESC,   "
	cQrySelect +=        " NXY_DTINVI, "
	cQrySelect +=        " NXY_DTTMVI, "
	cQrySelect +=        " NXY_VLADIT, "
	cQrySelect +=        " NXY_COD "

	cQryFrom :=  " FROM " + RetSqlName('NSZ') + " NSZ "

	// Aditivos
	cQryFrom +=         " INNER JOIN " + RetSqlName('NXY') + " NXY "
	cQryFrom +=                  " ON NXY.NXY_CAJURI = NSZ.NSZ_COD "
	cQryFrom +=                  " AND NXY.D_E_L_E_T_ = ' ' "

	// Tipos de aditivos
	cQryFrom +=         " INNER JOIN " + RetSqlName('NXZ') + " NXZ "
	cQryFrom +=                  " ON NXZ.NXZ_COD = NXY.NXY_CTIPO "
	cQryFrom +=                  " AND NXZ.D_E_L_E_T_ = ' ' "	

	cQryWhere  += " WHERE NSZ.NSZ_FILIAL = '" + cFilCont + "' "
	cQryWhere  += " AND NSZ.NSZ_COD = '" + cContrato + "' "
	cQryWhere  += " AND NSZ.D_E_L_E_T_ = ' ' "

	If(!Empty(cTipoAditivo))
       cQryWhere  += " AND NXY.NXY_CTIPO= '" + cTipoAditivo + "' "
    EndIf
	
	cQuery := ChangeQuery( cQrySelect + cQryFrom + cQryWhere + cOrder )
	cQuery := StrTran(cQuery,",' '",",''")

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} POST SetFilter
Executa a pesquisa avançada de contratos

@param correcao - Informa se sofrerá correção monetária ou não
@return lRet    - .T.

@since 29/05/2025

@example [Sem Opcional] POST -> http://localhost:12173/rest/JURCONTRATOS/SetFilter
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
WSMETHOD POST SetFilter WSRECEIVE correcao WSREST JURCONTRATOS
Local lRet       := .T.
Local oRequest   := JsonObject():New()
Local oResponse  := JsonObject():New()
Local cAlias     := GetNextAlias()
Local cBody      := Self:GetContent()
Local cUser      := __cUserID
Local cAssJur    := Self:GetHeader("TIPOASSJUR")
Local cQuery     := ""
Local cThread    := JGetSecao(cUser, SubStr(AllTrim(Str(ThreadId())),1,4))
Local nTotal     := 0
Local nNumReg    := 0
Local nInsertNQ3 := 0
Local aSearchKey := {}
Local aPaginacao := {}
Local aSQL       := {}
Local aAuxFlt    := {}
Local lAutRec    := InfoSX2('NQ3','X2_AUTREC') == '1'
Local lExporta   := .F.
Local lNoFilter  := .F.
Local lPDF       := .F.
Local cAssuntos  := ""
Local lCorrige   := Self:correcao == 'true'

	oRequest:fromJson(cBody)
	nTotal     := oRequest['count']
	lExporta   := oRequest['export'] == "true"
	aPaginacao := JStPagSize(Str(oRequest['page']), Str(oRequest['pageSize']))

	//-- Tratamento para exportação - Relatório de Pesquisa Avançada
	If lExporta
		lNoFilter  := oRequest['isNoFilter']
		lPDF       := !Empty(oRequest['codRel'])
	EndIf

	If nTotal > 0 .Or. lNoFilter
		// Tratamento dos filtros
		aAuxFlt    := JPreFltQry(cBody)
		aSearchKey := aAuxFlt[1] // Palavras-chave
		aSQL       := aAuxFlt[2] // Filtros adicionais
		
		// Consulta com filtro
		If (!lNoFilter .And. !lExporta) .Or. (!lAutRec .And. lExporta) 

			cQuery := GetQryFlt(aSearchKey, cAssJur, aSQL, lExporta, .F.)
			MpSysOpenQuery(cQuery, cAlias)

			oResponse['contracts'] := {}
			oResponse['hasNext']   := .F.
			oResponse['cUserId']   := cUser
			oResponse['count']     := 0

			While (cAlias)->(!Eof())
				nNumReg++
				// Controle de paginação
				If (!lExporta)
					If (aPaginacao[1] .and. nNumReg > aPaginacao[3]) 
						oResponse['hasNext'] := .T.
						Exit
					ElseIf (!aPaginacao[1] .Or. ;
							(aPaginacao[1] .And. nNumReg > aPaginacao[2] .And. nNumReg <= aPaginacao[3])) 
						aAdd(oResponse['contracts'], JsonObject():New())
						aTail(oResponse['contracts'])['filialContract'] := (cAlias)->NSZ_FILIAL
						aTail(oResponse['contracts'])['codContract']    := (cAlias)->NSZ_COD
						aTail(oResponse['contracts'])['nomeContract']   := JConvUTF8( (cAlias)->NVE_TITULO )
						aTail(oResponse['contracts'])['numContract']    := JConvUTF8( (cAlias)->NSZ_NUMCON )
						aTail(oResponse['contracts'])['dataIniVig']     := (cAlias)->NSZ_DTINVI
						aTail(oResponse['contracts'])['dataFimVig']     := (cAlias)->NSZ_DTTMVI
						aTail(oResponse['contracts'])['valorContract']  := (cAlias)->NSZ_VLCONT
					EndIf
				EndIf
				(cAlias)->(dbSkip())
			EndDo

			(cAlias)->(DbCloseArea())

			oResponse['length']   := JTSQtdSql(GetQryFlt(aSearchKey, cAssJur, aSQL, .T., .F.))

		EndIf
	EndIf

	If lExporta .AND. lAutRec
		If lPDF
			cAssuntos := JGetAssJur(GetQryFlt(aSearchKey, cAssJur, aSQL, lExporta, .T.))
		EndIf
		cQuery := GetQryFlt(aSearchKey, cAssJur, aSQL, lExporta, .F.)
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
Monta a consulta para pesquisa avançada de contratos

@Param aSearchKey - Array de palavras-chave para pesquisa
					{"searchKey01", "searchKey02", ...}
@Param cAssJur    - Código do assunto jurídico
@Param aSQL       - Array de filtros adicionais para pesquisa
					{
						{"NSZ_DETALH", "AND NSZT10.NSZ_DETALH LIKE '%TESTE%'},
						{"NSZ_SOLICI", "AND NSZT10.NSZ_SOLICI = 'TESTE'"},
					}
@Param lExporta   - Indica se é inclusão via query
@Param lAssJur    - Define se irá buscar o tipo de assunto juridico
@return cQuery    - Consulta de pesquisa avançada de contratos

@since 29/05/2025
/*/
//-------------------------------------------------------------------
Static Function GetQryFlt(aSearchKey, cAssJur, aSQL, lExporta, lAssJur)
Local cQuery     := ""
Local cExists    := ""
Local cSearchKey := ""
Local cTabelas   := "NSZ|NVE" // Tabelas em excessão
Local cUser      := __cUserID
Local cThread    := JGetSecao(cUser, SubsTr(AllTrim(Str(ThreadId())), 1, 4))
Local oQuery     := Nil
Local aParams    := {}
Local nI         := 0

Default cAssJur    := "006" 
Default aSearchKey := {}
Default aSQL       := {}
Default lExporta   := .F.
Default lAssJur    := .F.

	If lExporta
		cQuery := " SELECT DISTINCT '?' FILNQ3, "
		aAdd(aParams, {"U", xFilial('NQ3')})
		If lAssJur
			cQuery +=    " NSZ001.NSZ_TIPOAS NSZ_TIPOAS, "
		EndIf
		cQuery += 		 " NSZ001.NSZ_COD NSZ_COD, "
		cQuery +=		 " ?  USUARIO, "
		aAdd(aParams, {"C", cUser})
		cQuery += 		 " ? SECAO, "
		aAdd(aParams, {"C", cThread})
		cQuery += 		 " NSZ001.NSZ_FILIAL NSZ_FILIAL, "
		cQuery += 	 	 " ' ' D_E_L_E_T_ "
	Else
		cQuery := " SELECT NSZ001.NSZ_FILIAL  NSZ_FILIAL,"
		cQuery +=        " NSZ001.NSZ_COD     NSZ_COD,"
		cQuery +=        " NVE.NVE_TITULO  NVE_TITULO,"
		cQuery +=        " NSZ001.NSZ_NUMCON  NSZ_NUMCON,"
		cQuery +=        " NSZ001.NSZ_DTINVI  NSZ_DTINVI,"
		cQuery +=        " NSZ001.NSZ_DTTMVI  NSZ_DTTMVI,"
		cQuery +=        " NSZ001.NSZ_VLCONT  NSZ_VLCONT"
	EndIf
	cQuery +=       " FROM " + RetSqlName('NSZ') + " NSZ001"
	cQuery +=       " LEFT JOIN " + RetSqlName('NVE') + " NVE"
	cQuery +=         " ON ( NVE.NVE_NUMCAS = NSZ001.NSZ_NUMCAS"
	cQuery +=        " AND NVE.NVE_CCLIEN = NSZ001.NSZ_CCLIEN"
	cQuery +=        " AND NVE.NVE_LCLIEN = NSZ001.NSZ_LCLIEN"
	cQuery +=        " AND NVE.NVE_FILIAL = '?'"
	aAdd(aParams, {"U", xFilial("NVE")})
	cQuery +=        " AND NVE.D_E_L_E_T_ = ' ' )"

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
			// Número do contrato
			cExists :=  " AND " + JurFormat("NSZ_NUMCON", .F.,.T.) + " LIKE '%?%'"
			cExists :=  " OR " + SUBSTR(JurGtExist(RetSqlName("NSZ"), cExists, "NSZ001.NSZ_FILIAL"), 5)
			cQuery  += cExists
			aAdd(aParams, {"U", cSearchKey})
			// Número do Workflow FLUIG
			cExists :=  " AND " + JurFormat("NSZ_CODWF", .F.,.T.) + " LIKE '%?%'"
			cExists :=  " OR " + SUBSTR(JurGtExist(RetSqlName("NSZ"), cExists, "NSZ001.NSZ_FILIAL"), 5)
			cQuery  += cExists
			aAdd(aParams, {"U", cSearchKey})
			// Caso
			cExists := " AND " + JurFormat("NT9_NOME", .T.,.T.) + " LIKE '%?%')"
			cExists := " OR " + SUBSTR(JurGtExist(RetSqlName("NT9"), cExists, "NSZ001.NSZ_FILIAL"), 5)
			cQuery  += cExists
			aAdd(aParams, {"U", cSearchKey})
		Next
	EndIf

	// Pesquisa por filtros adicionais
	cQuery += JWhrFltAdd(aSQL, AllTrim(RetSqlName("NSZ")), .F., cTabelas)

	If !lExporta
		cQuery += " ORDER BY NSZ001.NSZ_DTTMVI"
	EndIf

	oQuery := FWPreparedStatement():New(cQuery)
	oQuery := JQueryPSPr(oQuery, aParams)
	cQuery := oQuery:GetFixQuery()

	// Retirar espaços vazios do JURGTEXIST
	cQuery := StrTran(cQuery,",' '",",''")	
	cQuery := ChangeQuery(cQuery)

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} UpdNVHTpAssJur
Executa a compatibilização dos tipos de assunto jurídico na NVH

@since 06/06/2025
/*/
//-------------------------------------------------------------------
Static Function UpdNVHTpAssJur()
Local cAlias   := GetNextAlias()
Local cQuery   := ""
Local cSelect  := ""
Local cWhere   := ""
Local cAssJur  := ""
Local oQuery   := Nil
Local aParams  := {}
Local aCmpProc := {}
Local aCmpCont := {}
Local aCmpCons := {}
Local nPosProc := 0
Local nPosCont := 0
Local nPosCons := 0

	DbSelectArea("NVH")
	If ColumnPos("NVH_TIPOAS") > 0
		// Proteção para não executar a compatibilização se já estiver feito
		cQuery := "SELECT NVH_TIPOAS FROM " + RetSqlName("NVH") + " WHERE NVH_TIPOAS <> ' ' "
		MpSysOpenQuery(cQuery, cAlias)
		If (cAlias)->(Eof())
			cSelect := "SELECT DISTINCT "
			cSelect +=       " NUZ_CAMPO"
			cSelect +=  " FROM " + RetSqlName("NUZ")
			cSelect += " WHERE NUZ_CTAJUR ?"

			// 01. Apenas processos
			cWhere := " NOT IN ('005', '006')"
			aAdd(aParams, {"U", cWhere})
			oQuery := FWPreparedStatement():New(cSelect)
			oQuery := JQueryPSPr(oQuery, aParams)
			cQuery := oQuery:GetFixQuery()
			MpSysOpenQuery(cQuery, cAlias)
			oQuery := Nil
			cQuery := ""
			aSize(aParams, 0)

			While (cAlias)->(!Eof())
				aAdd(aCmpProc, (cAlias)->NUZ_CAMPO)
				(cAlias)->(dbSkip())
			EndDo
			(cAlias)->( DBCloseArea() )

			// 02. Apenas contratos
			cWhere := " IN ('006')"
			aAdd(aParams, {"U", cWhere})
			oQuery := FWPreparedStatement():New(cSelect)
			oQuery := JQueryPSPr(oQuery, aParams)
			cQuery := oQuery:GetFixQuery()
			MpSysOpenQuery(cQuery, cAlias)
			oQuery := Nil
			cQuery := ""
			aSize(aParams, 0)

			While (cAlias)->(!Eof())
				aAdd(aCmpCont, (cAlias)->NUZ_CAMPO)
				(cAlias)->(dbSkip())
			EndDo
			(cAlias)->( DBCloseArea() )

			// 03. Apenas consultas
			cWhere := " IN ('005')"
			aAdd(aParams, {"U", cWhere})
			oQuery := FWPreparedStatement():New(cSelect)
			oQuery := JQueryPSPr(oQuery, aParams)
			cQuery := oQuery:GetFixQuery()
			MpSysOpenQuery(cQuery, cAlias)
			oQuery := Nil
			cQuery := ""
			aSize(aParams, 0)

			While (cAlias)->(!Eof())
				aAdd(aCmpCons, (cAlias)->NUZ_CAMPO)
				(cAlias)->(dbSkip())
			EndDo
			(cAlias)->( DBCloseArea() )

			// Percorrer os campos da NVH, realizando tratamentos para Contratos, Consultas e Processos
			cQuery := "SELECT DISTINCT NVH_FILIAL,"
			cQuery +=       " NVH_COD,"
			cQuery +=       " NVH_CAMPO,"
			cQuery +=       " NVH_TIPOAS,"
			// Campos usados para duplicar os registros
			cQuery +=       " NVH_DESC,"
			cQuery +=       " NVH_TABELA,"
			cQuery +=       JQryMemo("NVH_WHERE", Nil, Nil, 4000) + " NVH_WHERE,"
			cQuery +=       " NVH_PROPRI,"
			cQuery +=       " NVH_F3DIF,"
			cQuery +=       " NVH_F3CONS,"
			cQuery +=       " NVH_F3MULT,"
			cQuery +=       " NVH_CHAVE,"
			cQuery +=       " NVH_LABEL"
			cQuery +=  " FROM " + RetSqlName("NVH")
			cQuery += " WHERE D_E_L_E_T_ = ' '"
			cQuery +=   " AND NVH_FILIAL = '?'"
			aAdd(aParams, {"U", xFilial("NVH")})
			cQuery +=   " AND NVH_TPPESQ = '1'"
			oQuery := FWPreparedStatement():New(cQuery)
			oQuery := JQueryPSPr(oQuery, aParams)
			cQuery := oQuery:GetFixQuery()
			MpSysOpenQuery(cQuery, cAlias)
			oQuery := Nil
			cQuery := ""
			aSize(aParams, 0)

			While (cAlias)->(!EoF())
				NVH->(DbSetOrder(3)) // NVH_FILIAL+NVH_CAMPO+NVH_TPPESQ+NVH_TIPOAS
				nPosProc := aScan(aCmpProc, (cAlias)->NVH_CAMPO)
				nPosCont := aScan(aCmpCont, (cAlias)->NVH_CAMPO)
				nPosCons := aScan(aCmpCons, (cAlias)->NVH_CAMPO)

				// Verifica se o campo é de processo + contrato + consulta
				If (nPosProc > 0 .And. nPosCont > 0 .And. nPosCons > 0)
					cAssJur := "   "
				ElseIf (nPosProc > 0 .And. nPosCont > 0) // Verifica se o campo é de processo + contrato
					cAssJur := "001"
					// Criar novo registro  para contrato com assjur 006
					If RecLock("NVH", .T.)
						NVH->NVH_FILIAL := (cAlias)->NVH_FILIAL
						NVH->NVH_COD    := GetSXENum("NVH", "NVH_COD")
						NVH->NVH_DESC   := (cAlias)->NVH_DESC
						NVH->NVH_TABELA := (cAlias)->NVH_TABELA
						NVH->NVH_CAMPO  := (cAlias)->NVH_CAMPO
						NVH->NVH_WHERE  := (cAlias)->NVH_WHERE
						NVH->NVH_PROPRI := (cAlias)->NVH_PROPRI == 'T'
						NVH->NVH_F3DIF  := (cAlias)->NVH_F3DIF  == 'T'
						NVH->NVH_F3CONS := (cAlias)->NVH_F3CONS
						NVH->NVH_F3MULT := (cAlias)->NVH_F3MULT == 'T'
						NVH->NVH_CHAVE  := (cAlias)->NVH_CHAVE
						NVH->NVH_LABEL  := (cAlias)->NVH_LABEL
						NVH->NVH_QTDUSO := 0
						NVH->NVH_TPPESQ := "1"
						NVH->NVH_TIPOAS := "006"
						NVH->(MsUnLock())
						If __lSX8
  							ConfirmSX8()
						EndIf
					EndIf
				ElseIf (nPosProc > 0 .And. nPosCons > 0) // Verifica se o campo é de processo + consulta
					cAssJur := "001"
					// Criar novo registro  para consulta com assjur 005
					If RecLock("NVH", .T.)
						NVH->NVH_FILIAL := (cAlias)->NVH_FILIAL
						NVH->NVH_COD    := GetSXENum("NVH", "NVH_COD")
						NVH->NVH_DESC   := (cAlias)->NVH_DESC
						NVH->NVH_TABELA := (cAlias)->NVH_TABELA
						NVH->NVH_CAMPO  := (cAlias)->NVH_CAMPO
						NVH->NVH_WHERE  := (cAlias)->NVH_WHERE
						NVH->NVH_PROPRI := (cAlias)->NVH_PROPRI == 'T'
						NVH->NVH_F3DIF  := (cAlias)->NVH_F3DIF  == 'T'
						NVH->NVH_F3CONS := (cAlias)->NVH_F3CONS
						NVH->NVH_F3MULT := (cAlias)->NVH_F3MULT == 'T'
						NVH->NVH_CHAVE  := (cAlias)->NVH_CHAVE
						NVH->NVH_LABEL  := (cAlias)->NVH_LABEL
						NVH->NVH_QTDUSO := 0
						NVH->NVH_TPPESQ := "1"
						NVH->NVH_TIPOAS := "005"
						NVH->(MsUnLock())
						If __lSX8
  							ConfirmSX8()
						EndIf
					EndIf
				ElseIf (nPosCont > 0 .And. nPosCons > 0) // Verifica se o campo é de contrato + consulta
					cAssJur := "006"
					// Criar novo registro  para consulta com assjur 005
					If RecLock("NVH", .T.)
						NVH->NVH_FILIAL := (cAlias)->NVH_FILIAL
						NVH->NVH_COD    := GetSXENum("NVH", "NVH_COD")
						NVH->NVH_DESC   := (cAlias)->NVH_DESC
						NVH->NVH_TABELA := (cAlias)->NVH_TABELA
						NVH->NVH_CAMPO  := (cAlias)->NVH_CAMPO
						NVH->NVH_WHERE  := (cAlias)->NVH_WHERE
						NVH->NVH_PROPRI := (cAlias)->NVH_PROPRI == 'T'
						NVH->NVH_F3DIF  := (cAlias)->NVH_F3DIF  == 'T'
						NVH->NVH_F3CONS := (cAlias)->NVH_F3CONS
						NVH->NVH_F3MULT := (cAlias)->NVH_F3MULT == 'T'
						NVH->NVH_CHAVE  := (cAlias)->NVH_CHAVE
						NVH->NVH_LABEL  := (cAlias)->NVH_LABEL
						NVH->NVH_QTDUSO := 0
						NVH->NVH_TPPESQ := "1"
						NVH->NVH_TIPOAS := "005"
						NVH->(MsUnLock())
						If __lSX8
  							ConfirmSX8()
						EndIf
					EndIf
				Else
					// Verifica se o campo é único de cada assunto
					If (nPosProc > 0)
						cAssJur := "001"
					ElseIf (nPosCont > 0)
						cAssJur := "006"
					ElseIf (nPosCons > 0)
						cAssJur := "005"
					EndIf
				EndIf

				// Atualiza o campo NVH_TIPOAS com o assunto jurídico
				If NVH->(DbSeek((cAlias)->NVH_FILIAL + (cAlias)->NVH_CAMPO + "1" + (cAlias)->NVH_TIPOAS))
					If RecLock("NVH", .F.)
						NVH->NVH_TIPOAS := cAssJur
						NVH->(MsUnLock())
					EndIF
				EndIf

				(cAlias)->(dbSkip())
			EndDo
			(cAlias)->( DBCloseArea() )
		EndIf
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} POST RltDot
Executa a pesquisa avançada de contratos

@return lRet - .T.

@since 25/07/2025

@example POST -> http://localhost:12173/rest/JURCONTRATOS/relDot
@param Body - {
				"cajuri": "0000000001",
				"codRel": "005",
				"tipoDoc": "P",
			  }
/*/
//-------------------------------------------------------------------
WSMETHOD POST RltDot WSREST JURCONTRATOS
Local lRet      := .T.
Local oRequest  := JsonObject():New()
Local oResponse := JsonObject():New()
Local oJsonRel  := Nil
Local cBody     := Self:GetContent()
Local cUserTkn  := JGetAuthTk()
Local cLink     := ""

	oRequest:fromJson(cBody)
	DbSelectArea("NSZ")
	NSZ->(dbSetOrder(1)) // NSZ_FILIAL+NSZ_COD

	If NSZ->(dbSeek(xFilial("NSZ")+oRequest["cajuri"]))
		cLink := JurGetDados("NZ7",1,xFilial("NZ7") + NSZ->NSZ_CCLIEN + NSZ->NSZ_LCLIEN + NSZ->NSZ_NUMCAS, "NZ7_LINK")
		cLink := Left(cLink,At(';', cLink)-1)

		oJsonRel := J288JsonRel()
		oJsonRel['O17_URLREQ'] := Substr(Self:GetPath(), At('JURCONTRATOS',Self:GetPath()))
		oJsonRel['O17_BODY']   := oRequest:toJson()
		J288GestRel(oJsonRel)

		oResponse['message'] := JConvUTF8(STR0009) // "O arquivo será gerado em segundo plano. Quando finalizado, será enviado uma notificação para realizar o download."

		STARTJOB("JWSCntGrMn", GetEnvServer(), .F.,;
				cEmpAnt,;
				cFilAnt,;
				cUserTkn,;
				oRequest["codRel"],;
				oRequest["cajuri"],;
				cLink,;
				!Empty(cLink),;
				/*cFilNsz*/,;
				oRequest["tipoDoc"],;
				oJsonRel:toJson())
	EndIf

	NSZ->(dbCloseArea())

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JWSCntGrMn()
Executa a geração da minuta em segundo plano

@Param cSrvEmp  - Empresa
@Param cSrvFil  - Filial
@Param cUserTkn - Token do usuário
@Param cCodRel  - Código do relatório
@Param cCajuri  - Código do contrato
@Param cPasta   - Pasta do Fluig
@Param lFluig   - Indica se é Fluig
@Param cFilNsz  - Filial da NSZ
@Param cTipoDoc - Tipo do documento
@Param cGstRel  - JSON de controle da gestão de relatórios

@since 25/07/2025
/*/
//-------------------------------------------------------------------
Function JWSCntGrMn(cSrvEmp, cSrvFil, cUserTkn, cCodRel, cCajuri, cPasta, lFluig, cFilNsz, cTipoDoc, cGstRel)

	RPCSetType(3)
	RPCSetEnv(cSrvEmp,cSrvFil, , , 'JURI')

	// Valida se o usuário informado é válido
	JHasUserTk(cUserTkn)

	J162StartBG(cCodRel, cCajuri, cPasta, lFluig, cFilNsz, cTipoDoc, cGstRel)
Return Nil
