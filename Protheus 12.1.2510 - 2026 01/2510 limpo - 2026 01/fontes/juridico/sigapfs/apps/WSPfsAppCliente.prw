#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "WSPFSAPPCLIENTE.CH"

WSRESTFUL WSPfsAppCliente DESCRIPTION STR0001 //"Webservice App PFS - Clientes"
	WSDATA valorDig     AS STRING
	WSDATA filtFilial   AS STRING
	WSDATA pageSize     AS NUMBER
	WSDATA page         AS NUMBER
	WSDATA count        AS BOOLEAN
	WSDATA chaveCli     AS STRING
	WSDATA cnpj         AS STRING
	WSDATA idIndicador  AS STRING
	WSDATA entidade     AS STRING
	WSDATA filialLog    AS STRING
	WSDATA filialAnexo  AS STRING
	WSDATA empEbilling  AS STRING
	WSDATA formatEbil   AS STRING
	WSDATA filtraAtivo  AS STRING
	WSDATA perfil       AS STRING
	WSDATA filtercpo    AS STRING
	WSDATA filterinfo   AS STRING
	WSDATA getContat    AS STRING

	// Métodos GET
	WSMETHOD GET GrdCli              DESCRIPTION STR0002 PATH "grid"                           WSSYNTAX "grid"                           PRODUCES APPLICATION_JSON // "Retorna dados de Grid de Cliente"
	WSMETHOD GET GrdContatos         DESCRIPTION STR0003 PATH "contatos/{chaveCli}"            WSSYNTAX "contatos/{chaveCli}"            PRODUCES APPLICATION_JSON // "Retorna dados da Grid de Contatos do Cliente"
	WSMETHOD GET GrdCabParticipacao  DESCRIPTION STR0004 PATH "cabparticip/{chaveCli}"         WSSYNTAX "cabparticip/{chaveCli}"         PRODUCES APPLICATION_JSON // "Retorna dados da Grid de Participação do Cliente (NU9)"
	WSMETHOD GET GrdHstParticipacao  DESCRIPTION STR0005 PATH "hstparticip/{chaveCli}"         WSSYNTAX "hstparticip/{chaveCli}"         PRODUCES APPLICATION_JSON // "Retorna dados da Grid de Participação do Cliente (NUD)"
	WSMETHOD GET GrdAtDpNaoCobCli    DESCRIPTION STR0006 PATH "atdpnaocob/{chaveCli}"          WSSYNTAX "atdpnaocob/{chaveCli}"          PRODUCES APPLICATION_JSON // "Retorna dados da Grid de tipos de atividades e tipos de despesas não cobráveis do cliente"
	WSMETHOD GET GrdExcecaoTpAtiv    DESCRIPTION STR0007 PATH "exctipoatv/{chaveCli}"          WSSYNTAX "exctipoatv/{chaveCli}"          PRODUCES APPLICATION_JSON // "Retorna dados da Grid de exceção de tipo de atividade do cliente"
	WSMETHOD GET DadosCliCNPJ        DESCRIPTION STR0008 PATH "cnpj"                           WSSYNTAX "cnpj"                           PRODUCES APPLICATION_JSON // "Retorna dados de um cliente a partir do CNPJ"
	WSMETHOD GET VldEBilling         DESCRIPTION STR0011 PATH "vldebilling/{chaveCli}"         WSSYNTAX "vldebilling/{chaveCli}"         PRODUCES APPLICATION_JSON // "Verificar se há time sheets com os campos de fase e tarefa sem preenchimento"
	WSMETHOD GET lsCli               DESCRIPTION STR0015 PATH "listaCliente"                   WSSYNTAX "listaCliente"                   PRODUCES APPLICATION_JSON // "Busca a lista de clientes cadastrados"

	// Métodos POST
	WSMETHOD POST attTimeSheet       DESCRIPTION STR0012 PATH "atutimesheet"                   WSSYNTAX "atutimesheet"                   PRODUCES APPLICATION_JSON // "Atualiza as informações de Fase, Tarefa e Atividade dos time sheets pendentes"

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} GET GrdCli
Consulta de Grid de Clientes

@example GET -> http://127.0.0.1:9090/rest/WSPfsAppCliente

@param valorDig    - Valor digitado no campo
@param filtFilial  - Indica se filtra Filial com xFilial
@param page        - Numero da página
@param pagesize    - Quantidade de itens na página
@param count       - Indica se retorna a quantidade de clientes ao invés da lista de clientes
@param idIndicador - Indica o tipo de filtro que será feito, conforme o indicador
                     1 - Clientes e-billing
                     2 - Clientes abertos no mês
                     3 - Clientes inativados no mês
                     4 - Clientes provisórios

@author Willian Kazahaya
@since  14/08/2023
/*/
//-------------------------------------------------------------------
WSMETHOD GET GrdCli QUERYPARAM valorDig, filtFilial, page, pageSize, count, idIndicador WSREST WSPfsAppCliente
Local oResponse  := JSonObject():New()
Local oCliente   := Nil
Local aArea      := GetArea()
Local aFiliais   := UsrFilial()
Local cSearchKey := Self:valorDig
Local lFiltFil   := Self:filtFilial == 'true'
Local nPage      := Self:page
Local nPageSize  := Self:pageSize
Local lCount     := Self:count
Local cIdInd     := Self:idIndicador
Local cAliasCli  := ""
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
	aQuery    := JCliQry(cSearchKey, "" /*cCodigo*/, ""/*cLoja*/, lFiltFil, .T., .F., lCount, cIdInd, /*lAdcCPOs*/, /*cPerfil*/)
	cQuery    := ChangeQuery(aQuery[1])
	aParams   := aQuery[2]
	cAliasCli := GetNextAlias()
	
	oCliente := FWPreparedStatement():New(cQuery)
	
	For nParam := 1 To Len(aParams)
		If ValType(aParams[nParam]) == "C"
			oCliente:SetString(nParam, aParams[nParam])
		ElseIf ValType(aParams[nParam]) == "A"
			oCliente:SetIn(nParam, aParams[nParam])
		EndIf
	Next

	cQuery := oCliente:GetFixQuery()

	MpSysOpenQuery(cQuery, cAliasCli)
	
	If lCount 
		If !(cAliasCli)->(Eof())
			oResponse['total'] := (cAliasCli)->QTD_CLIENTES
		EndIf

	Else
		oResponse['cliente'] := {}

		// Monta o response
		While !(cAliasCli)->(Eof()) .And. nQtdReg < nQtdRegFim + 1
			nQtdReg++
			// Verifica se o registro está no range da pagina
			If (nQtdReg > nQtdRegIni .AND. nQtdReg <= nQtdRegFim)
				nIndexJSon++
				nIndFilSA1 := aScan(aFiliais, {|x| AllTrim((cAliasCli)->A1_FILIAL) $ x['filial'] })
				cFilSA1    := IIf(nIndFilSA1 == 0, cFilAnt, aFiliais[nIndFilSA1]['filial'])

				Aadd(oResponse['cliente'], JsonObject():New())
				oResponse['cliente'][nIndexJSon]['filialInterna']    := cFilSA1  // Não colocar o JConvUTF8 na filial pois ele corta o espaço vazio da filial no final da string.
				oResponse['cliente'][nIndexJSon]['filialDoRegistro'] := (cAliasCli)->A1_FILIAL
				oResponse['cliente'][nIndexJSon]['codigo']           := JConvUTF8((cAliasCli)->A1_COD + "/" + (cAliasCli)->A1_LOJA)
				oResponse['cliente'][nIndexJSon]['chave']            := Encode64((cAliasCli)->(A1_FILIAL) + (cAliasCli)->A1_COD + (cAliasCli)->A1_LOJA)
				oResponse['cliente'][nIndexJSon]['nome']             := JConvUTF8((cAliasCli)->(A1_NOME))
				oResponse['cliente'][nIndexJSon]['perfil']           := JConvUTF8((cAliasCli)->(NUH_PERFIL))
				oResponse['cliente'][nIndexJSon]['cpfcnpj']          := JConvUTF8((cAliasCli)->(A1_CGC))
				oResponse['cliente'][nIndexJSon]['tipoPessoa']       := JConvUTF8((cAliasCli)->(A1_PESSOA))
				oResponse['cliente'][nIndexJSon]['socioResponsavel'] := JConvUTF8((cAliasCli)->(RD0_SIGLA))
				oResponse['cliente'][nIndexJSon]['nomeSocio']        := JConvUTF8((cAliasCli)->(RD0_NOME))
				oResponse['cliente'][nIndexJSon]['situacao']         := JConvUTF8((cAliasCli)->(NUH_SITCAD))

				oResponse['cliente'][nIndexJSon]['contatos']         := JGtContat((cAliasCli)->(A1_FILIAL),  (cAliasCli)->A1_COD, (cAliasCli)->A1_LOJA )
				oResponse['cliente'][nIndexJSon]['cabparticip']      := JGtCabPart((cAliasCli)->(A1_FILIAL), (cAliasCli)->A1_COD, (cAliasCli)->A1_LOJA )
				oResponse['cliente'][nIndexJSon]['hstparticip']      := JGtHstPart((cAliasCli)->(A1_FILIAL), (cAliasCli)->A1_COD, (cAliasCli)->A1_LOJA )
				oResponse['cliente'][nIndexJSon]['atdpnaocob']       := JGtNCobCli((cAliasCli)->(A1_FILIAL), (cAliasCli)->A1_COD, (cAliasCli)->A1_LOJA )
				oResponse['cliente'][nIndexJSon]['exctipoatv']       := JGtExcTpAt((cAliasCli)->(A1_FILIAL), (cAliasCli)->A1_COD, (cAliasCli)->A1_LOJA )
				
			ElseIf (nQtdReg == nQtdRegFim + 1)
				lHasNext := .T.
			EndIf
			(cAliasCli)->(dbSkip())
		EndDo

		// Verifica se há uma proxima pagina
		oResponse['hasNext'] := lHasNext
		oResponse['hasNext'] := lHasNext
	EndIf

	(cAliasCli)->(dbCloseArea())
	Self:SetResponse( FWJsonSerialize(oResponse, .F., .F., .T.) )
	oResponse:fromJson("{}")
	oResponse := Nil

	JurFreeArr(@aQuery)
	JurFreeArr(@aParams)

	RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET GrdContatos
Consulta da Grid de Contatos do Cliente

@example GET -> http://127.0.0.1:9090/rest/WSPfsAppCliente/contatos/{chaveCli}
@param chaveCli - Chave do Cliente (Filial + Cliente + Loja)

@author reginaldo.borges
@since  31/08/2023
@version 1.0
/*/
//-------------------------------------------------------------------
WSMethod GET GrdContatos PATHPARAM chaveCli QUERYPARAM valorDig, filtraAtivo WSREST WSPfsAppCliente
Local oResponse  := JSonObject():New()
Local cChaveCli  := Decode64(Self:chaveCli)
Local nTamFilial := TamSX3("A1_FILIAL")[1]
Local nTamCodCli := TamSX3("A1_COD")[1]
Local nTamCodLoj := TamSX3("A1_LOJA")[1]
Local cFilCli    := xFilial("SA1")
Local cCliente   := Substr(cChaveCli, nTamFilial + 1, nTamCodCli)
Local cLoja      := Substr(cChaveCli, nTamFilial + nTamCodCli + 1, nTamCodLoj)
Local cSearchKey := Self:valorDig // Valor digitado para busca de caso
Local lFiltraAtv := Lower(Self:filtraAtivo) == 'true' // Filtra ativos

	oResponse := {}
	Aadd(oResponse, JsonObject():New())

	oResponse := JGtContat(cFilCli, cCliente, cLoja, cSearchKey, lFiltraAtv)

	Self:SetResponse( FWJsonSerialize(oResponse, .F., .F., .T.) )
	aSize(oResponse, 0)
	oResponse := Nil

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JCliQry
Monta a Query de Clientes

@param cSearchKey  - Valor digitado no campo
@param cCodigo     - Indica se filtra Filial com xFilial
@param cLoja       - Loja do Cliente
@param lFiltFil    - Indica se irá filtrar pela filial logada
@param lFilAdc     - Indica se terá o filtro adcional (sócio resp/cnpj/nomefantasia)
@param lFilAtivo   - Filtra os registros ativos
@param lCount      - Indica se a query vai apenas trazer a quantidade de registros
@param cIdInd      - Indica o tipo de filtro que será feito, conforme o indicador
                     1 - Clientes e-billing
                     2 - Clientes abertos no mês
                     3 - Clientes inativados no mês
                     4 - Clientes provisórios
@param lAdcCPOs    - Indica se trata campos adicionais na query.
@param cPerfil     - Se preenchido filtra pelo perfil do cliente 
                     1=Cliente/Pagador
                     2=Somente pagador

@return {cQuery, aParams} - cQuery - Query de busca dos clientes
                            aParams - Parâmetros para o FWPreparedStatement

@author Willian Kazahaya
@since  06/04/2020
/*/
//-------------------------------------------------------------------
Function JCliQry(cSearchKey, cCodigo, cLoja, lFiltFil, lFilAdc, lFilAtivo, lCount, cIdInd, lAdcCPOs, cPerfil)
Local cQuery      := ""
Local cQrySel     := ""
Local cQryFrm     := ""
Local cQryWhr     := ""
Local cQryOrd     := ""
Local cDtIni      := ""
Local cDtFim      := ""
Local nI          := 0
Local nQtd        := 0
Local aParams     := {}
Local aFilFilt    := EmpFilUsu("SA1")
Local lFilPerf    := .F.
Local cTpDtBase   :=  AllTrim(Upper(TCGetDB()))

Default cCodigo   := ""
Default cLoja     := ""
Default lFiltFil  := .F.
Default lFilAdc   := .F.
Default lFilAtivo := .T.
Default lCount    := .F.
Default lAdcCPOs  := .F.
Default cPerfil   := ""

	If lCount
		cQrySel += " SELECT COUNT(SA1.A1_COD) QTD_CLIENTES"
	ElseIf !lCount .And. !lAdcCPOs
		cQrySel += " SELECT SA1.A1_COD,"
		cQrySel +=        " SA1.A1_LOJA,"
		cQrySel +=        " SA1.A1_NOME,"
		cQrySel +=        " NUH.NUH_PERFIL,"
		cQrySel +=        " SA1.A1_CGC,"
		cQrySel +=        " SA1.A1_PESSOA,"
		cQrySel +=        " RD0.RD0_SIGLA,"
		cQrySel +=        " RD0.RD0_NOME,"
		cQrySel +=        " NUH.NUH_SITCAD,"
		cQrySel +=        " SA1.A1_FILIAL"
	ElseIf !lCount .And. lAdcCPOs
		cQrySel += " SELECT SA1.A1_COD,"
		cQrySel +=        " SA1.A1_LOJA,"
		cQrySel +=        " SA1.A1_NOME,"
		cQrySel +=        " RD0.RD0_SIGLA,"
		cQrySel +=        " RD0.RD0_NOME,"
		cQrySel +=        " NUH.NUH_CESCR2,"
		cQrySel +=        " NUH.NUH_CTABH,"
		cQrySel +=        " NUH.NUH_CIDIO,"
		cQrySel +=        " NUH.NUH_DSPDIS,"
		cQrySel +=        " NUH.NUH_UTEBIL,"
		cQrySel +=        " NUH.NUH_CPART,"
		cQrySel +=        " NUH.NUH_TPFECH,"
		cQrySel +=        " NUH.NUH_CEMP"
	EndIf
	cQryFrm +=   " FROM " + RetSqlName("SA1") + " SA1"
	cQryFrm +=  " INNER JOIN " + RetSqlName("NUH") + " NUH"
	cQryFrm +=     " ON (NUH.NUH_COD = SA1.A1_COD"
	cQryFrm +=    " AND NUH.NUH_LOJA = SA1.A1_LOJA"
	cQryFrm +=    " AND NUH.D_E_L_E_T_ = ' ')"
	cQryFrm +=  " INNER JOIN " + RetSqlName("RD0") + " RD0"
	cQryFrm +=     " ON ( RD0.RD0_CODIGO = NUH.NUH_CPART"
	cQryFrm +=    " AND RD0.RD0_FILIAL = ?" // xFilial("RD0")
	cQryFrm +=    " AND RD0.D_E_L_E_T_ = ' ' )"
	cQryWhr +=  " WHERE SA1.D_E_L_E_T_ = ' '"

	aAdd(aParams, xFilial("RD0"))

	If (lFilAtivo)
		cQryWhr +=    " AND NUH.NUH_ATIVO = '1'"
		cQryWhr +=    " AND SA1.A1_MSBLQL = '2'"
	EndIf

	// Filtra pelo perfil do cliente
	lFilPerf := !Empty(cPerfil)
	If (lFilPerf)
		cQryWhr +=    " AND NUH.NUH_PERFIL = ?"
		aAdd(aParams, cPerfil)
	EndIf

	If !lCount // Pro count não precisa fazer ORDER BY
		cQryOrd +=  " ORDER BY SA1.A1_NOME"
	EndIf

	If (lFiltFil)
		cQryWhr += " AND SA1.A1_FILIAL = ?" // FWxFilial("SA1")
		aAdd(aParams, FWxFilial("SA1"))
	Else
		// Inclui as filiais que o usuário tem permissão
		If Len(aFilFilt) > 0
			cQryWhr += " AND SA1.A1_FILIAL IN (?)" // aFilFilt
			aAdd(aParams, aFilFilt)
		EndIf
	EndIf

	// Pesquisa por valor digitado
	If !Empty(cSearchKey)
		cSearchKey := Lower(StrTran(JurLmpCpo( cSearchKey,.F. ),'#',''))
		
		cQryWhr += " AND ( LOWER(A1_COD) LIKE ?" // "%" + cSearchKey + "%"
		cQryWhr +=        " OR LOWER(A1_LOJA) LIKE ?" // "%" + cSearchKey + "%"
		cQryWhr +=        " OR " + JurFormat("A1_NOME", .T.,.T.) + " LIKE ?" // "%" + cSearchKey + "%"

		If cTpDtBase == "ORACLE"
			cQryWhr +=    " OR " + JurFormat("RTRIM(A1_COD)||A1_LOJA", .T.,.T.) + " LIKE ?" // "%" + cSearchKey + "%"
		ElseIf cTpDtBase == "MSSQL"
			cQryWhr +=    " OR " + JurFormat("RTRIM(A1_COD)+A1_LOJA", .T.,.T.) + " LIKE ?" // "%" + cSearchKey + "%"
		EndIf

		nQtd := 4
		
		If lFilAdc
			cQryWhr +=    " OR " + JurFormat("A1_NREDUZ", .T.,.T.) + " LIKE ?" // "%" + cSearchKey + "%"
			cQryWhr +=    " OR " + JurFormat("A1_CGC", .T.,.T.)    + " LIKE ?" // "%" + cSearchKey + "%"
			cQryWhr +=    " OR " + JurFormat("RD0_SIGLA", .T.,.T.) + " LIKE ?" // "%" + cSearchKey + "%"
			cQryWhr +=    " OR " + JurFormat("RD0_NOME", .T.,.T.)  + " LIKE ?" // "%" + cSearchKey + "%"

			nQtd += 4
		EndIf

		For nI := 1 To nQtd
			aAdd(aParams, "%" + cSearchKey + "%")
		Next

		cQryWhr += ")"
	EndIf

	// Filtro conforme o indicador
	If !Empty(cIdInd)
		cDtIni := DToS(FirstDay(Date())) // Primeiro dia do mês do período
		cDtFim := DToS(LastDay(Date()))  // Último dia do mês do período
		
		If cIdInd == "1" // 1 - Clientes e-billing
			cQryWhr += " AND (NUH.NUH_ATIVO = '1' AND NUH.NUH_CEMP <> ' ')"
		ElseIf cIdInd == "2" // 2 - Clientes abertos no mês
			cQryWhr += " AND (NUH.NUH_ATIVO = '1' AND SA1.A1_DTCAD BETWEEN ? AND ?)" // cDtIni e cDtFim
			aAdd(aParams, cDtIni)
			aAdd(aParams, cDtFim)
		ElseIf cIdInd == "3" // 3 - Clientes inativados no mês
			cQryWhr += " AND (NUH.NUH_DTENC BETWEEN ? AND ?)" // cDtIni e cDtFim
			aAdd(aParams, cDtIni)
			aAdd(aParams, cDtFim)
		ElseIf cIdInd == "4" // 4 - Clientes provisórios
			cQryWhr += " AND (NUH.NUH_SITCAD = '1')"
		EndIf
	EndIf

	// Pesquisa por código
	If !Empty(cCodigo)
		cQryWhr += " AND UPPER(A1_COD) = ?" // cCodigo
		cQryWhr += " AND UPPER(A1_LOJA) = ?" // cLoja
		aAdd(aParams, cCodigo)
		aAdd(aParams, cLoja)
	EndIf

	cQuery := cQrySel + cQryFrm + cQryWhr + cQryOrd

Return {cQuery, aParams}

//-------------------------------------------------------------------
/*/{Protheus.doc} JGtContat
Consulta de Grid de Clientes

@param cFilCli     - Filial do Cliente
@param cCodClien   - Código do cliente
@param cLojClien   - Loja do Cliente
@param cSearchKey  - Valor digitado para busca do contato (Codigo ou Nome)
@param lFiltraAtv  - Informa se filtra somente os registros ativos

@author Willian Kazahaya
@since  16/08/2020
/*/
//-------------------------------------------------------------------
Static Function JGtContat(cFilCli, cCodClien, cLojClien, cSearchKey, lFiltraAtv)
Local aContatos := {}
Local cQuery    := ""
Local cAliasQry := ""
Local cIndJson  := 0
Local nParam    := 0
Local oContato  := Nil // Objeto de Query do caso

	cFilCli   := Padr(cFilCli,TamSx3("A1_FILIAL")[1])
	cCodClien := Padr(cCodClien,TamSx3("A1_COD")[1])
	cLojClien := Padr(cLojClien,TamSx3("A1_LOJA")[1])

	cQuery := " SELECT SU5.U5_FILIAL,"
	cQuery +=        " SU5.U5_CODCONT,"
	cQuery +=        " SU5.U5_CONTAT,"
	cQuery +=        " SU5.U5_END,"
	cQuery +=        " SU5.U5_BAIRRO,"
	cQuery +=        " SU5.U5_MUN,"
	cQuery +=        " SU5.U5_CEP,"
	cQuery +=        " SU5.U5_DDD,"
	cQuery +=        " SU5.U5_FCOM1,"
	cQuery +=        " SU5.U5_FCOM2,"
	cQuery +=        " SU5.U5_CELULAR,"
	cQuery +=        " SU5.U5_EMAIL,"
	cQuery +=        " SU5.U5_ATIVO"
	cQuery +=   " FROM " + RetSqlName("AC8") + " AC8"
	cQuery +=  " INNER JOIN " + RetSqlName("SU5") + " SU5"
	cQuery +=     " ON (SU5.U5_FILIAL  = AC8.AC8_FILIAL"
	cQuery +=    " AND SU5.U5_CODCONT = AC8.AC8_CODCON"
	If lFiltraAtv
		cQuery +=    " AND SU5.U5_ATIVO = '1'"
	EndIf
	cQuery +=    " AND SU5.D_E_L_E_T_ = ' ')"
	cQuery +=  " WHERE AC8.AC8_FILIAL = ?"
	cQuery +=    " AND AC8.AC8_CODENT = ?"
	cQuery +=    " AND AC8.D_E_L_E_T_ = ' '"

	// Informações digitadas pelo usuario
	If !Empty(cSearchKey)
		cQuery +=    " AND( U5_CODCONT LIKE ?"
		cQuery +=    " OR ? LIKE ?)"
	EndIf

	oContato := FWPreparedStatement():New(cQuery)

	oContato:SetString(++nParam, cFilCli)
	oContato:SetString(++nParam, cCodClien + cLojClien)

	// Informações digitadas pelo usuario
	If !Empty(cSearchKey)
		cSearchKey := "%" + Lower(StrTran(JurLmpCpo( cSearchKey,.F. ),'#','')) + "%"
		oContato:SetString(++nParam, cSearchKey) // U5_CODCONT
		oContato:SetUnsafe(++nParam, JurFormat("U5_CONTAT", .T.,.T.)) 
		oContato:SetString(++nParam, cSearchKey) // U5_CONTAT
	EndIf

	cAliasQry := GetNextAlias()
	cQuery := oContato:GetFixQuery()

	MpSysOpenQuery(cQuery, cAliasQry)

	While ((cAliasQry)->(!Eof()))
		cIndJson++
		aAdd(aContatos, JSonObject():New())

		aContatos[cIndJson]['chaveSU5']    := Encode64((cAliasQry)->(U5_FILIAL) + (cAliasQry)->U5_CODCONT)
		aContatos[cIndJson]['codigo']      := JConvUTF8((cAliasQry)->U5_CODCONT)
		aContatos[cIndJson]['nome']        := JConvUTF8((cAliasQry)->U5_CONTAT)
		aContatos[cIndJson]['endereco']    := JConvUTF8((cAliasQry)->U5_END)
		aContatos[cIndJson]['bairro']      := JConvUTF8((cAliasQry)->U5_BAIRRO)
		aContatos[cIndJson]['municipio']   := JConvUTF8((cAliasQry)->U5_MUN)
		aContatos[cIndJson]['cep']         := JConvUTF8((cAliasQry)->U5_CEP)
		aContatos[cIndJson]['ddd']         := JConvUTF8((cAliasQry)->U5_DDD)
		aContatos[cIndJson]['foneCom1']    := JConvUTF8((cAliasQry)->U5_FCOM1)
		aContatos[cIndJson]['foneCom2']    := JConvUTF8((cAliasQry)->U5_FCOM2)
		aContatos[cIndJson]['foneCelular'] := JConvUTF8((cAliasQry)->U5_CELULAR)
		aContatos[cIndJson]['email']       := JConvUTF8((cAliasQry)->U5_EMAIL)
		aContatos[cIndJson]['ativo']       := JConvUTF8((cAliasQry)->U5_ATIVO)
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())

Return aContatos

//-------------------------------------------------------------------
/*/{Protheus.doc} GET GrdCabParticipacao
Consulta da Grid de Participação do Cliente (NU9)

@example GET -> http://127.0.0.1:9090/rest/WSPfsAppCliente/cabparticip/{chaveCli}
@param chaveCli - Chave do Cliente (Filial + Cliente + Loja)

@author Jorge Martins
@since  01/09/2023
/*/
//-------------------------------------------------------------------
WSMethod GET GrdCabParticipacao PATHPARAM chaveCli WSREST WSPfsAppCliente
Local oResponse  := JSonObject():New()
Local cChaveCli  := Decode64(Self:chaveCli)
Local nTamFilial := TamSX3("A1_FILIAL")[1]
Local nTamCodCli := TamSX3("A1_COD")[1]
Local nTamCodLoj := TamSX3("A1_LOJA")[1]
Local cFilCli    := Substr(cChaveCli, 1, nTamFilial)
Local cCliente   := Substr(cChaveCli, nTamFilial + 1, nTamCodCli)
Local cLoja      := Substr(cChaveCli, nTamFilial + nTamCodCli + 1, nTamCodLoj)

	oResponse := {}
	Aadd(oResponse, JsonObject():New())

	oResponse := JGtCabPart(cFilCli, cCliente, cLoja)

	Self:SetResponse( FWJsonSerialize(oResponse, .F., .F., .T.) )
	aSize(oResponse, 0)
	oResponse := Nil

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JGtCabPart
Consulta de Grid Participação de Clientes (NU9)

@param cFilCli     - Filial do Cliente
@param cCodClien   - Código do cliente
@param cLojClien   - Loja do Cliente

@author Jorge Martins
@since  01/09/2023
/*/
//-------------------------------------------------------------------
Static Function JGtCabPart(cFilCli, cCodClien, cLojClien)
Local aParticip := {}
Local cQuery    := ""
Local cAliasQry := ""
Local cIndJson  := 0

	cFilCli   := Padr(cFilCli,TamSx3("A1_FILIAL")[1])
	cCodClien := Padr(cCodClien,TamSx3("A1_COD")[1])
	cLojClien := Padr(cLojClien,TamSx3("A1_LOJA")[1])

	cQuery := " SELECT NU9.NU9_FILIAL,"
	cQuery +=        " NU9.NU9_COD,"
	cQuery +=        " NU9.NU9_CPART,"
	cQuery +=        " NU9.NU9_CCLIEN,"
	cQuery +=        " NU9.NU9_CLOJA,"
	cQuery +=        " NU9.NU9_CTIPO,"
	cQuery +=        " NU9.NU9_PERC,"
	cQuery +=        " NU9.NU9_DTINI,"
	cQuery +=        " NU9.NU9_DTFIM,"
	cQuery +=        " RD0.RD0_SIGLA,"
	cQuery +=        " RD0.RD0_NOME,"
	cQuery +=        " NRI.NRI_DESC"
	cQuery +=   " FROM " + RetSqlName("NU9") + " NU9"
	cQuery +=  " INNER JOIN " + RetSqlName("RD0") + " RD0"
	cQuery +=     " ON RD0.RD0_FILIAL = ?"
	cQuery +=    " AND RD0.RD0_CODIGO = NU9.NU9_CPART"
	cQuery +=    " AND RD0.D_E_L_E_T_ = ' '"
	cQuery +=  " INNER JOIN " + RetSqlName("NRI") + " NRI"
	cQuery +=     " ON NRI.NRI_FILIAL = ?"
	cQuery +=    " AND NRI.NRI_COD = NU9.NU9_CTIPO"
	cQuery +=    " AND NRI.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE NU9.NU9_FILIAL = ?"
	cQuery +=    " AND NU9.NU9_CCLIEN = ?"
	cQuery +=    " AND NU9.NU9_CLOJA = ?"
	cQuery +=    " AND NU9.D_E_L_E_T_ = ' '"
	cQuery +=  " ORDER BY NU9.NU9_CPART, NU9.NU9_CTIPO"

	cAliasQry := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TcGenQry2( ,, cQuery, {xFilial("RD0"), xFilial("NRI"), xFilial("NU9"), cCodClien, cLojClien} ) , cAliasQry, .T., .F. )

	While ((cAliasQry)->(!Eof()))
		cIndJson++
		aAdd(aParticip, JSonObject():New())

		aParticip[cIndJson]['chaveNU9']          := Encode64((cAliasQry)->NU9_FILIAL + (cAliasQry)->NU9_CCLIEN + (cAliasQry)->NU9_CLOJA + (cAliasQry)->NU9_CPART + (cAliasQry)->NU9_CTIPO)
		aParticip[cIndJson]['codigo']            := JConvUTF8((cAliasQry)->NU9_COD)
		aParticip[cIndJson]['cliente']           := JConvUTF8((cAliasQry)->NU9_CCLIEN)
		aParticip[cIndJson]['loja']              := JConvUTF8((cAliasQry)->NU9_CLOJA)
		aParticip[cIndJson]['codparticipante']   := JConvUTF8((cAliasQry)->NU9_CPART)
		aParticip[cIndJson]['siglaparticipante'] := JConvUTF8((cAliasQry)->RD0_SIGLA)
		aParticip[cIndJson]['nomeparticipante']  := JConvUTF8((cAliasQry)->RD0_NOME)
		aParticip[cIndJson]['codtipoorig']       := JConvUTF8((cAliasQry)->NU9_CTIPO)
		aParticip[cIndJson]['desctipoorig']      := JConvUTF8((cAliasQry)->NRI_DESC)
		aParticip[cIndJson]['percentual']        := JConvUTF8(cValToChar((cAliasQry)->NU9_PERC))
		aParticip[cIndJson]['dataini']           := JConvUTF8((cAliasQry)->NU9_DTINI)
		aParticip[cIndJson]['datafim']           := JConvUTF8((cAliasQry)->NU9_DTFIM)
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())

Return aParticip

//-------------------------------------------------------------------
/*/{Protheus.doc} GET GrdHstParticipacao
Consulta da Grid Histórico de Participação do Cliente (NUD)

@example GET -> http://127.0.0.1:9090/rest/WSPfsAppCliente/hstparticip/{chaveCli}
@param chaveCli - Chave do Cliente (Filial + Cliente + Loja)

@author Jorge Martins
@since  01/09/2023
/*/
//-------------------------------------------------------------------
WSMethod GET GrdHstParticipacao PATHPARAM chaveCli WSREST WSPfsAppCliente
Local oResponse  := JSonObject():New()
Local cChaveCli  := Decode64(Self:chaveCli)
Local nTamFilial := TamSX3("A1_FILIAL")[1]
Local nTamCodCli := TamSX3("A1_COD")[1]
Local nTamCodLoj := TamSX3("A1_LOJA")[1]
Local cFilCli    := Substr(cChaveCli, 1, nTamFilial)
Local cCliente   := Substr(cChaveCli, nTamFilial + 1, nTamCodCli)
Local cLoja      := Substr(cChaveCli, nTamFilial + nTamCodCli + 1, nTamCodLoj)

	oResponse := {}
	Aadd(oResponse, JsonObject():New())

	oResponse := JGtHstPart(cFilCli, cCliente, cLoja)

	Self:SetResponse( FWJsonSerialize(oResponse, .F., .F., .T.) )
	aSize(oResponse, 0)
	oResponse := Nil

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JGtHstPart
Consulta de Grid de Histórico de Participação de Clientes (NUD)

@param cFilCli     - Filial do Cliente
@param cCodClien   - Código do cliente
@param cLojClien   - Loja do Cliente

@author Jorge Martins
@since  01/09/2023
/*/
//-------------------------------------------------------------------
Static Function JGtHstPart(cFilCli, cCodClien, cLojClien)
Local aParticip := {}
Local cQuery    := ""
Local cAliasQry := ""
Local cIndJson  := 0

	cFilCli   := Padr(cFilCli,TamSx3("A1_FILIAL")[1])
	cCodClien := Padr(cCodClien,TamSx3("A1_COD")[1])
	cLojClien := Padr(cLojClien,TamSx3("A1_LOJA")[1])

	cQuery := " SELECT NUD.NUD_FILIAL,"
	cQuery +=        " NUD.NUD_CPARTI,"
	cQuery +=        " NUD.NUD_AMINI,"
	cQuery +=        " NUD.NUD_AMFIM,"
	cQuery +=        " NUD.NUD_CCLIEN,"
	cQuery +=        " NUD.NUD_CLOJA,"
	cQuery +=        " NUD.NUD_CPART,"
	cQuery +=        " NUD.NUD_CTPORI,"
	cQuery +=        " NUD.NUD_PERC,"
	cQuery +=        " NUD.NUD_COD,"
	cQuery +=        " NUD.NUD_DTINI,"
	cQuery +=        " NUD.NUD_DTFIM,"
	cQuery +=        " RD0.RD0_SIGLA,"
	cQuery +=        " RD0.RD0_NOME,"
	cQuery +=        " NRI.NRI_DESC"
	cQuery +=   " FROM " + RetSqlName("NUD") + " NUD"
	cQuery +=  " INNER JOIN " + RetSqlName("RD0") + " RD0"
	cQuery +=     " ON RD0.RD0_FILIAL = ?"
	cQuery +=    " AND RD0.RD0_CODIGO = NUD.NUD_CPART"
	cQuery +=    " AND RD0.D_E_L_E_T_ = ' '"
	cQuery +=  " INNER JOIN " + RetSqlName("NRI") + " NRI"
	cQuery +=     " ON NRI.NRI_FILIAL = ?"
	cQuery +=    " AND NRI.NRI_COD = NUD.NUD_CTPORI"
	cQuery +=    " AND NRI.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE NUD.NUD_FILIAL = ?"
	cQuery +=    " AND NUD.NUD_CCLIEN = ?"
	cQuery +=    " AND NUD.NUD_CLOJA = ?"
	cQuery +=    " AND NUD.D_E_L_E_T_ = ' '"
	cQuery +=  " ORDER BY NUD.NUD_AMINI DESC, NUD.NUD_CTPORI DESC, RD0.RD0_SIGLA DESC"

	cAliasQry := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TcGenQry2( ,, cQuery, {xFilial("RD0"), xFilial("NRI"), xFilial("NUD"), cCodClien, cLojClien} ) , cAliasQry, .T., .F. )

	While ((cAliasQry)->(!Eof()))
		cIndJson++
		aAdd(aParticip, JSonObject():New())

		aParticip[cIndJson]['chaveNUD']          := Encode64((cAliasQry)->NUD_FILIAL + (cAliasQry)->NUD_CCLIEN + (cAliasQry)->NUD_CLOJA + (cAliasQry)->NUD_CPART + (cAliasQry)->NUD_CTPORI + (cAliasQry)->NUD_AMINI + (cAliasQry)->NUD_AMFIM)
		aParticip[cIndJson]['codigo']            := JConvUTF8((cAliasQry)->NUD_CPARTI)
		aParticip[cIndJson]['cliente']           := JConvUTF8((cAliasQry)->NUD_CCLIEN)
		aParticip[cIndJson]['loja']              := JConvUTF8((cAliasQry)->NUD_CLOJA)
		aParticip[cIndJson]['codparticipante']   := JConvUTF8((cAliasQry)->NUD_CPART)
		aParticip[cIndJson]['siglaparticipante'] := JConvUTF8((cAliasQry)->RD0_SIGLA)
		aParticip[cIndJson]['nomeparticipante']  := JConvUTF8((cAliasQry)->RD0_NOME)
		aParticip[cIndJson]['codtipoorig']       := JConvUTF8((cAliasQry)->NUD_CTPORI)
		aParticip[cIndJson]['desctipoorig']      := JConvUTF8((cAliasQry)->NRI_DESC)
		aParticip[cIndJson]['percentual']        := JConvUTF8(cValToChar((cAliasQry)->NUD_PERC))
		aParticip[cIndJson]['anomesini']         := JConvUTF8((cAliasQry)->NUD_AMINI)
		aParticip[cIndJson]['anomesfim']         := JConvUTF8((cAliasQry)->NUD_AMFIM)
		aParticip[cIndJson]['dataini']           := JConvUTF8((cAliasQry)->NUD_DTINI)
		aParticip[cIndJson]['datafim']           := JConvUTF8((cAliasQry)->NUD_DTFIM)
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())

Return aParticip

//-------------------------------------------------------------------
/*/{Protheus.doc} GET GrdAtDpNaoCobCli
Consulta de Grid de tipos de atividades e tipos de despesas não cobráveis (NUB e NUC)

@example GET -> http://127.0.0.1:9090/rest/WSPfsAppCliente/atdpnaocob/{chaveCli}
@param chaveCli - Chave do Cliente (Filial + Cliente + Loja)

@author Jorge Martins
@since  01/09/2023
/*/
//-------------------------------------------------------------------
WSMethod GET GrdAtDpNaoCobCli PATHPARAM chaveCli WSREST WSPfsAppCliente
Local oResponse  := JSonObject():New()
Local cChaveCli  := Decode64(Self:chaveCli)
Local nTamFilial := TamSX3("A1_FILIAL")[1]
Local nTamCodCli := TamSX3("A1_COD")[1]
Local nTamCodLoj := TamSX3("A1_LOJA")[1]
Local cFilCli    := Substr(cChaveCli, 1, nTamFilial)
Local cCliente   := Substr(cChaveCli, nTamFilial + 1, nTamCodCli)
Local cLoja      := Substr(cChaveCli, nTamFilial + nTamCodCli + 1, nTamCodLoj)

	oResponse := {}
	Aadd(oResponse, JsonObject():New())

	oResponse := JGtNCobCli(cFilCli, cCliente, cLoja)

	Self:SetResponse( FWJsonSerialize(oResponse, .F., .F., .T.) )
	aSize(oResponse, 0)
	oResponse := Nil

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JGtNCobCli
Consulta de Grid de tipos de atividades e tipos de despesas não cobráveis

@param cFilCli     - Filial do Cliente
@param cCodClien   - Código do cliente
@param cLojClien   - Loja do Cliente

@author Jorge Martins
@since  01/09/2023
/*/
//-------------------------------------------------------------------
Static Function JGtNCobCli(cFilCli, cCodClien, cLojClien)
Local aTpAtDpNCob := {}
Local cQuery      := ""
Local cAliasQry   := ""
Local nIndJson    := 0

	cFilCli   := Padr(cFilCli,TamSx3("A1_FILIAL")[1])
	cCodClien := Padr(cCodClien,TamSx3("A1_COD")[1])
	cLojClien := Padr(cLojClien,TamSx3("A1_LOJA")[1])

	cQuery := " SELECT * FROM ("
	cQuery +=        " SELECT '1' TIPO, NUB.NUB_FILIAL FILIAL, NUB.NUB_CCLIEN CLIENTE, NUB.NUB_CLOJA LOJA, NUB_CTPATI CODTPATIDES, NRC_DESC DESTPATIDES"
	cQuery +=          " FROM " + RetSqlName("NUB") + " NUB"
	cQuery +=         " INNER JOIN " + RetSqlName("NRC") + " NRC"
	cQuery +=            " ON NRC.NRC_FILIAL = NUB.NUB_FILIAL "
	cQuery +=           " AND NRC.NRC_COD = NUB.NUB_CTPATI "
	cQuery +=           " AND NRC.NRC_ATIVO = '1' "
	cQuery +=           " AND NRC.D_E_L_E_T_ = ' ' "
	cQuery +=         " WHERE NUB.NUB_FILIAL = ?"
	cQuery +=           " AND NUB.NUB_CCLIEN = ?"
	cQuery +=           " AND NUB.NUB_CLOJA = ?"
	cQuery +=           " AND NUB.D_E_L_E_T_ = ' '"
	cQuery +=         " UNION ALL "
	cQuery +=        " SELECT '2' TIPO, NUC.NUC_FILIAL FILIAL, NUC.NUC_CCLIEN CLIENTE, NUC.NUC_CLOJA LOJA, NUC_CTPDES CODTPATIDES, NRH_DESC DESTPATIDES"
	cQuery +=          " FROM " + RetSqlName("NUC") + " NUC"
	cQuery +=         " INNER JOIN " + RetSqlName("NRH") + " NRH"
	cQuery +=            " ON NRH.NRH_FILIAL = NUC.NUC_FILIAL "
	cQuery +=           " AND NRH.NRH_COD = NUC.NUC_CTPDES "
	cQuery +=           " AND NRH.NRH_ATIVO = '1' "
	cQuery +=           " AND NRH.D_E_L_E_T_ = ' ' "
	cQuery +=         " WHERE NUC.NUC_FILIAL = ?"
	cQuery +=           " AND NUC.NUC_CCLIEN = ?"
	cQuery +=           " AND NUC.NUC_CLOJA = ?"
	cQuery +=           " AND NUC.D_E_L_E_T_ = ' ' ) A"

	cAliasQry := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TcGenQry2(,, cQuery, {cFilCli, cCodClien, cLojClien, cFilCli, cCodClien, cLojClien}), cAliasQry, .T., .F. )

	While ((cAliasQry)->(!Eof()))
		nIndJson++
		aAdd(aTpAtDpNCob, JSonObject():New())

		aTpAtDpNCob[nIndJson]['chaveNUBNUC']       := Encode64((cAliasQry)->FILIAL + (cAliasQry)->CLIENTE + (cAliasQry)->LOJA + (cAliasQry)->CODTPATIDES)
		aTpAtDpNCob[nIndJson]['cliente']           := JConvUTF8((cAliasQry)->CLIENTE)
		aTpAtDpNCob[nIndJson]['loja']              := JConvUTF8((cAliasQry)->LOJA)
		aTpAtDpNCob[nIndJson]['tipo']              := JConvUTF8((cAliasQry)->TIPO)
		aTpAtDpNCob[nIndJson]['codtpativdesp']     := JConvUTF8((cAliasQry)->CODTPATIDES)
		aTpAtDpNCob[nIndJson]['destpativdesp']     := JConvUTF8((cAliasQry)->DESTPATIDES)
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())

Return aTpAtDpNCob

//-------------------------------------------------------------------
/*/{Protheus.doc} GET GrdExcecaoTpAtiv
Consulta de Grid de tipos de exceção de valor hora por tipo de atividade

@example GET -> http://127.0.0.1:9090/rest/WSPfsAppCliente/exctipoatv/{chaveCli}
@param chaveCli - Chave do Cliente (Filial + Cliente + Loja)

@author Jorge Martins
@since  01/09/2023
/*/
//-------------------------------------------------------------------
WSMethod GET GrdExcecaoTpAtiv PATHPARAM chaveCli WSREST WSPfsAppCliente
Local oResponse  := JSonObject():New()
Local cChaveCli  := Decode64(Self:chaveCli)
Local nTamFilial := TamSX3("A1_FILIAL")[1]
Local nTamCodCli := TamSX3("A1_COD")[1]
Local nTamCodLoj := TamSX3("A1_LOJA")[1]
Local cFilCli    := Substr(cChaveCli, 1, nTamFilial)
Local cCliente   := Substr(cChaveCli, nTamFilial + 1, nTamCodCli)
Local cLoja      := Substr(cChaveCli, nTamFilial + nTamCodCli + 1, nTamCodLoj)

	oResponse := {}
	Aadd(oResponse, JsonObject():New())

	oResponse := JGtExcTpAt(cFilCli, cCliente, cLoja)

	Self:SetResponse( FWJsonSerialize(oResponse, .F., .F., .T.) )
	aSize(oResponse, 0)
	oResponse := Nil

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JGtExcTpAt
Consulta de Grid de tipos de atividades e tipos de despesas não cobráveis

@param cFilCli     - Filial do Cliente
@param cCodClien   - Código do cliente
@param cLojClien   - Loja do Cliente

@author Jorge Martins
@since  01/09/2023
/*/
//-------------------------------------------------------------------
Static Function JGtExcTpAt(cFilCli, cCodClien, cLojClien)
Local aExcTpAt  := {}
Local cQuery    := ""
Local cAliasQry := ""
Local nIndJson  := 0

	cFilCli   := Padr(cFilCli,TamSx3("A1_FILIAL")[1])
	cCodClien := Padr(cCodClien,TamSx3("A1_COD")[1])
	cLojClien := Padr(cLojClien,TamSx3("A1_LOJA")[1])

	cQuery := " SELECT OHO.OHO_FILIAL,"
	cQuery +=        " OHO.OHO_COD,"
	cQuery +=        " OHO.OHO_CCLIEN,"
	cQuery +=        " OHO.OHO_CLOJA,"
	cQuery +=        " OHO.OHO_AMINI,"
	cQuery +=        " OHO.OHO_AMFIM,"
	cQuery +=        " OHO.OHO_CATIVI,"
	cQuery +=        " OHO.OHO_REGRA,"
	cQuery +=        " OHO.OHO_VALOR,"
	cQuery +=        " NRC.NRC_DESC"
	cQuery +=   " FROM " + RetSqlName("OHO") + " OHO"
	cQuery +=  " INNER JOIN " + RetSqlName("NRC") + " NRC"
	cQuery +=     " ON NRC.NRC_FILIAL = OHO.OHO_FILIAL "
	cQuery +=    " AND NRC.NRC_COD = OHO.OHO_CATIVI "
	cQuery +=    " AND NRC.D_E_L_E_T_ = ' ' "
	cQuery +=  " WHERE OHO.OHO_FILIAL = ?"
	cQuery +=    " AND OHO.OHO_CCLIEN = ?"
	cQuery +=    " AND OHO.OHO_CLOJA = ?"
	cQuery +=    " AND OHO.D_E_L_E_T_ = ' '"
	cQuery +=  " ORDER BY OHO.OHO_AMINI DESC, OHO.OHO_CATIVI DESC"

	cAliasQry := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TcGenQry2(,, cQuery, {cFilCli, cCodClien, cLojClien}), cAliasQry, .T., .F. )

	While ((cAliasQry)->(!Eof()))
		nIndJson++
		aAdd(aExcTpAt, JSonObject():New())

		aExcTpAt[nIndJson]['chaveOHO']    := Encode64((cAliasQry)->OHO_FILIAL + (cAliasQry)->OHO_CCLIEN + (cAliasQry)->OHO_CLOJA + (cAliasQry)->OHO_CATIVI + (cAliasQry)->OHO_COD + (cAliasQry)->OHO_AMINI)
		aExcTpAt[nIndJson]['cliente']     := JConvUTF8((cAliasQry)->OHO_CCLIEN)
		aExcTpAt[nIndJson]['loja']        := JConvUTF8((cAliasQry)->OHO_CLOJA)
		aExcTpAt[nIndJson]['anomesini']   := JConvUTF8((cAliasQry)->OHO_AMINI)
		aExcTpAt[nIndJson]['anomesfim']   := JConvUTF8((cAliasQry)->OHO_AMFIM)
		aExcTpAt[nIndJson]['codtipoativ'] := JConvUTF8((cAliasQry)->OHO_CATIVI)
		aExcTpAt[nIndJson]['destipoativ'] := JConvUTF8((cAliasQry)->NRC_DESC)
		aExcTpAt[nIndJson]['regra']       := JConvUTF8((cAliasQry)->OHO_REGRA)
		aExcTpAt[nIndJson]['valor']       := JConvUTF8(cValToChar((cAliasQry)->OHO_VALOR))

		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())

Return aExcTpAt

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
/*/{Protheus.doc} EmpFilUsu(cEntidade)
Retorna o array de Empresa/Filial que o usuário logado tem permissão

@Param cEntidade - Entidade a ser consultada a filial

@author Willian Kazahaya
@since 06/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function EmpFilUsu(cEntidade)
Local aFiliais     := FWLoadSM0()
Local aFilUsu      := {}
Local aCompTab     := {}
Local nI           := 0
Local nY           := 0
Local cFilEntida   := ""

Default cEntidade  := ""

	If !Empty(cEntidade)
		aAdd(aCompTab, FWModeAccess(cEntidade,1)) // Empresa
		aAdd(aCompTab, FWModeAccess(cEntidade,2)) // Unidade
		aAdd(aCompTab, FWModeAccess(cEntidade,3)) // Filial
	EndIf

	For nI := 1 To Len(aFiliais)
		If (aFiliais[nI][11]) // Verifica se o usuário tem acesso. No LoadSM0 ele pega o usuário logado
			cFilEntida := ""
			If (aScan(aCompTab, "C") > 0) // Realiza tratamento no compartilhamento da tabela
				For nY := 1 To Len(aCompTab)
					If (aCompTab[nY] == "C")
						cFilEntida += Space(Len(aFiliais[nI][2+nY]))
					Else
						cFilEntida += aFiliais[nI][2+nY]
					EndIf
				Next nY
			Else
				cFilEntida := aFiliais[nI][3] + aFiliais[nI][4] + aFiliais[nI][5]
			EndIf

			If (aScan(aFilUsu, cFilEntida) == 0)
				aAdd(aFilUsu, cFilEntida)
			EndIf
		EndIf
	Next nI

Return aFilUsu

//-------------------------------------------------------------------
/*/{Protheus.doc} GET DadosCliCNPJ
Busca dados do cliente a partir do CNPJ informado

@example GET -> http://127.0.0.1:9090/rest/WSPfsAppCliente/CNPJ

@param cnpj - CNPJ do cliente

@return lRet - .T. - Indica se foram encontrados os dados do cliente

@author Jorge Martins
@since  28/09/2023
/*/
//-------------------------------------------------------------------
WSMethod GET DadosCliCNPJ QUERYPARAM cnpj WSREST WSPfsAppCliente
Local oResponse := {}
Local aResponse := {}
Local lRet      := .T.
Local cCNPJ     := IIf(Empty(Self:cnpj), "", StrTran(JurLmpCpo(Self:cnpj), '#', ""))

	Aadd(oResponse, JsonObject():New())

	aResponse := JAPICNPJ(cCNPJ)
	lRet      := aResponse[1]
	oResponse := aResponse[2]

	Self:SetResponse( FWJsonSerialize(oResponse, .F., .F., .T.) )
	aSize(oResponse, 0)
	oResponse := Nil

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JAPICNPJ
Busca dados do cliente na API da função APIForCli a partir do CNPJ informado

@param cCNPJ - Filial do Cliente

@return {lRet, aCliente} - lRet - .T. - Indica se foram encontrados os dados do cliente
                         - aCliente - Dados com as informações localizadas

@author Jorge Martins
@since  28/09/2023
/*/
//-------------------------------------------------------------------
Static Function JAPICNPJ(cCNPJ)
Local aRetJson := {}
Local aRet     := {}
Local aCliente := {}
Local oRest    := Nil
Local oRetJson := Nil
Local lRet     := .T.

	If !(FindFunction('APIForCli'))
		lRet := setRespError(400, STR0009) // "Função APIForCli não compilada no RPO"
	Else

		aRetJson := APIForCli(cCNPJ) // Realiza o POST de consulta CNPJ na API da Carol
		oRest    := JsonObject():New()
		oRest:FromJson(aRetJson[2])
		aRet     := oRest:GetJsonObject("hits")

		If ValType(aRet) == "U" .OR. Len(aRet) == 0
			aAdd(aCliente, JSonObject():New())
			lRet := .F.
			aCliente[1]['mensagem'] := JConvUTF8(STR0010) // "Dados não encontrados"
		Else
			If !(aRetJson[1])
				lRet := .F.
				aAdd(aCliente, JSonObject():New())
				aCliente[1]['mensagem'] := JConvUTF8(STR0010) // "Dados não encontrados"
			Else
				oRetJson := oRest["hits"][1]["mdmGoldenFieldAndValues"]
				aCliente := JGetCli(oRetJson, cCNPJ)
			EndIf
		EndIf
	EndIf

Return {lRet, aCliente}

//-------------------------------------------------------------------
/*/{Protheus.doc} JGetCli
Trata dados dados do cliente a partir do CNPJ informado e retorna
em formato resumido

@param oRetJson  - JSON com os dados do cliente identificados na API da função APIForCli
@param cCNPJ     - Filial do Cliente

@return aCliente - aCliente - Dados com as informações localizadas

@author Jorge Martins
@since  28/09/2023
/*/
//-------------------------------------------------------------------
Static Function JGetCli(oRetJson, cCNPJ)
Local aTel         := {}
Local aCliente     := {}
Local cComplemento := Iif(oRetJson["mdmaddress"][1]["mdmaddress2"] != NIL, Capital(oRetJson["mdmaddress"][1]["mdmaddress2"]), "")
Local cUFBrasil    := 'AC|AL|AM|AP|BA|CE|DF|ES|GO|MA|MG|MS|MT|PA|PB|PE|PI|PR|RJ|RN|RO|RR|RS|SC|SE|SP|TO'

	aAdd(aCliente, JSonObject():New())

	aCliente[1]['cgc']          := JConvUTF8(cCNPJ)
	aCliente[1]['nome']         := JConvUTF8(Iif(oRetJson["mdmname"]  != NIL, oRetJson["mdmname"], ""))
	aCliente[1]['nomeFantasia'] := JConvUTF8(Iif(oRetJson["mdmdba"]   != NIL, oRetJson["mdmdba"] , ""))
	aCliente[1]['cnae']         := JConvUTF8(Iif(oRetJson["cnaebr"]   != NIL, oRetJson["cnaebr"] , ""))
	aCliente[1]['tipoPessoa']   := JConvUTF8(Iif(oRetJson["mdmtaxid"] != NIL, Iif(Len(AllTrim(oRetJson["mdmtaxid"])) == 11, "F", "J"), "J"))

	aCliente[1]['cep']          := JConvUTF8(Iif(oRetJson["mdmaddress"][1]["mdmzipcode"]  != NIL, oRetJson["mdmaddress"][1]["mdmzipcode"] , ""))
	aCliente[1]['endereco']     := JConvUTF8(Iif(oRetJson["mdmaddress"][1]["mdmaddress1"] != NIL, Capital(oRetJson["mdmaddress"][1]["mdmaddress1"]), ""))
	aCliente[1]['complemento']  := JConvUTF8(JTrataComp(cComplemento))
	aCliente[1]['bairro']       := JConvUTF8(Iif(oRetJson["mdmaddress"][1]["mdmaddress3"] != NIL, Capital(oRetJson["mdmaddress"][1]["mdmaddress3"]), ""))
	aCliente[1]['estado']       := JConvUTF8(Iif(oRetJson["mdmaddress"][1]["mdmstate"]    != NIL, oRetJson["mdmaddress"][1]["mdmstate"]   , ""))
	aCliente[1]['municipio']    := JConvUTF8(Iif(oRetJson["mdmaddress"][1]["mdmcity"]     != NIL, Capital(oRetJson["mdmaddress"][1]["mdmcity"]), ""))
	aCliente[1]['pais']         := JConvUTF8(Iif(oRetJson["mdmaddress"][1]["mdmstate"]    != NIL, Iif(AllTrim(oRetJson["mdmaddress"][1]["mdmstate"]) $ cUFBrasil, "105", ""), ""))

	If (oRetJson["mdmphone"][2]["mdmphonenumber"] != Nil) .And. (!Empty(oRetJson["mdmphone"][2]["mdmphonenumber"])) 
		If FindFunction("RemDddTel")
			aTel := RemDddTel( oRetJson["mdmphone"][2]["mdmphonenumber"] )
			aCliente[1]['telefone'] := JConvUTF8(Iif(Len(aTel) == 3 .And. !Empty(aTel[1]), aTel[1], ""))
			aCliente[1]['ddd']      := JConvUTF8(Iif(Len(aTel) == 3 .And. !Empty(aTel[2]), aTel[2], ""))
			aCliente[1]['ddi']      := JConvUTF8(Iif(Len(aTel) == 3 .And. !Empty(aTel[3]), aTel[3], ""))
		Else
			aCliente[1]['telefone'] := JConvUTF8(oRetJson["mdmphone"][2]["mdmphonenumber"])
			aCliente[1]['ddd']      := JConvUTF8("")
			aCliente[1]['ddi']      := JConvUTF8("")
		EndIf
	Else
		aCliente[1]['telefone'] := JConvUTF8("")
		aCliente[1]['ddd']      := JConvUTF8("")
		aCliente[1]['ddi']      := JConvUTF8("")
	EndIf

Return aCliente

//-----------------------------------------------------------------
/*/{Protheus.doc} JTrataComp
Trata o complemento recebido pela API da Carol, tirando espaços
e separando os tipos de complemento com traço (-).

Ex: 
- Antes : "CONJ  ABC                 BLOCO A                   COND  EXEMPLO"
- Depois: "CONJ ABC - BLOCO A - COND EXEMPLO"

@param cComplemento - Complemento para tratamento

@return cComplemento - Complemento ajustado

@author Jorge Martins
@since  03/10/2023
/*/
//-----------------------------------------------------------------
Static Function JTrataComp(cComplemento)

	If !Empty(cComplemento)
		While (At("   ", cComplemento)) > 0
			cComplemento := StrTran(cComplemento, "   ", " - ")
		End

		While (At(" -  - ", cComplemento)) > 0
			cComplemento := StrTran(cComplemento, " -  - ", " - ")
		End

		While (At(" - - ", cComplemento)) > 0
			cComplemento := StrTran(cComplemento, " - - ", " - ")
		End

		While (At("  ", cComplemento)) > 0
			cComplemento := StrTran(cComplemento, "  ", " ")
		End
	EndIf

Return cComplemento

//-----------------------------------------------------------------
/*/{Protheus.doc} setRespError
Padroniza a resposta sempre convertendo o texto para UTF-8

@param nCodHttp    - Código HTTP
@param cErrMessage - Mensagem de erro a ser convertido

@author Willian Kazahaya
@since  20/03/2020
/*/
//-----------------------------------------------------------------
Static Function setRespError(nCodHttp, cErrMessage)
	SetRestFault(nCodHttp, JConvUTF8(cErrMessage), .T.)
Return .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET VldEBilling
Verifica se tem algum timesheet pendente sem as informações de ebilling
e também retorna as informações de padrões (Atividade, tarefa e fase) e
documento ebilling.

@example GET -> http://127.0.0.1:9090/rest/WSPFSAPPCLIENTE/vldebilling/{chaveCli}

@param cChaveCli   - PathParam  - Chave do cliente (SA1 - A1_COD + A1_LOJA)
@param empEbilling - QueryParam - Codigo da empresa Ebilling (NUH_CEMP)
@param formatEbil  - QueryParam - Formato do Ebilling (NUH_FORMEB)

@author Victor Hayashi
@since  03/10/2023
/*/
//-------------------------------------------------------------------
WSMethod GET VldEBilling PATHPARAM chaveCli QUERYPARAM empEbilling, formatEbil WSREST WSPfsAppCliente
Local oResponse    := JSonObject():New()
Local cChaveCli    := Decode64(Self:chaveCli)
Local cEmpEbil     := IIf(Empty(Self:empEbilling), "", self:empEbilling)
Local cUtiEbil     := Iif(Empty(cEmpEbil), "2", "1")
Local cFormEbil    := IIf(Empty(Self:formatEbil), "", self:formatEbil)
Local nTamFilial   := TamSX3("A1_FILIAL")[1]
Local nTamCodCli   := TamSX3("A1_COD")[1]
Local nTamCodLoj   := TamSX3("A1_LOJA")[1]
Local cCliente     := Substr(cChaveCli, nTamFilial + 1, nTamCodCli)
Local cLoja        := Substr(cChaveCli, nTamFilial + nTamCodCli + 1, nTamCodLoj)
Local lAtvPad      := Iif(ChkFile("NRW"),  NRW->(ColumnPos("NRW_ATIPAD")) > 0 , .F.) // Proteção @12.1.2210
Local cChaveNRW    := ""
Local cCodDocEbil  := ""
Local cDescDocEbil := ""
Local cCodAtvPad   := ""
Local cDescAtvPad  := ""
Local cDodFasPad   := ""
Local cDescFasPad  := ""
Local cCodTarfPad  := ""
Local cDescTarfPad := ""
Local lRet         := .T.

	nQtde := JA148QTDTS(cCliente, cLoja, cUtiEbil, cFormEbil)
	lAttTS := nQtde > 0

	oResponse['attTimeSheet'] := Iif( lAttTS, 'true', 'false')
	oResponse['qtdTimeSheet'] := JConvUTF8(cValToChar(nQtde))

	If lAttTS .And. lAtvPad
		// Retorna as informações padrões do documento ebilling
		aInfoPad := JA148PDEBL(cEmpEbil)
		If !Empty(aInfoPad)
			cChaveNRW    := Encode64(aInfoPad[01] + aInfoPad[02]) // NRW_FILIAL + NRW_COD
			cCodDocEbil  := JConvUTF8(aInfoPad[02])
			cDescDocEbil := JConvUTF8(aInfoPad[03])
			cCodAtvPad   := JConvUTF8(aInfoPad[04])
			cDescAtvPad  := JConvUTF8(aInfoPad[05])
			cDodFasPad   := JConvUTF8(aInfoPad[06])
			cDescFasPad  := JConvUTF8(aInfoPad[07])
			cCodTarfPad  := JConvUTF8(aInfoPad[08])
			cDescTarfPad := JConvUTF8(aInfoPad[09])
		EndIf
	EndIf

		// Força o retorno
		oResponse['chaveNRW']    := cChaveNRW
		oResponse['codDocEbil']  := cCodDocEbil
		oResponse['descDocEbil'] := cDescDocEbil
		oResponse['codAtvPad']   := cCodAtvPad
		oResponse['descAtvPad']  := cDescAtvPad
		oResponse['codFasPad']   := cDodFasPad
		oResponse['descFasPad']  := cDescFasPad
		oResponse['codTarfPad']  := cCodTarfPad
		oResponse['descTarfPad'] := cDescTarfPad

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
	oResponse:FromJSon("{}")
	oResponse := Nil

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} POST attTimeSheet
Grava as informações de atividade, fase e tarefa ebilling nos timesheets.

@example POST -> http://127.0.0.1:9090/rest/WSPfsAppCliente/atutimesheet

@Return lRet    Se .T. retorna 201 com a mensagem "TimeSheets atualizados com sucesso!"
                Se .F. retorna 400 com a mensagem "Alguns Timesheets tiveram problema na atualização"
                (Mesmo que retornar .F. alguns timesheets já terão sido efetivados as alterações)

@author Victor Hayashi
@since  19/01/2024
/*/
//-------------------------------------------------------------------
WSMethod POST AttTimeSheet WSREST WSPfsAppCliente
Local oResponse  := JSonObject():New()
Local oJSonBody  := JsonObject():New()
Local cBody      := StrTran(Self:GetContent(),CHR(10),"")
Local cCliente   := ""
Local cLoja      := ""
Local cFase      := ""
Local cTarefa    := ""
Local cAtivi     := ""
Local cDocEbCli  := ""
Local aInfo      := {}
Local aErrorTS   := {}
Local nX         := 0
Local lRet       := .T.

	oJSonBody:fromJson(cBody)
	aInfo := oJsonBody:getJsonObject("infoApi")

	If !Empty(aInfo)
		cCliente   := aInfo[1]["codCliente"]
		cLoja      := aInfo[1]["lojaCliente"]
		cFase      := aInfo[1]["codFaseEbil"]
		cTarefa    := aInfo[1]["codTarefaEbil"]
		cAtivi     := aInfo[1]["codAtividadeEbil"]
		cDocEbCli  := aInfo[1]["codDocEbil"]
	EndIf

	lRet:= JA148REbil(cCliente, cLoja, cFase, cTarefa, cAtivi, cDocEbCli, @aErrorTS, .T.)

	If lRet
		oResponse['status']  = 201
		oResponse['message'] = JurEncUTF8(STR0013) // "TimeSheets atualizados com sucesso!"
	Else
		oResponse['status']  = 400
		oResponse['message'] = JurEncUTF8(STR0014) // "Alguns Timesheets tiveram problema na atualização"
		oResponse['timesheets'] := {}
		For nX := 1 to Len(aErrorTS)
			aAdd(oResponse['timesheets'], aErrorTS[nX])
		Next nX
	EndIf

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
	oJSonBody:FromJSon("{}")
	oJSonBody := Nil
	oResponse:FromJSon("{}")
	oResponse := Nil

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GET lsCli
Busca a lista de clientes cadastrados.

@example GET -> http://127.0.0.1:9090/rest/WSPfsAppCliente/listaCliente

@param valorDig    - QueryParam - valor digitado pelo usuario para pesquisa
@param filtFilial  - QueryParam - indica se filtra a filial dos registros
@param filtraAtivo - QueryParam - indica se deve filtrar apenas os registros ativos e desbloqueados
@param perfil      - QueryParam - indica o perfil do cliente que deve ser filtrado
@param filtercpo   - QueryParam - indica os campos adicionais do filtro (obs mesma ordem dos valores em filterinfo)
@param filterinfo  - QueryParam - indica as informações adicionais para serem filtradas (obs mesma ordem dos valores em filtercpo)
@param pageSize    - QueryParam - Quantidade de registros que retornarão da api

@author Victor Hayashi
@since  01/02/2024
/*/
//-------------------------------------------------------------------
WSMethod GET lsCli QUERYPARAM valorDig, filtFilial, filtraAtivo, perfil, filtercpo, filterinfo, pageSize, getContat WSREST WSPfsAppCliente
Local oResponse  := JSonObject():New() // Objeto JSON de retorno
Local oCliente   := Nil // Objeto de Query do cliente
Local cSearchKey := Self:valorDig // Valor digitado para busca de cliente
Local cQuery     := "" // Armazena a query de clientes
Local cAliasQry  := GetNextAlias() // Alias para a query
Local cTpDtBase  :=  AllTrim(Upper(TCGetDB())) // Tipo de database do sistema
Local cPerfil    := Self:perfil // Indica qual o perfil do cliente
Local lFiltFil   := Self:filtFilial == 'true' // Indica se deverá filtrar a filial do cliente
Local lFilAtivo  := Self:filtraAtivo == 'true' // Indica se será filtrado apenas clientes ativos/desbloqueados
Local lFilPerf   := !Empty(cPerfil) // Indica se será filtrado o perfil do cliente
Local lGetContat := Iif(ValType(Self:getContat) == "C",Lower(Self:getContat) =="true" , .F.) // Valida se deve trazer as informações dos contatos
Local aCpoFiltro := Iif(Empty(Self:filtercpo), {}, StrToArray(Self:filtercpo, ",")) // Campos da clausula 'WHERE'
Local aInfFiltro := Iif(Empty(Self:filterinfo), {}, StrToArray(Self:filterinfo, ",")) // Valores da clausula 'WHERE'
Local aFilFilt   := EmpFilUsu("SA1") // Filiais do usuario logado
Local nPage      := Iif(Empty(Self:pageSize), 10, Val(Self:pageSize)) // Quantidade de registros que retornarão da api
Local nParam     := 0 // Contador para o Bind Parameters
Local nX         := 0 // Contador para o For
Local nIndJson   := 0 // Indice do Obj Json
Local lLojaAuto  := SuperGetMv("MV_JLOJAUT", .F., "2",) == '1' // Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local cLojaAuto  := StrZero(0, TamSx3("A1_LOJA")[1])

	cQuery := " SELECT SA1.A1_FILIAL,"
	cQuery +=        " SA1.A1_COD,"
	cQuery +=        " SA1.A1_LOJA,"
	cQuery +=        " SA1.A1_NOME,"
	cQuery +=        " SA1.A1_CGC,"
	cQuery +=        " SA1.A1_PESSOA,"
	cQuery +=        " SA1.A1_GRPVEN,"
	cQuery +=        " NUH.NUH_PERFIL," 
	cQuery +=        " NUH.NUH_CPART,"
	cQuery +=        " NUH.NUH_SITCAD,"
	cQuery +=        " NUH.NUH_CESCR2,"
	cQuery +=        " NUH.NUH_CTABH,"
	cQuery +=        " NUH.NUH_DSPDIS,"
	cQuery +=        " NUH.NUH_UTEBIL,"
	cQuery +=        " NUH.NUH_CEMP,"
	cQuery +=        " NUH.NUH_TPFECH,"
	cQuery +=        " RD0.RD0_SIGLA,"
	cQuery +=        " RD0.RD0_NOME,"
	cQuery +=        " NUH.NUH_FPAGTO,"
	cQuery +=        " SA1.A1_COND,"
	cQuery +=        " SE4.E4_DESCRI,"
	cQuery +=        " NUH.NUH_CBANCO,"
	cQuery +=        " NUH.NUH_CAGENC,"
	cQuery +=        " NUH.NUH_CCONTA,"
	cQuery +=        " SA6.A6_NOME,"
	cQuery +=        " SA6.A6_NOMEAGE,"
	cQuery +=        " NUH.NUH_CMOE,"
	cQuery +=        " CTO.CTO_SIMB,"
	cQuery +=        " NUH.NUH_CRELAT,"
	cQuery +=        " NRJ.NRJ_DESC,"
	cQuery +=        " NUH.NUH_CIDIO,"
	cQuery +=        " NUH.NUH_CCARTA,"
	cQuery +=        " NRG.NRG_DESC,"
	cQuery +=        " NUH.NUH_CIDIO2,"
	cQuery +=        " NUH.NUH_TXADM,"
	cQuery +=        " NUH.NUH_GROSUP,"
	cQuery +=        " NUH.NUH_GROSHN,"
	cQuery +=        " NUH.NUH_PERCGH,"
	cQuery +=        " NUH.NUH_TXPERM,"
	cQuery +=        " NUH.NUH_PJUROS,"
	cQuery +=        " NUH.NUH_DESFIN,"
	cQuery +=        " NUH.NUH_DIADES,"
	cQuery +=        " NUH.NUH_TPDESC,"
 	cQuery +=        " SA1.A1_NATUREZ,"
 	cQuery +=        " SED.ED_DESCRIC"
 	cQuery +=   " FROM " + RetSqlName("SA1") + " SA1"
	cQuery +=  " INNER JOIN " + RetSqlName("NUH") + " NUH"
	cQuery +=     " ON (NUH.NUH_COD = SA1.A1_COD"
	cQuery +=    " AND NUH.NUH_LOJA = SA1.A1_LOJA"
	cQuery +=    " AND NUH.D_E_L_E_T_ = ' ')"
	cQuery +=  " INNER JOIN " + RetSqlName("RD0") + " RD0"
	cQuery +=     " ON ( RD0.RD0_CODIGO = NUH.NUH_CPART"
	cQuery +=    " AND RD0.RD0_FILIAL = ?" // xFilial("RD0")
	cQuery +=    " AND RD0.D_E_L_E_T_ = ' ' )"
	cQuery +=   " LEFT JOIN " + RetSqlName("SE4") + " SE4"
	cQuery +=    " ON ( SE4.E4_CODIGO = SA1.A1_COND"
	cQuery +=    " AND SE4.E4_FILIAL = ?" // xFilial("SE4")
	cQuery +=    " AND SE4.D_E_L_E_T_ = ' ' )"
	cQuery +=  " INNER JOIN " + RetSqlName("NRG") + " NRG"
	cQuery +=    "  ON ( NRG.NRG_COD = NUH.NUH_CCARTA"
	cQuery +=    " AND NRG.NRG_FILIAL = ?" // xFilial("NRG")
	cQuery +=    " AND NRG.D_E_L_E_T_ = ' ' )"
	cQuery +=  " INNER JOIN " + RetSqlName("NRJ") + " NRJ"
	cQuery +=    "  ON ( NRJ.NRJ_COD = NUH.NUH_CRELAT"
	cQuery +=    " AND NRJ.NRJ_FILIAL = ?" // xFilial("NRJ")
	cQuery +=    " AND NRJ.D_E_L_E_T_ = ' ' )"
	cQuery +=  " INNER JOIN " + RetSqlName("CTO") + " CTO"
	cQuery +=    "  ON ( CTO.CTO_MOEDA = NUH.NUH_CMOE"
	cQuery +=    " AND CTO.CTO_FILIAL = ?" // xFilial("CTO")
	cQuery +=    " AND CTO.D_E_L_E_T_ = ' ' )"
	cQuery +=   " LEFT JOIN " + RetSqlName("SED") + " SED"
	cQuery +=    "  ON ( SED.ED_CODIGO = SA1.A1_NATUREZ"
	cQuery +=    " AND SED.ED_FILIAL = ?" // xFilial("SED")
	cQuery +=    " AND SED.D_E_L_E_T_ = ' ' )"
	cQuery +=  " INNER JOIN " + RetSqlName("SA6") + " SA6"
	cQuery +=  "    ON ( SA6.A6_COD = NUH.NUH_CBANCO "
	cQuery +=    " AND SA6.A6_AGENCIA = NUH.NUH_CAGENC "
	cQuery +=    " AND SA6.A6_NUMCON = NUH.NUH_CCONTA "
	cQuery +=    " AND SA6.A6_FILIAL = ? "
	cQuery +=    " AND SA6.D_E_L_E_T_ = ' ' ) "
	cQuery +=  " WHERE SA1.D_E_L_E_T_ = ' '"

	// Filtra Filial
	If (lFiltFil)
		cQuery += " AND SA1.A1_FILIAL = ?" // FWxFilial("SA1")
	Else
		// Inclui as filiais que o usuário tem permissão
		If Len(aFilFilt) > 0
			cQuery += " AND SA1.A1_FILIAL IN (?)" // aFilFilt
		EndIf
	EndIf

	// Filtra os registros bloqueados/inativos
	If (lFilAtivo)
		cQuery +=    " AND NUH.NUH_ATIVO = '1'"
		cQuery +=    " AND SA1.A1_MSBLQL <> ' '"
	EndIf

	// Filtra pelo perfil do cliente
	If (lFilPerf)
		cQuery +=    " AND NUH.NUH_PERFIL = ?"
	EndIf

	// Monta os filtros informados
	For nX := 1 to Len(aCpoFiltro)
		cQuery +=  " AND ? = ?"
	Next nX

	// Pesquisa por valor digitado
	If !Empty(cSearchKey)
		cSearchKey := "%" + Lower(StrTran(JurLmpCpo( cSearchKey,.F. ),'#','')) + "%"
		
		cQuery += " AND ( LOWER(A1_COD) LIKE ?" // "%" + cSearchKey + "%"
		cQuery +=        " OR LOWER(A1_LOJA) LIKE ?" // "%" + cSearchKey + "%"
		cQuery +=        " OR ? LIKE ?" // "%" + cSearchKey + "%"
		cQuery +=        " OR ? LIKE ?" // "%" + cSearchKey + "%"
		cQuery +=    " OR ? LIKE ?" // "%" + cSearchKey + "%"
		cQuery += ")"
	EndIf

	If lLojaAuto
		cQuery +=    " AND SA1.A1_LOJA = ?"
	EndIf

	cQuery +=  " ORDER BY SA1.A1_NOME"

	oCliente := FWPreparedStatement():New(cQuery)

	oCliente:SetString(++nParam, xFilial("RD0")) // Filial do participantes
	oCliente:SetString(++nParam, xFilial("SE4")) // Filial da condições de pagamento
	oCliente:SetString(++nParam, xFilial("NRG")) // Filial do tipos de relatórios
	oCliente:SetString(++nParam, xFilial("NRJ")) // Filial do tipos de cartas
	oCliente:SetString(++nParam, xFilial("CTO")) // Filial da moedas
	oCliente:SetString(++nParam, xFilial("SED")) // Filial da naturezas
	oCliente:SetString(++nParam, xFilial("SA6")) // Filial do banco

	// Informações do Filtro de Filial
	If (lFiltFil)
		oCliente:SetString(++nParam, FWxFilial("SA1"))
	Else
		// Inclui as filiais que o usuário tem permissão
		If Len(aFilFilt) > 0
			oCliente:SetIn(++nParam, aFilFilt)
		EndIf
	EndIf

	// Informações do Filtro pelo perfil do cliente
	If (lFilPerf)
		oCliente:SetString(++nParam, cPerfil)
	EndIf

	// Campos e valores da clausula 'WHERE'
	For nX := 1 To Len(aCpoFiltro)
		oCliente:SetUnsafe(++nParam, aCpoFiltro[nX])
		oCliente:SetString(++nParam, aInfFiltro[nX])
	Next nX
	
	// Informações digitadas pelo usuario
	If !Empty(cSearchKey)
		oCliente:SetString(++nParam, cSearchKey) // LOWER(A1_COD) LIKE ?
		oCliente:SetString(++nParam, cSearchKey) // LOWER(A1_LOJA) LIKE ?
		oCliente:SetUnsafe(++nParam, JurFormat("A1_NOME", .T.,.T.)) // Seta o campo OR (?) LIKE ?
		oCliente:SetString(++nParam, cSearchKey) // Seta o valor do trecho OR A1_NOME LIKE (?)
		oCliente:SetUnsafe(++nParam, JurFormat("A1_NREDUZ", .T.,.T.)) // Seta o campo OR (?) LIKE ?
		oCliente:SetString(++nParam, cSearchKey) // Seta o valor do trecho OR A1_NREDUZ LIKE (?)
		If cTpDtBase == "ORACLE"
			oCliente:SetUnsafe(++nParam, JurFormat("RTRIM(A1_COD)||A1_LOJA", .T.,.T.))
		ElseIf cTpDtBase == "MSSQL"
			oCliente:SetUnsafe(++nParam, JurFormat("RTRIM(A1_COD)+A1_LOJA", .T.,.T.))
		EndIf
			oCliente:SetString(++nParam, cSearchKey)
	EndIf

	If lLojaAuto
		oCliente:SetString(++nParam, cLojaAuto)
	EndIf

	cQuery := oCliente:GetFixQuery()

	MpSysOpenQuery(cQuery, cAliasQry)

	oResponse['clientes'] := {}

	While !(cAliasQry)->(Eof()) .And. nIndJson < nPage
		nIndJson++
		aAdd(oResponse["clientes"], JsonObject():New())
		oResponse["clientes"][nIndJson]["filial"]             := JConvUTF8((cAliasQry)->A1_FILIAL)
		oResponse["clientes"][nIndJson]["codCliente"]        := JConvUTF8((cAliasQry)->A1_COD)
		If lLojaAuto
			oResponse["clientes"][nIndJson]["lojaCliente"]   := JConvUTF8(cLojaAuto)
		Else
			oResponse["clientes"][nIndJson]["lojaCliente"]   := JConvUTF8((cAliasQry)->A1_LOJA)
		EndIf
		oResponse["clientes"][nIndJson]["nomeCliente"]        := JConvUTF8((cAliasQry)->A1_NOME)
		oResponse["clientes"][nIndJson]["cgcCliente"]         := JConvUTF8((cAliasQry)->A1_CGC)
		oResponse["clientes"][nIndJson]["tpPessoa"]           := JConvUTF8((cAliasQry)->A1_PESSOA)
		oResponse["clientes"][nIndJson]["codGrpCliente"]      := JConvUTF8((cAliasQry)->A1_GRPVEN)
		oResponse["clientes"][nIndJson]["perfilCliente"]      := JConvUTF8((cAliasQry)->NUH_PERFIL)
		oResponse["clientes"][nIndJson]["codSocCliente"]      := JConvUTF8((cAliasQry)->NUH_CPART)
		oResponse["clientes"][nIndJson]["sitCadastro"]        := JConvUTF8((cAliasQry)->NUH_SITCAD)
		oResponse["clientes"][nIndJson]["codEscritorio"]      := JConvUTF8((cAliasQry)->NUH_CESCR2)
		oResponse["clientes"][nIndJson]["codTabHon"]          := JConvUTF8((cAliasQry)->NUH_CTABH)
		oResponse["clientes"][nIndJson]["discriminaDespesas"] := JConvUTF8((cAliasQry)->NUH_DSPDIS)
		oResponse["clientes"][nIndJson]["usaEbiling"]         := JConvUTF8((cAliasQry)->NUH_UTEBIL)
		oResponse["clientes"][nIndJson]["empresaEbiling"]     := JConvUTF8((cAliasQry)->NUH_CEMP)
		oResponse["clientes"][nIndJson]["codDocEbil"]         := JConvUTF8(JurGetDados("NRX", 1, xFilial("NRX") + (cAliasQry)->NUH_CEMP, "NRX_CDOC"))
		oResponse["clientes"][nIndJson]["codTpFech"]          := JConvUTF8((cAliasQry)->NUH_TPFECH)
		oResponse["clientes"][nIndJson]["siglaSocio"]         := JConvUTF8((cAliasQry)->RD0_SIGLA)
		oResponse["clientes"][nIndJson]["nomeSocio"]          := JConvUTF8((cAliasQry)->RD0_NOME)
		oResponse["clientes"][nIndJson]['numCaso']            := JConvUTF8(JA070NUMER((cAliasQry)->(A1_COD), (cAliasQry)->(A1_LOJA)))
		oResponse["clientes"][nIndJson]["formaPagamento"]     := JConvUTF8((cAliasQry)->NUH_FPAGTO)
		oResponse["clientes"][nIndJson]["codCondPagamento"]   := JConvUTF8((cAliasQry)->A1_COND)
		oResponse["clientes"][nIndJson]["descCondPagamento"]  := JConvUTF8((cAliasQry)->E4_DESCRI)
		oResponse["clientes"][nIndJson]["codigoBanco"]        := JConvUTF8((cAliasQry)->NUH_CBANCO)
		oResponse["clientes"][nIndJson]["codigoAgencia"]      := JConvUTF8((cAliasQry)->NUH_CAGENC)
		oResponse["clientes"][nIndJson]["codigoConta"]        := JConvUTF8((cAliasQry)->NUH_CCONTA)
		oResponse["clientes"][nIndJson]["nomeBanco"]          := JConvUTF8((cAliasQry)->A6_NOME)
		oResponse["clientes"][nIndJson]["nomeAgencia"]        := JConvUTF8((cAliasQry)->A6_NOMEAGE)
		oResponse["clientes"][nIndJson]["codMoeda"]           := JConvUTF8((cAliasQry)->NUH_CMOE)
		oResponse["clientes"][nIndJson]["simbMoeda"]          := JConvUTF8((cAliasQry)->CTO_SIMB)
		oResponse["clientes"][nIndJson]["codRelatorio"]       := JConvUTF8((cAliasQry)->NUH_CRELAT)
		oResponse["clientes"][nIndJson]["descrRelatorio"]     := JConvUTF8((cAliasQry)->NRJ_DESC)
		oResponse["clientes"][nIndJson]["codIdioma1"]         := JConvUTF8((cAliasQry)->NUH_CIDIO)
		oResponse["clientes"][nIndJson]["descrIdioma1"]       := JConvUTF8(JurGetDados("NR1", 1, xFilial("NR1") + (cAliasQry)->NUH_CIDIO, "NR1_DESC"))
		oResponse["clientes"][nIndJson]["codCarta"]           := JConvUTF8((cAliasQry)->NUH_CCARTA)
		oResponse["clientes"][nIndJson]["descrCarta"]         := JConvUTF8((cAliasQry)->NRG_DESC)
		oResponse["clientes"][nIndJson]["codIdioma2"]         := JConvUTF8((cAliasQry)->NUH_CIDIO2)
		oResponse["clientes"][nIndJson]["descrIdioma2"]       := JConvUTF8(JurGetDados("NR1", 1, xFilial("NR1") + (cAliasQry)->NUH_CIDIO2, "NR1_DESC"))
		oResponse["clientes"][nIndJson]["taxaAdministrativa"] := JConvUTF8(cValToChar((cAliasQry)->NUH_TXADM))
		oResponse["clientes"][nIndJson]["grosupDepesas"]      := JConvUTF8(cValToChar((cAliasQry)->NUH_GROSUP))
		oResponse["clientes"][nIndJson]["calculoGrosupHon"]   := JConvUTF8((cAliasQry)->NUH_GROSHN)
		oResponse["clientes"][nIndJson]["grosupHonorarios"]   := JConvUTF8(cValToChar((cAliasQry)->NUH_PERCGH))
		oResponse["clientes"][nIndJson]["taxaPermanencia"]    := JConvUTF8(cValToChar((cAliasQry)->NUH_TXPERM))
		oResponse["clientes"][nIndJson]["percentualJuros"]    := JConvUTF8(cValToChar((cAliasQry)->NUH_PJUROS))
		oResponse["clientes"][nIndJson]["percentualDescFin"]  := JConvUTF8(cValToChar((cAliasQry)->NUH_DESFIN))
		oResponse["clientes"][nIndJson]["diasParaDesconto"]   := JConvUTF8(cValToChar((cAliasQry)->NUH_DIADES))
		oResponse["clientes"][nIndJson]["tipoDesconto"]       := JConvUTF8((cAliasQry)->NUH_TPDESC)
		oResponse["clientes"][nIndJson]["naturezaFinanceira"] := JConvUTF8((cAliasQry)->A1_NATUREZ)
		oResponse["clientes"][nIndJson]["descricaoNatureza"]  := JConvUTF8((cAliasQry)->ED_DESCRIC)
		If lGetContat // Filtra somente clientes ativos.
			oResponse["clientes"][nIndJson]["contatos"]       := JGtContat((cAliasQry)->(A1_FILIAL),  (cAliasQry)->A1_COD, (cAliasQry)->A1_LOJA, /*cSearchKey*/, .T.)
		EndIf

		(cAliasQry)->(dbSkip())
	EndDo

	(cAliasQry)->(dbCloseArea())

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
	oResponse:FromJSon("{}")
	oResponse := Nil

Return .T.
