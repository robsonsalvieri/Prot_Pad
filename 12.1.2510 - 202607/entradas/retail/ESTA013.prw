#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "ESTA013.CH"

PUBLISH MODEL REST NAME MATA010RETAIL SOURCE MATA010

Static __cResultF3 := Nil
Static __cTabF3    := Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} E013F3GenR
Retorna o registro posicionado pela consulta especifica D4VD4X.

@type    Function
@author  Jorge Martins
@since   03/11/2025
@version 12
@return  cResult - Código da consulta selecionada
/*/
//-------------------------------------------------------------------
Function E013F3GenR()
	Local cResult As Character

	cResult := E013GetF3()

Return cResult

//-------------------------------------------------------------------
/*/{Protheus.doc} E013SetF3
Define o código da consulta selecionada na variável estática.

@type    Function
@author  Jorge Martins
@since   03/11/2025
@version 12
@param   cResult - Código da consulta selecionada
/*/
//-------------------------------------------------------------------
Static Function E013SetF3(cResult)
	__cResultF3 := cResult
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} E013GetF3
Retorna o código da consulta selecionada na variável estática.

@type    Function
@author  Jorge Martins
@since   03/11/2025
@version 12
@return  __cResultF3 - Código da consulta selecionada (variável estática)
/*/
//-------------------------------------------------------------------
Static Function E013GetF3()
Return __cResultF3

//-------------------------------------------------------------------
/*/{Protheus.doc} E013SetTab
Define o código da tabela da consulta selecionada na variável estática.

@type    Function
@author  Jorge Martins
@since   29/12/2025
@version 12
/*/
//-------------------------------------------------------------------
Static Function E013SetTab(cTabela)
	__cTabF3 := cTabela
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} E013GetTab
Retorna o código da tabela da consulta selecionada na variável estática.

@type    Function
@author  Jorge Martins
@since   29/12/2025
@version 12
@return  __cTabF3 - Código da tabela da consulta selecionada (variável estática)
/*/
//-------------------------------------------------------------------
Static Function E013GetTab()
Return __cTabF3

//-------------------------------------------------------------------
/*/{Protheus.doc} E013VldVal
Rotina de validação dos campos

@Obs: Função utilizada no X3_VALID dos campos da tabela D4V

@type    Function
@author  Jorge Martins
@since   03/11/2025
@version 12
@param   cField - Campo a ser validado
@param   xValue - Conteúdo do campo
@return  lValid - .T. se o valor do campo é válido
/*/
//-------------------------------------------------------------------
Function E013VldVal(cField, xValue)
	Local lValid     As Logical
	Local cProblema  As Character
	Local cSolucao   As Character
	Local oModel     As Object
	Local oModelD4X  As Object
	Local aArea      As Array
	Local aAreaD4V   As Array
	Local aAreaD4W   As Array
	Local nI         As Numeric
	Local cCodCarac  As Character
	Local oConSXB    As Object
	Local cRotina    As Character

	aArea := FwGetArea()
	aAreaD4V := D4V->(FwGetArea())
	aAreaD4W := D4W->(FwGetArea())

	D4V->(DBSetOrder(1))
	D4W->(DBSetOrder(1))

	oModel := FwModelActive()
	oModelD4X := oModel:GetModel("D4XDETAIL")

	lValid := .T.
	cCodCarac := FwFldGet("D4X_CARAC")

	// Campo de consulta padrão que deve existir na tabela SXB
	If cField $ "D4X_VALOR" .And. !Empty(xValue)
		If Empty(cCodCarac) // Valida se o código da característica foi preenchido
			lValid    := .F.
			cProblema := STR0019 // "Preencha o código da característica antes de preencher o valor."
			cSolucao  := STR0020 // "Informe o código da característica e tente novamente."
			Help('', 1, '', ProcName(0), cProblema, 1,,,,,,, {cSolucao})
		ElseIf D4V->(MsSeek(FWxFilial('D4V') + cCodCarac))
			cTipo  := D4V->D4V_TIPO // Tipo da característica (1=Lista de Opções, 2=Consulta Padrão, 3=Livre, 4=Número)
			Do Case 
				Case cTipo == "1" // Tipo Lista de Opções
					If !D4W->(MsSeek(FWxFilial('D4W') + cCodCarac + xValue))
						lValid := .F.
						cProblema := I18n(STR0002, {STR0016}) // "O conteúdo digitado não é válido para a característica do tipo 'Lista de opções'." / "Lista de opções"
						cSolucao  := STR0003 //"Selecione um valor válido através da Lupa (Botão F3)."
						Help('', 1, '', ProcName(0), cProblema, 1,,,,,,, {cSolucao})
					EndIf
				Case cTipo == "2" // Tipo Consulta Padrão
					oConSXB := FWSXB():New(ALLTRIM(D4V->D4V_F3))
					oConSXB:Activate()
					E013SetTab(oConSXB:cTable)
					
					If !ExistCpo(E013GetTab(), RTrim(xValue)) // Valida se o valor preenchido existe na tabela da consulta padrão.
						lValid := .F.
						cProblema := I18n(STR0002, {STR0017}) // "O conteúdo digitado não é válido para a característica do tipo '#1'." // "Consulta Padrão"
						cSolucao  := STR0003 // "Selecione um valor válido através da Lupa (Botão F3)."
						Help('', 1, '', ProcName(0), cProblema, 1,,,,,,, {cSolucao})
					EndIf
				Case cTipo == "4" // Tipo Numérico
					cRotina := ProcName(0)
					For nI := 1 to Len (xValue)
						// Verifica se na cadeia de caracteres possui caracteres não numéricos.
						// Com exceção à letra 'X' que pode ser usada em valores como Altura x Largura x Profundidade (Ex: 4x2x3)
						If !IsDigit(SubStr(xValue, nI, 1)) .And. IsAlpha(SubStr(xValue,nI,1)) .And. !Upper(SubStr(xValue,nI,1)) == "X"
							lValid    := .F.
							cProblema := I18n(STR0002, {STR0018}) //"O conteúdo digitado não é válido para a característica do tipo 'Numérico'." // "Numérico"
							cSolucao  := STR0006 //"Informe um valor numérico."
							Help('', 1, '', cRotina, cProblema, 1,,,,,,, {cSolucao})
							Exit
						EndIf
					Next nI
			EndCase
		EndIf
	EndIf

	FwRestArea(aAreaD4W)
	FwRestArea(aAreaD4V)
	FwRestArea(aArea)

Return lValid

//-------------------------------------------------------------------
/*/{Protheus.doc} MATA010ESTA013
Classe para ser utilizada na rotina MATA010 (Cadastro de Produtos) 
para adicionar a amarração de categorias x produtos.

@type    Class
@author  Jorge Martins
@since   08/12/2025
@version 12
/*/
//-------------------------------------------------------------------
CLASS MATA010ESTA013 FROM FWModelEvent

	DATA cModelProduto	As Character
	DATA lProdutoCadastro As Logical

	METHOD New(cModelMaster) CONSTRUCTOR
	METHOD VldActivate(oModel, cModelId)
	METHOD GridLinePosVld(oSubModel, cModelID, nLine)
	METHOD GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue)

	METHOD ModelDefMata010(oModel)
	METHOD ViewDefMata010(oView)
	METHOD A010CanActivate(oView)

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo de criação do objeto

@type    Method
@author  Jorge Martins
@since   08/12/2025
@version 12
@param   cModelMaster - Modelo Master
/*/
//-------------------------------------------------------------------
METHOD New(cModelMaster) CLASS MATA010ESTA013

	::cModelProduto    := cModelMaster
	::lProdutoCadastro := "D4X" $ SuperGetMv("MV_CADPROD",,"|SBZ|SB5|SGI|D3E|")
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} VldActivate
Metodo de validação para ativar o objeto de amarração de categoria x produto

@type    Method
@author  Jorge Martins
@since   08/12/2025
@version 12
@param   oModel   - Objeto Model
@param   cModelId - Id do Model
/*/
//-------------------------------------------------------------------
METHOD VldActivate(oModel, cModelId) CLASS MATA010ESTA013

	::ModelDefMata010(oModel)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDefMata010
Definição da view da tabela D4X para ser adicionada na View da tabela de produtos

@type    Method
@author  Jorge Martins
@since   26/12/2025
@version 12
@param   oView - Objeto View
/*/
//-------------------------------------------------------------------
METHOD ViewDefMata010(oView) CLASS MATA010ESTA013
Local oStruD4X As Object
Local nOpc     As Numeric

	If ::lProdutoCadastro
		nOpc := oView:GetOperation()
		oStruD4X := FWFormStruct(2, "D4X", {|cField| !(AllTrim(Upper(cField)) $ "D4X_PROD") })
		oStruD4X:RemoveField("D4X_CATEGO")
		oView:AddGrid("FORMD4X", oStruD4X, "D4XDETAIL")
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A010CanActivate
Metodo para ativar a view da amarração de categoria x produto

@type    Method
@author  Jorge Martins
@since   26/12/2025
@version 12
@param   oView - Objeto View
/*/
//-------------------------------------------------------------------
METHOD A010CanActivate(oView) CLASS MATA010ESTA013
Local nOpc := 0

	If ::lProdutoCadastro
		nOpc := oView:GetOperation()
		If MPUserHasAccess("ESTA012", nOpc) // checa se o ususario tem acesso a rotina na opcao escolhida
			oView:CreateHorizontalBox('BOXFORMD4X', 10)
			oView:SetOwnerView("FORMD4X", 'BOXFORMD4X')
			oView:EnableTitleView("FORMD4X", STR0007) // "Amarração Produto x Característica"
		EndIf
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDefMata010
Metodo de definição do model da tabela D4X para ser adicionada 
no Model da tabela de produtos

@type    Method
@author  Jorge Martins
@since   26/12/2025
@version 12
@param   oView - Objeto View
/*/
//-------------------------------------------------------------------
METHOD ModelDefMata010(oModel) CLASS MATA010ESTA013
Local oStruD4X As Object

	If ::lProdutoCadastro
		oStruD4X := FWFormStruct(1, "D4X")

		oModel:AddGrid("D4XDETAIL", ::cModelProduto, oStruD4X)
		oModel:SetRelation("D4XDETAIL", {{'D4X_FILIAL', 'xFilial("D4X")'}, {'D4X_PROD', 'B1_COD'}}, D4X->(IndexKey(1)))
		oModel:GetModel("D4XDETAIL"):SetOptional(.T.)
		oModel:GetModel("D4XDETAIL"):SetUniqueLine({"D4X_CARAC", "D4X_VALOR"})  // Define o campo ACV_CATEGO como chave única do detalhe ACVDETAIL
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} E013F3Gen
Monta a consulta padrão genérica de características

@type    Function
@author  Jorge Martins
@since   26/12/2025
@version 12
@return  lRet - .T. se a consulta foi executada com sucesso
/*/
//-------------------------------------------------------------------
Function E013F3Gen()
	Local oModalDlg As Object
	Local oColumn   As Object
	Local oList     As Object
	Local lRet      As Logical
	Local cTipo     As Character
	Local cF3       As Character
	Local cCarac    As Character
	Local aArea     As Array
	Local aAreaD4V  As Array
	Local nX        As Numeric
	Local cConteud  As Character

	aArea    := GetArea()
	aAreaD4V := D4V->(GetArea())

	E013SetF3("") // Zera o valor da consulta selecionada

	lRet   := .T.
	cCarac := FwFldGet("D4X_CARAC")
	cTipo  := Posicione('D4V', 1, FWxFilial('D4V') + cCarac, 'D4V_TIPO')

	If cTipo == "1" // Lista de opções
	
		oModalDlg := FWDialogModal():New()
		oModalDlg:setSize(200, 500)
		oModalDlg:SetTitle(STR0001) // "Características"
		oModalDlg:SetEscClose(.T.) // Permite fechar a tela com a tecla ESC
		oModalDlg:CreateDialog()

		oList := FWBrowse():New(oModalDlg:GetPanelMain())
		oList:SetDataTable(.T.)
		oList:SetAlias("D4W")
		oList:SetFilterDefault( "D4W_CODATR == '" + cCarac + "' " )
		oList:DisableConfig()
		oList:DisableReport()
		oList:SetOwner(oModalDlg:GetPanelMain())
		oList:SetDoubleClick( {|| lRet := .T., E013SetF3(D4W->D4W_VALOR), oModalDlg:Deactivate(), oList:DeActivate() } )

		oColumn := FWBrwColumn():New(); oColumn:SetData({||D4W->D4W_VALOR}); oColumn:SetTitle(STR0009); oColumn:SetSize(050); oList:SetColumns({oColumn}) // "Valor" 

		oList:Activate()

		oModalDlg:AddOkButton( {|| lRet := .T., E013SetF3(D4W->D4W_VALOR), oModalDlg:Deactivate(), oList:DeActivate() }, STR0010) // "Confirmar"
		oModalDlg:AddCloseButton( {|| lRet := .F., oModalDlg:Deactivate(), oList:DeActivate() }, STR0011) // "Fechar"
		oModalDlg:Activate()

	ElseIf cTipo == "2" // Consulta padrão

		cF3  := Posicione('D4V', 1, FWxFilial('D4V') + cCarac, 'D4V_F3')
		lRet := ConPad1( NIL , NIL , NIL , cF3 , NIL , NIL , .T., /*cVar*/ )

		If lRet .And. Type("aCpoRet") == "A" .And. Len(aCpoRet) > 0 // aCpoRet é populada pela rotina ConPad1
			cConteud := ""
			For nX := 1 To Len (aCpoRet)
				cConteud += aCpoRet[nX]
			Next nX
			E013SetF3(cConteud)
		EndIf

	Else // 3-Livre ou 4-Número
		E013SetF3("")
		MsgAlert(STR0008) //"Característica dos tipos 'Livre' e 'Número' não possuem consulta padrão. Digite o valor desejado."
	EndIf

	RestArea(aAreaD4V)
	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} E013Tipo
Devolve a descrição do tipo da característica.

@type    Function
@author  Jorge Martins
@since   26/12/2025
@version 12
@return  cRet   - Descrição do tipo da característica
@param   cCarac - Código da característica
/*/
//-------------------------------------------------------------------
Function E013Tipo(cCarac)
	Local cTipo     As Character
	Local cX3CBox   As Character
	Local aX3CBox   As Character
	Local cItem     As Character
	Local nItem     As Numeric
	Local nPos      As Numeric
	Local cRet      As Character
	Local aArea     As Array
	Local aAreaD4V  As Array
	Local aAreaD4X  As Array

	Default cCarac := ""
	
	cRet := ""
	
	If !Empty(cCarac)

		aArea    := FWGetArea()
		aAreaD4V := D4V->(FWGetArea())
		aAreaD4X := D4X->(FWGetArea())

		// Tipo da característica
		cTipo := Posicione('D4V', 1, FWxFilial('D4V') + cCarac, 'D4V_TIPO')

		// Lista de opções do campo D4V_TIPO
		cX3CBox := E013X3cBox('D4V_TIPO')

		If !Empty(cX3CBox) // Se existir lista de opções
			aX3CBox := STRTOKARR(AllTrim(cX3CBox) ,";") // Separa as opções em um array
		EndIf

		If (nItem := aScan( aX3CBox, {|aTp| cTipo $ aTp} )) > 0
			cItem := aX3CBox[nItem] // Opção selecionada (Ex: 1=Lista de Opções)
			nPos  := At('=', cItem) // Posição do '='
			cRet  := RIGHT(cItem, Len(cItem)-nPos) // Descrição da opção (Ex: Lista de Opções)
		EndIf

		FWRestArea(aAreaD4X)
		FWRestArea(aAreaD4V)
		FWRestArea(aArea)

	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} E013X3cBox
Devolve o conteudo do campo de lista de opções de acordo com o idioma corrente.

@type    Function
@author  Jorge Martins
@since   26/12/2025
@version 12
@param   cCampo - Nome do campo da tabela
@return  cRet   - String com a lista de opções
/*/
//-------------------------------------------------------------------
Function E013X3cBox(cCampo)
	Local cRet    as Character
	Local cX3CBox as Character
	Local cIdioma as Character

	cX3CBox := ''
	cIdioma := FWRetIdiom() // Retorna o idioma corrente do Protheus

	If cIdioma == 'pt-br' // Português
		cX3CBox := GetSx3Cache(cCampo, 'X3_CBOX')
	ElseIf cIdioma == 'en' // Inglês
		cX3CBox := GetSx3Cache(cCampo, 'X3_CBOXENG')
	ElseIf cIdioma == 'es' // Espanhol
		cX3CBox := GetSx3Cache(cCampo, 'X3_CBOXSPA')
	EndIf

	cRet := Alltrim(cX3CBox)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GridLinePreVld
Metodo de pré validação para o grid de amarração de 
caracteristica x produto

@type    Method
@author  cruz.rafael
@since   21/01/2026
@version 12
@param   oSubModel     - Objeto Grid do modelo
@param   cModelId      - Id do Model
@param   nLine         - Numero da linha sendo validada
@param   cAction       - Acao a ser executada
@param   cId           - Id do Campo
@param   xValue        - Valor do Campo
@param   xCurrentValue - Valor Atual
@return  lRet          - Indica se executou com sucesso (.T.) ou com erro (.F.)
/*/
//-------------------------------------------------------------------
METHOD GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) CLASS MATA010ESTA013
	Local lRet      As Logical
	Local cProblema As Character
	Local cSolucao  As Character

	lRet := .T.
	If !FwIsInCallStack("E013DelD4X") .And. cModelID == "D4XDETAIL"
		// Valida se a característica é herdada da categoria
		// Se for herdada, não permite alteração, deleção ou desfazer a deleção
		If cAction == "DELETE" .OR. cAction == "UNDELETE" .OR. (cAction == "SETVALUE" .AND. cId == "D4X_CARAC" .AND. xValue <> xCurrentValue)
			If !Empty(oSubModel:GetValue("D4X_CATEGO", nLine)) // Se o campo de categoria for vazio, indica que não é uma característica herdada da categoria.
				lRet      := .F.
				cProblema := STR0014 // "Não é possível alterar, deletar ou desfazer a deleção de uma característica herdada." 
				cSolucao  := STR0015 // "Exclua ou desfaça a exclusão da categoria." 
				Help('', 1, '', ProcName(0), cProblema, 1,,,,,,, {cSolucao})
			EndIf
		EndIf
	EndIf
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} E013DelD4X
Função para a deleção de linhas do grid

@type    Function
@author  cruz.rafael
@since   21/01/2026
@version 12
@param   oSubModel     - Objeto Grid do modelo
@param   cModelId      - Id do Model
@param   nLine         - Numero da linha sendo validada
@param   cAction       - Acao a ser executada
@param   cId           - Id do Campo
@param   xValue        - Valor do Campo
@param   xCurrentValue - Valor Atual
@return  lRet          - Indica se executou com sucesso (.T.) ou com erro (.F.)
/*/
//-------------------------------------------------------------------
Function E013DelD4X(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue)
	Local oModel    := oSubModel:GetModel() as Object
	Local oModelD4X	:= oModel:GetModel("D4XDETAIL") as Object
	Local lRet      := .T. as Logical
	Local nReg      := 1   as Numeric
	Local cCatego   := ""  as Character
	
	Default cAction := "DELETE" // Usado para verificação de recuperação de registro no model ACVDETAIL
	
	If cModelID == "ACVDETAIL"

		If cAction == "DELETE" .Or. cAction == "UNDELETE"
			cCatego := oSubModel:GetValue("ACV_CATEGO", nLine) // Pega a categoria da linha atual
		Else // cAction == "SETVALUE"
			cCatego := xCurrentValue // Pega a categoria da linha atual (antes da mudança)
		EndIf

		For nReg := 1 to oModelD4X:Length()
			If oModelD4X:GetValue("D4X_CATEGO", nReg) == cCatego
				If cAction == "DELETE" .OR. (cAction == "SETVALUE" .And. xValue <> xCurrentValue) // Se a ação for deleção, desfazer a deleção ou a alteração do campo, a(s) linha(s) serão de características deletadas.
					oModelD4X:Goline(nReg)
					oModelD4X:DeleteLine()
				ElseIf cAction == "UNDELETE"
					oModelD4X:Goline(nReg)
					oModelD4X:UnDeleteLine()
				EndIf
			EndIf
		Next nReg
		oModelD4X:Goline(1)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GridLinePosVld
Metodo de pós validação para o grid de amarração de caracteristica x produto

@type    Method
@author  cruz.rafael
@since   21/01/2026
@version 12
@param   oModel   - Objeto Model
@param   cModelId - Id do Model
@param   nLine    - Numero da linha sendo validada
@return  lRet     - Se executou com sucesso (.T.) ou com erro (.F.)
/*/
//-------------------------------------------------------------------
METHOD GridLinePosVld(oSubModel, cModelID, nLine) CLASS MATA010ESTA013
	Local lRet       As Logical
	Local oModel     As Object
	Local nTotLine   As Numeric
	Local nLineAtu   As Numeric
	Local cCarac     As Character
	Local aSaveRows  As Array
	Local aArea      As Array
	Local aAreaD4V   As Array
	Local cRotina    As Character

	lRet := .T.

	If cModelID == "D4XDETAIL" // Modelo de características

		oModel    := oSubModel:GetModel()
		cCarac    := oSubModel:GetValue("D4X_CARAC", nLine)
		nTotLine  := oSubModel:GetQtdLines()
		aSaveRows := FWSaveRows()
		aArea     := FWGetArea()
		aAreaD4V  := D4V->(FWGetArea())

		// Valida se a caracterítica foi utilizada em outra linha
		// Permite característas duplicadas se o tipo de seleção da característica for "Múltipla"
		If !Empty(cCarac) .And. oModel:GetOperation() <> MODEL_OPERATION_DELETE .And. !oSubModel:IsDeleted(nLine)
			D4V->(DBSetOrder(1))
			If D4V->(MSSeek(FWxFilial("D4V") + cCarac)) .And. D4V->D4V_TPSEL == "1" // Tipo de Seleção : 1=Única / 2=Múltipla
				cRotina := ProcName(0)
				For nLineAtu := 1 To nTotLine
					if nLineAtu != nLine // Exclui a validação da própria linha
						If oSubModel:GetValue("D4X_CARAC", nLineAtu) == cCarac .And. !oSubModel:IsDeleted(nLineAtu) 
							lRet := .F.
							cProblema := I18n(STR0012, {cCarac}) // "A característica "+cCarac+" é de utilização única e já foi utilizada em outra linha."
							cSolucao  := STR0013 // "Selecione outra característica ou exclua a atual."
							Help('', 1, '', cRotina, cProblema, 1,,,,,,, {cSolucao})
							EXIT
						EndIf
					EndIf
				Next nLineAtu
			EndIf
		EndIf
		FWRestArea(aAreaD4V)
		FWRestArea(aArea)
		FWRestRows(aSaveRows)
	EndIf

Return lRet
