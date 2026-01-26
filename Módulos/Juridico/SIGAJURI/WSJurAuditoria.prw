#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "WSJURAUDITORIA.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WSJurAuditoria
Métodos WS REST do Jurídico para Marcas de Auditoria.

@since 08/01/2024
/*/
//-------------------------------------------------------------------
WSRESTFUL JURAUDITORIA DESCRIPTION STR0001 //"Métodos WS REST do Jurídico para Marcas de Auditoria"

WSDATA filMarca  AS String
WSDATA codMarca  AS String
WSDATA codGstRel AS String
WSDATA dtMarca   AS String
WSDATA dtInicial AS String
WSDATA dtFinal   AS String
WSDATA pageSize  AS Number
WSDATA page      AS Number

    WSMETHOD GET getMarcaPedidos   DESCRIPTION STR0002 PATH "getMarcaPedidos/{filMarca}/{dtMarca}" PRODUCES APPLICATION_JSON //Busca marca de auditoria
    WSMETHOD GET getListaMarcas    DESCRIPTION STR0015 PATH "getListaMarcas"                       PRODUCES APPLICATION_JSON //Busca a lista de marcas processadas
	WSMETHOD GET GstRelatorio      DESCRIPTION STR0016 PATH "gestao-relatorio/{codMarca}"          PRODUCES APPLICATION_JSON //Retorna código de gestão de relatório

    WSMETHOD POST Processos       DESCRIPTION STR0003 PATH "postMarcaProcessos"                    PRODUCES APPLICATION_JSON //Processa os Processos de Marcas de Auditoria
    WSMETHOD POST Objetos         DESCRIPTION STR0004 PATH "postMarcaObjetos"                      PRODUCES APPLICATION_JSON //Processa os Objetos de Marcas de Auditoria
    WSMETHOD POST Garantias       DESCRIPTION STR0005 PATH "postMarcaGarantias"                    PRODUCES APPLICATION_JSON //Processa as Garantias de Marcas de Auditoria
    WSMETHOD POST Despesas        DESCRIPTION STR0006 PATH "postMarcaDespesas"                     PRODUCES APPLICATION_JSON //Processa as Despesas de Marcas de Auditoria
	WSMETHOD POST Pedidos         DESCRIPTION STR0007 PATH "postMarcaPedidos"                      PRODUCES APPLICATION_JSON //Processa os Pedidos de Marcas de Auditoria

	// Processamento via Segundo Plano
	WSMETHOD POST ProcGstRel      DESCRIPTION STR0017 PATH "marca/processa/segundo-plano"          PRODUCES APPLICATION_JSON //Processa a Marca por Gestão de Relatório
	WSMETHOD PUT  CanGstRel       DESCRIPTION STR0018 PATH "gestao-relatorio/cancela/{codGstRel}"  PRODUCES APPLICATION_JSON //Cancela o processamento da Marca por Gestão de Relatório
END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} GET getMarcaPedidos
Busca os dados da Marca de Auditoria de Pedidos

@param filMarca  - Filial da Marca
@param dtMarca   - Código da marca

@example GET -> http://localhost:12173/rest/JURAUDITORIA/getMarcaPedidos/{filMarca}/{dtMarca}
/*/
//-------------------------------------------------------------------
WSMETHOD GET getMarcaPedidos PATHPARAM filMarca, dtMarca WSREST JURAUDITORIA

Local lRet       := .T.
Local cFilMarca  := DECODE64(Self:filMarca)
Local cDtMarca   := Self:dtMarca
Local oResponse  := Nil

Default cFilMarca := ""

	Self:SetContentType("application/json")

	If !Empty(cDtMarca)
		oResponse := getDadosMarcaPedidos(cFilMarca, cDtMarca)

		Self:SetResponse(oResponse:toJson())
		oResponse:fromJson("{}")
		oResponse := NIL
	Else
		lRet := .F.
		JRestError(400, STR0008) //Código da marca inválido ou em branco
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} getDadosMarcaPedidos
Retorna os dados da Marca de Auditoria de Pedidos

@param cFilMarca  - Filial da Marca
@param cDtMarca   - Código da marca

@return - json contendo o objeto dos dados
/*/
//-------------------------------------------------------------------
Static Function getDadosMarcaPedidos( cFilMarca, cDtMarca )
Local oResponse := JsonObject():New()
Local cAlias    := GetNextAlias()
Local cQuery    := ""
Local aParams   := {}

Default cFilMarca := ""

	oResponse["marcaPedidos"] := JsonObject():New()

	oResponse["marcaPedidos"]["vlrPedido"]       := 0
	oResponse["marcaPedidos"]["vlrAtuPed"]       := 0
	oResponse["marcaPedidos"]["vlrProvisao"]     := 0
	oResponse["marcaPedidos"]["vlrProvisaoAtu"]  := 0
	oResponse["marcaPedidos"]["vlrPossivel"]     := 0
	oResponse["marcaPedidos"]["vlrPossivelAtu"]  := 0
	oResponse["marcaPedidos"]["vlrRemoto"]       := 0
	oResponse["marcaPedidos"]["vlrRemotoAtu"]    := 0
	oResponse["marcaPedidos"]["vlrIncontro"]     := 0
	oResponse["marcaPedidos"]["vltInconAtu"]     := 0
	oResponse["marcaPedidos"]["vlrRedutor"]      := 0
	oResponse["marcaPedidos"]["vlrHistPossivel"] := 0
	oResponse["marcaPedidos"]["vlrHistRemoto"]   := 0

	cQuery += "SELECT SUM(O0Y.O0Y_VPEDID) O0Y_VPEDID"
	cQuery +=      " ,SUM(O0Y.O0Y_VATPED) O0Y_VATPED"
	cQuery +=      " ,SUM(O0Y.O0Y_VPROVA) O0Y_VPROVA"
	cQuery +=      " ,SUM(O0Y.O0Y_VATPRO) O0Y_VATPRO"
	cQuery +=      " ,SUM(O0Y.O0Y_VPOSSI) O0Y_VPOSSI"
	cQuery +=      " ,SUM(O0Y.O0Y_VATPOS) O0Y_VATPOS"
	cQuery +=      " ,SUM(O0Y.O0Y_VREMOT) O0Y_VREMOT"
	cQuery +=      " ,SUM(O0Y.O0Y_VATREM) O0Y_VATREM"
	cQuery +=      " ,SUM(O0Y.O0Y_VINCON) O0Y_VINCON"
	cQuery +=      " ,SUM(O0Y.O0Y_VATINC) O0Y_VATINC"

	DbSelectArea("O0Y")
	If ColumnPos("O0Y_VLREDU") > 0
		cQuery +=  " ,SUM(O0Y.O0Y_VLREDU) O0Y_VLREDU"
		cQuery +=  " ,SUM(O0Y.O0Y_VRDPOS) O0Y_VRDPOS"
		cQuery +=  " ,SUM(O0Y.O0Y_VRDREM) O0Y_VRDREM"
	EndIf

	cQuery +=  " FROM " + RetSqlName("O0Y") + " O0Y"
	cQuery += " WHERE O0Y.D_E_L_E_T_ = ' '"
	cQuery +=   " AND O0Y.O0Y_FILIAL = ?"
	cQuery +=   " AND O0Y.O0Y_MARCA = ?"

	aAdd( aParams, cFilMarca )
	aAdd( aParams, cDtMarca  )

	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., 'TOPCONN', TCGenQry2( NIL, NIL, cQuery, aParams),cAlias, .F., .T. )

	While ( cAlias )->( !EoF() )

		oResponse["marcaPedidos"]["vlrPedido"]       := (cAlias)->O0Y_VPEDID
		oResponse["marcaPedidos"]["vlrAtuPed"]       := (cAlias)->O0Y_VATPED
		oResponse["marcaPedidos"]["vlrProvisao"]     := (cAlias)->O0Y_VPROVA
		oResponse["marcaPedidos"]["vlrProvisaoAtu"]  := (cAlias)->O0Y_VATPRO
		oResponse["marcaPedidos"]["vlrPossivel"]     := (cAlias)->O0Y_VPOSSI
		oResponse["marcaPedidos"]["vlrPossivelAtu"]  := (cAlias)->O0Y_VATPOS
		oResponse["marcaPedidos"]["vlrRemoto"]       := (cAlias)->O0Y_VREMOT
		oResponse["marcaPedidos"]["vlrRemotoAtu"]    := (cAlias)->O0Y_VATREM
		oResponse["marcaPedidos"]["vlrIncontro"]     := (cAlias)->O0Y_VINCON
		oResponse["marcaPedidos"]["vltInconAtu"]     := (cAlias)->O0Y_VATINC
		If ColumnPos("O0Y_VLREDU") > 0
			oResponse["marcaPedidos"]["vlrRedutor"]      := (cAlias)->O0Y_VLREDU
			oResponse["marcaPedidos"]["vlrHistPossivel"] := (cAlias)->O0Y_VRDPOS
			oResponse["marcaPedidos"]["vlrHistRemoto"]   := (cAlias)->O0Y_VRDREM
		EndIf
		(cAlias)->(DbSkip())
	EndDo

	(cAlias)->( DbCloseArea() )
	aSize(aParams, 0)

Return oResponse

//-------------------------------------------------------------------
/*/{Protheus.doc} GET getListaMarcas
Busca a lista de Marcas de Auditorias pela quantidade

@param pageSize  - Quantidade filtrada
@param page      - Número da página

@example GET -> http://localhost:12173/rest/JURAUDITORIA/getListaMarcas?pageSize=10&page=1
/*/
//-------------------------------------------------------------------
WSMETHOD GET getListaMarcas QUERYPARAM pageSize, page WSREST JURAUDITORIA

Local lRet            := .T.
Local oResponse       := Nil

Default Self:pageSize := 10
Default Self:page     := 1

	If VALTYPE(Self:page) == "C"
		Self:page := VAL(Self:page)
	EndIf

	If VALTYPE(Self:pageSize) == "C"
		Self:pageSize := VAL(Self:pageSize)
	EndIf

	Self:SetContentType("application/json")

	oResponse := getDadosListaMarcas(Self:pageSize, Self:page)

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} getDadosListaMarcas
Retorna os dados da lista de Marcas de Auditoria

@param nPageSize  - Quantidade filtrada
@param nPage      - Número da página

@return - json contendo a lista de objeto dos dados
/*/
//-------------------------------------------------------------------
Static Function getDadosListaMarcas(nPageSize, nPage)
Local oQuery      := Nil
Local oResponse   := JsonObject():New()
Local cTpDtBase   := AllTrim(Upper(TCGetDB())) // Tipo de database do sistema
Local cAnoMes     := AnoMes(MonthSub(Date(), 6))
Local cAlias      := GetNextAlias()

Local cQuery      := ""
Local nRegMin     := 0
Local nRegMax     := 0
Local nNumReg     := 1
Local nIndex      := 0

Default nPageSize := 10
Default nPage     := 1

	oResponse["marcas"] := {}
	cQuery :=   " SELECT O0E.O0E_FILIAL,"
	cQuery +=          " O0E.O0E_MARCA,"
	cQuery +=          " O0E.O0E_DESC,"
	cQuery +=          " COALESCE( SUM(O0Y_VPEDID), 0 ) O0Y_VPEDID,"
	cQuery +=          " COALESCE( SUM(O0Y_VATPED), 0 ) O0Y_VATPED,"
	cQuery +=          " COALESCE( SUM(O0Y_VPROVA), 0 ) O0Y_VPROVA,"
	cQuery +=          " COALESCE( SUM(O0Y_VATPRO), 0 ) O0Y_VATPRO,"
	cQuery +=          " COALESCE( SUM(O0Y_VPOSSI), 0 ) O0Y_VPOSSI,"
	cQuery +=          " COALESCE( SUM(O0Y_VATPOS), 0 ) O0Y_VATPOS,"
	cQuery +=          " COALESCE( SUM(O0Y_VREMOT), 0 ) O0Y_VREMOT,"
	cQuery +=          " COALESCE( SUM(O0Y_VATREM), 0 ) O0Y_VATREM"
	cQuery +=     " FROM " + RetSQLName("O0E") + " O0E"
	cQuery +=          " INNER JOIN " + RetSQLName("O0Y") + " O0Y"
	cQuery +=             " ON O0Y.O0Y_FILIAL = O0E.O0E_FILIAL"
	cQuery +=            " AND O0Y.O0Y_MARCA = O0E.O0E_MARCA"
	cQuery +=            " AND O0Y.D_E_L_E_T_ = ' '"
	cQuery +=   " WHERE O0E.D_E_L_E_T_ = ' '"

	If cTpDtBase $ "POSTGRES|ORACLE"
		cQuery +=  " AND SUBSTR(O0E.O0E_MARCA,1,6) >= ?"
	Else
		cQuery +=  " AND SUBSTRING(O0E.O0E_MARCA,1,6) >= ?"
	EndIf

	cQuery += " GROUP BY O0E.O0E_FILIAL, O0E.O0E_MARCA, O0E.O0E_DESC"
	cQuery += " ORDER BY O0E.O0E_MARCA DESC"

	cQuery := ChangeQuery(cQuery)
	oQuery := FWPreparedStatement():New(cQuery)

	oQuery:SetString(1, cAnoMes)
	MPSysOpenQuery(oQuery:GetFixQuery(), cAlias)

	// Paginação dos registros
	nRegMax := nPageSize * nPage
	nRegMin := nPage-1 * nPageSize
	nNumReg := 1
	nIndex  := 0

	While (cAlias)->(!EoF()) .AND. nNumReg > nRegMin .And. nNumReg <= nRegMax
		nNumReg++
		nIndex++

		aAdd(oResponse["marcas"], JSonObject():New())
		oResponse["marcas"][nIndex]["filial"]          := (cAlias)->O0E_FILIAL
		oResponse["marcas"][nIndex]["marca"]           := (cAlias)->O0E_MARCA
		oResponse["marcas"][nIndex]["descricao"]       := JConvUTF8((cAlias)->O0E_DESC)
		oResponse["marcas"][nIndex]["vlrPedido"]       := (cAlias)->O0Y_VPEDID
		oResponse["marcas"][nIndex]["vlrPedidoAtu"]    := (cAlias)->O0Y_VATPED
		oResponse["marcas"][nIndex]["vlrProvavel"]     := (cAlias)->O0Y_VPROVA
		oResponse["marcas"][nIndex]["vlrProvavelAtu"]  := (cAlias)->O0Y_VATPRO
		oResponse["marcas"][nIndex]["vlrPossivel"]     := (cAlias)->O0Y_VPOSSI
		oResponse["marcas"][nIndex]["vlrPossivelAtu"]  := (cAlias)->O0Y_VATPOS
		oResponse["marcas"][nIndex]["vlrRemoto"]       := (cAlias)->O0Y_VREMOT
		oResponse["marcas"][nIndex]["vlrRemotoAtu"]    := (cAlias)->O0Y_VATREM

		(cAlias)->(DbSkip())
	EndDo

	oQuery := Nil
	(cAlias)->( DbCloseArea() )

	oResponse['total'] := Len(oResponse["marcas"])

Return oResponse

//-------------------------------------------------------------------
/*/{Protheus.doc} Processos
Processa os dados da Marca de Auditoria de Processos

Exemplo do @Body: 	{
						"filPro": "        ",
						"dtMarca": "20231231",
						"codInternos": "267,270,271",
						"dtInicial":"20231201",
						"dtFinal":"20231231"
					}

@return - json contendo um objeto com a query e quantidade de processos e uma mensagem
@example POST -> http://localhost:12173/rest/JURAUDITORIA/postMarcaProcessos
/*/
//-------------------------------------------------------------------
WSMETHOD POST Processos WSREST JURAUDITORIA
Local lRet      := .T.
Local nRet      := 0
Local cMsgErro  := ""
Local cQuery    := ""
Local cBody     := Self:GetContent()
Local oRequest  := JsonObject():New()
Local oResponse := JsonObject():New()

	If !Empty(cBody)
		oRequest:fromJson(cBody)
	EndIf

	lRet := JExcMarca( oRequest )

	If lRet
		nRet := J112AProc(@cQuery,,oRequest,@cMsgErro) //Gera auditoria de Processos

		If nRet > 0
			oResponse['queryProc'] := "SELECT NSZ_FILIAL, NSZ_COD " + cQuery
			oResponse['qtde']      := nRet
			oResponse['message']   := STR0010 //"Auditoria de Processos gerada com sucesso"

			Self:SetResponse(oResponse:toJson())
			oResponse:fromJson("{}")
			oResponse := NIL

		ElseIf nRet == 0
			oResponse['qtde']    := nRet
			oResponse['message'] := JurEncUTF8(STR0009) //"Não há registros para processar"

			Self:SetResponse(oResponse:toJson())
			oResponse:fromJson("{}")
			oResponse := NIL
		Else
			lRet := JRestError(400, cMsgErro)
		EndIf
	Else
		lRet := JRestError(400, cMsgErro)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Objetos
Processa os dados da Marca de Auditoria de Objetos

Exemplo do @Body: 	{
						"queryProc": "SELECT NSZ_FILIAL, NSZ_COD  FROM NSZ990 NSZ WHERE ( 
										( NSZ_SITUAC = '1' AND NSZ_DTINCL <= '20231231' ) OR 
										( NSZ_SITUAC = '2' AND NSZ_DTENCE BETWEEN '20231201' AND '20231231') 
										) AND  NSZ.D_E_L_E_T_ = ' '"
						"filPro": "        ",
						"dtMarca": "20231231",
						"codInternos": "267,270,271",
						"dtInicial":"20231201",
						"dtFinal":"20231231"
					}

@return - json contendo um objeto com a quantidade de registros e uma mensagem
@example POST -> http://localhost:12173/rest/JURAUDITORIA/postMarcaObjetos
/*/
//-------------------------------------------------------------------
WSMETHOD POST Objetos WSREST JURAUDITORIA
Local lRet      := .T.
Local nRet      := 0
Local cMsgErro  := ""
Local cQuery    := ""
Local cBody     := Self:GetContent()
Local oRequest  := JsonObject():New()
Local oResponse := JsonObject():New()

	If !Empty(cBody)
		oRequest:fromJson(cBody)
	EndIf

	cQuery := oRequest['queryProc']
	nRet := J112AObj(cQuery,,oRequest,@cMsgErro) //Gerando auditoria de Objetos

	If nRet > 0 .And. Empty(cMsgErro)
		oResponse['qtde']    := nRet
		oResponse['message'] := STR0011 //"Auditoria de Objetos gerada com sucesso"

		Self:SetResponse(oResponse:toJson())
		oResponse:fromJson("{}")
		oResponse := NIL

	ElseIf nRet == 0
		oResponse['qtde']    := nRet
		oResponse['message'] := JurEncUTF8(STR0009) //"Não há registros para processar"

		Self:SetResponse(oResponse:toJson())
		oResponse:fromJson("{}")
		oResponse := NIL
	Else
		lRet := JRestError(400, cMsgErro)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Garantias
Processa os dados da Marca de Auditoria de Garantias

Exemplo do @Body: 	{
						"queryProc": "SELECT NSZ_FILIAL, NSZ_COD  FROM NSZ990 NSZ WHERE ( 
										( NSZ_SITUAC = '1' AND NSZ_DTINCL <= '20231231' ) OR 
										( NSZ_SITUAC = '2' AND NSZ_DTENCE BETWEEN '20231201' AND '20231231') 
										) AND  NSZ.D_E_L_E_T_ = ' '"
						"filPro": "        ",
						"dtMarca": "20231231",
						"codInternos": "267,270,271",
						"dtInicial":"20231201",
						"dtFinal":"20231231"
					}

@return - json contendo um objeto com a quantidade de registros e uma mensagem
@example POST -> http://localhost:12173/rest/JURAUDITORIA/postMarcaGarantias
/*/
//-------------------------------------------------------------------
WSMETHOD POST Garantias WSREST JURAUDITORIA
Local lRet      := .T.
Local nRet      := 0
Local cMsgErro  := ""
Local cQuery    := ""
Local cBody     := Self:GetContent()
Local oRequest  := JsonObject():New()
Local oResponse := JsonObject():New()

	If !Empty(cBody)
		oRequest:fromJson(cBody)
	EndIf

	cQuery := oRequest['queryProc']
	nRet := J112AGar(cQuery,,oRequest,@cMsgErro) //Gerando auditoria de Garantias

	If nRet > 0
		oResponse['qtde']    := nRet
		oResponse['message'] := STR0012 //"Auditoria de Garantias gerada com sucesso"

		Self:SetResponse(oResponse:toJson())
		oResponse:fromJson("{}")
		oResponse := NIL
	ElseIf nRet == 0
		oResponse['qtde']    := nRet
		oResponse['message'] := JurEncUTF8(STR0009) //"Não há registros para processar"

		Self:SetResponse(oResponse:toJson())
		oResponse:fromJson("{}")
		oResponse := NIL
	Else
		lRet := JRestError(400, cMsgErro)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Despesas
Processa os dados da Marca de Auditoria de Despesas

Exemplo do @Body: 	{
						"queryProc": "SELECT NSZ_FILIAL, NSZ_COD  FROM NSZ990 NSZ WHERE ( 
										( NSZ_SITUAC = '1' AND NSZ_DTINCL <= '20231231' ) OR 
										( NSZ_SITUAC = '2' AND NSZ_DTENCE BETWEEN '20231201' AND '20231231') 
										) AND  NSZ.D_E_L_E_T_ = ' '"
						"filPro": "        ",
						"dtMarca": "20231231",
						"codInternos": "267,270,271",
						"dtInicial":"20231201",
						"dtFinal":"20231231"
					}

@return - json contendo um objeto com a quantidade de registros e uma mensagem
@example POST -> http://localhost:12173/rest/JURAUDITORIA/postMarcaDespesas
/*/
//-------------------------------------------------------------------
WSMETHOD POST Despesas WSREST JURAUDITORIA
Local lRet      := .T.
Local nRet      := 0
Local cMsgErro  := ""
Local cQuery    := ""
Local cBody     := Self:GetContent()
Local oRequest  := JsonObject():New()
Local oResponse := JsonObject():New()

	If !Empty(cBody)
		oRequest:fromJson(cBody)
	EndIf

	cQuery := oRequest['queryProc']
	nRet := J112ADesp(cQuery,,oRequest,@cMsgErro) //Gerando auditoria de Despesas

	If nRet > 0
		oResponse['qtde']    := nRet
		oResponse['message'] := STR0013 //"Auditoria de Despesas gerada com sucesso"

		Self:SetResponse(oResponse:toJson())
		oResponse:fromJson("{}")
		oResponse := NIL
	ElseIf nRet == 0
		oResponse['qtde']    := nRet
		oResponse['message'] := JurEncUTF8(STR0009) //"Não há registros para processar"

		Self:SetResponse(oResponse:toJson())
		oResponse:fromJson("{}")
		oResponse := NIL
	Else
		lRet := JRestError(400, cMsgErro)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Pedidos
Processa os dados da Marca de Auditoria de Pedidos

Exemplo do @Body: 	{
						"queryProc": "SELECT NSZ_FILIAL, NSZ_COD  FROM NSZ990 NSZ WHERE ( 
										( NSZ_SITUAC = '1' AND NSZ_DTINCL <= '20231231' ) OR 
										( NSZ_SITUAC = '2' AND NSZ_DTENCE BETWEEN '20231201' AND '20231231') 
										) AND  NSZ.D_E_L_E_T_ = ' '"
						"filPro": "        ",
						"dtMarca": "20231231",
						"codInternos": "267,270,271",
						"dtInicial":"20231201",
						"dtFinal":"20231231"
					}

@return - json contendo um objeto com a quantidade de registros e uma mensagem
@example POST -> http://localhost:12173/rest/JURAUDITORIA/postMarcaPedidos
/*/
//-------------------------------------------------------------------
WSMETHOD POST Pedidos WSREST JURAUDITORIA
Local lRet      := .T.
Local nRet      := 0
Local cMsgErro  := ""
Local cQuery    := ""
Local cBody     := Self:GetContent()
Local oRequest  := JsonObject():New()
Local oResponse := JsonObject():New()

	If !Empty(cBody)
		oRequest:fromJson(cBody)
	EndIf

	cQuery := oRequest['queryProc']
	nRet := J112APed(cQuery,,oRequest,@cMsgErro) //Gerando auditoria de Pedidos

	If nRet > 0 .And. Empty(cMsgErro)
		oResponse['qtde']    := nRet
		oResponse['message'] := STR0014 //"Auditoria de Pedidos gerada com sucesso"

		Self:SetResponse(oResponse:toJson())
		oResponse:fromJson("{}")
		oResponse := NIL
	ElseIf nRet == 0
		oResponse['qtde']    := nRet
		oResponse['message'] := JurEncUTF8(STR0009) //"Não há registros para processar"

		Self:SetResponse(oResponse:toJson())
		oResponse:fromJson("{}")
		oResponse := NIL
	Else
		lRet := JRestError(400, cMsgErro)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcGstRel
Processa os dados da Marca de Auditoria de Pedidos

Exemplo do @Body: 	{
						"filPro": "        ",
						"dtMarca": "20231231",
						"codInternos": "267,270,271",
						"dtInicial":"20231201",
						"dtFinal":"20231231",
						"idMarca": ""
					}

@return - json contendo um objeto com a quantidade de registros e uma mensagem
@example POST -> http://localhost:12173/rest/JURAUDITORIA/postMarcaPedidos
/*/
//-------------------------------------------------------------------
WSMETHOD POST ProcGstRel WSREST JURAUDITORIA
Local lRet      := .T.
Local cBody     := Self:GetContent()
Local oBody     := JSonObject():New()
Local oResponse := JSonObject():New()
Local cChave    := ""
Local lTpChave  := .F.
Local cCodMarca := ""
Local cIdMarca  := ""
Local cUserTkn  := JGetAuthTk()

	DbSelectArea("O17")
	lTpChave := O17->(FieldPos("O17_TIPO")) > 0 .And. O17->(FieldPos("O17_CHAVE")) > 0

	oBody:FromJSon(cBody)

	cIdMarca  := oBody['idMarca']
	If Empty(cIdMarca)
		cCodMarca := Encode64(xFilial("O0E") + oBody['dtMarca'])
		cChave    := "Marca:[" + cCodMarca + "]"
	Else
		cChave    := cIdMarca
	EndIf

	If (J288InProc(cChave))
		oResponse['operation'] := "Error"
		oResponse['message']   := JurEncUTF8(STR0019) // "Já existe um processamento em andamento para a Marca de Auditoria."
		lRet := JRestError(400, oResponse['message'])
	Else
		oGstRel := J288JsonRel()
		oGstRel['O17_FILE']   := cChave
		oGstRel['O17_URLREQ'] := Substr(Self:GetPath(), At('JURAUDITORIA',Self:GetPath()))
		oGstRel['O17_BODY']   := oBody:toJson() // cBody

		If (lTpChave)
			oGstRel['O17_TIPO']  := "2"
			oGstRel['O17_CHAVE'] := cCodMarca
		EndIf

		J288GestRel(oGstRel)
		STARTJOB("JWSAudPrcM", GetEnvServer(), .F.,;
		         oBody, oGstRel, cEmpAnt, cFilAnt, cUserTkn )

		oResponse['operation'] := "Notification"
		oResponse['message']   := JurEncUTF8(STR0020 + ; // "O processamento da Marca foi iniciado em segundo plano."
								             STR0021   ) // " Você poderá acompanhar o andamento do processamento por dentro da marca, no final da pagina."
		oResponse['codigo']    := EncodeUTF8(oGstRel['O17_FILIAL'] + oGstRel['O17_CODIGO'])

		Self:SetResponse(oResponse:toJson())
	EndIf
	oResponse:fromJson("{}")
	oResponse := NIL
Return lRet

//-------------------------------------------------------------------------
/*/{Protheus.doc} JWSAudPrcM(oBody)
Processa os dados da Marca de Auditoria

@param oBody    - Objeto com os dados de Processamento de Marca de Auditoria
@param oGstRel  - Objeto com os dados de Gestão de Relatório
@param cEmpLog  - Empresa de Log
@param cFilLog  - Filial de Log
@param cUsuario - Usuário que está processando a Marca de Auditoria

@since 27/07/2020
/*/
//-------------------------------------------------------------------------
Function JWSAudPrcM(oBody, oGstRel, cEmpLog, cFilLog, cUsuario)
Local nRet       := 0
Local cQuery     := ""
Local lContinue  := .F.
Local cMsgErro   := ""
Default oGstRel  := Nil

	RPCSetType(3) // Prepara o ambiente e não consome licença
	RPCSetEnv(cEmpLog, cFilLog, , , 'JWSAudPrcM') // Abre o ambiente

	// Valida se o usuário informado é válido
	JHasUserTk(cUsuario)
	
	oBody['cIdThredExec'] := "JWSAudPrcM" + __cUserId + StrZero(Randomize(1,9999),4)

	oGstRel['O17_DESC'] := STR0022 // "Iniciado o processamento da Marca de Auditoria."
	oGstRel['O17_BODY'] := oBody:toJson() // cBody
	J288GestRel(oGstRel)

	// Trava a execução atual
	If LockByName(oBody["cIdThredExec"], .T., .T.)
		J288GestRel(oGstRel)
		lContinue := JExcMarca(oBody)
		If (lContinue)
			If nRet > -1
				oGstRel['O17_DESC'] := STR0023 // "Processando os assuntos jurídicos."
				J288GestRel(oGstRel)
				// Gera auditoria de Processos
				nRet := J112AProc( @cQuery, , oBody, @cMsgErro, @oGstRel ) 
				
				cQuery := "SELECT NSZ_FILIAL, NSZ_COD " + cQuery
			EndIf

			If nRet > -1
				oGstRel['O17_DESC'] := STR0024 // "Processando as garantias dos processos."
				J288GestRel(oGstRel)
				// Gerando auditoria de Garantias
				nRet := J112AGar(   cQuery, , oBody, @cMsgErro, @oGstRel ) 
			EndIf

			If nRet > -1
				oGstRel['O17_DESC'] := STR0025 // "Processando as despesas dos processos."
				J288GestRel(oGstRel)
				// Gerando auditoria de Despesas
				nRet := J112ADesp(  cQuery, , oBody, @cMsgErro, @oGstRel ) 
			EndIf

			If nRet > -1
				oGstRel['O17_DESC'] := STR0026 // "Processando os objetos dos processos."
				J288GestRel(oGstRel)
				// Gerando auditoria de Objetos
				nRet := J112AObj(   cQuery, , oBody, @cMsgErro, @oGstRel ) 
			EndIf

			If nRet > -1
				oGstRel['O17_DESC'] := STR0027 // "Processando os pedidos dos processos."
				J288GestRel(oGstRel)
				// Gerando auditoria de Pedidos
				nRet := J112APed(   cQuery, , oBody, @cMsgErro, @oGstRel ) 
			EndIf
		EndIf

		oGstRel['O17_STATUS'] := "2"
		oGstRel['O17_DESC']   := STR0028 // "Processamento da Marca de Auditoria finalizado."
		
		J288GestRel(oGstRel)
		UnLockByName(oBody["cIdThredExec"], .T., .T.)
		RpcClearEnv() // Reseta o ambiente
	EndIf
Return Nil

//-----------------------------------------------------------------
/*/{Protheus.doc} JExcMarca(oBody )
Processa os dados da Marca de Auditoria

@param oBody - Objeto com os dados de Processamento de Marca de Auditoria
@since 27/07/2020
/*/
//-----------------------------------------------------------------
Static Function JExcMarca( oBody )
Local lRet     := .F.
Local cMsgErro := ""
Local aMvPars  := {}

	aAdd(aMvPars, StoD(oBody['dtMarca'])) //Marca
	aAdd(aMvPars, oBody['filPro']       ) //Filial
	aAdd(aMvPars, ""                    )
	aAdd(aMvPars, oBody['codInternos']  )   //Cajuris

	lRet := J112AExMar(aMvPars,@cMsgErro)
Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} JWSUpdGstRel( oGstRel )
Processa os dados da Marca de Auditoria

@param oBody - Objeto com os dados de Processamento de Marca de Auditoria
@since 27/07/2020
/*/
//-----------------------------------------------------------------
Function JWSUpdGstRel(oGstRel)
	If (oGstRel != Nil)
		oGstRel['O17_MIN']++
		oGstRel['O17_PERC'] := J288CalcPerc(oGstRel['O17_MIN'], oGstRel['O17_MAX'])
		J288GestRel(oGstRel)
	EndIf
Return

//-----------------------------------------------------------------
/*/{Prothes.doc} GET GstRelatorio
 Retorna código de gestão de relatório

@param codMarca - código da PK da marca
@since 09/05/2024 
/*/
//-----------------------------------------------------------------
WSMETHOD GET GstRelatorio PATHPARAM codMarca WSREST JURAUDITORIA
Local lRet       := .T.
Local cCodMarca  := Self:codMarca
Local cAlias     := GetNextAlias()
Local cQuery     := ""
local aParams    := {}
Local oQuery     := Nil
Local oResponse  := JsonObject():New()
Local lTpChave   := .F.

Default cCodMarca = ""

	If !Empty(cCodMarca) 
		DbSelectArea('O17')
		lTpChave := O17->(FieldPos("O17_TIPO")) > 0 .And. O17->(FieldPos("O17_CHAVE")) > 0 

		cQuery := " SELECT O17_FILIAL, O17_CODIGO, O17_STATUS"
		cQuery += " FROM " + RetSqlName("O17")
		cQuery += " WHERE D_E_L_E_T_ = ' '"
		cQuery +=   " AND O17_STATUS = '0'"

		If (lTpChave)
			cQuery +=   " AND O17_TIPO = '2'"
			cQuery +=   " AND O17_CHAVE = ?"
			Aadd(aParams,{ "C", Self:codMarca })
		Else
			cQuery +=   " AND O17_FILE = ?"
			Aadd(aParams,{ "C", "Marca:[" + Self:codMarca + "]" })
		EndIf		

		oQuery   := FWPreparedStatement():New(cQuery)
		oQuery   := JQueryPSPr(oQuery, aParams)
		cQuery   := oQuery:GetFixQuery()
		MpSysOpenQuery(cQuery,cAlias)

		While (cAlias)->(!EoF())
			oResponse['codigoRelatorio'] := Encode64((cAlias)->O17_FILIAL + (cAlias)->O17_CODIGO)
			oResponse['status']          := (cAlias)->O17_STATUS
			(cAlias)->( dbSkip() )
		EndDo

		(cAlias)->( DbCloseArea() )
		aSize(aParams, 0)
		aParams   := Nil

		Self:SetResponse(oResponse:toJson())
		oResponse:fromJson("{}")
		oResponse := Nil
	Else
		lRet := .F.
		JRestError(400, STR0008) //Código da marca inválido ou em branco
  	EndIf  
Return lRet

//-----------------------------------------------------------------
/*/{Prothes.doc} PUT CanGstRel
Altera o Status da Fila de Gestão de Relatório da Marca

@param codGstRel - código da gestão de relatório
@since 10/05/2024 
/*/
//-----------------------------------------------------------------
WSMETHOD PUT CanGstRel PATHPARAM codGstRel WSREST JURAUDITORIA
Local aArea      := GetArea()
Local lRet       := .T.
Local cCodGstRel := Decode64(Self:codGstRel)
Local oResponse  := JSonObject():New()

	DbSelectArea("O17")

	O17->( DbSetOrder(1) ) //O17_FILIAL+O17_CODIGO
	If O17->( DbSeek( cCodGstRel ) )
		O17->(RecLock("O17", .F.))
		O17->O17_STATUS := "3"
		O17->O17_DESC   := STR0031 //"Processamento cancelado pelo usuário."
		O17->(MsUnlock())

		J288ChkRel()

		oResponse['message'] := JurEncUTF8(STR0029) // "Status da Fila de Gestão de Relatório alterado com sucesso."
	Else 
		oResponse['message'] := JurEncUTF8(STR0030) // "Não foi possivel encontrar o registro na Fila de Gestão de Relatório."
		lRet := JRestError(400, oResponse['message'])
	EndIf

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := Nil
	RestArea(aArea)
Return lRet
