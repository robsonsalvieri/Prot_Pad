#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "EnsaiosInspecaoDeProcessosAPI.CH"

#DEFINE nPosCPS_Considera                  1
#DEFINE nPosCPS_Titulo_Interface           2
#DEFINE nPosCPS_Titulo_API                 3
#DEFINE nPosCPS_Protheus                   4
#DEFINE nPosCPS_Tipo                       5
#DEFINE nPosCPS_Tamanho                    6
#DEFINE nPosCPS_Decimal                    7
#DEFINE nPosCPS_Alias                      8
#DEFINE nPosCPS_Protheus_Externo           9

/*/{Protheus.doc} processinspectiontest
API de Ensaio de Inspeção de Processos - Qualidade
@author rafael.hesse
@since  31/05/2022
/*/
WSRESTFUL processinspectiontest DESCRIPTION STR0001 FORMAT APPLICATION_JSON //"Ensaio de Inspeção de Processos"

    WSDATA Fields            as STRING OPTIONAL
	WSDATA IDEnsaio          as STRING OPTIONAL
	WSDATA Laboratory        as STRING OPTIONAL
	WSDATA Login             as STRING OPTIONAL
	WSDATA MeasurementDate   as STRING OPTIONAL
	WSDATA OperationID       as STRING OPTIONAL
	WSDATA OperationRoutines as STRING OPTIONAL
    WSDATA Order             as STRING OPTIONAL
	WSDATA OrderType         as STRING OPTIONAL
    WSDATA Page              as INTEGER OPTIONAL
    WSDATA PageSize          as INTEGER OPTIONAL
	WSDATA ProductID         as STRING OPTIONAL
    WSDATA Recno             as STRING OPTIONAL
	WSDATA RecnoQPK          as STRING OPTIONAL
	WSDATA Revision          as STRING OPTIONAL
	WSDATA Status            as STRING OPTIONAL

    WSMETHOD GET list;
    DESCRIPTION STR0002; //"Retorna Lista de Ensaios de Inspeções de Processos"
    WSSYNTAX "api/qip/v1/list/{Recno}/{OperationID}/{Order}/{OrderType}/{Page}/{PageSize}" ;
    PATH "/api/qip/v1/list" ;
    TTALK "v1"

	WSMETHOD GET test;
    DESCRIPTION STR0003; //"Retorna um Ensaio da Inspeção de Processos"
    WSSYNTAX "api/qip/v1/test/{Recno}/{OperationID}/{IDEnsaio}" ;
    PATH "/api/qip/v1/test" ;
    TTALK "v1"

	WSMETHOD GET hasmetrologyintegration;
    DESCRIPTION STR0007; //"Indica se está habilitada a integração com o módulo de metrologia"
    WSSYNTAX "api/qip/v1/hasmetrologyintegration" ;
    PATH "/api/qip/v1/hasmetrologyintegration" ;
    TTALK "v1"

	WSMETHOD GET hasafamilyofinstruments;
    DESCRIPTION STR0008; //"Indica existência de relaciomanento de família de instrumentos"
    WSSYNTAX "api/qip/v1/hasafamilyofinstruments/{ProductID}/{Revision}/{OperationRoutines}/{OperationID}/{IDEnsaio}" ;
    PATH "/api/qip/v1/hasafamilyofinstruments" ;
    TTALK "v1"

	WSMETHOD GET metrologyinstruments;
    DESCRIPTION STR0009; //"Lista instrumentos de metrologia relacionados"
    WSSYNTAX "api/qip/v1/metrologyinstruments/{ProductID}/{Revision}/{OperationRoutines}/{OperationID}/{IDEnsaio}/{MeasurementDate}" ;
    PATH "/api/qip/v1/metrologyinstruments" ;
    TTALK "v1"

	WSMETHOD GET texttestwithmandatoryinstrument;
    DESCRIPTION STR0010; //"Ensaio de texto com instrumento obrigatório"
    WSSYNTAX "api/qip/v1/texttestwithmandatoryinstrument" ;
    PATH "/api/qip/v1/texttestwithmandatoryinstrument" ;
    TTALK "v1"

	WSMETHOD GET repeatinstruments;
    DESCRIPTION STR0011; //"Indica se está habilitada repetição de instrumentos da primeira amostra"
    WSSYNTAX "api/qip/v1/repeatinstruments" ;
    PATH "/api/qip/v1/repeatinstruments" ;
    TTALK "v1"

	WSMETHOD GET evaluateskiptest;
    DESCRIPTION STR0012; //"Avalia Skip Teste"
    WSSYNTAX "api/qip/v1/evaluateskiptest/{RecnoQPK}/{OperationRoutines}/{OperationID}/{IDEnsaio}" ;
    PATH "/api/qip/v1/evaluateskiptest" ;
    TTALK "v1"

ENDWSRESTFUL

WSMETHOD GET list PATHPARAM Recno, OperationID, Laboratory, Order, OrderType, Page, PageSize QUERYPARAM Fields WSSERVICE processinspectiontest
    Local oAPIClass  := EnsaiosInspecaoDeProcessosAPI():New(Self)
	Default Self:Fields      := ""
	Default Self:Laboratory  := ""
	Default Self:Login       := ""
	Default Self:OperationID := ""
	Default Self:Order       := ""
	Default Self:OrderType   := ""
	Default Self:Page        := 1
	Default Self:PageSize    := 5
	Default Self:Recno       := 0
	Default Self:Status      := "true"
	oAPIClass:cEndPoint := "/api/qip/v1/list"
Return oAPIClass:RetornaLista(Self:Recno, Self:OperationID, Self:Laboratory, Self:Order, Self:OrderType, Self:Page, Self:PageSize, Self:Fields, Nil, Self:Login, Iif(Self:Status == "true", .T., .F.))

WSMETHOD GET test PATHPARAM Recno, OperationID, Laboratory, IDEnsaio QUERYPARAM Fields WSSERVICE processinspectiontest
    Local oAPIClass  := EnsaiosInspecaoDeProcessosAPI():New(Self)
	Default Self:Fields     := ""
	Default Self:IDEnsaio   := ""
	Default Self:Login      := ""
	Default Self:OperationID := ""
	Default Self:Recno      := 0
	oAPIClass:cEndPoint := "/api/qip/v1/test"
Return oAPIClass:RetornaLista(Self:Recno, Self:OperationID, Self:Laboratory, "", "", 1, 1, Self:Fields, Self:IDEnsaio, Self:Login)

WSMETHOD GET hasmetrologyintegration PATHPARAM QUERYPARAM Fields WSSERVICE processinspectiontest
    
	Local oAPIClass  := EnsaiosInspecaoDeProcessosAPI():New(Self)

	oAPIClass:cEndPoint := "/api/qip/v1/hasmetrologyintegration"
	oAPIClass:oAPIManager := QualityAPIManager():New({}, Self)
	oAPIClass:oAPIManager:RespondeValor("result", Iif(AllTrim(Upper(GetMv("MV_QIPQMT"))) == "S", "true", "false"))

Return 

WSMETHOD GET texttestwithmandatoryinstrument PATHPARAM QUERYPARAM Fields WSSERVICE processinspectiontest
    
	Local lMV_QINVLTX  := Iif(ValType(GetMv("MV_QINVLTX")) == "C", Val(GetMv("MV_QINVLTX")), GetMv("MV_QINVLTX")) == 1
	Local oAPIClass    := EnsaiosInspecaoDeProcessosAPI():New(Self)

	oAPIClass:cEndPoint := "/api/qip/v1/texttestwithmandatoryinstrument"
	oAPIClass:oAPIManager := QualityAPIManager():New({}, Self)
	oAPIClass:oAPIManager:RespondeValor("result", Iif(lMV_QINVLTX, "true", "false"))
	
Return 

WSMETHOD GET repeatinstruments PATHPARAM QUERYPARAM Fields WSSERVICE processinspectiontest
    
	Local oAPIClass  := EnsaiosInspecaoDeProcessosAPI():New(Self)

	oAPIClass:cEndPoint := "/api/qip/v1/repeatinstruments"
	oAPIClass:oAPIManager := QualityAPIManager():New({}, Self)
	oAPIClass:oAPIManager:RespondeValor("result", Iif(GetMv("MV_QPINAUT") == "S", "true", "false"))

Return 

WSMETHOD GET evaluateskiptest PATHPARAM RecnoQPK, OperationRoutines, OperationID, IDEnsaio QUERYPARAM Fields WSSERVICE processinspectiontest
    
	Local cEnsaio     := Self:IDEnsaio
	Local lInspeciona := .F.
	Local oAPIClass   := EnsaiosInspecaoDeProcessosAPI():New(Self)

	Private cRoteiro  := Self:OperationRoutines

	QPK->(DbGoTo(Val(Self:RecnoQPK)))

	lInspeciona := QP215SkpT(cEnsaio, Self:OperationID) != OemToAnsi(STR0013) //"Certificar"

	oAPIClass:cEndPoint := "/api/qip/v1/evaluateskiptest"
	oAPIClass:oAPIManager := QualityAPIManager():New({}, Self)
	oAPIClass:oAPIManager:RespondeValor("inspect", Iif(lInspeciona, "true", "false"))

Return 

WSMETHOD GET hasafamilyofinstruments PATHPARAM ProductID, Revision, OperationRoutines, OperationID, IDEnsaio QUERYPARAM Fields WSSERVICE processinspectiontest
    
	Local oAPIClass  := EnsaiosInspecaoDeProcessosAPI():New(Self)

	Default Self:IDEnsaio          := ""
	Default Self:OperationID       := ""
	Default Self:OperationRoutines := ""
	Default Self:ProductID         := ""
	Default Self:Revision          := ""

	oAPIClass:cEndPoint := "/api/qip/v1/hasafamilyofinstruments"
	oAPIClass:oAPIManager := QualityAPIManager():New({}, Self)
	oAPIClass:oAPIManager:RespondeValor("result", oAPIClass:PossuiFamiliaDeInstrumentos(Self:ProductID, Self:Revision, Self:OperationRoutines, Self:OperationID, Self:IDEnsaio))

Return 

WSMETHOD GET metrologyinstruments PATHPARAM ProductID, Revision, OperationRoutines, OperationID, IDEnsaio, MeasurementDate QUERYPARAM Fields WSSERVICE processinspectiontest

    Local oAPIClass    := EnsaiosInspecaoDeProcessosAPI():New(Self)
	Local dDataAmostra := Nil

	Default Self:IDEnsaio          := ""
	Default Self:OperationID       := ""
	Default Self:OperationRoutines := ""
	Default Self:ProductID         := ""
	Default Self:Revision          := ""
	Default Self:MeasurementDate   := ""

	oAPIClass:cEndPoint := "/api/qip/v1/metrologyinstruments"
	
	oAPIClass:oAPIManager := QualityAPIManager():New({}, Self)
	dDataAmostra := oAPIClass:oAPIManager:FormataDado("D", Self:MeasurementDate, "1")

	oAPIClass:ListaInstrumentosDeMedicao(Self:ProductID, Self:Revision, Self:OperationRoutines, Self:OperationID, Self:IDEnsaio, dDataAmostra)

Return 

/*/{Protheus.doc} EnsaiosInspecaoDeProcessosAPI
Regras de Negocio - API Ensaios de Inspeção de Processos
@author rafael.hesse
@since  31/05/2022
/*/
CLASS EnsaiosInspecaoDeProcessosAPI FROM LongNameClass
    
	DATA cEndPoint        as STRING
	DATA oAPIManager      as OBJECT
	DATA oQueryManager    as OBJECT
	DATA oWSRestFul       as OBJECT

    METHOD new(oWSRestFul) CONSTRUCTOR
	METHOD CriaAliasEnsaiosPesquisa(nRecno, cOperacao, cLaboratorio, cOrdem, cTipoOrdem, nPagina, nTamPag, cCampos, cIDEnsaio, cUsuario, lStatus)
	METHOD ListaInstrumentosDeMedicao(cProduto, cRevisao, cRoteiro, cOperacao, cIDEnsaio, dDataMedicao)
	METHOD PossuiFamiliaDeInstrumentos(cProduto, cRevisao, cRoteiro, cOperacao, cIDEnsaio)
    METHOD RetornaLista(nRecno, cLaboratorio, cOrdem, cTipoOrdem, nPagina, nTamPag, cCampos, cIDEnsaio, cUsuario, lStatus)
     
    //Métodos Internos
    METHOD MapeiaCampos(cCampos)
	METHOD MapeiaCamposListaInstrumento()
	METHOD ModoExibicaoReferencias(cLogin)
	METHOD NaoImplantado()
	
ENDCLASS

METHOD new(oWSRestFul) CLASS EnsaiosInspecaoDeProcessosAPI
	 Self:oWSRestFul    := oWSRestFul
	 Self:oQueryManager := QLTQueryManager():New()
Return Self

/*/{Protheus.doc} MapeiaCampos
Mapeia os Campos
@author rafael.hesse
@since  01/06/2022
@param 01 - cCampos, String, string com os campos [nPosCPS_Titulo_API] para consideração separados por vírgula
@return aMapaCampos, Array , {{lConsidera, Titulo Interface, Título API, Campo Protheus, Tipo, Tamanho, Decimal}, ...}
                             {{nPosCPS_Considera, ..., nPosCPS_Decimal}, ...}
/*/
METHOD MapeiaCampos(cCampos) CLASS EnsaiosInspecaoDeProcessosAPI

    Local aMapaCampos := {}

   	aadd(aMapaCampos, {.T., "RecnoInspecao"        , "recnoInspection"     , "RECNOQPK"            , "NN", 0                                      , 0, "QPK"}) //NN para não formatar como número pois não temos certeza do tamanho configurado na tabela do cliente
    aadd(aMapaCampos, {.T., "RecnoEnsaio"          , "recnoTest"           , "RECNOTEST"           , "NN", 0                                      , 0, "QP7QP8"}) //NN para não formatar como número pois não temos certeza do tamanho configurado na tabela do cliente
    aadd(aMapaCampos, {.T., "Ensaio"               , "testID"              , "QP7_ENSAIO"          , "C" , 0                                      , 0, "QP7QP8"}) //NN para não formatar como número pois não temos certeza do tamanho configurado na tabela do cliente
    aadd(aMapaCampos, {.T., "Sequencia"            , "sequence"            , "QP7_SEQLAB"          , "NN", 0                                      , 0, "QP7QP8"}) //NN para não formatar como número pois não temos certeza do tamanho configurado na tabela do cliente
	aadd(aMapaCampos, {.T., "Obrigatorio"          , "obrigatory"          , "ENSOBRI"             , "LL", 0                                      , 0, "QP7QP8"}) //NN para não formatar como número pois não temos certeza do tamanho configurado na tabela do cliente
    aadd(aMapaCampos, {.F., "Titulo"               , "title"               , "QP1_DESCPO"          , "C" , GetSx3Cache("QP1_DESCPO" ,"X3_TAMANHO"), 0, "QP1"})
	aadd(aMapaCampos, {.F., "Nível Ensaio"         , "testLevel"           , "QP1_NIENSR"          , "C" , GetSx3Cache("QP1_NIENSR" ,"X3_TAMANHO"), 0, "QP1"})
    aAdd(aMapaCampos, {.F., "QuantidadeMedicoes"   , "numberOfMeasurements", "QP1_QTDE"            , "N" , GetSx3Cache("QP1_QTDE"   ,"X3_TAMANHO"), 0, "QP1"})
	aadd(aMapaCampos, {.F., "Tipo"                 , "type"                , "QP1_TIPO"            , "C" , GetSx3Cache("QP1_TIPO"   ,"X3_TAMANHO"), 0, "QP1"})
    aadd(aMapaCampos, {.F., "Laboratorio"          , "laboratory"          , "X5_DESCRI"           , "C" , GetSx3Cache("X5_DESCRI"  ,"X3_TAMANHO"), 0, "SX5"})
	aadd(aMapaCampos, {.F., "IDLaboratorio"        , "laboratoryID"        , "X5_CHAVE"            , "C" , GetSx3Cache("X5_CHAVE"   ,"X3_TAMANHO"), 0, "SX5"})
    aadd(aMapaCampos, {.F., "EspecificacaoResumida", "summarySpecification", "SUMMARYSPECIFICATION", "C" , 20                                     , 0, "N/A"})
    aadd(aMapaCampos, {.F., "UnidadeDeMedida"      , "lotUnitID"           , "QP7_UNIMED"          , "C" , 2                                      , 0, "N/A"})
    aadd(aMapaCampos, {.F., "TipoDeControle"       , "controlType"         , "CONTROLTYPE"         , "C" , 1                                      , 0, "N/A"})
    aadd(aMapaCampos, {.F., "ValorNominal"         , "nominalValue"        , "QP7_NOMINA"          , "C" , GetSx3Cache("QP7_NOMINA" ,"X3_TAMANHO"), 0, "N/A"})
	aadd(aMapaCampos, {.F., "AfastamentoInferior"  , "lowerDeviation"      , "QP7_LIE"             , "C" , GetSx3Cache("QP7_LIE" ,"X3_TAMANHO")   , 0, "N/A"})
    aadd(aMapaCampos, {.F., "AfastamentoSuperior"  , "upperDeviation"      , "QP7_LSE"             , "C" , GetSx3Cache("QP7_LSE" ,"X3_TAMANHO")   , 0, "N/A"})
	aadd(aMapaCampos, {.F., "Operação"             , "operationID"         , "QP7_OPERAC"          , "C" , GetSx3Cache("QP7_OPERAC" ,"X3_TAMANHO"), 0, "N/A"})
    aadd(aMapaCampos, {.T., "TipoEnsaio"           , "testType"            , "TIPO"                , "V" , 1                                      , 0, "N/A"})
	aadd(aMapaCampos, {.T., "LaudoLaboratorio"     , "laboratoryReport"    , "QPL_LAUDO"           , "C" , GetSx3Cache("QPL_LAUDO" ,"X3_TAMANHO") , 0, "QPL"})
	aadd(aMapaCampos, {.T., "ExibeReferencias"     , "displaysReference"   , "QAA_VISREF"          , "L" , 1                                      , 0, "N/A"})
	aadd(aMapaCampos, {.T., "Nível Ensaiador"      , "testerLevel"         , "QAA_NIVEL"           , "C" , 1                                      , 0, "N/A"})
    aadd(aMapaCampos, {.T., "Status"               , "status"              , "STATUS"              , "C" , 1                                      , 0, "N/A"})
	
	Self:oAPIManager := QualityAPIManager():New(aMapaCampos, Self:oWSRestFul)
	Self:oAPIManager:MarcaCamposConsiderados(cCampos, aMapaCampos, nPosCPS_Titulo_API)

Return aMapaCampos


/*/{Protheus.doc} CriaAliasEnsaiosPesquisa
Cria Alias para Pesquisa Lista de Inspeções de Processo com Base em Texto nos Campos Produto, OP
@author rafael.hesse
@since  31/05/2022
@param 01 - nRecno      , numérico, R_E_C_N_O_ para buscar informações da tabela QPK
@param 02 - cOperacao   , numérico, operação relacionada
@param 03 - cLaboratorio, caracter, código do laboratório para filtro
@param 04 - cOrdem      , caracter, ordenação para retornar a listagem dos dados
@param 05 - cTipoOrdem  , caracter, tipo de ordenação para retornar a listagem dos dados (Ascedente ou Decrescente)
@param 06 - nPagina     , numérico, página atual dos dados para consulta
@param 07 - nTamPag     , numérico, tamanho de página padrão com a quantidade de registros para retornar
@param 08 - cCampos     , caracter, campos que deverão estar contidos na mensagem
@param 09 - cIDEnsaio   , caracter, código do ensaio
@param 10 - cUsuario    , caracter, código do usuário consumindo a API
@param 11 - lStatus     , lógico  , indica se deve consultar o status dos ensaios
@return cAlias, caracter, alias com os dados da Lista
/*/
METHOD CriaAliasEnsaiosPesquisa(nRecno, cOperacao, cLaboratorio, cOrdem, cTipoOrdem, nPagina, nTamPag, cCampos, cIDEnsaio, cUsuario, lStatus) CLASS EnsaiosInspecaoDeProcessosAPI
	
	Local aAreaQPK    := QPK->(GetArea())
	Local bErrorBlock := ErrorBlock({|e| Self:oAPIManager:ErrorBlock(e, e:Description), Break(e)})
    Local cAlias      := Nil
	Local cC2_OP      := ""
	Local cNivelUsr   := Posicione("QAA", 6, Upper(cUsuario), "QAA_NIVEL")
	Local cOrdemDB    := Nil
    Local cQuery      := ""
	Local lExibeRef   := Self:ModoExibicaoReferencias(cUsuario) == "1"

	Default lStatus := .T.

	nRecno := Iif(ValType(nRecno) == "C", Val(nRecno), nRecno)
	QPK->(DbGoTo(nRecno))
	cC2_OP := QPK->QPK_OP

    Begin Sequence

		Self:MapeiaCampos(cCampos)
		Self:oAPIManager:AvaliaPELaboratoriosRelacionadosAoUsuario()

		//Ensaios do tipo Numérico
		cQuery +=  " SELECT RECNOQPK, "
		cQuery +=         " RECNOTEST, "
		cQuery +=         " QP7_ENSAIO, "
		cQuery +=         " QP7_SEQLAB, "
		cQuery += 		  " CONTROLTYPE, "
		cQuery += 		  " QP7_NOMINA, "
		cQuery += 		  " QP7_LIE, "
		cQuery += 		  " QP7_LSE, "
		cQuery += 		  " QP7_CODREC, "
		cQuery += 		  " QP7_OPERAC, "
		cQuery += 		  " ENSOBRI, "
		cQuery +=         " QP1_DESCPO, "
		cQuery += 		  " QP1_NIENSR, "
		cQuery +=         " QP1_TIPO, "
		cQuery += 		  " QP1_QTDE, "
		cQuery +=         " X5_CHAVE, "
		cQuery +=         " X5_DESCRI, "
		cQuery +=         " SUMMARYSPECIFICATION, "
		cQuery += 		  " QP7_UNIMED, "
		cQuery +=         " (CASE COALESCE(QPR_RESULT,' ') "
		cQuery += 				" WHEN ' ' "
		cQuery += 				" THEN ( "
		cQuery += 						" CASE ENSOBRI " 
		cQuery += 							" WHEN 'N' "
		cQuery += 							" THEN 'N' "
		cQuery += 						" ELSE 'P' END )  " 
		cQuery +=         " ELSE COALESCE(QPR_RESULT,' ') "
		cQuery +=         " END ) STATUS, "
		cQuery +=         " COALESCE(QPL_LAUDO, ' ') QPL_LAUDO, "

		If lExibeRef
			cQuery +=         " '.T.' QAA_VISREF, "
		Else
			cQuery +=         " '.F.' QAA_VISREF, "
		EndIf
		
		cQuery +=         "COALESCE(NULLIF('" + cNivelUsr + "', ''), '00') QAA_NIVEL, "

		cQuery +=         " TIPO "
		cQuery +=  " FROM "
		cQuery +=  " (SELECT "
		cQuery +=      " QPK.R_E_C_N_O_ RECNOQPK, "
		cQuery +=      " QP7.R_E_C_N_O_ RECNOTEST, "
		cQuery +=      " QP7.QP7_ENSAIO, "
		cQuery +=      " QP7.QP7_SEQLAB, "
		cQuery +=      " QP7.CONTROLTYPE, "
		cQuery +=      " QP7.QP7_NOMINA, "
		cQuery +=      " (CASE WHEN QP7.QP7_MINMAX = '1' OR QP7.QP7_MINMAX = '2' THEN QP7.QP7_LIE ELSE 'n/c' END) QP7_LIE, "
		cQuery +=      " (CASE WHEN QP7.QP7_MINMAX = '1' OR QP7.QP7_MINMAX = '3' THEN QP7.QP7_LSE ELSE 'n/c' END) QP7_LSE, "
		cQuery +=      " QP7.QP7_CODREC, "
		cQuery +=      " QP7.QP7_OPERAC, "
		cQuery +=      " QP7.QP7_UNIMED, "
		cQuery +=      " COALESCE(QP1.QP1_DESCPO, ' ') QP1_DESCPO, "
		cQuery +=	   " COALESCE(QP1.QP1_NIENSR, '00') QP1_NIENSR, "
		cQuery +=      " COALESCE(QP1.QP1_TIPO, ' ') QP1_TIPO, "
		cQuery +=	   " COALESCE(QP1.QP1_QTDE, 1) QP1_QTDE, "
		cQuery +=      " COALESCE(SX5.X5_CHAVE, ' ') X5_CHAVE, "
		cQuery +=      " COALESCE(SX5.X5_DESCRI, ' ') X5_DESCRI, "
		cQuery +=      " CONCAT(CONCAT(( "
		cQuery +=          " CASE "
		cQuery +=              " WHEN QP7.QP7_MINMAX = '2' "                                                                                // Controla mínimo
		cQuery += 				"	THEN CONCAT(CONCAT(RTRIM(QP7.QP7_NOMINA) , ' ') , RTRIM(QP7.QP7_LIE)) " // Exemplo: 20 -1 cm
		cQuery +=              " WHEN QP7.QP7_MINMAX = '3' "                                                                                // Controla máximo
		cQuery +=  				"	THEN CONCAT(CONCAT(RTRIM(QP7.QP7_NOMINA) , ' ' ), RTRIM(QP7.QP7_LSE)) " // Exemplo: 20 5 cm
		cQuery +=              " ELSE "                                                                                                     // Controla mínimo e máximo
		cQuery += 				"	CONCAT(CONCAT(CONCAT(CONCAT(RTRIM(QP7.QP7_NOMINA) , ' ' ), RTRIM(QP7.QP7_LIE)) , '/' ), RTRIM(QP7.QP7_LSE))  " // Exemplo: 20 -1/5 cm
		cQuery +=          " END "
		cQuery +=      " ) , ' ') , QP7.QP7_UNIMED) SUMMARYSPECIFICATION, "
		cQuery +=      " QP7.QP7_ENSOBR ENSOBRI, "
		cQuery +=      " QPL_LAUDO, "
		cQuery +=      " QPR_RESULT, "
		cQuery +=       "'N' TIPO "
		cQuery +=  " FROM "
		cQuery +=      " (SELECT "
		cQuery +=              " X5_CHAVE, "
		cQuery +=              " X5_DESCRI "
		cQuery +=          " FROM " + RetSqlName("SX5")
		cQuery +=          " WHERE "
		cQuery +=              "     (X5_FILIAL = '" + xFilial("SX5") +"') " 
		cQuery +=              " AND (X5_TABELA = 'Q2') "
		cQuery +=              " AND (D_E_L_E_T_ = ' ') "

		If Self:oAPIManager:lPELaboratoriosRelacionadosAoUsuario
			cQuery +=           Self:oAPIManager:RetornaFiltroPELaboratoriosRelacionadosAoUsuario("X5_CHAVE", cUsuario)
		EndIf

		If !Empty(cLaboratorio)
			cQuery +=           " AND (X5_CHAVE = '" + cLaboratorio + "') "
		EndIf

		cQuery +=       " ) SX5 "
		cQuery += 		" RIGHT OUTER JOIN "
		cQuery +=       " ( SELECT	"
		cQuery +=              " QPK_PRODUT, "
		cQuery +=              " QPK_REVI, "
		cQuery +=              " R_E_C_N_O_, "
		cQuery +=              " QPK_LAUDO,	"
		cQuery +=              " QPK_LOTE, "
		cQuery +=              " QPK_NUMSER, "
		cQuery +=              " QPK_OP "
		cQuery +=          " FROM	" + RetSqlName("QPK")
		cQuery +=          " WHERE "
		cQuery += 			       " (QPK_FILIAL = '" + xFilial("QPK") +"') " 
		cQuery +=              " AND (R_E_C_N_O_ = " + cValToChar(nRecno) +") " 
		cQuery +=              " AND (D_E_L_E_T_ = ' ') "
		cQuery +=       " ) QPK "
		cQuery +=       " INNER JOIN  "
		cQuery +=       " ( SELECT "
		cQuery +=              " QP7_PRODUT, "
		cQuery +=              " QP7_REVI, "
		cQuery +=              " QP7_ENSAIO, "
		cQuery +=              " QP7_LABOR, "
		cQuery +=              " R_E_C_N_O_, "
		cQuery +=              " QP7_NOMINA, "
		cQuery +=              " QP7_LIE, "
		cQuery +=              " QP7_LSE, "
		cQuery +=              " QP7_UNIMED, "
		cQuery +=              " QP7_MINMAX, "
		cQuery +=              " QP7_ENSOBR, "
		cQuery +=              " QP7_SEQLAB, "
		cQuery += 			   " QP7_MINMAX CONTROLTYPE, "
		cQuery += 			   " QP7_CODREC, "
		cQuery += 			   " QP7_OPERAC "
		cQuery +=          " FROM " + RetSqlName("QP7")
		cQuery +=          " WHERE "
		cQuery +=              " (QP7_FILIAL = '" + xFilial("QP7") +"') " 

		If !Empty(cOperacao)
			cQuery +=          " AND (QP7_OPERAC = '" + cOperacao +"') " 
		EndIf

		If !Empty(cIDEnsaio)
			cQuery +=          " AND (QP7_ENSAIO = '" + cIDEnsaio +"') " 
		EndIf

		If Self:oAPIManager:lPELaboratoriosRelacionadosAoUsuario
			cQuery +=          Self:oAPIManager:RetornaFiltroPELaboratoriosRelacionadosAoUsuario("QP7_LABOR", cUsuario)
		EndIf

		If !Empty(cLaboratorio)
			cQuery += " AND (QP7_LABOR = '" + cLaboratorio + "') "
		EndIf
		cQuery +=     " AND (D_E_L_E_T_ = ' ') "

		cQuery +=      	 " ) QP7 ON QP7.QP7_PRODUT = QPK.QPK_PRODUT "
		cQuery +=      		  " AND QP7.QP7_REVI = QPK.QPK_REVI "		

		cQuery +=        " INNER JOIN "
		cQuery +=          "(SELECT C2_NUM, C2_ITEM, C2_ITEMGRD, C2_SEQUEN, C2_ROTEIRO "
		cQuery +=          " FROM " + RetSQLName("SC2") + " "
		cQuery +=          " WHERE C2_FILIAL = '" + xFilial("SC2") + "' AND D_E_L_E_T_=' ' "
		cQuery += " ) SC2 "
		cQuery +=        " ON " + Self:oQueryManager:MontaRelationC2OP("QPK_OP")
		cQuery +=        Iif(SuperGetMV("MV_QIPOPEP") == "3", " AND (QP7_CODREC = C2_ROTEIRO OR QP7_CODREC = '" + QIPRotGene("QP7_CODREC") + "') ", " AND QP7_CODREC = C2_ROTEIRO ")

		cQuery +=      	 " LEFT OUTER JOIN "

		cQuery +=		 " (SELECT 
		cQuery +=		      " QPR_OP, "
		cQuery +=		      " QPR_PRODUT, "
		cQuery +=		      " QPR_LOTE, "
		cQuery +=		      " QPR_NUMSER, "
		cQuery +=		      " QPR_LABOR, "
		cQuery +=		      " QPR_ENSAIO, "
		cQuery +=		      " QPR_ROTEIR, "
		cQuery +=		      " QPR_OPERAC, "
		cQuery +=		      " MAX(QPR_RESULT) QPR_RESULT "
		cQuery +=		  " FROM " + RetSqlName("QPR")
		cQuery +=		  " WHERE  "
		cQuery +=            " (QPR_FILIAL = '" + xFilial("QPR") + "') "
		cQuery +=        " AND (QPR_OP     = '" + cC2_OP + "') "
		
		If !Empty(cOperacao)
			cQuery +=          " AND (QPR_OPERAC = '" + cOperacao +"') " 
		EndIf

		If Self:oAPIManager:lPELaboratoriosRelacionadosAoUsuario
			cQuery +=           Self:oAPIManager:RetornaFiltroPELaboratoriosRelacionadosAoUsuario("QPR_LABOR", cUsuario)
		EndIf

		If !Empty(cLaboratorio)
			cQuery += " AND (QPR_LABOR = '" + cLaboratorio + "') "
		EndIf

		cQuery +=		            " AND ( D_E_L_E_T_ = ' ' )  "
		cQuery +=		            " AND ( QPR_RESULT IN ('A', 'R')) "
		
		If !lStatus
			cQuery += " AND 1=0 "
		EndIf

		cQuery +=		        " GROUP BY "
		cQuery +=		            " QPR_OP, "
		cQuery +=		            " QPR_PRODUT, "
		cQuery +=		            " QPR_LOTE, "
		cQuery +=		            " QPR_NUMSER, "
		cQuery +=		            " QPR_LABOR, "
		cQuery +=		            " QPR_ENSAIO, "
		cQuery +=		            " QPR_ROTEIR, "
		cQuery +=		            " QPR_OPERAC "
		
		cQuery += 		" ) ENSAIO  "

		//Relaciona por CHAVE_ENSAIO
		cQuery +=          " ON " + Self:oQueryManager:MontaRelationArraysCampos("ENSAIO"     , {"QPR_OP", "QPR_LOTE", "QPR_NUMSER", "QPR_ROTEIR", "QPR_OPERAC", "QPR_LABOR", "QPR_ENSAIO"},;
		                                                                         ""           , {"QPK_OP", "QPK_LOTE", "QPK_NUMSER", "QP7_CODREC", "QP7_OPERAC", "QP7_LABOR", "QP7_ENSAIO"})

		cQuery +=      " LEFT OUTER JOIN ( "
		cQuery +=      " SELECT "
		cQuery +=           " QP1_ENSAIO, "
		cQuery +=           " QP1_FILIAL, "
		cQuery += 		    " (CASE QP1_CARTA "
		cQuery +=           " WHEN 'XBR' THEN QP1_QTDE "
		cQuery +=           " WHEN 'XBS' THEN QP1_QTDE "
		cQuery +=           " WHEN 'XMR' THEN QP1_QTDE "
		cQuery +=           " WHEN 'HIS' THEN QP1_QTDE "
		cQuery +=           " WHEN 'NP ' THEN QP1_QTDE "
		cQuery +=           " WHEN 'P  ' THEN 3 "
		cQuery +=           " WHEN 'U  ' THEN 2 "
		cQuery +=           " ELSE 1 "
		cQuery +=           " END) QP1_QTDE, "
		cQuery +=           " QP1_DESCPO, "
		cQuery +=           " QP1_NIENSR, "
		cQuery +=           " QP1_TIPO "
		cQuery +=      " FROM " + RetSqlName("QP1")
		cQuery +=      " WHERE "
		cQuery +=               " (QP1_FILIAL = '" + xFilial("QP1") +"') " 
		cQuery +=           " AND (D_E_L_E_T_ = ' ') "
		cQuery +=      		" ) QP1 ON QP7.QP7_ENSAIO = QP1.QP1_ENSAIO "
		cQuery += 	   " ON SX5.X5_CHAVE = QP7.QP7_LABOR "	

		cQuery +=      " LEFT OUTER JOIN ( "
		cQuery +=       " SELECT QPL_OP, QPL_LOTE, QPL_NUMSER, QPL_ROTEIR, QPL_OPERAC, QPL_LABOR, QPL_LAUDO "
		cQuery +=       " FROM " + RetSqlName("QPL")
		cQuery +=       " WHERE "
		cQuery +=             " (QPL_FILIAL = '" + xFilial("QPL") +"') " 
		cQuery +=         " AND (QPL_OP    = '" + cC2_OP + "')"
		
		If !Empty(cOperacao)
			cQuery +=   " AND (QPL_OPERAC = '" + cOperacao +"') " 
		EndIf

		If Self:oAPIManager:lPELaboratoriosRelacionadosAoUsuario
			cQuery +=   Self:oAPIManager:RetornaFiltroPELaboratoriosRelacionadosAoUsuario("QPL_LABOR", cUsuario)
		EndIf

		If !Empty(cLaboratorio)
			cQuery += " AND (QPL_LABOR = '" + cLaboratorio + "') "
		EndIf

		cQuery += " AND (D_E_L_E_T_ = ' ') "

		cQuery +=       " ) QPL "
		
		//Relaciona por CHAVE_LABORATORIO
		cQuery +=      " ON " + Self:oQueryManager:MontaRelationArraysCampos("", {"QPK_OP", "QPK_LOTE", "QPK_NUMSER", "QP7_CODREC", "QP7_OPERAC", "QP7_LABOR"},;
		                                                                     "", {"QPL_OP", "QPL_LOTE", "QPL_NUMSER", "QPL_ROTEIR", "QPL_OPERAC", "QPL_LABOR"})

		cQuery +=  " UNION "

		// Ensaios do tipo TEXTO
		cQuery +=  " SELECT "
		cQuery +=      " QPK.R_E_C_N_O_ RECNOQPK, "
		cQuery +=      " QP8.R_E_C_N_O_ RECNOTEST, "
		cQuery +=      " QP8.QP8_ENSAIO, "
		cQuery +=      " QP8.QP8_SEQLAB, "
		cQuery +=      " ' ' CONTROLTYPE, "
		cQuery +=      " ' ' QP7_NOMINA, "
		cQuery +=      " ' ' QP7_LIE, "
		cQuery +=      " ' ' QP7_LSE, "
		cQuery +=      " QP8.QP8_CODREC, "
		cQuery +=      " QP8.QP8_OPERAC, "
		cQuery +=      " ' ' QP7_UNIMED, "
		cQuery +=      " COALESCE(QP1.QP1_DESCPO, ' ') QP1_DESCPO, "
		cQuery +=      " COALESCE(QP1.QP1_NIENSR, '00') QP1_NIENSR, "
		cQuery +=      " COALESCE(QP1.QP1_TIPO, ' ') QP1_TIPO, "
		cQuery +=      " 1 QP1_QTDE, "
		cQuery +=      " COALESCE(SX5.X5_CHAVE, ' ') X5_CHAVE, "
		cQuery +=      " COALESCE(SX5.X5_DESCRI, ' ') X5_DESCRI, "
		cQuery +=      " QP8.QP8_TEXTO SUMMARYSPECIFICATION,	"
		cQuery +=      " QP8.QP8_ENSOBR ENSOBRI,	"
		cQuery +=      " QPL_LAUDO, "
		cQuery +=      " QPR_RESULT, "
		cQuery +=      " 'T' TIPO "
		cQuery +=  " FROM "
		cQuery +=      " ( SELECT "
		cQuery +=              " X5_CHAVE, "
		cQuery +=              " X5_DESCRI "
		cQuery +=       " FROM " + RetSqlName("SX5")
		cQuery +=       " WHERE "
		cQuery +=                  " (X5_FILIAL = '" + xFilial("SX5") + "') " 
		cQuery +=              " AND (X5_TABELA = 'Q2') "
		cQuery +=              " AND (D_E_L_E_T_ = ' ') "
		
		If Self:oAPIManager:lPELaboratoriosRelacionadosAoUsuario
			cQuery +=   Self:oAPIManager:RetornaFiltroPELaboratoriosRelacionadosAoUsuario("X5_CHAVE", cUsuario)
		EndIf

		If !Empty(cLaboratorio)
			cQuery += " AND (X5_CHAVE = '" + cLaboratorio + "') "
		EndIf

		cQuery +=       " ) SX5 "
		cQuery +=       " RIGHT OUTER JOIN "
		cQuery +=       " ( SELECT "
		cQuery +=              " QPK_PRODUT, "
		cQuery +=              " QPK_REVI, "
		cQuery +=              " R_E_C_N_O_, "
		cQuery +=              " QPK_LAUDO, "
		cQuery +=              " QPK_LOTE, "
		cQuery +=              " QPK_NUMSER, "
		cQuery +=              " QPK_OP "
		cQuery +=       " FROM " + RetSqlName("QPK")
		cQuery +=       " WHERE "
		cQuery +=              " (QPK_FILIAL = '" + xFilial("QPK") +"') "
		cQuery += 			   " AND (R_E_C_N_O_ = " + cValToChar(nRecno) +") "
		cQuery +=              " AND (D_E_L_E_T_ = ' ') "
		cQuery +=       " ) QPK "
		cQuery +=       " INNER JOIN "
		cQuery +=       " (SELECT "
		cQuery +=              " QP8_PRODUT, "
		cQuery +=              " QP8_REVI, "
		cQuery +=              " QP8_ENSAIO, "
		cQuery +=              " QP8_LABOR, "
		cQuery +=              " R_E_C_N_O_, "
		cQuery +=              " QP8_TEXTO, "
		cQuery +=              " QP8_ENSOBR, "
		cQuery +=              " QP8_SEQLAB, "
		cQuery +=              " QP8_CODREC, "
		cQuery +=              " QP8_OPERAC "
		cQuery +=       " FROM " + RetSqlName("QP8")
		cQuery +=       " WHERE "
		cQuery +=                  " (QP8_FILIAL = '" + xFilial("QP8") +"') "

		If !Empty(cOperacao)
			cQuery +=          " AND (QP8_OPERAC = '" + cOperacao +"') " 
		EndIf

		If !Empty(cIDEnsaio)
			cQuery +=          " AND (QP8_ENSAIO = '" + cIDEnsaio +"') " 
		EndIf

		If Self:oAPIManager:lPELaboratoriosRelacionadosAoUsuario
			cQuery +=   Self:oAPIManager:RetornaFiltroPELaboratoriosRelacionadosAoUsuario("QP8_LABOR", cUsuario)
		EndIf

		If !Empty(cLaboratorio)
			cQuery += " AND (QP8_LABOR = '" + cLaboratorio + "') "
		EndIf

		cQuery +=     " AND (D_E_L_E_T_ = ' ') "

		cQuery +=       " ) QP8 ON QP8.QP8_PRODUT = QPK.QPK_PRODUT "
		cQuery +=            " AND QP8.QP8_REVI   = QPK.QPK_REVI "

		cQuery +=       " INNER JOIN "
		cQuery +=         "(SELECT C2_NUM, C2_ITEM, C2_ITEMGRD, C2_SEQUEN, C2_ROTEIRO "
		cQuery +=         " FROM " + RetSQLName("SC2") + " "
		cQuery +=         " WHERE C2_FILIAL = '" + xFilial("SC2") + "' AND D_E_L_E_T_=' ' "
		cQuery += " ) SC2 "
		cQuery +=       " ON " + Self:oQueryManager:MontaRelationC2OP("QPK_OP")
		cQuery +=       Iif(SuperGetMV("MV_QIPOPEP") == "3", " AND (QP8_CODREC = C2_ROTEIRO OR QP8_CODREC = '" + QIPRotGene("QP8_CODREC") + "') ", " AND QP8_CODREC = C2_ROTEIRO ")

		cQuery +=       " LEFT OUTER JOIN "
		cQuery +=		" (SELECT 
		cQuery +=		      " QPR_OP, "
		cQuery +=		      " QPR_PRODUT, "
		cQuery +=		      " QPR_LOTE, "
		cQuery +=		      " QPR_NUMSER, "
		cQuery +=		      " QPR_LABOR, "
		cQuery +=		      " QPR_ENSAIO, "
		cQuery +=		      " QPR_ROTEIR, "
		cQuery +=		      " QPR_OPERAC, "
		cQuery +=		      " MAX(QPR_RESULT) QPR_RESULT "
		cQuery +=		  " FROM " + RetSqlName("QPR")
		cQuery +=		  " WHERE  "
		cQuery +=            " (QPR_FILIAL = '" + xFilial("QPR") + "') "
		cQuery +=        " AND (QPR_OP     = '" + cC2_OP + "') "
		
		If !Empty(cOperacao)
			cQuery +=          " AND (QPR_OPERAC = '" + cOperacao +"') " 
		EndIf

		If Self:oAPIManager:lPELaboratoriosRelacionadosAoUsuario
			cQuery +=   Self:oAPIManager:RetornaFiltroPELaboratoriosRelacionadosAoUsuario("QPR_LABOR", cUsuario)
		EndIf

		If !Empty(cLaboratorio)
			cQuery += " AND (QPR_LABOR = '" + cLaboratorio + "') "
		EndIf

		cQuery +=		            " AND ( D_E_L_E_T_ = ' ' )  "
		cQuery +=		            " AND ( QPR_RESULT IN ('A', 'R')) "
		
		If !lStatus
			cQuery += " AND 1=0 "
		EndIf

		cQuery +=		        " GROUP BY "
		cQuery +=		            " QPR_OP, "
		cQuery +=		            " QPR_PRODUT, "
		cQuery +=		            " QPR_LOTE, "
		cQuery +=		            " QPR_NUMSER, "
		cQuery +=		            " QPR_LABOR, "
		cQuery +=		            " QPR_ENSAIO, "
		cQuery +=		            " QPR_ROTEIR, "
		cQuery +=		            " QPR_OPERAC, "
		cQuery +=		            " QPR_RESULT "
		
		cQuery += 		" ) ENSAIO  "

		//Relaciona por CHAVE_ENSAIO
		cQuery +=      " ON " + Self:oQueryManager:MontaRelationArraysCampos("ENSAIO"     , {"QPR_OP", "QPR_LOTE", "QPR_NUMSER", "QPR_LABOR", "QPR_ENSAIO", "QPR_ROTEIR", "QPR_OPERAC"},;
		                                                                     ""           , {"QPK_OP", "QPK_LOTE", "QPK_NUMSER", "QP8_LABOR", "QP8_ENSAIO", "QP8_CODREC", "QP8_OPERAC"})

		cQuery +=       " LEFT OUTER JOIN "
		cQuery +=       " (SELECT "
		cQuery +=              " QP1_ENSAIO, "
		cQuery +=              " QP1_FILIAL, "
		cQuery +=              " QP1_DESCPO, "
		cQuery +=              " QP1_NIENSR, "
		cQuery +=              " QP1_TIPO "
		cQuery +=       " FROM " + RetSqlName("QP1")
		cQuery +=       " WHERE "
		cQuery +=              " (QP1_FILIAL = '" + xFilial("QP1") + "') AND "
		cQuery +=              " (D_E_L_E_T_ = ' ') " 
		cQuery +=       " ) QP1 ON QP8.QP8_ENSAIO = QP1.QP1_ENSAIO "
		cQuery +=       " ON SX5.X5_CHAVE = QP8.QP8_LABOR"
		
		cQuery +=      " LEFT OUTER JOIN ( "
		cQuery +=       " SELECT QPL_OP, QPL_LOTE, QPL_NUMSER, QPL_ROTEIR, QPL_OPERAC, QPL_LABOR, QPL_LAUDO "
		cQuery +=       " FROM " + RetSqlName("QPL")
		cQuery +=       " WHERE (QPL_FILIAL = '" + xFilial("QPL") +"') " 
		cQuery +=            " AND (QPL_OP     = '" + cC2_OP + "') "

		If !Empty(cOperacao)
			cQuery +=          " AND (QPL_OPERAC = '" + cOperacao +"') " 
		EndIf


		If Self:oAPIManager:lPELaboratoriosRelacionadosAoUsuario
			cQuery +=   Self:oAPIManager:RetornaFiltroPELaboratoriosRelacionadosAoUsuario("QPL_LABOR", cUsuario)
		EndIf

		If !Empty(cLaboratorio)
			cQuery += " AND (QPL_LABOR = '" + cLaboratorio + "') "
		EndIf

		cQuery +=            " AND (D_E_L_E_T_ = ' ') "

		cQuery +=       " ) QPL "
		
		//Relaciona por CHAVE_LABORATORIO
		cQuery +=      " ON " + Self:oQueryManager:MontaRelationArraysCampos("", {"QPK_OP", "QPK_LOTE", "QPK_NUMSER", "QP8_CODREC", "QP8_OPERAC", "QP8_LABOR"},;
		                                                                     "", {"QPL_OP", "QPL_LOTE", "QPL_NUMSER", "QPL_ROTEIR", "QPL_OPERAC", "QPL_LABOR"})

		cQuery += " ) UNIAO "

		cOrdemDB := Self:oAPIManager:RetornaOrdemDB(cOrdem, cTipoOrdem)
		If !Empty(cOrdemDB)
			cQuery += " ORDER BY " + cOrdemDB
		EndIf

		cQuery := Self:oAPIManager:ChangeQueryAllDB(cQuery)
		cAlias := Self:oQueryManager:executeQuery(cQuery)

	End Sequence	
	ErrorBlock(bErrorBlock)

	RestArea(aAreaQPK)

Return cAlias

/*/{Protheus.doc} RetornaLista
Pesquisa Lista de Inspeções de Processo com Base em Texto nos Campos Produto, OP
@author brunno.costa
@since  25/10/2022
@param 01 - nRecno      , numérico, R_E_C_N_O_ para buscar informações da tabela QPK
@param 02 - cOperacao   , numérico, R_E_C_N_O_ para buscar informações da tabela QPK
@param 03 - cLaboratorio, caracter, código do laboratório para filtro
@param 04 - cOrdem      , caracter, ordenação para retornar a listagem dos dados
@param 05 - cTipoOrdem  , caracter, tipo de ordenação para retornar a listagem dos dados (Ascedente ou Decrescente)
@param 06 - nPagina     , numérico, página atual dos dados para consulta
@param 07 - nTamPag     , numérico, tamanho de página padrão com a quantidade de registros para retornar
@param 08 - cCampos     , caracter, campos que deverão estar contidos na mensagem
@param 09 - cIDEnsaio   , caracter, código do ensaio
@param 10 - cUsuario    , caracter, código do usuário consumindo a API
@param 11 - lStatus     , lógico  , indica se retorna o status com base nos registros do banco de dados
@return lRetorno, lógico, indica se conseguiu realizar o processamento
/*/
METHOD RetornaLista(nRecno, cOperacao, cLaboratorio, cOrdem, cTipoOrdem, nPagina, nTamPag, cCampos, cIDEnsaio, cUsuario, lStatus) CLASS EnsaiosInspecaoDeProcessosAPI
     
    Local cAlias      := Nil
    Local lRetorno    := .T.

	Default lStatus   := .T.

	If Self:NaoImplantado()
		SetRestFault(405, EncodeUtf8(STR0004), .T.,; //"Módulo não está implantado"
					 405, EncodeUtf8(STR0005))       //"Fale com a TOTVS e faça implantação do módulo!"
		Return
	EndIf
		
	cAlias := Self:CriaAliasEnsaiosPesquisa(nRecno, cOperacao, cLaboratorio, cOrdem, cTipoOrdem, nPagina, nTamPag, cCampos, cIDEnsaio, cUsuario, lStatus)

	If Empty(Self:oAPIManager:cErrorMessage)
		lRetorno := Self:oAPIManager:ProcessaListaResultados(cAlias, nPagina, nTamPag)
    	(cAlias)->(dbCloseArea())
	Else
		lRetorno := .F.
		SetRestFault(400, EncodeUtf8(Self:oAPIManager:cErrorMessage), .T.,;
		             400, EncodeUtf8(Self:oAPIManager:cDetailedMessage))
	EndIf

Return lRetorno

/*/{Protheus.doc} NaoImplantado
Indica se o Módulo QIP não está implantado
@author brunno.costa
@since  16/08/2022
@return lNaoImplantado, lógico, indica se o módulo QIP não está implantado
/*/
METHOD NaoImplantado() CLASS EnsaiosInspecaoDeProcessosAPI
	Local lNaoImplantado := Nil
	If (AlLTrim(SuperGetMV("MV_QIPMAT", .F., "N")) == "S")
		lNaoImplantado := .F.
	Else
		DbSelectArea("QPK")
		QPK->(DbSetOrder(1))
		QPK->(DbSeek(xFilial("QPK")))
		lNaoImplantado := QPK->(Eof())
	EndIf
Return lNaoImplantado

/*/{Protheus.doc} ModoExibicaoReferencias
Indica o modo de exibição das referencias nominais, LIE e LSE do usuário
@author brunno.costa
@since  26/12/2024
@param 01 - cLogin , caracter, login do usuário para validação das permissões de acesso
@return cRetorno, caracter, indica o modo de acesso do usuário aos resultados das amostras do QIP:
							1 = Exibe referências;
							2 = Oculta referências;
/*/
METHOD ModoExibicaoReferencias(cLogin) CLASS EnsaiosInspecaoDeProcessosAPI
     
    Local cAlias   := Nil
    Local cQuery   := Nil
	Local cRetorno := "1"
	Local lExiste  := !Empty(GetSx3Cache("QAA_VISREF", "X3_TAMANHO"))
	
	If lExiste
		cQuery :=   " SELECT COALESCE( QAA_VISREF, '1') QAA_VISREF "
		cQuery +=   " FROM " + RetSQLName("QAA") + " "
		cQuery +=   " WHERE (D_E_L_E_T_ = ' ') "
		cQuery +=     " AND (QAA_FILIAL = '" + xFilial("QAA") + "') "
		cQuery +=     " AND (UPPER(RTRIM(QAA_LOGIN)) = " + FwQtToChr(AllTrim(Upper(cLogin))) +" ) "

		cAlias := Self:oQueryManager:executeQuery(cQuery)

		If !Empty((cAlias)->QAA_VISREF)
			cRetorno := Alltrim( (cAlias)->QAA_VISREF )
		EndIf
		
		(cAlias)->(dbCloseArea())
	EndIF

Return cRetorno

/*/{Protheus.doc} PossuiFamiliaDeInstrumentos
Indica se possui família de instrumentos relacionada à inspeção, operação e ensaio
@author brunno.costa
@since  12/03/2025
@param 01 - cProduto   , caracter, código do produto
@param 02 - cRevisao   , caracter, revisão do produto
@param 03 - cRoteiro   , caracter, código do roteiro
@param 04 - cOperacao  , caracter, código da operação
@param 05 - cIDEnsaio  , caracter, código do ensaio
@return lExiste, lógico, indica se existe família de instrumentos relacionada à inspeção, operação e ensaio
/*/
METHOD PossuiFamiliaDeInstrumentos(cProduto, cRevisao, cRoteiro, cOperacao, cIDEnsaio) CLASS EnsaiosInspecaoDeProcessosAPI
     
	Local lExiste := .F.

	cProduto  := PadR(cProduto , GetSx3Cache("QQ1_PRODUT", "X3_TAMANHO"))
	cRevisao  := PadR(cRevisao , GetSx3Cache("QQ1_REVI"  , "X3_TAMANHO"))
	cRoteiro  := PadR(cRoteiro , GetSx3Cache("QQ1_ROTEIR", "X3_TAMANHO"))
	cOperacao := PadR(cOperacao, GetSx3Cache("QQ1_OPERAC", "X3_TAMANHO"))
	cIDEnsaio := PadR(cIDEnsaio, GetSx3Cache("QQ1_ENSAIO", "X3_TAMANHO"))

	//QQ1 - 3 - QQ1_FILIAL+QQ1_PRODUT+QQ1_REVI+QQ1_ROTEIR+QQ1_OPERAC+QQ1_ENSAIO+QQ1_INSTR
	DbSelectArea("QQ1")
	QQ1->(DbSetOrder(3))
	If QQ1->(DbSeek(xFilial("QQ1")+cProduto+cRevisao+cRoteiro+cOperacao+cIDEnsaio))
		lExiste := .T.
	EndIf
	QQ1->(dbCloseArea())

Return lExiste


/*/{Protheus.doc} ListaInstrumentosDeMedicao
Retorna a lista de instrumentos de medição vinculados ao ensaio
@author brunno.costa
@since  12/03/2025
@param 01 - cProduto    , caracter, código do produto
@param 02 - cRevisao    , caracter, revisão do produto
@param 03 - cRoteiro    , caracter, código do roteiro
@param 04 - cOperacao   , caracter, código da operação
@param 05 - cIDEnsaio   , caracter, código do ensaio
@param 06 - dDataMedicao, data, data da medição
/*/
METHOD ListaInstrumentosDeMedicao(cProduto, cRevisao, cRoteiro, cOperacao, cIDEnsaio, dDataMedicao) CLASS EnsaiosInspecaoDeProcessosAPI

    Local cAlias        := ""
    Local cMvQlins      := GetMv("MV_QLINS")
    Local cMvQpvlin     := GetMv("MV_QPVLIN")
    Local cQuery        := ""

    // Construção da consulta SQL
    cQuery := "SELECT QM2.QM2_DESCR, QM2.QM2_INSTR, QM2.QM2_REVINS, QM2.QM2_VALDAF "
    cQuery += "FROM " + RetSQLName("QM2") + " QM2 "
    cQuery += "JOIN " + RetSQLName("QQ1") + " QQ1 "
    cQuery += "ON QQ1.QQ1_INSTR = QM2.QM2_TIPO "
    cQuery += "WHERE QM2.D_E_L_E_T_ = ' ' "
    cQuery += "AND QQ1.D_E_L_E_T_ = ' ' "
    cQuery += "AND QM2.QM2_FILIAL = '" + xFilial("QM2") + "' "
	cQuery += "AND QQ1.QQ1_FILIAL = '" + xFilial("QQ1") + "' "
    cQuery += "AND QQ1.QQ1_PRODUT = '" + cProduto + "' "
    cQuery += "AND QQ1.QQ1_REVI   = '" + cRevisao + "' "
    cQuery += "AND QQ1.QQ1_ROTEIR = '" + cRoteiro + "' "
    cQuery += "AND QQ1.QQ1_OPERAC = '" + cOperacao + "' "
    cQuery += "AND QQ1.QQ1_ENSAIO = '" + cIDEnsaio + "' "

    // Aplicar filtros conforme MV_QPVLIN
    If cMvQpvlin == "S"
        If Empty(cMvQlins)
            cMvQlins := "3" // Laudo Aprovado
        EndIf
		cQuery += "AND QM2.QM2_LAUDO IN (" + FormatIn(cMvQlins, "/") + ") "
        cQuery += "AND QM2.QM2_STATUS = 'A' "
        cQuery += "AND QM2.QM2_VALDAF >= '" + DtoS(dDataMedicao) + "' "
    EndIf

    // Execução da consulta
    cAlias := Self:oQueryManager:executeQuery(cQuery)

    // Processamento dos resultados
    If !Empty(cAlias)
		Self:MapeiaCamposListaInstrumento()
        lSucesso := Self:oAPIManager:ProcessaListaResultados(cAlias)
    EndIf

Return 

/*/{Protheus.doc} MapeiaCamposListaInstrumento
Mapeia os Campos Lista de Instrumento de Medição
@author brunno.costa
@since  12/03/2025
@param 01 - cCampos, String, string com os campos [nPosCPS_Titulo_API] para consideração separados por vírgula
@return aMapaCampos, Array , {{lConsidera, Titulo Interface, Título API, Campo Protheus, Tipo, Tamanho, Decimal}, ...}
                             {{nPosCPS_Considera, ..., nPosCPS_Decimal}, ...}
/*/
METHOD MapeiaCamposListaInstrumento() CLASS EnsaiosInspecaoDeProcessosAPI

    Local aMapaCampos := {}

	aadd(aMapaCampos, {.F., "Descricao"       , "description"   , "QM2_DESCR" , "C" , GetSx3Cache("QM2_DESCR" ,"X3_TAMANHO"), 0,})
    aadd(aMapaCampos, {.F., "Codigo"          , "code"          , "QM2_INSTR" , "C" , GetSx3Cache("QM2_INSTR" ,"X3_TAMANHO"), 0,})
	aadd(aMapaCampos, {.F., "Revisao"         , "revision"      , "QM2_REVINS", "C" , GetSx3Cache("QM2_REVINS","X3_TAMANHO"), 0,})
	aadd(aMapaCampos, {.F., "Val.Calibracao"  , "validate"      , "QM2_VALDAF", "D" , GetSx3Cache("QM2_VALDAF","X3_TAMANHO"), 0,})
	
	Self:oAPIManager := QualityAPIManager():New(aMapaCampos, Self:oWSRestFul)
	Self:oAPIManager:MarcaCamposConsiderados("*", aMapaCampos, nPosCPS_Titulo_API)

Return aMapaCampos



