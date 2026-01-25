#INCLUDE "TOTVS.CH"
#INCLUDE 'MrpDados.ch'

Static _lOraclve19 := Nil

/*/{Protheus.doc} MrpDados_CargaMemoria
Classe para carregar os dados do banco para memoria

@author marcelo.neumann
@since 08/07/2019
@version 1
/*/
CLASS MrpDados_CargaMemoria FROM LongNameClass

	DATA aDocumentos    AS ARRAY
	DATA lThreads       AS LOGICAL
	DATA lCargaSeletiva AS LOGICAL
	DATA lExistSMV      AS LOGICAL
	DATA nTamCod        AS NUMERIC
	DATA oDadosSMV      AS OBJECT
	DATA oDados         AS OBJECT
	DATA oCompTab       AS OBJECT

	METHOD new(oDados) CONSTRUCTOR

	METHOD aguardaCalculoNiveis(oStatus, lProcPrinc)
	METHOD addLogDocumento(cFilAux, cProduto, cOpcional, dData, cDocum, cTabela, nQuant, cVarTipo, cVarOrig)
	METHOD atualizaRegistrosNoBanco(cTable, cUpdSet, cFilter)
	METHOD buscaRegistrosNoBanco(cTable, aJoin, cFilter, aFields, cOrder, cRecursive)
	METHOD carregaRegistros()
	METHOD montaJoinHWA(cProdCol, cTicket, lJoinSMM, cColFil, cTabela, oMultiEmp, lJoinSMB, lBloque)
	METHOD montaJoinSMM(cProdCol, cTicket, cAliasSMM)
	METHOD montaExistsSMM(cProdCol, cTicket)
	METHOD percentualAtual(oDados, nPercent)
	METHOD preCarga()
	METHOD processaCargasSequencia(oCargaDocs,oCargaEnge,cTicket)
	METHOD processaMultiThread()
	METHOD registraDocumentos(cTabela)
	METHOD registraProcessados()
	METHOD relacionaFilial(cTab1, cAlias1, cFil1, cTab2, cAlias2, cFil2, lPrefixo, lAddTab1, lAddTab2)
	METHOD trataJsonString(cJsonOrig)
	METHOD trataOptimizerOracle()
	METHOD utilizaCargaSeletiva()
	METHOD utilizaSMV()

ENDCLASS

/*/{Protheus.doc} new
Método construtor da classe MrpDados_CargaMemoria

@author marcelo.neumann
@since 08/07/2019
@version 1
@param oDados, objeto, objeto da camada de dados
@return Self , objeto, instância do objeto MrpDados_CargaMemoria criado
/*/
METHOD new(oDados) CLASS MrpDados_CargaMemoria

	Self:oDados         := oDados
	Self:oDadosSMV		:= Nil
	Self:oCompTab       := JsonObject():New()

	Self:lThreads       := oDados:oParametros["nThreads"] >= 1 .And. oDados:oParametros["cAutomacao"] != "2"

	Self:aDocumentos    := {}
	Self:lCargaSeletiva := Nil
	Self:lExistSMV      := Nil
	Self:nTamCod        := 90

Return Self

/*/{Protheus.doc} addLogDocumento
Armazena (localmente) informações de documento para posteriormente gravar na memória global e gravar na tabela SMV.

@author lucas.franca
@since 08/12/2021
@version P12
@param 01 cFilAux  , Character, Código da filial (em branco quando não utiliza multi-empresa)
@param 02 cProduto , Character, Código do produto
@param 03 cOpcional, Character, ID de opcional do produto
@param 04 dData    , Date     , Data do MRP onde o documento foi considerado
@param 05 cDocum   , Character, Código do documento
@param 06 cTabela  , Character, Tabela que está efetuando a carga
@param 07 nQuant   , Numeric  , Quantidade do documento
@param 08 cVarTipo , Character, Utilizado para variação de um tipo
@param 09 cVarOrig , Character, Utilizado para variação da origem do pedido de compras
@return Nil
/*/
Method addLogDocumento(cFilAux, cProduto, cOpcional, dData, cDocum, cTabela, nQuant, cVarTipo, cVarOrig) Class MrpDados_CargaMemoria
	Local   cTipoDoc  := ""
	Local   cTipoReg  := ""
	Local   cIndex    := ""
	Default cVarOrig  := "1"

	If Self:utilizaSMV()
		/*
		cTipoDoc = Tipo de documento: 1 = OP (Firme)
		                              2 = SC (Firme)
		                              3 = Pedido de Compra (Firme)
		                              4 = Empenho (Firme)
		                              5 = Demanda
		                              6 = Saldo inicial
		                              7 = Saldo Rejeitado
		                              8 = Em Terceiro
		                              9 = De Terceiro
		                              0 = Saldo Bloqueado
		                              A = OP Prevista
		                              B = SC Prevista
		                              C = PC Previsto
		                              D = Empenho Previsto
		cTipoReg = Tipo de registro: 1 = Entrada
		                             2 = Saída
		                             3 = Saldo
		cVarOrig = Tipo de origem  : 1 = Pedido de Compra
		                             2 = Autorização de entrega
		*/
		Do Case
			Case cTabela == "T4Q"
				cTipoDoc := IIf(cVarTipo == "1", "A", "1")
				cTipoReg := "1"

			Case cTabela == "T4T"
				cTipoDoc := IIf(cVarTipo == "1", "2", "B")
				cTipoReg := "1"

			Case cTabela == "T4U"
				If cVarOrig == "1"
					cTipoDoc := IIf(cVarTipo == "1", "3", "C")
				Else
                    cTipoDoc := IIf(cVarTipo == "1", "E", "F")
				Endif
				cTipoReg := "1"

			Case cTabela == "T4S"
				cTipoDoc := IIf(cVarTipo == "1", "D", "4")
				cTipoReg := "2"

			Case cTabela == "T4J"
				cTipoDoc := "5"
				cTipoReg := "2"

			Case cTabela == "T4V"
				cTipoDoc := "6"
				cTipoReg := "3"

			Case cTabela == "HWX"
				cTipoDoc := "7"
				cTipoReg := "3"

			Case cTabela == "ET"
				cTipoDoc := "8"
				cTipoReg := "3"

			Case cTabela == "DT"
				cTipoDoc := "9"
				cTipoReg := "3"

			Case cTabela == "SB"
				cTipoDoc := "0"
				cTipoReg := "3"
		End

		If Self:oDadosSMV == Nil
  			Self:oDadosSMV := JsonObject():New()
		EndIf

		cIndex := cFilAux+cProduto+cTabela+cDocum

		If Self:oDadosSMV:HasProperty(cIndex)
			Self:aDocumentos[ Self:oDadosSMV[cIndex] ][9] += nQuant
		Else
			aAdd(Self:aDocumentos, {cFilAux, cProduto, cOpcional, dData, cDocum, cTipoDoc, cTipoReg, cTabela, nQuant})
			Self:oDadosSMV[cIndex] := Len(Self:aDocumentos)
		EndIf

	EndIf

Return Nil

/*/{Protheus.doc} preCarga
Realiza a carga inicial (informações que não dependem dos parâmetros da tela de processamento)

@author marcelo.neumann
@since 08/07/2019
@version 1
@return Nil
/*/
METHOD preCarga() CLASS MrpDados_CargaMemoria
	Local oCargaEnge := MrpDados_Carga_Engenharia():New(Self)

	ajustaData(Self:oDados)

	//Somente a carga de calendário ficou na pré-carga, o restante será carregado após inicio do processamento
	oCargaEnge:calendario()

Return

/*/{Protheus.doc} carregaRegistros
Realiza a carga dos demais registros (informações que dependem dos parâmetros da tela de processamento)

@author marcelo.neumann
@since 08/07/2019
@version 1.0
/*/
METHOD carregaRegistros() CLASS MrpDados_CargaMemoria
	Local lDocs_Ok   := .F.
	Local lEng_Ok    := .F.
	Local lError     := .F.
	Local oCargaDocs := MrpDados_Carga_Documentos():New(Self)
	Local oCargaEnge := MrpDados_Carga_Engenharia():New(Self)
	Local oStatus    := MrpDados_Status():New(Self:oDados:oParametros["ticket"])

	ajustaData(Self:oDados)

	//Efetua a chamada dos métodos de carga em memória
	Self:processaCargasSequencia(oCargaDocs,oCargaEnge,Self:oDados:oParametros["ticket"])

	//Efetua Carga Inicial no Controle de Seletivo de Produtos
	Self:oDados:oDominio:oSeletivos:loadProdutosValidos()

	While !lEng_Ok .Or. !lDocs_Ok
		If !lEng_Ok
			lEng_Ok := oCargaEnge:cargaFinalizada()
		EndIf

		If !lDocs_Ok
			lDocs_Ok  := oCargaDocs:cargaFinalizada()
		EndIf

		Sleep(50)
	EndDo

	oCargaDocs:cargaDocsComOpcional()

	//Limpa Memória Referente STR IN de Seletivos
	Self:oDados:oDominio:oSeletivos:limpaInMemoria()

	//Se está carregando apenas os movimentos, corrige execução para inserir produtos opcionais
	Self:oDados:oDominio:oOpcionais:insereProdutosOpcionais()
	If oStatus:getStatus("status") != "4"    //Checa cancelamento
		Self:oDados:oProdutos:order(2, @lError) //Reordena
	EndIf

	If Self:oDados:oParametros['lAnalisaMemoriaPosCarga']
		Self:oDados:oProdutos:analiseMemoria(Self:oDados:oParametros['lAnalisaMemoriaSplit'], STR0070) //"Análise de Memória Após Carga Memória"
	EndIf

Return

/*/{Protheus.doc} registraDocumentos
Registra na memória global os documentos que foram registrados pelo método addLogDocumento

@author lucas.franca
@since 07/12/2021
@version 1.0
@param 01 cTabela, Character, Tabela dos documentos
/*/
METHOD registraDocumentos(cTabela) Class MrpDados_CargaMemoria
	Local cChave := "DOCMRP_" + cTabela
	Local lError := .F.

	If Self:utilizaSMV() .And. Len(Self:aDocumentos) > 0
		//Cria uma lista para armazenar as informações relacionadas ao tipo de documento.
		//Este método deve ser executado apenas uma vez para cada tipo de documento.
		If Self:oDados:oMatriz:existAList(cChave)
			Self:oDados:oMatriz:setItemAList(cChave, cTabela, @Self:aDocumentos, @lError, .F., .T., 2)
		Else
			Self:oDados:oMatriz:createAList(cChave, .T.)
			Self:oDados:oMatriz:setItemAList(cChave, cTabela, @Self:aDocumentos, @lError, .F., .F.)
		EndIf

		If !lError
			//Armazena global com os tipos gravados, para recuperar posteriormente
			//todos os tipos gerados e gravar os dados no banco de dados.
			cChave := "DOCMRP_TABELAS"
			Self:oDados:oMatriz:lock(cChave)

			If !Self:oDados:oMatriz:existAList(cChave)
				//Chave ainda não existe, faz a criação.
				Self:oDados:oMatriz:createAList(cChave, .T.)
			EndIf

			//Grava o novo tipo na global.
			Self:oDados:oMatriz:setItemAList(cChave, "TABELAS", cTabela, @lError, .F., .T.)

			Self:oDados:oMatriz:unlock(cChave)
		EndIf

		aSize(Self:aDocumentos, 0)
		FreeObj(Self:oDadosSMV)
		Self:oDadosSMV := Nil
	EndIf

Return

/*/{Protheus.doc} registraProcessados
Atualizar os status dos registros que foram processados

@author marcelo.neumann
@since 08/07/2019
@version 1.0
/*/
METHOD registraProcessados() CLASS MrpDados_CargaMemoria
	Local lNrMrp  := .F.
	Local cUpdate := ""
	Local cWhere  := ""
	Local oStatus := MrpDados_Status():New(Self:oDados:oParametros["ticket"])

	If oStatus:preparaAmbiente(Self:oDados)
		dbSelectArea("T4J")
		If FieldPos("T4J_NRMRP") > 0
			lNrMrp := .T.
		EndIf

		If Self:oDados:oDominio:oMultiEmp:utilizaMultiEmpresa()
			cWhere := Self:oDados:oDominio:oMultiEmp:queryFilial("T4J", "T4J_FILIAL", .F.)
		Else
			cWhere := " T4J_FILIAL   = '" + xFilial("T4J") + "' "
		EndIf
		cWhere  += " AND T4J_PROC = '3'"

		cUpdate := IIf(lNrMrp, "T4J_PROC = '1', T4J_NRMRP = '" + Self:oDados:oParametros["ticket"] + "'", "T4J_PROC = '1'")

		Self:atualizaRegistrosNoBanco("T4J", cUpdate, cWhere)
	EndIf

Return

/*/{Protheus.doc} atualizaRegistrosNoBanco
Realiza o UPDATE na base de dados

@author marcelo.neumann
@since 08/07/2019
@version 1.0
@param 01 cTable , caracter, tabela a ser buscada/atualizada
@param 02 cUpdSet, caracter, campos a serem atualizados
@param 03 cFilter, caracter, filtro a ser aplicado na busca
@return   lOk    , lógico  , indica se os registros foram selecionados e atualizado com sucesso
/*/
METHOD atualizaRegistrosNoBanco(cTable, cUpdSet, cFilter) CLASS MrpDados_CargaMemoria
	Local cQuery := ""
	Local lOk    := .T.

	cQuery := "UPDATE " + RetSqlName(cTable) + ;
	            " SET " + cUpdSet            + ;
	          " WHERE D_E_L_E_T_ = ' '"

	If !Empty(cFilter)
		cQuery += " AND " + cFilter
	EndIf

	If TCSqlExec(cQuery) < 0
		lOk := .F.
	EndIf

Return lOk

/*/{Protheus.doc} buscaRegistrosNoBanco
Retorna um array com os registros (em formato JSON) a serem processados

@author marcelo.neumann
@since 08/07/2019
@version 1.0
@param 01 cTable    , caracter, tabela principal que será buscada
@param 02 aJoin     , array   , tabelas auxiliares: [1][1] - Alias
                                                    [1][2] - Comando para o Join ("LEFT OUTER JOIN", "INNER JOIN")
                                                    [1][3] - Relacionamento entre as tabelas
@param 03 cFilter   , caracter, filtro a ser aplicado na busca
@param 04 aFields   , array   , array com os campos a serem retornados: [1][1] - Nome da coluna 1
                                                                        [1][2] - Tipo da coluna: C (caracter)
                                                                                                 N (numérico)
                                                                                                 D (data)
                                                                                                 O (opcional)
@param 05 cOrder    , caracter, ordenação dos registros que serão retornados na busca
@param 06 cRecursive, caracter, código da query recursiva
@return aRegEmJson  , array   , data convertida no periodo. Em caso de data superior ao ultimo periodo retorna Nil.
/*/
METHOD buscaRegistrosNoBanco(cTable, aJoin, cFilter, aFields, cOrder, cRecursive) CLASS MrpDados_CargaMemoria
	Local aRegEmJson := {}
	Local cAliasQry  := GetNextAlias()
	Local cBanco     := TCGetDB()
	Local cFim       := ""
	Local cQryFields := ""
	Local cQryCondic := ""
	Local cQryOpcion := ""
	Local cQuery     := ""
	Local nInd       := 0
	Local nIndWhile  := 0
	Local nTotalFor  := Len(aFields)
	Local oStatus    := MrpDados_Status():New(Self:oDados:oParametros["ticket"])

	Default aJoin      := {}
	Default cFilter    := "1 = 1"
	Default cOrder     := ""
	Default cRecursive := ""

	//ORACLE
	If cBanco == "ORACLE"
		cQryFields := "'{'"
		For nInd := 1 To nTotalFor
			Do Case
				Case aFields[nInd][2] == "C"
					cQryFields += " || '" + '"' + aFields[nInd][1] + '":"' + "' || RTRIM(" + aFields[nInd][3] + "." + aFields[nInd][1] + ") || '" + '",' + "'"

				Case aFields[nInd][2] == "O"
					cQryOpcion := " || '" + '"' + aFields[nInd][1] + '":{"OPTIONAL":' + "' || DECODE(LENGTH(" + aFields[nInd][3] + "." + aFields[nInd][1] + "), 1, '" + '""' + "', RTRIM(" + aFields[nInd][3] + "." + aFields[nInd][1] + ")), "

				Otherwise
					cQryFields += " || '" + '"' + aFields[nInd][1] + '":"' + "' || " + aFields[nInd][3] + "." + aFields[nInd][1] + " || '" + '",' + "'"
			EndCase
		Next nInd

		cQryFields += cQryOpcion
		cQryFields := Stuff(cQryFields, Len(cQryFields)-1, 1, '') + " REGISTRO_EM_JSON"

	//SQL SERVER
	ElseIf "MSSQL" $ cBanco
		cQryFields := "'{'"
		For nInd := 1 To nTotalFor
			Do Case
				Case aFields[nInd][2] == "C"
					cQryFields += " + '" + '"' + aFields[nInd][1] + '":"' + "' + RTRIM(ISNULL(" + aFields[nInd][3] + "." + aFields[nInd][1] + ", '')) + '" + '",' + "'"

				Case aFields[nInd][2] == "O"
					cQryOpcion := " + '" + '"' + aFields[nInd][1] + '":{"OPTIONAL":' + "' + ISNULL(RTRIM(" + aFields[nInd][3] + "." + aFields[nInd][1] + "), '" + '""' + "'), "

				Otherwise
					cQryFields += " + '" + '"' + aFields[nInd][1] + '":"' + "' + CAST(ISNULL(" + aFields[nInd][3] + "." + aFields[nInd][1] + ", '') AS VARCHAR) + '" + '",' + "'"
			EndCase
		Next nInd

		cQryFields += cQryOpcion
		cQryFields := "CAST(" + Stuff(cQryFields, Len(cQryFields)-1, 1, '') + " AS VARCHAR(8000)) AS REGISTRO_EM_JSON"

	//POSTGRES
	ElseIf cBanco == "POSTGRES"
		cQryFields := "CONCAT('{'"
		For nInd := 1 To nTotalFor
			Do Case
				Case aFields[nInd][2] == "C"
					cQryFields += " , '" + '"' + aFields[nInd][1] + '":"' + "' , RTRIM(" + aFields[nInd][3] + "." + aFields[nInd][1] + ") , '" + '",' + "'"

				Case aFields[nInd][2] == "O"
					cQryOpcion := " , '" + '"' + aFields[nInd][1] + '":{"OPTIONAL":' + "', COALESCE(SUBSTRING(ENCODE(" + aFields[nInd][3] + "." + aFields[nInd][1] + ", 'ESCAPE'), 1, LENGTH(" + aFields[nInd][3] + "." +  aFields[nInd][1] + ") - 1), '" + '""' + "'), "

				Otherwise
					cQryFields += " , '" + '"' + aFields[nInd][1] + '":"' + "' , " + aFields[nInd][3] + "." + aFields[nInd][1] + " , '" + '",' + "'"
			EndCase
		Next nInd

		cQryFields += cQryOpcion
		cQryFields := Stuff(cQryFields, Len(cQryFields)-1, 1, '') + ") REGISTRO_EM_JSON"
	EndIf

	cQryFields := "%" + cQryFields + "%"
	cQryCondic := "%" + RetSqlName(cTable) + " " + cTable

	//Trata as querys que possuem JOIN
	nTotalFor := Len(aJoin)
	For nInd := 1 To nTotalFor
		cQryCondic += " " + aJoin[nInd][2] + " " + Iif(Empty(aJoin[nInd][1]), "", RetSqlName(aJoin[nInd][1])) + " " + aJoin[nInd][1] + " ON " + aJoin[nInd][3] + ""
	Next nInd

	cQryCondic += " WHERE " + cTable + ".D_E_L_E_T_ = ' ' AND " + cFilter + " "

	If !Empty(cOrder)
		cQryCondic += " ORDER BY " + cOrder + "%"
	Else
		cQryCondic += "%"
	EndIf

	If Empty(cRecursive)
		BeginSql Alias cAliasQry
			%noparser%
			SELECT %Exp:cQryFields%
			FROM %Exp:cQryCondic%
		EndSql

	Else
		cQuery := cRecursive
		cQuery += "SELECT " + StrTran(cQryFields, "%", "")
		cQuery +=  " FROM " + StrTran(cQryCondic, "%", "")

		//Altera sintaxe da clausula WITH
		If cBanco == "POSTGRES"
			cQuery := StrTran(cQuery, 'WITH ', 'WITH recursive ')
		EndIf

		dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAliasQry, .T., .T.)
	EndIf

	//Trata o fechamento da String (JSON) caso possua campo/chave Opcional
	If !Empty(cQryOpcion)
		cFim := "}}]}"
	Else
		cFim := "}]}"
	EndIf

	While (cAliasQry)->(!Eof())
		aAdd(aRegEmJson, '{"aRegs":[' + AllTrim((cAliasQry)->REGISTRO_EM_JSON) + cFim)

		//Checa cancelamento a cada X execucoes
		If (nIndWhile == 1 .OR. Mod(nIndWhile, self:oDados:oParametros["nX_Para_Cancel"]) == 0) .AND. oStatus:getStatus("status") == "4"
			Exit
		EndIf
		nIndWhile++

		(cAliasQry)->(dbSkip())
	End
	(cAliasQry)->(dbCloseArea())

Return aRegEmJson

/*/{Protheus.doc} trataJsonString
Realiza Replace de Caracteres Especiais para o Padrão JSON

@type  Static Function
@author brunno.costa
@since 07/04/2020
@version P12.1.30
@return cReturn, caracter, retorna string cJsonOrig com replace de caracteres especiais
/*/
METHOD trataJsonString(cJsonOrig) CLASS MrpDados_CargaMemoria
	Local cReturn := ""
	Default cJsonOrig := ""

	cReturn := cJsonOrig
	cReturn := StrTran(cReturn, "'"              , "\'")
	cReturn := StrTran(cReturn, '\'              , '\\')
	cReturn := StrTran(cReturn, '"'              , '\"')
	cReturn := StrTran(cReturn, '\",\"'          , '","')
	cReturn := StrTran(cReturn, '\":\"'          , '":"')
	cReturn := StrTran(cReturn, '\"aRegs\"'      , '"aRegs"')
	cReturn := StrTran(cReturn, '[{\"'           , '[{"')
	cReturn := StrTran(cReturn, '\"}]'           , '"}]')
	cReturn := StrTran(cReturn, '\"}}]'          , '"}}]')
	cReturn := StrTran(cReturn, '\":{\"OPTIONAL"', '":{"OPTIONAL"')
	cReturn := StrTran(cReturn, '/'              , '\/')
	cReturn := StrTran(cReturn, Chr(8)           , '\b') //Backspace
	cReturn := StrTran(cReturn, Chr(12)          , '\f') //Formfeed
	cReturn := StrTran(cReturn, Chr(10)          , '\n') //Newline
	cReturn := StrTran(cReturn, Chr(13)          , '\r') //Carriage
	cReturn := StrTran(cReturn, Chr(9)           , '\t') //Horizontal tab

Return cReturn

/*/{Protheus.doc} processaMultiThread
Retorna se a execução é multi ou single thread

@type Static Function
@author marcelo.neumann
@since 15/04/2021
@version 1
@return Self:lThreads, lógico, indica se pode abrir uma nova thread ou não
/*/
METHOD processaMultiThread() CLASS MrpDados_CargaMemoria

Return Self:lThreads

/*/{Protheus.doc} percentualAtual
Retorna o percentual da carga em memória
@author marcelo.neumann
@since 19/04/2021
@version 1
@param 01 oDados  , objeto  , instância do objeto MrpDados
@param 02 nPercent, numérico, retorna por referência o percentual atual de carga em memoria dos dados
@return Nil
/*/
METHOD percentualAtual(oDados, nPercent) CLASS MrpDados_CargaMemoria
	Local nPercent   := 0
	Local nPerDocIni := 0
	Local nPerEngIni := 0
	Local nPerDoc    := 0
	Local nPerEng    := 0
	Local oCargaDocs := Nil
	Local oCargaEnge := Nil

	//Verifica se a sessão está ativa
	If !VarIsUID(oDados:oProdutos:cGlobalKey)
		Return 0
	EndIf

	If oDados:oProdutos:getflag("memoryLoadPercentage") == Nil
		oDados:oProdutos:setflag("memoryLoadPercentage", 0, .F., .F.)

	ElseIf oDados:oProdutos:getflag("memoryLoadPercentage") >= 100
		Return 100
	EndIf

	oCargaEnge := MrpDados_Carga_Documentos():New()
	oCargaDocs := MrpDados_Carga_Engenharia():New()
	nPerEngIni := oCargaEnge:getPerCarInicial(oDados)
	nPerDocIni := oCargaDocs:getPerCarInicial(oDados)
	nPerEng    := oCargaEnge:getPerCarga(oDados)
	nPerDoc    := oCargaDocs:getPerCarga(oDados)
	nPercent   := (nPerEngIni * 30) + (nPerDocIni * 10) + ;
	              (nPerEng    * 30) + (nPerDoc    * 30)
	nPercent   := Round((nPercent/100), 2)

	If nPercent > 0 .AND. nPercent < 100 .AND. nPercent > oDados:oProdutos:getflag("memoryLoadPercentage")
		oDados:oProdutos:setflag("memoryLoadPercentage", nPercent, .F., .F.)
	Else
		nPercent := oDados:oProdutos:getflag("memoryLoadPercentage")
	EndIf

Return

/*/{Protheus.doc} utilizaCargaSeletiva
Verifica se está parametrizado para utilizar a carga em memória seletiva.

@author lucas.franca
@since 30/06/2021
@version 1
@return Self:lCargaSeletiva, Logic, Identifica se utiliza carga em memória seletiva.
/*/
METHOD utilizaCargaSeletiva() CLASS MrpDados_CargaMemoria
	If Self:lCargaSeletiva == Nil
		If Self:oDados:oParametros["memoryLoadType"] == "1" .And. FWAliasInDic("SMM", .F.)
			Self:lCargaSeletiva := .T.
		Else
			Self:lCargaSeletiva := .F.
		EndIf
	EndIf
Return Self:lCargaSeletiva

/*/{Protheus.doc} utilizaSMV
Verifica se o ambiente possui a tabela SMV e se os registros podem ser gerados nesta tabela.

@author lucas.franca
@since 08/12/2021
@version P12
@return Self:lExistSMV, Logic, Identifica pode utilizar a tabela SMV
/*/
METHOD utilizaSMV() CLASS MrpDados_CargaMemoria

	If Self:lExistSMV == Nil
		Self:lExistSMV := FWAliasInDic("SMV", .F.)
	EndIf

Return Self:lExistSMV

/*/{Protheus.doc} ajustaData
Converte uma data do tipo DATE para o formato string AAAA-MM-DD

@type Static Function
@author brunno.costa
@since 29/07/2019
@version P12.1.27
@param oDados, objeto  , instância do objeto de Dados
@return cData, caracter, data convertida para o formato utilizado na integração.
/*/
Static Function ajustaData(oDados)
	Local aDatas := {}
	Local aNames := oDados:oParametros:GetNames()
	Local cJson  := ""
	Local nInd   := 0
	Local nTotal := 0

	//Ajusta Data para padrão do JSON
	nTotal := Len(aNames)
	For nInd := 1 To nTotal
		If ValType(oDados:oParametros[aNames[nInd]]) == "D"
			aAdd(aDatas, aNames[nInd])
			oDados:oParametros[aNames[nInd]] := convDate(oDados:oParametros[aNames[nInd]])
		EndIf
	Next nInd

	cJson := oDados:oParametros:toJson()

	//Retorna Data para padrão de oDados:oParametros
	nTotal := Len(aDatas)
	For nInd := 1 To nTotal
		oDados:oParametros[aDatas[nInd]] := StoD(StrTran(oDados:oParametros[aDatas[nInd]], "-", ""))
	Next nInd

	//Grava variaveis globais com os dados para popular as Statics das Threads
	PutGlbVars("PCP_aParam" + oDados:oParametros["ticket"], {cJson, , aDatas, "3"})

	aSize(aDatas, 0)
	aSize(aNames, 0)

Return

/*/{Protheus.doc} convDate
Converte uma data do tipo DATE para o formato string AAAA-MM-DD

@type Static Function
@author brunno.costa
@since 29/07/2019
@version P12.1.27
@param dData , data    , data que será convertida
@return cData, caracter, data convertida para o formato "AAAA-MM-DD"
/*/
Static Function convDate(dData)

Return StrZero(Year(dData),4) + "-" + StrZero(Month(dData),2) + "-" + StrZero(Day(dData),2)

/*/{Protheus.doc} processaCargasSequencia
Chama os métodos de carga em memória conforme em sequencia.
Essa sequencia é valida para a automação ou para processamentos single thread.
Para o processamento multithread, a ordem não interfere no processamento

@author ricardo.prandi
@since 02/11/2021
@version 1
@param 01 oCargaDocs, object, instancia do objeto de carga de documentos
@param 02 oCargaEnge, object, instancia do objeto de carga da engenharia
@param 03 cTicket   , object, ticket de processamento do MRP
@return nil
/*/
METHOD processaCargasSequencia(oCargaDocs,oCargaEnge,cTicket) CLASS MrpDados_CargaMemoria

	//Reserva as demandas para identificar o que precisa para o carga seletiva
	oCargaDocs:reservaDemandasProcessamento(cTicket)

	//Carrega os produtos da carga seletiva
	oCargaEnge:identificaProdutos()

	//Carrega o restante da engenharia
	oCargaEnge:produtos()
	oCargaEnge:estruturas()
	oCargaEnge:subprodutos()
	oCargaEnge:versaoDaProducao()

	//Carrega os documentos
	oCargaDocs:demandas()
	oCargaDocs:entradasEmpenho()
	oCargaDocs:entradasOP()
	oCargaDocs:entradasPC()
	oCargaDocs:entradasSC()

Return

/*/{Protheus.doc} montaJoinHWA
Monta o WHERE CLAUSE com a tabela de produtos

@author ricardo.prandi
@since 30/09/2021
@version 1
@param 01 cProdCol , caracter, coluna referente ao código do produto para comparação com a tabela HWA
@param 02 cTicket  , caracter, número do ticket que está sendo processado (usado quando com carga seletiva)
@param 03 lJoinSMM , logic   , indica se irá realizar o join com a tabela SMM
@param 04 cColFil  , caracter, coluna referente a filial para comparação com a tabela HWE.
@param 05 cTabela  , caracter, tabela que irá realizar o join.
@param 06 oMultiEmp, caracter, objeto da classe dominio multi empresa para buscar as filiais no join.
@param 07 lJoinSMB , logic   , indica se irá realizar o join com a tabela SMB
@param 08 lBloque  , logic   , indica que deve filtrar o campo HWA_BLOQUE
@return cQuery, caracter, retorna o WHERE CLAUSE com a tabela HWA
/*/
METHOD montaJoinHWA(cProdCol, cTicket, lJoinSMM, cColFil, cTabela, oMultiEmp, lJoinSMB, lBloque) CLASS MrpDados_CargaMemoria
	Local aFiliais := {}
	Local cAlias   := ""
	Local cColuna  := ""
	Local cQuery   := ""
	Local nTotal   := 0
	Default lJoinSMM := .T.
	Default lJoinSMB := .F.
	Default lBloque  := .F.

	If oMultiEmp:utilizaMultiEmpresa()
		aFiliais := oMultiEmp:retornaFiliais()
		nTotal   := Len(aFiliais)
	EndIf

	If nTotal > 0 .And. !Empty(cColFil)
		cAlias  := Left( cColFil, At(".", cColFil) - 1 )
		cColuna := StrTran(cColFil, cAlias + ".", "")
	EndIf

	cQuery := " INNER JOIN " + RetSqlName("HWA") + " HWA "
	cQuery +=        "  ON HWA.HWA_FILIAL = '" + xFilial("HWA") + "' "
	cQuery +=        " AND HWA.HWA_PROD   = "  + cProdCol
	cQuery +=        " AND HWA.D_E_L_E_T_ = ' ' "

	If lBloque
		cQuery += " AND HWA.HWA_BLOQUE <> '1' "
	EndIf

	If Self:oDados:oParametros["lUsesProductIndicator"]
		cQuery += " LEFT OUTER JOIN " +  RetSqlName("HWE") + " HWE "
		cQuery += 		       " ON HWA.HWA_PROD = HWE.HWE_PROD "
		cQuery += 		      " AND HWE.D_E_L_E_T_ = ' ' "

		//Multi-Empresa
		If nTotal > 0
			cQuery  += " AND " + Self:relacionaFilial("HWE", "HWE", "HWE_FILIAL", cTabela, cAlias, cColuna, .T., .T., .T.)
		Else
			cQuery += " AND HWE.HWE_FILIAL = '" + xFilial("HWE") + "' "
		EndIf
	EndIf

	If lJoinSMM .AND. Self:utilizaCargaSeletiva()
		cQuery += Self:montaJoinSMM(cProdCol,cTicket)
	EndIf

	//Multi-Empresa
	If lJoinSMB .And. nTotal > 0
		cQuery += " LEFT JOIN " + RetSqlName("SMB") + " SMB"
		cQuery +=        "  ON SMB.MB_PROD   = "  + cProdCol
		cQuery +=        " AND SMB.D_E_L_E_T_ = ' ' "
 		cQuery +=        " AND " + Self:relacionaFilial("SMB", "SMB", "MB_FILIAL", cTabela, cAlias, cColuna, .T., .T., .T.)
	EndIf

Return cQuery

/*/{Protheus.doc} montaJoinSMM
Monta o WHERE CLAUSE da carga seletiva

@author ricardo.prandi
@since 23/11/2021
@version 1
@param  cProdCol , caracter, coluna referente ao código do produto para comparação com a tabela HWA
@param  cTicket  , caracter, número do ticket que está sendo processado
@param  cAliasSMM, caracter, Alias que será dado para a tabela SMM
@return cQuery   , caracter, retorna o WHERE CLAUSE com a tabela SMM
/*/
METHOD montaJoinSMM(cProdCol, cTicket, cAliasSMM) CLASS MrpDados_CargaMemoria
	Local cQuery := ""

	Default cAliasSMM := "SMM"

	If Self:utilizaCargaSeletiva()
		cQuery += " INNER JOIN " + RetSqlName("SMM") + " [SMM] "
		cQuery +=        "  ON [SMM].MM_FILIAL  = '" + xFilial("SMM") + "' "
		cQuery +=        " AND [SMM].MM_PROD    = "  + cProdCol
		cQuery +=        " AND [SMM].MM_TICKET  = '" + cTicket + "' "
		cQuery +=        " AND [SMM].D_E_L_E_T_ = ' ' "

		//Ajusta o ALIAS da tabela SMM conforme o parâmetro cAliasSMM
		cQuery := StrTran(cQuery, "[SMM]", cAliasSMM)
	EndIf

Return cQuery

/*/{Protheus.doc} montaExistsSMM
Monta o WHERE CLAUSE da carga seletiva utilizando a condição "EXISTS".

@author lucas.franca
@since 24/10/2022
@version P12
@param  cProdCol, caracter, coluna referente ao código do produto para comparação com a tabela HWA
@param  cTicket , caracter, número do ticket que está sendo processado
@return cQuery  , caracter, retorna o WHERE CLAUSE com a tabela SMM
/*/
METHOD montaExistsSMM(cProdCol, cTicket) CLASS MrpDados_CargaMemoria
	Local cQuery := ""

	If Self:utilizaCargaSeletiva()
		cQuery := " EXISTS( SELECT 1"
		cQuery +=           " FROM " + RetSqlName("SMM") + " SMM_EXS "
		cQuery +=          " WHERE SMM_EXS.MM_FILIAL  = '" + xFilial("SMM") + "' "
		cQuery +=            " AND SMM_EXS.MM_PROD    = "  + cProdCol
		cQuery +=            " AND SMM_EXS.MM_TICKET  = '" + cTicket + "' "
		cQuery +=            " AND SMM_EXS.D_E_L_E_T_ = ' ' ) "
	EndIf
Return cQuery

/*/{Protheus.doc} aguardaCalculoNiveis
Aguarda o término do cálculo de níveis

@author marcelo.nemann
@since 20/11/2019
@version 1.0
@param 01 oStatus   , objeto, instância do objeto de status
@param 02 lProcPrinc, lógico, indica se é o processo principal (que iniciou o cálculo dos níveis)
@return lRecalcOk, logico, indica se o cálculo foi realizado com sucesso
/*/
METHOD aguardaCalculoNiveis(oStatus, lProcPrinc) CLASS MrpDados_CargaMemoria
	Local lFlagOk   := .T.
	Local lRecalcOk := .F.
	Local nSecLog   := MicroSeconds()
	Local nSecRecNv := 0
	Default lProcPrinc := .F.

	If lProcPrinc
		nSecRecNv := oStatus:getStatus("tempo_recalculo_niveis", @lFlagOk)
	EndIf

	If lFlagOk
		While oStatus:getStatus("niveis") != "9" .AND. oStatus:getStatus("status") != "4"
			If oStatus:getStatus("niveis") == "3"
				lRecalcOk := .T.
				Exit
			EndIf

			//A cada 15 segundos, emite um log informando que está executando o recálculo de níveis
			If lProcPrinc .And. (((MicroSeconds() - nSecLog) / 15) > 1)
				LogMsg("MrpDados_CargaMemoria", 0, 0, 1, '', '', STR0105) // "Processando o recalculo de niveis."
				nSecLog := MicroSeconds()
			EndIf

			Sleep(50)
		EndDo
	Else
		oStatus:gravaErro("niveis", STR0092) //"Falha ao obter o status do início do processo do recálculo de níveis."
	EndIf

	If lProcPrinc
		oStatus:setStatus("tempo_recalculo_niveis" , MicroSeconds() - nSecRecNv)
	EndIf

Return lRecalcOk

/*/{Protheus.doc} utilizaCargaSeletiva
Verifica a versão do banco oracle

@author vivian.beatriz
@since 05/04/2023
@version 1.0
@param
@return cComando, character, retorna o tratamento da versão 19 do oracle
/*/
METHOD trataOptimizerOracle() Class MrpDados_CargaMemoria
	Local cAlias   := GetNextAlias()
	Local cBanco   := TcGetDb()
	Local cComando := " "
	Local cQuery   := "SELECT VERSION FROM PRODUCT_COMPONENT_VERSION"
	Local nPosVer  := 0

	If cBanco == "ORACLE" .And. _lOraclve19 == NIL
		_lOraclve19 := .F.
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)
		If (cAlias)->(!Eof()) .And. !Empty((cAlias)->(VERSION))
			nPosVer  := At(".", (cAlias)->(VERSION)) - 1
			cVersion := SubStr((cAlias)->(VERSION), 1, Iif(nPosVer > 0, nPosVer, 2))
		EndIf
		(cAlias)->(dbCloseArea())
		If cVersion == "19"
			_lOraclve19 := .T.
		EndIf
	EndIf

	If _lOraclve19 == .T.
		cComando := "/*+ optimizer_features_enable('12.1.0.1') */"
	EndIf

Return cComando

/*/{Protheus.doc} relacionaFilial
Monta relacionamento entre os campos _FILIAL de duas tabelas, conforme o compartilhamento das tabelas.

@author lucas.franca
@since 13/04/2023
@version 1.0
@param 01 cTab1   , Caracter, Nome da primeira tabela para relacionamento
@param 02 cAlias1 , Caracter, Alias que será utilizado para a coluna na query da primeira tabela
@param 03 cFil1   , Caracter, Nome da coluna de filial da primeira tabela
@param 04 cTab2   , Caracter, Nome da segunda tabela para relacionamento
@param 05 cAlias2 , Caracter, Alias que será utilizado para a coluna na query da segunda tabela
@param 06 cFil2   , Caracter, Nome da coluna de filial da segunda tabela
@param 07 lPrefixo, Logic   , Indica se usa o prefixo das tabelas
@param 08 lAddTab1, Logic   , Indica que deve adicionar o IN() de todas as filiais para a tabela 1
@param 09 lAddTab2, Logic   , Indica que deve adicionar o IN() de todas as filiais para a tabela 2
@return cRelFil, Caracter, Query de relacionamento das colunas de filial.
/*/
METHOD relacionaFilial(cTab1, cAlias1, cFil1, cTab2, cAlias2, cFil2, lPrefixo, lAddTab1, lAddTab2) Class MrpDados_CargaMemoria
	Local cRelFil  := ""
	Local cAnd     := ""

	If !Self:oCompTab:HasProperty(cTab1)
		Self:oCompTab[cTab1] := FWModeAccess(cTab1,1)+FWModeAccess(cTab1,2)+FWModeAccess(cTab1,3)
	EndIf

	If !Self:oCompTab:HasProperty(cTab2)
		Self:oCompTab[cTab2] := FWModeAccess(cTab2,1)+FWModeAccess(cTab2,2)+FWModeAccess(cTab2,3)
	EndIf

	cRelFil := "("
	If lAddTab1
		cRelFil += cAnd + Self:oDados:oDominio:oMultiEmp:queryFilial(cTab1, cFil1, lPrefixo, cAlias1)
		cAnd    := " AND "
	EndIf
	If lAddTab2
		cRelFil += cAnd + Self:oDados:oDominio:oMultiEmp:queryFilial(cTab2, cFil2, lPrefixo, cAlias2)
		cAnd    := " AND "
	EndIf

	If Self:oCompTab[cTab1] != 'CCC' .And. Self:oCompTab[cTab2] != 'CCC'
		cRelFil += cAnd + FWJoinFilial(cTab1, cTab2, cAlias1, cAlias2, lPrefixo)
		cAnd    := " AND "
	EndIf
	cRelFil += ")"

Return cRelFil
