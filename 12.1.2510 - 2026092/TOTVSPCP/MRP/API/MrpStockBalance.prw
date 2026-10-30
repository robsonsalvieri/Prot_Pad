#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "mrpstockbalance.ch"

Static _aMapFields := MapFields()

//dummy function
Function mrpStock()
Return

/*/{Protheus.doc} mrpstockbalance
API de integracao de Solicitacoes de Compras do MRP

@type  WSCLASS
@author douglas.heydt
@since 13/06/2019
@version P12.1.27
/*/
WSRESTFUL mrpstockbalance DESCRIPTION STR0001 FORMAT APPLICATION_JSON //"Solicitacoes de Compras do MRP"
	WSDATA Fields     AS STRING  OPTIONAL
	WSDATA Order      AS STRING  OPTIONAL
	WSDATA Page       AS INTEGER OPTIONAL
	WSDATA PageSize   AS INTEGER OPTIONAL
	WSDATA branchId   AS STRING  OPTIONAL
	WSDATA code       AS STRING  OPTIONAL

	WSMETHOD GET ALL;
		DESCRIPTION STR0002; //"Retorna todos os Saldos em Estoque do MRP"
		WSSYNTAX "api/pcp/v1/mrpstockbalance" ;
		PATH "/api/pcp/v1/mrpstockbalance" ;
		TTALK "v1"

	WSMETHOD GET STOCKBALANCE;
		DESCRIPTION STR0003; //"Retorna o saldo em estoque de um registro MRP específico"
		WSSYNTAX "api/pcp/v1/mrpstockbalance/{branchId}/{code}" ;
		PATH "/api/pcp/v1/mrpstockbalance/{branchId}/{code}" ;
		TTALK "v1"

	WSMETHOD POST STOCKBALANCE;
		DESCRIPTION STR0004; //"Inclui ou atualiza um ou mais Saldos em Estoque do MRP"
		WSSYNTAX "api/pcp/v1/mrpstockbalance" ;
		PATH "/api/pcp/v1/mrpstockbalance" ;
		TTALK "v1"

	WSMETHOD POST sync;
		DESCRIPTION STR0009; //"Sincronização dos Estoques no MRP"
		WSSYNTAX "api/pcp/v1/mrpstockbalance/sync" ;
		PATH "/api/pcp/v1/mrpstockbalance/sync" ;
		TTALK "v1"

	WSMETHOD DELETE STOCKBALANCE;
		DESCRIPTION STR0005; //"Exclui um ou mais Saldos em Estoque do MRP"
		WSSYNTAX "api/pcp/v1/mrpstockbalance" ;
		PATH "/api/pcp/v1/mrpstockbalance" ;
		TTALK "v1"

	WSMETHOD DELETE DELPRD;
		DESCRIPTION STR0010; //"Zera os saldos de um ou mais produtos em um determinado armazém"
		WSSYNTAX "api/pcp/v1/mrpstockbalance/clearProduct" ;
		PATH "/api/pcp/v1/mrpstockbalance/clearProduct" ;
		TTALK "v1"
ENDWSRESTFUL

/*/{Protheus.doc} GET ALL /api/pcp/v1/mrpstockbalance
Retorna todas as Solicitacoes de Compras MRP

@type  WSMETHOD
@author douglas.heydt
@since 13/06/2019
@version P12.1.27
@param	Order   , caracter, Ordenacao da tabela principal
@param	Page    , numerico, Número da pagina inicial da consulta
@param	PageSize, numerico, Número de registro por paginas
@param	Fields  , caracter, Campos que serão retornados no GET.
@return lRet    , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET ALL QUERYPARAM Order, Page, PageSize, Fields WSSERVICE mrpstockbalance
	Local aReturn := {}
	Local lRet    := .T.

	Self:SetContentType("application/json")

	aReturn := MrpSBAll(Self:aQueryString, Self:Order, Self:Page, Self:PageSize, Self:Fields)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
Return lRet

/*/{Protheus.doc} GET STOCKBALANCE /api/pcp/v1/mrpstockbalance
Retorna uma solicitacao de compras especifica do MRP

@type  WSMETHOD
@author douglas.heydt
@since 13/06/2019
@version P12.1.27
@param	branchId, Character, Codigo da filial para fazer a pesquisa
@param	code    , Character, Codigo único da solicitacao de compras para fazer a pesquisa.
@param	Fields  , Character, Campos que serão retornados no GET.
@return lRet    , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET STOCKBALANCE PATHPARAM branchId, code QUERYPARAM Fields WSSERVICE mrpstockbalance
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a funcao para retornar os dados.
	aReturn := MrpSBGet(Self:branchId, Self:code, Self:Fields)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
Return lRet

/*/{Protheus.doc} POST STOCKBALANCE /api/pcp/v1/mrpstockbalance
Inclui ou altera uma ou mais Solicitacoes de Compras do MRP

@type  WSMETHOD
@author douglas.heydt
@since 13/06/2019
@version P12.1.27
@return lRet, Logico, Informa se o processo foi executado com sucesso.
/*/
WSMETHOD POST STOCKBALANCE WSSERVICE mrpstockbalance
	Local aReturn  := {}
	Local cBody    := ""
	Local cError   := ""
	Local lRet     := .T.
	Local oBody    := JsonObject():New()

	Self:SetContentType("application/json")
	cBody := Self:GetContent()

	cError := oBody:FromJson(cBody)

	If cError == Nil
		aReturn := MrpSBPost(oBody)
		MRPApi():restReturn(Self, aReturn, "POST", @lRet)
	Else
		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
		lRet    := .F.
		SetRestFault(400, EncodeUtf8(STR0006), .T., , cError ) //"Nao foi possível interpretar os dados recebidos."
	EndIf

	FreeObj(oBody)
	oBody := Nil
Return lRet

/*/{Protheus.doc} POST SYNC /api/pcp/v1/mrpstockbalance/sync
Sincronização dos Estoques no MRP (Apaga todas os registros existentes na base, e inclui as recebidas na requisição)

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		brunno.costa
@since		06/08/2019
@version	12.1.28
/*/
WSMETHOD POST sync WSSERVICE mrpstockbalance
	Local aReturn  := {}
	Local cBody    := ""
	Local cError   := ""
	Local lRet     := .T.
	Local oBody    := JsonObject():New()

	Self:SetContentType("application/json")
	cBody := Self:GetContent()

	cError := oBody:FromJson(cBody)

	If cError == Nil
		aReturn := MrpSBSync(oBody)
		MRPApi():restReturn(Self, aReturn, "POST", @lRet)
	Else
		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
		lRet    := .F.
		SetRestFault(400, EncodeUtf8(STR0005), .T., , cError ) //"Não foi possível interpretar os dados recebidos."
	EndIf

	FreeObj(oBody)
	oBody := Nil

Return lRet

/*/{Protheus.doc} DELETE DELPRD /api/pcp/v1/mrpstockbalance/clearProduct
Zera os saldos dos produtos/locais.

@type  WSMETHOD
@author lucas.franca
@since 13/08/2019
@version P12.1.27
@return lRet, Logico, Informa se o processo foi executado com sucesso.
/*/
WSMETHOD DELETE DELPRD WSSERVICE mrpstockbalance
	Local aReturn  := {}
	Local cBody    := ""
	Local cError   := ""
	Local lRet     := .T.
	Local oBody    := JsonObject():New()

	Self:SetContentType("application/json")
	cBody := Self:GetContent()

	cError := oBody:FromJson(cBody)

	If cError == Nil
		aReturn := MrpSBClr(oBody)
		MRPApi():restReturn(Self, aReturn, "DELETE", @lRet)
	Else
		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
		lRet    := .F.
		SetRestFault(400, EncodeUtf8(STR0006), .T., , cError ) //"Nao foi possível interpretar os dados recebidos."
	EndIf

	FreeObj(oBody)
	oBody := Nil
Return lRet

/*/{Protheus.doc} DELETE STOCKBALANCE /api/pcp/v1/mrpstockbalance
Deleta uma ou mais Solicitacoes de Compras do MRP

@type  WSMETHOD
@author douglas.heydt
@since 13/06/2019
@version P12.1.27
@return lRet, Logico, Informa se o processo foi executado com sucesso.
/*/
WSMETHOD DELETE STOCKBALANCE WSSERVICE mrpstockbalance
	Local aReturn  := {}
	Local cBody    := ""
	Local cError   := ""
	Local lRet     := .T.
	Local oBody    := JsonObject():New()

	Self:SetContentType("application/json")
	cBody := Self:GetContent()

	cError := oBody:FromJson(cBody)

	If cError == Nil
		aReturn := MrpSBDel(oBody)
		MRPApi():restReturn(Self, aReturn, "DELETE", @lRet)
	Else
		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
		lRet    := .F.
		SetRestFault(400, EncodeUtf8(STR0006), .T., , cError ) //"Nao foi possível interpretar os dados recebidos."
	EndIf

	FreeObj(oBody)
	oBody := Nil
Return lRet

/*/{Protheus.doc} MrpSBPost
Dispara as acoes da API de Solicitacoes de Compras do MRP, para o metodo POST (Inclusao/Alteracao).

@type    Function
@author  douglas.heydt
@since   13/06/2019
@version P12.1.27
@oaram   oBody, JsonObject, Objeto JSON com as informacoes recebidas no corpo da requisicao.
@return aReturn, Array, Array contendo o Codigo HTTP que devera ser retornado pela API, e o JSON formatado com todos os dados de retorno.
                        Array[1] -> Numeric. Codigo HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                        Array[2] -> Character. JSON no formato definido pela API para ser retornado.
/*/
Function MrpSBPost(oBody)
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

/*/{Protheus.doc} MrpSBSync
Função para disparar as ações da API de Estoques do MRP, para o método Sync (Sincronização).

@type    Function
@author  brunno.costa
@since   06/08/2019
@version P12.1.28
@oaram   oBody, JsonObject, Objeto JSON com as informações recebidas no corpo da requisição.
@param   lBuffer, Lógico, Define a sincronização em processo de buffer.
@return aReturn, Array, Array contendo o código HTTP que deverá ser retornado pela API, e o JSON formatado com todos os dados de retorno.
                        Array[1] -> Numeric. Código HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                        Array[2] -> Character. JSON no formato definido pela API para ser retornado.
/*/
Function MrpSBSync(oBody,lBuffer)
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

/*/{Protheus.doc} MrpSBClr
Dispara as acoes da API de Estoques do MRP, para o metodo DELETE (Exclusao) zerando os estoques por produto+local.

@type  Function
@author lucas.franca
@since 13/08/2019
@version P12.1.27
@oaram oBody, JsonObject, Objeto JSON com as informacoes recebidas no corpo da requisicao.
@return aReturn, Array, Array contendo o Codigo HTTP que devera ser retornado pela API, e o JSON formatado com todos os dados de retorno.
                        Array[1] -> Numeric. Codigo HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                        Array[2] -> Character. JSON no formato definido pela API para ser retornado.
/*/
Function MrpSBClr(oBody)
	Local aReturn  := {201, ""}
	Local oMRPApi  := defMRPApi("DELETE", "", .T.) //Instancia da classe MRPApi para o metodo DELETE

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
/*/{Protheus.doc} MrpSBDel
Dispara as acoes da API de Solicitacoes de Compras do MRP, para o metodo DELETE (Exclusao).

@type  Function
@author douglas.heydt
@since 13/06/2019
@version P12.1.27
@oaram oBody, JsonObject, Objeto JSON com as informacoes recebidas no corpo da requisicao.
@return aReturn, Array, Array contendo o Codigo HTTP que devera ser retornado pela API, e o JSON formatado com todos os dados de retorno.
                        Array[1] -> Numeric. Codigo HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                        Array[2] -> Character. JSON no formato definido pela API para ser retornado.
/*/
Function MrpSBDel(oBody)
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

/*/{Protheus.doc} MrpSBAll
Dispara as acoes da API de Solicitacoes de Compras do MRP, para o metodo GET (Consulta) para varias Solicitacoes de Compras.

@type  Function
@author douglas.heydt
@since 13/06/2019
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
Function MrpSBAll(aQuery, cOrder, nPage, nPageSize, cFields)
	Local aReturn := {}

	//Processa o GET
	aReturn := SBGet(.T., aQuery, cOrder, nPage, nPageSize, cFields)
Return aReturn

/*/{Protheus.doc} MrpSBGet
Funcao para disparar as acoes da API de Solicitacoes de Compras do MRP, para o metodo GET (Consulta) de uma solicitacao de compras especifica.

@type  Function
@author douglas.heydt
@since 13/06/2019
@version P12.1.27
@param cBranch , Caracter, Codigo da filial
@param cCode   , Caracter, Codigo único da solicitacao de compras
@param cFields , Caracter, Campos que devem ser retornados.
@return aReturn, Array, Array com as informacoes da requisicao.
                        aReturn[1] - Logico    - Indica se a requisicao foi processada com sucesso ou Nao.
						aReturn[2] - Character - JSON com o resultado da requisicao, ou com a mensagem de erro.
						aReturn[3] - Numeric   - Codigo de erro identificado pelo MRPApi.
/*/
Function MrpSBGet(cBranch, cCode, cFields)
	Local aReturn   := {}
	Local aQryParam := {}

	//Adiciona os filtros de filial e produto como QueryParam.
	aAdd(aQryParam, {"BRANCHID", cBranch})
	aAdd(aQryParam, {"CODE"    , cCode})

	If !Empty(cFields)
		//Adiciona o FIELDS se for recebido.
		aAdd(aQryParam, {"FIELDS", cFields})
	EndIf

	//Chama a funcao para retornar os dados.
	aReturn := SBGet(.F., aQryParam, Nil, Nil, Nil, cFields)

Return aReturn

/*/{Protheus.doc} MapFields
Gera o array com o MAP dos fields da API e os fields da tabela T4V

@type  Static Function
@author douglas.heydt
@since 13/06/2019
@version P12.1.27
@return aFields, Array, Array contendo o MAP dos fields da API e da tabela
/*/
Static Function MapFields()
	Local aFields := {}
	Local nTamanho
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
	            {"branchId"             	, "T4V_FILIAL"  , "C", FWSizeFilial()                       , 0},;
	            {"product"              	, "T4V_PROD"    , "C", GetSx3Cache("T4V_PROD"  ,"X3_TAMANHO"), 0},;
	            {"warehouse"            	, "T4V_LOCAL"   , "C", GetSx3Cache("T4V_LOCAL" ,"X3_TAMANHO"), 0},;
	            {"lot"                  	, "T4V_LOTE"    , "C", GetSx3Cache("T4V_LOTE"  ,"X3_TAMANHO"), 0},;
	            {"sublot"               	, "T4V_SLOTE"   , "C", GetSx3Cache("T4V_SLOTE" ,"X3_TAMANHO"), 0},;
	            {"expirationDate"       	, "T4V_VALID"   , "D", 8                                    , 0},;
	            {"availableQuantity"    	, "T4V_QTD"     , "N", GetSx3Cache("T4V_QTD"   ,"X3_TAMANHO"), GetSx3Cache("T4V_QTD"  , "X3_DECIMAL")},;
	            {"consignedOut"         	, "T4V_QNPT"    , "N", GetSx3Cache("T4V_QNPT"  ,"X3_TAMANHO"), GetSx3Cache("T4V_QNPT" , "X3_DECIMAL")},;
	            {"consignedIn"          	, "T4V_QTNP"    , "N", GetSx3Cache("T4V_QTNP"  ,"X3_TAMANHO"), 0},;
				{"unavailableQuantity"  	, "T4V_QTIND"   , "N", GetSx3Cache("T4V_QTIND" ,"X3_TAMANHO"), 0},;
	            {"code"                 	, "T4V_IDREG"   , "C", GetSx3Cache("T4V_IDREG" ,"X3_TAMANHO"), 0};
	           }

	nTamanho := GetSx3Cache("T4V_SLDBQ" ,"X3_TAMANHO")
	If !Empty(nTamanho)
		aAdd(aFields, {"blockedBalance", "T4V_SLDBQ"   , "N", GetSx3Cache("T4V_SLDBQ" ,"X3_TAMANHO"), GetSx3Cache("T4V_SLDBQ" , "X3_DECIMAL")})
	EndIf

Return aFields

/*/{Protheus.doc} SBGet
Executa o processamento do metodo GET de acordo com os parametros recebidos.

@type  Static Function
@author douglas.heydt
@since 13/06/2019
@version P12.1.27
@param lLista   , Logic    , Indica se devera retornar uma lista de registros (.T.), ou apenas um registro (.F.).
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
Static Function SBGet(lLista, aQuery, cOrder, nPage, nPageSize, cFields)
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

/*/{Protheus.doc} MrpSBVLD
Funcao responsavel por validar as informacoes recebidas.

@type  Function
@author douglas.heydt
@since 13/06/2019
@version P12.1.27
@param oMRPApi   , Object   , Referência da classe MRPApi que esta processando os dados.
@param cMapCode  , Character, Codigo do mapeamento que sera validado
@param oItem     , Object   , Referência do objeto JSON com os dados que devem ser validados.
@return lRet     , Logico   , Identifica se os dados estão validos.
/*/
Function MrpSBVLD(oMRPApi, cMapCode, oItem)
	Local lRet := .T.

	If cMapCode == "fields"
		If lRet .And. Empty(oItem["code"])
			lRet := .F.
			oMRPApi:SetError(400, STR0007 + " 'code' " + STR0008 + " (T4V_IDREG)") //"Atributo 'XXX' Nao foi informado."
		EndIf

        If lRet .And. Empty(oItem["product"])
			lRet := .F.
			oMRPApi:SetError(400, STR0007 + " 'product' " + STR0008 + " (T4V_PROD)") //"Atributo 'XXX' Nao foi informado."
		EndIf

        If lRet .And. Empty(oItem["warehouse"])
			lRet := .F.
			oMRPApi:SetError(400, STR0007 + " 'warehouse' " + STR0008 + " (T4V_LOCAL)") //"Atributo 'XXX' Nao foi informado."
		EndIf

        If lRet .And. oItem["lot"] == Nil
			lRet := .F.
			oMRPApi:SetError(400, STR0007 + " 'lot' " + STR0008 + " (T4V_LOTE)") //"Atributo 'XXX' Nao foi informado."
		EndIf

        If lRet .And. oItem["availableQuantity"] == Nil
			lRet := .F.
			oMRPApi:SetError(400, STR0007 + " 'availableQuantity' " + STR0008 + " (T4V_QTD)") //"Atributo 'XXX' Nao foi informado."
		EndIf

        If lRet .And. oItem["consignedOut"] == Nil
			lRet := .F.
			oMRPApi:SetError(400, STR0007 + " 'consignedOut' " + STR0008 + " (T4V_QNPT)") //"Atributo 'XXX' Nao foi informado."
		EndIf

        If lRet .And. oItem["consignedIn"] == Nil
			lRet := .F.
			oMRPApi:SetError(400, STR0007 + " 'consignedIn' " + STR0008 + " (T4V_QTNP)") //"Atributo 'XXX' Nao foi informado."
		EndIf

        If lRet .And. oItem["unavailableQuantity"] == Nil
			lRet := .F.
			oMRPApi:SetError(400, STR0007 + " 'unavailableQuantity' " + STR0008 + " (T4V_QTIND)") //"Atributo 'XXX' Nao foi informado."
		EndIf

	EndIf
Return lRet

/*/{Protheus.doc} defMRPApi
Faz a instancia da classe MRPAPI e seta as propriedades basicas.

@type  Static Function
@author douglas.heydt
@since 13/06/2019
@version P12.1.27
@param cMethod  , Character, Metodo que sera executado (GET/POST/DELETE)
@param cOrder   , Character, Ordenacao para o GET
@param lKeyProd , Character, Indica que a chave utilizada será por filial+produto+local
@return oMRPApi , Object   , Referência da classe MRPApi com as definicoes ja executadas.
/*/
Static Function defMRPApi(cMethod, cOrder, lKeyProd)
	Local oMRPApi := MRPApi():New(cMethod)

	Default lKeyProd := .F.

	//Seta o APIMAP do item principal (cabeçalho)
	oMRPApi:setAPIMap("fields", _aMapFields , "T4V", .F., cOrder)

	//Seta os campos utilizados para busca de registros.
	If lKeyProd
		oMRPApi:setKeySearch("fields",{"T4V_FILIAL","T4V_PROD","T4V_LOCAL"})
	Else
		oMRPApi:setKeySearch("fields",{"T4V_FILIAL","T4V_IDREG"})
	EndIf

	If cMethod == "POST"
		//Seta as funções de validação de cada mapeamento.
		oMRPApi:setValidData("fields", "MrpSBVLD")
	EndIf
Return oMRPApi

/*/{Protheus.doc} MrpSBMap
Retorna um array com todos os MapFields utilizados na API

@type    Function
@author  marcelo.neumann
@since   18/10/2019
@version P12.1.27
@return  Array, array com os arrays de MapFields
/*/
Function MrpSBMap()

Return {_aMapFields}
