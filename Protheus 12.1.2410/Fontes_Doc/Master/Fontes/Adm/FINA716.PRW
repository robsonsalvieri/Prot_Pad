#INCLUDE "TOTVS.ch"
#Include "FINA716.ch"

Static __cDateFormat As Character
Static __cValFormat As Character
Static __oHashCache

/*/{Protheus.doc} FINA716
    Chamada do app de aplicações e emprestimos pelo menu do protheus

    @author Vitor Duca
    @since 23/06/2022
/*/
Function FINA716()
	Local lOk As Logical
	Private cNGFVersion as character

	lOk := .T.
	__cDateFormat := getDtFmt()
	__cValFormat  := getValFmt()
	__oHashCache  := FwHashMap():New()
	cNGFVersion   := F716Ver()
	// Verifica se a pota multiprotocola está configurada no ambiente
	If FindFunction("AmIOnRestEnv")
		If !AmIOnRestEnv()
			Help('', 1, "NOAPPENV", NIL, STR0001, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0009})
			lOk := .F.
		EndIf
	EndIf

	If GetSx3Cache("EH_NUMERO", "X3_TAMANHO") <> GetSx3Cache("EI_NUMERO", "X3_TAMANHO") .or. GetSx3Cache("EH_NUMERO", "X3_TAMANHO") > TamSXG("018")[1]
		Help('', 1, "F716TAMNUM", NIL, STR0019, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0020 + cValToChar(TamSXG("018")[1])}) // "O tamanho dos campos EH_NUMERO e/ou EI_NUMERO estão incorretos" # "Os tamanhos devem ser iguais e não podem ultrapassar o limite de "
		lOk := .F.
	Endif

	If lOk
		FwCallApp("FINA710")
	EndIf

Return

/*/{Protheus.doc} JsToAdvpl
    configura o preLoad do sistema

    @param oWebChannel, object
    @param cType, character
    @param cContent, character

    @author Vitor Duca
    @since 23/06/2022
/*/
Static Function JsToAdvpl(oWebChannel As Object, cType As Character, cContent As Character)
	Local jsonDtFormat     as Json
	Local jsonValFormat    as Json
	Local jsonFunName      as Json
	Local aContent         as Array
	Local cFilBkp          as Character
	Local jStorage         as Json
	Local nOpcDetPrv	   as Numeric
	Local cTypeDet         as Character

	cType   := Upper(cType)

	Do Case
		Case cType == "PRELOAD"
			if cNGFVersion == "1"
				jsonDtFormat     := JsonObject():New()
				jsonValFormat    := JsonObject():New()
				jsonFunName      := JsonObject():New()
				jStorage         := JsonObject():New()

				jsonDtFormat["DateFormat"]     := __cDateFormat
				jsonValFormat["ValueFormat"]   := __cValFormat
				jsonFunName["FunName"]         := "fina716"

				// objeto para adicionar na sessionStorage de forma dinamica
				jStorage["AppVersion"]  	:= SubStr(DtoS(getapoinfo("fina710.app")[4]), 3)
				jStorage['LayoutSM0'] 		:= FWSM0Layout()
				jStorage['ProPaisLoc']  	:= cPaisLoc
				jStorage['DateFormat']		:= jsonDtFormat:toJSON()
				jStorage['ValueFormat']		:= jsonValFormat:toJSON()
				jStorage['FunName']			:= jsonFunName:toJson()
				jStorage['Branch_MarkAll'] 	:= VerSenha(114) .or. VerSenha(115)
				jStorage['Branch_Profile']	:= ''

				oWebChannel:AdvPLToJS('setStorage', jStorage:toJSON())

				FreeObj(jsonDtFormat)
				FreeObj(jStorage)
			endIf
		/*
		Trecho mantido para metricas futuras

		Case cType == 'FWLsPutAsyncInfo'
			If !Empty(cContent) .And. !__oHashCache:containsKey(cContent) // controle para acionar apenas uma vez enquanto navega
				FWLsPutAsyncInfo("LS006", RetCodUsr(), '06', cContent)
				__oHashCache:put(cContent)
			EndIf
		*/
		Case cType == 'GETSXENUM'
			If !Empty(cContent)
				aContent := StrTokArr2(cContent, '|', .T.)
				If Len(aContent) == 4
					DbSelectArea("SEH")
					cFilBkp := cFilAnt
					If !Empty(aContent[1])
						cFilAnt := aContent[1]
					EndIF
					oWebChannel:AdvPLToJS('RETSXENUM', GetSxENum(Upper(aContent[2]), Upper(aContent[4]),,Val(aContent[3])))
					cFilAnt := cFilBkp
				Else
					oWebChannel:AdvPLToJS('RETSXENUM', ' ')
				EndIf
			EndIf
		Case cType == 'CONFIRMSX8'
			cFilBkp := cFilAnt
			cFilAnt := cContent
			ConfirmSX8()
			cFilAnt := cFilBkp
		Case cType == 'ROLLBACKSX8'
			cFilBkp := cFilAnt
			cFilAnt := cContent
			RollBackSx8()
			cFilAnt := cFilBkp
		Case cType == 'DETPROVA'
			If !Empty(cContent)
				// 1- filial 2- idproces 3- vizualia(2) ou altera(4) 4- mostra lancamento
				aContent := StrTokArr2(cContent, '|', .T.)
				nOpcDetPrv := Val(aContent[3])
				cFilBkp := cFilAnt
				cFilAnt := FXRetFil("SEH", Padr(aContent[1], TamSx3("EH_FILIAL")[1]))
				cTypeDet:= ''
				// regra mostra lançamento;1 (sim) = sempre mostra 2 (nao) = so exibe tela se existir inconsistencia
				If len(aContent) > 3 .And. aContent[4] == '2'
					cTypeDet := '1'
				EndIf
				If FindFunction('CTB102POUI') .And. !Empty(aContent[2])
					Altera := .F.
					CTB102POUI(cFilAnt, aContent[2], cTypeDet, nOpcDetPrv)
				EndIf
				cFilAnt := cFilBkp
				oWebChannel:AdvPLToJS('detprova', ' ')
			EndIf
		Case cType == "MENU"
			jMenu := JsonObject():new()
			jMenu['a710AplEmp'] := .T.
			jMenu['a710BrwAprop'] := FindFunction('backoffice.ngf.preload.detProvaPoUi', .T.) .And. backoffice.ngf.preload.detProvaPoUi() > 0
			oWebChannel:AdvPLToJS(cContent, jMenu:toJson())
		Case cType == "GETINFO"
			jStorage                   := JsonObject():New()
			jStorage['AppVersion']     := SubStr(DtoS(getapoinfo( 'fina710.app' )[4]), 3)
			jStorage['UserName']       := cUserName
			jStorage['ProPaisLoc']     := cPaisLoc
			jStorage['DateFormat']     := __cDateFormat
			jStorage['PictFormat']     := __cValFormat
			jStorage['FunName']        := 'fina716'
			jStorage['Branch_MarkAll'] 	:= VerSenha(114) .or. VerSenha(115)
			jStorage['Branch_Profile']	:= ''
			jStorage['NGFAPLVersion']  := cNGFVersion
			oWebChannel:AdvPLToJS(cContent, jStorage:toJSON())
			FreeObj(jStorage)
		Case cType == "CALLFUNCTION"
			appCallFNC(cContent, oWebChannel)
		Case cType == "EXECRESCUE"
			F716ResPay(cContent, 'APL', oWebChannel)
		Case cType == "EXECPAYMENT"
			F716ResPay(cContent, 'EMP', oWebChannel)
	EndCase

Return

/*/{Protheus.doc} F716ResPay
	Realiza o resgate ou pagamentos atraves dos services
	@type  Static Function
	@author Vitor Duca
	@since 01/07/2024
	@version 1.0
	@param cBody, Character, Body enviado pelo front pelo websocket
	@param cType, Character, Tipo do contrato que deve conter APL ou EMP
	@param oWebChannel, Object, Objeto tWebChannel que será utilizado para devolver o conteudo ao front
/*/
Function F716ResPay(cBody As Character, cType As Character, oWebChannel As Object)
	Local jBody	:= JsonObject():new()		as Json
	Local jResponse := JsonObject():new()	as Json
	Local nOperation := 3					as Numeric
	Local cPathParam := ""					as Character
	Local cFilBkp := cFilAnt				as Character

	jBody:FromJson(cBody)

	If jBody:hasProperty("operation")
		nOperation := jBody["operation"]
	Endif

	if jBody:hasProperty("pathParam")
		cPathParam := jBody["pathParam"]
	Endif

	If jBody:hasProperty("eh_filial") .and. !Empty(jBody["eh_filial"])
		cFilAnt := FXRetFil("SEH", Padr( jBody["eh_filial"], FWSizeFilial()))
	Endif

	If cType == "APL"
		If nOperation == 3
			jResponse := totvs.protheus.backoffice.ngf.rescue.RescueApplication(jBody)
		Else
			jResponse := totvs.protheus.backoffice.ngf.rescue.ReverseRescueApplication(cPathParam, jBody)
		Endif
	Elseif cType == "EMP"
		If nOperation == 3
			jResponse := totvs.protheus.backoffice.ngf.payment.PaymentLoan(jBody)
		Else
			jResponse := totvs.protheus.backoffice.ngf.payment.ReversePaymentLoan(cPathParam, jBody)
		Endif
	Endif

	cFilAnt := cFilBkp
	oWebChannel:AdvPLToJS(jBody["receivadId"], jResponse:ToJson())
Return

/*/{Protheus.doc} getDtFmt
    Pega o formato da data baseado
	na configuração do Ini.

    @author Luiz.nai
    @since 16/02/2022
/*/
Static Function getDtFmt() As Character
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

Return cFormat

/*/{Protheus.doc} getValFmt
    Pega o formato do valor baseado
	na configuração do Ini.

    @author Luiz.nai
    @since 16/02/2022
/*/
Static Function getValFmt() As Character
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

/*/{Protheus.doc} F716Ver
    Verifica a versao do APLEMP para o ambiente

    @return character
    @author renato.ito
    @since  19/04/2025
/*/
function F716Ver() as character
	Local cVersion as character
	Local lPiloto  as logical

	lPiloto  := GetPvProfString(GetEnvServer(), "PILOTMIFINA716", "0", GetSrvIniName()) == '1'
	cVersion := "1"

	// Verifica o ambiente para execução do APLEMP V2
	if GetRPORelease() >= "12.1.2510" .or. lPiloto
		cVersion := "2"
	endIf

return cVersion
