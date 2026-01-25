#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "MRPBOMRouting.CH"

Static _aMapFields := MapFields()

//dummy function
Function MrpBOMRout()
Return


/*/{Protheus.doc} MRPBOMRouting
API de integracao das Operações por Componente

@type  WSCLASS
@author brunno.costa
@since 13/04/2020
@version P12.1.30
/*/
WSRESTFUL mrpbomrouting DESCRIPTION STR0001 FORMAT APPLICATION_JSON //"Operações por Componente"
	WSDATA Fields     AS STRING  OPTIONAL
	WSDATA Order      AS STRING  OPTIONAL
	WSDATA Page       AS INTEGER OPTIONAL
	WSDATA PageSize   AS INTEGER OPTIONAL
	WSDATA branchId   AS STRING  OPTIONAL
	WSDATA product    AS STRING  OPTIONAL
	WSDATA routing    AS STRING  OPTIONAL
	WSDATA operation  AS STRING  OPTIONAL

	WSMETHOD GET ALL;
		DESCRIPTION STR0002; //"Retorna todas as operações x componentes"
		WSSYNTAX "api/pcp/v1/mrpbomrouting" ;
		PATH "/api/pcp/v1/mrpbomrouting" ;
		TTALK "v1"

	WSMETHOD GET OPERACAO;
		DESCRIPTION STR0003; //"Retorna uma operação por componente específica"
		WSSYNTAX "api/pcp/v1/mrpbomrouting/{branchId}/{product}/{routing}/{operation}" ;
		PATH "/api/pcp/v1/mrpbomrouting/{branchId}/{product}/{routing}/{operation}" ;
		TTALK "v1"

	WSMETHOD POST OPERACAO;
		DESCRIPTION STR0004; //"Inclui ou atualiza uma ou mais operações por componente"
		WSSYNTAX "api/pcp/v1/mrpbomrouting" ;
		PATH "/api/pcp/v1/mrpbomrouting" ;
		TTALK "v1"

	WSMETHOD POST SYNC;
		DESCRIPTION STR0005; //"Sincronização de Operações por Componente"
		WSSYNTAX "api/pcp/v1/mrpbomrouting/sync" ;
		PATH "/api/pcp/v1/mrpbomrouting/sync" ;
		TTALK "v1"

	WSMETHOD DELETE OPERACAO;
		DESCRIPTION STR0006; //"Exclui uma ou mais Operação por Componente"
		WSSYNTAX "api/pcp/v1/mrpbomrouting" ;
		PATH "/api/pcp/v1/mrpbomrouting" ;
		TTALK "v1"
ENDWSRESTFUL

/*/{Protheus.doc} GET ALL /api/pcp/v1/mrpbomrouting
Retorna todos os cadastros de operações por componente do MRP

@type  WSMETHOD
@author brunno.costa
@since 13/04/2020
@version P12.1.30
@param	Order   , caracter, Ordenacao da tabela principal
@param	Page    , numerico, Número da pagina inicial da consulta
@param	PageSize, numerico, Número de registro por paginas
@param	Fields  , caracter, Campos que serão retornados no GET.
@return lRet    , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET ALL QUERYPARAM Order, Page, PageSize, Fields WSSERVICE mrpbomrouting
	Local aReturn := {}
	Local lRet    := .T.

	Self:SetContentType("application/json")

	aReturn := MrpBROGAll(Self:aQueryString, Self:Order, Self:Page, Self:PageSize, Self:Fields)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
Return lRet

/*/{Protheus.doc} GET OPERACAO /api/pcp/v1/mrpbomrouting/{branchId}/{product}/{routing}/{operation}
Retorna uma operação por componente específica

@type  WSMETHOD
@author brunno.costa
@since 13/04/2020
@version P12.1.30
@param	branchId  , Character, Codigo da filial para fazer a pesquisa
@param	product   , Character, Codigo do produto
@param	routing   , Character, Codigo do roteiro
@param	operation , Character, Codigo da operação
@param	Fields    , Character, Campos que serão retornados no GET.
@return lRet      , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET OPERACAO PATHPARAM branchId, product, routing, operation QUERYPARAM Fields WSSERVICE mrpbomrouting
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a funcao para retornar os dados.
	aReturn := MrpBROGet(Self:branchId, Self:product, Self:Fields)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)

Return lRet

/*/{Protheus.doc} POST OPERACAO /api/pcp/v1/mrpbomrouting
Inclui ou atualiza uma ou mais operações por componente

@type  WSMETHOD
@author brunno.costa
@since 13/04/2020
@version P12.1.30
@return lRet, Logico, Informa se o processo foi executado com sucesso.
/*/
WSMETHOD POST OPERACAO WSSERVICE mrpbomrouting
	Local aReturn  := {}
	Local cBody    := ""
	Local cError   := ""
	Local lRet     := .T.
	Local oBody    := JsonObject():New()

	Self:SetContentType("application/json")
	cBody := Self:GetContent()

	cError := oBody:FromJson(cBody)

	If cError == Nil
		aReturn := MrpBROPost(oBody)
		MRPApi():restReturn(Self, aReturn, "POST", @lRet)
	Else
		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
		lRet    := .F.
		SetRestFault(400, EncodeUtf8(STR0007), .T., , cError ) //"Nao foi possível interpretar os dados recebidos."
	EndIf

	FreeObj(oBody)
	oBody := Nil
Return lRet

/*/{Protheus.doc} POST SYNC /api/pcp/v1/mrpbomrouting/sync
Sincronização de Operações por Componente

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		brunno.costa
@since		13/04/2020
@version	12.1.27
/*/
WSMETHOD POST sync WSSERVICE mrpbomrouting
	Local aReturn  := {}
	Local cBody    := ""
	Local cError   := ""
	Local lRet     := .T.
	Local oBody    := JsonObject():New()

	Self:SetContentType("application/json")
	cBody := Self:GetContent()

	cError := oBody:FromJson(cBody)

	If cError == Nil
		aReturn := MrpBROSync(oBody)
		MRPApi():restReturn(Self, aReturn, "POST", @lRet)
	Else
		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
		lRet    := .F.
		SetRestFault(400, EncodeUtf8(STR0007), .T., , cError ) //"Não foi possível interpretar os dados recebidos."
	EndIf

	FreeObj(oBody)
	oBody := Nil

Return lRet

/*/{Protheus.doc} DELETE OPERACAO /api/pcp/v1/mrpbomrouting
Deleta um ou mais cadastros de operações por componente

@type  WSMETHOD
@author brunno.costa
@since 13/04/2020
@version P12.1.30
@return lRet, Logico, Informa se o processo foi executado com sucesso.
/*/
WSMETHOD DELETE OPERACAO WSSERVICE mrpbomrouting
	Local aReturn  := {}
	Local cBody    := ""
	Local cError   := ""
	Local lRet     := .T.
	Local oBody    := JsonObject():New()

	Self:SetContentType("application/json")
	cBody := Self:GetContent()

	cError := oBody:FromJson(cBody)

	If cError == Nil
		aReturn := MrpBRODel(oBody)
		MRPApi():restReturn(Self, aReturn, "DELETE", @lRet)
	Else
		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
		lRet    := .F.
		SetRestFault(400, EncodeUtf8(STR0007), .T., , cError ) //"Nao foi possível interpretar os dados recebidos."
	EndIf

	FreeObj(oBody)
	oBody := Nil
Return lRet

/*/{Protheus.doc} MrpBROPost
Dispara as acoes da API de operações por componente, para o metodo POST (Inclusao/Alteracao).

@type    Function
@author  brunno.costa
@since   13/04/2020
@version P12.1.30
@oaram   oBody, JsonObject, Objeto JSON com as informacoes recebidas no corpo da requisicao.
@return aReturn, Array, Array contendo o Codigo HTTP que devera ser retornado pela API, e o JSON formatado com todos os dados de retorno.
                        Array[1] -> Numeric. Codigo HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                        Array[2] -> Character. JSON no formato definido pela API para ser retornado.
/*/
Function MrpBROPost(oBody)
	Local aReturn := {201, ""}
	Local oMRPApi := defMRPApi("POST","") //Instancia da classe MRPApi para o metodo POST

	//Adiciona os parametros recebidos no corpo da requisicao (BODY)
	oMRPApi:setBody(oBody)

	//Executa o processamento do POST
	oMRPApi:processar("fields")

	//Recupera o status do processamento
	aReturn[1] := oMRPApi:getStatus()

	//Recupera o JSON com os dados do retorno do processo.
	aReturn[2] := oMRPApi:getRetorno(1)

	//Libera o objeto MRPApi da memoria.
	oMRPApi:Destroy()
	FreeObj(oMRPApi)
	oMRPApi := Nil
Return aReturn

/*/{Protheus.doc} MrpBROSync
Função para disparar as ações da API de operações por componente, para o método Sync (Sincronização).

@type    Function
@author  brunno.costa
@since   13/04/2020
@version P12.1.30
@oaram   oBody, JsonObject, Objeto JSON com as informações recebidas no corpo da requisição.
@param   lBuffer, Lógico, Define a sincronização em processo de buffer.
@return aReturn, Array, Array contendo o código HTTP que deverá ser retornado pela API, e o JSON formatado com todos os dados de retorno.
                        Array[1] -> Numeric. Código HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                        Array[2] -> Character. JSON no formato definido pela API para ser retornado.
/*/
Function MrpBROSync(oBody, lBuffer)
	Local aReturn := {201, ""}
	Local oMRPApi := defMRPApi("POST","") //Instância da classe MRPApi para o método POST

	Default lBuffer := .F.

	//Adiciona os parâmetros recebidos no corpo da requisição (BODY)
	oMRPApi:setBody(oBody)

	//Seta FLAG que indica o processo de sincronização.
	oMRPApi:setSync(.T.)

	//Seta Flag que indica o processo de buffer.
	oMRPApi:setBuffer(lBuffer)

	//Executa o processamento do POST
	oMRPApi:processar("fields")
	//Recupera o status do processamento
	aReturn[1] := oMRPApi:getStatus()
	//Recupera o JSON com os dados do retorno do processo.
	aReturn[2] := oMRPApi:getRetorno(1)

	//Libera o objeto MRPApi da memória.
	oMRPApi:Destroy()
	FreeObj(oMRPApi)
	oMRPApi := Nil
Return aReturn

/*/{Protheus.doc} MrpBRODel
Dispara as acoes da API de operações por componente, para o metodo DELETE (Exclusao).

@type  Function
@author brunno.costa
@since 13/04/2020
@version P12.1.30
@oaram oBody, JsonObject, Objeto JSON com as informacoes recebidas no corpo da requisicao.
@return aReturn, Array, Array contendo o Codigo HTTP que devera ser retornado pela API, e o JSON formatado com todos os dados de retorno.
                        Array[1] -> Numeric. Codigo HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                        Array[2] -> Character. JSON no formato definido pela API para ser retornado.
/*/
Function MrpBRODel(oBody)
	Local aReturn  := {201, ""}
	Local oMRPApi  := defMRPApi("DELETE","") //Instancia da classe MRPApi para o metodo DELETE

	//Adiciona os parametros recebidos no corpo da requisicao (BODY)
	oMRPApi:setBody(oBody)

	oMRPApi:setMapDelete("fields")

	//Executa o processamento do POST
	oMRPApi:processar("fields")

	//Recupera o status do processamento
	aReturn[1] := oMRPApi:getStatus()

	//Recupera o JSON com os dados do retorno do processo.
	aReturn[2] := oMRPApi:getRetorno(1)

	//Libera o objeto MRPApi da memoria.
	oMRPApi:Destroy()
	FreeObj(oMRPApi)
	oMRPApi := Nil
Return aReturn

/*/{Protheus.doc} MrpBROGAll
Dispara as acoes da API de operações por componente, para o metodo GET (Consulta) para várias operações por componente..

@type  Function
@author brunno.costa
@since 13/04/2020
@version P12.1.30
@param aQuery   , Array    , Array com os dados que devem ser filtrados.
                             Exemplo: Array[1]
                                      Array[1][1] = "PRODUCT"
                                      Array[1][2] = "PRODUTO001"
                                      Array[2]
                                      Array[2][1] = "PRODUCTIONORDER"
                                      Array[2][2] = "00000101001"
@param cOrder   , Character, Ordenacao desejada do retorno.
@param nPage    , Numeric  , Pagina dos dados. Se Nao enviado, considera pagina 1.
@param nPageSize, Numeric  , Quantidade de registros retornados por pagina. Se Nao enviado, considera 20 registros por pagina.
@param cFields  , Character, Campos que devem ser retornados. Se Nao enviado, retorna todos os fields que possuem valor.
@return aReturn , Array    , Array com as informacoes da requisicao.
                             aReturn[1] - Logico    - Indica se a requisicao foi processada com sucesso ou Nao.
						     aReturn[2] - Character - JSON com o resultado da requisicao, ou com a mensagem de erro.
						     aReturn[3] - Numeric   - Codigo de erro identificado pelo MRPApi.
/*/
Function MrpBROGAll(aQuery, cOrder, nPage, nPageSize, cFields)
	Local aReturn := {}

	//Processa o GET
	aReturn := BROGet(.T., aQuery, cOrder, nPage, nPageSize, cFields)
Return aReturn

/*/{Protheus.doc} MrpBROGet
Funcao para disparar as acoes da API de operações por componente, para o metodo GET (Consulta) da operação por componente específica.

@type  Function
@author brunno.costa
@since 13/04/2020
@version P12.1.30
@param cBranch , Caracter, Codigo da filial
@param cCode   , Caracter, Codigo único da solicitacao de compras
@param cFields , Caracter, Campos que devem ser retornados.
@return aReturn, Array, Array com as informacoes da requisicao.
                        aReturn[1] - Logico    - Indica se a requisicao foi processada com sucesso ou Nao.
						aReturn[2] - Character - JSON com o resultado da requisicao, ou com a mensagem de erro.
						aReturn[3] - Numeric   - Codigo de erro identificado pelo MRPApi.
/*/
Function MrpBROGet(cBranch, cProduct, cFields)
	Local aReturn   := {}
	Local aQryParam := {}

	//Adiciona os filtros de filial e produto como QueryParam.
	aAdd(aQryParam, {"BRANCHID", cBranch})
	aAdd(aQryParam, {"PRODUCT"    , cProduct})

	If !Empty(cFields)
		//Adiciona o FIELDS se for recebido.
		aAdd(aQryParam, {"FIELDS", cFields})
	EndIf

	//Chama a funcao para retornar os dados.
	aReturn := BROGet(.F., aQryParam, Nil, Nil, Nil, cFields)

Return aReturn

/*/{Protheus.doc} MapFields
Gera o array com o MAP dos fields da API e os fields da tabela HW9

@type  Static Function
@author brunno.costa
@since 13/04/2020
@version P12.1.30
@return aFields, Array, Array contendo o MAP dos fields da API e da tabela
/*/
Static Function MapFields()
	Local aFields := {}

/*
	O array de mapeamento do JSON e composto por:
	aArray[1]
	aArray[1][1] = Nome do elemento do JSON que contem a informacao.
	aArray[1][2] = Nome da coluna da tabela correspondente a informacao.
	aArray[1][3] = Tipo de dado no banco de dados.
	aArray[1][4] = Tamanho do campo.
	aArray[1][5] = Decimais do campo, quando e do tipo numerico.
*/

	aFields := { ;
                {"branchId"                     , "HW9_FILIAL", "C", GetSx3Cache("HW9_FILIAL"  ,"X3_TAMANHO")    ,0},;
                {"product"                      , "HW9_PROD"  , "C", GetSx3Cache("HW9_PROD"    ,"X3_TAMANHO")    ,0},;
                {"routing"                      , "HW9_ROTEIR", "C", GetSx3Cache("HW9_ROTEIR"  ,"X3_TAMANHO")    ,0},;
                {"operation"                    , "HW9_OPERAC", "C", GetSx3Cache("HW9_OPERAC"  ,"X3_TAMANHO")    ,0},;
                {"component"                    , "HW9_COMP"  , "C", GetSx3Cache("HW9_COMP"    ,"X3_TAMANHO")    ,0},;
                {"sequency"                     , "HW9_TRT"   , "C", GetSx3Cache("HW9_TRT"     ,"X3_TAMANHO")    ,0},;
                {"code"                         , "HW9_IDREG" , "C", GetSx3Cache("HW9_IDREG"   ,"X3_TAMANHO")    ,0} }

Return aFields

/*/{Protheus.doc} BROGet
Executa o processamento do metodo GET de acordo com os parametros recebidos.

@type  Static Function
@author brunno.costa
@since 13/04/2020
@version P12.1.30
@param lLista   , Logic    , Indica se devera retornar uma lista de registros (.T.), ou apenas um registro (.F.).
@param aQuery   , Array    , Array com os dados que devem ser filtrados.
                             Exemplo: Array[1]
                                      Array[1][1] = "CALENDAR"
                                      Array[1][2] = "202006"
@param cOrder   , Character, Ordenacao desejada do retorno.
@param nPage    , Numeric  , Pagina dos dados. Se Nao enviado, considera pagina 1.
@param nPageSize, Numeric  , Quantidade de registros retornados por pagina. Se Nao enviado, considera 20 registros por pagina.
@param cFields  , Character, Campos que devem ser retornados. Se Nao enviado, retorna todos os fields que possuem valor.
@return aReturn , Array    , Array com as informacoes da requisicao.
                             aReturn[1] - Logico    - Indica se a requisicao foi processada com sucesso ou Nao.
						     aReturn[2] - Character - JSON com o resultado da requisicao, ou com a mensagem de erro.
						     aReturn[3] - Numeric   - Codigo de erro identificado pelo MRPApi.
/*/
Static Function BROGet(lLista, aQuery, cOrder, nPage, nPageSize, cFields)
	Local aReturn := {.T.,"",200}
	Local oMRPApi := defMRPApi("GET",cOrder) //Instancia da classe MRPApi para o metodo GET

	//Seta os parametros de paginacao, filtros e campos para retorno
	oMRPApi:setFields(cFields)
	oMRPApi:setPage(nPage)
	oMRPApi:setPageSize(nPageSize)
	oMRPApi:setQueryParams(aQuery)
	oMRPApi:setUmRegistro(!lLista)

	//Executa o processamento
	aReturn[1] := oMRPApi:processar("fields")
	//Retorna o status do processamento
	aReturn[3] := oMRPApi:getStatus()
	If aReturn[1]
		//Se processou com sucesso, recupera o JSON com os dados.
		aReturn[2] := oMRPApi:getRetorno(1)
	Else
		//Ocorreu algum erro no processo. Recupera mensagem de erro.
		aReturn[2] := oMRPApi:getMessage()
	EndIf

	//Libera o objeto MRPApi da memoria.
	oMRPApi:Destroy()
	FreeObj(oMRPApi)
	oMRPApi := Nil
Return aReturn

/*/{Protheus.doc} MrpBROVLD
Funcao responsavel por validar as informacoes recebidas.

@type  Function
@author brunno.costa
@since 13/04/2020
@version P12.1.30
@param oMRPApi   , Object   , Referência da classe MRPApi que esta processando os dados.
@param cMapCode  , Character, Codigo do mapeamento que sera validado
@param oItem     , Object   , Referência do objeto JSON com os dados que devem ser validados.
@return lRet     , Logico   , Identifica se os dados estão validos.
/*/
Function MrpBROVLD(oMRPApi, cMapCode, oItem)
	Local lRet := .T.

	If cMapCode == "fields"

		If Empty(oItem["product"])
			oMRPApi:SetError(400, STR0008 + " 'product' " + STR0009 + " (HW9_PROD)") //"Atributo 'XXX' não foi informado."
			Return .F.
		EndIf

		If Empty(oItem["routing"])
			oMRPApi:SetError(400, STR0008 + " 'routing' " + STR0009 + " (HW9_ROTEIR)") //"Atributo 'XXX' não foi informado."
			Return .F.
		EndIf

		If Empty(oItem["operation"])
			oMRPApi:SetError(400, STR0008 + " 'operation' " + STR0009 + " (HW9_OPERAC)") //"Atributo 'XXX' não foi informado."
			Return .F.
		EndIf

		If Empty(oItem["component"])
			oMRPApi:SetError(400, STR0008 + " 'component' " + STR0009 + " (HW9_COMP)") //"Atributo 'XXX' não foi informado."
			Return .F.
		EndIf

		If Empty(oItem["code"])
			oMRPApi:SetError(400, STR0008 + " 'code' " + STR0009 + " (HW9_IDREG)") //"Atributo 'XXX' não foi informado."
			Return .F.
		EndIf

	EndIf

Return lRet

/*/{Protheus.doc} defMRPApi
Faz a instancia da classe MRPAPI e seta as propriedades basicas.

@type  Static Function
@author brunno.costa
@since 13/04/2020
@version P12.1.30
@param cMethod  , Character, Metodo que sera executado (GET/POST/DELETE)
@param cOrder   , Character, Ordenacao para o GET
@return oMRPApi , Object   , Referência da classe MRPApi com as definicoes ja executadas.
/*/
Static Function defMRPApi(cMethod, cOrder)
	Local oMRPApi := MRPApi():New(cMethod)

	//Seta o APIMAP do item principal (cabeçalho)
	oMRPApi:setAPIMap("fields", _aMapFields , "HW9", .F., cOrder)

	//Seta os campos utilizados para busca de registros.
	oMRPApi:setKeySearch("fields",{"HW9_FILIAL","HW9_IDREG"})

	If cMethod == "POST"
		//Seta as funcoes de validacao de cada mapeamento.
		oMRPApi:setValidData("fields", "MrpBROVLD")

		//Seta valores default
		oMRPApi:setDefaultValues("fields" ,"sequency","")
	EndIf
Return oMRPApi

/*/{Protheus.doc} MrpBROMap
Retorna um array com todos os MapFields utilizados na API

@type    Function
@author  brunno.costa
@since   13/04/2020
@version P12.1.30
@return  Array, array com os arrays de MapFields
/*/
Function MrpBROMap()
Return {_aMapFields}

