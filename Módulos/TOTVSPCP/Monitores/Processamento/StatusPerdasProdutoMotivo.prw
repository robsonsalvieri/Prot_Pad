#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PCPMONITOR.CH"
#INCLUDE "PCPMONITORDEF.CH"

/*/{Protheus.doc} StatusPerdasProdutoMotivo
Classe para prover os dados do Monitor de Motivo de Perdas
@type Class
@author parffit.silva
@since 18/12/2024
@version P12.1.2410
@return Nil
/*/
Class StatusPerdasProdutoMotivo FROM LongNameClass
    Static Method BuscaDados(oFiltros, cTipo, cSubTipo)
    Static Method BuscaDetalhes(oFiltros, nPagina)
    Static Method CargaMonitor()
    Static Method ValidaPropriedades(oFiltros)
EndClass

/*/{Protheus.doc} CargaMonitor
Realiza a carga do monitor no banco de dados, permitindo a exibição de um exemplo desse monitor para 
ser escolhido para uso na aplicação.
@type Class
@author parffit.silva
@since 18/12/2024
@version P12.1.2410
@return lRet, logico, Define se a carga do Monitor foi realizada com sucesso
/*/
Method CargaMonitor() Class StatusPerdasProdutoMotivo
    Local aCategoria := {}
    Local aDetalhes  := {}
    Local aTags      := {}
    Local lRet       := .T.
    Local nPosTag    := 0
    Local oCarga     := PCPMonitorCarga():New()
    Local oPrmAdc    := JsonObject():New()
    Local oSeries    := JsonObject():New()
        
    If !PCPMonitorCarga():monitorAtualizado("StatusPerdasProdutoMotivo")
        oSeries["FH (UN)"] := {{5,10,12,8,10,9}, COR_AZUL }
        oSeries["FP (UN)"] := {{1,2,5,1,3,4}, COR_VERMELHO }
        oSeries["RB (UN)"] := {{0,1,0,0,0,0}, COR_VERDE }
        aCategoria := {"16/04/23","23/04/23","30/04/23","07/05/23","14/05/23","21/05/23"}

        PCPMonitorUtils():AdicionaTagMonitor(aTags,@nPosTag,"po-icon-calendar","01/02/2023 - 28/02/2023")
        PCPMonitorUtils():AdicionaTagMonitor(aTags,@nPosTag,"po-icon-calculator",STR0088) //"Semanal"
        PCPMonitorUtils():AdicionaTagMonitor(aTags,@nPosTag,"po-icon-bar-code","CANETA")
        PCPMonitorUtils():AdicionaTagMonitor(aTags,@nPosTag,"po-icon-star",STR0156+": 71 UN") //"Perda"

        oCarga:setaTitulo(STR0284) //"Perdas do Produto Por Motivo"
        oCarga:setaObjetivo(STR0285) //"Acompanhar as quantidades perdidas de um determinado produto em uma linha do tempo conforme o tipo de período parametrizado, classificadas por seu motivo de perda."
        oCarga:setaAgrupador("PCP")
        oCarga:setaFuncaoNegocio("StatusPerdasProdutoMotivo")
        oCarga:setaTiposPermitidos("chart")
        oCarga:setaTiposGraficoPermitidos("line;column;bar")
        oCarga:setaTipoPadrao("chart")
        oCarga:setaTipoGraficoPadrao("line")
        oCarga:setaTipoDetalhe("detalhe")
        oCarga:setaExemploJsonGrafico(oSeries, aTags, aDetalhes, aCategoria, "line")
       
        oCarga:setaPropriedadeFilial("01_BC_FILIAL")
        oCarga:setaPropriedadeProduto("02_BC_PRODUTO",.F.)
        oCarga:setaPropriedadeRecurso("03_BC_RECURSO",.T.)
        oCarga:setaPropriedadeLookupTabela("04_BC_MOTIVO",STR0275,.T.,"CYO","CYO_CDRF","CYO_DSRF") //"Motivos de Perda"
        oCarga:setaPropriedadePeriodoLinhaTempo("05_TIPOPERIODO","D","06_PERIODO")
        
        If !oCarga:gravaMonitorPropriedades()
            lRet := .F.
        EndIf
        oCarga:Destroy()
    EndIf
    FwFreeArray(aCategoria)
    FwFreeArray(aDetalhes)
    FwFreeArray(aTags)
    FreeObj(oPrmAdc)
    FreeObj(oSeries)
Return lRet


/*/{Protheus.doc} BuscaDados
Responsável por realizar a busca dos dados que serão exibidos no monitor (gráfico ou texto)
@type Class
@author parffit.silva
@since 18/12/2024
@version P12.1.2410
@param	oFiltros  , objeto Json, Contém as propriedades do monitor usadas para filtrar a query de busca
@param	cTipo     , caracter   , Tipo chart/info
@param	cSubTipo  , caracter   , Tipo de grafico pie/bar/column
@return cJsonDados, caracter   , Retorna um novo Json em formato texto, pronto para conversão e exibição no front
/*/
Method BuscaDados(oFiltros, cTipo, cSubTipo) Class StatusPerdasProdutoMotivo
    Local aPeriodos  := PCPMonitorUtils():RetornaListaPeriodosPassado(oFiltros["05_TIPOPERIODO"],cValToChar(oFiltros["06_PERIODO"]))
    Local aDataSerie := {}
    Local aMotivos   := {}
    Local cAliasQry  := GetNextAlias()
    Local cJsonDados := ""
    Local cQuery     := ""
    Local cTpPerDesc := ""
    Local cUnMed     := ""
    Local dDataAjust := Nil
    Local dDataIni   := aPeriodos[Len(aPeriodos)][1]
    Local dDataFin   := aPeriodos[1][2]
    Local nIndice    := 0
    Local nIndiceMot := 0
    Local nPosTag    := 0
    Local nTotApont  := 0
    Local nTotCateg  := 0
    Local nTotQuant  := 0
    Local oCategoria := JsonObject():New()
    Local oDados     := JsonObject():New()
    Local oJsonRet   := JsonObject():New()

    oJsonRet["alturaMinimaWidget"] := "350px"
    oJsonRet["alturaMaximaWidget"] := "500px"
    oJsonRet["categorias"]         := {}
    oJsonRet["series"]             := {}
    oJsonRet["tags"]               := {}
    oJsonRet["detalhes"]           := {}

    oFiltros["01_BC_FILIAL"] := PadR(oFiltros["01_BC_FILIAL"], FWSizeFilial())
    cUnMed := Posicione("SB1",1,xFilial("SB1",oFiltros["01_BC_FILIAL"])+oFiltros["02_BC_PRODUTO"],"B1_UM")

    cQuery := montaQuery(oFiltros, @dDataIni, @dDataFin,1)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

    nIndice := 0
    While (cAliasQry)->(!Eof())
        dDataAjust := dToC(PCPMonitorUtils():RetornaPeriodoInicial(oFiltros["05_TIPOPERIODO"],sToD((cAliasQry)->BC_DATA)))

        If !oCategoria:HasProperty(dDataAjust)
            oCategoria[dDataAjust] := JsonObject():New()
        EndIf

        nTotApont += (cAliasQry)->NR_APONT
        nTotQuant += (cAliasQry)->QT_PERDA

        If !oDados:HasProperty(AllTrim((cAliasQry)->BC_MOTIVO))
            ++nIndice

            oDados[AllTrim((cAliasQry)->BC_MOTIVO)] := JsonObject():New()
            oDados[AllTrim((cAliasQry)->BC_MOTIVO)]["Color"] := PCPMonitorUtils():RetornaCorSerie(nIndice)
        EndIf

        If oDados[AllTrim((cAliasQry)->BC_MOTIVO)]:HasProperty(dDataAjust)
            oDados[AllTrim((cAliasQry)->BC_MOTIVO)][dDataAjust] += (cAliasQry)->QT_PERDA
        Else
            oDados[AllTrim((cAliasQry)->BC_MOTIVO)][dDataAjust] := (cAliasQry)->QT_PERDA
        EndIf

        (cAliasQry)->(dbSkip())
    End
    (cAliasQry)->(dbCloseArea())

    oJsonRet["categorias"] := oCategoria:GetNames()
    nTotCateg := Len(oJsonRet["categorias"])
    aMotivos  := oDados:GetNames()
    For nIndiceMot := 1 To Len(aMotivos)
        aDataSerie := {}

        For nIndice := 1 To nTotCateg
            If oDados[aMotivos[nIndiceMot]]:HasProperty(oJsonRet["categorias"][nIndice])
                aAdd(aDataSerie,oDados[aMotivos[nIndiceMot]][oJsonRet["categorias"][nIndice]])
            Else
                aAdd(aDataSerie,0)
            EndIf
        Next nIndice
    
        aAdd(oJsonRet["series"], JsonObject():New())
        oJsonRet["series"][nIndiceMot]["color"]   := oDados[aMotivos[nIndiceMot]]["Color"]
        oJsonRet["series"][nIndiceMot]["data"]    := aDataSerie
        oJsonRet["series"][nIndiceMot]["tooltip"] := ""
        oJsonRet["series"][nIndiceMot]["label"]   := IIF(AllTrim(aMotivos[nIndiceMot])<>"",aMotivos[nIndiceMot],"-") + " ("+cUnMed+")"
    Next nIndiceMot

    cTpPerDesc := PCPMonitorUtils():RetornaDescricaoTipoPeriodo(oFiltros["05_TIPOPERIODO"])

    PCPMonitorUtils():AdicionaTagMonitor(oJsonRet["tags"],@nPosTag,"po-icon-calendar",dToC(dDataIni) + " - " + dToC(dDataFin))
    PCPMonitorUtils():AdicionaTagMonitor(oJsonRet["tags"],@nPosTag,"po-icon-calculator",cTpPerDesc)
    PCPMonitorUtils():AdicionaTagMonitor(oJsonRet["tags"],@nPosTag,"po-icon-bar-code",oFiltros["02_BC_PRODUTO"])
    PCPMonitorUtils():AdicionaTagMonitor(oJsonRet["tags"],@nPosTag,"po-icon-star",STR0156 + ": " + cValToChar(nTotQuant) + " " + cUnMed) //"Perda"
    PCPMonitorUtils():AdicionaTagMonitor(oJsonRet["tags"],@nPosTag,"po-icon-star-filled",cValToChar(nTotApont) + IIF(nTotApont > 1," "+STR0197," "+STR0280)) //"Apontamentos" //"Apontamento"

    If oFiltros:HasProperty("04_BC_MOTIVO") .And. ValType(oFiltros["04_BC_MOTIVO"]) == "A"
        For nIndice := 1 To Len(oFiltros["04_BC_MOTIVO"])
            PCPMonitorUtils():AdicionaTagMonitor(oJsonRet["tags"],@nPosTag,"po-icon-filter",oFiltros["04_BC_MOTIVO"][nIndice])
        Next nIndice
    EndIf

    If oFiltros:HasProperty("03_BC_RECURSO") .And. ValType(oFiltros["03_BC_RECURSO"]) == "A"
        For nIndice := 1 To Len(oFiltros["03_BC_RECURSO"])
            PCPMonitorUtils():AdicionaTagMonitor(oJsonRet["tags"],@nPosTag,"po-icon-manufacture",oFiltros["03_BC_RECURSO"][nIndice])
        Next nIndice
    EndIf

    cJsonDados := oJsonRet:toJson()
    FwFreeArray(aDataSerie)
    FwFreeArray(aMotivos)
    FreeObj(oCategoria)
    FreeObj(oDados)
    FreeObj(oJsonRet)
Return cJsonDados

/*/{Protheus.doc} BuscaDetalhes
Responsável por realizar a busca dos dados que serão exibidos no detalhamento do monitor
@type Class
@author parffit.silva
@since 18/12/2024
@version P12.1.2410
@param	oFiltros  , objeto Json , Contém as propriedades do monitor usadas para filtrar a query de busca
@param	nPagina   , numerico    , Número da página desejada para busca
@return cJsonDados, caracter    , Retorna um novo Json em formato texto, pronto para conversão e exibição no front
/*/
Method BuscaDetalhes(oFiltros, nPagina) Class StatusPerdasProdutoMotivo
    Local aPeriodos  := {}
    Local cAliasQry  := GetNextAlias()
    Local cCategoria := ""
    Local cJsonDados := ""
    Local cQuery     := ""
    Local cRoteiro   := ""
    Local cSerie     := ""
    Local cTpPerDesc := ""
    Local cUnMed     := ""
    Local dDataIni   := dDataBase
    Local dDataFin   := dDataBase
    Local lExpResult := .F.
    Local nIndice    := 0
    Local nPos       := 0
    Local nPosTag    := 0
    Local nStart     := 0
    Local oDados     := JsonObject():New()

    Default nPagina    := 1
    Default nTamPagina := 20

    If nPagina == 0
        lExpResult := .T.
    EndIf

    cCategoria := IIF(oFiltros:HasProperty("CATEGORIA"),oFiltros["CATEGORIA"],"")
    If !Empty(cCategoria)
        dDataIni := cToD(cCategoria)
        dDataFin := PCPMonitorUtils():RetornaPeriodoFinal(oFiltros["05_TIPOPERIODO"],cToD(cCategoria))
        If dDataFin > dDatabase
            dDataFin := dDatabase
        EndIf
    Else
        aPeriodos := PCPMonitorUtils():RetornaListaPeriodosPassado(oFiltros["05_TIPOPERIODO"],cValToChar(oFiltros["06_PERIODO"]))
        dDataIni := aPeriodos[Len(aPeriodos)][1]
        dDataFin := aPeriodos[1][2]
    EndIf

    If !Empty(oFiltros["SERIE"])
        cSerie := Left(oFiltros["SERIE"],RAt("(",oFiltros["SERIE"])-2)
    EndIf
    cTpPerDesc := PCPMonitorUtils():RetornaDescricaoTipoPeriodo(oFiltros["05_TIPOPERIODO"])

    oFiltros["01_BC_FILIAL"] := PadR(oFiltros["01_BC_FILIAL"], FWSizeFilial())
    cUnMed := Posicione("SB1",1,xFilial("SB1",oFiltros["01_BC_FILIAL"])+oFiltros["02_BC_PRODUTO"],"B1_UM")

    cQuery := montaQuery(oFiltros, @dDataIni, @dDataFin,2)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

    oDados["items"]   := {}
    oDados["columns"] := bscColunas(lExpResult,cSerie)
    oDados["headers"] := {}
    oDados["tags"] := {}
    oDados["canExportCSV"] := .T.

    PCPMonitorUtils():AdicionaTagMonitor(oDados["tags"],@nPosTag,"po-icon-calendar",dToC(dDataIni) + " - " + dToC(dDataFin))

    If Empty(cCategoria)
        PCPMonitorUtils():AdicionaTagMonitor(oDados["tags"],@nPosTag,"po-icon-calculator",cTpPerDesc)
    EndIf

    If !Empty(oFiltros["SERIE"])
        PCPMonitorUtils():AdicionaTagMonitor(oDados["tags"],@nPosTag,"po-icon-filter",cSerie + " " + IIF(cSerie <> "-",Capital(AllTrim(Posicione("CYO",1,xFilial("CYO",oFiltros["01_BC_FILIAL"])+cSerie, "CYO_DSRF"))),STR0286))
    Else
        If oFiltros:HasProperty("04_BC_MOTIVO") .And. ValType(oFiltros["04_BC_MOTIVO"]) == "A"
            For nIndice := 1 To Len(oFiltros["04_BC_MOTIVO"])
                PCPMonitorUtils():AdicionaTagMonitor(oDados["tags"],@nPosTag,"po-icon-filter",oFiltros["04_BC_MOTIVO"][nIndice])
            Next nIndice
        EndIf
    EndIf

    PCPMonitorUtils():AdicionaTagMonitor(oDados["tags"],@nPosTag,"po-icon-bar-code",oFiltros["02_BC_PRODUTO"])

    If oFiltros:HasProperty("03_BC_RECURSO") .And. ValType(oFiltros["03_BC_RECURSO"]) == "A"
        For nIndice := 1 To Len(oFiltros["03_BC_RECURSO"])
            PCPMonitorUtils():AdicionaTagMonitor(oDados["tags"],@nPosTag,"po-icon-manufacture",oFiltros["03_BC_RECURSO"][nIndice])
        Next nIndice
    EndIf

    If nPagina > 1
		nStart := ( (nPagina-1) * nTamPagina )
		If nStart > 0
			(cAliasQry)->(DbSkip(nStart))
		EndIf
	EndIf

	nPos := 0
    While (cAliasQry)->(!Eof())
        aAdd(oDados["items"], JsonObject():New())
        nPos++
        cRoteiro := IIF(!Empty((cAliasQry)->C2_ROTEIRO),(cAliasQry)->C2_ROTEIRO,IIF(!Empty((cAliasQry)->B1_OPERPAD),(cAliasQry)->B1_OPERPAD,"01"))

        oDados["items"][nPos]["BC_FILIAL"]  := (cAliasQry)->BC_FILIAL
        oDados["items"][nPos]["BC_TIPO"]    := (cAliasQry)->BC_TIPO
        oDados["items"][nPos]["BC_MOTIVO"]  := (cAliasQry)->BC_MOTIVO
        oDados["items"][nPos]["CYO_DSRF"]   := AllTrim(Posicione("CYO",1,xFilial("CYO",oFiltros["01_BC_FILIAL"])+(cAliasQry)->BC_MOTIVO, "CYO_DSRF"))
        oDados["items"][nPos]["BC_OP"]      := (cAliasQry)->BC_OP
        oDados["items"][nPos]["BC_OPERAC"]  := (cAliasQry)->BC_OPERAC
        oDados["items"][nPos]["G2_DESCRI"]  := AllTrim(Posicione("SG2",1,xFilial("SG2",oFiltros["01_BC_FILIAL"])+(cAliasQry)->BC_PRODUTO+cRoteiro+(cAliasQry)->BC_OPERAC,"G2_DESCRI"))
        oDados["items"][nPos]["BC_PRODUTO"] := (cAliasQry)->BC_PRODUTO
        oDados["items"][nPos]["B1_DESC"]    := (cAliasQry)->B1_DESC
        oDados["items"][nPos]["BC_LOCORIG"] := (cAliasQry)->BC_LOCORIG
        oDados["items"][nPos]["BC_QUANT"]   := (cAliasQry)->BC_QUANT
        oDados["items"][nPos]["B1_UM"]      := (cAliasQry)->B1_UM
        oDados["items"][nPos]["BC_OPERADO"] := (cAliasQry)->BC_OPERADO
        oDados["items"][nPos]["BC_DATA"]    := PCPMonitorUtils():FormataData((cAliasQry)->BC_DATA, 5)
        oDados["items"][nPos]["BC_RECURSO"] := (cAliasQry)->BC_RECURSO
        oDados["items"][nPos]["H1_DESCRI"]  := PCPMonitorUtils():RetornaDescricaoRecurso(oFiltros["01_BC_FILIAL"],(cAliasQry)->BC_RECURSO)

        (cAliasQry)->(dbSkip())

        //Verifica tamanho da página
        If !lExpResult .And. nPos >= nTamPagina
            Exit
        EndIf
    End
    oDados["hasNext"] := (cAliasQry)->(!Eof())
    (cAliasQry)->(dbCloseArea())

    cJsonDados := oDados:toJson()

    FwFreeArray(aPeriodos)
    FreeObj(oDados)
Return cJsonDados

/*/{Protheus.doc} bscColunas
Cria array de objetos no formato poTableColumn com as colunas da table de detalhamento
@type Static Function
@author parffit.silva
@since 18/12/2024
@version P12.1.2410
@param  lExpResult, logico, Indica se trata todas as colunas como visible
@param  cSerie    , caracter, Motivo selecionado para filtrar detalhes (quando selecionado)
@return aColumns, array objetos, Contém as definições das colunas da grid do monitor
/*/
Static Function bscColunas(lExpResult, cSerie)
    Local aColunas   := {}
    Local aLabels    := {}
    Local nIndice    := 0
    Local nIndLabels := 0

    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"BC_FILIAL",STR0058,"string",lExpResult) //"Filial"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"BC_MOTIVO",STR0159,"string",IIF(lExpResult .Or. cSerie == "",.T.,.F.)) //"Motivo"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"CYO_DSRF", STR0160,"string",IIF(lExpResult .Or. cSerie == "",.T.,.F.)) //"Desc. Motivo"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"BC_OP",STR0076,"string",.T.) //"OP"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"BC_OPERAC",STR0077,"string",.T.) //"Operação"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"G2_DESCRI" ,STR0078,"string",lExpResult) //"Desc. Oper"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"BC_PRODUTO",STR0074,"string",.T.) //"Produto"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"B1_DESC",STR0075,"string",lExpResult) //"Desc. Produto"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"BC_LOCORIG",STR0277,"string",.T.) //"Armazém Origem"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"BC_DATA",STR0278,"string",.T.) //"Data Perda"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"BC_QUANT",STR0091,"string",.T.) //"Quantidade"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"B1_UM",STR0180,"string",.T.) //"Un. Medida"
    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabels,@nIndLabels,"R",COR_VERMELHO,STR0282,COR_BRANCO) //"Refugo"
    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabels,@nIndLabels,"S",COR_AMARELO,STR0283,COR_PRETO) //"Scrap"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"BC_TIPO",STR0146,"cellTemplate",.T.,.T.,aLabels) //"Tipo"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"BC_OPERADO",STR0141,"string",.T.) //"Operador"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"BC_RECURSO",STR0059,"string",.T.) //"Recurso"    
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H1_DESCRI" ,STR0073,"string",lExpResult) //"Desc. Recurso"
Return aColunas

/*/{Protheus.doc} ValidaPropriedades
Valida os dados informados nas propriedades do Monitor
@type Method
@author renan.roeder
@since 10/03/2023
@version P12.1.2410
@param  oFiltros, objeto json, Objeto json com os filtros para a consulta dos dados
@return aRetorno, array      , [1] logico - indica se os dados são válidos [2] caracter - mensagem de erro
/*/
Method ValidaPropriedades(oFiltros) Class StatusPerdasProdutoMotivo
    Local aRetorno := {.T.,""}

    PCPMonitorUtils():ValidaPropriedadeFilial(oFiltros["01_BC_FILIAL"],aRetorno)
   
    If aRetorno[1] .And. Empty(oFiltros["02_BC_PRODUTO"])
        aRetorno[1] := .F.
        aRetorno[2] := STR0165 //"O filtro de Produto deve ser preenchido."
    Else
        If aRetorno[1]
            SB1->(dbSetOrder(1))
			If !SB1->(dbSeek(xFilial("SB1",PadR(oFiltros["01_BC_FILIAL"], FWSizeFilial())) + PadR(oFiltros["02_BC_PRODUTO"],GetSx3Cache("BC_PRODUTO","X3_TAMANHO")), .F.))
                aRetorno[1] := .F.
                aRetorno[2] := STR0164 //"O Produto não existe na Filial informada."
            EndIf
        EndIf
    EndIf

    If aRetorno[1] .And. Empty(oFiltros["06_PERIODO"])
        aRetorno[1] := .F.
        aRetorno[2] := STR0194 //"Deve ser informada a quantidade de períodos que será visualizada."
    EndIf
Return aRetorno

/*/{Protheus.doc} montaQuery
Realiza a criação de objeto Json que define as colunas utilizadas na grid de detalhamento do monitor
@type Static Function
@author parffit.silva
@since 18/12/2024
@version P12.1.2410
@param	oFiltros, objeto Json, Contém as propriedades do monitor usadas para filtrar a query de busca
@param	dDataIni, data       , Data inicial do filtro
@param	dDataFin, data       , Data final do filtro
@param	nTipo   , numerico   , Data final do filtro
		1 - BuscaDados (dados agrupados)
		2 - BuscaDetalhes (colunas para consulta)
@return cQuery  , caracter   , Query utilizada para busca no banco de dados
/*/
Static Function montaQuery(oFiltros, dDataIni, dDataFin, nTipo)
    Local cMotivos  := ""
    Local cQuery    := ""
    Local cRecursos := ""
    Local nIndice   := 0

    cQuery := " SELECT "
    If nTipo == 1
        cQuery +=    " SBC.BC_FILIAL, SBC.BC_PRODUTO, SBC.BC_DATA, SBC.BC_MOTIVO, COUNT(SBC.BC_FILIAL) NR_APONT, SUM(SBC.BC_QUANT) QT_PERDA"
    ElseIf nTipo == 2
        cQuery +=    " SBC.BC_FILIAL, SBC.BC_TIPO, SBC.BC_MOTIVO, SBC.BC_OP, SBC.BC_OPERAC, SBC.BC_PRODUTO, SB1.B1_DESC, SB1.B1_UM,"
        cQuery +=    " SBC.BC_LOCORIG, SBC.BC_QUANT, SBC.BC_OPERADO, SBC.BC_DATA, SBC.BC_RECURSO, SB1.B1_OPERPAD, SC2.C2_ROTEIRO"
    EndIf
    cQuery += " FROM " +RetSqlName("SBC")+ " SBC "

    If nTipo == 2
        cQuery += " LEFT JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1",oFiltros["01_BC_FILIAL"])+"' AND SB1.B1_COD = SBC.BC_PRODUTO AND SB1.D_E_L_E_T_ = ' ' " 
        cQuery += " LEFT JOIN "+RetSqlName("SC2")+" SC2 ON SC2.C2_FILIAL = '"+xFilial("SC2",oFiltros["01_BC_FILIAL"])+"' AND SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN||SC2.C2_ITEMGRD = SBC.BC_OP AND SC2.D_E_L_E_T_ = ' ' "
    EndIf

    cQuery += " WHERE SBC.BC_FILIAL = '"+ xFilial("SBC", oFiltros["01_BC_FILIAL"])+"' "
    cQuery +=   " AND SBC.BC_PRODUTO = '"+oFiltros["02_BC_PRODUTO"]+"' "

    If oFiltros:HasProperty("03_BC_RECURSO") .And. ValType(oFiltros["03_BC_RECURSO"]) == "A"
        For nIndice := 1 To Len(oFiltros["03_BC_RECURSO"])
            If Empty(cRecursos)
                cRecursos := "'" + oFiltros["03_BC_RECURSO"][nIndice] + "'"
            Else
                cRecursos +=  ",'" + oFiltros["03_BC_RECURSO"][nIndice] + "'"
            EndIf
        Next nIndice
    EndIf
    If !Empty(cRecursos)
        cQuery += " AND SBC.BC_RECURSO IN ("+cRecursos+") "
    EndIf

    If !Empty(oFiltros["SERIE"])
        cMotivos := "'" + IIF(Left(oFiltros["SERIE"],RAt("(",oFiltros["SERIE"])-2) <> "-",Left(oFiltros["SERIE"],RAt("(",oFiltros["SERIE"])-2),"") + "'"
    Else
        If oFiltros:HasProperty("04_BC_MOTIVO") .And. ValType(oFiltros["04_BC_MOTIVO"]) == "A"
            For nIndice := 1 To Len(oFiltros["04_BC_MOTIVO"])
                If Empty(cMotivos)
                    cMotivos := "'" + oFiltros["04_BC_MOTIVO"][nIndice] + "'"
                Else
                    cMotivos +=  ",'" + oFiltros["04_BC_MOTIVO"][nIndice] + "'"
                EndIf
            Next nIndice
        EndIf
    EndIf
    If !Empty(cMotivos)
        cQuery += " AND SBC.BC_MOTIVO IN ("+cMotivos+") "
    EndIf

    cQuery += " AND SBC.BC_DATA BETWEEN '"+dToS(dDataIni)+"' AND '"+dToS(dDataFin)+"' "
    cQuery += " AND SBC.D_E_L_E_T_ = ' ' "

    If nTipo == 1
        cQuery += " GROUP BY SBC.BC_FILIAL, SBC.BC_PRODUTO, SBC.BC_DATA, SBC.BC_MOTIVO"
    EndIf

    cQuery += " ORDER BY SBC.BC_FILIAL, SBC.BC_PRODUTO, SBC.BC_DATA, SBC.BC_MOTIVO"

    cQuery := ChangeQuery(cQuery)
Return cQuery
