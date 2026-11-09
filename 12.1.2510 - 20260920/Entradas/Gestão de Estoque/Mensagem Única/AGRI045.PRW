#Include 'Protheus.ch'
#Include 'fwAdapterEAI.ch'
#Include 'FWMVCDEF.CH'
#Include 'AGRI045.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} AGRI045
Funcao de integracao com o adapter EAI para envio e recebimento do
cadastro de locais de estoque (NNR) utilizando o conceito de mensagem unica.

@param   xEnt          Variavel com conteudo xml (lEAIObj=.F.) ou objeto FWEAIObj/JSON (lEAIObj=.T.) para envio/recebimento.
@param   nTypeTrans    Tipo de transacao. (TRANS_SEND / TRANS_RECEIVE)
@param   cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)
@param   cVersion      Versao da mensagem unica. (Ex.: 1.000)
@param   cTransac      Nome da transacao.
@param   lEAIObj       Indica se a mensagem e objeto EAI/JSON (.T.) ou XML (.F.).

@author  Mateus Gustavo de Freitas e Silva
@version P11
@since   17/07/2012
@module  SIGAEST
@return  aRet - Array contendo o resultado da execucao e a mensagem Xml de retorno.
			aRet[1] - (boolean) Indica o resultado da execução da função
			aRet[2] - (caracter) Mensagem Xml para envio

@obs     O método irá retornar um objeto do tipo TOTVSBusinessEvent caso
			o tipo da mensagem seja EAI_BUSINESS_EVENT ou um tipo
			TOTVSBusinessRequest caso a mensagem seja do tipo TOTVSBusinessRequest.
			O tipo da classe pode ser definido com a função EAI_BUSINESS_REQUEST.
/*/
//-------------------------------------------------------------------
Function AGRI045(xEnt,nTypeTrans,cTypeMessage, cVersion, cTransac, lEAIObj )
Local cError   := ""
Local cWarning := ""
Local cVersao  := ""
Local lRet     := .T.
Local cRet     := ""
Local cXmlRet  := ""
Local aRet     := { .T., "" }
Local aAux     := { .F., "" }

Private lIntegPPI := .F.

//Verifica se está sendo executado para realizar a integração com o PPI.
//Se a variável lRunPPI estiver definida, e for .T., assume que é para o PPI.
//Variável é criada no fonte AGRA045.prw, na função AGRA045PPI().
If Type("lRunPPI") == "L" .And. lRunPPI
	lIntegPPI := .T.
EndIf

If !lEAIObj
	If nTypeTrans == TRANS_RECEIVE
		If cTypeMessage == EAI_MESSAGE_BUSINESS .OR. cTypeMessage == EAI_MESSAGE_RESPONSE
			oXml := xmlParser(xEnt, "_", @cError, @cWarning)

			If oXml != Nil .And. Empty(cError) .And. Empty(cWarning)
				If Type("oXml:_TOTVSMessage:_MessageInformation:_version:Text") != "U" .AND. !Empty(oXml:_TOTVSMessage:_MessageInformation:_version:Text)
					cVersao	:= StrTokArr(oXml:_TOTVSMessage:_MessageInformation:_version:Text, ".")[1]
				Else
					lRet     := .F.
					aAux := { lRet , 	STR0033 } //"Versão do local de estoque não suportada."
				EndIf
			Else
				lRet := .F.
				aAux := { lRet , 	STR0008 } //"Erro no parser!"
			EndIf

			If lRet
				If cVersao == "1"
					aAux := v1000(xEnt, nTypeTrans, cTypeMessage)
				Else
					aAux := { .F. , 	STR0033 } //"Versão do local de estoque não suportada."
				EndIf
			EndIf
			aRet := { aAux[1], aAux[2], 'WAREHOUSE' }

		ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
			cXmlRet := "1.000|1.001|1.002|1.003"
			aAux := { lRet , cXmlRet  }

		EndIf

		aRet := { aAux[ 1 ] , aAux[ 2 ], 'WAREHOUSE' }

	ElseIf nTypeTrans == TRANS_SEND
		If lIntegPPI
			aAux := v1000(xEnt, nTypeTrans, cTypeMessage)
		Else
			cVersao := StrTokArr(cVersion, ".")[1]
			If Empty(cVersao)
				lRet := .F.
				aAux := { lRet , STR0033  } //"Versão do local de estoque não suportada."
			EndIf

			If lRet
				If cVersao == "1"
					aAux := v1000(xEnt, nTypeTrans, cTypeMessage)
				Else
					lRet := .F.
					aAux := { lRet , STR0033 } 	//"Versão do local de estoque não suportada."
				EndIf
			EndIf

		EndIf
		aRet := { aAux[ 1 ] , aAux[ 2 ], 'WAREHOUSE' }

	EndIf

Else
	//FORMATO JSON
	If nTypeTrans == TRANS_RECEIVE
		If cTypeMessage == EAI_MESSAGE_BUSINESS .Or. cTypeMessage == EAI_MESSAGE_RESPONSE
			aAux := v1000J(xEnt, nTypeTrans, cTypeMessage)
		ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
			cRet := "1.000|1.001|1.002|1.003"
			aAux := { lRet , cRet }
		EndIf
		aRet := { aAux[ 1 ] , aAux[ 2 ], 'WAREHOUSE' }

	ElseIf nTypeTrans == TRANS_SEND
		If lIntegPPI
			aAux := v1000J( xEnt, nTypeTrans, cTypeMessage )
		Else
			cVersao := StrTokArr(cVersion, ".")[1]
			If Empty(cVersao)
				lRet := .F.
				aAux := { lRet , STR0033 } //"Versão do local de estoque não suportada."
			EndIf

			If lRet
				If cVersao == "1"
					aAux := v1000J(xEnt, nTypeTrans, cTypeMessage)
				Else
					lRet := .F.
					aAux := { lRet , STR0033 } //"Versão do local de estoque não suportada."
				EndIf
			EndIf
		EndIf
		aRet := { aAux[ 1 ] , aAux[ 2 ], 'WAREHOUSE' }

	EndIf
EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} V1000
Funcao de integracao com o adapter EAI para envio e recebimento do
cadastro de Local de Estoque utilizando o conceito de mensagem unica.
@type function
@param Caracter, cXML, Variavel com conteudo xml para envio/recebimento.
@param Numérico, nTypeTrans, Tipo de transacao. (Envio/Recebimento)
@param Caracter, cTypeMessage, Tipo de mensagem. (Business Type, WhoIs, etc)
@param Objeto, oXml, Objeto xml com a mensagem recebida.

@author rodrigo.mpontes
@version P12
@since 21/10/2015
@return Array, Array contendo o resultado da execucao e a mensagem Xml de retorno.
		aRet[1] - (boolean) Indica o resultado da execução da função
		aRet[2] - (caracter) Mensagem Xml para envio
/*/
//-------------------------------------------------------------------
Static Function V1000(xEnt, nTypeTrans, cTypeMessage)

	Local cXmlRet   := ""
	Local cEntity   := "Warehouse"
	Local cEvent    := ""
	Local lRet      := .T.
	Local nOpcx     := 0
	Local cAlias    := "NNR"
	Local cField    := "NNR_CODIGO"
	Local nCount    := 0
	Local cError    := ""
	Local cWarning  := ""
	Local cValInt   := ""
	Local cValExt   := ""
	Local cProduct  := ""
	Local cCode     := ""
	Local nI        := 0
	Local aLocalEst := {}
	Local aAux      := {}
	Local aErro     := {}
	Local lInicPad  := .F.
	Local cWHECommer	:= GetNewPar("MV_LJECOMG","01")
	Local cWHDefault	:= GetNewPar("MV_LJECLPE","01")
	Local nX         := 0
	Local cXMLOrigin := ""
	Local oXMLOrigin := NIL

	Private oXML      := Nil
	Private lIntegPPI := .F.

	// oModel e oModelNNR: Private herdadas do caller (AGRA045PPI via TOTVS MES/PPI).
	// Quando chamada fora do contexto PPI (TRANS_RECEIVE), oModel é criada localmente via FWLoadModel().

	//Verifica se está sendo executado para realizar a integração com o PPI.
	//Se a variável lRunPPI estiver definida, e for .T., assume que é para o PPI.
	//Variável é criada no fonte AGRA045.prw, na função AGRA045PPI().
	If Type("lRunPPI") == "L" .And. lRunPPI
		lIntegPPI := .T.
	EndIf

	//Mensagem de Entrada
	If nTypeTrans == TRANS_RECEIVE
		If cTypeMessage == EAI_MESSAGE_BUSINESS
			// Faz o parser do xml em um objeto
			oXML := xmlParser(xEnt, "_", @cError, @cWarning)

			// Se não houve erros no parser
			If oXML != Nil .And. Empty(cError) .And. Empty(cWarning)
				// Verifica se a marca foi informada
				If Type("oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text") != "U" .And. !Empty(oXML:_TotvsMessage:_MessageInformation:_Product:_Name:Text)
					cProduct := oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text
				Else
					lRet := .F.
					cXmlRet := STR0001 // "A marca é obrigatória"
					Return {lRet, cXmlRet}
				EndIf

				// Verifica se o InternalId foi informado
				If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text)
					cValExt := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text
				Else
					lRet := .F.
					cXmlRet := STR0002 // "O InternalId é obrigatório!"
					Return {lRet, cXmlRet}
				EndIf

				aAux := IntLocInt(cValExt,cProduct)

				If Upper(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
					If !aAux[1]
						nOpcx := 3
					Else
						nOpcx := 4
						cCode := aAux[2,3]
					Endif
				Elseif Upper(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
					If !aAux[1]
						lRet := .F.
						cXmlRet := STR0005 // "O registro a ser excluído não existe na base Protheus"
						Return {lRet, cXmlRet}
					Else
						nOpcx := 5
						cCode := aAux[2,3]
					Endif
				Endif

				lInicPad := .T.
				If Empty(Posicione("SX3", 2, PADR("NNR_CODIGO", 10), "X3_RELACAO"))
					lInicPad := .F.
				Endif

				If !lInicPad .And. nOpcx == 3
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text)
						If Len(AllTrim(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text)) > TamSX3('NNR_CODIGO')[1]
							lRet := .F.
							cXmlRet := STR0038+ AllTrim(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text) + STR0039  + Chr(10) //"O Codigo do Local de Estoque " ## " possui tamanho maior que o permitido."
							cXmlRet += STR0040 + CValToChar(TamSx3("NNR_CODIGO")[1]) + Chr(10) //"Maximo:"
							cXmlRet += STR0041 + CValToChar(Len(AllTrim(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text))) //"Enviado:"

							Return {lRet, cXmlRet}
						Else
							cCode := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text
						EndIf
					Else
						lRet := .F.
						cXmlRet := STR0003 // "O Code é obrigatório!"
						Return {lRet, cXmlRet}
					Endif
				Endif

				If !Empty(cCode) .And. (!lInicPad .And. nOpcx == 3)
					aAdd(aLocalEst, {"NNR_CODIGO", cCode, Nil}) // Código do Local
				Endif

				If nOpcx <> 3
					NNR->(DbSetOrder(1))
					lRet := NNR->(dbSeek(xFilial("NNR") + PadR(cCode, TamSX3("NNR_CODIGO")[1])))

					If !lRet
						cXmlRet := I18N(STR0042, {AllTrim(cCode)}) //  "Local de estoque: #1 não encontrado para alteração ou exclusão" 
						Return {lRet,cXmlRet}
					Endif
				Endif

				oModel := FWLoadModel('AGRA045')

				If nOpcx == 3
					oModel:SetOperation(MODEL_OPERATION_INSERT)
				ElseIf nOpcx == 4
					oModel:SetOperation(MODEL_OPERATION_UPDATE)
				Elseif nOpcx == 5
					oModel:SetOperation(MODEL_OPERATION_DELETE)
				Endif

				If nOpcx <> 5
					// Verifica se a descrição do local foi informada
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Description:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Description:Text)
						If Len(AllTrim(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Description:Text)) > TamSX3('NNR_DESCRI')[1]
							lRet := .F.
							cXmlRet := STR0021 // "A Descrição do Local não pode ser maior que 20 caracteres!"
							Return {lRet, cXmlRet}
						Else
							aAdd(aLocalEst, {"NNR_DESCRI", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Description:Text, Nil}) // Descricao do Local
						EndIf
					Else
						lRet := .F.
						cXmlRet := STR0004 // "A Descrição do Local é obrigatória!"
						Return {lRet, cXmlRet}
					EndIf

					// Obtém o Tipo do Local
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Type:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Type:Text)
						aAdd(aLocalEst, {"NNR_TIPO", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Type:Text, Nil}) // Tipo do Local
					EndIf

					If nOpcx == 4
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Active:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Active:Text)
							If AllTrim(Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Active:Text)) == "FALSE" .And. NNR->(FieldPos('NNR_MSBLQL')) > 0
								aAdd(aLocalEst, {"NNR_MSBLQL", '1', Nil})
							Endif
						Endif
					EndIf
				Endif

				oModel:Activate()

				// Obtém a estrutura de dados
				aAux := oModel:GetModel('NNRMASTER'):GetStruct():GetFields()

				If oModel:nOperation != MODEL_OPERATION_DELETE
					For nI := 1 To Len(aLocalEst)
						// Verifica se os campos passados existem na estrutura do modelo
						// Não enviar a filial e o código ao alterar
						If aScan(aAux, {|x| AllTrim(x[3]) == AllTrim(aLocalEst[nI][1])}) > 0 .And. (aLocalEst[nI][1] != "NNR_CODIGO" .Or. (!lInicPad .And. nOpcx == 3))
							// é feita a atribuição do dado ao campo do Model
							oModel:SetValue('NNRMASTER', aLocalEst[nI][1], aLocalEst[nI][2])
						EndIf
					Next nI
				EndIf

				// Se os dados não são válidos
				If !oModel:VldData()
					// Obtém o log de erros
					aErro := oModel:GetErrorMessage()

					cXmlRet := "<![CDATA["
					cXmlRet += STR0024 + AllToChar(aErro[6]) + CRLF // "Mensagem do erro: "
					cXmlRet += STR0025 + AllToChar(aErro[7]) + CRLF // "Mensagem da solução: "
					cXmlRet += STR0026 + AllToChar(aErro[8]) + CRLF // "Valor atribuído: "
					cXmlRet += STR0027 + AllToChar(aErro[9]) + CRLF // "Valor anterior: "
					cXmlRet += STR0028 + AllToChar(aErro[1]) + CRLF // "Id do formulário de origem: "
					cXmlRet += STR0029 + AllToChar(aErro[2]) + CRLF // "Id do campo de origem: "
					cXmlRet += STR0030 + AllToChar(aErro[3]) + CRLF // "Id do formulário de erro: "
					cXmlRet += STR0031 + AllToChar(aErro[4]) + CRLF // "Id do campo de erro: "
					cXmlRet += STR0032 + AllToChar(aErro[5])        // "Id do erro: "
					cXmlRet += "]]>"

					lRet := .F.
				Else
					// Se o dados foram validados faz-se a gravação efetiva dos dados (commit)
					oModel:CommitData()

					// Se o evento é diferente de DELETE
					If oModel:nOperation != MODEL_OPERATION_DELETE
						CFGA070Mnt(cProduct, cAlias, cField, cValExt, IntLocExt(, , NNR->NNR_CODIGO)[2], .F.)
					Else
						// Exclui o registro na tabela XXF (de/para)
						CFGA070Mnt(cProduct, cAlias, cField, cValExt, IntLocExt(, , cCode)[2], .T.)
					EndIf

					// Monta o XML de Retorno
					cXmlRet := "<ListOfInternalId>"
					cXmlRet +=    "<InternalId>"
					cXmlRet +=       "<Name>" + cEntity + "</Name>"
					cXmlRet +=       "<Origin>" + cValExt + "</Origin>"
					If oModel:nOperation != MODEL_OPERATION_DELETE
						cXmlRet +=       "<Destination>" + IntLocExt(, , NNR->NNR_CODIGO)[2] + "</Destination>"
					Else
						cXmlRet +=       "<Destination>" + IntLocExt(, , cCode)[2] + "</Destination>"
					Endif
					cXmlRet +=    "</InternalId>"
					cXmlRet += "</ListOfInternalId>"
				EndIf

				oModel:DeActivate()
			Else  //reavaliar - esta condição não vai ocorrer
				lRet := .F.
				cXmlRet := STR0008 // "Erro no parser!"
			EndIf
		ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE
			// Faz o parser do XML de retorno em um objeto
			oXML := xmlParser(xEnt, "_", @cError, @cWarning)

			// Se não houve erros na resposta
			If Upper(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_Status:Text) == "OK"
				// Verifica se a marca foi informada
				If Type("oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text)
					cProduct := oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text
				Else
					lRet    := .F.
					cXmlRet := STR0009 // "Erro no retorno. O Product é obrigatório!"
					AdpLogEAI(5, "AGRI045", cXmlRet, lRet)
					Return {lRet, cXmlRet}
				EndIf

				// Obtém a mensagem original enviada
				If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text)
					cXMLOrigin := oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text
				Else
					lRet    := .F.
					cXmlRet := STR0012 // "Conteúdo do MessageContent vazio!"
					Return {lRet, cXmlRet}
				EndIf

				// Faz o parse do XML em um objeto
				oXMLOrigin := XmlParser(cXMLOrigin, "_", @cError, @cWarning)

				// Se não houve erros no parse
				If oXMLOrigin <> Nil .And. Empty(cError) .And. Empty(cWarning)

					If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId") <> "U"
						// se a tag ListOfInternalId:_InternalId nao for array, converte
						If  Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId") <> "A"
							XmlNode2Arr(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId,"_InternalId" )
						EndIf

						For nX := 1 To Len(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId)

							// Verifica se o código interno foi informado
							If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[" + Str(nX) + "]:_Origin:Text") != "U" .and. !Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nX]:_Origin:Text)
								cValInt := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nX]:_Origin:Text
							Else
								lRet    := .F.
								cXmlRet := STR0010 // "Erro no retorno. O OriginalInternalId é obrigatório!"
								Return {lRet, cXmlRet}
							EndIf

							// Verifica se o código externo foi informado
							If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[" + str(nX) + "]:_Destination:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nX]:_Destination:Text)
								cValExt := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nX]:_Destination:Text
							Else
								lRet    := .F.
								cXmlRet := STR0011 // "Erro no retorno. O DestinationInternalId é obrigatório"
								Return {lRet, cXmlRet}
							EndIf

							If Upper(oXMLOrigin:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
								// Insere / Atualiza o registro na tabela XXF (de/para)
								CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .F.)
							ElseIf Upper(oXMLOrigin:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
								// Exclui o registro na tabela XXF (de/para)
								CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .T.)
							Else
								lRet := .F.
								cXmlRet := STR0013 // "Evento do retorno inválido!"
								Return {lRet, cXmlRet}
							EndIf

						next nX

					Else
						lRet := .F.
						cXmlRet := STR0014 // "Erro no parser do retorno!"
						Return {lRet, cXmlRet}
					EndIf
				Endif
			Else
				// Se não for array
				If Type("oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message") != "A"
					// Transforma em array
					XmlNode2Arr(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message, "_Message")
				EndIf

				// Percorre o array para obter os erros gerados
				For nCount := 1 To Len(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message)
					cError := oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount]:Text + Chr(10)
				Next nCount

				lRet := .F.
				cXmlRet := cError
			EndIf
		ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
			cXmlRet := "1.000|1.001|1.002"
		Endif
	ElseIf nTypeTrans == TRANS_SEND

		IF TYPE('OMODELNNR') == 'U'
			oModel := FWMODELACTIVE()
			oModelNNR := oModel:GetModel('NNRMASTER')
		ENDIF

		//Verifica operação realizada
		Do Case
			Case oModel:nOperation == MODEL_OPERATION_INSERT
				cEvent := 'upsert' //Inclusão
			Case oModel:nOperation == MODEL_OPERATION_UPDATE
				cEvent := 'upsert' //Alteração
			Case oModel:nOperation == MODEL_OPERATION_DELETE
				cEvent := 'delete' //Exclusão
				If !lIntegPPI
					CFGA070Mnt(,"NNR","NNR_CODIGO",,IntLocExt(,,RTrim(oModelNNR:GetValue('NNR_CODIGO')))[2],.T.)
				EndIf
		EndCase

		cXmlRet := '<BusinessEvent>'
		cXmlRet +=    '<Entity>' + cEntity + '</Entity>'
		cXmlRet +=    '<Event>' + cEvent + '</Event>'
		cXmlRet +=    '<Identification>'
		cXmlRet +=       '<key name="InternalID">' + IntLocExt(, , RTrim(oModelNNR:GetValue('NNR_CODIGO')))[2] + '</key>'
		cXmlRet +=    '</Identification>'
		cXmlRet += '</BusinessEvent>'
		cXmlRet += '<BusinessContent>'
		cXmlRet +=    '<CompanyId>' + cEmpAnt + '</CompanyId>'
		cXmlRet +=    '<BranchId>' + cFilAnt + '</BranchId>'
		cXmlRet +=    '<CompanyInternalId>' + cEmpAnt + '|' + cFilAnt + '</CompanyInternalId>'
		cXmlRet +=    '<Code>' + RTrim(oModelNNR:GetValue('NNR_CODIGO')) + '</Code>'
		cXmlRet +=    '<InternalId>' + IntLocExt(, , RTrim(oModelNNR:GetValue('NNR_CODIGO')))[2] + '</InternalId>'
		cXmlRet +=    '<Description>' + _NoTags(RTrim(oModelNNR:GetValue('NNR_DESCRI'))) + '</Description>'
		cXmlRet +=    '<Active>' + 'true' + '</Active>'
		cXmlRet +=    '<WarehouseClassification>' + oModelNNR:GetValue('NNR_INTP') + '</WarehouseClassification>'
		cXmlRet +=    '<WorkCenterCode>' + oModelNNR:GetValue('NNR_CTRAB') + '</WorkCenterCode>'
		cXmlRet +=    '<Type>' + oModelNNR:GetValue('NNR_TIPO') + '</Type>'

		If !RTrim(oModelNNR:GetValue('NNR_CODIGO')) $ cWHECommer
			cXmlRet +=    '<Purpose>1</Purpose>'
		Else
			cXmlRet +=    '<Purpose>2</Purpose>'
		EndIf

		If RTrim(oModelNNR:GetValue('NNR_CODIGO')) == cWHDefault
			cXmlRet +=    '<StandardWarehouse>1</StandardWarehouse>'
		Else
			cXmlRet +=    '<StandardWarehouse>2</StandardWarehouse>'
		EndIf

		cXmlRet +=    '<IsFinalItem/>'
		cXmlRet +=    '<IsQualityControl/>'
		cXmlRet +=    '<IsProcess/>'
		cXmlRet +=    '<IsWaste/>'
		cXmlRet +=    '<IsRecycled/>'
		cXmlRet +=    '<IsBalanceAvailable/>'
		cXmlRet += '</BusinessContent>'
		If lIntegPPI
			completXml(@cXmlRet)
		EndIf
	EndIf

	If !lIntegPPI
		AdpLogEAI(5, "AGRI045", cXmlRet, lRet)
	EndIf

Return {lRet, cXmlRet}

//-------------------------------------------------------------------
/*/{Protheus.doc} IntLocExt
Monta o InternalID do Local de Estoque de acordo com o código passado
no parâmetro.
@type function
@author Leandro Luiz da Cruz
@since 08/02/2013
@version P11
@param cEmpresa, character, Código da empresa (Default cEmpAnt)
@param cFil, character, Código da Filial (Default cFilAnt)
@param cLocalEst, character, Código do Local de Estoque
@param [cVersao], character, Versão da mensagem única (Default 1.000)
@return array, Array contendo no primeiro elemento uma variável lógica indicando se o registro foi encontrado e no segundo elemento uma string com o InternalID montado
@example
IntLocExt(,,'01') // Retorna {.T.,'01|01|01'}
/*/
//-------------------------------------------------------------------
Function IntLocExt(cEmpresa, cFil, cLocalEst, cVersao)
	Local aResult    := {}
	Local cMajor     := ""
	Default cEmpresa := cEmpAnt
	Default cFil     := xFilial('NNR')
	Default cVersao  := '1.000'

	cMajor	:= StrTokArr(cVersao, ".")[1]

	If cMajor == '1'
		aAdd(aResult, .T.)
		aAdd(aResult, cEmpresa + '|' + RTrim(cFil) + '|' + RTrim(cLocalEst))
	Else
		aAdd(aResult, .F.)
		aAdd(aResult, STR0033 + Chr(10) + STR0035) // "Versão do local de estoque não suportada." "As versões suportadas são: 1.000"
	EndIf
Return aResult

//-------------------------------------------------------------------
/*/{Protheus.doc} IntLocInt
Recebe um InternalID e retorna o código do Local de Estoque.

@param   cInternalID InternalID recebido na mensagem.
@param   cRefer      Produto que enviou a mensagem
@param   cVersao     Versão da mensagem única (Default 1.000)

@author  Leandro Luiz da Cruz
@version P11
@since   08/02/2013
@return  aResult Array contendo no primeiro parâmetro uma variável
			lógica indicando se o registro foi encontrado no de/para.
			No segundo parâmetro uma variável array com a empresa,
			filial e o Código do Local de Estoque.

@sample  IntLocInt('01|01|01') irá retornar {.T., {'01', '01', '01'}}
/*/
//-------------------------------------------------------------------
Function IntLocInt(cInternalID, cRefer, cVersao)
	Local aResult  := {}
	Local aTemp    := {}
	Local cTemp    := ''
	Local cAlias   := 'NNR'
	Local cField   := 'NNR_CODIGO'
	Local cMajor   := ""

	Default cVersao  := '1.000'

	cTemp := CFGA070Int(cRefer, cAlias, cField, cInternalID)

	If Empty(cTemp)
		aAdd(aResult, .F.)
		aAdd(aResult, STR0034 + " -> " + cInternalID ) // "Local de Estoque não encontrado no de/para!"
	Else
		cMajor	:= StrTokArr(cVersao, ".")[1]
		If cMajor == "1"
			aAdd(aResult, .T.)
			aTemp := Separa(cTemp, '|')
			aAdd(aResult, aTemp)
		Else
			aAdd(aResult, .F.)
			aAdd(aResult, STR0033 + Chr(10) + STR0035) // "Versão do local de estoque não suportada." "As versões suportadas são: 1.000"
		EndIf
	EndIf
Return aResult

//-------------------------------------------------------------------
/*/{Protheus.doc} completXml()
Adiciona o cabeçalho da mensagem quando utilizado integração com o PPI.

@param   cXML  - XML gerado pelo adapter. Parâmetro recebido por referência.

@author  Lucas Konrad França
@version P12
@since   17/08/2015
@return  Nil
/*/
//-------------------------------------------------------------------
Static Function completXml(cXML)
	Local cCabec     := ""
	Local cCloseTags := ""
	Local cGenerated := ""

	cGenerated := SubStr(DTOS(Date()), 1, 4) + '-' + SubStr(DTOS(Date()), 5, 2) + '-' + SubStr(DTOS(Date()), 7, 2) + 'T' + Time()

	cCabec := '<?xml version="1.0" encoding="UTF-8" ?>'
	cCabec += '<TOTVSMessage xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="xmlschema/general/events/Warehouse_1_001.xsd">'
	cCabec +=     '<MessageInformation version="1.001">'
	cCabec +=         '<UUID>1</UUID>'
	cCabec +=         '<Type>BusinessMessage</Type>'
	cCabec +=         '<Transaction>Warehouse</Transaction>'
	cCabec +=         '<StandardVersion>1.0</StandardVersion>'
	cCabec +=         '<SourceApplication>SIGAPCP</SourceApplication>'
	cCabec +=         '<CompanyId>'+cEmpAnt+'</CompanyId>'
	cCabec +=         '<BranchId>'+cFilAnt+'</BranchId>'
	cCabec +=         '<UserId>'+__cUserId+'</UserId>'
	cCabec +=         '<Product name="'+FunName()+'" version="'+GetRPORelease()+'"/>'
	cCabec +=         '<ContextName>PROTHEUS</ContextName>'
	cCabec +=         '<GeneratedOn>' + cGenerated +'</GeneratedOn>'
	cCabec +=         '<DeliveryType>Sync</DeliveryType>'
	cCabec +=     '</MessageInformation>'
	cCabec +=     '<BusinessMessage>'

	cCloseTags := '</BusinessMessage>'
	cCloseTags += '</TOTVSMessage>'

	cXML := cCabec + cXML + cCloseTags

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} V1000J
Funcao de integracao com o adapter EAI para envio e recebimento do
cadastro de Local de Estoque (Warehouse) utilizando o formato JSON
(objeto FWEAIObj), com suporte as versoes 1.000 a 1.003 da mensagem unica.
@type function
@author rodrigo.mpontes
@since 21/10/2015
@version P12
@param xEnt, variant, Objeto FWEAIObj com a mensagem recebida (TRANS_RECEIVE) ou dados de origem para envio (TRANS_SEND)
@param nTypeTrans, numeric, Tipo de transacao (TRANS_RECEIVE / TRANS_SEND)
@param cTypeMessage, character, Tipo de mensagem (EAI_MESSAGE_BUSINESS / EAI_MESSAGE_RESPONSE / EAI_MESSAGE_WHOIS)
@return array, Array de dois elementos: [1] logico indicando o resultado da execucao; [2] objeto FWEAIObj com o conteudo de retorno
/*/
//-------------------------------------------------------------------
Static Function V1000J(xEnt, nTypeTrans, cTypeMessage)

	Local cRet   	    := ""
	Local cEntity       := "WAREHOUSE"
	Local cEvent        := ""
	Local lRet          := .T.
	Local oModel        := Nil
	Local oModelNNR     := Nil
	Local cWHECommer	:= GetNewPar("MV_LJECOMG","01")
	Local cWHDefault	:= GetNewPar("MV_LJECLPE","01")
	Local ofwEAIObj     := FWEAIobj():NEW()
	Local aRet			:= {}
	Local nX   			:= 0
	Local nI            := 0
	Local cProduct      := ""
	Local cValExt       := ""
	Local cMsgRet 	    := ""
	Local cValInt       := ""
	Local cCode         := ""
	Local cAlias        := "NNR"
	Local cField        := "NNR_CODIGO"
	Local nOpcx         := 0
	Local aLocalEst     := {}
	Local aAux          := {}
	Local lInicPad      := .F.
	Local aErro         := {}
	Local oMsgError     := NIL
	Local nPurpose      := 0
	Local nStdWarehouse := 0
	Local nCnt          := 0
	Local jListInternalID := Nil

	Private lIntegPPI 	:= .F.

	//Verifica se está sendo executado para realizar a integração com o PPI.
	//Se a variável lRunPPI estiver definida, e for .T., assume que é para o PPI.
	//Variável é criada no fonte AGRA045.prw, na função AGRA045PPI().
	If Type("lRunPPI") == "L" .And. lRunPPI
		lIntegPPI := .T.
	EndIf

	//Mensagem de Entrada
	If nTypeTrans == TRANS_RECEIVE

		If cTypeMessage == EAI_MESSAGE_BUSINESS

			// Verifica se a marca foi informada
			If xEnt:getHeaderValue("ProductName") != Nil .And. !Empty(xEnt:getHeaderValue("ProductName"))
				cProduct := AllTrim(xEnt:getHeaderValue("ProductName"))
			Else
				lRet := .F.
				cMsgRet += STR0001 // "A marca é obrigatória"
				Return {lRet, cMsgRet}
			EndIf

			If lRet .And. xEnt:getPropValue("InternalId")  != Nil
				cValExt := ( xEnt:getPropValue("InternalId") )
			Else
				lRet := .F.
				cMsgRet := STR0002 // "O InternalId é obrigatório!"
				Return {lRet, cMsgRet}
			EndIf

			aAux := IntLocInt(cValExt,cProduct)

			If lRet .And. xEnt:getPropValue("Event")  != Nil
				If AllTrim(Upper(xEnt:getPropValue("Event"))) ==  "UPSERT"
					If !aAux[1]
						nOpcx := 3
					Else
						nOpcx := 4
						cCode := aAux[2,3]
					Endif
				ElseIf AllTrim(Upper(xEnt:getPropValue("Event"))) ==  "DELETE"
					If !aAux[1]
						lRet := .F.
						cMsgRet := STR0005 // "O registro a ser excluído não existe na base Protheus"
						Return {lRet, cMsgRet}
					Else
						nOpcx := 5
						cCode := aAux[2,3]
					Endif
				Endif
			Else
				lRet := .F.
				cMsgRet := STR0002 // "O InternalId é obrigatório!"
				Return {lRet, cMsgRet}
			EndIf

			lInicPad := !Empty(Posicione("SX3", 2, PADR("NNR_CODIGO", 10), "X3_RELACAO"))

			If !lInicPad .And. nOpcx == 3
				If lRet .And. xEnt:getPropValue("Code")  != Nil
					If Len( AllTrim(xEnt:getPropValue("Code")) ) > TamSX3('NNR_CODIGO')[1]
						lRet := .F.
						cMsgRet := STR0038+ AllTrim(xEnt:getPropValue("Code")) + STR0039  + Chr(10) //"O Codigo do Local de Estoque " ## " possui tamanho maior que o permitido."
						cMsgRet += STR0040 + CValToChar(TamSx3("NNR_CODIGO")[1]) + Chr(10) //"Maximo:"
						cMsgRet += STR0041 + CValToChar(Len(AllTrim(xEnt:getPropValue("Code")))) //"Enviado:"
						Return {lRet, cMsgRet}
					Else
						cCode := xEnt:getPropValue("Code")
					EndIf
				Else
					lRet := .F.
					cMsgRet := STR0003 // "O Code é obrigatório!"
					Return {lRet, cMsgRet}
				EndIf
			Endif

			If !Empty(cCode) .And. (!lInicPad .And. nOpcx == 3)
				aAdd(aLocalEst, {"NNR_CODIGO", cCode, Nil}) // Código do Local
			Endif

			If nOpcx <> 3
				NNR->(DbSetOrder(1))
				lRet := NNR->(dbSeek(xFilial("NNR") + PadR(cCode, TamSX3("NNR_CODIGO")[1])))

				If !lRet
					cMsgRet := "Local de estoque: " + AllTrim(cCode) + " não encontrado para alteração ou exclusão"
					Return {lRet,cMsgRet}
				Endif
			Endif

			oModel := FWLoadModel('AGRA045')

			If nOpcx == 3
				oModel:SetOperation(MODEL_OPERATION_INSERT)
			ElseIf nOpcx == 4
				oModel:SetOperation(MODEL_OPERATION_UPDATE)
			Elseif nOpcx == 5
				oModel:SetOperation(MODEL_OPERATION_DELETE)
			Endif

			If nOpcx <> 5
				// Verifica se a descrição do local foi informada
				If lRet .And. xEnt:getPropValue("Description")  != Nil
					If Len(AllTrim(xEnt:getPropValue("Description") )) > TamSX3('NNR_DESCRI')[1]
						lRet := .F.
						cMsgRet := STR0021 // "A Descrição do Local não pode ser maior que 20 caracteres!"
						Return {lRet, cMsgRet}
					Else
						aAdd(aLocalEst, {"NNR_DESCRI", xEnt:getPropValue("Description"), Nil}) // Descricao do Local
					EndIf
				Else
					lRet := .F.
					cMsgRet := STR0004 // "A Descrição do Local é obrigatória!"
					Return {lRet, cMsgRet}
				EndIf

				// Obtém o Tipo do Local
				If lRet .And. xEnt:getPropValue("Type")  != Nil
					aAdd(aLocalEst, {"NNR_TIPO", xEnt:getPropValue("Type"), Nil}) // Tipo do Local
				EndIf

				If lRet .And. nOpcx == 4 .And. xEnt:getPropValue("Active")  != Nil
					If AllTrim(Upper(xEnt:getPropValue("Active") )) == "FALSE" .And. NNR->(FieldPos('NNR_MSBLQL')) > 0
						aAdd(aLocalEst, {"NNR_MSBLQL", '1', Nil})
					Endif
				Endif
			Endif

			oModel:Activate()

			// Obtém a estrutura de dados
			aAux := oModel:GetModel('NNRMASTER'):GetStruct():GetFields()

			If oModel:nOperation != MODEL_OPERATION_DELETE
				For nI := 1 To Len(aLocalEst)
					// Verifica se os campos passados existem na estrutura do modelo
					// Não enviar a filial e o código ao alterar
					If aScan(aAux, {|x| AllTrim(x[3]) == AllTrim(aLocalEst[nI][1])}) > 0 .And. (aLocalEst[nI][1] != "NNR_CODIGO" .Or. (!lInicPad .And. nOpcx == 3))
						// é feita a atribuição do dado ao campo do Model
						If !oModel:SetValue('NNRMASTER', aLocalEst[nI][1], aLocalEst[nI][2])
							lRet := .F.
							cMsgRet := STR0022 /*"Não foi possível atribuir o valor "*/ + AllToChar(aLocalEst[nI][2]) + STR0023 /*" ao campo "*/ + aLocalEst[nI][1] + "."
							Return {lRet, cMsgRet}
						EndIf
					EndIf
				Next nI
			EndIf

			// Se os dados não são válidos
			lRet := oModel:VldData()

			If lRet
				// Se o dados foram validados faz-se a gravação efetiva dos dados (commit)
				oModel:CommitData()

				// Se o evento é diferente de DELETE
				If oModel:nOperation != MODEL_OPERATION_DELETE
					CFGA070Mnt(cProduct, cAlias, cField, cValExt, IntLocExt(, , NNR->NNR_CODIGO)[2], .F.)
				Else
					// Exclui o registro na tabela XXF (de/para)
					CFGA070Mnt(cProduct, cAlias, cField, cValExt, IntLocExt(, , cCode)[2], .T.)
				EndIf

				ofwEAIObj:Activate()
				ofwEAIObj:setProp("ReturnContent")

				ofwEAIObj:getPropValue("ReturnContent"):setProp("ListOfInternalId",{},'InternalId',,.T.)
				ofwEAIObj:getPropValue("ReturnContent"):getPropValue("ListOfInternalId")[1]:setProp("Name",cEntity)
				ofwEAIObj:getPropValue("ReturnContent"):getPropValue("ListOfInternalId")[1]:setProp("Origin",      	cValExt)
				ofwEAIObj:getPropValue("ReturnContent"):getPropValue("ListOfInternalId")[1]:setProp("Destination",  IntLocExt(, , cCode)[2] )

				aAdd(aRet, lRet)
				aAdd(aRet, ofwEAIObj)

			Else
				// Obtém o log de erros
				aErro := oModel:GetErrorMessage()

				cMsgRet += STR0024 + AllToChar(aErro[6]) + CRLF // "Mensagem do erro: "
				cMsgRet += STR0025 + AllToChar(aErro[7]) + CRLF // "Mensagem da solução: "
				cMsgRet += STR0026 + AllToChar(aErro[8]) + CRLF // "Valor atribuído: "
				cMsgRet += STR0027 + AllToChar(aErro[9]) + CRLF // "Valor anterior: "
				cMsgRet += STR0028 + AllToChar(aErro[1]) + CRLF // "Id do formulário de origem: "
				cMsgRet += STR0029 + AllToChar(aErro[2]) + CRLF // "Id do campo de origem: "
				cMsgRet += STR0030 + AllToChar(aErro[3]) + CRLF // "Id do formulário de erro: "
				cMsgRet += STR0031 + AllToChar(aErro[4]) + CRLF // "Id do campo de erro: "
				cMsgRet += STR0032 + AllToChar(aErro[5])        // "Id do erro: "

				ofwEAIObj:Activate()
				ofwEAIObj:setProp("ReturnContent")
				ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cMsgRet)

			EndIf

			oModel:DeActivate()

		ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE

			If xEnt:getPropValue("ProcessingInformation"):getPropValue("Status") <> Nil .And. Upper(xEnt:getPropValue("ProcessingInformation"):getPropValue("Status")) == "OK"  

				// Verifica se a marca foi informada
				cProduct := xEnt:getHeaderValue("ProductName")

				If cProduct == NIL .Or. Empty(cProduct)
					lRet := .F.
					cRet += STR0001 // "A marca é obrigatória"
				Else
					cProduct := AllTrim(cProduct)
				EndIf

				// Obtém ListOfInternalId uma única vez
				jListInternalID := xEnt:getPropValue("ReturnContent"):getPropValue("ListOfInternalId")

				If jListInternalID != NIL
					// Valida evento
					cEvent := xEnt:getPropValue("ReceivedMessage"):getPropValue("Event")
					If cEvent != NIL
						cEvent := Upper(RTrim(cEvent))
					EndIf

					If cEvent == NIL .or. (cEvent != "UPSERT" .and. cEvent != "DELETE")
						lRet := .F.
						cRet += STR0013 + CRLF // "Evento do retorno inválido!"
					EndIf

					// Percorre ListOfInternalId
					If lRet
						For nCnt := 1 To Len(jListInternalID)
							cValInt := jListInternalID[nCnt]:getPropValue("Origin")
							If cValInt == NIL
								cRet += I18N(STR0043, {"Origin", "ListOfInternalId"}) // "Erro no retorno. O elemento #1[campo] está vazio/nulo dentro do elemento #2[elemento]."
								lRet := .F.
								Exit
							EndIf

							cValExt := jListInternalID[nCnt]:getPropValue("Destination")
							If cValExt == NIL
								cRet += I18N(STR0043, {"Destination", "ListOfInternalId"}) // "Erro no retorno. O elemento #1[campo] está vazio/nulo dentro do elemento #2[elemento]."
								lRet := .F.
								Exit
							EndIf

							// Atualiza o registro na tabela XXF (de/para)
							If !CFGA070Mnt(cProduct, "NNR", "NNR_CODIGO", cValExt, cValInt, (cEvent == "DELETE"))
								cRet += I18N(STR0044, {cEvent, cValExt, cValInt}) + CRLF // "Não foi possivel gravar na tabela De/Para. Evento: #1[DELETE] com o Valor externo: #2[valorexterno] e o Valor interno: #3[valorInterno]."
								lRet := .F.
								Exit
							EndIf
						Next nCnt
					EndIf
				Else
					cRet += I18N(STR0043, {"ListOfInternalId", "ReturnContent"}) // "Erro no retorno. O elemento #1[campo] está vazio/nulo dentro do elemento #2[elemento]."
					lRet := .F.
				EndIf
			Else
				cRet := ""
				If xEnt:getpropvalue('ProcessingInformation') != nil
					oMsgError := xEnt:getpropvalue('ProcessingInformation'):getpropvalue("Details")
					For nX := 1 To Len( oMsgError )
						cRet := oMsgError[nX]:getpropvalue('Message')
						If cRet != NiL .AND. ValType(cRet) == "C"
							cRet += cRet + CRLF
						EndIf
					Next nX
				Endif

				lRet := .F.
			EndIf

			If !lRet
				xEnt:Activate()
				xEnt:setProp("ReturnContent")
				xEnt:getPropValue("ReturnContent"):setProp("Error", cRet)

			EndIf
			aAdd(aRet, lRet)
			aAdd(aRet, xEnt)
		ElseIf cTypeMessage == EAI_MESSAGE_WHOIS

			cRet := "1.000|1.001|1.002"
			aAdd(aRet, .T.)
			aAdd(aRet, ofwEAIObj)
		Endif
	ElseIf nTypeTrans == TRANS_SEND

		IF TYPE('OMODELNNR') == 'U'
			oModel := FWMODELACTIVE()
			oModelNNR := oModel:GetModel('NNRMASTER')
		ENDIF

		//Verifica operação realizada
		Do Case
			Case oModel:nOperation == MODEL_OPERATION_INSERT
				cEvent := 'upsert' //Inclusão
			Case oModel:nOperation == MODEL_OPERATION_UPDATE
				cEvent := 'upsert' //Alteração
			Case oModel:nOperation == MODEL_OPERATION_DELETE
				cEvent := 'delete' //Exclusão
				If !lIntegPPI
					CFGA070Mnt(,"NNR","NNR_CODIGO",,IntLocExt(,,RTrim(oModelNNR:GetValue('NNR_CODIGO')))[2],.T.)
				EndIf
		EndCase

		nPurpose := 2
		If !RTrim(oModelNNR:GetValue('NNR_CODIGO')) $ cWHECommer
			nPurpose := 1       
		EndIf
		nStdWarehouse := 2
		If RTrim(oModelNNR:GetValue('NNR_CODIGO')) == cWHDefault
			nStdWarehouse := 1
		EndIf

		ofwEAIObj:Activate()
		ofwEAIObj:setEvent(cEvent)

		//	ofwEAIObj:setbatch(1) Só QUANDO USA LOTE

		ofwEAIObj:setProp("Entity"           		,cEntity)
		ofwEAIObj:setProp("Event"            		,cEvent)
		ofwEAIObj:setProp("InternalId"       		,IntLocExt(, , RTrim(oModelNNR:GetValue('NNR_CODIGO')))[2]  )
		ofwEAIObj:setProp("CompanyId"        		,cEmpAnt)
		ofwEAIObj:setProp("BranchId"         		,cFilAnt)
		ofwEAIObj:setProp("CompanyinternalId"		,cEmpAnt + '|' + cFilAnt )
		ofwEAIObj:setProp("Code"					,RTrim(oModelNNR:GetValue('NNR_CODIGO')) )
		ofwEAIObj:setProp("Description"				,_NoTags(RTrim(oModelNNR:GetValue('NNR_DESCRI'))) )
		ofwEAIObj:setProp("Active"		    		,'true'  )

		ofwEAIObj:setProp("WarehouseClassification"	,oModelNNR:GetValue('NNR_INTP')   ) // A partir da versao 1.001
		ofwEAIObj:setProp("WorkCenterCode"			,oModelNNR:GetValue('NNR_CTRAB')  ) // A partir da versao 1.002

		ofwEAIObj:setProp("Type"					,oModelNNR:GetValue('NNR_TIPO')   )

		ofwEAIObj:setProp("Purpose"				,nPurpose       ) // A partir da versao 1.003
		ofwEAIObj:setProp("StandardWarehouse"	,nStdWarehouse ) // A partir da versao 1.004

		aAdd(aRet, .T.)
		aAdd(aRet, ofwEAIObj)

	EndIf

Return {aRet[1],aRet[2]}
