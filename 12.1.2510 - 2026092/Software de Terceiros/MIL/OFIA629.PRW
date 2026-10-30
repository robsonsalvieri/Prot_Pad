#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'OFIA629.CH'

/*/{Protheus.doc} OFIA629
	Atualizacao de pedidos JDPRISM

	@author Vinicius Gati
	@since 11/06/2026
	@type
/*/
Function OFIA629(aParam)
	conout("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	conout("~~~~~~~~ INICIANDO OFIA629 ~~~~~~~~~~~~~")
	conout("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")

	OA6290024_AtualizaPedidosJDPRISM()

	conout("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	conout("~~~~~~~~ FINALIZANDO OFIA629 ~~~~~~~~~~~")
	conout("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
Return

/*/{Protheus.doc} OA6290024_AtualizaPedidosJDPRISM
	Passa as filiais para adeqeuação de pedidos dependendo se usar grupos ou não
	
	@type function
	@author Vinicius Gati
	@since 12/11/2025
/*/
Function OA6290024_AtualizaPedidosJDPRISM()
	local nX         := 1
	local aFils      := {}
	local oDpmCfg    := {}
	local cFilBck    := cFilAnt
	local oRpmConfig := OFJDRpmConfig():New()
	local oLogger    := DMS_Logger():New("OA6290024.LOG")
	
	oLogger:Log({STR0001}) //"Iniciando atualização de pedidos"
	

	aGrupos := oRpmConfig:GetConfigs()

	lUsaGrps := LEN( aGrupos ) > 0
	
	if lUsaGrps
		for nX := 1 to len(aGrupos)
			oDpmCfg := aGrupos[nX]
			aFils := oDpmCfg:GetFiliais()
			oLogger:Log({STR0002 + cvaltochar(nX)}) // "Iniciando atualização de pedidos de grupo: "
			OA6290094_AdequaPedidosDaConfiguracao(aFils, oRpmConfig, oLogger)
		next
	else
		aFils := oRpmConfig:GetFiliais()
		OA6290094_AdequaPedidosDaConfiguracao(aFils, oRpmConfig, oLogger)
	endif

	cFilant := cFilBck
Return .T.

/*/{Protheus.doc} OA6290094_AdequaPedidosDaConfiguracao
	Vai trocar os pedidos que entraram via jdprism contendo - no inicio 
	e trocar pelo numero JA buscando no order status os dados
	
	@type function
	@author Vinicius Gati
	@since 12/11/2025
/*/
Function OA6290094_AdequaPedidosDaConfiguracao(aFils, oRpmConfig, oLogger, qtdErrMax)
	local nX := 1
	local nY := 1
	local cQuery := ""
	local nQuantidade := 0
	local aPedidos := {}
	local oSqlHelper := DMS_SqlHelper():New()
	local nQtdErros := 0
	default oRpmConfig := OFJDRpmConfig():New()
	default oLogger := DMS_Logger():New("OA6290094.LOG")
	default qtdErrMax := 5

	for nY := 1 to len(aFils)
		cFilant     := aFils[nY, 1]
		cDealerCode := aFils[nY, 2]

		cQuery := " SELECT C7_NUM, C7_PEDFAB "
		cQuery += "   FROM "+oSqlHelper:Nolock("SC7")
		cQuery += "   JOIN "+oSqlHelper:Nolock("VR0")+" ON VR0_FILIAL = '"+xFilial('VR0')+"' AND VR0_NUMPED = C7_NUM AND VR0.D_E_L_E_T_ = ' ' "
		cQuery += "  WHERE C7_FILIAL = '"+xFilial('SC7')+"' "
		cQuery += "    AND VR0.VR0_FILDES = '"+ALLTRIM(cDealerCode)+"' "
		cQuery += "    AND SC7.C7_PEDFAB LIKE '-%' "
		cQuery += "    AND SC7.D_E_L_E_T_ = ' ' "
		cQuery += "  GROUP BY C7_NUM, C7_PEDFAB "

		nQuantidade := oSqlHelper:Count(cQuery, "*")

		if nQuantidade > 60
			cQuery := oSqlHelper:TopFunc(cQuery, Int(nQuantidade / 20)) // 20%
		else
			cQuery := oSqlHelper:TopFunc(cQuery, 20) // 20 registros por vez
		endif

		aPedidos := oSqlHelper:GetSelect({;
			{'campos', {'C7_NUM', 'C7_PEDFAB'}},;
			{'query', cQuery} ;
		})

		oLogger:Log({"TIMESTAMP", "Filial:" + cFilant, "Dealer Code: " + cValtoChar(cDealerCode), STR0003 + cvaltochar(len(aPedidos))}) // "Quantidade de pedidos a serem atualizados : "

		for nX := 1 to len(aPedidos)
			cNrPedAnt  := cValtoChar(aPedidos[nX]:GetValue('C7_PEDFAB'))
			cC7NUM := cValtoChar(aPedidos[nX]:GetValue('C7_NUM'))
			cMsg := OA6290084_AdequaPedido(xFilial('SC7'), cC7NUM, cNrPedAnt, cDealerCode, oLogger)
			if cMsg == "ABORTA"
				nQtdErros += 1
				if nQtdErros > qtdErrMax
					oLogger:Log({STR0004 + " Ped. Jdprism:" + cNrPedAnt + " Pedido(C7_NUM) : " + cC7NUM})
					return .F.
				endif
			endif
			if cMsg == "ORDER_NOT_FOUND"
				//"Pedido não encontrado para dealer code: "
				oLogger:Log({STR0005 + cDealerCode+". Ped. Jdprism:" + cNrPedAnt + " Pedido(C7_NUM) : " + cC7NUM})
				return .F.
			endif
		next
	next

Return .T.


/*/{Protheus.doc} OA6290084_AdequaPedido
	Recebe os dados do Pedido, busca no JDPoint o numero correto e atualiza o pedido
	
	@type function
	@author Vinicius Gati
	@since 12/11/2025
/*/
Function OA6290084_AdequaPedido(cFilC7, cC7Num, cPedFabAtual, cDealerCode, oLogger, cUsrPar)
	local oWs
	local oStatement
	local cUpdate := ""
	local nStatus := 0
	local oOkta := OFJDOkta():New()
	local cToken := NIL
	default oLogger := DMS_Logger():New("OA6290084.LOG")
	default cUsrPar := __cUserID

	if oOkta:oauth2Habilitado()
		oOkta:SetOrderStatusJDPoint()
		oOkta := oOkta:GetAuth()
		cToken := oOkta:getToken()
		if empty(cToken)
			conout("OFIA629 - " + STR0014) // Token do usuário scheduler expirado, isso requer atenção, tentando coletar token avulso para continuidade.
			oAuth2 := OFOAUTH2():New()
			lAny := oAuth2:GenAnyValidToken(2, oOkta:_client_ID)
			if lAny
				jAuthData := oAuth2:GenGetNewestToken(2, oOkta:_client_ID)
				if valtype(jAuthData) != "U"
					oOkta:_RefreshToken := jAuthData["REFRESH"]
					oOkta:_getTokenRefresh()
					cToken := oOkta:getToken()
				endif
			endif
		endif
	endif

	oWS := WSJohnDeereJDPoint_1_4_Pedido_Compra():New()
	ows:cUserId := AllTrim(FM_SQL("SELECT VAI_FABUSR FROM " + RetSqlName("VAI") + " WHERE VAI_FILIAL = '" + xFilial("VAI") + "' AND VAI_CODUSR = '" + cUsrPar + "' AND D_E_L_E_T_ = ' '"))
	oWS:corderNumber   := AllTrim(strtran(cPedFabAtual, "-", "")) // remove o - do inicio que indica que falta adequar
	oWS:caccountnumber := cDealerCode
	lSucesso := oWS:retrieveOrderStatus(cToken)

	if ! lSucesso .OR. valtype(oWS:oOrderStatusReturn:cexceptionReport) == "C" .and. ! empty(alltrim(oWS:oOrderStatusReturn:cexceptionReport))
		if upper(alltrim(oWS:oOrderStatusReturn:cexceptionReport)) == "ORDER NOT FOUND"
			return "ORDER_NOT_FOUND"
		endif
		oLogger:Log({"TIMESTAMP", "Nro: " + AllTrim(strtran(cPedFabAtual, "-", "")) })
		if valtype(oWS:oOrderStatusReturn:cexceptionReport) == "C" .and. ! empty(alltrim(oWS:oOrderStatusReturn:cexceptionReport))
		oLogger:Log({ STR0007 + cValtoChar(oWS:oOrderStatusReturn:cexceptionReport) })// "Erro ao buscar pedido no OrderStatus: "
		else
			oLogger:Log({ STR0008 })// "Erro ao buscar pedido, possívelmente falta de token valido no usuário"
		endif
		return "ABORTA" // evitando de fazer N requisições que estão bloqueando ips
	Endif

	if ! empty(oWS:oOrderStatusReturn:corderNumber)
		oStatement := FWPreparedStatement():New("UPDATE " + RetSqlName("SC7") + " SET C7_PEDFAB = ? WHERE C7_FILIAL = ? AND C7_NUM = ? AND D_E_L_E_T_ = ' ' ")
		oStatement:SetString(1, alltrim(cValtoChar(oWS:oOrderStatusReturn:corderNumber)))
		oStatement:SetString(2, cFilC7)
		oStatement:SetString(3, cC7Num)
		cUpdate := oStatement:GetFixQuery()
		nStatus := TcSqlExec(cUpdate)

		if nStatus < 0
			oLogger:Log({"TIMESTAMP", STR0009 /*"Erro ao atualizar pedido JDPRISM: "*/ + cValtoChar(cPedFabAtual) + STR0012 /*" para: "*/ + cValtoChar(oWS:oOrderStatusReturn:corderNumber)  + STR0013 + TCSQLError()}) //" Erro: "
			return "ABORTA" // evitando de fazer N requisições que estão bloqueando ips
		else
			oLogger:Log({"TIMESTAMP", STR0010 + cValtoChar(cPedFabAtual) + STR0011 + cValtoChar(oWS:oOrderStatusReturn:corderNumber) })//"Pedido JDPRISM : " // " atualizado para: "
			return alltrim(cValtoChar(oWS:oOrderStatusReturn:corderNumber))
		Endif
	endif
return "ABORTA" // evitando de fazer N requisições que estão bloqueando ips

/*/{Protheus.doc} SchedDef
	Função padrão scheduler

	@author Vinicius Gati
	@since 11/06/2026
	@type
/*/
Static Function SchedDef()
	Local aParam := {;
		"P",;
		"",;
		"",;
		"",;
		"" ;
	}
Return aParam
