#Include "agdip010.ch"
#Include 'TOTVS.ch'
#Include 'fwAdapterEAI.ch'
#Include 'FWMVCDEF.CH'


/*/{Protheus.doc} AGDIP010
Rotina para Interpretação/Geração Mensagem do Descarte de Embalagem
@type function
@version 12
@author jean.schulze
@since 15/10/2025
@param xEnt, variant, Obejto Recebido
@param nTypeTrans, numeric, Recebimento/Envio
@param cTypeMessage, character, Tipo Mensagem
@param cVersion, character, Versão
@param cTransac, character, Tipo Transação
@param lEAIObj, logical, Formato JSON
@return variant, retorno array Padrao
/*/
Function AGDIP010(xEnt,nTypeTrans,cTypeMessage, cVersion, cTransac, lEAIObj )
	Local lRet     := .T.
	Local aRet     := { .T., "" }
	Local aAux     := { .F., "" }

	If !lEAIObj
		If nTypeTrans == TRANS_RECEIVE

			If cTypeMessage == EAI_MESSAGE_WHOIS
				aAux := { lRet , "1.000"  }
			else
				lRet     := .F.
				aAux := { lRet , 	STR0001 } //'Mensagem Não Implementada'
			EndIf

			aRet := { aAux[ 1 ] , aAux[ 2 ], 'AGDP010' }

		ElseIf nTypeTrans == TRANS_SEND

			lRet     := .F.
			aAux := { lRet , 	STR0002 } //'Mensagem Não Implementada para XML'
			aRet := { aAux[ 1 ] , aAux[ 2 ], 'AGDP010' }

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

			aRet := { aAux[ 1 ] , aAux[ 2 ], 'AGDP010' }

		ElseIf nTypeTrans == TRANS_SEND

			aAux := V1000JSEND()

			aRet := { aAux[ 1 ] , aAux[ 2 ], 'AGDP010' }

		EndIf
	EndIf

Return aRet

/*/{Protheus.doc} V1000JSEND
Envio da Mensagem em JSON
@type function
@version 12
@author jean.schulze
@since 15/10/2025
@return variant, array 
/*/
Static Function V1000JSEND()
	Local ofwEAIObj     := FWEAIobj():NEW()
	Local cEntity       := "AGDP010"
	Local cEvent        := ""
	Local oModel        := FWMODELACTIVE()
	Local oModelNEO     := oModel:GetModel('AGDP010_NEO')
	Local aRet			:= {}

	//Verifica operação realizada
	Do Case
	Case oModel:nOperation == MODEL_OPERATION_INSERT
		cEvent := 'upsert' //Inclusão
	Case oModel:nOperation == MODEL_OPERATION_UPDATE
		cEvent := 'upsert' //Alteração
	Case oModel:nOperation == MODEL_OPERATION_DELETE
		cEvent := 'delete' //Exclusao
		CFGA070Mnt(,"NEO","NEO_CODIGO",,getIDInt(oModelNEO:GetValue('NEO_CODIGO')),.T.)
	EndCase

	ofwEAIObj:Activate()
	ofwEAIObj:setEvent(cEvent)

	ofwEAIObj:setProp("Entity"            ,cEntity)
	ofwEAIObj:setProp("Event"             ,cEvent)
	ofwEAIObj:setProp("InternalId"        ,getIDInt(oModelNEO:GetValue('NEO_CODIGO'))  )
	ofwEAIObj:setProp("ExternalId"        ,getIDExt(oModelNEO:GetValue('NEO_CODIGO'))  )
	ofwEAIObj:setProp("CompanyId"         ,cEmpAnt)
	ofwEAIObj:setProp("BranchId"          ,cFilAnt)
	ofwEAIObj:setProp("CompanyinternalId" ,cEmpAnt + '|' + cFilAnt )
	ofwEAIObj:setProp("Code"			  ,RTrim(oModelNEO:GetValue('NEO_CODIGO')) )
	ofwEAIObj:setProp("Name"		      ,_NoTags(RTrim(oModelNEO:GetValue('NEO_NOME'))) )
	ofwEAIObj:setProp("Date"	          ,oModelNEO:GetValue('NEO_DATA'))
	ofwEAIObj:setProp("CPFCNPJCode"		  ,RTrim(oModelNEO:GetValue('NEO_CPFCGC')))
	ofwEAIObj:setProp("State"	          ,RTrim(oModelNEO:GetValue('NEO_EST')))
	ofwEAIObj:setProp("CityCode"		  ,RTrim(oModelNEO:GetValue('NEO_CODMUN')))
	ofwEAIObj:setProp("CityDescription"	  ,RTrim(oModelNEO:GetValue('NEO_DESMUN')))
	ofwEAIObj:setProp("Neighborhood"	  ,RTrim(oModelNEO:GetValue('NEO_BAIRRO')))
	ofwEAIObj:setProp("Address"			  ,RTrim(oModelNEO:GetValue('NEO_ENDERE')))
	ofwEAIObj:setProp("AddressNumber"	  ,oModelNEO:GetValue('NEO_NUMERO'))
	ofwEAIObj:setProp("ZipCode"			  ,oModelNEO:GetValue('NEO_CEP'))
	ofwEAIObj:setProp("DDDCode"	          ,oModelNEO:GetValue('NEO_DDD'))
	ofwEAIObj:setProp("Phone"			  ,oModelNEO:GetValue('NEO_TEL'))
	ofwEAIObj:setProp("Cellphone"	      ,oModelNEO:GetValue('NEO_CEL'))
	ofwEAIObj:setProp("StateRegistration" ,RTrim(oModelNEO:GetValue('NEO_INSEST')))
	ofwEAIObj:setProp("AddressComplement" ,RTrim(oModelNEO:GetValue('NEO_COMPL')))
	ofwEAIObj:setProp("Blocked"			  ,oModelNEO:GetValue('NEO_BLOQUE'))
	ofwEAIObj:setProp("Default"	          ,oModelNEO:GetValue('NEO_PADRAO'))

	aAdd(aRet, .T.)
	aAdd(aRet, ofwEAIObj)

Return aRet

/*/{Protheus.doc} getIDInt
Retorna o Codigo Interno
@type function
@version 12
@author jean.schulze
@since 15/10/2025
@param codigo, character, codigo
@return variant, id
/*/
Static Function getIDInt(codigo)
	Local cEmpresa := cEmpAnt
	Local cFil     := xFilial('NEO')
return cEmpresa + '|' + cFil + '|' + codigo

/*/{Protheus.doc} getIDExt
Retorna o Codigo Externo Conforme DE-PARA padrao
@type function
@version 12
@author jean.schulze
@since 15/10/2025
@param codigo, character, codigo
@return variant, id
/*/
Static Function getIDExt(codigo)
	Local ofeatureDTO  := agdTCOSolicitacaoExternaReceituarioDTO():new()
	Local cCodeInteg   := ofeatureDTO:getIdentificaoIntegracao()
	Local cIdInter     := getIDInt(codigo)
return CFGA070Ext(cCodeInteg, "NEO", "NEO_CODIGO", cIdInter)

