#Include "Totvs.ch"
#Include "FWMVCDEF.ch"
#Include "FATA142.ch"

#Define TAB_CATEGORY "ACU"
#Define TAB_ATTRIBUTE "D4V"
#Define FUN_CATEGORY  "FATA140"
#Define FUN_ATTRIBUTE "ESTA012"

Static __cCodPai := ""

//-------------------------------------------------------------------
/*/{Protheus.doc} FATA142
Categorias (Smart-UI)

@type       Function
@author     Daniel Tonon / Squad Retail
@since      12/01/2026
@version    P12
/*/
//-------------------------------------------------------------------
Function FATA142()
	If F142ReqMin() // Valida se os requisitos mínimos para execução do app estão atendidos
		FwCallApp("product-categories")
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JsToAdvpl
Router de chamadas do Front-end

@type       Function
@author     Paulo Dias Oliveira / Daniel Tonon / Squad Retail
@since      12/01/2026
@version    P12
@param      oWebChannel , Object  - Canal de comunicação com o Front-end
@param      cType       , Character - Tipo de operação
@param      cContent    , Character - Conteúdo da operação
@return     .T. - Lógico
/*/
//-------------------------------------------------------------------
Static Function JsToAdvpl(oWebChannel, cType, cContent)
	Local aArea     as Array
	Local oJson     as Object
	Local cCode     as Character
	Local cCategory as Character
	Local cCatDesc  as Character
	Local lIsJson   as Logical

	aArea     := FWGetArea()
	cCode     := ""
	cCategory := ""
	cCatDesc  := ""
	lIsJson   := .F.

	// Tratamento do Conteúdo
	If !Empty(cContent) .And. ("{" $ cContent)
		oJson := JsonObject():New()
		If oJson:FromJson(cContent) == Nil
			cCode     := oJson:GetJsonText("code")
			cCategory := oJson:GetJsonText("category")
			cCatDesc  := oJson:GetJsonText("description")
			lIsJson   := .T.
		EndIf
	Else
		cCode := cContent
	EndIf

	// Roteamento
	Do Case
	// Categoria
	Case cType $ 'Edit|Include|Remove'
		ProcessCat(oWebChannel, cType, cCode, cContent)

	// Características
	Case cType $ 'IncludeAttribute|EditAttribute|RemoveAttribute'
		// Chama a função renomeada para evitar cache/conflito
		ProcAttr(oWebChannel, cType, cCode, cCategory, cCatDesc)

	EndCase

	FWRestArea(aArea)
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcessCat
CRUD da Categoria

@type       Function
@author     Paulo Dias Oliveira / Squad Retail
@since      12/01/2026
@version    P12
@param      oWebChannel , Object  - Canal de comunicação com o Front-end
@param      cType       , Character - Tipo de operação
@param      cCode       , Character - Código da Categoria
@param      cContent	, Character - Conteúdo da operação
/*/
//-------------------------------------------------------------------
Static Function ProcessCat(oWebChannel, cType, cCode, cContent)
	Local oModel as Object

	If cType == 'Include'
		F142SetSup(cCode) // Seta o código da categoria pai para ser utilizado como valor inicial no campo ACU_CODPAI da View de Categoria
		
		oModel := FWLoadModel(FUN_CATEGORY)
		oModel:SetOperation(MODEL_OPERATION_INSERT)
		oModel:Activate()

		FWExecView(STR0008, 'FATA140', MODEL_OPERATION_INSERT,,,,,,,,,oModel) // "Incluir"

		oModel:DeActivate()
		oModel:Destroy()
		oModel := Nil

		oWebChannel:AdvPLToJS('messageProtheus', STR0002) // "Inclusão Concluída"
	Else
		DbSelectArea(TAB_CATEGORY)
		(TAB_CATEGORY)->(DbSetOrder(1))

		If (TAB_CATEGORY)->(DbSeek(FWxFilial(TAB_CATEGORY) + cCode))
			If cType == 'Edit'
				// Abertura da View de Edição
				ExecuteVw(FUN_CATEGORY, STR0009, MODEL_OPERATION_UPDATE) // "Editar"
				oWebChannel:AdvPLToJS('messageProtheus', STR0003) // "Edição Concluída"
			ElseIf cType == 'Remove'
				// Abertura da View de Remoção
				ExecuteVw(FUN_CATEGORY, STR0010, MODEL_OPERATION_DELETE) // "Remover"
				oWebChannel:AdvPLToJS('messageProtheus', STR0004) // "Remoção Concluída"
			EndIf
		EndIf
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcAttr
CRUD Característica (Atributo)

@type       Function
@author     Paulo Dias Oliveira / Squad Retail
@since      12/01/2026
@version    P12
@param      oWebChannel , Object  - Canal de comunicação com o Front-end
@param      cType       , Character - Tipo de operação
@param      cCode       , Character - Código da Característica
@param      cCategory   , Character - Código da Categoria
@param      cCatDesc    , Character - Descrição da Categoria
/*/
//-------------------------------------------------------------------
Static Function ProcAttr(oWebChannel, cType, cCode, cCategory, cCatDesc)
	Local oModel    as Object
	Local oJsonRet  as Object
	Local lIsGlobal as Logical

	lIsGlobal := .F.

	// Seta o contexto da categoria para uso na View
	If FindFunction("E012SetCtx") .And. !Empty(cCategory)
		E012SetCtx(cCategory, cCatDesc)
	EndIf

	Do Case
		Case cType == 'IncludeAttribute'
			oModel := FWLoadModel(FUN_ATTRIBUTE)
			oModel:SetOperation(MODEL_OPERATION_INSERT)
			oModel:Activate()

			// Abertura da View de Inclusão
			ExecuteVw(FUN_ATTRIBUTE, STR0008, MODEL_OPERATION_INSERT) // "Incluir"

			oModel:DeActivate()
			oModel:Destroy()
			oModel := Nil

			// Verifica se as funções de retorno existem antes de chamar
			cCode := ""
			If FindFunction("E012GetLCd")
				cCode := E012GetLCd()
			EndIf

			If FindFunction("E012GetLGl")
				lIsGlobal := E012GetLGl()
			EndIf

			DbSelectArea(TAB_ATTRIBUTE)
			(TAB_ATTRIBUTE)->(DbSetOrder(1))

			If !Empty(cCode) .And. (TAB_ATTRIBUTE)->(DbSeek(FWxFilial(TAB_ATTRIBUTE) + cCode))
				oJsonRet := JsonObject():New()
				oJsonRet['code']     := cCode
				oJsonRet['category'] := cCategory
				oJsonRet['isGlobal'] := lIsGlobal
				
				oWebChannel:AdvPLToJS('linkNewAttribute', oJsonRet:ToJson())
			Else
				oWebChannel:AdvPLToJS('messageProtheus', STR0005) // "Operação Finalizada"
			EndIf

		Case cType == 'EditAttribute'
			DbSelectArea(TAB_ATTRIBUTE)
			(TAB_ATTRIBUTE)->(DbSetOrder(1))
			
			If (TAB_ATTRIBUTE)->(DbSeek(FWxFilial(TAB_ATTRIBUTE) + cCode))
				ExecuteVw(FUN_ATTRIBUTE, STR0009, MODEL_OPERATION_UPDATE) // "Editar"
				
				oWebChannel:AdvPLToJS('messageProtheus', STR0006) // "Característica Alterada"
				oWebChannel:AdvPLToJS('updateAttributes', '') 
			EndIf

	EndCase

	// Limpa contexto da função após operação
	If FindFunction("E012SetCtx")
		E012SetCtx("", "")
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ExecuteVw
Helper para execução de Views MVC

@type       Function
@author     Paulo Dias Oliveira / Squad Retail
@since      12/01/2026
@version    P12
@param      cRotina    , Character - Nome da Rotina
@param      cTitulo    , Character - Título da Janela
@param      nOperation , Numeric   - Tipo de Operação (Insert, Update, Delete)
/*/
//-------------------------------------------------------------------
Static Function ExecuteVw(cRotina, cTitulo, nOperation)
	Local cFunBkp as Character

	Default cRotina    := ""
	Default cTitulo    := ""
	Default nOperation := 1

	cFunBkp := FunName()

	SetFunName(cRotina)

	FWExecView(cTitulo, cRotina, nOperation)

	SetFunName(cFunBkp)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F142ReqMin
Valida os Requisitos Mínimos para execução do App

@type       Function
@author     Jorge Martins / Squad Retail
@since      06/02/2026
@version    P12
@return     lRet, Logical - .T. se os requisitos mínimos forem atendidos
/*/
//-------------------------------------------------------------------
Static Function F142ReqMin()
Local lRet      as Logical
Local cRotina   as Character
Local cProblema as Character
Local cSolucao  as Character

	lRet := .F.

	// Valida se as tabelas existem
	If AliasInDic("D4V") .And.; // D4V - Tabela de Características
	   AliasInDic("D4W") .And.; // D4W - Tabela de Lista de opções de Características
	   AliasInDic("AQU") .And.; // AQU - Tabela de Relacionamento Categoria x Características
	   AliasInDic("D4X") .And.; // D4X - Tabela de Valores das Características (Valoração)
	   ACU->(ColumnPos("ACU_CDPROD")) > 0 // Valida se o campo ACU_CDPROD existe
		lRet := .T.
	Else
		cRotina   := ProcName(0) // Nome da rotina onde ocorreu o erro
		cProblema := STR0011 // "Ambiente desatualizado"
		cSolucao  := STR0012 // "Necessário aplicar o pacote de expedição contínua backoffice mais recente."

		Help("", 1, "HELP", cRotina, cProblema, 1,,,,,,, {cSolucao})
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F142SetSup
Seta o código da categoria superior na variável estática __cCodPai

Obs: Utilizado como inicializador padrão do campo ACU_CODPAI
setado via fonte no FATA140

@type       Function
@author     Jorge Martins / Squad Retail
@since      24/02/2026
@version    P12
@param      cCodPai, Character - Código da categoria superior
/*/
//-------------------------------------------------------------------
Static Function F142SetSup(cCodPai)
	__cCodPai := cCodPai
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F142GetSup
Retorna o código da categoria superior (__cCodPai)

Obs: Utilizado como inicializador padrão do campo ACU_CODPAI
setado via fonte no FATA140

@type       Function
@author     Jorge Martins / Squad Retail
@since      24/02/2026
@version    P12
@return     __cCodPai, Character - Código da categoria superior
/*/
//-------------------------------------------------------------------
Function F142GetSup()
Return __cCodPai
