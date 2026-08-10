#include 'totvs.ch'
#include 'restful.ch'
#include 'TopConn.ch'
#include 'OFIW125.ch'

WSRESTFUL ofixa015_api DESCRIPTION STR0001 //'Api das aprovações OFIXA015 para margem e desconto'
	WSDATA id as string
	WSDATA vs6Id as string 
	WSDATA codMap as string
	WSDATA code as string
	WSDATA pageSize as character
	WSDATA page as character
	WSDATA search as string
	WSDATA filter as string
	WSDATA text as string
	WSDATA needClient as boolean

	WSMETHOD GET REPROVADOS DESCRIPTION STR0002 WSSYNTAX "/ofixa015_api/rejeitados" PATH "/ofixa015_api/rejeitados" //Retorna as aprovacoes que foram rejeitadas
	WSMETHOD GET APROVACOES DESCRIPTION STR0003 WSSYNTAX "/ofixa015_api/aprovacoes" PATH "/ofixa015_api/aprovacoes" //Retorna as margens pendentes para aprovação
	WSMETHOD GET PECASVS7 DESCRIPTION STR0004 WSSYNTAX "/ofixa015_api/aprovacao/pecas" PATH "/ofixa015_api/aprovacao/pecas" //Retorna valores da VS7 para pecas
	WSMETHOD GET SERVICOSVS7 DESCRIPTION STR0005 WSSYNTAX "/ofixa015_api/aprovacao/servicos" PATH "/ofixa015_api/aprovacao/servicos" //Retorna valores da VS7 para servicos
	WSMETHOD GET MOTREJECT DESCRIPTION STR0006 WSSYNTAX "/ofixa015_api/motivosrejeicao" PATH "/ofixa015_api/motivosrejeicao" //Retorna motivos de rejeicao da VS0
	WSMETHOD GET FORMMOT DESCRIPTION STR0007 WSSYNTAX "/ofixa015_api/formmot"	PATH "/ofixa015_api/formmot" //Retornar metadados para formação de motivos
	WSMETHOD GET PECFORMVS7	DESCRIPTION STR0008 WSSYNTAX "/ofixa015_api/vs7formpecas"	PATH "/ofixa015_api/vs7formpecas" //Retorna metadados da VS7 para pecas
	WSMETHOD GET SERVFORMS7	DESCRIPTION STR0009 WSSYNTAX "/ofixa015_api/vs7formservicos" PATH "/ofixa015_api/vs7formservicos" //Retorna metadados da VS7 para servicos
	WSMETHOD GET APROVFORMVS6 DESCRIPTION STR0010 WSSYNTAX "/ofixa015_api/vs6form" PATH "/ofixa015_api/vs6form" //Retorna metadados da VS6
	WSMETHOD PUT APROVADESC	DESCRIPTION STR0011 WSSYNTAX "/ofixa015_api/aprova" PATH "/ofixa015_api/aprova" //Realiza a aprovação de desconto
	WSMETHOD PUT REJECTDESC	DESCRIPTION STR0012 WSSYNTAX "/ofixa015_api/reprova" PATH "/ofixa015_api/reprova" //Realiza a rejeição de desconto			
	WSMETHOD GET MAPRESUL DESCRIPTION STR0013 WSSYNTAX "/ofixa015_api/mapa" PATH "/ofixa015_api/mapa" //Retorna o mapa de resultados
	WSMETHOD GET MAPTIPOS DESCRIPTION STR0014 WSSYNTAX "/ofixa015_api/mapa/tipos|/ofixa015_api/mapa/tipos/{params}" //Retorna lista com os tipos de mapa

END WSRESTFUL

/*/{Protheus.doc} OFIW125 REPROVADOS
	Retorna os pedidos de liberação que foram rejeitados
	@author Renan Migliaris
	@since 09/04/2025
	@version version
/*/
WSMETHOD GET REPROVADOS WSRECEIVE page, pageSize, search WSSERVICE ofixa015_api
	local oAdapter  	:= OFIMargemEDescontoAdapter():New('GET')
	local lRet 			:= .T.
	
	::SetContentType("application/json; charset=utf-8")
	oAdapter:setPage(val(self:page))
	oAdapter:setPageSize(val(self:pageSize))
	
	oAdapter:getReprovados(self:search)
	
	::setStatus(200)
	::setResponse(encodeUTF8(oAdapter:getJSONResponse()))
	FreeObj(oAdapter)
return lRet

/*/{Protheus.doc} OFIW125 APROVACOES
	Retorna os pedidos de liberação que precisam de aprovação
	@author Renan Migliaris
	@since 09/04/2025
	@version version
/*/
WSMETHOD GET APROVACOES WSRECEIVE page, pageSize, search, filter WSSERVICE ofixa015_api
	local oResp 		:= JsonObject():New()
	local oAdapter 		:= OFIMargemEDescontoAdapter():New('GET')
	local oException	:= OFIMensagensPadrao():new() 
	local oJson			:= JsonObject():New()
	local lRet 			:= .T.
	local cAprvlv		:= ''
	local cAprvlm		:= ''
	local index			:= 0

	::SetContentType("application/json; charset=utf-8")
	VAI->(dbSetOrder(4))
	VAI->(dbSeek(xFilial("VAI")+__cUserID))

	cAprvlm := VAI->VAI_APRVLM
	cAprvlv := VAI->VAI_APRVLV

	if (Empty(cAprvlm) .or. Empty(cAprvlv)) .or. (cAprvlm == "0" .or. cAprvlv == "0")
		SetRestFault(403, encodeUTF8(oException:ERR_SEM_PERMISSAO)) //Usuário não possui permissão para o acesso a essa rotina
		lRet := .F.
		freeobj(oException)
		Return lRet
	else
		oAdapter:setAprVlm(cAprvlm)
		oAdapter:setAprvlv(cAprvlv)
	endif

	oAdapter:setPage(val(self:page))
	oAdapter:setPageSize(val(self:pageSize))
	oAdapter:getAprovacoes(self:search)

	oResp := oAdapter:getJSONResponse()
    oJson:fromJson(oResp)

	if len(oJson['items']) > 0
		for index := 1 to len(oJson['items'])
			if !empty(oJson['items'][index]['vs6_obsmem'])
				oJson['items'][index]['vs6_observ'] := MSMM(oJson['items'][index]['vs6_obsmem'],80)                                                                                                    
			endif
			
			oJson['items'][index]['vai_despec'] := VAI->VAI_DESPEC  
		Next
	endif
	
	oJson['vai_despec'] := VAI->VAI_DESPEC
	::setStatus(200)
	::setResponse(encodeUTF8(oJson:toJson()))
	FreeObj(oResp)
	FreeObj(oAdapter)
	FreeObj(oJson)
return lRet

/*/{Protheus.doc} OFIW125 PECASVS7
	Retorna as peças que estão no pedido de aprovação
	@author Renan Migliaris
	@since 09/04/2025
	@version version
/*/
WSMETHOD GET PECASVS7 WSRECEIVE filter WSSERVICE ofixa015_api
	local oAdapter 		:= OFIMargemEDescontoAdapter():New('GET')
	local oException 	:= OFIMensagensPadrao():new()
	local lRet 			:= .T.

	::SetContentType("application/json; charset=utf-8")
	if Empty(self:filter)
		SetRestFault(400, encodeUTF8(oException:ERR_PECAS_APROVACAO)) //Não foi possível buscar as peças para aprovação
		lRet := .F.
		freeobj(oException)
		Return lRet
	endif

	oAdapter:setPage(val(self:page))
	oAdapter:setPageSize(val(self:pageSize))
	oAdapter:getPecAproacao(self:search, self:filter)
	
	::setStatus(200)
	::setResponse(encodeUTF8(oAdapter:getJSONResponse()))
	FreeObj(oAdapter)
	FreeObj(oException)
return lRet

/*/{Protheus.doc} OFIW125 SERVICOSVS7
	Retorna os serviços que estão no pedido de aprovação
	@author Renan Migliaris
	@since 09/04/2025
	@version version
/*/
WSMETHOD GET SERVICOSVS7 WSSERVICE ofixa015_api
	local oAdapter 		:= OFIMargemEDescontoAdapter():New('GET')
	local oException	:= OFIMensagensPadrao():new()
	local lRet 			:= .T.

	::SetContentType("application/json; charset=utf-8")
	if Empty(self:filter)
		SetRestFault(400, encodeUTF8(oException:ERR_SERVICOS_APROVACAO_NAO_ENCONTRADOS)) //Não foi possível buscar os serviços da aprovação
		lRet := .F.
		freeobj(oException)
		freeobj(oAdapter)
		Return lRet
	endif

	oAdapter:setPage(val(self:page))
	oAdapter:setPageSize(val(self:pageSize))
	oAdapter:getServAproacao(self:search, self:filter)
	
	::setStatus(200)
	::setResponse(encodeUTF8(oAdapter:getJSONResponse()))
	FreeObj(oAdapter)
	freeobj(oException)
return lRet

/*/{Protheus.doc} OFIW125 MOTREJECT
	Retorna os motivos de rejeição da VS0
	@author Renan Migliaris
	@since 09/04/2025
	@version version
/*/
WSMETHOD GET MOTREJECT WSSERVICE ofixa015_api
	local lRet := .t.
	local aMotCancel := {}
	local aMot := {}
	local i := 0
	local oResp := JsonObject():new()

	::SetContentType("application/json; charset=utf-8")
	// parametros da função como passados na OFIXA015:
	// motivo, OS, filial de origem vazia, codigo da origem vazio, não grava resposta
	aMotCancel := OFA210MOT("000016","2","","",.f.)

	if len(aMotCancel) == 0
		oResp["items"] := {}
		oResp["hasNext"] := .F.

		::setStatus(200)
		::setResponse(encodeUTF8(oResp:toJson()))
		FreeObj(oResp)
		return lRet
	endif

	for i := 1 to len(aMotCancel)
		aadd(aMot, aMotCancel[i])
	next

	oResp["items"] := aMot
	oResp["hasNext"] := .F.

	::setStatus(200)
	::setResponse(encodeUTF8(oResp:toJson()))
	FreeObj(oResp)
return lRet

/*/{Protheus.doc} OFIW125 FORMMOT
	Retorna o metadado para o form de motivos de rejeição da VDS
	@author Renan Migliaris
	@since 09/04/2025
	@version version
/*/
WSMETHOD GET FORMMOT WSSERVICE ofixa015_api
	local lRet 			:= .T.
	local oBuilder 		:= VEFormBuilder():new()

	::SetContentType("application/json; charset=utf-8")
	::SetStatus(200)
	::SetResponse(encodeUTF8(oBuilder:getfromVds("000016", self:id)))
	freeobj(oBuilder)
return lRet

/*/{Protheus.doc} OFIW125 PECFORMVS7
	Retorna o metadado da VS7 para o form de peças
	@author Renan Migliaris
	@since 09/04/2025
	@version version
/*/
WSMETHOD GET PECFORMVS7 WSSERVICE ofixa015_api
	local lRet := .t.
	local oBuilder := VEFormBuilder():new()
	local aCampos := {"VS7_GRUITE", "VS7_CODITE", "VS7_DESPER", "VS7_DESDES", "VS7_VALORI", "VS7_VALPER",;
					  "VS7_VALDES", "VS7_MARLUC", "VS7_MARPER", "VS7_QTDITE"} 

	::SetContentType("application/json; charset=utf-8")
	::setStatus(200)
	::setResponse(oBuilder:getFromSx3(aCampos))
	freeobj(oBuilder)
return lret

/*/{Protheus.doc} OFIW125 SERVFORMS7
	Retorna o metadado da VS7 para o form de serviços
	@author Renan Migliaris
	@since 09/04/2025
	@version version
/*/
WSMETHOD GET SERVFORMS7 WSSERVICE ofixa015_api
	local lRet := .t.
	local oBuilder := VEFormBuilder():new()
	local aCampos := {"VS7_GRUSER", "VS7_CODSER", "VS7_TIPSER", "VS7_DESPER", "VS7_DESDES", "VS7_VALORI",;
					  "VS7_VALPER", "VS7_VALDES", "VS7_QTDITE"} 

	::SetContentType("application/json; charset=utf-8")
	::setStatus(200)
	::setResponse(oBuilder:getFromSx3(aCampos))
	freeobj(oBuilder)
return lret

/*/{Protheus.doc} OFIW125 APROVFORMVS6
	Retorna o metadado da VS6 para o form de aprovações
	@author Renan Migliaris
	@since 09/04/2025
	@version version
/*/
WSMETHOD GET APROVFORMVS6 WSSERVICE ofixa015_api
	local lRet := .t.
	local oBuilder := VEFormBuilder():new()
	// local oJson := nil
	// local aPeCamp := {}
	local aCampos := {"VS6_NUMIDE", "VS6_NUMORC" ,"VS6_DATOCO", "VS6_DESOCO", "VS6_USUARI",;
					 "VS6_CODCLI", "VS6_LOJA","VS6_OBSERV"}

	::SetContentType("application/json; charset=utf-8")
	if !empty(self:needClient)
		aadd(aCampos, "A1_NOME")
		aadd(aCampos, "VAI_DESPEC")
	endif

	::setStatus(200)
	::setResponse(oBuilder:getFromSx3(aCampos))
	freeobj(oBuilder)
return lret

/*/{Protheus.doc} OFIW125 APROVADESC
	Aprova a liberação de margem e desconto
	@author Renan Migliaris
	@since 09/04/2025
	@version version
/*/
WSMETHOD PUT APROVADESC WSRECEIVE id, text WSSERVICE ofixa015_api
	Local lRet      := .T.
	Local oResp     := JsonObject():New()
	Local oRetorno  := JsonObject():New()
	Local oAprov    := OFIAprovacaoMargem():New()
	Local oMessages := OFIMensagensPadrao():New()
	Local cText     := ""

	::SetContentType("application/json; charset=utf-8")

	If Empty(::id)
		SetRestFault(400, encodeUTF8(oMessages:ERR_ID_NAO_INFORMADO))
		Return .f.
	EndIf

	If !OXA015_VerAcesso()
		SetRestFault(403, encodeUTF8(oMessages:ERR_SEM_PERMISSAO_DESCONTO))
		Return .f.
	EndIf

	If !Empty(::text)
		cText := ::text
	EndIf

	oRetorno := oAprov:aprovaDesc(::id, cText)

	If oRetorno["status"] == 404 .Or. oRetorno["status"] == 400
		lRet := .f.
		SetRestFault(oRetorno["status"], oRetorno["message"])
		Return lRet
	EndIf

	If oRetorno["status"] == 200
		oResp["message"] := oRetorno["message"]
		::setStatus(200)
		::setResponse(oResp:toJson())
	EndIf
	freeobj(oResp)
	freeobj(oRetorno)
	FreeObj(oMessages)
	FreeObj(oAprov)
Return lRet
/*/{Protheus.doc} OFIW125 REJECTDESC
	rejeita a liberação de margem e desconto
	@author Renan Migliaris
	@since 09/04/2025
	@version version
/*/
WSMETHOD PUT REJECTDESC WSSERVICE ofixa015_api
	local oReq 	 		:= JsonObject():new()
	local oAprApi 		:= OFIAprovacaoMargem():new() 
	local oException 	:= OFIMensagensPadrao():new()
	local lRet			:= .t.
	
	::SetContentType("application/json; charset=utf-8")

	if !OXA015_VerAcesso()
		SetRestFault(400, encodeUTF8(oException:ERR_SEM_PERMISSAO_DESCONTO)) //Atenção, usuário não autorizado a realizar liberações ou reprovações de desconto
		freeobj(oException)
		return .f.
	endif	

	oReq:FromJson(::GetContent())

	if !oAprApi:rejectCredit(oReq)
		SetRestFault(400, encodeUTF8(oException:ERR_ERRO_CONCLUSAO_REJEICAO)) //Não foi possível concluir a rejeição no momento
		freeobj(oException)
		return .f.
	endif
	freeobj(oReq)
	freeobj(oAprApi)
	freeobj(oException)
return lRet

/*/{Protheus.doc} OFIW125 MAPRESUL
	Retorna o mapa de avaliacao de pecas 
	@author Renan Migliaris
	@params id -id do orcamento NUMORC
	@params vs6Id - numide VS6_NUMIDE 
	@params codMap - codMap solicitado
	@since 09/04/2025
	@version version
/*/
WSMETHOD GET MAPRESUL WSRECEIVE id, codMap, vs6Id WSSERVICE ofixa015_api

	local lRet := .t.
	local aStru := {}
	local nx := 0
	local ny := 0
	local oMessage := nil
	local jItem := nil
	local jFinal := nil
	local cItem := ""
	local aItens := {}
	local aNomes := {}
	local nIdx := 0
	local i := 0

	dbSelectArea('VS6')
	dbSetOrder(1)
	dbSeek(xFiliaL('VS6') + self:vs6Id)

	if VS6->VS6_NUMORC <> self:id
		lRet := .f.
		oMessage := OFIMensagensPadrao():new()
		SetRestFault(404, encodeUTF8(oMessage:ERR_APROVACAO_NAO_ENCONTRADA)) //Aprovação não encontrada.
		freeobj(oMessage)
		return lRet
	endif

	VS6->(DbCloseArea())

	dbSelectArea('VS1')
	dbSetOrder(1)
	dbSeek(xFiliaL('VS1') + self:id)

	if valtype(self:codMap) == 'U'
		self:codMap := '004'
	endif

	aStru := OX001AVARES(2, .t., self:codMap)

	if valType(aStru) == 'U' .or. len(aStru) <= 0
		oMessage := OFIMensagensPadrao():new()
		lRet := .f.
		SetRestFault(400, oMessage:ERR_BAD_REQUEST) //Ocorreu um erro ao processar a requisicao
		freeobj(oMessage)
		return lRet
	endif

	//posicao 11 do astru é o id do item. A logica vai separar para criar um array no json
	//o Json vai ser basicamente um array de objetos, no qual a chave desse objeto vai ser o id do item
	//cada posicao do array sera aStru do item, ou seja, cada posição desse array será o resultado daquele item
	for nx := 1 to len(aStru)

		if !empty(aStru[nx][10])
			aStru[nx][10] := round(aStru[nx][10], 2)
		endif

		if !empty(aStru[nx][9])
			aStru[nx][9] := round(aStru[nx][9], 2)
		endif

		// monta o objeto JSON para cada linha
		jItem := JsonObject():new()
		for ny := 1 to len(aStru[nx])
			jItem["aStru_" + cValToChar(ny)] := aStru[nx][ny]
		next

		// define chave: totalizadores usam aStru3, itens normais usam aStru11
		if aStru[nx][3] != aStru[nx][11]
			cItem := alltrim(aStru[nx][3])
		else
			cItem := alltrim(aStru[nx][11])
		endif

		// adiciona nova chave ao array de nomes, se necessário
		nIdx := aScan(aNomes, { |x| x == cItem })
		if nIdx == 0
			aadd(aNomes, cItem)
			aadd(aItens, {})
			nIdx := len(aItens)
		endif

		// adiciona o item ao grupo correto
		aadd(aItens[nIdx], jItem)
	next

	jFinal := JsonObject():new()
	for i := 1 to len(aNomes)
		jFinal[aNomes[i]] := aItens[i]
	next

	::setStatus(200)
	::setResponse(jFinal:toJson())
	freeobj(jFinal)
	freeobj(jItem)
return lRet

/*/{Protheus.doc} OFIW125 MAPTIPOS
	Retorna uma lista com os tipos de mapa de avaliação
	@author Bruno Forcato
	@since 07/05/2025
	@version version
/*/
WSMETHOD GET MAPTIPOS WSSERVICE ofixa015_api
	local oMapAPi  		:= VEMapasAvaliacao():New('GET')
	local oResp			:= JsonObject():New()
	local oJAux			:= nil
	local lRet 			:= .T.
	
	::SetContentType("application/json; charset=utf-8")
	
	oResp := oMapAPi:getMapOpt('2')
	
	if len(self:aUrlParms) == 3
		oJAux := JsonObject():new()
		oJAux:fromJson(oMapAPi:getMapOpt('2'))
		oResp := oJAux["items"][1]:toJson()
	else 
		oResp := oMapAPi:getMapOpt('2')
	endif

	::setStatus(200)
	::setResponse(encodeUTF8(oResp))
	FreeObj(oMapAPi)
	FreeObj(oResp)
return lRet
