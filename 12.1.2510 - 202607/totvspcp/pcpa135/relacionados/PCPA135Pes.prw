#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEDITPANEL.CH"
#INCLUDE "PCPA135.CH"

Static slRefzPesq := .T.

/*/{Protheus.doc} PCPA135EVPES
Eventos de pesquisa da manutenção de estruturas

@author lucas.franca
@since 19/03/2019
@version P12.1.25
/*/
CLASS PCPA135EVPES FROM FwModelEvent
	METHOD New()
	METHOD GridLinePreVld()
	METHOD GridLinePosVld()
ENDCLASS

/*/{Protheus.doc} New
Método construtor da classe.

@author lucas.franca
@since 19/03/2019
@version P12.1.25
/*/
METHOD New() CLASS PCPA135EVPES
Return Nil

/*/{Protheus.doc} GridLinePreVld
Pré-validação dos modelos

@author lucas.franca
@since 19/03/2019
@version P12.1.25

@param oSubModel	- Modelo de dados
@param cModelId		- ID do modelo de dados
@param nLine		- Linha do grid
@param cAction		- Ação que está sendo realizada no grid, podendo ser: ADDLINE, UNDELETE, DELETE, SETVALUE, CANSETVALUE, ISENABLE
@param cId			- Nome do campo
@param xValue		- Novo valor do campo
@param xCurrentValue- Valor atual do campo
@return lRet		- Indica se a linha está válida
/*/
METHOD GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) CLASS PCPA135EVPES

	If cModelID == "GRID_DETAIL"
		If (cAction == "DELETE"   .Or. ;
		    cAction == "UNDELETE" .Or. ;
		   (cAction == "SETVALUE" .And. cId == "GG_TRT")) .And. ;
		   !IsInCallStack("P135TreeCh")
			slRefzPesq := .T.
		EndIf
	EndIf

Return .T.

/*/{Protheus.doc} GridLinePosVld
Valida linha da grid principal da operação preenchida
@author Lucas Konrad França
@since 20/03/2019
@version 1.0
@param oSubModel, object    , modelo de dados
@param cModelId	, characters, ID do modelo de dados
@param nLine    , numeric   , linha do grid
@return lOK, logical, indica se a linha está válida
/*/
METHOD GridLinePosVld(oSubModel, cModelId, nLine) CLASS PCPA135EVPES
	If cModelId == "GRID_DETAIL" .And. oSubModel:IsInserted() .And. !oSubModel:IsDeleted()
		slRefzPesq := .T.
	EndIf
Return .T.

/*/{Protheus.doc} PCPA135Pes
Opção de PESQUISA do PCPA135
@author Carlos Alexandre da Silveira
@since 11/03/2019
@version P12
@param 01 oViewPai, objeto  , view principal do PCPA135
@param 02 cOpcao  , caracter, opção a ser executada: "PESQUISA", "ANTERIOR" ou "PROXIMO"
@return Nil
/*/
Function PCPA135Pes(oViewPai, cOpcao)
	Local lModifyAnt := oViewPai:GetModel():lModify
	Local oModel     := oViewPai:GetModel()

	Default cOpcao := "PESQUISA"

	If !oModel:GetModel("GRID_DETAIL"):VldLineData()
		If oViewPai != Nil .And. oViewPai:IsActive()
			oViewPai:ShowLastError()
		EndIf
		Return
	EndIf

	If slRefzPesq
		ReloadPesq(oViewPai)
	EndIf

	If oViewPai != Nil .And. oViewPai:isActive()
		//Abre a tela para PESQUISA
		If cOpcao == "PESQUISA"
			AbrePesqu(oViewPai)
		ElseIf cOpcao == "INICIALIZA"
			LimpaPesq(oViewPai)
		Else
			//Posiciona no PRÓXIMO ou no ANTERIOR somente se existir uma pesquisa
			If !oViewPai:GetModel():GetModel("GRID_RESULTS"):IsEmpty()
				PosicReg(oViewPai, cOpcao)
			EndIf
		EndIf
	EndIf

	//Seta modelo como não alterado
	oViewPai:GetModel():lModify := lModifyAnt

Return

/*/{Protheus.doc} IniciaPesq
Inicializa a tela da Pesquisa de componentes
@author Carlos Alexandre da Silveira
@since 11/03/2019
@version P12
@param 01 oViewPai, objeto, view principal do PCPA135
@return Nil
/*/
Static Function LimpaPesq(oViewPai)
	Local oModel := oViewPai:GetModel()

	oModel:GetModel("FLD_PESQUISA"):LoadValue("cCodigo",    CriaVar("GG_COMP"))
	oModel:GetModel("FLD_PESQUISA"):LoadValue("cDescricao", CriaVar("B1_DESC"))
	oModel:GetModel("GRID_RESULTS"):ClearData(.F.,.T.)
	oModel:GetModel("GRID_RESULTS"):DeActivate()
	oModel:GetModel("GRID_RESULTS"):Activate()

Return

/*/{Protheus.doc} ReloadPesq
Reinicializa a tela da Pesquisa de componentes
@author brunno.costa
@since 19/03/2019
@version P12
@param 01 oViewPai, objeto, view principal do PCPA200
@return Nil
/*/
Static Function ReloadPesq(oViewPai)

	Local oModel     := oViewPai:GetModel()
	Local oFieldPesq := oModel:GetModel("FLD_PESQUISA")
	Local oGridResul := oModel:GetModel("GRID_RESULTS")
	Local cCodPesq   := oFieldPesq:GetValue("cCodigo")
	Local cDescPesq  := oFieldPesq:GetValue("cDescricao")
	Local cOldPath   := oGridResul:GetValue("cCaminho")
	Local nOpViewAnt := oViewPai:GetOperation()
	Local nOpModelAn := oViewPai:oModel:nOperation

	If (!Empty(cCodPesq) .or. !Empty(cDescPesq))
		ConfigTela("ABRE", oViewPai)
		If !Empty(cCodPesq)
			oFieldPesq:SetValue("cCodigo", CriaVar("GG_COMP"))
			oFieldPesq:SetValue("cCodigo", cCodPesq)
		EndIf

		If !Empty(cDescPesq)
			oFieldPesq:SetValue("cDescricao", CriaVar("B1_DESC"))
			oFieldPesq:SetValue("cDescricao", cDescPesq)
		EndIf

		If !Empty(cOldPath)
			If !oGridResul:SeekLine({{"cCaminho" , cOldPath  }}, .F., .T.)
				oGridResul:GoLine(1)
			Endif
		EndIf

		//Sempre que a tela for fechada, ativa a View principal
		FwViewActive(oViewPai)
		ConfigTela("FECHA", oViewPai, nOpViewAnt, nOpModelAn)
		slRefzPesq := .F.
	EndIf

Return

/*/{Protheus.doc} AbrePesqu
Abre a tela da Pesquisa de componentes
@author Carlos Alexandre da Silveira
@since 11/03/2019
@version P12
@param 01 oViewPai, objeto, view principal do PCPA135
@return Nil
/*/
Static Function AbrePesqu(oViewPai)
	Local oViewExec  := Nil
	Local oViewPesq  := ViewDef(oViewPai)
	Local oModelPai  := oViewPai:GetModel()
	Local nOpViewAnt := oViewPai:GetOperation()
	Local nOpModelAn := oViewPai:oModel:nOperation
	Local lPrevia    := oModelPai:GetModel("FLD_PESQUISA"):GetValue("lPrevia")
	Local lChgPrevia := .F.
	Local cBotaoPrev := IIf(lPrevia, STR0235, STR0236) //"Ocultar Prévia" - "Ver Prévia"

	ConfigTela("ABRE", oViewPai)

	//Determina teclas de atalho
	SetKey( VK_F5, {|| Navega(oViewPai, "ATUAL"   , .T.)} )
	SetKey( VK_F6, {|| Navega(oViewPai, "ANTERIOR", .T.)} )
	SetKey( VK_F7, {|| Navega(oViewPai, "PROXIMO" , .T.)} )

	//Adiciona os botões na tela
	oViewPesq:AddUserButton(cBotaoPrev, "", {|| lChgPrevia := .T., oViewPesq:CloseOwner() }, cBotaoPrev, , , .T.) //"Ocultar Prévia" - "Ver Prévia"
	oViewPesq:AddUserButton(STR0237   , "", {|| Navega(oViewPai, "ANTERIOR", !lPrevia)    }, STR0237   , , , .T.) //"Anterior [F6]"
	oViewPesq:AddUserButton(STR0238   , "", {|| Navega(oViewPai, "PROXIMO" , !lPrevia)    }, STR0238   , , , .T.) //"Próximo [F7]"
	oViewPesq:AddUserButton(STR0239   , "", {|| oViewPesq:CloseOwner()                    }, STR0239   , , , .T.) //"Fechar [ESC]"

	//Prepara ViewExec para abertura da tela
	oViewExec := FWViewExec():New()
	oViewExec:setModel(oModelPai)
	oViewExec:setView(oViewPesq)
	oViewExec:setTitle(STR0240) //"Pesquisa"
	oViewExec:setOperation(MODEL_OPERATION_INSERT)

	If lPrevia
		oViewExec:setReduction(65)
	Else
		oViewExec:setSize(76, 385)
	EndIf

	oViewExec:setButtons({{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0241},{.F.,""},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}) //"Posicionar e Fechar [F5]"
	oViewExec:SetCloseOnOk({|o| Navega(oViewPai, "ATUAL", .F.) })
	oViewExec:SetModal(.T.)
	oViewExec:OpenView(.F.)

	//Sempre que a tela for fechada, ativa a View principal
	FwViewActive(oViewPai)

	//Se foi selecionada a mudança de tela (Ver/Ocultar Prévia)
	If lChgPrevia
		ChgPrevia(oViewPai)
	EndIf

	ConfigTela("FECHA", oViewPai, nOpViewAnt, nOpModelAn)

	SetKey( VK_F5,  Nil )
	SetKey( VK_F6,  Nil )
	SetKey( VK_F7,  Nil )

Return

/*/{Protheus.doc} ConfigTela
Altera as configurações da View (operação, atalhos) para correto funcionamento
@author Carlos Alexandre da Silveira
@since 11/03/2019
@version P12
@param 01 cIndTela  , caracter, indica se está abrindo ou fechando a tela
@param 02 oViewPai  , objeto  , view principal (PCPA135)
@param 03 nOpViewAnt, numérico, operaação da view principal a ser restaurada no fechamento da tela
@param 04 nOpModelAn, numérico, operaação do modelo principal a ser restaurada no fechamento da tela
@return Nil
/*/
Static Function ConfigTela(cIndTela, oViewPai, nOpViewAnt, nOpModelAn)
	Local oModelPai := oViewPai:GetModel()

	If cIndTela == "ABRE"
		//Ajusta operação do modelo e view anteriores (PCPA135) para Inclusão para que os Get's da pesquisa funcionem adequadamente
		oViewPai:SetOperation(OP_INCLUIR)
		oViewPai:oModel:nOperation := MODEL_OPERATION_INSERT
		oModelPai:GetModel("FLD_MASTER"):SetValue("LPESQUISA",.T.)
	Else
		//Retorna operação do modelo e view anteriores (PCPA135) para visualização
		oModelPai:GetModel("FLD_MASTER"):LoadValue("LPESQUISA",.F.)
		oViewPai:SetOperation(nOpViewAnt)
		oViewPai:oModel:nOperation := nOpModelAn
	EndIf

Return

/*/{Protheus.doc} P135PesMod
Função chamada no PCPA135 para criar o modelo da pesquisa no modelo principal
@author Carlos Alexandre da Silveira
@since 11/03/2019
@version P12
@param 01 oModel, objeto, modelo onde serão adicionados os modelos de Pesquisa
@return oModel
/*/
Function P135PesMod(oModel)

Return ModelDef(oModel, "FLD_MASTER")

/*/{Protheus.doc} ModelDef
Definição do Modelo (Pesquisa)
@author Carlos Alexandre da Silveira
@since 11/03/2019
@version P12
@param 01 oModel, objeto  , modelo da tela principal
@param 02 cOwner, caracter, nome do field master/owner
@return oModel
/*/
Static Function ModelDef(oModel, cOwner)
	Local oStruCab := FWFormStruct(1, "SGG", {|cCampo| "|" + AllTrim(cCampo) + "|" $ "|GG_COD|"})
	Local oStruRes := FWFormStruct(1, "SGG", {|cCampo| "|" + AllTrim(cCampo) + "|" $ "|GG_COD|"})

	Default oModel := MPFormModel():New('PCPA135Pes')

	//Altera as estruturas dos modelos
	AltStrMod(@oStruCab, @oStruRes)

	//FLD_PESQUISA - Modelo do cabeçalho
	oModel:AddFields("FLD_PESQUISA", cOwner, oStruCab)
	oModel:GetModel("FLD_PESQUISA"):SetDescription(STR0240) //"Pesquisa"
	oModel:GetModel("FLD_PESQUISA"):SetOnlyQuery(.T.)
	If !Empty(cOwner)
		oModel:GetModel("FLD_PESQUISA"):SetOptional(.T.)
	EndIf

	//GRID_RESULTS - Grid de resultados
	oModel:AddGrid("GRID_RESULTS", "FLD_PESQUISA", oStruRes)
	oModel:GetModel("GRID_RESULTS"):SetDescription(STR0242) //"Resultados"
	oModel:GetModel("GRID_RESULTS"):SetOnlyQuery(.T.)
	oModel:GetModel("GRID_RESULTS"):SetOptional(.T.)

Return oModel

/*/{Protheus.doc} ViewDef
Definição da View (Pesquisa)
@author Carlos Alexandre da Silveira
@since 11/03/2019
@version P12
@param 01 oViewOwner, objeto, view da tela principal
@return oView
/*/
Static Function ViewDef(oViewOwner)
	Local oView    := FWFormView():New(oViewOwner)
	Local oStruCab := FWFormStruct(2, "SGG", {|cCampo| "|" + AllTrim(cCampo) + "|" $ "|GG_COD|"})
	Local oStruRes := FWFormStruct(2, "SGG", {|cCampo| "|" + AllTrim(cCampo) + "|" $ "|GG_COD|"})
	Local lPrevia  := oViewOwner:GetModel():GetModel("FLD_PESQUISA"):GetValue("lPrevia")

	//Altera as estruturas dos modelos
	AltStrView(@oStruCab, @oStruRes)

	oView:SetModel(FWLoadModel("PCPA135Pes"))

	//V_FLD_PESQUISA - View do Cabeçalho
	oView:AddField("V_FLD_PESQUISA", oStruCab, "FLD_PESQUISA")
	oView:SetViewProperty("V_FLD_PESQUISA", "SETLAYOUT", { FF_LAYOUT_HORZ_DESCR_TOP , 2 })
	oView:CreateHorizontalBox("BOX_HEADER", 74, , .T.)
	oView:SetOwnerView("V_FLD_PESQUISA", 'BOX_HEADER')

	//Na visão com Prévia, adiciona a Grid com os resultados
	If lPrevia
		//V_GRID_RESULTS - View da Grid de Resultados
		oView:AddGrid("V_GRID_RESULTS", oStruRes ,"GRID_RESULTS")
		oView:CreateHorizontalBox("BOX_GRID", 100)
		oView:SetOwnerView("V_GRID_RESULTS", 'BOX_GRID')

		//Atribui posicionamento com Duplo Clique na GRID
		oView:SetViewProperty("V_GRID_RESULTS", "GRIDDOUBLECLICK", {{|| Navega(oViewOwner, "ATUAL", .T.) }})
	EndIf

	oView:ShowUpdateMsg(.F.)
	oView:ShowInsertMsg(.F.)

	//Seta bloco AfterViewActivate
	oView:SetAfterViewActivate({|oView| AfterView(oView)})

Return oView


/*/{Protheus.doc} AltStrMod
Edita os campos da estrutura do Model
@author Carlos Alexandre da Silveira
@since 11/03/2019
@version P12
@param 01 oStruCab, object, estrutura do modelo FLD_PESQUISA
@param 02 oStruRes, object, estrutura do modelo GRID_RESULTS
@return Nil
/*/
Static Function AltStrMod(oStruCab, oStruRes)
	//Campos do Cabeçalho
	oStruCab:RemoveField("GG_COD")
	oStruCab:AddField(STR0243                            ,; // [01]  C   Titulo do campo  - "Componente:"
	                  STR0243                            ,; // [02]  C   ToolTip do campo - "Componente:"
	                  "cCodigo"                          ,; // [03]  C   Id do Field
	                  "C"                                ,; // [04]  C   Tipo do campo
	                  GetSx3Cache("GG_COD","X3_TAMANHO") ,; // [05]  N   Tamanho do campo
	                  0                                  ,; // [06]  N   Decimal do campo
	                  NIL                                ,; // [07]  B   Code-block de validação do campo
	                  NIL                                ,; // [08]  B   Code-block de validação When do campo
	                  NIL                                ,; // [09]  A   Lista de valores permitido do campo
	                  .F.                                ,; // [10]  L   Indica se o campo tem preenchimento obrigatório
	                  NIL                                ,; // [11]  B   Code-block de inicializacao do campo
	                  .F.                                ,; // [12]  L   Indica se trata-se de um campo chave
	                  .T.                                ,; // [13]  L   Indica se o campo pode receber valor em uma operação de update
                      .T.                                )  // [14]  L   Indica se o campo é virtual

	oStruCab:AddField(STR0244                            ,; // [01]  C   Titulo do campo  - "Descrição:"
	                  STR0244                            ,; // [02]  C   ToolTip do campo - "Descrição:"
	                  "cDescricao"                       ,; // [03]  C   Id do Field
	                  "C"                                ,; // [04]  C   Tipo do campo
	                  GetSx3Cache("B1_DESC","X3_TAMANHO"),; // [05]  N   Tamanho do campo
	                  0                                  ,; // [06]  N   Decimal do campo
	                  NIL                                ,; // [07]  B   Code-block de validação do campo
	                  NIL                                ,; // [08]  B   Code-block de validação When do campo
	                  NIL                                ,; // [09]  A   Lista de valores permitido do campo
	                  .F.                                ,; // [10]  L   Indica se o campo tem preenchimento obrigatório
	                  NIL                                ,; // [11]  B   Code-block de inicializacao do campo
	                  .F.                                ,; // [12]  L   Indica se trata-se de um campo chave
	                  .T.                                ,; // [13]  L   Indica se o campo pode receber valor em uma operação de update
                      .T.                                )  // [14]  L   Indica se o campo é virtual

	oStruCab:AddField(STR0245                            ,; // [01]  C   Titulo do campo  - "Prévia?"
	                  STR0245                            ,; // [02]  C   ToolTip do campo - "Prévia?"
	                  "lPrevia"                          ,; // [03]  C   Id do Field
	                  "L"                                ,; // [04]  C   Tipo do campo
	                  1                                  ,; // [05]  N   Tamanho do campo
	                  0                                  ,; // [06]  N   Decimal do campo
	                  NIL                                ,; // [07]  B   Code-block de validação do campo
	                  NIL                                ,; // [08]  B   Code-block de validação When do campo
	                  NIL                                ,; // [09]  A   Lista de valores permitido do campo
	                  .F.                                ,; // [10]  L   Indica se o campo tem preenchimento obrigatório
	                  {|| .T.}                           ,; // [11]  B   Code-block de inicializacao do campo
	                  .F.                                ,; // [12]  L   Indica se trata-se de um campo chave
	                  .T.                                ,; // [13]  L   Indica se o campo pode receber valor em uma operação de update
                      .T.                                )  // [14]  L   Indica se o campo é virtual

	oStruCab:SetProperty("cCodigo"   , MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, "P135Filtra('cCodigo')"   ))
	oStruCab:SetProperty("cDescricao", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, "P135Filtra('cDescricao')"))

	//Campos da GRID de Resultados
	oStruRes:RemoveField("GG_COD")
	oStruRes:AddField(STR0246                            ,; // [01]  C   Titulo do campo  - "Níveis"
	                  STR0246                            ,; // [02]  C   ToolTip do campo - "Níveis"
	                  "cNiveis"                          ,; // [03]  C   Id do Field
	                  "C"                                ,; // [04]  C   Tipo do campo
	                  2                                  ,; // [05]  N   Tamanho do campo
	                  0                                  ,; // [06]  N   Decimal do campo
	                  NIL                                ,; // [07]  B   Code-block de validação do campo
	                  NIL                                ,; // [08]  B   Code-block de validação When do campo
	                  NIL                                ,; // [09]  A   Lista de valores permitido do campo
	                  .F.                                ,; // [10]  L   Indica se o campo tem preenchimento obrigatório
	                  NIL                                ,; // [11]  B   Code-block de inicializacao do campo
	                  NIL                                ,; // [12]  L   Indica se trata-se de um campo chave
	                  .T.                                ,; // [13]  L   Indica se o campo pode receber valor em uma operação de update
                      .T.                                )  // [14]  L   Indica se o campo é virtual

	oStruRes:AddField(STR0247                            ,; // [01]  C   Titulo do campo  - "Caminho"
	                  STR0247                            ,; // [02]  C   ToolTip do campo - "Caminho"
	                  "cCaminho"                         ,; // [03]  C   Id do Field
	                  "C"                                ,; // [04]  C   Tipo do campo
	                  255                                ,; // [05]  N   Tamanho do campo
	                  0                                  ,; // [06]  N   Decimal do campo
	                  NIL                                ,; // [07]  B   Code-block de validação do campo
	                  NIL                                ,; // [08]  B   Code-block de validação When do campo
	                  NIL                                ,; // [09]  A   Lista de valores permitido do campo
	                  .F.                                ,; // [10]  L   Indica se o campo tem preenchimento obrigatório
	                  NIL                                ,; // [11]  B   Code-block de inicializacao do campo
	                  NIL                                ,; // [12]  L   Indica se trata-se de um campo chave
	                  .T.                                ,; // [13]  L   Indica se o campo pode receber valor em uma operação de update
                      .T.                                )  // [14]  L   Indica se o campo é virtual

	oStruRes:AddField(STR0077                            ,; // [01]  C   Titulo do campo  - "Descrição"
	                  STR0077                            ,; // [02]  C   ToolTip do campo - "Descrição"
	                  "cDescricao"                       ,; // [03]  C   Id do Field
	                  "C"                                ,; // [04]  C   Tipo do campo
	                  GetSx3Cache("B1_DESC","X3_TAMANHO"),; // [05]  N   Tamanho do campo
	                  0                                  ,; // [06]  N   Decimal do campo
	                  NIL                                ,; // [07]  B   Code-block de validação do campo
	                  NIL                                ,; // [08]  B   Code-block de validação When do campo
	                  NIL                                ,; // [09]  A   Lista de valores permitido do campo
	                  .F.                                ,; // [10]  L   Indica se o campo tem preenchimento obrigatório
	                  NIL                                ,; // [11]  B   Code-block de inicializacao do campo
	                  NIL                                ,; // [12]  L   Indica se trata-se de um campo chave
	                  .T.                                ,; // [13]  L   Indica se o campo pode receber valor em uma operação de update
                      .T.                                )  // [14]  L   Indica se o campo é virtual

	oStruRes:AddField(STR0248                            ,; // [01]  C   Titulo do campo  - "ID do Nó"
                      STR0248                            ,; // [02]  C   ToolTip do campo - "ID do Nó"
                      "NodeID"                           ,; // [03]  C   Id do Field
                      "C"                                ,; // [04]  C   Tipo do campo
                      7                                  ,; // [05]  N   Tamanho do campo
                      0                                  ,; // [06]  N   Decimal do campo
					  NIL                                ,; // [07]  B   Code-block de validação do campo
					  NIL                                ,; // [08]  B   Code-block de validação When do campo
					  NIL                                ,; // [09]  A   Lista de valores permitido do campo
                      .F.                                ,; // [10]  L   Indica se o campo tem preenchimento obrigatório
					  NIL                                ,; // [11]  B   Code-block de inicializacao do campo
					  NIL                                ,; // [12]  L   Indica se trata-se de um campo chave
                      .T.                                ,; // [13]  L   Indica se o campo pode receber valor em uma operação de update
                      .T.                                )  // [14]  L   Indica se o campo é virtual

Return

/*/{Protheus.doc} AltStrView
Edita os campos da estrutura da View
@author Carlos Alexandre da Silveira
@since 11/03/2019
@version P12
@param 01 oStruCab, object, estrutura da view V_FLD_PESQUISA
@param 02 oStruRes, object, estrutura da view V_GRID_RESULTS
@return Nil
/*/
Static Function AltStrView(oStruCab, oStruRes)
	//Campos do Cabeçalho
	oStruCab:RemoveField("GG_COD")
	oStruCab:AddField("cCodigo"     ,; // [01]  C   Nome do Campo
	                  "1"           ,; // [02]  C   Ordem
	                  STR0243       ,; // [03]  C   Titulo do campo    - "Componente:"
	                  STR0243       ,; // [04]  C   Descricao do campo - "Componente:"
	                  NIL           ,; // [05]  A   Array com Help
	                  "C"           ,; // [06]  C   Tipo do campo
	                  "@!S10"       ,; // [07]  C   Picture
	                  NIL           ,; // [08]  B   Bloco de Picture Var
	                  "SB1"         ,; // [09]  C   Consulta F6
	                  .T.           ,; // [10]  L   Indica se o campo é alteravel
	                  NIL           ,; // [11]  C   Pasta do campo
	                  NIL           ,; // [12]  C   Agrupamento do campo
	                  NIL           ,; // [13]  A   Lista de valores permitido do campo (Combo)
	                  NIL           ,; // [14]  N   Tamanho maximo da maior opção do combo
	                  NIL           ,; // [15]  C   Inicializador de Browse
	                  .T.           ,; // [16]  L   Indica se o campo é virtual
	                  NIL           ,; // [17]  C   Picture Variavel
	                  NIL           )  // [18]  L   Indica pulo de linha após o campo

	oStruCab:AddField("cDescricao"  ,; // [01]  C   Nome do Campo
	                  "2"           ,; // [02]  C   Ordem
	                  STR0244       ,; // [03]  C   Titulo do campo    - "Descrição:"
	                  STR0244       ,; // [04]  C   Descricao do campo - "Descrição:"
	                  NIL           ,; // [05]  A   Array com Help
	                  "C"           ,; // [06]  C   Tipo do campo
	                  "@!S20"       ,; // [07]  C   Picture
	                  NIL           ,; // [08]  B   Bloco de Picture Var
	                  NIL           ,; // [09]  C   Consulta F6
	                  .T.           ,; // [10]  L   Indica se o campo é alteravel
	                  NIL           ,; // [11]  C   Pasta do campo
	                  NIL           ,; // [12]  C   Agrupamento do campo
	                  NIL           ,; // [13]  A   Lista de valores permitido do campo (Combo)
	                  NIL           ,; // [14]  N   Tamanho maximo da maior opção do combo
	                  NIL           ,; // [15]  C   Inicializador de Browse
	                  .T.           ,; // [16]  L   Indica se o campo é virtual
	                  NIL           ,; // [17]  C   Picture Variavel
	                  NIL           )  // [18]  L   Indica pulo de linha após o campo

	//Campos da GRID de Resultados
	oStruRes:RemoveField("GG_COD")
	oStruRes:AddField("cCaminho"    ,; // [01]  C   Nome do Campo
	                  "1"           ,; // [02]  C   Ordem
	                  STR0247       ,; // [03]  C   Titulo do campo    - "Caminho"
	                  STR0247       ,; // [04]  C   Descricao do campo - "Caminho"
	                  NIL           ,; // [05]  A   Array com Help
	                  "C"           ,; // [06]  C   Tipo do campo
	                  NIL           ,; // [07]  C   Picture
	                  NIL           ,; // [08]  B   Bloco de Picture Var
	                  NIL           ,; // [09]  C   Consulta F6
	                  .F.           ,; // [10]  L   Indica se o campo é alteravel
	                  NIL           ,; // [11]  C   Pasta do campo
	                  NIL           ,; // [12]  C   Agrupamento do campo
	                  NIL           ,; // [13]  A   Lista de valores permitido do campo (Combo)
	                  NIL           ,; // [14]  N   Tamanho maximo da maior opção do combo
	                  NIL           ,; // [15]  C   Inicializador de Browse
	                  .T.           ,; // [16]  L   Indica se o campo é virtual
	                  NIL           ,; // [17]  C   Picture Variavel
	                  NIL           )  // [18]  L   Indica pulo de linha após o campo

	oStruRes:AddField("cDescricao"  ,; // [01]  C   Nome do Campo
	                  "2"           ,; // [02]  C   Ordem
	                  STR0077       ,; // [03]  C   Titulo do campo    - "Descrição"
	                  STR0077       ,; // [04]  C   Descricao do campo - "Descrição"
	                  NIL           ,; // [05]  A   Array com Help
	                  "C"           ,; // [06]  C   Tipo do campo
	                  NIL           ,; // [07]  C   Picture
	                  NIL           ,; // [08]  B   Bloco de Picture Var
	                  NIL           ,; // [09]  C   Consulta F6
	                  .F.           ,; // [10]  L   Indica se o campo é alteravel
	                  NIL           ,; // [11]  C   Pasta do campo
	                  NIL           ,; // [12]  C   Agrupamento do campo
	                  NIL           ,; // [13]  A   Lista de valores permitido do campo (Combo)
	                  NIL           ,; // [14]  N   Tamanho maximo da maior opção do combo
	                  NIL           ,; // [15]  C   Inicializador de Browse
	                  .T.           ,; // [16]  L   Indica se o campo é virtual
	                  NIL           ,; // [17]  C   Picture Variavel
	                  NIL           )  // [18]  L   Indica pulo de linha após o campo

	oStruRes:AddField("cNiveis"     ,; // [01]  C   Nome do Campo
	                  "3"           ,; // [02]  C   Ordem
	                  STR0246       ,; // [03]  C   Titulo do campo    - "Níveis"
	                  STR0246       ,; // [04]  C   Descricao do campo - "Níveis"
	                  NIL           ,; // [05]  A   Array com Help
	                  "C"           ,; // [06]  C   Tipo do campo
	                  NIL           ,; // [07]  C   Picture
	                  NIL           ,; // [08]  B   Bloco de Picture Var
	                  NIL           ,; // [09]  C   Consulta F6
	                  .F.           ,; // [10]  L   Indica se o campo é alteravel
	                  NIL           ,; // [11]  C   Pasta do campo
	                  NIL           ,; // [12]  C   Agrupamento do campo
	                  NIL           ,; // [13]  A   Lista de valores permitido do campo (Combo)
	                  NIL           ,; // [14]  N   Tamanho maximo da maior opção do combo
	                  NIL           ,; // [15]  C   Inicializador de Browse
	                  .T.           ,; // [16]  L   Indica se o campo é virtual
	                  NIL           ,; // [17]  C   Picture Variavel
	                  NIL           )  // [18]  L   Indica pulo de linha após o campo

	//Ajusta largura dos campos na Grid
	oStruRes:SetProperty("cNiveis"   , MVC_VIEW_WIDTH,  60)
	oStruRes:SetProperty("cDescricao", MVC_VIEW_WIDTH, 300)

Return

/*/{Protheus.doc} AfterView
Função executada após ativar a view
@author Carlos Alexandre da Silveira
@since 11/03/2019
@version P12
@param 01 oView, objeto, view da tela de Pesquisa
@return Nil
/*/
Static Function AfterView(oView)
	//Se está usando a Prévia, faz o refresh para que o posicionamento em tela fique correto (igual ao da Model)
	If oView:GetModel():GetModel("FLD_PESQUISA"):GetValue("lPrevia")
		oView:Refresh("V_GRID_RESULTS")
	EndIf

Return

/*/{Protheus.doc} ChgPrevia()
Reabre a tela alterando o modo de exibição (com ou sem Prévia)
@author Carlos Alexandre da Silveira
@since 11/03/2019
@version P12
@param 01 oViewPai, objeto, view principal (PCPA135)
@return Nil
/*/
Static Function ChgPrevia(oViewPai)
	Local oModelCab := oViewPai:GetModel():GetModel("FLD_PESQUISA")

	//Indica no model se está sendo utilizada a tela de Prévia
	oModelCab:SetValue("lPrevia", !oModelCab:GetValue("lPrevia"))

	//Chama a função para abrir a tela de pesquisa
	AbrePesqu(oViewPai)

Return

/*/{Protheus.doc} Navega()
Tratamento das funcionalidades da tela de Pesquisa que executam ação na Tree
@author Carlos Alexandre da Silveira
@since 11/03/2019
@version P12
@param 01 oViewPai  , objeto  , view principal (PCPA135)
@param 02 cDirecao  , caracter, indica a direção para o posicionamento: "ATUAL", "ANTERIOR" ou "PROXIMO"
@param 03 lFechaTela, lógico  , indica se deverá ser fechada a tela de pesquisa
@return .T.
/*/
Static Function Navega(oViewPai, cDirecao, lFechaTela)
	Local oView := FwViewActive()

	PosicReg(oViewPai, cDirecao)

	If lFechaTela
		oView:CloseOwner()
		FwViewActive(oViewPai)
	Else
		FwViewActive(oView)
	EndIf

Return .T.

/*/{Protheus.doc} PosicReg()
Posiciona o registro
@author Carlos Alexandre da Silveira
@since 11/03/2019
@version P12
@param 01 oViewPai, objeto  , view principal (PCPA135)
@param 02 cDirecao, caracter, indica a direção para o posicionamento: "ATUAL", "ANTERIOR" ou "PROXIMO"
@return .T.
/*/
Static Function PosicReg(oViewPai, cDirecao)
	Local oGridResul := oViewPai:GetModel():GetModel("GRID_RESULTS")
	Local nLine      := oGridResul:GetLine()

	//Posiciona a Grid na linha desejada
	If cDirecao == "ANTERIOR"
		If nLine == 1
			oGridResul:GoLine(oGridResul:Length())
		Else
			oGridResul:GoLine(nLine - 1)
		EndIf

	ElseIf cDirecao == "PROXIMO"
		If nLine == oGridResul:Length()
			oGridResul:GoLine(1)
		Else
			oGridResul:GoLine(nLine + 1)
		EndIf
	EndIf

	//Processa a busca pelo registro posicionando a Tree
	Processa({|| PosicTree(oViewPai)}, STR0086, STR0249, .F.) //"Aguarde..." - "Posicionando..."

Return .T.

/*/{Protheus.doc} PosicTree()
Busca e posiciona o registro na Tree de acordo com o registro posicionado no modelo GRID_RESULTS
@author Carlos Alexandre da Silveira
@since 11/03/2019
@version P12
@param 01 oViewPai, objeto, view principal (PCPA135)
@return .T.
/*/
Static Function PosicTree(oViewPai)
	Local oMdlMaster  := oViewPai:GetModel():GetModel("FLD_MASTER")
	Local oMdlDetail  := oViewPai:GetModel():GetModel("GRID_DETAIL")
	Local oGridResul  := oViewPai:GetModel():GetModel("GRID_RESULTS")
	Local aCaminho    := StrToKArr2(oGridResul:GetValue("cCaminho"), " -> ")
	Local nIndNivel   := 0
	Local cCod        := ""
	Local cComp       := ""
	Local cTrt        := ""
	Local cNodeID     := oGridResul:GetValue("NodeID")

	//Seta regua infinita
	ProcRegua(0)

	//Determina oViewPai como ativa atual para manipular a Tree
	FwViewActive(oViewPai)

	//Verifica se já foi posicionado nesse registro antes
	If Empty(cNodeID)
		//Posiciona no pai da Tree
		P135TrSeek(oMdlMaster:GetValue("CARGO"), , .T.)

		//Percorre os componentes do "caminho" selecionado
		For nIndNivel := 1 To Val(oGridResul:GetValue("cNiveis"))
			cCod  := AllTrim(aCaminho[nIndNivel])
			cComp := AllTrim(aCaminho[nIndNivel + 1])
			cTrt  := ExtraiTrt(@cComp)

			ExtraiTrt(@cCod)

			//Busca o registro na Grid do PCPA135 para pegar o Cargo do mesmo na Tree
			If oMdlDetail:SeekLine({{"GG_COD" , cCod  }, ;
									{"GG_COMP", cComp }, ;
									{"GG_TRT" , cTrt  } }, .F., .T.)

				//Posiciona a tree no cargo do registro
				P135TrSeek(oMdlDetail:GetValue("CARGO"), , .T.)
			EndIf
		Next nIndNivel

		//Grava o NodeID desse registro para não precisar buscar novamente depois
		GravaNode(oViewPai)
	Else
		//Se já foi posicionado nesse registro, vai direto ao nó correspondente
		P135TrSeek( , cNodeID, .T.)
	EndIf

Return .T.

/*/{Protheus.doc} GravaNode
Grava o ID do nó para posteriormente não precisar refazer a busca
@author Carlos Alexandre da Silveira
@since 11/03/2019
@version P12
@param 01 oViewPai, objeto, view principal (PCPA135)
@return Nil
/*/
Static Function GravaNode(oViewPai)
	Local nOpViewAnt := oViewPai:GetOperation()
	Local nOpModelAn := oViewPai:oModel:nOperation
	Local oGridResul := oViewPai:GetModel():GetModel("GRID_RESULTS")

	If nOpModelAn == MODEL_OPERATION_DELETE
		ConfigTela("ABRE", oViewPai)
	EndIf

	oGridResul:SetNoUpdateLine(.F.)
	oGridResul:LoadValue("NodeID", P135GtNoID())
	oGridResul:SetNoUpdateLine(.T.)

	If nOpModelAn == MODEL_OPERATION_DELETE
		ConfigTela("FECHA", oViewPai, nOpViewAnt, nOpModelAn)
	EndIf

Return

/*/{Protheus.doc} ExtraiTrt
Extrai o TRT do produto pois estará concatenado: PRODUTO (TRT)
@author Carlos Alexandre da Silveira
@since 11/03/2019
@version P12
@param 01 cCod, caracter, código do produto que terá o TRT extraído e retornado
@return cTrt, caracter, TRT extraido de cCod
/*/
Static Function ExtraiTrt(cCod)
	Local cTrt    := CriaVar('GG_TRT')
	Local nTrtIni := 0
	Local nTrtFim := 0

	If Right(cCod, 1) == ")"
		nTrtIni := At(" (", cCod) + 2
		nTrtFim := At(")",cCod, nTrtIni)
		cTrt    := SubStr(cCod, nTrtIni, nTrtFim - nTrtIni)
		cCod    := Left(cCod, nTrtIni - 2)
	EndIf

	cCod := AllTrim(cCod)

Return cTrt

/*/{Protheus.doc} P135Filtra()
Processa a pesquisa dos registros de acordo com os filtros informados
@author Carlos Alexandre da Silveira
@since 11/03/2019
@version P12
@return lAbort, lógico, indica se a operação foi cancelada pelo usuário
/*/
Function P135Filtra()
	Local lAbort := .F.

	Processa({|| ProcFiltro() }, STR0086, STR0250, lAbort) //"Aguarde..." - "Pesquisando as opções..."

Return !lAbort

/*/{Protheus.doc} ProcFiltro()
Processa a busca dos registros e alimenta a Grid com o resultado
@author Carlos Alexandre da Silveira
@since 11/03/2019
@version P12
@return lAbort
/*/
Static Function ProcFiltro()
	Local oView      := FwViewActive()
	Local oModel     := FWModelActive()
	Local oGridResul := oModel:GetModel("GRID_RESULTS")
	Local cProdPai   := oModel:GetModel("FLD_MASTER"):GetValue("GG_COD")
	Local cCodigo    := oModel:GetModel("FLD_PESQUISA"):GetValue("cCodigo")
	Local cDescricao := oModel:GetModel("FLD_PESQUISA"):GetValue("cDescricao")
	Local lPrevia    := oModel:GetModel("FLD_PESQUISA"):GetValue("lPrevia")
	Local lFiltraVen := IIf(P135GetF12("EXIBE_VENCIDOS") == 1, .F., .T.)
	Local cCaminho   := ""
	Local aPaths     := {}
	Local nInd       := 0
	Local lAbort     := .F.

	//Seta regua infinita
	ProcRegua(0)

	//Se Código ou Descrição está preenchido, faz a busca dos registros
	If !Empty(cCodigo) .Or. !Empty(cDescricao)
		//Faz a pesquisa no banco de dados carregando o array aPaths
		Processa({|| BuscaRegs(cProdPai, lFiltraVen, cCodigo, cDescricao, @aPaths) }, STR0086, STR0251, lAbort) //"Aguarde..." - "Lendo as opções na base de dados..."
	EndIf

	//Verifica se encontrou registros e se a busca não foi abortada pelo usuário
	If Len(aPaths) > 0 .AND. !lAbort
		oGridResul:SetNoUpdateLine(.F.)
		oGridResul:SetNoDeleteLine(.F.)
		oGridResul:SetNoInsertLine(.F.)
		oGridResul:ClearData(.F.,.T.)

		//Percorre os registros encontrados
		For nInd := 1 to Len(aPaths)
			//Processa a Regua
			IncProc()

			If nInd > 1
				oGridResul:AddLine()
			EndIf

			//Trata o campo com o caminho
			cCaminho := AllTrim(aPaths[nInd][1])
			cCaminho := StrTran(cCaminho, ' ()', '')

			oGridResul:LoadValue("cCaminho"  , AllTrim(cCaminho))
			oGridResul:LoadValue("cDescricao", Alltrim(aPaths[nInd][2]))
			oGridResul:LoadValue("cNiveis"   , PadL(cValToChar(aPaths[nInd][3]), 2, '0'))
		Next nInd

		oGridResul:GoLine(1)
		oGridResul:SetNoUpdateLine(.T.)
		oGridResul:SetNoDeleteLine(.T.)
		oGridResul:SetNoInsertLine(.T.)
	Else
		//Inicializa a grid de resutados
		oGridResul:ClearData(.F.,.T.)
		oGridResul:DeActivate()
		oGridResul:Activate()
	Endif

	If lPrevia .AND. IsInCallStack("AbrePesqu")
		oView:Refresh("V_GRID_RESULTS")
	EndIf

Return !lAbort

/*/{Protheus.doc} BuscaRegs
Query recursiva para busca do componente na estrutura
@author Carlos Alexandre da Silveira
@since 11/03/2019
@version P12
@param 01 cProdPai  , caracter, código do produto pai da estrutura, de onde partirá a busca
@param 02 lFiltraVen, lógico  , indica se deverá filtrar os componentes vencidos (F12)
@param 03 cBuscaCod , caracter, código do componente a ser procurado
@param 04 cBuscaDesc, caracter, parte da descrição do componente a ser procurada
@param 05 aPaths    , array   , array com os caminhos do componente na estrutura (passado por referÃªncia):
								aPaths[1] = PathCod  - Caminho do pai até o componente (PAI -> ... -> COMPONENTE)
								aPaths[2] = DescProd - Descrição do componente
								aPaths[3] = Nivel    - Nível onde o mesmo foi encontrado
@return lAchou, lógico, indica se a busca encontrou algum registro
/*/
Static Function BuscaRegs(cProdPai, lFiltraVen, cBuscaCod, cBuscaDesc, aPaths)
	Local cAliasTop    := GetNextAlias()
	Local cBanco       := TCGetDB()
	Local cQuery       := ""
	Local cQryUniAll   := ""
	Local lAchou       := .F.
	Local oTempTable   := criaTmpTRB()

	//Tratamentos de SQL Injection
	cBuscaCod  := StrTran(cBuscaCod,  "'", "")
	cBuscaDesc := StrTran(cBuscaDesc, "'", "")

	//Seta regua infinita
	ProcRegua(0)

	slRefzPesq := .F.

	cQuery := " WITH EstruturaRecursiva(GG_COMP, B1_DESC, Nivel, PathCod)"
	cQuery += " AS ("
	cQuery +=      " SELECT SGG_Base.GG_COMP,"
	cQuery +=             " SB1_Prod.B1_DESC,"
	cQuery +=             " 1 AS Nivel,"
	cQuery +=             " Cast( Trim(SGG_Base.GG_COD) || ' -> ' || Trim(SGG_Base.GG_COMP) || ' (' || Trim(SGG_Base.GG_TRT) || ')' AS VarChar(8000) ) AS PathCod"
	cQuery +=        " FROM ( cQryMemFro ) SGG_Base"
	cQuery +=       " INNER JOIN " + RetSqlName( "SB1" ) + " SB1_Prod"
	cQuery +=          " ON SB1_Prod.B1_FILIAL  = '" + xFilial("SB1") + "' "
	cQuery +=         " AND SB1_Prod.B1_COD = SGG_Base.GG_COMP "
	cQuery +=         " AND SB1_Prod.D_E_L_E_T_ = ' '"
	cQuery +=       " WHERE SGG_Base.GG_COD = '" + cProdPai + "'"

	//Desconsidera componentes inválidos
	If lFiltraVen
		cQuery +=     " AND SGG_Base.GG_INI <= '" + DToS(dDataBase) + "'"
		cQuery +=     " AND SGG_Base.GG_FIM >= '" + DToS(dDataBase) + "'"
	EndIf

	cQryUniAll +=  " UNION ALL"
	cQryUniAll += " SELECT SGG_Filho.GG_COMP,"
	cQryUniAll +=        " SB1_Comp.B1_DESC,"
	cQryUniAll +=        " Qry_Recurs.Nivel + 1 AS Nivel,"
	cQryUniAll +=        " Cast( (Qry_Recurs.PathCod || ' -> ' || Trim(SGG_Filho.GG_COMP) || ' (' || Trim(SGG_Filho.GG_TRT) || ')') AS VarChar(8000) ) AS PathCod"
	cQryUniAll +=   " FROM " + RetSqlName("SGG") + " SGG_Filho "
	cQryUniAll +=   " INNER JOIN EstruturaRecursiva Qry_Recurs"
	cQryUniAll +=      " ON Qry_Recurs.GG_COMP = SGG_Filho.GG_COD"
	cQryUniAll +=   " INNER JOIN " + RetSqlName( "SB1" ) + " SB1_Comp"
	cQryUniAll +=      " ON SB1_Comp.B1_FILIAL  = '" + xFilial("SB1") + "' "
	cQryUniAll +=     " AND SB1_Comp.B1_COD = SGG_Filho.GG_COMP"
	cQryUniAll +=     " AND SB1_Comp.D_E_L_E_T_ = ' '"
	cQryUniAll +=   " INNER JOIN " + RetSqlName( "SB1" ) + " SB1_Pai"
	cQryUniAll +=     " ON SB1_Pai.B1_FILIAL  = '" + xFilial("SB1") + "' "
	cQryUniAll +=    " AND SB1_Pai.B1_COD = SGG_Filho.GG_COD"
	cQryUniAll +=    " AND SB1_Pai.D_E_L_E_T_ = ' '"
	cQryUniAll +=  " WHERE SGG_Filho.GG_FILIAL  = '" + xFilial("SGG") + "' "
	cQryUniAll +=    " AND SGG_Filho.D_E_L_E_T_ = ' ' "

	//Desconsidera componentes inválidos
	If lFiltraVen
		cQryUniAll +=     " AND SGG_Filho.GG_INI <= '" + DToS(dDataBase) + "'"
		cQryUniAll +=     " AND SGG_Filho.GG_FIM >= '" + DToS(dDataBase) + "'"
	EndIf

	//Tratamento dados em memoria
	PesMemoria(@cQryUniAll, @cQuery, oTempTable)

	cQuery +=   " )"
	cQuery += " SELECT DISTINCT Resultado.PathCod,"
	cQuery +=                 " Resultado.B1_DESC AS DescProd,"
	cQuery +=                 " Resultado.Nivel"
	cQuery +=   " FROM EstruturaRecursiva Resultado"
	cQuery +=  " WHERE 1 = 1"

	If !Empty(cBuscaCod)
		cQuery += " AND Resultado.GG_COMP = '" + cBuscaCod + "'"
	EndIf

	If !Empty(cBuscaDesc)
		cQuery += " AND Resultado.B1_DESC LIKE '%" + AllTrim(cBuscaDesc) + "%'"
	EndIf

	//Ordena por Path
	cQuery += " ORDER BY 1"

	//Realiza ajustes da Query para cada banco
	If "POSTGRES" $ cBanco

		//Altera sintaxe da clausula WITH
		cQuery := StrTran(cQuery, 'WITH ', 'WITH recursive ')

		//Medida paliativa banco POSTGRES. Banco suporta VarChar(8000), entretanto DbAccess com PostGres funciona em bases desatualizadas
		//cQuery := StrTran(cQuery,"VarChar(8000)","VarChar(255)")

		//Corrige Falhas internas de Binário - POSTGRES
		cQuery := StrTran(cQuery, CHR(13), " ")
		cQuery := StrTran(cQuery, CHR(10), " ")
		cQuery := StrTran(cQuery, CHR(09), " ")

	ElseIf "MSSQL" $ cBanco
		//Substitui a função Trim
		cQuery := StrTran(cQuery, "Trim(", "RTrim(")
		//Substitui concatenação || por +
		cQuery := StrTran(cQuery, '||', '+')

	ElseIf !("ORACLE" $ cBanco)
		//Substitui concatenação || por +
		cQuery := StrTran(cQuery, '||', '+')
	EndIf

	If "ORACLE" $ cBanco
		cQuery := StrTran(cQuery,"VarChar(8000)","VarChar(4000)")
	EndIf

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAliasTop, .T., .T.)
	If !(cAliasTop)->(Eof())
		lAchou := .T.
	EndIf

	While !(cAliasTop)->(Eof())
		//Processa a Regua
		IncProc()

		//Adiciona o registro no array aPaths
		aAdd(aPaths, {(cAliasTop)->PathCod, (cAliasTop)->DescProd, (cAliasTop)->Nivel})

		(cAliasTop)->(DbSkip())
	EndDo

	(cAliasTop)->(dbCloseArea())

	oTempTable:Delete()
	oTempTable := Nil
Return lAchou

/*/{Protheus.doc} PesMemoria
Realiza ajustes na query de pesquisa para considerar os dados em memoria
@author lucas.franca
@since 18/03/2019
@version 1.0
@param 01 - cQryUniAll, caracter, trecho da query UNION ALL utilizada para copia em MSSQL
@param 02 - cQuery    , caracter, query recursiva de pesquisa original - retornada por referencia
@return oTempTable	- Objeto da tabela temporária.
/*/
Static Function PesMemoria(cQryUniAll, cQuery, oTempTable)
	Local nIndex       := 0
	Local cBanco       := TCGetDB()
	Local cQryMemFro   := ""
	Local cQryMemCpl   := ""
	Local cRecnos      := ""
	Local cAliasTRB    := oTempTable:GetAlias()
	Local oModel       := FWModelActive()
	Local oModelGrv    := oModel:GetModel("GRAVA_SGG")
	Local oModelGrid   := oModel:GetModel("GRID_DETAIL")

	//Tratamento para os dados em memória
	cQryMemFro := " SELECT GG_FILIAL, GG_COD, GG_COMP, GG_TRT, GG_INI, GG_FIM, D_E_L_E_T_ "
	cQryMemFro +=   " FROM " + RetSqlName("SGG") + " "
	cQryMemFro +=  " WHERE GG_FILIAL  = '"+xFilial("SGG")+"' "
	cQryMemFro +=    " AND D_E_L_E_T_ = ' ' "
	cQryMemFro +=  " X_UpdRecnos_X "
	cQryMemFro += " UNION "
	cQryMemFro += " SELECT GG_FILIAL, GG_COD, GG_COMP, GG_TRT, GG_INI, GG_FIM, D_E_L_E_T_ "
	cQryMemFro +=   " FROM " + oTempTable:GetRealName()

	//Recupera os dados do modelo de gravação
	For nIndex := 1 To oModelGrv:Length()
		If !Empty(oModelGrv:GetValue("GG_COD", nIndex)) .And. !oModelGrv:IsDeleted(nIndex)
			//Tratamento de exclusoes
			If oModelGrv:GetValue("DELETE", nIndex)
				If Empty(cRecnos)
					cRecnos := cValToChar(oModelGrv:GetValue("NREG", nIndex))
				Else
					cRecnos += ", " + cValToChar(oModelGrv:GetValue("NREG", nIndex))
				EndIf
			Else
				//Tratamento de inclusoes
				RecLock(cAliasTRB, .T.)
				(cAliasTRB)->GG_FILIAL := xFilial("SGG")
				(cAliasTRB)->GG_COD    := oModelGrv:GetValue("GG_COD", nIndex)
				(cAliasTRB)->GG_COMP   := oModelGrv:GetValue("GG_COMP", nIndex)
				(cAliasTRB)->GG_TRT    := oModelGrv:GetValue("GG_TRT", nIndex)
				(cAliasTRB)->GG_INI    := oModelGrv:GetValue("GG_INI", nIndex)
				(cAliasTRB)->GG_FIM    := oModelGrv:GetValue("GG_FIM", nIndex)
				(cAliasTRB)->(MsUnLock())
			EndIf
		EndIf
	Next nIndex

	//Recupera os dados que estão no modelo da tela
	For nIndex := 1 To oModelGrid:Length()
		If !Empty(oModelGrid:GetValue("GG_COD", nIndex)) .And. ;
		   (oModelGrid:IsUpdated(nIndex) .OR. oModelGrid:IsDeleted(nIndex))
		   
			//Tratamento de exclusoes
			If oModelGrid:IsDeleted(nIndex)
				If Empty(cRecnos)
					cRecnos := cValToChar(oModelGrid:GetValue("NREG", nIndex))
				Else
					cRecnos += ", " + cValToChar(oModelGrid:GetValue("NREG", nIndex))
				EndIf
			Else
				//Tratamento de inclusoes
				RecLock(cAliasTRB, .T.)
				(cAliasTRB)->GG_FILIAL := xFilial("SGG")
				(cAliasTRB)->GG_COD    := oModelGrid:GetValue("GG_COD", nIndex)
				(cAliasTRB)->GG_COMP   := oModelGrid:GetValue("GG_COMP", nIndex)
				(cAliasTRB)->GG_TRT    := oModelGrid:GetValue("GG_TRT", nIndex)
				(cAliasTRB)->GG_INI    := oModelGrid:GetValue("GG_INI", nIndex)
				(cAliasTRB)->GG_FIM    := oModelGrid:GetValue("GG_FIM", nIndex)
				(cAliasTRB)->(MsUnLock())
			EndIf
		EndIf
	Next nIndex

	If "MSSQL" $ cBanco 
		cQryMemCpl := StrTran(cQryUniAll, "FROM " + RetSqlName( "SGG" ) + " SGG_Filho",;
		                                  "FROM (SELECT GG_FILIAL, GG_COD, GG_COMP, GG_TRT, GG_INI, GG_FIM, D_E_L_E_T_ " +;
		                                         " FROM " + oTempTable:GetRealName() + ") SGG_Filho")

		cQryUniAll += " SGG_Filho.X_UpdRecnos_X "
	Else
		cQryUniAll := StrTran(cQryUniAll, "FROM " + RetSqlName( "SGG" ) + " SGG_Filho",;
		                                  "FROM (SELECT GG_FILIAL, GG_COD, GG_COMP, GG_TRT, GG_INI, GG_FIM, D_E_L_E_T_ "+;
		                                         " FROM " + RetSqlName( "SGG" ) +;
		                                        " WHERE GG_FILIAL  = '" + xFilial("SGG") + "' " +;
											      " AND D_E_L_E_T_ = ' ' " +;
		                                              " X_UpdRecnos_X " +;
		                                       " UNION " +;
		                                       " SELECT GG_FILIAL, GG_COD, GG_COMP, GG_TRT, GG_INI, GG_FIM, D_E_L_E_T_ " +;
		                                         " FROM " + oTempTable:GetRealName() + ") SGG_Filho")
	EndIf

	cQuery += cQryUniAll + cQryMemCpl
	cQuery := StrTran(cQuery, "cQryMemFro", cQryMemFro)

	If !Empty(cRecnos)
		cQuery := StrTran(cQuery, "SGG_Filho.X_UpdRecnos_X", " AND SGG_Filho.R_E_C_N_O_ NOT IN (" + cRecnos + ") ")
		cQuery := StrTran(cQuery, "X_UpdRecnos_X", " AND R_E_C_N_O_ NOT IN (" + cRecnos + ") ")
	Else
		cQuery := StrTran(cQuery, "SGG_Filho.X_UpdRecnos_X", "")
		cQuery := StrTran(cQuery, "X_UpdRecnos_X", "")
	EndIf
Return

/*/{Protheus.doc} criaTmpTRB
Cria a tabela temporária conforme a estrutura da tabela SGG
@author lucas.franca
@since 18/03/2019
@version 1.0
@return oTempTable	- Objeto da tabela temporária.
/*/
Static Function criaTmpTRB()
	Local oTempTable := FwTemporaryTable():New()

	oTempTable:SetFields(SGG->(dbStruct()))
	oTempTable:AddIndex("01",{"GG_FILIAL","GG_COD","GG_COMP","GG_TRT"})
	oTempTable:Create()

Return oTempTable