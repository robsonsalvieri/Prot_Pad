#Include "AGDIA040.ch"
#Include 'TOTVS.ch'
#Include 'fwAdapterEAI.ch'
#Include 'FWMVCDEF.CH'

#DEFINE TCODEPARA_SERVICE agd.TCODeParaService.agdTCODeParaService
#DEFINE SOLICITACAO_RECEITA_REPOSITORY agd.solicitacaoReceitaRepository.agdSolicitacaoReceitaRepository

/*/{Protheus.doc} AGDIA040
Rotina para Interpretação/Geração Mensagem do Descarte de Embalagem
@type function
@version 12
@author lindembergson.pacheco
@since 19/11/2025
@param xEnt, variant, Obejto Recebido
@param nTypeTrans, numeric, Recebimento/Envio
@param cTypeMessage, character, Tipo Mensagem
@param cVersion, character, Versão
@param cTransac, character, Tipo Transação
@param lEAIObj, logical, Formato JSON
@return variant, retorno array Padrao
/*/
Function AGDIA040(xEnt,nTypeTrans,cTypeMessage, cVersion, cTransac, lEAIObj )
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

			aRet := { aAux[ 1 ] , aAux[ 2 ], 'AGDA040' }

		ElseIf nTypeTrans == TRANS_SEND

			lRet     := .F.
			aAux := { lRet , 	STR0002 } //"Mensagem Não Implementada para XML"
			aRet := { aAux[ 1 ] , aAux[ 2 ], 'AGDA040' }

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

			aRet := { aAux[ 1 ] , aAux[ 2 ], 'AGDA040' }

		ElseIf nTypeTrans == TRANS_SEND

			aAux := V1000JSEND()

			aRet := { aAux[ 1 ] , aAux[ 2 ], 'AGDA040' }

		EndIf
	EndIf

Return aRet

/*/{Protheus.doc} V1000JSEND
Envio da Mensagem em JSON
@type function
@version 12
@author lindembergson.pacheco
@since 19/11/2025
@return variant, array 
/*/
Static Function V1000JSEND()
	Local ofwEAIObj     := FWEAIobj():NEW()
	Local cEntity       := "AGDA040"
	Local cEvent        := ""
	Local oModel        := FWMODELACTIVE()
	Local oNET			:= oModel:GetModel('AGDA040_NET')
	Local oNEU     		:= oModel:GetModel('AGDA040_NEU')
	Local aRet			:= {}
	Local oTCOService	:= TCODEPARA_SERVICE():new()
	Local cEmissao		:= ""
	Local cInternalId	:= oTCOService:formatInternalIdSolReceita(oNET:GetValue('NET_CODIGO')) //setInternalID({cEmpAnt, xFilial('NET'), oNET:GetValue('NET_CODIGO') })
	Local cClienteId	:= ""
	Local cPropertyId	:= oTCOService:formatInternalIdPropriedade(oNET:GetValue('NET_CLIENT'), oNET:GetValue('NET_LOJA')) //setInternalID({cEmpAnt, xFilial('NEP'), oNET:GetValue('NET_CLIENT'), oNET:GetValue('NET_LOJA')})
	Local cCulturaId	:= oTCOService:formatInternalIdCultura(oNET:GetValue('NET_CULTRA'))//setInternalID({cEmpAnt, xFilial('NP3'), oNET:GetValue('NET_CULTRA') })
	Local cRespTecId	:= oTCOService:formatInternalIdRespTecnico(oNET:GetValue('NET_CODENG'))//setInternalID({cEmpAnt, xFilial('NP8'), oNET:GetValue('NET_CODENG') })
	Local cDescarteId	:= oTCOService:formatInternalIdDescarte(oNET:GetValue('NET_LOCDES'))//setInternalID({cEmpAnt, xFilial('NEO'), oNET:GetValue('NET_LOCDES') })
	Local cProductId	:= ""
	Local cUF			:= ""
	Local nX			:= 0
	Local oRepository 	:= SOLICITACAO_RECEITA_REPOSITORY():New()
	Local aProdutos		:= {}
	Local aMapas		:= {}

	//Verifica operação realizada
	Do Case
	Case oModel:nOperation == MODEL_OPERATION_INSERT
		cEvent := 'upsert' //Inclusão
	Case oModel:nOperation == MODEL_OPERATION_UPDATE
		cEvent := 'upsert' //Alteração
	Case oModel:nOperation == MODEL_OPERATION_DELETE
		cEvent := 'delete' //Exclusao
		CFGA070Mnt(,"NET","NET_CODIGO",, cInternalId ,.T.)
	EndCase

	cEmissao := FsDateConv(oNET:GetValue('NET_EMISSA'),"YYYYMMDD")
	cEmissao := SubStr(cEmissao,1,4)+"-"+SubStr(cEmissao,5,2)+"-"+SubStr(cEmissao,7)

	dbSelectArea("SA1")
	SA1->(dbSetOrder(1))
	If SA1->(dbSeek(FWxFilial("SA1") + oNET:GetValue('NET_CLIENT') + oNET:GetValue('NET_LOJA')))
		cUF := SA1->A1_EST
	endif
	//BUSCAND CLIENTE RELACIONADO A PROPRIEDADE
	dbSelectArea("NEP")
	NEP->(dbSetOrder(1))
	If NEP->(dbSeek(FWxFilial("NEP") + oNET:GetValue('NET_CLIENT') + oNET:GetValue('NET_LOJA')))
		cClienteId	:= oTCOService:formatInternalIDcliente(NIL, NIL, NEP->NEP_CLIPRO, NEP->NEP_LOJPRO)
	endif

	ofwEAIObj:Activate()
	ofwEAIObj:setEvent(cEvent)

	ofwEAIObj:setProp("Entity"				,cEntity)
	ofwEAIObj:setProp("Event"				,cEvent)
	ofwEAIObj:setProp("InternalId"			,cInternalId )
	ofwEAIObj:setProp("ExternalId"			,getIDExt("NET", "NET_CODIGO",cInternalId)  )
	ofwEAIObj:setProp("CompanyId"			,cEmpAnt)
	ofwEAIObj:setProp("BranchId"			,cFilAnt)
	ofwEAIObj:setProp("CompanyinternalId"	,cEmpAnt + '|' + cFilAnt )
	ofwEAIObj:setProp("RequestId"			,alltrim(oNET:GetValue('NET_CODIGO')) )
	ofwEAIObj:setProp("OrderId"				,alltrim(oNET:GetValue('NET_NUMPED')) )
	ofwEAIObj:setProp("IssueDate"			, cEmissao )
	ofwEAIObj:setProp("StatusRequest"		,alltrim(oNET:GetValue('NET_STSSOL')) )
	ofwEAIObj:setProp("StatusRevenue"		,alltrim(oNET:GetValue('NET_STSREC')) )
	ofwEAIObj:setProp("CustomerId"			,getIDExt("SA1", "A1_COD"		,cClienteId) )
	ofwEAIObj:setProp("PropertyId"			,getIDExt("NEP", "NEP_CODCLI"	,cPropertyId) )
	ofwEAIObj:setProp("StateCode"			,cUF )
	For nX := 1 To oNEU:Length()
		oNEU:GoLine(nX)
		If !oNEU:IsDeleted(nX)
			cProductId	:= oTCOService:formatInternalIdProduto(nil, nil, oNEU:GetValue("NEU_PRODUT"))

			aAdd(aProdutos,{ oNEU:GetValue("NEU_PRODUT"), oNEU:GetValue("NEU_QTDVEN"),  oNEU:GetValue("NEU_UM"), getIDExt("SB1", "B1_COD",cProductId)})
		EndIf
	Next
	ofwEAIObj:setProp("CultureId"			,getIDExt("NP3", "NP3_CODIGO"	,cCulturaId) )
	ofwEAIObj:setProp("TechnicalManagerId"	,getIDExt("NP8", "NP8_CODIGO"	,cRespTecId) )
	ofwEAIObj:setProp("LocalReturnId"		,getIDExt("NEO", "NEO_CODIGO"	,cDescarteId) )

	aMapas := oRepository:groupByMapa(aProdutos)

	for nX := 1 to Len(aMapas)
		ofwEAIObj:setprop('Products',{},'Product',,.T.)
		ofwEAIObj:getPropValue("Products")[nX]:setProp("ProductId", 		aMapas[nX][1])
		ofwEAIObj:getPropValue("Products")[nX]:setProp("ProductMapping", 	aMapas[nX][2])
		ofwEAIObj:getPropValue("Products")[nX]:setProp("Quantity", 			aMapas[nX][3])
		ofwEAIObj:getPropValue("Products")[nX]:setProp("UnitMeasurement", 	aMapas[nX][4])
		ofwEAIObj:getPropValue("Products")[nX]:setProp("Data", 				aMapas[nX][5])
	next nY


	aAdd(aRet, .T.)
	aAdd(aRet, ofwEAIObj)

Return aRet


/*/{Protheus.doc} getIDExt
Retorna o Codigo Externo Conforme DE-PARA padrao
@type function
@version 12
@author lindembergson.pacheco
@since 19/11/2025
@param codigo, character, codigo
@return variant, id
/*/
Static Function getIDExt(cAlias, cField, cIdInter)
	Local ofeatureDTO  := agdTCOSolicitacaoExternaReceituarioDTO():new()
	Local cCodeInteg   := ofeatureDTO:getIdentificaoIntegracao()
	Local oTCOService	:= TCODEPARA_SERVICE():new()
return oTCOService:getExternalID(cCodeInteg, cAlias, cField, cIdInter)

