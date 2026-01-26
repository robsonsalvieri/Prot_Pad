#INCLUDE "TOTVS.CH"
#INCLUDE "GFEMONITOR.CH"
#INCLUDE "GFEMONITORDEF.CH"

/*/{Protheus.doc} MonitorEntrega
Classe para prover os dados do Monitor de Entregas
@type Class
@author Jefferson Hita
@since 28/08/2023
@version P12.1.2410
@return Nil
/*/
Class MonitorEntrega FROM LongNameClass
	Static Method BuscaDados(oFiltros, cTipo, cSubTipo)
	Static Method BuscaDetalhes(oFiltro,nPagina)
	Static Method CargaMonitor()
	Static Method ValidaPropriedades(oFiltros)
EndClass


/*/{Protheus.doc} CargaMonitor
Realiza a carga do Monitor padrão na base de dados
@type Method
@author Jefferson Hita
@since 28/08/2023
@version P12.1.2410
@return lRet, logico, Indica se conseguiu realizar a carga
/*/
Method CargaMonitor() Class MonitorEntrega
	Local aTags     := {}
	Local aDetalhes := {}
	Local lRet      := .T.
	Local oCarga    := PCPMonitorCarga():New()
	Local oExemplo  := JsonObject():New()
	Local oPrmAdc   := JsonObject():New()
	Local oStyle    := JsonObject():New()
	Local oStyleQtd := JsonObject():New()
	Local oSeries   := JsonObject():New()

	If !PCPMonitorCarga():monitorAtualizado("MonitorEntrega")
		// Exemplo Barras verticais
		oSeries["Sem previsão"]  := {{3,5}, COR_CINZA }
		oSeries["Em andamento atrasado"] := {{2,3}, COR_AMARELO }
		oSeries["Concluído atrasado"] := {{5,8}, COR_VERMELHO }
		oSeries["Em andamento no prazo"] := {{2,6}, COR_AZUL }
		oSeries["Concluído no prazo"] := {{4,10}, COR_VERDE }

		aAdd(aTags, JsonObject():New())
		aTags[1]["texto"]      := "D MG 01 - D MG 02"
		aTags[1]["colorTexto"] := ""
		aTags[1]["icone"]      := "po-icon-company"
		aAdd(aTags, JsonObject():New())
		aTags[2]["texto"]      := "01/01/2023 - 28/02/2023"
		aTags[2]["colorTexto"] := ""
		aTags[2]["icone"]      := "po-icon-calendar"
		aAdd(aTags, JsonObject():New())
		aTags[3]["texto"]      := "Todos"
		aTags[3]["colorTexto"] := ""
		aTags[3]["icone"]      := "po-icon-parameters"

		oCarga:setaTitulo("Monitor de Entregas")
		oCarga:setaObjetivo("Apresentar informações dos documentos relacionados referente as entregas conforme filtros configurados.")
		oCarga:setaAgrupador("GFE")
		oCarga:setaFuncaoNegocio("MonitorEntrega")
		oCarga:setaTiposPermitidos("chart;info")
		oCarga:setaTiposGraficoPermitidos("column;bar;info;gauge")
		oCarga:setaTipoPadrao("info")
		oCarga:setaTipoGraficoPadrao("column")
		oCarga:setaTipoDetalhe("detalhe")
		oCarga:setaExemploJsonGrafico(oSeries, aTags, aDetalhes, {"Janeiro","Fevereiro"},"column")

		oPrmAdc["01_GFE_FILIAL"]                                 := JsonObject():New()
		oPrmAdc["01_GFE_FILIAL"]["filtroServico"]                := "/api/pcp/v1/pcpmonitorapi/consulta"
		oPrmAdc["01_GFE_FILIAL"]["parametrosServico"]            := JsonObject():New()
		oPrmAdc["01_GFE_FILIAL"]["parametrosServico"]["metodo"]  := "PCPMonitorConsultas():BuscaFiliais"
		oPrmAdc["01_GFE_FILIAL"]["labelSelect"]                  := "Description"
		oPrmAdc["01_GFE_FILIAL"]["valorSelect"]                  := "Code"

		oPrmAdc["02_GFE_FILIAL"]                                 := JsonObject():New()
		oPrmAdc["02_GFE_FILIAL"]["filtroServico"]                := "/api/pcp/v1/pcpmonitorapi/consulta"
		oPrmAdc["02_GFE_FILIAL"]["parametrosServico"]            := JsonObject():New()
		oPrmAdc["02_GFE_FILIAL"]["parametrosServico"]["metodo"]  := "PCPMonitorConsultas():BuscaFiliais"
		oPrmAdc["02_GFE_FILIAL"]["labelSelect"]                  := "Description"
		oPrmAdc["02_GFE_FILIAL"]["valorSelect"]                  := "Code"

		oPrmAdc["03_GFE_SITUACAO"]           := JsonObject():New()
		oPrmAdc["03_GFE_SITUACAO"]["opcoes"] := "Todos" + ":T;" + "Sem previsão" + ":S; " + " Em andamento atrasado" + ":EA;" + " Concluído atrasado" + ":CA;" + " Em andamento no prazo" + ":AP;" + " Concluído no prazo" + ":CP"

		oPrmAdc["04_GFE_TIPOPERIODO"]           := JsonObject():New()
		oPrmAdc["04_GFE_TIPOPERIODO"]["opcoes"] := "Dia Atual" + ":D;" + " Semana Atual" + ":S; " + " Quinzena Atual" + ":Q; " + " Mês Atual" + ":M; " + " Personalizado" + ":X"

		oPrmAdc["06_GFE_TIPOSEMAFORO"]           := JsonObject():New()
		oPrmAdc["06_GFE_TIPOSEMAFORO"]["opcoes"] := "Quantidade"+":Q"

		oCarga:setaPropriedade("01_GFE_FILIAL","", "Filial De:",7,GetSx3Cache("GWN_FILIAL","X3_TAMANHO"),0,"po-lg-6 po-xl-6 po-md-6 po-sm-12 po-pr-6",,,oPrmAdc["01_GFE_FILIAL"])
		oCarga:setaPropriedade("02_GFE_FILIAL","", "Filial Até:",7,GetSx3Cache("GWN_FILIAL","X3_TAMANHO"),0,"po-lg-6 po-xl-6 po-md-6 po-sm-12 po-pr-6",,,oPrmAdc["02_GFE_FILIAL"])
		oCarga:setaPropriedade("03_GFE_SITUACAO","T", "Situação",4,,,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,oPrmAdc["03_GFE_SITUACAO"])
		oCarga:setaPropriedade("04_GFE_TIPOPERIODO","X", "Período",4,,,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,oPrmAdc["04_GFE_TIPOPERIODO"])
		oCarga:setaPropriedade("05_GFE_PERIODO","99", "Período personalizado (dias)",2,4,0,"po-lg-6 po-xl-6 po-md-6 po-sm-12")
		oCarga:setaPropriedade("07_GFE_SEMAFORO", "Atenção;Urgente", "Semáforo (Quantidade)",1,30,0,"po-lg-8 po-xl-8 po-md-8 po-sm-12",,,)

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
@author Jefferson Hita
@since 28/08/2023
@version P12.1.2410
@param	oFiltros  , objeto Json, Contém as propriedades do monitor usadas para filtrar a query de busca
@param	cTipo     , caracter   , Tipo chart/info
@param	cSubTipo  , caracter   , Tipo de grafico pie/bar/column
@return cJsonDados, caracter   , Retorna um novo Json em formato texto, pronto para conversão e exibição no front
/*/
Method BuscaDados(oFiltros, cTipo, cSubTipo) Class MonitorEntrega
	Local cAliasQry  := GetNextAlias()
	Local cJsonDados := ""
	Local nQtdDoc    := 0
	Local nPos       := 0
	Local oJsonRet   := JsonObject():New()
	Local aSemaforo  := StrTokArr(Replace(oFiltros["07_GFE_SEMAFORO"],",","."),";")
	Local dDataIni   := PCPMonitorUtils():RetornaPeriodoInicial(AllTrim(oFiltros["04_GFE_TIPOPERIODO"]),dDatabase,cValToChar(oFiltros["05_GFE_PERIODO"]))

	Private cFilDe    := ""
	Private cFilAte   := ""
	Private cInner    := " "
	Private cWhere    := "GW1.D_E_L_E_T_=' '"
	Private cSituacao := ""

	oFiltros["01_GFE_FILIAL"] := PadR(oFiltros["01_GFE_FILIAL"], FWSizeFilial())
	oFiltros["02_GFE_FILIAL"] := PadR(oFiltros["02_GFE_FILIAL"], FWSizeFilial())
	cFilDe  := xFilial("GWN", oFiltros["01_GFE_FILIAL"])
	cFilAte := xFilial("GWN", oFiltros["02_GFE_FILIAL"])

	If Alltrim(oFiltros["03_GFE_SITUACAO"]) $ "CA;AP;CP"
		cInner := "INNER JOIN " + RetSqlName("GWU") + " GWU"
		cInner += " ON GWU.GWU_FILIAL = GW1.GW1_FILIAL"
		cInner += " AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC"
		cInner += " AND GWU.GWU_EMISDC = GW1.GW1_EMISDC"
		cInner += " AND GWU.GWU_SERDC = GW1.GW1_SERDC"
		cInner += " AND GWU.GWU_NRDC = GW1.GW1_NRDC"
		cInner += " AND GWU.GWU_SEQ = '01'"
		cInner += " AND GWU.D_E_L_E_T_=' '"
	EndIf

	If Alltrim(oFiltros["03_GFE_SITUACAO"]) == "S"
		cSituacao := "Sem previsão"
		cWhere    += " AND GW1_DTPSAI = ' '"
	ElseIf Alltrim(oFiltros["03_GFE_SITUACAO"]) == "EA"
		cSituacao := "Em andamento atrasado"
		cWhere    += " AND GW1_DTPSAI != ' ' AND GW1_DTPSAI < '" + dtos(Date())+ "' AND (GW1_DTSAI != ' ' OR GW1_DTPSAI < GW1_DTSAI)" 
	ElseIf Alltrim(oFiltros["03_GFE_SITUACAO"]) == "CA"
		cSituacao := "Concluído atrasado"
		cWhere    += " AND GWU_DTPENT != ' ' AND GWU_DTENT != ' ' AND GWU_DTENT > GW1_DTPENT"
	ElseIf Alltrim(oFiltros["03_GFE_SITUACAO"]) == "AP"
		cSituacao := "Em andamento no prazo"
		cWhere    += "  AND GW1_DTPSAI > GW1_DTSAI  AND GWU_DTPENT != ' ' AND GWU_DTENT = ' ' AND GWU_DTPENT < '" + dtos(Date()) + "'"
	ElseIf Alltrim(oFiltros["03_GFE_SITUACAO"]) == "CP"
		cSituacao := "Concluído no prazo"
		cWhere    += " AND GWU_DTPENT != ' ' AND GW1_DTPENT >= GWU_DTENT"
	Else
		cSituacao := "Todos"
	EndIf
	cInner := "%"+cInner+"%"
	cWhere := "%"+cWhere+"%"

	BeginSql Alias cAliasQry
        SELECT COUNT(GW1.R_E_C_N_O_) QTDD
		FROM %Table:GW1% GW1
		%Exp:cInner%
        WHERE GW1.GW1_FILIAL BETWEEN %Exp:cFilDe% AND %Exp:cFilAte%
        AND GW1.GW1_DTEMIS BETWEEN %Exp:dDataIni% AND %Exp:dDatabase%
        AND %Exp:cWhere%
	EndSql
	If (cAliasQry)->(!Eof())
		nQtdDoc := (cAliasQry)->QTDD
	EndIf
	(cAliasQry)->(dbCloseArea())

	If cTipo == "info"
		montaInfo(oJsonRet, nQtdDoc, aSemaforo)
	Else
		montaGraf(oJsonRet, nQtdDoc, aSemaforo, oFiltros, oFiltros["06_GFE_TIPOSEMAFORO"], cSubTipo)
	EndIf

	oJsonRet["tags"]     := {}
	nPos++
	aAdd(oJsonRet["tags"], JsonObject():New())
	oJsonRet["tags"][nPos]["texto"]      := " " + oFiltros["01_GFE_FILIAL"] + " - " + oFiltros["02_GFE_FILIAL"]
	oJsonRet["tags"][nPos]["colorTexto"] := ""
	oJsonRet["tags"][nPos]["icone"]      := "po-icon-company"
	nPos++
	aAdd(oJsonRet["tags"], JsonObject():New())
	oJsonRet["tags"][nPos]["texto"]      := " " + cValToChar(dDataIni) + " - " + cValToChar(dDatabase) + " "
	oJsonRet["tags"][nPos]["colorTexto"] := ""
	oJsonRet["tags"][nPos]["icone"]      := "po-icon-calendar"
	nPos++
	aAdd(oJsonRet["tags"], JsonObject():New())
	oJsonRet["tags"][nPos]["colorTexto"] := ""
	oJsonRet["tags"][nPos]["icone"]      := "po-icon-parameters"
	oJsonRet["tags"][nPos]["texto"]      := cSituacao

	cJsonDados := oJsonRet:toJson()

	FreeObj(oJsonRet)
Return cJsonDados

/*/{Protheus.doc} ValidaPropriedades
Valida os dados informados nas propriedades do Monitor
@type Method
@author Jefferson Hita
@since 28/08/2023
@version P12.1.2410
@param  oFiltros, objeto json, Objeto json com os filtros para a consulta dos dados
@return aRetorno, array      , [1] logico - indica se os dados são válidos [2] caracter - mensagem de erro
/*/
Method ValidaPropriedades(oFiltros) Class MonitorEntrega
	Local aFiliais  := FWLoadSM0(.T.,.T.)
	Local aRetorno  := {.T.,""}

	If Empty(oFiltros["01_GFE_FILIAL"]) .Or. Empty(oFiltros["02_GFE_FILIAL"])
		aRetorno[1] := .F.
		aRetorno[2] := "O filtro de Filial deve ser preenchido."
	EndIf

	If aRetorno[1] .And. oFiltros["04_GFE_TIPOPERIODO"] == "X"
		If !oFiltros:HasProperty("05_GFE_PERIODO") .Or. oFiltros["05_GFE_PERIODO"] == Nil .Or. Empty(oFiltros["05_GFE_PERIODO"])
			aRetorno[1] := .F.
			aRetorno[2] := "Deve ser informada a quantidade de dias para o período personalizado."
		EndIf
	EndIf

	FwFreeArray(aFiliais)
Return aRetorno

/*/{Protheus.doc} BuscaDetalhes
Realiza a busca dos dados para montar os detalhes do Monitor
@type Method
@author Jefferson Hita
@since 28/08/2023
@version P12.1.2410
@return Nil
/*/
Method BuscaDetalhes(oFiltro,nPagina) Class MonitorEntrega
	Local cAlias     := GetNextAlias()
	Local nI         := 0
	Local nPos       := 0
	Local cSituacao  := ""
	Local cCpoQry    := ""
	Local cInnerGWN  := ""
	Local cWhere     := "GW1.D_E_L_E_T_=' '"
	Local dDataFim   := dDatabase
	Local dDataIni   := PCPMonitorUtils():RetornaPeriodoInicial(AllTrim(oFiltro["04_GFE_TIPOPERIODO"]),dDataFim,cValToChar(oFiltro["05_GFE_PERIODO"]))
	Local oDados     := JsonObject():New()
	Local cFilDe     := ""
	Local cFilAte    := ""

	Default nPagina := 1

	Private aFields  := {{" " 		        , "STATUS"    , "C", 1                      , 0},;
		{"Filial"		   	, "GW1_FILIAL", "C", TamSX3("GW1_FILIAL")[1], TamSX3("GW1_FILIAL")[2]},;
		{"Emissor"  		, "GW1_NMEMIS", "C", TamSX3("GW1_NMEMIS")[1], TamSX3("GW1_NMEMIS")[2]},;
		{"Tipo"  		    , "GW1_CDTPDC", "C", TamSX3("GW1_CDTPDC")[1], TamSX3("GW1_CDTPDC")[2]},;
		{"Série"  		    , "GW1_SERDC" , "C", TamSX3("GW1_SERDC")[1] , TamSX3("GW1_SERDC")[2]},;
		{"Nr Documento"     , "GW1_NRDC"  , "C", TamSX3("GW1_NRDC")[1]  , TamSX3("GW1_NRDC")[2]},;
		{"Dt Emissão" 		, "GW1_DTEMIS", "C", TamSX3("GW1_DTEMIS")[1], 0},;  //{" ", "SITPREVSAI", "C", 1, 0},;
		{"Prev Saída" 		, "GW1_DTPSAI", "D", TamSX3("GW1_DTPSAI")[1], 0},;
		{"Saída Real" 		, "GW1_DTSAI" , "D", TamSX3("GW1_DTSAI")[1] , 0},;  //{" ", "SITDTPENT" , "C", 1, 0},;
		{"Prev Entrega Emb" , "GW1_DTPENT", "D", TamSX3("GW1_DTPENT")[1], 0},;  //{" ", "SITTRPPENT", "C", 1, 0},;
		{"Prev Entrega Trp" , "GWU_DTPENT", "D", TamSX3("GWU_DTPENT")[1], 0},;
		{"Entrega Real"     , "GWU_DTENT" , "D", TamSX3("GWU_DTENT")[1] , 0},;
		{"Cidade Dest"      , "GU7_NMCID" , "C", TamSX3("GU7_NMCID")[1] , TamSX3("GU7_NMCID")[2]},;
		{"UF Dest"          , "GU7_CDUF"  , "C", TamSX3("GU7_CDUF")[1]  , TamSX3("GU7_CDUF")[2]},;
		{"Qtd Ocor"	 	    , "QTD_OCO"   , "N", 10                     , 0},;
		{"Transportador"    , "NMEMIT_1"  , "C", TamSX3("GU3_NMEMIT")[1]  , TamSX3("GU3_NMEMIT")[2]},;//{" ", "SITTRANSP" , "C", 1, 0},;
		{"Redespachante 1"  , "NMEMIT_2"  , "C", TamSX3("GU3_NMEMIT")[1]  , TamSX3("GU3_NMEMIT")[2]},;//{" ", "SITRED1"   , "C", 1, 0},;
		{"Redespachante 2"  , "NMEMIT_3"  , "C", TamSX3("GU3_NMEMIT")[1]  , TamSX3("GU3_NMEMIT")[2]},;//{" ", "SITRED2"   , "C", 1, 0},;
		{"Cod Rastreamento" , "GWN_RASTR" , "C", TamSX3("GWN_RASTR")[1] , TamSX3("GWN_RASTR")[2]}}

	If GFXCP1212210('GW1_FILROM')
		aadd(aFields, {"Fil Romaneio", "GW1_FILROM", "C", TamSX3("GW1_FILROM")[1], 0})
	EndIf
	aadd(aFields, {"Romaneio", "GW1_NRROM", "C", TamSX3("GW1_NRROM")[1], TamSX3("GW1_NRROM")[2]})

	oFiltro["01_GFE_FILIAL"] := PadR(oFiltro["01_GFE_FILIAL"], FWSizeFilial())
	oFiltro["02_GFE_FILIAL"] := PadR(oFiltro["02_GFE_FILIAL"], FWSizeFilial())
	cFilDe  := xFilial("GWN", oFiltro["01_GFE_FILIAL"])
	cFilAte := xFilial("GWN", oFiltro["02_GFE_FILIAL"])

	If GFXCP1212210('GW1_FILROM')
		cInnerGWN += "GWN.GWN_FILIAL = GW1.GW1_FILROM"
		cCpoQry += ", GW1.GW1_FILROM AS GW1_FILROM"
	Else
		cInnerGWN += "GWN.GWN_FILIAL = GW1.GW1_FILIAL"
	EndIf

	If Alltrim(oFiltro["03_GFE_SITUACAO"]) == "S"                      // "Sem previsão"
		cSituacao := "Sem previsão"
		cWhere    += " AND GW1_DTPSAI = ' '"
	ElseIf Alltrim(oFiltro["03_GFE_SITUACAO"]) == "EA"                 // "Em andamento atrasado"
		cSituacao := "Em andamento atrasado"
		cWhere    += " AND GW1_DTPSAI != ' ' AND GW1_DTPSAI < '" + dtos(Date())+ "' AND (GW1_DTSAI != ' ' OR GW1_DTPSAI < GW1_DTSAI)"
	ElseIf Alltrim(oFiltro["03_GFE_SITUACAO"]) == "CA"                  // "Concluído atrasado"
		cSituacao := "Concluído atrasado"
		cWhere    += " AND GWU1.GWU_DTPENT != ' ' AND GWU1.GWU_DTENT != ' ' AND GWU1.GWU_DTENT > GW1_DTPENT"
	ElseIf Alltrim(oFiltro["03_GFE_SITUACAO"]) == "AP"                  // "Em andamento no prazo"
		cSituacao := "Em andamento no prazo"
		cWhere    += " AND GW1_DTPSAI > GW1_DTSAI AND GWU1.GWU_DTPENT != ' ' AND GWU1.GWU_DTENT = ' ' AND GWU1.GWU_DTPENT < '" + dtos(Date()) + "'"
	ElseIf Alltrim(oFiltro["03_GFE_SITUACAO"]) == "CP"                 // "Concluído no prazo"
		cSituacao := "Concluído no prazo"
		cWhere    += " AND GWU1.GWU_DTPENT != ' ' AND GW1_DTPENT >= GWU1.GWU_DTENT"
	Else
		cSituacao := "Todos"
	EndIf

	cCpoQry := "%" + cCpoQry + "%"
	cInnerGWN := "%" + cInnerGWN + "%"
	cWhere := "%" + cWhere + "%"

	oDados["items"]        := {}
	oDados["columns"]      := montaColun()
	oDados["canExportCSV"] := .T.
	oDados["tags"]         := {}

	aAdd(oDados["tags"],JsonObject():New())
	oDados["tags"][1]["icone"]      := "po-icon-company"
	oDados["tags"][1]["colorTexto"] := ""
	oDados["tags"][1]["texto"]      := oFiltro["01_GFE_FILIAL"] + " - " + oFiltro["02_GFE_FILIAL"]
	aAdd(oDados["tags"],JsonObject():New())
	oDados["tags"][2]["icone"]      := "po-icon-calendar"
	oDados["tags"][2]["colorTexto"] := ""
	oDados["tags"][2]["texto"]      := dToC(dDataIni) + " - " + dToC(dDataFim)
	aAdd(oDados["tags"],JsonObject():New())
	oDados["tags"][3]["icone"]      := "po-icon-bar-code"
	oDados["tags"][3]["colorTexto"] := ""
	oDados["tags"][3]["texto"] := cSituacao


	BeginSql Alias cAlias
        SELECT GW1.GW1_FILIAL AS GW1_FILIAL
             , GU3EMI.GU3_NMEMIT AS GW1_NMEMIS
             , GW1.GW1_CDTPDC AS GW1_CDTPDC
             , GW1.GW1_SERDC AS GW1_SERDC
             , GW1.GW1_NRDC AS GW1_NRDC
             , GW1.GW1_DTEMIS AS GW1_DTEMIS
             , ' ' AS STATUS
             , GW1.GW1_DTPSAI AS GW1_DTPSAI
             , GW1.GW1_DTSAI AS GW1_DTSAI
             , GW1.GW1_DTPENT AS GW1_DTPENT
             , GWUFIN.GWU_DTPENT AS GWU_DTPENT
             , GWUFIN.GWU_DTENT AS GWU_DTENT
             , GU7.GU7_NMCID AS GU7_NMCID
             , GU7.GU7_CDUF AS GU7_CDUF
             , GW1.GW1_NRROM AS GW1_NRROM
             , CASE WHEN OCO.QTD_OCO IS NULL THEN 0 ELSE OCO.QTD_OCO END AS QTD_OCO
             , CASE WHEN TRP1.GU3_NMEMIT IS NULL THEN ' ' ELSE TRP1.GU3_NMEMIT END AS NMEMIT_1
             , CASE WHEN TRP2.GU3_NMEMIT IS NULL THEN ' ' ELSE TRP2.GU3_NMEMIT END AS NMEMIT_2
             , CASE WHEN TRP3.GU3_NMEMIT IS NULL THEN ' ' ELSE TRP3.GU3_NMEMIT END AS NMEMIT_3
             , CASE WHEN GWN.GWN_RASTR IS NULL THEN ' ' ELSE GWN.GWN_RASTR END AS GWN_RASTR
             %Exp:cCpoQry%
		FROM %Table:GW1% GW1
	    INNER JOIN %Table:GU3% GU3
	      ON GU3.GU3_CDEMIT = GW1.GW1_CDDEST
         AND GU3.%NotDel%
	    INNER JOIN %Table:GU3% GU3EMI
	      ON GU3EMI.GU3_CDEMIT = GW1.GW1_EMISDC
         AND GU3EMI.%NotDel%
        INNER JOIN %Table:GU7% GU7
          ON GU7.GU7_NRCID = GU3.GU3_NRCID
         AND GU7.%NotDel%
        INNER JOIN %Table:GWU% GWU1
          ON GWU1.GWU_NRDC = GW1.GW1_NRDC
         AND GWU1.GWU_FILIAL = GW1.GW1_FILIAL
         AND GWU1.GWU_EMISDC = GW1.GW1_EMISDC
         AND GWU1.GWU_SERDC = GW1.GW1_SERDC
         AND GWU1.GWU_CDTPDC = GW1.GW1_CDTPDC
         AND GWU1.GWU_SEQ = '01'
         AND GWU1.%NotDel%
		 LEFT JOIN %Table:GWN% GWN
         ON %Exp:cInnerGWN%
	     AND GWN.GWN_NRROM = GW1.GW1_NRROM
	     AND GWN.%NotDel%
        LEFT JOIN %Table:GWU% GWU2
          ON GWU2.GWU_NRDC = GW1.GW1_NRDC
         AND GWU2.GWU_FILIAL = GW1.GW1_FILIAL
         AND GWU2.GWU_EMISDC = GW1.GW1_EMISDC
         AND GWU2.GWU_SERDC = GW1.GW1_SERDC
         AND GWU2.GWU_CDTPDC = GW1.GW1_CDTPDC
         AND GWU2.GWU_SEQ = '02'
         AND GWU2.%NotDel%
        LEFT JOIN %Table:GWU% GWU3
          ON GWU3.GWU_NRDC = GW1.GW1_NRDC
         AND GWU3.GWU_FILIAL = GW1.GW1_FILIAL
         AND GWU3.GWU_EMISDC = GW1.GW1_EMISDC
         AND GWU3.GWU_SERDC = GW1.GW1_SERDC
         AND GWU3.GWU_CDTPDC = GW1.GW1_CDTPDC
         AND GWU3.GWU_SEQ = '03'
         AND GWU3.%NotDel%
        LEFT JOIN ( 
                    SELECT GWU1.GWU_FILIAL, GWU1.GWU_CDTPDC, GWU1.GWU_EMISDC, GWU1.GWU_SERDC, GWU1.GWU_NRDC, GWU1.GWU_DTENT, GWU1.GWU_DTPENT
                    FROM %Table:GWU% GWU1
                    INNER JOIN ( SELECT GWU_FILIAL, GWU_CDTPDC, GWU_EMISDC, GWU_SERDC, GWU_NRDC, MAX(GWU_SEQ) GWU_SEQ
                                 FROM %Table:GWU% GWU
                                 WHERE GWU.%NotDel%
                                 AND GWU_PAGAR = '1' GROUP BY GWU_FILIAL, GWU_CDTPDC, GWU_EMISDC, GWU_SERDC, GWU_NRDC ) GWU2
                    ON GWU1.GWU_FILIAL = GWU2.GWU_FILIAL
                    AND GWU1.GWU_CDTPDC = GWU2.GWU_CDTPDC
                    AND GWU1.GWU_EMISDC = GWU2.GWU_EMISDC
                    AND GWU1.GWU_SERDC = GWU2.GWU_SERDC
                    AND GWU1.GWU_NRDC = GWU2.GWU_NRDC
                    AND GWU1.GWU_SEQ = GWU2.GWU_SEQ
                    WHERE GWU1.%NotDel%
                    AND GWU1.GWU_PAGAR = '1'
                  ) GWUFIN
	      ON GWUFIN.GWU_NRDC = GW1.GW1_NRDC
	     AND GWUFIN.GWU_FILIAL = GW1.GW1_FILIAL
	     AND GWUFIN.GWU_EMISDC = GW1.GW1_EMISDC
	     AND GWUFIN.GWU_SERDC = GW1.GW1_SERDC
	     AND GWUFIN.GWU_CDTPDC = GW1.GW1_CDTPDC
        LEFT JOIN ( SELECT GWL_NRDC, GWL_FILDC, GWL_EMITDC, GWL_SERDC, GWL_TPDC, COUNT(*) QTD_OCO
                    FROM %Table:GWL% GWL
                    WHERE GWL.%NotDel% GROUP BY GWL_NRDC, GWL_FILDC, GWL_EMITDC, GWL_SERDC, GWL_TPDC
                  ) OCO
          ON OCO.GWL_NRDC = GW1.GW1_NRDC
         AND OCO.GWL_FILDC = GW1.GW1_FILIAL
         AND OCO.GWL_EMITDC = GW1.GW1_EMISDC
         AND OCO.GWL_SERDC = GW1.GW1_SERDC
         AND OCO.GWL_TPDC = GW1.GW1_CDTPDC
        LEFT JOIN %Table:GU3% TRP1
          ON TRP1.GU3_CDEMIT = GWU1.GWU_CDTRP
         AND TRP1.%NotDel%
        LEFT JOIN %Table:GU3% TRP2
          ON TRP2.GU3_CDEMIT = GWU2.GWU_CDTRP
         AND TRP2.%NotDel%
        LEFT JOIN %Table:GU3% TRP3
          ON TRP3.GU3_CDEMIT = GWU3.GWU_CDTRP
         AND TRP3.%NotDel%
        WHERE GW1.GW1_FILIAL BETWEEN %Exp:cFilDe% AND %Exp:cFilAte%
	    AND GW1.GW1_DTEMIS BETWEEN %Exp:DTOS(dDataIni)% AND %Exp:DTOS(dDatabase)%
        AND %Exp:cWhere%
	EndSql
	While (cAlias)->(!Eof())

		aAdd(oDados["items"], JsonObject():New())
		nPos++
		For nI := 1 To Len(aFields)
			If Alltrim(aFields[nI][3]) == "D"
				oDados["items"][nPos][aFields[nI][2]] := &( "DTOC(STOD((cAlias)->" + Alltrim(aFields[nI][2])+"))" )
			ElseIf Alltrim(aFields[nI][3]) == "N"
				oDados["items"][nPos][aFields[nI][2]] := &("Round((cAlias)->" + Alltrim(aFields[nI][2])+", 2)")
			Else
				// If Alltrim(aFields[nI][2]) == "STATUS"
				//     If Empty((cAlias)->GW1_DTPSAI)
				//         oDados["items"][nPos][aFields[nI][2]] := {"1", COR_CINZA}
				//     ElseIf !Empty((cAlias)->GW1_DTPSAI) .And. Empty((cAlias)->GW1_DTSAI)
				//         oDados["items"][nPos][aFields[nI][2]] := {"2", COR_AMARELO}
				//     ElseIf !Empty((cAlias)->GWU_DTPENT) .And. (cAlias)->GWU_DTENT < (cAlias)->GW1_DTPENT
				//         oDados["items"][nPos][aFields[nI][2]] := {"3", COR_VERMELHO}
				//     ElseIf !Empty((cAlias)->GWU_DTPENT) .And. (cAlias)->GWU_DTPENT < dtos(Date())
				//         oDados["items"][nPos][aFields[nI][2]] := {"4", COR_AZUL}
				//     ElseIf !Empty((cAlias)->GWU_DTPENT) .And. (cAlias)->GWU_DTPENT > (cAlias)->GWU_DTENT
				//         oDados["items"][nPos][aFields[nI][2]] := {"5", COR_VERDE}
				//     Else
				//         oDados["items"][nPos][aFields[nI][2]] := {"0", COR_BRANCO}
				//     EndIf
				// Else
				oDados["items"][nPos][aFields[nI][2]] := &("Alltrim((cAlias)->" + Alltrim(aFields[nI][2])+")")
				//EndIf
			EndIf
		Next nI

		(cAlias)->(dbSkip())
	EndDo
	oDados["hasNext"] := (cAlias)->(!Eof())
	(cAlias)->(dbCloseArea())
Return oDados:ToJson()

/*/{Protheus.doc} montaColun
Realiza a criação de objeto Json que define as colunas utilizadas na grid de detalhamento do monitor
@type Static Function
@author Jefferson Hita
@since 28/08/2023
@version P12.1.2410
@return aColumns, array objetos, Contém as definições das colunas da grid do monitor
/*/
Static Function montaColun()
	Local aColumns := {}
	Local nI       := 0
	Local nPos     := 0

	For nI := 1 To Len(aFields)
		// If Alltrim(aFields[nI][2]) == "STATUS"
		//     aAdd(aColumns, JsonObject():New())
		//     nPos++
		//     aColumns[nPos]["property"] := Alltrim(aFields[nI][2])
		//     aColumns[nPos]["label"]    := "Status"
		//     aColumns[nPos]["type"]     := "cellTemplate"
		//     aColumns[nPos]["labels"]   := {}
		//     aAdd(aColumns[nPos]["labels"], JsonObject():New())
		//     aColumns[nPos]["labels"][1]['value']     := '1'
		//     aColumns[nPos]["labels"][1]['color']     := COR_CINZA
		//     aColumns[nPos]["labels"][1]['label']     := "Sem previsão"
		//     aColumns[nPos]["labels"][1]['textColor'] := COR_PRETO
		//     aAdd(aColumns[nPos]["labels"], JsonObject():New())
		//     aColumns[nPos]["labels"][2]['value']     := '2'
		//     aColumns[nPos]["labels"][2]['color']     := COR_AMARELO
		//     aColumns[nPos]["labels"][2]['label']     := "Em andamento atrasado"
		//     aColumns[nPos]["labels"][2]['textColor'] := COR_BRANCO
		//     aAdd(aColumns[nPos]["labels"], JsonObject():New())
		//     aColumns[nPos]["labels"][3]['value']     := '3'
		//     aColumns[nPos]["labels"][3]['color']     := COR_VERMELHO
		//     aColumns[nPos]["labels"][3]['label']     := "Concluído atrasado"
		//     aColumns[nPos]["labels"][3]['textColor'] := COR_BRANCO
		//     aAdd(aColumns[nPos]["labels"], JsonObject():New())
		//     aColumns[nPos]["labels"][4]['value']     := '4'
		//     aColumns[nPos]["labels"][4]['color']     := COR_AZUL
		//     aColumns[nPos]["labels"][4]['label']     := "Em andamento no prazo"
		//     aColumns[nPos]["labels"][4]['textColor'] := COR_BRANCO
		//     aAdd(aColumns[nPos]["labels"], JsonObject():New())
		//     aColumns[nPos]["labels"][5]['value']     := '5'
		//     aColumns[nPos]["labels"][5]['color']     := COR_VERDE
		//     aColumns[nPos]["labels"][5]['label']     := "Concluído no prazo"
		//     aColumns[nPos]["labels"][5]['textColor'] := COR_BRANCO
		//     aAdd(aColumns[nPos]["labels"], JsonObject():New())
		//     aColumns[nPos]["labels"][6]['value']     := '0'
		//     aColumns[nPos]["labels"][6]['color']     := COR_BRANCO
		//     aColumns[nPos]["labels"][6]['label']     := " "
		//     aColumns[nPos]["labels"][6]['textColor'] := COR_BRANCO
		// Else
		aAdd(aColumns, JsonObject():New())
		nPos++
		aColumns[nPos]["label"]    := aFields[nI][1]
		aColumns[nPos]["property"] := aFields[nI][2]
		aColumns[nPos]["type"]     := "string"
		aColumns[nPos]["visible"]  := .T.
		//EndIf
	Next nI

Return aColumns

/*/{Protheus.doc} montaGraf
Monta objeto json com os dados para mostrar o gauge
@type Static Function
@author Jefferson Hita
@since 28/08/2023
@version P12.1.2410
@param  oJsonRet  , objeto json, Objeto json que receberá os dados do gauge
@param  nQtdDoc   , numerico   , Número de documentos retornado da consulta
@param  aSemaforo , array      , Array com os números do semáforo
@param  oFiltros  , array      , filtros configurados
@param  cTipoSemaf, caracter   , L - Quantidade Lotes / Q - Saldo Lotes
@param  cSubTipo  , caracter   , Tipo de grafico pie/bar/column
@return Nil
/*/
Static Function montaGraf(oJsonRet,nQtdDoc,aSemaforo,oFiltros,cTipoSemaf,cSubTipo)
	Local cMesAtual  := ""
	Local cValorFim  := ""
	Local cValSemaf1 := iif(Len(aSemaforo) > 0, aSemaforo[1], '0')
	Local cValSemaf2 := iif(Len(aSemaforo) > 0, aSemaforo[2], '0')
	Local cAlias     := GetNextAlias()
	Local nI         := 0
	Local nPosDt     := 0
	Local nValorFim  := 0
	Local nValSemaf1 := Val(cValSemaf1)
	Local nValSemaf2 := Val(cValSemaf2)
	Local dDataIni   := ""
	Local aAuxMes   := {}
	Local aSemPrev  := {} // "Sem previsão"
	Local aAndAtraz := {} // "Em andamento atrasado"
	Local aConcAtrz := {} // "Concluído atrasado"
	Local aAndPrz   := {} // "Em andamento no prazo"
	Local aConcPrz  := {} // "Concluído no prazo"
	Local oDados     := JsonObject():New()

	If cSubTipo == "gauge"
		If nQtdDoc > nValSemaf2
			nValorFim := nQtdDoc + (nValSemaf2 - nValSemaf1)
		Else
			nValorFim := nValSemaf2 + (nValSemaf2 - nValSemaf1)
		EndIf
		cValorFim := cValToChar(nValorFim)

		oJsonRet["alturaMinimaWidget"] := "350px"
		oJsonRet["alturaMaximaWidget"] := "500px"
		oJsonRet["categorias"] := {}
		oJsonRet["series"]     := {}
		oJsonRet["detalhes"]   := {}
		oJsonRet["gauge"]           := JsonObject():New()
		oJsonRet["gauge"]["type"]   := "arch"
		oJsonRet["gauge"]["value"]  := nQtdDoc
		oJsonRet["gauge"]["max"]    := nValorFim
		oJsonRet["gauge"]["label"]  := "Documento(s)"
		oJsonRet["gauge"]["append"] := ""
		oJsonRet["gauge"]["thick"]  := 20
		oJsonRet["gauge"]["margin"] := 15
		oJsonRet["gauge"]["valueStyle"]                := JsonObject():New()
		oJsonRet["gauge"]["valueStyle"]["color"]       := retCorSmf(nQtdDoc,nValSemaf1,nValSemaf2)
		oJsonRet["gauge"]["valueStyle"]["font-weight"] := "bold"
		oJsonRet["gauge"]["labelStyle"]                := JsonObject():New()
		oJsonRet["gauge"]["labelStyle"]["font-weight"] := "bold"
		oJsonRet["gauge"]["thresholds"]                          := JsonObject():New()
		oJsonRet["gauge"]["thresholds"]["0"]                     := JsonObject():New()
		oJsonRet["gauge"]["thresholds"]["0"]["color"]            := COR_VERDE_FORTE
		oJsonRet["gauge"]["thresholds"]["0"]["bgOpacity"]        := 0.2
		oJsonRet["gauge"]["thresholds"][cValSemaf1]              := JsonObject():New()
		oJsonRet["gauge"]["thresholds"][cValSemaf1]["color"]     := COR_AMARELO_QUEIMADO
		oJsonRet["gauge"]["thresholds"][cValSemaf1]["bgOpacity"] := 0.2
		oJsonRet["gauge"]["thresholds"][cValSemaf2]              := JsonObject():New()
		oJsonRet["gauge"]["thresholds"][cValSemaf2]["color"]     := COR_VERMELHO_FORTE
		oJsonRet["gauge"]["thresholds"][cValSemaf2]["bgOpacity"] := 0.2
		oJsonRet["gauge"]["markers"] := JsonObject():New()
		If Val(cValSemaf1) > 0
			oJsonRet["gauge"]["markers"]["0"]          :=  JsonObject():New()
			oJsonRet["gauge"]["markers"]["0"]["color"] := COR_PRETO
			oJsonRet["gauge"]["markers"]["0"]["size"]  := 6
			oJsonRet["gauge"]["markers"]["0"]["label"] := "0"
			oJsonRet["gauge"]["markers"]["0"]["type"]  := "line"
		EndIf
		oJsonRet["gauge"]["markers"][cValSemaf1] :=  JsonObject():New()
		oJsonRet["gauge"]["markers"][cValSemaf1]["color"]   := COR_PRETO
		oJsonRet["gauge"]["markers"][cValSemaf1]["size"]    := 6
		oJsonRet["gauge"]["markers"][cValSemaf1]["label"]   := cValSemaf1
		oJsonRet["gauge"]["markers"][cValSemaf1]["type"]    := "line"
		oJsonRet["gauge"]["markers"][cValSemaf2] :=  JsonObject():New()
		oJsonRet["gauge"]["markers"][cValSemaf2]["color"]   := COR_PRETO
		oJsonRet["gauge"]["markers"][cValSemaf2]["size"]    := 6
		oJsonRet["gauge"]["markers"][cValSemaf2]["label"]   := cValSemaf2
		oJsonRet["gauge"]["markers"][cValSemaf2]["type"]    := "line"
		oJsonRet["gauge"]["markers"][cValorFim]    :=  JsonObject():New()
		oJsonRet["gauge"]["markers"][cValorFim]["color"]    := COR_PRETO
		oJsonRet["gauge"]["markers"][cValorFim]["size"]     := 6
		oJsonRet["gauge"]["markers"][cValorFim]["label"]    := cValorFim
		oJsonRet["gauge"]["markers"][cValorFim]["type"]     := "line"

	ElseIf cSubTipo == "column" .Or. cSubTipo == "bar"

		dDataIni := PCPMonitorUtils():RetornaPeriodoInicial(AllTrim(oFiltros["04_GFE_TIPOPERIODO"]),dDatabase,cValToChar(oFiltros["05_GFE_PERIODO"]))
		oFiltros["01_GFE_FILIAL"] := PadR(oFiltros["01_GFE_FILIAL"], FWSizeFilial())
		oFiltros["02_GFE_FILIAL"] := PadR(oFiltros["02_GFE_FILIAL"], FWSizeFilial())

		oJsonRet["alturaMinimaWidget"] := "350px"
		oJsonRet["alturaMaximaWidget"] := "500px"
		oJsonRet["categorias"] := {}
		oJsonRet["series"]     := {}
		oJsonRet["tags"]       := {}

		BeginSql Alias cAlias
            SELECT GW1_DTEMIS, GW1_DTPSAI, GW1_DTSAI, GW1_DTPENT, GWU_DTPENT, GWU_DTENT, GWU_NRDC, GWU_SEQ
            FROM %Table:GW1% GW1
            INNER JOIN %Table:GWU% GWU
      	    ON GWU.GWU_FILIAL = GW1.GW1_FILIAL
            AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC
            AND GWU.GWU_EMISDC = GW1.GW1_EMISDC
            AND GWU.GWU_SERDC = GW1.GW1_SERDC
            AND GWU.GWU_NRDC = GW1.GW1_NRDC
            AND GWU.%NotDel%
            WHERE GW1.GW1_FILIAL BETWEEN %Exp:cFilDe% AND %Exp:cFilAte%
            AND GW1.GW1_DTIMPL BETWEEN %Exp:dDataIni% AND %Exp:dDatabase%
            AND %Exp:cWhere%
		EndSql
		While (cAlias)->(!Eof())
			cMesAtual := Month2Str(stod((cAlias)->GW1_DTEMIS))
			If !oDados:HasProperty(cMesAtual)
				aadd(aAuxMes, {cMesAtual, MesExtenso(stod((cAlias)->GW1_DTEMIS))})
				oDados[cMesAtual] := JsonObject():New()
				oDados[cMesAtual]["1"] := 0
				oDados[cMesAtual]["2"] := 0
				oDados[cMesAtual]["3"] := 0
				oDados[cMesAtual]["4"] := 0
				oDados[cMesAtual]["5"] := 0
			EndIf

			If Empty((cAlias)->GW1_DTPSAI) // "Sem previsão"
				oDados[cMesAtual]["1"]++
			ElseIf !Empty((cAlias)->GW1_DTPSAI) .And. STOD((cAlias)->GW1_DTPSAI) < Date() .And. (Empty((cAlias)->GW1_DTSAI) .Or. (cAlias)->GW1_DTPSAI < (cAlias)->GW1_DTSAI )  // "Em andamento atrasado"
				oDados[cMesAtual]["2"]++
			ElseIf !Empty((cAlias)->GWU_DTPENT) .And. !Empty((cAlias)->GWU_DTENT) .And. (cAlias)->GWU_DTENT > (cAlias)->GW1_DTPENT // "Concluído atrasado"
				oDados[cMesAtual]["3"]++
			ElseIf  (cAlias)->GW1_DTPSAI > (cAlias)->GW1_DTSAI .And. !Empty((cAlias)->GWU_DTPENT) .And. Empty((cAlias)->GWU_DTENT) .And. STOD((cAlias)->GWU_DTPENT) >= Date() // "Em andamento no prazo"		
				oDados[cMesAtual]["4"]++
			ElseIf !Empty((cAlias)->GWU_DTPENT) .And. (cAlias)->GWU_DTENT <= (cAlias)->GWU_DTPENT // "Concluído no prazo"
				oDados[cMesAtual]["5"]++
			EndIf

			(cAlias)->(dbSkip())
		EndDo
		(cAlias)->(dbCloseArea())

		// Meses dentro do periodo indicado
		oJsonRet["categorias"] := oDados:GetNames()
		oJsonRet["chaveCategorias"] := {}
		nTotCateg := Len(oJsonRet["categorias"])    // Cada mes referente aos dados filtrados
		For nI := 1 To nTotCateg
			aAdd(aSemPrev, oDados[oJsonRet["categorias"][nI]]["1"])
			aAdd(aAndAtraz, oDados[oJsonRet["categorias"][nI]]["2"])
			aAdd(aConcAtrz, oDados[oJsonRet["categorias"][nI]]["3"])
			aAdd(aAndPrz, oDados[oJsonRet["categorias"][nI]]["4"])
			aAdd(aConcPrz, oDados[oJsonRet["categorias"][nI]]["5"])

			nPosDt := aScan(aAuxMes,{|x| x[1] == oJsonRet["categorias"][nI]})
			aAdd(oJsonRet["chaveCategorias"], JsonObject():New())
			oJsonRet["chaveCategorias"][nI]["valor"] := oJsonRet["categorias"][nI]
			oJsonRet["chaveCategorias"][nI]["label"] := aAuxMes[nPosDt][2]
			oJsonRet["categorias"][nI] := aAuxMes[nPosDt][2]
		Next nIndice

		aAdd(oJsonRet["series"], JsonObject():New())
		oJsonRet["series"][1]["color"]   := COR_CINZA
		oJsonRet["series"][1]["data"]    := aSemPrev
		oJsonRet["series"][1]["tooltip"] := ""
		oJsonRet["series"][1]["label"]   := "Sem previsão"

		aAdd(oJsonRet["series"], JsonObject():New())
		oJsonRet["series"][2]["color"]   := COR_AMARELO
		oJsonRet["series"][2]["data"]    := aAndAtraz
		oJsonRet["series"][2]["tooltip"] := ""
		oJsonRet["series"][2]["label"]   := "Em andamento atrasado"

		aAdd(oJsonRet["series"], JsonObject():New())
		oJsonRet["series"][3]["color"]   := COR_VERMELHO
		oJsonRet["series"][3]["data"]    := aConcAtrz
		oJsonRet["series"][3]["tooltip"] := ""
		oJsonRet["series"][3]["label"]   := "Concluído atrasado"

		aAdd(oJsonRet["series"], JsonObject():New())
		oJsonRet["series"][4]["color"]   := COR_AZUL
		oJsonRet["series"][4]["data"]    := aAndPrz
		oJsonRet["series"][4]["tooltip"] := ""
		oJsonRet["series"][4]["label"]   := "Em andamento no prazo"

		aAdd(oJsonRet["series"], JsonObject():New())
		oJsonRet["series"][5]["color"]   := COR_VERDE
		oJsonRet["series"][5]["data"]    := aConcPrz
		oJsonRet["series"][5]["tooltip"] := ""
		oJsonRet["series"][5]["label"]   := "Concluído no prazo"
	EndIf
Return

/*/{Protheus.doc} montaInfo
Monta objeto json com os dados para mostrar o gráfico de informações
@type Static Function
@author Jefferson Hita
@since 28/08/2023
@version P12.1.2410
@param  oJsonRet  , objeto json, Objeto json que receberá os dados do gauge
@param  nQtdDoc   , numerico   , Número de documentos retornados da consulta
@return Nil
/*/
Static Function montaInfo(oJsonRet, nQtdDoc, aSemaforo)
	Local cTxtPrc    := cValToChar(nQtdDoc)
	Local oStyle     := JsonObject():New()
	Local oStyleQtd  := JsonObject():New()
	Private cTxtSec    := cSituacao

	oStyle["color"] := "white"
	oJsonRet["corTitulo"]          := "white"
	oJsonRet["alturaMinimaWidget"] := "350px"
	oJsonRet["alturaMaximaWidget"] := "500px"
	oJsonRet["linhas"]             := {}

	If cSituacao == "Sem previsão"
          oJSonRet["corFundo"] := COR_CINZA
	elseif cSituacao == "Em andamento atrasado"
        oJSonRet["corFundo"] := COR_AMARELO_ESCURO
	elseif cSituacao == "Concluído atrasado"
        oJSonRet["corFundo"] := COR_VERMELHO_FORTE
	elseif cSituacao == "Em andamento no prazo"
        oJSonRet["corFundo"] := COR_VERDE
	elseif cSituacao == "Concluído no prazo"
        oJSonRet["corFundo"] := COR_VERDE_FORTE
	EndIf

	If nQtdDoc > 0
		oStyle["color"]       := "black"
		oJsonRet["corTitulo"] := "black"
		aAdd(oJsonRet["linhas"],JsonObject():New())
		oStyleQtd["font-weight"] := "bold"
		oStyleQtd["font-size"]   := "120px"
		oStyleQtd["line-height"] := "130px"
		oStyleQtd["text-align"]  := "center"
		oStyleQtd["color"]       := oStyle["color"]
		oStyleQtd["cursor"]      := "pointer"

		oJsonRet["linhas"][1]["texto"]           := cTxtPrc
		oJsonRet["linhas"][1]["tipo"]            := "texto"
		oJsonRet["linhas"][1]["classeTexto"]     := "po-sm-12"
		oJsonRet["linhas"][1]["styleTexto"]      := oStyleQtd:ToJson()
		oJsonRet["linhas"][1]["tituloProgresso"] := ""
		oJsonRet["linhas"][1]["valorProgresso"]  := ""
		oJsonRet["linhas"][1]["icone"]           := ""
		oJsonRet["linhas"][1]["tipoDetalhe"]     := "detalhe"
		aAdd(oJsonRet["linhas"],JsonObject():New())
		oJsonRet["linhas"][2]["texto"]           := cTxtSec
		oJsonRet["linhas"][2]["tipo"]            := "texto"
		oJsonRet["linhas"][2]["classeTexto"]     := "po-font-title po-text-center po-sm-12 po-pt-1 bold-text"
		oJsonRet["linhas"][2]["styleTexto"]      := oStyle:ToJson()
		oJsonRet["linhas"][2]["tituloProgresso"] := ""
		oJsonRet["linhas"][2]["valorProgresso"]  := ""
		oJsonRet["linhas"][2]["icone"]           := ""
	Else
		oJsonRet["corFundo"] := COR_VERDE_FORTE
		aAdd(oJsonRet["linhas"],JsonObject():New())
		oJsonRet["linhas"][1]["texto"]           := "Nenhum carregamento foi identificado no filtro selecionado."
		oJsonRet["linhas"][1]["tipo"]            := "texto"
		oJsonRet["linhas"][1]["classeTexto"]     := "po-font-text-large-bold po-text-center po-sm-12 po-pt-4"
		oJsonRet["linhas"][1]["styleTexto"]      := oStyle:ToJson()
		oJsonRet["linhas"][1]["tituloProgresso"] := ""
		oJsonRet["linhas"][1]["valorProgresso"]  := ""
		oJsonRet["linhas"][1]["icone"]           := ""
		oJsonRet["linhas"][1]["tipoDetalhe"]     := ""
	EndIf
Return

/*/{Protheus.doc} retCorSmf
Retorna a cor do semáforo de acordo com a quantidade parametrizada
@type Static Function
@author douglas.heydt
@since 28/04/2023
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
