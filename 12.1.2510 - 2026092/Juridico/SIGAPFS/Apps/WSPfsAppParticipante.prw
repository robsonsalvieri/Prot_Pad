#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "WSPFSAPPPARTICIPANTE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WsPfsParticipante
Métodos WS para Participantes

@author Willian Yoshiaki Kazahaya
@since 19/04/2024
@version 1.0
/*/
//-------------------------------------------------------------------
WSRESTFUL WsPfsParticipante DESCRIPTION STR0001 //"Webservice para Participantes"
	WSDATA pageSize     as String
	WSDATA page         as String
	WSDATA codFornec    as String
	WSDATA lojaFornec   as String

	WSMETHOD GET lsBancoFornec  DESCRIPTION STR0004 PATH "bancosFornecedor/{codFornec}/{lojaFornec}" PRODUCES APPLICATION_JSON // "Lista de Bancos por fornecedor"
	WSMETHOD PUT lsParticipante DESCRIPTION STR0002 PATH "grid"                                      PRODUCES APPLICATION_JSON // "Lista de Participantes"
End WSRESTFUL


//-------------------------------------------------------------------
/*/{Protheus.doc} lsParticipante( oBody, cAlias )
Query de busca dos dados do participante

@author Willian Yoshiaki Kazahaya
@since 24/04/2024
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD PUT lsParticipante QUERYPARAM pageSize, page WSREST WsPfsParticipante
Local oJsonBody       := JsonObject():new()
Local oResponse       := JsonObject():New()
Local cAlias          := ""
Local aPaginacao      := {}
Local lRet            := .F.
Local nNumReg         := 0

Default Self:page     := '1'
Default Self:pageSize := '10'

	aPaginacao := JStPagSize(Self:page, Self:pageSize)
	cBody      := StrTran(Self:GetContent(), CHR(10), "")
	oJsonBody:FromJson(cBody)

	cAlias := QryLsParts( oJsonBody, cAlias )
	oResponse['hasNext'] := .F.
	oResponse['participantes'] := {}
	While (cAlias)->(!Eof())
		nNumReg++
		If (aPaginacao[1] .and. nNumReg > aPaginacao[3])
			oResponse['hasNext'] := .T.
			Exit
		ElseIf (!aPaginacao[1] .Or. ;
				(aPaginacao[1] .And. nNumReg > aPaginacao[2] .And. nNumReg <= aPaginacao[3]))
			aAdd(oResponse['participantes'], JsonObject():New())
			aTail(oResponse['participantes'])['pk']            := Encode64((cAlias)->RD0_FILIAL + (cAlias)->RD0_CODIGO)
			aTail(oResponse['participantes'])['filial']        := (cAlias)->RD0_FILIAL
			aTail(oResponse['participantes'])['codigo']        := (cAlias)->RD0_CODIGO
			aTail(oResponse['participantes'])['nome']          := JConvUTF8((cAlias)->RD0_NOME)
			aTail(oResponse['participantes'])['tipo']          := (cAlias)->RD0_TIPO
			aTail(oResponse['participantes'])['dataAdmissao']  := (cAlias)->RD0_DTADMI
			aTail(oResponse['participantes'])['email']         := JConvUTF8((cAlias)->RD0_EMAIL)
			aTail(oResponse['participantes'])['sigla']         := JConvUTF8((cAlias)->RD0_SIGLA)
			aTail(oResponse['participantes'])['ativo']         := (cAlias)->RD0_MSBLQL == '2'
			aTail(oResponse['participantes'])['categoria']     := JConvUTF8((cAlias)->NRN_DESC)
		EndIf
		(cAlias)->(DbSkip())
	EndDo

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} QryLsParts( oBody, cAlias )
Query de busca dos dados do participante

@author Willian Yoshiaki Kazahaya
@since 24/04/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function QryLsParts( oBody, cAlias )
Local aCpoSrch   := {"RD0_NOME", "RD0_SIGLA", "RD0_EMAIL"}
Local aQryParams := {}
Local cSearchKey := ""
Local cQry       := ""
Local nI         := 0
Local oQuery     := Nil

	cQry := " SELECT RD0_FILIAL,"
	cQry +=        " RD0_CODIGO,"
	cQry +=        " RD0_NOME,"
	cQry +=        " RD0_TIPO,"
	cQry +=        " RD0_DTADMI,"
	cQry +=        " RD0_EMAIL,"
	cQry +=        " RD0_SIGLA,"
	cQry +=        " RD0.RD0_MSBLQL,"
	cQry +=        " NRN.NRN_DESC"

	// Participante
	cQry +=   " FROM " + RetSqlName("RD0") + " RD0"

	// Tabela auxiliar de Participante Jurídico
	cQry +=   " LEFT JOIN " + RetSqlName("NUR") + " NUR"
	cQry +=     " ON (NUR.NUR_CPART = RD0.RD0_CODIGO"
	cQry +=    " AND NUR.D_E_L_E_T_ = ' ')"

	// Categoria de Participante
	cQry +=   " LEFT JOIN " + RetSqlName("NRN") + " NRN "
	cQry +=     " ON (NRN.NRN_COD = NUR.NUR_CCAT"
	cQry +=    " AND NRN.D_E_L_E_T_ = ' ')
	cQry +=  " WHERE RD0.D_E_L_E_T_ = ' '"

	If !Empty(oBody['searchkey'])
		cSearchKey := StrTran( JurLmpCpo( Decode64(oBody['searchkey']), .F., .F. ), '#', '' )
		cQry += " AND ("
		For nI := 1 To Len(aCpoSrch)
			cQry += " LOWER(TRIM(?)) LIKE '%?%' OR"
			aAdd(aQryParams, { "U", aCpoSrch[nI] })
			aAdd(aQryParams, { "U", Lower(Trim(cSearchKey))  })

			cQry +=  " LOWER(TRIM(?)) LIKE '%?%' OR"
			aAdd(aQryParams, { "U", JurFormat(aCpoSrch[nI], .T./*lAcentua*/)  })
			aAdd(aQryParams, { "U", Lower(Trim(cSearchKey)) })
			
		Next nI
		cQry := Substring(cQry,1, Len(cQry)-2) + ")"
	EndIf

	oQuery := FWPreparedStatement():New(cQry)
	oQuery := JQueryPSPr(oQuery, aQryParams)
	cQry   := oQuery:GetFixQuery()

	cAlias := GetNextAlias()
	MPSysOpenQuery(cQry, cAlias)

Return cAlias 

//-------------------------------------------------------------------
/*/{Protheus.doc} GET lsBancoFornec
Retorna a lista de bancos conforme o fornecedor selecionado

@example GET -> http://localhost:12173/rest/WsPfsParticipante/bancosFornecedor/UNO/01

@param codFornec  - Código do fornecedor
@param lojaFornec - Loja do fornecedor

@author Bruno Henrique Silva Soares
@since 26/09/2024
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET lsBancoFornec PATHPARAM codFornec, lojaFornec WSREST WsPfsParticipante
Local oResponse   := JsonObject():New()
Local oFIL        := Nil
Local cAlias      := GetNextAlias()
Local cQuery      := ""
Local cCdFornec   := Self:codFornec
Local cLjFornec   := Self:lojaFornec
Local aParams     := {}
Local lRet        := .T.

	If !Empty(cCdFornec) .And. !Empty(cLjFornec)
		cQuery += " SELECT FIL.FIL_FILIAL,"
		cQuery +=        " FIL.FIL_FORNEC,"
		cQuery +=        " FIL.FIL_LOJA  ,"
		cQuery +=        " FIL.FIL_BANCO ,"
		cQuery +=        " FIL.FIL_AGENCI,"
		cQuery +=        " FIL.FIL_DVAGE ,"
		cQuery +=        " FIL.FIL_CONTA ,"
		cQuery +=        " FIL.FIL_DVCTA ,"
		cQuery +=        " FIL.FIL_TIPO  ,"
		cQuery +=        " FIL.FIL_DETRAC,"
		cQuery +=        " FIL.FIL_MOEDA ,"
		cQuery +=        " FIL.FIL_TIPCTA,"
		cQuery +=        " FIL.FIL_MOVCTO "
		cQuery +=   " FROM " + RetSqlName("FIL") + " FIL "
		cQuery +=  " WHERE FIL.FIL_FILIAL = ? "
		aAdd(aParams, {"C", xFilial("FIL")})
		cQuery +=    " AND FIL.FIL_FORNEC = ? "
		aAdd(aParams, {"C", cCdFornec})
		cQuery +=    " AND FIL.FIL_LOJA   = ? "
		aAdd(aParams, {"C", cLjFornec})
		cQuery +=    " AND FIL.D_E_L_E_T_ = ' '"

		oFIL := FWPreparedStatement():New(cQuery)
		oFIL := JQueryPSPr(oFIL, aParams)

		cQuery := oFIL:GetFixQuery()
		MpSysOpenQuery(cQuery, cAlias)

		oResponse["bancos"] := {}

		While (cAlias)->(!EoF())
			aAdd(oResponse["bancos"], JsonObject():New())
			aTail(oResponse["bancos"])["filial"]     := (cAlias)->FIL_FILIAL
			aTail(oResponse["bancos"])["fornecedor"] := (cAlias)->FIL_FORNEC
			aTail(oResponse["bancos"])["loja"]       := (cAlias)->FIL_LOJA
			aTail(oResponse["bancos"])["banco"]      := (cAlias)->FIL_BANCO
			aTail(oResponse["bancos"])["agencia"]    := (cAlias)->FIL_AGENCI
			aTail(oResponse["bancos"])["dvAgencia"]  := (cAlias)->FIL_DVAGE
			aTail(oResponse["bancos"])["conta"]      := (cAlias)->FIL_CONTA
			aTail(oResponse["bancos"])["dvConta"]    := (cAlias)->FIL_DVCTA
			aTail(oResponse["bancos"])["tipoCc"]     := (cAlias)->FIL_TIPO
			aTail(oResponse["bancos"])["detrac"]     := (cAlias)->FIL_DETRAC
			aTail(oResponse["bancos"])["moeda"]      := (cAlias)->FIL_MOEDA
			aTail(oResponse["bancos"])["tipoConta"]  := (cAlias)->FIL_TIPCTA
			aTail(oResponse["bancos"])["permiteCc"]  := (cAlias)->FIL_MOVCTO
			(cAlias)->(dbSkip())
		EndDo

		(cAlias)->(dbCloseArea())
		aSize(aParams, 0)
		aParams := Nil
	EndIf

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := Nil
	oFIL      := Nil

return lRet
