#INCLUDE "TOTVS.CH"
#INCLUDE "PCPMONITOR.CH"
#INCLUDE "PCPMONITORDEF.CH"

/*/{Protheus.doc} StatusRecurso
Classe para prover os dados do Monitor de Status do Recurso
@type Class
@author renan.roeder
@since 10/03/2023
@version P12.1.2310
@return Nil
/*/
Class StatusRecurso FROM LongNameClass
    Static Method BuscaDados(oFiltros)
    Static Method BuscaDetalhes(oFiltro,nPagina)
    Static Method CargaMonitor()
    Static Method ValidaPropriedades(oFiltros)
EndClass

/*/{Protheus.doc} BuscaDados
Realiza a busca dos dados para o Monitor
@type Method
@author renan.roeder
@since 10/03/2023
@version P12.1.2310
@param  oFiltros, objeto json, Objeto json com os filtros para a consulta dos dados
@return cJson   , caracter   , string json com os dados para retorno
/*/
Method BuscaDados(oFiltros) Class StatusRecurso
    Local cHrDispRec := ""
    Local cCodRecur  := ""
    Local cWhere     := ""
    Local dDataFin   := dDatabase
    Local dDataIni   := dDatabase
    Local oJsRet     := Nil
    Local oJsTmpApt  := Nil
    Local oJsUltApt  := Nil

    oFiltros["01_H6_FILIAL"] := PadR(oFiltros["01_H6_FILIAL"], FWSizeFilial())
    dDataFin              := dDatabase
    dDataIni              := PCPMonitorUtils():RetornaPeriodoInicial(AllTrim(oFiltros["04_TIPOPERIODO"]),dDataFin,cValToChar(oFiltros["05_PERIODO"]))
    cCodRecur             := AllTrim(oFiltros["02_H6_RECURSO"])
    cWhere                := filtroQuery(oFiltros,dToS(dDataIni),dToS(dDataFin))
    cHrDispRec            := PCPA152Disponibilidade():buscaHorasRecurso(cCodRecur,dDataIni,dDataFin)["totalHoras"]
    oJsTmpApt             := calcTmpApt(oFiltros,dDataIni,dDataFin)
    oJsUltApt             := ultApontam(cWhere,oFiltros["01_H6_FILIAL"])
    oJsRet                := fmtRetorno(cHrDispRec,oJsTmpApt,oJsUltApt,cCodRecur,dDataIni,dDataFin)
Return oJsRet:ToJson()

/*/{Protheus.doc} fmtRetorno
Monta objeto json para retornar os dados do Monitor
@type Static Function
@author renan.roeder
@since 10/03/2023
@version P12.1.2310
@param	cHrDispRec, caracter   , Horas disponiveis no recurso
@param	oJsTmpApt , objeto json, Objeto json com os tempos de apontamento no período
@param	oJsUltApt , objeto json, Objeto json com o ultimo apontamento
@param	cCodRecur , caracter   , Codigo do recurso
@param	dDataIni  , data       , Data Inicial
@param	dDataFin  , data       , Data Final
@return oJson     , objeto json, Objeto json com os dados para retorno
/*/
Static Function fmtRetorno(cHrDispRec,oJsTmpApt,oJsUltApt,cCodRecur,dDataIni,dDataFin)
    Local nIndLinha  := 0
    Local nIndTag    := 0
    Local oJson      := JsonObject():New()
    Local oJsCxVerde := JsonObject():New()
    Local oJsCxVmlha := JsonObject():New()

    oJsCxVerde["background-color"] := COR_VERDE
    oJsCxVerde["border-radius"]    := "3px"
    oJsCxVerde["border-color"]     := COR_VERDE
    oJsCxVerde["border"]           := "5px"
    oJsCxVerde["cursor"]           := "pointer"
    oJsCxVmlha["background-color"] := COR_VERMELHO
    oJsCxVmlha["border-radius"]    := "3px"
    oJsCxVmlha["border-color"]     := COR_VERMELHO
    oJsCxVmlha["border"]           := "5px"
    oJsCxVmlha["cursor"]           := "pointer"

    oJson["alturaMinimaWidget"] := "350px"
    oJson["alturaMaximaWidget"] := "500px"
    oJson["corFundo"]  := "white"
    oJson["corTitulo"] := ""
    oJson["tags"]   := {}
    PCPMonitorUtils():AdicionaTagMonitor(oJson["tags"],@nIndTag,"po-icon-calendar",dToC(dDataIni) + " - " + dToC(dDataFin))
    PCPMonitorUtils():AdicionaTagMonitor(oJson["tags"],@nIndTag,"po-icon-manufacture",cCodRecur)
    oJson["linhas"] := {}
    PCPMonitorUtils():AdicionaLinhaInformacao(oJson["linhas"],@nIndLinha,STR0105,"po-font-text-large po-text-center po-sm-6 po-pt-2") //"Horas Produtivas"
    PCPMonitorUtils():AdicionaLinhaInformacao(oJson["linhas"],@nIndLinha,STR0106,"po-font-text-large po-text-center po-sm-6 po-pt-2") //"Horas Improdutivas"
    PCPMonitorUtils():AdicionaLinhaInformacao(oJson["linhas"],@nIndLinha,oJsTmpApt["P"],"po-font-title po-text-center bold-text po-sm-6 po-pt-2 po-pb-2",oJsCxVerde:ToJson(),.T.,"SH6.H6_TIPO = 'P'")
    PCPMonitorUtils():AdicionaLinhaInformacao(oJson["linhas"],@nIndLinha,oJsTmpApt["I"],"po-font-title po-text-center bold-text po-sm-6 po-pt-2 po-pb-2",oJsCxVmlha:ToJson(),.T.,"SH6.H6_TIPO = 'I'")
    PCPMonitorUtils():AdicionaLinhaInformacao(oJson["linhas"],@nIndLinha,STR0169 +" <b>"+ cHrDispRec +" "+ STR0054+"</b>.","po-font-text-large po-text-left po-sm-12 po-pt-1 po-pl-0") //"Calendário do recurso possui"  //"horas"
    If oJsUltApt:HasProperty("ORDEM_PRODUCAO")
        PCPMonitorUtils():AdicionaLinhaInformacao(oJson["linhas"],@nIndLinha,STR0170,"po-font-text-large-bold po-text-left po-sm-12 po-pt-1 po-pl-0") //"Última Produção"
        PCPMonitorUtils():AdicionaLinhaInformacao(oJson["linhas"],@nIndLinha,STR0189+oJsUltApt["ORDEM_PRODUCAO"]+"</br>"+STR0074+" "+oJsUltApt["CODIGO_PRODUTO"]+" - "+oJsUltApt["DESCRICAO_PRODUTO"]+"</br>"+STR0077+" "+oJsUltApt["CODIGO_OPERACAO"]+" - "+oJsUltApt["DESCRICAO_OPERACAO"]+"","po-font-text-small po-text-left po-sm-12 po-pl-0") //"Ordem " //"Produto" //Operação
    EndIf
    FreeObj(oJsCxVerde)
    FreeObj(oJsCxVmlha)
Return oJson

/*/{Protheus.doc} ultApontam
Busca o ultimo apontamento de produção pro recurso
@type Static Function
@author renan.roeder
@since 10/03/2023
@version P12.1.2310
@param	cWhere    , caracter   , Condição para a consulta sql
@param	cFilialFlt, caracter   , Filial informada no filtro
@return oJsUltApon, objeto json, Objeto json com os dados do último apontamento de produção do recurso
/*/
Static Function ultApontam(cWhere,cFilialFlt)
    Local cAlias     := GetNextAlias()
    Local cQuery     := ""
    Local cRoteiro   := ""
    Local oJsUltApon := JsonObject():New()

    cQuery := "SELECT "
    cQuery += " SH6.H6_OP ORDEM_PRODUCAO,SH6.H6_PRODUTO CODIGO_PRODUTO,SB1.B1_DESC DESCRICAO_PRODUTO,"
    cQuery += " SH6.H6_OPERAC CODIGO_OPERACAO,SH6.H6_TIPO TIPO_APONTAMENTO, "
    cQuery += " SB1.B1_OPERPAD ROTEIRO_PADRAO, SC2.C2_ROTEIRO ROTEIRO_ORDEM "
    cQuery += " FROM "+RetSqlName("SH6")+" SH6 "
    cQuery += " LEFT JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1",cFilialFlt)+"' AND SB1.B1_COD = SH6.H6_PRODUTO AND SB1.D_E_L_E_T_ = ' ' "
    cQuery += " LEFT JOIN "+RetSqlName("SC2")+" SC2 ON SC2.C2_FILIAL = '"+xFilial("SC2",cFilialFlt)+"' AND SC2.C2_NUM||C2_ITEM||C2_SEQUEN||C2_ITEMGRD = SH6.H6_OP AND SC2.D_E_L_E_T_ = ' ' "
    cQuery += cWhere
    cQuery += " AND SH6.H6_TIPO = 'P' "
    cQuery += " ORDER BY SH6.H6_IDENT DESC"
    cQuery := ChangeQuery(cQuery)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)
    If (cAlias)->(!Eof())
        cRoteiro := IIF(!Empty((cAlias)->ROTEIRO_ORDEM),(cAlias)->ROTEIRO_ORDEM,IIF(!Empty((cAlias)->ROTEIRO_PADRAO),(cAlias)->ROTEIRO_PADRAO,"01"))
        oJsUltApon["ORDEM_PRODUCAO"]     := AllTrim((cAlias)->ORDEM_PRODUCAO)
        oJsUltApon["CODIGO_PRODUTO"]     := AllTrim((cAlias)->CODIGO_PRODUTO)
        oJsUltApon["DESCRICAO_PRODUTO"]  := AllTrim((cAlias)->DESCRICAO_PRODUTO)
        oJsUltApon["CODIGO_OPERACAO"]    := AllTrim((cAlias)->CODIGO_OPERACAO)
        oJsUltApon["DESCRICAO_OPERACAO"] := AllTrim(Posicione("SG2",1,xFilial("SG2",cFilialFlt)+(cAlias)->CODIGO_PRODUTO+cRoteiro+(cAlias)->CODIGO_OPERACAO,"G2_DESCRI"))
        oJsUltApon["TIPO_APONTAMENTO"]   := AllTrim((cAlias)->TIPO_APONTAMENTO)
        (cAlias)->(dbSkip())
    EndIf
    (cAlias)->(dbCloseArea())    

Return oJsUltApon

/*/{Protheus.doc} calcTmpApt
Calcula a quantidade de horas de apontamento produtivo e improdutivo no período
@type Static Function
@author renan.roeder
@since 10/03/2023
@version P12.1.2310
@param  cWhere    , caracter   , Condição sql com base nos filtros do Monitor
@return oJsonTempo, objeto json, Objeto json com a quantidade de horas produtivas e improdutivas
/*/
Static Function calcTmpApt(oFiltros,dDataIni,dDataFin)
    Local oJsonCalc  := Nil
    Local oJsonTempo := JsonObject():New()

    oJsonCalc := PCPMonitorUtils():CalculaTempoApontamentoOperacao(oFiltros["01_H6_FILIAL"],"'"+oFiltros["02_H6_RECURSO"]+"'",{dDataIni,dDataFin},.F.,,oFiltros["03_FILTRODATA"])
    oJsonTempo["P"] := PCPMonitorUtils():TransformaMinutosCentesimaisParaTempo(oJsonCalc[dToC(dDatabase)]["P"],1)
    oJsonTempo["I"] := PCPMonitorUtils():TransformaMinutosCentesimaisParaTempo(oJsonCalc[dToC(dDatabase)]["I"],1)
    FreeObj(oJsonCalc)
Return oJsonTempo

/*/{Protheus.doc} filtroQuery
Atribui o filtro padrão para ser usado nos métodos da busca de dados e detalhes
@type Static Function
@author renan.roeder
@since 10/03/2023
@version P12.1.2310
@param	oFiltro , objeto json, Objeto json com as propriedades que devem ser consideradas no filtro
@param	cDataIni, caracter   , Data inicial calculada para o filtro
@param	cDataFin, caracter   , Data final com base na database do sistema
@return cWhere  , caracter   , Condição sql para a query
/*/
Static Function filtroQuery(oFiltro,cDataIni,cDataFin)
    Local cWhere   := "WHERE SH6.D_E_L_E_T_ = ' ' "

    cWhere += " AND SH6.H6_FILIAL = '" + xFilial("SH6",oFiltro["01_H6_FILIAL"]) + "' "
    cWhere += " AND SH6.H6_RECURSO = '" + AllTrim(oFiltro["02_H6_RECURSO"]) + "' "
    cWhere += " AND (SH6."+AllTrim(oFiltro["03_FILTRODATA"])+" >= '"+cDataIni+"' AND SH6."+AllTrim(oFiltro["03_FILTRODATA"])+" <= '"+cDataFin+"') "
Return cWhere

/*/{Protheus.doc} BuscaDetalhes
Realiza a busca dos dados para montar os detalhes do Monitor
@type Method
@author renan.roeder
@since 10/03/2023
@version P12.1.2310
@return Nil
/*/
Method BuscaDetalhes(oFiltro,nPagina) Class StatusRecurso
    Local cAlias     := GetNextAlias()
    Local cFilialFlt := ""
    Local cParamDet  := ""
    Local cRecurFlt  := ""
    Local cQuery     := ""
    Local cRoteiro   := ""
    Local dDataFin   := dDatabase
    Local dDataIni   := dDatabase
    Local lExpResult := .F.
    Local nIndTag    := 0
    Local nPos       := 0
    Local nStart     := 1
    Local nTamPagina := 20
    Local oDados     := JsonObject():New()

    Default nPagina := 1

    oFiltro["01_H6_FILIAL"] := PadR(oFiltro["01_H6_FILIAL"], FWSizeFilial())
    cFilialFlt           := oFiltro["01_H6_FILIAL"]
    cParamDet            := IIF(oFiltro:HasProperty("PARAMETROSDETALHE"),oFiltro["PARAMETROSDETALHE"],"")
    cRecurFlt            := oFiltro["02_H6_RECURSO"]
    dDataFin             := dDatabase
    dDataIni             := PCPMonitorUtils():RetornaPeriodoInicial(AllTrim(oFiltro["04_TIPOPERIODO"]),dDataFin,cValToChar(oFiltro["05_PERIODO"]))

    If nPagina == 0
        lExpResult := .T.
    EndIf
    cQuery := "SELECT "
    cQuery += "  SH6.H6_FILIAL,SH6.H6_OP,SH6.H6_PRODUTO,SH6.H6_OPERAC,SH6.H6_RECURSO,SH6.H6_DTAPONT, "
    cQuery += "  SH6.H6_DATAINI,SH6.H6_HORAINI,SH6.H6_DATAFIN,SH6.H6_HORAFIN,SH6.H6_TEMPO,SH6.H6_QTDPROD, "
    cQuery += "  SH6.H6_QTDPERD,SH6.H6_TIPO,SH6.H6_TIPOTEM, SH6.H6_MOTIVO, "
    cQuery += "  SB1.B1_DESC, SB1.B1_OPERPAD, SC2.C2_ROTEIRO "
    cQuery += " FROM "+RetSqlName("SH6")+" SH6 "
    cQuery += " LEFT JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1",cFilialFlt)+"' AND SB1.B1_COD = SH6.H6_PRODUTO AND SB1.D_E_L_E_T_ = ' ' "
    cQuery += " LEFT JOIN "+RetSqlName("SC2")+" SC2 ON SC2.C2_FILIAL = '"+xFilial("SC2",cFilialFlt)+"' AND SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN||SC2.C2_ITEMGRD = SH6.H6_OP AND SC2.D_E_L_E_T_ = ' ' "
    cQuery += filtroQuery(oFiltro,dToS(dDataIni),dToS(dDataFin))
    If !Empty(cParamDet)
        cQuery += " AND " + cParamDet
    EndIf
    cQuery += " ORDER BY SH6."+AllTrim(oFiltro["03_FILTRODATA"])+",SH6.H6_TIPO DESC"
    cQuery := ChangeQuery(cQuery)
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
    PCPMonitorUtils():AdicionaTagMonitor(oDados["tags"],@nIndTag,"po-icon-calendar",dToC(dDataIni) + " - " + dToC(dDataFin))
    PCPMonitorUtils():AdicionaTagMonitor(oDados["tags"],@nIndTag,"po-icon-manufacture",cRecurFlt)
    If !Empty(cParamDet)
        PCPMonitorUtils():AdicionaTagMonitor(oDados["tags"],@nIndTag,"po-icon-filter",STR0171 +" "+ IIF("'P'" $ cParamDet,STR0190,STR0191)) //"Horas" //"Produtivas" //"Improdutivas"
    EndIf

    While (cAlias)->(!Eof())
        aAdd(oDados["items"], JsonObject():New())
        nPos++
        cRoteiro := IIF(!Empty((cAlias)->C2_ROTEIRO),(cAlias)->C2_ROTEIRO,IIF(!Empty((cAlias)->B1_OPERPAD),(cAlias)->B1_OPERPAD,"01"))
        oDados["items"][nPos]["H6_FILIAL"]  := (cAlias)->H6_FILIAL
        oDados["items"][nPos]["H6_OP"]      := (cAlias)->H6_OP
        oDados["items"][nPos]["H6_PRODUTO"] := (cAlias)->H6_PRODUTO
        oDados["items"][nPos]["B1_DESC"]    := (cAlias)->B1_DESC
        oDados["items"][nPos]["H6_OPERAC"]  := (cAlias)->H6_OPERAC
        oDados["items"][nPos]["G2_DESCRI"]  := AllTrim(Posicione("SG2",1,xFilial("SG2",cFilialFlt)+(cAlias)->H6_PRODUTO+cRoteiro+(cAlias)->H6_OPERAC,"G2_DESCRI"))
        oDados["items"][nPos]["H6_RECURSO"] := (cAlias)->H6_RECURSO
        oDados["items"][nPos]["H6_DTAPONT"] := PCPMonitorUtils():FormataData((cAlias)->H6_DTAPONT,4)
        oDados["items"][nPos]["H6_DATAINI"] := PCPMonitorUtils():FormataData((cAlias)->H6_DATAINI,4)
        oDados["items"][nPos]["H6_HORAINI"] := (cAlias)->H6_HORAINI
        oDados["items"][nPos]["H6_DATAFIN"] := PCPMonitorUtils():FormataData((cAlias)->H6_DATAFIN,4)
        oDados["items"][nPos]["H6_HORAFIN"] := (cAlias)->H6_HORAFIN
        oDados["items"][nPos]["H6_TEMPO"]   := IIF((cAlias)->H6_TIPOTEM == 2,A680ConvHora((cAlias)->H6_TEMPO,"C","N"),(cAlias)->H6_TEMPO)
        oDados["items"][nPos]["H6_QTDPROD"] := (cAlias)->H6_QTDPROD
        oDados["items"][nPos]["H6_QTDPERD"] := (cAlias)->H6_QTDPERD
        oDados["items"][nPos]["H6_TIPO"]    := (cAlias)->H6_TIPO
        oDados["items"][nPos]["H6_MOTIVO"]  := (cAlias)->H6_MOTIVO
        oDados["items"][nPos]["CYN_DSSP"]   := AllTrim(Posicione("CYN",1,xFilial("CYN",oFiltro["01_H6_FILIAL"])+(cAlias)->H6_MOTIVO, "CYN_DSSP"))
      
        (cAlias)->(dbSkip())
        If !lExpResult .And. nPos >= nTamPagina
            Exit
        EndIf
    End
    oDados["hasNext"] := (cAlias)->(!Eof())
    (cAlias)->(dbCloseArea())    
Return oDados:ToJson()

/*/{Protheus.doc} bscColunas
Cria array de objetos no formato poTableColumn com as colunas da table de detalhamento
@type Static Function
@author renan.roeder
@since 10/03/2023
@version P12.1.2310
@param  lExpResult, logico, Indica se trata todas as colunas como visible
@return aColunas  , array   , Array de objetos com as colunas da table po-ui
/*/
Static Function bscColunas(lExpResult)
    Local aColunas   := {}
    Local aLabels    := {}
    Local nIndice    := 0
    Local nIndLabels := 0

    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H6_FILIAL",STR0058,"string",lExpResult) //"Filial"
    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabels,@nIndLabels,"I",COR_VERMELHO,STR0071,COR_BRANCO) //"Improdutivo"
    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabels,@nIndLabels,"P",COR_VERDE,STR0072,COR_BRANCO) //"Produtivo"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H6_TIPO",STR0070,"cellTemplate",.T.,.T.,aLabels) //"Tp Apon"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H6_RECURSO",STR0059,"string",lExpResult) //"Recurso"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H6_OP",STR0076,"string",.T.) //"OP"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H6_PRODUTO",STR0074,"string",.T.) //"Produto"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"B1_DESC",STR0075,"string",lExpResult) //"Desc. Produto"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H6_OPERAC",STR0077,"string",.T.) //"Operação"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"G2_DESCRI",STR0078,"string",lExpResult) //"Desc. Operação"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H6_DTAPONT",STR0080,"date",.T.) //"Dt Apont"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H6_DATAINI",STR0081,"date",lExpResult) //"Dt Ini"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H6_HORAINI",STR0082,"string",lExpResult) //"Hora Ini"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H6_DATAFIN",STR0083,"date",lExpResult) //"Dt Fin"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H6_HORAFIN",STR0084,"string",lExpResult) //"Hora Fin"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H6_TEMPO",STR0079,"string",.T.) //"Tempo"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H6_QTDPROD",STR0085,"number",lExpResult) //"Qtd. Prod"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H6_QTDPERD",STR0086,"number",lExpResult) //"Qtd. Perda"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H6_MOTIVO",STR0159,"string",.T.) //"Motivo"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"CYN_DSSP",STR0160,"string",lExpResult) //"Desc. Motivo"
Return aColunas

/*/{Protheus.doc} CargaMonitor
Realiza a carga do Monitor padrão na base de dados
@type Method
@author renan.roeder
@since 10/03/2023
@version P12.1.2310
@return lRet, logico, Indica se conseguiu realizar a carga
/*/
Method CargaMonitor() Class StatusRecurso
    Local lRet       := .T.
    Local nIndLinha  := 0
    Local nIndTag    := 0
    Local oCarga     := PCPMonitorCarga():New()
    Local oExemplo   := JsonObject():New()
    Local oJsCxVerde := JsonObject():New()
    Local oJsCxVmlha := JsonObject():New()
    Local oPrmAdc    := JsonObject():New()
 
    If !PCPMonitorCarga():monitorAtualizado("StatusRecurso")
        oJsCxVerde["background-color"] := COR_VERDE
        oJsCxVerde["border-radius"]    := "3px"
        oJsCxVerde["border-color"]     := COR_VERDE
        oJsCxVerde["border"]           := "5px"
        oJsCxVerde["cursor"]           := "pointer"
        oJsCxVmlha["background-color"] := COR_VERMELHO
        oJsCxVmlha["border-radius"]    := "3px"
        oJsCxVmlha["border-color"]     := COR_VERMELHO
        oJsCxVmlha["border"]           := "5px"
        oJsCxVmlha["cursor"]           := "pointer"
        oExemplo["corFundo"]  := "white"
        oExemplo["corTitulo"] := ""
        oExemplo["tags"]   := {}
        PCPMonitorUtils():AdicionaTagMonitor(oExemplo["tags"],@nIndTag,"po-icon-calendar","01/01/23 - 15/01/23")
        PCPMonitorUtils():AdicionaTagMonitor(oExemplo["tags"],@nIndTag,"po-icon-manufacture","GUIL01")
        oExemplo["linhas"] := {}
        PCPMonitorUtils():AdicionaLinhaInformacao(oExemplo["linhas"],@nIndLinha,STR0105,"po-font-text-large po-text-center po-sm-6 po-pt-2") //"Horas Produtivas"
        PCPMonitorUtils():AdicionaLinhaInformacao(oExemplo["linhas"],@nIndLinha,STR0106,"po-font-text-large po-text-center po-sm-6 po-pt-2") //"Horas Improdutivas"
        PCPMonitorUtils():AdicionaLinhaInformacao(oExemplo["linhas"],@nIndLinha,"5:30","po-font-title po-text-center bold-text po-sm-6 po-pt-2 po-pb-2",oJsCxVerde:ToJson())
        PCPMonitorUtils():AdicionaLinhaInformacao(oExemplo["linhas"],@nIndLinha,"3:15","po-font-title po-text-center bold-text po-sm-6 po-pt-2 po-pb-2",oJsCxVmlha:ToJson())
        PCPMonitorUtils():AdicionaLinhaInformacao(oExemplo["linhas"],@nIndLinha,STR0169 +" <b>10:00 "+STR0054+"</b>.","po-font-text-large po-text-left po-sm-12 po-pt-1 po-pl-0") //"Calendário do recurso possui"  //"horas"
        PCPMonitorUtils():AdicionaLinhaInformacao(oExemplo["linhas"],@nIndLinha,STR0170,"po-font-text-large-bold po-text-left po-sm-12 po-pt-1 po-pl-0") //"Última Produção"
        PCPMonitorUtils():AdicionaLinhaInformacao(oExemplo["linhas"],@nIndLinha,STR0189+" 10000101001</br>"+STR0074+" CHAPAALUMINIO23 - Chapa de Alumínio 2x3</br>"+STR0077+" 20 - Corte","po-font-text-small po-text-left po-sm-12 po-pl-0") //"Ordem " //"Produto" //Operação

        oPrmAdc["03_FILTRODATA"]                                := JsonObject():New()
        oPrmAdc["03_FILTRODATA"]["opcoes"]                      := STR0192+":H6_DATAINI;"+STR0154+":H6_DATAFIN;"+STR0193+":H6_DTAPONT" //"Data Início:H6_DATAINI;Data Final:H6_DATAFIN;Data Apontamento:H6_DTAPONT"
        oPrmAdc["04_TIPOPERIODO"]                               := JsonObject():New()
        oPrmAdc["04_TIPOPERIODO"]["opcoes"]                     := STR0184+":D;"+STR0185+":S;"+STR0186+":Q;"+STR0187+":M;"+STR0188+":X"  //"Dia Atual:D;Semana Atual:S;Quinzena Atual:Q;Mês Atual:M;Personalizado:X"

        oCarga:setaTitulo(STR0172) //"Situação do Recurso"
        oCarga:setaObjetivo(STR0173) //"Monitorar o uso do recurso na fábrica, mostrando sua capacidade produtiva no período, detalhes do último apontamento, total de apontamentos de produção e horas improdutivas, além da possibilidade de visualizar em detalhes os apontamentos."
        oCarga:setaAgrupador("PCP")
        oCarga:setaFuncaoNegocio("StatusRecurso")
        oCarga:setaTiposPermitidos("info")
        oCarga:setaTiposGraficoPermitidos("")
        oCarga:setaTipoPadrao("info")
        oCarga:setaTipoGraficoPadrao("")
        oCarga:setaTipoDetalhe("detalhe")
        oCarga:setaExemploJsonTexto(.F.,oExemplo)
        oCarga:setaPropriedadeFilial("01_H6_FILIAL")
        oCarga:setaPropriedadeRecurso("02_H6_RECURSO")
        oCarga:setaPropriedade("03_FILTRODATA","H6_DATAINI",STR0061,4,,,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,oPrmAdc["03_FILTRODATA"]) //"Data de referência"
        oCarga:setaPropriedadePeriodoAtual("04_TIPOPERIODO","D","05_PERIODO")
        If !oCarga:gravaMonitorPropriedades()
            lRet := .F.
        EndIf
        oCarga:Destroy()
    EndIf
    FreeObj(oJsCxVerde)
    FreeObj(oJsCxVmlha)
    FreeObj(oExemplo)
    FreeObj(oPrmAdc)
Return lRet

/*/{Protheus.doc} ValidaPropriedades
Valida os dados informados nas propriedades do Monitor
@type Method
@author renan.roeder
@since 10/03/2023
@version P12.1.2310
@param  oFiltros, objeto json, Objeto json com os filtros para a consulta dos dados
@return aRetorno, array      , [1] logico - indica se os dados são válidos [2] caracter - mensagem de erro
/*/
Method ValidaPropriedades(oFiltros) Class StatusRecurso
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
    If aRetorno[1] .And. oFiltros["04_TIPOPERIODO"] == "X"
        If !oFiltros:HasProperty("05_PERIODO") .Or. oFiltros["05_PERIODO"] == Nil
            aRetorno[1] := .F.
            aRetorno[2] := STR0069 //"Deve ser informada a quantidade de dias para o período personalizado."
        EndIf
    EndIf
Return aRetorno

