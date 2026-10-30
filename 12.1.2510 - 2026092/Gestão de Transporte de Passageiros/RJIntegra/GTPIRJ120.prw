#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPIRJ120.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPIRJ120

Adapter REST da rotina de TRECHOS (Pedágios)

@type 		function
@sample 	GTPIRJ120(lJob)
@param 	 	lJob, logical - indica se a chamada foi realizada através de JOB (.T.) ou não (.F.)
@return		Logical - informa se o processo foi finalizado com sucesso (.T.) ou não (.F.)	 	
@author 	thiago.tavares
@since 		03/04/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GTPIRJ120(lJob,lMonit)

	Local aArea  := GetArea()
	Local lRet   := .T.

	Default lJob := .F.

	FwMsgRun( , {|oSelf| lRet := GI120Receb(lJob, oSelf, @lMonit)}, , STR0001)		// "Processando registros de Trechos... Aguarde!"

	RestArea(aArea)
	GTPDestroy(aArea)

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI120Receb

Função utilizada para executar o recebimento da integração e atualizar o registro

@type 		function
@sample 	GI120Receb(lJob, oMessage)
@param 		lJob, logical    - informa se a chamada foi realizada através de job (.T.) ou não (.F.) 
			oMessage, objeto - trata a mensagem apresentada em tela
@return 	lRet, logical    - resultado do processamento da rotina (.T. / .F.)
@author 	thiago.tavares
@since 		03/04/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Static Function GI120Receb(lJob, oMessage, lMonit)

	Local oRJIntegra  := GtpRjIntegra():New()
	Local oModel	  := FwLoadModel("GTPA120")
	Local oMdlG9T	  := Nil
	Local aFldDePara  := {}
	Local aDeParaXXF  := {}
	Local aCampos	  := {"G9T_FILIAL", "G9T_CODIGO"}
	Local cIntID	  := ""
	Local cIntAux     := ""
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
	Local nTotReg     := 0
	Local lOk		  := .F.
	Local lRet        := .T.
	Local lContinua   := .T.
	Local lOnlyInsert := .F.
	Local lOverWrite  := .F.
	Local lMessage	  := ValType(oMessage) == 'O'
	Local cRotina	  := "GTPIRJ120"
	Local aError	  := {}

	oRJIntegra:SetPath("/trecho/todos")
	oRJIntegra:SetServico("Trecho")

	aFldDePara	:= oRJIntegra:GetFieldDePara()
	aDeParaXXF  := oRJIntegra:GetFldXXF()

	If oRJIntegra:Get()

		oModel:SetCommit({ || CFGA070MNT("TotalBus", "G9T", "G9T_CODIGO", cExtID, IIF(!Empty(cIntId), cIntId, GTPxMakeId(oMdlG9T:GetValue('G9T_CODIGO'), 'G9T'))) },.T.)

		G9T->(DbSetOrder(1))	// G9T_FILIAL+G9T_CODIGO
		nTotReg := oRJIntegra:GetLenItens()

		nTotReg := IIf( (GTPDummyRunning() .and. nTotReg > GTPDummyVal()), GTPDummyVal(), nTotReg)

		If ( nTotReg >= 0 )

			For nX := 0 To nTotReg
				lContinua := .T.
				If lMessage .And. !lJob
					oMessage:SetText(I18N(STR0002, {cValtoChar(nX + 1), nTotReg + 1}))		// "Processando registros de Trechos - #1/#2... Aguarde!"
					ProcessMessages()
				EndIf

				If !Empty(cExtID := oRJIntegra:GetJsonValue(nX, 'idTrecho' ,'C'))
					cCode := GTPxRetId("TotalBus", "G9T", "G9T_CODIGO", cExtID, @cIntID, 3, @lOk, @cErro, aCampos, 1)
					If Empty(cIntID)
						nOpc := MODEL_OPERATION_INSERT
					ElseIf lOk .And. G9T->(DbSeek(xFilial('G9T') + cCode))
						nOpc := MODEL_OPERATION_UPDATE
					Else
						lContinua := .F.
						If aScan(aError, {|x| AllTrim(x) == cErro}) == 0
							GtpGrvLgRj(		STR0008,; //"Trechos (Pedágio)"
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
						oMdlG9T	:= oModel:GetModel("G9TMASTER")

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

								If nOpc == MODEL_OPERATION_INSERT .And. lOnlyInsert .And. Empty(oMdlG9T:GetValue(cCampo))
									lContinua := oRJIntegra:SetValue(oMdlG9T, cCampo, xValor)
								ElseIf (nOpc == MODEL_OPERATION_INSERT .And. !lOnlyInsert) .Or. (nOpc == MODEL_OPERATION_UPDATE .And. lOverWrite)
									lContinua := oRJIntegra:SetValue(oMdlG9T, cCampo, xValor)
								EndIf

								If !lContinua
									cErro := I18N(STR0003 , {GTPXErro(oModel),cExtID,cIntId})	// "Falha ao gravar o valor do campo #1 (#2)."
									If aScan(aError, {|x| AllTrim(x) == cErro}) == 0
										GtpGrvLgRj(		STR0008,; //"Trechos (Pedágio)"
														oRJIntegra:cUrl,;
														oRJIntegra:cPath,;
														cRotina,;
														oRJIntegra:cParam,;
														cErro)
										aAdd(aError, cErro)
										EXIT
									Endif
								EndIf


							EndIf
						Next nX

						If lContinua .And. oModel:lModify
							lContinua := oModel:VldData() .And. oModel:CommitData()
							If !lContinua
								cErro := I18N(STR0009, {GTPXErro(oModel),cExtID,cIntId})	// "Falha ao validar os dados do trecho #2 (#1)."
								If aScan(aError, {|x| AllTrim(x) == cErro}) == 0
									GtpGrvLgRj(		STR0008,; //"Trechos (Pedágio)"
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
			FwAlertHelp("Não há dados a serem processados com a parametrização utilizada.")
		EndIf
	Else

		cErro := I18N( STR0006, {oRJIntegra:GetLastError(),oRJIntegra:cUrl}) //"Falha ao processar o retorno do serviço #2 (#1)."
		GtpGrvLgRj(		STR0008,; //"Trechos (Pedágio)"
						oRJIntegra:cUrl,;
						oRJIntegra:cPath,;
						cRotina,;
						oRJIntegra:cParam,;
						cErro)

	EndIf

	If !lJob
		If lMessage
			oMessage:SetText(STR0007) // "Processo finalizado."
			ProcessMessages()
		EndIf
	EndIf

	oRJIntegra:Destroy()
	GTPDestroy(oModel)
	GTPDestroy(oMdlG9T)
	GTPDestroy(aFldDePara)
	GTPDestroy(aDeParaXXF)

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI120Job

Função utilizada para consumir o serviço através de um JOB

@type 		function
@sample 	GI120Job(aParams)
@param		aParam, array - lista de parâmetros 	 	
@return 	
@author 	thiago.tavares
@since 		03/04/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GI120Job(aParam)

//---Inicio Ambiente
	RPCSetType(3)
	RpcSetEnv(aParam[1], aParam[2])

	GTPIRJ120(.T.)

	RpcClearEnv()

Return
