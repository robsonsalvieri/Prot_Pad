#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPIRJ035.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPIRJ035

Adapter REST da rotina de TIPOS DE LOCALIDADE

@type 		function
@sample 	GTPIRJ035(lJob)
@param 	 	lJob, logical - indica se a chamada foi realizada através de JOB (.T.) ou não (.F.)
@return		Logical - informa se o processo foi finalizado com sucesso (.T.) ou não (.F.)	 	
@author 	thiago.tavares
@since 		04/04/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GTPIRJ035(lJob,lAuto,lMonit)

	Local aArea  := GetArea()
	Local lRet   := .T.

	Default lJob := .F.
	Default lAuto := .F.

	If !lJob
		FwMsgRun( , {|oSelf| lRet := GI035Receb(lJob, oSelf, lAuto,@lMonit)}, , STR0001)		// "Processando registros de Tipos de Localidade... Aguarde!"
	Else
		lRet := GI035Receb(lJob, nil, lAuto)
	EndIf
	RestArea(aArea)
	GTPDestroy(aArea)

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI035Receb

Função utilizada para executar o recebimento da integração e atualizar o registro

@type 		function
@sample 	GI035Receb(lJob, oMessage)
@param 		lJob, logical    - informa se a chamada foi realizada através de job (.T.) ou não (.F.) 
			oMessage, objeto - trata a mensagem apresentada em tela
@return 	lRet, logical    - resultado do processamento da rotina (.T. / .F.)
@author 	thiago.tavares
@since 		03/04/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Static Function GI035Receb(lJob, oMessage, lAuto, lMonit)

	Local oRJIntegra  := GtpRjIntegra():New()
	Local oModel	  := FwLoadModel("GTPA035")
	Local oMdlG9V	  := Nil
	Local aFldDePara  := {}
	Local aDeParaXXF  := {}
	Local aCampos	  := {"G9V_FILIAL", "G9V_CODIGO"}
	Local cIntID	  := ""
	Local cIntAux     := ""
	Local cExtID	  := ""
	Local cCode		  := ""
	Local cErro		  := ""
	Local cTagName    := ""
	Local cCampo      := ""
	Local cTipoCpo    := ""
	Local xValor      := ""
	Local cResultAuto := ""
	Local cXmlAuto    := ""
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
	Local cRotina	  := "GTPIRJ035"
	Local aError	  := {}

	If lAuto
		cResultAuto := '{"TipoLocalidade":[{"idTipo":88,"descTipo":"TSTE WALLACE"},{"idTipo":161,"descTipo":"GARAGEM"},{"idTipo":181,"descTipo":"TESTE 2"},{"idTipo":86,"descTipo":"TROCA MOTORISTA"},{"idTipo":61,"descTipo":"EMBARQUE"},{"idTipo":81,"descTipo":"DESEMBARQUE"},{"idTipo":1,"descTipo":"EMBARQUE-DESEMBARQUE"},{"idTipo":83,"descTipo":"LANCHE"},{"idTipo":84,"descTipo":"ALMOÃ‡O"},{"idTipo":85,"descTipo":"JANTAR"},{"idTipo":221,"descTipo":"EMB. / DESEMB. LANCH"},{"idTipo":261,"descTipo":"MARINHO"},{"idTipo":241,"descTipo":"JOSE"},{"idTipo":2,"descTipo":"TESTE WALLACE 2"}]}'
		cXmlAuto    := '<?xml version="1.0" encoding="utf-8"?><RJIntegra><TipoLocalidade tagMainList="TipoLocalidade"><ListOfFields><Field><tagName>idTipo</tagName><fieldProtheus>G9V_CODIGO</fieldProtheus><onlyInsert>True</onlyInsert><overwrite>False</overwrite></Field><Field><tagName>descTipo</tagName><fieldProtheus>G9V_DESCRI</fieldProtheus><onlyInsert>False</onlyInsert><overwrite>True</overwrite></Field></ListOfFields></TipoLocalidade></RJIntegra>'
	EndIf

	oRJIntegra:SetPath("/tipoLocalidade/todas")
	If !lAuto
		oRJIntegra:SetServico("TipoLocalidade")
	Else
		oRJIntegra:SetServico("TipoLocalidade",,,cXmlAuto)
	EndIf

	aFldDePara	:= oRJIntegra:GetFieldDePara()
	aDeParaXXF  := oRJIntegra:GetFldXXF()

	If oRJIntegra:Get(cResultAuto)

		oModel:SetCommit({ || CFGA070MNT("TotalBus", "G9V", "G9V_CODIGO", cExtID, IIF(!Empty(cIntId), cIntId, GTPxMakeId(oMdlG9V:GetValue('G9V_CODIGO'), 'G9V'))) },.T.)

		G9V->(DbSetOrder(1))	// G9V_FILIAL+G9V_CODIGO
		nTotReg := oRJIntegra:GetLenItens()
		//Necessário para a automação não efetuar todos os registros de uma vez
		If lAuto
			nTotReg := 1
		EndIf

		nTotReg := IIf( (GTPDummyRunning() .and. nTotReg > GTPDummyVal()), GTPDummyVal(), nTotReg)

		If ( nTotReg >= 0)

			For nX := 0 To nTotReg
				lContinua := .T.
				If lMessage .And. !lJob
					oMessage:SetText(I18N(STR0002, {cValtoChar(nX + 1), nTotReg + 1}))		// "Processando registros de Tipos de Localidade - #1/#2... Aguarde!"
					ProcessMessages()
				EndIf

				If !Empty(cExtID := oRJIntegra:GetJsonValue(nX, 'idTipo' ,'C'))
					cCode := GTPxRetId("TotalBus", "G9V", "G9V_CODIGO", cExtID, @cIntID, 3, @lOk, @cErro, aCampos, 1)
					If Empty(cIntID)
						nOpc := MODEL_OPERATION_INSERT
					ElseIf lOk .And. G9V->(DbSeek(xFilial('G9V') + cCode))
						nOpc := MODEL_OPERATION_UPDATE
					Else
						lContinua := .F.
						If aScan(aError, {|x| AllTrim(x) == cErro}) == 0
							GtpGrvLgRj(		STR0008,; //"Tipos de localidade"
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
						oMdlG9V	:= oModel:GetModel("G9VMASTER")

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

								If nOpc == MODEL_OPERATION_INSERT .And. lOnlyInsert .And. Empty(oMdlG9V:GetValue(cCampo))
									lContinua := oRJIntegra:SetValue(oMdlG9V, cCampo, xValor)
								ElseIf (nOpc == MODEL_OPERATION_INSERT .And. !lOnlyInsert) .Or. (nOpc == MODEL_OPERATION_UPDATE .And. lOverWrite)
									lContinua := oRJIntegra:SetValue(oMdlG9V, cCampo, xValor)
								EndIf

								If !lContinua
									cErro := I18N(STR0003 , {GTPXErro(oModel),cExtID,cIntId})	// "Falha ao gravar o valor do campo #1 (#2)."
									If aScan(aError, {|x| AllTrim(x) == cErro}) == 0
										GtpGrvLgRj(		STR0008,; //"Tipos de localidade"
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
								cErro := I18N(STR0009, {GTPXErro(oModel),cExtID,cIntId})	// "Falha ao validar os dados do Tipos de localidade #2 (#1)."
								If aScan(aError, {|x| AllTrim(x) == cErro}) == 0
									GtpGrvLgRj(		STR0008,; //"Tipos de localidade"
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
		GtpGrvLgRj(		STR0008,; //"Tipos de localidade"
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
	GTPDestroy(oMdlG9V)
	GTPDestroy(aFldDePara)
	GTPDestroy(aDeParaXXF)

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI035Job

Função utilizada para consumir o serviço através de um JOB

@type 		function
@sample 	GI035Job(aParams)
@param		aParam, array - lista de parâmetros 	 	
@return 	
@author 	jacomo.fernandes
@since 		28/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GI035Job(aParam, lAuto)

	Default lAuto := .F.
//---Inicio Ambiente
	RPCSetType(3)
	RpcSetEnv(aParam[1], aParam[2])

	GTPIRJ035(.T.,lAuto)

	RpcClearEnv()

Return
