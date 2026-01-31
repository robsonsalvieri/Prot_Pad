#INCLUDE "TOTVS.CH"
#INCLUDE "PCPMONITOR.CH"
#INCLUDE "PCPMONITORDEF.CH"

/*/{Protheus.doc} StatusPlayStopPCP
Classe para prover os dados do Monitor de Apontamentos Cronômetro PCP
@type Class
@author renan.roeder
@since 09/02/2023
@version P12.1.2310
@return Nil
/*/
Class StatusPlayStopPCP FROM LongNameClass
	Static Method BuscaDados(oFiltros, cTipo, cSubTipo)
	Static Method BuscaDetalhes(oFiltros, nPagina)
	Static Method CargaMonitor()
    Static Method ValidaPropriedades(oFiltros)
EndClass

/*/{Protheus.doc} CargaMonitor
Realiza a carga do monitor no banco de dados, 
permitindo a exibição de um exemplo desse monitor para uso na aplicação.
@type Method
@author douglas.heydt
@since 13/03/2023
@version P12.1.2310
@return lRet, logico, Indica se a carga do Monitor foi realizada com sucesso.
/*/
Method CargaMonitor() Class StatusPlayStopPCP
    Local aDetalhes := {}
    Local aTags     := {}
    Local lRet      := .T.
    Local nPosTag   := 0
    Local oCarga    := PCPMonitorCarga():New()
    Local oPrmAdc   := JsonObject():New()
    Local oSeries   := JsonObject():New()    
        
    If !PCPMonitorCarga():monitorAtualizado("StatusPlayStopPCP")
        oSeries["Produção"] := {{4,10}, COR_VERDE }
        oSeries["Pausa"]    := {{2,3}, COR_VERMELHO }

        PCPMonitorUtils():AdicionaTagMonitor(aTags,@nPosTag,"po-icon-calendar","01/02/2023 - 28/02/2023")
        PCPMonitorUtils():AdicionaTagMonitor(aTags,@nPosTag,"po-icon-parameters",STR0196) //"Concluído"
        PCPMonitorUtils():AdicionaTagMonitor(aTags,@nPosTag,"po-icon-parameters",STR0197) //"Apontamentos"
        
        oCarga:setaTitulo(STR0139) //"Acompanhamento Play/Stop PCP"
        oCarga:setaObjetivo(STR0140) //"Acompanhar os números de apontamentos de produção e horas improdutivas que estão em andamento e que foram finalizados utilizando o Play/Stop do PCP, além de visualizar seus detalhes."
        oCarga:setaAgrupador("PCP")
        oCarga:setaFuncaoNegocio("StatusPlayStopPCP")
        oCarga:setaTiposPermitidos("chart")
        oCarga:setaTiposGraficoPermitidos("column;bar")
        oCarga:setaTipoPadrao("chart")
        oCarga:setaTipoGraficoPadrao("column")
        oCarga:setaTipoDetalhe("detalhe")
        oCarga:setaExemploJsonGrafico(oSeries, aTags, aDetalhes, {"João","Maria"},"column")
        
        oCarga:setaPropriedadeFilial("01_HZA_FILIAL")
        oCarga:setaPropriedadeProduto("02_C2_PRODUTO",.T.)
        oCarga:setaPropriedadeUsuario("03_HZA_OPERAD",.T.)
        
        oPrmAdc["04_HZA_STATUS"]                                  := JsonObject():New()
        oPrmAdc["04_HZA_STATUS"]["opcoes"]                        := "Em Andamento:A;Concluído:C"
        oCarga:setaPropriedade("04_HZA_STATUS","A",STR0198,4,,,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,oPrmAdc["04_HZA_STATUS"]) //"Tipo Apontamento"
        
        oPrmAdc["05_APONTAMENTOHORA"]                             := JsonObject():New()
        oPrmAdc["05_APONTAMENTOHORA"]["opcoes"]                   := STR0197+":A;"+STR0171+":H" //"Apontamentos:A;Horas:H"
        oCarga:setaPropriedade("05_APONTAMENTOHORA","A",STR0199,4,,,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,oPrmAdc["05_APONTAMENTOHORA"]) //"Apontamentos/Horas"
        
        oCarga:setaPropriedadePeriodoAtual("06_TIPOPERIODO","D","07_PERIODO")
        
        If !oCarga:gravaMonitorPropriedades()
            lRet := .F.
        EndIf
        oCarga:Destroy()
    EndIf
    FwFreeArray(aTags)
    FreeObj(oPrmAdc)
    FreeObj(oSeries)
Return lRet

/*/{Protheus.doc} BuscaDados
Responsável por realizar a busca dos dados que serão exibidos no monitor (gráfico ou texto)
@type Method
@author douglas.heydt
@since 09/02/2023
@version P12.1.2310
@param	oFiltros  , objeto Json, Contém as propriedades do monitor usadas para filtrar a query de busca
@param	cTipo     , caracter, Tipo chart/info
@param	cSubTipo  , caracter, Tipo de grafico pie/bar/column
@return cJsonDados, caracter, Retorna um novo Json em formato texto, pronto para conversão e exibição no front
/*/
Method BuscaDados(oFiltros, cTipo, cSubTipo) Class StatusPlayStopPCP
    Local aPausa     := {}
    Local aProd      := {}
    Local aUsuarios  := {}
    Local cAlias     := GetNextAlias()
    Local cJsonDados := ""
    Local cProdutos  := ""
    Local cUsuarios  := ""
    Local cUsrAtual  := ""
    Local cQuery     := ""
    Local dDataIni   := dDatabase
    Local dDataFin   := dDatabase
    Local lFilUsuar  := .F.
    Local nIndice    := 0
    Local nIndSerie  := 0
    Local nPosTag    := 0
    Local oDados     := JsonObject():New()
    Local oJsonRet   := JsonObject():New()

    oJsonRet["alturaMinimaWidget"] := "350px"
    oJsonRet["alturaMaximaWidget"] := "500px"
    oJsonRet["categorias"] := {}
    oJsonRet["series"]     := {}
    oJsonRet["tags"]       := {}

    oFiltros["01_HZA_FILIAL"] := PadR(oFiltros["01_HZA_FILIAL"], FWSizeFilial())
    dDataIni := PCPMonitorUtils():RetornaPeriodoInicial(oFiltros["06_TIPOPERIODO"],dDataFin,cValtoChar(oFiltros["07_PERIODO"]))
    cQuery +="  SELECT "
    cQuery += "     HZA.HZA_FILIAL,
    cQuery += "     HZA.HZA_OP,
    cQuery += "     HZA.HZA_OPERAD,
    cQuery += "     HZA.HZA_DTINI,
    cQuery += "     HZA.HZA_HRINI,
    cQuery += "     HZA.HZA_DTFIM,
    cQuery += "     HZA.HZA_HRFIM,
    cQuery += "     HZA.HZA_TPTRNS
    cQuery += " FROM "+RetSqlName("HZA")+" HZA "
    cQuery += " LEFT JOIN "+RetSqlName("SC2")+" SC2 ON SC2.C2_FILIAL = '"+xFilial("SC2",oFiltros["01_HZA_FILIAL"])+"' AND SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN||SC2.C2_ITEMGRD = HZA.HZA_OP AND SC2.D_E_L_E_T_ = ' ' "
    cQuery += " WHERE HZA.HZA_FILIAL = '" + xFilial("HZA",oFiltros["01_HZA_FILIAL"]) + "' "
    cQuery += "   AND HZA.HZA_DTINI BETWEEN '" + dToS(dDataIni) + "' AND '" + dToS(dDataFin) + "' "
    cQuery += "   AND HZA.HZA_STATUS = '"+IIF(oFiltros["04_HZA_STATUS"] == "A","1","2")+"' "
    If oFiltros:HasProperty("02_C2_PRODUTO") .And. ValType(oFiltros["02_C2_PRODUTO"]) == "A"
        For nIndice := 1 To Len(oFiltros["02_C2_PRODUTO"])
            If Empty(cProdutos)
                cProdutos := "'" + oFiltros["02_C2_PRODUTO"][nIndice] + "'"
            Else
                cProdutos +=  ",'" + oFiltros["02_C2_PRODUTO"][nIndice] + "'"
            EndIf
        Next nIndice
    EndIf
    If !Empty(cProdutos)
        cQuery += " AND SC2.C2_PRODUTO IN ("+cProdutos+") "
    EndIf
    If oFiltros:HasProperty("03_HZA_OPERAD") .And. ValType(oFiltros["03_HZA_OPERAD"]) == "A"
        For nIndice := 1 To Len(oFiltros["03_HZA_OPERAD"])
            If Empty(cUsuarios)
                cUsuarios := "'" + oFiltros["03_HZA_OPERAD"][nIndice] + "'"
            Else
                cUsuarios +=  ",'" + oFiltros["03_HZA_OPERAD"][nIndice] + "'"
            EndIf
        Next nIndice
    EndIf
    If !Empty(cUsuarios)
        lFilUsuar := .T.
        cQuery += " AND HZA.HZA_OPERAD IN ("+cUsuarios+") "
    EndIf
    cQuery += " AND HZA.D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY HZA.HZA_FILIAL, HZA.HZA_OPERAD "
    cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)
	While (cAlias)->(!Eof())
        cUsrAtual := IIF(lFilUsuar,(cAlias)->HZA_OPERAD,STR0200) //"Todos"
        If !oDados:HasProperty(cUsrAtual)
            oDados[cUsrAtual] := JsonObject():New()
            oDados[cUsrAtual]["1"] := 0
            oDados[cUsrAtual]["2"] := 0
        EndIf
        If oFiltros["05_APONTAMENTOHORA"] == "H"
            If oFiltros["04_HZA_STATUS"] == "A"
                If (cAlias)->HZA_DTINI != dToS(dDatabase)
                    nDifDias := DateDiffDay(sToD((cAlias)->HZA_DTINI),dDatabase) - 1
                    nMinutos := nDifDias * 24 * 60
                    nMinutos += Hrs2Min(ElapTime(SubStr((cAlias)->HZA_HRINI,1,5)+":00","24:00:00"))
                    nMinutos += Hrs2Min(ElapTime("00:00:00",SubStr(Time(),1,5)+":00"))
                Else
                    nMinutos := Hrs2Min(ElapTime(SubStr((cAlias)->HZA_HRINI,1,5)+":00",SubStr(Time(),1,5)+":00"))
                EndIf                
            Else
                If (cAlias)->HZA_DTINI != (cAlias)->HZA_DTFIM
                    nDifDias := DateDiffDay(sToD((cAlias)->HZA_DTINI),sToD((cAlias)->HZA_DTFIM)) - 1
                    nMinutos := nDifDias * 24 * 60
                    nMinutos += Hrs2Min(ElapTime(SubStr((cAlias)->HZA_HRINI,1,5)+":00","24:00:00"))
                    nMinutos += Hrs2Min(ElapTime("00:00:00",SubStr((cAlias)->HZA_HRFIM,1,5)+":00"))
                Else
                    nMinutos := Hrs2Min(ElapTime(SubStr((cAlias)->HZA_HRINI,1,5)+":00",SubStr((cAlias)->HZA_HRFIM,1,5)+":00"))            
                EndIf
            EndIf
            oDados[cUsrAtual][(cAlias)->HZA_TPTRNS] += nMinutos
        Else
            oDados[cUsrAtual][(cAlias)->HZA_TPTRNS]++
        EndIf
		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())

    aUsuarios :=  oDados:GetNames()
    For nIndice := 1 To Len(aUsuarios)
        aAdd(aProd,IIF(oFiltros["05_APONTAMENTOHORA"] == "H",NOROUND(((oDados[aUsuarios[nIndice]]["1"] / 0.6) / 100),2),oDados[aUsuarios[nIndice]]["1"]))
        aAdd(aPausa,IIF(oFiltros["05_APONTAMENTOHORA"] == "H",NOROUND(((oDados[aUsuarios[nIndice]]["2"] / 0.6) / 100),2),oDados[aUsuarios[nIndice]]["2"]))
        aUsuarios[nIndice] := IIF(lFilUsuar,UsrRetName(aUsuarios[nIndice]),aUsuarios[nIndice])
    Next nIndice

    PCPMonitorUtils():AdicionaSerieGraficoMonitor(oJsonRet["series"],@nIndSerie,COR_VERDE,aProd,STR0144) //"Produção"
    PCPMonitorUtils():AdicionaSerieGraficoMonitor(oJsonRet["series"],@nIndSerie,COR_VERMELHO,aPausa,STR0145) //"Pausa"
    PCPMonitorUtils():AdicionaCategoriasGraficoMonitor(oJsonRet["categorias"], aUsuarios)
    
    PCPMonitorUtils():AdicionaTagMonitor(oJsonRet["tags"],@nPosTag,"po-icon-calendar",dToC(dDataIni) + " - " + dToC(dDataFin))
    PCPMonitorUtils():AdicionaTagMonitor(oJsonRet["tags"],@nPosTag,"po-icon-parameters",IIF(oFiltros["04_HZA_STATUS"] == "A",STR0142,STR0196)) //"Em Andamento" //"Concluído"
    PCPMonitorUtils():AdicionaTagMonitor(oJsonRet["tags"],@nPosTag,"po-icon-parameters",IIF(oFiltros["05_APONTAMENTOHORA"] == "H",STR0171,STR0197)) //"Horas" //"Apontamentos"

    If oFiltros:HasProperty("02_C2_PRODUTO") .And. ValType(oFiltros["02_C2_PRODUTO"]) == "A"
        For nIndice := 1 To Len(oFiltros["02_C2_PRODUTO"])
            PCPMonitorUtils():AdicionaTagMonitor(oJsonRet["tags"],@nPosTag,"po-icon-bar-code",oFiltros["02_C2_PRODUTO"][nIndice])
        Next nIndice
    EndIf
    cJsonDados := oJsonRet:ToJson()

    FreeObj(oDados)
    FreeObj(oJsonRet)
    FwFreeArray(aPausa)
    FwFreeArray(aProd)
    FwFreeArray(aUsuarios)
Return cJsonDados

/*/{Protheus.doc} BuscaDetalhes
Responsável por realizar a busca dos dados que serão exibidos no detalhamento do monitor
@type Method
@author douglas.heydt
@since 13/03/2023
@version P12.1.2310
@param	oFiltros  , objeto   , Contém as propriedades do monitor usadas para filtrar a query de busca
@param	nPagina   , numerico , Número da página desejada para busca
@return cJsonDados, caracter , Retorna um novo Json em formato texto, pronto para conversão e exibição no front
/*/
Method BuscaDetalhes(oFiltros, nPagina) Class StatusPlayStopPCP
    Local aFiltros   := {}
    Local cAlias     := GetNextAlias()
    Local cProdutos  := ""
    Local cUsuarios  := ""
    Local cSerie     := ""
    Local cCateg     := ""
    Local cJsonDados := ""
	Local cQuery     := ""
    Local dDataIni   := dDatabase
    Local dDataFin   := dDatabase
    Local lExpResult := .F.
	Local nIndice    := 0
    Local nPos       := 0
    Local nPosTag    := 0
    Local nStart     := 0
	Local oDados     := JsonObject():New()

    Default nPagina := 1
    Default nPageSize := 20

    If nPagina == 0
        lExpResult := .T.
    EndIf

    cSerie := IIF(oFiltros:HasProperty("SERIE"),oFiltros["SERIE"],"")
    cCateg := IIF(oFiltros:HasProperty("CATEGORIA"),oFiltros["CATEGORIA"],"")
    oFiltros["01_HZA_FILIAL"] := PadR(oFiltros["01_HZA_FILIAL"], FWSizeFilial())
    dDataIni := PCPMonitorUtils():RetornaPeriodoInicial(oFiltros["06_TIPOPERIODO"],dDataFin,cValtoChar(oFiltros["07_PERIODO"]))
    cQuery += " SELECT HZA.HZA_FILIAL,HZA.HZA_OP,HZA.HZA_OPERAC,HZA.HZA_OPERAD,HZA.HZA_FORM, "
    cQuery += "        HZA.HZA_DTINI,HZA.HZA_HRINI,HZA.HZA_DTFIM,HZA.HZA_HRFIM, "
    cQuery += "        HZA.HZA_TPTRNS,HZA.HZA_STATUS,HZA.HZA_IDAPON,HZA.HZA_RECUR, "
    cQuery += "        SC2.C2_PRODUTO,SB1.B1_DESC,SB1.B1_OPERPAD,SC2.C2_NUM,SC2.C2_ITEM,SC2.C2_SEQUEN,SC2.C2_ROTEIRO,"
    cQuery += "        SH6.H6_PRODUTO,SH6.H6_LOCAL,SH6.H6_IDENT,SH6.H6_QTDPERD,SH6.H6_TEMPO,SH6.H6_MOTIVO,SH6.H6_QTDPROD,SH6.H6_RECURSO,SH6.H6_OPERAC "
    cQuery += " FROM "+RetSqlName("HZA")+" HZA "
    cQuery += " LEFT JOIN "+RetSqlName("SC2")+" SC2 ON SC2.C2_FILIAL = '"+xFilial("SC2",oFiltros["01_HZA_FILIAL"])+"' AND SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN||SC2.C2_ITEMGRD = HZA.HZA_OP AND SC2.D_E_L_E_T_ = ' ' "
    cQuery += " LEFT JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1",oFiltros["01_HZA_FILIAL"])+"' AND SB1.B1_COD = SC2.C2_PRODUTO  AND SB1.D_E_L_E_T_ = ' ' "
    cQuery += " LEFT JOIN "+RetSqlName("SH6")+" SH6 ON SH6.H6_FILIAL = '"+xFilial("SH6",oFiltros["01_HZA_FILIAL"])+"' AND SH6.H6_FILIAL||SH6.H6_PRODUTO||SH6.H6_LOCAL||SH6.H6_IDENT = HZA.HZA_IDAPON AND SH6.D_E_L_E_T_ = ' ' "
    cQuery += " WHERE HZA.HZA_FILIAL = '" + xFilial("HZA",oFiltros["01_HZA_FILIAL"]) + "' "
    cQuery += "   AND HZA.HZA_DTINI BETWEEN '" + dToS(dDataIni) + "' AND '" + dToS(dDataFin) + "' "
    cQuery += "   AND HZA.HZA_STATUS = '"+IIF(oFiltros["04_HZA_STATUS"] == "A","1","2")+"' "
    If oFiltros:HasProperty("02_C2_PRODUTO") .And. ValType(oFiltros["02_C2_PRODUTO"]) == "A"
        For nIndice := 1 To Len(oFiltros["02_C2_PRODUTO"])
            If Empty(cProdutos)
                cProdutos := "'" + oFiltros["02_C2_PRODUTO"][nIndice] + "'"
            Else
                cProdutos +=  ",'" + oFiltros["02_C2_PRODUTO"][nIndice] + "'"
            EndIf
        Next nIndice
    EndIf
    If !Empty(cProdutos)
        cQuery += " AND SC2.C2_PRODUTO IN ("+cProdutos+") "
    EndIf
    If !Empty(cSerie)
        cQuery += " AND HZA.HZA_TPTRNS = '"+IIF(cSerie == "Pausa","2","1")+"' "
    EndIf
    If !Empty(cCateg)
        If cCateg != "Todos" 
            cQuery += " AND HZA.HZA_OPERAD = '"+cCateg+"' "
        EndIf
    Else
        If oFiltros:HasProperty("03_HZA_OPERAD") .And. ValType(oFiltros["03_HZA_OPERAD"]) == "A"
            For nIndice := 1 To Len(oFiltros["03_HZA_OPERAD"])
                If Empty(cUsuarios)
                    cUsuarios := "'" + oFiltros["03_HZA_OPERAD"][nIndice] + "'"
                Else
                    cUsuarios +=  ",'" + oFiltros["03_HZA_OPERAD"][nIndice] + "'"
                EndIf
            Next nIndice
        EndIf
        If !Empty(cUsuarios)
            cQuery += " AND HZA.HZA_OPERAD IN ("+cUsuarios+") "
        EndIf
    EndIf
    cQuery += " AND HZA.D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY HZA.HZA_FILIAL, HZA.HZA_OPERAD, HZA.HZA_DTINI, HZA.HZA_HRINI "
    cQuery := ChangeQuery(cQuery)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)

    oDados["items"]        := {}
    oDados["columns"]      := montaColun(lExpResult)
    oDados["headers"]      := {}
    oDados["canExportCSV"] := .T.
    oDados["tags"]         := {}

    PCPMonitorUtils():AdicionaTagMonitor(oDados["tags"],@nPosTag,"po-icon-calendar",dToC(dDataIni) + " - " + dToC(dDataFin))
    PCPMonitorUtils():AdicionaTagMonitor(oDados["tags"],@nPosTag,"po-icon-parameters",IIF(oFiltros["04_HZA_STATUS"] == "A",STR0142,STR0196)) //"Em Andamento" //"Concluído"
    PCPMonitorUtils():AdicionaTagMonitor(oDados["tags"],@nPosTag,"po-icon-parameters",IIF(oFiltros["05_APONTAMENTOHORA"] == "H",STR0171,STR0197)) //"Horas" //"Apontamentos"

    If !Empty(cSerie)
        PCPMonitorUtils():AdicionaTagMonitor(oDados["tags"],@nPosTag,"po-icon-filter",cSerie)
    EndIf

    If !Empty(cCateg)
        PCPMonitorUtils():AdicionaTagMonitor(oDados["tags"],@nPosTag,"po-icon-filter",IIF(cCateg != "Todos",UsrRetName(cCateg),cCateg))
    EndIf

    If oFiltros:HasProperty("02_C2_PRODUTO") .And. ValType(oFiltros["02_C2_PRODUTO"]) == "A"
        For nIndice := 1 To Len(oFiltros["02_C2_PRODUTO"])
            PCPMonitorUtils():AdicionaTagMonitor(oDados["tags"],@nPosTag,"po-icon-bar-code",oFiltros["02_C2_PRODUTO"][nIndice])
        Next nIndice
    EndIf

    If nPagina > 1
        nStart := ( (nPagina-1) * nPageSize )
        If nStart > 0
            (cAlias)->(DbSkip(nStart))
        EndIf
	EndIf
	nPos := 0
    While (cAlias)->(!Eof())
        aAdd(oDados["items"], JsonObject():New())
        nPos++
        cRoteiro := IIF(!Empty((cAlias)->C2_ROTEIRO),(cAlias)->C2_ROTEIRO,IIF(!Empty((cAlias)->B1_OPERPAD),(cAlias)->B1_OPERPAD,"01"))
        oDados["items"][nPos]["HZA_FILIAL"] := (cAlias)->HZA_FILIAL
        oDados["items"][nPos]["HZA_OP"]     := (cAlias)->HZA_OP
        oDados["items"][nPos]["HZA_OPERAC"] := (cAlias)->HZA_OPERAC
        oDados["items"][nPos]["G2_DESCRI"]  := AllTrim(Posicione("SG2",1,xFilial("SG2",PadR(oFiltros["01_HZA_FILIAL"], FWSizeFilial()))+(cAlias)->C2_PRODUTO+cRoteiro+(cAlias)->HZA_OPERAC,"G2_DESCRI"))
        oDados["items"][nPos]["C2_PRODUTO"] := (cAlias)->C2_PRODUTO
        oDados["items"][nPos]["B1_DESC"]    := (cAlias)->B1_DESC
        oDados["items"][nPos]["HZA_OPERAD"] := UsrRetName((cAlias)->HZA_OPERAD)
        oDados["items"][nPos]["HZA_DTINI"]  := PCPMonitorUtils():FormataData((cAlias)->HZA_DTINI, 5)
        oDados["items"][nPos]["HZA_HRINI"]  := (cAlias)->HZA_HRINI 
        oDados["items"][nPos]["HZA_DTFIM"]  := PCPMonitorUtils():FormataData((cAlias)->HZA_DTFIM, 5)
        oDados["items"][nPos]["HZA_HRFIM"]  := (cAlias)->HZA_HRFIM
        oDados["items"][nPos]["RECURSO"]    := Iif(Empty((cAlias)->H6_RECURSO), (cAlias)->HZA_RECUR, (cAlias)->H6_RECURSO )  
        oDados["items"][nPos]["H1_DESCRI"]  := AllTrim(Posicione("SH1",1,xFilial("SH1",PadR(oFiltros["01_HZA_FILIAL"], FWSizeFilial()))+oDados["items"][nPos]["RECURSO"],"H1_DESCRI"))
        oDados["items"][nPos]["HZA_FORM"]   := (cAlias)->HZA_FORM
        oDados["items"][nPos]["H6_QTDPROD"] := (cAlias)->H6_QTDPROD
        oDados["items"][nPos]["H6_QTDPERD"] := (cAlias)->H6_QTDPERD
        oDados["items"][nPos]["H6_TEMPO"]   := (cAlias)->H6_TEMPO
        oDados["items"][nPos]["H6_MOTIVO"]  := (cAlias)->H6_MOTIVO
        oDados["items"][nPos]["CYN_DSSP"]   := AllTrim(Posicione("CYN",1,xFilial("CYN",PadR(oFiltros["01_HZA_FILIAL"], FWSizeFilial()))+(cAlias)->H6_MOTIVO, "CYN_DSSP"))
        oDados["items"][nPos]["HZA_TPTRNS"] := Alltrim((cAlias)->HZA_TPTRNS)
		(cAlias)->(dbSkip())
        //Verifica tamanho da página
		If !lExpResult .And. nPos >= nPageSize
			Exit
		EndIf
	End
    oDados["hasNext"] := (cAlias)->(!Eof())
    (cAlias)->(dbCloseArea())
	cJsonDados :=  oDados:toJson()
    FwFreeArray(aFiltros)
    FreeObj(oDados)
Return cJsonDados

/*/{Protheus.doc} montaColun
Realiza a criação de objeto Json que define as colunas utilizadas na grid de detalhamento do monitor

@type Static Function
@author douglas.heydt
@since 09/02/2023
@version P12.1.2310
@param  lExpResult, logico, Indica se trata todas as colunas como visible
@return oColumns, objeto Json, Contém as definições das colunas da grid do monitor
/*/
Static Function montaColun(lExpResult) 
    Local aColunas   := {}
    Local aLabels    := {}
    Local nIndice    := 0
    Local nIndLabels := 0

    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabels,@nIndLabels,"1",COR_VERDE,STR0144,COR_BRANCO) //"Produção"
    PCPMonitorUtils():AdicionaLabelsColunaTabela(aLabels,@nIndLabels,"2",COR_VERMELHO,STR0145,COR_BRANCO) //"Pausa"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"HZA_TPTRNS",STR0146,"cellTemplate",.T.,.T.,aLabels) //"Tipo"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"HZA_FILIAL",STR0058,"string",lExpResult) //"Filial"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"HZA_OP",STR0076,"string",.T.) //"OP"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"HZA_OPERAC",STR0077,"string",.T.) //"Operação"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"G2_DESCRI",STR0151,"string",lExpResult) //"Desc. Operação"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"C2_PRODUTO",STR0074,"string",.T.) //"Produto"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"B1_DESC",STR0075,"string",lExpResult) //"Desc. Produto"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"HZA_OPERAD",STR0141,"string",.T.) //"Operador"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"HZA_DTINI",STR0152,"string",.T.) //"Data Inicial"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"HZA_HRINI",STR0153,"string",.T.) //"Hora Inicial"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"HZA_DTFIM",STR0154,"string",.T.) //"Data Final"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"HZA_HRFIM",STR0155,"string",.T.) //"Hora Final"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H6_QTDPROD",STR0144,"string",.T.) //"Produção"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H6_QTDPERD",STR0156,"string",lExpResult) //"Perda"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H6_TEMPO",STR0157,"string",lExpResult) //"Tempo real"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"HZA_FORM",STR0158,"string",lExpResult) //"Formulário"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"RECURSO",STR0059,"string",.T.) //"Recurso"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H1_DESCRI",STR0073,"string",lExpResult) //"Desc. Recurso"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"H6_MOTIVO",STR0159,"string",.T.) //"Motivo"
    PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndice,"CYN_DSSP",STR0160,"string",lExpResult) //"Desc. motivo"
Return aColunas

/*/{Protheus.doc} ValidaPropriedades
Valida os dados informados nas propriedades do Monitor
@type Method
@author renan.roeder
@since 10/03/2023
@version P12.1.2310
@param  oFiltros, objeto json, Objeto json com os filtros para a consulta dos dados
@return aRetorno, array      , [1] logico - indica se os dados são válidos [2] caracter - mensagem de erro
/*/
Method ValidaPropriedades(oFiltros) Class StatusPlayStopPCP
    Local aRetorno := {.T.,""}

    PCPMonitorUtils():ValidaPropriedadeFilial(oFiltros["01_HZA_FILIAL"],aRetorno)

    If aRetorno[1] .And. oFiltros["06_TIPOPERIODO"] == "X"
        If !oFiltros:HasProperty("07_PERIODO") .Or. oFiltros["07_PERIODO"] == Nil .Or. Empty(oFiltros["07_PERIODO"])
            aRetorno[1] := .F.
            aRetorno[2] := STR0069 //"Deve ser informada a quantidade de dias para o período personalizado."
        EndIf
    EndIf
Return aRetorno
