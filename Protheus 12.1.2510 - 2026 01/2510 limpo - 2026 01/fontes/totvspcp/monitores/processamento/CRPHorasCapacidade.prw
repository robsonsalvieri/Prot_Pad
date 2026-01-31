#INCLUDE "TOTVS.CH"
#INCLUDE "PCPMONITORDEF.CH"
#INCLUDE "PCPMONITOR.CH"

#DEFINE TIPO_DISPONIBILIDADE "D"
#DEFINE TIPO_DEMANDA "O"
#DEFINE TIPO_CRP "C"

#DEFINE TIPO_OP_AMBAS "A"
#DEFINE TIPO_OP_FIRMES "F"
#DEFINE TIPO_OP_PREVISTAS "P"

#DEFINE OPCAO_SIM "S"
#DEFINE OPCAO_NAO "N"

#DEFINE ICONE_CALENDARIO "po-icon-calendar"
#DEFINE ICONE_RECURSO    "po-icon-manufacture"
#DEFINE ICONE_CTRAB      "po-icon-filter"
#DEFINE ICONE_TIPO_OP    "po-icon-document"

/*/{Protheus.doc} CRPHorasCapacidade
Classe para prover os dados do monitor CRPHorasCapacidade
@author Lucas Fagundes
@since 14/02/2025
@version P12
/*/
Class CRPHorasCapacidade From LongNameClass
    Private Data cFiltFil  as Caracter
    Private Data cSerie    as Caracter
    Private Data cTipoOP   as Caracter
    Private Data oFiltros  as Object
    Private Data dDataIni  as Date
    Private Data dDataFim  as Date
    Private Data aRecursos as Array
    Private Data aCTrabs   as Array
    Private Data lUsaSHY   as Logical

    Public Method new(oFiltros) Constructor
    Public Method getHorasDisponibilidade(nPage, nPageSize)
    Public Method getHorasDemandas(nPage, nPageSize)
    Public Method getHorasCRP(nPage, nPageSize)
    Public Method getColunasDetalhes()
    Public Method getTagFiltros()

    Private Method getQueryOperacoes()
    Private Method getQueryBuscaCRP(lDetalhado)

    Static Method cargaMonitor()
    Static Method validaPropriedades(oFiltros)
    Static Method buscaDados(oFiltros, cTipo, cSubTipo)
    Static Method buscaDetalhes(oFiltros, nPagina)
EndClass

/*/{Protheus.doc} new
Método construtor da classe CRPHorasCapacidade.
@author Lucas Fagundes
@since 14/02/2025
@version P12
@param oFiltros, Object, Filtros do monitor.
@return Self, Object, Nova instancia da classe.
/*/
Method new(oFiltros) Class CRPHorasCapacidade
    Local aPerAux := {}

    Self:aCTrabs   := {}
    Self:aRecursos := {}
    Self:cSerie    := ""
    Self:oFiltros  := oFiltros
    Self:lUsaSHY   := SuperGetMv("MV_APS", .F., "") == "TOTVS" .Or. ExisteSFC('SC2') .Or. SuperGetMv("MV_PCPATOR", .F., .F.)
    Self:cTipoOP   := TIPO_OP_AMBAS

    If oFiltros:HasProperty("RECURSO") .And. ValType(oFiltros["RECURSO"]) == "A"
        Self:aRecursos := oFiltros["RECURSO"]
    EndIf

    If oFiltros:HasProperty("CTRAB") .And. ValType(oFiltros["CTRAB"]) == "A"
        Self:aCTrabs := oFiltros["CTRAB"]
    EndIf

    If oFiltros:hasProperty("CT_BRANCO") .And. ValType(oFiltros["TIPO_OP"]) == "C" .And. oFiltros["CT_BRANCO"] == OPCAO_SIM
        aAdd(Self:aCTrabs, " ")
    EndIf

    If oFiltros:HasProperty("TIPO_OP") .And. ValType(oFiltros["TIPO_OP"]) == "C"
        Self:cTipoOP := oFiltros["TIPO_OP"]
    EndIf

    If oFiltros:HasProperty("SERIE")
        Self:cSerie := oFiltros["SERIE"]
    EndIf

    aPerAux  := PCPMonitorUtils():RetornaListaPeriodosFuturo(oFiltros["TIPO_PERIODO"], cValToChar(oFiltros["PERIODO"]))
    Self:dDataIni := aPerAux[1][1]
    Self:dDataFim := aTail(aPerAux)[2]

    FwFreeArray(aPerAux)
Return Self

/*/{Protheus.doc} cargaMonitor
Realiza a carga do monitor para o banco de dados.
@author Lucas Fagundes
@since 14/02/2025
@version P12
@return lRet, Logico, Indica se a carga do monitor foi realizada com sucesso.
/*/
Method cargaMonitor() Class CRPHorasCapacidade
    Local aCategoria := {}
    Local aDetalhes  := {}
    Local aTags      := {}
    Local lRet       := .T.
    Local nPosTag    := 0
    Local oCarga     := PCPMonitorCarga():New()
    Local oSeries    := JsonObject():New()
    Local oParAdc    := JsonObject():New()

    If !PCPMonitorCarga():monitorAtualizado("CRPHorasCapacidade")

        oSeries["Disponibilidade"] := {{100}, COR_VERDE_FORTE    }
        oSeries["Demandas"       ] := {{ 75}, COR_VERMELHO_FORTE }
        oSeries["CRP"            ] := {{ 50}, COR_AMARELO_ESCURO }

        PCPMonitorUtils():AdicionaTagMonitor(aTags, @nPosTag, ICONE_CALENDARIO, "01/02/2024 - 15/02/2024")
        PCPMonitorUtils():AdicionaTagMonitor(aTags, @nPosTag, ICONE_RECURSO, "INJ")

        oCarga:setaTitulo(STR0287) // "CRP - Horas X Capacidade"
        oCarga:setaObjetivo(STR0288) // "Acompanhar as horas das demandas produtivas e horas planejadas pelas programações do CRP (PCPA152) versus a capacidade dos recursos, em um determinado período."

        oCarga:setaAgrupador("PCP")
        oCarga:setaFuncaoNegocio("CRPHorasCapacidade")
        oCarga:setaTiposPermitidos("chart")
        oCarga:setaTiposGraficoPermitidos("column")
        oCarga:setaTipoPadrao("chart")
        oCarga:setaTipoGraficoPadrao("column")
        oCarga:setaTipoDetalhe("detalhe")
        oCarga:setaExemploJsonGrafico(oSeries, aTags, aDetalhes, aCategoria, "column")

        oCarga:setaPropriedadeFilial("FILIAL")

        oCarga:setaPropriedadeRecurso("RECURSO",.T.)

        oCarga:setaPropriedadeLookupTabela("CTRAB", STR0289, .T., "SHB", "HB_COD", "HB_NOME") // "Centro de trabalho"

        oParAdc["CT_BRANCO"] := JsonObject():New()
        oParAdc["CT_BRANCO"]["opcoes"] := STR0303 + ":" + OPCAO_SIM + ";" + STR0304 + ":" + OPCAO_NAO // "Sim" "Não"
        oCarga:setaPropriedade("CT_BRANCO", OPCAO_NAO, STR0290, 4, , /*cDecimal*/, "po-sm-12 po-md-6 po-lg-6 po-xl-6", /*oEstilos*/, /*cIcone*/, oParAdc["CT_BRANCO"]) // "Filtra CT em branco?"

        oParAdc["TIPO_OP"] := JsonObject():New()
        oParAdc["TIPO_OP"]["opcoes"] := STR0300 + ":" + TIPO_OP_AMBAS + ";" + STR0301 + ":" + TIPO_OP_FIRMES + ";" + STR0302 + ":" + TIPO_OP_PREVISTAS // "Ambas" "Firmes" "Previstas"
        oCarga:setaPropriedade("TIPO_OP", TIPO_OP_AMBAS, STR0291, 4, , /*cDecimal*/, "po-sm-12 po-md-6 po-lg-6 po-xl-6", /*oEstilos*/, /*cIcone*/, oParAdc["TIPO_OP"]) // "Tipo ordem de produção"

        oCarga:setaPropriedadePeriodoLinhaTempo("TIPO_PERIODO", "D", "PERIODO")

        lRet := oCarga:gravaMonitorPropriedades()
    EndIf

    oCarga:Destroy()

    FwFreeArray(aCategoria)
    FwFreeArray(aDetalhes)
    FwFreeArray(aTags)
    FreeObj(oSeries)
    FreeObj(oCarga)
Return lRet

/*/{Protheus.doc} validaPropriedades
Valida os dados informados nas propriedades do monitor.
@author Lucas Fagundes
@since 14/02/2025
@version P12
@param  oFiltros, Object, Objeto json com os filtros para a consulta dos dados
@return aRetorno, Array , [1] logico - indica se os dados são válidos
                          [2] caracter - mensagem de erro
/*/
Method validaPropriedades(oFiltros) Class CRPHorasCapacidade
    Local aRetorno := {.T., ""}

    PCPMonitorUtils():ValidaPropriedadeFilial(oFiltros["FILIAL"],aRetorno)

Return aRetorno

/*/{Protheus.doc} buscaDados
Retorna os dados para exibição do monitor.
@author Lucas Fagundes
@since 14/02/2025
@version P12
@param	oFiltros  , objeto Json, Contém as propriedades do monitor usadas para filtrar a query de busca
@param	cTipo     , caracter   , Tipo chart/info
@param	cSubTipo  , caracter   , Tipo de grafico pie/bar/column
@return cJsonDados, caracter   , Retorna um novo Json em formato texto, pronto para conversão e exibição no front
/*/
Method buscaDados(oFiltros, cTipo, cSubTipo) Class CRPHorasCapacidade
    Local cJsonDados := ""
    Local oCRP       := Nil
    Local oDemandas  := Nil
    Local oDisp      := Nil
    Local oJsonRet   := JsonObject():New()
    Local oSelf      := CRPHorasCapacidade():New(oFiltros)
    Local oSerie     := Nil

    oJsonRet["alturaMinimaWidget"] := "350px"
    oJsonRet["alturaMaximaWidget"] := "500px"
    oJsonRet["categorias"        ] := {STR0146} // "Tipo"
    oJsonRet["series"            ] := {}
    oJsonRet["tags"              ] := {}
    oJsonRet["detalhes"          ] := {}

    oDisp     := oSelf:getHorasDisponibilidade()
    oDemandas := oSelf:getHorasDemandas()
    oCRP      := oSelf:getHorasCRP()

    oSerie := JsonObject():New()
    oSerie["label"  ] := STR0292 // "Disponibilidade"
    oSerie["color"  ] := COR_VERDE_FORTE
    oSerie["tooltip"] := STR0293 + __Min2Hrs(__Hrs2Min(oDisp["total"]), .T.) // "Disponibilidade (hh:mm): "
    oSerie["data"   ] := {oDisp["total"]}

    aAdd(oJsonRet["series"], oSerie)

    oSerie := JsonObject():New()
    oSerie["label"  ] := STR0294 // "Demandas"
    oSerie["color"  ] := COR_VERMELHO_FORTE
    oSerie["tooltip"] := STR0295 + __Min2Hrs(__Hrs2Min(oDemandas["total"]), .T.) // "Demandas (hh:mm): "
    oSerie["data"   ] := {oDemandas["total"]}

    aAdd(oJsonRet["series"], oSerie)

    oSerie := JsonObject():New()
    oSerie["label"  ] := STR0296 // "CRP"
    oSerie["color"  ] := COR_AMARELO_ESCURO
    oSerie["tooltip"] := STR0297 + __Min2Hrs(__Hrs2Min(oCRP["total"]), .T.) // "CRP (hh:mm): "
    oSerie["data"   ] := {oCRP["total"]}

    aAdd(oJsonRet["series"], oSerie)

    oJsonRet["tags"] := oSelf:getTagFiltros()
    cJsonDados := oJsonRet:toJson()

    FreeObj(oSerie)
    FreeObj(oJsonRet)
    FwFreeObj(oCRP)
    FwFreeObj(oDisp)
    FwFreeObj(oDemandas)
    FwFreeObj(oSelf)
Return cJsonDados

/*/{Protheus.doc} getHorasDisponibilidade
Retorna as horas disponiveis nos recursos.
@author Lucas Fagundes
@since 14/02/2025
@version P12
@param nPage    , Numerico, Paginação dos registros que será retornado.
@param nPageSize, Numerico, Tamanho da pagina que será retornada.
@return oReturn, Object, Json com as informações de disponibilidade dos recursos.
/*/
Method getHorasDisponibilidade(nPage, nPageSize) Class CRPHorasCapacidade
    Local cAlias    := GetNextAlias()
    Local cQuery    := ""
    Local cRecurso  := ""
    Local lPaginado := .F.
    Local nCont     := 0
    Local nStart    := 0
    Local oItem     := Nil
    Local oRetDisp  := Nil
    Local oReturn   := JsonObject():New()

    cQuery := " SELECT DISTINCT SH1.H1_FILIAL, SH1.H1_CODIGO, SH1.H1_DESCRI "
    cQuery +=   " FROM " + RetSqlName("SH1") + " SH1 "
    cQuery +=  " INNER JOIN " + RetSqlName("SG2") + " SG2 "
    cQuery +=     " ON SG2.G2_FILIAL  = '" + xFilial("SG2", Self:cFiltFil) + "' "
    cQuery +=    " AND SG2.G2_RECURSO = SH1.H1_CODIGO "
    If !Empty(Self:aCTrabs)
        cQuery +=    " AND SG2.G2_CTRAB IN ('" + ArrToKStr(Self:aCTrabs, "','") + "') "
    EndIf
    cQuery +=    " AND SG2.D_E_L_E_T_ = ' ' "
    cQuery +=  " WHERE SH1.H1_FILIAL  = '" + xFilial("SH1", Self:cFiltFil) + "' "
    If !Empty(Self:aRecursos)
        cQuery +=    " AND SH1.H1_CODIGO IN ('" + ArrToKStr(Self:aRecursos, "','") + "') "
    EndIf
    cQuery +=    " AND SH1.D_E_L_E_T_ = ' ' "

    dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)

    oReturn["items"] := {}
    oReturn["total"] := 0

    If (cAlias)->(!EoF())
        lPaginado := nPage != Nil .And. nPage > 0

        If lPaginado .And. nPage > 0
            nStart := ((nPage-1) * nPageSize)

            If nStart > 0
                (cAlias)->(dbSkip(nStart))
            EndIf
        EndIf

        While (cAlias)->(!EoF())
            cRecurso := (cAlias)->H1_CODIGO
            nCont++

            oRetDisp := PCPA152Disponibilidade():buscaHorasRecurso(cRecurso, Self:dDataIni, Self:dDataFim)

            oItem := JsonObject():New()
            oItem["filial"     ] := (cAlias)->H1_FILIAL
            oItem["recurso"    ] := cRecurso
            oItem["descRecurso"] := (cAlias)->H1_DESCRI
            oItem["horas"      ] := oRetDisp["totalHoras"]

            aAdd(oReturn["items"], oItem)
            oReturn["total"] += __Hrs2Min(oRetDisp["totalHoras"])

            (cAlias)->(dbSkip())

            If lPaginado .And. nCont >= nPageSize
                Exit
            EndIf
        End

        oReturn["total"  ] := __Min2Hrs(oReturn["total"])
        oReturn["hasNext"] := (cAlias)->(!EoF())

        oItem    := Nil
        oRetDisp := Nil
    EndIf
    (cAlias)->(dbCloseArea())

Return oReturn

/*/{Protheus.doc} getHorasDemandas
Retorna as horas das demandas.
@author Lucas Fagundes
@since 14/02/2025
@version P12
@param nPage    , Numerico, Paginação dos registros que será retornado.
@param nPageSize, Numerico, Tamanho da pagina que será retornada.
@return oReturn, Object, Json com as informações de disponibilidade dos recursos.
/*/
Method getHorasDemandas(nPage, nPageSize) Class CRPHorasCapacidade
    Local cAlias     := GetNextAlias()
    Local cOrdem     := ""
    Local cQuery     := ""
    Local lPaginado  := .F.
    Local nCont      := 0
    Local nStart     := 0
    Local oAux       := Nil
    Local oItem      := Nil
    Local oReturn    := JsonObject():New()
    Local oTempoOper := Nil

    cQuery := Self:getQueryOperacoes()
    dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)

    oReturn["items"] := {}
    oReturn["total"] := 0

    If (cAlias)->(!EoF())
        lPaginado  := nPage != Nil .And. nPage > 0
        oTempoOper := PCPA152TempoOperacao():new()

        oTempoOper:setParam("MV_PERDINF", SuperGetMv("MV_PERDINF", .F., .F.))
        oTempoOper:setParam("MV_TPHR"   , SuperGetMv("MV_TPHR"   , .F., "C"))

        If lPaginado .And. nPage > 0
            nStart := ((nPage-1) * nPageSize)

            If nStart > 0
                (cAlias)->(dbSkip(nStart))
            EndIf
        EndIf

        While (cAlias)->(!EoF())
            cOrdem := (cAlias)->C2_NUM + (cAlias)->C2_ITEM + (cAlias)->C2_SEQUEN + (cAlias)->C2_ITEMGRD
            nCont++

            oAux := JsonObject():New()
            oAux["filial"        ] := (cAlias)->C2_FILIAL
            oAux["ordemProducao" ] := cOrdem
            oAux["produto"       ] := (cAlias)->C2_PRODUTO
            oAux["descProduto"   ] := (cAlias)->B1_DESC
            oAux["dataEntrega"   ] := PCPConvDat((cAlias)->C2_DATPRF, 4)
            oAux["operacao"      ] := (cAlias)->operacao
            oAux["descOperacao"  ] := (cAlias)->descOperacao
            oAux["recurso"       ] := (cAlias)->recurso
            oAux["descRecurso"   ] := (cAlias)->H1_DESCRI
            oAux["centroTrab"    ] := (cAlias)->centroTrab
            oAux["descCentroTrab"] := (cAlias)->HB_NOME
            oAux["quantidade"    ] := (cAlias)->C2_QUANT
            oAux["qtdProduzida"  ] := (cAlias)->C2_QUJE
            oAux["perda"         ] := (cAlias)->C2_PERDA
            oAux["lotePadrao"    ] := (cAlias)->lotePadrao
            oAux["tempoPadrao"   ] := (cAlias)->tempoPadrao
            oAux["tipoOperacao"  ] := (cAlias)->tipoOperacao
            oAux["maoDeObra"     ] := (cAlias)->maoDeObra

            oAux := oTempoOper:getTempoOperacao(oAux)

            oItem := JsonObject():New()
            oItem:fromJson(oAux:toJson())

            oItem["horas"] := __Min2Hrs(oItem["tempoOperacao"], .T.)

            aAdd(oReturn["items"], oItem)
            oReturn["total"] += oItem["tempoOperacao"]

            (cAlias)->(dbSkip())

            If lPaginado .And. nCont >= nPageSize
                Exit
            EndIf
        End

        oReturn["total"  ] := __Min2Hrs(oReturn["total"])
        oReturn["hasNext"] := (cAlias)->(!EoF())

        oTempoOper:destroy()

        oAux  := Nil
        oItem := Nil
        FwFreeObj(oTempoOper)
    EndIf
    (cAlias)->(dbCloseArea())

Return oReturn

/*/{Protheus.doc} getQueryOperacoes
Retorna a query que busca as demandas no periodo do monitor.
@author Lucas Fagundes
@since 14/02/2025
@version P12
@return cQuery, Caracter, Query para buscar as operações no periodo do monitor.
/*/
Method getQueryOperacoes() Class CRPHorasCapacidade
    Local cQuery := ""

    cQuery := " SELECT SC2.C2_FILIAL, "
    cQuery +=        " SC2.C2_NUM, "
    cQuery +=        " SC2.C2_ITEM, "
    cQuery +=        " SC2.C2_SEQUEN, "
    cQuery +=        " SC2.C2_ITEMGRD, "
    cQuery +=        " SC2.C2_QUANT, "
    cQuery +=        " SC2.C2_QUJE, "
    cQuery +=        " SC2.C2_PERDA, "
    cQuery +=        " SC2.C2_DATPRF, "
    cQuery +=        " SH1.H1_DESCRI, "
    cQuery +=        " SHB.HB_NOME, "
    cQuery +=        " SC2.C2_PRODUTO, "
    cQuery +=        " SB1.B1_DESC, "
    If Self:lUsaSHY
        cQuery += " COALESCE(SHY.HY_OPERAC, SG2.G2_OPERAC) operacao, "
        cQuery += " COALESCE(SHY.HY_DESCRI, SG2.G2_DESCRI) descOperacao, "
        cQuery += " COALESCE(SHY.HY_RECURSO, SG2.G2_RECURSO) recurso, "
        cQuery += " COALESCE(SHY.HY_CTRAB, SG2.G2_CTRAB) centroTrab, "
		cQuery += " COALESCE(SHY.HY_TPOPER, SG2.G2_TPOPER) tipoOperacao, "
        cQuery += " COALESCE(SHY.HY_TEMPAD, SG2.G2_TEMPAD) tempoPadrao, "
		cQuery += " CASE "
		cQuery +=    " WHEN COALESCE(SHY.HY_LOTEPAD, SG2.G2_LOTEPAD) = 0 THEN 1 "
		cQuery +=    " ELSE COALESCE(SHY.HY_LOTEPAD, SG2.G2_LOTEPAD) "
		cQuery += " END lotePadrao, "
        cQuery += " CASE "
		cQuery +=    " WHEN COALESCE(SHY.HY_MAOOBRA, SG2.G2_MAOOBRA) <> 0 THEN COALESCE(SHY.HY_MAOOBRA, SG2.G2_MAOOBRA) "
		cQuery +=    " ELSE SH1.H1_MAOOBRA "
		cQuery += " END maoDeObra "
    Else
        cQuery += " SG2.G2_OPERAC operacao, "
        cQuery += " SG2.G2_DESCRI descOperacao, "
        cQuery += " SG2.G2_RECURSO recurso, "
        cQuery += " SG2.G2_CTRAB centroTrab, "
        cQuery += " SG2.G2_TPOPER tipoOperacao, "
        cQuery += " SG2.G2_TEMPAD tempoPadrao, "
        cQuery += " SG2.G2_LOTEPAD lotePadrao, "
        cQuery += " CASE "
		cQuery +=    " WHEN SG2.G2_MAOOBRA <> 0 THEN SG2.G2_MAOOBRA "
		cQuery +=    " ELSE SH1.H1_MAOOBRA "
		cQuery += " END maoDeObra "
    EndIf

    cQuery +=   " FROM " + RetSqlName("SC2") + " SC2 "

    cQuery +=  " INNER JOIN " + RetSqlName("SB1") + " SB1 "
    cQuery +=     " ON SB1.B1_FILIAL  = '" + xFilial("SB1", Self:cFiltFil) + "' "
    cQuery +=    " AND SB1.B1_COD     = SC2.C2_PRODUTO "
    cQuery +=    " AND SB1.D_E_L_E_T_ = ' ' "

    If Self:lUsaSHY
		cQuery += " LEFT JOIN " + RetSqlName("SHY") + " SHY "
		cQuery +=   " ON SHY.HY_FILIAL  = '" + xFilial("SHY") + "' "
		cQuery +=  " AND " + PCPQrySC2("SC2", "SHY.HY_OP")
		cQuery +=  " AND SHY.HY_ROTEIRO = CASE "
		cQuery +=                           " WHEN SC2.C2_ROTEIRO <> ' ' THEN SC2.C2_ROTEIRO "
		cQuery +=                           " WHEN SB1.B1_OPERPAD <> ' ' THEN SB1.B1_OPERPAD "
		cQuery +=                           " ELSE '01' "
		cQuery +=                       " END "
		cQuery +=  " AND ((SHY.HY_DTINI <= '" + DtoS(Self:dDataIni) + "') OR (SHY.HY_DTINI  = ' ')) "
		cQuery +=  " AND ((SHY.HY_DTFIM >= '" + DtoS(Self:dDataFim) + "') OR (SHY.HY_DTFIM  = ' ')) "
		cQuery +=  " AND SHY.D_E_L_E_T_ = ' ' "
		cQuery +=  " AND SHY.HY_TEMPAD <> 0 "

        cQuery +=  " LEFT JOIN " + RetSqlName("SG2") + " SG2 "
    Else
        cQuery += " INNER JOIN " + RetSqlName("SG2") + " SG2 "
    EndIf
    cQuery +=     " ON SG2.G2_FILIAL  = '" + xFilial("SG2", Self:cFiltFil) + "' "
    cQuery +=    " AND SG2.G2_PRODUTO = SC2.C2_PRODUTO "
    cQuery +=    " AND SG2.G2_CODIGO  = CASE"
	cQuery +=                             " WHEN SC2.C2_ROTEIRO <> ' ' THEN SC2.C2_ROTEIRO"
	cQuery +=                             " WHEN SB1.B1_OPERPAD <> ' ' THEN SB1.B1_OPERPAD"
	cQuery +=                             " ELSE '01' "
	cQuery +=                         " END"
	cQuery +=    " AND ((SG2.G2_DTINI <= '" + DtoS(Self:dDataIni) + "') OR (SG2.G2_DTINI  = ' '))"
	cQuery +=    " AND ((SG2.G2_DTFIM >= '" + DtoS(Self:dDataFim) + "') OR (SG2.G2_DTFIM  = ' '))"
	cQuery +=    " AND SG2.D_E_L_E_T_ = ' '"
    If Self:lUsaSHY
        cQuery += " AND SHY.HY_OP IS NULL "
    Else
        If !Empty(Self:aCTrabs)
            cQuery += " AND SG2.G2_CTRAB IN ('" + ArrToKStr(Self:aCTrabs, "','") + "') "
        EndIf
        If !Empty(Self:aRecursos)
            cQuery += " AND SG2.G2_RECURSO IN ('" + ArrToKStr(Self:aRecursos, "','") + "') "
        EndIf
    EndIf

    cQuery +=  " INNER JOIN " + RetSqlName("SH1") + " SH1 "
    cQuery +=     " ON SH1.H1_FILIAL = '" + xFilial("SH1", Self:cFiltFil) + "' "
    If Self:lUsaSHY
		cQuery +=" AND ((SG2.G2_RECURSO IS NOT NULL AND SG2.G2_RECURSO = SH1.H1_CODIGO)"
		cQuery +=  " OR (SHY.HY_RECURSO IS NOT NULL AND SHY.HY_RECURSO = SH1.H1_CODIGO))"
	Else
		cQuery +=" AND SG2.G2_RECURSO = SH1.H1_CODIGO "
	EndIf
	cQuery +=    " AND SH1.D_E_L_E_T_ = ' ' "

    cQuery +=   " LEFT JOIN " + RetSqlName("SHB") + " SHB "
    cQuery +=     " ON SHB.HB_FILIAL = '" + xFilial("SHB", Self:cFiltFil) + "' "
    If Self:lUsaSHY
		cQuery +=" AND ((SG2.G2_CTRAB IS NOT NULL AND SG2.G2_CTRAB = SHB.HB_COD)"
		cQuery +=  " OR (SHY.HY_CTRAB IS NOT NULL AND SHY.HY_CTRAB = SHB.HB_COD))"
	Else
		cQuery +=" AND SG2.G2_CTRAB = SHB.HB_COD "
	EndIf
	cQuery +=    " AND SHB.D_E_L_E_T_ = ' ' "

    cQuery +=  " WHERE SC2.C2_FILIAL  = '" + xFilial("SC2", Self:cFiltFil) + "' "
    cQuery +=    " AND SC2.C2_DATPRF >= '" + DToS(Self:dDataIni) + "' "
    cQuery +=    " AND SC2.C2_DATPRF <= '" + DToS(Self:dDataFim) + "' "
    cQuery +=    " AND SC2.C2_DATRF   = ' ' "
    If Self:cTipoOP == TIPO_OP_FIRMES
        cQuery +=" AND SC2.C2_TPOP = 'F' "
    EndIf
    If Self:cTipoOP == TIPO_OP_PREVISTAS
        cQuery +=" AND SC2.C2_TPOP = 'P' "
    EndIf
    cQuery +=    " AND SC2.D_E_L_E_T_ = ' ' "
    If Self:lUsaSHY
		cQuery += " AND (SHY.HY_OP IS NOT NULL OR SG2.G2_CODIGO IS NOT NULL) "
        If !Empty(Self:aCTrabs)
            cQuery += " AND COALESCE(SHY.HY_CTRAB, SG2.G2_CTRAB) IN ('" + ArrToKStr(Self:aCTrabs, "','") + "') "
        EndIf
        If !Empty(Self:aRecursos)
            cQuery += " AND COALESCE(SHY.HY_RECURSO, SG2.G2_RECURSO) IN ('" + ArrToKStr(Self:aRecursos, "','") + "') "
        EndIf
	EndIf

Return cQuery

/*/{Protheus.doc} getHorasCRP
Busca as horas do CRP.
@author Lucas Fagundes
@since 17/02/2025
@version P12
@param nPage    , Numerico, Indica que o retorno será detalhado em páginas (-1 retorna todas as páginas).
@param nPageSize, Numerico, Tamanho da pagina que será retornada.
@return oReturn, Object, Json com as informações das horas do CRP.
/*/
Method getHorasCRP(nPage, nPageSize) Class CRPHorasCapacidade
    Local cAlias     := GetNextAlias()
    Local cQuery     := ""
    Local lDetalhado := .F.
    Local lExport    := .F.
    Local nCont      := 0
    Local nStart     := 0
    Local oItem      := Nil
    Local oReturn    := JsonObject():New()

    If nPage != Nil
        lDetalhado := .T.
        lExport    := nPage == 0
    EndIf

    cQuery := Self:getQueryBuscaCRP(lDetalhado)
    dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)

    oReturn["items"] := {}
    oReturn["total"] := 0

    If lDetalhado

        If !lExport .And. nPage > 1
            nStart := ((nPage-1) * nPageSize)

            If nStart > 0
                (cAlias)->(dbSkip(nStart))
            EndIf
	    EndIf

        While (cAlias)->(!EoF())
            nCont++

            oItem := JsonObject():New()
            oItem["filial"        ] := (cAlias)->HWF_FILIAL
            oItem["ordemProducao" ] := (cAlias)->HWF_OP
            oItem["produto"       ] := (cAlias)->C2_PRODUTO
            oItem["descProduto"   ] := (cAlias)->B1_DESC
            oItem["operacao"      ] := (cAlias)->HWF_OPER
            oItem["descOperacao"  ] := (cAlias)->descOperacao
            oItem["recurso"       ] := (cAlias)->HWF_RECURS
            oItem["descRecurso"   ] := (cAlias)->H1_DESCRI
            oItem["centroTrab"    ] := (cAlias)->HWF_CTRAB
            oItem["descCentroTrab"] := (cAlias)->HB_NOME
            oItem["data"          ] := PCPConvDat((cAlias)->HWF_DATA, 4)
            oItem["horaInicio"    ] := (cAlias)->HWF_HRINI
            oItem["horaFim"       ] := (cAlias)->HWF_HRFIM
            oItem["horas"         ] := __Min2Hrs((cAlias)->HWF_TEMPOT, .T.)

            aAdd(oReturn["items"], oItem)
            oReturn["total"] += (cAlias)->HWF_TEMPOT

            (cAlias)->(dbSkip())

            If !lExport .And. nCont >= nPageSize
                Exit
            EndIf
        End

        oReturn["total"  ] := __Min2Hrs(oReturn["total"])
        oReturn["hasNext"] := (cAlias)->(!EoF())

        oItem := Nil
    Else
        oReturn["total"  ] := __Min2Hrs((cAlias)->total)
        oReturn["hasNext"] := .F.
    EndIf
    (cAlias)->(dbCloseArea())

Return oReturn

/*/{Protheus.doc} getQueryBuscaCRP
Retorna a query que busca as horas do CRP no periodo do monitor. Se lDetalhado for .T. retorna os campos de forma detalhada, se .F. retorna de forma sumarizada.
@author Lucas Fagundes
@since 28/02/2025
@version P12
@param lDetalhado, Logico, Indica que deve buscar os campos de forma detalhada.
@return cQuery, Caracter, Query para buscar as horas do CRP.
/*/
Method getQueryBuscaCRP(lDetalhado) Class CRPHorasCapacidade
    Local cQuery := ""

    If lDetalhado
        cQuery := " SELECT HWF.HWF_FILIAL, "
        cQuery +=        " HWF.HWF_OP, "
        cQuery +=        " HWF.HWF_OPER, "
        cQuery +=        " HWF.HWF_RECURS, "
        cQuery +=        " HWF.HWF_CTRAB, "
        cQuery +=        " HWF.HWF_DATA, "
        cQuery +=        " HWF.HWF_HRINI, "
        cQuery +=        " HWF.HWF_HRFIM, "
        cQuery +=        " HWF.HWF_TEMPOT, "
        cQuery +=        " SH1.H1_DESCRI, "
        cQuery +=        " SHB.HB_NOME, "
        cQuery +=        " SC2.C2_PRODUTO, "
        cQuery +=        " SB1.B1_DESC, "
        If Self:lUsaSHY
            cQuery +=    " COALESCE(SHY.HY_DESCRI, SG2.G2_DESCRI) descOperacao "
        Else
            cQuery +=    " SG2.G2_DESCRI descOperacao "
        EndIf
    Else
        cQuery := " SELECT SUM(HWF.HWF_TEMPOT) total "
    EndIf
    cQuery +=   " FROM " + RetSqlName("HWF") + " HWF "
    If lDetalhado
        cQuery += " INNER JOIN " + RetSqlName("SC2") + " SC2 "
        cQuery +=    " ON SC2.C2_FILIAL  = '" + xFilial("SC2", Self:cFiltFil) + "' "
        cQuery +=   " AND " + PCPQrySC2("SC2", "HWF.HWF_OP")
        cQuery +=   " AND SC2.D_E_L_E_T_ = ' ' "

        cQuery +=  " INNER JOIN " + RetSqlName("SB1") + " SB1 "
        cQuery +=     " ON SB1.B1_FILIAL  = '" + xFilial("SB1", Self:cFiltFil) + "' "
        cQuery +=    " AND SB1.B1_COD     = SC2.C2_PRODUTO "
        cQuery +=    " AND SB1.D_E_L_E_T_ = ' ' "

        If Self:lUsaSHY
            cQuery += " LEFT JOIN " + RetSqlName("SHY") + " SHY "
            cQuery +=   " ON SHY.HY_FILIAL  = '" + xFilial("SHY") + "' "
            cQuery +=  " AND SHY.HY_OP      = HWF.HWF_OP "
            cQuery +=  " AND SHY.HY_ROTEIRO = HWF.HWF_ROTEIR "
            cQuery +=  " AND SHY.HY_OPERAC  = HWF.HWF_OPER "
            cQuery +=  " AND SHY.D_E_L_E_T_ = ' ' "

            cQuery +=  " LEFT JOIN " + RetSqlName("SG2") + " SG2 "
        Else
            cQuery += " INNER JOIN " + RetSqlName("SG2") + " SG2 "
        EndIf
        cQuery +=     " ON SG2.G2_FILIAL  = '" + xFilial("SG2", Self:cFiltFil) + "' "
        cQuery +=    " AND SG2.G2_PRODUTO = SC2.C2_PRODUTO "
        cQuery +=    " AND SG2.G2_CODIGO  = HWF.HWF_ROTEIR "
        cQuery +=    " AND SG2.G2_OPERAC  = HWF.HWF_OPER "
        cQuery +=    " AND SG2.D_E_L_E_T_ = ' ' "
        If Self:lUsaSHY
            cQuery += " AND SHY.HY_OP IS NULL "
        EndIf

        cQuery += " INNER JOIN " + RetSqlName("SH1") + " SH1 "
        cQuery +=    " ON SH1.H1_FILIAL = '" + xFilial("SH1", Self:cFiltFil) + "' "
        If Self:lUsaSHY
            cQuery +=" AND ((SG2.G2_RECURSO IS NOT NULL AND SG2.G2_RECURSO = SH1.H1_CODIGO)"
            cQuery +=  " OR (SHY.HY_RECURSO IS NOT NULL AND SHY.HY_RECURSO = SH1.H1_CODIGO))"
        Else
            cQuery +=" AND SG2.G2_RECURSO = SH1.H1_CODIGO "
        EndIf
        cQuery +=   " AND SH1.D_E_L_E_T_ = ' ' "

        cQuery +=  " LEFT JOIN " + RetSqlName("SHB") + " SHB "
        cQuery +=    " ON SHB.HB_FILIAL = '" + xFilial("SHB", Self:cFiltFil) + "' "
        If Self:lUsaSHY
            cQuery +=" AND ((SG2.G2_CTRAB IS NOT NULL AND SG2.G2_CTRAB = SHB.HB_COD)"
            cQuery +=  " OR (SHY.HY_CTRAB IS NOT NULL AND SHY.HY_CTRAB = SHB.HB_COD))"
        Else
            cQuery +=" AND SG2.G2_CTRAB = SHB.HB_COD "
        EndIf
        cQuery +=   " AND SHB.D_E_L_E_T_ = ' ' "
    EndIf

    cQuery +=  " WHERE HWF.HWF_FILIAL = '" + xFilial("HWF", Self:cFiltFil) + "' "
    cQuery +=    " AND HWF.HWF_DATA >= '" + DToS(Self:dDataIni) + "' "
    cQuery +=    " AND HWF.HWF_DATA <= '" + DToS(Self:dDataFim) + "' "
    If !Empty(Self:aCTrabs)
        cQuery += " AND HWF.HWF_CTRAB IN ('" + ArrToKStr(Self:aCTrabs, "','") + "') "
    EndIf
    If !Empty(Self:aRecursos)
        cQuery += " AND HWF.HWF_RECURS IN ('" + ArrToKStr(Self:aRecursos, "','") + "') "
    EndIf
    cQuery +=    " AND HWF.D_E_L_E_T_ = ' ' "

Return cQuery

/*/{Protheus.doc} buscaDetalhes
Retorna as informações para exibição de detalhes do monitor.
@author Lucas Fagundes
@since 17/02/2025
@version P12
@param oFiltros, Object  , Json com os filtros do monitor.
@param nPagina , Numerico, Paginação da tela de detalhes.
@return cDados, Caracter, Json que será enviado com as informações para exibição em tela.
/*/
Method buscaDetalhes(oFiltros, nPagina) Class CRPHorasCapacidade
    Local cDados    := ""
    Local cSerie    := ""
    Local nIndex    := 0
    Local nPageSize := 20
    Local nTotal    := 0
    Local oAux      := Nil
    Local oDados    := JsonObject():New()
    Local oItem     := Nil
    Local oSelf     := CRPHorasCapacidade():New(oFiltros)

    If oFiltros:hasProperty("SERIE")
        cSerie := oFiltros["SERIE"]
    EndIf

    If cSerie == ""
        nPageSize := 5
    EndIf

    oDados["items"       ] := {}
    oDados["columns"     ] := oSelf:getColunasDetalhes()
    oDados["headers"     ] := {}
    oDados["tags"        ] := {}
    oDados["canExportCSV"] := .T.
    oDados["hasNext"     ] := .F.

    If cSerie == "" .Or. cSerie == STR0292 // "Disponibilidade"
        oAux   := oSelf:getHorasDisponibilidade(nPagina, nPageSize)
        nTotal := Len(oAux["items"])

        For nIndex := 1 To nTotal
            oItem := oAux["items"][nIndex]

            oItem["tipo"] := TIPO_DISPONIBILIDADE

            aAdd(oDados["items"], oItem)
        Next

        oDados["hasNext"] := oDados["hasNext"] .Or. oAux["hasNext"]
    EndIf

    If cSerie == "" .Or. cSerie == STR0294 // "Demandas"
        oAux   := oSelf:getHorasDemandas(nPagina, nPageSize)
        nTotal := Len(oAux["items"])

        For nIndex := 1 To nTotal
            oItem := oAux["items"][nIndex]

            oItem["tipo"] := TIPO_DEMANDA

            aAdd(oDados["items"], oItem)
        Next

        oDados["hasNext"] := oDados["hasNext"] .Or. oAux["hasNext"]
    EndIf

    If cSerie == "" .Or. cSerie == STR0296 // "CRP"
        oAux   := oSelf:getHorasCRP(nPagina, nPageSize)
        nTotal := Len(oAux["items"])

        For nIndex := 1 To nTotal
            oItem := oAux["items"][nIndex]

            oItem["tipo"] := TIPO_CRP

            aAdd(oDados["items"], oItem)
        Next

        oDados["hasNext"] := oDados["hasNext"] .Or. oAux["hasNext"]
    EndIf

    oDados["tags"] := oSelf:getTagFiltros()
    cDados := oDados:toJson()

    FwFreeObj(oItem)
    FwFreeObj(oAux)
    FwFreeObj(oDados)
    FwFreeObj(oSelf)
Return cDados

/*/{Protheus.doc} getColunasDetalhes
Retorna as colunas que serão exibidas na tela de detalhes.
@author Lucas Fagundes
@since 17/02/2025
@version P12
@return aColunas, Array, Array com as colunas que serão exibidas na tela de detalhes.
/*/
Method getColunasDetalhes() Class CRPHorasCapacidade
    Local aColunas   := {}
    Local aLabels    := {}
    Local nIndice    := 0
    Local nIndLabels := 0

    PCPMonitorUtils():AdicionaColunaTabela(aColunas, @nIndice, "filial", STR0058, "string", .F.) // "Filial"
    If Self:cSerie == "" .Or. Self:cSerie != STR0292 // "Disponibilidade"
        PCPMonitorUtils():AdicionaColunaTabela(aColunas, @nIndice, "ordemProducao", STR0298, "string", .T.) // "Ordem de produção"
        PCPMonitorUtils():AdicionaColunaTabela(aColunas, @nIndice, "produto"      , STR0074, "string", .T.) // "Produto"
        PCPMonitorUtils():AdicionaColunaTabela(aColunas, @nIndice, "descProduto"  , STR0075, "string", .F.) // "Desc. Produto"
    EndIf
    If Self:cSerie == "" .Or. Self:cSerie == STR0294 // "Demandas"
        PCPMonitorUtils():AdicionaColunaTabela(aColunas, @nIndice, "dataEntrega", STR0305, "string", .T.) // "Data Entrega"
    EndIf
    If Self:cSerie == "" .Or. Self:cSerie != STR0292 // "Disponibilidade"
        PCPMonitorUtils():AdicionaColunaTabela(aColunas, @nIndice, "operacao"    , STR0077, "string", .T.) // "Operação"
        PCPMonitorUtils():AdicionaColunaTabela(aColunas, @nIndice, "descOperacao", STR0078, "string", .F.) // "Desc. Oper"
    EndIf
    PCPMonitorUtils():AdicionaColunaTabela(aColunas, @nIndice, "recurso"    , STR0059, "string", .T.) // "Recurso"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas, @nIndice, "descRecurso", STR0073, "string", .F.) // "Desc. Recurso"
    If Self:cSerie == "" .Or. Self:cSerie != STR0292 // "Disponibilidade"
        PCPMonitorUtils():AdicionaColunaTabela(aColunas, @nIndice, "centroTrab"    , STR0289, "string", .T.) // "Centro de trabalho"
        PCPMonitorUtils():AdicionaColunaTabela(aColunas, @nIndice, "descCentroTrab", STR0306, "string", .F.) // "Desc. Centro de Trabalho"
    EndIf
    If Self:cSerie == "" .Or. Self:cSerie == STR0296 // "CRP"
        PCPMonitorUtils():AdicionaColunaTabela(aColunas, @nIndice, "data", "Data", "string", .T.)
        PCPMonitorUtils():AdicionaColunaTabela(aColunas, @nIndice, "horaInicio", STR0153, "string", .T.) // "Hora inicial"
        PCPMonitorUtils():AdicionaColunaTabela(aColunas, @nIndice, "horaFim"   , STR0155, "string", .T.) // "Hora final"
    EndIf
    PCPMonitorUtils():AdicionaColunaTabela(aColunas, @nIndice, "horas", STR0171, "string", .T.) // "Horas"
    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabels, @nIndLabels, TIPO_DISPONIBILIDADE, COR_VERDE_FORTE   , STR0292, COR_BRANCO) // "Disponibilidade"
    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabels, @nIndLabels, TIPO_DEMANDA        , COR_VERMELHO_FORTE, STR0294, COR_BRANCO) // "Demanda"
    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabels, @nIndLabels, TIPO_CRP            , COR_AMARELO_ESCURO, STR0296, COR_BRANCO) // "CRP"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas, @nIndice, "tipo", STR0146, "cellTemplate", .T., .T., aLabels) // "Tipo"

Return aColunas

/*/{Protheus.doc} getTagFiltros
Retorna as tags dos filtros utilizados na busca.
@author Lucas Fagundes
@since 18/02/2025
@version P12
@return aTags, Array, Array com as tags do filtros.
/*/
Method getTagFiltros() Class CRPHorasCapacidade
    Local aTags   := {}
    Local nPosTag := 0
    Local cValor  := ""
    Local nIndex  := 0
    Local nTotal  := 0

    cValor := DToC(Self:dDataIni) + " - " + DToC(Self:dDataFim)
    PCPMonitorUtils():AdicionaTagMonitor(aTags, @nPosTag, ICONE_CALENDARIO, cValor)

    nTotal := Len(Self:aRecursos)
    For nIndex := 1 To nTotal
        cValor := Self:aRecursos[nIndex]
        PCPMonitorUtils():AdicionaTagMonitor(aTags, @nPosTag, ICONE_RECURSO, cValor)
    Next

    nTotal := Len(Self:aCTrabs)
    For nIndex := 1 To nTotal
        cValor := Self:aCTrabs[nIndex]

        If cValor == " "
            cValor := STR0299 // "Centro de trabalho em branco"
        EndIf

        PCPMonitorUtils():AdicionaTagMonitor(aTags, @nPosTag, ICONE_CTRAB, cValor)
    Next

    If Self:cTipoOP == TIPO_OP_AMBAS
        cValor := STR0300 // "Ambas"

    ElseIf Self:cTipoOP == TIPO_OP_FIRMES
        cValor := STR0301 // "Firmes"

    ElseIf Self:cTipoOP == TIPO_OP_PREVISTAS
        cValor := STR0302 // "Previstas"

    EndIf

    PCPMonitorUtils():AdicionaTagMonitor(aTags, @nPosTag, ICONE_TIPO_OP, cValor)
Return aTags
