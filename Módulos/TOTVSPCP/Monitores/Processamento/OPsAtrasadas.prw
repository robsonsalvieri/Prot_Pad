#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PCPMONITOR.ch"
#INCLUDE "PCPMONITORDEF.ch"

/*/{Protheus.doc} OPsAtrasadas
Classe para prover os dados do Monitor de Ordens de Produção atrasadas, de acordo com sua previsão de entrega
@type Class
@author douglas.heydt
@since 30/06/2023
@version P12.1.2310
@return Nil
/*/
Class OPsAtrasadas FROM LongNameClass
    Static Method CargaMonitor()
    Static Method BuscaDados(oFiltros, cTipo, cSubTipo)
    Static Method BuscaDetalhes(oFiltros, nPagina)
    Static Method ValidaPropriedades(oFiltros)
EndClass

/*/{Protheus.doc} CargaMonitor
Realiza a carga do Monitor padrão na base de dados
@type Method
@author douglas.heydt
@since 30/06/2023
@version P12.1.2310
@return lRet, logico, Indica se conseguiu realizar a carga
/*/
Method CargaMonitor() Class OPsAtrasadas
    Local aDetalhes   := {}
    Local aTags       := {}
    Local lRet        := .T.
    Local nIndTag     := 0
    Local oCarga      := PCPMonitorCarga():New()
    Local oSeries     := JsonObject():New()    
    Local oPrmAdc     := JsonObject():New()
        
    If !PCPMonitorCarga():monitorAtualizado("OPsAtrasadas")

        oSeries["UN"] := {{10, 20, 5}, COR_VERMELHO_FORTE }

        PCPMonitorUtils():AdicionaTagMonitor(aTags,@nIndTag,"po-icon-calendar","01/02/2023 - 28/03/2023")
        PCPMonitorUtils():AdicionaTagMonitor(aTags,@nIndTag,"po-icon-calculator",PCPMonitorUtils():RetornaDescricaoTipoPeriodo("D"))
        PCPMonitorUtils():AdicionaTagMonitor(aTags,@nIndTag,"po-icon-bar-code","TUBO_CANETA")
        PCPMonitorUtils():AdicionaTagMonitor(aTags,@nIndTag,"po-icon-star-filled","3 "+STR0203) //"Ordens"
        PCPMonitorUtils():AdicionaTagMonitor(aTags,@nIndTag,"po-icon-star-filled","35 UN")
       
        oCarga:setaTitulo(STR0220) //"Acomp. OPs em Atraso"
        oCarga:setaObjetivo(STR0227) //"Apresentar um gráfico contendo o saldo a produzir das ordens de produção em atraso de um determinado produto, com base na data de entrega prevista, para um número de períodos configurado."
        oCarga:setaAgrupador("PCP")
        oCarga:setaFuncaoNegocio("OPsAtrasadas")
        oCarga:setaTiposPermitidos("chart")
        oCarga:setaTiposGraficoPermitidos("column;bar;line")
        oCarga:setaTipoPadrao("chart")
        oCarga:setaTipoGraficoPadrao("line")
        oCarga:setaTipoDetalhe("detalhe")
        oCarga:setaExemploJsonGrafico(oSeries,aTags,aDetalhes,{"20/02/23","13/03/23","25/03/23"},"line")
        oCarga:setaPropriedadeFilial("01_C2_FILIAL")
        oCarga:setaPropriedadeProduto("02_C2_PRODUTO",.F.)
        oCarga:setaPropriedadePeriodoLinhaTempo("03_TIPOPERIODO","D","04_PERIODO")
        
        If !oCarga:gravaMonitorPropriedades()
            lRet := .F.
        EndIf
        oCarga:Destroy()
    EndIf

    FwFreeArray(aTags)
    FwFreeArray(aDetalhes)
    FreeObj(oSeries)
    FreeObj(oPrmAdc)
Return lRet

/*/{Protheus.doc} BuscaDados
Responsável por realizar a busca dos dados que serão exibidos no monitor (gráfico ou texto)

@type Class
@author douglas.heydt
@since 30/06/2023
@version P12.1.2310
@param	oFiltros  , objeto Json, Contém as propriedades do monitor usadas para filtrar a query de busca
@param	cTipo     , caracter   , Tipo chart/info
@param	cSubTipo  , caracter   , Tipo de grafico pie/bar/column
@return cJsonDados, caracter   , Retorna um novo Json em formato texto, pronto para conversão e exibição no front
/*/
Method BuscaDados(oFiltros, cTipo, cSubTipo) Class OPsAtrasadas
    Local aSaldos    := {}
    Local aPeriodos  := PCPMonitorUtils():RetornaListaPeriodosPassado(oFiltros["03_TIPOPERIODO"],cValToChar(oFiltros["04_PERIODO"]))
    Local aChaves    := {}
    Local cAliasQry  := GetNextAlias()
    Local cJsonDados := ""
    Local cUnMed     := ""
    Local cQuery     := ""
    Local dDataAjust := Nil
    Local dDataIni   := dDatabase
    Local dDataFin   := dDatabase
    Local lPerdInf := SuperGetMV("MV_PERDINF",.F.,.F.)
    Local nOPsTotal  := 0
    Local nQtPTotal  := 0
    Local nPosTag    := 0
    Local nX         := 0
    Local oJsonRet   := JsonObject():New()
    Local oPeriods   := JsonObject():New()
    
    oJsonRet["alturaMinimaWidget"] := "350px"
    oJsonRet["alturaMaximaWidget"] := "500px"
    oJsonRet["tags"]               := {}
    oJsonRet["series"]             := {}

    oFiltros["01_C2_FILIAL"] := PadR(oFiltros["01_C2_FILIAL"], FWSizeFilial())
    cUnMed := Posicione("SB1",1,xFilial("SB1",oFiltros["01_C2_FILIAL"])+oFiltros["02_C2_PRODUTO"],"B1_UM")
    dDataIni := aPeriodos[Len(aPeriodos)][1]
    dDataFin := aPeriodos[1][2]

    cQuery := " SELECT "
    cQuery +=        " SC2.C2_FILIAL, "
    cQuery +=        " SC2.C2_PRODUTO, "
    cQuery +=        " SC2.C2_DATPRF, "
        cQuery +=    " SUM(SC2.C2_QUANT - SC2.C2_QUJE" 
        If !lPerdInf
            cQuery +=    " - SC2.C2_PERDA"
        EndIf
        cQuery +=    ")"
    cQuery +=        " AS QUANTIDADE_PRODUTO, "
    cQuery +=        " COUNT(*) AS NUMERO_OPS "
    cQuery +=   " FROM "+RetSqlName("SC2")+" SC2 "
    cQuery +=  " WHERE SC2.C2_FILIAL = '"+xFilial("SC2",oFiltros["01_C2_FILIAL"])+"' "
    cQuery +=    " AND SC2.C2_PRODUTO = '"+oFiltros["02_C2_PRODUTO"]+"' "
    cQuery +=    " AND SC2.C2_DATPRF >= '"+dToS(dDataIni)+"' AND SC2.C2_DATPRF < '"+dToS(dDataFin)+"' "
    cQuery +=    " AND SC2.C2_DATRF = ' '"
    cQuery +=    " AND SC2.D_E_L_E_T_ = ' ' "
    cQuery +=  " GROUP BY SC2.C2_FILIAL, SC2.C2_PRODUTO, SC2.C2_DATPRF "
    cQuery +=  " ORDER BY SC2.C2_FILIAL, SC2.C2_PRODUTO, SC2.C2_DATPRF "

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)
   
    WHile (cAliasQry)->(!Eof())
        dDataAjust := dToC(PCPMonitorUtils():RetornaPeriodoInicial(oFiltros["03_TIPOPERIODO"],sToD((cAliasQry)->C2_DATPRF)))
        nOPsTotal   += (cAliasQry)->NUMERO_OPS
        nQtPTotal   += (cAliasQry)->QUANTIDADE_PRODUTO
        If oPeriods:HasProperty(dDataAjust) 
            oPeriods[dDataAjust] += (cAliasQry)->QUANTIDADE_PRODUTO
        Else
            oPeriods[dDataAjust] := (cAliasQry)->QUANTIDADE_PRODUTO
        EndIf
        (cAliasQry)->(DBSKIP())
    End
    (cAliasQry)->(dbCloseArea())

    aChaves := oPeriods:GetNames()

    For nX := 1 To Len(aChaves)
        aAdd(aSaldos, oPeriods[aChaves[nX]])
    Next nX

    aAdd(oJsonRet["series"], JsonObject():New())
    oJsonRet["series"][1]["color"]   := COR_VERMELHO_FORTE
    oJsonRet["series"][1]["data"]    := aSaldos
    oJsonRet["series"][1]["label"]   := cUnMed
    oJsonRet["categorias"] := aChaves

    PCPMonitorUtils():AdicionaTagMonitor(oJsonRet["tags"],@nPosTag,"po-icon-calendar",dToC(dDataIni) + " - " + dToC(dDataFin))
    PCPMonitorUtils():AdicionaTagMonitor(oJsonRet["tags"],@nPosTag,"po-icon-calculator",PCPMonitorUtils():RetornaDescricaoTipoPeriodo(oFiltros["03_TIPOPERIODO"]))
    PCPMonitorUtils():AdicionaTagMonitor(oJsonRet["tags"],@nPosTag,"po-icon-bar-code",oFiltros["02_C2_PRODUTO"])
    PCPMonitorUtils():AdicionaTagMonitor(oJsonRet["tags"],@nPosTag,"po-icon-star-filled",cValToChar(nOPsTotal) + IIF(nOPsTotal > 1," "+STR0203," "+STR0189) ) //"Ordens"  "Ordem"
    PCPMonitorUtils():AdicionaTagMonitor(oJsonRet["tags"],@nPosTag,"po-icon-star-filled",cValToChar(nQtPTotal) + " " + cUnMed )

    cJsonDados :=  oJsonRet:toJson()

    FwFreeArray(aChaves)
    FwFreeArray(aPeriodos)
    FwFreeArray(aSaldos)
    FreeObj(oPeriods)
    FreeObj(oJsonRet)
Return cJsonDados

/*/{Protheus.doc} BuscaDetalhes
Realiza a busca dos dados para montar os detalhes do Monitor
@type Method
@author douglas.heydt
@since 30/06/2023
@version P12.1.2310
@param	oFiltros  , objeto Json , Contém as propriedades do monitor usadas para filtrar a query de busca
@param	nPagina   , numerico    , Número da página desejada para busca
@return cJsonDados, caracter    , Retorna um novo Json em formato texto, pronto para conversão e exibição no front
@return Nil
/*/
Method BuscaDetalhes(oFiltros,nPagina) Class OPsAtrasadas
    Local aPeriodos  := PCPMonitorUtils():RetornaListaPeriodosFuturo(oFiltros["03_TIPOPERIODO"],cValToChar(oFiltros["04_PERIODO"]))
    Local cAliasQry  := GetNextAlias()
    Local cCategoria := IIF(oFiltros:HasProperty("CATEGORIA"),oFiltros["CATEGORIA"],"")
    Local cOp        := ""
    Local cQuery     := ""
    Local dDataIni   := Nil
    Local dDataFin   := Nil
    Local lExpResult := .F.
    Local nPos       := 0
    Local nPosTag    := 0
    Local nStart     := 1
    Local nTamPagina := 20
    Local oDados     := JsonObject():New()

    Default nPagina := 1

    If nPagina == 0
        lExpResult := .T.
    EndIf

    oFiltros["01_C2_FILIAL"] := PadR(oFiltros["01_C2_FILIAL"], FWSizeFilial())
    If !Empty(cCategoria)
        dDataIni := cToD(cCategoria)
        dDataFin := PCPMonitorUtils():RetornaPeriodoFinal(oFiltros["03_TIPOPERIODO"],cToD(cCategoria))
        If dDataFin > dDatabase
            dDataFin := dDatabase
        EndIf
    Else
        aPeriodos := PCPMonitorUtils():RetornaListaPeriodosPassado(oFiltros["03_TIPOPERIODO"],cValToChar(oFiltros["04_PERIODO"]))
        dDataIni := aPeriodos[Len(aPeriodos)][1]
        dDataFin := aPeriodos[1][2]
    EndIf

    oDados["items"]        := {}
    oDados["columns"]      := montaColun(lExpResult)
    oDados["canExportCSV"] := .T.
    oDados["tags"]         := {}

    cQuery += " SELECT "
    cQuery +=        " SC2.C2_FILIAL, SC2.C2_NUM, SC2.C2_ITEM, SC2.C2_SEQUEN, SC2.C2_ITEMGRD, SC2.C2_OP, SC2.C2_PRODUTO, "
    cQuery +=        " SB1.B1_DESC, SC2.C2_LOCAL, SC2.C2_DATPRI, SC2.C2_DATPRF, SC2.C2_QUANT, SC2.C2_QUJE, SC2.C2_PERDA, SB1.B1_UM "
    cQuery +=   " FROM "+RetSqlName("SC2")+" SC2 "
    cQuery +=   " LEFT JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1",oFiltros["01_C2_FILIAL"])+"' AND SB1.B1_COD = SC2.C2_PRODUTO AND SB1.D_E_L_E_T_ = ' ' "
    cQuery +=  " WHERE SC2.C2_FILIAL = '"+xFilial("SC2",oFiltros["01_C2_FILIAL"])+"' AND SC2.C2_PRODUTO = '"+oFiltros["02_C2_PRODUTO"]+"' "
    cQuery +=    " AND SC2.C2_DATPRF >= '"+dToS(dDataIni)+"' AND SC2.C2_DATPRF <"+Iif(dDataIni == dDataFin .Or. dDataFin < dDatabase, "=", "")+" '"+dToS(dDataFin)+"' "
    cQuery +=    " AND SC2.C2_DATRF = ' ' "
    cQuery +=    " AND SC2.D_E_L_E_T_  = ' ' "
    cQuery += " ORDER BY SC2.C2_FILIAL, SC2.C2_DATPRF, SC2.C2_NUM, SC2.C2_ITEM, SC2.C2_SEQUEN, SC2.C2_ITEMGRD "

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

    If nPagina > 1
		nStart := ( (nPagina-1) * nTamPagina )
		If nStart > 0
			(cAliasQry)->(DbSkip(nStart))
		EndIf
	EndIf

    While (cAliasQry)->(!Eof())
        cOp := (cAliasQry)->C2_NUM+(cAliasQry)->C2_ITEM+(cAliasQry)->C2_SEQUEN+(cAliasQry)->C2_ITEMGRD

        aAdd(oDados["items"], JsonObject():New())
        nPos++
        oDados["items"][nPos]["C2_FILIAL"]  := (cAliasQry)->C2_FILIAL
        oDados["items"][nPos]["C2_OP"]      := Iif(!Empty((cAliasQry)->C2_OP), (cAliasQry)->C2_OP, cOp)
        oDados["items"][nPos]["C2_PRODUTO"] := (cAliasQry)->C2_PRODUTO
        oDados["items"][nPos]["B1_DESC"]    := (cAliasQry)->B1_DESC
        oDados["items"][nPos]["C2_LOCAL"]   := (cAliasQry)->C2_LOCAL
        oDados["items"][nPos]["C2_DATPRI"]  := PCPMonitorUtils():FormataData((cAliasQry)->C2_DATPRI, 5)
        oDados["items"][nPos]["C2_DATPRF"]  := PCPMonitorUtils():FormataData((cAliasQry)->C2_DATPRF, 5)
        oDados["items"][nPos]["C2_QUANT"]   := (cAliasQry)->C2_QUANT
        oDados["items"][nPos]["C2_QUJE"]    := (cAliasQry)->C2_QUJE
        oDados["items"][nPos]["C2_PERDA"]   := (cAliasQry)->C2_PERDA
        oDados["items"][nPos]["B1_UM"]      := (cAliasQry)->B1_UM
        (cAliasQry)->(dbSkip())
        If !lExpResult .And. nPos >= nTamPagina
            Exit
        EndIf
    End
    oDados["hasNext"] := (cAliasQry)->(!Eof())
    (cAliasQry)->(dbCloseArea())    


    PCPMonitorUtils():AdicionaTagMonitor(oDados["tags"],@nPosTag,"po-icon-calendar",dToC(dDataIni) + " - " + dToC(dDataFin))
    If Empty(cCategoria)
        PCPMonitorUtils():AdicionaTagMonitor(oDados["tags"],@nPosTag,"po-icon-calculator",PCPMonitorUtils():RetornaDescricaoTipoPeriodo(oFiltros["03_TIPOPERIODO"]))
    EndIf
    PCPMonitorUtils():AdicionaTagMonitor(oDados["tags"],@nPosTag,"po-icon-bar-code",oFiltros["02_C2_PRODUTO"])

    FwFreeArray(aPeriodos)

Return oDados:ToJson()

/*/{Protheus.doc} ValidaPropriedades
Valida os dados informados nas propriedades do Monitor
@type Method
@author douglas.heydt
@since 30/06/2023
@version P12.1.2310
@param  oFiltros, objeto json, Objeto json com os filtros para a consulta dos dados
@return aRetorno, array      , [1] logico - indica se os dados são válidos [2] caracter - mensagem de erro
/*/
Method ValidaPropriedades(oFiltros) Class OPsAtrasadas
   Local aRetorno  := {.T.,""}

    PCPMonitorUtils():ValidaPropriedadeFilial(oFiltros["01_C2_FILIAL"],aRetorno)

    If aRetorno[1] .And. Empty(oFiltros["02_C2_PRODUTO"])
        aRetorno[1] := .F.
        aRetorno[2] := STR0117 //"O produto deve ser informado."
    EndIf

    If aRetorno[1] .And. (!oFiltros:HasProperty("04_PERIODO") .Or. oFiltros["04_PERIODO"] == Nil .Or. Empty(oFiltros["04_PERIODO"]))
        aRetorno[1] := .F.
        aRetorno[2] := STR0127 //"Deve ser informada a quantidade de períodos."
    EndIf

Return aRetorno


/*/{Protheus.doc} montaColun
Realiza a criação de objeto Json que define as colunas utilizadas na grid de detalhamento do monitor
@type Static Function
@author douglas.heydt
@since 30/06/2023
@version P12.1.2310
@param  lExpResult, logico, Indica se trata todas as colunas como visible
@return aColunas, array objetos, Contém as definições das colunas da grid do monitor
/*/
Static Function montaColun(lExpResult)
    Local aColunas   := {}
    Local nIndice    := 0

    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"C2_FILIAL" ,STR0058,"string",lExpResult) //"Filial"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"C2_OP"     ,STR0076,"string",.T.) //"OP"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"C2_PRODUTO",STR0074,"string",.T.) //"Produto"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"B1_DESC"   ,STR0075,"string",lExpResult) //"Desc. Produto"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"C2_LOCAL"  ,STR0095,"string",.T.) //"Armazém"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"C2_DATPRI" ,STR0138,"string",.T.) //"Previsão Início"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"C2_DATPRF" ,STR0097,"string",.T.) //"Previsão Entrega"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"C2_QUANT"  ,STR0226,"string",.T.) //"Quant Original"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"C2_QUJE"   ,STR0085,"string",.T.) //"Qtd. Prod"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"C2_PERDA"  ,STR0086,"string",.T.) //"Qtd. Perda"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"B1_UM"     ,STR0180,"string",lExpResult) //"Un. Medida"

Return aColunas
