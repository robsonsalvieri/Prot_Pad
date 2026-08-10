#INCLUDE "TOTVS.CH"
#INCLUDE "QLTMONITORDEF.CH"
#INCLUDE "DocumentosVencidos.CH"

/*/{Protheus.doc} DocumentosAVencer
Classe para prover os dados do Monitor Documentos A Vencer do Módulo Controle de Documentos (SIGAQDO)
@type Class
@author cintia.paul
@since 27/10/2023
@version P12.1.2310
@return Nil
/*/
Class DocumentosAVencer FROM LongNameClass
	
    //Métodos Padrões
    Static Method BuscaDados(oFiltros, cTipo, cSubTipo)
	Static Method BuscaDetalhes(oFiltro, nPagina)
	Static Method CargaMonitor()
    Static Method ValidaPropriedades(oFiltros)

    //Métodos Internos
    Static Method MontaComboPeriodos(oParametro)
    Static Method RetornaPeriodoFinal(cFiltro, dDataFim)

EndClass

/*/{Protheus.doc} CargaMonitor
Realiza a carga do Monitor padrão na base de dados
@type Method
@author cintia.paul
@since 27/10/2023
@version P12.1.2310
@return lRet, logico, Indica se conseguiu realizar a carga
/*/
Method CargaMonitor() Class DocumentosAVencer
    Local lRet        := .T.
    Local nIndTag     := 0
    Local oCarga      := PCPMonitorCarga():New()
    Local oExemplo    := JsonObject()     :New()
    Local oParametros := JsonObject()     :New()
        
    If !PCPMonitorCarga():monitorAtualizado("DocumentosAVencer")
        
        oCarga:setaTitulo(STR0033) //"Documentos a Vencer"
        oCarga:setaObjetivo(STR0032) //"Apresentar o número de documentos a vencer do módulo Controle de Documentos (SIGAQDO) do usuário logado ou de todos os usuários, do meu departamento ou para todos os departamento, dentro de um período configurado, utilizando o conceito de semáforo para indicar os níveis Aceitável, Atenção e Crítico."
        oCarga:setaAgrupador(STR0003) //"Qualidade"
        oCarga:setaFuncaoNegocio("DocumentosAVencer")
        oCarga:setaTiposPermitidos("chart;info")
        oCarga:setaTiposGraficoPermitidos("gauge")
        oCarga:setaTipoPadrao("info")
        oCarga:setaTipoGraficoPadrao("")
        oCarga:setaTipoDetalhe("detalhe")

        oExemplo := DocumentosVencidos():MontaJsonInfo(@oExemplo,2,{"1","3"},"2",.F.)

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
        oCarga:setaPropriedade("03_TIPOPERIODO","",STR0008 + "*",4,,,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,DocumentosAVencer():MontaComboPeriodos(oParametros["03_TIPOPERIODO"]))

        //STR0009 - "Usuário Logado"
        oCarga:setaPropriedade("04_USUARIO_LOGADO" ,"",STR0009,4,,,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,DocumentosVencidos():MontaComboUsuarioLogado(oParametros["04_USUARIO_LOGADO"]))
        
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
@author cintia.paul
@since 27/10/2023
@version P12.1.2310
@param 01 - oFiltros, objeto Json, Contém as propriedades do monitor usadas para filtrar a query de busca
@param 02 - cTipo   , caracter   , Tipo chart/info
@param 03 - cSubTipo, caracter   , Tipo de grafico pie/bar/column
@return cJsonDados, caracter   , Retorna um novo Json em formato texto, pronto para conversão e exibição no front
/*/
Method BuscaDados(oFiltros, cTipo, cSubTipo) Class DocumentosAVencer
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

    dDataFim                  := DocumentosAVencer():RetornaPeriodoFinal(oFiltros["03_TIPOPERIODO"],;
                                                                                      dDataFim)
    dDataIni                  := dDataBase

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
        oJson := DocumentosVencidos():MontaJsonInfo(@oJson,nQtde,aSemaforo,.F.)
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
@author cintia.paul
@since 27/10/2023
@version P12.1.2310
@param 01 - oFiltros, objeto, objeto json com os filtros da consulta 
@param 02 - nPagina , número, número de página da consulta
@return cJson, string Json, string com os dados de detalhes para exibição em tabela de detalhes
/*/
Method BuscaDetalhes(oFiltros, nPagina) Class DocumentosAVencer
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
    dDataFim       := DocumentosAVencer():RetornaPeriodoFinal(oFiltros["03_TIPOPERIODO"],;
                                                                        dDataFim)
    dDataIni       := dDatabase

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

/*/{Protheus.doc} MontaComboPeriodos
Cria JSON com os dados para COMBO de Períodos
@type Method
@author cintia.paul
@since 27/10/2023
@version P12.1.2310
@param 01 - oParametro, objeto, cria por referência o objeto JSON oFiltros["03_TIPOPERIODO"]
@return oParametro, objeto, retorna o objeto criado
/*/
Method MontaComboPeriodos(oParametro) Class DocumentosAVencer
    Default oParametro      := JsonObject():New()
    oParametro["opcoes"] :=       STR0034+":7"  //"Próximos 7 dias"
    oParametro["opcoes"] += ";" + STR0035+":30"  //"Próximos 30 dias"
    oParametro["opcoes"] += ";" + STR0036+":90" //"Próximos 90 dias"
Return oParametro

/*/{Protheus.doc} RetornaPeriodoFinal
Retorna Período Final
@type METHOD
@author cintia.paul
@since 27/10/2023
@version P12.1.2310
@param 01 - cFiltro  , caracter, tipo do filtro: 1:Próximos 30 dias; 6: Próximos 180 dias; 12: Próximos 365 dias
@param 02 - dDataFim , data    , data final para filtro
@return dDataIni     , data    , data inicial para filtro
/*/
Method RetornaPeriodoFinal(cFiltro, dDataIni) Class DocumentosAVencer
    Local dDataFim := dDataIni

    Do Case
    Case cFiltro == "7"
        dDataFim += 7 //7 dias
    Case cFiltro == "30"
        dDataFim += 30 //30 dias
    Case cFiltro == "90"
        dDataFim += 90 //90 dias
    EndCase

Return dDataFim

/*/{Protheus.doc} ValidaPropriedades
Valida os dados informados nas propriedades do Monitor
@type Method
@author cintia.paul
@since 27/10/2023
@version P12.1.2310
@param  oFiltros, objeto json, Objeto json com os filtros para a consulta dos dados
@return aRetorno, array      , [1] logico - indica se os dados são válidos [2] caracter - mensagem de erro
/*/
Method ValidaPropriedades(oFiltros) Class DocumentosAVencer
Return DocumentosVencidos():ValidaPropriedades(oFiltros,.F.)
