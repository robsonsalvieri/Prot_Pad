#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "mrpcalendar.CH"

Static _aMapFields := MapFields()

//dummy function
Function MrpCalenda()
Return

/*/{Protheus.doc} mrpcalendar
API de integracao de Calendário do MRP

@type WSCLASS
@author marcelo.neumann
@since 19/06/2019
@version P12.1.27
/*/
WSRESTFUL mrpcalendar DESCRIPTION STR0001 FORMAT APPLICATION_JSON //"Calendário do MRP"
	WSDATA Fields     AS STRING  OPTIONAL
	WSDATA Order      AS STRING  OPTIONAL
	WSDATA Page       AS INTEGER OPTIONAL
	WSDATA PageSize   AS INTEGER OPTIONAL
	WSDATA branchId   AS STRING  OPTIONAL
	WSDATA code       AS STRING  OPTIONAL

	WSMETHOD GET ALL;
		DESCRIPTION STR0002; //"Retorna todos os Calendários do MRP"
		WSSYNTAX "api/pcp/v1/mrpcalendar" ;
		PATH "/api/pcp/v1/mrpcalendar" ;
		TTALK "v1"

	WSMETHOD GET CALENDAR;
		DESCRIPTION STR0003; //"Retorna um Calendário do MRP especifico"
		WSSYNTAX "api/pcp/v1/mrpcalendar/{branchId}/{code}" ;
		PATH "/api/pcp/v1/mrpcalendar/{branchId}/{code}" ;
		TTALK "v1"

	WSMETHOD POST CALENDAR;
		DESCRIPTION STR0004; //"Inclui ou atualiza um ou mais Calendários do MRP"
		WSSYNTAX "api/pcp/v1/mrpcalendar" ;
		PATH "/api/pcp/v1/mrpcalendar" ;
		TTALK "v1"

	WSMETHOD POST sync;
		DESCRIPTION STR0012; //"Sincronização do Calendário no MRP"
		WSSYNTAX "api/pcp/v1/mrpcalendar/sync" ;
		PATH "/api/pcp/v1/mrpcalendar/sync" ;
		TTALK "v1"

	WSMETHOD DELETE CALENDAR;
		DESCRIPTION STR0005; //"Exclui uma ou mais Calendário do MRP"
		WSSYNTAX "api/pcp/v1/mrpcalendar" ;
		PATH "/api/pcp/v1/mrpcalendar" ;
		TTALK "v1"
ENDWSRESTFUL

/*/{Protheus.doc} GET ALL /api/pcp/v1/mrpcalendar
Retorna todos os Calendários MRP

@type WSMETHOD
@author marcelo.neumann
@since 19/06/2019
@version P12.1.27
@param	Order   , caracter, Ordenacao da tabela principal
@param	Page    , numerico, Número da pagina inicial da consulta
@param	PageSize, numerico, Número de registro por paginas
@param	Fields  , caracter, Campos que serão retornados no GET.
@return lRet    , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET ALL QUERYPARAM Order, Page, PageSize, Fields WSSERVICE mrpcalendar
	Local aReturn := {}
	Local lRet    := .T.

	Self:SetContentType("application/json")

	aReturn := MrpCAGAll(Self:aQueryString, Self:Order, Self:Page, Self:PageSize, Self:Fields)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
Return lRet

/*/{Protheus.doc} GET CALENDAR /api/pcp/v1/mrpcalendar
Retorna um calendário especifico do MRP

@type WSMETHOD
@author marcelo.neumann
@since 19/06/2019
@version P12.1.27
@param	branchId, Character, Codigo da filial para fazer a pesquisa
@param	code    , Character, Codigo único do calendário para fazer a pesquisa.
@param	Fields  , Character, Campos que serão retornados no GET.
@return lRet    , Logico   , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET CALENDAR PATHPARAM branchId, code QUERYPARAM Fields WSSERVICE mrpcalendar
	Local aReturn := {}
	Local lRet    := .T.

	Self:SetContentType("application/json")

	//Chama a funcao para retornar os dados.
	aReturn := MrpCAGet(Self:branchId, Self:code, Self:Fields)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
Return lRet

/*/{Protheus.doc} POST CALENDAR /api/pcp/v1/mrpcalendar
Inclui ou altera uma ou mais Calendário do MRP

@type WSMETHOD
@author marcelo.neumann
@since 19/06/2019
@version P12.1.27
@return lRet, Logico, Informa se o processo foi executado com sucesso.
/*/
WSMETHOD POST CALENDAR WSSERVICE mrpcalendar
	Local aReturn := {}
	Local cBody   := ""
	Local cError  := ""
	Local lRet    := .T.
	Local oBody   := JsonObject():New()

	Self:SetContentType("application/json")

	cBody  := Self:GetContent()
	cError := oBody:FromJson(cBody)

	If cError == Nil
		aReturn := MrpCAPost(oBody)
		MRPApi():restReturn(Self, aReturn, "POST", @lRet)
	Else
		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
		lRet := .F.
		SetRestFault(400, EncodeUtf8(STR0006), .T., , cError ) //"Nao foi possível interpretar os dados recebidos."
	EndIf

	FreeObj(oBody)
	oBody := Nil
Return lRet

/*/{Protheus.doc} POST SYNC /api/pcp/v1/mrpcalendar/sync
Sincronização dos Calendários do MRP (Apaga todas os registros existentes na base, e inclui as recebidas na requisição)

@type WSMETHOD
@author Ricardo Prandi
@since 01/08/2019
@version 12.1.28
@return lRet, Lógico, Informa se o processo foi executado com sucesso.
/*/
WSMETHOD POST sync WSSERVICE mrpcalendar
	Local aReturn := {}
	Local cBody   := ""
	Local cError  := ""
	Local lRet    := .T.
	Local oBody   := JsonObject():New()

	Self:SetContentType("application/json")
	cBody  := Self:GetContent()
	cError := oBody:FromJson(cBody)

	If cError == Nil
		aReturn := MrpCASync(oBody)
		MRPApi():restReturn(Self, aReturn, "POST", @lRet)
	Else
		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
		lRet := .F.
		SetRestFault(400, EncodeUtf8(STR0006), .T., , cError ) //"Não foi possível interpretar os dados recebidos."
	EndIf

	FreeObj(oBody)
	oBody := Nil

Return lRet

/*/{Protheus.doc} DELETE CALENDAR /api/pcp/v1/mrpcalendar
Deleta um ou mais Calendários do MRP

@type WSMETHOD
@author marcelo.neumann
@since 19/06/2019
@version P12.1.27
@return lRet, Logico, Informa se o processo foi executado com sucesso.
/*/
WSMETHOD DELETE CALENDAR WSSERVICE mrpcalendar
	Local aReturn := {}
	Local cBody   := ""
	Local cError  := ""
	Local lRet    := .T.
	Local oBody   := JsonObject():New()

	Self:SetContentType("application/json")
	cBody  := Self:GetContent()
	cError := oBody:FromJson(cBody)

	If cError == Nil
		aReturn := MrpCADel(oBody)
		MRPApi():restReturn(Self, aReturn, "DELETE", @lRet)
	Else
		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
		lRet := .F.
		SetRestFault(400, EncodeUtf8(STR0006), .T., , cError ) //"Nao foi possível interpretar os dados recebidos."
	EndIf

	FreeObj(oBody)
	oBody := Nil
Return lRet

/*/{Protheus.doc} MrpCAPost
Dispara as acoes da API de Calendário do MRP, para o metodo POST (Inclusao/Alteracao).

@type Function
@author marcelo.neumann
@since 19/06/2019
@version P12.1.27
@oaram  oBody  , Object, Objeto JSON com as informacoes recebidas no corpo da requisicao.
@return aReturn, Array , Array contendo o Codigo HTTP que devera ser retornado pela API, e o JSON formatado com todos os dados de retorno.
                         Array[1] -> Numeric. Codigo HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                         Array[2] -> Character. JSON no formato definido pela API para ser retornado.
/*/
Function MrpCAPost(oBody)
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

/*/{Protheus.doc} MrpCASync
Função para disparar as ações da API de Calendário do MRP, para o método Sync (Sincronização).

@type Function
@author brunno.costa
@since 05/08/2019
@version P12.1.28
@oaram  oBody  , Object, Objeto JSON com as informações recebidas no corpo da requisição.
@param  lBuffer, Lógico, Define a sincronização em processo de buffer.
@return aReturn, Array , Array contendo o código HTTP que deverá ser retornado pela API, e o JSON formatado com todos os dados de retorno.
                         Array[1] -> Numeric. Código HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                         Array[2] -> Character. JSON no formato definido pela API para ser retornado.
/*/
Function MrpCASync(oBody, lBuffer)
	Local aReturn := {201, ""}
	Local oMRPApi := defMRPApi("POST","") //Instância da classe MRPApi para o método POST

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

/*/{Protheus.doc} MrpCADel
Dispara as acoes da API de Calendário do MRP, para o metodo DELETE (Exclusao).

@type Function
@author marcelo.neumann
@since 19/06/2019
@version P12.1.27
@oaram  oBody  , Object, Objeto JSON com as informacoes recebidas no corpo da requisicao.
@return aReturn, Array , Array contendo o Codigo HTTP que devera ser retornado pela API, e o JSON formatado com todos os dados de retorno.
                         Array[1] -> Numeric. Codigo HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                         Array[2] -> Character. JSON no formato definido pela API para ser retornado.
/*/
Function MrpCADel(oBody)
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

/*/{Protheus.doc} MrpCAGAll
Dispara as acoes da API de Calendário do MRP, para o metodo GET (Consulta) para varias Calendário.

@type Function
@author marcelo.neumann
@since 19/06/2019
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
Function MrpCAGAll(aQuery, cOrder, nPage, nPageSize, cFields)
	Local aReturn := {}

	//Processa o GET
	aReturn := CAGet(.T., aQuery, cOrder, nPage, nPageSize, cFields)
Return aReturn

/*/{Protheus.doc} MrpCAGet
Funcao para disparar as acoes da API de Calendário do MRP, para o metodo GET (Consulta) de um calendário especifico.

@type Function
@author marcelo.neumann
@since 19/06/2019
@version P12.1.27
@param cBranch , Caracter, Codigo da filial
@param cCode   , Caracter, Codigo único da solicitacao de compras
@param cFields , Caracter, Campos que devem ser retornados.
@return aReturn, Array, Array com as informacoes da requisicao.
                        aReturn[1] - Logico    - Indica se a requisicao foi processada com sucesso ou Nao.
						aReturn[2] - Character - JSON com o resultado da requisicao, ou com a mensagem de erro.
						aReturn[3] - Numeric   - Codigo de erro identificado pelo MRPApi.
/*/
Function MrpCAGet(cBranch, cCode, cFields)
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
	aReturn := CAGet(.F., aQryParam, Nil, Nil, Nil, cFields)

Return aReturn

/*/{Protheus.doc} MapFields
Gera o array com o MAP dos fields da API e os fields da tabela HW0

@type Static Function
@author marcelo.neumann
@since 19/06/2019
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
	            {"branchId"  , "HW0_FILIAL", "C", FWSizeFilial()                        , 0},;
	            {"calendar"  , "HW0_CALEND", "C", GetSx3Cache("HW0_CALEND","X3_TAMANHO"), 0},;
	            {"date"      , "HW0_DATA"  , "D", 8                                     , 0},;
	            {"startTime" , "HW0_HRINI" , "C", GetSx3Cache("HW0_HRINI" ,"X3_TAMANHO"), 0},;
	            {"endTime"   , "HW0_HRFIM" , "C", GetSx3Cache("HW0_HRFIM" ,"X3_TAMANHO"), 0},;
	            {"interval"  , "HW0_INTERV", "C", GetSx3Cache("HW0_INTERV","X3_TAMANHO"), 0},;
	            {"totalHours", "HW0_TOTH"  , "C", GetSx3Cache("HW0_TOTH"  ,"X3_TAMANHO"), 0},;
	            {"code"      , "HW0_IDREG" , "C", GetSx3Cache("HW0_IDREG" ,"X3_TAMANHO"), 0} ;
	           }
Return aFields

/*/{Protheus.doc} CAGet
Executa o processamento do metodo GET de acordo com os parametros recebidos.

@type Static Function
@author marcelo.neumann
@since 19/06/2019
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
Static Function CAGet(lLista, aQuery, cOrder, nPage, nPageSize, cFields)
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

/*/{Protheus.doc} MrpCAVLD
Funcao responsavel por validar as informacoes recebidas.

@type Function
@author marcelo.neumann
@since 19/06/2019
@version P12.1.27
@param oMRPApi , Object   , Referência da classe MRPApi que esta processando os dados.
@param cMapCode, Character, Codigo do mapeamento que sera validado
@param oItem   , Object   , Referência do objeto JSON com os dados que devem ser validados.
@return lRet   , Logico   , Identifica se os dados estão validos.
/*/
Function MrpCAVLD(oMRPApi, cMapCode, oItem)
	Local lRet := .T.

	If cMapCode == "fields"
		If Empty(oItem["code"])
			oMRPApi:SetError(400, STR0007 + " 'code' " + STR0008 + " (HW0_IDREG)") //"Atributo 'XXX' não foi informado."
			Return .F.
		EndIf

		If Empty(oItem["calendar"])
			oMRPApi:SetError(400, STR0007 + " 'calendar' " + STR0008 + " (HW0_CALEND)") //"Atributo 'XXX' não foi informado."
			Return .F.
		EndIf

		If Empty(oItem["date"])
			oMRPApi:SetError(400, STR0007 + " 'date' " + STR0008 + " (HW0_DATA)") //"Atributo 'XXX' não foi informado."
			Return .F.
		EndIf

		If Empty(oItem["startTime"])
			oMRPApi:SetError(400, STR0007 + " 'startTime' " + STR0008 + " (HW0_HRINI)") //"Atributo 'XXX' não foi informado."
			Return .F.
		Else
			If !FormatHrOk(oItem["startTime"])
				oMRPApi:SetError(400, STR0007 + " 'startTime' " + STR0009 + " (HW0_HRINI)") //"Atributo 'XXX' deve ser informado no formato de hora (hh:mm)."
				Return .F.
			EndIf
		EndIf

		If oItem["endTime"] == Nil
			oMRPApi:SetError(400, STR0007 + " 'endTime' " + STR0008 + " (HW0_HRFIM)") //"Atributo 'XXX' não foi informado."
			Return .F.
		Else
			If !FormatHrOk(oItem["endTime"])
				oMRPApi:SetError(400, STR0007 + " 'endTime' " + STR0009 + " (HW0_HRFIM)") //"Atributo 'XXX' deve ser informado no formato de hora (hh:mm)."
				Return .F.
			EndIf
		EndIf

		If Empty(oItem["interval"])
			oMRPApi:SetError(400, STR0007 + " 'interval' " + STR0008 + " (HW0_INTERV)") //"Atributo 'XXX' não foi informado."
			Return .F.
		Else
			If !FormatHrOk(oItem["interval"])
				oMRPApi:SetError(400, STR0007 + " 'interval' " + STR0009 + " (HW0_INTERV)") //"Atributo 'XXX' deve ser informado no formato de hora (hh:mm)."
				Return .F.
			EndIf
		EndIf

		If (SubHoras(oItem["startTime"], oItem["endTime"])) > 0
			oMRPApi:SetError(400, STR0007 + " 'startTime' " + STR0010 + " 'endTime'." + " (HW0_HRINI > HW0_HRFIM)") //"Atributo 'XXX' deve ser menor ou igual ao 'endTime'."
			Return .F.
		EndIf

		If Hrs2Min(oItem["endTime"]) - Hrs2Min(oItem["startTime"]) - Hrs2Min(oItem["interval"]) < 0
			oMRPApi:SetError(400, STR0011 + " (HW0_HRFIM - HW0_HRINI - HW0_INTERV < 0)") //"O período informado é inválido. ('endTime' - 'startTime' - 'interval') deve ser maior ou igual a zero."
			Return .F.
		EndIf

		If Empty(oItem["totalHours"])
			oMRPApi:SetError(400, STR0007 + " 'totalHours' " + STR0008 + " (HW0_TOTH)") //"Atributo 'XXX' não foi informado."
			Return .F.
		Else
			If !FormatHrOk(oItem["totalHours"])
				oMRPApi:SetError(400, STR0007 + " 'totalHours' " + STR0009 + " (HW0_TOTH)") //"Atributo 'XXX' deve ser informado no formato de hora (hh:mm)."
				Return .F.
			EndIf
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} defMRPApi
Faz a instancia da classe MRPAPI e seta as propriedades basicas.

@type Static Function
@author marcelo.neumann
@since 19/06/2019
@version P12.1.27
@param cMethod  , Character, Metodo que sera executado (GET/POST/DELETE)
@param cOrder   , Character, Ordenacao para o GET
@return oMRPApi , Object   , Referência da classe MRPApi com as definicoes ja executadas.
/*/
Static Function defMRPApi(cMethod, cOrder)
	Local oMRPApi := MRPApi():New(cMethod)

	//Seta o APIMAP do item principal (cabeçalho)
	oMRPApi:setAPIMap("fields", _aMapFields , "HW0", .F., cOrder)

	//Seta os campos utilizados para busca de registros.
	oMRPApi:setKeySearch("fields",{"HW0_FILIAL","HW0_IDREG"})

	If cMethod == "POST"
		//Seta as funcoes de validacao de cada mapeamento.
		oMRPApi:setValidData("fields", "MrpCAVLD")
	EndIf
Return oMRPApi

/*/{Protheus.doc} FormatHrOk
Valida se o parâmetro passado está no formato de hora "hh:mm"

@type Static Function
@author marcelo.neumann
@since 25/06/2019
@version P12.1.27
@param cHora, Character, Hora a ser validada
@return lOk , Logical  , Indica se a hora está no formato válido (hh:mm)
/*/
Static Function FormatHrOk(cHora)

	Local lOk := .T.

	If !SubStr(cHora, 1, 1) $ "012"
		Return .F.
	EndIf

	If !SubStr(cHora, 2, 1) $ "0123456789"
		Return .F.
	EndIf

	If SubStr(cHora, 3, 1) <> ":"
		Return .F.
	EndIf

	If !SubStr(cHora, 4, 1) $ "012345"
		Return .F.
	EndIf

	If !SubStr(cHora, 5, 1) $ "0123456789"
		Return .F.
	EndIf

	If Val(SubStr(cHora, 1, 2)) > 24
		Return .F.
	Else
		If Val(SubStr(cHora, 1, 2)) == 24 .And. Val(SubStr(cHora, 4, 2)) > 0
			Return .F.
		EndIf
	EndIf

	If Val(SubStr(cHora, 4, 2)) > 59
		Return .F.
	EndIf

Return lOk

/*/{Protheus.doc} MrpCAMap
Retorna um array com todos os MapFields utilizados na API

@type Function
@author marcelo.neumann
@since 18/10/2019
@version P12.1.27
@return Array, array com os arrays de MapFields
/*/
Function MrpCAMap()

Return  {_aMapFields}