#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPIRJ005.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPIRJ005

Adapter REST da rotina de VIAS

@type 		function
@sample 	GTPIRJ005(lJob)
@param 	 	lJob, logical - indica se a chamada foi realizada através de JOB (.T.) ou não (.F.)
@return		Logical - informa se o processo foi finalizado com sucesso (.T.) ou não (.F.)	 	
@author 	thiago.tavares
@since 		04/04/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GTPIRJ005(lJob, lAuto, lMonit)

	Local aArea  := GetArea()
	Local lRet   := .T.

	Default lJob := .F.
	Default lAuto := .F.

	If !lJob
		FwMsgRun( , {|oSelf| lRet := GI005Receb(lJob, oSelf, lAuto, @lMonit)}, , STR0001)		// "Processando registros de Vias... Aguarde!"
	Else
		lRet := GI005Receb(lJob, nil,lAuto)
	EndIf
	RestArea(aArea)
	GTPDestroy(aArea)

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI005Receb

Função utilizada para executar o recebimento da integração e atualizar o registro

@type 		function
@sample 	GI005Receb(lJob, oMessage)
@param 		lJob, logical    - informa se a chamada foi realizada através de job (.T.) ou não (.F.) 
			oMessage, objeto - trata a mensagem apresentada em tela
@return 	lRet, logical    - resultado do processamento da rotina (.T. / .F.)
@author 	thiago.tavares
@since 		03/04/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Static Function GI005Receb(lJob, oMessage, lAuto, lMonit)

	Local oRJIntegra  := GtpRjIntegra():New()
	Local oModel	  := FwLoadModel("GTPA005")
	Local oMdlG9U	  := Nil
	Local aFldDePara  := {}
	Local aDeParaXXF  := {}
	Local aCampos	  := {"G9U_FILIAL", "G9U_CODIGO"}
	Local cIntID	  := ""
	Local cIntAux     := ""
	Local cExtID	  := ""
	Local cCode		  := ""
	Local cErro		  := ""
	Local cTagName    := ""
	Local cCampo      := ""
	Local cTipoCpo    := ""
	Local xValor      := ""
	Local cXmlAuto    := ""
	Local cResultAuto := ""
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
	Local cRotina	  := "GTPIRJ005"
	Local aError	  := {}

	cXmlAuto := '<?xml version="1.0" encoding="utf-8"?>'
	cXmlAuto += "<RJIntegra>"
	cXmlAuto += '	<Vias tagMainList="TipoVia">'
	cXmlAuto += "		<ListOfFields>"
	cXmlAuto += "			<Field>"
	cXmlAuto += "				<tagName>idTipo</tagName>"
	cXmlAuto += "				<fieldProtheus>G9U_CODIGO</fieldProtheus>"
	cXmlAuto += "				<onlyInsert>True</onlyInsert>"
	cXmlAuto += "				<overwrite>False</overwrite>"
	cXmlAuto += "			</Field>"
	cXmlAuto += "			<Field>"
	cXmlAuto += "				<tagName>descTipo</tagName>"
	cXmlAuto += "				<fieldProtheus>G9U_DESCRI</fieldProtheus>"
	cXmlAuto += "				<onlyInsert>False</onlyInsert>"
	cXmlAuto += "				<overwrite>True</overwrite>"
	cXmlAuto += "			</Field>"
	cXmlAuto += "		</ListOfFields>"
	cXmlAuto += "	</Vias>"
	cXmlAuto += "</RJIntegra>"

	oRJIntegra:SetPath("/tipoVia/todas")

	If !lAuto
		oRJIntegra:SetServico("Vias")
	Else
		oRJIntegra:SetServico("Vias",,,cXmlAuto)
	EndIf

	If lAuto
		cResultAuto := '{"TipoVia":[{"idTipo":1966,"descTipo":"RJ API"},{"idTipo":1685,"descTipo":"INTERNCIONAL"},{"idTipo":1785,"descTipo":"TESTE KM 01"},{"idTipo":1786,"descTipo":"TESTE KM 02"},{"idTipo":1805,"descTipo":"ROD. ANHANGUERA"},{"idTipo":1886,"descTipo":"(L017)FUNDAO"},{"idTipo":1546,"descTipo":"SANTA INES-MA"},{"idTipo":1547,"descTipo":"FELIZARDO-CE"}]}'
	EndIf

	aFldDePara	:= oRJIntegra:GetFieldDePara()
	aDeParaXXF  := oRJIntegra:GetFldXXF()

	If oRJIntegra:Get(cResultAuto)

		oModel:SetCommit({ || CFGA070MNT("TotalBus", "G9U", "G9U_CODIGO", cExtID, IIF(!Empty(cIntId), cIntId, GTPxMakeId(oMdlG9U:GetValue('G9U_CODIGO'), 'G9U'))) },.T.)

		G9U->(DbSetOrder(1))	// G9U_FILIAL+G9U_CODIGO
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
					oMessage:SetText(I18N(STR0002, {cValtoChar(nX + 1), nTotReg + 1}))		// "Processando registros de Vias - #1/#2... Aguarde!"
					ProcessMessages()
				EndIf

				If !Empty(cExtID := oRJIntegra:GetJsonValue(nX, 'idTipo' ,'C'))
					cCode := GTPxRetId("TotalBus", "G9U", "G9U_CODIGO", cExtID, @cIntID, 3, @lOk, @cErro, aCampos, 1)
					If Empty(cIntID)
						nOpc := MODEL_OPERATION_INSERT
					ElseIf lOk .And. G9U->(DbSeek(xFilial('G9U') + cCode))
						nOpc := MODEL_OPERATION_UPDATE
					Else
						lContinua := .F.
						If aScan(aError, {|x| AllTrim(x) == cErro}) == 0
							GtpGrvLgRj(		STR0008,; //"Vias"
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
						oMdlG9U	:= oModel:GetModel("G9UMASTER")

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

								If nOpc == MODEL_OPERATION_INSERT .And. lOnlyInsert .And. Empty(oMdlG9U:GetValue(cCampo))
									lContinua := oRJIntegra:SetValue(oMdlG9U, cCampo, xValor)
								ElseIf (nOpc == MODEL_OPERATION_INSERT .And. !lOnlyInsert) .Or. (nOpc == MODEL_OPERATION_UPDATE .And. lOverWrite)
									lContinua := oRJIntegra:SetValue(oMdlG9U, cCampo, xValor)
								EndIf

								If !lContinua
									cErro := I18N(STR0003 , {GTPXErro(oModel),cExtID,cIntId})	// "Falha ao gravar o valor do campo #1 (#2)."
									If aScan(aError, {|x| AllTrim(x) == cErro}) == 0
										GtpGrvLgRj(		STR0008,; //"Vias"
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
						Next nY

						If lContinua .And. oModel:lModify
							lContinua := oModel:VldData() .And. oModel:CommitData()
							If !lContinua
								cErro := I18N(STR0009, {GTPXErro(oModel),cExtID,cIntId})	// "Falha ao validar os dados da via #2 (#1)."
								If aScan(aError, {|x| AllTrim(x) == cErro}) == 0
									GtpGrvLgRj(		STR0008,; //"Vias"
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
		cErro := I18N( STR0010, {oRJIntegra:GetLastError(),oRJIntegra:cUrl}) //"Falha ao processar o retorno do serviço #2 (#1)."
		GtpGrvLgRj(		STR0008,; //"Vias"
						oRJIntegra:cUrl,;
						oRJIntegra:cPath,;
						cRotina,;
						oRJIntegra:cParam,;
						cErro)
	EndIf
	If !lJob
		If lMessage
			oMessage:SetText(STR0011) // "Processo finalizado."
			ProcessMessages()
		EndIf
	EndIf

	oRJIntegra:Destroy()
	GTPDestroy(oModel)
	GTPDestroy(oMdlG9U)
	GTPDestroy(aFldDePara)
	GTPDestroy(aDeParaXXF)

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI005Job

Função utilizada para consumir o serviço através de um JOB

@type 		function
@sample 	GI005Job(aParams)
@param		aParam, array - lista de parâmetros 	 	
@return 	
@author 	jacomo.fernandes
@since 		28/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GI005Job(aParam, lAuto)

	Default lAuto := .F.

//---Inicio Ambiente
	RPCSetType(3)
	RpcSetEnv(aParam[1], aParam[2])

	GTPIRJ005(.T.,lAuto)

	RpcClearEnv()

Return
