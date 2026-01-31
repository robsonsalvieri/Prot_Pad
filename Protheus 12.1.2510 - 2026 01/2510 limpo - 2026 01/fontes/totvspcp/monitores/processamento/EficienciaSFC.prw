#INCLUDE "PROTHEUS.CH"
#INCLUDE "PCPMONITOR.CH"
#INCLUDE "PCPMONITORDEF.CH"

/*/{Protheus.doc} EficienciaSFC
Classe para mostrar o indicador de Eficiencia do modulo do SFC
@type Class
@author breno.ferreira
@since 07/06/2025
@version P12.1.2410
@return Nil
/*/ 
Class EficienciaSFC FROM LongNameClass
	Static Method BuscaDados(oFiltros, cTipo, cSubTipo)
	Static Method BuscaDetalhes(oFiltros, nPagina)
    Static Method CargaMonitor()
	Static Method ValidaPropriedades(oFiltros)
EndClass

/*/{Protheus.doc} CargaMonitor
Realiza a carga do Monitor padrão na base de dados
@type Method
@author breno.ferreira
@since 07/06/2025
@version P12.1.2410
@return lRet, logico, Indica se conseguiu realizar a carga
/*/
Method CargaMonitor() Class EficienciaSFC
	Local aCategr   := {}
    Local aDetalhes := {}
    Local aTags     := {}
    Local lRet      := .T.
    Local nIndTag   := 0
    Local oCarga    := PCPMonitorCarga():New()
	Local oGauge    := PCPMonitorGauge():New()
    Local oPrmAdc   := JsonObject():New()
    Local oSeries   := JsonObject():New()
        
    If !PCPMonitorCarga():monitorAtualizado("EficienciaSFC")

		PCPMonitorUtils():AdicionaTagMonitor(aTags,@nIndTag,"po-icon-calendar","22/06/2025")
		PCPMonitorUtils():AdicionaTagMonitor(aTags,@nIndTag,"an an-clock","15:25:10")
        PCPMonitorUtils():AdicionaTagMonitor(aTags,@nIndTag,"po-icon-bar-code","SFC-MAQ")
        PCPMonitorUtils():AdicionaTagMonitor(aTags,@nIndTag,"po-icon-bar-code","SFC-META")

		oGauge:SetValue(55)
        oGauge:SetValueStyle("color",COR_AMARELO_QUEIMADO)
        oGauge:SetValueStyle("font-weight","bold")
        oGauge:SetLabel(STR0311) //"% Eficiência"
        oGauge:SetLabelStyle("font-weight","bold")
        oGauge:SetThreshold("0",COR_VERMELHO_FORTE)
        oGauge:SetThreshold("40",COR_AMARELO_QUEIMADO)
        oGauge:SetThreshold("75",COR_VERDE_FORTE)
        oGauge:SetMarker("0")
        oGauge:SetMarker("40")
        oGauge:SetMarker("75")
        oGauge:SetMarker("100")

        oCarga:setaTitulo(STR0312) //"Eficiência SFC"
        oCarga:setaObjetivo(STR0313) //"Apresenta a porcentagem de Eficiência da máquina, utilizando o conceito de semáforo para indicar o nível de atenção ou urgência."
        oCarga:setaAgrupador("SFC") //"SFC"
        oCarga:setaFuncaoNegocio("EficienciaSFC")
        oCarga:setaTiposPermitidos("chart")
        oCarga:setaTiposGraficoPermitidos("gauge")
        oCarga:setaTipoPadrao("chart")
        oCarga:setaTipoGraficoPadrao("gauge")
        oCarga:setaTipoDetalhe("detalhe")
		oCarga:setaExemploJsonGrafico(oSeries, aTags, aDetalhes,aCategr,"gauge",oGauge:GetJsonObject())
        oCarga:setaPropriedadeFilial("EFI_FILIAL")
		oCarga:setaPropriedade("EFI_SEMAFORO", STR0314, STR0315,1,10,0,"po-sm-12 po-md-6 po-lg-6 po-xl-6",/*oEstilos*/,/*cIcone*/,/*oPrmAdc*/)// "Urgente;Atenção" "Semáforo"
		oCarga:setaPropriedadeLookupTabela("EFI_MAQUINA", STR0316, .F., "CYB", "CYB_CDMQ", "CYB_DSMQ") //"Máquina"
		oCarga:setaPropriedadeLookupTabela("EFI_METAPROD", STR0317, .F., "CYU", "CYU_CDMEPO", "CYU_DSME") //"Meta Produzida"
		oCarga:setaPropriedade("EFI_DATAREF", "", STR0318, 3,8,0, "po-sm-12 po-md-6 po-lg-6 po-xl-6",/*oEstilos*/,/*cIcone*/,/*oPrmAdc*/) //"Data de Referência"
		oCarga:setaPropriedade("EFI_HORAREF", STR0319, STR0320,1,8,0, "po-sm-12 po-md-6 po-lg-6 po-xl-6",/*oEstilos*/,/*cIcone*/,/*oPrmAdc*/) //"Hora de Referência"
		oPrmAdc["EFI_DATAATUAL"] := JsonObject():New()
       	oPrmAdc["EFI_DATAATUAL"]["opcoes"] := STR0321 + ":" + "S" + ";" + STR0322 + ":" + "N" // "Sim" "Não"
        oCarga:setaPropriedade("EFI_DATAATUAL", "N", STR0323, 4,/*cTamanho*/,/*cDecimal*/, "po-sm-12 po-md-6 po-lg-6 po-xl-6",/*oEstilos*/,/*cIcone*/,oPrmAdc["EFI_DATAATUAL"]) //"Data Atual"
		If !oCarga:gravaMonitorPropriedades()
            lRet := .F.
        EndIf
        oCarga:Destroy()
    EndIf
    FreeObj(oGauge)
    FreeObj(oSeries)
    FreeObj(oPrmAdc)
Return lRet

/*/{Protheus.doc} BuscaDados
Responsável por realizar a busca dos dados que serão exibidos no monitor
@type Method
@author breno.ferreira
@since 07/06/2025
@version P12.1.2410
@param  oFiltros  , objeto Json, Contém as propriedades do monitor usadas para filtrar a query de busca
@param  cTipo     , caracter   , Tipo chart
@param  cSubTipo  , caracter   , Tipo de grafico gauge
@return cJsonDados, caracter   , Retorna um novo Json em formato texto, pronto para conversão e exibição no front
/*/
Method BuscaDados(oFiltros, cTipo, cSubTipo) Class EficienciaSFC
	Local aSemaforo  := StrTokArr(Replace(oFiltros["EFI_SEMAFORO"],",","."),";")
	Local cAliasDH   := ""
	Local cAliasInd  := ""
	Local cCodMaq    := oFiltros["EFI_MAQUINA"]
	Local cCodMeta   := oFiltros["EFI_METAPROD"]
	Local cJsonDados := ""
	Local cLabel     := ""
	Local cQueryDH   := ""
	Local cQueryInd  := ""
	Local dDataRef   := Replace(oFiltros["EFI_DATAREF"],"-","")
	Local hHoraRef   := oFiltros["EFI_HORAREF"]
	Local nDataatual := oFiltros["EFI_DATAATUAL"]
	Local nPos       := 0
	Local nValor     := 0
	Local oExecDH    := Nil
	Local oExecInd   := Nil
	Local oJsonRet   := JsonObject():New()

	oFiltros["EFI_FILIAL"] := PadR(oFiltros["EFI_FILIAL"], FWSizeFilial())
	oJsonRet["tags"]       := {}

	If nDataatual == "S"
		dDataRef := DATE()
		hHoraRef := Time()
	Else
		dDataRef := SToD(dDataRef)
	EndIf

	// Obtendo a data e hora de referência mais próximas da indicada durante a seleção
	cQueryDH := " SELECT CZ4.CZ4_DTRE, "
	cQueryDH +=        " CZ4.CZ4_HRRE "
	cQueryDH +=   " FROM " + RetSQLName('CZ4') + " CZ4 "
	cQueryDH += "  WHERE CZ4.CZ4_FILIAL = ? "
	cQueryDH += "    AND CZ4.CZ4_IDMEPO IN (SELECT CY5.CY5_IDMEPO "
	cQueryDH +=                             " FROM " + RetSQLName('CY5') + " CY5 "
	cQueryDH += "                            WHERE CY5.CY5_FILIAL = CZ4.CZ4_FILIAL "
	cQueryDH += "                              AND CY5.CY5_CDMEPO = ? "
	cQueryDH += "                              AND CY5.CY5_CDMQ   = ? "
	cQueryDH += "                              AND CY5.D_E_L_E_T_ = ' ') "
	cQueryDH += "    AND (( CZ4.CZ4_DTRE = ? "
	cQueryDH += "       	 AND CZ4.CZ4_HRRE <= ?) "
	cQueryDH += "     OR CZ4.CZ4_DTRE  <= ?) "
	cQueryDH += "    AND CZ4.D_E_L_E_T_ = ' ' "
	cQueryDH +=  " ORDER BY CZ4.CZ4_DTRE DESC, "
	cQueryDH +=           " CZ4.CZ4_HRRE DESC "

	oExecDH := FwExecStatement():New(cQueryDH)

	oExecDH:SetString(1, xFilial("CZ4",oFiltros["EFI_FILIAL"]))
	oExecDH:SetString(2, cCodMeta)
	oExecDH:SetString(3, cCodMaq)
	oExecDH:SetDate(4, dDataRef)
	oExecDH:SetString(5, hHoraRef)
	oExecDH:SetDate(6, dDataRef)

    cAliasDH := oExecDH:OpenAlias()

	If (cAliasDH)->(!EOF())
		dDataRef := SToD((cAliasDH)->CZ4_DTRE)
		hHoraRef := (cAliasDH)->CZ4_HRRE
	EndIf

	//Query com os filtros para buscar as informações e apresentar no monitor
	cQueryInd += " SELECT CZ4.CZ4_VLEF VLEF "
	cQueryInd +=   " FROM " + RetSqlName("CZ4") + " CZ4 "
	cQueryInd +=  " INNER JOIN " + RetSqlName("CY5") + " CY5 "
	cQueryInd +=     " ON CY5.CY5_FILIAL = ? "
	cQueryInd +=    " AND CY5.CY5_IDMEPO = CZ4.CZ4_IDMEPO "
	cQueryInd +=    " AND CY5.D_E_L_E_T_ = ' ' "
	cQueryInd +=  " WHERE CZ4.CZ4_FILIAL = ? "
	cQueryInd +=    " AND CZ4.CZ4_CDMQ   = ? "
	cQueryInd +=    " AND CZ4.CZ4_DTRE   = ? "
	cQueryInd +=    " AND CZ4.CZ4_HRRE   = ? "
	cQueryInd +=    " AND CY5.CY5_CDMEPO = ? " 
	cQueryInd +=    " AND CZ4.D_E_L_E_T_ = ' ' "

	oExecInd := FwExecStatement():New(cQueryInd)

	oExecInd:SetString(1, xFilial("CY5",oFiltros["EFI_FILIAL"]))
	oExecInd:SetString(2, xFilial("CZ4",oFiltros["EFI_FILIAL"]))
	oExecInd:SetString(3, cCodMaq)
	oExecInd:SetDate(4, dDataRef)
	oExecInd:SetString(5, hHoraRef)
	oExecInd:SetString(6, cCodMeta)

    cAliasInd := oExecInd:OpenAlias()

	nValor := 0
	If (cAliasInd)->(!Eof())
		nValor := Round((cAliasInd)->VLEF,2)
		cLabel := STR0311 //"% Eficiência"
	EndIf

	If cSubTipo == "gauge"
		montaGraf(oJsonRet, cLabel, nValor, aSemaforo)
	EndIf

	//Adiciona tags ao monitor
	PCPMonitorUtils():AdicionaTagMonitor(oJsonRet["tags"],@nPos,"po-icon-calendar",PCPConvDat(DToS(dDataRef), 4))
	PCPMonitorUtils():AdicionaTagMonitor(oJsonRet["tags"],@nPos,"an an-clock",hHoraRef)
	PCPMonitorUtils():AdicionaTagMonitor(oJsonRet["tags"],@nPos,"po-icon-bar-code",cCodMaq)
	PCPMonitorUtils():AdicionaTagMonitor(oJsonRet["tags"],@nPos,"po-icon-bar-code",cCodMeta)

	cJsonDados :=  oJsonRet:toJson()

	FwFreeArray(aSemaforo)
	FreeObj(oJsonRet)
	FreeObj(oExecDH)
	FreeObj(oExecInd)

Return cJsonDados


/*/{Protheus.doc} BuscaDetalhes
Responsável por realizar a busca dos dados que serão exibidos no detalhamento do monitor
@type Method
@author breno.ferreira
@since 07/06/2025
@version P12.1.2410
@param  oFiltros  , objeto Json , Contém as propriedades do monitor usadas para filtrar a query de busca
@param  nPagina   , numerico    , Número da página desejada para busca
@return cJsonDados, caracter    , Retorna um novo Json em formato texto, pronto para conversão e exibição no front
/*/
Method BuscaDetalhes(oFiltros, nPagina) Class EficienciaSFC
	Local cAliasDH   := ""
	Local cAliasItem := ""
	Local cCodMaq    := oFiltros["EFI_MAQUINA"]
	Local cCodMeta   := oFiltros["EFI_METAPROD"]
	Local cJsonDados := ""
	Local cQueryDH   := ""
	Local cQueryItem := ""
	Local dDataRef   := Replace(oFiltros["EFI_DATAREF"],"-","")
	Local hHoraRef   := oFiltros["EFI_HORAREF"]
	Local nDataatual := oFiltros["EFI_DATAATUAL"]
	Local nIndTag    := 0
	Local nPos       := 0
	Local nStart     := 1
	Local nTamPagina := 20
	Local oDados     := JsonObject():New()
	Local oExecDH    := Nil
	Local oExecItem  := Nil

	Default nPagina := 1

	oFiltros["EFI_FILIAL"] := PadR(oFiltros["EFI_FILIAL"], FWSizeFilial())

	oDados["items"]        := {}
	oDados["columns"]      := montaColun()
	oDados["canExportCSV"] := .T.
	oDados["tags"]         := {}

	If nDataatual == "S"
		dDataRef = DATE()
		hHoraRef = Time()
	Else
		dDataRef := SToD(dDataRef)
	EndIf

	cQueryDH := " SELECT CZ4.CZ4_DTRE, "
	cQueryDH +=        " CZ4.CZ4_HRRE "
	cQueryDH +=   " FROM " + RetSQLName("CZ4") + " CZ4 "
	cQueryDH += "  WHERE CZ4.CZ4_FILIAL = ? "
	cQueryDH += "    AND CZ4.CZ4_IDMEPO IN (SELECT CY5.CY5_IDMEPO 
	cQueryDH +=                             " FROM " + RetSQLName("CY5") + " CY5 "
	cQueryDH += "                            WHERE CY5.CY5_FILIAL = CZ4.CZ4_FILIAL "
	cQueryDH += "                              AND CY5.CY5_CDMEPO = ? "
	cQueryDH += "                              AND CY5.CY5_CDMQ   = ? " 
	cQueryDH += "                              AND CY5.D_E_L_E_T_ = ' ') "
	cQueryDH += "    AND (( CZ4.CZ4_DTRE = ? "
	cQueryDH += "           AND CZ4.CZ4_HRRE <= ? ) "
	cQueryDH += "     OR CZ4.CZ4_DTRE <= ? ) "
	cQueryDH += "    AND CZ4.D_E_L_E_T_ = ' ' "
	cQueryDH += " ORDER BY CZ4.CZ4_DTRE DESC, "
	cQueryDH +=          " CZ4.CZ4_HRRE DESC "

	oExecDH := FwExecStatement():New(cQueryDH)

	oExecDH:SetString(1, xFilial("CZ4",oFiltros["EFI_FILIAL"]))
	oExecDH:SetString(2, cCodMeta)
	oExecDH:SetString(3, cCodMaq)
	oExecDH:SetDate(4, dDataRef)
	oExecDH:SetString(5, hHoraRef)
	oExecDH:SetDate(6, dDataRef)

    cAliasDH := oExecDH:OpenAlias()

	If (cAliasDH)->(!EOF())
		dDataRef := SToD((cAliasDH)->CZ4_DTRE)
		hHoraRef := (cAliasDH)->CZ4_HRRE
	EndIf

	cQueryItem += " SELECT CZ5.CZ5_CDAC, "
	cQueryItem +=        " Sum(CZ5.CZ5_HRTEAT) AS CZ5_HRTEAT, "
	cQueryItem +=        " Sum(CZ5.CZ5_HRATPA) AS CZ5_HRATPA, "
	cQueryItem +=        " Sum(CZ5.CZ5_QTRPPL) AS CZ5_QTRPPL, "
	cQueryItem +=        " Sum(CZ5.CZ5_QTRP) AS CZ5_QTRP, "
	cQueryItem +=        " Sum(CZ5.CZ5_QTRF) AS CZ5_QTRF, "
	cQueryItem +=        " Sum(CZ5.CZ5_QTRT) AS CZ5_QTRT "
	cQueryItem +=   " FROM " + RetSqlName("CZ5") + " CZ5 "
	cQueryItem +=  " INNER JOIN " + RetSqlName("CZ4") + " CZ4 "
	cQueryItem +=     " ON CZ4.CZ4_FILIAL = ? "
	cQueryItem +=    " AND CZ4.CZ4_DTRE   = CZ5.CZ5_DTRE "
	cQueryItem +=    " AND CZ4.CZ4_HRRE   = CZ5.CZ5_HRRE "
	cQueryItem +=    " AND CZ4.CZ4_IDMEPO = CZ5.CZ5_IDMEPO "
	cQueryItem +=    " AND CZ4.D_E_L_E_T_ = ' ' "
	cQueryItem +=  " INNER JOIN " + RetSqlName("CY5") + " CY5 "
	cQueryItem +=     " ON CY5.CY5_FILIAL = ? "
	cQueryItem +=    " AND CY5.CY5_IDMEPO = CZ4.CZ4_IDMEPO "
	cQueryItem +=    " AND CY5.D_E_L_E_T_ = ' ' "
	cQueryItem +=  " WHERE CZ5.CZ5_FILIAL = ? "
	cQueryItem +=    " AND CZ5.CZ5_CDMQ   = ? "
	cQueryItem +=    " AND CZ4.CZ4_DTRE   = ? "
	cQueryItem +=    " AND CZ4.CZ4_HRRE   = ? "
	cQueryItem +=    " AND CY5.CY5_CDMEPO = ? "
	cQueryItem +=    " AND (CZ5.CZ5_TPMV  = '4' " 
	cQueryItem +=     " OR CZ5.CZ5_TPMV   = '1') " 
	cQueryItem +=    " AND CZ5.D_E_L_E_T_ = ' ' "
	cQueryItem +=  " GROUP BY CZ4.CZ4_DTRE, "
	cQueryItem +=           " CZ4.CZ4_HRRE, "
	cQueryItem +=           " CZ5.CZ5_CDAC "
	cQueryItem +=  " ORDER BY CZ5.CZ5_CDAC "

	oExecItem := FwExecStatement():New(cQueryItem)

	oExecItem:SetString(1, xFilial("CZ4",oFiltros["EFI_FILIAL"]))
	oExecItem:SetString(2, xFilial("CY5",oFiltros["EFI_FILIAL"]))
	oExecItem:SetString(3, xFilial("CZ5",oFiltros["EFI_FILIAL"]))
	oExecItem:SetString(4, cCodMaq)
	oExecItem:SetDate(5, dDataRef)
	oExecItem:SetString(6, hHoraRef)
	oExecItem:SetString(7, cCodMeta)

	cAliasItem := oExecItem:OpenAlias()

	If nPagina > 1
		nStart := ( (nPagina-1) * nTamPagina )
		If nStart > 0
			(cAliasItem)->(DbSkip(nStart))
		EndIf
	EndIf

	While (cAliasItem)->(!Eof())
		aAdd(oDados["items"], JsonObject():New())
		nPos++
		oDados["items"][nPos]["CZ5_CDAC"  ] := (cAliasItem)->CZ5_CDAC
		oDados["items"][nPos]["CZ5_HRTEAT"] := (cAliasItem)->CZ5_HRTEAT
		oDados["items"][nPos]["CZ5_HRATPA"] := (cAliasItem)->CZ5_HRATPA
		oDados["items"][nPos]["CZ5_QTRPPL"] := Round((cAliasItem)->CZ5_QTRPPL, 2)
		oDados["items"][nPos]["CZ5_QTRP"  ] := Round((cAliasItem)->CZ5_QTRP, 2)
		oDados["items"][nPos]["CZ5_QTRF"  ] := Round((cAliasItem)->CZ5_QTRF, 2)
		oDados["items"][nPos]["CZ5_QTRT"  ] := Round((cAliasItem)->CZ5_QTRT, 2)

		(cAliasItem)->(dbSkip())

		If nPos >= nTamPagina
			Exit
		EndIf
	EndDo

	PCPMonitorUtils():AdicionaTagMonitor(oDados["tags"],@nIndTag,"po-icon-calendar",PCPConvDat(DToS(dDataRef), 4))
	PCPMonitorUtils():AdicionaTagMonitor(oDados["tags"],@nIndTag,"an an-clock",hHoraRef)
	PCPMonitorUtils():AdicionaTagMonitor(oDados["tags"],@nIndTag,"po-icon-bar-code",cCodMaq)
	PCPMonitorUtils():AdicionaTagMonitor(oDados["tags"],@nIndTag,"po-icon-bar-code",cCodMeta)

	oDados["hasNext"] := (cAliasItem)->(!Eof())
	(cAliasItem)->(dbCloseArea())

	cJsonDados := oDados:ToJson()

	FreeObj(oExecDH)
	FreeObj(oExecItem)

Return cJsonDados

/*/{Protheus.doc} ValidaPropriedades
Valida os dados informados nas propriedades do Monitor
@type Method
@author breno.ferreira
@since 07/06/2025
@version P12.1.2410
@param  oFiltros, objeto json, Objeto json com os filtros para a consulta dos dados
@return aRetorno, array      , [1] logico - indica se os dados são válidos [2] caracter - mensagem de erro
/*/
Method ValidaPropriedades(oFiltros) Class EficienciaSFC
	Local aRetorno  := {.T., ""}
	Local aSemaforo := {}
	Local nX        := 0

	PCPMonitorUtils():ValidaPropriedadeFilial(oFiltros["EFI_FILIAL"],aRetorno)

	If aRetorno[1] .And. Empty(oFiltros["EFI_MAQUINA"])
		aRetorno[1] := .F.
		aRetorno[2] := STR0325 //"A Máquina deve ser informada."
	EndIf

	If aRetorno[1] .And. Empty(oFiltros["EFI_METAPROD"])
		aRetorno[1] := .F.
		aRetorno[2] := STR0326 //"A meta deve ser informada."
	EndIf

	If aRetorno[1] .And. oFiltros["EFI_DATAATUAL"] == "N"
		If Empty(oFiltros["EFI_DATAREF"]) .Or. Empty(oFiltros["EFI_HORAREF"])
			aRetorno[1] := .F.
			aRetorno[2] := STR0327 //"A Data e Hora deve ser informada."
		EndIf
	EndIf

	If aRetorno[1]
		If !oFiltros:HasProperty("EFI_SEMAFORO") .Or. oFiltros["EFI_SEMAFORO"] == Nil .Or. Empty(oFiltros["EFI_SEMAFORO"])
			aRetorno[1] := .F.
			aRetorno[2] := STR0328 //"O campo 'Semáforo' deve ser preenchido com 2 valores separados por ponto e vírgula (ex.: '10;100') que indicam Urgência e Atenção, respectivamente"
		Else 
			aSemaforo := STRTOKARR(Replace(oFiltros["EFI_SEMAFORO"],",","."),";")
			If Len(aSemaforo) <> 2
				aRetorno[1] := .F.
				aRetorno[2] := STR0328 //"O campo 'Semáforo' deve ser preenchido com 2 valores separados por ponto e vírgula (ex.: '10;100') que indicam Urgência e Atenção, respectivamente"
			Else
				For nX := 1 To 2
					If Empty(aSemaforo[nX])
						aRetorno[1] := .F.
						aRetorno[2] := STR0328 //"O campo 'Semáforo' deve ser preenchido com 2 valores separados por ponto e vírgula (ex.: '10;100') que indicam Urgência e Atenção, respectivamente"
						Exit
					EndIf
				Next nX
				If Val(aSemaforo[1]) >= Val(aSemaforo[2])
					aRetorno[1] := .F.
					aRetorno[2] := STR0329 //"No campo 'Semáforo', o primeiro valor, referente ao status 'Urgência', deve ser menor que o segundo, que representa 'Atenção'"
				EndIf
			EndIf
		EndIf
	EndIf
	FwFreeArray(aSemaforo)

Return aRetorno

/*/{Protheus.doc} montaColun
Realiza a criação de objeto Json que define as colunas utilizadas na grid de detalhamento do monitor
@type Static Function
@author breno.ferreira
@since 07/06/2025
@version P12.1.2410
@return aColumns, array objetos, Contém as definições das colunas da grid do monitor
/*/
Static Function montaColun()
	Local aColunas := {}
	Local nIndCol  := 0

	PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndCol,"CZ5_CDAC"  ,STR0374,"string",.T.) //"Item"
	PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndCol,"CZ5_HRTEAT",STR0366,"string",.T.) //"Tempo Real"
	PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndCol,"CZ5_HRATPA",STR0377,"string",.T.) //"Tempo Padrão"
	PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndCol,"CZ5_QTRPPL",STR0367,"string",.T.) //"Quant. Projetada"
	PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndCol,"CZ5_QTRP"  ,STR0368,"string",.T.) //"Quant. Real"
	PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndCol,"CZ5_QTRF"  ,STR0375,"string",.T.) //"Refugo Real"
	PCPMonitorUtils():AdicionaColunaTabela(aColunas,@nIndCol,"CZ5_QTRT"  ,STR0376,"string",.T.) //"Retrabalho Real"

Return aColunas

/*/{Protheus.doc} montaGraf
Monta objeto json com os dados para mostrar o gauge
@type Static Function
@author breno.ferreira
@since 07/06/2025
@version P12.1.2410
@param  oJsonRet  , objeto json, Objeto json que receberá os dados do gauge
@param  cLabel    , character  , Label para apresentar no gráfico
@param  nValor    , numerico   , Número de lotes retornado da consulta
@param  aSemaforo , array      , Array com os números do semáforo
@return Nil
/*/
Static Function montaGraf(oJsonRet,cLabel,nValor,aSemaforo)
    Local cValorFim  := ""
    Local cValSemaf1 := aSemaforo[1]
    Local cValSemaf2 := aSemaforo[2]
    Local nValorFim  := 0
    Local nValSemaf1 := Val(cValSemaf1)
    Local nValSemaf2 := Val(cValSemaf2)
    Local oGauge     := PCPMonitorGauge():New()

	If nValor > nValSemaf2
		nValorFim := nValor + (nValSemaf2 - nValSemaf1)
	Else
		nValorFim := nValSemaf2 + (nValSemaf2 - nValSemaf1)
	EndIf
	cValorFim := cValToChar(nValorFim)

	//Propriedades que devem ser retornadas para monitores do tipo gráfico
	oJsonRet["corTitulo"]          := "black"
	oJsonRet["alturaMinimaWidget"] := "350px"
	oJsonRet["alturaMaximaWidget"] := "550px"
	oJsonRet["series"]             := {}
	oJsonRet["categorias"]         := {}

	//Especifica as propriedades do gráfico tipo velocímetro
	oGauge:SetMaxValue(nValorFim)
	oGauge:SetValue(nValor)
	oGauge:SetValueStyle("color",IIF(nValor < nValSemaf1,"rgb(245,0,49)",IIF(nValor < nValSemaf2,"rgb(255,240,10)","rgb(38,186,65)")))
	oGauge:SetValueStyle("font-weight","bold")
	oGauge:SetLabel(cLabel)
	oGauge:SetLabelStyle("font-weight","bold")
	oGauge:SetThreshold("0","rgb(245,0,49)")
	oGauge:SetThreshold(cValSemaf1,"rgb(255,240,10)")
	oGauge:SetThreshold(cValSemaf2,"rgb(38,186,65)")
	If Val(cValSemaf1) > 0
		oGauge:SetMarker("0")
	Endif
	oGauge:SetMarker(cValSemaf1)
	oGauge:SetMarker(cValSemaf2)
	oGauge:SetMarker(cValorFim)

	//Atribui o objeto json do velocímetro ao objeto json de retorno do método
	oJsonRet["gauge"] := oGauge:GetJsonObject()
	FreeObj(oGauge)

Return
