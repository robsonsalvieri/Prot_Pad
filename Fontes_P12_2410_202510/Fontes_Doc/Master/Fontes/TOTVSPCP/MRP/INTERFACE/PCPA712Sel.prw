#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PCPA712.CH"

#DEFINE IND_EMPTY '*' + CHR(13) + '*'

Static slMarkAll := .F.

// Estaticas da consulta de documento
Static _aCampos    := {}
Static _aDados     := {}
Static _lMultiEmp  := .F.
Static _lMultiplos := .F.

/*/{Protheus.doc} FiltroMultivalorado
Classe para construção de tela de filtro multivalorado
@author Marcelo Neumann
@since 31/07/2019
@version P12
/*/
CLASS FiltroMultivalorado FROM LongClassName

	DATA aFields         AS ARRAY
	DATA aFieldRet       AS ARRAY
	DATA aFilter         AS ARRAY
	DATA aSelected       AS ARRAY
	DATA aChave          AS ARRAY
	DATA aOrder          AS ARRAY
	DATA aViewBtn        AS ARRAY
	DATA cAlias          AS STRING
	DATA cModelName      AS STRING
	DATA cTitulo         AS STRING
	DATA lPermVazio      AS LOGICAL
	DATA lAlterouSelecao AS LOGICAL
	DATA nIndice         AS INTEGER
	DATA oModel          AS OBJECT
	DATA oPreSelected    AS OBJECT
	DATA oView           AS OBJECT

	METHOD New() CONSTRUCTOR
	METHOD AbreTela()
	METHOD ButtonOk()
	METHOD Destroy()
	METHOD GetSelected()
	METHOD SetPreSelected()
	METHOD montaChaveRegistro()
	METHOD selecaoAlterada()

ENDCLASS

/*/{Protheus.doc} New
Construtor da classe para Filtro Multivalorado
@author Marcelo Neumann
@since 31/07/2019
@version P12
@param 01 cAlias    , caracter, alias para busca dos registros
@param 02 aFields   , array   , array com os campos a serem exibidos na view
@param 03 aFieldRet , array   , array com os campos a serem retornados
@param 04 aFilter   , array   , array com os filtros a serem aplicados na consulta
@param 05 nIndice   , numérico, índice a ser utilizado na consulta do alias
@param 06 cModelName, caracter, nome para o modelo dos resultados
                                (necessário informar nomes diferentes caso um mesmo programa reutilize a classe)
@param 07 cTitulo   , caracter, título para a janela
@param 08 lPermVazio, lógico  , define se o filtro deve conter um elemento vazio
@param 09 aChave    , array   , array com os dados que devem ser concatenados para formar a chave do registro.
@param 10 aOrder    , array   , array com os campos para ordenação dos registros.
@param 11 aViewBtn  , array   , array com informações para adicionar botão na view.
@return   Self      , objeto  , classe FiltroMultivalorado
/*/
METHOD New(cAlias, aFields, aFieldRet, aFilter, nIndice, cModelName, cTitulo, lPermVazio, aChave, aOrder, aViewBtn) CLASS FiltroMultivalorado

	Default nIndice    := 1
	Default cModelName := "GRID_RESULTS"
	Default cTitulo    := STR0148 //"Consulta"
	Default aChave     := {}
	Default aOrder     := {}
	Default aViewBtn   := {}

	::oPreSelected    := JsonObject():New()
	::aSelected       := {}
	::aFields         := aClone(aFields)
	::aFieldRet       := aClone(aFieldRet)
	::aFilter         := aClone(aFilter)
	::aChave          := aClone(aChave)
	::aOrder          := aClone(aOrder)
	::aViewBtn        := aClone(aViewBtn)
	::cAlias          := cAlias
	::cModelName      := cModelName
	::cTitulo         := cTitulo
	::nIndice         := nIndice
	::oModel          := Nil
	::oView           := Nil
	::lPermVazio      := lPermVazio
	::lAlterouSelecao := .F.

Return Self

/*/{Protheus.doc} Destroy
Método para limpar da memória os objetos utilizados pela classe
@author Marcelo Neumann
@since 31/07/2019
@version P12
@return Nil
/*/
METHOD Destroy() CLASS FiltroMultivalorado

	If ::oModel <> Nil
		::oModel:DeActivate()
		::oModel:Destroy()
	EndIf

	If ::oView <> Nil
		::oView:DeActivate()
	EndIf

	aSize(::aFields  , 0)
	aSize(::aFieldRet, 0)
	aSize(::aFilter  , 0)
	aSize(::aSelected, 0)

	If ::oPreSelected <> Nil 
		FreeObj(::oPreSelected)
	EndIf
	If ::oModel <> Nil
		FreeObj(::oModel)
	EndIf
	If ::oView <> Nil
		FreeObj(::oView)
	EndIf

Return

/*/{Protheus.doc} AbreTela
Método para abrir a tela de consulta/filtro multivalorado
@author Marcelo Neumann
@since 31/07/2019
@version P12
@return lConfirm, lógico, indica se a tela foi Confirmada ou Cancelada
/*/
METHOD AbreTela() CLASS FiltroMultivalorado

	Local aArea     := GetArea()
	Local aButtons  := { {.F.,Nil    },{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0146},; //"Confirmar"
	                     {.T.,STR0147},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil    } } //"Cancelar"
	Local lConfirm  := .T.
	Local oViewExec := FWViewExec():New()

	If ::oModel == Nil
		::oModel := ModelDef(::Self)
	EndIf

	(::cAlias)->(dbSetOrder(1))
	(::cAlias)->(MsSeek(xFilial(::cAlias)))

	::oModel:SetOperation(MODEL_OPERATION_UPDATE)
	::oModel:Activate()

	If ::oView == Nil
		::oView := ViewDef(::Self)
		::oView:SetOperation(MODEL_OPERATION_VIEW)
	EndIf

	//Variável de controle da opção de Marcar Todos
	slMarkAll := .F.

	oViewExec:setModel(::oModel)
	oViewExec:setView(::oView)
	oViewExec:setTitle(::cTitulo)
	oViewExec:setOperation(MODEL_OPERATION_VIEW)
	oViewExec:setReduction(65)
	oViewExec:setButtons(aButtons)
	oViewExec:SetCloseOnOk({|| ::ButtonOk()})
	oViewExec:setCancel({|| SetModify(::oView,.F.)})
	oViewExec:openView(.F.)

	If oViewExec:getButtonPress() == VIEW_BUTTON_OK
		lConfirm := .T.
	Else
		lConfirm := .F.
	Endif

	RestArea(aArea)

Return lConfirm

/*/{Protheus.doc} ModelDef
Definição do Modelo
@author Marcelo Neumann
@since 31/07/2019
@version P12
@param 01 oSelf , objeto, objeto referente à classe
@return   oModel, objeto, modelo definido
/*/
Static Function ModelDef(oSelf)

	Local oModel    := MPFormModel():New('PCPA712Sel')
	Local oStruCab  := FWFormModelStruct():New()
	Local oStruGrid := Nil
	Local oEvent    := Nil

	If oSelf == Nil
		Return Nil
	EndIf
	
	oStruGrid := FWFormStruct(1, oSelf:cAlias, {|cCampo| "|" + AllTrim(cCampo) + "|" $ "|" + ArrTokStr(oSelf:aFields, "|", 0) + "|"}, .F.)
	
	//Altera as estruturas dos modelos
 	AltStruMod(@oStruCab, @oStruGrid, oSelf)

	//FLD_INVISIVEL - Modelo "invisível"
	oModel:addFields('FLD_INVISIVEL', /*cOwner*/, oStruCab, , , {|| LoadMdlFld()})
	oModel:GetModel("FLD_INVISIVEL"):SetDescription(STR0148) //"Consulta"
	oModel:GetModel("FLD_INVISIVEL"):SetOnlyQuery(.T.)

	//::cModelName - Grid de resultados (o nome deve ser atribuido através da propriedade ::cModelName)
	oModel:AddGrid(oSelf:cModelName, "FLD_INVISIVEL", oStruGrid, , , , ,{|oGridModel| LoadMdlGrd(oGridModel, oSelf)})
	oModel:GetModel(oSelf:cModelName):SetDescription(STR0150) //"Resultados"
	oModel:GetModel(oSelf:cModelName):SetOnlyQuery(.T.)
	oModel:GetModel(oSelf:cModelName):SetOptional(.T.)
	oModel:GetModel(oSelf:cModelName):SetNoDeleteLine(.T.)
	oModel:GetModel(oSelf:cModelName):SetNoInsertLine(.T.)

	oModel:SetDescription(STR0148) //"Consulta"
	oModel:SetPrimaryKey({})

	oEvent := PCPA712SelEVDEF():New(oSelf:cModelName)
	oModel:InstallEvent("PCPA712SelEVDEF", /*cOwner*/, oEvent)

Return oModel

/*/{Protheus.doc} ViewDef
Definição da View
@author Marcelo Neumann
@since 31/07/2019
@version P12
@param 01 oSelf, objeto, objeto referente à classe
@return   oView, objeto, view definida
/*/
Static Function ViewDef(oSelf)

	Local nIndex    := 0
	Local nTotBtn   := 0
	Local oStruGrid := FWFormStruct(2, oSelf:cAlias, {|cCampo| "|" + AllTrim(cCampo) + "|" $ "|" + ArrTokStr(oSelf:aFields, "|", 0) + "|"}, .F.)
	Local oView     := FWFormView():New()

	//Altera os campos da estrutura para a view
	AltStrView(@oStruGrid, oSelf)

	//Definições da View
	oView:SetModel(oSelf:oModel)

	//V_GRID_RESULTS - View da Grid com resultado da pesquisa
	oView:AddGrid("V_GRID_RESULTS", oStruGrid, oSelf:cModelName)

	//Relaciona a SubView com o Box
	oView:CreateHorizontalBox("BOX_GRID", 100)
	oView:SetOwnerView("V_GRID_RESULTS", 'BOX_GRID')

	//Função chamada após ativar a View
	oView:SetAfterViewActivate({|oView| AfterView(oView)})

	//Habilita os botões padrões de filtro e pesquisa
	oView:SetViewProperty("V_GRID_RESULTS", "GRIDFILTER", {.T.})
	oView:SetViewProperty("V_GRID_RESULTS", "GRIDSEEK", {.T.})

	//Seta ação após o checkbox
	oView:SetFieldAction("LSELECT", { |oView| SetModify(oView, .F.) })

	nTotBtn := Len(oSelf:aViewBtn)
	If nTotBtn > 0
		For nIndex := 1 To nTotBtn
			oView:addUserButton(oSelf:aViewBtn[nIndex][1], "", oSelf:aViewBtn[nIndex][2], /*cToolTip*/, /*nShortCut*/, /*aOptions*/, .T.)
		Next
	EndIf

	//Seta para não exibir a mensagem de Modificação
	oView:showUpdateMsg(.F.)

Return oView

/*/{Protheus.doc} LoadMdlFld
Carga do modelo mestre (invisível)
@author Marcelo Neumann
@since 31/07/2019
@version P12
@return aLoad, array, array de load do modelo preenchido
/*/
Static Function LoadMdlFld()

	Local aLoad := {}

	aAdd(aLoad, {"A"}) //dados
	aAdd(aLoad, 1    ) //recno

Return aLoad

/*/{Protheus.doc} ViewDef
Carga do modelo detalhe (consulta)
@author Marcelo Neumann
@since 31/07/2019
@version P12
@param 01 oGridModel, objeto, modelo que deve ser carregado
@param 02 oSelf     , objeto, objeto referente à classe
@return   aLoad     , array , array de load do modelo preenchido
/*/
Static Function LoadMdlGrd(oGridModel, oSelf)

	Local aFields    := {}
	Local aLoad      := {}
	Local aRegistro  := {}
	Local aStruct    := oGridModel:oFormModelStruct
	Local aStrFields := aStruct:aFields
	Local cNextAlias := GetNextAlias()
	Local cQuery     := ""
	Local cOrderBy   := ArrTokStr(oSelf:aOrder, ",")
	Local lSelect    := .F.
	Local lUsaChave  := Len(oSelf:aChave) > 0
	Local nInd       := 1
	Local nLenAux    := 0
	Local nLenFields := 0

	//Busca os campos reais da estrutura do modelo
	nLenAux := Len(aStrFields)
	For nInd := 1 To nLenAux
		If !aStruct:GetProperty(aStrFields[nInd][3], MODEL_FIELD_VIRTUAL)
			//Adiciona o nome do campo e o tipo
			aAdd(aFields, {aStrFields[nInd][3], aStrFields[nInd][4]})
		EndIf
	Next nInd

	cQuery := "SELECT DISTINCT 1"

	//Preenche o SELECT com os campos reais do modelo
	nLenFields := Len(aFields)
	For nInd := 1 To nLenFields
		cQuery += ", " + aFields[nInd][1]
	Next nInd

	cQuery +=  " FROM " + RetSqlName(oSelf:cAlias)
	cQuery += " WHERE D_E_L_E_T_ = ' '"

	//Acrescenta os filtros definidos na classe
	nLenAux := Len(oSelf:aFilter)
	For nInd := 1 To nLenAux
		cQuery += " AND (" + oSelf:aFilter[nInd] + ")"
	Next nInd

	If !Empty(oSelf:aOrder)
		cQuery += " ORDER BY " + cOrderBy
	EndIf

	//Inclui uma linha de código em branco quando necessário
	If oSelf:lPermVazio
		If aFields[1][1] == oSelf:aFieldRet[1]
			If oSelf:oPreSelected[IND_EMPTY] == Nil
				lSelect := .F.
			Else
				lSelect := .T.
				oSelf:oPreSelected[IND_EMPTY][1] := Len(aLoad) + 1
				aAdd(oSelf:oPreSelected[IND_EMPTY][2], Len(aLoad) + 1)
			EndIf
		EndIf
		aAdd(aLoad, {0, {" ", STR0182, lSelect} }) //"Grupo não informado"
	EndIf

	//Realiza a consulta dos registros
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cNextAlias,.T.,.T.)

	//Percorre os registros encontrados, atualizando o modelo
	While !(cNextAlias)->(Eof())
		aSize(aRegistro,0)
		lSelect := .F.

		//Preenche os campos do modelo
		For nInd := 1 To nLenFields
			//Campo DATE precisa ser convertido
			If aFields[nInd][2] == "D"
				aAdd(aRegistro, SToD((cNextAlias)->&(aFields[nInd][1])))
			Else
				aAdd(aRegistro, (cNextAlias)->&(aFields[nInd][1]))
			EndIf

			//Verifica se o registro já deve vir selecionado
			If aFields[nInd][1] == oSelf:aFieldRet[1]
				If oSelf:oPreSelected[AllTrim((cNextAlias)->&(aFields[nInd][1]))] == Nil
					lSelect := .F.
				Else
					lSelect := .T.
					oSelf:oPreSelected[AllTrim((cNextAlias)->&(aFields[nInd][1]))][1] := Len(aLoad) + 1
					aAdd(oSelf:oPreSelected[AllTrim((cNextAlias)->&(aFields[nInd][1]))][2], Len(aLoad) + 1)
				EndIf
			EndIf
		Next nInd

		//Se utiliza chave no registro, verifica no JSON de pré-seleção utilizando a chave do registro
		If lUsaChave .And. !lSelect
			cChave := oSelf:montaChaveRegistro(Nil, Nil, cNextAlias, .F.)
			If oSelf:oPreSelected[AllTrim(cChave)] == Nil
				lSelect := .F.
			Else
				lSelect := .T.
				oSelf:oPreSelected[AllTrim(cChave)][1] := Len(aLoad) + 1
				aAdd(oSelf:oPreSelected[AllTrim(cChave)][2], Len(aLoad) + 1)
			EndIf
		EndIf

		aAdd(aRegistro, lSelect)

		aAdd(aLoad, {0, aClone(aRegistro)})

		(cNextAlias)->(DbSkip())
	EndDo
	(cNextAlias)->(dbCloseArea())

Return aLoad

/*/{Protheus.doc} AltStruMod
Edita os campos da estrutura do Model
@author Marcelo Neumann
@since 31/07/2019
@version P12
@param 01 oStruCab , object, estrutura do modelo FLD_INVISIVEL
@param 02 oStruGrid, object, estrutura do modelo GRID_RESULTS
@param 03 oSelf    , object, objeto referente à classe
@return Nil
/*/
Static Function AltStruMod(oStruCab, oStruGrid, oSelf)

	//Adiciona campo
	oStruCab:AddField(STR0148, STR0148, "ARQ", "C", 1, 0, , , {}, .T., , .F., .F., .F., , ) //"Consulta"

	//Adiciona o checkbox para selecionar o registro
	oStruGrid:AddField(STR0149  ,; // [01]  C   Titulo do campo  - "Selecionado?"
                       STR0149  ,; // [02]  C   ToolTip do campo - "Selecionado?"
                       "LSELECT",; // [03]  C   Id do Field
                       "L"      ,; // [04]  C   Tipo do campo
                       1        ,; // [05]  N   Tamanho do campo
                       0        ,; // [06]  N   Decimal do campo
                       Nil      ,; // [07]  B   Code-block de validação do campo
                       {|| !oSelf:oModel:GetModel(oSelf:cModelName):IsEmpty()}      ,; // [07]  B   Code-block de validação When do campo
                       NIL      ,; // [09]  A   Lista de valores permitido do campo
                       .F.      ,; // [10]  L   Indica se o campo tem preenchimento obrigatório
                       NIL      ,; // [11]  B   Code-block de inicializacao do campo
                       .F.      ,; // [12]  L   Indica se trata-se de um campo chave
                       .F.      ,; // [13]  L   Indica se o campo não pode receber valor em uma operação de update
                       .T.      )  // [14]  L   Indica se o campo é virtual

	oStruGrid:SetProperty(oStruGrid:aFields[1][3], MODEL_FIELD_OBRIGAT, .F.)

Return Nil

/*/{Protheus.doc} AltStrView
Edita os campos da estrutura da View
@author Marcelo Neumann
@since 31/07/2019
@version P12
@param 01 oStrDetail, object, estrutura da View V_GRID_RESULTS
@return Nil
/*/
Static Function AltStrView(oStruGrid, oSelf)

	Local nInd    := 1
	Local nLength := Len(oSelf:aFields)

	//Reornena os campos de acordo com o que foi setado na classe e seta para não editável
	For nInd := 1 To nLength
		If oStruGrid:HasField(oSelf:aFields[nInd])
			oStruGrid:SetProperty(oSelf:aFields[nInd], MVC_VIEW_CANCHANGE, .F.)
			oStruGrid:SetProperty(oSelf:aFields[nInd], MVC_VIEW_ORDEM    , cValToChar(nInd+1))
		EndIf
	Next nInd

	oStruGrid:AddField("LSELECT"                    ,; // [01]  C   Nome do Campo
						"01"                        ,; // [02]  C   Ordem
						""                          ,; // [03]  C   Titulo do campo
						""                          ,; // [04]  C   Descricao do campo
						NIL                         ,; // [05]  A   Array com Help
						"L"                         ,; // [06]  C   Tipo do campo
						NIL                         ,; // [07]  C   Picture
						NIL                         ,; // [08]  B   Bloco de Picture Var
						NIL                         ,; // [09]  C   Consulta F3
						.T.                         ,; // [10]  L   Indica se o campo é alteravel
						NIL                         ,; // [11]  C   Pasta do campo
						NIL                         ,; // [12]  C   Agrupamento do campo
						NIL                         ,; // [13]  A   Lista de valores permitido do campo (Combo)
						NIL                         ,; // [14]  N   Tamanho maximo da maior opção do combo
						NIL                         ,; // [15]  C   Inicializador de Browse
						.T.                         ,; // [16]  L   Indica se o campo é virtual
						NIL                         ,; // [17]  C   Picture Variavel
						NIL                         )  // [18]  L   Indica pulo de linha após o campo

Return Nil

/*/{Protheus.doc} AfterView
Função executada após ativar a view
@author Marcelo Neumann
@since 31/07/2019
@version P12
@param 01 oView, object, objeto da View
@return Nil
/*/
Static Function AfterView(oView)

	//Seta funcionalidade de marcar/desmarcar todos clicando no cabeçalho
	oView:GetSubView("V_GRID_RESULTS"):oBrowse:aColumns[1]:bHeaderClick := {|| MarcaTodos(oView) }

	//Seta o modelo como não alterado
	SetModify(oView, .F.)

Return Nil

/*/{Protheus.doc} MarcaTodos
Função executada ao clicar no cabeçalho do CheckBox
@author Marcelo Neumann
@since 31/07/2019
@version P12
@param 01 oView, object, objeto da View
@return Nil
/*/
Static Function MarcaTodos(oView)

	Local oViewGrid := oView:GetSubView("V_GRID_RESULTS")
	Local oMdlGrid  := oViewGrid:GetModel()
	Local aFilLines := oViewGrid:GetFilLines()
	Local nLinAtua  := oMdlGrid:GetLine()
	Local nInd      := 1
	Local nLength   := Len(aFilLines)

	If !oMdlGrid:IsEmpty()

		slMarkAll := !slMarkAll

		//Percorre a grid marcando/descmarcando todos os registros (considerando o filtro)
		For nInd := 1 to nLength
			oMdlGrid:GoLine(aFilLines[nInd])
			oMdlGrid:LoadValue("LSELECT", slMarkAll)
		Next nInd

		//Atualiza a Grid
		oMdlGrid:GoLine(nLinAtua)

		//Tratamento para caso os registros estejam filtrados
		If Len(aFilLines) == oMdlGrid:Length()
			oViewGrid:DeActivate(.T.)
			oViewGrid:Activate()
		Else
			oViewGrid:Refresh()
		EndIf
	EndIf

Return Nil

/*/{Protheus.doc} ButtonOk
Método chamado ao pressionar o botão "Confirmar" da tela
@author Marcelo Neumann
@since 31/07/2019
@version P12
@return lRet, Logical, retorna true para permitir fechar a tela
/*/
METHOD ButtonOk() CLASS FiltroMultivalorado

	Local aLinesChg := {}
	Local aRetLine  := {}
	Local aNames    := {}
	Local cChave    := ""
	Local lUsaChave := Len(::aChave) > 0
	Local nIndFlds  := 1
	Local nIndLines := 1
	Local nIndAux   := 0
	Local nLenFld   := 0
	Local nLenLin   := 0
	Local nLenAux   := 0
	Local oModel    := ::oView:GetModel()

	If Len(oModel:GetModel(::cModelName):GetLinesChanged()) > 0
		Self:lAlterouSelecao := .T.
	Else
		Self:lAlterouSelecao := .F.
	EndIf

	//Se algum registro veio pré-selecionado, seta a linha como modificada
	If ::oPreSelected <> NIL
		aNames  := ::oPreSelected:GetNames()
		nLenLin := Len(aNames)
		For nIndLines := 1 To nLenLin
			If ::oPreSelected[aNames[nIndLines]] <> Nil .And. ::oPreSelected[aNames[nIndLines]][1] > 0
				nLenAux := Len(::oPreSelected[aNames[nIndLines]][2])
				For nIndAux := 1 To nLenAux
					::oModel:GetModel(::cModelName):SetLineModify(::oPreSelected[aNames[nIndLines]][2][nIndAux])
				Next nIndAux
			EndIf
		Next nIndLines
	EndIf

	aLinesChg := oModel:GetModel(::cModelName):GetLinesChanged()
	//Verifica se foi clicado em algum checkbox
	If Len(aLinesChg) > 0
		aSize(::aSelected, 0)
	EndIf

	//Percorre as linhas que tiveram alteração
	nLenLin := Len(aLinesChg)
	For nIndLines := 1 To nLenLin
		//Se o registro ficou marcado, preenche o array de retorno (aSelected)
		If oModel:GetModel(::cModelName):GetValue("LSELECT", aLinesChg[nIndLines])
			aSize(aRetLine, 0)

			//Preenche os campos que serão retornados (definidos na classe)
			nLenFld := Len(::aFieldRet)
			For nIndFlds := 1 To nLenFld
				aAdd(aRetLine, { ::aFieldRet[nIndFlds], ;
				                 oModel:GetModel(::cModelName):GetValue(::aFieldRet[nIndFlds], aLinesChg[nIndLines]) })
			Next nIndFlds

			//Se selecionou o registro em branco, transforma no caracter especial (Json não permite chave em branco)
			If aRetLine[1][2] == " "
			 	aRetLine[1][2] := IND_EMPTY
			EndIf

			If lUsaChave
				cChave := Self:montaChaveRegistro(oModel:GetModel(::cModelName), aLinesChg[nIndLines], Nil, .T.)
				aAdd(aRetLine, {"CHAVE", cChave})
			EndIf

			aAdd(::aSelected, aClone(aRetLine))

		EndIf
	Next nIndLines

	SetModify(::oView,.T.)
	aSize(aNames, 0)
Return .T.

/*/{Protheus.doc} GetSelected
Método para recuperar os registros que foram selecionados na consulta
@author Marcelo Neumann
@since 31/07/2019
@version P12
@return aSelected, array, array com os registros que foram selecionados
/*/
METHOD GetSelected() CLASS FiltroMultivalorado
Return ::aSelected

/*/{Protheus.doc} SetPreSelected
Seta os registros que deverão vir pré-selecionados ao abrir a tela
@author Marcelo Neumann
@since 31/07/2019
@version P12
@param 01 aPreSel, array, registros que devem vir pré-selecionados na consulta
                          (considerar como chave o campo informado na primeira posição da propriedade ::aFieldRet)
/*/
METHOD SetPreSelected(aPreSel) CLASS FiltroMultivalorado

	Local nIndSelect := 1
	Local nLenPreSel := Len(aPreSel)

	//Inicializa a propriedade que grava os pré-selecionados
	If ::oPreSelected <> Nil
		FreeObj(::oPreSelected)
	EndIf
	::oPreSelected := JsonObject():New()

	//Grava a chave dos registros pré-selecionados
	For nIndSelect := 1 To nLenPreSel
		If Empty(aPreSel[nIndSelect])
			::oPreSelected[IND_EMPTY] := {0,{}}
		Else
			::oPreSelected[AllTrim(aPreSel[nIndSelect])] := {0,{}}
		EndIf

	Next nIndSelect

Return Nil

/*/{Protheus.doc} montaChaveRegistro
Monta a chave do registro de acordo com o array aChave.

@author lucas.franca
@since 04/01/2021
@version P12
@param 01 oModel   , Object   , Objeto do modelo de dados da tela de filtro multivalorado
@param 02 nLinha   , Numeric  , Linha da grid do modelo de dados que deve ser utilizada para obter os valores
@param 03 cAlias   , Character, Alias da query que traz os dados da tabela
@param 04 lUsaModel, Logic    , Indica se obtém os valores de oModel+nLinha ou de cAlias.
@return cChave, Character, Código da chave do registro.
/*/
METHOD montaChaveRegistro(oModel, nLinha, cAlias, lUsaModel) CLASS FiltroMultivalorado
	Local cChave    := ""
	Local nIndChave := 0
	Local nTotChave := Len(Self:aChave)

	For nIndChave := 1 To nTotChave
		If nIndChave > 1
			cChave += ";"
		EndIf
		If lUsaModel
			cChave += oModel:GetValue(::aChave[nIndChave], nLinha)
		Else
			cChave += &(cAlias+'->'+::aChave[nIndChave])
		EndIf
	Next nIndChave

Return cChave

/*/{Protheus.doc} selecaoAlterada
Retorna indicador se houve alguma modificação nos registros selecionados.

@author lucas.franca
@since 07/01/2021
@version P12
@return lAlterouSelecao, Logic, Indicador de modificação da seleção de registros
/*/
METHOD selecaoAlterada() CLASS FiltroMultivalorado
Return Self:lAlterouSelecao

/*/{Protheus.doc} SetModify
Seta o indicador de modificado do modelo
@author Marcelo Neumann
@since 31/07/2019
@version P12
@param 01 oView, object, objeto da View
@param 02 lMod , logic , indica se o modelo será setado para modificado ou não
@return .T.
/*/
Static Function SetModify(oView, lMod)

	Local oModel := oView:GetModel()

	oModel:lModify := lMod
	oView:lModify  := lMod

Return .T.

/*/{Protheus.doc} PCPA712SelEVDEF
Classe de eventos do modelo de seleção da tela de filtros do pcpa712

@author lucas.franca
@since 12/12/2022
@version P12
/*/
CLASS PCPA712SelEVDEF FROM FWModelEvent

	DATA cModelName AS CHARACTER

	METHOD New(cModelName) CONSTRUCTOR
	METHOD ModelPosVld()
	
ENDCLASS

/*/{Protheus.doc} New
Método construtor da classe.

@author lucas.franca
@since 12/12/2022
@version P12
@param cModelName, Caracter, Nome do modelo
@return Nil
/*/
METHOD New(cModelName) CLASS PCPA712SelEVDEF
	Self:cModelName := cModelName
Return Nil

/*/{Protheus.doc} ModelPosVld
Método para validação do modelo

@author lucas.franca
@since 12/12/2022
@version P12

@param 01 oModel  , Object  , Modelo de dados
@param 02 cModelId, Caracter, ID do modelo de dados
@return lRet, Logic, Indica se o modelo de dados está válido
/*/
METHOD ModelPosVld(oModel, cModelId) CLASS PCPA712SelEVDEF
	Local lRet      := .T.
	Local nMarcados := 0
	Local nIndex    := 0
	Local nTotal    := 0
	Local oMdlGrid  := oModel:GetModel(::cModelName)

	nTotal := oMdlGrid:Length()
	For nIndex := 1 To nTotal 
		If oMdlGrid:GetValue("LSELECT", nIndex)
			nMarcados++
		EndIf
	Next nIndex 

	If nMarcados == nTotal
		//Não permite marcar todos, pois não existe necessidade e afeta a performance do MRP.
		lRet := .F.
		Help(, , "HELP",, STR0345; //"Seleção não permitida."
		     , 1, 0,,,,,,{STR0346}) //"Não é permitido selecionar todos os dados do filtro. Caso deseje processar todos os dados, não marque nenhum filtro."
	EndIf

Return lRet

/*/{Protheus.doc} P712ConDoc
Função responsavel por exibir a tela com as informações de onde um documento do mrp é utilizado.
@type  Function
@author Lucas Fagundes
@since 10/01/2023
@version P12
@param 01 aConsulta , Array , Array com as informações dos documentos a consultar.
@param 02 lMultiplos, Logico, Indica se a consulta é para multiplos documentos.
@param 03 lMultiEmp , Logico, Indica se é multi-empresa.
@return Nil
/*/
Function P712ConDoc(aConsulta, lMultiplos, lMultiEmp)
	Local aButtons  := { {.F.,Nil },{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T., STR0326},; // "Fechar"
	                     {.F.,Nil },{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F., Nil     } } 
	Local cTitle    := ""
	Local oModel    := Nil
	Local oView     := Nil
	Local oViewExec := FWViewExec():New()

	iniStatic(aConsulta, lMultiplos, lMultiEmp)
	oModel := mdlConDoc()
	oView  := viewConDoc(oModel)

	oModel:SetOperation(MODEL_OPERATION_VIEW)
	oModel:Activate()

	oView:SetOperation(MODEL_OPERATION_VIEW)

	If _lMultiplos
		cTitle := STR0368 // "Demandas dos documentos selecionados"
	Else
		cTitle := I18N(STR0348, {Rtrim(_aDados[1][1])}) // "Demandas do documento #1[DOCUMENTO]#"
		
		If !Empty(_aDados[1][2])
			cTitle += " " + I18N(STR0351, {Rtrim(_aDados[1][2])}) // "na Filial #1[FILIAL]#"
		EndIf
	EndIf

	oViewExec:setModel(oModel)
	oViewExec:setView(oView)
	oViewExec:setTitle(cTitle)
	oViewExec:setOperation(MODEL_OPERATION_VIEW)
	oViewExec:setReduction(55)
	oViewExec:setButtons(aButtons)
	
	oViewExec:openView()

Return Nil

/*/{Protheus.doc} mdlConDoc
Função responsavel pela definição do modelo de consulta de documentos.
@type  Static Function
@author Lucas Fagundes
@since 10/01/2023
@version P12
@return oModel, Object, Objeto modelo do MVC.
/*/
Static Function mdlConDoc()
	Local cCampos   := "|" + ArrTokStr(_aCampos, "|") + "|"
	Local oModel    := MPFormModel():New("PCPA712Doc")
	Local oStruCab  := FWFormModelStruct():New()
	Local oStruGrid := FWFormStruct(1, "SVR", {|cCampo| "|" + AllTrim(cCampo) + "|" $ cCampos })

	//Cria campo para o modelo invisível
	oStruCab:addField("", "", "ARQ", "C", 1, 0, , , {}, .T., , .F., .F., .F., , )

	// Cria campo para descrição do produto
	oStruGrid:AddField(STR0347        ,; // [01]  C  Titulo do campo // "Descrição"
	                   STR0347        ,; // [02]  C  ToolTip do campo // "Descrição"
	                   "B1_DESC"      ,; // [03]  C  Id do Field
	                   "C"            ,; // [04]  C  Tipo do campo
	                   GetSx3Cache("B1_DESC", "X3_TAMANHO"),; // [05]  N  Tamanho do campo
	                   0              ,; // [06]  N  Decimal do campo
	                   NIL            ,; // [07]  B  Code-block de validação do campo
	                   NIL            ,; // [08]  B  Code-block de validação When do campo
	                   {}             ,; // [09]  A  Lista de valores permitido do campo
	                   .F.            ,; // [10]  L  Indica se o campo tem preenchimento obrigatório
	                   Nil            ,; // [11]  B  Code-block de inicializacao do campo
	                   NIL            ,; // [12]  L  Indica se trata-se de um campo chave
	                   NIL            ,; // [13]  L  Indica se o campo pode receber valor em uma operação de update.
	                   .T.)              // [14]  L  Indica se o campo é virtual

	//MDL_INVI - Modelo "invisível"
	oModel:addFields('MDL_INVI', /*cOwner*/, oStruCab, , , {|| loadMdlFld()})
	oModel:getModel("MDL_INVI"):setDescription(STR0148) // "Consulta"
	oModel:getModel("MDL_INVI"):setOnlyQuery(.T.)

	oModel:addGrid("GRID", "MDL_INVI",oStruGrid, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bLinePost*/, {|oGridModel| loadData(oGridModel)})
	oModel:getModel("GRID"):setDescription(STR0150) // "Resultados"
	oModel:getModel("GRID"):setOnlyQuery(.T.)
	oModel:getModel("GRID"):setNoInsertLine(.T.)
	oModel:getModel("GRID"):setNoDeleteLine(.T.)

	oModel:setDescription(STR0349) // "Consultar Demandas"
	oModel:setPrimaryKey({})

Return oModel

/*/{Protheus.doc} viewConDoc
Função responsavel pela definição da view de consulta de documentos.
@type  Static Function
@author Lucas Fagundes
@since 10/01/2023
@version P12
@param 01 oModel, Object, Objeto model que será atribuido a view.
@return oView, Object, Objeto view do MVC.
/*/
Static Function viewConDoc(oModel)
	Local cCampos   := "|" + ArrTokStr(_aCampos, "|") + "|"
	Local oStruGrid := FWFormStruct(2, "SVR", {|cCampo| "|" + AllTrim(cCampo) + "|" $ cCampos }, /*lViewUsado*/, /*lVirtual*/, _lMultiplos .And. _lMultiEmp)
	Local oView     := FWFormView():New()

	oStruGrid:setProperty("VR_CODIGO", MVC_VIEW_TITULO, STR0350) // "Demanda"
	
	If _lMultiplos
		oStruGrid:setProperty("VR_DOC", MVC_VIEW_ORDEM, Iif(_lMultiEmp, "02", "01"))
	EndIf

	oStruGrid:AddField("B1_DESC"               ,; // [01]  C   Nome do Campo
	                  soma1(oStruGrid:getProperty("VR_PROD", MVC_VIEW_ORDEM)),; // [02]  C   Ordem
	                  STR0347                  ,; // [03]  C   Titulo do campo // "Descrição"
	                  STR0347                  ,; // [04]  C   Descricao do campo // "Descrição"
	                  NIL                      ,; // [05]  A   Array com Help
	                  "C"                      ,; // [06]  C   Tipo do campo
	                  NIL                      ,; // [07]  C   Picture
	                  NIL                      ,; // [08]  B   Bloco de Picture Var
	                  NIL                      ,; // [09]  C   Consulta F3
	                  .F.                      ,; // [10]  L   Indica se o campo é alteravel
	                  NIL                      ,; // [11]  C   Pasta do campo
	                  NIL                      ,; // [12]  C   Agrupamento do campo
	                  NIL                      ,; // [13]  A   Lista de valores permitido do campo (Combo)
	                  NIL                      ,; // [14]  N   Tamanho maximo da maior opção do combo
	                  NIL                      ,; // [15]  C   Inicializador de Browse
	                  .T.                      ,; // [16]  L   Indica se o campo é virtual
	                  NIL                      ,; // [17]  C   Picture Variavel
	                  NIL                      )  // [18]  L   Indica pulo de linha após o campo

	oView:setModel(oModel)

	oView:addGrid("VIEW_GRID", oStruGrid, "GRID")

	oView:createHorizontalBox("BOX_GRID", 100)

	oView:setOwnerView("VIEW_GRID", "BOX_GRID")

Return oView

/*/{Protheus.doc} loadData
Carrega a grid com os dados de um documento.

@type  Static Function
@author Lucas Fagundes
@since 10/01/2023
@version P12
@param oModel, Object, Objeto que está sendo carregado.
@return aLoad, Array, Array com os dados do modelo.
/*/
Static Function loadData(oModel)
	Local aDados     := {}
	Local aLoad      := {}
	Local cAlias     := GetNextAlias()
	Local cDocumento := ""
	Local cFilAux    := ""
	Local cQuery     := ""
	Local nIndCon    := 0
	Local nIndex     := 0
	Local nTamCampos := Len(_aCampos)
	Local nTotCon    := 0
	Local oStmtQry   := FWPreparedStatement():New()

	cQuery += " SELECT " + ArrTokStr(_aCampos, ",")
	cQuery +=   " FROM " + RetSqlName("SVR") + " SVR "
	cQuery +=  " INNER JOIN " + RetSqlName("SB1") + " SB1 "
	cQuery +=     " ON SB1.B1_COD = SVR.VR_PROD "
	cQuery +=    " AND SB1.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
	cQuery +=  " WHERE SVR.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND SVR.VR_DOC = ? "
	cQuery += " AND SVR.VR_FILIAL = ? "

	oStmtQry:setQuery(cQuery)

	nTotCon := Iif(_lMultiplos, Len(_aDados), 1)
	For nIndCon := 1 To nTotCon
		cDocumento := _aDados[nIndCon][1]
		cFilAux    := _aDados[nIndCon][2]

		If Empty(cFilAux)
			cFilAux := xFilial("SVR")
		EndIf

		oStmtQry:setString(1, cDocumento)
		oStmtQry:setString(2, cFilAux)

		cQuery := oStmtQry:getFixQuery()

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
		TCSetField(cAlias, "VR_DATA", "D")

		While (cAlias)->(!Eof())
			For nIndex := 1 To nTamCampos
				aAdd(aDados, &("(cAlias)->" + _aCampos[nIndex]))
			Next

			aAdd(aLoad, {0, aClone(aDados)})
			
			aSize(aDados, 0)
			
			(cAlias)->(dbSkip())
		End
		(cAlias)->(dbCloseArea())
	Next

Return aLoad

/*/{Protheus.doc} iniStatic
Inicia as variaveis estaticas para verificação de documento.
@type  Static Function
@author Lucas Fagundes
@since 10/01/2023
@version P12
@param 01 aConsulta , Array , Array com as informações dos documentos a consultar.
@param 02 lMultiplos, Logico, Indica se a consulta é para multiplos documentos.
@param 03 lMultiEmp , Logico, Indica se é multi-empresa.
@return Nil
/*/
Static Function iniStatic(aConsulta, lMultiplos, lMultiEmp)

	_aDados     := aConsulta
	_lMultiplos := lMultiplos
	_lMultiEmp  := lMultiEmp
	_aCampos    := {}

	If lMultiplos .And. lMultiEmp
		aAdd(_aCampos, "VR_FILIAL")
	EndIf

	aAdd(_aCampos, "VR_CODIGO")
	aAdd(_aCampos, "VR_DATA"  )
	aAdd(_aCampos, "VR_TIPO"  )
	aAdd(_aCampos, "VR_PROD"  )
	aAdd(_aCampos, "VR_QUANT" )
	
	If lMultiplos
		aAdd(_aCampos, "VR_DOC")
	EndIf

	aAdd(_aCampos, "VR_OPC" )
	aAdd(_aCampos, "B1_DESC")

Return Nil
