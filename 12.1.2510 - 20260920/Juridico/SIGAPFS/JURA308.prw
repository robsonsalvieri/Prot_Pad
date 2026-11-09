#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FILEIO.CH'
#INCLUDE 'JURA308.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA308()
Consulta de Solicitações Prontas para criar Fatura Adicional

@return .T.
@since 01/12/2022
/*/
//-------------------------------------------------------------------
Function JURA308()
Local cConfig     := SuperGetMv('MV_JCFGOCO',, '') // Chave de config da integração de ocorrencias x Juridico

	// Verificar se possui configuração
	If !Empty(cConfig)
		AtuStatus() //Atualiza status da solicitação
	Else
		JurMsgErro(STR0001) //"Para utilizar a funcionalidade de Faturamento por ocorrencias é necessário realizar configuração prévia!"
	EndIf

Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} J308FACreate(oSolicit, cConfig )
Função responsável por criar faturas adcionais e movimentar
a solicitação para a pasta history na Azure

@since 13/12/2022
@version 1.0
@param oSolicit  - Objeto da solicitação
@param cConfig    - Configuração do cliente
@return .T.
/*/
//-------------------------------------------------------------------
Static Function J308FACreate(oSolicit, cConfig )
Local aRetFatAdc := {}

	aRetFatAdc := J033GrvOco(oSolicit)

	// Movimenta a solicitação para a pasta History na Azure
	If aRetFatAdc[1]
		J308PutHis(cConfig, oSolicit, aRetFatAdc[2])
	EndIf

Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} J308GtDone(cConfig, oResposta, cCodSolic)
Responsável por buscar a solicitação na pasta done na Azure

@param cConfig   - Configuração do cliente
@param oResposta - Objeto de resultado da consulta das solicitações done.
@param cCodSolic - Código da Solicitação

@return lRet     - Indica se encontrou a solicitação
@since 01/12/2022
/*/
//-------------------------------------------------------------------
Function J308GtDone(cConfig, oResposta, cCodSolic)
Local lRet        := .F.
Local oRest       := Nil
Local aHeader     := {}
Local cEndPoint   := 'ocorrencia/done/' + Encode64(cConfig)
Default cCodSolic := ''

	oRest := JRestOcor(cEndPoint + cCodSolic,@aHeader)

	If oRest:Get(aHeader)
		oResposta := JsonObject():New()
		oResposta:fromJson(oRest:GetResult())

		// Nas solicitações que forem de lista, muda a validação
		If Empty(cCodSolic)
			lRet := VALTYPE(oResposta['response']) <> "U" .AND. Len(oResposta['response']) > 0
		Else
			// Se retornar como Status, significa que não irá gerar fatura adicional
			lRet := Len(oResposta:getNames()) > 0 .And. aScan(oResposta:getNames(),'status') == 0 
		EndIf
	Else
		oResposta := JSonObject():New()
		oResposta:fromJson(oRest:GetResult())
	EndIf

	aSize(aHeader, 0)
	FWFreeObj(oRest)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J308PutHis(cConfig, oSolic, cCodFatAdc)
Responsável por movimentar a solicitação das pasta DONE para a pasta
HISTORY na Azure.

@param cConfig    - Configuração do cliente
@param oSolic     - Objeto da solicitação
@param cCodFatAdc - Código da Fatura Adicional criada
@return lRet      - Indica se foi realizada a movimentação da solicitação
					da pasta DONE para a pasta HISTORY na Azure
@since 05/12/2022
/*/
//-------------------------------------------------------------------
Function J308PutHis(cConfig, oSolic, cCodFatAdc)
Local lRet      := .F.
Local oRest     := Nil
Local oResponse := Nil
Local oBody     := JsonObject():New()
Local aHeader   := {}
Local codSolic  := oSolic['id']
Local cEndPoint := 'ocorrencia/history/' + Encode64(cConfig) + '/' + codSolic
Local aCampos   := {}

	oBody['idFaturaAdicionalFinal'] := cCodFatAdc

	If !Empty(cCodFatAdc)
		oBody['statusProcessamento'] := EncodeUTF8( STR0002 ) // "Criado com sucesso!"
		aAdd(aCampos, { 'OI7_FATADC', cCodFatAdc })
		aAdd(aCampos, { 'OI7_STATUS', '5' })
	Else
		oBody['statusProcessamento'] := EncodeUTF8( STR0003 ) // "Solicitação processada não gerando valor para faturamento!"
		aAdd(aCampos, { 'OI7_MSG', STR0003 }) // "Solicitação processada não gerando valor para faturamento!"
		aAdd(aCampos, { 'OI7_STATUS', '4' })  //Concluido sem cobrança, 
	EndIf

	J308Update(codSolic, aCampos) // Pendente de faturamento

	oRest := JRestOcor(cEndPoint,@aHeader)

	If oRest:Put(aHeader, oBody:ToJson())
		oResponse := JsonObject():New()
		oResponse:fromJson(oRest:GetResult())

		If VALTYPE(oResponse['mensagem']) <> "U"
			lRet := codSolic $ oResponse['mensagem']
		EndIf
	EndIf

	aSize(aHeader, 0)
	FWFreeObj(oRest)
	FWFreeObj(oResponse)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuStatus
Efetua a alteração via modelo da solicitação de ocorrência

@since 09/12/2022
@version 1.0
@return .T. logico
/*/
//-------------------------------------------------------------------
Static Function AtuStatus()
Local aArea      := getArea()
Local cQuery     := ""
Local cAlias     := getNextAlias()
Local lRet       := .F.
Local oResposta  := Nil
Local oRespDone  := Nil
Local cConfig    := SuperGetMv('MV_JCFGOCO',, '') // Chave de config da integração de ocorrencias x Juridico
Local nI         := 0
Local nIndJson   := 0
Local cNewStatus := ""
Local cCodSolic  := ""

	lRet   := J308GtDone(cConfig, @oRespDone)

	cQuery := "SELECT OI7_IDSOL, OI7_FATADC, OI7_STATUS, NX0.NX0_COD, NXA.NXA_COD, "
	cQuery +=       " CAST(OI7.OI7_MSG AS VARCHAR(4000)) OI7_MSG "
	cQuery +=  " FROM " + RetSqlName("OI7") + " OI7 "
	cQuery +=  " LEFT JOIN "  + RetSqlName("NX0") + " NX0"
	cQuery +=    " ON (NX0.NX0_CFTADC = OI7.OI7_FATADC "
	cQuery +=   " AND NX0.NX0_CCONTR = OI7.OI7_CCONTR "
	cQuery +=   " AND NX0.NX0_SITUAC <> '8' "
	cQuery +=   " AND NX0.D_E_L_E_T_ = ' ') "
	cQuery +=  " LEFT JOIN "  + RetSqlName("NXA") + " NXA"
	cQuery +=    " ON (NXA.NXA_CFTADC = OI7.OI7_FATADC "
	cQuery +=   " AND NXA.NXA_CPREFT = NX0.NX0_COD "
	cQuery +=   " AND NXA.NXA_SITUAC = '1' "
	cQuery +=   " AND NXA.D_E_L_E_T_ = ' ') "
	cQuery += " WHERE OI7_STATUS NOT IN ('2','4') "
	cQuery +=   " AND OI7.D_E_L_E_T_ = ' ' "

	cQuery	 := ChangeQuery(cQuery)
	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cQuery ) , cAlias, .T., .T.)

	(cAlias)->( dbGoTop() )
	While !(cAlias)->( EOF() )
		nI++
		cNewStatus := ""
		ProcRegua( nI )
		IncProc( STR0004 ) // "Atualizando status das solicitações ..."
	
		cCodSolic := (cAlias)->OI7_IDSOL
		If !Empty((cAlias)->OI7_FATADC) .And. (cAlias)->OI7_STATUS >= '5'
			If !Empty((cAlias)->NXA_COD)
				cNewStatus := "6" //Faturado, pois tem fatura vinculada
			Elseif !Empty((cAlias)->NX0_COD)
				cNewStatus := "7" //Em faturamento, pois há pre-fatura vinculada mas não há fatura
			Else
				cNewStatus := "5" //Pendende de faturamento, pois não há fatura e nem pre-fatura
			EndIf
		Else
			If Empty(AllTrim((cAlias)->OI7_MSG))//não tem fatura adicional, verifica se não tem msg, pq se tiver o status já foi alterado para concluido sem cobrança
				nIndJson := aScan(oRespDone['response'], {|x| x['id'] == cCodSolic })

				If (nIndJson == 0)
					lRet := J308GtDone(cConfig, @oResposta, '/' + cCodSolic)
				Else
					oResposta := oRespDone['response'][nIndJson]
					lRet := .T.
				EndIf

				If lRet
					J308FACreate(oResposta, cConfig )
				ElseIf ValType(oResposta) == 'J' .And. !Empty(oResposta['status'])
					cNewStatus := "3" //Em processamento, pois está aguardando retorno do juridico
				Else
					cNewStatus := "1" //Pendente
				EndIf

				oResposta:fromJson("{}")
				oResposta := NIL
			EndIf
		EndIf

		If !Empty(cNewStatus) .And. (cAlias)->OI7_STATUS <> cNewStatus
			J308Update(cCodSolic, {{'OI7_STATUS', cNewStatus}})
		EndIf
		
		(cAlias)->( dbSkip() )
	End

	If nI > 0
		FWAlertSuccess(STR0006)//"As solicitações foram atualizadas com sucesso!"
	EndIf
	
	(cAlias)->( dbCloseArea() )
	RestArea(aArea)
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} J308Update
Efetua a alteração via modelo da solicitação de ocorrência

@since 09/12/2022
@version 1.0
@param cCodSolic string Codigo da solicitação de ocorrencia
@param aValores array aValores[1] campo a ser alterado
	aValores[2] valor a ser setado no campo ex: '5'
@return 
/*/
//-------------------------------------------------------------------
Static Function J308Update(cCodSolic, aValores)
Local aArea  := GetArea()
Local oModel := Nil
Local nI     := 0
Local lRet   := .T.

Default aValores := {}

	If Len(aValores) > 0
		OI7->(dbSeek(xFilial('OI7') + cCodSolic ))//OI7_FILIAL +OI7_IDSOL

		oModel := FWLoadModel("JURA306")
		oModel:SetOperation( 4 )
		oModel:Activate()

		For nI := 1 to Len(aValores)
			oModel:SetValue( "OI7MASTER", aValores[nI][1], aValores[nI][2] ) 
		Next nI

		If ( lRet := oModel:VldData() )
			lRet := oModel:CommitData()
		EndIf

		oModel:DeActivate()
		oModel:Destroy()
		oModel := Nil
	EndIf

	RestArea(aArea)
Return lRet
