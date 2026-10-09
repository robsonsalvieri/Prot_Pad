#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'OFIA541.CH'

static oView
static oModel
static aTab1 := {"CFG_AMBIENTE", "CFG_INTEGRACAO_ATIVA", "CFG_TPAUT", "CFG_CLIENTEID", "CFG_CLIENTESECRET", "CFG_URL", "CFG_AUTHPATH", "CFG_GRANTTYPE", "CFG_CONTTYPE"}
static aTab2 := {"CFG_TPAUT2", "CFG_URLBASE", "CFG_ENDPOINT"}
static aTab3 := {"CFG_PRECADAUT", "CFG_LOCPAD", "OFIXX001", "OFIOM010", "OFIOM140", "CFG_CODMAR"}
static aScrm := {"SCRM_AMBIENTE","SCRM_INTEGRACAO_ATIVA", "SCRM_PSW_WEBSERVICE","SCRM_USER_WEBSERVICE","SCRM_CLIENTES_URL_WEBSERVICE","SCRM_VEICULOS_URL_WEBSERVICE"}
static aGatScrm := {"SCRM_SA1","SCRM_VCF", "SCRM_VV1", "SCRM_VO1", "SCRM_VS1", "SCRM_SF2"}
static aARMSToken	:= {"ARMS_AMBIENTE","ARMS_INTEGRACAO_ATIVA","ARMS_TPAUT","ARMS_CLIENTID","ARMS_CLIENTSEC","ARMS_TOKEN_URL","ARMS_GRANTTYPE","ARMS_SCOPE","ARMS_CONTTYPE"}
static aARMSCons	:= {"ARMS_TPAUT2", "ARMS_URLBASE", "ARMS_ENDPOINT"}	
static aCotoToken 	:= {"COTO_AMBIENTE","COTO_INTEGRACAO_ATIVA","COTO_TPAUT","COTO_CLIENTEID","COTO_CLIENTESECRET","COTO_URL","COTO_USERNAME","COTO_PASSWORD","COTO_GRANTTYPE","COTO_CONTENTTYPE"}
static aCoto 		:= {"COTO_TPAUT2", "COTO_URLBASE","COTO_ENDPOINT"}
static aCotoGeneral := {"COTO_OBTERTPCONT","COTO_QTDHEVENTO","COTO_MARCAVEIINT","COTO_SRVCHECK","COTO_MAXTENT"}
static aCotoGridConcessionaria := {"COTO_GCONC_FILIAL", "COTO_GCONC_ID"}
static aCotoGridTPContratos := {"COTO_GTPCONT_TPCONTRATO"}
static aCotoGridDePara := {"COTO_CODPAUSA","COTO_CODINTERRUPCAO"}


/*/ {Protheus.doc} OFIA541
	Tela Configurações Scania

	@author  Guilherme Santos
	@since   25/09/2025
	@version 12.1.2610
/*/
Function OFIA541()
	
	Local aEnableButtons	:=	{	{ .F., Nil }, { .F., Nil }, ;
									{ .F., Nil }, { .F., Nil }, ;
									{ .F., Nil }, { .F., Nil }, ;
									{ .T., Nil }, { .T., Nil }, ;
									{ .F., Nil }, { .F., Nil }, ;
									{ .F., Nil }, { .F., Nil }, ;
									{ .F., Nil }, { .F., Nil }		} //"Confirmar"###"Fechar"


	Private oCfgScInt 	:= OfScaniaConfig():New("","OFIA541")
	Private cFiltroVX5 := "107"

	FWExecView( STR0001 , "OFIA541", MODEL_OPERATION_UPDATE, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, aEnableButtons, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, /*oModel*/ )
Return NIL

/*/{Protheus.doc} ModelDef
Definicao do Modelo dos Dados

	@author  Guilherme Santos
	@since   25/09/2025
	@version 12.1.2610
/*/
Static Function ModelDef()
	Local oSubMod01		:= OA5410001L_GetStr01()
	Local oStruct01		:= nil
	Local bLoadMod01	:= {|| OA5410002L_LoadModelAutenticacaoScobModel01()}

	Local oSubMod02		:= OA5410004L_GetStructConsultaVeiculoScobScania()
	Local oStruct02		:= nil
	Local bLoadMod02	:= {|| OA5410005L_LoadModelEndpointVeiculosScaniaModel02()}

	Local oSubMod03		:= OA5410006L_GetStructSecaoGerais03()
	Local oStruct03		:= nil
	Local bLoadMod03	:= {|| OA5410007L_LoadModelSecaoGeraisModel03()}

	local oSubMod04SCRM := OA5410014J_GetStructSecaoGerais04Scrm()
	local oStruct04Scrm := nil
	local bLoadMod04Scrm := {|| OA5410015J_LoadModel04Scrm()}

	local oSubMod05Scrm := OA5410017J_Struct05ScrmGerais()
	local oStruct05Scrm := nil
	local bLoadMod05Scrm := {|| OA5410018J_LoadModel05Scrm()}

	local oSubMod06Scrm := OA5410023J_GetStruct06Scrm()
	local oStruct06Scrm := nil
	local bLoadMod06Scrm := {|| OA5410024J_LoadModel06Scrm()}

	local oSubMod07Coto := OA54100262_Struct07CotoToken()
	local oStruct07Coto := nil
	local bLoadMod07Coto := {|| OA54100272_LoadModel07CotoToken()}

	local oSubMod08Coto := OA54100282_Struct08Coto()
	local oStruct08Coto := nil
	local bLoadMod08Coto := {|| OA54100292_LoadModel08Coto()}

	local oSubMod09Coto := OA54100302_Struct09CotoGeneral()
	local oStruct09Coto := nil
	local bLoadMod09Coto := {|| OA54100312_LoadModel09CotoGeneral()}

	local oSubMod10Coto := OA54100332_Struct10CotoGridConcessionaria()
	local oStruct10Coto := nil
	local bLoadMod10Coto := {|| OA54100342_LoadModel10CotoGridConcessionaria()}

	local oSubMod11Coto := OA54100352_Struct11CotoGridTPContrato()
	local oStruct11Coto := nil
	local bLoadMod11Coto := {|| OA54100362_LoadModel11CotoGridTPContrato()}

	local oSubMod12Coto  := OA54100353_Struct12CotoGridDePara()
	local oStruct12Coto  := nil
	local bLoadMod12Coto := {|| OA54100363_LoadModel12CotoGridDePara()}
	local b12CotoLinePost      := { |oGridModel, nLine| OA5410041M_ValidaLinhaDePara(oGridModel, nLine) }

	// ---------- ARMS: Seção TOKEN / Seção Consulta Contrato ----------
	Local oSubArmsTok	   := OA5410100N_GetStructArmsToken()
	Local oStruToken	   := Nil 
	Local bLoadArmsTok     := {|| OA5410101N_LoadModelArmsToken()}
	Local oSubArmsCons     := OA5410102N_GetStructArmsConsulta()
	Local oStruCons  	   := Nil 
	Local bLoadArmsCons    := {|| OA5410103N_LoadModelArmsConsulta()}

	local oEveDef := OFIA541EVDEF():New()
	oModel		:= MPFormModel():New('OFIA541')
	
	// -- SCOB
	oStruct01 := oSubMod01:GetModel()
	oStruct02 := oSubMod02:GetModel()
	oStruct03 := oSubMod03:GetModel()
	
	// -- SCRM
	oStruct04SCrm := oSubMod04SCRM:GetModel()
	oStruct05Scrm := oSubMod05Scrm:GetModel()
	oStruct06Scrm := oSubMod06Scrm:GetModel()

	// -- ARMS
	oStruToken		:= oSubArmsTok:GetModel()
	oStruCons		:= oSubArmsCons:GetModel()

	// -- Control Tower
	oStruct07Coto 	:= oSubMod07Coto:GetModel()
	oStruct08Coto 	:= oSubMod08Coto:GetModel()
	oStruct09Coto 	:= oSubMod09Coto:GetModel()
	oStruct10Coto 	:= oSubMod10Coto:GetModel()
	oStruct11Coto 	:= oSubMod11Coto:GetModel()
	oStruct12Coto 	:= oSubMod12Coto:GetModel()

	// -- GATILHOS
	oStruct01:addTrigger('CFG_AMBIENTE', "CFG_AMBIENTE", {|| .t.}, {|oModel, cField, xValue, xOldValue| OA5410011J_TrocaDadosDoScobDeAcordoComOAmbienteSelecionado(oModel, cField, xValue, xOldValue)})
	oStruct04Scrm:addTrigger('SCRM_AMBIENTE', 'SCRM_AMBIENTE', {|| .t.}, {|oModel, cField, xValue, xOldValue| OA5410019J_TrocaDadosScrm(oModel, cField, xValue, xOldValue)})
	oStruToken:addTrigger('ARMS_AMBIENTE'		, 'ARMS_AMBIENTE'	, {|| .t.}, {|oModel, cField, xValue, xOldValue| OA5410104N_TrocaDadosArms(oModel, cField, xValue, xOldValue)  })
	oStruct07Coto:addTrigger('COTO_AMBIENTE', "COTO_AMBIENTE", {|| .t.}, {|oModel, cField, xValue, xOldValue| OA54100322_TrocaDadosDeAmbienteControlTower(oModel, cField, xValue, xOldValue)})	

	oModel:SetDescription(STR0032)		//Configurações Montadora

	//Secao TOKEN
	oModel:AddFields('TAB1', NIL, oStruct01, /* bPreLoad */, /* bPost */, bLoadMod01)
	oModel:GetModel('TAB1'):SetDescription(STR0012)		//Token

	//Secao Consulta Chassi Scania
	oModel:AddFields('TAB2', 'TAB1', oStruct02, /* bPreLoad */, /* bPost */, bLoadMod02)
	oModel:GetModel('TAB2'):SetDescription(STR0002)		//Consulta Chassi Scania

	//Secao Gerais
	oModel:AddFields('TAB3', 'TAB1', oStruct03, /* bPreLoad */, /* bPost */, bLoadMod03)
	oModel:GetModel('TAB3'):SetDescription(STR0015)		//Gerais

	//SCRM - Scania
	oModel:AddFields('TAB_SCRM', 'TAB1', oStruct04SCrm, /* bPreLoad */, /* bPost */, bLoadMod04Scrm)
	oModel:GetModel('TAB_SCRM'):SetDescription('SCRM')
	
	oModel:AddFields('TAB_GERAIS_SCRM', 'TAB1', oStruct05Scrm, /* bPreLoad */, /* bPost */, bLoadMod05Scrm)
	oModel:GetModel('TAB_GERAIS_SCRM'):SetDescription(STR0053)  //'Gerais'

	oModel:AddFields('TAB_GATILHOS_SCRM', 'TAB1', oStruct06Scrm, /* bPreLoad */, /* bPost */, bLoadMod06Scrm)
	oModel:GetModel('TAB_GATILHOS_SCRM'):SetDescription(STR0054) //'Gatilhos para envio ao SCRM'

	// ---------- ARMS: Seção TOKEN ----------
	oModel:AddFields('TAB_ARMS', 'TAB1', oStruToken, /*pre*/, /*post*/, bLoadArmsTok)
	oModel:GetModel('TAB_ARMS'):SetDescription(STR0072) // 'ARMS - Token'

	// ---------- ARMS: Seção Consulta Contrato ----------
	oModel:AddFields('TAB_ARMS_CONSULTA', 'TAB_ARMS', oStruCons, /*pre*/, /*post*/, bLoadArmsCons)
	oModel:GetModel('TAB_ARMS_CONSULTA'):SetDescription(STR0073) // 'ARMS - Consulta Contrato'

	//Control Tower
	oModel:AddFields('TAB_TOKEN_COTO', 'TAB1', oStruct07Coto, /* bPreLoad */, /* bPost */, bLoadMod07Coto)
	oModel:GetModel('TAB_TOKEN_COTO'):SetDescription(STR0103) //'Control Tower - Token'
	
	oModel:AddFields('TAB_COTO', 'TAB1', oStruct08Coto, /* bPreLoad */, /* bPost */, bLoadMod08Coto)
	oModel:GetModel('TAB_COTO'):SetDescription(STR0104)  //"Control Tower"

	oModel:AddFields('TAB_GERAIS_COTO', 'TAB1', oStruct09Coto, /* bPreLoad */, /* bPost */, bLoadMod09Coto)
	oModel:GetModel('TAB_GERAIS_COTO'):SetDescription(STR0105)  //"Control Tower - Gerais"

	oModel:AddGrid("TAB_CONCESSIONARIA_COTO","TAB1", oStruct10Coto,,,,, bLoadMod10Coto)
	oModel:GetModel('TAB_CONCESSIONARIA_COTO'):SetDescription(STR0106)  //"Control Tower - ID Concessionária"
	oModel:GetModel('TAB_CONCESSIONARIA_COTO'):SetLoadFilter( { { 'COTO_GCONC_FILIAL', "' '", MVC_LOADFILTER_EQUAL } } )
	oModel:GetModel('TAB_CONCESSIONARIA_COTO'):SetOptional(.T.)

	oModel:AddGrid("TAB_TP_CONTRATO_COTO","TAB1", oStruct11Coto,,,,,bLoadMod11Coto)
	oModel:GetModel('TAB_TP_CONTRATO_COTO'):SetDescription(STR0107)  //"Control Tower - Tipo de Contrato"
	oModel:GetModel('TAB_TP_CONTRATO_COTO'):SetOptional(.T.)
	
	oModel:AddGrid("TAB_DEPARA_COTO", "TAB1", oStruct12Coto,/*bLinePre*/, b12CotoLinePost,,, bLoadMod12Coto)
	oModel:GetModel("TAB_DEPARA_COTO"):SetDescription(STR0110)  // "Control Tower - De/Para Interrupcao"
	oModel:GetModel("TAB_DEPARA_COTO"):SetOptional(.T.)

	oModel:SetPrimaryKey({})

	oModel:InstallEvent("OFIA541EVDEF", /*cOwner*/, oEveDef)

Return oModel

/*/{Protheus.doc} OA5410001L_GetStr01
	Definicao da Struct da Secao Token

	@author  Guilherme Santos
	@since   25/09/2025
	@version 12.1.2610
/*/
Static Function OA5410001L_GetStr01()
	Local oStruct01 := OFDMSStruct():New()

	oStruct01:AddField({	{'cTitulo',	STR0003},;  //'Ambiente'
							{'cIdField', "CFG_AMBIENTE"},;
							{'nTamanho', OA5410009L_GetFieldLen("CFG_AMBIENTE")},;
							{'aComboValues', {"1="+ STR0005, "2=" + STR0006}},;		//'Produo','Homologao'
							{'bValid', { |a,b,c,d| OA5410003L_ValidaOpcao(a,b,c,d, "1,2")}},;
							{'lObrigat', .F.},;
							{'cTooltip', STR0003}}) //'Ambiente'

	oStruct01:AddField({	{'cTitulo', STR0033},; //'Integração Ativa?'
							{'cIdField', "CFG_INTEGRACAO_ATIVA"},;
							{'nTamanho', OA5410009L_GetFieldLen("CFG_INTEGRACAO_ATIVA")},;
							{'aComboValues', {STR0028, STR0029}},; //'Produção','Homologação'
							{'bValid', { |a,b,c,d| OA5410003L_ValidaOpcao(a,b,c,d, "1,2")}},;
							{'lObrigat', .T.},;
							{'cTooltip', STR0055}}) //"Ativa ou desativa integração"

	oStruct01:AddField({	{'cTitulo', STR0004},;  //'Tipo de Autenticação'
							{'cIdField', "CFG_TPAUT" },;
							{'nTamanho', OA5410009L_GetFieldLen("CFG_TPAUT") },;
							{'aComboValues', {"1=Basic Auth"}},;
							{'bValid', { |a,b,c,d| OA5410003L_ValidaOpcao(a,b,c,d, "1")}},;
							{'lObrigat', .F. },;
							{'cTooltip', STR0004}})		//'Tipo de Autenticao'

	oStruct01:AddField({	{'cTitulo', STR0007},;		//'Client ID'
							{'cIdField', "CFG_CLIENTEID"},;
							{'nTamanho', OA5410009L_GetFieldLen("CFG_CLIENTEID")},;
							{'cPicture', '@X'},;
							{'lObrigat', .F.},;
							{'cTooltip', STR0007}})		//'Client ID'

	oStruct01:AddField({	{'cTitulo', STR0008},;		//'Client Secret'
							{'cIdField', "CFG_CLIENTESECRET"},;
							{'nTamanho', OA5410009L_GetFieldLen("CFG_CLIENTESECRET")},;
							{'cPicture', '@X'},;
							{'lObrigat', .F.},;
							{'cTooltip', STR0008}})		//'Client Secret'

	oStruct01:AddField({	{'cTitulo', STR0013},;		//'URL Base'
							{'cIdField', "CFG_URL"},;
							{'nTamanho', OA5410009L_GetFieldLen("CFG_URL")},;
							{'cPicture', '@X'},;
							{'lObrigat', .F.},;
							{'cTooltip', STR0013}})		//'URL Base'
	
	oStruct01:AddField({	{'cTitulo', STR0019},;		//'Authentication path'
							{'cIdField', "CFG_AUTHPATH"},;
							{'nTamanho', OA5410009L_GetFieldLen("CFG_AUTHPATH")},;
							{'cPicture', '@X'},;
							{'lObrigat', .F.},;
							{'cTooltip', STR0020}})		//'Endpoint autenticao'

	
	oStruct01:AddField({	{'cTitulo', STR0010},;		//'Grant Type'
							{'cIdField', "CFG_GRANTTYPE"},;
							{'nTamanho', OA5410009L_GetFieldLen("CFG_GRANTTYPE")},;
							{'cPicture', '@X'},;
							{'lObrigat', .F.},;
							{'cTooltip', STR0010}})		//'Grant Type'

	oStruct01:AddField({	{'cTitulo', STR0011},;		//'Content-Type'
							{'cIdField', "CFG_CONTTYPE"},;
							{'nTamanho', OA5410009L_GetFieldLen("CFG_CONTTYPE")},;
							{'aComboValues', {"1=application/json", "2=application/x", "3=www-form-urlencoded", "4=multipart/form-data", "5=text/plain"}},;
							{'bValid', { |a,b,c,d| OA5410003L_ValidaOpcao(a,b,c,d, "1,2,3,4,5")}},;
							{'lObrigat', .F.},;
							{'cTooltip', STR0011}})		//'Content-Type'
Return oStruct01

/*/{Protheus.doc} OA5410002L_LoadModelAutenticacaoScobModel01
	Carrega os valores default no Modelo

	@author  Guilherme Santos
	@since   25/09/2025
	@version 12.1.2610
	/*/
Static Function OA5410002L_LoadModelAutenticacaoScobModel01()
	Local aRetorno := {}
	local oCfg := OfScaniaConfig():New("SCOB","OFIA541")
	local oJson := oCfg:getConfig() //GetValue("SCOB")
	local lTemJson := (ValType(oJson) == "J")
	local nX := 0

	if !lTemJson .or. !oJson:HasProperty(aTab1[1]) .or. empty(oJson[aTab3[1]])
		aadd(aRetorno, "1")
		aadd(aRetorno, "1")
		aadd(aRetorno, "1")
		aadd(aRetorno, Space(OA5410009L_GetFieldLen("CFG_CLIENTEID")))
		aadd(aRetorno, Space(OA5410009L_GetFieldLen("CFG_CLIENTESECRET")))
		aadd(aRetorno, Space(OA5410009L_GetFieldLen("CFG_URL")))
		aadd(aRetorno, Space(OA5410009L_GetFieldLen("CFG_AUTHPATH")))
		aadd(aRetorno, Space(OA5410009L_GetFieldLen("CFG_GRANTTYPE")))
		aadd(aRetorno, "1")
	else
		for nX := 1 to len(aTab1)
			aadd(aRetorno, oJson[aTab1[nX]])
		next

	endif


Return aRetorno

/*/{Protheus.doc} OA5410004L_GetStructConsultaVeiculoScobScania
	Definicao da Struct da Secao Consulta Chassi Scania

	@author  Guilherme Santos
	@since   26/09/2025
	@version 12.1.2610
/*/
Static Function OA5410004L_GetStructConsultaVeiculoScobScania()
	Local oStruct02 := OFDMSStruct():New()

	oStruct02:AddField({	{'cTitulo', STR0004},;  //'Tipo de Autenticao'
							{'cIdField', "CFG_TPAUT2" },;
							{'nTamanho', OA5410009L_GetFieldLen("CFG_TPAUT2") },;
							{'aComboValues', {"1=Bearer Token"}},;
							{'bValid', { |a,b,c,d| OA5410003L_ValidaOpcao(a,b,c,d, "1")}},;
							{'cPicture', '@X'},;
							{'lObrigat', .F. },;
							{'cTooltip', STR0004}})		//'Tipo de Autenticao'

	oStruct02:AddField({	{'cTitulo', STR0013},;		//'URL Base'
							{'cIdField', "CFG_URLBASE"},;
							{'nTamanho', OA5410009L_GetFieldLen("CFG_URLBASE")},;
							{'cPicture', '@X'},;
							{'lObrigat', .F.},;
							{'cTooltip', STR0013}})		//'URL Base'

	oStruct02:AddField({	{'cTitulo', STR0014},;		//'EndPoint'
							{'cIdField', "CFG_ENDPOINT"},;
							{'nTamanho', OA5410009L_GetFieldLen("CFG_ENDPOINT")},;
							{'cPicture', '@X'},;
							{'lObrigat', .F.},;
							{'cTooltip', STR0014}})		//'EndPoint'

Return oStruct02

/*/{Protheus.doc} OA5410005L_LoadModelEndpointVeiculosScaniaModel02
	Carrega os valores default no Modelo

	@author  Guilherme Santos
	@since   26/09/2025
	@version 12.1.2610
	/*/
Static Function OA5410005L_LoadModelEndpointVeiculosScaniaModel02()
	Local aRetorno := {}
	local oCfg := OfScaniaConfig():New("SCOB","OFIA541")
	local oJson := oCfg:getConfig() //GetValue("SCOB")
	local lTemJson := (ValType(oJson) == "J")
	local nX := 0

	if !lTemJson .or. !oJson:HasProperty(aTab2[1]) .or. empty(oJson[aTab3[1]])
		aadd(aRetorno, "1")
		aadd(aRetorno, Space(OA5410009L_GetFieldLen("CFG_URLBASE")))
		aadd(aRetorno, Space(OA5410009L_GetFieldLen("CFG_ENDPOINT")))
	else
		for nX := 1 to len(aTab2)
			aadd(aRetorno, oJson[aTab2[nx]])
		next
	endif

	freeObj(oJson)
Return aRetorno

/*/{Protheus.doc} OA5410006L_GetStructSecaoGerais03
	Definicao da Struct da Secao Gerais

	@author  Guilherme Santos
	@since   26/09/2025
	@version 12.1.2610
	/*/
Static Function OA5410006L_GetStructSecaoGerais03()
	Local oStruct03 := OFDMSStruct():New()

	oStruct03:AddField({	{'cTitulo', STR0016},;  //'Pr-Cadastro Automtico'
							{'cIdField', "CFG_PRECADAUT" },;
							{'nTamanho', OA5410009L_GetFieldLen("CFG_PRECADAUT")},;
							{'aComboValues', {"1=" + STR0017, "2=" + STR0018}},;
							{'bValid', { |a,b,c,d| OA5410003L_ValidaOpcao(a,b,c,d, "1,2")}},;
							{'lObrigat', .F. },;
							{'cTooltip', STR0016}})		//'Pr-Cadastro Automtico'
	
	oStruct03:AddField({	{'cTitulo', STR0056},;  //"Localização padrão"
							{'cIdField', "CFG_LOCPAD" },;
							{'nTamanho', OA5410009L_GetFieldLen("CFG_LOCPAD")},;
							{'bValid', { |a,b,c,d| OA5410010J_ValidaLocPad(a,b,c,d)}},;
							{'cLookUp', 'NNR'},;
							{'lObrigat', .F. },;
							{'cTooltip', STR0056}}) //"Localizao padro"
	
	oStruct03:AddField({	{'cTitulo', STR0024},; //"Exibe Complemento de Cadastro Oramento Oficina (OFIXX001)"  
							{'cIdField', "OFIXX001" },;
							{'nTamanho', 1},;
							{'aComboValues', {STR0028, STR0029}},; //1=Sim //2=No
							{'bValid', { |a,b,c,d| OA5410003L_ValidaOpcao(a,b,c,d, "1,2")}},;
							{'lObrigat', .F. },;
							{'cTooltip', STR0025}}) //"Indica se deve exibir tela para complemento de cadastro no OFIXX001"
	
	oStruct03:AddField({	{'cTitulo', STR0026},; //"Exibe Complemento de Cadastro - Abertura da OS (OFIOM010)"  
							{'cIdField', "OFIOM010" },;
							{'nTamanho', 1},;
							{'aComboValues', {STR0028, STR0029}},; //1=Sim //2=No
							{'bValid', { |a,b,c,d| OA5410003L_ValidaOpcao(a,b,c,d, "1,2")}},;
							{'lObrigat', .F. },;
							{'cTooltip', STR0027}}) //"Indica se deve exibir tela para complemento de cadastro no OFIOM010"
	
	oStruct03:AddField({	{'cTitulo', STR0030},;  //"Exibe Complemento de Cadastro - Abertura da OS (OFIOM140)"
							{'cIdField', "OFIOM140"},;
							{'nTamanho', 1},;
							{'aComboValues', {STR0028, STR0029}},; //1=Sim //2=No
							{'bValid', { |a,b,c,d| OA5410003L_ValidaOpcao(a,b,c,d, "1,2")}},;
							{'lObrigat', .F. },;
							{'cTooltip', STR0031}}) //"Indica se deve exibir tela para complemento de cadastro no OFIOM140"

	oStruct03:AddField({	{'cTitulo', "Marca padrão para cadastro"},;  //"Localização padrão"
							{'cIdField', "CFG_CODMAR" },;
							{'nTamanho', OA5410009L_GetFieldLen("CFG_CODMAR")},;
							{'bValid', { |a,b,c,d| OA5410025J_ValidaMarca(a,b,c,d)}},;
							{'cLookUp', 'VE1'},;
							{'lObrigat', .F. },;
							{'cTooltip', STR0056}}) //"Localizao padro"

Return oStruct03

/*/{Protheus.doc} OA5410007L_LoadModelSecaoGeraisModel03()
	Carrega os valores default no Modelo

	@author  Guilherme Santos
	@since   26/09/2025
	@version 12.1.2610
	/*/
Static Function OA5410007L_LoadModelSecaoGeraisModel03()
	Local aRetorno := {}
	local oCfg := OfScaniaConfig():New("SCOB","OFIA541")
	local oJson := oCfg:getConfig() //GetValue("SCOB")
	local lTemJson := (ValType(oJson) == "J")
	local nX := 0

	if !lTemJson .or. !oJson:HasProperty(aTab3[1]) .or. empty(oJson[aTab3[1]])
		aadd(aRetorno, "1")
		aadd(aRetorno, Space(OA5410009L_GetFieldLen("CFG_LOCPAD")))
		aadd(aRetorno, "1")
		aadd(aRetorno, "1")
		aadd(aRetorno, "1")
		aadd(aRetorno, Space(OA5410009L_GetFieldLen("CFG_CODMAR")))
	else
		for nX := 1 to len(aTab3)
			aadd(aRetorno, oJson[aTab3[nx]])
		next
	endif

	FreeObj(oJson)
Return aRetorno

/*/{Protheus.doc} OA5410003L_ValidaOpcao
	Valida se o valor atual esta nas opcoes disponiveis

	@author  Guilherme Santos
	@since   25/09/2025
	@version 12.1.2610
	/*/
Function OA5410003L_ValidaOpcao(oModel, cField, xValue, xValueAntigo, cOpcoesDisponiveis)
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

/*/{Protheus.doc} ViewDef
	Definicao do Interface dos Dados

	@author  Guilherme Santos
	@since   25/09/2025
	@version 12.1.2610
	/*/
Static Function ViewDef()
	Local oModel	:= FWLoadModel("OFIA541")
	Local oView		:= FWFormView():New()

	Local oSubMod01	:= OA5410001L_GetStr01()
	Local oStruct01	:= oSubMod01:GetView()

	Local oSubMod02	:= OA5410004L_GetStructConsultaVeiculoScobScania()
	Local oStruct02	:= oSubMod02:GetView()

	Local oSubMod03	:= OA5410006L_GetStructSecaoGerais03()
	Local oStruct03	:= oSubMod03:GetView()
	Local oSubTok		:= OA5410100N_GetStructArmsToken()
	Local oStruToken	:= oSubTok:GetView()
	Local oSubCons  	:= OA5410102N_GetStructArmsConsulta()
	Local oStruCons		:= oSubCons:GetView()

	local oSubMod04Scrm := OA5410014J_GetStructSecaoGerais04Scrm()
	local oStruct04Scrm := oSubMod04Scrm:getView()

	local oSubMod05Scrm := OA5410017J_Struct05ScrmGerais()
	local oStruct05Scrm := oSubMod05Scrm:getView()

	local oSubMod06Scrm := OA5410023J_GetStruct06Scrm()
	local oStruct06Scrm := oSubMod06Scrm:getView()

	local oSubMod07Coto := OA54100262_Struct07CotoToken()
	local oStruct07Coto := oSubMod07Coto:getView()

	local oSubMod08Coto := OA54100282_Struct08Coto()
	local oStruct08Coto := oSubMod08Coto:getView()

	local oSubMod09Coto := OA54100302_Struct09CotoGeneral()
	local oStruct09Coto := oSubMod09Coto:getView()

	local oSubMod10Coto := OA54100332_Struct10CotoGridConcessionaria()
	local oStruct10Coto := oSubMod10Coto:getView()

	local oSubMod11Coto := OA54100352_Struct11CotoGridTPContrato()
	local oStruct11Coto := oSubMod11Coto:getView()

	local oSubMod12Coto := OA54100353_Struct12CotoGridDePara()
	local oStruct12Coto := oSubMod12Coto:getView()

	oView:SetModel(oModel)

	// Vincula estruturas às seções do modelo
	oView:AddField('VIEW_TAB1', oStruct01, 'TAB1')
	oView:AddField('VIEW_TAB2', oStruct02, 'TAB2')
	oView:AddField('VIEW_TAB3', oStruct03, 'TAB3')
	oView:AddField('VIEW_SCRM', oStruct04Scrm, 'TAB_SCRM')
	oView:AddField('VIEW_GERAIS_SCRM', oStruct05Scrm, 'TAB_GERAIS_SCRM')
	oView:AddField('VIEW_GATILHOS_SCRM', oStruct06Scrm, 'TAB_GATILHOS_SCRM')
	oView:AddField('VIEW_TAB_ARMS'		, oStruToken	, 'TAB_ARMS')
	oView:AddField('VIEW_TAB_ARMS_CONS'	, oStruCons		, 'TAB_ARMS_CONSULTA')
	oView:AddField('VIEW_TOKEN_COTO'	, oStruct07Coto	, 'TAB_TOKEN_COTO')
	oView:AddField('VIEW_COTO'			, oStruct08Coto	, 'TAB_COTO')
	oView:AddField('VIEW_GERAIS_COTO'	, oStruct09Coto	, 'TAB_GERAIS_COTO')
	oView:AddGrid('GRID_CONCESSIONARIA_COTO', oStruct10Coto, 'TAB_CONCESSIONARIA_COTO')
	oView:AddGrid('GRID_TP_CONTRATO_COTO', oStruct11Coto, 'TAB_TP_CONTRATO_COTO')
	oView:AddGrid('GRID_DEPARA_COTO', oStruct12Coto, 'TAB_DEPARA_COTO')

	// Criao dos containers
	oView:CreateHorizontalBox('BOX', 100)
	oView:CreateFolder('FOLDER', 'BOX')

	// Cria as abas (sheets)
	oView:AddSheet('FOLDER', 'SCOB_SCANIA', STR0023)                  // "SCOB Scania"
	oView:AddSheet('FOLDER', 'SCRM_SCANIA', STR0043) //'Integração SCRM Scania'
	oView:AddSheet('FOLDER', 'ARMS_SCANIA', STR0074) // 'Integração ARMS'
	oView:AddSheet('FOLDER', 'COTO_SCANIA', STR0061) //'Control Tower'
	// Cria os boxes dentro das abas
	//SCOB 
	oView:CreateHorizontalBox('BOX_TAB1', 40,,,'FOLDER', 'SCOB_SCANIA')
	oView:CreateHorizontalBox('BOX_TAB2', 25,,,'FOLDER', 'SCOB_SCANIA')
	oView:CreateHorizontalBox('BOX_TAB3', 35,,,'FOLDER', 'SCOB_SCANIA')
	//SCRM
	oView:CreateHorizontalBox('BOX_TAB_SCRM', 35,,,'FOLDER', 'SCRM_SCANIA')
	oView:CreateHorizontalBox('BOX_GERAIS_SCRM', 25,,,'FOLDER', 'SCRM_SCANIA')
	oView:CreateHorizontalBox('BOX_GATILHOS_SCRM', 40,,,'FOLDER', 'SCRM_SCANIA')

	//-- ARMS
	oView:CreateHorizontalBox('BOX_TAB_ARMS',       70,,,'FOLDER', 'ARMS_SCANIA')
	oView:CreateHorizontalBox('BOX_TAB_ARMS_CONS',  30,,,'FOLDER', 'ARMS_SCANIA')

	//CONTROL TOWER
	oView:CreateHorizontalBox('BOX_TAB_TOKEN_COTO', 30,,,'FOLDER', 'COTO_SCANIA')
	oView:CreateHorizontalBox('BOX_COTO', 20,,,'FOLDER', 'COTO_SCANIA')
	oView:CreateHorizontalBox('BOX_GERAIS_COTO', 20,,,'FOLDER', 'COTO_SCANIA')
	oView:CreateHorizontalBox('BOX_GRIDS_COTO',30,,,'FOLDER','COTO_SCANIA')
	oView:CreateVerticalBox("BOX_CONCESSIONARIA_COTO",25,'BOX_GRIDS_COTO', .f., "FOLDER", "COTO_SCANIA")
	oView:CreateVerticalBox("BOX_TP_CONTRATO_COTO",25,'BOX_GRIDS_COTO', .f., "FOLDER", "COTO_SCANIA")
	oView:CreateVerticalBox("BOX_DEPARA_COTO",50,'BOX_GRIDS_COTO', .f., "FOLDER", "COTO_SCANIA")

	// Define o vnculo entre os fields e os boxes
	oView:SetOwnerView('VIEW_TAB1', 'BOX_TAB1')
	oView:SetOwnerView('VIEW_TAB2', 'BOX_TAB2')
	oView:SetOwnerView('VIEW_TAB3', 'BOX_TAB3')
	oView:SetOwnerView('VIEW_SCRM', 'BOX_TAB_SCRM')
	oView:SetOwnerView('VIEW_GERAIS_SCRM', 'BOX_GERAIS_SCRM')
	oView:SetOwnerView('VIEW_GATILHOS_SCRM', 'BOX_GATILHOS_SCRM')
	oView:SetOwnerView('VIEW_TAB_ARMS',      'BOX_TAB_ARMS')		
	oView:SetOwnerView('VIEW_TAB_ARMS_CONS', 'BOX_TAB_ARMS_CONS')
	oView:SetOwnerView('VIEW_TOKEN_COTO', 'BOX_TAB_TOKEN_COTO')
	oView:SetOwnerView('VIEW_COTO', 'BOX_COTO')
	oView:SetOwnerView('VIEW_GERAIS_COTO', 'BOX_GERAIS_COTO')
	oView:SetOwnerView('GRID_CONCESSIONARIA_COTO', 'BOX_CONCESSIONARIA_COTO')
	oView:SetOwnerView('GRID_TP_CONTRATO_COTO', 'BOX_TP_CONTRATO_COTO')
	oView:SetOwnerView('GRID_DEPARA_COTO', 'BOX_DEPARA_COTO')


	// Títulos das seções
	oView:EnableTitleView('VIEW_TAB1', STR0012) // Token
	oView:EnableTitleView('VIEW_TAB2', STR0002) // Consulta Chassi Scania
	oView:EnableTitleView('VIEW_TAB3', STR0015) // Gerais
	oView:EnableTitleView('VIEW_SCRM', STR0044) //'Integração - SCRM'
	oView:EnableTitleView('VIEW_GERAIS_SCRM', STR0045) //'Gerais'
	oView:EnableTitleView('VIEW_GATILHOS_SCRM', STR0057) //'Gatilhos para envio ao SCRM'
	oView:EnableTitleView('VIEW_TAB_ARMS'		, STR0075) // 'Token (ARMS)'
	oView:EnableTitleView('VIEW_TAB_ARMS_CONS'	, STR0076) // 'Consulta Contrato (ARMS)'
	oView:EnableTitleView('VIEW_TOKEN_COTO', STR0012) //'Token'
	oView:EnableTitleView('VIEW_COTO', STR0061) //'Control Tower'
	oView:EnableTitleView('VIEW_GERAIS_COTO', STR0015) //'Gerais'
	oView:EnableTitleView('GRID_CONCESSIONARIA_COTO', STR0096) //'ID Concessionária'
	oView:EnableTitleView('GRID_TP_CONTRATO_COTO', STR0097) //'Tipos de Contrato'
	oView:EnableTitleView('GRID_DEPARA_COTO', STR0111)  //'De/Para Interrupcao'
Return oView

/*/{Protheus.doc} OA5410009L_GetFieldLen
	Retorna o tamanho dos campos da tela

	@author  Guilherme Santos
	@since   26/09/2025
	@version 12.1.2610
	/*/

Static Function OA5410009L_GetFieldLen(cField)
	Local aFields 	:= {}
	Local nRetorno	:= 0

	//-- SCOB
	Aadd(aFields, {"CFG_AMBIENTE", 1})
	aadd(aFields, {"CFG_INTEGRACAO_ATIVA", 1})
	Aadd(aFields, {"CFG_TPAUT", 1})
	Aadd(aFields, {"CFG_CLIENTEID", 100})
	Aadd(aFields, {"CFG_CLIENTESECRET", 100})
	Aadd(aFields, {"CFG_URL", 200})
	aadd(aFields, {"CFG_AUTHPATH", 200})
	Aadd(aFields, {"CFG_GRANTTYPE", 100})
	Aadd(aFields, {"CFG_CONTTYPE", 1})
	Aadd(aFields, {"CFG_TPAUT2", 1})
	Aadd(aFields, {"CFG_URLBASE", 150})
	Aadd(aFields, {"CFG_ENDPOINT", 150})
	Aadd(aFields, {"CFG_PRECADAUT", 1})
	aadd(aFields, {"CFG_LOCPAD", TamSx3('VV1_LOCPAD')[1]})
	aadd(aFields, {"CFG_CODMAR", TamSx3('VE1_CODMAR')[1]})
	//-- SCRM
	aadd(aFields, {"SCRM_INTEGRACAO_ATIVA", 1})
	aadd(aFields, {"SCRM_AMBIENTE", 1})
	aadd(aFields, {"SCRM_PSW_WEBSERVICE", 100})
	aadd(aFields, {"SCRM_USER_WEBSERVICE", 100})
	aadd(aFields, {"SCRM_CLIENTES_URL_WEBSERVICE", 100})
	aadd(aFields, {"SCRM_VEICULOS_URL_WEBSERVICE", 100})
	aadd(aFields, {"SCRM_ULTIMA_EXECUCAO", 8})
	aadd(aFields, {"SCRM_LEVANTAR_FROTA", 2})
	aadd(aFields, {"SCRM_APENAS_CLIENTES", 1})
	aadd(aFields, {"SCRM_GERA_ARQUIVO", 1})
	aadd(aFields, {"SCRM_FILE_PATH", 99})
	//-- ARMS 
	aAdd(aFields, {"ARMS_AMBIENTE", 1})
	aadd(aFields, {"ARMS_INTEGRACAO_ATIVA", 1})
	aAdd(aFields, {"ARMS_TPAUT", 1})
	aAdd(aFields, {"ARMS_CLIENTID", 100})
	aAdd(aFields, {"ARMS_CLIENTSEC", 100})
	aAdd(aFields, {"ARMS_TOKEN_URL", 200})
	aAdd(aFields, {"ARMS_GRANTTYPE", 100})
	aAdd(aFields, {"ARMS_SCOPE", 150})
	aAdd(aFields, {"ARMS_CONTTYPE", 1})
	aAdd(aFields, {"ARMS_TPAUT2", 1})
	aAdd(aFields, {"ARMS_URLBASE", 150})
	aAdd(aFields, {"ARMS_ENDPOINT", 150})
	//Control Tower
	aadd(aFields, {"COTO_AMBIENTE", 1})
	aadd(aFields, {"COTO_INTEGRACAO_ATIVA", 1})
	aadd(aFields, {"COTO_TPAUT", 1})
	aadd(aFields, {"COTO_CLIENTEID", 100})
	aadd(aFields, {"COTO_CLIENTESECRET", 100})
	aadd(aFields, {"COTO_URL", 200})
	aadd(aFields, {"COTO_USERNAME", 100})
	aadd(aFields, {"COTO_PASSWORD", 100})
	aadd(aFields, {"COTO_GRANTTYPE", 100})
	aadd(aFields, {"COTO_CONTENTTYPE", 1})
	aadd(aFields, {"COTO_TPAUT2", 1})
	aadd(aFields, {"COTO_URLBASE", 150})
	aadd(aFields, {"COTO_ENDPOINT", 150})
	aadd(aFields, {"COTO_OBTERTPCONT", 1})
	aadd(aFields, {"COTO_QTDHEVENTO", 12})
	aadd(aFields, {"COTO_MARCAVEIINT", TamSx3('VE1_CODMAR')[1]})
	aadd(aFields, {"COTO_SRVCHECK", 50})   
	aadd(aFields, {"COTO_MAXTENT", 12})
	aadd(aFields, {"COTO_GCONC_FILIAL", FWSizeFilial()})
	aadd(aFields, {"COTO_GCONC_ID", 36})
	aadd(aFields, {"COTO_GTPCONT_TPCONTRATO", 100})	
	aadd(aFields, {"COTO_CODPAUSA", 6})
	aadd(aFields, {"COTO_DESCPAUSA", 40})
	aadd(aFields, {"COTO_CODINTERRUPCAO", 6})
	aadd(aFields, {"COTO_DESCINTERRUPCAO", 40})

	nRetorno := aFields[AScan(aFields, {|x| x[1] == cField})][02]

Return nRetorno

/*/{Protheus.doc} OA5410010J_ValidaLocPad
	Valida opo selecionada no lookup
	@type  Static Function
	@author Renan Migliaris
	@since 09/10/2025
	/*/
Static Function OA5410010J_ValidaLocPad(oModel, cField, xValue, xValueAntigo)
	Local lRet := .f.

	DbSelectArea('NNR')
	DbSetOrder(1)
	If DbSeek(xFilial('NNR') + xValue)
		lRet := .t. 
	EndIf
	DbCloseArea()

Return lRet

/*/{Protheus.doc} OA5410011J_TrocaDadosDoScobDeAcordoComOAmbienteSelecionado
	Mtodo que vai realizar a troca dos dados de acordo com o ambiente selecionado
	@type  Static Function
	@author Renan Migliaris
	@since 14/10/2025
/*/
Static Function OA5410011J_TrocaDadosDoScobDeAcordoComOAmbienteSelecionado(oModelL, cField, xValue, xOldValue)
	local oSubMod01	:= oModelL:GetModel("TAB1")
	local oSubMod02	:= oModelL:GetModel("TAB2")
	local oSubMod03	:= oModelL:GetModel("TAB3")
	local oJson := oCfgScInt:GetValue("SCOB")
	local cPropEnv := ''
	local oStru01 := OA5410001L_GetStr01()
	local oStru02 := OA5410004L_GetStructConsultaVeiculoScobScania()
	local oStru03 := OA5410006L_GetStructSecaoGerais03()
	local aStru01 := oStru01:GetModel():GetFields()
	local aStru02 := oStru02:GetModel():GetFields()
	local aStru03 := oStru03:GetModel():GetFields()
	local nX := 0
	
	if ValType(oJson) <> "J"
		oJson := JsonObject():New()
	endif

	if xValue == '1'
		cPropEnv := 'PRODUCAO'
	elseif xValue == '2'
		cPropEnv := 'HOMOLOGACAO'
	endif

	if oJson:HasProperty(cPropEnv) .and. (ValType(oJson[cPropEnv]) == 'J')
		for nX := 1 to len(aStru01)
			oSubMod01:SetValue('TAB1', aStru01[nx][3], oJson[cPropEnv][aStru01[nx][3]])
		next
		for nX := 1 to len(aStru02)
			oSubMod02:SetValue('TAB2', aStru02[nx][3], oJson[cPropEnv][aStru02[nx][3]])
		next
		for nx := 1 to len(aStru03)
			oSubMod03:SetValue('TAB3', aStru03[nx][3], oJson[cPropEnv][aStru03[nx][3]])
		next
	else
		//TAB1 - Auth
		oSubMod01:SetValue("TAB1", "CFG_INTEGRACAO_ATIVA", "0")
		oSubMod01:SetValue("TAB1", "CFG_TPAUT", "1")
		oSubMod01:SetValue("TAB1", "CFG_CLIENTEID", Space(OA5410009L_GetFieldLen("CFG_CLIENTEID")))
		oSubMod01:SetValue("TAB1", "CFG_CLIENTESECRET", Space(OA5410009L_GetFieldLen("CFG_CLIENTESECRET")))
		oSubMod01:SetValue("TAB1", "CFG_URL", Space(OA5410009L_GetFieldLen("CFG_URL")))
		oSubMod01:SetValue("TAB1", "CFG_GRANTTYPE", Space(OA5410009L_GetFieldLen("CFG_GRANTTYPE")))
		oSubMod01:SetValue("TAB1", "CFG_CONTTYPE", "1")
		oSubMod01:SetValue("TAB1", "CFG_AUTHPATH", Space(OA5410009L_GetFieldLen("CFG_AUTHPATH")))
		//TAB2 - Endpoint Veiculos
		oSubMod02:SetValue("TAB2", "CFG_TPAUT2", "1")
		oSubMod02:SetValue("TAB2", "CFG_URLBASE", Space(OA5410009L_GetFieldLen("CFG_URLBASE")))
		oSubMod02:SetValue("TAB2", "CFG_ENDPOINT", Space(OA5410009L_GetFieldLen("CFG_ENDPOINT")))
		//TAB3 - Gerais
		oSubMod03:SetValue("TAB3", "CFG_PRECADAUT", "1")
		oSubMod03:LoadValue("TAB3", "CFG_LOCPAD", Space(OA5410009L_GetFieldLen("CFG_LOCPAD")))
		oSubMod03:SetValue("TAB3", "OFIXX001", "1")
		oSubMod03:SetValue("TAB3", "OFIOM010", "1")
		oSubMod03:SetValue("TAB3", "OFIOM140", "1")
		oSubMod03:LoadValue("TAB3", "CFG_CODMAR", Space(OA5410009L_GetFieldLen("CFG_CODMAR")))
	endif

Return .t.

/*/{Protheus.doc} OA5410012J_CarregaConfigVRNDeAcordoComAmbiente
	Funo que ser utilizada para levar o json de configurao para as telas de oramento ou os aonde seja necessrio 
	verificar alguma troca de tela ou algo do tipo
	@type  Function
	@author Renan Migliaris	
	@since 22/10/2025
	/*/
Function OA5410012J_CarregaConfigVRNDeAcordoComAmbienteEIntegracao(cConfig, cItegracao, cEnv)
	local jJson := JsonObject():New()
	local oConfig := JsonObject():New()
	local cProperty := ''

	default cEnv := ''
	default cConfig := 'OFIA541'
	default cIntegracao := 'SCOB'
	
	DbSelectArea('VRN')
	DbSetOrder(1)

	if DbSeek(xFilial('VRN') + cConfig)
		jJson:FromJson(VRN->VRN_CONFIG)
	else
		jJson := JsonObject():New()
	endif
	DbCloseArea()

	if cEnv == '3' .or. cEnv == '2'
		cProperty := 'HOMOLOGACAO'
	elseif cEnv == '1'
		cProperty := 'PRODUCAO'
	endif

	if jJson:HasProperty(cIntegracao) .and. jJson[cIntegracao]:HasProperty(cProperty)
		oConfig := jJson[cItegracao][cProperty]
	else
		oConfig := JsonObject():New()
	endif

	freeObj(jJson)
Return oConfig

/*/{Protheus.doc} OA5410013J_VerificaExibicaTelaComplementoCadastroVeiculo
	Vai verificar se existe a config de exibio da tela de complemento de cadastros (a partir da integrao scob)
	@type  Function
	@author Renan Migliaris
	@since 22/10/2025
	/*/
Function OA5410013J_VerificaExibicaTelaComplementoCadastroVeiculo(oConfig, cRotina)
	local lRet := .f.
	local aCompTelas := {'OFIOM010', 'OFIXX001', 'OFIOM140'}
	local nx := 0
	default cRotina := ''
	
	if Empty(cRotina)
		for nx := 1 to len(aCompTelas)
			if IsInCallStack(aCompTelas[nx])
				cRotina := aCompTelas[nx]
				exit
			endif
		next
	endif
	
	if FindFunction("FGX_ValidRequiredFieds") .and. oConfig:HasProperty(cRotina) .and. oConfig[cRotina] == '1'
		lRet := .t.
	endIf
Return lRet

/*/{Protheus.doc} OA5410025J_ValidaMarca
	Valida a marca padrão para integração do SCOB
	@type  Static Function
	@author Renan Migliaris
	@since 19/11/2025
/*/
Static Function OA5410025J_ValidaMarca(oModel, cField, xValue, xValueAntigo)
	local lRet := .f.

	DbSelectArea("VE1")
	DbSetOrder(1)
	if DbSeek(xFilial("VE1")+xValue)
		lRet := .t.
	endif
	DbCloseArea()

Return lRet


/*/{Protheus.doc} OA5410014J_GetStructSecaoGerais04Scrm
	Retorna a struct do SCRM 
	@type  Static Function
	@author Renan Migliaris
	@since 27/10/2025
	/*/
Static Function OA5410014J_GetStructSecaoGerais04Scrm()
	local oStruct04Scrm := OFDMSStruct():new()

	oStruct04Scrm:AddField(;
		{;
			{'cTitulo', STR0003},;
			{'cIdField', 'SCRM_AMBIENTE'},;
			{'nTamanho', OA5410009L_GetFieldLen("SCRM_AMBIENTE")},;
			{'aComboValues', {"1="+ STR0005, "2=" + STR0006}},;		//'Produção','Homologação'
			{'bValid', { |a,b,c,d| OA5410003L_ValidaOpcao(a,b,c,d, "1,2")}},;
			{'lObrigat', .f.},;
			{'cTooltip', STR0003}; //'Ambiente'
		};
	)

	oStruct04Scrm:AddField(;
		{;
			{'cTitulo', STR0033},; //'Integração Ativa?'
			{'cIdField', 'SCRM_INTEGRACAO_ATIVA'},;
			{'nTamanho', OA5410009L_GetFieldLen("SCRM_INTEGRACAO_ATIVA")},;
			{'bValid', { |a,b,c,d| OA5410003L_ValidaOpcao(a,b,c,d, "1,2")}},;
			{'aComboValues', {STR0028, STR0029}},; //"1=Sim" //"2=Não"
			{'lObrigat', .f.},;
			{'cTooltip', STR0003}; //'Ambiente'
		};
	)

	oStruct04Scrm:AddField(;
		{;
			{'cTitulo', STR0034},; //'Usuário WebService'
			{'cIdField','SCRM_USER_WEBSERVICE'},;
			{'nTamanho', OA5410009L_GetFieldLen('SCRM_USER_WEBSERVICE')},;
			{'lObrigat', .f.},;
			{'cPicture', '@X'},;
			{'cTooltip', STR0035}; //'Usuário Web Service SCRM'
		};
	)

	oStruct04Scrm:AddField(;
		{;
			{'cTitulo', STR0036},; //'Senha WebService'
			{'cIdField','SCRM_PSW_WEBSERVICE'},;
			{'nTamanho', OA5410009L_GetFieldLen('SCRM_PSW_WEBSERVICE')},;
			{'lObrigat', .f.},;
			{'cPicture', '@X'},;
			{'cTooltip', STR0036}; //'Senha WebService'
		};
	)

	oStruct04Scrm:AddField(;
		{;
			{'cTitulo', STR0037},; //URL Clientes WebService
			{'cIdField','SCRM_CLIENTES_URL_WEBSERVICE'},;
			{'nTamanho', OA5410009L_GetFieldLen('SCRM_CLIENTES_URL_WEBSERVICE')},;
			{'lObrigat', .f.},;
			{'cPicture', '@X'},;
			{'cTooltip', STR0037}; //URL Clientes WebService
		};
	)
	
	oStruct04Scrm:AddField(;
		{;
			{'cTitulo', STR0038},; //'URL Veiculos WebService'
			{'cIdField','SCRM_VEICULOS_URL_WEBSERVICE'},;
			{'nTamanho', OA5410009L_GetFieldLen('SCRM_VEICULOS_URL_WEBSERVICE')},;
			{'lObrigat', .f.},;
			{'cPicture', '@X'},;
			{'cTooltip', STR0038}; //'URL Veiculos WebService'
		};
	)
Return oStruct04Scrm

/*/{Protheus.doc} OA5410015J_LoadModel04Scrm
	@type  Static Function
	@author Renan Migliaris
	@since 27/10/2025
	/*/
Static Function OA5410015J_LoadModel04Scrm()
	local aRetorno := {}
	local oCfg := OfScaniaConfig():New("SCRM","OFIA541")
	local oJson := oCfg:getConfig()
	local lTemJson := (ValType(oJson) == "J")
	local nX := 0

	if !lTemJson .or. !oJson:HasProperty(aScrm[1]) .or. empty(oJson[aScrm[1]])
		aadd(aRetorno, '1') //SCRM_AMBIENTE
		aadd(aRetorno, '1') //SCRM_INTEGRACAO_ATIVA
		aadd(aRetorno, Space(OA5410009L_GetFieldLen('SCRM_USER_WEBSERVICE'))) //SCRM_USER_WEBSERVICE
		aadd(aRetorno, Space(OA5410009L_GetFieldLen('SCRM_PSW_WEBSERVICE'))) //SCRM_PSW_WEBSERVICE
		aadd(aRetorno, Space(OA5410009L_GetFieldLen('SCRM_CLIENTES_URL_WEBSERVICE'))) //SCRM_CLIENTES_URL_WEBSERVICE
		aadd(aRetorno, Space(OA5410009L_GetFieldLen('SCRM_VEICULOS_URL_WEBSERVICE'))) //SCRM_VEICULOS_URL_WEBSERVICE
	else
		for nX := 1 to len(aScrm)
			aadd(aRetorno, oJson[aScrm[nx]])
		next
	endif
	 
	freeObj(oJson)
Return aRetorno

/*/{Protheus.doc} OA5410017J_LoadModel05ScrmGerais
	Model da seção gerais do SCRM
	@type  Static Function
	@author Renan Migliaris
	@since 27/10/2025
	/*/
Static Function OA5410017J_Struct05ScrmGerais()
	local oStruct05ScrmGerais := OFDMSStruct():new()

	oStruct05ScrmGerais:AddField(;
		{;
			{'cTitulo', STR0039},; //'Última Execução'
			{'cIdField', 'SCRM_ULTIMA_EXECUCAO'},;
			{'nTamanho', 8},;
			{'lObrigat', .f.},;
			{'cTipo', 'D'},;
			{'bValid', {|| .t.}},;
			{'bWhen', {|| .f.}},;
			{'cTooltip', STR0040}; //'Data da Última Integração'
		};
	)

	oStruct05ScrmGerais:AddField(;
		{;
			{'cTitulo', STR0046},; //"Hora da Ultima Execução"
			{'cIdField', 'SCRM_HORA_ULTIMA_EXECUCAO'},;
			{'nTamanho', 8},;
			{'lObrigat', .f.},;
			{'cTipo', 'C'},;
			{'bValid', {|| .t.}},;
			{'bWhen', {|| .f.}},;
			{'cTooltip', STR0040}; //'Data da Última Integração'
		};
	)
	
	oStruct05ScrmGerais:AddField(;
		{;
			{'cTitulo', STR0041},; //'Quantidade de Anos para Levantamento da Frota'
			{'cIdField', 'SCRM_LEVANTAR_FROTA'},;
			{'nTamanho', 2},;
			{'lObrigat', .f.},;
			{'cTooltip', STR0041},; //'Quantidade de Anos para Levantamento da Frota'
			{'cTipo', 'N'};
		};
	)

	oStruct05ScrmGerais:AddField(;
		{;
			{'cTitulo', STR0042},; //'Enviar Apenas Clientes Viculados a Carteira de Vendedores de Veículos Novos?'
			{'cIdField', 'SCRM_APENAS_CLIENTES'},;
			{'nTamanho', 1},;
			{'aComboValues', {STR0028, STR0029}},; //"1=Sim" //"2=Não"
			{'bValid', { |a,b,c,d| OA5410003L_ValidaOpcao(a,b,c,d, "1,2")}},;
			{'lObrigat', .f.};
		};
	)
	
	oStruct05ScrmGerais:AddField(;
		{;
			{'cTitulo', STR0058},; //"Gerar Arquivo espelho do XML integrado ao SCRM?"
			{'cIdField', 'SCRM_GERA_ARQUIVO'},;
			{'nTamanho', 1},;
			{'aComboValues', {STR0028, STR0029}},; //"1=Sim" //"2=Não"
			{'bValid', { |a,b,c,d| OA5410003L_ValidaOpcao(a,b,c,d, "1,2")}},;
			{'lObrigat', .f.};
		};
	)

	oStruct05ScrmGerais:AddField(;
		{;
			{'cTitulo', STR0059},; //"Salvar arquivo na pasta (do servidor)"
			{'cIdField', 'SCRM_FILE_PATH'},;
			{'nTamanho', OA5410009L_GetFieldLen('SCRM_FILE_PATH')},;
			{'cLookUp', 'DIRFIS'},;
			{'lObrigat', .T.},;
			{'bWhen', {|oModel| OA5410026J_WhenDoFilePathScrm(oModel)}},;
			{'cTooltip', STR0060}; //'Selecionar a pasta de destino do arquivo'
		};
	)
Return oStruct05ScrmGerais

/*/{Protheus.doc} OA5410018J_LoadModel05Scrm
	Carrega a model 05 do SCRM - Scania
	@type  Static Function
	@author Renan Migliaris
	@since 27/10/2025
	/*/
Static Function OA5410018J_LoadModel05Scrm()
	local aRetorno := {}
	local oCfg := OfScaniaConfig():New("SCRM","OFIA541")
	local oJson := oCfg:getConfig()
	local lTemJson := (ValType(oJson) == "J")

	if !lTemJson .or. !oJson:HasProperty("SCRM_APENAS_CLIENTES") .or. empty(oJson["SCRM_APENAS_CLIENTES"])
		aadd(aRetorno, OA5410020J_RetornaDataDeUltimaExecucao()[1])
		aadd(aRetorno, OA5410020J_RetornaDataDeUltimaExecucao()[2])
		aadd(aRetorno, 5) //SCRM_LEVANTAR_FROTA
		aadd(aRetorno, "1") //SCRM_APENAS_CLIENTES
		aadd(aRetorno, "2") //SCRM_GERA_ARQUIVO
		aadd(aRetorno, space(OA5410009L_GetFieldLen("SCRM_FILE_PATH")))
	else
		aadd(aRetorno, OA5410020J_RetornaDataDeUltimaExecucao()[1])
		aadd(aRetorno, OA5410020J_RetornaDataDeUltimaExecucao()[2])
		aadd(aRetorno, oJson["SCRM_LEVANTAR_FROTA"])
		aadd(aRetorno, oJson["SCRM_APENAS_CLIENTES"])
		aadd(aRetorno, oJson["SCRM_GERA_ARQUIVO"])
		aadd(aRetorno, oJson["SCRM_FILE_PATH"])
	endif
	 
	freeObj(oJson)
Return aRetorno

/*/{Protheus.doc} OA5410019J_TrocaDadosScrm
	Vai trocar os dados do ambiente de integraçãod o SCRM 
	@type  Static Function
	@author Renan Migliaris
	@since 28/10/2025
	/*/
Static Function OA5410019J_TrocaDadosScrm(oModelL, cField, xValue, xOldValue)
	local oSubMod04Scrm := oModelL:GetModel('TAB_SCRM')
	local oSubMod05SCrmGerais := oModelL:GetModel('TAB_GERAIS_SCRM')
	local oSubMod06ScrmGatilhos := oModelL:GetModel('TAB_GATILHOS_SCRM')
	local oJson := oCfgScInt:GetValue('SCRM')
	local cPropEnv := ''
	local oStru04 := OA5410014J_GetStructSecaoGerais04Scrm()
	local oStru05 := OA5410017J_Struct05ScrmGerais()
	local oSTru06 := OA5410023J_GetStruct06Scrm()
	local aStru04 := oStru04:GetModel():GetFields()
	local aStru05 := oStru05:GetModel():GetFields()
	local aStru06 := oStru06:GetModel():GetFields()
	local nX := 0

	if ValType(oJson) <> 'J'
		oJson := JsonObject():new()
	endif

	if xValue == '1'
		cPropEnv := 'PRODUCAO'
	elseif xValue == '2'
		cPropEnv := 'HOMOLOGACAO'
	endif

	if oJson:HasProperty(cPropEnv) .and. (ValType(oJson[cPropEnv]) == 'J')
		for nx := 1 to len(aStru04)
			if aStru04[nx][3] == cField
				loop
			endif
			oSubMod04SCRM:SetValue('TAB_SCRM', aStru04[nx][3], oJson[cPropEnv][aStru04[nx][3]])
		next
		for nx := 1 to len(aStru05)
			if aStru05[nx][3] == "SCRM_ULTIMA_EXECUCAO" .or. aStru05[nx][3] == "SCRM_HORA_ULTIMA_EXECUCAO" 
				loop
			endif
			oSubMod05SCrmGerais:SetValue('TAB_GERAIS_SCRM', aStru05[nx][3], oJson[cPropEnv][aStru05[nx][3]])
		next
		for nx := 1 to len(aStru06)
			oSubMod06ScrmGatilhos:SetValue('TAB_GATILHOS_SCRM', aStru06[nx][3], oJson[cPropEnv][aStru06[nx][3]])
		next
		
	else
		oSubMod04Scrm:setValue('TAB_SCRM',  "SCRM_INTEGRACAO_ATIVA", "0")
		oSubMod04Scrm:setValue('TAB_SCRM',  "SCRM_USER_WEBSERVICE", space(OA5410009L_GetFieldLen("SCRM_USER_WEBSERVICE")))
		oSubMod04Scrm:setValue('TAB_SCRM',  "SCRM_PSW_WEBSERVICE", space(OA5410009L_GetFieldLen("SCRM_PSW_WEBSERVICE")))
		oSubMod04Scrm:setValue('TAB_SCRM',  "SCRM_CLIENTES_URL_WEBSERVICE", space(OA5410009L_GetFieldLen("SCRM_CLIENTES_URL_WEBSERVICE")))
		oSubMod04Scrm:setValue('TAB_SCRM',  "SCRM_VEICULOS_URL_WEBSERVICE", space(OA5410009L_GetFieldLen("SCRM_VEICULOS_URL_WEBSERVICE")))

		oSubMod05Scrm:SetValue('TAB_GERAIS_SCRM', 'SCRM_ULTIMA_EXECUCAO', OA5410020J_RetornaDataDeUltimaExecucao()[1])
		oSubMod05Scrm:SetValue('TAB_GERAIS_SCRM', 'SCRM_HORA_ULTIMA_EXECUCAO', OA5410020J_RetornaDataDeUltimaExecucao()[2])
		oSubMod05Scrm:SetValue('TAB_GERAIS_SCRM', 'SCRM_LEVANTAR_FROTA', 5)
		oSubMod05Scrm:SetValue('TAB_GERAIS_SCRM', 'SCRM_APENAS_CLIENTES', "1")
		oSubMod05SCrm:SetValue('TAB_GERAIS_SCRM', 'SCRM_GERA_ARQUIVO', '1')
		oSubMod05SCrm:SetValue('TAB_GERAIS_SCRM', 'SCRM_FILE_PATH', space(OA5410009L_GetFieldLen("SCRM_FILE_PATH")))

		oSubMod06ScrmGatilhos:SetValue('TAB_GATILHOS_SCRM', 'SCRM_SA1', "1")
		oSubMod06ScrmGatilhos:SetValue('TAB_GATILHOS_SCRM', 'SCRM_VCF', "1")
		oSubMod06ScrmGatilhos:SetValue('TAB_GATILHOS_SCRM', 'SCRM_VV1', "1")
		oSubMod06ScrmGatilhos:SetValue('TAB_GATILHOS_SCRM', 'SCRM_VO1', "1")
		oSubMod06ScrmGatilhos:SetValue('TAB_GATILHOS_SCRM', 'SCRM_VS1', "1")
		oSubMod06ScrmGatilhos:SetValue('TAB_GATILHOS_SCRM', 'SCRM_SF2', "1")
	endif
Return .t.

/*/{Protheus.doc} OA5410020J_PegaDataDeUltimaExecucao
	Vai pegar o SCRM_DELIMITA_INIT da VRN para exibição na tela de configurações
	@type  Static Function
	@author Renan Migliaris
	@since 29/10/2025
	/*/
Static Function OA5410020J_RetornaDataDeUltimaExecucao()
	local oJson := JsonObject():new()
	local cConfig := "SCRM_DLM"
	local aRetorno := {}

	DbSelectArea('VRN')
	DbSetOrder(1)

	if DbSeek(xFilial('VRN') + cConfig)
		oJson:FromJson(VRN->VRN_CONFIG)
	endif

	if oJson:HasProperty('ULTIMA_EXECUCAO')	
		aadd(aRetorno, sTod(oJson['ULTIMA_EXECUCAO']['DATA']))
		aadd(aRetorno, oJson['ULTIMA_EXECUCAO']['HORA'])
	else
		aadd(aRetorno, Ctod("  /  /  "))
		aadd(aRetorno, " ")
	endif
Return aRetorno
/*/{Protheus.doc} OA5410023J_GetStruct06SCRM
	Struct da 06 que vai ser o Gatilhos para o SCRM (vai ter os alias das tabelas)
	@type  Static Function
	@author Renan Migliaris
	@since 31/10/2025
/*/
Static Function OA5410023J_GetStruct06Scrm()
	local oStruct06Gatilhos := OFDMSStruct():new()
	
	oStruct06Gatilhos:AddField(;
		{;
			{'cTitulo', STR0047},; //'SA1 – Considera operações realizadas no cadastro do cliente?'
			{'cIdField', 'SCRM_SA1'},;
			{'nTamanho', 1},;
			{'aComboValues', {STR0028, STR0029}},; //"1=Sim" //"2=Não"
			{'bValid', { |a,b,c,d| OA5410003L_ValidaOpcao(a,b,c,d, "1,2")}},;
			{'lObrigat', .f.};
		};
	)

	oStruct06Gatilhos:AddField(;
		{;
			{'cTitulo', STR0048},; //'VCF – Considera operações realizadas no Cadastro Complementar do cliente?'
			{'cIdField', 'SCRM_VCF'},;
			{'nTamanho', 1},;
			{'aComboValues', {STR0028, STR0029}},; //"1=Sim" //"2=Não"
			{'bValid', { |a,b,c,d| OA5410003L_ValidaOpcao(a,b,c,d, "1,2")}},;
			{'lObrigat', .f.};
		};
	)

	oStruct06Gatilhos:AddField(;
		{;
			{'cTitulo', STR0049},; //'VV1 – Considera operações realizadas no cadastro do veículo?'
			{'cIdField', 'SCRM_VV1'},;
			{'nTamanho', 1},;
			{'aComboValues', {STR0028, STR0029}},; //"1=Sim" //"2=Não"
			{'bValid', { |a,b,c,d| OA5410003L_ValidaOpcao(a,b,c,d, "1,2")}},;
			{'lObrigat', .f.};
		};
	)

	oStruct06Gatilhos:AddField(;
		{;
			{'cTitulo', STR0050},; //'VO1 – Considera operações realizadas na OS?'
			{'cIdField', 'SCRM_VO1'},;
			{'nTamanho', 1},;
			{'aComboValues', {STR0028, STR0029}},; //"1=Sim" //"2=Não"
			{'bValid', { |a,b,c,d| OA5410003L_ValidaOpcao(a,b,c,d, "1,2")}},;
			{'lObrigat', .f.};
		};
	)

	oStruct06Gatilhos:AddField(;
		{;
			{'cTitulo', STR0051},; //'VS1 – Considera operações realizadas no Orçamento?'
			{'cIdField', 'SCRM_VS1'},;
			{'nTamanho', 1},;
			{'aComboValues', {STR0028, STR0029}},; //"1=Sim" //"2=Não"
			{'bValid', { |a,b,c,d| OA5410003L_ValidaOpcao(a,b,c,d, "1,2")}},;
			{'lObrigat', .f.};
		};
	)

	oStruct06Gatilhos:AddField(;
		{;
			{'cTitulo', STR0052},; //'SF2 – Considera operações realizadas em emissão de Nota Fiscal?'
			{'cIdField', 'SCRM_SF2'},;
			{'nTamanho', 1},;
			{'aComboValues', {STR0028, STR0029}},; //"1=Sim" //"2=Não"
			{'bValid', { |a,b,c,d| OA5410003L_ValidaOpcao(a,b,c,d, "1,2")}},;
			{'lObrigat', .f.};
		};
	)
Return oStruct06Gatilhos

/*/{Protheus.doc} OA5410024J_LoadModel06Scrm
	@type  Static Function
	@author Renan Migliaris
	@since 31/10/2025
	/*/
Static Function OA5410024J_LoadModel06Scrm()
	local aRetorno := {}
	local oCfg := OfScaniaConfig():New("SCRM","OFIA541")
	local oJson := oCfg:getConfig()
	local lTemJson := (ValType(oJson) == "J")
	local nX := 0

	if !lTemJson .or. !oJson:HasProperty(aGatScrm[1]) .or. empty(oJson[aGatScrm[1]])
		for nX := 1 to len(aGatScrm)
			aadd(aRetorno, '1')
		next
	else
		for nX := 1 to len(aGatScrm)
			aadd(aRetorno, oJson[aGatScrm[nx]])
		next
	endif
	 
	freeObj(oJson)
Return aRetorno

/*/{Protheus.doc} OA5410026J_WhenDoFilePathScrm
	@type  Static Function
	@author Renan Migliaris
	@since 04/11/2025	
/*/
Static Function OA5410026J_WhenDoFilePathScrm(oModel)
	local lRet := .f.
    local cValor := ""

    cValor := oModel:GetValue("SCRM_GERA_ARQUIVO")

    If cValor == "1"
		oModel:GetStruct():SetProperty('SCRM_FILE_PATH', MODEL_FIELD_OBRIGAT, .t.)
        lRet := .t.
    Else
		oModel:GetStruct():SetProperty('SCRM_FILE_PATH', MODEL_FIELD_OBRIGAT, .f.)
        lRet := .f.
    EndIf
Return lRet

/*/{Protheus.doc} OA5410100N_GetStructArmsToken
@description Retorna a estrutura de campos necessária para configurar o token de autenticação ARMS.
@author      Lucas Brustolin
@since       07/11/2025
@version     1.0
@type        Function
@obs         Estrutura inclui parâmetros como ambiente, tipo de autenticação, client ID/secret, URL do token, grant type, scope e content-type.
@return      Object OFDMSStruct com os campos configuráveis para autenticação ARMS.
*/
Static Function OA5410100N_GetStructArmsToken()
   Local oStruToken := OFDMSStruct():New()

   oStruToken:AddField({ {'cTitulo',STR0077}, ; // 'Ambiente'
                 {'cIdField','ARMS_AMBIENTE'}, ;
                 {'nTamanho', OA5410009L_GetFieldLen('ARMS_AMBIENTE')}, ;
                 {'aComboValues', {"1="+ STR0078, "2=" + STR0079}}, ; // '1=Produção','2=Homologação'
                 {'bValid', {|a,b,c,d| OA5410003L_ValidaOpcao(a,b,c,d,'1,2')}}, ;
                 {'lObrigat', .F.} })

   oStruToken:AddField({	{'cTitulo', STR0033},; //'Integração Ativa?'
				{'cIdField', "ARMS_INTEGRACAO_ATIVA"},;
				{'nTamanho', OA5410009L_GetFieldLen("ARMS_INTEGRACAO_ATIVA")},;
				{'aComboValues', {STR0028, STR0029}},; //'Produo','Homologao'
				{'bValid', { |a,b,c,d| OA5410003L_ValidaOpcao(a,b,c,d, "1,2")}},;
				{'lObrigat', .F.},;
				{'cTooltip', STR0055}}) //"Ativa ou desativa integrao"


   oStruToken:AddField({ {'cTitulo',STR0080}, ; // 'Tipo de Autenticação'
                 {'cIdField','ARMS_TPAUT'}, ;
                 {'nTamanho', OA5410009L_GetFieldLen('ARMS_TPAUT')}, ;
                 {'aComboValues', {'1='+ STR0081 }}, ; // Basic Auth
                 {'bValid', {|a,b,c,d| OA5410003L_ValidaOpcao(a,b,c,d,'1')}}, ;
                 {'lObrigat', .F.} })

   oStruToken:AddField({ {'cTitulo',STR0082}, ; // 'Client ID'
                 {'cIdField','ARMS_CLIENTID'}, ;
                 {'nTamanho', OA5410009L_GetFieldLen('ARMS_CLIENTID')}, ;
                 {'cPicture','@X'}, {'lObrigat', .F.} })

   oStruToken:AddField({ {'cTitulo',STR0083}, ; // 'Client Secret'
                 {'cIdField','ARMS_CLIENTSEC'}, ;
                 {'nTamanho', OA5410009L_GetFieldLen('ARMS_CLIENTSEC')}, ;
                 {'cPicture','@X'}, {'lObrigat', .F.} })

   oStruToken:AddField({ {'cTitulo',STR0084}, ; // 'Token URL'
                 {'cIdField','ARMS_TOKEN_URL'}, ;
                 {'nTamanho', OA5410009L_GetFieldLen('ARMS_TOKEN_URL')}, ;
                 {'cPicture','@X'}, {'lObrigat', .F.} })

   oStruToken:AddField({ {'cTitulo',STR0085}, ; // 'Grant Type'
                 {'cIdField','ARMS_GRANTTYPE'}, ;
                 {'nTamanho', OA5410009L_GetFieldLen('ARMS_GRANTTYPE')}, ;
                 {'lObrigat', .F.} })

   oStruToken:AddField({ {'cTitulo',STR0086}, ; // 'Scope'
                 {'cIdField','ARMS_SCOPE'}, ;
                 {'nTamanho', OA5410009L_GetFieldLen('ARMS_SCOPE')}, ;
                 {'lObrigat', .F.} })

   oStruToken:AddField({ {'cTitulo',STR0087}, ; // 'Content-Type'
                 {'cIdField','ARMS_CONTTYPE'}, ;
                 {'nTamanho', OA5410009L_GetFieldLen('ARMS_CONTTYPE')}, ;
                 {'aComboValues', {'1='+STR0088,'2='+STR0089,'3='+STR0090,'4='+STR0090}}, ; // "application/json" # "application/x-www-form-urlencoded" # "multipart/form-data" "ext/plain"   
                 {'bValid', {|a,b,c,d| OA5410003L_ValidaOpcao(a,b,c,d,'1,2,3,4')}}, ;
                 {'lObrigat', .F.} })

Return( oStruToken )


/*/{Protheus.doc} OA5410101N_LoadModelArmsToken
@description Carrega os valores do modelo de configuração de autenticação ARMS a partir do JSON salvo em memória ou utiliza valores padrão 
	(fallbacks seguros). Ideal para preenchimento automático dos campos da tela de configuração ARMS Token quando não houver dados persistidos ainda. 
@author      Lucas Brustolin
@since       07/11/2025
@version     1.0
@type        Function
@return      Array com os dados carregados (ambiente, tipo autenticação, client ID, secret, etc).
*/
Static Function OA5410101N_LoadModelArmsToken()

	Local aRetorno	:= {}
	local oCfg		:= OfScaniaConfig():New('ARMS','OFIA541')
	Local oJson 	:= oCfg:getConfig()
	Local cAmb  	:= 'PRODUCAO'
	Local lTemJson	:= (ValType(oJson) == 'J')
	Local nX 		:= 0


   If !lTemJson .or. !oJson:HasProperty(aARMSToken[1]) .or. empty(oJson[aARMSToken[1]])
      aAdd(aRetorno,'1') // ARMS_CFG_AMBIENTE
	  aAdd(aRetorno,'1') // ARMS_INTEGRACAO_ATIVA
      aAdd(aRetorno,'1') // ARMS_TPAUT
      aAdd(aRetorno, Space(OA5410009L_GetFieldLen('ARMS_CLIENTID')))
      aAdd(aRetorno, Space(OA5410009L_GetFieldLen('ARMS_CLIENTSEC')))
      aAdd(aRetorno, Space(OA5410009L_GetFieldLen('ARMS_TOKEN_URL')))
      aAdd(aRetorno, Space(OA5410009L_GetFieldLen('ARMS_GRANTTYPE')) )
      aAdd(aRetorno, Space(OA5410009L_GetFieldLen('ARMS_SCOPE')))
      aAdd(aRetorno,'2') // x-www-form-urlencoded
   Else

		if ((ValType(oJson["PRODUCAO"]) <> 'U'))
			cAmb := "PRODUCAO"
		else 
			cAmb := "HOMOLOGACAO"
		endif
		
		For nX := 1 To len(aARMSToken)
			Aadd(aRetorno, oJson[aARMSToken[nx]])
		Next
   EndIf

   FreeObj(oJson)
   freeObj(oCfg)
Return aRetorno


/*/{Protheus.doc} OA5410102N_GetStructArmsConsulta
@description Retorna a estrutura de campos para a configuração da consulta ARMS com autenticação via Bearer Token, incluindo campos para URL 
	base e endpoint da API da Scania. Estrutura utilizada para comunicação com o serviço de consulta de contratos da Scania (API PMS). Ideal 
	para configuração inicial no configurador interno (oCfgScInt). 
@author      Lucas Brustolin
@since       07/11/2025
@version     1.0
@type        Function
@return      Object OFDMSStruct com os campos configuráveis da consulta ARMS.
*/
Static Function OA5410102N_GetStructArmsConsulta()
   Local oStructCon  := OFDMSStruct():New()

   oStructCon:AddField({ {'cTitulo',STR0092}, ; // 'Tipo de Autenticação'
                 {'cIdField','ARMS_TPAUT2'}, ;
                 {'nTamanho', OA5410009L_GetFieldLen('ARMS_TPAUT2')}, ;
                 {'aComboValues', {'1='+STR0093}}, ; // Bearer Token
                 {'bValid', {|a,b,c,d| OA5410003L_ValidaOpcao(a,b,c,d,'1')}}, ;
                 {'lObrigat', .F.} })

   oStructCon:AddField({ {'cTitulo',STR0094}, ; // 'URL Base'
                 {'cIdField','ARMS_URLBASE'}, ;
                 {'nTamanho', OA5410009L_GetFieldLen('ARMS_URLBASE')}, ;
                 {'cPicture','@X'}, {'lObrigat', .F.} })

   oStructCon:AddField({ {'cTitulo',STR0095}, ; // 'EndPoint'
                 {'cIdField','ARMS_ENDPOINT'}, ;
                 {'nTamanho', OA5410009L_GetFieldLen('ARMS_ENDPOINT')}, ;
                 {'cPicture','@X'}, {'lObrigat', .F.} })

Return( oStructCon )


/*/{Protheus.doc} OA5410103N_LoadModelArmsConsulta
@description Carrega os valores do modelo da consulta ARMS (tipo de autenticação, URL base e endpoint), utilizando os dados
	 persistidos no JSON de configuração. Caso ausente, insere valores padrão da Scania. Utilizada para preencher 
	 automaticamente os campos de configuração da consulta de contratos via API da Scania, com token do tipo Bearer Token. 
@author      Lucas Brustolin
@since       07/11/2025
@version     1.0
@type        Function
@return      Array com os dados da consulta (auth type, URL base, endpoint).
*/
Static Function OA5410103N_LoadModelArmsConsulta()
   Local aRet := {}
   local oCfg := OfScaniaConfig():New('ARMS','OFIA541')
   Local oJson := oCfg:getConfig()
   local lTemJson := (ValType(oJson) == 'J')
   local nX := 0

   if !lTemJson .or. !oJson:HasProperty(aARMSCons[1]) .or. empty(oJson[aARMSCons[1]])
		aAdd(aRet, '1') // ARMS_TPAUT2
		aAdd(aRet, Space(OA5410009L_GetFieldLen('ARMS_URLBASE')) )
		aAdd(aRet, Space(OA5410009L_GetFieldLen('ARMS_ENDPOINT')) )
   Else
		for nX := 1 To len(aARMSCons)
			aadd(aRet, oJson[aARMSCons[nx]])
		next
   endif

   FreeObj(oJson)
   freeObj(oCfg)
Return aRet

/*/{Protheus.doc} OA5410104N_TrocaDadosArms
@description Atualiza dinamicamente os modelos de configuração ARMS (token e consulta) com base no ambiente selecionado (produção ou homologação). 
	Utiliza os dados salvos em JSON ou insere valores padrões caso os dados não estejam disponíveis. Recurso acionado na alteração de ambiente no 
	configurador de integração interna (oCfgScInt). 
@param       oModelL    -> Objeto com os modelos 'TAB_ARMS' e 'TAB_ARMS_CONSULTA'
@param       cField     -> Nome do campo alterado (geralmente o ambiente)
@param       xValue     -> Novo valor do campo (ex: '1' para produção, '2' para homologação)
@param       xOldValue  -> Valor anterior do campo alterado
@return      Boolean    -> Retorna .T. após concluir a atualização dos dados no modelo
@author      Lucas Brustolin
@since       07/11/2025
@version     1.0
@type        Function
*/ //TODO a lógica da troca de dados também mudou de acordo com a mudança da classe
Static Function OA5410104N_TrocaDadosArms(oModelL, cField, xValue, xOldValue)
   Local oTok  		:= oModelL:GetModel('TAB_ARMS')
   Local oCons 		:= oModelL:GetModel('TAB_ARMS_CONSULTA')
   Local oJson 		:= oCfgScInt:GetValue('ARMS')
   Local oStruToken := OA5410100N_GetStructArmsToken() 
   Local oStruCons	:= OA5410102N_GetStructArmsConsulta()
   Local aFieldsTok := oStruToken:GetModel():GetFields()
   Local aFieldsCon := oStruCons:GetModel():GetFields()
   local cPropEnv 	:= ''
   Local nX 		:= 0


	if ValType(oJson) <> "J"
		oJson := JsonObject():New()
	endif

	if xValue == '1'
		cPropEnv := 'PRODUCAO'
	elseif xValue == '2'
		cPropEnv := 'HOMOLOGACAO'
	endif

	if oJson:HasProperty(cPropEnv) .and. (ValType(oJson[cPropEnv]) == 'J')
      // Token
		For nx := 1 to len(aFieldsTok)
			if aFieldsTok[nx][3] == cField
				loop
			endif
			oTok:SetValue('TAB_ARMS', aFieldsTok[nx][3], oJson[cPropEnv][aFieldsTok[nx][3]])
		Next

		For nx := 1 to len(aFieldsCon)
			oCons:SetValue('TAB_ARMS_CONSULTA', aFieldsCon[nx][3], oJson[cPropEnv][aFieldsCon[nx][3]])
		Next

   Else
      // Defaults seguros
	  oTok:SetValue('TAB_ARMS','ARMS_INTEGRACAO_ATIVA'	, '0')
      oTok:SetValue('TAB_ARMS','ARMS_TPAUT'			, '1')
      oTok:SetValue('TAB_ARMS','ARMS_CLIENTID'		, Space(OA5410009L_GetFieldLen('ARMS_CLIENTID')))
      oTok:SetValue('TAB_ARMS','ARMS_CLIENTSEC'		, Space(OA5410009L_GetFieldLen('ARMS_CLIENTSEC')))
      oTok:SetValue('TAB_ARMS','ARMS_TOKEN_URL'		, Space(OA5410009L_GetFieldLen('ARMS_TOKEN_URL')))
      oTok:SetValue('TAB_ARMS','ARMS_GRANTTYPE'		, Space(OA5410009L_GetFieldLen('ARMS_GRANTTYPE')))
      oTok:SetValue('TAB_ARMS','ARMS_SCOPE'			, Space(OA5410009L_GetFieldLen('ARMS_SCOPE')))
      oTok:SetValue('TAB_ARMS','ARMS_CONTTYPE'		, '2')

      oCons:SetValue('TAB_ARMS_CONSULTA','ARMS_TPAUT2','1')
      oCons:SetValue('TAB_ARMS_CONSULTA','ARMS_URLBASE','')
      oCons:SetValue('TAB_ARMS_CONSULTA','ARMS_ENDPOINT','')
   EndIf

   FreeObj(oJson)
Return .T.

/*/{Protheus.doc} OA54100262_Struct07CotoToken
	Model da seção Token da aba Control Tower
	@type  Static Function
	@author Bruno Forcato
	@since 05/11/2025
	/*/
Static Function OA54100262_Struct07CotoToken()
	local oStruct07CotoToken := OFDMSStruct():new()

	oStruct07CotoToken:AddField(;
		{;
			{'cTitulo', STR0003},;	//'Ambiente'
			{'cIdField', 'COTO_AMBIENTE'},;
			{'nTamanho', OA5410009L_GetFieldLen("COTO_AMBIENTE")},;
			{'aComboValues', {"1="+ STR0005, "2=" + STR0006}},;		//'Produção','Homologação'
			{'bValid', { |a,b,c,d| OA5410003L_ValidaOpcao(a,b,c,d, "1,2")}},;
			{'lObrigat', .F.},;
			{'cTooltip', STR0003};	//'Ambiente'
		};
	)

	oStruct07CotoToken:AddField(;
		{;
			{'cTitulo', STR0033},; //'Integração Ativa?'
			{'cIdField', 'COTO_INTEGRACAO_ATIVA'},;
			{'nTamanho', OA5410009L_GetFieldLen("COTO_INTEGRACAO_ATIVA")},;
			{'bValid', { |a,b,c,d| OA5410003L_ValidaOpcao(a,b,c,d, "1,2")}},;
			{'aComboValues', {STR0028, STR0029}},; //"1=Sim" //"2=Não"
			{'lObrigat', .F.},;
			{'cTooltip', STR0033}; //'Integração Ativa?'
		};
	)

	oStruct07CotoToken:AddField(;
		{;
			{'cTitulo', STR0004},;	//'Tipo de Autenticação'
			{'cIdField', "COTO_TPAUT" },;
			{'nTamanho', OA5410009L_GetFieldLen("COTO_TPAUT") },;
			{'aComboValues', {"1="+ STR0062}},;	//Basic Auth
			{'bValid', { |a,b,c,d| OA5410003L_ValidaOpcao(a,b,c,d, "1")}},;
			{'lObrigat', .F. },;
			{'cTooltip', STR0004};	//'Tipo de Autenticação'
		};
	)

	oStruct07CotoToken:AddField(;
		{;
			{'cTitulo', STR0007},;	//'Client ID'
			{'cIdField', "COTO_CLIENTEID"},;
			{'nTamanho', OA5410009L_GetFieldLen("COTO_CLIENTEID")},;
			{'cPicture', '@X'},;
			{'lObrigat', .F.},;
			{'cTooltip', STR0007};	//'Client ID'
		};
	)

	oStruct07CotoToken:AddField(;
		{;	
			{'cTitulo', STR0008},;	//'Client Secret'
			{'cIdField', "COTO_CLIENTESECRET"},;
			{'nTamanho', OA5410009L_GetFieldLen("COTO_CLIENTESECRET")},;
			{'cPicture', '@X'},;
			{'lObrigat', .F.},;
			{'cTooltip', STR0008};	//'Client Secret'
		};
	)
	
	oStruct07CotoToken:AddField(;
		{;	
			{'cTitulo', STR0009},;	//'URL'
			{'cIdField', "COTO_URL"},;
			{'nTamanho', OA5410009L_GetFieldLen("COTO_URL")},;
			{'cPicture', '@X'},;
			{'lObrigat', .F.},;
			{'cTooltip', STR0009};	//'URL'
		};
	)

	oStruct07CotoToken:AddField(;
		{;	
			{'cTitulo', STR0063},;	//'Username'
			{'cIdField', "COTO_USERNAME"},;
			{'nTamanho', OA5410009L_GetFieldLen("COTO_USERNAME")},;
			{'cPicture', '@X'},;
			{'lObrigat', .F.},;
			{'cTooltip', STR0064};	//'Username do Body da requisição'
		};
	)

	oStruct07CotoToken:AddField(;
		{;	
			{'cTitulo', STR0065},;	//'Password'
			{'cIdField', "COTO_PASSWORD"},;
			{'nTamanho', OA5410009L_GetFieldLen("COTO_PASSWORD")},;
			{'cPicture', '@X'},;
			{'lObrigat', .F.},;
			{'cTooltip', STR0066};	//'Password do Body da requisição'
		};
	)

	oStruct07CotoToken:AddField(;
		{;	
			{'cTitulo', STR0010},;	//'Grant Type'
			{'cIdField', "COTO_GRANTTYPE"},;
			{'nTamanho', OA5410009L_GetFieldLen("COTO_GRANTTYPE")},;
			{'cPicture', '@X'},;
			{'lObrigat', .F.},;
			{'cTooltip', STR0010};	//'Grant Type'
		};
	)

	oStruct07CotoToken:AddField(;
		{;
			{'cTitulo', STR0067},;  //'Content-Type'
			{'cIdField', "COTO_CONTENTTYPE" },;
			{'nTamanho', OA5410009L_GetFieldLen("COTO_CONTENTTYPE") },;
			{'aComboValues', {"1=application/json", "2=application/x", "3=www-form-urlencoded", "4=multipart/form-data", "5=text/plain"}},;
			{'bValid', { |a,b,c,d| OA5410003L_ValidaOpcao(a,b,c,d, "1,2,3,4,5")}},;
			{'lObrigat', .F. },;
			{'cTooltip', STR0067};  //'Content-Type'
		};
	)

	
Return oStruct07CotoToken

/*/{Protheus.doc} OA54100272_LoadModel07CotoToken
	@type  Static Function
	@author Bruno Forcato
	@since 05/11/2025
	/*/
Static Function OA54100272_LoadModel07CotoToken()
	local aRetorno := {}
	local oCfg := OfScaniaConfig():New("CONTROLTOWER","OFIA541")
	local oJson := oCfg:getConfig()
	local lTemJson := (ValType(oJson) == "J")
	local nX := 0

	if !lTemJson .or. !oJson:HasProperty(aCotoToken[2]) .or. empty(oJson[aCotoToken[2]])
		aadd(aRetorno, iif(oCfg:cEnvironment == "PRODUCAO", '1', '2')) //COTO_AMBIENTE
		aadd(aRetorno, '1') //COTO_TPAUT
		aadd(aRetorno, '1') //COTO_INTEGRACAO_ATIVA
		aadd(aRetorno, Space(OA5410009L_GetFieldLen('COTO_CLIENTEID'))) //COTO_CLIENTEID
		aadd(aRetorno, Space(OA5410009L_GetFieldLen('COTO_CLIENTESECRET'))) //COTO_CLIENTESECRET
		aadd(aRetorno, Space(OA5410009L_GetFieldLen('COTO_URL'))) //COTO_URL
		aadd(aRetorno, Space(OA5410009L_GetFieldLen('COTO_USERNAME'))) //COTO_USERNAME
		aadd(aRetorno, Space(OA5410009L_GetFieldLen('COTO_PASSWORD'))) //COTO_PASSWORD
		aadd(aRetorno, Space(OA5410009L_GetFieldLen('COTO_GRANTTYPE'))) //COTO_GRANTTYPE
		aadd(aRetorno, '1') //COTO_CONTENTTYPE
	else
		aadd(aRetorno, iif(oCfg:cEnvironment == "PRODUCAO", '1', '2'))
		
		for nX := 2 to len(aCotoToken)
			aadd(aRetorno, oJson[aCotoToken[nx]])
		next
	endif
	 
	freeObj(oJson)
Return aRetorno

/*/{Protheus.doc} OA54100262_Struct08Coto
	Model da seção Control Tower da aba Control Tower
	@type  Static Function
	@author Bruno Forcato
	@since 05/11/2025
	/*/
Static Function OA54100282_Struct08Coto()
	local oStruct08Coto := OFDMSStruct():new()

	oStruct08Coto:AddField(;
		{;	
			{'cTitulo', STR0004},;  //'Tipo de Autenticação'
			{'cIdField', "COTO_TPAUT2" },;
			{'nTamanho', OA5410009L_GetFieldLen("COTO_TPAUT2") },;
			{'aComboValues', {"1=Bearer Token"}},;
			{'bValid', { |a,b,c,d| OA5410003L_ValidaOpcao(a,b,c,d, "1")}},;
			{'cPicture', '@X'},;
			{'lObrigat', .F. },;
			{'cTooltip', STR0004}; 	//'Tipo de Autenticação'
		};
	)

	oStruct08Coto:AddField(;
		{;	
			{'cTitulo', STR0013},;	//'URL Base'
			{'cIdField', "COTO_URLBASE"},;
			{'nTamanho', OA5410009L_GetFieldLen("COTO_URLBASE")},;
			{'cPicture', '@X'},;
			{'lObrigat', .F.},;
			{'cTooltip', STR0013};	//'URL Base'
		};
	)

	oStruct08Coto:AddField(;
		{;	
			{'cTitulo', STR0068},;	//Endpoint'
			{'cIdField', "COTO_ENDPOINT"},;
			{'nTamanho', OA5410009L_GetFieldLen("COTO_ENDPOINT")},;
			{'cPicture', '@X'},;
			{'lObrigat', .F.},;
			{'cTooltip', STR0068};	//'Endpoint'
		};
	)
	
Return oStruct08Coto

/*/{Protheus.doc} OA54100272_LoadModel07CotoToken
	@type  Static Function
	@author Bruno Forcato
	@since 05/11/2025
	/*/
Static Function OA54100292_LoadModel08Coto()
	local aRetorno := {}
	local oCfg := OfScaniaConfig():New("CONTROLTOWER","OFIA541")
	local oJson := oCfg:getConfig()
	local cAmb := "PRODUCAO"
	local lTemJson := (ValType(oJson) == "J")
	local nX := 0

	if !lTemJson .or. !oJson:HasProperty(aCoto[1]) .or. empty(oJson[aCoto[1]])
		aadd(aRetorno, '1') //COTO_TPAUT2
		aadd(aRetorno, Space(OA5410009L_GetFieldLen('COTO_URLBASE'))) //COTO_URLBASE
		aadd(aRetorno, Space(OA5410009L_GetFieldLen('COTO_ENDPOINT'))) //COTO_ENDPOINT
	else
		if ((ValType(oJson["PRODUCAO"]) <> 'U'))
			cAmb := "PRODUCAO"
		else 
			cAmb := "HOMOLOGACAO"
		endif
		
		for nX := 1 to len(aCoto)
			aadd(aRetorno, oJson[aCoto[nx]])
		next
	endif
	 
	freeObj(oJson)
Return aRetorno

/*/{Protheus.doc} OA54100302_Struct09CotoGeneral
	Model da seção Gerais da aba Control Tower
	@type  Static Function
	@author Bruno Forcato
	@since 05/11/2025
	/*/
Static Function OA54100302_Struct09CotoGeneral()
	local oStruct09CotoGeneral := OFDMSStruct():new()

	oStruct09CotoGeneral:AddField(;
		{;	
			{'cTitulo', STR0071},;	//'Obter tipo de Contrato'
			{'cIdField', "COTO_OBTERTPCONT" },;
			{'nTamanho', OA5410009L_GetFieldLen("COTO_OBTERTPCONT") },;
			{'aComboValues', {"1=Sempre consultar API Control Tower","2=Priorizar Cadastro Contrato Protheus"}},;
			{'bValid', { |a,b,c,d| OA5410003L_ValidaOpcao(a,b,c,d, "1,2")}},;
			{'cPicture', '@X'},;
			{'lObrigat', .F. },;
			{'cTooltip', STR0071};	//'Obter tipo de Contrato'
		};
	)

	oStruct09CotoGeneral:AddField(;
		{;	
			{'cTitulo', STR0108},;	//'Quantidade de horas para considerar evento como agendado'
			{'cIdField', "COTO_QTDHEVENTO" },;
			{'nTamanho', OA5410009L_GetFieldLen("COTO_QTDHEVENTO") },;
			{'cTipo', 'N'},;
			{'lObrigat', .F. },;
			{'cTooltip', STR0108};	//'Quantidade de horas para considerar evento como agendado'
		};
	)

	oStruct09CotoGeneral:AddField(;
		{;
			{'cTitulo', STR0109},;  //'Marca do veículo a ser integrada?'
			{'cIdField', "COTO_MARCAVEIINT" },;
			{'nTamanho', OA5410009L_GetFieldLen("COTO_MARCAVEIINT")},;
			{'cLookUp', 'VE1'},;
			{'lObrigat', .F. },;
			{'bValid'   , FWBuildFeature(STRUCT_FEATURE_VALID,'Vazio() .or. ExistCpo("VE1")') }, ;
			{'cTooltip', STR0109}; //"Marca do veículo a ser integrada?"
		};
	)
	
	oStruct09CotoGeneral:AddField(;
			{;
				{'cTitulo', STR0126},;  //'Servico Checklist'
				{'cIdField', "COTO_SRVCHECK" },;
				{'nTamanho', OA5410009L_GetFieldLen("COTO_SRVCHECK")},;
				{'cPicture', '@!'},;
				{'lObrigat', .F. },;
				{'cTooltip', STR0127}; //"ódigos de serviço checklist separados por / (ex: 00005095/00005096). Serão excluídos do cálculo de status e tempo padrão dos apontamentos."
			};
		)

	oStruct09CotoGeneral:AddField(;
		{;
			{'cTitulo', STR0128},;	//'Max. de Tentativas de Integracao'
			{'cIdField', "COTO_MAXTENT" },;
			{'nTamanho', OA5410009L_GetFieldLen("COTO_MAXTENT") },;
			{'cPicture', '@E 999'},;
			{'cTipo', 'N'},;
			{'lObrigat', .F. },;
			{'cTooltip', STR0129};	//'Numero maximo de tentativas de integracao por evento'
		};
	)
		

Return oStruct09CotoGeneral

/*/{Protheus.doc} OA54100312_LoadModel09CotoGeneral
	@type  Static Function
	@author Bruno Forcato
	@since 05/11/2025
	/*/
Static Function OA54100312_LoadModel09CotoGeneral()
	local aRetorno := {}
	local oCfg := OfScaniaConfig():New("CONTROLTOWER","OFIA541")
	local oJson := oCfg:getConfig()
	local cAmb := "PRODUCAO"
	local lTemJson := (ValType(oJson) == "J")
	local nX := 0

	if !lTemJson .or. !oJson:HasProperty(aCotoGeneral[1]) .or. empty(oJson[aCotoGeneral[1]])
		aadd(aRetorno, '1') //COTO_OBTERTPCONT
		aadd(aRetorno, 12) //COTO_QTDHEVENTO
		aadd(aRetorno, Space(OA5410009L_GetFieldLen("COTO_MARCAVEIINT"))) //"COTO_MARCAVEIINT"
		aadd(aRetorno, Space(OA5410009L_GetFieldLen("COTO_SRVCHECK"))) //"COTO_SRVCHECK"  
		aadd(aRetorno, 3) //"COTO_MAXTENT" - default 3 tentativas
	else
		if ((ValType(oJson["PRODUCAO"]) <> 'U'))
			cAmb := "PRODUCAO"
		else 
			cAmb := "HOMOLOGACAO"
		endif
		
		for nX := 1 to len(aCotoGeneral)
			aadd(aRetorno, oJson[aCotoGeneral[nx]])
		next
	endif
	 
	freeObj(oJson)
Return aRetorno

/*/{Protheus.doc} OA54100332_Struct10CotoGridConcessionaria
	Model da seção ID Concessionária da aba Control Tower
	@type  Static Function
	@author Bruno Forcato
	@since 05/11/2025
	/*/
Static Function OA54100332_Struct10CotoGridConcessionaria()
	local oStruct10CotoGridConcessionaria := OFDMSStruct():new()

	oStruct10CotoGridConcessionaria:AddField(;
		{;	
			{'cTitulo', STR0098},;	//'Filial'
			{'cIdField', "COTO_GCONC_FILIAL"},;
			{'nTamanho', OA5410009L_GetFieldLen("COTO_GCONC_FILIAL")},;
			{'cPicture', '@X'},;
			{'lObrigat', .F.},;
			{'bValid'   , FWBuildFeature(STRUCT_FEATURE_VALID,'Vazio() .or. ExistCpo("SM0", cEmpAnt + FWFldGet("COTO_GCONC_FILIAL",,,.T.))') },;
			{'cLookUp', 'SM0'},;
			{'cTooltip', STR0099};	//"Filial da Grid de ID Concessionária"
		};
	)

	oStruct10CotoGridConcessionaria:AddField(;
		{;	
			{'cTitulo', STR0096},;	//'ID Concessionária'
			{'cIdField', "COTO_GCONC_ID"},;
			{'nTamanho', OA5410009L_GetFieldLen("COTO_GCONC_ID")},;
			{'cPicture', '@X'},;
			{'lObrigat', .F.},;
			{'cTooltip', STR0100};	//'Campo de ID Concessionária da GRID'
		};
	)
	
Return oStruct10CotoGridConcessionaria

/*/{Protheus.doc} OA54100342_LoadModel10CotoGridConcessionaria
    @type  Static Function
    @author Bruno
    @since 05/11/2025
/*/
Static Function OA54100342_LoadModel10CotoGridConcessionaria()
	local aRetorno := {}
	local oCfg := OfScaniaConfig():New("CONTROLTOWER","OFIA541")
	local oJson := oCfg:getConfig()
	local lTemJson := (ValType(oJson) == "J")
	local cArray   := "COTO_GCONC"
	local nLine, nField   := 0
	local oItem
	local oGrid := oModel:GetModel():getModel("TAB_CONCESSIONARIA_COTO")

	if lTemJson .and. !empty(oJson[cArray]) .and. Len(oJson[cArray]) > 0
		for nLine := 1 to Len(oJson[cArray])
			oItem := oJson[cArray][nLine]
			oGrid:AddLine()

			for nField := 1 to Len(aCotoGridConcessionaria)
				oGrid:SetValue(aCotoGridConcessionaria[nField], oItem[aCotoGridConcessionaria[nField]])
			next
		next
	endif
Return aRetorno

/*/{Protheus.doc} OA54100352_Struct11CotoGridTPContrato
	Model da seção Tipos de Contrato da aba Control Tower
	@type  Static Function
	@author Bruno Forcato
	@since 05/11/2025
	/*/
Static Function OA54100352_Struct11CotoGridTPContrato()
	local oStruct11CotoGridTPContrato := OFDMSStruct():new()

	oStruct11CotoGridTPContrato:AddField(;
		{;	
			{'cTitulo', STR0101},;	//'Tipo de Contrato'
			{'cIdField', "COTO_GTPCONT_TPCONTRATO"},;
			{'nTamanho', OA5410009L_GetFieldLen("COTO_GTPCONT_TPCONTRATO")},;
			{'cPicture', '@X'},;
			{'lObrigat', .F.},;
			{'cLookUp', 'VX5BRA'},;
			{'cTooltip', STR0102};	//'Digite o tipo de contrato'
		};
	)
	
Return oStruct11CotoGridTPContrato

/*/{Protheus.doc} OA54100362_LoadModel11CotoGridTPContrato
    @type  Static Function
    @author Bruno
    @since 05/11/2025
/*/
Static Function OA54100362_LoadModel11CotoGridTPContrato()
	local aRetorno := {}
	local oCfg := OfScaniaConfig():New("CONTROLTOWER","OFIA541")
	local oJson := oCfg:getConfig()
	local lTemJson := (ValType(oJson) == "J")
	local cArray   := "COTO_GTPCONTRATOS"
	local nLine, nField   := 0
	local oItem
	local oGrid := oModel:GetModel():getModel("TAB_TP_CONTRATO_COTO")

	if lTemJson .and. !empty(oJson[cArray]) .and. Len(oJson[cArray]) > 0
		for nLine := 1 to Len(oJson[cArray])
			oItem := oJson[cArray][nLine]
			oGrid:AddLine()

			for nField := 1 to Len(aCotoGridTPContratos)
				oGrid:SetValue(aCotoGridTPContratos[nField], oItem[aCotoGridTPContratos[nField]])
			next
		next
	endif
Return aRetorno

/*/{Protheus.doc} OA54100322_TrocaDadosDeAmbienteControlTower
	Método que vai realizar a troca dos dados de acordo com o ambiente selecionado

	@type  Static Function
	@author Bruno Forcato
	@since 05/11/2025
/*/
Static Function OA54100322_TrocaDadosDeAmbienteControlTower(oModelL, cField, xValue, xOldValue)
	local oSubMod01	:= oModelL:GetModel("TAB_TOKEN_COTO")
	local oSubMod02	:= oModelL:GetModel("TAB_COTO")
	local oSubMod03	:= oModelL:GetModel("TAB_GERAIS_COTO")
	local oJson := oCfgScInt:GetValue("CONTROLTOWER")
	local cPropEnv := ''
	local oStru01 := OA54100262_Struct07CotoToken()
	local oStru02 := OA54100282_Struct08Coto()
	local oStru03 := OA54100302_Struct09CotoGeneral()
	local oStru04 := OA54100332_Struct10CotoGridConcessionaria()
	local oStru05 := OA54100352_Struct11CotoGridTPContrato()
	local oStru06 := OA54100353_Struct12CotoGridDePara()
	local aStru01 := oStru01:GetModel():GetFields()
	local aStru02 := oStru02:GetModel():GetFields()
	local aStru03 := oStru03:GetModel():GetFields()
	local aStru04 := oStru04:GetModel():GetFields()
	local aStru05 := oStru05:GetModel():GetFields()
	local aStru06 := oStru06:GetModel():GetFields()
	local oGrid04 := oModelL:GetModel():getModel("TAB_CONCESSIONARIA_COTO")
	local oGrid05 := oModelL:GetModel():getModel("TAB_TP_CONTRATO_COTO")
	local oGrid06 := oModelL:GetModel():getModel("TAB_DEPARA_COTO")
	
	local nX := 0
	
	if ValType(oJson) <> "J"
		oJson := JsonObject():New()
	endif

	if xValue == '1'
		cPropEnv := 'PRODUCAO'
	elseif xValue == '2'
		cPropEnv := 'HOMOLOGACAO'
	endif

	if oJson:HasProperty(cPropEnv) .and. (ValType(oJson[cPropEnv]) == 'J')
		for nx := 1 to len(aStru01)
			if aStru01[nx][3] == cField
				loop
			endif
			oSubMod01:SetValue('TAB_TOKEN_COTO', aStru01[nx][3], oJson[cPropEnv][aStru01[nx][3]])
		next
		for nx := 1 to len(aStru02)
			oSubMod02:SetValue('TAB_COTO', aStru02[nx][3], oJson[cPropEnv][aStru02[nx][3]])
		next
		for nx := 1 to len(aStru03)
			oSubMod03:SetValue('TAB_GERAIS_COTO', aStru03[nx][3], oJson[cPropEnv][aStru03[nx][3]])
		next

		OA54100372_TrocaDeDadosDaGridDoAmbiente(oGrid04, aStru04, cPropEnv, "COTO_GCONC", oJson)
		OA54100372_TrocaDeDadosDaGridDoAmbiente(oGrid05, aStru05, cPropEnv, "COTO_GTPCONTRATOS", oJson)
		OA54100372_TrocaDeDadosDaGridDoAmbiente(oGrid06, aStru06, cPropEnv, "COTO_GDEPARA", oJson)
	else
		//TAB_TOKEN_COTO - Token
		oSubMod01:SetValue("TAB_TOKEN_COTO", "COTO_INTEGRACAO_ATIVA", "0")
		oSubMod01:SetValue("TAB_TOKEN_COTO", "COTO_TPAUT", "1")
		oSubMod01:SetValue("TAB_TOKEN_COTO", "COTO_CLIENTEID", Space(OA5410009L_GetFieldLen('COTO_CLIENTEID')))
		oSubMod01:SetValue("TAB_TOKEN_COTO", "COTO_CLIENTESECRET", Space(OA5410009L_GetFieldLen("COTO_CLIENTESECRET")))
		oSubMod01:SetValue("TAB_TOKEN_COTO", "COTO_URL", Space(OA5410009L_GetFieldLen("COTO_URL")))
		oSubMod01:SetValue("TAB_TOKEN_COTO", "COTO_USERNAME", Space(OA5410009L_GetFieldLen("COTO_USERNAME")))
		oSubMod01:SetValue("TAB_TOKEN_COTO", "COTO_PASSWORD", Space(OA5410009L_GetFieldLen("COTO_PASSWORD")))
		oSubMod01:SetValue("TAB_TOKEN_COTO", "COTO_GRANTTYPE", Space(OA5410009L_GetFieldLen('COTO_GRANTTYPE')))
		oSubMod01:SetValue("TAB_TOKEN_COTO", "COTO_CONTENTTYPE", "1")
		//TAB_COTO - Control Tower
		oSubMod02:SetValue("TAB_COTO", "COTO_TPAUT2", "1")
		oSubMod02:SetValue("TAB_COTO", "COTO_URLBASE", Space(OA5410009L_GetFieldLen("COTO_URLBASE")))
		oSubMod02:SetValue("TAB_COTO", "COTO_ENDPOINT", Space(OA5410009L_GetFieldLen("COTO_ENDPOINT")))
		//TAB_GERAIS_COTO - Gerais
		oSubMod03:SetValue("TAB_GERAIS_COTO", "COTO_OBTERTPCONT", "1")
		oSubMod03:SetValue("TAB_GERAIS_COTO", "COTO_QTDHEVENTO", 12)
		oSubMod03:SetValue("TAB_GERAIS_COTO", "COTO_MARCAVEIINT", Space(OA5410009L_GetFieldLen("COTO_MARCAVEIINT")))
		oSubMod03:SetValue("TAB_GERAIS_COTO", "COTO_SRVCHECK", Space(OA5410009L_GetFieldLen("COTO_SRVCHECK")))  
		oSubMod03:SetValue("TAB_GERAIS_COTO", "COTO_MAXTENT", 3)

		OA54100402_LimpaGridModel(oGrid04, aStru04)
		OA54100402_LimpaGridModel(oGrid05, aStru05)
		OA54100402_LimpaGridModel(oGrid06, aStru06)
	endif
Return .t.

/*/{Protheus.doc} OA54100372_TrocaDeDadosDaGridDoAmbiente
	Função que vai faze a troca de dados da grid de acordo com o ambiente

	@type  Static Function
	@author Bruno Forcato
	@since 17/11/2025
/*/
static function OA54100372_TrocaDeDadosDaGridDoAmbiente( oGrid, aStru, cPropEnv, cGridName, oJson )
    local nLine, nField := 0
    local aData := {}

	If ValType(oJson) == "J" .And. oJson:HasProperty(cPropEnv) .And. ValType(oJson[cPropEnv]) == "J" ;
		.And. oJson[cPropEnv]:HasProperty(cGridName) .And. ValType(oJson[cPropEnv][cGridName]) == "A"
		aData := oJson[cPropEnv][cGridName]
	EndIf

		If Len(aData) == 0
		Return
	EndIf

	OA54100402_LimpaGridModel(oGrid, aStru)

 	for nLine := 1 to Len(aData)
		if nLine > 1
			oGrid:AddLine()
		endif

        for nField := 1 to Len(aStru)
            oGrid:SetValue(aStru[nField][3], aData[nLine][aStru[nField][3]])
        next
    next

	OA54100392_posicionaPrimeiraLinhaValida(oGrid, aStru)
return

/*/{Protheus.doc} OA54100382_limpaCamposDaLinha
	Limpa os campos das linhas

	@type  Static Function
	@author Bruno Forcato
	@since 16/11/2025
/*/
static function OA54100382_limpaCamposDaLinha(oGrid, aStru, nLine)
    local nField := 0

    for nField := 1 to Len(aStru)
        oGrid:ClearField(aStru[nField][3], nLine)
    next
return

/*/{Protheus.doc} OA54100392_posicionaPrimeiraLinhaValida
	Posiciona na primeira linha que possui dados ( atualmente esta na linha -1 por erro na grid)

	@type  Static Function
	@author Bruno Forcato
	@since 16/11/2025
/*/
static function OA54100392_posicionaPrimeiraLinhaValida(oGrid, aStru)
    local nLine, nField := 0
    local cField := ""
    local uValue := Nil

    for nLine := 1 to oGrid:Length()
        oGrid:GoLine(nLine)

        for nField := 1 to Len(aStru)
            cField := aStru[nField][3]
            uValue := oGrid:GetValue(cField)

            if !Empty(uValue)
                oGrid:GoLine(nLine-1)
                return
            endif
        next
    next
return

/*/{Protheus.doc} OA54100402_LimpaGridModel
	Limpa todas as linhas de uma grid de submodelo MVC de forma segura

	@type  Static Function
	@author Bruno Forcato
	@since 25/11/2026
/*/
Static Function OA54100402_LimpaGridModel(oGrid, aStru)
	Local nLine := 0

	If oGrid:CanClearData()
		oGrid:ClearData(.F., .F.)

		If oGrid:Length() == 0
			oGrid:AddLine()
		EndIf
		Return
	EndIf

	For nLine := oGrid:Length() To 1 Step -1
		oGrid:GoLine(nLine)

		If aStru != NIL
			OA54100382_limpaCamposDaLinha(oGrid, aStru, nLine)
		EndIf

		If oGrid:IsDeleted(nLine)
			Loop
		EndIf
	Next
Return

/*/{Protheus.doc} OA54100353_Struct12CotoGridDePara
	Struct do Grid De/Para Motivos de Interrupcao Control Tower.
	Colunas: 	Codigo Pausa Protheus, 
				Descricao Pausa, 
				Codigo Interrupcao Control Tower, 
				Descricao Interrupcao Control Tower

	@type  Static Function
	@author Diogo Barros
	@since 12/03/2026
	@version 12.1.2510
	@Return oStructDePara, object
/*/
Static Function OA54100353_Struct12CotoGridDePara()
	
	Local oStructDePara := OFDMSStruct():new()

	// Codigo Pausa Protheus - validacao VS0
	oStructDePara:AddField(;
		{;
			{'cTitulo', STR0112},;	//'Cod Pausa Protheus'
			{'cIdField', 'COTO_CODPAUSA'},;
			{'nTamanho', OA5410009L_GetFieldLen('COTO_CODPAUSA')},;
			{'cPicture', '@!'},;
			{'bValid', {|a,b,c,d| OA5410042M_ValidaPausaVS0(a,b,c,d)}},;
			{'cLookUp', 'VS0OFI'},;
			{'lObrigat', .T.},;
			{'cTooltip', STR0113};	//'Codigo do motivo de pausa cadastrado no Protheus (VS0 - Tipo Assunto 000006)'
		};
	)

	// Descricao Pausa Protheus - nao editavel (virtual)
	oStructDePara:AddField(;
		{;
			{'cTitulo', STR0114},;	//'Desc Pausa Protheus'
			{'cIdField', 'COTO_DESCPAUSA'},;
			{'nTamanho', OA5410009L_GetFieldLen('COTO_DESCPAUSA')},;
			{'cPicture', '@!'},;
			{'lObrigat', .F.},;
			{'bWhen', {|| .F.}},;
			{'cTooltip', STR0115};	//'Descricao automatica do motivo de pausa (VS0)'
		};
	)

	// Codigo Interrupcao Control Tower - validacao VX5
	oStructDePara:AddField(;
		{;
			{'cTitulo', STR0116},;	//'Cod Interrup CT'
			{'cIdField', 'COTO_CODINTERRUPCAO'},;
			{'nTamanho', OA5410009L_GetFieldLen('COTO_CODINTERRUPCAO')},;
			{'cPicture', '@!'},;
			{'bValid', {|a,b,c,d| OA5410043M_ValidaInterVX5(a,b,c,d)}},;
			{'cLookUp', 'VX5OFI'},;
			{'lObrigat', .T.},;
			{'cTooltip', STR0117};	//'Codigo de interrupcao aceito pelo Control Tower Scania (VX5)'
		};
	)

	// Descricao Interrupcao Control Tower - nao editavel (virtual)
	oStructDePara:AddField(;
		{;
			{'cTitulo', STR0118},;	//'Desc Interrup CT'
			{'cIdField', 'COTO_DESCINTERRUPCAO'},;
			{'nTamanho', OA5410009L_GetFieldLen('COTO_DESCINTERRUPCAO')},;
			{'cPicture', '@!'},;
			{'lObrigat', .F.},;
			{'bWhen', {|| .F.}},;
			{'cTooltip', STR0119};	//'Descricao automatica do codigo de interrupcao (VX5)'
		};
	)

Return oStructDePara

/*/{Protheus.doc} OA54100363_LoadModel12CotoGridDePara
	Carrega os dados do grid De/Para Control Tower a partir da
	configuracao salva via OfScaniaConfig (JSON na VRN).

	@type  Static Function
	@author Diogo Barros
	@since 12/03/2026
	@version 12.1.2510
	@Return aRetorno, array	
/*/
Static Function OA54100363_LoadModel12CotoGridDePara()
	
	Local aRetorno	:= {}
	Local oCfg		:= OfScaniaConfig():New("CONTROLTOWER","OFIA541")
	Local oJson		:= oCfg:getConfig()
	Local lTemJson	:= (ValType(oJson) == "J")
	Local cArray	:= "COTO_GDEPARA"
	Local nLine		:= 0
	Local nField	:= 0
	Local oItem		:= nil
	Local oGrid		:= oModel:GetModel():getModel("TAB_DEPARA_COTO")

	If lTemJson .and. !empty(oJson[cArray]) .and. Len(oJson[cArray]) > 0
		For nLine := 1 to Len(oJson[cArray])
			oItem := oJson[cArray][nLine]
			oGrid:AddLine()

			For nField := 1 to Len(aCotoGridDePara)
				oGrid:SetValue(aCotoGridDePara[nField], oItem[aCotoGridDePara[nField]])
			Next

			// Preenche as descricoes automaticamente a partir dos codigos carregados			
			oGrid:LoadValue("COTO_DESCPAUSA", OA5410046M_RetDescPausa(oItem["COTO_CODPAUSA"]))
			oGrid:LoadValue("COTO_DESCINTERRUPCAO", OA5410047M_RetDescInter(oItem["COTO_CODINTERRUPCAO"]))
		Next
	Endif

	freeObj(oJson)
	freeObj(oCfg)

Return aRetorno

/*/{Protheus.doc} OA5410041M_ValidaLinhaDePara
	Validacao pos linha do Grid De/Para Control Tower.
	Verifica se os codigos informados existem nas tabelas VS0 e VX5.

	@param oGridModel - Objeto do modelo MVC
	@param nLine -  Posição da linha que está sendo verificada.
	@type  Static Function
	@author Diogo Barros
	@since 12/03/2026
	@version 12.1.2510
	@return lRet, logical
/*/
Static Function OA5410041M_ValidaLinhaDePara(oGridModel, nLine)
	
	Local lRet			:= .T.	
	Local cCodPausa		:= ""
	Local cCodInter		:= ""

	cCodPausa := oGridModel:GetValue("COTO_CODPAUSA")
	cCodInter := oGridModel:GetValue("COTO_CODINTERRUPCAO")

	// Codigo Pausa Protheus (VS0_TIPASS = 000006)
	If !Empty(cCodPausa)		
		If !OA5410044M_ExistePausaVS0(cCodPausa)			
			FMX_HELP("OFIA54101", STR0120, STR0121) // "Código Pausa Protheus inválido" // "O código deve existir na tabela VS0"
			lRet := .F.
		EndIf
	EndIf

	// Codigo Interrupcao Control Tower (VX5_CHAVE = 106)
	If lRet .And. !Empty(cCodInter)
		If !OA5410045M_ExisteInterVX5(cCodInter)			
			FMX_HELP("OFIA54102", STR0122, STR0123) // "Código Interrupção Control Tower inválido" // "O código deve existir na tabela VX5"
			lRet := .F.
		EndIf
	EndIf	

Return lRet


/*/{Protheus.doc} OA5410042M_ValidaPausaVS0
	Validacao do campo Codigo de Pausa no grid (bValid).
	Verifica existencia na VS0 com Tipo do Assunto = 000006.

	@param oModel       - Objeto do modelo
	@param cField       - Nome do campo
	@param xValue       - Valor atual
	@param xValueAntigo - Valor anterior

	@type  Static Function
	@author Diogo Barros
	@since 12/03/2026
	@version 12.1.2510
	@return lRet, logical
/*/
Static Function OA5410042M_ValidaPausaVS0(oModel, cField, xValue, xValueAntigo)
	
	Local lRet := .T.	

	If !Empty(xValue)
		If !OA5410044M_ExistePausaVS0(xValue)
			FMX_HELP("OFIA54103", STR0124) // "Código de pausa nao encontrado na tabela VS0"
			lRet := .F.
		Else
			oModel:LoadValue("COTO_DESCPAUSA",OA5410046M_RetDescPausa(xValue))
		EndIf	
	EndIf

Return lRet


/*/{Protheus.doc} OA5410043M_ValidaInterVX5
	Validacao do campo Codigo de Interrupcao Control Tower no grid (bValid).
	Verifica existencia na VX5.

	@param oModel       - Objeto do modelo
	@param cField       - Nome do campo
	@param xValue       - Valor atual
	@param xValueAntigo - Valor anterior

	@type  Static Function
	@author Diogo Barros
	@since 12/03/2026	
	@version 12.1.2510
	@return lRet, logical
/*/
Static Function OA5410043M_ValidaInterVX5(oModel, cField, xValue, xValueAntigo)
	
	Local lRet := .T.	

	If !Empty(xValue)
		If !OA5410045M_ExisteInterVX5(xValue)		
			FMX_HELP("OFIA541", STR0125) // "Código de Interrupção não encontrado na tabela VX5"
			lRet := .F.
		Else
			oModel:LoadValue("COTO_DESCINTERRUPCAO", OA5410047M_RetDescInter(xValue))        
		EndIf
	EndIf

Return lRet


/*/{Protheus.doc} OA5410044M_ExistePausaVS0
	Verifica se o Codigo de Pausa existe na tabela VS0
	VS0_TIPASS (Tipo do Assunto) = 000006 (Pausa no serviço).

	@param cCodPausa - Codigo do motivo de pausa	
	@type  Static Function
	@author Diogo Barros
	@since 12/03/2026
	@version 12.1.2510
	@return logical
/*/
Static Function OA5410044M_ExistePausaVS0(cCodPausa)
	DbSelectArea("VS0")
	VS0->(DbSetOrder(1))			
Return VS0->(DbSeek(xFilial("VS0") + "000006" + cCodPausa))


/*/{Protheus.doc} OA5410045M_ExisteInterVX5
	Verifica se o Codigo de Interrupcao existe na tabela VX5

	@param cCodInter - Codigo de interrupcao Control Tower	
	@type  Static Function
	@author Diogo Barros
	@since 12/03/2026
	@version 12.1.2510
	@return logical
/*/
Static Function OA5410045M_ExisteInterVX5(cCodInter)
	DbSelectArea("VX5")
	VX5->(DbSetOrder(1))
Return VX5->(DbSeek(xFilial("VX5") + "106" + cCodInter))


/*/{Protheus.doc} OA5410046M_RetDescPausa
	Retorna a descricao do motivo de pausa da tabela VS0.
	Utilizado pelo gatilho do campo COTO_CODPAUSA.
	VS0_TIPASS (Tipo do Assunto) = 000006 (Pausa no serviço).

	@param cCodPausa - Codigo do motivo de pausa (ou xValue do trigger)
	@type  Static Function
	@author Diogo Barros
	@since 12/03/2026
	@version 12.1.2510
	@return cDescr, character
/*/
Static Function OA5410046M_RetDescPausa(cCodPausa)
	
	Local cDescr := Space(OA5410009L_GetFieldLen("COTO_DESCPAUSA"))

	DbSelectArea("VS0")
	VS0->(DbSetOrder(1))

	If VS0->(DbSeek(xFilial("VS0") + "000006" + cCodPausa))
		cDescr := Alltrim(VS0->VS0_DESMOT)
	EndIf

Return cDescr


/*/{Protheus.doc} OA5410047M_RetDescInter
	Retorna a descricao do codigo de interrupcao da tabela VX5.
	Utilizado pelo gatilho do campo COTO_CODINTERRUPCAO e pelo LoadModel.

	@param cCodInter - Codigo de interrupcao Control Tower (ou xValue do trigger)
	@type  Static Function
	@author Diogo Barros
	@since 12/03/2026
	@version 12.1.2510
	@return cDescr, character

/*/
Static Function OA5410047M_RetDescInter(cCodInter)
	
	Local cDescr := Space(OA5410009L_GetFieldLen("COTO_DESCINTERRUPCAO"))
	
	DbSelectArea("VX5")
	VX5->(DbSetOrder(1))

	If VX5->(DbSeek(xFilial("VX5") + "106" + cCodInter))
		cDescr := AllTrim(VX5->VX5_DESCRI)
	EndIf

Return cDescr
