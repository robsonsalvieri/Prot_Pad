#include 'PROTHEUS.CH'
#include 'FINXAPP.CH'

Static __cAppName := ""

/*
	Fonte generico para os arquivos .app do Financeiro
*/


/*/{Protheus.doc} FINAPP001
	Analise de credito financeiro (Protheus x Vadu)
	@type  Function
	@author Vitor Duca
	@since 16/12/2022
	@version 1.0
/*/
Function FINAPP001()
	If AliasInDic("F7F")
		__cAppName := 'finapp001.app'
		FwCallApp("FINAPP001")
	Else
		Help(, , "FINAPP001DIC", , STR0001, 1, 0) //"Dicionário incompatível com a aplicação."
	Endif
Return

/*/{Protheus.doc} JsToAdvpl
    configura o preLoad do sistema

    @param oWebChannel, object
    @param cType, character
    @param cContent, character

    @author renato.ito
    @since 09/12/2022
/*/
Static Function JsToAdvpl(oWebChannel As Object, cType As Character, cContent As Character)
	Local jStorage as Json

	Do Case
		Case cType == "preLoad"
			jStorage := JsonObject():New()
			// objeto para adicionar na sessionStorage de forma dinamica
			jStorage['AppVersion']  := SubStr(DtoS(getapoinfo(__cAppName)[4]), 3)
			jStorage["PaisLoc"]	:= cPaisLoc
			oWebChannel:AdvPLToJS('setStorage', jStorage:toJSON())
			FreeObj(jStorage)
	EndCase

Return

/*/{Protheus.doc} appCallFNC
    realiza a chamada de funcoes ADVPL pelo app

    @param cParams, character, deve ser um json em string
    @param oWebChannel, object, Objeto do TWebChannel quando a execução é via websocket

    @author renato.ito
    @since 16/05/2024
/*/
Function appCallFNC(cParams as Character, oWebChannel as Object, lAltFName as Logical)
	Local jParams as Json
	Local jReturn as Json
	Local cFilBkp as Character
	Local cFunBkp as Character

	DEFAULT cParams := ""
	DEFAULT oWebChannel := NIL
	DEFAULT lAltFName := .T.

	jParams := JsonObject():new()
	jReturn := JsonObject():new()
	cFilBkp := cFilAnt
	cFunBkp := FunName()

	jParams:fromJson(cParams)
	if (jParams:hasProperty("receivadId"))
		if (jParams:hasProperty("function") .and. jParams:hasProperty("option"))

			If lAltFName
				SetFunName(jParams["function"])
			Endif
			
			If jParams:hasProperty("branch") .And. !Empty(jParams['branch'])
				cFilAnt := appSetFil(jParams["alias"], jParams['branch'])
			endIf

			if jParams:hasProperty("alias") .and. jParams:hasProperty("index") .and. jParams:hasProperty("key")
				appOpTable(jParams["alias"], jParams["index"], jParams["key"])
			endIf

			do case
				case (jParams["function"] == "FINA040")
					if MPUserHasAccess( 'FINA040', jParams["option"], __cUserID, .T.)
						FINA040(, jParams["option"])
						jReturn["return"] := "true"
					else
						jReturn["return"] := "fasle"
					endIf
				case (jParams["function"] == "FINA050")
					if MPUserHasAccess( 'FINA050', jParams["option"], __cUserID, .T.)
						FINA050(,, jParams["option"])
						jReturn["return"] := "true"
					else
						jReturn["return"] := "fasle"
					endIf
				case (jParams["function"] == "FINA171EMP")
					FINA171EMP(jParams["option"])
					jReturn["return"] := "true"
				case (jParams["function"] == "FINA171APL")
					FINA171APL(jParams["option"])
					jReturn["return"] := "true"
				case (jParams["function"] == "FA171IDX")
					FA171IDX()
					jReturn["return"] := "true"
				OtherWise
					&(jParams["function"])
					jReturn["return"] := "true"
			endCase

			cFilAnt := cFilBkp
			SetFunName(cFunBkp)
		endIf

		If oWebChannel <> NIL
			oWebChannel:AdvPLToJS(jParams["receivadId"], jReturn:toJson())
		Endif
	endIf
Return

/*/{Protheus.doc} appOpTable
    Auxiliar para appCallFNC, posiciona o registro para acionar uma funcao ADVPL

    @param cAlias, character, alias da tabela
    @param nOrder, Numeric, order da tabela
    @param cKey, character, chave para pesquisa

    @author renato.ito
    @since 16/05/2024
/*/
Function appOpTable(cAlias as Character, nOrder as Numeric, cKey as Character)
	Local aKey as Array
	aKey := totvs.protheus.backoffice.fin.apiutil.normalizeID(cKey, cAlias, nOrder)

	if (!Empty(aKey[2]))
		dbSelectArea(cAlias)
		dbSetOrder(nOrder)
		(cAlias)->(DbSeek(aKey[2]))
	endIf
Return

/*/{Protheus.doc} appSetFil
	Realiza a configuração da cFilAnt de acordo com o parametro cBranch fazendo com que 
	o ambiente fique posicionado na filial correta
	@type  Static Function
	@author Vitor Duca
	@since 21/09/2026
	@version 1.0
	@param cAlias, Character, Alias da tabela que será verificada
	@param cBranch, Character, Filial que será verificada e que possivelmente irá sobrepor cFilAnt
	@return cBranchRet, Character, Filial corretamente configurada para sobrepor cFilAnt
	@example
	cFilAnt := appSetFil("SEH", "D MG") ou cFilAnt := appSetFil("SEH", "D MG 02 ")
/*/
Static Function appSetFil(cAlias as character, cBranch as character) as character
	Local cBranchRet as character

	DEFAULT cAlias := ""
	DEFAULT cBranch := ""

	cBranchRet := cFilAnt

	If !Empty(cBranch)
		cBranchRet := Padr( cBranch, FWSizeFilial())
	Endif

	//A função FXRetFil só deve ser chamada se o conteudo da filial for realmente incompleto
	If !Empty(cAlias) .and. Len(Alltrim(cFilAnt)) > Len(AllTrim(cBranchRet))
		cBranchRet := FXRetFil(cAlias, cBranchRet)
	Endif

return cBranchRet
