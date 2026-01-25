#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "InspecoesDeProcessosAPI.CH"

#DEFINE nPosCPS_Considera                  1
#DEFINE nPosCPS_Titulo_Interface           2
#DEFINE nPosCPS_Titulo_API                 3
#DEFINE nPosCPS_Protheus                   4
#DEFINE nPosCPS_Tipo                       5
#DEFINE nPosCPS_Tamanho                    6
#DEFINE nPosCPS_Decimal                    7
#DEFINE nPosCPS_Alias                      8
#DEFINE nPosCPS_Protheus_Externo           9

/*/{Protheus.doc} processinspections
API de Inspeção de Processos - Qualidade
@author brunno.costa
@since  23/05/2022
/*/
WSRESTFUL processinspections DESCRIPTION STR0001 FORMAT APPLICATION_JSON //"Inspeções de Processos"

    WSDATA Fields               as STRING OPTIONAL
	WSDATA IncompleteReport     as BOOLEAN OPTIONAL
	WSDATA Laboratory           as STRING OPTIONAL
    WSDATA Login                as STRING OPTIONAL
	WSDATA Lot                  as STRING OPTIONAL
	WSDATA NotStarted           as BOOLEAN OPTIONAL
	WSDATA OperationDescription as STRING OPTIONAL
	WSDATA OperationID          as STRING OPTIONAL
    WSDATA Order                as STRING OPTIONAL
	WSDATA OrderType            as STRING OPTIONAL
    WSDATA Page                 as INTEGER OPTIONAL
    WSDATA PageSize             as INTEGER OPTIONAL
	WSDATA ProductID            as STRING OPTIONAL
	WSDATA ProductionStartDate  as STRING OPTIONAL
	WSDATA Recno                as STRING OPTIONAL
	WSDATA SerialNumber         as STRING OPTIONAL
	WSDATA SpecificationVersion as STRING OPTIONAL
    WSDATA Text                 as STRING OPTIONAL
	WSDATA WithoutReport        as BOOLEAN OPTIONAL

    WSMETHOD GET pendinglist;
	DESCRIPTION STR0002; //"Retorna Lista Inspeções de Processos Pendentes"
	WSSYNTAX "api/qip/v1/pendinglist/{Login}/{OperationDescription}/{ProductionStartDate}/{Laboratory}/{Order}/{OrderType}/{Page}/{PageSize}/{NotStarted}/{WithoutReport}/{IncompleteReport}" ;
	PATH "/api/qip/v1/pendinglist" ;
	TTALK "v1"

    WSMETHOD GET search;
    DESCRIPTION STR0003; //"Pesquisa Lista Inspeções de Processos"
    WSSYNTAX "api/qip/v1/search/{Login}/{Laboratory}/{Text}/{Lot}/{SerialNumber}/{OperationDescription}/{ProductionStartDate}/{Order}/{OrderType}/{Page}/{PageSize}" ;
    PATH "/api/qip/v1/search" ;
    TTALK "v1"

	WSMETHOD GET inspection;
    DESCRIPTION STR0005; //"Retorna uma Inspeção de Processos"
    WSSYNTAX "api/qip/v1/inspection/{Login}/{Laboratory}/{Recno}/{OperationID}" ;
    PATH "/api/qip/v1/inspection" ;
    TTALK "v1"

	WSMETHOD GET userExist;
	DESCRIPTION STR0004; //"Retorna se o usuário possui cadastro ativo no módulo inspeção de processos"
	WSSYNTAX "api/qip/v1/userExist/{Login}" ;
	PATH "/api/qip/v1/userExist" ;
	TTALK "v1"

	WSMETHOD GET version;
	DESCRIPTION STR0010; //"Retorna a versão do back-end de Inspeção de Processos"
	WSSYNTAX "api/qip/v1/version/{Login}" ;
	PATH "/api/qip/v1/version" ;
	TTALK "v1"

	WSMETHOD GET cards;
    DESCRIPTION STR0008; //"Retorna Resumo dos Cards de Inspeção"
    WSSYNTAX "api/qip/v1/cards/{Login}/{Laboratory}/{Text}" ;
    PATH "/api/qip/v1/cards" ;
    TTALK "v1"

	WSMETHOD POST completeStockRelease;
	DESCRIPTION STR0009; // "Movimenta as pendências de estoque CQ automaticamente"
	WSSYNTAX "api/qip/v1/completestockrelease" ;
	PATH    "/api/qip/v1/completestockrelease" ;
	TTALK "v1"

	WSMETHOD GET hasqipintapi;
    DESCRIPTION STR0011; //"Indica se há compilação do ponto de entrada QIPINTAPI"
    WSSYNTAX "api/qip/v1/hasqipintapi" ;
    PATH "/api/qip/v1/hasqipintapi" ;
    TTALK "v1"

	WSMETHOD GET picturecode;
    DESCRIPTION STR0012; //"Retorna o código da foto relacionada, quando existir"
    WSSYNTAX "api/qip/v1/picturecode/{ProductID}/{SpecificationVersion}" ;
    PATH "/api/qip/v1/picturecode" ;
    TTALK "v1"

ENDWSRESTFUL

WSMETHOD GET picturecode PATHPARAM ProductID, SpecificationVersion QUERYPARAM Fields WSSERVICE processinspections
    
	Local cPicture    := ""
	Local oAPIManager := QualityAPIManager():New({}, Self)

	Default Self:ProductID            := ""
	Default Self:SpecificationVersion := ""

	Self:ProductID            := PadR(Self:ProductID           , GetSx3Cache("QP6_PRODUT", 'X3_TAMANHO') )
	Self:SpecificationVersion := PadR(Self:SpecificationVersion, GetSx3Cache("QP6_REVI"  , 'X3_TAMANHO') )

	dbSelectArea("QP6")
	QP6->(DBSetOrder(2))
	If !Empty(Self:ProductID) .And. !Empty(Self:SpecificationVersion) .And. QP6->(DbSeek(xFilial("QP6") + Self:ProductID + Self:SpecificationVersion))
		cPicture := QP6->QP6_BITMAP
	EndIf
	QP6->(dbCloseArea())

	oAPIManager := QualityAPIManager():New({}, Self)
	oAPIManager:RespondeValor("pictureCode", cPicture)

Return 

WSMETHOD GET pendinglist PATHPARAM Login, OperationDescription, ProductionStartDate, Laboratory, Order, OrderType, Page, PageSize, NotStarted, WithoutReport, IncompleteReport QUERYPARAM Fields WSSERVICE processinspections
    Local oAPIClass                    := InspecoesDeProcessosAPI():New(Self)
	Default Self:Login                 := ""
	Default Self:Laboratory            := ""
	Default Self:Order                 := ""
	Default Self:OrderType             := ""
	Default Self:Page                  := 1
	Default Self:PageSize              := 5
	Default Self:Fields                := ""
	Default Self:NotStarted            := .F.
    Default Self:WithoutReport         := .F.
    Default Self:IncompleteReport      := .F.
	Default Self:OperationDescription  := ""
	Default Self:ProductionStartDate   := ""

Return oAPIClass:PesquisaLista(Self:Login, Self:Laboratory, "", Self:Order, Self:OrderType, Self:Page, Self:PageSize, Self:Fields, Nil, Nil, Self:NotStarted, Self:WithoutReport, Self:IncompleteReport, "", "", Self:OperationDescription, Iif(Empty(Self:ProductionStartDate), dDataBase - 180, StoD(Self:ProductionStartDate)))

WSMETHOD GET search PATHPARAM Login, Laboratory, Text, Lot, SerialNumber, OperationDescription, ProductionStartDate, Order, OrderType, Page, PageSize, NotStarted, WithoutReport, IncompleteReport QUERYPARAM Fields WSSERVICE processinspections
    Local oAPIClass                   := InspecoesDeProcessosAPI():New(Self)
	Default Self:Fields               := ""
    Default Self:IncompleteReport     := .F.
	Default Self:Laboratory           := ""
	Default Self:Login                := ""
	Default Self:Lot                  := ""
	Default Self:NotStarted           := .F.
	Default Self:OperationDescription := ""
	Default Self:Order                := ""
	Default Self:OrderType            := ""
	Default Self:Page                 := 1
	Default Self:PageSize             := 5
	Default Self:ProductionStartDate  := ""
	Default Self:SerialNumber         := ""
	Default Self:Text                 := ""
    Default Self:WithoutReport        := .F.
Return oAPIClass:PesquisaLista(Self:Login, Self:Laboratory, Self:Text, Self:Order, Self:OrderType, Self:Page, Self:PageSize, Self:Fields, Nil, Nil, Self:NotStarted, Self:WithoutReport, Self:IncompleteReport, Self:Lot, Self:SerialNumber, Self:OperationDescription, Iif(Empty(Self:ProductionStartDate), dDataBase - 180, StoD(Self:ProductionStartDate)))

WSMETHOD GET inspection PATHPARAM Login, Laboratory, Recno QUERYPARAM Fields WSSERVICE processinspections
    Local oAPIClass          := InspecoesDeProcessosAPI():New(Self)
	Default Self:Login       := ""
	Default Self:Recno       := "0"
	Default Self:Fields      := ""
	Default Self:OperationID := ""
Return oAPIClass:PesquisaLista(Self:Login, "", "", "", "", 1, 9999, Self:Fields, Self:Recno, Self:OperationID)

WSMETHOD GET userExist PATHPARAM Login WSSERVICE processinspections
    Local oAPIClass  := InspecoesDeProcessosAPI():New(Self)
	Default Self:Login    := ""
Return oAPIClass:UsuarioExistente(Self:Login)

WSMETHOD GET version PATHPARAM Login WSSERVICE processinspections
    Local lRetorno       := .T.
	Local oResponse      := JsonObject():New()
	
	Self:SetContentType("application/json")
	oResponse['version'      ] := "4.1.7"
	oResponse['type'         ] := "warning"
	oResponse['hasNext'      ] := .F.
	oResponse['code'         ] := 200

	//Processou com sucesso.
	HTTPSetStatus(200)

	Self:SetResponse(EncodeUtf8(oResponse:toJson()))
Return lRetorno

WSMETHOD GET hasqipintapi PATHPARAM Login WSSERVICE processinspections
    
    Local oAPIManager := QualityAPIManager():New({}, Self)
	
	oAPIManager:RespondeValor("hasqipintapi", oAPIManager:existePEIntegracaoAppMinhaProducaoCompilado("QIP"))

Return

WSMETHOD GET cards PATHPARAM Login, Text, Lot, SerialNumber, OperationDescription, Laboratory, ProductionStartDate QUERYPARAM Fields WSSERVICE processinspections
    Local oAPIClass         := InspecoesDeProcessosAPI():New(Self)
	Default Self:Laboratory           := ""
	Default Self:Login                := ""
	Default Self:Lot                  := ""
	Default Self:OperationDescription := ""
	Default Self:SerialNumber         := ""
	Default Self:Text                 := ""
	Default Self:ProductionStartDate  := ""
Return oAPIClass:RetornaContagemCards(Self:Login, Self:Text, Self:Lot, Self:SerialNumber, Self:OperationDescription, Self:Laboratory, Iif(Empty(Self:ProductionStartDate), dDataBase - 180, StoD(Self:ProductionStartDate)))


WSMETHOD POST completeStockRelease QUERYPARAM Fields WSSERVICE processinspections
    
    Local cError     := ""
    Local cJsonData  := DecodeUTF8(Self:GetContent())
    Local lSucesso   := .F.
    Local oAPIClass  := QIPLaudosEnsaios():New(Self)
    Local oData 	 := JsonObject():New()

    oData:fromJson(cJsonData)
	BEGIN SEQUENCE
		nRecnoQPK := oData['recno']
    	lSucesso  := oAPIClass:MovimentaEstoqueCQ(nRecnoQPK)
    	cError 	  := oAPIClass:oAPIManager:cErrorMessage
	ENDSEQUENCE

    oAPIClass:oAPIManager:RespondeValor("success", lSucesso, cError)

Return 

/*/{Protheus.doc} InspecoesDeProcessosAPI
Regras de Negocio - API Inspeção de Processos
@author brunno.costa
@since  23/05/2022
/*/
CLASS InspecoesDeProcessosAPI FROM LongNameClass
	DATA oAPIManager   as OBJECT
    DATA oWSRestFul    as OBJECT
	DATA oQueryManager as OBJECT
    METHOD new(oWSRestFul) CONSTRUCTOR
    METHOD CriaAliasPesquisa(cLogin, cLaboratorio, cTexto, cOrdem, cTipoOrdem, nPagina, nTamPag, cCampos, cRecno, cOperacao, lNaoIniciadas, lSemLaudos, lLaudosIncompletos, cLote, cNumeroDeSerie, cDescricaoOperacao, dInicioProducao)
	METHOD PesquisaLista(cLogin, cLaboratorio, cTexto, cOrdem, cTipoOrdem, nPagina, nTamPag, cCampos, cRecno, cOperacao, lNaoIniciadas, lSemLaudos, lLaudosIncompletos, cLote, cNumeroDeSerie, cDescricaoOperacao, dInicioProducao)
	METHOD RetornaContagemCards(cLogin, cTexto, cLote, cNumeroDeSerie, cDescricaoOperacao, cLaboratorio, dInicioProducao)
	METHOD UsuarioExistente(cLogin)
     
    //Métodos Internos
    METHOD MapeiaCampos(cCampos)
	METHOD NaoImplantado()
	METHOD PreparaTextoParaPesquisaComLike(cTextoOrig)
	METHOD RetornaQueryFiltroCardLaudoIncompleto(cLogin, cTexto, cLote, cNumeroDeSerie, cLaboratorio, cDescricaoOperacao, dInicioProducao, cRecno)
	METHOD RetornaQueryFiltroCardSemLaudos(cLogin, cTexto, cLote, cNumeroDeSerie, cLaboratorio, dInicioProducao)
ENDCLASS

METHOD new(oWSRestFul) CLASS InspecoesDeProcessosAPI
     Self:oWSRestFul  := oWSRestFul
	 Self:oQueryManager := QLTQueryManager():New()
Return Self

/*/{Protheus.doc} MapeiaCampos
Mapeia os Campos
@author brunno.costa
@since  23/05/2022
@param 01 - cCampos, String, string com os campos [nPosCPS_Titulo_API] para consideração separados por vírgula
@return aMapaCampos, Array , {{lConsidera, Titulo Interface, Título API, Campo Protheus, Tipo, Tamanho, Decimal}, ...}
                             {{nPosCPS_Considera, ..., nPosCPS_Decimal}, ...}
/*/
METHOD MapeiaCampos(cCampos) CLASS InspecoesDeProcessosAPI

    Local aMapaCampos := {}
	Local oQltAPIManager := QualityAPIManager():New(nil, Self:oWSRestFul)

    aAdd(aMapaCampos, {.F., "CodigoProduto"           , "productID"              , "QPK_PRODUT"      , "C" , oQltAPIManager:GetSx3Cache("QPK_PRODUT" ,"X3_TAMANHO"), 0})
	aAdd(aMapaCampos, {.F., "Produto"                 , "product"                , "B1_DESC"         , "C" , oQltAPIManager:GetSx3Cache("B1_DESC"    ,"X3_TAMANHO"), 0})
    aAdd(aMapaCampos, {.F., "OrdemDeProducao"         , "productionOrderID"      , "QPK_OP"          , "C" , oQltAPIManager:GetSx3Cache("QPK_OP"     ,"X3_TAMANHO"), 0})
	aAdd(aMapaCampos, {.F., "CodigoRoteiro"           , "operationRoutines"      , "QQK_CODIGO"      , "C" , oQltAPIManager:GetSx3Cache("QQK_CODIGO" ,"X3_TAMANHO"), 0})
	aAdd(aMapaCampos, {.F., "CodigoOperacao"          , "operationID"            , "QQK_OPERAC"      , "C" , oQltAPIManager:GetSx3Cache("QQK_OPERAC" ,"X3_TAMANHO"), 0})
	aAdd(aMapaCampos, {.F., "Operacao"                , "operation"              , "QQK_DESCRI"      , "C" , oQltAPIManager:GetSx3Cache("QQK_DESCRI" ,"X3_TAMANHO"), 0})
	aAdd(aMapaCampos, {.F., "Recurso"                 , "resource"               , "H1_DESCRI"       , "C" , oQltAPIManager:GetSx3Cache("H1_DESCRI"  ,"X3_TAMANHO"), 0})
    aAdd(aMapaCampos, {.F., "Quantidade"              , "lotSize"                , "QPK_TAMLOT"      , "N" , oQltAPIManager:GetSx3Cache("QPK_TAMLOTE","X3_TAMANHO"), oQltAPIManager:GetSx3Cache("QPK_TAMLOTE","X3_DECIMAL")})
	aAdd(aMapaCampos, {.F., "CodigoUM"                , "lotUnitID"              , "QPK_UM"          , "C" , oQltAPIManager:GetSx3Cache("QPK_UM"     ,"X3_TAMANHO"), 0})
	aAdd(aMapaCampos, {.F., "UnidadeMedida"           , "lotUnit"                , "AH_DESCPO"       , "C" , oQltAPIManager:GetSx3Cache("AH_DESCPO"  ,"X3_TAMANHO"), 0})
    aAdd(aMapaCampos, {.F., "Lote"                    , "lot"                    , "QPK_LOTE"        , "C" , oQltAPIManager:GetSx3Cache("QPK_LOTE"   ,"X3_TAMANHO"), 0})
    aAdd(aMapaCampos, {.F., "NumeroDeSerie"           , "serialNumber"           , "QPK_NUMSER"      , "C" , oQltAPIManager:GetSx3Cache("QPK_NUMSER" ,"X3_TAMANHO"), 0})
    aAdd(aMapaCampos, {.F., "DataEmissao"             , "date"                   , "QPK_EMISSA"      , "D" , oQltAPIManager:GetSx3Cache("QPK_EMISSAO","X3_TAMANHO"), 0})
    aAdd(aMapaCampos, {.F., "ClienteLoja"             , "customer"               , "ClienteLoja"     , "C" , oQltAPIManager:GetSx3Cache("A1_NOME"    ,"X3_TAMANHO") + oQltAPIManager:GetSx3Cache("QPK_CLIENT","X3_TAMANHO") + oQltAPIManager:GetSx3Cache("QPK_LOJA","X3_TAMANHO") + 4, 0})
    aAdd(aMapaCampos, {.F., "VersaEspecificacao"      , "specificationVersion"   , "QPK_REVI"        , "C" , oQltAPIManager:GetSx3Cache("QPK_REVI"   ,"X3_TAMANHO"), 0})
    aAdd(aMapaCampos, {.F., "DataProducao"            , "productionDate"         , "QPK_DTPROD"      , "D" , oQltAPIManager:GetSx3Cache("QPK_DTPROD" ,"X3_TAMANHO"), 0})
    aAdd(aMapaCampos, {.F., "UsuarioPermitido"        , "allowedUser"            , "Permitido"       , "L" ,                                       3, 0})
	aAdd(aMapaCampos, {.F., "LaudoOperacao"           , "operationReport"        , "QPM_LAUDO"       , "C" ,                                       1, 0})
	aAdd(aMapaCampos, {.F., "Status"                  , "status"                 , "Status"          , "C" ,                                       1, 0})
	aAdd(aMapaCampos, {.F., "LaudoIncompleto"         , "incompleteReport"       , "incompletereport", "C" ,                                       1, 0})
	aAdd(aMapaCampos, {.T., "RecnoInspecao"           , "recno"                  , "R_E_C_N_O_"      , "NN",                                       0, 0}) //NN para não formatar como número pois não temos certeza do tamanho configurado na tabela do cliente
 
	Self:oAPIManager := QualityAPIManager():New(aMapaCampos, Self:oWSRestFul)
	Self:oAPIManager:MarcaCamposConsiderados(cCampos, aMapaCampos, nPosCPS_Titulo_API)

Return aMapaCampos

/*/{Protheus.doc} CriaAliasPesquisa
Cria Alias para Pesquisa Lista de Inspeções de Processo com Base em Texto nos Campos Produto, OP
@author brunno.costa
@since  23/05/2022
@param 01 - cLogin             , caracter, login do usuário para validação das permissões de acesso
@param 02 - cLaboratorio       , caracter, laboratório para filtro
@param 03 - cTexto             , caracter, texto para pesquisa nos campos de OP e Produto
@param 04 - cOrdem             , caracter, ordenação para retornar a listagem dos dados
@param 05 - cTipoOrdem         , caracter, tipo de ordenação para retornar a listagem dos dados (Ascencente ou Decrescente)
@param 06 - nPagina            , numérico, página atual dos dados para consulta
@param 07 - nTamPag            , numérico, tamanho de página padrão com a quantidade de registros para retornar
@param 08 - cCampos            , caracter, campos que deverão estar contidos na mensagem
@param 09 - cRecno             , caracter, recno do registro para filtro
@param 10 - cOperacao          , caracter, operacao da inspecao para filtro
@param 11 - lNaoIniciadas      , lógico  , indica se realiza filtro de inspeções não iniciadas
@param 12 - lSemLaudos         , lógico  , indica se realiza filtro de inspeções sem laudos
@param 13 - lLaudosIncompletos , lógico  , indica se realiza filtro de inspeções com laudos incompletos
@param 14 - cLote              , caracter, filtro de lote
@param 15 - cNumeroDeSerie     , caracter, filtro de numero de série
@param 16 - cDescricaoOperacao , caracter, filtro por descrição da operação
@param 17 - dInicioProducao    , data    , filtro de data inicial da produção 
@return cAlias, caracter, alias com os dados da pesquisa
/*/
METHOD CriaAliasPesquisa(cLogin, cLaboratorio, cTexto, cOrdem, cTipoOrdem, nPagina, nTamPag, cCampos, cRecno, cOperacao, lNaoIniciadas, lSemLaudos, lLaudosIncompletos, cLote, cNumeroDeSerie, cDescricaoOperacao, dInicioProducao) CLASS InspecoesDeProcessosAPI
     
	Local bErrorBlock            := ErrorBlock({|e| Self:oAPIManager:ErrorBlock(e, e:Description), Break(e)})
    Local cAlias                 := Nil
	Local cDescricaoOperacaoOrig := cDescricaoOperacao
	Local cLoteOrig              := cLote
	Local cNumeroDeSerieOrig     := cNumeroDeSerie
	Local cOrdemDB               := Nil
    Local cQuery                 := Nil
	Local cTextoOrig             := cTexto

    Local nEnd        := 0
	Local nStart      := 0

	Default cCampos            := "*"
	Default cDescricaoOperacao := ""
	Default cLaboratorio       := ""
	Default cLogin             := ""
	Default cLote              := ""
	Default cNumeroDeSerie     := ""
	Default cOperacao          := ""
	Default cOrdem             := ""
	Default cRecno             := ""
	Default cTexto             := ""
	Default cTipoOrdem         := ""
	Default dInicioProducao    := dDataBase - 180
	Default lLaudosIncompletos := .F.
	Default lNaoIniciadas      := .F.
	Default lSemLaudos         := .F.
	Default nPagina            := 1
	Default nTamPag            := 999999

	nStart := ((nPagina - 1) * nTamPag) + 1
	nEnd   := (nPagina * nTamPag) + 1

	BEGIN SEQUENCE
		Self:MapeiaCampos(cCampos)

		cTexto             := Self:PreparaTextoParaPesquisaComLike(cTexto)
		cLote              := Self:PreparaTextoParaPesquisaComLike(cLote)
		cNumeroDeSerie     := Self:PreparaTextoParaPesquisaComLike(cNumeroDeSerie)
		cDescricaoOperacao := Self:PreparaTextoParaPesquisaComLike(cDescricaoOperacao)

		Self:oAPIManager:AvaliaPELaboratoriosRelacionadosAoUsuario()
		
		cQuery := " SELECT * "
		cQuery += " FROM ( "

		cQuery += " SELECT  ROW_NUMBER() OVER( "
    	
		cOrdemDB := Self:oAPIManager:RetornaOrdemDB(cOrdem,cTipoOrdem)
		cOrdemDB := IIf(Empty(cOrdemDB), "QPK_OP DESC, QQK_CODIGO ASC, QQK_OPERAC ASC", cOrdemDB)

		cQuery += " ORDER BY " + cOrdemDB + " ) LINHA, "

		cQuery += " QPK_PRODUT, "
		cQuery += " QPK_OP, "
		cQuery += " QQK_CODIGO, "
		cQuery += " QQK_OPERAC, "
		cQuery += " QPK_TAMLOT, "
		cQuery += " QPK_UM, "
		cQuery += " QPK_LOTE, "
		cQuery += " QPK_NUMSER, "
		cQuery += " QPK_EMISSA, "
		cQuery += " ClienteLoja, "
		cQuery += " QPK_REVI, "
		cQuery += " QPK_DTPROD, "
		cQuery += " R_E_C_N_O_, "
		cQuery += " Permitido, "
		cQuery += " QPM_LAUDO, "
		cQuery += " Status, "
		cQuery += " incompletereport, "
		cQuery += " B1_DESC, "
		cQuery += " QQK_DESCRI, "
		cQuery += " H1_DESCRI, "
		cQuery += " AH_DESCPO "

		cQuery += " FROM  "
		cQuery += " ( "

		cQuery += " SELECT "
		cQuery +=        " QPK.QPK_PRODUT, "
		cQuery +=        " QPK.QPK_OP, "
		cQuery +=        " QQK.QQK_CODIGO, "
		cQuery +=        " QQK.QQK_OPERAC, "
		cQuery +=        " QPK.QPK_TAMLOT, "
		cQuery +=        " QPK.QPK_UM, "
		cQuery +=        " QPK.QPK_LOTE, "
		cQuery +=        " QPK.QPK_NUMSER, "
		cQuery +=        " QPK.QPK_EMISSA, "
		cQuery +=        " COALESCE ((CASE QPK_CLIENT "
		cQuery +=                       " WHEN NULL THEN '' "
		cQuery +=                       " ELSE CONCAT( CONCAT( CONCAT( CONCAT( A1_COD , '-' ) , A1_LOJA ) , ' ' ) , A1_NOME ) "
		cQuery +=                   " END), ' ') ClienteLoja, "
		cQuery +=        " QPK.QPK_REVI, "
		cQuery +=        " QPK.QPK_DTPROD, "
		cQuery +=        " QPK.R_E_C_N_O_, "
		cQuery +=        " QAA.Permitido, "
		cQuery +=        " QUERY_STATUS.QPM_LAUDO, "
		
		cQuery +=        " (CASE QPK.QPK_SITOP "
		cQuery +=             " WHEN '2' THEN 'A' "
		cQuery +=             " WHEN '3' THEN 'R' "
		cQuery +=             " WHEN '4' THEN 'U' "
		cQuery +=             " WHEN '5' THEN 'C' "
		cQuery +=             " WHEN '6' THEN 'E' "
		cQuery +=             " ELSE "

		cQuery +=             " COALESCE (QUERY_STATUS.QPM_LAUDO, "
		cQuery +=                      " (CASE COALESCE (QPR_RESULT, "
		cQuery +=                                       "'N') "
		cQuery +=                           " WHEN 'N' THEN 'N' "
		cQuery +=                           " ELSE 'I' "
		cQuery +=                       " END))

		cQuery +=        " END) Status, "


		If (lNaoIniciadas .OR. lSemLaudos)
			cQuery +=        " 'false' incompletereport, "
		
		//IF para Otimização de performance, fará com que o card de laudo incompleto não funcione quando filtrar por descrição da operação apenas
		ElseIf !(Empty(cDescricaoOperacaoOrig) .OR. !Empty(cTextoOrig) .OR. !Empty(cLoteOrig) .OR. !Empty(cNumeroDeSerieOrig) .OR. !Empty(cLaboratorio))
			cQuery +=        " 'false' incompletereport, "

		Else
			cQuery +=        " (CASE WHEN INCOMPLETOS.QPL_OPERAC IS NULL THEN 'false' ELSE 'true' END) incompletereport, "
			
		EndIf

		cQuery +=        " SB1.B1_DESC, "
		cQuery +=        " QQK.QQK_DESCRI, "
		cQuery +=        " SH1.H1_DESCRI, "
		cQuery +=        " SAH.AH_DESCPO "
		cQuery += " FROM "
		cQuery +=   "(SELECT AH_UNIMED, "
		cQuery +=          " AH_DESCPO "
		cQuery +=   " FROM " + RetSQLName("SAH") + " "
		cQuery +=   " WHERE "
		cQuery +=        " (AH_FILIAL = '" + xFilial("SAH") + "') "
		cQuery +=    " AND (D_E_L_E_T_ = ' ') "
		cQuery +=    " ) SAH "
		cQuery += " RIGHT JOIN "
		cQuery +=   "(SELECT H1_CODIGO, "
		cQuery +=          " H1_DESCRI "
		cQuery +=   " FROM " + RetSQLName("SH1") + " "
		cQuery +=   " WHERE "
		cQuery +=        " (H1_FILIAL = '" + xFilial("SH1") + "') "
		cQuery +=    " AND (D_E_L_E_T_ = ' ') "
		cQuery +=    " ) SH1 "
		cQuery += " RIGHT JOIN "
		cQuery +=   "(SELECT QPM.QPM_PRODUT, "
		cQuery +=          " QPM.QPM_OP, "
		cQuery +=          " QPM.QPM_ROTEIR, "
		cQuery +=          " QPM.QPM_OPERAC, "
		cQuery +=          " QPM.QPM_LOTE, "
		cQuery +=          " QPM.QPM_NUMSER, "
		cQuery +=          " QPM.QPM_LAUDO "
		cQuery +=   " FROM " + RetSQLName("QPM") + " QPM "
		cQuery +=   " INNER JOIN "
		cQuery +=     "(SELECT QPD_CODFAT, "
		cQuery +=            " QPD_CATEG "
		cQuery +=     " FROM " + RetSQLName("QPD") + " "
		cQuery +=     " WHERE (QPD_FILIAL = '" + xFilial("QPD") + "') "
		cQuery +=       " AND (D_E_L_E_T_ = ' ')) QPD "
		cQuery +=   " ON QPM.QPM_LAUDO = QPD.QPD_CODFAT "
		cQuery +=   " WHERE (QPM.QPM_FILIAL = '" + xFilial("QPM") + "') "
		If !(!Empty(cRecno) .AND. cRecno <> "0") .And. (Empty(cTextoOrig)) .And. (Empty(cLoteOrig)) .And. (Empty(cNumeroDeSerieOrig))
			cQuery += " AND (QPM.QPM_DTLAUD >= '" + DtoS(dInicioProducao) + "') "
		EndIf
		cQuery +=     " AND (QPM.D_E_L_E_T_ = ' ') "
		If !Empty(cTextoOrig)
			cQuery +=        " AND (    (UPPER(QPM_PRODUT) LIKE UPPER("+cTexto+") ) "   //5
			cQuery +=              " OR (UPPER(QPM_OP)     LIKE UPPER("+cTexto+") ) ) " //6			
		EndIf
		If !Empty(cLoteOrig)
			cQuery +=        " AND (UPPER(QPM_LOTE) LIKE UPPER("+cLote+") ) " 
		EndIf
		If !Empty(cNumeroDeSerieOrig)
			cQuery +=        " AND (UPPER(QPM_NUMSER) LIKE UPPER("+cNumeroDeSerie+") ) " 
		EndIf
		cQuery += " ) QUERY_STATUS "

		cQuery += " RIGHT JOIN "
		cQuery +=   "(SELECT QPK_PRODUT, "
		cQuery +=          " QPK_OP, "
		cQuery +=          " QPK_TAMLOT, "
		cQuery +=          " QPK_UM, "
		cQuery +=          " QPK_LOTE, "
		cQuery +=          " QPK_NUMSER, "
		cQuery +=          " QPK_EMISSA, "
		cQuery +=          " QPK_REVI, "
		cQuery +=          " QPK_DTPROD, "
		cQuery +=          " QPK_CLIENT, "
		cQuery +=          " QPK_LOJA, "
		cQuery +=          " R_E_C_N_O_, "
		cQuery +=          " QPK_SITOP "
		cQuery +=   " FROM " + RetSQLName("QPK") + " "
		cQuery +=   " WHERE (QPK_FILIAL = '" + xFilial("QPK") + "') "

		If !Empty(cRecno) .AND. cRecno <> "0"
			cQuery +=    " AND (R_E_C_N_O_ = " + cRecno + ") "
		EndIf

		If !Empty(cTextoOrig)
			cQuery +=        " AND (    (UPPER(QPK_PRODUT) LIKE UPPER("+cTexto+") ) "   //5
			cQuery +=              " OR (UPPER(QPK_OP)     LIKE UPPER("+cTexto+") ) ) " //6
		EndIf

		If !Empty(cLoteOrig)
			cQuery +=        " AND (UPPER(QPK_LOTE) LIKE UPPER("+cLote+") ) " 
		EndIf

		If !Empty(cNumeroDeSerieOrig)
			cQuery +=        " AND (UPPER(QPK_NUMSER) LIKE UPPER("+cNumeroDeSerie+") ) " 
		EndIf

		If !(!Empty(cRecno) .AND. cRecno <> "0") .And. (Empty(cTextoOrig)) .And. (Empty(cLoteOrig)) .And. (Empty(cNumeroDeSerieOrig))
			cQuery +=        " AND QPK_EMISSA >= '" + DtoS(dInicioProducao) + "'"
		EndIf
		
		cQuery +=    " AND  (D_E_L_E_T_ = ' ') "
		cQuery += " ) QPK "

		cQuery += " INNER JOIN "
		cQuery +=   "(SELECT QQK_CODIGO, "
		cQuery +=          " QQK_OPERAC, "
		cQuery +=          " QQK_PRODUT, "
		cQuery +=          " QQK_REVIPR, "
		cQuery +=          " QQK_DESCRI, "
		cQuery +=          " QQK_RECURS "
		cQuery +=   " FROM " + RetSQLName("QQK") + " "
		cQuery +=   " WHERE (QQK_FILIAL = '" + xFilial("QQK") + "') "
		cQuery +=    " AND  (D_E_L_E_T_ = ' ')
		cQuery +=  " ) QQK "
		cQuery += " ON    QPK.QPK_PRODUT = QQK.QQK_PRODUT "
		cQuery +=   " AND QPK.QPK_REVI   = QQK.QQK_REVIPR "
		
		If !Empty(cOperacao)
			cQuery +=   " AND QQK.QQK_OPERAC = '" + cOperacao + "' "
		EndIf

		If !Empty(cDescricaoOperacaoOrig)
			cQuery +=        " AND (UPPER(QQK_DESCRI) LIKE UPPER("+cDescricaoOperacao+") ) "
		EndIf

		If Self:oAPIManager:lPELaboratoriosRelacionadosAoUsuario .OR. !Empty(cLaboratorio)
			cQuery += " INNER JOIN "
			cQuery += " (SELECT QP8_PRODUT AS PRODUTO, QP8_REVI AS REVISAO, QP8_CODREC, QP8_OPERAC, QP8_LABOR "
			cQuery += " FROM " + RetSQLName("QP8") + " "
			cQuery += " WHERE (QP8_FILIAL = '" + xFilial("QP8") + "') "
			If !Empty(cLaboratorio)
				cQuery += " AND (QP8_LABOR = '" + cLaboratorio + "') "
			EndIf
			cQuery += " AND D_E_L_E_T_ = ' ' "
			cQuery +=   Self:oAPIManager:RetornaFiltroPELaboratoriosRelacionadosAoUsuario("QP8_LABOR", cLogin)
			cQuery += " UNION "
			cQuery += " SELECT QP7_PRODUT, QP7_REVI, QP7_CODREC, QP7_OPERAC, QP7_LABOR "
			cQuery += " FROM " + RetSQLName("QP7") + " "
			cQuery += " WHERE (QP7_FILIAL = '" + xFilial("QP7") + "') "
			If !Empty(cLaboratorio)
				cQuery += " AND (QP7_LABOR = '" + cLaboratorio + "') "
			EndIf
			cQuery += " AND D_E_L_E_T_ = ' ' "
			cQuery +=   Self:oAPIManager:RetornaFiltroPELaboratoriosRelacionadosAoUsuario("QP7_LABOR", cLogin)
			cQuery += " ) FILTROLAB ON QPK.QPK_PRODUT = FILTROLAB.PRODUTO "
			cQuery +=            " AND QPK.QPK_REVI   = FILTROLAB.REVISAO "
			cQuery +=            " AND QQK.QQK_CODIGO = FILTROLAB.QP8_CODREC "
			cQuery +=            " AND QQK.QQK_OPERAC = FILTROLAB.QP8_OPERAC "
		EndIf

		cQuery += " INNER JOIN "
		cQuery +=   RetSQLName("SC2") + " SC2 "
		cQuery += " ON " 
		cQuery +=       " (SC2.C2_FILIAL = '" + xFilial("SC2") + "') "
		cQuery +=   " AND " + Self:oQueryManager:MontaRelationC2OP("QPK_OP")
		cQuery +=   Iif(SuperGetMV("MV_QIPOPEP") == "3", " AND (QQK_CODIGO = C2_ROTEIRO OR QQK_CODIGO = '" + QIPRotGene("QQK_CODIGO") + "') ", " AND QQK_CODIGO = C2_ROTEIRO ")
		cQuery +=   " AND (SC2.D_E_L_E_T_=' ') "		

		If lNaoIniciadas .OR. lSemLaudos
			cQuery += " LEFT JOIN ( " + Self:RetornaQueryFiltroCardSemLaudos(cLogin, cTextoOrig, cLoteOrig, cNumeroDeSerieOrig, cLaboratorio, dInicioProducao, cRecno) + ") LAUDOS "

			//Relaciona por CHAVE_OPERACAO
			cQuery += " ON " + Self:oQueryManager:MontaRelationArraysCampos(""      , {"QPK_OP", "QPK_LOTE", "QPK_NUMSER", "QQK_CODIGO", "QQK_OPERAC"},;
			                                                                "LAUDOS", {"QPL_OP", "QPL_LOTE", "QPL_NUMSER", "QPL_ROTEIR", "QPL_OPERAC"})
		ElseIf lLaudosIncompletos
			cQuery += " INNER JOIN ( " + Self:RetornaQueryFiltroCardLaudoIncompleto(cLogin, cTextoOrig, cLoteOrig, cNumeroDeSerieOrig, cLaboratorio, cDescricaoOperacaoOrig, dInicioProducao, cRecno) + ") INCOMPLETOS"

			//Relaciona por CHAVE_OPERACAO
			cQuery += " ON " + Self:oQueryManager:MontaRelationArraysCampos(""           , {"QPK_OP", "QPK_LOTE", "QPK_NUMSER", "QQK_CODIGO", "QQK_OPERAC"},;
			                                                                "INCOMPLETOS", {"QPL_OP", "QPL_LOTE", "QPL_NUMSER", "QPL_ROTEIR", "QPL_OPERAC"})

		//IF para Otimização de performance, fará com que o card de laudo incompleto não funcione quando filtrar por descrição da operação apenas
		ElseIf Empty(cDescricaoOperacaoOrig) .OR. !Empty(cTextoOrig) .OR. !Empty(cLoteOrig) .OR. !Empty(cNumeroDeSerieOrig) .OR. !Empty(cLaboratorio)
		//Else
			cQuery += " LEFT JOIN ( " + Self:RetornaQueryFiltroCardLaudoIncompleto(cLogin, cTextoOrig, cLoteOrig, cNumeroDeSerieOrig, cLaboratorio, cDescricaoOperacaoOrig, dInicioProducao, cRecno) + ") INCOMPLETOS"

			//Relaciona por CHAVE_OPERACAO
			cQuery += " ON " + Self:oQueryManager:MontaRelationArraysCampos(""           , {"QPK_OP", "QPK_LOTE", "QPK_NUMSER", "QQK_CODIGO", "QQK_OPERAC"},;
			                                                                "INCOMPLETOS", {"QPL_OP", "QPL_LOTE", "QPL_NUMSER", "QPL_ROTEIR", "QPL_OPERAC"})

		EndIf

		cQuery += " LEFT JOIN "
		cQuery +=   "(SELECT A1_COD, "
		cQuery +=          " A1_LOJA, "
		cQuery +=          " A1_NOME "
		cQuery +=   " FROM " + RetSQLName("SA1") + " "
		cQuery +=   " WHERE (A1_FILIAL = '" + xFilial("SA1") + "') "
		cQuery +=    " AND (D_E_L_E_T_ = ' ') "
		cQuery +=  " ) SA1 "
		cQuery += " ON SA1.A1_COD = QPK.QPK_CLIENT "
		cQuery +=   " AND SA1.A1_LOJA = QPK.QPK_LOJA "

		cQuery += " INNER JOIN "
		cQuery +=   "(SELECT B1_COD, "
		cQuery +=          " B1_DESC "
		cQuery +=   " FROM " + RetSQLName("SB1") + " "
		cQuery +=   " WHERE (B1_FILIAL = '" + xFilial("SB1") + "') "
		cQuery +=    " AND  (D_E_L_E_T_ = ' ') "
		cQuery +=  " ) SB1 "
		cQuery += " ON SB1.B1_COD = QPK.QPK_PRODUT "

		cQuery += " LEFT JOIN "
		cQuery +=   "(SELECT DISTINCT QPR.QPR_OP, "
		cQuery +=                   " QPR.QPR_PRODUT, "
		cQuery +=                   " QPR.QPR_OPERAC, "
		cQuery +=                   " QPR.QPR_ROTEIR, "
		cQuery +=                   " QPR.QPR_LOTE, "
		cQuery +=                   " QPR.QPR_NUMSER, "
		cQuery +=                   " 'X' QPR_RESULT "
		cQuery +=   " FROM " + RetSQLName("QPR") + " QPR "
		cQuery +=   " WHERE (QPR.QPR_FILIAL = '" + xFilial("QPR") + "') "
		
		If Self:oAPIManager:lPELaboratoriosRelacionadosAoUsuario .OR. !Empty(cLaboratorio)
			If !Empty(cLaboratorio)
				cQuery += " AND (QPR_LABOR = '" + cLaboratorio + "') "
			EndIf
			cQuery +=   Self:oAPIManager:RetornaFiltroPELaboratoriosRelacionadosAoUsuario("QPR_LABOR", cLogin)
		EndIf

		If !Empty(cTextoOrig)
			cQuery +=        " AND (    (UPPER(QPR_PRODUT) LIKE UPPER("+cTexto+") ) "  
			cQuery +=              " OR (UPPER(QPR_OP)     LIKE UPPER("+cTexto+") ) ) "
		EndIf
		
		If !Empty(cLoteOrig)
			cQuery +=        " AND (UPPER(QPR_LOTE) LIKE UPPER("+cLote+") ) " 
		EndIf

		If !Empty(cNumeroDeSerieOrig)
			cQuery +=        " AND (UPPER(QPR_NUMSER) LIKE UPPER("+cNumeroDeSerie+") ) " 
		EndIf

		If !(!Empty(cRecno) .AND. cRecno <> "0") .And. (Empty(cTextoOrig)) .And. (Empty(cLoteOrig)) .And. (Empty(cNumeroDeSerieOrig))
			cQuery +=        " AND (QPR_DTMEDI >= '" + DtoS(dInicioProducao) + "') "
		EndIf

		cQuery +=            " AND (QPR.D_E_L_E_T_ = ' ') "

		cQuery += " ) AMOSTRAGENS "
		
		//Relaciona por CHAVE_OPERACAO
		cQuery += " ON " + Self:oQueryManager:MontaRelationArraysCampos(""           , {"QPK_OP", "QPK_LOTE", "QPK_NUMSER", "QQK_CODIGO", "QQK_OPERAC"},;
																		"AMOSTRAGENS", {"QPR_OP", "QPR_LOTE", "QPR_NUMSER", "QPR_ROTEIR", "QPR_OPERAC"})

		//Relaciona por CHAVE_OPERACAO
		cQuery += " ON " + Self:oQueryManager:MontaRelationArraysCampos(""            , {"QPK_OP", "QPK_LOTE", "QPK_NUMSER", "QQK_CODIGO", "QQK_OPERAC"},;
																		"QUERY_STATUS", {"QPM_OP", "QPM_LOTE", "QPM_NUMSER", "QPM_ROTEIR", "QPM_OPERAC"})

		cQuery += " ON SH1.H1_CODIGO = QQK.QQK_RECURS "
		cQuery += " ON SAH.AH_UNIMED = QPK.QPK_UM "

		cQuery += " CROSS JOIN "
		cQuery +=   "(SELECT COALESCE( MAX(CASE "
		cQuery +=                         " WHEN QAA_NIVEL = NULL "
		cQuery += 							   " OR QAA_STATUS <> '1' "
		cQuery += 							   " OR (UPPER(RTRIM(QAA_LOGIN)) = '' ) "
		cQuery += 							   " THEN '.F.' "
		cQuery +=                         " ELSE '.T.' "
		cQuery +=                         " END), '.F.') Permitido "
		cQuery +=   " FROM " + RetSQLName("QAA") + " "
		cQuery +=   " WHERE (QAA_FILIAL = '" + xFilial("QAA") + "') "
		cQuery +=    " AND (UPPER(RTRIM(QAA_LOGIN)) = " + FwQtToChr(AllTrim(Upper(cLogin))) +" ) "
		cQuery +=    " AND (D_E_L_E_T_ = ' ') "
		cQuery +=  " ) QAA "

		cQuery += " WHERE 1=1 "
		If Empty(cTextoOrig) .AND. Empty(cLoteOrig) .AND. Empty(cNumeroDeSerieOrig) .AND. Empty(cRecno) .AND. !lNaoIniciadas .AND. !lSemLaudos .AND. !lLaudosIncompletos
			cQuery += " AND COALESCE(QUERY_STATUS.QPM_LAUDO,  "
			cQuery +=         " (CASE AMOSTRAGENS.QPR_OP "
			cQuery +=             " WHEN NULL THEN 'N' "
			cQuery +=             " ELSE 'I' "
			cQuery +=         " END)) "
			cQuery +=    " NOT IN ('A','R','U', 'C') "
			cQuery += " AND QPK_SITOP NOT IN ('2','3','4','5','6') "

		ElseIf lNaoIniciadas 
			cQuery += " AND LAUDOS.QPL_OP IS NULL "
			cQuery += " AND LAUDOS.QPL_OPERAC IS NULL "
			cQuery += " AND (CASE QPK.QPK_SITOP "
			cQuery +=             " WHEN '2' THEN 'A' "
			cQuery +=             " WHEN '3' THEN 'R' "
			cQuery +=             " WHEN '4' THEN 'U' "
			cQuery +=             " WHEN '5' THEN 'C' "
			cQuery +=             " WHEN '6' THEN 'E' "
			cQuery +=             " ELSE "
			cQuery +=             " COALESCE (QUERY_STATUS.QPM_LAUDO, "
			cQuery +=                      " (CASE COALESCE (QPR_RESULT, "
			cQuery +=                                       "'N') "
			cQuery +=                           " WHEN 'N' THEN 'N' "
			cQuery +=                           " ELSE 'I' "
			cQuery +=                       " END))
			cQuery +=        " END) = 'N' "

		ElseIf lSemLaudos
			cQuery += " AND LAUDOS.QPL_OPERAC IS NULL "
			cQuery += " AND (CASE QPK.QPK_SITOP "
			cQuery +=             " WHEN '2' THEN 'A' "
			cQuery +=             " WHEN '3' THEN 'R' "
			cQuery +=             " WHEN '4' THEN 'U' "
			cQuery +=             " WHEN '5' THEN 'C' "
			cQuery +=             " WHEN '6' THEN 'E' "
			cQuery +=             " ELSE "
			cQuery +=             " COALESCE (QUERY_STATUS.QPM_LAUDO, "
			cQuery +=                      " (CASE COALESCE (QPR_RESULT, "
			cQuery +=                                       "'N') "
			cQuery +=                           " WHEN 'N' THEN 'N' "
			cQuery +=                           " ELSE 'I' "
			cQuery +=                       " END))
			cQuery +=        " END) = 'I' "
			//cQuery += " AND (QPK_SITOP = '7') " //Desconsiderardo devido inconsistência nas bases
		EndIf

		cQuery +=       " ) DADOS ) DADOS2 "
		cQuery += " WHERE LINHA BETWEEN '" + cValToChar(nStart) + "' AND '" + cValToChar(nEnd) + "' "

		cQuery := Self:oAPIManager:ChangeQueryAllDB(cQuery)
		cAlias := Self:oQueryManager:executeQuery(cQuery)

	RECOVER
	END SEQUENCE
	ErrorBlock(bErrorBlock)

Return cAlias

/*/{Protheus.doc} PesquisaLista
Pesquisa Lista de Inspeções de Processo com Base em Texto nos Campos Produto, OP
@author brunno.costa
@since  23/05/2022
@param 01 - cLogin             , caracter, login do usuário para validação das permissões de acesso
@param 02 - cLaboratorio       , caracter, laboratório para filtro
@param 02 - cTexto             , caracter, texto para pesquisa nos campos de OP e Produto
@param 03 - cOrdem             , caracter, ordenação para retornar a listagem dos dados
@param 03 - cTipoOrdem         , caracter, tipo de ordenação para retornar a listagem dos dados (Ascencente ou Decrescente)
@param 04 - nPagina            , numérico, página atual dos dados para consulta
@param 05 - nTamPag            , numérico, tamanho de página padrão com a quantidade de registros para retornar
@param 06 - cCampos            , caracter, campos que deverão estar contidos na mensagem
@param 07 - cRecno             , caracter, recno do registro para filtro
@param 08 - cOperacao          , caracter, operacao da inspecao para filtro
@param 09 - lNaoIniciadas      , lógico, indica se realiza filtro de inspeções não iniciadas
@param 10 - lSemLaudos         , lógico, indica se realiza filtro de inspeções sem laudos
@param 11 - lLaudosIncompletos , lógico, indica se realiza filtro de inspeções com laudos incompletos
@param 12 - cLote              , caracter, filtro de lote
@param 13 - cNumeroDeSerie     , caracter, filtro de numero de série
@param 14 - cDescricaoOperacao , caracter, filtro por descrição da operação
@param 15 - dInicioProducao    , data    , filtro de data inicial da produção 
@return lRetorno, lógico, indica se conseguiu realizar o processamento
/*/
METHOD PesquisaLista(cLogin, cLaboratorio, cTexto, cOrdem, cTipoOrdem, nPagina, nTamPag, cCampos, cRecno, cOperacao, lNaoIniciadas, lSemLaudos, lLaudosIncompletos, cLote, cNumeroDeSerie, cDescricaoOperacao, dInicioProducao) CLASS InspecoesDeProcessosAPI
     
    Local cAlias      := Nil
    Local lRetorno    := .T.

	Default cRecno    := ""
	Default cOperacao := ""

	If Self:NaoImplantado()
		SetRestFault(405, EncodeUtf8(STR0006), .T.,; //"Módulo não está implantado"
		             405, EncodeUtf8(STR0007))       //"Fale com a TOTVS e faça implantação do módulo!"
		Return
	EndIf

    cAlias := Self:CriaAliasPesquisa(cLogin, cLaboratorio, cTexto, cOrdem, cTipoOrdem, nPagina, nTamPag, cCampos, cRecno, cOperacao, lNaoIniciadas, lSemLaudos, lLaudosIncompletos, cLote, cNumeroDeSerie, cDescricaoOperacao, dInicioProducao)

	If cAlias == Nil .OR. Empty(cAlias)
		lRetorno := .F.
		Self:oAPIManager:RespondeValor("message", Self:oAPIManager:cErrorMessage, Self:oAPIManager:cErrorMessage, Self:oAPIManager:cDetailedMessage)
	Else	
		lRetorno := Self:oAPIManager:ProcessaListaResultados(cAlias, nPagina, nTamPag, .F.)
		(cAlias)->(dbCloseArea())
	EndIf

Return lRetorno

/*/{Protheus.doc} UsuarioExistente
Identifica se o usuário possui cadastro na QAA
@author brunno.costa
@since  23/05/2022
@param 01 - cLogin , caracter, login do usuário para validação das permissões de acesso
@return lRetorno, lógico, indica se o usuário é permitido
/*/
METHOD UsuarioExistente(cLogin) CLASS InspecoesDeProcessosAPI
     
    Local cAlias         := Nil
    Local cQuery         := Nil
    Local lRetorno       := .T.
	Local oLaudos        := QIPLaudosEnsaios()                       :New()
	Local oQltAPIManager := QualityAPIManager()                      :New(, Self:oWSRestFul)
	Local oResponse      := JsonObject()                             :New()
	Local oResultQIE     := ResultadosEnsaiosInspecaoDeEntradasAPI() :New()
	Local oResultQIP     := ResultadosEnsaiosInspecaoDeProcessosAPI():New()
	
	If oQltAPIManager:ValidaPrepareInDoAmbiente()

		cQuery :=   "SELECT COALESCE( MAX(CASE "
		cQuery +=                         " WHEN QAA_NIVEL = NULL "
		cQuery += 							   " OR QAA_STATUS <> '1' "
		cQuery += 							   " OR (UPPER(RTRIM(QAA_LOGIN)) = '' ) "
		cQuery += 							   " THEN 'false' "
		cQuery +=                         " ELSE 'true' "
		cQuery +=                         " END), 'false') Permitido "
		cQuery +=   " FROM " + RetSQLName("QAA") + " "
		cQuery +=   " WHERE (QAA_FILIAL = '" + xFilial("QAA") + "') "
		cQuery +=     " AND (UPPER(RTRIM(QAA_LOGIN)) = " + FwQtToChr(AllTrim(Upper(cLogin))) +" ) "
		cQuery +=     " AND (D_E_L_E_T_ = ' ') "

		cAlias := Self:oQueryManager:executeQuery(cQuery)

		If Alltrim((cAlias)->Permitido ) == "true"
			
			oResponse['exist'] := Iif(Empty(oResponse['exist']).And. oResultQIP:ModoAcessoResultados(cLogin)       $ "|1|3|"       , "qip"  , oResponse['exist'])
			oResponse['exist'] := Iif(Empty(oResponse['exist']).And. oResultQIE:ModoAcessoResultados(cLogin)       $ "|1|3|"       , "qie"  , oResponse['exist'])
			oResponse['exist'] := Iif(Empty(oResponse['exist']).And. oLaudos:ModoAcessoLaudo(cLogin, "QAA_LDOOPE") $ "|1|3|"       , "qip"  , oResponse['exist'])
			oResponse['exist'] := Iif(Empty(oResponse['exist']).And.(oLaudos:ModoAcessoLaudo(cLogin, "QAA_LDOLAB") $ "|1|3|" .OR. ;
			                                                         oLaudos:ModoAcessoLaudo(cLogin, "QAA_LDOGER") $ "|1|3|")      , "qie"  , oResponse['exist'])
			oResponse['exist'] := Iif(Empty(oResponse['exist'])                                                                    , "false", oResponse['exist'])

		EndIf

		lRetorno := Alltrim((cAlias)->Permitido ) == "true"
		
		oResponse['hasNext'      ] := .F.
		(cAlias)->(dbCloseArea())

		Self:oWSRestFul:SetContentType("application/json")

		//Processou com sucesso.
		HTTPSetStatus(200)
		oResponse['code'         ] := 200
		Self:oWSRestFul:SetResponse(EncodeUtf8(oResponse:toJson()))
	EndIf

Return lRetorno

/*/{Protheus.doc} NaoImplantado
Indica se o Módulo QIP não está implantado
@author brunno.costa
@since  16/08/2022
@return lNaoImplantado, lógico, indica se o módulo QIP não está implantado
/*/
METHOD NaoImplantado() CLASS InspecoesDeProcessosAPI
	Local lNaoImplantado := .F.
	
	DbSelectArea("QPK")
	QPK->(DbSetOrder(1))
	QPK->(DbSeek(xFilial("QPK")))
	lNaoImplantado := QPK->(Eof())
	
Return lNaoImplantado

/*/{Protheus.doc} RetornaContagemCards
Indica se o Módulo QIP não está implantado
@author brunno.costa
@since  16/08/2022
@param 01 - cLogin            , caracter, login de usuário relacionado
@param 02 - cTexto            , caracter, texto de pesquisa
@param 03 - cLote             , caracter, lote de pesquisa
@param 04 - cNumeroDeSerie    , caracter, número de série de pesquisa
@param 05 - cDescricaoOperacao, caracter, descrição da operação de pesquisa
@param 06 - cLaboratorio      , caracter, laboratório de filtro
@param 07 - dInicioProducao   , data    , filtro de data inicial da produção 
@return oRetorno, JsonObject, objeto json com os dados para retorno
		oRetorno['notStarted']        = Inspeções não iniciadas
		oRetorno['withoutReport']     = Inspeções sem laudos
		oRetorno['incompleteReports'] = Inspeções com laudos incompletos
/*/
METHOD RetornaContagemCards(cLogin, cTexto, cLote, cNumeroDeSerie, cDescricaoOperacao, cLaboratorio, dInicioProducao) CLASS InspecoesDeProcessosAPI
	
	Local bErrorBlock            := Nil
	Local cAlias                 := Nil
	Local cDescricaoOperacaoOrig := cDescricaoOperacao
	Local cLoteOrig              := cLote
	Local cNumeroDeSerieOrig     := cNumeroDeSerie
    Local cQuery                 := Nil
	Local cTextoOrig             := cTexto
	Local oRetorno               := JsonObject():New()

	Default cTexto       := ""
	Default cLaboratorio := ""

	Self:oAPIManager := QualityAPIManager():New(Nil, Self:oWSRestFul)
	bErrorBlock := ErrorBlock({|e| Self:oAPIManager:ErrorBlock(e, e:Description), Break(e)})
	
	BEGIN SEQUENCE
		cTexto             := Self:PreparaTextoParaPesquisaComLike(cTexto)
		cLote              := Self:PreparaTextoParaPesquisaComLike(cLote)
		cNumeroDeSerie     := Self:PreparaTextoParaPesquisaComLike(cNumeroDeSerie)
		cDescricaoOperacao := Self:PreparaTextoParaPesquisaComLike(cDescricaoOperacao)

		cQuery := " SELECT "
		cQuery += 	" SUM( "
		cQuery += 	    " ( "
		cQuery += 	      " CASE UNIAO.INSPECOES WHEN 'X' THEN 0 ELSE  "
		cQuery += 	 	    " (CASE UNIAO.LAUDO WHEN 'X' THEN  "
		cQuery += 	 	       " (CASE UNIAO.AMOSTRAS WHEN 'X' THEN "
		cQuery += 	 	          " (CASE UNIAO.LAUDO_GERAL WHEN 'X' THEN 1 ELSE 0 END) "
		cQuery +=               " ELSE 0 END) "
		cQuery += 	 	     " ELSE 0 END) "
		cQuery += 	 	 " END "
		cQuery += 	    " ) "
		cQuery += 	  " ) NAO_INICIADA, "

		cQuery += 	" SUM(CASE UNIAO.AMOSTRAS
		cQuery +=       " WHEN 'X' THEN 0 "
		cQuery +=       " ELSE (CASE UNIAO.LAUDO WHEN 'X' THEN  "
		cQuery +=			   " (CASE UNIAO.LAUDO_GERAL WHEN 'X' THEN  "
		cQuery +=				   " (CASE QPK_SITOP WHEN ' ' THEN 0 ELSE 1 END) "
		cQuery +=			    " ELSE 0 END) "
		cQuery +=            " ELSE 0 END) "
		cQuery +=     " END) SEM_LAUDO, "

		cQuery += 	" SUM( CASE CONCAT(UNIAO.LAUDO, UNIAO.LAUDO_GERAL)  WHEN 'TX'  THEN 1 ELSE 0  END ) INCOMPLETO "

		cQuery += " FROM "
		cQuery += 	   " (SELECT DISTINCT "
		
		cQuery +=              " COALESCE(COALESCE(AMOSTRAS.QPR_OP    , COALESCE(LAUDO.QPL_OP    , LAUDO_GERAL.QPL_OP    )), INSPECOES.QPK_OP    ) QPL_OP, "
		cQuery +=              " COALESCE(COALESCE(AMOSTRAS.QPR_LOTE  , COALESCE(LAUDO.QPL_LOTE  , LAUDO_GERAL.QPL_LOTE  )), INSPECOES.QPK_LOTE  ) QPL_LOTE, "
		cQuery +=              " COALESCE(COALESCE(AMOSTRAS.QPR_NUMSER, COALESCE(LAUDO.QPL_NUMSER, LAUDO_GERAL.QPL_NUMSER)), INSPECOES.QPK_NUMSER) QPL_NUMSER, "
		cQuery +=              " COALESCE(COALESCE(AMOSTRAS.QPR_ROTEIR, COALESCE(LAUDO.QPL_ROTEIR, LAUDO_GERAL.QPL_ROTEIR)), INSPECOES.QQK_CODIGO) QPL_ROTEIR, "
		cQuery +=              " COALESCE(COALESCE(AMOSTRAS.QPR_OPERAC,          LAUDO.QPL_OPERAC                         ), INSPECOES.QQK_OPERAC) QPL_OPERAC, "

		cQuery +=              " INSPECOES.QPK_SITOP, "
		cQuery +=              " (CASE WHEN COALESCE(INSPECOES.QQK_OPERAC, 'X') = 'X' THEN 'X' ELSE 'T' END) INSPECOES,
        cQuery +=              " (CASE WHEN COALESCE(AMOSTRAS.QPR_OPERAC , 'X') = 'X' THEN 'X' ELSE 'T' END) AMOSTRAS, "
        cQuery +=              " (CASE WHEN COALESCE(LAUDO.QPL_OPERAC    , 'X') = 'X' THEN 'X' ELSE 'T' END) LAUDO, "
		cQuery +=              " (CASE WHEN COALESCE(LAUDO_GERAL.QPL_OP  , 'X') = 'X' THEN 'X' ELSE 'T' END) LAUDO_GERAL "
		cQuery +=       " FROM  "


		cQuery += " (SELECT "
		cQuery +=   " QPK_OP, QPK_LOTE, QPK_NUMSER, QQK_CODIGO, QQK_OPERAC, QPK_SITOP "
		cQuery += " FROM (SELECT DISTINCT QPK.QPK_PRODUT, QPK.QPK_OP, QQK.QQK_CODIGO, QQK.QQK_OPERAC, QPK.QPK_LOTE, QPK.QPK_NUMSER, QPK.QPK_REVI, QPK.QPK_SITOP "
		cQuery +=       " FROM (SELECT QPK_PRODUT, QPK_OP, QPK_LOTE, QPK_NUMSER, QPK_REVI, QPK_SITOP "
		cQuery +=             " FROM " + RetSQLName("QPK")
		cQuery +=             " WHERE (QPK_FILIAL = '" + xFilial("QPK") + "') "

		If !Empty(cTextoOrig)
			cQuery +=         " AND (    (UPPER(QPK_PRODUT) LIKE UPPER("+cTexto+") ) "  
			cQuery +=               " OR (UPPER(QPK_OP)     LIKE UPPER("+cTexto+") ) ) "
		EndIf

		If !Empty(cLoteOrig)
			cQuery +=        " AND (UPPER(QPK_LOTE) LIKE UPPER("+cLote+") ) " 
		EndIf

		If !Empty(cNumeroDeSerieOrig)
			cQuery +=        " AND (UPPER(QPK_NUMSER) LIKE UPPER("+cNumeroDeSerie+") ) " 
		EndIf

		If (Empty(cTextoOrig)) .AND. (Empty(cLoteOrig)) .AND. (Empty(cNumeroDeSerieOrig))
			cQuery +=        " AND QPK_EMISSA >= '" + DtoS(dInicioProducao) + "'"
		EndIf

		cQuery +=               " AND (D_E_L_E_T_ = ' ') ) QPK "
		
		cQuery += " INNER JOIN (SELECT QQK_CODIGO, QQK_OPERAC, QQK_PRODUT, QQK_REVIPR "
		cQuery +=             " FROM " + RetSQLName("QQK")
		cQuery +=             " WHERE (QQK_FILIAL = '" + xFilial("QQK") + "') "
		If !Empty(cDescricaoOperacaoOrig)
			cQuery +=           " AND (UPPER(QQK_DESCRI) LIKE UPPER("+cDescricaoOperacao+") ) "
		EndIf
		cQuery +=               " AND (D_E_L_E_T_ = ' ') ) QQK "
		cQuery +=             " ON    QPK.QPK_REVI = QQK.QQK_REVIPR "
		cQuery +=             " AND QPK.QPK_PRODUT = QQK.QQK_PRODUT "

		If Self:oAPIManager:lPELaboratoriosRelacionadosAoUsuario .OR. !Empty(cLaboratorio) //Filtro de Laboratórios - INSPECOES
			cQuery += " INNER JOIN "
			cQuery += " (SELECT QP8_PRODUT AS PRODUTO, QP8_REVI AS REVISAO, QP8_CODREC, QP8_OPERAC, QP8_LABOR "
			cQuery += " FROM " + RetSQLName("QP8") + " "
			cQuery += " WHERE (QP8_FILIAL = '" + xFilial("QP8") + "') "
			If !Empty(cLaboratorio)
				cQuery += " AND (QP8_LABOR = '" + cLaboratorio + "') "
			EndIf
			cQuery +=     " AND (D_E_L_E_T_ = ' ') "
			cQuery +=   Self:oAPIManager:RetornaFiltroPELaboratoriosRelacionadosAoUsuario("QP8_LABOR", cLogin)
			cQuery += " UNION "
			cQuery += " SELECT QP7_PRODUT, QP7_REVI, QP7_CODREC, QP7_OPERAC, QP7_LABOR "
			cQuery += " FROM " + RetSQLName("QP7") + " "
			cQuery += " WHERE (QP7_FILIAL = '" + xFilial("QP7") + "') "
			If !Empty(cLaboratorio)
				cQuery += " AND (QP7_LABOR = '" + cLaboratorio + "') "
			EndIf
			cQuery += " AND (D_E_L_E_T_ = ' ') "
			cQuery +=   Self:oAPIManager:RetornaFiltroPELaboratoriosRelacionadosAoUsuario("QP7_LABOR", cLogin)
			cQuery += " ) FILTROLAB ON QPK.QPK_PRODUT = FILTROLAB.PRODUTO "
			cQuery +=            " AND QPK.QPK_REVI   = FILTROLAB.REVISAO "
			cQuery +=            " AND QQK.QQK_CODIGO = FILTROLAB.QP8_CODREC "
			cQuery +=            " AND QQK.QQK_OPERAC = FILTROLAB.QP8_OPERAC "
		EndIf

		If Empty(cTextoOrig) .AND. Empty(cLoteOrig) .AND. Empty(cNumeroDeSerieOrig)
			cQuery +=         " AND QPK.QPK_SITOP NOT IN ('2','3','4','5') "
		EndIf

		cQuery +=             " INNER JOIN " + RetSQLName("SC2") + " SC2 "
		cQuery +=             " ON "
		cQuery +=                   " (SC2.C2_FILIAL = '" + xFilial("SC2") + "') "
		cQuery +=               " AND " + Self:oQueryManager:MontaRelationC2OP("QPK_OP")
		cQuery +=               Iif(SuperGetMV("MV_QIPOPEP") == "3", " AND (QQK_CODIGO = C2_ROTEIRO OR QQK_CODIGO = '" + QIPRotGene("QQK_CODIGO") + "') ", " AND QQK_CODIGO = C2_ROTEIRO ")
		cQuery +=               " AND (SC2.D_E_L_E_T_ = ' ') "
		cQuery +=               " ) DADOS) INSPECOES "


		cQuery += " LEFT JOIN (SELECT DISTINCT "
		cQuery +=   " QPR_OP, QPR_LOTE, QPR_NUMSER, QPR_ROTEIR, QPR_OPERAC "
		cQuery += " FROM " + RetSQLName("QPR")
		cQuery += " WHERE (QPR_FILIAL = '" + xFilial("QPR") + "') "
		If !Empty(cTextoOrig)
			cQuery += " AND (    (UPPER(QPR_PRODUT) LIKE UPPER("+cTexto+") ) "  
			cQuery +=       " OR (UPPER(QPR_OP)     LIKE UPPER("+cTexto+") ) ) "
		EndIf
		If !Empty(cLoteOrig)
			cQuery += " AND (UPPER(QPR_LOTE) LIKE UPPER("+cLote+") ) " 
		EndIf
		If !Empty(cNumeroDeSerieOrig)
			cQuery += " AND (UPPER(QPR_NUMSER) LIKE UPPER("+cNumeroDeSerie+") ) " 
		EndIf
		If !Empty(cLaboratorio)
			cQuery += " AND (QPR_LABOR = '" + cLaboratorio + "') "
		EndIf
		
		If (Empty(cTextoOrig)) .And. (Empty(cLoteOrig)) .And. (Empty(cNumeroDeSerieOrig))
			cQuery += " AND (QPR_DTMEDI >= '" + DtoS(dInicioProducao) + "') "
		EndIf

		cQuery +=     " AND (D_E_L_E_T_ = ' ')  "
		cQuery +=   " ) AMOSTRAS "

		//Relaciona por CHAVE_OPERACAO
		cQuery += " ON " + Self:oQueryManager:MontaRelationArraysCampos("AMOSTRAS" , {"QPR_OP", "QPR_LOTE", "QPR_NUMSER", "QPR_ROTEIR", "QPR_OPERAC"},;
																		"INSPECOES", {"QPK_OP", "QPK_LOTE", "QPK_NUMSER", "QQK_CODIGO", "QQK_OPERAC"})


		cQuery += " LEFT JOIN (SELECT DISTINCT "
		cQuery +=                   " QPL_OP, QPL_LOTE, QPL_NUMSER, QPL_ROTEIR, QPL_OPERAC "
		cQuery +=            " FROM (SELECT DISTINCT "
		cQuery +=                         " QPL_OP, QPL_LOTE, QPL_NUMSER, QPL_ROTEIR, QPL_OPERAC "
		cQuery +=                  " FROM " + RetSQLName("QPL")
		cQuery +=                  " WHERE (QPL_FILIAL = '" + xFilial("QPL") + "') "
		if !Empty(cTextoOrig)
			cQuery +=                " AND (    (UPPER(QPL_PRODUT) LIKE UPPER("+cTexto+") ) "  
			cQuery +=                      " OR (UPPER(QPL_OP)     LIKE UPPER("+cTexto+") ) ) "
		EndIf
		If !Empty(cLoteOrig)
			cQuery +=                " AND (UPPER(QPL_LOTE) LIKE UPPER("+cLote+") ) " 
		EndIf
		If !Empty(cNumeroDeSerieOrig)
			cQuery +=                " AND (UPPER(QPL_NUMSER) LIKE UPPER("+cNumeroDeSerie+") ) " 
		EndIf
		If (Empty(cTextoOrig)) .And. (Empty(cLoteOrig)) .And. (Empty(cNumeroDeSerieOrig))
			cQuery +=                " AND (QPL_DTLAUD >= '" + DtoS(dInicioProducao) + "') "
		EndIf
		
		cQuery +=                    " AND (QPL_OPERAC <> ' ') "
		cQuery +=                    " AND (QPL_LAUDO  <> ' ') "
		cQuery +=                    " AND (D_E_L_E_T_ = ' ') "

		cQuery +=                  " UNION "
		cQuery +=                  " SELECT DISTINCT "
		cQuery +=                         " QPM_OP, QPM_LOTE, QPM_NUMSER, QPM_ROTEIR, QPM_OPERAC "
		cQuery +=                  " FROM " + RetSQLName("QPM")
		cQuery +=                  " WHERE (QPM_FILIAL = '" + xFilial("QPM") + "') "
		If !Empty(cTextoOrig)
			cQuery +=              " AND (    (UPPER(QPM_PRODUT) LIKE UPPER("+cTexto+") ) "  
			cQuery +=                    " OR (UPPER(QPM_OP)     LIKE UPPER("+cTexto+") ) ) "
		EndIf
		If !Empty(cLoteOrig)
			cQuery +=              " AND (UPPER(QPM_LOTE) LIKE UPPER("+cLote+") ) " 
		EndIf
		If !Empty(cNumeroDeSerieOrig)
			cQuery +=              " AND (UPPER(QPM_NUMSER) LIKE UPPER("+cNumeroDeSerie+") ) " 
		EndIf
		cQuery +=                    " AND (QPM_OPERAC <> ' ') "
		cQuery +=                    " AND (QPM_LAUDO  <> ' ') "
		If (Empty(cTextoOrig)) .And. (Empty(cLoteOrig)) .And. (Empty(cNumeroDeSerieOrig))
			cQuery +=                " AND (QPM_DTLAUD >= '" + DtoS(dInicioProducao) + "') "
		EndIf
		cQuery +=                    " AND (D_E_L_E_T_ = ' ')  "
		cQuery +=                  " ) LAUDOS "
		cQuery +=                " ) LAUDO "

		//Relaciona por CHAVE_OPERACAO
		cQuery += " ON " + Self:oQueryManager:MontaRelationArraysCampos("LAUDO"    , {"QPL_OP", "QPL_LOTE", "QPL_NUMSER", "QPL_ROTEIR", "QPL_OPERAC"},;
																		"INSPECOES", {"QPK_OP", "QPK_LOTE", "QPK_NUMSER", "QQK_CODIGO", "QQK_OPERAC"})


		cQuery += " LEFT JOIN (SELECT DISTINCT "
		cQuery +=                   " QPL_OP, QPL_LOTE, QPL_NUMSER, QPL_ROTEIR "
		cQuery +=       " FROM " + RetSQLName("QPL")
		cQuery +=       " WHERE "
		cQuery +=         "   (QPL_FILIAL = '" + xFilial("QPL") + "') "
		If !Empty(cTextoOrig)
			cQuery +=   " AND (    (UPPER(QPL_PRODUT) LIKE UPPER("+cTexto+") ) "  
			cQuery +=         " OR (UPPER(QPL_OP)     LIKE UPPER("+cTexto+") ) ) "
		EndIf
		If !Empty(cLoteOrig)
			cQuery +=   " AND (UPPER(QPL_LOTE) LIKE UPPER("+cLote+") ) " 
		EndIf
		If !Empty(cNumeroDeSerieOrig)
			cQuery +=   " AND (UPPER(QPL_NUMSER) LIKE UPPER("+cNumeroDeSerie+") ) " 
		EndIf
		cQuery +=       "   AND (QPL_LABOR = ' ') "
		cQuery +=       "   AND (QPL_OPERAC = ' ') "
		If (Empty(cTextoOrig)) .And. (Empty(cLoteOrig)) .And. (Empty(cNumeroDeSerieOrig))
			cQuery +=   "   AND (QPL_DTLAUD >= '" + DtoS(dInicioProducao) + "')  "
		EndIf
		cQuery +=       "   AND (QPL_LAUDO <> ' ') "
		cQuery +=       "   AND (D_E_L_E_T_ = ' ') "
		cQuery +=       " ) LAUDO_GERAL"

		//Relaciona por CHAVE_INSPECAO
		cQuery += " ON " + Self:oQueryManager:MontaRelationArraysCampos("LAUDO_GERAL", {"QPL_OP", "QPL_LOTE", "QPL_NUMSER", "QPL_ROTEIR"},;
																		"INSPECOES"  , {"QPK_OP", "QPK_LOTE", "QPK_NUMSER", "QQK_CODIGO"})

		cQuery += " ) UNIAO "

		cQuery := Self:oAPIManager:ChangeQueryAllDB(cQuery)

		cAlias       := Self:oQueryManager:executeQuery(cQuery)
		oRetorno['notStarted']        := (cAlias)->NAO_INICIADA
		oRetorno['withoutReport']     := (cAlias)->SEM_LAUDO
		oRetorno['incompleteReports'] := (cAlias)->INCOMPLETO
		(cAlias)->(dbCloseArea())
	RECOVER
	END SEQUENCE

	ErrorBlock(bErrorBlock)

	Self:oAPIManager:RespondeJson(oRetorno)

Return 

/*/{Protheus.doc} RetornaQueryFiltroCardLaudoIncompleto
Retorna Query para Filtro doo CARD Laudo Incompleto
@author brunno.costa
@since  16/08/2022
@param 01 - cLogin             , caracter, login de usuário relacionado
@param 02 - cTexto             , caracter, texto de pesquisa
@param 03 - cLote              , caracter, filtro de lote
@param 04 - cNumeroDeSerie     , caracter, filtro de numero de série
@param 05 - cLaboratorio       , caracter, laboratório de filtro
@param 06 - cDescricaoOperacao , caracter, descrição da operação de pesquisa
@param 07 - dInicioProducao    , data    , filtro de data inicial da produção 
@param 08 - cRecno             , caracter, recno do registro para filtro
@return cQuery, caracter, string de filtro dos status de CARDS
/*/
METHOD RetornaQueryFiltroCardLaudoIncompleto(cLogin, cTexto, cLote, cNumeroDeSerie, cLaboratorio, cDescricaoOperacao, dInicioProducao, cRecno) CLASS InspecoesDeProcessosAPI
	
	Local cDescricaoOperacaoOrig := cDescricaoOperacao
	Local cLoteOrig              := cLote
	Local cNumeroDeSerieOrig     := cNumeroDeSerie
	Local cQuery                 := ""
	Local cTextoOrig             := cTexto

	Default cTexto       := ""
	Default cLaboratorio := ""

	cTexto             := Self:PreparaTextoParaPesquisaComLike(cTexto)
	cLote              := Self:PreparaTextoParaPesquisaComLike(cLote)
	cNumeroDeSerie     := Self:PreparaTextoParaPesquisaComLike(cNumeroDeSerie)
	cDescricaoOperacao := Self:PreparaTextoParaPesquisaComLike(cDescricaoOperacaoOrig)

	cQuery := " SELECT "
	cQuery += 	" QPL_OP, QPL_LOTE, QPL_NUMSER, QPL_ROTEIR, QPL_OPERAC "
	cQuery += " FROM (SELECT "
	cQuery +=              " COALESCE(LAUDO.QPL_OP    , LAUDO_GERAL.QPL_OP    ) QPL_OP,     "
	cQuery +=              " COALESCE(LAUDO.QPL_LOTE  , LAUDO_GERAL.QPL_LOTE  ) QPL_LOTE,   "
	cQuery +=              " COALESCE(LAUDO.QPL_NUMSER, LAUDO_GERAL.QPL_NUMSER) QPL_NUMSER, "
	cQuery +=              " COALESCE(LAUDO.QPL_ROTEIR, LAUDO_GERAL.QPL_ROTEIR) QPL_ROTEIR, "
	cQuery +=              " LAUDO.QPL_OPERAC, "
	cQuery +=              " COALESCE(LAUDO.QPL_OP, 'X') LAUDO, "
	cQuery +=              " COALESCE(LAUDO_GERAL.QPL_OP, 'X') LAUDO_GERAL "
	cQuery +=       " FROM (SELECT "
	cQuery +=                    " QPL_OP, QPL_LOTE, QPL_NUMSER, QPL_ROTEIR "
	cQuery +=       " FROM " + RetSQLName("QPL")
	cQuery +=       " WHERE (QPL_FILIAL = '" + xFilial("QPL") + "') "
	If !Empty(cTextoOrig)
		cQuery +=   " AND (    (UPPER(QPL_PRODUT) LIKE UPPER("+cTexto+") ) "  
		cQuery +=         " OR (UPPER(QPL_OP)     LIKE UPPER("+cTexto+") ) ) "
	EndIf
	If !Empty(cLoteOrig)
		cQuery +=   " AND (UPPER(QPL_LOTE) LIKE UPPER("+cLote+") ) " 
	EndIf
	If !Empty(cNumeroDeSerieOrig)
		cQuery +=   " AND (UPPER(QPL_NUMSER) LIKE UPPER("+cNumeroDeSerie+") ) " 
	EndIf
	cQuery +=       "   AND (QPL_LABOR  = ' ') "
	cQuery +=       "   AND (QPL_OPERAC = ' ') "
	If !(!Empty(cRecno) .AND. cRecno <> "0") .And. (Empty(cTextoOrig)) .And. (Empty(cLoteOrig)) .And. (Empty(cNumeroDeSerieOrig))
		cQuery +=   "   AND (QPL_DTLAUD >= '" + DtoS(dInicioProducao) + "') "	
	EndIf
	cQuery +=       "   AND (QPL_LAUDO <> ' ') "
	cQuery +=       "   AND (D_E_L_E_T_ = ' ') "
	cQuery +=       " ) LAUDO_GERAL "	

	cQuery += " FULL JOIN (SELECT "
	cQuery +=                   " QPL_OP, QPL_LOTE, QPL_NUMSER, QPL_ROTEIR, QPL_OPERAC "
	cQuery +=            " FROM (SELECT "
	cQuery +=                         " QPL_OP, QPL_LOTE, QPL_NUMSER, QPL_ROTEIR, QPL_OPERAC "
	cQuery +=                  " FROM " + RetSQLName("QPL")
	cQuery +=                  " WHERE (QPL_FILIAL = '" + xFilial("QPL") + "') "
	If !Empty(cTextoOrig)
		cQuery +=   " AND (    (UPPER(QPL_PRODUT) LIKE UPPER("+cTexto+") ) "  
		cQuery +=         " OR (UPPER(QPL_OP)     LIKE UPPER("+cTexto+") ) ) "
	EndIf
	If !Empty(cLoteOrig)
		cQuery +=   " AND (UPPER(QPL_LOTE) LIKE UPPER("+cLote+") ) " 
	EndIf
	If !Empty(cNumeroDeSerieOrig)
		cQuery +=   " AND (UPPER(QPL_NUMSER) LIKE UPPER("+cNumeroDeSerie+") ) " 
	EndIf
	If !(!Empty(cRecno) .AND. cRecno <> "0") .And. (Empty(cTextoOrig)) .And. (Empty(cLoteOrig)) .And. (Empty(cNumeroDeSerieOrig))
		cQuery +=   "   AND (QPL_DTLAUD >= '" + DtoS(dInicioProducao) + "') "	
	EndIf
	cQuery +=       " AND (QPL_LAUDO <> ' ') "
	cQuery +=       " AND (D_E_L_E_T_ = ' ') "

	cQuery +=                  " UNION "
	cQuery +=                  " SELECT "
	cQuery +=                         " QPM_OP, QPM_LOTE, QPM_NUMSER, QPM_ROTEIR, QPM_OPERAC "
	cQuery +=                  " FROM " + RetSQLName("QPM") 
	cQuery +=                  " WHERE (QPM_FILIAL = '" + xFilial("QPM") + "') "
	If !Empty(cTextoOrig)
		cQuery +=              " AND (    (UPPER(QPM_PRODUT) LIKE UPPER("+cTexto+") ) "  
		cQuery +=                    " OR (UPPER(QPM_OP)     LIKE UPPER("+cTexto+") ) ) "
	EndIf
	If !Empty(cLoteOrig)
		cQuery +=              " AND (UPPER(QPM_LOTE) LIKE UPPER("+cLote+") ) " 
	EndIf
	If !Empty(cNumeroDeSerieOrig)
		cQuery +=              " AND (UPPER(QPM_NUMSER) LIKE UPPER("+cNumeroDeSerie+") ) " 
	EndIf
	If !(!Empty(cRecno) .AND. cRecno <> "0") .And. (Empty(cTextoOrig)) .And. (Empty(cLoteOrig)) .And. (Empty(cNumeroDeSerieOrig))
		cQuery +=              " AND (QPM_DTLAUD >= '" + DtoS(dInicioProducao) + "') "
	EndIf
	cQuery +=                  " AND (QPM_LAUDO <> ' ') "
	cQuery +=                  " AND (D_E_L_E_T_ = ' ') ) LAUDOS) LAUDO "
	
	//Relaciona por CHAVE_INSPECAO
	cQuery += " ON " + Self:oQueryManager:MontaRelationArraysCampos("LAUDO"      , {"QPL_OP", "QPL_LOTE", "QPL_NUMSER", "QPL_ROTEIR"},;
			                                                        "LAUDO_GERAL", {"QPL_OP", "QPL_LOTE", "QPL_NUMSER", "QPL_ROTEIR"})
	cQuery += " ) UNIAO "

	/*
	If !(Empty(cDescricaoOperacaoOrig) .OR. !Empty(cTextoOrig) .OR. !Empty(cLoteOrig) .OR. !Empty(cNumeroDeSerieOrig) .OR. !Empty(cLaboratorio))
		cQuery += " INNER JOIN "
		
		cQuery +=   "(SELECT QPK_OP, "
		cQuery +=          " QPK_LOTE, "
		cQuery +=          " QPK_NUMSER, "
		cQuery +=          " QPK_REVI, "
		cQuery +=          " QQK_CODIGO, "
		cQuery +=          " QQK_OPERAC "

		cQuery +=   " FROM "

		cQuery +=   "(SELECT QPK_PRODUT, "
		cQuery +=          " QPK_OP, "
		cQuery +=          " QPK_LOTE, "
		cQuery +=          " QPK_NUMSER, "
		cQuery +=          " QPK_REVI "
		cQuery +=   " FROM " + RetSQLName("QPK") + " "
		cQuery +=   " WHERE (D_E_L_E_T_ = ' ') "
		cQuery +=    " AND (QPK_FILIAL = '" + xFilial("QPK") + "') "

		If !Empty(cTextoOrig)
			cQuery +=        " AND (    (UPPER(QPK_PRODUT) LIKE UPPER("+cTexto+") ) "  
			cQuery +=              " OR (UPPER(QPK_OP)     LIKE UPPER("+cTexto+") ) ) "
		EndIf

		If !Empty(cLoteOrig)
			cQuery +=        " AND (UPPER(QPK_LOTE) LIKE UPPER("+cLote+") ) " 
		EndIf

		If !Empty(cNumeroDeSerieOrig)
			cQuery +=        " AND (UPPER(QPK_NUMSER) LIKE UPPER("+cNumeroDeSerie+") ) " 
		EndIf

		If (Empty(cTextoOrig)) .And. (Empty(cLoteOrig)) .And. (Empty(cNumeroDeSerieOrig))
			cQuery +=        " AND QPK_EMISSA >= '" + DtoS(dInicioProducao) + "'"
		EndIf
		
		cQuery += " ) QPK "


		cQuery += " INNER JOIN "
		cQuery +=   "(SELECT QQK_CODIGO, "
		cQuery +=          " QQK_OPERAC, "
		cQuery +=          " QQK_PRODUT, "
		cQuery +=          " QQK_REVIPR "
		cQuery +=   " FROM " + RetSQLName("QQK") + " "
		cQuery +=   " WHERE (D_E_L_E_T_ = ' ') "
		cQuery +=    " AND (QQK_FILIAL = '" + xFilial("QQK") + "') "
		cQuery +=    " AND (UPPER(QQK_DESCRI) LIKE UPPER("+cDescricaoOperacao+") ) ) QQK "
		cQuery += " ON    QPK.QPK_REVI   = QQK.QQK_REVIPR "
		cQuery +=   " AND QPK.QPK_PRODUT = QQK.QQK_PRODUT "
		cQuery +=   " ) QPK_QQK "

		//Relaciona por CHAVE_OPERACAO
		cQuery += " ON " + Self:oQueryManager:MontaRelationArraysCampos("QPK_QQK", {"QPK_OP", "QPK_LOTE", "QPK_NUMSER", "QQK_CODIGO", "QQK_OPERAC"},;
																		"UNIAO"  , {"QPL_OP", "QPL_LOTE", "QPL_NUMSER", "QPL_ROTEIR", "QPL_OPERAC"})

	EndIf
	*/

	cQuery += " WHERE (CASE WHEN (CASE UNIAO.LAUDO WHEN 'X' THEN 0 ELSE 1 END) - (CASE UNIAO.LAUDO_GERAL WHEN 'X' THEN 0 ELSE 1 END) > 0 "
	cQuery +=             " THEN (CASE UNIAO.LAUDO WHEN 'X' THEN 0 ELSE 1 END) - (CASE UNIAO.LAUDO_GERAL WHEN 'X' THEN 0 ELSE 1 END) "
	cQuery +=        " ELSE 0 END) = 1 "//Filtra Laudos Incompletos

Return cQuery


/*/{Protheus.doc} RetornaQueryFiltroCardSemLaudos
Retorna Query para Filtro doo CARD Laudo Incompleto
@author brunno.costa
@since  16/08/2022
@param 01 - cLogin         , caracter, login de usuário relacionado
@param 02 - cTexto         , caracter, texto de pesquisa
@param 03 - cLote          , caracter, filtro de lote
@param 04 - cNumeroDeSerie , caracter, filtro de numero de série
@param 05 - cLaboratorio   , caracter, laboratório de filtro
@param 06 - dInicioProducao, data    , filtro de data inicial da produção
@param 07 - cRecno		   , caracter, recno do registro para filtro
@return cQuery, caracter, string de filtro dos status de CARDS
/*/
METHOD RetornaQueryFiltroCardSemLaudos(cLogin, cTexto, cLote, cNumeroDeSerie, cLaboratorio, dInicioProducao, cRecno) CLASS InspecoesDeProcessosAPI
	
	Local cLoteOrig              := cLote
	Local cNumeroDeSerieOrig     := cNumeroDeSerie
	Local cQuery                 := ""
	Local cTextoOrig             := cTexto


	Default cTexto       := ""
	Default cLaboratorio := ""

	cTexto             := Self:PreparaTextoParaPesquisaComLike(cTexto)
	cLote              := Self:PreparaTextoParaPesquisaComLike(cLote)
	cNumeroDeSerie     := Self:PreparaTextoParaPesquisaComLike(cNumeroDeSerie)

	cQuery := " SELECT  "
	cQuery += 	" QPL_OP, QPL_LOTE, QPL_NUMSER, QPL_ROTEIR, QPL_OPERAC "
	cQuery += " FROM (SELECT "
	cQuery +=              " COALESCE(LAUDO.QPL_OP    , LAUDO_GERAL.QPL_OP    ) QPL_OP,     "
	cQuery +=              " COALESCE(LAUDO.QPL_LOTE  , LAUDO_GERAL.QPL_LOTE  ) QPL_LOTE,   "
	cQuery +=              " COALESCE(LAUDO.QPL_NUMSER, LAUDO_GERAL.QPL_NUMSER) QPL_NUMSER, "
	cQuery +=              " COALESCE(LAUDO.QPL_ROTEIR, LAUDO_GERAL.QPL_ROTEIR) QPL_ROTEIR, "
	cQuery +=              " LAUDO.QPL_OPERAC, "
	cQuery +=              " COALESCE(LAUDO.QPL_OP, 'X') LAUDO, "
	cQuery +=              " COALESCE(LAUDO_GERAL.QPL_OP, 'X') LAUDO_GERAL "
	cQuery +=       " FROM (SELECT "
	cQuery +=                    " QPL_OP, QPL_LOTE, QPL_NUMSER, QPL_ROTEIR "
	cQuery +=       " FROM " + RetSQLName("QPL")
	cQuery +=       " WHERE (QPL_FILIAL = '" + xFilial("QPL") + "') "
	cQuery +=         " AND (QPL_LAUDO <> ' ') "
	If !Empty(cTextoOrig)
		cQuery +=     " AND (    (UPPER(QPL_PRODUT) LIKE UPPER("+cTexto+") ) "  
		cQuery +=           " OR (UPPER(QPL_OP)     LIKE UPPER("+cTexto+") ) ) "
	EndIf
	If !Empty(cLoteOrig)
		cQuery +=     " AND (UPPER(QPL_LOTE) LIKE UPPER("+cLote+") ) " 
	EndIf
	If !Empty(cNumeroDeSerieOrig)
		cQuery +=     " AND (UPPER(QPL_NUMSER) LIKE UPPER("+cNumeroDeSerie+") ) " 
	EndIf
	cQuery +=         " AND (QPL_LABOR  = ' ') "
	cQuery +=         " AND (QPL_OPERAC = ' ') "
	If !(!Empty(cRecno) .AND. cRecno <> "0") .And. (Empty(cTextoOrig)) .And. (Empty(cLoteOrig)) .And. (Empty(cNumeroDeSerieOrig))
		cQuery +=     " AND (QPL_DTLAUD >= '" + DtoS(dInicioProducao) + "')  "
	EndIf
	cQuery +=         " AND (D_E_L_E_T_ = ' ') "	
	cQuery +=       " ) LAUDO_GERAL "

	cQuery += " FULL JOIN (SELECT "
	cQuery +=                   " QPL_OP, QPL_LOTE, QPL_NUMSER, QPL_ROTEIR, QPL_OPERAC "
	cQuery +=            " FROM (SELECT "
	cQuery +=                    " QPL_OP, QPL_LOTE, QPL_NUMSER, QPL_ROTEIR, QPL_OPERAC "
	cQuery +=                  " FROM " + RetSQLName("QPL")
	cQuery +=                  " WHERE (QPL_FILIAL = '" + xFilial("QPL") + "') "
	If !Empty(cTextoOrig)
		cQuery +=                " AND (    (UPPER(QPL_PRODUT) LIKE UPPER("+cTexto+") ) "  
		cQuery +=                      " OR (UPPER(QPL_OP)     LIKE UPPER("+cTexto+") ) ) "
	EndIf
	If !Empty(cLoteOrig)
		cQuery +=                " AND (UPPER(QPL_LOTE) LIKE UPPER("+cLote+") ) " 
	EndIf
	If !Empty(cNumeroDeSerieOrig)
		cQuery +=                " AND (UPPER(QPL_NUMSER) LIKE UPPER("+cNumeroDeSerie+") ) " 
	EndIf
	If !(!Empty(cRecno) .AND. cRecno <> "0") .And. (Empty(cTextoOrig)) .And. (Empty(cLoteOrig)) .And. (Empty(cNumeroDeSerieOrig))
		cQuery +=                " AND (QPL_DTLAUD >= '" + DtoS(dInicioProducao) + "')  "
	EndIf
	cQuery +=                    " AND (QPL_OPERAC <> ' ') "
	cQuery +=                    " AND (QPL_LAUDO  <> ' ') "
	cQuery +=                    " AND (D_E_L_E_T_ = ' ') "

	cQuery +=                  " UNION "
	cQuery +=                  " SELECT "
	cQuery +=                         " QPM_OP, QPM_LOTE, QPM_NUMSER, QPM_ROTEIR, QPM_OPERAC "
	cQuery +=                  " FROM " + RetSQLName("QPM")
	cQuery +=                  " WHERE (QPM_FILIAL = '" + xFilial("QPM") + "') "
	If !Empty(cTextoOrig)
		cQuery +=              " AND (    (UPPER(QPM_PRODUT) LIKE UPPER("+cTexto+") ) "  
		cQuery +=                    " OR (UPPER(QPM_OP)     LIKE UPPER("+cTexto+") ) ) "
	EndIf
	If !Empty(cLoteOrig)
		cQuery +=              " AND (UPPER(QPM_LOTE) LIKE UPPER("+cLote+") ) " 
	EndIf
	If !Empty(cNumeroDeSerieOrig)
		cQuery +=              " AND (UPPER(QPM_NUMSER) LIKE UPPER("+cNumeroDeSerie+") ) " 
	EndIf
	If !(!Empty(cRecno) .AND. cRecno <> "0") .And. (Empty(cTextoOrig)) .And. (Empty(cLoteOrig)) .And. (Empty(cNumeroDeSerieOrig))
		cQuery +=              " AND (QPM_DTLAUD >= '" + DtoS(dInicioProducao) + "') "
	EndIf
	cQuery +=                  " AND (QPM_OPERAC <> ' ') "
	cQuery +=                  " AND (QPM_LAUDO  <> ' ') "
	cQuery +=                  " AND (D_E_L_E_T_ = ' ') "
	cQuery +=                " ) LAUDOS "
	cQuery +=              " ) LAUDO "

	//Relaciona por CHAVE_INSPECAO
	cQuery += " ON " + Self:oQueryManager:MontaRelationArraysCampos("LAUDO"      , {"QPL_OP", "QPL_LOTE", "QPL_NUMSER", "QPL_ROTEIR"},;
			                                                        "LAUDO_GERAL", {"QPL_OP", "QPL_LOTE", "QPL_NUMSER", "QPL_ROTEIR"})
	cQuery += " ) UNIAO "

Return cQuery

/*/{Protheus.doc} PreparaTextoParaPesquisaComLike
Prepara o texto para pesquisa com Like
@author brunno.costa
@since  16/08/2022
@param 01 - cTextoOrig
@return cTexto, caracter, string para pesquisa
/*/
METHOD PreparaTextoParaPesquisaComLike(cTextoOrig) CLASS InspecoesDeProcessosAPI
	
	Local cLetra    := ""
	Local cTexto    := ""
	Local cTextoAux := ""
	Local lInicio   := .T.
	Local nLetra    := 0
	Local nTotal    := 0

	Default cTextoOrig := ""

	cTextoAux := FwQtToChr(cTextoOrig)
	nTotal    := Len(cTextoAux)

	For nLetra := 1 to nTotal
		cLetra := Substring(cTextoAux, nLetra, 1)
		If cLetra == "'"
			If lInicio
				cTexto  += "'%"
				lInicio := .F.
			Else
				cTexto  += "%'"
				lInicio := .T.
			EndIf
		Else
			cTexto += cLetra
		EndIf
	Next

Return cTexto


