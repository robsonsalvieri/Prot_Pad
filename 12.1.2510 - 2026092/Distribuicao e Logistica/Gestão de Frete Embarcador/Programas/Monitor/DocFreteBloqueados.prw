#INCLUDE "TOTVS.CH"
#INCLUDE "PCPMONITOR.CH"
#INCLUDE "GFEMONITORDEF.CH"


/*/{Protheus.doc} DocFreteBloqueados
Classe para prover os dados do Monitor de Status dos Documentos de Frete Bloqueados
@type Class
@author Jefferson Hita
@since 28/07/2023
@version P12.1.2410
@return Nil
/*/
Class DocFreteBloqueados FROM LongNameClass
	Static Method BuscaDados(oFiltros, cTipo, cSubTipo)
	Static Method BuscaDetalhes(oFiltro,nPagina)
	Static Method CargaMonitor()
    Static Method ValidaPropriedades(oFiltros)
EndClass


/*/{Protheus.doc} CargaMonitor
Realiza a carga do Monitor padrão na base de dados
@type Method
@author Jefferson Hita
@since 28/07/2023
@version P12.1.2410
@return lRet, logico, Indica se conseguiu realizar a carga
/*/
Method CargaMonitor() Class DocFreteBloqueados
    Local lRet      := .T.
    Local oCarga    := PCPMonitorCarga():New()
    Local oExemplo  := JsonObject():New()
    Local oStyle    := JsonObject():New()
    Local oStyleQtd := JsonObject():New()
    Local oPrmAdc   := JsonObject():New()

    If !PCPMonitorCarga():monitorAtualizado("DocFreteBloqueados")
        oExemplo["corFundo"]  := COR_VERMELHO_FORTE
        oExemplo["corTitulo"] := "white"
        oExemplo["tags"]      := {}
        oExemplo["linhas"]    := {}
        oStyle["color"] := "white"

        aAdd(oExemplo["tags"],JsonObject():New())
        oExemplo["tags"][1]["icone"]      := "po-icon-bar-code"
        oExemplo["tags"][1]["colorTexto"] := ""
        oExemplo["tags"][1]["texto"]      := "D MG 01 - D MG 02"

        aAdd(oExemplo["tags"],JsonObject():New())
        oExemplo["tags"][2]["icone"]      := "po-icon-calendar"
        oExemplo["tags"][2]["colorTexto"] := ""
        oExemplo["tags"][2]["texto"]      := "01/01/23 - 31/01/23"

        aAdd(oExemplo["linhas"],JsonObject():New())
        oStyleQtd["font-weight"] := "bold"
        oStyleQtd["font-size"]   := "120px"
        oStyleQtd["line-height"] := "130px"
        oStyleQtd["text-align"]  := "center"
        oStyleQtd["color"]       := oStyle["color"]

        aAdd(oExemplo["linhas"],JsonObject():New())
        oExemplo["linhas"][1]["texto"]           := "15"
        oExemplo["linhas"][1]["tipo"]            := "texto"
        oExemplo["linhas"][1]["classeTexto"]     := "po-sm-12"
        oExemplo["linhas"][1]["styleTexto"]      := oStyleQtd:ToJson()
        oExemplo["linhas"][1]["tituloProgresso"] := ""
        oExemplo["linhas"][1]["valorProgresso"]  := ""
        oExemplo["linhas"][1]["icone"]           := ""

        oExemplo["linhas"][2]["texto"]           := "Documento(s)"
        oExemplo["linhas"][2]["tipo"]            := "texto"
        oExemplo["linhas"][2]["classeTexto"]     := "po-font-title po-text-center po-sm-12 po-pt-1 bold-text"
        oExemplo["linhas"][2]["styleTexto"]      := oStyle:ToJson()
        oExemplo["linhas"][2]["tituloProgresso"] := ""
        oExemplo["linhas"][2]["valorProgresso"]  := ""
        oExemplo["linhas"][2]["icone"]           := ""

        oCarga:setaTitulo("Documentos Frete Bloqueados") //oCarga:setaTitulo(STR0110) //"Lotes a vencer"
        oCarga:setaObjetivo("Apresentar o número de documentos de frete bloqueados, dentro de um período configurado.") // oCarga:setaObjetivo(STR0111) //"Apresentar o número de lotes e a quantidade a vencer de um determinado produto, dentro de um período futuro configurado, utilizando o conceito de semáforo para indicar o nível de atenção ou urgência."
        oCarga:setaAgrupador("GFE")
        oCarga:setaFuncaoNegocio("DocFreteBloqueados")
        oCarga:setaTiposPermitidos("chart;info")
        oCarga:setaTiposGraficoPermitidos("gauge")
        oCarga:setaTipoPadrao("info")
        oCarga:setaTipoGraficoPadrao("")
        oCarga:setaTipoDetalhe("detalhe")
        oCarga:setaExemploJsonTexto(.F.,oExemplo)

        oPrmAdc["01_GW3_FILIAL"]                                 := JsonObject():New()
        oPrmAdc["01_GW3_FILIAL"]["filtroServico"]                := "/api/pcp/v1/pcpmonitorapi/consulta"
        oPrmAdc["01_GW3_FILIAL"]["parametrosServico"]            := JsonObject():New()
        oPrmAdc["01_GW3_FILIAL"]["parametrosServico"]["metodo"]  := "PCPMonitorConsultas():BuscaFiliais"
        oPrmAdc["01_GW3_FILIAL"]["labelSelect"]                  := "Description"
        oPrmAdc["01_GW3_FILIAL"]["valorSelect"]                  := "Code"

        oPrmAdc["02_GW3_FILIAL"]                                 := JsonObject():New()
        oPrmAdc["02_GW3_FILIAL"]["filtroServico"]                := "/api/pcp/v1/pcpmonitorapi/consulta"
        oPrmAdc["02_GW3_FILIAL"]["parametrosServico"]            := JsonObject():New()
        oPrmAdc["02_GW3_FILIAL"]["parametrosServico"]["metodo"]  := "PCPMonitorConsultas():BuscaFiliais"
        oPrmAdc["02_GW3_FILIAL"]["labelSelect"]                  := "Description"
        oPrmAdc["02_GW3_FILIAL"]["valorSelect"]                  := "Code"

        oPrmAdc["03_GW3_TIPOPERIODO"]           := JsonObject():New()
        oPrmAdc["03_GW3_TIPOPERIODO"]["opcoes"] := STR0184 + ":D;" + STR0185 + ":S; " + STR0186 + ":Q; " + STR0187 + ":M; " + STR0188 + ":X" //"Dia Atual:D; Semana Atual:S; Quinzena Atual:Q; Mês Atual:M; Personalizado:X"

        oPrmAdc["06_GW3_TIPOSEMAFORO"]                           := JsonObject():New()
        oPrmAdc["06_GW3_TIPOSEMAFORO"]["opcoes"]                 := "Quantidade"+":Q" //"Número de Lotes //Quantidade do Produto

        oCarga:setaPropriedade("01_GW3_FILIAL","", "Filial De:",7,GetSx3Cache("GW3_FILIAL","X3_TAMANHO"),0,"po-lg-6 po-xl-6 po-md-6 po-sm-12 po-pr-6",/*oEstilos*/,/*cIcone*/,oPrmAdc["01_GW3_FILIAL"])
        oCarga:setaPropriedade("02_GW3_FILIAL","", "Filial Até:",7,GetSx3Cache("GW3_FILIAL","X3_TAMANHO"),0,"po-lg-6 po-xl-6 po-md-6 po-sm-12 po-pr-6",/*oEstilos*/,/*cIcone*/,oPrmAdc["02_GW3_FILIAL"])
        oCarga:setaPropriedade("03_GW3_TIPOPERIODO","D", STR0062,4,,,"po-lg-6 po-xl-6 po-md-6 po-sm-12",/*oEstilos*/,/*cIcone*/,oPrmAdc["03_GW3_TIPOPERIODO"]) //"Período"
        oCarga:setaPropriedade("04_GW3_PERIODO","9999", STR0063,2,4,0,"po-lg-6 po-xl-6 po-md-6 po-sm-12") //"Período personalizado (dias)"
        oCarga:setaPropriedade("05_GW3_SEMAFORO", "Atenção;Urgente", "Semáforo (Quantidade)",1,30,0,"po-lg-8 po-xl-8 po-md-8 po-sm-12",/*oEstilos*/,/*cIcone*/,/*oPrmAdc*/)

        If !oCarga:gravaMonitorPropriedades()
            lRet := .F.
        EndIf
        oCarga:Destroy()
    EndIf
    FreeObj(oExemplo)
    FreeObj(oStyle)
    FreeObj(oPrmAdc)
    FreeObj(oStyleQtd)
Return lRet

/*/{Protheus.doc} BuscaDados
Responsável por realizar a busca dos dados que serão exibidos no monitor (gráfico ou texto)

@type Class
@author Jefferson Hita
@since 28/07/2023
@version P12.1.2410
@param	oFiltros  , objeto Json, Contém as propriedades do monitor usadas para filtrar a query de busca
@param	cTipo     , caracter   , Tipo chart/info
@param	cSubTipo  , caracter   , Tipo de grafico pie/bar/column
@return cJsonDados, caracter   , Retorna um novo Json em formato texto, pronto para conversão e exibição no front
/*/
Method BuscaDados(oFiltros, cTipo, cSubTipo) Class DocFreteBloqueados
    Local cAliasQry  := GetNextAlias()
    Local cJsonDados := ""
    Local cQuery     := ""
    Local dDataFin   := dDatabase
    Local dDataIni   := PCPMonitorUtils():RetornaPeriodoInicial(AllTrim(oFiltros["03_GW3_TIPOPERIODO"]),dDataFin,cValToChar(oFiltros["04_GW3_PERIODO"]))
    Local nQtdBlq    := 0
    Local nPos       := 0
    Local oJsonRet   := JsonObject():New()
    Local aSemaforo  := StrTokArr(Replace(oFiltros["05_GW3_SEMAFORO"],",","."),";")

    oFiltros["01_GW3_FILIAL"] := PadR(oFiltros["01_GW3_FILIAL"], FWSizeFilial())
    oFiltros["02_GW3_FILIAL"] := PadR(oFiltros["02_GW3_FILIAL"], FWSizeFilial())

    cQuery += " SELECT COUNT(GW3.R_E_C_N_O_) QUANTIDADE_BLQ"
    cQuery += " FROM " + RetSqlName("GW3")+" GW3 "
    cQuery += " WHERE GW3.GW3_FILIAL BETWEEN '" + xFilial("GW3", oFiltros["01_GW3_FILIAL"]) + "' AND '" + xFilial("GW3", oFiltros["02_GW3_FILIAL"]) + "'"
    cQuery += " AND GW3.GW3_SIT IN ('2','5')"
    cQuery += " AND GW3.GW3_DTEMIS BETWEEN '" + DTOS(dDataIni) + "' AND '" + DTOS(dDataFin) + "'"
    cQuery += " AND GW3.D_E_L_E_T_  = ' ' "

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)
    If (cAliasQry)->(!Eof())
        nQtdBlq := (cAliasQry)->QUANTIDADE_BLQ
    End
    (cAliasQry)->(dbCloseArea())

    If cTipo == "info"
        montaInfo(oJsonRet, nQtdBlq)
    Else
        montaGraf(oJsonRet, nQtdBlq, aSemaforo, oFiltros["06_GW3_TIPOSEMAFORO"])
    EndIf

    oJsonRet["tags"]     := {}
    aAdd(oJsonRet["tags"], JsonObject():New())
    nPos++
    oJsonRet["tags"][nPos]["texto"]      := " " + cValToChar(dDataIni) + " - " + cValToChar(dDataFin) + " "
    oJsonRet["tags"][nPos]["colorTexto"] := ""
    oJsonRet["tags"][nPos]["icone"]      := "po-icon-calendar"

    If cTipo == "chart"
        aAdd(oJsonRet["tags"], JsonObject():New())
        nPos++
        oJsonRet["tags"][nPos]["texto"]      := cValToChar(nQtdBlq) + IIF(nQtdBlq > 1, " Bloqueados", " Bloqueado")
        oJsonRet["tags"][nPos]["colorTexto"] := ""
        oJsonRet["tags"][nPos]["icone"]      := "po-icon-star-filled"
    EndIf
    cJsonDados :=  oJsonRet:toJson()

    FreeObj(oJsonRet)
Return cJsonDados

/*/{Protheus.doc} ValidaPropriedades
Valida os dados informados nas propriedades do Monitor
@type Method
@author Jefferson Hita
@since 31/07/2023
@version P12.1.2410
@param  oFiltros, objeto json, Objeto json com os filtros para a consulta dos dados
@return aRetorno, array      , [1] logico - indica se os dados são válidos [2] caracter - mensagem de erro
/*/
Method ValidaPropriedades(oFiltros) Class DocFreteBloqueados
    Local aFiliais  := FWLoadSM0(.T.,.T.)
    Local aRetorno  := {.T.,""}

    If Empty(oFiltros["01_GW3_FILIAL"]) .Or. Empty(oFiltros["02_GW3_FILIAL"])
        aRetorno[1] := .F.
        aRetorno[2] := STR0064 //"O filtro de Filial deve ser preenchido."
    EndIf

    If aRetorno[1] .And. oFiltros["03_GW3_TIPOPERIODO"] == "X"
        If !oFiltros:HasProperty("04_GW3_PERIODO") .Or. oFiltros["04_GW3_PERIODO"] == Nil .Or. Empty(oFiltros["04_GW3_PERIODO"])
            aRetorno[1] := .F.
            aRetorno[2] := STR0069 //"Deve ser informada a quantidade de dias para o período personalizado."
        EndIf
    EndIf

    FwFreeArray(aFiliais)
Return aRetorno

/*/{Protheus.doc} BuscaDetalhes
Realiza a busca dos dados para montar os detalhes do Monitor
@type Method
@author Jefferson Hita
@since 31/07/2023
@version P12.1.2410
@return Nil
/*/
Method BuscaDetalhes(oFiltro,nPagina) Class DocFreteBloqueados
    Local cAlias     := GetNextAlias()
    Local cQuery     := ""
    Local dDataFim   := dDatabase
    Local dDataIni   := PCPMonitorUtils():RetornaPeriodoInicial(AllTrim(oFiltro["03_GW3_TIPOPERIODO"]),dDataFim,cValToChar(oFiltro["04_GW3_PERIODO"]))
    Local lExpResult := .T.
    Local nI         := 0
    Local nPos       := 0
    Local oDados     := JsonObject():New()
    Private aFields  := {{"Filial"	    , "GW3_FILIAL", "C", TamSX3("GW3_FILIAL")[1], 0, "", 1, TamSX3("GW3_FILIAL")[1]},;
                         {"Espécie"     , "GW3_CDESP" , "C", TamSX3("GW3_CDESP")[1]	, 0, "", 1, TamSX3("GW3_CDESP")[1]},;
                         {"Emissor"     , "GW3_EMISDF", "C", TamSX3("GW3_EMISDF")[1], 0, "", 1, TamSX3("GW3_EMISDF")[1]},;
                         {"Nome Emissor", "GU3_NMEMIT", "C", TamSX3("GU3_NMEMIT")[1], 0, "", 1, TamSX3("GU3_NMEMIT")[1]},;
                         {"Série"      	, "GW3_SERDF" , "C", TamSX3("GW3_SERDF")[1]	, 0, "", 1, TamSX3("GW3_SERDF")[1]},;
                         {"Nr Documento", "GW3_NRDF"  , "C", TamSX3("GW3_NRDF")[1]  , 0, "", 1, TamSX3("GW3_NRDF")[1]},;
                         {"Dt Emissão"  , "GW3_DTEMIS", "D", TamSX3("GW3_DTEMIS")[1], 0, "", 1, TamSX3("GW3_DTEMIS")[1]},;
                         {"Remetente"	, "GW3_CDREM" , "C", TamSX3("GW3_CDREM")[1] , 0, "", 1, TamSX3("GW3_CDREM")[1]},;
                         {"Destinatário", "GW3_CDDEST", "C", TamSX3("GW3_CDDEST")[1], 0, "", 1, TamSX3("GW3_CDDEST")[1]},;
                         {"Valor Docto" , "GW3_VLDF"  , "N", TamSX3("GW3_VLDF")[1]  , 0, "", 1, TamSX3("GW3_VLDF")[1]}}

    Default nPagina := 1

    oFiltro["01_GW3_FILIAL"] := PadR(oFiltro["01_GW3_FILIAL"], FWSizeFilial())
    oFiltro["02_GW3_FILIAL"] := PadR(oFiltro["02_GW3_FILIAL"], FWSizeFilial())

    oDados["items"]                 := {}
    oDados["columns"]               := montaColun(lExpResult)
    oDados["canExportCSV"]          := .T.
    oDados["tags"]                  := {}
    aAdd(oDados["tags"],JsonObject():New())
    oDados["tags"][1]["icone"]      := "po-icon-calendar"
    oDados["tags"][1]["colorTexto"] := ""
    oDados["tags"][1]["texto"]      := dToC(dDataIni) + " - " + dToC(dDataFim)
    aAdd(oDados["tags"],JsonObject():New())
    oDados["tags"][2]["icone"]      := "po-icon-bar-code"
    oDados["tags"][2]["colorTexto"] := ""
    oDados["tags"][2]["texto"]      := "Bloqueados"

    cQuery += " SELECT *"
    cQuery += " FROM " + RetSqlName("GW3") + " GW3"
    cQuery += " INNER JOIN " + RetSqlName("GU3") + " GU3 ON GU3.GU3_FILIAL = '" + xFilial("GU3") + "' AND GU3.GU3_CDEMIT = GW3.GW3_EMISDF AND GU3.D_E_L_E_T_=' '"
    cQuery += " WHERE GW3.GW3_FILIAL BETWEEN '" + xFilial("GW3", oFiltro["01_GW3_FILIAL"]) + "' AND '" + xFilial("GW3", oFiltro["02_GW3_FILIAL"]) + "'"
    cQuery += " AND GW3.GW3_SIT IN ('2','5')"
    cQuery += " AND GW3.GW3_DTEMIS BETWEEN '" + DTOS(dDataIni) + "' AND '" + DTOS(dDataFim) + "'"
    cQuery += " AND GW3.D_E_L_E_T_ = ' '"
    cQuery += " ORDER BY GW3_FILIAL, GW3_CDESP, GW3_EMISDF, GW3_SERDF, GW3_NRDF"
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)

    While (cAlias)->(!Eof())
        aAdd(oDados["items"], JsonObject():New())
        nPos++
        For nI := 1 To Len(aFields)
            If Alltrim(aFields[nI][3]) == "D"
                oDados["items"][nPos][aFields[nI][2]] := &( "DTOC(STOD((cAlias)->" + Alltrim(aFields[nI][2])+"))" )
            Else
                oDados["items"][nPos][aFields[nI][2]] := &("(cAlias)->" + Alltrim(aFields[nI][2]))
            EndIf
        Next nI

        (cAlias)->(dbSkip())
    EndDo
    oDados["hasNext"] := (cAlias)->(!Eof())
    (cAlias)->(dbCloseArea())
Return oDados:ToJson()

/*/{Protheus.doc} montaColun
Realiza a criação de objeto Json que define as colunas utilizadas na grid de detalhamento do monitor
@type Static Function
@author Jefferson Hita
@since 31/07/2023
@version P12.1.2410
@return aColumns, array objetos, Contém as definições das colunas da grid do monitor
/*/
Static Function montaColun(lExpResult)
    Local aColumns := {}
    Local nI       := 0
    Local nPos     := 0

    For nI := 1 To Len(aFields)
        aAdd(aColumns, JsonObject():New())
        nPos++
        aColumns[nPos]["label"]    := aFields[nI][1]
        aColumns[nPos]["property"] := aFields[nI][2]
        aColumns[nPos]["type"]     := "string"
        aColumns[nPos]["visible"]  := lExpResult
    Next nI

Return aColumns

/*/{Protheus.doc} montaGraf
Monta objeto json com os dados para mostrar o gauge
@type Static Function
@author Jefferson Hita
@since 31/07/2023
@version P12.1.2410
@param  oJsonRet  , objeto json, Objeto json que receberá os dados do gauge
@param  nQtdBlq   , numerico   , Número de documentos bloqueados retornado da consulta
@param  aSemaforo , array      , Array com os números do semáforo
@param  cTipoSemaf, caracter   , L - Quantidade Lotes / Q - Saldo Lotes
@return Nil
/*/
Static Function montaGraf(oJsonRet,nQtdBlq,aSemaforo,cTipoSemaf)
    Local cLabel     := ""
    Local cValorFim  := ""
    Local cValSemaf1 := aSemaforo[1]
    Local cValSemaf2 := aSemaforo[2]
    Local nQuant     := 0
    Local nValorFim  := 0
    Local nValSemaf1 := Val(cValSemaf1)
    Local nValSemaf2 := Val(cValSemaf2)

    nQuant  := nQtdBlq
    cLabel  := "Documento(s)"

    If nQuant > nValSemaf2
        nValorFim := nQuant + (nValSemaf2 - nValSemaf1)
    Else
        nValorFim := nValSemaf2 + (nValSemaf2 - nValSemaf1)
    EndIf
    cValorFim := cValToChar(nValorFim)

    oJsonRet["alturaMinimaWidget"] := "350px"
    oJsonRet["alturaMaximaWidget"] := "500px"
    oJsonRet["categorias"] := {}
    oJsonRet["series"]     := {}
    oJsonRet["detalhes"]   := {}
    oJsonRet["gauge"]               := JsonObject():New()
    oJsonRet["gauge"]["type"]       := "arch"
    oJsonRet["gauge"]["value"]      := nQuant
    oJsonRet["gauge"]["max"]        := nValorFim
    oJsonRet["gauge"]["label"]      := cLabel
    oJsonRet["gauge"]["append"]     := ""
    oJsonRet["gauge"]["thick"]      := 20
    oJsonRet["gauge"]["margin"]     := 15
    oJsonRet["gauge"]["valueStyle"] := JsonObject():New()
    oJsonRet["gauge"]["valueStyle"]["color"]       := retCorSmf(nQuant,nValSemaf1,nValSemaf2)
    oJsonRet["gauge"]["valueStyle"]["font-weight"] := "bold"
    oJsonRet["gauge"]["labelStyle"] := JsonObject():New()
    oJsonRet["gauge"]["labelStyle"]["font-weight"] := "bold"
    oJsonRet["gauge"]["thresholds"]                          := JsonObject():New()
    oJsonRet["gauge"]["thresholds"]["0"]                     := JsonObject():New()
    oJsonRet["gauge"]["thresholds"]["0"]["color"]            := COR_VERDE_FORTE
    oJsonRet["gauge"]["thresholds"]["0"]["bgOpacity"]        := 0.2
    oJsonRet["gauge"]["thresholds"][cValSemaf1]              := JsonObject():New()
    oJsonRet["gauge"]["thresholds"][cValSemaf1]["color"]     := COR_AMARELO_QUEIMADO
    oJsonRet["gauge"]["thresholds"][cValSemaf1]["bgOpacity"] := 0.2
    oJsonRet["gauge"]["thresholds"][cValSemaf2]              := JsonObject():New()
    oJsonRet["gauge"]["thresholds"][cValSemaf2]["color"]     := COR_VERMELHO_FORTE
    oJsonRet["gauge"]["thresholds"][cValSemaf2]["bgOpacity"] := 0.2
    oJsonRet["gauge"]["markers"] := JsonObject():New()
    If Val(cValSemaf1) > 0
        oJsonRet["gauge"]["markers"]["0"]          :=  JsonObject():New()
        oJsonRet["gauge"]["markers"]["0"]["color"] := COR_PRETO
        oJsonRet["gauge"]["markers"]["0"]["size"]  := 6
        oJsonRet["gauge"]["markers"]["0"]["label"] := "0"
        oJsonRet["gauge"]["markers"]["0"]["type"]  := "line"
    EndIf
    oJsonRet["gauge"]["markers"][cValSemaf1] :=  JsonObject():New()
    oJsonRet["gauge"]["markers"][cValSemaf1]["color"]   := COR_PRETO
    oJsonRet["gauge"]["markers"][cValSemaf1]["size"]    := 6
    oJsonRet["gauge"]["markers"][cValSemaf1]["label"]   := cValSemaf1
    oJsonRet["gauge"]["markers"][cValSemaf1]["type"]    := "line"
    oJsonRet["gauge"]["markers"][cValSemaf2] :=  JsonObject():New()
    oJsonRet["gauge"]["markers"][cValSemaf2]["color"]   := COR_PRETO
    oJsonRet["gauge"]["markers"][cValSemaf2]["size"]    := 6
    oJsonRet["gauge"]["markers"][cValSemaf2]["label"]   := cValSemaf2
    oJsonRet["gauge"]["markers"][cValSemaf2]["type"]    := "line"
    oJsonRet["gauge"]["markers"][cValorFim]    :=  JsonObject():New()
    oJsonRet["gauge"]["markers"][cValorFim]["color"]    := COR_PRETO
    oJsonRet["gauge"]["markers"][cValorFim]["size"]     := 6
    oJsonRet["gauge"]["markers"][cValorFim]["label"]    := cValorFim
    oJsonRet["gauge"]["markers"][cValorFim]["type"]     := "line"
Return

/*/{Protheus.doc} montaInfo
Monta objeto json com os dados para mostrar o gráfico de informações
@type Static Function
@author Jefferson Hita
@since 31/07/2023
@version P12.1.2410
@param  oJsonRet  , objeto json, Objeto json que receberá os dados do gauge
@param  nQtdBlq   , numerico   , Número de documentos bloqueados retornado da consulta
@return Nil
/*/
Static Function montaInfo(oJsonRet, nQtdBlq)
    Local cTxtPrc    := cValToChar(nQtdBlq)
    Local cTxtSec    := "Bloqueado(s)"
    Local oStyle     := JsonObject():New()
    Local oStyleQtd  := JsonObject():New()

    oStyle["color"] := "white"
    oJsonRet["corTitulo"]          := "white"
    oJsonRet["alturaMinimaWidget"] := "350px"
    oJsonRet["alturaMaximaWidget"] := "500px"
    oJsonRet["linhas"]             := {}

    If nQtdBlq > 0
        oJSonRet["corFundo"] := COR_VERMELHO_FORTE
        If oJSonRet["corFundo"] == COR_VERMELHO_FORTE
            oStyle["color"]       := "black"
            oJsonRet["corTitulo"] := "black"
        EndIf
        aAdd(oJsonRet["linhas"],JsonObject():New())
        oStyleQtd["font-weight"] := "bold"
        oStyleQtd["font-size"]   := "120px"
        oStyleQtd["line-height"] := "130px"
        oStyleQtd["text-align"]  := "center"
        oStyleQtd["color"]       := oStyle["color"]
        oStyleQtd["cursor"]      := "pointer"

        oJsonRet["linhas"][1]["texto"]           := cTxtPrc
        oJsonRet["linhas"][1]["tipo"]            := "texto"
        oJsonRet["linhas"][1]["classeTexto"]     := "po-sm-12"
        oJsonRet["linhas"][1]["styleTexto"]      := oStyleQtd:ToJson()
        oJsonRet["linhas"][1]["tituloProgresso"] := ""
        oJsonRet["linhas"][1]["valorProgresso"]  := ""
        oJsonRet["linhas"][1]["icone"]           := ""
        oJsonRet["linhas"][1]["tipoDetalhe"]     := "detalhe"
        aAdd(oJsonRet["linhas"],JsonObject():New())
        oJsonRet["linhas"][2]["texto"]           := cTxtSec
        oJsonRet["linhas"][2]["tipo"]            := "texto"
        oJsonRet["linhas"][2]["classeTexto"]     := "po-font-title po-text-center po-sm-12 po-pt-1 bold-text"
        oJsonRet["linhas"][2]["styleTexto"]      := oStyle:ToJson()
        oJsonRet["linhas"][2]["tituloProgresso"] := ""
        oJsonRet["linhas"][2]["valorProgresso"]  := ""
        oJsonRet["linhas"][2]["icone"]           := ""
    Else
        oJsonRet["corFundo"] := COR_VERDE_FORTE
        aAdd(oJsonRet["linhas"],JsonObject():New())
        oJsonRet["linhas"][1]["texto"]           := "Nenhum documento de frete bloqueado identificado no período selecionado."
        oJsonRet["linhas"][1]["tipo"]            := "texto"
        oJsonRet["linhas"][1]["classeTexto"]     := "po-font-text-large-bold po-text-center po-sm-12 po-pt-4"
        oJsonRet["linhas"][1]["styleTexto"]      := oStyle:ToJson()
        oJsonRet["linhas"][1]["tituloProgresso"] := ""
        oJsonRet["linhas"][1]["valorProgresso"]  := ""
        oJsonRet["linhas"][1]["icone"]           := ""
        oJsonRet["linhas"][1]["tipoDetalhe"]     := ""
    EndIf
Return

/*/{Protheus.doc} retCorSmf
Retorna a cor do semáforo de acordo com a quantidade parametrizada
@type Static Function
@author douglas.heydt
@since 13/04/2023
@version P12.1.2310
@param  nQuant    , numerico, Quantidade de lotes ou de unidades
@param  nValSemaf1, numerico, Número do semáforo relacionado a atenção
@param  nValSemaf2, numerico, Número do semáforo relacionado ao urgente
@return cCorSemaf , caracter, String com código RGB da cor
/*/
Static Function retCorSmf(nQuant,nValSemaf1,nValSemaf2)
    If nQuant < nValSemaf1
        Return COR_VERDE_FORTE
    ElseIf nQuant < nValSemaf2
        Return COR_AMARELO_ESCURO
    EndIf
Return COR_VERMELHO_FORTE
