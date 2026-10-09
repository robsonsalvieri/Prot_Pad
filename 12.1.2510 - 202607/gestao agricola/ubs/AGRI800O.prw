#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "AGRI800.CH"

Static cMessage := "AgriculturalCulture"
Static cModelId := "AGRA800"
Static nTamCod  := TamSX3("NP3_CODIGO")[1]

/*/{Protheus.doc} AGRI800O
Função de integração com o adapter EAI para envio e recebimento do cadastro de
culturas (NP3) utilizando o conceito de mensagem única no formato JSON.
@type function
@version 12
@author jc.maldonado / claudineia.reinert
@since 10/03/2026
@param oEAIdef, object, objeto eai formato JSON
@param cTypeTrans, character, Tipo de transação (Envio / Recebimento).
@param cTypeMsg, character, Tipo de mensagem (Business Type, WhoIs, etc).
@param cVersion, character, Versão da mensagem.
@param cTransac, character, Nome da transação.
@return array, Contém o resultado da execução e a mensagem XML de retorno.
       aRet[1] - (logical)  Indica o resultado da execução da função
       aRet[2] - (character) Mensagem XML para envio
       aRet[3] - (character) Nome da mensagem
/*/
Function AGRI800O(oEAIdef, cTypeTrans, cTypeMsg, cVersion, cTransac)
	Local aRet := {.F., "", cMessage}

	If (cTypeMsg == EAI_MESSAGE_WHOIS)
		aRet[1] := .T.
		aRet[2] := cVersion

	ElseIf (cTypeTrans == TRANS_SEND .or. cTypeTrans == TRANS_RECEIVE)
		If Left( cVersion, 1 ) == "2"
			aRet := v2000(oEAIdef, cTypeTrans, cTypeMsg, cVersion)
		Else
			aRet[2] := STR0001  // "A versão da mensagem informada não foi implementada!"
		Endif
	Endif
Return aRet

/*/{Protheus.doc} v2000
Implementação do adapter EAI, versão 2.x
@type function
@version 12
@author jc.maldonado / claudineia.reinert
@since 10/03/2026
@param oEAIdef, object, objeto eai formato JSON
@param cTypeTrans, character, Tipo de transação (Envio / Recebimento).
@param cTypeMsg, character, Tipo de mensagem (Business Type, WhoIs, etc).
@param cVersion, character, Versão da mensagem.
@return array, Contém o resultado da execução e a mensagem XML de retorno.
       aRet[1] - (logical)  Indica o resultado da execução da função
       aRet[2] - (character) Mensagem XML para envio
       aRet[3] - (character) Nome da mensagem
/*/
Static Function v2000(oEAIdef, cTypeTrans, cTypeMsg, cVersion)
	Local lRet       := .F.
	Local nX

	Local oModel, cRefer, nMVCOper
	Local aErro, cErro

	Local lFound     := .F.
	Local xValue     := nil
	Local aValInt    := {}
	Local cValInt    := ""
	Local cValExt    := ""
	Local cEvent     := 'upsert'
	Local oFwEAIobj  := FWEAIobj():NEW()
	Local oIntID     := nil

	If (cTypeTrans == TRANS_SEND)
		If (cTypeMsg == EAI_MESSAGE_BUSINESS)
			lRet    := .T.
			oModel  := FwModelActive()
			cValInt := oModel:GetValue('NP3MASTER', 'NP3_CODIGO')

			If oModel:GetOperation() = MODEL_OPERATION_DELETE
				cEvent := 'delete'
			EndIf

			oFwEAIobj:Activate()

			//BusinessEvent
			oFwEAIobj:setHeader("Entity", cMessage)
			ofwEAIObj:setEvent(cEvent)

			//BusinessContent
			ofwEAIObj:setprop("CompanyId", RTrim(cEmpAnt))
			ofwEAIObj:setprop("BranchId", RTrim(cFilAnt))
			ofwEAIObj:setprop("CompanyInternalId", RTrim(cEmpAnt + '|' + cFilAnt))
			ofwEAIObj:setprop("InternalId", AI800IntId(nil, cValInt))
			ofwEAIObj:setprop("Code", RTrim(cValInt))

			If oModel:GetOperation() <> MODEL_OPERATION_DELETE
				ofwEAIObj:setprop("Description", RTrim(oModel:GetValue('NP3MASTER', 'NP3_OBS')))
				ofwEAIObj:setprop("ShortDescription", RTrim(oModel:GetValue('NP3MASTER', 'NP3_DESCRI')))
				ofwEAIObj:setprop("PlantationType", RTrim(oModel:GetValue('NP3MASTER', 'NP3_TIPO')))
				ofwEAIObj:setprop("PlantationDateType", RTrim(oModel:GetValue('NP3MASTER', 'NP3_DTPLAN')))
				ofwEAIObj:setprop("AgeCalculationType", RTrim(oModel:GetValue('NP3MASTER', 'NP3_BASE')))
				ofwEAIObj:setprop("EstimateType", RTrim(oModel:GetValue('NP3MASTER', 'NP3_TPEST')))
				ofwEAIObj:setprop("RoundingType", RTrim(oModel:GetValue('NP3MASTER', 'NP3_TPARRE')))
			Endif
		Endif

	ElseIf (cTypeTrans == TRANS_RECEIVE)
		If (cTypeMsg == EAI_MESSAGE_RESPONSE)  // Resposta da mensagem única TOTVS.
			// Gravo o de/para local, caso tenha sido gravado o dado no sistema remoto.
			lRet := .T.

			If oEAIdef:getPropValue("ProcessingInformation"):getPropValue("Status") != nil;
					.And. Upper(oEAIdef:getPropValue("ProcessingInformation"):getPropValue("Status")) == "OK"

				cRefer := oEAIdef:getHeaderValue("ProductName")
				cEvent := AllTrim(Upper(oEAIdef:getPropValue("ReceivedMessage"):getPropValue("Event")))
				oIntID := oEAIdef:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")
				For nX := 1 to len(oIntID)
					cValExt := oIntID[nX]:getPropValue("Destination")
					cValInt := oIntID[nX]:getPropValue("Origin")
					If cEvent = 'DELETE' .and. cValInt != nil .and. !empty(cValInt)
						CFGA070Mnt(cRefer, "NP3", "NP3_CODIGO", nil, cValInt, .T.)
					ElseIf cValInt != nil .and. !empty(cValInt) .and. cValExt != nil .and. !empty(cValExt)
						CFGA070Mnt(cRefer, "NP3", "NP3_CODIGO", cValExt, cValInt)
					Else
						lRet  := .F.
						cErro := STR0002 + "|"  // "Erro no processamento pela outra aplicação"
						cErro += STR0003        // "Erro ao processar de/para de códigos."
					Endif
				Next nX
			Else
				lRet  := .F.
				cErro := STR0002 + "|"  // "Erro no processamento pela outra aplicação|"

				oMsgError := oEAIdef:getpropvalue("ProcessingInformation"):getpropvalue("ListOfMessages") 
				For nX := 1 To Len(oMsgError)
					cErro += oMsgError[nX]:getpropvalue("Message") + "|"
				Next nX
			Endif

		ElseIf (cTypeMsg == EAI_MESSAGE_RECEIPT)  // Recibo.
			// Não realiza nenhuma ação.

		ElseIf (cTypeMsg == EAI_MESSAGE_BUSINESS)  // Chegada de mensagem de negócios.
			lRet    := .T.
			cRefer  := oEAIdef:getHeaderValue("ProductName")
			cEvent  := AllTrim(Upper(oEAIdef:getEvent()))
			cValExt := oEAIdef:getPropValue("InternalId")
			cValInt := RTrim(CFGA070Int(cRefer, "NP3", "NP3_CODIGO", cValExt))
			aValInt := StrToKarr2(cValInt, "|", .T.)

			// Verifica se encontrou uma chave no de/para.
			If len(aValInt) > 2
				NP3->(dbSetOrder(1))  // NP3_FILIAL, NP3_CODIGO.
				lFound := NP3->(dbSeek(xFilial(nil, aValInt[2]) + aValInt[3], .F.))
			Endif

			If lFound
				If cEvent == 'UPSERT'
					nMVCOper := MODEL_OPERATION_UPDATE
				ElseIf cEvent == 'DELETE'
					nMVCOper := MODEL_OPERATION_DELETE
				Else
					lRet  := .F.
					cErro := STR0004  // "Operação inválida. Somente são permitidas as operações UPSERT e DELETE."
				Endif
			Else
				If cEvent == 'UPSERT'
					nMVCOper := MODEL_OPERATION_INSERT
				ElseIf cEvent == 'DELETE'
					lRet  := .F.
					cErro := STR0005  // "Registro não encontrado no Protheus."
				Else
					lRet  := .F.
					cErro := STR0004  // "Operação inválida. Somente são permitidas as operações UPSERT e DELETE."
				Endif
			Endif

			If lRet
				oModel := FwLoadModel(cModelId)
				oModel:SetOperation(nMVCOper)
				If oModel:Activate()
					If nMVCOper <> MODEL_OPERATION_DELETE
						// Se for inclusão, trata o código do registro.
						If nMVCOper == MODEL_OPERATION_INSERT
							// Usa o inicializador padrão do campo de código.
							cValInt := oModel:GetValue('NP3MASTER', 'NP3_CODIGO')

							// Se o código não tiver inicializador padrão, tenta usar o código do sistema de origem.
							If empty(cValInt)
								If oEAIdef:getPropValue("Code") != nil
									cValInt := RTrim(oEAIdef:getPropValue("Code"))
								Endif

								// Se o código for maior do que o campo do Protheus, não usar esse código.
								If len(cValInt) > nTamCod
									cValInt := ""
								Endif
							Endif

							// Se o código já existir na base, não usar esse código.
							If !empty(cValInt)
								cValInt := PadR(cValInt, nTamCod)
								NP3->(dbSetOrder(1))  // NP3_FILIAL, NP3_CODIGO.
								If NP3->(dbSeek(xFilial() + cValInt, .F.))
									cValInt := ""
								Endif
							Endif

							// Se não puder usar o mesmo código da origem, usa numeração sequencial automática.
							If empty(cValInt)
								cValInt := GetSXENum('NP3', 'NP3_CODIGO')
							Endif

							// Atualiza o código no modelo.
							If oModel:GetValue('NP3MASTER', 'NP3_CODIGO') <> cValInt
								oModel:SetValue('NP3MASTER', 'NP3_CODIGO', cValInt)
							Endif

							cValInt := AI800IntId(nil, cValInt)
						Endif

						If oEAIdef:getPropValue("Description") != nil
							xValue := oEAIdef:getPropValue("Description")
							oModel:SetValue('NP3MASTER', 'NP3_OBS',    xValue)
						Endif
						If oEAIdef:getPropValue("ShortDescription") != nil
							xValue := oEAIdef:getPropValue("ShortDescription")
							oModel:SetValue('NP3MASTER', 'NP3_DESCRI', xValue)
						Endif
						If oEAIdef:getPropValue("PlantationType") != nil
							xValue := oEAIdef:getPropValue("PlantationType")
							oModel:SetValue('NP3MASTER', 'NP3_TIPO', xValue)
						Endif
						If oEAIdef:getPropValue("PlantationDateType") != nil
							xValue := oEAIdef:getPropValue("PlantationDateType")
							oModel:SetValue('NP3MASTER', 'NP3_DTPLAN', xValue)
						Endif
						If oEAIdef:getPropValue("AgeCalculationType") != nil
							xValue := oEAIdef:getPropValue("AgeCalculationType")
							oModel:SetValue('NP3MASTER', 'NP3_BASE', xValue)
						Endif
						If oEAIdef:getPropValue("EstimateType") != nil
							xValue := oEAIdef:getPropValue("EstimateType")
							oModel:SetValue('NP3MASTER', 'NP3_TPEST', xValue)
						Endif
						If oEAIdef:getPropValue("RoundingType") != nil
							xValue := oEAIdef:getPropValue("RoundingType")
							oModel:SetValue('NP3MASTER', 'NP3_TPARRE', xValue)
						Endif
					Endif
					lRet := oModel:VldData() .and. oModel:CommitData()

					// Se gravou certo, retorna o código gravado.
					If lRet
						// Atualiza o de/para local.
						If nMVCOper = MODEL_OPERATION_DELETE
							CFGA070Mnt(cRefer, "NP3", "NP3_CODIGO", nil, cValInt, .T.)
						ElseIf nMVCOper = MODEL_OPERATION_INSERT
							CFGA070Mnt(cRefer, "NP3", "NP3_CODIGO", cValExt, cValInt)
						Endif

						ofwEAIObj:Activate()
						ofwEAIObj:setProp("ReturnContent")
						ofwEAIObj:getPropValue("ReturnContent"):setProp("ListOfInternalID",{},'InternalId',,.T.)
						ofwEAIObj:getPropValue("ReturnContent"):get("ListOfInternalID")[1]:setprop("Origin",cValExt,,.T.)
						ofwEAIObj:getPropValue("ReturnContent"):get("ListOfInternalID")[1]:setprop("Destination",cValInt,,.T.)
					Endif
				Else
					lRet  := .F.
					cErro := StrTran(STR0006, "%cModelId%", cModelId)  // "Erro ao ativar modelo %cModelId%."
				Endif

				If !lRet
					cErro := STR0007 + STR0010  // "A integração não foi bem sucedida. " // "Verifique os dados enviados."
					aErro := oModel:GetErrorMessage()
					If !Empty(aErro)
						cErro += STR0008 + Alltrim(aErro[5]) + '-' + AllTrim(aErro[6])  // "Foi retornado o seguinte erro: "
						If !Empty(Alltrim(aErro[7]))
							cErro += CRLF + STR0009 + AllTrim(aErro[7])  // "Solução: "
						Endif
					Endif
				Endif
				oModel:Deactivate()
				oModel:Destroy()
				oModel := nil
			Endif
		Else
			lRet := .F.
		Endif
	Endif

	DelClassIntF()

	// Se deu erro no processamento.
	If !empty(cErro)
		lRet := .F.
		oFwEAIobj:Activate()
		oFwEAIobj:setProp("ReturnContent")
		oFwEAIobj:getPropValue("ReturnContent"):setProp("Error", cErro)
	Endif

Return {lRet, oFwEAIobj, cMessage}
