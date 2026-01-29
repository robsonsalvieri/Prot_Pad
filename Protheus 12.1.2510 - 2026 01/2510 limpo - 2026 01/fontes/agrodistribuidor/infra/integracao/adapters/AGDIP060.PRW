#INCLUDE 'TOTVS.CH'
#INCLUDE 'AGDIP060.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWADAPTEREAI.CH'

#DEFINE MODEL_NAME 'AGDP060'
#DEFINE TABLE_NAME 'NEP'
#DEFINE TCODEPARA_SERVICE agd.TCODeParaService.agdTCODeParaService

/*/{Protheus.doc} AGDIP060
Função de integração com o adapter EAI para envio do cadastro de
Propriedade Rural, utilizando o conceito de mensagem única EAI.
@type function
@version 12
@author jc.maldonado
@since 20/10/2025
@param xEnt, variant, xml/obj para envio/recebimento
@param cTypeTrans, character, '0'=TRANS_SEND, '1'=TRANS_RECEIVE
@param cTypeMessage, character, Tipo Mensagem '20'=DEFINE EAI_MESSAGE_BUSINESS, '21'=DEFINE EAI_MESSAGE_RESPONSE, '22'=DEFINE EAI_MESSAGE_RECEIPT, '23'=DEFINE EAI_MESSAGE_WHOIS
@param cVersion, character, Versao
@param cTransac, character, Nome mensagem unica
@param lEAIObj, logical, EAI Object
@return array, {lResult, xValue(oFWEAIobj ou cMsgErr)}
/*/
Function AGDIP060(xEnt, cTypeTrans, cTypeMessage, cVersion, cTransac, lEAIObj)
	Local aReturn := {.F., Nil}

	If cTypeTrans == TRANS_SEND .And. lEAIObj // Somente Envio, e formato Json
		aReturn := genEAIobj()
		aReturn := {aReturn[1/*lResult*/], aReturn[2/*xValue*/], MODEL_NAME}
	Else
		aReturn[2] := STR0001 // 'Tipo Envio/Formato não suportado.'
	EndIf
Return aReturn

/*/{Protheus.doc} genEAIobj
Gera o objeto FWEAI
@type function
@version 12
@author jc.maldonado
@since 20/10/2025
@return array, {lResultado, xValue(oFWEAIobj ou cMsgErr)}
/*/
Static Function genEAIobj()
	Local oModelAct  := FwModelActive()
	Local aReturn    := {.F., Nil}
	Local cEvent     := 'upsert'
	Local cReferenci := ''
	Local cInternaId := ''
	Local cExternaId := ''
	Local oModelNEP  := Nil
	Local oFWEAIobj  := Nil
	private oTCOSrecei := Nil
	private oTCOService	:= TCODEPARA_SERVICE():new()

	If oModelAct == Nil;
			.Or. ValType(oModelAct) != "O";
			.Or. ! oModelAct:IsActive();
			.Or. oModelAct:GetId() != MODEL_NAME
		aReturn[2] := STR0002 // 'Modelo inválido.'
		Return aReturn
	EndIf

	oTCOSrecei := agdTCOSolicitacaoExternaReceituarioDTO():New()
	cReferenci := oTCOSrecei:getIdentificaoIntegracao()


	oModelNEP  := oModelAct:GetModel('AGDP060_NEP')
	cInternaId := getIDInt(oModelNEP:GetValue('NEP_CODCLI'), oModelNEP:GetValue('NEP_LOJCLI'))
	cExternaId := oTCOService:getExternalID(cReferenci, TABLE_NAME, "NEP_CODCLI", cInternaId) //RTRIM(CFGA070Ext(cReferenci, TABLE_NAME, "NEP_CODCLI", cInternaId))

	If oModelAct:GetOperation() == MODEL_OPERATION_DELETE
		cEvent := 'delete'
		CFGA070Mnt(cReferenci, TABLE_NAME, "NEP_CODCLI",, cInternaId, .T. /*lDelete*/)
	EndIf

	oFWEAIobj := FWEAIobj():NEW()
	oFWEAIobj:Activate()
	oFWEAIobj:setEvent(cEvent)

	oFWEAIobj:setProp("Entity"                , MODEL_NAME                             )
	oFWEAIobj:setProp("Event"                 , cEvent                                 )
	oFWEAIobj:setProp("InternalId"            , cInternaId                             )
	oFWEAIobj:setProp("ExternalId"            , cExternaId                             )
	oFWEAIobj:setProp("CompanyId"             , cEmpAnt                                )
	oFWEAIobj:setProp("BranchId"              , cFilAnt                                )
	oFWEAIobj:setProp("CompanyinternalId"     , cEmpAnt + '|' + cFilAnt                )
	oFWEAIobj:setProp("TotalArea"             , oModelNEP:GetValue('NEP_AREA'  )       )
	oFWEAIobj:setProp("Latitude"              , oModelNEP:GetValue('NEP_LATIT' )       )
	oFWEAIobj:setProp("Longitude"             , oModelNEP:GetValue('NEP_LONGI' )       )
	oFWEAIobj:setProp("CustomerOwnerCode"     , oModelNEP:GetValue('NEP_CLIPRO')       )
	oFWEAIobj:setProp("CustomerOwnerStoreCode", oModelNEP:GetValue('NEP_LOJPRO')       )
	oFWEAIobj:setProp("CARcode"               , RTRIM(oModelNEP:GetValue('NEP_CAR'))   )
	oFWEAIobj:setProp("RuralProperty"         , oModelNEP:GetValue('NEP_PRORUR') == '1')
	oFWEAIobj:setProp("PropertyNumber"        , oModelNEP:GetValue('NEP_NUMERO') 	   )
	if NEP->(FieldPos("NEP_ALTITU")) > 0
		oFWEAIobj:setProp("Altitude"          , oModelNEP:GetValue('NEP_ALTITU' )       )
	endif


	addCustEAI(@oFWEAIobj, 'Customer', oModelNEP:GetValue('NEP_CODCLI'), oModelNEP:GetValue('NEP_LOJCLI'))

	If (!Empty(oModelNEP:GetValue('NEP_CODCLI')))
		addCustEAI(@oFWEAIobj, 'CustomerOwner', oModelNEP:GetValue('NEP_CLIPRO'), oModelNEP:GetValue('NEP_LOJPRO'))
	EndIf

	aReturn[1] := .T.
	aReturn[2] := oFWEAIobj

	FWfreeObj(oTCOSrecei)
	FWfreeObj(oTCOService)
Return aReturn

/*/{Protheus.doc} getIDInt
Obtem o id de integracao a partir do codigo do cliente e da loja
@type function
@version 12
@author jc.maldonado
@since 20/10/2025
@param codCli, character, codigo cliente
@param lojCli, logical, codigo loja
@return character, "cCodEmpresa | cFilial | cCodigoCliente | cCodigoLoja"
/*/
Static Function getIDInt(cCodCli, cLojCli)
Return cEmpAnt + '|' + FWxFilial(TABLE_NAME) + '|' + cCodCli + '|' + cLojCli

/*/{Protheus.doc} addCustEAI
Adiciona propriedade a um objeto FWEAI com informaçoes do cliente (SA1)
@type function
@version 12
@author jc.maldonado
@since 20/10/2025
@param oFWEAIobj, object, @oFWEAI recebido por referencia
@param cPropId, character, nome da propriedade a ser adicionada
@param cCodCli, character, codigo do cliente
@param cLojCli, character, loja do cliente
/*/
Static Function addCustEAI(oFWEAI, cPropId, cCodCli, cLojCli)
	Local aAreaSA1   := {}
	Local cCodEst    := ''
	Local cCodMun    := ''
	Local cEstadoDes := ''
	Local cTelefone  := ''
	Local cLogradour := ''
	Local cNumero    := ''
	Local cComplemen := ''
	Local cExternaId := ''
	Local cClienteId := ''
	Local cReferenci := ''

	dbSelectArea("SA1")
	aAreaSA1 := SA1->(FWGetArea())

	SA1->(dbSetOrder(1))
	SA1->(dbGoTop())
	If SA1->(dbSeek(FWxFilial("SA1") + cCodCli + cLojCli))

		cReferenci := oTCOSrecei:getIdentificaoIntegracao()

		IF cPropId == "CustomerOwner"
			cClienteId := oTCOService:formatInternalIDcliente(NIL, NIL, cCodCli, cLojCli)
			cExternaId := oTCOService:getExternalID(cReferenci, "SA1", "A1_COD", cClienteId)
		Else
			cClienteId := getIDInt(cCodCli, cLojCli)
			cExternaId := oTCOService:getExternalID(cReferenci, TABLE_NAME, "NEP_CODCLI", cClienteId)
		ENDIF

		If cPaisLoc $ "BRA"
			cCodEst := Tms120CdUf(SA1->A1_EST, '1') // Retorna o codigo do estado a partir da sigla
		EndIf

		If ! Empty(SA1->A1_COD_MUN) // Envio do codigo de acordo com padrao IBGE (cod. estado + cod. municipio)
			cCodMun := Rtrim(cCodEst) + Rtrim(SA1->A1_COD_MUN)
		Endif

		If ! Empty(SA1->A1_EST)
			cEstadoDes := Rtrim(Posicione("SX5",1, FWxFilial("SX5") + "12" + SA1->A1_EST, "X5DESCRI()"))
		EndIf

		cTelefone  := AllTrim(SA1->A1_DDI) + AllTrim(SA1->A1_DDD) + AllTrim(SA1->A1_TEL)
		cLogradour := Rtrim(trataEnd(SA1->A1_END, "L"))
		cNumero    := Rtrim(trataEnd(SA1->A1_END, "N"))
		cComplemen := Iif(Empty(SA1->A1_COMPLEM), _NoTags(trataEnd(SA1->A1_END,"C")), _NoTags(Rtrim(SA1->A1_COMPLEM)))

		oFWEAI:setProp(cPropId)

		oFWEAI:get(cPropId):setProp("InternalId" 	   , cClienteId           )
		oFWEAI:get(cPropId):setProp("ExternalId" 	   , cExternaId			  )
		oFWEAI:get(cPropId):setProp("CustomerCode"	   , cCodCli              )
		oFWEAI:get(cPropId):setProp("CustomerStore"    , cLojCli              )
		oFWEAI:get(cPropId):setProp("Name"             , RTRIM(SA1->A1_NOME)  )
		oFWEAI:get(cPropId):setProp("CPFCNPJ"          , Rtrim(SA1->A1_CGC)   )
		oFWEAI:get(cPropId):setProp("PhoneNumber"      , cTelefone            )
		oFWEAI:get(cPropId):setProp("StateRegistration", Rtrim(SA1->A1_INSCR) )
		oFWEAI:get(cPropId):setProp("IBGEcityCode"     , cCodMun              )
		oFWEAI:get(cPropId):setProp("CityDescription"  , Rtrim(SA1->A1_MUN)   )
		oFWEAI:get(cPropId):setProp("ZipCode"          , Rtrim(SA1->A1_CEP)   )
		oFWEAI:get(cPropId):setProp("StateCode"        , SA1->A1_EST          )
		oFWEAI:get(cPropId):setProp("StateDescription" , cEstadoDes           )
		oFWEAI:get(cPropId):setProp("Address"          , cLogradour           )
		oFWEAI:get(cPropId):setProp("Number"           , cNumero              )
		oFWEAI:get(cPropId):setProp("Complement"       , cComplemen           )
		oFWEAI:get(cPropId):setProp("District"         , Rtrim(SA1->A1_BAIRRO))
		oFWEAI:get(cPropId):setProp("emailAddress"     , Rtrim(SA1->A1_EMAIL) )
	EndIf

	FWrestArea(aAreaSA1)
Return
