#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "MRPDemand.CH"

Static _aMapField := MapFields()

//dummy function
Function demands()
Return

/*/{Protheus.doc} Demandas do MRP
API de integração de Demandas do MRP

@author		Douglas Heydt
@since		10/04/2018
/*/
WSRESTFUL mrpdemands DESCRIPTION STR0029 FORMAT APPLICATION_JSON //"Demandas do MRP"
    WSDATA Fields     AS STRING  OPTIONAL
    WSDATA Order      AS STRING  OPTIONAL
    WSDATA Page       AS INTEGER OPTIONAL
    WSDATA PageSize   AS INTEGER OPTIONAL
    WSDATA branchId   AS STRING  OPTIONAL
    WSDATA code       AS STRING  OPTIONAL

    WSMETHOD GET Demand;
        DESCRIPTION STR0001;//"Retorna todas as demandas do MRP"
    WSSYNTAX "api/pcp/v1/mrpdemands" ;
        PATH "/api/pcp/v1/mrpdemands" ;
        TTALK "v1"

    WSMETHOD GET code;
        DESCRIPTION STR0002;//"Retorna um registro específico de demandas"
    WSSYNTAX "api/pcp/v1/mrpdemands/{branchId}/{code}" ;
        PATH "/api/pcp/v1/mrpdemands/{branchId}/{code}" ;
        TTALK "v1"

    WSMETHOD POST Demand;
        DESCRIPTION STR0005; //"Inclui ou atualiza uma ou mais demandas do MRP"
    WSSYNTAX "api/pcp/v1/mrpdemands" ;
        PATH "/api/pcp/v1/mrpdemands" ;
        TTALK "v1"

    WSMETHOD POST Sync;
        DESCRIPTION STR0030; //"Sincronização das demandas do MRP"
    WSSYNTAX "api/pcp/v1/mrpdemands/sync" ;
        PATH "/api/pcp/v1/mrpdemands/sync" ;
        TTALK "v1"

    WSMETHOD DELETE Demand;
        DESCRIPTION STR0006; //"Exclui uma ou mais demandas do MRP"
    WSSYNTAX "api/pcp/v1/mrpdemands" ;
        PATH "/api/pcp/v1/mrpdemands" ;
        TTALK "v1"

ENDWSRESTFUL

/*/{Protheus.doc} GET /api/pcp/v1/mrpdemands
Retorna todas as demandas MRP

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET

@return lRet	, Lógico, Informa se o processo foi executado com sucesso

@author		Douglas Heydt
@since		16/04/2019
@version	12.1.23
/*/
WSMETHOD GET Demand WSRECEIVE Order, Page, PageSize, Fields WSSERVICE mrpdemands
    Local aReturn := {}
    Local lRet    := .T.

    Self:SetContentType("application/json")

    aReturn := MrpDemGAll(Self:aQueryString, Self:Order, Self:Page, Self:PageSize, Self:Fields)
    MRPApi():restReturn(Self, aReturn, "GET", @lRet)

Return lRet

/*/{Protheus.doc} GET /api/pcp/v1/mrpdemands/{branchId}/{code}
Retorna um registro específico de demandas

@param	branchId, caracter, Código da filial para utilizar na consulta,
@param	code    , caracter, Código da demanda para utilizar na consulta.
@param	Fields  , caracter, Campos que serão retornados no GET.

@return lRet    , Lógico, Informa se o processo foi executado com sucesso.

@author		Douglas Heydt
@since		16/04/2019
@version	12.1.23
/*/
WSMETHOD GET code PATHPARAM branchId, code WSRECEIVE Fields WSSERVICE mrpdemands
    Local aReturn   := {}
    Local lRet      := .T.

    Self:SetContentType("application/json")

    //Chama a função para retornar os dados
    aReturn := MrpDemGCod(Self:branchId, Self:code, Self:Fields)
    MRPApi():restReturn(Self, aReturn, "GET", @lRet)
Return lRet

/*/{Protheus.doc} POST /api/pcp/v1/mrpdemands
Cadastra uma nova demanda MRP

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Douglas Heydt
@since		16/04/2019
@version	12.1.23
/*/
WSMETHOD POST Demand WSSERVICE mrpdemands
    Local aReturn  := {}
    Local cBody    := ""
    Local cError   := ""
    Local lRet     := .T.
    Local oBody    := JsonObject():New()

    Self:SetContentType("application/json")
    cBody := Self:GetContent()

    cError := oBody:FromJson(cBody)

    If cError == Nil
        aReturn := MrpDemPost(oBody)
        MRPApi():restReturn(Self, aReturn, "POST", @lRet)
    Else
        //Ocorreu erro ao transformar os dados recebidos em objeto JSON
        lRet    := .F.
        SetRestFault(400, EncodeUtf8(STR0016), .T., , cError ) //"Não foi possível interpretar os dados recebidos."
    EndIf

    FreeObj(oBody)
    oBody := Nil

Return lRet

/*/{Protheus.doc} POST /api/pcp/v1/mrpdemands/sync
Sincronização de demandas do MRP (Apaga todas as demandas existentes na base, e inclui as recebidas na requisição)

@author  lucas.franca
@since   29/07/2019
@version 12.1.28
@return lRet, Lógico, Informa se o processo foi executado com sucesso.
/*/
WSMETHOD POST Sync WSSERVICE mrpdemands
    Local aReturn  := {}
    Local cBody    := ""
    Local cError   := ""
    Local lRet     := .T.
    Local oBody    := JsonObject():New()

    Self:SetContentType("application/json")
    cBody := Self:GetContent()

    cError := oBody:FromJson(cBody)

    If cError == Nil
        aReturn := MrpDemSync(oBody)
        MRPApi():restReturn(Self, aReturn, "POST", @lRet)
    Else
        //Ocorreu erro ao transformar os dados recebidos em objeto JSON.
        lRet    := .F.
        SetRestFault(400, EncodeUtf8(STR0016), .T., , cError ) //"Não foi possível interpretar os dados recebidos."
    EndIf

    FreeObj(oBody)
    oBody := Nil

Return lRet

/*/{Protheus.doc} DELETE /api/pcp/v1/mrpdemands/
Exclui um registro de demanda MRP

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Douglas Heydt
@since		16/04/2019
@version	12.1.23
/*/
WSMETHOD DELETE Demand WSSERVICE mrpdemands
    Local aReturn  := {}
    Local cBody    := ""
    Local cError   := ""
    Local lRet     := .T.
    Local oBody    := JsonObject():New()

    Self:SetContentType("application/json")
    cBody := Self:GetContent()

    cError := oBody:FromJson(cBody)

    If cError == Nil
        aReturn := MrpDemDel(oBody)
        MRPApi():restReturn(Self, aReturn, "DELETE", @lRet)
    Else
        //Ocorreu erro ao transformar os dados recebidos em objeto JSON.
        lRet    := .F.
        SetRestFault(400, EncodeUtf8(STR0016), .T., , cError ) //"Não foi possível interpretar os dados recebidos."
    EndIf

    FreeObj(oBody)
    oBody := Nil

Return lRet

/*/{Protheus.doc} MapFields
Gera o array com o MAP dos fields da API e os fields da tabela T4J

@type  Static Function
@author lucas.franca
@since 24/04/2019
@version P12.1.25
@return aFields, Array, Array contendo o MAP dos fields da API e da tabela
/*/
Static Function MapFields()
    Local nTamanho := 0
    Local aFields  := {{"branchId"         , "T4J_FILIAL", "C", FWSizeFilial()                        , 0},;
	                   {"date"             , "T4J_DATA"  , "D", 8                                     , 0},;
	                   {"product"          , "T4J_PROD"  , "C", GetSx3Cache("T4J_PROD"  ,"X3_TAMANHO"), 0},;
	                   {"revision"         , "T4J_REV"   , "C", GetSx3Cache("T4J_REV"   ,"X3_TAMANHO"), 0},;
	                   {"source"           , "T4J_ORIGEM", "C", GetSx3Cache("T4J_ORIGEM","X3_TAMANHO"), 0},;
	                   {"document"         , "T4J_DOC"   , "C", GetSx3Cache("T4J_DOC"   ,"X3_TAMANHO"), 0},;
	                   {"quantity"         , "T4J_QUANT" , "N", GetSx3Cache("T4J_QUANT" ,"X3_TAMANHO"), GetSx3Cache("T4J_QUANT" ,"X3_DECIMAL")},;
	                   {"warehouse"        , "T4J_LOCAL" , "C", GetSx3Cache("T4J_LOCAL" ,"X3_TAMANHO"), 0},;
	                   {"processed"        , "T4J_PROC"  , "C", GetSx3Cache("T4J_PROC"  ,"X3_TAMANHO"), 0},;
	                   {"code"             , "T4J_IDREG" , "C", GetSx3Cache("T4J_IDREG" ,"X3_TAMANHO"), 0},;
	                   {"optional"         , "T4J_MOPC"  , "O", 80                                    , 0},;
	                   {"erpMemoOptional"  , "T4J_ERPMOP", "M", 10                                    , 0},;
	                   {"erpStringOptional", "T4J_ERPOPC", "C", GetSx3Cache("T4J_ERPOPC","X3_TAMANHO"), 0};
	                   }

	nTamanho := GetSx3Cache("T4J_NRMRP" ,"X3_TAMANHO")
	If !Empty(nTamanho)
		aAdd(aFields, {"ticket", "T4J_NRMRP" , "C", nTamanho, 0} )
	EndIf

	nTamanho := GetSx3Cache("T4J_CODE" ,"X3_TAMANHO")
	If !Empty(nTamanho)
		aAdd(aFields, {"demandCode", "T4J_CODE", "C", nTamanho, 0} )
	EndIf
Return aFields

/*/{Protheus.doc} MRPDEMVLD
Função para validar os dados recebidos na API

@type  Static Function
@author lucas.franca
@since 26/04/2019
@version P12.1.25
@param oMRPApi   , Object   , Referência da classe MRPApi que está processando os dados.
@param cMapCode  , Character, Código do mapeamento que será validado
@param oItem     , Object   , Referência do objeto JSON com os dados que devem ser validados.
@return lRet     , Lógico   , Identifica se os dados estão válidos.
/*/
Function MRPDEMVLD(oMRPApi, cMapCode, oItem)
    Local lRet   := .T.
    Local nTam   := 0
    Local nIndex := 0

    If lRet .And. Empty(oItem["code"])
        lRet     := .F.
        oMRPApi:SetError(400, STR0018 + " 'code' " + STR0022 + " (T4J_IDREG)") //"Atributo 'XXX' não foi informado."
    EndIf

    If oMRPApi:cMethod == "POST"
        //Valida a quantidade
        If lRet .And. oItem["quantity"] == Nil
            lRet     := .F.
            oMRPApi:SetError(400, STR0018 + " 'quantity' " + STR0022 + " (T4J_QUANT)") //"Atributo 'XXX' não foi informado."
        EndIf

        If lRet .And. oItem["quantity"] <= 0
            lRet     := .F.
            oMRPApi:SetError(400, STR0023 + " (T4J_QUANT)") //"Quantidade não pode ser menor que 0."
        EndIf

        //Valida a data
        If lRet .And. oItem["date"] == Nil
            lRet     := .F.
            oMRPApi:SetError(400, STR0018 + " 'date' " + STR0022 + " (T4J_DATA)") //"Atributo 'XXX' não foi informado."
        EndIf

        //Valida se os opcionais estão no formato correto.
        If lRet .And. oItem["optional"] != Nil
            If ValType(oItem["optional"]) != "A"
                lRet     := .F.
                oMRPApi:SetError(400, STR0018 + " 'optional' " + STR0020 + " (T4J_MOPC)") //"Atributo 'XXX' enviado em formato incorreto."
            EndIf
            If lRet
                nTam := Len(oItem["optional"])
                For nIndex := 1 To nTam
                    If oItem["optional"][nIndex]["key"] == Nil
                        lRet     := .F.
                        oMRPApi:SetError(400, STR0018 + " 'key' " + STR0024 + " (T4J_MOPC)") //"Atributo 'XXX' não informado para os opcionais."
                        Exit
                    EndIf
                    If oItem["optional"][nIndex]["value"] == Nil
                        lRet     := .F.
                        oMRPApi:SetError(400, STR0018 + " 'value' " + STR0024 + " (T4J_MOPC)") //"Atributo 'XXX' não informado para os opcionais."
                        Exit
                    EndIf
                Next nIndex
            EndIf
        EndIf
    EndIf
Return lRet

/*/{Protheus.doc} MrpDemPost
Função para disparar as ações da API de Demandas do MRP, para o método POST (Inclusão/Alteração).

@type    Function
@author  lucas.franca
@since   24/04/2019
@version P12.1.25
@oaram   oBody, JsonObject, Objeto JSON com as informações recebidas no corpo da requisição.
@return aReturn, Array, Array contendo o código HTTP que deverá ser retornado pela API, e o JSON formatado com todos os dados de retorno.
                        Array[1] -> Numeric. Código HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                        Array[2] -> Character. JSON no formato definido pela API para ser retornado.
/*/
Function MrpDemPost(oBody)
    Local aReturn := {201, ""}
    Local oMRPApi := defMRPApi("POST","") //Instância da classe MRPApi para o método POST

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

/*/{Protheus.doc} MrpDemSync
Função para disparar as ações da API de Demandas do MRP, para o método de sincronização.
Sincronização irá apagar os dados existentes na tabela do MRP, e incluir os novos recebidos.

@type    Function
@author  lucas.franca
@since   29/07/2019
@version P12.1.25
@oaram   oBody, JsonObject, Objeto JSON com as informações recebidas no corpo da requisição.
@param   lBuffer, Lógico, Define a sincronização em processo de buffer.
@return aReturn, Array, Array contendo o código HTTP que deverá ser retornado pela API, e o JSON formatado com todos os dados de retorno.
                        Array[1] -> Numeric. Código HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                        Array[2] -> Character. JSON no formato definido pela API para ser retornado.
/*/
Function MrpDemSync(oBody, lBuffer)
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

/*/{Protheus.doc} MrpDemDel
Função para disparar as ações da API de Demandas do MRP, para o método DELETE (Exclusão).

@type  Function
@author lucas.franca
@since 24/04/2019
@version P12.1.25
@oaram oBody, JsonObject, Objeto JSON com as informações recebidas no corpo da requisição.
@return aReturn, Array, Array contendo o código HTTP que deverá ser retornado pela API, e o JSON formatado com todos os dados de retorno.
                        Array[1] -> Numeric. Código HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                        Array[2] -> Character. JSON no formato definido pela API para ser retornado.
/*/
Function MrpDemDel(oBody)
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

/*/{Protheus.doc} MrpDemGCod
Função para disparar as ações da API de Demandas do MRP, para o método GET (Consulta) de um código específico.

@type  Function
@author lucas.franca
@since 24/04/2019
@version P12.1.25
@param param, param_type, param_descr
@return aReturn, Array, Array com as informações da requisição.
                        aReturn[1] - Lógico    - Indica se a requisição foi processada com sucesso ou não.
						aReturn[2] - Character - JSON com o resultado da requisição, ou com a mensagem de erro.
						aReturn[3] - Numeric   - Código de erro identificado pelo FwApiManager.
/*/
Function MrpDemGCod(cBranch, cCode, cFields)
    Local aReturn := {}
    Local aQryParam := {}

    //Adiciona os filtros de filial e produto como QueryParam.
    aAdd(aQryParam, {"BRANCHID", cBranch})
    aAdd(aQryParam, {"CODE"    , cCode})

    If !Empty(cFields)
        //Adiciona o FIELDS se for recebido.
        aAdd(aQryParam, {"FIELDS", cFields})
    EndIf

    //Processa o GET
    aReturn := DemandGet(.F., aQryParam, Nil, Nil, Nil, cFields)
Return aReturn

/*/{Protheus.doc} MrpDemGAll
Função para disparar as ações da API de Demandas do MRP, para o método GET (Consulta) para várias demandas.

@type  Function
@author lucas.franca
@since 24/04/2019
@version P12.1.25
@param aQuery   , Array    , Array com os dados que devem ser filtrados.
                             Exemplo: Array[1]
                                      Array[1][1] = "PRODUCT"
                                      Array[1][2] = "PRODUTO001"
                                      Array[2]
                                      Array[2][1] = "DATE"
                                      Array[2][2] = "2019-04-24"
@param cOrder   , Character, Ordenação desejada do retorno.
@param nPage    , Numeric  , Página dos dados. Se não enviado, considera página 1.
@param nPageSize, Numeric  , Quantidade de registros retornados por página. Se não enviado, considera 20 registros por página.
@param cFields  , Character, Campos que devem ser retornados. Se não enviado, retorna todos os fields que possuem valor.
@return aReturn , Array    , Array com as informações da requisição.
                             aReturn[1] - Lógico    - Indica se a requisição foi processada com sucesso ou não.
						     aReturn[2] - Character - JSON com o resultado da requisição, ou com a mensagem de erro.
						     aReturn[3] - Numeric   - Código de erro identificado pelo FwApiManager.
/*/
Function MrpDemGAll(aQuery, cOrder, nPage, nPageSize, cFields)
    Local aReturn := {}

    //Processa o GET
    aReturn := DemandGet(.T., aQuery, cOrder, nPage, nPageSize, cFields)
Return aReturn

/*/{Protheus.doc} DemandGet
Função que dispara o processamento do método GET

@type  Static Function
@author lucas.franca
@since 20/06/2019
@version P12.1.27
@param lLista   , Logic    , Indica se deverá retornar uma lista de registros (.T.), ou apenas um registro (.F.).
@param aQuery   , Array    , Array com os dados que devem ser filtrados.
                             Exemplo: Array[1]
                                      Array[1][1] = "PRODUCT"
                                      Array[1][2] = "PRODUTO001"
                                      Array[2]
                                      Array[2][1] = "DOCUMENT"
                                      Array[2][2] = "8554255"
@param cOrder   , Character, Ordenação desejada do retorno.
@param nPage    , Numeric  , Página dos dados. Se não enviado, considera página 1.
@param nPageSize, Numeric  , Quantidade de registros retornados por página. Se não enviado, considera 20 registros por página.
@param cFields  , Character, Campos que devem ser retornados. Se não enviado, retorna todos os fields que possuem valor.
@return aReturn , Array    , Array com as informações da requisição.
                             aReturn[1] - Lógico    - Indica se a requisição foi processada com sucesso ou não.
						     aReturn[2] - Character - JSON com o resultado da requisição, ou com a mensagem de erro.
						     aReturn[3] - Numeric   - Código de erro identificado pelo MRPApi.
/*/
Static Function DemandGet(lLista, aQuery, cOrder, nPage, nPageSize, cFields)
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
    oMRPApi:setAPIMap("fields", _aMapField , "T4J", .F., cOrder)

    //Seta os campos utilizados para busca de registros.
    oMRPApi:setKeySearch("fields",{"T4J_FILIAL","T4J_IDREG"})

    If cMethod == "POST"
        //Seta as funções de validação de cada mapeamento.
        oMRPApi:setValidData("fields", "MRPDEMVLD")

        //seta valores default
        oMRPApi:setDefaultValues("fields", "source"   , "1")
        oMRPApi:setDefaultValues("fields", "processed", "2")
    EndIf
Return oMRPApi

/*/{Protheus.doc} MrpDemMap
Retorna um array com todos os MapFields utilizados na API

@type    Function
@author  marcelo.neumann
@since   18/10/2019
@version P12.1.27
@return  Array, array com os arrays de MapFields
/*/
Function MrpDemMap()
Return {_aMapField}
