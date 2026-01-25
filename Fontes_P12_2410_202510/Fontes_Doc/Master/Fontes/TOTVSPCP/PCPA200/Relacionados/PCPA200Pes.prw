#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEDITPANEL.CH"
#INCLUDE "PCPA200.CH"

Static slRefzPesq := .T.

/*/{Protheus.doc} PCPA200PES
Eventos de pesquisa da manutenção de estruturas

@author brunno.costa
@since 19/03/2019
@version P12.1.25
/*/
CLASS PCPA200EVPES FROM FWModelEvent

	METHOD New() CONSTRUCTOR
	METHOD GridLinePreVld()

ENDCLASS

/*/{Protheus.doc} New
Método construtor da classe.

@author brunno.costa
@since 19/03/2019
@version P12.1.25
/*/
METHOD New() CLASS PCPA200EVPES

Return Nil

/*/{Protheus.doc} GridLinePreVld
Pré-validação dos modelos

@author brunno.costa
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
METHOD GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) CLASS PCPA200EVPES

	If cModelID == "SG1_DETAIL"
		If (cAction == "DELETE";
			.Or. cAction == "UNDELETE";
			.Or. (cAction == "SETVALUE" .AND. cId == "G1_TRT");
			.Or. (cAction == "SETVALUE" .AND. cId == "G1_QUANT" .AND. Empty(oSubModel:GetValue("CARGO"))));
			.AND. !IsInCallStack("P200TreeCh")
			slRefzPesq := .T.
		EndIf
	EndIf

Return .T.

/*/{Protheus.doc} PCPA200Pes
Opção de PESQUISA do PCPA200
@author Marcelo Neumann
@since 01/03/2019
@version P12
@param 01 oViewPai, objeto  , view principal do PCPA200
@param 02 cOpcao  , caracter, opção a ser executada: "PESQUISA", "ANTERIOR" ou "PROXIMO"
@return Nil
/*/
Function PCPA200Pes(oViewPai, cOpcao)

	Local lModifyAnt := oViewPai:GetModel():lModify
	Local oModel     := oViewPai:GetModel()

	Default cOpcao := "PESQUISA"

	If !oModel:GetModel("SG1_DETAIL"):VldLineData()
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
@author Marcelo Neumann
@since 01/03/2019
@version P12
@param 01 oViewPai, objeto, view principal do PCPA200
@return Nil
/*/
Static Function LimpaPesq(oViewPai)

	Local oModel := oViewPai:GetModel()

	oModel:GetModel("FLD_PESQUISA"):LoadValue("cCodigo",    CriaVar("G1_COMP"))
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
			oFieldPesq:SetValue("cCodigo", CriaVar("G1_COMP"))
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
@author Marcelo Neumann
@since 01/03/2019
@version P12
@param 01 oViewPai, objeto, view principal do PCPA200
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
	Local cBotaoPrev := IIf(lPrevia, STR0144, STR0145) //"Ocultar Prévia" - "Ver Prévia"

	ConfigTela("ABRE", oViewPai)

	//Determina teclas de atalho
	SetKey( VK_F5, {|| Navega(oViewPai, "ATUAL"   , .T.)} )
	SetKey( VK_F6, {|| Navega(oViewPai, "ANTERIOR", .T.)} )
	SetKey( VK_F7, {|| Navega(oViewPai, "PROXIMO" , .T.)} )

	//Adiciona os botões na tela
	oViewPesq:AddUserButton(cBotaoPrev, "", {|| lChgPrevia := .T., oViewPesq:CloseOwner() }, cBotaoPrev, , , .T.) //"Ocultar Prévia" - "Ver Prévia"
	oViewPesq:AddUserButton(STR0146   , "", {|| Navega(oViewPai, "ANTERIOR", !lPrevia)    }, STR0146   , , , .T.) //"Anterior [F6]"
	oViewPesq:AddUserButton(STR0147   , "", {|| Navega(oViewPai, "PROXIMO" , !lPrevia)    }, STR0147   , , , .T.) //"Próximo [F7]"
	oViewPesq:AddUserButton(STR0148   , "", {|| oViewPesq:CloseOwner()                    }, STR0148   , , , .T.) //"Fechar [ESC]""

	//Prepara ViewExec para abertura da tela
	oViewExec := FWViewExec():New()
	oViewExec:setModel(oModelPai)
	oViewExec:setView(oViewPesq)
	oViewExec:setTitle(STR0149) //"Pesquisa"
	oViewExec:setOperation(MODEL_OPERATION_INSERT)

	If lPrevia
		oViewExec:setReduction(65)
	Else
		oViewExec:setSize(76, 385)
	EndIf

	oViewExec:setButtons({{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0150},{.F.,""},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}) //"Posicionar e Fechar [F5]"
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
@author Marcelo Neumann
@since 01/03/2019
@version P12
@param 01 cIndTela  , caracter, indica se está abrindo ou fechando a tela
@param 02 oViewPai  , objeto  , view principal (PCPA200)
@param 03 nOpViewAnt, numérico, operaação da view principal a ser restaurada no fechamento da tela
@param 04 nOpModelAn, numérico, operaação do modelo principal a ser restaurada no fechamento da tela
@return Nil
/*/
Static Function ConfigTela(cIndTela, oViewPai, nOpViewAnt, nOpModelAn)

	Local oModelPai := oViewPai:GetModel()

	If cIndTela == "ABRE"
		//Ajusta operação do modelo e view anteriores (PCPA200) para Inclusão para que os Get's da pesquisa funcionem adequadamente
		oViewPai:SetOperation(OP_INCLUIR)
		oViewPai:oModel:nOperation := MODEL_OPERATION_INSERT
		oModelPai:GetModel("SG1_MASTER"):SetValue("LPESQUISA",.T.)
	Else
		//Retorna operação do modelo e view anteriores (PCPA200) para visualização
		oModelPai:GetModel("SG1_MASTER"):LoadValue("LPESQUISA",.F.)
		oViewPai:SetOperation(nOpViewAnt)
		oViewPai:oModel:nOperation := nOpModelAn
	EndIf

Return

/*/{Protheus.doc} P200PesMod
Função chamada no PCPA200 para criar o modelo da pesquisa no modelo principal
@author Marcelo Neumann
@since 01/03/2019
@version P12
@param 01 oModel, objeto, modelo onde serão adicionados os modelos de Pesquisa
@return oModel
/*/
Function P200PesMod(oModel)

Return ModelDef(oModel, "SG1_MASTER")

/*/{Protheus.doc} ModelDef
Definição do Modelo (Pesquisa)
@author Marcelo Neumann
@since 01/03/2019
@version P12
@param 01 oModel, objeto  , modelo da tela principal
@param 02 cOwner, caracter, nome do field master/owner
@return oModel
/*/
Static Function ModelDef(oModel, cOwner)

	Local oStruCab := FWFormStruct(1, "SG1", {|cCampo| "|" + AllTrim(cCampo) + "|" $ "|G1_COD|"})
	Local oStruRes := FWFormStruct(1, "SG1", {|cCampo| "|" + AllTrim(cCampo) + "|" $ "|G1_COD|"})

	Default oModel := MPFormModel():New('PCPA200Pes')

	//Altera as estruturas dos modelos
	AltStrMod(@oStruCab, @oStruRes)

	//FLD_PESQUISA - Modelo do cabeçalho
	oModel:AddFields("FLD_PESQUISA", cOwner, oStruCab)
	oModel:GetModel("FLD_PESQUISA"):SetDescription(STR0149) //"Pesquisa"
	oModel:GetModel("FLD_PESQUISA"):SetOnlyQuery(.T.)
	If !Empty(cOwner)
		oModel:GetModel("FLD_PESQUISA"):SetOptional(.T.)
	EndIf

	//GRID_RESULTS - Grid de resultados
	oModel:AddGrid("GRID_RESULTS", "FLD_PESQUISA", oStruRes)
	oModel:GetModel("GRID_RESULTS"):SetDescription(STR0151) //Resultados
	oModel:GetModel("GRID_RESULTS"):SetOnlyQuery(.T.)
	oModel:GetModel("GRID_RESULTS"):SetOptional(.T.)
	oModel:GetModel("GRID_RESULTS"):SetMaxLine(9999)

Return oModel

/*/{Protheus.doc} ViewDef
Definição da View (Pesquisa)
@author Marcelo Neumann
@since 01/03/2019
@version P12
@param 01 oViewOwner, objeto, view da tela principal
@return oView
/*/
Static Function ViewDef(oViewOwner)

	Local oView    := FWFormView():New(oViewOwner)
	Local oStruCab := FWFormStruct(2, "SG1", {|cCampo| "|" + AllTrim(cCampo) + "|" $ "|G1_COD|"})
	Local oStruRes := FWFormStruct(2, "SG1", {|cCampo| "|" + AllTrim(cCampo) + "|" $ "|G1_COD|"})
	Local lPrevia  := oViewOwner:GetModel():GetModel("FLD_PESQUISA"):GetValue("lPrevia")

	//Altera as estruturas dos modelos
	AltStrView(@oStruCab, @oStruRes)

	oView:SetModel(FWLoadModel("PCPA200Pes"))

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
@author Marcelo Neumann
@since 01/03/2019
@version P12
@param 01 oStruCab, object, estrutura do modelo FLD_PESQUISA
@param 02 oStruRes, object, estrutura do modelo GRID_RESULTS
@return Nil
/*/
Static Function AltStrMod(oStruCab, oStruRes)

	//Campos do Cabeçalho
	oStruCab:RemoveField("G1_COD")
	oStruCab:AddField(STR0152                            ,; // [01]  C   Titulo do campo  - "Componente:"
	                  STR0152                            ,; // [02]  C   ToolTip do campo - "Componente:"
	                  "cCodigo"                          ,; // [03]  C   Id do Field
	                  "C"                                ,; // [04]  C   Tipo do campo
	                  GetSx3Cache("G1_COD","X3_TAMANHO") ,; // [05]  N   Tamanho do campo
	                  0                                  ,; // [06]  N   Decimal do campo
	                  NIL                                ,; // [07]  B   Code-block de validação do campo
	                  NIL                                ,; // [08]  B   Code-block de validação When do campo
	                  NIL                                ,; // [09]  A   Lista de valores permitido do campo
	                  .F.                                ,; // [10]  L   Indica se o campo tem preenchimento obrigatório
	                  NIL                                ,; // [11]  B   Code-block de inicializacao do campo
	                  .F.                                ,; // [12]  L   Indica se trata-se de um campo chave
	                  .T.                                ,; // [13]  L   Indica se o campo pode receber valor em uma operação de update
                      .T.                                )  // [14]  L   Indica se o campo é virtual

	oStruCab:AddField(STR0153                            ,; // [01]  C   Titulo do campo  - "Descrição:"
	                  STR0153                            ,; // [02]  C   ToolTip do campo - "Descrição:"
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

	oStruCab:AddField(STR0154                            ,; // [01]  C   Titulo do campo  - "Prévia?"
	                  STR0154                            ,; // [02]  C   ToolTip do campo - "Prévia?"
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

	oStruCab:SetProperty("cCodigo"   , MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, "P200Filtra('cCodigo')"   ))
	oStruCab:SetProperty("cDescricao", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, "P200Filtra('cDescricao')"))

	//Campos da GRID de Resultados
	oStruRes:RemoveField("G1_COD")
	oStruRes:AddField(STR0155                            ,; // [01]  C   Titulo do campo  - "Níveis"
	                  STR0155                            ,; // [02]  C   ToolTip do campo - "Níveis"
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

	oStruRes:AddField(STR0156                            ,; // [01]  C   Titulo do campo  - "Caminho"
	                  STR0156                            ,; // [02]  C   ToolTip do campo - "Caminho"
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

	oStruRes:AddField(STR0018                            ,; // [01]  C   Titulo do campo  - "Descrição"
	                  STR0018                            ,; // [02]  C   ToolTip do campo - "Descrição"
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

	oStruRes:AddField(STR0157                            ,; // [01]  C   Titulo do campo  - "ID do Nó"
                      STR0157                            ,; // [02]  C   ToolTip do campo - "ID do Nó"
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
@author Marcelo Neumann
@since 01/03/2019
@version P12
@param 01 oStruCab, object, estrutura da view V_FLD_PESQUISA
@param 02 oStruRes, object, estrutura da view V_GRID_RESULTS
@return Nil
/*/
Static Function AltStrView(oStruCab, oStruRes)

	//Campos do Cabeçalho
	oStruCab:RemoveField("G1_COD")
	oStruCab:AddField("cCodigo"     ,; // [01]  C   Nome do Campo
	                  "1"           ,; // [02]  C   Ordem
	                  STR0152       ,; // [03]  C   Titulo do campo    - "Componente:"
	                  STR0152       ,; // [04]  C   Descricao do campo - "Componente:"
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
	                  STR0153       ,; // [03]  C   Titulo do campo    - "Descrição:"
	                  STR0153       ,; // [04]  C   Descricao do campo - "Descrição:"
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
	oStruRes:RemoveField("G1_COD")
	oStruRes:AddField("cCaminho"    ,; // [01]  C   Nome do Campo
	                  "1"           ,; // [02]  C   Ordem
	                  STR0156       ,; // [03]  C   Titulo do campo    - "Caminho"
	                  STR0156       ,; // [04]  C   Descricao do campo - "Caminho"
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
	                  STR0018       ,; // [03]  C   Titulo do campo    - "Descrição"
	                  STR0018       ,; // [04]  C   Descricao do campo - "Descrição"
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
	                  STR0155       ,; // [03]  C   Titulo do campo    - "Níveis"
	                  STR0155       ,; // [04]  C   Descricao do campo - "Níveis"
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
@author Marcelo Neumann
@since 01/03/2019
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
@author Marcelo Neumann
@since 01/03/2019
@version P12
@param 01 oViewPai, objeto, view principal (PCPA200)
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
@author Marcelo Neumann
@since 01/03/2019
@version P12
@param 01 oViewPai  , objeto  , view principal (PCPA200)
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
@author Marcelo Neumann
@since 01/03/2019
@version P12
@param 01 oViewPai, objeto  , view principal (PCPA200)
@param 02 cDirecao, caracter, indica a direção para o posicionamento: "ATUAL", "ANTERIOR" ou "PROXIMO"
@return .T.
/*/
Static Function PosicReg(oViewPai, cDirecao)

	Local oGridResul := oViewPai:GetModel():GetModel("GRID_RESULTS")
	Local nLine      := oGridResul:GetLine()
	Local nPadMaxCmp := P200GPdMax()

	//Grava regitros da grid de detalhes atual
	P200GravAl(oViewPai:GetModel())

	//Seta maximo de componentes exibidos por padrao para 3
	//Mantido no fonte como tecnica "Carta na manga de melhoria de performance" a pedidos do PO, entretanto "em desuso". Para uso, reduzir snPadMaxCmp para X componentes.
	P200SPdMax(999999) //3

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
	Processa({|| PosicTree(oViewPai)}, STR0053, STR0158, .F.) //"Aguarde..." - "Posicionando..."

	//Seta maximo de componentes exibidos por padrao para default
	P200SPdMax(nPadMaxCmp)

Return .T.

/*/{Protheus.doc} PosicTree()
Busca e posiciona o registro na Tree de acordo com o registro posicionado no modelo GRID_RESULTS
@author Marcelo Neumann
@since 01/03/2019
@version P12
@param 01 oViewPai , objeto, view principal (PCPA200)
@return lPosicionou, lógica, indica se consiguiu posicionar no registro desejado
/*/
Static Function PosicTree(oViewPai)

	Local oMdlMaster  := oViewPai:GetModel():GetModel("SG1_MASTER")
	Local oMdlDetail  := oViewPai:GetModel():GetModel("SG1_DETAIL")
	Local oGridResul  := oViewPai:GetModel():GetModel("GRID_RESULTS")
	Local aCaminho    := StrToKArr2(oGridResul:GetValue("cCaminho"), " -> ")
	Local nIndNivel   := 0
	Local cCod        := ""
	Local cComp       := ""
	Local cTrt        := ""
	Local cNodeID     := oGridResul:GetValue("NodeID")
	Local lPosicionou := .T.

	//Seta regua infinita
	ProcRegua(0)

	//Determina oViewPai como ativa atual para manipular a Tree
	FwViewActive(oViewPai)

	//Verifica se já foi posicionado nesse registro antes
	If Empty(cNodeID)
		//Posiciona no pai da Tree
		P200TrSeek(oMdlMaster:GetValue("CARGO"), , .T.)

		//Percorre os componentes do "caminho" selecionado
		For nIndNivel := 1 To Val(oGridResul:GetValue("cNiveis"))
			cCod  := AllTrim(aCaminho[nIndNivel])
			cComp := AllTrim(aCaminho[nIndNivel + 1])
			cTrt  := ExtraiTrt(@cComp)

			ExtraiTrt(@cCod)

			//Busca o registro na Grid do PCPA200 para pegar o Cargo do mesmo na Tree
			If oMdlDetail:SeekLine({{"G1_COD" , cCod  }, ;
									{"G1_COMP", cComp }, ;
									{"G1_TRT" , cTrt  } }, .F., .T.)

				//Posiciona a tree no cargo do registro
				Processa({|| lPosicionou := P200TrSeek(oMdlDetail:GetValue("CARGO"), , .T.)}, STR0053, STR0158, .F.) //"Aguarde..." - "Posicionando..."

				If !lPosicionou
					Exit
				EndIf
			EndIf
		Next nIndNivel

		//Grava o NodeID desse registro para não precisar buscar novamente depois
		GravaNode(oViewPai)
	Else
		//Se já foi posicionado nesse registro, vai direto ao nó correspondente
		Processa({|| lPosicionou := P200TrSeek( , cNodeID, .T.)}, STR0053, STR0158, .F.) //"Aguarde..." - "Posicionando..."
	EndIf

	If !lPosicionou
		Help( ,  , "Help", ,  I18N(STR0240, {cCod, cComp}),; //"O registro #1[ATRIBUTO]# > #2[ATRIBUTO]# não pode ser acessado."
			 1, 0, , , , , , {I18N(STR0241, {cComp})})       //"Verifique se o componente #1[ATRIBUTO]# pode ser acessado."
	EndIf

Return lPosicionou

/*/{Protheus.doc} GravaNode
Grava o ID do nó para posteriormente não precisar refazer a busca
@author Marcelo Neumann
@since 01/03/2019
@version P12
@param 01 oViewPai, objeto, view principal (PCPA200)
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
	oGridResul:LoadValue("NodeID", P200GtNoID())
	oGridResul:SetNoUpdateLine(.T.)

	If nOpModelAn == MODEL_OPERATION_DELETE
		ConfigTela("FECHA", oViewPai, nOpViewAnt, nOpModelAn)
	EndIf

Return

/*/{Protheus.doc} ExtraiTrt
Extrai o TRT do produto pois estará concatenado: PRODUTO (TRT)
@author Marcelo Neumann
@since 01/03/2019
@version P12
@param 01 cCod, caracter, código do produto que terá o TRT extraído e retornado
@return cTrt, caracter, TRT extraido de cCod
/*/
Static Function ExtraiTrt(cCod)

	Local cTrt    := CriaVar('G1_TRT')
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

/*/{Protheus.doc} P200Filtra()
Processa a pesquisa dos registros de acordo com os filtros informados
@author Marcelo Neumann
@since 01/03/2019
@version P12
@return lAbort, lógico, indica se a operação foi cancelada pelo usuário
/*/
Function P200Filtra()

	Local lAbort := .F.

	Processa({|| ProcFiltro() }, STR0053, STR0159, lAbort) //"Aguarde..." - "Pesquisando as opções..."

Return !lAbort

/*/{Protheus.doc} ProcFiltro()
Processa a busca dos registros e alimenta a Grid com o resultado
@author Marcelo Neumann
@since 01/03/2019
@version P12
@return lAbort
/*/
Static Function ProcFiltro()

	Local oView      := FwViewActive()
	Local oModel     := FWModelActive()
	Local oGridResul := oModel:GetModel("GRID_RESULTS")
	Local cProdPai   := oModel:GetModel("SG1_MASTER"):GetValue("G1_COD")
	Local cCodigo    := oModel:GetModel("FLD_PESQUISA"):GetValue("cCodigo")
	Local cDescricao := oModel:GetModel("FLD_PESQUISA"):GetValue("cDescricao")
	Local lPrevia    := oModel:GetModel("FLD_PESQUISA"):GetValue("lPrevia")
	Local cRevisao   := P200GetRvT()
	Local lFiltraVen := IIf(P200GetF12("EXIBE_VENCIDOS") == 1, .F., .T.)
	Local cCaminho   := ""
	Local aPaths     := {}
	Local nInd       := 0
	Local lAbort     := .F.

	//Seta regua infinita
	ProcRegua(0)

	//Se Código ou Descrição está preenchido, faz a busca dos registros
	If !Empty(cCodigo) .Or. !Empty(cDescricao)
		//Faz a pesquisa no banco de dados carregando o array aPaths
		Processa({|| BuscaRegs(cProdPai, cRevisao, lFiltraVen, cCodigo, cDescricao, @aPaths) }, STR0053, STR0160, lAbort) //"Aguarde..." - "Lendo as opções na base de dados..."
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
@author Marcelo Neumann
@since 01/03/2019
@version P12
@param 01 cProdPai  , caracter, código do produto pai da estrutura, de onde partirá a busca
@param 02 cRevisao  , caracter, revisão do produto pai da estrutura, de onde partirá a busca
@param 03 lFiltraVen, lógico  , indica se deverá filtrar os componentes vencidos (F12)
@param 04 cBuscaCod , caracter, código do componente a ser procurado
@param 05 cBuscaDesc, caracter, parte da descrição do componente a ser procurada
@param 06 aPaths    , array   , array com os caminhos do componente na estrutura (passado por referência):
								aPaths[1] = PathCod  - Caminho do pai até o componente (PAI -> ... -> COMPONENTE)
								aPaths[2] = DescProd - Descrição do componente
								aPaths[3] = Nivel    - Nível onde o mesmo foi encontrado
@return lAchou, lógico, indica se a busca encontrou algum registro
/*/
Static Function BuscaRegs(cProdPai, cRevisao, lFiltraVen, cBuscaCod, cBuscaDesc, aPaths)

	Local cAliasTop    := GetNextAlias()
	Local cBanco       := TCGetDB()
	Local cQuery       := ""
	Local cQryUniAll   := ""
	Local lAchou       := .F.
	Local lPCPREVATU   := SuperGetMV("MV_REVFIL",.F.,.F.)  
	Local lUsaSBZ      := SuperGetMV("MV_ARQPROD",.F.,"SB1")=='SBZ'
	Local oTempTable   := criaTmpTRB()

	//Tratamentos de SQL Injection
	cBuscaCod  := StrTran(cBuscaCod,  "'", "")
	cBuscaDesc := StrTran(cBuscaDesc, "'", "")

	//Seta regua infinita
	ProcRegua(0)

	slRefzPesq := .F.

	cQuery := " WITH EstruturaRecursiva(G1_COMP, B1_DESC, Nivel, PathCod)"
	cQuery += " AS ("
	cQuery +=      " SELECT SG1_Base.G1_COMP,"
	cQuery +=             " SB1_Prod.B1_DESC,"
	cQuery +=             " 1 AS Nivel,"
	cQuery +=             " Cast( Trim(SG1_Base.G1_COD) || ' -> ' || Trim(SG1_Base.G1_COMP) || ' (' || Trim(SG1_Base.G1_TRT) || ')' AS VarChar(8000) ) AS PathCod"
	cQuery +=        " FROM ( cQryMemFro ) SG1_Base"
	cQuery +=       " INNER JOIN " + RetSqlName( "SB1" ) + " SB1_Prod"
	cQuery +=          " ON SB1_Prod.B1_COD = SG1_Base.G1_COMP"
	cQuery +=         " AND SB1_Prod.D_E_L_E_T_ = ' '"
	cQuery +=         " AND SB1_Prod.B1_FILIAL = '" + xFilial("SB1") + "'"
	cQuery +=       " WHERE ((SG1_Base.G1_COD = '" + cProdPai + "'"
	cQuery +=         " AND SG1_Base.G1_REVINI <= '" + cRevisao + "'"
	cQuery +=         " AND SG1_Base.G1_REVFIM >= '" + cRevisao + "'))"

	//Desconsidera componentes inválidos
	If lFiltraVen
		cQuery +=     " AND SG1_Base.G1_INI <= '" + DToS(dDataBase) + "'"
		cQuery +=     " AND SG1_Base.G1_FIM >= '" + DToS(dDataBase) + "'"
	EndIf

	cQryUniAll +=       " UNION ALL"
	cQryUniAll +=      " SELECT SG1_Filho.G1_COMP,"
	cQryUniAll +=             " SB1_Comp.B1_DESC,"
	cQryUniAll +=             " Qry_Recurs.Nivel + 1 AS Nivel,"
	cQryUniAll +=             " Cast( (Qry_Recurs.PathCod || ' -> ' || Trim(SG1_Filho.G1_COMP) || ' (' || Trim(SG1_Filho.G1_TRT) || ')') AS VarChar(8000) ) PathCod"
	cQryUniAll +=        " FROM " + RetSqlName( "SG1" ) + " SG1_Filho "
	cQryUniAll +=       " INNER JOIN EstruturaRecursiva Qry_Recurs"
	cQryUniAll +=          " ON Qry_Recurs.G1_COMP = SG1_Filho.G1_COD"
	cQryUniAll +=       " INNER JOIN " + RetSqlName( "SB1" ) + " SB1_Comp"
	cQryUniAll +=          " ON SB1_Comp.B1_COD = SG1_Filho.G1_COMP"
	cQryUniAll +=         " AND SB1_Comp.D_E_L_E_T_ = ' '"
	cQryUniAll +=         " AND SB1_Comp.B1_FILIAL = '" + xFilial("SB1") + "'"
	cQryUniAll +=       " INNER JOIN " + RetSqlName( "SB1" ) + " SB1_Pai"
	cQryUniAll +=          " ON SB1_Pai.B1_COD = SG1_Filho.G1_COD"
	cQryUniAll +=         " AND SB1_Pai.D_E_L_E_T_ = ' '"
	cQryUniAll +=         " AND SB1_Pai.B1_FILIAL = '" + xFilial("SB1") + "'"
	if !lUsaSBZ .OR. !lPCPREVATU
		cQryUniAll +=         " AND SB1_Pai.B1_REVATU >= SG1_Filho.G1_REVINI"
		cQryUniAll +=         " AND SB1_Pai.B1_REVATU <= SG1_Filho.G1_REVFIM"
	else
		cQryUniAll += " INNER JOIN " + RetSqlName("SBZ") + " SBZ_Pai ON SBZ_Pai.BZ_COD = SG1_Filho.G1_COD"
		cQryUniAll += " AND SBZ_Pai.BZ_FILIAL = '" + xFilial("SBZ") + "'"
		cQryUniAll += " AND SBZ_Pai.BZ_REVATU >= SG1_Filho.G1_REVINI "
		cQryUniAll += " AND SBZ_Pai.BZ_REVATU <= SG1_Filho.G1_REVFIM "
		cQryUniAll += " AND SBZ_Pai.D_E_L_E_T_ = '' "
	endif
	
	cQryUniAll +=       " WHERE SG1_Filho.D_E_L_E_T_ = ' '"
	cQryUniAll +=         " AND SG1_Filho.G1_FILIAL  = '" + xFilial("SG1") + "' "

	//Desconsidera componentes inválidos
	If lFiltraVen
		cQryUniAll +=     " AND SG1_Filho.G1_INI <= '" + DToS(dDataBase) + "'"
		cQryUniAll +=     " AND SG1_Filho.G1_FIM >= '" + DToS(dDataBase) + "'"
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
		cQuery += " AND Resultado.G1_COMP = '" + cBuscaCod + "'"
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

	ElseIf ! "ORACLE" $ cBanco
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
@author brunno.costa
@since 19/03/2019
@version 1.0
@param 01 - cQryUniAll, caracter, trecho da query UNION ALL utilizada para copia em MSSQL
@param 02 - cQuery    , caracter, query recursiva de pesquisa original - retornada por referencia
@param 03 - oTempTable, objeto  , objeto com a tabela temporaria
@return oTempTable	- Objeto da tabela temporária.
/*/
Static Function PesMemoria(cQryUniAll, cQuery, oTempTable)

	Local cBanco       := TCGetDB()
	Local nIndAux      := 0
	Local cQryMemFro   := ""
	Local cQryMemCpl   := ""
	Local cRecnos      := ""
	Local oModel       := FWModelActive()
	Local oEvent       := PCPA200gtMdlEvent( oModel, "PCPA200EVDEF")
	Local oModelGrAt   := oModel:GetModel("SG1_DETAIL")
	Local cAliasTRB    := oTempTable:GetAlias()
	Local oLines       := oEvent:oDadosCommit["oLines"]
	Local oFields      := oEvent:oDadosCommit["oFields"]
	Local oLinDel      := oEvent:oDadosCommit["oLinDel"]
	Local aLinhasMem   := oLines:GetNames()

	cQryMemFro := " SELECT G1_FILIAL, "
	cQryMemFro +=        " G1_COD, "
	cQryMemFro +=        " G1_REVINI, "
	cQryMemFro +=        " G1_REVFIM, "
	cQryMemFro +=        " G1_COMP, "
	cQryMemFro +=        " G1_TRT, "
	cQryMemFro +=        " G1_INI, "
	cQryMemFro +=        " G1_FIM "
	cQryMemFro +=   " FROM " + RetSqlName("SG1") + " "
	cQryMemFro +=  " WHERE D_E_L_E_T_ = ' ' "
	cQryMemFro +=    " AND G1_FILIAL  = '" + xFilial("SG1") + "' "
	cQryMemFro += " X_UpdRecnos_X "
	cQryMemFro += " UNION ALL "
	cQryMemFro += " SELECT G1_FILIAL, "
	cQryMemFro +=        " G1_COD, "
	cQryMemFro +=        " '   ' G1_REVINI, "
	cQryMemFro +=        " 'ZZZ' G1_REVFIM, "
	cQryMemFro +=        " G1_COMP, "
	cQryMemFro +=        " G1_TRT, "
	cQryMemFro +=        " G1_INI, "
	cQryMemFro +=        " G1_FIM "
	cQryMemFro +=   " FROM " + oTempTable:GetRealName()

	//Analise dos dados no JSON com os dados para commit - Dados alterados ainda nao gravados no banco
	For nIndAux := 1 to Len(aLinhasMem)
		If oLines[aLinhasMem[nIndAux]] != Nil
			//Tratamento de exclusoes
			If oLinDel[aLinhasMem[nIndAux]]
				If Empty(cRecnos)
					cRecnos := cValToChar(oLines[aLinhasMem[nIndAux]][oFields["NREG"]])
				Else
					cRecnos += ", " + cValToChar(oLines[aLinhasMem[nIndAux]][oFields["NREG"]])
				EndIf
			Else
				//Tratamento de inclusoes
				RecLock(cAliasTRB, .T.)
				(cAliasTRB)->G1_FILIAL := xFilial("SG1")
				(cAliasTRB)->G1_COD    := oLines[aLinhasMem[nIndAux]][oFields["G1_COD"]]
				(cAliasTRB)->G1_REVINI := oLines[aLinhasMem[nIndAux]][oFields["G1_REVINI"]]
				(cAliasTRB)->G1_REVFIM := oLines[aLinhasMem[nIndAux]][oFields["G1_REVFIM"]]
				(cAliasTRB)->G1_INI    := oLines[aLinhasMem[nIndAux]][oFields["G1_INI"]]
				(cAliasTRB)->G1_FIM    := oLines[aLinhasMem[nIndAux]][oFields["G1_FIM"]]
				(cAliasTRB)->G1_COMP   := oLines[aLinhasMem[nIndAux]][oFields["G1_COMP"]]
				(cAliasTRB)->G1_TRT    := oLines[aLinhasMem[nIndAux]][oFields["G1_TRT"]]
				(cAliasTRB)->(MsUnLock())
			EndIf
		EndIf
	Next

	//Analise dos dados na SG1_DETAIL - Dados alterados(ou nao) exibidos na tela
	For nIndAux := 1 to oModelGrAt:Length(.F.)
		If !Empty(oModelGrAt:GetValue("G1_COD", nIndAux)) .AND. (oModelGrAt:IsUpdated(nIndAux) .OR. oModelGrAt:IsDeleted(nIndAux))
			//Tratamento de exclusoes
			If oModelGrAt:IsDeleted(nIndAux)
				If Empty(cRecnos)
					cRecnos := cValToChar(oModelGrAt:GetValue("NREG", nIndAux))
				Else
					cRecnos += ", " + cValToChar(oModelGrAt:GetValue("NREG", nIndAux))
				EndIf
			Else
				//Tratamento de inclusoes
				RecLock(cAliasTRB, .T.)
				(cAliasTRB)->G1_FILIAL := xFilial("SG1")
				(cAliasTRB)->G1_COD    := oModelGrAt:GetValue("G1_COD"   , nIndAux)
				(cAliasTRB)->G1_REVINI := oModelGrAt:GetValue("G1_REVINI", nIndAux)
				(cAliasTRB)->G1_REVFIM := oModelGrAt:GetValue("G1_REVFIM", nIndAux)
				(cAliasTRB)->G1_INI    := oModelGrAt:GetValue("G1_INI"   , nIndAux)
				(cAliasTRB)->G1_FIM    := oModelGrAt:GetValue("G1_FIM"   , nIndAux)
				(cAliasTRB)->G1_COMP   := oModelGrAt:GetValue("G1_COMP"  , nIndAux)
				(cAliasTRB)->G1_TRT    := oModelGrAt:GetValue("G1_TRT"   , nIndAux)
				(cAliasTRB)->(MsUnLock())
			EndIf
		EndIf
	Next

	//SQL SERVER
	If "MSSQL" $ cBanco
		cQryMemCpl := StrTran(cQryUniAll, "FROM " + RetSqlName( "SG1" ) + " SG1_Filho",;
																			"FROM (SELECT G1_FILIAL, G1_COD, '   ' G1_REVINI, 'ZZZ' G1_REVFIM, G1_COMP, G1_TRT, G1_INI, G1_FIM " +;
																			      "FROM " + oTempTable:GetRealName() + ") SG1_Filho")

		cQryMemCpl := StrTran(cQryMemCpl, "WHERE SG1_Filho.D_E_L_E_T_ = ' '", "")
		cQryUniAll +=         " SG1_Filho.X_UpdRecnos_X "
		cQryUniAll +=         " AND SG1_Filho.D_E_L_E_T_ = ' ' "

	//ORACLE, POSTGRES
	Else
		cQryUniAll := StrTran(cQryUniAll, "SG1_Filho.D_E_L_E_T_ = ' '", "1=1")
		cQryUniAll := StrTran(cQryUniAll, "FROM " + RetSqlName( "SG1" ) + " SG1_Filho",;
																			"FROM (SELECT G1_FILIAL, G1_COD, G1_REVINI, G1_REVFIM, G1_COMP, G1_TRT, G1_INI, G1_FIM "+;
																			      " FROM " + RetSqlName( "SG1" ) +;
																						" WHERE D_E_L_E_T_ = ' ' " +;
																						" AND G1_FILIAL = '" + xFilial("SG1") + "' " +;
																						" X_UpdRecnos_X " +;
																						" UNION " +;
																						" SELECT G1_FILIAL, G1_COD, '   ' G1_REVINI, 'ZZZ' G1_REVFIM, G1_COMP, G1_TRT, G1_INI, G1_FIM " +;
																			      " FROM " + oTempTable:GetRealName() + ") SG1_Filho")
	EndIf

	cQuery     += cQryUniAll + cQryMemCpl
	cQuery     := StrTran(cQuery, "cQryMemFro", cQryMemFro)

	If !Empty(cRecnos)
		cQuery := StrTran(cQuery, "SG1_Filho.X_UpdRecnos_X", " AND SG1_Filho.R_E_C_N_O_ NOT IN (" + cRecnos + ") ")
		cQuery := StrTran(cQuery, "X_UpdRecnos_X", " AND R_E_C_N_O_ NOT IN (" + cRecnos + ") ")
	Else
		cQuery := StrTran(cQuery, "SG1_Filho.X_UpdRecnos_X", "")
		cQuery := StrTran(cQuery, "X_UpdRecnos_X", "")
	EndIf
Return

/*/{Protheus.doc} criaTmpTRB
Cria a tabela temporária conforme a estrutura da tabela SG1
@author brunno.costa
@since 19/03/2019
@version 1.0
@return oTempTable	- Objeto da tabela temporária.
/*/
Static Function criaTmpTRB()
	Local oTempTable := FwTemporaryTable():New()

	oTempTable:SetFields(SG1->(dbStruct()))
	oTempTable:AddIndex("01",{"G1_FILIAL","G1_COD","G1_COMP","G1_TRT", "G1_REVINI", "G1_REVFIM"})
	oTempTable:Create()

Return oTempTable
