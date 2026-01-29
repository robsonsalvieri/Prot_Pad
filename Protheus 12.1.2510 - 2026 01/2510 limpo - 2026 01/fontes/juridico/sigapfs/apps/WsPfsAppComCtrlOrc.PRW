#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "WSPFSAPPCOMCTRLORC.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} WsPfsParticipante
Métodos WS para Integração de Compras x Controle Orçamentário

@author Guilherme Vieira
@since 30/10/2025
/*/
//-------------------------------------------------------------------
WSRESTFUL WsPfsAppComCtrlOrc DESCRIPTION STR0001 //STR0001 "Webservice Compras x Controle Orçamentário"
	WSDATA cChaveDoc   AS STRING

	WSMETHOD GET buscaDocEntr DESCRIPTION STR0005 PATH "buscaDocEntr/{cChaveDoc}" WSSYNTAX "buscaDocEntr/{cChaveDoc}" //STR0005 "Retorna o detalhe do Documento de Entrada com desdobramentos"

    WSMETHOD PUT AprvDoc DESCRIPTION STR0006 PATH "AprvDocEntr/{cChaveDoc}" WSSYNTAX "AprvDocEntr/{cChaveDoc}"// STR0006 "Retorna aprovacao do documento de entrada"

END WSRESTFUL

//-------------------------------------------------------------------
/*{Protheus.doc} GET Doc de entrada
Consulta documentos de entrada

@example GET -> http://127.0.0.1:9090/rest/WsPfsAppComCtrlOrc/buscaDocEntr/{cChaveDoc}

@param cChaveDoc - Chave codificada em Base64 contendo filial+doc+série+fornecedor+loja

@author Guilherme Vieira
@since  30/10/2025
/*/
//-------------------------------------------------------------------
WSMETHOD GET buscaDocEntr PATHPARAM cChaveDoc WSREST WsPfsAppComCtrlOrc
Local oResponse  := JSonObject():New() // Objeto de resposta JSON
Local cChvDoc    := Decode64(Self:cChaveDoc)
Local nTamFilial := TamSX3("F1_FILIAL")[1]
Local nTamDoc    := TamSX3("F1_DOC")[1]
Local nTamSerie  := TamSX3("F1_SERIE")[1]
Local nTamFornec := TamSX3("F1_FORNECE")[1]
Local nTamLoja   := TamSX3("F1_LOJA")[1]
Local cFilDoc    := Substr(cChvDoc, 1, nTamFilial)
Local cDocEnt    := Substr(cChvDoc, nTamFilial + 1, nTamDoc)
Local cSerie     := Substr(cChvDoc, nTamFilial + nTamDoc + 1, nTamSerie)
Local cFornec    := Substr(cChvDoc, nTamFilial + nTamDoc + nTamSerie + 1, nTamFornec)
Local cLoja      := Substr(cChvDoc, nTamFilial + nTamDoc + nTamSerie + nTamFornec + 1, nTamLoja)
Local aArea      := GetArea()
Local lRet       := .T.
Local aDadosDoc  := {}
Local aDadosDes  := {}
Local cAccept    := Self:GetAccept() // Captura o header Accept
Local cResponse  := ""
Local cXml       := ""
Local nI         := 0

	// Identificando o tipo do Body
	If !Empty(cAccept) .And. ValType(cAccept) == "C"
		cContent := Upper(Substr(cAccept, At("/",cAccept)+1))
	EndIf

	// Decodificar e validar chave
	If Empty(Self:cChaveDoc)
		SetRestFault(400, JConvUTF8(STR0002))  //STR0002 "Parâmetro cChaveDoc não informado"
		lRet := .F.
	EndIf

	If lRet .And. (Empty(cChvDoc) .Or. Len(cChvDoc) < (nTamFilial + nTamDoc + nTamSerie + nTamFornec + nTamLoja))
		SetRestFault(400, JConvUTF8(STR0003))  //STR0003 "Chave do documento inválida ou incompleta"
		lRet := .F.
	EndIf

	If lRet
		// Obter dados do documento (SF1)
		aDadosDoc := JGetDoc(cFilDoc, cDocEnt, cSerie, cFornec, cLoja)

		// Obter desdobramentos (OHV)
		aDadosDes := JGetDes(cFilDoc, cDocEnt, cSerie, cFornec, cLoja)

		If Len(aDadosDoc) == 0
			SetRestFault(400, JConvUTF8(STR0004)) //STR0004 "Documento não encontrado"
			lRet := .F.
		EndIf

		If lRet .And. cContent == "JSON"
			// Montar JSON do cabeçalho (DocEntrada)
			oResponse['DocEntrada'] := JSonObject():New()
			oResponse['DocEntrada']['filialDoLancamento'] := JConvUTF8(aDadosDoc[1])             // F1_FILIAL
			oResponse['DocEntrada']['numeroNotaFiscal']   := JConvUTF8(aDadosDoc[2])             // F1_DOC
			oResponse['DocEntrada']['serieNotaFiscal']    := JConvUTF8(aDadosDoc[3])             // F1_SERIE
			oResponse['DocEntrada']['codigoFornecedor']   := JConvUTF8(aDadosDoc[4])             // F1_FORNECE
			oResponse['DocEntrada']['lojaFornecedor']     := JConvUTF8(aDadosDoc[5])             // F1_LOJA
			oResponse['DocEntrada']['codMoeda']           := JConvUTF8(cValToChar(aDadosDoc[6])) // F1_MOEDA
			oResponse['DocEntrada']['cotacao']            := JConvUTF8(cValToChar(aDadosDoc[7])) // F1_TXMOEDA
			oResponse['DocEntrada']['valorBruto']         := JConvUTF8(cValToChar(aDadosDoc[8])) // F1_VALBRUT
			oResponse['DocEntrada']['valorLiq']           := JConvUTF8(cValToChar(aDadosDoc[9])) // F1_VALMERC
			oResponse['DocEntrada']['dataEmissao']        := JConvUTF8(aDadosDoc[10])            // F1_EMISSAO
			oResponse['DocEntrada']['statusNotaFiscal']   := JConvUTF8(aDadosDoc[11])            // F1_STATUS

			oResponse['DocEntrada']['desdobramentos'] := {}

			For nI := 1 To Len(aDadosDes)
				aAdd(oResponse["DocEntrada"]["desdobramentos"], JSonObject():New())
				oResponse["DocEntrada"]["desdobramentos"][nI]["valorTotalItem"]        := JConvUTF8(cValToChar(aDadosDes[nI][1]))  // OHV_TOTAL
				oResponse["DocEntrada"]["desdobramentos"][nI]["naturezaDesdobramento"] := JConvUTF8(aDadosDes[nI][2])              // OHV_CNATUR
				oResponse["DocEntrada"]["desdobramentos"][nI]["codigoSolicitante"]     := JConvUTF8(aDadosDes[nI][3])              // OHV_CPART
				oResponse["DocEntrada"]["desdobramentos"][nI]["codigoEscritorio"]      := JConvUTF8(aDadosDes[nI][4])              // OHV_CESCR
				oResponse["DocEntrada"]["desdobramentos"][nI]["centroCusto"]           := JConvUTF8(aDadosDes[nI][5])              // OHV_CCUSTO
				oResponse["DocEntrada"]["desdobramentos"][nI]["codigoParticipante"]    := JConvUTF8(aDadosDes[nI][6])              // OHV_CPART2
				oResponse["DocEntrada"]["desdobramentos"][nI]["codigoCliente"]         := JConvUTF8(aDadosDes[nI][7])              // OHV_CCLIEN
				oResponse["DocEntrada"]["desdobramentos"][nI]["lojaCliente"]           := JConvUTF8(aDadosDes[nI][8])              // OHV_CLOJA
				oResponse["DocEntrada"]["desdobramentos"][nI]["codigoCaso"]            := JConvUTF8(aDadosDes[nI][9])              // OHV_CCASO
				oResponse["DocEntrada"]["desdobramentos"][nI]["codigoTipoDespesa"]     := JConvUTF8(aDadosDes[nI][10])             // OHV_CTPDSP
				oResponse["DocEntrada"]["desdobramentos"][nI]["quantidadeDespesa"]     := JConvUTF8(cValToChar(aDadosDes[nI][11])) // OHV_QTDDSP
				oResponse["DocEntrada"]["desdobramentos"][nI]["dataDespesa"]           := JConvUTF8(aDadosDes[nI][12])             // OHV_DTDESP
				oResponse["DocEntrada"]["desdobramentos"][nI]["cobraDespesa"]          := JConvUTF8(aDadosDes[nI][13])             // OHV_COBRA
				oResponse["DocEntrada"]["desdobramentos"][nI]["codigoProjeto"]         := JConvUTF8(aDadosDes[nI][14])             // OHV_CPROJE
				oResponse["DocEntrada"]["desdobramentos"][nI]["codigoItemProjeto"]     := JConvUTF8(aDadosDes[nI][15])             // OHV_CITPRJ
				oResponse["DocEntrada"]["desdobramentos"][nI]["historico"]             := JConvUTF8(aDadosDes[nI][16])             // OHV_HISTOR
				oResponse["DocEntrada"]["desdobramentos"][nI]["dataInclusao"]          := JConvUTF8(aDadosDes[nI][17])             // OHV_DTINCL
			Next nI
		
		EndIf 

		If lRet .And. cContent == "XML"

			cXml := '<?xml version="1.0" encoding="UTF-8"?>' + CRLF
			cXml += '<DocEntrada>' + CRLF
			cXml += '  <filialDoLancamento>' + JConvUTF8(aDadosDoc[1]) + '</filialDoLancamento>' + CRLF
			cXml += '  <numeroNotaFiscal>' + JConvUTF8(aDadosDoc[2]) + '</numeroNotaFiscal>' + CRLF
			cXml += '  <serieNotaFiscal>' + JConvUTF8(aDadosDoc[3]) + '</serieNotaFiscal>' + CRLF
			cXml += '  <codigoFornecedor>' + JConvUTF8(aDadosDoc[4]) + '</codigoFornecedor>' + CRLF
			cXml += '  <lojaFornecedor>' + JConvUTF8(aDadosDoc[5]) + '</lojaFornecedor>' + CRLF
			cXml += '  <codMoeda>' + JConvUTF8(cValToChar(aDadosDoc[6])) + '</totalNotaFiscal>' + CRLF
			cXml += '  <cotacao>' + JConvUTF8(cValToChar(aDadosDoc[7])) + '</totalNotaFiscal>' + CRLF
			cXml += '  <valorBruto>' + JConvUTF8(cValToChar(aDadosDoc[8])) + '</totalNotaFiscal>' + CRLF
			cXml += '  <valorLiq>' + JConvUTF8(cValToChar(aDadosDoc[9])) + '</totalNotaFiscal>' + CRLF
			cXml += '  <dataEmissao>' + JConvUTF8(aDadosDoc[10]) + '</dataEmissao>' + CRLF
			cXml += '  <statusNotaFiscal>' + JConvUTF8(aDadosDoc[11]) + '</statusNotaFiscal>' + CRLF
			cXml += '  <desdobramentos>' + CRLF
			For nI := 1 To Len(aDadosDes)
				cXml += '    <desdobramento>' + CRLF
				cXml += '      <valorTotalItem>' + JConvUTF8(cValToChar(aDadosDes[nI][1])) + '</valorTotalItem>' + CRLF
				cXml += '      <naturezaDesdobramento>' + JConvUTF8(aDadosDes[nI][2]) + '</naturezaDesdobramento>' + CRLF
				cXml += '      <codigoSolicitante>' + JConvUTF8(aDadosDes[nI][3]) + '</codigoSolicitante>' + CRLF
				cXml += '      <codigoEscritorio>' + JConvUTF8(aDadosDes[nI][4]) + '</codigoEscritorio>' + CRLF
				cXml += '      <centroCusto>' + JConvUTF8(aDadosDes[nI][5]) + '</centroCusto>' + CRLF
				cXml += '      <codigoParticipante>' + JConvUTF8(aDadosDes[nI][6])  + '</codigoParticipante>' + CRLF
				cXml += '      <codigoCliente>' + JConvUTF8(aDadosDes[nI][7])  + '</codigoCliente>' + CRLF
				cXml += '      <lojaCliente>' + JConvUTF8(aDadosDes[nI][8])  + '</lojaCliente>' + CRLF
				cXml += '      <codigoCaso>' + JConvUTF8(aDadosDes[nI][9])  + '</codigoCaso>' + CRLF
				cXml += '      <codigoTipoDespesa>' + JConvUTF8(aDadosDes[nI][10])  + '</codigoTipoDespesa>' + CRLF
				cXml += '      <quantidadeDespesa>' + cValToChar(aDadosDes[nI][11]) + '</quantidadeDespesa>' + CRLF
				cXml += '      <dataDespesa>' + JConvUTF8(aDadosDes[nI][12])  + '</dataDespesa>' + CRLF
				cXml += '      <cobraDespesa>' + JConvUTF8(aDadosDes[nI][13])  + '</cobraDespesa>' + CRLF
				cXml += '      <codigoProjeto>' + JConvUTF8(aDadosDes[nI][14])  + '</codigoProjeto>' + CRLF
				cXml += '      <codigoItemProjeto>' + JConvUTF8(aDadosDes[nI][15])  + '</codigoItemProjeto>' + CRLF
				cXml += '      <historico>' + JConvUTF8(aDadosDes[nI][16])  + '</historico>' + CRLF
				cXml += '      <dataInclusao>' + JConvUTF8(aDadosDes[nI][17])  + '</dataInclusao>' + CRLF
				cXml += '    </desdobramento>' + CRLF
			Next
			cXml += '  </desdobramentos>' + CRLF
			cXml += '</DocEntrada>' + CRLF

		EndIf

		// Determinar formato da resposta baseado no header Accept
		If cContent == "XML"
			If lRet
				cResponse := cXml
			EndIf	
			Self:SetContentType("application/xml")
		Else
			cResponse := FWJsonSerialize(oResponse, .F., .F., .T.)
			Self:SetContentType("application/json")
		EndIf

		Self:SetResponse(cResponse)
	EndIf

	// Limpeza
	oResponse:FromJSon("{}")
	oResponse := Nil
	RestArea(aArea)

Return lRet


//-------------------------------------------------------------------
/*{Protheus.doc} JGetDoc
Obter dados da SF1 atraves da chave filial+doc+série+fornecedor+loja

@author Guilherme Vieira
@since  30/10/2025
/*/
//-------------------------------------------------------------------
Static Function JGetDoc(cFil, cDoc, cSer, cFor, cLoj)
Local aRet   := {}
Local cQuery := ""
Local cAlias := GetNextAlias()
Local oStmt  := Nil
Local nParam := 0

	cQuery := "SELECT F1_FILIAL,"
	cQuery +=       " F1_DOC,"
	cQuery +=       " F1_SERIE,"
	cQuery +=       " F1_FORNECE,"
	cQuery +=       " F1_LOJA,"
	cQuery +=       " F1_MOEDA,"
	cQuery +=       " F1_TXMOEDA,"
	cQuery +=       " F1_VALMERC,"
	cQuery +=       " F1_VALBRUT,"
	cQuery +=       " F1_EMISSAO,"
	cQuery +=       " F1_STATUS"
	cQuery +=  " FROM " + RetSqlName('SF1')
	cQuery += " WHERE F1_FILIAL = ?"
	cQuery +=   " AND F1_DOC = ?"
	cQuery +=   " AND F1_SERIE = ?"
	cQuery +=   " AND F1_FORNECE = ?"
	cQuery +=   " AND F1_LOJA = ?"
	cQuery +=   " AND D_E_L_E_T_ = ?"

	oStmt := FWPreparedStatement():New(cQuery)
	oStmt:SetString(++nParam, cFil) // Parâmetro 1: filial
	oStmt:SetString(++nParam, cDoc) // Parâmetro 2: documento
	oStmt:SetString(++nParam, cSer) // Parâmetro 3: série
	oStmt:SetString(++nParam, cFor) // Parâmetro 4: fornecedor
	oStmt:SetString(++nParam, cLoj) // Parâmetro 5: loja
	oStmt:SetString(++nParam, Space(1)) // Parâmetro 6: d_e_l_e_t_

	cQuery := oStmt:GetFixQuery()
	MpSysOpenQuery(cQuery, cAlias)

	If !(cAlias)->(Eof())
		aRet := {(cAlias)->F1_FILIAL, (cAlias)->F1_DOC, (cAlias)->F1_SERIE, (cAlias)->F1_FORNECE, (cAlias)->F1_LOJA,;
		         (cAlias)->F1_MOEDA,(cAlias)->F1_TXMOEDA,(cAlias)->F1_VALBRUT,(cAlias)->F1_VALMERC, (cAlias)->F1_EMISSAO, (cAlias)->F1_STATUS}
	EndIf

	oStmt:Destroy()
	(cAlias)->(dbCloseArea())

Return aRet

//-------------------------------------------------------------------
/*{Protheus.doc} JGetDes
Obter dados da OHV atraves da chave filial+doc+série+fornecedor+loja

@author Guilherme Vieira
@since  30/10/2025
/*/
//-------------------------------------------------------------------
Static Function JGetDes(cFil, cDoc, cSer, cFor, cLoj)
Local aRet    := {}
Local cQuery  := ""
Local cHistor := ""
Local cAlias  := GetNextAlias()
Local oStmt   := Nil
Local nParam  := 0

	cQuery := "SELECT OHV_COD,"
	cQuery +=       " OHV_ITEM,"
	cQuery +=       " OHV_TOTAL,"
	cQuery +=       " OHV_CNATUR,"
	cQuery +=       " OHV_CPART,"
	cQuery +=       " OHV_CESCR,"
	cQuery +=       " OHV_CCUSTO,"
	cQuery +=       " OHV_CPART2,"
	cQuery +=       " OHV_CCLIEN,"
	cQuery +=       " OHV_CLOJA,"
	cQuery +=       " OHV_CCASO,"
	cQuery +=       " OHV_CTPDSP,"
	cQuery +=       " OHV_QTDDSP,"
	cQuery +=       " OHV_DTDESP,"
	cQuery +=       " OHV_COBRA,"
	cQuery +=       " OHV_CPROJE,"
	cQuery +=       " OHV_CITPRJ,"
	cQuery +=       " OHV_HISTOR,"
	cQuery +=       " OHV_DTINCL"
	cQuery +=  " FROM " + RetSqlName('OHV')
	cQuery += " WHERE OHV_FILIAL = ?"
	cQuery +=   " AND OHV_DOC = ?"
	cQuery +=   " AND OHV_SERIE = ?"
	cQuery +=   " AND OHV_FORNEC = ?"
	cQuery +=   " AND OHV_LOJA = ?"
	cQuery +=   " AND D_E_L_E_T_ = ?"
	cQuery += " ORDER BY OHV_ITEM DESC"

	oStmt := FWPreparedStatement():New(cQuery)
	oStmt:SetString(++nParam, cFil)     // Parâmetro 1: filial
	oStmt:SetString(++nParam, cDoc)     // Parâmetro 2: documento
	oStmt:SetString(++nParam, cSer)     // Parâmetro 3: série
	oStmt:SetString(++nParam, cFor)     // Parâmetro 4: fornecedor
	oStmt:SetString(++nParam, cLoj)     // Parâmetro 5: loja
	oStmt:SetString(++nParam, Space(1)) // Parâmetro 6: d_e_l_e_t_

	cQuery := oStmt:GetFixQuery()
	MpSysOpenQuery(cQuery, cAlias)

	While !(cAlias)->(Eof())

		// Obtenção das informações dos campos MEMO
		OHV->(DbSetOrder(1)) //OHV_FILIAL, OHV_DOC, OHV_SERIE, OHV_FORNEC, OHV_LOJA, OHV_COD, OHV_ITEM
		If (OHV->(DbSeek(cFil + cDoc + cSer + cFor + cLoj + (cAlias)->OHV_COD + (cAlias)->OHV_ITEM)))
			cHistor := OHV->OHV_HISTOR
		EndIf

		aAdd(aRet, {(cAlias)->OHV_TOTAL, (cAlias)->OHV_CNATUR, (cAlias)->OHV_CPART, (cAlias)->OHV_CESCR, (cAlias)->OHV_CCUSTO,;
		            (cAlias)->OHV_CPART2, (cAlias)->OHV_CCLIEN, (cAlias)->OHV_CLOJA, (cAlias)->OHV_CCASO, (cAlias)->OHV_CTPDSP,;
		            (cAlias)->OHV_QTDDSP, (cAlias)->OHV_DTDESP, (cAlias)->OHV_COBRA, (cAlias)->OHV_CPROJE, (cAlias)->OHV_CITPRJ,;
		            cHistor, (cAlias)->OHV_DTINCL})
		(cAlias)->(dbSkip())
	EndDo

	oStmt:Destroy()
	(cAlias)->(dbCloseArea())

Return aRet

//-------------------------------------------------------------------
/*{Protheus.doc} PUT aprovacao doc entrada
Consulta documentos de entrada

@example PUT -> http://127.0.0.1:9090/rest/WsPfsAppComCtrlOrc/AprvDocEntr/{cChaveDoc}
Body JSON: {"situacao": "Aprovado"} ou {"situacao": "Reprovado", "justificativa": "Motivo"}

@param cChaveDoc - Chave contendo filial+doc+serie+fornecedor+loja (Número da nota)

@author Guilherme Vieira
@since  10/11/2025
/*/
//-------------------------------------------------------------------

WSMETHOD PUT AprvDoc PATHPARAM cChaveDoc WSREST WsPfsAppComCtrlOrc
Local cChvDocEnd  := Decode64(Self:cChaveDoc)
Local nTamFilial  := TamSX3("F1_FILIAL")[1]
Local nTamDoc     := TamSX3("F1_DOC")[1]
Local nTamSerie   := TamSX3("F1_SERIE")[1]
Local nTamFornec  := TamSX3("F1_FORNECE")[1]
Local nTamLoja    := TamSX3("F1_LOJA")[1]
Local cFilDoc     := Substr(cChvDocEnd, 1, nTamFilial)
Local cDocEnt     := Substr(cChvDocEnd, nTamFilial + 1, nTamDoc)
Local cSerie      := Substr(cChvDocEnd, nTamFilial + nTamDoc + 1, nTamSerie)
Local cFornec     := Substr(cChvDocEnd, nTamFilial + nTamDoc + nTamSerie + 1, nTamFornec)
Local cLoja       := Substr(cChvDocEnd, nTamFilial + nTamDoc + nTamSerie + nTamFornec + 1, nTamLoja)
Local oRequest    := JsonObject():New()
Local oResponse   := JsonObject():New()
Local oXml        := NIL
Local aXml        := {}
Local cBody       := Self:GetContent()
Local lJSON       := .T.
Local lRet        := .T.
Local cAccept     := Self:GetAccept() // Captura o header Accept
Local cSituacao   := ""
Local cJustific   := ""
Local cResponse   := ""
Local nPosSituac  := 0
Local nPosJustif  := 0

	// Identificando o tipo do Body
	If !Empty(cAccept) .And. ValType(cAccept) == "C"
		cContent := Upper(Substr(cAccept, At("/",cAccept)+1))
		If cContent != "JSON"
			lJSON := .F.
			oXml := TXmlManager():New()
			If oXML:Parse( cBody )
				aXml := oXML:DOMGetChildArray()
				nPosSituac := ASCAN(oXML:DOMGetChildArray(), {|x| AllTrim(Upper(x[1])) == "SITUACAO"})
				nPosJustif := ASCAN(oXML:DOMGetChildArray(), {|x| AllTrim(Upper(x[1])) == "JUSTIFICATIVA"})
			Else
				SetRestFault(400, JConvUTF8(STR0013), lJSON) // STR0013 - "XML inválido"
				lRet := .F.
			EndIf
		Else
			oRequest:FromJson(cBody)
		EndIf
	EndIf

	SF1->(DbSetOrder(1))
	If SF1->(DbSeek(cFilDoc + cDocEnt + cSerie + cFornec + cLoja))
		If lJSON
			cSituacao := AllTrim(oRequest['situacao'])
			cJustific := AllTrim(oRequest['justificativa'])
		Else
			If nPosSituac > 0
				cSituacao := aXml[nPosSituac][2]
			EndIf

			If nPosJustif > 0
				cJustific := aXml[nPosJustif][2]
			EndIf
		EndIf

		If Empty(cSituacao)
			lRet := .F.
			SetRestFault(400, JConvUTF8(STR0007), lJSON) //STR0007 - "Campo 'situacao' é obrigatório!"
		ElseIf Upper(AllTrim(cSituacao)) == Upper("Aprovado")
			// Aprovação: sucesso imediato
			If lJSON
				oResponse['message'] := STR0008  //STR0008 - "Documento aprovado com sucesso!"
				oResponse['code'] := "200"
				Self:SetResponse(oResponse:toJson())
			Else
				cResponse := '<?xml version="1.0" encoding="UTF-8"?>' + CRLF
				cResponse += '<response>' + CRLF
				cResponse += '  <message>' + JConvUTF8(STR0008) + '</message>' + CRLF //STR0008 - "Documento aprovado com sucesso!"
				cResponse += '  <code>200</code>' + CRLF
				cResponse += '</response>' + CRLF
				Self:SetContentType("application/xml")
				Self:SetResponse(cResponse)
			EndIf
		ElseIf Upper(AllTrim(cSituacao)) == Upper("Reprovado")
			If Empty(cJustific)
				lRet := .F.
				SetRestFault(400, JConvUTF8(STR0009), lJSON) //STR0009 - "Justificativa é obrigatória para reprovação!"
			Else
				// Reprovação com justificativa: sucesso
				If lJSON
					oResponse['message'] := STR0010 //STR0010 - "Documento reprovado com sucesso!"
					oResponse['code'] := "200"
					Self:SetResponse(oResponse:toJson())
				Else
					cResponse := '<?xml version="1.0" encoding="UTF-8"?>' + CRLF
					cResponse += '<response>' + CRLF
					cResponse += '  <message>' + JConvUTF8(STR0010) + '</message>' + CRLF //STR0010 - "Documento reprovado com sucesso!"
					cResponse += '  <code>200</code>' + CRLF
					cResponse += '</response>' + CRLF
					Self:SetContentType("application/xml")
					Self:SetResponse(cResponse)
				EndIf
			EndIf
		Else
			lRet := .F.
			SetRestFault(400, JConvUTF8(STR0011), lJSON) //STR0011 - "Valor inválido para 'situacao'! Use 'Aprovado' ou 'Reprovado'."
		EndIf
	Else
		SetRestFault(400, JConvUTF8(STR0012 + " - " + cChvDocEnd), lJSON) //STR0012 - "Documento de entrada não encontrado!"
		lRet := .F.
	EndIf

	oRequest  := Nil
	oResponse := Nil

Return lRet
