#INCLUDE "ESTA010A.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} ESTA010A
Rotina de Processamento Agendado (Schedule) para avisos de vencimento de lotes
@type    Function
@author  Paulo Dias Oliveira (oliveira.paulo)
@since   06/10/2025
@version P12
@param   aParams[1] - Empresa
@param   aParams[2] - Filial
/*/
//-------------------------------------------------------------------
Function ESTA010A(aParams As Array)
	Local aArea         As Array
	Local aAreaD4Q      As Array
	Local cAliasQ       As Character
	Local nDiasGlobal   As Numeric
	Local nParam        As Numeric
	Local dDataAtual    As Date
	Local dDataLimite   As Date
	Local cCodProd      As Character
	Local cDescProd     As Character
	Local cCodArmz      As Character
	Local cLote         As Character
	Local cSubLote      As Character
	Local dDataVenc     As Date
	Local nSaldo        As Numeric
	Local nDiasRest     As Numeric
	Local lTemNotif     As Logical
	Local aNotif        As Array
	Local nDiasAnt      As Numeric
	Local cEmpProc      As Character 
	Local cFilProc      As Character
	Local cQuery        As Character
	Local nI            As Numeric
	Local oLote         As Object
	Local cChannel      As Character
	Local cCategEvent   As Character
	Local cEventID      As Character
	Local cTitle        As Character
	Local cNotif        As Character
	Local cTipo         As Character
	Local cGrupo        As Character
	Local cCateg        As Character
	Local lPublic       As Logical
	Local lSchedule     As Logical
	Local nLevel        As Numeric
	Local cSpcProd      As Character
	Local cSpcTipo      As Character
	Local cSpcGrupo     As Character
	Local cSpcCateg     As Character

	Default aParams := {FWCodEmp(), FWCodFil()} // Empresa e Filial padrão

	cEmpProc    := aParams[1]
	cFilProc    := aParams[2]

	lSchedule   := FwIsInCallStack("WFLAUNCHER")

	cAliasQ     := GetNextAlias()

	// Seta o ambiente para execução do schedule
	If lSchedule
		RPCSetType(3)
		RpcClearEnv()
		RPCSetEnv(cEmpProc, cFilProc)
	EndIf
	
	aArea       := FWGetArea()
	dDataAtual  := Date()
	nDiasGlobal := 0 // Valor padrão caso não exista regra global
	
	// Busca a regra global de dias de antecedência - Regra global é a regra sem filtro de produto, tipo, grupo ou categoria
	If AliasInDic("D4Q")
		aAreaD4Q  := D4Q->(FwGetArea())
		cSpcProd  := AvKey("", "D4Q_CPROD")
		cSpcTipo  := AvKey("", "D4Q_CTIPO")
		cSpcGrupo := AvKey("", "D4Q_CGRUPO")
		cSpcCateg := AvKey("", "D4Q_CCATEG")
		
		D4Q->(DbSetOrder(2)) // D4Q_FILIAL + D4Q_CPROD + D4Q_CTIPO + D4Q_CGRUPO + D4Q_CCATEG
		If D4Q->(DbSeek(xFilial("D4Q") + cSpcProd + cSpcTipo + cSpcGrupo + cSpcCateg ) )
			nDiasGlobal := D4Q->D4Q_DIAS // Dias de antecedência global
		EndIf
		FWRestArea(aAreaD4Q)
	EndIf
	
	// Array para armazenar os lotes a serem notificados
	aNotif    := {}
	lTemNotif := .F.

	// Configura os parâmetros do Event Viewer
	cChannel    := FW_EV_CHANEL_ENVIRONMENT
	cCategEvent := FW_EV_CATEGORY_MODULES
	cEventID    := "089" // Evento de Dias de Antecedência
	cTitle      := STR0001 // "Aviso de vencimento"
	cNotif      := ""
	lPublic     := .F.
	nLevel      := FW_EV_LEVEL_INFO // 1 = FW_EV_LEVEL_INFO // 2 = FW_EV_LEVEL_WARNING // 3 = FW_EV_LEVEL_ERROR

	// Constrói a query para buscar os lotes com saldo e dentro do período de validade
	// Busca dados do produto (SB1) e categoria (ACV)
	// Utiliza a regra global para definir o filtro de data máxima
	cQuery := " SELECT SB8.B8_FILIAL, SB8.B8_PRODUTO, SB1.B1_DESC, SB8.B8_LOTECTL, SB8.B8_NUMLOTE, SB8.B8_DTVALID, SB8.B8_SALDO, SB8.B8_LOCAL, SB1.B1_GRUPO, SB1.B1_TIPO, ACV.ACV_CATEGO"
	cQuery +=   " FROM " + RetSqlName("SB8") + " SB8"
	cQuery +=  " INNER JOIN " + RetSqlName("SB1") + " SB1"
	cQuery +=     " ON SB1.B1_FILIAL = ?" // #1
	cQuery +=    " AND SB1.B1_COD = SB8.B8_PRODUTO"
	cQuery +=    " AND SB1.D_E_L_E_T_ = ?" // #2
	cQuery +=   " LEFT JOIN " + RetSqlName("ACV") + " ACV"
	cQuery +=     " ON ACV.ACV_FILIAL = ?" // #3
	cQuery +=    " AND ACV.ACV_CODPRO = SB1.B1_COD"
	cQuery +=    " AND ACV.D_E_L_E_T_ = ?" // #4
	cQuery +=  " WHERE SB8.B8_FILIAL = ?" // #5
	cQuery +=    " AND SB8.B8_SALDO > ?" // #6
	cQuery +=    " AND SB8.B8_DTVALID >= ?" // #7
	cQuery +=    " AND SB8.D_E_L_E_T_ = ?" // #8

	oLote := FwExecStatement():New(cQuery)
	
	// Binding dos parâmetros na ordem
	nParam := 1
	oLote:SetString(nParam++, FWxFilial("SB1")) // #1
	oLote:SetString(nParam++, Space(1))         // #2
	oLote:SetString(nParam++, FWxFilial("ACV")) // #3
	oLote:SetString(nParam++, Space(1))         // #4
	oLote:SetString(nParam++, FWxFilial("SB8")) // #5
	oLote:SetNumeric(nParam++, 0)               // #6
	oLote:SetString(nParam++, DToS(dDataAtual)) // #7
	oLote:SetString(nParam++, Space(1))         // #8

	oLote:OpenAlias(cAliasQ)

	// Percorre os lotes retornados pela query
	While (cAliasQ)->(!Eof())
		cCodProd   := (cAliasQ)->B8_PRODUTO
		cDescProd  := (cAliasQ)->B1_DESC
		cLote      := (cAliasQ)->B8_LOTECTL
		cSubLote   := (cAliasQ)->B8_NUMLOTE
		dDataVenc  := SToD((cAliasQ)->B8_DTVALID)
		nSaldo     := (cAliasQ)->B8_SALDO
		cTipo      := (cAliasQ)->B1_TIPO
		cGrupo     := (cAliasQ)->B1_GRUPO
		cCateg     := (cAliasQ)->ACV_CATEGO

		// Busca os dias de antecedência para o produto atual
		nDiasAnt := E010DiasAnt(cCodProd, cCateg, cGrupo, cTipo, nDiasGlobal)

		// Calcular a data limite para o aviso
		dDataLimite := DaySub(dDataVenc, nDiasAnt)

		// Se a data atual for maior ou igual à data limite, gera a notificação
		If dDataAtual >= dDataLimite
			lTemNotif := .T.

			// Captura os dados do lote para a notificação
			cCodArmz  := (cAliasQ)->B8_LOCAL
			nDiasRest := DateDiffDay(dDataVenc, dDataAtual)

			// Adiciona os dados do lote à lista de notificações
			aAdd(aNotif, {cCodProd, cDescProd, cCodArmz, cLote, cSubLote, dDataVenc, nDiasRest, nSaldo})
		EndIf

		(cAliasQ)->(DbSkip())
	EndDo

	If lTemNotif
		// Organiza as notificações por produto para gerar uma notificação por produto
		aSort(aNotif, , , {|x, y| x[1] < y[1]})
		
		// Loop para criar uma notificação por produto
		For nI := 1 to Len(aNotif)
			cCodProd := aNotif[nI][1]
			
			// Monta a mensagem de notificação para o produto
			cNotif := STR0003 + AllTrim(cCodProd) + " - " + AllTrim(aNotif[nI][2]) + CRLF // "Aviso de Vencimento de Lotes - Produto: "
			cNotif += STR0004 + CRLF // "Lotes a vencer: "
			
			While nI <= Len(aNotif) .And. aNotif[nI][1] == cCodProd
				cSubLote := ""
				If !Empty(aNotif[nI][5])
					cSubLote := STR0006 + AllTrim(aNotif[nI][5]) // " / Sublote: "
				EndIf

				cNotif += STR0005 + AllTrim(aNotif[nI][4]) + cSubLote + CRLF // "Lote: "
				cNotif += STR0007 + AllTrim(aNotif[nI][3]) + CRLF // "Armazém: "
				cNotif += STR0008 + DToC(aNotif[nI][6]) + CRLF // "Data de Validade: "
				cNotif += STR0009 + AllTrim(Str(aNotif[nI][7])) + STR0010 + CRLF // "Dias Restantes: " / dia(s)"
				cNotif += STR0011 + AllTrim(Str(aNotif[nI][8], 10, 2)) + CRLF + CRLF // "Saldo do Lote: "

				nI++
			EndDo
			
			nI-- // Ajusta o loop
			
			// Insere o evento no EventViewer
			EventInsert(cChannel, cCategEvent, cEventID, nLevel, "", cTitle, cNotif, lPublic)
		Next nI
	EndIf

	(cAliasQ)->(DbCloseArea())

	FWRestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} E010DiasAnt
Função para buscar os dias de antecedência para um produto, respeitando as regras de prioridade
@type    Function
@author  Paulo Dias Oliveira (oliveira.paulo)
@since   06/10/2025
@version P12
@param   cProduto - Código do produto
@param   cCateg - Código da categoria do produto
@param   cGrupo - Código do grupo do produto
@param   cTipo - Código do tipo do produto
@param   nDiasGlobal - Dias de antecedência global
@return  nDiasAnt - Dias de antecedência encontrados
/*/
//-------------------------------------------------------------------
Static Function E010DiasAnt(cProduto, cCateg, cGrupo, cTipo, nDiasGlobal)
	Local aArea        As Array
	Local nDiasAnt     As Numeric
	Local nParam       As Numeric
	Local cQuery       As Character
	Local cAliasQ      As Character
	Local oRegra       As Object

	nDiasAnt  := nDiasGlobal // Valor padrão: regra global

	If AliasInDic("D4Q")

		aArea   := FWGetArea()
		cAliasQ := GetNextAlias()

		// Busca a regra de maior prioridade
		cQuery := " SELECT D4Q_DIAS "
		cQuery +=   " FROM " + RetSqlName("D4Q") + " D4Q "
		cQuery +=  " WHERE D4Q.D4Q_FILIAL = ?" // #1
		cQuery +=    " AND D_E_L_E_T_ = ' '"
		cQuery +=    " AND ( "
		cQuery +=              " (D4Q.D4Q_CPROD = ?) " // #2
		// Procura no nível mais específico categoria/grupo/tipo
		cQuery +=           " OR (D4Q.D4Q_CPROD = ' ' AND D4Q.D4Q_CCATEG = ? AND D4Q.D4Q_CGRUPO = ? AND D4Q.D4Q_CTIPO = ?) " // #3, #4, #5
		
		// Caso as 3 variáveis estejam preenchidas e não encontre no nível mais específico,
		// procura nas combinações de dois ou um atributos
		If !Empty(cCateg) .And. !Empty(cGrupo) .And. !Empty(cTipo)
			cQuery +=       " OR (D4Q.D4Q_CPROD = ' ' AND D4Q.D4Q_CCATEG = ?   AND D4Q.D4Q_CGRUPO = ?   AND D4Q.D4Q_CTIPO = ' ')" // #6, #7   // Categoria e Grupo
			cQuery +=       " OR (D4Q.D4Q_CPROD = ' ' AND D4Q.D4Q_CCATEG = ?   AND D4Q.D4Q_CGRUPO = ' ' AND D4Q.D4Q_CTIPO = ?  )" // #8, #9   // Categoria e Tipo
			cQuery +=       " OR (D4Q.D4Q_CPROD = ' ' AND D4Q.D4Q_CCATEG = ' ' AND D4Q.D4Q_CGRUPO = ?   AND D4Q.D4Q_CTIPO = ?  )" // #10, #11 // Grupo e Tipo
			cQuery +=       " OR (D4Q.D4Q_CPROD = ' ' AND D4Q.D4Q_CCATEG = ?   AND D4Q.D4Q_CGRUPO = ' ' AND D4Q.D4Q_CTIPO = ' ')" // #12      // Apenas Categoria
			cQuery +=       " OR (D4Q.D4Q_CPROD = ' ' AND D4Q.D4Q_CCATEG = ' ' AND D4Q.D4Q_CGRUPO = ?   AND D4Q.D4Q_CTIPO = ' ')" // #13      // Apenas Grupo
			cQuery +=       " OR (D4Q.D4Q_CPROD = ' ' AND D4Q.D4Q_CCATEG = ' ' AND D4Q.D4Q_CGRUPO = ' ' AND D4Q.D4Q_CTIPO = ?  )" // #14      // Apenas Tipo
		EndIf

		// Caso 2 variáveis estejam preenchidas e não encontre no nível mais específico, procura nas combinações de um atributo
		// Tipo sempre estará preenchido, pois é obrigatório no produto. Então vê se tem categoria ou grupo
		If !Empty(cTipo) .And. ((!Empty(cCateg) .And. Empty(cGrupo)) .Or. (Empty(cCateg) .And. !Empty(cGrupo)))
			cQuery +=      " OR (D4Q.D4Q_CPROD = ' ' AND D4Q.D4Q_CCATEG = ? AND D4Q.D4Q_CGRUPO = ? AND D4Q.D4Q_CTIPO = ?)" // #15 #16 #17
			cQuery +=      " OR (D4Q.D4Q_CPROD = ' ' AND D4Q.D4Q_CCATEG = ? AND D4Q.D4Q_CGRUPO = ? AND D4Q.D4Q_CTIPO = ?)" // #18 #19 #20
		EndIf
		cQuery +=        " ) "
		cQuery +=  " ORDER BY "
		cQuery +=   " CASE "
		cQuery +=     " WHEN D4Q.D4Q_CPROD <> ' ' THEN 1 "
		cQuery +=     " WHEN D4Q.D4Q_CCATEG <> ' ' AND D4Q.D4Q_CGRUPO <> ' ' AND D4Q.D4Q_CTIPO <> ' ' THEN 2 "
		cQuery +=     " WHEN (D4Q.D4Q_CCATEG <> ' ' AND D4Q.D4Q_CGRUPO <> ' ' AND D4Q.D4Q_CTIPO =  ' ')"
		cQuery +=       " OR (D4Q.D4Q_CCATEG <> ' ' AND D4Q.D4Q_CGRUPO =  ' ' AND D4Q.D4Q_CTIPO <> ' ')"
		cQuery +=       " OR (D4Q.D4Q_CCATEG =  ' ' AND D4Q.D4Q_CGRUPO <> ' ' AND D4Q.D4Q_CTIPO <> ' ') THEN 3 "
		cQuery +=     " WHEN (D4Q.D4Q_CCATEG <> ' ' AND D4Q.D4Q_CGRUPO =  ' ' AND D4Q.D4Q_CTIPO =  ' ')"
		cQuery +=       " OR (D4Q.D4Q_CCATEG =  ' ' AND D4Q.D4Q_CGRUPO <> ' ' AND D4Q.D4Q_CTIPO =  ' ')"
		cQuery +=       " OR (D4Q.D4Q_CCATEG =  ' ' AND D4Q.D4Q_CGRUPO =  ' ' AND D4Q.D4Q_CTIPO <> ' ') THEN 4 "
		cQuery +=     " ELSE 5 "
		cQuery +=   " END, D4Q_DIAS DESC "

		oRegra := FwExecStatement():New(cQuery)

		nParam := 1
		oRegra:SetString(nParam++, FWxFilial("D4Q")) // #1
		oRegra:SetString(nParam++, cProduto)         // #2
		oRegra:SetString(nParam++, cCateg)           // #3
		oRegra:SetString(nParam++, cGrupo)           // #4
		oRegra:SetString(nParam++, cTipo)            // #5
		If !Empty(cCateg) .And. !Empty(cGrupo) .And. !Empty(cTipo)
			oRegra:SetString(nParam++, cCateg)       // #6
			oRegra:SetString(nParam++, cGrupo)       // #7
			oRegra:SetString(nParam++, cCateg)       // #8
			oRegra:SetString(nParam++, cTipo)        // #9
			oRegra:SetString(nParam++, cGrupo)       // #10
			oRegra:SetString(nParam++, cTipo)        // #11
			oRegra:SetString(nParam++, cCateg)       // #12
			oRegra:SetString(nParam++, cGrupo)       // #13
			oRegra:SetString(nParam++, cTipo)        // #14
		EndIf
		// Tipo sempre estará preenchido, pois é obrigatório no produto. Então vê se tem categoria ou grupo
		If !Empty(cTipo) .And. ((!Empty(cCateg) .And. Empty(cGrupo)) .Or. (Empty(cCateg) .And. !Empty(cGrupo)))
			oRegra:SetString(nParam++, cCateg)       // #15
			oRegra:SetString(nParam++, cGrupo)       // #16
			oRegra:SetString(nParam++, "")           // #17
			oRegra:SetString(nParam++, "")           // #18
			oRegra:SetString(nParam++, "")           // #19
			oRegra:SetString(nParam++, cTipo)        // #20
		EndIf

		oRegra:OpenAlias(cAliasQ)

		If (cAliasQ)->(!Eof())
			nDiasAnt := (cAliasQ)->D4Q_DIAS
		EndIf

		(cAliasQ)->(DbCloseArea())

		FWRestArea(aArea)
	EndIf

Return nDiasAnt
