#Include "AGDIP110.ch"
#Include 'TOTVS.ch'
#Include 'fwAdapterEAI.ch'
#Include 'FWMVCDEF.CH'

#DEFINE TCODEPARA_SERVICE totvs.protheus.agrobusiness.agd.TCOFromtoService
#DEFINE TCOTBDC_DTO totvs.protheus.agrobusiness.agd.TCOTBDCDTO

/*/{Protheus.doc} AGDIP110
Rotina para Interpretação/Geração Mensagem de Tabela de Preço (NE8) - Extensão
@type function
@version 12
@author lindembergson.pacheco
@since 24/03/2026
@param xEnt, variant, Obejto Recebido
@param nTypeTrans, numeric, Recebimento/Envio
@param cTypeMessage, character, Tipo Mensagem
@param cVersion, character, Versão
@param cTransac, character, Tipo Transação
@param lEAIObj, logical, Formato JSON
@return variant, retorno array Padrao
/*/
Function AGDIP110(xEnt,nTypeTrans,cTypeMessage, cVersion, cTransac, lEAIObj )
	Local lRet     := .T.
	Local aRet     := { .T., "" }
	Local aAux     := { .F., "" }

	If !lEAIObj
		If nTypeTrans == TRANS_RECEIVE

			If cTypeMessage == EAI_MESSAGE_WHOIS
				aAux := { lRet , "1.000"  }
			else
				lRet     := .F.
				aAux := { lRet , 	STR0001 } //"Mensagem Não Implementada"
			EndIf

			aRet := { aAux[ 1 ] , aAux[ 2 ], 'AGDP110' }

		ElseIf nTypeTrans == TRANS_SEND

			lRet     := .F.
			aAux := { lRet , 	STR0002 } //"Mensagem Não Implementada para XML"
			aRet := { aAux[ 1 ] , aAux[ 2 ], 'AGDP110' }

		EndIf

	Else
		//FORMATO JSON
		If nTypeTrans == TRANS_RECEIVE
			If cTypeMessage == EAI_MESSAGE_WHOIS
				aAux := { lRet , "1.000"  }
			else
				lRet     := .F.
				aAux := { lRet , 	STR0001 } //'Mensagem Não Implementada'
			EndIf

			aRet := { aAux[ 1 ] , aAux[ 2 ], 'AGDP110' }

		ElseIf nTypeTrans == TRANS_SEND

			aAux := V1000JSEND()

			aRet := { aAux[ 1 ] , aAux[ 2 ], 'AGDP110' }

		EndIf
	EndIf

Return aRet

/*/{Protheus.doc} V1000JSEND
Envio da Mensagem em JSON
@type function
@version 12
@author lindembergson.pacheco
@since 24/03/2026
@return variant, array 
/*/
Static Function V1000JSEND()
	Local ofwEAIObj			:= FWEAIobj():NEW()
	Local cEntity			:= "AGDP110"
	Local cEvent			:= ""
	Local oModel			:= FWMODELACTIVE()
	Local oNE8				:= oModel:GetModel('AGDP110_NE8')
	Local aRet				:= {}
	Local oTCOService		:= TCODEPARA_SERVICE():new()
	Local cDataDe			:= ""
	Local cDataAte			:= ""
	Local cValidade			:= ""
	Local cPagamento		:= ""
	Local cProductId		:= ""
	Local cItemTableId		:= ""
	Local cInternalId		:= oTCOService:formatInternalIdTabelaPreco(oNE8:GetValue('NE8_CODTAB'))
	Local nX				:= 0

	//Verifica operação realizada
	Do Case
	Case oModel:nOperation == MODEL_OPERATION_INSERT
		cEvent := 'upsert' //Inclusão
	Case oModel:nOperation == MODEL_OPERATION_UPDATE
		cEvent := 'upsert' //Alteração
	Case oModel:nOperation == MODEL_OPERATION_DELETE
		cEvent := 'delete' //Exclusao
		CFGA070Mnt(,"DA0","DA0_CODTAB",, cInternalId ,.T.)
	EndCase

	dbSelectArea("DA0")
	DA0->(dbSetOrder(1)) //DA0_FILIAL+DA0_CODTAB
	If DA0->(dbSeek(FWxFilial("DA0") + oNE8:GetValue('NE8_CODTAB') ))
	
		cDataDe 	:= getFormatData(DA0->DA0_DATDE)
		cDataAte 	:= getFormatData(DA0->DA0_DATATE)
		cPagamento 	:= getFormatData(oNE8:GetValue('NE8_PRAPAG'))

		ofwEAIObj:Activate()
		ofwEAIObj:setEvent(cEvent)

		ofwEAIObj:setProp("Entity"					,cEntity)
		ofwEAIObj:setProp("Event"					,cEvent)
		ofwEAIObj:setProp("InternalId"				,cInternalId )
		ofwEAIObj:setProp("ExternalId"				,getIDExt("DA0", "DA0_CODTAB",cInternalId)  )
		ofwEAIObj:setProp("CompanyId"				,cEmpAnt)
		ofwEAIObj:setProp("BranchId"				,cFilAnt)
		ofwEAIObj:setProp("CompanyInternalID"		,cEmpAnt + '|' + cFilAnt )
		//DADOS DA0
		ofwEAIObj:setProp("Code"					,alltrim(oNE8:GetValue('NE8_CODTAB')))
		ofwEAIObj:setProp("Name"					,alltrim(DA0->DA0_DESCRI))
		ofwEAIObj:setProp("InitialDate"				, cDataDe )
		ofwEAIObj:setProp("InitialHour"				, alltrim(DA0->DA0_HORADE) )
		ofwEAIObj:setProp("FinalDate"				, cDataAte )
		ofwEAIObj:setProp("FinalHour"				, alltrim(DA0->DA0_HORATE) )
		ofwEAIObj:setProp("ActiveTablePrice"		,alltrim(DA0->DA0_ATIVO) )
		ofwEAIObj:setProp("Branch"					,alltrim(DA0->DA0_FILIAL) )
		//DADOS NE8
		ofwEAIObj:setProp("InterestCalculationType"	,alltrim(oNE8:GetValue('NE8_CALJUR')) )
		ofwEAIObj:setProp("PaymentDueDate"			,cPagamento)

		//DADOS DA1
		dbSelectArea('DA1')
		DA1->(dbSetOrder(3)) // DA1_FILIAL+DA1_CODTAB+DA1_ITEM

		If DA1->(dbSeek(xFilial('DA1') + oNE8:GetValue('NE8_CODTAB')))

			ofwEAIObj:setprop("ItensTablePrice")

			While  DA1->(!EoF()) .And. ;
					DA1->(DA1_FILIAL+DA1_CODTAB) == DA0->(DA0_FILIAL + DA0_CODTAB)
				nX++

				cValidade 		:= getFormatData(DA1->DA1_DATVIG)
				cItemTableId	:= oTCOService:formatInternalIdItemTabelaPreco(oNE8:GetValue('NE8_CODTAB'),  DA1->DA1_CODPRO)
				cProductId		:= oTCOService:formatInternalIdProduto(nil, nil, DA1->DA1_CODPRO)

				ofwEAIObj:getPropValue("ItensTablePrice"):setProp("Item",{})

				ofwEAIObj:getPropValue("ItensTablePrice"):getPropValue("Item")[nX]:setProp("ItemCode", 						alltrim(DA1->DA1_CODPRO))
				ofwEAIObj:getPropValue("ItensTablePrice"):getPropValue("Item")[nX]:setProp("ItemTableInternalId",			cItemTableId)
				ofwEAIObj:getPropValue("ItensTablePrice"):getPropValue("Item")[nX]:setProp("ItemTableExternalId",			getIDExt("DA1", "DA1_CODTAB", cItemTableId)  )
				ofwEAIObj:getPropValue("ItensTablePrice"):getPropValue("Item")[nX]:setProp("ItemInternalId",				cProductId)
				ofwEAIObj:getPropValue("ItensTablePrice"):getPropValue("Item")[nX]:setProp("ItemExternalId",				getIDExt("SB1", "B5_COD", cProductId)  )
				ofwEAIObj:getPropValue("ItensTablePrice"):getPropValue("Item")[nX]:setProp("ProductComplementExternalId",	getIDExt("SB5", "B5_COD", cProductId)  )
				ofwEAIObj:getPropValue("ItensTablePrice"):getPropValue("Item")[nX]:setProp("MinimumSalesPrice", 			DA1->DA1_PRCVEN)
				ofwEAIObj:getPropValue("ItensTablePrice"):getPropValue("Item")[nX]:setProp("DiscountValue", 				DA1->DA1_VLRDES)
				ofwEAIObj:getPropValue("ItensTablePrice"):getPropValue("Item")[nX]:setProp("DiscountFactor", 				DA1->DA1_PERDES)
				ofwEAIObj:getPropValue("ItensTablePrice"):getPropValue("Item")[nX]:setProp("ActiveItemPrice", 				DA1->DA1_ATIVO)
				ofwEAIObj:getPropValue("ItensTablePrice"):getPropValue("Item")[nX]:setProp("Currency", 						DA1->DA1_MOEDA)
				ofwEAIObj:getPropValue("ItensTablePrice"):getPropValue("Item")[nX]:setProp("ItemValidity", 					cValidade)

				DA1->(dbSkip())
			EndDo

		EndIf

	endif

	aAdd(aRet, .T.)
	aAdd(aRet, ofwEAIObj)

Return aRet


/*/{Protheus.doc} getIDExt
Retorna o Codigo Externo Conforme DE-PARA padrao
@type function
@version 12
@author lindembergson.pacheco
@since 24/03/2026
@param codigo, character, codigo
@return variant, id
/*/
Static Function getIDExt(cAlias, cField, cIdInter)
	Local ofeatureDTO  := TCOTBDC_DTO():new()
	Local cCodeInteg   := ofeatureDTO:getIdentificaoIntegracao()
	Local oTCOService	:= TCODEPARA_SERVICE():new()
return oTCOService:getExternalID(cCodeInteg, cAlias, cField, cIdInter)

/*/{Protheus.doc} getFormatData
Retorna a data formatada com 4 digitos no ano (ignorado o conteudo da funcao __SetCentury)
@type function
@version 12
@author jean.schulze
@since 19/05/2026
@param dData, date, data a ser formatada
@return variant, data formatada
/*/
Static Function getFormatData(dData)
return Day2Str(dData)+ '/' + Month2Str(dData)+ '/' +Year2Str(dData)
