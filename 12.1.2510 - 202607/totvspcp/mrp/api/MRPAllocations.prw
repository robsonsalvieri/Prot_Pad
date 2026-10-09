#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "MRPALLOCATIONS.CH"

Static _aMapFields := MapFields()

//dummy function
Function MrpAllocat()
Return

/*/{Protheus.doc} MrpAllocations
API de integração de EMPENHOS do MRP

@type  WSCLASS
@author lucas.franca
@since 10/06/2019
@version P12.1.27
/*/
WSRESTFUL mrpallocations DESCRIPTION STR0001 FORMAT APPLICATION_JSON //"Empenhos do MRP"
	WSDATA Fields     AS STRING  OPTIONAL
	WSDATA Order      AS STRING  OPTIONAL
	WSDATA Page       AS INTEGER OPTIONAL
	WSDATA PageSize   AS INTEGER OPTIONAL
	WSDATA branchId   AS STRING  OPTIONAL
	WSDATA code       AS STRING  OPTIONAL

	WSMETHOD GET ALLALLOCAT;
		DESCRIPTION STR0002; //"Retorna todos os empenhos do MRP"
		WSSYNTAX "api/pcp/v1/mrpallocations" ;
		PATH "/api/pcp/v1/mrpallocations" ;
		TTALK "v1"

	WSMETHOD GET ALLOCATION;
		DESCRIPTION STR0003; //"Retorna um empenho do MRP específico"
		WSSYNTAX "api/pcp/v1/mrpallocations/{branchId}/{code}" ;
		PATH "/api/pcp/v1/mrpallocations/{branchId}/{code}" ;
		TTALK "v1"

	WSMETHOD POST ALLOCATION;
		DESCRIPTION STR0004; //"Inclui ou atualiza um ou mais empenhos do MRP"
		WSSYNTAX "api/pcp/v1/mrpallocations" ;
		PATH "/api/pcp/v1/mrpallocations" ;
		TTALK "v1"

	WSMETHOD POST sync;
		DESCRIPTION STR0009; //"Sincronização empenhos do MRP"
		WSSYNTAX "api/pcp/v1/mrpallocations/sync" ;
		PATH "/api/pcp/v1/mrpallocations/sync" ;
		TTALK "v1"

	WSMETHOD DELETE ALLOCATION;
		DESCRIPTION STR0005; //"Exclui um ou mais empenhos do MRP"
		WSSYNTAX "api/pcp/v1/mrpallocations" ;
		PATH "/api/pcp/v1/mrpallocations" ;
		TTALK "v1"
ENDWSRESTFUL

/*/{Protheus.doc} GET ALLALLOCAT /api/pcp/v1/mrpallocations
Retorna todos os Empenhos MRP

@type  WSMETHOD
@author lucas.franca
@since 10/06/2019
@version P12.1.27
@param	Order   , caracter, Ordenação da tabela principal
@param	Page    , numérico, Número da página inicial da consulta
@param	PageSize, numérico, Número de registro por páginas
@param	Fields  , caracter, Campos que serão retornados no GET.
@return lRet    , Lógico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET ALLALLOCAT QUERYPARAM Order, Page, PageSize, Fields WSSERVICE mrpallocations
	Local aReturn := {}
	Local lRet    := .T.

	Self:SetContentType("application/json")

	aReturn := MrpEmpGAll(Self:aQueryString, Self:Order, Self:Page, Self:PageSize, Self:Fields)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
Return lRet

/*/{Protheus.doc} GET ALLOCATION /api/pcp/v1/mrpallocations
Retorna um empenho específico do MRP

@type  WSMETHOD
@author lucas.franca
@since 10/06/2019
@version P12.1.27
@param	branchId, Character, Código da filial para fazer a pesquisa
@param	code    , Character, Código único do empenho para fazer a pesquisa.
@param	Fields  , Character, Campos que serão retornados no GET.
@return lRet    , Lógico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET ALLOCATION PATHPARAM branchId, code QUERYPARAM Fields WSSERVICE mrpallocations
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a função para retornar os dados.
	aReturn := MrpEmpGet(Self:branchId, Self:code, Self:Fields)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
Return lRet

/*/{Protheus.doc} POST ALLOCATION /api/pcp/v1/mrpallocations
Inclui ou altera um ou mais empenhos do MRP

@type  WSMETHOD
@author lucas.franca
@since 10/06/2019
@version P12.1.27
@return lRet, Lógico, Informa se o processo foi executado com sucesso.
/*/
WSMETHOD POST ALLOCATION WSSERVICE mrpallocations
	Local aReturn  := {}
	Local cBody    := ""
	Local cError   := ""
	Local lRet     := .T.
	Local oBody    := JsonObject():New()

	Self:SetContentType("application/json")
	cBody := Self:GetContent()

	cError := oBody:FromJson(cBody)

	If cError == Nil
		aReturn := MrpEmpPost(oBody)
		MRPApi():restReturn(Self, aReturn, "POST", @lRet)
	Else
		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
		lRet    := .F.
		SetRestFault(400, EncodeUtf8(STR0006), .T., , cError ) //"Não foi possível interpretar os dados recebidos."
	EndIf

	FreeObj(oBody)
	oBody := Nil
Return lRet

/*/{Protheus.doc} POST sync /api/pcp/v1/mrpallocations/sync
Sincronização dos empenhos do MRP

@type  WSMETHOD
@author douglas.heydt
@since 05/08/2019
@version P12.1.27
@return lRet, Lógico, Informa se o processo foi executado com sucesso.
/*/
WSMETHOD POST sync WSSERVICE mrpallocations
	Local aReturn  := {}
	Local cBody    := ""
	Local cError   := ""
	Local lRet     := .T.
	Local oBody    := JsonObject():New()

	Self:SetContentType("application/json")
	cBody := Self:GetContent()

	cError := oBody:FromJson(cBody)

	If cError == Nil
		aReturn := MrpEmpSync(oBody)
		MRPApi():restReturn(Self, aReturn, "POST", @lRet)
	Else
		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
		lRet    := .F.
		SetRestFault(400, EncodeUtf8(STR0006), .T., , cError ) //"Não foi possível interpretar os dados recebidos."
	EndIf

	FreeObj(oBody)
	oBody := Nil
Return lRet

/*/{Protheus.doc} DELETE ALLOCATION /api/pcp/v1/mrpallocations
Deleta um ou mais empenhos do MRP

@type  WSMETHOD
@author lucas.franca
@since 10/06/2019
@version P12.1.27
@return lRet, Lógico, Informa se o processo foi executado com sucesso.
/*/
WSMETHOD DELETE ALLOCATION WSSERVICE mrpallocations
	Local aReturn  := {}
	Local cBody    := ""
	Local cError   := ""
	Local lRet     := .T.
	Local oBody    := JsonObject():New()

	Self:SetContentType("application/json")
	cBody := Self:GetContent()

	cError := oBody:FromJson(cBody)

	If cError == Nil
		aReturn := MrpEmpDel(oBody)
		MRPApi():restReturn(Self, aReturn, "DELETE", @lRet)
	Else
		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
		lRet    := .F.
		SetRestFault(400, EncodeUtf8(STR0006), .T., , cError ) //"Não foi possível interpretar os dados recebidos."
	EndIf

	FreeObj(oBody)
	oBody := Nil
Return lRet

/*/{Protheus.doc} MrpEmpPost
Função para disparar as ações da API de empenhos do MRP, para o método POST (Inclusão/Alteração).

@type    Function
@author  lucas.franca
@since   10/06/2019
@version P12.1.27
@oaram   oBody, JsonObject, Objeto JSON com as informações recebidas no corpo da requisição.
@return aReturn, Array, Array contendo o código HTTP que deverá ser retornado pela API, e o JSON formatado com todos os dados de retorno.
                        Array[1] -> Numeric. Código HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                        Array[2] -> Character. JSON no formato definido pela API para ser retornado.
/*/
Function MrpEmpPost(oBody)
	Local aReturn := {201, ""}
	Local oMRPApi := defMRPApi("POST","") //Instância da classe MRPApi para o método POST

	//Seta as funções de validação de cada mapeamento.
	oMRPApi:setValidData("fields", "MRPEMPVLD")

	//Adiciona os parâmetros recebidos no corpo da requisição (BODY)
	oMRPApi:setBody(oBody)

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

/*/{Protheus.doc} MrpEmpSync
Função para disparar as ações da API de empenhos do MRP, para o método Sync (sincronização).

@type    Function
@author  douglas.heydt
@since   10/06/2019
@version P12.1.27
@oaram   oBody, JsonObject, Objeto JSON com as informações recebidas no corpo da requisição.
@param   lBuffer, Lógico, Define a sincronização em processo de buffer.
@return aReturn, Array, Array contendo o código HTTP que deverá ser retornado pela API, e o JSON formatado com todos os dados de retorno.
                        Array[1] -> Numeric. Código HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                        Array[2] -> Character. JSON no formato definido pela API para ser retornado.
/*/
Function MrpEmpSync(oBody, lBuffer)
	Local aReturn := {201, ""}
	Local oMRPApi := defMRPApi("POST","") //Instância da classe MRPApi para o método POST

	//Seta as funções de validação de cada mapeamento.
	oMRPApi:setValidData("fields", "MRPEMPVLD")

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

/*/{Protheus.doc} MrpEmpDel
Função para disparar as ações da API de Empenhos do MRP, para o método DELETE (Exclusão).

@type  Function
@author lucas.franca
@since 10/06/2019
@version P12.1.27
@oaram oBody, JsonObject, Objeto JSON com as informações recebidas no corpo da requisição.
@return aReturn, Array, Array contendo o código HTTP que deverá ser retornado pela API, e o JSON formatado com todos os dados de retorno.
                        Array[1] -> Numeric. Código HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                        Array[2] -> Character. JSON no formato definido pela API para ser retornado.
/*/
Function MrpEmpDel(oBody)
	Local aReturn  := {201, ""}
	Local oMRPApi  := defMRPApi("DELETE","") //Instância da classe MRPApi para o método DELETE

	//Adiciona os parâmetros recebidos no corpo da requisição (BODY)
	oMRPApi:setBody(oBody)

	oMRPApi:setMapDelete("fields")

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

/*/{Protheus.doc} MrpEmpGAll
Função para disparar as ações da API de Empenhos do MRP, para o método GET (Consulta) para vários empenhos.

@type  Function
@author lucas.franca
@since 10/06/2019
@version P12.1.27
@param aQuery   , Array    , Array com os dados que devem ser filtrados.
                             Exemplo: Array[1]
                                      Array[1][1] = "PRODUCT"
                                      Array[1][2] = "PRODUTO001"
                                      Array[2]
                                      Array[2][1] = "PRODUCTIONORDER"
                                      Array[2][2] = "00000101001"
@param cOrder   , Character, Ordenação desejada do retorno.
@param nPage    , Numeric  , Página dos dados. Se não enviado, considera página 1.
@param nPageSize, Numeric  , Quantidade de registros retornados por página. Se não enviado, considera 20 registros por página.
@param cFields  , Character, Campos que devem ser retornados. Se não enviado, retorna todos os fields que possuem valor.
@return aReturn , Array    , Array com as informações da requisição.
                             aReturn[1] - Lógico    - Indica se a requisição foi processada com sucesso ou não.
						     aReturn[2] - Character - JSON com o resultado da requisição, ou com a mensagem de erro.
						     aReturn[3] - Numeric   - Código de erro identificado pelo MRPApi.
/*/
Function MrpEmpGAll(aQuery, cOrder, nPage, nPageSize, cFields)
	Local aReturn := {}

	//Processa o GET
	aReturn := EmpGet(.T., aQuery, cOrder, nPage, nPageSize, cFields)
Return aReturn

/*/{Protheus.doc} MrpEmpGet
Função para disparar as ações da API de Empenhos do MRP, para o método GET (Consulta) de um empenho específico.

@type  Function
@author lucas.franca
@since 10/06/2019
@version P12.1.27
@param cBranch , Caracter, Código da filial
@param cCode   , Caracter, Código único do empenho
@param cFields , Caracter, Campos que devem ser retornados.
@return aReturn, Array, Array com as informações da requisição.
                        aReturn[1] - Lógico    - Indica se a requisição foi processada com sucesso ou não.
						aReturn[2] - Character - JSON com o resultado da requisição, ou com a mensagem de erro.
						aReturn[3] - Numeric   - Código de erro identificado pelo MRPApi.
/*/
Function MrpEmpGet(cBranch, cCode, cFields)
	Local aReturn   := {}
	Local aQryParam := {}

	//Adiciona os filtros de filial e produto como QueryParam.
	aAdd(aQryParam, {"BRANCHID", cBranch})
	aAdd(aQryParam, {"CODE"    , cCode})

	If !Empty(cFields)
		//Adiciona o FIELDS se for recebido.
		aAdd(aQryParam, {"FIELDS", cFields})
	EndIf

	//Chama a função para retornar os dados.
	aReturn := EmpGet(.F., aQryParam, Nil, Nil, Nil, cFields)

Return aReturn

/*/{Protheus.doc} MapFields
Gera o array com o MAP dos fields da API e os fields da tabela T4S

@type  Static Function
@author lucas.franca
@since 10/06/2019
@version P12.1.27
@return aFields, Array, Array contendo o MAP dos fields da API e da tabela
/*/
Static Function MapFields()
	Local aFields := {}

/*
	O array de mapeamento do JSON é composto por:
	aArray[1]
	aArray[1][1] = Nome do elemento do JSON que contém a informação.
	aArray[1][2] = Nome da coluna da tabela correspondente a informação.
	aArray[1][3] = Tipo de dado no banco de dados.
	aArray[1][4] = Tamanho do campo.
	aArray[1][5] = Decimais do campo, quando é do tipo Numérico.
*/
	aFields := { ;
	            {"branchId"           , "T4S_FILIAL", "C", FWSizeFilial()                        , 0},;
	            {"code"               , "T4S_IDREG" , "C", GetSx3Cache("T4S_IDREG" ,"X3_TAMANHO"), 0},;
	            {"product"            , "T4S_PROD"  , "C", GetSx3Cache("T4S_PROD"  ,"X3_TAMANHO"), 0},;
	            {"productionOrder"    , "T4S_OP"    , "C", GetSx3Cache("T4S_OP"    ,"X3_TAMANHO"), 0},;
	            {"productionOrderOrig", "T4S_OPORIG", "C", GetSx3Cache("T4S_OPORIG","X3_TAMANHO"), 0},;
	            {"allocationDate"     , "T4S_DT"    , "D", 8                                     , 0},;
	            {"sequence"           , "T4S_SEQ"   , "C", GetSx3Cache("T4S_SEQ"   ,"X3_TAMANHO"), 0},;
	            {"quantity"           , "T4S_QTD"   , "N", GetSx3Cache("T4S_QTD"   ,"X3_TAMANHO"), GetSx3Cache("T4S_QTD"  , "X3_DECIMAL")},;
	            {"suspendedQuantity"  , "T4S_QSUSP" , "N", GetSx3Cache("T4S_QSUSP" ,"X3_TAMANHO"), GetSx3Cache("T4S_QSUSP", "X3_DECIMAL")},;
	            {"warehouse"          , "T4S_LOCAL" , "C", GetSx3Cache("T4S_LOCAL" ,"X3_TAMANHO"), 0};
	           }
Return aFields

/*/{Protheus.doc} EmpGet
Executa o processamento do método GET de acordo com os parâmetros recebidos.

@type  Static Function
@author lucas.franca
@since 10/06/2019
@version P12.1.27
@param lLista   , Logic    , Indica se deverá retornar uma lista de registros (.T.), ou apenas um registro (.F.).
@param aQuery   , Array    , Array com os dados que devem ser filtrados.
                             Exemplo: Array[1]
                                      Array[1][1] = "PRODUCT"
                                      Array[1][2] = "PRODUTO001"
                                      Array[2]
                                      Array[2][1] = "PRODUCTIONORDER"
                                      Array[2][2] = "00000101001"
@param cOrder   , Character, Ordenação desejada do retorno.
@param nPage    , Numeric  , Página dos dados. Se não enviado, considera página 1.
@param nPageSize, Numeric  , Quantidade de registros retornados por página. Se não enviado, considera 20 registros por página.
@param cFields  , Character, Campos que devem ser retornados. Se não enviado, retorna todos os fields que possuem valor.
@return aReturn , Array    , Array com as informações da requisição.
                             aReturn[1] - Lógico    - Indica se a requisição foi processada com sucesso ou não.
						     aReturn[2] - Character - JSON com o resultado da requisição, ou com a mensagem de erro.
						     aReturn[3] - Numeric   - Código de erro identificado pelo MRPApi.
/*/
Static Function EmpGet(lLista, aQuery, cOrder, nPage, nPageSize, cFields)
	Local aReturn := {.T.,"",200}
	Local oMRPApi := defMRPApi("GET",cOrder) //Instância da classe MRPApi para o método GET

	//Seta os parâmetros de paginação, filtros e campos para retorno
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

	//Libera o objeto MRPApi da memória.
	oMRPApi:Destroy()
	FreeObj(oMRPApi)
	oMRPApi := Nil
Return aReturn

/*/{Protheus.doc} MRPBOMVLD
Função responsável por validar as informações recebidas.

@type  Function
@author lucas.franca
@since 10/06/2019
@version P12.1.27
@param oMRPApi   , Object   , Referência da classe MRPApi que está processando os dados.
@param cMapCode  , Character, Código do mapeamento que será validado
@param oItem     , Object   , Referência do objeto JSON com os dados que devem ser validados.
@return lRet     , Lógico   , Identifica se os dados estão válidos.
/*/
Function MRPEMPVLD(oMRPApi, cMapCode, oItem)
	Local lRet := .T.

	If cMapCode == "fields"
		If lRet .And. Empty(oItem["code"])
			lRet := .F.
			oMRPApi:SetError(400, STR0007 + " 'code' " + STR0008 + " (T4S_IDREG)") //"Atributo 'XXX' não foi informado."
		EndIf

		If lRet .And. Empty(oItem["product"])
			lRet := .F.
			oMRPApi:SetError(400, STR0007 + " 'product' " + STR0008 + " (T4S_PROD)") //"Atributo 'XXX' não foi informado."
		EndIf
		If lRet .And. Empty(oItem["productionOrder"])
			lRet := .F.
			oMRPApi:SetError(400, STR0007 + " 'productionOrder' " + STR0008 + " (T4S_OP)") //"Atributo 'XXX' não foi informado."
		EndIf
		If lRet .And. Empty(oItem["allocationDate"])
			lRet := .F.
			oMRPApi:SetError(400, STR0007 + " 'allocationDate' " + STR0008 + " (T4S_DT)") //"Atributo 'XXX' não foi informado."
		EndIf
		If lRet .And. Empty(oItem["quantity"])
			lRet := .F.
			oMRPApi:SetError(400, STR0007 + " 'quantity' " + STR0008 + " (T4S_QTD)") //"Atributo 'XXX' não foi informado."
		EndIf
		If lRet .And. Empty(oItem["warehouse"])
			lRet := .F.
			oMRPApi:SetError(400, STR0007 + " 'warehouse' " + STR0008 + " (T4S_LOCAL)") //"Atributo 'XXX' não foi informado."
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} defMRPApi
Faz a instância da classe MRPAPI e seta as propriedades básicas.

@type  Static Function
@author lucas.franca
@since 10/06/2019
@version P12.1.27
@param cMethod  , Character, Método que será executado (GET/POST/DELETE)
@param cOrder   , Character, Ordenação para o GET
@return oMRPApi , Object   , Referência da classe MRPApi com as definições já executadas.
/*/
Static Function defMRPApi(cMethod, cOrder)
	Local oMRPApi := MRPApi():New(cMethod)

	//Seta o APIMAP do item principal (cabeçalho)
	oMRPApi:setAPIMap("fields", _aMapFields , "T4S", .F., cOrder)

	//Seta os campos utilizados para busca de registros.
	oMRPApi:setKeySearch("fields",{"T4S_IDREG"})

Return oMRPApi

/*/{Protheus.doc} MrpEmpMap
Retorna um array com todos os MapFields utilizados na API

@type    Function
@author  marcelo.neumann
@since   18/10/2019
@version P12.1.27
@return  Array, array com os arrays de MapFields
/*/
Function MrpEmpMap()

Return {_aMapFields}