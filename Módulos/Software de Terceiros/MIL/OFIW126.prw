#include 'totvs.ch'
#include 'restful.ch'
#include 'TopConn.ch'
#include 'ofiw126.ch'

/*/{Protheus.doc} OFIW126
	WebService para api do processo de aprovações de credito - AprovaMil
	@author Renan Migliaris
	@since 09/04/2025
	/*/
WSRESTFUL ofixa016_019_api DESCRIPTION STR0001 //Api das aprovacoes do processo de credito OFIXA016 e OFIXA019
	WSDATA id as string
	WSDATA code as string
	WSDATA pageSize as character
	WSDATA page as character
	WSDATA search as string
	WSDATA filter as string
	WSDATA numOrc as string
	WSDATA datHor as string
	WSDATA filial as string
	WSDATA codMot as string

	WSMETHOD GET VS1FORM DESCRIPTION STR0002 WSSYNTAX "/ofixa016_019_api/vs1form" PATH "/ofixa016_019_api/vs1form" //Retorna metadados VS1
	WSMETHOD GET VS3FORM DESCRIPTION STR0003 WSSYNTAX "/ofixa016_019_api/vs3form" PATH "/ofixa016_019_api/vs3form" //Retorna metadados VS3
	WSMETHOD GET VSWFORM DESCRIPTION STR0004 WSSYNTAX "/ofixa016_019_api/vswform" PATH "/ofixa016_019_api/vswform" //Retorna metadados VSW
	WSMETHOD GET VO3FORM DESCRIPTION STR0005 WSSYNTAX "/ofixa016_019_api/vo3form" PATH "/ofixa016_019_api/vo3form" //Retorna metadados VO3
	WSMETHOD GET VO4FORM DESCRIPTION STR0006 WSSYNTAX "/ofixa016_019_api/vo4form" PATH "/ofixa016_019_api/vo4form" //Retorna metadados VO4
	WSMETHOD GET FORMMOT DESCRIPTION STR0007 WSSYNTAX "/ofixa016_019_api/formmot" PATH "/ofixa016_019_api/formmot" //Retorna form de motivos
	WSMETHOD GET APRCRED DESCRIPTION STR0008 WSSYNTAX "/ofixa016_019_api/aprcred" PATH "/ofixa016_019_api/aprcred" //Retorna aprovacoes de credito pendentes
	WSMETHOD GET APRITENS DESCRIPTION STR0009 WSSYNTAX "/ofixa016_019_api/apritens" PATH "/ofixa016_019_api/apritens" //Retorna os itens da aprovacao
	WSMETHOD GET APRCRD19 DESCRIPTION STR0010 WSSYNTAX "/ofixa016_019_api/aprcrd19" PATH "/ofixa016_019_api/aprcrd19" //Retorna as aprovações ofixa019
	WSMETHOD GET GETVO3 DESCRIPTION STR0011 WSSYNTAX "/ofixa016_019_api/getvo3" PATH "/ofixa016_019_api/getvo3" //Retorna as peças da aprovacao ofixa019
	WSMETHOD GET GETVO4 DESCRIPTION STR0012 WSSYNTAX "/ofixa016_019_api/getvo4" PATH "/ofixa016_019_api/getvo4" //Retorna as serviços da aprovacao ofixa019
	WSMETHOD PUT PUTCRD19 DESCRIPTION STR0013 WSSYNTAX "/ofixa016_019_api/putcrd19" PATH "/ofixa016_019_api/putcrd19" //Realiza a aprovacao de credito ofixa019
	WSMETHOD PUT REABREORC DESCRIPTION STR0014 WSSYNTAX '/ofixa016_019_api/reabreorc' PATH '/ofixa016_019_api/reabreorc' //Realiza a reabertura de orçamento OFIXA016
	WSMETHOD PUT APRCRED DESCRIPTION STR0015 WSSYNTAX '/ofixa016_019_api/aprcred' PATH '/ofixa016_019_api/aprcred' //Realiza aprovação do credito
	WSMETHOD GET REABREMOTS DESCRIPTION 'Traz os formulários de motivos' WSSYNTAX '/ofixa016_019_api/reabremot' PATH '/ofixa016_019_api/reabremot' 
	WSMETHOD GET MOTREJECT DESCRIPTION 'Traz os motivos para reabuertura' WSSYNTAX '/ofixa016_019_api/motreject' PATH '/ofixa016_019_api/motreject' 
END WSRESTFUL

WSMETHOD GET MOTREJECT WSRECEIVE filial, numOrc WSSERVICE ofixa016_019_api
	local lRet := .t.
	local aMotCancel := {}
	local aMot := {}
	local i := 0
	local oResp := JsonObject():new()

	::SetContentType("application/json; charset=utf-8")
	aMotCancel := OFA210MOT("000012", "4", self:filial, self:numOrc, .t.) //código do motivo retirado da rotina original

	if len(aMotCancel) == 0
		oResp["items"] := {}
		oResp["hasNext"] := .f.
		
		::setStatus(200)
		::setResponse(encodeUTF8(oResp:toJson()))
		freeobj(oResp)
		return lRet
	endif

	for i := 1 to len(aMotCancel)
		aadd(aMot, aMotCancel[i])
	next

	oResp["items"] := aMot
	oResp["hasNext"] := .f.

	::setStatus(200)
	::setResponse(encodeUTF8(oResp:toJson()))
	freeobj(oResp)
return lRet

WSMETHOD GET REABREMOTS WSRECEIVE codMot WSSERVICE ofixa016_019_api
	local lRet := .t.
	local cMotivo := '000012' //filtro consulta do motivo que está sendo chamado na rotina original
	local oMessages := nil
	local oFormBuilder := VEFormBuilder():new()

	if empty(self:codMot)
		oMessages := OFIMensagensPadrao():new()
		SetRestFault(400, oMessages:ERR_ID_NAO_INFORMADO)
		return .f.
	endif

	::SetContentType("application/json; charset=utf-8")
	::SetStatus(200)
	::SetResponse(encodeUTF8(oFormBuilder:getFromVds(cMotivo, self:codMot)))
return lRet

/*/{Protheus.doc} OFIW126 VSWFORM
	Retorna o metadado do VSW
	@author Renan Migliaris
	@since 09/04/2025
	@version version
/*/
WSMETHOD GET VSWFORM WSSERVICE ofixa016_019_api
	local lRet := .t.
	local oBuilder := VEFormBuilder():new()
	local aCampos := { "VSW_NUMORC", "VSW_TIPTEM", "VSW_LOJA", "VSW_USUARI",;
					"VSW_VALCRE", "VSW_DATHOR", "VSW_DTHLIB", "VSW_MOTIVO",;
					"VSW_NUMATE", "VSW_RISANT", "VSW_LCANT", "VSW_NOMCLI", "VSW_LIBVOO"}
	
	::SetContentType("application/json; charset=utf-8")
	::setStatus(200)
	::setResponse(oBuilder:getFromSx3(aCampos))
	freeobj(oBuilder)
return lRet 

/*/{Protheus.doc} OFIW126 VS1FORM
	Retorna o metadado do VS1
	@author Renan Migliaris
	@since 09/04/2025
	@version version
/*/
WSMETHOD GET VS1FORM WSSERVICE ofixa016_019_api
	local lRet := .t.
	local oBuilder := VEFormBuilder():new()
	// local aPeCamp := {}
	local aCampos := { "VS1_FILIAL", "VS1_NUMORC", "VS1_DTPORC", "VS1_DTPSTP",; 
					"VS1_NCLIFT", "VS1_LOJA", "VS1_DATALT", "A3_NOME", "VS1_DATVAL", "E4_DESCRI" }
					
	::SetContentType("application/json; charset=utf-8")
	::setStatus(200)
	::setResponse(oBuilder:getFromSx3(aCampos))
	freeobj(oBuilder)
return lRet

/*/{Protheus.doc} OFIW126 VS3FORM
	Retorna o metadado do VS3
	@author Renan Migliaris
	@since 09/04/2025
	@version version
/*/
WSMETHOD GET VS3FORM WSSERVICE ofixa016_019_api
	local lRet :=  .t.
	local oBuilder := VEFormBuilder():new()
	local aCampos := { "VS3_GRUITE", "VS3_CODITE", "VS3_VALPEC", "VS3_DESITE",; 
					"VS3_QTDITE", "VS3_CODTES", "VS3_PERDES", "VS3_VALTOT" }
	::SetContentType("application/json; charset=utf-8")
	::setStatus(200)
	::setResponse(oBuilder:getFromSx3(aCampos))
	freeobj(oBuilder)
return lRet

/*/{Protheus.doc} OFIW126 VO3FORM
	Retorna o metadado do VO3
	@author Renan Migliaris
	@since 09/04/2025
	@version version
/*/
WSMETHOD GET VO3FORM WSSERVICE ofixa016_019_api
    local lRet := .t.
    local oBuilder := VEFormBuilder():new()
    local aCampos := { "VO3_FILIAL", "VO3_TIPTEM", "VO3_LOJA", "VO3_GRUITE", "VO3_LIBVOO",;
                       "VO3_CODITE", "VO3_QTDREQ", "VO3_OPER", "VO3_VALPEC", "VO3_CODTES" }

    ::SetContentType("application/json; charset=utf-8")
    ::setStatus(200)
    ::setResponse(oBuilder:getFromSx3(aCampos))
	freeobj(oBuilder)
return lRet

/*/{Protheus.doc} OFIW126 VO4FORM
	Retorna o metadado do VO4
	@author Renan Migliaris
	@since 09/04/2025
	@version version
/*/
WSMETHOD GET VO4FORM WSSERVICE ofixa016_019_api
    local lRet := .t.
    local oBuilder := VEFormBuilder():new()
    local aCampos := { "VO4_FILIAL", "VO4_TIPTEM", "VO4_LOJA", "VO4_FATPAR", "VO4_LIBVOO",;
                       "VO4_GRUSER", "VO4_CODSER", "VO4_TIPSER", "VO4_DATINI", ;
                       "VO4_HORINI", "VO4_DATFIN", "VO4_HORFIN" }

    ::SetContentType("application/json; charset=utf-8")
    ::setStatus(200)
    ::setResponse(oBuilder:getFromSx3(aCampos))
	freeobj(oBuilder)
return lRet

/*/{Protheus.doc} OFIW126 FORMMOT
	Retorna o metadado do VDS para montar o motivo de rejeição
	@author Renan Migliaris
	@since 09/04/2025
	@version version
/*/
WSMETHOD GET FORMMOT WSSERVICE ofixa016_019_api
	local lRet := .t.
	local oBuilder := VEFormBuilder():new()

	::SetContentType("application/json; charset=utf-8")
	::SetStatus(200)
	::SetResponse(oBuilder:getFromVds("000012", self:id))
	freeobj(oBuilder)
return lRet

/*/{Protheus.doc} OFIW126 APRCRED
	Retorna os pedidos de aprovação de crédito pendentes
	@author Renan Migliaris
	@since 09/04/2025
	@version version
/*/
WSMETHOD GET APRCRED WSRECEIVE search WSSERVICE ofixa016_019_api
	local lRet := .t.
	local index := 1
	local oAdapter := OFICreditoAdapter():new('GET')
	local oItem := JsonObject():new()
	local oJson := JsonObject():new()
	local oResp := JsonObject():New()

	::SetContentType("application/json; charset=utf-8")

	if !empty(self:id)
		oAdapter:setNumOrc(self:id)
	endif

	oAdapter:setPage(val(self:page))
	oAdapter:setPageSize(val(self:pageSize))
	oAdapter:getAprovacoesCredito(self:search)

	oJson := JsonObject():New()
    oJson:fromJson(oAdapter:getJSONResponse())

	if len(oJson['items']) > 0
		for index := 1 to len(oJson['items'])
			oItem := oJson['items'][index]
			if !empty(oItem['vs1_tiporc'])
				oItem['vs1_dtporc'] := X3CBOXDESC("VS1_TIPORC", oItem['vs1_tiporc'])                                                                                                    
			else
				oItem['vs1_dtporc'] := ""
			endif

			if !empty(oItem['vs1_pedsta'])
				oItem['vs1_dtpstp'] := X3CBOXDESC("VS1_PEDSTA", oItem['vs1_pedsta'])                                                                                                    
			else
				oItem['vs1_dtpstp'] := ""
			endif
		Next
	endif
	oResp := oJson:toJson()
	::setStatus(200)
	::setResponse(encodeUTF8(oResp))
	freeobj(oAdapter)
	freeobj(oItem)
	freeobj(oJson)
return lRet

/*/{Protheus.doc} OFIW126 APRITENS
	Retorna os itens do pedidos de aprovação de crédito pendentes
	@author Renan Migliaris
	@since 09/04/2025
	@version version
/*/
WSMETHOD GET APRITENS WSRECEIVE id WSSERVICE ofixa016_019_api
	local lRet := .t.
	local index := 1
	local oAdapter := OFICreditoAdapter():new('GET')
	local oItem := JsonObject():new()
	local oJson := JsonObject():new()

	::SetContentType("application/json; charset=utf-8")

	if !empty(self:id)
		oAdapter:setNumOrc(self:id)
	endif

	oAdapter:setPage(val(self:page))
	oAdapter:setPageSize(val(self:pageSize))
	oAdapter:getItensAprovacaoCredito(self:search)
    oJson:fromJson(oAdapter:getJSONResponse())

	if len(oJson['items']) > 0
		for index := 1 to len(oJson['items'])
			oItem := oJson['items'][index]
			if !empty(oItem['vs3_gruite']) .AND. !empty(oItem['vs3_codite'])
				oItem['vs3_desite'] := Posicione("SB1",7,xFilial("SB1")+oItem['vs3_gruite']+oItem['vs3_codite'],"B1_DESC")                                                                                                                                      
			else
				oItem['vs3_desite'] := ""
			endif
		Next
	endif

	::setStatus(200)
	::setResponse(encodeUTF8(oJson:toJson()))
	freeobj(oAdapter)
	freeobj(oJson)
	freeobj(oItem)	
return lRet

/*/{Protheus.doc} OFIW126 APRITENS
	Aprova o item pendende de credito
	@author Renan Migliaris
	@since 09/04/2025
	@version version
/*/
WSMETHOD PUT APRCRED WSRECEIVE id WSSERVICE ofixa016_019_api
	local lRet := .t.
	local oResp := JsonObject():new()
	local oReq := JsonObject():new()
	local oCred := nil
	local oMessages := OFIMensagensPadrao():new()

	oReq:FromJson(::GetContent())
	::SetContentType("application/json; charset=utf-8")

	oCred := OFIAprovacaoCredito():new(self:id, oReq["motivo"], "OFIW126")

	if !oCred:checkAlcada("VS1")
		SetRestFault(403, encodeUTF8(oMessages:ERR_SEM_ALCADA)) //Alcada de crédito não é suficiente para essa liberação
		return .f.
	endif

	oCred:validarFase()
	oCred:updateStatusOrcamento()
	oCred:gravarLiberacaoCredito()
	oCred:gravarLog()

	oResp["message"] := encodeUTF8(oMessages:SUCCESS_APROVACAO) //Aprovação concluída com sucesso!
	oResp["status"] := "200"
	::SetStatus(200)
	::SetResponse(EncodeUTF8(oResp:ToJson()))
	freeobj(oResp)
	freeobj(oReq)
	freeobj(oCred)
	freeobj(oMessages)
return lRet

/*/{Protheus.doc} OFIW126 REABREORC
	Reabre o orçamento que estava pendente de crédito
	@author Renan Migliaris
	@since 09/04/2025
	@version version
/*/
WSMETHOD PUT REABREORC WSSERVICE ofixa016_019_api
	local lRet := .t.
	local oReq := JsonObject():new()
	local oMessages := OFIMensagensPadrao():new()
	local oResp := JsonObject():new()
	local aMotCancel
	oReq:FromJson(::GetContent())

	// Pergunta o Motivo de reabertura/negacao do credito. 
	if GetNewPar("MV_MIL0012","0") $ "1"
		aMotCancel := OFA210MOT("000012","4",xFilial("SA1"),oReq["VS1_NUMORC"],.T.)
		If Len(aMotCancel) == 0
			SetRestFault(400, encodeUTF8(oMessages:ERR_REABERTURA))
			Return .f.
		EndIf
		RecLock("VS1",.f.) 
		VS1->VS1_MOTCRD := oReq["VS1_MOTCRD"]
		MsUnlock()
	Endif
	OXI001REVF(oReq["VS1_NUMORC"], "0")

	oResp["message"] := encodeUTF8(oMessages:SUCCESS_REQUEST_CONCLUIDO) //Concluído com sucesso!
	oResp["status"] := "200"
	::SetStatus(200)
	::setResponse(encodeUTF8(oResp:ToJson()))
	freeobj(oReq)
	freeobj(oMessages)
	freeobj(oResp)
return lRet 

/*/{Protheus.doc} OFIW126 REABREORC
	Retorna os itens pendentes para aprovação do OFIXA019
	@author Renan Migliaris
	@since 09/04/2025
	@version version
/*/
WSMETHOD GET APRCRD19 WSRECEIVE id WSSERVICE ofixa016_019_api
	local lRet := .t.
	local oAdapter := OFICreditoAdapter():new('GET')
	local oItem := JsonObject():new()
	local oJson := JsonObject():new()
	local index := 1
	default id := ''

	::SetContentType("application/json; charset=utf-8")

	oAdapter:setPage(val(self:page))
	oAdapter:setPageSize(val(self:pageSize))
	oAdapter:getOfixa019OrcsApr(self:search, self:filter, self:id)
	oJson:fromJson(oAdapter:getJSONResponse())

	if len(oJson['items']) > 0
		for index := 1 to len(oJson['items'])
			oItem := oJson['items'][index]
			if !empty(oItem['vsw_codcli'])
				oItem['vsw_nomcli'] := Posicione("SA1",1,xFilial("SA1")+oItem['vsw_codcli']+oItem['vsw_loja'],"A1_NOME")                                                                                                                                      
			else
				oItem['vsw_nomcli'] := ""
			endif
		Next
	endif

	::setStatus(200)
	::setResponse(encodeUTF8(oJson:toJson()))
	FreeObj(oAdapter)
	freeobj(oItem)
	FreeObj(oJson)
return lRet

/*/{Protheus.doc} OFIW126 GETVO3
	Retorna os metadados da VO3
	@author Renan Migliaris
	@since 09/04/2025
	@version version
/*/
WSMETHOD GET GETVO3 WSRECEIVE search, id WSSERVICE ofixa016_019_api
	local oAdapter  	:= OFICreditoAdapter():New('GET')
	::SetContentType("application/json; charset=utf-8")

	if !empty(self:id)
		oAdapter:setNumLib(self:id)
	endif

	oAdapter:getVO3(::search)
	::setStatus(200)
	::setResponse(encodeUTF8(oAdapter:getJSONResponse()))
	FreeObj(oAdapter)
return .t.

/*/{Protheus.doc} OFIW126 GETVO4
	Retorna os metadados da VO4
	@author Renan Migliaris
	@since 09/04/2025
	@version version
/*/
WSMETHOD GET GETVO4 WSRECEIVE search, id WSSERVICE ofixa016_019_api
	local oAdapter  	:= OFICreditoAdapter():New('GET')
	::SetContentType("application/json; charset=utf-8")

	if !empty(self:id)
		oAdapter:setNumLib(self:id)
	endif

	oAdapter:getVO4(::search)
	::setStatus(200)
	::setResponse(encodeUTF8(oAdapter:getJSONResponse()))
	FreeObj(oAdapter)
return .t.

/*/{Protheus.doc} OFIW126 GETVO4
	Aprova a pendencia de credito do OFIXA019
	@author Renan Migliaris
	@since 09/04/2025
	@version version
/*/
WSMETHOD PUT PUTCRD19 WSSERVICE ofixa016_019_api
	local lRet := .t.
	local oCred := nil
	local oReq := JsonObject():new()
	local oMessages := OFIMensagensPadrao():new()
	local oResp := JsonObject():new()
	
	::SetContentType("application/json; charset=utf-8")
	
	oReq:FromJson(::GetContent())

	oCred := OFIAprovacaoCredito():new(self:id, oReq["motivo"], "OFIW126", self:code)

	if !oCred:checkAlcada("VSW")
		SetRestFault(403, encodeUTF8(oMessages:ERR_SEM_ALCADA)) //Alcada de crédito não é suficiente para essa liberação
		return .f.
	endif

	if !oCred:gravaLiberacaoCreditoOfixa019()
		SetRestFault(400, encodeUTF8(oMessages:ERR_ERRO_LIBERA)) //Nao foi não foi possivel concluir a liberação"
		return .f.
	endif

	oResp["message"] := encodeUTF8(oMessages:SUCCESS_APROVACAO) //Aprovação concluída com sucesso!
	oResp["status"] := "200"
	::SetStatus(200)
	::SetResponse(encodeUTF8(oResp:toJson()))
	freeobj(oCred)
	freeobj(oReq)
	freeobj(oMessages)
	freeobj(oResp)
return lRet
 