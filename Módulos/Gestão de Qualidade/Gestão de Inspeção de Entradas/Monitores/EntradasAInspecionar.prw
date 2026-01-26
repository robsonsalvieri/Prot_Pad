#INCLUDE "ENTRADASAINSPECIONAR.CH"
#INCLUDE "QLTMONITORDEF.CH"
#INCLUDE "TOTVS.CH"

STATIC nModulo := 21

/*/{Protheus.doc} EntradasAInspecionar
Classe para prover os dados do Monitor de Entradas a Inspecionar
@type Class
@author jorge.oliveira
@since 10/10/2023
@version P12.1.2310
@return Nil
/*/
Class EntradasAInspecionar FROM LongNameClass
    /*
        Métodos Padrões, utilizados pela classe "PCPMonitor"
    */
    Static Method BuscaDados(oFiltros)
    Static Method BuscaDetalhes(oFiltros,nPagina)
    Static Method CargaMonitor()
    Static Method ValidaPropriedades(oFiltros)

    /*
        Métodos Internos
    */
    Static Method AdicionaColunasDetalhes(lExpResult)
    Static Method MontaRetornoJson(oDados, cFilAux, cCodLab, dDataIni, dDataFim)
    Static Method MontaWhereQuery(cFilAux, cCodLab, cCpoData, dDataIni, dDataFim)
    Static Method RetornaBoxStringJson(cCor, lCima, lBaixo)
    Static Method RetornaDadosDoBanco(cFilAux, cCodLab, cCpoData, dDataIni, dDataFim)
    Static Method RetornaDescricaoLaboratorio(cFilAux, cCodLab)
    Static Method RetornaPeriodoInicial(cFiltro, dDataFim)
    Static Method SetaPropriedadeFilial(oCarga, cCodigo, cTitulo)

EndClass

/*/{Protheus.doc} BuscaDados
Realiza a busca dos dados para o Monitor
@type Method
@author jorge.oliveira
@since 10/10/2023
@version P12.1.2310
@param  oFiltros, objeto json, Objeto json com os filtros para a consulta dos dados
@return cJson   , caracter   , string json com os dados para retorno
/*/
Method BuscaDados(oFiltros) Class EntradasAInspecionar
    Local dDataFim := dDatabase
    Local dDataIni := dDatabase
    Local oDadosDB := Nil
    Local oRetorno := Nil

    oFiltros["01_QEK_FILIAL"] := PadR(oFiltros["01_QEK_FILIAL"], FWSizeFilial())
    dDataFim                  := dDatabase
    dDataIni                  := EntradasAInspecionar():RetornaPeriodoInicial(oFiltros["04_TIPOPERIODO"],;
                                                                                dDataFim)

    oDadosDB                  := EntradasAInspecionar():RetornaDadosDoBanco(oFiltros["01_QEK_FILIAL"],;
                                                                                oFiltros["02_QEL_LABOR"],;
                                                                                oFiltros["03_FILTRODATA"],;
                                                                                dDataIni,;
                                                                                dDataFim)

    oRetorno                  := EntradasAInspecionar():MontaRetornoJson(oDadosDB,;
                                                                                 oFiltros["01_QEK_FILIAL"],;
                                                                                 oFiltros["02_QEL_LABOR"],;
                                                                                 dDataIni,;
                                                                                 dDataFim)

Return oRetorno:ToJson()

/*/{Protheus.doc} MontaRetornoJson
Monta objeto json para retornar os dados do Monitor
@type Method
@author jorge.oliveira
@since 10/10/2023
@version P12.1.2310
@param 01 - oDados  , objeto  , objeto com os dados para exibicao
@param 02 - cFilAux , caracter, filial de selecao para referencia
@param 03 - cCodLab , caracter, codigo do laboratorio
@param 04 - dDataIni, data    , data inicial
@param 05 - dDataFim, data    , data final
@return oJson     , objeto json, Objeto json com os dados para retorno
/*/
Method MontaRetornoJson(oDados, cFilAux, cCodLab, dDataIni, dDataFim) Class EntradasAInspecionar
    Local cClasseNum := "po-font-title po-text-center bold-text po-sm-12 po-pt-1"
    Local cClasseSub := "po-font-text-large po-text-center po-sm-12 po-pb-1"
    Local nIndLinha  := 0
    Local nIndTag    := 0
    Local oJson      := JsonObject():New()

    oJson["alturaMinimaWidget"] := "350px"
    oJson["alturaMaximaWidget"] := "500px"
    oJson["corFundo"]           := "white"
    oJson["corTitulo"]          := ""
    oJson["tags"]               := {}

    PCPMonitorUtils():AdicionaTagMonitor(oJson["tags"],@nIndTag,"po-icon-calendar",dToC(dDataIni) + " - " + dToC(dDataFim))
    
    If !Empty(cCodLab)
        PCPMonitorUtils():AdicionaTagMonitor(oJson["tags"],@nIndTag,"po-icon-exam",EntradasAInspecionar():RetornaDescricaoLaboratorio(cFilAux, cCodLab))

    EndIf

    oJson["linhas"] := {}
    PCPMonitorUtils():AdicionaLinhaInformacao(oJson["linhas"],@nIndLinha,oDados["N"],cClasseNum,EntradasAInspecionar():RetornaBoxStringJson(COR_CINZA_LEG,.T.,.F.)    ,.T.,"QEK.QEK_SITENT=' '")
    PCPMonitorUtils():AdicionaLinhaInformacao(oJson["linhas"],@nIndLinha,STR0001    ,cClasseSub,EntradasAInspecionar():RetornaBoxStringJson(COR_CINZA_LEG,.F.,.T.))      //"Não Iniciadas"

    PCPMonitorUtils():AdicionaLinhaInformacao(oJson["linhas"],@nIndLinha,oDados["S"],cClasseNum,EntradasAInspecionar():RetornaBoxStringJson(COR_AZUL_LEG,.T.,.F.)     ,.T.,"QEK.QEK_SITENT='7'")
    PCPMonitorUtils():AdicionaLinhaInformacao(oJson["linhas"],@nIndLinha,STR0002    ,cClasseSub,EntradasAInspecionar():RetornaBoxStringJson(COR_AZUL_LEG,.F.,.T.))       //"Laudo Laboratório Pendente"

    PCPMonitorUtils():AdicionaLinhaInformacao(oJson["linhas"],@nIndLinha,oDados["P"],cClasseNum,EntradasAInspecionar():RetornaBoxStringJson(COR_AZUL_CLARO_LEG,.T.,.F.),.T.,"QEK.QEK_SITENT='1'")
    PCPMonitorUtils():AdicionaLinhaInformacao(oJson["linhas"],@nIndLinha,STR0003    ,cClasseSub,EntradasAInspecionar():RetornaBoxStringJson(COR_AZUL_CLARO_LEG,.F.,.T.)) //"Laudo Geral Pendente"

Return oJson

/*/{Protheus.doc} BuscaDetalhes
Realiza a busca dos dados para montar os detalhes do Monitor
@type Method
@author jorge.oliveira
@since 10/10/2023
@version P12.1.2310
@param 01 - oFiltros, objeto, objeto json com os filtros selecionados
@param 02 - nPagina , número, número de página para retorno dos dados
@return cJson   , caracter   , string json com os dados para retorno
/*/
Method BuscaDetalhes(oFiltros,nPagina) Class EntradasAInspecionar
    Local aCampos          :={"QEK_PRODUT", "B1_DESC", "QEK_REVI", "QEK_LOCORI", "QEK_UNIMED", "QEK_TAMLOT", "QEK_LOTE", "QEK_DTNFIS", "QEK_DTENTR", "QEK_FORNEC", "QEK_LOJFOR", "A1_NREDUZ", "QEK_SITENT"}
    Local cAlias           := Nil
    Local cCampo           := ""
    Local cCodLab          := ""
    Local cFilAux          := ""
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

    Default nPagina := 1

    cFilAux        := PadR(oFiltros["01_QEK_FILIAL"], FWSizeFilial())
    cParamDet      := IIF(oFiltros:HasProperty("PARAMETROSDETALHE"),oFiltros["PARAMETROSDETALHE"],"")
    cCodLab        := oFiltros["02_QEL_LABOR"]
    dDataFim       := dDatabase
    dDataIni       := EntradasAInspecionar():RetornaPeriodoInicial(oFiltros["04_TIPOPERIODO"], dDataFim)

    If nPagina == 0
        lExpResult := .T.

    EndIf

    cQuery := " SELECT "
    cQuery += "     QEK_TIPONF, QEK_PRODUT, QEK_REVI, QEK_DTENTR,QEK_LOCORI, QEK_LOTE, QEK_HRENTR,QEK_UNIMED, QEK_TAMLOT, QEK_TAMAMO, QEK_NTFISC, QEK_SERINF, QEK_TIPDOC,"
    cQuery += "     QEK_DTNFIS,"
    cQuery += "     QEK_FORNEC, "
    cQuery += "     QEK_LOJFOR, "
    cQuery += "     CASE " 
    cQuery += "         WHEN QEK_TIPONF = 'B' "
    cQuery += "             THEN ISNULL(A1_NREDUZ,'') "
    cQuery += "         ELSE "
    cQuery += "             ISNULL(A2_NREDUZ,'') "
    cQuery += "     END AS A1_NREDUZ, "
    cQuery += "     B1_DESC, QEK_SITENT "
    cQuery += " FROM "+RetSqlName("QEK")+" QEK "
    cQuery += " LEFT JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1",cFilAux)+"' AND SB1.B1_COD = QEK.QEK_PRODUT AND SB1.D_E_L_E_T_ = ' ' "
    cQuery += " LEFT JOIN "+RetSqlName("SA1")+" SA1 ON QEK_TIPONF IN ('D','B') AND SA1.A1_FILIAL = '" + xFilial("SA1",cFilAux) + "' AND SA1.A1_COD = QEK.QEK_FORNEC AND SA1.A1_LOJA = QEK.QEK_LOJFOR AND SA1.D_E_L_E_T_ = ' ' "
    cQuery += " LEFT JOIN "+RetSqlName("SA2")+" SA2 ON QEK_TIPONF =  'N'       AND SA2.A2_FILIAL = '" + xFilial("SA2",cFilAux) + "' AND SA2.A2_COD = QEK.QEK_FORNEC AND SA2.A2_LOJA = QEK.QEK_LOJFOR AND SA2.D_E_L_E_T_ = ' ' "
    cQuery += EntradasAInspecionar():MontaWhereQuery(cFilAux, cCodLab, oFiltros["03_FILTRODATA"], dDataIni, dDataFim)
    
    If !Empty(cParamDet)
        cQuery += " AND " + cParamDet

    EndIf

    cQuery := oQLTQueryManager:ChangeQuery(cQuery)
    cAlias := oQLTQueryManager:ExecuteQuery(cQuery)
    
    If nPagina > 1
		nStart := ( (nPagina-1) * nTamPagina )
		If nStart > 0
			(cAlias)->(DbSkip(nStart))

		EndIf

	EndIf

    oDados["items"]        := {}
    oDados["columns"]      := EntradasAInspecionar():AdicionaColunasDetalhes(lExpResult)
    oDados["canExportCSV"] := .T.
    oDados["tags"]         := {}
    
    PCPMonitorUtils():AdicionaTagMonitor(oDados["tags"],@nIndTag,"po-icon-calendar",dToC(dDataIni) + " - " + dToC(dDataFim))
    
    If !Empty(cCodLab)
        PCPMonitorUtils():AdicionaTagMonitor(oDados["tags"],@nIndTag,"po-icon-exam",EntradasAInspecionar():RetornaDescricaoLaboratorio(cFilAux, cCodLab))

    EndIf
    
    Do Case
        Case "' '" $ cParamDet .OR. Empty(cParamDet)
            PCPMonitorUtils():AdicionaTagMonitor(oDados["tags"],@nIndTag,"po-icon-filter",STR0001) //"Não Iniciadas"

        Case "'7'" $ cParamDet
            PCPMonitorUtils():AdicionaTagMonitor(oDados["tags"],@nIndTag,"po-icon-filter",STR0002) //"Laudo Laboratório Pendente"

        Case "'1'" $ cParamDet
            PCPMonitorUtils():AdicionaTagMonitor(oDados["tags"],@nIndTag,"po-icon-filter",STR0003) //"Laudo Geral Pendente"

    EndCase

    While (cAlias)->(!Eof())
        aAdd(oDados["items"], JsonObject():New())
        nRegistro++
        
        For nCampo := 1 to nCampos
            cCampo                               := aCampos[nCampo]
            oDados["items"][nRegistro][cCampo]   := (cAlias)->&(cCampo)

        Next nCampo

        oDados["items"][nRegistro]["QEK_DTENTR"] := PCPMonitorUtils():FormataData((cAlias)->QEK_DTENTR,4)
        oDados["items"][nRegistro]["QEK_DTNFIS"] := PCPMonitorUtils():FormataData((cAlias)->QEK_DTNFIS,4)

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
@type Method
@author jorge.oliveira
@since 10/10/2023
@version P12.1.2310
@param 01 - lExpResult, logico, Indica se trata todas as colunas como visible
@return aColunas  , array   , Array de objetos com as colunas da table po-ui
/*/
Method AdicionaColunasDetalhes(lExpResult) Class EntradasAInspecionar
    Local aCampos    :={"QEK_PRODUT", "B1_DESC", "QEK_REVI", "QEK_LOCORI", "QEK_UNIMED", "QEK_TAMLOT", "QEK_LOTE", "QEK_DTNFIS", "QEK_DTENTR", "QEK_FORNEC", "QEK_LOJFOR", "A1_NREDUZ"}
    Local aColunas   := {}
    Local aLabels    := {}
    Local cTipo      := ""
    Local lVisivel   := .T.
    Local nCampo     := 0
    Local nCampos    := Len(aCampos)
    Local nIndice    := 0
    Local nIndLabels := 0

    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabels,@nIndLabels," ",COR_CINZA_LEG     ,STR0001,COR_BRANCO)//"Não Iniciadas"
    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabels,@nIndLabels,"7",COR_AZUL_LEG      ,STR0002,COR_BRANCO)//"Laudo Laboratório Pendente"
    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabels,@nIndLabels,"1",COR_AZUL_CLARO_LEG,STR0003,COR_BRANCO)//"Laudo Geral Pendente"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"QEK_SITENT","Status","cellTemplate",.T.,.T.,aLabels)

    For nCampo := 1 to nCampos
        cCampo := aCampos[nCampo]
        If X3Uso(GetSx3Cache(cCampo,"X3_USADO"),nModulo)
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

/*/{Protheus.doc} CargaMonitor
Realiza a carga do Monitor padrão na base de dados
@type Method
@author jorge.oliveira
@since 10/10/2023
@version P12.1.2310
@return lRet, logico, Indica se conseguiu realizar a carga
/*/
Method CargaMonitor() Class EntradasAInspecionar

    Local lRet        := .T.
    Local oCarga      := PCPMonitorCarga():New()
    Local oDadosEx    := Nil
    Local oExemplo    := Nil
    Local oParametros := Nil
 
    If !oCarga:monitorAtualizado("EntradasAInspecionar")
        oDadosEx      := JsonObject():New()
        oExemplo      := JsonObject():New()
        oParametros   := JsonObject():New()

        oDadosEx["N"] := "100"
        oDadosEx["S"] := "50"
        oDadosEx["P"] := "10"
        oExemplo      := EntradasAInspecionar():MontaRetornoJson(oDadosEx,xFilial("QEK"),"LABFIS",Ctod("01/01/2023"),Ctod("30/01/2023"))

        oParametros["03_FILTRODATA"]            := JsonObject():New()
        oParametros["03_FILTRODATA"]["opcoes"]  := STR0004+":QEK_DTENTR;"+STR0005+":QEK_DTNFIS;" //"Data Entrada:QEK_DTENTR;Data Nota Fiscal:QEK_DTNFIS"
        oParametros["04_TIPOPERIODO"]           := JsonObject():New()
        oParametros["04_TIPOPERIODO"]["opcoes"] := STR0006+":D;"+STR0007+":S;"+STR0008+":M;"+STR0009+":T"//"Dia Atual:D;Últimos 7 dias:S;Últimos 30 dias:M;Últimos 90 dias:T"

        oCarga:setaTitulo(STR0010)    //"Entradas a Inspecionar"
        oCarga:setaObjetivo(STR0011)  //"Apresentar, para acompanhamento, o número de Entradas a Inspecionar, nos status Não Iniciadas, com Laudo Laboratório Pendente e com Laudo Geral Pendente, dentro de um período de entradas."
        oCarga:setaAgrupador(STR0012) //"Qualidade"
        oCarga:setaFuncaoNegocio("EntradasAInspecionar")
        oCarga:setaTiposPermitidos("info")
        oCarga:setaTiposGraficoPermitidos("")
        oCarga:setaTipoPadrao("info")
        oCarga:setaTipoGraficoPadrao("")
        oCarga:setaTipoDetalhe("detalhe")
        oCarga:setaExemploJsonTexto(.F.,oExemplo)
        EntradasAInspecionar():SetaPropriedadeFilial(oCarga, "01_QEK_FILIAL", "Filial" + "*")                                               //"Filial"
        oCarga:setaPropriedadeLookupTabelaGenerica("02_QEL_LABOR",STR0013,.F.,"Q2")                                                                //"Laboratório"
        oCarga:setaPropriedade("03_FILTRODATA" ,""   ,STR0014 + "*",4,,,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,oParametros["03_FILTRODATA" ]) //"Data de referência"
        oCarga:setaPropriedade("04_TIPOPERIODO","",STR0015 + "*",4,,,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,oParametros["04_TIPOPERIODO"]) //"Período"
        
        
        lRet := Iif(!oCarga:gravaMonitorPropriedades(), .F., lRet )

        oCarga:Destroy()

        FreeObj(oDadosEx)
        FreeObj(oExemplo)
        FreeObj(oParametros)
        FwFreeObj(oCarga)

    EndIf

Return lRet

/*/{Protheus.doc} RetornaDadosDoBanco
Busca dados para exibicao do monitor no banco de dados
@type Method
@author jorge.oliveira
@since 10/10/2023
@version P12.1.2310
@param 01 - cFilAux , caracter, filial de selecao para referencia
@param 02 - cCodLab , caracter, codigo do laboratorio
@param 03 - cCpoData, caracter, campo de data para consideracao no filtro
@param 04 - dDataIni, data    , data inicial
@param 05 - dDataFim, data    , data final
@return oDadosDB, objeto, Objeto json com os dados do banco para exibicao
/*/
Method RetornaDadosDoBanco(cFilAux, cCodLab, cCpoData, dDataIni, dDataFim) Class EntradasAInspecionar
    Local cAlias           := Nil
    Local cQuery           := ""
    Local cSituacao        := ""
    Local oDadosDB         := JsonObject()     :New()
    Local oQLTQueryManager := QLTQueryManager():New()

    oDadosDB["N"] := "0"
    oDadosDB["S"] := "0"
    oDadosDB["P"] := "0"

    cQuery += " SELECT QEK_SITENT, COUNT(*) AS QTD "
    cQuery += " FROM " + RetSqlName("QEK") + " QEK "
    cQuery += EntradasAInspecionar():MontaWhereQuery(cFilAux, cCodLab, cCpoData, dDataIni, dDataFim)
    cQuery += " GROUP BY QEK_SITENT "

    cQuery := oQLTQueryManager:ChangeQuery(cQuery)
    cAlias := oQLTQueryManager:ExecuteQuery(cQuery)

    While (cAlias)->(!Eof())        
        cSituacao := AllTrim((cAlias)->QEK_SITENT)

        Do Case
            Case Empty(cSituacao)
                oDadosDB["N"] := Str((cAlias)->QTD)

            Case cSituacao == "7"
                oDadosDB["S"] := Str((cAlias)->QTD)

            Case cSituacao == "1"
                oDadosDB["P"] := Str((cAlias)->QTD)

        EndCase
        
        (cAlias)->(dbSkip())

    EndDo

    (cAlias)->(dbCloseArea()) 
       
Return oDadosDB

/*/{Protheus.doc} MontaWhereQuery
Monta dados WHERE para selecao dos dados da QEK para contagem
@type Method
@author jorge.oliveira
@since 10/10/2023
@version P12.1.2310
@param 01 - cFilAux , caracter, filial de selecao para referencia
@param 02 - cCodLab , caracter, codigo do laboratorio
@param 03 - cCpoData, caracter, campo de data para consideracao no filtro
@param 04 - dDataIni, data    , data inicial
@param 05 - dDataFim, data    , data final
@return cWhere, objeto json, Objeto json com os dados do último apontamento de produção do recurso
/*/
Method MontaWhereQuery(cFilAux, cCodLab, cCpoData, dDataIni, dDataFim) Class EntradasAInspecionar
    Local cWhere := ""
    
    If !Empty(cCodLab) //Alica Filtro de Laboratórios
        cWhere += " INNER JOIN "
        cWhere += " (SELECT DISTINCT QE8_PRODUT AS PRODUTO, QE8_REVI AS REVISAO "
        cWhere += " FROM " + RetSQLName("QE8") + " "
        cWhere += " WHERE D_E_L_E_T_ = ' ' "
        cWhere += " AND (QE8_FILIAL = '" + xFilial("QE8", cFilAux) + "') "
        cWhere += " AND (QE8_LABOR = '" + cCodLab + "') "
        cWhere += " UNION "
        cWhere += " SELECT DISTINCT QE7_PRODUT AS PRODUTO, QE7_REVI AS REVISAO "
        cWhere += " FROM " + RetSQLName("QE7") + " "
        cWhere += " WHERE D_E_L_E_T_ = ' ' "
        cWhere += " AND (QE7_FILIAL = '" + xFilial("QE7", cFilAux) + "') "
        cWhere += " AND (QE7_LABOR = '" + cCodLab + "') "
        cWhere += " ) FILTROLAB ON QEK.QEK_PRODUT = FILTROLAB.PRODUTO "
        cWhere +=            " AND QEK.QEK_REVI   = FILTROLAB.REVISAO "

    EndIf

    cWhere += " WHERE (QEK.D_E_L_E_T_ = ' ') "
    cWhere +=   " AND (QEK.QEK_SITENT IN ('1', '7', ' ')) "
    cWhere +=         " AND QEK.QEK_FILIAL = '" + xFilial("QEK", cFilAux) + "' "
    cWhere +=         " AND QEK." + cCpoData + " BETWEEN '" + DtoS(dDataIni) + "' AND '" + DtoS(dDataFim) + "' "

Return cWhere

/*/{Protheus.doc} RetornaPeriodoInicial
Retorna Período Inicial
@type Method
@author jorge.oliveira
@since 10/10/2023
@version P12.1.2310
@param 01 - cFiltro , caracter, tipo do filtro: D-Dia Atual;S-Ultimos 7 dias; M-Ultimos 30 dias; T-Ultimos 90 dias
@param 02 - dDataFim, data    , data final para filtro
@return dDataIni, data      , data inicial para filtro
/*/
Method RetornaPeriodoInicial(cFiltro, dDataFim) Class EntradasAInspecionar
    Local dDataIni := dDataFim

    Do Case
        Case cFiltro == "S"
            dDataIni -= 7

        Case cFiltro == "M"
            dDataIni -= 30

        Case cFiltro == "T"
            dDataIni -= 90

    EndCase

Return dDataIni

/*/{Protheus.doc} RetornaBoxStringJson
Retorna formatação CSS de BOX em String Json
@type Method
@author jorge.oliveira
@since 10/10/2023
@version P12.1.2310
@param 01 cCor  , caracter, cor para utilizacao no BOX
@param 02 lCima , logico , indica ser o box superior
@param 03 lBaixo, logico , indica ser o box inferior
@return cJson, caracter, conteudo json com dados CSS para consideracao no BOX de visualizacao dos dados
/*/
Method RetornaBoxStringJson(cCor, lCima, lBaixo) Class EntradasAInspecionar
    Local oJson  := JsonObject():New()

    oJson["background-color"] := cCor
    
    If lCima
        oJson["border-radius"]    := "3px 3px 0 0"
        oJson["margin"]           := "2px 0 0 0"

    ElseIf lBaixo
        oJson["border-radius"]    := "0 0 3px 3px"
        oJson["margin"]           := "0 0 1px 0"

    EndIf

    oJson["border-color"]     := cCor
    oJson["border"]           := "5px"
    oJson["cursor"]           := "pointer"

Return oJson:toJson()

/*/{Protheus.doc} RetornaDescricaoLaboratorio
Retorna a descricao do laboratorio
@type Method
@author jorge.oliveira
@since 10/10/2023
@version P12.1.2310
@param 01 - cFilAux, caracter, filial do sistema relacionado aos dados
@param 02 - cCodLab, caracter, codigo do laboratorio
@return cDescricao, caracter, descricao do laboratorio
/*/
Method RetornaDescricaoLaboratorio(cFilAux, cCodLab) Class EntradasAInspecionar
    Local aContent   := Nil
    Local cDescricao := cCodLab
    Local cFilBkp    := cFilAnt

    If !Empty(cCodLab)
        cFilAnt    := xFilial("SX5", PadR(cFilAux, FWSizeFilial()))
        aContent   := FWGetSX5( "Q2", PadR(cCodLab,GetSx3Cache("QEL_LABOR","X3_TAMANHO")))
        cDescricao := Iif(Len(aContent)>0, Capital(aContent[1][4]), "")
        FwFreeArray(aContent)

    EndIf

    cFilAnt := cFilBkp

Return cDescricao

/*/{Protheus.doc} ValidaPropriedades
Valida os dados informados nas propriedades do Monitor
@type Method
@author jorge.oliveira
@since 10/10/2023
@version P12.1.2310
@param  oFiltros, objeto json, Objeto json com os filtros para a consulta dos dados
@return aRetorno, array      , [1] logico - indica se os dados são válidos [2] caracter - mensagem de erro
/*/
Method ValidaPropriedades(oFiltros) Class EntradasAInspecionar
    Local aRetorno := {.T.,""}

    PCPMonitorUtils():ValidaPropriedadeFilial(oFiltros["01_QEK_FILIAL"], @aRetorno)

    If aRetorno[1] .And. (!oFiltros:HasProperty("03_FILTRODATA") .Or. oFiltros["03_FILTRODATA"] == Nil .Or. Empty(oFiltros["03_FILTRODATA"]))
        aRetorno[1] := .F.
        aRetorno[2] := STR0018 //"Deve ser informada a Data de Referência para consulta."

    EndIf

    If aRetorno[1] .And. (!oFiltros:HasProperty("04_TIPOPERIODO") .Or. oFiltros["04_TIPOPERIODO"] == Nil .Or. Empty(oFiltros["04_TIPOPERIODO"]))
        aRetorno[1] := .F.
        aRetorno[2] := STR0019 //"Deve ser informado o período para análise do monitor."

    EndIf

Return aRetorno

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
Method SetaPropriedadeFilial(oCarga, cCodigo, cTitulo) Class EntradasAInspecionar
    Local oPrmAdc := JsonObject():New()
    
    oPrmAdc["filtroServico"]                := "/api/pcp/v1/pcpmonitorapi/consulta"
    oPrmAdc["parametrosServico"]            := JsonObject():New()
    oPrmAdc["parametrosServico"]["metodo"]  := "PCPMonitorConsultas():BuscaFiliais"
    oPrmAdc["labelSelect"]                  := "Description"
    oPrmAdc["valorSelect"]                  := "Code"

    oCarga:setaPropriedade(cCodigo,"",cTitulo,7,GetSx3Cache("HZD_FILIAL","X3_TAMANHO"),0,"po-sm-12 po-md-6 po-lg-6 po-xl-6",/*oEstilos*/,/*cIcone*/,oPrmAdc)

    FreeObj(oPrmAdc)

Return
