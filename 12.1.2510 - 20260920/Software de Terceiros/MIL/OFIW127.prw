#include 'totvs.ch'
#include 'restful.ch'
#include 'ofiw127.ch'

/*/{Protheus.doc} OFIW127
	Webservice dms que irá retornar algumas informações que poderão ser utilizadas em várias aplicações web
	Por exemplo, parcelas em aberto de um usuário, informações de clientes entre outros
	@author Renan Migliaris
	@since 09/04/2025
	@version version
	/*/
WSRESTFUL dms_infos_gerais_api DESCRIPTION STR0001 //Api para retorno de informações gerais (exemplo: parcelas em aberto, informações de clientes)
	WSDATA id as string
	WSDATA code as string
	WSDATA pageSize as character
	WSDATA page as character
	WSDATA search as string
	WSDATA filter as string

	WSMETHOD GET SE1PARCELAS DESCRIPTION STR0002 WSSYNTAX "/dms_infos_gerais_api/SE1PARCELAS/{cod}/{loja}" PATH "/dms_infos_gerais_api/SE1PARCELAS/{cod}/{loja}" //Retorna parcelas em aberto
	WSMETHOD GET INFOCLI DESCRIPTION STR0003 WSSYNTAX "/dms_infos_gerais_api/infocli/{cod}/{loja}" PATH "/dms_infos_gerais_api/infocli/{cod}/{loja}" //Retorna info do cliente
	WSMETHOD GET CONFIGAPRV DESCRIPTION STR0004 WSSYNTAX "/dms_infos_gerais_api/configaprovamil" PATH "/dms_infos_gerais_api/configaprovamil" //Retorna as configurações do usuário aprovador
	WSMETHOD GET CLIFORMINFO DESCRIPTION STR0005 WSSYNTAX "/dms_infos_gerais_api/cliforminfo"	PATH "/dms_infos_gerais_api/cliforminfo" //Retorna metadados para info de clientes
	WSMETHOD GET SE1FORM DESCRIPTION STR0006 WSSYNTAX "/dms_infos_gerais_api/se1form"	PATH "/dms_infos_gerais_api/se1form" //Retorna metadados para info de parcelas
	WSMETHOD GET BRANCHES DESCRIPTION STR0007 WSSYNTAX "/dms_infos_gerais_api/branches" PATH "/dms_infos_gerais_api/branches" //Retorna filais do ambiente 
	WSMETHOD GET ENVCONFIG DESCRIPTION STR0008 WSSYNTAX "/dms_info_gerais_api/configenv" PATH "/dms_infos_gerais_api/configenv" //Retorna a configuracao do enviroment
	WSMETHOD PUT ENVSAVECONFIG DESCRIPTION STR0009 WSSYNTAX "/dms_info_gerais_api/saveconfigenv" PATH "/dms_infos_gerais_api/saveconfigenv" //Atualiza as configurações do environment
	WSMETHOD GET VALIDCUSTOMERCREDITDATA DESCRIPTION STR0010 WSSYNTAX "/dms_infos_gerais_api/validcustomercredit/{cod}/{loja}" PATH "/dms_infos_gerais_api/validcustomercredit/{cod}/{loja}" //Consulta valores em andamento levantados pela Validação de Crédito do Cliente ( FG_AVALCRED )
END WSRESTFUL

/*/{Protheus.doc} OFIW127 CONFIGAPRV
	Retorna as configurações básicas de usuário do aprovamil
	@author Renan Migliaris
	@since 09/04/2025
	@version version
/*/
WSMETHOD GET CONFIGAPRV WSSERVICE dms_infos_gerais_api
	local oResp := JsonObject():New()
	local oException := nil
	local oMenuConfig := VEConfigMenuAPI():New()
	local lRet 		:= .F.
	local aMenus := {}
	local aMenusPer := {}
	local nx := 0
	local aSM0 := FWLoadSM0()
	local aBranchs := {}
	Local cEmprLog := ""
    Local cFiliLog := ""

	::SetContentType("application/json; charset=utf-8")
    cEmprLog := FWCodEmp()
    cFiliLog := FWCodFil()

	for nx := 1 to len(aSM0)
		if aSM0[nx][1] == cEmprLog .AND. aSM0[nx][2] == cFiliLog .AND. !aSM0[nx][11]
			oException := OFIMensagensPadrao():new()
			SetRestFault(403, encodeUTF8(oException:ERR_SEM_ACESSO_EMPRESA_FILIAL)) //Usuário sem acesso a empresa/filial.
			freeObj(oException)
			return .f.
		endif

		aadd(aBranchs, aSM0[nx])
	next

	if GetNewPar("MV_MIL0012","0") $ "1"
		oResp["MOTIVO_NEGACAO_CREDITO"] := .t.
	else
		oResp["MOTIVO_NEGACAO_CREDITO"] := .f.
	endif

	VAI->(dbSetOrder(4))
	VAI->(dbSeek(xFilial("VAI")+__cUserId))

	lRet := .T.
	oResp["VAI_APRVLV"	] := VAI->VAI_APRVLV
	oResp["VAI_APRVLM"	] := VAI->VAI_APRVLM
	oResp["VAI_NOMUSU"	] := VAI->VAI_NOMUSU
	oResp["VAI_TELAPR"	] := VAI->VAI_TELAPR

	aMenus := {'OFIXA015', 'VEIXA018', 'OFIXA016', 'OFIXA019'}
	oMenuConfig:SetMenus(aMenus)
	aMenusPer := oMenuConfig:aMenusAccess
	OF127001J_VerificaPermissaoCampos(aMenusPer)
	oResp['MENUS'] := aMenusPer
	oResp['FILIAIS'] := aBranchs

	::setStatus(200)
	::setResponse(oResp:ToJson())

	VAI->(dbCloseArea())
	return lRet
return

/*/{Protheus.doc} OFIW127 SE1PARCELAS
	Retorna as parcelas abertas de um cliente recebe como parâmetro código e loja para realizar a busca
	Valida com o parâmetro MV_CREDCLI se as totalizações serão realizadas por loja ou por cliente
	@author Renan Migliaris
	@since 09/04/2025
	@version version
	/*/
WSMETHOD GET SE1PARCELAS WSRECEIVE page, pageSize WSSERVICE dms_infos_gerais_api
	local lRet 		:= .t.
	local oAdapter 	:= VEAprovacoesInfosAdapter():new('GET')
	local cResp 	:= ''
	local lCredCli  := GetMV("MV_CREDCLI") == "L"

	::SetContentType("application/json; charset=utf-8")
	if !Empty(lCredCli)
		oAdapter:setTLoja(.t.)
	endif
	oAdapter:setCodCli(::aUrlParms[2])
	oAdapter:setLoja(::aUrlParms[3])
	oAdapter:setPage(val(self:page))
	oAdapter:setPageSize(val(self:pageSize))
	oAdapter:getParcelasAbertas()

	cResp := oAdapter:getJSONResponse()
	::setStatus(200)
	::setResponse(encodeUTF8(cResp))
	FreeObj(oAdapter)
return lRet

/*/{Protheus.doc} OFIW127 INFOCLI
	Retorna informações de um cliente em específico (informações que são mostradas no semáforo)
	Recebe como parâmetros o cod e loja para que a busca seja realizada.
	Valida com o parâmetro MV_CREDCLI se as totalizações serão realizadas por loja ou por cliente
	@author Renan Migliaris
	@since 09/04/2025
	@version version
	/*/
WSMETHOD GET INFOCLI WSSERVICE dms_infos_gerais_api
	local oAdapter  := VEAprovacoesInfosAdapter():New("GET")
	local lRet 		:= .t.
	local cJson	 	:= ''
	local lCredCli  := GetMV("MV_CREDCLI") == "L"

	::SetContentType("application/json; charset=utf-8")
	if lCredCli
		oAdapter:setTLoja(.t.)
	endif
	oAdapter:setCodCli(::aUrlParms[2])
	oAdapter:setLoja(::aUrlParms[3])
	cJson := oAdapter:getInfoClientes()
	
	::setStatus(200)
	::setResponse(encodeUTF8(cJson))
	FreeObj(oAdapter)
return lRet

/*/{Protheus.doc} OFIW127 CLIFORMINFO
	Retorna os metadados para o formulário de informações do cliente, que são utilizados na tela de aprovações
	@author Renan Migliaris
	@since 09/04/2025
	@version version
/*/
WSMETHOD GET CLIFORMINFO WSSERVICE dms_infos_gerais_api
	local lRet := .t.
	local lCredCli := GetMv("MV_CREDCLI") == "L"
	local oBuilder := VEFormBuilder():new()
	local aCampos := {"A1_COD", "A1_LC", "A1_NOME", "A1_RISCO",;
					"VCF_NIVIMP", "VCF_AREVEN", "VCB_DESREG"}

	local aCustomFields := {;
			{"property", "label", "type", "gridColumns","gridSmColumns"},;
			{;
				{"nValor", "Valor Utilizado", "number",  6, 12},;
				{"nDif", "Saldo", "number", 6, 12},;
				{"nValVenc", "Vencidos", "number", 6, 12},;
				{"nAndamento", "Andamento (OS+Orc)", "number", 6, 12};
			};
		}
	
	::SetContentType("application/json; charset=utf-8")
	if lCredCli
		aadd(aCampos, "A1_LOJA")
	endif
	::setStatus(200)
	::setResponse(oBuilder:getFromSx3(aCampos, aCustomFields))
return lRet 

/*/{Protheus.doc} OFIW127 SE1FORM
	Retorna os metadados para o formulário de informações de parcelas do cliente, 
	que são utilizados na tela de aprovações
	@author Renan Migliaris
	@since 09/04/2025
	@version version
/*/
WSMETHOD GET SE1FORM WSSERVICE dms_infos_gerais_api
	local lRet := .t.
	local oBuilder := VEFormBuilder():new()
	local aCampos := {"E1_FILIAL", "E1_TIPO", "E1_NUM", "E1_PARCELA",; 
					"E1_EMISSAO", "E1_VENCREA", "E1_VALOR", "E1_SALDO"}
	
	::SetContentType("application/json; charset=utf-8")
	::setStatus(200)
	::setResponse(oBuilder:getFromSx3(aCampos))
return lret 

/*/{Protheus.doc} OFIW127 BRANCHES
	Retorna dados de empresa e filiais que o ambiente tem como disponíveis.
	Atenção: endpoint público!
	@author Renan Migliaris
	@since 09/06/2025	
/*/

WSMETHOD GET BRANCHES WSSERVICE dms_infos_gerais_api
	local lRet := .t.
	local aFiliais := FwLoadSm0()
	local oJaux := nil
	local oResp := nil
	local aResp := {}
	local nX := 0

	for nx := 1 to len(aFiliais)
		oJaux := JsonObject():new()
		oJaux["grupoEmpresa"]   		:= aFiliais[nx][1]   
		oJaux["codigoFilialAll"]		:= aFiliais[nx][2]
		oJaux["codigoEmpresa"]        	:= aFiliais[nx][3]   
		oJaux["unidadeNegocio"] 		:= aFiliais[nx][4]   
		oJaux["filial"]         		:= aFiliais[nx][5]   
		oJaux["nomeFilial"]     		:= aFiliais[nx][6]   
		oJaux["nomeReduzidoFilial"]		:= aFiliais[nx][7]
		oJaux["nomeComercial"]  		:= aFiliais[nx][17]  
		oJaux["status"]         		:= aFiliais[nx][16]  
		oJaux["razaoSocial"]			:= aFiliais[nx][24]
		oJaux["tenantId"]				:= aFiliais[nx][1] +","+ aFiliais[nx][2]
		aadd(aResp, oJaux)
		freeObj(oJaux)
	next

	oResp := JsonObject():new()
	oResp:set(aResp)
	::setStatus(200)
	::setResponse(oResp:toJson())
	
return lRet

/*/{Protheus.doc} OFIW127 ENVCONFIG
	Retorna as configurações de ambeinte do sistema
	@author Bruno Forcato
	@since 13/06/2025
	@table VRN
	@version version
/*/
WSMETHOD GET ENVCONFIG WSSERVICE dms_infos_gerais_api
	local jConfig := JsonObject():New()
	local cCodigo := "APROVAMIL"
	local lExistCfg := .f.
	local oException := nil

	dbselectArea("VRN")
	VRN->(dbSetOrder(1))
	lExistCfg := VRN->(dbSeek(xFilial("VRN") + cCodigo))
	if !lExistCfg
		oException := OFIMensagensPadrao():new()
		SetRestFault(404, encodeUTF8(oException:ERR_CONFIGURACAO_NAO_ENCONTRADA)) //Nenhuma configuração encontrada.
		freeObj(oException)
		return .f.
	endif

	jConfig:FromJson(VRN->VRN_CONFIG)
	::setStatus(200)
	::setResponse(jConfig)

	VRN->(dbCloseArea())
return .t.

/*/{Protheus.doc} ENVSAVECONFIG
	salva json com a config

	@type method
	@author Bruno Forcato	
	@since 13/06/2025
/*/
WSMETHOD PUT ENVSAVECONFIG WSSERVICE dms_infos_gerais_api
	local oMessages := OFIMensagensPadrao():new()
	local oResp := JsonObject():New()
	local cCodigo := "APROVAMIL"
	
	::SetContentType("application/json; charset=utf-8")
	dbselectArea("VRN")
	dbSetOrder(1)
	dbSeek(xFilial("VRN") + cCodigo)

	reclock("VRN", !Found())
	VRN->VRN_FILIAL := xFilial("VRN")
	VRN->VRN_CODIGO := cCodigo
	VRN->VRN_CONFIG := ::GetContent()
	VRN->(msUnlock())

	oResp['message'] := encodeUTF8(oMessages:SUCCESS_REQUEST_CONCLUIDO) //Concluído com sucesso!
	VRN->(dbCloseArea())

	::setStatus(200)
	::setResponse(oResp:toJson())
Return .t.

/*/{Protheus.doc} VALIDCUSTOMERCREDITDATA
	Busca as informações de crédito em andamento do cliente

	@type method
	@author Bruno Forcato	
	@since 02/09/2025
/*/
WSMETHOD GET VALIDCUSTOMERCREDITDATA WSSERVICE dms_infos_gerais_api
	local oResp := JsonObject():New()
	Local aCols := OC1600031_TitulosCOLUNAS()
	local oException := nil
	default cClient := ""
	default cLoja := ""

	::SetContentType("application/json; charset=utf-8")
	cClient := ::aUrlParms[2]
	cLoja := ::aUrlParms[3]

	if empty(cClient) .or. empty(cLoja)
		oException := OFIMensagensPadrao():new()
		SetRestFault(404, encodeUTF8(oException:ERR_BAD_REQUEST)) //Ocorreu um erro ao processar a requisicao.
	 	freeObj(oException)
	 	return .f.
	endif

	oResp["cols"] := aCols
	oResp['values'] := OC1600041_LEVANTA(cClient, cLoja)
	::setStatus(200)
	::setResponse(encodeUTF8(oResp:toJson()))
return .t.


/*/{Protheus.doc} OF127001J_VerificaPermissaoCampos
	Verifica campos (da equipe técnica) de autorização da rotina para a montagem do menu 
	@type  Static Function
	@author Renan Migliaris
	@since 28/07/2025
/*/
Static Function OF127001J_VerificaPermissaoCampos(aMenus)
	local nPos := 0

	nPos := aScan(aMenus, "VEIXA018")

	if nPos > 0
		dbSelectArea("VAI")
		dbSetOrder(4)
		dbSeek(xFilial("VAI")+__cUserId)

		if VAI->(found())
			if VAI->VAI_APROVA == "0"
				aDel(aMenus, nPos)
			endif
		endif

		VAI->(dbCloseArea())
	endif

Return aMenus