#INCLUDE "TOTVS.CH"
#INCLUDE "PCPMONITOR.CH"
#INCLUDE "PCPMONITORDEF.CH"

/*/{Protheus.doc} ProducaoCapacidadeRecurso
Classe para prover os dados do Monitor de acompanhamento do percentual de utilização do recurso com produção
@type Class
@author renan.roeder
@since 24/05/2023
@version P12.1.2310
@return Nil
/*/
Class ProducaoCapacidadeRecurso FROM LongNameClass
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
Method BuscaDados(oFiltros, cTipo, cSubTipo) Class ProducaoCapacidadeRecurso
    Local aNiveis    := {}
    Local cCodRecur  := ""
    Local dDataFin   := dDatabase
    Local dDataIni   := dDatabase
    Local nGaugeVal  := 0
    Local nHrDispRec := 0
    Local nHrProd    := 0
    Local nPosTag    := 0
    Local oGauge     := PCPMonitorGauge():New()
    Local oJsonCalc  := Nil
    Local oJsonRet   := JsonObject():New()

    oFiltros["01_H6_FILIAL"] := PadR(oFiltros["01_H6_FILIAL"], FWSizeFilial())
    cCodRecur  := AllTrim(oFiltros["02_H6_RECURSO"])
    aNiveis    := StrTokArr(Replace(oFiltros["03_NIVEIS"],",","."),";")
    dDataFin   := dDatabase
    dDataIni   := PCPMonitorUtils():RetornaPeriodoInicial(AllTrim(oFiltros["05_TIPOPERIODO"]),dDataFin,cValToChar(oFiltros["06_PERIODO"]))
    oJsonCalc  := PCPMonitorUtils():CalculaTempoApontamentoOperacao(oFiltros["01_H6_FILIAL"],"'"+cCodRecur+"'",{dDataIni,dDataFin},.F.,,oFiltros["04_FILTRODATA"])
    nHrProd    := PCPMonitorUtils():TransformaMinutosCentesimaisParaTempo(oJsonCalc[dToC(dDatabase)]["P"],2)
    nHrDispRec := Val(StrTran(A680ConvHora(PCPA152Disponibilidade():buscaHorasRecurso(cCodRecur,dDataIni,dDataFin)["totalHoras"],"N","C"),":","."))
    nGaugeVal  := Round((nHrProd / nHrDispRec) * 100,2)

    oJsonRet["alturaMinimaWidget"] := "350px"
    oJsonRet["alturaMaximaWidget"] := "500px"
    oJsonRet["categorias"] := {}
    oJsonRet["series"]     := {}
    oJsonRet["tags"]       := {}
    oJsonRet["detalhes"]   := {}
    oGauge:SetValue(nGaugeVal)
    oGauge:SetValueStyle("color",IIF(nGaugeVal > Val(aNiveis[1]),COR_VERDE_FORTE,IIF(nGaugeVal > Val(aNiveis[2]),COR_AMARELO_QUEIMADO,COR_VERMELHO_FORTE)))
    oGauge:SetValueStyle("font-weight","bold")
    oGauge:SetLabel(STR0100) //"% Utilização"
    oGauge:SetLabelStyle("font-weight","bold")
    oGauge:SetThreshold("0",COR_VERMELHO_FORTE)
    oGauge:SetThreshold(aNiveis[2],COR_AMARELO_QUEIMADO)
    oGauge:SetThreshold(aNiveis[1],COR_VERDE_FORTE)
    If Val(aNiveis[2]) > 0
        oGauge:SetMarker("0")
    Endif
    oGauge:SetMarker(aNiveis[2])
    oGauge:SetMarker(aNiveis[1])
    If Val(aNiveis[1]) < 100
        oGauge:SetMarker("100")
    Endif
    oJsonRet["gauge"]      := oGauge:GetJsonObject()
    PCPMonitorUtils():AdicionaTagMonitor(oJsonRet["tags"],@nPosTag,"po-icon-calendar",dToC(dDataIni) + " - " + dToC(dDataFin))
    PCPMonitorUtils():AdicionaTagMonitor(oJsonRet["tags"],@nPosTag,"po-icon-manufacture",cCodRecur)
    PCPMonitorUtils():AdicionaTagMonitor(oJsonRet["tags"],@nPosTag,"po-icon-star-half",STR0105+": "+cValToChar(nHrProd)+" "+STR0054) //"Horas Produtivas" //" horas"
    PCPMonitorUtils():AdicionaTagMonitor(oJsonRet["tags"],@nPosTag,"po-icon-star-filled",STR0099+": "+cValToChar(nHrDispRec)+" "+STR0054) //"Capacidade" //" horas"
    FreeObj(oGauge)
    FwFreeArray(aNiveis)
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
Method BuscaDetalhes(oFiltros, nPagina) Class ProducaoCapacidadeRecurso
    Local aPeriodos  := {}
    Local cAlias     := GetNextAlias()
    Local cCodRecur  := ""
    Local cQuery     := ""
    Local cTempo     := ""
    Local cTpPerDesc := ""
    Local lExpResult := .F.
    Local nPosCon    := 0
    Local nPosTag    := 0
    Local nStart     := 1
    Local nTamPagina := 20
    Local oDados     := JsonObject():New()

    Default nPagina := 1

    If nPagina == 0
        lExpResult := .T.
    EndIf
    oFiltros["01_H6_FILIAL"] := PadR(oFiltros["01_H6_FILIAL"], FWSizeFilial())
    cCodRecur  := AllTrim(oFiltros["02_H6_RECURSO"])
    dDataFin   := dDatabase
    dDataIni   := PCPMonitorUtils():RetornaPeriodoInicial(AllTrim(oFiltros["05_TIPOPERIODO"]),dDataFin,cValToChar(oFiltros["06_PERIODO"]))

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
    cQuery += "   AND SH6.H6_RECURSO = '" + AllTrim(oFiltros["02_H6_RECURSO"]) + "' "
    cQuery += "   AND (SH6."+AllTrim(oFiltros["04_FILTRODATA"])+" >= '"+DToS(dDataIni)+"' AND SH6."+AllTrim(oFiltros["04_FILTRODATA"])+" <= '"+DToS(dDataFin)+"') "
    cQuery += "   AND SH6.H6_TIPO = 'P' "
    cQuery += " ORDER BY SH6.H6_FILIAL,SH6.H6_RECURSO,SH6."+AllTrim(oFiltros["04_FILTRODATA"])+" "
    cQuery := ChangeQuery(cQuery)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)
    If nPagina > 1
		nStart := ( (nPagina-1) * nTamPagina )
		If nStart > 0
			(cAlias)->(DbSkip(nStart))
		EndIf
	EndIf
    cTpPerDesc := PCPMonitorUtils():RetornaDescricaoTipoPeriodo(oFiltros["05_TIPOPERIODO"])
    oDados["items"]        := {}
    oDados["columns"]      := bscColunas(lExpResult,oFiltros["04_FILTRODATA"])
    oDados["canExportCSV"] := .T.
    oDados["tags"]         := {}

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
    PCPMonitorUtils():AdicionaTagMonitor(oDados["tags"],@nPosTag,"po-icon-manufacture",cCodRecur)
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
Method CargaMonitor() Class ProducaoCapacidadeRecurso
    Local aCategr    := {}
    Local aDetalhes  := {}
    Local aTags      := {}
    Local lRet       := .T.
    Local nIndTag    := 0
    Local oCarga     := PCPMonitorCarga():New()
    Local oGauge     := PCPMonitorGauge():New()
    Local oPrmAdc    := JsonObject():New()
    Local oSeries    := JsonObject():New()

    If !PCPMonitorCarga():monitorAtualizado("ProducaoCapacidadeRecurso")
        PCPMonitorUtils():AdicionaTagMonitor(aTags,@nIndTag,"po-icon-calendar","16/04/2023 - 28/05/2023")
        PCPMonitorUtils():AdicionaTagMonitor(aTags,@nIndTag,"po-icon-bar-code","GUIL01")
        PCPMonitorUtils():AdicionaTagMonitor(aTags,@nIndTag,"po-icon-star-half", STR0105+": 110"+STR0054) //"Horas Produtivas" //" horas"
        PCPMonitorUtils():AdicionaTagMonitor(aTags,@nIndTag,"po-icon-star-filled",STR0099+": 200"+STR0054) //"Capacidade" //" horas"
        oPrmAdc["04_FILTRODATA"]           := JsonObject():New()
        oPrmAdc["04_FILTRODATA"]["opcoes"] := "Data Início:H6_DATAINI;Data Final:H6_DATAFIN;Data Apontamento:H6_DTAPONT"
        oGauge:SetValue(55)
        oGauge:SetValueStyle("color",COR_AMARELO_QUEIMADO)
        oGauge:SetValueStyle("font-weight","bold")
        oGauge:SetLabel(STR0100) //"% Utilização"
        oGauge:SetLabelStyle("font-weight","bold")
        oGauge:SetThreshold("0",COR_VERMELHO_FORTE)
        oGauge:SetThreshold("40",COR_AMARELO_QUEIMADO)
        oGauge:SetThreshold("75",COR_VERDE_FORTE)
        oGauge:SetMarker("0")
        oGauge:SetMarker("40")
        oGauge:SetMarker("75")
        oGauge:SetMarker("100")
        oCarga:setaTitulo(STR0102) //"Produção X Capacidade"
        oCarga:setaObjetivo(STR0103) //"Acompanhar o percentual de utilização do recurso com apontamentos de produção com base na capacidade calculada para o período."
        oCarga:setaAgrupador("PCP")
        oCarga:setaFuncaoNegocio("ProducaoCapacidadeRecurso")
        oCarga:setaTiposPermitidos("chart")
        oCarga:setaTiposGraficoPermitidos("gauge")
        oCarga:setaTipoPadrao("chart")
        oCarga:setaTipoGraficoPadrao("gauge")
        oCarga:setaTipoDetalhe("detalhe")
        oCarga:setaExemploJsonGrafico(oSeries, aTags, aDetalhes,aCategr,"gauge",oGauge:GetJsonObject())
        oCarga:setaPropriedadeFilial("01_H6_FILIAL")
        oCarga:setaPropriedadeRecurso("02_H6_RECURSO")
        oCarga:setaPropriedade("03_NIVEIS",STR0205,STR0208,1,30,0,"po-lg-6 po-xl-6 po-md-6 po-sm-12") //"Atenção;Urgente" //"Níveis (% Utilização)"
        oCarga:setaPropriedade("04_FILTRODATA","H6_DATAINI",STR0061,4,,,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,oPrmAdc["04_FILTRODATA"]) //"Data de referência"
        oCarga:setaPropriedadePeriodoAtual("05_TIPOPERIODO","D","06_PERIODO")
        If !oCarga:gravaMonitorPropriedades()
            lRet := .F.
        EndIf
        oCarga:Destroy()
    EndIf
    FwFreeArray(aCategr)
    FwFreeArray(aDetalhes)
    FwFreeArray(aTags)
    FreeObj(oGauge)
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
Method ValidaPropriedades(oFiltros) Class ProducaoCapacidadeRecurso
    Local aNiveis  := {}
    Local aRetorno := {.T.,""}

    PCPMonitorUtils():ValidaPropriedadeFilial(oFiltros["01_H6_FILIAL"],aRetorno)

    If aRetorno[1] .And. Empty(oFiltros["02_H6_RECURSO"])
        aRetorno[1] := .F.
        aRetorno[2] := STR0067 //"O filtro de Recurso deve ser preenchido."
    Else
        If aRetorno[1]
            SH1->(dbSetOrder(1))
			If !SH1->(dbSeek(xFilial("SH1",PadR(oFiltros["01_H6_FILIAL"], FWSizeFilial())) + PadR(oFiltros["02_H6_RECURSO"],GetSx3Cache("H6_RECURSO","X3_TAMANHO")), .F.))
                aRetorno[1] := .F.
                aRetorno[2] := STR0068 //"O Recurso não existe na Filial informada."
            EndIf
        EndIf
    EndIf
    If aRetorno[1] .And. oFiltros["05_TIPOPERIODO"] == "X"
        If !oFiltros:HasProperty("06_PERIODO") .Or. oFiltros["06_PERIODO"] == Nil
            aRetorno[1] := .F.
            aRetorno[2] := STR0069 //"Deve ser informada a quantidade de dias para o período personalizado."
        EndIf
    EndIf

    If aRetorno[1] 
        If !oFiltros:HasProperty("03_NIVEIS") .Or. oFiltros["03_NIVEIS"] == Nil .Or. Empty(oFiltros["03_NIVEIS"])
            aRetorno[1] := .F.
            aRetorno[2] := STR0209 //"O campo 'Níveis' deve ser preenchido com 2 valores separados por ponto e vírgula (ex.: '75;50'), definindo os percentuais de utilização do recurso que indicam Atenção e Urgência, respectivamente."
        Else 
            aNiveis := StrTokArr(Replace(oFiltros["03_NIVEIS"],",","."),";")
            If Len(aNiveis) <> 2
                aRetorno[1] := .F.
                aRetorno[2] := STR0209 //"O campo 'Níveis' deve ser preenchido com 2 valores separados por ponto e vírgula (ex.: '75;50'), definindo os percentuais de utilização do recurso que indicam Atenção e Urgência, respectivamente."
            Else
                If Empty(aNiveis[1]) .Or. Empty(aNiveis[2])
                    aRetorno[1] := .F.
                    aRetorno[2] := STR0209 //"O campo 'Níveis' deve ser preenchido com 2 valores separados por ponto e vírgula (ex.: '75;50'), definindo os percentuais de utilização do recurso que indicam Atenção e Urgência, respectivamente."
                Else
                    If Val(aNiveis[1]) <= Val(aNiveis[2])
                        aRetorno[1] := .F.
                        aRetorno[2] := STR0210 //"No campo 'Níveis', o primeiro valor referente ao status 'Atenção' deve ser maior que o segundo, que representa 'Urgência'."
                    EndIf
                EndIf
            EndIf
        EndIf
    EndIf
    FwFreeArray(aNiveis)
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

    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H6_FILIAL",STR0058,"string",lExpResult) //"Filial"
    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabels,@nIndLabels,"I",COR_VERMELHO,STR0071,COR_BRANCO) //"Improdutivo"
    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabels,@nIndLabels,"P",COR_VERDE,STR0072,COR_BRANCO) //"Produtivo"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H6_TIPO",STR0070,"cellTemplate",.T.,.T.,aLabels) //"Tp Apon"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H6_RECURSO",STR0059,"string",.T.) //"Recurso"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H1_DESCRI",STR0073,"string",lExpResult) //"Desc. Recurso"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H6_OP",STR0076,"string",.T.) //"OP"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H6_PRODUTO",STR0074,"string",.T.) //"Produto"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"B1_DESC",STR0075,"string",lExpResult) //"Desc. Produto"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H6_OPERAC",STR0077,"string",.T.) //"Operação"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"G2_DESCRI",STR0078,"string",lExpResult) //"Desc. Operação"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H6_TEMPO",STR0079,"string",.T.) //"Tempo"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H6_DTAPONT",STR0080,"date",IIF(lExpResult .Or. cDataRef == "H6_DTAPONT",.T.,.F.)) //"Dt Apont"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H6_DATAINI",STR0081,"date",IIF(lExpResult .Or. cDataRef == "H6_DATAINI",.T.,.F.)) //"Dt Ini"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H6_HORAINI",STR0082,"string",lExpResult) //"Hora Ini"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H6_DATAFIN",STR0083,"date",IIF(lExpResult .Or. cDataRef == "H6_DATAFIN",.T.,.F.)) //"Dt Fin"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H6_HORAFIN",STR0084,"string",lExpResult) //"Hora Fin"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H6_QTDPROD",STR0085,"number",lExpResult) //"Qtd. Prod"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H6_QTDPERD",STR0086,"number",lExpResult) //"Qtd. Perda"
Return aColunas
