#INCLUDE "TOTVS.CH"
#INCLUDE "PCPMONITOR.CH"
#INCLUDE "PCPMONITORDEF.CH"


/*/{Protheus.doc} StatusLotesAVencer
Classe para prover os dados do Monitor de Status dos Lotes  a vencer
@type Class
@author douglas.heydt
@since 12/04/2023
@version P12.1.2310
@return Nil
/*/
Class StatusLotesAVencer FROM LongNameClass
	Static Method BuscaDados(oFiltros, cTipo, cSubTipo)
	Static Method BuscaDetalhes(oFiltro,nPagina)
	Static Method CargaMonitor()
    Static Method ValidaPropriedades(oFiltros)
EndClass

/*/{Protheus.doc} CargaMonitor
Realiza a carga do Monitor padrão na base de dados
@type Method
@author douglas.heydt
@since 12/04/2023
@version P12.1.2310
@return lRet, logico, Indica se conseguiu realizar a carga
/*/
Method CargaMonitor() Class StatusLotesAVencer
    Local lRet      := .T.
    Local nIndLinha := 0
    Local nIndTag   := 0
    Local oCarga    := PCPMonitorCarga():New()
    Local oExemplo  := JsonObject():New()
    Local oStyle    := JsonObject():New()
    Local oStyleQtd := JsonObject():New()
    Local oPrmAdc   := JsonObject():New()
        
    If !PCPMonitorCarga():monitorAtualizado("StatusLotesAVencer")
        oExemplo["corFundo"]  := COR_VERDE_FORTE
        oExemplo["corTitulo"] := "white"
        oExemplo["tags"]      := {}
        oExemplo["linhas"]    := {}
        oStyle["color"] := "white"

        PCPMonitorUtils():AdicionaTagMonitor(oExemplo["tags"],@nIndTag,"po-icon-calendar","01/01/23 - 15/01/23")
        PCPMonitorUtils():AdicionaTagMonitor(oExemplo["tags"],@nIndTag,"po-icon-bar-code","GUIL01")
        
        oStyleQtd["font-weight"] := "bold"
        oStyleQtd["font-size"]   := "120px"
        oStyleQtd["line-height"] := "130px"
        oStyleQtd["text-align"]  := "center"
        oStyleQtd["color"]       := oStyle["color"]
        PCPMonitorUtils():AdicionaLinhaInformacao(oExemplo["linhas"],@nIndLinha,"15","po-sm-12",oStyleQtd:ToJson())
        PCPMonitorUtils():AdicionaLinhaInformacao(oExemplo["linhas"],@nIndLinha,"1350 Kg","po-font-title po-text-center po-sm-12 po-pt-1 bold-text",oStyle:ToJson())

        oCarga:setaTitulo(STR0110) //"Lotes a vencer"
        oCarga:setaObjetivo(STR0111) //"Apresentar o número de lotes e a quantidade a vencer de um determinado produto, dentro de um período futuro configurado, utilizando o conceito de semáforo para indicar o nível de atenção ou urgência."
        oCarga:setaAgrupador(STR0112) //"Estoque"
        oCarga:setaFuncaoNegocio("StatusLotesAVencer")
        oCarga:setaTiposPermitidos("chart;info")
        oCarga:setaTiposGraficoPermitidos("gauge")
        oCarga:setaTipoPadrao("info")
        oCarga:setaTipoGraficoPadrao("")
        oCarga:setaTipoDetalhe("detalhe")
        oCarga:setaExemploJsonTexto(.F.,oExemplo)

        oPrmAdc["04_TIPOSEMAFORO"]           := JsonObject():New()
        oPrmAdc["04_TIPOSEMAFORO"]["opcoes"] := STR0182+":L;"+STR0183+":Q" //"Número de Lotes //Quantidade do Produto
        oCarga:setaPropriedadeFilial("01_B8_FILIAL")
        oCarga:setaPropriedadeProduto("02_B8_PRODUTO")
        oCarga:setaPropriedade("03_SEMAFORO", STR0175, STR0176,1,30,0,"po-lg-8 po-xl-8 po-md-8 po-sm-12",/*oEstilos*/,/*cIcone*/,/*oPrmAdc*/) //"Atenção;Urgente (Lotes/Quantidade)" //"Semáforo (Lotes/Quantidade)"
        oCarga:setaPropriedade("04_TIPOSEMAFORO","L", STR0113,4,/*cTamanho*/,/*cDecimal*/,"po-lg-4 po-xl-4 po-md-4 po-sm-12",/*oEstilos*/,/*cIcone*/,oPrmAdc["04_TIPOSEMAFORO"]) //"Lotes/Quantidade"
        oCarga:setaPropriedadePeriodoAtual("05_TIPOPERIODO","D","06_PERIODO")
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
@author douglas.heydt
@since 09/02/2023
@version P12.1.2310
@param	oFiltros  , objeto Json, Contém as propriedades do monitor usadas para filtrar a query de busca
@param	cTipo     , caracter   , Tipo chart/info
@param	cSubTipo  , caracter   , Tipo de grafico pie/bar/column
@return cJsonDados, caracter   , Retorna um novo Json em formato texto, pronto para conversão e exibição no front
/*/
Method BuscaDados(oFiltros, cTipo, cSubTipo) Class StatusLotesAVencer
    Local aSemaforo  := StrTokArr(Replace(oFiltros["03_SEMAFORO"],",","."),";")
    Local cAliasQry  := GetNextAlias()
    Local cCodProd   := oFiltros["02_B8_PRODUTO"]
    Local cJsonDados := ""
    Local cQuery     := ""
    Local cUnMedida  := ""
    Local dFilterDat := PCPMonitorUtils():RetornaPeriodoFinal(oFiltros["05_TIPOPERIODO"],ddatabase,cValtoChar(oFiltros["06_PERIODO"]))
    Local nLotes     := 0
    Local nPos       := 0
    Local nSaldo     := 0
    Local oJsonRet   := JsonObject():New()

    oFiltros["01_B8_FILIAL"] := PadR(oFiltros["01_B8_FILIAL"], FWSizeFilial())
    cUnMedida  := Posicione("SB1",1,xFilial("SB1",oFiltros["01_B8_FILIAL"])+cCodProd,"B1_UM")

    cQuery += " SELECT "
    cQuery += "     SB8.B8_PRODUTO CODIGO_PRODUTO, "
    cQuery += "     SUM(SB8.B8_SALDO) SALDO, "
    cQuery += "     COUNT(SB8.R_E_C_N_O_) QUANTIDADE_LOTES "
    cQuery += " FROM "+RetSqlName("SB8")+" SB8 "
    cQuery += " WHERE SB8.B8_FILIAL = '" + xFilial("SB8",oFiltros["01_B8_FILIAL"]) + "' "
    cQuery += "   AND SB8.B8_PRODUTO = '" + cCodProd + "' "
    cQuery += "   AND SB8.B8_DTVALID BETWEEN '"+DTOS(ddatabase)+"' AND  '"+DTOS(dFilterDat)+"' "
    cQuery += "   AND SB8.B8_SALDO > 0 "
    cQuery += "   AND SB8.D_E_L_E_T_  = ' ' "
    cQuery += " GROUP BY SB8.B8_FILIAL,SB8.B8_PRODUTO  "

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)
    If  (cAliasQry)->(!Eof())
        cCodProd   := AllTrim((cAliasQry)->CODIGO_PRODUTO)
        nLotes     := (cAliasQry)->QUANTIDADE_LOTES
        nSaldo     := (cAliasQry)->SALDO
    End
    (cAliasQry)->(dbCloseArea())

    If cTipo == "info"
        montaInfo(oJsonRet,nLotes,nSaldo,aSemaforo,oFiltros["04_TIPOSEMAFORO"],cCodProd,cUnMedida)
    Else
        montaGraf(oJsonRet,nLotes,nSaldo,aSemaforo,oFiltros["04_TIPOSEMAFORO"],cCodProd,cUnMedida)
    EndIf

    oJsonRet["tags"]     := {}
    PCPMonitorUtils():AdicionaTagMonitor(oJsonRet["tags"],@nPos,"po-icon-calendar",cValToChar(ddatabase) + " - " + cValToChar(dFilterDat))
    PCPMonitorUtils():AdicionaTagMonitor(oJsonRet["tags"],@nPos,"po-icon-bar-code",cCodProd)
    If cTipo == "info" .And. oFiltros["04_TIPOSEMAFORO"] == "Q"
        PCPMonitorUtils():AdicionaTagMonitor(oJsonRet["tags"],@nPos,"po-icon-weight",STR0180 +": "+ cUnMedida) //"Un. Medida"
    EndIf
    If cTipo == "chart"
        PCPMonitorUtils():AdicionaTagMonitor(oJsonRet["tags"],@nPos,"po-icon-star-filled",IIF(oFiltros["04_TIPOSEMAFORO"] == "L",cValToChar(nSaldo) + " " + cUnMedida,cValToChar(nLotes) + IIF(nLotes > 1, " "+STR0178, " "+STR0177))) //"Lotes" //"Lote"
    EndIf
    cJsonDados :=  oJsonRet:toJson()

    FwFreeArray(aSemaforo)
    FreeObj(oJsonRet)
Return cJsonDados

/*/{Protheus.doc} ValidaPropriedades
Valida os dados informados nas propriedades do Monitor
@type Method
@author douglas.heydt
@since 12/04/2023
@version P12.1.2310
@param  oFiltros, objeto json, Objeto json com os filtros para a consulta dos dados
@return aRetorno, array      , [1] logico - indica se os dados são válidos [2] caracter - mensagem de erro
/*/
Method ValidaPropriedades(oFiltros) Class StatusLotesAVencer
    Local aRetorno  := {.T.,""}
    Local aSemaforo := {}
    Local nX        := 1

    PCPMonitorUtils():ValidaPropriedadeFilial(oFiltros["01_B8_FILIAL"],aRetorno)

	If aRetorno[1] .And. Empty(oFiltros["02_B8_PRODUTO"])
        aRetorno[1] := .F.
        aRetorno[2] := STR0117 //"O produto deve ser informado."
    EndIf

    If aRetorno[1] .And. oFiltros["05_TIPOPERIODO"] == "X"
        If !oFiltros:HasProperty("06_PERIODO") .Or. oFiltros["06_PERIODO"] == Nil .Or. Empty(oFiltros["06_PERIODO"])
            aRetorno[1] := .F.
            aRetorno[2] := STR0069 //"Deve ser informada a quantidade de dias para o período personalizado."
        EndIf
    EndIf

    If aRetorno[1]
        If !oFiltros:HasProperty("03_SEMAFORO") .Or. oFiltros["03_SEMAFORO"] == Nil .Or. Empty(oFiltros["03_SEMAFORO"])
            aRetorno[1] := .F.
            aRetorno[2] := STR0115 //"O campo 'Semáforo' deve ser preenchido com 2 valores separados por ponto e vírgula (ex.: '10;100'), definindo o número de lotes/quantidade que indicam Atenção e Urgência, respectivamente"
        Else 
            aSemaforo := STRTOKARR(Replace(oFiltros["03_SEMAFORO"],",","."),";")
            If Len(aSemaforo) <> 2
                aRetorno[1] := .F.
                aRetorno[2] := STR0115 //"O campo 'Semáforo' deve ser preenchido com 2 valores separados por ponto e vírgula (ex.: '10;100'), definindo o número de lotes/quantidade que indicam Atenção e Urgência, respectivamente"
            Else
                For nX := 1 To 2
                    If Empty(aSemaforo[nX])
                        aRetorno[1] := .F.
                        aRetorno[2] := STR0115 //"O campo 'Semáforo' deve ser preenchido com 2 valores separados por ponto e vírgula (ex.: '10;100'), definindo o número de lotes/quantidade que indicam Atenção e Urgência, respectivamente"
                        Exit
                    EndIf
                Next nX
                If Val(aSemaforo[1]) >= Val(aSemaforo[2])
                    aRetorno[1] := .F.
                    aRetorno[2] := STR0116 //"No campo 'Semáforo', o primeiro valor, referente ao status 'Atenção', deve ser menor que o segundo, que representa 'Urgência'"
                EndIf
            EndIf
        EndIf
    EndIf
    FwFreeArray(aSemaforo)
Return aRetorno

/*/{Protheus.doc} BuscaDetalhes
Realiza a busca dos dados para montar os detalhes do Monitor
@type Method
@author douglas.heydt
@since 12/04/2023
@version P12.1.2310
@return Nil
/*/
Method BuscaDetalhes(oFiltro,nPagina) Class StatusLotesAVencer
    Local cAlias     := GetNextAlias()
    Local cQuery     := ""
    Local dDataFim   := PCPMonitorUtils():RetornaPeriodoFinal(AllTrim(oFiltro["05_TIPOPERIODO"]),ddatabase,cValToChar(oFiltro["06_PERIODO"]))
    Local lExpResult := .F.
    Local nIndTag    := 0
    Local nPos       := 0
    Local nStart     := 1
    Local nTamPagina := 20
    Local oDados     := JsonObject():New()

    Default nPagina := 1

    If nPagina == 0
        lExpResult := .T.
    EndIf

    oFiltro["01_B8_FILIAL"] := PadR(oFiltro["01_B8_FILIAL"], FWSizeFilial())
    oDados["items"]        := {}
    oDados["columns"]      := montaColun(lExpResult)
    oDados["canExportCSV"] := .T.
    oDados["tags"]         := {}
    PCPMonitorUtils():AdicionaTagMonitor(oDados["tags"],@nIndTag,"po-icon-calendar",dToC(dDatabase) + " - " + dToC(dDataFim))
    PCPMonitorUtils():AdicionaTagMonitor(oDados["tags"],@nIndTag,"po-icon-bar-code",oFiltro["02_B8_PRODUTO"])

    cQuery += " SELECT "
    cQuery += "     SB8.B8_FILIAL,  SB8.B8_QTDORI,  SB8.B8_PRODUTO,  SB8.B8_LOCAL,  SB8.B8_DTVALID, "
    cQuery += "     SB8.B8_SALDO, SB8.B8_LOTECTL, SB1.B1_DESC, SB8.B8_NUMLOTE, SB1.B1_UM "
    cQuery += " FROM "+RetSqlName("SB8")+" SB8 "
    cQuery += " LEFT JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1",oFiltro["01_B8_FILIAL"])+"' AND SB1.B1_COD = SB8.B8_PRODUTO AND SB1.D_E_L_E_T_ = ' ' "
    cQuery += " WHERE SB8.B8_FILIAL = '" + xFilial("SB8",oFiltro["01_B8_FILIAL"]) + "' "
    cQuery += "   AND SB8.B8_PRODUTO = '"+oFiltro["02_B8_PRODUTO"]+"'  "
    cQuery += "   AND SB8.B8_DTVALID BETWEEN '"+DTOS(ddatabase)+"' AND  '"+DTOS(dDataFim)+"' "
    cQuery += "   AND SB8.B8_SALDO > 0 "
    cQuery += "   AND SB8.D_E_L_E_T_  = ' ' "
    cQuery += " ORDER BY SB8.B8_FILIAL,SB8.B8_DTVALID,SB8.B8_LOTECTL  "
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)

    If nPagina > 1
		nStart := ( (nPagina-1) * nTamPagina )
		If nStart > 0
			(cAlias)->(DbSkip(nStart))
		EndIf
	EndIf

    While (cAlias)->(!Eof())
        aAdd(oDados["items"], JsonObject():New())
        nPos++
        oDados["items"][nPos]["B8_FILIAL"  ] := (cAlias)->B8_FILIAL
        oDados["items"][nPos]["B8_LOTECTL" ] := (cAlias)->B8_LOTECTL
        oDados["items"][nPos]["B8_NUMLOTE" ] := (cAlias)->B8_NUMLOTE
        oDados["items"][nPos]["B8_PRODUTO" ] := (cAlias)->B8_PRODUTO
        oDados["items"][nPos]["B1_DESC"    ] := (cAlias)->B1_DESC
        oDados["items"][nPos]["B8_QTDORI"  ] := (cAlias)->B8_QTDORI
        oDados["items"][nPos]["B1_UM"      ] := (cAlias)->B1_UM
        oDados["items"][nPos]["B8_LOCAL"   ] := (cAlias)->B8_LOCAL
        oDados["items"][nPos]["B8_DTVALID" ] := PCPMonitorUtils():FormataData((cAlias)->B8_DTVALID, 5)
        oDados["items"][nPos]["B8_SALDO"   ] := (cAlias)->B8_SALDO
        (cAlias)->(dbSkip())
        If !lExpResult .And. nPos >= nTamPagina
            Exit
        EndIf
    End
    oDados["hasNext"] := (cAlias)->(!Eof())
    (cAlias)->(dbCloseArea())
Return oDados:ToJson()

/*/{Protheus.doc} montaColun
Realiza a criação de objeto Json que define as colunas utilizadas na grid de detalhamento do monitor
@type Static Function
@author douglas.heydt
@since 13/04/2023
@version P12.1.2310
@return aColumns, array objetos, Contém as definições das colunas da grid do monitor
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
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"B8_DTVALID",STR0179,"string",.T.) //"Validade"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"B8_QTDORI",STR0120,"string",.T.) //"Quant. Orig."
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"B8_SALDO",STR0121,"string",.T.) //"Saldo"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"B8_UM",STR0180,"string",lExpResult) //"Un. Medida"
Return aColunas

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

/*/{Protheus.doc} montaGraf
Monta objeto json com os dados para mostrar o gauge
@type Static Function
@author renan.roeder
@since 01/06/2023
@version P12.1.2310
@param  oJsonRet  , objeto json, Objeto json que receberá os dados do gauge
@param  nLotes    , numerico   , Número de lotes retornado da consulta
@param  nSaldo    , numerico   , Saldo dos lotes retornados na consulta
@param  aSemaforo , array      , Array com os números do semáforo
@param  cTipoSemaf, caracter   , L - Quantidade Lotes / Q - Saldo Lotes
@param  cProduto  , caracter   , Codigo do produto
@param  cUnMedida , caracter   , Unidade de medida do produto
@return Nil
/*/
Static Function montaGraf(oJsonRet,nLotes,nSaldo,aSemaforo,cTipoSemaf,cProduto,cUnMedida)
    Local cLabel     := ""
    Local cValorFim  := ""
    Local cValSemaf1 := aSemaforo[1]
    Local cValSemaf2 := aSemaforo[2]
    Local nQuant     := 0
    Local nValorFim  := 0
    Local nValSemaf1 := Val(cValSemaf1)
    Local nValSemaf2 := Val(cValSemaf2)
    Local oGauge     := PCPMonitorGauge():New()

    If cTipoSemaf == "L"
        nQuant  := nLotes
        cLabel  := IIF(nLotes > 1, STR0178, STR0177) //"Lotes" //"Lote"
    Else
        nQuant  := nSaldo
        cLabel  := cUnMedida
    EndIf
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
    oGauge:SetMaxValue(nValorFim)
    oGauge:SetValue(nQuant)
    oGauge:SetValueStyle("color",retCorSmf(nQuant,nValSemaf1,nValSemaf2))
    oGauge:SetValueStyle("font-weight","bold")
    oGauge:SetLabel(cLabel)
    oGauge:SetLabelStyle("font-weight","bold")
    oGauge:SetThreshold("0",COR_VERDE_FORTE)
    oGauge:SetThreshold(cValSemaf1,COR_AMARELO_QUEIMADO)
    oGauge:SetThreshold(cValSemaf2,COR_VERMELHO_FORTE)
    If Val(cValSemaf1) > 0
        oGauge:SetMarker("0")
    Endif
    oGauge:SetMarker(cValSemaf1)
    oGauge:SetMarker(cValSemaf2)
    oGauge:SetMarker(cValorFim)
    oJsonRet["gauge"]      := oGauge:GetJsonObject()
    FreeObj(oGauge)
Return

/*/{Protheus.doc} montaInfo
Monta objeto json com os dados para mostrar o gráfico de informações
@type Static Function
@author renan.roeder
@since 01/06/2023
@version P12.1.2310
@param  oJsonRet  , objeto json, Objeto json que receberá os dados do gauge
@param  nLotes    , numerico   , Número de lotes retornado da consulta
@param  nSaldo    , numerico   , Saldo dos lotes retornados na consulta
@param  aSemaforo , array      , Array com os números do semáforo
@param  cTipoSemaf, caracter   , L - Quantidade Lotes / Q - Saldo Lotes
@param  cProduto  , caracter   , Codigo do produto
@param  cUnMedida , caracter   , Unidade de medida do produto
@return Nil
/*/
Static Function montaInfo(oJsonRet,nLotes,nSaldo,aSemaforo,cTipoSemaf,cProduto,cUnMedida)
    Local cTxtPrc    := ""
    Local cTxtSec    := ""
    Local nIndLinha  := 0
    Local nQuant     := 0
    Local nValSemaf1 := Val(aSemaforo[1])
    Local nValSemaf2 := Val(aSemaforo[2])
    Local oStyle     := JsonObject():New()
    Local oStyleQtd  := JsonObject():New()

    oJsonRet["corTitulo"] := "white"
    oStyle["color"] := "white"
    oJsonRet["alturaMinimaWidget"] := "350px"
    oJsonRet["alturaMaximaWidget"] := "500px"
    oJsonRet["linhas"] := {}

    If cTipoSemaf == "L"
        nQuant  := nLotes
        cTxtPrc := cValToChar(nLotes)
        cTxtSec := cValToChar(nSaldo) + " " + cUnMedida
    Else
        nQuant  := nSaldo
        cTxtPrc := cValToChar(nSaldo)
        cTxtSec := cValToChar(nLotes) + IIF(nLotes > 1, " "+STR0178, " "+STR0177) //"Lotes" // "Lote"
    EndIf
    If nLotes > 0
        oJSonRet["corFundo"] := retCorSmf(nQuant,nValSemaf1,nValSemaf2)

        If oJSonRet["corFundo"] == COR_AMARELO_ESCURO
            oStyle["color"]       := "black"
            oJsonRet["corTitulo"] := "black"
        EndIf
        oStyleQtd["font-weight"] := "bold"
        oStyleQtd["font-size"]   := "120px"
        oStyleQtd["line-height"] := "130px"
        oStyleQtd["text-align"]  := "center"
        oStyleQtd["color"]       := oStyle["color"]
        oStyleQtd["cursor"]      := "pointer"
        PCPMonitorUtils():AdicionaLinhaInformacao(oJsonRet["linhas"],@nIndLinha,cTxtPrc,"po-sm-12",oStyleQtd:ToJson(),.T.)
        PCPMonitorUtils():AdicionaLinhaInformacao(oJsonRet["linhas"],@nIndLinha,cTxtSec,"po-font-title po-text-center po-sm-12 po-pt-1 bold-text",oStyle:ToJson())
    Else
        oJsonRet["corFundo"] := COR_VERDE_FORTE
        PCPMonitorUtils():AdicionaLinhaInformacao(oJsonRet["linhas"],@nIndLinha,STR0123,"po-font-text-large-bold po-text-center po-sm-12 po-pt-4",oStyle:ToJson()) //"Nenhum lote do produto vencerá no período selecionado."
    EndIf
Return
