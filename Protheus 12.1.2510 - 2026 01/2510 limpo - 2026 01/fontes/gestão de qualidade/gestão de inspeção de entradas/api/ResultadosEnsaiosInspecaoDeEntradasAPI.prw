#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "ResultadosEnsaiosInspecaoDeEntradasAPI.CH"

Static lQLTExAAmIn  := Nil
Static scMVQlins    := Nil
Static slMVQINTQMT  := Nil
Static slMVQinvlTx  := Nil
Static slQLTMetrics := FindClass("QLTMetrics")
Static sQNCClass    := Nil

//Desconsiderado o uso de FWAPIManager devido complexidade de DE-PARA das tabelas QEK, QES, QEQ x API Mobile

#DEFINE nPosCPS_Considera                  1
#DEFINE nPosCPS_Titulo_Interface           2
#DEFINE nPosCPS_Titulo_API                 3
#DEFINE nPosCPS_Protheus                   4
#DEFINE nPosCPS_Tipo                       5
#DEFINE nPosCPS_Tamanho                    6
#DEFINE nPosCPS_Decimal                    7
#DEFINE nPosCPS_Alias                      8
#DEFINE nPosCPS_Protheus_Externo           9

/*/{Protheus.doc} incominginspectiontestresults
API Resultados Ensaios da Inspeção de Entradas - Qualidade
@author brunno.costa
@since  23/05/2022
/*/
WSRESTFUL incominginspectiontestresults DESCRIPTION STR0001 FORMAT APPLICATION_JSON //"Resultados Ensaios Inspeção de Entradas"

	WSDATA BlocoErro as STRING OPTIONAL
    WSDATA Fields    as STRING OPTIONAL
	WSDATA Form      as OBJECT OPTIONAL
	WSDATA IDTest    as STRING OPTIONAL
	WSDATA Login     as STRING OPTIONAL
    WSDATA Order     as STRING OPTIONAL
    WSDATA Page      as INTEGER OPTIONAL
    WSDATA PageSize  as INTEGER OPTIONAL
    WSDATA RecnoQEK  as STRING OPTIONAL
	WSDATA RecnoQER  as STRING OPTIONAL
	WSDATA RecnoQQM  as STRING OPTIONAL
    WSDATA RecnosQER as STRING OPTIONAL

    WSMETHOD GET result;
    DESCRIPTION STR0015; //"Retorna Resultado da Inspeção de Entradas"
    WSSYNTAX "api/qie/v1/result/{RecnoQEK}/{RecnosQER}/{Order}/{Page}/{PageSize}" ;
    PATH "/api/qie/v1/result" ;
    TTALK "v1"

    WSMETHOD GET testhistory;
    DESCRIPTION STR0015; //"Retorna Resultado da Inspeção de Entradas"
    WSSYNTAX "api/qie/v1/testhistory/{RecnoQEK}/{IDTest}/{Order}/{Page}/{PageSize}" ;
    PATH "/api/qie/v1/testhistory" ;
    TTALK "v1"

	WSMETHOD GET history;
    DESCRIPTION STR0016; //"Retorna Histórico de Resultados da Inspeção de Entradas"
    WSSYNTAX "api/qie/v1/history/{RecnoQEK}/{Order}/{Page}/{PageSize}" ;
    PATH "/api/qie/v1/history" ;
    TTALK "v1"
	
	WSMETHOD POST save;
	DESCRIPTION STR0002; //"Salva Resultado"
	WSSYNTAX "api/qie/v1/save" ;
	PATH "/api/qie/v1/save" ;
	TTALK "v1"

	WSMETHOD DELETE result;
	DESCRIPTION STR0031; //"Deleta Informações de uma Amostra"
	WSSYNTAX "api/qie/v1/result/{RecnoQER}" ;
    WSSYNTAX "api/qie/v1/result" ;
	TTALK "v1"

	WSMETHOD GET canreceivefiles;
	DESCRIPTION STR0043; //"Indica se o ambiente está preparado para o recebimento de arquivos";
	WSSYNTAX "api/qie/v1/canreceivefiles" ;
	PATH "/api/qie/v1/canreceivefiles" ;
	TTALK "v1"

	WSMETHOD GET accessmode;
	DESCRIPTION STR0061; //"Indica o modo de acesso do usuário as amostras de resultados"
	WSSYNTAX "api/qie/v1/accessmode/{Login}/{IDTest}" ;
	PATH "/api/qie/v1/accessmode" ;
	TTALK "v1"

	WSMETHOD GET texttypesize;
	DESCRIPTION STR0060; //"Indica o tamanho máximo do resultado do tipo texto";
	WSSYNTAX "api/qie/v1/texttypesize" ;
	PATH "/api/qie/v1/texttypesize" ;
	TTALK "v1"

	WSMETHOD GET vldsingleresult;
	DESCRIPTION STR0083; //"Indica se permite a inclusao do resultado individual de formulario atual"
	WSSYNTAX "api/qie/v1/vldsingleresult/{Login}/{RecnoQEK}/{RecnoQER}" ;
	PATH "/api/qie/v1/vldsingleresult" ;
	TTALK "v1"

	WSMETHOD GET vldmultipleresult;
	DESCRIPTION STR0084; //"Indica se permite a inclusao do resultado multiplo de formulario atual"
	WSSYNTAX "api/qie/v1/vldmultipleresult/{Login}/{RecnoQEK}" ;
	PATH "/api/qie/v1/vldmultipleresult" ;
	TTALK "v1"

	WSMETHOD GET dateeditpermission;
	DESCRIPTION STR0065; //"Indica a permissão para edição do campo data da amostra"
	WSSYNTAX "api/qie/v1/dateeditpermission/{Login}/{RecnoQEK}/{RecnoQER}" ;
	PATH "/api/qie/v1/dateeditpermission" ;
	TTALK "v1"

	WSMETHOD GET timeeditpermission;
	DESCRIPTION STR0066; //"Indica a permissão para edição do campo hora da amostra"
	WSSYNTAX "api/qie/v1/timeeditpermission/{Login}/{RecnoQEK}/{RecnoQER}" ;
	PATH "/api/qie/v1/timeeditpermission" ;
	TTALK "v1"

	WSMETHOD GET relatedinstruments;
    DESCRIPTION STR0067; //"Lista instrumentos relacioados à amostra"
    WSSYNTAX "api/qie/v1/relatedinstruments/{RecnoQER}";
    PATH "/api/qie/v1/relatedinstruments" ;
    TTALK "v1"

	WSMETHOD GET repeatrelatedinstruments;
    DESCRIPTION STR0081; //"Retorna lista de instrumentos para repetição com base na primeira amostra de resultados"
    WSSYNTAX "api/qie/v1/repeatrelatedinstruments/{RecnoQEK}/{IDTest}" ;
    PATH "/api/qie/v1/repeatrelatedinstruments" ;
    TTALK "v1"

ENDWSRESTFUL


WSMETHOD GET result PATHPARAM RecnoQEK, RecnosQER, Order, Page, PageSize QUERYPARAM Fields WSSERVICE incominginspectiontestresults

	Local aRecnosQER := Nil
    Local oAPIClass  := ResultadosEnsaiosInspecaoDeEntradasAPI():New(Self)

	Default Self:Fields    := ""
	Default Self:Order     := ""
	Default Self:Page      := 1
	Default Self:PageSize  := 5
	Default Self:RecnoQEK  := ""
	Default Self:RecnosQER := ""

	aRecnosQER := StrTokArr2( Self:RecnosQER, ";")

Return oAPIClass:RetornaResultadosInspecao(Self:RecnoQEK, Self:Order, aRecnosQER, Self:Page, Self:PageSize, Self:Fields)


WSMETHOD GET testhistory PATHPARAM RecnoQEK, IDTest, Order, Page, PageSize QUERYPARAM Fields WSSERVICE incominginspectiontestresults

    Local oAPIClass  := ResultadosEnsaiosInspecaoDeEntradasAPI():New(Self)

	Default Self:Fields   := ""
	Default Self:IDTest   := ""
	Default Self:Order    := ""
	Default Self:Page     := 1
	Default Self:PageSize := 5
	Default Self:RecnoQEK := ""
	
Return oAPIClass:RetornaResultadosInspecaoPorEnsaio(Self:RecnoQEK, Self:Order, Self:IDTest, Self:Page, Self:PageSize, Self:Fields)

WSMETHOD GET repeatrelatedinstruments PATHPARAM RecnoQEK, IDTest, Order, Page, PageSize QUERYPARAM Fields WSSERVICE incominginspectiontestresults
    Local oAPIClass  := ResultadosEnsaiosInspecaoDeEntradasAPI():New(Self)
	Default Self:RecnoQEK    := ""
	Default Self:IDTest      := ""
Return oAPIClass:RetornaRepeticaoInstrumentosPrimeiraAmostra(Self:RecnoQEK, Self:IDTest)

WSMETHOD GET history PATHPARAM RecnoQEK, Order, Page, PageSize QUERYPARAM Fields WSSERVICE incominginspectiontestresults

	Local aRecnosQER := Nil
    Local oAPIClass  := ResultadosEnsaiosInspecaoDeEntradasAPI():New(Self)

	Default Self:Fields   := ""
	Default Self:Order    := ""
	Default Self:Page     := 1
	Default Self:PageSize := 5
	Default Self:RecnoQEK := ""

Return oAPIClass:RetornaResultadosInspecao(Self:RecnoQEK, Self:Order, aRecnosQER, Self:Page, Self:PageSize, Self:Fields)


WSMETHOD GET relatedinstruments PATHPARAM RecnoQER QUERYPARAM Fields WSSERVICE incominginspectiontestresults
    Local oAPIClass  := ResultadosEnsaiosInspecaoDeEntradasAPI():New(Self)
	Default Self:RecnoQER  := ""
Return oAPIClass:ListaInstrumentosRelacionadosAmostra(Val(Self:RecnoQER))


WSMETHOD POST save QUERYPARAM Fields PATHPARAM BlocoErro WSSERVICE incominginspectiontestresults

    Local oAPIClass  := ResultadosEnsaiosInspecaoDeEntradasAPI():New(Self)

	Default Self:BlocoErro  := ".T."

Return oAPIClass:Salva(DecodeUTF8(Self:GetContent()), Self:BlocoErro)


WSMETHOD DELETE result PATHPARAM RecnoQER, BlocoErro WSSERVICE incominginspectiontestresults

    Local oAPIClass  := ResultadosEnsaiosInspecaoDeEntradasAPI():New(Self)

	Self:SetContentType("application/json")
	Default Self:BlocoErro  := ".T."

Return oAPIClass:DeletaAmostra(Val(Self:RecnoQER), Nil,  Self:BlocoErro)


WSMETHOD GET accessmode PATHPARAM Login, IDTest WSSERVICE incominginspectiontestresults
    Local oAPIClass  := ResultadosEnsaiosInspecaoDeEntradasAPI():New(Self)
	oAPIClass:RespondeAPIModoAcessoResultados(Self:Login, Self:IDTest)
Return 


WSMETHOD GET texttypesize WSSERVICE incominginspectiontestresults

    Local oAPIClass  := ResultadosEnsaiosInspecaoDeEntradasAPI():New(Self)

	oAPIClass:RetornaTamanhoResultadoTipoTexto()

Return 


WSMETHOD GET vldsingleresult PATHPARAM Login, RecnoQEK, RecnoQER QUERYPARAM Form WSSERVICE incominginspectiontestresults

    Local oAPIManager := QualityAPIManager():New({}, Self)
	Local oObj        := JsonObject()       :New()
	Local oResponse   := JsonObject()       :New()
	Local oReturnPE   := JsonObject()       :New()

	Default Self:RecnoQEK := "-1"
	Default Self:RecnoQER := "-1"

	oResponse["permite" ] := .T.
	oResponse["mensagem"] := ""

	If oAPIManager:existePEIntegracaoAppMinhaProducaoCompilado("QIE")
		oObj             := JsonObject():New()
		oObj["login"   ] := Self:Login
		oObj["recnoQEK"] := Val(Self:RecnoQEK)
		oObj["recnoQER"] := Val(Self:RecnoQER)
		oObj["insert"  ] := Val(Self:RecnoQER) < 1
		oObj["update"  ] := Val(Self:RecnoQER) > 0
		oObj["form"    ] := Self:Form

		oReturnPE := Execblock('QIEINTAPI',.F.,.F.,{oObj, "incominginspectiontestresults/api/qie/v1/vldsingleresult", "ResultadosEnsaiosInspecaoDeEntradasAPI", "validaResultadoUnico"})
		If Valtype(oReturnPE) == 'J' .And. ValType(oReturnPE['permite']) == "L" .And. ValType(oReturnPE['mensagem']) == "C"
			oResponse := oReturnPE
		EndIf
	EndIf
	
	oAPIManager:RespondeValor("response", oResponse)

Return 


WSMETHOD GET vldmultipleresult PATHPARAM Login, RecnoQEK QUERYPARAM Form WSSERVICE incominginspectiontestresults

    Local oAPIManager := QualityAPIManager():New({}, Self)
	Local oObj        := JsonObject()       :New()
	Local oResponse   := JsonObject()       :New()
	Local oReturnPE   := JsonObject()       :New()

	Default Self:RecnoQEK := -1
	Default Self:RecnoQER := -1

	oResponse["permite" ] := .T.
	oResponse["mensagem"] := ""

	If oAPIManager:existePEIntegracaoAppMinhaProducaoCompilado("QIE")
		oObj             := JsonObject():New()
		oObj["login"   ] := Self:Login
		oObj["recnoQEK"] := Val(Self:RecnoQEK)
		oObj["form"    ] := Self:Form

		oReturnPE := Execblock('QIEINTAPI',.F.,.F.,{oObj, "incominginspectiontestresults/api/qie/v1/vldmultipleresult", "ResultadosEnsaiosInspecaoDeEntradasAPI", "validaResultadosMultiplos"})
		If Valtype(oReturnPE) == 'J' .And. ValType(oReturnPE['permite']) == "L" .And. ValType(oReturnPE['mensagem']) == "C"
			oResponse := oReturnPE
		EndIf
	EndIf
	
	oAPIManager:RespondeValor("response", oResponse)

Return 


WSMETHOD GET dateeditpermission PATHPARAM Login, RecnoQEK, RecnoQER WSSERVICE incominginspectiontestresults

	Local lBloqueioPE := .F.
	Local lPermite    := .T.
    Local oAPIManager := QualityAPIManager():New({}, Self)
	Local oObj        := JsonObject()       :New()

	Default Self:RecnoQEK  := "-1"
	Default Self:RecnoQER  := "-1"

	If oAPIManager:existePEIntegracaoAppMinhaProducaoCompilado("QIE")
		oObj             := JsonObject():New()
		oObj["login"   ] := Self:Login
		oObj["recnoQEK"] := Val(Self:RecnoQEK)
		oObj["recnoQER"] := Val(Self:RecnoQER)
		oObj["insert"  ] := Val(Self:RecnoQER) < 1
		oObj["update"  ] := Val(Self:RecnoQER) > 0
		lBloqueioPE := Execblock('QIEINTAPI',.F.,.F.,{oObj, "incominginspectiontestresults/api/qie/v1/dateeditpermission", "ResultadosEnsaiosInspecaoDeEntradasAPI", "bloqueiaDataInspecao"})
		If Valtype(lBloqueioPE) == 'L'
			lPermite := !lBloqueioPE
		EndIf
	EndIf
	
	oAPIManager:RespondeValor("permission", lPermite)

Return 

WSMETHOD GET timeeditpermission PATHPARAM Login, RecnoQEK, RecnoQER WSSERVICE incominginspectiontestresults

	Local lBloqueioPE := .F.
	Local lPermite    := .T.
    Local oAPIManager := QualityAPIManager():New({}, Self)
	Local oObj        := JsonObject()       :New()

	Default Self:RecnoQEK  := "-1"
	Default Self:RecnoQER  := "-1"

	If oAPIManager:existePEIntegracaoAppMinhaProducaoCompilado("QIE")
		oObj             := JsonObject():New()
		oObj["login"   ] := Self:Login
		oObj["recnoQEK"] := Val(Self:RecnoQEK)
		oObj["recnoQER"] := Val(Self:RecnoQER)
		oObj["insert"  ] := Val(Self:RecnoQER) < 1
		oObj["update"  ] := Val(Self:RecnoQER) > 0
		lBloqueioPE := Execblock('QIEINTAPI',.F.,.F.,{oObj, "incominginspectiontestresults/api/qie/v1/timeeditpermission", "ResultadosEnsaiosInspecaoDeEntradasAPI", "bloqueiaHoraInspecao"})
		If Valtype(lBloqueioPE) == 'L'
			lPermite := !lBloqueioPE
		EndIf
	EndIf
	
	oAPIManager:RespondeValor("permission", lPermite)

Return 

/*/{Protheus.doc} ResultadosEnsaiosInspecaoDeEntradasAPI
Regras de Negocio - API Inspeção de Entradas
@author brunno.costa
@since  23/05/2022
/*/
CLASS ResultadosEnsaiosInspecaoDeEntradasAPI FROM LongNameClass

	DATA aCamposAPI                         as ARRAY
	DATA aCamposQEQ                         as ARRAY
	DATA aCamposQER                         as ARRAY
	DATA aCamposQES                         as ARRAY
	DATA cDetailedMessage                   as STRING
	DATA cErrorMessage                      as STRING
	DATA cLogin                             as STRING
	DATA lExcluiuRegistroNumerico           as LOGICAL
	DATA lForcaInexistenciaDiretorio        as LOGICAL
	DATA lProcessaRetorno                   as LOGICAL
	DATA lResponseAPI                       as LOGICAL
	DATA lSalvouRegistroNumerico            as LOGICAL
	DATA lTemQQM                            as LOGICAL
	DATA nAmostraTela                       as STRING
	DATA nCamposQER                         as NUMERIC
	DATA nRecnoQEK                          as NUMERIC
	DATA nRegistros                         as NUMERIC
	DATA oAnexos                            as OBJECT
	DATA oAPIManager                        as OBJECT
	DATA oCacheEnsaiadorQER                 as OBJECT
	DATA oCacheInexistenciaLaudoLaboratorio as OBJECT
	DATA oCachePermissaoEnsaioNumerico      as OBJECT
	DATA oCacheQuantidadeMedicoesEnsaio     as OBJECT
	DATA oQueryManager                      as OBJECT
    DATA oWSRestFul                         as OBJECT

    METHOD new(oWSRestFul) CONSTRUCTOR
	METHOD DeletaAmostra(nRecnoQER, cUsuario)
	METHOD DeletaAmostraSemResponse(nRecnoQER, cChaveQEK)
	METHOD ModoAcessoResultados()
	METHOD RespondeAPIModoAcessoResultados()
	METHOD RetornaTamanhoResultadoTipoTexto()
    METHOD Salva(cJsondata, cBlocoForcaErro)
     
    //Métodos Internos
	METHOD AtualizaChaveQERParaMedia(oRegistro)
	METHOD AtualizaEnsaiadorQER(cLogin, oRegistro)
	METHOD AtualizaStatusQEKComChaveQEK(cChaveQEK)
	METHOD AtualizaStatusQEKComRecno(nRecnoQEK)
	METHOD CriaAliasListaInstrumentosRelacionadosAmostra(nRecnoQER)
	METHOD CriaAliasRepeticaoInstrumentos(nRecnoQEK, cIDTest)
	METHOD CriaAliasResultadosInspecaoPorEnsaio(nRecnoQEK, cOrdem, cIDTest, nPagina, nTamPag, cCampos, cAlias, cAlias, oAPIManager)
	METHOD CriaPasta(cDiretorio)
	METHOD EnsaioComMedia(cTipo, cFormula)
	METHOD ErrorBlock(e)
	METHOD ExcluiInstrumentosRelacionadosAmostra(nRecnoQER)
	METHOD ExcluiRelacionamentoInstrumento(nRecnoQER, oItem, cErrorMessage)
	METHOD ExisteLaudoRelacionadoAoPost(oDadosJson)
	METHOD GeraChaveQER()
	METHOD IdentificaRecnosInspecoesEEnsaios(oDadosJson, aRecsQEK, aRecsQE7, aRecsQE8)
	METHOD IncluiRelacionamentoInstrumento(nRecnoQER, oItemAPI)
	METHOD ListaInstrumentosRelacionadosAmostra(nRecnoQER)
	METHOD MapeiaCamposAPI(cCampos)
	METHOD MapeiaCamposListaInstrumento()
	METHOD MapeiaCamposQEQ(cCampos)
	METHOD MapeiaCamposQER(cCampos)
	METHOD MapeiaCamposQES(cCampos)
	METHOD PreparaDadosQEQ(oItemAPI)
	METHOD PreparaDadosQES(oItemAPI)
	METHOD PreparaRegistroInclusaoQER(oItemAPI, oRegistro)
	METHOD PreparaRegistroQER(oItemAPI, oRegistro)
	METHOD ProcessaItensRecebidos(oDadosJson, aRecnosQER)
	METHOD processaRelacionamentoInstrumento(oRegistro, oItemAPI, cErrorMessage)
	METHOD RecuperaCamposQE7paraQER(oRegistro, nRecnoQE7)
	METHOD RecuperaCamposQE8paraQER(oRegistro, nRecnoQE8)
	METHOD RecuperaCamposQEKParaQER(oRegistro, nRecnoQEK)
	METHOD RetornaRepeticaoInstrumentosPrimeiraAmostra(nRecnoQEK, cIDTest)
	METHOD RetornaResultadosInspecao(nRecnoQEK, cOrdem, aRecnosQER, nPagina, nTamPag, cCampos)
	METHOD RetornaResultadosInspecaoPorEnsaio(nRecnoQEK, cOrdem, cIDTest, nPagina, nTamPag, cCampos)
	METHOD RevisaEnsaiosCalculados(oDadosJson)
    METHOD SalvaRegistroNumerico(oItemAPI)
	METHOD SalvaRegistroQESSequencialmente(oDadosQES)
	METHOD SalvaRegistros(oItemAPI)
	METHOD SalvaRegistroTexto(oItemAPI)
	METHOD ValidaEnsaiador(oRegistro)
	METHOD ValidaEnsaioEditavel(cEnsaio, cOperacao)
	METHOD ValidaEnsaioEditavelPorQER(cOperacao)
	METHOD ValidaEnsaioEditavelPorRegistro(oRegistro, cOperacao)
	METHOD ValidaFormatosCamposItem(oItemAPI, aCamposAPI)
	METHOD validaInclusaoRelacionamentoInstrumento(oRegistro, oItemAPI, cErrorMessage)
	METHOD ValidaInexistenciaLaudoLaboratorio(cChaveQEL, cOperacao)
	Method ValidaPermissaoDoUsuarioParaOEnsaio(cLogin, cEnsaio)
	METHOD ValidaPermissaoEnsaioNumerico(nRecnoQE7)
	METHOD ValidaPermissaoEnsaioTexto(nRecnoQE8)
	METHOD ValidaQuantidadeMedicoesEnsaio(oItemAPI, nMedicoes, cEnsaio)
	METHOD ValidaUsuarioProtheus(oItemAPI)

ENDCLASS

METHOD new(oWSRestFul) CLASS ResultadosEnsaiosInspecaoDeEntradasAPI
	Self:cDetailedMessage            := ""
	Self:cErrorMessage               := ""
	Self:lExcluiuRegistroNumerico    := .F.
	Self:lForcaInexistenciaDiretorio := .F.
	Self:lProcessaRetorno            := .T.
	Self:lSalvouRegistroNumerico     := .F.
	Self:lTemQQM                     := !Empty(FWX2Nome( "QQM" ))
	self:nAmostraTela                := ""
	Self:oAnexos                     := AnexosInspecaoQualidadeAPI():New(Self)
	Self:oAPIManager                 := QualityAPIManager()         :New(Nil, oWSRestFul, Nil)
	Self:oQueryManager               := QLTQueryManager()           :New()
	Self:oWSRestFul                  := oWSRestFul
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
METHOD MapeiaCamposAPI(cCampos) CLASS ResultadosEnsaiosInspecaoDeEntradasAPI

    Local aMapaCampos := {}

	aAdd(aMapaCampos, {.T., "RecnoInspecao"     , "recnoInspection"     , "RECNOQEK"   , "NN" ,                                       0, 0, "QEK"})    //NN para não formatar como número pois não temos certeza do tamanho configurado na tabela do cliente
	aAdd(aMapaCampos, {.T., "RecnoEnsaio"       , "recnoTest"           , "RECNOTEST"  , "NN" ,                                       0, 0, "QE7QE8"}) //NN para não formatar como número pois não temos certeza do tamanho configurado na tabela do cliente
	aAdd(aMapaCampos, {.F., "Ensaio"            , "testID"              , "QER_ENSAIO" , "CN" , GetSx3Cache("QER_ENSAIO" ,"X3_TAMANHO"), 0, "QER"})
	aAdd(aMapaCampos, {.F., "Data"              , "measurementDate"     , "QER_DTMEDI" , "D"  , GetSx3Cache("QER_DTMEDI" ,"X3_TAMANHO"), 0, "QER"})
	aAdd(aMapaCampos, {.F., "Hora"              , "measurementTime"     , "QER_HRMEDI" , "H"  , GetSx3Cache("QER_HRMEDI" ,"X3_TAMANHO"), 0, "QER"})
	aAdd(aMapaCampos, {.F., "CodigoEnsaiador"   , "rehearserID"         , "QER_ENSR"   , "C"  , GetSx3Cache("QER_ENSR"   ,"X3_TAMANHO"), 0, "QER"})
	aAdd(aMapaCampos, {.F., "Ensaiador"         , "rehearser"           , "QAA_NOME"   , "C"  , GetSx3Cache("QAA_NOME"   ,"X3_TAMANHO"), 0, "QAA"})
	aAdd(aMapaCampos, {.T., "NumeroAmostra"     , "sampleNumber"        , "QER_AMOSTR" , "N"  , GetSx3Cache("QER_AMOSTR" ,"X3_TAMANHO"), 0, "QER" })
	aAdd(aMapaCampos, {.T., "TipoEnsaio"        , "testType"            , "TIPO"       , "C"  ,                                       1, 0, "N/A"})
	aAdd(aMapaCampos, {.F., "ArrayMedicoes"     , "measurements"        , "MEDICOES"   , "A"  ,                                       0, 0, "QES"})
	aAdd(aMapaCampos, {.F., "TextoStatus"       , "textStatus"          , "QER_RESULT" , "C"  , GetSx3Cache("QER_RESULT" ,"X3_TAMANHO"), 0, "QER"})
	aAdd(aMapaCampos, {.F., "TextoDetalhes"     , "textDetail"          , "QEQ_MEDICA" , "C"  , GetSx3Cache("QEQ_MEDICA" ,"X3_TAMANHO"), 0, "QEQ"})
	aAdd(aMapaCampos, {.F., "UsuarioProtheus"   , "protheusLogin"       , "QAA_LOGIN"  , "C"  , GetSx3Cache("QAA_LOGIN"  ,"X3_TAMANHO"), 0, "QAA"})
	aAdd(aMapaCampos, {.T., "Recno"             , "recno"               , "RECNOQER"   , "NN" ,                                       0, 0, "QER"}) //NN para não formatar como número pois não temos certeza do tamanho configurado na tabela do cliente
	aAdd(aMapaCampos, {.T., "TemAnexo"          , "hasAttachment"       , "TEMANEXO"   , "C"  ,                                       0, 0, "QQM"})
 
    aMapaCampos := Self:oAPIManager:MarcaCamposConsiderados(cCampos, aMapaCampos, nPosCPS_Titulo_API)

Return aMapaCampos

/*/{Protheus.doc} MapeiaCamposQER
Mapeia os Campos da tabela QER do Protheus - Dados Genéricos das Medições
@author brunno.costa
@since  23/05/2022
@param 01 - cCampos, String, string com os campos [nPosCPS_Titulo_API] para consideração separados por vírgula
@return aMapaCampos, Array , {{lConsidera, Titulo Interface, Título API, Campo Protheus, Tipo, Tamanho, Decimal}, ...}
                             {{nPosCPS_Considera, ..., nPosCPS_Decimal}, ...}
/*/
METHOD MapeiaCamposQER(cCampos) CLASS ResultadosEnsaiosInspecaoDeEntradasAPI

    Local aMapaCampos := {}

	aAdd(aMapaCampos, {.T., "Data"              , "measurementDate"     , "QER_DTMEDI"        , "D"  , GetSx3Cache("QER_DTMEDI" ,"X3_TAMANHO"), 0, "QER" })
	aAdd(aMapaCampos, {.T., "Hora"              , "measurementTime"     , "QER_HRMEDI"        , "C"  , GetSx3Cache("QER_HRMEDI" ,"X3_TAMANHO"), 0, "QER" })
	aAdd(aMapaCampos, {.T., "Ensaiador"         , "rehearser"           , "QER_ENSR"          , "C"  , GetSx3Cache("QER_ENSR"   ,"X3_TAMANHO"), 0, "QER" })
	aAdd(aMapaCampos, {.T., "TextoStatus"       , "textStatus"          , "QER_RESULT"        , "C"  , GetSx3Cache("QER_RESULT" ,"X3_TAMANHO"), 0, "QER" })
	aAdd(aMapaCampos, {.T., "NumeroAmostra"     , "sampleNumber"        , "QER_AMOSTR"        , "N"  , GetSx3Cache("QER_AMOSTR" ,"X3_TAMANHO"), 0, "QER" })
	aAdd(aMapaCampos, {.T., "N/A"               , "N/A"                 , "QER_CHAVE"         , "C"  ,                                       0, 0, "QER" })
	aAdd(aMapaCampos, {.T., "N/A"               , "N/A"                 , "QER_NISERI"        , "C"  ,                                       0, 0, "QEK"   , "QEK_NTFISC+QEK_SERINF+QEK_ITEMNF"})
	aAdd(aMapaCampos, {.T., "N/A"               , "N/A"                 , "QER_NTFISC"        , "C"  ,                                       0, 0, "QEK"   , "QEK_NTFISC"})
	aAdd(aMapaCampos, {.T., "N/A"               , "N/A"                 , "QER_SERINF"        , "C"  ,                                       0, 0, "QEK"   , "QEK_SERINF"})
	aAdd(aMapaCampos, {.T., "N/A"               , "N/A"                 , "QER_ITEMNF"        , "C"  ,                                       0, 0, "QEK"   , "QEK_ITEMNF"})
	aAdd(aMapaCampos, {.T., "N/A"               , "N/A"                 , "QER_TIPONF"        , "C"  ,                                       0, 0, "QEK"   , "QEK_TIPONF"})
	aAdd(aMapaCampos, {.T., "N/A"               , "N/A"                 , "QER_NUMSEQ"        , "C"  ,                                       0, 0, "QEK"   , "QEK_NUMSEQ"})
	aAdd(aMapaCampos, {.T., "N/A"               , "N/A"                 , "QER_FILMAT"        , "C"  ,                                       0, 0, "QAA"   , "QAA_FILIAL"})
	aAdd(aMapaCampos, {.T., "N/A"               , "N/A"                 , "QER_REVI"          , "C"  ,                                       0, 0, "QEK"   , "QEK_REVI"  })
	aAdd(aMapaCampos, {.T., "N/A"               , "N/A"                 , "QER_DTENTR"        , "C"  ,                                       0, 0, "QEK"   , "QEK_DTENTR"})
	aAdd(aMapaCampos, {.T., "N/A"               , "N/A"                 , "QER_LOTE"          , "C"  ,                                       0, 0, "QEK"   , "QEK_LOTE"  })
	aAdd(aMapaCampos, {.T., "N/A"               , "N/A"                 , "QER_FORNEC"        , "C"  ,                                       0, 0, "QEK"   , "QEK_FORNEC"})
	aAdd(aMapaCampos, {.T., "N/A"               , "N/A"                 , "QER_LOJFOR"        , "C"  ,                                       0, 0, "QEK"   , "QEK_LOJFOR"})
	aAdd(aMapaCampos, {.T., "N/A"               , "N/A"                 , "QER_PRODUT"        , "C"  ,                                       0, 0, "QE7QE8", "QE7_PRODUT"})
	aAdd(aMapaCampos, {.T., "N/A"               , "N/A"                 , "QER_LABOR"         , "C"  ,                                       0, 0, "QE7QE8", "QE7_LABOR" })
	aAdd(aMapaCampos, {.T., "N/A"               , "N/A"                 , "QER_ENSAIO"        , "C"  ,                                       0, 0, "QE7QE8", "QE7_ENSAIO"})
	aAdd(aMapaCampos, {.T., "Recno"             , "recno"               , "R_E_C_N_O_"        , "NN" ,                                       0, 0, "QER"}) //NN para não formatar como número pois não temos certeza do tamanho configurado na tabela do cliente
 
    aMapaCampos := Self:oAPIManager:MarcaCamposConsiderados(cCampos, aMapaCampos, nPosCPS_Protheus)

	Self:nCamposQER := Len(aMapaCampos)

Return aMapaCampos

/*/{Protheus.doc} MapeiaCampos
Mapeia os Campos da tabela QES do Protheus - Processo Medições Mensuráveis - Dados Numéricos
@author brunno.costa
@since  23/05/2022
@param 01 - cCampos, String, string com os campos [nPosCPS_Titulo_API] para consideração separados por vírgula
@return aMapaCampos, Array , {{lConsidera, Titulo Interface, Título API, Campo Protheus, Tipo, Tamanho, Decimal}, ...}
                             {{nPosCPS_Considera, ..., nPosCPS_Decimal}, ...}
/*/
METHOD MapeiaCamposQES(cCampos) CLASS ResultadosEnsaiosInspecaoDeEntradasAPI

    Local aMapaCampos := {}

	aAdd(aMapaCampos, {.T., "N/A", "N/A", "QES_CODMED", "C"  ,0, 0, "QER", "QER_CHAVE"})
	aAdd(aMapaCampos, {.T., "N/A", "N/A", "QES_MEDICA", "C"  ,0, 0, "QES" }) //MEDICAO
	aAdd(aMapaCampos, {.T., "N/A", "N/A", "QES_INDMED", "C"  ,0, 0, "QES" }) //SEQUENCIAL MEDICOES ARRAY 1-3 ou vazio acima de 4
 
    aMapaCampos := Self:oAPIManager:MarcaCamposConsiderados(cCampos, aMapaCampos, nPosCPS_Protheus)

Return aMapaCampos

/*/{Protheus.doc} MapeiaCamposQEQ
Mapeia os Campos da tabela QES do Protheus - Valores das Medições (Texto)  
@author brunno.costa
@since  23/06/2022
@param 01 - cCampos, String, string com os campos [nPosCPS_Titulo_API] para consideração separados por vírgula
@return aMapaCampos, Array , {{lConsidera, Titulo Interface, Título API, Campo Protheus, Tipo, Tamanho, Decimal}, ...}
                             {{nPosCPS_Considera, ..., nPosCPS_Decimal}, ...}
/*/
METHOD MapeiaCamposQEQ(cCampos) CLASS ResultadosEnsaiosInspecaoDeEntradasAPI

    Local aMapaCampos := {}

	aAdd(aMapaCampos, {.T., "N/A"               , "N/A"                 , "QEQ_CODMED"        , "C"  ,                                       0, 0, "QER", "QER_CHAVE"})
	aAdd(aMapaCampos, {.F., "TextoDetalhes"     , "textDetail"          , "QEQ_MEDICA"        , "C"  , GetSx3Cache("QEQ_MEDICA" ,"X3_TAMANHO"), 0})
	
	aMapaCampos := Self:oAPIManager:MarcaCamposConsiderados(cCampos, aMapaCampos, nPosCPS_Protheus)

Return aMapaCampos

/*/{Protheus.doc} Salva
Método para Salvar um Registro Recebido via API no DB Protheus
@author brunno.costa
@since  23/05/2022
@param 01 - cJsonData, caracter, string JSON com os dados para interpretação e gravação
@return lSucesso, lógico, indica se o processo foi executado com sucesso
/*/
METHOD Salva(cJsonData, cBlocoForcaErro) CLASS ResultadosEnsaiosInspecaoDeEntradasAPI

	Local aRecnosQER            := {}
	Local bErrorBlock           := Nil
	Local cError                := Nil
	Local lSucesso              := .T.
    Local oDadosJson            := Nil
	Local oQIEEnsaiosCalculados := Nil
	Local oSelf                 := Self

	Default cBlocoForcaErro := ".T."
	
	If !IsInCallStack("QIECASVAPI")
		bErrorBlock := ErrorBlock({|e| lSucesso := .F., cError := e:Description, oSelf:ErrorBlock(e), Break(e)})
		Self:oWSRestFul:SetContentType("application/json")
	EndIf

	oDadosJson  := JsonObject():New() 
	cError := oDadosJson:fromJson(cJsonData)
	If cError == Nil
		Begin Transaction
			Begin Sequence

				&(cBlocoForcaErro)

				lSucesso := !Self:ExisteLaudoRelacionadoAoPost(oDadosJson)
				If !lSucesso
					Self:cErrorMessage            := Self:oAPIManager:cErrorMessage
					Self:cDetailedMessage         := Self:oAPIManager:cDetailedMessage
					If Empty(Self:oAPIManager:cErrorMessage)
						Self:oAPIManager:lWarningError := .T.
						Self:cErrorMessage            := STR0041 //"Operação não permitida! Existe laudo relacionado a esta inspeção."
						Self:cDetailedMessage         := STR0041 //"Operação não permitida! Existe laudo relacionado a esta inspeção."
					EndIf
				EndIf

				If lSucesso
					lSucesso := Self:ProcessaItensRecebidos(@oDadosJson, @aRecnosQER, @Self:cErrorMessage)
				EndIf

				If lSucesso .And. (oDadosJson['responseItems'] == Nil .OR. oDadosJson['responseItems']) .And. !Empty(Self:nRecnoQEK)
					lSucesso := Self:RetornaResultadosInspecao(Self:nRecnoQEK, Nil, aRecnosQER)
				EndIf

				If lSucesso .And. !Empty(Self:nRecnoQEK)
					Self:AtualizaStatusQEKComRecno(Self:nRecnoQEK)
					Self:nAmostraTela := oDadosJson["items"][1]["sampleNumber"]
					Self:nAmostraTela := Iif(Empty(Self:nAmostraTela),2,Self:nAmostraTela)

					If (Self:nRegistros   == 1 .And. Self:lSalvouRegistroNumerico .And. oDadosJson['justCalculated'] == Nil)
						oQIEEnsaiosCalculados := QIEEnsaiosCalculados():New(Self:nRecnoQEK, {})
						oQIEEnsaiosCalculados:PersisteEnsaiosCalculados(oDadosJson["items"][1],Nil , self:nAmostraTela)
					ElseIf (Self:nAmostraTela == 2 .And. oDadosJson['justCalculated'] != Nil .AND. !oDadosJson['justCalculated'])
						oDadosJson['justCalculated'] := "true"
						StartJob("QIECASVAPI", GetEnvServer(), .F., cEmpAnt, cFilAnt, oDadosJson:toJson())
					EndIf

				EndIf

				If !lSucesso .And. Empty(Self:cErrorMessage) .And. Empty(Self:oAPIManager:cErrorMessage)
					cError := Iif(cError == Nil, "", cError)
					//"Não foi possível realizar o processamento."
					//"Ocorreu erro durante a gravação dos dados: "
					Self:cErrorMessage    := STR0003          
					Self:cDetailedMessage := STR0004 + cError 
				EndIf

				If lSucesso .And. Self:oAPIManager:existePEIntegracaoAppMinhaProducaoCompilado("QIE")
					Execblock('QIEINTAPI',.F.,.F.,{oDadosJson, "incominginspectiontestresults/api/qie/v1/save", "ResultadosEnsaiosInspecaoDeEntradasAPI", "complementoResultados"})
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
		If !("QER_CHAVE" $ FWX2Unico('QER')) .And. "duplicate" $ Self:cDetailedMessage
			//STR0064 - "Falha ao inserir resultados nesta Data e Hora, utilize outra data e hora. Nota: Para incluir resultados no mesmo minuto é necessário atualizar dicionário de expedição contínua dos módulos de qualidade."
			Self:cErrorMessage    := STR0064
			Self:cDetailedMessage := ""
		EndIf
		Self:oAPIManager:RespondeValor("result", .F., Self:cErrorMessage, Self:cDetailedMessage)
	EndIf

	FwFreeObj(oDadosJson)

	If !Empty(bErrorBlock)
		ErrorBlock(bErrorBlock)
	EndIf

Return lSucesso

/*/{Protheus.doc} ValidaEnsaioEditavelPorQER
Valida Se é Permitida Alteração/Inclusão/Alteração na QER por posicionamento em registro da QER
@author brunno.costa
@since  10/08/2022
@param 01 - cOperacao, caracter, I = Inclusão, A = Alteração, E = Exclusão 
@return lPermite, lógico, indica se permite editar o ensaio
/*/
METHOD ValidaEnsaioEditavelPorQER(cOperacao) CLASS ResultadosEnsaiosInspecaoDeEntradasAPI

	Local lPermite := .T.
	Local lQReinsp := QieReinsp()

	Default cOperacao := "I"

	If QER->(!Eof())
		lPermite := Self:ValidaEnsaioEditavel(QER->QER_ENSAIO, cOperacao)

		If lPermite
			lPermite := Self:ValidaInexistenciaLaudoLaboratorio(QER->(QER_FORNEC+QER_LOJFOR+QER_PRODUT+QER_NISERI+QER_TIPONF+DTOS(QER_DTENTR)+QER_LOTE+QER_LABOR+Iif(lQReinsp, QER_NUMSEQ, "")), cOperacao)

		EndIf
	EndIf

Return lPermite

/*/{Protheus.doc} ValidaEnsaioEditavelPorRegistro
Valida Se é Permitida Alteração/Inclusão/Alteração na QER por oRegistro da QER
@author brunno.costa
@since  10/08/2022
@param 01 - oRegistro , objeto, retorna por referência os dados para gravação na tabela QER do DB
@param 02 - cOperacao, caracter, I = Inclusão, A = Alteração, E = Exclusão 
@return lPermite, lógico, indica se permite editar o ensaio
/*/
METHOD ValidaEnsaioEditavelPorRegistro(oRegistro, cOperacao) CLASS ResultadosEnsaiosInspecaoDeEntradasAPI

	Local lPermite := .T.

	Default cOperacao := "I"

	lPermite := Self:ValidaEnsaioEditavel(oRegistro["QER_ENSAIO"], cOperacao)

	If lPermite
		lPermite := Self:ValidaInexistenciaLaudoLaboratorio(oRegistro["QER_FORNEC"]+;
                                                            oRegistro["QER_LOJFOR"]+;
                                                            oRegistro["QER_PRODUT"]+;
                                                            oRegistro["QER_NISERI"]+;
															oRegistro["QER_TIPONF"]+;
															DtoS(oRegistro["QER_DTENTR"])+;
															oRegistro["QER_LOTE"  ]+;
															oRegistro["QER_LABOR" ]+;
															oRegistro["QER_NUMSEQ"],;
															cOperacao)
	EndIf

Return lPermite

/*/{Protheus.doc} ValidaInexistenciaLaudoLaboratorio
Valida inexistência do laudo de laboratório na QEL
@author brunno.costa
@since  10/08/2022
@param 01 - cChaveQEL, caracter, chave de posicionamento na QEL
@param 02 - cOperacao, caracter, I = Inclusão, A = Alteração, E = Exclusão 
@return lNaoExiste, lógico, indica se não existe laudo de laboratório
/*/
METHOD ValidaInexistenciaLaudoLaboratorio(cChaveQEL, cOperacao) CLASS ResultadosEnsaiosInspecaoDeEntradasAPI
	
	Local cMessage   := Nil
	Local lNaoExiste := .T.

	Default cOperacao := "I"

	Self:oCacheInexistenciaLaudoLaboratorio := Iif(Self:oCacheInexistenciaLaudoLaboratorio == Nil, JsonObject():New(), Self:oCacheInexistenciaLaudoLaboratorio)

	cMessage := Iif(cOperacao == "I", STR0037, cMessage) //"Falha na Inclusão da Amostra"
	cMessage := Iif(cOperacao == "A", STR0038, cMessage) //"Falha na Alteração da Amostra"
	cMessage := Iif(cOperacao == "E", STR0033, cMessage) //"Falha na Exclusão da Amostra"

	If Self:oCacheInexistenciaLaudoLaboratorio[xFilial("QEL") + cChaveQEL] == Nil
		DbSelectArea("QEL")
		QEL->(DbSetOrder(3)) //QEL_FILIAL+QEL_FORNEC+QEL_LOJFOR+QEL_PRODUT+QEL_NISERI+QEL_TIPONF+DTOS(QEL_DTENTR)+QEL_LOTE+QEL_LABOR+QEL_NUMSEQ
		If QEL->(DbSeek(xFilial("QEL") + cChaveQEL))
			lNaoExiste := Empty(QEL->QEL_LAUDO)
			Self:cErrorMessage    := Iif(lNaoExiste,Self:cErrorMessage, cMessage)
			Self:cDetailedMessage := Iif(lNaoExiste,Self:cDetailedMessage, STR0036) //"Esta inspeção já possui laudo"
		EndIf
		Self:oCacheInexistenciaLaudoLaboratorio[xFilial("QEL") + cChaveQEL] := lNaoExiste
	Else
		lNaoExiste        := Self:oCacheInexistenciaLaudoLaboratorio[xFilial("QEL") + cChaveQEL]
	EndIf

Return lNaoExiste

/*/{Protheus.doc} ValidaEnsaioEditavel
Valida Se é Permitida Alteração/Inclusão/Alteração para este Ensaio
@author brunno.costa
@since  10/08/2022
@param 01 - nRecnoQER, número  , RECNO do registro da amostra na tabela QER
@param 02 - cOperacao, caracter, I = Inclusão, A = Alteração, E = Exclusão 
@return lPermite, lógico, indica se permite editar o ensaio
/*/
METHOD ValidaEnsaioEditavel(cEnsaio, cOperacao) CLASS ResultadosEnsaiosInspecaoDeEntradasAPI
	
	
	Local cMessage := Nil
	Local lPermite := .T.

	Default cOperacao := "I"

	cMessage := Iif(cOperacao == "I", STR0037, cMessage) //"Falha na Inclusão da Amostra"
	cMessage := Iif(cOperacao == "A", STR0038, cMessage) //"Falha na Alteração da Amostra"
	cMessage := Iif(cOperacao == "E", STR0033, cMessage) //"Falha na Exclusão da Amostra"

	/*
	//TODO
	DbSelectArea("QE1")
	QE1->(DbSetOrder(1))
	If QE1->(DbSeek(xFilial("QE1") + cEnsaio))
		lPermite := QE1->QE1_TIPO=="2"
		Self:cErrorMessage    := Iif(lPermite,Self:cErrorMessage, cMessage)
		Self:cDetailedMessage := Iif(QE1->QE1_TIPO=="2",Iif(QE1->QE1_CARTA!="TMP",Self:cDetailedMessage, STR0034), STR0035) //"A carta deste ensaio é TMP" + "Este ensaio é calculado"
	EndIf
	*/

Return lPermite

/*/{Protheus.doc} DeletaAmostraSemResponse
Método para Deletar uma Amostra via API no DB Protheus
@author brunno.costa
@since  10/08/2022
@param 01 - nRecnoQER, número  , RECNO do registro da amostra na tabela QER
@param 02 - cChaveQEK, caracter, retorna por referência a chave do registro na QEK
@return lSucesso, lógico, indica se o processo foi executado com sucesso
/*/
METHOD DeletaAmostraSemResponse(nRecnoQER, cChaveQEK, cBlocoForcaErro) CLASS ResultadosEnsaiosInspecaoDeEntradasAPI

	Local bErrorBlock := Nil
	Local cChaveQER   := Nil
	Local cError      := Nil
	Local lQReinsp    := QieReinsp()
	Local lSucesso    := .T.
    Local oDadosJson  := Nil
	Local oSelf       := Self

	Default cChaveQEK := ""
	Default cBlocoForcaErro := ".T."
	
	bErrorBlock := ErrorBlock({|e| lSucesso := .F., cError := e:Description, oSelf:ErrorBlock(e), Break(e)})

	Begin Transaction
		Begin Sequence

			&(cBlocoForcaErro)

			DbSelectArea("QER")
			QER->(DbGoTo(nRecnoQER))
			If QER->(!Eof())
				cChaveQER := QER->QER_CHAVE

				lSucesso := Self:ValidaEnsaioEditavelPorQER("E")

				If lSucesso
					DbSelectArea("QEQ")
					QEQ->(DbSetOrder(1))
					If QEQ->(DbSeek(xFilial("QEQ") + cChaveQER))
						While lSucesso .AND. xFilial("QEQ") + cChaveQER == QEQ->(QEQ_FILIAL+QEQ_CODMED)
							RecLock("QEQ", .F.)
							QEQ->(DbDelete())
							QEQ->(MsUnLock())
							QEQ->(DBSkip())
						EndDo
					EndIf

					DbSelectArea("QES")
					QES->(DbSetOrder(1))
					If lSucesso .AND. QES->(DbSeek(xFilial("QES") + cChaveQER))
						While lSucesso .AND. xFilial("QES") + cChaveQER == QES->(QES_FILIAL+QES_CODMED)
							RecLock("QES", .F.)
							QES->(DbDelete())
							QES->(MsUnLock())
							Self:lExcluiuRegistroNumerico := Iif(!Self:lExcluiuRegistroNumerico, lSucesso, .T.)
							QES->(DBSkip())
						EndDo
					EndIf

					cChaveQEK := QER->(QER_FORNEC+QER_LOJFOR+QER_NTFISC+QER_SERINF+QER_ITEMNF+QER_TIPONF+QER_LOTE) + Iif(lQReinsp, QER->QER_NUMSEQ, "")

					lQLTExAAmIn := Iif(lQLTExAAmIn == Nil, FindFunction("QLTExAAmIn"), lQLTExAAmIn)
					If lQLTExAAmIn
						StartJob("QLTExAAmIn", GetEnvServer(), .F., cEmpAnt, cFilAnt, QER->QER_FILIAL, QER->QER_CHAVE, "QIE")
					EndIf
					RecLock("QER", .F.)
					QER->(DbDelete())
					QER->(MsUnLock())
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
@param 01 - nRecnoQER, número  , RECNO do registro da amostra na tabela QER
@param 02 - cUsuario , caracter, indica o usuário que realizou a exclusão
@return lSucesso, lógico, indica se o processo foi executado com sucesso
/*/
METHOD DeletaAmostra(nRecnoQER, cUsuario, cBlocoForcaErro) CLASS ResultadosEnsaiosInspecaoDeEntradasAPI

	Local aNCsVinculadas             := {}
	Local cChaveQEK                  := ""
	Local cResp                      := Nil
	Local lSucesso                   := .T.
	Local nControle                  := 0
	Local nRecnoQEK                  := Nil
	Local oFichasNaoConformidadesAPI := FichasNaoConformidadesAPI():New()
	Local oQIEEnsaiosCalculados      := Nil
	Local oResponse                  := JsonObject()               :New()

	Self:oWSRestFul:SetContentType("application/json")

	//Força passagem por MATXALC para popular variável Static cRetCodUsr - DMANQUALI-9983 - DBRUnlock cannot be called in a transaction
	//Trecho fora de transação, tratamento complementar AtualizaFlagLegendaInspecao
	PCPDocUser(RetCodUsr(cUsuario))
	Self:cLogin := cUsuario

	If lSucesso := Self:DeletaAmostraSemResponse(nRecnoQER, @cChaveQEK, cBlocoForcaErro)

		aNCsVinculadas := oFichasNaoConformidadesAPI:retornaNCsDaInspecaoDeEntrada(nRecnoQER)
		
		For nControle := 1 to Len(aNCsVinculadas)

			oFichasNaoConformidadesAPI:excluiRelacionamentoNCQIE(nRecnoQER, aNCsVinculadas[nControle],,.F.)
		
		Next nControle 

		Self:ExcluiInstrumentosRelacionadosAmostra(nRecnoQER)

	Endif

	If lSucesso
		Self:AtualizaStatusQEKComChaveQEK(cChaveQEK)
		If Self:lExcluiuRegistroNumerico
			QEK->(DbSetOrder(11))
			If QEK->(DbSeek(xFilial("QEK")+cChaveQEK))
				nRecnoQEK := QEK->(Recno())
				oQIEEnsaiosCalculados := QIEEnsaiosCalculados():New(nRecnoQEK, {})
				oQIEEnsaiosCalculados:ExcluiMedicoesCalculadas(cUsuario)
			EndIf
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

/*/{Protheus.doc} SalvaRegistroNumerico
Método para Salvar um Registro NUMÉRICO Recebido via API no DB Protheus
@author brunno.costa
@since  23/05/2022
@param 01 - oItemAPI  , objeto, objeto Json com UM ITEM DOS REGISTROS JSON recebidos da API para conversão
@return lSucesso, lógico, indica se o processo foi executado com sucesso
/*/
METHOD SalvaRegistroNumerico(oItemAPI) CLASS ResultadosEnsaiosInspecaoDeEntradasAPI
	
	Local lSucesso   := .T.
	Local oDadosQES  := JsonObject():New()

	If lSucesso
		oDadosQES                    := Self:PreparaDadosQES(oItemAPI, @oDadosQES)
		lSucesso                     := Self:SalvaRegistroQESSequencialmente(oDadosQES)
		Self:lSalvouRegistroNumerico := Iif(!Self:lSalvouRegistroNumerico, lSucesso, .T.)
	EndIf

	FwFreeObj(oDadosQES)

Return lSucesso


/*/{Protheus.doc} SalvaRegistroTexto
Método para Salvar um Registro TEXTO Recebido via API no DB Protheus
@author brunno.costa
@since  23/06/2022
@param 01 - oItemAPI  , objeto, objeto Json com UM ITEM DOS REGISTROS JSON recebidos da API para conversão
@return lSucesso, lógico, indica se o processo foi executado com sucesso
/*/
METHOD SalvaRegistroTexto(oItemAPI) CLASS ResultadosEnsaiosInspecaoDeEntradasAPI
	Local cCpsErro  := ""
	Local lSucesso  := .T.
	Local oRegistro := Nil

	oRegistro := Self:PreparaDadosQEQ(oItemAPI)
	lSucesso  := Self:oAPIManager:ValidaCamposObrigatorios(oRegistro, "|QEQ_CODMED|QEQ_MEDICA|", @cCpsErro)
	If lSucesso
		Self:oAPIManager:SalvaRegistroDB("QEQ", @oRegistro, Self:aCamposQEQ)
	Else
		//"Dados para Integração Inválidos"
		//"Campo(s) obrigatório(s) inválido(s)"
		Self:cErrorMessage    := STR0008
		Self:cDetailedMessage := STR0020 + " '" + AllTrim(cCpsErro) + "': " + oRegistro:toJson()
	EndIf

	FwFreeObj(oRegistro)
Return lSucesso

/*/{Protheus.doc} PreparaDadosQEQ
Prepara os Dados Recebidos para Gravação na tabela QEQ
@author brunno.costa
@since  23/06/2022
@param 01 - oItemAPI  , objeto, objeto Json com UM ITEM DOS REGISTROS JSON recebidos da API para conversão
@return oRegistro, objeto, retorna os dados para gravação na tabela QEQ do DB
/*/
METHOD PreparaDadosQEQ(oItemAPI) CLASS ResultadosEnsaiosInspecaoDeEntradasAPI
	
	Local oRegistro     := Nil

	If Self:aCamposQEQ  == Nil
		Self:aCamposQEQ := Self:MapeiaCamposQEQ("*")
	EndIf

	oRegistro               := Self:oAPIManager:InicializaCamposPadroes("QEQ",,.T.)
	oRegistro["QEQ_CODMED"] := oItemAPI["QER_CHAVE"]
	oRegistro["QEQ_MEDICA"] := oItemAPI["textDetail"]

	QEQ->(DbSetOrder(1))
	If QEQ->(DbSeek(xFilial("QEQ")+oRegistro["QEQ_CODMED"]))
		oRegistro['R_E_C_N_O_'] := QEQ->(Recno())
	EndIf

Return oRegistro

/*/{Protheus.doc} RetornaResultadosInspecao
Retorna a Lista de Resultados da Inspeção nRecnoQEK
@author brunno.costa
@since  23/05/2022
@param 01 - nRecnoQEK , numérico, número do recno da inspeção na QEK
@param 02 - cOrdem    , caracter, ordem para retorno dos resultados do banco
@param 03 - aRecnosQER, array   , NIL e Vazio para retornar todos ou array com os RECNOS da QER para receber na resposta do POST
@param 04 - nPagina   , numérico, página atual dos dados para consulta
@param 05 - nTamPag   , numérico, tamanho de página padrão com a quantidade de registros para retornar
@param 06 - cCampos   , caracter, campos que deverão estar contidos na mensagem
@param 07 - lMedicao  , lógico  , retorna por referência indicando se existem Medições relacionadas
@return lSucesso, lógico, indica se o processo foi executado com sucesso
/*/
METHOD RetornaResultadosInspecao(nRecnoQEK, cOrdem, aRecnosQER, nPagina, nTamPag, cCampos, lMedicao) CLASS ResultadosEnsaiosInspecaoDeEntradasAPI
	
	Local cAlias      := Nil
	Local cFIlQAA     := xFilial("QAA")
	Local cFilQE7     := xFilial("QE7")
	Local cFilQE8     := xFilial("QE8")
	Local cFilQEQ     := xFilial("QEQ")
	Local cFIlQER     := xFilial("QER")
	Local cFIlQES     := xFilial("QES")
	Local cINRecQER   := ""
	Local cOrdemDB    := Nil
    Local cQuery      := ""
	Local lSucesso    := .T.
    Local oAPIManager := QualityAPIManager():New(Self:MapeiaCamposAPI(cCampos), Self:oWSRestFul)
	Local oExec		  := Nil

	Default cOrdem   := "measurementDate,measurementTime"
	Default nPagina  := 1
	Default nTamPag  := 99
	Default lMedicao := .F.

	nRecnoQEK := Iif(ValType(nRecnoQEK)=="C", Val(nRecnoQEK), nRecnoQEK)
	nRecnoQEK := Iif(ValType(nRecnoQEK)!="N", -1            , nRecnoQEK)

	//cQuery +=  " /*INICIO MONTAGEM QUERY RECURSIVA*/ "
	cQuery +=  " WITH Query_Recursiva (Recursao, QES_CODMED, QES_MEDICA, Recno) "
	cQuery +=  " AS "
	cQuery +=  " ( "
	//cQuery +=      " /*INICIO 1 ANCORA DA RECURSIVIDADE*/ "
	cQuery +=      " SELECT 1 As Recursao, "
	cQuery +=              " QES_CODMED, "
	cQuery +=              "CONCAT(CONCAT('" + '"' + "', Cast(QES_MEDICA as VarChar(8000)) ),'" + '"' + "')" + " MEDICAO, "
	cQuery +=              " R_E_C_N_O_ Recno "
	cQuery +=      " FROM " + RetSQLName("QES") + " QES "
	cQuery +=      " INNER JOIN "
	cQuery +=          " (SELECT QER_FORNEC, QER_LOJFOR, QER_PRODUT, QER_NISERI, QER_TIPONF, QER_LOTE, QER_NUMSEQ, QER_DTENTR, QER_CHAVE, QER_AMOSTR  "
	cQuery +=           " FROM " + RetSQLName("QER")
	cQuery +=           " WHERE   (D_E_L_E_T_ = ' ') "
	cQuery +=               " AND (QER_FILIAL = '" + cFilQER + "')) "
	cQuery +=          " QER  "
	cQuery +=      " ON QER.QER_CHAVE = QES_CODMED "

	cQuery +=      " INNER JOIN "
	cQuery +=          " (SELECT QEK_FORNEC, QEK_LOJFOR, QEK_PRODUT, QEK_REVI, QEK_NTFISC, QEK_SERINF, QEK_ITEMNF, QEK_TIPONF, QEK_LOTE, QEK_NUMSEQ, QEK_DTENTR "
	cQuery +=              " FROM " + RetSQLName("QEK")
	cQuery +=              " WHERE (D_E_L_E_T_ = ' ') "
	cQuery +=              " AND (R_E_C_N_O_ = " + cValToChar(nRecnoQEK) + ")) "
	cQuery +=          " QEK  "
	cQuery += " ON " + Self:oQueryManager:MontaRelationArraysCampos("QEK", {"QEK_FORNEC","QEK_LOJFOR","QEK_PRODUT","QEK_NTFISC+QEK_SERINF+QEK_ITEMNF","QEK_TIPONF","QEK_LOTE","QEK_DTENTR"},;
																	"QER", {"QER_FORNEC","QER_LOJFOR","QER_PRODUT","QER_NISERI"                      ,"QER_TIPONF","QER_LOTE","QER_DTENTR"})
	
	If QIEReinsp()
		cQuery += " AND QEK.QEK_NUMSEQ = QER.QER_NUMSEQ "
	EndIf

	cQuery +=      " WHERE   QES.D_E_L_E_T_ = ' ' "
	cQuery +=          " AND QES.QES_FILIAL = '" + cFilQES + "' "
	//cQuery +=      " /*FIM 1 ANCORA DA RECURSIVIDADE*/ "
	cQuery +=      " UNION ALL "
	//cQuery +=      " /*INICIO RECURSIVIDADE*/ "
	cQuery +=      " SELECT  "
	cQuery +=          " Recursao + 1 as Recursao, "
	cQuery +=          " REC.QES_CODMED, "
	cQuery +=          " CONCAT(CONCAT(CONCAT(REC.QES_MEDICA , '," + '"' + "' ), QES.QES_MEDICA ), '" + '"' + "') AS MEDICAO, "
	cQuery +=          " QES.Recno "
	cQuery +=      " FROM Query_Recursiva REC "
	cQuery +=      " INNER JOIN "
	cQuery +=          " (SELECT QES_CODMED, QES_MEDICA, R_E_C_N_O_ Recno "
	cQuery +=           " FROM " + RetSQLName("QES")
	cQuery +=           " WHERE   D_E_L_E_T_ = ' ' "
	cQuery +=              " AND  QES_FILIAL = '" + cFilQES + "') QES "
	cQuery +=      " ON      QES.Recno > REC.Recno  "
	cQuery +=          " AND QES.QES_CODMED = REC.QES_CODMED "
	//cQuery +=      " /*FIM RECURSIVIDADE*/ "
	cQuery +=   " ) "
	
	//cQuery +=   " /*FIM MONTAGEM QUERY RECURSIVA*/ "
	cQuery +=  " SELECT RECNOQEK, "
	cQuery +=  		  " RECNOTEST, "
	cQuery += 		  " QER_DTMEDI, "
	cQuery += 		  " QER_HRMEDI, "
	cQuery += 		  " QER_ENSR, "
	cQuery += 		  " TIPO, "
	cQuery += 		  " CONCAT(CONCAT('[' , RTRIM(QES_MEDICA)) , ']') AS MEDICOES, "
	cQuery += 		  " QER_RESULT, "
	cQuery += 		  " QEQ_MEDICA, "
	cQuery += 		  " QAA_LOGIN, "
	cQuery += 		  " QAA_NOME, "
	cQuery += 		  " QER_ENSAIO, "
	cQuery += 		  " RECNOQER, "
	cQuery += 		  " QER_AMOSTR, "

	If Self:lTemQQM
		cQuery += 		  " COALESCE(TEMANEXO,'F') TEMANEXO "
	Else
		cQuery += 		  " 'F' TEMANEXO "
	EndIf

	cQuery +=  " FROM Query_Recursiva  "
	cQuery +=  " INNER JOIN "
	cQuery +=      " (SELECT QES_CODMED, Count(*) MAXRECURSAO "
	cQuery +=       " FROM " + RetSQLName("QES")
	cQuery +=       " INNER JOIN "
	cQuery +=          " (SELECT QER_FORNEC, QER_LOJFOR, QER_PRODUT, QER_NISERI, QER_TIPONF, QER_LOTE, QER_NUMSEQ, QER_DTENTR, QER_CHAVE, QER_AMOSTR  "
	cQuery +=          " FROM " + RetSQLName("QER")
	cQuery +=          " WHERE (D_E_L_E_T_ = ' ') "
	cQuery +=              " AND (QER_FILIAL = '" + cFilQER + "')) "
	cQuery +=          " QER  "
	cQuery +=       " ON QER.QER_CHAVE = QES_CODMED "

	cQuery +=       " INNER JOIN "
	cQuery +=          " (SELECT QEK_FORNEC, QEK_LOJFOR, QEK_PRODUT, QEK_REVI, QEK_NTFISC, QEK_SERINF, QEK_ITEMNF, QEK_TIPONF, QEK_LOTE, QEK_NUMSEQ, QEK_DTENTR "
	cQuery +=          " FROM " + RetSQLName("QEK")
	cQuery +=          " WHERE   (D_E_L_E_T_ = ' ') "
	cQuery +=              " AND (R_E_C_N_O_ = " + cValToChar(nRecnoQEK) + " )) "
	cQuery +=          " QEK  "
	cQuery +=          " ON " + Self:oQueryManager:MontaRelationArraysCampos("QEK", {"QEK_FORNEC","QEK_LOJFOR","QEK_PRODUT","QEK_NTFISC+QEK_SERINF+QEK_ITEMNF","QEK_TIPONF","QEK_LOTE","QEK_DTENTR"},;
			                                                                 "QER", {"QER_FORNEC","QER_LOJFOR","QER_PRODUT","QER_NISERI"                      ,"QER_TIPONF","QER_LOTE","QER_DTENTR"})

	If QIEReinsp()
		cQuery += " AND QEK.QEK_NUMSEQ = QER.QER_NUMSEQ "
	EndIf

	cQuery +=       " WHERE  D_E_L_E_T_ = ' ' "
	cQuery +=          " AND QES_FILIAL = '" + cFilQES + "' "
	cQuery +=       " GROUP BY QES_CODMED) "
	cQuery +=       " QUERYMAXRECURSAO "
	cQuery +=  " ON    Query_Recursiva.QES_CODMED = QUERYMAXRECURSAO.QES_CODMED "
	cQuery +=      " AND Query_Recursiva.Recursao = QUERYMAXRECURSAO.MAXRECURSAO "
	cQuery +=  " INNER JOIN     "
	cQuery +=      " (    SELECT  "
	cQuery +=              " '' AS QEQ_MEDICA, "
	cQuery +=              " 'N' AS TIPO, "
	cQuery +=              " QER.QER_DTMEDI, "
	cQuery +=              " QER.QER_HRMEDI, "
	cQuery +=              " QER.QER_ENSR, "
	cQuery +=              " QER.QER_RESULT, "
	cQuery +=              " QEK.R_E_C_N_O_ RECNOQEK, "
	cQuery +=              " QER.R_E_C_N_O_ RECNOQER, "
	cQuery +=              " QAA.QAA_LOGIN, "
	cQuery +=              " QAA.QAA_NOME, "
	cQuery +=              " QER.QER_ENSAIO, "
	cQuery +=              " QE7.R_E_C_N_O_ RECNOTEST, "
	cQuery +=              " QER_CHAVE, "
	cQuery +=              " QER.QER_AMOSTR, "
	cQuery +=              " QER.QER_FILIAL "
	cQuery +=          " FROM            "
	cQuery +=                  " (SELECT QER_FORNEC, QER_LOJFOR, QER_PRODUT, QER_REVI , QER_NISERI, QER_TIPONF, QER_LOTE, QER_NUMSEQ, QER_DTENTR, QER_CHAVE, "
	cQuery +=                          " QER_AMOSTR, QER_FILIAL, QER_ENSAIO, QER_LABOR, R_E_C_N_O_, QER_RESULT, QER_ENSR, QER_HRMEDI, QER_DTMEDI "
	cQuery +=                  " FROM " + RetSQLName("QER")
	cQuery +=                  " WHERE (D_E_L_E_T_ = ' ') "
	cQuery +=                      " AND (QER_FILIAL = '" + cFilQER + "')) "
	cQuery +=                  " QER  "

	cQuery +=              " INNER JOIN "
	cQuery +=                  " (SELECT QEK_FORNEC, QEK_LOJFOR, QEK_PRODUT, QEK_REVI, QEK_NTFISC, QEK_SERINF, QEK_ITEMNF, QEK_TIPONF, QEK_LOTE, QEK_NUMSEQ, QEK_DTENTR, R_E_C_N_O_ "
	cQuery +=                  " FROM " + RetSQLName("QEK")
	cQuery +=                  " WHERE (D_E_L_E_T_ = ' ') "
	cQuery +=                      " AND (R_E_C_N_O_ = " + cValToChar(nRecnoQEK) + ")) "
	cQuery +=                  " QEK  "
	cQuery +=                  " ON " + Self:oQueryManager:MontaRelationArraysCampos("QEK", {"QEK_FORNEC","QEK_LOJFOR","QEK_PRODUT","QEK_NTFISC+QEK_SERINF+QEK_ITEMNF","QEK_TIPONF","QEK_LOTE","QEK_DTENTR"},;
			                                                                         "QER", {"QER_FORNEC","QER_LOJFOR","QER_PRODUT","QER_NISERI"                      ,"QER_TIPONF","QER_LOTE","QER_DTENTR"})

	If QIEReinsp()
		cQuery += " AND QEK.QEK_NUMSEQ = QER.QER_NUMSEQ "
	EndIf

	cQuery +=              " INNER JOIN "
	cQuery +=                  " (SELECT QAA_LOGIN, QAA_MAT, QAA_NOME "
	cQuery +=                   " FROM " + RetSQLName("QAA")
	cQuery +=                  " WHERE D_E_L_E_T_=' ' "
	cQuery +=                      " AND QAA_FILIAL='" + cFilQAA + "') "
	cQuery +=                  " QAA "
	cQuery +=              " ON QAA.QAA_MAT = QER.QER_ENSR "
	cQuery +=              " INNER JOIN "
	cQuery +=                  " (SELECT QE7_PRODUT, QE7_REVI, QE7_ENSAIO, QE7_LABOR, R_E_C_N_O_ "
	cQuery +=                   " FROM " + RetSQLName("QE7")
	cQuery +=                   " WHERE D_E_L_E_T_  = ' ' "
	cQuery +=                      " AND QE7_FILIAL = '" + cFilQE7 + "') "
	cQuery +=              " QE7 "
	cQuery +=              " ON QE7.QE7_PRODUT   = QER.QER_PRODUT  "
	cQuery +=               " AND QE7.QE7_REVI   = QER.QER_REVI "
	cQuery +=               " AND QE7.QE7_LABOR  = QER.QER_LABOR "
	cQuery +=               " AND QE7.QE7_ENSAIO = QER.QER_ENSAIO "
	cQuery +=      " ) NAORECURSIVA  "
	cQuery +=  " ON NAORECURSIVA.QER_CHAVE = Query_Recursiva.QES_CODMED "

	If Self:lTemQQM
		cQuery += 		 " LEFT OUTER JOIN "
		cQuery += 		  " (SELECT DISTINCT 'T' TEMANEXO, "
		cQuery += 		 		   " QQM_FILQPR,  "
		cQuery += 				   " QQM_CHAVE "
		cQuery += 		  " FROM " + RetSqlName("QQM")
		cQuery +=					" WHERE D_E_L_E_T_ = ' ' ) QQM ON QER_CHAVE  = QQM.QQM_CHAVE "
		cQuery += 												" AND QER_FILIAL = QQM_FILQPR "
	EndIf
	
	If aRecnosQER != Nil .And. !Empty(aRecnosQER)
		cINRecQER := FormatIn(ArrToKStr(aRecnosQER),"|")
		cQuery    += "WHERE RECNOQER IN " + cINRecQER
	EndIf

	cQuery +=  " UNION "

	//RESULTADO DE TEXTO
	cQuery += " SELECT   "
	cQuery +=     " QEK.R_E_C_N_O_ RECNOQEK, "
	cQuery +=     " QE8.R_E_C_N_O_ RECNOTEST, "
	cQuery +=     " QER.QER_DTMEDI, "
	cQuery +=     " QER.QER_HRMEDI, "
	cQuery +=     " QER.QER_ENSR, "
	cQuery +=     " 'T' AS TIPO, "
	cQuery +=     " '[]' AS MEDICOES, "
	cQuery +=     " QER.QER_RESULT, "
	cQuery +=     " QEQ_MEDICA, "
	cQuery +=     " QAA.QAA_LOGIN, "
	cQuery +=     " QAA.QAA_NOME, "
	cQuery +=     " QER.QER_ENSAIO, "
	cQuery +=     " QER.R_E_C_N_O_ RECNOQER, "
	cQuery +=     " QER.QER_AMOSTR, "
	If Self:lTemQQM
		cQuery +=     " COALESCE(TEMANEXO,'F') TEMANEXO "
	Else
		cQuery +=     " 'F' TEMANEXO "
	EndIf
	cQuery += " FROM "
	cQuery +=           "(SELECT QER_FORNEC, QER_LOJFOR, QER_PRODUT, QER_REVI , QER_NISERI, QER_TIPONF, QER_LOTE, QER_NUMSEQ, QER_DTENTR, QER_CHAVE, "
	cQuery +=                  " QER_AMOSTR, QER_FILIAL, QER_ENSAIO, QER_LABOR, R_E_C_N_O_, QER_RESULT, QER_ENSR, QER_HRMEDI, QER_DTMEDI "
	cQuery +=         " FROM " + RetSQLName("QER")
	cQuery +=         " WHERE (D_E_L_E_T_ = ' ') "
	cQuery +=             " AND (QER_FILIAL = '" + cFilQER + "')) "
	cQuery +=         " QER "

	If Self:lTemQQM
		cQuery += 		 " LEFT OUTER JOIN "
		cQuery += 		  " (SELECT DISTINCT 'T' TEMANEXO, "
		cQuery += 		 		   " QQM_FILQPR,  "
		cQuery += 				   " QQM_CHAVE "
		cQuery += 		  " FROM " + RetSqlName("QQM")
		cQuery +=					" WHERE D_E_L_E_T_ = ' ' ) QQM ON QER_CHAVE  = QQM.QQM_CHAVE "
		cQuery += 												" AND QER_FILIAL = QQM_FILQPR "
	EndIf

	cQuery +=     " INNER JOIN "
	cQuery +=         " (SELECT QEK_FORNEC, QEK_LOJFOR, QEK_PRODUT, QEK_REVI, QEK_NTFISC, QEK_SERINF, QEK_ITEMNF, QEK_TIPONF, QEK_LOTE, QEK_NUMSEQ, QEK_DTENTR, R_E_C_N_O_ "
	cQuery +=         " FROM " + RetSQLName("QEK")
	cQuery +=         " WHERE (D_E_L_E_T_ = ' ') "
	cQuery +=             " AND (R_E_C_N_O_ =  " + cValToChar(nRecnoQEK) + " )) "
	cQuery +=         " QEK "
	cQuery +=         " ON " + Self:oQueryManager:MontaRelationArraysCampos("QEK", {"QEK_FORNEC","QEK_LOJFOR","QEK_PRODUT","QEK_NTFISC+QEK_SERINF+QEK_ITEMNF","QEK_TIPONF","QEK_LOTE","QEK_DTENTR"},;
			                                                                "QER", {"QER_FORNEC","QER_LOJFOR","QER_PRODUT","QER_NISERI"                      ,"QER_TIPONF","QER_LOTE","QER_DTENTR"})
	
	If QIEReinsp()
		cQuery += " AND QEK.QEK_NUMSEQ = QER.QER_NUMSEQ "
	EndIf

	cQuery +=     " INNER JOIN "
	cQuery +=         " (SELECT QAA_LOGIN, QAA_MAT, QAA_NOME "
	cQuery +=         " FROM " + RetSQLName("QAA")
	cQuery +=         " WHERE D_E_L_E_T_=' ' "
	cQuery +=             " AND QAA_FILIAL='" + cFilQAA + "') "
	cQuery +=         " QAA "
	cQuery +=     " ON QAA.QAA_MAT = QER.QER_ENSR "
	cQuery +=     " INNER JOIN "
	cQuery +=         " (SELECT QE8_PRODUT, QE8_REVI, QE8_ENSAIO, QE8_LABOR, R_E_C_N_O_ "
	cQuery +=         " FROM " + RetSQLName("QE8")
	cQuery +=         " WHERE D_E_L_E_T_  = ' ' "
	cQuery +=             " AND QE8_FILIAL = '" + cFilQE8 + "') "
	cQuery +=     " QE8 "
	cQuery +=     " ON QE8.QE8_PRODUT   = QER.QER_PRODUT "
	cQuery +=      " AND QE8.QE8_REVI   = QER.QER_REVI "
	cQuery +=      " AND QE8.QE8_LABOR  = QER.QER_LABOR "
	cQuery +=      " AND QE8.QE8_ENSAIO = QER.QER_ENSAIO "

	cQuery += 	" INNER JOIN "
	cQuery +=     " (SELECT QEQ_CODMED, QEQ_MEDICA "
	cQuery +=  	  " FROM " + RetSQLName("QEQ")
	cQuery +=  	  " WHERE (D_E_L_E_T_ = ' ') "
	cQuery +=         " AND QEQ_FILIAL = '" + cFilQEQ + "') "
	cQuery +=     " QEQ "
	cQuery +=     " ON QEQ.QEQ_CODMED = QER.QER_CHAVE "

	If aRecnosQER != Nil .And. !Empty(aRecnosQER)
		cQuery    += "WHERE QER.R_E_C_N_O_ IN " + cINRecQER
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
Retorna a Lista de Resultados da Inspeção nRecnoQEK
@author brunno.costa
@since  23/05/2022
@param 01 - nRecnoQEK , numérico, número do recno da inspeção na QEK
@param 02 - cOrdem    , caracter, ordem para retorno dos resultados do banco
@param 03 - cIDTest   , caracter, ID do ensaio relacionado
@param 05 - nPagina   , numérico, página atual dos dados para consulta
@param 06 - nTamPag   , numérico, tamanho de página padrão com a quantidade de registros para retornar
@param 07 - cCampos   , caracter, campos que deverão estar contidos na mensagem
@return lSucesso, lógico, indica se o processo foi executado com sucesso
/*/
METHOD RetornaResultadosInspecaoPorEnsaio(nRecnoQEK, cOrdem, cIDTest, nPagina, nTamPag, cCampos) CLASS ResultadosEnsaiosInspecaoDeEntradasAPI
	
	Local cAlias      := Nil
	Local lSucesso    := .T.
    Local oAPIManager := QualityAPIManager():New(Self:MapeiaCamposAPI(cCampos), Self:oWSRestFul)

	Default cOrdem  := "measurementDate,measurementTime"
	Default nPagina := 1
	Default nTamPag := 99

	If (lSucesso := Self:CriaAliasResultadosInspecaoPorEnsaio(nRecnoQEK, cOrdem, cIDTest, nPagina, nTamPag, cCampos, @cAlias, oAPIManager))
    	lSucesso := oAPIManager:ProcessaListaResultados(cAlias, nPagina, nTamPag)
	EndIf

    (cAlias)->(dbCloseArea())

Return lSucesso

/*/{Protheus.doc} CriaAliasResultadosInspecao
Cria Alias para Retornar a Lista de Resultados da Inspeção nRecnoQEK
@author brunno.costa
@since  23/05/2022
@param 01 - nRecnoQEK  , numérico, número do recno da inspeção na QEK
@param 02 - cOrdem     , caracter, ordem para retorno dos resultados do banco
@param 03 - cIDTest    , caracter, ID do ensaio relacionado
@param 05 - nPagina    , numérico, página atual dos dados para consulta
@param 06 - nTamPag    , numérico, tamanho de página padrão com a quantidade de registros para retornar
@param 07 - cCampos    , caracter, campos que deverão estar contidos na mensagem
@param 08 - cAlias     , caracter, retorna por referencia alias criado
@param 09 - oAPIManager, objeto  , instancia da classe QualityAPIManager
@return lSucesso, lógico, indica se o processo foi executado com sucesso
/*/
METHOD CriaAliasResultadosInspecaoPorEnsaio(nRecnoQEK, cOrdem, cIDTest, nPagina, nTamPag, cCampos, cAlias, oAPIManager) CLASS ResultadosEnsaiosInspecaoDeEntradasAPI
	
	Local aBindParam := {}
	Local cFIlQAA    := xFilial("QAA")
	Local cFilQE7    := xFilial("QE7")
	Local cFilQE8    := xFilial("QE8")
	Local cFilQEQ    := xFilial("QEQ")
	Local cFIlQER    := xFilial("QER")
	Local cFIlQES    := xFilial("QES")
	Local cOrdemDB   := Nil
    Local cQuery     := ""
	Local lSucesso   := .T.

	Default cOrdem      := "measurementDate,measurementTime"
	Default nPagina     := 1
	Default nTamPag     := 99
    Default oAPIManager := QualityAPIManager():New(Self:MapeiaCamposAPI(cCampos), Self:oWSRestFul)

	nRecnoQEK := Iif(ValType(nRecnoQEK)=="C", Val(nRecnoQEK), nRecnoQEK)
	nRecnoQEK := Iif(ValType(nRecnoQEK)!="N", -1            , nRecnoQEK)

	//cQuery +=  " /*INICIO MONTAGEM QUERY RECURSIVA*/ "
	cQuery +=  " WITH Query_Recursiva (Recursao, QES_CODMED, QES_MEDICA, Recno) "
	cQuery +=  " AS "
	cQuery +=  " ( "
	//cQuery +=      " /*INICIO 1 ANCORA DA RECURSIVIDADE*/ "
	cQuery +=      " SELECT 1 As Recursao, "
	cQuery +=              " QES_CODMED, "
	cQuery +=              "CONCAT(CONCAT('" + '"' + "', Cast(QES_MEDICA as VarChar(8000))) ,'" + '"' + "')" + " MEDICAO, "
	cQuery +=              " R_E_C_N_O_ Recno "
	cQuery +=      " FROM " + RetSQLName("QES") + " QES "
	cQuery +=      " INNER JOIN "
	cQuery +=          " (SELECT QER_FORNEC, QER_LOJFOR, QER_PRODUT, QER_NISERI, QER_TIPONF, QER_LOTE, QER_NUMSEQ, QER_DTENTR, QER_CHAVE, QER_AMOSTR  "
	cQuery +=           " FROM " + RetSQLName("QER")

	cQuery +=           " WHERE   (QER_FILIAL = ?) "
	cQuery +=               " AND (D_E_L_E_T_ = ?)) "
	aAdd(aBindParam, {cFilQER, "S"})
	aAdd(aBindParam, {" "    , "S"})

	cQuery +=          " QER  "
	cQuery +=      " ON QER.QER_CHAVE = QES_CODMED "

	cQuery +=      " INNER JOIN "
	cQuery +=        "(SELECT QEK_FORNEC, QEK_LOJFOR, QEK_PRODUT, QEK_REVI, QEK_NTFISC, QEK_SERINF, QEK_ITEMNF, QEK_TIPONF, QEK_LOTE, QEK_NUMSEQ, QEK_DTENTR "
	cQuery +=          " FROM " + RetSQLName("QEK")
	cQuery +=          " WHERE (R_E_C_N_O_ = ?) "
	cQuery +=          " AND (D_E_L_E_T_ = ?)) "

	aAdd(aBindParam, {nRecnoQEK, "N"})
	aAdd(aBindParam, {" ", "S"})

	cQuery +=        " QEK  "
	cQuery +=        " ON " + Self:oQueryManager:MontaRelationArraysCampos("QEK", {"QEK_FORNEC","QEK_LOJFOR","QEK_PRODUT","QEK_NTFISC+QEK_SERINF+QEK_ITEMNF","QEK_TIPONF","QEK_LOTE","QEK_DTENTR"},;
	                                                                        "QER", {"QER_FORNEC","QER_LOJFOR","QER_PRODUT","QER_NISERI"                      ,"QER_TIPONF","QER_LOTE","QER_DTENTR"})

	If QIEReinsp()
		cQuery += " AND QEK.QEK_NUMSEQ = QER.QER_NUMSEQ "
	EndIf

	cQuery +=      " WHERE   QES.QES_FILIAL = ? "
	cQuery +=          " AND QES.D_E_L_E_T_ = ? "

    aAdd(aBindParam, {cFilQES, "S"})
	aAdd(aBindParam, {" ", "S"})

	//cQuery +=      " /*FIM 1 ANCORA DA RECURSIVIDADE*/ "
	cQuery +=      " UNION ALL "
	//cQuery +=      " /*INICIO RECURSIVIDADE*/ "
	cQuery +=      " SELECT  "
	cQuery +=          " Recursao + 1 as Recursao, "
	cQuery +=          " REC.QES_CODMED, "
	cQuery +=          " CONCAT(CONCAT(CONCAT(REC.QES_MEDICA , '," + '"' + "') , QES.QES_MEDICA) , '" + '"' + "') MEDICAO, "
	cQuery +=          " QES.Recno "
	cQuery +=      " FROM Query_Recursiva REC "
	cQuery +=      " INNER JOIN "
	cQuery +=          " (SELECT QES_CODMED, QES_MEDICA, R_E_C_N_O_ Recno "
	cQuery +=           " FROM " + RetSQLName("QES")
	cQuery +=           " WHERE  QES_FILIAL = ? "
	cQuery +=              " AND D_E_L_E_T_ = ?) QES "

    aAdd(aBindParam, {cFilQES, "S"})
	aAdd(aBindParam, {" ", "S"})

	cQuery +=      " ON      QES.Recno > REC.Recno  "
	cQuery +=          " AND QES.QES_CODMED = REC.QES_CODMED "
	//cQuery +=      " /*FIM RECURSIVIDADE*/ "
	cQuery +=   " ) "
	
	//cQuery +=   " /*FIM MONTAGEM QUERY RECURSIVA*/ "
	cQuery +=  " SELECT RECNOQEK, "
	cQuery +=         " RECNOTEST, "
	cQuery +=         " QER_DTMEDI, "
	cQuery +=         " QER_HRMEDI, "
	cQuery +=         " QER_ENSR, "
	cQuery +=         " TIPO, "
	cQuery +=         " CONCAT(CONCAT('[' , RTRIM(QES_MEDICA)) , ']') MEDICOES, "
	cQuery +=         " QER_RESULT, "
	cQuery +=         " QEQ_MEDICA, "
	cQuery +=         " QAA_LOGIN, "
	cQuery +=         " QAA_NOME, "
	cQuery +=         " QER_ENSAIO, "
	cQuery +=         " RECNOQER, "
	cQuery +=         " QER_AMOSTR, "
	
	If Self:lTemQQM
		cQuery +=         " COALESCE(TEMANEXO,'F') TEMANEXO "
	Else
		cQuery +=         " 'F' TEMANEXO "
	EndIf

	cQuery +=  " FROM Query_Recursiva  "
	cQuery +=  " INNER JOIN "
	cQuery +=      " (SELECT QES_CODMED, Count(*) MAXRECURSAO "
	cQuery +=       " FROM " + RetSQLName("QES")
	cQuery +=       " INNER JOIN "
	cQuery +=          " (SELECT QER_FORNEC, QER_LOJFOR, QER_PRODUT, QER_NISERI, QER_TIPONF, QER_LOTE, QER_NUMSEQ, QER_DTENTR, QER_CHAVE, QER_AMOSTR  "
	cQuery +=          " FROM " + RetSQLName("QER")
	cQuery +=          " WHERE (QER_FILIAL = ? ) "
	cQuery +=              " AND (D_E_L_E_T_ = ?)) "

    aAdd(aBindParam, {cFilQER, "S"})
	aAdd(aBindParam, {" ", "S"})

	cQuery +=          " QER  "
	cQuery +=       " ON QER.QER_CHAVE = QES_CODMED "

	cQuery +=       " INNER JOIN "
	cQuery +=          " (SELECT QEK_FORNEC, QEK_LOJFOR, QEK_PRODUT, QEK_REVI, QEK_NTFISC, QEK_SERINF, QEK_ITEMNF, QEK_TIPONF, QEK_LOTE, QEK_NUMSEQ, QEK_DTENTR "
	cQuery +=          " FROM " + RetSQLName("QEK")
	cQuery +=          " WHERE   (R_E_C_N_O_ = ?) "
	cQuery +=              " AND (D_E_L_E_T_ = ? )) "

    aAdd(aBindParam, {nRecnoQEK, "N"})
	aAdd(aBindParam, {" ", "S"})

	cQuery +=          " QEK  "
	cQuery +=         " ON " + Self:oQueryManager:MontaRelationArraysCampos("QEK", {"QEK_FORNEC","QEK_LOJFOR","QEK_PRODUT","QEK_NTFISC+QEK_SERINF+QEK_ITEMNF","QEK_TIPONF","QEK_LOTE","QEK_DTENTR"},;
	                                                                        "QER", {"QER_FORNEC","QER_LOJFOR","QER_PRODUT","QER_NISERI"                      ,"QER_TIPONF","QER_LOTE","QER_DTENTR"})
	
	If QIEReinsp()
		cQuery += " AND QEK.QEK_NUMSEQ = QER.QER_NUMSEQ "
	EndIf

	cQuery +=       " WHERE  D_E_L_E_T_ = ' ' "
	cQuery +=          " AND QES_FILIAL = '" + cFilQES + "' "
	cQuery +=       " GROUP BY QES_CODMED) "
	cQuery +=       " QUERYMAXRECURSAO "
	cQuery +=  " ON    Query_Recursiva.QES_CODMED = QUERYMAXRECURSAO.QES_CODMED "
	cQuery +=      " AND Query_Recursiva.Recursao = QUERYMAXRECURSAO.MAXRECURSAO "
	cQuery +=  " INNER JOIN     "
	cQuery +=      " (    SELECT  "
	cQuery +=              " '' QEQ_MEDICA, "
	cQuery +=              " 'N' TIPO, "
	cQuery +=              " QER.QER_DTMEDI, "
	cQuery +=              " QER.QER_HRMEDI, "
	cQuery +=              " QER.QER_ENSR, "
	cQuery +=              " QER.QER_RESULT, "
	cQuery +=              " QEK.R_E_C_N_O_ RECNOQEK, "
	cQuery +=              " QER.R_E_C_N_O_ RECNOQER, "
	cQuery +=              " QAA.QAA_LOGIN, "
	cQuery +=              " QAA.QAA_NOME, "
	cQuery +=              " QER.QER_ENSAIO, "
	cQuery +=              " QE7.R_E_C_N_O_ RECNOTEST, "
	cQuery +=              " QER_CHAVE, "
	cQuery +=              " QER.QER_AMOSTR, "
	cQuery += 			   " QER.QER_FILIAL  "
	cQuery +=          " FROM            "
	cQuery +=                  " (SELECT QER_FORNEC, QER_LOJFOR, QER_PRODUT, QER_REVI , QER_NISERI, QER_TIPONF, QER_LOTE, QER_NUMSEQ, QER_DTENTR, QER_CHAVE, "
	cQuery +=                          " QER_AMOSTR, QER_FILIAL, QER_ENSAIO, QER_LABOR, R_E_C_N_O_, QER_RESULT, QER_ENSR, QER_HRMEDI, QER_DTMEDI "
	cQuery +=                  " FROM " + RetSQLName("QER")
	cQuery +=                  " WHERE (QER_FILIAL = ?) "
	cQuery +=                      " AND (D_E_L_E_T_ = ?)) "

    aAdd(aBindParam, {cFilQER, "S"})
	aAdd(aBindParam, {" ", "S"})

	cQuery +=                  " QER  "

	cQuery +=              " INNER JOIN "
	cQuery +=                  " (SELECT QEK_FORNEC, QEK_LOJFOR, QEK_PRODUT, QEK_REVI, QEK_NTFISC, QEK_SERINF, QEK_ITEMNF, QEK_TIPONF, QEK_LOTE, QEK_NUMSEQ, QEK_DTENTR, R_E_C_N_O_ "
	cQuery +=                  " FROM " + RetSQLName("QEK")
	cQuery +=                  " WHERE (R_E_C_N_O_ = ?) "
	cQuery +=                      " AND (D_E_L_E_T_ = ?)) "

	aAdd(aBindParam, {nRecnoQEK, "N"})
	aAdd(aBindParam, {" ", "S"})

	cQuery +=                  " QEK  "
	cQuery +=                  " ON " + Self:oQueryManager:MontaRelationArraysCampos("QEK", {"QEK_FORNEC","QEK_LOJFOR","QEK_PRODUT","QEK_NTFISC+QEK_SERINF+QEK_ITEMNF","QEK_TIPONF","QEK_LOTE","QEK_DTENTR"},;
	                                                                                 "QER", {"QER_FORNEC","QER_LOJFOR","QER_PRODUT","QER_NISERI"                      ,"QER_TIPONF","QER_LOTE","QER_DTENTR"})
	
	If QIEReinsp()
		cQuery += " AND QEK.QEK_NUMSEQ = QER.QER_NUMSEQ "
	EndIf

	cQuery +=              " INNER JOIN "
	cQuery +=                  " (SELECT QAA_LOGIN, QAA_MAT, QAA_NOME "
	cQuery +=                   " FROM " + RetSQLName("QAA")
	cQuery +=                  " WHERE QAA_FILIAL = ? "
	cQuery +=                      " AND D_E_L_E_T_ = ?) "

	aAdd(aBindParam, {cFilQAA, "S"})
	aAdd(aBindParam, {" ", "S"})

	cQuery +=                  " QAA "
	cQuery +=              " ON QAA.QAA_MAT = QER.QER_ENSR "
	cQuery +=              " INNER JOIN "
	cQuery +=                  " (SELECT QE7_PRODUT, QE7_REVI, QE7_ENSAIO, QE7_LABOR, R_E_C_N_O_ "
	cQuery +=                   " FROM " + RetSQLName("QE7")
	cQuery +=                   " WHERE QE7_FILIAL  = ? "

	aAdd(aBindParam, {cFilQE7, "S"})

	If cIDTest != Nil .And. !Empty(cIDTest)
		cQuery +=                  " AND QE7_ENSAIO = ? "

		aAdd(aBindParam, {cIDTest, "S"})
	EndIf

	cQuery +=                      " AND D_E_L_E_T_ = ?) "
	
	
	aAdd(aBindParam, {" ", "S"})

	cQuery +=              " QE7 "
	cQuery +=              " ON QE7.QE7_PRODUT   = QER.QER_PRODUT  "
	cQuery +=               " AND QE7.QE7_REVI   = QER.QER_REVI "
	cQuery +=               " AND QE7.QE7_LABOR  = QER.QER_LABOR "
	cQuery +=               " AND QE7.QE7_ENSAIO = QER.QER_ENSAIO "
	cQuery +=      " ) NAORECURSIVA  "
	cQuery +=  " ON NAORECURSIVA.QER_CHAVE = Query_Recursiva.QES_CODMED "

	If Self:lTemQQM
		cQuery += 		 " LEFT OUTER JOIN "
		cQuery += 		  " (SELECT DISTINCT 'T' TEMANEXO, "
		cQuery += 		 		   " QQM_FILQPR,  "
		cQuery += 				   " QQM_CHAVE "
		cQuery += 		  " FROM " + RetSqlName("QQM")
		cQuery +=					" WHERE D_E_L_E_T_ = ? ) QQM ON QER_CHAVE  = QQM.QQM_CHAVE "
		cQuery += 												" AND QER_FILIAL = QQM_FILQPR "

		aAdd(aBindParam, {' ', "S"})

	EndIf

	cQuery +=  " UNION "

	//RESULTADO DE TEXTO
	cQuery += " SELECT   "
	cQuery +=     " QEK.R_E_C_N_O_ RECNOQEK, "
	cQuery +=     " QE8.R_E_C_N_O_ RECNOTEST, "
	cQuery +=     " QER.QER_DTMEDI, "
	cQuery +=     " QER.QER_HRMEDI, "
	cQuery +=     " QER.QER_ENSR, "
	cQuery +=     " 'T' AS TIPO, "
	cQuery +=     " '[]' AS MEDICOES, "
	cQuery +=     " QER.QER_RESULT, "
	cQuery +=     " QEQ_MEDICA, "
	cQuery +=     " QAA.QAA_LOGIN, "
	cQuery +=     " QAA.QAA_NOME, "
	cQuery +=     " QER.QER_ENSAIO, "
	cQuery +=     " QER.R_E_C_N_O_ RECNOQER, "
	cQuery +=     " QER.QER_AMOSTR, "

	If Self:lTemQQM
	cQuery += 	  " COALESCE(TEMANEXO,'F') TEMANEXO "
	Else
		cQuery += 	  " 'F' TEMANEXO "
	EndIf
	cQuery += " FROM "
	cQuery +=        " (SELECT QER_FORNEC, QER_LOJFOR, QER_PRODUT, QER_REVI , QER_NISERI, QER_TIPONF, QER_LOTE, QER_NUMSEQ, QER_DTENTR, QER_CHAVE, "
	cQuery +=                " QER_AMOSTR, QER_FILIAL, QER_ENSAIO, QER_LABOR, R_E_C_N_O_, QER_RESULT, QER_ENSR, QER_HRMEDI, QER_DTMEDI "
	cQuery +=         " FROM " + RetSQLName("QER")
	cQuery +=         " WHERE (QER_FILIAL = ? ) "
	cQuery +=             " AND (D_E_L_E_T_ = ?)) "

	aAdd(aBindParam, {cFilQER, "S"})
	aAdd(aBindParam, {' ', "S"})

	cQuery +=         " QER "

	If Self:lTemQQM
		cQuery += 		 " LEFT OUTER JOIN "
		cQuery += 		  " (SELECT DISTINCT 'T' TEMANEXO, "
		cQuery += 		 		   " QQM_FILQPR,  "
		cQuery += 				   " QQM_CHAVE "
		cQuery += 		  " FROM " + RetSqlName("QQM")
		cQuery +=					" WHERE D_E_L_E_T_ = ? ) QQM ON QER_CHAVE  = QQM.QQM_CHAVE "
		cQuery += 												" AND QER_FILIAL = QQM_FILQPR "

		aAdd(aBindParam, {' ', "S"})

	EndIf

	cQuery +=     " INNER JOIN "
	cQuery +=         " (SELECT QEK_FORNEC, QEK_LOJFOR, QEK_PRODUT, QEK_REVI, QEK_NTFISC, QEK_SERINF, QEK_ITEMNF, QEK_TIPONF, QEK_LOTE, QEK_NUMSEQ, QEK_DTENTR, R_E_C_N_O_ "
	cQuery +=         " FROM " + RetSQLName("QEK")
	cQuery +=         " WHERE (R_E_C_N_O_ =  ? ) "
	cQuery +=             " AND (D_E_L_E_T_ = ? )) "

	aAdd(aBindParam, {nRecnoQEK, "N"})
	aAdd(aBindParam, {" ", "S"})

	cQuery +=         " QEK "
	cQuery +=         " ON " + Self:oQueryManager:MontaRelationArraysCampos("QEK", {"QEK_FORNEC","QEK_LOJFOR","QEK_PRODUT","QEK_NTFISC+QEK_SERINF+QEK_ITEMNF","QEK_TIPONF","QEK_LOTE","QEK_DTENTR"},;
	                                                                        "QER", {"QER_FORNEC","QER_LOJFOR","QER_PRODUT","QER_NISERI"                      ,"QER_TIPONF","QER_LOTE","QER_DTENTR"})
	
	If QIEReinsp()
		cQuery += " AND QEK.QEK_NUMSEQ = QER.QER_NUMSEQ "
	EndIf
	
	cQuery +=     " INNER JOIN "
	cQuery +=         " (SELECT QAA_LOGIN, QAA_MAT, QAA_NOME "
	cQuery +=         " FROM " + RetSQLName("QAA")
	cQuery +=         " WHERE QAA_FILIAL = ? "
	cQuery +=             " AND D_E_L_E_T_ = ? ) "

    aAdd(aBindParam, {cFilQAA, "S"})
	aAdd(aBindParam, {" ", "S"})

	cQuery +=         " QAA "
	cQuery +=     " ON QAA.QAA_MAT = QER.QER_ENSR "
	cQuery +=     " INNER JOIN "
	cQuery +=         " (SELECT QE8_PRODUT, QE8_REVI, QE8_ENSAIO, QE8_LABOR, R_E_C_N_O_ "
	cQuery +=         " FROM " + RetSQLName("QE8")
	cQuery +=         " WHERE QE8_FILIAL = ? "
	
	aAdd(aBindParam, {cFilQE8, "S"})

	If cIDTest != Nil .And. !Empty(cIDTest)
		cQuery +=         " AND QE8_ENSAIO = ? "
		aAdd(aBindParam, {cIDTest, "S"})
	EndIf

	cQuery +=             " AND D_E_L_E_T_  = ? ) "

	aAdd(aBindParam, {" ", "S"})


	cQuery +=     " QE8 "
	cQuery +=     " ON QE8.QE8_PRODUT   = QER.QER_PRODUT "
	cQuery +=      " AND QE8.QE8_REVI   = QER.QER_REVI "
	cQuery +=      " AND QE8.QE8_LABOR  = QER.QER_LABOR "
	cQuery +=      " AND QE8.QE8_ENSAIO = QER.QER_ENSAIO "

	cQuery += 	" INNER JOIN "
	cQuery +=     " (SELECT QEQ_CODMED, QEQ_MEDICA "
	cQuery +=  	  " FROM " + RetSQLName("QEQ")
	cQuery +=  	  " WHERE (QEQ_FILIAL = ?) "
	cQuery +=         " AND D_E_L_E_T_ = ?) "

    aAdd(aBindParam, {cFilQEQ, "S"})
	aAdd(aBindParam, {" ", "S"})

	cQuery +=     " QEQ "
	cQuery +=     " ON QEQ.QEQ_CODMED = QER.QER_CHAVE "


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
@param 01 - oDadosJson, objeto, objeto Json com os dados JSON recebidos da API para conversão
@param 02 - aRecnosQER, array , retorna por referência os RECNOS da QER relacionados
@param 03 - cErrorMessage, string, retorna por referência a mensagem de erro
@return lSucesso, lógico, indica se o processo foi executado com sucesso
/*/
METHOD ProcessaItensRecebidos(oDadosJson, aRecnosQER, cErrorMessage) CLASS ResultadosEnsaiosInspecaoDeEntradasAPI

	Local lSucesso   := .T.
	Local nIndReg    := Nil
	Local oDadosCalc := Nil
	Local oItemAPI   := Nil
	Local oQNCClass  := Nil
	Local oRegistro  := Nil

	Default aRecnosQER := {}

	Self:nRegistros := Len(oDadosJson["items"])
	If Self:nRegistros <= 0
		lSucesso              := .F.
		//"Dados para Integração Inválidos"
		//"Não existem registros para gravação"
		Self:cErrorMessage    := STR0008
		Self:cDetailedMessage := STR0009
	Else

		Self:aCamposAPI             := Iif(Self:aCamposAPI == Nil, Self:MapeiaCamposAPI("*"), Self:aCamposAPI)
		Self:aCamposQER             := IIf(Self:aCamposQER == Nil, Self:MapeiaCamposQER("*"), Self:aCamposQER)
		
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

			lSucesso := IIf(lSucesso, Self:PreparaRegistroQER(oItemAPI, @oRegistro), lSucesso)

			Self:oAnexos:RegistraAnexos(oItemAPI, oRegistro, "QIE")

			lSucesso := IIf(lSucesso, Self:ValidaEnsaiador(oRegistro), lSucesso)

			lSucesso := IIf(lSucesso, Self:SalvaRegistros(oItemAPI, oRegistro, @aRecnosQER), lSucesso)

			If !oDadosJson['justCalculated']
				sQNCClass := IIF(sQNCClass == Nil, FindClass("FichasNaoConformidadesAPI"), sQNCClass)
				If sQNCClass .AND. lSucesso .AND. oItemAPI["nonConformitiesList"] != Nil
					oQNCClass := IIF(oQNCClass == Nil, FichasNaoConformidadesAPI():New(), oQNCClass)
					lSucesso  := oQNCClass:processaRelacionamentoNCQIE(oRegistro["R_E_C_N_O_"], oItemAPI["nonConformitiesList"], @cErrorMessage)
				EndIf

				If lSucesso
					lSucesso  := Self:processaRelacionamentoInstrumento(oRegistro, oItemAPI, @cErrorMessage)
				EndIf

			EndIf

			If !lSucesso
				Exit
			EndIf

			If Self:oAPIManager:existePEIntegracaoAppMinhaProducaoCompilado("QIE")
				Execblock('QIEINTAPI',.F.,.F.,{oRegistro, "incominginspectiontestresults/api/qie/v1/save", "ResultadosEnsaiosInspecaoDeEntradasAPI", "complementoAmostra"})
			EndIf

		Next nIndReg

	EndIf
Return lSucesso

/*/{Protheus.doc} processaRelacionamentoInstrumento
Processa relacionamento do Instrumento (Inclui, altera ou excluí)
@author rafael.kleestadt / brunno.costa
@since  07/05/2025
@param 01 - oRegistro    , objeto, objeto com os dados do registro da QER
@param 02 - oItemAPI	 , objeto, objeto com os dados do item da API
@param 03 - cErrorMessage, string, retorna por referência a mensagem de erro
@return lSucesso, lógico, indica se processou com sucesso a lista de instrumentos relacionados
/*/
METHOD processaRelacionamentoInstrumento(oRegistro, oItemAPI, cErrorMessage) as logical CLASS ResultadosEnsaiosInspecaoDeEntradasAPI

	Local aLista        := oItemAPI["instrumentsList"]
	Local cCarta        := Posicione("QE1", 1, xFilial("QE1")+oRegistro["QER_ENSAIO"], "QE1_CARTA")
	Local cTipo         := ""
	Local lInstrumento  := Iif(ValType(GetMv("MV_QINVLTX")) == "C", Val(GetMv("MV_QINVLTX")), GetMv("MV_QINVLTX")) == 1
	Local lSucesso      := .T.
	Local nInstrumentos := 0
	Local nItem         := 0
	Local nRecnoQER     := oRegistro["R_E_C_N_O_"]
	Local nTotal        := Iif(aLista == Nil, 0, Len(aLista))
	Local oEnsaiosAPI   := EnsaiosInspecaoDeEntradasAPI():New(Self:oWSRestFul)

	//Valida Obrigatoriedade de Instrumento
	slMVQINTQMT := Iif(slMVQINTQMT == Nil, AllTrim(Upper(GetMv("MV_QINTQMT")))  == "S", slMVQINTQMT  )
	slMVQinvlTx := Iif(slMVQinvlTx == Nil, lInstrumento  							  , slMVQinvlTx )
	scMVQlins   := Iif(scMVQlins   == Nil, AllTrim(GetMv("MV_QLINS"))                 , scMVQlins   )

	If lSucesso
		//Grava Instruentos
		DbSelectArea("QET")
		DbSelectArea("QM2")
		DbSelectArea("QM6")
		QET->(dbSetOrder(1))
		QM2->(dbSetOrder(1))
		QM6->(dbSetOrder(1))
		For nItem := 1 To nTotal

			//Ajusta tamanho dos campos Instrumento e Revisao
			aLista[nItem]['code']     := PadR(aLista[nItem]['code']    , GetSx3Cache("QET_INSTR" ,"X3_TAMANHO"))
			aLista[nItem]['revision'] := PadR(aLista[nItem]['revision'], GetSx3Cache("QET_REVINS","X3_TAMANHO"))

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
		If lSucesso .AND. slMVQINTQMT .AND. nInstrumentos == 0

			//Preenche oRegistro da QER completo quando houver integração com o QMT em operação de edição
			If slMVQINTQMT .And. oRegistro["R_E_C_N_O_"] > 0
				cTipo := oItemAPI["testType"]

				If cTipo == "N"        //Tipo N -> Array Numérico -> QE7
					lSucesso := Self:RecuperaCamposQE7paraQER(@oRegistro, oItemAPI["recnoTest"])

				ElseIf cTipo == "T"    //Tipo T -> Texto -> QE8
					lSucesso := Self:RecuperaCamposQE8paraQER(@oRegistro, oItemAPI["recnoTest"])

				EndIf

				If lSucesso
					lSucesso := Self:RecuperaCamposQEKParaQER(@oRegistro, oItemAPI["recnoInspection"])
				EndIf
			EndIf
			
			If oEnsaiosAPI:PossuiFamiliaDeInstrumentos( oRegistro["QER_PRODUT"],;
														oRegistro["QER_REVI"  ],;
														oRegistro["QER_ENSAIO"])

				If cCarta != "TXT" .OR. slMVQinvlTx
					//STR0068 - "Informe o instrumento relacionado ao ensaio"
					cErrorMessage := STR0068 + " '" + AllTrim(Posicione("QE1", 1, xFilial("QE1") + oRegistro["QER_ENSAIO"], "QE1_DESCPO")) + "(" + oRegistro["QER_ENSAIO"] + ")'."
					lSucesso      := .F.
					Self:oAPIManager:lWarningError := .T.
				EndIf

			EndIf
		EndIf

	EndIf


Return lSucesso

/*/{Protheus.doc} validaInclusaoRelacionamentoInstrumento
Valida inclusão de relacionamento de Amostra com Instrumento
@author rafael.kleestadt / brunno.costa
@since  07/05/2025
@param 01 - oRegistro    , objeto, objeto com os dados do registro da QER
@param 02 - oItemAPI     , objeto, item para inclusão de relacionamento
@param 03 - cErrorMessage, string, retorna por referência a mensagem de erro
@return lSucesso, lógico, indica se processou com sucesso a validação de inclusão do relacionamento do instrumento
/*/
METHOD validaInclusaoRelacionamentoInstrumento(oRegistro, oItemAPI, cErrorMessage) as logical CLASS ResultadosEnsaiosInspecaoDeEntradasAPI

	Local cEnsaio      := ""
    Local cInstrumento := IIf(!Empty(QM2->QM2_DESCR), AllTrim(QM2->QM2_DESCR) + " ", "") + "(" + AllTrim(oItemAPI[ 'code' ]) + "/" + AllTrim(oItemAPI[ 'revision' ]) + ")"
    Local dDataMedicao := oRegistro["QER_DTMEDI"]
	Local lPosicQM2    := .F.
	Local lPosicQM6    := .F.
	Local lSucesso     := .T.
	
	lPosicQM2 := QM2->(dbSeek(xFilial("QM2")+oItemAPI['code']+Inverte(oItemAPI['revision'])))
	lPosicQM6 := QM6->(dbSeek(xFilial('QM6')+oItemAPI['code']+        oItemAPI['revision'] ))
	lSucesso  := lPosicQM2 .And. lPosicQM6

	//STR0069 - "Instrumento não encontrado"
	//STR0070 - "Calibração do instrumento"
	//STR0071 - "não encontrada."
	cErrorMessage := Iif(!lPosicQM2, STR0069 + ": " + AllTrim(oItemAPI['code']) + "/" + AllTrim(oItemAPI['revision']), cErrorMessage)
	cErrorMessage := Iif(!lPosicQM6, STR0070 + " '" + cInstrumento + "' " + STR0071, cErrorMessage)
	Self:oAPIManager:lWarningError := Iif(!lPosicQM2 .OR. !lPosicQM6, .T., Self:oAPIManager:lWarningError)

    // Laudo do instrumento vazio
    If lSucesso .And. Empty(QM2->QM2_LAUDO)
		//STR0072 - "Instrumento"
		//STR0073 - "relacionado ao ensaio"
		//STR0074 - "sem laudo cadastrado."
		cEnsaio      := AllTrim(Posicione("QE1", 1, xFilial("QE1") + oRegistro["QER_ENSAIO"], "QE1_DESCPO")) + " (" + oRegistro["QER_ENSAIO"] + ")"
        cErrorMessage := STR0072 + " '" + cInstrumento + "' " + STR0073 + " '" + cEnsaio + "' " + STR0074
        lSucesso      := .F.
		Self:oAPIManager:lWarningError := .T.
    EndIf

	// Laudo do instrumento incompatível
    If lSucesso .And. !(QM2->QM2_LAUDO $ scMVQlins)
		//STR0075 - "Laudo"
		//STR0076 - "do instrumento"
		//STR0073 - "relacionado ao ensaio"
		//STR0077 - "não é permitido (MV_QLINS)."
		cEnsaio      := AllTrim(Posicione("QE1", 1, xFilial("QE1") + oRegistro["QER_ENSAIO"], "QE1_DESCPO")) + " (" + oRegistro["QER_ENSAIO"] + ")"
        cErrorMessage := STR0075 + " '" + QM2->QM2_LAUDO + "' " + STR0076 + " '" + cInstrumento + "' " + STR0073 + " '" + cEnsaio + "' " + STR0077
        lSucesso      := .F.
		Self:oAPIManager:lWarningError := .T.
    EndIf

    // Instrumento inativo
    If lSucesso .AND. QM2->QM2_STATUS != "A"
		//STR0078 - "O instrumento"
		//STR0073 - "relacionado ao ensaio"
		//STR0079 - "está inativo."
		cEnsaio      := AllTrim(Posicione("QE1", 1, xFilial("QE1") + oRegistro["QER_ENSAIO"], "QE1_DESCPO")) + " (" + oRegistro["QER_ENSAIO"] + ")"
        cErrorMessage := STR0078 + " '" + cInstrumento + "' " + STR0073 + " '" + cEnsaio + "' " + STR0079
        lSucesso      := .F.
		Self:oAPIManager:lWarningError := .T.
    EndIf

    // Validade do instrumento incompatível
    If lSucesso .AND. QM2->QM2_VALDAF < dDataMedicao
		//STR0072 - "Instrumento"
		//STR0073 - "relacionado ao ensaio"
		//STR0080 - "com validade incompatível à data da amostra."
		cEnsaio      := AllTrim(Posicione("QE1", 1, xFilial("QE1") + oRegistro["QER_ENSAIO"], "QE1_DESCPO")) + " (" + oRegistro["QER_ENSAIO"] + ")"
        cErrorMessage := STR0071 + " '" + cInstrumento + "' " + STR0073 + " '" + cEnsaio + "' " + STR0080
        lSucesso      := .F.
		Self:oAPIManager:lWarningError := .T.
    EndIf

Return lSucesso

/*/{Protheus.doc} incluiRelacionamentoInstrumento
Processa inclusão de relacionamento de Amostra com Instrumento
@author rafael.kleestadt / brunno.costa
@since  07/05/2025
@param 01 - nRecnoQER, número, recno da amostra na QER relacionada
@param 02 - oItemAPI , objeto, item para inclusão de relacionamento
@return lSucesso, lógico, indica se processou com sucesso a inclusão do relacionamento instrumento
/*/
METHOD incluiRelacionamentoInstrumento(nRecnoQER, oItemAPI) as logical CLASS ResultadosEnsaiosInspecaoDeEntradasAPI

	Local cChaveQER := ""
	Local lSucesso  := .F.

	//Posiciona na QER
	QER->(DbGoTo(nRecnoQER))
	cChaveQER := QER->QER_CHAVE

	If !QET->(dbSeek(xFilial("QET")+cChaveQER+oItemAPI['code']))
		RecLock("QET",.T.)
		QET->QET_FILIAL := xFilial("QET")
		QET->QET_CODMED := cChaveQER
		QET->QET_INSTR  := oItemAPI['code']
		MsUnLock()
		FkCommit()
	EndIf

	RecLock("QET",.F.)
	QET->QET_INSTR  := oItemAPI['code']
	QET->QET_REVINS := oItemAPI['revision']
	QET->QET_REVTIP := QM6->QM6_REVTIP
	MsUnLock()
	FkCommit()
	lSucesso      := .T.

Return lSucesso

/*/{Protheus.doc} excluiRelacionamentoInstrumento
Processa exclusão de relacionamento de Amostra com Instrumento
@author thiago.rover
@since  21/05/2025
@param 01 - nRecnoQER, número, recno da amostra na QER relacionada
@param 02 - oItem  , objeto, item de para inclusão de relacionamento
@param 03 - cErrorMessage, string, retorna por referência a mensagem de erro
@return lSucesso, lógico, indica se processou com sucesso a exclusão do relacionamento instrumento
/*/
METHOD excluiRelacionamentoInstrumento(nRecnoQER, oItem, cErrorMessage) as Logical CLASS ResultadosEnsaiosInspecaoDeEntradasAPI

	Local cBkpMsg   := cErrorMessage
	Local cChaveQER := ""
	Local lPosicQET := .F.
	Local lSucesso  := .F.

	oItem['code']     := PadR(oItem['code']    , GetSx3Cache("QET_INSTR" ,"X3_TAMANHO"))

	//Posiciona na QER
	If nRecnoQER > 0
		QER->(DbGoTo(nRecnoQER))
		cChaveQER := QER->QER_CHAVE

		lPosicQET     := QET->(dbSeek(xFilial("QET")+cChaveQER+oItem['code']))

		If lPosicQET
			RecLock("QET",.F.)
			QET->(dbDelete())
			MsUnLock()
			lSucesso      := .T.
			cErrorMessage := cBkpMsg
		EndIf
	EndIf

Return lSucesso


/*/{Protheus.doc} PreparaRegistroInclusaoQER
Prepara Registro
@author brunno.costa
@since  23/05/2022
@param 01 - oItemAPI  , objeto, objeto Json com UM ITEM DOS REGISTROS JSON recebidos da API para conversão
@param 02 - oRegistro , objeto, retorna por referência os dados para gravação na tabela QER do DB
@return lSucesso, lógico, indica se o processo foi executado com sucesso
/*/
METHOD PreparaRegistroInclusaoQER(oItemAPI, oRegistro) CLASS ResultadosEnsaiosInspecaoDeEntradasAPI
	
	Local cTipo      := Nil
	Local lSucesso   := .T.

	oRegistro := Self:oAPIManager:InicializaCamposPadroes("QER",,.T.)
	oRegistro := Self:oAPIManager:AtualizaCamposAPINoRegistro(oItemAPI, oRegistro, "QER", Self:aCamposAPI)

	cTipo := oItemAPI["testType"]
	
	If cTipo == "N"        //Tipo N -> Array Numérico -QE7P7
		lSucesso := Self:RecuperaCamposQE7paraQER(@oRegistro, oItemAPI["recnoTest"])

	ElseIf cTipo == "T"    //Tipo T -> Texto -> QE8
		lSucesso := Self:RecuperaCamposQE8paraQER(@oRegistro, oItemAPI["recnoTest"])

	EndIf

	If lSucesso
		lSucesso := Self:RecuperaCamposQEKParaQER(@oRegistro, oItemAPI["recnoInspection"])
	EndIf

	If lSucesso
		oRegistro["QER_CHAVE"]     := oItemAPI["QER_CHAVE"]
		If oItemAPI["QER_CHAVE"] == Nil
			If Self:EnsaioComMedia(cTipo, QE7->QE7_FORMUL)
				Self:AtualizaChaveQERParaMedia(oRegistro)
			Else
				oRegistro["QER_CHAVE"] := Self:GeraChaveQER()
			EndIf
			oItemAPI["QER_CHAVE"]  := oRegistro["QER_CHAVE"]
		EndIf
		Self:AtualizaEnsaiadorQER(oItemAPI["protheusLogin"], @oRegistro)
	EndIf

Return lSucesso

/*/{Protheus.doc} EnsaioComMedia
Avalia se é um ensaio numérico com fórmula de média
@author brunno.costa
@since  04/10/2022
@param 01 - cTipo   , caracter, indica o tipo do ensaio (N - Numérico ou T - Texto)
@param 02 - cFormula, caracter, formula para análise
@return lEnsaioComMedia, lógico, indica se o ensaio atual corresponde a um registro numérico e com média na fórmula
/*/
METHOD EnsaioComMedia(cTipo, cFormula) CLASS ResultadosEnsaiosInspecaoDeEntradasAPI
	Local lEnsaioComMedia := cTipo == "N" .AND. At("AVG", cFormula)
Return lEnsaioComMedia

/*/{Protheus.doc} GeraChaveQER
Gecha próxima numeração para o campo QER_CHAVE
@author brunno.costa
@since  23/05/2022
@return cChave, caracter, próxima numeração para a chave
/*/
METHOD GeraChaveQER() CLASS ResultadosEnsaiosInspecaoDeEntradasAPI
	
	Local cChave   := Nil
	Local nSaveSX8 := Nil

	nSaveSX8 := GetSX8Len()
	cChave   := QA_SXESXF("QER","QER_CHAVE",,4)

	While ( GetSX8Len() > nSaveSx8 )
		ConfirmSX8()
	EndDo

Return cChave

/*/{Protheus.doc} AtualizaChaveQERParaMedia
Recupera a Chave da QER para Registro de Média, ou seja, primeiro registro existente da amostra ou chave nova
@author brunno.costa
@since  04/10/2022
@param 01 - oRegistro, objeto, registro JSON com os dados para gravação na QER que serão atualizados
/*/
METHOD AtualizaChaveQERParaMedia(oRegistro) CLASS ResultadosEnsaiosInspecaoDeEntradasAPI
	QER->(DbSetOrder(1))
	//QER_FILIAL+QER_PRODUT+QER_REVI+QER_FORNEC+QER_LOJFOR+DTOS(QER_DTENTR)+QER_LOTE+QER_LABOR+QER_ENSAIO   +DTOS(QER_DTMEDI)+QER_HRMEDI+STR(QER_AMOSTR,1)
	
	If QER->(DbSeek(xFilial("QER")+;
	                oRegistro["QER_PRODUT"]+;
					oRegistro["QER_REVI"  ]+;
					oRegistro["QER_FORNEC"]+;
					oRegistro["QER_LOJFOR"]+;
					DtoS(oRegistro["QER_DTENTR"])+;
					oRegistro["QER_LOTE"  ]+;
					oRegistro["QER_LABOR" ]+;
					oRegistro["QER_ENSAIO"]))
		oRegistro["QER_CHAVE"]  := QER->QER_CHAVE
		oRegistro['R_E_C_N_O_'] := QER->(Recno())
	EndIf

	If Empty(oRegistro["QER_CHAVE"])
		oRegistro["QER_CHAVE"] := Self:GeraChaveQER()
	EndIf
Return

/*/{Protheus.doc} AtualizaEnsaiadorQER
Atualiza Ensaiador no oRegistro com base no cLogin recebido
@author brunno.costa
@since  23/05/2022
@param 01 - cLogin   , caracter, nome do login de usuário utilizado no Protheus pelo usuário do APP
@param 02 - oRegistro, objeto  , registro JSON com os dados para gravação na QER que serão atualizados
/*/
METHOD AtualizaEnsaiadorQER(cLogin, oRegistro) CLASS ResultadosEnsaiosInspecaoDeEntradasAPI

	Self:oCacheEnsaiadorQER := Iif(Self:oCacheEnsaiadorQER == Nil, JsonObject():New(), Self:oCacheEnsaiadorQER)

	If Self:oCacheEnsaiadorQER[cLogin] == Nil
		//Força passagem por MATXALC para popular variável Static cRetCodUsr - DMANQUALI-9983 - DBRUnlock cannot be called in a transaction
		PCPDocUser(RetCodUsr(cLogin))
		Self:cLogin := cLogin

		DbSelectArea("QAA")
		QAA->(DbSetOrder(6))
		If QAA->(DbSeek(Upper(cLogin))) .OR. QAA->(DbSeek(Lower(cLogin)))
			oRegistro["QER_FILMAT"]         :=  QAA->QAA_FILIAL
			oRegistro["QER_ENSR"  ]         :=  QAA->QAA_MAT
			Self:oCacheEnsaiadorQER[cLogin] := {QAA->QAA_FILIAL, QAA->QAA_MAT}
		EndIf
	Else
		oRegistro["QER_FILMAT"]     := Self:oCacheEnsaiadorQER[cLogin, 1]
		oRegistro["QER_ENSR"  ]     := Self:oCacheEnsaiadorQER[cLogin, 2]
	EndIf
	
Return 

/*/{Protheus.doc} RecuperaCamposQE7paraQER
Recupera campos referência da tabelQE7P7 para gravação na QER
@author brunno.costa
@since  23/05/2022
@param 01 - oRegistro, objeto  , registro JSON com os dados para gravação na QER que serão atualizados
@param 02 - nRecnoQE7, numérico, recno do registro referênciaQE7 QP7
@return lSucesso, lógico, indica se o processo foi executado com sucesso
/*/
METHOD RecuperaCamposQE7paraQER(oRegistro, nRecnoQE7) CLASS ResultadosEnsaiosInspecaoDeEntradasAPI

	Local cCampo     := Nil
	Local cCampoQE7  := Nil
	Local lSucesso   := .T.
	Local nCamposQER := Len(Self:aCamposQER)
	Local nIndCampo  := 0

	Default nRecnoQE7   := -1

	DbSelectArea("QE7")
	QE7->(DbGoTo(nRecnoQE7))
	If nRecnoQE7 <= 0 .OR. QE7->(Eof())
		lSucesso              := .F.
		//"Dados para Integração Inválidos"
		//"Não foi possível encontrar o registro QE7 de RECNO[recnoTest]: "
		Self:cErrorMessage    := STR0008                        
		Self:cDetailedMessage := STR0011 + cValToChar(nRecnoQE7)
	Else
		For nIndCampo := 1 to nCamposQER
			If Self:aCamposQER[nIndCampo][nPosCPS_Alias] == "QE7QE8"
				cCampo            := Self:aCamposQER[nIndCampo][nPosCPS_Protheus]
				cCampoQE7         := Self:aCamposQER[nIndCampo][nPosCPS_Protheus_Externo]
				oRegistro[cCampo] := QE7->&(cCampoQE7)
			EndIf
		Next nIndCampo
	EndIf
	
Return lSucesso

/*/{Protheus.doc} RecuperaCamposQE8paraQER
Recupera campos referência da tabelQE8P8 para gravação na QER
@author brunno.costa
@since  23/06/2022
@param 01 - oRegistro, objeto  , registro JSON com os dados para gravação na QER que serão atualizados
@param 02 - nRecnoQE8, numérico, recno do registro referênciaQE8 QP8
@return lSucesso, lógico, indica se o processo foi executado com sucesso
/*/
METHOD RecuperaCamposQE8paraQER(oRegistro, nRecnoQE8) CLASS ResultadosEnsaiosInspecaoDeEntradasAPI

	Local cCampo     := Nil
	Local cCampoQE8  := Nil
	Local lSucesso   := .T.
	Local nCamposQER := Len(Self:aCamposQER)
	Local nIndCampo  := 0

	Default nRecnoQE8   := -1

	DbSelectArea("QE8")
	QE8->(DbGoTo(nRecnoQE8))
	If nRecnoQE8 <= 0 .OR. QE8->(Eof())
		lSucesso              := .F.
		//"Dados para Integração Inválidos"
		//"Não foi possível encontrar o registro QE8 de RECNO[recnoTest]: "
		Self:cErrorMessage    := STR0008                        
		Self:cDetailedMessage := STR0019 + cValToChar(nRecnoQE8)
	Else
		For nIndCampo := 1 to nCamposQER
			If Self:aCamposQER[nIndCampo][nPosCPS_Alias] == "QE7QE8"
				cCampo            := Self:aCamposQER[nIndCampo][nPosCPS_Protheus]
				cCampoQE8         := Self:aCamposQER[nIndCampo][nPosCPS_Protheus_Externo]
				cCampoQE8         := StrTran(cCampoQE8, "QE7", "QE8")
				oRegistro[cCampo] := QE8->&(cCampoQE8)
			EndIf
		Next nIndCampo
	EndIf
	
Return lSucesso

/*/{Protheus.doc} RecuperaCamposQEKParaQER
Recupera campos referência da tabela QEK para gravação na QER
@author brunno.costa
@since  23/05/2022
@param 01 - oRegistro, objeto  , registro JSON com os dados para gravação na QER que serão atualizados
@param 02 - nRecnoQEK, numérico, recno do registro referência da QEK
@return lSucesso, lógico, indica se o processo foi executado com sucesso
/*/
METHOD RecuperaCamposQEKParaQER(oRegistro, nRecnoQEK) CLASS ResultadosEnsaiosInspecaoDeEntradasAPI

	Local cCampo     := Nil
	Local cCampoQEK  := Nil
	Local lSucesso   := .T.
	Local nCamposQER := Len(Self:aCamposQER)
	Local nIndCampo  := 0

	Default nRecnoQEK   := -1

	DbSelectArea("QEK")
	QEK->(DbGoTo(nRecnoQEK))
	If nRecnoQEK <= 0 .OR. QEK->(Eof())
		lSucesso              := .F.
		//"Dados para Integração Inválidos"
		//"Não foi possível encontrar o registro da QEK de RECNO[recnoInspection]: "
		Self:cErrorMessage    := STR0008                        
		Self:cDetailedMessage := STR0012 + cValToChar(nRecnoQEK)
	Else
		For nIndCampo := 1 to nCamposQER
			If Self:aCamposQER[nIndCampo][nPosCPS_Alias] == "QEK"
				cCampo            := Self:aCamposQER[nIndCampo][nPosCPS_Protheus]
				cCampoQEK         := Self:aCamposQER[nIndCampo][nPosCPS_Protheus_Externo]
				oRegistro[cCampo] := QEK->&(cCampoQEK)
			EndIf
		Next nIndCampo
	EndIf
	
Return lSucesso

/*/{Protheus.doc} PreparaDadosQES
Prepara os Dados Recebidos para Gravação na tabela QES
@author brunno.costa
@since  23/05/2022
@param 01 - oDadosJson, objeto, objeto Json com os dados JSON recebidos da API para conversão
@param 02 - oDadosQES , objeto, retorna por referência os dados para gravação na tabela QER do DB
@return oDadosQES, objeto, retorna os dados para gravação na tabela QES do DB
/*/
METHOD PreparaDadosQES(oItemAPI, oDadosQES) CLASS ResultadosEnsaiosInspecaoDeEntradasAPI
	
	Local nIndMedicoes := Nil
	Local nMedicoes    := Nil
	Local oRegistro    := Nil
	Local cJsonQESDef  := ""

	If Self:aCamposQES       == Nil
		Self:aCamposQES      := Self:MapeiaCamposQES("*")
	EndIf

	oDadosQES['items'  ]     := {}

	oRegistro   := Self:oAPIManager:InicializaCamposPadroes("QES",,.T.)
	cJsonQESDef := oRegistro:toJson()

	nMedicoes := Len(oItemAPI["measurements"])
	For nIndMedicoes := 1 to nMedicoes
		oRegistro                   := JsonObject():New()
		oRegistro:fromJson(cJsonQESDef)
		oRegistro["QES_MEDICA"]     := oItemAPI["measurements"][nIndMedicoes]
		oRegistro["QES_CODMED"]     := oItemAPI["QER_CHAVE"]
		If nIndMedicoes == 1
			oRegistro["QES_INDMED"] := "A"
		Elseif nIndMedicoes == 2
			oRegistro["QES_INDMED"] := "N"
		Elseif nIndMedicoes == 3
			oRegistro["QES_INDMED"] := "P"
		EndIf

		//TODO
		//TODO O QUE É ISSO NO FONTE?
		//If nY == 4
		//	QES->QES_MEDICA := StrTran(Str(aResultados[nPosOpe,_MED,nPosLab,nPosEns,nPosMed,(nMed+nY)-1],TamSx3("QES_MEDICA")[1],2),".",",")
		//Else
		//	QES->QES_MEDICA := Str(aResultados[nPosOpe,_MED,nPosLab,nPosEns,nPosMed,(nMed+nY)-1],TamSx3("QES_MEDICA")[1],TamSx3("QES_MEDIPP")[2])
		//EndIf
		aAdd(oDadosQES['items'], oRegistro)
	Next nIndMedicoes

Return oDadosQES

/*/{Protheus.doc} SalvaRegistroQESSequencialmente
Grava os Registros NUMÉRICOS Sequencialmente na Tabela QES
@author brunno.costa
@since  23/05/2022
@param 01 - oDadosJson, objeto, objeto Json com os dados JSON que serão gravados na QES
@return lSucesso, lógico, indica se o processo foi executado com sucesso
/*/
METHOD SalvaRegistroQESSequencialmente(oDadosJson) CLASS ResultadosEnsaiosInspecaoDeEntradasAPI

	Local cCpsErro    := ""
	Local cFilQES     := xFilial("QES")
	Local lModificado := .T.
	Local lSucesso    := .T.
	Local nIndReg     := Nil
	Local nRegistros  := Len(oDadosJson[ 'items' ])

	If nRegistros > 0
		If oDadosJson['items'][1]['QES_CODMED'] == Nil .OR. oDadosJson['items'][1]['QES_MEDICA'] == Nil
			//"Dados para Integração Inválidos"
			//"Dados para gravação na QES inválidos no registro: "
			Self:cErrorMessage    := STR0008                                  
			Self:cDetailedMessage := STR0013 + oDadosJson['items'][1]:toJson()
			lSucesso              := .F.
			Return lSucesso
		EndIf

		DbSelectArea("QES")
		QES->(DbSetOrder(1))
		QES->(DbSeek(cFilQES+oDadosJson['items'][1]['QES_CODMED']))
		For nIndReg  := 1 to nRegistros
			lSucesso := Self:oAPIManager:ValidaCamposObrigatorios(oDadosJson['items'][nIndReg], "|QES_CODMED|QES_MEDICA|", @cCpsErro)
			If lSucesso
				lSucesso := Self:oAPIManager:ValidaFormatosCamposItem(oDadosJson['items'][nIndReg], Self:aCamposQES, @cCpsErro, nPosCPS_Protheus)
				If lSucesso
					If oDadosJson['items'][nIndReg]['QES_CODMED'] == QES->QES_CODMED
						lModificado := Self:oAPIManager:validaMudancaRegistro("QES", oDadosJson['items'][nIndReg], Self:aCamposQES)
						If lModificado
							RecLock("QES", .F.)
						EndIf
					Else
						lModificado := .T.
						RecLock("QES", .T.)
					EndIf

					If lModificado
						QES->QES_FILIAL := cFilQES
						QES->QES_CODMED := oDadosJson['items'][nIndReg]['QES_CODMED']
						QES->QES_MEDICA := oDadosJson['items'][nIndReg]['QES_MEDICA']
						QES->QES_INDMED := oDadosJson['items'][nIndReg]['QES_INDMED']

						QES->(MsUnlock())
					EndIf

					If nIndReg  < nRegistros
						QES->(dbSkip())
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
METHOD ErrorBlock(e) CLASS ResultadosEnsaiosInspecaoDeEntradasAPI
	
	Local cCallStack := ""
	Local nIndAux    := Nil
	Local nTotal     := 10
	
	For nIndAux := 2 to (1+nTotal)
		cCallStack += " <- " + ProcName(nIndAux) + " line " + cValToChar(ProcLine(nIndAux))
	Next nIndAux

	Self:cErrorMessage    := Iif(Empty(Self:cErrorMessage) , STR0014 + " - ResultadosEnsaiosInspecaoDeEntradasAPI", Self:cErrorMessage ) //Erro Interno
	Self:cDetailedMessage := e:Description + cCallStack
	Self:oAPIManager:lWarningError := .F.

Return 

/*/{Protheus.doc} ValidaFormatosCamposItem
Valida Formatos de Campos Recebidos no Item
@author brunno.costa
@since  24/06/2022
@param 01 - oItemAPI  , objeto, objeto Json com UM ITEM DOS REGISTROS JSON recebidos da API para conversão
@return lSucesso, lógico, indica sucesso na validação
/*/
METHOD ValidaFormatosCamposItem(oItemAPI) CLASS ResultadosEnsaiosInspecaoDeEntradasAPI
	
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

/*/{Protheus.doc} PreparaRegistroQER
Prepara e Valida Registros para Inclusão na QER
@author brunno.costa
@since  23/05/2022
@param 01 - oItemAPI  , objeto, objeto Json com UM ITEM DOS REGISTROS JSON recebidos da API para conversão
@param 02 - oRegistro , objeto, retorna por referência os dados do registro da QER para gravação
@return lSucesso, lógico, indica sucesso na operação
/*/
METHOD PreparaRegistroQER(oItemAPI, oRegistro) CLASS ResultadosEnsaiosInspecaoDeEntradasAPI
	
	Local lSucesso := .T.
	Local nRecno   := oItemAPI["recno"]

	Self:nRecnoQEK := Iif(Self:nRecnoQEK == Nil, oItemAPI["recnoInspection"], Self:nRecnoQEK)
	If (nRecno == Nil .OR. nRecno <= 0)
		lSucesso := Self:PreparaRegistroInclusaoQER(@oItemAPI, @oRegistro)
		If lSucesso
			lSucesso := Self:ValidaEnsaioEditavelPorRegistro(oRegistro, "I")
		EndIf
	Else
		lSucesso := Self:oAPIManager:AtualizaCamposBancoNoRegistro(@oRegistro, "QER", nRecno, Self:aCamposQER)
		If lSucesso
			lSucesso := Self:RecuperaCamposQEKParaQER(@oRegistro, Self:nRecnoQEK)
		EndIf
		If lSucesso
			//QER->(DbGoTo(nRecno)) - Já faz em AtualizaCamposBancoNoRegistro
			lSucesso := Self:ValidaEnsaioEditavelPorQER("A")
		EndIf
		If lSucesso
			oItemAPI["QER_CHAVE"] := oRegistro["QER_CHAVE"]
			oRegistro := Self:oAPIManager:AtualizaCamposAPINoRegistro(oItemAPI, oRegistro, "QER", Self:aCamposAPI)
			Self:AtualizaEnsaiadorQER(oItemAPI["protheusLogin"], @oRegistro)
		Else
			//"Dados para Integração Inválidos"
			//"Não foi possível encontrar o registro da QER de RECNO[recno]: "
			Self:cErrorMessage    := STR0008                          
			Self:cDetailedMessage := STR0010 + cValToChar(nRecno)     
		EndIf
	EndIf

Return lSucesso

/*/{Protheus.doc} SalvaRegistros
Salva Registros no Banco de Dados
@author brunno.costa
@since  24/06/2022
@param 01 - oItemAPI  , objeto, objeto Json com UM ITEM DOS REGISTROS JSON recebidos da API para conversão
@param 02 - oRegistro , objeto, registro JSON com os dados para gravação na QER
@param 03 - aRecnosQER, array , NIL e Vazio para retornar todos ou array com os RECNOS da QER para receber na resposta do POST
@return lSucesso, lógico, indica sucesso na operação
/*/
METHOD SalvaRegistros(oItemAPI, oRegistro, aRecnosQER) CLASS ResultadosEnsaiosInspecaoDeEntradasAPI
	
	Local cCpsErro   := ""
	Local cEnsaio    := ""
	Local lSucesso   := .T.
	Local nMedicoes  := 0
	Local nRecnoErro := Nil

	If oItemAPI['testType'] != "N" .AND. oItemAPI['testType'] != "T"
		lSucesso := .F.
		Self:cErrorMessage    := STR0017 // "TIPO do item inválido"
		Self:cDetailedMessage := STR0018 + oItemAPI:toJson() //"Informe um TIPO de item válido, somente são válidos os tipos de item N ou T. Item recebido: "
	EndIf

	If lSucesso
		oRegistro["QER_DTMEDI"] := Iif(Empty(oRegistro["QER_DTMEDI"]), Date()         , oRegistro["QER_DTMEDI"])
		oRegistro["QER_HRMEDI"] := Iif(Empty(oRegistro["QER_HRMEDI"]), Left(Time(), 5), oRegistro["QER_HRMEDI"])
		oRegistro["QER_AMOSTR"] := Iif(Self:nRegistros == 1, 2, 1)
		lSucesso  := Self:oAPIManager:ValidaCamposObrigatorios(oRegistro, "|QER_ENSR|", @cCpsErro)
		If lSucesso
			lSucesso := Self:oAPIManager:SalvaRegistroDB("QER", @oRegistro, Self:aCamposQER, @nRecnoErro)
			If lSucesso                                    //Trecho de ELSE é Código Morto - Desvio já tratado no retorno de AtualizaCamposBancoNoRegistro
				aAdd(aRecnosQER, oRegistro["R_E_C_N_O_"])
			EndIf
		Else
			//"Dados para Integração Inválidos"
			//"Campo(s) obrigatório(s) inválido(s)"
			Self:cErrorMessage    := STR0008
			Self:cDetailedMessage := STR0020 + " '" + AllTrim(cCpsErro) + "': " + oRegistro:toJson()
		EndIf
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
		EndIf
	EndIf

Return lSucesso

/*/{Protheus.doc} ValidaEnsaiador
Valida se o Ensaiador está cadastrado na QAA
@author brunno.costa
@since  24/06/2022
@param 01 - oRegistro, objeto, registro JSON com os dados para gravação na QER
@return lSucesso, lógico, indica sucesso na validação
/*/
METHOD ValidaEnsaiador(oRegistro) CLASS ResultadosEnsaiosInspecaoDeEntradasAPI
	
	Local lSucesso   := .T.

	lSucesso := IIf(lSucesso, Self:oAPIManager:ValidaChaveEstrangeira("QAA", 1, xFilial("QAA") + AllTrim(oRegistro["QER_ENSR"])), lSucesso)
	If !lSucesso
		//"Ensaiador não cadastrado no cadastro de usuários (QAA)"
		Self:cErrorMessage    := STR0029 + "."
		Self:cDetailedMessage := STR0029 + ": " + AllTrim(oRegistro["QER_ENSR"])
	EndIf

Return lSucesso

/*/{Protheus.doc} ValidaUsuarioProtheus
Valida se o Usuário do Protheus está cadastrado no configurador
@author brunno.costa
@since  24/06/2022
@param 01 - oItemAPI, objeto, objeto Json com UM ITEM DOS REGISTROS JSON recebidos da API para conversão
@return lSucesso, lógico, indica sucesso na validação
/*/
METHOD ValidaUsuarioProtheus(oItemAPI) CLASS ResultadosEnsaiosInspecaoDeEntradasAPI
	
	Local lSucesso   := .T.

	lSucesso := Self:oAPIManager:ValidaUsuarioProtheus(oItemAPI["protheusLogin"])
	If !lSucesso
		//"Login de usuário não cadastrado no configurador do Protheus"
		Self:cErrorMessage    := STR0030 + "."
		Self:cDetailedMessage := STR0030 + ": " + oItemAPI["protheusLogin"]
	EndIf

Return lSucesso

/*/{Protheus.doc} ValidaPermissaoEnsaioNumerico
Valida se o ensaio de nRecnoQE7 permite recebimento de resultado Numérico
@author brunno.costa
@since  24/06/2022
@param 01 - nRecnoQE7, número, recno do ensaio nQE7P7
@return lSucesso, lógico, indica sucesso na validação
/*/
METHOD ValidaPermissaoEnsaioNumerico(nRecnoQE7) CLASS ResultadosEnsaiosInspecaoDeEntradasAPI
	
	Local cAlias   := Nil
	Local cFIlQE1  := xFilial("QE1")
	Local cFIlQE7  := xFilial("QE7")
    Local cQuery   := ""
	Local lSucesso := .T.
	Local oExec    := Nil

	Self:oCachePermissaoEnsaioNumerico := Iif(Self:oCachePermissaoEnsaioNumerico == Nil, JsonObject():New(), Self:oCachePermissaoEnsaioNumerico)

	If Self:oCachePermissaoEnsaioNumerico[cValToChar(nRecnoQE7)] == Nil
		cQuery += " SELECT QE7_ENSAIO "
		cQuery += " FROM " + RetSQLName("QE7")  + " QE7 "
		cQuery += 	" INNER JOIN "
		cQuery += 	" (SELECT QE1_ENSAIO "
		cQuery += 	" FROM " + RetSQLName("QE1")
		cQuery += 	" WHERE D_E_L_E_T_ = ' ' "
		cQuery += 		" AND QE1_CARTA  != 'TXT' "
		cQuery += 		" AND QE1_FILIAL = '" + cFIlQE1 + "') "
		cQuery += 	" QE1  "
		cQuery += 	" ON QE7_ENSAIO = QE1_ENSAIO "
		cQuery += " WHERE D_E_L_E_T_=' ' "
		cQuery += 	" AND QE7_FILIAL = '" + cFIlQE7 + "' "
		cQuery += 	" AND R_E_C_N_O_ = " + cValToChar(nRecnoQE7)

		Self:cErrorMessage := STR0007 + cQuery //"Erro na execução da query: "
		
		oExec := FwExecStatement():New(cQuery)
		cAlias := oExec:OpenAlias()

		Self:cErrorMessage := ""
		lSucesso := !(cAlias)->(Eof())
		Self:oCachePermissaoEnsaioNumerico[cValToChar(nRecnoQE7)] := lSucesso
		(cAlias)->(dbCloseArea())
		oExec:Destroy()
		oExec := nil 
	Else
		lSucesso := Self:oCachePermissaoEnsaioNumerico[cValToChar(nRecnoQE7)]
	EndIf

Return lSucesso

/*/{Protheus.doc} ValidaPermissaoEnsaioTexto
Valida se o ensaio de nRecnoQE8 permite recebimento de resultado Texto
@author brunno.costa
@since  24/06/2022
@param 01 - nRecnoQE8, número, recno do ensaio nQE8P8
@return lSucesso, lógico, indica sucesso na validação
/*/
METHOD ValidaPermissaoEnsaioTexto(nRecnoQE8) CLASS ResultadosEnsaiosInspecaoDeEntradasAPI
	
	Local cAlias   := Nil
	Local cFIlQE1  := xFilial("QE1")
	Local cFIlQE8  := xFilial("QE8")
    Local cQuery   := ""
	Local lSucesso := .T.
	Local oExec    := Nil

	cQuery += " SELECT QE8_ENSAIO "
	cQuery += " FROM " + RetSQLName("QE8")  + " QE8 "
	cQuery += 	" INNER JOIN "
	cQuery += 	" (SELECT QE1_ENSAIO "
	cQuery += 	" FROM " + RetSQLName("QE1")
	cQuery += 	" WHERE D_E_L_E_T_ = ' ' "
	cQuery += 		" AND QE1_CARTA  = 'TXT' "
	cQuery += 		" AND QE1_FILIAL = '" + cFIlQE1 + "') "
	cQuery += 	" QE1  "
	cQuery += 	" ON QE8_ENSAIO = QE1_ENSAIO "
	cQuery += " WHERE D_E_L_E_T_=' ' "
	cQuery += 	" AND QE8_FILIAL = '" + cFIlQE8 + "' "
	cQuery += 	" AND R_E_C_N_O_ = " + cValToChar(nRecnoQE8)

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
Valida se o ensaio de nRecnoQE8 permite recebimento de resultado Texto
@author brunno.costa
@since  24/06/2022
@param 01 - oItemAPI , objeto  , objeto Json com UM ITEM DOS REGISTROS JSON recebidos da API para conversão
@param 02 - nMedicoes, número  , retorna por referência a quantidade de medições do ensaio
@param 03 - cEnsaio  , caracter, retorna por referência o código do ensaio
@return lSucesso, lógico, indica sucesso na validação
/*/
METHOD ValidaQuantidadeMedicoesEnsaio(oItemAPI, nMedicoes, cEnsaio) CLASS ResultadosEnsaiosInspecaoDeEntradasAPI
	
	Local cAlias    := Nil
	Local cFIlQE1   := xFilial("QE1")
	Local cFIlQE7   := xFilial("QE7")
    Local cQuery    := ""
	Local lSucesso  := .T.
	Local nRecnoQE7 := oItemAPI["recnoTest"]
	Local oExec     := Nil

	If oItemAPI["measurements"] == Nil .OR. Len(oItemAPI["measurements"]) == 0
		lSucesso := .F.
	EndIf

	Self:oCacheQuantidadeMedicoesEnsaio := Iif(Self:oCacheQuantidadeMedicoesEnsaio == Nil, JsonObject():New(), Self:oCacheQuantidadeMedicoesEnsaio)
	If lSucesso .and. Self:oCacheQuantidadeMedicoesEnsaio[cValToChar(nRecnoQE7)] == Nil
		cQuery += " SELECT QE1_ENSAIO, "
		cQuery +=        " (CASE QE1_CARTA "
		cQuery +=           " WHEN 'XBR' THEN QE1_QTDE "
		cQuery +=           " WHEN 'XBS' THEN QE1_QTDE "
		cQuery +=           " WHEN 'XMR' THEN QE1_QTDE "
		cQuery +=           " WHEN 'HIS' THEN QE1_QTDE "
		cQuery +=           " WHEN 'NP ' THEN QE1_QTDE "
		cQuery +=           " WHEN 'P  ' THEN 3 "
		cQuery +=           " WHEN 'U  ' THEN 2 "
		cQuery +=           " ELSE 1 END) QE1_QTDE "
		cQuery += " FROM " + RetSQLName("QE7")  + " QE7 "
		cQuery += 	" INNER JOIN "
		cQuery += 	" (SELECT QE1_ENSAIO, QE1_CARTA, QE1_QTDE "
		cQuery += 	" FROM " + RetSQLName("QE1")
		cQuery += 	" WHERE D_E_L_E_T_ = ' ' "
		cQuery += 		" AND QE1_CARTA  != 'TXT' "
		cQuery += 		" AND QE1_FILIAL = '" + cFIlQE1 + "') "
		cQuery += 	" QE1  "
		cQuery += 	" ON QE7_ENSAIO = QE1_ENSAIO "
		cQuery += " WHERE D_E_L_E_T_=' ' "
		cQuery += 	" AND QE7_FILIAL = '" + cFIlQE7 + "' "
		cQuery += 	" AND R_E_C_N_O_ = " + cValToChar(nRecnoQE7)

		Self:cErrorMessage := STR0007 + cQuery //"Erro na execução da query: "
		
		oExec := FwExecStatement():New(cQuery)
		cAlias := oExec:OpenAlias()
		
		Self:cErrorMessage := ""
		lSucesso  := Iif(lSucesso, !(cAlias)->(Eof())                                 , lSucesso)
		lSucesso  := Iif(lSucesso, (cAlias)->QE1_QTDE == Len(oItemAPI["measurements"]), lSucesso)
		nMedicoes := (cAlias)->QE1_QTDE
		cEnsaio   := (cAlias)->QE1_ENSAIO
		Self:oCacheQuantidadeMedicoesEnsaio[cValToChar(nRecnoQE7)] := {(cAlias)->QE1_QTDE, (cAlias)->QE1_ENSAIO}
		(cAlias)->(dbCloseArea())
		oExec:Destroy()
		oExec := nil 
	Else
		lSucesso  := Iif(lSucesso, Self:oCacheQuantidadeMedicoesEnsaio[cValToChar(nRecnoQE7), 1] == Len(oItemAPI["measurements"]), lSucesso)
		nMedicoes := Self:oCacheQuantidadeMedicoesEnsaio[cValToChar(nRecnoQE7), 1]
		cEnsaio   := Self:oCacheQuantidadeMedicoesEnsaio[cValToChar(nRecnoQE7), 2]
	EndIf

Return lSucesso

/*/{Protheus.doc} AtualizaStatusQEKComRecno
Atualiza Status do Registro na QEK com base em RECNO da QEK
@author brunno.costa
@since  16/08/2022
@param 01 - nRecnoQEK, número, recno para posicionamento na QEK
/*/
METHOD AtualizaStatusQEKComRecno(nRecnoQEK) CLASS ResultadosEnsaiosInspecaoDeEntradasAPI
	
	Local cLaudo   := " "
	Local lMedicao := .F.
	Local oLaudos    := QIELaudosEnsaios():New()
	
	Self:lProcessaRetorno := .F.
	Self:RetornaResultadosInspecao(nRecnoQEK, "", Nil, Nil, Nil, "", @lMedicao)
	QEK->(DbGoTo(nRecnoQEK))
	
	If QEK->(!Eof())
		oLaudos:AtualizaFlagLegendaInspecao(cLaudo, lMedicao, .F., Self:cLogin)
	EndIf
	
	QEK->(DbCloseArea())
	
Return

/*/{Protheus.doc} AtualizaStatusQEKComChaveQEK
Atualiza Status do Registro na QEK com base em Chave do Registro da QEK
@author brunno.costa
@since  18/11/2022
@param 01 - cChaveQEK, caracter, chave do registro na QEK
/*/
METHOD AtualizaStatusQEKComChaveQEK(cChaveQEK) CLASS ResultadosEnsaiosInspecaoDeEntradasAPI
	Local nRecnoQEK := 0
	IF !Empty(cChaveQEK)
		QEK->(DbSetOrder(11))
		If QEK->(DbSeek(xFilial("QEK")+cChaveQEK))
			nRecnoQEK := QEK->(Recno())
		EndIf
		Self:AtualizaStatusQEKComRecno(nRecnoQEK)
	EndIf
Return

/*/{Protheus.doc} ExisteLaudoRelacionadoAoPost
Indica se existe laudo relacionado aos dados do POST
@author brunno.costa
@since  27/11/2022
@param 01 - oDadosJson, objeto, objeto Json com os dados JSON recebidos da API para conversão
@return lExiste, lógico, indica se existe laudo (.T.) relacionado aos dados do POST 
(ou .T. TAMBÉM em caso de falha, para interromper processo e exibir mensagem de falha)
/*/
METHOD ExisteLaudoRelacionadoAoPost(oDadosJson) CLASS ResultadosEnsaiosInspecaoDeEntradasAPI
	
	Local aRecsQE7    := Nil
	Local aRecsQE8    := Nil
	Local aRecsQEK    := Nil
	Local bErrorBlock := Nil
	Local cAlias      := Nil
    Local cQuery      := ""
	Local lExiste     := .F.
    Local oExec       := Nil

	Self:oAPIManager := QualityAPIManager():New(Nil, Self:oWSRestFul)
	bErrorBlock := ErrorBlock({|e| Self:oAPIManager:ErrorBlock(e, e:Description), lExiste := .T., Break(e)})

	Self:IdentificaRecnosInspecoesEEnsaios(oDadosJson, @aRecsQEK, @aRecsQE7, @aRecsQE8)
	
	BEGIN SEQUENCE

		cQuery += " SELECT DISTINCT "
		cQuery +=         " COALESCE(LAUDO_GERAL.QEL_PRODUT, LAUDO_LABORATORIO.QEL_PRODUT) TEM_LAUDO "
		cQuery +=  " FROM  "


		cQuery += " (SELECT "
		cQuery +=         " QEK_FORNEC, "
		cQuery +=         " QEK_LOJFOR, "
		cQuery +=         " QEK_PRODUT, "
		cQuery +=         " QEK_REVI, "
		cQuery +=         " QEK_NTFISC, "
		cQuery +=         " QEK_SERINF, "
		cQuery +=         " QEK_ITEMNF, "
		cQuery +=         " QEK_TIPONF, "
		cQuery +=         " QEK_LOTE, "
		cQuery +=         " QEK_NUMSEQ, "
		cQuery +=         " QEK_DTENTR, "
		cQuery += 		  " QE8_LABOR, "
		cQuery += 		  " QEK_SITENT "
		cQuery += " FROM (SELECT DISTINCT QEK_FORNEC, QEK_LOJFOR, QEK_PRODUT, QEK_REVI, QEK_NTFISC, QEK_SERINF, QEK_ITEMNF, QEK_TIPONF, QEK_LOTE, QEK_NUMSEQ, QEK_DTENTR, QEK_SITENT, QE8_LABOR "
		cQuery +=       " FROM (SELECT QEK_FORNEC, QEK_LOJFOR, QEK_PRODUT, QEK_REVI, QEK_NTFISC, QEK_SERINF, QEK_ITEMNF, QEK_TIPONF, QEK_LOTE, QEK_NUMSEQ, QEK_DTENTR, QEK_SITENT "
		cQuery +=             " FROM " + RetSQLName("QEK")
		cQuery +=             " WHERE (D_E_L_E_T_ = ' ') "
		cQuery +=               " AND (R_E_C_N_O_ IN " + FormatIn(ArrToKStr(aRecsQEK),"|") + ") "
		cQuery +=               " AND (QEK_FILIAL = '" + xFilial("QEK") + "') ) QEK "

		cQuery += " INNER JOIN "
		cQuery += " ( "
		If Len(aRecsQE8) > 0
			cQuery += " SELECT QE8_PRODUT AS PRODUTO, QE8_REVI AS REVISAO, QE8_LABOR "
			cQuery += " FROM " + RetSQLName("QE8") + " "
			cQuery += " WHERE D_E_L_E_T_ = ' ' "
			cQuery += " AND (QE8_FILIAL = '" + xFilial("QE8") + "') "
			cQuery += " AND (R_E_C_N_O_ IN " + FormatIn(ArrToKStr(aRecsQE8),"|") + ") "
		EndIf
		If Len(aRecsQE7) > 0 .AND. Len(aRecsQE8) > 0
			cQuery += " UNION "
		EndIf
		If Len(aRecsQE7) > 0
			cQuery += " SELECT QE7_PRODUT AS PRODUTO, QE7_REVI AS REVISAO, QE7_LABOR AS QE8_LABOR "
			cQuery += " FROM " + RetSQLName("QE7") + " "
			cQuery += " WHERE D_E_L_E_T_ = ' ' "
			cQuery += " AND (QE7_FILIAL = '" + xFilial("QE7") + "') "
			cQuery += " AND (R_E_C_N_O_ IN " + FormatIn(ArrToKStr(aRecsQE7),"|") + ") "
		EndIf
		cQuery += " ) FILTROLAB ON QEK.QEK_PRODUT = FILTROLAB.PRODUTO "
		cQuery +=            " AND QEK.QEK_REVI   = FILTROLAB.REVISAO "
		
		cQuery += " ) DADOS) INSPECOES "


		cQuery += " LEFT JOIN (SELECT DISTINCT
		cQuery +=                   " QEL_FORNEC, QEL_LOJFOR, QEL_PRODUT, QEL_NISERI, QEL_TIPONF, QEL_LOTE, QEL_NUMSEQ, QEL_DTENTR, QEL_LABOR "
		cQuery +=            " FROM " + RetSQLName("QEL") + " "
		cQuery +=            " WHERE (D_E_L_E_T_ = ' ') "
		cQuery +=            " AND (QEL_FILIAL = '" + xFilial("QEL") + "') "
		cQuery +=            " AND (QEL_LAUDO <> ' ') ) LAUDO_LABORATORIO "
		cQuery += " ON " + Self:oQueryManager:MontaRelationArraysCampos("INSPECOES"        , {"QEK_FORNEC","QEK_LOJFOR","QEK_PRODUT","QEK_NTFISC+QEK_SERINF+QEK_ITEMNF","QEK_TIPONF","QEK_LOTE","QEK_DTENTR","QE8_LABOR"},;
			                                                            "LAUDO_LABORATORIO", {"QEL_FORNEC","QEL_LOJFOR","QEL_PRODUT","QEL_NISERI"                      ,"QEL_TIPONF","QEL_LOTE","QEL_DTENTR","QEL_LABOR"})

		If QIEReinsp()
			cQuery += " AND INSPECOES.QEK_NUMSEQ = LAUDO_LABORATORIO.QEL_NUMSEQ "
		EndIf

		cQuery += " LEFT JOIN (SELECT DISTINCT "
		cQuery +=                   " QEL_FORNEC, QEL_LOJFOR, QEL_PRODUT, QEL_NISERI, QEL_TIPONF, QEL_LOTE, QEL_NUMSEQ, QEL_DTENTR "
		cQuery +=       " FROM " + RetSQLName("QEL")
		cQuery +=       " WHERE (D_E_L_E_T_ = ' ') "
		cQuery +=       "   AND (QEL_FILIAL = '" + xFilial("QEL") + "') "
		cQuery +=       "   AND (QEL_LAUDO <> ' ') "
		cQuery +=       "   AND (QEL_LABOR = ' ') ) LAUDO_GERAL "
		cQuery += " ON " + Self:oQueryManager:MontaRelationArraysCampos("INSPECOES"  , {"QEK_FORNEC","QEK_LOJFOR","QEK_PRODUT","QEK_NTFISC+QEK_SERINF+QEK_ITEMNF","QEK_TIPONF","QEK_LOTE","QEK_DTENTR"},;
		                                                                "LAUDO_GERAL", {"QEL_FORNEC","QEL_LOJFOR","QEL_PRODUT","QEL_NISERI"                      ,"QEL_TIPONF","QEL_LOTE","QEL_DTENTR"})

		If QIEReinsp()
			cQuery += " AND INSPECOES.QEK_NUMSEQ = LAUDO_GERAL.QEL_NUMSEQ "
		EndIf

		cQuery += " WHERE COALESCE(LAUDO_GERAL.QEL_PRODUT, LAUDO_LABORATORIO.QEL_PRODUT) IS NOT NULL "


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
Identifica os Recnos da QEK, QE7 e QE8 relacionados a inspeção
@author brunno.costa
@since  27/11/2022
@param 01 - oDadosJson, objeto, objeto Json com os dados JSON recebidos da API para conversão
@param 02 - aRecsQEK  , array , retorna por referência relação de RECNOS da QEK relacionados
@param 03 - aRecsQE7  , array , retorna por referência relação de RECNQE7da QP7 relacionados
@param 04 - aRecsQE8  , array , retorna por referência relação de RECNQE8da QP8 relacionados
/*/
METHOD IdentificaRecnosInspecoesEEnsaios(oDadosJson, aRecsQEK, aRecsQE7, aRecsQE8) CLASS ResultadosEnsaiosInspecaoDeEntradasAPI

	Local nIndReg    := Nil
	Local nRegistros := Len(oDadosJson["items"])
	Local oItemAPI   := Nil

	Default aRecsQEK := {}
	Default aRecsQE7 := {}
	Default aRecsQE8 := {}

	If nRegistros > 0
		For nIndReg := 1 to nRegistros
			oItemAPI := oDadosJson["items"][nIndReg]
			aAdd(aRecsQEK, oItemAPI["recnoInspection"])
			If oItemAPI['testType'] == "N"
				aAdd(aRecsQE7, oItemAPI["recnoTest"])
			Else
				aAdd(aRecsQE8, oItemAPI["recnoTest"])
			EndIf
		Next nIndReg
	EndIf
Return 

/*/{Protheus.doc} RetornaTamanhoResultadoTipoTexto
Retorna o tamanho permitido para resultados do tipo texto
@author brunno.costa
@since  08/05/2024
/*/
METHOD RetornaTamanhoResultadoTipoTexto() CLASS ResultadosEnsaiosInspecaoDeEntradasAPI
     
	Local cResp     := ""
	Local oResponse := JsonObject():New()
	
	oResponse['result' ] := GetSx3Cache("QEQ_MEDICA", "X3_TAMANHO")

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
@param 01 - oDadosJson, objeto, objeto Json com os dados JSON recebidos da API para conversão e gravação
/*/
METHOD RevisaEnsaiosCalculados(oDadosJson, oDadosCalc) CLASS ResultadosEnsaiosInspecaoDeEntradasAPI

	Local aPendentes            := {}
	Local cEnsaio               := ""
	Local lConsideraDB          := .T.
	Local lDigitRelacCalc       := .F.
	Local nIndAmostra           := 0
	Local nIndEnsaio            := 0
	Local nIndPend              := 0
	Local nMedicoes             := 0
	Local oItemAPI              := Nil
	Local oQIEEnsaiosCalculados := QIEEnsaiosCalculados():New(oDadosJson["items"][1]["recnoInspection"], oDadosJson["items"], lConsideraDB)

	//Valida se existe pelo menos um ensaio numérico relacionado a ensaio calculado
	For nIndEnsaio := 1 To Len(oQIEEnsaiosCalculados:aEnsaiosCalculados)
		
		If    aScan(oDadosJson["items"], {|oItemAPI| "#"+Padr(SubStr(AllTrim(oItemAPI['testID']), 1, 8), 8)+"#";
		                                              $ oQIEEnsaiosCalculados:aEnsaiosCalculados[nIndEnsaio, 'formula']}) > 0
			lDigitRelacCalc := .T.
			Exit
		EndIf

	Next nIndEnsaio

	If lDigitRelacCalc
		For nIndEnsaio := 1 To Len(oQIEEnsaiosCalculados:aEnsaiosCalculados)
			cEnsaio := AllTrim(oQIEEnsaiosCalculados:aEnsaiosCalculados[nIndEnsaio, 'testID'])

			If aScan(oDadosJson["items"], {|oItemAPI| AllTrim(oItemAPI['testID']) == cEnsaio}) <= 0
				aAdd(aPendentes, {nIndEnsaio, cEnsaio})
			EndIf

		Next nIndEnsaio
	EndIf

	If Len(aPendentes) > 0

		oQIEEnsaiosCalculados:ProcessaEnsaiosCalculados()

		oItemAPI                        := JsonObject():new()
		oItemAPI['attachments']         := {}
		oItemAPI['nonConformitiesList'] := {}
		oItemAPI['textDetail']          := ""
		oItemAPI['testType']            := "N"
		oItemAPI['type']                := "C"
		oItemAPI["recnoInspection"]     := Self:nRecnoQEK

		For nIndPend := 1 To Len(aPendentes)

			nIndEnsaio := aPendentes[nIndPend, 1]
			
			For nIndAmostra := 1 to Len(oQIEEnsaiosCalculados:aEnsaiosCalculados[nIndEnsaio, 'results'])
				nMedicoes := Len(oQIEEnsaiosCalculados:aEnsaiosCalculados[nIndEnsaio]['results'][nIndAmostra])
				oQIEEnsaiosCalculados:TrataRegistroParaInclusao(@oDadosCalc, oItemAPI, nIndEnsaio, nIndAmostra, nMedicoes)
			Next nIndAmostra

		Next nIndEnsaio

	EndIf
	
Return 

/*/{Protheus.doc} ModoAcessoResultados
Indica o modo de acesso do usuário aos resultados das amostras do QIE
@author brunno.costa
@since  23/05/2022
@param 01 - cLogin , caracter, login do usuário para validação das permissões de acesso
@return cRetorno, caracter, indica o modo de acesso do usuário aos resultados das amostras do QIP:
							1=Com Acesso;
							2=Sem Acesso;
							3=Apenas Consulta
/*/
METHOD ModoAcessoResultados(cLogin) CLASS ResultadosEnsaiosInspecaoDeEntradasAPI
     
    Local cAlias   := Nil
    Local cQuery   := Nil
	Local cRetorno := "1"
	Local lExiste  := !Empty(GetSx3Cache("QAA_INSPEN", "X3_TAMANHO"))
	
	If lExiste
		cQuery :=   " SELECT COALESCE( QAA_INSPEN, '1') QAA_INSPEN "
		cQuery +=   " FROM " + RetSQLName("QAA") + " "
		cQuery +=   " WHERE (D_E_L_E_T_ = ' ') "
		cQuery +=     " AND (QAA_FILIAL = '" + xFilial("QAA") + "') "
		cQuery +=     " AND (UPPER(RTRIM(QAA_LOGIN)) = " + FwQtToChr(AllTrim(Upper(cLogin))) +" ) "

		cAlias := Self:oAPIManager:oQueryManager:executeQuery(cQuery)

		If !Empty((cAlias)->QAA_INSPEN)
			cRetorno := Alltrim( (cAlias)->QAA_INSPEN )
		EndIf

		(cAlias)->(dbCloseArea())
	EndIF

Return cRetorno

/*/{Protheus.doc} RespondeAPIModoAcessoResultados
Responde via API se o usuário pode incluir resultados no QIE
@author brunno.costa
@since  10/12/2024
@param 01 - cLogin , caracter, login do usuário para validação das permissões de acesso
@param 02 - cEnsaio, caracter, código do ensaio para validação das permissões de acesso
/*/
METHOD RespondeAPIModoAcessoResultados(cLogin, cEnsaio) CLASS ResultadosEnsaiosInspecaoDeEntradasAPI
     
	Local cModoAcesso := Self:ModoAcessoResultados(cLogin)
	Local oResponse   := JsonObject():New()

	Default cEnsaio   := ""
	
	//STR0062 - 'Acesso negado. Solicite liberação no campo'
	//STR0063 - ' do seu cadastro de usuário (QIEA050) do Protheus.'
	
	If     cModoAcesso == '1'
		oResponse['accessmode'] := 'insert'
	ElseIf cModoAcesso == '2'
		oResponse['accessmode'] := 'noAccess'
		oResponse['message'   ] := STR0062 + ' "' + AllTrim(GetSx3Cache("QAA_INSPEN","X3_TITULO")) + '" (QAA_INSPEN)' + STR0063
	ElseIf cModoAcesso == '3'
		oResponse['accessmode'] := 'onlyView'
		oResponse['message'   ] := STR0062 + ' "' + AllTrim(GetSx3Cache("QAA_INSPEN","X3_TITULO")) + '" (QAA_INSPEN)' + STR0063
	EndIf

	//Valida se o usuário possui permissão para incluir resultados no ensaio
	//STR0082 - Nivel atual incompatível com o Ensaio
	If !Empty(cEnsaio) .And. cModoAcesso != '2'
		If !Self:ValidaPermissaoDoUsuarioParaOEnsaio(cLogin, cEnsaio)
			oResponse['accessmode'] := 'onlyView'
			oResponse['message'   ] := STR0062 + ' "' + AllTrim(GetSx3Cache("QAA_NIVEL","X3_TITULO")) + '" (QAA_NIVEL)' + STR0063 + " " + STR0082 + " '" + AllTrim(cEnsaio) + "'."
		EndIf
	EndIf

	oResponse['hasNext'          ] := .F.
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
Method ValidaPermissaoDoUsuarioParaOEnsaio(cLogin, cEnsaio) CLASS ResultadosEnsaiosInspecaoDeEntradasAPI

	Local cAlias   := Nil
	Local cQuery   := Nil
	Local lPermite := .T.
	
	cQuery :=   " SELECT COUNT(*) QTD "
	cQuery +=   " FROM " + RetSQLName("QAA") + " QAA "
	cQuery +=   " INNER JOIN " + RetSQLName("QE1") + " QE1 "
	cQuery +=   " ON "
	cQuery +=      Self:oAPIManager:oQueryManager:MontaQueryComparacaoFiliais("QAA", "QE1","QAA", "QE1") + " AND "
	cQuery +=      " COALESCE(NULLIF(QAA.QAA_NIVEL, ''), '00') >= COALESCE(NULLIF(QE1.QE1_NIENSR, ''), '00') "

	cQuery += " WHERE (QAA.QAA_FILIAL = '" + xFilial("QAA") + "') "
	cQuery +=   " AND (UPPER(RTRIM(QAA.QAA_LOGIN)) = " + FwQtToChr(AllTrim(Upper(cLogin))) + ") "
	cQuery +=   " AND (QE1.QE1_ENSAIO = '" + cEnsaio + "') "
	cQuery +=   " AND (QAA.D_E_L_E_T_ = ' ') "
	cQuery +=   " AND (QE1.D_E_L_E_T_ = ' ') "

	cAlias := Self:oAPIManager:oQueryManager:executeQuery(cQuery)

	lPermite := (cAlias)->QTD > 0
	
	(cAlias)->(dbCloseArea())

Return lPermite

/*/{Protheus.doc} CriaAliasListaInstrumentosRelacionadosAmostra
Retorna a lista de instrumentos de medição vinculados a amostra de resultados
@author thiago.rover
@since  06/05/2025
@param 01 - nRecnoQER, número, recno do ensaio na QER
@param 02 - lExclusao, lógico, indica se é para exclusão
@return cAlias, caracter, alias da consulta SQL
/*/
METHOD CriaAliasListaInstrumentosRelacionadosAmostra(nRecnoQER, lExclusao) CLASS ResultadosEnsaiosInspecaoDeEntradasAPI

    Local cAlias        := ""
    Local cQuery        := ""

	Default lExclusao := .F.

    // Construção da consulta SQL
    cQuery := "SELECT "
    cQuery +=    " QM2.QM2_VALDAF, "
    cQuery +=    " QM2.QM2_DESCR, "
    cQuery +=    " QM2.QM2_INSTR, "
    cQuery +=    " QM2.QM2_REVINS, "
	cQuery +=    " QET.R_E_C_N_O_ "
    cQuery += " FROM "       + RetSQLName("QET") + " QET "
    cQuery += " INNER JOIN " + RetSQLName("QM2") + " QM2 "
    cQuery +=  " ON " + Self:oAPIManager:oQueryManager:montaQueryComparacaoFiliais("QET", "QM2", "QET", "QM2")
	cQuery +=   " AND QET.QET_INSTR  = QM2.QM2_INSTR "
	cQuery +=   " AND QET.QET_REVINS = QM2.QM2_REVINS "
    cQuery +=   " AND QM2.D_E_L_E_T_ = ' ' "
    cQuery += " INNER JOIN " + RetSQLName("QER") + " QER "
	cQuery +=   " ON " + Self:oAPIManager:oQueryManager:montaQueryComparacaoFiliais("QET", "QER", "QET", "QER")
	cQuery +=   " AND QET.QET_CODMED = QER.QER_CHAVE "
	
	If !lExclusao
    	cQuery +=   " AND QER.D_E_L_E_T_ = ' ' "
	EndIf

    cQuery += " WHERE QER.R_E_C_N_O_ = " + cValToChar(nRecnoQER)
    cQuery +=   " AND QET.D_E_L_E_T_ = ' ' "

    // Execução da consulta
    cAlias := Self:oApiManager:oQueryManager:executeQuery(cQuery)

Return cAlias

/*/{Protheus.doc} CriaAliasRepeticaoInstrumentos
Retorna a lista de instrumentos de medição para repetição da primeira amostra de resultados
@author thiago.rover
@since  13/05/2025
@param 01 - nRecnoQEK, número, recno da inspeção relacionada na QEK
@param 02 - cIDTest  , caracter, ID do ensaio relacionado
@return cAlias, caracter, alias da consulta SQL
/*/
METHOD CriaAliasRepeticaoInstrumentos(nRecnoQEK, cIDTest) CLASS ResultadosEnsaiosInspecaoDeEntradasAPI

    Local cAliasResult := ""
	Local cAliasReturn := ""
	Local nRecnoQER    := 0
	
	nRecnoQEK := Iif(ValType(nRecnoQEK)=="C", Val(nRecnoQEK), nRecnoQEK)
	nRecnoQEK := Iif(ValType(nRecnoQEK)!="N", -1            , nRecnoQEK)

	If nRecnoQEK > 0 .And. !Empty(cIDTest)
		If (Self:CriaAliasResultadosInspecaoPorEnsaio(nRecnoQEK, "measurementDate+measurementTime", cIDTest, 1, 1, "*", @cAliasResult, Self:oAPIManager))
			If !Empty(cAliasResult) .AND. Select(cAliasResult) > 0
				nRecnoQER := (cAliasResult)->RECNOQER
				(cAliasResult)->(dbCloseArea())
			EndIf
		EndIf

		If nRecnoQEK > 0
			// Execução da consulta
			cAliasReturn := Self:CriaAliasListaInstrumentosRelacionadosAmostra(nRecnoQER, .F.)
		EndIf
	EndIf

Return cAliasReturn

/*/{Protheus.doc} QIECASVAPI
Processamento assíncrono dos ensaios calculados
@type  Function
@author brunno.costa
@since  02/04/2025
@param 01 - cEmpAux  , caracter, empresa para abertura do ambiente
@param 02 - cFilAux  , caracter, filial para abertura do ambiente
@param 03 - cJsonData, caracter, dados json para reprocessamento
/*/
Function QIECASVAPI(cEmpAux, cFilAux, cJsonData)

	Local oAPI      := Nil
	local cThReadID	:= threadID()

	FWLogMsg('INFO',, 'QIECASVAPI', "QIECASVAPI", '', '01', "QIECASVAPI - Inicio - " + Time() + " - " + str(cThReadID) , 0, 0, {})

	//Seta job para nao consumir licenças
	RpcSetType(3)

	// Seta job para empresa filial desejada
	RpcSetEnv( cEmpAux, cFilAux,,, 'QIE')
	
	oAPI := ResultadosEnsaiosInspecaoDeEntradasAPI():New(Nil)
	oAPI:lResponseAPI := .F.
	oAPI:Salva(cJsonData)

	RpcClearEnv()

	FWLogMsg('INFO',, 'CTBXSEM', "QIECASVAPI", '', '01', "QIECASVAPI - Termino - " + Time() + " - " + str(cThReadID) , 0, 0, {})
	
Return


/*/{Protheus.doc} ListaInstrumentosDeMedicao
Retorna a lista de instrumentos de medição vinculados a amostra de resultados
@author thiago.rover
@since  01/05/2025
@param 01 - nRecnoQER, número, recno do ensaio na QER
/*/
METHOD ListaInstrumentosRelacionadosAmostra(nRecnoQER) CLASS ResultadosEnsaiosInspecaoDeEntradasAPI

    Local cAlias   := Self:CriaAliasListaInstrumentosRelacionadosAmostra(nRecnoQER)
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
@author thiago.rover
@since  21/05/2025
@param 01 - nRecnoQER, número, recno do ensaio na QER
/*/
METHOD ExcluiInstrumentosRelacionadosAmostra(nRecnoQER) CLASS ResultadosEnsaiosInspecaoDeEntradasAPI

    Local cAlias := Self:CriaAliasListaInstrumentosRelacionadosAmostra(nRecnoQER, .T.)

    While !(cAlias)->(Eof())
		QET->(DbGoto((cAlias)->R_E_C_N_O_))
		
		RecLock("QET",.F.)
		QET->(dbDelete())
		MsUnLock()

		(cAlias)->(DbSkip())
	EndDo

Return 


/*/{Protheus.doc} RetornaRepeticaoInstrumentosPrimeiraAmostra
Retorna a lista de instrumentos de medição vinculados a amostra de resultados
@author thiago.rover
@since  13/05/2025
@param 01 - nRecnoQEK   , número  , recno do ensaio na QEK
@param 02 - cIDTest     , caracter, ID do ensaio relacionado
@return lSucesso, lógico, indica se respondeu com sucesso a lista de instrumentos relacionados
/*/
METHOD RetornaRepeticaoInstrumentosPrimeiraAmostra(nRecnoQEK, cIDTest) CLASS ResultadosEnsaiosInspecaoDeEntradasAPI

    Local cAlias   := Self:CriaAliasRepeticaoInstrumentos(nRecnoQEK, cIDTest)
	Local lSucesso := .F.

    // Processamento dos resultados
    If !Empty(cAlias)
		Self:MapeiaCamposListaInstrumento()
        lSucesso := Self:oAPIManager:ProcessaListaResultados(cAlias)

		(cAlias)->(dbCloseArea())
    EndIf

Return lSucesso

/*/{Protheus.doc} MapeiaCamposListaInstrumento
Mapeia os Campos Lista de Instrumento de Medição
@author thiago.rover
@since  01/05/2025
@param 01 - cCampos, String, string com os campos [nPosCPS_Titulo_API] para consideração separados por vírgula
@return aMapaCampos, Array , {{lConsidera, Titulo Interface, Título API, Campo Protheus, Tipo, Tamanho, Decimal}, ...}
                             {{nPosCPS_Considera, ..., nPosCPS_Decimal}, ...}
/*/
METHOD MapeiaCamposListaInstrumento() CLASS ResultadosEnsaiosInspecaoDeEntradasAPI

    Local aMapaCampos := {}

	aadd(aMapaCampos, {.F., "Descricao"       , "description"   , "QM2_DESCR" , "C" , GetSx3Cache("QM2_DESCR" ,"X3_TAMANHO"), 0,})
    aadd(aMapaCampos, {.F., "Codigo"          , "code"          , "QM2_INSTR" , "C" , GetSx3Cache("QM2_INSTR" ,"X3_TAMANHO"), 0,})
	aadd(aMapaCampos, {.F., "Revisao"         , "revision"      , "QM2_REVINS", "C" , GetSx3Cache("QM2_REVINS","X3_TAMANHO"), 0,})
	aadd(aMapaCampos, {.F., "Val.Calibracao"  , "validate"      , "QM2_VALDAF", "D" , GetSx3Cache("QM2_VALDAF","X3_TAMANHO"), 0,})
	
	Self:oAPIManager := QualityAPIManager():New(aMapaCampos, Self:oWSRestFul)
	Self:oAPIManager:MarcaCamposConsiderados("*", aMapaCampos, nPosCPS_Titulo_API)

Return aMapaCampos

/*/{Protheus.doc} EAPPQIEQMT
Função para definição de existência no RPO dos fontes de integração do APP Minha Produção do SIGAQIP com o SIGAQMT
@author thiago.rover
@since  01/05/2025
/*/
Function EAPPQIEQMT()
Return




