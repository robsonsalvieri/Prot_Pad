#INCLUDE "PendenciasDeDocumentos.CH"
#INCLUDE "QLTMONITORDEF.CH"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} PendenciasDeDocumentos
Classe para prover os dados do Monito de Pendencias de Documentos do Módulo Controle de Documentos (QDO) 
@author thiago.rover
@since 19/10/2023
@version P12.1.2023
@return Nil
/*/
Class PendenciasDeDocumentos FROM LongNameClass
    
    //Métodos Padrões
    Static Method BuscaDados(oFiltros, cTipo, cSubTipo)
	Static Method BuscaDetalhes(oFiltro, nPagina)
	Static Method CargaMonitor()
    Static Method ValidaPropriedades(oFiltros)

    //Métodos Internos
    Static Method AdicionaColunasDetalhes(lExpResult)
    Static Method MontaComboTipoDePendencia(oParametro)
    Static Method MontaComboMeuDepartamento(oParametro)
    Static Method MontaComboMeuUsuario(oParametro)
    Static Method MontaJsonInfo(oJson, nQtde, aSemaforo, cTipoPend)
    Static Method MontaJsonVelocimetro(oJson, nQtde, aSemaforo, cTipoPend)
    Static Method MontaWhereQuery(oFiltros)
    Static Method RetornaCorSemaforo(nQtde, aSemaforo)
    Static Method SetaPropriedadeFilial(oCarga, cCodigo, cTitulo)
    Static Method SetaPropriedadeLookupTabela(oCarga, cCodigo, cLabel, lSelecMult, cTabela, cCampoCod, cCampoDsc, cOrdFil)

EndClass

/*/{Protheus.doc} CargaMonitor
Realiza a carga do Monitor padrão na base de dados
@type Method
@author thiago.rover
@since 20/10/2023
@version P12.1.2310
@return lRet, logico, Indica se conseguiu realizar a carga
/*/
Method CargaMonitor() Class PendenciasDeDocumentos
    Local lRet        := .T.
    Local oCarga      := PCPMonitorCarga():New()
    Local oExemplo    := JsonObject()     :New()
    Local oParametros := JsonObject()     :New()
        
    If !PCPMonitorCarga():monitorAtualizado("PendenciasDeDocumentos")
        
        oCarga:setaTitulo(STR0002) // "Pendências De Documentos"
        oCarga:setaObjetivo(STR0003) // "Apresentar o número de pendências no fluxo de criação de documentos do módulo Controle de Documentos (SIGAQDO) do usuário logado ou de todos os usuários, para o meu departamento ou para todos os departamentos, de uma etapa ou mais etapas do fluxo, utilizando o conceito de semáforo para indicar os níveis Atenção e Urgente."
        oCarga:setaAgrupador(STR0004) // "Qualidade"
        oCarga:setaFuncaoNegocio("PendenciasDeDocumentos")
        oCarga:setaTiposPermitidos("chart;info")
        oCarga:setaTiposGraficoPermitidos("gauge")
        oCarga:setaTipoPadrao("info")
        oCarga:setaTipoGraficoPadrao("")
        oCarga:setaTipoDetalhe("detalhe")

        oExemplo := PendenciasDeDocumentos():MontaJsonInfo(@oExemplo,123,{"10","0"},"3")

        oExemplo["tags"] := {}

        oCarga:setaExemploJsonTexto(.F.,oExemplo)

        // STR0005 - "Filial"
        PendenciasDeDocumentos():SetaPropriedadeFilial(@oCarga, "01_FILIAL", STR0005 + "*")

        // STR0006 - "Atenção"
        // STR0007 - "Urgente"
        // STR0008 - "Semáforo" 
        oCarga:setaPropriedade("02_SEMAFORO", STR0006 + ";" + STR0007, STR0008 + " (" + STR0006 + ";" + STR0007 + ")*",1,30,0,"po-lg-6 po-xl-6 po-md-6 po-sm-12",/*oEstilos*/,/*cIcone*/,/*oParametros*/)
    	
        // STR0010 - "Usuário Logado"
        oCarga:setaPropriedade("03_USUARIO_LOGADO", "", STR0010, 4,,,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,PendenciasDeDocumentos():MontaComboMeuUsuario(oParametros["03_USUARIO_LOGADO"]))

        // STR0013 - "Meu Departamento"
        oCarga:setaPropriedade("04_MEU_DEPARTAMENTO" ,"",STR0013,4,,,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,PendenciasDeDocumentos():MontaComboMeuDepartamento(oParametros["04_MEU_DEPARTAMENTO"]))

        // STR0014 - "Departamentos Específicos"
        PendenciasDeDocumentos():SetaPropriedadeLookupTabela(@oCarga, "05_DEPARTAMENTOS_ESPECIFICOS",STR0014,.T.,"QAD","QAD_CUSTO","QAD_DESC",1)

        // STR0015 - "Tipo de Pendência"
        oCarga:setaPropriedade("06_TIPO_PENDENCIA", "", STR0015,5,,,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,PendenciasDeDocumentos():MontaComboTipoDePendencia(oParametros["06_TIPO_PENDENCIA"]))

        lRet := iif(oCarga:gravaMonitorPropriedades(), lRet, .F.)

        oCarga:Destroy()
    EndIf
    FreeObj(oExemplo)
    FreeObj(oParametros)
Return lRet


/*/{Protheus.doc} BuscaDados
Responsável por realizar a busca dos dados que serão exibidos no monitor (gráfico ou texto)

@type Class
@author thiago.rover
@since 09/02/2023
@version P12.1.2310
@param 01 - oFiltros, objeto Json, Contém as propriedades do monitor usadas para filtrar a query de busca
@param 02 - cTipo   , caracter   , Tipo chart/info
@param 03 - cSubTipo, caracter   , Tipo de grafico pie/bar/column
@return cJsonDados, caracter   , Retorna um novo Json em formato texto, pronto para conversão e exibição no front
/*/
Method BuscaDados(oFiltros, cTipo, cSubTipo) Class PendenciasDeDocumentos
    Local aSemaforo        := StrTokArr(Replace(oFiltros["02_SEMAFORO"],",","."),";")
    Local cAlias           := Nil
    Local cQuery           := ""
    Local nIndTag          := 0
    Local nQtde            := 0
    Local oJson            := JsonObject():New()
    Local oQLTQueryManager := QLTQueryManager():New()

    oFiltros["01_FILIAL"] := PadR(oFiltros["01_FILIAL"], FWSizeFilial())

    cQuery += " SELECT COUNT(*) QTDE "
    cQuery += " FROM "+RetSqlName("QDH")+" QDH "
    cQuery += PendenciasDeDocumentos():MontaWhereQuery(oFiltros)
    
    cQuery := oQLTQueryManager:ChangeQuery(cQuery)
    cAlias := oQLTQueryManager:ExecuteQuery(cQuery)

    nQtde := iif((cAlias)->(!Eof()), (cAlias)->QTDE, nQtde)

    (cAlias)->(dbCloseArea())

    If cTipo == "info"
        oJson := PendenciasDeDocumentos():MontaJsonInfo(@oJson,nQtde,aSemaforo,oFiltros["06_TIPO_PENDENCIA"])
    Else
        oJson := PendenciasDeDocumentos():MontaJsonVelocimetro(@oJson,nQtde,aSemaforo,oFiltros["06_TIPO_PENDENCIA"])
    EndIf

    oJson["tags"] := {}

    If (!Empty(oFiltros["03_USUARIO_LOGADO"])   .AND. oFiltros["03_USUARIO_LOGADO"] == "1") .OR.;
       (!Empty(oFiltros["04_MEU_DEPARTAMENTO"]) .AND. oFiltros["04_MEU_DEPARTAMENTO"] == "1")
        aUsrMat := QA_USUARIO()
        cMatFil := aUsrMat[2]
        cMatCod := aUsrMat[3]
        cMatDep := aUsrMat[4]
    EndIf

    If !Empty(oFiltros["03_USUARIO_LOGADO"]) .AND. oFiltros["03_USUARIO_LOGADO"] == "1"
        PCPMonitorUtils():AdicionaTagMonitor(oJson["tags"],@nIndTag,"po-icon-user",QA_NUSR(cMatFil,cMatCod))
    EndIf

    If !Empty(oFiltros["04_MEU_DEPARTAMENTO"]) .AND. oFiltros["04_MEU_DEPARTAMENTO"] == "1"
        PCPMonitorUtils():AdicionaTagMonitor(oJson["tags"],@nIndTag,"po-icon-company",AllTrim(QA_NDEPT(cMatDep,.T., xFilial("QAD", oFiltros["01_FILIAL"]))))
    EndIf

    FwFreeArray(aSemaforo)
Return oJson:toJson()

/*/{Protheus.doc} BuscaDetalhes
Realiza a busca dos dados para montar os detalhes do Monitor
@type Method
@author thiago.rover
@since 20/10/2023
@version P12.1.2310
@param 01 - oFiltros, objeto, objeto json com os filtros da consulta 
@param 02 - nPagina , número, número de página da consulta
@return cJson, string Json, string com os dados de detalhes para exibição em tabela de detalhes
/*/
Method BuscaDetalhes(oFiltros, nPagina) Class PendenciasDeDocumentos
    Local aCampos          := {"QDH_DOCTO", "QDH_RV", "QDH_TITULO", "QD1_DTGERA", "QDH_DTVIG", "QDH_DTIMPL", "QDH_DTLIM", "QDH_CODTP"}
    Local aUsrMat          := {}
    Local cAlias           := Nil
    Local cCampo           := ""
    Local cCodDep          := ""
    Local cMatCod          := ""
    Local cMatDep          := ""
    Local cMatFil          := ""
    Local cParamDet        := ""
    Local cQuery           := ""
    Local lExpResult       := .F.
    Local nCampo           := 0
    Local nCampos          := Len(aCampos)
    Local nIndTag          := 0
    Local nPos             := 0
    Local nStart           := 1
    Local nTamPagina       := 20
    Local oDados           := JsonObject():New()
    Local oQLTQueryManager := QLTQueryManager():New()

    Private Inclui   := .F.

    Default nPagina  := 1

    cParamDet := IIF(oFiltros:HasProperty("PARAMETROSDETALHE"),oFiltros["PARAMETROSDETALHE"],"")
    cCodDep   := oFiltros["04_MEU_DEPARTAMENTO"]
    
    lExpResult := iif(nPagina == 0, .T., lExpResult)

    cQuery += " SELECT QDH.QDH_CODTP, QDH.QDH_DOCTO, QDH.QDH_RV, QDH.QDH_TITULO, QD1.QD1_TPPEND, QDH.QDH_FILIAL, QD1.QD1_DTGERA, "
    cQuery +=        " QDH.QDH_DTVIG, QDH.QDH_DTIMPL, QDH.QDH_DTLIM, QD1.QD1_FILMAT, QD1.QD1_MAT, QD1.QD1_DEPTO "
    cQuery += " FROM "+RetSqlName("QDH")+" QDH "
    cQuery += PendenciasDeDocumentos():MontaWhereQuery(oFiltros)

    cQuery += iif(!Empty(cParamDet), " AND " + cParamDet, "")

    cQuery += " ORDER BY QDH.QDH_DOCTO, QDH.QDH_RV, QD1.QD1_DEPTO, QD1.QD1_MAT, QD1.QD1_TPPEND DESC "

    cQuery := oQLTQueryManager:ChangeQuery(cQuery)
    cAlias := oQLTQueryManager:ExecuteQuery(cQuery)
    
    nStart := iif(nPagina > 1, ( (nPagina-1) * nTamPagina ), nStart)

    iif(nPagina > 1 .And. nStart > 0, (cAlias)->(DbSkip(nStart)), NIL)

    oDados["items"]        := {}
    oDados["columns"]      := PendenciasDeDocumentos():AdicionaColunasDetalhes(lExpResult)
    oDados["canExportCSV"] := .T.
    oDados["tags"]         := {}
 
    If (!Empty(oFiltros["03_USUARIO_LOGADO"])   .AND. oFiltros["03_USUARIO_LOGADO"] == "1") .OR.;
       (!Empty(oFiltros["04_MEU_DEPARTAMENTO"]) .AND. oFiltros["04_MEU_DEPARTAMENTO"] == "1")
        aUsrMat := QA_USUARIO()
        cMatFil := aUsrMat[2]
        cMatCod := aUsrMat[3]
        cMatDep := aUsrMat[4]
    EndIf

    If !Empty(oFiltros["03_USUARIO_LOGADO"]) .AND. oFiltros["03_USUARIO_LOGADO"] == "1"
        PCPMonitorUtils():AdicionaTagMonitor(oDados["tags"],@nIndTag,"po-icon-user",QA_NUSR(cMatFil,cMatCod))
    EndIf

    If !Empty(oFiltros["04_MEU_DEPARTAMENTO"]) .AND. oFiltros["04_MEU_DEPARTAMENTO"] == "1"
        PCPMonitorUtils():AdicionaTagMonitor(oDados["tags"],@nIndTag,"po-icon-company",AllTrim(QA_NDEPT(cMatDep,.T., xFilial("QAD", oFiltros["01_FILIAL"]))))
    EndIf

    While (cAlias)->(!Eof())
        aAdd(oDados["items"], JsonObject():New())

        nPos++
        For nCampo := 1 to nCampos
            cCampo                          := aCampos[nCampo]
            oDados["items"][nPos][cCampo]   := (cAlias)->&(cCampo)
        Next nCampo

        oDados["items"][nPos]["QD1_TPPEND"]   := AllTrim((cAlias)->QD1_TPPEND)
        oDados["items"][nPos]["DEPARTAMENTO"] := AllTrim(QA_NDEPT((cAlias)->QD1_DEPTO,.T., (cAlias)->QD1_FILMAT)) 
        oDados["items"][nPos]["RESPONSAVEL"]  := QA_NUSR((cAlias)->QD1_FILMAT,(cAlias)->QD1_MAT)
        oDados["items"][nPos]["QDH_DESCTP"]   := QDXFNANTPD((cAlias)->QDH_CODTP,,(cAlias)->QDH_FILIAL)
        oDados["items"][nPos]["QD1_DTGERA"]  := PCPMonitorUtils():FormataData((cAlias)->QD1_DTGERA,4)
        oDados["items"][nPos]["QDH_DTVIG"]   := PCPMonitorUtils():FormataData((cAlias)->QDH_DTVIG,4)
        oDados["items"][nPos]["QDH_DTIMPL"]  := PCPMonitorUtils():FormataData((cAlias)->QDH_DTIMPL,4)
        oDados["items"][nPos]["QDH_DTLIM"]   := PCPMonitorUtils():FormataData((cAlias)->QDH_DTLIM,4)
        
        (cAlias)->(dbSkip())

        IF !lExpResult .And. nPos >= nTamPagina
            Exit
        EndIf
    End
    oDados["hasNext"] := (cAlias)->(!Eof())
    (cAlias)->(dbCloseArea())
Return oDados:ToJson()

/*/{Protheus.doc} AdicionaColunasDetalhes
Cria array de objetos no formato poTableColumn com as colunas da table de detalhamento
@type METHOD
@author thiago.rover
@since 10/10/2023
@version P12.1.2310
@param 01 - lExpResult, logico, Indica se trata todas as colunas como visible para exportação de planilha
@return aColunas  , array   , Array de objetos com as colunas da table po-ui
/*/
Method AdicionaColunasDetalhes(lExpResult) Class PendenciasDeDocumentos
    Local aCampos    := {"QDH_DESCTP", "QDH_TITULO", "QDH_RV", "QD1_DTGERA", "QDH_DTVIG", "QDH_DTIMPL", "QDH_DTLIM"}
    Local aColunas   := {}
    Local aLabelP    := {}
    Local cTipo      := ""
    Local lVisivel   := .T.
    Local nCampo     := 0
    Local nCampos    := Len(aCampos)
    Local nIndice    := 0
    Local nIndLblLeg := 0

    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabelP,@nIndLblLeg,"A" ,COR_BRANCO, STR0027, COR_PRETO)   //"Aprovado"                   
    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabelP,@nIndLblLeg,"D" ,COR_BRANCO, STR0022, COR_PRETO)   //"Digitação"
    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabelP,@nIndLblLeg,"DC",COR_BRANCO, STR0023, COR_PRETO)   //"Digitação c/ Critica"
    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabelP,@nIndLblLeg,"E" ,COR_BRANCO, STR0024, COR_PRETO)   //"Elaboração"      
    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabelP,@nIndLblLeg,"EC",COR_BRANCO, STR0025, COR_PRETO)   //"Elaboração c/ Critica"      
    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabelP,@nIndLblLeg,"H" ,COR_BRANCO, STR0028, COR_PRETO)   //"Homologação"      
    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabelP,@nIndLblLeg,"L" ,COR_BRANCO, STR0029, COR_PRETO)   //"Leitura"      
    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabelP,@nIndLblLeg,"I" ,COR_BRANCO, STR0036, COR_PRETO)   //"Distribuição"      
    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabelP,@nIndLblLeg,"R" ,COR_BRANCO, STR0026, COR_PRETO)   //"Revisão"      

    For nCampo := 1 to nCampos
        cCampo := aCampos[nCampo]
        If X3Uso(GetSx3Cache(cCampo,"X3_USADO"),24)
            cTipo := GetSx3Cache(cCampo,"X3_TIPO")

            cTipo := iif(cTipo == "C", "string", cTipo)
            cTipo := iif(cTipo == "D", "date", cTipo)
            
            lVisivel := GetSx3Cache(cCampo,"X3_BROWSE") != "N"
            PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,cCampo,GetSx3Cache(cCampo,"X3_TITULO"),cTipo,lVisivel.OR.lExpResult)

            If cCampo == "QDH_RV"
                PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"QD1_TPPEND",STR0015,"cellTemplate"  ,.T.,.T.,aLabelP) //"Tipo de Pendência"
            Endif

            If cCampo == "QDH_RV"
                PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"DEPARTAMENTO",STR0038,"string",.T.) //"Depart. Responsável"
            EndIf
           
            If cCampo == "QDH_RV"
                PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"RESPONSAVEL",STR0039,"string",.T.) //"Responsável"
            EndIf
        EndIf
    Next nCampo

Return aColunas

/*/{Protheus.doc} MontaComboMeuUsuario
Cria JSON com os dados para COMBO de Meu Usuário
@type Method
@author thiago.rover
@since 23/10/2023
@version P12.1.2310
@param 01 - oParametro, objeto, cria por referência o objeto JSON oFiltros["03_USUARIO_LOGADO"]
@return oParametro, objeto, retorna o objeto criado
/*/
Method MontaComboMeuUsuario(oParametro) Class PendenciasDeDocumentos
    Default oParametro := JsonObject():New()
    oParametro["opcoes"] :=       STR0016+":1" // STR0016 - "Sim"
    oParametro["opcoes"] += ";" + STR0017+":2" // STR0017 - "Não, todos"
Return oParametro

/*/{Protheus.doc} MontaComboMeuDepartamento
Cria JSON com os dados para COMBO de Meu Departamento
@type Method
@author thiago.rover
@since 20/10/2023
@version P12.1.2310
@param 01 - oParametro, objeto, cria por referência o objeto JSON oFiltros["04_MEU_DEPARTAMENTO"]
@return oParametro, objeto, retorna o objeto criado
/*/
Method MontaComboMeuDepartamento(oParametro) Class PendenciasDeDocumentos
    Default oParametro := JsonObject():New()
    oParametro["opcoes"] :=       STR0016+":1" // STR0016 - "Sim"
    oParametro["opcoes"] += ";" + STR0017+":2" // STR0017 - "Não, todos"
Return oParametro

/*/{Protheus.doc} MontaComboTipoDePendencia
Cria JSON com os dados para COMBO Tipo de Pendência
@type Method
@author thiago.rover
@since 23/10/2023
@version P12.1.2310
@param 01 - oParametro, objeto, cria por referência o objeto JSON oFiltros["06_TIPO_PENDENCIA"]
@return oParametro, objeto, retorna o objeto criado
/*/
Method MontaComboTipoDePendencia(oParametro) Class PendenciasDeDocumentos
    Default oParametro      := JsonObject():New()
    oParametro["opcoes"] :=       STR0027+":A"  // STR0027 - "Aprovação"
    oParametro["opcoes"] += ";" + STR0022+":D"  // STR0022 - "Digitação"
    oParametro["opcoes"] += ";" + STR0023+":DC" // STR0023 - "Digitação com Crítica"
    oParametro["opcoes"] += ";" + STR0024+":E"  // STR0024 - "Elaboração"
    oParametro["opcoes"] += ";" + STR0025+":EC" // STR0025 - "Elaboração com Crítica"
    oParametro["opcoes"] += ";" + STR0026+":R"  // STR0026 - "Revisão"
    oParametro["opcoes"] += ";" + STR0028+":H"  // STR0028 - "Homologação"
    oParametro["opcoes"] += ";" + STR0036+":I"  // STR0036 - "Distribuição"
    oParametro["opcoes"] += ";" + STR0029+":L"  // STR0029 - "Leitura"
    
Return oParametro

/*/{Protheus.doc} SetaPropriedadeFilial
Adiciona ao objeto de carga do Monitor a propriedade Filial
@type Method
@author thiago.rover
@since 20/10/2023
@version P12.1.2310
@param 01 - oCarga , objeto  , instancia do objeto json de carga
@param 02 - cCodigo, caracter, codigo da propriedade
@param 03 - cTitulo, caracter, título da propriedade para exibicao no front-end
@return Nil
/*/
Method SetaPropriedadeFilial(oCarga, cCodigo, cTitulo) Class PendenciasDeDocumentos
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
@author thiago.rover
@since 20/10/2023
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
Method SetaPropriedadeLookupTabela(oCarga, cCodigo, cLabel, lSelecMult, cTabela, cCampoCod, cCampoDsc, nOrdFil) Class PendenciasDeDocumentos
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
@author thiago.rover
@since 20/10/2023
@version P12.1.2310
@param 01 - oJson     , objeto json, Objeto json que receberá os dados do gauge
@param 02 - nQtde     , numerico   , quantidade para exibição no monitor
@param 03 - aSemaforo , array      , Array com os números do semáforo
@param 04 - cTipoPend, caracter, comparação para filtro do tipo de ficha
@return Nil
/*/
Method MontaJsonVelocimetro(oJson, nQtde, aSemaforo, cTipoPend) Class PendenciasDeDocumentos
    Local cDescricao  := Iif(nQtde > 1, STR0030, STR0031) // STR0030 - "Pendencias" - STR0031 - "Pendencia"
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
    oGauge:SetValueStyle("color",PendenciasDeDocumentos():RetornaCorSemaforo(nQtde,aSemaforo))
    oGauge:SetValueStyle("font-weight","bold")
    oGauge:SetLabel(cDescricao)
    oGauge:SetLabelStyle("font-weight","bold")

    If lMenorVerde

        nValorFim := iif(nQtde > nValSemaf2, nQtde + (nValSemaf2 - nValSemaf1), nValSemaf2 + (nValSemaf2 - nValSemaf1))
        
        cValorFim := cValToChar(nValorFim)
        oGauge:SetMaxValue(nValorFim)
        oGauge:SetThreshold("0",COR_VERDE_FORTE)
        oGauge:SetThreshold(cValSemaf1,COR_AMARELO_QUEIMADO)
        oGauge:SetThreshold(cValSemaf2,COR_VERMELHO_FORTE)
    Else
        nValorFim := iif(nQtde > nValSemaf1, nQtde + (nValSemaf1 - nValSemaf2), nValSemaf1 + nValSemaf2)

        cValorFim := cValToChar(nValorFim)
        oGauge:SetMaxValue(nValorFim)
        oGauge:SetThreshold("0",COR_VERMELHO_FORTE)
        oGauge:SetThreshold(cValSemaf2,COR_AMARELO_QUEIMADO)
        oGauge:SetThreshold(cValSemaf1,COR_VERDE_FORTE)
    EndIf

    iif(Val(cValSemaf1) > 0, oGauge:SetMarker("0"), Nil)

    oGauge:SetMarker(cValSemaf1)
    oGauge:SetMarker(cValSemaf2)
    oGauge:SetMarker(cValorFim)

    oJson["gauge"] := oGauge:GetJsonObject()
    FreeObj(oGauge)
Return oJson

/*/{Protheus.doc} MontaJsonInfo
Monta objeto json com os dados para mostrar o gráfico de informações
@type Static Function
@author thiago.rover
@since 20/10/2023
@version P12.1.2310
@param 01 - oJson     , objeto json, Objeto json que receberá os dados do gauge
@param 02 - nQtde     , numerico   , quantidade para exibição no monitor
@param 03 - aSemaforo , array      , Array com os números do semáforo
@param 04 - cTipoPend, caracter, comparação para filtro do tipo de ficha
@return Nil
/*/
Method MontaJsonInfo(oJson, nQtde, aSemaforo, cTipoPend) Class PendenciasDeDocumentos

    Local cDescricao  := Iif(nQtde > 1, STR0030, STR0031) // STR0030 - "Pendências" - STR0031 - "Pendência"
    Local nIndLinha  := 0
    Local oStyle     := JsonObject():New()
    Local oStyleQtd  := JsonObject():New()

    oStyle["color"]             := "white"
    oJson["alturaMaximaWidget"] := "500px"
    oJson["alturaMinimaWidget"] := "350px"
    oJson["corTitulo"]          := "white"
    oJson["linhas"]             := {}
    oJson["corFundo"]           := PendenciasDeDocumentos():RetornaCorSemaforo(nQtde,aSemaforo)

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
        //STR0037 - "Nenhuma pendência de documento foi localizada a partir dos filtros preenchidos."
        PCPMonitorUtils():AdicionaLinhaInformacao(oJson["linhas"],@nIndLinha,STR0037,"po-font-text-large-bold po-text-center po-sm-12 po-pt-4",oStyle:ToJson())
    EndIf

Return oJson

/*/{Protheus.doc} RetornaCorSemaforo
Retorna a cor do semáforo de acordo com a quantidade parametrizada
@type Static Function
@author thiago.rover
@since 13/04/2023
@version P12.1.2310
@param 01 - nQtde     , numerico, quantidade exibida no semaforo para análise
@param 02 - aSemaforo , array   , Array com os números do semáforo
@return cCorSemaf , caracter, String com código RGB da cor
/*/
Method RetornaCorSemaforo(nQtde, aSemaforo) Class PendenciasDeDocumentos
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
@author thiago.rover
@since 20/10/2023
@version P12.1.2310
@param  oFiltros, objeto json, Objeto json com os filtros para a consulta dos dados
@return aRetorno, array      , [1] logico - indica se os dados são válidos [2] caracter - mensagem de erro
/*/
Method ValidaPropriedades(oFiltros) Class PendenciasDeDocumentos
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
            aRetorno[2] := STR0032 //"O campo 'Semáforo' deve ser preenchido com 2 valores separados por ponto e vírgula (ex.: '10;100'), definindo o número de lotes/quantidade que indicam Atenção e Urgência, respectivamente" 
        Else 
            aSemaforo := StrTokArr(Replace(oFiltros["02_SEMAFORO"],",","."),";")
            If Len(aSemaforo) <> 2
                aRetorno[1] := .F.
                aRetorno[2] := STR0032 //"O campo 'Semáforo' deve ser preenchido com 2 valores separados por ponto e vírgula (ex.: '10;100'), definindo o número de lotes/quantidade que indicam Atenção e Urgência, respectivamente" 
            Else
                lSemNumero  := .F.
                bErrorBlock := ErrorBlock({|| lSemNumero := .T.})
                For nIndSemaf := 1 To 2
                    nAux      := Val(aSemaforo[nIndSemaf])
                    If Empty(aSemaforo[nIndSemaf]) .Or. lSemNumero .Or. AllTrim(Str(nAux)) <> AllTrim(aSemaforo[nIndSemaf])
                        aRetorno[1] := .F.
                        aRetorno[2] := STR0032 //"O campo 'Semáforo' deve ser preenchido com 2 valores separados por ponto e vírgula (ex.: '10;100'), definindo o número de lotes/quantidade que indicam Atenção e Urgência, respectivamente" 061
                        Exit
                    EndIf
                Next nIndSemaf
                ErrorBlock(bErrorBlock)
            EndIf
        EndIf
    EndIf

    FwFreeArray(aSemaforo)
Return aRetorno

/*/{Protheus.doc} MontaWhereQuery
Monta dados WHERE para selecao dos dados da QDH para contagem
@type METHOD
@author thiago.rover
@since 10/10/2023
@version P12.1.2310
@param 01 - oFiltros, objeto  , objeto Json de filtros do monitor
@return cWhere, caracter, string SQL com clausua WHERE para filtro dos dados
/*/
Method MontaWhereQuery(oFiltros) Class PendenciasDeDocumentos
    
    Local cFilAux    := PadR(oFiltros["01_FILIAL"], FWSizeFilial())
    Local cWhere     := ""
    Local aUsrMat    := QA_USUARIO()
    Local cMatCod    := aUsrMat[3]
    Local cMatDep    := aUsrMat[4]

    cWhere += " INNER JOIN " +RetSqlName("QD1")+" QD1 ON QD1.QD1_DOCTO = QDH.QDH_DOCTO AND QD1.QD1_RV = QDH.QDH_RV "
    cWhere +=    " WHERE QD1_PENDEN = 'P' " 
    cWhere +=    " AND QD1.QD1_FILIAL = '"+xFilial("QD1", cFilAux)+"' "   
    cWhere +=    " AND QD1.QD1_TPDIST IN ('1','3') "

    IF (!Empty(oFiltros["03_USUARIO_LOGADO"]) .AND. oFiltros["03_USUARIO_LOGADO"] == "1") .OR. ;   // Usuário Logado
       (!Empty(oFiltros["04_MEU_DEPARTAMENTO"]) .AND. oFiltros["04_MEU_DEPARTAMENTO"] == "1") // Meu Departamento 
        cWhere += " AND QDH.QDH_FILIAL = '" + xFilial("QDH", cFilAux) + "' "
    Endif

    IF (!Empty(oFiltros["03_USUARIO_LOGADO"]) .AND. oFiltros["03_USUARIO_LOGADO"] == "1")  // Usuário Logado
        cWhere += " AND QDH.QDH_MAT = '" + cMatCod + "' "
    Endif

    If !Empty(oFiltros["04_MEU_DEPARTAMENTO"]) .AND. oFiltros["04_MEU_DEPARTAMENTO"] == "1" // Meu Departamento
        cWhere += " AND QDH.QDH_DEPTOE = '" + cMatDep +"' "
    EndIf

    If !Empty(oFiltros["05_DEPARTAMENTOS_ESPECIFICOS"]) // Departamento Especifico
        cWhere += " AND QDH.QDH_DEPTOE IN (" + "'" + ArrTokStr(oFiltros["05_DEPARTAMENTOS_ESPECIFICOS"],"', '",0) + "'" + ") "
    EndIf

    IF !Empty(oFiltros["06_TIPO_PENDENCIA"]) // Tipo de Pendencia
        cWhere += " AND RTRIM(QD1.QD1_TPPEND) IN (" + "'" + ArrTokStr(oFiltros["06_TIPO_PENDENCIA"],"', '",0) + "'" + ") "
    Endif

    cWhere +=  " AND QDH.D_E_L_E_T_ = ' ' "
    cWhere +=  " AND QD1.D_E_L_E_T_ = ' ' "

Return cWhere
