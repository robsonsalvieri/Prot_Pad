#INCLUDE "TOTVS.CH"
#INCLUDE "PCPMONITOR.CH"

/*/{Protheus.doc} PCPMonitorUtils
Classe com os métodos para consultas dos dados nas propriedades do Monitor
@type Class
@author renan.roeder
@since 26/04/2023
@version P12.1.2310
@return Nil
/*/
Class PCPMonitorUtils FROM LongNameClass
    Static Method CalculaTempoApontamentoOperacao(cFilFlt,cRecursos,aPeriodo,lDtAgrup,cTpAgrup,cDatRef)
    Static Method FormataData(xData, nTipo)
    Static Method BuscaPeriodoAnterior(cTipo,dData)
    Static Method BuscaProximoPeriodo(cTipo,dData)
    Static Method RetornaDescricaoTipoPeriodo(cTpPeriodo)
    Static Method RetornaDescricaoRecurso(cCodFilial,cCodRecur)
    Static Method RetornaPeriodoInicial(cTipo,dDataFim,cDias)
    Static Method RetornaPeriodoFinal(cTipo,dDataIni,cDias)
    Static Method RetornaListaPeriodosPassado(cTipo,cPeriodos)
    Static Method RetornaListaPeriodosFuturo(cTipo,cPeriodos)
    Static Method RetornaQuantidadesProducaoProduto(cFilFlt,cProduto,dDataIni,dDataFin,lDtAgrup,cTpAgrup)
    Static Method TransformaTempoParaMinutosCentesimais(cTempo,nTipoTempo)
    Static Method TransformaMinutosCentesimaisParaTempo(nMinCent,nTipoTempo)
    Static Method RetornaListaMonitores()
    Static Method RetornaListaMonitoresPadrao()
    Static Method RetornaIndiceListaMonitores(cAPINeg)
    Static Method RetornaIndiceListaMonitoresPadrao(cAPINeg)
    Static Method RetornaListaMonitoresExclusivos()
    Static Method AdicionaLinhaInformacao(aLinhas,nIndice,cTexto,cClasse,cEstilo,lAcessaDet)
    Static Method AdicionaTagMonitor(aTags,nIndice,cIcone,cTexto,cCorTxt)
    Static Method AdicionaSerieGraficoMonitor(aSeries,nIndice,cCor,xValor,cDescricao)
    Static Method ValidaPropriedadeFilial(cFilialFlt,aRetorno)
    Static Method AdicionaColunaTabela(aColunas,nIndice,cProp,cTexto,cTipo,lVisivel,lTipoLabel,aLabels)
    Static Method AdicionaLabelsColunaTabela(aLabels,nIndice,cValor,cCor,cTexto,cCorTexto)
    Static Method AdicionaHeaderDetalhe(aHeaders,cTexto,nIndice,cClasse,cEstilo)
    Static Method AdicionaCategoriasGraficoMonitor(aCategorias,aValores)
    Static Method RetornaCorSerie(nIndice)
EndClass

/*/{Protheus.doc} CalculaTempoApontamentoOperacao
Calcula o tempo total de apontamento num período
@type Method
@author renan.roeder
@since 17/05/2023
@version P12.1.2310
@param  cFilFlt   , caracter   , Filial do filtro
@param  cRecursos , caracter   , Codigo dos recursos separado por virgula
@param  aPeriodo  , array      , array com período inicial e final
@param  lDtAgrup  , logico     , define se agrupa os apontamentos por período
@param  cTpAgrup  , caracter   , tipo de período para agrupamento
@param  cDataRef  , caracter   , data de referência para filtro da query
@return oJsonTempo, objeto json, Objeto json com os apontamentos dos períodos
/*/
Method CalculaTempoApontamentoOperacao(cFilFlt,cRecursos,aPeriodo,lDtAgrup,cTpAgrup,cDataRef) Class PCPMonitorUtils
    Local cAlias     := GetNextAlias()
    Local cQuery     := ""
    Local cDataAjust := dToC(dDatabase)
    Local nTempAjust := 0
    Local oJsonTempo := JsonObject():New()

    If !lDtAgrup
        oJsonTempo[cDataAjust] := JsonObject():New()
        oJsonTempo[cDataAjust]["P"] := 0
        oJsonTempo[cDataAjust]["I"] := 0
    EndIf
    cQuery := " SELECT SH6.H6_TIPO TIPO,SH6.H6_TEMPO TEMPO,SH6.H6_TIPOTEM TIPO_TEMPO,SH6."+cDataRef+" DATA_FILTRO "
    cQuery += " FROM "+RetSqlName("SH6")+" SH6 "
    cQuery += " WHERE SH6.D_E_L_E_T_ = ' ' "
    cQuery += "   AND SH6.H6_FILIAL = '" + xFilial("SH6",cFilFlt) + "' "
    cQuery += "   AND SH6.H6_RECURSO IN ("+cRecursos+") "
    cQuery += "   AND (SH6."+cDataRef+" >= '"+dToS(aPeriodo[1])+"' AND SH6."+cDataRef+" <= '"+dToS(aPeriodo[2])+"') "
    cQuery += " ORDER BY SH6.H6_FILIAL,SH6."+cDataRef+" "
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)
    While (cAlias)->(!Eof())
        If lDtAgrup
            cDataAjust := dToC(PCPMonitorUtils():RetornaPeriodoInicial(cTpAgrup,sToD((cAlias)->DATA_FILTRO)))
            If !oJsonTempo:HasProperty(cDataAjust)
                oJsonTempo[cDataAjust] := JsonObject():New()
                oJsonTempo[cDataAjust]["P"] := 0
                oJsonTempo[cDataAjust]["I"] := 0
            EndIf
        EndIf
        nTempAjust := PCPMonitorUtils():TransformaTempoParaMinutosCentesimais((cAlias)->TEMPO,(cAlias)->TIPO_TEMPO)
        oJsonTempo[cDataAjust][(cAlias)->TIPO] += nTempAjust
        (cAlias)->(dbSkip())
    End
    (cAlias)->(dbCloseArea())

Return oJsonTempo

/*/{Protheus.doc} FormataData
Formata a data conforme o tipo definido
@type  Method
@author douglas.heydt
@since 13/03/2023
@version P12.1.2310
@param cData, Date   , Data que será convertida
@param nTipo, numeral, tipo de conversão executada
		1 - date para DD/MM/AAAA
		2 - AAAA-MM-DD para AAAAMMDD
		3 - AAAA-MM-DD para DD/MM/AAAA
		4 - AAAAMMDD para AAAA-MM-DD
        5 - AAAAMMDD para DD/MM/AAAA
@return cData, Caracter, Data convertida para o formato utilizado na integração.
/*/
Method FormataData(xData, nTipo) Class PCPMonitorUtils
    Local cDateSeparator := "/"

    If UPPER(GetSrvProfString( 'DATEFORMAT', 'AMERICAN')) == "RUSSIAN"
        cDateSeparator := "."
    Endif 

	If !Empty(xData)
		If nTipo == 1
			xData := StrZero(Day(xData),2) + cDateSeparator + StrZero(Month(xData),2) + cDateSeparator +  StrZero(Year(xData),4)
		ElseIf nTipo == 2
			xData := StrTran(xData, "-", "")
		ElseIf nTipo == 3
			xData := StrTran(xData, "-", "")
			xData := SUBSTR(xData, 7, 2)  + cDateSeparator + SUBSTR(xData, 5, 2)  + cDateSeparator +  SUBSTR(xData, 0, 4)
		ElseIf nTipo == 4
			xData := SUBSTR(xData, 0, 4) +"-"+ SUBSTR(xData, 5, 2)+"-"+SUBSTR(xData, 7, 2)
        ElseIf nTipo == 5
            xData := SUBSTR(xData, 7, 2) +cDateSeparator+SUBSTR(xData, 5, 2) +cDateSeparator+SUBSTR(xData, 0, 4)
		EndIf
	EndIf
Return xData

/*/{Protheus.doc} BuscaPeriodoAnterior
Busca a data de inicio do período anterior
@type Method
@author renan.roeder
@since 08/05/2023
@version P12.1.2310
@param	cTipo, caracter, Tipo do período (D,S,Q,M)
@param	dData, data    , Data base para o cálculo
@return Nil
/*/
Method BuscaPeriodoAnterior(cTipo,dData) Class PCPMonitorUtils
    Do Case
        Case cTipo == "D"
            dData--
        Case cTipo == "S"
            dData -= 7
            While Dow(dData) > 1
                dData--
            End
        Case cTipo == "Q"
            If Day(dData) <= 15
                dData := FirstDate(MonthSub(dData,1)) + 15
            Else
                dData := FirstDate(dData,1)
            EndIf
        Case cTipo == "M"
            dData := FirstDate(MonthSub(dData,1))
    EndCase
Return

/*/{Protheus.doc} BuscaProximoPeriodo
Busca a data de inicio do próximo período
@type Method
@author douglas.heydt
@since 08/05/2023
@version P12.1.2310
@param	cTipo, caracter, Tipo do período (D,S,Q,M)
@param	dData, data    , Data base para o cálculo
@return Nil
/*/
Method BuscaProximoPeriodo(cTipo,dData) Class PCPMonitorUtils
    Do Case
        Case cTipo == "D"
            dData++
        Case cTipo == "S"
            dData += 7
            While Dow(dData) > 1
                dData--
            End
        Case cTipo == "Q"
            If Day(dData) <= 15
                dData := FirstDate(dData,1) + 15
            Else
                dData := FirstDate(MonthSum(dData,1))
            EndIf
        Case cTipo == "M"
            dData := FirstDate(MonthSum(dData,1))
    EndCase
Return

/*/{Protheus.doc} RetornaDescricaoTipoPeriodo
Retorna a descrição do tipo de período
@type Method
@author renan.roeder
@since 08/05/2023
@version P12.1.2310
@param	cTpPeriodo, caracter, Tipo do período (D,S,Q,M)
@return cTpPerDesc, caracter, Descrição do tipo de período
/*/
Method RetornaDescricaoTipoPeriodo(cTpPeriodo) Class PCPMonitorUtils
    Local cTpPerDesc := ""

    Do Case
            Case cTpPeriodo == "D"
                cTpPerDesc := STR0087 //"Diário"
            Case cTpPeriodo == "S"
                cTpPerDesc := STR0088 //"Semanal"
            Case cTpPeriodo == "Q"
                cTpPerDesc := STR0089 //"Quinzenal"
            Case cTpPeriodo == "M"
                cTpPerDesc := STR0090 //"Mensal"
    End Case
Return cTpPerDesc

/*/{Protheus.doc} RetornaDescricaoRecurso
Retorna a descrição do recurso
@type Method
@author renan.roeder
@since 09/05/2023
@version P12.1.2310
@param	cCodFilial, caracter, Codigo Filial
@param	cCodRecur , caracter, Codigo Recurso
@return cDscRecur , caracter, Descricao Recurso
/*/
Method RetornaDescricaoRecurso(cCodFilial,cCodRecur) Class PCPMonitorUtils
    Local cDscRecur := AllTrim(Posicione("SH1",1,xFilial("SH1",cCodFilial)+cCodRecur,"H1_DESCRI"))
Return cDscRecur

/*/{Protheus.doc} RetornaPeriodoInicial
Calcula a data inicial do período da consulta conforme a data final e o tipo do período
@type Method
@author renan.roeder
@since 10/03/2023
@version P12.1.2310
@param	cTipo   , caracter, Tipo do período
@param	dDataFim, data    , Data final que por padrão é a database do sistema
@param	cDias   , caracter, Quantidade de dias quando o período for personalizado
@return dDataIni, data    , Data inicial calculada conforme a data final e o tipo
/*/
Method RetornaPeriodoInicial(cTipo,dDataFim,cDias) Class PCPMonitorUtils
    Local dDataIni := dDataFim

    Default cTipo := "D", dDataFim = dDatabase, cDias := "0"

    Do Case
        Case cTipo == "D"
            dDataIni := dDataFim
        Case cTipo == "S"
            While Dow(dDataIni) > 1
                dDataIni--
            End
        Case cTipo == "Q"
            If Day(dDataFim) <= 15
                dDataIni := FirstDate(dDataFim)
            Else
                dDataIni := FirstDate(dDataFim) + 15
            EndIf
        Case cTipo == "M"
            dDataIni := FirstDate(dDataFim)
        Case cTipo == "X"
            dDataIni := dDataIni - Val(cDias)
    End Case
Return dDataIni

/*/{Protheus.doc} RetornaPeriodoFinal
Calcula a data final do período da consulta conforme a data atual e o tipo do período
@type Method
@author douglas.heydt
@since 10/04/2023
@version P12.1.2310
@param  cTipo   , caracter, Tipo do período
@param  dDataIni, data    , Data inicial que por padrão é a database do sistema
@param  cDias   , caracter, Quantidade de dias quando o período for personalizado
@return dDataFim, data    , Data final calculada conforme a data final e o tipo
/*/
Method RetornaPeriodoFinal(cTipo,dDataIni,cDias) Class PCPMonitorUtils
    Local dDataFim := dDataIni

    Default cTipo := "D", dDataIni = dDatabase, cDias := "0"

    Do Case
        Case cTipo == "D"
           dDataFim :=  dDataIni
        Case cTipo == "S"
            While Dow(dDataFim) < 7
                dDataFim++
            End
        Case cTipo == "Q"
            If Day(dDataIni) <= 15
                dDataFim := FirstDate(dDataIni) + 14
            Else
                dDataFim := LastDate(dDataIni)
            EndIf
        Case cTipo == "M"
            dDataFim := LastDate(dDataIni)
        Case cTipo == "X"
            dDataFim := dDataFim + Val(cDias)
    End Case
Return dDataFim

/*/{Protheus.doc} RetornaListaPeriodosPassado
Retorna um array com os períodos calculados conforme o tipo
@type Method
@author renan.roeder
@since 08/05/2023
@version P12.1.2310
@param	cTipo     , caracter, Tipo do período (D,S,Q,M)
@param	cPeriodos , caracter, Quantidade de períodos
@return aPeriodos , array   , Array com os períodos gerados
/*/
Method RetornaListaPeriodosPassado(cTipo,cPeriodos) Class PCPMonitorUtils
    Local aPeriodos := {}
    Local nPeriodos := Val(cPeriodos)
    Local nIndex    := 0
    Local dData     := PCPMonitorUtils():RetornaPeriodoInicial(cTipo,dDatabase)

	aAdd(aPeriodos, {dData,dDatabase})
    For nIndex := 1 To nPeriodos
        PCPMonitorUtils():BuscaPeriodoAnterior(cTipo,@dData)
        aAdd(aPeriodos, {dData,PCPMonitorUtils():RetornaPeriodoFinal(cTipo,dData)})
	Next nIndex
Return aPeriodos

/*/{Protheus.doc} RetornaListaPeriodosFuturo
Retorna um array com os períodos calculados conforme o tipo
@type Static Function
@author douglas.heydt
@since 08/05/2023
@version P12.1.2310
@param	cTipo     , caracter, Tipo do período (D,S,Q,M)
@param	cPeriodos , caracter, Quantidade de períodos
@return aPeriodos , array   , Array com os períodos gerados
/*/
Method RetornaListaPeriodosFuturo(cTipo,cPeriodos) Class PCPMonitorUtils
    Local aPeriodos := {}
    Local nPeriodos := Val(cPeriodos)
    Local nIndex    := 0
    Local dData     := dDatabase

    aAdd(aPeriodos, {dData, PCPMonitorUtils():RetornaPeriodoFinal(cTipo,dData) })
    For nIndex := 1 To nPeriodos
        PCPMonitorUtils():BuscaProximoPeriodo(cTipo,@dData)
        aAdd(aPeriodos, {dData,PCPMonitorUtils():RetornaPeriodoFinal(cTipo,dData)})
	Next nIndex
Return aPeriodos

/*/{Protheus.doc} RetornaQuantidadesProducaoProduto
Retorna o total de unidades produzidas e perdidas por período
@type Method
@author renan.roeder
@since 02/06/2023
@version P12.1.2310
@param  cFilFlt   , caracter   , Filial do filtro
@param  cProduto  , caracter   , Codigo do produto
@param  dDataIni  , data       , Data inicial
@param  dDataFin  , data       , Data final
@param  cTpAgrup  , caracter   , tipo de período para agrupamento
@return oJsonDados, objeto json, Objeto json com as quantidades apontadas por período
/*/
Method RetornaQuantidadesProducaoProduto(cFilFlt,cProduto,dDataIni,dDataFin,cTpAgrup) Class PCPMonitorUtils
    Local cAlias     := GetNextAlias()
    Local cQuery     := ""
    Local dDataAjust := dDatabase
    Local nTotProd   := 0
    Local nTotPerda  := 0
    Local oJsonDados := JsonObject():New()

    Default cTpAgrup := "D"

    oJsonDados["PRODUCAO"] := JsonObject():New()
    oJsonDados["PERDA"]    := JsonObject():New()
    oJsonDados["ORDENS_PRODUCAO"] := JsonObject():New()
    cQuery := " SELECT SD3.D3_FILIAL,SD3.D3_COD,SD3.D3_EMISSAO,SD3.D3_QUANT,SD3.D3_PERDA,SD3.D3_OP "
    cQuery += " FROM " + RetSqlName("SD3") + " SD3 "
    cQuery += " WHERE SD3.D3_FILIAL = '"+xFilial("SD3",cFilFlt)+"' "
    cQuery += "   AND SD3.D3_COD = '"+cProduto+"' "
    cQuery += "   AND (SD3.D3_EMISSAO >= '"+dToS(dDataIni)+"' AND SD3.D3_EMISSAO <= '"+dToS(dDataFin)+"') "
    cQuery += "   AND SD3.D3_CF IN ('PR0','PR1') "
    cQuery += "   AND SD3.D3_ESTORNO <> 'S' "
    cQuery += "   AND SD3.D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY SD3.D3_FILIAL,SD3.D3_COD,SD3.D3_EMISSAO "
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)
    While (cAlias)->(!Eof())
        dDataAjust := dToC(PCPMonitorUtils():RetornaPeriodoInicial(cTpAgrup,sToD((cAlias)->D3_EMISSAO)))
        nTotProd   += (cAlias)->D3_QUANT
        nTotPerda  += (cAlias)->D3_PERDA
        If oJsonDados["PRODUCAO"]:HasProperty(dDataAjust)
            oJsonDados["PRODUCAO"][dDataAjust] += (cAlias)->D3_QUANT
        Else
            oJsonDados["PRODUCAO"][dDataAjust] := (cAlias)->D3_QUANT
        EndIf

        If oJsonDados["PERDA"]:HasProperty(dDataAjust)
            oJsonDados["PERDA"][dDataAjust] += (cAlias)->D3_PERDA
        Else
            oJsonDados["PERDA"][dDataAjust] := (cAlias)->D3_PERDA
        EndIf
        oJsonDados["ORDENS_PRODUCAO"][RTrim((cAlias)->D3_OP)] := .T.
        (cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())
    oJsonDados["TOTAL_PRODUCAO"] := nTotProd
    oJsonDados["TOTAL_PERDA"]    := nTotPerda
Return oJsonDados

/*/{Protheus.doc} TransformaTempoParaMinutosCentesimais
Transforma o tempo no formato do campo H6_TEMPO para minutos em formato centesimal
@type Method
@author renan.roeder
@since 06/06/2023
@version P12.1.2310
@param  cTempo    , caracter, String com o tempo no formato do campo H6_TEMPO
@param  nTipoTempo, numerico, Tipo do tempo no campo cTempo (1 - Normal / 2 - Centesimal)
@return nMinCent  , numerico, Tempo em minutos no formato centesimal
/*/
Method TransformaTempoParaMinutosCentesimais(cTempo,nTipoTempo) Class PCPMonitorUtils
    Local aHora     := StrTokArr(cTempo,":")
    Local nHoras    := Val(aHora[1])
    Local nMinutos  := Val(aHora[2])
    Local nMinCent  := 0

    nMinCent := (nHoras * 100)
    If nTipoTempo == 1
        nMinCent += nMinutos / .6
    Else
        nMinCent += nMinutos
    EndIf
Return nMinCent

/*/{Protheus.doc} TransformaMinutosCentesimaisParaTempo
Transforma minutos no formato centesimal para tempo no formato parametrizado
@type Method
@author renan.roeder
@since 06/06/2023
@version P12.1.2310
@param  nMinCent  , numerico         , Tempo em minutos no formato centesimal
@param  nTipoTempo, numerico         , Tipo do tempo no campo cTempo (1 - Normal / 2 - Centesimal)
@return xTempo    , caracter/numerico, Tempo no formato indicado no parâmetro nTipoTempo
/*/
Method TransformaMinutosCentesimaisParaTempo(nMinCent,nTipoTempo) Class PCPMonitorUtils
    Local xTempo   := ""
    Local nHoras   := 0
    Local nMinutos := 0

    If nTipoTempo == 1
        nMinCent := nMinCent * 0.6
        nHoras   := Int(nMinCent / 60)
        nMinutos := Int(nMinCent % 60)
        xTempo   := IIF(nHoras < 10,StrZero(nHoras,2),cValToChar(nHoras)) + ":" + IIF(nMinutos < 10,StrZero(nMinutos,2),cValToChar(nMinutos))
    Else
        xTempo   := Round(nMinCent / 100,2)
    EndIf
Return xTempo

Method RetornaListaMonitores() Class PCPMonitorUtils
    Local aMonitores := {}

    aAdd(aMonitores, {"IncluirVisao", STR0053}) //"Incluir visão"
    PCPMonitorUtils():RetornaListaMonitoresPadrao(@aMonitores)
    PCPMonitorUtils():RetornaListaMonitoresExclusivos(@aMonitores)
Return aMonitores

Method RetornaIndiceListaMonitores(cAPINeg) Class PCPMonitorUtils
    Local aMonitores := PCPMonitorUtils():RetornaListaMonitores()
    Local nIndice    := aScan(aMonitores, {|x| x[1] == cAPINeg})

Return nIndice

/*/{Protheus.doc} RetornaListaMonitoresPadrao
Retorna lista com o o nome e descrição de todos os Monitores padrão
@type Method
@author renan.roeder
@since 14/06/2023
@version P12.1.2310
@param  aMonitores, array, Lista com os Monitores padrão
@return Nil
/*/
Method RetornaListaMonitoresPadrao(aMonitores) Class PCPMonitorUtils
    aAdd(aMonitores,{"StatusOrdemProducao"         , STR0201 }) //"Situação de ordens de produção"
    aAdd(aMonitores,{"StatusRecurso"               , STR0172}) //"Situação do Recurso"
    aAdd(aMonitores,{"StatusPlayStopPCP"           , STR0139}) //"Acompanhamento Play/Stop PCP"
    aAdd(aMonitores,{"StatusLotesAVencer"          , STR0110}) //"Lotes a vencer"
    aAdd(aMonitores,{"StatusLotesAVencerGrafico"   , STR0124}) //"Acomp. Lotes A Vencer"
    aAdd(aMonitores,{"StatusApontamentoHoras"      , STR0108}) //"Acomp. Horas Apontadas"
    aAdd(aMonitores,{"StatusProducaoProduto"       , STR0162}) //"Acomp. Produção Produto"
    aAdd(aMonitores,{"ProducaoCapacidadeRecurso"   , STR0102}) //"Produção X Capacidade"
    aAdd(aMonitores,{"ImprodutivaProducaoRecurso"  , STR0056}) //"Horas Improdutivas X Produção"
    aAdd(aMonitores,{"StatusLotesVencidosGrafico"  , STR0217}) //"Acomp. Lotes Vencidos"
    aAdd(aMonitores,{"PrevisaoEntregaOP"           , STR0218}) //"Acomp. Previsão Entrega OPs"
    aAdd(aMonitores,{"ImprodutivaCapacidadeRecurso", STR0219}) //"Horas Improdutivas X Capacidade"
    aAdd(aMonitores,{"OPsAtrasadas"                , STR0220}) //"Acomp. OPs em Atraso"
    aAdd(aMonitores,{"OPsAtrasadasMultiProd"       , STR0310}) //"Acomp. OPs em Atraso Multi Produtos"
    aAdd(aMonitores,{"StatusMotivoPerdas"          , STR0275}) //"Motivos de Perda"
    aAdd(aMonitores,{"StatusPerdasProdutoMotivo"   , STR0284}) //"Perdas do Produto Por Motivo"
    aAdd(aMonitores,{"CRPHorasCapacidade"          , STR0287}) //"CRP - Horas X Capacidade"
    If FindFunction("GFEListaMonitores")
        GFEListaMonitores(@aMonitores)
    EndIf
    If FindFunction("QLTListaMonitores")
        QLTListaMonitores(@aMonitores)
    EndIf
Return

/*/{Protheus.doc} RetornaIndiceListaMonitoresPadrao
Retorna o indice do array da lista do menudef em que o monitor está localizado
@type Method
@author renan.roeder
@since 14/06/2023
@version P12.1.2310
@param  cAPINeg, caracter, Nome do Monitor
@return nIndice, numerico, Indice em que está localizado o Monitor
/*/
Method RetornaIndiceListaMonitoresPadrao(cAPINeg) Class PCPMonitorUtils
    Local aMonitores := PCPMonitorUtils():RetornaListaMonitoresPadrao()
    Local nIndice    := aScan(aMonitores, {|x| x[1] == cAPINeg})

Return nIndice

Method RetornaListaMonitoresExclusivos(aMonitores) Class PCPMonitorUtils
    Local cAlias     := GetNextAlias()
    Local cQuery     := ""

    cQuery := " SELECT "
    cQuery += "   HZE.HZE_APINEG,HZE.HZE_TITULO "
    cQuery += " FROM "+RetSqlName("HZE")+" HZE "
    cQuery += " WHERE HZE.HZE_FILIAL = '"+xFilial("HZE")+"' "
    cQuery += "   AND HZE.HZE_PADRAO = 'N' "
    cQuery += "   AND HZE.D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY HZE.HZE_CODIGO "
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)
    While (cAlias)->(!Eof())
        aAdd(aMonitores,{AllTrim((cAlias)->HZE_APINEG), AllTrim((cAlias)->HZE_TITULO)})
        (cAlias)->(dbSkip())
    End
    (cAlias)->(dbCloseArea())
Return

/*/{Protheus.doc} AdicionaLinhaInformacao
Adiciona uma linha de informação em um Monitor do tipo 'info'
@type Method
@author renan.roeder
@since 15/08/2023
@version P12.1.2310
@param  aLinhas   , array   , Array de Objetos com as linhas do Monitor
@param  nIndice   , numerico, Indice em que deve ser adicionada a linha
@param  cTexto    , caracter, Texto a ser adicionado
@param  cClasse   , caracter, Classe
@param  cEstilo   , caracter, Estilo
@param  lAcessaDet, logico  , Indica se deve acessar detalhes
@param  cParamDet , caracter, Parametros para acessar detalhes
@return Nil
/*/
Method AdicionaLinhaInformacao(aLinhas,nIndice,cTexto,cClasse,cEstilo,lAcessaDet,cParamDet) Class PCPMonitorUtils
    Default cClasse := "", cEstilo := "{}", lAcessaDet := .F., cParamDet := ""

    aAdd(aLinhas,JsonObject():New())
    nIndice++
    aLinhas[nIndice]["texto"]           := cTexto
    aLinhas[nIndice]["tipo"]            := "texto"
    aLinhas[nIndice]["classeTexto"]     := cClasse
    aLinhas[nIndice]["styleTexto"]      := cEstilo
    aLinhas[nIndice]["tituloProgresso"] := ""
    aLinhas[nIndice]["valorProgresso"]  := ""
    aLinhas[nIndice]["icone"]           := ""
    If lAcessaDet
        aLinhas[nIndice]["tipoDetalhe"]       := "detalhe"
        aLinhas[nIndice]["parametrosDetalhe"] := cParamDet
    EndIf

Return

/*/{Protheus.doc} AdicionaTagMonitor
Adiciona uma nova tag ao Monitor
@type Method
@author renan.roeder
@since 15/08/2023
@version P12.1.2310
@param  aTags   , array   , Array de Objetos com as tags do Monitor
@param  nIndice , numerico, Indice em que deve ser adicionada a tag
@param  cIcone  , caracter, Icone
@param  cTexto  , caracter, Texto
@param  cCorTxt , caracter, Cor do Texto
@return Nil
/*/
Method AdicionaTagMonitor(aTags,nIndice,cIcone,cTexto,cCorTxt) Class PCPMonitorUtils
    Default cCorTxt := ""

    aAdd(aTags,JsonObject():New())
    nIndice++
    aTags[nIndice]["icone"]      := cIcone
    aTags[nIndice]["texto"]      := cTexto
    aTags[nIndice]["colorTexto"] := cCorTxt
Return

/*/{Protheus.doc} AdicionaSerieGraficoMonitor
Adiciona uma nova serie ao grafico do Monitor
@type Method
@author renan.roeder
@since 15/08/2023
@version P12.1.2310
@param  aSeries    , array         , Array de Objetos com as series do Monitor
@param  nIndice    , numerico      , Indice em que deve ser adicionada a serie
@param  cCor       , caracter      , Cor da serie do grafico
@param  xValor     , numerico/array, Valor da serie
@param  cDescricao , caracter      , Descricao
@return Nil
/*/
Method AdicionaSerieGraficoMonitor(aSeries,nIndice,cCor,xValor,cDescricao) Class PCPMonitorUtils

    aAdd(aSeries, JsonObject():New())
    nIndice++
    aSeries[nIndice]["color"]   := cCor
    aSeries[nIndice]["data"]    := xValor
    aSeries[nIndice]["label"]   := cDescricao
Return

/*/{Protheus.doc} ValidaPropriedadeFilial
Verifica se a filial é valida
@type Method
@author renan.roeder
@since 15/08/2023
@version P12.1.2310
@param  cFilialFlt , caracter, Codigo da filial
@param  aRetorno   , array   , Array referencia para o retorno.[1]-Indica se a filial é valida [2]-Mensagem de erro
@return Nil
/*/
Method ValidaPropriedadeFilial(cFilialFlt,aRetorno) Class PCPMonitorUtils
    Local aFiliais  := FWLoadSM0(.T.,.T.)
    Local nFilSeg   := 0

    If Empty(cFilialFlt)
        aRetorno[1] := .F.
        aRetorno[2] := STR0064 //"O filtro de Filial deve ser preenchido."
    Else
        nFilSeg := aScan(aFiliais, {|x| x[1] == cEmpAnt .And. AllTrim(x[2]) == AllTrim(cFilialFlt) } )
        If nFilSeg > 0
            If !aFiliais[nFilSeg][11]
                aRetorno[1] := .F.
                aRetorno[2] := STR0065 + " " + cFilialFlt + "." //"Usuário não tem permissão na filial"
            EndIf
        Else
            aRetorno[1] := .F.
            aRetorno[2] := STR0066 //"Preencha uma Filial válida para a consulta."
        EndIf
    EndIf
    FwFreeArray(aFiliais)
Return

/*/{Protheus.doc} AdicionaColunaTabela
Adiciona coluna da tabela ao array
@type Method
@author renan.roeder
@since 15/08/2023
@version P12.1.2310
@param  aColunas  , array   , Array de objetos com as colunas da tabela
@param  nIndice   , numerico, Indice para a posição a ser adicionada
@param  cProp     , caracter, Nome da propriedade
@param  cTexto    , caracter, Texto da coluna
@param  cTipo     , caracter, Tipo de informação
@param  lVisivel  , logico  , Indica se é visivel
@param  lTipoLabel, logico  , Indice se a coluna é do tipo label
@param  aLabels   , array   , Array de objetos com as labels
@return Nil
/*/
Method AdicionaColunaTabela(aColunas,nIndice,cProp,cTexto,cTipo,lVisivel,lTipoLabel,aLabels) Class PCPMonitorUtils
    aAdd(aColunas,JsonObject():New())
    nIndice++
    aColunas[nIndice]["property"] := cProp
    aColunas[nIndice]["label"]    := cTexto
    aColunas[nIndice]["type"]     := cTipo
    aColunas[nIndice]["visible"]  := lVisivel
    If lTipoLabel
        aColunas[nIndice]["labels"] := aLabels
    EndIf
Return

/*/{Protheus.doc} AdicionaLabelsColunaTabela
Adiciona coluna da tabela do tipo label ao array
@type Method
@author renan.roeder
@since 15/08/2023
@version P12.1.2310
@param  aLabels  , array   , Array de objetos com as labels da coluna
@param  nIndice  , numerico, Indice para a posição a ser adicionada
@param  cValor   , caracter, Valor da propriedade
@param  cCor     , caracter, Cor da label
@param  cTexto   , caracter, Texto
@param  cCorTexto, caracter, Cor do texto
@return Nil
/*/
Method AdicionaLabelsColunaTabela(aLabels,nIndice,cValor,cCor,cTexto,cCorTexto) Class PCPMonitorUtils
    aAdd(aLabels,JsonObject():New())
    nIndice++
    aLabels[nIndice]["value"]     := cValor
    aLabels[nIndice]["color"]     := cCor
    aLabels[nIndice]["label"]     := cTexto
    aLabels[nIndice]["textColor"] := cCorTexto
Return

/*/{Protheus.doc} AdicionaHeaderDetalhe
Adiciona header na página de detalhe
@type Method
@author renan.roeder
@since 26/10/2023
@version P12.1.2310
@param  aHeaders, array   , Array de objetos com os headers do detalhe
@param  nIndice , numerico, Indice para a posição a ser adicionada
@param  cTexto  , caracter, Texto do header
@param  cClasse , caracter, Classe
@param  cEstilo , caracter, Estilo
@return Nil
/*/
Method AdicionaHeaderDetalhe(aHeaders,nIndice,cTexto,cClasse,cEstilo) Class PCPMonitorUtils
    Default cClasse := "", cEstilo := "{}"

    aAdd(aHeaders,JsonObject():New())
    nIndice++
    aHeaders[nIndice]["headerText"]  := cTexto
    aHeaders[nIndice]["headerClass"] := cClasse
    aHeaders[nIndice]["headerStyle"] := cEstilo
Return

/*/{Protheus.doc} AdicionaCategoriasGraficoMonitor
Adiciona categoria no gráfico
@type Method
@author renan.roeder
@since 26/10/2023
@version P12.1.2310
@param  aCategorias, array, Array de objetos que receberá as categorias
@param  aValores   , array, Array de objetos com as categorias a serem adicionadas
@return Nil
/*/
Method AdicionaCategoriasGraficoMonitor(aCategorias,aValores) Class PCPMonitorUtils
    aCategorias := aClone(aValores)
Return


/*/{Protheus.doc} RetornaCorSerie
Retorna cor que será utilizada pela série, conforme paleta de cores com máximo de 23 opções
@type Method
@author parffit.silva
@since 10/12/2024
@version P12.1.2410
@param  nIndice, integer, Índice para atribuir cor
@return cCor, string, texto indicando a cor no formato rgb(0,0,0)
 1 rgb(0,0,100) azul escuro
 2 rgb(0,200,0) verde
 3 rgb(100,0,0) vermelho escuro
 4 rgb(200,0,200) violeta
 5 rgb(200,100,0) laranja
 6 rgb(200,200,200) cinza claro
 7 rgb(200,0,100) rosa escuro
 8 rgb(255,255,0) amarelo
 9 rgb(0,0,200) azul
10 rgb(0,100,0) verde escuro
11 rgb(200,0,0) vermelho
12 rgb(100,0,100) roxo escuro
13 rgb(200,200,0) mostarda claro
14 rgb(100,100,100) cinza escuro
15 rgb(0,200,200) verde água
16 rgb(100,0,200) roxo
17 rgb(100,100,0) amarelo bronze
18 rgb(140,70,0) marrom
19 rgb(255,100,100) vermelho claro
20 rgb(0,255,255) azul piscina
21 rgb(255,128,200) rosa claro
22 rgb(255,255,255) branco
23 rgb(0,0,0) preto
/*/
Method RetornaCorSerie(nIndice) Class PCPMonitorUtils
    Local cCor    := "rgb("
    Local cIndice := ""
    Local nRed    := 0
    Local nGreen  := 0
    Local nBlue   := 0

    cIndice := StrZero(nIndice,2)

    If nIndice < 23
        Do Case
            Case cIndice $ "|03|12|14|16|17|"
                nRed := 100
            Case cIndice == "18"
                nRed := 140
            Case cIndice $ "|04|05|06|07|11|13|"
                nRed := 200
            Case cIndice $ "|08|19|21|22|"
                nRed := 255
        EndCase

        Do Case
            Case cIndice $ "|05|10|14|17|19|"
                nGreen := 100
            Case cIndice == "18"
                nGreen := 70
            Case cIndice == "21"
                nGreen := 128
            Case cIndice $ "|02|06|13|15|"
                nGreen := 200
            Case cIndice $ "|08|20|22|"
                nGreen := 255
        EndCase

        Do Case
            Case cIndice $ "|01|07|12|14|19|"
                nBlue := 100
            Case cIndice $ "|04|06|09|15|16|21|"
                nBlue := 200
            Case cIndice $ "|20|22|"
                nBlue := 255
        EndCase
    EndIf

    cCor := cCor + cValToChar(nRed) + ',' + cValToChar(nGreen) + ',' + cValToChar(nBlue) + ')'
Return cCor
