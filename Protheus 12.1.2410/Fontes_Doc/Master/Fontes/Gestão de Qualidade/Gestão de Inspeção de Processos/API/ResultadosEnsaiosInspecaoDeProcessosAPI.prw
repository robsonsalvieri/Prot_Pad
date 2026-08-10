#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "ResultadosEnsaiosInspecaoDeProcessosAPI.CH"

Static lQLTExAAmIn  := Nil
Static scMVQlins    := Nil
Static slMVQinvlTx  := Nil
Static slMVQipQMT   := Nil
Static slQLTMetrics := FindClass("QLTMetrics")
Static sQNCClass    := Nil

//Desconsiderado o uso de FWAPIManager devido complexidade de DE-PARA das tabelas QPK, QPS, QPQ x API Mobile

#DEFINE nPosCPS_Considera                  1
#DEFINE nPosCPS_Titulo_Interface           2
#DEFINE nPosCPS_Titulo_API                 3
#DEFINE nPosCPS_Protheus                   4
#DEFINE nPosCPS_Tipo                       5
#DEFINE nPosCPS_Tamanho                    6
#DEFINE nPosCPS_Decimal                    7
#DEFINE nPosCPS_Alias                      8
#DEFINE nPosCPS_Protheus_Externo           9

/*/{Protheus.doc} processinspectiontestresults
API Resultados Ensaios da Inspeção de Processos - Qualidade
@author brunno.costa
@since  23/05/2022
/*/
WSRESTFUL processinspectiontestresults DESCRIPTION STR0001 FORMAT APPLICATION_JSON //"Resultados Ensaios Inspeção de Processos"

    WSDATA Fields      as STRING OPTIONAL
	WSDATA IDTest      as STRING OPTIONAL
	WSDATA Login       as STRING OPTIONAL
	WSDATA OperationID as STRING OPTIONAL
    WSDATA Order       as STRING OPTIONAL
    WSDATA Page        as INTEGER OPTIONAL
    WSDATA PageSize    as INTEGER OPTIONAL
    WSDATA RecnoQPK    as STRING OPTIONAL
	WSDATA RecnoQPR    as STRING OPTIONAL
	WSDATA RecnoQQM    as STRING OPTIONAL
    WSDATA RecnosQPR   as STRING OPTIONAL

    WSMETHOD GET result;
    DESCRIPTION STR0015; //"Retorna Resultado da Inspeção de Processos"
    WSSYNTAX "api/qip/v1/result/{RecnoQPK}/{RecnosQPR}/{Order}/{Page}/{PageSize}" ;
    PATH "/api/qip/v1/result/{RecnoQPK}/{RecnosQPR}/{Order}/{Page}/{PageSize}" ;
    TTALK "v1"

    WSMETHOD GET testhistory;
    DESCRIPTION STR0015; //"Retorna Resultado da Inspeção de Processos"
    WSSYNTAX "api/qip/v1/testhistory/{RecnoQPK}/{OperationID}/{IDTest}/{Order}/{Page}/{PageSize}" ;
    PATH "/api/qip/v1/testhistory" ;
    TTALK "v1"

	WSMETHOD GET history;
    DESCRIPTION STR0016; //"Retorna Histórico de Resultados da Inspeção de Processos"
    WSSYNTAX "api/qip/v1/history/{RecnoQPK}/{Order}/{Page}/{PageSize}" ;
    PATH "/api/qip/v1/history" ;
    TTALK "v1"

	WSMETHOD GET attachedfile;
    DESCRIPTION STR0050; //"Retorna Arquivo em base 64"
    WSSYNTAX "api/qip/v1/attachedfile/{RecnoQQM}" ;
    PATH "/api/qip/v1/attachedfile" ;
    TTALK "v1"
	
	WSMETHOD POST save;
	DESCRIPTION STR0002; //"Salva Resultado"
	WSSYNTAX "api/qip/v1/save" ;
	PATH "/api/qip/v1/save" ;
	TTALK "v1"

	WSMETHOD DELETE result;
	DESCRIPTION STR0031; //"Deleta Informações de uma Amostra"
	WSSYNTAX "api/qip/v1/result/{RecnoQPR}" ;
    WSSYNTAX "api/qip/v1/result" ;
	TTALK "v1"

	WSMETHOD GET accessmode;
	DESCRIPTION STR0061; //"Indica o modo de acesso do usuário as amostras de resultados"
	WSSYNTAX "api/qip/v1/accessmode/{Login}/{IDTest}/{RecnoQPK}/{OperationID}" ;
	PATH "/api/qip/v1/accessmode" ;
	TTALK "v1"

	WSMETHOD GET texttypesize;
	DESCRIPTION STR0060; //"Indica o tamanho máximo do resultado do tipo texto";
	WSSYNTAX "api/qip/v1/texttypesize" ;
	PATH "/api/qip/v1/texttypesize" ;
	TTALK "v1"

	WSMETHOD GET dateeditpermission;
	DESCRIPTION STR0064; //"Indica a permissão para edição do campo data da amostra"
	WSSYNTAX "api/qip/v1/dateeditpermission/{Login}/{RecnoQPK}/{RecnoQPR}/{RecnoQQM}" ;
	PATH "/api/qip/v1/dateeditpermission" ;
	TTALK "v1"

	WSMETHOD GET timeeditpermission;
	DESCRIPTION STR0065; //"Indica a permissão para edição do campo hora da amostra"
	WSSYNTAX "api/qip/v1/timeeditpermission/{Login}/{RecnoQPK}/{RecnoQPR}/{RecnoQQM}" ;
	PATH "/api/qip/v1/timeeditpermission" ;
	TTALK "v1"

	WSMETHOD GET relatedinstruments;
    DESCRIPTION STR0066; //"Lista instrumentos relacioados à amostra"
    WSSYNTAX "api/qip/v1/relatedinstruments/{RecnoQPR}";
    PATH "/api/qip/v1/relatedinstruments" ;
    TTALK "v1"

	WSMETHOD GET repeatrelatedinstruments;
    DESCRIPTION STR0080; //"Retorna lista de instrumentos para repetição com base na primeira amostra de resultados"
    WSSYNTAX "api/qip/v1/repeatrelatedinstruments/{RecnoQPK}/{OperationID}/{IDTest}" ;
    PATH "/api/qip/v1/repeatrelatedinstruments" ;
    TTALK "v1"

	WSMETHOD GET setdefaultnominalvalueforresultsample;
    DESCRIPTION STR0082; //"Indica se deve setar valor nominal como default de amostras de resultados"
    WSSYNTAX "api/qip/v1/setdefaultnominalvalueforresultsample/{RecnoQPK}/{OperationID}/{Login}" ;
    PATH "/api/qip/v1/setdefaultnominalvalueforresultsample" ;
    TTALK "v1"

ENDWSRESTFUL

WSMETHOD GET result PATHPARAM RecnoQPK, RecnosQPR, Order, Page, PageSize QUERYPARAM Fields WSSERVICE processinspectiontestresults
    Local oAPIClass  := ResultadosEnsaiosInspecaoDeProcessosAPI():New(Self)
	Local aRecnosQPR := Nil
	Default Self:RecnoQPK  := ""
	Default Self:RecnosQPR := ""
	Default Self:Order     := ""
	Default Self:Page      := 1
	Default Self:PageSize  := 5
	Default Self:Fields    := ""
	aRecnosQPR := StrTokArr2( Self:RecnosQPR, ";")
Return oAPIClass:RetornaResultadosInspecao(Self:RecnoQPK, Self:Order, aRecnosQPR, Self:Page, Self:PageSize, Self:Fields)

WSMETHOD GET testhistory PATHPARAM RecnoQPK, IDTest, OperationID, Order, Page, PageSize QUERYPARAM Fields WSSERVICE processinspectiontestresults
    Local oAPIClass  := ResultadosEnsaiosInspecaoDeProcessosAPI():New(Self)
	Default Self:RecnoQPK    := ""
	Default Self:IDTest      := ""
	Default Self:OperationID := ""
	Default Self:Order       := ""
	Default Self:Page        := 1
	Default Self:PageSize    := 5
	Default Self:Fields      := ""
Return oAPIClass:RetornaResultadosInspecaoPorEnsaio(Self:RecnoQPK, Self:Order, Self:IDTest, Self:OperationID, Self:Page, Self:PageSize, Self:Fields)

WSMETHOD GET repeatrelatedinstruments PATHPARAM RecnoQPK, IDTest, OperationID, Order, Page, PageSize QUERYPARAM Fields WSSERVICE processinspectiontestresults
    Local oAPIClass  := ResultadosEnsaiosInspecaoDeProcessosAPI():New(Self)
	Default Self:RecnoQPK    := ""
	Default Self:IDTest      := ""
	Default Self:OperationID := ""
Return oAPIClass:RetornaRepeticaoInstrumentosPrimeiraAmostra(Self:RecnoQPK, Self:OperationID, Self:IDTest)

WSMETHOD GET setdefaultnominalvalueforresultsample PATHPARAM RecnoQPK, OperationID, Login QUERYPARAM WSSERVICE processinspectiontestresults
    Local oAPIClass  := ResultadosEnsaiosInspecaoDeProcessosAPI():New(Self)
Return oAPIClass:definirValorNominalPadraoParaAmostraDeResultado(Self:RecnoQPK, Self:OperationID, Self:Login)

WSMETHOD GET history PATHPARAM RecnoQPK, Order, Page, PageSize QUERYPARAM Fields WSSERVICE processinspectiontestresults
    Local oAPIClass  := ResultadosEnsaiosInspecaoDeProcessosAPI():New(Self)
	Local aRecnosQPR := Nil
	Default Self:RecnoQPK  := ""
	Default Self:Order     := ""
	Default Self:Page      := 1
	Default Self:PageSize  := 5
	Default Self:Fields    := ""
Return oAPIClass:RetornaResultadosInspecao(Self:RecnoQPK, Self:Order, aRecnosQPR, Self:Page, Self:PageSize, Self:Fields)

WSMETHOD GET relatedinstruments PATHPARAM RecnoQPR QUERYPARAM Fields WSSERVICE processinspectiontestresults
    Local oAPIClass  := ResultadosEnsaiosInspecaoDeProcessosAPI():New(Self)
	Default Self:RecnoQPR  := ""
Return oAPIClass:ListaInstrumentosRelacionadosAmostra(Val(Self:RecnoQPR))

WSMETHOD POST save QUERYPARAM Fields WSSERVICE processinspectiontestresults
    Local oAPIClass  := ResultadosEnsaiosInspecaoDeProcessosAPI():New(Self)
Return oAPIClass:Salva(DecodeUTF8(Self:GetContent()))

WSMETHOD DELETE result PATHPARAM RecnoQPR WSSERVICE processinspectiontestresults
    Local oAPIClass  := ResultadosEnsaiosInspecaoDeProcessosAPI():New(Self)
	Self:SetContentType("application/json")
Return oAPIClass:DeletaAmostra(Val(Self:RecnoQPR))

WSMETHOD GET accessmode PATHPARAM Login, IDTest, RecnoQPK, OperationID WSSERVICE processinspectiontestresults
    Local oAPIClass  := ResultadosEnsaiosInspecaoDeProcessosAPI():New(Self)
	oAPIClass:RespondeAPIModoAcessoResultados(Self:Login, Self:IDTest, Self:RecnoQPK, Self:OperationID)
Return 

WSMETHOD GET texttypesize WSSERVICE processinspectiontestresults
    Local oAPIClass  := ResultadosEnsaiosInspecaoDeProcessosAPI():New(Self)
	oAPIClass:RetornaTamanhoResultadoTipoTexto()
Return 

WSMETHOD GET dateeditpermission PATHPARAM Login, RecnoQPK, RecnoQPR, OperationID WSSERVICE processinspectiontestresults

	Local lBloqueioPE := .F.
	Local lPermite    := .T.
    Local oAPIManager := QualityAPIManager():New({}, Self)
	Local oObj        := JsonObject()       :New()

	Default Self:OperationID := "01"
	Default Self:RecnoQPK    := -1
	Default Self:RecnoQPR    := -1

	If oAPIManager:existePEIntegracaoAppMinhaProducaoCompilado("QIP")
		oObj                := JsonObject():New()
		oObj["login"   ]    := Self:Login
		oObj["recnoQPK"]    := Val(Self:RecnoQPK)
		oObj["recnoQPR"]    := Val(Self:RecnoQPR)
		oObj["operationID"] := Self:OperationID
		oObj["insert"  ]    := Val(Self:RecnoQPR) < 1
		oObj["update"  ]    := Val(Self:RecnoQPR) > 0
		lBloqueioPE := Execblock('QIPINTAPI',.F.,.F.,{oObj, "processinspectiontestresults/api/qip/v1/dateeditpermission", "ResultadosEnsaiosInspecaoDeProcessosAPI", "bloqueiaDataInspecao"})
		If Valtype(lBloqueioPE) == 'L'
			lPermite := !lBloqueioPE
		EndIf
	EndIf
	
	oAPIManager:RespondeValor("permission", lPermite)

Return 

WSMETHOD GET timeeditpermission PATHPARAM Login, RecnoQPK, RecnoQPR, OperationID WSSERVICE processinspectiontestresults

	Local lBloqueioPE := .F.
	Local lPermite    := .T.
    Local oAPIManager := QualityAPIManager():New({}, Self)
	Local oObj        := JsonObject()       :New()

	Default Self:OperationID := "01"
	Default Self:RecnoQPK    := -1
	Default Self:RecnoQPR    := -1

	If oAPIManager:existePEIntegracaoAppMinhaProducaoCompilado("QIP")
		oObj                := JsonObject():New()
		oObj["login"   ]    := Self:Login
		oObj["recnoQPK"]    := Val(Self:RecnoQPK)
		oObj["recnoQPR"]    := Val(Self:RecnoQPR)
		oObj["operationID"] := Self:OperationID
		oObj["insert"  ]    := Val(Self:RecnoQPR) < 1
		oObj["update"  ]    := Val(Self:RecnoQPR) > 0
		lBloqueioPE := Execblock('QIPINTAPI',.F.,.F.,{oObj, "processinspectiontestresults/api/qip/v1/timeeditpermission", "ResultadosEnsaiosInspecaoDeProcessosAPI", "bloqueiaHoraInspecao"})
		If Valtype(lBloqueioPE) == 'L'
			lPermite := !lBloqueioPE
		EndIf
	EndIf
	
	oAPIManager:RespondeValor("permission", lPermite)

Return 

/*/{Protheus.doc} ResultadosEnsaiosInspecaoDeProcessosAPI
Regras de Negocio - API Inspeção de Processos
@author brunno.costa
@since  23/05/2022
/*/
CLASS ResultadosEnsaiosInspecaoDeProcessosAPI FROM LongNameClass

	DATA aCamposAPI                         as ARRAY
	DATA aCamposQPQ                         as ARRAY
	DATA aCamposQPR                         as ARRAY
	DATA aCamposQPS                         as ARRAY
	DATA cDetailedMessage                   as STRING
	DATA cErrorMessage                      as STRING
	DATA cOperacao                          as STRING
	DATA lExcluiuRegistroNumerico           as LOGICAL
	DATA lForcaInexistenciaDiretorio        as LOGICAL
	DATA lProcessaRetorno                   as LOGICAL
	DATA lResponseAPI                       as LOGICAL
	DATA lSalvouRegistroNumerico            as LOGICAL
	DATA lTemQQM                            as LOGICAL
	DATA nAmostraTela                       as STRING
	DATA nCamposQPR                         as NUMERIC
	DATA nRecnoQPK                          as NUMERIC
	DATA nRegistros                         as NUMERIC
	DATA oAnexos                            as OBJECT
	DATA oAPIManager                        as OBJECT
	DATA oCacheEnsaiadorQPR                 as OBJECT
	DATA oCacheInexistenciaLaudoLaboratorio as OBJECT
	DATA oCachePermissaoEnsaioNumerico      as OBJECT
	DATA oCacheQuantidadeMedicoesEnsaio     as OBJECT
    DATA oWSRestFul                         as OBJECT

    METHOD new(oWSRestFul) CONSTRUCTOR
	METHOD DefinirValorNominalPadraoParaAmostraDeResultado()
	METHOD DeletaAmostra(nRecnoQPR, cUsuario)
	METHOD DeletaAmostraSemResponse(nRecnoQPR, cChaveQPK)
	METHOD ModoAcessoResultados()
	METHOD RespondeAPIModoAcessoResultados()
	METHOD RetornaTamanhoResultadoTipoTexto()
    METHOD Salva(cJsondata)
     
    //Métodos Internos
	METHOD AtualizaChaveQPRParaMedia(oRegistro)
	METHOD AtualizaEnsaiadorQPR(cLogin, oRegistro)
	METHOD AtualizaStatusQPKComChaveQPK(cChaveQPK)
	METHOD AtualizaStatusQPKComRecno(nRecnoQPK)
	METHOD CriaAliasListaInstrumentosRelacionadosAmostra(nRecnoQPR)
	METHOD CriaAliasRepeticaoInstrumentos(nRecnoQPK, cOperationID, cIDTest)
	METHOD CriaAliasResultadosInspecaoPorEnsaio(nRecnoQPK, cOrdem, cIDTest, cOperacao, nPagina, nTamPag, cCampos, cAlias)
	METHOD CriaPasta(cDiretorio)
	METHOD DefineFatores()
	METHOD EnsaioComMedia(cTipo, cFormula)
	METHOD ErrorBlock(e)
	METHOD ExcluiInstrumentosRelacionadosAmostra(nRecnoQPR)
	METHOD ExcluiRelacionamentoInstrumento(nRecnoQPR, oItem, cErrorMessage)
	METHOD ExisteLaudoRelacionadoAoPost(oDadosJson)
	METHOD GeraChaveQPR()
	METHOD IdentificaRecnosInspecoesEEnsaios(oDadosJson, aRecsQPK, aRecsQP7, aRecsQP8)
	METHOD IncluiRelacionamentoInstrumento(nRecnoQPR, oItem)
	METHOD ListaInstrumentosRelacionadosAmostra(nRecnoQPR)
	METHOD MapeiaCamposAPI(cCampos)
	METHOD MapeiaCamposListaInstrumento()
	METHOD MapeiaCamposQPQ(cCampos)
	METHOD MapeiaCamposQPR(cCampos)
	METHOD MapeiaCamposQPS(cCampos)
	METHOD NaoImplantado()
	METHOD PreparaDadosQPQ(oItemAPI)
	METHOD PreparaDadosQPS(oItemAPI)
	METHOD PreparaRegistroInclusaoQPR(oItemAPI, oRegistro)
	METHOD PreparaRegistroQPR(oItemAPI, oRegistro)
	METHOD ProcessaItensRecebidos(oDadosJson, aRecnosQPR)
	METHOD ProcessaRelacionamentoInstrumento(oRegistro, oItemAPI, cErrorMessage)
	METHOD RecuperaCamposQP7paraQPR(oRegistro, nRecnoQP7)
	METHOD RecuperaCamposQP8paraQPR(oRegistro, nRecnoQP8)
	METHOD RecuperaCamposQPKParaQPR(oRegistro, nRecnoQPK)
	METHOD RetornaRepeticaoInstrumentosPrimeiraAmostra(nRecnoQPK, cOperationID, cIDTest)
	METHOD RetornaResultadosInspecao(nRecnoQPK, cOrdem, aRecnosQPR, nPagina, nTamPag, cCampos)
	METHOD RetornaResultadosInspecaoPorEnsaio(nRecnoQPK, cOrdem, cIDTest, cOperacao, nPagina, nTamPag, cCampos)
	METHOD RevisaEnsaiosCalculados(oDadosJson, oDadosCalc)
    METHOD SalvaRegistroNumerico(oItemAPI)
	METHOD SalvaRegistroQPSSequencialmente(oDadosQPS)
	METHOD SalvaRegistros(oItemAPI)
	METHOD SalvaRegistroTexto(oItemAPI)
	METHOD ValidaEnsaiador(oRegistro)
	METHOD ValidaEnsaioEditavel(cEnsaio, cOperacao)
	METHOD ValidaEnsaioEditavelPorQPR(cOperacao)
	METHOD ValidaEnsaioEditavelPorRegistro(oRegistro, cOperacao)
	METHOD ValidaFormatosCamposItem(oItemAPI, aCamposAPI)
	METHOD ValidaInclusaoRelacionamentoInstrumento(cEnsaio, oItem, cErrorMessage)
	METHOD ValidaInexistenciaLaudoLaboratorio(cChaveQPL, cOperacao)
	Method ValidaPermissaoDoUsuarioParaOEnsaio(cLogin, cEnsaio)
	METHOD ValidaPermissaoEnsaioNumerico(nRecnoQP7)
	METHOD ValidaPermissaoEnsaioTexto(nRecnoQP8)
	METHOD ValidaQuantidadeMedicoesEnsaio(oItemAPI, nMedicoes, cEnsaio)
	METHOD ValidaUsuarioProtheus(oItemAPI)

ENDCLASS

METHOD new(oWSRestFul) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
     Self:oWSRestFul                  := oWSRestFul
	 Self:oAPIManager                 := QualityAPIManager():New(Nil, oWSRestFul, Nil)
	 Self:oAnexos                     := AnexosInspecaoQualidadeAPI():New(Self)
	 Self:lProcessaRetorno            := .T.
	 Self:lSalvouRegistroNumerico     := .F.
	 Self:lExcluiuRegistroNumerico    := .F.
	 Self:lForcaInexistenciaDiretorio := .F.
	 self:nAmostraTela                := ""
	 Self:lTemQQM                     := !Empty(FWX2Nome( "QQM" ))
	 Self:cErrorMessage               := ""
	 Self:cDetailedMessage            := ""
	 Self:lResponseAPI                := .T.
Return Self

/*/{Protheus.doc} MapeiaCamposAPI
Mapeia os Campos da Interface da API
@author brunno.costa
@since  23/05/2022
@param 01 - cCampos, String, string com os campos [nPosCPS_Titulo_API] para consideração separados por vírgula
@return aMapaCampos, Array , {{lConsidera, Titulo Interface, Título API, Campo Protheus, Tipo, Tamanho, Decimal}, ...}
                             {{nPosCPS_Considera, ..., nPosCPS_Decimal}, ...}
/*/
METHOD MapeiaCamposAPI(cCampos) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI

    Local aMapaCampos := {}

	aAdd(aMapaCampos, {.T., "RecnoInspecao"     , "recnoInspection"     , "RECNOQPK"   , "NN" ,                                       0, 0, "QPK"})    //NN para não formatar como número pois não temos certeza do tamanho configurado na tabela do cliente
	aAdd(aMapaCampos, {.T., "RecnoEnsaio"       , "recnoTest"           , "RECNOTEST"  , "NN" ,                                       0, 0, "QP7QP8"}) //NN para não formatar como número pois não temos certeza do tamanho configurado na tabela do cliente
	aAdd(aMapaCampos, {.F., "Ensaio"            , "testID"              , "QPR_ENSAIO" , "CN" , GetSx3Cache("QPR_ENSAIO" ,"X3_TAMANHO"), 0, "QPR"})
	aAdd(aMapaCampos, {.F., "Data"              , "measurementDate"     , "QPR_DTMEDI" , "D"  , GetSx3Cache("QPR_DTMEDI" ,"X3_TAMANHO"), 0, "QPR"})
	aAdd(aMapaCampos, {.F., "Hora"              , "measurementTime"     , "QPR_HRMEDI" , "H"  , GetSx3Cache("QPR_HRMEDI" ,"X3_TAMANHO"), 0, "QPR"})
	aAdd(aMapaCampos, {.F., "CodigoEnsaiador"   , "rehearserID"         , "QPR_ENSR"   , "C"  , GetSx3Cache("QPR_ENSR"   ,"X3_TAMANHO"), 0, "QPR"})
	aAdd(aMapaCampos, {.F., "Ensaiador"         , "rehearser"           , "QAA_NOME"   , "C"  , GetSx3Cache("QAA_NOME"   ,"X3_TAMANHO"), 0, "QAA"})
	aAdd(aMapaCampos, {.T., "NumeroAmostra"     , "sampleNumber"        , "QPR_AMOSTR" , "N"  , GetSx3Cache("QPR_AMOSTR" ,"X3_TAMANHO"), 0, "QPR" })
	aAdd(aMapaCampos, {.T., "TipoEnsaio"        , "testType"            , "TIPO"       , "C"  ,                                       1, 0, "N/A"})
	aAdd(aMapaCampos, {.F., "ArrayMedicoes"     , "measurements"        , "MEDICOES"   , "A"  ,                                       0, 0, "QPS"})
	aAdd(aMapaCampos, {.F., "TextoStatus"       , "textStatus"          , "QPR_RESULT" , "C"  , GetSx3Cache("QPR_RESULT" ,"X3_TAMANHO"), 0, "QPR"})
	aAdd(aMapaCampos, {.F., "TextoDetalhes"     , "textDetail"          , "QPQ_MEDICA" , "C"  , GetSx3Cache("QPQ_MEDICA" ,"X3_TAMANHO"), 0, "QPQ"})
	aAdd(aMapaCampos, {.F., "UsuarioProtheus"   , "protheusLogin"       , "QAA_LOGIN"  , "C"  , GetSx3Cache("QAA_LOGIN"  ,"X3_TAMANHO"), 0, "QAA"})
	aAdd(aMapaCampos, {.T., "Recno"             , "recno"               , "RECNOQPR"   , "NN" ,                                       0, 0, "QPR"}) //NN para não formatar como número pois não temos certeza do tamanho configurado na tabela do cliente
	aAdd(aMapaCampos, {.T., "TemAnexo"          , "hasAttachment"       , "TEMANEXO"   , "C"  ,                                       0, 0, "QQM"})
 
    aMapaCampos := Self:oAPIManager:MarcaCamposConsiderados(cCampos, aMapaCampos, nPosCPS_Titulo_API)

Return aMapaCampos

/*/{Protheus.doc} MapeiaCamposQPR
Mapeia os Campos da tabela QPR do Protheus - Dados Genéricos das Medições
@author brunno.costa
@since  23/05/2022
@param 01 - cCampos, String, string com os campos [nPosCPS_Titulo_API] para consideração separados por vírgula
@return aMapaCampos, Array , {{lConsidera, Titulo Interface, Título API, Campo Protheus, Tipo, Tamanho, Decimal}, ...}
                             {{nPosCPS_Considera, ..., nPosCPS_Decimal}, ...}
/*/
METHOD MapeiaCamposQPR(cCampos) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI

    Local aMapaCampos := {}

	aAdd(aMapaCampos, {.T., "Data"              , "measurementDate"     , "QPR_DTMEDI"        , "D"  , GetSx3Cache("QPR_DTMEDI" ,"X3_TAMANHO"), 0, "QPR" })
	aAdd(aMapaCampos, {.T., "Hora"              , "measurementTime"     , "QPR_HRMEDI"        , "C"  , GetSx3Cache("QPR_HRMEDI" ,"X3_TAMANHO"), 0, "QPR" })
	aAdd(aMapaCampos, {.T., "Ensaiador"         , "rehearser"           , "QPR_ENSR"          , "C"  , GetSx3Cache("QPR_ENSR"   ,"X3_TAMANHO"), 0, "QPR" })
	aAdd(aMapaCampos, {.T., "TextoStatus"       , "textStatus"          , "QPR_RESULT"        , "C"  , GetSx3Cache("QPR_RESULT" ,"X3_TAMANHO"), 0, "QPR" })
	aAdd(aMapaCampos, {.T., "NumeroAmostra"     , "sampleNumber"        , "QPR_AMOSTR"        , "N"  , GetSx3Cache("QPR_AMOSTR" ,"X3_TAMANHO"), 0, "QPR" })
	aAdd(aMapaCampos, {.T., "N/A"               , "N/A"                 , "QPR_CHAVE"         , "C"  ,                                       0, 0, "QPR" })
	aAdd(aMapaCampos, {.T., "N/A"               , "N/A"                 , "QPR_FILMAT"        , "C"  ,                                       0, 0, "QAA"   , "QAA_FILIAL"})
	aAdd(aMapaCampos, {.T., "N/A"               , "N/A"                 , "QPR_REVI"          , "C"  ,                                       0, 0, "QPK"   , "QPK_REVI"  })
	aAdd(aMapaCampos, {.T., "N/A"               , "N/A"                 , "QPR_OP"            , "C"  ,                                       0, 0, "QPK"   , "QPK_OP"    })
	aAdd(aMapaCampos, {.T., "N/A"               , "N/A"                 , "QPR_DTENTR"        , "C"  ,                                       0, 0, "QPK"   , "QPK_EMISSA"})
	aAdd(aMapaCampos, {.T., "N/A"               , "N/A"                 , "QPR_LOTE"          , "C"  ,                                       0, 0, "QPK"   , "QPK_LOTE"  })
	aAdd(aMapaCampos, {.T., "N/A"               , "N/A"                 , "QPR_NUMSER"        , "C"  ,                                       0, 0, "QPK"   , "QPK_NUMSER"})
	aAdd(aMapaCampos, {.T., "N/A"               , "N/A"                 , "QPR_CLIENT"        , "C"  ,                                       0, 0, "QPK"   , "QPK_CLIENT"})
	aAdd(aMapaCampos, {.T., "N/A"               , "N/A"                 , "QPR_LOJA"          , "C"  ,                                       0, 0, "QPK"   , "QPK_LOJA"  })
	aAdd(aMapaCampos, {.T., "N/A"               , "N/A"                 , "QPR_PRODUT"        , "C"  ,                                       0, 0, "QP7QP8", "QP7_PRODUT"})
	aAdd(aMapaCampos, {.T., "N/A"               , "N/A"                 , "QPR_LABOR"         , "C"  ,                                       0, 0, "QP7QP8", "QP7_LABOR" })
	aAdd(aMapaCampos, {.T., "N/A"               , "N/A"                 , "QPR_ENSAIO"        , "C"  ,                                       0, 0, "QP7QP8", "QP7_ENSAIO"})
	aAdd(aMapaCampos, {.T., "N/A"               , "N/A"                 , "QPR_OPERAC"        , "C"  ,                                       0, 0, "QP7QP8", "QP7_OPERAC"})
	aAdd(aMapaCampos, {.T., "N/A"               , "N/A"                 , "QPR_ROTEIR"        , "C"  ,                                       0, 0, "QP7QP8", "QP7_CODREC"})
	aAdd(aMapaCampos, {.T., "Recno"             , "recno"               , "R_E_C_N_O_"        , "NN" ,                                           0, 0, "QPR"}) //NN para não formatar como número pois não temos certeza do tamanho configurado na tabela do cliente
 
    aMapaCampos := Self:oAPIManager:MarcaCamposConsiderados(cCampos, aMapaCampos, nPosCPS_Protheus)

	Self:nCamposQPR := Len(aMapaCampos)

Return aMapaCampos

/*/{Protheus.doc} MapeiaCampos
Mapeia os Campos da tabela QPS do Protheus - Processo Medições Mensuráveis - Dados Numéricos
@author brunno.costa
@since  23/05/2022
@param 01 - cCampos, String, string com os campos [nPosCPS_Titulo_API] para consideração separados por vírgula
@return aMapaCampos, Array , {{lConsidera, Titulo Interface, Título API, Campo Protheus, Tipo, Tamanho, Decimal}, ...}
                             {{nPosCPS_Considera, ..., nPosCPS_Decimal}, ...}
/*/
METHOD MapeiaCamposQPS(cCampos) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI

    Local aMapaCampos := {}

	aAdd(aMapaCampos, {.T., "N/A", "N/A", "QPS_CODMED", "C"  ,0, 0, "QPR", "QPR_CHAVE"})
	aAdd(aMapaCampos, {.T., "N/A", "N/A", "QPS_MEDICA", "C"  ,0, 0, "QPS" }) //MEDICAO
	aAdd(aMapaCampos, {.T., "N/A", "N/A", "QPS_INDMED", "C"  ,0, 0, "QPS" }) //SEQUENCIAL MEDICOES ARRAY 1-3 ou vazio acima de 4
 
    aMapaCampos := Self:oAPIManager:MarcaCamposConsiderados(cCampos, aMapaCampos, nPosCPS_Protheus)

Return aMapaCampos

/*/{Protheus.doc} MapeiaCamposQPQ
Mapeia os Campos da tabela QPS do Protheus - Valores das Medições (Texto)  
@author brunno.costa
@since  23/06/2022
@param 01 - cCampos, String, string com os campos [nPosCPS_Titulo_API] para consideração separados por vírgula
@return aMapaCampos, Array , {{lConsidera, Titulo Interface, Título API, Campo Protheus, Tipo, Tamanho, Decimal}, ...}
                             {{nPosCPS_Considera, ..., nPosCPS_Decimal}, ...}
/*/
METHOD MapeiaCamposQPQ(cCampos) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI

    Local aMapaCampos := {}

	aAdd(aMapaCampos, {.T., "N/A"               , "N/A"                 , "QPQ_CODMED"        , "C"  ,                                       0, 0, "QPR", "QPR_CHAVE"})
	aAdd(aMapaCampos, {.F., "TextoDetalhes"     , "textDetail"          , "QPQ_MEDICA"        , "C"  , GetSx3Cache("QPQ_MEDICA" ,"X3_TAMANHO"), 0})
	
	aMapaCampos := Self:oAPIManager:MarcaCamposConsiderados(cCampos, aMapaCampos, nPosCPS_Protheus)

Return aMapaCampos

/*/{Protheus.doc} Salva
Método para Salvar um Registro Recebido via API no DB Protheus
@author brunno.costa
@since  23/05/2022
@param 01 - cJsonData, caracter, string JSON com os dados para interpretação e gravação
@return lSucesso, lógico, indica se o processo foi executado com sucesso
/*/
METHOD Salva(cJsonData) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI

	Local aRecnosQPR            := {}
	Local bErrorBlock           := Nil
	Local cError                := Nil
	Local lSucesso              := .T.
    Local oDadosJson            := Nil
	Local oQIPEnsaiosCalculados := Nil
	Local oSelf                 := Self
	
	If !IsInCallStack("QIPCASVAPI")
		bErrorBlock := ErrorBlock({|e| lSucesso := .F., cError := e:Description, oSelf:ErrorBlock(e)})
		Self:oWSRestFul:SetContentType("application/json")
	EndIf

	oDadosJson  := JsonObject():New() 
	cError := oDadosJson:fromJson(cJsonData)
	If cError == Nil
		Begin Transaction
			Begin Sequence

				lSucesso := !Self:ExisteLaudoRelacionadoAoPost(oDadosJson)
				If !lSucesso .And. Empty(Self:oAPIManager:cErrorMessage)
					Self:oAPIManager:lWarningError := .T.
					Self:cErrorMessage            := STR0041 //"Operação não permitida! Existe laudo relacionado a esta inspeção."
					Self:cDetailedMessage         := STR0041 //"Operação não permitida! Existe laudo relacionado a esta inspeção."
				EndIf

				If lSucesso
					lSucesso := Self:ProcessaItensRecebidos(@oDadosJson, @aRecnosQPR, @Self:cErrorMessage)
				EndIf

				If lSucesso .And. (oDadosJson['responseItems'] == Nil .OR. oDadosJson['responseItems']) .And. !Empty(Self:nRecnoQPK)
					lSucesso := Self:RetornaResultadosInspecao(Self:nRecnoQPK, Nil, aRecnosQPR)
				EndIf

				If lSucesso .And. !Empty(Self:nRecnoQPK)
					Self:AtualizaStatusQPKComRecno(Self:nRecnoQPK)
					Self:nAmostraTela := oDadosJson["items"][1]["sampleNumber"]
					Self:nAmostraTela := Iif(Empty(Self:nAmostraTela),2,Self:nAmostraTela)
					If (Self:nRegistros   == 1 .And. Self:lSalvouRegistroNumerico .And. oDadosJson['justCalculated'] == Nil)
						oQIPEnsaiosCalculados := QIPEnsaiosCalculados():New(Self:nRecnoQPK, Self:cOperacao, {})
						oQIPEnsaiosCalculados:PersisteEnsaiosCalculados(oDadosJson["items"][1],Nil , self:nAmostraTela)
					ElseIf (Self:nAmostraTela == 2 .And. oDadosJson['justCalculated'] != Nil .AND. !oDadosJson['justCalculated'])
						oDadosJson['justCalculated'] := "true"
						StartJob("QIPCASVAPI", GetEnvServer(), .F., cEmpAnt, cFilAnt, oDadosJson:toJson())
					EndIf
				EndIf

				If !lSucesso .And. Empty(Self:cErrorMessage) .And. Empty(Self:oAPIManager:cErrorMessage)
					cError := Iif(cError == Nil, "", cError)
					//"Não foi possível realizar o processamento."
					//"Ocorreu erro durante a gravação dos dados: "
					Self:cErrorMessage    := STR0003          
					Self:cDetailedMessage := STR0004 + cError 
				EndIf

				If lSucesso .And. Self:oAPIManager:existePEIntegracaoAppMinhaProducaoCompilado("QIP")
					Execblock('QIPINTAPI',.F.,.F.,{oDadosJson, "processinspectiontestresults/api/qip/v1/save", "ResultadosEnsaiosInspecaoDeProcessosAPI", "complementoResultados"})
				EndIf
					
			Recover
				lSucesso := .F.
			End Sequence

			If !lSucesso 
				DisarmTransaction()
			EndIf

		End Transaction		

	Else
		//"Não foi possível interpretar os dados recebidos."
		//"Ocorreu erro ao transformar os dados recebidos em objeto JSON: "
		Self:cErrorMessage    := STR0005         
		Self:cDetailedMessage := STR0006 + cError
		lSucesso              := .F.
	EndIf

	If !lSucesso .And. Self:lResponseAPI
		Self:oAPIManager:RespondeValor("result", .F., Self:cErrorMessage, Self:cDetailedMessage)
	EndIf

	FwFreeObj(oDadosJson)

	If !Empty(bErrorBlock)
		ErrorBlock(bErrorBlock)
	EndIf

Return lSucesso

/*/{Protheus.doc} ValidaEnsaioEditavelPorQPR
Valida Se é Permitida Alteração/Inclusão/Alteração na QPR por posicionamento em registro da QPR
@author brunno.costa
@since  10/08/2022
@param 01 - cOperacao, caracter, I = Inclusão, A = Alteração, E = Exclusão 
@return lPermite, lógico, indica se permite editar o ensaio
/*/
METHOD ValidaEnsaioEditavelPorQPR(cOperacao) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI

	Local lPermite := .T.

	Default cOperacao := "I"

	If QPR->(!Eof())
		lPermite := Self:ValidaEnsaioEditavel(QPR->QPR_ENSAIO, cOperacao)

		If lPermite
			lPermite := Self:ValidaInexistenciaLaudoLaboratorio(QPR->(QPR_OP+QPR_LOTE+QPR_NUMSER+QPR_ROTEIR+QPR_OPERAC+QPR_LABOR), cOperacao)
		EndIf
	EndIf

Return lPermite

/*/{Protheus.doc} ValidaEnsaioEditavelPorRegistro
Valida Se é Permitida Alteração/Inclusão/Alteração na QPR por oRegistro da QPR
@author brunno.costa
@since  10/08/2022
@param 01 - oRegistro , objeto, retorna por referência os dados para gravação na tabela QPR do DB
@param 02 - cOperacao, caracter, I = Inclusão, A = Alteração, E = Exclusão 
@return lPermite, lógico, indica se permite editar o ensaio
/*/
METHOD ValidaEnsaioEditavelPorRegistro(oRegistro, cOperacao) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI

	Local lPermite := .T.

	Default cOperacao := "I"

	lPermite := Self:ValidaEnsaioEditavel(oRegistro["QPR_ENSAIO"], cOperacao)

	If lPermite
		lPermite := Self:ValidaInexistenciaLaudoLaboratorio(oRegistro["QPR_OP"]+;
                                                            oRegistro["QPR_LOTE"]+;
                                                            oRegistro["QPR_NUMSER"]+;
                                                            oRegistro["QPR_ROTEIR"]+;
                                                            oRegistro["QPR_OPERAC"]+;
                                                            oRegistro["QPR_LABOR"], cOperacao)
	EndIf

Return lPermite

/*/{Protheus.doc} ValidaInexistenciaLaudoLaboratorio
Valida inexistência do laudo de laboratório na QPL
@author brunno.costa
@since  10/08/2022
@param 01 - cChaveQPL, caracter, chave de posicionamento na QPL
@param 02 - cOperacao, caracter, I = Inclusão, A = Alteração, E = Exclusão 
@return lNaoExiste, lógico, indica se não existe laudo de laboratório
/*/
METHOD ValidaInexistenciaLaudoLaboratorio(cChaveQPL, cOperacao) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	
	Local lNaoExiste := .T.
	Local cMessage   := Nil

	Default cOperacao := "I"

	Self:oCacheInexistenciaLaudoLaboratorio := Iif(Self:oCacheInexistenciaLaudoLaboratorio == Nil, JsonObject():New(), Self:oCacheInexistenciaLaudoLaboratorio)

	cMessage := Iif(cOperacao == "I", STR0037, cMessage) //"Falha na Inclusão da Amostra"
	cMessage := Iif(cOperacao == "A", STR0038, cMessage) //"Falha na Alteração da Amostra"
	cMessage := Iif(cOperacao == "E", STR0033, cMessage) //"Falha na Exclusão da Amostra"

	If Self:oCacheInexistenciaLaudoLaboratorio[xFilial("QPL") + cChaveQPL] == Nil
		DbSelectArea("QPL")
		QPL->(DbSetOrder(3)) //QPL_FILIAL+QPL_OP+QPL_LOTE+QPL_NUMSER+QPL_ROTEIR+QPL_OPERAC+QPL_LABOR
		If QPL->(DbSeek(xFilial("QPL") + cChaveQPL))
			lNaoExiste := Empty(QPL->QPL_LAUDO)
		EndIf
		Self:oCacheInexistenciaLaudoLaboratorio[xFilial("QPL") + cChaveQPL] := lNaoExiste
	Else
		lNaoExiste        := Self:oCacheInexistenciaLaudoLaboratorio[xFilial("QPL") + cChaveQPL]
	EndIf

	Self:cErrorMessage    := Iif(lNaoExiste,Self:cErrorMessage, cMessage)
	Self:cDetailedMessage := Iif(lNaoExiste,Self:cDetailedMessage, STR0036) //"Esta inspeção já possui laudo"

Return lNaoExiste

/*/{Protheus.doc} ValidaEnsaioEditavel
Valida Se é Permitida Alteração/Inclusão/Alteração para este Ensaio
@author brunno.costa
@since  10/08/2022
@param 01 - nRecnoQPR, número  , RECNO do registro da amostra na tabela QPR
@param 02 - cOperacao, caracter, I = Inclusão, A = Alteração, E = Exclusão 
@return lPermite, lógico, indica se permite editar o ensaio
/*/
METHOD ValidaEnsaioEditavel(cEnsaio, cOperacao) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	
	
	Local cMessage := Nil
	Local lPermite := .T.

	Default cOperacao := "I"

	cMessage := Iif(cOperacao == "I", STR0037, cMessage) //"Falha na Inclusão da Amostra"
	cMessage := Iif(cOperacao == "A", STR0038, cMessage) //"Falha na Alteração da Amostra"
	cMessage := Iif(cOperacao == "E", STR0033, cMessage) //"Falha na Exclusão da Amostra"

	/*
	DbSelectArea("QP1")
	QP1->(DbSetOrder(1))
	If QP1->(DbSeek(xFilial("QP1") + cEnsaio))
		lPermite := QP1->QP1_TIPO=="D"
		Self:cErrorMessage    := Iif(lPermite,Self:cErrorMessage, cMessage)
		Self:cDetailedMessage := Iif(QP1->QP1_TIPO=="D",Iif(QP1->QP1_CARTA!="TMP",Self:cDetailedMessage, STR0034), STR0035) //"A carta deste ensaio é TMP" + "Este ensaio é calculado"
	EndIf
	*/

Return lPermite

/*/{Protheus.doc} DeletaAmostraSemResponse
Método para Deletar uma Amostra via API no DB Protheus
@author brunno.costa
@since  10/08/2022
@param 01 - nRecnoQPR, número  , RECNO do registro da amostra na tabela QPR
@param 02 - cChaveQPK, caracter, retorna por referência a chave do registro na QPK
@return lSucesso, lógico, indica se o processo foi executado com sucesso
/*/
METHOD DeletaAmostraSemResponse(nRecnoQPR, cChaveQPK) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	Local bErrorBlock := Nil
	Local cChaveQPR   := Nil
	Local cError      := Nil
	Local lSucesso    := .T.
    Local oDadosJson  := Nil
	Local oSelf       := Self

	Default cChaveQPK := ""
	
	bErrorBlock := ErrorBlock({|e| lSucesso := .F., cError := e:Description, oSelf:ErrorBlock(e)})

	Begin Transaction
		Begin Sequence
			DbSelectArea("QPR")
			QPR->(DbGoTo(nRecnoQPR))
			If QPR->(!Eof())
				cChaveQPR := QPR->QPR_CHAVE

				lSucesso := Self:ValidaEnsaioEditavelPorQPR("E")

				If lSucesso
					DbSelectArea("QPQ")
					QPQ->(DbSetOrder(1))
					If QPQ->(DbSeek(xFilial("QPQ") + cChaveQPR))
						While lSucesso .AND. xFilial("QPQ") + cChaveQPR == QPQ->(QPQ_FILIAL+QPQ_CODMED)
							RecLock("QPQ", .F.)
							QPQ->(DbDelete())
							QPQ->(MsUnLock())
							QPQ->(DBSkip())
						EndDo
					EndIf

					DbSelectArea("QPS")
					QPS->(DbSetOrder(1))
					If lSucesso .AND. QPS->(DbSeek(xFilial("QPS") + cChaveQPR))
						While lSucesso .AND. xFilial("QPS") + cChaveQPR == QPS->(QPS_FILIAL+QPS_CODMED)
							RecLock("QPS", .F.)
							QPS->(DbDelete())
							QPS->(MsUnLock())
							Self:lExcluiuRegistroNumerico := Iif(!Self:lExcluiuRegistroNumerico, lSucesso, .T.)
							QPS->(DBSkip())
						EndDo
					EndIf

					cChaveQPK := QPR->(QPR_OP+QPR_LOTE+QPR_NUMSER+QPR_PRODUT+QPR_REVI)

					lQLTExAAmIn := Iif(lQLTExAAmIn == Nil, FindFunction("QLTExAAmIn"), lQLTExAAmIn)
					If lQLTExAAmIn
						StartJob("QLTExAAmIn", GetEnvServer(), .F., cEmpAnt, cFilAnt, QPR->QPR_FILIAL, QPR->QPR_CHAVE, "QIP")
					EndIf
					RecLock("QPR", .F.)
					QPR->(DbDelete())
					QPR->(MsUnLock())
				EndIf
			EndIf
				
		Recover
			lSucesso := .F.
		End Sequence

		If !lSucesso 
			DisarmTransaction()
		EndIf

	End Transaction	

	FwFreeObj(oDadosJson)

	ErrorBlock(bErrorBlock)

Return lSucesso

/*/{Protheus.doc} DeletaAmostra
Método para Deletar uma Amostra via API no DB Protheus
@author brunno.costa
@since  10/08/2022
@param 01 - nRecnoQPR, número  , RECNO do registro da amostra na tabela QPR
@param 02 - cUsuario , caracter, indica o usuário que realizou a exclusão
@return lSucesso, lógico, indica se o processo foi executado com sucesso
/*/
METHOD DeletaAmostra(nRecnoQPR, cUsuario) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	Local cChaveQPK                  := ""
	Local cResp                      := Nil
	Local lSucesso                   := .T.
	Local nRecnoQPK                  := Nil
	Local oFichasNaoConformidadesAPI := FichasNaoConformidadesAPI():New()
	Local aNCsVinculadas             := {}
	Local oQIPEnsaiosCalculados      := Nil
	Local oResponse                  := JsonObject():New()
	Local nControle                  := 0

	Self:oWSRestFul:SetContentType("application/json")

	If lSucesso := Self:DeletaAmostraSemResponse(nRecnoQPR, @cChaveQPK)

		aNCsVinculadas := oFichasNaoConformidadesAPI:retornaNCsDaInspecaoDeProcesso(nRecnoQPR)
		
		For nControle := 1 to Len(aNCsVinculadas)

			oFichasNaoConformidadesAPI:excluiRelacionamentoNCQIP(nRecnoQPR, aNCsVinculadas[nControle],,.F.)
		
		Next nControle 

		Self:ExcluiInstrumentosRelacionadosAmostra(nRecnoQPR)

	Endif

	If lSucesso
		Self:AtualizaStatusQPKComChaveQPK(cChaveQPK)
		If Self:lExcluiuRegistroNumerico
			QPK->(DbSetOrder(1))
			If QPK->(DbSeek(xFilial("QPK")+cChaveQPK))
				nRecnoQPK := QPK->(Recno())
			EndIf
			oQIPEnsaiosCalculados := QIPEnsaiosCalculados():New(nRecnoQPK, Self:cOperacao, {})
			oQIPEnsaiosCalculados:ExcluiMedicoesCalculadas(cUsuario)
		EndIf

		Self:oWSRestFul:SetContentType("")
		HTTPSetStatus(204)
	Else
		SetRestFault(403, EncodeUtf8(Self:cErrorMessage), .T.,;
		             403, EncodeUtf8(Self:cDetailedMessage))
		oResponse['code'         ] := 403
		oResponse['errorCode'    ] := 403
		oResponse['message'      ] := Self:cErrorMessage
		oResponse['errorMessage' ] := Self:cDetailedMessage
		cResp := EncodeUtf8(FwJsonSerialize( oResponse, .T. ))
		Self:oWSRestFul:SetResponse( cResp )
	EndIf	

Return lSucesso

/*/{Protheus.doc} DefinirValorNominalPadraoParaAmostraDeResultado
Definir Valor Nominal Padrao Para Amostra De Resultado
@author brunno.costa
@since  15/09/2025
@param 01 - nRecnoQPR, número  , recno do ensaio na QPR
@param 02 - cOperacao, caracter, código da operação relacionada
@param 03 - cLogin   , caracter, usuário que está realizando a operação
/*/
METHOD DefinirValorNominalPadraoParaAmostraDeResultado(nRecnoQPK, cOperacao, cLogin) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	
	Local bErrorBlock := Nil
	Local cResp       := ""
	Local oReturnPE   := Nil
	Local lUsaPE      := ExistBlock("QIPINTAPI")
	Local lUsaNominal := .F.
	Local oError      := Nil
	Local oResponse   := JsonObject():New()

	Self:oWSRestFul:SetContentType("application/json")
	HTTPSetStatus(200)
	oResponse['code'    ] := 200
	oResponse['numerico'] := lUsaNominal
	oResponse['texto'   ] := lUsaNominal

	If lUsaPE

		oResponse['nRecnoQPK'] := Iif(ValType(nRecnoQPK)=="C", Val(nRecnoQPK), nRecnoQPK)
		oResponse['cOperacao'] := cOperacao
		oResponse['cLogin'   ] := cLogin
		
		bErrorBlock := ErrorBlock({|e| oError := e, .T. })
		Begin Sequence
			
			oReturnPE   := Execblock('QIPINTAPI',.F.,.F.,{oResponse, "processinspectiontestresults/api/qip/v1/setdefaultnominalvalueforresultsample", "ResultadosEnsaiosInspecaoDeProcessosAPI", "inversaoDefaultResultadosAmostras"})

			If Valtype(oReturnPE) == 'J'
				
				If Valtype(oReturnPE['numerico']) == 'L'
					oResponse['numerico'] := oReturnPE['numerico']
				EndIf

				If Valtype(oReturnPE['texto']) == 'L'
					oResponse['texto'] := oReturnPE['texto']
				EndIf

			EndIf

		Recover
		End Sequence
		ErrorBlock(bErrorBlock)
	EndIf	

	cResp := EncodeUtf8(FwJsonSerialize( oResponse, .T. ))
	Self:oWSRestFul:SetResponse( cResp )

	If oError != Nil
		LogMsg('QIPINTAPI', 0, 0, 1, '', '', "QIPINTAPI Fail - " + oError:Description + CHR(10) + oError:ErrorStack + CHR(10) + oError:ErrorEnv)
	EndIf

Return

/*/{Protheus.doc} SalvaRegistroNumerico
Método para Salvar um Registro NUMÉRICO Recebido via API no DB Protheus
@author brunno.costa
@since  23/05/2022
@param 01 - oItemAPI  , objeto, objeto Json com UM ITEM DOS REGISTROS JSON recebidos da API para conversão
@return lSucesso, lógico, indica se o processo foi executado com sucesso
/*/
METHOD SalvaRegistroNumerico(oItemAPI) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	
	Local lSucesso   := .T.
	Local oDadosQPS  := JsonObject():New()

	If lSucesso
		oDadosQPS                    := Self:PreparaDadosQPS(oItemAPI, @oDadosQPS)
		lSucesso                     := Self:SalvaRegistroQPSSequencialmente(oDadosQPS)
		Self:lSalvouRegistroNumerico := Iif(!Self:lSalvouRegistroNumerico, lSucesso, .T.)
	EndIf

	FwFreeObj(oDadosQPS)

Return lSucesso


/*/{Protheus.doc} SalvaRegistroTexto
Método para Salvar um Registro TEXTO Recebido via API no DB Protheus
@author brunno.costa
@since  23/06/2022
@param 01 - oItemAPI  , objeto, objeto Json com UM ITEM DOS REGISTROS JSON recebidos da API para conversão
@return lSucesso, lógico, indica se o processo foi executado com sucesso
/*/
METHOD SalvaRegistroTexto(oItemAPI) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	Local cCpsErro  := ""
	Local lSucesso  := .T.
	Local oRegistro := Nil

	oRegistro := Self:PreparaDadosQPQ(oItemAPI)
	lSucesso  := Self:oAPIManager:ValidaCamposObrigatorios(oRegistro, "|QPQ_CODMED|QPQ_MEDICA|", @cCpsErro)
	If lSucesso
		Self:oAPIManager:SalvaRegistroDB("QPQ", @oRegistro, Self:aCamposQPQ)
	Else
		//"Dados para Integração Inválidos"
		//"Campo(s) obrigatório(s) inválido(s)"
		Self:cErrorMessage    := STR0008
		Self:cDetailedMessage := STR0020 + " '" + AllTrim(cCpsErro) + "': " + oRegistro:toJson()
	EndIf

	FwFreeObj(oRegistro)
Return lSucesso

/*/{Protheus.doc} PreparaDadosQPQ
Prepara os Dados Recebidos para Gravação na tabela QPQ
@author brunno.costa
@since  23/06/2022
@param 01 - oItemAPI  , objeto, objeto Json com UM ITEM DOS REGISTROS JSON recebidos da API para conversão
@return oRegistro, objeto, retorna os dados para gravação na tabela QPQ do DB
/*/
METHOD PreparaDadosQPQ(oItemAPI) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	
	Local oRegistro     := Nil

	If Self:aCamposQPQ  == Nil
		Self:aCamposQPQ := Self:MapeiaCamposQPQ("*")
	EndIf

	oRegistro               := Self:oAPIManager:InicializaCamposPadroes("QPQ",,.T.)
	oRegistro["QPQ_CODMED"] := oItemAPI["QPR_CHAVE"]
	oRegistro["QPQ_MEDICA"] := oItemAPI["textDetail"]

	QPQ->(DbSetOrder(1))
	If QPQ->(DbSeek(xFilial("QPQ")+oRegistro["QPQ_CODMED"]))
		oRegistro['R_E_C_N_O_'] := QPQ->(Recno())
	EndIf

Return oRegistro

/*/{Protheus.doc} RetornaResultadosInspecao
Retorna a Lista de Resultados da Inspeção nRecnoQPK
@author brunno.costa
@since  23/05/2022
@param 01 - nRecnoQPK , numérico, número do recno da inspeção na QPK
@param 02 - cOrdem    , caracter, ordem para retorno dos resultados do banco
@param 03 - aRecnosQPR, array   , NIL e Vazio para retornar todos ou array com os RECNOS da QPR para receber na resposta do POST
@param 04 - nPagina   , numérico, página atual dos dados para consulta
@param 05 - nTamPag   , numérico, tamanho de página padrão com a quantidade de registros para retornar
@param 06 - cCampos   , caracter, campos que deverão estar contidos na mensagem
@param 07 - lMedicao  , lógico  , retorna por referência indicando se existem Medições relacionadas
@return lSucesso, lógico, indica se o processo foi executado com sucesso
/*/
METHOD RetornaResultadosInspecao(nRecnoQPK, cOrdem, aRecnosQPR, nPagina, nTamPag, cCampos, lMedicao) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	
	Local cAlias      := Nil
	Local cFIlQAA     := xFilial("QAA")
	Local cFilQP7     := xFilial("QP7")
	Local cFilQP8     := xFilial("QP8")
	Local cFilQPQ     := xFilial("QPQ")
	Local cFIlQPR     := xFilial("QPR")
	Local cFIlQPS     := xFilial("QPS")
	Local cINRecQPR   := ""
	Local cOrdemDB    := Nil
    Local cQuery      := ""
	Local lSucesso    := .T.
    Local oAPIManager := QualityAPIManager():New(Self:MapeiaCamposAPI(cCampos), Self:oWSRestFul)
	Local oExec		  := Nil

	Default cOrdem   := "measurementDate,measurementTime"
	Default nPagina  := 1
	Default nTamPag  := 99
	Default lMedicao := .F.

	If Self:NaoImplantado() .AND. Self:lProcessaRetorno
		SetRestFault(405, EncodeUtf8(STR0039), .T.,; //"Módulo não está implantado"
		             405, EncodeUtf8(STR0040))       //"Fale com a TOTVS e faça implantação do módulo!"
		Return
	EndIf

	nRecnoQPK := Iif(ValType(nRecnoQPK)=="C", Val(nRecnoQPK), nRecnoQPK)
	nRecnoQPK := Iif(ValType(nRecnoQPK)!="N", -1            , nRecnoQPK)

	//cQuery +=  " /*INICIO MONTAGEM QUERY RECURSIVA*/ "
	cQuery +=  " WITH Query_Recursiva (Recursao, QPS_CODMED, QPS_MEDICA, Recno) "
	cQuery +=  " AS "
	cQuery +=  " ( "
	//cQuery +=      " /*INICIO 1 ANCORA DA RECURSIVIDADE*/ "
	cQuery +=      " SELECT 1 As Recursao, "
	cQuery +=              " QPS_CODMED, "
	cQuery +=              "CONCAT(CONCAT('" + '"' + "', Cast(QPS_MEDICA as VarChar(8000)) ),'" + '"' + "')" + " MEDICAO, "
	cQuery +=              " R_E_C_N_O_ Recno "
	cQuery +=      " FROM " + RetSQLName("QPS") + " QPS "
	cQuery +=      " INNER JOIN "
	cQuery +=          " (SELECT QPR_OP, QPR_PRODUT, QPR_REVI, QPR_CHAVE, QPR_ROTEIR, QPR_AMOSTR, QPR_LOTE, QPR_NUMSER  "
	cQuery +=           " FROM " + RetSQLName("QPR")
	cQuery +=           " WHERE   (D_E_L_E_T_ = ' ') "
	cQuery +=               " AND (QPR_FILIAL = '" + cFilQPR + "')) "
	cQuery +=          " QPR  "
	cQuery +=      " ON QPR.QPR_CHAVE = QPS_CODMED "

	cQuery +=      " INNER JOIN "
	cQuery +=        "(SELECT C2_NUM, C2_ITEM, C2_ITEMGRD, C2_SEQUEN, C2_ROTEIRO "
	cQuery +=        " FROM " + RetSQLName("SC2") + " "
	cQuery +=        " WHERE D_E_L_E_T_=' ' AND C2_FILIAL = '" + xFilial("SC2") + "') SC2 "
	cQuery +=      " ON " + Self:oApiManager:oQueryManager:MontaRelationC2OP("QPR_OP")
	cQuery +=      Iif(SuperGetMV("MV_QIPOPEP") == "3", " AND (QPR_ROTEIR = C2_ROTEIRO OR QPR_ROTEIR = '" + QIPRotGene("QPR_ROTEIR") + "') ", " AND QPR_ROTEIR = C2_ROTEIRO ")

	cQuery +=      " INNER JOIN "
	cQuery +=          " (SELECT QPK_OP, QPK_PRODUT, QPK_REVI, QPK_LOTE, QPK_NUMSER "
	cQuery +=              " FROM " + RetSQLName("QPK")
	cQuery +=              " WHERE (D_E_L_E_T_ = ' ') "
	cQuery +=              " AND (R_E_C_N_O_ = " + cValToChar(nRecnoQPK) + ")) "
	cQuery +=          " QPK  "
	cQuery +=      " ON      QPR.QPR_OP     = QPK.QPK_OP "
	cQuery +=          " AND QPR.QPR_PRODUT = QPK.QPK_PRODUT "
	cQuery +=          " AND QPR.QPR_REVI   = QPK.QPK_REVI "
	cQuery +=          " AND QPR.QPR_LOTE   = QPK.QPK_LOTE "
	cQuery +=          " AND QPR.QPR_NUMSER = QPK.QPK_NUMSER "
	cQuery +=      " WHERE   QPS.D_E_L_E_T_ = ' ' "
	cQuery +=          " AND QPS.QPS_FILIAL = '" + cFilQPS + "' "
	//cQuery +=      " /*FIM 1 ANCORA DA RECURSIVIDADE*/ "
	cQuery +=      " UNION ALL "
	//cQuery +=      " /*INICIO RECURSIVIDADE*/ "
	cQuery +=      " SELECT  "
	cQuery +=          " Recursao + 1 as Recursao, "
	cQuery +=          " REC.QPS_CODMED, "
	cQuery +=          " CONCAT(CONCAT(CONCAT(REC.QPS_MEDICA , '," + '"' + "' ), QPS.QPS_MEDICA ), '" + '"' + "') AS MEDICAO, "
	cQuery +=          " QPS.Recno "
	cQuery +=      " FROM Query_Recursiva REC "
	cQuery +=      " INNER JOIN "
	cQuery +=          " (SELECT QPS_CODMED, QPS_MEDICA, R_E_C_N_O_ Recno "
	cQuery +=           " FROM " + RetSQLName("QPS")
	cQuery +=           " WHERE   D_E_L_E_T_ = ' ' "
	cQuery +=              " AND  QPS_FILIAL = '" + cFilQPS + "') QPS "
	cQuery +=      " ON      QPS.Recno > REC.Recno  "
	cQuery +=          " AND QPS.QPS_CODMED = REC.QPS_CODMED "
	//cQuery +=      " /*FIM RECURSIVIDADE*/ "
	cQuery +=   " ) "
	
	//cQuery +=   " /*FIM MONTAGEM QUERY RECURSIVA*/ "
	cQuery +=  " SELECT RECNOQPK, "
	cQuery +=  		  " RECNOTEST, "
	cQuery += 		  " QPR_DTMEDI, "
	cQuery += 		  " QPR_HRMEDI, "
	cQuery += 		  " QPR_ENSR, "
	cQuery += 		  " TIPO, "
	cQuery += 		  " CONCAT(CONCAT('[' , RTRIM(QPS_MEDICA)) , ']') AS MEDICOES, "
	cQuery += 		  " QPR_RESULT, "
	cQuery += 		  " QPQ_MEDICA, "
	cQuery += 		  " QAA_LOGIN, "
	cQuery += 		  " QAA_NOME, "
	cQuery += 		  " QPR_ENSAIO, "
	cQuery += 		  " RECNOQPR, "
	cQuery += 		  " QPR_AMOSTR, "

	If Self:lTemQQM
		cQuery += 		  " COALESCE(TEMANEXO,'F') TEMANEXO "
	Else
		cQuery += 		  " 'F' TEMANEXO "
	EndIf

	cQuery +=  " FROM Query_Recursiva  "
	cQuery +=  " INNER JOIN "
	cQuery +=      " (SELECT QPS_CODMED, Count(*) MAXRECURSAO "
	cQuery +=       " FROM " + RetSQLName("QPS")
	cQuery +=       " INNER JOIN "
	cQuery +=          " (SELECT QPR_OP, QPR_PRODUT, QPR_REVI, QPR_CHAVE, QPR_ROTEIR, QPR_AMOSTR, QPR_LOTE, QPR_NUMSER  "
	cQuery +=          " FROM " + RetSQLName("QPR")
	cQuery +=          " WHERE (D_E_L_E_T_ = ' ') "
	cQuery +=              " AND (QPR_FILIAL = '" + cFilQPR + "')) "
	cQuery +=          " QPR  "
	cQuery +=       " ON QPR.QPR_CHAVE = QPS_CODMED "

	cQuery +=       " INNER JOIN "
	cQuery +=         "(SELECT C2_NUM, C2_ITEM, C2_ITEMGRD, C2_SEQUEN, C2_ROTEIRO "
	cQuery +=         " FROM " + RetSQLName("SC2") + " "
	cQuery +=         " WHERE D_E_L_E_T_=' ' AND C2_FILIAL = '" + xFilial("SC2") + "') SC2 "
	cQuery +=       " ON " + Self:oApiManager:oQueryManager:MontaRelationC2OP("QPR_OP")
	cQuery +=       Iif(SuperGetMV("MV_QIPOPEP") == "3", " AND (QPR_ROTEIR = C2_ROTEIRO OR QPR_ROTEIR = '" + QIPRotGene("QPR_ROTEIR") + "') ", " AND QPR_ROTEIR = C2_ROTEIRO ")

	cQuery +=       " INNER JOIN "
	cQuery +=          " (SELECT QPK_OP, QPK_PRODUT, QPK_REVI, QPK_LOTE, QPK_NUMSER "
	cQuery +=          " FROM " + RetSQLName("QPK")
	cQuery +=          " WHERE   (D_E_L_E_T_ = ' ') "
	cQuery +=              " AND (R_E_C_N_O_ = " + cValToChar(nRecnoQPK) + " )) "
	cQuery +=          " QPK  "
	cQuery +=       " ON QPR.QPR_OP = QPK.QPK_OP  "
	cQuery +=          " AND QPR.QPR_PRODUT = QPK.QPK_PRODUT  "
	cQuery +=          " AND QPR.QPR_REVI   = QPK.QPK_REVI "
	cQuery +=          " AND QPR.QPR_LOTE   = QPK.QPK_LOTE "
	cQuery +=          " AND QPR.QPR_NUMSER = QPK.QPK_NUMSER "
	cQuery +=       " WHERE  D_E_L_E_T_ = ' ' "
	cQuery +=          " AND QPS_FILIAL = '" + cFilQPS + "' "
	cQuery +=       " GROUP BY QPS_CODMED) "
	cQuery +=       " QUERYMAXRECURSAO "
	cQuery +=  " ON    Query_Recursiva.QPS_CODMED = QUERYMAXRECURSAO.QPS_CODMED "
	cQuery +=      " AND Query_Recursiva.Recursao = QUERYMAXRECURSAO.MAXRECURSAO "
	cQuery +=  " INNER JOIN     "
	cQuery +=      " (    SELECT  "
	cQuery +=              " '' AS QPQ_MEDICA, "
	cQuery +=              " 'N' AS TIPO, "
	cQuery +=              " QPR.QPR_DTMEDI, "
	cQuery +=              " QPR.QPR_HRMEDI, "
	cQuery +=              " QPR.QPR_ENSR, "
	cQuery +=              " QPR.QPR_RESULT, "
	cQuery +=              " QPK.R_E_C_N_O_ RECNOQPK, "
	cQuery +=              " QPR.R_E_C_N_O_ RECNOQPR, "
	cQuery +=              " QAA.QAA_LOGIN, "
	cQuery +=              " QAA.QAA_NOME, "
	cQuery +=              " QPR.QPR_ENSAIO, "
	cQuery +=              " QP7.R_E_C_N_O_ RECNOTEST, "
	cQuery +=              " QPR_CHAVE, "
	cQuery +=              " QPR.QPR_AMOSTR, "
	cQuery +=              " QPR.QPR_FILIAL "
	cQuery +=          " FROM            "
	cQuery +=                  " (SELECT QPR_OP, QPR_PRODUT, QPR_REVI, QPR_DTMEDI, QPR_HRMEDI, QPR_ENSR, QPR_RESULT, R_E_C_N_O_, QPR_LABOR, QPR_ENSAIO, QPR_OPERAC, QPR_CHAVE, QPR_ROTEIR, QPR_AMOSTR, QPR_LOTE, QPR_NUMSER, QPR_FILIAL "
	cQuery +=                  " FROM " + RetSQLName("QPR")
	cQuery +=                  " WHERE (D_E_L_E_T_ = ' ') "
	cQuery +=                      " AND (QPR_FILIAL = '" + cFilQPR + "')) "
	cQuery +=                  " QPR  "

	cQuery +=              " INNER JOIN "
	cQuery +=                "(SELECT C2_NUM , C2_ITEM, C2_ITEMGRD, C2_SEQUEN, C2_ROTEIRO "
	cQuery +=                " FROM " + RetSQLName("SC2") + " "
	cQuery +=                " WHERE D_E_L_E_T_=' ' AND C2_FILIAL = '" + xFilial("SC2") + "') SC2 "
	cQuery +=              " ON " + Self:oApiManager:oQueryManager:MontaRelationC2OP("QPR_OP")
	cQuery +=              Iif(SuperGetMV("MV_QIPOPEP") == "3", " AND (QPR_ROTEIR = C2_ROTEIRO OR QPR_ROTEIR = '" + QIPRotGene("QPR_ROTEIR") + "') ", " AND QPR_ROTEIR = C2_ROTEIRO ")

	cQuery +=              " INNER JOIN "
	cQuery +=                  " (SELECT QPK_OP, QPK_PRODUT, QPK_REVI, R_E_C_N_O_, QPK_LOTE, QPK_NUMSER "
	cQuery +=                  " FROM " + RetSQLName("QPK")
	cQuery +=                  " WHERE (D_E_L_E_T_ = ' ') "
	cQuery +=                      " AND (R_E_C_N_O_ = " + cValToChar(nRecnoQPK) + ")) "
	cQuery +=                  " QPK  "
	cQuery +=              " ON QPR.QPR_OP = QPK.QPK_OP "
	cQuery +=                  " AND QPR.QPR_PRODUT = QPK.QPK_PRODUT "
	cQuery +=                  " AND QPR.QPR_REVI   = QPK.QPK_REVI "
	cQuery +=                  " AND QPR.QPR_LOTE   = QPK.QPK_LOTE "
	cQuery +=                  " AND QPR.QPR_NUMSER = QPK.QPK_NUMSER "
	cQuery +=              " INNER JOIN "
	cQuery +=                  " (SELECT QAA_LOGIN, QAA_MAT, QAA_NOME "
	cQuery +=                   " FROM " + RetSQLName("QAA")
	cQuery +=                  " WHERE D_E_L_E_T_=' ' "
	cQuery +=                      " AND QAA_FILIAL='" + cFilQAA + "') "
	cQuery +=                  " QAA "
	cQuery +=              " ON QAA.QAA_MAT = QPR.QPR_ENSR "
	cQuery +=              " INNER JOIN "
	cQuery +=                  " (SELECT QP7_PRODUT, QP7_REVI, QP7_ENSAIO, QP7_LABOR, R_E_C_N_O_, QP7_OPERAC, QP7_CODREC "
	cQuery +=                   " FROM " + RetSQLName("QP7")
	cQuery +=                   " WHERE D_E_L_E_T_  = ' ' "
	cQuery +=                      " AND QP7_FILIAL = '" + cFilQP7 + "') "
	cQuery +=              " QP7 "
	cQuery +=              " ON QP7.QP7_PRODUT   = QPR.QPR_PRODUT  "
	cQuery +=               " AND QP7.QP7_REVI   = QPR.QPR_REVI "
	cQuery +=               " AND QP7.QP7_LABOR  = QPR.QPR_LABOR "
	cQuery +=               " AND QP7.QP7_ENSAIO = QPR.QPR_ENSAIO "
	cQuery +=               " AND QP7.QP7_OPERAC = QPR.QPR_OPERAC "
	cQuery +=               " AND QP7.QP7_CODREC = QPR.QPR_ROTEIR "
	cQuery +=      " ) NAORECURSIVA  "
	cQuery +=  " ON NAORECURSIVA.QPR_CHAVE = Query_Recursiva.QPS_CODMED "

	If Self:lTemQQM
		cQuery += 		 " LEFT OUTER JOIN "
		cQuery += 		  " (SELECT DISTINCT 'T' TEMANEXO, "
		cQuery += 		 		   " QQM_FILQPR,  "
		cQuery += 				   " QQM_CHAVE "
		cQuery += 		  " FROM " + RetSqlName("QQM")
		cQuery +=					" WHERE D_E_L_E_T_ = ' ' ) QQM ON QPR_CHAVE  = QQM.QQM_CHAVE "
		cQuery += 												" AND QPR_FILIAL = QQM_FILQPR "
	EndIf
	
	If aRecnosQPR != Nil .And. !Empty(aRecnosQPR)
		cINRecQPR := FormatIn(ArrToKStr(aRecnosQPR),"|")
		cQuery    += "WHERE RECNOQPR IN " + cINRecQPR
	EndIf

	cQuery +=  " UNION "

	//RESULTADO DE TEXTO
	cQuery += " SELECT   "
	cQuery +=     " QPK.R_E_C_N_O_ RECNOQPK, "
	cQuery +=     " QP8.R_E_C_N_O_ RECNOTEST, "
	cQuery +=     " QPR.QPR_DTMEDI, "
	cQuery +=     " QPR.QPR_HRMEDI, "
	cQuery +=     " QPR.QPR_ENSR, "
	cQuery +=     " 'T' AS TIPO, "
	cQuery +=     " '[]' AS MEDICOES, "
	cQuery +=     " QPR.QPR_RESULT, "
	cQuery +=     " QPQ_MEDICA, "
	cQuery +=     " QAA.QAA_LOGIN, "
	cQuery +=     " QAA.QAA_NOME, "
	cQuery +=     " QPR.QPR_ENSAIO, "
	cQuery +=     " QPR.R_E_C_N_O_ RECNOQPR, "
	cQuery +=     " QPR.QPR_AMOSTR, "
	If Self:lTemQQM
		cQuery +=     " COALESCE(TEMANEXO,'F') TEMANEXO "
	Else
		cQuery +=     " 'F' TEMANEXO "
	EndIf
	cQuery += " FROM "
	cQuery +=         " (SELECT QPR_OP, QPR_PRODUT, QPR_REVI, QPR_DTMEDI, QPR_HRMEDI, QPR_ENSR, QPR_RESULT, R_E_C_N_O_, QPR_LABOR, QPR_ENSAIO, QPR_OPERAC, QPR_CHAVE, QPR_ROTEIR, QPR_AMOSTR, QPR_LOTE, QPR_NUMSER, QPR_FILIAL "
	cQuery +=         " FROM " + RetSQLName("QPR")
	cQuery +=         " WHERE (D_E_L_E_T_ = ' ') "
	cQuery +=             " AND (QPR_FILIAL = '" + cFilQPR + "')) "
	cQuery +=         " QPR "

	If Self:lTemQQM
		cQuery += 		 " LEFT OUTER JOIN "
		cQuery += 		  " (SELECT DISTINCT 'T' TEMANEXO, "
		cQuery += 		 		   " QQM_FILQPR,  "
		cQuery += 				   " QQM_CHAVE "
		cQuery += 		  " FROM " + RetSqlName("QQM")
		cQuery +=					" WHERE D_E_L_E_T_ = ' ' ) QQM ON QPR_CHAVE  = QQM.QQM_CHAVE "
		cQuery += 												" AND QPR_FILIAL = QQM_FILQPR "
	EndIf

	cQuery +=       " INNER JOIN "
	cQuery +=         "(SELECT C2_NUM, C2_ITEM, C2_ITEMGRD, C2_SEQUEN, C2_ROTEIRO "
	cQuery +=         " FROM " + RetSQLName("SC2") + " "
	cQuery +=         " WHERE D_E_L_E_T_=' ' AND C2_FILIAL = '" + xFilial("SC2") + "') SC2 "
	cQuery +=       " ON " + Self:oApiManager:oQueryManager:MontaRelationC2OP("QPR_OP")
	cQuery +=       Iif(SuperGetMV("MV_QIPOPEP") == "3", " AND (QPR_ROTEIR = C2_ROTEIRO OR QPR_ROTEIR = '" + QIPRotGene("QPR_ROTEIR") + "') ", " AND QPR_ROTEIR = C2_ROTEIRO ")

	cQuery +=     " INNER JOIN "
	cQuery +=         " (SELECT QPK_OP, QPK_PRODUT, QPK_REVI, R_E_C_N_O_, QPK_LOTE, QPK_NUMSER "
	cQuery +=         " FROM " + RetSQLName("QPK")
	cQuery +=         " WHERE (D_E_L_E_T_ = ' ') "
	cQuery +=             " AND (R_E_C_N_O_ =  " + cValToChar(nRecnoQPK) + " )) "
	cQuery +=         " QPK "
	cQuery +=     " ON QPR.QPR_OP = QPK.QPK_OP "
	cQuery +=      " AND QPR.QPR_PRODUT = QPK.QPK_PRODUT "
	cQuery +=      " AND QPR.QPR_REVI   = QPK.QPK_REVI "
	cQuery +=      " AND QPR.QPR_LOTE   = QPK.QPK_LOTE "
	cQuery +=      " AND QPR.QPR_NUMSER = QPK.QPK_NUMSER "
	cQuery +=     " INNER JOIN "
	cQuery +=         " (SELECT QAA_LOGIN, QAA_MAT, QAA_NOME "
	cQuery +=         " FROM " + RetSQLName("QAA")
	cQuery +=         " WHERE D_E_L_E_T_=' ' "
	cQuery +=             " AND QAA_FILIAL='" + cFilQAA + "') "
	cQuery +=         " QAA "
	cQuery +=     " ON QAA.QAA_MAT = QPR.QPR_ENSR "
	cQuery +=     " INNER JOIN "
	cQuery +=         " (SELECT QP8_PRODUT, QP8_REVI, QP8_ENSAIO, QP8_LABOR, R_E_C_N_O_, QP8_OPERAC, QP8_CODREC "
	cQuery +=         " FROM " + RetSQLName("QP8")
	cQuery +=         " WHERE D_E_L_E_T_  = ' ' "
	cQuery +=             " AND QP8_FILIAL = '" + cFilQP8 + "') "
	cQuery +=     " QP8 "
	cQuery +=     " ON QP8.QP8_PRODUT   = QPR.QPR_PRODUT "
	cQuery +=      " AND QP8.QP8_REVI   = QPR.QPR_REVI "
	cQuery +=      " AND QP8.QP8_LABOR  = QPR.QPR_LABOR "
	cQuery +=      " AND QP8.QP8_ENSAIO = QPR.QPR_ENSAIO "
	cQuery +=      " AND QP8.QP8_OPERAC = QPR.QPR_OPERAC "
	cQuery +=      " AND QP8.QP8_CODREC = QPR.QPR_ROTEIR "

	cQuery += 	" INNER JOIN "
	cQuery +=     " (SELECT QPQ_CODMED, QPQ_MEDICA "
	cQuery +=  	  " FROM " + RetSQLName("QPQ")
	cQuery +=  	  " WHERE (D_E_L_E_T_ = ' ') "
	cQuery +=         " AND QPQ_FILIAL = '" + cFilQPQ + "') "
	cQuery +=     " QPQ "
	cQuery +=     " ON QPQ.QPQ_CODMED = QPR.QPR_CHAVE "

	If aRecnosQPR != Nil .And. !Empty(aRecnosQPR)
		cQuery    += "WHERE QPR.R_E_C_N_O_ IN " + cINRecQPR
	EndIf

	cOrdemDB := oAPIManager:RetornaOrdemDB(cOrdem)
	If !Empty(cOrdemDB)
		cQuery += " ORDER BY " + cOrdemDB
	EndIf
	
    cQuery := oAPIManager:ChangeQueryAllDB(cQuery)

	Self:cErrorMessage := STR0007 + cQuery //"Erro na execução da query: "
	
	oExec := FwExecStatement():New(cQuery)
    cAlias := oExec:OpenAlias()

	Self:cErrorMessage := ""

	lMedicao := (cAlias)->(!Eof())
	If Self:lProcessaRetorno
    	lSucesso := oAPIManager:ProcessaListaResultados(cAlias, nPagina, nTamPag)
	EndIf

    (cAlias)->(dbCloseArea())
	oExec:Destroy()
	oExec := nil 
Return lSucesso

/*/{Protheus.doc} RetornaResultadosInspecaoPorEnsaio
Retorna a Lista de Resultados da Inspeção nRecnoQPK
@author brunno.costa
@since  23/05/2022
@param 01 - nRecnoQPK , numérico, número do recno da inspeção na QPK
@param 02 - cOrdem    , caracter, ordem para retorno dos resultados do banco
@param 03 - cIDTest   , caracter, ID do ensaio relacionado
@param 04 - cOperacao , caracter, código da operação relacionada
@param 05 - nPagina   , numérico, página atual dos dados para consulta
@param 06 - nTamPag   , numérico, tamanho de página padrão com a quantidade de registros para retornar
@param 07 - cCampos   , caracter, campos que deverão estar contidos na mensagem
@return lSucesso, lógico, indica se o processo foi executado com sucesso
/*/
METHOD RetornaResultadosInspecaoPorEnsaio(nRecnoQPK, cOrdem, cIDTest, cOperacao, nPagina, nTamPag, cCampos) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	
	Local cAlias      := Nil
	Local lSucesso    := .T.
    Local oAPIManager := QualityAPIManager():New(Self:MapeiaCamposAPI(cCampos), Self:oWSRestFul)

	Default cOrdem  := "measurementDate,measurementTime"
	Default nPagina := 1
	Default nTamPag := 99

	If Self:NaoImplantado()
		SetRestFault(405, EncodeUtf8(STR0039), .T.,; //"Módulo não está implantado"
		             405, EncodeUtf8(STR0040))       //"Fale com a TOTVS e faça implantação do módulo!"
		Return
	EndIf

	If (lSucesso := Self:CriaAliasResultadosInspecaoPorEnsaio(nRecnoQPK, cOrdem, cIDTest, cOperacao, nPagina, nTamPag, cCampos, @cAlias, oAPIManager))
    	lSucesso := oAPIManager:ProcessaListaResultados(cAlias, nPagina, nTamPag)
	EndIf

    (cAlias)->(dbCloseArea())

Return lSucesso

/*/{Protheus.doc} CriaAliasResultadosInspecao
Cria Alias para Retornar a Lista de Resultados da Inspeção nRecnoQPK
@author brunno.costa
@since  23/05/2022
@param 01 - nRecnoQPK , numérico, número do recno da inspeção na QPK
@param 02 - cOrdem    , caracter, ordem para retorno dos resultados do banco
@param 03 - cIDTest   , caracter, ID do ensaio relacionado
@param 04 - cOperacao , caracter, operação da inspeção relacionada
@param 05 - nPagina   , numérico, página atual dos dados para consulta
@param 06 - nTamPag   , numérico, tamanho de página padrão com a quantidade de registros para retornar
@param 07 - cCampos   , caracter, campos que deverão estar contidos na mensagem
@return lSucesso, lógico, indica se o processo foi executado com sucesso
/*/
METHOD CriaAliasResultadosInspecaoPorEnsaio(nRecnoQPK, cOrdem, cIDTest, cOperacao, nPagina, nTamPag, cCampos, cAlias, oAPIManager) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	
	Local aBindParam := {}
	Local cFIlQAA    := xFilial("QAA")
	Local cFilQP7    := xFilial("QP7")
	Local cFilQP8    := xFilial("QP8")
	Local cFilQPQ    := xFilial("QPQ")
	Local cFIlQPR    := xFilial("QPR")
	Local cFIlQPS    := xFilial("QPS")
	Local cOrdemDB   := Nil
    Local cQuery     := ""
	Local lSucesso   := .T.

	Default cOrdem      := "measurementDate,measurementTime"
	Default nPagina     := 1
	Default nTamPag     := 99
    Default oAPIManager := QualityAPIManager():New(Self:MapeiaCamposAPI(cCampos), Self:oWSRestFul)

	nRecnoQPK := Iif(ValType(nRecnoQPK)=="C", Val(nRecnoQPK), nRecnoQPK)
	nRecnoQPK := Iif(ValType(nRecnoQPK)!="N", -1            , nRecnoQPK)

	//cQuery +=  " /*INICIO MONTAGEM QUERY RECURSIVA*/ "
	cQuery +=  " WITH Query_Recursiva (Recursao, QPS_CODMED, QPS_MEDICA, Recno) "
	cQuery +=  " AS "
	cQuery +=  " ( "
	//cQuery +=      " /*INICIO 1 ANCORA DA RECURSIVIDADE*/ "
	cQuery +=      " SELECT 1 As Recursao, "
	cQuery +=              " QPS_CODMED, "
	cQuery +=              "CONCAT(CONCAT('" + '"' + "', Cast(QPS_MEDICA as VarChar(8000))) ,'" + '"' + "')" + " MEDICAO, "
	cQuery +=              " R_E_C_N_O_ Recno "
	cQuery +=      " FROM " + RetSQLName("QPS") + " QPS "
	cQuery +=      " INNER JOIN "
	cQuery +=          " (SELECT QPR_OP, QPR_PRODUT, QPR_REVI, QPR_CHAVE, QPR_ROTEIR, QPR_AMOSTR, QPR_LOTE, QPR_NUMSER  "
	cQuery +=           " FROM " + RetSQLName("QPR")
	
	cQuery +=           " WHERE   (QPR_FILIAL = ?) "
	cQuery +=               " AND (D_E_L_E_T_ = ?)) "
	aAdd(aBindParam, {cFilQPR, "S"})
	aAdd(aBindParam, {" "    , "S"})

	cQuery +=          " QPR  "
	cQuery +=      " ON QPR.QPR_CHAVE = QPS_CODMED "

	cQuery +=      " INNER JOIN "
	cQuery +=        "(SELECT C2_NUM, C2_ITEM, C2_ITEMGRD, C2_SEQUEN, C2_ROTEIRO "
	cQuery +=        " FROM " + RetSQLName("SC2") + " "
	
	cQuery +=        " WHERE C2_FILIAL = ? AND D_E_L_E_T_ = ? ) SC2 "
	aAdd(aBindParam, {xFilial("SC2"), "S"})
	aAdd(aBindParam, {" "           , "S"})

	cQuery +=      " ON " + Self:oApiManager:oQueryManager:MontaRelationC2OP("QPR_OP")
	cQuery +=      Iif(SuperGetMV("MV_QIPOPEP") == "3", " AND (QPR_ROTEIR = C2_ROTEIRO OR QPR_ROTEIR = '" + QIPRotGene("QPR_ROTEIR") + "') ", " AND QPR_ROTEIR = C2_ROTEIRO ")

	cQuery +=      " INNER JOIN "
	cQuery +=          " (SELECT QPK_OP, QPK_PRODUT, QPK_REVI, QPK_LOTE, QPK_NUMSER "
	cQuery +=              " FROM " + RetSQLName("QPK")
	
	cQuery +=              " WHERE (R_E_C_N_O_ = ?) "
	cQuery +=              "   AND (D_E_L_E_T_ = ?) ) "
	aAdd(aBindParam, {nRecnoQPK, "N"})
	aAdd(aBindParam, {" "      , "S"})

	cQuery +=          " QPK  "
	cQuery +=      " ON      QPR.QPR_OP     = QPK.QPK_OP "
	cQuery +=          " AND QPR.QPR_PRODUT = QPK.QPK_PRODUT "
	cQuery +=          " AND QPR.QPR_REVI   = QPK.QPK_REVI "
	cQuery +=          " AND QPR.QPR_LOTE   = QPK.QPK_LOTE "
	cQuery +=          " AND QPR.QPR_NUMSER = QPK.QPK_NUMSER "
	
	cQuery +=      " WHERE   QPS.QPS_FILIAL = ? "
	cQuery +=          " AND QPS.D_E_L_E_T_ = ? "
	aAdd(aBindParam, {cFilQPS  , "S"})
	aAdd(aBindParam, {" "      , "S"})

	//cQuery +=      " /*FIM 1 ANCORA DA RECURSIVIDADE*/ "
	cQuery +=      " UNION ALL "
	//cQuery +=      " /*INICIO RECURSIVIDADE*/ "
	cQuery +=      " SELECT  "
	cQuery +=          " Recursao + 1 as Recursao, "
	cQuery +=          " REC.QPS_CODMED, "
	cQuery +=          " CONCAT(CONCAT(CONCAT(REC.QPS_MEDICA , '," + '"' + "') , QPS.QPS_MEDICA) , '" + '"' + "') MEDICAO, "
	cQuery +=          " QPS.Recno "
	cQuery +=      " FROM Query_Recursiva REC "
	cQuery +=      " INNER JOIN "
	cQuery +=          " (SELECT QPS_CODMED, QPS_MEDICA, R_E_C_N_O_ Recno "
	cQuery +=           " FROM " + RetSQLName("QPS")
	
	cQuery +=           " WHERE   QPS_FILIAL = ? "
	cQuery +=              " AND  D_E_L_E_T_ = ? ) QPS "
	aAdd(aBindParam, {cFilQPS  , "S"})
	aAdd(aBindParam, {" "      , "S"})

	cQuery +=      " ON      QPS.Recno > REC.Recno  "
	cQuery +=          " AND QPS.QPS_CODMED = REC.QPS_CODMED "
	//cQuery +=      " /*FIM RECURSIVIDADE*/ "
	cQuery +=   " ) "
	
	//cQuery +=   " /*FIM MONTAGEM QUERY RECURSIVA*/ "
	cQuery +=  " SELECT RECNOQPK, "
	cQuery +=         " RECNOTEST, "
	cQuery +=         " QPR_DTMEDI, "
	cQuery +=         " QPR_HRMEDI, "
	cQuery +=         " QPR_ENSR, "
	cQuery +=         " TIPO, "
	cQuery +=         " CONCAT(CONCAT('[' , RTRIM(QPS_MEDICA)) , ']') MEDICOES, "
	cQuery +=         " QPR_RESULT, "
	cQuery +=         " QPQ_MEDICA, "
	cQuery +=         " QAA_LOGIN, "
	cQuery +=         " QAA_NOME, "
	cQuery +=         " QPR_ENSAIO, "
	cQuery +=         " RECNOQPR, "
	cQuery +=         " QPR_AMOSTR, "
	
	If Self:lTemQQM
		cQuery +=         " COALESCE(TEMANEXO,'F') TEMANEXO "
	Else
		cQuery +=         " 'F' TEMANEXO "
	EndIf

	cQuery +=  " FROM Query_Recursiva  "
	cQuery +=  " INNER JOIN "
	cQuery +=      " (SELECT QPS_CODMED, Count(*) MAXRECURSAO "
	cQuery +=       " FROM " + RetSQLName("QPS")
	cQuery +=       " INNER JOIN "
	cQuery +=          " (SELECT QPR_OP, QPR_PRODUT, QPR_REVI, QPR_CHAVE, QPR_ROTEIR, QPR_AMOSTR, QPR_LOTE, QPR_NUMSER  "
	cQuery +=          " FROM " + RetSQLName("QPR")
	
	cQuery +=          " WHERE   (QPR_FILIAL = ?) "
	cQuery +=              " AND (D_E_L_E_T_ = ?)) "
	aAdd(aBindParam, {cFilQPR  , "S"})
	aAdd(aBindParam, {" "      , "S"})

	cQuery +=          " QPR  "
	cQuery +=       " ON QPR.QPR_CHAVE = QPS_CODMED "

	cQuery +=       " INNER JOIN "
	cQuery +=         "(SELECT C2_NUM, C2_ITEM, C2_ITEMGRD, C2_SEQUEN, C2_ROTEIRO "
	cQuery +=         " FROM " + RetSQLName("SC2") + " "
	
	cQuery +=         " WHERE  C2_FILIAL = ? AND D_E_L_E_T_ = ?) SC2 "
	aAdd(aBindParam, {xFilial("SC2"), "S"})
	aAdd(aBindParam, {" "           , "S"})

	cQuery +=       " ON " + Self:oApiManager:oQueryManager:MontaRelationC2OP("QPR_OP")	
	cQuery +=       Iif(SuperGetMV("MV_QIPOPEP") == "3", " AND (QPR_ROTEIR = C2_ROTEIRO OR QPR_ROTEIR = '" + QIPRotGene("QPR_ROTEIR") + "') ", " AND QPR_ROTEIR = C2_ROTEIRO ")

	cQuery +=       " INNER JOIN "
	cQuery +=          " (SELECT QPK_OP, QPK_PRODUT, QPK_REVI, QPK_LOTE, QPK_NUMSER "
	cQuery +=          " FROM " + RetSQLName("QPK")
	
	cQuery +=          " WHERE   (R_E_C_N_O_ = ? ) "
	cQuery +=              " AND (D_E_L_E_T_ = ?)) "
	aAdd(aBindParam, {nRecnoQPK, "N"})
	aAdd(aBindParam, {" "      , "S"})

	cQuery +=          " QPK  "
	cQuery +=       " ON QPR.QPR_OP = QPK.QPK_OP  "
	cQuery +=          " AND QPR.QPR_PRODUT = QPK.QPK_PRODUT  "
	cQuery +=          " AND QPR.QPR_REVI   = QPK.QPK_REVI "
	cQuery +=          " AND QPR.QPR_LOTE   = QPK.QPK_LOTE "
	cQuery +=          " AND QPR.QPR_NUMSER = QPK.QPK_NUMSER "
	
	cQuery +=       " WHERE  QPS_FILIAL = ? "
	cQuery +=          " AND D_E_L_E_T_ = ? "
	aAdd(aBindParam, {cFilQPS  , "S"})
	aAdd(aBindParam, {" "      , "S"})

	cQuery +=       " GROUP BY QPS_CODMED) "
	cQuery +=       " QUERYMAXRECURSAO "
	cQuery +=  " ON    Query_Recursiva.QPS_CODMED = QUERYMAXRECURSAO.QPS_CODMED "
	cQuery +=      " AND Query_Recursiva.Recursao = QUERYMAXRECURSAO.MAXRECURSAO "
	cQuery +=  " INNER JOIN     "
	cQuery +=      " (    SELECT  "
	cQuery +=              " '' QPQ_MEDICA, "
	cQuery +=              " 'N' TIPO, "
	cQuery +=              " QPR.QPR_DTMEDI, "
	cQuery +=              " QPR.QPR_HRMEDI, "
	cQuery +=              " QPR.QPR_ENSR, "
	cQuery +=              " QPR.QPR_RESULT, "
	cQuery +=              " QPK.R_E_C_N_O_ RECNOQPK, "
	cQuery +=              " QPR.R_E_C_N_O_ RECNOQPR, "
	cQuery +=              " QAA.QAA_LOGIN, "
	cQuery +=              " QAA.QAA_NOME, "
	cQuery +=              " QPR.QPR_ENSAIO, "
	cQuery +=              " QP7.R_E_C_N_O_ RECNOTEST, "
	cQuery +=              " QPR_CHAVE, "
	cQuery +=              " QPR.QPR_AMOSTR, "
	cQuery += 			   " QPR.QPR_FILIAL  "
	cQuery +=          " FROM            "
	cQuery +=                  " (SELECT QPR_OP, QPR_PRODUT, QPR_REVI, QPR_DTMEDI, QPR_HRMEDI, QPR_ENSR, QPR_RESULT, R_E_C_N_O_, QPR_LABOR, QPR_ENSAIO, QPR_OPERAC, QPR_CHAVE, QPR_ROTEIR, QPR_AMOSTR, QPR_LOTE, QPR_NUMSER, QPR_FILIAL "
	cQuery +=                  " FROM " + RetSQLName("QPR")
	cQuery +=                  " WHERE (QPR_FILIAL = ?) "
	aAdd(aBindParam, {cFilQPR  , "S"})

	If !Empty(cOperacao)
		cQuery +=                " AND (QPR_OPERAC = ?) "
		aAdd(aBindParam, {cOperacao, "S"})
	EndIf

	cQuery +=                      " AND (D_E_L_E_T_ = ?) ) "
	aAdd(aBindParam, {" "      , "S"})

	cQuery +=                  " QPR  "

	cQuery +=              " INNER JOIN "
	cQuery +=                "(SELECT C2_NUM, C2_ITEM, C2_ITEMGRD, C2_SEQUEN, C2_ROTEIRO "
	cQuery +=                " FROM " + RetSQLName("SC2") + " "
	
	cQuery +=                " WHERE C2_FILIAL = ? AND D_E_L_E_T_ = ?) SC2 "
	aAdd(aBindParam, {xFilial("SC2"), "S"})
	aAdd(aBindParam, {" "           , "S"})

	cQuery +=              " ON " + Self:oApiManager:oQueryManager:MontaRelationC2OP("QPR_OP")
	cQuery +=              Iif(SuperGetMV("MV_QIPOPEP") == "3", " AND (QPR_ROTEIR = C2_ROTEIRO OR QPR_ROTEIR = '" + QIPRotGene("QPR_ROTEIR") + "') ", " AND QPR_ROTEIR = C2_ROTEIRO ")

	cQuery +=              " INNER JOIN "
	cQuery +=                  " (SELECT QPK_OP, QPK_PRODUT, QPK_REVI, R_E_C_N_O_, QPK_LOTE, QPK_NUMSER "
	cQuery +=                  " FROM " + RetSQLName("QPK")
	
	cQuery +=                  " WHERE   (R_E_C_N_O_ = ?) "
	cQuery +=                      " AND (D_E_L_E_T_ = ?)) "
	aAdd(aBindParam, {nRecnoQPK, "N"})
	aAdd(aBindParam, {" "      , "S"})

	cQuery +=                  " QPK  "
	cQuery +=              " ON QPR.QPR_OP = QPK.QPK_OP "
	cQuery +=                  " AND QPR.QPR_PRODUT = QPK.QPK_PRODUT "
	cQuery +=                  " AND QPR.QPR_REVI   = QPK.QPK_REVI "
	cQuery +=                  " AND QPR.QPR_LOTE   = QPK.QPK_LOTE "
	cQuery +=                  " AND QPR.QPR_NUMSER = QPK.QPK_NUMSER "
	cQuery +=              " INNER JOIN "
	cQuery +=                  " (SELECT QAA_LOGIN, QAA_MAT, QAA_NOME "
	cQuery +=                   " FROM " + RetSQLName("QAA")
	
	cQuery +=                  " WHERE   QAA_FILIAL = ? "
	cQuery +=                      " AND D_E_L_E_T_ = ? ) "
	aAdd(aBindParam, {cFilQAA, "S"})
	aAdd(aBindParam, {" "    , "S"})

	cQuery +=                  " QAA "
	cQuery +=              " ON QAA.QAA_MAT = QPR.QPR_ENSR "
	cQuery +=              " INNER JOIN "
	cQuery +=                  " (SELECT QP7_PRODUT, QP7_REVI, QP7_ENSAIO, QP7_LABOR, R_E_C_N_O_, QP7_OPERAC, QP7_CODREC "
	cQuery +=                   " FROM " + RetSQLName("QP7")
	
	cQuery +=                   " WHERE QP7_FILIAL = ? "
	aAdd(aBindParam, {cFilQP7, "S"})

	If !Empty(cOperacao)
		cQuery +=                 " AND QP7_OPERAC = ? "
		aAdd(aBindParam, {cOperacao, "S"})
	EndIf
	
	If cIDTest != Nil .And. !Empty(cIDTest)
		cQuery +=                 " AND QP7_ENSAIO = ?"
		aAdd(aBindParam, {cIDTest, "S"})
	EndIf

	cQuery +=                      " AND D_E_L_E_T_  = ?) "
	aAdd(aBindParam, {" "    , "S"})

	cQuery +=              " QP7 "
	cQuery +=              " ON QP7.QP7_PRODUT   = QPR.QPR_PRODUT  "
	cQuery +=               " AND QP7.QP7_REVI   = QPR.QPR_REVI "
	cQuery +=               " AND QP7.QP7_LABOR  = QPR.QPR_LABOR "
	cQuery +=               " AND QP7.QP7_ENSAIO = QPR.QPR_ENSAIO "
	cQuery +=               " AND QP7.QP7_OPERAC = QPR.QPR_OPERAC "
	cQuery +=               " AND QP7.QP7_CODREC = QPR.QPR_ROTEIR "
	cQuery +=      " ) NAORECURSIVA  "
	cQuery +=  " ON NAORECURSIVA.QPR_CHAVE = Query_Recursiva.QPS_CODMED "

	If Self:lTemQQM
		cQuery += 		 " LEFT OUTER JOIN "
		cQuery += 		  " (SELECT DISTINCT 'T' TEMANEXO, "
		cQuery += 		 		   " QQM_FILQPR,  "
		cQuery += 				   " QQM_CHAVE "
		cQuery += 		  " FROM " + RetSqlName("QQM")
		cQuery +=					" WHERE D_E_L_E_T_ = ? ) QQM ON QPR_CHAVE  = QQM.QQM_CHAVE "
		cQuery += 										      " AND QPR_FILIAL = QQM_FILQPR "
		aAdd(aBindParam, {" "    , "S"})
	EndIf

	cQuery +=  " UNION "

	//RESULTADO DE TEXTO
	cQuery += " SELECT   "
	cQuery +=     " QPK.R_E_C_N_O_ RECNOQPK, "
	cQuery +=     " QP8.R_E_C_N_O_ RECNOTEST, "
	cQuery +=     " QPR.QPR_DTMEDI, "
	cQuery +=     " QPR.QPR_HRMEDI, "
	cQuery +=     " QPR.QPR_ENSR, "
	cQuery +=     " 'T' AS TIPO, "
	cQuery +=     " '[]' AS MEDICOES, "
	cQuery +=     " QPR.QPR_RESULT, "
	cQuery +=     " QPQ_MEDICA, "
	cQuery +=     " QAA.QAA_LOGIN, "
	cQuery +=     " QAA.QAA_NOME, "
	cQuery +=     " QPR.QPR_ENSAIO, "
	cQuery +=     " QPR.R_E_C_N_O_ RECNOQPR, "
	cQuery +=     " QPR.QPR_AMOSTR, "

	If Self:lTemQQM
	cQuery += 	  " COALESCE(TEMANEXO,'F') TEMANEXO "
	Else
		cQuery += 	  " 'F' TEMANEXO "
	EndIf
	cQuery += " FROM "
	cQuery +=         " (SELECT QPR_OP, QPR_PRODUT, QPR_REVI, QPR_DTMEDI, QPR_HRMEDI, QPR_ENSR, QPR_RESULT, R_E_C_N_O_, QPR_LABOR, QPR_ENSAIO, QPR_OPERAC, QPR_CHAVE, QPR_ROTEIR, QPR_AMOSTR, QPR_LOTE, QPR_NUMSER, QPR_FILIAL "
	cQuery +=         " FROM " + RetSQLName("QPR")
	
	cQuery +=         " WHERE (QPR_FILIAL = ?) "
	aAdd(aBindParam, {cFilQPR, "S"})

	If !Empty(cOperacao)
		cQuery +=       " AND (QPR_OPERAC = ?) "
		aAdd(aBindParam, {cOperacao, "S"})
	EndIf

	cQuery +=             " AND (D_E_L_E_T_ = ?)) "
	aAdd(aBindParam, {" "    , "S"})

	cQuery +=         " QPR "

	If Self:lTemQQM
		cQuery += 		 " LEFT OUTER JOIN "
		cQuery += 		  " (SELECT DISTINCT 'T' TEMANEXO, "
		cQuery += 		 		   " QQM_FILQPR,  "
		cQuery += 				   " QQM_CHAVE "
		cQuery += 		  " FROM " + RetSqlName("QQM")
		cQuery +=					" WHERE D_E_L_E_T_ = ? ) QQM ON QPR_CHAVE  = QQM.QQM_CHAVE "
		cQuery += 												" AND QPR_FILIAL = QQM_FILQPR "
		aAdd(aBindParam, {" "    , "S"})

	EndIf

	cQuery +=       " INNER JOIN "
	cQuery +=         "(SELECT C2_NUM, C2_ITEM, C2_ITEMGRD, C2_SEQUEN, C2_ROTEIRO "
	cQuery +=         " FROM " + RetSQLName("SC2") + " "
	
	cQuery +=         " WHERE C2_FILIAL = ? AND D_E_L_E_T_ = ?) SC2 "
	aAdd(aBindParam, {xFilial("SC2"), "S"})
	aAdd(aBindParam, {" "           , "S"})

	cQuery +=       " ON " + Self:oApiManager:oQueryManager:MontaRelationC2OP("QPR_OP")
	cQuery +=       Iif(SuperGetMV("MV_QIPOPEP") == "3", " AND (QPR_ROTEIR = C2_ROTEIRO OR QPR_ROTEIR = '" + QIPRotGene("QPR_ROTEIR") + "') ", " AND QPR_ROTEIR = C2_ROTEIRO ")

	cQuery +=     " INNER JOIN "
	cQuery +=         " (SELECT QPK_OP, QPK_PRODUT, QPK_REVI, R_E_C_N_O_, QPK_LOTE, QPK_NUMSER "
	cQuery +=         " FROM " + RetSQLName("QPK")
	
	cQuery +=         " WHERE   (R_E_C_N_O_ = ? ) "
	cQuery +=             " AND (D_E_L_E_T_ = ? )) "
	aAdd(aBindParam, {nRecnoQPK, "N"})
	aAdd(aBindParam, {" "      , "S"})

	cQuery +=         " QPK "
	cQuery +=     " ON QPR.QPR_OP = QPK.QPK_OP "
	cQuery +=      " AND QPR.QPR_PRODUT = QPK.QPK_PRODUT "
	cQuery +=      " AND QPR.QPR_REVI   = QPK.QPK_REVI "
	cQuery +=      " AND QPR.QPR_LOTE   = QPK.QPK_LOTE "
	cQuery +=      " AND QPR.QPR_NUMSER = QPK.QPK_NUMSER "
	cQuery +=     " INNER JOIN "
	cQuery +=         " (SELECT QAA_LOGIN, QAA_MAT, QAA_NOME "
	cQuery +=         " FROM " + RetSQLName("QAA")
	
	cQuery +=         " WHERE   QAA_FILIAL = ? "
	cQuery +=             " AND D_E_L_E_T_ = ?) "
	aAdd(aBindParam, {cFilQAA, "S"})
	aAdd(aBindParam, {" "    , "S"})

	cQuery +=         " QAA "
	cQuery +=     " ON QAA.QAA_MAT = QPR.QPR_ENSR "
	cQuery +=     " INNER JOIN "
	cQuery +=         " (SELECT QP8_PRODUT, QP8_REVI, QP8_ENSAIO, QP8_LABOR, R_E_C_N_O_, QP8_OPERAC, QP8_CODREC "
	cQuery +=         " FROM " + RetSQLName("QP8")
	
	cQuery +=         " WHERE QP8_FILIAL = ? "
	aAdd(aBindParam, {cFilQP8, "S"})
	
	If !Empty(cOperacao)
		cQuery +=      " AND (QP8_OPERAC = ?) "
		aAdd(aBindParam, {cOperacao, "S"})
	EndIf

	If cIDTest != Nil .And. !Empty(cIDTest)
		cQuery +=       " AND QP8_ENSAIO = ? "
		aAdd(aBindParam, {cIDTest, "S"})
	EndIf

	cQuery +=           " AND D_E_L_E_T_  = ?) "
	aAdd(aBindParam, {" "    , "S"})

	cQuery +=     " QP8 "
	cQuery +=     " ON QP8.QP8_PRODUT   = QPR.QPR_PRODUT "
	cQuery +=      " AND QP8.QP8_REVI   = QPR.QPR_REVI "
	cQuery +=      " AND QP8.QP8_LABOR  = QPR.QPR_LABOR "
	cQuery +=      " AND QP8.QP8_ENSAIO = QPR.QPR_ENSAIO "
	cQuery +=      " AND QP8.QP8_OPERAC = QPR.QPR_OPERAC "
	cQuery +=      " AND QP8.QP8_CODREC = QPR.QPR_ROTEIR "

	cQuery += 	" INNER JOIN "
	cQuery +=     " (SELECT QPQ_CODMED, QPQ_MEDICA "
	cQuery +=  	  " FROM " + RetSQLName("QPQ")
	
	cQuery +=  	  " WHERE    QPQ_FILIAL = ? "
	cQuery +=         " AND (D_E_L_E_T_ = ?) ) "
	aAdd(aBindParam, {cFilQPQ, "S"})
	aAdd(aBindParam, {" "    , "S"})

	cQuery +=     " QPQ "
	cQuery +=     " ON QPQ.QPQ_CODMED = QPR.QPR_CHAVE "


	cOrdemDB := oAPIManager:RetornaOrdemDB(cOrdem)
	If !Empty(cOrdemDB)
		cQuery += " ORDER BY " + cOrdemDB
	EndIf
	
    cQuery := oAPIManager:ChangeQueryAllDB(cQuery)

	Self:cErrorMessage := STR0007 + cQuery //"Erro na execução da query: "

    cAlias := self:oAPIManager:oQueryManager:executeQueryWithBind(cQuery, aBindParam, .F.)

	Self:cErrorMessage := ""

Return lSucesso

/*/{Protheus.doc} ProcessaItensRecebidos
Processa os Itens Recebidos
@author brunno.costa
@since  23/05/2022
@param 01 - oDadosJson   , objeto, objeto Json com os dados JSON recebidos da API para conversão
@param 02 - aRecnosQPR   , array , retorna por referência os RECNOS da QPR relacionados
@param 03 - cErrorMessage, string, retorna por referência a mensagem de erro
@return lSucesso, lógico, indica se o processo foi executado com sucesso
/*/
METHOD ProcessaItensRecebidos(oDadosJson, aRecnosQPR, cErrorMessage) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI

	Local lSucesso   := .T.
	Local nIndReg    := Nil
	Local oDadosCalc := Nil
	Local oItemAPI   := Nil
	Local oQNCClass  := Nil
	Local oRegistro  := Nil

	Default aRecnosQPR   := {}

	Self:nRegistros := Len(oDadosJson["items"])
	If Self:nRegistros <= 0
		lSucesso              := .F.
		//"Dados para Integração Inválidos"
		//"Não existem registros para gravação"
		Self:cErrorMessage    := STR0008
		Self:cDetailedMessage := STR0009
	Else

		Self:aCamposAPI             := Iif(Self:aCamposAPI == Nil, Self:MapeiaCamposAPI("*"), Self:aCamposAPI)
		Self:aCamposQPR             := IIf(Self:aCamposQPR == Nil, Self:MapeiaCamposQPR("*"), Self:aCamposQPR)

		If Self:nRegistros == 1
			Self:nAmostraTela := oDadosJson["items"][1]["sampleNumber"]
			Self:nAmostraTela := Iif(Empty(Self:nAmostraTela),2,Self:nAmostraTela)
		Endif

		oDadosJson['justCalculated'] := Iif(oDadosJson['justCalculated'] == Nil, Nil, oDadosJson['justCalculated'] == "true")
		If oDadosJson['justCalculated'] == Nil
			Self:RevisaEnsaiosCalculados(oDadosJson, @oDadosJson)
		
		//Avalia necessidade de processamento apenas dos ensaios calculados
		ElseIf oDadosJson['justCalculated']
			oDadosCalc          := JsonObject():New()
			oDadosCalc["items"] := {}
			Self:RevisaEnsaiosCalculados(oDadosJson, @oDadosCalc)
			oDadosJson["items"] := oDadosCalc["items"]
			Self:nRegistros     := Len(oDadosJson["items"])
		EndIf

		oDadosJson['responseItems'] := Iif(oDadosJson['responseItems'] == Nil, .F., oDadosJson['responseItems'])
		
		If slQLTMetrics
			QLTMetrics():enviaMetricaQuantidadeResultadosEnsaiosDigitadosQIP("API", Self:nRegistros)
		EndIf

		For nIndReg := 1 to Self:nRegistros
			oItemAPI := oDadosJson["items"][nIndReg]
			
			lSucesso := Self:ValidaFormatosCamposItem(oItemAPI)

			lSucesso := IIf(lSucesso, Self:ValidaUsuarioProtheus(oItemAPI), lSucesso)

			lSucesso := IIf(lSucesso, Self:PreparaRegistroQPR(oItemAPI, @oRegistro), lSucesso)

			Self:oAnexos:RegistraAnexos(oItemAPI, oRegistro, "QIP")

			lSucesso := IIf(lSucesso, Self:ValidaEnsaiador(oRegistro), lSucesso)

			lSucesso := IIf(lSucesso, Self:SalvaRegistros(oItemAPI, oRegistro, @aRecnosQPR), lSucesso)

			If !oDadosJson['justCalculated']
				sQNCClass := IIF(sQNCClass == Nil, FindClass("FichasNaoConformidadesAPI"), sQNCClass)
				If sQNCClass .AND. lSucesso .AND. oItemAPI["nonConformitiesList"] != Nil
					oQNCClass := IIF(oQNCClass == Nil, FichasNaoConformidadesAPI():New(), oQNCClass)
					lSucesso  := oQNCClass:processaRelacionamentoNCQIP(oRegistro["R_E_C_N_O_"], oItemAPI["nonConformitiesList"], @cErrorMessage)
				EndIf

				If lSucesso
					lSucesso  := Self:processaRelacionamentoInstrumento(oRegistro, oItemAPI, @cErrorMessage)
				EndIf
			EndIf		

			If !lSucesso
				Exit
			EndIf

			If Self:oAPIManager:existePEIntegracaoAppMinhaProducaoCompilado("QIP")
				Execblock('QIPINTAPI',.F.,.F.,{oRegistro, "processinspectiontestresults/api/qip/v1/save", "ResultadosEnsaiosInspecaoDeProcessosAPI", "complementoAmostra"})
			EndIf

		Next nIndReg

	EndIf
Return lSucesso

/*/{Protheus.doc} PreparaRegistroInclusaoQPR
Prepara Registro
@author brunno.costa
@since  23/05/2022
@param 01 - oItemAPI  , objeto, objeto Json com UM ITEM DOS REGISTROS JSON recebidos da API para conversão
@param 02 - oRegistro , objeto, retorna por referência os dados para gravação na tabela QPR do DB
@return lSucesso, lógico, indica se o processo foi executado com sucesso
/*/
METHOD PreparaRegistroInclusaoQPR(oItemAPI, oRegistro) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	
	Local cTipo      := Nil
	Local lSucesso   := .T.

	oRegistro := Self:oAPIManager:InicializaCamposPadroes("QPR",,.T.)
	oRegistro := Self:oAPIManager:AtualizaCamposAPINoRegistro(oItemAPI, oRegistro, "QPR", Self:aCamposAPI)

	cTipo := oItemAPI["testType"]
	
	If cTipo == "N"        //Tipo N -> Array Numérico -> QP7
		lSucesso := Self:RecuperaCamposQP7paraQPR(@oRegistro, oItemAPI["recnoTest"])

	ElseIf cTipo == "T"    //Tipo T -> Texto -> QP8
		lSucesso := Self:RecuperaCamposQP8paraQPR(@oRegistro, oItemAPI["recnoTest"])

	EndIf

	If lSucesso
		lSucesso := Self:RecuperaCamposQPKParaQPR(@oRegistro, oItemAPI["recnoInspection"])
	EndIf

	If lSucesso
		oRegistro["QPR_CHAVE"]     := oItemAPI["QPR_CHAVE"]
		If oItemAPI["QPR_CHAVE"] == Nil
			If Self:EnsaioComMedia(cTipo, QP7->QP7_FORMUL)
				Self:AtualizaChaveQPRParaMedia(oRegistro)
			Else
				oRegistro["QPR_CHAVE"] := Self:GeraChaveQPR()
			EndIf
			oItemAPI["QPR_CHAVE"]  := oRegistro["QPR_CHAVE"]
		EndIf
		Self:AtualizaEnsaiadorQPR(oItemAPI["protheusLogin"], @oRegistro)
	EndIf

Return lSucesso

/*/{Protheus.doc} EnsaioComMedia
Avalia se é um ensaio numérico com fórmula de média
@author brunno.costa
@since  04/10/2022
@return lEnsaioComMedia, lógico, indica se o ensaio atual corresponde a um registro numérico e com média na fórmula
/*/
METHOD EnsaioComMedia(cTipo, cFormula) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	Local lEnsaioComMedia := cTipo == "N" .AND. At("AVG", cFormula)
Return lEnsaioComMedia

/*/{Protheus.doc} GeraChaveQPR
Gecha próxima numeração para o campo QPR_CHAVE
@author brunno.costa
@since  23/05/2022
@return cChave, caracter, próxima numeração para a chave
/*/
METHOD GeraChaveQPR() CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	Local nSaveSX8 := GetSX8Len()
	Local cChave   := QA_SXESXF("QPR","QPR_CHAVE",,4)
	While ( GetSX8Len() > nSaveSx8 )
		ConfirmSX8()
	EndDo
Return cChave

/*/{Protheus.doc} AtualizaChaveQPRParaMedia
Recupera a Chave da QPR para Registro de Média, ou seja, primeiro registro existente da amostra ou chave nova
@author brunno.costa
@since  04/10/2022
@param 01 - oRegistro, objeto, registro JSON com os dados para gravação na QPR que serão atualizados
/*/
METHOD AtualizaChaveQPRParaMedia(oRegistro) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	QPR->(DbSetOrder(1))
	If QPR->(DbSeek(xFilial("QPR")+oRegistro["QPR_OP"]+oRegistro["QPR_OPERAC"]+oRegistro["QPR_LABOR"]+oRegistro["QPR_ENSAIO"]))
		oRegistro["QPR_CHAVE"]  := QPR->QPR_CHAVE
		oRegistro['R_E_C_N_O_'] := QPR->(Recno())
	EndIf
	If oRegistro["QPR_CHAVE"] == Nil
		oRegistro["QPR_CHAVE"] := Self:GeraChaveQPR()
	EndIf
Return

/*/{Protheus.doc} AtualizaEnsaiadorQPR
Atualiza Ensaiador no oRegistro com base no cLogin recebido
@author brunno.costa
@since  23/05/2022
@param 01 - cLogin   , caracter, nome do login de usuário utilizado no Protheus pelo usuário do APP
@param 02 - oRegistro, objeto  , registro JSON com os dados para gravação na QPR que serão atualizados
/*/
METHOD AtualizaEnsaiadorQPR(cLogin, oRegistro) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	
	Self:oCacheEnsaiadorQPR := Iif(Self:oCacheEnsaiadorQPR == Nil, JsonObject():New(), Self:oCacheEnsaiadorQPR)

	If Self:oCacheEnsaiadorQPR[cLogin] == Nil
		DbSelectArea("QAA")
		QAA->(DbSetOrder(6))
		If QAA->(DbSeek(Upper(cLogin))) .OR. QAA->(DbSeek(Lower(cLogin)))
			oRegistro["QPR_FILMAT"]         := QAA->QAA_FILIAL
			oRegistro["QPR_ENSR"  ]         := QAA->QAA_MAT
			Self:oCacheEnsaiadorQPR[cLogin] := {QAA->QAA_FILIAL, QAA->QAA_MAT}
		EndIf
	Else
		oRegistro["QPR_FILMAT"]             := Self:oCacheEnsaiadorQPR[cLogin, 1]
		oRegistro["QPR_ENSR"  ]             := Self:oCacheEnsaiadorQPR[cLogin, 2]
	EndIf

Return 

/*/{Protheus.doc} RecuperaCamposQP7paraQPR
Recupera campos referência da tabela QP7 para gravação na QPR
@author brunno.costa
@since  23/05/2022
@param 01 - oRegistro, objeto  , registro JSON com os dados para gravação na QPR que serão atualizados
@param 02 - nRecnoQP7, numérico, recno do registro referência da QP7
@return lSucesso, lógico, indica se o processo foi executado com sucesso
/*/
METHOD RecuperaCamposQP7paraQPR(oRegistro, nRecnoQP7) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI

	Local cCampo     := Nil
	Local cCampoQP7  := Nil
	Local lSucesso   := .T.
	Local nCamposQPR := Len(Self:aCamposQPR)
	Local nIndCampo  := 0

	Default nRecnoQP7   := -1

	DbSelectArea("QP7")
	QP7->(DbGoTo(nRecnoQP7))
	If nRecnoQP7 <= 0 .OR. QP7->(Eof())
		lSucesso              := .F.
		//"Dados para Integração Inválidos"
		//"Não foi possível encontrar o registro da QP7 de RECNO[recnoTest]: "
		Self:cErrorMessage    := STR0008                        
		Self:cDetailedMessage := STR0011 + cValToChar(nRecnoQP7)
	Else
		For nIndCampo := 1 to nCamposQPR
			If Self:aCamposQPR[nIndCampo][nPosCPS_Alias] == "QP7QP8"
				cCampo            := Self:aCamposQPR[nIndCampo][nPosCPS_Protheus]
				cCampoQP7         := Self:aCamposQPR[nIndCampo][nPosCPS_Protheus_Externo]
				oRegistro[cCampo] := QP7->&(cCampoQP7)
			EndIf
		Next nIndCampo
	EndIf
	
Return lSucesso

/*/{Protheus.doc} RecuperaCamposQP8paraQPR
Recupera campos referência da tabela QP8 para gravação na QPR
@author brunno.costa
@since  23/06/2022
@param 01 - oRegistro, objeto  , registro JSON com os dados para gravação na QPR que serão atualizados
@param 02 - nRecnoQP8, numérico, recno do registro referência da QP8
@return lSucesso, lógico, indica se o processo foi executado com sucesso
/*/
METHOD RecuperaCamposQP8paraQPR(oRegistro, nRecnoQP8) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI

	Local cCampo     := Nil
	Local cCampoQP8  := Nil
	Local lSucesso   := .T.
	Local nCamposQPR := Len(Self:aCamposQPR)
	Local nIndCampo  := 0

	Default nRecnoQP8   := -1

	DbSelectArea("QP8")
	QP8->(DbGoTo(nRecnoQP8))
	If nRecnoQP8 <= 0 .OR. QP8->(Eof())
		lSucesso              := .F.
		//"Dados para Integração Inválidos"
		//"Não foi possível encontrar o registro da QP8 de RECNO[recnoTest]: "
		Self:cErrorMessage    := STR0008                        
		Self:cDetailedMessage := STR0019 + cValToChar(nRecnoQP8)
	Else
		For nIndCampo := 1 to nCamposQPR
			If Self:aCamposQPR[nIndCampo][nPosCPS_Alias] == "QP7QP8"
				cCampo            := Self:aCamposQPR[nIndCampo][nPosCPS_Protheus]
				cCampoQP8         := Self:aCamposQPR[nIndCampo][nPosCPS_Protheus_Externo]
				cCampoQP8         := StrTran(cCampoQP8, "QP7", "QP8")
				oRegistro[cCampo] := QP8->&(cCampoQP8)
			EndIf
		Next nIndCampo
	EndIf
	
Return lSucesso

/*/{Protheus.doc} RecuperaCamposQPKParaQPR
Recupera campos referência da tabela QPK para gravação na QPR
@author brunno.costa
@since  23/05/2022
@param 01 - oRegistro, objeto  , registro JSON com os dados para gravação na QPR que serão atualizados
@param 02 - nRecnoQPK, numérico, recno do registro referência da QPK
@return lSucesso, lógico, indica se o processo foi executado com sucesso
/*/
METHOD RecuperaCamposQPKParaQPR(oRegistro, nRecnoQPK) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI

	Local cCampo     := Nil
	Local cCampoQPK  := Nil
	Local lSucesso   := .T.
	Local nCamposQPR := Len(Self:aCamposQPR)
	Local nIndCampo  := 0

	Default nRecnoQPK   := -1

	DbSelectArea("QPK")
	QPK->(DbGoTo(nRecnoQPK))
	If nRecnoQPK <= 0 .OR. QPK->(Eof())
		lSucesso              := .F.
		//"Dados para Integração Inválidos"
		//"Não foi possível encontrar o registro da QPK de RECNO[recnoInspection]: "
		Self:cErrorMessage    := STR0008                        
		Self:cDetailedMessage := STR0012 + cValToChar(nRecnoQPK)
	Else
		For nIndCampo := 1 to nCamposQPR
			If Self:aCamposQPR[nIndCampo][nPosCPS_Alias] == "QPK"
				cCampo            := Self:aCamposQPR[nIndCampo][nPosCPS_Protheus]
				cCampoQPK         := Self:aCamposQPR[nIndCampo][nPosCPS_Protheus_Externo]
				oRegistro[cCampo] := QPK->&(cCampoQPK)
			EndIf
		Next nIndCampo
	EndIf
	
Return lSucesso

/*/{Protheus.doc} PreparaDadosQPS
Prepara os Dados Recebidos para Gravação na tabela QPS
@author brunno.costa
@since  23/05/2022
@param 01 - oDadosJson, objeto, objeto Json com os dados JSON recebidos da API para conversão
@param 02 - oDadosQPS , objeto, retorna por referência os dados para gravação na tabela QPR do DB
@return oDadosQPS, objeto, retorna os dados para gravação na tabela QPS do DB
/*/
METHOD PreparaDadosQPS(oItemAPI, oDadosQPS) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	
	Local nIndMedicoes := Nil
	Local nMedicoes    := Nil
	Local oRegistro    := Nil
	Local cJsonQPSDef  := ""

	If Self:aCamposQPS       == Nil
		Self:aCamposQPS      := Self:MapeiaCamposQPS("*")
	EndIf

	oDadosQPS['items'  ]     := {}

	oRegistro   := Self:oAPIManager:InicializaCamposPadroes("QPS",,.T.)
	cJsonQPSDef := oRegistro:toJson()

	nMedicoes := Len(oItemAPI["measurements"])
	For nIndMedicoes := 1 to nMedicoes
		oRegistro                   := JsonObject():New()
		oRegistro:fromJson(cJsonQPSDef)
		oRegistro["QPS_MEDICA"]     := oItemAPI["measurements"][nIndMedicoes]
		oRegistro["QPS_CODMED"]     := oItemAPI["QPR_CHAVE"]
		If nIndMedicoes == 1
			oRegistro["QPS_INDMED"] := "A"
		Elseif nIndMedicoes == 2
			oRegistro["QPS_INDMED"] := "N"
		Elseif nIndMedicoes == 3
			oRegistro["QPS_INDMED"] := "P"
		EndIf
		//TODO O QUE É ISSO NO FONTE?
		//If nY == 4
		//	QPS->QPS_MEDICA := StrTran(Str(aResultados[nPosOpe,_MED,nPosLab,nPosEns,nPosMed,(nMed+nY)-1],TamSx3("QPS_MEDICA")[1],2),".",",")
		//Else
		//	QPS->QPS_MEDICA := Str(aResultados[nPosOpe,_MED,nPosLab,nPosEns,nPosMed,(nMed+nY)-1],TamSx3("QPS_MEDICA")[1],TamSx3("QPS_MEDIPP")[2])
		//EndIf
		aAdd(oDadosQPS['items'], oRegistro)
	Next nIndMedicoes

Return oDadosQPS

/*/{Protheus.doc} SalvaRegistroQPSSequencialmente
Grava os Registros NUMÉRICOS Sequencialmente na Tabela QPS
@author brunno.costa
@since  23/05/2022
@param 01 - oDadosJson, objeto, objeto Json com os dados JSON que serão gravados na QPS
@return lSucesso, lógico, indica se o processo foi executado com sucesso
/*/
METHOD SalvaRegistroQPSSequencialmente(oDadosJson) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI

	Local cCpsErro    := ""
	Local cFilQPS     := xFilial("QPS")
	Local lModificado := .T.
	Local lSucesso    := .T.
	Local nIndReg     := Nil
	Local nRegistros  := Len(oDadosJson[ 'items' ])

	If nRegistros > 0
		If oDadosJson['items'][1]['QPS_CODMED'] == Nil .OR. oDadosJson['items'][1]['QPS_MEDICA'] == Nil
			//"Dados para Integração Inválidos"
			//"Dados para gravação na QPS inválidos no registro: "
			Self:cErrorMessage    := STR0008                                  
			Self:cDetailedMessage := STR0013 + oDadosJson['items'][1]:toJson()
			lSucesso              := .F.
			Return lSucesso
		EndIf

		DbSelectArea("QPS")
		QPS->(DbSetOrder(1))
		QPS->(DbSeek(cFilQPS+oDadosJson['items'][1]['QPS_CODMED']))
		For nIndReg  := 1 to nRegistros
			lSucesso := Self:oAPIManager:ValidaCamposObrigatorios(oDadosJson['items'][nIndReg], "|QPS_CODMED|QPS_MEDICA|", @cCpsErro)
			If lSucesso
				lSucesso := Self:oAPIManager:ValidaFormatosCamposItem(oDadosJson['items'][nIndReg], Self:aCamposQPS, @cCpsErro, nPosCPS_Protheus)
				If lSucesso
					If oDadosJson['items'][nIndReg]['QPS_CODMED'] == QPS->QPS_CODMED
						lModificado := Self:oAPIManager:validaMudancaRegistro("QPS", oDadosJson['items'][nIndReg], Self:aCamposQPS)
						If lModificado
							RecLock("QPS", .F.)
						EndIf
					Else
						lModificado := .T.
						RecLock("QPS", .T.)
					EndIf

					If lModificado
						QPS->QPS_FILIAL := cFilQPS
						QPS->QPS_CODMED := oDadosJson['items'][nIndReg]['QPS_CODMED']
						QPS->QPS_MEDICA := oDadosJson['items'][nIndReg]['QPS_MEDICA']
						QPS->QPS_INDMED := oDadosJson['items'][nIndReg]['QPS_INDMED']

						QPS->(MsUnlock())
					EndIf

					If nIndReg  < nRegistros
						QPS->(dbSkip())
					EndIf
				Else
					//"Dados para Integração Inválidos"
					//"Falha no formato de dado(s) do(s) campo(s)"
					Self:cErrorMessage    := STR0008
					Self:cDetailedMessage := STR0021 + " '" + cCpsErro + "': " + oDadosJson['items'][nIndReg]:toJson()
					Exit
				EndIf
			Else
				//"Dados para Integração Inválidos"
				//"Campo(s) obrigatório(s) inválido(s)"
				Self:cErrorMessage    := STR0008
				Self:cDetailedMessage := STR0020 + " '" + AllTrim(cCpsErro) + "': " + oDadosJson['items'][nIndReg]:toJson()
				Exit
			EndIf

		Next nIndReg
	EndIf

Return lSucesso

/*/{Protheus.doc} ErrorBlock
Proteção para Execução de Error.log
@author brunno.costa
@since  23/05/2022
@param 01 - e, objeto, objeto de errror.log
/*/
METHOD ErrorBlock(e) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	
	Local cCallStack := ""
	Local nIndAux    := Nil
	Local nTotal     := 10
	
	For nIndAux := 2 to (1+nTotal)
		cCallStack += " <- " + ProcName(nIndAux) + " line " + cValToChar(ProcLine(nIndAux))
	Next nIndAux

	Self:cErrorMessage    := Iif(Empty(Self:cErrorMessage) , STR0014 + " - ResultadosEnsaiosInspecaoDeProcessosAPI", Self:cErrorMessage ) //Erro Interno
	Self:cDetailedMessage := e:Description + cCallStack
	Self:oAPIManager:lWarningError := .F.
	Break

Return .F.

/*/{Protheus.doc} ValidaFormatosCamposItem
Valida Formatos de Campos Recebidos no Item
@author brunno.costa
@since  24/06/2022
@param 01 - oItemAPI  , objeto, objeto Json com UM ITEM DOS REGISTROS JSON recebidos da API para conversão
@return lSucesso, lógico, indica sucesso na validação
/*/
METHOD ValidaFormatosCamposItem(oItemAPI) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	
	Local cCpsErro := ""
	Local lSucesso := .T.

	If !Self:oAPIManager:ValidaFormatosCamposItem(oItemAPI, Self:aCamposAPI, @cCpsErro)
		//"Dados para Integração Inválidos"
		//"Falha no formato de dado(s) do(s) campo(s)"
		Self:cErrorMessage    := STR0008
		Self:cDetailedMessage := STR0021 + " '" + cCpsErro + "': " + oItemAPI:toJson()
		lSucesso              := .F.
	EndIf

Return lSucesso

/*/{Protheus.doc} PreparaRegistroQPR
Prepara e Valida Registros para Inclusão na QPR
@author brunno.costa
@since  23/05/2022
@param 01 - oItemAPI  , objeto, objeto Json com UM ITEM DOS REGISTROS JSON recebidos da API para conversão
@param 02 - oRegistro , objeto, retorna por referência os dados do registro da QPR para gravação
@return lSucesso, lógico, indica sucesso na operação
/*/
METHOD PreparaRegistroQPR(oItemAPI, oRegistro) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	
	Local lSucesso := .T.
	Local nRecno   := oItemAPI["recno"]

	Self:nRecnoQPK := Iif(Self:nRecnoQPK == Nil, oItemAPI["recnoInspection"], Self:nRecnoQPK)
	If (nRecno == Nil .OR. nRecno <= 0)
		lSucesso := Self:PreparaRegistroInclusaoQPR(@oItemAPI, @oRegistro)
		If lSucesso
			lSucesso := Self:ValidaEnsaioEditavelPorRegistro(oRegistro, "I")
		EndIf
	Else
		lSucesso := Self:oAPIManager:AtualizaCamposBancoNoRegistro(@oRegistro, "QPR", nRecno, Self:aCamposQPR)
		If lSucesso
			//QPR->(DbGoTo(nRecno)) - Já faz em AtualizaCamposBancoNoRegistro
			lSucesso := Self:ValidaEnsaioEditavelPorQPR("A")
		EndIf
		If lSucesso
			oItemAPI["QPR_CHAVE"] := oRegistro["QPR_CHAVE"]
			oRegistro := Self:oAPIManager:AtualizaCamposAPINoRegistro(oItemAPI, oRegistro, "QPR", Self:aCamposAPI)
		Else
			//"Dados para Integração Inválidos"
			//"Não foi possível encontrar o registro da QPR de RECNO[recno]: "
			Self:cErrorMessage    := STR0008                          
			Self:cDetailedMessage := STR0010 + cValToChar(nRecno)     
		EndIf
		Self:AtualizaEnsaiadorQPR(oItemAPI["protheusLogin"], @oRegistro)
	EndIf

	If lSucesso
		Self:cOperacao := oRegistro["QPR_OPERAC"]
	EndIf

Return lSucesso

/*/{Protheus.doc} SalvaRegistros
Salva Registros no Banco de Dados
@author brunno.costa
@since  24/06/2022
@param 01 - oItemAPI  , objeto, objeto Json com UM ITEM DOS REGISTROS JSON recebidos da API para conversão
@param 02 - oRegistro , objeto, registro JSON com os dados para gravação na QPR
@param 03 - aRecnosQPR, array , NIL e Vazio para retornar todos ou array com os RECNOS da QPR para receber na resposta do POST
@return lSucesso, lógico, indica sucesso na operação
/*/
METHOD SalvaRegistros(oItemAPI, oRegistro, aRecnosQPR) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	
	Local cCpsErro   := ""
	Local cEnsaio    := ""
	Local lSucesso   := .T.
	Local nMedicoes  := 0
	Local nRecnoErro := Nil

	oRegistro["QPR_DTMEDI"] := Iif(Empty(oRegistro["QPR_DTMEDI"]), Date()         , oRegistro["QPR_DTMEDI"])
	oRegistro["QPR_HRMEDI"] := Iif(Empty(oRegistro["QPR_HRMEDI"]), Left(Time(), 5), oRegistro["QPR_HRMEDI"])
	
	If Empty(oItemAPI["sampleNumber"])
		oRegistro["QPR_AMOSTR"] := Iif(Self:nRegistros == 1, 2, 1)
	Else
		oRegistro["QPR_AMOSTR"] := oItemAPI["sampleNumber"]
	Endif

	lSucesso  := Self:oAPIManager:ValidaCamposObrigatorios(oRegistro, "|QPR_ENSR|", @cCpsErro)
	If lSucesso
		lSucesso := Self:oAPIManager:SalvaRegistroDB("QPR", @oRegistro, Self:aCamposQPR, @nRecnoErro)
		If lSucesso                                    //Trecho de ELSE é Código Morto - Desvio já tratado no retorno de AtualizaCamposBancoNoRegistro
			aAdd(aRecnosQPR, oRegistro["R_E_C_N_O_"])
		EndIf
	Else
		//"Dados para Integração Inválidos"
		//"Campo(s) obrigatório(s) inválido(s)"
		Self:cErrorMessage    := STR0008
		Self:cDetailedMessage := STR0020 + " '" + AllTrim(cCpsErro) + "': " + oRegistro:toJson()
	EndIf

	If lSucesso
		If oItemAPI['testType'] == "N"
			If Self:ValidaPermissaoEnsaioNumerico(oItemAPI["recnoTest"])
				lSucesso := Self:ValidaQuantidadeMedicoesEnsaio(oItemAPI, @nMedicoes, @cEnsaio)
				If lSucesso
					lSucesso := Self:SalvaRegistroNumerico(oItemAPI)
				Else
					//"Informe as"  + "medições"
					//"O ensaio" + "requer o preenchimento de" + "medições"
					Self:cErrorMessage    := STR0022 + " " + CValToChar(nMedicoes)+ " " + STR0023 + "."
					Self:cDetailedMessage := STR0024 + " '" + cEnsaio + "' " + STR0025 + " " + CValToChar(nMedicoes) + " " + STR0026 + ": " + oItemAPI:toJson()
				EndIf
			Else
				lSucesso := .F.
				//"A inspeção não permite o lançamento de medições do tipo numérica"
				Self:cErrorMessage    := STR0027 + "."
				Self:cDetailedMessage := STR0027 + ": " + oItemAPI:toJson()
			EndIf
		ElseIf oItemAPI['testType'] == "T"
			If Self:ValidaPermissaoEnsaioTexto(oItemAPI["recnoTest"])
				lSucesso := Self:SalvaRegistroTexto(oItemAPI)
			Else
				lSucesso := .F.
				//"A inspeção não permite o lançamento de medições do tipo texto"
				Self:cErrorMessage    := STR0028 + "."
				Self:cDetailedMessage := STR0028 + ":" + oItemAPI:toJson()
			EndIf
		Else
			lSucesso := .F.
			Self:cErrorMessage    := STR0017 // "TIPO do item inválido"
			Self:cDetailedMessage := STR0018 + oItemAPI:toJson() //"Informe um TIPO de item válido, somente são válidos os tipos de item N ou T. Item recebido: "
		EndIf
	EndIf

Return lSucesso

/*/{Protheus.doc} ValidaEnsaiador
Valida se o Ensaiador está cadastrado na QAA
@author brunno.costa
@since  24/06/2022
@param 01 - oRegistro, objeto, registro JSON com os dados para gravação na QPR
@return lSucesso, lógico, indica sucesso na validação
/*/
METHOD ValidaEnsaiador(oRegistro) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	
	Local lSucesso   := .T.

	lSucesso := IIf(lSucesso, Self:oAPIManager:ValidaChaveEstrangeira("QAA", 1, xFilial("QAA") + AllTrim(oRegistro["QPR_ENSR"])), lSucesso)
	If !lSucesso
		//"Ensaiador não cadastrado no cadastro de usuários (QAA)"
		Self:cErrorMessage    := STR0029 + "."
		Self:cDetailedMessage := STR0029 + ": " + AllTrim(oRegistro["QPR_ENSR"])
	EndIf

Return lSucesso

/*/{Protheus.doc} ValidaUsuarioProtheus
Valida se o Usuário do Protheus está cadastrado no configurador
@author brunno.costa
@since  24/06/2022
@param 01 - oItemAPI, objeto, objeto Json com UM ITEM DOS REGISTROS JSON recebidos da API para conversão
@return lSucesso, lógico, indica sucesso na validação
/*/
METHOD ValidaUsuarioProtheus(oItemAPI) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	
	Local lSucesso   := .T.

	lSucesso := Self:oAPIManager:ValidaUsuarioProtheus(oItemAPI["protheusLogin"])
	If !lSucesso
		//"Login de usuário não cadastrado no configurador do Protheus"
		Self:cErrorMessage    := STR0030 + "."
		Self:cDetailedMessage := STR0030 + ": " + oItemAPI["protheusLogin"]
	EndIf

Return lSucesso

/*/{Protheus.doc} ValidaPermissaoEnsaioNumerico
Valida se o ensaio de nRecnoQP7 permite recebimento de resultado Numérico
@author brunno.costa
@since  24/06/2022
@param 01 - nRecnoQP7, número, recno do ensaio na QP7
@return lSucesso, lógico, indica sucesso na validação
/*/
METHOD ValidaPermissaoEnsaioNumerico(nRecnoQP7) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	
	Local cAlias   := Nil
	Local cFIlQP1  := xFilial("QP1")
	Local cFIlQP7  := xFilial("QP7")
    Local cQuery   := ""
	Local lSucesso := .T.
	Local oExec    := Nil

	If Self:NaoImplantado()
		SetRestFault(405, EncodeUtf8(STR0039), .T.,; //"Módulo não está implantado"
		             405, EncodeUtf8(STR0040))       //"Fale com a TOTVS e faça implantação do módulo!"
		Return .F.
	EndIf

	Self:oCachePermissaoEnsaioNumerico := Iif(Self:oCachePermissaoEnsaioNumerico == Nil, JsonObject():New(), Self:oCachePermissaoEnsaioNumerico)

	If Self:oCachePermissaoEnsaioNumerico[cValToChar(nRecnoQP7)] == Nil
		cQuery += " SELECT QP7_ENSAIO "
		cQuery += " FROM " + RetSQLName("QP7")  + " QP7 "
		cQuery += 	" INNER JOIN "
		cQuery += 	" (SELECT QP1_ENSAIO "
		cQuery += 	" FROM " + RetSQLName("QP1")
		cQuery += 	" WHERE QP1_FILIAL = '" + cFIlQP1 + "' "
		cQuery += 		" AND QP1_CARTA  != 'TXT' "
		cQuery += 		" AND D_E_L_E_T_ = ' ') "
		cQuery += 	" QP1  "
		cQuery += 	" ON QP7_ENSAIO = QP1_ENSAIO "
		cQuery += " WHERE QP7_FILIAL = '" + cFIlQP7 + "' "
		cQuery += 	" AND D_E_L_E_T_ = ' ' "
		cQuery += 	" AND R_E_C_N_O_ = " + cValToChar(nRecnoQP7)

		Self:cErrorMessage := STR0007 + cQuery //"Erro na execução da query: "
		
		oExec := FwExecStatement():New(cQuery)
		cAlias := oExec:OpenAlias()

		Self:cErrorMessage := ""
		lSucesso := !(cAlias)->(Eof())
		Self:oCachePermissaoEnsaioNumerico[cValToChar(nRecnoQP7)] := lSucesso
		(cAlias)->(dbCloseArea())
		oExec:Destroy()
		oExec := nil 
	Else
		lSucesso := Self:oCachePermissaoEnsaioNumerico[cValToChar(nRecnoQP7)]
	EndIf


Return lSucesso

/*/{Protheus.doc} ValidaPermissaoEnsaioTexto
Valida se o ensaio de nRecnoQP8 permite recebimento de resultado Texto
@author brunno.costa
@since  24/06/2022
@param 01 - nRecnoQP8, número, recno do ensaio na QP8
@return lSucesso, lógico, indica sucesso na validação
/*/
METHOD ValidaPermissaoEnsaioTexto(nRecnoQP8) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	
	Local cAlias   := Nil
	Local cFIlQP1  := xFilial("QP1")
	Local cFIlQP8  := xFilial("QP8")
    Local cQuery   := ""
	Local lSucesso := .T.
	Local oExec    := Nil

	If Self:NaoImplantado()
		SetRestFault(405, EncodeUtf8(STR0039), .T.,; //"Módulo não está implantado"
		             405, EncodeUtf8(STR0040))       //"Fale com a TOTVS e faça implantação do módulo!"
		Return .F.
	EndIf

	cQuery += " SELECT QP8_ENSAIO "
	cQuery += " FROM " + RetSQLName("QP8")  + " QP8 "
	cQuery += 	" INNER JOIN "
	cQuery += 	" (SELECT QP1_ENSAIO "
	cQuery += 	" FROM " + RetSQLName("QP1")
	cQuery += 	" WHERE QP1_FILIAL = '" + cFIlQP1 + "' "
	cQuery += 		" AND QP1_CARTA  = 'TXT' "
	cQuery += 		" AND D_E_L_E_T_ = ' ') "
	cQuery += 	" QP1  "
	cQuery += 	" ON QP8_ENSAIO = QP1_ENSAIO "
	cQuery += " WHERE QP8_FILIAL = '" + cFIlQP8 + "' "
	cQuery += 	" AND D_E_L_E_T_=' ' "
	cQuery += 	" AND R_E_C_N_O_ = " + cValToChar(nRecnoQP8)

	Self:cErrorMessage := STR0007 + cQuery //"Erro na execução da query: "
	
	oExec := FwExecStatement():New(cQuery)
    cAlias := oExec:OpenAlias()
	
	Self:cErrorMessage := ""
    lSucesso := !(cAlias)->(Eof())
    (cAlias)->(dbCloseArea())
	oExec:Destroy()
	oExec := nil 

Return lSucesso

/*/{Protheus.doc} ValidaQuantidadeMedicoesEnsaio
Valida se o ensaio de nRecnoQP8 permite recebimento de resultado Texto
@author brunno.costa
@since  24/06/2022
@param 01 - oItemAPI , objeto  , objeto Json com UM ITEM DOS REGISTROS JSON recebidos da API para conversão
@param 02 - nMedicoes, número  , retorna por referência a quantidade de medições do ensaio
@param 03 - cEnsaio  , caracter, retorna por referência o código do ensaio
@return lSucesso, lógico, indica sucesso na validação
/*/
METHOD ValidaQuantidadeMedicoesEnsaio(oItemAPI, nMedicoes, cEnsaio) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	
	Local cAlias    := Nil
	Local cFIlQP1   := xFilial("QP1")
	Local cFIlQP7   := xFilial("QP7")
    Local cQuery    := ""
	Local lSucesso  := .T.
	Local nRecnoQP7 := oItemAPI["recnoTest"]
	Local oExec     := Nil

	If oItemAPI["measurements"] == Nil .OR. Len(oItemAPI["measurements"]) == 0
		lSucesso := .F.
	EndIf

	Self:oCacheQuantidadeMedicoesEnsaio := Iif(Self:oCacheQuantidadeMedicoesEnsaio == Nil, JsonObject():New(), Self:oCacheQuantidadeMedicoesEnsaio)
	If lSucesso .and. Self:oCacheQuantidadeMedicoesEnsaio[cValToChar(nRecnoQP7)] == Nil

		cQuery += " SELECT QP1_ENSAIO, "
		cQuery +=        " (CASE QP1_CARTA "
		cQuery +=           " WHEN 'XBR' THEN QP1_QTDE "
		cQuery +=           " WHEN 'XBS' THEN QP1_QTDE "
		cQuery +=           " WHEN 'XMR' THEN QP1_QTDE "
		cQuery +=           " WHEN 'HIS' THEN QP1_QTDE "
		cQuery +=           " WHEN 'NP ' THEN QP1_QTDE "
		cQuery +=           " WHEN 'P  ' THEN 3 "
		cQuery +=           " WHEN 'U  ' THEN 2 "
		cQuery +=           " ELSE 1 END) QP1_QTDE "
		cQuery += " FROM " + RetSQLName("QP7")  + " QP7 "
		cQuery += 	" INNER JOIN "
		cQuery += 	" (SELECT QP1_ENSAIO, QP1_CARTA, QP1_QTDE "
		cQuery += 	" FROM " + RetSQLName("QP1")
		cQuery += 	" WHERE QP1_FILIAL = '" + cFIlQP1 + "' "
		cQuery += 		" AND QP1_CARTA  != 'TXT' "
		cQuery += 		" AND D_E_L_E_T_ = ' ') "
		cQuery += 	" QP1  "
		cQuery += 	" ON QP7_ENSAIO = QP1_ENSAIO "
		cQuery += " WHERE QP7_FILIAL = '" + cFIlQP7 + "' "
		cQuery += 	" AND D_E_L_E_T_= ' ' "
		cQuery += 	" AND R_E_C_N_O_ = " + cValToChar(nRecnoQP7)

		Self:cErrorMessage := STR0007 + cQuery //"Erro na execução da query: "
		
		oExec := FwExecStatement():New(cQuery)
		cAlias := oExec:OpenAlias()
		
		Self:cErrorMessage := ""
		lSucesso  := Iif(lSucesso, !(cAlias)->(Eof())                                 , lSucesso)
		lSucesso  := Iif(lSucesso, (cAlias)->QP1_QTDE == Len(oItemAPI["measurements"]), lSucesso)
		nMedicoes := (cAlias)->QP1_QTDE
		cEnsaio   := (cAlias)->QP1_ENSAIO
		Self:oCacheQuantidadeMedicoesEnsaio[cValToChar(nRecnoQP7)] := {(cAlias)->QP1_QTDE, (cAlias)->QP1_ENSAIO}
		(cAlias)->(dbCloseArea())
		oExec:Destroy()
		oExec := nil 
	Else
		lSucesso  := Iif(lSucesso, Self:oCacheQuantidadeMedicoesEnsaio[cValToChar(nRecnoQP7), 1] == Len(oItemAPI["measurements"]), lSucesso)
		nMedicoes := Self:oCacheQuantidadeMedicoesEnsaio[cValToChar(nRecnoQP7), 1]
		cEnsaio   := Self:oCacheQuantidadeMedicoesEnsaio[cValToChar(nRecnoQP7), 2]
	EndIf

Return lSucesso

/*/{Protheus.doc} NaoImplantado
Indica se o Módulo QIP não está implantado
@author brunno.costa
@since  16/08/2022
@return lNaoImplantado, lógico, indica se o módulo QIP não está implantado
/*/
METHOD NaoImplantado() CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
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

/*/{Protheus.doc} AtualizaStatusQPKComRecno
Atualiza Status do Registro na QPK com base em RECNO da QPK
@author brunno.costa
@since  16/08/2022
@param 01 - nRecnoQPK, número, recno para posicionamento na QPK
/*/
METHOD AtualizaStatusQPKComRecno(nRecnoQPK) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	Local cLaudo   := " "
	Local lMedicao := .F.
	Local lQPKLDAUTO := Nil
	Self:lProcessaRetorno := .F.
	Self:RetornaResultadosInspecao(nRecnoQPK, "", Nil, Nil, Nil, "", @lMedicao)
	QPK->(DbGoTo(nRecnoQPK))
	If QPK->(!Eof())
		Private cFatApC := ""
		Private cFatApr := ""
		Private cFatLU  := ""
		Private cFatRep := ""

		lQPKLDAUTO      := !Empty(GetSx3Cache("QPK_LDAUTO","X3_CAMPO"))

		RecLock("QPK",.F.)
		
		QPK->QPK_SITOP  := " "

		If lQPKLDAUTO
			QPK->QPK_LDAUTO := "0"
		EndIf

		MsUnLock()

		Self:DefineFatores()
		QP215AtuSit(cLaudo, lMedicao)
	EndIf
	QPK->(DbCloseArea())
Return

/*/{Protheus.doc} AtualizaStatusQPKComChaveQPK
Atualiza Status do Registro na QPK com base em Chave do Registro da QPK
@author brunno.costa
@since  18/11/2022
@param 01 - cChaveQPK, caracter, chave do registro na QPK
/*/
METHOD AtualizaStatusQPKComChaveQPK(cChaveQPK) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	IF !Empty(cChaveQPK)
		QPK->(DbSetOrder(1))
		If QPK->(DbSeek(xFilial("QPK")+cChaveQPK))
			nRecnoQPK := QPK->(Recno())
		EndIf
		Self:AtualizaStatusQPKComRecno(nRecnoQPK)
	EndIf
Return

/*/{Protheus.doc} DefineFatores
Define os Fatores Aprovado, Aprovado Condicional e Reprovado
@author brunno.costa
@since  16/08/2022
/*/
METHOD DefineFatores() CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	If QPD->(dbSeek(xFilial("QPD")))
		While !QPD->(Eof())
			If QPD->QPD_CATEG == "1"
				cFatApr := Iif(Empty(cFatApr),QPD->QPD_CODFAT,cFatApr)
			ElseIf QPD->QPD_CATEG == "2"
				cFatApC += QPD->QPD_CODFAT
			ElseIf QPD->QPD_CATEG == "3"
				cFatRep := Iif(Empty(cFatRep),QPD->QPD_CODFAT,cFatRep)
			ElseIf QPD->QPD_CATEG == "4"
				cFatLU := Iif(Empty(cFatLU),QPD->QPD_CODFAT,cFatLU)
			EndIf
			QPD->(dbSkip())
		EndDo
	Endif
Return

/*/{Protheus.doc} ExisteLaudoRelacionadoAoPost
Indica se existe laudo relacionado aos dados do POST
@author brunno.costa
@since  27/11/2022
@param 01 - oDadosJson, objeto, objeto Json com os dados JSON recebidos da API para conversão
@return lExiste, lógico, indica se existe laudo (.T.) relacionado aos dados do POST 
(ou .T. TAMBÉM em caso de falha, para interromper processo e exibir mensagem de falha)
/*/
METHOD ExisteLaudoRelacionadoAoPost(oDadosJson) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	
	Local aRecsQP7    := Nil
	Local aRecsQP8    := Nil
	Local aRecsQPK    := Nil
	Local bErrorBlock := Nil
	Local cAlias      := Nil
    Local cQuery      := ""
	Local lExiste     := .F.
    Local oExec       := Nil

	Self:oAPIManager := QualityAPIManager():New(Nil, Self:oWSRestFul)
	bErrorBlock := ErrorBlock({|e| Self:oAPIManager:ErrorBlock(e, e:Description), lExiste := .T., Break(e)})

	Self:IdentificaRecnosInspecoesEEnsaios(oDadosJson, @aRecsQPK, @aRecsQP7, @aRecsQP8)
	
	BEGIN SEQUENCE

		cQuery += " SELECT DISTINCT "
		cQuery +=         " COALESCE(COALESCE(LAUDO_GERAL.CHAVE_INSPECAO, LAUDO_LABORATORIO.CHAVE_LABORATORIO), LAUDO_OPERACAO.CHAVE_OPERACAO) TEM_LAUDO "
		cQuery +=  " FROM  "


		cQuery += " (SELECT "
		cQuery += 		" CONCAT(CONCAT(CONCAT(QPK_OP, QPK_LOTE), QPK_NUMSER), QQK_CODIGO) CHAVE_INSPECAO, "
		cQuery += 		" CONCAT(CONCAT(CONCAT(CONCAT(QPK_OP, QPK_LOTE), QPK_NUMSER), QQK_CODIGO), QQK_OPERAC) CHAVE_OPERACAO, "
		cQuery += 		" CONCAT(CONCAT(CONCAT(CONCAT(CONCAT(QPK_OP, QPK_LOTE), QPK_NUMSER), QQK_CODIGO), QQK_OPERAC), QP8_LABOR) CHAVE_LABORATORIO, "
		cQuery += 		" QPK_SITOP "
		cQuery += " FROM (SELECT DISTINCT QPK.QPK_PRODUT, QPK.QPK_OP, QQK.QQK_CODIGO, QQK.QQK_OPERAC, QPK.QPK_LOTE, QPK.QPK_NUMSER, QPK.QPK_REVI, QPK.QPK_SITOP, QP8_LABOR "
		cQuery +=       " FROM (SELECT QPK_PRODUT, QPK_OP, QPK_LOTE, QPK_NUMSER, QPK_REVI, QPK_SITOP "
		cQuery +=             " FROM " + RetSQLName("QPK")
		cQuery +=             " WHERE (D_E_L_E_T_ = ' ') "
		cQuery +=               " AND (R_E_C_N_O_ IN " + FormatIn(ArrToKStr(aRecsQPK),"|") + ") "
		cQuery +=               " AND (QPK_FILIAL = '" + xFilial("QPK") + "') ) QPK "
		
		cQuery += " INNER JOIN (SELECT QQK_CODIGO, QQK_OPERAC, QQK_PRODUT, QQK_REVIPR "
		cQuery +=             " FROM " + RetSQLName("QQK")
		cQuery +=             " WHERE (D_E_L_E_T_ = ' ') "
		cQuery +=               " AND (QQK_FILIAL = '" + xFilial("QQK") + "')) QQK "
		cQuery +=             " ON    QPK.QPK_REVI = QQK.QQK_REVIPR "
		cQuery +=             " AND QPK.QPK_PRODUT = QQK.QQK_PRODUT "
		cQuery +=             " INNER JOIN (SELECT C2_NUM, C2_ITEM, C2_ITEMGRD, C2_SEQUEN, C2_ROTEIRO "
		cQuery +=                         " FROM " + RetSQLName("SC2")
		cQuery +=                         " WHERE (D_E_L_E_T_ = ' ') "
		cQuery +=                         " AND C2_FILIAL = '" + xFilial("SC2") + "') SC2 "
		cQuery +=             " ON " + Self:oApiManager:oQueryManager:MontaRelationC2OP("QPK_OP")
		cQuery +=             Iif(SuperGetMV("MV_QIPOPEP") == "3", " AND (QQK_CODIGO = C2_ROTEIRO OR QQK_CODIGO = '" + QIPRotGene("QQK_CODIGO") + "') ", " AND QQK_CODIGO = C2_ROTEIRO ")

		cQuery += " INNER JOIN "
		cQuery += " ( "
		If Len(aRecsQP8) > 0
			cQuery += " SELECT QP8_PRODUT AS PRODUTO, QP8_REVI AS REVISAO, QP8_CODREC, QP8_OPERAC AS OPERACAO, QP8_LABOR "
			cQuery += " FROM " + RetSQLName("QP8") + " "
			cQuery += " WHERE D_E_L_E_T_ = ' ' "
			cQuery += " AND (QP8_FILIAL = '" + xFilial("QP8") + "') "
			cQuery += " AND (R_E_C_N_O_ IN " + FormatIn(ArrToKStr(aRecsQP8),"|") + ") "
		EndIf
		If Len(aRecsQP7) > 0 .AND. Len(aRecsQP8) > 0
			cQuery += " UNION "
		EndIf
		If Len(aRecsQP7) > 0
			cQuery += " SELECT QP7_PRODUT AS PRODUTO, QP7_REVI AS REVISAO, QP7_CODREC AS QP8_CODREC, QP7_OPERAC AS OPERACAO, QP7_LABOR AS QP8_LABOR "
			cQuery += " FROM " + RetSQLName("QP7") + " "
			cQuery += " WHERE D_E_L_E_T_ = ' ' "
			cQuery += " AND (QP7_FILIAL = '" + xFilial("QP7") + "') "
			cQuery += " AND (R_E_C_N_O_ IN " + FormatIn(ArrToKStr(aRecsQP7),"|") + ") "
		EndIf
		cQuery += " ) FILTROLAB ON QPK.QPK_PRODUT = FILTROLAB.PRODUTO "
		cQuery +=            " AND QPK.QPK_REVI   = FILTROLAB.REVISAO "
		cQuery +=            " AND QQK.QQK_OPERAC = FILTROLAB.OPERACAO "
		
		cQuery += " ) DADOS) INSPECOES "


		cQuery += " LEFT JOIN (SELECT DISTINCT "
		cQuery +=                   " CONCAT(CONCAT(CONCAT(QPM_OP, QPM_LOTE), QPM_NUMSER), QPM_ROTEIR) CHAVE_INSPECAO, "
		cQuery +=                   " CONCAT(CONCAT(CONCAT(CONCAT(QPM_OP, QPM_LOTE), QPM_NUMSER), QPM_ROTEIR), QPM_OPERAC) CHAVE_OPERACAO "
		cQuery +=            " FROM " + RetSQLName("QPM") + " "
		cQuery +=            " WHERE (D_E_L_E_T_ = ' ') "
		cQuery +=            " AND (QPM_LAUDO <> ' ') "
		cQuery +=            " AND (QPM_OPERAC <> ' ') "
		cQuery +=            " AND (QPM_FILIAL = '" + xFilial("QPM") + "')) LAUDO_OPERACAO "
		cQuery += " ON LAUDO_OPERACAO.CHAVE_OPERACAO = INSPECOES.CHAVE_OPERACAO "


		cQuery += " LEFT JOIN (SELECT DISTINCT
		cQuery +=                   " CONCAT(CONCAT(CONCAT(QPL_OP, QPL_LOTE), QPL_NUMSER), QPL_ROTEIR) CHAVE_INSPECAO, "
		cQuery +=                   " CONCAT(CONCAT(CONCAT(CONCAT(CONCAT(QPL_OP, QPL_LOTE), QPL_NUMSER), QPL_ROTEIR), QPL_OPERAC), QPL_LABOR) CHAVE_LABORATORIO "
		cQuery +=            " FROM " + RetSQLName("QPL") + " "
		cQuery +=            " WHERE (D_E_L_E_T_ = ' ') "
		cQuery +=            " AND (QPL_FILIAL = '" + xFilial("QPL") + "') "
		cQuery +=            " AND (QPL_LAUDO <> ' ') "
		cQuery +=            " AND (QPL_OPERAC <> ' ')) LAUDO_LABORATORIO "
		cQuery += " ON LAUDO_LABORATORIO.CHAVE_LABORATORIO = INSPECOES.CHAVE_LABORATORIO "


		cQuery += " LEFT JOIN (SELECT DISTINCT "
		cQuery +=                   " CONCAT(CONCAT(CONCAT(QPL_OP, QPL_LOTE), QPL_NUMSER), QPL_ROTEIR) CHAVE_INSPECAO "
		cQuery +=       " FROM " + RetSQLName("QPL")
		cQuery +=       " WHERE (D_E_L_E_T_ = ' ') "
		cQuery +=       "   AND (QPL_FILIAL = '" + xFilial("QPL") + "') "
		cQuery +=       "   AND (QPL_LAUDO <> ' ') "
		cQuery +=       "   AND (QPL_LABOR = ' ') "
		cQuery +=       "   AND (QPL_OPERAC = ' ')) LAUDO_GERAL "
		cQuery += " ON LAUDO_GERAL.CHAVE_INSPECAO = INSPECOES.CHAVE_INSPECAO "

		cQuery += " WHERE COALESCE(COALESCE(LAUDO_GERAL.CHAVE_INSPECAO, LAUDO_LABORATORIO.CHAVE_LABORATORIO), LAUDO_OPERACAO.CHAVE_OPERACAO) IS NOT NULL "


		cQuery := Self:oAPIManager:ChangeQueryAllDB(cQuery)

		oExec       := FwExecStatement():New(cQuery)
		cAlias      := oExec:OpenAlias()
		lExiste     := (cAlias)->(!Eof())
		oExec:Destroy()
		oExec       := nil

		(cAlias)->(dbCloseArea())
	RECOVER
	END SEQUENCE

	ErrorBlock(bErrorBlock)

Return lExiste

/*/{Protheus.doc} IdentificaRecnosInspecoesEEnsaios
Identifica os Recnos da QPK, QP7 e QP8 relacionados a inspeção
@author brunno.costa
@since  27/11/2022
@param 01 - oDadosJson, objeto, objeto Json com os dados JSON recebidos da API para conversão
@param 02 - aRecsQPK  , array , retorna por referência relação de RECNOS da QPK relacionados
@param 03 - aRecsQP7  , array , retorna por referência relação de RECNOS da QP7 relacionados
@param 04 - aRecsQP8  , array , retorna por referência relação de RECNOS da QP8 relacionados
/*/
METHOD IdentificaRecnosInspecoesEEnsaios(oDadosJson, aRecsQPK, aRecsQP7, aRecsQP8) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI

	Local nIndReg    := Nil
	Local nRegistros := Len(oDadosJson["items"])
	Local oItemAPI   := Nil

	Default aRecsQPK := {}
	Default aRecsQP7 := {}
	Default aRecsQP8 := {}

	If nRegistros > 0
		For nIndReg := 1 to nRegistros
			oItemAPI := oDadosJson["items"][nIndReg]
			aAdd(aRecsQPK, oItemAPI["recnoInspection"])
			If oItemAPI['testType'] == "N"
				aAdd(aRecsQP7, oItemAPI["recnoTest"])
			Else
				aAdd(aRecsQP8, oItemAPI["recnoTest"])
			EndIf
		Next nIndReg
	EndIf
Return 

/*/{Protheus.doc} RetornaTamanhoResultadoTipoTexto
Retorna o tamanho permitido para resultados do tipo texto
@author brunno.costa
@since  08/05/2024
/*/
METHOD RetornaTamanhoResultadoTipoTexto() CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
     
	Local oResponse := JsonObject():New()
	Local cResp     := ""
	
	oResponse['result' ] := GetSx3Cache("QPQ_MEDICA", "X3_TAMANHO")

	Self:oWSRestFul:SetContentType("application/json")

	//Processou com sucesso.
	HTTPSetStatus(200)
	oResponse['code'         ] := 200
	cResp := EncodeUtf8(FwJsonSerialize( oResponse, .T. ))
	Self:oWSRestFul:SetResponse( cResp )

Return 

/*/{Protheus.doc} RevisaEnsaiosCalculados
Revisa Ensaios Calculados
@author brunno.costa
@since  24/05/2024
@param 01 - oDadosJson, objeto, objeto Json com os dados JSON recebidos da API para conversãoação e gravação
/*/
METHOD RevisaEnsaiosCalculados(oDadosJson, oDadosCalc) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI

	Local aPendentes            := {}
	Local cEnsaio               := ""
	Local lConsideraDB          := .T.
	Local lDigitRelacCalc       := .F.
	//Local lSemMedEDesvio        := .T.
	Local nIndAmostra           := 0
	Local nIndEnsaio            := 0
	Local nIndPend              := 0
	Local nMedicoes             := 0
	//Local oCalculosSemD         := QIPEnsaiosCalculados():New(oDadosJson["items"][1]["recnoInspection"], Self:cOperacao, oDadosJson["items"], .F.)
	Local oItemAPI              := Nil
	Local oQIPEnsaiosCalculados := QIPEnsaiosCalculados():New(oDadosJson["items"][1]["recnoInspection"], Self:cOperacao, oDadosJson["items"], lConsideraDB)

	//Valida uso de Média ou Desvio Padrão para priorizar cálculos sem resultados do banco
	//If Self:nRegistros != 1 .AND. (Empty(Self:nAmostraTela) .OR. Self:nAmostraTela != 2)
	//	For nIndEnsaio := 1 To Len(oQIPEnsaiosCalculados:aEnsaiosCalculados)
	//		If "AVG(" $ Upper(oQIPEnsaiosCalculados:aEnsaiosCalculados[nIndEnsaio, 'formula']) .OR. "DESVPAD(" $ Upper(oQIPEnsaiosCalculados:aEnsaiosCalculados[nIndEnsaio, 'formula'])
	//			lSemMedEDesvio := .F.
	//			Exit
	//		EndIf
	//	Next nIndEnsaio
	//	If lSemMedEDesvio
	//		oQIPEnsaiosCalculados := oCalculosSemD
	//	EndIf
	//EndIf

	//Valida se existe pelo menos um ensaio numérico relacionado a ensaio calculado
	For nIndEnsaio := 1 To Len(oQIPEnsaiosCalculados:aEnsaiosCalculados)
		
		If    aScan(oDadosJson["items"], {|oItemAPI| "#"+Padr(SubStr(AllTrim(oItemAPI['testID']), 1, 8), 8)+"#";
		                                              $ oQIPEnsaiosCalculados:aEnsaiosCalculados[nIndEnsaio, 'formula']}) > 0
			lDigitRelacCalc := .T.
			Exit
		EndIf
	Next nIndEnsaio

	//Identifica ensaios calculados pendentes (não recebidos na mensagem)
	If lDigitRelacCalc
		For nIndEnsaio := 1 To Len(oQIPEnsaiosCalculados:aEnsaiosCalculados)
			cEnsaio := AllTrim(oQIPEnsaiosCalculados:aEnsaiosCalculados[nIndEnsaio, 'testID'])

			If aScan(oDadosJson["items"], {|oItemAPI| AllTrim(oItemAPI['testID']) == cEnsaio}) <= 0
				aAdd(aPendentes, {nIndEnsaio, cEnsaio})
			EndIf

		Next nIndEnsaio
	EndIf

	If Len(aPendentes) > 0

		oQIPEnsaiosCalculados:ProcessaEnsaiosCalculados()

		oItemAPI                        := JsonObject():new()
		oItemAPI['attachments']         := {}
		oItemAPI['nonConformitiesList'] := {}
		oItemAPI['textDetail']          := ""
		oItemAPI['testType']            := "N"
		oItemAPI['type']                := "C"
		oItemAPI["recnoInspection"]     := Self:nRecnoQPK

		For nIndPend := 1 To Len(aPendentes)

			nIndEnsaio := aPendentes[nIndPend, 1]
			
			For nIndAmostra := 1 to Len(oQIPEnsaiosCalculados:aEnsaiosCalculados[nIndEnsaio, 'results'])
				nMedicoes := Len(oQIPEnsaiosCalculados:aEnsaiosCalculados[nIndEnsaio]['results'][nIndAmostra])
				oQIPEnsaiosCalculados:TrataRegistroParaInclusao(@oDadosCalc, oItemAPI, nIndEnsaio, nIndAmostra, nMedicoes)
			Next nIndAmostra

		Next nIndEnsaio

	EndIf
	
Return 

/*/{Protheus.doc} ModoAcessoResultados
Indica o modo de acesso do usuário aos resultados das amostras do QIP
@author brunno.costa
@since  23/05/2022
@param 01 - cLogin , caracter, login do usuário para validação das permissões de acesso
@return cRetorno, caracter, indica o modo de acesso do usuário aos resultados das amostras do QIP:
							1=Com Acesso;
							2=Sem Acesso;
							3=Apenas Consulta
/*/
METHOD ModoAcessoResultados(cLogin) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
     
    Local cAlias   := Nil
    Local cQuery   := Nil
	Local cRetorno := "1"
	Local lExiste  := !Empty(GetSx3Cache("QAA_INSPPR", "X3_TAMANHO"))
	
	If lExiste
		cQuery :=   " SELECT COALESCE( QAA_INSPPR, '1') QAA_INSPPR "
		cQuery +=   " FROM " + RetSQLName("QAA") + " "
		cQuery +=   " WHERE (D_E_L_E_T_ = ' ') "
		cQuery +=     " AND (QAA_FILIAL = '" + xFilial("QAA") + "') "
		cQuery +=     " AND (UPPER(RTRIM(QAA_LOGIN)) = " + FwQtToChr(AllTrim(Upper(cLogin))) +" ) "

		cAlias := Self:oAPIManager:oQueryManager:executeQuery(cQuery)

		If !Empty((cAlias)->QAA_INSPPR)
			cRetorno := Alltrim( (cAlias)->QAA_INSPPR )
		EndIf
		
		(cAlias)->(dbCloseArea())
	EndIF

Return cRetorno

/*/{Protheus.doc} RespondeAPIModoAcessoResultados
Responde via API se o usuário pode incluir resultados no QIP
@author brunno.costa
@since  10/12/2024
@param 01 - cLogin , caracter, login do usuário para validação das permissões de acesso
@param 02 - cEnsaio, caracter, código do ensaio para validação das permissões de acesso
@param 03 - nRecnoQPK, número, recno do ensaio na QPK
@param 04 - cOperacao, caracter, código da operação da inspeção relacionada para avaliação de sequência obrigatória
/*/
METHOD RespondeAPIModoAcessoResultados(cLogin, cEnsaio, nRecnoQPK, cOperacao) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
     
	Local cError            := ""
	Local cModoAcesso       := Self:ModoAcessoResultados(cLogin)
	Local oQIPLaudosEnsaios := Nil
	Local oResponse         := JsonObject():New()

	Default cEnsaio   := ""
	Default nRecnoQPK := -1
	Default cOperacao := ""
	
	//STR0062 - 'Acesso negado. Solicite liberação no campo'
	//STR0063 - ' do seu cadastro de usuário (QIEA050) do Protheus.'

	If     cModoAcesso == '1'
		oResponse['accessmode'] := 'insert'
	ElseIf cModoAcesso == '2'
		oResponse['accessmode'] := 'noAccess'
		oResponse['message'   ] := STR0062 + ' "' + AllTrim(GetSx3Cache("QAA_INSPPR","X3_TITULO")) + '" (QAA_INSPPR)' + STR0063
	ElseIf cModoAcesso == '3'
		oResponse['accessmode'] := 'onlyView'
		oResponse['message'   ] := STR0062 + ' "' + AllTrim(GetSx3Cache("QAA_INSPPR","X3_TITULO")) + '" (QAA_INSPPR)' + STR0063
	EndIf

	//Valida se o usuário possui permissão para incluir resultados no ensaio
	//STR0081 - Nivel atual incompatível com o Ensaio
	If !Empty(cEnsaio) .And. cModoAcesso != '2'
		If !Self:ValidaPermissaoDoUsuarioParaOEnsaio(cLogin, cEnsaio)
			oResponse['accessmode'] := 'onlyView'
			oResponse['message'   ] := STR0062 + ' "' + AllTrim(GetSx3Cache("QAA_NIVEL","X3_TITULO")) + '" (QAA_NIVEL)' + STR0063 + " " + STR0081 + " '" + AllTrim(cEnsaio) + "'."
		EndIf
	EndIf

	//Valida Fluxo de Permissão para Sequência Operação Obrigatória
	If cModoAcesso == "1" 
		nRecnoQPK := Iif(ValType(nRecnoQPK)=="C", Val(nRecnoQPK), nRecnoQPK)
		If nRecnoQPK > 0
			oQIPLaudosEnsaios := QIPLaudosEnsaios():New(Self:oWSRestFul)
			If !oQIPLaudosEnsaios:FluxoValidacaoSequenciaLaudoOperacao(nRecnoQPK, cOperacao, cLogin, @cError)
				oResponse['accessmode'] := 'onlyView'
				oResponse['message'   ] := cError
			EndIf
		EndIf
	EndIf

	oResponse['hasNext'           ] := .F.
	Self:oWSRestFul:SetContentType("application/json")

	//Processou com sucesso.
	HTTPSetStatus(200)
	oResponse['code'         ]     := 200
	Self:oWSRestFul:SetResponse(EncodeUtf8(oResponse:toJson()))

Return

/*/{Protheus.doc} ValidaPermissaoDoUsuarioParaOEnsaio
Valida se o usuário possui permissão para incluir resultados no ensaio
@author brunno.costa
@since  02/09/2025
@param 01 - cLogin , caracter, login do usuário para validação das permissões de acesso
@param 02 - cEnsaio, caracter, código do ensaio para validação das permissões de acesso
@return lPermite, lógico, indica se o usuário possui permissão para incluir resultados no ensaio
/*/
Method ValidaPermissaoDoUsuarioParaOEnsaio(cLogin, cEnsaio) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI

	Local cAlias   := Nil
	Local cQuery   := Nil
	Local lPermite := .T.
	
	cQuery :=   " SELECT COUNT(*) QTD "
	cQuery +=   " FROM " + RetSQLName("QAA") + " QAA "
	cQuery +=   " INNER JOIN " + RetSQLName("QP1") + " QP1 "
	cQuery +=   " ON "
	cQuery +=      Self:oAPIManager:oQueryManager:MontaQueryComparacaoFiliais("QAA", "QP1","QAA", "QP1") + " AND "
	cQuery +=      " COALESCE(NULLIF(QAA.QAA_NIVEL, ''), '00') >= COALESCE(NULLIF(QP1.QP1_NIENSR, ''), '00') "

	cQuery += " WHERE (QAA.QAA_FILIAL = '" + xFilial("QAA") + "') "
	cQuery +=   " AND (UPPER(RTRIM(QAA.QAA_LOGIN)) = " + FwQtToChr(AllTrim(Upper(cLogin))) + ") "
	cQuery +=   " AND (QP1.QP1_ENSAIO = '" + cEnsaio + "') "
	cQuery +=   " AND (QAA.D_E_L_E_T_ = ' ') "
	cQuery +=   " AND (QP1.D_E_L_E_T_ = ' ') "

	cAlias := Self:oAPIManager:oQueryManager:executeQuery(cQuery)

	lPermite := (cAlias)->QTD > 0
	
	(cAlias)->(dbCloseArea())

Return lPermite

/*/{Protheus.doc} CriaAliasListaInstrumentosRelacionadosAmostra
Retorna a lista de instrumentos de medição vinculados a amostra de resultados
@author brunno.costa
@since  18/03/2025
@param 01 - nRecnoQPR, número, recno do ensaio na QPR
@param 02 - lExclusao, lógico, indica se é para exclusão
@return cAlias, caracter, alias da consulta SQL
/*/
METHOD CriaAliasListaInstrumentosRelacionadosAmostra(nRecnoQPR, lExclusao) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI

    Local cAlias        := ""
    Local cQuery        := ""

	Default lExclusao := .F.

    // Construção da consulta SQL
    cQuery := "SELECT "
    cQuery +=    " QM2.QM2_VALDAF, "
    cQuery +=    " QM2.QM2_DESCR, "
    cQuery +=    " QM2.QM2_INSTR, "
    cQuery +=    " QM2.QM2_REVINS, "
	cQuery +=    " QPT.R_E_C_N_O_ "
    cQuery += " FROM "       + RetSQLName("QPT") + " QPT "
    cQuery += " INNER JOIN " + RetSQLName("QM2") + " QM2 "
    cQuery +=  " ON " + Self:oAPIManager:oQueryManager:montaQueryComparacaoFiliais("QPT", "QM2", "QPT", "QM2")
	cQuery +=   " AND QPT.QPT_INSTR  = QM2.QM2_INSTR "
	cQuery +=   " AND QPT.QPT_REVINS = QM2.QM2_REVINS "
    cQuery +=   " AND QM2.D_E_L_E_T_ = ' ' "
    cQuery += " INNER JOIN " + RetSQLName("QPR") + " QPR "
	cQuery +=   " ON " + Self:oAPIManager:oQueryManager:montaQueryComparacaoFiliais("QPT", "QPR", "QPT", "QPR")
	cQuery +=   " AND QPT.QPT_CODMED = QPR.QPR_CHAVE "
	
	If !lExclusao
    	cQuery +=   " AND QPR.D_E_L_E_T_ = ' ' "
	EndIf

    cQuery += " WHERE QPR.R_E_C_N_O_ = " + cValToChar(nRecnoQPR)
    cQuery +=   " AND QPT.D_E_L_E_T_ = ' ' "

    // Execução da consulta
    cAlias := Self:oApiManager:oQueryManager:executeQuery(cQuery)

Return cAlias

/*/{Protheus.doc} CriaAliasRepeticaoInstrumentos
Retorna a lista de instrumentos de medição para repetição da primeira amostra de resultados
@author brunno.costa
@since  21/03/2025
@param 01 - nRecnoQPK, número, recno da inspeção relacionada na QPK
@param 02 - cOperacao, caracter, código da operação relacionada
@param 03 - cIDTest  , caracter, ID do ensaio relacionado
@return cAlias, caracter, alias da consulta SQL
/*/
METHOD CriaAliasRepeticaoInstrumentos(nRecnoQPK, cOperacao, cIDTest) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI

    Local cAliasResult := ""
	Local cAliasReturn := ""
	Local nRecnoQPR     := 0
	
	nRecnoQPK := Iif(ValType(nRecnoQPK)=="C", Val(nRecnoQPK), nRecnoQPK)
	nRecnoQPK := Iif(ValType(nRecnoQPK)!="N", -1            , nRecnoQPK)

	If nRecnoQPK > 0 .And. !Empty(cOperacao) .ANd. !Empty(cIDTest)
		If (Self:CriaAliasResultadosInspecaoPorEnsaio(nRecnoQPK, "measurementDate+measurementTime", cIDTest, cOperacao, 1, 1, "*", @cAliasResult, Self:oAPIManager))
			If !Empty(cAliasResult) .AND. Select(cAliasResult) > 0
				nRecnoQPR := (cAliasResult)->RECNOQPR
				(cAliasResult)->(dbCloseArea())
			EndIf
		EndIf

		If nRecnoQPK > 0
			// Execução da consulta
			cAliasReturn := Self:CriaAliasListaInstrumentosRelacionadosAmostra(nRecnoQPR, .F.)
		EndIf
	EndIf

Return cAliasReturn

/*/{Protheus.doc} ListaInstrumentosRelacionadosAmostra
Retorna a lista de instrumentos de medição vinculados a amostra de resultados
@author brunno.costa
@since  18/03/2025
@param 01 - nRecnoQPR, número, recno do ensaio na QPR
@return lSucesso, lógico, indica se respondeu com sucesso a lista de instrumentos relacionados
/*/
METHOD ListaInstrumentosRelacionadosAmostra(nRecnoQPR) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI

    Local cAlias   := Self:CriaAliasListaInstrumentosRelacionadosAmostra(nRecnoQPR)
	Local lSucesso := .F.

    // Processamento dos resultados
    If !Empty(cAlias)
		Self:MapeiaCamposListaInstrumento()
        lSucesso := Self:oAPIManager:ProcessaListaResultados(cAlias)
    EndIf
	(cAlias)->(dbCloseArea())

Return lSucesso

/*/{Protheus.doc} RetornaRepeticaoInstrumentosPrimeiraAmostra
Retorna a lista de instrumentos de medição vinculados a amostra de resultados
@author brunno.costa
@since  21/03/2025
@param 01 - nRecnoQPR   , número  , recno do ensaio na QPR
@param 02 - cOperationID, caracter, código da operação relacionada
@param 03 - cIDTest     , caracter, ID do ensaio relacionado
@return lSucesso, lógico, indica se respondeu com sucesso a lista de instrumentos relacionados
/*/
METHOD RetornaRepeticaoInstrumentosPrimeiraAmostra(nRecnoQPK, cOperationID, cIDTest) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI

    Local cAlias   := Self:CriaAliasRepeticaoInstrumentos(nRecnoQPK, cOperationID, cIDTest)
	Local lSucesso := .F.

    // Processamento dos resultados
    If !Empty(cAlias)
		Self:MapeiaCamposListaInstrumento()
        lSucesso := Self:oAPIManager:ProcessaListaResultados(cAlias)
	    (cAlias)->(dbCloseArea())
    EndIf

Return lSucesso

/*/{Protheus.doc} ExcluiInstrumentosRelacionadosAmostra
Exclui instrumentos de medição vinculados a amostra de resultados
@author brunno.costa
@since  18/03/2025
@param 01 - nRecnoQPR, número, recno do ensaio na QPR
/*/
METHOD ExcluiInstrumentosRelacionadosAmostra(nRecnoQPR) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI

    Local cAlias := Self:CriaAliasListaInstrumentosRelacionadosAmostra(nRecnoQPR, .T.)

    While !(cAlias)->(Eof())
		QPT->(DbGoto((cAlias)->R_E_C_N_O_))
		
		RecLock("QPT",.F.)
		QPT->(dbDelete())
		MsUnLock()

		(cAlias)->(DbSkip())
	EndDo

Return 

/*/{Protheus.doc} MapeiaCamposListaInstrumento
Mapeia os Campos Lista de Instrumento de Medição
@author brunno.costa
@since  18/03/2025
@param 01 - cCampos, String, string com os campos [nPosCPS_Titulo_API] para consideração separados por vírgula
@return aMapaCampos, Array , {{lConsidera, Titulo Interface, Título API, Campo Protheus, Tipo, Tamanho, Decimal}, ...}
                             {{nPosCPS_Considera, ..., nPosCPS_Decimal}, ...}
/*/
METHOD MapeiaCamposListaInstrumento() CLASS ResultadosEnsaiosInspecaoDeProcessosAPI

    Local aMapaCampos := {}

	aadd(aMapaCampos, {.F., "Descricao"       , "description"   , "QM2_DESCR" , "C" , GetSx3Cache("QM2_DESCR" ,"X3_TAMANHO"), 0,})
    aadd(aMapaCampos, {.F., "Codigo"          , "code"          , "QM2_INSTR" , "C" , GetSx3Cache("QM2_INSTR" ,"X3_TAMANHO"), 0,})
	aadd(aMapaCampos, {.F., "Revisao"         , "revision"      , "QM2_REVINS", "C" , GetSx3Cache("QM2_REVINS","X3_TAMANHO"), 0,})
	aadd(aMapaCampos, {.F., "Val.Calibracao"  , "validate"      , "QM2_VALDAF", "D" , GetSx3Cache("QM2_VALDAF","X3_TAMANHO"), 0,})
	
	Self:oAPIManager := QualityAPIManager():New(aMapaCampos, Self:oWSRestFul)
	Self:oAPIManager:MarcaCamposConsiderados("*", aMapaCampos, nPosCPS_Titulo_API)

Return aMapaCampos

/*/{Protheus.doc} processaRelacionamentoInstrumento
Processa relacionamento do Instrumento (Inclui, altera ou excluí)
@author brunno.costa
@since  19/03/2025
@param 01 - oRegistro    , objeto, objeto com os dados do registro da QPR
@param 02 - oItemAPI	 , objeto, objeto com os dados do item da API
@param 03 - cErrorMessage, string, retorna por referência a mensagem de erro
@return lSucesso, lógico, indica se processou com sucesso a lista de instrumentos relacionados
/*/
METHOD processaRelacionamentoInstrumento(oRegistro, oItemAPI, cErrorMessage) as logical CLASS ResultadosEnsaiosInspecaoDeProcessosAPI

	Local aLista        := oItemAPI["instrumentsList"]
	Local cCarta        := Posicione("QP1", 1, xFilial("QP1")+oRegistro["QPR_ENSAIO"], "QP1_CARTA")
	Local cTipo         := ""
	Local lInstrumento  := Iif(ValType(GetMv("MV_QINVLTX")) == "C", Val(GetMv("MV_QINVLTX")), GetMv("MV_QINVLTX")) == 1
	Local lSucesso      := .T.
	Local nInstrumentos := 0
	Local nItem         := 0
	Local nRecnoQER     := oRegistro["R_E_C_N_O_"]
	Local nTotal        := Iif(aLista == Nil, 0, Len(aLista))
	Local oEnsaiosAPI   := EnsaiosInspecaoDeProcessosAPI():New(Self:oWSRestFul)

	//Valida Obrigatoriedade de Instrumento
	slMVQipQMT  := Iif(slMVQipQMT  == Nil, AllTrim(Upper(GetMv("MV_QIPQMT")))  == "S", slMVQipQMT  )
	slMVQinvlTx := Iif(slMVQinvlTx == Nil, lInstrumento  							 , slMVQinvlTx )
	scMVQlins   := Iif(scMVQlins   == Nil, AllTrim(GetMv("MV_QLINS"))                , scMVQlins   )

	If lSucesso
		//Grava Nao Conformidades
		DbSelectArea("QPT")
		DbSelectArea("QM2")
		DbSelectArea("QM6")
		QPT->(dbSetOrder(1))
		QM2->(dbSetOrder(1))
		QM6->(dbSetOrder(1))
		For nItem := 1 To nTotal

			//Ajusta tamanho dos campos Instrumento e Revisao
			aLista[nItem]['code']     := PadR(aLista[nItem]['code']    , GetSx3Cache("QPT_INSTR" ,"X3_TAMANHO"))
			aLista[nItem]['revision'] := PadR(aLista[nItem]['revision'], GetSx3Cache("QPT_REVINS","X3_TAMANHO"))

			//Inclusão / Alteração
			If !aLista[nItem,"deleted"]
				lSucesso      := self:validaInclusaoRelacionamentoInstrumento(oRegistro, aLista[nItem], @cErrorMessage)
				lSucesso      := lSucesso .AND. self:incluiRelacionamentoInstrumento(nRecnoQER, aLista[nItem])
				nInstrumentos := nInstrumentos + 1
			Else
				lSucesso      := self:excluiRelacionamentoInstrumento(nRecnoQER, aLista[nItem], @cErrorMessage, .T.)
			EndIf

			If !lSucesso
				Break
			Endif

		Next nItem

		//Valida Obrigatoriedade de Instrumento
		If lSucesso .AND. slMVQipQMT .AND. nInstrumentos == 0

			//Preenche oRegistro da QPR completo quando houver integração com o QMT em operação de edição
			If slMVQipQMT .And. oRegistro["R_E_C_N_O_"] > 0
				cTipo := oItemAPI["testType"]

				If cTipo == "N"        //Tipo N -> Array Numérico -> QP7
					lSucesso := Self:RecuperaCamposQP7paraQPR(@oRegistro, oItemAPI["recnoTest"])

				ElseIf cTipo == "T"    //Tipo T -> Texto -> QP8
					lSucesso := Self:RecuperaCamposQP8paraQPR(@oRegistro, oItemAPI["recnoTest"])

				EndIf

				If lSucesso
					lSucesso := Self:RecuperaCamposQPKParaQPR(@oRegistro, oItemAPI["recnoInspection"])
				EndIf
			EndIf
			
			If oEnsaiosAPI:PossuiFamiliaDeInstrumentos( oRegistro["QPR_PRODUT"],;
														oRegistro["QPR_REVI"  ],;
														oRegistro["QPR_ROTEIR"],;
														oRegistro["QPR_OPERAC"],;
														oRegistro["QPR_ENSAIO"])

				If cCarta != "TXT" .OR. slMVQinvlTx
					//STR0067 - "Informe o instrumento relacionado ao ensaio"
					cErrorMessage := STR0067 + " '" + AllTrim(Posicione("QP1", 1, xFilial("QP1") + oRegistro["QPR_ENSAIO"], "QP1_DESCPO")) + "(" + oRegistro["QPR_ENSAIO"] + ")'."
					lSucesso      := .F.
					Self:oAPIManager:lWarningError := .T.
				EndIf

			EndIf
		EndIf

	EndIf


Return lSucesso

/*/{Protheus.doc} validaInclusaoRelacionamentoInstrumento
Valida inclusão de relacionamento de Amostra com Instrumento
@author brunno.costa
@since  19/03/2025
@param 01 - oRegistro    , objeto, objeto com os dados do registro da QPR
@param 02 - oItem        , objeto, item para inclusão de relacionamento
@param 03 - cErrorMessage, string, retorna por referência a mensagem de erro
@return lSucesso, lógico, indica se processou com sucesso a validação de inclusão do relacionamento do instrumento
/*/
METHOD validaInclusaoRelacionamentoInstrumento(oRegistro, oItem, cErrorMessage) as logical CLASS ResultadosEnsaiosInspecaoDeProcessosAPI

	Local cEnsaio      := ""
    Local cInstrumento := IIf(!Empty(QM2->QM2_DESCR), AllTrim(QM2->QM2_DESCR) + " ", "") + "(" + AllTrim(oItem[ 'code' ]) + "/" + AllTrim(oItem[ 'revision' ]) + ")"
    Local dDataMedicao := oRegistro["QPR_DTMEDI"]
	Local lPosicQM2    := .F.
	Local lPosicQM6    := .F.
	Local lSucesso     := .T.
	
	lPosicQM2 := QM2->(dbSeek(xFilial("QM2")+oItem['code']+Inverte(oItem['revision'])))
	lPosicQM6 := QM6->(dbSeek(xFilial('QM6')+oItem['code']+        oItem['revision'] ))
	lSucesso  := lPosicQM2 .And. lPosicQM6

	//STR0068 - "Instrumento não encontrado""
	//STR0069 - "Calibração do instrumento"
	//STR0070 - "não encontrada."
	cErrorMessage := Iif(!lPosicQM2, STR0068 + ": " + AllTrim(oItem['code']) + "/" + AllTrim(oItem['revision']), cErrorMessage)
	cErrorMessage := Iif(!lPosicQM6, STR0069 + " '" + cInstrumento + "' " + STR0070, cErrorMessage)
	Self:oAPIManager:lWarningError := Iif(!lPosicQM2 .OR. !lPosicQM6, .T., Self:oAPIManager:lWarningError)

    // Laudo do instrumento vazio
    If lSucesso .And. Empty(QM2->QM2_LAUDO)
		//STR0071 - "Instrumento"
		//STR0072 - "relacionado ao ensaio"
		//STR0073 - "sem laudo cadastrado."
		cEnsaio      := AllTrim(Posicione("QP1", 1, xFilial("QP1") + oRegistro["QPR_ENSAIO"], "QP1_DESCPO")) + " (" + oRegistro["QPR_ENSAIO"] + ")"
        cErrorMessage := STR0071 + " '" + cInstrumento + "' " + STR0072 + " '" + cEnsaio + "' " + STR0073
        lSucesso      := .F.
		Self:oAPIManager:lWarningError := .T.
    EndIf

	// Laudo do instrumento incompatível
    If lSucesso .And. !(QM2->QM2_LAUDO $ scMVQlins)
		//STR0074 - "Laudo"
		//STR0075 - "do instrumento"
		//STR0072 - "relacionado ao ensaio"
		//STR0076 - "não é permitido (MV_QLINS)."
		cEnsaio      := AllTrim(Posicione("QP1", 1, xFilial("QP1") + oRegistro["QPR_ENSAIO"], "QP1_DESCPO")) + " (" + oRegistro["QPR_ENSAIO"] + ")"
        cErrorMessage := STR0074 + " '" + QM2->QM2_LAUDO + "' " + STR0075 + " '" + cInstrumento + "' " + STR0072 + " '" + cEnsaio + "' " + STR0076
        lSucesso      := .F.
		Self:oAPIManager:lWarningError := .T.
    EndIf

    // Instrumento inativo
    If lSucesso .AND. QM2->QM2_STATUS != "A"
		//STR0077 - "O instrumento"
		//STR0072 - "relacionado ao ensaio"
		//STR0078 - "está inativo."
		cEnsaio      := AllTrim(Posicione("QP1", 1, xFilial("QP1") + oRegistro["QPR_ENSAIO"], "QP1_DESCPO")) + " (" + oRegistro["QPR_ENSAIO"] + ")"
        cErrorMessage := STR0077 + " '" + cInstrumento + "' " + STR0072 + " '" + cEnsaio + "' " + STR0078
        lSucesso      := .F.
		Self:oAPIManager:lWarningError := .T.
    EndIf

    // Validade do instrumento incompatível
    If lSucesso .AND. QM2->QM2_VALDAF < dDataMedicao
		//STR0071 - "Instrumento"
		//STR0072 - "relacionado ao ensaio"
		//STR0079 - "com validade incompatível à data da amostra."
		cEnsaio      := AllTrim(Posicione("QP1", 1, xFilial("QP1") + oRegistro["QPR_ENSAIO"], "QP1_DESCPO")) + " (" + oRegistro["QPR_ENSAIO"] + ")"
        cErrorMessage := STR0071 + " '" + cInstrumento + "' " + STR0072 + " '" + cEnsaio + "' " + STR0079
        lSucesso      := .F.
		Self:oAPIManager:lWarningError := .T.
    EndIf

Return lSucesso

/*/{Protheus.doc} incluiRelacionamentoInstrumento
Processa inclusão de relacionamento de Amostra com Instrumento
@author brunno.costa
@since  19/03/2025
@param 01 - nRecnoQPR, número, recno da amostra na QPR relacionada
@param 02 - oItem    , objeto, item para inclusão de relacionamento
@return lSucesso, lógico, indica se processou com sucesso a inclusão do relacionamento instrumento
/*/
METHOD incluiRelacionamentoInstrumento(nRecnoQPR, oItem) as logical CLASS ResultadosEnsaiosInspecaoDeProcessosAPI

	Local cChaveQPR := ""
	Local lSucesso  := .F.

	//Posiciona na QPR
	QPR->(DbGoTo(nRecnoQPR))
	cChaveQPR := QPR->QPR_CHAVE

	If !QPT->(dbSeek(xFilial("QPT")+cChaveQPR+oItem['code']))
		RecLock("QPT",.T.)
		QPT->QPT_FILIAL := xFilial("QPT")
		QPT->QPT_CODMED := cChaveQPR
		QPT->QPT_INSTR  := oItem['code']
		MsUnLock()
		FkCommit()
	EndIf

	RecLock("QPT",.F.)
	QPT->QPT_INSTR  := oItem['code']
	QPT->QPT_REVINS := oItem['revision']
	QPT->QPT_TIPO   := QM2->QM2_TIPO
	QPT->QPT_REVTIP := QM6->QM6_REVTIP
	MsUnLock()
	FkCommit()
	lSucesso      := .T.

Return lSucesso

/*/{Protheus.doc} excluiRelacionamentoInstrumento
Processa exclusão de relacionamento de Amostra com Instrumento
@author brunno.costa
@since  19/03/2025
@param 01 - nRecnoQPR, número, recno da amostra na QPR relacionada
@param 02 - oItem  , objeto, item de para inclusão de relacionamento
@param 03 - cErrorMessage, string, retorna por referência a mensagem de erro
@return lSucesso, lógico, indica se processou com sucesso a exclusão do relacionamento instrumento
/*/
METHOD excluiRelacionamentoInstrumento(nRecnoQPR, oItem, cErrorMessage) as Logical CLASS ResultadosEnsaiosInspecaoDeProcessosAPI

	Local cBkpMsg   := cErrorMessage
	Local cChaveQPR := ""
	Local lPosicQPT := .F.
	Local lSucesso  := .F.

	oItem['code']     := PadR(oItem['code']    , GetSx3Cache("QPT_INSTR" ,"X3_TAMANHO"))

	//Posiciona na QPR
	If nRecnoQPR > 0
		QPR->(DbGoTo(nRecnoQPR))
		cChaveQPR := QPR->QPR_CHAVE

		lPosicQPT     := QPT->(dbSeek(xFilial("QPT")+cChaveQPR+oItem['code']))

		If lPosicQPT
			RecLock("QPT",.F.)
			QPT->(dbDelete())
			MsUnLock()
			lSucesso      := .T.
			cErrorMessage := cBkpMsg
		EndIf
	EndIf

Return lSucesso

/*/{Protheus.doc} EAPPQIPQMT
Função para definição de existência no RPO dos fontes de integração do APP Minha Produção do SIGAQIP com o SIGAQMT
@author brunno.costa
@since  18/03/2025
/*/
Function EAPPQIPQMT()
Return


/*/{Protheus.doc} QIPCASVAPI
Processamento assíncrono dos ensaios calculados
@type  Function
@author brunno.costa
@since  02/04/2025
@param 01 - cEmpAux  , caracter, empresa para abertura do ambiente
@param 02 - cFilAux  , caracter, filial para abertura do ambiente
@param 03 - cJsonData, caracter, dados json para reprocessamento
/*/
Function QIPCASVAPI(cEmpAux, cFilAux, cJsonData)

	Local oAPI      := Nil
	local cThReadID	:= threadID()

	FWLogMsg('INFO',, 'QIPCASVAPI', "QIPCASVAPI", '', '01', "QIPCASVAPI - Inicio - " + Time() + " - " + str(cThReadID) , 0, 0, {})

	//Seta job para nao consumir licenças
	RpcSetType(3)

	// Seta job para empresa filial desejada
	RpcSetEnv( cEmpAux, cFilAux,,, 'QIP')
	
	oAPI := ResultadosEnsaiosInspecaoDeProcessosAPI():New(Nil)
	oAPI:lResponseAPI := .F.
	oAPI:Salva(cJsonData)

	RpcClearEnv()

	FWLogMsg('INFO',, 'CTBXSEM', "QIPCASVAPI", '', '01', "QIPCASVAPI - Termino - " + Time() + " - " + str(cThReadID) , 0, 0, {})
	
Return


