#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#include "FWEVENTVIEWCONSTS.CH"
#Include "OFIA541EVDEF.ch"

/*/{Protheus.doc} OFIA541EVDEF
    @author Renan Migliaris
    @since 14/10/2025
    @version version
    /*/
Class OFIA541EVDEF From FWModelEvent
    public data oConfig
    public data JJsonConfig

    method new() constructor
    method destroy()
	method ModelPosVld(oModel, cModelId)

    method _validaCamposObrigatorios(oModel, cModelID)
    method _setaScob(oModel, cModelIDoModel, cModelID)
    method _setaScrm(oModel, cModelID)
    method _setaArms(oModel, cModelID)
    method _setaCoto(oModel, cModelId)
    method _updateRegras(oModel, aGerScrm)
EndClass

Method new() Class OFIA541EVDEF
    self:JJsonConfig := JsonObject():New()
    self:oConfig := OfScaniaConfig():New("","OFIA541")
return .t.

Method destroy() Class OFIA541EVDEF
    freeObj(self:oConfig)
    freeObj(self:JJsonConfig)
return .t.

method ModelPosVld(oModel, cModelId) class OFIA541EVDEF

  Local lOK := .T.

    // Chama a validação de campos da integração
    lOK := Self:_validaCamposObrigatorios(oModel,cModelId)

    // Se Ok faz o commit
    If ( lOK )

        DbSelectArea("VRN")
        DbSetOrder(1)
        if DbSeek(xFilial("VRN") + "OFIA541")
            if !Empty(VRN->VRN_CONFIG)
                self:JJsonConfig:FromJson(VRN->VRN_CONFIG)
            endif
        endif
        DbCloseArea()
        self:_setaScrm(oModel, cModelId)
        self:_setaScob(oModel, cModelId)
        self:_setaArms(oModel, cModelId)
        self:_setaCoto(oModel, cModelId)
        self:oConfig:saveConfig(self:jJsonConfig)

    EndIf
return( lOk )

/*/{Protheus.doc} _setaScob
    Salva o json do Scob
    @author Renan Migliaris
    @since 15/10/2025
    /*/
Method _setaScob(oModel, cModelID) Class OFIA541EVDEF
    local oSubMod01 := oModel:getModel("TAB1")
    local oSubMod02 := oModel:getModel("TAB2")
    local oSubMod03 := oModel:getModel("TAB3")
    local cAmbiente := ""
    local jEnvAtual := JsonObject():New()
    local jTarget := JsonObject():New()
    local aCampos := {}
    local nX := 0
    local cKey := ""

    if !self:jJsonConfig:HasProperty("SCOB")
        self:jJsonConfig["SCOB"] := JsonObject():New()
    endif

    if oSubMod01:GetValue("CFG_AMBIENTE") == "1"
        cAmbiente := "PRODUCAO"
    elseif oSubMod01:GetValue("CFG_AMBIENTE") == "2"
        cAmbiente := "HOMOLOGACAO"
    endif

    if self:jJsonConfig["SCOB"]:HasProperty(cAmbiente)
        jEnvAtual := self:jJsonConfig["SCOB"][cAmbiente]
    else
        jEnvAtual := JsonObject():New()
    endif

    jTarget["CFG_AMBIENTE"] := oSubMod01:GetValue("CFG_AMBIENTE")
    jTarget["CFG_INTEGRACAO_ATIVA"] := oSubMod01:GetValue("CFG_INTEGRACAO_ATIVA")
    jTarget["CFG_TPAUT"] := oSubMod01:GetValue("CFG_TPAUT")
    jTarget["CFG_CLIENTEID"] := oSubMod01:GetValue("CFG_CLIENTEID")
    jTarget["CFG_CLIENTESECRET"] := oSubMod01:GetValue("CFG_CLIENTESECRET")
    jTarget["CFG_URL"] := oSubMod01:GetValue("CFG_URL")
    jTarget["CFG_GRANTTYPE"] := oSubMod01:GetValue("CFG_GRANTTYPE")
    jTarget["CFG_CONTTYPE"] := oSubMod01:GetValue("CFG_CONTTYPE")
    jTarget["CFG_AUTHPATH"] := oSubMod01:GetValue("CFG_AUTHPATH")

    jTarget["CFG_TPAUT2"] := oSubMod02:GetValue("CFG_TPAUT2")
    jTarget["CFG_URLBASE"] := oSubMod02:GetValue("CFG_URLBASE")
    jTarget["CFG_ENDPOINT"] := oSubMod02:GetValue("CFG_ENDPOINT")

    jTarget["CFG_PRECADAUT"] := oSubMod03:GetValue("CFG_PRECADAUT")
    jTarget["CFG_LOCPAD"] := oSubMod03:GetValue("CFG_LOCPAD")
    jTarget["OFIXX001"] := oSubMod03:GetValue("OFIXX001")
    jTarget["OFIOM010"] := oSubMod03:GetValue("OFIOM010")
    jTarget["OFIOM140"] := oSubMod03:GetValue("OFIOM140")
    jTarget["CFG_CODMAR"] := oSubMod03:GetValue("CFG_CODMAR")

    aCampos := jTarget:GetNames()

    if !self:jJsonConfig["SCOB"]:HasProperty(cAmbiente)
        for nX := 1 to Len(aCampos)
            jEnvAtual[aCampos[nX]] := ""
        next
    endif

    for nX := 1 to Len(aCampos)
        cKey := aCampos[nX]
        jEnvAtual[cKey] := jTarget[cKey]
    next

    self:jJsonConfig["SCOB"][cAmbiente] := jEnvAtual
return .t.
/*/{Protheus.doc} _setaArms
@description Consolida os dados das abas de configuração ARMS (token e consulta) no JSON interno da classe, de acordo com o ambiente selecionado
     (Produção ou Homologação). Esse método é responsável por armazenar todos os campos preenchidos nas telas de configuração dentro da estrutura
      `self:jJsonConfig["ARMS"]`, organizando os dados por ambiente.
@param        oModel     -> Objeto do tipo Model contendo os dados das abas 'TAB_ARMS' e 'TAB_ARMS_CONSULTA'
@param        cModelId   -> Identificador do modelo principal (não utilizado diretamente neste método)
@return       Boolean    -> Retorna .T. ao finalizar a persistência dos dados no JSON da classe
@author       Lucas Brustolin
@since        07/11/2025
@version      1.0
@type         Method
@obs          Este método é geralmente chamado no momento do salvamento da configuração no configurador de integração.
              Caso o ambiente ainda não esteja presente na estrutura JSON, ele será inicializado com os campos vazios e sobrescrito.
*/
Method _setaArms(oModel, cModelId) Class OFIA541EVDEF

    Local oTokArms  := oModel:GetModel('TAB_ARMS')
    Local oConsArms := oModel:GetModel('TAB_ARMS_CONSULTA')
    Local cAmbiente := ""
    local jEnvAtual := JsonObject():new()
    local jTarget   := JsonObject():new()
    local aCampos   := {}
    local nX        := 0
    local cKey      := ""


   If ValType(oTokArms) <> 'O' .or. ValType(oConsArms) <> 'O'
      Return .T.
   EndIf


    if !self:jJsonConfig:HasProperty("ARMS")
        self:jJsonConfig["ARMS"] := JsonObject():New()
    endif

    if oTokArms:GetValue("ARMS_AMBIENTE") == "1"
        cAmbiente := "PRODUCAO"
    elseif oTokArms:GetValue("ARMS_AMBIENTE") == "2"
        cAmbiente := "HOMOLOGACAO"
    endIf

   // TOKEN
   jTarget['ARMS_AMBIENTE']         := oTokArms:GetValue('ARMS_AMBIENTE')
   jTarget['ARMS_INTEGRACAO_ATIVA'] := oTokArms:GetValue('ARMS_INTEGRACAO_ATIVA')
   jTarget['ARMS_TPAUT']            := oTokArms:GetValue('ARMS_TPAUT')
   jTarget['ARMS_CLIENTID']         := oTokArms:GetValue('ARMS_CLIENTID')
   jTarget['ARMS_CLIENTSEC']        := oTokArms:GetValue('ARMS_CLIENTSEC')
   jTarget['ARMS_TOKEN_URL']        := oTokArms:GetValue('ARMS_TOKEN_URL')
   jTarget['ARMS_GRANTTYPE']        := oTokArms:GetValue('ARMS_GRANTTYPE')
   jTarget['ARMS_SCOPE']            := oTokArms:GetValue('ARMS_SCOPE')
   jTarget['ARMS_CONTTYPE']         := oTokArms:GetValue('ARMS_CONTTYPE')
   // Consulta      
   jTarget['ARMS_TPAUT2']           := oConsArms:GetValue('ARMS_TPAUT2')
   jTarget['ARMS_URLBASE']          := oConsArms:GetValue('ARMS_URLBASE')
   jTarget['ARMS_ENDPOINT']         := oConsArms:GetValue('ARMS_ENDPOINT')


    aCampos := jTarget:GetNames()

    if !self:jJsonConfig["ARMS"]:HasProperty(cAmbiente)
        for nX := 1 to Len(aCampos)
            jEnvAtual[aCampos[nX]] := ""
        next
    endif

    for nX := 1 to Len(aCampos)
        cKey := aCampos[nX]
        jEnvAtual[cKey] := jTarget[cKey]
    next

    self:jJsonConfig["ARMS"][cAmbiente] := jEnvAtual


Return .T.

/*/{Protheus.doc} _setaScrm
    Salva o Json do SCRM
    @author Renan Migliaris
    @since 28/10/2025
    /*/
Method _setaScrm(oModel, cModelID) class OFIA541EVDEF
    local oSubMod04Scrm := oModel:getModel('TAB_SCRM')
    local oSubMod05GeraisScrm := oModel:getModel('TAB_GERAIS_SCRM')
    local oSubMod06GatilhosScrm := oModel:getModel('TAB_GATILHOS_SCRM')
    local cAmbiente := ''
    local jEnvAtual := JsonObject():new()
    local jTarget := JsonObject():new()
    local aCampos := {}
    local nX := 0
    local cKey := ''

    
    if !self:jJsonConfig:HasProperty("SCRM")
        self:jJsonConfig["SCRM"] := JsonObject():New()
    endif

    if oSubMod04Scrm:GetValue("SCRM_AMBIENTE") == "1"
        cAmbiente := "PRODUCAO"
    elseif oSubMod04Scrm:GetValue("SCRM_AMBIENTE") == "2"
        cAmbiente := "HOMOLOGACAO"
    endIf

    //SubMod04Scrm
    jTarget["SCRM_INTEGRACAO_ATIVA"] := oSubMod04Scrm:GetValue("SCRM_INTEGRACAO_ATIVA")
    jTarget["SCRM_AMBIENTE"] := oSubMod04Scrm:GetValue("SCRM_AMBIENTE")
    jTarget["SCRM_USER_WEBSERVICE"] := oSubMod04Scrm:GetValue("SCRM_USER_WEBSERVICE")
    jTarget["SCRM_PSW_WEBSERVICE"] := oSubMod04Scrm:GetValue("SCRM_PSW_WEBSERVICE")
    jTarget["SCRM_CLIENTES_URL_WEBSERVICE"] := oSubMod04Scrm:GetValue("SCRM_CLIENTES_URL_WEBSERVICE")
    jTarget["SCRM_VEICULOS_URL_WEBSERVICE"] := oSubMod04Scrm:GetValue("SCRM_VEICULOS_URL_WEBSERVICE")
    //SubMod05GeraisScrm
    jTarget["SCRM_LEVANTAR_FROTA"] := oSubMod05GeraisScrm:GetValue("SCRM_LEVANTAR_FROTA") 
    jTarget["SCRM_APENAS_CLIENTES"] := oSubMod05GeraisScrm:GetValue("SCRM_APENAS_CLIENTES")
    jTarget["SCRM_GERA_ARQUIVO"] := oSubMod05GeraisScrm:GetValue("SCRM_GERA_ARQUIVO")
    if jTarget["SCRM_GERA_ARQUIVO"] == '2'
        jTarget["SCRM_FILE_PATH"] := space(99) //salvando espaço vazio no tamanho do campo
    elseif jTarget["SCRM_GERA_ARQUIVO"] == '1'
        jTarget["SCRM_FILE_PATH"] := oSubMod05GeraisScrm:GetValue("SCRM_FILE_PATH")
    endif
    //SubMod06GatilhosScrm
    jTarget["SCRM_SA1"] := oSubMod06GatilhosScrm:GetValue("SCRM_SA1")
    jTarget["SCRM_VCF"] := oSubMod06GatilhosScrm:GetValue("SCRM_VCF")
    jTarget["SCRM_VV1"] := oSubMod06GatilhosScrm:GetValue("SCRM_VV1")
    jTarget["SCRM_VO1"] := oSubMod06GatilhosScrm:GetValue("SCRM_VO1")
    jTarget["SCRM_VS1"] := oSubMod06GatilhosScrm:GetValue("SCRM_VS1")
    jTarget["SCRM_SF2"] := oSubMod06GatilhosScrm:GetValue("SCRM_SF2")


    aCampos := jTarget:GetNames()

    if !Self:jJsonConfig["SCRM"]:HasProperty(cAmbiente)
        for nX := 1 to Len(aCampos)
            jEnvAtual[aCampos[nX]] := ""
        next
    endif

    for nX := 1 to Len(aCampos)
        cKey := aCampos[nX]
        jEnvAtual[cKey] := jTarget[cKey]
    next

    self:jJsonConfig["SCRM"][cAmbiente] := jEnvAtual
Return .t.

/*/{Protheus.doc} _setaCoto
    Salva o Json do Control Tower
    @author Bruno Forcato
    @since 05/11/2025
    /*/
Method _setaCoto(oModel, cModelID) class OFIA541EVDEF
    local oSubMod07CotoToken := oModel:getModel('TAB_TOKEN_COTO')
    local oSubMod08Coto := oModel:getModel('TAB_COTO')
    local oSubMod09CotoGeneral := oModel:getModel('TAB_GERAIS_COTO')
    local oSubMod10CotoGridConcessionaria := oModel:getModel('TAB_CONCESSIONARIA_COTO')
    local oSubMod11CotoGridTPContratos := oModel:getModel('TAB_TP_CONTRATO_COTO')
    local oSubMod12CotoGridDePara := oModel:getModel('TAB_DEPARA_COTO')
    local aConsessionariaIds := {}
    local aTPContratos := {}
    local aTPDePara := {}
    local cAmbiente := ''
    local jEnvAtual := JsonObject():new()
    local jTarget := JsonObject():new()
    local aCampos := {}
    local nX := 0
    local cKey := ''

    if !self:jJsonConfig:HasProperty("CONTROLTOWER")
        self:jJsonConfig["CONTROLTOWER"] := JsonObject():New()
    endif

    if oSubMod07CotoToken:GetValue("COTO_AMBIENTE") == "1"
        cAmbiente := "PRODUCAO"
    elseif oSubMod07CotoToken:GetValue("COTO_AMBIENTE") == "2"
        cAmbiente := "HOMOLOGACAO"
    endIf

    //SubMod07CotoToken
    jTarget["COTO_INTEGRACAO_ATIVA"] := oSubMod07CotoToken:GetValue("COTO_INTEGRACAO_ATIVA")
    jTarget["COTO_TPAUT"] := oSubMod07CotoToken:GetValue("COTO_TPAUT")
    jTarget["COTO_CLIENTEID"] := oSubMod07CotoToken:GetValue("COTO_CLIENTEID")
    jTarget["COTO_CLIENTESECRET"] := oSubMod07CotoToken:GetValue("COTO_CLIENTESECRET")
    jTarget["COTO_URL"] := oSubMod07CotoToken:GetValue("COTO_URL")
    jTarget["COTO_USERNAME"] := oSubMod07CotoToken:GetValue("COTO_USERNAME")
    jTarget["COTO_PASSWORD"] := oSubMod07CotoToken:GetValue("COTO_PASSWORD")
    jTarget["COTO_GRANTTYPE"] := oSubMod07CotoToken:GetValue("COTO_GRANTTYPE")
    jTarget["COTO_CONTENTTYPE"] := oSubMod07CotoToken:GetValue("COTO_CONTENTTYPE")
    //SubMod08Coto
    jTarget["COTO_TPAUT2"] := oSubMod08Coto:GetValue("COTO_TPAUT2") 
    jTarget["COTO_URLBASE"] := oSubMod08Coto:GetValue("COTO_URLBASE")
    jTarget["COTO_ENDPOINT"] := oSubMod08Coto:GetValue("COTO_ENDPOINT")
    //SubMod09CotoGeneral
    jTarget["COTO_OBTERTPCONT"] := oSubMod09CotoGeneral:GetValue("COTO_OBTERTPCONT")
    jTarget["COTO_QTDHEVENTO"] := oSubMod09CotoGeneral:GetValue("COTO_QTDHEVENTO")
    jTarget["COTO_MARCAVEIINT"] := oSubMod09CotoGeneral:GetValue("COTO_MARCAVEIINT")
    jTarget["COTO_SRVCHECK"] 	:= oSubMod09CotoGeneral:GetValue("COTO_SRVCHECK")  
    jTarget["COTO_MAXTENT"]  	:= oSubMod09CotoGeneral:GetValue("COTO_MAXTENT")
    //SubMod10CotoGridConcessionaria
    for nX := 1 to oSubMod10CotoGridConcessionaria:Length()
		oSubMod10CotoGridConcessionaria:GoLine(nX)
		if ! oSubMod10CotoGridConcessionaria:IsDeleted()
			jIds := JsonObject():New()
			jIds['COTO_GCONC_FILIAL'] := oSubMod10CotoGridConcessionaria:GetValue('COTO_GCONC_FILIAL')
			jIds['COTO_GCONC_ID'] := oSubMod10CotoGridConcessionaria:GetValue('COTO_GCONC_ID')
			AADD(aConsessionariaIds, jIds)
		endif
	next
    jTarget["COTO_GCONC"] := aConsessionariaIds
    //SubMod11CotoGridTPContratos
    for nX := 1 to oSubMod11CotoGridTPContratos:Length()
		oSubMod11CotoGridTPContratos:GoLine(nX)
		if ! oSubMod11CotoGridTPContratos:IsDeleted()
			jContratos := JsonObject():New()
			jContratos['COTO_GTPCONT_TPCONTRATO'] := oSubMod11CotoGridTPContratos:GetValue('COTO_GTPCONT_TPCONTRATO')
			AADD(aTPContratos, jContratos)
		endif
	next
    jTarget["COTO_GTPCONTRATOS"] := aTPContratos

    //SubMod12CotoGridDePara - De-Para Interrupcao
    for nX := 1 to oSubMod12CotoGridDePara:Length()
        oSubMod12CotoGridDePara:GoLine(nX)
        if ! oSubMod12CotoGridDePara:IsDeleted()
            jDePara := JsonObject():New()
            jDePara['COTO_CODPAUSA']    := oSubMod12CotoGridDePara:GetValue('COTO_CODPAUSA')            
            jDePara['COTO_CODINTERRUPCAO']  := oSubMod12CotoGridDePara:GetValue('COTO_CODINTERRUPCAO')
            AADD(aTPDePara, jDePara)
        endif
    next
    jTarget["COTO_GDEPARA"] := aTPDePara

    aCampos := jTarget:GetNames()

    if !Self:jJsonConfig["CONTROLTOWER"]:HasProperty(cAmbiente)
        for nX := 1 to Len(aCampos)
            jEnvAtual[aCampos[nX]] := ""
        next
    endif

    for nX := 1 to Len(aCampos)
        cKey := aCampos[nX]
        jEnvAtual[cKey] := jTarget[cKey]
    next

    self:jJsonConfig["CONTROLTOWER"][cAmbiente] := jEnvAtual
Return .t.

/*/{Protheus.doc} OA5410022N_ValidaCamposObrigatorios
@description
    Realiza a validação dinâmica de campos obrigatórios em cada Folder da
    rotina de Configurações de Integrações (OFIA541), de acordo com o
    campo INTEGRACAO_ATIVA presente no SubModelo principal da aba.

    Quando o campo de integração da Folder estiver ativo (= "1"), todos os
    campos definidos nos arrays fixos deste método tornam-se obrigatórios.
    Caso algum campo não esteja preenchido, será exibida uma mensagem ao
    usuário utilizando o padrão DMS (FMX_HELP), listando o TÍTULO dos
    campos faltantes conforme definido na estrutura (oStruct).

    # Folder e seus agrupamentos.
    - SCOB (Token, Consulta Chassi, Gerais)
    - SCRM (Token, Gerais, Gatilhos)
    - ARMS (Token, Consulta Contrato)

@rules
    - A obrigatoriedade NÃO vem da estrutura MVC (não usar lObrigat).
    - Cada Folder possui seu próprio campo de INTEGRACAO_ATIVA.
    - O SubModelo que possui o campo de integração controla os demais
      SubModels da mesma Folder.
    - Campos obrigatórios são definidos em arrays fixos neste código.

@param  oModel   (Object)     ? Instância MPFormModel da rotina OFIA541
@param  cModelId (Character)  ? Nome do SubModelo que disparou o evento

@return Logical
    .T. ? Todos os campos obrigatórios foram preenchidos.
    .F. ? Existe campo obrigatório não preenchido (exibido via FMX_HELP)

@since   14/11/2025
@version 1.0
@author  Lucas Brustolin
*/

Method _ValidaCamposObrigatorios(oModel, cModelId) Class OFIA541EVDEF
    Local aErros      := {}     // { {cSubModVal, cCampo}, ... }
    Local aRegras     := {}     // {cSubModVal, cSubModInt, cCampoInt, aCampos}
    Local nI, nJ      := 0
    Local cSubModVal  := ""
    Local cSubModInt  := ""
    Local cCampoInt   := ""
    Local aCampos     := {}
    Local oSubVal     := Nil
    Local oSubInt     := Nil
    Local oStruct     := Nil
    Local xValInt     := ""
    Local cCampo      := ""
    Local xValor      := Nil
    Local cTitulo     := ""
    Local cMsg        := ""
	Local nLinha  := 0
	Local lErroGrid := .F.
	local aErroGrid := {}
	local oGridConcessionaria
	local oGridTPContrato
    // ----------------------------------- CAMPOS OBRIGATORIOS QUANDO INTEGRALÇÃO ESTIVER ATIVA -------------------------------------------------------------
    Local aTab1 		:= {"CFG_AMBIENTE", "CFG_INTEGRACAO_ATIVA", "CFG_TPAUT", "CFG_CLIENTEID", "CFG_CLIENTESECRET", "CFG_URL", "CFG_AUTHPATH", "CFG_GRANTTYPE", "CFG_CONTTYPE"}
    Local aTab2 		:= {"CFG_TPAUT2", "CFG_URLBASE", "CFG_ENDPOINT"}
    Local aTab3 		:= {"CFG_PRECADAUT", "CFG_LOCPAD", "OFIXX001", "OFIOM010", "OFIOM140", "CFG_CODMAR"}
    // SCRM - OBRIGATORIOS
    Local aScrm 		:= {"SCRM_AMBIENTE","SCRM_INTEGRACAO_ATIVA","SCRM_USER_WEBSERVICE", "SCRM_PSW_WEBSERVICE","SCRM_CLIENTES_URL_WEBSERVICE","SCRM_VEICULOS_URL_WEBSERVICE"}
    Local aGerScrm      := { "SCRM_LEVANTAR_FROTA", "SCRM_APENAS_CLIENTES" ,"SCRM_GERA_ARQUIVO", "SCRM_FILE_PATH" } 
    Local aGatScrm 	    := {"SCRM_SA1","SCRM_VCF", "SCRM_VV1", "SCRM_VO1", "SCRM_VS1", "SCRM_SF2"}
    // ARMS - OBRIGATORIOS
    Local aARMSToken	:= {"ARMS_AMBIENTE","ARMS_INTEGRACAO_ATIVA","ARMS_TPAUT","ARMS_CLIENTID","ARMS_CLIENTSEC","ARMS_TOKEN_URL","ARMS_GRANTTYPE","ARMS_SCOPE","ARMS_CONTTYPE"}
    Local aARMSCons	    := {"ARMS_TPAUT2","ARMS_URLBASE","ARMS_ENDPOINT"}
    // Control Tower - OBRIGATORIOS
    local aCotoToken 	:= {"COTO_AMBIENTE","COTO_INTEGRACAO_ATIVA","COTO_TPAUT","COTO_CLIENTEID","COTO_CLIENTESECRET","COTO_URL","COTO_USERNAME","COTO_PASSWORD","COTO_GRANTTYPE","COTO_CONTENTTYPE"}
	local aCoto 		:= {"COTO_TPAUT2", "COTO_URLBASE","COTO_ENDPOINT"}
	local aCotoGeneral	:= {"COTO_OBTERTPCONT","COTO_QTDHEVENTO","COTO_MARCAVEIINT"}
	local aCotoGridConcessionaria := {"COTO_GCONC_FILIAL", "COTO_GCONC_ID"}
	local aCotoGridTPContratos := {"COTO_GTPCONT_TPCONTRATO"}    
    local aCotoGridDePara := {"COTO_CODPAUSA","COTO_CODINTERRUPCAO"}
    // --- Atualiza Array Regras conforme condies de preenchimento.
    aGerScrm := self:_updateRegras( oModel, aGerScrm )

    /* -----------------------------------------------------------
       1) MATRIZ DE REGRAS – 1 CAMPO DE INTEGRAÇÃO POR FOLDER
       ----------------------------------------------------------- */

    // --- SCOB (Folder SCOB_SCANIA)
    // Campo mestre de integração: CFG_INTEGRACAO_ATIVA (em TAB1)
    AAdd(aRegras, { "TAB1"           , "TAB1"    , "CFG_INTEGRACAO_ATIVA", aTab1 })
    AAdd(aRegras, { "TAB2"           , "TAB1"    , "CFG_INTEGRACAO_ATIVA", aTab2 })
    AAdd(aRegras, { "TAB3"           , "TAB1"    , "CFG_INTEGRACAO_ATIVA", aTab3 })
    
    // --- SCRM (Folder SCRM_SCANIA)
    // Campo mestre de integrao: SCRM_INTEGRACAO_ATIVA (em TAB_SCRM)
    AAdd(aRegras, { "TAB_SCRM"       , "TAB_SCRM", "SCRM_INTEGRACAO_ATIVA", aScrm })
    AAdd(aRegras, { "TAB_GERAIS_SCRM", "TAB_SCRM", "SCRM_INTEGRACAO_ATIVA", aGerScrm })
    AAdd(aRegras, { "TAB_GATILHOS_SCRM", "TAB_SCRM", "SCRM_INTEGRACAO_ATIVA", aGatScrm })

    // --- ARMS (Folder ARMS_SCANIA)
    // Campo mestre de integração: ARMS_INTEGRACAO_ATIVA (em TAB_ARMS)
    AAdd(aRegras, { "TAB_ARMS"        , "TAB_ARMS", "ARMS_INTEGRACAO_ATIVA", aARMSToken })
    AAdd(aRegras, { "TAB_ARMS_CONSULTA", "TAB_ARMS", "ARMS_INTEGRACAO_ATIVA", aARMSCons })

    // Campo Mestre de integração: COTO_INTEGRACAO_ATIVA (em TAB_COTO)
	AAdd(aRegras, { "TAB_COTO"       , "TAB_TOKEN_COTO", "COTO_INTEGRACAO_ATIVA", aCoto })
    AAdd(aRegras, { "TAB_TOKEN_COTO", "TAB_TOKEN_COTO", "COTO_INTEGRACAO_ATIVA", aCotoToken })
    AAdd(aRegras, { "TAB_GERAIS_COTO", "TAB_TOKEN_COTO", "COTO_INTEGRACAO_ATIVA", aCotoGeneral })
    AAdd(aRegras, { "TAB_CONCESSIONARIA_COTO", "TAB_TOKEN_COTO", "COTO_INTEGRACAO_ATIVA", aCotoGridConcessionaria })
    AAdd(aRegras, { "TAB_TP_CONTRATO_COTO", "TAB_TOKEN_COTO", "COTO_INTEGRACAO_ATIVA", aCotoGridTPContratos })
    AAdd(aRegras, { "TAB_DEPARA_COTO", "TAB_TOKEN_COTO", "COTO_INTEGRACAO_ATIVA", aCotoGridDePara })

    /* -----------------------------------------------------------
       2) VARRER REGRAS ? CHECAR INTEGRAÇÃO + VALIDAR CAMPOS
       ----------------------------------------------------------- */

    For nI := 1 To Len(aRegras)

        cSubModVal := aRegras[nI][1]   // Submodel a validar
        cSubModInt := aRegras[nI][2]   // Submodel dono da integração_ativa
        cCampoInt  := aRegras[nI][3]   // campo integração ativa
        aCampos    := aRegras[nI][4]   // campos obrigatórios

        // Submodelo dono do campo de integração
        oSubInt := oModel:GetModel(cSubModInt)
        If ValType(oSubInt) <> "O"
            Loop // se não existe, ignora regra
        EndIf

        // Lê o valor do campo de integração a partir do SubModel "mestre"
        xValInt := oSubInt:GetValue(cCampoInt)

        // Se integração da Folder NÃO estiver ativa ? não valida nada dessa regra
        If xValInt <> "1"
            Loop
        EndIf

        // Submodelo que terá os campos validados
        oSubVal := oModel:GetModel(cSubModVal)
		oGridConcessionaria := oModel:GetModel():getModel("TAB_CONCESSIONARIA_COTO")
		oGridTPContrato := oModel:GetModel():getModel("TAB_TP_CONTRATO_COTO")
        If ValType(oSubVal) <> "O"
            Loop
        EndIf

        // Integração ativa ? validar preenchimento dos campos
		For nJ := 1 To Len(aCampos)
			cCampo := aCampos[nJ]
			xValor := oSubVal:GetValue(cCampo)

			If Empty(xValor)
				AAdd(aErros, { cSubModVal, cCampo })
			EndIf
		Next nJ

		//-- Grid Concessionaria
		If oGridConcessionaria:Length() > 0
			lErroGrid := .T.

			For nLinha := 1 To oGridConcessionaria:Length()
				oGridConcessionaria:GoLine(nLinha)

				If !oGridConcessionaria:IsDeleted()
					lErroGrid := .F.
					Exit
				EndIf
			Next

			If lErroGrid .and. Ascan(aErroGrid, {|x| x[2] == STR0004}) == 0 // "Concessionaria"
				AAdd(aErroGrid, {"Control Tower", STR0004})
			EndIf
		EndIf

		//-- Grid Contrato
		If oGridTPContrato:Length() > 0
			lErroGrid := .T.

			For nLinha := 1 To oGridTPContrato:Length()
				oGridTPContrato:GoLine(nLinha)

				If !oGridTPContrato:IsDeleted()
					lErroGrid := .F.
					Exit
				EndIf
			Next

			If lErroGrid .and. Ascan(aErroGrid, {|x| x[2] == STR0005}) == 0 // "Contrato"
				AAdd(aErroGrid, {"Control Tower", STR0005})
			EndIf
		EndIf
	Next nI

    /* -----------------------------------------------------------
       3) MONTAGEM DA MENSAGEM DE USUÁRIO (FMX_HELP)
          COM TÍTULO DO CAMPO (cTitulo) VIA ESTRUTURA
       ----------------------------------------------------------- */

	If Len(aErros) > 0 .Or. Len(aErroGrid) > 0

		cMsg := STR0001 + CRLF + CRLF // "Existem campos obrigatórios não preenchidos:"

		For nI := 1 To Len(aErros)

			cSubModVal := aErros[nI][1]
			cCampo     := aErros[nI][2]

			oSubVal := oModel:GetModel(cSubModVal)
			oStruct := oSubVal:GetStruct()
			cTitulo := oStruct:GetProperty(cCampo, MODEL_FIELD_TITULO)

			cMsg += oSubVal:CDESCRIPTION + " - " + cTitulo + CRLF

		Next nI

		For nI := 1 to Len(aErroGrid)
			cMsg += aErroGrid[nI][1] + " - " + STR0006 + aErroGrid[nI][2] + CRLF // "Existe Campos não preenchidos na grid de "
		Next nI

		// Função padrão DMS para mensagem ao usuário
		FMX_HELP(STR0002, ; // "Validação de Campos"
					cMsg, ;
					STR0003) // "Preencha os campos obrigatórios para prosseguir."

		Return .F.
	EndIf

Return .T.

/*/{Protheus.doc} UpdateRegras
@description
    Atualiza dinamicamente o array de campos obrigatrios da aba de "Gerais SCRM"
    com base no valor do campo `SCRM_GERA_ARQUIVO`, localizado no SubModelo
    `TAB_GERAIS_SCRM`.

    Caso o valor de `SCRM_GERA_ARQUIVO` seja igual a `"2"`, os campos
    `SCRM_GERA_ARQUIVO` e `SCRM_FILE_PATH` sero removidos do array de campos
    obrigatrios, tornando seu preenchimento opcional na validao dinmica.

    Esta funo  utilizada dentro da rotina de validao `OA5410022N_ValidaCamposObrigatorios`.

@rules
    - Considera que o campo `SCRM_GERA_ARQUIVO` est presente em `TAB_GERAIS_SCRM`.
    - O retorno  sempre um clone do array original, mesmo que nenhuma alterao ocorra.
    - A remoo  baseada no contedo do array, utilizando comparao exata (`==`).

@param  oModel     (Object)     ? Instncia do MPFormModel com os dados atuais da interface
@param  aGerScrm   (Array)      ? Lista de campos obrigatrios da aba "Gerais SCRM"

@return Array
    ? Novo array com os campos obrigatrios ajustados de acordo com a condio de negcio

@since   14/11/2025
@version 1.0
@type    Function
@author  Lucas Brustolin
*/
Method _updateRegras(oModel, aGerScrm) class OFIA541EVDEF
    Local aRetorno := aClone(aGerScrm)
    Local nIndex   := 0
    Local cValor   := ""

    Default oModel := FWModelActive()

    If ValType(oModel) == "O"
        cValor := oModel:GetModel("TAB_GERAIS_SCRM"):GetValue("SCRM_GERA_ARQUIVO")

        If cValor == "2"
            // Remove "SCRM_FILE_PATH"
            nIndex := aScan(aRetorno, {|x| x == "SCRM_FILE_PATH" })
            If nIndex > 0
                aDel(aRetorno, nIndex)
                aSize(aRetorno, Len(aRetorno) - 1)
            EndIf

            // Remove tambm "SCRM_GERA_ARQUIVO"
            nIndex := aScan(aRetorno, {|x| x == "SCRM_GERA_ARQUIVO" })
            If nIndex > 0
                aDel(aRetorno, nIndex)
                aSize(aRetorno, Len(aRetorno) - 1)
            EndIf
        EndIf
    EndIf
Return aClone(aRetorno)
