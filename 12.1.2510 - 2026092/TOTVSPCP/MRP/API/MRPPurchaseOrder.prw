#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "mrppurchaseorder.CH"

Static _aMapFields := MapFields()

//dummy function
Function MrpPurchas()
Return

/*/{Protheus.doc} mrppurchaseorder
API de integracao de Solicitacoes de Compras do MRP

@type  WSCLASS
@author brunno.costa
@since 13/06/2019
@version P12.1.27
/*/
WSRESTFUL mrppurchaseorder DESCRIPTION STR0001 FORMAT APPLICATION_JSON //"Solicitacoes de Compras do MRP"
	WSDATA Fields     AS STRING  OPTIONAL
	WSDATA Order      AS STRING  OPTIONAL
	WSDATA Page       AS INTEGER OPTIONAL
	WSDATA PageSize   AS INTEGER OPTIONAL
	WSDATA branchId   AS STRING  OPTIONAL
	WSDATA code       AS STRING  OPTIONAL

	WSMETHOD GET ALL;
		DESCRIPTION STR0002; //"Retorna todas as Solicitacoes de Compras do MRP"
		WSSYNTAX "api/pcp/v1/mrppurchaseorder" ;
		PATH "/api/pcp/v1/mrppurchaseorder" ;
		TTALK "v1"

	WSMETHOD GET PURCHASEORDER;
		DESCRIPTION STR0003; //"Retorna uma solicitacao de compras do MRP especifica"
		WSSYNTAX "api/pcp/v1/mrppurchaseorder/{branchId}/{code}" ;
		PATH "/api/pcp/v1/mrppurchaseorder/{branchId}/{code}" ;
		TTALK "v1"

	WSMETHOD POST PURCHASEORDER;
		DESCRIPTION STR0004; //"Inclui ou atualiza uma ou mais Solicitacoes de Compras do MRP"
		WSSYNTAX "api/pcp/v1/mrppurchaseorder" ;
		PATH "/api/pcp/v1/mrppurchaseorder" ;
		TTALK "v1"

	WSMETHOD POST SYNC;
		DESCRIPTION STR0009; //"Sincroniza Solicitações de Compras no MRP"
		WSSYNTAX "api/pcp/v1/mrppurchaseorder/sync" ;
		PATH "/api/pcp/v1/mrppurchaseorder/sync" ;
		TTALK "v1"

	WSMETHOD DELETE PURCHASEORDER;
		DESCRIPTION STR0005; //"Exclui uma ou mais Solicitacoes de Compras do MRP"
		WSSYNTAX "api/pcp/v1/mrppurchaseorder" ;
		PATH "/api/pcp/v1/mrppurchaseorder" ;
		TTALK "v1"
ENDWSRESTFUL

/*/{Protheus.doc} GET ALL /api/pcp/v1/mrppurchaseorder
Retorna todas as Solicitacoes de Compras MRP

@type  WSMETHOD
@author brunno.costa
@since 13/06/2019
@version P12.1.27
@param	Order   , caracter, Ordenacao da tabela principal
@param	Page    , numerico, Número da pagina inicial da consulta
@param	PageSize, numerico, Número de registro por paginas
@param	Fields  , caracter, Campos que serão retornados no GET.
@return lRet    , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET ALL QUERYPARAM Order, Page, PageSize, Fields WSSERVICE mrppurchaseorder
	Local aReturn := {}
	Local lRet    := .T.

	Self:SetContentType("application/json")

	aReturn := MrpSCGAll(Self:aQueryString, Self:Order, Self:Page, Self:PageSize, Self:Fields)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
Return lRet

/*/{Protheus.doc} GET PURCHASEORDER /api/pcp/v1/mrppurchaseorder
Retorna uma solicitacao de compras especifica do MRP

@type  WSMETHOD
@author brunno.costa
@since 13/06/2019
@version P12.1.27
@param	branchId, Character, Codigo da filial para fazer a pesquisa
@param	code    , Character, Codigo único da solicitacao de compras para fazer a pesquisa.
@param	Fields  , Character, Campos que serão retornados no GET.
@return lRet    , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET PURCHASEORDER PATHPARAM branchId, code QUERYPARAM Fields WSSERVICE mrppurchaseorder
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a funcao para retornar os dados.
	aReturn := MrpSCGet(Self:branchId, Self:code, Self:Fields)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
Return lRet

/*/{Protheus.doc} POST PURCHASEORDER /api/pcp/v1/mrppurchaseorder
Inclui ou altera uma ou mais Solicitacoes de Compras do MRP

@type  WSMETHOD
@author brunno.costa
@since 13/06/2019
@version P12.1.27
@return lRet, Logico, Informa se o processo foi executado com sucesso.
/*/
WSMETHOD POST PURCHASEORDER WSSERVICE mrppurchaseorder
	Local aReturn  := {}
	Local cBody    := ""
	Local cError   := ""
	Local lRet     := .T.
	Local oBody    := JsonObject():New()

	Self:SetContentType("application/json")
	cBody := Self:GetContent()

	cError := oBody:FromJson(cBody)

	If cError == Nil
		aReturn := MrpSCPost(oBody)
		MRPApi():restReturn(Self, aReturn, "POST", @lRet)
	Else
		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
		lRet    := .F.
		SetRestFault(400, EncodeUtf8(STR0006), .T., , cError ) //"Nao foi possível interpretar os dados recebidos."
	EndIf

	FreeObj(oBody)
	oBody := Nil
Return lRet

/*/{Protheus.doc} POST PURCHASEORDER /api/pcp/v1/mrppurchaseorder/sync
Sincronização das Solicitações de Compra no MRP (Apaga todas os registros existentes na base, e inclui as recebidas na requisição)

@type  WSMETHOD
@author marcelo.neumann
@since 05/08/2019
@version P12.1.27
@return lRet, Logico, Informa se o processo foi executado com sucesso.
/*/
WSMETHOD POST SYNC WSSERVICE mrppurchaseorder
	Local aReturn  := {}
	Local cBody    := ""
	Local cError   := ""
	Local lRet     := .T.
	Local oBody    := JsonObject():New()

	Self:SetContentType("application/json")
	cBody := Self:GetContent()

	cError := oBody:FromJson(cBody)

	If cError == Nil
		aReturn := MrpSCSync(oBody)
		MRPApi():restReturn(Self, aReturn, "POST", @lRet)
	Else
		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
		lRet    := .F.
		SetRestFault(400, EncodeUtf8(STR0006), .T., , cError ) //"Nao foi possível interpretar os dados recebidos."
	EndIf

	FreeObj(oBody)
	oBody := Nil
Return lRet

/*/{Protheus.doc} DELETE PURCHASEORDER /api/pcp/v1/mrppurchaseorder
Deleta uma ou mais Solicitacoes de Compras do MRP

@type  WSMETHOD
@author brunno.costa
@since 13/06/2019
@version P12.1.27
@return lRet, Logico, Informa se o processo foi executado com sucesso.
/*/
WSMETHOD DELETE PURCHASEORDER WSSERVICE mrppurchaseorder
	Local aReturn  := {}
	Local cBody    := ""
	Local cError   := ""
	Local lRet     := .T.
	Local oBody    := JsonObject():New()

	Self:SetContentType("application/json")
	cBody := Self:GetContent()

	cError := oBody:FromJson(cBody)

	If cError == Nil
		aReturn := MrpSCDel(oBody)
		MRPApi():restReturn(Self, aReturn, "DELETE", @lRet)
	Else
		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
		lRet    := .F.
		SetRestFault(400, EncodeUtf8(STR0006), .T., , cError ) //"Nao foi possível interpretar os dados recebidos."
	EndIf

	FreeObj(oBody)
	oBody := Nil
Return lRet

/*/{Protheus.doc} MrpSCPost
Dispara as acoes da API de Solicitacoes de Compras do MRP, para o metodo POST (Inclusao/Alteracao).

@type    Function
@author  brunno.costa
@since   13/06/2019
@version P12.1.27
@oaram   oBody, JsonObject, Objeto JSON com as informacoes recebidas no corpo da requisicao.
@return aReturn, Array, Array contendo o Codigo HTTP que devera ser retornado pela API, e o JSON formatado com todos os dados de retorno.
                        Array[1] -> Numeric. Codigo HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                        Array[2] -> Character. JSON no formato definido pela API para ser retornado.
/*/
Function MrpSCPost(oBody)
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

/*/{Protheus.doc} MrpSCSync
Dispara as acoes da API de Solicitacoes de Compras do MRP, para o metodo Sync (Sincronização).

@type    Function
@author  marcelo.neumann
@since   05/08/2019
@version P12.1.27
@oaram   oBody, JsonObject, Objeto JSON com as informacoes recebidas no corpo da requisicao.
@param   lBuffer, Lógico, Define a sincronização em processo de buffer.
@return aReturn, Array, Array contendo o Codigo HTTP que devera ser retornado pela API, e o JSON formatado com todos os dados de retorno.
                        Array[1] -> Numeric. Codigo HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                        Array[2] -> Character. JSON no formato definido pela API para ser retornado.
/*/
Function MrpSCSync(oBody,lBuffer)
	Local aReturn := {201, ""}
	Local oMRPApi := defMRPApi("POST","") //Instancia da classe MRPApi para o metodo POST

	Default lBuffer := .F.

	//Adiciona os parametros recebidos no corpo da requisicao (BODY)
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

	//Libera o objeto MRPApi da memoria.
	oMRPApi:Destroy()
	FreeObj(oMRPApi)
	oMRPApi := Nil
Return aReturn

/*/{Protheus.doc} MrpSCDel
Dispara as acoes da API de Solicitacoes de Compras do MRP, para o metodo DELETE (Exclusao).

@type  Function
@author brunno.costa
@since 13/06/2019
@version P12.1.27
@oaram oBody, JsonObject, Objeto JSON com as informacoes recebidas no corpo da requisicao.
@return aReturn, Array, Array contendo o Codigo HTTP que devera ser retornado pela API, e o JSON formatado com todos os dados de retorno.
                        Array[1] -> Numeric. Codigo HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                        Array[2] -> Character. JSON no formato definido pela API para ser retornado.
/*/
Function MrpSCDel(oBody)
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

/*/{Protheus.doc} MrpSCGAll
Dispara as acoes da API de Solicitacoes de Compras do MRP, para o metodo GET (Consulta) para varias Solicitacoes de Compras.

@type  Function
@author brunno.costa
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
Function MrpSCGAll(aQuery, cOrder, nPage, nPageSize, cFields)
	Local aReturn := {}

	//Processa o GET
	aReturn := SCGet(.T., aQuery, cOrder, nPage, nPageSize, cFields)
Return aReturn

/*/{Protheus.doc} MrpSCGet
Funcao para disparar as acoes da API de Solicitacoes de Compras do MRP, para o metodo GET (Consulta) de uma solicitacao de compras especifica.

@type  Function
@author brunno.costa
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
Function MrpSCGet(cBranch, cCode, cFields)
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
	aReturn := SCGet(.F., aQryParam, Nil, Nil, Nil, cFields)

Return aReturn

/*/{Protheus.doc} MapFields
Gera o array com o MAP dos fields da API e os fields da tabela T4T

@type  Static Function
@author brunno.costa
@since 13/06/2019
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
	            {"branchId"           , "T4T_FILIAL", "C", FWSizeFilial()                       , 0},;
	            {"purchase"           , "T4T_NUM"   , "C", GetSx3Cache("T4T_NUM"  ,"X3_TAMANHO"), 0},;
	            {"sequence"           , "T4T_SEQ"   , "C", GetSx3Cache("T4T_SEQ"  ,"X3_TAMANHO"), 0},;
	            {"product"            , "T4T_PROD"  , "C", GetSx3Cache("T4T_PROD" ,"X3_TAMANHO"), 0},;
	            {"productionOrder"    , "T4T_OP"    , "C", GetSx3Cache("T4T_OP"   ,"X3_TAMANHO"), 0},;
	            {"deliveryDate"       , "T4T_DTENT" , "D", 8                                    , 0},;
	            {"quantity"           , "T4T_QTD"   , "N", GetSx3Cache("T4T_QTD"  ,"X3_TAMANHO"), GetSx3Cache("T4T_QTD"  , "X3_DECIMAL")},;
	            {"receivedQuantity"   , "T4T_QUJE"  , "N", GetSx3Cache("T4T_QUJE" ,"X3_TAMANHO"), GetSx3Cache("T4T_QUJE" , "X3_DECIMAL")},;
	            {"warehouse"          , "T4T_LOCAL" , "C", GetSx3Cache("T4T_LOCAL","X3_TAMANHO"), 0},;
				{"type"               , "T4T_TIPO"  , "C", GetSx3Cache("T4T_TIPO" ,"X3_TAMANHO"), 0},;
	            {"code"               , "T4T_IDREG" , "C", GetSx3Cache("T4T_IDREG","X3_TAMANHO"), 0};
	           }
    
	//MANSMARTSQUAD1-30175 - Inclusão C1_APROV na T4T
	dbSelectArea("T4T")
	If FieldPos("T4T_APROV") > 0
        aAdd(aFields, {"approved"           , "T4T_APROV" , "C", GetSx3Cache("T4T_APROV","X3_TAMANHO"), 0})
	EndIf

	If mrpGrdT4T()
		aAdd(aFields, {"itemGrade", "T4T_ITGRD" , "C", GetSx3Cache("T4T_ITGRD","X3_TAMANHO"), 0})
		aAdd(aFields, {"document" , "T4T_DOCUM" , "C", GetSx3Cache("T4T_DOCUM","X3_TAMANHO"), 0})
	EndIf

Return aFields

/*/{Protheus.doc} SCGet
Executa o processamento do metodo GET de acordo com os parametros recebidos.

@type  Static Function
@author brunno.costa
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
Static Function SCGet(lLista, aQuery, cOrder, nPage, nPageSize, cFields)
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

/*/{Protheus.doc} MrpSCVLD
Funcao responsavel por validar as informacoes recebidas.

@type  Function
@author brunno.costa
@since 13/06/2019
@version P12.1.27
@param oMRPApi   , Object   , Referência da classe MRPApi que esta processando os dados.
@param cMapCode  , Character, Codigo do mapeamento que sera validado
@param oItem     , Object   , Referência do objeto JSON com os dados que devem ser validados.
@return lRet     , Logico   , Identifica se os dados estão validos.
/*/
Function MrpSCVLD(oMRPApi, cMapCode, oItem)
	Local lRet := .T.

	If cMapCode == "fields"
		If lRet .And. Empty(oItem["code"])
			lRet := .F.
			oMRPApi:SetError(400, STR0007 + " 'code' " + STR0008 + " (T4T_IDREG)") //"Atributo 'XXX' Nao foi informado."
		EndIf

		If lRet .And. Empty(oItem["purchase"])
			lRet := .F.
			oMRPApi:SetError(400, STR0007 + " 'purchase' " + STR0008 + " (T4T_NUM)") //"Atributo 'XXX' Nao foi informado."
		EndIf

		If lRet .And. Empty(oItem["product"])
			lRet := .F.
			oMRPApi:SetError(400, STR0007 + " 'product' " + STR0008 + " (T4T_PROD)") //"Atributo 'XXX' Nao foi informado."
		EndIf

		If lRet .And. Empty(oItem["quantity"])
			lRet := .F.
			oMRPApi:SetError(400, STR0007 + " 'quantity' " + STR0008 + " (T4T_QTD)") //"Atributo 'XXX' Nao foi informado."
		EndIf

		If lRet .And. oItem["receivedQuantity"] == Nil
			lRet := .F.
			oMRPApi:SetError(400, STR0007 + " 'receivedQuantity' " + STR0008 + " (T4T_QUJE)") //"Atributo 'XXX' Nao foi informado."
		EndIf
		If lRet .And. Empty(oItem["warehouse"])
			lRet := .F.
			oMRPApi:SetError(400, STR0007 + " 'warehouse' " + STR0008 + " (T4T_LOCAL)") //"Atributo 'XXX' Nao foi informado."
		EndIf
		If lRet .And. Empty(oItem["type"])
			lRet := .F.
			oMRPApi:SetError(400, STR0007 + " 'type' " + STR0008 + " (T4T_TIPO)") //"Atributo 'XXX' Nao foi informado."
		EndIf

		If lRet .And. mrpGrdT4T() .And. Empty(oItem["document"])
			lRet := .F.
			oMRPApi:SetError(400, STR0007 + " 'document' " + STR0008 + " (T4T_DOCUM)") //"Atributo 'XXX' Nao foi informado."
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} defMRPApi
Faz a instancia da classe MRPAPI e seta as propriedades basicas.

@type  Static Function
@author brunno.costa
@since 13/06/2019
@version P12.1.27
@param cMethod  , Character, Metodo que sera executado (GET/POST/DELETE)
@param cOrder   , Character, Ordenacao para o GET
@return oMRPApi , Object   , Referência da classe MRPApi com as definicoes ja executadas.
/*/
Static Function defMRPApi(cMethod, cOrder)
	Local oMRPApi := MRPApi():New(cMethod)

	//Seta o APIMAP do item principal (cabeçalho)
	oMRPApi:setAPIMap("fields", _aMapFields , "T4T", .F., cOrder)

	//Seta os campos utilizados para busca de registros.
	oMRPApi:setKeySearch("fields",{"T4T_FILIAL","T4T_IDREG"})

	If cMethod == "POST"
		//Seta as funções de validação de cada mapeamento.
		oMRPApi:setValidData("fields", "MrpSCVLD")
	EndIf
Return oMRPApi

/*/{Protheus.doc} MrpSCMap
Retorna um array com todos os MapFields utilizados na API

@type    Function
@author  marcelo.neumann
@since   18/10/2019
@version P12.1.27
@return  Array, array com os arrays de MapFields
/*/
Function MrpSCMap()
Return {_aMapFields}



