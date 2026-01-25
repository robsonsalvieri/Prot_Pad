#INCLUDE "TOTVS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FATI300O.CH"

//------------------------------------------------------------------------------
/*/	{Protheus.doc} FATI300O
Funcao de tratamento para o recebimento/envio de mensagem unica de oportunidades.
@sample	FATI300O(oEaiObEt, nTypeTrans, cTypeMessage)
@param		ExpO1 = Objeto JSON do EAI
			ExpN1 = Tipo de transação
			ExpC2 = Tipo de Menssagem
@return	aRet
@author		TI - Negócios Digitais
@since		30/06/2022
@version	12
/*/
//----------------------------------------------------------------------------
Function FATI300O(oEAIObEt, nTypeTrans, cTypeMessage)

    Local lRet          := .T.
    Local ofwEAIObj		:= FWEAIobj():New()
	Local cAlias		:= "AD1"
    Local cOwnerMsg		:= "OPPORTUNITY"
    Local cEvent        := "upsert"
    Local cLogErro      := ""
    Local cMarca        := ""
	Local cField 		:= "AD1_NROPOR"
	Local cValExt		:= ""
	Local cValInt		:= ""
	Local cCode			:= ""
	Local aAux			:= {}
	Local cAux			:= ""
	Local nOpcX			:= 0
	Local lFoundAD1		:= .F.
	Local aRet			:= {}
	Local nCount		:= 0
	Local oAux
	Local nTamAux		:= 0
	Local lRetPE        := .F.
	Local lF300Fils     := ExistBlock('F300OFILS')

	Local aAD1Master	:= {} //Array de campos da oportunidade
	Local aAD2Detail	:= {} //Grid de time de vendas
	Local aAD3Detail	:= {} //Grid de concorrentes
	Local aAD4Detail	:= {} //Grid de parceiros
	Local aAD9Detail	:= {} //Grid de contatos
	Local aADJDetail	:= {} //Grid de produtos
	Local aDetailAux	:= {}

	Local aRetPE		:= {} //Retorno de Pontos de Entrada
	Local cJson 		:= "" //Json para ponto de entrada de mensagem de saída

	//Variáveis de EAI secundários
	Local cCusVer          	:= RTrim(PmsMsgUVer('CUSTOMERVENDOR',            'MATA030')) //Versão do Cliente/Fornecedor

	//Tipo de controle da ADJ
	Local nCtrlADJ	 	:= SuperGetMv("MV_FATMNTP",,1)

	//Locais para descrições
	Local cNomGsn 		:= ""
	Local cDscCar 		:= ""
	Local cDscUnid		:= ""
	Local cRespUnid		:= ""
	Local cDescPapel	:= ""
	Local cNmProd		:= ""
	Local cDecCateg		:= ""
	Local cDescAgrup	:= ""
	Local cDescNivel	:= ""

	Private lMsErroAuto	:= .F.
   	//--------------------------------------
	//Recebimento mensagem
	//--------------------------------------
	If nTypeTrans == TRANS_RECEIVE .And. ValType( oEAIObEt ) == 'O'

		//--------------------------------------
		//chegada de mensagem de negocios
		//--------------------------------------
		If cTypeMessage == EAI_MESSAGE_BUSINESS

            cEvent := Upper(AllTrim(oEAIObEt:getHeaderValue("Event")))
            If !cEvent $ "UPSERT|REQUEST|DELETE"
                lRet := .F.
                ofwEAIObj:Activate()
                ofwEAIObj:setProp("ReturnContent")
                cLogErro := STR0001 + CRLF //"O evento informado é inválido!"
                ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
				aRet := {lRet, ofwEAIObj, cOwnerMsg}
				Return aRet
            EndIf

			If oEAIObEt:getHeaderValue("ProductName") !=  Nil .And. !Empty( oEAIObEt:getHeaderValue("ProductName") )
				cMarca :=  Upper(oEAIObEt:getHeaderValue("ProductName"))
			Else
				lRet := .F.
				ofwEAIObj:Activate()
				ofwEAIObj:setProp("ReturnContent")
				cLogErro := STR0002 + CRLF //"Product é obrigatório!"
				ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
				aRet := {lRet, ofwEAIObj, cOwnerMsg}
				Return aRet
			EndIf

			// Obtém o Valor externo
			If oEAIObEt:getPropValue("InternalId") != nil  .And. !Empty( oEAIObEt:getPropValue("InternalId") )
				cValExt := oEAIObEt:getPropValue("InternalId")
				//Obtém o valor interno
				aAux := IntOpoInt(cValExt, cMarca)
			Else
				lRet := .F.
				ofwEAIObj:Activate()
				ofwEAIObj:setProp("ReturnContent")
				cLogErro := STR0003 //"InternalId é obrigatório!"
				ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
				aRet := {lRet, ofwEAIObj, cOwnerMsg}
				Return aRet
			EndIf

			//Obtém o code
			If oEAIObEt:getPropValue("Code") != nil .And. !Empty( oEAIObEt:getPropValue("Code") )
				cCode := AllTrim(oEAIObEt:getPropValue("Code"))
			ElseIf aAux[1]
				cCode := aAux[2][3]
			EndIf

			AD1->(DbSetOrder(1))

			lFoundAD1 :=  Len(aAux) > 0 .And. AD1->(DbSeek(FWxFilial('AD1') + Padr(cCode, Len(AD1->AD1_NROPOR))))

			//Se já existe o ID na base, verifica se o código informado é o mesmo
			If cEvent $ "UPSERT|REQUEST" .And. lFoundAD1 .And. !Empty(cCode) .And. AllTrim(aAux[2][3]) != AllTrim(cCode)
				lRet := .F.
				ofwEAIObj:Activate()
				ofwEAIObj:setProp("ReturnContent")
				cLogErro := STR0004 + " " + cValExt + STR0005 + " -> " + AllTrim(aAux[2][3]) //"O ID" ## //"informado já existe no Protheus com outro código de oportunidade!"
				ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
				aRet := {lRet, ofwEAIObj, cOwnerMsg}
				Return aRet
			EndIf

			//Upsert
			If cEvent $ "UPSERT|REQUEST"
				If lFoundAD1
					nOpcX := 4
					cCode := AllTrim(aAux[2][3])
				Else
					//Verifica se o código foi enviado ou se tem inicializador padrão
					If !Empty(GetSx3Cache("AD1_NROPOR","X3_RELACAO"))
						nOpcX := 3
						cCode := ""
					ElseIf Empty(cCode)
						lRet := .F.
						ofwEAIObj:Activate()
						ofwEAIObj:setProp("ReturnContent")
						cLogErro := STR0006 //"O código da Oportunidade deve ser informado!"
						ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
						aRet := {lRet, ofwEAIObj, cOwnerMsg}
						Return aRet
					Else
						nOpcX := 3
					EndIf
				EndIf
			Else //Delete
				If lFoundAD1
					nOpcX := 5
				Else
					lRet := .F.
					ofwEAIObj:Activate()
					ofwEAIObj:setProp("ReturnContent")
					cLogErro := STR0007 + " -> " + cValExt //"O registro a ser excluído não existe na base Protheus!"
					ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
				EndIf
			EndIf
			
			If lRet 
				//Ponto de entrada para validação
				If ExistBlock('F300OVRE')
					aRetPE := ExecBlock("F300OVRE",.F.,.F., { cEvent, nOpcX, oEAIObEt, cValExt, If(Len(aAux) >= 2, aClone(aAux[2]), {}) })
					If ValType(aRetPE) == 'A' .And. Len(aRetPE) >= 2 .And. ValType(aRetPE[1]) == 'L' .And. !aRetPE[1]

						lRet := aRetPE[1]
						ofwEAIObj:Activate()
						ofwEAIObj:setProp("ReturnContent")
						cLogErro := If(ValType(aRetPE[2])=="C" .And. !Empty(aRetPE[2]), aRetPE[2], STR0008) //"Não passou pela validação do ponto de entrada F300OVRE."
						ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)

					EndIf
				EndIf
				
				If lRet 
					//Adiciona campo de código se necessário
					If (nOpcX != 3) .Or. (nOpcX == 3 .And. !Empty(cCode))
						aAdd(aAD1Master, { "AD1_NROPOR", cCode, Nil} )
					EndIf

					If nOpcX != 5 //Se não for exclusão

						//Revisão
						If oEAIObEt:getPropValue("Review") != Nil .And. !Empty( oEAIObEt:getPropValue("Review") )
							aAdd(aAD1Master, {"AD1_REVISA", AllTrim(oEAIObEt:getPropValue("Review")), Nil})
						EndIf

						//Descrição
						If oEAIObEt:getPropValue("Description") != Nil .And. !Empty( oEAIObEt:getPropValue("Description") )
							aAdd(aAD1Master, {"AD1_DESCRI", Padr((oEAIObEt:getPropValue("Description")), TamSX3('AD1_DESCRI')[1]), Nil})
						EndIf

						//Código do vendedor
						If oEAIObEt:getPropValue("SellerInternalId") != Nil .And. !Empty( oEAIObEt:getPropValue("SellerInternalId") )

							aAux 	:= StrTokArr(CFGA070Int(cMarca, "SA3", "A3_COD", oEAIObEt:getPropValue("SellerInternalId")),"|")
							nTamAux := TamSX3('AD1_VEND')[1]
							If Len( aAux ) > 0
								If !Empty( aAux[Len(aAux)] )
									aAdd(aAD1Master, {"AD1_VEND", Padr(aAux[Len(aAux)],nTamAux), Nil})
								Endif
							Endif


						ElseIf oEAIObEt:getPropValue("Seller") != Nil .And. !Empty( oEAIObEt:getPropValue("Seller") )
							aAdd(aAD1Master, {"AD1_VEND", AllTrim(oEAIObEt:getPropValue("Seller")), Nil})
						EndIf

						//Data de Criação da Oportunidade
						If oEAIObEt:getPropValue("CreateDate") != Nil .And. !Empty( oEAIObEt:getPropValue("CreateDate") )
							aAdd(aAD1Master, {"AD1_DATA", StoD(oEAIObEt:getPropValue("CreateDate")), Nil})
						EndIf

						//Data inicial da oportunidade
						If oEAIObEt:getPropValue("StartDate") != Nil .And. !Empty( oEAIObEt:getPropValue("StartDate") )
							aAdd(aAD1Master, {"AD1_DTINI", StoD(oEAIObEt:getPropValue("StartDate")), Nil})
						EndIf

						//Data final da oportunidade
						If oEAIObEt:getPropValue("ClosingDate") != Nil .And. !Empty( oEAIObEt:getPropValue("ClosingDate") )
							aAdd(aAD1Master, {"AD1_DTFIM", StoD(oEAIObEt:getPropValue("ClosingDate")), Nil})
						EndIf

						//Tipo de cliente
						If oEAIObEt:getPropValue("EntityType") != Nil .And. !Empty( oEAIObEt:getPropValue("EntityType") )

							If AllTrim(oEAIObEt:getPropValue("EntityType")) == "1" //Cliente

								//Código de/para (EAI)
								If oEAIObEt:getPropValue("EntityInternalId") != Nil .And. !Empty( oEAIObEt:getPropValue("EntityInternalId") )

									cCusVer := If(Empty(cCusver), "2.005", cCusVer)

									aAux := IntCliInt(oEAIObEt:getPropValue("EntityInternalId"), cMarca, cCusVer)

									If !aAux[1]
										lRet := aAux[1]
										cLogErro := ""
										ofwEAIObj:Activate()
										ofwEAIObj:setProp("ReturnContent")
										cLogErro := aAux[2]
										ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
										aRet := {lRet, ofwEAIObj, cOwnerMsg}
										Return aRet

									Else

										aAdd(aAD1Master, { "AD1_CODCLI", AllTrim(aAux[2][3]), Nil})
										aAdd(aAD1Master, { "AD1_LOJCLI", AllTrim(aAux[2][4]), Nil})

									EndIf

								Else

									//Código
									If oEAIObEt:getPropValue("EntityId") != Nil .And. !Empty( oEAIObEt:getPropValue("EntityId") )

										aAdd(aAD1Master, { "AD1_CODCLI", AllTrim(oEAIObEt:getPropValue("EntityId")), Nil})

									EndIf

									//Loja
									If oEAIObEt:getPropValue("EntityUnit") != Nil .And. !Empty( oEAIObEt:getPropValue("EntityUnit") )

										aAdd(aAD1Master, { "AD1_LOJCLI", AllTrim(oEAIObEt:getPropValue("EntityUnit")), Nil})

									EndIf

								EndIf

							ElseIf AllTrim(oEAIObEt:getPropValue("EntityType")) == "2" //Prospect - não tem de/para de EAI

								//Código
								If oEAIObEt:getPropValue("EntityId") != Nil .And. !Empty( oEAIObEt:getPropValue("EntityId") )

									aAdd(aAD1Master, { "AD1_PROSPE", AllTrim(oEAIObEt:getPropValue("EntityId")), Nil})

								EndIf

								//Loja
								If oEAIObEt:getPropValue("EntityUnit") != Nil .And. !Empty( oEAIObEt:getPropValue("EntityUnit") )

									aAdd(aAD1Master, { "AD1_LOJPRO", AllTrim(oEAIObEt:getPropValue("EntityUnit")), Nil})

								EndIf

							EndIf

						EndIf

						//Processo de venda
						If oEAIObEt:getPropValue("Process") != Nil .And. !Empty( oEAIObEt:getPropValue("Process") )
							aAdd(aAD1Master, {"AD1_PROVEN", AllTrim(oEAIObEt:getPropValue("Process")), Nil})
						EndIf

						//Estágio do processo de venda
						If oEAIObEt:getPropValue("Stage") != Nil .And. !Empty( oEAIObEt:getPropValue("Stage") )
							aAdd(aAD1Master, {"AD1_STAGE", AllTrim(oEAIObEt:getPropValue("Stage")), Nil})
						EndIf

						//Observações
						If oEAIObEt:getPropValue("Notes") != Nil .And. !Empty( oEAIObEt:getPropValue("Notes") )
							aAdd(aAD1Master, {"AD1_MEMO", AllTrim(oEAIObEt:getPropValue("Notes")), Nil})
						EndIf

						//Data prevista de finalizacao
						If oEAIObEt:getPropValue("ExpectedEndDate") != Nil .And. !Empty( oEAIObEt:getPropValue("ExpectedEndDate") )
							aAdd(aAD1Master, {"AD1_DTPFIM", StoD(oEAIObEt:getPropValue("ExpectedEndDate")), Nil})
						EndIf

						//Moeda
						If oEAIObEt:getPropValue("CurrencyInternalId") != nil .And. !Empty( oEAIObEt:getPropValue("CurrencyInternalId") )
									cAux := oEAIObEt:getPropValue("CurrencyInternalId")
									aAux := GetCurrId(cAux,cMarca)
									If !aAux[1]
										lRet := aAux[1]
										cLogErro := ""
										ofwEAIObj:Activate()
										ofwEAIObj:setProp("ReturnContent")
										cLogErro := aAux[2]
										ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
										aRet := {lRet, ofwEAIObj, cOwnerMsg}
										Return aRet

									Else
										aAdd(aCab, {"AD1_MOEDA", Val(aAux[2][3]), Nil})
									EndIf

						ElseIf oEAIObEt:getPropValue("Currency") != Nil .And. !Empty( oEAIObEt:getPropValue("Currency") )
							aAdd(aAD1Master, {"AD1_MOEDA", ToNumber(oEAIObEt:getPropValue("Currency")), Nil})
						EndIf

						//Previsão de receita inicial
						If oEAIObEt:getPropValue("InitialEstimate") != Nil .And. !Empty( oEAIObEt:getPropValue("InitialEstimate") )
							aAdd(aAD1Master, {"AD1_RCINIC", ToNumber(oEAIObEt:getPropValue("InitialEstimate")), Nil})
						EndIf

						//Verba estimada destinada pelo lead
						If oEAIObEt:getPropValue("EstimatedRevenue") != Nil .And. !Empty( oEAIObEt:getPropValue("EstimatedRevenue") )
							aAdd(aAD1Master, {"AD1_VERBA", ToNumber(oEAIObEt:getPropValue("EstimatedRevenue")), Nil})
						EndIf

						//Receita estimada no fechamento
						If oEAIObEt:getPropValue("MonthlyPayment") != Nil .And. !Empty( oEAIObEt:getPropValue("MonthlyPayment") )
							aAdd(aAD1Master, {"AD1_RCFECH", ToNumber(oEAIObEt:getPropValue("MonthlyPayment")), Nil})
						EndIf

						//Feeling
						If oEAIObEt:getPropValue("Feeling") != Nil .And. !Empty( oEAIObEt:getPropValue("Feeling") )
							aAdd(aAD1Master, {"AD1_FEELIN", AllTrim(oEAIObEt:getPropValue("Feeling")), Nil})
						EndIf

						//Fator crítico de sucesso
						If oEAIObEt:getPropValue("SuccessFactor") != Nil .And. !Empty( oEAIObEt:getPropValue("SuccessFactor") )
							aAdd(aAD1Master, {"AD1_FCS", AllTrim(oEAIObEt:getPropValue("SuccessFactor")), Nil})
						EndIf

						//Fato crítico de insucesso
						If oEAIObEt:getPropValue("FailureFactor") != Nil .And. !Empty( oEAIObEt:getPropValue("FailureFactor") )
							aAdd(aAD1Master, {"AD1_FCI", AllTrim(oEAIObEt:getPropValue("FailureFactor")), Nil})
						EndIf

						//Prioridade
						If oEAIObEt:getPropValue("Priority") != Nil .And. !Empty( oEAIObEt:getPropValue("Priority") )
							aAdd(aAD1Master, {"AD1_PRIOR", AllTrim(oEAIObEt:getPropValue("Priority")), Nil})
						EndIf

						//Status
						If oEAIObEt:getPropValue("Status") != Nil .And. !Empty( oEAIObEt:getPropValue("Status") )
							aAdd(aAD1Master, {"AD1_STATUS", AllTrim(oEAIObEt:getPropValue("Status")), Nil})
						EndIf

						//Código de Encerramento
						If oEAIObEt:getPropValue("Ending") != Nil .And. !Empty( oEAIObEt:getPropValue("Ending") )
							aAdd(aAD1Master, {"AD1_ENCERR", AllTrim(oEAIObEt:getPropValue("Ending")), Nil})
						EndIf

						//Motivo de Encerramento
						If oEAIObEt:getPropValue("Reason") != Nil .And. !Empty( oEAIObEt:getPropValue("Reason") )
							aAdd(aAD1Master, {"AD1_MTVENC", AllTrim(oEAIObEt:getPropValue("Reason")), Nil})
						EndIf

						//Tipo de comunicação
						If oEAIObEt:getPropValue("CommunicationType") != Nil .And. !Empty( oEAIObEt:getPropValue("CommunicationType") )
							aAdd(aAD1Master, {"AD1_COMUNI", AllTrim(oEAIObEt:getPropValue("CommunicationType")), Nil})
						EndIf

						//Unidade de venda (Canal)
						If oEAIObEt:getPropValue("SalesChannel") != Nil .And. !Empty( oEAIObEt:getPropValue("SalesChannel") )
							aAdd(aAD1Master, {"AD1_CANAL", AllTrim(oEAIObEt:getPropValue("SalesChannel")), Nil})
						EndIf

						//Tabela de preços
						If oEAIObEt:getPropValue("PriceTableCode") != Nil .And. !Empty( oEAIObEt:getPropValue("PriceTableCode") )
							aAdd(aAD1Master, {"AD1_TABELA", AllTrim(oEAIObEt:getPropValue("PriceTableCode")), Nil})
						EndIf

						//Produto
						If oEAIObEt:getPropValue("ProductCode") != Nil .And. !Empty( oEAIObEt:getPropValue("ProductCode") )
							aAdd(aAD1Master, {"AD1_CODPRO", AllTrim(oEAIObEt:getPropValue("ProductCode")), Nil})
						EndIf

						//Status do registro (bloqueio)
						If oEAIObEt:getPropValue("RecordStatus") != Nil .And. !Empty( oEAIObEt:getPropValue("RecordStatus") )
							aAdd(aAD1Master, {"AD1_MSBLQL", AllTrim(oEAIObEt:getPropValue("RecordStatus")), Nil})
						EndIf

						//Data de assinatura
						If oEAIObEt:getPropValue("DateSignature") != Nil .And. !Empty( oEAIObEt:getPropValue("DateSignature") )
							aAdd(aAD1Master, {"AD1_DTASSI", StoD(oEAIObEt:getPropValue("DateSignature")), Nil})
						EndIf

						//Comentários de fechamento
						If oEAIObEt:getPropValue("Comments") != Nil .And. !Empty( oEAIObEt:getPropValue("Comments") )
							aAdd(aAD1Master, {"AD1_OBSPRO", AllTrim(oEAIObEt:getPropValue("Comments")), Nil})
						EndIf

						//Contato da Assinatura
						If oEAIObEt:getPropValue("SignatureContactCode") != Nil .And. !Empty( oEAIObEt:getPropValue("SignatureContactCode") )
							aAdd(aAD1Master, {"AD1_CNTPRO", AllTrim(oEAIObEt:getPropValue("SignatureContactCode")), Nil})
						EndIf

						//Setor
						If oEAIObEt:getPropValue("Sector") != Nil .And. !Empty( oEAIObEt:getPropValue("Sector") )
							aAdd(aAD1Master, {"AD1_SETOR", AllTrim(oEAIObEt:getPropValue("Sector")), Nil})
						EndIf

						//Categoria
						If oEAIObEt:getPropValue("Category") != Nil .And. !Empty( oEAIObEt:getPropValue("Category") )
							aAdd(aAD1Master, {"AD1_CODCAT", AllTrim(oEAIObEt:getPropValue("Category")), Nil})
						EndIf

						//Time de vendas
						If oEAIObEt:getPropValue("SalesTeam") != Nil .And. !Empty( oEAIObEt:getPropValue("SalesTeam") ) .And. ValType(oEAIObEt:getPropValue("SalesTeam")) == "A"
							oAux := oEAIObEt:getPropValue("SalesTeam")

							nTamAux := TamSX3('AD2_VEND')[1]

							For nCount := 1 To Len(oAux)
								aDetailAux := {}

								If oAux[nCount]:getPropValue("SellerInternalId") != Nil .And. !Empty( oAux[nCount]:getPropValue("SellerInternalId") )

									aAux 	:= StrTokArr(CFGA070Int(cMarca, "SA3", "A3_COD", oAux[nCount]:getPropValue("SellerInternalId")),"|")

									If Len( aAux ) > 0
										If !Empty( aAux[Len(aAux)] )
											aAdd(aDetailAux, {"AD2_VEND", Padr(aAux[Len(aAux)],nTamAux), Nil})
										Endif
									Endif

								ElseIf oAux[nCount]:getPropValue("SellerCode") != Nil .And. !Empty( oAux[nCount]:getPropValue("SellerCode") )
									aAdd(aDetailAux, {"AD2_VEND", AllTrim(oAux[nCount]:getPropValue("SellerCode")), Nil })
								EndIf

								If oAux[nCount]:getPropValue("ParticipationPercentage") != Nil .And. !Empty( oAux[nCount]:getPropValue("ParticipationPercentage") )
									aAdd(aDetailAux, {"AD2_PERC", ToNumber(oAux[nCount]:getPropValue("ParticipationPercentage")), Nil })
								EndIf

								If oAux[nCount]:getPropValue("PaperCode") != Nil .And. !Empty( oAux[nCount]:getPropValue("PaperCode") )
									aAdd(aDetailAux, {"AD2_CODPAP", AllTrim(oAux[nCount]:getPropValue("PaperCode")), Nil })
								EndIf

								aAdd(aAD2Detail, aClone(aDetailAux))

							Next nCount

						EndIf

						//Concorrentes
						If oEAIObEt:getPropValue("Competitors") != Nil .And. !Empty( oEAIObEt:getPropValue("Competitors") ) .And. ValType(oEAIObEt:getPropValue("Competitors")) == "A"
							oAux := oEAIObEt:getPropValue("Competitors")

							For nCount := 1 To Len(oAux)
								aDetailAux := {}

								If oAux[nCount]:getPropValue("CompetitorCode") != Nil .And. !Empty( oAux[nCount]:getPropValue("CompetitorCode") )
									aAdd(aDetailAux, {"AD3_CODCON", AllTrim(oAux[nCount]:getPropValue("CompetitorCode")), Nil })
								EndIf

								If oAux[nCount]:getPropValue("Value") != Nil .And. !Empty( oAux[nCount]:getPropValue("Value") )
									aAdd(aDetailAux, {"AD3_PRECO", ToNumber(oAux[nCount]:getPropValue("Value")), Nil })
								EndIf

								If oAux[nCount]:getPropValue("Currency") != Nil .And. !Empty( oAux[nCount]:getPropValue("Currency") )
									aAdd(aDetailAux, {"AD3_MOEDA", ToNumber(oAux[nCount]:getPropValue("Currency")), Nil })
								EndIf

								If oAux[nCount]:getPropValue("SuccessFactor") != Nil .And. !Empty( oAux[nCount]:getPropValue("SuccessFactor") )
									aAdd(aDetailAux, {"AD3_FCS", AllTrim(oAux[nCount]:getPropValue("SuccessFactor")), Nil })
								EndIf

								If oAux[nCount]:getPropValue("FailureFactor") != Nil .And. !Empty( oAux[nCount]:getPropValue("FailureFactor") )
									aAdd(aDetailAux, {"AD3_FCI", AllTrim(oAux[nCount]:getPropValue("FailureFactor")), Nil })
								EndIf

								aAdd(aAD3Detail, aClone(aDetailAux))

							Next nCount

						EndIf

						//Parceiros
						If oEAIObEt:getPropValue("Partners") != Nil .And. !Empty( oEAIObEt:getPropValue("Partners") ) .And. ValType(oEAIObEt:getPropValue("Partners")) == "A"
							oAux := oEAIObEt:getPropValue("Partners")

							For nCount := 1 To Len(oAux)
								aDetailAux := {}

								If oAux[nCount]:getPropValue("PartnerCode") != Nil .And. !Empty( oAux[nCount]:getPropValue("PartnerCode") )
									aAdd(aDetailAux, {"AD4_PARTNE", AllTrim(oAux[nCount]:getPropValue("PartnerCode")), Nil })
								EndIf

								If oAux[nCount]:getPropValue("Notes") != Nil .And. !Empty( oAux[nCount]:getPropValue("Notes") )
									aAdd(aDetailAux, {"AD4_MEMO", AllTrim(oAux[nCount]:getPropValue("Notes")), Nil })
								EndIf

								aAdd(aAD4Detail, aClone(aDetailAux))

							Next nCount

						EndIf

						//Contatos
						If oEAIObEt:getPropValue("Contacts") != Nil .And. !Empty( oEAIObEt:getPropValue("Contacts") ) .And. ValType(oEAIObEt:getPropValue("Contacts")) == "A"
							oAux := oEAIObEt:getPropValue("Contacts")

							For nCount := 1 To Len(oAux)
								aDetailAux := {}

								If oAux[nCount]:getPropValue("ContactCode") != Nil .And. !Empty( oAux[nCount]:getPropValue("ContactCode") )
									aAdd(aDetailAux, {"AD9_CODCON", AllTrim(oAux[nCount]:getPropValue("ContactCode")), Nil })
								EndIf

								aAdd(aAD9Detail, aClone(aDetailAux))

							Next nCount

						EndIf

						//Produtos
						If oEAIObEt:getPropValue("Products") != Nil .And. !Empty( oEAIObEt:getPropValue("Products") ) .And. ValType(oEAIObEt:getPropValue("Products")) == "A"

							oAux := oEAIObEt:getPropValue("Products")
							nTamAux := TamSX3('B1_COD')[1]
							For nCount := 1 To Len(oAux)
								aDetailAux := {}

								If oAux[nCount]:getPropValue("Item") != Nil .And. !Empty( oAux[nCount]:getPropValue("Item") )
									aAdd(aDetailAux, {"ADJ_ITEM", PadL(AllTrim(oAux[nCount]:getPropValue("Item")),TamSX3("ADJ_ITEM")[1],"0"), Nil })
								EndIf

								If oAux[nCount]:getPropValue("ProductInternalId") != nil .And. !Empty( oAux[nCount]:getPropValue("ProductInternalId") )
									aAux := IntProInt(oAux[nCount]:getPropValue("ProductInternalId"), cMarca)
									If !aAux[1]
										lRet := aAux[1]
										cLogErro := ""
										ofwEAIObj:Activate()
										ofwEAIObj:setProp("ReturnContent")
										cLogErro := aAux[2]
										ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
										aRet := {lRet, ofwEAIObj, cOwnerMsg}
										Return aRet

									Else
										aAdd(aDetailAux, {"ADJ_PROD",Padr(aAux[2][3],nTamAux) , Nil})
									EndIf

								ElseIf oAux[nCount]:getPropValue("ProductCode") != Nil .And. !Empty( oAux[nCount]:getPropValue("ProductCode") )
									aAdd(aDetailAux, {"ADJ_PROD", Padr(oAux[nCount]:getPropValue("ProductCode"),nTamAux), Nil })
								EndIf

								If oAux[nCount]:getPropValue("Forecast") != Nil .And. !Empty( oAux[nCount]:getPropValue("Forecast") )
									aAdd(aDetailAux, {"ADJ_FCAST", oAux[nCount]:getPropValue("Forecast"), Nil })
								EndIf

								If oAux[nCount]:getPropValue("Quantity") != Nil .And. !Empty( oAux[nCount]:getPropValue("Quantity") )
									aAdd(aDetailAux, {"ADJ_QUANT", ToNumber(oAux[nCount]:getPropValue("Quantity")), Nil })
								EndIf

								If oAux[nCount]:getPropValue("UnitValue") != Nil .And. !Empty( oAux[nCount]:getPropValue("UnitValue") )
									aAdd(aDetailAux, {"ADJ_PRUNIT", ToNumber(oAux[nCount]:getPropValue("UnitValue")), Nil })
								EndIf

								If oAux[nCount]:getPropValue("TotalAmount") != Nil .And. !Empty( oAux[nCount]:getPropValue("TotalAmount") )
									aAdd(aDetailAux, {"ADJ_VALOR", ToNumber(oAux[nCount]:getPropValue("TotalAmount")), Nil })
								EndIf

								If oAux[nCount]:getPropValue("CategoryInternalId") != nil .And. !Empty( oAux[nCount]:getPropValue("CategoryInternalId") )

									aAux 	:= StrTokArr(CFGA070Int(cMarca, "ACU", "ACU_COD", oAux[nCount]:getPropValue("CategoryInternalId")),"|")

									If Len( aAux ) > 0
										If !Empty( aAux[Len(aAux)] )
											aAdd(aDetailAux, {"ADJ_CATEG", AllTrim(aAux[Len(aAux)]), Nil})
										Endif
									Endif

								ElseIf oAux[nCount]:getPropValue("Category") != Nil .And. !Empty( oAux[nCount]:getPropValue("Category") )
									aAdd(aDetailAux, {"ADJ_CATEG", AllTrim(oAux[nCount]:getPropValue("Category")), Nil })
								EndIf

								If oAux[nCount]:getPropValue("GrouperCode") != Nil .And. !Empty( oAux[nCount]:getPropValue("GrouperCode") )
									aAdd(aDetailAux, {"ADJ_CODAGR", AllTrim(oAux[nCount]:getPropValue("GrouperCode")), Nil })
								EndIf

								If oAux[nCount]:getPropValue("GrouperLevel") != Nil .And. !Empty( oAux[nCount]:getPropValue("GrouperLevel") )
									aAdd(aDetailAux, {"ADJ_CODNIV", AllTrim(oAux[nCount]:getPropValue("GrouperLevel")), Nil })
								EndIf

								aAdd(aADJDetail, aClone(aDetailAux))

							Next nCount

						EndIf

					EndIf

					//Ponto de entrada para customizações de entrada
					If ExistBlock('F300OMME')

						aRetPE := ExecBlock("F300OMME",.F.,.F., { 	cEvent, ;
																	nOpcX, ;
																	oEAIObEt, ;
																	cValExt, ;
																	aAux, ;
																	aClone(aAD1Master), ;
																	aClone(aAD2Detail), ;
																	aClone(aAD3Detail), ;
																	aClone(aAD4Detail), ;
																	aClone(aAD9Detail), ;
																	aClone(aADJDetail) })

						If ValType(aRetPE) == 'A'

							If Len(aRetPE) >= 1 .And. ValType(aRetPE[1]) == 'A'
								aAD1Master := aClone(aRetPE[1])
							EndIf

							If Len(aRetPE) >= 2 .And. ValType(aRetPE[2]) == 'A'
								aAD2Detail := aClone(aRetPE[2])
							EndIf

							If Len(aRetPE) >= 3 .And. ValType(aRetPE[3]) == 'A'
								aAD3Detail := aClone(aRetPE[3])
							EndIf

							If Len(aRetPE) >= 4 .And. ValType(aRetPE[4]) == 'A'
								aAD4Detail := aClone(aRetPE[4])
							EndIf

							If Len(aRetPE) >= 5 .And. ValType(aRetPE[5]) == 'A'
								aAD9Detail := aClone(aRetPE[5])
							EndIf

							If Len(aRetPE) >= 6 .And. ValType(aRetPE[6]) == 'A'
								aADJDetail := aClone(aRetPE[6])
							EndIf

						EndIf

					EndIf

					//Posicionamento de campos de acordo com o dicionário
					aAD1Master := FWVetByDic(aAD1Master,"AD1",.F.)
					For nCount := 1 To Len(aAD2Detail)
						aAD2Detail[nCount] := FWVetByDic(aAD2Detail[nCount],"AD2",.F.)
					Next nCount

					For nCount := 1 To Len(aAD3Detail)
						aAD3Detail[nCount] := FWVetByDic(aAD3Detail[nCount],"AD3",.F.)
					Next nCount

					For nCount := 1 To Len(aAD4Detail)
						aAD4Detail[nCount] := FWVetByDic(aAD4Detail[nCount],"AD4",.F.)
					Next nCount

					For nCount := 1 To Len(aAD9Detail)
						aAD9Detail[nCount] := FWVetByDic(aAD9Detail[nCount],"AD9",.F.)
					Next nCount

					For nCount := 1 To Len(aADJDetail)
						aADJDetail[nCount] := FWVetByDic(aADJDetail[nCount],"ADJ",.F.)
					Next nCount

					//Verifica se é alteração, para apagar os itens antigos das grids antes de inserir os novos
					If nOpcx == 4

						AD1->(DbSetOrder(1))
						AD1->(DbSeek(xFilial('AD1') + Padr(cCode, Len(AD1->AD1_NROPOR))))

						AD2->(DbSetOrder(1))
						cChaveGrid := xFilial('AD2') + AD1->AD1_NROPOR + AD1->AD1_REVISA

						AD2->(DbSeek(cChaveGrid))

						While AD2->(AD2_FILIAL + AD2_NROPOR + AD2_REVISA) == cChaveGrid

							aDetailAux := {}

							aAdd(aDetailAux, {"LINPOS", "AD2_VEND", AD2->AD2_VEND, Nil })
							aAdd(aDetailAux, {"AUTDELETA", "S", Nil })
							
							aSize(aAD2Detail, Len(aAD2Detail) + 1)
							aIns(aAD2Detail, 1)
							aAD2Detail[1] := aClone(aDetailAux)

							AD2->(DbSkip())

						EndDo

						AD3->(DbSetOrder(1))
						cChaveGrid := xFilial('AD3') + AD1->AD1_NROPOR + AD1->AD1_REVISA

						AD3->(DbSeek(cChaveGrid))

						While AD3->(AD3_FILIAL + AD3_NROPOR + AD3_REVISA) == cChaveGrid

							aDetailAux := {}

							aAdd(aDetailAux, {"LINPOS", "AD3_CODCON", AD3->AD3_CODCON, Nil })
							aAdd(aDetailAux, {"AUTDELETA", "S", Nil })

							aSize(aAD3Detail, Len(aAD3Detail) + 1)
							aIns(aAD3Detail, 1)
							aAD3Detail[1] := aClone(aDetailAux)

							AD3->(DbSkip())

						EndDo

						AD4->(DbSetOrder(1))
						cChaveGrid := xFilial('AD4') + AD1->AD1_NROPOR + AD1->AD1_REVISA

						AD4->(DbSeek(cChaveGrid))

						While AD4->(AD4_FILIAL + AD4_NROPOR + AD4_REVISA) == cChaveGrid

							aDetailAux := {}

							aAdd(aDetailAux, {"LINPOS", "AD4_PARTNE", AD4->AD4_PARTNE, Nil })
							aAdd(aDetailAux, {"AUTDELETA", "S", Nil })

							aSize(aAD4Detail, Len(aAD4Detail) + 1)
							aIns(aAD4Detail, 1)
							aAD4Detail[1] := aClone(aDetailAux)

							AD4->(DbSkip())

						EndDo

						AD9->(DbSetOrder(1))
						cChaveGrid := xFilial('AD9') + AD1->AD1_NROPOR + AD1->AD1_REVISA

						AD9->(DbSeek(cChaveGrid))

						While AD9->(AD9_FILIAL + AD9_NROPOR + AD9_REVISA) == cChaveGrid

							aDetailAux := {}

							aAdd(aDetailAux, {"LINPOS", "AD9_CODCON", AD9->AD9_CODCON, Nil })
							aAdd(aDetailAux, {"AUTDELETA", "S", Nil })
							
							aSize(aAD9Detail, Len(aAD9Detail) + 1)
							aIns(aAD9Detail, 1)
							aAD9Detail[1] := aClone(aDetailAux)

							AD9->(DbSkip())

						EndDo

						ADJ->(DbSetOrder(1))
						cChaveGrid := xFilial('ADJ') + AD1->AD1_NROPOR + AD1->AD1_REVISA

						ADJ->(DbSeek(cChaveGrid))

						While ADJ->(ADJ_FILIAL + ADJ_NROPOR + ADJ_REVISA) == cChaveGrid

							aDetailAux := {}

							If nCtrlADJ == 4 //Agrupador
								aAdd(aDetailAux, {"LINPOS", "ADJ_CODNIV", ADJ->(ADJ_CODNIV), Nil })
							Else
								aAdd(aDetailAux, {"LINPOS", "ADJ_ITEM", ADJ->ADJ_ITEM, Nil })
							EndIf
							aAdd(aDetailAux, {"AUTDELETA", "S", Nil })

							aSize(aADJDetail, Len(aADJDetail) + 1)
							aIns(aADJDetail, 1)
							aADJDetail[1] := aClone(aDetailAux)

							ADJ->(DbSkip())

						EndDo

					EndIf

					//Executa rotina automática
					FATA300(nOpcX,aAD1Master,aAD2Detail,aAD3Detail,aAD4Detail,aAD9Detail,aADJDetail)

					// Se a Rotina Automática retornou erro
					If lMsErroAuto

						lRet := .F.

						// Obtém o log de erros
						cLogErro := MemoRead(NomeAutoLog())

						cLogErro := StrTran( StrTran( cLogErro, "<", "" ), "-", "" )

						ofwEAIObj:Activate()
						ofwEAIObj:setProp("ReturnContent")
						ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)

					Else
						cValInt := IntOpoExt(, , AD1->AD1_NROPOR)[2]
						// CRUD do XXF (de/para)
						If nOpcx == 3 // Insert
							CFGA070Mnt(cMarca, cAlias, cField, cValExt, cValInt, .F.,,,cOwnerMsg)
						ElseIf nOpcx == 5  // Delete
							CFGA070Mnt(cMarca, cAlias, cField, cValExt, cValInt, .T.,,,cOwnerMsg)
						EndIf

						lRet := .T.
						ofwEAIObj:Activate()
						ofwEAIObj:setProp("ReturnContent")
						ofwEAIObj:getPropValue("ReturnContent"):setProp("ListOfInternalID",{},'InternalId',,.T.)
						ofwEAIObj:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:setProp("Name","OPPORTUNITY")
						ofwEAIObj:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:setProp("Origin",      	cValExt)
						ofwEAIObj:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:setProp("Destination",  cValInt)

					EndIf
				EndIf
			EndIf

			//--------------------------------------
			//resposta da mensagem Unica TOTVS
			//--------------------------------------
		ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE

			// Verifica se a marca foi informada
			If oEAIObEt:getHeaderValue("ProductName") !=  nil .And. !Empty( oEAIObEt:getHeaderValue("ProductName") )
				cMarca := Upper(oEAIObEt:getHeaderValue("ProductName"))

				// Verifica se o código interno foi informado
				If oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:getPropValue("Origin") != nil
					cValInt := oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:getPropValue("Origin")
				Endif

				// Verifica se o código externo foi informado
				If oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:getPropValue("Destination") != nil
					cValExt := oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:getPropValue("Destination")
				Endif

				If !Empty(cValInt) .And. !Empty(cValExt)
					// Se não houve erros no parse
					If Upper(AllTrim(oEAIObEt:getPropValue("ReceivedMessage"):getPropValue("Event"))) == 'DELETE'
						// Exclui o registro na tabela XXF (de/para)
						CFGA070Mnt(cMarca, cAlias, cField, cValExt, cValInt,.T.)
					Else
						// Insere / Atualiza o registro na tabela XXF (de/para)
						CFGA070Mnt(cMarca, cAlias, cField, cValExt, cValInt, .F.,,,cOwnerMsg)
					EndIf
				Else
					lRet    := .F.
					cLogErro := ""
					ofwEAIObj:Activate()
					ofwEAIObj:setProp("ReturnContent")
					cLogErro := STR0009 //"Não enviado conteúdo de retorno para cadastro de de-para."
					ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
				Endif
			Endif

			//--------------------------------------
			//whois
			//--------------------------------------
		ElseIf   cTypeMessage == EAI_MESSAGE_WHOIS

			ofwEAIObj := "1.000"

        EndIf

		//--------------------------------------
		//envio mensagem
		//--------------------------------------
	ElseIf(nTypeTrans == TRANS_SEND)

		oModel := FwModelActive()

		If VALTYPE(oModel) <> "U"
			If oModel:GetOperation() == MODEL_OPERATION_DELETE
				cEvent := 'delete'
			EndIf
		ElseIf Type("INCLUI") == "L" .And. Type("ALTERA") == "L"
			If ( !INCLUI .AND. !ALTERA )
				cEvent := 'delete'
			EndIf
		EndIf

		//Ponto de Entrada de Filtro de Envio da Mensag. Saída - Mesmo que o campo XX4_EXPFIL
		If lF300Fils
			lRetPE := ExecBlock("F300OFILS",.F.,.F., {cEvent, oModel, ofwEAIObj})
		EndIf

		If (lF300Fils .and. lRetPe) .or. (!lF300Fils)
			cValExt := IntOpoExt(, , AD1->AD1_NROPOR)[2]

			If cEvent == "delete"
				CFGA070Mnt(,cAlias,cField,,cValExt,.T.,,,cOwnerMsg)
			EndIf

			dbSelectArea("AD2")
			AD2->(dbSetOrder(1))

			dbSelectArea("AD3")
			AD3->(dbSetOrder(1))

			dbSelectArea("AD4")
			AD4->(dbSetOrder(1))

			dbSelectArea("AIJ")
			AIJ->(dbSetOrder(1))

			cNomVend := Alltrim(Posicione("SA3",1,xFilial("SA3")+AD1->AD1_VEND,"A3_NOME"))
			cNomCli  := Alltrim(Posicione("SA1",1, xFilial("SA1")+AD1->(AD1_CODCLI+AD1_LOJCLI),"A1_NOME"))
			cNomPro  := Alltrim(Posicione("SUS",1,xFilial("SUS")+AD1->(AD1_PROSPE+AD1_LOJPRO),"US_NREDUZ"))
			cDescMoe := SuperGetMv("MV_MOEDA"+AllTrim(Str(AD1->AD1_MOEDA,2)))
			cDescPrd := Alltrim(Posicione("SB1",1,xFilial("SB1")+AD1->AD1_CODPRO,"B1_DESC"))
			cDescCnt := Alltrim(Posicione("SU5",1,xFilial("SU5")+AD1->AD1_CNTPRO,"U5_CONTAT"))
			cNomUser := FwGetUserName(AD1->AD1_USRASS)
			cDescCam := Alltrim(Posicione("SUO",1,AllTrim(AD1->AD1_CHVCAM),"UO_DESC"))

			//Montagem da mensagem
			ofwEAIObj:Activate()
			ofwEAIObj:setEvent(cEvent)

			// Detalhamento dos campos da Oportunidade(Form)
			ofwEAIObj:setprop("CompanyInternal", cEmpAnt+Rtrim(AD1->(AD1_FILIAL+AD1_NROPOR)))
			ofwEAIObj:setprop("InternalId", Rtrim(cValExt))
			ofwEAIObj:setprop("BranchId", cFilAnt)
			ofwEAIObj:setprop("Code", Rtrim(AD1->AD1_NROPOR))
			ofwEAIObj:setprop("Review", Rtrim(AD1->AD1_REVISA))
			ofwEAIObj:setprop("Description", Rtrim(AD1->AD1_DESCRI))
			ofwEAIObj:setprop("Seller", Rtrim(AD1->AD1_VEND))
			ofwEAIObj:setprop("SellerName", Rtrim(cNomVend))
			ofwEAIObj:setprop("CreateDate", DtoC(AD1->AD1_DATA))
			ofwEAIObj:setprop("StartDate", DtoC(AD1->AD1_DTINI))
			ofwEAIObj:setprop("ClosingDate", DtoC(AD1->AD1_DTFIM))
			ofwEAIObj:setprop("EntityType", IIF(!Empty(Rtrim(AD1->AD1_CODCLI)),"1","2"))
			ofwEAIObj:setprop("EntityId", IIF(!Empty(Rtrim(AD1->AD1_CODCLI)), AD1->AD1_CODCLI ,AD1->AD1_PROSPE))
			ofwEAIObj:setprop("EntityUnit", IIF(!Empty(Rtrim(AD1->AD1_CODCLI)),AD1->AD1_LOJCLI ,AD1->AD1_LOJPRO))
			ofwEAIObj:setprop("EntityName",IIF(!Empty(Rtrim(AD1->AD1_CODCLI)),cNomCli , cNomPro))
			ofwEAIObj:setprop("Process", Rtrim(AD1->AD1_PROVEN))
			ofwEAIObj:setprop("Stage", Rtrim(AD1->AD1_STAGE))
			ofwEAIObj:setprop("Notes", MSMM(AD1->AD1_CODMEM))
			ofwEAIObj:setprop("ExpectedEndDate", DtoC(AD1->AD1_DTPFIM))
			ofwEAIObj:setprop("ExpectedClosingDate", DtoC(AD1->AD1_DTPENC))
			ofwEAIObj:setprop("ExpectedClosingTime", Rtrim(AD1->AD1_HRPENC))
			ofwEAIObj:setprop("Currency", AD1->AD1_MOEDA)
			ofwEAIObj:setprop("CurrencyDescription", Rtrim(cDescMoe))
			ofwEAIObj:setprop("InitialEstimate", AD1->AD1_RCINIC)
			ofwEAIObj:setprop("EstimatedRevenue", AD1->AD1_VERBA)
			ofwEAIObj:setprop("MonthlyPayment", AD1->AD1_RCFECH)
			ofwEAIObj:setprop("RealIncome", AD1->AD1_RCREAL)
			ofwEAIObj:setprop("Cost", AD1->AD1_CUSTO)
			ofwEAIObj:setprop("Feeling", Rtrim(AD1->AD1_FEELIN))
			ofwEAIObj:setprop("SuccessFactor", Rtrim(AD1->AD1_FCS))
			ofwEAIObj:setprop("FailureFactor", Rtrim(AD1->AD1_FCI))
			ofwEAIObj:setprop("Priority", Rtrim(AD1->AD1_PRIOR))
			ofwEAIObj:setprop("Status", Rtrim(AD1->AD1_STATUS))
			ofwEAIObj:setprop("Ending", Rtrim(AD1->AD1_ENCERR))
			ofwEAIObj:setprop("Reason", Rtrim(AD1->AD1_MTVENC))
			ofwEAIObj:setprop("Mode", Rtrim(AD1->AD1_MODO))
			ofwEAIObj:setprop("CommunicationType", Rtrim(AD1->AD1_COMUNI))
			ofwEAIObj:setprop("SalesChannel", Rtrim(AD1->AD1_CANAL))
			ofwEAIObj:setprop("PriceTableCode", Rtrim(AD1->AD1_TABELA))
			ofwEAIObj:setprop("ProductCode", Rtrim(AD1->AD1_CODPRO))
			ofwEAIObj:setprop("ProductDescription", Rtrim(cDescPrd))
			ofwEAIObj:setprop("TechnicalInspection", Rtrim(AD1->AD1_VISTEC))
			ofwEAIObj:setprop("TechnicalInspectionCode", Rtrim(AD1->AD1_CODVIS))
			ofwEAIObj:setprop("TechnicalInspectionStatus", Rtrim(AD1->AD1_SITVIS))
			ofwEAIObj:setprop("ServiceCode", Rtrim(AD1->AD1_CODTMK))
			ofwEAIObj:setprop("SLAIdRecord", Rtrim(AD1->AD1_REGSLA))
			ofwEAIObj:setprop("RecordStatus", Rtrim(AD1->AD1_MSBLQL))
			ofwEAIObj:setprop("DateSignature", DtoC(AD1->AD1_DTASSI))
			ofwEAIObj:setprop("Comments", Rtrim(AD1->AD1_OBSPRO))
			ofwEAIObj:setprop("SignatureContactCode", Rtrim(AD1->AD1_CNTPRO))
			ofwEAIObj:setprop("SignatureContactName", Rtrim(cDescCnt))
			ofwEAIObj:setprop("ResponsibleUserCode", Rtrim(AD1->AD1_USRASS))
			ofwEAIObj:setprop("ResponsibleUserName", Rtrim(cNomUser))
			ofwEAIObj:setprop("Sector", Rtrim(AD1->AD1_SETOR))
			ofwEAIObj:setprop("Category", Rtrim(AD1->AD1_CODCAT))
			ofwEAIObj:setprop("CampaignType", Rtrim(AD1->AD1_TPCAMP))
			ofwEAIObj:setprop("CampaignCode", Rtrim(AD1->AD1_CHVCAM))
			ofwEAIObj:setprop("CampaignDescription", Rtrim(cDescCam))

			// Detalhamento dos campos do Time de Vendas (Grid)
			If AD2->(dbSeek(xFilial("AD2")+ AD1->(AD1_NROPOR + AD1_REVISA)))
				nCont := 1

				While AD2->(! Eof()) .And. AD2->(AD2_FILIAL+AD2_NROPOR+AD2_REVISA) == AD1->((AD1_FILIAL + AD1_NROPOR + AD1_REVISA))

					cNomGsn 	:= Alltrim(Posicione("SA3",1,xFilial("SA3")+AD2->AD2_VEND,"A3_NOME"))
					cDscCar 	:= Alltrim(Ft300NCargo(AD2->AD2_CODCAR))
					cDscUnid	:= Alltrim(Posicione("ADK",1,xFilial("ADK")+AD2->AD2_UNIDAD,"ADK_NOME"))
					cRespUnid	:= Alltrim(Posicione("SA3",1,xFilial("SA3")+AD2->AD2_RESPUN,"A3_NOME"))
					cDescPapel	:= Alltrim(Ft300NCargo(AD2->AD2_CODPAP))

					ofwEAIObj:setprop('SalesTeam',{},'ST',,.T.)

					ofwEAIObj:get("SalesTeam")[nCont]:setprop("BranchId"   						, Rtrim(AD2->AD2_FILIAL),,.T.)
					ofwEAIObj:get("SalesTeam")[nCont]:setprop("Code"     						, Rtrim(AD2->AD2_NROPOR),,.T.)
					ofwEAIObj:get("SalesTeam")[nCont]:setprop("Review"							, Rtrim(AD2->AD2_REVISA),,.T.)
					ofwEAIObj:get("SalesTeam")[nCont]:setprop("History"							, Rtrim(AD2->AD2_HISTOR),,.T.)
					ofwEAIObj:get("SalesTeam")[nCont]:setprop("SellerCode"						, Rtrim(AD2->AD2_VEND),,.T.)
					ofwEAIObj:get("SalesTeam")[nCont]:setprop("SellerName"						, Rtrim(cNomGsn),,.T.)
					ofwEAIObj:get("SalesTeam")[nCont]:setprop("ParticipationPercentage"			, AD2->AD2_PERC,,.T.)
					ofwEAIObj:get("SalesTeam")[nCont]:setprop("PositionCode"					, Rtrim(AD2->AD2_CODCAR),,.T.)
					ofwEAIObj:get("SalesTeam")[nCont]:setprop("Position"						, Rtrim(cDscCar),,.T.)
					ofwEAIObj:get("SalesTeam")[nCont]:setprop("SalesChannel"					, Rtrim(AD2->AD2_UNIDAD),,.T.)
					ofwEAIObj:get("SalesTeam")[nCont]:setprop("SalesChannelName"				, Rtrim(cDscUnid),,.T.)
					ofwEAIObj:get("SalesTeam")[nCont]:setprop("SalesChannelResponsible"			, Rtrim(AD2->AD2_RESPUN),,.T.)
					ofwEAIObj:get("SalesTeam")[nCont]:setprop("SalesChannelResponsibleName"		, Rtrim(cRespUnid),,.T.)
					ofwEAIObj:get("SalesTeam")[nCont]:setprop("PaperCode"						, Rtrim(AD2->AD2_CODPAP),,.T.)
					ofwEAIObj:get("SalesTeam")[nCont]:setprop("Paper"							, Rtrim(cDescPapel),,.T.)
					ofwEAIObj:get("SalesTeam")[nCont]:setprop("BusinessStructureAccessId"		, Rtrim(AD2->AD2_IDESTN),,.T.)
					ofwEAIObj:get("SalesTeam")[nCont]:setprop("BusinessStructureAccessLevel"	, AD2->AD2_NVESTN,,.T.)

					nCont++
					AD2->(dbSkip())
				endDo

			Endif

			// Detalhamento dos campos dos Concorrentes (Grid)
			If AD3->(dbSeek(xFilial("AD3")+ AD1->(AD1_NROPOR + AD1_REVISA)))
				nCont := 1

				While AD3->(! Eof()) .And. AD3->(AD3_FILIAL+AD3_NROPOR+AD3_REVISA) == AD1->((AD1_FILIAL + AD1_NROPOR + AD1_REVISA))

					cDescComp := Alltrim(Posicione("AC3",1,xFilial("AC3")+AD3->AD3_CODCON,"AC3_NOME"))

					ofwEAIObj:setprop('Competitors',{},'CP',,.T.)

					ofwEAIObj:get("Competitors")[nCont]:setprop("BranchId"   					, Rtrim(AD3->AD3_FILIAL),,.T.)
					ofwEAIObj:get("Competitors")[nCont]:setprop("Code"     						, Rtrim(AD3->AD3_NROPOR),,.T.)
					ofwEAIObj:get("Competitors")[nCont]:setprop("Review"						, Rtrim(AD3->AD3_REVISA),,.T.)
					ofwEAIObj:get("Competitors")[nCont]:setprop("History"						, Rtrim(AD3->AD3_HISTOR),,.T.)
					ofwEAIObj:get("Competitors")[nCont]:setprop("CompetitorCode"				, Rtrim(AD3->AD3_CODCON),,.T.)
					ofwEAIObj:get("Competitors")[nCont]:setprop("CompetitorName"				, Rtrim(cDescComp),,.T.)
					ofwEAIObj:get("Competitors")[nCont]:setprop("Value"							, AD3->AD3_PRECO,,.T.)
					ofwEAIObj:get("Competitors")[nCont]:setprop("Currency"						, AD3->AD3_MOEDA,,.T.)
					ofwEAIObj:get("Competitors")[nCont]:setprop("SuccessFactor"					, Rtrim(AD3->AD3_FCS),,.T.)
					ofwEAIObj:get("Competitors")[nCont]:setprop("FailureFactor"					, Rtrim(AD3->AD3_FCI),,.T.)

					nCont++
					AD3->(dbSkip())
				endDo

			Endif


			// Detalhamento dos campos de Parceiros (Grid)
			If AD4->(dbSeek(xFilial("AD4")+ AD1->(AD1_NROPOR + AD1_REVISA)))
				nCont := 1

				While AD4->(! Eof()) .And. AD4->(AD4_FILIAL+AD4_NROPOR+AD4_REVISA) == AD1->((AD1_FILIAL + AD1_NROPOR + AD1_REVISA))

					cNomPar := Alltrim(Posicione("AC4",1,xFilial("AC4")+AD4->AD4_PARTNE,"AC4_NOME"))

					ofwEAIObj:setprop('Partners',{},'PT',,.T.)

					ofwEAIObj:get("Partners")[nCont]:setprop("BranchId"   				, Rtrim(AD4->AD4_FILIAL),,.T.)
					ofwEAIObj:get("Partners")[nCont]:setprop("Code"     				, Rtrim(AD4->AD4_NROPOR),,.T.)
					ofwEAIObj:get("Partners")[nCont]:setprop("Review"					, Rtrim(AD4->AD4_REVISA),,.T.)
					ofwEAIObj:get("Partners")[nCont]:setprop("History"					, Rtrim(AD4->AD4_HISTOR),,.T.)
					ofwEAIObj:get("Partners")[nCont]:setprop("PartnerCode"				, Rtrim(AD4->AD4_PARTNE),,.T.)
					ofwEAIObj:get("Partners")[nCont]:setprop("PartnerName"				, Rtrim(cNomPar),,.T.)
					ofwEAIObj:get("Partners")[nCont]:setprop("Notes"					, MSMM(AD4->AD4_CODMEM),,.T.)

					nCont++
					AD4->(dbSkip())
				endDo

			Endif

			// Detalhamento dos campos de Contatos (Grid)
			If AD9->(dbSeek(xFilial("AD9")+ AD1->(AD1_NROPOR + AD1_REVISA)))
				nCont := 1

				While AD9->(! Eof()) .And. AD9->(AD9_FILIAL+AD9_NROPOR+AD9_REVISA) == AD1->((AD1_FILIAL + AD1_NROPOR + AD1_REVISA))

					cNmContact := Alltrim(Posicione("SU5",1,xFilial("SU5")+AD9->AD9_CODCON,"U5_CONTAT"))

					ofwEAIObj:setprop('Contacts',{},'CT',,.T.)

					ofwEAIObj:get("Contacts")[nCont]:setprop("BranchId"   				, Rtrim(AD9->AD9_FILIAL),,.T.)
					ofwEAIObj:get("Contacts")[nCont]:setprop("Code"     				, Rtrim(AD9->AD9_NROPOR),,.T.)
					ofwEAIObj:get("Contacts")[nCont]:setprop("Review"					, Rtrim(AD9->AD9_REVISA),,.T.)
					ofwEAIObj:get("Contacts")[nCont]:setprop("History"					, Rtrim(AD9->AD9_HISTOR),,.T.)
					ofwEAIObj:get("Contacts")[nCont]:setprop("ContactCode"				, Rtrim(AD9->AD9_CODCON),,.T.)
					ofwEAIObj:get("Contacts")[nCont]:setprop("ContactName"				, Rtrim(cNmContact),,.T.)

					nCont++
					AD9->(dbSkip())
				endDo

			Endif

			// Detalhamento dos campos de Produtos (Grid)
			If ADJ->(dbSeek(xFilial("ADJ")+ AD1->(AD1_NROPOR + AD1_REVISA)))
				nCont := 1

				While ADJ->(! Eof()) .And. ADJ->(ADJ_FILIAL+ADJ_NROPOR+ADJ_REVISA) == AD1->((AD1_FILIAL + AD1_NROPOR + AD1_REVISA))

					cNmProd 	:= Alltrim(Posicione("SB1",1,xFilial("SB1")+ADJ->ADJ_PROD,"B1_DESC"))
					cDecCateg 	:= Alltrim(Posicione("ACU",1,xFilial("ACU")+ADJ->ADJ_CATEG,"ACU_DESC"))
					cDescAgrup	:= AllTrim(Posicione("AOL",1,xFilial("AOL")+ADJ->ADJ_CODAGR,"AOL_RESUMO"))
					cDescNivel	:= AllTrim(Posicione("AOM",1,xFilial("AOM")+ADJ->ADJ_CODAGR+ADJ->ADJ_CODNIV,"AOM_DESCRI"))

					ofwEAIObj:setprop('Products',{},'PD',,.T.)

					ofwEAIObj:get("Products")[nCont]:setprop("BranchId"   				, Rtrim(ADJ->ADJ_FILIAL),,.T.)
					ofwEAIObj:get("Products")[nCont]:setprop("Code"     				, Rtrim(ADJ->ADJ_NROPOR),,.T.)
					ofwEAIObj:get("Products")[nCont]:setprop("Review"					, Rtrim(ADJ->ADJ_REVISA),,.T.)
					ofwEAIObj:get("Products")[nCont]:setprop("History"					, Rtrim(ADJ->ADJ_HISTOR),,.T.)
					ofwEAIObj:get("Products")[nCont]:setprop("Item"						, Rtrim(ADJ->ADJ_ITEM),,.T.)
					ofwEAIObj:get("Products")[nCont]:setprop("ProductCode"				, Rtrim(ADJ->ADJ_PROD),,.T.)
					ofwEAIObj:get("Products")[nCont]:setprop("ProductName"				, Rtrim(cNmProd),,.T.)
					ofwEAIObj:get("Products")[nCont]:setprop("Quantity"					, ADJ->ADJ_QUANT,,.T.)
					ofwEAIObj:get("Products")[nCont]:setprop("UnitValue"				, ADJ->ADJ_PRUNIT,,.T.)
					ofwEAIObj:get("Products")[nCont]:setprop("TotalAmount"				, ADJ->ADJ_VALOR,,.T.)
					ofwEAIObj:get("Products")[nCont]:setprop("BudgetNumber"				, Rtrim(ADJ->ADJ_NUMORC),,.T.)
					ofwEAIObj:get("Products")[nCont]:setprop("ProposalNumber"			, Rtrim(ADJ->ADJ_PROPOS),,.T.)
					ofwEAIObj:get("Products")[nCont]:setprop("SalesType"				, Rtrim(ADJ->ADJ_TPVEND),,.T.)
					ofwEAIObj:get("Products")[nCont]:setprop("Category"					, Rtrim(ADJ->ADJ_CATEG),,.T.)
					ofwEAIObj:get("Products")[nCont]:setprop("CategoryName"				, Rtrim(cDecCateg),,.T.)
					ofwEAIObj:get("Products")[nCont]:setprop("GrouperCode"				, Rtrim(ADJ->ADJ_CODAGR),,.T.)
					ofwEAIObj:get("Products")[nCont]:setprop("GrouperLevel"				, Rtrim(ADJ->ADJ_CODNIV),,.T.)
					ofwEAIObj:get("Products")[nCont]:setprop("GrouperDescription"		, cDescAgrup,,.T.)
					ofwEAIObj:get("Products")[nCont]:setprop("GrouperLevelDescription"	, cDescNivel,,.T.)
					ofwEAIObj:get("Products")[nCont]:setprop("Forecast"					, Rtrim(ADJ->ADJ_FCAST),,.T.)
					ofwEAIObj:get("Products")[nCont]:setprop("GrouperSmartCode"			, Rtrim(ADJ->ADJ_IDINT),,.T.)

					nCont++
					ADJ->(dbSkip())
				endDo

			Endif

			// Detalhamento dos campos de Evolução de Venda (Grid)
			If AIJ->(dbSeek(xFilial("AIJ")+ AD1->(AD1_NROPOR + AD1_REVISA)))
				nCont := 1

				While AIJ->(! Eof()) .And. AIJ->(AIJ_FILIAL+AIJ_NROPOR+AIJ_REVISA) == AD1->((AD1_FILIAL + AD1_NROPOR + AD1_REVISA))

					cDescStage := Alltrim(POSICIONE("AC2",1,FwxFilial("AC2")+AD1->AD1_PROVEN+AD1->AD1_STAGE,"AC2_DESCRI"))

					ofwEAIObj:setprop('SalesEvolution',{},'SE',,.T.)

					ofwEAIObj:get("SalesEvolution")[nCont]:setprop("BranchId"   				, Rtrim(AIJ->AIJ_FILIAL),,.T.)
					ofwEAIObj:get("SalesEvolution")[nCont]:setprop("Code"     					, Rtrim(AIJ->AIJ_NROPOR),,.T.)
					ofwEAIObj:get("SalesEvolution")[nCont]:setprop("Review"						, Rtrim(AIJ->AIJ_REVISA),,.T.)
					ofwEAIObj:get("SalesEvolution")[nCont]:setprop("History"					, Rtrim(AIJ->AIJ_HISTOR),,.T.)
					ofwEAIObj:get("SalesEvolution")[nCont]:setprop("Process"					, Rtrim(AIJ->AIJ_PROVEN),,.T.)
					ofwEAIObj:get("SalesEvolution")[nCont]:setprop("Stage"						, Rtrim(AIJ->AIJ_STAGE),,.T.)
					ofwEAIObj:get("SalesEvolution")[nCont]:setprop("StageDescription"			, Rtrim(cDescStage),,.T.)
					ofwEAIObj:get("SalesEvolution")[nCont]:setprop("StartDate"					, Dtoc(AIJ->AIJ_DTINIC),,.T.)
					ofwEAIObj:get("SalesEvolution")[nCont]:setprop("StartTime"					, AIJ->AIJ_HRINIC,,.T.)
					ofwEAIObj:get("SalesEvolution")[nCont]:setprop("LimitDate"					, Dtoc(AIJ->AIJ_DTENCE),,.T.)
					ofwEAIObj:get("SalesEvolution")[nCont]:setprop("LimitTime"					, Rtrim(AIJ->AIJ_HRENCE),,.T.)
					ofwEAIObj:get("SalesEvolution")[nCont]:setprop("StayTime"					, TKCalcPer(AIJ->AIJ_DTINIC,AIJ->AIJ_HRINIC,dDataBase,SubStr(Time(),1,5)),,.T.)
					ofwEAIObj:get("SalesEvolution")[nCont]:setprop("Status"						, Rtrim(AIJ->AIJ_STATUS),,.T.)

					nCont++
					AIJ->(dbSkip())
				endDo

			Endif

			If ExistBlock("F300OMMS")
				cJson := ExecBlock("F300OMMS",.F.,.F., {cEvent, oModel, ofwEAIObj})
				If ValType( cJson ) == "C" .And. !( Empty( cJson ) )
					ofwEAIObj:loadJson(cJson)
				Endif
			EndIf
		EndIf
    EndIf

    aRet := { lRet, ofwEAIObj, cOwnerMsg }

	oModel := Nil

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} IntOpoInt
Recebe um InternalID e retorna o código da Oportunidade.

@param   cInternalID InternalID recebido na mensagem.
@param   cRefer      Produto que enviou a mensagem
@param   cVersao     Versão da mensagem única (Default 2.000)

@author		TI - Negócios Digitais
@since		30/06/2022
@version	12
@return  aResult Array contendo no primeiro parâmetro uma variável
         lógica indicando se o registro foi encontrado no de/para.
         No segundo parâmetro uma variável array com a empresa,
         filial, o código da oportunidade.

@sample  IntOpoInt('01|01|00001') irá retornar
{.T., {'01', '01', '00001', 'O'}}
/*/
//-------------------------------------------------------------------
Static Function IntOpoInt(cInternalID, cRefer)

   	Local   aResult  := {}
   	Local   aTemp    := {}
   	Local   cTemp    := ''
   	Local   cAlias   := 'AD1'
   	Local   cField   := 'AD1_NROPOR'

	Default cInternalID	:= ''
	Default cRefer		:= ''

	cTemp := CFGA070Int(cRefer, cAlias, cField, cInternalID)

  	If !Empty( cTemp )
		aAdd(aResult, .T.)
	 	aTemp := Separa(cTemp, '|')
	 	aAdd(aResult, {})
	 	aResult[Len(aResult)] := aClone( aTemp )
	Endif

	aSize(aTemp, 0)
	aTemp := {}

Return aResult

//-------------------------------------------------------------------
/*/{Protheus.doc} IntOpoExt
Monta o InternalID da Oportunidade de acordo com o código passado
no parâmetro.

@param   cEmpresa   Código da empresa (Default cEmpAnt)
@param   cFil       Código da Filial (Default cFilAnt)
@param   cOport   	Código da Oportunidade

@author		TI - Negócios Digitais
@since		30/06/2022
@version	12
@return  aResult Array contendo no primeiro parâmetro uma variável
         lógica indicando se o registro foi encontrado.
         No segundo parâmetro uma variável string com o InternalID
         montado.

@sample  IntOpoExt(, , '00001') irá retornar {.T., '01|01|00001|O'}
/*/
//-------------------------------------------------------------------
Static Function IntOpoExt(cEmpresa, cFil, cOport )

   	Local   aResult  := {}

   	Default cEmpresa 	:= cEmpAnt
   	Default cFil     	:= xFilial('AD1')
	Default cOport		:= ""

	aAdd(aResult, .T.)
	aAdd(aResult, cEmpresa + '|' + RTrim(cFil) + '|' + RTrim(cOport) + '|O')

Return aResult


//-------------------------------------------------------------------
/*/{Protheus.doc} ToNumber
Converte valores para numéricos
@param   xVal   Valor a ser convertido

@author		TI - Negócios Digitais
@since		14/07/2022
@version	12
@return  nRet Valor convertido
/*/
//-------------------------------------------------------------------
Static Function ToNumber(xVal)

	Local nRet	:= 0

	If ValType(xVal) == "N"
		nRet := xVal
	Else
		nRet := Val(AllTrim(xVal))
	EndIf

Return nRet

//--------------------------------------------------------------------
/*/{Protheus.doc} GetCurrId
Get Currency ID - Utilizado para identificar se o id da moeda já existe,
antes de acrescentar '0'.

@param   cAux   , Char, Código da Moeda
@param   cMarca , Char, Marca da integração
@param   cMoeVer, Char, Versão do Adapter Currency

@author  Squad CRM/Faturamento
@version P12
@since   19/06/2018
@return  IntMoeInt() função que retorna os dados da moeda.
/*/
//--------------------------------------------------------------------
Static Function GetCurrId(cAux, cMarca, cMoeVer)
   If Empty( CFGA070Int( cMarca, 'CTO', 'CTO_MOEDA', cAux) )
        cAux := SubStr(cAux,1,Len(cAux)-2) + PadL(cAux, 2, "0")
    EndIf
Return IntMoeInt(cAux, cMarca, cMoeVer)
