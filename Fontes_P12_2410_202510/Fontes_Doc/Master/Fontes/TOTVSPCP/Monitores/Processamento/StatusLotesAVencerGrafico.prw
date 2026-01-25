#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PCPMONITOR.CH"
#INCLUDE "PCPMONITORDEF.CH"

/*/{Protheus.doc} StatusLotesAVencerGrafico
Classe para prover os dados do Monitor de Status dos Lotes  a vencer ( gráfico )
@type Class
@author douglas.heydt
@since 09/05/2023
@version P12.1.2310
@return Nil
/*/
Class StatusLotesAVencerGrafico FROM LongNameClass
    Static Method CargaMonitor()
    Static Method BuscaDados(oFiltros, cTipo, cSubTipo)
    Static Method BuscaDetalhes(oFiltros, nPagina)
    Static Method ValidaPropriedades(oFiltros)
EndClass

/*/{Protheus.doc} CargaMonitor
Realiza a carga do Monitor padrão na base de dados
@type Method
@author douglas.heydt
@since 09/05/2023
@version P12.1.2310
@return lRet, logico, Indica se conseguiu realizar a carga
/*/
Method CargaMonitor() Class StatusLotesAVencerGrafico
    Local aCategorias := {}
    Local aDetalhes   := {}
    Local aTags       := {}
    Local lRet        := .T.
    Local nIndTag     := 0
    Local oCarga      := PCPMonitorCarga():New()
    Local oSeries     := JsonObject():New()    
    Local oPrmAdc     := JsonObject():New()
        
    If !PCPMonitorCarga():monitorAtualizado("StatusLotesAVencerGrafico")
        oSeries["Lotes"] := {{10, 20, 5}, COR_AZUL }

        PCPMonitorUtils():AdicionaTagMonitor(aTags,@nIndTag,"po-icon-calendar","01/02/2023 - 28/03/2023")
        PCPMonitorUtils():AdicionaTagMonitor(aTags,@nIndTag,"po-icon-calculator",PCPMonitorUtils():RetornaDescricaoTipoPeriodo("D"))
        PCPMonitorUtils():AdicionaTagMonitor(aTags,@nIndTag,"po-icon-bar-code","TUBO_CANETA")
        PCPMonitorUtils():AdicionaTagMonitor(aTags,@nIndTag,"po-icon-star-filled","3 Lotes")
        PCPMonitorUtils():AdicionaTagMonitor(aTags,@nIndTag,"po-icon-star-filled","150 UN")

        oCarga:setaTitulo(STR0124) //"Acomp. Lotes A Vencer"
        oCarga:setaObjetivo(STR0181) //"Apresentar um gráfico contendo o número de lotes ou a quantidade a vencer de um determinado produto, dentro de um número de períodos futuros configurado."
        oCarga:setaAgrupador(STR0112) //"Estoque"
        oCarga:setaFuncaoNegocio("StatusLotesAVencerGrafico")
        oCarga:setaTiposPermitidos("chart")
        oCarga:setaTiposGraficoPermitidos("column;bar;line")
        oCarga:setaTipoPadrao("chart")
        oCarga:setaTipoGraficoPadrao("line")
        oCarga:setaTipoDetalhe("detalhe")
        oCarga:setaExemploJsonGrafico(oSeries,aTags,aDetalhes,{"20/02/23","13/03/23","25/03/23"},"line")

        oPrmAdc["03_TIPOINFO"]                                  := JsonObject():New()
        oPrmAdc["03_TIPOINFO"]["opcoes"]                        := STR0182+":L;"+STR0183+":Q" //"Número de Lotes:L;Quantidade do Produto:Q"

        oCarga:setaPropriedadeFilial("01_B8_FILIAL")
        oCarga:setaPropriedadeLookupTabela("02_B8_PRODUTO",STR0074,.F.,"SB1","B1_COD","B1_DESC") //"Produto"
        oCarga:setaPropriedade("03_TIPOINFO","L", STR0113,4,/*cTamanho*/,/*cDecimal*/,"po-lg-6 po-xl-6 po-md-6 po-sm-12",/*oEstilos*/,/*cIcone*/,oPrmAdc["03_TIPOINFO"]) //"Lotes/Quantidade"
        oCarga:setaPropriedadePeriodoLinhaTempo("04_TIPOPERIODO","D","05_PERIODO")
        If !oCarga:gravaMonitorPropriedades()
            lRet := .F.
        EndIf
        oCarga:Destroy()
    EndIf
    FwFreeArray(aTags)
    FwFreeArray(aCategorias)
    FwFreeArray(aDetalhes)
    FreeObj(oSeries)
    FreeObj(oPrmAdc)
Return lRet

/*/{Protheus.doc} BuscaDados
Responsável por realizar a busca dos dados que serão exibidos no monitor (gráfico ou texto)
@type Method
@author douglas.heydt
@since 09/05/2023
@version P12.1.2310
@param	oFiltros  , objeto Json, Contém as propriedades do monitor usadas para filtrar a query de busca
@param	cTipo     , caracter   , Tipo chart/info
@param	cSubTipo  , caracter   , Tipo de grafico pie/bar/column
@return cJsonDados, caracter   , Retorna um novo Json em formato texto, pronto para conversão e exibição no front
/*/
Method BuscaDados(oFiltros, cTipo, cSubTipo) Class StatusLotesAVencerGrafico
    Local aSaldos    := {}
    Local aPeriodos  := PCPMonitorUtils():RetornaListaPeriodosFuturo(oFiltros["04_TIPOPERIODO"],cValToChar(oFiltros["05_PERIODO"]))
    Local aChaves    := {}
    Local cAliasQry  := GetNextAlias()
    Local cJsonDados := ""
    Local cUnMed     := ""
    Local cQuery     := ""
    Local dDataAjust := Nil
    Local dDataIni   := dDatabase
    Local dDataFin   := dDatabase
    Local nIndSerie  := 0
    Local nIndTag    := 0
    Local nLtsTotal  := 0
    Local nQtPTotal  := 0
    Local nX         := 0
    Local oDados     := JsonObject():New()
    Local oJsonRet   := JsonObject():New()
    Local oStyle     := JsonObject():New()
    Local oPeriods   := JsonObject():New()
    
    oJsonRet["corTitulo"] := "white"
    oJsonRet["alturaMinimaWidget"] := "350px"
    oJsonRet["alturaMaximaWidget"] := "500px"
    oJsonRet["tags"]   := {}
    oJsonRet["series"] := {}
    oStyle["color"] := "white"

    oFiltros["01_B8_FILIAL"] := PadR(oFiltros["01_B8_FILIAL"], FWSizeFilial())
    cUnMed := Posicione("SB1",1,xFilial("SB1",oFiltros["01_B8_FILIAL"])+oFiltros["02_B8_PRODUTO"],"B1_UM")
    dDataIni := aPeriodos[1][1]
    dDataFin := aPeriodos[Len(aPeriodos)][2]
    cQuery := " SELECT "
    cQuery += "     SB8.B8_FILIAL, "
    cQuery += "     SB8.B8_PRODUTO, "
    cQuery += "     SB8.B8_DTVALID, "
    cQuery += "     SUM(SB8.B8_SALDO) QUANTIDADE_PRODUTO, "
    cQuery += "     COUNT(SB8.B8_LOTECTL) NUMERO_LOTES "
    cQuery += " FROM "+RetSqlName("SB8")+" SB8 "
    cQuery += " WHERE SB8.B8_FILIAL  = '"+xFilial("SB8",oFiltros["01_B8_FILIAL"])+"' "
    cQuery += "   AND SB8.B8_PRODUTO = '"+oFiltros["02_B8_PRODUTO"]+"' "
    cQuery += "   AND SB8.B8_DTVALID BETWEEN '"+dToS(dDataIni)+"' AND '"+dToS(dDataFin)+"' "
    cQuery += "   AND SB8.B8_SALDO > 0 "
    cQuery += "   AND SB8.D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY SB8.B8_FILIAL,SB8.B8_PRODUTO,SB8.B8_DTVALID "
    cQuery += " ORDER BY SB8.B8_FILIAL,SB8.B8_PRODUTO,SB8.B8_DTVALID "
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)
    While (cAliasQry)->(!Eof())
        dDataAjust := dToC(PCPMonitorUtils():RetornaPeriodoInicial(oFiltros["04_TIPOPERIODO"],sToD((cAliasQry)->B8_DTVALID)))
        nLtsTotal   += (cAliasQry)->NUMERO_LOTES
        nQtPTotal   += (cAliasQry)->QUANTIDADE_PRODUTO
        If oPeriods:HasProperty(dDataAjust) 
            oPeriods[dDataAjust] += IIF(oFiltros["03_TIPOINFO"] == "L",(cAliasQry)->NUMERO_LOTES,(cAliasQry)->QUANTIDADE_PRODUTO)
        Else
            oPeriods[dDataAjust] := IIF(oFiltros["03_TIPOINFO"] == "L",(cAliasQry)->NUMERO_LOTES,(cAliasQry)->QUANTIDADE_PRODUTO)
        EndIf
        (cAliasQry)->(dbSkip())
    End
    (cAliasQry)->(dbCloseArea())

    aChaves := oPeriods:GetNames()
    For nX := 1 To Len(aChaves)
        aAdd(aSaldos, oPeriods[aChaves[nX]])
    Next nX

    PCPMonitorUtils():AdicionaSerieGraficoMonitor(oJsonRet["series"],nIndSerie,COR_AZUL,aSaldos,IIF(oFiltros["03_TIPOINFO"] == "L", STR0178,cUnMed)) //"Lotes"
    oJsonRet["categorias"] := aChaves

    oJsonRet["tags"]     := {}
    PCPMonitorUtils():AdicionaTagMonitor(oJsonRet["tags"],@nIndTag,"po-icon-calendar",dToC(dDataIni) + " - " + dToC(dDataFin))
    PCPMonitorUtils():AdicionaTagMonitor(oJsonRet["tags"],@nIndTag,"po-icon-calculator",PCPMonitorUtils():RetornaDescricaoTipoPeriodo(oFiltros["04_TIPOPERIODO"]))
    PCPMonitorUtils():AdicionaTagMonitor(oJsonRet["tags"],@nIndTag,"po-icon-bar-code",oFiltros["02_B8_PRODUTO"],"")
    PCPMonitorUtils():AdicionaTagMonitor(oJsonRet["tags"],@nIndTag,"po-icon-star-filled",cValToChar(nLtsTotal) + IIF(nLtsTotal > 1, " "+STR0178, " "+STR0177)) //"Lotes" //"Lote"
    PCPMonitorUtils():AdicionaTagMonitor(oJsonRet["tags"],@nIndTag,"po-icon-star-filled",cValToChar(nQtPTotal) + " " + cUnMed )

    cJsonDados :=  oJsonRet:toJson()

    FwFreeArray(aChaves)
    FwFreeArray(aPeriodos)
    FwFreeArray(aSaldos)
    FreeObj(oDados)
    FreeObj(oJsonRet)
    FreeObj(oStyle)
Return cJsonDados

/*/{Protheus.doc} BuscaDetalhes
Realiza a busca dos dados para montar os detalhes do Monitor
@type Method
@author douglas.heydt
@since 12/04/2023
@version P12.1.2310
@param	oFiltros  , objeto Json , Contém as propriedades do monitor usadas para filtrar a query de busca
@param	nPagina   , numerico    , Número da página desejada para busca
@return cJsonDados, caracter    , Retorna um novo Json em formato texto, pronto para conversão e exibição no front
@return Nil
/*/
Method BuscaDetalhes(oFiltros,nPagina) Class StatusLotesAVencerGrafico
    Local aPeriodos  := PCPMonitorUtils():RetornaListaPeriodosFuturo(oFiltros["04_TIPOPERIODO"],cValToChar(oFiltros["05_PERIODO"]))
    Local cAliasQry  := GetNextAlias()
    Local cCategoria := IIF(oFiltros:HasProperty("CATEGORIA"),oFiltros["CATEGORIA"],"")
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

    oFiltros["01_B8_FILIAL"] := PadR(oFiltros["01_B8_FILIAL"], FWSizeFilial())
    If !Empty(cCategoria)
        dDataIni := cToD(cCategoria)
        dDataFin := PCPMonitorUtils():RetornaPeriodoFinal(oFiltros["04_TIPOPERIODO"],cToD(cCategoria))
        If dDataIni < dDatabase
            dDataIni := dDatabase
        EndIf
    Else
        dDataIni := aPeriodos[1][1]
        dDataFin := aPeriodos[Len(aPeriodos)][2]
    EndIf

    oDados["items"]        := {}
    oDados["columns"]      := montaColun(lExpResult)
    oDados["canExportCSV"] := .T.
    oDados["tags"]         := {}

    cQuery += " SELECT "
    cQuery += "     SB8.B8_FILIAL, SB8.B8_QTDORI, SB8.B8_PRODUTO, SB8.B8_LOCAL, SB8.B8_DTVALID, "
    cQuery += "     SB8.B8_SALDO, SB8.B8_LOTECTL, SB1.B1_DESC, SB8.B8_NUMLOTE, SB1.B1_UM "
    cQuery += " FROM "+RetSqlName("SB8")+" SB8 "
    cQuery += " LEFT JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1",oFiltros["01_B8_FILIAL"])+"' AND SB1.B1_COD = SB8.B8_PRODUTO AND SB1.D_E_L_E_T_ = ' ' "
    cQuery += " WHERE SB8.B8_FILIAL = '" + xFilial("SB8",oFiltros["01_B8_FILIAL"]) + "' "
    cQuery += "   AND SB8.B8_PRODUTO = '"+oFiltros["02_B8_PRODUTO"]+"'  "
    cQuery += "   AND SB8.B8_DTVALID BETWEEN '"+DTOS(dDataIni)+"' AND  '"+DTOS(dDataFin)+"' "
    cQuery += "   AND SB8.B8_SALDO > 0 "
    cQuery += "   AND SB8.D_E_L_E_T_  = ' ' "
    cQuery += " ORDER BY SB8.B8_FILIAL,SB8.B8_DTVALID,SB8.B8_LOTECTL  "
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

    If nPagina > 1
		nStart := ( (nPagina-1) * nTamPagina )
		If nStart > 0
			(cAliasQry)->(DbSkip(nStart))
		EndIf
	EndIf
    While (cAliasQry)->(!Eof())
        aAdd(oDados["items"], JsonObject():New())
        nPos++
        oDados["items"][nPos]["B8_FILIAL"  ] := (cAliasQry)->B8_FILIAL
        oDados["items"][nPos]["B8_LOTECTL" ] := (cAliasQry)->B8_LOTECTL
        oDados["items"][nPos]["B8_NUMLOTE" ] := (cAliasQry)->B8_NUMLOTE
        oDados["items"][nPos]["B8_PRODUTO" ] := (cAliasQry)->B8_PRODUTO
        oDados["items"][nPos]["B1_DESC"    ] := (cAliasQry)->B1_DESC
        oDados["items"][nPos]["B8_QTDORI"  ] := (cAliasQry)->B8_QTDORI
        oDados["items"][nPos]["B1_UM"      ] := (cAliasQry)->B1_UM
        oDados["items"][nPos]["B8_LOCAL"   ] := (cAliasQry)->B8_LOCAL
        oDados["items"][nPos]["B8_DTVALID" ] := PCPMonitorUtils():FormataData((cAliasQry)->B8_DTVALID, 5)
        oDados["items"][nPos]["B8_SALDO"   ] := (cAliasQry)->B8_SALDO
        (cAliasQry)->(dbSkip())
        If !lExpResult .And. nPos >= nTamPagina
            Exit
        EndIf
    End
    oDados["hasNext"] := (cAliasQry)->(!Eof())
    (cAliasQry)->(dbCloseArea())    

    PCPMonitorUtils():AdicionaTagMonitor(oDados["tags"],@nPosTag,"po-icon-calendar",dToC(dDataIni) + " - " + dToC(dDataFin))
    If Empty(cCategoria)
        PCPMonitorUtils():AdicionaTagMonitor(oDados["tags"],@nPosTag,"po-icon-calculator",PCPMonitorUtils():RetornaDescricaoTipoPeriodo(oFiltros["04_TIPOPERIODO"]))
    EndIf
    PCPMonitorUtils():AdicionaTagMonitor(oDados["tags"],@nPosTag,"po-icon-bar-code",oFiltros["02_B8_PRODUTO"])
Return oDados:ToJson()

/*/{Protheus.doc} ValidaPropriedades
Valida os dados informados nas propriedades do Monitor
@type Method
@author douglas.heydt
@since 10/03/2023
@version P12.1.2310
@param  oFiltros, objeto json, Objeto json com os filtros para a consulta dos dados
@return aRetorno, array      , [1] logico - indica se os dados são válidos [2] caracter - mensagem de erro
/*/
Method ValidaPropriedades(oFiltros) Class StatusLotesAVencerGrafico
    Local aRetorno  := {.T.,""}
    Local aSemaforo := {}

    PCPMonitorUtils():ValidaPropriedadeFilial(oFiltros["01_B8_FILIAL"],aRetorno)

	If aRetorno[1] .And. Empty(oFiltros["02_B8_PRODUTO"])
        aRetorno[1] := .F.
        aRetorno[2] := STR0117 //"O produto deve ser informado."
    EndIf

    If aRetorno[1] .And. (!oFiltros:HasProperty("05_PERIODO") .Or. oFiltros["05_PERIODO"] == Nil .Or. Empty(oFiltros["05_PERIODO"]))
        aRetorno[1] := .F.
        aRetorno[2] := STR0127 //"Deve ser informada a quantidade de períodos."
    EndIf
    
    FwFreeArray(aSemaforo)
Return aRetorno

/*/{Protheus.doc} montaColun
Realiza a criação de objeto Json que define as colunas utilizadas na grid de detalhamento do monitor
@type Class
@author douglas.heydt
@since 13/04/2023
@version P12.1.2310
@param  lExpResult, logico, Define se exporta resultado mostrando as colunas não visíveis por padrão
@return aColunas  , array , Contém as definições das colunas da grid do monitor
/*/
Static Function montaColun(lExpResult)
    Local aColunas := {}
    Local nIndice  := 0

    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"B8_FILIAL",STR0058,"string",lExpResult) //"Filial"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"B8_LOTECTL",STR0177,"string",.T.) //"Lote"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"B8_NUMLOTE",STR0119,"string",lExpResult) //"Sub-Lote"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"B8_PRODUTO",STR0074,"string",.T.) //"Produto"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"B1_DESC",STR0075,"string",lExpResult) //"Desc. Produto"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"B8_LOCAL",STR0095,"string",.T.) //"Armazém"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"B8_DTVALID",STR0178,"string",.T.) //"Data Validade"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"B8_QTDORI",STR0120,"string",.T.) //"Quant. Orig."
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"B8_SALDO",STR0121,"string",.T.) //"Saldo"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"B1_UM",STR0180,"string",lExpResult) //"Un. Medida"
Return aColunas
