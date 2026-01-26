#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "inspecoesdeentradasapi.ch"

#DEFINE nPosCPS_Considera                  1
#DEFINE nPosCPS_Titulo_Interface           2
#DEFINE nPosCPS_Titulo_API                 3
#DEFINE nPosCPS_Protheus                   4
#DEFINE nPosCPS_Tipo                       5
#DEFINE nPosCPS_Tamanho                    6
#DEFINE nPosCPS_Decimal                    7
#DEFINE nPosCPS_Alias                      8
#DEFINE nPosCPS_Protheus_Externo           9

/*/{Protheus.doc} incominginspections
API de Inspeção de Entradas - Qualidade
@author brunno.costa
@since  25/10/2024
/*/
WSRESTFUL incominginspections DESCRIPTION STR0001 FORMAT APPLICATION_JSON //"Inspeções de Entradas"

    WSDATA Fields               as STRING OPTIONAL
	WSDATA IncomingStartDate    as STRING OPTIONAL
	WSDATA IncompleteReport     as BOOLEAN OPTIONAL
	WSDATA Laboratory           as STRING OPTIONAL
    WSDATA Login                as STRING OPTIONAL
	WSDATA Lot                  as STRING OPTIONAL
	WSDATA NotStarted           as BOOLEAN OPTIONAL
    WSDATA Order                as STRING OPTIONAL
	WSDATA OrderType            as STRING OPTIONAL
    WSDATA Page                 as INTEGER OPTIONAL
    WSDATA PageSize             as INTEGER OPTIONAL
	WSDATA ProductID            as STRING OPTIONAL
	WSDATA Recno                as STRING OPTIONAL
	WSDATA SequencialNumber     as STRING OPTIONAL
	WSDATA SpecificationVersion as STRING OPTIONAL
	WSDATA Supplier             as STRING OPTIONAL
    WSDATA Text                 as STRING OPTIONAL
	WSDATA WithoutReport        as BOOLEAN OPTIONAL

    WSMETHOD GET search;
    DESCRIPTION STR0002; //"Pesquisa Lista Inspeções de Entradas"
    WSSYNTAX "api/qie/v1/search/{Login}/{Laboratory}/{Text}/{Lot}/{Supplier}/{SequencialNumber}/{IncomingStartDate}/{Order}/{OrderType}/{Page}/{PageSize}" ;
    PATH "/api/qie/v1/search" ;
    TTALK "v1"

	WSMETHOD GET inspection;
    DESCRIPTION STR0003; //"Retorna uma Inspeção de Entradas"
    WSSYNTAX "api/qie/v1/inspection/{Login}/{Laboratory}/{Recno}" ;
    PATH "/api/qie/v1/inspection" ;
    TTALK "v1"

	WSMETHOD GET userExist;
	DESCRIPTION STR0004; //"Retorna se o usuário possui cadastro ativo no módulo Inspeção de Entradas"
	WSSYNTAX "api/qie/v1/userExist/{Login}" ;
	PATH "/api/qie/v1/userExist" ;
	TTALK "v1"

	WSMETHOD GET version;
	DESCRIPTION STR0005; //"Retorna a versão do back-end de Inspeção de Entradas"
	WSSYNTAX "api/qie/v1/version/{Login}" ;
	PATH "/api/qie/v1/version" ;
	TTALK "v1"

	WSMETHOD GET cards;
    DESCRIPTION STR0006; //"Retorna Resumo dos Cards de Inspeção"
    WSSYNTAX "api/qie/v1/cards/{Login}/{Laboratory}/{Text}" ;
    PATH "/api/qie/v1/cards" ;
    TTALK "v1"

	WSMETHOD POST completeStockRelease;
	DESCRIPTION STR0007; //"Movimenta as pendências de estoque CQ automaticamente"
	WSSYNTAX "api/qie/v1/completestockrelease" ;
	PATH    "/api/qie/v1/completestockrelease" ;
	TTALK "v1"

	WSMETHOD GET hasqieintapi;
    DESCRIPTION STR0010; //"Indica se há compilação do ponto de entrada QIEINTAPI"
    WSSYNTAX "api/qie/v1/hasqieintapi" ;
    PATH "/api/qie/v1/hasqieintapi" ;
    TTALK "v1"

	WSMETHOD GET picturecode;
    DESCRIPTION STR0011; //"Retorna o código da foto relacionada, quando existir"
    WSSYNTAX "api/qie/v1/picturecode/{ProductID}/{SpecificationVersion}" ;
    PATH "/api/qie/v1/picturecode" ;
    TTALK "v1"

ENDWSRESTFUL

WSMETHOD GET picturecode PATHPARAM ProductID, SpecificationVersion QUERYPARAM Fields WSSERVICE incominginspections
    
	Local cPicture    := ""
	Local oAPIManager := QualityAPIManager():New({}, Self)

	Default Self:ProductID             := ""
	Default Self:SpecificationVersion  := ""

	Self:ProductID            := PadR(Self:ProductID           , GetSx3Cache("QE6_PRODUT", 'X3_TAMANHO') )
	Self:SpecificationVersion := PadR(Self:SpecificationVersion, GetSx3Cache("QE6_REVI"  , 'X3_TAMANHO') )

	dbSelectArea("QE6")
	QE6->(DBSetOrder(3))
	If !Empty(Self:ProductID) .And. !Empty(Self:SpecificationVersion) .And. QE6->(DbSeek(xFilial("QE6") + Self:ProductID + Self:SpecificationVersion))
		cPicture := QE6->QE6_BITMAP
	EndIf
	QE6->(dbCloseArea())

	oAPIManager := QualityAPIManager():New({}, Self)
	oAPIManager:RespondeValor("pictureCode", cPicture)

Return 

WSMETHOD GET search PATHPARAM Login, Laboratory, Text, Lot, Supplier, SequencialNumber, IncomingStartDate, Order, OrderType, Page, PageSize, NotStarted, WithoutReport, IncompleteReport QUERYPARAM Fields WSSERVICE incominginspections
    
	Local oAPIClass                   := InspecoesDeEntradasAPI():New(Self)

	Default Self:Fields            := ""
	Default Self:IncomingStartDate := ""
    Default Self:IncompleteReport  := .F.
	Default Self:Laboratory        := ""
	Default Self:Login             := ""
	Default Self:Lot               := ""
	Default Self:NotStarted        := .F.
	Default Self:Order             := ""
	Default Self:OrderType         := ""
	Default Self:Page              := 1
	Default Self:PageSize          := 5
	Default Self:SequencialNumber  := ""
	Default Self:Supplier          := ""
	Default Self:Text              := ""
    Default Self:WithoutReport     := .F.

	oAPIClass:cCampos            := Self:Fields
	oAPIClass:cFornecedor        := Self:Supplier
	oAPIClass:cLaboratorio       := Self:Laboratory
	oAPIClass:cLogin             := Self:Login
	oAPIClass:cLote              := Self:Lot
	oAPIClass:cNumSEQ            := Self:SequencialNumber
	oAPIClass:cOrdem             := Self:Order
	oAPIClass:cRecno             := "0"
	oAPIClass:cTexto             := Self:Text
	oAPIClass:cTipoOrdem         := Self:OrderType
	oAPIClass:dEntradaInicial    := StoD(Self:IncomingStartDate)
	oAPIClass:lLaudosIncompletos := Self:IncompleteReport
	oAPIClass:lNaoIniciadas      := Self:NotStarted
	oAPIClass:lSemLaudos         := Self:WithoutReport
	oAPIClass:nPagina            := Self:Page
	oAPIClass:nTamPag            := Self:PageSize

Return oAPIClass:pesquisaLista()

WSMETHOD GET inspection PATHPARAM Login, Laboratory, Recno QUERYPARAM Fields WSSERVICE incominginspections
    
	Local oAPIClass          := InspecoesDeEntradasAPI():New(Self)

	Default Self:Fields := ""
	Default Self:Login  := ""
	Default Self:Recno  := "0"

	oAPIClass:cLaboratorio := Self:Laboratory
	oAPIClass:cLogin       := Self:Login
	oAPIClass:cRecno       := Self:Recno

Return oAPIClass:pesquisaLista()

WSMETHOD GET userExist PATHPARAM Login WSSERVICE incominginspections

    Local oAPIClass  := InspecoesDeEntradasAPI():New(Self)
	Default Self:Login    := ""

Return oAPIClass:usuarioExistente(Self:Login)

WSMETHOD GET version PATHPARAM Login WSSERVICE incominginspections

    Local lRetorno             := .T.
	Local oResponse            := JsonObject():New()
	
	Self:SetContentType("application/json")
	oResponse['version'      ] := "4.1.7"
	oResponse['type'         ] := "warning"
	oResponse['hasNext'      ] := .F.
	oResponse['code'         ] := 200

	//Processou com sucesso.
	HTTPSetStatus(200)

	Self:SetResponse(EncodeUtf8(oResponse:toJson()))

Return lRetorno

WSMETHOD GET cards PATHPARAM Login, Text, Lot, Supplier, SequencialNumber, Laboratory, IncomingStartDate QUERYPARAM Fields WSSERVICE incominginspections

    Local oAPIClass                := InspecoesDeEntradasAPI():New(Self)

	Default Self:IncomingStartDate := ""
	Default Self:Laboratory        := ""
	Default Self:Login             := ""
	Default Self:Lot               := ""
	Default Self:SequencialNumber  := ""
	Default Self:Supplier          := ""
	Default Self:Text              := ""

	oAPIClass:cFornecedor     := Self:Supplier
	oAPIClass:cLaboratorio    := Self:Laboratory
	oAPIClass:cLogin          := Self:Login
	oAPIClass:cLote           := Self:Lot
	oAPIClass:cNumSEQ         := Self:SequencialNumber
	oAPIClass:cTexto          := Self:Text
	oAPIClass:dEntradaInicial := StoD(Self:IncomingStartDate)

Return oAPIClass:retornaContagemCards()

WSMETHOD GET hasqieintapi PATHPARAM Login WSSERVICE incominginspections
    
	Local oAPIManager := QualityAPIManager():New({}, Self)
	
	oAPIManager:RespondeValor("hasqieintapi", oAPIManager:existePEIntegracaoAppMinhaProducaoCompilado("QIE"))

Return

WSMETHOD POST completeStockRelease QUERYPARAM Fields WSSERVICE incominginspections
    
    Local cError    := ""
    Local cJsonData := DecodeUTF8(Self:GetContent())
    Local lSucesso  := .F.
	Local nRecnoQEK := Nil
    Local oAPIClass := QIELaudosEnsaios():New(Self)
    Local oData     := JsonObject()      :New()

    oData:fromJson(cJsonData)
	BEGIN SEQUENCE
		nRecnoQEK := oData['recno']
    	lSucesso  := oAPIClass:MovimentaEstoqueCQ(nRecnoQEK)
    	cError 	  := oAPIClass:oAPIManager:cErrorMessage
	ENDSEQUENCE

    oAPIClass:oAPIManager:RespondeValor("success", lSucesso, cError)

Return 

/*/{Protheus.doc} InspecoesDeEntradasAPI
Regras de Negocio - API Inspeção de Entradas
@author brunno.costa
@since  25/10/2024
/*/
CLASS InspecoesDeEntradasAPI FROM LongNameClass
	
	DATA oAPIManager        as OBJECT
    DATA oWSRestFul         as OBJECT
	DATA oQueryManager      as OBJECT

	DATA cCampos            as Character //campos que deverão estar contidos na mensagem
	DATA cLaboratorio       as Character //laboratório para filtro
	DATA cLogin             as Character //login do usuário para validação das permissões de acesso
	DATA cLote              as Character //filtro de lote
	DATA cNumSEQ            as Character //filtro de QEK_NUMSEQ
	DATA cFornecedor        as Character //filtro de fornecedor
	DATA cOrdem             as Character //ordenação para retornar a listagem dos dados
	DATA cRecno             as Character //recno do registro para filtro
	DATA cTexto             as Character //texto para pesquisa nos campos de OP e Produto
	DATA cTipoOrdem         as Character //tipo de ordenação para retornar a listagem dos dados (Ascencente ou Decrescente)
	DATA dEntradaInicial    as Date      //filtro de data inicial da produção
	DATA lLaudosIncompletos as Logical   //indica se realiza filtro de inspeções com laudos incompletos
	DATA lNaoIniciadas      as Logical   //indica se realiza filtro de inspeções não iniciadas
	DATA lSemLaudos         as Logical   //indica se realiza filtro de inspeções sem laudos
	DATA nPagina            as Numeric   //página atual dos dados para consulta
	DATA nTamPag            as Numeric   //tamanho de página padrão com a quantidade de registros para retornar

    METHOD new(oWSRestFul) CONSTRUCTOR
    METHOD criaAliasPesquisa(lPorLab)
	METHOD pesquisaLista()
	METHOD retornaContagemCards()
	METHOD usuarioExistente(cLogin)
     
    //Métodos Internos
	METHOD filtraPorRegistrosPendentes()
    METHOD mapeiaCampos(cCampos)
	METHOD naoImplantado()
	METHOD preparaTextoParaPesquisaComLike(cTextoOrig)
	METHOD retornaQueryFiltroCardLaudoIncompleto()
	METHOD retornaQueryFiltroCardSemLaudos()

ENDCLASS

METHOD new(oWSRestFul) CLASS InspecoesDeEntradasAPI

    Self:oWSRestFul    := oWSRestFul
	Self:oQueryManager := QLTQueryManager():New()

	Self:cCampos            := "*"
	Self:cLaboratorio       := ""
	Self:cLogin             := ""
	Self:cLote              := ""
	Self:cNumSEQ            := ""
	Self:cFornecedor        := ""
	Self:cOrdem             := ""
	Self:cRecno             := ""
	Self:cTexto             := ""
	Self:cTipoOrdem         := ""
	Self:dEntradaInicial    := dDataBase - 180
	Self:lLaudosIncompletos := .F.
	Self:lNaoIniciadas      := .F.
	Self:lSemLaudos         := .F.
	Self:nPagina            := 1
	Self:nTamPag            := 999999

Return Self

/*/{Protheus.doc} mapeiaCampos
Mapeia os Campos
@author brunno.costa
@since  25/10/2024
@param 01 - cCampos, String, string com os campos [nPosCPS_Titulo_API] para consideração separados por vírgula
@return aMapaCampos, Array , {{lConsidera, Titulo Interface, Título API, Campo Protheus, Tipo, Tamanho, Decimal}, ...}
                             {{nPosCPS_Considera, ..., nPosCPS_Decimal}, ...}
/*/
METHOD mapeiaCampos(cCampos) CLASS InspecoesDeEntradasAPI

    Local aMapaCampos := {}
	Local oQltAPIManager := QualityAPIManager():New(nil, Self:oWSRestFul)

	//cOrdemDB := "QEK_DTENTR DESC, QEK_PRODUT DESC, QEK_REVI DESC, QEK_NTFISC DESC, QEK_SERINF DESC, QEK_ITEMNF DESC, QEK_LOTE DESC, QEK_NUMSEQ DESC"

    aAdd(aMapaCampos, {.F., "CodigoProduto"           , "productID"              , "QEK_PRODUT"      , "C" , oQltAPIManager:GetSx3Cache("QEK_PRODUT" ,"X3_TAMANHO"), 0})
    aAdd(aMapaCampos, {.F., "VersaEspecificacao"      , "specificationVersion"   , "QEK_REVI"        , "C" , oQltAPIManager:GetSx3Cache("QEK_REVI"   ,"X3_TAMANHO"), 0})
	aAdd(aMapaCampos, {.F., "ChaveNotaFiscal"         , "invoiceID"              , "QEK_NTFISC"      , "C" , oQltAPIManager:GetSx3Cache("QEK_NTFISC" ,"X3_TAMANHO"), 0})
	aAdd(aMapaCampos, {.F., "SerieNotaFiscal"         , "invoiceSerie"           , "QEK_SERINF"      , "C" , oQltAPIManager:GetSx3Cache("QEK_SERINF" ,"X3_TAMANHO"), 0})
	aAdd(aMapaCampos, {.F., "ItemNF"                  , "invoiceItem"            , "QEK_ITEMNF"      , "C" , oQltAPIManager:GetSx3Cache("QEK_ITEMNF" ,"X3_TAMANHO"), 0})
	aAdd(aMapaCampos, {.F., "TipoNF"                  , "invoiceType"            , "QEK_TIPONF"      , "C" , oQltAPIManager:GetSx3Cache("QEK_TIPONF" ,"X3_TAMANHO"), 0})
    aAdd(aMapaCampos, {.F., "Lote"                    , "lot"                    , "QEK_LOTE"        , "C" , oQltAPIManager:GetSx3Cache("QEK_LOTE"   ,"X3_TAMANHO"), 0})
	aAdd(aMapaCampos, {.F., "Sequencia"               , "sequence"               , "QEK_NUMSEQ"      , "C" , oQltAPIManager:GetSx3Cache("QEK_NUMSEQ" ,"X3_TAMANHO"), 0})
	aAdd(aMapaCampos, {.F., "Produto"                 , "product"                , "B1_DESC"         , "C" , oQltAPIManager:GetSx3Cache("B1_DESC"    ,"X3_TAMANHO"), 0})
    aAdd(aMapaCampos, {.F., "Quantidade"              , "lotSize"                , "QEK_TAMLOT"      , "C" , oQltAPIManager:GetSx3Cache("QEK_TAMLOT" ,"X3_TAMANHO"), 0})
	aAdd(aMapaCampos, {.F., "CodigoUM"                , "lotUnitID"              , "QEK_UNIMED"      , "C" , oQltAPIManager:GetSx3Cache("QEK_UNIMED" ,"X3_TAMANHO"), 0})
	aAdd(aMapaCampos, {.F., "UnidadeMedida"           , "lotUnit"                , "AH_DESCPO"       , "C" , oQltAPIManager:GetSx3Cache("AH_DESCPO"  ,"X3_TAMANHO"), 0})
    aAdd(aMapaCampos, {.F., "DataEmissao"             , "date"                   , "QEK_DTNFIS"      , "D" , oQltAPIManager:GetSx3Cache("QEK_DTNFISO","X3_TAMANHO"), 0})
    aAdd(aMapaCampos, {.F., "FornecedorLoja"          , "supplier"               , "FornecedorLoja"  , "C" , oQltAPIManager:GetSx3Cache("A2_NOME"    ,"X3_TAMANHO") + oQltAPIManager:GetSx3Cache("QEK_FORNEC","X3_TAMANHO") + oQltAPIManager:GetSx3Cache("QEK_LOJFOR","X3_TAMANHO") + 4, 0})
    aAdd(aMapaCampos, {.F., "DataEntrada"             , "incomingDate"           , "QEK_DTENTR"      , "D" , oQltAPIManager:GetSx3Cache("QEK_DTENTR" ,"X3_TAMANHO"), 0})
    aAdd(aMapaCampos, {.F., "UsuarioPermitido"        , "allowedUser"            , "Permitido"       , "L" ,                                       3, 0})
	aAdd(aMapaCampos, {.F., "Laudo"                   , "report"                 , "QEL_LAUDO"       , "C" ,                                       1, 0})
	aAdd(aMapaCampos, {.F., "Status"                  , "status"                 , "Status"          , "C" ,                                       1, 0})
	aAdd(aMapaCampos, {.F., "LaudoIncompleto"         , "incompleteReport"       , "incompletereport", "C" ,                                       1, 0})
	aAdd(aMapaCampos, {.T., "RecnoInspecao"           , "recno"                  , "R_E_C_N_O_"      , "NN",                                       0, 0}) //NN para não formatar como número pois não temos certeza do tamanho configurado na tabela do cliente
 
	Self:oAPIManager := QualityAPIManager():New(aMapaCampos, Self:oWSRestFul)
	Self:oAPIManager:marcaCamposConsiderados(cCampos, aMapaCampos, nPosCPS_Titulo_API)

Return aMapaCampos

/*/{Protheus.doc} filtraPorRegistrosPendentes
Indica que a pesquisa deve retornar apenas os registros pendentes, ou seja, não está filtrando por uma NF, um Produto, um Lote.
@author brunno.costa
@since  25/10/2024
@return cAlias, caracter, alias com os dados da pesquisa
/*/
METHOD filtraPorRegistrosPendentes() CLASS InspecoesDeEntradasAPI
Return (Empty(Self:cRecno) .OR. Self:cRecno == "0") .AND. Empty(Self:cTexto) .AND. Empty(Self:cLote) .AND. Empty(Self:cNumSEQ)
/*/{Protheus.doc} criaAliasPesquisa
Cria Alias para Pesquisa Lista de Inspeções de Processo com Base em Texto nos Campos Produto, OP
@author brunno.costa
@since  25/10/2024
@param lPorLab, lógico  , indica que deve quebrar os registros por laudo de laboratório
@return cAlias, caracter, alias com os dados da pesquisa
/*/
METHOD criaAliasPesquisa(lPorLab) CLASS InspecoesDeEntradasAPI
     
	Local bErrorBlock := ErrorBlock({|e| Self:oAPIManager:ErrorBlock(e, e:Description), Break(e)})
    Local cAlias      := Nil
	Local cFornecedor := Self:preparaTextoParaPesquisaComLike(Self:cFornecedor)
	Local cLote       := Self:preparaTextoParaPesquisaComLike(Self:cLote)
	Local cNumSEQ     := Self:preparaTextoParaPesquisaComLike(Self:cNumSEQ)
	Local cOrdemDB    := Nil
    Local cQuery      := Nil
	Local cTexto      := Self:preparaTextoParaPesquisaComLike(Self:cTexto)
    Local nEnd        := 0
	Local nStart      := 0

	Default lPorLab := .F.

	nStart := ((Self:nPagina - 1) * Self:nTamPag) + 1
	nEnd   := (Self:nPagina * Self:nTamPag) + 1

	BEGIN SEQUENCE

		Self:mapeiaCampos(Self:cCampos)

		Self:oAPIManager:AvaliaPELaboratoriosRelacionadosAoUsuario("QIE")
		
		cQuery := " SELECT * "
		cQuery += " FROM ( "

		cQuery += " SELECT  ROW_NUMBER() OVER( "
    	
		cOrdemDB := Self:oAPIManager:RetornaOrdemDB(Self:cOrdem, Self:cTipoOrdem)
		cOrdemDB := IIf(Empty(cOrdemDB), "QEK_DTENTR DESC, QEK_PRODUT DESC, QEK_REVI DESC, QEK_NTFISC DESC, QEK_SERINF DESC, QEK_ITEMNF DESC, QEK_LOTE DESC, QEK_NUMSEQ DESC", cOrdemDB)

		cQuery += " ORDER BY " + cOrdemDB + " ) LINHA, "

		cQuery += " QEK_PRODUT, "
		cQuery += " QEK_REVI, "
		cQuery += " QEK_NTFISC, "
		cQuery += " QEK_SERINF, "
		cQuery += " QEK_ITEMNF, "
		cQuery += " QEK_TIPONF, "
		cQuery += " QEK_LOTE, "
		cQuery += " QEK_NUMSEQ, "
		cQuery += " QEK_DTENTR, "
		cQuery += " QEK_TAMLOT, "
		cQuery += " QEK_UNIMED, "
		cQuery += " QEK_DTNFIS, "
		cQuery += " FornecedorLoja, "
		cQuery += " R_E_C_N_O_, "
		cQuery += " Permitido, "
		cQuery += " QEL_LAUDO, "
		cQuery += " Status, "
		cQuery += " incompletereport, "
		cQuery += " B1_DESC, "
		cQuery += " AH_DESCPO "

		cQuery += " FROM  "
		cQuery += " ( "

		cQuery += " SELECT DISTINCT "
		cQuery +=        " QEK.QEK_PRODUT, "
		cQuery +=        " QEK.QEK_REVI, "
		cQuery +=        " QEK.QEK_NTFISC, "
		cQuery +=        " QEK.QEK_SERINF, "
		cQuery +=        " QEK.QEK_ITEMNF, "
		cQuery +=        " QEK.QEK_TIPONF, "
		cQuery +=        " QEK.QEK_LOTE, "
		cQuery +=        " QEK.QEK_NUMSEQ, "
		cQuery +=        " QEK.QEK_DTENTR, "
		cQuery +=        " QEK.QEK_TAMLOT, "
		cQuery +=        " QEK.QEK_UNIMED, "
		cQuery +=        " QEK.QEK_DTNFIS, "
		cQuery +=        " CONCAT( CONCAT( CONCAT( CONCAT( A2_COD , '-' ) , A2_LOJA ) , ' ' ) , A2_NOME ) FornecedorLoja, "
		cQuery +=        " QEK.R_E_C_N_O_, "
		cQuery +=        " QAA.Permitido, "
		cQuery +=        " QUERY_STATUS.QEL_LAUDO, "
		
		cQuery +=        " (CASE QEK.QEK_SITENT "
		cQuery +=             " WHEN '2' THEN 'A' "
		cQuery +=             " WHEN '3' THEN 'R' "
		cQuery +=             " WHEN '4' THEN 'U' "
		cQuery +=             " WHEN '5' THEN 'C' "
		cQuery +=             " WHEN '6' THEN 'E' "
		cQuery +=             " ELSE "

		cQuery +=             " (CASE COALESCE (QER_RESULT, "
		cQuery +=                                       "'N') "
		cQuery +=                           " WHEN 'N' THEN 'N' "
		cQuery +=                           " ELSE 'I' "
		cQuery +=                       " END)

		cQuery +=        " END) Status, "


		If (Self:lNaoIniciadas .OR. Self:lSemLaudos)
			cQuery +=        " 'false' incompletereport, "

		Else
			cQuery +=        " (CASE WHEN INCOMPLETOS.QEL_NISERI IS NULL THEN 'false' ELSE 'true' END) incompletereport, "
			
		EndIf

		cQuery +=        " SB1.B1_DESC, "
		cQuery +=        " SAH.AH_DESCPO "
		cQuery += " FROM "
		cQuery +=   "(SELECT AH_UNIMED, "
		cQuery +=          " AH_DESCPO "
		cQuery +=   " FROM " + RetSQLName("SAH") + " "
		cQuery +=   " WHERE (AH_FILIAL = '" + xFilial("SAH") + "') "
		cQuery +=     " AND (D_E_L_E_T_ = ' ') ) SAH "
		cQuery += " RIGHT JOIN "
		cQuery +=   "(SELECT QEL.QEL_FORNEC, QEL.QEL_LOJFOR, QEL.QEL_PRODUT, QEL.QEL_NISERI, QEL.QEL_TIPONF, QEL.QEL_LOTE, QEL.QEL_NUMSEQ, QEL.QEL_DTENTR, QEL_LAUDO "
		cQuery +=   " FROM " + RetSQLName("QEL") + " QEL "
		cQuery +=   " INNER JOIN "
		cQuery +=     "(SELECT QED_CODFAT, "
		cQuery +=            " QED_CATEG "
		cQuery +=     " FROM " + RetSQLName("QED") + " "
		cQuery +=     " WHERE (QED_FILIAL = '" + xFilial("QED") + "') "
		cQuery +=       " AND (D_E_L_E_T_ = ' ')) QED "
		cQuery +=   " ON QEL.QEL_LAUDO = QED.QED_CODFAT "
		cQuery +=   " WHERE (QEL.QEL_FILIAL = '" + xFilial("QEL") + "') "

		If lPorLab
			cQuery +=     " AND (QEL.QEL_LABOR <> ' ') "
		Else
			cQuery +=     " AND (QEL.QEL_LABOR = ' ') "
		EndIf
		
		If !Empty(Self:cTexto)
			cQuery +=        " AND (    (UPPER(QEL_PRODUT) LIKE UPPER("+cTexto+") ) "   
			cQuery +=              " OR (UPPER(QEL_NISERI) LIKE UPPER("+cTexto+") ) ) " 
		EndIf
		
		If !Empty(Self:cLote)
			cQuery +=        " AND (UPPER(QEL_LOTE) LIKE UPPER("+cLote+") ) " 
		EndIf

		If !Empty(Self:cNumSEQ)
			cQuery +=        " AND (UPPER(QEL_NUMSEQ) LIKE UPPER("+cNumSEQ+") ) " 
		EndIf

		If !Empty(Self:cFornecedor)
			cQuery +=        " AND (UPPER(QEL_FORNEC) LIKE UPPER("+cFornecedor+") ) " 
		EndIf

		cQuery +=            " AND (QEL.D_E_L_E_T_ = ' ') "
		cQuery += " ) QUERY_STATUS "

		cQuery += " RIGHT JOIN "
		cQuery +=   "(SELECT "
		cQuery +=          " QEK_FORNEC, "
		cQuery +=          " QEK_LOJFOR, "
		cQuery +=          " QEK_PRODUT, "
		cQuery +=          " QEK_REVI, "
		cQuery +=          " QEK_NTFISC, "
		cQuery +=          " QEK_SERINF, "
		cQuery +=          " QEK_ITEMNF, "
		cQuery +=          " QEK_TIPONF, "
		cQuery +=          " QEK_LOTE, "
		cQuery +=          " QEK_NUMSEQ, "
		cQuery +=          " QEK_DTENTR, "
		cQuery +=          " QEK_SITENT, "
		cQuery +=          " QEK_TAMLOT, "
		cQuery +=          " QEK_UNIMED, "
		cQuery +=          " QEK_DTNFIS, "
		cQuery +=          " R_E_C_N_O_ "
		cQuery +=   " FROM " + RetSQLName("QEK") + " "
		cQuery +=   " WHERE (QEK_FILIAL = '" + xFilial("QEK") + "') "

		If !Empty(Self:cRecno) .AND. Self:cRecno <> "0"
			cQuery +=    " AND (R_E_C_N_O_ = " + Self:cRecno + ") "
		EndIf

		If !Empty(Self:cTexto)
			cQuery +=        " AND (    (UPPER(QEK_PRODUT) LIKE UPPER("+cTexto+") ) "  
			cQuery +=              " OR (UPPER(QEK_NTFISC) LIKE UPPER("+cTexto+") ) ) "
		EndIf

		If !Empty(Self:cLote)
			cQuery +=        " AND (UPPER(QEK_LOTE) LIKE UPPER("+cLote+") ) " 
		EndIf

		If !Empty(Self:cNumSEQ)
			cQuery +=        " AND (UPPER(QEK_NUMSEQ) LIKE UPPER("+cNumSEQ+") ) " 
		EndIf

		If !Empty(Self:cFornecedor)
			cQuery +=        " AND (UPPER(QEK_FORNEC) LIKE UPPER("+cFornecedor+") ) " 
		EndIf

		If Self:filtraPorRegistrosPendentes()
			cQuery +=        " AND (QEK_DTENTR >= '" + DtoS(Self:dEntradaInicial) + "') "
		EndIf
		
		cQuery +=            " AND (D_E_L_E_T_ = ' ') "
		cQuery += " ) QEK "

		If Self:oAPIManager:lPELaboratoriosRelacionadosAoUsuario .OR. !Empty(Self:cLaboratorio)
			cQuery += " INNER JOIN "
			cQuery += " (SELECT QE8_PRODUT AS PRODUTO, QE8_REVI AS REVISAO, QE8_LABOR "
			cQuery += " FROM " + RetSQLName("QE8") + " "
			cQuery += " WHERE   (QE8_FILIAL = '" + xFilial("QE8") + "') "
			If !Empty(Self:cLaboratorio)
				cQuery += " AND (QE8_LABOR = '" + Self:cLaboratorio + "') "
			EndIf
			cQuery +=   Self:oAPIManager:RetornaFiltroPELaboratoriosRelacionadosAoUsuario("QE8_LABOR", Self:cLogin, "incominginspections/api/qie/v1/inspection")
			cQuery +=     " AND (D_E_L_E_T_ = ' ') "
			cQuery += " UNION "
			cQuery += " SELECT QE7_PRODUT, QE7_REVI, QE7_LABOR "
			cQuery += " FROM " + RetSQLName("QE7") + " "
			cQuery += " WHERE   (QE7_FILIAL = '" + xFilial("QE7") + "') "
			If !Empty(Self:cLaboratorio)
				cQuery += " AND (QE7_LABOR = '" + Self:cLaboratorio + "') "
			EndIf
			cQuery +=   Self:oAPIManager:RetornaFiltroPELaboratoriosRelacionadosAoUsuario("QE7_LABOR", Self:cLogin, "incominginspections/api/qie/v1/inspection")
			cQuery +=     " AND (D_E_L_E_T_ = ' ') "
			cQuery += " ) FILTROLAB ON QEK.QEK_PRODUT = FILTROLAB.PRODUTO "
			cQuery +=            " AND QEK.QEK_REVI   = FILTROLAB.REVISAO "
		EndIf

		If Self:lNaoIniciadas .OR. Self:lSemLaudos
			cQuery += " LEFT JOIN ( " + Self:retornaQueryFiltroCardSemLaudos() + ") LAUDOS "

			//Relaciona por CHAVE_INSPECAO
			cQuery += " ON " + Self:oQueryManager:MontaRelationArraysCampos(""      , {"QEK_FORNEC","QEK_LOJFOR","QEK_PRODUT","QEK_NTFISC+QEK_SERINF+QEK_ITEMNF","QEK_TIPONF","QEK_LOTE","QEK_DTENTR"},;
			                                                                "LAUDOS", {"QEL_FORNEC","QEL_LOJFOR","QEL_PRODUT","QEL_NISERI"                      ,"QEL_TIPONF","QEL_LOTE","QEL_DTENTR"})

			If QIEReinsp()
				cQuery += " AND QEK_NUMSEQ = LAUDOS.QEL_NUMSEQ "
			EndIf

		ElseIf Self:lLaudosIncompletos
			cQuery += " INNER JOIN ( " + Self:retornaQueryFiltroCardLaudoIncompleto() + ") INCOMPLETOS"

			//Relaciona por CHAVE_INSPECAO
			cQuery += " ON " + Self:oQueryManager:MontaRelationArraysCampos(""           , {"QEK_FORNEC","QEK_LOJFOR","QEK_PRODUT","QEK_NTFISC+QEK_SERINF+QEK_ITEMNF","QEK_TIPONF","QEK_LOTE","QEK_DTENTR"},;
			                                                                "INCOMPLETOS", {"QEL_FORNEC","QEL_LOJFOR","QEL_PRODUT","QEL_NISERI"                      ,"QEL_TIPONF","QEL_LOTE","QEL_DTENTR"})
			
			If QIEReinsp()
				cQuery += " AND QEK_NUMSEQ = INCOMPLETOS.QEL_NUMSEQ "
			EndIf

		Else//If !Self:filtraPorRegistrosPendentes() .OR. !Empty(Self:cLaboratorio)
			cQuery += " LEFT JOIN ( " + Self:retornaQueryFiltroCardLaudoIncompleto() + ") INCOMPLETOS"

			//Relaciona por CHAVE_INSPECAO
			cQuery += " ON " + Self:oQueryManager:MontaRelationArraysCampos(""           , {"QEK_FORNEC","QEK_LOJFOR","QEK_PRODUT","QEK_NTFISC+QEK_SERINF+QEK_ITEMNF","QEK_TIPONF","QEK_LOTE","QEK_DTENTR"},;
			                                                                "INCOMPLETOS", {"QEL_FORNEC","QEL_LOJFOR","QEL_PRODUT","QEL_NISERI"                      ,"QEL_TIPONF","QEL_LOTE","QEL_DTENTR"})
			
			If QIEReinsp()
				cQuery += " AND QEK_NUMSEQ = INCOMPLETOS.QEL_NUMSEQ "
			EndIf

		EndIf

		cQuery += " LEFT JOIN "
		cQuery +=   "(SELECT A2_COD, "
		cQuery +=          " A2_LOJA, "
		cQuery +=          " A2_NOME "
		cQuery +=   " FROM " + RetSQLName("SA2") + " "
		cQuery +=   " WHERE (A2_FILIAL = '" + xFilial("SA2") + "') "
		cQuery +=    " AND  (D_E_L_E_T_ = ' ') ) SA2 "
		cQuery += " ON     SA2.A2_COD = QEK.QEK_FORNEC "
		cQuery +=   " AND SA2.A2_LOJA = QEK.QEK_LOJFOR "

		cQuery += " INNER JOIN "
		cQuery +=   "(SELECT B1_COD, "
		cQuery +=          " B1_DESC "
		cQuery +=   " FROM " + RetSQLName("SB1") + " "
		cQuery +=   " WHERE (B1_FILIAL  = '" + xFilial("SB1") + "') "
		cQuery +=    " AND  (D_E_L_E_T_ = ' ') ) SB1 "
		cQuery += " ON SB1.B1_COD = QEK.QEK_PRODUT "

		cQuery += " LEFT JOIN "

		cQuery +=   "(SELECT DISTINCT QER.QER_FORNEC, "
		cQuery +=                   " QER.QER_LOJFOR, "
		cQuery +=                   " QER.QER_PRODUT, "
		cQuery +=                   " QER.QER_NISERI, "
		cQuery +=                   " QER.QER_TIPONF, "
		cQuery +=                   " QER.QER_LOTE, "
		cQuery +=                   " QER.QER_NUMSEQ, "
		cQuery +=                   " QER.QER_DTENTR, "
		cQuery +=                   " 'X' QER_RESULT "
		cQuery +=   " FROM " + RetSQLName("QER") + " QER "
		cQuery +=   " WHERE     (QER.QER_FILIAL = '" + xFilial("QER") + "') "
		
		If Self:oAPIManager:lPELaboratoriosRelacionadosAoUsuario .OR. !Empty(Self:cLaboratorio)
			If !Empty(Self:cLaboratorio)
				cQuery += " AND (QER_LABOR = '" + Self:cLaboratorio + "') "
			EndIf
			cQuery +=   Self:oAPIManager:RetornaFiltroPELaboratoriosRelacionadosAoUsuario("QER_LABOR", Self:cLogin, "incominginspections/api/qie/v1/inspection")
		EndIf

		If !Empty(Self:cTexto)
			cQuery +=        " AND (    (UPPER(QER_PRODUT) LIKE UPPER("+cTexto+") ) "  
			cQuery +=              " OR (UPPER(QER_NISERI) LIKE UPPER("+cTexto+") ) ) "
		EndIf
		
		If !Empty(Self:cLote)
			cQuery +=        " AND (UPPER(QER_LOTE) LIKE UPPER("+cLote+") ) " 
		EndIf

		If !Empty(Self:cNumSEQ)
			cQuery +=        " AND (UPPER(QER_NUMSEQ) LIKE UPPER("+cNumSEQ+") ) " 
		EndIf

		If !Empty(Self:cFornecedor)
			cQuery +=        " AND (UPPER(QER_FORNEC) LIKE UPPER("+cFornecedor+") ) " 
		EndIf

		cQuery +=            " AND  (QER.D_E_L_E_T_ = ' ') "
		cQuery += " ) AMOSTRAGENS "

		//Relaciona por CHAVE_INSPECAO
		cQuery += " ON " + Self:oQueryManager:MontaRelationArraysCampos(""           , {"QEK_FORNEC","QEK_LOJFOR","QEK_PRODUT","QEK_NTFISC+QEK_SERINF+QEK_ITEMNF","QEK_TIPONF","QEK_LOTE","QEK_DTENTR"},;
																		"AMOSTRAGENS", {"QER_FORNEC","QER_LOJFOR","QER_PRODUT","QER_NISERI"                      ,"QER_TIPONF","QER_LOTE","QER_DTENTR"})
		If QIEReinsp()
			cQuery += " AND QEK_NUMSEQ = AMOSTRAGENS.QER_NUMSEQ "
		EndIf

		//Relaciona por CHAVE_INSPECAO
		cQuery += " ON " + Self:oQueryManager:MontaRelationArraysCampos(""            , {"QEK_FORNEC","QEK_LOJFOR","QEK_PRODUT","QEK_NTFISC+QEK_SERINF+QEK_ITEMNF","QEK_TIPONF","QEK_LOTE","QEK_DTENTR"},;
																		"QUERY_STATUS", {"QEL_FORNEC","QEL_LOJFOR","QEL_PRODUT","QEL_NISERI"                      ,"QEL_TIPONF","QEL_LOTE","QEL_DTENTR"})

		If QIEReinsp()
			cQuery += " AND QEK_NUMSEQ = QUERY_STATUS.QEL_NUMSEQ "
		EndIf

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
		cQuery +=    " AND  (UPPER(RTRIM(QAA_LOGIN)) = " + FwQtToChr(AllTrim(Upper(Self:cLogin))) +" ) "
		cQuery +=    " AND  (D_E_L_E_T_ = ' ')"
		cQuery +=  " ) QAA "

		cQuery += " ON SAH.AH_UNIMED = QEK.QEK_UNIMED "

		cQuery += " WHERE 1=1 "

		If Self:filtraPorRegistrosPendentes() .AND. !Self:lNaoIniciadas .AND. !Self:lSemLaudos .AND. !Self:lLaudosIncompletos
			cQuery += " AND QEK_SITENT NOT IN ('2','3','4','5','6') "

		ElseIf Self:lNaoIniciadas 
			cQuery += " AND LAUDOS.QEL_NISERI IS NULL "
			cQuery += " AND (CASE QEK.QEK_SITENT "
			cQuery +=             " WHEN '2' THEN 'A' "
			cQuery +=             " WHEN '3' THEN 'R' "
			cQuery +=             " WHEN '4' THEN 'U' "
			cQuery +=             " WHEN '5' THEN 'C' "
			cQuery +=             " WHEN '6' THEN 'E' "
			cQuery +=             " ELSE "
			cQuery +=             " COALESCE (QUERY_STATUS.QEL_LAUDO, "
			cQuery +=                      " (CASE COALESCE (QER_RESULT, "
			cQuery +=                                       "'N') "
			cQuery +=                           " WHEN 'N' THEN 'N' "
			cQuery +=                           " ELSE 'I' "
			cQuery +=                       " END)) "
			cQuery +=        " END) = 'N' "

		ElseIf Self:lSemLaudos
			cQuery += " AND LAUDOS.QEL_NISERI IS NULL "
			cQuery += " AND (CASE QEK.QEK_SITENT "
			cQuery +=             " WHEN '2' THEN 'A' "
			cQuery +=             " WHEN '3' THEN 'R' "
			cQuery +=             " WHEN '4' THEN 'U' "
			cQuery +=             " WHEN '5' THEN 'C' "
			cQuery +=             " WHEN '6' THEN 'E' "
			cQuery +=             " ELSE "
			cQuery +=             " COALESCE (QUERY_STATUS.QEL_LAUDO, "
			cQuery +=                      " (CASE COALESCE (QER_RESULT, "
			cQuery +=                                       "'N') "
			cQuery +=                           " WHEN 'N' THEN 'N' "
			cQuery +=                           " ELSE 'I' "
			cQuery +=                       " END)) "
			cQuery +=        " END) = 'I' "
			//cQuery += " AND (QEK_SITENT = '7') " //Desconsiderardo devido inconsistência nas bases
		EndIf

		cQuery +=       " ) DADOS ) DADOS2 "
		cQuery += " WHERE LINHA BETWEEN '" + cValToChar(nStart) + "' AND '" + cValToChar(nEnd) + "' "

		cQuery := Self:oAPIManager:ChangeQueryAllDB(cQuery)
		cAlias := Self:oQueryManager:executeQuery(cQuery)

	RECOVER
	END SEQUENCE
	ErrorBlock(bErrorBlock)

Return cAlias

/*/{Protheus.doc} pesquisaLista
Pesquisa Lista de Inspeções de Processo com Base em Texto nos Campos Produto, OP
@author brunno.costa
@since  25/10/2024
@return lRetorno, lógico, indica se conseguiu realizar o processamento
/*/
METHOD pesquisaLista() CLASS InspecoesDeEntradasAPI
     
    Local cAlias      := Nil
    Local lRetorno    := .T.

	If Self:naoImplantado()
		SetRestFault(405, EncodeUtf8(STR0008), .T.,; //"Módulo não está implantado"
		             405, EncodeUtf8(STR0009)) //"Fale com a TOTVS e faça implantação do módulo!"
		Return
	EndIf

    cAlias := Self:criaAliasPesquisa()

	If cAlias == Nil .OR. Empty(cAlias)
		lRetorno := .F.
		Self:oAPIManager:RespondeValor("message", Self:oAPIManager:cErrorMessage, Self:oAPIManager:cErrorMessage, Self:oAPIManager:cDetailedMessage)
	Else	
		lRetorno := Self:oAPIManager:ProcessaListaResultados(cAlias, Self:nPagina, Self:nTamPag, .F.)
		(cAlias)->(dbCloseArea())
	EndIf

Return lRetorno

/*/{Protheus.doc} usuarioExistente
Identifica se o usuário possui cadastro na QAA
@author brunno.costa
@since  25/10/2024
@param 01 - cLogin , caracter, login do usuário para validação das permissões de acesso
@return lRetorno, lógico, indica se o usuário é permitido
/*/
METHOD usuarioExistente(cLogin) CLASS InspecoesDeEntradasAPI
     
	Local oAPIQIP := InspecoesDeProcessosAPI():New(Self:oWSRestFul)

Return oAPIQIP:UsuarioExistente(cLogin)

/*/{Protheus.doc} naoImplantado
Indica se o Módulo QIP não está implantado
@author brunno.costa
@since  25/10/2024
@return lnaoImplantado, lógico, indica se o módulo QIP não está implantado
/*/
METHOD naoImplantado() CLASS InspecoesDeEntradasAPI

	Local lnaoImplantado := Nil

	DbSelectArea("QEK")
	QEK->(DbSetOrder(1))
	QEK->(DbSeek(xFilial("QEK")))

	lnaoImplantado := QEK->(Eof())
	
Return lnaoImplantado


/*/{Protheus.doc} retornaContagemCards
Indica se o Módulo QIP não está implantado
@author brunno.costa
@since  25/10/2024
@return oRetorno, JsonObject, objeto json com os dados para retorno
		oRetorno['notStarted']        = Inspeções não iniciadas
		oRetorno['withoutReport']     = Inspeções sem laudos
		oRetorno['incompleteReports'] = Inspeções com laudos incompletos
/*/
METHOD retornaContagemCards() CLASS InspecoesDeEntradasAPI
	
	Local bErrorBlock := Nil
	Local cAlias      := Nil
	Local cFornecedor := Self:preparaTextoParaPesquisaComLike(Self:cFornecedor)
	Local cLote       := Self:preparaTextoParaPesquisaComLike(Self:cLote)
	Local cNumSEQ     := Self:preparaTextoParaPesquisaComLike(Self:cNumSEQ)
    Local cQuery      := Nil
	Local cTexto      := Self:preparaTextoParaPesquisaComLike(Self:cTexto)
	Local oRetorno    := JsonObject():New()

	Self:oAPIManager := QualityAPIManager():New(Nil, Self:oWSRestFul)
	bErrorBlock := ErrorBlock({|e| Self:oAPIManager:ErrorBlock(e, e:Description), Break(e)})
	
	BEGIN SEQUENCE

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
		cQuery +=				   " (CASE QEK_SITENT WHEN ' ' THEN 0 ELSE 1 END) "
		cQuery +=			    " ELSE 0 END) "
		cQuery +=            " ELSE 0 END) "
		cQuery +=     " END) SEM_LAUDO, "

		cQuery += 	" SUM( CASE CONCAT(UNIAO.LAUDO, UNIAO.LAUDO_GERAL)  WHEN 'TX'  THEN 1 ELSE 0  END ) INCOMPLETO "

		cQuery += " FROM "
		cQuery += 	   " (SELECT DISTINCT "
		
		cQuery +=              " COALESCE(COALESCE(AMOSTRAS.QER_NISERI, COALESCE(LAUDO.QEL_FORNEC, LAUDO_GERAL.QEL_FORNEC)), INSPECOES.QEK_FORNEC    ) QEL_FORNEC, "
		cQuery +=              " COALESCE(COALESCE(AMOSTRAS.QER_NISERI, COALESCE(LAUDO.QEL_LOJFOR, LAUDO_GERAL.QEL_LOJFOR)), INSPECOES.QEK_LOJFOR    ) QEL_LOJFOR, "
		cQuery +=              " COALESCE(COALESCE(AMOSTRAS.QER_NISERI, COALESCE(LAUDO.QEL_PRODUT, LAUDO_GERAL.QEL_PRODUT)), INSPECOES.QEK_PRODUT    ) QEL_PRODUT, "
		
		cQuery +=              " COALESCE(COALESCE(AMOSTRAS.QER_NISERI, COALESCE(LAUDO.QEL_NISERI, LAUDO_GERAL.QEL_NISERI)), " + Self:oQueryManager:acertaConcatenacaoComConcat("INSPECOES.", "QEK_NTFISC+QEK_SERINF+QEK_ITEMNF") + " ) QEL_NISERI, "
		cQuery +=              " COALESCE(COALESCE(AMOSTRAS.QER_NISERI, COALESCE(LAUDO.QEL_TIPONF, LAUDO_GERAL.QEL_TIPONF)), INSPECOES.QEK_TIPONF    ) QEL_TIPONF, "
		cQuery +=              " COALESCE(COALESCE(AMOSTRAS.QER_NISERI, COALESCE(LAUDO.QEL_LOTE  , LAUDO_GERAL.QEL_LOTE  )), INSPECOES.QEK_LOTE      ) QEL_LOTE  , "
		cQuery +=              " COALESCE(COALESCE(AMOSTRAS.QER_NISERI, COALESCE(LAUDO.QEL_NUMSEQ, LAUDO_GERAL.QEL_NUMSEQ)), INSPECOES.QEK_NUMSEQ    ) QEL_NUMSEQ, "
		cQuery +=              " COALESCE(COALESCE(AMOSTRAS.QER_DTENTR, COALESCE(LAUDO.QEL_DTENTR, LAUDO_GERAL.QEL_DTENTR)), INSPECOES.QEK_DTENTR    ) QEL_DTENTR, "

		cQuery +=              " INSPECOES.QEK_SITENT, "
		cQuery +=              " (CASE WHEN COALESCE(INSPECOES.QEK_NTFISC  , 'X') = 'X' THEN 'X' ELSE 'T' END) INSPECOES, "
        cQuery +=              " (CASE WHEN COALESCE(AMOSTRAS.QER_NISERI   , 'X') = 'X' THEN 'X' ELSE 'T' END) AMOSTRAS, "
        cQuery +=              " (CASE WHEN COALESCE(LAUDO.QEL_NISERI      , 'X') = 'X' THEN 'X' ELSE 'T' END) LAUDO, "
		cQuery +=              " (CASE WHEN COALESCE(LAUDO_GERAL.QEL_NISERI, 'X') = 'X' THEN 'X' ELSE 'T' END) LAUDO_GERAL "
		cQuery +=       " FROM  "


		cQuery += " (SELECT "
		cQuery +=                       " QEK_FORNEC, QEK_LOJFOR, QEK_PRODUT, QEK_REVI, QEK_NTFISC, QEK_SERINF, QEK_ITEMNF, QEK_TIPONF, QEK_LOTE, QEK_NUMSEQ, QEK_DTENTR, QEK_SITENT "
		cQuery += " FROM (SELECT DISTINCT QEK_FORNEC, QEK_LOJFOR, QEK_PRODUT, QEK_REVI, QEK_NTFISC, QEK_SERINF, QEK_ITEMNF, QEK_TIPONF, QEK_LOTE, QEK_NUMSEQ, QEK_DTENTR, QEK_SITENT "
		cQuery +=       " FROM (SELECT QEK_FORNEC, QEK_LOJFOR, QEK_PRODUT, QEK_REVI, QEK_NTFISC, QEK_SERINF, QEK_ITEMNF, QEK_TIPONF, QEK_LOTE, QEK_NUMSEQ, QEK_DTENTR, QEK_SITENT "
		cQuery +=             " FROM " + RetSQLName("QEK")
		cQuery +=             " WHERE (QEK_FILIAL = '" + xFilial("QEK") + "') "

		If !Empty(Self:cTexto)
			cQuery +=         " AND (    (UPPER(QEK_PRODUT) LIKE UPPER("+cTexto+") ) "  
			cQuery +=               " OR (UPPER(QEK_NTFISC) LIKE UPPER("+cTexto+") ) ) "
		EndIf

		If !Empty(Self:cLote)
			cQuery +=         " AND (UPPER(QEK_LOTE) LIKE UPPER("+cLote+") ) " 
		EndIf

		If !Empty(Self:cNumSEQ)
			cQuery +=         " AND (UPPER(QEK_NUMSEQ) LIKE UPPER("+cNumSEQ+") ) " 
		EndIf

		If !Empty(Self:cFornecedor)
			cQuery +=         " AND (UPPER(QEK_FORNEC) LIKE UPPER("+cFornecedor+") ) " 
		EndIf

		If Self:filtraPorRegistrosPendentes()
			cQuery +=         " AND QEK_DTENTR >= '" + DtoS(Self:dEntradaInicial) + "'"
			cQuery +=         " AND QEK_SITENT NOT IN ('2','3','4','5') "
		EndIf

		cQuery +=             " AND (D_E_L_E_T_ = ' ') ) QEK "

		If Self:oAPIManager:lPELaboratoriosRelacionadosAoUsuario .OR. !Empty(Self:cLaboratorio) //Filtro de Laboratórios - INSPECOES
			cQuery += " INNER JOIN "
			cQuery += " (SELECT QE8_PRODUT AS PRODUTO, QE8_REVI AS REVISAO, QE8_LABOR "
			cQuery += " FROM " + RetSQLName("QE8") + " "
			cQuery += " WHERE (QE8_FILIAL = '" + xFilial("QE8") + "') "
			If !Empty(Self:cLaboratorio)
				cQuery += " AND (QE8_LABOR = '" + Self:cLaboratorio + "') "
			EndIf
			cQuery +=   Self:oAPIManager:RetornaFiltroPELaboratoriosRelacionadosAoUsuario("QE8_LABOR", Self:cLogin, "incominginspections/api/qie/v1/cards")
			cQuery += " AND   (D_E_L_E_T_ = ' ') "
			cQuery += " UNION "
			cQuery += " SELECT QE7_PRODUT, QE7_REVI, QE7_LABOR "
			cQuery += " FROM " + RetSQLName("QE7") + " "
			cQuery += " WHERE (QE7_FILIAL = '" + xFilial("QE7") + "') "
			If !Empty(Self:cLaboratorio)
				cQuery += " AND (QE7_LABOR = '" + Self:cLaboratorio + "') "
			EndIf
			cQuery +=   Self:oAPIManager:RetornaFiltroPELaboratoriosRelacionadosAoUsuario("QE7_LABOR", Self:cLogin, "incominginspections/api/qie/v1/cards")
			cQuery += " AND   (D_E_L_E_T_ = ' ')"
			cQuery += " ) FILTROLAB ON QEK_PRODUT = FILTROLAB.PRODUTO "
			cQuery +=            " AND QEK_REVI   = FILTROLAB.REVISAO "
		EndIf

		cQuery +=               " ) DADOS) INSPECOES "


		cQuery += " LEFT JOIN (SELECT DISTINCT "
		cQuery +=   " QER_FORNEC, QER_LOJFOR, QER_PRODUT, QER_NISERI, QER_TIPONF, QER_LOTE, QER_NUMSEQ, QER_DTENTR "
		cQuery += " FROM " + RetSQLName("QER")
		cQuery += " WHERE (QER_FILIAL = '" + xFilial("QER") + "') "

		If !Empty(Self:cTexto)
			cQuery += " AND (    (UPPER(QER_PRODUT) LIKE UPPER("+cTexto+") ) "  
			cQuery +=       " OR (UPPER(QER_NISERI) LIKE UPPER("+cTexto+") ) ) "
		EndIf

		If !Empty(Self:cLote)
			cQuery += " AND (UPPER(QER_LOTE) LIKE UPPER("+cLote+") ) " 
		EndIf

		If !Empty(Self:cNumSEQ)
			cQuery += " AND (UPPER(QER_NUMSEQ) LIKE UPPER("+cNumSEQ+") ) " 
		EndIf

		If !Empty(Self:cFornecedor)
			cQuery += " AND (UPPER(QER_FORNEC) LIKE UPPER("+cFornecedor+") ) " 
		EndIf

		If !Empty(Self:cLaboratorio)
			cQuery += " AND (QER_LABOR = '" + Self:cLaboratorio + "') "
		EndIf

		cQuery +=     " AND (D_E_L_E_T_ = ' ')  "
		cQuery +=   " ) AMOSTRAS "

		//Relaciona por CHAVE_INSPECAO
		cQuery += " ON " + Self:oQueryManager:MontaRelationArraysCampos("INSPECOES" , {"QEK_FORNEC","QEK_LOJFOR","QEK_PRODUT","QEK_NTFISC+QEK_SERINF+QEK_ITEMNF","QEK_TIPONF","QEK_LOTE","QEK_DTENTR"},;
																		"AMOSTRAS"  , {"QER_FORNEC","QER_LOJFOR","QER_PRODUT","QER_NISERI"                      ,"QER_TIPONF","QER_LOTE","QER_DTENTR"})

		If QIEReinsp()
			cQuery += " AND INSPECOES.QEK_NUMSEQ = AMOSTRAS.QER_NUMSEQ "
		EndIf

		cQuery += " LEFT JOIN (SELECT DISTINCT "
		cQuery +=                         " QEL_FORNEC, QEL_LOJFOR, QEL_PRODUT, QEL_NISERI, QEL_TIPONF, QEL_LOTE, QEL_NUMSEQ, QEL_DTENTR "
		cQuery +=            " FROM (SELECT DISTINCT "
		cQuery +=                         " QEL_FORNEC, QEL_LOJFOR, QEL_PRODUT, QEL_NISERI, QEL_TIPONF, QEL_LOTE, QEL_NUMSEQ, QEL_DTENTR "
		cQuery +=                  " FROM " + RetSQLName("QEL")
		cQuery +=                  " WHERE (QEL_FILIAL = '" + xFilial("QEL") + "') "

		if !Empty(Self:cTexto)
			cQuery +=                " AND (    (UPPER(QEL_PRODUT) LIKE UPPER("+cTexto+") ) "  
			cQuery +=                      " OR (UPPER(QEL_NISERI) LIKE UPPER("+cTexto+") ) ) "
		EndIf

		If !Empty(Self:cLote)
			cQuery +=                " AND (UPPER(QEL_LOTE) LIKE UPPER("+cLote+") ) " 
		EndIf

		If !Empty(Self:cNumSEQ)
			cQuery +=                " AND (UPPER(QEL_NUMSEQ) LIKE UPPER("+cNumSEQ+") ) " 
		EndIf

		If !Empty(Self:cFornecedor)
			cQuery +=                " AND (UPPER(QEL_FORNEC) LIKE UPPER("+cFornecedor+") ) " 
		EndIf
		cQuery +=                    " AND (D_E_L_E_T_ = ' ') "
		cQuery +=                    " AND (QEL_LAUDO <> ' ') "

		cQuery +=                  " UNION "
		cQuery +=                  " SELECT DISTINCT "
		cQuery +=                         " QEL_FORNEC, QEL_LOJFOR, QEL_PRODUT, QEL_NISERI, QEL_TIPONF, QEL_LOTE, QEL_NUMSEQ, QEL_DTENTR "
		cQuery +=                  " FROM " + RetSQLName("QEL")
		cQuery +=                  " WHERE (QEL_FILIAL = '" + xFilial("QEL") + "') "
		cQuery +=                    " AND (QEL_LAUDO <> ' ') "

		If !Empty(Self:cTexto)
			cQuery +=              " AND (    (UPPER(QEL_PRODUT) LIKE UPPER("+cTexto+") ) "  
			cQuery +=                    " OR (UPPER(QEL_NISERI) LIKE UPPER("+cTexto+") ) ) "
		EndIf

		If !Empty(Self:cLote)
			cQuery +=              " AND (UPPER(QEL_LOTE) LIKE UPPER("+cLote+") ) " 
		EndIf

		If !Empty(Self:cNumSEQ)
			cQuery +=              " AND (UPPER(QEL_NUMSEQ) LIKE UPPER("+cNumSEQ+") ) " 
		EndIf

		If !Empty(Self:cFornecedor)
			cQuery +=              " AND (UPPER(QEL_FORNEC) LIKE UPPER("+cFornecedor+") ) " 
		EndIf

		cQuery +=                  " AND (D_E_L_E_T_ = ' ')  "
		cQuery +=                " ) LAUDOS "
		cQuery +=              " ) LAUDO "

		//Relaciona por CHAVE_INSPECAO
		cQuery += " ON " + Self:oQueryManager:MontaRelationArraysCampos("INSPECOES", {"QEK_FORNEC","QEK_LOJFOR","QEK_PRODUT","QEK_NTFISC+QEK_SERINF+QEK_ITEMNF","QEK_TIPONF","QEK_LOTE","QEK_DTENTR"},;
																		"LAUDO"    , {"QEL_FORNEC","QEL_LOJFOR","QEL_PRODUT","QEL_NISERI"                      ,"QEL_TIPONF","QEL_LOTE","QEL_DTENTR"})

		If QIEReinsp()
			cQuery += " AND INSPECOES.QEK_NUMSEQ = LAUDO.QEL_NUMSEQ "
		EndIf

		cQuery += " LEFT JOIN (SELECT DISTINCT "
		cQuery +=                   " QEL_FORNEC, QEL_LOJFOR, QEL_PRODUT, QEL_NISERI, QEL_TIPONF, QEL_LOTE, QEL_NUMSEQ, QEL_DTENTR "
		cQuery +=       " FROM " + RetSQLName("QEL")
		cQuery +=       " WHERE (QEL_FILIAL = '" + xFilial("QEL") + "') "
		
		If !Empty(Self:cTexto)
			cQuery +=   " AND (    (UPPER(QEL_PRODUT) LIKE UPPER("+cTexto+") ) "  
			cQuery +=         " OR (UPPER(QEL_NISERI) LIKE UPPER("+cTexto+") ) ) "
		EndIf
		
		If !Empty(Self:cLote)
			cQuery +=   " AND (UPPER(QEL_LOTE) LIKE UPPER("+cLote+") ) " 
		EndIf

		If !Empty(Self:cNumSEQ)
			cQuery +=   " AND (UPPER(QEL_NUMSEQ) LIKE UPPER("+cNumSEQ+") ) " 
		EndIf

		If !Empty(Self:cFornecedor)
			cQuery +=   " AND (UPPER(QEL_FORNEC) LIKE UPPER("+cFornecedor+") ) " 
		EndIf

		cQuery +=       " AND (QEL_LABOR = ' ')  "
		cQuery +=       " AND (QEL_LAUDO <> ' ') "
		cQuery +=       " AND (D_E_L_E_T_ = ' ') "
		cQuery +=     " ) LAUDO_GERAL "

		//Relaciona por CHAVE_INSPECAO
		cQuery += " ON " + Self:oQueryManager:MontaRelationArraysCampos("INSPECOES"  , {"QEK_FORNEC","QEK_LOJFOR","QEK_PRODUT","QEK_NTFISC+QEK_SERINF+QEK_ITEMNF","QEK_TIPONF","QEK_LOTE","QEK_DTENTR"},;
																		"LAUDO_GERAL", {"QEL_FORNEC","QEL_LOJFOR","QEL_PRODUT","QEL_NISERI"                      ,"QEL_TIPONF","QEL_LOTE","QEL_DTENTR"})

		If QIEReinsp()
			cQuery += " AND INSPECOES.QEK_NUMSEQ = LAUDO.QEL_NUMSEQ "
		EndIf

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

/*/{Protheus.doc} retornaQueryFiltroCardLaudoIncompleto
Retorna Query para Filtro doo CARD Laudo Incompleto
@author brunno.costa
@since  25/10/2024
@return cQuery, caracter, string de filtro dos status de CARDS
/*/
METHOD retornaQueryFiltroCardLaudoIncompleto() CLASS InspecoesDeEntradasAPI
	
	Local cFornecedor := Self:preparaTextoParaPesquisaComLike(Self:cFornecedor)
	Local cLote       := Self:preparaTextoParaPesquisaComLike(Self:cLote)
	Local cNumSEQ     := Self:preparaTextoParaPesquisaComLike(Self:cNumSEQ)
	Local cQuery      := ""
	Local cTexto      := Self:preparaTextoParaPesquisaComLike(Self:cTexto)

	cQuery := " SELECT DISTINCT "
	cQuery += 	" QEL_FORNEC, QEL_LOJFOR, QEL_PRODUT, QEL_NISERI, QEL_TIPONF, QEL_LOTE, QEL_NUMSEQ, QEL_DTENTR "
	cQuery += " FROM (SELECT "

	cQuery +=              " COALESCE(LAUDO.QEL_FORNEC, LAUDO_GERAL.QEL_FORNEC) QEL_FORNEC, "
	cQuery +=              " COALESCE(LAUDO.QEL_LOJFOR, LAUDO_GERAL.QEL_LOJFOR) QEL_LOJFOR, "
	cQuery +=              " COALESCE(LAUDO.QEL_PRODUT, LAUDO_GERAL.QEL_PRODUT) QEL_PRODUT, "
	cQuery +=              " COALESCE(LAUDO.QEL_NISERI, LAUDO_GERAL.QEL_NISERI) QEL_NISERI, "
	cQuery +=              " COALESCE(LAUDO.QEL_TIPONF, LAUDO_GERAL.QEL_TIPONF) QEL_TIPONF, "
	cQuery +=              " COALESCE(LAUDO.QEL_LOTE  , LAUDO_GERAL.QEL_LOTE  ) QEL_LOTE  , "
	cQuery +=              " COALESCE(LAUDO.QEL_NUMSEQ, LAUDO_GERAL.QEL_NUMSEQ) QEL_NUMSEQ, "
	cQuery +=              " COALESCE(LAUDO.QEL_DTENTR, LAUDO_GERAL.QEL_DTENTR) QEL_DTENTR, "

	cQuery +=              " COALESCE(LAUDO.QEL_NISERI      , 'X') LAUDO, "
	cQuery +=              " COALESCE(LAUDO_GERAL.QEL_NISERI, 'X') LAUDO_GERAL "

	cQuery +=       " FROM (SELECT DISTINCT "
	cQuery +=                    " QEL_FORNEC, QEL_LOJFOR, QEL_PRODUT, QEL_NISERI, QEL_TIPONF, QEL_LOTE, QEL_NUMSEQ, QEL_DTENTR "
	cQuery +=       " FROM " + RetSQLName("QEL")
	cQuery +=       " WHERE (QEL_FILIAL = '" + xFilial("QEL") + "') "
	
	If !Empty(Self:cTexto)
		cQuery +=   " AND (    (UPPER(QEL_PRODUT) LIKE UPPER("+cTexto+") ) "  
		cQuery +=         " OR (UPPER(QEL_NISERI) LIKE UPPER("+cTexto+") ) ) "
	EndIf
	
	If !Empty(Self:cLote)
		cQuery +=   " AND (UPPER(QEL_LOTE) LIKE UPPER("+cLote+") ) " 
	EndIf

	If !Empty(Self:cNumSEQ)
		cQuery +=   " AND (UPPER(QEL_NUMSEQ) LIKE UPPER("+cNumSEQ+") ) " 
	EndIf

	If !Empty(Self:cFornecedor)
		cQuery +=   " AND (UPPER(QEL_FORNEC) LIKE UPPER("+cFornecedor+") ) " 
	EndIf

	cQuery +=       "   AND (QEL_LABOR = ' ') "
	cQuery +=       "   AND (QEL_LAUDO <> ' ') "
	cQuery +=       "   AND (D_E_L_E_T_ = ' ') "
	cQuery +=     " ) LAUDO_GERAL "

	cQuery += " FULL JOIN (SELECT DISTINCT "
	cQuery +=                   " QEL_FORNEC, QEL_LOJFOR, QEL_PRODUT, QEL_NISERI, QEL_TIPONF, QEL_LOTE, QEL_NUMSEQ, QEL_DTENTR "
	cQuery +=            " FROM (SELECT DISTINCT "
	cQuery +=                         " QEL_FORNEC, QEL_LOJFOR, QEL_PRODUT, QEL_NISERI, QEL_TIPONF, QEL_LOTE, QEL_NUMSEQ, QEL_DTENTR "
	cQuery +=                  " FROM " + RetSQLName("QEL")
	cQuery +=                  " WHERE (QEL_FILIAL = '" + xFilial("QEL") + "') "
	
	If !Empty(Self:cTexto)
		cQuery +=   " AND (    (UPPER(QEL_PRODUT) LIKE UPPER("+cTexto+") ) "  
		cQuery +=         " OR (UPPER(QEL_NISERI) LIKE UPPER("+cTexto+") ) ) "
	EndIf
	
	If !Empty(Self:cLote)
		cQuery +=   " AND (UPPER(QEL_LOTE) LIKE UPPER("+cLote+") ) " 
	EndIf

	If !Empty(Self:cNumSEQ)
		cQuery +=   " AND (UPPER(QEL_NUMSEQ) LIKE UPPER("+cNumSEQ+") ) " 
	EndIf

	If !Empty(Self:cFornecedor)
		cQuery +=   " AND (UPPER(QEL_FORNEC) LIKE UPPER("+cFornecedor+") ) " 
	EndIf

	cQuery +=                    " AND (QEL_LAUDO <> ' ') "
	cQuery +=                    " AND (D_E_L_E_T_ = ' ') "

	cQuery +=                  " UNION "
	cQuery +=                  " SELECT DISTINCT "
	cQuery +=                         " QEL_FORNEC, QEL_LOJFOR, QEL_PRODUT, QEL_NISERI, QEL_TIPONF, QEL_LOTE, QEL_NUMSEQ, QEL_DTENTR "
	cQuery +=                  " FROM " + RetSQLName("QEL") 
	cQuery +=                  " WHERE (QEL_FILIAL = '" + xFilial("QEL") + "') "
	
	If !Empty(Self:cTexto)
		cQuery +=              " AND (    (UPPER(QEL_PRODUT) LIKE UPPER("+cTexto+") ) "  
		cQuery +=                    " OR (UPPER(QEL_NISERI) LIKE UPPER("+cTexto+") ) ) "
	EndIf
	
	If !Empty(Self:cLote)
		cQuery +=              " AND (UPPER(QEL_LOTE) LIKE UPPER("+cLote+") ) " 
	EndIf

	If !Empty(Self:cNumSEQ)
		cQuery +=              " AND (UPPER(QEL_NUMSEQ) LIKE UPPER("+cNumSEQ+") ) " 
	EndIf

	If !Empty(Self:cFornecedor)
		cQuery +=              " AND (UPPER(QEL_FORNEC) LIKE UPPER("+cFornecedor+") ) " 
	EndIf

	cQuery +=                  " AND (QEL_LAUDO <> ' ') "
	cQuery +=                  " AND (D_E_L_E_T_ = ' ') "
	cQuery +=                " ) LAUDOS "
	cQuery +=              " ) LAUDO "
	
	//Relaciona por CHAVE_INSPECAO
	cQuery += " ON " + Self:oQueryManager:MontaRelationArraysCampos("LAUDO"      , {"QEL_LOJFOR","QEL_PRODUT","QEL_NISERI","QEL_TIPONF","QEL_LOTE","QEL_NUMSEQ","QEL_DTENTR"},;
			                                                        "LAUDO_GERAL", {"QEL_LOJFOR","QEL_PRODUT","QEL_NISERI","QEL_TIPONF","QEL_LOTE","QEL_NUMSEQ","QEL_DTENTR"})
	cQuery += " ) UNIAO "

	cQuery += " WHERE (CASE WHEN (CASE UNIAO.LAUDO WHEN 'X' THEN 0 ELSE 1 END) - (CASE UNIAO.LAUDO_GERAL WHEN 'X' THEN 0 ELSE 1 END) > 0 "
	cQuery +=             " THEN (CASE UNIAO.LAUDO WHEN 'X' THEN 0 ELSE 1 END) - (CASE UNIAO.LAUDO_GERAL WHEN 'X' THEN 0 ELSE 1 END) "
	cQuery +=        " ELSE 0 END) = 1 "//Filtra Laudos Incompletos

Return cQuery


/*/{Protheus.doc} retornaQueryFiltroCardSemLaudos
Retorna Query para Filtro doo CARD Laudo Incompleto
@author brunno.costa
@since  25/10/2024
@return cQuery, caracter, string de filtro dos status de CARDS
/*/
METHOD retornaQueryFiltroCardSemLaudos() CLASS InspecoesDeEntradasAPI
	
	Local cFornecedor := Self:preparaTextoParaPesquisaComLike(Self:cFornecedor)
	Local cLote       := Self:preparaTextoParaPesquisaComLike(Self:cLote)
	Local cNumSEQ     := Self:preparaTextoParaPesquisaComLike(Self:cNumSEQ)
	Local cQuery      := ""
	Local cTexto      := Self:preparaTextoParaPesquisaComLike(Self:cTexto)

	cQuery := " SELECT  "
	cQuery += 	" DISTINCT QEL_FORNEC, QEL_LOJFOR, QEL_PRODUT, QEL_NISERI, QEL_TIPONF, QEL_LOTE, QEL_NUMSEQ, QEL_DTENTR "
	cQuery += " FROM (SELECT "

	cQuery +=              " COALESCE(LAUDO.QEL_FORNEC, LAUDO_GERAL.QEL_FORNEC) QEL_FORNEC, "
	cQuery +=              " COALESCE(LAUDO.QEL_LOJFOR, LAUDO_GERAL.QEL_LOJFOR) QEL_LOJFOR, "
	cQuery +=              " COALESCE(LAUDO.QEL_PRODUT, LAUDO_GERAL.QEL_PRODUT) QEL_PRODUT, "
	cQuery +=              " COALESCE(LAUDO.QEL_NISERI, LAUDO_GERAL.QEL_NISERI) QEL_NISERI, "
	cQuery +=              " COALESCE(LAUDO.QEL_TIPONF, LAUDO_GERAL.QEL_TIPONF) QEL_TIPONF, "
	cQuery +=              " COALESCE(LAUDO.QEL_LOTE  , LAUDO_GERAL.QEL_LOTE  ) QEL_LOTE  , "
	cQuery +=              " COALESCE(LAUDO.QEL_NUMSEQ, LAUDO_GERAL.QEL_NUMSEQ) QEL_NUMSEQ, "
	cQuery +=              " COALESCE(LAUDO.QEL_DTENTR, LAUDO_GERAL.QEL_DTENTR) QEL_DTENTR, "

	cQuery +=              " COALESCE(LAUDO.QEL_NISERI      , 'X') LAUDO, "
	cQuery +=              " COALESCE(LAUDO_GERAL.QEL_NISERI, 'X') LAUDO_GERAL "

	cQuery +=       " FROM (SELECT DISTINCT "
	cQuery +=                    " QEL_FORNEC, QEL_LOJFOR, QEL_PRODUT, QEL_NISERI, QEL_TIPONF, QEL_LOTE, QEL_NUMSEQ, QEL_DTENTR "
	cQuery +=       " FROM " + RetSQLName("QEL")
	cQuery +=       " WHERE (QEL_FILIAL = '" + xFilial("QEL") + "') "
	
	If !Empty(Self:cTexto)
		cQuery +=     " AND (    (UPPER(QEL_PRODUT) LIKE UPPER("+cTexto+") ) "  
		cQuery +=           " OR (UPPER(QEL_NISERI) LIKE UPPER("+cTexto+") ) ) "
	EndIf
	
	If !Empty(Self:cLote)
		cQuery +=     " AND (UPPER(QEL_LOTE) LIKE UPPER("+cLote+") ) " 
	EndIf

	If !Empty(Self:cNumSEQ)
		cQuery +=     " AND (UPPER(QEL_NUMSEQ) LIKE UPPER("+cNumSEQ+") ) " 
	EndIf

	If !Empty(Self:cFornecedor)
		cQuery +=     " AND (UPPER(QEL_FORNEC) LIKE UPPER("+cFornecedor+") ) " 
	EndIf

	cQuery +=         " AND (QEL_LABOR = ' ')  "
	cQuery +=         " AND (QEL_LAUDO <> ' ') "
	cQuery +=         " AND (D_E_L_E_T_ = ' ') "
	cQuery +=       " ) LAUDO_GERAL "
	

	cQuery += " FULL JOIN (SELECT DISTINCT "
	cQuery +=                   " QEL_FORNEC, QEL_LOJFOR, QEL_PRODUT, QEL_NISERI, QEL_TIPONF, QEL_LOTE, QEL_NUMSEQ, QEL_DTENTR "
	cQuery +=            " FROM (SELECT DISTINCT "
	cQuery +=                    " QEL_FORNEC, QEL_LOJFOR, QEL_PRODUT, QEL_NISERI, QEL_TIPONF, QEL_LOTE, QEL_NUMSEQ, QEL_DTENTR "
	cQuery +=                  " FROM " + RetSQLName("QEL")
	cQuery +=                  " WHERE (QEL_FILIAL = '" + xFilial("QEL") + "') "
	
	If !Empty(Self:cTexto)
		cQuery +=                " AND (    (UPPER(QEL_PRODUT) LIKE UPPER("+cTexto+") ) "  
		cQuery +=                      " OR (UPPER(QEL_NISERI) LIKE UPPER("+cTexto+") ) ) "
	EndIf
	
	If !Empty(Self:cLote)
		cQuery +=                " AND (UPPER(QEL_LOTE) LIKE UPPER("+cLote+") ) " 
	EndIf

	If !Empty(Self:cNumSEQ)
		cQuery +=                " AND (UPPER(QEL_NUMSEQ) LIKE UPPER("+cNumSEQ+") ) " 
	EndIf

	If !Empty(Self:cFornecedor)
		cQuery +=                " AND (UPPER(QEL_FORNEC) LIKE UPPER("+cFornecedor+") ) " 
	EndIf
	cQuery +=                    " AND (QEL_LAUDO <> ' ') "
	cQuery +=                    " AND (D_E_L_E_T_ = ' ') "
	
	cQuery +=                  " UNION "
	cQuery +=                  " SELECT DISTINCT "
	cQuery +=                         " QEL_FORNEC, QEL_LOJFOR, QEL_PRODUT, QEL_NISERI, QEL_TIPONF, QEL_LOTE, QEL_NUMSEQ, QEL_DTENTR "
	cQuery +=                  " FROM " + RetSQLName("QEL")
	cQuery +=                  " WHERE (QEL_FILIAL = '" + xFilial("QEL") + "') "
	cQuery +=                    " AND (QEL_LAUDO <> ' ') "
	
	If !Empty(Self:cTexto)
		cQuery +=              " AND (    (UPPER(QEL_PRODUT) LIKE UPPER("+cTexto+") ) "  
		cQuery +=                    " OR (UPPER(QEL_NISERI) LIKE UPPER("+cTexto+") ) ) "
	EndIf

	If !Empty(Self:cLote)
		cQuery +=              " AND (UPPER(QEL_LOTE) LIKE UPPER("+cLote+") ) " 
	EndIf

	If !Empty(Self:cNumSEQ)
		cQuery +=              " AND (UPPER(QEL_NUMSEQ) LIKE UPPER("+cNumSEQ+") ) " 
	EndIf

	If !Empty(Self:cFornecedor)
		cQuery +=              " AND (UPPER(QEL_FORNEC) LIKE UPPER("+cFornecedor+") ) " 
	EndIf
	
	cQuery +=                  " AND (D_E_L_E_T_ = ' ')  "
	cQuery +=                " ) LAUDOS "
	cQuery +=              " ) LAUDO "

	//Relaciona por CHAVE_INSPECAO
	cQuery += " ON " + Self:oQueryManager:MontaRelationArraysCampos("LAUDO"      , {"QEL_LOJFOR","QEL_PRODUT","QEL_NISERI","QEL_TIPONF","QEL_LOTE","QEL_NUMSEQ","QEL_DTENTR"},;
			                                                        "LAUDO_GERAL", {"QEL_LOJFOR","QEL_PRODUT","QEL_NISERI","QEL_TIPONF","QEL_LOTE","QEL_NUMSEQ","QEL_DTENTR"})

	cQuery += " ) UNIAO "

Return cQuery

/*/{Protheus.doc} preparaTextoParaPesquisaComLike
Prepara o texto para pesquisa com Like
@author brunno.costa
@since  25/10/2024
@param 01 - cTextoOrig
@return cTexto, caracter, string para pesquisa
/*/
METHOD preparaTextoParaPesquisaComLike(cTextoOrig) CLASS InspecoesDeEntradasAPI
	
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




