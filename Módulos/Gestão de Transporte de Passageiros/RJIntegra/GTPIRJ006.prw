#Include "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPIRJ006.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPIRJ006

Adapter REST da rotina de AGÊNCIA

@type 		function
@sample 	GTPIRJ006()
@param 	 	lJob, logical - indica se a chamada foi realizada através de JOB (.T.) ou não (.F.)
@return		Logical - informa se o processo foi finalizado com sucesso (.T.) ou não (.F.)	 	
@author 	thiago.tavares
@since 		25/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GTPIRJ006(lJob,lAuto, lMonit,cResultAuto,cXmlAuto)

	Local aArea  := GetArea()
	Local lRet   := .T.

	Default lJob := .F.
	Default cResultAuto := ''
	Default cXmlAuto    := ''

	If !lJob
		If Pergunte("GTPIRJ006", .T.)
			FwMsgRun( , {|oSelf| lRet := GI006Receb(lJob, oSelf,MV_PAR01,lAuto,@lMonit,cResultAuto,cXmlAuto)}, , STR0001)		// "Processando registros de Agência... Aguarde!"
		Endif
	Else
		lRet := GI006Receb(lJob, nil,,lAuto)
	EndIf

	RestArea(aArea)
	GTPDestroy(aArea)

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI006Receb

Função utilizada para executar o recebimento da integração e atualizar o registro

@type 		function
@sample 	GI006Receb(cRestResult, oMessage)
@param 		oRJIntegra, objeto - classe que trata da integração
			oMessage, objeto   - trata a mensagem apresentada em tela
@return 	lRet, logical      - resultado do processamento da rotina (.T. / .F.)
@author 	thiago.tavares
@since 		29/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Static Function GI006Receb(lJob, oMessage, cEmpRJ, lAuto, lMonit,cResultAuto,cXmlAuto)

	Local oRJIntegra  := GtpRjIntegra():New()
	Local oModel	  := FwLoadModel("GTPA006")
	Local oMdlGI6	  := Nil
	Local aFldDePara  := {}
	Local aDeParaXXF  := {}
	Local aCampos	  := {"GI6_FILIAL", "GI6_CODIGO"}
	Local cIntID	  := ""
	Local cIntAux	  := ""
	Local cExtID	  := ""
	Local cCode		  := ""
	Local cErro		  := ""
	Local cTagName    := ""
	Local cCampo      := ""
	Local cTipoCpo    := ""
	Local xValor      := ""
	Local nX          := 0
	Local nY          := 0
	Local nOpc		  := 0
	Local nPos        := 0
	Local nTotReg     := 0
	Local lOk		  := .F.
	Local lRet        := .T.
	Local lContinua   := .T.
	Local lOnlyInsert := .F.
	Local lOverWrite  := .F.
	Local lMessage	  := ValType(oMessage) == 'O'
	Local cRotina	  := "GTPIRJ006"
	Local aError	  := {}
	Local lPEIntId	  := Existblock("GTPINTEGID")
	Local cCodePE	  := ""

	Default cEmpRJ    := oRJIntegra:GetEmpRJ(,,cEmpAnt, cFilAnt,,.T.)
	Default cResultAuto := ''
	Default cXmlAuto    := ''
	Default lAuto 		:= .F.

	oRJIntegra:SetPath("/agencia")
	If !lAuto
		oRJIntegra:SetServico("Agencia")
	Else
		oRJIntegra:SetServico("Agencia",,,cXmlAuto)
	EndIf
	If !lAuto
		oRJIntegra:SetParam('empresa', ALLTRIM(cEmpRJ))
	Else
		oRJIntegra:SetParam('empresa', ALLTRIM("10"))
	EndIf

	aFldDePara	:= oRJIntegra:GetFieldDePara()
	aDeParaXXF  := oRJIntegra:GetFldXXF()

	If oRJIntegra:Get(cResultAuto)

		oModel:SetCommit({ || CFGA070MNT("TotalBus", "GI6", "GI6_CODIGO", cExtID, IIF(!Empty(cIntId), cIntId, GTPxMakeId(oMdlGI6:GetValue('GI6_CODIGO'), 'GI6'))) },.T.)

		GI6->(DbSetOrder(1))	// GI6_FILIAL+GI6_CODIGO
		nTotReg := oRJIntegra:GetLenItens()

		//Necessário para a automação não efetuar todos os registros de uma vez
		If lAuto
			nTotReg := 1
		EndIf

		nTotReg := IIf( (GTPDummyRunning() .and. nTotReg > GTPDummyVal()), GTPDummyVal(), nTotReg)
		If ( nTotReg >= 0 )

			For nX := 0 To nTotReg

				lContinua := .T.
				If lMessage .And. !lJob
					oMessage:SetText(I18N(STR0002, {cValtoChar(nX + 1), nTotReg + 1}))		// "Processando registros de Agência - #1/#2... Aguarde!"
					ProcessMessages()
				EndIf

				// para essa integraç?o é preciso localizar a filial. Caso n?o encontrada, pular para próximo item do JSON
				If Empty((cFilAux := oRJIntegra:GetEmpRJ(cEmpAnt, cFilAnt, oRJIntegra:GetJsonValue(nX, 'idEmpresa', 'C'), , "2")))
					Loop
				Else
					cFilAnt := cFilAux
				EndIf

				If !Empty((cExtID := oRJIntegra:GetJsonValue(nX, 'idEmpresa', 'C') + "|" + oRJIntegra:GetJsonValue(nX, 'idAgencia', 'C')))					

					cCode := GTPxRetId("TotalBus", "GI6", "GI6_CODIGO", cExtID, @cIntID, 3, @lOk, @cErro, aCampos, 1)

					If lPEIntId
						cCodePE := ExecBlock("GTPINTEGID",.F.,.F.,{"GI6_CODIGO",nX,oRJIntegra})
						If ValType(cCodePE) == "C" .AND. !Empty(cCodePE)
							cCode := cCodePE
						Endif
					EndIf

					If lPEIntId .AND. !Empty(cCodePE)
						If !GI6->(DbSeek(xFilial('GI6') + cCodePE))
							nOpc := MODEL_OPERATION_INSERT
						Else
							nOpc := MODEL_OPERATION_UPDATE
						Endif
					ElseIf Empty(cIntID)
						nOpc := MODEL_OPERATION_INSERT
					ElseIf lOk .And. GI6->(DbSeek(xFilial('GI6') + cCode))
						nOpc := MODEL_OPERATION_UPDATE
					Else
						lContinua := .F.
						If aScan(aError, {|x| AllTrim(x) == cErro}) == 0
							GtpGrvLgRj(		STR0010,; //"Agência"
											oRJIntegra:cUrl,;
											oRJIntegra:cPath,;
											cRotina,;
											oRJIntegra:cParam,;
											cErro)
							aAdd(aError, cErro)
						Endif
					EndIf

					If lContinua

						oModel:SetOperation(nOpc)
						oModel:Activate()
						oMdlGI6 := oModel:GetModel("GI6MASTER")

						For nY := 1 To Len(aFldDePara)

							// recuperando a TAG e o respectivo campo da tabela
							cTagName    := aFldDePara[nY][1]
							cCampo      := aFldDePara[nY][2]
							cTipoCpo    := aFldDePara[nY][3]
							lOnlyInsert := aFldDePara[nY][6]
							lOverWrite  := aFldDePara[nY][7]

							// recuperando através da TAG o valor a ser inserido no campo
							If !Empty(cTagName) .And. !Empty((xValor := oRJIntegra:GetJsonValue(nX, cTagName, cTipoCpo)))

								// verificando a necessidade de realizar o DePara XXF
								If (nPos := aScan(aDeParaXXF, {|x| x[1] == cCampo})) > 0
									xValor := GTPxRetId("TotalBus", aDeParaXXF[nPos, 2], aDeParaXXF[nPos, 3], xValor, @cIntAux, aDeParaXXF[nPos, 4], @lOk, @cErro, aDeParaXXF[nPos, 6], aDeParaXXF[nPos, 5])
								EndIf

								If cTagName == "interFechamento"
									cCampo := 'GI6_FCHCAI'
									if UPPER(xValor) == 'SEMANAL'
										oMdlGI6:LoadValue('GI6_FCHCAI', '2')
										oMdlGI6:LoadValue('GI6_DIASFC', 7)
									endif
									if UPPER(xValor) == 'DECENDIAL'
										oMdlGI6:LoadValue('GI6_FCHCAI', '2')
										oMdlGI6:LoadValue('GI6_DIASFC', 10)
									endif
									if UPPER(xValor) == 'QUINZENAL'
										oMdlGI6:LoadValue('GI6_FCHCAI', '2')
										oMdlGI6:LoadValue('GI6_DIASFC', 15)
									endif
									if UPPER(xValor) == 'MENSAL'
										oMdlGI6:LoadValue('GI6_FCHCAI', '2')
										oMdlGI6:LoadValue('GI6_DIASFC', 31)
									endif
								EndIf

								// para o campo GI6_MSBLQL é preciso realizar De/Para TAG enviada Status 0=Ativo e 1=Inativo
								If cCampo == "GI6_MSBLQL"
									xValor := IIF(xValor == "0", "1", "2")
								EndIf

								if cCampo != 'GI6_FCHCAI'
									If cCampo == "GI6_CODIGO" .AND. lPEIntId .AND. !Empty(cCodePE) .AND. nOpc == MODEL_OPERATION_INSERT .And. lOnlyInsert
										lContinua := oRJIntegra:SetValue(oMdlGI6, cCampo, SUBSTR(cCodePE,0,TAMSX3(cCampo)[1]))
									ElseIf nOpc == MODEL_OPERATION_INSERT .And. lOnlyInsert .And. Empty(oMdlGI6:GetValue(cCampo))
										lContinua := oRJIntegra:SetValue(oMdlGI6, cCampo, SUBSTR(xValor,0,TAMSX3(cCampo)[1]))
									ElseIf (nOpc == MODEL_OPERATION_INSERT .And. !lOnlyInsert) .Or. (nOpc == MODEL_OPERATION_UPDATE .And. lOverWrite)
										lContinua := oRJIntegra:SetValue(oMdlGI6, cCampo, SUBSTR(xValor,0,TAMSX3(cCampo)[1]))
									EndIf
								EndIf

								If !lContinua
									cErro := I18N(STR0003, {cCampo, GTPXErro(oModel)})	// "Falha ao gravar o valor do campo #1 (#2)."
									If aScan(aError, {|x| AllTrim(x) == cErro}) == 0
										GtpGrvLgRj(		STR0010,; //"Agência"
														oRJIntegra:cUrl,;
														oRJIntegra:cPath,;
														cRotina,;
														oRJIntegra:cParam,;
														cErro)
										aAdd(aError, cErro)
									Endif
									Exit

								EndIf

							EndIf

						Next nY

						If lContinua//Validar existencia do campo
							lContinua := oRJIntegra:SetValue(oMdlGI6, "GI6_ORIGEM", '1', .T.)
						EndIf

						If lContinua .And. oModel:lModify

							lContinua := oModel:VldData() .And. oModel:CommitData()

							If !lContinua

								cErro := I18N(STR0011, {GTPXErro(oModel),cExtID,cIntId})	// "Falha ao validar os dados da agência #2 (#1)."
								If aScan(aError, {|x| AllTrim(x) == cErro}) == 0
									GtpGrvLgRj(		STR0010,; //"Agência"
													oRJIntegra:cUrl,;
													oRJIntegra:cPath,;
													cRotina,;
													oRJIntegra:cParam,;
													cErro)
									aAdd(aError, cErro)
								Endif

							EndIf

						Endif

						oModel:DeActivate()

					EndIf

				EndIf

			Next nX

		Else

			lMonit := .f.
			FwAlertHelp("Não há dados a serem processados com a parametrização utilizada.") // "Não há dados a serem processados com a parametrização utilizada."

		EndIf

	Else

		cErro := I18N( STR0009, {oRJIntegra:GetLastError(),oRJIntegra:cUrl}) //"Falha ao processar o retorno do serviço #2 (#1)."
		GtpGrvLgRj(		STR0010,; //"Agência"
						oRJIntegra:cUrl,;
						oRJIntegra:cPath,;
						cRotina,;
						oRJIntegra:cParam,;
						cErro)

	EndIf

	If !lJob
		If lMessage
			oMessage:SetText(STR0012) // "Processo finalizado."
			ProcessMessages()
		EndIf
	EndIf

	oRJIntegra:Destroy()
	GTPDestroy(oModel)
	GTPDestroy(oMdlGI6)
	GTPDestroy(aFldDePara)
	GTPDestroy(aDeParaXXF)

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI006Job

Função utilizada para consumir o serviço através de um JOB

@type 		function
@sample 	GI006Job(aParams)
@param		aParam, array - lista de parâmetros 	 	
@return 	
@author 	jacomo.fernandes
@since 		28/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GI006Job(aParams, lAuto)

	Default lAuto := .F.

//---Inicio Ambiente
	RPCSetType(3)
	RpcSetEnv(aParams[1], aParams[2])

	GTPIRJ006(.T., lAuto)

	RpcClearEnv()

Return
