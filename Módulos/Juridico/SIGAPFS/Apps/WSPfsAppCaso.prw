#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "WSPFSAPPCASO.CH"

WSRESTFUL WSPfsAppCaso DESCRIPTION STR0001 // "Webservice App PFS - Casos"
	WSDATA valorDig         AS STRING
	WSDATA filtraFilial     AS BOOLEAN
	WSDATA filtraContratos  AS BOOLEAN
	WSDATA page             AS NUMBER
	WSDATA pageSize         AS NUMBER
	WSDATA count            AS BOOLEAN
	WSDATA idIndicador      AS STRING
	WSDATA chaveCaso        AS STRING
	WSDATA entidade         AS STRING
	WSDATA filialAnexo      AS STRING
	WSDATA filtercpo        AS STRING
	WSDATA filterinfo       AS STRING

	WSDATA codigoCliente    AS STRING
	WSDATA lojaCliente      AS STRING
	WSDATA codigoCaso       AS STRING
	WSDATA valorLimite      AS STRING
	WSDATA valorUtilizado   AS STRING
	WSDATA moedaLimite      AS BOOLEAN
	

	// Métodos GET
	WSMETHOD GET GrdCaso            DESCRIPTION STR0002 PATH "grid"                        WSSYNTAX "grid"                        PRODUCES APPLICATION_JSON // "Retorna dados de Grid de Casos"
	WSMETHOD GET GetContratos       DESCRIPTION STR0003 PATH "contratos/{chaveCaso}"       WSSYNTAX "contratos/{chaveCaso}"       PRODUCES APPLICATION_JSON // "Retorna dados da Grid de Contratos do Caso"
	WSMETHOD GET GetDetCaso         DESCRIPTION STR0004 PATH "detcaso/{chaveCaso}"         WSSYNTAX "detcaso/{chaveCaso}"         PRODUCES APPLICATION_JSON // "Retorna o detalhe do caso"
	WSMETHOD GET GrdHstCaso         DESCRIPTION STR0005 PATH "histcaso/{chaveCaso}"        WSSYNTAX "histcaso/{chaveCaso}"        PRODUCES APPLICATION_JSON // "Retorna dados da Grid de Histórioco do Caso"
	WSMETHOD GET GrdCabParticipacao DESCRIPTION STR0006 PATH "cabpartcas/{chaveCaso}"      WSSYNTAX "cabparticip/{chaveCaso}"     PRODUCES APPLICATION_JSON // "Retorna dados da Grid de Participação do Caso (NUK)"
	WSMETHOD GET GrdHisPartCaso     DESCRIPTION STR0007 PATH "histpartcas/{chaveCaso}"     WSSYNTAX "histpartcas/{chaveCaso}"     PRODUCES APPLICATION_JSON // "Retorna dados da Grid de Historico de Participação do Caso (NVF)"
	WSMETHOD GET GrdCondExitoCaso   DESCRIPTION STR0008 PATH "condexitocas/{chaveCaso}"    WSSYNTAX "condexitocas/{chaveCaso}"    PRODUCES APPLICATION_JSON // "Retorna dados da Grid de Condição de Êxito do Caso (NWL)"
	WSMETHOD GET GrdsSocRevDoCaso   DESCRIPTION STR0009 PATH "socrevdocaso/{chaveCaso}"    WSSYNTAX "socrevdocaso/{chaveCaso}"    PRODUCES APPLICATION_JSON // "Retorna dados da Grid de Sócios/Revisores do Caso (OHN)"
	WSMETHOD GET GExcTbHnCtg        DESCRIPTION STR0010 PATH "extbhoncateg/{chaveCaso}"    WSSYNTAX "extbhoncateg/{chaveCaso}"    PRODUCES APPLICATION_JSON // "Retorna dados das exceções nas tabelas de honorarios - Categoria (NUW)"
	WSMETHOD GET GetSaldoLimDisp    DESCRIPTION STR0011 PATH "sldlimdisp"                  WSSYNTAX "sldlimdisp"                  PRODUCES APPLICATION_JSON // "Retorna saldo disponível para o limite do caso"
	WSMETHOD GET GetHistRemanej     DESCRIPTION STR0012 PATH "histremanja/{chaveCaso}"     WSSYNTAX "histremanja/{chaveCaso}"     PRODUCES APPLICATION_JSON // "Retorna dados da tabela de Histórico Remanejamento Caso (NY1)"
	WSMETHOD GET GetTituloIdioma    DESCRIPTION STR0013 PATH "tituloporidioma/{chaveCaso}" WSSYNTAX "tituloporidioma/{chaveCaso}" PRODUCES APPLICATION_JSON // "Retorna dados da tabela de título do caso por idioma (NT7)"
	WSMETHOD GET GetExcTbHnPart     DESCRIPTION STR0015 PATH "extbhonpart/{chaveCaso}"     WSSYNTAX "extbhonpart/{chaveCaso}"     PRODUCES APPLICATION_JSON // "Retorna dados das tabelas de exceção nas tabelas de honorarios - Participantes (NV0)"
	WSMETHOD GET GetAtvExcTbHn      DESCRIPTION STR0016 PATH "extbhonativ/{chaveCaso}"     WSSYNTAX "extbhonativ/{chaveCaso}"     PRODUCES APPLICATION_JSON // "Retorna dados das tabelas de exceção nas tabelas de honorarios - Atividade (OHR)"
	WSMETHOD GET LsCaso             DESCRIPTION STR0050  PATH "listacaso"                   WSSYNTAX "listacaso"                   PRODUCES APPLICATION_JSON // "Retorna lista de casos"

	// Métodos POST
	WSMETHOD POST RevalorizarTS     DESCRIPTION STR0014 PATH "revalorizar"                 WSSYNTAX "revalorizar"                 PRODUCES APPLICATION_JSON // "Revaloriza os time sheets do caso"
	WSMETHOD POST RemanejarCaso     DESCRIPTION STR0017 PATH "remanejar"                   WSSYNTAX "remanejar"                   PRODUCES APPLICATION_JSON // "Realiza o remanejamento dos casos"
	WSMETHOD POST GetValNUWNV0      DESCRIPTION STR0016 PATH "getValNUWNV0/{chaveCaso}"    WSSYNTAX "getValNUWNV0/{chaveCaso}"    PRODUCES APPLICATION_JSON // "Retorna os valores originais e ajustados das tabelas NUW e NV0"
	WSMETHOD POST NUTLt             DESCRIPTION STR0044 PATH "vinccontrlot"                WSSYNTAX "vinccontrlot"                PRODUCES APPLICATION_JSON // "Vincular lote de casos em contratos"


END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} GET GrdCaso
Consulta de Grid de Casos

@example GET -> http://127.0.0.1:9090/rest/WSPfsAppCaso/grid

@param valorDig        - Valor digitado no campo
@param filtraFilial    - Indica se filtra Filial com xFilial
@param filtraContratos - Indica se filtra os contratos do caso
@param page            - Numero da página
@param pagesize        - Quantidade de itens na página
@param count           - Indica se retorna a quantidade de clientes ao invés da lista de clientes
@param idIndicador     - Indica o tipo de filtro que será feito, conforme o indicador
                         1 - Casos em andamento
                         2 - Novos casos no mês
                         3 - Casos efetivados no mês
                         4 - Casos encerrados no mês
                         5 - Casos provisórios
                         6 - Casos encerrados com lançamentos pendentes
                         7 - Casos sem vínculo com contrato
                         8 - Casos com Time Sheet sem contrato que cobre hora (Em construção)
                         9 - Casos com Despesa sem contrato que cobre despesa (Em construção)
                         A - Casos com Tabelado sem contrato que cobre tabelado (Em construção)
                         B - Casos Remanejados

@author Jorge Martins
@since  13/10/2023
/*/
//-------------------------------------------------------------------
WSMETHOD GET GrdCaso QUERYPARAM valorDig, filtraFilial, filtraContratos, page, pageSize, count, idIndicador WSREST WSPfsAppCaso
Local oResponse  := JSonObject():New()
Local oCaso      := Nil
Local aArea      := GetArea()
Local lLojaAuto  := SuperGetMv("MV_JLOJAUT", .F., "2",) == '1' // Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local aFiliais   := UsrFilial()
Local cSearchKey := Self:valorDig
Local lFiltFil   := Self:filtraFilial
Local lFiltCont  := Self:filtraContratos
Local nPage      := Self:page
Local nPageSize  := Self:pageSize
Local lCount     := Self:count
Local cIdInd     := Self:idIndicador
Local cAliasCaso := ""
Local cQuery     := ""
Local cFilSA1    := ""
Local nIndexJSon := 0
Local nQtdRegFim := 0
Local nQtdRegIni := 0
Local nQtdReg    := 0
Local nIndFilSA1 := 0
Local nParam     := 0
Local aQuery     := {}
Local aParams    := {}
Local lHasNext   := .F.

Default nPage      := 1
Default nPageSize  := 10
Default lFiltFil   := .F.
Default lFiltCont  := .T.
Default lCount     := .F.
Default cIdInd     := ""

	If ValType(nPageSize) == "C"
		nPageSize := Val(nPageSize)
	EndIf

	If ValType(nPage) == "C"
		nPage := Val(nPage)
	EndIf

	nQtdRegIni := ((nPage) * nPageSize) - nPageSize
	nQtdRegFim := (nPage * nPageSize)

	// Monta a Query
	aQuery    := JQryCaso(cSearchKey, lFiltFil, .T., lCount, cIdInd)
	cQuery    := ChangeQuery(aQuery[1])
	aParams   := aQuery[2]
	cAliasCaso := GetNextAlias()
	
	oCaso := FWPreparedStatement():New(cQuery)
	
	For nParam := 1 To Len(aParams)
		If ValType(aParams[nParam]) == "C"
			oCaso:SetString(nParam, aParams[nParam])
		EndIf
	Next

	cQuery := oCaso:GetFixQuery()

	MpSysOpenQuery(cQuery, cAliasCaso)
	
	If lCount 
		If !(cAliasCaso)->(Eof())
			oResponse['total'] := (cAliasCaso)->QTD_CASOS
			oResponse['exibemes'] := IIf(cIdInd $ "2|3|4", "true", "false") // Indica se aparece o mês no indicador
		EndIf

	Else
		oResponse['caso'] := {}

		// Monta o response
		While !(cAliasCaso)->(Eof()) .And. nQtdReg < nQtdRegFim + 1
			nQtdReg++
			// Verifica se o registro está no range da pagina
			If (nQtdReg > nQtdRegIni .AND. nQtdReg <= nQtdRegFim)
				nIndexJSon++
				nIndFilSA1 := aScan(aFiliais, {|x| AllTrim((cAliasCaso)->A1_FILIAL) $ x['filial'] })
				cFilSA1    := IIf(nIndFilSA1 == 0, cFilAnt, aFiliais[nIndFilSA1]['filial'])

				Aadd(oResponse['caso'], JsonObject():New())
				oResponse['caso'][nIndexJSon]['filialDoRegistro']  := JConvUTF8((cAliasCaso)->NVE_FILIAL)
				oResponse['caso'][nIndexJSon]['chave']             := Encode64((cAliasCaso)->(NVE_FILIAL) + (cAliasCaso)->NVE_CCLIEN + (cAliasCaso)->NVE_LCLIEN + (cAliasCaso)->NVE_NUMCAS)
				oResponse['caso'][nIndexJSon]['filialCliente']     := JConvUTF8(cFilSA1)
				oResponse['caso'][nIndexJSon]['codigoCliente']     := JConvUTF8((cAliasCaso)->NVE_CCLIEN)
				If !lLojaAuto
					oResponse['caso'][nIndexJSon]['codigoCliente'] := oResponse['caso'][nIndexJSon]['codigoCliente'] + "/" + (cAliasCaso)->NVE_LCLIEN
				EndIf
				oResponse['caso'][nIndexJSon]['nomeCliente']       := JConvUTF8((cAliasCaso)->(A1_NOME))
				oResponse['caso'][nIndexJSon]['numeroCaso']        := JConvUTF8((cAliasCaso)->(NVE_NUMCAS))
				oResponse['caso'][nIndexJSon]['tituloCaso']        := JConvUTF8((cAliasCaso)->(NVE_TITULO))
				oResponse['caso'][nIndexJSon]['codigoSocio']       := JConvUTF8((cAliasCaso)->(CODIGOSOC))
				oResponse['caso'][nIndexJSon]['siglaSocio']        := JConvUTF8((cAliasCaso)->(SIGLASOC))
				oResponse['caso'][nIndexJSon]['nomeSocio']         := JConvUTF8((cAliasCaso)->(NOMESOC))
				oResponse['caso'][nIndexJSon]['codigoRevisor']     := JConvUTF8((cAliasCaso)->(CODIGOREV))
				oResponse['caso'][nIndexJSon]['siglaRevisor']      := JConvUTF8((cAliasCaso)->(SIGLAREV))
				oResponse['caso'][nIndexJSon]['nomeRevisor']       := JConvUTF8((cAliasCaso)->(NOMEREV))
				oResponse['caso'][nIndexJSon]['situacao']          := JConvUTF8((cAliasCaso)->(NVE_SITUAC))

				If lFiltCont
					oResponse['caso'][nIndexJSon]['contratos']     := JGetContr((cAliasCaso)->(NVE_FILIAL), (cAliasCaso)->NVE_CCLIEN, (cAliasCaso)->NVE_LCLIEN, (cAliasCaso)->NVE_NUMCAS)
				EndIf

				// Informações de Remanejamento
				oResponse['caso'][nIndexJSon]["clienteCasoNovo"]   := JConvUTF8((cAliasCaso)->(NVE_CCLINV)+(cAliasCaso)->(NVE_CLJNV)+(cAliasCaso)->(NVE_CCASNV))
				oResponse['caso'][nIndexJSon]["clienteCasoAntigo"] := JConvUTF8((cAliasCaso)->(NVE_CCLIAN)+(cAliasCaso)->(NVE_CLOJAN)+(cAliasCaso)->(NVE_CCASAN))

				//Informação documento ebiling para remanejamento
				oResponse['caso'][nIndexJSon]["codDocEbil"] := JConvUTF8(JurGetDados("NRX", 1, xFilial("NRX") + (cAliasCaso)->NUH_CEMP, "NRX_CDOC"))

			ElseIf (nQtdReg == nQtdRegFim + 1)
				lHasNext := .T.
			EndIf
			(cAliasCaso)->(dbSkip())
		EndDo

		// Verifica se há uma proxima pagina
		oResponse['hasNext'] := lHasNext
	EndIf

	// Limpa o objeto FWPreparedStatement
	oCaso:Destroy()

	(cAliasCaso)->(dbCloseArea())
	Self:SetResponse( FWJsonSerialize(oResponse, .F., .F., .T.) )
	oResponse:fromJson("{}")
	oResponse := NIL

	JurFreeArr(@aQuery)
	JurFreeArr(@aParams)

	RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JQryCaso
Monta a query de Casos

@param cSearchKey  - Valor digitado no campo
@param lFiltFil    - Indica se irá filtrar pela filial logada
@param lFilAdc     - Indica se terá o filtro adicional (sócio resp/cnpj/nomefantasia)
@param lCount      - Indica se a query vai apenas trazer a quantidade de registros
@param cIdInd      - Indica o tipo de filtro que será feito, conforme o indicador
                     1 - Casos em andamento
                     2 - Novos casos no mês
                     3 - Casos efetivados no mês
                     4 - Casos encerrados no mês
                     5 - Casos provisórios
                     6 - Casos encerrados com lançamentos pendentes (Em construção)
                     7 - Casos sem vínculo com contrato (Em construção)
                     8 - Casos com Time Sheet sem contrato que cobre hora (Em construção)
                     9 - Casos com Despesa sem contrato que cobre despesa (Em construção)
                     A - Casos com Tabelado sem contrato que cobre tabelado (Em construção)
                     B - Casos Remanejados

@return {cQuery, aParams} - cQuery - Query de busca dos casos
                            aParams - Parâmetros para o FWPreparedStatement

@author Jorge Martins
@since  13/10/2023
/*/
//-------------------------------------------------------------------
Static Function JQryCaso(cSearchKey, lFiltFil, lFilAdc, lCount, cIdInd)
Local cQuery      := ""
Local cQrySel     := ""
Local cQryFrm     := ""
Local cQryWhr     := ""
Local cQryOrd     := ""
Local nI          := 0
Local nQtd        := 0
Local aParams     := {}
Local cTpDtBase   := AllTrim(Upper(TCGetDB())) // Tipo de database do sistema

Default cLoja     := ""
Default cIdInd    := ""
Default lFiltFil  := .F.
Default lFilAdc   := .F.
Default lCount    := .F.

	If lCount
		cQrySel += " SELECT COUNT(NVE.R_E_C_N_O_) QTD_CASOS"
	Else
		cQrySel += " SELECT NVE.NVE_CCLIEN,"
		cQrySel +=        " NVE.NVE_LCLIEN,"
		cQrySel +=        " SA1.A1_NOME,"
		cQrySel +=        " NUH.NUH_CEMP,"
		cQrySel +=        " NVE.NVE_NUMCAS,"
		cQrySel +=        " NVE.NVE_TITULO,"
		cQrySel +=        " COALESCE(RD0SOC.RD0_CODIGO, ' ') CODIGOSOC,"
		cQrySel +=        " COALESCE(RD0SOC.RD0_SIGLA, ' ') SIGLASOC,"
		cQrySel +=        " COALESCE(RD0SOC.RD0_NOME, ' ') NOMESOC,"
		cQrySel +=        " RD0REV.RD0_CODIGO CODIGOREV,"
		cQrySel +=        " RD0REV.RD0_SIGLA SIGLAREV,"
		cQrySel +=        " RD0REV.RD0_NOME NOMEREV,"
		cQrySel +=        " NVE.NVE_SITUAC,"
		cQrySel +=        " NVE.NVE_FILIAL,"
		cQrySel +=        " SA1.A1_FILIAL,"
		cQrySel +=        " NVE.NVE_CCLINV,"
		cQrySel +=        " NVE.NVE_CLJNV,"
		cQrySel +=        " NVE.NVE_CCASNV,"
		cQrySel +=        " NVE.NVE_CCLIAN,"
		cQrySel +=        " NVE.NVE_CLOJAN,"
		cQrySel +=        " NVE.NVE_CCASAN"
	EndIf
	cQryFrm +=   " FROM " + RetSqlName("NVE") + " NVE"
	cQryFrm +=  " INNER JOIN " + RetSqlName("SA1") + " SA1"
	cQryFrm +=     " ON (SA1.A1_COD = NVE.NVE_CCLIEN"
	cQryFrm +=    " AND SA1.A1_LOJA = NVE.NVE_LCLIEN"
	cQryFrm +=    " AND SA1.D_E_L_E_T_ = ' ')"
	cQryFrm +=  " INNER JOIN " + RetSqlName("NUH") + " NUH"
	cQryFrm +=     " ON (NUH.NUH_COD = SA1.A1_COD"
	cQryFrm +=    " AND NUH.NUH_LOJA = SA1.A1_LOJA"
	cQryFrm +=    " AND NUH.D_E_L_E_T_ = ' ')"
	cQryFrm +=   " LEFT JOIN " + RetSqlName("RD0") + " RD0SOC"
	cQryFrm +=     " ON (RD0SOC.RD0_CODIGO = NVE.NVE_CPART5"
	cQryFrm +=    " AND RD0SOC.RD0_FILIAL = ?" // xFilial("RD0")
	cQryFrm +=    " AND RD0SOC.D_E_L_E_T_ = ' ' )"
	cQryFrm +=  " INNER JOIN " + RetSqlName("RD0") + " RD0REV"
	cQryFrm +=     " ON (RD0REV.RD0_CODIGO = NVE.NVE_CPART1"
	cQryFrm +=    " AND RD0REV.RD0_FILIAL = ?" // xFilial("RD0")
	cQryFrm +=    " AND RD0REV.D_E_L_E_T_ = ' ' )"
	cQryWhr +=  " WHERE NVE.D_E_L_E_T_ = ' '"

	aAdd(aParams, xFilial("RD0"))
	aAdd(aParams, xFilial("RD0"))

	// Pesquisa por valor digitado
	If !Empty(cSearchKey)
		cSearchKey := Lower(StrTran(JurLmpCpo( cSearchKey,.F. ),'#',''))
		
		cQryWhr += " AND ( LOWER(NVE_CCLIEN) LIKE ?" // "%" + cSearchKey + "%"
		cQryWhr +=        " OR LOWER(NVE_LCLIEN) LIKE ?" // "%" + cSearchKey + "%"
		cQryWhr +=        " OR " + JurFormat("A1_NOME", .T.,.T.) + " LIKE ?" // "%" + cSearchKey + "%"

		If cTpDtBase == "ORACLE"
			cQryWhr +=    " OR " + JurFormat("NVE_CCLIEN||NVE_LCLIEN||NVE_NUMCAS", .T.,.T.) + " LIKE ?" // "%" + cSearchKey + "%"
		ElseIf cTpDtBase == "MSSQL"
			cQryWhr +=    " OR " + JurFormat("NVE_CCLIEN+NVE_LCLIEN+NVE_NUMCAS", .T.,.T.) + " LIKE ?" // "%" + cSearchKey + "%"
		EndIf

		nQtd := 4
		
		If lFilAdc
			cQryWhr +=    " OR " + JurFormat("A1_NREDUZ" , .T.,.T.          ) + " LIKE ?" // "%" + cSearchKey + "%"
			cQryWhr +=    " OR " + JurFormat("NVE_TITULO", .T.,.T.          ) + " LIKE ?" // "%" + cSearchKey + "%"
			cQryWhr +=    " OR " + JurFormat("NVE_NUMCAS", .T.,.T.          ) + " LIKE ?" // "%" + cSearchKey + "%"
			cQryWhr +=    " OR " + JurFormat("RD0_SIGLA" , .T.,.T., "RD0SOC") + " LIKE ?" // "%" + cSearchKey + "%"
			cQryWhr +=    " OR " + JurFormat("RD0_SIGLA" , .T.,.T., "RD0REV") + " LIKE ?" // "%" + cSearchKey + "%"
			cQryWhr +=    " OR " + JurFormat("RD0_NOME"  , .T.,.T., "RD0SOC") + " LIKE ?" // "%" + cSearchKey + "%"
			cQryWhr +=    " OR " + JurFormat("RD0_NOME"  , .T.,.T., "RD0REV") + " LIKE ?" // "%" + cSearchKey + "%"

			nQtd += 7
		EndIf

		For nI := 1 To nQtd
			aAdd(aParams, "%" + cSearchKey + "%")
		Next

		cQryWhr += ")"
	EndIf

	// Filtro conforme o indicador
	If !Empty(cIdInd)
		cQryWhr += JQryInd(cIdInd, @aParams)
	EndIf

	If !lCount // Pro count não precisa fazer ORDER BY
		cQryOrd +=  " ORDER BY SA1.A1_NOME, NVE.NVE_TITULO"
	EndIf

	cQuery := cQrySel + cQryFrm + cQryWhr + cQryOrd

Return {cQuery, aParams}

//-------------------------------------------------------------------
/*/{Protheus.doc} JQryInd
Monta trecho de query para filtro dos indicadores

@param cIdInd  - Id do indicador
                 1 - Casos em andamento
                 2 - Novos casos no mês
                 3 - Casos efetivados no mês
                 4 - Casos encerrados no mês
                 5 - Casos provisórios
                 6 - Casos encerrados com lançamentos pendentes
                 7 - Casos sem vínculo com contrato
                 8 - Casos com Time Sheet sem contrato que cobre hora
                 9 - Casos com Despesa sem contrato que cobre despesa
                 A - Casos com Tabelado sem contrato que cobre tabelado
                 B - Casos Remanejados
@param aParams  - Array (passado por referência) de parâmetros de query 
                  (bind params) para montar o TcGenQry2

@return cQuery - Trecho de query do filtro dos indicadores

@author Jorge Martins
@since  12/12/2023
/*/
//-------------------------------------------------------------------
Static Function JQryInd(cIdInd, aParams)
Local cQuery := ""
Local cDtIni := DToS(FirstDay(Date())) // Primeiro dia do mês do período
Local cDtFim := DToS(LastDay(Date()))  // Último dia do mês do período

	If cIdInd == "1" // 1 - Casos em andamento
		cQuery += " AND (NVE.NVE_SITUAC = '1')"

	ElseIf cIdInd == "2" // 2 - Novos casos no mês
		cQuery += " AND (NVE.NVE_DTENTR BETWEEN ? AND ?)" // cDtIni e cDtFim
		aAdd(aParams, cDtIni)
		aAdd(aParams, cDtFim)

	ElseIf cIdInd == "3" // 3 - Casos efetivados no mês
		cQuery += " AND (NVE.NVE_SITCAD = '2' AND NVE.NVE_DTEFT BETWEEN ? AND ?)" // cDtIni e cDtFim
		aAdd(aParams, cDtIni)
		aAdd(aParams, cDtFim)

	ElseIf cIdInd == "4" // 4 - Casos encerrados no mês
		cQuery += " AND (NVE.NVE_SITUAC = '2' AND NVE.NVE_DTENCE BETWEEN ? AND ?)" // cDtIni e cDtFim
		aAdd(aParams, cDtIni)
		aAdd(aParams, cDtFim)

	ElseIf cIdInd == "5" // 5 - Casos provisórios
		cQuery += " AND (NVE.NVE_SITCAD = '1')"

	ElseIf cIdInd == "6" // 6 - Casos encerrados com lançamentos pendentes
		cQuery += " AND NVE.NVE_SITUAC = '2'"
		cQuery += " AND ("
		// TIME SHEET
		cQuery +=        " EXISTS (SELECT NUE.R_E_C_N_O_"
		cQuery +=                  " FROM " + RetSqlName("NUE") + " NUE"
		cQuery +=                 " WHERE NUE.NUE_FILIAL = ?" // xFilial("NUE")
		cQuery +=                   " AND NUE.NUE_SITUAC = '1'"
		cQuery +=                   " AND NUE.NUE_CCLIEN = NVE.NVE_CCLIEN"
		cQuery +=                   " AND NUE.NUE_CLOJA = NVE.NVE_LCLIEN"
		cQuery +=                   " AND NUE.NUE_CCASO = NVE.NVE_NUMCAS"
		cQuery +=                   " AND NUE.D_E_L_E_T_ = ' ')"
		cQuery +=        " OR"
		// DESPESAS
		cQuery +=        " EXISTS (SELECT NVY.R_E_C_N_O_"
		cQuery +=                  " FROM " + RetSqlName("NVY") + " NVY"
		cQuery +=                 " WHERE NVY.NVY_FILIAL = ?" // xFilial("NVY")
		cQuery +=                   " AND NVY.NVY_SITUAC = '1'"
		cQuery +=                   " AND NVY.NVY_CCLIEN = NVE.NVE_CCLIEN"
		cQuery +=                   " AND NVY.NVY_CLOJA = NVE.NVE_LCLIEN"
		cQuery +=                   " AND NVY.NVY_CCASO = NVE.NVE_NUMCAS"
		cQuery +=                   " AND NVY.D_E_L_E_T_ = ' ')"
		cQuery +=        " OR"
		// LANÇAMENTO TABELADO
		cQuery +=        " EXISTS (SELECT NV4.R_E_C_N_O_"
		cQuery +=                  " FROM " + RetSqlName("NV4") + " NV4"
		cQuery +=                 " WHERE NV4.NV4_FILIAL = ?" // xFilial("NV4")
		cQuery +=                   " AND NV4.NV4_SITUAC = '1'"
		cQuery +=                   " AND NV4.NV4_CCLIEN = NVE.NVE_CCLIEN"
		cQuery +=                   " AND NV4.NV4_CLOJA = NVE.NVE_LCLIEN"
		cQuery +=                   " AND NV4.NV4_CCASO = NVE.NVE_NUMCAS"
		cQuery +=                   " AND D_E_L_E_T_ = ' ')"
		cQuery +=        " OR"
		// FATURA ADICIONAL
		cQuery +=        " EXISTS (SELECT NVW.R_E_C_N_O_"
		cQuery +=                  " FROM " + RetSqlName("NVW") + " NVW"
		cQuery +=                 " INNER JOIN " + RetSqlName("NVV") + " NVV"
		cQuery +=                    " ON NVV.NVV_FILIAL = NVW.NVW_FILIAL"
		cQuery +=                   " AND NVV.NVV_COD = NVW.NVW_CODFAD"
		cQuery +=                   " AND NVV.NVV_SITUAC = '1'"
		cQuery +=                   " AND NVV.D_E_L_E_T_ = ' '"
		cQuery +=                 " WHERE NVW.NVW_FILIAL = ?" // xFilial("NVW")
		cQuery +=                   " AND NVW.NVW_CCLIEN = NVE.NVE_CCLIEN"
		cQuery +=                   " AND NVW.NVW_CLOJA = NVE.NVE_LCLIEN"
		cQuery +=                   " AND NVW.NVW_CCASO = NVE.NVE_NUMCAS"
		cQuery +=                   " AND NVW.D_E_L_E_T_ = ' ')"
		cQuery +=        " OR"
		// FIXO
		cQuery +=        " EXISTS (SELECT NUT.R_E_C_N_O_"
		cQuery +=                  " FROM " + RetSqlName("NUT") + " NUT"
		cQuery +=                 " INNER JOIN " + RetSqlName("NT1") + " NT1"
		cQuery +=                    " ON NT1.NT1_FILIAL = NUT.NUT_FILIAL"
		cQuery +=                   " AND NT1.NT1_CCONTR = NUT.NUT_CCONTR"
		cQuery +=                   " AND NT1.NT1_SITUAC = '1'"
		cQuery +=                   " AND NT1.D_E_L_E_T_ = ' '"
		cQuery +=                 " WHERE NUT.NUT_FILIAL = ?" // xFilial("NUT")
		cQuery +=                   " AND NUT.NUT_CCLIEN = NVE.NVE_CCLIEN"
		cQuery +=                   " AND NUT.NUT_CLOJA = NVE.NVE_LCLIEN"
		cQuery +=                   " AND NUT.NUT_CCASO = NVE.NVE_NUMCAS"
		cQuery +=                   " AND NUT.D_E_L_E_T_ = ' ')"
		cQuery += " )"

		aAdd(aParams, xFilial("NUE"))
		aAdd(aParams, xFilial("NVY"))
		aAdd(aParams, xFilial("NV4"))
		aAdd(aParams, xFilial("NVW"))
		aAdd(aParams, xFilial("NUT"))

	ElseIf cIdInd == "7" // 7 - Casos sem vínculo com contrato
		cQuery += " AND NOT EXISTS (SELECT NUT.R_E_C_N_O_ "
		cQuery +=                   " FROM " + RetSqlName("NUT") + " NUT"
		cQuery +=                  " WHERE NUT.D_E_L_E_T_ = ' '"
		cQuery +=                    " AND NUT.NUT_FILIAL = ?" // xFilial("NUT")
		cQuery +=                    " AND NUT.NUT_CCLIEN = NVE.NVE_CCLIEN"
		cQuery +=                    " AND NUT.NUT_CLOJA  = NVE.NVE_LCLIEN"
		cQuery +=                    " AND NUT.NUT_CCASO  = NVE.NVE_NUMCAS)"

		aAdd(aParams, xFilial("NUT"))

	ElseIf cIdInd == "8" // 8 - Casos com Time Sheet sem contrato que cobre hora

		cQuery += " AND EXISTS (SELECT NUE.R_E_C_N_O_ "
		cQuery +=               " FROM " + RetSqlName("NUE") + " NUE"
		cQuery +=              " WHERE NUE.NUE_FILIAL = ?" // xFilial("NUE")
		cQuery +=               "  AND NUE.D_E_L_E_T_ = ' '"
		cQuery +=               "  AND NUE.NUE_CCLIEN = NVE.NVE_CCLIEN"
		cQuery +=               "  AND NUE.NUE_CLOJA  = NVE.NVE_LCLIEN"
		cQuery +=               "  AND NUE.NUE_CCASO  = NVE.NVE_NUMCAS)"
		
		cQuery += " AND NOT EXISTS (SELECT NUT.R_E_C_N_O_ "
		cQuery +=                   " FROM " + RetSqlName("NUT") + " NUT"
		cQuery +=                  " INNER JOIN " + RetSqlName("NT0") + " NT0"
		cQuery +=                     " ON NT0.NT0_FILIAL = NUT.NUT_FILIAL"
		cQuery +=                    " AND NT0.NT0_COD = NUT.NUT_CCONTR"
		cQuery +=                    " AND NT0.NT0_ATIVO = '1'"
		cQuery +=                    " AND NT0.NT0_SIT   = '2'"
		cQuery +=                    " AND NT0.D_E_L_E_T_ = ' '"
		cQuery +=                  " INNER JOIN " + RetSqlName("NRA") + " NRA"
		cQuery +=                     " ON NRA.NRA_FILIAL = NT0.NT0_FILIAL"
		cQuery +=                    " AND NRA.NRA_COD = NT0.NT0_CTPHON"
		cQuery +=                    " AND NRA.NRA_COBRAH = '1'"
		cQuery +=                    " AND NRA.D_E_L_E_T_ = ' '"
		cQuery +=                  " WHERE NUT.NUT_FILIAL = ?" // xFilial("NUT")
		cQuery +=                    " AND NUT.NUT_CCLIEN = NVE.NVE_CCLIEN"
		cQuery +=                    " AND NUT.NUT_CLOJA  = NVE.NVE_LCLIEN"
		cQuery +=                    " AND NUT.NUT_CCASO  = NVE.NVE_NUMCAS"
		cQuery +=                    " AND NUT.D_E_L_E_T_ = ' ')"
		
		aAdd(aParams, xFilial("NUE"))
		aAdd(aParams, xFilial("NUT"))

	ElseIf cIdInd == "9" // 9 - Casos com Despesa sem contrato que cobre hora

		cQuery += " AND EXISTS (SELECT NVY.R_E_C_N_O_ "
		cQuery +=               " FROM " + RetSqlName("NVY") + " NVY"
		cQuery +=              " WHERE NVY.NVY_FILIAL = ?" // xFilial("NVY")
		cQuery +=                " AND NVY.D_E_L_E_T_ = ' '"
		cQuery +=                " AND NVY.NVY_CCLIEN = NVE.NVE_CCLIEN"
		cQuery +=                " AND NVY.NVY_CLOJA  = NVE.NVE_LCLIEN"
		cQuery +=                " AND NVY.NVY_CCASO  = NVE.NVE_NUMCAS)"

		cQuery += " AND NOT EXISTS (SELECT NUT.R_E_C_N_O_ "
		cQuery +=                   " FROM " + RetSqlName("NUT") + " NUT"
		cQuery +=                  " INNER JOIN " + RetSqlName("NT0") + " NT0"
		cQuery +=                     " ON NT0.NT0_FILIAL = NUT.NUT_FILIAL"
		cQuery +=                    " AND NT0.NT0_COD = NUT.NUT_CCONTR"
		cQuery +=                    " AND NT0.NT0_ATIVO = '1'"
		cQuery +=                    " AND NT0.NT0_SIT   = '2'"
		cQuery +=                    " AND NT0.NT0_DESPES = '1'"
		cQuery +=                    " AND NT0.D_E_L_E_T_ = ' '"
		cQuery +=                  " WHERE NUT.NUT_FILIAL = ?" // xFilial("NUT")
		cQuery +=                    " AND NUT.NUT_CCLIEN = NVE.NVE_CCLIEN"
		cQuery +=                    " AND NUT.NUT_CLOJA  = NVE.NVE_LCLIEN"
		cQuery +=                    " AND NUT.NUT_CCASO  = NVE.NVE_NUMCAS"
		cQuery +=                    " AND NUT.D_E_L_E_T_ = ' ')"

		aAdd(aParams, xFilial("NVY"))
		aAdd(aParams, xFilial("NUT"))

	ElseIf cIdInd == "A" // A - Casos com Tabelado sem contrato que cobre hora

		cQuery += " AND EXISTS ( SELECT NV4.R_E_C_N_O_ "
		cQuery +=                " FROM " + RetSqlName("NV4") + " NV4"
		cQuery +=               " WHERE NV4.NV4_FILIAL = ?" // xFilial("NV4")
		cQuery +=                 " AND NV4.D_E_L_E_T_ = ' '"
		cQuery +=                 " AND NV4.NV4_CCLIEN = NVE.NVE_CCLIEN"
		cQuery +=                 " AND NV4.NV4_CLOJA  = NVE.NVE_LCLIEN"
		cQuery +=                 " AND NV4.NV4_CCASO  = NVE.NVE_NUMCAS)"

		cQuery += " AND NOT EXISTS (SELECT NUT.R_E_C_N_O_ "
		cQuery +=                   " FROM " + RetSqlName("NUT") + " NUT"
		cQuery +=                  " INNER JOIN " + RetSqlName("NT0") + " NT0"
		cQuery +=                     " ON NT0.NT0_FILIAL = NUT.NUT_FILIAL"
		cQuery +=                    " AND NT0.NT0_COD = NUT.NUT_CCONTR"
		cQuery +=                    " AND NT0.NT0_ATIVO = '1'"
		cQuery +=                    " AND NT0.NT0_SIT   = '2'"
		cQuery +=                    " AND NT0.NT0_SERTAB = '1'"
		cQuery +=                    " AND NT0.D_E_L_E_T_ = ' '"
		cQuery +=                  " WHERE NUT.NUT_FILIAL = ?" // xFilial("NUT")
		cQuery +=                    " AND NUT.NUT_CCLIEN = NVE.NVE_CCLIEN"
		cQuery +=                    " AND NUT.NUT_CLOJA  = NVE.NVE_LCLIEN"
		cQuery +=                    " AND NUT.NUT_CCASO  = NVE.NVE_NUMCAS"
		cQuery +=                    " AND NUT.D_E_L_E_T_ = ' ')"

		aAdd(aParams, xFilial("NV4"))
		aAdd(aParams, xFilial("NUT"))

	ElseIf cIdInd == "B" // B - Casos Remanejados
		cQuery += " AND (NVE.NVE_REVISA = '2' AND (NVE.NVE_CCASNV <> ' ' OR NVE.NVE_CCASAN  <> ' '))"
	EndIf

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} GET GrdContratos
Consulta de Contratos do Caso

@example GET -> http://127.0.0.1:9090/rest/WSPfsAppCaso/contratos/{chaveCaso}
@param chaveCaso - Chave do Caso (Filial + Cliente + Loja + Caso)

@author Jorge Martins
@since  13/10/2023
/*/
//-------------------------------------------------------------------
WSMethod GET GetContratos PATHPARAM chaveCaso WSREST WSPfsAppCaso
Local oResponse  := JSonObject():New()
Local cChaveCaso := Decode64(Self:chaveCaso)
Local nTamFilial := TamSX3("NVE_FILIAL")[1]
Local nTamCodCli := TamSX3("NVE_CCLIEN")[1]
Local nTamCodLoj := TamSX3("NVE_LCLIEN")[1]
Local nTamCodCas := TamSX3("NVE_NUMCAS")[1]
Local cFilCaso   := Substr(cChaveCaso, 1, nTamFilial)
Local cCliente   := Substr(cChaveCaso, nTamFilial + 1, nTamCodCli)
Local cLoja      := Substr(cChaveCaso, nTamFilial + nTamCodCli + 1, nTamCodLoj)
Local cCaso      := Substr(cChaveCaso, nTamFilial + nTamCodCli + nTamCodLoj + 1, nTamCodCas)

	oResponse := {}
	Aadd(oResponse, JsonObject():New())

	oResponse := JGetContr(cFilCaso, cCliente, cLoja, cCaso)

	Self:SetResponse( FWJsonSerialize(oResponse, .F., .F., .T.) )
	oResponse := Nil

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JGetContr
Consulta de Contratos do Caso (Usado no complemento do Browse)

@param cFilCaso  - Filial do Caso
@param cCliente  - Código do Cliente
@param cLoja     - Loja do Cliente
@param cCaso     - Número do Caso

@return aContratos - Array com as informações dos contratos do caso

@author Jorge Martins
@since  13/10/2023
/*/
//-------------------------------------------------------------------
Static Function JGetContr(cFilCaso, cCliente, cLoja, cCaso)
Local aContratos := {}
Local cQuery     := ""
Local cAliasQry  := ""
Local nIndJson   := 0

	cFilCaso := Padr(cFilCaso, TamSx3("NVE_FILIAL")[1])
	cCliente := Padr(cCliente, TamSx3("NVE_CCLIEN")[1])
	cLoja    := Padr(cLoja   , TamSx3("NVE_LCLIEN")[1])
	cCaso    := Padr(cCaso   , TamSx3("NVE_NUMCAS")[1])

	cQuery := " SELECT NT0.NT0_FILIAL,"
	cQuery +=        " NT0.NT0_COD,"
	cQuery +=        " NT0.NT0_NOME,"
	cQuery +=        " NT0.NT0_CPART1,"
	cQuery +=        " RD0.RD0_SIGLA,"
	cQuery +=        " RD0.RD0_NOME,"
	cQuery +=        " NT0.NT0_CTPHON,"
	cQuery +=        " NT0.NT0_DESPES,"
	cQuery +=        " NT0.NT0_SERTAB,"
	cQuery +=        " NRA.NRA_DESC,"
	cQuery +=        " NRA.NRA_COBRAH,"
	cQuery +=        " NT0.NT0_ATIVO,"
	cQuery +=        " NUT.NUT_CCLIEN,"
	cQuery +=        " NUT.NUT_CLOJA,"
	cQuery +=        " NUT.NUT_CCASO"
	cQuery +=   " FROM " + RetSqlName("NUT") + " NUT"
	cQuery +=  " INNER JOIN " + RetSqlName("NT0") + " NT0"
	cQuery +=     " ON (NT0.NT0_FILIAL = NUT.NUT_FILIAL"
	cQuery +=    " AND NT0.NT0_COD = NUT.NUT_CCONTR"
	cQuery +=    " AND NT0.D_E_L_E_T_ = ' ')"
	cQuery +=  " INNER JOIN " + RetSqlName("RD0") + " RD0"
	cQuery +=     " ON (RD0.RD0_CODIGO = NT0.NT0_CPART1"
	cQuery +=    " AND RD0.RD0_FILIAL = ?" // xFilial("RD0")
	cQuery +=    " AND RD0.D_E_L_E_T_ = ' ' )"
	cQuery +=  " INNER JOIN " + RetSqlName("NRA") + " NRA"
	cQuery +=     " ON NRA.NRA_FILIAL = ?" // xFilial("NRA")
	cQuery +=    " AND NRA.NRA_COD = NT0.NT0_CTPHON"
	cQuery +=    " AND NRA.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE NUT.NUT_FILIAL = ?" // cFilCaso
	cQuery +=    " AND NUT.NUT_CCLIEN = ?" // cCliente
	cQuery +=    " AND NUT.NUT_CLOJA  = ?" // cLoja
	cQuery +=    " AND NUT.NUT_CCASO  = ?" // cCaso
	cQuery +=    " AND NUT.D_E_L_E_T_ = ' '"

	cAliasQry := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TcGenQry2( ,, cQuery, {xFilial("RD0"), xFilial("NRA"), cFilCaso, cCliente, cLoja, cCaso} ) , cAliasQry, .T., .F. )

	While ((cAliasQry)->(!Eof()))
		nIndJson++
		aAdd(aContratos, JSonObject():New())

		aContratos[nIndJson]['chaveNUT']    := Encode64(xFilial("NUT") + NT0_COD + cCliente + cLoja + cCaso)
		aContratos[nIndJson]['chaveNT0']    := Encode64((cAliasQry)->(NT0_FILIAL) + (cAliasQry)->NT0_COD)
		aContratos[nIndJson]['codigo']      := JConvUTF8((cAliasQry)->NT0_COD)
		aContratos[nIndJson]['nome']        := JConvUTF8((cAliasQry)->NT0_NOME)
		aContratos[nIndJson]['codigoSocio'] := JConvUTF8((cAliasQry)->NT0_CPART1)
		aContratos[nIndJson]['siglaSocio']  := JConvUTF8((cAliasQry)->RD0_SIGLA)
		aContratos[nIndJson]['nomeSocio']   := JConvUTF8((cAliasQry)->RD0_NOME)
		aContratos[nIndJson]['codTpHon']    := JConvUTF8((cAliasQry)->NT0_CTPHON)
		aContratos[nIndJson]['descTpHon']   := JConvUTF8((cAliasQry)->NRA_DESC)
		aContratos[nIndJson]['cobHora']     := JConvUTF8((cAliasQry)->NRA_COBRAH)
		aContratos[nIndJson]['ativo']       := JConvUTF8((cAliasQry)->NT0_ATIVO)
		aContratos[nIndJson]['cobDespesa']  := JConvUTF8((cAliasQry)->NT0_DESPES)
		aContratos[nIndJson]['cobServTab']  := JConvUTF8((cAliasQry)->NT0_SERTAB)
		aContratos[nIndJson]['codCliente']  := JConvUTF8((cAliasQry)->NUT_CCLIEN)
		aContratos[nIndJson]['lojaCliente'] := JConvUTF8((cAliasQry)->NUT_CLOJA)
		aContratos[nIndJson]['codCaso']     := JConvUTF8((cAliasQry)->NUT_CCASO)
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())

Return aContratos

//-------------------------------------------------------------------
/*/{Protheus.doc} UsrFilial
Filial do usuário

@author Willian Kazahaya
@since  01/09/2023
/*/
//-------------------------------------------------------------------
Static Function UsrFilial()
Local aFiliais := FWLoadSM0()
Local aJson    := {}
Local nI       := 0

	For nI := 1 To Len(aFiliais)
		If aFiliais[nI][11] .And. aFiliais[nI][1] == cEmpAnt // Retorna as filiais que o usuário tem acesso da empresa logada.
			Aadd(aJson,JsonObject():new())
			nPos := Len(aJson)
			aJson[nPos]['empresa']   := aFiliais[nI][1]
			aJson[nPos]['filial']    := aFiliais[nI][2]
			aJson[nPos]['descricao'] := aFiliais[nI][7]
		EndIf
	Next nI

Return aJson

//-------------------------------------------------------------------
/*/{Protheus.doc} GET GetDetCaso
Busca as informações do caso.

@example GET -> http://127.0.0.1:9090/rest/WSPfsAppCaso/detcaso/{chaveCaso}

@author Victor Hayashi
@since  /10/2023
/*/
//-------------------------------------------------------------------
WSMETHOD GET GetDetCaso PATHPARAM chaveCaso QUERYPARAM WSREST WSPfsAppCaso
Local oResponse  := JSonObject():New() // Objto de Resposta da requisição
Local oCaso      := Nil // Objeto de query do caso
Local cChaveCaso := Decode64(Self:chaveCaso) // Chave do Caso (NVE_CCLIEN + NVE_LCLIEN + NVE_NUMCAS)
Local nTamFilial := TamSX3("NVE_FILIAL")[1] // Tamanho do campo Filial
Local nTamCodCli := TamSX3("A1_COD"    )[1] // Tamanho do campo Codigo Cliente
Local nTamCodLoj := TamSX3("A1_LOJA"   )[1] // Tamanho do campo Codigo Loja
Local nTamCodCas := TamSX3("NVE_NUMCAS")[1] // Tamanho do campo Numero do Caso
Local cFilCaso   := Substr(cChaveCaso, 1, nTamFilial) // Filial do Caso
Local cCliente   := Substr(cChaveCaso, nTamFilial + 1, nTamCodCli) // Codigo do Cliente do Caso
Local cLoja      := Substr(cChaveCaso, nTamFilial + nTamCodCli + 1, nTamCodLoj) // Codigo da loja do cliente
Local cCaso      := Substr(cChaveCaso, nTamFilial + nTamCodCli + nTamCodLoj + 1, nTamCodCas) // Numero do Caso
Local cQuery     := "" // Query para pegar as informações do caso
Local cAliasNVE  := GetNextAlias() // Alias para a query de casos
Local nParam     := 0 // contador para os parametros da query
Local lPrtDtEft  := Iif(ChkFile("NVE"), NVE->(ColumnPos("NVE_DTEFT")) > 0, .F.) // Proteção 12/05/2023
Local cObsCad    := ""
Local cObsFat    := ""
Local cObsRev    := ""
Local cDetEnc    := ""
Local cDetReab   := ""
Local lRet       := .T.
Local lPrsrvCas  := ( SuperGetMV('MV_JCASO1',, '1') == "2") .And. SuperGetMV('MV_JCASO3',, .F.) // .T./.F. = Preserva ou não o número do Caso de Origem quando for Independente de Cliente.

	// ----------- Query de Casos
	cQuery := " SELECT NVE.NVE_FILIAL,"
	cQuery +=        " NVE.NVE_CGRPCL,"
	cQuery +=        " NVE.NVE_CCLIEN,"
	cQuery +=        " NVE.NVE_LCLIEN,"
	cQuery +=        " SA1.A1_NOME,"
	cQuery +=        " NUH.NUH_UTEBIL," // Cliente Utiliza eBiling
	cQuery +=        " NVE.NVE_NUMCAS,"
	cQuery +=        " NVE.NVE_TITSUG,"
	cQuery +=        " NVE.NVE_TITULO,"
	cQuery +=        " NVE.NVE_CAREAJ,"
	cQuery +=        " NVE.NVE_CSUBAR,"
	cQuery +=        " NVE.NVE_CPART2," // Solicitante
	cQuery +=        " NVE.NVE_CPART5," // Socio
	If lPrtDtEft
		cQuery +=        " NVE.NVE_DTEFT,"
	EndIf
	cQuery +=        " NVE.NVE_SITCAD,"
	//------------- DADOS FATURAMENTO
	cQuery +=        " NVE.NVE_CESCRI,"
	cQuery +=        " NVE.NVE_CPART1," // Revisor
	cQuery +=        " NVE.NVE_CTABH,"
	cQuery +=        " NVE.NVE_CTABS,"
	cQuery +=        " NVE.NVE_CIDIO,"
	cQuery +=        " NVE.NVE_DESPAD,"
	cQuery +=        " NVE.NVE_COBRAV,"
	cQuery +=        " NVE.NVE_EXITO,"
	cQuery +=        " NVE.NVE_DSPDIS,"
	cQuery +=        " NVE.NVE_LANTS,"
	cQuery +=        " NVE.NVE_LANDSP,"
	cQuery +=        " NVE.NVE_LANTAB,"
	cQuery +=        " NVE.NVE_DBTPES,"
	cQuery +=        " NVE.NVE_CPTDBT," // Participante Debito Pessoal
	//------------- E - BILING
	cQuery +=        " NVE.NVE_TITEBI,"
	cQuery +=        " NVE.NVE_MATTER,"
	cQuery +=        " NVE.NVE_CPGEBI,"
	//------------- ENCERRAMENTO COBRANÇA
	cQuery +=        " NVE.NVE_ENCHON,"
	cQuery +=        " NVE.NVE_ENCDES,"
	cQuery +=        " NVE.NVE_ENCTAB,"
	//------------- Valor Hora
	cQuery +=        " NVE.NVE_TPHORA,"
	cQuery +=        " NVE.NVE_VLHORA,"
	cQuery +=        " NVE.NVE_CMOELI,"
	cQuery +=        " NVE.NVE_VLRLI,"
	cQuery +=        " NVE.NVE_SALDOI,"
	cQuery +=        " NVE.NVE_CTBCVL,"
	cQuery +=        " NVE.NVE_CFACVL,"
	//------------- Step Situação
	cQuery +=        " NVE.NVE_SITUAC,"
	cQuery +=        " NVE.NVE_DTENTR,"
	cQuery +=        " NVE.NVE_USUINC," // Usuario de Inclusão (Cod Protheus)
	cQuery +=        " NVE.NVE_DTENCE,"
	cQuery +=        " NVE.NVE_CPART3," // Participante do Encerramento
	cQuery +=        " NVE.NVE_DTREAB,"
	cQuery +=        " NVE.NVE_CPART4,"
	//------------- Step Remanejamento de Caso
	cQuery +=        " NVE.NVE_CCLINV,"
	cQuery +=        " NVE.NVE_CLJNV,"
	cQuery +=        " CLINOV.A1_NOME CLINOV,"
	cQuery +=        " NVE.NVE_CCASNV,"
	cQuery +=        " NVE.NVE_CCLIAN,"
	cQuery +=        " NVE.NVE_CLOJAN,"
	cQuery +=        " CLIANT.A1_NOME CLIANT,"
	cQuery +=        " NVE.NVE_CCASAN,"
	cQuery +=        " NVE.NVE_REVISA,"
	cQuery +=        " NVE.NVE_DTREVI,"
	cQuery +=        " NVE.NVE_CPARTR,"
	cQuery +=        " COALESCE(CPARTR.RD0_NOME, ' ') CPARTR_NOME,"
	cQuery +=        " COALESCE(CPARTR.RD0_SIGLA, ' ') CPARTR_SIGLA"
	cQuery +=   " FROM " + RetSqlName( 'NVE' ) + " NVE"
	cQuery +=  " INNER JOIN " + RetSqlName( 'SA1' ) + " SA1"
	cQuery +=     " ON SA1.A1_COD =  NVE.NVE_CCLIEN"
	cQuery +=    " AND SA1.A1_LOJA = NVE.NVE_LCLIEN"
	cQuery +=    " AND SA1.D_E_L_E_T_ = ' '"
	cQuery +=  " INNER JOIN " + RetSqlName( 'NUH' ) + " NUH"
	cQuery +=     " ON SA1.A1_COD = NUH.NUH_COD"
	cQuery +=    " AND SA1.A1_LOJA = NUH.NUH_LOJA"
	cQuery +=    " AND NUH.D_E_L_E_T_ = ' '"
	cQuery +=   " LEFT JOIN " + RetSqlName( 'RD0' ) + " CPARTR"
	cQuery +=     " ON CPARTR.RD0_FILIAL = ?"
	cQuery +=    " AND CPARTR.RD0_CODIGO = NVE_CPARTR"
	cQuery +=    " AND CPARTR.D_E_L_E_T_ = ' '"
	// Cliente Novo
	cQuery +=  " LEFT JOIN " + RetSqlName( 'SA1' ) + " CLINOV"
	cQuery +=     " ON CLINOV.A1_COD =  NVE.NVE_CCLINV"
	cQuery +=    " AND CLINOV.A1_LOJA = NVE.NVE_CLJNV"
	cQuery +=    " AND CLINOV.D_E_L_E_T_ = ' '"
	// Cliente Antigo
	cQuery +=  " LEFT JOIN " + RetSqlName( 'SA1' ) + " CLIANT"
	cQuery +=     " ON CLIANT.A1_COD =  NVE.NVE_CCLIAN"
	cQuery +=    " AND CLIANT.A1_LOJA = NVE.NVE_CLOJAN"
	cQuery +=    " AND CLIANT.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE NVE.NVE_FILIAL = ?"
	cQuery +=    " AND NVE.NVE_CCLIEN = ?"
	cQuery +=    " AND NVE.NVE_LCLIEN = ?"
	cQuery +=    " AND NVE.NVE_NUMCAS = ?"
	cQuery +=    " AND NVE.D_E_L_E_T_ = ' '"

	oCaso := FWPreparedStatement():New(cQuery)

	oCaso:SetString(++nParam, xFilial("RD0"))
	oCaso:SetString(++nParam, cFilCaso)
	oCaso:SetString(++nParam, cCliente)
	oCaso:SetString(++nParam, cLoja)
	oCaso:SetString(++nParam, cCaso)

	cQuery := oCaso:GetFixQuery()

	MpSysOpenQuery(cQuery, cAliasNVE)

	oResponse['caso'] := {}

	If (cAliasNVE)->(!Eof())
		// Criação do Objeto JSON
		aAdd(oResponse["caso"], JsonObject():New())

		// Obtenção das informações dos campos MEMO
		NVE->(DbSetOrder(1))
		If (NVE->(DbSeek((cAliasNVE)->(NVE_FILIAL) + (cAliasNVE)->(NVE_CCLIEN) + (cAliasNVE)->(NVE_LCLIEN) + (cAliasNVE)->(NVE_NUMCAS))))
			cObsCad  := NVE->NVE_OBSCAD
			cObsFat  := NVE->NVE_OBSFAT
			cObsRev  := NVE->NVE_OBSREV
			cDetEnc  := NVE->NVE_DETENC
 			cDetReab := NVE->NVE_DETREA
		EndIf

		// Chave do Registro
		oResponse["caso"][1]["chvCaso"]                  := JConvUTF8((cAliasNVE)->(NVE_FILIAL) + (cAliasNVE)->(NVE_CCLIEN) + (cAliasNVE)->(NVE_LCLIEN) + (cAliasNVE)->(NVE_NUMCAS))

		// Dados principais
		oResponse["caso"][1]["grupoClientes"]            := JConvUTF8((cAliasNVE)->(NVE_CGRPCL))
		oResponse["caso"][1]["clienteLoja"]              := JConvUTF8((cAliasNVE)->(NVE_CCLIEN) + " - " + (cAliasNVE)->(NVE_LCLIEN))
		oResponse["caso"][1]["cliente"]                  := JConvUTF8((cAliasNVE)->(NVE_CCLIEN))
		oResponse["caso"][1]["loja"]                     := JConvUTF8((cAliasNVE)->(NVE_LCLIEN))
		oResponse["caso"][1]["nomeCliente"]              := JConvUTF8((cAliasNVE)->(A1_NOME))
		oResponse["caso"][1]["usaEbiling"]               := JConvUTF8((cAliasNVE)->(NUH_UTEBIL))
		oResponse["caso"][1]["numero"]                   := JConvUTF8((cAliasNVE)->(NVE_NUMCAS))
		oResponse["caso"][1]["tituloSugerido"]           := JConvUTF8((cAliasNVE)->(NVE_TITSUG))
		oResponse["caso"][1]["titulo"]                   := JConvUTF8((cAliasNVE)->(NVE_TITULO))
		oResponse["caso"][1]["areaJuridica"]             := JConvUTF8((cAliasNVE)->(NVE_CAREAJ))
		oResponse["caso"][1]["subAreaJuridica"]          := JConvUTF8((cAliasNVE)->(NVE_CSUBAR))
		oResponse["caso"][1]["solicitante"]              := JConvUTF8((cAliasNVE)->(NVE_CPART2))
		oResponse["caso"][1]["socio"]                    := JConvUTF8((cAliasNVE)->(NVE_CPART5))
		oResponse["caso"][1]["observacaoCad"]            := JConvUTF8(cObsCad)
		If lPrtDtEft
			oResponse["caso"][1]["dataEfetivacao"]       := JConvUTF8((cAliasNVE)->(NVE_DTEFT))
		EndIf
		oResponse["caso"][1]["situacaoCadastro"]         := JConvUTF8((cAliasNVE)->(NVE_SITCAD))

		// Dados para faturamento
		oResponse["caso"][1]["escritorioFaturamento"]    := JConvUTF8((cAliasNVE)->(NVE_CESCRI)) // escritorio
		oResponse["caso"][1]["revisor"]                  := JConvUTF8((cAliasNVE)->(NVE_CPART1))
		oResponse["caso"][1]["tabelaHonorario"]          := JConvUTF8((cAliasNVE)->(NVE_CTABH )) // tabelaHonorarios
		oResponse["caso"][1]["tabelaServicos"]           := JConvUTF8((cAliasNVE)->(NVE_CTABS ))
		oResponse["caso"][1]["idiomaRelatorio"]          := JConvUTF8((cAliasNVE)->(NVE_CIDIO )) // idiomaLancamentos
		oResponse["caso"][1]["percentualDescontoLinear"] := JConvUTF8(cValToChar((cAliasNVE)->(NVE_DESPAD)))
		oResponse["caso"][1]["cobravel"]                 := JConvUTF8((cAliasNVE)->(NVE_COBRAV))
		oResponse["caso"][1]["cobraExito"]               := JConvUTF8((cAliasNVE)->(NVE_EXITO ))
		oResponse["caso"][1]["discriminaDespesas"]       := JConvUTF8((cAliasNVE)->(NVE_DSPDIS)) // detalhaDespesas
		oResponse["caso"][1]["permiteLancarTS"]          := JConvUTF8((cAliasNVE)->(NVE_LANTS ))
		oResponse["caso"][1]["permiteLancarDespesa"]     := JConvUTF8((cAliasNVE)->(NVE_LANDSP))
		oResponse["caso"][1]["permiteLancarTabelado"]    := JConvUTF8((cAliasNVE)->(NVE_LANTAB))
		oResponse["caso"][1]["debitoPessoal"]            := JConvUTF8((cAliasNVE)->(NVE_DBTPES))
		oResponse["caso"][1]["participante"]             := JConvUTF8((cAliasNVE)->(NVE_CPTDBT))
		oResponse["caso"][1]["observacaoFaturamento"]    := JConvUTF8(cObsFat)

		// E-biling
		oResponse["caso"][1]["tituloEbilling"]           := JConvUTF8((cAliasNVE)->(NVE_TITEBI))
		oResponse["caso"][1]["assunto"]                  := JConvUTF8((cAliasNVE)->(NVE_MATTER))
		oResponse["caso"][1]["clientePagador"]           := JConvUTF8((cAliasNVE)->(NVE_CPGEBI))

		// Encerramento de Cobrança
		oResponse["caso"][1]["encerraHonorarios"]        := JConvUTF8((cAliasNVE)->(NVE_ENCHON))
		oResponse["caso"][1]["encerraDespesas"]          := JConvUTF8((cAliasNVE)->(NVE_ENCDES))
		oResponse["caso"][1]["encerraTabelados"]         := JConvUTF8((cAliasNVE)->(NVE_ENCTAB))

		// Configuração de valor hora diferenciado e Limite do caso
		oResponse["caso"][1]["tipoHoraDiferenciada"]     := JConvUTF8((cAliasNVE)->(NVE_TPHORA))
		oResponse["caso"][1]["valorHora"]                := JConvUTF8(cValToChar((cAliasNVE)->(NVE_VLHORA)))
		oResponse["caso"][1]["moeda"]                    := JConvUTF8((cAliasNVE)->(NVE_CMOELI))
		oResponse["caso"][1]["valorLimite"]              := JConvUTF8(cValToChar((cAliasNVE)->(NVE_VLRLI )))
		oResponse["caso"][1]["valorUtilizado"]           := JConvUTF8(cValToChar((cAliasNVE)->(NVE_SALDOI)))
		oResponse["caso"][1]["saldoDisponivel"]          := JConvUTF8(cValToChar(J201GSldCs(cCliente, cLoja, cCaso, '2', .F.)))
		oResponse["caso"][1]["consideraTabelado"]        := JConvUTF8((cAliasNVE)->(NVE_CTBCVL))
		oResponse["caso"][1]["consideraFaturaAdicional"] := JConvUTF8((cAliasNVE)->(NVE_CFACVL))

		// Step - Situação
		oResponse["caso"][1]["situacao"]                 := JConvUTF8((cAliasNVE)->(NVE_SITUAC))
		oResponse["caso"][1]["usuarioInc"]               := JConvUTF8((cAliasNVE)->(NVE_USUINC))
		oResponse["caso"][1]["dataEntr"]                 := JConvUTF8((cAliasNVE)->(NVE_DTENTR))
		oResponse["caso"][1]["dataEnc"]                  := JConvUTF8((cAliasNVE)->(NVE_DTENCE))
		oResponse["caso"][1]["detalheEnc"]               := JConvUTF8(cDetEnc)
		oResponse["caso"][1]["particEnc"]                := JConvUTF8((cAliasNVE)->(NVE_CPART3))
		oResponse["caso"][1]["dataReab"]                 := JConvUTF8((cAliasNVE)->(NVE_DTREAB))
		oResponse["caso"][1]["detalheReab"]              := JConvUTF8(cDetReab)
		oResponse["caso"][1]["particReab"]               := JConvUTF8((cAliasNVE)->(NVE_CPART4))

		//------------- Step Remanejamento de Caso
		oResponse["caso"][1]["clienteNovo"]              := JConvUTF8((cAliasNVE)->(NVE_CCLINV))
		oResponse["caso"][1]["lojaNovo"]                 := JConvUTF8((cAliasNVE)->(NVE_CLJNV))
		oResponse["caso"][1]["casoNovo"]                 := JConvUTF8((cAliasNVE)->(NVE_CCASNV))
		oResponse["caso"][1]["nomeCliNovo"]              := JConvUTF8((cAliasNVE)->(CLINOV))
		oResponse["caso"][1]["clienteAntigo"]            := JConvUTF8((cAliasNVE)->(NVE_CCLIAN))
		oResponse["caso"][1]["lojaAntiga"]               := JConvUTF8((cAliasNVE)->(NVE_CLOJAN))
		oResponse["caso"][1]["casoAntigo"]               := JConvUTF8((cAliasNVE)->(NVE_CCASAN))
		oResponse["caso"][1]["nomeCliAnt"]               := JConvUTF8((cAliasNVE)->(CLIANT))
		oResponse["caso"][1]["revisao"]                  := JConvUTF8((cAliasNVE)->(NVE_REVISA))
		oResponse["caso"][1]["dataRev"]                  := JConvUTF8((cAliasNVE)->(NVE_DTREVI))
		oResponse["caso"][1]["codRevRem"]                := JConvUTF8((cAliasNVE)->(NVE_CPARTR))
		oResponse["caso"][1]["nomeRevRem"]               := JConvUTF8((cAliasNVE)->(CPARTR_NOME))
		oResponse["caso"][1]["siglaRevRem"]              := JConvUTF8((cAliasNVE)->(CPARTR_SIGLA))
		oResponse["caso"][1]["obsRevisao"]               := JConvUTF8(cObsRev)
		oResponse["caso"][1]["usaHistReman"]             := lPrsrvCas
	EndIf
	oCaso:Destroy()
	(cAliasNVE)->( dbCloseArea() )

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
	oResponse:FromJSon("{}")
	oResponse := Nil
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GET GrdHstCaso
Consulta Grid de Históricos do Caso do Cliente (NUU)

@example GET -> http://127.0.0.1:9090/rest/WSPfsAppCaso/histcaso/{chaveCaso}
@param chaveCaso - Chave do Caso (Filial + Cliente + Loja + Caso)

@author Reginaldo Borges
@since  27/10/2023
/*/
//-------------------------------------------------------------------
WSMethod GET GrdHstCaso PATHPARAM chaveCaso WSREST WSPfsAppCaso
Local oResponse  := JSonObject():New()
Local cChaveCaso := Decode64(Self:chaveCaso)
Local nTamFilial := TamSX3("NVE_FILIAL")[1]
Local nTamCodCli := TamSX3("NVE_CCLIEN")[1]
Local nTamCodLoj := TamSX3("NVE_LCLIEN")[1]
Local nTamCodCas := TamSX3("NVE_NUMCAS")[1]
Local cFilCaso   := Substr(cChaveCaso, 1, nTamFilial)
Local cCliente   := Substr(cChaveCaso, nTamFilial + 1, nTamCodCli)
Local cLoja      := Substr(cChaveCaso, nTamFilial + nTamCodCli + 1, nTamCodLoj)
Local cCaso      := Substr(cChaveCaso, nTamFilial + nTamCodCli + nTamCodLoj + 1, nTamCodCas)

	oResponse := {}
	Aadd(oResponse, JsonObject():New())

	oResponse := JGtHstCaso(cFilCaso, cCliente, cLoja, cCaso)

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
	aSize(oResponse, 0)
	oResponse := Nil

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JGtHstCaso
Consulta Grid de Históricos do Caso do Cliente (NUU)

@param cFilCaso   - Filial do Caso
@param cCodClien  - Código do Cliente do Caso
@param cLojClien  - Loja do Cliente do Caso
@param cCasoClien - Código do Caso

@author Reginaldo Borges
@since  27/10/2023
/*/
//-------------------------------------------------------------------
Static Function JGtHstCaso(cFilCaso, cCodClien, cLojClien, cCasoClien)
Local aHistCaso := {}
Local cQuery    := ""
Local cAliasQry := GetNextAlias()
Local nIndJson  := 0
Local nParam    := 0 // contador para os parametros da query
Local oHistCaso := Nil // Objeto de query de historico do caso
Local lPartNUU  := Iif(ChkFile("NUU"), NUU->(ColumnPos("NUU_CPART1")) > 0, .F.) // Proteção @12.1.2410

	cFilCaso   := Padr(cFilCaso  , TamSx3("NVE_FILIAL")[1])
	cCodClien  := Padr(cCodClien , TamSx3("NVE_CCLIEN")[1])
	cLojClien  := Padr(cLojClien , TamSx3("NVE_LCLIEN")[1])
	cCasoClien := Padr(cCasoClien, TamSx3("NVE_NUMCAS")[1])

	cQuery := " SELECT NUU.NUU_FILIAL,"
	cQuery +=        " NUU.NUU_CCLIEN,"
	cQuery +=        " NUU.NUU_CLOJA,"
	cQuery +=        " NUU.NUU_CCASO,"
	cQuery +=        " NUU.NUU_AMINI,"
	cQuery +=        " NUU.NUU_AMFIM,"
	cQuery +=        " NUU.NUU_CTABS,"
	cQuery +=        " COALESCE(NRE.NRE_DESC, ' ') NRE_DESC,"
	cQuery +=        " NUU.NUU_CTABH,"
	cQuery +=        " COALESCE(NRF.NRF_DESC, ' ') NRF_DESC,"
	cQuery +=        " NUU.NUU_TPHORA,"
	cQuery +=        " NUU.NUU_VLHORA,"
	cQuery +=        " NUU.NUU_CESCR,"
	cQuery +=        " COALESCE(NS7.NS7_NOME, ' ') NS7_NOME,"
	cQuery +=        " NUU.NUU_CAREAJ,"
	cQuery +=        " COALESCE(NRB.NRB_DESC, ' ') NRB_DESC,"
	cQuery +=        " NUU.NUU_CSUBAR,"
	cQuery +=        " COALESCE(NRL.NRL_DESC, ' ') NRL_DESC"
	If lPartNUU // Proteção @12.1.2410
		cQuery +=    " , NUU.NUU_CPART1,"
		cQuery +=    " RD0REV.RD0_NOME REV_NOME,"
		cQuery +=    " RD0REV.RD0_SIGLA REV_SIGLA,"
		cQuery +=    " NUU.NUU_CPART5,"
		cQuery +=    " RD0SOC.RD0_NOME SOC_NOME,"
		cQuery +=    " RD0SOC.RD0_SIGLA SOC_SIGLA"
	EndIf 
	cQuery +=   " FROM " + RetSqlName( 'NUU' ) + " NUU"
	cQuery +=   " LEFT JOIN " + RetSqlName( 'NRF' ) + " NRF"
	cQuery +=     " ON NRF.NRF_FILIAL = ?"
	cQuery +=    " AND NRF.NRF_COD = NUU.NUU_CTABH"
	cQuery +=    " AND NRF.D_E_L_E_T_ = ' '"
	cQuery +=   " LEFT JOIN " + RetSqlName( 'NRE' ) + " NRE"
	cQuery +=     " ON NRE.NRE_FILIAL = ?"
	cQuery +=    " AND NRE.NRE_COD = NUU.NUU_CTABS"
	cQuery +=    " AND NRE.D_E_L_E_T_ = ' '"
	cQuery +=   " LEFT JOIN " + RetSqlName( 'NS7' ) + " NS7"
	cQuery +=     " ON NS7.NS7_FILIAL = ?"
	cQuery +=    " AND NS7.NS7_COD = NUU.NUU_CESCR"
	cQuery +=    " AND NS7.D_E_L_E_T_ = ' '"
	cQuery +=   " LEFT JOIN " + RetSqlName( 'NRB' ) + " NRB"
	cQuery +=     " ON NRB.NRB_FILIAL = ?"
	cQuery +=    " AND NRB.NRB_COD = NUU.NUU_CAREAJ"
	cQuery +=    " AND NRB.D_E_L_E_T_ = ' '"
	cQuery +=   " LEFT JOIN " + RetSqlName( 'NRL' ) + " NRL"
	cQuery +=     " ON NRL.NRL_FILIAL = ?"
	cQuery +=    " AND NRL.NRL_COD = NUU.NUU_CSUBAR"
	cQuery +=    " AND NRL.D_E_L_E_T_ = ' '"
	If lPartNUU // Proteção @12.1.2410
		cQuery += " LEFT JOIN " + RetSqlName("RD0") + " RD0SOC"
		cQuery +=   " ON RD0SOC.RD0_FILIAL = ?"
		cQuery +=  " AND RD0SOC.RD0_CODIGO = NUU.NUU_CPART5"
		cQuery +=  " AND RD0SOC.D_E_L_E_T_ = ' '"
		cQuery += " LEFT JOIN " + RetSqlName("RD0") + " RD0REV"
		cQuery +=   " ON RD0REV.RD0_FILIAL = ?"
		cQuery +=  " AND RD0REV.RD0_CODIGO = NUU.NUU_CPART1"
		cQuery +=  " AND RD0REV.D_E_L_E_T_ = ' '"
	EndIf
	cQuery +=  " WHERE NUU.NUU_FILIAL = ?"
	cQuery +=    " AND NUU.NUU_CCLIEN = ?"
	cQuery +=    " AND NUU.NUU_CLOJA = ?"
	cQuery +=    " AND NUU.NUU_CCASO = ?"
	cQuery +=    " AND NUU.D_E_L_E_T_ = ' '"
	cQuery +=  " ORDER BY NUU.NUU_AMINI DESC"

	oHistCaso := FWPreparedStatement():New(cQuery)

	oHistCaso:SetString(++nParam, xFilial("NRF"))
	oHistCaso:SetString(++nParam, xFilial("NRE"))
	oHistCaso:SetString(++nParam, xFilial("NS7"))
	oHistCaso:SetString(++nParam, xFilial("NRB"))
	oHistCaso:SetString(++nParam, xFilial("NRL"))
	If lPartNUU // Proteção @12.1.2410
		oHistCaso:SetString(++nParam, xFilial("RD0"))
		oHistCaso:SetString(++nParam, xFilial("RD0"))
	EndIf
	oHistCaso:SetString(++nParam, cFilCaso)
	oHistCaso:SetString(++nParam, cCodClien)
	oHistCaso:SetString(++nParam, cLojClien)
	oHistCaso:SetString(++nParam, cCasoClien)

	cQuery := oHistCaso:GetFixQuery()

	MpSysOpenQuery(cQuery, cAliasQry)

	While ((cAliasQry)->(!Eof()))
		nIndJson++
		aAdd(aHistCaso, JSonObject():New())

		aHistCaso[nIndJson]['chaveNUU']     := Encode64((cAliasQry)->NUU_FILIAL + (cAliasQry)->NUU_CCLIEN + (cAliasQry)->NUU_CLOJA + (cAliasQry)->NUU_CCASO + (cAliasQry)->NUU_AMINI + (cAliasQry)->NUU_AMFIM)
		aHistCaso[nIndJson]['cliente']      := JConvUTF8((cAliasQry)->NUU_CCLIEN)
		aHistCaso[nIndJson]['loja']         := JConvUTF8((cAliasQry)->NUU_CLOJA)
		aHistCaso[nIndJson]['caso']         := JConvUTF8((cAliasQry)->NUU_CCASO)
		aHistCaso[nIndJson]['anomesini']    := JConvUTF8((cAliasQry)->NUU_AMINI)
		aHistCaso[nIndJson]['anomesfim']    := JConvUTF8((cAliasQry)->NUU_AMFIM)
		aHistCaso[nIndJson]['tabservicos']  := JConvUTF8((cAliasQry)->NUU_CTABS)
		aHistCaso[nIndJson]['descTabSer']   := JConvUTF8((cAliasQry)->NRE_DESC)
		aHistCaso[nIndJson]['tabhora']      := JConvUTF8((cAliasQry)->NUU_CTABH)
		aHistCaso[nIndJson]['descTabHora']  := JConvUTF8((cAliasQry)->NRF_DESC)
		aHistCaso[nIndJson]['tipohora']     := JConvUTF8((cAliasQry)->NUU_TPHORA)
		aHistCaso[nIndJson]['valorhora']    := JConvUTF8(cValToChar((cAliasQry)->NUU_VLHORA))
		aHistCaso[nIndJson]['escritorio']   := JConvUTF8((cAliasQry)->NUU_CESCR)
		aHistCaso[nIndJson]['nomeEsc']      := JConvUTF8((cAliasQry)->NS7_NOME)
		aHistCaso[nIndJson]['areajuridica'] := JConvUTF8((cAliasQry)->NUU_CAREAJ)
		aHistCaso[nIndJson]['descArea']     := JConvUTF8((cAliasQry)->NRB_DESC)
		aHistCaso[nIndJson]['subarea']      := JConvUTF8((cAliasQry)->NUU_CSUBAR)
		aHistCaso[nIndJson]['descSubarea']  := JConvUTF8((cAliasQry)->NRL_DESC)
		If lPartNUU // Proteção @12.1.2410
			aHistCaso[nIndJson]['codSocio']   := JConvUTF8((cAliasQry)->NUU_CPART5)
			aHistCaso[nIndJson]['nomeSocio']  := JConvUTF8((cAliasQry)->SOC_NOME)
			aHistCaso[nIndJson]['siglaSocio'] := JConvUTF8((cAliasQry)->SOC_SIGLA)
			aHistCaso[nIndJson]['codRev']     := JConvUTF8((cAliasQry)->NUU_CPART1)
			aHistCaso[nIndJson]['nomeRev']    := JConvUTF8((cAliasQry)->REV_NOME)
			aHistCaso[nIndJson]['siglaRev']   := JConvUTF8((cAliasQry)->REV_SIGLA)
		EndIf
		(cAliasQry)->(dbSkip())
	EndDo
	
	oHistCaso:Destroy()
	(cAliasQry)->(dbCloseArea())

Return aHistCaso

//-------------------------------------------------------------------
/*/{Protheus.doc} GET GrdCabParticipacao
Busca as informações da participação do caso.

@example GET -> http://127.0.0.1:9090/rest/WSPfsAppCaso/cabpartcas/{chaveCaso}

@author Victor Hayashi
@since 31/10/2023
/*/
//-------------------------------------------------------------------
WSMETHOD GET GrdCabParticipacao PATHPARAM chaveCaso QUERYPARAM WSREST WSPfsAppCaso
Local oResponse  := JSonObject():New() // Objto de Resposta da requisição
Local oPartCaso  := Nil // Objeto de query de participação do caso
Local cChvPrtCas := Decode64(Self:chaveCaso) // Chave do Caso (NVE_CCLIEN + NVE_LCLIEN + NVE_NUMCAS)
Local nTamFilial := TamSX3("NVE_FILIAL")[1] // Tamanho do campo Filial
Local nTamCodCli := TamSX3("A1_COD"    )[1] // Tamanho do campo Codigo Cliente
Local nTamCodLoj := TamSX3("A1_LOJA"   )[1] // Tamanho do campo Codigo Loja
Local nTamCodCas := TamSX3("NVE_NUMCAS")[1] // Tamanho do campo Numero do Caso
Local cFilCaso   := Substr(cChvPrtCas, 1, nTamFilial) // Filial do Caso
Local cCliente   := Substr(cChvPrtCas, nTamFilial + 1, nTamCodCli) // Codigo do Cliente do Caso
Local cLoja      := Substr(cChvPrtCas, nTamFilial + nTamCodCli + 1, nTamCodLoj) // Codigo da loja do cliente
Local cCaso      := Substr(cChvPrtCas, nTamFilial + nTamCodCli + nTamCodLoj + 1, nTamCodCas) // Numero do Caso
Local cQuery     := "" // Query para pegar as informações de participação do caso
Local cAliasNUK  := GetNextAlias() // Alias para a query de participação do caso
Local nParam     := 0 // Contador para os parametros da query
Local nIndJson   := 0 // Contador para o indice do JSON
Local lRet       := .T.

	// Query da Participação do Caso
	cQuery := " SELECT NUK.NUK_FILIAL,"
	cQuery +=        " NUK.NUK_CCLIEN,"
	cQuery +=        " NUK.NUK_CLOJA,"
	cQuery +=        " NUK.NUK_NUMCAS,"
	cQuery +=        " NUK.NUK_CPART,"
	cQuery +=        " RD0.RD0_NOME,"
	cQuery +=        " RD0.RD0_SIGLA,"
	cQuery +=        " NUK.NUK_CTIPO,"
	cQuery +=        " NRI.NRI_DESC,"
	cQuery +=        " NUK.NUK_PERC,"
	cQuery +=        " NUK.NUK_DTINI,"
	cQuery +=        " NUK.NUK_DTFIN"
	cQuery +=   " FROM " + RetSqlName( 'NUK' ) + " NUK"
	cQuery +=  " INNER JOIN " + RetSqlName("RD0") + " RD0" // Participante
	cQuery +=     " ON RD0.RD0_FILIAL = ?"
	cQuery +=    " AND RD0.RD0_CODIGO = NUK.NUK_CPART"
	cQuery +=    " AND RD0.D_E_L_E_T_ = ' '"
	cQuery +=  " INNER JOIN " + RetSqlName("NRI") + " NRI" // Originação
	cQuery +=     " ON NRI.NRI_FILIAL = ?"
	cQuery +=    " AND NRI.NRI_COD = NUK.NUK_CTIPO"
	cQuery +=    " AND NRI.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE NUK_FILIAL = ?"
	cQuery +=    " AND NUK.NUK_CCLIEN = ?"
	cQuery +=    " AND NUK.NUK_CLOJA = ?"
	cQuery +=    " AND NUK.NUK_NUMCAS = ?"
	cQuery +=    " AND NUK.D_E_L_E_T_ = ' '"

	oPartCaso := FWPreparedStatement():New(cQuery)

	oPartCaso:SetString(++nParam, xFilial('RD0'))
	oPartCaso:SetString(++nParam, xFilial('NRI'))
	oPartCaso:SetString(++nParam, cFilCaso)
	oPartCaso:SetString(++nParam, cCliente)
	oPartCaso:SetString(++nParam, cLoja)
	oPartCaso:SetString(++nParam, cCaso)

	cQuery := oPartCaso:GetFixQuery()

	MpSysOpenQuery(cQuery, cAliasNUK)

	oResponse['participacaoCaso'] := {}

	While (cAliasNUK)->(!Eof())
		nIndJson++
		// Criação do Objeto JSON
		aAdd(oResponse["participacaoCaso"], JsonObject():New())

		// Chave do Registro
		oResponse["participacaoCaso"][nIndJson]["chaveNUK"]          := Encode64((cAliasNUK)->NUK_FILIAL + (cAliasNUK)->NUK_CCLIEN + (cAliasNUK)->NUK_CLOJA + (cAliasNUK)->NUK_NUMCAS + (cAliasNUK)->NUK_CPART + (cAliasNUK)->NUK_CTIPO )
		oResponse["participacaoCaso"][nIndJson]["codParticipante"]   := JConvUTF8((cAliasNUK)->(NUK_CPART))
		oResponse["participacaoCaso"][nIndJson]["nomeParticipante"]  := JConvUTF8((cAliasNUK)->(RD0_NOME))
		oResponse["participacaoCaso"][nIndJson]["siglaParticipante"] := JConvUTF8((cAliasNUK)->(RD0_SIGLA))
		oResponse["participacaoCaso"][nIndJson]["codTipoOrig"]       := JConvUTF8((cAliasNUK)->(NUK_CTIPO))
		oResponse["participacaoCaso"][nIndJson]["descTipoOrig"]      := JConvUTF8((cAliasNUK)->(NRI_DESC))
		oResponse["participacaoCaso"][nIndJson]["percentual"]        := JConvUTF8(cValToChar((cAliasNUK)->(NUK_PERC)))
		oResponse["participacaoCaso"][nIndJson]["dataInicio"]        := JConvUTF8((cAliasNUK)->(NUK_DTINI))
		oResponse["participacaoCaso"][nIndJson]["dataFim"]           := JConvUTF8((cAliasNUK)->(NUK_DTFIN))

		(cAliasNUK)->( dbSkip() )
	EndDo
	oPartCaso:Destroy()
	(cAliasNUK)->( dbCloseArea() )

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
	oResponse:FromJSon("{}")
	oResponse := Nil

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GET GrdHisPartCaso
Busca as informações do historico da participação do caso.

@example GET -> http://127.0.0.1:9090/rest/WSPfsAppCaso/cabparticip/{chaveCaso}

@author Victor Hayashi
@since 31/10/2023
/*/
//-------------------------------------------------------------------
WSMETHOD GET GrdHisPartCaso PATHPARAM chaveCaso QUERYPARAM WSREST WSPfsAppCaso
Local oResponse  := JSonObject():New() // Objto de Resposta da requisição
Local oHstPrtCas := Nil // Objeto de query de historico de participação do caso
Local cChvPrtCas := Decode64(Self:chaveCaso) // Chave do Caso (NVE_CCLIEN + NVE_LCLIEN + NVE_NUMCAS)
Local nTamFilial := TamSX3("NVE_FILIAL")[1] // Tamanho do campo Filial
Local nTamCodCli := TamSX3("A1_COD"    )[1] // Tamanho do campo Codigo Cliente
Local nTamCodLoj := TamSX3("A1_LOJA"   )[1] // Tamanho do campo Codigo Loja
Local nTamCodCas := TamSX3("NVE_NUMCAS")[1] // Tamanho do campo Numero do Caso
Local cFilCaso   := Substr(cChvPrtCas, 1, nTamFilial) // Filial do Caso
Local cCliente   := Substr(cChvPrtCas, nTamFilial + 1, nTamCodCli) // Codigo do Cliente do Caso
Local cLoja      := Substr(cChvPrtCas, nTamFilial + nTamCodCli + 1, nTamCodLoj) // Codigo da loja do cliente
Local cCaso      := Substr(cChvPrtCas, nTamFilial + nTamCodCli + nTamCodLoj + 1, nTamCodCas) // Numero do Caso
Local cQuery     := "" // Query para pegar as informações de Historico de participação do caso
Local cAliasNVF  := GetNextAlias() // Alias para a query de participação do caso
Local nParam     := 0 // Contador para os parametros da query
Local nIndJson   := 0 // Contador para o indice do JSON
Local lRet       := .T.

	cQuery := "SELECT NVF_FILIAL,"
	cQuery +=       " NVF_COD,"
	cQuery +=       " NVF_AMINI,"
	cQuery +=       " NVF_AMFIM,"
	cQuery +=       " NVF_CCLIEN,"
	cQuery +=       " NVF_CLOJA,"
	cQuery +=       " NVF_NUMCAS,"
	cQuery +=       " NVF_CPART,"
	cQuery +=       " RD0.RD0_NOME,"
	cQuery +=       " RD0.RD0_SIGLA,"
	cQuery +=       " NVF_CTIPO,"
	cQuery +=       " NRI.NRI_DESC,"
	cQuery +=       " NVF_PERC,"
	cQuery +=       " NVF_DTINI,"
	cQuery +=       " NVF_DTFIN"
	cQuery +=  " FROM " + RetSqlName( 'NVF' ) + " NVF"
	cQuery += " INNER JOIN " + RetSqlName("RD0") + " RD0"
	cQuery +=    " ON RD0.RD0_FILIAL = ?"
	cQuery +=   " AND RD0.RD0_CODIGO = NVF.NVF_CPART"
	cQuery +=   " AND RD0.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN " + RetSqlName("NRI") + " NRI"
	cQuery +=    " ON NRI.NRI_FILIAL = ?"
	cQuery +=   " AND NRI.NRI_COD = NVF.NVF_CTIPO"
	cQuery +=   " AND NRI.D_E_L_E_T_ = ' '"
	cQuery += " WHERE NVF_FILIAL = ?
	cQuery +=   " AND NVF_CCLIEN = ?"
	cQuery +=   " AND NVF_CLOJA = ?"
	cQuery +=   " AND NVF_NUMCAS = ?"
	cQuery +=   " AND NVF.D_E_L_E_T_ = ' '"
	cQuery +=   " ORDER BY NVF_AMINI DESC, NVF_CTIPO DESC, RD0_SIGLA DESC"

	oHstPrtCas := FWPreparedStatement():New(cQuery)

	oHstPrtCas:SetString(++nParam, xFilial('RD0'))
	oHstPrtCas:SetString(++nParam, xFilial('NRI'))
	oHstPrtCas:SetString(++nParam, cFilCaso)
	oHstPrtCas:SetString(++nParam, cCliente)
	oHstPrtCas:SetString(++nParam, cLoja)
	oHstPrtCas:SetString(++nParam, cCaso)

	cQuery := oHstPrtCas:GetFixQuery()

	MpSysOpenQuery(cQuery, cAliasNVF)

	oResponse['histPartCaso'] := {}

	While (cAliasNVF)->(!Eof())
		nIndJson++
		// Criação do Objeto JSON
		aAdd(oResponse["histPartCaso"], JsonObject():New())

		// Chave do Registro
		oResponse["histPartCaso"][nIndJson]["chaveNVF"]          := Encode64((cAliasNVF)->NVF_FILIAL + (cAliasNVF)->NVF_CCLIEN + (cAliasNVF)->NVF_CLOJA + (cAliasNVF)->NVF_NUMCAS + (cAliasNVF)->NVF_CPART + (cAliasNVF)->NVF_CTIPO + (cAliasNVF)->NVF_AMINI + (cAliasNVF)->NVF_AMFIM)
		oResponse["histPartCaso"][nIndJson]["anoMesIni"]         := JConvUTF8((cAliasNVF)->NVF_AMINI)
		oResponse["histPartCaso"][nIndJson]["anoMesFim"]         := JConvUTF8((cAliasNVF)->NVF_AMFIM)
		oResponse["histPartCaso"][nIndJson]["codParticipante"]   := JConvUTF8((cAliasNVF)->NVF_CPART)
		oResponse["histPartCaso"][nIndJson]["nomeParticipante"]  := JConvUTF8((cAliasNVF)->(RD0_NOME))
		oResponse["histPartCaso"][nIndJson]["siglaParticipante"] := JConvUTF8((cAliasNVF)->(RD0_SIGLA))
		oResponse["histPartCaso"][nIndJson]["codTipoOrig"]       := JConvUTF8((cAliasNVF)->NVF_CTIPO)
		oResponse["histPartCaso"][nIndJson]["descTipoOrig"]      := JConvUTF8((cAliasNVF)->(NRI_DESC))
		oResponse["histPartCaso"][nIndJson]["percentual"]        := JConvUTF8(cValToChar((cAliasNVF)->NVF_PERC))
		oResponse["histPartCaso"][nIndJson]["dataInicio"]        := JConvUTF8((cAliasNVF)->NVF_DTINI)
		oResponse["histPartCaso"][nIndJson]["dataFim"]           := JConvUTF8((cAliasNVF)->NVF_DTFIN)

		(cAliasNVF)->( dbSkip() )
	EndDo
	
	oHstPrtCas:Destroy()
	(cAliasNVF)->( dbCloseArea() )

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
	oResponse:FromJSon("{}")
	oResponse := Nil

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GET GrdCondExitoCaso
Consulta Grid de Condição de Êxito Caso do Cliente (NWL)

@example GET -> http://127.0.0.1:9090/rest/WSPfsAppCaso/condexitocas/{chaveCaso}
@param chaveCaso - Chave do Caso (Filial + Cliente + Loja + Caso)

@author Reginaldo Borges
@since  03/11/2023
/*/
//-------------------------------------------------------------------
WSMethod GET GrdCondExitoCaso PATHPARAM chaveCaso WSREST WSPfsAppCaso
Local oResponse  := JSonObject():New()
Local cChaveCaso := Decode64(Self:chaveCaso)
Local nTamFilial := TamSX3("NVE_FILIAL")[1]
Local nTamCodCli := TamSX3("NVE_CCLIEN")[1]
Local nTamCodLoj := TamSX3("NVE_LCLIEN")[1]
Local nTamCodCas := TamSX3("NVE_NUMCAS")[1]
Local cFilCaso   := Substr(cChaveCaso, 1, nTamFilial)
Local cCliente   := Substr(cChaveCaso, nTamFilial + 1, nTamCodCli)
Local cLoja      := Substr(cChaveCaso, nTamFilial + nTamCodCli + 1, nTamCodLoj)
Local cCaso      := Substr(cChaveCaso, nTamFilial + nTamCodCli + nTamCodLoj + 1, nTamCodCas)

	oResponse := {}
	Aadd(oResponse, JsonObject():New())

	oResponse := JGtCdExtCaso(cFilCaso, cCliente, cLoja, cCaso)

	Self:SetResponse( FWJsonSerialize(oResponse, .F., .F., .T.) )
	aSize(oResponse, 0)
	oResponse := Nil

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JGtCdExtCaso
Consulta Grid de Condição de Êxito Caso do Cliente (NWL)

@param cFilCaso   - Filial do Caso
@param cCodClien  - Código do Cliente do Caso
@param cLojClien  - Loja do Cliente do Caso
@param cCasoClien - Código do Caso

@author Reginaldo Borges
@since  03/11/2023
/*/
//-------------------------------------------------------------------
Static Function JGtCdExtCaso(cFilCaso, cCodClien, cLojClien, cCasoClien)
Local aCondExitoCaso := {}
Local cQuery         := ""
Local cAliasQry      := ""
Local nIndJson       := 0
Local nOpCondEx      := 0
Local nOpTpOcor      := 0
Local aOpCondEx      := {STR0018,STR0019,STR0020,STR0021,STR0022} // "Percentual" / "Faixa de Valor" / "Faixa de Anos (Data de Distribuição)" / "Percentual (com Limite de Valor)" / "Valor Fechado"
Local aOpTpOcor      := {STR0023,STR0024} // "Não Corrigir" / "Índice"

	cFilCaso   := Padr(cFilCaso  , TamSx3("NVE_FILIAL")[1])
	cCodClien  := Padr(cCodClien , TamSx3("NVE_CCLIEN")[1])
	cLojClien  := Padr(cLojClien , TamSx3("NVE_LCLIEN")[1])
	cCasoClien := Padr(cCasoClien, TamSx3("NVE_NUMCAS")[1])

	cQuery := " SELECT NWL.NWL_FILIAL,"
	cQuery +=        " NWL.NWL_COD,"
	cQuery +=        " NWL.NWL_CCLIEN,"
	cQuery +=        " NWL.NWL_CLOJA,"
	cQuery +=        " NWL.NWL_DCLIEN,"
	cQuery +=        " NWL.NWL_NUMCAS,"
	cQuery +=        " NWL.NWL_DCASO,"
	cQuery +=        " NWL.NWL_CONDEX,"
	cQuery +=        " NWL.NWL_PERCEN,"
	cQuery +=        " NWL.NWL_VALINI,"
	cQuery +=        " NWL.NWL_VALFIN,"
	cQuery +=        " NWL.NWL_ANOINI,"
	cQuery +=        " NWL.NWL_ANOFIN,"
	cQuery +=        " NWL.NWL_VALLIM,"
	cQuery +=        " NWL.NWL_DTBASE,"
	cQuery +=        " NWL.NWL_VALFEC,"
	cQuery +=        " NWL.NWL_TPCORR,"
	cQuery +=        " NWL.NWL_CINDIC,"
	cQuery +=        " COALESCE(NW5.NW5_DESC, ' ') NW5_DESC,"
	cQuery +=        " NWL.NWL_VALCOR"
	cQuery +=   " FROM " + RetSqlNAme("NWL") + " NWL"
	cQuery +=   " LEFT JOIN " + RetSqlNAme("NW5") + " NW5"
	cQuery +=     " ON NW5.NW5_FILIAL = ?"
	cQuery +=    " AND NW5.NW5_COD = NWL.NWL_CINDIC"
	cQuery +=    " AND NW5.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE NWL.NWL_FILIAL = ?"
	cQuery +=    " AND NWL.NWL_CCLIEN = ?"
	cQuery +=    " AND NWL.NWL_CLOJA = ?"
	cQuery +=    " AND NWL.NWL_NUMCAS = ?"
	cQuery +=    " AND NWL.D_E_L_E_T_ = ' '"
	cQuery +=   "ORDER BY NWL_FILIAL, NWL_COD"

	cAliasQry := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TcGenQry2( ,, cQuery, {xFilial("NW5"), xFilial("NWL"), cCodClien, cLojClien, cCasoClien} ) , cAliasQry, .T., .F. )

	While ((cAliasQry)->(!Eof()))
		nIndJson++
		aAdd(aCondExitoCaso, JSonObject():New())

		aCondExitoCaso[nIndJson]['cChaveNWL']      := Encode64((cAliasQry)->NWL_FILIAL + (cAliasQry)->NWL_COD)
		aCondExitoCaso[nIndJson]['condicaoExito']  := JConvUTF8((cAliasQry)->NWL_CONDEX)
		nOpCondEx := Val((cAliasQry)->NWL_CONDEX)
		If !Empty(nOpCondEx)
			aCondExitoCaso[nIndJson]['descCondExt']    := JConvUTF8(aOpCondEx[nOpCondEx])
		EndIf
		aCondExitoCaso[nIndJson]['percentual']     := JConvUTF8(cValToChar((cAliasQry)->NWL_PERCEN))
		aCondExitoCaso[nIndJson]['valorInicial']   := JConvUTF8(cValToChar((cAliasQry)->NWL_VALINI))
		aCondExitoCaso[nIndJson]['valorFinal']     := JConvUTF8(cValToChar((cAliasQry)->NWL_VALFIN))
		aCondExitoCaso[nIndJson]['anoInicial']     := JConvUTF8((cAliasQry)->NWL_ANOINI)
		aCondExitoCaso[nIndJson]['anoFinal']       := JConvUTF8((cAliasQry)->NWL_ANOFIN)
		aCondExitoCaso[nIndJson]['valorLimite']    := JConvUTF8(cValToChar((cAliasQry)->NWL_VALLIM))
		aCondExitoCaso[nIndJson]['dataBase']       := JConvUTF8((cAliasQry)->NWL_DTBASE)
		aCondExitoCaso[nIndJson]['valorFechado']   := JConvUTF8(cValToChar((cAliasQry)->NWL_VALFEC))
		aCondExitoCaso[nIndJson]['tipoCorrecao']   := JConvUTF8(cValToChar((cAliasQry)->NWL_TPCORR))
		nOpTpOcor := Val((cAliasQry)->NWL_TPCORR)
		If !Empty(nOpTpOcor)
			aCondExitoCaso[nIndJson]['descCorrecao']   := JConvUTF8(aOpTpOcor[nOpTpOcor])
		EndIf
		aCondExitoCaso[nIndJson]['codigoIndice']   := JConvUTF8((cAliasQry)->NWL_CINDIC)
		aCondExitoCaso[nIndJson]['descIndice']     := JConvUTF8((cAliasQry)->NW5_DESC)
		aCondExitoCaso[nIndJson]['valorCorrigido'] := JConvUTF8(cValToChar((cAliasQry)->NWL_VALCOR))

		(cAliasQry)->(dbSkip())
	EndDo

	(cAliasQry)->(dbCloseArea())

Return aCondExitoCaso

//-------------------------------------------------------------------
/*/{Protheus.doc} GET GrdsSocRevDoCaso
Consulta Grid de Sócios/Revisores do Caso do Cliente (OHN)

@example GET -> http://127.0.0.1:9090/rest/WSPfsAppCaso/socrevdocaso/{chaveCaso}
@param chaveCaso - Chave do Caso (Filial + Cliente + Loja + Caso)

@author Reginaldo Borges
@since  03/11/2023
/*/
//-------------------------------------------------------------------
WSMethod GET GrdsSocRevDoCaso PATHPARAM chaveCaso WSREST WSPfsAppCaso
Local oResponse  := JSonObject():New()
Local cChaveCaso := Decode64(Self:chaveCaso)
Local nTamFilial := TamSX3("NVE_FILIAL")[1]
Local nTamCodCli := TamSX3("NVE_CCLIEN")[1]
Local nTamCodLoj := TamSX3("NVE_LCLIEN")[1]
Local nTamCodCas := TamSX3("NVE_NUMCAS")[1]
Local cFilCaso   := Substr(cChaveCaso, 1, nTamFilial)
Local cCliente   := Substr(cChaveCaso, nTamFilial + 1, nTamCodCli)
Local cLoja      := Substr(cChaveCaso, nTamFilial + nTamCodCli + 1, nTamCodLoj)
Local cCaso      := Substr(cChaveCaso, nTamFilial + nTamCodCli + nTamCodLoj + 1, nTamCodCas)

	oResponse := {}
	Aadd(oResponse, JsonObject():New())

	oResponse := JGtSocRevCaso(cFilCaso, cCliente, cLoja, cCaso)

	Self:SetResponse( FWJsonSerialize(oResponse, .F., .F., .T.) )
	aSize(oResponse, 0)
	oResponse := Nil

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JGtSocRevCaso
Consulta Grid de Sócios/Revisores do Caso do Cliente (OHN)

@param cFilCaso   - Filial do Caso
@param cCodClien  - Código do Cliente do Caso
@param cLojClien  - Loja do Cliente do Caso
@param cCasoClien - Código do Caso

@author Reginaldo Borges
@since  03/11/2023
/*/
//-------------------------------------------------------------------
Static Function JGtSocRevCaso(cFilCaso, cCodClien, cLojClien, cCasoClien)
Local aCondExitoCaso := {}
Local cQuery         := ""
Local cAliasQry      := ""
Local aOpTpRev       := {STR0025,STR0026,STR0027} // "Honorários" / "Despesas" / "Ambos"
Local aTipo          := {STR0028,STR0029} // "Sócio Responsável" / "Revisor"
Local nIndJson       := 0
Local nTipo          := 0
Local nTpRev         := 0

	cFilCaso   := Padr(cFilCaso  , TamSx3("NVE_FILIAL")[1])
	cCodClien  := Padr(cCodClien , TamSx3("NVE_CCLIEN")[1])
	cLojClien  := Padr(cLojClien , TamSx3("NVE_LCLIEN")[1])
	cCasoClien := Padr(cCasoClien, TamSx3("NVE_NUMCAS")[1])

	cQuery := " SELECT OHN.OHN_FILIAL,"
	cQuery +=        " OHN.OHN_CPREFT,"
	cQuery +=        " OHN.OHN_CCLIEN,"
	cQuery +=        " OHN.OHN_CLOJA,"
	cQuery +=        " OHN.OHN_CCASO,"
	cQuery +=        " OHN.OHN_TIPO,"
	cQuery +=        " OHN.OHN_CPART,"
	cQuery +=        " RD0.RD0_NOME,"
	cQuery +=        " RD0.RD0_SIGLA,"
	cQuery +=        " OHN.OHN_ORDEM,"
	cQuery +=        " OHN.OHN_REVISA,"
	cQuery +=        " OHN.OHN_CCONTR"
	cQuery +=   " FROM " + RetSqlNAme("OHN") + " OHN"
	cQuery +=  " INNER JOIN " + RetSqlNAme("RD0") + " RD0"
	cQuery +=     " ON RD0.RD0_FILIAL = ?"
	cQuery +=    " AND RD0.RD0_CODIGO = OHN.OHN_CPART"
	cQuery +=    " AND RD0.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE OHN.OHN_FILIAL = ?"
	cQuery +=    " AND OHN.OHN_CCLIEN = ?"
	cQuery +=    " AND OHN.OHN_CLOJA = ?"
	cQuery +=    " AND OHN.OHN_CCASO = ?"
	cQuery +=    " AND OHN.OHN_CPREFT = ' '"
	cQuery +=    " AND OHN.D_E_L_E_T_ = ' '"
	cQuery +=    " ORDER BY OHN_FILIAL, OHN_CPREFT, OHN_CCONTR, OHN_CCLIEN, OHN_CLOJA, OHN_CCASO, OHN_CPART, OHN_REVISA"

	cAliasQry := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TcGenQry2( ,, cQuery, {xFilial("NVE"), cFilCaso, cCodClien, cLojClien, cCasoClien} ) , cAliasQry, .T., .F. )

	While ((cAliasQry)->(!Eof()))
		nIndJson++
		aAdd(aCondExitoCaso, JSonObject():New())

		nTipo  := Val((cAliasQry)->OHN_TIPO)
		nTpRev := Val((cAliasQry)->OHN_REVISA)

		aCondExitoCaso[nIndJson]['cChaveOHN']       := Encode64((cAliasQry)->(OHN_FILIAL + OHN_CPREFT + OHN_CCONTR + OHN_CCLIEN+ OHN_CLOJA + OHN_CCASO + OHN_CPART + OHN_REVISA))
		aCondExitoCaso[nIndJson]['codidoPreFatura'] := JConvUTF8((cAliasQry)->OHN_CPREFT)
		aCondExitoCaso[nIndJson]['codigoCliente']   := JConvUTF8((cAliasQry)->OHN_CCLIEN)
		aCondExitoCaso[nIndJson]['lojaCliente']     := JConvUTF8((cAliasQry)->OHN_CLOJA)
		aCondExitoCaso[nIndJson]['codigoCaso']      := JConvUTF8((cAliasQry)->OHN_CCASO)
		aCondExitoCaso[nIndJson]['tipo']            := JConvUTF8((cAliasQry)->OHN_TIPO)
		aCondExitoCaso[nIndJson]['tipoDesc']        := JConvUTF8(aTipo[nTipo])
		aCondExitoCaso[nIndJson]['codigoPartic']    := JConvUTF8((cAliasQry)->OHN_CPART)
		aCondExitoCaso[nIndJson]['nomePartic']      := JConvUTF8((cAliasQry)->RD0_NOME)
		aCondExitoCaso[nIndJson]['siglaPartic']     := JConvUTF8((cAliasQry)->RD0_SIGLA)
		aCondExitoCaso[nIndJson]['ordemRevisao']    := JConvUTF8(cValToChar((cAliasQry)->OHN_ORDEM))
		aCondExitoCaso[nIndJson]['tipoRevisao']     := JConvUTF8((cAliasQry)->OHN_REVISA)
		aCondExitoCaso[nIndJson]['tipoRevDesc']     := JConvUTF8(aOpTpRev[nTpRev])
		aCondExitoCaso[nIndJson]['codigoContrato']  := JConvUTF8((cAliasQry)->OHN_CCONTR)

		(cAliasQry)->(dbSkip())
	EndDo

	(cAliasQry)->(dbCloseArea())

Return aCondExitoCaso


//-------------------------------------------------------------------
/*/{Protheus.doc} GET GExcTbHnCtg
Retorna dados das tabelas de exceção nas tabelas de honorarios
referente a categoria (NUW)

@example GET -> http://127.0.0.1:9090/rest/WSPfsAppCaso/extbhoncateg/{chaveCaso}
@param chaveCaso - Chave do Caso (Filial + Cliente + Loja + Caso)

@author Victor Hayashi
@since  03/11/2023
/*/
//-------------------------------------------------------------------
WSMethod GET GExcTbHnCtg PATHPARAM chaveCaso WSREST WSPfsAppCaso
Local oResponse  := JSonObject():New()
Local cChaveCaso := Decode64(Self:chaveCaso)
Local nTamFilial := TamSX3("NVE_FILIAL")[1]
Local nTamCodCli := TamSX3("NVE_CCLIEN")[1]
Local nTamCodLoj := TamSX3("NVE_LCLIEN")[1]
Local nTamCodCas := TamSX3("NVE_NUMCAS")[1]
Local cFilCaso   := Substr(cChaveCaso, 1, nTamFilial)
Local cCliente   := Substr(cChaveCaso, nTamFilial + 1, nTamCodCli)
Local cLoja      := Substr(cChaveCaso, nTamFilial + nTamCodCli + 1, nTamCodLoj)
Local cCaso      := Substr(cChaveCaso, nTamFilial + nTamCodCli + nTamCodLoj + 1, nTamCodCas)

	oResponse['excTabHon'] := JsonObject():New()
	oResponse['excTabHon']['categoria']    := {}

	// -- Exceção Tabela de Honorarios por Categoria
	Aadd(oResponse['excTabHon']['categoria'] , JsonObject():New())
	oResponse['excTabHon']['categoria'] := GetExCateg(cFilCaso, cCliente, cLoja, cCaso)

	Self:SetResponse( FWJsonSerialize(oResponse, .F., .F., .T.) )
	oResponse:FromJSon("{}")
	oResponse := Nil

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET GetExcTbHnPart
Retorna dados das tabelas de exceção nas tabelas de honorarios
referente a participação (NV0).

@example GET -> http://127.0.0.1:9090/rest/WSPfsAppCaso/extbhonpart/{chaveCaso}
@param chaveCaso - Chave do Caso (Filial + Cliente + Loja + Caso)

@author Victor Hayashi
@since  03/11/2023
/*/
//-------------------------------------------------------------------
WSMethod GET GetExcTbHnPart PATHPARAM chaveCaso WSREST WSPfsAppCaso
Local oResponse  := JSonObject():New()
Local cChaveCaso := Decode64(Self:chaveCaso)
Local nTamFilial := TamSX3("NVE_FILIAL")[1]
Local nTamCodCli := TamSX3("NVE_CCLIEN")[1]
Local nTamCodLoj := TamSX3("NVE_LCLIEN")[1]
Local nTamCodCas := TamSX3("NVE_NUMCAS")[1]
Local cFilCaso   := Substr(cChaveCaso, 1, nTamFilial)
Local cCliente   := Substr(cChaveCaso, nTamFilial + 1, nTamCodCli)
Local cLoja      := Substr(cChaveCaso, nTamFilial + nTamCodCli + 1, nTamCodLoj)
Local cCaso      := Substr(cChaveCaso, nTamFilial + nTamCodCli + nTamCodLoj + 1, nTamCodCas)

	oResponse['excTabHon'] := JsonObject():New()
	oResponse['excTabHon']['participante'] := {}

	// -- Exceção Tabela de Honorarios por Participante
	Aadd(oResponse['excTabHon']['participante'] , JsonObject():New())
	oResponse['excTabHon']['participante'] := GetExPart(cFilCaso, cCliente, cLoja, cCaso)

	Self:SetResponse( FWJsonSerialize(oResponse, .F., .F., .T.) )
	oResponse:FromJSon("{}")
	oResponse := Nil

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET GetAtvExcTbHn
Retorna dados das tabelas de exceção nas tabelas de honorarios 
referente a atividade (OHR).

@example GET -> http://127.0.0.1:9090/rest/WSPfsAppCaso/extbhonativ/{chaveCaso}
@param chaveCaso - Chave do Caso (Filial + Cliente + Loja + Caso)

@author Victor Hayashi
@since  03/11/2023
/*/
//-------------------------------------------------------------------
WSMethod GET GetAtvExcTbHn PATHPARAM chaveCaso WSREST WSPfsAppCaso
Local oResponse  := JSonObject():New()
Local cChaveCaso := Decode64(Self:chaveCaso)
Local nTamFilial := TamSX3("NVE_FILIAL")[1]
Local nTamCodCli := TamSX3("NVE_CCLIEN")[1]
Local nTamCodLoj := TamSX3("NVE_LCLIEN")[1]
Local nTamCodCas := TamSX3("NVE_NUMCAS")[1]
Local cFilCaso   := Substr(cChaveCaso, 1, nTamFilial)
Local cCliente   := Substr(cChaveCaso, nTamFilial + 1, nTamCodCli)
Local cLoja      := Substr(cChaveCaso, nTamFilial + nTamCodCli + 1, nTamCodLoj)
Local cCaso      := Substr(cChaveCaso, nTamFilial + nTamCodCli + nTamCodLoj + 1, nTamCodCas)

	oResponse['excTabHon'] := JsonObject():New()
	oResponse['excTabHon']['atividade']    := {}

	// -- Exceção Tabela de Honorarios por Atividade
	Aadd(oResponse['excTabHon']['atividade'] , JsonObject():New())
	oResponse['excTabHon']['atividade'] := GetExAtiv(cFilCaso, cCliente, cLoja, cCaso)

	Self:SetResponse( FWJsonSerialize(oResponse, .F., .F., .T.) )
	oResponse:FromJSon("{}")
	oResponse := Nil

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GetExCateg
Retorna dados das tabelas de exceção nas tabelas de honorarios da 
Categoria (NUW).

@param cFilCaso   - Filial do Caso
@param cCodClien  - Código do Cliente do Caso
@param cLojClien  - Loja do Cliente do Caso
@param cCasoClien - Código do Caso

@author Victor Hayashi
@since  10/11/2023
/*/
//-------------------------------------------------------------------
Static Function GetExCateg(cFilCaso, cCodClien, cLojClien, cCasoClien)
Local aExcTabHon := JSonObject():New() // Array com as informações de exceção de tabela de honorarios
Local oExTabHon  := Nil // Objeto de query de exceção de tabela de honorarios
Local cQuery     := "" // Query da exceção de tabela de honorarios
Local cTabHon    := "" // Codigo da tabela de honorarios do caso
Local cAliasQry  := GetNextAlias() // Alias para a query
Local nIndJson   := 0 // Indice do JSON
Local nParam     := 0 // Contador dos parametros de query
Local nValor1    := 0 // Valor Original
Local nValor3    := 0 // Valor Ajustado
Local aInfoApi   := {} // Array com as informações para as funções dos campos virtuais

	cFilCaso   := Padr(cFilCaso  , TamSx3("NVE_FILIAL")[1])
	cCodClien  := Padr(cCodClien , TamSx3("NVE_CCLIEN")[1])
	cLojClien  := Padr(cLojClien , TamSx3("NVE_LCLIEN")[1])
	cCasoClien := Padr(cCasoClien, TamSx3("NVE_NUMCAS")[1])

	cTabHon    := AllTrim(JurGetDados('NVE', 1, cFilCaso + cCodClien + cLojClien + cCasoClien, 'NVE_CTABH'))

	cQuery := " SELECT NUW_FILIAL,"
	cQuery +=        " NUW.NUW_CCLIEN,"
	cQuery +=        " NUW.NUW_CLOJA,"
	cQuery +=        " NUW.NUW_CCASO,"
	cQuery +=        " NUW.NUW_COD,"
	cQuery +=        " NUW.NUW_AMINI,"
	cQuery +=        " NUW.NUW_AMFIM,"
	cQuery +=        " NUW.NUW_CCAT,"
	cQuery +=        " COALESCE(NRN.NRN_DESC, ' ') NRN_DESC,"
	cQuery +=        " NUW.NUW_REGRA,"
	cQuery +=        " NUW.NUW_VALOR2"
	cQuery +=   " FROM " + RetSqlNAme("NUW") + " NUW"
	cQuery +=  " LEFT JOIN " + RetSqlNAme("NRN") + " NRN"
	cQuery +=     " ON NRN.NRN_FILIAL = ?"
	cQuery +=    " AND NRN.NRN_COD = NUW.NUW_CCAT"
	cQuery +=    " AND NRN.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE NUW.NUW_FILIAL = ?"
	cQuery +=    " AND NUW.NUW_CCLIEN = ?"
	cQuery +=    " AND NUW.NUW_CLOJA = ?"
	cQuery +=    " AND NUW.NUW_CCASO = ?"
	cQuery +=    " AND NUW.D_E_L_E_T_ = ' '"
	cQuery +=  " ORDER BY NUW_AMINI DESC"

	oExTabHon := FWPreparedStatement():New(cQuery)

	oExTabHon:SetString(++nParam, xFilial('NRN'))
	oExTabHon:SetString(++nParam, xFilial('NUW'))
	oExTabHon:SetString(++nParam, cCodClien)
	oExTabHon:SetString(++nParam, cLojClien)
	oExTabHon:SetString(++nParam, cCasoClien)

	cQuery := oExTabHon:GetFixQuery()
	MpSysOpenQuery(cQuery, cAliasQry)

	aExcTabHon := {}

	While ((cAliasQry)->(!Eof()))
		nIndJson++
		aAdd(aExcTabHon, JSonObject():New())

		// NUW_VALOR1 - Valor Original
		aInfoApi := {(cAliasQry)->NUW_AMINI, (cAliasQry)->NUW_AMFIM, (cAliasQry)->NUW_CCAT, cFilCaso, cCodClien, cLojClien, cCasoClien }
		nValor1  := J70VlONUW(/*modelo*/, aInfoApi)

		// NUW_VALOR3 - Valor Ajustado
		aInfoApi := { nValor1, (cAliasQry)->NUW_VALOR2, (cAliasQry)->NUW_REGRA, (cAliasQry)->NUW_CCAT, cTabHon, (cAliasQry)->NUW_AMINI, (cAliasQry)->NUW_AMFIM, ""/*NV0_EXCCAT*/, ""/*NUW_VALOR3*/}
		nValor3  := J70VLRAJUST("NUW" , /*modelo*/, aInfoApi)

		aExcTabHon[nIndJson]['cChaveNUW']     := Encode64((cAliasQry)->(NUW_FILIAL+NUW_CCLIEN+NUW_CLOJA+NUW_CCASO+NUW_CCAT+NUW_COD+NUW_AMINI))
		aExcTabHon[nIndJson]['anoMesIni']     := JConvUTF8((cAliasQry)->NUW_AMINI)
		aExcTabHon[nIndJson]['anoMesFim']     := JConvUTF8((cAliasQry)->NUW_AMFIM)
		aExcTabHon[nIndJson]['codCategoria']  := JConvUTF8((cAliasQry)->NUW_CCAT)
		aExcTabHon[nIndJson]['descCategoria'] := JConvUTF8((cAliasQry)->NRN_DESC)
		aExcTabHon[nIndJson]['regra']         := JConvUTF8((cAliasQry)->NUW_REGRA)
		aExcTabHon[nIndJson]['valorOriginal'] := JConvUTF8(cValToChar(nValor1)) //NUW_VALOR1
		aExcTabHon[nIndJson]['valorAjuste']   := JConvUTF8(cValToChar((cAliasQry)->NUW_VALOR2))
		aExcTabHon[nIndJson]['valorAjustado'] := JConvUTF8(cValToChar(nValor3)) //NUW_VALOR3

		(cAliasQry)->(dbSkip())
	EndDo

	(cAliasQry)->(dbCloseArea())

Return aExcTabHon

//-------------------------------------------------------------------
/*/{Protheus.doc} GetExPart
Retorna dados das tabelas de exceção nas tabelas de honorarios do 
Participante (NV0).

@param cFilCaso   - Filial do Caso
@param cCodClien  - Código do Cliente do Caso
@param cLojClien  - Loja do Cliente do Caso
@param cCasoClien - Código do Caso

@author Victor Hayashi
@since  10/11/2023
/*/
//-------------------------------------------------------------------
Static Function GetExPart(cFilCaso, cCodClien, cLojClien, cCasoClien)
Local aExcTabHon := JSonObject():New() // Array com as informações de exceção de tabela de honorarios
Local oExTabHon  := Nil // Objeto de query de exceção de tabela de honorarios
Local cQuery     := "" // Query da exceção de tabela de honorarios
Local cTabHon    := "" // Codigo da tabela de honorarios do caso
Local cDescCateg := "" // Descrição da categoria original
Local cAliasQry  := GetNextAlias() // Alias para a query
Local nIndJson   := 0 // Indice do JSON
Local nParam     := 0 // Contador dos parametros de query
Local nValor1    := 0 // Valor Original
Local nValor3    := 0 // Valor Ajustado
Local aInfoApi   := {} // Array com as informações para as funções dos campos virtuais

	cFilCaso   := Padr(cFilCaso  , TamSx3("NVE_FILIAL")[1])
	cCodClien  := Padr(cCodClien , TamSx3("NVE_CCLIEN")[1])
	cLojClien  := Padr(cLojClien , TamSx3("NVE_LCLIEN")[1])
	cCasoClien := Padr(cCasoClien, TamSx3("NVE_NUMCAS")[1])

	cTabHon    := AllTrim(JurGetDados('NVE', 1, cFilCaso + cCodClien + cLojClien + cCasoClien, 'NVE_CTABH'))

	cQuery := " SELECT NV0_FILIAL,"
	cQuery +=        " NV0.NV0_CCLIEN,"
	cQuery +=        " NV0.NV0_CLOJA,"
	cQuery +=        " NV0.NV0_CCASO,"
	cQuery +=        " NV0.NV0_COD,"
	cQuery +=        " NV0.NV0_AMINI,"
	cQuery +=        " NV0.NV0_AMFIM,"
	cQuery +=        " NV0.NV0_CPART,"
	cQuery +=        " RD0.RD0_NOME,"
	cQuery +=        " RD0.RD0_SIGLA,"
	cQuery +=        " NV0.NV0_EXCCAT,"
	cQuery +=        " NV0.NV0_REGRA,"
	cQuery +=        " NV0.NV0_CCAT,"
	cQuery +=        " COALESCE(NRN.NRN_DESC, ' ') NRN_DESC,"
	cQuery +=        " NV0.NV0_VALOR2"
	cQuery +=   " FROM " + RetSqlNAme("NV0") + " NV0"
	cQuery +=  " INNER JOIN " + RetSqlNAme("RD0") + " RD0"
	cQuery +=     " ON RD0.RD0_FILIAL = ?"
	cQuery +=    " AND RD0.RD0_CODIGO = NV0.NV0_CPART"
	cQuery +=    " AND RD0.D_E_L_E_T_ = ' '"
	cQuery +=   " LEFT JOIN " + RetSqlNAme("NRN") + " NRN"
	cQuery +=     " ON NRN.NRN_FILIAL = ?"
	cQuery +=    " AND NRN.NRN_COD = NV0.NV0_CCAT"
	cQuery +=    " AND NRN.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE NV0.NV0_FILIAL = ' '"
	cQuery +=    " AND NV0.NV0_CCLIEN = ?"
	cQuery +=    " AND NV0.NV0_CLOJA = ?"
	cQuery +=    " AND NV0.NV0_CCASO = ?"
	cQuery +=    " AND NV0.D_E_L_E_T_ = ' '"
	cQuery +=  " ORDER BY NV0_AMINI DESC"

	oExTabHon := FWPreparedStatement():New(cQuery)

	oExTabHon:SetString(++nParam, xFilial('RD0'))
	oExTabHon:SetString(++nParam, xFilial('NV0'))
	oExTabHon:SetString(++nParam, cCodClien)
	oExTabHon:SetString(++nParam, cLojClien)
	oExTabHon:SetString(++nParam, cCasoClien)

	cQuery := oExTabHon:GetFixQuery()
	MpSysOpenQuery(cQuery, cAliasQry)

	aExcTabHon := {}

	While ((cAliasQry)->(!Eof()))
		nIndJson++
		aAdd(aExcTabHon, JSonObject():New())

		cDescCateg := J70GATDCAT("NV0", {(cAliasQry)->NV0_AMINI, (cAliasQry)->NV0_AMFIM, (cAliasQry)->NV0_CPART})

		// NV0_VALOR1 - Valor Original
		aInfoApi := {cCodClien, cLojClien, cCasoClien, (cAliasQry)->NV0_AMINI, (cAliasQry)->NV0_AMFIM, (cAliasQry)->NV0_CPART, (cAliasQry)->NV0_REGRA, (cAliasQry)->NV0_CCAT, (cAliasQry)->NV0_EXCCAT, ""/*NUW_VALOR3*/}
		nValor1  := J70VlONV0(/*modelo*/, aInfoApi)

		// NV0_VALOR3 - Valor Ajustado
		aInfoApi := { nValor1, (cAliasQry)->NV0_VALOR2, (cAliasQry)->NV0_REGRA, (cAliasQry)->NV0_CCAT, cTabHon, (cAliasQry)->NV0_AMINI, (cAliasQry)->NV0_AMFIM, (cAliasQry)->NV0_EXCCAT,""/*NUW_VALOR3*/}
		nValor3  := J70VLRAJUST("NV0" , /*modelo*/, aInfoApi)

		aExcTabHon[nIndJson]['cChaveNV0']     := Encode64((cAliasQry)->(NV0_FILIAL+NV0_CCLIEN+NV0_CLOJA+NV0_CCASO+NV0_CPART+NV0_CCAT+NV0_COD+NV0_AMINI ))
		aExcTabHon[nIndJson]['anoMesIni']     := JConvUTF8((cAliasQry)->NV0_AMINI)
		aExcTabHon[nIndJson]['anoMesFim']     := JConvUTF8((cAliasQry)->NV0_AMFIM)
		aExcTabHon[nIndJson]['codPart']       := JConvUTF8((cAliasQry)->NV0_CPART)
		aExcTabHon[nIndJson]['nomePart']      := JConvUTF8((cAliasQry)->RD0_NOME)
		aExcTabHon[nIndJson]['siglaPart']     := JConvUTF8((cAliasQry)->RD0_SIGLA)
		aExcTabHon[nIndJson]['descCategOrig'] := JConvUTF8(cDescCateg) // NV0_DCAT1
		aExcTabHon[nIndJson]['valorOriginal'] := JConvUTF8(cValToChar(nValor1)) // NV0_VALOR1
		aExcTabHon[nIndJson]['acumulativo']   := JConvUTF8((cAliasQry)->NV0_EXCCAT)
		aExcTabHon[nIndJson]['regra']         := JConvUTF8((cAliasQry)->NV0_REGRA)
		aExcTabHon[nIndJson]['codCateg']      := JConvUTF8((cAliasQry)->NV0_CCAT)
		aExcTabHon[nIndJson]['descCateg']     := JConvUTF8((cAliasQry)->NRN_DESC)
		aExcTabHon[nIndJson]['valorAjuste']   := JConvUTF8(cValToChar((cAliasQry)->NV0_VALOR2))
		aExcTabHon[nIndJson]['valorAjustado'] := JConvUTF8(cValToChar(nValor3)) // NV0_VALOR3
		(cAliasQry)->(dbSkip())
	EndDo
	oExTabHon:Destroy()
	(cAliasQry)->(dbCloseArea())

Return aExcTabHon

//-------------------------------------------------------------------
/*/{Protheus.doc} GetExAtiv
Retorna dados das tabelas de exceção nas tabelas de honorarios da 
Atividade (OHR).

@param cFilCaso   - Filial do Caso
@param cCodClien  - Código do Cliente do Caso
@param cLojClien  - Loja do Cliente do Caso
@param cCasoClien - Código do Caso

@author Victor Hayashi
@since  10/11/2023
/*/
//-------------------------------------------------------------------
Static Function GetExAtiv(cFilCaso, cCodClien, cLojClien, cCasoClien)
Local aExcTabHon := JSonObject():New()// Array com as informações de exceção de tabela de honorarios
Local oExTabHon  := Nil // Objeto de query de exceção de tabela de honorarios
Local cQuery     := "" // Query da exceção de tabela de honorarios
Local cAliasQry  := GetNextAlias() // Alias para a query
Local nIndJson   := 0 // Indice do JSON
Local nParam     := 0 // Contador dos parametros de query

	cFilCaso   := Padr(cFilCaso  , TamSx3("NVE_FILIAL")[1])
	cCodClien  := Padr(cCodClien , TamSx3("NVE_CCLIEN")[1])
	cLojClien  := Padr(cLojClien , TamSx3("NVE_LCLIEN")[1])
	cCasoClien := Padr(cCasoClien, TamSx3("NVE_NUMCAS")[1])

	cQuery := " SELECT OHR.OHR_FILIAL,"
	cQuery +=        " OHR.OHR_COD,"
	cQuery +=        " OHR.OHR_AMINI,"
	cQuery +=        " OHR.OHR_AMFIM,"
	cQuery +=        " OHR.OHR_CATIVI,"
	cQuery +=        " NRC.NRC_DESC,"
	cQuery +=        " OHR.OHR_REGRA,"
	cQuery +=        " OHR.OHR_VALOR"
	cQuery +=   " FROM " + RetSqlNAme("OHR") + " OHR"
	cQuery +=  " INNER JOIN " + RetSqlNAme("NRC") + " NRC"
	cQuery +=     " ON NRC.NRC_FILIAL = ?"
	cQuery +=    " AND NRC.NRC_COD = OHR_CATIVI"
	cQuery +=    " AND NRC.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE OHR.OHR_FILIAL = ?"
	cQuery +=    " AND OHR.OHR_CCLIEN = ?"
	cQuery +=    " AND OHR.OHR_CLOJA = ?"
	cQuery +=    " AND OHR.OHR_CCASO = ?"
	cQuery +=    " AND OHR.D_E_L_E_T_ = ' '"
	cQuery +=  " ORDER BY OHR_FILIAL, OHR_CCLIEN, OHR_CLOJA, OHR_CCASO, OHR_CATIVI, OHR_AMINI, OHR_AMFIM"

	oExTabHon := FWPreparedStatement():New(cQuery)

	oExTabHon:SetString(++nParam, xFilial('NRC'))
	oExTabHon:SetString(++nParam, xFilial('OHR'))
	oExTabHon:SetString(++nParam, cCodClien)
	oExTabHon:SetString(++nParam, cLojClien)
	oExTabHon:SetString(++nParam, cCasoClien)

	cQuery := oExTabHon:GetFixQuery()
	MpSysOpenQuery(cQuery, cAliasQry)

	aExcTabHon := {}

	While ((cAliasQry)->(!Eof()))
		nIndJson++
		aAdd(aExcTabHon, JSonObject():New())

		aExcTabHon[nIndJson]['cChaveOHR']   := Encode64((cAliasQry)->(OHR_FILIAL+OHR_COD))
		aExcTabHon[nIndJson]['anoMesIni']   := JConvUTF8((cAliasQry)->OHR_AMINI)
		aExcTabHon[nIndJson]['anoMesFim']   := JConvUTF8((cAliasQry)->OHR_AMFIM)
		aExcTabHon[nIndJson]['codAtiv']     := JConvUTF8((cAliasQry)->OHR_CATIVI)
		aExcTabHon[nIndJson]['descAtiv']    := JConvUTF8((cAliasQry)->NRC_DESC)
		aExcTabHon[nIndJson]['regra']       := JConvUTF8((cAliasQry)->OHR_REGRA)
		aExcTabHon[nIndJson]['valorAjuste'] := JConvUTF8(cValToChar((cAliasQry)->OHR_VALOR))

		(cAliasQry)->(dbSkip())
	EndDo
	oExTabHon:Destroy()
	(cAliasQry)->(dbCloseArea())

Return aExcTabHon

//-------------------------------------------------------------------
/*/{Protheus.doc} GET GetSaldoLimDisp
Consulta saldo de limite disponível para o Caso.

@example GET -> http://127.0.0.1:9090/rest/WSPfsAppCaso/sldlimdisp
@param codigoCliente  - Cliente do Caso
@param lojaCliente    - Loja do Cliente do Caso
@param codigoCaso     - Código do Caso
@param valorLimite    -  Valor limite do Caso
@param valorUtilizado -  Valor utilizado do Caso
@param moedaLimite    -  Se tem moeda do limite do Caso (.T./.F.)

@author Reginaldo Borges
@since  21/11/2023
/*/
//-------------------------------------------------------------------
WSMethod GET GetSaldoLimDisp QUERYPARAM codigoCliente, lojaCliente, codigoCaso, valorLimite, valorUtilizado, moedaLimite WSREST WSPfsAppCaso
Local oResponse       := JSonObject():New()
Local cCliente        := self:codigoCliente
Local cLoja           := self:lojaCliente
Local cCaso           := self:codigoCaso
Local nValorLimite    := VAL(self:valorLimite)
Local nValorUtilizado := VAL(self:valorUtilizado)
Local lmoedaLimite    := self:moedaLimite

	oResponse := {}
	Aadd(oResponse, JsonObject():New())

	oResponse := JGtSldLimDisp(cCliente, cLoja, cCaso, nValorLimite, nValorUtilizado, lmoedaLimite)

	Self:SetResponse( FWJsonSerialize(oResponse, .F., .F., .T.) )
	oResponse:FromJSon("{}")
	oResponse := Nil

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JGtSldLimDisp
Consulta saldo de limite disponível para o Caso.

@param cCodClien     - Cliente do Caso
@param cLojClien  - Loja do Cliente do Caso
@param cCasoClien - Código do Caso
@param nValLimite    -  Valor limite do Caso
@param nValUtilizado -  Valor utilizado do Caso
@param lMoedaLim     -  Se tem moeda do limite do Caso (.T./.F.)

@author Reginaldo Borges
@since  22/11/2023
/*/
//-------------------------------------------------------------------
Static Function JGtSldLimDisp(cCodClien, cLojClien, cCasoClien, nValLimite, nValUtilizado, lMoedaLim)
Local nSaldo    := 0
Local oResponse := JsonObject():New()

	cCodClien  := Padr(cCodClien , TamSx3("NVE_CCLIEN")[1])
	cLojClien  := Padr(cLojClien , TamSx3("NVE_LCLIEN")[1])
	cCasoClien := Padr(cCasoClien, TamSx3("NVE_NUMCAS")[1])

	nSaldo := J201GSldCs(cCodClien, cLojClien, cCasoClien, '2', .F.,,nValLimite, nValUtilizado, lMoedaLim)
	oResponse['saldoLimite'] := JConvUTF8(cValToChar(nSaldo))

Return oResponse


//-------------------------------------------------------------------
/*/{Protheus.doc} GET GetHistRemanej
Retorna dados das tabelas de exceção nas tabelas de honorarios
(NUW, NV0, OHR)

@example GET -> http://127.0.0.1:9090/rest/WSPfsAppCaso/histremanja/{chaveCaso}
@param chaveCaso - Chave do Caso (Filial + Cliente + Loja + Caso)

@author Victor Hayashi
@since  03/11/2023
/*/
//-------------------------------------------------------------------
WSMethod GET GetHistRemanej PATHPARAM chaveCaso WSREST WSPfsAppCaso
Local oResponse  := JSonObject():New()
Local cChaveCaso := Decode64(Self:chaveCaso)
Local nTamFilial := TamSX3("NVE_FILIAL")[1]
Local nTamCodCli := TamSX3("NVE_CCLIEN")[1]
Local nTamCodLoj := TamSX3("NVE_LCLIEN")[1]
Local nTamCodCas := TamSX3("NVE_NUMCAS")[1]
Local cFilCaso   := Substr(cChaveCaso, 1, nTamFilial)
Local cCliente   := Substr(cChaveCaso, nTamFilial + 1, nTamCodCli)
Local cLoja      := Substr(cChaveCaso, nTamFilial + nTamCodCli + 1, nTamCodLoj)
Local cCaso      := Substr(cChaveCaso, nTamFilial + nTamCodCli + nTamCodLoj + 1, nTamCodCas)

	oResponse := {}
	Aadd(oResponse, JsonObject():New())

	oResponse := JGtHistRemaneja(cFilCaso, cCliente, cLoja, cCaso)

	Self:SetResponse( FWJsonSerialize(oResponse, .F., .F., .T.) )
	aSize(oResponse, 0)
	oResponse := Nil

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JGtHistRemaneja
Consulta Grid de historico de remanejamento do Caso do Cliente (NY1)

@param cFilCaso   - Filial do Caso
@param cCodClien  - Código do Cliente do Caso
@param cLojClien  - Loja do Cliente do Caso
@param cCasoClien - Código do Caso

@author Victor Hayashi
@since  21/11/2023
/*/
//-------------------------------------------------------------------
Static Function JGtHistRemaneja(cFilCaso, cCliente, cLoja, cCaso)
Local aHistRem  := {}
Local cQuery    := ""
Local cAliasQry := ""
Local nIndJson  := 0

	cFilCaso   := Padr(cFilCaso  , TamSx3("NVE_FILIAL")[1])
	cCodClien  := Padr(cCodClien , TamSx3("NVE_CCLIEN")[1])
	cLojClien  := Padr(cLojClien , TamSx3("NVE_LCLIEN")[1])
	cCasoClien := Padr(cCasoClien, TamSx3("NVE_NUMCAS")[1])

	cQuery := " SELECT NY1.NY1_FILIAL,"
	cQuery +=        " NY1.NY1_CCLIEN,"
	cQuery +=        " NY1.NY1_CLOJA,"
	cQuery +=        " SA1.A1_NOME,"
	cQuery +=        " NY1.NY1_CCASO,"
	cQuery +=        " NVE.NVE_CCLINV,"
	cQuery +=        " NVE.NVE_CLJNV,"
	cQuery +=        " CLINV.A1_NOME NOME_CLINV,"
	cQuery +=        " NY1.NY1_SEQ,"
	cQuery +=        " NY1.NY1_CPART,"
	cQuery +=        " RD0.RD0_SIGLA,"
	cQuery +=        " RD0.RD0_NOME,"
	cQuery +=        " NY1.NY1_DTREM,"
	cQuery +=        " NY1.NY1_PERINI,"
	cQuery +=        " NY1.NY1_PERFIM"
	cQuery +=   " FROM " + RetSqlNAme("NY1") + " NY1"
	cQuery +=  " INNER JOIN " + RetSqlNAme("SA1") + " SA1"
	cQuery +=     " ON SA1.A1_COD = NY1.NY1_CCLIEN"
	cQuery +=    " AND SA1.A1_LOJA = NY1.NY1_CLOJA"
	cQuery +=    " AND SA1.D_E_L_E_T_ = ' '"
	cQuery +=   " LEFT JOIN " + RetSqlNAme("RD0") + " RD0"
	cQuery +=     " ON RD0_FILIAL = ?"
	cQuery +=    " AND RD0.RD0_CODIGO = NY1.NY1_CPART"
	cQuery +=    " AND RD0.D_E_L_E_T_ = ' '"
	cQuery +=   " INNER JOIN " + RetSqlNAme("NVE") + " NVE"
	cQuery +=     " ON NVE.NVE_CCLIEN = NY1_CCLIEN"
	cQuery +=    " AND NVE.NVE_LCLIEN = NY1_CLOJA"
	cQuery +=    " AND NVE.NVE_NUMCAS = NY1_CCASO"
	cQuery +=    " AND NVE.D_E_L_E_T_ = ' '"
	cQuery +=   " LEFT JOIN " + RetSqlNAme("SA1") + "  CLINV"
	cQuery +=     " ON CLINV.A1_COD = NVE.NVE_CCLINV"
	cQuery +=    " AND CLINV.A1_LOJA = NVE.NVE_CLJNV"
	cQuery +=    " AND CLINV.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE NY1.NY1_FILIAL = ?"
	cQuery +=    " AND NY1.NY1_CCASO = ?"
	cQuery +=    " AND NY1.D_E_L_E_T_ = ' '"

	cAliasQry := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TcGenQry2( ,, cQuery, {xFilial("RD0"),cFilCaso, cCaso} ) , cAliasQry, .T., .F. )

	While ((cAliasQry)->(!Eof()))
		nIndJson++
		aAdd(aHistRem, JSonObject():New())

		aHistRem[nIndJson]['codigoCliente']     := JConvUTF8((cAliasQry)->NY1_CCLIEN)
		aHistRem[nIndJson]['lojaCliente']       := JConvUTF8((cAliasQry)->NY1_CLOJA)
		aHistRem[nIndJson]['nomeCliente']       := JConvUTF8((cAliasQry)->A1_NOME)
		aHistRem[nIndJson]['codigoCaso']        := JConvUTF8((cAliasQry)->NY1_CCASO)
		aHistRem[nIndJson]['codigoPartic']      := JConvUTF8((cAliasQry)->NY1_CPART)
		aHistRem[nIndJson]['nomePartic']        := JConvUTF8((cAliasQry)->RD0_NOME)
		aHistRem[nIndJson]['siglaPartic']       := JConvUTF8((cAliasQry)->RD0_SIGLA)
		aHistRem[nIndJson]['dataRemanejamento'] := JConvUTF8((cAliasQry)->NY1_DTREM)
		aHistRem[nIndJson]['periodoInicial']    := JConvUTF8((cAliasQry)->NY1_PERINI)
		aHistRem[nIndJson]['periodoFinal']      := JConvUTF8((cAliasQry)->NY1_PERFIM)
		aHistRem[nIndJson]['codCliNovo']        := JConvUTF8((cAliasQry)->NVE_CCLINV)
		aHistRem[nIndJson]['lojaCliNovo']       := JConvUTF8((cAliasQry)->NVE_CLJNV)
		aHistRem[nIndJson]['nomeCliNovo']       := JConvUTF8((cAliasQry)->NOME_CLINV)

		(cAliasQry)->(dbSkip())
	EndDo

	(cAliasQry)->(dbCloseArea())

Return aHistRem

//-------------------------------------------------------------------
/*/{Protheus.doc} GET GetTituloIdioma
Retorna dados daa tabela de título do caso por idioma (NT7)

@example GET -> http://127.0.0.1:9090/rest/WSPfsAppCaso/tituloporidioma/{chaveCaso}
@param chaveCaso - Chave do Caso (Filial + Cliente + Loja + Caso)

@author Jorge Martins
@since  07/12/2023
/*/
//-------------------------------------------------------------------
WSMethod GET GetTituloIdioma PATHPARAM chaveCaso WSREST WSPfsAppCaso
Local oResponse  := JSonObject():New()
Local cChaveCaso := Decode64(Self:chaveCaso)
Local nTamFilial := TamSX3("NVE_FILIAL")[1]
Local nTamCodCli := TamSX3("NVE_CCLIEN")[1]
Local nTamCodLoj := TamSX3("NVE_LCLIEN")[1]
Local nTamCodCas := TamSX3("NVE_NUMCAS")[1]
Local cFilCaso   := Substr(cChaveCaso, 1, nTamFilial)
Local cCliente   := Substr(cChaveCaso, nTamFilial + 1, nTamCodCli)
Local cLoja      := Substr(cChaveCaso, nTamFilial + nTamCodCli + 1, nTamCodLoj)
Local cCaso      := Substr(cChaveCaso, nTamFilial + nTamCodCli + nTamCodLoj + 1, nTamCodCas)

	oResponse := {}
	Aadd(oResponse, JsonObject():New())

	oResponse := JGtTitIdioma(cFilCaso, cCliente, cLoja, cCaso)

	Self:SetResponse( FWJsonSerialize(oResponse, .F., .F., .T.) )
	aSize(oResponse, 0)
	oResponse := Nil

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JGtTitIdioma
Consulta Grid de título do caso por idioma (NT7)

@param cFilCaso   - Filial do Caso
@param cCodClien  - Código do Cliente do Caso
@param cLojClien  - Loja do Cliente do Caso
@param cCasoClien - Código do Caso

@author Jorge Martins
@since  07/12/2023
/*/
//-------------------------------------------------------------------
Static Function JGtTitIdioma(cFilCaso, cCodClien, cLojClien, cCasoClien)
Local aTitIdioma := {}
Local cQuery     := ""
Local cAliasQry  := ""
Local nIndJson   := 0

	cFilCaso   := Padr(cFilCaso  , TamSx3("NVE_FILIAL")[1])
	cCodClien  := Padr(cCodClien , TamSx3("NVE_CCLIEN")[1])
	cLojClien  := Padr(cLojClien , TamSx3("NVE_LCLIEN")[1])
	cCasoClien := Padr(cCasoClien, TamSx3("NVE_NUMCAS")[1])

	cQuery := " SELECT NT7.NT7_FILIAL,"
	cQuery +=        " NT7.NT7_CCLIEN,"
	cQuery +=        " NT7.NT7_CLOJA,"
	cQuery +=        " NT7.NT7_CCASO,"
	cQuery +=        " NVE.NVE_TITULO,"
	cQuery +=        " NT7.NT7_CIDIOM,"
	cQuery +=        " NR1.NR1_DESC,"
	cQuery +=        " NT7.NT7_TITULO,"
	cQuery +=        " NT7.NT7_REV"
	cQuery +=   " FROM " + RetSqlName("NT7") + " NT7"
	cQuery +=   " LEFT JOIN " + RetSqlName("NR1") + " NR1"
	cQuery +=     " ON NR1.NR1_FILIAL = ?"
	cQuery +=    " AND NR1.NR1_COD = NT7.NT7_CIDIOM"
	cQuery +=    " AND NR1.D_E_L_E_T_ = ' '"
	cQuery +=   " INNER JOIN " + RetSqlName("NVE") + " NVE"
	cQuery +=     " ON NVE.NVE_FILIAL = NT7.NT7_FILIAL"
	cQuery +=    " AND NVE.NVE_CCLIEN = NT7.NT7_CCLIEN"
	cQuery +=    " AND NVE.NVE_LCLIEN = NT7.NT7_CLOJA"
	cQuery +=    " AND NVE.NVE_NUMCAS = NT7.NT7_CCASO"
	cQuery +=    " AND NVE.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE NT7.NT7_FILIAL = ?"
	cQuery +=    " AND NT7.NT7_CCLIEN = ?"
	cQuery +=    " AND NT7.NT7_CLOJA  = ?"
	cQuery +=    " AND NT7.NT7_CCASO  = ?"
	cQuery +=    " AND NT7.D_E_L_E_T_ = ' '"

	cAliasQry := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TcGenQry2( ,, cQuery, {xFilial("NR1"), cFilCaso, cCodClien, cLojClien, cCasoClien} ) , cAliasQry, .T., .F. )

	While ((cAliasQry)->(!Eof()))
		nIndJson++
		aAdd(aTitIdioma, JSonObject():New())

		aTitIdioma[nIndJson]['chaveNT7']          := Encode64((cAliasQry)->(NT7_FILIAL + NT7_CCLIEN + NT7_CLOJA + NT7_CCASO + NT7_CIDIOM))
		aTitIdioma[nIndJson]['codigoCliente']     := JConvUTF8((cAliasQry)->NT7_CCLIEN)
		aTitIdioma[nIndJson]['lojaCliente']       := JConvUTF8((cAliasQry)->NT7_CLOJA)
		aTitIdioma[nIndJson]['codigoCaso']        := JConvUTF8((cAliasQry)->NT7_CCASO)
		aTitIdioma[nIndJson]['tituloCaso']        := JConvUTF8((cAliasQry)->NVE_TITULO)
		aTitIdioma[nIndJson]['codigoIdioma']      := JConvUTF8((cAliasQry)->NT7_CIDIOM)
		aTitIdioma[nIndJson]['descricaoIdioma']   := JConvUTF8((cAliasQry)->NR1_DESC)
		aTitIdioma[nIndJson]['titulo']            := JConvUTF8((cAliasQry)->NT7_TITULO)
		aTitIdioma[nIndJson]['revisado']          := JConvUTF8((cAliasQry)->NT7_REV)

		(cAliasQry)->(dbSkip())
	EndDo

	(cAliasQry)->(dbCloseArea())

Return aTitIdioma

//-------------------------------------------------------------------
/*/{Protheus.doc} POST RevalorizarTS
Revaloriza os time sheets dos caso

@example POST -> http://127.0.0.1:9090/rest/WSPfsAppCaso/revalorizar

/*/
//-------------------------------------------------------------------
WSMETHOD POST RevalorizarTS WSREST WSPfsAppCaso
Local oResponse := JPOSTReval(Self:GetContent())
Local lRet      := oResponse <> Nil

	If lRet
		Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JPOSTReval
Revaloriza os time sheets dos caso

@param cBody - Body da requisição

@param oReval - Estrutura Json de mensagens de retorno

@author Jorge Martins
@since  07/12/2023
/*/
//-------------------------------------------------------------------
Static Function JPOSTReval(cBody)
Local oJsonBody    := JsonObject():New()
Local oReval       := JsonObject():New()

	oJsonBody:fromJson(cBody)

	If ValType(oJSonBody) == "J" .And. Len(oJSonBody["casos"]) > 0
		oReval["legenda"] := JRevLegend() // Estrutura de legendas
		oReval["casos"]   := JRevDados(oJSonBody) // Dados dos casos
	EndIf

Return oReval

//-------------------------------------------------------------------
/*/{Protheus.doc} JRevStsUni
Monta mensagem de revalorização quando o status de todas as 
revalorizações foi o mesmo

@param cStatus - Status da revalorização

@param aReval - Array com a estrutura Json de mensagens de retorno

@author Jorge Martins
@since  13/12/2023
/*/
//-------------------------------------------------------------------
Static Function JRevStsUni(cStatus)
Local cMensagem := ""
Local aReval    := {}

	// cStatus - Usada para identificar o tipo de mensagem que será apresentada no front
	If cStatus == "1"
		cMensagem := STR0031 // "Houve erro na revalorização dos Time Sheets dos casos selecionados."
	ElseIf cStatus == "2"
		cMensagem := STR0032 // "Não há dados para revalorização de Time Sheets dos casos selecionados."
	ElseIf cStatus == "3"
		cMensagem := STR0033 // "Time Sheets revalorizados com sucesso para os casos selecionados."
	ElseIf cStatus == "4"
		cMensagem := STR0034 // "Não foi possível revalorizar os Time Sheets dos casos selecionados devido a vínculo com pré-fatura em revisão."
	ElseIf cStatus == "5"
		cMensagem := STR0035 // "Não foi possível revalorizar os Time Sheets dos casos selecionados por falta de permissão para alterar e revalorizar os Time Sheets em Pré-Fatura."
	ElseIf cStatus == "6"
		cMensagem := STR0036 // "Não foi possível revalorizar os Time Sheets dos casos selecionados por falta de permissão para alterar e revalorizar os Time Sheets."
	ElseIf cStatus == "7"
		cMensagem := STR0043 // "Não é possivel revalorizar os Time Sheets dos casos devido a vínculo com pré-fatura."
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
	aReval[1]["caso"]     := ""
	aReval[1]["situacao"] := JConvUTF8(cMensagem)
	aReval[1]["legenda"]  := JConvUTF8(cLegenda)
	aReval[1]["status"]   := JConvUTF8(cStatus)

Return aReval

//-------------------------------------------------------------------
/*/{Protheus.doc} JRevDados
Monta estrutura do JSON com os dados da revalorização

@param oJSonBody - Corpo da requisição em formato JSON

@return aDados - Array com a estrutura JSON de dados dos casos

@author Jorge Martins
@since  14/12/2023
/*/
//-------------------------------------------------------------------
Static Function JRevDados(oJSonBody) // Dados dos casos
Local aArea        := GetArea()
Local aAreaNVE     := NVE->(GetArea())
Local aDados       := {}
Local nCaso        := 0
Local nIndReval    := 0
Local nTamFilial   := TamSX3("NVE_FILIAL")[1]
Local nTamCodCli   := TamSX3("NVE_CCLIEN")[1]
Local nTamCodLoj   := TamSX3("NVE_LCLIEN")[1]
Local nTamCodCas   := TamSX3("NVE_NUMCAS")[1]
Local cChaveCaso   := ""
Local cCliente     := ""
Local cLoja        := ""
Local cCaso        := ""
Local cMensagem    := ""
Local cStatus      := ""
Local cStatusBkp   := ""
Local cLegenda     := ""
Local lStatusUnico := .T.
Local lLojaAuto    := SuperGetMv("MV_JLOJAUT", .F., "2",) == '1' // Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)

	NVE->(DbSetOrder(1)) // NVE_FILIAL+NVE_CCLIEN+NVE_LCLIEN+NVE_NUMCAS

	For nCaso := 1 To Len(oJSonBody["casos"])
		cChaveCaso := Decode64(oJSonBody["casos"][nCaso]["pk"])
		
		If NVE->(dbSeek(cChaveCaso))
			cStatusBkp := cStatus
			cStatus    := ""
			cMensagem  := JA070REVAL(.T., .T., @cStatus)

			// Avalia se todos as revalorizações tiveram o mesmo Status de retorno
			If lStatusUnico
				lStatusUnico := Empty(cStatusBkp) .Or. cStatusBkp == cStatus
			EndIf

			If !Empty(cMensagem)
				cCliente := Substr(cChaveCaso, nTamFilial + 1, nTamCodCli)
				cLoja    := Substr(cChaveCaso, nTamFilial + nTamCodCli + 1, nTamCodLoj)
				cCaso    := Substr(cChaveCaso, nTamFilial + nTamCodCli + nTamCodLoj + 1, nTamCodCas)
				
				nIndReval++
				aAdd(aDados, JSonObject():New())

				// cLegenda
				// 1-Erro
				// 2-Informação (falta de dados ou validação)
				// 3-Sucesso

				// Para o FRONTEND, os status 4, 5 e 6 serão considerados como 2-Informação (falta de dados ou validação)
				cLegenda := IIf(cStatus $ "2|4|5|6", "2", cStatus)

				aDados[nIndReval]["cliente"]  := JConvUTF8(cCliente + IIf(!lLojaAuto, "/" + cLoja, ""))
				aDados[nIndReval]["caso"]     := JConvUTF8(cCaso)
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

	RestArea(aAreaNVE)
	RestArea(aArea)

Return aDados

//-------------------------------------------------------------------
/*/{Protheus.doc} JRevLegend
Monta estrutura do JSON com a legenda usada na tela de revalorização

@return aLegenda - Array com a estrutura Json de legenda

@author Jorge Martins
@since  14/12/2023
/*/
//-------------------------------------------------------------------
Static Function JRevLegend()
Local aLegenda := {}

	aAdd(aLegenda, JSonObject():New())
	aLegenda[1]["legenda"]  := JConvUTF8("1") // Erro
	aLegenda[1]["status"]   := JConvUTF8("1")
	aLegenda[1]["situacao"] := JConvUTF8(STR0037) // "Erro na revalorização dos Time Sheets dos casos"

	aAdd(aLegenda, JSonObject():New())
	aLegenda[2]["legenda"]  := JConvUTF8("2") // Informação
	aLegenda[2]["status"]   := JConvUTF8("2")
	aLegenda[2]["situacao"] := JConvUTF8(STR0038) // "Não há dados para revalorização de Time Sheets dos casos"

	aAdd(aLegenda, JSonObject():New())
	aLegenda[3]["legenda"]  := JConvUTF8("3") // Sucesso
	aLegenda[3]["status"]   := JConvUTF8("3") 
	aLegenda[3]["situacao"] := JConvUTF8(STR0039) // "Time Sheets revalorizados com sucesso dos casos"

	aAdd(aLegenda, JSonObject():New())
	aLegenda[4]["legenda"]  := JConvUTF8("2") // Informação
	aLegenda[4]["status"]   := JConvUTF8("4")
	aLegenda[4]["situacao"] := JConvUTF8(STR0040) // "Não foi possível revalorizar os Time Sheets dos casos devido a vínculo com pré-fatura em revisão"

	aAdd(aLegenda, JSonObject():New())
	aLegenda[5]["legenda"]  := JConvUTF8("2") // Informação
	aLegenda[5]["status"]   := JConvUTF8("5")
	aLegenda[5]["situacao"] := JConvUTF8(STR0041) // "Não foi possível revalorizar os Time Sheets dos casos por falta de permissão para alterar e revalorizar os Time Sheets em Pré-Fatura"

	aAdd(aLegenda, JSonObject():New())
	aLegenda[6]["legenda"]  := JConvUTF8("2") // Informação
	aLegenda[6]["status"]   := JConvUTF8("6")
	aLegenda[6]["situacao"] := JConvUTF8(STR0042) // "Não foi possível revalorizar os Time Sheets dos casos por falta de permissão para alterar e revalorizar os Time Sheets."

	aAdd(aLegenda, JSonObject():New())
	aLegenda[6]["legenda"]  := JConvUTF8("2") // Informação
	aLegenda[6]["status"]   := JConvUTF8("7")
	aLegenda[6]["situacao"] := JConvUTF8(STR0043) // "Não é possivel revalorizar os Time Sheets dos casos devido a vínculo com pré-fatura."

Return aLegenda

//-------------------------------------------------------------------
/*/{Protheus.doc} POST RemanejarCaso
Remanejamento de casos

@example POST -> http://127.0.0.1:9090/rest/WSPfsAppCaso/remanejar

/*/
//-------------------------------------------------------------------
WSMETHOD POST RemanejarCaso WSREST WSPfsAppCaso
Local oResponse := JPOSTReman(Self:GetContent())
Local lRet      := oResponse <> Nil

	If lRet
		Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JPOSTReman
Remanejamento de casos

@param cBody - Body da requisição

@param oRemanejar - Estrutura Json de retorno

@author Jorge Martins
@since  07/12/2023
/*/
//-------------------------------------------------------------------
Static Function JPOSTReman(cBody)
Local oJsonBody    := JsonObject():New()
Local oRemanejar   := JsonObject():New()

	oJsonBody:fromJson(cBody)

	If ValType(oJSonBody) == "J" .And. Len(oJSonBody["casos"]) > 0
		oRemanejar["legenda"] := JRemLegend() // Estrutura de legendas
		oRemanejar["casos"]   := JRemDados(oJSonBody) // Dados dos casos
	EndIf

Return oRemanejar

//-------------------------------------------------------------------
/*/{Protheus.doc} JRemLegend
Monta estrutura do JSON com a legenda usada na tela de remanejamento

@return aLegenda - Array com a estrutura Json de legenda

@author Jorge Martins
@since  14/12/2023
/*/
//-------------------------------------------------------------------
Static Function JRemLegend()
Local aLegenda := {}

	aAdd(aLegenda, JSonObject():New())
	aLegenda[1]["legenda"]  := JConvUTF8("1") // Erro
	aLegenda[1]["status"]   := JConvUTF8("1")
	aLegenda[1]["situacao"] := JConvUTF8("Erro no remanjamento dos casos") // "Erro no remanjamento dos casos"

	aAdd(aLegenda, JSonObject():New())
	aLegenda[2]["legenda"]  := JConvUTF8("3") // Sucesso
	aLegenda[2]["status"]   := JConvUTF8("2")
	aLegenda[2]["situacao"] := JConvUTF8("Remanejamento realizado com sucesso") // "Remanejamento realizado com sucesso"

	aAdd(aLegenda, JSonObject():New())
	aLegenda[3]["legenda"]  := JConvUTF8("2") // Informação
	aLegenda[3]["status"]   := JConvUTF8("3") 
	aLegenda[3]["situacao"] := JConvUTF8("Não é permitido remanejar casos definitivos para clientes provisórios.") // "Não é permitido remanejar casos definitivos para clientes provisórios."

	aAdd(aLegenda, JSonObject():New())
	aLegenda[4]["legenda"]  := JConvUTF8("2") // Informação
	aLegenda[4]["status"]   := JConvUTF8("4")
	aLegenda[4]["situacao"] := JConvUTF8("Não é possível remanejar o caso para mesmo cliente.") // "Não é possível remanejar o caso para mesmo cliente."

Return aLegenda

//-------------------------------------------------------------------
/*/{Protheus.doc} JRemDados
Monta estrutura do JSON com os dados do remanejamento

@param oJSonBody - Corpo da requisição em formato JSON

@return aDados - Array com a estrutura JSON de dados dos casos

@author Jorge Martins
@since  14/12/2023
/*/
//-------------------------------------------------------------------
Static Function JRemDados(oJSonBody)
Local aArea        := GetArea()
Local aAreaNVE     := NVE->(GetArea())
Local aDados       := {}
Local aInfoEbil    := {}
Local nCaso        := 0
Local nIndReman    := 0
Local nTamFilial   := TamSX3("NVE_FILIAL")[1]
Local nTamCodCli   := TamSX3("NVE_CCLIEN")[1]
Local nTamCodLoj   := TamSX3("NVE_LCLIEN")[1]
Local nTamCodCas   := TamSX3("NVE_NUMCAS")[1]
Local cChaveCaso   := ""
Local cCliente     := ""
Local cLoja        := ""
Local cCaso        := ""
Local cCliDest     := ""
Local cLojaDest    := ""
Local cMensagem    := ""
Local cStatus      := ""
Local cStatusBkp   := ""
Local cLegenda     := ""
Local lStatusUnico := .T.
Local lLojaAuto    := SuperGetMv("MV_JLOJAUT", .F., "2",) == '1' // Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)

	NVE->(DbSetOrder(1)) // NVE_FILIAL+NVE_CCLIEN+NVE_LCLIEN+NVE_NUMCAS

	If !Empty(oJsonBody:getJsonObject("ebilling"))
		aInfoEbil := {oJSonBody["ebilling"][1]["codFase"], oJSonBody["ebilling"][1]["codTaref"], oJSonBody["ebilling"][1]["codAtiv"]}
	EndIf

	For nCaso := 1 To Len(oJSonBody["casos"])
		cChaveCaso := Decode64(oJSonBody["casos"][nCaso]["pk"])
		
		If NVE->(dbSeek(cChaveCaso))

			cCliente  := Substr(cChaveCaso, nTamFilial + 1, nTamCodCli)
			cLoja     := Substr(cChaveCaso, nTamFilial + nTamCodCli + 1, nTamCodLoj)
			cCaso     := Substr(cChaveCaso, nTamFilial + nTamCodCli + nTamCodLoj + 1, nTamCodCas)
			cCliDest  := oJSonBody["casos"][nCaso]["clienteDestino"]
			cLojaDest := oJSonBody["casos"][nCaso]["lojaDestino"]

			cStatusBkp := cStatus
			cStatus    := ""

			aRet       := J063Remanj(cCliente, cLoja, cCaso, cCliDest, cLojaDest, Nil, .T., .T., @cStatus, aInfoEbil)

			// Avalia se todos os remanejamentos tiveram o mesmo Status de retorno
			If lStatusUnico
				lStatusUnico := Empty(cStatusBkp) .Or. cStatusBkp == cStatus
			EndIf

			cMensagem  := aRet[2]

			If !Empty(cMensagem)
				cCliente := Substr(cChaveCaso, nTamFilial + 1, nTamCodCli)
				cLoja    := Substr(cChaveCaso, nTamFilial + nTamCodCli + 1, nTamCodLoj)
				cCaso    := Substr(cChaveCaso, nTamFilial + nTamCodCli + nTamCodLoj + 1, nTamCodCas)
				
				nIndReman++
				aAdd(aDados, JSonObject():New())

				// cLegenda
				// 1-Erro
				// 2-Informação (falta de dados ou validação)
				// 3-Sucesso

				If cStatus $ "2" // Para o FRONTEND, o status 2 será considerado como 3-Sucesso
					cLegenda := "3"
				ElseIf cStatus $ "3|4" // Para o FRONTEND, os status 3 e 4 serão considerados como 2-Informação (falta de dados ou validação)
					cLegenda := "2"
				Else
					cLegenda := cStatus
				EndIf

				aDados[nIndReman]["cliente"]  := JConvUTF8(cCliente + IIf(!lLojaAuto, "/" + cLoja, ""))
				aDados[nIndReman]["caso"]     := JConvUTF8(cCaso)
				aDados[nIndReman]["situacao"] := JConvUTF8(cMensagem)
				aDados[nIndReman]["legenda"]  := JConvUTF8(cLegenda)
				aDados[nIndReman]["status"]   := JConvUTF8(cStatus)
			EndIf
		EndIf
	Next
	
	// Se em todas as execuções o status e mensagem foi a mesma o sistema apresentará uma mensagem única genérica, 
	// ao invés de gerar o log para todos os registros.
	// Exceto: 
	// - Erros, podem ter ocorridos erros diferentes entre os casos, e é importante lista-los.
	If Len(oJSonBody["casos"]) > 1 .And. lStatusUnico .And. cStatus <> "1"
		aDados := JRemStsUni(cStatus)
	EndIf

	RestArea(aAreaNVE)
	RestArea(aArea)

Return aDados

//-------------------------------------------------------------------
/*/{Protheus.doc} JRemStsUni
Monta mensagem de remanejamento quando o status de todas os 
remanejamentos foi o mesmo

@param cStatus - Status do remanejamento

@param aRemaneja - Array com a estrutura Json de mensagens de retorno

@author Jorge Martins
@since  13/12/2023
/*/
//-------------------------------------------------------------------
Static Function JRemStsUni(cStatus)
Local cMensagem := ""
Local aRemaneja := {}

	// cStatus - Usada para identificar o tipo de mensagem que será apresentada no front
	If cStatus == "2"
		cMensagem := "Casos remanejamentos com sucesso." // "Remanejamentos realizados com sucesso."
	ElseIf cStatus == "3"
		cMensagem := "Não foi possível remanejar os casos definitivos selecionados para clientes provisórios." // "Não foi possível remanejar os casos definitivos selecionados para clientes provisórios."
	ElseIf cStatus == "4"
		cMensagem := "Não foi possível remanejar os casos selecionados para o mesmo cliente." // "Não foi possível remanejar os casos selecionados para o mesmo cliente."
	EndIf

	// cLegenda
	// 1-Erro
	// 2-Informação (falta de dados ou validação)
	// 3-Sucesso

	If cStatus $ "2" // Para o FRONTEND, o status 2 será considerado como 3-Sucesso
		cLegenda := "3"
	ElseIf cStatus $ "3|4" // Para o FRONTEND, os status 3 e 4 serão considerados como 2-Informação (falta de dados ou validação)
		cLegenda := "2"
	Else
		cLegenda := cStatus
	EndIf

	aAdd(aRemaneja, JSonObject():New())
	aRemaneja[1]["cliente"]  := ""
	aRemaneja[1]["caso"]     := ""
	aRemaneja[1]["situacao"] := JConvUTF8(cMensagem)
	aRemaneja[1]["legenda"]  := JConvUTF8(cLegenda)
	aRemaneja[1]["status"]   := JConvUTF8(cStatus)

Return aRemaneja

//-------------------------------------------------------------------
/*/{Protheus.doc} GET GetValNUWNV0


@example GET -> http://127.0.0.1:9090/rest/WSPfsAppCaso/tituloporidioma/{chaveCaso}
@param chaveCaso - Chave do Caso (Filial + Cliente + Loja + Caso)

@author Victor Hayashi
@since  18/12/2023
/*/
//-------------------------------------------------------------------
WSMethod POST GetValNUWNV0 PATHPARAM chaveCaso QUERYPARAM entidade WSREST WSPfsAppCaso
Local oResponse  := JSonObject():New()
Local oJSonBody  := JsonObject():New()
Local cChaveCaso := Decode64(Self:chaveCaso)
Local cEntidade  := Self:entidade
Local nTamFilial := TamSX3("NVE_FILIAL")[1]
Local nTamCodCli := TamSX3("NVE_CCLIEN")[1]
Local nTamCodLoj := TamSX3("NVE_LCLIEN")[1]
Local nTamCodCas := TamSX3("NVE_NUMCAS")[1]
Local cFilCaso   := Substr(cChaveCaso, 1, nTamFilial)
Local cCliente   := Substr(cChaveCaso, nTamFilial + 1, nTamCodCli)
Local cLoja      := Substr(cChaveCaso, nTamFilial + nTamCodCli + 1, nTamCodLoj)
Local cCaso      := Substr(cChaveCaso, nTamFilial + nTamCodCli + nTamCodLoj + 1, nTamCodCas)
Local nValor1    := 0
Local nValor3    := 0
Local cBody      := StrTran(Self:GetContent(),CHR(10),"")
Local aCampos    := {}
Local aInfoApi   := {}

	oJSonBody:fromJson(cBody)
	aCampos := oJsonBody:getJsonObject("campos")

	oResponse := {}
	Aadd(oResponse, JsonObject():New())

	If cEntidade == "NUW"
		// NUW_VALOR1 - Valor Original
		aInfoApi := {aCampos[1]["amini"], aCampos[1]["amfim"], aCampos[1]["categ"], cFilCaso, cCliente, cLoja, cCaso }
		nValor1  := J70VlONUW(/*modelo*/, aInfoApi)

		// NUW_VALOR3 - Valor Ajustado
		aInfoApi := { nValor1, Val(aCampos[1]["valor"]), aCampos[1]["regra"], aCampos[1]["categ"], aCampos[1]["tabhon"], aCampos[1]["amini"], aCampos[1]["amfim"], ""/*NV0_EXCCAT*/, ""/*NUW_VALOR3*/}
		nValor3  := J70VLRAJUST("NUW" , /*modelo*/, aInfoApi)

	ElseIf cEntidade == "NV0"
		// NV0_VALOR1 - Valor Original
		aInfoApi := {cCliente, cLoja, cCaso, aCampos[1]["amini"], aCampos[1]["amfim"], aCampos[1]["part"], aCampos[1]["regra"], aCampos[1]["categ"], aCampos[1]["exccat"], Val(aCampos[1]["nuw_valor3"])}
		nValor1  := J70VlONV0(/*modelo*/, aInfoApi)

		// NV0_VALOR3 - Valor Ajustado
		aInfoApi := { nValor1, Val(aCampos[1]["valor"]), aCampos[1]["regra"], aCampos[1]["categ"], aCampos[1]["tabhon"], aCampos[1]["amini"], aCampos[1]["amfim"], aCampos[1]["exccat"], Val(aCampos[1]["nuw_valor3"])}
		nValor3  := J70VLRAJUST("NV0" , /*modelo*/, aInfoApi)
	EndIf

	oResponse[1]["valorOriginal"] := nValor1
	oResponse[1]["valorAjustado"] := nValor3

	Self:SetResponse( FWJsonSerialize(oResponse, .F., .F., .T.) )
	aSize(oResponse, 0)
	oResponse := Nil

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET NUTLt
Vincula casos a contratos

@example GET -> http://127.0.0.1:9090/rest/WSPfsAppCaso/vinccontrlot
@param chaveCaso - Chave do Caso (Filial + Cliente + Loja + Caso)

@author Victor Hayashi
@since  18/12/2023
/*/
//-------------------------------------------------------------------
WSMethod POST NUTLt WSREST WSPfsAppCaso
Local oJSonBody  := JsonObject():New()
Local oResponse  := JSonObject():New()
Local cBody      := StrTran(Self:GetContent(),CHR(10),"")
Local cMsg       := ""
Local cCaso      := ""
Local cCliente   := ""
Local cLoja      := ""
Local cSituac    := ""
Local cSitContr  := ""
Local nCaso      := 0
Local nContrato  := 0
Local nIndex     := 0
Local nTamClient := TamSX3("NVE_CCLIEN")[1]
Local aCasos     := {}
Local aContrs    := {}
Local aAreaNVE   := NVE->(GetArea())
Local oModel070  := Nil
Local oModelNUT  := Nil
Local lAtuSit    := .F.

	oJSonBody:fromJson(cBody)
	aCasos  := oJsonBody:getJsonObject("casos")
	aContrs := oJsonBody:getJsonObject("contratos")

	oResponse['info'] := {}

	For nCaso := 1 to Len(aCasos)
		cCliente   := aCasos[nCaso]["codCliente"] + Space(nTamClient - Len(aCasos[nCaso]["codCliente"]))
		cLoja      := aCasos[nCaso]["lojaCliente"]
		cCaso      := aCasos[nCaso]["numCaso"]

		For nContrato := 1 to Len(aContrs)
			lAtuSit   := .F.
			cSituac   := ""
			cMsg      := ""
			cSitContr := JurGetDados("NT0", 1, xFilial('NT0') + aContrs[nContrato]["codContr"], "NT0_SIT")
			aAdd(oResponse["info"], JsonObject():New())
			nIndex++

			// Posiciona no caso
			NVE->(dbSetOrder(1))
			If NVE->(dbSeek(xFilial("NVE") + cCliente + cLoja + cCaso))

				// Valida se o Caso vai ter sua situação alterada
				If NVE->NVE_SITCAD == '1' .And. cSitContr == '2'
					lAtuSit := .T.
				EndIf

				oModel070 := FWLoadModel("JURA070")
				oModel070:SetOperation(MODEL_OPERATION_UPDATE)
				oModel070:Activate()

				oModelNUT := oModel070:GetModel("NUTDETAIL")
				// Adiciona uma nova linha caso o modelo não esteja vazio
				If !oModelNUT:IsEmpty()
					oModelNUT:AddLine()
				EndIf

				// Realiza o vinculo do caso com o contrato
				oModelNUT:SetValue("NUT_CCONTR", aContrs[nContrato]["codContr"])
				oModelNUT:SetValue("NUT_CCLIEN", aCasos[nCaso]["codCliente"])
				oModelNUT:SetValue("NUT_CLOJA" , aCasos[nCaso]["lojaCliente"])
				oModelNUT:SetValue("NUT_CCASO" , aCasos[nCaso]["numCaso"])

				If oModel070:VldData() .And. oModel070:CommitData()
					If lAtuSit
						cMsg    := STR0051 // "Contrato vinculado com sucesso! A situação do caso foi alterada para Definitiva."
						cSituac := "2"
					Else
						cMsg := STR0049 // "Contrato vinculado com sucesso!"
						cSituac := "1"
					EndIf
				Else
					cMsg    := oModel070:GetErrorMessage()[06]
					cSituac := "3"
				EndIf

				oModel070:DeActivate()
			Else
				cMsg := STR0045 // "Caso não encontrado!"
				cSituac := "2"
			EndIf

			// Adiciona as mensagens no array
			oResponse["info"][nIndex]["codContr"]    := JConvUTF8(aContrs[nContrato]["codContr"])
			oResponse["info"][nIndex]["codCliente"]  := JConvUTF8(aCasos[nCaso]["codCliente"])
			oResponse["info"][nIndex]["lojaCliente"] := JConvUTF8(aCasos[nCaso]["lojaCliente"])
			oResponse["info"][nIndex]["numCaso"]     := JConvUTF8(aCasos[nCaso]["numCaso"])
			oResponse["info"][nIndex]["status"]      := JConvUTF8(cSituac) // Legenda 1=Sucesso;2=Informação;3=Erro
			oResponse["info"][nIndex]["mensagem"]    := JConvUTF8(cMsg)

		Next nContrato
	Next nCaso

	Self:SetResponse( FWJsonSerialize(oResponse, .F., .F., .T.) )
	oResponse := Nil
	RestArea(aAreaNVE)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET LsCaso

@example GET -> http://127.0.0.1:9090/rest/WSPfsAppCaso/listacaso

@param valorDig    - QueryParam - valor digitado pelo usuario para pesquisa
@param filtercpo   - QueryParam - indica os campos adicionais do filtro (obs mesma ordem dos valores em filterinfo)
@param filterinfo  - QueryParam - indica as informações adicionais para serem filtradas (obs mesma ordem dos valores em filtercpo)

@author Victor Hayashi
@since  01/02/2024
/*/
//-------------------------------------------------------------------
WSMethod GET LsCaso QUERYPARAM valorDig, filtercpo, filterinfo, pageSize WSREST WSPfsAppCaso
Local oResponse   := JSonObject():New() // Objeto JSON de retorno
Local oCaso    := Nil // Objeto de Query do caso
Local cSearchKey  := Self:valorDig // Valor digitado para busca de caso
Local cQuery      := "" // Armazena a query de casos
Local cAliasQry   := GetNextAlias() // Alias para a query
Local cTpDtBase   := AllTrim(Upper(TCGetDB())) // Tipo de database do sistema
Local aCpoFiltro  := Iif(Empty(Self:filtercpo), {}, StrToArray(Self:filtercpo, ",")) // Campos da clausula 'WHERE'
Local aInfFiltro  := Iif(Empty(Self:filterinfo), {}, StrToArray(Self:filterinfo, ",")) // Valores da clausula 'WHERE'
Local nPage       := Iif(Empty(Self:pageSize), 10, Val(Self:pageSize)) // Quantidade de registros que retornarão da api
Local nParam      := 0 // Contador para o Bind Parameters
Local nX          := 0 // Contador para o For
Local nIndJson    := 0 // Indice do Obj Json

	cQuery := " SELECT NVE.NVE_CCLIEN,"
	cQuery +=        " NVE.NVE_LCLIEN,"
	cQuery +=        " SA1.A1_NOME,"
	cQuery +=        " NVE.NVE_NUMCAS,"
	cQuery +=        " NVE.NVE_TITULO,"
	cQuery +=        " COALESCE(RD0SOC.RD0_CODIGO, ' ') CODIGOSOC,"
	cQuery +=        " COALESCE(RD0SOC.RD0_SIGLA, ' ') SIGLASOC,"
	cQuery +=        " COALESCE(RD0SOC.RD0_NOME, ' ') NOMESOC,"
	cQuery +=        " RD0REV.RD0_CODIGO CODIGOREV,"
	cQuery +=        " RD0REV.RD0_SIGLA SIGLAREV,"
	cQuery +=        " RD0REV.RD0_NOME NOMEREV,"
	cQuery +=        " NVE.NVE_SITUAC,"
	cQuery +=        " NVE.NVE_SITCAD"
	cQuery +=   " FROM " + RetSqlName("NVE") + " NVE"
	cQuery +=  " INNER JOIN " + RetSqlName("SA1") + " SA1"
	cQuery +=     " ON (SA1.A1_COD = NVE.NVE_CCLIEN"
	cQuery +=    " AND SA1.A1_LOJA = NVE.NVE_LCLIEN"
	cQuery +=    " AND SA1.D_E_L_E_T_ = ' ')"
	cQuery +=   " LEFT JOIN " + RetSqlName("RD0") + " RD0SOC"
	cQuery +=     " ON (RD0SOC.RD0_CODIGO = NVE.NVE_CPART5"
	cQuery +=    " AND RD0SOC.RD0_FILIAL = ?" // 1 - xFilial("RD0")
	cQuery +=    " AND RD0SOC.D_E_L_E_T_ = ' ' )"
	cQuery +=   " LEFT JOIN " + RetSqlName("RD0") + " RD0REV"
	cQuery +=     " ON (RD0REV.RD0_CODIGO = NVE.NVE_CPART1"
	cQuery +=    " AND RD0REV.RD0_FILIAL = ?" // 2 - xFilial("RD0")
	cQuery +=    " AND RD0REV.D_E_L_E_T_ = ' ' )"
	cQuery +=  " WHERE NVE.D_E_L_E_T_ = ' '"

	// Monta os filtros informados
	For nX := 1 to Len(aCpoFiltro)
		cQuery +=  " AND ? = ?" // 3 - Len(aCpoFiltro)
	Next nX

	// Pesquisa por valor digitado
	If !Empty(cSearchKey)
		cSearchKey := "%" + Lower(StrTran(JurLmpCpo( cSearchKey,.F. ),'#','')) + "%"

		cQuery += " AND ( LOWER(NVE_CCLIEN) LIKE ?"     // 4 - "%" + cSearchKey + "%"
		cQuery +=        " OR LOWER(NVE_LCLIEN) LIKE ?" // 5 - "%" + cSearchKey + "%"
		cQuery +=        " OR LOWER(NVE_NUMCAS) LIKE ?" // 6 - "%" + cSearchKey + "%"
		cQuery +=        " OR ? LIKE ?" // 7 - JurFormat("A1_NOME", .T.,.T.) | 8 - "%" + cSearchKey + "%"
		cQuery +=        " OR ? LIKE ?" // 9 - JurFormat("A1_NREDUZ" , .T.,.T.) | 10 - "%" + cSearchKey + "%"
		cQuery +=        " OR ? LIKE ?" // 11 - JurFormat("NVE_TITULO" , .T.,.T.) | 12 - "%" + cSearchKey + "%"
		cQuery +=        " OR ? LIKE ?" // 13 - JurFormat("NVE_CCLIEN||NVE_LCLIEN||NVE_NUMCAS", .T.,.T.) | 14 - "%" + cSearchKey + "%"
		cQuery += ")"
	EndIf

	cQuery +=  " ORDER BY SA1.A1_NOME, NVE.NVE_TITULO"

	oCaso := FWPreparedStatement():New(cQuery)

	oCaso:SetString(++nParam, xFilial("RD0"))
	oCaso:SetString(++nParam, xFilial("RD0"))

	// Aplica os filtros da requisição
	For nX := 1 To Len(aInfFiltro)
		oCaso:SetUnsafe(++nParam, aCpoFiltro[nX])
		oCaso:SetString(++nParam, aInfFiltro[nX])
	Next nX

	// Informações digitadas pelo usuario
	If !Empty(cSearchKey)
		oCaso:SetString(++nParam, cSearchKey) // LOWER(NVE_CCLIEN) 4 - "%" + cSearchKey + "%"
		oCaso:SetString(++nParam, cSearchKey) // LOWER(NVE_LCLIEN) 5 - "%" + cSearchKey + "%"
		oCaso:SetString(++nParam, cSearchKey) // LOWER(NVE_NUMCAS) 6 - "%" + cSearchKey + "%"
		oCaso:SetUnsafe(++nParam, JurFormat("A1_NOME", .T.,.T.)) // 7 - JurFormat("A1_NOME", .T.,.T.)
		oCaso:SetString(++nParam, cSearchKey) // 8 - "%" + cSearchKey + "%"
		oCaso:SetUnsafe(++nParam, JurFormat("A1_NREDUZ", .T.,.T.)) // 9 - JurFormat("A1_NREDUZ", .T.,.T.)
		oCaso:SetString(++nParam, cSearchKey) // 10 - "%" + cSearchKey + "%"
		oCaso:SetUnsafe(++nParam, JurFormat("NVE_TITULO", .T.,.T.)) // 11 - JurFormat("NVE_TITULO", .T.,.T.)
		oCaso:SetString(++nParam, cSearchKey) // 12 - "%" + cSearchKey + "%"

		If cTpDtBase == "ORACLE"
			oCaso:SetUnsafe(++nParam, JurFormat("NVE_CCLIEN||NVE_LCLIEN||NVE_NUMCAS", .T.,.T.)) // 13 - JurFormat("NVE_CCLIEN||NVE_LCLIEN||NVE_NUMCAS", .T.,.T.)
		ElseIf cTpDtBase == "MSSQL"
			oCaso:SetUnsafe(++nParam, JurFormat("NVE_CCLIEN+NVE_LCLIEN+NVE_NUMCAS", .T.,.T.)) // 13 - JurFormat("NVE_CCLIEN||NVE_LCLIEN||NVE_NUMCAS", .T.,.T.)
		EndIf
		oCaso:SetString(++nParam, cSearchKey) // 14 - "%" + cSearchKey + "%"
	EndIf

	cQuery := oCaso:GetFixQuery()

	MpSysOpenQuery(cQuery, cAliasQry)

	oResponse["casos"] := {}

	While !(cAliasQry)->(Eof()) .And. nIndJson < nPage
		nIndJson++
		aAdd(oResponse["casos"], JsonObject():New())

		oResponse["casos"][nIndJson]["codCliente"]   := JConvUTF8((cAliasQry)->NVE_CCLIEN)
		oResponse["casos"][nIndJson]["lojaCliente"]  := JConvUTF8((cAliasQry)->NVE_LCLIEN)
		oResponse["casos"][nIndJson]["nomeCliente"]  := JConvUTF8((cAliasQry)->A1_NOME)
		oResponse["casos"][nIndJson]["codCaso"]      := JConvUTF8((cAliasQry)->NVE_NUMCAS)
		oResponse["casos"][nIndJson]["tituloCaso"]   := JConvUTF8((cAliasQry)->NVE_TITULO)
		oResponse["casos"][nIndJson]["codSocio"]     := JConvUTF8((cAliasQry)->CODIGOSOC)
		oResponse["casos"][nIndJson]["siglaSocio"]   := JConvUTF8((cAliasQry)->SIGLASOC)
		oResponse["casos"][nIndJson]["nomeSocio"]    := JConvUTF8((cAliasQry)->NOMESOC)
		oResponse["casos"][nIndJson]["codRevisor"]   := JConvUTF8((cAliasQry)->CODIGOREV)
		oResponse["casos"][nIndJson]["siglaRevisor"] := JConvUTF8((cAliasQry)->SIGLAREV)
		oResponse["casos"][nIndJson]["nomeRevisor"]  := JConvUTF8((cAliasQry)->NOMEREV)
		oResponse["casos"][nIndJson]["situacao"]     := JConvUTF8((cAliasQry)->NVE_SITUAC)
		oResponse["casos"][nIndJson]["situCadastro"] := JConvUTF8((cAliasQry)->NVE_SITCAD)

		(cAliasQry)->(dbSkip())
	EndDo
	oCaso:Destroy(0)
	(cAliasQry)->(dbCloseArea())

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
	oResponse:FromJSon("{}")
	oResponse := Nil

Return .T.
