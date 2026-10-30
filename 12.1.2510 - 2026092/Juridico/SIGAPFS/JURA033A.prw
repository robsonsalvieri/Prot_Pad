#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'JURA033A.CH'

#Define CALC_QTD "1"
#Define CALC_VLR "2"

#Define FAIXA_ESTATICA "1"
#Define FAIXA_PROGRESSIVA "2"

#Define TPVLR_FIXO       "1"
#Define TPVLR_UNITARIO   "2"
#Define TPVLR_PERCENTUAL "3"

//------------------------------------------------------------------------------
/* /{Protheus.doc} J033GrvOco(oRequest)
Realiza a gravação da fatura adicional conforme a solicitação da ocorrência

@param oRequest, JSON, Objeto da requisição
@return lRet, retorna se a requisição foi realizada com sucesso
@since 07/10/2022
/*/
//------------------------------------------------------------------------------
Function J033GrvOco(oRequest)
Local lRet      := .T.
Local oModel    := FwLoadModel('JURA033')
Local oMdlNVV   := oModel:GetModel('NVVMASTERCAB') // Fatura adicional
Local cCodFatAdc := ""
Local lCriaFatAd := .F.

	lCriaFatAd := CalculaOcorrencia(oRequest)

	If lCriaFatAd
		oModel:SetOperation(MODEL_OPERATION_INSERT)
		
		If oModel:Activate() .AND. oRequest["valor-total"] > 0
			//Cabeçalho
			oMdlNVV:SetValue('NVV_CCLIEN' ,oRequest["contrato"]["cliente"])
			oMdlNVV:SetValue('NVV_CLOJA'  ,oRequest["contrato"]["loja"])
			oMdlNVV:SetValue('NVV_CCONTR' ,oRequest["contrato"]["codigo"])
			oMdlNVV:SetValue('NVV_TRATS'  ,'2')
			oMdlNVV:SetValue("NVV_DTINIH", StoD(oRequest['dataReferencia']['inicial'] ))
			oMdlNVV:SetValue("NVV_DTFIMH", StoD(oRequest['dataReferencia']['final']))
			oMdlNVV:SetValue("NVV_CMOE1" , oRequest["moeda"])
			oMdlNVV:SetValue('NVV_VALORH' ,Val(cValtochar(oRequest["valor-total"])))
			oMdlNVV:SetValue('NVV_TRALT'  ,'2')
			oMdlNVV:SetValue('NVV_DSPCAS' ,'2')
			oMdlNVV:SetValue('NVV_TRADSP' ,'2')
			oMdlNVV:SetValue('NVV_OCORRE' ,'1')
			oMdlNVV:SetValue('NVV_DESREL' ,oRequest["descricao"])
			oMdlNVV:SetValue('NVV_DESCRT' ,oRequest["descricao"])

			SetPagadores(oModel)

			SetCasos(oModel,oRequest["casos"])

			If (oModel:VldData() .and. oModel:CommitData())
			
				cCodFatAdc := oMdlNVV:GetValue('NVV_COD')
				oRequest["codFatura"] := cCodFatAdc
				oRequest["isOk"]      := .T.

				// gravação do histórico da pré fatura
				SetHistorico(cCodFatAdc,oRequest)

			Else
				lRet:= .F.
				oRequest["isOk"]         := .F.
				oRequest["messageError"] := oModel:GetErrorMessage()
			Endif

			oModel:DeActivate()
		EndIf
	EndIf
	oModel:Destroy()

Return { lRet, cCodFatAdc }

//------------------------------------------------------------------------------
/* /{Protheus.doc} CalculaOcorrencia(oRequest)
Realiza a busca e o calculo da ocorrência

@param oRequest, JSON, Objeto da requisição
@return
@since 07/10/2022
/*/
//------------------------------------------------------------------------------
Static Function CalculaOcorrencia(oRequest)

	GetOcorrencia(oRequest)
	chkLimParcela(oRequest)

Return CalculaFaixas(oRequest)

//------------------------------------------------------------------------------
/* /{Protheus.doc} chkLimParcela(oRequest)
Trata as entidades que utrapassaram o limite das parcelas

@param oRequest, objeto de resposta da requisição
@since 07/10/2022
/*/
//------------------------------------------------------------------------------
Static Function chkLimParcela(oRequest)
Local nLimPar          := oRequest["dadosOcorrencia"]["limiteParcelas"]
Local aResposta        := Nil
Local nQtdTotal        := 0
Local nQtdExcluido     := 0
Local aParams          := {}
Local cQuery           := ""
Local nPos             := 0
Local cTmpAlias        := GetNextAlias()

	aResposta := verResposta(oRequest)
	nQtdTotal        := Len(aResposta)
	If nQtdTotal > 0
		If nLimPar > 0

			aAdd(aParams,oRequest["contrato"]["codigo"])
			aAdd(aParams,oRequest["dadosOcorrencia"]["codigo"])
			aAdd(aParams,cValToChar(nLimPar))

			cQuery += " SELECT OI6_CHVUNI "
			cQuery += " FROM " + RetSqlName("OI6") + " OI6 "
			cQuery +=         " INNER JOIN " + RetSqlName("NVV") + " NVV  "
			cQuery +=             " ON (NVV.NVV_FILIAL = OI6.OI6_FILIAL "
			cQuery +=             " AND NVV.NVV_COD    = OI6.OI6_FATADI "
			cQuery +=             " AND NVV.D_E_L_E_T_ = ' ') "
			cQuery += " WHERE NVV.NVV_OCORRE = '1' "
			cQuery +=     " AND OI6.OI6_CONTRA = ? "
			cQuery +=     " AND OI6.OI6_OCORRE = ? "
			cQuery +=     " AND OI6.D_E_L_E_T_ = ' ' "
			cQuery += " GROUP BY OI6_CHVUNI "
			cQuery += " HAVING COUNT(*) >= ? "

			dbUseArea( .T., 'TOPCONN', TCGenQry2(NIL,NIL,cQuery,aParams), cTmpAlias, .T., .F. )

			While (cTmpAlias)->(!EoF())
				If (nPos := AScan(aResposta,{|x| x["id"] == AllTrim((cTmpAlias)->OI6_CHVUNI)})) > 0
					aResposta[nPos]["limiteParcela"] := .T.
					nQtdExcluido++
				EndIf
				(cTmpAlias)->(DBSkip())
			EndDo
			(cTmpAlias)->(DbCloseArea())
		Endif
	EndIf
	oRequest["quantidadeValida"] := nQtdTotal - nQtdExcluido
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} verResposta
	Verifica a resposta 
	
	@since 20/12/2022
	@version 1.0
	@param oRequest objeto de resposta da requisição
	@return aResposta array com a estrutura da resposta sendo processo ou ato

/*/
//------------------------------------------------------------------------------
Static function verResposta(oRequest)
Local aResposta := {}
	
	If (oRequest["entidade"] == "1") .And. oRequest['resposta']:getNames()[1] == "processos"
		aResposta    := oRequest["resposta"]["processos"]
	ElseIf oRequest['resposta']:getNames()[1] == "atosProcessuais"
		aResposta    := oRequest["resposta"]["atosProcessuais"]
	EndIf
Return aResposta

//------------------------------------------------------------------------------
/* /{Protheus.doc} SetPagadores(oModel)
Preenche os pagadores no modelo de dados

@param oModel, objeto, modelo de dados
@return
@since 07/10/2022
/*/
//--------------------------------------------------------	----------------------
Static Function SetPagadores(oModel)
Local oMdlNVV   := oModel:GetModel('NVVMASTERCAB') // Fatura adicional
Local oMdlNXG   := oModel:GetModel('NXGDETAIL')    // Pagadores
Local cContrato := oMdlNVV:GetValue('NVV_CCONTR')
Local cQuery    := ""
Local cTmpAlias := GetNextAlias()
Local aStruct   := {}
Local n1        := 0

	cQuery := " SELECT * "
	cQuery += " FROM " + RetSqlName("NXP") + " NXP "
	cQuery += " WHERE "
	cQuery +=     " NXP.NXP_FILIAL = ? "
	cQuery +=     " AND NXP.NXP_CCONTR = ? "
	cQuery +=     " AND NXP.D_E_L_E_T_ = ' '"

	dbUseArea( .T., 'TOPCONN', TcGenQry2(,,cQuery,{xFilial('NXP'),cContrato} ), cTmpAlias, .T., .F. )
	aStruct := (cTmpAlias)->(DbStruct())
	While (cTmpAlias)->(!EoF())
		If !Empty(oMdlNXG:GetValue("NXG_CLIPG"))
			oMdlNXG:addLine()
		Endif

		For n1 := 1 to Len(aStruct)
			
			cFld := "NXG_"+SubStr(aStruct[n1][1],5)

			If cFld == 'NXG_COD'
				loop
			Endif

			If oMdlNXG:HasField(cFld)
				oMdlNXG:SetValue(cFld,(cTmpAlias)->&(aStruct[n1][1]))
			Endif
		Next n1

		(cTmpAlias)->(DbSkip())
	End
	(cTmpAlias)->(DbCloseArea())


Return

//------------------------------------------------------------------------------
/* /{Protheus.doc} SetCasos(oModel,aCasos)
Preenche os casos na fatura adicional

@param oModel, objeto, modelo de dados
@param aCasos, array, lista dos casos a serem cadastrados
@return
@since 07/10/2022
/*/
//------------------------------------------------------------------------------
Static Function SetCasos(oModel,aCasos)
Local oMdlNVW := oModel:GetModel('NVWDETAIL')    // Casos
Local n1      := 1

	For n1 := 1 to len(aCasos)
		aCasos[n1]["valor"] := Val(cValtoChar(If(ValType(aCasos[n1]["valor"]) <> "U",aCasos[n1]["valor"],0)))
		If !Empty(oMdlNVW:GetValue('NVW_CCLIEN'))
			oMdlNVW:addLine()
		Endif
		oMdlNVW:SetValue('NVW_CCLIEN',aCasos[n1]["cliente"])
		oMdlNVW:SetValue('NVW_CLOJA' ,aCasos[n1]["loja"])
		oMdlNVW:SetValue('NVW_CCASO' ,aCasos[n1]["caso"])
		oMdlNVW:SetValue('NVW_VALORH',aCasos[n1]["valor"])

	Next

Return

//------------------------------------------------------------------------------
/* /{Protheus.doc} GetOcorrencia(oRequest)
Busca os dados da ocorrência

@param oRequest, JSON, objeto da requisição
@return oRequest, JSON, objeto da requisição
@since 07/10/2022
/*/
//------------------------------------------------------------------------------
Static Function GetOcorrencia(oRequest)
Local aParams    := {}
Local cQuery     := ""
Local cTmpAlias  := GetNextAlias()

	cQuery += " SELECT  "
	cQuery += " 	OI4.OI4_TPFAIX, "
	cQuery += " 	OI4.OI4_TPCALC, "
	cQuery += " 	OI4.OI4_LIMPAR, "
	cQuery += " 	OI2.OI2_DESC,  "
	cQuery += " 	OI2.OI2_ENTIDA,  "
	cQuery += " 	OI5.OI5_VLRINI, "
	cQuery += " 	OI5.OI5_VLRFIN, "
	cQuery += " 	OI5.OI5_TPVALO, "
	cQuery += " 	OI5.OI5_VALOR "
	cQuery += " FROM "+RetSqlName("OI4")+" OI4 "
	cQuery += " 	INNER JOIN  "+RetSqlName("OI2")+"  OI2 ON "
	cQuery += " 		OI2.OI2_FILIAL = ? " //1
	cQuery += " 		AND OI2.OI2_COD = OI4.OI4_COCORR "
	cQuery += " 		AND OI2.D_E_L_E_T_ = ' ' "
	cQuery += " 	INNER JOIN  "+RetSqlName("OI5")+"  OI5 ON "
	cQuery += " 		OI5.OI5_FILIAL = OI4.OI4_FILIAL "
	cQuery += " 		AND OI5.OI5_CCONTR = OI4.OI4_CCONTR "
	cQuery += " 		AND OI5.OI5_COCORR = OI4.OI4_COCORR "
	cQuery += " 		AND OI5.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE "
	cQuery += " 	OI4.OI4_FILIAL = ? "     //2
	cQuery += " 	AND OI4.OI4_CCONTR = ? " //3
	cQuery += " 	AND OI4.OI4_COCORR = ? " //4
	cQuery += " 	AND OI4.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY OI4_FILIAL,OI4_CCONTR,OI4_COCORR,OI5_SEQ "

	aAdd(aParams,xFilial('OI2'))
	aAdd(aParams,xFilial('OI4'))
	aAdd(aParams,oRequest["contrato"]["codigo"])
	aAdd(aParams,oRequest["ocorrencia"]["codigo"])
	
	dbUseArea( .T., 'TOPCONN', TCGenQry2(NIL,NIL,cQuery,aParams), cTmpAlias, .T., .F. )
	
	oRequest["moeda"]    := JurGetDados('NT0',1,xFilial('NT0')+oRequest["contrato"]["codigo"],"NT0_CMOE")
	oRequest["descMoeda"]:= JurGetDados('CTO',1,xFilial('CTO')+oRequest["moeda"]   ,'CTO_SIMB')

	oRequest["dadosOcorrencia"]:= JsonObject():New()
	oRequest["dadosOcorrencia"]["faixas"]      := {}

	If (cTmpAlias)->(!Eof())
		oRequest["dadosOcorrencia"]["codigo"]         := oRequest["ocorrencia"]["codigo"]
		oRequest["dadosOcorrencia"]["entidade"]       := JurInfBox('OI2_ENTIDA', (cTmpAlias)->OI2_ENTIDA)
		oRequest["dadosOcorrencia"]["codEntidade"]    := (cTmpAlias)->OI2_ENTIDA
		oRequest["dadosOcorrencia"]["descricao"]      := AllTrim((cTmpAlias)->OI2_DESC)
		oRequest["dadosOcorrencia"]["tipoFaixa"]      := (cTmpAlias)->OI4_TPFAIX
		oRequest["dadosOcorrencia"]["tipoCalculo"]    := (cTmpAlias)->OI4_TPCALC
		oRequest["dadosOcorrencia"]["limiteParcelas"] := (cTmpAlias)->OI4_LIMPAR
		
		While (cTmpAlias)->(!Eof())

			aAdd(oRequest["dadosOcorrencia"]["faixas"],JsonObject():New())
			aTail(oRequest["dadosOcorrencia"]["faixas"])["valorInicial"]   := (cTmpAlias)->OI5_VLRINI
			aTail(oRequest["dadosOcorrencia"]["faixas"])["valorFinal"]     := (cTmpAlias)->OI5_VLRFIN
			aTail(oRequest["dadosOcorrencia"]["faixas"])["tipoValor"]      := (cTmpAlias)->OI5_TPVALO
			aTail(oRequest["dadosOcorrencia"]["faixas"])["tipoValorDesc"]  := JurInfBox('OI5_TPVALO', (cTmpAlias)->OI5_TPVALO)
			aTail(oRequest["dadosOcorrencia"]["faixas"])["valor"]          := (cTmpAlias)->OI5_VALOR
			aTail(oRequest["dadosOcorrencia"]["faixas"])["utilizado"]      := .F.
			aTail(oRequest["dadosOcorrencia"]["faixas"])["valorUtilizado"] := 0
			aTail(oRequest["dadosOcorrencia"]["faixas"])["quantidade"]     := 0

			(cTmpAlias)->(DbSkip())
		End
	Endif

	(cTmpAlias)->(DbCloseArea())
	aSize(aParams,0)
	aParams:= nil

Return oRequest

//------------------------------------------------------------------------------
/* /{Protheus.doc} CalculaFaixas(oRequest)
Calcula os valores das faixas

@param oRequest, JSON, objeto da requisição
@return oRequest, JSON, objeto da requisição
@since 07/10/2022
/*/
//------------------------------------------------------------------------------
Static Function CalculaFaixas(oRequest)
Local oOcorrencia  := oRequest["dadosOcorrencia"]
Local oResposta    := Nil
Local cTpCalculo   := oOcorrencia["tipoCalculo"]
Local nQtdEntidade := oRequest["quantidadeValida"]
Local cFldRetorno  := oRequest["campoRetorno"]
Local cTpFaixa     := oOcorrencia["tipoFaixa"]
Local nI           := 0
Local nVlrEntida   := 0
Local aFaixas      := oOcorrencia["faixas"]
Local cRetFaixa    := ""
Local cPictValor   := ""
Local lProcFatAd   := .T.

	oResposta := verResposta(oRequest)

	oRequest["valor-total"] := 0

	If (Len(oResposta) > 0)
		If cTpCalculo == CALC_QTD
			cPictValor := "@E 99,999,999,999" 
			oRequest["valor-total"] := GetVlrFaixa(aFaixas,cTpFaixa,nQtdEntidade,.F.,oRequest["descMoeda"],@cRetFaixa)
			nVlrEntida := oRequest["valor-total"]/nQtdEntidade
			For nI := 1 to Len(oResposta)
				if !oResposta[nI]["limiteParcela"]
					oResposta[nI]["valorUnitario"]  := nVlrEntida
					oResposta[nI]["faixaUtilizada"] := cRetFaixa
					SetVlrCaso(oRequest["casos"],oResposta[nI]["caso"],nVlrEntida)
				Endif
			Next
		Else //CALC_VLR
			cPictValor := "@E 99,999,999,999.99"
			For nI := 1 to Len(oResposta) 
				if !oResposta[nI]["limiteParcela"]
					oResposta[nI]["valorUnitario"]  := GetVlrFaixa(aFaixas,cTpFaixa,oResposta[nI][cFldRetorno],.T.,oRequest["descMoeda"],@cRetFaixa)
					oResposta[nI]["faixaUtilizada"] := cRetFaixa
					oRequest["valor-total"]         += oResposta[nI]["valorUnitario"]
					SetVlrCaso(oRequest["casos"],oResposta[nI]["caso"],oResposta[nI]["valorUnitario"])
				EndIf
			Next
		Endif

		oRequest["descricao"] :=  I18n(;
										STR0001+Chr(13)+Chr(10);//"#1 no período #2 à #3."
										+STR0002+Chr(13)+Chr(10);//"Possuindo #4 #5(s) num total de #6 caso(s), totalizando: #7#8."
										+STR0003+Chr(13)+Chr(10);//"Na(s) faixa(s) de valores:"
									,{;
										oOcorrencia["descricao"],;
										DtoC(StoD(oRequest['dataReferencia']['inicial'] )),;
										DtoC(StoD(oRequest['dataReferencia']['final'] )),;
										nQtdEntidade,;
										oRequest["dadosOcorrencia"]["entidade"] ,;
										Len(oRequest["casos"]),;
										oRequest["descMoeda"],;
										Transform( oRequest["valor-total"], "@E 99,999,999,999.99");
									})

		For nI := 1 to Len(aFaixas)
			If aFaixas[nI]["utilizado"]
				//"#1 #2(s) entre a(s) faixa(s) #3 à #4, totalizando: #5#6"
				oRequest["descricao"] += I18N(STR0004,{;
					aFaixas[nI]["quantidade"],;
					oRequest["dadosOcorrencia"]["entidade"] ,;
					Transform( aFaixas[nI]["valorInicial"], cPictValor) ,;
					Transform( aFaixas[nI]["valorFinal"], cPictValor),;
					oRequest["descMoeda"],;
					Transform( aFaixas[nI]["valorUtilizado"], "@E 99,999,999,999.99");
				})+Chr(13)+Chr(10)
			Endif
		Next
	Else
		lProcFatAd := .F.
	EndIf
Return lProcFatAd

//------------------------------------------------------------------------------
/* /{Protheus.doc} SetVlrCaso(aCasos,cCaso,nVlrUnit)
Função para preencher o valor do caso

@param aCasos, array, lista de casos
@param cCaso, string, código do caso
@param nVlrUnit, numeric, valor da entidade
@since 07/10/2022
/*/
//------------------------------------------------------------------------------
Static Function SetVlrCaso(aCasos,cCaso,nVlrUnit)
Local nPos := aScan(aCasos,{|x| x['caso'] == cCaso })
	If nPos > 0
		//Proteção caso o valor esteja nulo
		aCasos[nPos]["valor"] := If(ValType(aCasos[nPos]["valor"]) == "U", 0 ,aCasos[nPos]["valor"])

		aCasos[nPos]["valor"] += nVlrUnit
	Endif
Return

//------------------------------------------------------------------------------
/* /{Protheus.doc} GetVlrFaixa(aFaixas,cTpFaixa,nValor,lValor,cMoeda,cRetFaixa)
Função para preencher o valor do caso

@param aFaixas, array, lista de faixas
@param cTpFaixa, string, tipo da faixa
@param nValor, numerico, valor a ser calculado
@param lValor, boolean, se é em valor ou quantidade
@param cMoeda, string, Moeda utilizada
@param cRetFaixa, string, informativo das faixas utilizadas
@return nRet,numerico, valor da faixa
@since 07/10/2022
/*/
//------------------------------------------------------------------------------
Static Function GetVlrFaixa(aFaixas,cTpFaixa,nValor,lValor,cMoeda,cRetFaixa)
Local nRet       := 0
Local nVlr       := 0
Local nVlrAux    := 0
Local nPos       := 0
Local cPictValor := if(lValor,"@E 99,999,999,999.99","@E 99,999,999,999")


Default lValor    := .F.
Default cRetFaixa := ""
	cRetFaixa := ""
	If cTpFaixa == FAIXA_ESTATICA
		If (nPos := aScan(aFaixas,{|x| x["valorInicial"]<= nValor .and. x["valorFinal"]>= nValor } ))  >0
			nRet := retVlrFaixa(aFaixas[nPos],nValor,lValor)
			aFaixas[nPos]["utilizado"]      := .T.
			aFaixas[nPos]["valorUtilizado"] += nRet
			aFaixas[nPos]["quantidade"]     := If(lValor, aFaixas[nPos]["quantidade"]+1,nValor)
			
			//"Contemplado a faixa estática entre #1 à #2, sendo calculado o #3 de: #4#5"
			cRetFaixa := I18n(STR0005,;
								{;
									Alltrim(Transform( aFaixas[nPos]["valorInicial"], cPictValor)),;
									Alltrim(Transform( aFaixas[nPos]["valorFinal"], cPictValor)),;
									aFaixas[nPos]["tipoValorDesc"],;
									cMoeda,;
									Alltrim(Transform(nRet,"@E 99,999,999,999.99"));
								})
		Endif
	Else //FAIXA_PROGRESSIVA
		For nPos := 1 to Len(aFaixas)
			If aFaixas[nPos]["valorInicial"] >= nValor 
				Exit
			Endif

			nVlrAux := nValor

			If Empty(cRetFaixa)
				cRetFaixa := STR0006+Chr(13)+Chr(10)//"Contemplado a(s) faixa(s) de forma progressiva, sendo:"
			Endif

			If nVlrAux > aFaixas[nPos]["valorFinal"]
				nVlrAux := aFaixas[nPos]["valorFinal"]
			EndIf 

			If !lValor
				nVlrAux := nVlrAux-If(aFaixas[nPos]["valorInicial"]>0,aFaixas[nPos]["valorInicial"]-1,0)
			Endif

			
			nVlr   := retVlrFaixa(aFaixas[nPos], nVlrAux,lValor)
			nRet   += nVlr
			aFaixas[nPos]["utilizado"]      := .T.
			aFaixas[nPos]["valorUtilizado"] += nVlr
			aFaixas[nPos]["quantidade"]     := If(lValor, aFaixas[nPos]["quantidade"]+1,nVlrAux)
			cRetFaixa := I18n(STR0007,;//"Faixas entre #1 à #2, sendo calculado o #3 de: #4#5"
								{;
									Alltrim(Transform( aFaixas[nPos]["valorInicial"], cPictValor)),;
									Alltrim(Transform( aFaixas[nPos]["valorFinal"], cPictValor)),;
									aFaixas[nPos]["tipoValorDesc"],;
									cMoeda,;
									Alltrim(Transform(nVlr,"@E 99,999,999,999.99"));
								}) + Chr(13)+Chr(10)
			
		Next
	Endif

Return nRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} RetVlrFaixa(oFaixa,nValor,lValor)
Retorna o valor da faixa

@param oFaixa, JSON, Faixa a ser utilizada
@param nValor, numerico, valor a ser calculado
@param lValor, boolean, se é em valor ou quantidade
@return nRet,numerico, valor da faixa
@since 07/10/2022
/*/
//------------------------------------------------------------------------------
Static Function RetVlrFaixa(oFaixa,nValor,lValor)
Local nRet := 0

	If oFaixa["tipoValor"] == TPVLR_FIXO
		nRet :=  oFaixa["valor"]
	ElseIf oFaixa["tipoValor"] == TPVLR_UNITARIO
		nRet := if(lValor,1,nValor) * oFaixa["valor"]
	Else //TPVLR_PERCENTUAL
		nRet := Round(nValor * oFaixa["valor"] / 100,2)
	endif

Return nRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} SetHistorico(cCodFatura,oRequest)
Retorna o histórico da fatura adicional

@param cCodFatura, código da fatura adicional
@param oRequest, Resposta da requisição
@since 24/10/2022
/*/
//------------------------------------------------------------------------------
Static Function SetHistorico(cCodFatura,oRequest)
Local oModel303  := FwLoadModel('JURA303')
Local oMdOI6     := oModel303:GetModel('OI6MASTER') //  Histórico da fatura adicional
Local aResposta  := Nil
Local lRet       := .T.
Local nI         := 1

	aResposta := verResposta(oRequest)

	oModel303:SetOperation(MODEL_OPERATION_INSERT)
	For nI := 1 to len(aResposta)
		If aResposta[nI]["limiteParcela"]
			loop
		Endif
		If oModel303:Activate()
			// Preenche o formulário
			oMdOI6:SetValue("OI6_DTINI", StoD(oRequest['dataReferencia']['inicial']))
			oMdOI6:SetValue("OI6_DTFIM", StoD(oRequest['dataReferencia']['final']))
			oMdOI6:SetValue('OI6_CHVUNI',aResposta[nI]["id"])
			oMdOI6:SetValue('OI6_ENTIDA',oRequest["dadosOcorrencia"]["codEntidade"])
			oMdOI6:SetValue('OI6_CONTRA',oRequest["contrato"]["codigo"])
			oMdOI6:SetValue('OI6_OCORRE',oRequest["dadosOcorrencia"]["codigo"])
			oMdOI6:SetValue('OI6_FATADI',cCodFatura)

			If !(oModel303:VldData() .and. oModel303:CommitData())
				lRet := .F.
			EndIf
			oModel303:Deactivate()
		EndIf
	Next
	oModel303:Destroy()

Return lRet
