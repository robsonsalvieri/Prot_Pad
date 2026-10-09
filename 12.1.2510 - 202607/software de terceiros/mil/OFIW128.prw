#INCLUDE 'totvs.ch'
#INCLUDE 'restful.ch'
#INCLUDE "TopConn.ch"
#INCLUDE "OFIW128.ch"

WSRESTFUL dms_prioatendimento DESCRIPTION STR0001 //"integracao REST para priorizacao de atendimento"
    WSDATA cPlaca as String
    WSDATA cChassiReduzido as String
    WSDATA cFiltroDataInicial as String
    WSDATA cFiltroDataFinal as String
    WSDATA cVeyID as String
    WSDATA cVezID as String
    WSDATA cTpAcao as String
    WSDATA cSenha as String
    WSDATA cTabela as String
    WSDATA cMarca as String
    WSDATA cFiltro as String
	WSDATA nPagina as Numeric
	WSDATA nQtdPagina as Numeric
	WSDATA cSenhasAnteriores as character

	WSMETHOD GET  GPA01_BUSCAPELAPLACA DESCRIPTION STR0002 WSSYNTAX "/dms_prioatendimento/placa?{cPlaca}" PATH "/dms_prioatendimento/placa" //"Validacao do veiculo por placa"
	WSMETHOD GET  GPA02_BUSCAPELOCHASSI DESCRIPTION STR0003 WSSYNTAX "/dms_prioatendimento/chassi?{cChassiReduzido, cPlaca}" PATH "/dms_prioatendimento/chassi" //"Validacao do veiculo por chassi"
	WSMETHOD GET  GPA03_BUSCASENHAS DESCRIPTION STR0009 WSSYNTAX "/dms_prioatendimento/senhas?{cFiltroDataInicial, cFiltroDataFinal}" PATH "/dms_prioatendimento/senhas" //"Busca senhas da tabela VEY"
	WSMETHOD GET  GPA04_BUSCAHISTORICO DESCRIPTION STR0010 WSSYNTAX "/dms_prioatendimento/historico" PATH "/dms_prioatendimento/historico" // "Busca historico de senhas do VEZ"
	WSMETHOD GET  GPA05_BUSCAMOTIVOSCANCELAMENTO DESCRIPTION STR0011 WSSYNTAX "/dms_prioatendimento/motivos_cancelamento" PATH "/dms_prioatendimento/motivos_cancelamento" // "Busca os motivos de cancelamento"
	WSMETHOD GET  GPA06_BUSCASX5 DESCRIPTION STR0039 WSSYNTAX "/dms_prioatendimento/buscaSX5?{cTabela}" PATH "/dms_prioatendimento/buscaSX5" //"Faz um lookup generico na SX5"
	WSMETHOD GET  GPA07_BUSCASENHASCOMPASSAGEM DESCRIPTION STR0040 WSSYNTAX "/dms_prioatendimento/senhas_abertas?{nPagina, nQtdPagina}" PATH "/dms_prioatendimento/senhas_abertas"
	WSMETHOD GET  GPA08_BUSCASENHASPAINEL DESCRIPTION STR0043 WSSYNTAX "/dms_prioatendimento/senhas_painel" PATH "/dms_prioatendimento/senhas_painel" // "Busca as ultimas senhas para mostrar no painel"
	WSMETHOD GET  GPA09_BUSCACONFIG DESCRIPTION STR0045 WSSYNTAX "/dms_prioatendimento/config" PATH "/dms_prioatendimento/config" // "Busca as config do painel de priorizacao"
	WSMETHOD GET  GPA10_BUSCAMODELOSVEICULO DESCRIPTION "Busca modelos de veiculo por marca" WSSYNTAX "/dms_prioatendimento/modelos_veiculo?{cMarca,cFiltro}" PATH "/dms_prioatendimento/modelos_veiculo"

	WSMETHOD POST PPA01_CHAMAPROXIMA DESCRIPTION STR0012 WSSYNTAX "/dms_prioatendimento/controle_senha?{cVeyID, cTpAcao}" PATH "/dms_prioatendimento/controle_senha" // "Faz um controle para chamar a proxima senha"
	WSMETHOD POST PPA02_CHAMAANTERIOR DESCRIPTION STR0013 WSSYNTAX "/dms_prioatendimento/chama_anterior?{cVezID, cSenhasAnteriores}" PATH "/dms_prioatendimento/chama_anterior" // "Faz um controle para chamara a senha anterior"
	WSMETHOD POST PPA03_CHAMANOVAMENTE DESCRIPTION STR0014 WSSYNTAX "/dms_prioatendimento/chama_novamente?{cVezID}" PATH "/dms_prioatendimento/chama_novamente" // "Faz um controle para chamar a senha novamente"
	WSMETHOD POST PPA04_CANCELARSENHA DESCRIPTION STR0015 WSSYNTAX "/dms_prioatendimento/cancelar_senha" PATH "/dms_prioatendimento/cancelar_senha" // "Cancela a senha"
	WSMETHOD POST PPA05_CRIAOS DESCRIPTION STR0041 WSSYNTAX "/dms_prioatendimento/cria_os?{cVeyID}" PATH "/dms_prioatendimento/cria_os" // "Cria OS com base na senha"
	WSMETHOD POST PPA06_CRIAMOTORISTA DESCRIPTION STR0042 WSSYNTAX "/dms_prioatendimento/cria_motorista?{cVeyID}" PATH "/dms_prioatendimento/cria_motorista" // "Cria novo motorista"
	WSMETHOD POST PPA07_PRECADVEICULO DESCRIPTION "Pre cadastro manual do veiculo" WSSYNTAX "/dms_prioatendimento/pre_cadastro_veiculo?{cVeyID}" PATH "/dms_prioatendimento/pre_cadastro_veiculo" // "Pre cadastro manual do veiculo"

	WSMETHOD PUT UPA05_ALTERADATAENTREGA DESCRIPTION STR0016 WSSYNTAX "/dms_prioatendimento/altera_entrega" PATH "/dms_prioatendimento/altera_entrega" // "Altera Data de Entrega"
END WSRESTFUL

/*/{Protheus.doc} OFIW128
    Funcao principal do OFIW128

    @type function
    @author Bruno Forcato
    @since 27/05/2026
/*/
function OFIW128()
return .t.

/*/{Protheus.doc} HandleResponse
    Funcao para lidar com respostas que deram sucesso

    @type function
    @author Bruno Forcato
    @since 16/03/2026
/*/
Static Function HandleResponse(oResponse, nCode, cMessage)
	oResponse['code'] := nCode
	oResponse['message'] := cMessage
Return .t.

/*/{Protheus.doc} HandleBadResponse
    Funcao para lidar com respostas que deram erro

    @type function
    @author Bruno Forcato
    @since 16/03/2026
/*/
Static Function HandleBadResponse(oResponse, nCode, cMessage)
	oResponse['code'] := nCode
	oResponse['message'] := cMessage

	SetRestFault(nCode, cMessage)
return .f.

/*/{Protheus.doc} GPA01_BUSCAPELAPLACA
    Methodo que busca o veiculo e gera uma senha baseado na placa

    @type method
    @author Bruno Forcato
    @since 07/01/2026
/*/
WSMETHOD GET GPA01_BUSCAPELAPLACA WSRECEIVE cPlaca WSSERVICE dms_prioatendimento
	local oResponse := JsonObject():New()
	local oPrioAtendimentoClass := OFPrioAtendimentoClass():New()

	if empty(self:cPlaca)
		return HandleBadResponse(oResponse, 400, STR0004) // "Placa não informada, erro ao fazer a busca, tente novamente informando a placa corretamente"
	endif

	If !oPrioAtendimentoClass:buscaPlaca(self:cPlaca)
		return HandleBadResponse(oResponse, 400, STR0005) // "Placa do veiculo não foi localizada no Protheus. Informe o chassi reduzido do veiculo, constante no documento do veiculo, para continuidade."
	EndIf

	oResponse['senha'] := oPrioAtendimentoClass:cSenha
	oResponse['tipoContrato'] := oPrioAtendimentoClass:cTipoContrato
	oResponse['agendamento'] := oPrioAtendimentoClass:cNumide
	HandleResponse(oResponse, 200, STR0006) // "Veiculo achado achado com sucesso"
	::setResponse(oResponse:toJson())
Return .t.

/*/{Protheus.doc} GPA02_BUSCAPELOCHASSI
    Methodo que busca o veiculo e gera uma senha baseado nos 7 digitos do chassi

    @type method
    @author Bruno Forcato
    @since 07/01/2026
/*/
WSMETHOD GET GPA02_BUSCAPELOCHASSI WSRECEIVE cChassiReduzido, cPlaca WSSERVICE dms_prioatendimento
	local oResponse := JsonObject():New()
	local oPrioAtendimentoClass := OFPrioAtendimentoClass():New()

	if empty(self:cChassiReduzido)
		return HandleBadResponse(oResponse, 400, STR0007) // "Chassi não informada, erro ao fazer a busca, tente novamente informando o chassi corretamente"
	endif

	oPrioAtendimentoClass:processaChassiReduzido(self:cChassiReduzido, self:cPlaca)
	oResponse['senha'] := oPrioAtendimentoClass:cSenha
	oResponse['tipoContrato'] := oPrioAtendimentoClass:cTipoContrato
	oResponse['agendamento'] := oPrioAtendimentoClass:cNumide
	HandleResponse(oResponse, 200, STR0006) // "Veiculo achado achado com sucesso"
	::setResponse(oResponse:toJson())
Return .t.

/*/{Protheus.doc} GPA03_BUSCASENHAS
    Methodo que busca as senhas podendo ser filtradas por data inicial e final

    @type method
    @author Bruno Forcato
    @since 07/01/2026
/*/
WSMETHOD GET GPA03_BUSCASENHAS WSRECEIVE cFiltroDataInicial, cFiltroDataFinal WSSERVICE dms_prioatendimento
	local oResponse := JsonObject():New()
	local oPrioAtendimentoClass := OFPrioAtendimentoClass():New()

	oResponse['senhas'] := oPrioAtendimentoClass:buscaSenhas(self:cFiltroDataInicial, self:cFiltroDataFinal)
	HandleResponse(oResponse, 200, STR0017) // "Senhas Achadas com sucesso"
	::setResponse(oResponse:toJson())
Return .t.

/*/{Protheus.doc} PPA01_CHAMAPROXIMA
    Methodo que cadastra e chama a proxima senha na lsita de senhas não atendidas

    @type method
    @author Bruno Forcato
    @since 07/01/2026
/*/
WSMETHOD POST PPA01_CHAMAPROXIMA WSRECEIVE cVeyID, cTpAcao WSSERVICE dms_prioatendimento
	local oResponse := JsonObject():New()
	local oPrioAtendimentoClass := OFPrioAtendimentoClass():New()

		if empty(self:cVeyID) .OR. empty(self:cTpAcao)
		return HandleBadResponse(oResponse, 400, STR0018) // "Parametros não informados ou invalidos, Por favor tente novamente"
	endif

	If !oPrioAtendimentoClass:controleDeChamada(self:cVeyID, self:cTpAcao)
		return HandleBadResponse(oResponse, 400, STR0019) // "Houve um erro ao fazer o controle da senha, tente novamente"
	EndIf

	oResponse['senha'] := oPrioAtendimentoClass:cSenha
	oResponse['tipoContrato'] := oPrioAtendimentoClass:cTipoContrato
	oResponse['agendamento'] := oPrioAtendimentoClass:cNumide
	HandleResponse(oResponse, 200, STR0020) // "Senhas Atualizada com sucesso"
	::setResponse(oResponse:toJson())
Return .t.

/*/{Protheus.doc} GPA04_BUSCAHISTORICO
    Methodo que busca o historico de senhas chamadas no dia

    @type method
    @author Bruno Forcato
    @since 07/01/2026
/*/
WSMETHOD GET GPA04_BUSCAHISTORICO  WSSERVICE dms_prioatendimento
	local oResponse := JsonObject():New()
	local oPrioAtendimentoClass := OFPrioAtendimentoClass():New()

	oResponse['historico'] := oPrioAtendimentoClass:buscaHistorico()
	HandleResponse(oResponse, 200, STR0021) // "Historico Achado com sucesso"
	::setResponse(oResponse:toJson())
Return .t.

/*/{Protheus.doc} PPA02_CHAMAANTERIOR
    Methodo que cadastra e chama a senha anterior da atual

    @type method
    @author Bruno Forcato
    @since 07/01/2026
/*/
WSMETHOD POST PPA02_CHAMAANTERIOR WSRECEIVE cVezID, cSenhasAnteriores WSSERVICE dms_prioatendimento
	local oResponse := JsonObject():New()
	local oPrioAtendimentoClass := OFPrioAtendimentoClass():New()

		if empty(self:cVezID)
		return HandleBadResponse(oResponse, 400, STR0018) // "Parametros não informados ou invalidos, Por favor tente novamente"
	endif

	If !oPrioAtendimentoClass:chamaAnterior(self:cVezID, self:cSenhasAnteriores)
		return HandleBadResponse(oResponse, 400, STR0023) // "Houve um erro ao chamar o anterior, tente novamente"
	EndIf

	oResponse["senha"] := oPrioAtendimentoClass:cSenha
	oResponse["codvey"] := oPrioAtendimentoClass:cVEYCodigo
	oResponse['tipoContrato'] := oPrioAtendimentoClass:cTipoContrato
	oResponse['agendamento'] := oPrioAtendimentoClass:cNumide
	HandleResponse(oResponse, 200, STR0024) // "Chamada anterior realizada com sucesso"
	::setResponse(oResponse:toJson())
Return .t.

/*/{Protheus.doc} PPA03_CHAMANOVAMENTE
    Methodo que chama a ultima senha chamada novamente

    @type method
    @author Bruno Forcato
    @since 07/01/2026
/*/
WSMETHOD POST PPA03_CHAMANOVAMENTE WSRECEIVE cVezID WSSERVICE dms_prioatendimento
	local oResponse := JsonObject():New()
	local oPrioAtendimentoClass := OFPrioAtendimentoClass():New()

		if empty(self:cVezID)
		return HandleBadResponse(oResponse, 400, STR0018) // "Parametros não informados ou invalidos, Por favor tente novamente"
	endif

	If !oPrioAtendimentoClass:chamaNovamente(self:cVezID)
		return HandleBadResponse(oResponse, 400, STR0022) // "Houve um erro ao chamar novamente, tente novamente"
	EndIf

	oResponse['senha'] := oPrioAtendimentoClass:cSenha
	oResponse['tipoContrato'] := oPrioAtendimentoClass:cTipoContrato
	oResponse['agendamento'] := oPrioAtendimentoClass:cNumide
	HandleResponse(oResponse, 200, STR0025) // "Chamada realizada novamente com sucesso"
	::setResponse(oResponse:toJson())
Return .t.

/*/{Protheus.doc} GPA05_BUSCAMOTIVOSCANCELAMENTO
    Methodo que busca os motivos de cancelamento para as senhas

    @type method
    @author Bruno Forcato
    @since 07/01/2026
/*/
WSMETHOD GET GPA05_BUSCAMOTIVOSCANCELAMENTO WSSERVICE dms_prioatendimento
	local oResponse := JsonObject():New()
	local oPrioAtendimentoClass := OFPrioAtendimentoClass():New()

	oResponse['motivos'] := oPrioAtendimentoClass:buscaMotCancelamentos()
	HandleResponse(oResponse, 200, STR0026) // "Motivos Achados com sucesso"
	::setResponse(oResponse:toJson())
Return .t.

/*/{Protheus.doc} PPA04_CANCELARSENHA
    Methodo que cancela a senha

    @type method
    @author Bruno Forcato
    @since 07/01/2026
/*/
WSMETHOD POST PPA04_CANCELARSENHA WSSERVICE dms_prioatendimento
	local oResponse := JsonObject():New()
	local oPrioAtendimentoClass := OFPrioAtendimentoClass():New()
	local oReq := JsonObject():new()

	oReq:FromJson(::GetContent())
		if empty(oReq['veyId']) .OR. empty(oReq['motivo'])
		return HandleBadResponse(oResponse, 400, STR0018) // "Parametros não informados ou invalidos, Por favor tente novamente"
	endif

	If !oPrioAtendimentoClass:cancelaSenha(oReq['veyId'], oReq['motivo'])
		return HandleBadResponse(oResponse, 400, STR0027) // "Houve um erro ao cancelar a senha, tente novamente"
	EndIf

	HandleResponse(oResponse, 200, STR0028) // "Senhas Cancelada com sucesso"
	::setResponse(oResponse:toJson())
Return .t.

/*/{Protheus.doc} UPA05_ALTERADATAENTREGA
    Methodo que altera a data de entrega da senha

    @type method
    @author Bruno Forcato
    @since 07/01/2026
/*/
WSMETHOD PUT UPA05_ALTERADATAENTREGA WSSERVICE dms_prioatendimento
	local oResponse := JsonObject():New()
	local oPrioAtendimentoClass := OFPrioAtendimentoClass():New()
	local oReq := JsonObject():new()

	oReq:FromJson(::GetContent())

	if empty(oReq['veyId']) .OR. empty(oReq['dataEntrega']) .OR. empty(oReq['horaEntrega'])
		return HandleBadResponse(oResponse, 400, STR0018) // "Parametros não informados ou invalidos, Por favor tente novamente"
	endif

	if !oPrioAtendimentoClass:alteraDataDeEntrega(oReq['veyId'], oReq['dataEntrega'], oReq['horaEntrega'])
		return HandleBadResponse(oResponse, 400, STR0029) // "Houve um erro ao alterar a data de entrega, tente novamente"
	EndIf

	HandleResponse(oResponse, 200, STR0030) // "Data de Entega alterada com sucesso"
	::setResponse(oResponse:toJson())
Return .t.

/*/{Protheus.doc} PPA05_CRIAOS
    Methodo que chama a ultima senha chamada novamente

    @type method
    @author Bruno Forcato
    @since 07/01/2026
/*/
WSMETHOD POST PPA05_CRIAOS WSRECEIVE cVeyID WSSERVICE dms_prioatendimento
	local oResponse := JsonObject():New()
	local oPrioAtendimentoClass := OFPrioAtendimentoClass():New()

		if empty(self:cVeyID)
		return HandleBadResponse(oResponse, 400, STR0018) // "Parametros não informados ou invalidos, Por favor tente novamente"
	endif

	If !oPrioAtendimentoClass:criaOrdemDeServico(self:cVeyID)
		return HandleBadResponse(oResponse, 400, STR0031) // "Houve um erro ao criar a Ordem de Serviço. Tente novamente."
	EndIf

	HandleResponse(oResponse, 200, STR0032) // "Ordem de serviço criada com sucesso!"
	::setResponse(oResponse:toJson())
Return .t.

/*/{Protheus.doc} PPA06_CRIAMOTORISTA
    Methodo que chama a ultima senha chamada novamente

    @type method
    @author Bruno Forcato
	@since 16/03/2026
/*/
WSMETHOD POST PPA06_CRIAMOTORISTA WSRECEIVE cVeyID WSSERVICE dms_prioatendimento
	local oResponse := JsonObject():New()
	local oPrioAtendimentoClass := OFPrioAtendimentoClass():New()
	local oReq 	 		:= JsonObject():new()

	if empty(self:cVeyID)
		return HandleBadResponse(oResponse, 400, STR0018) // "Parametros não informados ou invalidos, Por favor tente novamente"
	endif

	oReq:FromJson(::GetContent())
	If !oPrioAtendimentoClass:criaMotorista(oReq, self:cVeyID)
		return HandleBadResponse(oResponse, 400, STR0033) //"Houve um erro ao cadastrar o motorista. Tente novamente."
	EndIf

	HandleResponse(oResponse, 200, STR0034) // "Motorista cadastrado com sucesso!"
	::setResponse(oResponse:toJson())
Return .t.

/*/{Protheus.doc} PPA07_PRECADVEICULO
    Methodo que inclui ou complementa o cadastro do veiculo antes da OS

    @type method
    @author Bruno Forcato
	@since 29/05/2026
/*/
WSMETHOD POST PPA07_PRECADVEICULO WSRECEIVE cVeyID WSSERVICE dms_prioatendimento
	local oResponse := JsonObject():New()
	local oPrioAtendimentoClass := OFPrioAtendimentoClass():New()
	local oReq 	 		:= JsonObject():new()

	if empty(self:cVeyID)
		return HandleBadResponse(oResponse, 400, STR0018) // "Parametros nao informados ou invalidos, Por favor tente novamente"
	endif

	oReq:FromJson(::GetContent())
	If !oPrioAtendimentoClass:preCadastroVeiculo(oReq, self:cVeyID)
		return HandleBadResponse(oResponse, 400, iif(!empty(oPrioAtendimentoClass:cErroPreCadastro), oPrioAtendimentoClass:cErroPreCadastro, "Houve um erro ao cadastrar o veiculo. Tente novamente."))
	EndIf

	HandleResponse(oResponse, 200, "Veiculo cadastrado com sucesso!")
	::setResponse(oResponse:toJson())
Return .t.

/*/{Protheus.doc} GPA06_BUSCASX5
	Busca na SX5 valores para lookup de acordo com a tabela

	@type method
	@author Bruno Forcato	
	@since 16/03/2026
/*/
WSMETHOD GET GPA06_BUSCASX5 WSRECEIVE cTabela WSSERVICE dms_prioatendimento
	local oResponse := JsonObject():New()
	local oPrioAtendimentoClass := OFPrioAtendimentoClass():New()

	if empty(self:cTabela)
		return HandleBadResponse(oResponse, 400, STR0035) // "Parâmetro não informado. Tente novamente."
	endif

	oResponse['items'] := oPrioAtendimentoClass:BuscaSX5(self:cTabela)
	if len(oResponse['items']) == 0
		return HandleBadResponse(oResponse, 400, STR0036) // "Nenhum item encontrado. Tente com outra tabela."
	endif

	HandleResponse(oResponse, 200, STR0037 + cValtoChar(len(oResponse['items'])) + STR0038) // "Foram encontrado um total de " + " itens"
	::setResponse(oResponse:toJson())
return .t.

/*/{Protheus.doc} GPA07_BUSCASENHASCOMPASSAGEM
	Busca as senhas com passagem do control tower

	@type method
	@author Bruno Forcato	
	@since 16/03/2026
/*/
WSMETHOD GET GPA07_BUSCASENHASCOMPASSAGEM WSRECEIVE nPagina, nQtdPagina WSSERVICE dms_prioatendimento
    local oResponse := JsonObject():New()
    local oPrioAtendimentoClass := OFPrioAtendimentoClass():New()
	local aSenhas := {}

	self:nPagina := Max(1, Val(cValToChar(self:nPagina)))
	self:nQtdPagina := Max(1, Val(cValToChar(self:nQtdPagina)))

	aSenhas := oPrioAtendimentoClass:buscaSenhasStatusPassagemAberto(self:nPagina, self:nQtdPagina)
    oResponse['senhas'] := aSenhas[1]
	oResponse['totalPaginas'] := aSenhas[2]
	if len(oResponse['senhas']) == 0
		return HandleBadResponse(oResponse, 400, STR0036) // "Nenhum item encontrado. Tente com outra tabela."
	endif

    HandleResponse(oResponse, 200, STR0037 + cValtoChar(len(oResponse['senhas'])) + STR0038) // "Foram encontrado um total de " + " itens"
    ::setResponse(oResponse:toJson())
return .t.

/*/{Protheus.doc} GPA08_BUSCASENHASPAINEL
	Busca as senhas para o painel do cliente

	@type method
	@author Bruno Forcato	
	@since 16/03/2026
/*/
WSMETHOD GET GPA08_BUSCASENHASPAINEL WSSERVICE dms_prioatendimento
	local oResponse := JsonObject():New()
	local oPrioAtendimentoClass := OFPrioAtendimentoClass():New()

	oResponse := oPrioAtendimentoClass:buscaSenhasPainel()
	HandleResponse(oResponse, 200, STR0044) // "Dados encontrados com sucesso"
	::setResponse(oResponse:toJson())
return .t.

/*/{Protheus.doc} GPA09_BUSCACONFIG
	Busca as configuraçãoes da priorizacao de atendimento

	@type method
	@author Bruno Forcato	
	@since 13/04/2026
/*/
WSMETHOD GET GPA09_BUSCACONFIG WSSERVICE dms_prioatendimento
	Local ofScaniaConfig := OfScaniaConfig():New("PRIOATE","OFIA551")
	Local jConfig := ofScaniaConfig:getConfigWithNoEnviroment()

	HandleResponse(jConfig, 200, STR0046) // "Configurações encontradas"
	::setResponse(jConfig:toJson())
return .t.

/*/{Protheus.doc} GPA10_BUSCAMODELOSVEICULO
	Busca modelos de veiculo filtrados pela marca

	@type method
	@author Bruno Forcato
	@since 03/06/2026
/*/
WSMETHOD GET GPA10_BUSCAMODELOSVEICULO WSRECEIVE cMarca, cFiltro WSSERVICE dms_prioatendimento
	local oResponse := JsonObject():New()
	local oPrioAtendimentoClass := OFPrioAtendimentoClass():New()

	if empty(self:cMarca)
		return HandleBadResponse(oResponse, 400, STR0047) //"Marca nao informada."
	endif

	oResponse['items'] := oPrioAtendimentoClass:buscaModelosVeiculo(self:cMarca, self:cFiltro)
	oResponse['hasNext'] := .f.
	HandleResponse(oResponse, 200, STR0048) //"Modelos encontrados com sucesso"
	::setResponse(oResponse:toJson())
return .t.