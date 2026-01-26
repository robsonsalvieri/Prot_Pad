#INCLUDE "TOTVS.CH"
#INCLUDE "PCPMONITOR.CH"
#INCLUDE "PCPMONITORDEF.CH"

/*/{Protheus.doc} StatusApontamentoHoras
Classe para prover os dados do Monitor de acompanhamento das horas apontadas no recurso
@type Class
@author renan.roeder
@since 08/05/2023
@version P12.1.2310
@return Nil
/*/
Class StatusApontamentoHoras FROM LongNameClass
	Static Method BuscaDados(oFiltros, cTipo, cSubTipo)
	Static Method BuscaDetalhes(oFiltros, nPagina)
	Static Method CargaMonitor()
    Static Method ValidaPropriedades(oFiltros)
EndClass

/*/{Protheus.doc} BuscaDados
Realiza a busca dos dados para o Monitor
@type Method
@author renan.roeder
@since 08/05/2023
@version P12.1.2310
@param  oFiltros, objeto json, Objeto json com os filtros para a consulta dos dados
@param	cTipo   , caracter   , Tipo Monitor chart/info
@param	cSubTipo, caracter   , Tipo do grafico pie/bar/column/line
@return cJson   , caracter   , string json com os dados para retorno
/*/
Method BuscaDados(oFiltros, cTipo, cSubTipo) Class StatusApontamentoHoras
    Local aPeriodos  := PCPMonitorUtils():RetornaListaPeriodosPassado(oFiltros["04_TIPOPERIODO"],cValToChar(oFiltros["05_PERIODO"]))
    Local aProdHr    := {}
    Local aImprodHr  := {}
    Local cRecursos  := ""
    Local dDataIni   := dDatabase
    Local dDataFin   := dDatabase
    Local nIndice    := 0
    Local nPosTag    := 0
    Local nTotCateg  := 0
    Local nTotPrdHr  := 0
    Local nTotImpHr  := 0
    Local oJsonRet   := JsonObject():New()
    Local oJsonTempo := Nil

    oJsonRet["alturaMinimaWidget"] := "350px"
    oJsonRet["alturaMaximaWidget"] := "500px"
    oJsonRet["categorias"] := {}
    oJsonRet["series"]     := {}
    oJsonRet["tags"]       := {}
    oJsonRet["detalhes"]   := {}
    
    oFiltros["01_H6_FILIAL"] := PadR(oFiltros["01_H6_FILIAL"], FWSizeFilial())
    For nIndice := 1 To Len(oFiltros["02_H6_RECURSO"])
        If Empty(cRecursos)
            cRecursos := "'" + oFiltros["02_H6_RECURSO"][nIndice] + "'"
        Else
            cRecursos +=  ",'" + oFiltros["02_H6_RECURSO"][nIndice] + "'"
        EndIf
    Next nIndice
    dDataIni := aPeriodos[Len(aPeriodos)][1]
    dDataFin := aPeriodos[1][2]
    oJsonTempo := PCPMonitorUtils():CalculaTempoApontamentoOperacao(oFiltros["01_H6_FILIAL"],cRecursos,{dDataIni,dDataFin},.T.,oFiltros["04_TIPOPERIODO"],oFiltros["03_FILTRODATA"])
    oJsonRet["categorias"] := oJsonTempo:GetNames()
    nTotCateg := Len(oJsonTempo:GetNames())
    For nIndice := 1 To nTotCateg
        nTotPrdHr += oJsonTempo[oJsonRet["categorias"][nIndice]]["P"]
        nTotImpHr += oJsonTempo[oJsonRet["categorias"][nIndice]]["I"]
        aAdd(aProdHr,PCPMonitorUtils():TransformaMinutosCentesimaisParaTempo(oJsonTempo[oJsonRet["categorias"][nIndice]]["P"],2))
        aAdd(aImprodHr,PCPMonitorUtils():TransformaMinutosCentesimaisParaTempo(oJsonTempo[oJsonRet["categorias"][nIndice]]["I"],2))
    Next nIndice
    nTotPrdHr := PCPMonitorUtils():TransformaMinutosCentesimaisParaTempo(nTotPrdHr,2)
    nTotImpHr := PCPMonitorUtils():TransformaMinutosCentesimaisParaTempo(nTotImpHr,2)

    aAdd(oJsonRet["series"], JsonObject():New())
    oJsonRet["series"][1]["color"]   := COR_VERDE
    oJsonRet["series"][1]["data"]    := aClone(aProdHr)
    oJsonRet["series"][1]["tooltip"] := ""
    oJsonRet["series"][1]["label"]   := STR0105 //"Horas Produtivas"
    aAdd(oJsonRet["series"], JsonObject():New())
    oJsonRet["series"][2]["color"]   := COR_VERMELHO
    oJsonRet["series"][2]["data"]    := aClone(aImprodHr)
    oJsonRet["series"][2]["tooltip"] := ""
    oJsonRet["series"][2]["label"]   := STR0106 //"Horas Improdutivas"

    cTpPerDesc := PCPMonitorUtils():RetornaDescricaoTipoPeriodo(oFiltros["04_TIPOPERIODO"])

    PCPMonitorUtils():AdicionaTagMonitor(oJsonRet["tags"],@nPosTag,"po-icon-calendar",dToC(dDataIni) + " - " + dToC(dDataFin))
    PCPMonitorUtils():AdicionaTagMonitor(oJsonRet["tags"],@nPosTag,"po-icon-calculator",cTpPerDesc)
    PCPMonitorUtils():AdicionaTagMonitor(oJsonRet["tags"],@nPosTag,"po-icon-star",STR0106+": " + cValToChar(nTotImpHr)+" "+STR0054 ) //"Horas Improdutivas" //" horas"
    PCPMonitorUtils():AdicionaTagMonitor(oJsonRet["tags"],@nPosTag,"po-icon-star-filled",STR0105+": "+cValToChar(nTotPrdHr)+" "+STR0054 ) //"Horas Produtivas" ////" horas"
    For nIndice := 1 To Len(oFiltros["02_H6_RECURSO"])
        PCPMonitorUtils():AdicionaTagMonitor(oJsonRet["tags"],@nPosTag,"po-icon-manufacture",oFiltros["02_H6_RECURSO"][nIndice])
    Next nIndice

    FwFreeArray(aPeriodos)
    FwFreeArray(aProdHr)
    FwFreeArray(aImprodHr)
    FreeObj(oJsonTempo)

Return oJsonRet:ToJson()

/*/{Protheus.doc} BuscaDetalhes
Realiza a busca dos dados para montar os detalhes do Monitor
@type Method
@author renan.roeder
@since 08/05/2023
@version P12.1.2310
@param  oFiltros, objeto json, Objeto json com os filtros para a consulta dos dados
@return cJson   , caracter   , string json com os dados para retorno
@return Nil
/*/
Method BuscaDetalhes(oFiltros, nPagina) Class StatusApontamentoHoras
    Local aPeriodos  := {}
    Local cAlias     := GetNextAlias()
    Local cCategoria := ""
    Local cQuery     := ""
    Local cRecursos  := ""
    Local cSerie     := ""
    Local cTempo     := ""
    Local cTpPerDesc := ""
    Local dDataIni   := dDatabase
    Local dDataFin   := dDatabase
    Local lExpResult := .F.
    Local oDados     := JsonObject():New()
    Local nIndice    := 0
    Local nPosCon    := 0
    Local nPosTag    := 0
    Local nStart     := 1
    Local nTamPagina := 20

    Default nPagina := 1

    If nPagina == 0
        lExpResult := .T.
    EndIf
    cCategoria := IIF(oFiltros:HasProperty("CATEGORIA"),oFiltros["CATEGORIA"],"")
    cSerie     :=  IIF(oFiltros:HasProperty("SERIE"),IF(oFiltros["SERIE"] == STR0105,"P","I"),"") //"Horas Produtivas"
    If !Empty(cCategoria)
        dDataIni := cToD(cCategoria)
        dDataFin := PCPMonitorUtils():RetornaPeriodoFinal(oFiltros["04_TIPOPERIODO"],cToD(cCategoria))
        If dDataFin > dDatabase
            dDataFin := dDatabase
        EndIf
    Else
        aPeriodos := PCPMonitorUtils():RetornaListaPeriodosPassado(oFiltros["04_TIPOPERIODO"],cValToChar(oFiltros["05_PERIODO"]))
        dDataIni := aPeriodos[Len(aPeriodos)][1]
        dDataFin := aPeriodos[1][2]
    EndIf
    oFiltros["01_H6_FILIAL"] := PadR(oFiltros["01_H6_FILIAL"], FWSizeFilial())
    For nIndice := 1 To Len(oFiltros["02_H6_RECURSO"])
        If Empty(cRecursos)
            cRecursos := "'" + oFiltros["02_H6_RECURSO"][nIndice] + "'"
        Else
            cRecursos +=  ",'" + oFiltros["02_H6_RECURSO"][nIndice] + "'"
        EndIf
    Next nIndice
    cQuery := " SELECT "
    cQuery += "  SH6.H6_FILIAL,SH6.H6_OP,SH6.H6_PRODUTO,SH6.H6_OPERAC,SH6.H6_RECURSO,SH6.H6_DTAPONT, "
    cQuery += "  SH6.H6_DATAINI,SH6.H6_HORAINI,SH6.H6_DATAFIN,SH6.H6_HORAFIN,SH6.H6_TEMPO,SH6.H6_QTDPROD, "
    cQuery += "  SH6.H6_QTDPERD,SH6.H6_TIPO,SH6.H6_TIPOTEM, "
    cQuery += "  SB1.B1_DESC, SB1.B1_OPERPAD, SC2.C2_ROTEIRO "
    cQuery += " FROM "+RetSqlName("SH6")+" SH6 "
    cQuery += " LEFT JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1",oFiltros["01_H6_FILIAL"])+"' AND SB1.B1_COD = SH6.H6_PRODUTO AND SB1.D_E_L_E_T_ = ' ' "
    cQuery += " LEFT JOIN "+RetSqlName("SC2")+" SC2 ON SC2.C2_FILIAL = '"+xFilial("SC2",oFiltros["01_H6_FILIAL"])+"' AND SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN||SC2.C2_ITEMGRD = SH6.H6_OP AND SC2.D_E_L_E_T_ = ' ' "
    cQuery += " WHERE SH6.D_E_L_E_T_ = ' ' "
    cQuery += "   AND SH6.H6_FILIAL = '" + xFilial("SH6",oFiltros["01_H6_FILIAL"]) + "' "
    cQuery += "   AND SH6.H6_RECURSO IN ("+cRecursos+") "
    cQuery += "   AND (SH6."+AllTrim(oFiltros["03_FILTRODATA"])+" >= '"+dToS(dDataIni)+"' AND SH6."+AllTrim(oFiltros["03_FILTRODATA"])+" <= '"+dToS(dDataFin)+"') "
    If !Empty(cSerie)
        cQuery += "AND SH6.H6_TIPO = '" + cSerie + "' "
    EndIf
    cQuery += " ORDER BY SH6.H6_FILIAL,SH6.H6_RECURSO,SH6."+AllTrim(oFiltros["03_FILTRODATA"])+" "
    cQuery := ChangeQuery(cQuery)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)
    If nPagina > 1
		nStart := ( (nPagina-1) * nTamPagina )
		If nStart > 0
			(cAlias)->(DbSkip(nStart))
		EndIf
	EndIf
    cTpPerDesc := PCPMonitorUtils():RetornaDescricaoTipoPeriodo(oFiltros["04_TIPOPERIODO"])
    oDados["items"]   := {}
    oDados["columns"] := bscColunas(lExpResult,oFiltros["03_FILTRODATA"])
    oDados["canExportCSV"] := .T.
    oDados["tags"]    := {}

    While (cAlias)->(!Eof())
        aAdd(oDados["items"], JsonObject():New())
        nPosCon++
        cRoteiro := IIF(!Empty((cAlias)->C2_ROTEIRO),(cAlias)->C2_ROTEIRO,IIF(!Empty((cAlias)->B1_OPERPAD),(cAlias)->B1_OPERPAD,"01"))
        cTempo := cValToChar(Val(StrTran(IIF((cAlias)->H6_TIPOTEM == 1,A680ConvHora((cAlias)->H6_TEMPO,"N","C"),(cAlias)->H6_TEMPO),":",".")))
        oDados["items"][nPosCon]["H6_FILIAL"]  := (cAlias)->H6_FILIAL
        oDados["items"][nPosCon]["H6_OP"]      := (cAlias)->H6_OP
        oDados["items"][nPosCon]["H6_PRODUTO"] := (cAlias)->H6_PRODUTO
        oDados["items"][nPosCon]["B1_DESC"]    := (cAlias)->B1_DESC
        oDados["items"][nPosCon]["H6_OPERAC"]  := (cAlias)->H6_OPERAC
        oDados["items"][nPosCon]["G2_DESCRI"]  := AllTrim(Posicione("SG2",1,xFilial("SG2",oFiltros["01_H6_FILIAL"])+(cAlias)->H6_PRODUTO+cRoteiro+(cAlias)->H6_OPERAC,"G2_DESCRI"))
        oDados["items"][nPosCon]["H6_RECURSO"] := (cAlias)->H6_RECURSO
        oDados["items"][nPosCon]["H1_DESCRI"]  := PCPMonitorUtils():RetornaDescricaoRecurso(oFiltros["01_H6_FILIAL"],(cAlias)->H6_RECURSO)
        oDados["items"][nPosCon]["H6_DTAPONT"] := PCPMonitorUtils():FormataData((cAlias)->H6_DTAPONT,4)
        oDados["items"][nPosCon]["H6_DATAINI"] := PCPMonitorUtils():FormataData((cAlias)->H6_DATAINI,4)
        oDados["items"][nPosCon]["H6_HORAINI"] := (cAlias)->H6_HORAINI
        oDados["items"][nPosCon]["H6_DATAFIN"] := PCPMonitorUtils():FormataData((cAlias)->H6_DATAFIN,4)
        oDados["items"][nPosCon]["H6_HORAFIN"] := (cAlias)->H6_HORAFIN
        oDados["items"][nPosCon]["H6_TEMPO"]   := cTempo
        oDados["items"][nPosCon]["H6_QTDPROD"] := (cAlias)->H6_QTDPROD
        oDados["items"][nPosCon]["H6_QTDPERD"] := (cAlias)->H6_QTDPERD
        oDados["items"][nPosCon]["H6_TIPO"]    := (cAlias)->H6_TIPO
        (cAlias)->(dbSkip())
        If !lExpResult .And. nPosCon >= nTamPagina
            Exit
        EndIf
    End
    oDados["hasNext"] := (cAlias)->(!Eof())
    (cAlias)->(dbCloseArea())


    PCPMonitorUtils():AdicionaTagMonitor(oDados["tags"],@nPosTag,"po-icon-calendar",dToC(dDataIni) + " - " + dToC(dDataFin))
    If Empty(cCategoria)
       PCPMonitorUtils():AdicionaTagMonitor(oDados["tags"],@nPosTag,"po-icon-calculator",cTpPerDesc)
    EndIf
    For nIndice := 1 To Len(oFiltros["02_H6_RECURSO"])
        PCPMonitorUtils():AdicionaTagMonitor(oDados["tags"],@nPosTag,"po-icon-manufacture",oFiltros["02_H6_RECURSO"][nIndice])
    Next nIndice

    FwFreeArray(aPeriodos)
Return oDados:ToJson()

/*/{Protheus.doc} CargaMonitor
Realiza a carga do Monitor padrão na base de dados
@type Method
@author renan.roeder
@since 08/05/2023
@version P12.1.2310
@return lRet, logico, Indica se conseguiu realizar a carga
/*/
Method CargaMonitor() Class StatusApontamentoHoras
    Local aCategr   := {}
    Local aDetalhes := {}
    Local aTags     := {}
    Local lRet      := .T.
    Local nPosTag   := 0
    Local oCarga    := PCPMonitorCarga():New()
    Local oPrmAdc   := JsonObject():New()
    Local oSeries   := JsonObject():New()
        
    If !PCPMonitorCarga():monitorAtualizado("StatusApontamentoHoras")
        oSeries["Horas Produtivas"]   := {{5,6.75,8.5,6,7.5,8}, COR_VERDE }
        oSeries["Horas Improdutivas"] := {{2,3.5,1.75,1,0,1}, COR_VERMELHO }
        aCategr := {"16/04/23","23/04/23","30/04/23","07/05/23","14/05/23","21/05/23"}

        PCPMonitorUtils():AdicionaTagMonitor(aTags,@nPosTag,"po-icon-calendar","16/04/2023 - 28/05/2023")
        PCPMonitorUtils():AdicionaTagMonitor(aTags,@nPosTag,"po-icon-calculator",STR0088) //"Semanal"
        PCPMonitorUtils():AdicionaTagMonitor(aTags,@nPosTag,"po-icon-star",STR0106+": 54 "+STR0054) //"Horas Improdutivas" //" horas"
        PCPMonitorUtils():AdicionaTagMonitor(aTags,@nPosTag,"po-icon-star-filled",STR0105+": 54 "+STR0054) //"Horas Produtivas" ////" horas"
        PCPMonitorUtils():AdicionaTagMonitor(aTags,@nPosTag,"po-icon-manufacture","GUIL01")

        oCarga:setaTitulo(STR0108) //"Acomp. Horas Apontadas"
        oCarga:setaObjetivo(STR0109) //"Acompanhar a quantidade de horas apontadas no recurso em uma linha do tempo conforme o tipo de período parametrizado."
        oCarga:setaAgrupador("PCP")
        oCarga:setaFuncaoNegocio("StatusApontamentoHoras")
        oCarga:setaTiposPermitidos("chart")
        oCarga:setaTiposGraficoPermitidos("line;column;bar")
        oCarga:setaTipoPadrao("chart")
        oCarga:setaTipoGraficoPadrao("line")
        oCarga:setaTipoDetalhe("detalhe")
        oCarga:setaExemploJsonGrafico(oSeries, aTags, aDetalhes,aCategr,"line")
        
        oCarga:setaPropriedadeFilial("01_H6_FILIAL") 
        oCarga:setaPropriedadeRecurso("02_H6_RECURSO",.T.)
        
        oPrmAdc["03_FILTRODATA"]           := JsonObject():New()
        oPrmAdc["03_FILTRODATA"]["opcoes"] := STR0192+":H6_DATAINI;"+STR0154+":H6_DATAFIN;"+STR0193+":H6_DTAPONT" //"Data Início:H6_DATAINI;Data Final:H6_DATAFIN;Data Apontamento:H6_DTAPONT"
        oCarga:setaPropriedade("03_FILTRODATA","H6_DATAINI",STR0061,4,,,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,oPrmAdc["03_FILTRODATA"]) //"Data de referência"
        
        oCarga:setaPropriedadePeriodoLinhaTempo("04_TIPOPERIODO","D","05_PERIODO")
        
        If !oCarga:gravaMonitorPropriedades()
            lRet := .F.
        EndIf
        oCarga:Destroy()
    EndIf
    FwFreeArray(aCategr)
    FwFreeArray(aDetalhes)
    FwFreeArray(aTags)
    FreeObj(oPrmAdc)
    FreeObj(oSeries)
Return lRet

/*/{Protheus.doc} ValidaPropriedades
Valida os dados informados nas propriedades do Monitor
@type Method
@author renan.roeder
@since 08/05/2023
@version P12.1.2310
@param  oFiltros, objeto json, Objeto json com os filtros para a consulta dos dados
@return aRetorno, array      , [1] logico - indica se os dados são válidos [2] caracter - mensagem de erro
/*/
Method ValidaPropriedades(oFiltros) Class StatusApontamentoHoras
    Local aRetorno := {.T.,""}

    PCPMonitorUtils():ValidaPropriedadeFilial(oFiltros["01_H6_FILIAL"],aRetorno)

    If aRetorno[1] .And. Empty(oFiltros["02_H6_RECURSO"])
        aRetorno[1] := .F.
        aRetorno[2] := STR0067 //"O filtro de Recurso deve ser preenchido."
    Else
        If aRetorno[1]
            SH1->(dbSetOrder(1))
			If !SH1->(dbSeek(xFilial("SH1",PadR(oFiltros["01_H6_FILIAL"], FWSizeFilial())) + PadR(oFiltros["02_H6_RECURSO"][1],GetSx3Cache("H6_RECURSO","X3_TAMANHO")), .F.))
                aRetorno[1] := .F.
                aRetorno[2] := STR0068 //"O Recurso não existe na Filial informada."
            EndIf
        EndIf
    EndIf
    If aRetorno[1] .And. Empty(oFiltros["05_PERIODO"])
        aRetorno[1] := .F.
        aRetorno[2] := STR0194 //"Deve ser informada a quantidade de períodos que será visualizada."
    EndIf
Return aRetorno

/*/{Protheus.doc} bscColunas
Cria array de objetos no formato poTableColumn com as colunas da table de detalhamento
@type Static Function
@author renan.roeder
@since 08/05/2023
@version P12.1.2310
@param  lExpResult, logico  , Indica se trata todas as colunas como visible
@param  cDataRef  , caracter, Data usada como referência para a consulta
@return aColunas  , array   , Array de objetos com as colunas da table po-ui
/*/
Static Function bscColunas(lExpResult,cDataRef)
    Local aColunas   := {}
    Local aLabels    := {}
    Local nIndice    := 0
    Local nIndLabels := 0

    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H6_FILIAL" ,STR0058,"string",lExpResult) 
    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabels,@nIndLabels,"I",COR_VERMELHO,STR0071,COR_BRANCO) //"Improdutivo"
    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabels,@nIndLabels,"P",COR_VERDE,STR0072,COR_BRANCO) //"Produtivo"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H6_TIPO",STR0070,"cellTemplate",.T.,.T.,aLabels) //"Tp Apon"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H6_RECURSO" ,STR0059,"string",.T.)  //"Recurso"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H1_DESCRI" ,STR0073,"string",lExpResult) //"Desc. Recurso"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H6_OP" ,STR0076,"string",.T.) //"OP"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H6_PRODUTO" ,STR0074,"string",.T.) //"Produto"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"B1_DESC" ,STR0075,"string",lExpResult) //"Desc. Produto"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H6_OPERAC" ,STR0077,"string",.T.) //"Operação"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"G2_DESCRI" ,STR0078,"string",lExpResult) //"Desc. Oper"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H6_TEMPO" ,STR0079,"string",.T.) //"Tempo"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H6_DTAPONT" ,STR0080,"date", IIF(lExpResult .Or. cDataRef == aColunas[nIndice]["property"],.T.,.F.))  //"Dt Apont"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H6_DATAINI" ,STR0081,"date",IIF(lExpResult .Or. cDataRef == aColunas[nIndice]["property"],.T.,.F.))  //"Dt Ini"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H6_HORAINI" ,STR0082,"string",lExpResult) //"Hora Ini"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H6_DATAFIN" ,STR0083,"date",IIF(lExpResult .Or. cDataRef == aColunas[nIndice]["property"],.T.,.F.)) //"Dt Fin"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H6_HORAFIN" ,STR0084,"string",lExpResult) //"Hora Fin"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H6_QTDPROD" ,STR0085,"number",lExpResult) //"Qtd. Prod"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H6_QTDPERD" ,STR0086,"number",lExpResult) //"Qtd. Perda"

Return aColunas
