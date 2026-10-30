#INCLUDE "TOTVS.CH"
#INCLUDE "GFEMONITOR.CH"
#INCLUDE "GFEMONITORDEF.CH"

/*/{Protheus.doc} MonitorCarregamento
Classe para prover os dados do Monitor de Status dos Documentos de Frete Bloqueados
@type Class
@author Jefferson Hita
@since 15/08/2023
@version P12.1.2410
@return Nil
/*/
Class MonitorCarregamento FROM LongNameClass
	Static Method BuscaDados(oFiltros, cTipo, cSubTipo)
	Static Method BuscaDetalhes(oFiltro,nPagina)
	Static Method CargaMonitor()
    Static Method ValidaPropriedades(oFiltros)
EndClass


/*/{Protheus.doc} CargaMonitor
Realiza a carga do Monitor padrão na base de dados
@type Method
@author Jefferson Hita
@since 15/08/2023
@version P12.1.2410
@return lRet, logico, Indica se conseguiu realizar a carga
/*/
Method CargaMonitor() Class MonitorCarregamento
    Local aTags     := {}
    Local aDetalhes := {}
    Local lRet      := .T.
    Local oCarga    := PCPMonitorCarga():New()
    Local oExemplo  := JsonObject():New()
    Local oPrmAdc   := JsonObject():New()
    Local oStyle    := JsonObject():New()
    Local oStyleQtd := JsonObject():New()
    Local oSeries   := JsonObject():New()

    If !PCPMonitorCarga():monitorAtualizado("MonitorCarregamento")
        // Exemplo Barras verticais
        oSeries["Emitido"]  := {{3,5}, COR_VERMELHO }
        oSeries["Liberado"] := {{4,10}, COR_VERDE }
        aAdd(aTags, JsonObject():New())
        aTags[1]["texto"]      := "D MG 01"
        aTags[1]["colorTexto"] := ""
        aTags[1]["icone"]      := "po-icon-company"
        aAdd(aTags, JsonObject():New())
        aTags[2]["texto"]      := "01/01/2023 - 28/02/2023"
        aTags[2]["colorTexto"] := ""
        aTags[2]["icone"]      := "po-icon-calendar"
        aAdd(aTags, JsonObject():New())
        aTags[3]["texto"]      := "Emitido"
        aTags[3]["colorTexto"] := ""
        aTags[3]["icone"]      := "po-icon-parameters"
        aAdd(aTags, JsonObject():New())
        aTags[4]["texto"]      := "Liberado"
        aTags[4]["colorTexto"] := ""
        aTags[4]["icone"]      := "po-icon-parameters"
        
        // Exemplo Texto Simples
        oStyle["color"] := "white"
        oExemplo["corFundo"]  := COR_VERDE_FORTE
        oExemplo["corTitulo"] := "white"
        oExemplo["tags"]      := {}
        oExemplo["linhas"]    := {}

        aAdd(oExemplo["tags"],JsonObject():New())
        oExemplo["tags"][1]["icone"]      := "po-icon-company"
        oExemplo["tags"][1]["colorTexto"] := ""
        oExemplo["tags"][1]["texto"]      := "D MG 01"
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
        oExemplo["linhas"][1]["texto"]           := "5"
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


        oCarga:setaTitulo("Monitor de Carregamento")
        oCarga:setaObjetivo("Apresentar informações dos documentos relacionados aos carregamentos conforme filtros configurados.")
        oCarga:setaAgrupador("GFE")
        oCarga:setaFuncaoNegocio("MonitorCarregamento")
        oCarga:setaTiposPermitidos("chart;info")
        oCarga:setaTiposGraficoPermitidos("column;bar;info;gauge")
        oCarga:setaTipoPadrao("info")
        oCarga:setaTipoGraficoPadrao("column")
        oCarga:setaTipoDetalhe("detalhe")
        //oCarga:setaExemploJsonTexto(.F.,oExemplo)
        oCarga:setaExemploJsonGrafico(oSeries, aTags, aDetalhes, {"Janeiro","Fevereiro"},"column")

        oPrmAdc["01_GFE_FILIAL"]                                 := JsonObject():New()
        oPrmAdc["01_GFE_FILIAL"]["filtroServico"]                := "/api/pcp/v1/pcpmonitorapi/consulta"
        oPrmAdc["01_GFE_FILIAL"]["parametrosServico"]            := JsonObject():New()
        oPrmAdc["01_GFE_FILIAL"]["parametrosServico"]["metodo"]  := "PCPMonitorConsultas():BuscaFiliais"
        oPrmAdc["01_GFE_FILIAL"]["labelSelect"]                  := "Description"
        oPrmAdc["01_GFE_FILIAL"]["valorSelect"]                  := "Code"
        
        oPrmAdc["02_GFE_FILIAL"]                                 := JsonObject():New()
        oPrmAdc["02_GFE_FILIAL"]["filtroServico"]                := "/api/pcp/v1/pcpmonitorapi/consulta"
        oPrmAdc["02_GFE_FILIAL"]["parametrosServico"]            := JsonObject():New()
        oPrmAdc["02_GFE_FILIAL"]["parametrosServico"]["metodo"]  := "PCPMonitorConsultas():BuscaFiliais"
        oPrmAdc["02_GFE_FILIAL"]["labelSelect"]                  := "Description"
        oPrmAdc["02_GFE_FILIAL"]["valorSelect"]                  := "Code"

        oPrmAdc["03_GFE_SITUACAO"]                               := JsonObject():New()
        oPrmAdc["03_GFE_SITUACAO"]["opcoes"]                     := "Todos" + ":T;" + " Digitado/Emitido" + ":DE; " + " Liberado/Encerrado" + ":LE"

        oPrmAdc["04_GFE_TIPOPERIODO"]                            := JsonObject():New()
        oPrmAdc["04_GFE_TIPOPERIODO"]["opcoes"]                  := "Dia Atual" + ":D;" + " Semana Atual" + ":S; " + " Quinzena Atual" + ":Q; " + " Mês Atual" + ":M; " + " Personalizado" + ":X"

        oPrmAdc["06_GFE_TIPOSEMAFORO"]                           := JsonObject():New()
        oPrmAdc["06_GFE_TIPOSEMAFORO"]["opcoes"]                 := "Quantidade"+":Q"

        oCarga:setaPropriedade("01_GFE_FILIAL","", "Filial De:",7,GetSx3Cache("GWN_FILIAL","X3_TAMANHO"),0,"po-lg-6 po-xl-6 po-md-6 po-sm-12 po-pr-6",/*oEstilos*/,/*cIcone*/,oPrmAdc["01_GFE_FILIAL"])
        oCarga:setaPropriedade("02_GFE_FILIAL","", "Filial Até:",7,GetSx3Cache("GWN_FILIAL","X3_TAMANHO"),0,"po-lg-6 po-xl-6 po-md-6 po-sm-12 po-pr-6",/*oEstilos*/,/*cIcone*/,oPrmAdc["02_GFE_FILIAL"])
        oCarga:setaPropriedade("03_GFE_SITUACAO","T", "Situação",4,,,"po-lg-6 po-xl-6 po-md-6 po-sm-12",/*oEstilos*/,/*cIcone*/,oPrmAdc["03_GFE_SITUACAO"])
        oCarga:setaPropriedade("04_GFE_TIPOPERIODO","X", "Período",4,,,"po-lg-6 po-xl-6 po-md-6 po-sm-12",/*oEstilos*/,/*cIcone*/,oPrmAdc["04_GFE_TIPOPERIODO"])
        oCarga:setaPropriedade("05_GFE_PERIODO","999", "Período personalizado (dias)",2,4,0,"po-lg-6 po-xl-6 po-md-6 po-sm-12")
        oCarga:setaPropriedade("07_GFE_SEMAFORO", "Atenção;Urgente", "Semáforo (Quantidade)",1,30,0,"po-lg-8 po-xl-8 po-md-8 po-sm-12",/*oEstilos*/,/*cIcone*/,/*oPrmAdc*/)

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
@since 15/08/2023
@version P12.1.2410
@param	oFiltros  , objeto Json, Contém as propriedades do monitor usadas para filtrar a query de busca
@param	cTipo     , caracter   , Tipo chart/info
@param	cSubTipo  , caracter   , Tipo de grafico pie/bar/column
@return cJsonDados, caracter   , Retorna um novo Json em formato texto, pronto para conversão e exibição no front
/*/
Method BuscaDados(oFiltros, cTipo, cSubTipo) Class MonitorCarregamento
    Local cAliasQry  := GetNextAlias()
    Local cJsonDados := ""
    Local cQuery     := ""
    Local nQtdDoc    := 0
    Local nPos       := 0
    Local oJsonRet   := JsonObject():New()
    Local aSemaforo  := StrTokArr(Replace(oFiltros["07_GFE_SEMAFORO"],",","."),";")
    Local dDataIni   := PCPMonitorUtils():RetornaPeriodoInicial(AllTrim(oFiltros["04_GFE_TIPOPERIODO"]),dDatabase,cValToChar(oFiltros["05_GFE_PERIODO"]))

    Private cWhereSit  := ""

    oFiltros["01_GFE_FILIAL"] := PadR(oFiltros["01_GFE_FILIAL"], FWSizeFilial())
    oFiltros["02_GFE_FILIAL"] := PadR(oFiltros["02_GFE_FILIAL"], FWSizeFilial())
    If Alltrim(oFiltros["03_GFE_SITUACAO"]) == "T"
        cWhereSit  := "'1','2','3','4'"
    ElseIf Alltrim(oFiltros["03_GFE_SITUACAO"]) == "DE"
        cWhereSit  := "'1','2'"
    Else
        cWhereSit  := "'3','4'"
    EndIf

    cQuery += " SELECT COUNT(GWN.R_E_C_N_O_) QTDD_CARREG"
    cQuery += " FROM " + RetSqlName("GWN")+" GWN "
    cQuery += " WHERE GWN.GWN_FILIAL BETWEEN '" + xFilial("GWN", oFiltros["01_GFE_FILIAL"]) + "' AND '" + xFilial("GWN", oFiltros["02_GFE_FILIAL"]) + "'"
    cQuery += " AND GWN.GWN_DTIMPL BETWEEN '" + DTOS(dDataIni) + "' AND '" + DTOS(dDatabase) + "'"
    cQuery += " AND GWN.GWN_SIT IN (" + cWhereSit + ")"
    cQuery += " AND GWN.D_E_L_E_T_  = ' '"
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)
    If (cAliasQry)->(!Eof())
        nQtdDoc := (cAliasQry)->QTDD_CARREG
    EndIf
    (cAliasQry)->(dbCloseArea())

    If cTipo == "info"
        montaInfo(oJsonRet, nQtdDoc, aSemaforo)
    Else
        montaGraf(oJsonRet, nQtdDoc, aSemaforo, oFiltros, oFiltros["06_GFE_TIPOSEMAFORO"], cSubTipo)
    EndIf

    oJsonRet["tags"]     := {}
    aAdd(oJsonRet["tags"], JsonObject():New())
    nPos++
    oJsonRet["tags"][nPos]["texto"]      := " " + oFiltros["01_GFE_FILIAL"] + " - " + oFiltros["02_GFE_FILIAL"]
    oJsonRet["tags"][nPos]["colorTexto"] := ""
    oJsonRet["tags"][nPos]["icone"]      := "po-icon-company"
    aAdd(oJsonRet["tags"], JsonObject():New())
    nPos++
    oJsonRet["tags"][nPos]["texto"]      := " " + cValToChar(dDataIni) + " - " + cValToChar(dDatabase) + " "
    oJsonRet["tags"][nPos]["colorTexto"] := ""
    oJsonRet["tags"][nPos]["icone"]      := "po-icon-calendar"

    If cTipo == "chart" .And. (cSubTipo != "column" .And. cSubTipo != "bar")
        aAdd(oJsonRet["tags"], JsonObject():New())
        nPos++
        oJsonRet["tags"][nPos]["colorTexto"] := ""
        oJsonRet["tags"][nPos]["icone"]      := "po-icon-star-filled"
        If Alltrim(oFiltros["03_GFE_SITUACAO"]) == "T"
            oJsonRet["tags"][nPos]["texto"] := " Todos"
        ElseIf Alltrim(oFiltros["03_GFE_SITUACAO"]) == "DE"
            oJsonRet["tags"][nPos]["texto"] := " Não Carregado(s)"
        Else
            oJsonRet["tags"][nPos]["texto"] := " Carregado(s)"
        EndIf
        
    ElseIf cSubTipo == "column" .Or. cSubTipo == "bar"
        If oFiltros["03_GFE_SITUACAO"] == "T"
            aAdd(oJsonRet["tags"], JsonObject():New())
            nPos++
            oJsonRet["tags"][nPos]["icone"]      := "po-icon-parameters"
            oJsonRet["tags"][nPos]["colorTexto"] := ""
            oJsonRet["tags"][nPos]["texto"]      := "Emitido"
            aAdd(oJsonRet["tags"], JsonObject():New())
            nPos++
            oJsonRet["tags"][nPos]["icone"]      := "po-icon-parameters"
            oJsonRet["tags"][nPos]["colorTexto"] := ""
            oJsonRet["tags"][nPos]["texto"]      := "Liberado"
        Else
            aAdd(oJsonRet["tags"], JsonObject():New())
            nPos++
            oJsonRet["tags"][nPos]["icone"]      := "po-icon-parameters"
            oJsonRet["tags"][nPos]["colorTexto"] := ""
            If oFiltros["03_GFE_SITUACAO"] == "DE"
                oJsonRet["tags"][nPos]["texto"] := "Emitido"
            ElseIf oFiltros["03_GFE_SITUACAO"] == "LE"
                oJsonRet["tags"][nPos]["texto"] := "Liberado"
            EndIf
        EndIf
    EndIf
    cJsonDados :=  oJsonRet:toJson()

    FreeObj(oJsonRet)
Return cJsonDados

/*/{Protheus.doc} ValidaPropriedades
Valida os dados informados nas propriedades do Monitor
@type Method
@author Jefferson Hita
@since 15/08/2023
@version P12.1.2410
@param  oFiltros, objeto json, Objeto json com os filtros para a consulta dos dados
@return aRetorno, array      , [1] logico - indica se os dados são válidos [2] caracter - mensagem de erro
/*/
Method ValidaPropriedades(oFiltros) Class MonitorCarregamento
    Local aFiliais  := FWLoadSM0(.T.,.T.)
    Local aRetorno  := {.T.,""}

    If Empty(oFiltros["01_GFE_FILIAL"]) .Or. Empty(oFiltros["02_GFE_FILIAL"])
        aRetorno[1] := .F.
        aRetorno[2] := "O filtro de Filial deve ser preenchido."
    EndIf

    If aRetorno[1] .And. oFiltros["04_GFE_TIPOPERIODO"] == "X"
        If !oFiltros:HasProperty("05_GFE_PERIODO") .Or. oFiltros["05_GFE_PERIODO"] == Nil .Or. Empty(oFiltros["05_GFE_PERIODO"])
            aRetorno[1] := .F.
            aRetorno[2] := "Deve ser informada a quantidade de dias para o período personalizado."
        EndIf
    EndIf

    FwFreeArray(aFiliais)
Return aRetorno

/*/{Protheus.doc} BuscaDetalhes
Realiza a busca dos dados para montar os detalhes do Monitor
@type Method
@author Jefferson Hita
@since 15/08/2023
@version P12.1.2410
@return Nil
/*/
Method BuscaDetalhes(oFiltro,nPagina) Class MonitorCarregamento
    Local cAlias     := GetNextAlias()
    Local cQuery     := ""
    Local cWhereSit  := ""
    Local dDataFim   := dDatabase
    Local dDataIni   := PCPMonitorUtils():RetornaPeriodoInicial(AllTrim(oFiltro["04_GFE_TIPOPERIODO"]),dDataFim,cValToChar(oFiltro["05_GFE_PERIODO"]))
    Local lExpResult := .T.
    Local nI         := 0
    Local nPos       := 0
    Local oDados     := JsonObject():New()

    If Alltrim(oFiltro["03_GFE_SITUACAO"]) == "T"
        cWhereSit  := "'1','2','3','4'"
    ElseIf Alltrim(oFiltro["03_GFE_SITUACAO"]) == "DE"
        cWhereSit  := "'1','2'"
    Else
        cWhereSit  := "'3','4'"
    EndIf
 
    Private aFields  := {{"Filial"		   	, "GWN_FILIAL", "C", TamSX3("GWN_FILIAL")[1], 0,,1,2,.F.},;
                         {"Romaneio"		, "GWN_NRROM" , "C", TamSX3("GWN_NRROM")[1] , 0,,1,TamSX3("GWN_NRROM")[1],.T.},;
                         {"Data"	 		, "GWN_DTIMPL", "D", TamSX3("GWN_DTIMPL")[1], 0,,1,8,.T.},;
                         {"Prioridade"	 	, "GWN_PRIOR" , "N", TamSX3("GWN_PRIOR")[1] , 0,,1,2,.T.},;
                         {"Placa"	 		, "GWN_PLACA" , "C", TamSX3("GWN_PLACAD")[1], 0,PESQPICT("GWN","GWN_PLACAD"),1,TamSX3("GWN_PLACAD")[1],.T.},;
                         {"Cod Tipo Veic"	, "GWN_CDTPVC", "C", TamSX3("GWN_CDTPVC")[1], 0,,1,2,.F.},;
                         {"Tipo Veículo"	, "GV3_DSTPVC", "C", TamSX3("GV3_DSTPVC")[1], 0,,1,10,.T.},;
                         {"Cod Motorista"	, "GWN_CDMTR" , "C", TamSX3("GWN_CDMTR")[1] , 0,,1,2,.F.},;
                         {"Motorista"	 	, "GUU_NMMTR" , "C", TamSX3("GUU_NMMTR")[1] , 0,,1,10,.T.},;
                         {"Transportador"	, "GWN_CDTRP" , "C", TamSX3("GWN_CDTRP")[1] , 0,,1,6,.F.},;
                         {"Nome Transp"	    , "GU3_NMTRP" , "C", TamSX3("GU3_NMEMIT")[1], 0,,1,6,.T.},;
                         {"Tipo operação"	, "GV4_DSTPOP", "C", TamSX3("GV4_DSTPOP")[1], 0,,1,6,.T.},;
                         {"Carga Max"		, "CARGUT"	  , "N", TamSX3("GU8_CARGUT")[1], TamSX3("GU8_CARGUT")[2],PESQPICT("GU8","GU8_CARGUT"),2,10,.T.},;
                         {"% Lotação" 		, "PCT_CARGUT", "N", 10                     , 2,"@E 9,999.99",2,8,.T.},;
                         {"Volum Max" 		, "VOLUT"	  , "N", TamSX3("GU8_VOLUT")[1] , TamSX3("GU8_VOLUT")[2],PESQPICT("GU8","GU8_VOLUT"),2,5,.T.},;
                         {"% Ocupação"		, "PCT_VOLUT" , "N", 10                     , 2,"@E 9,999.99",2,8,.T.},;
                         {"Impresso?"  		, "IMPRESSO"  , "C", 05                     , 0,,1,5,.T.},;
                         {"UF Entregas" 	, "GU7_CDUF"  , "C", 50                     , 0,,1,6,.T.},;
                         {"Qtd Entregas"	, "QTD_TRE"   , "N", 15                     , 0,,2,10,.T.},;
                         {"Qtd Doctos"	 	, "QTD_DOC"	  , "N", 15                     , 0,,2,10,.T.},;
                         {"Qtd Vols"	 	, "GW8_QTDE"  , "N", TamSX3("GW8_QTDE")[1]  , 0,,2,10,.T.},;
                         {"Peso Carga"		, "GW8_PESOR" , "N", 15                     , 5,PESQPICT("GW8","GW8_PESOR"),2,10,.T.},;
                         {"Valor Carga" 	, "GW8_VALOR" , "N", TamSX3("GW8_VALOR")[1] , TamSX3("GW8_VALOR")[2],PESQPICT("GW8","GW8_VALOR"),2,10,.T.},;
                         {"Volume Carga" 	, "GW8_VOLUME", "N", TamSX3("GW8_VOLUME")[1], TamSX3("GW8_VOLUME")[2],PESQPICT("GW8","GW8_VOLUME"),2,10,.T.},;
                         {"Situação Cálculo", "GWN_CALC"  , "C", 30                     , 0,,1,10,.T.},;
                         {"Valor Frete" 	, "VLFRET"	  , "N", TamSX3("GWI_VLFRET")[1], TamSX3("GWI_VLFRET")[2],PESQPICT("GWI","GWI_VLFRET"),2,10,.T.},;
                         {"$ Frete Ton" 	, "FRT_PESOR" , "N", 15                     , 5,PESQPICT("GW8","GW8_PESOR"),2,10,.T.},;
                         {"% Frete Valor" 	, "FRT_VALOR" , "N", 15                     , 5,PESQPICT("GW8","GW8_VALOR"),2,10,.T.},;
                         {"$ Frete m3" 		, "FRT_VOLUME", "N", 15                     , 5,PESQPICT("GW8","GW8_VOLUME"),2,10,.T.}}

    Default nPagina := 1

    oFiltro["01_GFE_FILIAL"] := PadR(oFiltro["01_GFE_FILIAL"], FWSizeFilial())
    oFiltro["02_GFE_FILIAL"] := PadR(oFiltro["02_GFE_FILIAL"], FWSizeFilial())

    oDados["items"]                 := {}
    oDados["columns"]               := montaColun(lExpResult)
    oDados["canExportCSV"]          := .T.
    oDados["tags"]                  := {}
    aAdd(oDados["tags"],JsonObject():New())
    oDados["tags"][1]["icone"]      := "po-icon-company"
    oDados["tags"][1]["colorTexto"] := ""
    oDados["tags"][1]["texto"]      := oFiltro["01_GFE_FILIAL"] + " - " + oFiltro["02_GFE_FILIAL"]
    aAdd(oDados["tags"],JsonObject():New())
    oDados["tags"][2]["icone"]      := "po-icon-calendar"
    oDados["tags"][2]["colorTexto"] := ""
    oDados["tags"][2]["texto"]      := dToC(dDataIni) + " - " + dToC(dDataFim)
    aAdd(oDados["tags"],JsonObject():New())
    oDados["tags"][3]["icone"]      := "po-icon-bar-code"
    oDados["tags"][3]["colorTexto"] := ""
    If Alltrim(oFiltro["03_GFE_SITUACAO"]) == "T"
        oDados["tags"][3]["texto"] := "Todos"
    ElseIf Alltrim(oFiltro["03_GFE_SITUACAO"]) == "DE"
        oDados["tags"][3]["texto"] := "Não Carregado(s)"
    Else
        oDados["tags"][3]["texto"] := "Carregado(s)"
    EndIf
    
    cQuery := "SELECT DISTINCT GWN_FILIAL"
	cQuery += "     , GWN_NRROM"
	cQuery += "     , GWN_DTIMPL"
	cQuery += "     , GWN_PRIOR"
	cQuery += "     , GWN_PLACAD AS GWN_PLACA"
	cQuery += "     , GWN_CDTPVC"
	cQuery += "     , GWN_CDMTR"
	cQuery += "     , GWN_CDTRP"
	cQuery += "     , GWN_NRCIDD"
	cQuery += "     , GWN_CDTPOP"
	cQuery += "	   	, CASE WHEN (GU81.GU8_VOLUT+GU82.GU8_VOLUT+GU83.GU8_VOLUT) IS NOT NULL AND (GU81.GU8_VOLUT+GU82.GU8_VOLUT+GU83.GU8_VOLUT) > 0 THEN (GU81.GU8_VOLUT+GU82.GU8_VOLUT+GU83.GU8_VOLUT) ELSE GV3_VOLUT END VOLUT"
	cQuery += "     , CASE WHEN (GU81.GU8_CARGUT+GU82.GU8_CARGUT+GU83.GU8_CARGUT) IS NOT NULL AND (GU81.GU8_CARGUT+GU82.GU8_CARGUT+GU83.GU8_CARGUT) > 0 THEN (GU81.GU8_CARGUT+GU82.GU8_CARGUT+GU83.GU8_CARGUT) ELSE GV3_CARGUT END CARGUT"
	cQuery += "     , QTD_DOC"
	cQuery += "     , QTD_TRE"
	cQuery += "     , GW8_PESOR"
	cQuery += "     , GW8_VOLUME"
	cQuery += "     , GW8_QTDE"
	cQuery += "     , GW8_VALOR"
	cQuery += "     , GWN_CALC"
	cQuery += "     , GWN_SIT"
	cQuery += "     , GWF.VLFRET"
	cQuery += "     , GV3.GV3_DSTPVC"
	cQuery += "     , (SELECT GUU_NMMTR FROM " + RetSqlName("GUU") + " GUU WHERE GUU.GUU_FILIAL = '" + xFilial("GUU") + "' AND GUU.GUU_CDMTR = GWN.GWN_CDMTR AND GUU.D_E_L_E_T_ = '') GUU_NMMTR"
	cQuery += "     , (SELECT GU3_NMEMIT FROM " + RetSqlName("GU3") + " GU3TRP WHERE GU3TRP.GU3_FILIAL = '" + xFilial("GU3") + "' AND GU3TRP.GU3_CDEMIT = GWN.GWN_CDTRP AND GU3TRP.D_E_L_E_T_ = '') GU3_NMTRP"
	cQuery += "     , (SELECT GV4_DSTPOP FROM " + RetSqlName("GV4") + " GV4 WHERE GV4.GV4_FILIAL = '" + xFilial("GV4") + "' AND GV4.GV4_CDTPOP = GWN.GWN_CDTPOP AND GV4.D_E_L_E_T_ = '') GV4_DSTPOP"
	cQuery += "     , 0 AS PCT_CARGUT" // ", CASE WHEN CARGUT > 0 THEN (GW8_PESOR / CARGUT * 100) ELSE 0 END AS PCT_CARGUT"
	cQuery += "     , 0 AS PCT_VOLUT" // ", CASE WHEN VOLUT > 0 THEN (GW8_VOLUME / VOLUT * 100) ELSE 0 END AS PCT_VOLUT"
	cQuery += "     , CASE WHEN GWN_SIT = '2' THEN 'Sim' ELSE 'Não' END AS IMPRESSO"
	cQuery += "     , ' ' AS GU7_CDUF" // ", GetUFDest(GWN_FILIAL, GWN_NRROM) AS GU7_CDUF"
	cQuery += "     , CASE WHEN GW8_PESOR > 0 THEN (VLFRET / GW8_PESOR * 1000) ELSE 0 END AS FRT_PESOR"
	cQuery += "     , CASE WHEN GW8_VALOR > 0 THEN (VLFRET / GW8_VALOR * 100) ELSE 0 END AS FRT_VALOR"
	cQuery += "     , CASE WHEN GW8_VOLUME > 0 THEN (VLFRET / GW8_VOLUME) ELSE 0 END AS FRT_VOLUME"
	
	cQuery += "  FROM " + RetSQLName("GWN") + " GWN"
	cQuery += " INNER JOIN ("
	cQuery += " 	        SELECT GW1_FILIAL, GW1_FILROM, GW1_NRROM, COUNT(*) QTD_DOC, SUM(GW8_PESOR) GW8_PESOR, SUM(GW8_VOLUME) GW8_VOLUME, SUM(GW8_QTDE) GW8_QTDE, SUM(GW8_VALOR) GW8_VALOR, COUNT(DISTINCT GW1_CDDEST) QTD_TRE"
	cQuery += " 	          FROM " + RetSQLName("GW1") + " GW1"
	cQuery += " 	         INNER JOIN " + RetSQLName("GWN") + " GWN"
	If GFXCP1212210('GW1_FILROM')
		cQuery += "		        ON GWN.GWN_FILIAL = GW1.GW1_FILROM "
	Else
		cQuery += "	            ON GWN.GWN_FILIAL = GW1.GW1_FILIAL "
	EndIf
	cQuery += " 	           AND GWN.GWN_NRROM = GW1.GW1_NRROM "
    cQuery += "                AND GWN.GWN_SIT IN (" + cWhereSit + ")"
	cQuery += "   			   AND GWN.GWN_FILIAL BETWEEN '" + xFilial("GWN", oFiltro["01_GFE_FILIAL"]) + "' AND '" + xFilial("GWN", oFiltro["02_GFE_FILIAL"]) + "'"
	cQuery += " 	         INNER JOIN (SELECT GW8_FILIAL, GW8_CDTPDC, GW8_EMISDC, GW8_SERDC, GW8_NRDC, SUM(GW8_PESOR) GW8_PESOR, SUM(GW8_VOLUME) GW8_VOLUME, SUM(GW8_QTDE) GW8_QTDE, SUM(GW8_VALOR) GW8_VALOR FROM " + RetSQLName("GW8") + " WHERE D_E_L_E_T_ = '' GROUP BY GW8_FILIAL, GW8_CDTPDC, GW8_EMISDC, GW8_SERDC, GW8_NRDC) GW8"
	cQuery += " 	            ON GW8.GW8_FILIAL = GW1.GW1_FILIAL"
	cQuery += " 	 	       AND GW8.GW8_CDTPDC = GW1.GW1_CDTPDC"
	cQuery += " 	 	       AND GW8.GW8_EMISDC = GW1.GW1_EMISDC"
	cQuery += " 	 	       AND GW8.GW8_SERDC = GW1.GW1_SERDC"
	cQuery += " 	 	       AND GW8.GW8_NRDC = GW1.GW1_NRDC"
	cQuery += " 	         WHERE GW1.D_E_L_E_T_ = ''"
	cQuery += " 	         GROUP BY GW1_FILIAL, GW1_FILROM, GW1_NRROM"
	cQuery += "            ) GW1N"
	If GFXCP1212210('GW1_FILROM')
		cQuery += "     ON GW1N.GW1_FILROM = GWN.GWN_FILIAL"
	Else
		cQuery += "     ON GW1N.GW1_FILIAL = GWN.GWN_FILIAL"
	EndIf
	cQuery += "        AND GW1N.GW1_NRROM = GWN.GWN_NRROM"
	cQuery += "  LEFT JOIN " + RetSQLName("GU8") + " GU81 ON GU81.GU8_PLACA = GWN.GWN_PLACAD AND GU81.D_E_L_E_T_ = ''"
	cQuery += "  LEFT JOIN " + RetSQLName("GU8") + " GU82 ON GU82.GU8_PLACA = GWN.GWN_PLACAT AND GU82.D_E_L_E_T_ = ''"
	cQuery += "  LEFT JOIN " + RetSQLName("GU8") + " GU83 ON GU83.GU8_PLACA = GWN.GWN_PLACAM AND GU83.D_E_L_E_T_ = ''"
	cQuery += "  LEFT JOIN " + RetSQLName("GV3") + " GV3  ON GV3.GV3_FILIAL = '" + xFilial("GV3") + "' AND GV3.GV3_CDTPVC = GWN.GWN_CDTPVC AND GV3.D_E_L_E_T_ = ''"
	cQuery += "  LEFT JOIN ("
	cQuery += "  	        SELECT GWF_FILIAL, GWF_NRROM, SUM(GWI_VLFRET+GWF_VLAJUS) VLFRET "
	cQuery += "  	          FROM " + RetSQLName("GWF") + " GWF"
	cQuery += "	             INNER JOIN " + RetSQLName("GWN") + " GWN"
	cQuery += "	                ON GWN.GWN_FILIAL = GWF.GWF_FILIAL "
	cQuery += "	 			   AND GWN.GWN_NRROM = GWF.GWF_NRROM "
    cQuery += "                AND GWN.GWN_SIT IN (" + cWhereSit + ")"
	cQuery += "   			   AND GWN.D_E_L_E_T_ = ''"
	cQuery += " 	          LEFT JOIN (SELECT GWI_FILIAL, GWI_NRCALC, SUM(GWI_VLFRET) GWI_VLFRET FROM " + RetSQLName("GWI") + " WHERE D_E_L_E_T_ = '' AND GWI_TOTFRE = '1' GROUP BY GWI_FILIAL, GWI_NRCALC) GWI"
	cQuery += "	                ON GWI.GWI_FILIAL = GWF.GWF_FILIAL"
	cQuery += "	               AND GWI.GWI_NRCALC = GWF.GWF_NRCALC"
	cQuery += "	             WHERE GWF.D_E_L_E_T_ = ''"
	cQuery += "	               AND GWF_TPCALC != '8'"
	cQuery += "	             GROUP BY GWF_FILIAL, GWF_NRROM"
	cQuery += "	           ) GWF"
	cQuery += "	   ON GWF.GWF_FILIAL = GWN.GWN_FILIAL"
	cQuery += "	  AND GWF.GWF_NRROM = GWN.GWN_NRROM"
	cQuery += " WHERE GWN.D_E_L_E_T_ = ''"
	cQuery += "   AND GWN.GWN_FILIAL BETWEEN '" + xFilial("GWN", oFiltro["01_GFE_FILIAL"]) + "' AND '" + xFilial("GWN", oFiltro["02_GFE_FILIAL"]) + "'"
    cQuery += "   AND GWN.GWN_DTIMPL BETWEEN '" + DTOS(dDataIni) + "' AND '" + DTOS(dDatabase) + "'"
    cQuery += "   AND GWN.GWN_SIT IN (" + cWhereSit + ")"

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)
    While (cAlias)->(!Eof())
        aAdd(oDados["items"], JsonObject():New())
        nPos++
        For nI := 1 To Len(aFields)
            If Alltrim(aFields[nI][3]) == "D"
                oDados["items"][nPos][aFields[nI][2]] := &( "DTOC(STOD((cAlias)->" + Alltrim(aFields[nI][2])+"))" )
            ElseIf Alltrim(aFields[nI][3]) == "N"
                If Alltrim(aFields[nI][2]) == "PCT_CARGUT"
                    oDados["items"][nPos][aFields[nI][2]] := iif((cAlias)->CARGUT > 0, ((cAlias)->GW8_PESOR / (cAlias)->CARGUT * 100), 0)
                ElseIf Alltrim(aFields[nI][2]) == "PCT_VOLUT"
                    oDados["items"][nPos][aFields[nI][2]] := iif((cAlias)->VOLUT > 0, ((cAlias)->GW8_VOLUME / (cAlias)->VOLUT * 100), 0)
                Else
                    oDados["items"][nPos][aFields[nI][2]] := &("Round((cAlias)->" + Alltrim(aFields[nI][2])+", 2)")
                EndIf
            Else
                If Alltrim(aFields[nI][2]) == "GU7_CDUF"
                    oDados["items"][nPos][aFields[nI][2]] := GetUFDest((cAlias)->GWN_FILIAL, (cAlias)->GWN_NRROM)
                Else
                    oDados["items"][nPos][aFields[nI][2]] := &("(cAlias)->" + Alltrim(aFields[nI][2]))
                EndIf
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
@since 15/08/2023
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
@since 15/08/2023
@version P12.1.2410
@param  oJsonRet  , objeto json, Objeto json que receberá os dados do gauge
@param  nQtdDoc   , numerico   , Número de documentos retornado da consulta
@param  aSemaforo , array      , Array com os números do semáforo
@param  oFiltros  , array      , filtros configurados
@param  cTipoSemaf, caracter   , L - Quantidade Lotes / Q - Saldo Lotes
@param  cSubTipo  , caracter   , Tipo de grafico pie/bar/column
@return Nil
/*/
Static Function montaGraf(oJsonRet,nQtdDoc,aSemaforo,oFiltros,cTipoSemaf,cSubTipo)
    Local cQuery     := ""
    Local cMesAtual  := ""
    Local cValorFim  := ""
    Local cValSemaf1 := iif(Len(aSemaforo) > 0, aSemaforo[1], '0')
    Local cValSemaf2 := iif(Len(aSemaforo) > 0, aSemaforo[2], '0')
    Local cAlias     := GetNextAlias()
    Local nI         := 0
    Local nPosDt     := 0
    Local nValorFim  := 0
    Local nValSemaf1 := Val(cValSemaf1)
    Local nValSemaf2 := Val(cValSemaf2)
    Local dDataIni   := ""
    Local aAuxMes    := {}
    Local aEmit      := {}
    Local aLiber     := {}
    Local oDados     := JsonObject():New()

    If cSubTipo == "gauge"
        If nQtdDoc > nValSemaf2
            nValorFim := nQtdDoc + (nValSemaf2 - nValSemaf1)
        Else
            nValorFim := nValSemaf2 + (nValSemaf2 - nValSemaf1)
        EndIf
        cValorFim := cValToChar(nValorFim)

        oJsonRet["alturaMinimaWidget"] := "350px"
        oJsonRet["alturaMaximaWidget"] := "500px"
        oJsonRet["categorias"] := {}
        oJsonRet["series"]     := {}
        oJsonRet["detalhes"]   := {}
        oJsonRet["gauge"]           := JsonObject():New()
        oJsonRet["gauge"]["type"]   := "arch"
        oJsonRet["gauge"]["value"]  := nQtdDoc
        oJsonRet["gauge"]["max"]    := nValorFim
        oJsonRet["gauge"]["label"]  := "Documento(s)"
        oJsonRet["gauge"]["append"] := ""
        oJsonRet["gauge"]["thick"]  := 20
        oJsonRet["gauge"]["margin"] := 15
        oJsonRet["gauge"]["valueStyle"]                := JsonObject():New()
        oJsonRet["gauge"]["valueStyle"]["color"]       := retCorSmf(nQtdDoc,nValSemaf1,nValSemaf2)
        oJsonRet["gauge"]["valueStyle"]["font-weight"] := "bold"
        oJsonRet["gauge"]["labelStyle"]                := JsonObject():New()
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

    ElseIf cSubTipo == "column" .Or. cSubTipo == "bar"
        
        dDataIni := PCPMonitorUtils():RetornaPeriodoInicial(AllTrim(oFiltros["04_GFE_TIPOPERIODO"]),dDatabase,cValToChar(oFiltros["05_GFE_PERIODO"]))
        oFiltros["01_GFE_FILIAL"] := PadR(oFiltros["01_GFE_FILIAL"], FWSizeFilial())
        oFiltros["02_GFE_FILIAL"] := PadR(oFiltros["02_GFE_FILIAL"], FWSizeFilial())
        
        oJsonRet["alturaMinimaWidget"] := "350px"
        oJsonRet["alturaMaximaWidget"] := "500px"
        oJsonRet["categorias"] := {}
        oJsonRet["series"]     := {}
        oJsonRet["tags"]       := {}

        cQuery += " SELECT *"
        cQuery += " FROM " + RetSqlName("GWN")+" GWN "
        cQuery += " WHERE GWN.GWN_FILIAL BETWEEN '" + xFilial("GWN", oFiltros["01_GFE_FILIAL"]) + "' AND '" + xFilial("GWN", oFiltros["02_GFE_FILIAL"]) + "'"
        cQuery += " AND GWN.GWN_DTIMPL BETWEEN '" + DTOS(dDataIni) + "' AND '" + DTOS(dDatabase) + "'"
        cQuery += " AND GWN.GWN_SIT IN (" + cWhereSit + ")"
        cQuery += " AND GWN.D_E_L_E_T_  = ' '"
        dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)
        While (cAlias)->(!Eof())
            cMesAtual := Month2Str(stod((cAlias)->GWN_DTIMPL))
            If !oDados:HasProperty(cMesAtual)
                aadd(aAuxMes, {cMesAtual, MesExtenso(stod((cAlias)->GWN_DTIMPL))})
                oDados[cMesAtual] := JsonObject():New()
                oDados[cMesAtual]["1"] := 0
                oDados[cMesAtual]["2"] := 0
            EndIf

            If Alltrim((cAlias)->GWN_SIT) $ "1;2" // 1=Digitado;2=Emitido;3=Liberado;4=Encerrado
                oDados[cMesAtual]["1"]++
            Else
                oDados[cMesAtual]["2"]++
            EndIf

            (cAlias)->(dbSkip())
        EndDo
        (cAlias)->(dbCloseArea())

        aSort(aEmit)
        aSort(aLiber)

        // Meses dentro do periodo indicado
        oJsonRet["categorias"] := oDados:GetNames()
        oJsonRet["chaveCategorias"] := {}
        nTotCateg := Len(oJsonRet["categorias"])
        For nI := 1 To nTotCateg
            aAdd(aEmit , oDados[oJsonRet["categorias"][nI]]["1"])
            aAdd(aLiber, oDados[oJsonRet["categorias"][nI]]["2"])

            nPosDt := aScan(aAuxMes,{|x| x[1] == oJsonRet["categorias"][nI]})
            aAdd(oJsonRet["chaveCategorias"], JsonObject():New())
            oJsonRet["chaveCategorias"][nI]["valor"] := oJsonRet["categorias"][nI]
            oJsonRet["chaveCategorias"][nI]["label"] := aAuxMes[nPosDt][2]
            oJsonRet["categorias"][nI] := aAuxMes[nPosDt][2]
        Next nIndice

        aAdd(oJsonRet["series"], JsonObject():New())
        oJsonRet["series"][1]["color"]   := COR_VERMELHO
        oJsonRet["series"][1]["data"]    := aEmit
        oJsonRet["series"][1]["tooltip"] := ""
        oJsonRet["series"][1]["label"]   := "Emitido"
        
        aAdd(oJsonRet["series"], JsonObject():New())	
        oJsonRet["series"][2]["color"]   := COR_VERDE
        oJsonRet["series"][2]["data"]    := aLiber
        oJsonRet["series"][2]["tooltip"] := ""
        oJsonRet["series"][2]["label"]   := "Liberado"
    EndIf
Return

/*/{Protheus.doc} montaInfo
Monta objeto json com os dados para mostrar o gráfico de informações
@type Static Function
@author Jefferson Hita
@since 15/08/2023
@version P12.1.2410
@param  oJsonRet  , objeto json, Objeto json que receberá os dados do gauge
@param  nQtdDoc   , numerico   , Número de documentos retornados da consulta
@return Nil
/*/
Static Function montaInfo(oJsonRet, nQtdDoc, aSemaforo)
    Local cTxtPrc    := cValToChar(nQtdDoc)
    Local cTxtSec    := "Não Carregado(s)"
    Local oStyle     := JsonObject():New()
    Local oStyleQtd  := JsonObject():New()

    oStyle["color"] := "white"
    oJsonRet["corTitulo"]          := "white"
    oJsonRet["alturaMinimaWidget"] := "350px"
    oJsonRet["alturaMaximaWidget"] := "500px"
    oJsonRet["linhas"]             := {}

    If nQtdDoc > 0
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
        oJsonRet["linhas"][1]["texto"]           := "Nenhum carregamento foi identificado no filtro selecionado."
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

/*/{Protheus.doc} retCorSmf
Retorna a UF dos destinatarios dos DCs associados ao Romaneio
@type Static Function
@author Jefferson Hita
@since 15/08/2023
@version P12.1.2310
@param  cFil   , caracter, String com codigo da filial usada no romaneio
@return cNrRom , caracter, String com numero do Romaneio de Carga
/*/
Static Function GetUFDest(cFil, cNrRom)
	Local cRet      := ""
	Local cInner    := ""
	Local cAliasGWN := GetNextAlias()

	If GFXCP1212210('GW1_FILROM')
		cInner += " GW1_FILROM = GWN_FILIAL"
	Else
		cInner += " GW1_FILIAL = GWN_FILIAL"
	EndIf
    cInner := "%" + cInner + "%"

    BeginSql Alias cAliasGWN
        SELECT DISTINCT GWN_FILIAL,GWN_NRROM,GU7_CDUF
        FROM %table:GWN% GWN
    	INNER JOIN %table:GW1% GW1 
        ON %Exp:cInner% AND GW1_NRROM = GWN_NRROM AND GW1.%NotDel%
    	INNER JOIN %table:GU3% GU3 ON GU3_CDEMIT = GW1_CDDEST AND GU3.%NotDel%
	    INNER JOIN %table:GU7% GU7 ON GU7_NRCID = GU3_NRCID AND GU7.%NotDel%
        WHERE GWN.GWN_FILIAL = %Exp:cFil%
        AND GWN.GWN_NRROM  = %Exp:cNrRom%
        AND GWN.%NotDel%
    EndSql
    While !(cAliasGWN)->(Eof())
        If !Empty(cRet)
            cRet += ","	
        EndIf
        
        cRet += (cAliasGWN)->GU7_CDUF 

        (cAliasGWN)->(DbSkip())
    EndDo
    (cAliasGWN)->( dbCloseArea() )
	
Return cRet
