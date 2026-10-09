#INCLUDE "TOTVS.CH"
#INCLUDE "QLTMONITORDEF.CH"
#INCLUDE "DocumentosVencidos.CH"

/*/{Protheus.doc} DocumentosVencidos
Classe para prover os dados do Monitor Documentos Vencidos do Módulo Controle de Documentos (SIGAQDO)
@type Class
@author brunno.costa
@since 23/10/2023
@version P12.1.2310
@return Nil
/*/
Class DocumentosVencidos FROM LongNameClass
	
    //Métodos Padrões
    Static Method BuscaDados(oFiltros, cTipo, cSubTipo)
	Static Method BuscaDetalhes(oFiltro, nPagina)
	Static Method CargaMonitor()
    Static Method ValidaPropriedades(oFiltros, lVencido)

    //Métodos Internos
    Static Method AdicionaColunasDetalhes(lExpResult)
    Static Method ConverteEmNumero(oValor)
    Static Method MontaComboMeuDepartamento(oParametro)
    Static Method MontaComboPeriodos(oParametro)
    Static Method MontaComboUsuarioLogado(oParametro)
    Static Method MontaJsonInfo(oJson, nQtde, aSemaforo, lVencido)
    Static Method MontaJsonVelocimetro(oJson, nQtde, aSemaforo)
    Static Method MontaWhereQuery(oFiltros, dDataIni, dDataFim)
    Static Method RetornaCorSemaforo(nQtde, aSemaforo)
    Static Method RetornaPeriodoInicial(cFiltro, dDataFim, nPersonal)
    Static Method SetaPropriedadeFilial(cCodigo, cTitulo)
    Static Method SetaPropriedadeLookupTabela(oCarga, cCodigo, cLabel, lSelecMult, cTabela, cCampoCod, cCampoDsc, cOrdFil)
EndClass

/*/{Protheus.doc} CargaMonitor
Realiza a carga do Monitor padrão na base de dados
@type Method
@author brunno.costa
@since 23/10/2023
@version P12.1.2310
@return lRet, logico, Indica se conseguiu realizar a carga
/*/
Method CargaMonitor() Class DocumentosVencidos
    Local lRet        := .T.
    Local nIndTag     := 0
    Local oCarga      := PCPMonitorCarga():New()
    Local oExemplo    := JsonObject()     :New()
    Local oParametros := JsonObject()     :New()
        
    If !PCPMonitorCarga():monitorAtualizado("DocumentosVencidos")
        
        oCarga:setaTitulo(STR0001) //"Documentos Vencidos"
        oCarga:setaObjetivo(STR0002) //"Apresentar o número de documentos vencidos do módulo Controle de Documentos (SIGAQDO) do usuário logado ou de todos os usuários, do meu departamento ou para todos os departamento, dentro de um período configurado, utilizando o conceito de semáforo para indicar os níveis Aceitável, Atenção e Crítico."
        oCarga:setaAgrupador(STR0003) //"Qualidade"
        oCarga:setaFuncaoNegocio("DocumentosVencidos")
        oCarga:setaTiposPermitidos("chart;info")
        oCarga:setaTiposGraficoPermitidos("gauge")
        oCarga:setaTipoPadrao("info")
        oCarga:setaTipoGraficoPadrao("")
        oCarga:setaTipoDetalhe("detalhe")

        oExemplo := DocumentosVencidos():MontaJsonInfo(@oExemplo,2,{"1","3"},"2")

        oExemplo["tags"] := {}
        PCPMonitorUtils():AdicionaTagMonitor(oExemplo["tags"],@nIndTag,"po-icon-calendar",DtoC(dDataBase-180) + " - " + DtoC(dDataBase))

        oCarga:setaExemploJsonTexto(.F.,oExemplo)

        //STR0004 - "Filial"
        DocumentosVencidos():SetaPropriedadeFilial(@oCarga, "01_FILIAL", STR0004 + "*")

        //STR0005 - Atenção
        //STR0006 - Urgente
        //STR0007 - Semáforo
        oCarga:setaPropriedade("02_SEMAFORO", STR0005 + ";" + STR0006, STR0007 + " (" + STR0005 + ";" + STR0006 + ")*",1,30,0,"po-lg-6 po-xl-6 po-md-6 po-sm-12",/*oEstilos*/,/*cIcone*/,/*oParametros*/)

        //STR0008 - "Período de Vencimento"
        oCarga:setaPropriedade("03_TIPOPERIODO","",STR0008 + "*",4,,,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,DocumentosVencidos():MontaComboPeriodos(oParametros["03_TIPOPERIODO"]))

        //STR0009 - "Usuário Logado"
        oCarga:setaPropriedade("04_USUARIO_LOGADO" ,"",STR0009,4,,,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,DocumentosVencidos():MontaComboUsuarioLogado(oParametros["04_USUARIO_LOGADO"]))
        
        //STR0010 - STR0011 - "Período personalizado (anos)"
        oCarga:setaPropriedade("05_PERIODO_PERSONALIZADO","9",STR0010 + " (" + STR0011 + ")",2,1,0,"po-lg-6 po-xl-6 po-md-6 po-sm-12")

        //STR0012 - "Meu Departamento"
        oCarga:setaPropriedade("06_MEU_DEPARTAMENTO" ,"",STR0012,4,,,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,DocumentosVencidos():MontaComboMeuDepartamento(oParametros["06_MEU_DEPARTAMENTO"]))

        //STR0013 - "Departamentos Emissores"
        DocumentosVencidos():SetaPropriedadeLookupTabela(@oCarga, "07_DEPARTAMENTOS_EMISSORES",STR0013,.T.,"QAD","QAD_CUSTO","QAD_DESC",1)
        
        lRet := Iif(oCarga:gravaMonitorPropriedades(), lRet, .F.)
        oCarga:Destroy()
    EndIf
    FreeObj(oExemplo)
    FreeObj(oParametros)
Return lRet

/*/{Protheus.doc} BuscaDados
Responsável por realizar a busca dos dados que serão exibidos no monitor (gráfico ou texto)

@type Class
@author brunno.costa
@since 23/10/2023
@version P12.1.2310
@param 01 - oFiltros, objeto Json, Contém as propriedades do monitor usadas para filtrar a query de busca
@param 02 - cTipo   , caracter   , Tipo chart/info
@param 03 - cSubTipo, caracter   , Tipo de grafico pie/bar/column
@return cJsonDados, caracter   , Retorna um novo Json em formato texto, pronto para conversão e exibição no front
/*/
Method BuscaDados(oFiltros, cTipo, cSubTipo) Class DocumentosVencidos
    Local aSemaforo        := StrTokArr(Replace(oFiltros["02_SEMAFORO"],",","."),";")
    Local aUsrMat          := {}
    Local cAlias           := Nil
    Local cMatCod          := ""
    Local cMatDep          := ""
    Local cMatFil          := ""
    Local cQuery           := ""
    Local dDataFim         := dDataBase
    Local dDataIni         := dDataBase
    Local nIndTag          := 0
    Local nQtde            := 0
    Local oJson            := JsonObject()     :New()
    Local oQLTQueryManager := QLTQueryManager():New()

    oFiltros["01_FILIAL"] := PadR(oFiltros["01_FILIAL"], FWSizeFilial())

    dDataFim                  := dDatabase
    dDataIni                  := DocumentosVencidos():RetornaPeriodoInicial(oFiltros["03_TIPOPERIODO"],;
                                                                                      dDataFim,;
                                                                                      DocumentosVencidos():ConverteEmNumero(oFiltros["05_PERIODO_PERSONALIZADO"]))
    cQuery += " SELECT COUNT(*) QTDE "
    cQuery += " FROM "+RetSqlName("QDH")+" QDH "
    cQuery += DocumentosVencidos():MontaWhereQuery(oFiltros, dDataIni, dDataFim)
    
    cQuery := oQLTQueryManager:ChangeQuery(cQuery)
    cAlias := oQLTQueryManager:ExecuteQuery(cQuery)

    If  (cAlias)->(!Eof())
        nQtde := (cAlias)->QTDE
    End
    (cAlias)->(dbCloseArea())

    If cTipo == "info"
        oJson := DocumentosVencidos():MontaJsonInfo(@oJson,nQtde,aSemaforo)
    Else
        oJson := DocumentosVencidos():MontaJsonVelocimetro(@oJson,nQtde,aSemaforo)
    EndIf

    oJson["tags"]     := {}
    PCPMonitorUtils():AdicionaTagMonitor(oJson["tags"],@nIndTag,"po-icon-calendar",DtoC(dDataIni) + " - " + DtoC(dDataFim))

    If (!Empty(oFiltros["04_USUARIO_LOGADO"])   .AND. oFiltros["04_USUARIO_LOGADO"] == "1") .OR.;
       (!Empty(oFiltros["06_MEU_DEPARTAMENTO"]) .AND. oFiltros["06_MEU_DEPARTAMENTO"] == "1")
        aUsrMat := QA_USUARIO()
        cMatCod := aUsrMat[3]
        cMatDep := aUsrMat[4]
        cMatFil := aUsrMat[2]
    EndIf

    If !Empty(oFiltros["04_USUARIO_LOGADO"]) .AND. oFiltros["04_USUARIO_LOGADO"] == "1"
        PCPMonitorUtils():AdicionaTagMonitor(oJson["tags"],@nIndTag,"po-icon-user",QA_NUSR(cMatFil,cMatCod))
    EndIf

    If !Empty(oFiltros["06_MEU_DEPARTAMENTO"]) .AND. oFiltros["06_MEU_DEPARTAMENTO"] == "1"
        PCPMonitorUtils():AdicionaTagMonitor(oJson["tags"],@nIndTag,"po-icon-company",AllTrim(QA_NDEPT(cMatDep,.T., xFilial("QAD", oFiltros["01_FILIAL"]))))
    EndIf

    FwFreeArray(aSemaforo)
Return oJson:toJson()

/*/{Protheus.doc} BuscaDetalhes
Realiza a busca dos dados para montar os detalhes do Monitor
@type Method
@author brunno.costa
@since 23/10/2023
@version P12.1.2310
@param 01 - oFiltros, objeto, objeto json com os filtros da consulta 
@param 02 - nPagina , número, número de página da consulta
@return cJson, string Json, string com os dados de detalhes para exibição em tabela de detalhes
/*/
Method BuscaDetalhes(oFiltros, nPagina) Class DocumentosVencidos
    Local aCampos          := {"QDH_DOCTO", "QDH_RV", "QDH_TITULO", "QDH_FILMAT", "QDH_MAT", "QDH_DEPTOE", "QDH_CODTP"}
    Local aUsrMat          := {}
    Local cAlias           := Nil
    Local cCampo           := ""
    Local cCodLab          := ""
    Local cFilAux          := ""
    Local cMatCod          := ""
    Local cMatDep          := ""
    Local cMatFil          := ""
    Local cParamDet        := ""
    Local cQuery           := ""
    Local dDataFim         := dDatabase
    Local dDataIni         := dDatabase
    Local lExpResult       := .F.
    Local nCampo           := 0
    Local nCampos          := Len(aCampos)
    Local nIndTag          := 0
    Local nRegistro        := 0
    Local nStart           := 1
    Local nTamPagina       := 20
    Local oDados           := JsonObject()     :New()
    Local oQLTQueryManager := QLTQueryManager():New()

    Private Inclui   := .F.

    Default nPagina  := 1

    cFilAux        := PadR(oFiltros["01_FILIAL"], FWSizeFilial())
    cParamDet      := IIF(oFiltros:HasProperty("PARAMETROSDETALHE"),oFiltros["PARAMETROSDETALHE"],"")
    cCodLab        := oFiltros["02_QPL_LABOR"]
    dDataFim       := dDatabase
    dDataIni       := DocumentosVencidos():RetornaPeriodoInicial(oFiltros["03_TIPOPERIODO"],;
                                                                        dDataFim,;
                                                                        DocumentosVencidos():ConverteEmNumero(oFiltros["05_PERIODO_PERSONALIZADO"]))

    lExpResult := Iif(nPagina == 0, .T., lExpResult)

    cQuery += " SELECT "
    cQuery += " QDH.* "
    cQuery += " FROM "+RetSqlName("QDH")+" QDH "
    cQuery += DocumentosVencidos():MontaWhereQuery(oFiltros, dDataIni, dDataFim)
    cQuery += Iif(Empty(cParamDet), "", " AND " + cParamDet)
    cQuery += " ORDER BY QDH_DTLIM ASC, QDH_DOCTO, QDH_RV "

    cQuery := oQLTQueryManager:ChangeQuery(cQuery)
    cAlias := oQLTQueryManager:ExecuteQuery(cQuery)
    
    nStart := Iif(nPagina > 1, ( (nPagina-1) * nTamPagina ), nStart)
    Iif(nPagina > 1 .And. nStart > 0, (cAlias)->(DbSkip(nStart)), Nil)
    
    oDados["items"]        := {}
    oDados["columns"]      := DocumentosVencidos():AdicionaColunasDetalhes(lExpResult)
    oDados["canExportCSV"] := .T.
    oDados["tags"]         := {}

    PCPMonitorUtils():AdicionaTagMonitor(oDados["tags"],@nIndTag,"po-icon-calendar",dToC(dDataIni) + " - " + dToC(dDataFim))

   If (!Empty(oFiltros["04_USUARIO_LOGADO"])   .AND. oFiltros["04_USUARIO_LOGADO"] == "1") .OR.;
       (!Empty(oFiltros["06_MEU_DEPARTAMENTO"]) .AND. oFiltros["06_MEU_DEPARTAMENTO"] == "1")
        aUsrMat := QA_USUARIO()
        cMatCod := aUsrMat[3]
        cMatDep := aUsrMat[4]
        cMatFil := aUsrMat[2]
    EndIf

    If !Empty(oFiltros["04_USUARIO_LOGADO"]) .AND. oFiltros["04_USUARIO_LOGADO"] == "1"
        PCPMonitorUtils():AdicionaTagMonitor(oDados["tags"],@nIndTag,"po-icon-user",QA_NUSR(cMatFil,cMatCod))
    EndIf

    If !Empty(oFiltros["06_MEU_DEPARTAMENTO"]) .AND. oFiltros["06_MEU_DEPARTAMENTO"] == "1"
        PCPMonitorUtils():AdicionaTagMonitor(oDados["tags"],@nIndTag,"po-icon-company",AllTrim(QA_NDEPT(cMatDep,.T., xFilial("QAD", oFiltros["01_FILIAL"]))))
    EndIf

    While (cAlias)->(!Eof())
        aAdd(oDados["items"], JsonObject():New())

        nRegistro++
        For nCampo := 1 to nCampos
            cCampo                             := aCampos[nCampo]
            oDados["items"][nRegistro][cCampo] := (cAlias)->&(cCampo)
        Next nCampo

        oDados["items"][nRegistro]["QDH_DESCTP"]  := QDXFNANTPD((cAlias)->QDH_CODTP,,(cAlias)->QDH_FILIAL)
        oDados["items"][nRegistro]["DEP_EMISSOR"] := AllTrim(QA_NDEPT((cAlias)->QDH_DEPTOE,.T., (cAlias)->QDH_FILIAL))
        oDados["items"][nRegistro]["QDH_DTVIG" ]  := PCPMonitorUtils():FormataData((cAlias)->QDH_DTVIG,4)
        oDados["items"][nRegistro]["QDH_DTIMPL"]  := PCPMonitorUtils():FormataData((cAlias)->QDH_DTIMPL,4)
        oDados["items"][nRegistro]["QDH_DTCAD" ]  := PCPMonitorUtils():FormataData((cAlias)->QDH_DTCAD,4)
        oDados["items"][nRegistro]["QDH_DTFIM" ]  := PCPMonitorUtils():FormataData((cAlias)->QDH_DTFIM,4)
        oDados["items"][nRegistro]["QDH_DTLIM" ]  := PCPMonitorUtils():FormataData((cAlias)->QDH_DTLIM,4)
        oDados["items"][nRegistro]["DIAS"      ]  := Str(dDataBase - StoD((cAlias)->QDH_DTLIM)) + " " + "dias"
        oDados["items"][nRegistro]["DIGITADOR" ]  := QA_NUSR((cAlias)->QDH_FILMAT,(cAlias)->QDH_MAT)

        (cAlias)->(dbSkip())
        
        If !lExpResult .And. nRegistro >= nTamPagina
            Exit
        EndIf
    End
    oDados["hasNext"] := (cAlias)->(!Eof())
    (cAlias)->(dbCloseArea())
Return oDados:ToJson()

/*/{Protheus.doc} AdicionaColunasDetalhes
Cria array de objetos no formato poTableColumn com as colunas da table de detalhamento
@type METHOD
@author brunno.costa
@since 10/10/2023
@version P12.1.2310
@param 01 - lExpResult, logico, Indica se trata todas as colunas como visible para exportação de planilha
@return aColunas  , array   , Array de objetos com as colunas da table po-ui
/*/
Method AdicionaColunasDetalhes(lExpResult) Class DocumentosVencidos

    Local aCampos    := {"QDH_DOCTO", "QDH_RV", "QDH_TITULO", "QDH_DEPTOE", "QDH_CODTP", "QDH_DESCTP","QDH_DTVIG", "QDH_DTIMPL", "QDH_DTCAD", "QDH_DTFIM", "QDH_DTLIM", "QDH_FILMAT", "QDH_MAT"}
    Local aColunas   := {}
    Local cTipo      := ""
    Local lVisivel   := .T.
    Local nCampo     := 0
    Local nCampos    := Len(aCampos)
    Local nIndice    := 0

    For nCampo := 1 to nCampos
        cCampo := aCampos[nCampo]
        If X3Uso(GetSx3Cache(cCampo,"X3_USADO"),24)
            cTipo  := GetSx3Cache(cCampo,"X3_TIPO")
            Do Case
                Case cTipo == "C"
                    cTipo := "string"
                Case cTipo == "D"
                    cTipo := "date"
            EndCase
            lVisivel := GetSx3Cache(cCampo,"X3_BROWSE") != "N"
            PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,cCampo,GetSx3Cache(cCampo,"X3_TITULO"),cTipo,lVisivel.OR.lExpResult)

            If cCampo == "QDH_DEPTOE"
                //STR0014 - "Dep. Emissor"
                PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"DEP_EMISSOR",STR0014,"string",lVisivel.OR.lExpResult)
            EndIf

            If cCampo == "QDH_DTLIM"
                //STR0015 - "Dias"
                PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"DIAS",STR0015,"string",lVisivel.OR.lExpResult)
            EndIf

            If cCampo == "QDH_MAT"
                //STR0016 - "Digitador"
                PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"DIGITADOR",STR0016,"string",lVisivel.OR.lExpResult)
            EndIf
        EndIf
    Next nCampo    

Return aColunas

/*/{Protheus.doc} MontaComboUsuarioLogado
Cria JSON com os dados para COMBO de Usuário Logado
@type Method
@author brunno.costa
@since 23/10/2023
@version P12.1.2310
@param 01 - oParametro, objeto, cria por referência o objeto JSON oFiltros["06_MEU_DEPARTAMENTO"]
@return oParametro, objeto, retorna o objeto criado
/*/
Method MontaComboUsuarioLogado(oParametro) Class DocumentosVencidos
    Default oParametro    := JsonObject():New()
    oParametro["opcoes"]  :=       STR0017 + ":1" //"Sim"+":1"
    oParametro["opcoes"]  += ";" + STR0018 + ":2" //"Não, todos"+":2" 
Return oParametro

/*/{Protheus.doc} MontaComboMeuDepartamento
Cria JSON com os dados para COMBO de Situação
@type Method
@author brunno.costa
@since 23/10/2023
@version P12.1.2310
@param 01 - oParametro, objeto, cria por referência o objeto JSON oFiltros["06_MEU_DEPARTAMENTO"]
@return oParametro, objeto, retorna o objeto criado
/*/
Method MontaComboMeuDepartamento(oParametro) Class DocumentosVencidos
    Default oParametro      := JsonObject():New()
    oParametro["opcoes"]  :=       STR0017 + ":1" //"Sim"+":1"
    oParametro["opcoes"]  += ";" + STR0018 + ":2" //"Não, todos"+":2" 
Return oParametro

/*/{Protheus.doc} MontaComboPeriodos
Cria JSON com os dados para COMBO de Períodos
@type Method
@author brunno.costa
@since 23/10/2023
@version P12.1.2310
@param 01 - oParametro, objeto, cria por referência o objeto JSON oFiltros["03_TIPOPERIODO"]
@return oParametro, objeto, retorna o objeto criado
/*/
Method MontaComboPeriodos(oParametro) Class DocumentosVencidos
    Default oParametro      := JsonObject():New()
    oParametro["opcoes"] :=       STR0019+":1"  //"Últimos 30 dias"
    oParametro["opcoes"] += ";" + STR0020+":6"  //"Últimos 180 dias"
    oParametro["opcoes"] += ";" + STR0021+":12" //"Últimos 365 dias"
    oParametro["opcoes"] += ";" + STR0022+":X"  //"Personalizado"
Return oParametro


/*/{Protheus.doc} SetaPropriedadeFilial
Adiciona ao objeto de carga do Monitor a propriedade Filial
@type Method
@author brunno.costa
@since 23/10/2023
@version P12.1.2310
@param 01 - oCarga , objeto  , instancia do objeto json de carga
@param 02 - cCodigo, caracter, codigo da propriedade
@param 03 - cTitulo, caracter, título da propriedade para exibicao no front-end
@return Nil
/*/
Method SetaPropriedadeFilial(oCarga, cCodigo, cTitulo) Class DocumentosVencidos
    Local oPrmAdc := JsonObject():New()
    
    oPrmAdc["filtroServico"]                := "/api/pcp/v1/pcpmonitorapi/consulta"
    oPrmAdc["parametrosServico"]            := JsonObject():New()
    oPrmAdc["parametrosServico"]["metodo"]  := "PCPMonitorConsultas():BuscaFiliais"
    oPrmAdc["labelSelect"]                  := "Description"
    oPrmAdc["valorSelect"]                  := "Code"

    oCarga:setaPropriedade(cCodigo,"",cTitulo,7,GetSx3Cache("HZD_FILIAL","X3_TAMANHO"),0,"po-sm-12 po-md-6 po-lg-6 po-xl-6",/*oEstilos*/,/*cIcone*/,oPrmAdc)

    FreeObj(oPrmAdc)
Return

/*/{Protheus.doc} SetaPropriedadeLookupTabela
Adiciona ao objeto de carga do Monitor a propriedade lookup tabela
@type Method
@author brunno.costa
@since 23/10/2023
@version P12.1.2310
@param 01 - oCarga    , objeto  , instancia do objeto de carga relacionado
@param 02 - cCodigo   , caracter, Codigo da propriedade
@param 03 - cLabel    , caracter, Label do campo
@param 04 - lSelecMult, logico  , Indica se a propriedade é selecção múltipla
@param 05 - cTabela   , caracter, Tabela
@param 06 - cCampoCod , caracter, Campo código
@param 07 - cCampoDsc , caracter, Campo descrição
@param 08 - nOrdFil   , número  , indica a posição de referência da filial para filtro dos dados
@return Nil
/*/
Method SetaPropriedadeLookupTabela(oCarga, cCodigo, cLabel, lSelecMult, cTabela, cCampoCod, cCampoDsc, nOrdFil) Class DocumentosVencidos
    Local oPrmAdc := JsonObject():New()
    Local cOrdFil := Nil
    Default nOrdFil := 1
    cOrdFil := Str(nOrdFil - 1)
    oPrmAdc["filtroServico"]                       := "/api/pcp/v1/pcpmonitorapi/consulta"
    oPrmAdc["parametrosServico"]                   := JsonObject():New()
    oPrmAdc["parametrosServico"]["filial"]         := "${this.monitor.propriedades?.[" + cOrdFil + "]?.valorPropriedade}"
    oPrmAdc["parametrosServico"]["metodo"]         := "PCPMonitorConsultas():BuscaCadastroTabela"
    oPrmAdc["parametrosServico"]["tabela"]         := cTabela
    oPrmAdc["parametrosServico"]["campoCodigo"]    := cCampoCod
    oPrmAdc["parametrosServico"]["campoDescricao"] := cCampoDsc
    oPrmAdc["selecaoMultipla"]                     := lSelecMult
    oPrmAdc["colunas"]                             := {}
    aAdd(oPrmAdc["colunas"], JsonObject():New())
        oPrmAdc["colunas"][1]["property"]          := "Code"
        oPrmAdc["colunas"][1]["label"]             := GetSx3Cache(cCampoCod,"X3_TITULO")
    aAdd(oPrmAdc["colunas"], JsonObject():New())
        oPrmAdc["colunas"][2]["property"]          := "Description"
        oPrmAdc["colunas"][2]["label"]             := GetSx3Cache(cCampoDsc,"X3_TITULO")
    oPrmAdc["labelSelect"]                         := "Code"
    oPrmAdc["valorSelect"]                         := "Code"
    oCarga:setaPropriedade(cCodigo,"",cLabel,8,GetSx3Cache(cCampoCod,"X3_TAMANHO"),0,"po-sm-12 po-md-6 po-lg-6 po-xl-6",/*oEstilos*/,/*cIcone*/,oPrmAdc)
    FreeObj(oPrmAdc)
Return

/*/{Protheus.doc} MontaJsonVelocimetro
Monta objeto json com os dados para mostrar o gauge
@type Static Function
@author brunno.costa
@since 23/10/2023
@version P12.1.2310
@param 01 - oJson     , objeto json, Objeto json que receberá os dados do gauge
@param 02 - nQtde     , numerico   , quantidade para exibição no monitor
@param 03 - aSemaforo , array      , Array com os números do semáforo
@return Nil
/*/
Method MontaJsonVelocimetro(oJson, nQtde, aSemaforo) Class DocumentosVencidos
    Local cDescricao  := Iif(nQtde > 1, STR0023, STR0024) //Documentos , Documento
    Local cValorFim   := ""
    Local cValSemaf1  := aSemaforo[1]
    Local cValSemaf2  := aSemaforo[2]
    Local lMenorVerde := Nil
    Local nValorFim   := 0
    Local nValSemaf1  := Val(cValSemaf1)
    Local nValSemaf2  := Val(cValSemaf2)
    Local oGauge      := PCPMonitorGauge():New()

    lMenorVerde := nValSemaf1 < nValSemaf2

    oJson["alturaMinimaWidget"] := "350px"
    oJson["alturaMaximaWidget"] := "500px"
    oJson["categorias"] := {}
    oJson["series"]     := {}
    oJson["detalhes"]   := {}
    oGauge:SetValue(nQtde)
    oGauge:SetValueStyle("color",DocumentosVencidos():RetornaCorSemaforo(nQtde,aSemaforo))
    oGauge:SetValueStyle("font-weight","bold")
    oGauge:SetLabel(cDescricao)
    oGauge:SetLabelStyle("font-weight","bold")

    If lMenorVerde
        If nQtde > nValSemaf2
            nValorFim := nQtde + (nValSemaf2 - nValSemaf1)
        Else
            nValorFim := nValSemaf2 + (nValSemaf2 - nValSemaf1)
        EndIf
        cValorFim := cValToChar(nValorFim)
        oGauge:SetMaxValue(nValorFim)
        oGauge:SetThreshold("0",COR_VERDE_FORTE)
        oGauge:SetThreshold(cValSemaf1,COR_AMARELO_QUEIMADO)
        oGauge:SetThreshold(cValSemaf2,COR_VERMELHO_FORTE)
    Else
        If nQtde > nValSemaf1
            nValorFim := nQtde + (nValSemaf1 - nValSemaf2)
        Else
            nValorFim := nValSemaf1 + nValSemaf2
        EndIf
        cValorFim := cValToChar(nValorFim)
        oGauge:SetMaxValue(nValorFim)
        oGauge:SetThreshold("0",COR_VERMELHO_FORTE)
        oGauge:SetThreshold(cValSemaf2,COR_AMARELO_QUEIMADO)
        oGauge:SetThreshold(cValSemaf1,COR_VERDE_FORTE)
    EndIf

    Iif(Val(cValSemaf1) > 0, oGauge:SetMarker("0"), Nil)

    oGauge:SetMarker(cValSemaf1)
    oGauge:SetMarker(cValSemaf2)
    oGauge:SetMarker(cValorFim)

    oJson["gauge"] := oGauge:GetJsonObject()
    FreeObj(oGauge)
Return oJson

/*/{Protheus.doc} MontaJsonInfo
Monta objeto json com os dados para mostrar o gráfico de informações
@type Static Function
@author brunno.costa
@since 23/10/2023
@version P12.1.2310
@param 01 - oJson     , objeto json, Objeto json que receberá os dados do gauge
@param 02 - nQtde     , numerico   , quantidade para exibição no monitor
@param 03 - aSemaforo , array      , Array com os números do semáforo
@param 04 - lVencido  , lógico, Indica se a execução é para o monitor Vencido (.T.) ou a Vencer (.F.)
@return Nil
/*/
Method MontaJsonInfo(oJson, nQtde, aSemaforo, lVencido) Class DocumentosVencidos

    Local cDescricao := Iif(nQtde > 1, STR0023, STR0024) //Documentos , Documento
    Local nIndLinha  := 0
    Local oStyle     := JsonObject():New()
    Local oStyleQtd  := JsonObject():New()
    Default lVencido := .T.

    oStyle["color"]             := "white"

    oJson["alturaMaximaWidget"] := "500px"
    oJson["alturaMinimaWidget"] := "350px"
    oJson["corTitulo"]          := "white"
    oJson["linhas"]             := {}
    oJson["corFundo"]           := DocumentosVencidos():RetornaCorSemaforo(nQtde,aSemaforo)

    If oJson["corFundo"] == COR_AMARELO_ESCURO
        oStyle["color"]      := "black"
        oJson["corTitulo"]   := "black"
    EndIf

    oStyleQtd["font-weight"] := "bold"
    oStyleQtd["font-size"]   := "120px"
    oStyleQtd["line-height"] := "130px"
    oStyleQtd["text-align"]  := "center"
    oStyleQtd["color"]       := oStyle["color"]
    oStyleQtd["cursor"]      := "pointer"

    If nQtde > 0
        PCPMonitorUtils():AdicionaLinhaInformacao(oJson["linhas"],@nIndLinha,Str(nQtde),"po-sm-12 po-pt-4",oStyleQtd:ToJson(),.T.)
        PCPMonitorUtils():AdicionaLinhaInformacao(oJson["linhas"],@nIndLinha,cDescricao,"po-font-subtitle po-text-center po-sm-12 po-pt-1 bold-text",oStyle:ToJson())
    Else
        If lVencido
            PCPMonitorUtils():AdicionaLinhaInformacao(oJson["linhas"],@nIndLinha,STR0025,"po-font-text-large-bold po-text-center po-sm-12 po-pt-4",oStyle:ToJson())
        Else //"Nenhum documento a vencer foi encontrado no período selecionado."                                                                                                                                                                                                                                                                                                                                                                                                                                                  
            PCPMonitorUtils():AdicionaLinhaInformacao(oJson["linhas"],@nIndLinha,STR0030,"po-font-text-large-bold po-text-center po-sm-12 po-pt-4",oStyle:ToJson())    
        EndIf
    EndIf

Return oJson

/*/{Protheus.doc} RetornaCorSemaforo
Retorna a cor do semáforo de acordo com a quantidade parametrizada
@type Static Function
@author brunno.costa
@since 13/04/2023
@version P12.1.2310
@param 01 - nQtde     , numerico, quantidade exibida no semaforo para análise
@param 02 - aSemaforo , array   , Array com os números do semáforo
@return cCorSemaf , caracter, String com código RGB da cor
/*/
Method RetornaCorSemaforo(nQtde, aSemaforo) Class DocumentosVencidos
    Local nValSemaf1  := Val(aSemaforo[1])
    Local nValSemaf2  := Val(aSemaforo[2])
    Local lMenorVerde := nValSemaf1 < nValSemaf2

    If lMenorVerde
        If nQtde < nValSemaf1
            Return COR_VERDE_FORTE
        ElseIf nQtde < nValSemaf2
            Return COR_AMARELO_ESCURO
        EndIf
    Else
        If nQtde <= nValSemaf1 .AND. nQtde > nValSemaf2
            Return COR_AMARELO_ESCURO
        ElseIf nQtde > nValSemaf1
            Return COR_VERDE_FORTE
        EndIf
    EndIf

Return COR_VERMELHO_FORTE

/*/{Protheus.doc} RetornaPeriodoInicial
Retorna Período Inicial
@type METHOD
@author brunno.costa
@since 10/10/2023
@version P12.1.2310
@param 01 - cFiltro  , caracter, tipo do filtro: 1:Últimos 30 dias; 6: Últimos 180 dias; 12: Últimos 365 dias; X: Personalizado
@param 02 - dDataFim , data    , data final para filtro
@param 03 - nPersonal, número  , quantidade de anos para cFiltro = X-Personalizado
@return dDataIni     , data    , data inicial para filtro
/*/
Method RetornaPeriodoInicial(cFiltro, dDataFim, nPersonal) Class DocumentosVencidos
    Local dDataIni := dDataFim

    Do Case
    Case cFiltro == "1"
        dDataIni -= 30
    Case cFiltro == "6"
        dDataIni -= 180 //6 meses
    Case cFiltro == "12"
        dDataIni -= 365
    Case cFiltro == "X"
        dDataIni -= nPersonal*365
    EndCase

Return dDataIni

/*/{Protheus.doc} ValidaPropriedades
Valida os dados informados nas propriedades do Monitor
@type Method
@author brunno.costa
@since 23/10/2023
@version P12.1.2310
@param 01 - oFiltros, objeto json, Objeto json com os filtros para a consulta dos dados
@param 02 - lVencido, lógico, Indica se a execução é para o monitor Vencido (.T.) ou a Vencer (.F.)
@return aRetorno, array , [1] logico - indica se os dados são válidos [2] caracter - mensagem de erro
/*/
Method ValidaPropriedades(oFiltros, lVencido) Class DocumentosVencidos
    Local aRetorno    :={.T., ""}
    Local aSemaforo   := {}
    Local bErrorBlock := Nil
    Local lSemNumero  := .F.
    Local nAux        := 0
    Local nIndSemaf   := 1
    Default lVencido  := .T.

    PCPMonitorUtils():ValidaPropriedadeFilial(oFiltros["01_FILIAL"],aRetorno)

    If aRetorno[1]
        If !oFiltros:HasProperty("02_SEMAFORO") .Or. oFiltros["02_SEMAFORO"] == Nil .Or. Empty(oFiltros["02_SEMAFORO"])
            aRetorno[1] := .F.
            If lVencido
                aRetorno[2] := STR0026 //"O campo 'Semáforo' deve ser preenchido com 2 valores separados por ponto e vírgula (ex.: '10;100'), definindo o número de documentos vencidos que indicam Atenção e Urgência, respectivamente" 
            Else
                aRetorno[2] := STR0031 //"O campo 'Semáforo' deve ser preenchido com 2 valores separados por ponto e vírgula (ex.: '10;100'), definindo o número de documentos a vencer que indicam Atenção e Urgência, respectivamente"
            EndIf
        Else
            aSemaforo := StrTokArr(Replace(oFiltros["02_SEMAFORO"],",","."),";")
            If Len(aSemaforo) <> 2
                aRetorno[1] := .F.
                If lVencido
                    aRetorno[2] := STR0026  //"O campo 'Semáforo' deve ser preenchido com 2 valores separados por ponto e vírgula (ex.: '10;100'), definindo o número de documentos vencidos que indicam Atenção e Urgência, respectivamente"
                Else 
                    aRetorno[2] := STR0031 //"O campo 'Semáforo' deve ser preenchido com 2 valores separados por ponto e vírgula (ex.: '10;100'), definindo o número de documentos a vencer que indicam Atenção e Urgência, respectivamente"
                EndIf    
            Else   
                lSemNumero  := .F.
                bErrorBlock := ErrorBlock({|| lSemNumero := .T.})
                For nIndSemaf := 1 To 2
                    nAux      := Val(aSemaforo[nIndSemaf])
                    If Empty(aSemaforo[nIndSemaf]) .Or. lSemNumero .Or. AllTrim(Str(nAux)) <> AllTrim(aSemaforo[nIndSemaf])
                        aRetorno[1] := .F.
                        If lVencido
                            aRetorno[2] := STR0026  //"O campo 'Semáforo' deve ser preenchido com 2 valores separados por ponto e vírgula (ex.: '10;100'), definindo o número de documentos vencidos que indicam Atenção e Urgência, respectivamente"
                        Else
                            aRetorno[2] := STR0031 //"O campo 'Semáforo' deve ser preenchido com 2 valores separados por ponto e vírgula (ex.: '10;100'), definindo o número de documentos a vencer que indicam Atenção e Urgência, respectivamente"
                        EndIf     
                        Exit
                    EndIf
                Next nIndSemaf
                ErrorBlock(bErrorBlock)
            EndIf
        EndIf
    EndIf

    If aRetorno[1] .And. (!oFiltros:HasProperty("03_TIPOPERIODO") .Or. oFiltros["03_TIPOPERIODO"] == Nil .Or. Empty(oFiltros["03_TIPOPERIODO"]))
        aRetorno[1] := .F.
        aRetorno[2] := STR0027 //"Deve ser informado o período de vencimento para análise do monitor."
    EndIf

    If aRetorno[1] .And. oFiltros["03_TIPOPERIODO"] == "X"
        If !oFiltros:HasProperty("05_PERIODO_PERSONALIZADO") .Or. oFiltros["05_PERIODO_PERSONALIZADO"] == Nil .Or. Empty(oFiltros["05_PERIODO_PERSONALIZADO"])
            aRetorno[1] := .F.
            aRetorno[2] := STR0028 //"Deve ser informada a quantidade de anos para o período personalizado."
        EndIf
    EndIf

    FwFreeArray(aSemaforo)
Return aRetorno


/*/{Protheus.doc} ConverteEmNumero
Converte valor em número - necessário pois eventualmente front-end retorna valor numérico ou string
@type Method
@author brunno.costa
@since 23/10/2023
@version P12.1.2310
@param  oValor  , número / string, valor enviado pelo front-end
@return nRetorno, número, retorna o valor numérico relacionado a oValor
/*/
Method ConverteEmNumero(oValor) Class DocumentosVencidos
    Local nRetorno := oValor
    If ValType(oValor) == "C"
        nRetorno := Val(oValor)
    EndIf
Return nRetorno

/*/{Protheus.doc} MontaWhereQuery
Monta dados WHERE para selecao dos dados da QPK para contagem
@type METHOD
@author brunno.costa
@since 10/10/2023
@version P12.1.2310
@param 01 - oFiltros, objeto  , objeto Json de filtros do monitor
@param 02 - dDataIni, data    , data de inicio para filtro
@param 03 - dDataFim, data    , data de fim para filtro
@return cWhere, caracter, string SQL com clausua WHERE para filtro dos dados
/*/
Method MontaWhereQuery(oFiltros, dDataIni, dDataFim) Class DocumentosVencidos
    
    Local aUsrMat := {}
    Local cFilAux := PadR(oFiltros["01_FILIAL"], FWSizeFilial())
    Local cMatCod := ""
    Local cMatDep := ""
    Local cMatFil := ""
    Local cWhere  := ""

    cWhere := " WHERE QDH.QDH_FILIAL = '" + xFilial('QDH', cFilAux) + "' "
    cWhere +=   " AND QDH.QDH_OBSOL  <> 'S' "
    cWhere +=   " AND QDH.QDH_CANCEL <> 'S' "
    cWhere +=   " AND QDH.QDH_DTLIM  <> ' ' "
    cWhere +=   " AND QDH.QDH_DTLIM  >= '" + DtoS(dDataIni) + "' "
    cWhere +=   " AND QDH.QDH_DTLIM  <= '" + DtoS(dDataFim) + "' "

    If (!Empty(oFiltros["04_USUARIO_LOGADO"])   .AND. oFiltros["04_USUARIO_LOGADO"] == "1") .OR.;
       (!Empty(oFiltros["06_MEU_DEPARTAMENTO"]) .AND. oFiltros["06_MEU_DEPARTAMENTO"] == "1")
        aUsrMat := QA_USUARIO()
        cMatCod := aUsrMat[3]
        cMatDep := aUsrMat[4]
        cMatFil := aUsrMat[2]
        cWhere += " AND QDH.QDH_FILMAT = '" + cMatFil + "' "
    EndIf

    If !Empty(oFiltros["04_USUARIO_LOGADO"]) .AND. oFiltros["04_USUARIO_LOGADO"] == "1"
        cWhere += " AND QDH.QDH_MAT = '" + cMatCod + "'  "
    EndIf

    If !Empty(oFiltros["06_MEU_DEPARTAMENTO"]) .AND. oFiltros["06_MEU_DEPARTAMENTO"] == "1"
        cWhere += " AND QDH.QDH_DEPTOE = '" + cMatDep + "' "
    EndIf

    If !Empty(oFiltros["07_DEPARTAMENTOS_EMISSORES"])
        cWhere +=   " AND (QDH.QDH_DEPTOE IN (" + "'" + ArrTokStr(oFiltros["07_DEPARTAMENTOS_EMISSORES"],"', '",0) + "'" + ")) "
    EndIf

Return cWhere
