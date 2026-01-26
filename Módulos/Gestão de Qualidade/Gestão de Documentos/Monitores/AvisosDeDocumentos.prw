#INCLUDE "AVISOSDEDOCUMENTOS.CH"
#INCLUDE "QLTMONITORDEF.CH"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} AvisosDeDocumentos
Classe para prover os dados do Monitor de Ocorrências de Melhoria do Módulo Controle de Não Conformidades (QNC)
@type Class
@author jorge.oliveira
@since 20/10/2023
@version P12.1.2310
@return Nil
/*/
Class AvisosDeDocumentos FROM LongNameClass	
    /*
        Métodos Padrões, utilizados pela classe "PCPMonitor"
    */
    Static Method BuscaDados(oFiltros, cTipo, cSubTipo)
	Static Method BuscaDetalhes(oFiltro, nPagina)
	Static Method CargaMonitor()
    Static Method ValidaPropriedades(oFiltros)

    /*
        Métodos Internos
    */
    Static Method AdicionaColunasDetalhes(lExpResult)
    Static Method MontaComboMeuDepartamento(oParametro)
    Static Method MontaComboTipoPendencia(oParametro)
    Static Method MontaComboUsuarioLogado(oParametro)
    Static Method MontaJsonInfo(oJson, nQtde, aSemaforo)
    Static Method MontaJsonVelocimetro(oJson, nQtde, aSemaforo)
    Static Method MontaWhereQuery(oFiltros, dDataIni, dDataFim)
    Static Method RetornaCorSemaforo(nQtde, aSemaforo)
    Static Method RetornaTipoPendencia(cPendencia)
    Static Method SetaPropriedadeFilial(cCodigo, cTitulo)
    Static Method SetaPropriedadeLookupTabela(oCarga, cCodigo, cLabel, lSelecMult, cTabela, cCampoCod, cCampoDsc, cOrdFil)

EndClass

/*/{Protheus.doc} CargaMonitor
Realiza a carga do Monitor padrão na base de dados
@type Method
@author jorge.oliveira
@since 17/10/2023
@version P12.1.2310
@return lRet, logico, Indica se conseguiu realizar a carga
/*/
Method CargaMonitor() Class AvisosDeDocumentos
    Local lRet        := .T.
    Local oCarga      := PCPMonitorCarga():New()
    Local oExemplo    := JsonObject()     :New()
    Local oParametros := JsonObject()     :New()
        
    If !PCPMonitorCarga():monitorAtualizado("AvisosDeDocumentos")        
        oCarga:setaTitulo(STR0001) //"Avisos de Documentos"
        oCarga:setaObjetivo(STR0002) //"Apresentar o número de avisos pendentes no fluxo de criação de documentos no módulo Controle de Documentos (SIGAQDO), do usuário logado ou de todos os usuários, para o departamento do usuário ou para todos os departamentos, de uma ou mais etapas do fluxo."
        oCarga:setaAgrupador(STR0003) //"Qualidade"
        oCarga:setaFuncaoNegocio("AvisosDeDocumentos")
        oCarga:setaTiposPermitidos("chart;info")
        oCarga:setaTiposGraficoPermitidos("gauge")
        oCarga:setaTipoPadrao("info")
        oCarga:setaTipoGraficoPadrao("")
        oCarga:setaTipoDetalhe("detalhe")

        oExemplo := AvisosDeDocumentos():MontaJsonInfo(@oExemplo,123,{"1","10","30"})

        oExemplo["tags"] := {}

        oCarga:setaExemploJsonTexto(.F.,oExemplo)

        //STR0004 - "Filial Ocorrência"
        AvisosDeDocumentos():SetaPropriedadeFilial(@oCarga, "01_QDS_FILIAL", STR0004 + "*")

        //STR0005 - Atenção
        //STR0006 - Urgente
        //STR0008 - Semáforo
        oCarga:setaPropriedade("02_SEMAFORO", STR0005 + ";" + STR0006, STR0008 + " (" + STR0005 + ";" + STR0006 + ")*",1,30,0,"po-lg-6 po-xl-6 po-md-6 po-sm-12",/*oEstilos*/,/*cIcone*/,/*oParametros*/)

        //STR0009 - "Usuário Logado"        
        oCarga:setaPropriedade("03_USUARIO_LOGADO" ,"",STR0009,4,,,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,AvisosDeDocumentos():MontaComboUsuarioLogado(oParametros["03_USUARIO_LOGADO"]))

        //STR0010 - "Meu Departamento"
        oCarga:setaPropriedade("04_MEU_DEPARTAMENTO" ,"",STR0010,4,,,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,AvisosDeDocumentos():MontaComboMeuDepartamento(oParametros["04_MEU_DEPARTAMENTO"]))

        //STR0011 - "Departamentos Específicos"
        AvisosDeDocumentos():SetaPropriedadeLookupTabela(@oCarga, "05_DEPARTAMENTOS_ESPECIFICOS",STR0011,.T.,"QAD","QAD_CUSTO","QAD_DESC",1)

        //STR0029 - "Tipo Pendência"
        oCarga:setaPropriedade("06_TIPO_PENDENCIA" ,"",STR0029,5,,,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,AvisosDeDocumentos():MontaComboTipoPendencia(oParametros["06_TIPO_PENDENCIA"]))

        lRet := Iif(oCarga:gravaMonitorPropriedades(), lRet, .F.)

        oCarga:Destroy()

    EndIf

    FreeObj(oExemplo)
    FreeObj(oParametros)

Return lRet

/*/{Protheus.doc} BuscaDados
Responsável por realizar a busca dos dados que serão exibidos no monitor (gráfico ou texto)

@type Class
@author jorge.oliveira
@since 09/02/2023
@version P12.1.2310
@param 01 - oFiltros, objeto Json, Contém as propriedades do monitor usadas para filtrar a query de busca
@param 02 - cTipo   , caracter   , Tipo chart/info
@param 03 - cSubTipo, caracter   , Tipo de grafico pie/bar/column
@return cJsonDados, caracter   , Retorna um novo Json em formato texto, pronto para conversão e exibição no front
/*/
Method BuscaDados(oFiltros, cTipo, cSubTipo) Class AvisosDeDocumentos
    Local aSemaforo         := StrTokArr(Replace(oFiltros["02_SEMAFORO"],",","."),";")
    Local cAlias            := Nil
    Local cQuery            := ""
    Local nIndTag           := 0
    Local nQtde             := 0
    Local aUsrMat           := {}
    Local cMatFil           := ""
    Local cMatCod           := ""
    Local cMatDep           := ""
    Local oQLTQueryManager  := QLTQueryManager():New()
    Local oJson             := JsonObject()     :New()

    oFiltros["01_QDS_FILIAL"] := PadR(oFiltros["01_QDS_FILIAL"], FWSizeFilial())

    cQuery += " SELECT COUNT(*) QTDE "
    cQuery += " FROM "+RetSqlName("QDS")+" QDS "
    cQuery += AvisosDeDocumentos():MontaWhereQuery(oFiltros)
    
    cQuery := oQLTQueryManager:ChangeQuery(cQuery)
    cAlias := oQLTQueryManager:ExecuteQuery(cQuery)

    If  (cAlias)->(!Eof())
        nQtde := (cAlias)->QTDE

    EndIf

    (cAlias)->(dbCloseArea())
        
    If cTipo == "info"
        oJson := AvisosDeDocumentos():MontaJsonInfo(@oJson,nQtde,aSemaforo)

    Else
        oJson := AvisosDeDocumentos():MontaJsonVelocimetro(@oJson,nQtde,aSemaforo)

    EndIf

    oJson["tags"]     := {}

    If (!Empty(oFiltros["03_USUARIO_LOGADO"])   .AND. oFiltros["03_USUARIO_LOGADO"] == "1") .OR.;
       (!Empty(oFiltros["04_MEU_DEPARTAMENTO"]) .AND. oFiltros["04_MEU_DEPARTAMENTO"] == "1")
        aUsrMat := QA_USUARIO()
        cMatFil := aUsrMat[2]
        cMatCod := aUsrMat[3]
        cMatDep := aUsrMat[4]        

    EndIf
    
    If !Empty(oFiltros["03_USUARIO_LOGADO"]) .And. oFiltros["03_USUARIO_LOGADO"] == "1"
        PCPMonitorUtils():AdicionaTagMonitor(oJson["tags"],@nIndTag,"po-icon-user",QA_NUSR(cMatFil,cMatCod))

    EndIf

    If !Empty(oFiltros["04_MEU_DEPARTAMENTO"]) .And. oFiltros["04_MEU_DEPARTAMENTO"] == "1"
        PCPMonitorUtils():AdicionaTagMonitor(oJson["tags"],@nIndTag,"po-icon-company",AlLTrim(QA_NDEPT(cMatDep,.T.,xFilial("QAD"))))

    EndIf

    FwFreeArray(aSemaforo)

Return oJson:toJson()

/*/{Protheus.doc} BuscaDetalhes
Realiza a busca dos dados para montar os detalhes do Monitor
@type Method
@author jorge.oliveira
@since 17/10/2023
@version P12.1.2310
@param 01 - oFiltros, objeto, objeto json com os filtros da consulta 
@param 02 - nPagina , número, número de página da consulta
@return cJson, string Json, string com os dados de detalhes para exibição em tabela de detalhes
/*/
Method BuscaDetalhes(oFiltros, nPagina) Class AvisosDeDocumentos
    Local aCampos          := {"QDS_TPPEND", "QDS_DOCTO", "QDS_RV", "QDS_MAT", "QDS_DEPTO"}
    Local aUsrMat          := {}
    Local cAlias           := Nil
    Local cCampo           := ""
    Local cFilAux          := ""
    Local cMatCod          := ""
    Local cMatDep          := ""
    Local cMatFil          := ""
    Local cQuery           := ""
    Local lExpResult       := .F.
    Local nCampo           := 0
    Local nCampos          := Len(aCampos)
    Local nIndTag          := 0
    Local nRegistro        := 0
    Local nStart           := 1
    Local nTamPagina       := 20
    Local oDados           := JsonObject()     :New()
    Local oQLTQueryManager := QLTQueryManager():New()

    Default nPagina  := 1

    cFilAux    := PadR(oFiltros["01_QDS_FILIAL"], FWSizeFilial())
    lExpResult := Iif(nPagina == 0, .T., lExpResult)

    cQuery += " SELECT "
    cQuery += " QDS.* "
    cQuery += " FROM "+RetSqlName("QDS")+" QDS "
    cQuery += AvisosDeDocumentos():MontaWhereQuery(oFiltros)
    cQuery += " ORDER BY QDS_DTGERA, QDS_HRGERA"

    cQuery := oQLTQueryManager:ChangeQuery(cQuery)
    cAlias := oQLTQueryManager:ExecuteQuery(cQuery)
    
    nStart := Iif(nPagina > 1, ( (nPagina-1) * nTamPagina ), nStart)
    Iif(nPagina > 1 .And. nStart > 0, (cAlias)->(DbSkip(nStart)), Nil)

    oDados["items"]        := {}
    oDados["columns"]      := AvisosDeDocumentos():AdicionaColunasDetalhes(lExpResult)
    oDados["canExportCSV"] := .T.
    oDados["tags"]         := {}

    If (!Empty(oFiltros["03_USUARIO_LOGADO"])   .AND. oFiltros["03_USUARIO_LOGADO"] == "1") .OR.;
       (!Empty(oFiltros["04_MEU_DEPARTAMENTO"]) .AND. oFiltros["04_MEU_DEPARTAMENTO"] == "1")
        aUsrMat := QA_USUARIO()
        cMatFil := aUsrMat[2]
        cMatCod := aUsrMat[3]
        cMatDep := aUsrMat[4]        

    EndIf
        
    If !Empty(oFiltros["03_USUARIO_LOGADO"]) .And. oFiltros["03_USUARIO_LOGADO"] == "1"
        PCPMonitorUtils():AdicionaTagMonitor(oDados["tags"],@nIndTag,"po-icon-user",QA_NUSR(cMatFil,cMatCod))

    EndIf

    If !Empty(oFiltros["04_MEU_DEPARTAMENTO"]) .And. oFiltros["04_MEU_DEPARTAMENTO"] == "1"
        PCPMonitorUtils():AdicionaTagMonitor(oDados["tags"],@nIndTag,"po-icon-company",AlLTrim(QA_NDEPT(cMatDep,.T.,xFilial("QAD"))))

    EndIf

    While (cAlias)->(!Eof())
        aAdd(oDados["items"], JsonObject():New())

        nRegistro++

        For nCampo := 1 to nCampos
            cCampo                                 := aCampos[nCampo]
            oDados["items"][nRegistro][cCampo]     := (cAlias)->&(cCampo)

        Next nCampo

        oDados["items"][nRegistro]["QDS_DTGERA"   ] := PCPMonitorUtils():FormataData((cAlias)->QDS_DTGERA,4)
        oDados["items"][nRegistro]["TIPO_PENDENCA"] := AvisosDeDocumentos():RetornaTipoPendencia(oDados["items"][nRegistro]["QDS_TPPEND"])
        oDados["items"][nRegistro]["USUARIO"      ] := QA_NUSR((cAlias)->QDS_FILMAT,(cAlias)->QDS_MAT)
        oDados["items"][nRegistro]["DEPARTAMENTO" ] := PADR(QA_NDEPT((cAlias)->QDS_DEPTO,.F.,(cAlias)->QDS_FILMAT),FWSX3Util():GetFieldStruct('QDS_DEPTO')[3])

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
@author jorge.oliveira
@since 10/10/2023
@version P12.1.2310
@param 01 - lExpResult, logico, Indica se trata todas as colunas como visible para exportação de planilha
@return aColunas  , array   , Array de objetos com as colunas da table po-ui
/*/
Method AdicionaColunasDetalhes(lExpResult) Class AvisosDeDocumentos
    Local aCampos    :={"QDS_DTGERA","QDS_TPPEND","QDS_DOCTO","QDS_RV","QDS_DEPTO","QDS_MAT"}
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

            If cCampo == "QDS_MAT"
                //STR0012 - "Responsável"
                PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"USUARIO",STR0012,"string",lVisivel.OR.lExpResult)
            EndIf

            If cCampo == "QDS_DEPTO"
                //STR0013 - "Departamento"
                PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"DEPARTAMENTO",STR0013,"string",lVisivel.OR.lExpResult)
            EndIf

        EndIf

        If cCampo == "QDS_TPPEND"
            //STR0029 - "Tipo Pendência"
            PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"TIPO_PENDENCA",STR0029,"string",.T.)
        EndIf

    Next nCampo

Return aColunas

/*/{Protheus.doc} MontaComboUsuarioLogado
Cria JSON com os dados para COMBO de Usuário Logado
@type Method
@author jorge.oliveira
@since 17/10/2023
@version P12.1.2310
@param 01 - oParametro, objeto, cria por referência o objeto JSON oFiltros["03_USUARIO_LOGADO"]
@return oParametro, objeto, retorna o objeto criado
/*/
Method MontaComboUsuarioLogado(oParametro) Class AvisosDeDocumentos
    Default oParametro      := JsonObject():New()

    oParametro["opcoes"]  :=       STR0014+":1" //"Sim"+":1"
    oParametro["opcoes"]  += ";" + STR0015+":2" //"Não"+":2" 

Return oParametro

/*/{Protheus.doc} MontaComboMeuDepartamento
Cria JSON com os dados para COMBO de Situação
@type Method
@author jorge.oliveira
@since 17/10/2023
@version P12.1.2310
@param 01 - oParametro, objeto, cria por referência o objeto JSON oFiltros["04_MEU_DEPARTAMENTO"]
@return oParametro, objeto, retorna o objeto criado
/*/
Method MontaComboMeuDepartamento(oParametro) Class AvisosDeDocumentos
    Default oParametro      := JsonObject():New()

    oParametro["opcoes"]  :=       STR0014+":1" //"Sim"+":1"
    oParametro["opcoes"]  += ";" + STR0015+":2" //"Não"+":2" 

Return oParametro

/*/{Protheus.doc} SetaPropriedadeFilial
Adiciona ao objeto de carga do Monitor a propriedade Filial
@type Method
@author jorge.oliveira
@since 17/10/2023
@version P12.1.2310
@param 01 - oCarga , objeto  , instancia do objeto json de carga
@param 02 - cCodigo, caracter, codigo da propriedade
@param 03 - cTitulo, caracter, título da propriedade para exibicao no front-end
@return Nil
/*/
Method SetaPropriedadeFilial(oCarga, cCodigo, cTitulo) Class AvisosDeDocumentos
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
@author jorge.oliveira
@since 17/10/2023
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
Method SetaPropriedadeLookupTabela(oCarga, cCodigo, cLabel, lSelecMult, cTabela, cCampoCod, cCampoDsc, nOrdFil) Class AvisosDeDocumentos
    Local oPrmAdc   := JsonObject():New()
    Local cOrdFil   := Nil
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
    oPrmAdc["colunas"][1]["property"]              := "Code"
    oPrmAdc["colunas"][1]["label"]                 := GetSx3Cache(cCampoCod,"X3_TITULO")
    
    aAdd(oPrmAdc["colunas"], JsonObject():New())
    oPrmAdc["colunas"][2]["property"]              := "Description"
    oPrmAdc["colunas"][2]["label"]                 := GetSx3Cache(cCampoDsc,"X3_TITULO")
    oPrmAdc["labelSelect"]                         := "Code"
    oPrmAdc["valorSelect"]                         := "Code"

    oCarga:setaPropriedade(cCodigo,"",cLabel,8,GetSx3Cache(cCampoCod,"X3_TAMANHO"),0,"po-sm-12 po-md-6 po-lg-6 po-xl-6",/*oEstilos*/,/*cIcone*/,oPrmAdc)
    
    FreeObj(oPrmAdc)

Return

/*/{Protheus.doc} MontaJsonVelocimetro
Monta objeto json com os dados para mostrar o gauge
@type Static Function
@author jorge.oliveira
@since 17/10/2023
@version P12.1.2310
@param 01 - oJson     , objeto json, Objeto json que receberá os dados do gauge
@param 02 - nQtde     , numerico   , quantidade para exibição no monitor
@param 03 - aSemaforo , array      , Array com os números do semáforo
@return Nil
/*/
Method MontaJsonVelocimetro(oJson, nQtde, aSemaforo) Class AvisosDeDocumentos
    Local cDescricao  := Iif(nQtde > 1 .OR. nQtde == 0, STR0016, STR0017) //"Avisos", "Aviso"
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
    oGauge:SetValueStyle("color",AvisosDeDocumentos():RetornaCorSemaforo(nQtde,aSemaforo))
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
@author jorge.oliveira
@since 17/10/2023
@version P12.1.2310
@param 01 - oJson     , objeto json, Objeto json que receberá os dados do gauge
@param 02 - nQtde     , numerico   , quantidade para exibição no monitor
@param 03 - aSemaforo , array      , Array com os números do semáforo
@param 04 - cTpFicha, caracter, comparação para filtro do tipo de ficha
@return Nil
/*/
Method MontaJsonInfo(oJson, nQtde, aSemaforo) Class AvisosDeDocumentos
    Local cDescricao := ""
    Local nIndLinha  := 0
    Local oStyle     := JsonObject():New()
    Local oStyleQtd  := JsonObject():New()

    cDescricao  := Iif(nQtde > 1 .Or. nQtde == 0, STR0016, STR0017) //"Avisos", "Aviso"
   
    oStyle["color"]             := "white"

    oJson["alturaMaximaWidget"] := "500px"
    oJson["alturaMinimaWidget"] := "350px"
    oJson["corTitulo"]          := "white"
    oJson["linhas"]             := {}
    oJson["corFundo"]           := AvisosDeDocumentos():RetornaCorSemaforo(nQtde,aSemaforo)

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
        //STR0018 - "Nenhum Aviso de Documento Pendente."
        PCPMonitorUtils():AdicionaLinhaInformacao(oJson["linhas"],@nIndLinha,STR0018,"po-font-text-large-bold po-text-center po-sm-12 po-pt-4",oStyle:ToJson())

    EndIf

Return oJson

/*/{Protheus.doc} RetornaCorSemaforo
Retorna a cor do semáforo de acordo com a quantidade parametrizada
@type Static Function
@author jorge.oliveira
@since 13/04/2023
@version P12.1.2310
@param 01 - nQtde     , numerico, quantidade exibida no semaforo para análise
@param 02 - aSemaforo , array   , Array com os números do semáforo
@return cCorSemaf , caracter, String com código RGB da cor
/*/
Method RetornaCorSemaforo(nQtde, aSemaforo) Class AvisosDeDocumentos
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

/*/{Protheus.doc} ValidaPropriedades
Valida os dados informados nas propriedades do Monitor
@type Method
@author jorge.oliveira
@since 17/10/2023
@version P12.1.2310
@param  oFiltros, objeto json, Objeto json com os filtros para a consulta dos dados
@return aRetorno, array      , [1] logico - indica se os dados são válidos [2] caracter - mensagem de erro
/*/
Method ValidaPropriedades(oFiltros) Class AvisosDeDocumentos
    Local aRetorno    := {.T., ""}
    Local aSemaforo   := {}
    Local bErrorBlock := Nil
    Local lSemNumero  := .F.
    Local nAux        := 0
    Local nIndSemaf   := 1

    PCPMonitorUtils():ValidaPropriedadeFilial(oFiltros["01_QDS_FILIAL"],aRetorno)

    If aRetorno[1]
        If !oFiltros:HasProperty("02_SEMAFORO") .Or. oFiltros["02_SEMAFORO"] == Nil .Or. Empty(oFiltros["02_SEMAFORO"])
            aRetorno[1] := .F.
            aRetorno[2] := STR0019 //"O campo 'Semáforo' deve ser preenchido com 2 valores separados por ponto e vírgula (ex.: '10;100'), definindo o número de lotes/quantidade que indicam Atenção e Urgência, respectivamente"
        Else
            aSemaforo := StrTokArr(Replace(oFiltros["02_SEMAFORO"],",","."),";")
            If Len(aSemaforo) <> 2
                aRetorno[1] := .F.
                aRetorno[2] := STR0019 //"O campo 'Semáforo' deve ser preenchido com 2 valores separados por ponto e vírgula (ex.: '10;100'), definindo o número de lotes/quantidade que indicam Atenção e Urgência, respectivamente"
            Else
                lSemNumero  := .F.
                bErrorBlock := ErrorBlock({|| lSemNumero := .T.})
                For nIndSemaf := 1 To 2
                    nAux      := Val(aSemaforo[nIndSemaf])
                    If Empty(aSemaforo[nIndSemaf]) .Or. lSemNumero .Or. AllTrim(Str(nAux)) <> AllTrim(aSemaforo[nIndSemaf])
                        aRetorno[1] := .F.
                        aRetorno[2] := STR0019 //"O campo 'Semáforo' deve ser preenchido com 2 valores separados por ponto e vírgula (ex.: '10;100'), definindo o número de lotes/quantidade que indicam Atenção e Urgência, respectivamente"
                    EndIf
                Next nIndSemaf
                ErrorBlock(bErrorBlock)
            EndIf
        EndIf
    EndIf

    FwFreeArray(aSemaforo)

Return aRetorno

/*/{Protheus.doc} MontaWhereQuery
Monta dados WHERE para selecao dos dados da QPK para contagem
@type METHOD
@author jorge.oliveira
@since 10/10/2023
@version P12.1.2310
@param 01 - oFiltros, objeto  , objeto Json de filtros do monitor
@param 02 - dDataIni, data    , data de inicio para filtro
@param 03 - dDataFim, data    , data de fim para filtro
@param 04 - cTpFicha, caracter, comparação para filtro do tipo de ficha
@return cWhere, caracter, string SQL com clausua WHERE para filtro dos dados
/*/
Method MontaWhereQuery(oFiltros, dDataIni, dDataFim, cTpFicha) Class AvisosDeDocumentos
    Local cWhere     := ""

    cWhere += " WHERE "
    cWhere +=         " QDS.QDS_PENDEN = 'P' " 
    cWhere +=     " AND QDS.D_E_L_E_T_ = ' ' " 

    //Tratamento do parâmetro de usuário logado / departamento
    If (!Empty(oFiltros["03_USUARIO_LOGADO"])   .AND. oFiltros["03_USUARIO_LOGADO"] == "1") .OR.;
       (!Empty(oFiltros["04_MEU_DEPARTAMENTO"]) .AND. oFiltros["04_MEU_DEPARTAMENTO"] == "1")
        aUsrMat := QA_USUARIO()
        cMatCod := aUsrMat[3]
        cMatDep := aUsrMat[4]
        cMatFil := aUsrMat[2]

        cWhere += " AND QDS.QDS_FILMAT = '" + cMatFil + "' "

        If !Empty(oFiltros["03_USUARIO_LOGADO"]) .AND. oFiltros["03_USUARIO_LOGADO"] == "1"
            cWhere += " AND QDS.QDS_MAT = '" + cMatCod + "'  "

        EndIf

        If !Empty(oFiltros["04_MEU_DEPARTAMENTO"]) .AND. oFiltros["04_MEU_DEPARTAMENTO"] == "1"
            cWhere += " AND QDS.QDS_DEPTO = '" + cMatDep + "' "

        EndIf

    EndIf

    If !Empty(oFiltros["05_DEPARTAMENTOS_ESPECIFICOS"])
        cWhere +=   " AND (QDS.QDS_DEPTO IN (" + "'" + ArrTokStr(oFiltros["05_DEPARTAMENTOS_ESPECIFICOS"],"', '",0) + "'" + ")) "
    EndIf

    If !Empty(oFiltros["06_TIPO_PENDENCIA"])
        cWhere +=   " AND (QDS.QDS_TPPEND IN (" + "'" + ArrTokStr(oFiltros["06_TIPO_PENDENCIA"],"', '",0) + "'" + ")) "
    EndIf

Return cWhere

/*/{Protheus.doc} RetornaTipoPendencia
Dados personalizados sem tabela de origem, com identificação apenas pelos comentarios usados em QDXGvAviso()
@type METHOD
@author jorge.oliveira
@since 30/10/2023
@version P12.1.2310
@param 01 - cPendencia, caractere  , sigla gravada no campo QDS_TPPEND
@return cDescricaoPendencia, caracter, Descrição completa do Aviso de Pendencia de Documento
/*/
Method RetornaTipoPendencia(cPendencia) Class AvisosDeDocumentos
    Local cDescricaoPendencia as character

    cDescricaoPendencia := ""

    Do Case 
        Case cPendencia == "TMP"
            cDescricaoPendencia := STR0020 //"Ausência Temporária"

        Case cPendencia == "REF"
            cDescricaoPendencia := STR0021 //"Referência para o Elaborador"

        Case cPendencia == "QUE"
            cDescricaoPendencia := STR0022 //"Inclusão de Questionário"

        Case cPendencia == "TRE"
            cDescricaoPendencia := STR0023 //"Necessidade de Realizar Treinamento"

        Case cPendencia == "SID"
            cDescricaoPendencia := STR0024 //"Solicitação de Novo Documento"

        Case cPendencia == "SAD"
            cDescricaoPendencia := STR0025 //"Solicitação de Alteração de Documento"

        Case cPendencia == "CAN"
            cDescricaoPendencia := STR0026 //"Cancelamento de Documento"

        Case cPendencia == "VEN"
            cDescricaoPendencia := STR0027 //"Documento Vencido"

        Case AllTrim(cPendencia) == "TI"
            cDescricaoPendencia := STR0028 //"Agendamento de Treinamento"

    EndCase

Return cDescricaoPendencia

/*/{Protheus.doc} MontaComboTipoPendencia
Cria JSON com os dados para COMBO Tipo de Pendência
@type Method
@author brunno.costa
@since 07/11/2023
@version P12.1.2310
@param 01 - oParametro, objeto, cria por referência o objeto JSON oFiltros["06_TIPO_PENDENCIA"]
@return oParametro, objeto, retorna o objeto criado
/*/
Method MontaComboTipoPendencia(oParametro) Class AvisosDeDocumentos
    Default oParametro      := JsonObject():New()

    oParametro["opcoes"]  :=       STR0028+":TI"  //"Agendamento de Treinamento"
    oParametro["opcoes"]  += ";" + STR0020+":TMP" //"Ausência Temporária"
    oParametro["opcoes"]  += ";" + STR0026+":CAN" //"Cancelamento de Documento"
    oParametro["opcoes"]  += ";" + STR0027+":VEN" //"Documento Vencido"
    oParametro["opcoes"]  += ";" + STR0022+":QUE" //"Inclusão de Questionário"
    oParametro["opcoes"]  += ";" + STR0023+":TRE" //"Necessidade de Realizar Treinamento"
    oParametro["opcoes"]  += ";" + STR0025+":SAD" //"Solicitação de Alteração de Documento"
    oParametro["opcoes"]  += ";" + STR0024+":SID" //"Solicitação de Novo Documento"
    oParametro["opcoes"]  += ";" + STR0021+":REF" //"Referência para o Elaborador"

Return oParametro
