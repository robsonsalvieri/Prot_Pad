#Include "ensaiosinspecaodeentradasapi.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE nPosCPS_Considera                  1
#DEFINE nPosCPS_Titulo_Interface           2
#DEFINE nPosCPS_Titulo_API                 3
#DEFINE nPosCPS_Protheus                   4
#DEFINE nPosCPS_Tipo                       5
#DEFINE nPosCPS_Tamanho                    6
#DEFINE nPosCPS_Decimal                    7
#DEFINE nPosCPS_Alias                      8
#DEFINE nPosCPS_Protheus_Externo           9

/*/{Protheus.doc} incominginspectiontest
API de Ensaio de Inspeção de Entradas - Qualidade
@author brunno.costa
@since  28/10/2024
/*/
WSRESTFUL incominginspectiontest DESCRIPTION STR0001 FORMAT APPLICATION_JSON //"Ensaio de Inspeção de Entradas"

	WSDATA Fields           as STRING  OPTIONAL
	WSDATA IDEnsaio         as STRING  OPTIONAL
	WSDATA Laboratory       as STRING  OPTIONAL
	WSDATA Login            as STRING  OPTIONAL
	WSDATA MeasurementDate  as STRING  OPTIONAL
	WSDATA Order            as STRING  OPTIONAL
	WSDATA OrderType        as STRING  OPTIONAL
	WSDATA Page             as INTEGER OPTIONAL
	WSDATA PageSize         as INTEGER OPTIONAL
	WSDATA ProductID        as STRING  OPTIONAL
	WSDATA Recno            as STRING  OPTIONAL
	WSDATA Revision         as STRING  OPTIONAL
	WSDATA Status           as STRING  OPTIONAL

    WSMETHOD GET list;
    DESCRIPTION STR0002; //"Retorna Lista de Ensaios de Inspeções de Processos"
    WSSYNTAX "api/qie/v1/list/{Recno}/{Order}/{OrderType}/{Page}/{PageSize}" ;
    PATH "/api/qie/v1/list" ;
    TTALK "v1"

	WSMETHOD GET test;
    DESCRIPTION STR0003; //"Retorna um Ensaio da Inspeção de Entradas"
    WSSYNTAX "api/qie/v1/test/{Recno}/{IDEnsaio}" ;
    PATH "/api/qie/v1/test" ;
    TTALK "v1"

	WSMETHOD GET hasmetrologyintegration;
    DESCRIPTION STR0006; //"Indica se está habilitada a integração com o módulo de metrologia"
    WSSYNTAX "api/qie/v1/hasmetrologyintegration" ;
    PATH "/api/qie/v1/hasmetrologyintegration" ;
    TTALK "v1"

	WSMETHOD GET hasafamilyofinstruments;
    DESCRIPTION STR0007; //"Indica existência de relaciomanento de família de instrumentos"
    WSSYNTAX "api/qie/v1/hasafamilyofinstruments/{ProductID}/{Revision}/{IDEnsaio}" ;
    PATH "/api/qie/v1/hasafamilyofinstruments" ;
    TTALK "v1"

	WSMETHOD GET metrologyinstruments;
    DESCRIPTION STR0008; //"Lista instrumentos de metrologia relacionados"
    WSSYNTAX "api/qie/v1/metrologyinstruments/{ProductID}/{Revision}/{IDEnsaio}/{MeasurementDate}" ;
    PATH "/api/qie/v1/metrologyinstruments" ;
    TTALK "v1"

	WSMETHOD GET repeatinstruments;
    DESCRIPTION STR0009; //"Indica se está habilitada repetição de instrumentos da primeira amostra"
    WSSYNTAX "api/qie/v1/repeatinstruments" ;
    PATH "/api/qie/v1/repeatinstruments" ;
    TTALK "v1"

	WSMETHOD GET texttestwithmandatoryinstrument;
    DESCRIPTION STR0010; //"Ensaio de texto com instrumento obrigatório"
    WSSYNTAX "api/qie/v1/texttestwithmandatoryinstrument" ;
    PATH "/api/qie/v1/texttestwithmandatoryinstrument" ;
    TTALK "v1"

ENDWSRESTFUL

WSMETHOD GET list PATHPARAM Recno, Laboratory, Order, OrderType, Page, PageSize QUERYPARAM Fields WSSERVICE incominginspectiontest
    Local oAPIClass  := EnsaiosInspecaoDeEntradasAPI():New(Self)
	Default Self:Fields      := ""
	Default Self:Laboratory  := ""
	Default Self:Login       := ""
	Default Self:Order       := ""
	Default Self:OrderType   := ""
	Default Self:Page        := 1
	Default Self:PageSize    := 5
	Default Self:Recno       := 0
	Default Self:Status      := "true"
	oAPIClass:cEndPoint := "/api/qie/v1/list"
Return oAPIClass:RetornaLista(Self:Recno, Self:Laboratory, Self:Order, Self:OrderType, Self:Page, Self:PageSize, Self:Fields, Nil, Self:Login, Self:Status == "true")

WSMETHOD GET test PATHPARAM Recno, Laboratory, IDEnsaio QUERYPARAM Fields WSSERVICE incominginspectiontest
    Local oAPIClass  := EnsaiosInspecaoDeEntradasAPI():New(Self)
	Default Self:Fields     := ""
	Default Self:IDEnsaio   := ""
	Default Self:Login      := ""
	Default Self:Recno      := 0
	oAPIClass:cEndPoint := "/api/qie/v1/test"
Return oAPIClass:RetornaLista(Self:Recno, Self:Laboratory, "", "", 1, 1, Self:Fields, Self:IDEnsaio, Self:Login)

WSMETHOD GET repeatinstruments PATHPARAM QUERYPARAM Fields WSSERVICE incominginspectiontest
    
	Local oAPIClass  := EnsaiosInspecaoDeEntradasAPI():New(Self)

	oAPIClass:cEndPoint := "/api/qie/v1/repeatinstruments"
	oAPIClass:oAPIManager := QualityAPIManager():New({}, Self)
	oAPIClass:oAPIManager:RespondeValor("result", Iif(GetMv("MV_QPINAUT") == "S", "true", "false"))

Return 

WSMETHOD GET texttestwithmandatoryinstrument PATHPARAM QUERYPARAM Fields WSSERVICE incominginspectiontest
    
	Local oAPIClass  := EnsaiosInspecaoDeProcessosAPI():New(Self)

	oAPIClass:cEndPoint := "/api/qie/v1/texttestwithmandatoryinstrument"
	oAPIClass:oAPIManager := QualityAPIManager():New({}, Self)
	oAPIClass:oAPIManager:RespondeValor("result", Iif(GetMv("MV_QINVLTX") == 1, "true", "false"))

Return 

WSMETHOD GET hasmetrologyintegration PATHPARAM QUERYPARAM Fields WSSERVICE incominginspectiontest
    
	Local oAPIClass  := EnsaiosInspecaoDeEntradasAPI():New(Self)

	oAPIClass:cEndPoint := "/api/qie/v1/hasmetrologyintegration"
	oAPIClass:oAPIManager := QualityAPIManager():New({}, Self)
	oAPIClass:oAPIManager:RespondeValor("result", Iif(AllTrim(Upper(GetMv("MV_QINTQMT"))) == "S", "true", "false"))

Return 

WSMETHOD GET hasafamilyofinstruments PATHPARAM ProductID, Revision, IDEnsaio QUERYPARAM Fields WSSERVICE incominginspectiontest
    
	Local oAPIClass  := EnsaiosInspecaoDeEntradasAPI():New(Self)

	Default Self:IDEnsaio          := ""
	Default Self:ProductID         := ""
	Default Self:Revision          := ""

	oAPIClass:cEndPoint := "/api/qie/v1/hasafamilyofinstruments"
	oAPIClass:oAPIManager := QualityAPIManager():New({}, Self)
	oAPIClass:oAPIManager:RespondeValor("result", oAPIClass:PossuiFamiliaDeInstrumentos(Self:ProductID, Self:Revision, Self:IDEnsaio))

Return 

WSMETHOD GET metrologyinstruments PATHPARAM ProductID, Revision, IDEnsaio, MeasurementDate QUERYPARAM Fields WSSERVICE incominginspectiontest

    Local oAPIClass    := EnsaiosInspecaoDeEntradasAPI():New(Self)
	Local dDataAmostra := Nil

	Default Self:IDEnsaio          := ""
	Default Self:ProductID         := ""
	Default Self:Revision          := ""
	Default Self:MeasurementDate   := ""

	oAPIClass:cEndPoint := "/api/qie/v1/metrologyinstruments"
	
	oAPIClass:oAPIManager := QualityAPIManager():New({}, Self)
	dDataAmostra := oAPIClass:oAPIManager:FormataDado("D", Self:MeasurementDate, "1")

	oAPIClass:ListaInstrumentosDeMedicao(Self:ProductID, Self:Revision, Self:IDEnsaio, dDataAmostra)

Return 

/*/{Protheus.doc} EnsaiosInspecaoDeEntradasAPI
Regras de Negocio - API Ensaios de Inspeção de Entradas
@author brunno.costa
@since  28/10/2024
/*/
CLASS EnsaiosInspecaoDeEntradasAPI FROM LongNameClass
    
	DATA cEndPoint        as STRING
	DATA oAPIManager      as OBJECT
	DATA oQueryManager    as OBJECT
	DATA oWSRestFul       as OBJECT

    METHOD new(oWSRestFul) CONSTRUCTOR
	METHOD CriaAliasEnsaiosPesquisa(nRecno, cLaboratorio, cOrdem, cTipoOrdem, nPagina, nTamPag, cCampos, cIDEnsaio, cUsuario, lStatus)
    METHOD RetornaLista(nRecno, cLaboratorio, cOrdem, cTipoOrdem, nPagina, nTamPag, cCampos, cIDEnsaio, cUsuario, lStatus)
    METHOD PossuiFamiliaDeInstrumentos(cProduto, cRevisao, cIDEnsaio)
	METHOD ListaInstrumentosDeMedicao(cProduto, cRevisao, cIDEnsaio, dDataMedicao)
    
	//Métodos Internos
    METHOD MapeiaCampos(cCampos)
	METHOD MapeiaCamposListaInstrumento()
	METHOD ModoExibicaoReferencias(cLogin)
	METHOD NaoImplantado()

ENDCLASS

METHOD new(oWSRestFul) CLASS EnsaiosInspecaoDeEntradasAPI
	 Self:oWSRestFul    := oWSRestFul
	 Self:oQueryManager := QLTQueryManager():New()
Return Self

/*/{Protheus.doc} MapeiaCampos
Mapeia os Campos
@author brunno.costa
@since  28/10/2024
@param 01 - cCampos, String, string com os campos [nPosCPS_Titulo_API] para consideração separados por vírgula
@return aMapaCampos, Array , {{lConsidera, Titulo Interface, Título API, Campo Protheus, Tipo, Tamanho, Decimal}, ...}
                             {{nPosCPS_Considera, ..., nPosCPS_Decimal}, ...}
/*/
METHOD MapeiaCampos(cCampos) CLASS EnsaiosInspecaoDeEntradasAPI

    Local aMapaCampos := {}

   	aadd(aMapaCampos, {.T., "RecnoInspecao"        , "recnoInspection"     , "RECNOQEK"            , "NN", 0                                      , 0, "QEK"}) //NN para não formatar como número pois não temos certeza do tamanho configurado na tabela do cliente
    aadd(aMapaCampos, {.T., "RecnoEnsaio"          , "recnoTest"           , "RECNOTEST"           , "NN", 0                                      , 0, "QE7QE8"}) //NN para não formatar como número pois não temos certeza do tamanho configurado na tabela do cliente
    aadd(aMapaCampos, {.T., "Ensaio"               , "testID"              , "QE7_ENSAIO"          , "C" , 0                                      , 0, "QE7QE8"}) //NN para não formatar como número pois não temos certeza do tamanho configurado na tabela do cliente
    aadd(aMapaCampos, {.T., "Sequencia"            , "sequence"            , "QE7_SEQLAB"          , "NN", 0                                      , 0, "QE7QE8"}) //NN para não formatar como número pois não temos certeza do tamanho configurado na tabela do cliente
    aadd(aMapaCampos, {.F., "Titulo"               , "title"               , "QE1_DESCPO"          , "C" , GetSx3Cache("QE1_DESCPO" ,"X3_TAMANHO"), 0, "QE1"})
	aadd(aMapaCampos, {.F., "Nível Ensaio"         , "testLevel"           , "QE1_NIENSR"          , "C" , GetSx3Cache("QE1_NIENSR" ,"X3_TAMANHO"), 0, "QE1"})
    aAdd(aMapaCampos, {.F., "QuantidadeMedicoes"   , "numberOfMeasurements", "QE1_QTDE"            , "N" , GetSx3Cache("QE1_QTDE"   ,"X3_TAMANHO"), 0, "QE1"})
	aadd(aMapaCampos, {.F., "Tipo"                 , "type"                , "QE1_TIPO"            , "C" , GetSx3Cache("QE1_TIPO"   ,"X3_TAMANHO"), 0, "QE1"})
    aadd(aMapaCampos, {.F., "Laboratorio"          , "laboratory"          , "X5_DESCRI"           , "C" , GetSx3Cache("X5_DESCRI"  ,"X3_TAMANHO"), 0, "SX5"})
	aadd(aMapaCampos, {.F., "IDLaboratorio"        , "laboratoryID"        , "X5_CHAVE"            , "C" , GetSx3Cache("X5_CHAVE"   ,"X3_TAMANHO"), 0, "SX5"})
    aadd(aMapaCampos, {.F., "EspecificacaoResumida", "summarySpecification", "SUMMARYSPECIFICATION", "C" , 20                                     , 0, "N/A"})
    aadd(aMapaCampos, {.F., "UnidadeDeMedida"      , "lotUnitID"           , "QE7_UNIMED"          , "C" , 2                                      , 0, "N/A"})
    aadd(aMapaCampos, {.F., "TipoDeControle"       , "controlType"         , "CONTROLTYPE"         , "C" , 1                                      , 0, "N/A"})
    aadd(aMapaCampos, {.F., "ValorNominal"         , "nominalValue"        , "QE7_NOMINA"          , "C" , GetSx3Cache("QE7_NOMINA" ,"X3_TAMANHO"), 0, "N/A"})
	aadd(aMapaCampos, {.F., "AfastamentoInferior"  , "lowerDeviation"      , "QE7_LIE"             , "C" , GetSx3Cache("QE7_LIE" ,"X3_TAMANHO")   , 0, "N/A"})
    aadd(aMapaCampos, {.F., "AfastamentoSuperior"  , "upperDeviation"      , "QE7_LSE"             , "C" , GetSx3Cache("QE7_LSE" ,"X3_TAMANHO")   , 0, "N/A"})
    aadd(aMapaCampos, {.T., "TipoEnsaio"           , "testType"            , "TIPO"                , "V" , 1                                      , 0, "N/A"})
	aadd(aMapaCampos, {.T., "LaudoLaboratorio"     , "laboratoryReport"    , "QEL_LAUDO"           , "C" , GetSx3Cache("QEL_LAUDO" ,"X3_TAMANHO") , 0, "QEL"})
	aadd(aMapaCampos, {.T., "ExibeReferencias"     , "displaysReference"   , "QAA_VISREF"          , "L" , 1                                      , 0, "N/A"})
	aadd(aMapaCampos, {.T., "Nível Ensaiador"      , "testerLevel"         , "QAA_NIVEL"           , "C" , 1                                      , 0, "N/A"})
    aadd(aMapaCampos, {.T., "Status"               , "status"              , "STATUS"              , "C" , 1                                      , 0, "N/A"})
	
	Self:oAPIManager := QualityAPIManager():New(aMapaCampos, Self:oWSRestFul)
	Self:oAPIManager:MarcaCamposConsiderados(cCampos, aMapaCampos, nPosCPS_Titulo_API)

Return aMapaCampos


/*/{Protheus.doc} CriaAliasEnsaiosPesquisa
Cria Alias para Pesquisa Lista de Inspeções de Processo com Base em Texto nos Campos Produto, OP
@author brunno.costa
@since  28/10/2024
@param 01 - nRecno      , numérico, R_E_C_N_O_ para buscar informações da tabela QEK
@param 02 - cLaboratorio, caracter, código do laboratório para filtro
@param 03 - cOrdem      , caracter, ordenação para retornar a listagem dos dados
@param 04 - cTipoOrdem  , caracter, tipo de ordenação para retornar a listagem dos dados (Ascedente ou Decrescente)
@param 05 - nPagina     , numérico, página atual dos dados para consulta
@param 06 - nTamPag     , numérico, tamanho de página padrão com a quantidade de registros para retornar
@param 07 - cCampos     , caracter, campos que deverão estar contidos na mensagem
@param 08 - cIDEnsaio   , caracter, código do ensaio
@param 09 - cUsuario    , caracter, código do usuário consumindo a API
@param 10 - lStatus     , lógico  , indica se deve consultar o status dos ensaios
@return cAlias, caracter, alias com os dados da Lista
/*/
METHOD CriaAliasEnsaiosPesquisa(nRecno, cLaboratorio, cOrdem, cTipoOrdem, nPagina, nTamPag, cCampos, cIDEnsaio, cUsuario, lStatus) CLASS EnsaiosInspecaoDeEntradasAPI
	
	Local aAreaQEK    := QEK->(GetArea())
	Local bErrorBlock := ErrorBlock({|e| Self:oAPIManager:ErrorBlock(e, e:Description), Break(e)})
    Local cAlias      := Nil
	Local cNivelUsr   := Posicione("QAA", 6, Upper(cUsuario), "QAA_NIVEL")
	Local cOrdemDB    := Nil
    Local cQuery      := ""
	Local lExibeRef   := Self:ModoExibicaoReferencias(cUsuario) == "1"

	Default lStatus := .T.

	nRecno := Iif(ValType(nRecno) == "C", Val(nRecno), nRecno)
	QEK->(DbGoTo(nRecno))

    Begin Sequence

		Self:MapeiaCampos(cCampos)
		Self:oAPIManager:AvaliaPELaboratoriosRelacionadosAoUsuario("QIE")

		//Ensaios do tipo Numérico
		cQuery +=  " SELECT RECNOQEK, "
		cQuery +=         " RECNOTEST, "
		cQuery +=         " QE7_ENSAIO, "
		cQuery +=         " QE7_SEQLAB, "
		cQuery += 		  " CONTROLTYPE, "
		cQuery += 		  " QE7_NOMINA, "
		cQuery += 		  " QE7_LIE, "
		cQuery += 		  " QE7_LSE, "
		cQuery +=         " QE1_DESCPO, "
		cQuery +=         " QE1_NIENSR, "
		cQuery +=         " QE1_TIPO, "
		cQuery += 		  " QE1_QTDE, "
		cQuery +=         " X5_CHAVE, "
		cQuery +=         " X5_DESCRI, "
		cQuery +=         " SUMMARYSPECIFICATION, "
		cQuery += 		  " QE7_UNIMED, "
		cQuery += 		  " QER_RESULT, "
		cQuery +=         " (CASE COALESCE(QER_RESULT,' ') "
		cQuery += 				" WHEN ' ' "
		cQuery += 				" THEN 'P' " 
		cQuery +=         " ELSE COALESCE(QER_RESULT,' ') "
		cQuery +=         " END ) STATUS, "
		cQuery +=         " COALESCE(QEL_LAUDO, ' ') QEL_LAUDO, "

		If lExibeRef
			cQuery +=         " '.T.' QAA_VISREF, "
		Else
			cQuery +=         " '.F.' QAA_VISREF, "
		EndIf

		cQuery +=         "COALESCE(NULLIF('" + cNivelUsr + "', ''), '00') QAA_NIVEL, "

		cQuery +=         " TIPO "
		cQuery +=  " FROM "
		cQuery +=  " (SELECT "
		cQuery +=      " QEK.R_E_C_N_O_ RECNOQEK, "
		cQuery +=      " QE7.R_E_C_N_O_ RECNOTEST, "
		cQuery +=      " QE7.QE7_ENSAIO, "
		cQuery +=      " QE7.QE7_SEQLAB, "
		cQuery +=      " QE7.CONTROLTYPE, "
		cQuery +=      " QE7.QE7_NOMINA, "
		cQuery +=      " (CASE WHEN QE7.QE7_MINMAX = '1' OR QE7.QE7_MINMAX = '2' THEN QE7.QE7_LIE ELSE 'n/c' END) QE7_LIE, "
		cQuery +=      " (CASE WHEN QE7.QE7_MINMAX = '1' OR QE7.QE7_MINMAX = '3' THEN QE7.QE7_LSE ELSE 'n/c' END) QE7_LSE, "
		cQuery +=      " QE7.QE7_UNIMED, "
		cQuery +=      " COALESCE(QE1.QE1_DESCPO, ' ') QE1_DESCPO, "
		cQuery +=      " COALESCE(NULLIF(QE1.QE1_NIENSR, ''), '00') QE1_NIENSR, "
		cQuery +=      " COALESCE(QE1.QE1_TIPO, ' ') QE1_TIPO, "
		cQuery +=	   " COALESCE(QE1.QE1_QTDE, 1) QE1_QTDE, "
		cQuery +=      " COALESCE(SX5.X5_CHAVE, ' ') X5_CHAVE, "
		cQuery +=      " COALESCE(SX5.X5_DESCRI, ' ') X5_DESCRI, "
		cQuery +=      " CONCAT(CONCAT(( "
		cQuery +=          " CASE "
		cQuery +=              " WHEN QE7.QE7_MINMAX = '2' "                                                                                       // Controla mínimo
		cQuery += 				"	THEN CONCAT(CONCAT(RTRIM(QE7.QE7_NOMINA) , ' ') , RTRIM(QE7.QE7_LIE)) "                                        // Exemplo: 20 -1 cm
		cQuery +=              " WHEN QE7.QE7_MINMAX = '3' "                                                                                       // Controla máximo
		cQuery +=  				"	THEN CONCAT(CONCAT(RTRIM(QE7.QE7_NOMINA) , ' ' ), RTRIM(QE7.QE7_LSE)) "                                        // Exemplo: 20 5 cm
		cQuery +=              " ELSE "                                                                                                            // Controla mínimo e máximo
		cQuery += 				"	CONCAT(CONCAT(CONCAT(CONCAT(RTRIM(QE7.QE7_NOMINA) , ' ' ), RTRIM(QE7.QE7_LIE)) , '/' ), RTRIM(QE7.QE7_LSE))  " // Exemplo: 20 -1/5 cm
		cQuery +=          " END "
		cQuery +=      " ) , ' ') , QE7.QE7_UNIMED) SUMMARYSPECIFICATION, "
		cQuery +=      " QEL_LAUDO, "
		cQuery +=      " QER_RESULT, "
		cQuery +=       "'N' TIPO "
		cQuery +=  " FROM "
		cQuery +=      " (SELECT "
		cQuery +=              " X5_CHAVE, "
		cQuery +=              " X5_DESCRI "
		cQuery +=          " FROM " + RetSqlName("SX5")
		cQuery +=          " WHERE "
		cQuery +=                  " (X5_FILIAL = '" + xFilial("SX5") +"') " 
		cQuery +=              " AND (X5_TABELA = 'Q2') "

		If Self:oAPIManager:lPELaboratoriosRelacionadosAoUsuario
			cQuery +=           Self:oAPIManager:RetornaFiltroPELaboratoriosRelacionadosAoUsuario("X5_CHAVE", cUsuario, "incominginspectiontest/api/qie/v1/list")
		EndIf

		If !Empty(cLaboratorio)
			cQuery +=           " AND (X5_CHAVE = '" + cLaboratorio + "') "
		EndIf

		cQuery +=               " AND (D_E_L_E_T_ = ' ') "

		cQuery +=       " ) SX5 "
		cQuery += 		" RIGHT OUTER JOIN "
		cQuery +=       " ( SELECT	"
		cQuery +=              " R_E_C_N_O_, "
		cQuery +=              " QEK_FORNEC, "
		cQuery +=              " QEK_LOJFOR, "
		cQuery +=              " QEK_PRODUT, "
		cQuery +=              " QEK_REVI, "
		cQuery +=              " QEK_NTFISC, "
		cQuery +=              " QEK_SERINF, "
		cQuery +=              " QEK_ITEMNF, "
		cQuery +=              " QEK_TIPONF, "
		cQuery +=              " QEK_LOTE, "
		cQuery +=              " QEK_NUMSEQ, "
		cQuery +=              " QEK_DTENTR "
		cQuery +=          " FROM	" + RetSqlName("QEK")
		cQuery +=          " WHERE "
		cQuery += 			       " (QEK_FILIAL = '" + xFilial("QEK") +"') " 
		cQuery +=              " AND (R_E_C_N_O_ = " + cValToChar(nRecno) +") " 
		cQuery +=              " AND (D_E_L_E_T_ = ' ') "
		cQuery +=       " ) QEK "
		cQuery +=       " INNER JOIN  "
		cQuery +=       " ( SELECT "
		cQuery +=              " QE7_PRODUT, "
		cQuery +=              " QE7_REVI, "
		cQuery +=              " QE7_ENSAIO, "
		cQuery +=              " QE7_LABOR, "
		cQuery +=              " R_E_C_N_O_, "
		cQuery +=              " QE7_NOMINA, "
		cQuery +=              " QE7_LIE, "
		cQuery +=              " QE7_LSE, "
		cQuery +=              " QE7_UNIMED, "
		cQuery +=              " QE7_MINMAX, "
		cQuery +=              " QE7_SEQLAB, "
		cQuery += 			   " QE7_MINMAX CONTROLTYPE "
		cQuery +=          " FROM " + RetSqlName("QE7")
		cQuery +=          " WHERE "
		cQuery +=                  " (QE7_FILIAL = '" + xFilial("QE7") +"') " 

		If !Empty(cIDEnsaio)
			cQuery +=          " AND (QE7_ENSAIO = '" + cIDEnsaio +"') " 
		EndIf

		If Self:oAPIManager:lPELaboratoriosRelacionadosAoUsuario
			cQuery +=          Self:oAPIManager:RetornaFiltroPELaboratoriosRelacionadosAoUsuario("QE7_LABOR", cUsuario, "incominginspectiontest/api/qie/v1/list")
		EndIf

		If !Empty(cLaboratorio)
			cQuery += " AND (QE7_LABOR = '" + cLaboratorio + "') "
		EndIf

		cQuery +=     " AND (D_E_L_E_T_ = ' ') "

		cQuery +=      	 " ) QE7 ON QE7.QE7_PRODUT = QEK.QEK_PRODUT "
		cQuery +=      		  " AND QE7.QE7_REVI = QEK.QEK_REVI "		

		cQuery +=      	 " LEFT OUTER JOIN "

		cQuery +=		 " (SELECT "
		cQuery +=		        " QER_FORNEC, "
		cQuery +=		        " QER_LOJFOR, "
		cQuery +=		        " QER_PRODUT, "
		cQuery +=		        " QER_REVI, "
		cQuery +=		        " QER_NTFISC, "
		cQuery +=		        " QER_SERINF, "
		cQuery +=		        " QER_ITEMNF, "
		cQuery +=		        " QER_TIPONF, "
		cQuery +=		        " QER_LOTE, "
		cQuery +=		        " QER_NUMSEQ, "
		cQuery +=		        " QER_DTENTR, "
		cQuery +=		        " QER_LABOR, "
		cQuery +=		        " QER_ENSAIO, "
		cQuery +=	    		" MAX(QER_RESULT) QER_RESULT "
		cQuery +=	      " FROM " + RetSqlName("QER")
		cQuery +=		      " WHERE  "
		cQuery +=    	                " (QER_FILIAL = '" + xFilial("QER")  + "') "
		cQuery +=                   " AND (QER_FORNEC = '" + QEK->QEK_FORNEC + "')"
		cQuery +=                   " AND (QER_LOJFOR = '" + QEK->QEK_LOJFOR + "')"
		cQuery +=                   " AND (QER_PRODUT = '" + QEK->QEK_PRODUT + "')"
		cQuery +=                   " AND (QER_REVI   = '" + QEK->QEK_REVI   + "')"
		cQuery +=                   " AND (QER_NTFISC = '" + QEK->QEK_NTFISC + "')"
		cQuery +=                   " AND (QER_SERINF = '" + QEK->QEK_SERINF + "')"
		cQuery +=                   " AND (QER_ITEMNF = '" + QEK->QEK_ITEMNF + "')"
		cQuery +=                   " AND (QER_TIPONF = '" + QEK->QEK_TIPONF + "')"
		cQuery +=                   " AND (QER_LOTE   = '" + QEK->QEK_LOTE   + "')"

		If QIEReinsp()
			cQuery +=                 " AND (QER_NUMSEQ = '" + QEK->QEK_NUMSEQ + "')"
		EndIf

		cQuery +=                     " AND (QER_DTENTR = '" + DtoS(QEK->QEK_DTENTR) + "')"
		
		If Self:oAPIManager:lPELaboratoriosRelacionadosAoUsuario
			cQuery +=           Self:oAPIManager:RetornaFiltroPELaboratoriosRelacionadosAoUsuario("QER_LABOR", cUsuario, "incominginspectiontest/api/qie/v1/list")
		EndIf

		If !Empty(cLaboratorio)
			cQuery += " AND (QER_LABOR = '" + cLaboratorio + "') "
		EndIf
		
		cQuery += 	  " AND (D_E_L_E_T_ = ' ') "

		If !lStatus
			cQuery += " AND 1=0 "
		EndIf

		cQuery +=     " GROUP BY "	
		cQuery +=             " QER_FORNEC, "
		cQuery +=             " QER_LOJFOR, "
		cQuery +=             " QER_PRODUT, "
		cQuery +=             " QER_REVI, "
		cQuery +=             " QER_NTFISC, "
		cQuery +=             " QER_SERINF, "
		cQuery +=             " QER_ITEMNF, "
		cQuery +=             " QER_TIPONF, "
		cQuery +=             " QER_LOTE, "
		cQuery +=             " QER_NUMSEQ, "
		cQuery +=             " QER_DTENTR, "
		cQuery +=             " QER_LABOR, "
		cQuery +=             " QER_ENSAIO "
		
		cQuery +=          " ) ENSAIO "

		//Relaciona por CHAVE_ENSAIO
		cQuery +=          " ON " + Self:oQueryManager:MontaRelationArraysCampos("ENSAIO", {"QER_FORNEC", "QER_LOJFOR", "QER_PRODUT", "QER_REVI", "QER_NTFISC", "QER_SERINF", "QER_ITEMNF", "QER_TIPONF",;
																					        "QER_LOTE", "QER_DTENTR", "QER_LABOR", "QER_ENSAIO"},;
		                                                                         ""     , {"QEK_FORNEC", "QEK_LOJFOR", "QEK_PRODUT", "QEK_REVI" , "QEK_NTFISC", "QEK_SERINF", "QEK_ITEMNF", "QEK_TIPONF",;
																				 	       "QEK_LOTE", "QEK_DTENTR", "QE7_LABOR", "QE7_ENSAIO"})

		If QIEReinsp()
			cQuery += " AND QEK_NUMSEQ = ENSAIO.QER_NUMSEQ "
		EndIf

		cQuery +=      " LEFT OUTER JOIN ( "
		cQuery +=      " SELECT "
		cQuery +=           " QE1_ENSAIO, "
		cQuery +=           " QE1_FILIAL, "
		cQuery += 		    " (CASE QE1_CARTA "
		cQuery +=           " WHEN 'XBR' THEN QE1_QTDE "
		cQuery +=           " WHEN 'XBS' THEN QE1_QTDE "
		cQuery +=           " WHEN 'XMR' THEN QE1_QTDE "
		cQuery +=           " WHEN 'HIS' THEN QE1_QTDE "
		cQuery +=           " WHEN 'NP ' THEN QE1_QTDE "
		cQuery +=           " WHEN 'P  ' THEN 3 "
		cQuery +=           " WHEN 'U  ' THEN 2 "
		cQuery +=           " ELSE 1 "
		cQuery +=           " END) QE1_QTDE, "
		cQuery +=           " QE1_DESCPO, "
		cQuery +=           " QE1_NIENSR, "
		cQuery +=           " QE1_TIPO "
		cQuery +=      " FROM " + RetSqlName("QE1")
		cQuery +=      " WHERE "
		cQuery +=               " (QE1_FILIAL = '" + xFilial("QE1") +"') "
		cQuery +=           " AND (D_E_L_E_T_ = ' ') " 
		cQuery +=      		" ) QE1 ON QE7.QE7_ENSAIO = QE1.QE1_ENSAIO "
		cQuery += 	   " ON SX5.X5_CHAVE = QE7.QE7_LABOR "	

		cQuery +=      " LEFT OUTER JOIN ( "
		cQuery +=       " SELECT QEL_FORNEC, QEL_LOJFOR, QEL_PRODUT, QEL_REVI, QEL_NTFISC, QEL_SERINF, QEL_ITEMNF, QEL_TIPONF, QEL_LOTE, QEL_NUMSEQ, QEL_DTENTR, QEL_LABOR, QEL_LAUDO "
		cQuery +=       " FROM " + RetSqlName("QEL")
		cQuery +=       " WHERE  "
		cQuery +=             " (QEL_FILIAL = '" + xFilial("QEL") +"') " 
		cQuery +=         " AND (QEL_FORNEC = '" + QEK->QEK_FORNEC + "')"
		cQuery +=         " AND (QEL_LOJFOR = '" + QEK->QEK_LOJFOR + "')"
		cQuery +=         " AND (QEL_PRODUT = '" + QEK->QEK_PRODUT + "')"
		cQuery +=         " AND (QEL_REVI   = '" + QEK->QEK_REVI   + "')"
		cQuery +=         " AND (QEL_NTFISC = '" + QEK->QEK_NTFISC + "')"
		cQuery +=         " AND (QEL_SERINF = '" + QEK->QEK_SERINF + "')"
		cQuery +=         " AND (QEL_ITEMNF = '" + QEK->QEK_ITEMNF + "')"
		cQuery +=         " AND (QEL_TIPONF = '" + QEK->QEK_TIPONF + "')"
		cQuery +=         " AND (QEL_LOTE   = '" + QEK->QEK_LOTE   + "')"

		If QIEReinsp()
			cQuery +=     " AND (QEL_NUMSEQ = '" + QEK->QEK_NUMSEQ + "')"
		EndIf

		cQuery +=         " AND (QEL_DTENTR = '" + DtoS(QEK->QEK_DTENTR) + "')"
		

		If Self:oAPIManager:lPELaboratoriosRelacionadosAoUsuario
			cQuery +=   Self:oAPIManager:RetornaFiltroPELaboratoriosRelacionadosAoUsuario("QEL_LABOR", cUsuario, "incominginspectiontest/api/qie/v1/list")
		EndIf

		If !Empty(cLaboratorio)
			cQuery += " AND (QEL_LABOR = '" + cLaboratorio + "') "
		Else
			cQuery += " AND (QEL_LABOR <> ' ') "
		EndIf

		cQuery +=     " AND (D_E_L_E_T_ = ' ') " 

		cQuery +=       " ) QEL "
		
		//Relaciona por CHAVE_LABORATORIO
		cQuery +=          " ON " + Self:oQueryManager:MontaRelationArraysCampos("", {"QEL_FORNEC", "QEL_LOJFOR", "QEL_PRODUT", "QEL_REVI", "QEL_NTFISC", "QEL_SERINF", "QEL_ITEMNF", "QEL_TIPONF",;
																					  "QEL_LOTE", "QEL_DTENTR", "QEL_LABOR"},;
		                                                                         "", {"QEK_FORNEC", "QEK_LOJFOR", "QEK_PRODUT", "QEK_REVI" , "QEK_NTFISC", "QEK_SERINF", "QEK_ITEMNF", "QEK_TIPONF",;
																				 	  "QEK_LOTE", "QEK_DTENTR", "QE7_LABOR"})
		
		If QIEReinsp()
			cQuery += " AND QEL_NUMSEQ = QEK_NUMSEQ "
		EndIf

		cQuery +=  " UNION "

		// Ensaios do tipo TEXTO
		cQuery +=  " SELECT "
		cQuery +=      " QEK.R_E_C_N_O_ RECNOQEK, "
		cQuery +=      " QE8.R_E_C_N_O_ RECNOTEST, "
		cQuery +=      " QE8.QE8_ENSAIO, "
		cQuery +=      " QE8.QE8_SEQLAB, "
		cQuery +=      " ' ' CONTROLTYPE, "
		cQuery +=      " ' ' QE7_NOMINA, "
		cQuery +=      " ' ' QE7_LIE, "
		cQuery +=      " ' ' QE7_LSE, "
		cQuery +=      " ' ' QE7_UNIMED, "
		cQuery +=      " COALESCE(QE1.QE1_DESCPO, ' ') QE1_DESCPO, "
		cQuery +=      " COALESCE(NULLIF(QE1.QE1_NIENSR, ''), '00') QE1_NIENSR, "
		cQuery +=      " COALESCE(QE1.QE1_TIPO, ' ') QE1_TIPO, "
		cQuery +=      " 1 QE1_QTDE, "
		cQuery +=      " COALESCE(SX5.X5_CHAVE, ' ') X5_CHAVE, "
		cQuery +=      " COALESCE(SX5.X5_DESCRI, ' ') X5_DESCRI, "
		cQuery +=      " QE8.QE8_TEXTO SUMMARYSPECIFICATION,	"
		cQuery +=      " QEL_LAUDO, "
		cQuery +=      " QER_RESULT, "
		cQuery +=      " 'T' TIPO "
		cQuery +=  " FROM "
		cQuery +=      " ( SELECT "
		cQuery +=              " X5_CHAVE, "
		cQuery +=              " X5_DESCRI "
		cQuery +=       " FROM " + RetSqlName("SX5")
		cQuery +=       " WHERE "
		cQuery +=                  " (X5_FILIAL = '" + xFilial("SX5") + "') " 
		cQuery +=              " AND (X5_TABELA = 'Q2') "
		
		If Self:oAPIManager:lPELaboratoriosRelacionadosAoUsuario
			cQuery +=   Self:oAPIManager:RetornaFiltroPELaboratoriosRelacionadosAoUsuario("X5_CHAVE", cUsuario, "incominginspectiontest/api/qie/v1/list")
		EndIf

		If !Empty(cLaboratorio)
			cQuery += " AND (X5_CHAVE = '" + cLaboratorio + "') "
		EndIf

		cQuery +=     " AND (D_E_L_E_T_ = ' ') "

		cQuery +=       " ) SX5 "
		cQuery +=       " RIGHT OUTER JOIN "
		cQuery +=       " ( SELECT "
		cQuery +=              " R_E_C_N_O_, "
		cQuery +=              " QEK_FORNEC, "
		cQuery +=              " QEK_LOJFOR, "
		cQuery +=              " QEK_PRODUT, "
		cQuery +=              " QEK_REVI, "
		cQuery +=              " QEK_NTFISC, "
		cQuery +=              " QEK_SERINF, "
		cQuery +=              " QEK_ITEMNF, "
		cQuery +=              " QEK_TIPONF, "
		cQuery +=              " QEK_LOTE, "
		cQuery +=              " QEK_NUMSEQ, "
		cQuery +=              " QEK_DTENTR "

		cQuery +=       " FROM " + RetSqlName("QEK")
		cQuery +=       " WHERE "
		cQuery += 			       " (QEK_FILIAL = '" + xFilial("QEK") +"') "
		cQuery +=              " AND (R_E_C_N_O_ = " + cValToChar(nRecno) +") "
		cQuery +=              " AND (D_E_L_E_T_ = ' ') "
		cQuery +=       " ) QEK "
		cQuery +=       " INNER JOIN "
		cQuery +=       " (SELECT "
		cQuery +=              " QE8_PRODUT, "
		cQuery +=              " QE8_REVI, "
		cQuery +=              " QE8_ENSAIO, "
		cQuery +=              " QE8_LABOR, "
		cQuery +=              " R_E_C_N_O_, "
		cQuery +=              " QE8_TEXTO, "
		cQuery +=              " QE8_SEQLAB "
		cQuery +=       " FROM " + RetSqlName("QE8")
		cQuery +=       " WHERE "
		cQuery +=                  " (QE8_FILIAL = '" + xFilial("QE8") +"') "

		If !Empty(cIDEnsaio)
			cQuery +=          " AND (QE8_ENSAIO = '" + cIDEnsaio +"') " 
		EndIf

		If Self:oAPIManager:lPELaboratoriosRelacionadosAoUsuario
			cQuery +=   Self:oAPIManager:RetornaFiltroPELaboratoriosRelacionadosAoUsuario("QE8_LABOR", cUsuario, "incominginspectiontest/api/qie/v1/list")
		EndIf

		If !Empty(cLaboratorio)
			cQuery += " AND (QE8_LABOR = '" + cLaboratorio + "') "
		EndIf

		cQuery +=     " AND (D_E_L_E_T_ = ' ') "

		cQuery +=       " ) QE8 ON QE8.QE8_PRODUT = QEK.QEK_PRODUT "
		cQuery +=            " AND QE8.QE8_REVI = QEK.QEK_REVI "

		cQuery +=       " LEFT OUTER JOIN "
		
		cQuery +=		 " (SELECT "
		cQuery +=		        " QER_FORNEC, "
		cQuery +=		        " QER_LOJFOR, "
		cQuery +=		        " QER_PRODUT, "
		cQuery +=		        " QER_REVI, "
		cQuery +=		        " QER_NTFISC, "
		cQuery +=		        " QER_SERINF, "
		cQuery +=		        " QER_ITEMNF, "
		cQuery +=		        " QER_TIPONF, "
		cQuery +=		        " QER_LOTE, "
		cQuery +=		        " QER_NUMSEQ, "
		cQuery +=		        " QER_DTENTR, "
		cQuery +=		        " QER_LABOR, "
		cQuery +=		        " QER_ENSAIO, "
		cQuery +=	    		" MAX(QER_RESULT) QER_RESULT "
		cQuery +=	      " FROM " + RetSqlName("QER")
		cQuery +=		      " WHERE  "
		cQuery +=    	      " (QER_FILIAL = '" + xFilial("QER")  + "') "
		cQuery +=                   " AND (QER_FORNEC = '" + QEK->QEK_FORNEC + "')"
		cQuery +=                   " AND (QER_LOJFOR = '" + QEK->QEK_LOJFOR + "')"
		cQuery +=                   " AND (QER_PRODUT = '" + QEK->QEK_PRODUT + "')"
		cQuery +=                   " AND (QER_REVI   = '" + QEK->QEK_REVI   + "')"
		cQuery +=                   " AND (QER_NTFISC = '" + QEK->QEK_NTFISC + "')"
		cQuery +=                   " AND (QER_SERINF = '" + QEK->QEK_SERINF + "')"
		cQuery +=                   " AND (QER_ITEMNF = '" + QEK->QEK_ITEMNF + "')"
		cQuery +=                   " AND (QER_TIPONF = '" + QEK->QEK_TIPONF + "')"
		cQuery +=                   " AND (QER_LOTE   = '" + QEK->QEK_LOTE   + "')"

		If QIEReinsp()
			cQuery +=                 " AND (QER_NUMSEQ = '" + QEK->QEK_NUMSEQ + "')"
		EndIf

		cQuery +=                     " AND (QER_DTENTR = '" + DtoS(QEK->QEK_DTENTR) + "')"
		
		If Self:oAPIManager:lPELaboratoriosRelacionadosAoUsuario
			cQuery +=           Self:oAPIManager:RetornaFiltroPELaboratoriosRelacionadosAoUsuario("QER_LABOR", cUsuario, "incominginspectiontest/api/qie/v1/list")
		EndIf

		If !Empty(cLaboratorio)
			cQuery += " AND (QER_LABOR = '" + cLaboratorio + "') "
		EndIf
		
		cQuery += 	  " AND (D_E_L_E_T_ = ' ') "

		If !lStatus
			cQuery += " AND 1=0 "
		EndIf

		cQuery +=     " GROUP BY "	
		cQuery +=             " QER_FORNEC, "
		cQuery +=             " QER_LOJFOR, "
		cQuery +=             " QER_PRODUT, "
		cQuery +=             " QER_REVI, "
		cQuery +=             " QER_NTFISC, "
		cQuery +=             " QER_SERINF, "
		cQuery +=             " QER_ITEMNF, "
		cQuery +=             " QER_TIPONF, "
		cQuery +=             " QER_LOTE, "
		cQuery +=             " QER_NUMSEQ, "
		cQuery +=             " QER_DTENTR, "
		cQuery +=             " QER_LABOR, "
		cQuery +=             " QER_ENSAIO "
		
		cQuery +=          " ) ENSAIO "

		//Relaciona por CHAVE_ENSAIO
		cQuery +=          " ON " + Self:oQueryManager:MontaRelationArraysCampos("ENSAIO", {"QER_FORNEC", "QER_LOJFOR", "QER_PRODUT", "QER_REVI", "QER_NTFISC", "QER_SERINF", "QER_ITEMNF", "QER_TIPONF",;
																					        "QER_LOTE", "QER_DTENTR", "QER_LABOR", "QER_ENSAIO"},;
		                                                                         ""      , {"QEK_FORNEC", "QEK_LOJFOR", "QEK_PRODUT", "QEK_REVI" , "QEK_NTFISC", "QEK_SERINF", "QEK_ITEMNF", "QEK_TIPONF",;
																				 	        "QEK_LOTE", "QEK_DTENTR", "QE8_LABOR", "QE8_ENSAIO"})
		If QIEReinsp()
			cQuery += " AND ENSAIO.QER_NUMSEQ = QEK_NUMSEQ "
		EndIf

		cQuery +=       " LEFT OUTER JOIN "
		cQuery +=       " (SELECT "
		cQuery +=              " QE1_ENSAIO, "
		cQuery +=              " QE1_FILIAL, "
		cQuery +=              " QE1_DESCPO, "
		cQuery +=              " QE1_NIENSR, "
		cQuery +=              " QE1_TIPO "
		cQuery +=       " FROM " + RetSqlName("QE1")
		cQuery +=       " WHERE "
		cQuery +=                  " (QE1_FILIAL = '" + xFilial("QE1") + "') " 
		cQuery +=              " AND (D_E_L_E_T_ = ' ') " 
		cQuery +=       " ) QE1 ON QE8.QE8_ENSAIO = QE1.QE1_ENSAIO "
		cQuery +=       " ON SX5.X5_CHAVE = QE8.QE8_LABOR"
		
		cQuery +=      " LEFT OUTER JOIN ( "
		cQuery +=       " SELECT QEL_FORNEC, QEL_LOJFOR, QEL_PRODUT, QEL_REVI, QEL_NTFISC, QEL_SERINF, QEL_ITEMNF, QEL_TIPONF, QEL_LOTE, QEL_NUMSEQ, QEL_DTENTR, QEL_LABOR, QEL_LAUDO "
		cQuery +=       " FROM " + RetSqlName("QEL")
		cQuery +=       " WHERE "
		cQuery +=             " (QEL_FILIAL = '" + xFilial("QEL") +"') " 
		cQuery +=         " AND (QEL_FORNEC = '" + QEK->QEK_FORNEC + "')"
		cQuery +=         " AND (QEL_LOJFOR = '" + QEK->QEK_LOJFOR + "')"
		cQuery +=         " AND (QEL_PRODUT = '" + QEK->QEK_PRODUT + "')"
		cQuery +=         " AND (QEL_REVI   = '" + QEK->QEK_REVI   + "')"
		cQuery +=         " AND (QEL_NTFISC = '" + QEK->QEK_NTFISC + "')"
		cQuery +=         " AND (QEL_SERINF = '" + QEK->QEK_SERINF + "')"
		cQuery +=         " AND (QEL_ITEMNF = '" + QEK->QEK_ITEMNF + "')"
		cQuery +=         " AND (QEL_TIPONF = '" + QEK->QEK_TIPONF + "')"
		cQuery +=         " AND (QEL_LOTE   = '" + QEK->QEK_LOTE   + "')"

		If QIEReinsp()
			cQuery +=     " AND (QEL_NUMSEQ = '" + QEK->QEK_NUMSEQ + "')"
		EndIf

		cQuery +=         " AND (QEL_DTENTR = '" + DtoS(QEK->QEK_DTENTR) + "')"

		If Self:oAPIManager:lPELaboratoriosRelacionadosAoUsuario
			cQuery +=   Self:oAPIManager:RetornaFiltroPELaboratoriosRelacionadosAoUsuario("QEL_LABOR", cUsuario, "incominginspectiontest/api/qie/v1/list")
		EndIf

		If !Empty(cLaboratorio)
			cQuery += " AND (QEL_LABOR = '" + cLaboratorio + "') "
		Else
			cQuery += " AND (QEL_LABOR <> ' ') "
		EndIf

		cQuery +=     " AND (D_E_L_E_T_ = ' ') "

		cQuery +=       " ) QEL "
		
		//Relaciona por CHAVE_LABORATORIO
		cQuery +=          " ON " + Self:oQueryManager:MontaRelationArraysCampos("", {"QEL_FORNEC", "QEL_LOJFOR", "QEL_PRODUT", "QEL_REVI", "QEL_NTFISC", "QEL_SERINF", "QEL_ITEMNF", "QEL_TIPONF",;
																					  "QEL_LOTE"  , "QEL_DTENTR", "QEL_LABOR"},;
		                                                                         "", {"QEK_FORNEC", "QEK_LOJFOR", "QEK_PRODUT", "QEK_REVI" , "QEK_NTFISC", "QEK_SERINF", "QEK_ITEMNF", "QEK_TIPONF",;
  																				 	  "QEK_LOTE"  , "QEK_DTENTR", "QE8_LABOR"})

		If QIEReinsp()
			cQuery += " AND QEL_NUMSEQ = QEK_NUMSEQ "
		EndIf

		cQuery += " ) UNIAO "

		cOrdemDB := Self:oAPIManager:RetornaOrdemDB(cOrdem, cTipoOrdem)
		If !Empty(cOrdemDB)
			cQuery += " ORDER BY " + cOrdemDB
		EndIf

		cQuery := Self:oAPIManager:ChangeQueryAllDB(cQuery)
		cAlias := Self:oQueryManager:executeQuery(cQuery)

	End Sequence	
	ErrorBlock(bErrorBlock)

	RestArea(aAreaQEK)

Return cAlias

/*/{Protheus.doc} PossuiFamiliaDeInstrumentos
Indica se possui família de instrumentos relacionada à inspeção e ensaio
@author brunno.costa / rafael.kleestadt
@since  25/04/2025
@param 01 - cProduto   , caracter, código do produto
@param 02 - cRevisao   , caracter, revisão do produto
@param 05 - cIDEnsaio  , caracter, código do ensaio
@return !Empty(cAlias), lógico, indica se existe família de instrumentos relacionada à inspeção e ensaio
/*/
METHOD PossuiFamiliaDeInstrumentos(cProduto, cRevisao, cIDEnsaio) CLASS EnsaiosInspecaoDeEntradasAPI
    
	Local cAlias  := ""
	Local cQuery  := ""
	Local lExiste := .F.

	cQuery += " SELECT QE7.R_E_C_N_O_ "
	cQuery +=   " FROM " + RetSQLName("QE7") + " QE7 "
	cQuery +=  " WHERE QE7.QE7_FILIAL = '" + xFilial("QE7") + "' "
	cQuery +=    " AND QE7.QE7_PRODUT = '" + cProduto + "' "
	cQuery +=    " AND QE7.QE7_REVI   = '" + cRevisao + "' "
	cQuery +=    " AND QE7.QE7_ENSAIO = '" + cIDEnsaio + "' "
	cQuery +=    " AND QE7.QE7_TIPO  <> '" + Space(GetSx3Cache("QE7_TIPO", "X3_TAMANHO")) + "' "
	cQuery +=    " AND QE7.D_E_L_E_T_ = ' ' "

	cQuery +=  " UNION "

	cQuery += " SELECT QE8.R_E_C_N_O_ "
	cQuery +=   " FROM " + RetSQLName("QE8") + " QE8 "
	cQuery +=  " WHERE QE8.QE8_FILIAL = '" + xFilial("QE8") + "' "
	cQuery +=    " AND QE8.QE8_PRODUT = '" + cProduto + "' "
	cQuery +=    " AND QE8.QE8_REVI   = '" + cRevisao + "' "
	cQuery +=    " AND QE8.QE8_ENSAIO = '" + cIDEnsaio + "' "
	cQuery +=    " AND QE8.QE8_TIPO  <> '" + Space(GetSx3Cache("QE8_TIPO", "X3_TAMANHO")) + "' "
	cQuery +=    " AND QE8.D_E_L_E_T_ = ' ' "

	// Execução da consulta
    cAlias := Self:oQueryManager:executeQuery(cQuery)

	If !(cAlias)->(Eof())
		lExiste := .T.
	EndIf

	(cAlias)->(DbCloseArea())

Return lExiste

/*/{Protheus.doc} ListaInstrumentosDeMedicao
Retorna a lista de instrumentos de medição vinculados ao ensaio
@author brunno.costa / rafael.kleestadt
@since  25/04/2025
@param 01 - cProduto    , caracter, código do produto
@param 02 - cRevisao    , caracter, revisão do produto
@param 05 - cIDEnsaio   , caracter, código do ensaio
@param 06 - dDataMedicao, data, data da medição
/*/
METHOD ListaInstrumentosDeMedicao(cProduto, cRevisao, cIDEnsaio, dDataMedicao) CLASS EnsaiosInspecaoDeEntradasAPI

    Local cAlias          := ""
	Local cDataCalibracao := DtoS(dDataMedicao)
    Local cMvQlins        := GetMv("MV_QLINS")
    Local cMvQpvlin       := GetMv("MV_QPVLIN")
    Local cQuery          := ""

	cQuery := " SELECT QM2.QM2_DESCR, QM2.QM2_INSTR, QM2.QM2_REVINS, QM2.QM2_VALDAF "
	cQuery +=   " FROM " + RetSQLName("QM2") + " QM2 "
	cQuery +=   " JOIN " + RetSQLName("QE7") + " QE7 "
	cQuery +=     " ON QE7.QE7_TIPO = QM2.QM2_TIPO "
	cQuery +=  " WHERE QM2.QM2_FILIAL = '" + xFilial("QM2") + "' "
	cQuery +=    " AND QE7.QE7_FILIAL = '" + xFilial("QE7") + "' "
	cQuery +=    " AND QE7.QE7_PRODUT = '" + cProduto + "' "
	cQuery +=    " AND QE7.QE7_REVI   = '" + cRevisao + "' "
	cQuery +=    " AND QE7.QE7_ENSAIO = '" + cIDEnsaio + "' "
	cQuery +=    " AND QE7.QE7_TIPO   <> '" + Space(GetSx3Cache("QE7_TIPO", "X3_TAMANHO")) + "' "
	
	// Aplicar filtros conforme MV_QPVLIN
    If cMvQpvlin == "S"
        If Empty(cMvQlins)
            cMvQlins := "3" // Laudo Aprovado
        EndIf
		cQuery += "AND QM2.QM2_LAUDO IN (" + FormatIn(cMvQlins, "/") + ") "
        cQuery += "AND QM2.QM2_STATUS = 'A' "
        cQuery += "AND QM2.QM2_VALDAF >= '" + cDataCalibracao + "' "
    EndIf
	
	cQuery +=    " AND QM2.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND QE7.D_E_L_E_T_ = ' ' "
	
	cQuery +=  " UNION "

	cQuery += " SELECT QM2.QM2_DESCR, QM2.QM2_INSTR, QM2.QM2_REVINS, QM2.QM2_VALDAF "
	cQuery +=   " FROM " + RetSQLName("QM2") + " QM2 "
	cQuery +=   " JOIN " + RetSQLName("QE8") + " QE8 "
	cQuery +=     " ON QE8.QE8_TIPO = QM2.QM2_TIPO "
	cQuery +=  " WHERE QM2.QM2_FILIAL = '" + xFilial("QM2") + "' "
	cQuery +=    " AND QE8.QE8_FILIAL = '" + xFilial("QE8") + "' "
	cQuery +=    " AND QE8.QE8_PRODUT = '" + cProduto + "' "
	cQuery +=    " AND QE8.QE8_REVI   = '" + cRevisao + "' "
	cQuery +=    " AND QE8.QE8_ENSAIO = '" + cIDEnsaio + "' "
	cQuery +=    " AND QE8.QE8_TIPO   <> '" + Space(GetSx3Cache("QE8_TIPO", "X3_TAMANHO")) + "' "
	
	// Aplicar filtros conforme MV_QPVLIN
    If cMvQpvlin == "S"
		cQuery += "AND QM2.QM2_LAUDO IN (" + FormatIn(cMvQlins, "/") + ") "
        cQuery += "AND QM2.QM2_STATUS = 'A' "
        cQuery += "AND QM2.QM2_VALDAF >= '" + cDataCalibracao + "' "
    EndIf

	cQuery +=    " AND QM2.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND QE8.D_E_L_E_T_ = ' ' "

    // Execução da consulta
    cAlias := Self:oQueryManager:executeQuery(cQuery)

    // Processamento dos resultados
    If !Empty(cAlias)
		Self:MapeiaCamposListaInstrumento()
        lSucesso := Self:oAPIManager:ProcessaListaResultados(cAlias)
    EndIf

	(cAlias)->(DbCloseArea())

Return

/*/{Protheus.doc} RetornaLista
Pesquisa Lista de Inspeções de Processo com Base em Texto nos Campos Produto, OP
@author brunno.costa
@since  28/10/2024
@param 01 - nRecno      , numérico, R_E_C_N_O_ para buscar informações da tabela QEK
@param 02 - cLaboratorio, caracter, código do laboratório para filtro
@param 03 - cOrdem      , caracter, ordenação para retornar a listagem dos dados
@param 04 - cTipoOrdem  , caracter, tipo de ordenação para retornar a listagem dos dados (Ascedente ou Decrescente)
@param 05 - nPagina     , numérico, página atual dos dados para consulta
@param 06 - nTamPag     , numérico, tamanho de página padrão com a quantidade de registros para retornar
@param 07 - cCampos     , caracter, campos que deverão estar contidos na mensagem
@param 08 - cIDEnsaio   , caracter, código do ensaio
@param 09 - cUsuario    , caracter, código do usuário consumindo a API
@param 10 - lStatus     , lógico, indica se deve consultar o status dos ensaios
@return lRetorno, lógico, indica se conseguiu realizar o processamento
/*/
METHOD RetornaLista(nRecno, cLaboratorio, cOrdem, cTipoOrdem, nPagina, nTamPag, cCampos, cIDEnsaio, cUsuario, lStatus) CLASS EnsaiosInspecaoDeEntradasAPI
     
    Local cAlias      := Nil
    Local lRetorno    := .T.

	If Self:NaoImplantado()
		SetRestFault(405, EncodeUtf8(STR0004), .T.,; //"Módulo não está implantado"
					 405, EncodeUtf8(STR0005)) //"Fale com a TOTVS e faça implantação do módulo!"
		Return
	EndIf
		
	cAlias := Self:CriaAliasEnsaiosPesquisa(nRecno, cLaboratorio, cOrdem, cTipoOrdem, nPagina, nTamPag, cCampos, cIDEnsaio, cUsuario, lStatus)

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
Indica se o Módulo qie não está implantado
@author brunno.costa
@since  28/10/2024
@return lNaoImplantado, lógico, indica se o módulo qie não está implantado
/*/
METHOD NaoImplantado() CLASS EnsaiosInspecaoDeEntradasAPI

	Local lNaoImplantado := Nil

	DbSelectArea("QEK")
	QEK->(DbSetOrder(1))
	QEK->(DbSeek(xFilial("QEK")))

	lNaoImplantado := QEK->(Eof())
	
Return lNaoImplantado

/*/{Protheus.doc} ModoExibicaoReferencias
Indica o modo de exibição das referencias nominais, LIE e LSE do usuário
@author brunno.costa
@since  26/12/2024
@param 01 - cLogin , caracter, login do usuário para validação das permissões de acesso
@return cRetorno, caracter, indica o modo de acesso do usuário aos resultados das amostras do qie:
							1 = Exibe referências;
							2 = Oculta referências;
/*/
METHOD ModoExibicaoReferencias(cLogin) CLASS EnsaiosInspecaoDeEntradasAPI
     
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

/*/{Protheus.doc} MapeiaCamposListaInstrumento
Mapeia os Campos Lista de Instrumento de Medição
@author brunno.costa / rafael.kleestadt
@since  25/04/2025
@param 01 - cCampos, String, string com os campos [nPosCPS_Titulo_API] para consideração separados por vírgula
@return aMapaCampos, Array , {{lConsidera, Titulo Interface, Título API, Campo Protheus, Tipo, Tamanho, Decimal}, ...}
                             {{nPosCPS_Considera, ..., nPosCPS_Decimal}, ...}
/*/
METHOD MapeiaCamposListaInstrumento() CLASS EnsaiosInspecaoDeEntradasAPI

    Local aMapaCampos := {}

	aadd(aMapaCampos, {.F., "Descricao"       , "description"   , "QM2_DESCR" , "C" , GetSx3Cache("QM2_DESCR" ,"X3_TAMANHO"), 0,})
    aadd(aMapaCampos, {.F., "Codigo"          , "code"          , "QM2_INSTR" , "C" , GetSx3Cache("QM2_INSTR" ,"X3_TAMANHO"), 0,})
	aadd(aMapaCampos, {.F., "Revisao"         , "revision"      , "QM2_REVINS", "C" , GetSx3Cache("QM2_REVINS","X3_TAMANHO"), 0,})
	aadd(aMapaCampos, {.F., "Val.Calibracao"  , "validate"      , "QM2_VALDAF", "D" , GetSx3Cache("QM2_VALDAF","X3_TAMANHO"), 0,})
	
	Self:oAPIManager := QualityAPIManager():New(aMapaCampos, Self:oWSRestFul)
	Self:oAPIManager:MarcaCamposConsiderados("*", aMapaCampos, nPosCPS_Titulo_API)

Return aMapaCampos


