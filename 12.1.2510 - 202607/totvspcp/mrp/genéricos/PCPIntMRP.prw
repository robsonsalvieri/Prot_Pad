#INCLUDE "TOTVS.CH"
#INCLUDE "PCPINTMRP.CH"

#DEFINE CRLF CHR(10)
#DEFINE TAMANHO  1
#DEFINE DECIMAL  2
#DEFINE ERP      1
#DEFINE MRP      2
#DEFINE TABELA   1
#DEFINE CAMPOS   2
#DEFINE SINAL    3

#DEFINE PEND_CODIGO  1
#DEFINE PEND_STATUS  2
#DEFINE PEND_ATRJSON 3
#DEFINE PEND_POSICAO 4
#DEFINE PEND_MSGRET  5
#DEFINE PEND_MSGENV  6
#DEFINE PEND_TAMANHO 6

#DEFINE API_PEND_CODIGO      1
#DEFINE API_PEND_QTD_TOTAL   2
#DEFINE API_PEND_STATUS      3
#DEFINE API_PEND_MARCADOS    4
#DEFINE API_PEND_PROCESSADOS 5
#DEFINE API_PEND_MSG_ERRO    6
#DEFINE API_PEND_TAMANHO     6

Static _lTamLoad  := .F.
Static _lTemHZ8   := Nil
Static _lVRRev    := Nil
Static _nTmApi    := Nil
Static _nTmAtrJsn := 15
Static _nTmFil    := Nil
Static _nTmID     := Nil
Static _nTmMsgRet := Nil
Static _nTmProg   := Nil
Static _nTmStatus := Nil
Static _oCacheSMQ := JsonObject():New()
Static _oStmtSMQ  := Nil
Static _oStmtT4R  := Nil
Static _nTmGrdT4T := Nil

/*/{Protheus.doc} IntNewMRP
Verifica se a integração com o novo MRP está ativada.

@type  Function
@author lucas.franca
@since 17/05/2019
@version P12.1.25
@param cApi   , Caracter, API para verificar a integração
@param lOnline, Logical , Identifica se a API está configurada para ser
                          executada de modo Online (.T.), ou em BATH (.F.).
						  Passar por referência.
@return lAtivo, Logical , Indica se a integração está ativa ou não
/*/
Function IntNewMRP(cApi, lOnline)
	Local lAtivo := .F.

	//Verifica se a integração está ativa.
	If !FWAliasInDic("T4P",.F.)
		//Se a tabela não existe, retorna .F.
		Return .F.
	EndIf

	//Carrega variáveis com tamanho dos campos
	cargaTam()

	//Ajusta o tamanho da variável cApi
	cApi := PadR(cApi, _nTmApi)

	T4P->(dbSetOrder(1))
	If T4P->(dbSeek(xFilial("T4P")+cApi)) .And. T4P->T4P_ATIVO == '1'
		lAtivo := .T.
		//Se a integração estiver ativa, verifica o modo de integração (Online ou Batch)
		If T4P->T4P_TPEXEC == '1'
			lOnline := .T.
		Else
			lOnline := .F.
		EndIf
	Else
		lAtivo := .F.
	EndIf
Return lAtivo

/*/{Protheus.doc} PrcPendMRP
Função responsável por atualizar a tabela de pendências de integração do MRP

@type Function
@author douglas.heydt
@since 18/06/2019
@version P12.1.27
@param aReturn  , Array    , Array com os itens retornados pela API
@param cApi     , Character, Nome da Api que gerou o registro
@param oJsonData, Object   , Objeto Json que contém os registros para atualização (utilizado apenas em caso de erro)
@param lReproc  , Logical  , Indica se é reprocessamento.
@param aSuccess , Array    , Array com os itens integrados corretamente pela API. Opcional. Passar por referência.
@param aError   , Array    , Array com os itens que não puderam ser integrados. Opcional. Passar por referência.
@param lAllError, logico   , Varíavel que indica se foi possível executar a leitura do retorno da API. Opcional. Passar por referência.
@param cTipo    , Character, Indica o tipo do movimento. 1=Inclusão; 2=Exclusão.
@param cUUID    , Character, Identificador do processo do SCHEDULE. Utilizado para atualização de pendências.
@param lIntegra , logico   , Indica que foi realizado um processo de integração.
/*/
Function PrcPendMRP(aReturn, cApi, oJsonData, lReproc, aSuccess, aError, lAllError, cTipo, cUUID, lIntegra)
	Local aPend    := {}
	Local cError   := ""
	Local lUsaEnv  := .F.
	Local oJsonRet := JsonObject():New()

	Default cUUID    := ""
	Default lIntegra := .F.

	//Carrega variáveis com tamanho dos campos
	cargaTam()

	cError := oJsonRet:FromJson(aReturn[2])

	If !Empty(cError)
		arrayPend(@aPend, oJsonData, .T., cApi, oJsonData, @lUsaEnv)
		//Se não conseguiu interpretar o JSON, irá marcar todos os registros como erro de integração.
		PInMrpPend(0, oJsonData, lReproc, cApi, aPend, cTipo, cUUID, lIntegra)
		lAllError := .T.
	Else
		If aReturn[1] == 204
			//Exclusão com sucesso. Atualiza pendência de acordo
			//com os dados que foram enviados.
			arrayPend(@aPend, oJsonData, .F., cApi, oJsonData, @lUsaEnv)
			PInMrpPend(aReturn[1], oJsonData, lReproc, cApi, aPend, cTipo, cUUID, lIntegra)
		Else
			arrayPend(@aPend, oJsonRet, .F., cApi, oJsonData, @lUsaEnv)
		EndIf

		If aReturn[1] == 201 .Or. aReturn[1] == 207 .Or. aReturn[1] == 400 .Or. aReturn[1] == 503
			PInMrpPend(aReturn[1], Iif(lUsaEnv, oJsonData, oJsonRet), lReproc, cApi, aPend, cTipo, cUUID, lIntegra)
		EndIf

		//Alimenta os arrays aSuccess e aError
		If (aReturn[1] == 201 .Or. aReturn[1] == 207) .And. oJsonRet["items"] != Nil .And. Len(oJsonRet["items"]) > 0
			aSuccess := oJsonRet["items"]
		EndIf
		If aReturn[1] == 207 .And. oJsonRet["_messages"] != Nil .And. Len(oJsonRet["_messages"]) > 0
			aError := oJsonRet["_messages"]
		EndIf
		If (aReturn[1] == 400 .Or. aReturn[1] == 503)                     .And. ;
		   (oJsonRet["details"] != Nil .And. Len(oJsonRet["details"]) > 0 .Or.  ;
		   lUsaEnv .And. oJsonData["items"] != Nil)
			If lUsaEnv
				aError := oJsonData["items"]
				lAllError := .T.
			Else
				aError := oJsonRet["details"]
			EndIf
		EndIf
		If aReturn[1] == 204 .And. oJsonData["items"] != Nil .And. Len(oJsonData["items"]) > 0
			aSuccess := oJsonData["items"]
		EndIf
	EndIf

	FreeObj(oJsonRet)
	aSize(aPend, 0)
Return

/*/{Protheus.doc} PInMrpPend
Função responsável por deletar todos os registros da tabela T4R que tenham sido integrados com sucesso

@type Function
@author lucas.franca
@since 21/07/2021
@version P12
@param nCode   , Numeric  , código de retorno da API
@param oJsonRet, Character, Objeto Json que contém os registros para atulização
@param lReproc , logico   , Indica o status do registro. 1 = Pendente; 2 = Reprocesso com erro;
@param cApi    , Character, Nome da Api que gerou o registro
@param aPend   , Array    , Array com os dados de pendência para processamento.
@param cTipo   , Character, Indica o tipo do movimento. 1=Inclusão; 2=Exclusão.
@param cUUID   , Character, Identificador do processo do SCHEDULE. Utilizado para atualização de pendências.
@param lIntegra, logico   , Indica que foi realizado um processo de integração.
/*/
Function PInMrpPend(nCode, oJsonRet, lReproc, cApi, aPend, cTipo, cUUID, lIntegra)
	Local cAlias    := ""
	Local cQuery    := ""
	Local cProgOrig := ""
	Local cProg     := ""
	Local cHora     := ""
	Local cHoraOrig := Time()
	Local cReprHora := ""
	Local dData     := StoD("")
	Local dDataOrig := dDataBase
	Local dReprData := StoD("")
	Local lDelSuc   := .F.
	Local lUpdErr   := .F.
	Local lApiEst   := .F.
	Local nIndex    := 0
	Local nTotal    := Len(aPend)

	Default cUUID := ""

	//Carrega variáveis com tamanho dos campos
	cargaTam()
	cProgOrig := PadR(FunName(), _nTmProg)

	//Quando é a API de estoque e está executando via Schedule, apaga as pendências de processamento relacionadas independente do status;
	lApiEst := ("|"+AllTrim(Upper(cApi))+"|" $ "|MRPSTOCKBALANCE|MRPREJECTEDINVENTORY|" .And. !Empty(cUUID))

	// Apaga os registro da API de estrutura exceto quando for chamado pelo processo de sincronização.
	lNoUID := ("|"+AllTrim(Upper(cApi))+"|" $ "|MRPBILLOFMATERIAL|MRPPRODUCTINDICATOR|MRPPRODUCT|MRPBOMROUTING|MRPDEMANDS|MRPCALENDAR|MRPREJECTEDINVENTORY|";
	 .And. Empty(cUUID) .And. (lReproc .Or. lIntegra))

	If nCode == 201 .Or. nCode == 204 .Or. nCode == 207 .Or. lApiEst
		lDelSuc := .T.
	EndIf

	If nCode == 207 .Or. nCode == 400 .Or. nCode == 503 .Or. nCode == 0
		lUpdErr := .T.
	EndIf

	If lReproc
		cReprHora := Time()
		dReprData := dDataBase
	EndIf

	For nIndex := 1 To nTotal
		If lDelSuc .And. (aPend[nIndex][PEND_STATUS] == "1" .Or. lApiEst ) .And. (!Empty(cUUID) .Or. lNoUID)
			/*busca e deleta os registros integrados com sucesso*/
			delT4R(cApi, aPend[nIndex][PEND_CODIGO], cUUID)
		EndIf

		If lUpdErr .And. (aPend[nIndex][PEND_STATUS] == "2" .Or. aPend[nIndex][PEND_STATUS] == "3")
			/*
				aPend[nIndex][PEND_STATUS] == "2" - Erro de processamento. Elimina pendência atual e insere uma nova.
				aPend[nIndex][PEND_STATUS] == "3" - Erro de registro não encontrado em operação de delete, apaga da T4R
			*/

			//Restaura a data/hora do início do processo.
			dData := dDataOrig
			cHora := cHoraOrig
			cProg := cProgOrig

			//Primeiro deleta a T4R, e na sequencia faz nova inclusão.
			delT4R(cApi, aPend[nIndex][PEND_CODIGO], cUUID, @dData, @cHora, @cProg)

			//Se não for reprocessamento, atualiza data/hora/programa com os valores atuais.
			If !lReproc
				cProg := cProgOrig
				dData := dDataOrig
				cHora := cHoraOrig
			EndIf

			If aPend[nIndex][PEND_STATUS] == "2"
				insT4R(cApi,;
				       nCode,;
				       aPend[nIndex][PEND_CODIGO],;
				       aPend[nIndex][PEND_MSGRET],;
				       aPend[nIndex][PEND_ATRJSON],;
				       aPend[nIndex][PEND_POSICAO],;
				       cTipo,;
				       dReprData,;
				       cReprHora,;
				       dData,;
				       cHora,;
				       cProg,;
				       aPend[nIndex][PEND_MSGENV],;
				       oJsonRet)
			EndIf
		EndIf
	Next nIndex

	/*
		Se possuir o cUUID, significa que é uma execução via SCHEDULE.
		Neste caso, procura por registros de pendência do mesmo IDREG, onde o campo T4R_IDPRC está em branco.
		Se encontrar, irá excluir a pendência que está com o campo T4R_IDPRC preenchido, mantendo somente o registro
		que está com o T4R_IDPRC em branco.
	*/
	If !Empty(cUUID)
		cQuery := " SELECT T4R.R_E_C_N_O_ REC"
		cQuery +=   " FROM "  + RetSqlName("T4R") + " T4R"
		cQuery +=  " WHERE T4R.T4R_FILIAL = '" + xFilial("T4R") + "'"
		cQuery +=    " AND T4R.T4R_API    = '" + cApi + "'"
		cQuery +=    " AND T4R.T4R_IDPRC  = '" + cUUID + "'"
		cQuery +=    " AND T4R.D_E_L_E_T_ = ' '"
		cQuery +=    " AND EXISTS (SELECT 1"
		cQuery +=                  " FROM " + RetSqlName("T4R") + " T4RAUX"
		cQuery +=                 " WHERE T4RAUX.T4R_FILIAL = T4R.T4R_FILIAL"
		cQuery +=                   " AND T4RAUX.T4R_API    = T4R.T4R_API"
		cQuery +=                   " AND T4RAUX.T4R_IDPRC  = ' '"
		cQuery +=                   " AND T4RAUX.D_E_L_E_T_ = T4R.D_E_L_E_T_"
		cQuery +=                   " AND T4RAUX.T4R_IDREG  = T4R.T4R_IDREG)"

		//Verifica também pendências de estoque rejeitado não eliminadas, e elimina.
		If (AllTrim(Upper(cApi))+"|" $ "MRPREJECTEDINVENTORY|" .And. !Empty(cUUID))
			cQuery += " UNION"
			cQuery += " SELECT T4R.R_E_C_N_O_ REC"
			cQuery +=   " FROM " + RetSqlName("T4R") + " T4R"
			cQuery +=  " WHERE T4R.T4R_FILIAL = '" + xFilial("T4R") + "'"
			cQuery +=    " AND T4R.T4R_API    = '" + cApi + "'"
			cQuery +=    " AND T4R.T4R_IDPRC  = '" + cUUID + "'"
			cQuery +=    " AND T4R.D_E_L_E_T_ = ' '"
		EndIf

		cAlias := PCPAliasQr()

		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAlias,.F.,.F.)
		While (cAlias)->(!Eof())
			T4R->(dbGoTo((cAlias)->(REC)))

			RecLock("T4R", .F.)
				T4R->(dbDelete())
			T4R->(MsUnLock())

			(cAlias)->(dbSkip())
		End
		(cAlias)->(dbCloseArea())
	EndIf
Return

/*/{Protheus.doc} delT4R
Busca um registro da T4R e faz a deleção.

@type Static Function
@author lucas.franca
@since 21/07/2021
@version P12
@param 01 cApi  , Character, Nome da Api que gerou o registro
@param 02 cIdReg, Character, Identificador do registro
@param 03 cUUID , Character, Identificador do processo do SCHEDULE. Utilizado para atualização de pendências.
@param 04 dData , Date     , Retorna por referência a data original do registro deletado.
@param 05 cHora , Character, Retorna por referência a hora original do registro deletado.
@param 06 cProg , Character, Retorna por referência o programa original do registro deletado.
@Return Nil
/*/
Static Function delT4R(cAPI, cIDReg, cUUID, dData, cHora, cProg)
	Local cAlias := PCPAliasQr()
	Local cQuery := getQryT4R(cAPI, cIDReg, cUUID)

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAlias,.T.,.T.)
	If (cAlias)->(!Eof())
		T4R->(dbGoTo((cAlias)->(REC)))

		dData := T4R->T4R_DTENV
		cHora := T4R->T4R_HRENV
		cProg := T4R->T4R_PROG

		RecLock("T4R",.F.)
		T4R->(dbDelete())
		T4R->(MsUnLock())
	EndIf
	(cAlias)->(dbCloseArea())

Return

/*/{Protheus.doc} insT4R
Retorna query para buscar registro específico da T4R

@type  Static Function
@author lucas.franca
@since 22/07/2021
@version P12
@param 01 cApi     , Character, Código da API
@param 02 nCode    , Numeric  , Código de retorno da API
@param 03 cIdReg   , Character, Identificador do registro
@param 04 cMsgRet  , Character, Mensagem de retorno
@param 05 cAtrJson , Character, Atributo JSON para recuperar o json enviado
@param 06 nPosicao , Numeric  , Posição do registro no JSON enviado
@param 07 cTipo    , Character, Indica o tipo do movimento. 1=Inclusão; 2=Exclusão.
@param 08 dReprData, Date     , Data de reprocessamento quando executado via PCPA142
@param 09 cReprHora, Character, Hora de reprocessamento quando executado via PCPA142
@param 09 dData    , Date     , Data da geração da pendência
@param 10 cHora    , Character, Hora da geração da pendência
@param 11 cProg    , Character, Programa que gerou a pendência
@param 12 cJsonEnv , Character, JSON que foi enviado para o registro
@param 13 oJsonRet , Character, Objeto JSON com os dados
@return Nil
/*/
Static Function insT4R(cApi, nCode, cIdReg, cMsgRet, cAtrJson, nPosicao, cTipo, dReprData, cReprHora, dData, cHora, cProg, cJsonEnv, oJsonRet)
	Local cAlias     := PCPAliasQr()
	Local cT4RStatus := '1'
	Local cQuery     := getQryT4R(cApi, cIdReg, ' ')

	If !Empty(cReprHora)
		cT4RStatus := '2'
	EndIf

	If "|" + cApi + "|" $ '|MRPALLOCATIONS|MRPPRODUCTIONORDERS|MRPPURCHASEORDER|MRPPURCHASEREQUEST|'
		cT4RStatus := '4'
	EndIf

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAlias,.T.,.T.)
	If (cAlias)->(Eof())
		cAtrJson := AllTrim(cAtrJson)
		cApi     := PadR(cApi  , _nTmApi)
		cIdReg   := PadR(cIdReg, _nTmID)
		cMsgRet  := PadR(cMsgRet, _nTmMsgRet)
		//Se ocorreu erro durante a exclusão, e o erro ocorrido foi de não encontrar  o registro
		//Não gera pendência.
		If ! ((nCode == 207 .Or. nCode >= 400)                     .And. ;
		      ValType(oJsonRet[cAtrJson][nPosicao]["code"]) == "N" .And. ;
		      oJsonRet[cAtrJson][nPosicao]["code"] == 404)

			RecLock("T4R", .T.)
				T4R->T4R_FILIAL := xFilial("T4R")
				T4R->T4R_API    := cApi
				T4R->T4R_STATUS := cT4RStatus
				T4R->T4R_IDREG  := cIdReg
				T4R->T4R_DTENV  := dData
				T4R->T4R_HRENV  := cHora
				T4R->T4R_PROG   := cProg
				T4R->T4R_MSGRET := cMsgRet
				T4R->T4R_MSGENV := cJsonEnv
				T4R->T4R_HRREP  := cReprHora
				T4R->T4R_DTREP  := dReprData
				T4R->T4R_TIPO   := cTipo
			T4R->(MsUnLock())
		EndIf
	EndIf
	(cAlias)->(dbCloseArea())
Return

/*/{Protheus.doc} getQryT4R
Retorna query para buscar registro específico da T4R

@type  Static Function
@author lucas.franca
@since 22/07/2021
@version P12
@param 01 cApi  , Character, Código da API
@param 02 cIdReg, Character, Identificador do registro
@param 03 cUUID , Character, Identificador do processamento
@return cQuery, Character, Query para execução
/*/
Static Function getQryT4R(cApi, cIdReg, cUUID)
	Local cQuery := ""

	If _oStmtT4R == Nil
		_oStmtT4R := FWPreparedStatement():New()

		cQuery := "SELECT R_E_C_N_O_ REC "
		cQuery +=  " FROM " + RetSqlName("T4R")
		cQuery += " WHERE D_E_L_E_T_ = ' ' "
		cQuery +=   " AND T4R_FILIAL = '" + xFilial("T4R") + "' "
		cQuery +=   " AND T4R_API    = ? "
		cQuery +=   " AND T4R_IDREG  = ? "
		cQuery +=   " AND T4R_IDPRC  = ? "

		_oStmtT4R:SetQuery(cQuery)
	EndIf

	_oStmtT4R:SetString(1, cApi)
	_oStmtT4R:SetString(2, cIdReg)
	_oStmtT4R:SetString(3, cUUID)

	cQuery := _oStmtT4R:GetFixQuery()
Return cQuery

/*/{Protheus.doc} arrayPend
Função responsável por criar o array com os dados que serão utilizados para atualização de pendências.

@type  Static Function
@author lucas.franca
@since 21/07/2021
@version P12
@param aPend    , Array    , Array retornado por referência com os dados de pendências.
@param oDados   , Object   , Objeto JSON com os dados que serão processados.
@param lError   , Logic    , Indica se os dados devem ser considerados todos como erro.
@param cApi     , Character, API que está sendo processada.
@param oDadosEnv, Object   , Dados que foram enviados para a API
@param lUsaEnv  , Logic    , Retorna por referência se deve utilizar os dados que foram enviados para incluir pendências
@return Nil
/*/
Static Function arrayPend(aPend, oDados, lError, cApi, oDadosEnv, lUsaEnv)
	Local aNewPend := Array(PEND_TAMANHO)
	Local cCode    := ""
	Local cStatus  := "1"
	Local cMessage := ""
	Local mJsonEnv := ""
	Local nIndex   := 0
	Local nTotal   := 0

	lUsaEnv := .F.

	//Limpa os registros que estão no array
	aSize(aPend, 0)

	//Monta o array com os dados para geração de pendencias.
	If oDados["items"] != Nil
		nTotal := Len(oDados["items"])
		If lError
			cStatus  := "2"
			cMessage := STR0001 //"Não foi possível interpretar a mensagem retornada pela API, todos os items foram registrados como pendência de integração."
		Else
			cStatus  := "1"
			cMessage := ""
			mJsonEnv := ""
		EndIf
		For nIndex := 1 To nTotal
			If lError
				mJsonEnv := oDados["items"][nIndex]:ToJson()
			EndIf
			If !lError .And. cApi == "MRPSTOCKBALANCE" .And. oDados["items"][nIndex]["code"] == Nil
				//Tratativa para o método CLEAR da api MRPSTOCKBALANCE, para não apagar as pendências neste momento.
				Loop
			EndIf
			cCode := getCode(oDados["items"][nIndex], cApi)

			aNewPend[PEND_CODIGO ] := PadR(cCode   , _nTmID    )
			aNewPend[PEND_STATUS ] := PadR(cStatus , _nTmStatus)
			aNewPend[PEND_ATRJSON] := PadR("items" , _nTmAtrJsn)
			aNewPend[PEND_POSICAO] := nIndex
			aNewPend[PEND_MSGRET ] := PadR(cMessage, _nTmMsgRet)
			aNewPend[PEND_MSGENV ] := mJsonEnv
			aAdd(aPend, aClone(aNewPend))
		Next nIndex
	EndIf

	If oDados["_messages"] != Nil
		nTotal  := Len(oDados["_messages"])
		cStatus := "2"
		For nIndex := 1 To nTotal
			cMessage := oDados["_messages"][nIndex]["message"]
			mJsonEnv := oDados["_messages"][nIndex]["detailedMessage"]:ToJson()
			cCode    := getCode(oDados["_messages"][nIndex]["detailedMessage"], cApi)
			If oDados["_messages"][nIndex]["code"] == 404
				cStatus := "3"
			Else
				cStatus := "2"
			EndIf

			aNewPend[PEND_CODIGO ] := PadR(cCode      , _nTmID    )
			aNewPend[PEND_STATUS ] := PadR(cStatus    , _nTmStatus)
			aNewPend[PEND_ATRJSON] := PadR("_messages", _nTmAtrJsn)
			aNewPend[PEND_POSICAO] := nIndex
			aNewPend[PEND_MSGRET ] := PadR(cMessage   , _nTmMsgRet)
			aNewPend[PEND_MSGENV ] := mJsonEnv
			aAdd(aPend, aClone(aNewPend))
		Next nIndex
	EndIf

	If oDados["details"] != Nil
		nTotal  := Len(oDados["details"])
		cStatus := "2"
		For nIndex := 1 To nTotal
			cMessage := oDados["details"][nIndex]["message"]
			mJsonEnv := oDados["details"][nIndex]["detailedMessage"]:ToJson()
			cCode    := getCode(oDados["details"][nIndex]["detailedMessage"], cApi)
			If oDados["details"][nIndex]["code"] == 404
				cStatus := "3"
			Else
				cStatus := "2"
			EndIf

			aNewPend[PEND_CODIGO ] := PadR(cCode    , _nTmID    )
			aNewPend[PEND_STATUS ] := PadR(cStatus  , _nTmStatus)
			aNewPend[PEND_ATRJSON] := PadR("details", _nTmAtrJsn)
			aNewPend[PEND_POSICAO] := nIndex
			aNewPend[PEND_MSGRET ] := PadR(cMessage , _nTmMsgRet)
			aNewPend[PEND_MSGENV ] := mJsonEnv
			aAdd(aPend, aClone(aNewPend))
		Next nIndex
	EndIf

	//Verifica se ocorreu algum erro onde não retornou os dados processados.
	If !lError               .And. ;
	   Len(aPend) == 0       .And. ;
	   oDados["code"] != Nil .And. ;
	   oDados["code"] == 400 .And. ;
	   oDadosEnv != Nil      .And. ;
	   oDadosEnv["items"] != Nil

		//Adiciona como pendência todos os dados que foram enviados.
		nTotal := Len(oDadosEnv["items"])
		cStatus  := "2"
		cMessage := oDados["detailedMessage"]
		mJsonEnv := ""

		For nIndex := 1 To nTotal
			mJsonEnv := oDadosEnv["items"][nIndex]:ToJson()

			cCode := getCode(oDadosEnv["items"][nIndex], cApi)

			aNewPend[PEND_CODIGO ] := PadR(cCode   , _nTmID    )
			aNewPend[PEND_STATUS ] := PadR(cStatus , _nTmStatus)
			aNewPend[PEND_ATRJSON] := PadR("items" , _nTmAtrJsn)
			aNewPend[PEND_POSICAO] := nIndex
			aNewPend[PEND_MSGRET ] := PadR(cMessage, _nTmMsgRet)
			aNewPend[PEND_MSGENV ] := mJsonEnv
			aAdd(aPend, aClone(aNewPend))
		Next nIndex

		If nTotal > 0
			lUsaEnv := .T.
		EndIf

	EndIf

	aSize(aNewPend, 0)

Return Nil

/*/{Protheus.doc} getCode
Identifica qual é o código que deve ser utilizado para gerar a pendência

@type  Static Function
@author lucas.franca
@since 16/07/2019
@version P12.1.27
@param oData, Object   , Objeto JSON com os dados
@param cApi , Character, Código da API
@return cCode, Character, Código para gerar a pendência
/*/
Static Function getCode(oData, cApi)
	Local cCode := ""

	If cApi == "MRPBILLOFMATERIAL"
		cCode := oData["branchId"] + oData["product"]
	ElseIf cApi == "MRPSTOCKBALANCE" .And. oData["code"] == Nil
		cCode := oData["branchId"] + oData["product"] + oData["warehouse"]
	Else
		cCode := oData["code"]
	EndIf
Return cCode

/*/{Protheus.doc} cargaTam
Função que carrega as variáveis de escopo STATIC com o tamanho dos campos utilizados neste fonte.

@type  Static Function
@author lucas.franca
@since 25/06/2019
@version P12.1.27
/*/
Static Function cargaTam()
	If !_lTamLoad
		_nTmFil    := FwSizeFilial()
		_nTmApi    := GetSx3Cache("T4P_API"   ,"X3_TAMANHO")
		_nTmStatus := GetSx3Cache("T4R_STATUS","X3_TAMANHO")
		_nTmID     := GetSx3Cache("T4R_IDREG" ,"X3_TAMANHO")
		_nTmProg   := GetSx3Cache("T4R_PROG"  ,"X3_TAMANHO")
		_nTmMsgRet := GetSx3Cache("T4R_MSGRET","X3_TAMANHO")
		_lTamLoad  := .T.
	EndIf
Return

/*/{Protheus.doc} MRPVldSync
Verifica se é necessário executar a sincronização para alguma API, de acordo com o conteúdo do campo T4P_ALTER.

@type  Static Function
@author lucas.franca
@since 25/06/2019
@version P12.1.27
@param lExibeHelp, logico  , Identifica se deve ser exibido a mensagem de alerta.
@param cCodAPI   , caracter, código da API para sincronizar
@param lBtnSincr , logico  , não é mais utilizado (matido por compatibilidade)
@param lMrp      , logico  , Identifica que a chamada da função é feita pelo PCPA712
@param cTicket   , caracter, Número do ticket do MRP
@param lCanStart , logico  , Retorna por referência se pode iniciar a execução do MRP ou não
@return aApiAlter, Array   , Array com os códigos de API que necessitam de sincronização.
/*/
Function MRPVldSync(lExibeHelp, cCodAPI, lBtnSincr, lMRp, cTicket, lCanStart)
	Local aApiAlter := {}
	Local cAlias    := ""
	Local cMessage  := ""
	Local cQuery    := ""
	Local cUpdate   := ""
	Local nIndex    := 0
	Local oDescri   := Nil
	Local nMrpSinc  := SuperGetMV("MV_MRPSINC", .F., 1)
	Local lAlterada := .F.
	Local lInativa  := .F.

	Default lMRp      := .F.
	Default cTicket   := ""

	//Se a integração estiver ligada, faz a verificação.
	If IntNewMRP("MRPDEMANDS")

		//Verifica necessidade de sincronização da API MrpDemands referente inclusão de novo campo - T4J_CODE
		If !Empty(GetSx3Cache("T4J_CODE" ,"X3_TAMANHO"))
			cUpdate := " UPDATE " + RetSqlName("T4P")         + ;
			           " SET T4P_ALTER = '2' "                + ;
			           " WHERE   (D_E_L_E_T_ = ' ')  "        + ;
					       " AND (T4P_ALTER = '0') "          + ;
					       " AND (T4P_API = 'MRPDEMANDS') "   + ;
						   " AND ((SELECT COUNT(*) AS QTD "   + ;
						         " FROM " + RetSqlName("T4J") + ;
						         " WHERE (D_E_L_E_T_ = ' ') " + ;
								   " AND (T4J_CODE = ' ')) > 0) "
			TcSqlExec(cUpdate)
		EndIf

		cAlias := PCPAliasQr()
		cQuery := " SELECT DISTINCT T4P.T4P_API, T4P.T4P_ALTER "
		cQuery +=   " FROM " + RetSqlName("T4P") + " T4P "
		cQuery +=  " WHERE T4P.T4P_FILIAL = '" + xFilial("T4P") + "' "
		cQuery +=    " AND T4P.D_E_L_E_T_ = ' ' "
		cQuery += " AND T4P.T4P_API NOT IN ('MRPTRANSPORTINGLANES','MRPWAREHOUSEGROUP') "

		If nMrpSinc <> 3 .Or. !lMRp
			cQuery += " AND T4P.T4P_ALTER  IN ('1','2') "
		EndIf

		If !Empty(cCodAPI)
			cQuery += " AND T4P.T4P_API = '" + cCodAPI + "' "
		EndIf

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)
		While (cAlias)->(!Eof())
			aAdd(aApiAlter, (cAlias)->(T4P_API))
			If (cAlias)->(T4P_ALTER) == "1"
				lInativa  := .T.
			ElseIf (cAlias)->(T4P_ALTER) == "2"
				lAlterada := .T.
			EndIf
			(cAlias)->(dbSkip())
		End
		(cAlias)->(dbCloseArea())

		If !lMrp .Or. nMrpSinc == 1 .OR. (lAlterada .AND. nMrpSinc == 2)
			If lExibeHelp .And. Len(aApiAlter) > 0
				oDescri := P139AllAPI()

				If lInativa
					cMessage := STR0007 //"A integração com o MRP esteve desativada por algum período. Para garantir a integridade das informações do MRP será necessário executar a sincronização das seguintes entidades: "
				ElseIf lAlterada
					cMessage := STR0039 //"Existem atualizações nas API's do MRP que requerem sincronização para garantir a integridade das informações. Será necessário executar a sincronização das seguintes entidades: "
				EndIf

				For nIndex := 1 To Len(aApiAlter)
					cMessage += CRLF
					If oDescri[AllTrim(aApiAlter[nIndex])] == Nil
						cMessage += " - " + PadR(AllTrim(aApiAlter[nIndex]), 35)
					Else
						cMessage += " - " + PadR(oDescri[AllTrim(aApiAlter[nIndex])], 35)
					EndIf
				Next nIndex

				Help(' ', 1,"Help" ,,AllTrim(cMessage), 1, 1, , , , , , {STR0045}) // "<b>Para executar o MRP realize as correções informadas e tente novamente!</b>"
				If isBlind()
					LogMsg('PCPIntMRP', 0, 0, 1, '', '', AllTrim(cMessage))
				EndIf
				lCanStart := .F.

				FreeObj(oDescri)
				oDescri := Nil
			EndIf
		EndIf

		If lMRp .And. Len(aApiAlter) > 0
			PCPA140(.F. ,aApiAlter ,.F., cTicket) //sincroniza todas as APIs identificadas
		EndIf

		If lExibeHelp .And. lCanStart
			infErrSinc()
		EndIf
	EndIf
Return aApiAlter

/*/{Protheus.doc} MRPVldTrig
Valida se a Trigger do MRP está configurada corretamente

@type  Function
@author brunno.costa
@since 07/08/2019
@version P12.1.28
@param 01 - lExibeHelp, lógico  , Identifica se deve ser exibido a mensagem de alerta.
@param 02 - cCodAPI   , caracter, código da API para validar/corrigir as triggers
@param 03 - lInstala  , lógico  , indica se deve realizar as correções nas triggers
@param 04 - oModel    , objeto  , objeto do modelo da PCPA139
@param 05 - lExecJob  , lógico  , Identifica se o usuário será questionado quanto a execução de schedules pendentes.
@param 06 - aQryCompl , array   , retorna por referência array com queryes complementares para execução InTTS
@param 07 - lReteste  , lógico  , indica se está sendo feito o RE-TESTE (chamada recursiva)
@param 08 - lSchdl    , lógico  , indica se está rodando em schedule
@param 09 - lReItg    , lógico  , indica se deve ser feita a integração das apis rodando em schedule
@param 10 - cTicket   , caracter, número do ticket em execução (usado no processamento das pendências pelo PCPA712)
@param 11 - lAbreTela , lógico  , retorna por referência se a tela pode ser aberta
@return lReturn, lógico, indica se a trigger relacionada a API está configurada corretamente
/*/
Function MRPVldTrig(lExibeHelp, cCodAPI, lInstala, oModel, lExecJob, aQryCompl, lReteste, lSchdl, lReItg, cTicket, lAbreTela)
	Local aAPI       := {}
	Local cAPI       := ""
	Local cError     := ""
	Local cFullError := ""
	Local cMessage   := ""
	Local cMsgDesTr  := ""
	Local cMsgparc   := ""
	Local lIntegra   := IntNewMRP("MRPDEMANDS")
	Local lOnline    := .F.
	Local lReturn    := .T.
	Local lTrigInco  := .F.
	Local lUpdAlt1   := .F.
	Local lUpdLocal  := aQryCompl == Nil
	Local lUsaModel  := oModel != Nil
	Local nIndChild  := 0
	Local nIndex     := 0
	Local oDescri    := Iif(lExibeHelp, P139AllAPI(), Nil)
	Local oMdlGrid   := Nil
	Local oMdlHwl    := Nil
	Local oPosMdlGrd := Nil
	Local oTrigger   := MRPTrigger():New()

	Default lExecJob   := .F.
	Default lExibeHelp := .T.
	Default lInstala   := .F.
	Default lReItg     := .F.
	Default lReteste   := .F.
	Default lSchdl     := .F.
	Default cTicket    := "000000"

	lAbreTela := .T.

	If lUsaModel
		oMdlGrid   := oModel:GetModel("T4PDETAIL")
		oMdlHwl    := oModel:GetModel("HWLMASTER")
		oPosMdlGrd := JsonObject():New()
		oTrigger:lNetChange := oModel:GetModel("HWLMASTER"):GetValue("HWL_NETCH") == "1"
	EndIf

	If lUpdLocal
		aQryCompl := {}
	EndIf

	aAPI := getAPIS(oMdlGrid, cCodAPI, @oPosMdlGrd)

	For nIndex := 1 To Len(aAPI)
		cAPI      := AllTrim(aAPI[nIndex])
		lTrigInco := .F.

		/*caso possua o posFixo #child, retira o mesmo para não influenciar em outros
		trechos de código, o #child é importante apenas apara o método MRPIniTrig*/
		nIndChild := At("#CHILD", cAPI)
		If nIndChild > 0
			cAPI := PadR(cAPI, nIndChild-1)
		EndIf

		If lUsaModel
			lIntegra := oMdlGrid:GetValue("T4P_ATIVO", 1) == "1"
			lOnline  := oMdlGrid:GetValue("T4P_TPEXEC", oPosMdlGrd[cAPI]) == "1"
		Else
			lIntegra := IntNewMRP(cAPI, @lOnline)
		EndIf

		MRPIniTrig(AllTrim(aAPI[nIndex]), oTrigger)

		//API Schedule e trigger desabilitada/desinstalada/desatualizada
		If lIntegra .AND. !lOnline .AND. (!oTrigger:isTriggerInstalled() .OR. !oTrigger:isTriggerUpdated())
			lTrigInco := .T.

			If lInstala
				If !oTrigger:installTrigger()   //Instala/atualiza a trigger.
					cError     += CRLF + CRLF + " - " + STR0021 + " '" + AllTrim(cAPI) + "'" //Erro na instalação da trigger
					cFullError += CRLF + CRLF + " - " + STR0021 + " '" + AllTrim(cAPI) + "': " + AllTrim(oTrigger:getError()) //Erro na instalação da trigger
					lReturn := .F.
				Else
					aAdd(aQryCompl, "UPDATE " + RetSqlName("T4P") + " SET T4P_ALTER = '1' WHERE D_E_L_E_T_ = ' ' AND T4P_API = '" + cAPI + "'")
				EndIf
			Else
				lReturn := .F.
			EndIf

		//API Online e trigger existente ou integração com MRP desabilitada e trigger existente
		ElseIf (!lIntegra .OR. lOnline) .AND. oTrigger:isTriggerInstalled()
			lTrigInco := .T.

			If lInstala
				If !oTrigger:uninstallTrigger()   //Desinstala a trigger.
					cError     += CRLF + CRLF + " - " + STR0022 + " '" + AllTrim(cAPI) + "'"//Erro na desinstalação da trigger
					cFullError += CRLF + CRLF + " - " + STR0021 + " '" + AllTrim(cAPI) + "': " + AllTrim(oTrigger:getError()) //Erro na instalação da trigger
					lReturn := .F.
				Else
					aAdd(aQryCompl, "UPDATE " + RetSqlName("T4P") + " SET T4P_ALTER = '1' WHERE D_E_L_E_T_ = ' ' AND T4P_API = '" + cAPI + "'")
				EndIf
			EndIf
		EndIf

		If lExibeHelp .And. lTrigInco
			cMsgparc += CRLF
			If oDescri[AllTrim(cAPI)] == Nil
				cMsgDesTr := AllTrim(cAPI)
			Else
				cMsgDesTr := oDescri[AllTrim(cAPI)]
			EndIf

			cMsgparc += PadR(" - " + cMsgDesTr + Iif(nIndChild > 0, " (" + oTrigger:cAlias + ")", ""), 30)
		EndIf

		If !lUsaModel
			If !lIntegra
				aAdd(aQryCompl, "UPDATE " + RetSqlName("T4P") + " SET T4P_ALTER = ' ' WHERE D_E_L_E_T_ = ' ' AND T4P_API = '" + cAPI + "'")
			ElseIf !lUpdAlt1
				lUpdAlt1 := .T.
				aAdd(aQryCompl, "UPDATE " + RetSqlName("T4P") + " SET T4P_ALTER = '1' WHERE D_E_L_E_T_ = ' ' AND T4P_ALTER = ' '")
			EndIf
		EndIf
	Next nIndex

	If lExibeHelp .AND. !lReturn
		lAbreTela := .F.

		If !lInstala
			cMessage := AllTrim(STR0023 + cMsgparc) //"Foram identificadas inconsistências na configuração da integração com o MRP das API's listadas abaixo. Acesse a rotina de Configuração do MRP (PCPA139) para executar a correção automática das inconsistências, a seguir realize a sincronização (PCPA140), para garantir a integridade das informações." +  CRLF + cMessage

			Help(' ', 1,"Help" ,,cMessage, 1, 1, , , , , , {STR0045}) // "<b>Para executar o MRP realize as correções informadas e tente novamente!</b>"
			If lSchdl
				LogMsg('PCPIntMRP', 0, 0, 1, '', '', cMessage)
			EndIf
		Else
			cMessage := AllTrim(STR0025) + AllTrim(cError) //"Foram identificadas falhas na configuração da integração com o MRP das API's e ocorreram erros que impediram a conclusão do processo de atualização para as API's: "

			Help(' ', 1,"Help" ,,cMessage + CRLF + CRLF + AllTrim(STR0027), 1, 1, , , , , , {STR0028}) //"Consulte 'console.log' para visualizar o erro completo." + "Entre em contato com o suporte."
			LogMsg('PCPIntMRP', 0, 0, 1, '', '', Replicate("-",70) + CHR(10) + AllTrim(STR0025 + CRLF + cFullError) + CHR(10) + Replicate("-",70))
		EndIf
	EndIf

	If lReturn .and. lUpdLocal
		For nIndex := 1 to Len(aQryCompl)
			TcSqlExec(aQryCompl[nIndex])
		Next
	EndIf

	// Processa pendencias da T4R
	If lAbreTela .And. lExecJob .And. cTicket <> "000000"
		lReturn := procSchdl(aAPI, lSchdl, @lAbreTela, cTicket, lReItg)
	EndIf

	//Destruir o objeto.
	oTrigger:Destroy()
	FreeObj(oTrigger)

	FreeObj(oDescri)
	oDescri := Nil

Return lReturn

/*/{Protheus.doc} MRPIniTrig
Inicia o objeto MRPTrigger com as configurações de cada tabela

@type  Function
@author lucas.franca
@since 14/08/2019
@version P12.1.28
@param 01 - cCodAPI , caracter, código da API para configurar o objeto oTrigger.
@param 02 - oTrigger, Object  , Instância do objeto MRPTrigger para reutilização. Se não enviado, será criada uma nova instância.
@return oTrigger, Object, Instância do objeto MRPTrigger configurado.
/*/
Function MRPIniTrig(cCodAPI, oTrigger)
	Local aIdRegCQ := {}
	Local aIdRegSC := {}
	Local aFldHZ8  := {}

	If _lVRREV == Nil
		_lVRRev   := GetSx3Cache("VR_REV", "X3_TAMANHO") > 0
	EndIf

	If oTrigger == Nil
		oTrigger := MRPTrigger():New()
	EndIf

	oTrigger:clear()  //Limpar os dados para verificar a trigger de outra tabela.

	Do Case
		Case cCodAPI == "MRPDEMANDS"
			aIdRegDem := {"VR_FILIAL","VR_CODIGO","VR_SEQUEN","VR_PROD","VR_DATA","VR_TIPO","VR_DOC","VR_QUANT","VR_LOCAL","VR_MOPC","VR_OPC","R_E_C_N_O_","VR_NRMRP"}
			If _lVRRev			
				aAdd(aIdRegDem, "VR_REV")
			EndIf
			oTrigger:configureTable("SVR","MRPDEMANDS",;
									aIdRegDem,;
									{"VR_FILIAL","VR_CODIGO","VR_SEQUEN"},.T.,,,,,{"VR_FILIAL","VR_PROD"},{})

		Case cCodAPI == "MRPPRODUCTIONVERSION"
			oTrigger:configureTable("SVC","MRPPRODUCTIONVERSION",;
			                       {"VC_FILIAL","VC_VERSAO","VC_PRODUTO","VC_DTINI","VC_DTFIM","VC_QTDDE","VC_QTDATE","VC_REV", "VC_ROTEIRO", "VC_LOCCONS"},;
			                       {"VC_FILIAL","VC_VERSAO","VC_PRODUTO"},.T.,,,,,{"VC_FILIAL","VC_PRODUTO"},{})

		Case cCodAPI == "MRPBILLOFMATERIAL"
			oTrigger:configureTable("SG1","MRPBILLOFMATERIAL",{},;
			                       {"G1_FILIAL","G1_COD"},.F.,,,,,{"G1_FILIAL","G1_COD"},{})

		Case cCodAPI == "MRPALLOCATIONS"
			oTrigger:configureTable("SD4","MRPALLOCATIONS",;
			                       {"D4_FILIAL","D4_COD","D4_OP","D4_OPORIG","D4_DATA","D4_TRT","D4_QUANT","D4_QSUSP","D4_LOCAL"},;
			                       {"R_E_C_N_O_"},.F.,,,,,{"D4_FILIAL","D4_COD"},{},.T., .T.)

		Case cCodAPI == "MRPPRODUCTIONORDERS"
			oTrigger:configureTable("SC2","MRPPRODUCTIONORDERS",;
			                       {"C2_FILIAL","C2_NUM","C2_ITEM","C2_SEQUEN","C2_SEQPAI","C2_ITEMGRD","C2_PRODUTO","C2_LOCAL","C2_QUANT",;
			                        "C2_QUJE","C2_PERDA","C2_DATPRI","C2_DATPRF","C2_DATRF","C2_MOPC","C2_OPC","C2_TPOP","C2_STATUS","R_E_C_N_O_"},;
			                       {"R_E_C_N_O_"},.F.,,,,,{"C2_FILIAL","C2_PRODUTO"},{},.T., .T.)

		Case cCodAPI == "MRPPURCHASEORDER"
		    //DMANSMARTSQUAD1-30175 - Inclusão C1_APROV na T4T
			dbSelectArea("T4T")
	    	If FieldPos("T4T_APROV") > 0
               aIdRegSC := {"C1_FILIAL","C1_NUM","C1_ITEM","C1_ITEMGRD","C1_PRODUTO","C1_OP","C1_DATPRF","C1_QUANT","C1_QUJE","C1_LOCAL","C1_TPOP","C1_RESIDUO","C1_APROV"}
			Else
			   aIdRegSC := {"C1_FILIAL","C1_NUM","C1_ITEM","C1_ITEMGRD","C1_PRODUTO","C1_OP","C1_DATPRF","C1_QUANT","C1_QUJE","C1_LOCAL","C1_TPOP","C1_RESIDUO"}
			EndIf
			oTrigger:configureTable("SC1","MRPPURCHASEORDER",;
			                       aIdRegSC,;
			                       {"R_E_C_N_O_"},.F.,,,,,{"C1_FILIAL","C1_PRODUTO"},{},.T., .T.)

		Case cCodAPI == "MRPPURCHASEREQUEST"
			oTrigger:configureTable("SC7","MRPPURCHASEREQUEST",;
			                       {"C7_FILIAL","C7_NUM","C7_ITEM","C7_ITEMGRD","C7_PRODUTO","C7_OP","C7_DATPRF","C7_QUANT","C7_QUJE","C7_LOCAL","C7_TPOP","C7_RESIDUO","C7_TIPO"},;
			                       {"R_E_C_N_O_"},.F.,,,,,{"C7_FILIAL","C7_PRODUTO"},{},.T., .T.)

		Case cCodAPI == "MRPSTOCKBALANCE"
			oTrigger:configureTable("SB2","MRPSTOCKBALANCE",;
			                       {"B2_FILIAL","B2_COD","B2_LOCAL","B2_QATU","B2_QNPT","B2_QTNP"},;
			                       {"B2_FILIAL","B2_COD","B2_LOCAL"},.F.,,,,,{"B2_FILIAL","B2_COD"},{},.T., .T.)

		Case cCodAPI == "MRPREJECTEDINVENTORY"
			aIdRegCQ := {"D7_FILIAL","D7_PRODUTO","D7_LOCDEST","D7_DATA"}

			If mrpLoteCQ()
				aAdd(aIdRegCQ, "D7_LOTECTL")
				aAdd(aIdRegCQ, "D7_NUMLOTE")
			EndIf

			oTrigger:configureTable("SD7","MRPREJECTEDINVENTORY", {},;
			                       aIdRegCQ,.F.,,,,,{"D7_FILIAL","D7_PRODUTO"},{})

			aSize(aIdRegCQ, 0)
		Case cCodAPI == "MRPCALENDAR"
			oTrigger:configureTable("SVZ","MRPCALENDAR",;
			                       {"VZ_FILIAL","VZ_CALEND","VZ_DATA","VZ_HORAINI","VZ_HORAFIM","VZ_INTERVA"},;
			                       {"VZ_FILIAL","VZ_CALEND","VZ_DATA"},.T.)

		Case cCodApi == "MRPPRODUCT"
			oTrigger:configureTable("SB1","MRPPRODUCT",;
			                        {"B1_FILIAL","B1_COD","B1_LOCPAD","B1_TIPO","B1_GRUPO","B1_QE","B1_EMIN","B1_ESTSEG","B1_PE","B1_TIPE","B1_LE",;
			                         "B1_LM","B1_TOLER","B1_TIPODEC","B1_RASTRO","B1_MRP","B1_REVATU","B1_EMAX","B1_PRODSBP","B1_LOTESBP","B1_ESTRORI",;
			                         "B1_APROPRI","B1_CPOTENC","B1_MSBLQL","B1_CONTRAT","B1_OPERPAD","B1_CCCUSTO","B1_DESC","B1_UM","B1_GRUPCOM",;
			                         "B1_OPC","B1_MOPC", "B1_QB"},;
			                        {"B1_FILIAL","B1_COD"},.F.,,,,,{"B1_FILIAL","B1_FILIAL"},{},.T.)

		Case cCodAPI == "MRPPRODUCT#CHILD"
			oTrigger:configureTable("SVK","MRPPRODUCT",;
			                        {"VK_FILIAL","VK_COD","VK_HORFIX","VK_TPHOFIX"},;
			                        {"VK_FILIAL","VK_COD"},.F.,/*cTabelaPai*/,/*aFieldsPai*/, /*aRelPai*/, .F.,{"VK_FILIAL","VK_COD"},{},.T.)

		Case cCodAPI == "MRPPRODUCT#CHILDSB5"
			oTrigger:configureTable("SB5","MRPPRODUCT",;
			                        {"B5_FILIAL","B5_COD","B5_LEADTR", "B5_AGLUMRP"},;
			                        {"B5_FILIAL","B5_COD"},.F.,/*cTabelaPai*/,/*aFieldsPai*/,/*aRelPai*/, .F.,{"B5_FILIAL","B5_COD"},{},.T.)

		Case cCodAPI == "MRPPRODUCT#CHILDHZ8" .And. possuiHZ8()
			aFldHZ8 := {"HZ8_FILIAL", "HZ8_PROD", "HZ8_LEADTR", "HZ8_TRANSF", "HZ8_FILCOM"}
			If GetSx3Cache("HZ8_LMTRAN","X3_TAMANHO") > 0
				aAdd(aFldHZ8, "HZ8_LMTRAN")
			EndIf
			oTrigger:configureTable("HZ8","MRPPRODUCT",;
			                        aFldHZ8,;
			                        {"HZ8_FILIAL", "HZ8_PROD"}, .F., /*cTabelaPai*/, /*aFieldsPai*/, /*aRelPai*/, .F.,{"HZ8_FILIAL", "HZ8_PROD"}, {}, .T.)

		Case cCodApi == "MRPPRODUCTINDICATOR"
			oTrigger:configureTable("SBZ","MRPPRODUCTINDICATOR",;
			                        {"BZ_FILIAL","BZ_COD","BZ_LOCPAD","BZ_QE","BZ_EMIN","BZ_ESTSEG","BZ_PE","BZ_TIPE","BZ_LE","BZ_LM","BZ_TOLER","BZ_MRP",;
			                         "BZ_REVATU","BZ_EMAX","BZ_HORFIX","BZ_TPHOFIX","BZ_OPC","BZ_MOPC", "BZ_QB"},;
			                        {"BZ_FILIAL","BZ_COD"},.F.,,,,,{"BZ_FILIAL","BZ_COD"},{},.T.)

		Case cCodApi == "MRPBOMROUTING"
			oTrigger:configureTable("SGF","MRPBOMROUTING", {}, {"GF_FILIAL","GF_PRODUTO","GF_ROTEIRO","GF_OPERAC"},.F.,,,,,{"GF_FILIAL","GF_PRODUTO"},{})

		Case cCodApi == "MRPWAREHOUSE"
			oTrigger:configureTable("NNR","MRPWAREHOUSE",;
			                       {"NNR_FILIAL","NNR_CODIGO","NNR_TIPO","NNR_MRP"},;
			                       {"NNR_FILIAL","NNR_CODIGO"},.T.)
	EndCase

Return oTrigger

/*/{Protheus.doc} PendSchedu
Verifica se existe alguma pendência de processamento
por schedule para uma API específica na tabela T4R

@type  Static Function
@author lucas.franca
@since 14/08/2019
@version P12.1.28
@param 01 cCodApi  , Character, Código da API para verificação
@param 02 aApisPend, Array    , Lista das APIs para processamento das pendências
@param 03 oApisPrc , Object   , JsonObject com os processamentos (T4R_IDPRC) que estão presos
@return   nQtdPend , Numeric  , Quantidade de pendências para a API
/*/
Static Function PendSchedu(cCodApi, aApisPend, oApisPrc)
	Local aPrcNames := oApisPrc:GetNames()
	Local cAliasQry := PCPAliasQr()
	Local cInPrcs   := ""
	Local cQuery    := ""
	Local nIndex    := 0
	Local nTotal    := 0
	Local nQtdPend  := 0

	cQuery := "SELECT Count(*) TOTAL"
	cQuery +=  " FROM " + RetSqlName("T4R") + " T4R"
	cQuery += " WHERE T4R.T4R_FILIAL = '" + xFilial("T4R") + "'"
	cQuery +=   " AND T4R.T4R_API    = '" + cCodApi + "'"
	cQuery +=   " AND T4R.D_E_L_E_T_ = ' '"

	If !(cCodApi $ "|MRPALLOCATIONS|MRPBILLOFMATERIAL|")
		cQuery += " AND T4R.T4R_STATUS = '3'"
	EndIf

	nTotal := Len(aPrcNames)
	For nIndex := 1 To nTotal
		If nIndex > 1
			cInPrcs += ", "
		EndIf

		cInPrcs += "'" + aPrcNames[nIndex] + "'"
	Next nIndex

	If !Empty(cInPrcs)
		cQuery += " AND T4R_IDPRC NOT IN (" + cInPrcs + ")"
	EndIf

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

	If (cAliasQry)->(!Eof()) .And. (cAliasQry)->TOTAL > 0
		nQtdPend := (cAliasQry)->TOTAL

		aAdd(aApisPend, Array(API_PEND_TAMANHO))
		nIndex := Len(aApisPend)
		aApisPend[nIndex][API_PEND_CODIGO     ] := cCodApi
		aApisPend[nIndex][API_PEND_QTD_TOTAL  ] := nQtdPend
		aApisPend[nIndex][API_PEND_STATUS     ] := "N/I"
		aApisPend[nIndex][API_PEND_MARCADOS   ] := Nil
		aApisPend[nIndex][API_PEND_PROCESSADOS] := 0
		aApisPend[nIndex][API_PEND_MSG_ERRO   ] := ""
	EndIf
	(cAliasQry)->(dbCloseArea())

Return nQtdPend

/*/{Protheus.doc} prcPendenc
Executa as pendências das APIs

@type Static Function
@author lucas.franca
@since 14/08/2019
@version P12.1.28
@param 01 aApisPend, Array   , Lista dsa APIs para processamento das pendências
@param 02 cTicket  , Caracter, Número do ticket do MRP
@return   lReturn  , Lógico  , Indica se foi iniciado com sucesso o processamento
/*/
Static Function prcPendenc(aApisPend, cTicket)
	Local cErrorUID := cTicket + "PCPA141ERR"
	Local cRecover  := ""
	Local lReturn   := .T.
	Local nIndex    := 0
	Local nTotal    := Len(aApisPend)
	Local oPCPError := Nil

	If nTotal > 0
		P141IniGlb(cTicket)

		//Abre uma thread para cada API
		oPCPError := PCPMultiThreadError():New(cErrorUID, .F.)
		For nIndex := 1 To nTotal
			aApisPend[nIndex][API_PEND_STATUS] := "INI"
			P141SetGlb(cTicket, aApisPend[nIndex][API_PEND_CODIGO], aApisPend[nIndex])

			//Caso ocorra erro na thread, deve setar a global para 'ERRO' quando o processamento é via PCPA712
			If cTicket <> "000000"
				cRecover := "{|| P141SetGlb('" + cTicket + "', '" + aApisPend[nIndex][API_PEND_CODIGO] + "', " + ;
				                            "{'" + aApisPend[nIndex][API_PEND_CODIGO]                  + "', " + ;
				                                   cValToChar(aApisPend[nIndex][API_PEND_QTD_TOTAL])   + ", "  + ;
				                                   "'ERRO', 0, 0, '" + STR0011 + "'})}" //"Ocorreu um erro ao iniciar o processamento das pendências."
			EndIf

			oPCPError:startJob("PCPA141RUN", getEnvServer(), .F., cEmpAnt, cFilAnt, ;
							   aApisPend[nIndex][API_PEND_CODIGO]                 , ;
							   aApisPend[nIndex][API_PEND_QTD_TOTAL]              , ;
							   cTicket, , , , , , , , , cRecover)
		Next nIndex
	EndIf

Return lReturn

/*/{Protheus.doc} updDemands
Atualiza a tabela de demandas do ERP com o número da execução do MRP

@type Function
@author renan.roeder
@since 06/03/2020
@version P12.1.28
@param cNrMrp, Caracter , String com o número da execução do MRP
@return Nil
/*/
Function updDemands(cNrMrp)
	Local aDemands := {}
	Local aFiltro  := {}
	Local aResult  := {}
	Local cErro    := ""
	Local cUpdate  := ""
	Local cWhere   := ""
	Local lRet     := .T.
	Local lNext    := .T.
	Local nPage    := 1
	Local nSize    := 1000
	Local nX       := 0
	Local nTamCod  := GetSx3Cache("VR_CODIGO","X3_TAMANHO")
	Local nTamFil  := GetSx3Cache("VR_FILIAL","X3_TAMANHO")
	Local nTamSeq  := GetSx3Cache("VR_SEQUEN","X3_TAMANHO")
	Local oJsonDem := JsonObject():New()

	While lNext
		aAdd(aFiltro, {"ticket", cNrMrp})
		aResult := MrpDemGAll(aFiltro,,nPage,nSize)

		If !aResult[1]
			lNext := .F.
			If aResult[3] == 404
				lRet := .T.
			Else
				lRet := .F.
			EndIf
		Else
			cErro   := oJsonDem:FromJson(aResult[2])
			If Empty(cErro)
				aDemands := oJsonDem["items"]
				For nX := 1 To Len(aDemands)
					cWhere := "VR_FILIAL = '"+SubStr(aDemands[nX]["code"],1,nTamFil)+"' AND VR_CODIGO = '"+SubStr(aDemands[nX]["code"],nTamFil+1,nTamCod)+"' AND VR_SEQUEN = "+SubStr(aDemands[nX]["code"],nTamFil+nTamCod+1,nTamSeq)+" AND D_E_L_E_T_ = ' '"
					cUpdate := "UPDATE " +RetSqlName("SVR")+ " SET VR_NRMRP = '"+cNrMrp+"' WHERE " + cWhere
					If TcSqlExec(cUpdate) < 0
						lRet  := .F.
						lNext := .F.
						Exit
					EndIf
				Next nX
				If !oJsonDem["hasNext"]
					lNext := .F.
				Else
					If lRet
						nPage++
					EndIf
				EndIf
			Else
				lRet  := .F.
				lNext := .F.
			EndIf
		EndIf
	EndDo

Return lRet

/*/{Protheus.doc} VldTblComp
Valida se o compartilhamento das tabelas do erp está igual as tabelas do mrp.

@type Function
@author renan.roeder
@since 17/07/2020
@version P12.1.31
@return lRet, Logical, Retorna .T. se as tabelas estão compativeis.
/*/
Function VldTblComp()
	Local aIncons    := {}
	Local cMessagePr := ""
	Local cMessageSo := ""
	Local lRet       := .T.
	Local nX         := 0
	Local nLenIncons := 0

	aIncons := VCoMRPxERP()

	nLenIncons := Len(aIncons)
	If nLenIncons > 0
		lRet := .F.

		cMessagePr := STR0040        //"Foram identificadas inconsistências em relação ao modo de compartilhamento das tabelas do ERP com as tabelas do MRP. "
		cMessageSo := STR0041 + CRLF //"As seguintes tabelas devem ter seu modo de compartilhamento ajustado: "

		For nX := 1 To nLenIncons
			cMessageSo += CRLF
			cMessageSo += aIncons[nX][1][1] + " - " + aIncons[nX][2][1] + " - " + AllTrim(FWX2Nome(aIncons[nX][1][1]))
		Next nIndex

		Help(' ', 1,"Help" ,,cMessagePr, 1, 1, , , , , , {cMessageSo})
	EndIf

Return lRet

/*/{Protheus.doc} VCoMRPxERP
Identifica compartilhamento das tabelas do MRP diferentes das correspondentes tabelas do ERP.

@type Function
@author parffit.silva
@since 14/05/2021
@version P12.1.33
@return aIncons, Array, Tabelas do MRP com compartilhamento diferente das correspondentes tabelas do ERP
						aIncons[1][1][1] = Tabela ERP
						aIncons[1][1][2] = Compartilhamento Empresa Tabela ERP
						aIncons[1][1][3] = Compartilhamento Unidade de Negócio Tabela ERP
						aIncons[1][1][4] = Compartilhamento Filial Tabela ERP
						aIncons[1][2][1] = Tabela MRP
						aIncons[1][2][2] = Compartilhamento Empresa Tabela MRP
						aIncons[1][2][3] = Compartilhamento Unidade de Negócio Tabela MRP
						aIncons[1][2][4] = Compartilhamento Filial Tabela MRP
/*/
Function VCoMRPxERP()
	Local aTabelas   := {}
	Local aIncons    := {}
	Local cModEmpErp := ""
	Local cModUniErp := ""
	Local cModFilErp := ""
	Local cModEmpMrp := ""
	Local cModUniMrp := ""
	Local cModFilMrp := ""
	Local nIncons    := 0

	aTabelas := { {"SVX","HW0"},;
				  {"SB1","HWA"},;
				  {"SVB","T4J"},;
				  {"SD4","T4S"},;
				  {"SG1","T4N"},;
				  {"SC2","T4Q"},;
				  {"SVC","T4M"},;
				  {"SC1","T4T"},;
				  {"SC7","T4U"},;
				  {"SB2","T4V"},;
				  {"SBZ","HWE"},;
				  {"SGF","HW9"},;
				  {"NNR","HWY"},;
				  {"T4N","T4O"},;
				  {"SB5","SMI"}	}

	For nIncons := 1 To Len(aTabelas)
		If !AliasInDic(aTabelas[nIncons][2])
			Loop
		EndIf

		cModEmpErp := FWModeAccess(aTabelas[nIncons,1],1)
		cModUniErp := FWModeAccess(aTabelas[nIncons,1],2)
		cModFilErp := FWModeAccess(aTabelas[nIncons,1],3)

		cModEmpMrp := FWModeAccess(aTabelas[nIncons,2],1)
		cModUniMrp := FWModeAccess(aTabelas[nIncons,2],2)
		cModFilMrp := FWModeAccess(aTabelas[nIncons,2],3)

		If cModEmpErp != cModEmpMrp .Or. cModUniErp != cModUniMrp .Or. cModFilErp != cModFilMrp
			aAdd(aIncons,{{aTabelas[nIncons,1],cModEmpErp,cModUniErp,cModFilErp},{aTabelas[nIncons,2],cModEmpMrp,cModUniMrp,cModFilMrp}})
		EndIf
	Next nIncons

Return aIncons

/*/{Protheus.doc} VldCampTam
Valida se o tamanho dos campos numericos das tabelas do ERP estão compatíveis com os
campos correspondentes das tabelas do MRP.

@type Function
@author renan.roeder
@since 02/08/2020
@version P12.1.31
@return Array, Array, [1] Mensagem de inconsistências [2] Quantidade de Campos validados com sucesso [3] Quantidade de Campos com diferença no tamanho.
/*/
Function VldCampTam()
	Local aIncons    := {}
	Local cAviso     := ""
	Local nIndIncons := 0
	Private nSuc     := 0
	Private nErr     := 0

	aIncons := VCpMRPxERP()

	If Len(aIncons)
		For nIndIncons := 1 To Len(aIncons)
			cAviso += CHR(10)
			//STR0042 "Campo " STR0043 " da tabela " STR0044 " deve ter tamanho "
			cAviso += STR0042 + aIncons[nIndIncons][2] + STR0043 + aIncons[nIndIncons][1] + STR0044 + AllTrim(STR(aIncons[nIndIncons][3])) + IIF(aIncons[nIndIncons][4] > 0, "," + AllTrim(STR(aIncons[nIndIncons][4])),"") + Space(50)
		Next nIndIncons
	EndIf

Return {cAviso,nSuc,nErr}

/*/{Protheus.doc} ArrValMRP
Monta o array com os campos a serem validados para a integração com o MRP.
@type Static Function
@author renan.roeder
@since 02/08/2020
@version P12.1.31
@return aCampos, Array, Array com os campos as serem validados.
/*/
Static Function ArrValMRP()
	Local aCampos   := {}
	Local aOpc      := {}
	Local lT4TAprov := .F.
	Local nIndex    := 0
	Local nPosMaior := 1

	//DMANSMARTSQUAD1-30175 - Inclusão C1_APROV na T4T
	dbSelectArea("T4T")
	lT4TAprov := FieldPos("T4T_APROV") > 0

	aOpc := {{"SC2", "C2_OPC", TamSX3("C2_OPC")[1]},;
			 {"SVR", "VR_OPC", TamSX3("VR_OPC")[1]},;
			 {"SB1", "B1_OPC", TamSX3("B1_OPC")[1]},;
			 {"SBZ", "BZ_OPC", TamSX3("BZ_OPC")[1]};
	}

	For nIndex := 2 To Len(aOpc)
		If aOpc[nIndex][3] > aOpc[nPosMaior][3]
			nPosMaior := nIndex
		EndIf
	Next

	aCampos := {  {{"SB1",{"B1_EMAX","B1_EMIN","B1_ESTSEG","B1_LE","B1_LM","B1_LOTESBP","B1_PE","B1_QE","B1_TOLER","B1_DESC","B1_UM", "B1_OPC", "B1_QB"}},{"HWA",{"HWA_EMAX","HWA_EMIN","HWA_ESTSEG","HWA_LE","HWA_LM","HWA_LOTSBP","HWA_PE","HWA_QE","HWA_TOLER","HWA_DESC","HWA_UM", "HWA_ERPOPC", "HWA_QB"}},"=="},;
				  {{"SVK",{"VK_HORFIX"}}                                                                                                                 ,{"HWA",{"HWA_HORFIX"}},"=="},;
				  {{"SAJ",{"AJ_DESC"}}                                                                                                                   ,{"HWA",{"HWA_GCDESC"}},"=="},;
				  {{"SBZ",{"BZ_EMAX","BZ_EMIN","BZ_ESTSEG","BZ_LE","BZ_LM","BZ_HORFIX","BZ_PE","BZ_QE","BZ_TOLER", "BZ_OPC", "BZ_QB"}}                   ,{"HWE",{"HWE_EMAX","HWE_EMIN","HWE_ESTSEG","HWE_LE","HWE_LM","HWE_HORFIX","HWE_PE","HWE_QE","HWE_TOLER", "HWE_ERPOPC", "HWE_QB"}},"=="},;
				  {{"SB2",{"B2_QATU"}}                                                                                                                   ,{"HWC",{"HWC_QTBXES"}},"=="},;
				  {{"SVJ",{"VJ_QUANT"}}                                                                                                                  ,{"HWC",{"HWC_QTSUBS"}},"=="},;
				  {{"SD4",{"D4_QUANT"}}                                                                                                                  ,{"HWC",{"HWC_QTEMPE"}},"=="},;
				  {{"SB2",{"B2_LOCAL"}}                                                                                                                  ,{"HWC",{"HWC_LOCAL"}},"<="},;
				  {{"SD4",{"D4_QUANT"}}                                                                                                                  ,{"HWG",{"HWG_QTEMPE"}},"<="},;
				  {{"SD7",{"D7_QTDE"}}                                                                                                                   ,{"HWX",{"HWX_QTDE"}},"=="},;
				  {{"SD2",{"D2_QUANT"}}                                                                                                                  ,{"HWX",{"HWX_QTDEV"}},"=="},;
				  {{"SB2",{"B2_LOCAL"}}                                                                                                                  ,{"HWX",{"HWX_LOCAL"}},"<="},;
				  {{"SVQ",{"VQ_QNTINI","VQ_QNTFIM"}}                                                                                                     ,{"HW5",{"HW5_QTDINI","HW5_QTDFIN"}},"=="},;
				  {{"SB2",{"B2_LOCAL"}}                                                                                                                  ,{"HW6",{"HW6_LOCAL"}},"<="},;
				  {{"SVR",{"VR_QUANT","VR_OPC"}}                                                                                                         ,{"T4J",{"T4J_QUANT","T4J_ERPOPC"}},"=="},;
				  {{"SB2",{"B2_LOCAL"}}                                                                                                                  ,{"T4J",{"T4J_LOCAL"}},"<="},;
				  {{"SVC",{"VC_QTDDE","VC_QTDATE"}}                                                                                                      ,{"T4M",{"T4M_QNTDE","T4M_QNTATE"}},"=="},;
				  {{"SG1",{"G1_QUANT","G1_PERDA","G1_POTENCI"}}                                                                                          ,{"T4N",{"T4N_QTD","T4N_PERDA","T4N_POTEN"}},"=="},;
				  {{"SB1",{"B1_QB"}}                                                                                                                     ,{"T4N",{"T4N_QTDB"}},"=="},;
				  {{"SGI",{"GI_FATOR"}}                                                                                                                  ,{"T4O",{"T4O_FATCON"}},"=="},;
				  {{"SC2",{"C2_QUANT","C2_QUJE","C2_OPC"}}                                                                                               ,{"T4Q",{"T4Q_QUANT","T4Q_SALDO","T4Q_ERPOPC"}},"=="},;
				  {{aOpc[nPosMaior][1], {aOpc[nPosMaior][2]}}                                                                                            ,{"HWD",{"HWD_ERPOPC"}},"=="},;
				  {{"SB2",{"B2_LOCAL"}}                                                                                                                  ,{"T4Q",{"T4Q_LOCAL"}},"<="},;
				  {{"SD4",{"D4_QUANT","D4_QSUSP"}}                                                                                                       ,{"T4S",{"T4S_QTD","T4S_QSUSP"}},"=="},;
				  {{"SB2",{"B2_LOCAL"}}                                                                                                                  ,{"T4S",{"T4S_LOCAL"}},"<="},;
				  {{"SC1",{"C1_QUANT","C1_QUJE"}}                                                                                                        ,{"T4T",{"T4T_QTD","T4T_QUJE"}},"=="},;
				  {{"SB2",{"B2_LOCAL"}}                                                                                                                  ,{"T4T",{"T4T_LOCAL"}},"<="},;
				  {{"SC7",{"C7_QUANT","C7_QUJE"}}                                                                                                        ,{"T4U",{"T4U_QTD","T4U_QUJE"}},"=="},;
				  {{"SB2",{"B2_LOCAL"}}                                                                                                                  ,{"T4U",{"T4U_LOCAL"}},"<="},;
				  {{"SB2",{"B2_QATU","B2_QNPT","B2_QTNP","B2_QATU"}}                                                                                     ,{"T4V",{"T4V_QTD","T4V_QNPT","T4V_QTNP","T4V_QTIND"}},"=="},;
				  {{"SB8",{"B8_LOTECTL","B8_NUMLOTE"}}                                                                                                   ,{"T4V",{"T4V_LOTE","T4V_SLOTE"}},"=="},;
				  {{"SB8",{"B8_LOTECTL","B8_NUMLOTE"}}                                                                                                   ,{"SME",{"ME_LOTE","ME_SLOTE"}},"=="},;
				  {{"SB8",{"B8_LOTECTL","B8_NUMLOTE"}}                                                                                                   ,{"SMH",{"MH_LOTE","MH_SLOTE"}},"=="},;
				  {{"SDD",{"DD_SALDO"}}                                                                                                                  ,{"T4V",{"T4V_SLDBQ"}},"=="},;
				  {{"SB2",{"B2_LOCAL"}}                                                                                                                  ,{"T4V",{"T4V_LOCAL"}},"<="},;
				  {{"SB5",{"B5_LEADTR", "B5_AGLUMRP"}}                                                                                                   ,{"SMI",{"MI_LEADTR", "MI_AGLUMRP"}},"=="};
				}

	//DMANSMARTSQUAD1-30175 - Inclusão C1_APROV na T4T
    	If lT4TAprov
		aAdd(aCampos,{{"SC1",{"C1_APROV"}}                                                                                                        ,{"T4T",{"T4T_APROV"}},"=="})
	EndIf

	If mrpGrdT4T()
		aAdd(aCampos,{{"SC1",{"C1_ITEMGRD"}} , {"T4T",{"T4T_ITGRD"}},"=="})
		aAdd(aCampos,{{"SC7",{"C7_ITEMGRD"}} , {"T4U",{"T4U_ITGRD"}},"=="})
	EndIf

Return aCampos


/*/{Protheus.doc} VCpMRPxERP
Identifica campos das tabelas do MRP com tamanhos diferentes dos correspondentes nas tabelas do ERP.

@type Function
@author parffit.silva
@since 14/05/2021
@version P12.1.33
@return aIncons, Array, Campos do MRP com tamanhos diferentes dos correspondentes nas tabelas do ERP
						aIncons[1][1] = Tabela Campo MRP
						aIncons[1][2] = Nome Campo MRP
						aIncons[1][3] = Tamanho Campo ERP
						aIncons[1][4] = Decimal Campo ERP
						aIncons[1][5] = Picture Campo ERP
/*/
Function VCpMRPxERP()
	Local aCampos    := {}
	Local aInfERP    := {}
	Local aInfMRP    := {}
	Local aIncons    := {}
	Local aInfC1     := {}
	Local aInfC2     := {}
	Local aInfT4T    := {}
	Local aInfT4U    := {}
	Local cValid     := ""
	Local cPictERP   := ""
	Local nIndCampos := 0
	Local nIndCmpTab := 0

	nErr := 0
	nSuc := 0

	aCampos := ArrValMRP()

	//OPENSXS()
	For nIndCampos := 1 To Len(aCampos)
		For nIndCmpTab := 1 To Len(aCampos[nIndCampos][ERP][CAMPOS])
			aInfERP   := TAMSX3(aCampos[nIndCampos][ERP][CAMPOS][nIndCmpTab])
			aInfMRP   := TAMSX3(aCampos[nIndCampos][MRP][CAMPOS][nIndCmpTab])
			cValid := "aInfERP["+STR(TAMANHO)+"] "+aCampos[nIndCampos][SINAL]+" aInfMRP["+STR(TAMANHO)+"] .And. aInfERP["+STR(DECIMAL)+"] "+aCampos[nIndCampos][SINAL]+" aInfMRP["+STR(DECIMAL)+"]
			If (Len(aInfERP) > 0 .And. Len(aInfMRP) > 0) .And. !(&cValid)
				cPictERP := X3Picture(aCampos[nIndCampos][ERP][CAMPOS][nIndCmpTab])
				aAdd(aIncons,{aCampos[nIndCampos][MRP][TABELA],aCampos[nIndCampos][MRP][CAMPOS][nIndCmpTab],aInfERP[TAMANHO],aInfERP[DECIMAL],cPictERP})
				nErr++
			Else
				nSuc++
			EndIf
		Next nIndCmpTab
	Next nIndCampos

	aInfC1   := TAMSX3("C1_QUANT")
	aInfC2   := TAMSX3("C2_QUANT")
	aInfMRP  := TAMSX3("HWC_QTNECE")

	If Len(aInfC1) > 0 .And. Len(aInfC2) > 0 .And. Len(aInfMRP) > 0 .And. ;
	   ((aInfC1[TAMANHO] > aInfMRP[TAMANHO] .Or. aInfC1[DECIMAL] > aInfMRP[DECIMAL]) .Or.;
	    (aInfC2[TAMANHO] > aInfMRP[TAMANHO] .Or. aInfC2[DECIMAL] > aInfMRP[DECIMAL]))
		If aInfC1[TAMANHO] > aInfC2[TAMANHO]
			cPictERP := X3Picture("C1_QUANT")
			aInfERP  := aInfC1
		ElseIf aInfC1[TAMANHO] == aInfC2[TAMANHO]
			If aInfC1[DECIMAL] > aInfC2[DECIMAL]
				cPictERP := X3Picture("C1_QUANT")
				aInfERP  := aInfC1
			Else
				cPictERP := X3Picture("C2_QUANT")
				aInfERP  := aInfC2
			EndIf
		Else
			cPictERP := X3Picture("C2_QUANT")
			aInfERP  := aInfC2
		EndIf
		aAdd(aIncons,{"HWC","HWC_QTNECE",aInfERP[TAMANHO],aInfERP[DECIMAL],cPictERP})
	EndIf

	If mrpGrdT4T()
		aInfT4T := TAMSX3("T4T_DOCUM")
		If aInfT4T[TAMANHO] <> TAMSX3("C1_NUM")[TAMANHO] + TAMSX3("C1_ITEM")[TAMANHO] + TAMSX3("C1_ITEMGRD")[TAMANHO]
			aAdd(aIncons,{"T4T","T4T_DOCUM",aInfT4T[TAMANHO],aInfT4T[DECIMAL],""})
			nErr++
		Else
			nSuc++
		EndIf

		aInfT4U := TAMSX3("T4U_DOCUM")
		If aInfT4U[TAMANHO] <> TAMSX3("C7_NUM")[TAMANHO] + TAMSX3("C7_ITEM")[TAMANHO] + TAMSX3("C7_ITEMGRD")[TAMANHO]
			aAdd(aIncons,{"T4U","T4U_DOCUM",aInfT4U[TAMANHO],aInfT4U[DECIMAL],""})
			nErr++
		Else
			nSuc++
		EndIf
	EndIf
Return aIncons

/*/{Protheus.doc} PCPAliasQr
Retorna um alias único para utilização em uma query

@type Function
@author lucas.franca
@since 08/07/2021
@version P12.1.33
@return cAlias, Character, Alias para utilização na query.
/*/
Function PCPAliasQr()

Return GetNextAlias() + StrTran(cValToChar(MicroSeconds()),'.','')

/*/{Protheus.doc} PCPStatPrc
Retorna o status do processamento das pendências iniciado pelo PCPA712

@type Function
@author marcelo.neumann
@since 06/05/2022
@version P12.1.33
@param 01 cTicket   , Caracter, Número do ticket que iniciou o processamento das pendências
@param 02 nPendTotal, Numérico, Quantidade total de pendências
@param 03 nPendProc , Numérico, Quantidade de pendências já processadas
@param 04 nPercent  , Numérico, Percentual do progresso
@param 05 lError    , Lógico  , Indica se houve algum erro na execução (error.log nas threads)
@param 06 cError    , Caracter, Texto do erro que ocorreu no processamento
@return   lEmExecuc , Lógico  , Indica se o processamento de pendências ainda está em execução
/*/
Function PCPStatPrc(cTicket, nPendTotal, nPendProc, nPercent, lError, cError)
	Local aAPIsPend := {}
	Local lEmExecuc := .F.
	Local nIndex    := 1
	Local nTotal    := 0

	//Busca o processamento nas Globais
	aAPIsPend := P141GetGlb(cTicket)
	If aAPIsPend != Nil .And. Len(aAPIsPend) > 0
		nPendTotal := 0
		nPendProc  := 0
		nTotal     := Len(aAPIsPend)

		For nIndex := 1 To nTotal
			//Se não preencheu a quantidade de registros marcados, não é possível calcular o percentual
			If aAPIsPend[nIndex][API_PEND_MARCADOS] == Nil
				lEmExecuc  := .T.
				nPendTotal := 0
				nPendProc  := 0
				Exit
			EndIf

			nPendTotal += aAPIsPend[nIndex][API_PEND_MARCADOS]
			nPendProc  += aAPIsPend[nIndex][API_PEND_PROCESSADOS]

			//Se ocorreu algum erro no processamento de alguma API, retorna o erro por referência
			If aAPIsPend[nIndex][API_PEND_STATUS] == "ERRO"
				cError := aAPIsPend[nIndex][API_PEND_MSG_ERRO]
				lError := .T.

			//Se alguma API ainda estiver com status INIciada, é porque ainda está em processamento
			ElseIf aAPIsPend[nIndex][API_PEND_STATUS] == "INI"
				lEmExecuc := .T.
			EndIf
		Next nIndex

		nPercent := Round(((nPendProc*100)/nPendTotal), 2)

		FwFreeArray(aAPIsPend)
	EndIf

Return lEmExecuc

/*/{Protheus.doc} PCPLockPen
Controle de lock do processamento de pendências pela tabela HW3

@type Function
@author marcelo.neumann
@since 06/05/2022
@version P12.1.33
@param 01 cAcao    , Caracter, Ação a ser feita (LOCK, UNLOCK ou VALID)
@param 02 cTicket  , Caracter, Número do ticket atual
@param 03 aApisPend, Array   , Lista dsa APIs para processamento das pendências
@return   lReturn  , Logic   , Indica se a rotina está liberada ou se está em lock (há um processamento de pendências em execução)
/*/
Function PCPLockPen(cAcao, cTicket, aApisPend)
	Local cAliasQry := ""
	Local lReturn   := .T.
	Local nIndex    := 1
	Local nUnlock   := 0
	Local nTotal    := 0

	//Faz o lock pela tabela HW3
	If cAcao == "LOCK"
		HW3->(dbSetOrder(1))
		If HW3->(dbSeek(xFilial("HW3") + cTicket))
			RecLock("HW3", .F.)
				HW3->HW3_STATCM := "0"
			HW3->(MsUnLock())
		EndIf

	//Remove o lock
	ElseIf cAcao == "UNLOCK"
		HW3->(dbSetOrder(1))
		If HW3->(dbSeek(xFilial("HW3") + cTicket))
			RecLock("HW3", .F.)
				HW3->HW3_STATCM := "1"
			HW3->(MsUnLock())
		EndIf

	//Verifica se está em lock e se realmente deveria estar
	ElseIf cAcao == "VALID"
		If cTicket <> "000000"
			cAliasQry := PCPAliasQr()
			BeginSql Alias cAliasQry
			  SELECT R_E_C_N_O_ RECNO
				FROM %Table:HW3%
			   WHERE HW3_FILIAL = %xFilial:HW3%
			 	 AND HW3_STATCM = "0"
				 AND %NotDel%
			EndSql
			If !(cAliasQry)->(Eof())
				nTotal := Len(aApisPend)

				//Varre as APIs para ver se alguma ainda está sendo executada
				For nIndex := 1 To nTotal
					If !PCPLock("PCPA712_PCPA141" + aApisPend[nIndex][API_PEND_CODIGO])
						lReturn := .F.
						Exit
					EndIf
					nUnlock++
				Next nIndex

				//Desfaz os Locks feitos na verificação
				For nIndex := 1 To nUnlock
					PCPUnLock("PCPA712_PCPA141" + aApisPend[nIndex][API_PEND_CODIGO])
				Next nIndex
			EndIf

			//Se não está mais em execução
			If lReturn
				While !(cAliasQry)->(Eof())
					HW3->(dbGoTo((cAliasQry)->RECNO))
					RecLock("HW3", .F.)
						HW3->HW3_STATCM := "1"
					HW3->(MsUnLock())

					(cAliasQry)->(dbSkip())
				End
			EndIf
			(cAliasQry)->(dbCloseArea())
		EndIf
	EndIf

Return lReturn

/*/{Protheus.doc} mostraProc
Abre a tela impedindo a abertura do PCPA712 por conta do processamento das pendências

@type Function
@author marcelo.neumann
@since 06/05/2022
@version P12.1.33
@param 01 lSchdl  , Lógico, Indica se está rodando em schedule
@param 02 lAskProc, Lógico, Retorna por referência se deve questionar o processamento das pendencias que entraram na T4R enquanto aguardava.
@return lReturn, Lógico, Indica se o processamento finalizou (permitindo a abertura do PCPA712) ou se o usuário Saiu da tela
/*/
Static Function mostraProc(lSchdl, lAskProc)
	Local cMsg       := ""
	Local cPercent   := ""
	Local cTicket    := GetGlbValue("PCPA141_TICKET")
	Local lAbreMRP   := .F.
	Local lErro      := .F.
	Local lTerminou  := .F.
	Local nLinha     := 10
	Local nMeter     := 0
	Local nPendProc  := 0
	Local nPendTotal := 0
	Local oMeter     := Nil
	Local oSayMtr    := Nil
	Local oTimer     := Nil

	If lSchdl
		While PCPStatPrc(cTicket, @nPendProc, @nPendTotal, @cPercent, @lErro)
			cMsg := STR0014 + CRLF // "O último processamento de pendências iniciado pelo MRP Memória ainda não foi finalizado."
			cMsg += STR0048 // "Aguardando o término do processamento para executar a rotina."

			//Se posui o número do ticket é porque está no mesmo appserver, então exibe o processamento de acordo com as globais
			If !Empty(cTicket)
				cMsg += CRLF + I18N(STR0018, {cValToChar(nPendProc), cValToChar(nPendTotal), cValToChar(cPercent)}) //"Processadas #1[ATRIBUTO]# de #2[ATRIBUTO]# (#3[ATRIBUTO]#%)"
			EndIf

			LogMsg('PCPIntMRP', 0, 0, 1, '', '', cMsg)
			Sleep(2000)
		End
		lAbreMRP := .T.
	Else
		DEFINE MSDIALOG oDlgMet FROM 0,0 TO 12,65 TITLE STR0012 //"Pendências em Processamento"

		nLinha := 10
		tSay():New(nLinha,10,{|| STR0013}, oDlgMet,,,,,,.T.,,,240,20) //"Abertura não permitida!"
		nLinha += 10
		tSay():New(nLinha, 10,{|| STR0014},oDlgMet,,,,,,.T.,,,240,20) //"O último processamento de pendências iniciado pelo MRP Memória ainda não foi finalizado."
		nLinha += 15
		tSay():New(nLinha, 10,{|| STR0015},oDlgMet,,,,,,.T.,,,240,20) //"Aguarde o término do processamento para acessar a rotina."

		//Se posui o número do ticket é porque está no mesmo appserver, então exibe o processamento de acordo com as globais
		If !Empty(cTicket)
			nLinha += 15
			oSayMtr := tSay():New(nLinha,10,{|| STR0016},oDlgMet,,,,,,.T.,,,240,20) //"Calculando..."
			nLinha += 10
			oMeter := tMeter():New(nLinha,10,{|u|if(Pcount()>0, nMeter:=u,nMeter)},100,oDlgMet,240,10,,.T.)
			oTimer := TTimer():New(1000, {|| lTerminou := attProgres(cTicket, oMeter, oSayMtr, @lErro), IIf(lTerminou, oDlgMet:End(), Nil)}, oDlgMet)
			oTimer:Activate()
		EndIf

		oTButton3 := TButton():New(75, 210, STR0017, oDlgMet, {|| lAbreMRP := .F., oDlgMet:End() }, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Sair"

		ACTIVATE MSDIALOG oDlgMet CENTERED

		If lTerminou
			lAbreMRP := .T.
		EndIf
	EndIf

	If lErro
		cMsg := STR0049 + CRLF + CRLF // "Houve erro no processamento das pendências. Para mais informações, acesse as rotinas de Pendências de Integração (PCPA142) e Sincronização (PCPA140)."
		cMsg += STR0050               // "Deseja continuar com o processamento do MRP (pendências com erro não serão consideradas e poderá ocorrer divergências no cálculo do MRP)?"

		If lSchdl
			lAbreMRP := .F.
			Help(' ', 1, "INTMRPL" + cValToChar(ProcLine()), , STR0046, ; //"Houve erro no processamento das pendências."
			     1, 1, , , , , , {STR0047}) //"Acesse as rotinas de Pendências de Integração (PCPA142) e Sincronização (PCPA140) para obter detalhes."
		ElseIf MsgYesNo(cMsg, STR0032) // "Atenção!"
			lAskProc := .F.
			lAbreMRP := .T.
		Else
			lAbreMRP := .F.
		EndIf
	EndIf

Return lAbreMRP

/*/{Protheus.doc} attProgres
Atualiza a barra de progresso da tela (chamado pelo timer)

@type Function
@author marcelo.neumann
@since 06/05/2022
@version P12.1.33
@param 01 cTicket, Caracter, Número do ticket que está executando a pendência
@param 02 oMeter , Object  , Instância da régua de processamento
@param 03 oSayMtr, Object  , Instância do texto que será atualizado
@param 04 lErro  , Logic   , Retorna (por referência) se houve erro no processamento
@return lTerminou, Logic   , Indica se terminou o processamento
/*/
Static Function attProgres(cTicket, oMeter, oSayMtr, lErro)
	Local cPercent   := 0
	Local nPendProc  := 0
	Local nPendTotal := 0
	Local lTerminou  := .F.

	If !PCPStatPrc(cTicket, @nPendTotal, @nPendProc, @cPercent, @lErro)
		lTerminou := .T.
	EndIf

	If oMeter <> Nil .And. nPendTotal > 0
		oMeter:SetTotal(nPendTotal)
		oSayMtr:SetText(I18N(STR0018, {cValToChar(nPendProc), cValToChar(nPendTotal), cValToChar(cPercent)})) //"Processadas #1[ATRIBUTO]# de #2[ATRIBUTO]# (#3[ATRIBUTO]#%)"
		oSayMtr:CtrlRefresh()
		oMeter:Set(nPendProc)
		oMeter:Refresh()
	EndIf

Return lTerminou

/*/{Protheus.doc} PCPInMrpCn
Recupera o valor das constantes

@type Function
@author marcelo.neumann
@since 18/05/2022
@version P12.1.33
@param cInfo, Caracter, Define qual constante se deseja recuperar o valor.
@return nValue, Numeric, Valor da constante
/*/
Function PCPInMrpCn(cInfo)
	Local nValue := API_PEND_TAMANHO

	Do Case
		Case cInfo == "API_PEND_CODIGO"
			nValue := API_PEND_CODIGO
		Case cInfo == "API_PEND_QTD_TOTAL"
			nValue := API_PEND_QTD_TOTAL
		Case cInfo == "API_PEND_STATUS"
			nValue := API_PEND_STATUS
		Case cInfo == "API_PEND_MARCADOS"
			nValue := API_PEND_MARCADOS
		Case cInfo == "API_PEND_PROCESSADOS"
			nValue := API_PEND_PROCESSADOS
		Case cInfo == "API_PEND_MSG_ERRO"
			nValue := API_PEND_MSG_ERRO
		Case cInfo == "API_PEND_TAMANHO"
			nValue := API_PEND_TAMANHO
		Case cInfo == "PEND_CODIGO"
			nValue := PEND_CODIGO
		Case cInfo == "PEND_STATUS"
			nValue := PEND_STATUS
		Case cInfo == "PEND_ATRJSON"
			nValue := PEND_ATRJSON
		Case cInfo == "PEND_POSICAO"
			nValue := PEND_POSICAO
		Case cInfo == "PEND_MSGRET"
			nValue := PEND_MSGRET
		Case cInfo == "PEND_MSGENV"
			nValue := PEND_MSGENV
		Case cInfo == "PEND_TAMANHO"
			nValue := PEND_TAMANHO
		Otherwise
			nValue := API_PEND_TAMANHO
	EndCase
Return nValue

/*/{Protheus.doc} conferPend
Confere se existe pendência que iniciou o processamento, mas não finalizou por algum problema

@type Static Function
@author marcelo.neumann
@since 02/06/2022
@version P12.1.33
@Param 01 lSemTela, Logico, Indica que a execução está sendo feita sem tela (Realiza o log da mensagem ao invés de exibir na tela).
@return oApisPrc, Object, JsonObject com os processamentos (T4R_IDPRC) que ficaram presos
/*/
Static Function conferPend(lSemTela)
	Local cAliasQry := PCPAliasQr()
	Local cApi      := ""
	Local cIdPrc    := ""
	Local cMessage  := STR0039 + CRLF + CRLF //"Existem atualizações nas API's do MRP que requerem sincronização para garantir a integridade das informações. Será necessário executar a sincronização das seguintes entidades: "
	Local cQuery    := ""
	Local lError    := .F.
	Local oApisMsg  := JsonObject():New()
	Local oApisPrc  := JsonObject():New()
	Local oDescri   := P139AllAPI()

	cQuery := "SELECT DISTINCT T4R_API, T4R_IDPRC"
	cQuery +=  " FROM " + RetSqlName("T4R") + " T4R"
	cQuery += " WHERE T4R.T4R_FILIAL = '" + xFilial("T4R") + "'"
	cQuery +=   " AND T4R.D_E_L_E_T_ = ' '"
	cQuery +=   " AND T4R.T4R_IDPRC <> ' '"

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

	While (cAliasQry)->(!Eof())
		If PCPLock("PCPA141_" + (cAliasQry)->T4R_IDPRC)
			PCPUnLock("PCPA141_" + (cAliasQry)->T4R_IDPRC)
			lError := .T.
			cApi   := AllTrim((cAliasQry)->T4R_API)
			cIdPrc := AllTrim((cAliasQry)->T4R_IDPRC)

			If !oApisPrc:hasProperty(cIdPrc)
				oApisPrc[cIdPrc] := cApi
			EndIf

			If !oApisMsg:hasProperty(cApi)
				cMessage += CRLF
				If !oDescri:hasProperty(cApi)
					cMessage += " - " + cApi + Space(97- Len(cApi))
				Else
					cMessage += " - " + oDescri[cApi] + Space(97- Len(oDescri[cApi]))
				EndIf
				oApisMsg[cApi] := .T.
			EndIf
		EndIf
		(cAliasQry)->(dbSkip())
	End
	(cAliasQry)->(dbCloseArea())

	If lError
		If lSemTela
			LogMsg('PCPIntMRP', 0, 0, 1, '', '', cMessage)
		Else
			Aviso(STR0008, cMessage, {STR0009}, 3) //"Atenção" //"OK"
		EndIf
	EndIf

	FreeObj(oApisMsg)
	FreeObj(oDescri)

Return oApisPrc

/*/{Protheus.doc} procSchdl
Processa schedules pendentes.
@type  Static Function
@author Lucas Fagundes
@since 21/07/2022
@version P12
@param 01 aAPI     , Array    , Array com as APIS do MRP.
@param 02 lSchdl   , Logico   , Indica que o MRP está sendo executado via schedule.
@param 03 lAbreTela, Logico   , Retorna por referência se pode abrir a tela ou não.
@param 04 cTicket  , Caractere, Ticket em execução do MRP.
@param 05 lReItg   , Logico   , Indica se ira realizar a sincronização das pendencias quando o mrp está sendo executado via schedule.
@return lReturn, Logico, Retorna se iniciou o processamento das pendencias.
/*/
Static Function procSchdl(aAPI, lSchdl, lAbreTela, cTicket, lReItg)
	Local aApisPend := {}
	Local cApi      := ""
	Local cMessage  := ""
	Local lIntegra  := .T.
	Local lOnline   := .F.
	Local lProcPend := .F.
	Local lReturn   := .T.
	Local lAskProc  := .T.
	Local nIndex    := 0
	Local nMrpSinc  := SuperGetMV("MV_MRPSINC", .F., 1)
	Local nQtdPend  := 0
	Local oApisPrc  := JsonObject():New()
	Local oDescri   := P139AllAPI()

	oApisPrc := conferPend(lSchdl)
	If !Empty(oApisPrc:GetNames())
		lAbreTela := .F.
	EndIf

	For nIndex := 1 To Len(aAPI)
		cAPI := AllTrim(aAPI[nIndex])

		lIntegra := IntNewMRP(cAPI, @lOnline)

		//Se a integração está ativada, verifica se existem pendências na tabela T4R
		If lIntegra
			nQtdPend += PendSchedu(cAPI, aApisPend, oApisPrc)
		EndIf
	Next nIndex

	If nQtdPend > 0 .And. !lSchdl
		/*
			Não retirar as chamadas do Space(50) na montagem do cMessage.
			Foi feito para que a janela calcule o tamanho corretamente
			quando existe quebras de linha.
		*/
		If nQtdPend == 1
			cMessage := STR0010 //"Existe 1 pendência na fila de processamento da integração do MRP para a seguinte API:"
		Else
			cMessage := I18N(STR0029, {AllTrim(Transform(nQtdPend, '@E 999,999,999'))}) //"Existem #1[ATRIBUTO]# pendências na fila de processamento da integração do MRP para as seguintes APIs:"
		EndIf

		cMessage += CRLF + Space(50) + CRLF

		For nIndex := 1 To Len(aApisPend)
			cMessage += AllTrim(aApisPend[nIndex][API_PEND_CODIGO])
			If oDescri:hasProperty(AllTrim(aApisPend[nIndex][API_PEND_CODIGO]))
				cMessage += " - " + oDescri[AllTrim(aApisPend[nIndex][API_PEND_CODIGO])]
			EndIf
			cMessage += CRLF
		Next nIndex

		cMessage += Space(50) + CRLF + "<b>" + STR0033 + "</b>" //Deseja executar a integração agora?
	EndIf

	If lAbreTela .And. Len(aApisPend) > 0
		//Verifica se há algum processamento de pendências iniciado pelo PCPA712 e ainda não finalizado
		If !PCPLockPen("VALID", cTicket, aApisPend)
			//Se existe outro processamento iniciado, exibe a tela de acompanhamento
			lAbreTela := mostraProc(lSchdl, @lAskProc)

			//Se aguardou o término do processamento, refaz a validação (caso não tenha ocorrido erro) para abrir o pcpa712
			If lAbreTela .And. lAskProc
				Return procSchdl(aAPI, lSchdl, @lAbreTela, cTicket, lReItg)
			Else
				lReturn := .F.
			EndIf
		EndIf

		If lAbreTela .And. lAskProc
			If nMrpSinc == 1 .And. IIf(lSchdl, lReItg, MsgYesNo(cMessage, STR0032))
				lProcPend := .T.
			ElseIf nMrpSinc == 2
				lProcPend := .T.
			EndIf
		EndIf

		If lProcPend
			If !lSchdl
				FWMsgRun(, {|| lReturn := prcPendenc(aApisPend, cTicket) }, STR0034, STR0035) //"Aguarde" ### "Processando pendências..."
			Else
				LogMsg('PCPIntMRP', 0, 0, 1, '', '', STR0035) // "Processando pendências..."
				lReturn := prcPendenc(aApisPend, cTicket)
			EndIf
		EndIf
	EndIf

	FreeObj(oApisPrc)
	oApisPrc := Nil
	FreeObj(oDescri)
	oDescri := Nil

	aSize(aApisPend, 0)
Return lReturn

/*/{Protheus.doc} getAPIS
Retorna array com as APIS usadas pelo MRP
@type  Static Function
@author Lucas Fagundes
@since 21/07/2022
@version P12
@param 01 oModel, Object, Modelo de dados para buscar as APIS.
@param 02 cCodAPI, Caractere, Código da API, para buscar por API especifica.
@param 03 oPosMdlGrd, Json, Retorna por referência um json com a posição de cada API no modelo de dados.
@return aAPI, Array, Array com as APIS do MRP.
/*/
Static Function getAPIS(oMdlGrid, cCodAPI, oPosMdlGrd)
	Local aAPI   := {}
	Local cAlias := ""
	Local cApi   := ""
	Local cQuery := ""
	Local nIndex := 0

	If oMdlGrid == Nil
		cAlias := PCPAliasQr()
		cQuery := " SELECT DISTINCT T4P.T4P_API "
		cQuery +=   " FROM " + RetSqlName("T4P") + " T4P "
		cQuery +=  " WHERE T4P.T4P_FILIAL = '" + xFilial("T4P") + "' "
		cQuery +=    " AND T4P.D_E_L_E_T_ = ' ' "

		If !Empty(cCodAPI)
			cQuery += " AND T4P.T4P_API = '" + cCodAPI + "' "
		Else
			cQuery += " AND T4P.T4P_API NOT IN ('MRPTRANSPORTINGLANES','MRPWAREHOUSEGROUP') "
		EndIf

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)

		While (cAlias)->(!Eof())
			aAdd(aAPI, (cAlias)->(T4P_API))
			(cAlias)->(dbSkip())
		End

		(cAlias)->(dbCloseArea())
	Else
		For nIndex := 1 to oMdlGrid:Length(.F.)
			cApi := AllTrim(oMdlGrid:GetValue("T4P_API", nIndex))
			oPosMdlGrd[cApi] := nIndex

			If cApi == "MRPTRANSPORTINGLANES" .Or. cApi == "MRPWAREHOUSEGROUP"
				Loop
			EndIf

			If cApi == AllTrim(cCodAPI) .Or. Empty(cCodAPI)
				aAdd(aAPI, oMdlGrid:GetValue("T4P_API", nIndex))
			EndIf
		Next
		aAdd(aAPI, "MRPPRODUCTINDICATOR")
		oPosMdlGrd["MRPPRODUCTINDICATOR"] := oPosMdlGrd["MRPPRODUCT"]

		aAdd(aAPI, "MRPREJECTEDINVENTORY")
		oPosMdlGrd["MRPREJECTEDINVENTORY"] := oPosMdlGrd["MRPSTOCKBALANCE"]

		If FWAliasInDic("HW9", .F.)
			aAdd(aAPI, "MRPBOMROUTING")
			oPosMdlGrd["MRPBOMROUTING"] := oPosMdlGrd["MRPBILLOFMATERIAL"]
		EndIf
	EndIf

	/*TRIGGERS COM DUAS TABELAS PRECISAM DESSE TRATAMENTO PARA CRIAREM A TRIGGER EM AMBAS AS TABELAS*/
	aadd(aAPI, "MRPPRODUCT#CHILD")
	aadd(aAPI, "MRPPRODUCT#CHILDSB5")
	If possuiHZ8()
		aadd(aAPI, "MRPPRODUCT#CHILDHZ8")
	EndIf

Return aAPI

/*/{Protheus.doc} mrpLoteCQ
Verifica se os campos de lote e sublote estão presentes na tabela HWX.
@type  Function
@author Lucas Fagundes
@since 23/11/2022
@version P12
@return lRet, Logico, Verdadeiro se os campos de lote e sublote estiverem na HWX e falso que não estiverem.
/*/
Function mrpLoteCQ()

Return !Empty(GetSx3Cache("HWX_LOTE", "X3_TAMANHO")) .And. !Empty(GetSx3Cache("HWX_SLOTE", "X3_TAMANHO"))

/*/{Protheus.doc} mrpInSMQ
Verifica se uma filial está presente na tabela SMQ.
@type  Function
@author Lucas Fagundes
@since 07/12/2022
@version P12
@param cCodFil, Caracter, Código da filial que irá buscar na SMQ.
@return lEncontrou, Logico, Retorna se encontrou a filial na tabela SMQ.
/*/
Function mrpInSMQ(cCodFil)
	Local cAlias     := PCPAliasQr()
	Local cFilTrim   := Rtrim(cCodFil)
	Local cQuery     := ""

	If Empty(cCodFil)
		Return .T.
	EndIf

	If _oCacheSMQ:hasProperty(cFilTrim)
		Return _oCacheSMQ[cFilTrim]
	EndIf

	If _oStmtSMQ == Nil
		_oStmtSMQ := FWPreparedStatement():New()

		cQuery := "SELECT COUNT(1) AS FILIAIS "
		cQuery +=  " FROM " + RetSqlName("SMQ") + " SMQ"
		cQuery += " WHERE SMQ.D_E_L_E_T_ = ' ' "
		cQuery +=   " AND SMQ.MQ_FILIAL = '" + xFilial("SMQ") + "' "
		cQuery +=   " AND SMQ.MQ_CODFIL LIKE ? "

		_oStmtSMQ:SetQuery(cQuery)
	EndIf

	_oStmtSMQ:SetString(1, cFilTrim+"%")

	cQuery := _oStmtSMQ:GetFixQuery()

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAlias,.T.,.T.)
	If (cAlias)->(FILIAIS) > 0
		_oCacheSMQ[cFilTrim] := .T.
	Else
		_oCacheSMQ[cFilTrim] := .F.
	EndIf
	(cAlias)->(DbCloseArea())

Return _oCacheSMQ[cFilTrim]

/*/{Protheus.doc} possuiHZ8
Verifica se existe a tabela HZ8 no dicionario de dados.
@type  Static Function
@author Lucas Fagundes
@since 11/10/2024
@version P12
@return _lTemHZ8, Logico, Indica se existe a tabela HZ8
/*/
Static Function possuiHZ8()

	If _lTemHZ8 == Nil
		_lTemHZ8 := AliasInDic("HZ8")
	EndIf

Return _lTemHZ8

/*/{Protheus.doc} infErrSinc
Verifica e alerta o usuario sobre a existencia de registros com erro na tabela T4R.

@type  Static Function
@author Lucas Fagundes
@since 11/12/2024
@version P12
@return Nil
/*/
Static Function infErrSinc()
	Local cAlias := GetNextAlias()
	Local cMsg   := ""
	Local cQuery := ""

	cQuery := " SELECT DISTINCT T4R.T4R_API "
	cQuery +=   " FROM " + RetSqlName("T4R") + " T4R "
	cQuery +=  " WHERE T4R.T4R_FILIAL = '" + xFilial("T4R") + "' "
	cQuery +=    " AND T4R.T4R_STATUS = '2' "
	cQuery +=    " AND T4R.D_E_L_E_T_ = ' ' "

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAlias,.F.,.T.)

	If (cAlias)->(!EoF())
		cMsg := STR0051 // "Existem APIs com erro de integração com o MRP!"
		cMsg += CRLF + CRLF
		cMsg += STR0052 // "Para evitar divergências no cálculo do MRP, acesse as rotinas Pendências de Integração (PCPA142) e Sincronização (PCPA140) e corrija as pendências nas seguintes APIs:"

		While (cAlias)->(!EoF())
			cMsg += CRLF + "- " + P139GetAPI(RTrim((cAlias)->T4R_API))
			(cAlias)->(dbSkip())
		End

		Aviso(STR0008, cMsg, {STR0009}, 3) //"Atenção" //"OK"
	EndIf
	(cAlias)->(dbCloseArea())

Return Nil
/*/{Protheus.doc} mrpGrdT4T
Verifica se existe o campo T4T_IDGRD no dicionario de dados.
Por terem sido liberados no mesmo pacote, serve também para os campos T4U_IDGRD, T4T_DOCUM e T4U_DOCUM
@type  Static Function
@author Douglas Heydt
@since 21/01/2024
@version P12
@return _nTmGrdT4T, Logico, Indica se existe o campo T4T_ITGRD
/*/
Function mrpGrdT4T()

	If _nTmGrdT4T == Nil
		dbSelectArea("T4T")
		_nTmGrdT4T := FieldPos("T4T_ITGRD") > 0
	EndIf

Return _nTmGrdT4T

/*/{Protheus.doc} PCPLockSinc
Controle de lock do processamento de sincronização pela tabela HW3

@type Function
@author ana.paula
@since 26/02/2025
@version P12.1.2410
@param 01 cAcao    , Caracter, Ação a ser feita (LOCK, UNLOCK ou VALID)
@param 02 cTicket  , Caracter, Número do ticket atual
@return   lReturn  , Logic   , Indica se a rotina está liberada ou se está em lock (há um processamento de sincronização em execução)
/*/
Function PCPLockSinc(cAcao, cTicket)
	Local cAliasQry := ""
	Local lReturn   := .T.
	
	//Faz o lock pela tabela HW3
	If cAcao == "LOCK"
		HW3->(dbSetOrder(1))
		If HW3->(dbSeek(xFilial("HW3") + cTicket))
			RecLock("HW3", .F.)
				HW3->HW3_STATCM := "0"
			HW3->(MsUnLock())
		EndIf

	//Remove o lock
	ElseIf cAcao == "UNLOCK"
		HW3->(dbSetOrder(1))
		If HW3->(dbSeek(xFilial("HW3") + cTicket))
			RecLock("HW3", .F.)
				HW3->HW3_STATCM := "1"
			HW3->(MsUnLock())
		EndIf

	//Verifica se está em lock e se realmente deveria estar
	ElseIf cAcao == "VALID"
		If cTicket <> "000000"
			cAliasQry := PCPAliasQr()
			BeginSql Alias cAliasQry
			  SELECT R_E_C_N_O_ RECNO
				FROM %Table:HW3%
			   WHERE HW3_FILIAL = %xFilial:HW3%
			 	 AND HW3_STATCM = "0"
				 AND %NotDel%
			EndSql
			If !(cAliasQry)->(Eof())
				
				If !PCPLock("PCPA712_PCPA140_PROC")
					lReturn := .F.
				EndIf

				If lReturn
					//Desfaz os Locks feitos na verificação
					PCPUnLock("PCPA712_PCPA140_PROC")
				EndIf
			EndIf

			//Se não está mais em execução
			If lReturn
				While !(cAliasQry)->(Eof())
					HW3->(dbGoTo((cAliasQry)->RECNO))
					RecLock("HW3", .F.)
						HW3->HW3_STATCM := "1"
					HW3->(MsUnLock())

					(cAliasQry)->(dbSkip())
				End
			EndIf
			(cAliasQry)->(dbCloseArea())
		EndIf
	EndIf

Return lReturn

/*/{Protheus.doc} mostraSinc
Abre a tela impedindo a abertura do PCPA712 por conta do processamento da sincronização

@type Function
@author ana.paula
@since 28/02/2025
@version P12.1.2410
@param 01 lSchdl  , Lógico, Indica se está rodando em schedule
@return lReturn, Lógico, Indica se o processamento finalizou (permitindo a abertura do PCPA712) ou se o usuário Saiu da tela
/*/
Function mostraSinc(lSchdl)
	Local cMsg       := ""
	Local cTicket    := GetGlbValue("PCPA140_TICKET")
	Local lAbreMRP   := .F.
	Local lErro      := .F.
	Local lTerminou  := .F.
	Local nLinha     := 10
	Local nMeter     := 0
	Local oMeter     := Nil
	Local oSayMtr    := Nil
	Local oTimer     := Nil

	Default lSchdl := .F.

	If lSchdl
		While Val(GetGlbValue(cTicket+"PERCENTUALSINC")) < 100
			cMsg := STR0053 + CRLF //"O último processamento da sincronização iniciado pelo MRP Memória ainda não foi finalizado."
			cMsg += STR0048 // "Aguardando o término do processamento para executar a rotina."

			//Se posui o número do ticket é porque está no mesmo appserver, então exibe o processamento de acordo com as globais
			If !Empty(cTicket)
				cMsg += CRLF + I18N(STR0055+GetGlbValue(cTicket+"PERCENTUALSINC")+STR0056) //"Status: XX.XX %"
			EndIf

			LogMsg('PCPIntMRP', 0, 0, 1, '', '', cMsg)
			Sleep(2000)
		End
		lAbreMRP := .T.
	Else
		DEFINE MSDIALOG oDlgMet FROM 0,0 TO 12,65 TITLE STR0054 //"Sincronização em Processamento"

		nLinha := 10
		tSay():New(nLinha,10,{|| STR0013}, oDlgMet,,,,,,.T.,,,240,20) //"Abertura não permitida!"
		nLinha += 10
		tSay():New(nLinha, 10,{|| STR0053},oDlgMet,,,,,,.T.,,,240,20) //"O último processamento da sincronização iniciado pelo MRP Memória ainda não foi finalizado."
		nLinha += 15
		tSay():New(nLinha, 10,{|| STR0015},oDlgMet,,,,,,.T.,,,240,20) //"Aguarde o término do processamento para acessar a rotina."

		//Se posui o número do ticket é porque está no mesmo appserver, então exibe o processamento de acordo com as globais
		If !Empty(cTicket)
			nLinha += 15
			oSayMtr := tSay():New(nLinha,10,{|| STR0016},oDlgMet,,,,,,.T.,,,240,20) //"Calculando..."
			nLinha += 10
			oMeter := tMeter():New(nLinha,10,{|u|if(Pcount()>0, nMeter:=u,nMeter)},100,oDlgMet,240,10,,.T.)
			oTimer := TTimer():New(1000, {|| lTerminou := atuSinc(cTicket, oMeter, oSayMtr, @lErro), IIf(lTerminou, oDlgMet:End(), Nil)}, oDlgMet)
			oTimer:Activate()
		EndIf

		oTButton3 := TButton():New(75, 210, STR0017, oDlgMet, {|| lAbreMRP := .F., oDlgMet:End() }, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Sair"

		ACTIVATE MSDIALOG oDlgMet CENTERED

		If lTerminou
			lAbreMRP := .T.
		EndIf
	EndIf

Return lAbreMRP

/*/{Protheus.doc} atuSinc
Atualiza a barra de progresso da tela (chamado pelo timer)

@type Function
@author ana.paula
@since 28/02/2025
@version P12.1.33
@param 01 cTicket, Caracter, Número do ticket que está executando a pendência
@param 02 oMeter , Object  , Instância da régua de processamento
@param 03 oSayMtr, Object  , Instância do texto que será atualizado
@param 04 lErro  , Logic   , Retorna (por referência) se houve erro no processamento
@return lTerminou, Logic   , Indica se terminou o processamento
/*/
Static Function atuSinc(cTicket, oMeter, oSayMtr, lErro)
	Local cPercent   := 0
	Local lTerminou  := .F.

	cPercent   := GetGlbValue(cTicket+"PERCENTUALSINC")
	If cPercent == "100"
		lTerminou := .T.
	EndIf

	If oMeter <> Nil .And. Val(cPercent) < 100
		oMeter:SetTotal(100)
		oSayMtr:CtrlRefresh()
		oMeter:Set(val(cPercent))
		oMeter:Refresh()
	EndIf

Return lTerminou
