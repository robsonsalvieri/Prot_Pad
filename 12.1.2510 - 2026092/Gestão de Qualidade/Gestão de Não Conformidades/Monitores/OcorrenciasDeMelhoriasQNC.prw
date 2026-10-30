#INCLUDE "TOTVS.CH"
#INCLUDE "QLTMONITORDEF.CH"
#INCLUDE "OcorrenciasDeMelhoriasQNC.CH"

/*/{Protheus.doc} OcorrenciasDeMelhoriasQNC
Classe para prover os dados do Monitor de Ocorrências de Melhoria do Módulo Controle de Não Conformidades (QNC)
@type Class
@author brunno.costa
@since 17/10/2023
@version P12.1.2310
@return Nil
/*/
Class OcorrenciasDeMelhoriasQNC FROM LongNameClass
	
    //Métodos Padrões
    Static Method BuscaDados(oFiltros, cTipo, cSubTipo, cTpFicha)
	Static Method BuscaDetalhes(oFiltro, nPagina, cTpFicha)
	Static Method CargaMonitor()
    Static Method ValidaPropriedades(oFiltros)

    //Métodos Internos
    Static Method AdicionaColunasDetalhes(lExpResult)
    Static Method ConverteEmNumero(oValor)
    Static Method MontaComboModuloOrigem(oParametro)
    Static Method MontaComboPeriodos(oParametro)
    Static Method MontaComboSituacao(oParametro)
    Static Method MontaComboStatus(oParametro)
    Static Method MontaComboStatusPlanoDeAcao(oParametro)
    Static Method MontaJsonInfo(oJson, nQtde, aSemaforo, cTpFicha)
    Static Method MontaJsonVelocimetro(oJson, nQtde, aSemaforo, cTpFicha)
    Static Method MontaWhereQuery(oFiltros, dDataIni, dDataFim, cTpFicha)
    Static Method RetornaCorSemaforo(nQtde, aSemaforo)
    Static Method RetornaPeriodoInicial(cFiltro, dDataFim, nPersonal)
    Static Method RetornaStatusPlanoDeAcao(cFilQI2, cPlano, cRev)
    Static Method SetaPropriedadeFilial(cCodigo, cTitulo)
    Static Method SetaPropriedadeLookupTabela(oCarga, cCodigo, cLabel, lSelecMult, cTabela, cCampoCod, cCampoDsc, cOrdFil)
EndClass

/*/{Protheus.doc} CargaMonitor
Realiza a carga do Monitor padrão na base de dados
@type Method
@author brunno.costa
@since 17/10/2023
@version P12.1.2310
@return lRet, logico, Indica se conseguiu realizar a carga
/*/
Method CargaMonitor() Class OcorrenciasDeMelhoriasQNC
    Local lRet        := .T.
    Local nIndTag     := 0
    Local oCarga      := PCPMonitorCarga():New()
    Local oExemplo    := JsonObject()     :New()
    Local oParametros := JsonObject()     :New()
        
    If !PCPMonitorCarga():monitorAtualizado("OcorrenciasDeMelhoriasQNC")
        
        oCarga:setaTitulo(STR0001) //"Ocorrências de Melhorias QNC"
        oCarga:setaObjetivo(STR0002) //"Apresentar o número de Ocorrências de Melhoria do módulo Controle de Não Conformidades com origem de um módulo específico ou de qualquer módulo, de um determinado Departamento Origem ou Destino ou qualquer departamento, dentro de um período configurado, utilizando o conceito de semáforo para indicar os níveis Aceitável, Atenção e Crítico."
        oCarga:setaAgrupador(STR0003) //"Qualidade"
        oCarga:setaFuncaoNegocio("OcorrenciasDeMelhoriasQNC")
        oCarga:setaTiposPermitidos("chart;info")
        oCarga:setaTiposGraficoPermitidos("gauge")
        oCarga:setaTipoPadrao("info")
        oCarga:setaTipoGraficoPadrao("")
        oCarga:setaTipoDetalhe("detalhe")

        oExemplo := OcorrenciasDeMelhoriasQNC():MontaJsonInfo(@oExemplo,123,{"10","0"},"3")

        oExemplo["tags"] := {}
        PCPMonitorUtils():AdicionaTagMonitor(oExemplo["tags"],@nIndTag,"po-icon-calendar",DtoC(dDataBase-180) + " - " + DtoC(dDataBase))

        oCarga:setaExemploJsonTexto(.F.,oExemplo)

        //STR0004 - "Filial Ocorrência"
        OcorrenciasDeMelhoriasQNC():SetaPropriedadeFilial(@oCarga, "01_QI2_FILIAL", STR0004 + "*")

        //STR0005 - Atenção
        //STR0006 - Urgente
        //STR0007 - Semáforo
        oCarga:setaPropriedade("02_SEMAFORO", STR0005 + ";" + STR0006, STR0007 + " (" + STR0005 + ";" + STR0006 + ")*",1,30,0,"po-lg-6 po-xl-6 po-md-6 po-sm-12",/*oEstilos*/,/*cIcone*/,/*oParametros*/)

        //STR0008 - "Módulo Origem"
        oCarga:setaPropriedade("03_MODULOORIGEM" ,"",STR0008,5,,,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,OcorrenciasDeMelhoriasQNC():MontaComboModuloOrigem(oParametros["03_MODULOORIGEM"]))
        
        //STR0009 - "Período"
        oCarga:setaPropriedade("04_TIPOPERIODO","",STR0009 + "*",4,,,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,OcorrenciasDeMelhoriasQNC():MontaComboPeriodos(oParametros["04_TIPOPERIODO"]))

        //STR0010 - STR0011 - "Período personalizado (anos)"
        oCarga:setaPropriedade("05_PERIODO_PERSONALIZADO","9",STR0010 + " (" + STR0011 + ")",2,1,0,"po-lg-6 po-xl-6 po-md-6 po-sm-12")

        //STR0012 - "Situação Ocorrência"
        oCarga:setaPropriedade("06_SITUACAO" ,"",STR0012,5,,,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,OcorrenciasDeMelhoriasQNC():MontaComboSituacao(oParametros["06_SITUACAO"]))

        //STR0013 - "Filial Origem"
        OcorrenciasDeMelhoriasQNC():SetaPropriedadeFilial(@oCarga, "07_QI2_FILORI", STR0013)
        
        //STR0014 - "Departamento Origem"
        OcorrenciasDeMelhoriasQNC():SetaPropriedadeLookupTabela(@oCarga, "08_QI2_ORIDEP",STR0014,.F.,"QAD","QAD_CUSTO","QAD_DESC",7)

        //STR0015 - "Filial Destino"
        OcorrenciasDeMelhoriasQNC():SetaPropriedadeFilial(@oCarga, "09_QI2_FILDEP", STR0015)
        
        //STR0016 - "Departamento Origem"
        OcorrenciasDeMelhoriasQNC():SetaPropriedadeLookupTabela(@oCarga, "10_QI2_DESDEP",STR0016,.F.,"QAD","QAD_CUSTO","QAD_DESC",9)

        //STR0017 - "Status"
        oCarga:setaPropriedade("11_STATUS","",STR0017,5,,,"po-lg-12 po-xl-12 po-md-12 po-sm-12",,,OcorrenciasDeMelhoriasQNC():MontaComboStatus(oParametros["11_STATUS"]))

        //STR0065 - "Status Plano de Ação"
        oCarga:setaPropriedade("12_STATUS_PA","",STR0065,5,,,"po-lg-12 po-xl-12 po-md-12 po-sm-12",,,OcorrenciasDeMelhoriasQNC():MontaComboStatusPlanoDeAcao(oParametros["12_STATUS_PA"]))

        lRet := iif(oCarga:gravaMonitorPropriedades(), lRet, .F.)
        oCarga:Destroy()
    EndIf
    FreeObj(oExemplo)
    FreeObj(oParametros)
Return lRet

/*/{Protheus.doc} BuscaDados
Responsável por realizar a busca dos dados que serão exibidos no monitor (gráfico ou texto)

@type Class
@author brunno.costa
@since 09/02/2023
@version P12.1.2310
@param 01 - oFiltros, objeto Json, Contém as propriedades do monitor usadas para filtrar a query de busca
@param 02 - cTipo   , caracter   , Tipo chart/info
@param 03 - cSubTipo, caracter   , Tipo de grafico pie/bar/column
@param 04 - cTpFicha, caracter, comparação para filtro do tipo de ficha
@return cJsonDados, caracter   , Retorna um novo Json em formato texto, pronto para conversão e exibição no front
/*/
Method BuscaDados(oFiltros, cTipo, cSubTipo, cTpFicha) Class OcorrenciasDeMelhoriasQNC
    Local aSemaforo        := StrTokArr(Replace(oFiltros["02_SEMAFORO"],",","."),";")
    Local cAlias           := Nil
    Local cQuery           := ""
    Local dDataFim         := dDataBase
    Local dDataIni         := dDataBase
    Local lTMKPMS          := .F. //Integração do QNC com TMK e PMS: 1-Sem Integração,2-TMKxQNC,3-QNCxPMS,4-TMKxQNCxPMS ³
    Local nAux             := 0
    Local nIndTag          := 0
    Local nMVQTMKPMS       := SuperGetMv("MV_QTMKPMS",.F.,1)
    Local nQtde            := 0
    Local oJson            := JsonObject()     :New()
    Local oQLTQueryManager := QLTQueryManager():New()

    Default cTpFicha := "3"

    oFiltros["01_QI2_FILIAL"] := PadR(oFiltros["01_QI2_FILIAL"], FWSizeFilial())

    dDataFim                  := dDatabase
    dDataIni                  := OcorrenciasDeMelhoriasQNC():RetornaPeriodoInicial(oFiltros["04_TIPOPERIODO"],;
                                                                                      dDataFim,;
                                                                                      OcorrenciasDeMelhoriasQNC():ConverteEmNumero(oFiltros["05_PERIODO_PERSONALIZADO"]))
    
    lTMKPMS := If(nMVQTMKPMS == 1,.F.,.T.)
    If !Empty(oFiltros["12_STATUS_PA"]) .AND. lTMKPMS .AND. ((nMVQTMKPMS == 3) .Or. (nMVQTMKPMS == 4))

        cQuery += " SELECT QI2.* "
        cQuery += " FROM "+RetSqlName("QI2")+" QI2 "
        cQuery += OcorrenciasDeMelhoriasQNC():MontaWhereQuery(oFiltros, dDataIni, dDataFim, cTpFicha)
        
        cQuery := oQLTQueryManager:ChangeQuery(cQuery)
        cAlias := oQLTQueryManager:ExecuteQuery(cQuery)

        nQtde := 0
        QI3->(DBSetOrder(2))
        While  (cAlias)->(!Eof())

            If lTMKPMS .AND. ((nMVQTMKPMS == 3) .Or. (nMVQTMKPMS == 4))
                If QI3->(DbSeek(xFilial("QI3", oFiltros["01_QI2_FILIAL"]) + (cAlias)->QI2_CODACA + (cAlias)->QI2_REVACA))
                    nAux := Q030VldLeg()
                    cStatusPA := Iif(nAux == 1, "1", cStatusPA) //"Plano de Ação Obsoleto"
                    cStatusPA := Iif(nAux == 2, "2", cStatusPA) //"Plano de Ação Pendente"
                    cStatusPA := Iif(nAux == 3, "3", cStatusPA) //"Não-Procede"
                    cStatusPA := Iif(nAux == 4, "4", cStatusPA) //"Cancelada"
                    cStatusPA := Iif(nAux == 5, "5", cStatusPA) //"Plano de Ação Baixado"
                    cStatusPA := Iif(nAux == 6, "6", cStatusPA) //"Plano de Ação s/Projeto/EDT"
                    cStatusPA := Iif(nAux == 7, "7", cStatusPA) //"Plano de Ação Rejeitado"
                    If aScan(oFiltros["12_STATUS_PA"], {|cStatItem| cStatItem == cStatusPA }) <= 0
                        (cAlias)->(DbSkip())
                        Loop
                    EndIf
                ElseIf aScan(oFiltros["12_STATUS_PA"], {|cStatItem| "|"+cStatItem+"|" $ "|1|2|3|4|5|6|7|" }) > 0 .AND. !(aScan(oFiltros["12_STATUS_PA"], {|cStatItem| cStatItem == "18" }) > 0)
                    (cAlias)->(DbSkip())
                    Loop
                EndIf
            Endif
            
            nQtde += 1
            
            (cAlias)->(DbSkip())
        EndDo
        (cAlias)->(dbCloseArea())

    Else

        cQuery += " SELECT COUNT(*) QTDE "
        cQuery += " FROM "+RetSqlName("QI2")+" QI2 "
        cQuery += OcorrenciasDeMelhoriasQNC():MontaWhereQuery(oFiltros, dDataIni, dDataFim, cTpFicha)
        
        cQuery := oQLTQueryManager:ChangeQuery(cQuery)
        cAlias := oQLTQueryManager:ExecuteQuery(cQuery)

        If  (cAlias)->(!Eof())
            nQtde := (cAlias)->QTDE
        End
        (cAlias)->(dbCloseArea())
        
    EndIf

    If cTipo == "info"
        oJson := OcorrenciasDeMelhoriasQNC():MontaJsonInfo(@oJson,nQtde,aSemaforo,cTpFicha)
    Else
        oJson := OcorrenciasDeMelhoriasQNC():MontaJsonVelocimetro(@oJson,nQtde,aSemaforo,cTpFicha)
    EndIf

    oJson["tags"]     := {}
    PCPMonitorUtils():AdicionaTagMonitor(oJson["tags"],@nIndTag,"po-icon-calendar",DtoC(dDataIni) + " - " + DtoC(dDataFim))

    FwFreeArray(aSemaforo)
Return oJson:toJson()

/*/{Protheus.doc} BuscaDetalhes
Realiza a busca dos dados para montar os detalhes do Monitor
@type Method
@author brunno.costa
@since 17/10/2023
@version P12.1.2310
@param 01 - oFiltros, objeto, objeto json com os filtros da consulta 
@param 02 - nPagina , número, número de página da consulta
@param 03 - cTpFicha, caracter, comparação /para filtro do tipo de ficha
@return cJson, string Json, string com os dados de detalhes para exibição em tabela de detalhes
/*/
Method BuscaDetalhes(oFiltros, nPagina, cTpFicha) Class OcorrenciasDeMelhoriasQNC
    Local aCampos         := {"QI2_FNC", "QI2_REV", "QI2_ANO", "QI2_DESCR", "QI2_ORIGEM","QI2_REGIST","QI2_OCORRE","QI2_CONPRE","QI2_CONREA",;
                              "QI2_CODCAT", "QI2_CONREA", "QI2_FILORI", "QI2_ORIDEP", "QI2_FILDEP","QI2_DESDEP", "QI2_FILRES", "QI2_MATRES", "QI2_CODACA",;
                              "QI2_REVACA", "QI2_STATUS", "QI2_PRIORI" }
    Local cAlias           := Nil
    Local cCampo           := ""
    Local cFilAux          := ""
    Local cParamDet        := ""
    Local cQuery           := ""
    Local cStatusPA        := ""
    Local dDataFim         := dDatabase
    Local dDataIni         := dDatabase
    Local lExpResult       := .F.
    Local lStatusPA        := .T.
    Local nCampo           := 0
    Local nCampos          := Len(aCampos)
    Local nIndTag          := 0
    Local nPos             := 0
    Local nStart           := 1
    Local nTamPagina       := 20
    Local oDados           := JsonObject()     :New()
    Local oQLTQueryManager := QLTQueryManager():New()

    Default nPagina  := 1
    Default cTpFicha := "3"

    cFilAux        := PadR(oFiltros["01_QI2_FILIAL"], FWSizeFilial())
    cParamDet      := IIF(oFiltros:HasProperty("PARAMETROSDETALHE"),oFiltros["PARAMETROSDETALHE"],"")
    dDataFim       := dDatabase
    dDataIni       := OcorrenciasDeMelhoriasQNC():RetornaPeriodoInicial(oFiltros["04_TIPOPERIODO"],;
                                                                        dDataFim,;
                                                                        OcorrenciasDeMelhoriasQNC():ConverteEmNumero(oFiltros["05_PERIODO_PERSONALIZADO"]))

    lExpResult := Iif(nPagina == 0, .T., lExpResult)

    cQuery += " SELECT "
    cQuery += " QI2.* "
    cQuery += " FROM "+RetSqlName("QI2")+" QI2 "
    cQuery += OcorrenciasDeMelhoriasQNC():MontaWhereQuery(oFiltros, dDataIni, dDataFim, cTpFicha)

    cQuery += Iif(Empty(cParamDet), "", " AND " + cParamDet)
    cQuery += " ORDER BY QI2_ANO DESC, QI2_FNC DESC, QI2_REV DESC"

    cQuery := oQLTQueryManager:ChangeQuery(cQuery)
    cAlias := oQLTQueryManager:ExecuteQuery(cQuery)
    
    nStart := Iif(nPagina > 1, ( (nPagina-1) * nTamPagina ), nStart)
    Iif(nPagina > 1 .And. nStart > 0, (cAlias)->(DbSkip(nStart)), Nil)

    oDados["items"]        := {}
    oDados["columns"]      := OcorrenciasDeMelhoriasQNC():AdicionaColunasDetalhes(lExpResult)
    oDados["canExportCSV"] := .T.
    oDados["tags"]         := {}
    PCPMonitorUtils():AdicionaTagMonitor(oDados["tags"],@nIndTag,"po-icon-calendar",dToC(dDataIni) + " - " + dToC(dDataFim))

    QI3->(DBSetOrder(2))
    While (cAlias)->(!Eof())

        cStatusPA := OcorrenciasDeMelhoriasQNC():RetornaStatusPlanoDeAcao((cAlias)->QI2_FILIAL, (cAlias)->QI2_CODACA, (cAlias)->QI2_REVACA)
        lStatusPA := Iif(Empty(oFiltros["12_STATUS_PA"]), .T., aScan(oFiltros["12_STATUS_PA"], {|cStatItem| cStatItem == cStatusPA }) > 0)

        If lStatusPA
            aAdd(oDados["items"], JsonObject():New())
            nPos++
            For nCampo := 1 to nCampos
                cCampo                          := aCampos[nCampo]
                oDados["items"][nPos][cCampo]   := (cAlias)->&(cCampo)
            Next nCampo

            oDados["items"][nPos]["QI2_REGIST"] := PCPMonitorUtils():FormataData((cAlias)->QI2_REGIST,4)
            oDados["items"][nPos]["QI2_OCORRE"] := PCPMonitorUtils():FormataData((cAlias)->QI2_OCORRE,4)
            oDados["items"][nPos]["QI2_CONPRE"] := PCPMonitorUtils():FormataData((cAlias)->QI2_CONPRE,4)
            oDados["items"][nPos]["QI2_CONREA"] := PCPMonitorUtils():FormataData((cAlias)->QI2_CONREA,4)
            oDados["items"][nPos]["QI2_NCATEG"] := FQNCNTAB("4",(cAlias)->QI2_CODCAT)
            oDados["items"][nPos]["QI2_NUSRRS"] := QA_NUSR((cAlias)->QI2_FILRES,(cAlias)->QI2_MATRES)
            oDados["items"][nPos]["QI2_NDEPOR"] := PADR(QA_NDEPT((cAlias)->QI2_ORIDEP,.F.,(cAlias)->QI2_FILORI),FWSX3Util():GetFieldStruct('QI2_ORIDEP')[3])
            oDados["items"][nPos]["QI2_NDEPTO"] := PADR(QA_NDEPT((cAlias)->QI2_DESDEP,.F.,(cAlias)->QI2_FILDEP),FWSX3Util():GetFieldStruct('QI2_DESDEP')[3])
            oDados["items"][nPos]["QI2_STATPA"] := cStatusPA
            oDados["items"][nPos]["QI2_FNC"]    := Left(oDados["items"][nPos]["QI2_FNC"], Len(oDados["items"][nPos]["QI2_FNC"]) - 4) + "/" + Right(oDados["items"][nPos]["QI2_FNC"], 4)

            If !Empty(oDados["items"][nPos]["QI2_CODACA"])
                oDados["items"][nPos]["QI2_CODACA"]    := Left(oDados["items"][nPos]["QI2_CODACA"], Len(oDados["items"][nPos]["QI2_CODACA"]) - 4) + "/" + Right(oDados["items"][nPos]["QI2_CODACA"], 4)
            EndIf
            
            Do CASE
                Case (cAlias)->QI2_OBSOL=="S"
                    oDados["items"][nPos]["QI2_LEGEND"] := '4'
                Case !Empty((cAlias)->QI2_CONREA)
                    oDados["items"][nPos]["QI2_LEGEND"] := '1'
                Case Empty((cAlias)->QI2_CONREA) .And. !Empty((cAlias)->QI2_CODACA) .And. !Empty((cAlias)->QI2_REVACA)
                    oDados["items"][nPos]["QI2_LEGEND"] := '2'
                Case Empty((cAlias)->QI2_CONREA)
                    oDados["items"][nPos]["QI2_LEGEND"] := '3'
            EndCase

            (cAlias)->(dbSkip())
        Else
            (cAlias)->(dbSkip())
            Loop
        EndIf
        
        If !lExpResult .And. nPos >= nTamPagina
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
Method AdicionaColunasDetalhes(lExpResult) Class OcorrenciasDeMelhoriasQNC
    Local aCampos    :={"QI2_FNC", "QI2_REV", "QI2_ANO", "QI2_DESCR", "QI2_ORIGEM","QI2_REGIST","QI2_OCORRE","QI2_CONPRE","QI2_CONREA",;
                        "QI2_CODCAT", "QI2_NCATEG", "QI2_CONREA", "QI2_DOCUME", "QI2_FILORI", "QI2_ORIDEP", "QI2_NDEPOR", "QI2_FILDEP",;
                        "QI2_DESDEP","QI2_NDEPTO","QI2_NUSRRS", "QI2_FILRES", "QI2_MATRES", "QI2_CODACA", "QI2_REVACA"}
    Local aColunas   := {}
    Local aLabelsL   := {}
    Local aLabelsP   := {}
    Local aLabelsPA  := {}
    Local aLabelsS   := {}
    Local cTipo      := ""
    Local lVisivel   := .T.
    Local nCampo     := 0
    Local nCampos    := Len(aCampos)
    Local nIndice    := 0
    Local nIndLblLeg := 0
    Local nIndLblPA  := 0
    Local nIndLblPri := 0
    Local nIndLblSit := 0

    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabelsL,@nIndLblLeg,"1",COR_VERDE_FORTE   , STR0018, COR_BRANCO)   //"Ficha Baixada"                   
    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabelsL,@nIndLblLeg,"2",COR_AMARELO_ESCURO, STR0019, COR_PRETO )   //"Ficha Pendente com Plano de Ação"
    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabelsL,@nIndLblLeg,"3",COR_VERMELHO_FORTE, STR0020, COR_BRANCO)   //"Ficha Pendente sem Plano de Ação"
    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabelsL,@nIndLblLeg,"4",COR_CINZA_LEG     , STR0021, COR_BRANCO)   //"Ficha com Revisão Obsoleta"      
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"QI2_LEGEND",STR0022,"cellTemplate"  ,.T.,.T.,aLabelsL) //"Status"


    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabelsS,@nIndLblSit,"1",COR_BRANCO, STR0023, COR_PRETO)            //"Registrada" 
    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabelsS,@nIndLblSit,"2",COR_BRANCO, STR0024, COR_PRETO)            //"Em Análise" 
    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabelsS,@nIndLblSit,"3",COR_BRANCO, STR0025, COR_PRETO)            //"Procede"    
    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabelsS,@nIndLblSit,"4",COR_BRANCO, STR0026, COR_PRETO)            //"Não Procede"
    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabelsS,@nIndLblSit,"5",COR_BRANCO, STR0027, COR_PRETO)            //"Cancelada"  
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"QI2_STATUS",STR0028,"cellTemplate"  ,.T.,.T.,aLabelsS) //"Situação"

    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabelsP,@nIndLblPri,"1",COR_BRANCO, STR0029, COR_PRETO)            //"Baixa"
    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabelsP,@nIndLblPri,"2",COR_BRANCO, STR0030, COR_PRETO)            //"Média"
    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabelsP,@nIndLblPri,"3",COR_BRANCO, STR0031, COR_PRETO)            //"Alta"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"QI2_PRIORI",STR0032,"cellTemplate"  ,.T.,.T.,aLabelsP) //"Prioridade"


    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabelsPA,@nIndLblPA,"1" ,COR_PRETO         , STR0033, COR_BRANCO) //"Plano de Ação Obsoleto"
    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabelsPA,@nIndLblPA,"2" ,COR_AMARELO_ESCURO, STR0034, COR_PRETO)  //"Plano de Ação Pendente"
    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabelsPA,@nIndLblPA,"3" ,COR_CINZA_LEG     , STR0035, COR_BRANCO) //"Não-Procede"
    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabelsPA,@nIndLblPA,"4" ,COR_MARROM        , STR0036, COR_BRANCO) //"Cancelada"
    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabelsPA,@nIndLblPA,"5" ,COR_VERDE_FORTE   , STR0037, COR_BRANCO) //"Plano de Ação Baixado"
    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabelsPA,@nIndLblPA,"6" ,COR_LARANJA       , STR0038, COR_BRANCO) //"Plano de Ação s/Projeto/EDT"
    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabelsPA,@nIndLblPA,"7" ,COR_ROSA          , STR0039, COR_BRANCO) //"Plano de Ação Rejeitado"

    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabelsPA,@nIndLblPA,"8" ,COR_PRETO         , STR0033, COR_BRANCO) //"Plano de Ação Obsoleto"
    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabelsPA,@nIndLblPA,"9" ,COR_AMARELO_ESCURO, STR0034, COR_PRETO)  //"Plano de Ação Pendente"
    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabelsPA,@nIndLblPA,"10",COR_CINZA_LEG     , STR0035, COR_BRANCO) //"Não-Procede"           
    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabelsPA,@nIndLblPA,"11",COR_MARROM        , STR0036, COR_BRANCO) //"Cancelada"             
    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabelsPA,@nIndLblPA,"12",COR_VERDE_FORTE   , STR0037, COR_BRANCO) //"Plano de Ação Baixado" 

    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabelsPA,@nIndLblPA,"13",COR_PRETO         , STR0033, COR_BRANCO) //"Plano de Ação Obsoleto"
    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabelsPA,@nIndLblPA,"14",COR_VERMELHO_FORTE, STR0034, COR_BRANCO) //"Plano de Ação Pendente"
    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabelsPA,@nIndLblPA,"15",COR_CINZA_LEG     , STR0035, COR_BRANCO) //"Não-Procede"           
    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabelsPA,@nIndLblPA,"16",COR_MARROM        , STR0036, COR_BRANCO) //"Cancelada"             
    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabelsPA,@nIndLblPA,"17",COR_VERDE_FORTE   , STR0037, COR_BRANCO) //"Plano de Ação Baixado" 

    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabelsPA,@nIndLblPA,"18",COR_BRANCO        , STR0040, COR_PRETO)  //"Sem Plano de Ação" 

    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"QI2_STATPA",STR0041,"cellTemplate"  ,.T.,.T.,aLabelsPA) //"Plano de Ação"

    For nCampo := 1 to nCampos
        cCampo := aCampos[nCampo]
        If X3Uso(GetSx3Cache(cCampo,"X3_USADO"),36)
            cTipo  := GetSx3Cache(cCampo,"X3_TIPO")
            Do Case
                Case cTipo == "C"
                    cTipo := "string"
                Case cTipo == "D"
                    cTipo := "date"
            EndCase
            lVisivel := GetSx3Cache(cCampo,"X3_BROWSE") != "N"
            PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,cCampo,GetSx3Cache(cCampo,"X3_TITULO"),cTipo,lVisivel.OR.lExpResult)
        EndIf
    Next nCampo

Return aColunas

/*/{Protheus.doc} MontaComboModuloOrigem
Cria JSON com os dados para COMBO de Módulo Origem
@type Method
@author brunno.costa
@since 17/10/2023
@version P12.1.2310
@param 01 - oParametro, objeto, cria por referência o objeto JSON oFiltros["03_MODULOORIGEM"]
@return oParametro, objeto, retorna o objeto criado
/*/
Method MontaComboModuloOrigem(oParametro) Class OcorrenciasDeMelhoriasQNC
    Default oParametro      := JsonObject():New()
    oParametro["opcoes"]  :=       STR0042+":TMK" //"Call Center:TMK"        
    oParametro["opcoes"]  += ";" + STR0043+":QAD" //"Controle de Auditoria:QAD"
    oParametro["opcoes"]  += ";" + STR0044+":QNC" //"Controle de Não-Conformidades"+":QNC"
    oParametro["opcoes"]  += ";" + STR0045+":QIE" //"Inspeção de Entradas"+":QIE"
    oParametro["opcoes"]  += ";" + STR0046+":QIP" //"Inspeção de Processos"+":QIP"
    oParametro["opcoes"]  += ";" + STR0047+":SGA" //"Gestão Ambiental"+":SGA"
    oParametro["opcoes"]  += ";" + STR0048+":QMT" //"Gestão de Metrologia"+":QMT"
    oParametro["opcoes"]  += ";" + STR0049+":HSP" //"Gestão Hospitalar"+":HSP"
    oParametro["opcoes"]  += ";" + STR0050+":MNT" //"Manutenção de Ativos"+":MNT"
    oParametro["opcoes"]  += ";" + STR0051+":TEC" //"Prestadores de Serviços"+":TEC"
Return oParametro


/*/{Protheus.doc} MontaComboSituacao
Cria JSON com os dados para COMBO de Situação
@type Method
@author brunno.costa
@since 17/10/2023
@version P12.1.2310
@param 01 - oParametro, objeto, cria por referência o objeto JSON oFiltros["06_SITUACAO"]
@return oParametro, objeto, retorna o objeto criado
/*/
Method MontaComboSituacao(oParametro) Class OcorrenciasDeMelhoriasQNC
    Default oParametro      := JsonObject():New()
    oParametro["opcoes"]  :=       STR0023+":1" //"Registrada"+":1"
    oParametro["opcoes"]  += ";" + STR0024+":2" //"Em Análise"+":2" 
    oParametro["opcoes"]  += ";" + STR0025+":3" //"Procede"+":3" 
    oParametro["opcoes"]  += ";" + STR0026+":4" //"Não Procede"+":4" 
    oParametro["opcoes"]  += ";" + STR0027+":5" //"Cancelada"+":5" 
Return oParametro

/*/{Protheus.doc} MontaComboStatus
Cria JSON com os dados para COMBO de Status
@type Method
@author brunno.costa
@since 17/10/2023
@version P12.1.2310
@param 01 - oParametro, objeto, cria por referência o objeto JSON oFiltros["11_STATUS"]
@return oParametro, objeto, retorna o objeto criado
/*/
Method MontaComboStatus(oParametro) Class OcorrenciasDeMelhoriasQNC
    Default oParametro    := JsonObject():New()
    oParametro["opcoes"]  :=       STR0018+":1" // "Ficha Baixada"+":1"
    oParametro["opcoes"]  += ";" + STR0019+":2" // "Ficha Pendente com Plano de Ação"+":2"
    oParametro["opcoes"]  += ";" + STR0020+":3" // "Ficha Pendente Sem Plano de Ação"+":3"
    oParametro["opcoes"]  += ";" + STR0021+":4" // "Ficha com Revisão Obsoleta"+":4"
Return oParametro

/*/{Protheus.doc} MontaComboStatusPlanoDeAcao
Cria JSON com os dados para COMBO de Status do Plano de Acao
@type Method
@author brunno.costa
@since 19/10/2023
@version P12.1.2310
@param 01 - oParametro, objeto, cria por referência o objeto JSON oFiltros["11_STATUS"]
@return oParametro, objeto, retorna o objeto criado
/*/
Method MontaComboStatusPlanoDeAcao(oParametro) Class OcorrenciasDeMelhoriasQNC

    Local lTMKPMS    := .F. //Integração do QNC com TMK e PMS: 1-Sem Integração,2-TMKxQNC,3-QNCxPMS,4-TMKxQNCxPMS ³
    Local nMVQTMKPMS := SuperGetMv("MV_QTMKPMS",.F.,1)

    Default oParametro    := JsonObject():New()

    lTMKPMS := If(nMVQTMKPMS == 1,.F.,.T.)
            
    If lTMKPMS
        //Projeto TDI - TDSFL0 Identificação de rejeitados
        If (nMVQTMKPMS == 3) .Or. (nMVQTMKPMS == 4)
            
            oParametro["opcoes"]  :=       STR0033+":1" // "Plano de Ação Obsoleto"
            oParametro["opcoes"]  += ";" + STR0034+":2" // "Plano de Ação Pendente"
            oParametro["opcoes"]  += ";" + STR0035+":3" // "Não-Procede"
            oParametro["opcoes"]  += ";" + STR0036+":4" // "Cancelada"
            oParametro["opcoes"]  += ";" + STR0037+":5" // "Plano de Ação Baixado"
            oParametro["opcoes"]  += ";" + STR0038+":6" // "Plano de Ação s/Projeto/EDT"
            oParametro["opcoes"]  += ";" + STR0039+":7" // "Plano de Ação Rejeitado"
        
        Else

            oParametro["opcoes"]  :=       STR0033+":8"  // "Plano de Ação Obsoleto"
            oParametro["opcoes"]  += ";" + STR0034+":9"  // "Plano de Ação Pendente"
            oParametro["opcoes"]  += ";" + STR0035+":10" // "Não-Procede"           
            oParametro["opcoes"]  += ";" + STR0036+":11" // "Cancelada"             
            oParametro["opcoes"]  += ";" + STR0037+":12" // "Plano de Ação Baixado" 

        Endif
    Else
        oParametro["opcoes"]  :=       STR0033+":13" // "Plano de Ação Obsoleto"
        oParametro["opcoes"]  += ";" + STR0034+":14" // "Plano de Ação Pendente"
        oParametro["opcoes"]  += ";" + STR0035+":15" // "Não-Procede"           
        oParametro["opcoes"]  += ";" + STR0036+":16" // "Cancelada"             
        oParametro["opcoes"]  += ";" + STR0037+":17" // "Plano de Ação Baixado" 

    Endif

    oParametro["opcoes"]  += ";" + STR0040+":18" // "Sem Plano de Ação"
    
Return oParametro

/*/{Protheus.doc} MontaComboPeriodos
Cria JSON com os dados para COMBO de Períodos
@type Method
@author brunno.costa
@since 17/10/2023
@version P12.1.2310
@param 01 - oParametro, objeto, cria por referência o objeto JSON oFiltros["04_TIPOPERIODO"]
@return oParametro, objeto, retorna o objeto criado
/*/
Method MontaComboPeriodos(oParametro) Class OcorrenciasDeMelhoriasQNC
    Default oParametro      := JsonObject():New()
    oParametro["opcoes"] :=       STR0052+":1"  //"Últimos 30 dias"
    oParametro["opcoes"] += ";" + STR0053+":6"  // "Últimos 180 dias"
    oParametro["opcoes"] += ";" + STR0054+":12" // "Últimos 365 dias"
    oParametro["opcoes"] += ";" + STR0055+":X"  // "Personalizado"
Return oParametro


/*/{Protheus.doc} SetaPropriedadeFilial
Adiciona ao objeto de carga do Monitor a propriedade Filial
@type Method
@author brunno.costa
@since 17/10/2023
@version P12.1.2310
@param 01 - oCarga , objeto  , instancia do objeto json de carga
@param 02 - cCodigo, caracter, codigo da propriedade
@param 03 - cTitulo, caracter, título da propriedade para exibicao no front-end
@return Nil
/*/
Method SetaPropriedadeFilial(oCarga, cCodigo, cTitulo) Class OcorrenciasDeMelhoriasQNC
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
Method SetaPropriedadeLookupTabela(oCarga, cCodigo, cLabel, lSelecMult, cTabela, cCampoCod, cCampoDsc, nOrdFil) Class OcorrenciasDeMelhoriasQNC
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
@since 17/10/2023
@version P12.1.2310
@param 01 - oJson     , objeto json, Objeto json que receberá os dados do gauge
@param 02 - nQtde     , numerico   , quantidade para exibição no monitor
@param 03 - aSemaforo , array      , Array com os números do semáforo
@param 04 - cTpFicha, caracter, comparação para filtro do tipo de ficha
@return Nil
/*/
Method MontaJsonVelocimetro(oJson, nQtde, aSemaforo, cTpFicha) Class OcorrenciasDeMelhoriasQNC
    Local cDescricao  := Iif(nQtde > 1 .OR. nQtde == 0, STR0056, STR0056) //"Melhorias", "Melhoria"
    Local cValorFim   := ""
    Local cValSemaf1  := aSemaforo[1]
    Local cValSemaf2  := aSemaforo[2]
    Local lMenorVerde := Nil
    Local nValorFim   := 0
    Local nValSemaf1  := Val(cValSemaf1)
    Local nValSemaf2  := Val(cValSemaf2)
    Local oGauge      := PCPMonitorGauge():New()

    cDescricao := Iif(cTpFicha == "1", Iif(nQtde > 1, STR0068, STR0069), cDescricao) //"N.C. Potenciais", "N.C. Potencial"
    cDescricao := Iif(cTpFicha == "2", Iif(nQtde > 1, STR0070, STR0071), cDescricao) //"N.C. Existentes", "N.C. Existente"
    cDescricao := Iif(cTpFicha == "3", Iif(nQtde > 1, STR0056, STR0057), cDescricao) //"Melhorias", "Melhoria"

    lMenorVerde := nValSemaf1 < nValSemaf2

    oJson["alturaMinimaWidget"] := "350px"
    oJson["alturaMaximaWidget"] := "500px"
    oJson["categorias"] := {}
    oJson["series"]     := {}
    oJson["detalhes"]   := {}
    oGauge:SetValue(nQtde)
    oGauge:SetValueStyle("color",OcorrenciasDeMelhoriasQNC():RetornaCorSemaforo(nQtde,aSemaforo))
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
@since 17/10/2023
@version P12.1.2310
@param 01 - oJson     , objeto json, Objeto json que receberá os dados do gauge
@param 02 - nQtde     , numerico   , quantidade para exibição no monitor
@param 03 - aSemaforo , array      , Array com os números do semáforo
@param 04 - cTpFicha, caracter, comparação para filtro do tipo de ficha
@return Nil
/*/
Method MontaJsonInfo(oJson, nQtde, aSemaforo, cTpFicha) Class OcorrenciasDeMelhoriasQNC

    Local cDescricao := ""
    Local nIndLinha  := 0
    Local oStyle     := JsonObject():New()
    Local oStyleQtd  := JsonObject():New()

    cDescricao := Iif(cTpFicha == "1", Iif(nQtde > 1, STR0068, STR0069), cDescricao) //"N.C. Potenciais", "N.C. Potencial"
    cDescricao := Iif(cTpFicha == "2", Iif(nQtde > 1, STR0070, STR0071), cDescricao) //"N.C. Existentes", "N.C. Existente"
    cDescricao := Iif(cTpFicha == "3", Iif(nQtde > 1, STR0058, STR0059), cDescricao) //"Fichas de Melhorias", "Ficha de Melhoria"

    oStyle["color"]             := "white"

    oJson["alturaMaximaWidget"] := "500px"
    oJson["alturaMinimaWidget"] := "350px"
    oJson["corTitulo"]          := "white"
    oJson["linhas"]             := {}
    oJson["corFundo"]           := OcorrenciasDeMelhoriasQNC():RetornaCorSemaforo(nQtde,aSemaforo)

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
        //STR0060 - "Nenhuma Ocorrência de Melhoria foi registrada no período selecionado."
        PCPMonitorUtils():AdicionaLinhaInformacao(oJson["linhas"],@nIndLinha,STR0060,"po-font-text-large-bold po-text-center po-sm-12 po-pt-4",oStyle:ToJson())
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
Method RetornaCorSemaforo(nQtde, aSemaforo) Class OcorrenciasDeMelhoriasQNC
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
Method RetornaPeriodoInicial(cFiltro, dDataFim, nPersonal) Class OcorrenciasDeMelhoriasQNC
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
@since 17/10/2023
@version P12.1.2310
@param  oFiltros, objeto json, Objeto json com os filtros para a consulta dos dados
@return aRetorno, array      , [1] logico - indica se os dados são válidos [2] caracter - mensagem de erro
/*/
Method ValidaPropriedades(oFiltros) Class OcorrenciasDeMelhoriasQNC
    Local aRetorno    :={.T., ""}
    Local aSemaforo   := {}
    Local bErrorBlock := Nil
    Local lSemNumero  := .F.
    Local nAux        := 0
    Local nIndSemaf          := 1

    PCPMonitorUtils():ValidaPropriedadeFilial(oFiltros["01_QI2_FILIAL"],aRetorno)

    If aRetorno[1]
        If !oFiltros:HasProperty("02_SEMAFORO") .Or. oFiltros["02_SEMAFORO"] == Nil .Or. Empty(oFiltros["02_SEMAFORO"])
            aRetorno[1] := .F.
            aRetorno[2] := STR0061 //"O campo 'Semáforo' deve ser preenchido com 2 valores separados por ponto e vírgula (ex.: '10;100'), definindo o número de lotes/quantidade que indicam Atenção e Urgência, respectivamente" 
        Else 
            aSemaforo := StrTokArr(Replace(oFiltros["02_SEMAFORO"],",","."),";")
            If Len(aSemaforo) <> 2
                aRetorno[1] := .F.
                aRetorno[2] := STR0061 //"O campo 'Semáforo' deve ser preenchido com 2 valores separados por ponto e vírgula (ex.: '10;100'), definindo o número de lotes/quantidade que indicam Atenção e Urgência, respectivamente" 0061
            Else
                lSemNumero  := .F.
                bErrorBlock := ErrorBlock({|| lSemNumero := .T.})
                For nIndSemaf := 1 To 2
                    nAux      := Val(aSemaforo[nIndSemaf])
                    If Empty(aSemaforo[nIndSemaf]) .or. lSemNumero .Or. AllTrim(Str(nAux)) <> AllTrim(aSemaforo[nIndSemaf])
                        aRetorno[1] := .F.
                        aRetorno[2] := STR0061 //"O campo 'Semáforo' deve ser preenchido com 2 valores separados por ponto e vírgula (ex.: '10;100'), definindo o número de lotes/quantidade que indicam Atenção e Urgência, respectivamente" 061
                        Exit
                    EndIf
                Next nIndSemaf
                ErrorBlock(bErrorBlock)
            EndIf
        EndIf
    EndIf

    If aRetorno[1] .And. (!oFiltros:HasProperty("04_TIPOPERIODO") .Or. oFiltros["04_TIPOPERIODO"] == Nil .Or. Empty(oFiltros["04_TIPOPERIODO"]))
        aRetorno[1] := .F.
        aRetorno[2] := STR0062 //"Deve ser informado o período para análise do monitor."
    EndIf

    If aRetorno[1] .And. oFiltros["04_TIPOPERIODO"] == "X"
        If !oFiltros:HasProperty("05_PERIODO_PERSONALIZADO") .Or. oFiltros["05_PERIODO_PERSONALIZADO"] == Nil .Or. Empty(oFiltros["05_PERIODO_PERSONALIZADO"])
            aRetorno[1] := .F.
            aRetorno[2] := STR0063 //"Deve ser informada a quantidade de dias para o período personalizado."
        EndIf
    EndIf

    FwFreeArray(aSemaforo)
Return aRetorno


/*/{Protheus.doc} ConverteEmNumero
Converte valor em número - necessário pois eventualmente front-end retorna valor numérico ou string
@type Method
@author brunno.costa
@since 17/10/2023
@version P12.1.2310
@param  oValor  , número / string, valor enviado pelo front-end
@return nRetorno, número, retorna o valor numérico relacionado a oValor
/*/
Method ConverteEmNumero(oValor) Class OcorrenciasDeMelhoriasQNC
    Local nRetorno := oValor
    If ValType(oValor) == "C"
        nRetorno := Val(oValor)
    EndIf
Return nRetorno

/*/{Protheus.doc} RetornaStatusPlanoDeAcao
Retorna Status do Plano de Ação
@type Method
@author brunno.costa
@since 17/10/2023
@version P12.1.2310
@param 01 - cFilQI2, caracter, filial da ocorrência na QI2 
@param 02 - cPlano , caracter, código do plano de ação
@param 03 - cRev   , caracter, código da revisão do plano de acao
@return cStatus, caracter, codigo que indica o status do plano de acao
/*/
Method RetornaStatusPlanoDeAcao(cFilQI2, cPlano, cRev) Class OcorrenciasDeMelhoriasQNC
    Local cStatus    := ""
    Local lTMKPMS    := .F. //Integração do QNC com TMK e PMS: 1-Sem Integração,2-TMKxQNC,3-QNCxPMS,4-TMKxQNCxPMS ³
    Local nAux       := 0
    Local nMVQTMKPMS := SuperGetMv("MV_QTMKPMS",.F.,1)
    If !Empty(cPlano) .AND. !Empty(cRev)
        If QI3->(DbSeek(xFilial("QI3", cFilQI2) + cPlano + cRev))
            lTMKPMS := If(nMVQTMKPMS == 1,.F.,.T.)
            
            If lTMKPMS
                //Projeto TDI - TDSFL0 Identificação de rejeitados
                If (nMVQTMKPMS == 3) .Or. (nMVQTMKPMS == 4)
                    nAux := Q030VldLeg()
                    cStatus := Iif(nAux == 1, "1", cStatus) //"Plano de Ação Obsoleto"
                    cStatus := Iif(nAux == 2, "2", cStatus) //"Plano de Ação Pendente"
                    cStatus := Iif(nAux == 3, "3", cStatus) //"Não-Procede"
                    cStatus := Iif(nAux == 4, "4", cStatus) //"Cancelada"
                    cStatus := Iif(nAux == 5, "5", cStatus) //"Plano de Ação Baixado"
                    cStatus := Iif(nAux == 6, "6", cStatus) //"Plano de Ação s/Projeto/EDT"
                    cStatus := Iif(nAux == 7, "7", cStatus) //"Plano de Ação Rejeitado"
                
                Else
                    cStatus := Iif(Empty(cStatus) .And. QI3->QI3_OBSOL=="S"     , "8" , cStatus) //"Plano de Ação Obsoleto"
                    cStatus := Iif(Empty(cStatus) .And. Empty(QI3->QI3_ENCREA)  , "9" , cStatus) //"Plano de Ação Pendente"
                    cStatus := Iif(Empty(cStatus) .And. QI3->QI3_STATUS=="4"    , "10", cStatus) //"Não-Procede"           
                    cStatus := Iif(Empty(cStatus) .And. QI3->QI3_STATUS=="5"    , "11", cStatus) //"Cancelada"             
                    cStatus := Iif(Empty(cStatus) .And. !Empty(QI3->QI3_ENCREA) , "12", cStatus) //"Plano de Ação Baixado" 

                Endif
            Else
                cStatus := Iif(Empty(cStatus) .And. QI3->QI3_OBSOL=="S"         , "13", cStatus) //"Plano de Ação Obsoleto"
                cStatus := Iif(Empty(cStatus) .And. Empty(QI3->QI3_ENCREA)      , "14", cStatus) //"Plano de Ação Pendente"
                cStatus := Iif(Empty(cStatus) .And. QI3->QI3_STATUS=="4"        , "15", cStatus) //"Não-Procede"           
                cStatus := Iif(Empty(cStatus) .And. QI3->QI3_STATUS=="5"        , "16", cStatus) //"Cancelada"             
                cStatus := Iif(Empty(cStatus) .And. !Empty(QI3->QI3_ENCREA)     , "17", cStatus) //"Plano de Ação Baixado" 

            Endif

        EndIf
    
    Else
        cStatus := "18"
    EndIf
    
Return cStatus

/*/{Protheus.doc} MontaWhereQuery
Monta dados WHERE para selecao dos dados da QPK para contagem
@type METHOD
@author brunno.costa
@since 10/10/2023
@version P12.1.2310
@param 01 - oFiltros, objeto  , objeto Json de filtros do monitor
@param 02 - dDataIni, data    , data de inicio para filtro
@param 03 - dDataFim, data    , data de fim para filtro
@param 04 - cTpFicha, caracter, comparação para filtro do tipo de ficha
@return cWhere, caracter, string SQL com clausua WHERE para filtro dos dados
/*/
Method MontaWhereQuery(oFiltros, dDataIni, dDataFim, cTpFicha) Class OcorrenciasDeMelhoriasQNC
    
    Local cFilAux    := PadR(oFiltros["01_QI2_FILIAL"], FWSizeFilial())
    Local cPrefOR    := ""
    Local cPrefORPA  := ""
    Local cWhere     := ""
    Local lTMKPMS    := .F. //Integração do QNC com TMK e PMS: 1-Sem Integração,2-TMKxQNC,3-QNCxPMS,4-TMKxQNCxPMS ³
    Local nIndAux    := 0
    Local nMVQTMKPMS := SuperGetMv("MV_QTMKPMS",.F.,1)

    cWhere += " LEFT JOIN "+RetSqlName("QI3")+" QI3 ON QI3.QI3_FILIAL = '"+xFilial("QI3",cFilAux)+"' AND QI3.QI3_CODIGO = QI2.QI2_CODACA AND QI3.QI3_REV = QI2.QI2_REVACA AND QI3.D_E_L_E_T_ = ' ' "
    cWhere += " WHERE QI2.QI2_FILIAL = '" + xFilial("QI2",cFilAux) + "' "
    cWhere +=   " AND QI2.QI2_REGIST BETWEEN '"+DTOS(dDataIni)+"' AND  '"+DTOS(dDataFim)+"' "
    cWhere +=   " AND QI2.D_E_L_E_T_  = ' ' "
    cWhere +=   " AND QI2.QI2_TPFIC = '" + cTpFicha + "' "

    If !Empty(oFiltros["03_MODULOORIGEM"])
        cWhere +=   " AND QI2.QI2_ORIGEM IN (" + "'" + ArrTokStr(oFiltros["03_MODULOORIGEM"],"', '",0) + "'" + ") "
    EndIf

    If !Empty(oFiltros["06_SITUACAO"])
        cWhere +=   " AND (QI2.QI2_STATUS IN (" + "'" + ArrTokStr(oFiltros["06_SITUACAO"],"', '",0) + "'" + ")) "
    EndIf

    If !Empty(oFiltros["07_QI2_FILORI"])
        cWhere +=   " AND (QI2.QI2_FILORI = '" + oFiltros["07_QI2_FILORI"] + "') "
    EndIf

    If !Empty(oFiltros["08_QI2_ORIDEP"])
        cWhere +=   " AND (QI2.QI2_ORIDEP = '" + oFiltros["08_QI2_ORIDEP"] + "') "
    EndIf

    If !Empty(oFiltros["09_QI2_FILDEP"])
        cWhere +=   " AND (QI2.QI2_FILDEP = '" + oFiltros["09_QI2_FILDEP"] + "') "
    EndIf

    If !Empty(oFiltros["10_QI2_DESDEP"])
        cWhere +=   " AND (QI2.QI2_DESDEP = '" + oFiltros["10_QI2_DESDEP"] + "') "
    EndIf

    If !Empty(oFiltros["11_STATUS"])
        cWhere +=   " AND ( "
        For nIndAux := 1 to Len(oFiltros["11_STATUS"])
            Do CASE
                Case oFiltros["11_STATUS"][nIndAux] == "4"
                    cWhere  += cPrefOR + " QI2.QI2_OBSOL='S' "
                    cPrefOR := " OR "
                Case oFiltros["11_STATUS"][nIndAux] == "1"
                    cWhere  += cPrefOR + " QI2.QI2_CONREA <> ' ' "
                    cPrefOR := " OR "
                Case oFiltros["11_STATUS"][nIndAux] == "2"
                    cWhere  += cPrefOR + " (QI2.QI2_CONREA = ' ' AND QI2.QI2_CODACA <> ' ' AND QI2.QI2_REVACA <> ' ') "
                    cPrefOR := " OR "
                Case oFiltros["11_STATUS"][nIndAux] == "3"
                    cWhere  += cPrefOR + " (QI2.QI2_CONREA = ' ' AND (QI2.QI2_CODACA = ' ' AND QI2.QI2_REVACA = ' ')) "
                    cPrefOR := " OR "
            EndCase
        Next nIndAux
        cWhere +=   " ) "
    EndIf   



    If !Empty(oFiltros["12_STATUS_PA"])
        lTMKPMS := If(nMVQTMKPMS == 1,.F.,.T.)

        If lTMKPMS
            //Projeto TDI - TDSFL0 Identificação de rejeitados
            If (nMVQTMKPMS == 3) .Or. (nMVQTMKPMS == 4)
                cWhere  += " AND 1 = 1 "
            Else

                cWhere    +=   " AND ( "
                cPrefORPA := ""
                For nIndAux := 1 to Len(oFiltros["12_STATUS_PA"])
                     Do CASE
                        Case oFiltros["12_STATUS_PA"][nIndAux] == "8" 
                            cWhere  += cPrefORPA + " QI3.QI3_OBSOL = 'S' " //"Plano de Ação Obsoleto"
                            cPrefORPA := " OR "
                        Case oFiltros["12_STATUS_PA"][nIndAux] == "9" 
                            cWhere  += cPrefORPA + " QI3.QI3_ENCREA = ' ' AND QI3.QI3_OBSOL <> 'S' AND QI3.QI3_STATUS <> '4' AND QI3.QI3_STATUS <> '5' " //"Plano de Ação Pendente"
                            cPrefORPA := " OR "
                        Case oFiltros["12_STATUS_PA"][nIndAux] == "10" 
                            cWhere  += cPrefORPA + " QI3.QI3_STATUS = '4' " //"Não-Procede"           
                            cPrefORPA := " OR "
                        Case oFiltros["12_STATUS_PA"][nIndAux] == "11"
                            cWhere  += cPrefORPA + " QI3.QI3_STATUS = '5' " //"Cancelada"             
                            cPrefORPA := " OR "
                        Case oFiltros["12_STATUS_PA"][nIndAux] == "12"
                            cWhere  += cPrefORPA + " QI3.QI3_ENCREA <> ' ' AND QI3.QI3_OBSOL <> 'S' AND QI3.QI3_STATUS <> '4' AND QI3.QI3_STATUS <> '5' " //"Plano de Ação Baixado" 
                            cPrefORPA := " OR "
                        Case oFiltros["12_STATUS_PA"][nIndAux] == "18"
                            cWhere  += cPrefORPA + " QI3.QI3_CODIGO IS NULL " //"Sem Plano de Ação" 
                            cPrefORPA := " OR "
                    EndCase
                Next nIndAux
                cWhere += Iif(Empty(cPrefORPA), " 1 = 1 ", "")
                cWhere +=   " ) "
                
            Endif
        Else
            cWhere    +=   " AND ( "
            cPrefORPA := ""
            For nIndAux := 1 to Len(oFiltros["12_STATUS_PA"])
                Do CASE
                    Case oFiltros["12_STATUS_PA"][nIndAux] == "13" 
                        cWhere  += cPrefORPA + " QI3.QI3_OBSOL = 'S' " //"Plano de Ação Obsoleto"
                        cPrefORPA := " OR "
                    Case oFiltros["12_STATUS_PA"][nIndAux] == "14" 
                        cWhere  += cPrefORPA + " (QI3.QI3_ENCREA = ' ' AND QI3.QI3_OBSOL <> 'S' AND QI3.QI3_STATUS <> '4' AND QI3.QI3_STATUS <> '5') " //"Plano de Ação Pendente"
                        cPrefORPA := " OR "
                    Case oFiltros["12_STATUS_PA"][nIndAux] == "15"
                        cWhere  += cPrefORPA + " QI3.QI3_STATUS = '4' " //"Não-Procede"
                        cPrefORPA := " OR "
                    Case oFiltros["12_STATUS_PA"][nIndAux] == "16"
                        cWhere  += cPrefORPA + " QI3.QI3_STATUS = '5' " //"Cancelada"
                        cPrefORPA := " OR "
                    Case oFiltros["12_STATUS_PA"][nIndAux] == "17"
                        cWhere  += cPrefORPA + " QI3.QI3_ENCREA <> ' ' AND QI3.QI3_OBSOL <> 'S' AND QI3.QI3_STATUS <> '4' AND QI3.QI3_STATUS <> '5' " //"Plano de Ação Baixado" 
                        cPrefORPA := " OR "
                    Case oFiltros["12_STATUS_PA"][nIndAux] == "18"
                        cWhere  += cPrefORPA + " QI3.QI3_CODIGO IS NULL " //"Sem Plano de Ação" 
                        cPrefORPA := " OR "
                EndCase
            Next nIndAux
            cWhere += Iif(Empty(cPrefORPA), " 1 = 1 ", "")
            cWhere +=   " ) "

        Endif

    EndIf

Return cWhere
