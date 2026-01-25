#INCLUDE "TOTVS.CH"
#INCLUDE "PCPMONITOR.CH"
#INCLUDE "PCPMONITORDEF.CH"

/*/{Protheus.doc} StatusProducaoProduto
Classe para prover os dados do Monitor de acompanhamento de produção do produto
@type Class
@author renan.roeder
@since 08/05/2023
@version P12.1.2310
@return Nil
/*/
Class StatusProducaoProduto FROM LongNameClass
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
Method BuscaDados(oFiltros, cTipo, cSubTipo) Class StatusProducaoProduto
    Local aPeriodos  := PCPMonitorUtils():RetornaListaPeriodosPassado(oFiltros["03_TIPOPERIODO"],cValToChar(oFiltros["04_PERIODO"]))
    Local aProdData  := {}
    Local aDataPerda := {}
    Local cCodProd   := ""
    Local cTpPerDesc := ""
    Local cUnMedProd := ""
    Local dDataIni   := aPeriodos[Len(aPeriodos)][1]
    Local dDataFin   := aPeriodos[1][2]
    Local nIndex     := 0
    Local nIndTag    := 0
    Local nTotCateg  := 0
    Local oJsonDados := Nil
    Local oJsonRet   := JsonObject():New()

    oJsonRet["alturaMinimaWidget"] := "350px"
    oJsonRet["alturaMaximaWidget"] := "500px"
    oJsonRet["categorias"] := {}
    oJsonRet["series"]     := {}
    oJsonRet["tags"]       := {}
    oJsonRet["detalhes"]   := {}

    oFiltros["01_D3_FILIAL"] := PadR(oFiltros["01_D3_FILIAL"], FWSizeFilial())
    cCodProd   := PadR(oFiltros["02_D3_COD"],TamSX3("D3_COD")[1])
    cUnMedProd := Posicione("SB1",1,xFilial("SB1",oFiltros["01_D3_FILIAL"])+cCodProd,"B1_UM")
    oJsonDados := PCPMonitorUtils():RetornaQuantidadesProducaoProduto(oFiltros["01_D3_FILIAL"],cCodProd,dDataIni,dDataFin,oFiltros["03_TIPOPERIODO"])
    oJsonRet["categorias"] := oJsonDados["PRODUCAO"]:GetNames()
    nTotCateg := Len(oJsonRet["categorias"])
    For nIndex := 1 To nTotCateg
        aAdd(aProdData,oJsonDados["PRODUCAO"][oJsonRet["categorias"][nIndex]])
        aAdd(aDataPerda,oJsonDados["PERDA"][oJsonRet["categorias"][nIndex]])
    Next nIndex

    aAdd(oJsonRet["series"], JsonObject():New())
    oJsonRet["series"][1]["color"]   := COR_AZUL
    oJsonRet["series"][1]["data"]    := aProdData
    oJsonRet["series"][1]["tooltip"] := ""
    oJsonRet["series"][1]["label"]   := STR0231+" ("+cUnMedProd+")" //"Produção

    aAdd(oJsonRet["series"], JsonObject():New())
    oJsonRet["series"][2]["color"]   := COR_VERMELHO
    oJsonRet["series"][2]["data"]    := aDataPerda
    oJsonRet["series"][2]["tooltip"] := ""
    oJsonRet["series"][2]["label"]   := STR0230+" ("+cUnMedProd+")" //"Perda"

    cTpPerDesc := PCPMonitorUtils():RetornaDescricaoTipoPeriodo(oFiltros["03_TIPOPERIODO"])

    PCPMonitorUtils():AdicionaTagMonitor(oJsonRet["tags"],@nIndTag,"po-icon-calendar",dToC(dDataIni) + " - " + dToC(dDataFin))
    PCPMonitorUtils():AdicionaTagMonitor(oJsonRet["tags"],@nIndTag,"po-icon-calculator",cTpPerDesc)
    PCPMonitorUtils():AdicionaTagMonitor(oJsonRet["tags"],@nIndTag,"po-icon-bar-code",AllTrim(cCodProd))
    PCPMonitorUtils():AdicionaTagMonitor(oJsonRet["tags"],@nIndTag,"po-icon-star-filled",STR0231+": "+cValToChar(oJsonDados["TOTAL_PRODUCAO"]) + " " + cUnMedProd )//"Produção
    PCPMonitorUtils():AdicionaTagMonitor(oJsonRet["tags"],@nIndTag,"po-icon-star",STR0230+": "+cValToChar(oJsonDados["TOTAL_PERDA"]) + " " + cUnMedProd) //"Perda

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
Method BuscaDetalhes(oFiltros, nPagina) Class StatusProducaoProduto
    Local aPeriodos  := {}
    Local cAlias     := GetNextAlias()
    Local cCategoria := ""
    Local cCodProd   := ""
    Local cQuery     := ""
    Local cTpPerDesc := ""
    Local cUnMedProd := ""
    Local dDataIni   := dDatabase
    Local dDataFin   := dDatabase
    Local lExpResult := .F.
    Local oDados     := JsonObject():New()
    Local nPosCon    := 0
    Local nPosTag    := 0
    Local nStart     := 1
    Local nTamPagina := 20

    Default nPagina := 1

    If nPagina == 0
        lExpResult := .T.
    EndIf
    cCategoria := IIF(oFiltros:HasProperty("CATEGORIA"),oFiltros["CATEGORIA"],"")
    cSerie     := IIF(oFiltros:HasProperty("SERIE"),IF( STR0230 $ oFiltros["SERIE"] ,"Perda","Prod"),"") //"Perda"
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
    oFiltros["01_D3_FILIAL"] := PadR(oFiltros["01_D3_FILIAL"], FWSizeFilial())
    cTpPerDesc := PCPMonitorUtils():RetornaDescricaoTipoPeriodo(oFiltros["03_TIPOPERIODO"])
    cCodProd   := PadR(oFiltros["02_D3_COD"],TamSX3("D3_COD")[1])
    cUnMedProd := Posicione("SB1",1,xFilial("SB1",oFiltros["01_D3_FILIAL"])+cCodProd,"B1_UM")
    cQuery := " SELECT SD3.D3_FILIAL,SD3.D3_COD,SB1.B1_DESC,SD3.D3_UM,SD3.D3_EMISSAO,SD3.D3_QUANT,SD3.D3_OP,SD3.D3_PERDA "
    cQuery += " FROM " + RetSqlName("SD3") + " SD3 "
    cQuery += " LEFT OUTER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1",oFiltros["01_D3_FILIAL"])+"' AND SB1.B1_COD = SD3.D3_COD AND SB1.D_E_L_E_T_ = ' ' "
    cQuery += " WHERE SD3.D3_FILIAL = '"+xFilial("SD3",oFiltros["01_D3_FILIAL"])+"' "
    cQuery += "   AND SD3.D3_COD = '"+cCodProd+"' "
    cQuery += "   AND (SD3.D3_EMISSAO >= '"+dToS(dDataIni)+"' AND SD3.D3_EMISSAO <= '"+dToS(dDataFin)+"') "
    cQuery += "   AND SD3.D3_CF IN ('PR0','PR1') "
    cQuery += "   AND SD3.D3_ESTORNO <> 'S' "
    If cSerie == "Perda" 
        cQuery += "   AND SD3.D3_PERDA > 0 "
    EndIf
    cQuery += "   AND SD3.D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY SD3.D3_FILIAL,SD3.D3_COD,SD3.D3_EMISSAO "
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)
    If nPagina > 1
		nStart := ( (nPagina-1) * nTamPagina )
		If nStart > 0
			(cAlias)->(DbSkip(nStart))
		EndIf
	EndIf
    oDados["items"]   := {}
    oDados["columns"] := bscColunas(lExpResult)
    oDados["canExportCSV"] := .T.
    oDados["tags"]    := {}
    While (cAlias)->(!Eof())
        aAdd(oDados["items"], JsonObject():New())
        nPosCon++
        oDados["items"][nPosCon]["D3_FILIAL"]  := (cAlias)->D3_FILIAL
        oDados["items"][nPosCon]["D3_COD"]     := (cAlias)->D3_COD
        oDados["items"][nPosCon]["B1_DESC"]    := (cAlias)->B1_DESC
        oDados["items"][nPosCon]["D3_UM"]      := (cAlias)->D3_UM
        oDados["items"][nPosCon]["D3_EMISSAO"] := PCPMonitorUtils():FormataData((cAlias)->D3_EMISSAO,4)
        oDados["items"][nPosCon]["D3_QUANT"]   := (cAlias)->D3_QUANT
        oDados["items"][nPosCon]["D3_OP"]      := (cAlias)->D3_OP
        oDados["items"][nPosCon]["D3_PERDA"]   := (cAlias)->D3_PERDA
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
    PCPMonitorUtils():AdicionaTagMonitor(oDados["tags"],@nPosTag,"po-icon-bar-code",AllTrim(cCodProd))

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
Method CargaMonitor() Class StatusProducaoProduto
    Local aCategr   := {}
    Local aDetalhes := {}
    Local aTags     := {}
    Local lRet      := .T.
    Local nPosTag   := 0
    Local oCarga    := PCPMonitorCarga():New()
    Local oPrmAdc   := JsonObject():New()
    Local oSeries   := JsonObject():New()
        
    If !PCPMonitorCarga():monitorAtualizado("StatusProducaoProduto")
        oSeries["Produção (UN)"] := {{5,10,12,8,10,9}, COR_AZUL }
        oSeries["Perda (UN)"]    := {{1,2,5,1,3,4}, COR_VERMELHO }
        aCategr := {"16/04/23","23/04/23","30/04/23","07/05/23","14/05/23","21/05/23"}

        PCPMonitorUtils():AdicionaTagMonitor(aTags,@nPosTag,"po-icon-calendar","16/04/2023 - 28/05/2023")
        PCPMonitorUtils():AdicionaTagMonitor(aTags,@nPosTag,"po-icon-calculator",STR0088) //"Semanal"
        PCPMonitorUtils():AdicionaTagMonitor(aTags,@nPosTag,"po-icon-bar-code","CANETA")
        PCPMonitorUtils():AdicionaTagMonitor(aTags,@nPosTag,"po-icon-star-filled",STR0144+": 54 UN") //"Produção"
        PCPMonitorUtils():AdicionaTagMonitor(aTags,@nPosTag,"po-icon-star",STR0156+": 16 UN") //"Perda"

        oCarga:setaTitulo(STR0162) //"Acomp. Produção Produto"
        oCarga:setaObjetivo(STR0163) //"Acompanhar a quantidade produzida de um determinado produto em uma linha do tempo conforme o tipo de período parametrizado."
        oCarga:setaAgrupador("PCP")
        oCarga:setaFuncaoNegocio("StatusProducaoProduto")
        oCarga:setaTiposPermitidos("chart")
        oCarga:setaTiposGraficoPermitidos("line;column;bar")
        oCarga:setaTipoPadrao("chart")
        oCarga:setaTipoGraficoPadrao("line")
        oCarga:setaTipoDetalhe("detalhe")
        oCarga:setaExemploJsonGrafico(oSeries, aTags, aDetalhes,aCategr,"line")
        oCarga:setaPropriedadeFilial("01_D3_FILIAL")
        oCarga:setaPropriedadeProduto("02_D3_COD",.F.)
        oCarga:setaPropriedadePeriodoLinhaTempo("03_TIPOPERIODO","D","04_PERIODO")
        
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
Method ValidaPropriedades(oFiltros) Class StatusProducaoProduto
    Local aRetorno := {.T.,""}

    PCPMonitorUtils():ValidaPropriedadeFilial(oFiltros["01_D3_FILIAL"],aRetorno)
   
    If aRetorno[1] .And. Empty(oFiltros["02_D3_COD"])
        aRetorno[1] := .F.
        aRetorno[2] := STR0165 //"O filtro de Produto deve ser preenchido."
    Else
        If aRetorno[1]
            SB1->(dbSetOrder(1))
			If !SB1->(dbSeek(xFilial("SB1",PadR(oFiltros["01_D3_FILIAL"], FWSizeFilial())) + PadR(oFiltros["02_D3_COD"],GetSx3Cache("D3_COD","X3_TAMANHO")), .F.))
                aRetorno[1] := .F.
                aRetorno[2] := STR0164 //"O Produto não existe na Filial informada."
            EndIf
        EndIf
    EndIf
    If aRetorno[1] .And. Empty(oFiltros["04_PERIODO"])
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
@param  lExpResult, logico, Indica se trata todas as colunas como visible
@return aColunas  , array , Array de objetos com as colunas da table po-ui
/*/
Static Function bscColunas(lExpResult)
    Local aColunas := {}
    Local nIndice  := 0

    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"D3_FILIAL" ,STR0058,"string",lExpResult) //"Filial"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"D3_COD" ,STR0074,"string",.T.) //"Produto"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"B1_DESC" ,STR0195,"string",lExpResult) //"Desc. Prod."
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"D3_UM" ,STR0166,"string",lExpResult) //"UM"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"D3_EMISSAO" ,STR0167,"date", .T.) //"Dt. Emiss."
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"D3_OP" ,STR0076,"string",.T.) //"OP"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"D3_QUANT" ,STR0168,"number",.T.) //"Qt. Prod."
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"D3_PERDA" ,STR0230,"string",.T.) //"Perda"

Return aColunas
