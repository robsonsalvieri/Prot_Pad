#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "MRPPRODUCTINDICATOR.CH"

Static _aMapFields := MapFields()

//dummy function
Function mrpprodind()
Return

/*/{Protheus.doc} mrpproductindicator
API de integracao dos indicadores do produto MRP

@type  WSCLASS
@author renan.roeder
@since 14/11/2019
@version P12.1.27
/*/
WSRESTFUL mrpproductindicator DESCRIPTION STR0001 FORMAT APPLICATION_JSON //"Indicadores de Produtos MRP"
	WSDATA Fields     AS STRING  OPTIONAL
	WSDATA Order      AS STRING  OPTIONAL
	WSDATA Page       AS INTEGER OPTIONAL
	WSDATA PageSize   AS INTEGER OPTIONAL
	WSDATA branchId   AS STRING  OPTIONAL
	WSDATA product    AS STRING  OPTIONAL

	WSMETHOD GET ALL;
		DESCRIPTION STR0002; //"Retorna todos os Indicadores Produto MRP"
		WSSYNTAX "api/pcp/v1/mrpproductindicator" ;
		PATH "/api/pcp/v1/mrpproductindicator" ;
		TTALK "v1"

	WSMETHOD GET PRODUTO;
		DESCRIPTION STR0003; //"Retorna um Indicadores de Produto MRP especifico"
		WSSYNTAX "api/pcp/v1/mrpproductindicator/{branchId}/{product}" ;
		PATH "/api/pcp/v1/mrpproductindicator/{branchId}/{product}" ;
		TTALK "v1"

	WSMETHOD POST PRODUTO;
		DESCRIPTION STR0004; //"Inclui ou atualiza um ou mais Indicadores de Produtos MRP"
		WSSYNTAX "api/pcp/v1/mrpproductindicator" ;
		PATH "/api/pcp/v1/mrpproductindicator" ;
		TTALK "v1"

	WSMETHOD POST sync;
		DESCRIPTION STR0005; //"Sincronização de Indicadores de Produtos MRP"
		WSSYNTAX "api/pcp/v1/mrpproductindicator/sync" ;
		PATH "/api/pcp/v1/mrpproductindicator/sync" ;
		TTALK "v1"

	WSMETHOD DELETE PRODUTO;
		DESCRIPTION STR0006; //"Exclui um ou mais Indicadores de Produtos MRP"
		WSSYNTAX "api/pcp/v1/mrpproductindicator" ;
		PATH "/api/pcp/v1/mrpproductindicator" ;
		TTALK "v1"
ENDWSRESTFUL

/*/{Protheus.doc} GET ALL /api/pcp/v1/mrpproductindicator
Retorna todos os cadastros de indicadores de produto MRP

@type  WSMETHOD
@author renan.roeder
@since 14/11/2019
@version P12.1.27
@param	Order   , caracter, Ordenacao da tabela principal
@param	Page    , numerico, Número da pagina inicial da consulta
@param	PageSize, numerico, Número de registro por paginas
@param	Fields  , caracter, Campos que serão retornados no GET.
@return lRet    , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET ALL QUERYPARAM Order, Page, PageSize, Fields WSSERVICE mrpproductindicator
	Local aReturn := {}
	Local lRet    := .T.

	Self:SetContentType("application/json")

	aReturn := MrpIPrGAll(Self:aQueryString, Self:Order, Self:Page, Self:PageSize, Self:Fields)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
Return lRet

/*/{Protheus.doc} GET PRODUTO /api/pcp/v1/mrpproductindicator
Retorna um cadastro de indicadores de produto específico

@type  WSMETHOD
@author renan.roeder
@since 14/11/2019
@version P12.1.27
@param	branchId, Character, Codigo da filial para fazer a pesquisa
@param	code    , Character, Codigo único da solicitacao de compras para fazer a pesquisa.
@param	Fields  , Character, Campos que serão retornados no GET.
@return lRet    , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET PRODUTO PATHPARAM branchId, product QUERYPARAM Fields WSSERVICE mrpproductindicator
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a funcao para retornar os dados.
	aReturn := MrpIPrGet(Self:branchId, Self:product, Self:Fields)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
Return lRet

/*/{Protheus.doc} POST PRODUTO /api/pcp/v1/mrpproductindicator
Inclui ou altera um cadastro de indicador de produto MRP

@type  WSMETHOD
@author renan.roeder
@since 14/11/2019
@version P12.1.27
@return lRet, Logico, Informa se o processo foi executado com sucesso.
/*/
WSMETHOD POST PRODUTO WSSERVICE mrpproductindicator
	Local aReturn  := {}
	Local cBody    := ""
	Local cError   := ""
	Local lRet     := .T.
	Local oBody    := JsonObject():New()

	Self:SetContentType("application/json")
	cBody := Self:GetContent()

	cError := oBody:FromJson(cBody)

	If cError == Nil
		aReturn := MrpIPrPost(oBody)
		MRPApi():restReturn(Self, aReturn, "POST", @lRet)
	Else
		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
		lRet    := .F.
		SetRestFault(400, EncodeUtf8(STR0007), .T., , cError ) //"Nao foi possível interpretar os dados recebidos."
	EndIf

	FreeObj(oBody)
	oBody := Nil
Return lRet

/*/{Protheus.doc} POST SYNC /api/pcp/v1/mrpproductindicator/sync
Sincronização do cadastro de indicadores de produto com o MRP

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		renan.roeder
@since		14/11/2019
@version	12.1.27
/*/
WSMETHOD POST sync WSSERVICE mrpproductindicator
	Local aReturn  := {}
	Local cBody    := ""
	Local cError   := ""
	Local lRet     := .T.
	Local oBody    := JsonObject():New()

	Self:SetContentType("application/json")
	cBody := Self:GetContent()

	cError := oBody:FromJson(cBody)

	If cError == Nil
		aReturn := MrpIPrSync(oBody)
		MRPApi():restReturn(Self, aReturn, "POST", @lRet)
	Else
		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
		lRet    := .F.
		SetRestFault(400, EncodeUtf8(STR0007), .T., , cError ) //"Não foi possível interpretar os dados recebidos."
	EndIf

	FreeObj(oBody)
	oBody := Nil

Return lRet

/*/{Protheus.doc} DELETE PRODUTO /api/pcp/v1/mrpproductindicator
Deleta um ou mais cadastros de indicadores de produto MRP

@type  WSMETHOD
@author renan.roeder
@since 14/11/2019
@version P12.1.27
@return lRet, Logico, Informa se o processo foi executado com sucesso.
/*/
WSMETHOD DELETE PRODUTO WSSERVICE mrpproductindicator
	Local aReturn  := {}
	Local cBody    := ""
	Local cError   := ""
	Local lRet     := .T.
	Local oBody    := JsonObject():New()

	Self:SetContentType("application/json")
	cBody := Self:GetContent()

	cError := oBody:FromJson(cBody)

	If cError == Nil
		aReturn := MrpIPrDel(oBody)
		MRPApi():restReturn(Self, aReturn, "DELETE", @lRet)
	Else
		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
		lRet    := .F.
		SetRestFault(400, EncodeUtf8(STR0007), .T., , cError ) //"Nao foi possível interpretar os dados recebidos."
	EndIf

	FreeObj(oBody)
	oBody := Nil
Return lRet

/*/{Protheus.doc} MrpIPrPost
Dispara as acoes da API de Indicadores de Produto MRP, para o metodo POST (Inclusao/Alteracao).

@type    Function
@author  renan.roeder
@since   14/11/2019
@version P12.1.27
@oaram   oBody, JsonObject, Objeto JSON com as informacoes recebidas no corpo da requisicao.
@return aReturn, Array, Array contendo o Codigo HTTP que devera ser retornado pela API, e o JSON formatado com todos os dados de retorno.
                        Array[1] -> Numeric. Codigo HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                        Array[2] -> Character. JSON no formato definido pela API para ser retornado.
/*/
Function MrpIPrPost(oBody)
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

/*/{Protheus.doc} MrpIPrSync
Função para disparar as ações da API de Produto MRP, para o método Sync (Sincronização).

@type    Function
@author  renan.roeder
@since   14/11/2019
@version P12.1.27
@oaram   oBody, JsonObject, Objeto JSON com as informações recebidas no corpo da requisição.
@param   lBuffer, Lógico, Define a sincronização em processo de buffer.
@return aReturn, Array, Array contendo o código HTTP que deverá ser retornado pela API, e o JSON formatado com todos os dados de retorno.
                        Array[1] -> Numeric. Código HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                        Array[2] -> Character. JSON no formato definido pela API para ser retornado.
/*/
Function MrpIPrSync(oBody, lBuffer)
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

/*/{Protheus.doc} MrpIPrDel
Dispara as acoes da API de Indicadores de Produto MRP, para o metodo DELETE (Exclusao).

@type  Function
@author renan.roeder
@since 14/11/2019
@version P12.1.27
@oaram oBody, JsonObject, Objeto JSON com as informacoes recebidas no corpo da requisicao.
@return aReturn, Array, Array contendo o Codigo HTTP que devera ser retornado pela API, e o JSON formatado com todos os dados de retorno.
                        Array[1] -> Numeric. Codigo HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                        Array[2] -> Character. JSON no formato definido pela API para ser retornado.
/*/
Function MrpIPrDel(oBody)
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

/*/{Protheus.doc} MrpIPrGAll
Dispara as acoes da API de Indicadores de Produto MRP, para o metodo GET (Consulta) para vários indicadores de produtos..

@type  Function
@author renan.roeder
@since 14/11/2019
@version P12.1.27
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
Function MrpIPrGAll(aQuery, cOrder, nPage, nPageSize, cFields)
	Local aReturn := {}

	//Processa o GET
	aReturn := IPrGet(.T., aQuery, cOrder, nPage, nPageSize, cFields)
Return aReturn

/*/{Protheus.doc} MrpIPrGet
Funcao para disparar as acoes da API de Indicadores de Produto MRP, para o metodo GET (Consulta) dos indicadores de um produto específico.

@type  Function
@author renan.roeder
@since 14/11/2019
@version P12.1.27
@param cBranch , Caracter, Codigo da filial
@param cCode   , Caracter, Codigo único da solicitacao de compras
@param cFields , Caracter, Campos que devem ser retornados.
@return aReturn, Array, Array com as informacoes da requisicao.
                        aReturn[1] - Logico    - Indica se a requisicao foi processada com sucesso ou Nao.
						aReturn[2] - Character - JSON com o resultado da requisicao, ou com a mensagem de erro.
						aReturn[3] - Numeric   - Codigo de erro identificado pelo MRPApi.
/*/
Function MrpIPrGet(cBranch, cProduct, cFields)
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
	aReturn := IPrGet(.F., aQryParam, Nil, Nil, Nil, cFields)

Return aReturn

/*/{Protheus.doc} MapFields
Gera o array com o MAP dos fields da API e os fields da tabela HWE

@type  Static Function
@author renan.roeder
@since 14/11/2019
@version P12.1.27
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
	    {"branchId"                     , "HWE_FILIAL", "C", GetSx3Cache("HWE_FILIAL"  ,"X3_TAMANHO")    ,0},;
	    {"product"                      , "HWE_PROD"  , "C", GetSx3Cache("HWE_PROD"    ,"X3_TAMANHO")    ,0},;
	    {"warehouse"                    , "HWE_LOCPAD", "C", GetSx3Cache("HWE_LOCPAD"  ,"X3_TAMANHO")    ,0},;
	    {"packingQuantity"              , "HWE_QE"    , "N", GetSx3Cache("HWE_QE"      ,"X3_TAMANHO")    ,GetSx3Cache("HWE_QE","X3_DECIMAL") },;
	    {"orderPoint"                   , "HWE_EMIN"  , "N", GetSx3Cache("HWE_EMIN"    ,"X3_TAMANHO")    ,GetSx3Cache("HWE_EMIN","X3_DECIMAL") },;
	    {"safetyStock"                  , "HWE_ESTSEG", "N", GetSx3Cache("HWE_ESTSEG"  ,"X3_TAMANHO")    ,GetSx3Cache("HWE_ESTSEG","X3_DECIMAL") },;
	    {"deliveryLeadTime"             , "HWE_PE"    , "N", GetSx3Cache("HWE_PE"      ,"X3_TAMANHO")    ,GetSx3Cache("HWE_PE","X3_DECIMAL") },;
	    {"typeDeliveryLeadTime"         , "HWE_TIPE"  , "C", GetSx3Cache("HWE_TIPE"    ,"X3_TAMANHO")    ,0},;
	    {"economicLotSize"              , "HWE_LE"    , "N", GetSx3Cache("HWE_LE"      ,"X3_TAMANHO")    ,GetSx3Cache("HWE_LE","X3_DECIMAL") },;
	    {"minimumLotSize"               , "HWE_LM"    , "N", GetSx3Cache("HWE_LM"      ,"X3_TAMANHO")    ,GetSx3Cache("HWE_LM","X3_DECIMAL") },;
	    {"tolerance"                    , "HWE_TOLER" , "N", GetSx3Cache("HWE_TOLER"   ,"X3_TAMANHO")    ,GetSx3Cache("HWE_TOLER","X3_DECIMAL") },;
	    {"enterMRP"                     , "HWE_MRP"   , "C", GetSx3Cache("HWE_MRP"     ,"X3_TAMANHO")    ,0},;
	    {"currentBillOfMaterialRevision", "HWE_REVATU", "C", GetSx3Cache("HWE_REVATU"  ,"X3_TAMANHO")    ,0},;
	    {"maximumStock"                 , "HWE_EMAX"  , "N", GetSx3Cache("HWE_EMAX"    ,"X3_TAMANHO")    ,GetSx3Cache("HWE_EMAX","X3_DECIMAL") },;
	    {"fixedHorizon"                 , "HWE_HORFIX", "N", GetSx3Cache("HWE_HORFIX"  ,"X3_TAMANHO")    ,GetSx3Cache("HWE_HORFIX","X3_DECIMAL") },;
	    {"fixedHorizonType"             , "HWE_TPHFIX", "C", GetSx3Cache("HWE_TPHFIX"  ,"X3_TAMANHO")    ,0},;
	    {"code"                         , "HWE_IDREG" , "C", GetSx3Cache("HWE_IDREG"   ,"X3_TAMANHO")    ,0};
	}

	If !Empty(GetSx3Cache("HWE_ERPOPC", "X3_TAMANHO"))
		aAdd(aFields, {"optional"                     , "HWE_MOPC"  , "O", GetSx3Cache("HWE_MOPC"   ,"X3_TAMANHO")    ,0})
		aAdd(aFields, {"erpMemoOptional"              , "HWE_ERPMOP", "M", GetSx3Cache("HWE_ERPMOP" ,"X3_TAMANHO")    ,0})
		aAdd(aFields, {"erpStringOptional"            , "HWE_ERPOPC", "C", GetSx3Cache("HWE_ERPOPC" ,"X3_TAMANHO")    ,0})
	EndIf

	If !Empty(GetSx3Cache("HWE_QB", "X3_TAMANHO"))
		aAdd(aFields, {"structBaseQuantity", "HWE_QB", "N", GetSx3Cache("HWE_QB", "X3_TAMANHO"), GetSx3Cache("HWE_QB", "X3_DECIMAL")})
	EndIf

Return aFields

/*/{Protheus.doc} IPrGet
Executa o processamento do metodo GET de acordo com os parametros recebidos.

@type  Static Function
@author renan.roeder
@since 14/11/2019
@version P12.1.27
@param lLista   , Logic    , Indica se devera retornar uma lista de registros (.T.), ou apenas um registro (.F.).
@param aQuery   , Array    , Array com os dados que devem ser filtrados.
                             Exemplo: Array[1]
                                      Array[1][1] = "CALENDAR"
                                      Array[1][2] = "201906"
@param cOrder   , Character, Ordenacao desejada do retorno.
@param nPage    , Numeric  , Pagina dos dados. Se Nao enviado, considera pagina 1.
@param nPageSize, Numeric  , Quantidade de registros retornados por pagina. Se Nao enviado, considera 20 registros por pagina.
@param cFields  , Character, Campos que devem ser retornados. Se Nao enviado, retorna todos os fields que possuem valor.
@return aReturn , Array    , Array com as informacoes da requisicao.
                             aReturn[1] - Logico    - Indica se a requisicao foi processada com sucesso ou Nao.
						     aReturn[2] - Character - JSON com o resultado da requisicao, ou com a mensagem de erro.
						     aReturn[3] - Numeric   - Codigo de erro identificado pelo MRPApi.
/*/
Static Function IPrGet(lLista, aQuery, cOrder, nPage, nPageSize, cFields)
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

/*/{Protheus.doc} MrpIPrVLD
Funcao responsavel por validar as informacoes recebidas.

@type  Function
@author renan.roeder
@since 14/11/2019
@version P12.1.27
@param oMRPApi   , Object   , Referência da classe MRPApi que esta processando os dados.
@param cMapCode  , Character, Codigo do mapeamento que sera validado
@param oItem     , Object   , Referência do objeto JSON com os dados que devem ser validados.
@return lRet     , Logico   , Identifica se os dados estão validos.
/*/
Function MrpIPrVLD(oMRPApi, cMapCode, oItem)
	Local lRet := .T.

	If cMapCode == "fields"

		If Empty(oItem["product"])
			oMRPApi:SetError(400, STR0008 + " 'product' " + STR0009 + " (HWE_PROD)") //"Atributo 'XXX' não foi informado."
			Return .F.
		EndIf

		If Empty(oItem["warehouse"])
			oMRPApi:SetError(400, STR0008 + " 'warehouse' " + STR0009 + " (HWE_LOCPAD)") //"Atributo 'XXX' não foi informado."
			Return .F.
		EndIf

		If !Empty(oItem["typeDeliveryLeadTime"]) .And. !oItem["typeDeliveryLeadTime"] $ "|1|2|3|4|5|"
			oMRPApi:SetError(400, STR0008 + " 'typeDeliveryLeadTime' " + STR0010 + " (HWE_TIPE)") //"deve ser definido com '1', '2', '3', '4' ou '5'."
			Return .F.
		EndIf

		If !Empty(oItem["enterMRP"]) .And. !oItem["enterMRP"] $ "|1|2|"
			oMRPApi:SetError(400, STR0008 + " 'enterMRP' " + STR0011 + " (HWE_MRP)") //"deve ser definido como '1' ou '2'."
			Return .F.
		EndIf

		If Empty(oItem["code"])
			oMRPApi:SetError(400, STR0008 + " 'code' " + STR0009 + " (HWE_IDREG)") //"Atributo 'XXX' não foi informado."
			Return .F.
		EndIf

	EndIf

Return lRet

/*/{Protheus.doc} defMRPApi
Faz a instancia da classe MRPAPI e seta as propriedades basicas.

@type  Static Function
@author renan.roeder
@since 14/11/2019
@version P12.1.27
@param cMethod  , Character, Metodo que sera executado (GET/POST/DELETE)
@param cOrder   , Character, Ordenacao para o GET
@return oMRPApi , Object   , Referência da classe MRPApi com as definicoes ja executadas.
/*/
Static Function defMRPApi(cMethod, cOrder)
	Local oMRPApi := MRPApi():New(cMethod)

	//Seta o APIMAP do item principal (cabeçalho)
	oMRPApi:setAPIMap("fields", _aMapFields , "HWE", .F., cOrder)

	//Seta os campos utilizados para busca de registros.
	oMRPApi:setKeySearch("fields",{"HWE_FILIAL","HWE_PROD"})

	If cMethod == "POST"
		//Seta as funcoes de validacao de cada mapeamento.
		oMRPApi:setValidData("fields", "MrpIPrVLD")

		//Seta valores default
		oMRPApi:setDefaultValues("fields" ,"packingQuantity"			,0)
		oMRPApi:setDefaultValues("fields" ,"orderPoint"					,0)
		oMRPApi:setDefaultValues("fields" ,"safetyStock"				,0)
		oMRPApi:setDefaultValues("fields" ,"deliveryLeadTime"			,0)
		oMRPApi:setDefaultValues("fields" ,"economicLotSize"			,0)
		oMRPApi:setDefaultValues("fields" ,"minimumLotSize"				,0)
		oMRPApi:setDefaultValues("fields" ,"tolerance"					,0)
		oMRPApi:setDefaultValues("fields" ,"maximumStock"				,0)
		oMRPApi:setDefaultValues("fields" ,"fixedHorizon"				,0)
		oMRPApi:setDefaultValues("fields", "enterMRP"                   ,"1")
	EndIf
Return oMRPApi

/*/{Protheus.doc} MrpIPrMap
Retorna um array com todos os MapFields utilizados na API

@type    Function
@author  renan.roeder
@since   14/11/2019
@version P12.1.27
@return  Array, array com os arrays de MapFields
/*/
Function MrpIPrMap()
Return {_aMapFields}

