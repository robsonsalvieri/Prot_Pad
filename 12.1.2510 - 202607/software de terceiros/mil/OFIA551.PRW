#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'OFIA551.CH'

static oView
static oModel
static aTabAgendamento 	:= {"AGE_MULTIAGEN", "AGE_EXISTAGEN"}
static aTabOrdemServico := {"OS_VALIDINTERAGE", "OS_INTERMIN", "OS_VALIDANTAGEHORA", "OS_VALIDDEPAGEHORA"}
static aTabGeracaoSenha := {"GESE_ORDEM", "GESE_TPCONTRATO", "GESE_DESC"}
static aTabAcompanhaCliente := {"ACCLI_IDENTPAINEL", "ACCLI_TEMPCHAMADAS"}
static aTabCanalAgendamento := {"AAGE_FILIAL", "AAGE_CANALAGENDA"}
static aTabTempoTolerancia := {"TTO_TEMPOCHEGADA"}
static aTabSequencialSenha := {"SESE_TEMPORESETSENHA"}

/*/ {Protheus.doc} OFIA551
	Tela Configurações Priorização de Atendimento

	@author  Bruno Hebeler Forcato
	@since   30/03/2026
/*/
Function OFIA551()
	Private oCfgScInt 	:= OfScaniaConfig():New("","OFIA551")
	Private cFiltroVX5 := "107"

	FWExecView( STR0001 , "OFIA551", MODEL_OPERATION_UPDATE, , {|| .T. }) // Configurações
Return NIL

/*/{Protheus.doc} ModelDef
	Definicao do Modelo dos Dados
	@author  Bruno Hebeler Forcato
	@since   30/03/2026
/*/
Static Function ModelDef()
	local oSubModAgendamento := OA5510012_StructAgendamento()
	local oStructAgendamento := nil
	local bLoadModAgendamento := {|| OA5510022_LoadModelAgendamento()}

	local oSubModOrdemServico := OA5510032_StructOrdemServico()
	local oStructOrdemServico := nil
	local bLoadModOrdemServico := {|| OA5510042_LoadModelOrdemServico()}

	local oEveDef := OFIA551EVDEF():New()
	Local oSubModMaster := OA5510092_StructMaster()
	Local oStructMaster := oSubModMaster:GetModel()
	Local bLoadModMaster := {|| OA5510102_LoadModelMaster()}

	Local oSubModGeracaoSenha
	Local oStructGeracaoSenha
	Local bLoadModGeracaoSenha

	Local oSubModAcompanhaCliente := OA5510152_StructAcompanhaCliente()
	Local oStructAcompanhaCliente := oSubModAcompanhaCliente:GetModel()
	Local bLoadModAcompanhaCliente := {|| OA5510162_LoadModelAcompanhaCliente()}

	Local oSubModCanalAgendamento := OA5510172_StructCanalAgendamento()
	Local oStructCanalAgendamento := oSubModCanalAgendamento:GetModel()
	Local bLoadModCanalAgendamento := {|| OA5510182_LoadModelCanalAgendamento()}

	Local oSubModTempoTolerancia := OA5510202_StructTempoTolerancia()
	Local oStructTempoTolerancia := oSubModTempoTolerancia:GetModel()
	Local bLoadModTempoTolerancia := {|| OA5510212_LoadModelTempoTolerancia()}

	Local oSubModSequencialSenha := OA5510222_StructSequencialSenha()
	Local oStructSequencialSenha := oSubModSequencialSenha:GetModel()
	Local bLoadModSequencialSenha := {|| OA5510232_LoadModelSequencialSenha()}

	oModel := MPFormModel():New('OFIA551')
	oModel:SetDescription(STR0031) // "Configurações Priorização de Atendimento" 

	oStructAgendamento := oSubModAgendamento:GetModel()
	oStructOrdemServico := oSubModOrdemServico:GetModel()

	oSubModGeracaoSenha := OA5510112_StructGeracaoSenha(oModel)
	oStructGeracaoSenha := oSubModGeracaoSenha:GetModel()
	oStructGeracaoSenha:addTrigger('GESE_TPCONTRATO', "GESE_TPCONTRATO", {|| .t.}, {|oModel, cField, xValue, xOldValue| OA5510192_BuscaDescricaoTipoContrato(oModel, cField, xValue, xOldValue)})
	bLoadModGeracaoSenha := {|| OA5510142_LoadModelGeracaoSenha()}

	oModel:AddFields('MASTER', NIL, oStructMaster,,,bLoadModMaster)
	oModel:GetModel('MASTER'):SetDescription("MASTER")

	oModel:AddFields('TABAGE', 'MASTER', oStructAgendamento,,, bLoadModAgendamento)
	oModel:GetModel('TABAGE'):SetDescription(STR0003) // Agendamento

	oModel:AddFields('TABOS', 'MASTER', oStructOrdemServico,,, bLoadModOrdemServico)
	oModel:GetModel('TABOS'):SetDescription(STR0004) // Ordem de Serviço

	oModel:AddGrid("TABGESE","MASTER", oStructGeracaoSenha,,,,,bLoadModGeracaoSenha)
	oModel:GetModel('TABGESE'):SetDescription(STR0035) // "Prioridade de contratos"
	oModel:GetModel('TABGESE'):SetOptional(.T.)
	
	oModel:AddFields("TABACCLI","MASTER", oStructAcompanhaCliente,,,bLoadModAcompanhaCliente)
	oModel:GetModel('TABACCLI'):SetDescription(STR0045) // "Tempo de reapresentação da tela de chamadas no Painel do Cliente"

	oModel:AddGrid("TABCAAGE","MASTER", oStructCanalAgendamento,,,,,bLoadModCanalAgendamento)
	oModel:GetModel('TABCAAGE'):SetDescription(STR0049) // "Canal Agendamento por filial"
	oModel:GetModel('TABCAAGE'):SetOptional(.T.)

	oModel:AddFields("TABTOL","MASTER", oStructTempoTolerancia,,,bLoadModTempoTolerancia)
	oModel:GetModel('TABTOL'):SetDescription(STR0065) // "Tempo de Tolerância"

	oModel:AddFields("TABSEQ","MASTER", oStructSequencialSenha,,,bLoadModSequencialSenha)
	oModel:GetModel('TABSEQ'):SetDescription(STR0066) // "Sequencial de Senha"

	oModel:GetModel("TABGESE"):SetUniqueLine({"GESE_TPCONTRATO"})
	oModel:GetModel("TABCAAGE"):SetUniqueLine({"AAGE_FILIAL"})
	oModel:SetPrimaryKey({})
	oModel:InstallEvent("OFIA551EVDEF", /*cOwner*/, oEveDef)
Return oModel

/*/{Protheus.doc} ViewDef
	Definicao da Interface dos Dados

	@author  Bruno Hebeler Forcato
	@since   30/03/2026
/*/
Static Function ViewDef()
	Local oModel := FWLoadModel("OFIA551")
	Local oView	 := FWFormView():New()

	Local oSubModAgendamento := OA5510012_StructAgendamento()
	Local oStructAgendamento := oSubModAgendamento:GetView()

	Local oSubModOrdemServico := OA5510032_StructOrdemServico()
	Local oStructOrdemServico := oSubModOrdemServico:GetView()

	Local oSubModMaster := OA5510092_StructMaster()
	Local oStructMaster := oSubModMaster:GetView()

	Local oSubModGeracaoSenha := OA5510112_StructGeracaoSenha()
	Local oStructGeracaoSenha := oSubModGeracaoSenha:GetView()

	Local oSubModAcompanhaCliente := OA5510152_StructAcompanhaCliente()
	Local oStructAcompanhaCliente := oSubModAcompanhaCliente:GetView()

	Local oSubModTempoTolerancia := OA5510202_StructTempoTolerancia()
	Local oStructTempoTolerancia := oSubModTempoTolerancia:GetView()

	Local oSubModSequencialSenha := OA5510222_StructSequencialSenha()
	Local oStructSequencialSenha := oSubModSequencialSenha:GetView()

	Local oSubModCanalAgendamento := OA5510172_StructCanalAgendamento()
	Local oStructCanalAgendamento := oSubModCanalAgendamento:GetView()

	oView:SetModel(oModel)

	// Vincula estruturas às seções do modelo
	oView:AddField('VIEW_AGE', oStructAgendamento, 'TABAGE')
	oView:AddField('VIEW_OS', oStructOrdemServico, 'TABOS')

	// Criao dos containers
	oView:CreateHorizontalBox('BOX', 100)
	oView:CreateFolder('FOLDER', 'BOX')

	// Cria as abas (sheets)
	oView:AddSheet('FOLDER', 'FOLDER_AGE', STR0005) // Diario da Oficina

	// Cria os boxes dentro das abas
	oView:CreateHorizontalBox('BOX_TABAGE', 30,,,'FOLDER', 'FOLDER_AGE')
	oView:CreateHorizontalBox('BOX_TABOS', 70,,,'FOLDER', 'FOLDER_AGE')

	// Define o vnculo entre os fields e os boxes
	oView:SetOwnerView('VIEW_AGE', 'BOX_TABAGE')
	oView:SetOwnerView('VIEW_OS', 'BOX_TABOS')

	// Títulos das seções
	oView:EnableTitleView('VIEW_AGE', STR0003) // Agendamento
	oView:EnableTitleView('VIEW_OS', STR0004) // Ordem de Serviço


	oView:AddField('VIEW_MASTER', oStructMaster, 'MASTER')

	oView:AddSheet('FOLDER', 'ABA_PRIORIZACAO', STR0034) // "Priorização de Atendimento"

	oView:CreateHorizontalBox('BOX_GERACAO', 33,,,'FOLDER', 'ABA_PRIORIZACAO')
	oView:CreateHorizontalBox('BOX_PARAMETROS', 33,,,'FOLDER', 'ABA_PRIORIZACAO')
	oView:CreateHorizontalBox('BOX_CANAL', 34,,,'FOLDER', 'ABA_PRIORIZACAO')

	oView:CreateVerticalBox("BOX_ACOMPANHA", 46, "BOX_PARAMETROS", , 'FOLDER', 'ABA_PRIORIZACAO')
	oView:CreateVerticalBox("BOX_TEMPOTOLERANCIA", 27, "BOX_PARAMETROS", , 'FOLDER', 'ABA_PRIORIZACAO')
	oView:CreateVerticalBox("BOX_SEQSENHA", 27, "BOX_PARAMETROS", , 'FOLDER', 'ABA_PRIORIZACAO')

	oView:AddGrid('VIEW_TABGESE', oStructGeracaoSenha, 'TABGESE')
	oView:SetOwnerView('VIEW_TABGESE', 'BOX_GERACAO')

	oView:AddField('VIEW_TABACCLI', oStructAcompanhaCliente, 'TABACCLI')
	oView:SetOwnerView('VIEW_TABACCLI', 'BOX_ACOMPANHA')

	oView:AddField('VIEW_TABTOL', oStructTempoTolerancia, 'TABTOL')
	oView:SetOwnerView('VIEW_TABTOL', 'BOX_TEMPOTOLERANCIA')

	oView:AddField('VIEW_TABSEQ', oStructSequencialSenha, 'TABSEQ')
	oView:SetOwnerView('VIEW_TABSEQ', 'BOX_SEQSENHA')

	oView:AddGrid('VIEW_TABCAAGE', oStructCanalAgendamento, 'TABCAAGE')
	oView:SetOwnerView('VIEW_TABCAAGE', 'BOX_CANAL')

	oView:SetOwnerView('VIEW_MASTER', 'BOX_GERACAO')

	oView:EnableTitleView('VIEW_MASTER', STR0035) // ""Prioridade de contratos""
	oView:EnableTitleView('VIEW_TABACCLI', STR0033) // "Tempo de reapresentação da tela de chamadas no Painel do Cliente"
	oView:EnableTitleView('VIEW_TABTOL', STR0065) // "Tempo de Tolerância"
	oView:EnableTitleView('VIEW_TABSEQ', STR0066) // "Sequencial de Senha"
	oView:EnableTitleView('VIEW_TABCAAGE', STR0049) // "Canal Agendamento por filial"

	oView:SetModified(.T.)
Return oView

/*/{Protheus.doc} OA5510012_StructAgendamento
	Model da seção Agendamento do Diario da Oficina
	@type  Static Function
	@author Bruno Forcato
	@since 11/02/2026
	/*/
Static Function OA5510012_StructAgendamento()
	local oStructAgendamento := OFDMSStruct():new()

	oStructAgendamento:AddField(;
		{;
			{'cTitulo', STR0008},; // "Quantidade máxima de agendamento para o mesmo veículo"
			{'cIdField', 'AGE_MULTIAGEN'},;
			{ 'cTipo'      , 'N' },;
			{ 'nTamanho'   , 2 },;
			{ 'cPicture'   , '@E 9999' } ,;
			{'lObrigat', .T. },;
			{'bValid', { |a,b,c,d| OA5510082_ValidaValorMinimo(a,b,c,d)}},;
			{'cTooltip', STR0009}; // "Define a quantidade máxima de agendamento permitida para o mesmo veiculo"
		};
	)

	oStructAgendamento:AddField(;
		{;
			{'cTitulo', STR0012},; // Verifica existência de agendamento nas filiais
			{'cIdField', 'AGE_EXISTAGEN'},;
			{'nTamanho', 1},;
			{'bValid', { |a,b,c,d| OA5510062_ValidaOpcao(a,b,c,d, "1,2")}},;
			{'aComboValues', {"1="+ STR0014, "2=" + STR0015}},; //"Apenas filial corrente", "Todas as Filiais"
			{'lObrigat', .T.},;
			{'cTooltip', STR0013}; // Quando habilitado (dependente do Parâmetro 1 = Sim), este parâmetro determina se o sistema deverá verificar a existência de agendamentos somente na filial corrente ou em todas as filiais cadastradas.
		};
	)
Return oStructAgendamento

/*/{Protheus.doc} OA5510022_LoadModelAgendamento
	@type  Static Function
	@author Bruno Forcato
	@since 11/02/2026
	/*/
Static Function OA5510022_LoadModelAgendamento()
	local aRetorno := {}
	local oCfg := OfScaniaConfig():New("DIAOFI", "OFIA551")
	local oJson := oCfg:getConfigWithNoEnviroment()
	local lTemJson := (ValType(oJson) == "J")
	local nX := 0

	if !lTemJson .or. !oJson:HasProperty(aTabAgendamento[1])
		aadd(aRetorno, 9999) //AGE_MULTIAGEN
		aadd(aRetorno, '1') //AGE_EXISTAGEN
	else
		for nX := 1 to len(aTabAgendamento)
			aadd(aRetorno, oJson[aTabAgendamento[nx]])
		next
	endif
	 
	freeObj(oJson)
Return aRetorno

/*/{Protheus.doc} OA5510032_StructOrdemServico
	Model da seção Ordem de serviço da aba Diario da Oficina
	@type  Static Function
	@author Bruno Forcato
	@since 11/02/2026
	/*/
Static Function OA5510032_StructOrdemServico()
	local oSubModOrdemServico := OFDMSStruct():new()

	oSubModOrdemServico:AddField(;
		{;	
			{'cTitulo', STR0018},; // Validar intervalo entre criação do agendamento e data/hora agendada?
			{'cIdField', "OS_VALIDINTERAGE" },;
			{'nTamanho', 1},;
			{'aComboValues', {"1="+ STR0010, "2=" + STR0011}},;	//Sim, Não
			{'bValid', { |a,b,c,d| OA5510062_ValidaOpcao(a,b,c,d, "1,2")}},;
			{'lObrigat', .T. },;
			{'cTooltip', STR0019};	// Define se o sistema deve validar a diferença entre a data/hora de criação do agendamento e a data/hora prevista para o atendimento, garantindo um intervalo mínimo entre esses dois momentos.
		};
	)

	oSubModOrdemServico:AddField(;
		{;	
			{'cTitulo', STR0020},;	// Intervalo mínimo permitido (em horas)
			{'cIdField', "OS_INTERMIN" },;
			{ 'cTipo'      , 'N' },;
			{ 'nTamanho'   , 2 },;
			{ 'cPicture'   , '@E 99' } ,;
			{'lObrigat', .T. },;
			{'bWhen', {|| FWFldGet('OS_VALIDINTERAGE') == '1' }},;
			{'cTooltip', STR0021};	// Define a quantidade mínima de horas exigida entre a criação do agendamento e a data/hora prevista para o atendimento.
		};
	)

	oSubModOrdemServico:AddField(;
		{;	
			{'cTitulo', STR0022},;	// Validade do agendamento antes do horário agendado (em horas)
			{'cIdField', "OS_VALIDANTAGEHORA" },;
			{ 'cTipo'      , 'N' },;
			{ 'nTamanho'   , 2 },;
			{ 'cPicture'   , '@E 99' } ,;
			{'lObrigat', .T. },;
			{'cTooltip', STR0023};	// Define por quantas horas antes da data/hora agendada o agendamento será considerado válido para abertura da Ordem de Serviço.
		};
	)

	oSubModOrdemServico:AddField(;
		{;	
			{'cTitulo', STR0024},;	// Validade do agendamento após o horário agendado (em horas)
			{'cIdField', "OS_VALIDDEPAGEHORA" },;
			{ 'cTipo'      , 'N' },;
			{ 'nTamanho'   , 2 },;
			{ 'cPicture'   , '@E 99' } ,;
			{'lObrigat', .T. },;
			{'cTooltip', STR0025};	// Define por quantas horas após a data/hora agendada o agendamento será considerado válido para abertura da Ordem de Serviço.
		};
	)
	
Return oSubModOrdemServico

/*/{Protheus.doc} OA5510042_LoadModelOrdemServico
	@type  Static Function
	@author Bruno Forcato
	@since 11/02/2026
	/*/
Static Function OA5510042_LoadModelOrdemServico()
	local aRetorno := {}
	local oCfg := OfScaniaConfig():New("DIAOFI","OFIA551")
	local oJson := oCfg:getConfigWithNoEnviroment()
	local lTemJson := (ValType(oJson) == "J")
	local nX := 0

	if !lTemJson .or. !oJson:HasProperty(aTabOrdemServico[1])
		aadd(aRetorno, '1') //OS_VALIDINTERAGE
		aadd(aRetorno, 12) // OS_INTERMIN
		aadd(aRetorno, 72) // OS_VALIDANTAGEHORA
		aadd(aRetorno, 72) // OS_VALIDDEPAGEHORA
	else
		for nX := 1 to len(aTabOrdemServico)
			aadd(aRetorno, oJson[aTabOrdemServico[nx]])
		next
	endif
	 
	freeObj(oJson)
Return aRetorno

/*/{Protheus.doc} OA55100052_ValidaOpcao
	Valida se o valor atual esta nas opcoes disponiveis

	@author Bruno Forcato
	@since 11/02/2026
	/*/
Function OA5510062_ValidaOpcao(oModel, cField, xValue, xValueAntigo, cOpcoesDisponiveis)
	Local aOpcoes	:= StrTokArr(cOpcoesDisponiveis,",")
	Local nX		:= 1
	Local lRetorno	:= .F.

	For nX := 1 to Len(aOpcoes)
		If xValue == aOpcoes[nX]
			lRetorno := .T.
			Exit
		EndIf
	Next nX
Return lRetorno

/*/{Protheus.doc} OA5510072_ValidaMultiplosAgendamentos
	Valida se existe agendamento para o veiculo

	@author Bruno Forcato
	@since 11/02/2026
	/*/
Function OA5510072_ValidaMultiplosAgendamentos(cChassi)
	local oOfScanicaConfig := OfScaniaConfig():New("DIAOFI", "OFIA551")
	local oConfig := oOfScanicaConfig:getConfigWithNoEnviroment()
	local lTemJson := (ValType(oConfig) == "J")
	local cAlias := GetNextAlias()
	Local cQuery    := ""
	local cFixQuery := ""
	local oStatement := FWPreparedStatement():new()
	Local nLimite := oConfig[aTabAgendamento[1]]
	Local lFilial := (oConfig[aTabAgendamento[2]] == '1')
	Local nQtd    := 0
	Local cNumIde := ""
	local cFilialAchada := ""

	if !lTemJson .or. !oConfig:HasProperty(aTabAgendamento[1])
		return .t.
	endif+

	cQuery := ""
	cQuery += " SELECT COUNT(*) QTD, MIN(VSO_NUMIDE) NUMIDE, MIN(VSO_FILIAL) FILIAL "
	cQuery += " FROM " + RetSQLName("VSO") + " VSO "
	cQuery += " WHERE VSO_STATUS IN (1, 5) "
	cQuery += "   AND VSO_GETKEY = ? "

	If lFilial
		cQuery += " AND VSO_FILIAL = ? "
	EndIf
	
	cQuery += "   AND VSO.D_E_L_E_T_ = ' ' "

	oStatement:setQuery(cQuery)
	oStatement:setString(1, cChassi)

	If lFilial
		oStatement:setString(2, FWxFilial("VSO"))
	EndIf

	cFixQuery := oStatement:getFixQuery()

	dbUseArea(.T., "TOPCONN", TcGenQry(,, cFixQuery), cAlias, .F., .T.)
	If !(cAlias)->(EoF())
		nQtd    := (cAlias)->QTD
		cNumIde := AllTrim((cAlias)->NUMIDE) 
		cFilialAchada := AllTrim((cAlias)->FILIAL)
	EndIf
	(cAlias)->(dbCloseArea())

	If nLimite > 0 .and. nQtd >= nLimite
		FMX_HELP(STR0026, STR0027 + cNumIde + STR0028 + cFilialAchada, STR0029) // Problema , O veículo informado já possui um agendamento em aberto nesta filial (Agendamento nº + ) que está registrado na filial , "Já existe um agendamento para este veículo. Para continuar, cancele o agendamento atual ou reagende para uma nova data e horário.")
		Return .F.
	EndIf
return .t.


/*/{Protheus.doc} OA5510082_ValidaValorMinimo
	Valida se o valor atual esta nas opcoes disponiveis

	@author Bruno Forcato
	@since 12/02/2026
	/*/
Function OA5510082_ValidaValorMinimo(oModel, cField, xValue, xValueAntigo)
Return xValue > 0

/*/{Protheus.doc} OA5510092_StructMaster
	@type  Static Function
	@author Bruno Forcato
	@since 30/03/2026
/*/
Static Function OA5510092_StructMaster()
	local oStructMaster := OFDMSStruct():new()

	oStructMaster:AddField(;
		{;
			{'cTitulo', "ID"},;
			{'cIdField', "MASTER_ID"},;
			{'nTamanho', 1},;
			{'lObrigat', .F.},;
			{'cTooltip', ""};
		};
	)
Return oStructMaster

/*/{Protheus.doc} OA5510102_LoadModelMaster
	@type  Static Function
	@author Bruno Forcato
	@since 30/03/2026
/*/
Static Function OA5510102_LoadModelMaster()
	local aRetorno := {}

	aadd(aRetorno, space(1)) //MASTER_ID
Return aRetorno

/*/{Protheus.doc} OA5510112_StructGeracaoSenha
	Model da grid de geração de senha do priorização de atendimento
	@type  Static Function
	@author Bruno Forcato
	@since 30/03/2026
	/*/
Static Function OA5510112_StructGeracaoSenha(oModel)
	local oStructGeracaoSenha := OFDMSStruct():new()

	oStructGeracaoSenha:AddField(;
		{;
			{'cTitulo', STR0037},; // "Ordem"
			{'cIdField', "GESE_ORDEM"},;
			{'nTamanho', 2},;
			{'lObrigat', .F.},;
			{'lCanChange', .F.},;
			{'cTipo', 'N'},;
			{'cTooltip', STR0038},;	// "Ordem da prioridade dos contratos"
			{'bInit', {|oModel| oModel:getModel():getModel('TABGESE'):Length() + 1 }};
		};
	)

	oStructGeracaoSenha:AddField(;
		{;
			{'cTitulo', STR0041},; // "Tipo de contrato"
			{'cIdField', 'GESE_TPCONTRATO'},;
			{'nTamanho', 8},;
			{'lObrigat', .T.},;
			{'cLookUp', 'VX5BRA'},;
			{'cTooltip', STR0042}; // "Tipo de contrato baseado no codigo da VX5"
		};
	)

	oStructGeracaoSenha:AddField(;
		{;
			{'cTitulo', STR0043},; // "Descrição"
			{'cIdField', "GESE_DESC"},;
			{'nTamanho', 200},;
			{'lObrigat', .F.},;
			{'lCanChange', .F.},;
			{'cTooltip', STR0044};	// "Descrição do Tipo de Contrato"
		};
	)
Return oStructGeracaoSenha

/*/{Protheus.doc} OA5510142_LoadModelGeracaoSenha
	@type  Static Function
	@author Bruno Forcato
	@since 30/03/2026
	/*/
Static Function OA5510142_LoadModelGeracaoSenha()
	local aRetorno := {}
	local aAux := NIL
	Local oCfg		:= OfScaniaConfig():New("PRIOATE","OFIA551")
	Local oJson		:= oCfg:getConfigWithNoEnviroment()
	Local lTemJson	:= (ValType(oJson) == "J")
	Local cArray	:= "GESE"
	Local nLine		:= 0
	Local nField	:= 0
	Local oItem		:= nil
	Local oGrid		:= oModel:GetModel():getModel("TABGESE")

	If lTemJson .and. !empty(oJson[cArray]) .and. Len(oJson[cArray]) > 0
		For nLine := 1 to Len(oJson[cArray])
			oItem := oJson[cArray][nLine]
			oGrid:AddLine()
			oGrid:GoLine(oGrid:Length())

			For nField := 1 to Len(aTabGeracaoSenha)
				oGrid:SetValue(aTabGeracaoSenha[nField], oItem[aTabGeracaoSenha[nField]])
			Next
		
			oGrid:LoadValue("GESE_ORDEM", oItem["GESE_ORDEM"])
			oGrid:LoadValue("GESE_TPCONTRATO", oItem["GESE_TPCONTRATO"])
			oGrid:LoadValue("GESE_DESC", oItem["GESE_DESC"])
		Next
	Else
		aAux    := Array(3)
		aAux[1] := 1
		aAux[2] := space(5)
		aAux[3] := space(99)

		aadd(aRetorno, {0, aClone(aAux)})
	Endif
Return aRetorno

/*/{Protheus.doc} OA5510152_StructAcompanhaCliente
	Model da seção Ordem de serviço da aba Diario da Oficina
	@type  Static Function
	@author Bruno Forcato
	@since 30/03/2026
	/*/
Static Function OA5510152_StructAcompanhaCliente()
	local oSubModAcompanhaCliente := OFDMSStruct():new()

	oSubModAcompanhaCliente:AddField(;
		{;	
			{'cTitulo', STR0047},; // "Identificação no painel"
			{'cIdField', "ACCLI_IDENTPAINEL" },;
			{'nTamanho', 1},;
			{'aComboValues', {"1="+ STR0039, "2=" + STR0040}},;	// "Placa", "Senha"
			{'bValid', { |a,b,c,d| OA5510062_ValidaOpcao(a,b,c,d, "1,2")}},;
			{'lObrigat', .T. },;
			{'cTooltip', STR0048};	// "Painel deve usar essa configuração nas chamadas de senhas, para qual exibir"
		};
	)

	oSubModAcompanhaCliente:AddField(;
		{;	
			{'cTitulo', STR0045},;  // "Tempo de reapresentação da tela de chamadas (segundos)"
			{'cIdField', "ACCLI_TEMPCHAMADAS" },;
			{'nTamanho', 3},;
			{'lObrigat', .T. },;
			{'cTooltip', STR0046}; // "Definir o intervalo em que a tela de chamada de senhas será exibida automaticamente"
		};
	)

Return oSubModAcompanhaCliente

/*/{Protheus.doc} OA5510162_LoadModelAcompanhaCliente
	@type  Static Function
	@author Bruno Forcato
	@since 30/03/2026
	/*/
Static Function OA5510162_LoadModelAcompanhaCliente()
	local aRetorno := {}
	local oCfg := OfScaniaConfig():New("PRIOATE","OFIA551")
	local oJson := oCfg:getConfigWithNoEnviroment()
	local lTemJson := (ValType(oJson) == "J")
	local nX := 0

	if !lTemJson .or. !oJson:HasProperty(aTabAcompanhaCliente [1]) .or. empty(oJson[aTabAcompanhaCliente [1]])
		aadd(aRetorno, '2') //ACCLI_IDENTPAINEL
		aadd(aRetorno, space(3)) //ACCLI_TEMPCHAMADAS
	else
		for nX := 1 to len(aTabAcompanhaCliente )
			aadd(aRetorno, oJson[aTabAcompanhaCliente [nx]])
		next
	endif
Return aRetorno

/*/{Protheus.doc} OA5510172_StructCanalAgendamento
	Model da seção Ordem de serviço da aba Diario da Oficina
	@type  Static Function
	@author Bruno Forcato
	@since 30/03/2026
	/*/
Static Function OA5510172_StructCanalAgendamento()
	local oSubModCanalAgendamento := OFDMSStruct():new()

	oSubModCanalAgendamento:AddField(;
		{;	
			{'cTitulo', STR0050},;  // "Filial"
			{'cIdField', "AAGE_FILIAL" },;
			{'nTamanho', 4},;
			{'cPicture', '@E 9999'},;
			{'lObrigat', .T. },;
			{'cTooltip', STR0051}; // "Filial do canal de agendamento"
		};
	)

	oSubModCanalAgendamento:AddField(;
		{;	
			{'cTitulo', STR0052},; // "Canal de Agendamento"
			{'cIdField', "AAGE_CANALAGENDA" },;
			{'nTamanho', 99},;
			{'lObrigat', .T. },;
			{'cTooltip', STR0053}; // "Valor que define o canal de agendamento"
		};
	)
Return oSubModCanalAgendamento

/*/{Protheus.doc} OA5510182_LoadModelCanalAgendamento
	@type  Static Function
	@author Bruno Forcato
	@since 30/03/2026
	/*/
Static Function OA5510182_LoadModelCanalAgendamento()
	local aRetorno := {}
	local aAux := NIL
	Local oCfg		:= OfScaniaConfig():New("PRIOATE","OFIA551")
	Local oJson		:= oCfg:getConfigWithNoEnviroment()
	Local lTemJson	:= (ValType(oJson) == "J")
	Local cArray	:= "AGENDAMENTO"
	Local nLine		:= 0
	Local nField	:= 0
	Local oItem		:= nil
	Local oGrid		:= oModel:GetModel():getModel("TABCAAGE")

	If lTemJson .and. !empty(oJson[cArray]) .and. Len(oJson[cArray]) > 0
		For nLine := 1 to Len(oJson[cArray])
			oItem := oJson[cArray][nLine]
			oGrid:AddLine()
			oGrid:GoLine(oGrid:Length())

			For nField := 1 to Len(aTabCanalAgendamento)
				oGrid:SetValue(aTabCanalAgendamento[nField], oItem[aTabCanalAgendamento[nField]])
			Next
		
			oGrid:LoadValue("AAGE_FILIAL", oItem["AAGE_FILIAL"])
			oGrid:LoadValue("AAGE_CANALAGENDA", oItem["AAGE_CANALAGENDA"])
		Next
	Else
		aAux    := Array(2)
		aAux[1] := space(4)
		aAux[2] := space(99)

		aadd(aRetorno, {0, aClone(aAux)})
	Endif
Return aRetorno

/*/{Protheus.doc} OA5510192_BuscaDescricaoTipoContrato
	Busca a descrição do tipo de contrato

	@author Bruno Forcato
	@since 15/04/2026
/*/
Static Function OA5510192_BuscaDescricaoTipoContrato(oModel, cField, xValue, xOldValue)
	DbSelectArea("VX5")
	DbSetOrder(1)
	if DbSeek(xFilial("VX5") + "107" + xValue)
		oModel:SetValue("GESE_DESC", Alltrim(VX5->VX5_DESCRI))
	else
		oModel:SetValue("GESE_DESC", '')
	endif
Return

/*/{Protheus.doc} OA5510202_StructTempoTolerancia
	Model da seção TempoTolerancia da Priorização de Atendimento
	@type  Static Function
	@author Bruno Forcato
	@since 11/02/2026
	/*/
Static Function OA5510202_StructTempoTolerancia()
	local oStructTempoTolerancia := OFDMSStruct():new()

	oStructTempoTolerancia:AddField(;
		{;
			{'cTitulo', STR0067},; // "Tolerancia de chegada do agendamento"
			{'cIdField', 'TTO_TEMPOCHEGADA'},;
			{'nTamanho', 1},;
			{'aComboValues', {"1="+ "30 minutos", "2=" + "1 hora", "3=" + "2 horas", "4=" + "4 horas", "5=" + "Período integral"}},;	// "30 minutos", "1 hora", "2 horas", "4 horas", "Período integral"
			{'bValid', { |a,b,c,d| OA5510062_ValidaOpcao(a,b,c,d, "1,2,3,4,5")}},;
			{'lObrigat', .T. },;
			{'cTooltip', STR0067}; // "Tolerancia de chegada do agendamento"
		};
	)
Return oStructTempoTolerancia

/*/{Protheus.doc} OA5510212_LoadModelTempoTolerancia
	@type  Static Function
	@author Bruno Forcato
	@since 11/02/2026
	/*/
Static Function OA5510212_LoadModelTempoTolerancia()
	local aRetorno := {}
	local oCfg := OfScaniaConfig():New("PRIOATE", "OFIA551")
	local oJson := oCfg:getConfigWithNoEnviroment()
	local lTemJson := (ValType(oJson) == "J")
	local nX := 0

	if !lTemJson .or. !oJson:HasProperty(aTabTempoTolerancia[1])
		aadd(aRetorno, '1') //TTO_TEMPOCHEGADA
	else
		for nX := 1 to len(aTabTempoTolerancia)
			aadd(aRetorno, oJson[aTabTempoTolerancia[nx]])
		next
	endif
	 
	freeObj(oJson)
Return aRetorno

/*/{Protheus.doc} OA5510222_StructSequencialSenha
	Model da seção Sequencial Senha da Priorização de Atendimento
	@type  Static Function
	@author Bruno Forcato
	@since 11/02/2026
	/*/
Static Function OA5510222_StructSequencialSenha()
	local oStructSequencialSenha := OFDMSStruct():new()

	oStructSequencialSenha:AddField(;
		{;
			{'cTitulo', STR0068},; // "Periodicidade de reset do sequencial de senhas"
			{'cIdField', 'SESE_TEMPORESETSENHA'},;
			{'nTamanho', 1},;
			{'aComboValues', {"1="+ "Diário", "2=" + "Semanal", "3=" + "Mensal", "4=" + "Não Resetar"}},;	// "Diário", "Semanal", "Mensal", "Não Resetar"
			{'bValid', { |a,b,c,d| OA5510062_ValidaOpcao(a,b,c,d, "1,2,3,4")}},;
			{'lObrigat', .T. },;
			{'cTooltip', STR0068}; // "Periodicidade de reset do sequencial de senhas"
		};
	)
Return oStructSequencialSenha

/*/{Protheus.doc} OA5510232_LoadModelSequencialSenha
	@type  Static Function
	@author Bruno Forcato
	@since 11/02/2026
	/*/
Static Function OA5510232_LoadModelSequencialSenha()
	local aRetorno := {}
	local oCfg := OfScaniaConfig():New("PRIOATE", "OFIA551")
	local oJson := oCfg:getConfigWithNoEnviroment()
	local lTemJson := (ValType(oJson) == "J")
	local nX := 0

	if !lTemJson .or. !oJson:HasProperty(aTabSequencialSenha[1])
		aadd(aRetorno, '3') //SESE_TEMPORESETSENHA
	else
		for nX := 1 to len(aTabSequencialSenha)
			aadd(aRetorno, oJson[aTabSequencialSenha[nx]])
		next
	endif
	 
	freeObj(oJson)
Return aRetorno