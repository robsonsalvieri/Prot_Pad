#include 'totvs.ch'
#include 'restful.ch'
#include 'TopConn.ch'
#include 'veiw126.ch' 

WSRESTFUL veixa018_api DESCRIPTION STR0001 //Api das aprovações VEIXA018
	WSDATA id as string
	WSDATA pageSize as character
	WSDATA page as character
	WSDATA search as string

	WSMETHOD GET APROVACOES DESCRIPTION STR0002 WSSYNTAX "/veixa018_api/atendimentos" PATH "/veixa018_api/atendimentos" //Retorna os atendimentos pendentes a aprovacoes
	WSMETHOD GET REPROVADOS DESCRIPTION STR0003 WSSYNTAX "/veixa018_api/reprovados" PATH "/veixa018_api/reprovados" //Retorna os atendimentos reprovados
	WSMETHOD GET VV9FORM DESCRIPTION STR0004 WSSYNTAX "/veixa018_api/vv9form" PATH "/veixa018_api/vv9form" //retorna os campos do atendimento
	WSMETHOD GET GETMAPA DESCRIPTION STR0005 WSSYNTAX "/veixa018_api/mapa" PATH "/veixa018_api/mapa" //retorna o mapa do atendimento	
	WSMETHOD PUT APROVAATEND DESCRIPTION STR0005 WSSYNTAX "/veixa018_api/aprovar" PATH "/veixa018_api/aprovar" //Aprova o atendimento
	WSMETHOD PUT REJEITAATEND DESCRIPTION STR0006 WSSYNTAX "/veixa018_api/reprovar" PATH "/veixa018_api/reprovar" //rejeita o atendimento	
END WSRESTFUL

/*/{Protheus.doc} VEIW126 APROVACOES
	Retorna os pedidos de atendimento que precisam de aprovação
	@author Bruno Forcato
	@since 22/04/2025
	@version version
/*/
WSMETHOD GET APROVACOES WSRECEIVE page, pageSize, search WSSERVICE veixa018_api
	local oAdapter  	:= VEAtendimentoAdapter():New('GET')
	local lRet 			:= .T.
	::SetContentType("application/json; charset=utf-8")

	oAdapter:setPage(val(self:page))
	oAdapter:setPageSize(val(self:pageSize))
	oAdapter:getAprovacoes(::search)
	
	::setStatus(200)
	::setResponse(encodeUTF8(oAdapter:getJSONResponse()))
	FreeObj(oAdapter)
return lRet

/*/{Protheus.doc} VEIW126 REPROVADOS
	Retorna os atendimento que foram reprovados
	@author Bruno Forcato
	@since 22/04/2025
	@version version
/*/
WSMETHOD GET REPROVADOS WSRECEIVE page, pageSize, search WSSERVICE veixa018_api
	local oAdapter  	:= VEAtendimentoAdapter():New('GET')
	local oResp			:= JsonObject():New()
	local lRet 			:= .T.
	::SetContentType("application/json; charset=utf-8")

	oAdapter:setPage(val(self:page))
	oAdapter:setPageSize(val(self:pageSize))
	oAdapter:getReprovados(self:search)
	oResp := oAdapter:getJSONResponse()	
	
	::setStatus(200)
	::setResponse(encodeUTF8(oResp))
	FreeObj(oAdapter)
	FreeObj(oResp)
return lRet

/*/{Protheus.doc} VEIW126 APROVAATEND
	aprova o atendimento que estava pendente
	@author Bruno Forcato
	@since 22/04/2025
	@version version
/*/
WSMETHOD PUT APROVAATEND WSRECEIVE id WSSERVICE veixa018_api
	local oReq 	 		:= JsonObject():new()
	local oResp			:= JsonObject():new()
	local oAtend 		:= VEAtendimentoApi():new() 
	local oProd 		:= VEProdutivoApi():New()
	local oException 	:= OFIMensagensPadrao():new()
	local lRet			:= .t.

	::SetContentType("application/json; charset=utf-8")
	oReq:FromJson(::GetContent())
	oProd := oProd:AndEq("VAI_CODUSR", __cUserID):NotDeleted():first()
	oAtend := oAtend:AndEq("VV9_FILIAL", xFilial("VV9")):AndEq("VV9_NUMATE", self:id):First()
	INCLUI     := .F.
			
	if oAtend:Persistido()
		// Verificação de alçada do usuario
		DBSelectArea("VVA")
		DBSetOrder(1)
		DBSeek(xFilial("VVA") + self:id)
		oAtend:Alcada(VVA->VVA_CHAINT, self:id)

		if !oAtend:Aprovar(oProd)
			SetRestFault(400, encodeUTF8(oException:ERR_SEM_PERMISSAO_APROVAR_ATENDIMENTO)) //Usuário não possui permissão para aprovar o atendimento
			freeobj(oException)
			return .f.
		endif
	else
		SetRestFault(404, encodeUTF8(oException:ERR_DADOS_NAO_ENCONTRADOS)) //Erro dados nao encontrados
		freeobj(oException)
	endif

	oResp['message'] := encodeUTF8(oException:SUCCESS_REQUEST_CONCLUIDO) //Concluído com sucesso!
	::setStatus(200)
	::setResponse(encodeUTF8(oResp:toJson()))
	freeobj(oReq)
	FreeObj(oResp)
	freeobj(oAtend)
	freeobj(oProd)
	freeobj(oException)
return lRet

/*/{Protheus.doc} VEIW126 REJEITAATEND
	rejeita o atendimento que estava pendente
	@author Bruno Forcato
	@since 22/04/2025
	@version version
/*/
WSMETHOD PUT REJEITAATEND WSRECEIVE id WSSERVICE veixa018_api
	local oReq 	 		:= JsonObject():new()
	local oAtend 		:= VEAtendimentoApi():new() 
	local oProd 		:= VEProdutivoApi():New()
	local oResp 		:= JsonObject():new()
	local oException 	:= OFIMensagensPadrao():new()
	local lRet			:= .t.
	
	::SetContentType("application/json; charset=utf-8")
	oReq:FromJson(::GetContent())
	oProd := oProd:AndEq("VAI_CODUSR", __cUserID):first()
	oAtend := oAtend:AndEq("VV9_FILIAL", xFilial("VV9")):AndEq("VV9_NUMATE", self:id):First()
	INCLUI     := .F.
			
	if oAtend:Persistido()
		if !oAtend:Reprovar(oProd)
			SetRestFault(400, encodeUTF8(oException:ERR_SEM_PERMISSAO_REPROVAR_ATENDIMENTO)) //Não foi possível concluir a rejeição no momento
			freeobj(oException)
			return .f.
		endif
	else
		SetRestFault(404, encodeUTF8(oException:ERR_DADOS_NAO_ENCONTRADOS)) //Erro dados nao encontrados
		freeobj(oException)
	endif

	oResp['message'] := encodeUTF8(oException:SUCCESS_REQUEST_CONCLUIDO) //Concluído com sucesso!
	::setStatus(200)
	::setResponse(encodeUTF8(oResp:toJson()))
	freeobj(oReq)
	freeobj(oAtend)
	freeobj(oProd)
	FreeObj(oResp)
	freeobj(oException)
return lRet

/*/{Protheus.doc} VEIW126 VV9FORM
	retorna o metadado do VV9
	@author Bruno Forcato
	@since 22/04/2025
	@version version
/*/
WSMETHOD GET VV9FORM WSSERVICE veixa018_api
	local lRet := .t.
	local oBuilder := VEFormBuilder():new()
	local aCampos := {"VV9_FILIAL", "VV9_NUMATE", "VV9_STATUS", "VV9_CODCLI", "VV9_LOJA", "VV9_TELVIS",;
					  "VV9_NOMVIS", "VV9_MODVEI", "A1_NOME"} 

	::SetContentType("application/json; charset=utf-8")
	::setStatus(200)
	::setResponse(oBuilder:getFromSx3(aCampos))
	FreeObj(oBuilder)
return lret

/*/{Protheus.doc} VEIW126 GETMAPA
	retorna o mapa do atendimento
	@author Bruno Forcato
	@since 22/04/2025
	@version version
/*/
WSMETHOD GET GETMAPA WSRECEIVE id WSSERVICE veixa018_api
	local oResp			:= JsonObject():New()
	local oAtend 		:= VEAtendimentoApi():New()
	local oException 	:= OFIMensagensPadrao():new()
	local oVXRet		:= nil
	local lRet 			:= .T.
	local aMapa 		:= {}
	local nVComVde 		:= 0
	local nPComVda		:= 0
	::SetContentType("application/json; charset=utf-8")

	oAtend := oAtend:AndEq("VV9_FILIAL", xFilial("VV9")):AndEq("VV9_NUMATE", self:id):First()
	if !oAtend:Persistido()
		SetRestFault(404, encodeUTF8(oException:ERR_DADOS_NAO_ENCONTRADOS)) //Erro dados nao encontrados
		freeobj(oException)
		return .f.
	endif

	VV9->(dbSetOrder(1)) // VV9_FILIAL+VV9_NUMATE
	VV9->(dbSeek(xFilial("VV9")+self:id))

	aMapa := FM_MAPAVAPI(xFilial("VV9"), self:id)
	oVXRet := VX013MAPATEND(GetNewPar("MV_MAPAPR","011"), @nVComVde, @nPComVda, .t., self:id)

	VV9->(dbCloseArea())
	oResp["mapa"] := aMapa
	oResp["message"] := encodeUTF8(oException:SUCCESS_REQUEST_CONCLUIDO) //Concluído com sucesso!
	oResp["vendaAcumulado"] := nVComVde 	//nVComVde, numeric, Valor de venda acumulado
	oResp["percentualComissaoVenda"] := nPComVda 	//nPComVda, numeric, Percentual da comissao da venda
	oResp["totalizadorMapa"] := oVXRet

	::setStatus(200)
	::setResponse(encodeUTF8(oResp:toJson()))
	freeobj(oVXRet)
	FreeObj(oResp)
	freeobj(oAtend)
	freeobj(oException)
return lRet
