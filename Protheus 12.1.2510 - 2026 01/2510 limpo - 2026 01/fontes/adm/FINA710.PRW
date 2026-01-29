#include 'PROTHEUS.CH'
#Include "FwSchedule.ch"
#Include "FINA710.ch"
#INCLUDE "FWLIBVERSION.CH"
#INCLUDE "FWBROWSE.CH"
#Include 'FWMVCDef.ch'

Static __lMetric	:= .F.
Static __lAcces		:= .T.
Static __oHashCache
Static __lIAFin     := .F.
Static __cSessionID := ""

/*/{Protheus.doc} FINA710
    Chamada do app pelo menu do protheus

    @author renato.ito
    @since 10/09/2020
/*/
Function FINA710()
	Local cMvTfcjobT    as character
	Local nRetMnu       as numeric
	Local lOk           as logical
	Private aRotina     as array
	Private nStartTime  as character
	Private cDateFormat as character
	Private cValFormat  as character
	Private cNGFVersion as character

	cDateFormat := getDtFmt()
	cValFormat  := getValFmt()
	cNGFVersion := F710Ver()
	aRotina     := MenuDef()
	nRetMnu     := 0

	getMenu710(@nRetMnu)

	If nRetMnu == 0
		MsgStop( STR0012 + CRLF + STR0013, STR0014 ) // "Este usuário não possui acesso para executar essa operação." # "Menu: FINA710" # "Atenção"
		Return
	Endif

	__lMetric    := FwLibVersion() >= "20210517"
	__oHashCache := FwHashMap():New()
	__lIAFin     := FindFunction('SendMetricFin') .And. Findfunction('VldTenant') .And. Findfunction('VldTenantI14');
					.And. FindFunction('IAFinancial')
	nStartTime   := Time()
	lOk          := .T.

	If !(GetRpoRelease() >= "12.1.033")
		If !(&("gfin.util.validRelease.getValidRelease()"))
			Help(, , STR0005, , STR0004, 1, 0) // #"Novo Gestor Financeiro" #"Para uso deese recurso o ambiente deverá ser atualizado para versão 12.1.33"
			Return
		Endif
	Endif

	// Verifica se o dicionário é compatível
	If !AliasIndic("F75") .Or. !AliasIndic("F76")
		Help(, , "FINA710DIC", , STR0001, 1, 0)    // "Dicionário incompatível com a aplicação."
		lOk := .F.
	EndIf

	If lOk
		// Verifica se o ambiente está com os campos necessário para a execução do Novo Gestor Financeiro
		If F710CfgOk()
			if cNGFVersion == "1"
				cMvTfcjobT := SuperGetMV("MV_TFCJOBT",,'')
				// Job ainda não foi executado, necessário aguardar para o uso do Novo Gestor Financeiro
				If Empty(cMvTfcjobT)
					FwCustomMetrics():setSumMetric("FINA711 - Carga inicial", "financeiro-protheus_qtd-por-acesso_total", 1)
					Help(' ', 1, 'FINA710JOB' , , STR0002 , 1 , 0)  // 'A carga de dados não foi concluída/realizada. Por favor, solicitar ao administrador do sistema verificar a execução do Job FINA711 no módulo configurador.'
					lOk := .F.
				endIf
			endIf
			// Insights IA Financeiro
			If lOk .And.__lIAFin
				__cSessionID := FWUUIDV1()
				SendMetricFin ({"INSIGHT_ACCESS_FINA710", __cSessionID})
			EndIf
			if lOk
				FwCallApp("FINA710")
			endIf
		Else
			F712Wiz()
		EndIf
	EndIf
	FreeObj(__oHashCache)
Return

/*/{Protheus.doc} getDtFmt
    Pega o formato da data baseado
	na configuração do Ini.

    @author Luiz.nai
    @since 16/02/2022
/*/
Static Function getDtFmt()
	Local cFormat As Character
	Local cLanguage As Character
	Local cIdiom As Character
	cIdiom := FwRetIdiom()
	cFormat := "dd/mm/yyyy"

	cLanguage := GetPvProfString(GetEnvServer(), "DateFormat", "NOEXISTS", GetSrvIniName())

	If(Upper(cIdiom) == 'EN')
		cFormat := "mm/dd/yyyy"
	EndIf

	If(cLanguage != "NOEXISTS")
		If(Upper(cLanguage) == "AMERICAN")
			cFormat := "mm/dd/yyyy"
		EndIf
	EndIf

	If(Upper(cIdiom) == 'RU')
		cFormat := "dd.mm.yyyy"
	EndIf
Return cFormat

/*/{Protheus.doc} getValFmt
    Pega o formato do valor baseado
	na configuração do Ini.

    @author Luiz.nai
    @since 16/02/2022
/*/
Static Function getValFmt()
	Local cFormat As Character
	Local cLanguage As Character
	Local cIdiom As Character
	cIdiom := FwRetIdiom()
	cFormat := "DEFAULT"

	cLanguage := GetPvProfString(GetEnvServer(), "PictFormat", "NOEXISTS", GetSrvIniName())

	If(cLanguage != "NOEXISTS")
		If(Upper(cLanguage) == "AMERICAN")
			cFormat := "AMERICAN"
		EndIf
	Else
		If(Upper(cIdiom) == 'EN')
			cFormat := "AMERICAN"
		EndIf
	EndIf

Return cFormat

/*/{Protheus.doc} JsToAdvpl
    configura o preLoad do sistema

    @param oWebChannel, object
    @param cType, character
    @param cContent, character

    @author renato.ito
    @since 26/01/2021
/*/
Static Function JsToAdvpl(oWebChannel As Object, cType As Character, cContent As Character)
	Local jsonDtFormat   	as Json
	Local jsonValFormat		as Json
	Local jsonFunName       as Json
	Local nTimeSencs  := 0 	as Numeric
	Local jStorage          as Json
	Local jMenu				as Json
	Local jContent			as Json

	Do Case
		Case cType == "preLoad"
			jStorage         := JsonObject():New()
			if cNGFVersion == "1"
				jsonDtFormat     := JsonObject():New()
				jsonValFormat    := JsonObject():New()
				jsonFunName      := JsonObject():New()
				jsonDtFormat["DateFormat"]      := cDateFormat
				jsonValFormat["ValueFormat"]    := cValFormat
				jsonFunName["FunName"]          := 'fina710'
				// objeto para adicionar na sessionStorage de forma dinamica
				jStorage['AppVersion']  	:= SubStr(DtoS(getapoinfo('fina710.app')[4]), 3)
				jStorage['UserName'] 		:= cUserName
				jStorage['ProPaisLoc']  	:= cPaisLoc
				jStorage['DateFormat']		:= jsonDtFormat:toJSON()
				jStorage['ValueFormat']		:= jsonValFormat:toJSON()
				jStorage['FunName']			:= jsonFunName:toJson()
				jStorage['Branch_Profile'] 	:= RetProfDef(__cUserId, "NGF", "BranchSel", "Filter",,, cEmpAnt)
				jStorage['Branch_MarkAll']	:= .F.
			endIf

			// Insights IA Financeiro
			If __lIAFin
				FinPermInsight(@jStorage,__cSessionID)
			Endif
			oWebChannel:AdvPLToJS('setStorage', jStorage:toJSON())
			FreeObj(jStorage)
		Case cType == "metrics"
			If __lAcces .And. __lMetric
				nTimeSencs := Secs(ELAPTIME(nStartTime, TIME()))
				// Metrica de tempo médio para exibir a tela de Painel de Controle
				FwCustomMetrics():setAverageMetric("MediaCargaNGF", "financeiro-protheus_tempo-conclusão-processo_seconds", nTimeSencs)
				__lAcces := .F.
			Endif
		Case cType == 'FWLsPutAsyncInfo'
			If __lMetric .And. !Empty(cContent) .And. !__oHashCache:containsKey(cContent) // controle para acionar apenas uma vez enquanto navega pelo NGF
				FWLsPutAsyncInfo("LS006", RetCodUsr(), '06', cContent)
				__oHashCache:put(cContent)
			EndIf
		Case cType $ "FinancialForecastRequest|FinancialForecastResponse|InsightAlerts|InsightAlertsUpdate|InsightMetric"
			// Insights IA Financeiro
			If __lIAFin
				IAFinancial(oWebChannel, cType, cContent, @jStorage, __cSessionID)
			EndIf
		Case cType == "menu"
			jMenu := JsonObject():new()
			jMenu := getMenu710()
			jMenu['a710ComunicaOn'] := jMenu['a710ConfCta'] .or. jMenu['a710ApiCR'] .or. jMenu['a710ApiCP']
			jMenu['a710ComunicaOnTechFin'] := jMenu['a710ConfCta'] .or. jMenu['a710BHTFM'] .Or. jMenu['a710BHTFO']
			oWebChannel:AdvPLToJS(cContent, jMenu:toJson())
		Case cType == "execblock"
			If (!Empty(cContent) .And. ExistBlock(cContent))
				oWebChannel:AdvPLToJS(cContent, ExecBlock(cContent, .F., .F.))
			Else
				oWebChannel:AdvPLToJS(cContent, "{'code': '400','message': 'ExecBlock Error','detailedMessage':" +  STR0018 + "}") //ExecBlock não foi localizado no repositório
			EndIf
		Case cType == "callFunction"
			appCallFNC(cContent, oWebChannel)
		Case cType == "getInfo"
			jStorage                   := JsonObject():New()
			jStorage['AppVersion']     := SubStr(DtoS(getapoinfo( 'fina710.app' )[4]), 3)
			jStorage['UserName']       := cUserName
			jStorage['ProPaisLoc']     := cPaisLoc
			jStorage['DateFormat']     := cDateFormat
			jStorage['PictFormat']     := cValFormat
			jStorage['FunName']        := 'fina710'
			jStorage['Branch_Profile'] := RetProfDef(__cUserId, "NGF", "BranchSel", "Filter",,, cEmpAnt)
			jStorage['Branch_MarkAll'] := .F.
			jStorage['NGFAPLVersion']  := cNGFVersion
			// Insights IA Financeiro
			If __lIAFin
				FinPermInsight(@jStorage,__cSessionID)
			Endif
			oWebChannel:AdvPLToJS(cContent, jStorage:toJSON())
			FreeObj(jStorage)
		Case cType == "F713ExpRot"
			If FindFunction("F713ExpRot")
				jContent := JsonObject():new()
				jContent:FromJson(cContent)

				lRet := F713ExpRot()
				oWebChannel:AdvPLToJS(jContent["receivadId"], Iif(lRet, "true", "false"))
			Endif
	EndCase

Return

/*/{Protheus.doc} F710CfgOk
    Verifica se o ambiente está configurado

    @return lOk As Logical, true ou false
    @author renato.ito
    @since 02/03/2021
/*/
Static Function F710CfgOk() as logical
	Local lOk As Logical

	// Verifica se a pota multiprotocola está configurada no ambiente
	// Verifica se exite o campo S_T_A_M_P_ nas tabelas
	lOk := F710VMProt() .and. F710VDic()
	// Verifica se já existe o job configurado
	If cNGFVersion == "1" .and. lOk
		lOk := F710VJob()
	EndIf
Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} IsMProt
Valida porta multiprotocolo

@return lRet
@author rafael.rondon
@since 02/03/2021
/*/
//-------------------------------------------------------------------
Function F710VMProt() As Logical
	Local lRet As Logical
	lRet := FindFunction("AmIOnRestEnv") .AND. AmIOnRestEnv()
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F710VDic
Valida Dicionário

@return lRet
@author rafael.rondon
@since 02/03/2021
/*/
//-------------------------------------------------------------------
Function F710VDic() As Logical
	Local lRet 		As Logical
	Local aTables   As Array
	Local nTable    As Numeric

	lRet := .T.

	aTables := STRTOKARR('SE1|SE2|FKD|SC5|SC6|SC7|SC9', '|' )
	For nTable := 1 To len(aTables)
		If Ascan(TCStruct(RetSqlName(aTables[nTable])), {|x| x[1] == 'S_T_A_M_P_'}) == 0
			lRet := .F.
		EndIf
	Next
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F710VJob
Valida Job

@return lRet
@author rafael.rondon
@since 02/03/2021
/*/
//-------------------------------------------------------------------
Function F710VJob() As Logical
	Local lRet As Logical
	Local cJob As Character

	lRet := .T.

	cJob := FwSchdByFunction("FINA711('" + cEmpAnt + "')")
	If (Empty(cJob))
		lRet := .F.
	EndIf
Return lRet


/*/{Protheus.doc} MenuDef
    Definição de menu de Acesso

    @return Array com o Menu
    @author francisco.oliveira
    @since 05/01/2022
/*/

Static Function MenuDef()
	Local aRotina As Array

	aRotina := {}

	ADD OPTION aRotina TITLE STR0006 ACTION "a710Painel"  OPERATION 1 ACCESS 0  // "Painel de Controle"
	ADD OPTION aRotina TITLE STR0007 ACTION "a710MovFin"  OPERATION 2 ACCESS 0 	// "Movimentações Financeiras"

	If cPaisLoc == 'BRA'
		ADD OPTION aRotina TITLE STR0016 ACTION "a710ApiCR" OPERATION 3 ACCESS 0 	// "Contas a receber"
		ADD OPTION aRotina TITLE STR0017 ACTION "a710ApiCP" OPERATION 4 ACCESS 0 	// "Contas a pagar"
		ADD OPTION aRotina TITLE STR0009 ACTION "a710ConfCta" OPERATION 5 ACCESS 0 	// "Configuração de Contas"
		ADD OPTION aRotina TITLE STR0019 ACTION "a710BHTFM"  OPERATION 6 ACCESS 0 	// "Boleto Hibrido - Monitor"
		ADD OPTION aRotina TITLE STR0020 ACTION "a710BHTFO"  OPERATION 7 ACCESS 0 	// "Boleto Hibrido - Ocorrências"

	Endif

Return(aRotina)

/*/{Protheus.doc} getMenu710
    Definição de privilegio de Acesso ao Menu

    @return Json
    @author francisco.oliveira
    @since 07/01/2022
/*/

Function getMenu710(nRetMnu As Numeric)
	Local jPrivUser	  As Json
	Local cUsersID	  As Character
	Local aRotina	  As Array
	Local nX		  As Numeric
	Local lAPICP 	  As Character

	Default nRetMnu := 0

	aRotina  	 := MenuDef()
	cUsersID 	 := RetCodUsr(cUserName)
	lAPICP		 := FindFunction("F717VldUso") .and. F717VldUso()

	jPrivUser	:= JsonObject():New()

	For nX := 1 To Len(aRotina)
		if aRotina[nX][2] == 'a710ApiCP'
			jPrivUser[aRotina[nX][2]] := MPUserHasAccess('FINA710', aRotina[nX][4], cUsersID) .and. lAPICP
		Else
			jPrivUser[aRotina[nX][2]] := MPUserHasAccess('FINA710', aRotina[nX][4], cUsersID)
		Endif

		If jPrivUser[aRotina[nX][2]]
			nRetMnu++
		Endif
	Next nX

Return jPrivUser

/*/{Protheus.doc} F710Ver
    Verifica a versão do NGF

    @return character
    @author renato.ito
    @since  19/04/2025
/*/
function F710Ver() as character
	Local cVersion as character
	Local lPiloto  as logical

	lPiloto  := GetPvProfString(GetEnvServer(), "NGF2510", "0", GetSrvIniName()) == '1'
	cVersion := "1"

	// Verifica o ambiente para a execução do Novo Gestor Financeiro V2
	if GetRPORelease() >= "12.1.2510" .or. lPiloto
		cVersion := "2"
	endIf

return cVersion
