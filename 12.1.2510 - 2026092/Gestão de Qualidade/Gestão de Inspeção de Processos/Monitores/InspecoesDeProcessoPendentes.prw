#INCLUDE "INSPECOESDEPROCESSOPENDENTES.CH"
#INCLUDE "QLTMONITORDEF.CH"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} InspecoesDeProcessoPendentes
Classe para prover os dados do Monitor de Inspeções de Processo Pendentes
@type Class
@author brunno.costa
@since 10/10/2023
@version P12.1.2310
@return Nil
/*/
Class InspecoesDeProcessoPendentes FROM LongNameClass

    //Métodos Padrões
    Static Method BuscaDados(oFiltros)
    Static Method BuscaDetalhes(oFiltros,nPagina)
    Static Method CargaMonitor()
    Static Method ValidaPropriedades(oFiltros)

    //Métodos Internos
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
@type METHOD
@author brunno.costa
@since 10/10/2023
@version P12.1.2310
@param  oFiltros, objeto json, Objeto json com os filtros para a consulta dos dados
@return cJson   , caracter   , string json com os dados para retorno
/*/
Method BuscaDados(oFiltros) Class InspecoesDeProcessoPendentes
    Local dDataFim   := dDatabase
    Local dDataIni   := dDatabase
    Local oRetorno   := Nil
    Local oDadosDB   := Nil

    oFiltros["01_QPK_FILIAL"] := PadR(oFiltros["01_QPK_FILIAL"], FWSizeFilial())
    dDataFim                  := dDatabase
    dDataIni                  := InspecoesDeProcessoPendentes():RetornaPeriodoInicial(oFiltros["04_TIPOPERIODO"],;
                                                                                      dDataFim)

    oDadosDB                  := InspecoesDeProcessoPendentes():RetornaDadosDoBanco(oFiltros["01_QPK_FILIAL"],;
                                                                                    oFiltros["02_QPL_LABOR"],;
                                                                                    oFiltros["03_FILTRODATA"],;
                                                                                    dDataIni,;
                                                                                    dDataFim)

    oRetorno                  := InspecoesDeProcessoPendentes():MontaRetornoJson(oDadosDB,;
                                                                                 oFiltros["01_QPK_FILIAL"],;
                                                                                 oFiltros["02_QPL_LABOR"],;
                                                                                 dDataIni,;
                                                                                 dDataFim)
Return oRetorno:ToJson()

/*/{Protheus.doc} MontaRetornoJson
Monta objeto json para retornar os dados do Monitor
@type METHOD
@author brunno.costa
@since 10/10/2023
@version P12.1.2310
@param 01 - oDados  , objeto  , objeto com os dados para exibicao
@param 02 - cFilAux , caracter, filial de selecao para referencia
@param 03 - cCodLab , caracter, codigo do laboratorio
@param 04 - dDataIni, data    , data inicial
@param 05 - dDataFim, data    , data final
@return oJson     , objeto json, Objeto json com os dados para retorno
/*/
METHOD MontaRetornoJson(oDados, cFilAux, cCodLab, dDataIni, dDataFim) Class InspecoesDeProcessoPendentes

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
        PCPMonitorUtils():AdicionaTagMonitor(oJson["tags"],@nIndTag,"po-icon-exam",InspecoesDeProcessoPendentes():RetornaDescricaoLaboratorio(cFilAux, cCodLab))
    EndIf

    oJson["linhas"] := {}
    PCPMonitorUtils():AdicionaLinhaInformacao(oJson["linhas"],@nIndLinha,oDados["N"],cClasseNum,InspecoesDeProcessoPendentes():RetornaBoxStringJson(COR_CINZA_LEG,.T.,.F.)    ,.T.,"QPK.QPK_SITOP=' '")
    PCPMonitorUtils():AdicionaLinhaInformacao(oJson["linhas"],@nIndLinha,STR0001    ,cClasseSub,InspecoesDeProcessoPendentes():RetornaBoxStringJson(COR_CINZA_LEG,.F.,.T.))      //"Não Iniciadas"

    PCPMonitorUtils():AdicionaLinhaInformacao(oJson["linhas"],@nIndLinha,oDados["S"],cClasseNum,InspecoesDeProcessoPendentes():RetornaBoxStringJson(COR_AZUL_LEG,.T.,.F.)     ,.T.,"QPK.QPK_SITOP='1'")
    PCPMonitorUtils():AdicionaLinhaInformacao(oJson["linhas"],@nIndLinha,STR0002    ,cClasseSub,InspecoesDeProcessoPendentes():RetornaBoxStringJson(COR_AZUL_LEG,.F.,.T.))       //"Sem Laudo"

    PCPMonitorUtils():AdicionaLinhaInformacao(oJson["linhas"],@nIndLinha,oDados["P"],cClasseNum,InspecoesDeProcessoPendentes():RetornaBoxStringJson(COR_AZUL_CLARO_LEG,.T.,.F.),.T.,"QPK.QPK_SITOP='7'")
    PCPMonitorUtils():AdicionaLinhaInformacao(oJson["linhas"],@nIndLinha,STR0003    ,cClasseSub,InspecoesDeProcessoPendentes():RetornaBoxStringJson(COR_AZUL_CLARO_LEG,.F.,.T.)) //"Laudo Parcial"

Return oJson

/*/{Protheus.doc} BuscaDetalhes
Realiza a busca dos dados para montar os detalhes do Monitor
@type METHOD
@author brunno.costa
@since 10/10/2023
@version P12.1.2310
@param 01 - oFiltros, objeto, objeto json com os filtros selecionados
@param 02 - nPagina , número, número de página para retorno dos dados
@return cJson   , caracter   , string json com os dados para retorno
/*/
Method BuscaDetalhes(oFiltros,nPagina) Class InspecoesDeProcessoPendentes
    Local aCampos          :={"QPK_OP", "QPK_PRODUT", "B1_DESC", "QPK_REVI", "QPK_LOCAL", "QPK_UM", "QPK_TAMLOT", "QPK_LOTE", "QPK_NUMSER", "QPK_DTPROD", "QPK_EMISSA", "QPK_CLIENT", "QPK_LOJA", "A1_NREDUZ", "QPK_SITOP"}
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
    Local nPos             := 0
    Local nStart           := 1
    Local nTamPagina       := 20
    Local oDados           := JsonObject()     :New()
    Local oQLTQueryManager := QLTQueryManager():New()

    Default nPagina := 1

    cFilAux        := PadR(oFiltros["01_QPK_FILIAL"], FWSizeFilial())
    cParamDet      := IIF(oFiltros:HasProperty("PARAMETROSDETALHE"),oFiltros["PARAMETROSDETALHE"],"")
    cCodLab        := oFiltros["02_QPL_LABOR"]
    dDataFim       := dDatabase
    dDataIni       := InspecoesDeProcessoPendentes():RetornaPeriodoInicial(oFiltros["04_TIPOPERIODO"], dDataFim)

    If nPagina == 0
        lExpResult := .T.
    EndIf
    cQuery := "SELECT QPK_OP, QPK_PRODUT, QPK_REVI, QPK_LOCAL, QPK_UM, QPK_TAMLOT, QPK_LOTE, QPK_NUMSER, QPK_DTPROD, QPK_EMISSA, QPK_CLIENT, QPK_LOJA, B1_DESC, A1_NREDUZ, QPK_SITOP "
    cQuery += " FROM "+RetSqlName("QPK")+" QPK "
    cQuery += " LEFT JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1",cFilAux)+"' AND SB1.B1_COD = QPK.QPK_PRODUT AND SB1.D_E_L_E_T_ = ' ' "
    cQuery += " LEFT JOIN "+RetSqlName("SA1")+" SA1 ON SA1.A1_FILIAL = '"+xFilial("SA1",cFilAux)+"' AND SA1.A1_COD = QPK.QPK_CLIENT AND SA1.A1_LOJA = QPK.QPK_LOJA AND SA1.D_E_L_E_T_ = ' ' "
    cQuery += InspecoesDeProcessoPendentes():MontaWhereQuery(cFilAux, cCodLab, oFiltros["03_FILTRODATA"], dDataIni, dDataFim)
    If !Empty(cParamDet)
        cQuery += " AND " + cParamDet
    EndIf
    cQuery += " ORDER BY QPK."+AllTrim(oFiltros["03_FILTRODATA"])+" DESC, QPK.QPK_OP DESC"

    cQuery := oQLTQueryManager:ChangeQuery(cQuery)
    cAlias := oQLTQueryManager:ExecuteQuery(cQuery)
    
    If nPagina > 1
		nStart := ( (nPagina-1) * nTamPagina )
		If nStart > 0
			(cAlias)->(DbSkip(nStart))
		EndIf
	EndIf
    oDados["items"]        := {}
    oDados["columns"]      := InspecoesDeProcessoPendentes():AdicionaColunasDetalhes(lExpResult)
    oDados["canExportCSV"] := .T.
    oDados["tags"]         := {}
    PCPMonitorUtils():AdicionaTagMonitor(oDados["tags"],@nIndTag,"po-icon-calendar",dToC(dDataIni) + " - " + dToC(dDataFim))
    
    If !Empty(cCodLab)
        PCPMonitorUtils():AdicionaTagMonitor(oDados["tags"],@nIndTag,"po-icon-exam",InspecoesDeProcessoPendentes():RetornaDescricaoLaboratorio(cFilAux, cCodLab))
    EndIf
    
    If !Empty(cParamDet)
        Do Case
            Case "' '" $ cParamDet
                PCPMonitorUtils():AdicionaTagMonitor(oDados["tags"],@nIndTag,"po-icon-filter",STR0001) //"Não Iniciadas"
            Case "'1'" $ cParamDet
                PCPMonitorUtils():AdicionaTagMonitor(oDados["tags"],@nIndTag,"po-icon-filter",STR0002) //"Sem Laudo"
            Case "'7'" $ cParamDet
                PCPMonitorUtils():AdicionaTagMonitor(oDados["tags"],@nIndTag,"po-icon-filter",STR0003) //"Laudo Parcial"
        EndCase
    EndIf

    While (cAlias)->(!Eof())
        aAdd(oDados["items"], JsonObject():New())
        nPos++
        
        For nCampo := 1 to nCampos
            cCampo                          := aCampos[nCampo]
            oDados["items"][nPos][cCampo]   := (cAlias)->&(cCampo)
        Next nCampo

        oDados["items"][nPos]["QPK_EMISSA"] := PCPMonitorUtils():FormataData((cAlias)->QPK_EMISSA,4)
        oDados["items"][nPos]["QPK_DTPROD"] := PCPMonitorUtils():FormataData((cAlias)->QPK_DTPROD,4)

        (cAlias)->(dbSkip())
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
@param 01 - lExpResult, logico, Indica se trata todas as colunas como visible
@return aColunas  , array   , Array de objetos com as colunas da table po-ui
/*/
Method AdicionaColunasDetalhes(lExpResult) Class InspecoesDeProcessoPendentes
    Local aCampos    :={"QPK_OP", "QPK_PRODUT", "B1_DESC", "QPK_REVI", "QPK_LOCAL", "QPK_UM", "QPK_TAMLOT", "QPK_LOTE", "QPK_NUMSER", "QPK_DTPROD", "QPK_EMISSA", "QPK_CLIENT", "QPK_LOJA", "A1_NREDUZ"}
    Local aColunas   := {}
    Local aLabels    := {}
    Local cTipo      := ""
    Local lVisivel   := .T.
    Local nCampo     := 0
    Local nCampos    := Len(aCampos)
    Local nIndice    := 0
    Local nIndLabels := 0

    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"QPK_SITOP","Status","cellTemplate",.T.,.T.,aLabels)
    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabels,@nIndLabels," ",COR_CINZA_LEG     ,STR0001,COR_BRANCO)//"Não Iniciadas"
    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabels,@nIndLabels,"1",COR_AZUL_LEG      ,STR0002,COR_BRANCO)//"Sem Laudo"
    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabels,@nIndLabels,"7",COR_AZUL_CLARO_LEG,STR0003,COR_BRANCO)//"Laudo Parcial"

    For nCampo := 1 to nCampos
        cCampo := aCampos[nCampo]
        If X3Uso(GetSx3Cache(cCampo,"X3_USADO"),25)
            cTipo  := GetSx3Cache(cCampo,"X3_TIPO")
             Do Case
                Case cTipo == "C"
                    cTipo := "string"
                Case cTipo == "D"
                    cTipo := "date"
                Case cTipo == "N"
                    cTipo := "number"
            EndCase

            lVisivel := GetSx3Cache(cCampo,"X3_BROWSE") != "N"
            PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,cCampo,GetSx3Cache(cCampo,"X3_TITULO"),cTipo,lVisivel.OR.lExpResult)

        EndIf
    Next nCampo

Return aColunas

/*/{Protheus.doc} CargaMonitor
Realiza a carga do Monitor padrão na base de dados
@type METHOD
@author brunno.costa
@since 10/10/2023
@version P12.1.2310
@return lRet, logico, Indica se conseguiu realizar a carga
/*/
Method CargaMonitor() Class InspecoesDeProcessoPendentes

    Local lRet        := .T.
    Local oCarga      := PCPMonitorCarga():New()
    Local oExemplo    := Nil
    Local oParametros := Nil
    Local oDadosEx    := Nil
 
    If !oCarga:monitorAtualizado("InspecoesDeProcessoPendentes")

        oDadosEx      := JsonObject():New()
        oExemplo      := JsonObject():New()
        oParametros   := JsonObject():New()

        oDadosEx["N"] := "100"
        oDadosEx["S"] := "50"
        oDadosEx["P"] := "10"
        oExemplo      := InspecoesDeProcessoPendentes():MontaRetornoJson(oDadosEx,xFilial("QPK"),"LABFIS",Ctod("01/01/2023"),Ctod("30/01/2023"))

        oParametros["03_FILTRODATA"]            := JsonObject():New()
        oParametros["03_FILTRODATA"]["opcoes"]  := STR0004+":QPK_EMISSA;"+STR0005+":QPK_DTPROD;" //"Data Emissão:QPK_EMISSA;Data Produção:QPK_DTPROD"
        oParametros["04_TIPOPERIODO"]           := JsonObject():New()
        oParametros["04_TIPOPERIODO"]["opcoes"] := STR0006+":D;"+STR0007+":S;"+STR0008+":M;"+STR0009+":T"//"Dia Atual:D;Últimos 7 dias:S;Últimos 30 dias:M;Últimos 90 dias:T"

        oCarga:setaTitulo(STR0010)    //"Inspeções Processo Pendentes"
        oCarga:setaObjetivo(STR0011)  //"O objetivo deste monitor é apresentar para acompanhamento o número de Inspeções de Processo Pendentes nos status Não Iniciadas, Sem Laudos e Laudos Parciais, dentro de um período de emissões."
        oCarga:setaAgrupador(STR0012) //"Qualidade"
        oCarga:setaFuncaoNegocio("InspecoesDeProcessoPendentes")
        oCarga:setaTiposPermitidos("info")
        oCarga:setaTiposGraficoPermitidos("")
        oCarga:setaTipoPadrao("info")
        oCarga:setaTipoGraficoPadrao("")
        oCarga:setaTipoDetalhe("detalhe")
        oCarga:setaExemploJsonTexto(.F.,oExemplo)
        InspecoesDeProcessoPendentes():SetaPropriedadeFilial(oCarga, "01_QPK_FILIAL", "Filial" + "*")                                               //"Filial"
        oCarga:setaPropriedadeLookupTabelaGenerica("02_QPL_LABOR",STR0013,.F.,"Q2")                                                                //"Laboratório"
        oCarga:setaPropriedade("03_FILTRODATA" ,""   ,STR0014 + "*",4,,,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,oParametros["03_FILTRODATA" ]) //"Data de referência"
        oCarga:setaPropriedade("04_TIPOPERIODO","",STR0015 + "*",4,,,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,oParametros["04_TIPOPERIODO"]) //"Período"
        
        lRet := Iif(oCarga:gravaMonitorPropriedades(), lRet, .F.)
        oCarga:Destroy()

        FreeObj(oDadosEx)
        FreeObj(oExemplo)
        FreeObj(oParametros)
        FwFreeObj(oCarga)
    EndIf
Return lRet

/*/{Protheus.doc} RetornaDadosDoBanco
Busca dados para exibicao do monitor no banco de dados
@type METHOD
@author brunno.costa
@since 10/10/2023
@version P12.1.2310
@param 01 - cFilAux , caracter, filial de selecao para referencia
@param 02 - cCodLab , caracter, codigo do laboratorio
@param 03 - cCpoData, caracter, campo de data para consideracao no filtro
@param 04 - dDataIni, data    , data inicial
@param 05 - dDataFim, data    , data final
@return oDadosDB, objeto, Objeto json com os dados do banco para exibicao
/*/
Method RetornaDadosDoBanco(cFilAux, cCodLab, cCpoData, dDataIni, dDataFim) Class InspecoesDeProcessoPendentes

    Local cAlias           := Nil
    Local cQuery           := ""
    Local cSituacao        := ""
    Local oDadosDB         := JsonObject()     :New()
    Local oQLTQueryManager := QLTQueryManager():New()

    oDadosDB["N"] := "0"
    oDadosDB["S"] := "0"
    oDadosDB["P"] := "0"

    cQuery += " SELECT QPK_SITOP, COUNT(*) AS QTD "
    cQuery += " FROM " + RetSqlName("QPK") + " QPK "
    cQuery += InspecoesDeProcessoPendentes():MontaWhereQuery(cFilAux, cCodLab, cCpoData, dDataIni, dDataFim)
    cQuery += " GROUP BY QPK_SITOP "

    cQuery := oQLTQueryManager:ChangeQuery(cQuery)
    cAlias := oQLTQueryManager:ExecuteQuery(cQuery)

    While (cAlias)->(!Eof())
        
        cSituacao := AllTrim((cAlias)->QPK_SITOP)

        Do Case
            Case Empty(cSituacao)
                oDadosDB["N"] := Str((cAlias)->QTD)
            Case cSituacao == "1"
                oDadosDB["S"] := Str((cAlias)->QTD)
            Case cSituacao == "7"
                oDadosDB["P"] := Str((cAlias)->QTD)
        EndCase
        
        (cAlias)->(dbSkip())
    EndDo
    (cAlias)->(dbCloseArea()) 
       
Return oDadosDB

/*/{Protheus.doc} MontaWhereQuery
Monta dados WHERE para selecao dos dados da QPK para contagem
@type METHOD
@author brunno.costa
@since 10/10/2023
@version P12.1.2310
@param 01 - cFilAux , caracter, filial de selecao para referencia
@param 02 - cCodLab , caracter, codigo do laboratorio
@param 03 - cCpoData, caracter, campo de data para consideracao no filtro
@param 04 - dDataIni, data    , data inicial
@param 05 - dDataFim, data    , data final
@return cWhere, objeto json, Objeto json com os dados do último apontamento de produção do recurso
/*/
Method MontaWhereQuery(cFilAux, cCodLab, cCpoData, dDataIni, dDataFim) Class InspecoesDeProcessoPendentes
    
    Local cWhere := ""
    
    If !Empty(cCodLab) //Alica Filtro de Laboratórios
        cWhere += " INNER JOIN "
        cWhere += " (SELECT DISTINCT QP8_PRODUT AS PRODUTO, QP8_REVI AS REVISAO "
        cWhere += " FROM " + RetSQLName("QP8") + " "
        cWhere += " WHERE D_E_L_E_T_ = ' ' "
        cWhere += " AND (QP8_FILIAL = '" + xFilial("QP8", cFilAux) + "') "
        cWhere += " AND (QP8_LABOR = '" + cCodLab + "') "
        cWhere += " UNION "
        cWhere += " SELECT DISTINCT QP7_PRODUT AS PRODUTO, QP7_REVI AS REVISAO "
        cWhere += " FROM " + RetSQLName("QP7") + " "
        cWhere += " WHERE D_E_L_E_T_ = ' ' "
        cWhere += " AND (QP7_FILIAL = '" + xFilial("QP7", cFilAux) + "') "
        cWhere += " AND (QP7_LABOR = '" + cCodLab + "') "
        cWhere += " ) FILTROLAB ON QPK.QPK_PRODUT = FILTROLAB.PRODUTO "
        cWhere +=            " AND QPK.QPK_REVI   = FILTROLAB.REVISAO "
    EndIf

    cWhere += " WHERE (QPK.D_E_L_E_T_ = ' ') "
    cWhere +=   " AND (QPK.QPK_SITOP IN (' ', '1', '7')) "
    cWhere +=         " AND QPK.QPK_FILIAL = '" + xFilial("QPK", cFilAux) + "' "
    cWhere +=         " AND QPK." + cCpoData + " BETWEEN '" + DtoS(dDataIni) + "' AND '" + DtoS(dDataFim) + "' "

Return cWhere

/*/{Protheus.doc} RetornaPeriodoInicial
Retorna Período Inicial
@type METHOD
@author brunno.costa
@since 10/10/2023
@version P12.1.2310
@param 01 - cFiltro , caracter, tipo do filtro: D-Dia Atual;S-Ultimos 7 dias; M-Ultimos 30 dias; T-Ultimos 90 dias
@param 02 - dDataFim, data    , data final para filtro
@return dDataIni, data      , data inicial para filtro
/*/
Method RetornaPeriodoInicial(cFiltro, dDataFim) Class InspecoesDeProcessoPendentes
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
@type METHOD
@author brunno.costa
@since 10/10/2023
@version P12.1.2310
@param 01 cCor  , caracter, cor para utilizacao no BOX
@param 02 lCima , logico , indica ser o box superior
@param 03 lBaixo, logico , indica ser o box inferior
@return cJson, caracter, conteudo json com dados CSS para consideracao no BOX de visualizacao dos dados
/*/
Method RetornaBoxStringJson(cCor, lCima, lBaixo) Class InspecoesDeProcessoPendentes

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
@type METHOD
@author brunno.costa
@since 10/10/2023
@version P12.1.2310
@param 01 - cFilAux, caracter, filial do sistema relacionado aos dados
@param 02 - cCodLab, caracter, codigo do laboratorio
@return cDescricao, caracter, descricao do laboratorio
/*/
Method RetornaDescricaoLaboratorio(cFilAux, cCodLab) Class InspecoesDeProcessoPendentes
    Local cFilBkp    := cFilAnt
    Local cDescricao := cCodLab
    Local aContent   := Nil

    If !Empty(cCodLab)
        cFilAnt    := xFilial("SX5", PadR(cFilAux, FWSizeFilial()))
        aContent   := FWGetSX5( "Q2", PadR(cCodLab,GetSx3Cache("QPL_LABOR","X3_TAMANHO")))
        cDescricao := Iif(Len(aContent)>0, Capital(aContent[1][4]), "")
        FwFreeArray(aContent)
    EndIf

    cFilAnt := cFilBkp

Return cDescricao

/*/{Protheus.doc} ValidaPropriedades
Valida os dados informados nas propriedades do Monitor
@type METHOD
@author brunno.costa
@since 10/10/2023
@version P12.1.2310
@param  oFiltros, objeto json, Objeto json com os filtros para a consulta dos dados
@return aRetorno, array      , [1] logico - indica se os dados são válidos [2] caracter - mensagem de erro
/*/
Method ValidaPropriedades(oFiltros) Class InspecoesDeProcessoPendentes
    Local aRetorno := {.T.,""}

    PCPMonitorUtils():ValidaPropriedadeFilial(oFiltros["01_QPK_FILIAL"], @aRetorno)

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
@author brunno.costa
@since 17/10/2023
@version P12.1.2310
@param 01 - oCarga , objeto  , instancia do objeto json de carga
@param 02 - cCodigo, caracter, codigo da propriedade
@param 03 - cTitulo, caracter, título da propriedade para exibicao no front-end
@return Nil
/*/
Method SetaPropriedadeFilial(oCarga, cCodigo, cTitulo) Class InspecoesDeProcessoPendentes
    Local oPrmAdc := JsonObject():New()
    
    oPrmAdc["filtroServico"]                := "/api/pcp/v1/pcpmonitorapi/consulta"
    oPrmAdc["parametrosServico"]            := JsonObject():New()
    oPrmAdc["parametrosServico"]["metodo"]  := "PCPMonitorConsultas():BuscaFiliais"
    oPrmAdc["labelSelect"]                  := "Description"
    oPrmAdc["valorSelect"]                  := "Code"

    oCarga:setaPropriedade(cCodigo,"",cTitulo,7,GetSx3Cache("HZD_FILIAL","X3_TAMANHO"),0,"po-sm-12 po-md-6 po-lg-6 po-xl-6",/*oEstilos*/,/*cIcone*/,oPrmAdc)

    FreeObj(oPrmAdc)
Return
