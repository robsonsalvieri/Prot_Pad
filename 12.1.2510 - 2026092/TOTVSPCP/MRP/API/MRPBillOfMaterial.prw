#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "MRPBILLOFMATERIAL.CH"

Static _aMapCab   := MapFields(1)
Static _aMapComp  := MapFields(2)
Static _aMapAlt   := MapFields(3)

#DEFINE LISTA_DE_COMPONENTES  "listOfMRPComponents"
#DEFINE LISTA_DE_ALTERNATIVOS "listOfMRPAlternatives"

//dummy function
Function MrpBillOfM()
Return

/*/{Protheus.doc} MrpBillOfMaterial
API de integração de ESTRUTURAS do MRP

@type  WSCLASS
@author lucas.franca
@since 18/05/2019
@version P12.1.27
/*/
WSRESTFUL mrpbillofmaterial DESCRIPTION STR0029 FORMAT APPLICATION_JSON //"Estruturas do MRP"
	WSDATA Fields     AS STRING  OPTIONAL
	WSDATA Order      AS STRING  OPTIONAL
	WSDATA Page       AS INTEGER OPTIONAL
	WSDATA PageSize   AS INTEGER OPTIONAL
	WSDATA branchId   AS STRING  OPTIONAL
	WSDATA product    AS STRING  OPTIONAL

	WSMETHOD GET ALLBOM;
		DESCRIPTION STR0001; //"Retorna todas as estruturas do MRP"
		WSSYNTAX "api/pcp/v1/mrpbillofmaterial" ;
		PATH "/api/pcp/v1/mrpbillofmaterial" ;
		TTALK "v1"

	WSMETHOD GET BOM;
		DESCRIPTION STR0002; //"Retorna uma estrutura específica"
		WSSYNTAX "api/pcp/v1/mrpbillofmaterial/{branchId}/{product}" ;
		PATH "/api/pcp/v1/mrpbillofmaterial/{branchId}/{product}" ;
		TTALK "v1"

	WSMETHOD POST BOM;
		DESCRIPTION STR0003; //"Inclui ou atualiza uma ou mais estruturas do MRP"
		WSSYNTAX "api/pcp/v1/mrpbillofmaterial" ;
		PATH "/api/pcp/v1/mrpbillofmaterial" ;
		TTALK "v1"

	WSMETHOD POST SYNC;
		DESCRIPTION STR0030; //"Sincronização de estruturas do MRP"
		WSSYNTAX "api/pcp/v1/mrpbillofmaterial/sync" ;
		PATH "/api/pcp/v1/mrpbillofmaterial/sync" ;
		TTALK "v1"

	WSMETHOD DELETE ESTRUT;
		DESCRIPTION STR0004; //"Exclui uma ou mais estruturas do MRP"
		WSSYNTAX "api/pcp/v1/mrpbillofmaterial" ;
		PATH "/api/pcp/v1/mrpbillofmaterial" ;
		TTALK "v1"

	WSMETHOD DELETE COMPON;
		DESCRIPTION STR0005; //"Exclui um ou mais componentes das estruturas do MRP"
		WSSYNTAX "api/pcp/v1/mrpbillofmaterial/component" ;
		PATH "/api/pcp/v1/mrpbillofmaterial/component" ;
		TTALK "v1"

	WSMETHOD DELETE ALTERN;
		DESCRIPTION STR0006; //"Exclui um ou mais alternativos dos componentes das estruturas do MRP"
		WSSYNTAX "api/pcp/v1/mrpbillofmaterial/alternative" ;
		PATH "/api/pcp/v1/mrpbillofmaterial/alternative" ;
		TTALK "v1"

ENDWSRESTFUL

/*/{Protheus.doc} GET ALLBOM /api/pcp/v1/mrpbillofmaterial
Retorna todas as Estruturas MRP

@type  WSMETHOD
@author lucas.franca
@since 18/05/2019
@version P12.1.27
@param	Order   , caracter, Ordenação da tabela principal
@param	Page    , numérico, Número da página inicial da consulta
@param	PageSize, numérico, Número de registro por páginas
@param	Fields  , caracter, Campos que serão retornados no GET.
@return lRet    , Lógico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET ALLBOM QUERYPARAM Order, Page, PageSize, Fields WSSERVICE mrpbillofmaterial
	Local aReturn := {}
	Local lRet    := .T.

	Self:SetContentType("application/json")

	aReturn := MrpBOMGAll(Self:aQueryString, Self:Order, Self:Page, Self:PageSize, Self:Fields)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
Return lRet

/*/{Protheus.doc} GET BOM /api/pcp/v1/mrpbillofmaterial
Retorna uma estrutura específica do MRP

@type  WSMETHOD
@author lucas.franca
@since 18/05/2019
@version P12.1.27
@param  branchId, Character, Código da filial para fazer a busca
@param  product , Character, Código do produto para fazer a busca
@param	Fields  , Character, Campos que serão retornados no GET.
@return lRet    , Lógico   , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET BOM PATHPARAM branchId, product QUERYPARAM Fields WSSERVICE mrpbillofmaterial
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a função para retornar os dados.
	aReturn := MrpBOMGPrd(Self:branchId, Self:product, Self:Fields)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
Return lRet

/*/{Protheus.doc} POST BOM /api/pcp/v1/mrpbillofmaterial
Inclui ou altera uma ou mais estruturas do MRP

@type  WSMETHOD
@author lucas.franca
@since 18/05/2019
@version P12.1.27
@return lRet    , Lógico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD POST BOM WSSERVICE mrpbillofmaterial
	Local aReturn  := {}
	Local cBody    := ""
	Local cError   := ""
	Local lRet     := .T.
	Local oBody    := JsonObject():New()

	Self:SetContentType("application/json")
	cBody := Self:GetContent()

	cError := oBody:FromJson(cBody)

	If cError == Nil
		aReturn := MrpBOMPost(oBody)
		MRPApi():restReturn(Self, aReturn, "POST", @lRet)
	Else
		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
		lRet    := .F.
		SetRestFault(400, EncodeUtf8(STR0007), .T., , cError ) //"Não foi possível interpretar os dados recebidos."
	EndIf

	FreeObj(oBody)
	oBody := Nil
Return lRet

/*/{Protheus.doc} POST SYNC /api/pcp/v1/mrpbillofmaterial/sync
Sincronização de estruturas

@type  WSMETHOD
@author lucas.franca
@since 18/05/2019
@version P12.1.27
@return lRet    , Lógico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD POST SYNC WSSERVICE mrpbillofmaterial
	Local aReturn  := {}
	Local cBody    := ""
	Local cError   := ""
	Local lRet     := .T.
	Local oBody    := JsonObject():New()

	Self:SetContentType("application/json")
	cBody := Self:GetContent()

	cError := oBody:FromJson(cBody)

	If cError == Nil
		aReturn := MrpBOMSync(oBody)
		MRPApi():restReturn(Self, aReturn, "POST", @lRet)
	Else
		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
		lRet    := .F.
		SetRestFault(400, EncodeUtf8(STR0007), .T., , cError ) //"Não foi possível interpretar os dados recebidos."
	EndIf

	FreeObj(oBody)
	oBody := Nil
Return lRet

/*/{Protheus.doc} DELETE BOM /api/pcp/v1/mrpbillofmaterial
Deleta uma ou mais estruturas do MRP

@type  WSMETHOD
@author lucas.franca
@since 18/05/2019
@version P12.1.27
@return lRet    , Lógico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD DELETE ESTRUT WSSERVICE mrpbillofmaterial
	Local aReturn  := {}
	Local cBody    := ""
	Local cError   := ""
	Local lRet     := .T.
	Local oBody    := JsonObject():New()

	Self:SetContentType("application/json")
	cBody := Self:GetContent()

	cError := oBody:FromJson(cBody)

	If cError == Nil
		aReturn := MrpEstrDel(oBody, 1)
		MRPApi():restReturn(Self, aReturn, "DELETE", @lRet)
	Else
		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
		lRet    := .F.
		SetRestFault(400, EncodeUtf8(STR0007), .T., , cError ) //"Não foi possível interpretar os dados recebidos."
	EndIf

	FreeObj(oBody)
	oBody := Nil
Return lRet

/*/{Protheus.doc} DELETE BOM /api/pcp/v1/mrpbillofmaterial/component
Deleta uma ou mais estruturas do MRP

@type  WSMETHOD
@author lucas.franca
@since 18/05/2019
@version P12.1.27
@return lRet    , Lógico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD DELETE COMPON WSSERVICE mrpbillofmaterial
	Local aReturn  := {}
	Local cBody    := ""
	Local cError   := ""
	Local lRet     := .T.
	Local oBody    := JsonObject():New()

	Self:SetContentType("application/json")
	cBody := Self:GetContent()

	cError := oBody:FromJson(cBody)

	If cError == Nil
		aReturn := MrpEstrDel(oBody, 2)
		MRPApi():restReturn(Self, aReturn, "DELETE", @lRet)
	Else
		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
		lRet    := .F.
		SetRestFault(400, EncodeUtf8(STR0007), .T., , cError ) //"Não foi possível interpretar os dados recebidos."
	EndIf

	FreeObj(oBody)
	oBody := Nil
Return lRet

/*/{Protheus.doc} DELETE BOM /api/pcp/v1/mrpbillofmaterial/alternative
Deleta uma ou mais estruturas do MRP

@type  WSMETHOD
@author lucas.franca
@since 18/05/2019
@version P12.1.27
@return lRet    , Lógico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD DELETE ALTERN WSSERVICE mrpbillofmaterial
	Local aReturn  := {}
	Local cBody    := ""
	Local cError   := ""
	Local lRet     := .T.
	Local oBody    := JsonObject():New()

	Self:SetContentType("application/json")
	cBody := Self:GetContent()

	cError := oBody:FromJson(cBody)

	If cError == Nil
		aReturn := MrpEstrDel(oBody, 3)
		MRPApi():restReturn(Self, aReturn, "DELETE", @lRet)
	Else
		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
		lRet    := .F.
		SetRestFault(400, EncodeUtf8(STR0007), .T., , cError ) //"Não foi possível interpretar os dados recebidos."
	EndIf

	FreeObj(oBody)
	oBody := Nil
Return lRet

/*/{Protheus.doc} MrpBOMPost
Função para disparar as ações da API de Estruturas do MRP, para o método POST (Inclusão/Alteração).

@type    Function
@author  lucas.franca
@since   20/05/2019
@version P12.1.27
@oaram   oBody, JsonObject, Objeto JSON com as informações recebidas no corpo da requisição.
@return aReturn, Array, Array contendo o código HTTP que deverá ser retornado pela API, e o JSON formatado com todos os dados de retorno.
                        Array[1] -> Numeric. Código HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                        Array[2] -> Character. JSON no formato definido pela API para ser retornado.
/*/
Function MrpBOMPost(oBody)
	Local aReturn := {201, ""}
	Local oMRPApi := defMRPApi("POST","") //Instância da classe MRPApi para o método POST

	//Adiciona os parâmetros recebidos no corpo da requisição (BODY)
	oMRPApi:setBody(oBody)

	//Aciona flag para que a cada atualização, os dados sejam deletados e reinseridos
	oMRPApi:setDelStruct(.T.)

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

/*/{Protheus.doc} MrpBOMSync
Função para disparar as ações da API de Estruturas do MRP, para o método SYNC (Sincronização).

@type    Function
@author  lucas.franca
@since   05/08/2019
@version P12.1.27
@oaram   oBody, JsonObject, Objeto JSON com as informações recebidas no corpo da requisição.
@param   lBuffer, Lógico, Define a sincronização em processo de buffer.
@return aReturn, Array, Array contendo o código HTTP que deverá ser retornado pela API, e o JSON formatado com todos os dados de retorno.
                        Array[1] -> Numeric. Código HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                        Array[2] -> Character. JSON no formato definido pela API para ser retornado.
/*/
Function MrpBOMSync(oBody,lBuffer)
	Local aReturn := {201, ""}
	Local oMRPApi := defMRPApi("POST","") //Instância da classe MRPApi para o método POST

	Default lBuffer := .F.

	//Adiciona os parâmetros recebidos no corpo da requisição (BODY)
	oMRPApi:setBody(oBody)

	//Seta FLAG que indica o processo de sincronização.
	oMRPApi:setSync(.T.)

	//Seta FLAG que indica o processo de buffer.
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

/*/{Protheus.doc} MrpEstrDel
Função para disparar as ações da API de Estruturas do MRP, para o método DELETE (Exclusão) de toda a estrutura.

@type  Function
@author lucas.franca
@since 20/05/2019
@version P12.1.27
@oaram oBody, JsonObject, Objeto JSON com as informações recebidas no corpo da requisição.
@param nTipo, Numeric   , Identifica o tipo da exclusão. 1=Estrutura completa. 2=Componente da estrutura; 3=Alternativo do componente.
@return aReturn, Array, Array contendo o código HTTP que deverá ser retornado pela API, e o JSON formatado com todos os dados de retorno.
                        Array[1] -> Numeric. Código HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                        Array[2] -> Character. JSON no formato definido pela API para ser retornado.
/*/
Function MrpEstrDel(oBody, nTipo)
	Local aReturn  := {201, ""}
	Local cMapCode := ""
	Local oMRPApi  := defMRPApi("DELETE","") //Instância da classe MRPApi para o método DELETE

	//Adiciona os parâmetros recebidos no corpo da requisição (BODY)
	oMRPApi:setBody(oBody)

	Do Case
		Case nTipo == 1
			cMapCode := "fields"
		Case nTipo == 2
			cMapCode := LISTA_DE_COMPONENTES
		Case nTipo == 3
			cMapCode := LISTA_DE_ALTERNATIVOS
	EndCase

	oMRPApi:setMapDelete(cMapCode)

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

/*/{Protheus.doc} MrpBOMGAll
Função para disparar as ações da API de Estruturas do MRP, para o método GET (Consulta) para várias estruturas.

@type  Function
@author lucas.franca
@since 20/05/2019
@version P12.1.27
@param aQuery   , Array    , Array com os dados que devem ser filtrados.
                             Exemplo: Array[1]
                                      Array[1][1] = "PRODUCT"
                                      Array[1][2] = "PRODUTO001"
                                      Array[2]
                                      Array[2][1] = "COMPONENT"
                                      Array[2][2] = "PRODUTO002"
@param cOrder   , Character, Ordenação desejada do retorno.
@param nPage    , Numeric  , Página dos dados. Se não enviado, considera página 1.
@param nPageSize, Numeric  , Quantidade de registros retornados por página. Se não enviado, considera 20 registros por página.
@param cFields  , Character, Campos que devem ser retornados. Se não enviado, retorna todos os fields que possuem valor.
@return aReturn , Array    , Array com as informações da requisição.
                             aReturn[1] - Lógico    - Indica se a requisição foi processada com sucesso ou não.
						     aReturn[2] - Character - JSON com o resultado da requisição, ou com a mensagem de erro.
						     aReturn[3] - Numeric   - Código de erro identificado pelo FwApiManager.
/*/
Function MrpBOMGAll(aQuery, cOrder, nPage, nPageSize, cFields)
	Local aReturn := {}

	//Processa o GET
	aReturn := BOMGet(.T., aQuery, cOrder, nPage, nPageSize, cFields)
Return aReturn

/*/{Protheus.doc} MrpBOMGPrd
Função para disparar as ações da API de Estruturas do MRP, para o método GET (Consulta) de uma estrutura específica.

@type  Function
@author lucas.franca
@since 21/05/2019
@version P12.1.27
@param cBranch , Caracter, Código da filial
@param cProduct, Caracter, Código do produto pai da estrutura
@param cFields , Caracter, Campos que devem ser retornados.
@return aReturn, Array, Array com as informações da requisição.
                        aReturn[1] - Lógico    - Indica se a requisição foi processada com sucesso ou não.
						aReturn[2] - Character - JSON com o resultado da requisição, ou com a mensagem de erro.
						aReturn[3] - Numeric   - Código de erro identificado pelo FwApiManager.
/*/
Function MrpBOMGPrd(cBranch, cProduct, cFields)
	Local aReturn   := {}
	Local aQryParam := {}

	//Adiciona os filtros de filial e produto como QueryParam.
	aAdd(aQryParam, {"BRANCHID", cBranch})
	aAdd(aQryParam, {"PRODUCT" , cProduct})

	If !Empty(cFields)
		//Adiciona o FIELDS se for recebido.
		aAdd(aQryParam, {"FIELDS", cFields})
	EndIf

	//Chama a função para retornar os dados.
	aReturn := BOMGet(.F., aQryParam, Nil, Nil, Nil, cFields)

Return aReturn

/*/{Protheus.doc} MapFields
Gera o array com o MAP dos fields da API e os fields da tabela T4N e T4O

@type  Static Function
@author lucas.franca
@since 20/05/2019
@version P12.1.27
@param nType, Numeric, Tipo da estrutura (1=Cabeçalho; 2=Componentes; 3=Alternativos)
@return aFields, Array, Array contendo o MAP dos fields da API e da tabela
/*/
Static Function MapFields(nType)
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

	If nType == 1
		//Estrutura do cabeçalho
		aFields := { ;
		            {"branchId"  , "T4N_FILIAL", "C", FWSizeFilial()                      , 0},;
		            {"product"   , "T4N_PROD"  , "C", GetSx3Cache("T4N_PROD","X3_TAMANHO"), 0},;
		            {"itemAmount", "T4N_QTDB"  , "N", GetSx3Cache("T4N_QTDB","X3_TAMANHO"), GetSx3Cache("T4N_QTDB","X3_DECIMAL")};
		           }
	ElseIf nType == 2
		//Estrutura da lista de componentes
		aFields := { ;
		            {"component"      , "T4N_COMP"  , "C", GetSx3Cache("T4N_COMP"  ,"X3_TAMANHO"), 0},;
		            {"sequence"       , "T4N_SEQ"   , "C", GetSx3Cache("T4N_SEQ"   ,"X3_TAMANHO"), 0},;
		            {"startRevison"   , "T4N_REVINI", "C", GetSx3Cache("T4N_REVINI","X3_TAMANHO"), 0},;
		            {"endRevison"     , "T4N_REVFIM", "C", GetSx3Cache("T4N_REVFIM","X3_TAMANHO"), 0},;
		            {"quantity"       , "T4N_QTD"   , "N", GetSx3Cache("T4N_QTD"   ,"X3_TAMANHO"), GetSx3Cache("T4N_QTD","X3_DECIMAL")},;
		            {"startDate"      , "T4N_DTINI" , "D", 8, 0},;
		            {"endDate"        , "T4N_DTFIM" , "D", 8, 0},;
		            {"percentageScrap", "T4N_PERDA" , "N", GetSx3Cache("T4N_PERDA" ,"X3_TAMANHO"), GetSx3Cache("T4N_PERDA","X3_DECIMAL")},;
		            {"fixedQuantity"  , "T4N_FIXA"  , "C", GetSx3Cache("T4N_FIXA"  ,"X3_TAMANHO"), 0},;
		            {"optionalGroup"  , "T4N_GROPC" , "C", GetSx3Cache("T4N_GROPC" ,"X3_TAMANHO"), 0},;
		            {"optionalItem"   , "T4N_ITOPC" , "C", GetSx3Cache("T4N_ITOPC" ,"X3_TAMANHO"), 0},;
		            {"potency"        , "T4N_POTEN" , "N", GetSx3Cache("T4N_POTEN" ,"X3_TAMANHO"), GetSx3Cache("T4N_POTEN" ,"X3_DECIMAL")},;
		            {"warehouse"      , "T4N_ARMCON", "C", GetSx3Cache("T4N_ARMCON","X3_TAMANHO"), 0},;
		            {"isGhostMaterial", "T4N_FANTAS", "L", 1, 0},;
		            {"code"           , "T4N_IDREG" , "C", GetSx3Cache("T4N_IDREG" ,"X3_TAMANHO"), 0};
		           }
	ElseIf nType == 3
		//Estrutura dos produtos alternativos.
		aFields := { ;
		            {"sequence"        , "T4O_SEQ"   , "C", GetSx3Cache("T4O_SEQ"   ,"X3_TAMANHO"), 0},;
		            {"alternative"     , "T4O_ALTERN", "C", GetSx3Cache("T4O_ALTERN","X3_TAMANHO"), 0},;
		            {"conversionType"  , "T4O_TPCONV", "C", GetSx3Cache("T4O_TPCONV","X3_TAMANHO"), 0},;
		            {"conversionFactor", "T4O_FATCON", "N", GetSx3Cache("T4O_FATCON","X3_TAMANHO"), GetSx3Cache("T4O_FATCON","X3_DECIMAL")},;
		            {"vigency"         , "T4O_DATA"  , "D", GetSx3Cache("T4O_DATA"  ,"X3_TAMANHO"), 0},;
		            {"inventory"       , "T4O_ESTOQ" , "C", GetSx3Cache("T4O_ESTOQ" ,"X3_TAMANHO"), 0};
		           }
	EndIf
Return aFields

/*/{Protheus.doc} BOMGet
Executa o processamento do método GET de acordo com os parâmetros recebidos.

@type  Static Function
@author lucas.franca
@since 30/05/2019
@version P12.1.27
@param lLista   , Logic    , Indica se deverá retornar uma lista de registros (.T.), ou apenas um registro (.F.).
@param aQuery   , Array    , Array com os dados que devem ser filtrados.
                             Exemplo: Array[1]
                                      Array[1][1] = "PRODUCT"
                                      Array[1][2] = "PRODUTO001"
                                      Array[2]
                                      Array[2][1] = "COMPONENT"
                                      Array[2][2] = "PRODUTO002"
@param cOrder   , Character, Ordenação desejada do retorno.
@param nPage    , Numeric  , Página dos dados. Se não enviado, considera página 1.
@param nPageSize, Numeric  , Quantidade de registros retornados por página. Se não enviado, considera 20 registros por página.
@param cFields  , Character, Campos que devem ser retornados. Se não enviado, retorna todos os fields que possuem valor.
@return aReturn , Array    , Array com as informações da requisição.
                             aReturn[1] - Lógico    - Indica se a requisição foi processada com sucesso ou não.
						     aReturn[2] - Character - JSON com o resultado da requisição, ou com a mensagem de erro.
						     aReturn[3] - Numeric   - Código de erro identificado pelo FwApiManager.
/*/
Static Function BOMGet(lLista, aQuery, cOrder, nPage, nPageSize, cFields)
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
@since 27/05/2019
@version P12.1.27
@param oMRPApi   , Object   , Referência da classe MRPApi que está processando os dados.
@param cMapCode  , Character, Código do mapeamento que será validado
@param oItem     , Object   , Referência do objeto JSON com os dados que devem ser validados.
@return lRet     , Lógico   , Identifica se os dados estão válidos.
/*/
Function MRPBOMVLD(oMRPApi, cMapCode, oItem)
	Local lRet := .T.

	Do Case
		Case cMapCode == "fields"
			lRet := validaCab(oMRPApi, oItem)
		Case cMapCode == LISTA_DE_COMPONENTES
			lRet := vldCompons(oMRPApi, oItem)
		Case cMapCode == LISTA_DE_ALTERNATIVOS
			lRet := vldAlterns(oMRPApi, oItem)
	EndCase
Return lRet

/*/{Protheus.doc} validaCab
Faz a validação do cabeçalho.

@type  Static Function
@author lucas.franca
@since 05/06/2019
@version P12.1.27
@param oMRPApi, Object    , Referência da classe MRPAPI que está executando o processo.
@param oItem  , JsonObject, Objeto JSON do item que será validado
@return lRet  , Logical   , Indica se o item poderá ser processado.
/*/
Static Function validaCab(oMRPApi, oItem)
	Local lRet := .T.

	If lRet .And. Empty(oItem["product"])
		lRet := .F.
		oMRPApi:SetError(400, STR0010 + " 'product' " + STR0014 + " (T4N_PROD)") //"Atributo 'XXX' não foi informado."
	EndIf

Return lRet

/*/{Protheus.doc} vldCompons
Executa as validações referentes à lista de componentes para um determinado item.

@type  Static Function
@author lucas.franca
@since 27/05/2019
@version P12.1.27
@param oMRPApi , Object    , Referência da classe MRPAPI que está executando o processo.
@param oListCmp, JsonObject, Objeto JSON do item que será validado
@return lRet   , Lógico    , Identifica se os dados estão válidos.
/*/
Static Function vldCompons(oMRPApi, oListCmp)
	Local lRet   := .T.

	//Código único do componente
	If lRet .And. Empty(oListCmp["code"])
		lRet := .F.
		oMRPApi:SetError(400, STR0010 + " 'code' " + STR0014 + " (T4N_IDREG)") //"Atributo 'XXX' não foi informado."
	EndIf

	If lRet .And. oMRPApi:cMethod == "POST"
		//Código do componente preenchido.
		If lRet .And. Empty(oListCmp["component"])
			lRet := .F.
			oMRPApi:SetError(400, STR0010 + " 'component' " + STR0014 + " (T4N_COMP)") //"Atributo 'XXX' não foi informado."
		EndIf

		//Quantidade necessária preenchida
		If lRet .And. Empty(oListCmp["quantity"])
			lRet := .F.
			oMRPApi:SetError(400, STR0010 + " 'quantity' " + STR0014 + " (T4N_QTD)") //"Atributo 'XXX' não foi informado."
		EndIf

		If lRet .And. !Empty(oListCmp["fixedQuantity"])
			If !oListCmp["fixedQuantity"] $ "|1|2|"
				lRet := .F.
				oMRPApi:SetError(400, STR0010 + " 'fixedQuantity' " + STR0024 + " (T4N_FIXA)") //"Atributo 'XXX' informado incorretamente. Valores suportados: 1=Sim;2=Não."
			EndIf
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} vldAlterns
Executa as validações referentes à lista de componentes para um determinado item.

@type  Static Function
@author lucas.franca
@since 27/05/2019
@version P12.1.27
@param oMRPApi , Object    , Referência da classe MRPAPI que está executando o processo.
@param oListAlt, JsonObject, Objeto JSON do item que será validado
@return lRet     , Lógico    , Identifica se os dados estão válidos.
/*/
Static Function vldAlterns(oMRPApi, oListAlt)
	Local lRet   := .T.

	//Se enviou lista de alternativos, verifica se os dados estão válidos.
	If lRet .And. Empty(oListAlt["sequence"])
		lRet := .F.
		oMRPApi:SetError(400, STR0010 + " 'sequence' " + STR0014 + " (T4O_SEQ)") //"Atributo 'XXX' não foi informado."
	EndIf
	If oMRPApi:cMethod == "POST"
		If lRet .And. Empty(oListAlt["alternative"])
			lRet := .F.
			oMRPApi:SetError(400, STR0010 + " 'alternative' " + STR0014 + " (T4O_ALTERN)") //"Atributo 'XXX' não foi informado."
		EndIf
		If lRet .And. Empty(oListAlt["conversionType"])
			lRet     := .F.
			oMRPApi:SetError(400, STR0010 + " 'conversionType' " + STR0014 + " (T4O_TPCONV)") //"Atributo 'XXX' não foi informado."
		EndIf
		If lRet .And. !oListAlt["conversionType"] $ "|1|2|"
			lRet := .F.
			oMRPApi:SetError(400, STR0010 + " 'conversionType' " + STR0025 + " (T4O_TPCONV)") ////"Atributo 'XXX' informado incorretamente. Valores suportados: 1=Multiplicação;2=Divisão."
		EndIf
		If lRet .And. Empty(oListAlt["conversionFactor"])
			lRet := .F.
			oMRPApi:SetError(400, STR0010 + " 'conversionFactor' " + STR0014 + " (T4O_FATCON)") //"Atributo 'XXX' não foi informado."
		EndIf
		If lRet .And. !Empty(oListAlt["inventory"])
			If !oListAlt["inventory"] $ "|1|2|3|"
				lRet := .F.
				oMRPApi:SetError(400, STR0010 + " 'inventory' " + STR0026 + " (T4O_ESTOQ)") //"Atributo 'XXX' informado incorretamente. Valores suportados: 1=Original e Alternativo Produz Original;2=Original e Alternativo Produz Alternativo;3=Alternativo. Produz Alternativo."
			EndIf
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} defMRPApi
Faz a instância da classe MRPAPI e seta as propriedades básicas.

@type  Static Function
@author lucas.franca
@since 06/06/2019
@version P12.1.27
@param cMethod  , Character, Método que será executado (GET/POST/DELETE)
@param cOrder   , Character, Ordenação para o GET
@return oMRPApi , Object   , Referência da classe MRPApi com as definições já executadas.
/*/
Static Function defMRPApi(cMethod, cOrder)
	Local aRelac  := {}
	Local oMRPApi := MRPApi():New(cMethod)

	//Seta o APIMAP do item principal (cabeçalho)
	oMRPApi:setAPIMap("fields"             , _aMapCab , "T4N", .T., "branchId,product")
	//Seta o APIMAP da lista de componentes
	oMRPApi:setAPIMap(LISTA_DE_COMPONENTES , _aMapComp, "T4N", .F., cOrder)
	//Seta o APIMAP da lista de alternativos
	oMRPApi:setAPIMap(LISTA_DE_ALTERNATIVOS, _aMapAlt , "T4O", .F., "sequence")

	//Adiciona o relacionamento entre o cabeçalho e a lista de componentes
	aRelac := {}
	aAdd(aRelac, {"T4N_FILIAL", "T4N_FILIAL"})
	aAdd(aRelac, {"T4N_PROD"  , "T4N_PROD"  })
	oMRPApi:setMapRelation("fields", LISTA_DE_COMPONENTES, aRelac, .T.)

	//Adiciona o relacionamento entre a lista de componentes e a lista de alternativos
	aRelac := {}
	aAdd(aRelac, {"T4N_FILIAL", "T4O_FILIAL"})
	aAdd(aRelac, {"T4N_IDREG" , "T4O_IDEST" })
	oMRPApi:setMapRelation(LISTA_DE_COMPONENTES, LISTA_DE_ALTERNATIVOS, aRelac, .F.)

	//Seta os campos utilizados para busca de registros.
	oMRPApi:setKeySearch("fields"             ,{"T4N_FILIAL","T4N_PROD"})
	oMRPApi:setKeySearch(LISTA_DE_COMPONENTES ,{"T4N_FILIAL","T4N_IDREG"})
	oMRPApi:setKeySearch(LISTA_DE_ALTERNATIVOS,{"T4O_FILIAL","T4O_IDEST","T4O_SEQ"})

	If cMethod == "POST"
		//Seta as funções de validação de cada mapeamento.
		oMRPApi:setValidData("fields"             , "MRPBOMVLD")
		oMRPApi:setValidData(LISTA_DE_COMPONENTES , "MRPBOMVLD")
		oMRPApi:setValidData(LISTA_DE_ALTERNATIVOS, "MRPBOMVLD")

		//Seta valores default para os campos
		oMRPApi:setDefaultValues("fields"             , "itemAmount"     , 1)
		oMRPApi:setDefaultValues(LISTA_DE_COMPONENTES , "endRevison"     , "ZZZ")
		oMRPApi:setDefaultValues(LISTA_DE_COMPONENTES , "startDate"      , "1980-01-01")
		oMRPApi:setDefaultValues(LISTA_DE_COMPONENTES , "endDate"        , "2999-12-31")
		oMRPApi:setDefaultValues(LISTA_DE_COMPONENTES , "fixedQuantity"  , "2")
		oMRPApi:setDefaultValues(LISTA_DE_COMPONENTES , "isGhostMaterial", .F.)
		oMRPApi:setDefaultValues(LISTA_DE_ALTERNATIVOS, "inventory"      , "1")
	EndIf
Return oMRPApi

/*/{Protheus.doc} MrpBOMMap
Retorna um array com todos os MapFields utilizados na API

@type    Function
@author  marcelo.neumann
@since   18/10/2019
@version P12.1.27
@return  Array, array com os arrays de MapFields
/*/
Function MrpBOMMap()
Return {_aMapCab, _aMapComp, _aMapAlt}
