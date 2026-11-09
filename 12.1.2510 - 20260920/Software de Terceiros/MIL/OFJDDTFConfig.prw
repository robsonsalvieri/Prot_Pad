#include 'protheus.ch'

/*/{Protheus.doc} OFJDDTFConfig
	Classe de Configuracao do DTF
	
	@type function
	@author Jose Silveira
	@since 30/09/2021
/*/
Class OFJDDTFConfig from LongNameClass
	Data cCodigo
	Data oConfig
	Data cConta
	Data lNovoCombo

	Method New() CONSTRUCTOR

	Method saveConfig()
	Method getConfig()

	Method getCGPoll()
	Method getCotacao_Maquina()
	Method getPMMANAGE()
	Method getDPMEXT()
	Method getWarranty()
	Method getIncentivo_Maquina()
	Method get_UP_Incentivo_Maquina()
	Method getJDPRISM()
	Method getParts_Info()
	Method getParts_Locator()
	Method getAuthorized_Parts_Returns()
	Method getParts_Surplus_Returns()
	Method getParts_Subs()
	Method getSMManage()
	Method getDFA()
	Method getELIPS()
	Method getNAO_CLASSIFICADOS()
	Method criaDirDTF()
	Method getDirOrigemCotacao_Maquina()
	Method getDirOrigemDPMEXT()
	Method getDirOrigemPMMANAGE()
	Method getDirOrigemUP_Incentivo_Maquina()
	Method getDirOrigemParts_Locator()
	Method getDirOrigemParts_Surplus_Returns()
	Method getDirOrigemSMManage()
	Method getDirOrigemDFA()
	Method getDirOrigemELIPS()
	Method getAccountConfig()
	Method _loadDefaults()
EndClass

/*/{Protheus.doc} New
	Construtor Simples

	@type function
	@author Jose Silveira
	@since 30/09/2021
/*/
Method New() Class OFJDDTFConfig
	local lNovoCombo := GetNewPar("MV_MIL0210", .F.)
	::cCodigo := "OFIA410"
	::lNovoCombo := lNovoCombo
	if lNovoCombo
		::cCodigo += "_C"
	endif
Return SELF

/*/{Protheus.doc} saveConfig
	Salva a configuracao no lugar da atual

	@type function
	@author Jose Silveira
	@since 30/09/2021
/*/
Method saveConfig(oConfig) Class OFJDDTFConfig
	local oAtuCfg := JsonObject():New()
	local nx := 1
	local nContaIndex := 0

	VRN->(dbSetOrder(1))
	if ExistBlock("DTFCTMCF") // PE criado para terraverde pois a configuração deles teve que ficar customizada devido a setup de filiais erroneo
		ExecBlock("DTFCTMCF",.f.,.f.) // PE deve posicionar no VRN de acordo com o cFilAnt
		reclock("VRN", .F.)
		VRN->VRN_CONFIG := oConfig:toJson()
		VRN->(MsUnlock())
	else
		VRN->(dbSeek(xFilial("VRN") + self:cCodigo))
		oAtuCfg:FromJson(VRN->VRN_CONFIG)

		if self:lNovoCombo
			if empty(oConfig["ID"])
				oConfig["ID"] := self:cConta // só pra garantir o ID
			endif

			if ! oAtuCfg:hasProperty("CONFIGURACOES") // se tiver configuracao anterior, tenta atualizar ao inves de criar nova
				oAtuCfg["CONFIGURACOES"] := {}
			endif

			for nx := 1 to len(oAtuCfg["CONFIGURACOES"])
				if alltrim(oAtuCfg["CONFIGURACOES"][nx]["ID"]) == alltrim(oConfig["ID"])
					nContaIndex := nx
					exit
				endif
			next

			if nContaIndex > 0
				oAtuCfg["CONFIGURACOES"][nContaIndex] := oConfig
			elseif nContaIndex == 0
				aadd(oAtuCfg["CONFIGURACOES"], oConfig)
			endif

			cJson := oAtuCfg:toJson()
		else
			cJson := oConfig:toJson()
		endif

		reclock("VRN", .F.)
		VRN->VRN_CONFIG := cJson
		VRN->(MsUnlock())
	endif
return .t.

/*/{Protheus.doc} getConfig
	Pega a configuracao em formato de data container

	@type function
	@author Jose Silveira
	@since 30/09/2021
/*/
Method getConfig(cConta) Class OFJDDTFConfig
	local oConfig := JsonObject():New()
	local oTodasConfigs := JsonObject():New()
	local lExistCfg := .f.
	local lNovoCombo := GetNewPar("MV_MIL0210", .F.)
	default cConta := PadR( "OLD", 20 )

	if empty(cConta)
		cConta := PadR( "OLD", 20 )
	endif

	self:cConta := cConta

	if ExistBlock("DTFCTMCF") // PE criado para terraverde pois a configuração deles teve que ficar customizada devido a setup de filiais erroneo
		lExistCfg := ExecBlock("DTFCTMCF",.f.,.f.) // PE deve posicionar no VRN de acordo com o cFilAnt
		oConfig:FromJson(VRN->VRN_CONFIG)
	else
		VRN->(dbSetOrder(1))
		lExistCfg := VRN->(dbSeek(xFilial("VRN") + self:cCodigo))

		if lExistCfg
			oTodasConfigs := JsonObject():New()
			oTodasConfigs:FromJson(VRN->VRN_CONFIG)

			if lNovoCombo
				oConfig := ::getAccountConfig(cConta, oTodasConfigs["CONFIGURACOES"])
			else
				oConfig := oTodasConfigs
			endif
		endif
	endif

	if ! lExistCfg // criar vrn do zero
		if lNovoCombo
			oContaCfg := JsonObject():New()
			oContaCfg["ID"] := cConta
			self:_loadDefaults(oContaCfg)

			if ! oConfig:hasProperty("CONFIGURACOES") // se tiver configuracao anterior, tenta atualizar ao inves de criar nova
				oConfig["CONFIGURACOES"] := {}
			endif
			
			aadd(oConfig["CONFIGURACOES"], oContaCfg)
			self:oConfig := oContaCfg
		else
			self:_loadDefaults(oConfig)
			self:oConfig := oConfig
		endif

		reclock("VRN", .T.)
		VRN->VRN_FILIAL := xFilial("VRN")
		VRN->VRN_CODIGO := self:cCodigo
		VRN->VRN_CONFIG := oConfig:toJson()
		VRN->(MsUnlock())
	endif

	self:oConfig := oConfig
Return oConfig

/*/{Protheus.doc} getConfig
	Grava valores padrao das pastas quando primeiro acesso

	@type function
	@author Vinicius Gati
	@since 17/06/2026
/*/
Method _loadDefaults(jConfig) Class OFJDDTFConfig
	jConfig['CGPoll']                   := "\dtf\CGPoll\"
	jConfig['Cotacao_Maquina']          := "\dtf\Cotacao_Maquina\"
	jConfig['PMMANAGE']                 := "\dtf\PMMANAGE\"
	jConfig['DPMEXT']                   := "\dtf\DPMEXT\"
	jConfig['Warranty']                 := "\dtf\Warranty\"
	jConfig['Incentivo_Maquina']        := "\dtf\Incentivo_Maquina\"
	jConfig['JDPRISM']                  := "\dtf\JDPRISM\"
	jConfig['Parts_Info']               := "\dtf\Parts_Info\"
	jConfig['Parts_Locator']            := "\dtf\Parts_Locator\"
	jConfig['Authorized_Parts_Returns'] := "\dtf\Authorized_Parts_Returns\"
	jConfig['Parts_Surplus_Returns']    := "\dtf\Parts_Surplus_Returns\"
	jConfig['Parts_Subs']               := "\dtf\Parts_Subs\"
	jConfig['SMManage']                 := "\dtf\SMManage\"
	jConfig['DFA']                      := "\dtf\DFA\"
	jConfig['ELIPS']                    := "\dtf\ELIPS\"

	// como aqui usa o padrao \dtf\ achei mais condizente só criar a pasta se entrar aqui
	IF ! ExistDir("\dtf\")
		FM_Direct("\dtf\",.f.,.f.)
	endif
Return jConfig

Method getCGPoll() Class OFJDDTFConfig
Return self:oConfig['CGPoll']

Method getCotacao_Maquina() Class OFJDDTFConfig
Return self:oConfig['Cotacao_Maquina']

Method getPMMANAGE() Class OFJDDTFConfig
Return self:oConfig['PMMANAGE']

Method getDPMEXT() Class OFJDDTFConfig
Return self:oConfig['DPMEXT']

Method getWarranty() Class OFJDDTFConfig
Return self:oConfig['Warranty']

Method getIncentivo_Maquina() Class OFJDDTFConfig
Return self:oConfig['Incentivo_Maquina']

Method get_UP_Incentivo_Maquina() Class OFJDDTFConfig
Return self:oConfig['UP_Incentivo_Maquina']

Method getJDPRISM() Class OFJDDTFConfig
Return self:oConfig['JDPRISM']

Method getParts_Info() Class OFJDDTFConfig
Return self:oConfig['Parts_Info']

Method getParts_Locator() Class OFJDDTFConfig
Return self:oConfig['Parts_Locator']

Method getAuthorized_Parts_Returns() Class OFJDDTFConfig
Return self:oConfig['Authorized_Parts_Returns']

Method getParts_Surplus_Returns() Class OFJDDTFConfig
Return self:oConfig['Parts_Surplus_Returns']

Method getParts_Subs() Class OFJDDTFConfig
Return self:oConfig['Parts_Subs']

Method getSMManage() Class OFJDDTFConfig
Return self:oConfig['SMManage']

Method getDFA() Class OFJDDTFConfig
 Return self:oConfig['DFA']

Method getELIPS() Class OFJDDTFConfig
Return self:oConfig['ELIPS']

Method getNAO_CLASSIFICADOS() Class OFJDDTFConfig
Return self:oConfig['NAO_CLASSIFICADOS']

Method getDirOrigemCotacao_Maquina() Class OFJDDTFConfig
Return self:oConfig['OCotacao_Maquina']

Method getDirOrigemPMMANAGE() Class OFJDDTFConfig
Return self:oConfig['OPMMANAGE']

Method getDirOrigemDPMEXT() Class OFJDDTFConfig
Return self:oConfig['ODPMEXT']

Method getDirOrigemUP_Incentivo_Maquina() Class OFJDDTFConfig
Return self:oConfig['OUP_Incentivo_Maquina']

Method getDirOrigemParts_Locator() Class OFJDDTFConfig
Return self:oConfig['OParts_Locator']

Method getDirOrigemParts_Surplus_Returns() Class OFJDDTFConfig
Return self:oConfig['OParts_Surplus_Returns']

Method getDirOrigemSMManage() Class OFJDDTFConfig
Return self:oConfig['OSMManage']

Method getDirOrigemDFA() Class OFJDDTFConfig
Return self:oConfig['ODFA']

Method getDirOrigemELIPS() Class OFJDDTFConfig
Return self:oConfig['OELIPS']

Method criaDirDTF() Class OFJDDTFConfig
Local aDealer := {}
local i := 1
local nI
local cAux
local cFilAtu := cFilAnt
local aAllFil := fwAllFilial(,,,.f.)

IF !self:oConfig:hasProperty("CGPoll")
	return
Endif

VE4->(DBSetOrder(1))

for nI := 1 to len( aAllFil )
	cFilAnt := aAllFil[ nI ]
	cAux    := superGetMV( "MV_MIL0005", .F., "" )
	if ! empty( cAux )
		aAdd( aDealer, cAux )
		VE4->( dbSeek( right( cFilAnt, 2 ) ) )
	endif
next
cFilAnt := cFilAtu

IF left(self:oConfig['CGPoll'],5) == "\dtf\"
	IF !ExistDir(self:oConfig['CGPoll'])
		FM_Direct(self:oConfig['CGPoll'],.f.,.f.)
		FM_Direct(self:oConfig['CGPoll']+"salva\",.f.,.f.)
		for i := 1 to len(aDealer)
			FM_Direct(self:oConfig['CGPoll']+aDealer[i]+"\",.f.,.f.)
		next
	Endif
Endif
IF left(self:oConfig['Cotacao_Maquina'],5) == "\dtf\"
	IF !ExistDir(self:oConfig['Cotacao_Maquina'])
		FM_Direct(self:oConfig['Cotacao_Maquina'],.f.,.f.)
		FM_Direct(self:oConfig['Cotacao_Maquina']+"salva\",.f.,.f.)
		for i := 1 to len(aDealer)
			FM_Direct(self:oConfig['Cotacao_Maquina']+aDealer[i]+"\",.f.,.f.)
		next
	Endif
Endif
IF left(self:oConfig['PMMANAGE'],5) == "\dtf\"
	IF !ExistDir(self:oConfig['PMMANAGE'])
		FM_Direct(self:oConfig['PMMANAGE'],.f.,.f.)
		FM_Direct(self:oConfig['PMMANAGE']+"salva\",.f.,.f.)
		for i := 1 to len(aDealer)
			FM_Direct(self:oConfig['PMMANAGE']+aDealer[i]+"\",.f.,.f.)
		next
	Endif
Endif
IF left(self:oConfig['DPMEXT'],5) == "\dtf\"
	IF !ExistDir(self:oConfig['DPMEXT'])
		FM_Direct(self:oConfig['DPMEXT'],.f.,.f.)
		FM_Direct(self:oConfig['DPMEXT']+"salva\",.f.,.f.)
		for i := 1 to len(aDealer)
			FM_Direct(self:oConfig['DPMEXT']+aDealer[i]+"\",.f.,.f.)
		next
	Endif
Endif
IF left(self:oConfig['Warranty'],5) == "\dtf\"
	IF !ExistDir(self:oConfig['Warranty'])
		FM_Direct(self:oConfig['Warranty'],.f.,.f.)
		FM_Direct(self:oConfig['Warranty']+"salva\",.f.,.f.)
		for i := 1 to len(aDealer)
			FM_Direct(self:oConfig['Warranty']+aDealer[i]+"\",.f.,.f.)
		next
	Endif
Endif
IF left(self:oConfig['Incentivo_Maquina'],5) == "\dtf\"
	IF !ExistDir(self:oConfig['Incentivo_Maquina'])
		FM_Direct(self:oConfig['Incentivo_Maquina'],.f.,.f.)
		FM_Direct(self:oConfig['Incentivo_Maquina']+"salva\",.f.,.f.)
		for i := 1 to len(aDealer)
			FM_Direct(self:oConfig['Incentivo_Maquina']+aDealer[i]+"\",.f.,.f.)
		next
	Endif
Endif
IF left(self:oConfig['UP_Incentivo_Maquina'],5) == "\dtf\"
	IF !ExistDir(self:oConfig['UP_Incentivo_Maquina'])
		FM_Direct(self:oConfig['UP_Incentivo_Maquina'],.f.,.f.)
		FM_Direct(self:oConfig['UP_Incentivo_Maquina']+"salva\",.f.,.f.)
		for i := 1 to len(aDealer)
			FM_Direct(self:oConfig['UP_Incentivo_Maquina']+aDealer[i]+"\",.f.,.f.)
		next
	Endif
Endif
IF left(self:oConfig['JDPRISM'],5) == "\dtf\"
	IF !ExistDir(self:oConfig['JDPRISM'])
		FM_Direct(self:oConfig['JDPRISM'],.f.,.f.)
		FM_Direct(self:oConfig['JDPRISM']+"salva\",.f.,.f.)
		for i := 1 to len(aDealer)
			FM_Direct(self:oConfig['JDPRISM']+aDealer[i]+"\",.f.,.f.)
		next
	Endif
Endif
IF left(self:oConfig['Parts_Info'],5) == "\dtf\"
	IF !ExistDir(self:oConfig['Parts_Info'])
		FM_Direct(self:oConfig['Parts_Info'],.f.,.f.)
		FM_Direct(self:oConfig['Parts_Info']+"salva\",.f.,.f.)
		for i := 1 to len(aDealer)
			FM_Direct(self:oConfig['Parts_Info']+aDealer[i]+"\",.f.,.f.)
		next
	Endif
Endif
IF left(self:oConfig['Parts_Locator'],5) == "\dtf\"
	IF !ExistDir(self:oConfig['Parts_Locator'])
		FM_Direct(self:oConfig['Parts_Locator'],.f.,.f.)
		FM_Direct(self:oConfig['Parts_Locator']+"salva\",.f.,.f.)
		for i := 1 to len(aDealer)
			FM_Direct(self:oConfig['Parts_Locator']+aDealer[i]+"\",.f.,.f.)
		next
	Endif
Endif
IF left(self:oConfig['Authorized_Parts_Returns'],5) == "\dtf\"
	IF !ExistDir(self:oConfig['Authorized_Parts_Returns'])
		FM_Direct(self:oConfig['Authorized_Parts_Returns'],.f.,.f.)
		FM_Direct(self:oConfig['Authorized_Parts_Returns']+"salva\",.f.,.f.)
		for i := 1 to len(aDealer)
			FM_Direct(self:oConfig['Authorized_Parts_Returns']+aDealer[i]+"\",.f.,.f.)
		next
	Endif
Endif
IF left(self:oConfig['Parts_Surplus_Returns'],5) == "\dtf\"
	IF !ExistDir(self:oConfig['Parts_Surplus_Returns'])
		FM_Direct(self:oConfig['Parts_Surplus_Returns'],.f.,.f.)
		FM_Direct(self:oConfig['Parts_Surplus_Returns']+"salva\",.f.,.f.)
		for i := 1 to len(aDealer)
			FM_Direct(self:oConfig['Parts_Surplus_Returns']+aDealer[i]+"\",.f.,.f.)
		next
	Endif
Endif
IF left(self:oConfig['Parts_Subs'],5) == "\dtf\"
	IF !ExistDir(self:oConfig['Parts_Subs'])
		FM_Direct(self:oConfig['Parts_Subs'],.f.,.f.)
		FM_Direct(self:oConfig['Parts_Subs']+"salva\",.f.,.f.)
		for i := 1 to len(aDealer)
			FM_Direct(self:oConfig['Parts_Subs']+aDealer[i]+"\",.f.,.f.)
		next
	Endif
Endif
IF left(self:oConfig['SMManage'],5) == "\dtf\"
	IF !ExistDir(self:oConfig['SMManage'])
		FM_Direct(self:oConfig['SMManage'],.f.,.f.)
		FM_Direct(self:oConfig['SMManage']+"salva\",.f.,.f.)
		for i := 1 to len(aDealer)
			FM_Direct(self:oConfig['SMManage']+aDealer[i]+"\",.f.,.f.)
		next
	Endif
Endif
IF left(self:oConfig['DFA'],5) == "\dtf\"
	IF !ExistDir(self:oConfig['DFA'])
		FM_Direct(self:oConfig['DFA'],.f.,.f.)
		FM_Direct(self:oConfig['DFA']+"salva\",.f.,.f.)
		for i := 1 to len(aDealer)
			FM_Direct(self:oConfig['DFA']+aDealer[i]+"\",.f.,.f.)
		next
	Endif
Endif
IF left(self:oConfig['ELIPS'],5) == "\dtf\"
	IF !ExistDir(self:oConfig['ELIPS'])
		FM_Direct(self:oConfig['ELIPS'],.f.,.f.)
		FM_Direct(self:oConfig['ELIPS']+"salva\",.f.,.f.)
		for i := 1 to len(aDealer)
			FM_Direct(self:oConfig['ELIPS']+aDealer[i]+"\",.f.,.f.)
		next
	Endif
Endif

IF left(self:oConfig['NAO_CLASSIFICADOS'],5) == "\dtf\"
	IF !ExistDir(self:oConfig['NAO_CLASSIFICADOS'])
		FM_Direct(self:oConfig['NAO_CLASSIFICADOS'],.f.,.f.)
		FM_Direct(self:oConfig['NAO_CLASSIFICADOS']+"salva\",.f.,.f.)
		for i := 1 to len(aDealer)
			FM_Direct(self:oConfig['NAO_CLASSIFICADOS']+aDealer[i]+"\",.f.,.f.)
		Next
	Endif
Endif

return

Method getAccountConfig(cConta, aTodasConfig) Class OFJDDTFConfig
	local oConfig := JsonObject():New()
	local nx := 1

	for nx := 1 to len(aTodasConfig)
		if alltrim(aTodasConfig[nx]["ID"]) == alltrim(cConta)
			oConfig := aTodasConfig[nx]
		endif
	next
return oConfig
