#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PCPA134.CH"
#INCLUDE "FWEDITPANEL.CH"

Static slMarca     := .F.
Static slPCPREVATU := FindFunction('PCPREVATU')  .AND.  SuperGetMv("MV_REVFIL",.F.,.F.)
Static scCRLF      := Chr(13) + Chr(10)
Static soRecNo
Static soViewPai

/*/{Protheus.doc} PCPA134Alt
Abre uma tela com a consulta da malha de distribuição do produto
@author Marcelo Neumann
@since 25/01/2019
@version P12
@param 01 oViewPai, object, objeto da View Principal
@return lRet, logical, identifica se a View foi aberta
/*/
Function PCPA134Alt(oViewPai)

	Local oMdlAltera := NIL
	Local oModelPai  := oViewPai:GetModel()
	Local cComp      := ""
	Local aAreaSG1   := SG1->(GetArea())
	Local aButtons   := { {.F.,Nil    },{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0068},; //"Modificar"
	                      {.T.,STR0075},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil    } } //"Cancelar"
	Local lRet       := .T.

	Default lAutoMacao := .F.

	IF !lAutoMacao
		cComp := oModelPai:GetModel("GRID_ONDE"):GetValue("G1_COMP")
	ENDIF

	If !Empty(cComp)
		oMdlAltera := FWLoadModel("PCPA134Alt")
		SG1->(dbSetOrder(2))
		SG1->(MsSeek(xFilial("SG1") + cComp))
		oMdlAltera:SetOperation(MODEL_OPERATION_UPDATE)
		oMdlAltera:Activate()

		soViewPai := oViewPai

		//Carrega a Grid com os dados já carregados no modelo principal
		CarregaMdl(oModelPai, oMdlAltera)

		//Variável de controle da opção de Marcar Todos
		slMarca := .F.

		FWExecView(STR0069                           , ; //Titulo da janela - "Modificar Geral"
		           'PCPA134Alt'                      , ; //Nome do programa-fonte
		           MODEL_OPERATION_UPDATE            , ; //Indica o código de operação
		           NIL                               , ; //Objeto da janela em que o View deve ser colocado
		           { || .T. }                        , ; //Bloco de validação do fechamento da janela
		           { |oView| lRet := BotaoOk(oView) }, ; //Bloco de validação do botão OK
		           55                                , ; //Percentual de redução da janela
		           aButtons                          , ; //Botões que serão habilitados na janela
		           { |oView| lRet := .F., SetModify(oView,.F.) }, ; //Bloco de validação do botão Cancelar
		           NIL                               , ; //Identificador da opção do menu
		           NIL                               , ; //Indica o relacionamento com os botões da tela
		           oMdlAltera)                         //Model que será usado pelo View

		oMdlAltera:DeActivate()
		oMdlAltera:Destroy()

		//Remove lock's - Fonte PCPA200EVDEF
		SG1UnLockR(,,soRecNo)
		soRecNo := Nil
	Else
		lRet := .F.
		Help( ,  , "Help", ,  STR0072,; //"Componente não selecionado."
		     1, 0, , , , , , {STR0073}) //"Selecione o componente a ser Modificado."
	EndIf

	SG1->(RestArea(aAreaSG1))

Return lRet

/*/{Protheus.doc} ModelDef
Definição do Modelo
@author Marcelo Neumann
@since 25/01/2019
@version P12
@return oModel
/*/
Static Function ModelDef()

	Local oModel     := MPFormModel():New('PCPA134Alt')
	Local oStrMaster := FWFormStruct(1, "SG1", {|cCampo| "|" + AllTrim(cCampo) + "|" $ "|G1_COMP|G1_DESC|"})
	Local oStrDetail := FWFormStruct(1, "SG1", {|cCampo| "|" + AllTrim(cCampo) + "|" $ "|G1_COD|G1_COMP|G1_TRT|G1_QUANT|G1_REVINI|G1_REVFIM|G1_INI|G1_FIM|G1_LISTA|G1_LOCCONS|"})
	Local oStruErro  := GetStruErr(1)

	//Altera os campos da estrutura
	AltStruMod(@oStrMaster, @oStrDetail)

	//FLD_COMPONENTE - Modelo do Cabeçalho
	oModel:AddFields("FLD_COMPONENTE", /*cOwner*/, oStrMaster)
	oModel:GetModel("FLD_COMPONENTE"):SetDescription(STR0070) //"Modificar Geral - Mestre"
	oModel:GetModel("FLD_COMPONENTE"):SetOnlyQuery(.T.)

	//GRID_PRODUTOS - Modelo da Grid
	oModel:AddGrid("GRID_PRODUTOS", "FLD_COMPONENTE", oStrDetail)
	oModel:GetModel("GRID_PRODUTOS"):SetDescription(STR0071) //"Modificar Geral - Detalhe"
	oModel:GetModel("GRID_PRODUTOS"):SetOnlyQuery(.T.)

	//GRID_ERROS - Modelo para exibir erros ocorridos na modificação das estruturas.
	oModel:AddGrid("GRID_ERROS","FLD_COMPONENTE",oStruErro)
	oModel:GetModel("GRID_ERROS"):SetDescription(STR0081) //"Modificar geral - Erros do processamento."
	oModel:GetModel("GRID_ERROS"):SetOptional(.T.)
	oModel:GetModel("GRID_ERROS"):SetOnlyQuery(.T.)

	oModel:SetDescription(STR0069) //"Modificar Geral"
	oModel:SetPrimaryKey({})

Return oModel

/*/{Protheus.doc} ViewDef
Definição da View
@author Marcelo Neumann
@since 25/01/2019
@version P12
@return oView
/*/
Static Function ViewDef()

	Local oView      := FWFormView():New()
	Local oStrMaster := FWFormStruct(2, "SG1", {|cCampo| "|" + AllTrim(cCampo) + "|" $ "|G1_COMP|G1_DESC|"})
	Local oStrDetail := FWFormStruct(2, "SG1", {|cCampo| "|" + AllTrim(cCampo) + "|" $ "|G1_COD|G1_TRT|G1_QUANT|G1_REVINI|G1_REVFIM|G1_INI|G1_FIM|G1_LISTA|G1_LOCCONS|"})

	//Altera os campos da estrutura para a view
	AltStrView(@oStrMaster, @oStrDetail)

	oView:SetModel(FWLoadModel("PCPA134Alt"))

	//V_FLD_COMPONENTE - View do Cabeçalho
	oView:AddField("V_FLD_COMPONENTE", oStrMaster, "FLD_COMPONENTE")

	//V_GRID_PRODUTOS - View da Grid com os produtos que serão alterados
	oView:AddGrid("V_GRID_PRODUTOS", oStrDetail, "GRID_PRODUTOS")

	//Divisão da tela
	oView:CreateHorizontalBox("BOX_HEADER", 135, , .T.)
	oView:CreateHorizontalBox("BOX_GRID"  , 100)

	//Relaciona a SubView com o Box
	oView:SetOwnerView("V_FLD_COMPONENTE", 'BOX_HEADER')
	oView:SetOwnerView("V_GRID_PRODUTOS" , 'BOX_GRID')

	//Função chamada após ativar a View
	oView:SetAfterViewActivate({|oView| AfterView(oView)})

	//Função chamada após sair do campo
	oView:SetFieldAction("NQUANT" , { |oView| SetModify(oView, .F.) })
	oView:SetFieldAction("DINI"   , { |oView| SetModify(oView, .F.) })
	oView:SetFieldAction("DFIM"   , { |oView| SetModify(oView, .F.) })
	oView:SetFieldAction("LALTERA", { |oView| SetModify(oView, .F.) })

Return oView

/*/{Protheus.doc} AltStruMod
Edita os campos da estrutura do Model
@author Marcelo Neumann
@since 25/01/2019
@version P12
@param 01 oStrMaster, object, estrutura do modelo V_FLD_COMPONENTE
@param 02 oStrDetail, object, estrutura do modelo V_GRID_PRODUTOS
@return Nil
/*/
Static Function AltStruMod(oStrMaster, oStrDetail)

	//Adiciona novos campos
	oStrMaster:AddField(RetTitle("G1_QUANT")                 ,; // [01]  C   Titulo do campo
	                    RetTitle("G1_QUANT")                 ,; // [02]  C   ToolTip do campo
	                    "NQUANT"                             ,; // [03]  C   Id do Field
	                    GetSx3Cache("G1_QUANT","X3_TIPO")    ,; // [04]  C   Tipo do campo
	                    GetSx3Cache("G1_QUANT","X3_TAMANHO") ,; // [05]  N   Tamanho do campo
	                    GetSx3Cache("G1_QUANT","X3_DECIMAL") ,; // [06]  N   Decimal do campo
	                    NIL                                  ,; // [07]  B   Code-block de validação do campo
	                    NIL                                  ,; // [08]  B   Code-block de validação When do campo
	                    NIL                                  ,; // [09]  A   Lista de valores permitido do campo
	                    .F.                                  ,; // [10]  L   Indica se o campo tem preenchimento obrigatório
	                    NIL                                  ,; // [11]  B   Code-block de inicializacao do campo
	                    .F.                                  ,; // [12]  L   Indica se trata-se de um campo chave
	                    .F.                                  ,; // [13]  L   Indica se o campo não pode receber valor em uma operação de update
	                    .T.)                                    // [14]  L   Indica se o campo é virtual

	oStrMaster:AddField(RetTitle("G1_INI")                   ,; // [01]  C   Titulo do campo
	                    RetTitle("G1_INI")                   ,; // [02]  C   ToolTip do campo
	                    "DINI"                               ,; // [03]  C   Id do Field
	                    GetSx3Cache("G1_INI","X3_TIPO")      ,; // [04]  C   Tipo do campo
	                    GetSx3Cache("G1_INI","X3_TAMANHO")   ,; // [05]  N   Tamanho do campo
	                    GetSx3Cache("G1_INI","X3_DECIMAL")   ,; // [06]  N   Decimal do campo
	                    NIL                                  ,; // [07]  B   Code-block de validação do campo
	                    NIL                                  ,; // [08]  B   Code-block de validação When do campo
	                    NIL                                  ,; // [09]  A   Lista de valores permitido do campo
	                    .F.                                  ,; // [10]  L   Indica se o campo tem preenchimento obrigatório
	                    NIL                                  ,; // [11]  B   Code-block de inicializacao do campo
	                    .F.                                  ,; // [12]  L   Indica se trata-se de um campo chave
	                    .F.                                  ,; // [13]  L   Indica se o campo não pode receber valor em uma operação de update
	                    .T.)                                    // [14]  L   Indica se o campo é virtual

	oStrMaster:AddField(RetTitle("G1_FIM")                   ,; // [01]  C   Titulo do campo
	                    RetTitle("G1_FIM")                   ,; // [02]  C   ToolTip do campo
	                    "DFIM"                               ,; // [03]  C   Id do Field
	                    GetSx3Cache("G1_FIM","X3_TIPO")      ,; // [04]  C   Tipo do campo
	                    GetSx3Cache("G1_FIM","X3_TAMANHO")   ,; // [05]  N   Tamanho do campo
	                    GetSx3Cache("G1_FIM","X3_DECIMAL")   ,; // [06]  N   Decimal do campo
	                    NIL                                  ,; // [07]  B   Code-block de validação do campo
	                    NIL                                  ,; // [08]  B   Code-block de validação When do campo
	                    NIL                                  ,; // [09]  A   Lista de valores permitido do campo
	                    .F.                                  ,; // [10]  L   Indica se o campo tem preenchimento obrigatório
	                    NIL                                  ,; // [11]  B   Code-block de inicializacao do campo
	                    .F.                                  ,; // [12]  L   Indica se trata-se de um campo chave
	                    .F.                                  ,; // [13]  L   Indica se o campo não pode receber valor em uma operação de update
	                    .T.)                                    // [14]  L   Indica se o campo é virtual

	oStrDetail:AddField(STR0076                              ,; // [01]  C   Titulo do campo  - "Altera?"
	                    STR0076                              ,; // [02]  C   ToolTip do campo - "Altera?"
	                    "LALTERA"                            ,; // [03]  C   Id do Field
	                    "L"                                  ,; // [04]  C   Tipo do campo
	                    1                                    ,; // [05]  N   Tamanho do campo
	                    0                                    ,; // [06]  N   Decimal do campo
	                    FWBuildFeature(STRUCT_FEATURE_VALID,"A134AltVld()"),; // [07]  B   Code-block de validação do campo
	                    NIL                                  ,; // [08]  B   Code-block de validação When do campo
	                    NIL                                  ,; // [09]  A   Lista de valores permitido do campo
	                    .F.                                  ,; // [10]  L   Indica se o campo tem preenchimento obrigatório
	                    { || .F. }                           ,; // [11]  B   Code-block de inicializacao do campo
	                    .F.                                  ,; // [12]  L   Indica se trata-se de um campo chave
	                    .F.                                  ,; // [13]  L   Indica se o campo não pode receber valor em uma operação de update
	                    .T.)                                    // [14]  L   Indica se o campo é virtual

	oStrDetail:AddField(RetTitle("B1_DESC")                  ,; // [01]  C   Titulo do campo
	                    RetTitle("B1_DESC")                  ,; // [02]  C   ToolTip do campo
	                    "CDESCPAI"                           ,; // [03]  C   Id do Field
	                    "C"                                  ,; // [04]  C   Tipo do campo
	                    GetSx3Cache("B1_DESC","X3_TAMANHO")  ,; // [05]  N   Tamanho do campo
	                    0                                    ,; // [06]  N   Decimal do campo
	                    NIL                                  ,; // [07]  B   Code-block de validação do campo
	                    NIL                                  ,; // [08]  B   Code-block de validação When do campo
	                    NIL                                  ,; // [09]  A   Lista de valores permitido do campo
	                    .F.                                  ,; // [10]  L   Indica se o campo tem preenchimento obrigatório
	                    NIL                                  ,; // [11]  B   Code-block de inicializacao do campo
	                    NIL                                  ,; // [12]  L   Indica se trata-se de um campo chave
	                    .T.                                  ,; // [13]  L   Indica se o campo não pode receber valor em uma operação de update
	                    .T.)                                    // [14]  L   Indica se o campo é virtual

	oStrDetail:AddField("RECNO"                              ,; // [01]  C   Titulo do campo  - "Altera?"
	                    "RECNO"                              ,; // [02]  C   ToolTip do campo - "Altera?"
	                    "RECNO"                              ,; // [03]  C   Id do Field
	                    "N"                                  ,; // [04]  C   Tipo do campo
	                    10                                   ,; // [05]  N   Tamanho do campo
	                    0                                    ,; // [06]  N   Decimal do campo
	                    NIL                                  ,; // [07]  B   Code-block de validação do campo
	                    NIL                                  ,; // [08]  B   Code-block de validação When do campo
	                    NIL                                  ,; // [09]  A   Lista de valores permitido do campo
	                    .F.                                  ,; // [10]  L   Indica se o campo tem preenchimento obrigatório
	                    { || .F. }                           ,; // [11]  B   Code-block de inicializacao do campo
	                    .F.                                  ,; // [12]  L   Indica se trata-se de um campo chave
	                    .F.                                  ,; // [13]  L   Indica se o campo não pode receber valor em uma operação de update
	                    .T.)                                    // [14]  L   Indica se o campo é virtual

	//Altera propriedades dos campos
	oStrMaster:SetProperty("G1_COMP", MODEL_FIELD_OBRIGAT, .F.)

Return Nil

/*/{Protheus.doc} AltStrView
Edita os campos da estrutura da View
@author Marcelo Neumann
@since 25/01/2019
@version P12
@param 01 oStrMaster, object, estrutura da View V_FLD_COMPONENTE
@param 02 oStrDetail, object, estrutura da View V_GRID_PRODUTOS
@return Nil
/*/
Static Function AltStrView(oStrMaster, oStrDetail)

	//Adiciona novos campos
	oStrMaster:AddField("NQUANT"                            ,; // [01]  C   Nome do Campo
	                    GetSx3Cache("G1_QUANT","X3_ORDEM")  ,; // [02]  C   Ordem
	                    RetTitle("G1_QUANT")                ,; // [03]  C   Titulo do campo
	                    RetTitle("G1_QUANT")                ,; // [04]  C   Descricao do campo
	                    NIL                                 ,; // [05]  A   Array com Help
	                    GetSx3Cache("G1_QUANT","X3_TIPO")   ,; // [06]  C   Tipo do campo
	                    GetSx3Cache("G1_QUANT","X3_PICTURE"),; // [07]  C   Picture
	                    NIL                                 ,; // [08]  B   Bloco de Picture Var
	                    NIL                                 ,; // [09]  C   Consulta F3
	                    .T.                                 ,; // [10]  L   Indica se o campo é alteravel
	                    NIL                                 ,; // [11]  C   Pasta do campo
	                    NIL                                 ,; // [12]  C   Agrupamento do campo
	                    NIL                                 ,; // [13]  A   Lista de valores permitido do campo (Combo)
	                    NIL                                 ,; // [14]  N   Tamanho maximo da maior opção do combo
	                    NIL                                 ,; // [15]  C   Inicializador de Browse
	                    .T.                                 ,; // [16]  L   Indica se o campo é virtual
	                    NIL                                 ,; // [17]  C   Picture Variavel
	                    NIL                                 )  // [18]  L   Indica pulo de linha após o campo

	oStrMaster:AddField("DINI"                              ,; // [01]  C   Nome do Campo
	                    GetSx3Cache("G1_INI","X3_ORDEM")    ,; // [02]  C   Ordem
	                    RetTitle("G1_INI")                  ,; // [03]  C   Titulo do campo
	                    RetTitle("G1_INI")                  ,; // [04]  C   Descricao do campo
	                    NIL                                 ,; // [05]  A   Array com Help
	                    GetSx3Cache("G1_INI","X3_TIPO")     ,; // [06]  C   Tipo do campo
	                    GetSx3Cache("G1_INI","X3_PICTURE")  ,; // [07]  C   Picture
	                    NIL                                 ,; // [08]  B   Bloco de Picture Var
	                    NIL                                 ,; // [09]  C   Consulta F3
	                    .T.                                 ,; // [10]  L   Indica se o campo é alteravel
	                    NIL                                 ,; // [11]  C   Pasta do campo
	                    NIL                                 ,; // [12]  C   Agrupamento do campo
	                    NIL                                 ,; // [13]  A   Lista de valores permitido do campo (Combo)
	                    NIL                                 ,; // [14]  N   Tamanho maximo da maior opção do combo
	                    NIL                                 ,; // [15]  C   Inicializador de Browse
	                    .T.                                 ,; // [16]  L   Indica se o campo é virtual
	                    NIL                                 ,; // [17]  C   Picture Variavel
	                    NIL                                 )  // [18]  L   Indica pulo de linha após o campo

	oStrMaster:AddField("DFIM"                              ,; // [01]  C   Nome do Campo
	                    GetSx3Cache("G1_FIM","X3_ORDEM")    ,; // [02]  C   Ordem
	                    RetTitle("G1_FIM")                  ,; // [03]  C   Titulo do campo
	                    RetTitle("G1_FIM")                  ,; // [04]  C   Descricao do campo
	                    NIL                                 ,; // [05]  A   Array com Help
	                    GetSx3Cache("G1_FIM","X3_TIPO")     ,; // [06]  C   Tipo do campo
	                    GetSx3Cache("G1_FIM","X3_PICTURE")  ,; // [07]  C   Picture
	                    NIL                                 ,; // [08]  B   Bloco de Picture Var
	                    NIL                                 ,; // [09]  C   Consulta F3
	                    .T.                                 ,; // [10]  L   Indica se o campo é alteravel
	                    NIL                                 ,; // [11]  C   Pasta do campo
	                    NIL                                 ,; // [12]  C   Agrupamento do campo
	                    NIL                                 ,; // [13]  A   Lista de valores permitido do campo (Combo)
	                    NIL                                 ,; // [14]  N   Tamanho maximo da maior opção do combo
	                    NIL                                 ,; // [15]  C   Inicializador de Browse
	                    .T.                                 ,; // [16]  L   Indica se o campo é virtual
	                    NIL                                 ,; // [17]  C   Picture Variavel
	                    NIL                                 )  // [18]  L   Indica pulo de linha após o campo

	oStrDetail:AddField("LALTERA"                   ,; // [01]  C   Nome do Campo
	                    "01"                        ,; // [02]  C   Ordem
	                    STR0076                     ,; // [03]  C   Titulo do campo    - "Altera?"
	                    STR0076                     ,; // [04]  C   Descricao do campo - "Altera?"
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

	oStrDetail:AddField("CDESCPAI"                  ,; // [01]  C   Nome do Campo
	                    "03"                        ,; // [02]  C   Ordem
	                    STR0007                     ,; // [03]  C   Titulo do campo    - "Descrição"
	                    STR0007                     ,; // [04]  C   Descricao do campo - "Descrição"
	                    NIL                         ,; // [05]  A   Array com Help
	                    "C"                         ,; // [06]  C   Tipo do campo
	                    PesqPict('SB1','B1_DESC',3) ,; // [07]  C   Picture
	                    NIL                         ,; // [08]  B   Bloco de Picture Var
	                    NIL                         ,; // [09]  C   Consulta F3
	                    .F.                         ,; // [10]  L   Indica se o campo é alteravel
	                    NIL                         ,; // [11]  C   Pasta do campo
	                    NIL                         ,; // [12]  C   Agrupamento do campo
	                    NIL                         ,; // [13]  A   Lista de valores permitido do campo (Combo)
	                    NIL                         ,; // [14]  N   Tamanho maximo da maior opção do combo
	                    NIL                         ,; // [15]  C   Inicializador de Browse
	                    .T.                         ,; // [16]  L   Indica se o campo é virtual
	                    NIL                         ,; // [17]  C   Picture Variavel
	                    NIL                         )  // [18]  L   Indica pulo de linha após o campo

	//Altera propriedades dos campos do CABEÇALHO
	oStrMaster:SetProperty("G1_COMP"  , MVC_VIEW_CANCHANGE , .F.)
	oStrMaster:SetProperty("G1_DESC"  , MVC_VIEW_INSERTLINE, .T.) //Quebra linha

	//Altera propriedades dos campos da GRID
	oStrDetail:SetProperty("G1_COD"    , MVC_VIEW_ORDEM    , "02")
	oStrDetail:SetProperty("G1_TRT"    , MVC_VIEW_ORDEM    , "04")
	oStrDetail:SetProperty("G1_QUANT"  , MVC_VIEW_ORDEM    , "05")
	oStrDetail:SetProperty("G1_REVINI" , MVC_VIEW_ORDEM    , "06")
	oStrDetail:SetProperty("G1_REVFIM" , MVC_VIEW_ORDEM    , "07")
	oStrDetail:SetProperty("G1_INI"    , MVC_VIEW_ORDEM    , "08")
	oStrDetail:SetProperty("G1_FIM"    , MVC_VIEW_ORDEM    , "09")
	oStrDetail:SetProperty("G1_LOCCONS", MVC_VIEW_ORDEM    , "10")
	oStrDetail:SetProperty("G1_LISTA"  , MVC_VIEW_ORDEM    , "11")

	oStrDetail:SetProperty("G1_COD"    , MVC_VIEW_CANCHANGE, .F.)
	oStrDetail:SetProperty("G1_TRT"    , MVC_VIEW_CANCHANGE, .F.)
	oStrDetail:SetProperty("G1_QUANT"  , MVC_VIEW_CANCHANGE, .F.)
	oStrDetail:SetProperty("G1_REVINI" , MVC_VIEW_CANCHANGE, .F.)
	oStrDetail:SetProperty("G1_REVFIM" , MVC_VIEW_CANCHANGE, .F.)
	oStrDetail:SetProperty("G1_INI"    , MVC_VIEW_CANCHANGE, .F.)
	oStrDetail:SetProperty("G1_FIM"    , MVC_VIEW_CANCHANGE, .F.)
	oStrDetail:SetProperty("G1_LOCCONS", MVC_VIEW_CANCHANGE, .F.)
	oStrDetail:SetProperty("G1_LISTA"  , MVC_VIEW_CANCHANGE, .F.)

	oStrDetail:SetProperty("LALTERA"   , MVC_VIEW_WIDTH    ,  60)
	oStrDetail:SetProperty("G1_COD"    , MVC_VIEW_WIDTH    , 150)
	oStrDetail:SetProperty("G1_TRT"    , MVC_VIEW_WIDTH    ,  75)
	oStrDetail:SetProperty("G1_QUANT"  , MVC_VIEW_WIDTH    , 120)
	oStrDetail:SetProperty("G1_REVINI" , MVC_VIEW_WIDTH    ,  75)
	oStrDetail:SetProperty("G1_REVFIM" , MVC_VIEW_WIDTH    ,  70)
	oStrDetail:SetProperty("G1_INI"    , MVC_VIEW_WIDTH    ,  75)
	oStrDetail:SetProperty("G1_FIM"    , MVC_VIEW_WIDTH    ,  75)
	oStrDetail:SetProperty("G1_LOCCONS", MVC_VIEW_WIDTH    ,  75)
	oStrDetail:SetProperty("G1_LISTA"  , MVC_VIEW_WIDTH    ,  75)

	oStrMaster:SetProperty("G1_DESC"   , MVC_VIEW_TITULO   , STR0007) //"Descrição"
	oStrDetail:SetProperty("G1_COD"    , MVC_VIEW_TITULO   , STR0079) //"Código"
	oStrDetail:SetProperty("G1_TRT"    , MVC_VIEW_TITULO   , STR0080) //"Sequência"

Return Nil

/*/{Protheus.doc} GetStruErr
Cria a estrutura de dados para exibição da tela de erros.
@type  Static Function
@author lucas.franca
@since 01/02/2019
@version P12
@param nType, numeric, 1 - Struct do Modelo. 2 - Struct da view
@return oStruct, Object, Retorna a estrutura de dados para a exibição de tela de erros.
/*/
Static Function GetStruErr(nType)
	Local oStruct

	//Struct para o Modelo
	If nType == 1
		//Cria nova instância do FwFormModelStruct.
		oStruct := FWFormModelStruct():New()

		//Adiciona os campos do modelo de Erros
		oStruct:AddField(STR0082                              ,;	//	[01]  C   Titulo do campo //"Produto Pai"
		                 STR0083                              ,;	//	[02]  C   ToolTip do campo //"Código do produto pai"
		                 "CG1COD"                             ,;	//	[03]  C   Id do Field
		                 "C"                                  ,;	//	[04]  C   Tipo do campo
		                 GetSx3Cache("B1_DESC","X3_TAMANHO")  ,;	//	[05]  N   Tamanho do campo
		                 0                                    ,;	//	[06]  N   Decimal do campo
		                 NIL                                  ,;	//	[07]  B   Code-block de validação do campo
		                 NIL                                  ,;	//	[08]  B   Code-block de validação When do campo
		                 {}                                   ,;	//	[09]  A   Lista de valores permitido do campo
		                 .F.                                  ,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
		                 Nil                                  ,;	//	[11]  B   Code-block de inicializacao do campo
		                 NIL                                  ,;	//	[12]  L   Indica se trata-se de um campo chave
		                 NIL                                  ,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
		                 .T.                                   )	//	[14]  L   Indica se o campo é virtual

		oStruct:AddField(STR0084                              ,;	//	[01]  C   Titulo do campo //"Componente"
		                 STR0085                              ,;	//	[02]  C   ToolTip do campo //"Código do componente"
		                 "CG1COMP"                            ,;	//	[03]  C   Id do Field
		                 "C"                                  ,;	//	[04]  C   Tipo do campo
		                 GetSx3Cache("B1_DESC","X3_TAMANHO")  ,;	//	[05]  N   Tamanho do campo
		                 0                                    ,;	//	[06]  N   Decimal do campo
		                 NIL                                  ,;	//	[07]  B   Code-block de validação do campo
		                 NIL                                  ,;	//	[08]  B   Code-block de validação When do campo
		                 {}                                   ,;	//	[09]  A   Lista de valores permitido do campo
		                 .F.                                  ,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
		                 Nil                                  ,;	//	[11]  B   Code-block de inicializacao do campo
		                 NIL                                  ,;	//	[12]  L   Indica se trata-se de um campo chave
		                 NIL                                  ,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
		                 .T.                                   )	//	[14]  L   Indica se o campo é virtual

		oStruct:AddField(STR0086                              ,;	//	[01]  C   Titulo do campo //"Sequência"
		                 STR0087                              ,;	//	[02]  C   ToolTip do campo //"Sequência do componente"
		                 "CG1TRT"                             ,;	//	[03]  C   Id do Field
		                 "C"                                  ,;	//	[04]  C   Tipo do campo
		                 GetSx3Cache("G1_TRT","X3_TAMANHO")   ,;	//	[05]  N   Tamanho do campo
		                 0                                    ,;	//	[06]  N   Decimal do campo
		                 NIL                                  ,;	//	[07]  B   Code-block de validação do campo
		                 NIL                                  ,;	//	[08]  B   Code-block de validação When do campo
		                 {}                                   ,;	//	[09]  A   Lista de valores permitido do campo
		                 .F.                                  ,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
		                 Nil                                  ,;	//	[11]  B   Code-block de inicializacao do campo
		                 NIL                                  ,;	//	[12]  L   Indica se trata-se de um campo chave
		                 NIL                                  ,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
		                 .T.                                   )	//	[14]  L   Indica se o campo é virtual

		oStruct:AddField(RetTitle("G1_REVINI")                ,;	//	[01]  C   Titulo do campo
		                 RetTitle("G1_REVINI")                ,;	//	[02]  C   ToolTip do campo
		                 "CG1REVINI"                          ,;	//	[03]  C   Id do Field
		                 "C"                                  ,;	//	[04]  C   Tipo do campo
		                 GetSx3Cache("G1_REVINI","X3_TAMANHO"),;	//	[05]  N   Tamanho do campo
		                 0                                    ,;	//	[06]  N   Decimal do campo
		                 NIL                                  ,;	//	[07]  B   Code-block de validação do campo
		                 NIL                                  ,;	//	[08]  B   Code-block de validação When do campo
		                 {}                                   ,;	//	[09]  A   Lista de valores permitido do campo
		                 .F.                                  ,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
		                 Nil                                  ,;	//	[11]  B   Code-block de inicializacao do campo
		                 NIL                                  ,;	//	[12]  L   Indica se trata-se de um campo chave
		                 NIL                                  ,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
		                 .T.                                   )	//	[14]  L   Indica se o campo é virtual

		oStruct:AddField(RetTitle("G1_REVFIM")                ,;	//	[01]  C   Titulo do campo
		                 RetTitle("G1_REVFIM")                ,;	//	[02]  C   ToolTip do campo
		                 "CG1REVFIM"                          ,;	//	[03]  C   Id do Field
		                 "C"                                  ,;	//	[04]  C   Tipo do campo
		                 GetSx3Cache("G1_REVFIM","X3_TAMANHO"),;	//	[05]  N   Tamanho do campo
		                 0                                    ,;	//	[06]  N   Decimal do campo
		                 NIL                                  ,;	//	[07]  B   Code-block de validação do campo
		                 NIL                                  ,;	//	[08]  B   Code-block de validação When do campo
		                 {}                                   ,;	//	[09]  A   Lista de valores permitido do campo
		                 .F.                                  ,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
		                 Nil                                  ,;	//	[11]  B   Code-block de inicializacao do campo
		                 NIL                                  ,;	//	[12]  L   Indica se trata-se de um campo chave
		                 NIL                                  ,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
		                 .T.                                   )	//	[14]  L   Indica se o campo é virtual

		oStruct:AddField(STR0088                              ,;	//	[01]  C   Titulo do campo //"Mensagem"
		                 STR0089                              ,;	//	[02]  C   ToolTip do campo //"Mensagem de erro"
		                 "CMENS"                              ,;	//	[03]  C   Id do Field
		                 "C"                                  ,;	//	[04]  C   Tipo do campo
		                 255                                  ,;	//	[05]  N   Tamanho do campo
		                 0                                    ,;	//	[06]  N   Decimal do campo
		                 NIL                                  ,;	//	[07]  B   Code-block de validação do campo
		                 NIL                                  ,;	//	[08]  B   Code-block de validação When do campo
		                 {}                                   ,;	//	[09]  A   Lista de valores permitido do campo
		                 .F.                                  ,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
		                 Nil                                  ,;	//	[11]  B   Code-block de inicializacao do campo
		                 NIL                                  ,;	//	[12]  L   Indica se trata-se de um campo chave
		                 NIL                                  ,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
		                 .T.                                   )	//	[14]  L   Indica se o campo é virtual
	Else
		//Cria nova instância do FwFormViewStruct.
		oStruct := FWFormViewStruct():New()

		//Adiciona os campos do modelo de Erros
		oStruct:AddField("CG1COD"                             ,;	//	[01]  C   Nome do Campo
		                 "01"                                 ,;	//	[02]  C   Ordem
		                 STR0082                              ,;	//	[03]  C   Titulo do campo //"Produto pai"
		                 STR0083                              ,;	//	[04]  C   Descricao do campo //"Código do produto pai"
		                 NIL                                  ,;	//	[05]  A   Array com Help
		                 "C"                                  ,;	//	[06]  C   Tipo do campo
		                 "@!"                                 ,;	//	[07]  C   Picture
		                 NIL                                  ,;	//	[08]  B   Bloco de PictTre Var
		                 NIL                                  ,;	//	[09]  C   Consulta F3
		                 .F.                                  ,;	//	[10]  L   Indica se o campo é alteravel
		                 NIL                                  ,;	//	[11]  C   Pasta do campo
		                 NIL                                  ,;	//	[12]  C   Agrupamento do campo
		                 NIL                                  ,;	//	[13]  A   Lista de valores permitido do campo (Combo)
		                 NIL                                  ,;	//	[14]  N   Tamanho maximo da maior opção do combo
		                 NIL                                  ,;	//	[15]  C   Inicializador de Browse
		                 .T.                                  ,;	//	[16]  L   Indica se o campo é virtual
		                 NIL                                  ,;	//	[17]  C   Picture Variavel
		                 NIL                                   )	//	[18]  L   Indica pulo de linha após o campo

		oStruct:AddField("CG1COMP"                            ,;	//	[01]  C   Nome do Campo
		                 "02"                                 ,;	//	[02]  C   Ordem
		                 STR0084                              ,;	//	[03]  C   Titulo do campo //"Componente"
		                 STR0085                              ,;	//	[04]  C   Descricao do campo //"Código do componente"
		                 NIL                                  ,;	//	[05]  A   Array com Help
		                 "C"                                  ,;	//	[06]  C   Tipo do campo
		                 "@!"                                 ,;	//	[07]  C   Picture
		                 NIL                                  ,;	//	[08]  B   Bloco de PictTre Var
		                 NIL                                  ,;	//	[09]  C   Consulta F3
		                 .F.                                  ,;	//	[10]  L   Indica se o campo é alteravel
		                 NIL                                  ,;	//	[11]  C   Pasta do campo
		                 NIL                                  ,;	//	[12]  C   Agrupamento do campo
		                 NIL                                  ,;	//	[13]  A   Lista de valores permitido do campo (Combo)
		                 NIL                                  ,;	//	[14]  N   Tamanho maximo da maior opção do combo
		                 NIL                                  ,;	//	[15]  C   Inicializador de Browse
		                 .T.                                  ,;	//	[16]  L   Indica se o campo é virtual
		                 NIL                                  ,;	//	[17]  C   Picture Variavel
		                 NIL                                   )	//	[18]  L   Indica pulo de linha após o campo

		oStruct:AddField("CG1TRT"                             ,;	//	[01]  C   Nome do Campo
		                 "03"                                 ,;	//	[02]  C   Ordem
		                 STR0086                              ,;	//	[03]  C   Titulo do campo //"Sequência"
		                 STR0087                              ,;	//	[04]  C   Descricao do campo //"Sequência do componente"
		                 NIL                                  ,;	//	[05]  A   Array com Help
		                 "C"                                  ,;	//	[06]  C   Tipo do campo
		                 "@!"                                 ,;	//	[07]  C   Picture
		                 NIL                                  ,;	//	[08]  B   Bloco de PictTre Var
		                 NIL                                  ,;	//	[09]  C   Consulta F3
		                 .F.                                  ,;	//	[10]  L   Indica se o campo é alteravel
		                 NIL                                  ,;	//	[11]  C   Pasta do campo
		                 NIL                                  ,;	//	[12]  C   Agrupamento do campo
		                 NIL                                  ,;	//	[13]  A   Lista de valores permitido do campo (Combo)
		                 NIL                                  ,;	//	[14]  N   Tamanho maximo da maior opção do combo
		                 NIL                                  ,;	//	[15]  C   Inicializador de Browse
		                 .T.                                  ,;	//	[16]  L   Indica se o campo é virtual
		                 NIL                                  ,;	//	[17]  C   Picture Variavel
		                 NIL                                   )	//	[18]  L   Indica pulo de linha após o campo

		oStruct:AddField("CG1REVINI"                          ,;	//	[01]  C   Nome do Campo
		                 "04"                                 ,;	//	[02]  C   Ordem
		                 RetTitle("G1_REVINI")                ,;	//	[03]  C   Titulo do campo
		                 RetTitle("G1_REVINI")                ,;	//	[04]  C   Descricao do campo //"Seleciona ordem"
		                 NIL                                  ,;	//	[05]  A   Array com Help
		                 "C"                                  ,;	//	[06]  C   Tipo do campo
		                 NIL                                  ,;	//	[07]  C   Picture
		                 NIL                                  ,;	//	[08]  B   Bloco de PictTre Var
		                 NIL                                  ,;	//	[09]  C   Consulta F3
		                 .F.                                  ,;	//	[10]  L   Indica se o campo é alteravel
		                 NIL                                  ,;	//	[11]  C   Pasta do campo
		                 NIL                                  ,;	//	[12]  C   Agrupamento do campo
		                 NIL                                  ,;	//	[13]  A   Lista de valores permitido do campo (Combo)
		                 NIL                                  ,;	//	[14]  N   Tamanho maximo da maior opção do combo
		                 NIL                                  ,;	//	[15]  C   Inicializador de Browse
		                 .T.                                  ,;	//	[16]  L   Indica se o campo é virtual
		                 NIL                                  ,;	//	[17]  C   Picture Variavel
		                 NIL                                   )	//	[18]  L   Indica pulo de linha após o campo

		oStruct:AddField("CG1REVFIM"                          ,;	//	[01]  C   Nome do Campo
		                 "05"                                 ,;	//	[02]  C   Ordem
		                 RetTitle("G1_REVFIM")                ,;	//	[03]  C   Titulo do campo
		                 RetTitle("G1_REVFIM")                ,;	//	[04]  C   Descricao do campo //"Seleciona ordem"
		                 NIL                                  ,;	//	[05]  A   Array com Help
		                 "C"                                  ,;	//	[06]  C   Tipo do campo
		                 NIL                                  ,;	//	[07]  C   Picture
		                 NIL                                  ,;	//	[08]  B   Bloco de PictTre Var
		                 NIL                                  ,;	//	[09]  C   Consulta F3
		                 .F.                                  ,;	//	[10]  L   Indica se o campo é alteravel
		                 NIL                                  ,;	//	[11]  C   Pasta do campo
		                 NIL                                  ,;	//	[12]  C   Agrupamento do campo
		                 NIL                                  ,;	//	[13]  A   Lista de valores permitido do campo (Combo)
		                 NIL                                  ,;	//	[14]  N   Tamanho maximo da maior opção do combo
		                 NIL                                  ,;	//	[15]  C   Inicializador de Browse
		                 .T.                                  ,;	//	[16]  L   Indica se o campo é virtual
		                 NIL                                  ,;	//	[17]  C   Picture Variavel
		                 NIL                                   )	//	[18]  L   Indica pulo de linha após o campo

		oStruct:AddField("CMENS"                              ,;	//	[01]  C   Nome do Campo
		                 "06"                                 ,;	//	[02]  C   Ordem
		                 STR0088                              ,;	//	[03]  C   Titulo do campo //"Mensagem"
		                 STR0089                              ,;	//	[04]  C   Descricao do campo //"Mensagem de erro"
		                 NIL                                  ,;	//	[05]  A   Array com Help
		                 "C"                                  ,;	//	[06]  C   Tipo do campo
		                 NIL                                  ,;	//	[07]  C   Picture
		                 NIL                                  ,;	//	[08]  B   Bloco de PictTre Var
		                 NIL                                  ,;	//	[09]  C   Consulta F3
		                 .F.                                  ,;	//	[10]  L   Indica se o campo é alteravel
		                 NIL                                  ,;	//	[11]  C   Pasta do campo
		                 NIL                                  ,;	//	[12]  C   Agrupamento do campo
		                 NIL                                  ,;	//	[13]  A   Lista de valores permitido do campo (Combo)
		                 NIL                                  ,;	//	[14]  N   Tamanho maximo da maior opção do combo
		                 NIL                                  ,;	//	[15]  C   Inicializador de Browse
		                 .T.                                  ,;	//	[16]  L   Indica se o campo é virtual
		                 NIL                                  ,;	//	[17]  C   Picture Variavel
		                 NIL                                   )	//	[18]  L   Indica pulo de linha após o campo

		//Altera o tamanho das colunas
		oStruct:SetProperty("CG1COD"   , MVC_VIEW_WIDTH, 150)
		oStruct:SetProperty("CG1COMP"  , MVC_VIEW_WIDTH, 150)
		oStruct:SetProperty("CG1TRT"   , MVC_VIEW_WIDTH, 70)
		oStruct:SetProperty("CG1REVINI", MVC_VIEW_WIDTH, 70)
		oStruct:SetProperty("CG1REVFIM", MVC_VIEW_WIDTH, 70)
		oStruct:SetProperty("CMENS"    , MVC_VIEW_WIDTH, 250)
	EndIf
Return oStruct

/*/{Protheus.doc} AfterView
Função executada após ativar a view
@author Marcelo Neumann
@since 25/01/2019
@version P12
@param 01 oView, object, objeto da View
@return Nil
/*/
Static Function AfterView(oView)

	//Seta funcionalidade de marcar/desmarcar todos clicando no cabeçalho
	oView:GetSubView("V_GRID_PRODUTOS"):oBrowse:aColumns[1]:bHeaderClick := {|| MarcaTodos(oView) }

	//Seta o modelo como não alterado
	SetModify(oView, .F.)
Return Nil

/*/{Protheus.doc} CarregaMdl
Carrega os dados da Grid com os dados carregados na grid principal do PCPA134
@author Marcelo Neumann
@since 25/01/2019
@version P12
@param 01 oModelPai, object, modelo pai (tela principal do PCPA134)
@param 02 oModelAlt, object, modelo da tela de Alteração
@return Nil
/*/
Static Function CarregaMdl(oModelPai, oModelAlt)

	Local oSubMdlPai := oModelPai:GetModel("GRID_ONDE")
	Local oSubMdlAlt := oModelAlt:GetModel("GRID_PRODUTOS")
	Local nLine      := 0

	Default lAutoMacao := .F.

	IF !lAutoMacao
		For nLine := 1 to oSubMdlPai:Length()
			If nLine <> 1
				oSubMdlAlt:AddLine()
			EndIf
			oSubMdlAlt:LoadValue("G1_COD"    , oSubMdlPai:GetValue("G1_COD"    , nLine))
			oSubMdlAlt:LoadValue("CDESCPAI"  , oSubMdlPai:GetValue("B1_DESC"   , nLine))
			oSubMdlAlt:LoadValue("G1_COMP"   , oSubMdlPai:GetValue("G1_COMP"   , nLine))
			oSubMdlAlt:LoadValue("G1_TRT"    , oSubMdlPai:GetValue("G1_TRT"    , nLine))
			oSubMdlAlt:LoadValue("G1_QUANT"  , oSubMdlPai:GetValue("G1_QUANT"  , nLine))
			oSubMdlAlt:LoadValue("G1_REVINI" , oSubMdlPai:GetValue("G1_REVINI" , nLine))
			oSubMdlAlt:LoadValue("G1_REVFIM" , oSubMdlPai:GetValue("G1_REVFIM" , nLine))
			oSubMdlAlt:LoadValue("G1_INI"    , oSubMdlPai:GetValue("G1_INI"    , nLine))
			oSubMdlAlt:LoadValue("G1_FIM"    , oSubMdlPai:GetValue("G1_FIM"    , nLine))
			oSubMdlAlt:LoadValue("G1_LOCCONS", oSubMdlPai:GetValue("G1_LOCCONS", nLine))
			oSubMdlAlt:LoadValue("G1_LISTA"  , oSubMdlPai:GetValue("G1_LISTA"  , nLine))
			oSubMdlAlt:LoadValue("RECNO"     , oSubMdlPai:GetValue("RECNO"     , nLine))
			oSubMdlAlt:LoadValue("LALTERA"   , .F.)
		Next nLine
	ENDIF

	oSubMdlAlt:SetNoInsertLine(.T.)
	oSubMdlAlt:SetNoDeleteLine(.T.)
	IF !lAutoMacao
		oSubMdlAlt:GoLine(1)
	ENDIF

Return Nil

/*/{Protheus.doc} BotaoOk
Ação a ser executada ao clicar no botão de Confirmar ("Modificar")
@author brunno.costa
@since 04/04/2019
@version P12
@param 01 oView, object, objeto da View
@return lRetAux, logical, indica se a tela pode ser confirmada
/*/
Static Function BotaoOk(oView)
	Local lAbort   := .F.
	Local oOldView := FwViewActive()
	Local lRetAux  := .T.
	Processa({|| lRetAux := a134AltBAl(oView) }, STR0116, STR0115, lAbort) //"Modificando..." - "Aguarde o término do processamento."
	If lAbort
		lRetAux := .F.
	Endif
	If oOldView != Nil
		FwViewActive(oOldView)
	EndIf
Return lRetAux

/*/{Protheus.doc} a134AltBAl
Ação a ser executada ao clicar no botão de Confirmar ("Modificar")
@author Marcelo Neumann
@since 25/01/2019
@version P12
@param 01 oView, object, objeto da View
@return lOk, logical, indica se a tela pode ser confirmada
/*/
Function a134AltBAl(oView)
	Local oModel   := oView:GetModel()
	Local nLine    := 1
	Local lChecked := .F.
	Local lOk      := .T.
	Local aHistory := {}

	Default lAutoMacao := .F.

	//Seta barra infinita
	ProcRegua(0)

	//Processa a Regua
	IncProc()

	IF !lAutoMacao
		//Verifica se foi marcado algum produto para ser modificado
		For nLine := 1 to oModel:GetModel("GRID_PRODUTOS"):Length()
			//Processa a Regua
			IncProc()

			If oModel:GetModel("GRID_PRODUTOS"):GetValue("LALTERA", nLine)
				lChecked := .T.
				Exit
			EndIf
		Next nLine
	ENDIF

	//Processa a Regua
	IncProc()

	If !lChecked
		lOk := .F.
		Help( ,  , "Help", ,  STR0077,; //"Nenhum produto selecionado."
			 1, 0, , , , , , {STR0078}) //"Selecione ao menos um Produto para modificar."
	EndIf

	//Processa a Regua
	IncProc()

	//Verifica se foi informado ao menos um campo para alterar.
	If lOk
		If Empty(oModel:GetModel("FLD_COMPONENTE"):GetValue("NQUANT")) .And. ;
		   Empty(oModel:GetModel("FLD_COMPONENTE"):GetValue("DINI")) .And. ;
		   Empty(oModel:GetModel("FLD_COMPONENTE"):GetValue("DFIM"))
			lOk := .F.
			Help(,,"Help",,STR0090,; //"Quantidade, Data Inicial e Data Final não preenchidos."
			     1,0,,,,,,{STR0091}) //"Informe a Quantidade, Data Inicial ou Data Final para prosseguir com a modificação dos componentes."
		EndIf
	EndIf

	//Processa a Regua
	IncProc()

	//Valida a data inicial/final informada.
	If lOk
		If !Empty(oModel:GetModel("FLD_COMPONENTE"):GetValue("DINI")) .And. ;
		   !Empty(oModel:GetModel("FLD_COMPONENTE"):GetValue("DFIM"))
			If oModel:GetModel("FLD_COMPONENTE"):GetValue("DINI") > oModel:GetModel("FLD_COMPONENTE"):GetValue("DFIM")
				lOk := .F.
				Help(,,"Help",,STR0092,; //"Data inicial não pode ser maior que a data final."
				     1,0,,,,,,{STR0093}) //"Informe uma data inicial que seja anterior à data final."
			EndIf
		EndIf
	EndIf

	//Processa a Regua
	IncProc()

	//Verifica se a alteração irá gerar uma nova revisão da estrutura.
	If lOk
		lOk := VldRevisao(oModel)
	EndIf

	//Processa a Regua
	IncProc()

	//Processa a alteração das estruturas.
	If lOk
		aHistory := MontaHist(oModel)
		lOk := ProcEstrut(oModel,oView, aHistory)
	EndIf

	//Processa a Regua
	IncProc()

	If lOk
		SetModify(oView, .T.)
	EndIf

	//Processa a Regua
	IncProc()

Return lOk

/*/{Protheus.doc} SetModify
Seta o indicador de modificado do modelo
@author Marcelo Neumann
@since 25/01/2019
@version P12
@param 01 oView, object, objeto da View
@param 02 lMod , logic , indica se o modelo será setado para modificado ou não
@return .T.
/*/
Static Function SetModify(oView, lMod)

	Local oModel := oView:GetModel()

	oModel:lModify := lMod

Return .T.

/*/{Protheus.doc} MarcaTodos
Função executada ao clicar no cabeçalho do CheckBox
@author Marcelo Neumann
@since 25/01/2019
@version P12
@param 01 oView, object, objeto da View
@return Nil
/*/
Static Function MarcaTodos(oView)

	Local oModel   := oView:GetModel()
	Local oMdlGrid := oModel:GetModel("GRID_PRODUTOS")
	Local nLinAtua := 1
	Local nPCPRLEP := SuperGetMV("MV_PCPRLEP",.F., 2)
	Local nLine    := 1

	Default lAutoMacao := .F.

	slMarca := !slMarca

	IF !lAutoMacao
		nLinAtua := oMdlGrid:GetLine()

		For nLine := 1 to oMdlGrid:Length()
			oMdlGrid:GoLine(nLine)
			If nPCPRLEP == 1 .And. !Empty(oMdlGrid:GetValue("G1_LISTA")) .And. slMarca
				//Se é um componente que pertence a uma lista, não marca.
				Loop
			EndIf
			oMdlGrid:LoadValue("LALTERA", slMarca)
		Next nLine

		//Atualiza a Grid
		oMdlGrid:GoLine(nLinAtua)
		oView:GetSubView("V_GRID_PRODUTOS"):DeActivate(.T.)
		oView:GetSubView("V_GRID_PRODUTOS"):Activate()
	ENDIF	

Return Nil

/*/{Protheus.doc} VldRevisao
Faz as validações referentes a geração de revisão para a modificação realizada.

@type  Static Function
@author lucas.franca
@since 04/02/2019
@version P12
@param oModel, Object , Modelo de dados da tela de modificação
@return lRet , Logical, Identifica se a modificação poderá ser efetuada.
/*/
Static Function VldRevisao(oModel)
	Local aProdutos := {}
	Local lRet      := .T.
	Local lRevAut   := SuperGetMv("MV_REVAUT",.F.,.F.)
	Local lQuant    := .F.
	Local lDtIni    := .F.
	Local lDtFim    := .F.
	Local lAltQtd   := .F.
	Local lAltDtIni := .F.
	Local lAltDtFim := .F.
	Local nIndexCmp := 0
	Local nIndexPai := 0
	Local cRevAtu   := ""
	Local cProdutos := ""
	Local oMdlGrid  := oModel:GetModel("GRID_PRODUTOS")

	Default lAutoMacao := .F.

	If lRevAut .And. AliasInDic("SOW")
		//Identifica os campos que geram revisão
		SOW->(dbSetOrder(1))
		If SOW->(MsSeek(xFilial("SOW")+"G1_QUANT")) .And. SOW->OW_REVISA == "2"
			lQuant := .T.
		EndIf
		If SOW->(MsSeek(xFilial("SOW")+"G1_INI")) .And. SOW->OW_REVISA == "2"
			lDtIni := .T.
		EndIf
		If SOW->(MsSeek(xFilial("SOW")+"G1_FIM")) .And. SOW->OW_REVISA == "2"
			lDtFim := .T.
		EndIf

		IF !lAutoMacao
			//Verifica quais campos serão alterados
			lAltQtd   := !Empty(oModel:GetModel("FLD_COMPONENTE"):GetValue("NQUANT"))
			lAltDtIni := !Empty(oModel:GetModel("FLD_COMPONENTE"):GetValue("DINI"))
			lAltDtFim := !Empty(oModel:GetModel("FLD_COMPONENTE"):GetValue("DFIM"))
		ENDIF

		If ( lAltQtd   .And. lQuant ) .Or. ;
		   ( lAltDtIni .And. lDtIni ) .Or. ;
		   ( lAltDtFim .And. lDtFim )
			/*
			   Se a alteração pode gerar novas revisões,
			   percorre todos os componentes selecionados para verificar
			   se o mesmo produto pai foi selecionado com duas revisões diferentes.
			   Se foi, não permite continuar com a alteração.
			   Quando for gerada uma nova revisão, é possível selecionar somente uma revisão do produto PAI por vez.
			*/
			For nIndexPai := 1 To oMdlGrid:Length()
				If oMdlGrid:GetValue("LALTERA",nIndexPai)
					For nIndexCmp := nIndexPai+1 To oMdlGrid:Length()
						//Procura pelo mesmo produto PAI, que tenha sido selecionado utilizando uma revisão diferente.
						If oMdlGrid:GetValue("G1_COD",nIndexPai)    == oMdlGrid:GetValue("G1_COD",nIndexCmp)    .And. ;
						   oMdlGrid:GetValue("G1_REVFIM",nIndexPai) != oMdlGrid:GetValue("G1_REVFIM",nIndexCmp) .And. ;
						   oMdlGrid:GetValue("LALTERA",nIndexCmp)
							lRet := .F.
							Help(,,"Help",,STR0082 + " '" + AllTrim(oMdlGrid:GetValue("G1_COD",nIndexPai)) + "' " + STR0094,; //"Produto pai 'XXX' foi selecionado mais de uma vez com revisões diferentes."
							     1,0,,,,,,{STR0095}) //"A modificação deste componente poderá gerar nova revisão para o produto pai. Selecione apenas uma das revisões disponíveis deste produto para realizar a modificação."
							Exit
						EndIf
					Next nIndexCmp
					If !lRet
						//Sai do For nIndexPai.
						Exit
					EndIf
				EndIf
			Next nIndexPai

			If lRet
				//Verifica se o usuário selecionou o produto PAI em uma revisão que não é a atual, para exibir a mensagem de confirmarção.
				For nIndexPai := 1 To oMdlGrid:Length()
					If oMdlGrid:GetValue("LALTERA",nIndexPai)
						//Recupera a revisão atual do produto
						SB1->(MsSeek(xFilial("SB1")+oMdlGrid:GetValue("G1_COD",nIndexPai)))
						cRevAtu := Iif(slPCPREVATU,PCPREVATU(SB1->B1_COD),SB1->B1_REVATU)

						If cRevAtu != oMdlGrid:GetValue("G1_REVFIM",nIndexPai)
							If aScan(aProdutos,{|x| x == oMdlGrid:GetValue("G1_COD",nIndexPai)}) == 0
								aAdd(aProdutos,oMdlGrid:GetValue("G1_COD",nIndexPai))
							EndIf
						EndIf
					EndIf
				Next nIndexPai
				If Len(aProdutos) > 0
					For nIndexPai := 1 To Len(aProdutos)
						If !Empty(cProdutos)
							cProdutos += ", "
						EndIf
						cProdutos += AllTrim(aProdutos[nIndexPai])
					Next nIndexPai

					lRet := MsgYesNo(STR0096 + cProdutos + STR0097,STR0098) //"A alteração do(s) produto(s) " XXX " poderá gerar uma nova revisão, utilizando como base uma revisão diferente da revisão atual destes produtos. Confirma a modificação das estruturas?" --- "Confirmação"
					If !lRet
						Help(,,"Help",,STR0099,1,0) //"Modificação cancelada."
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} ProcEstrut
Faz o processamento da alteração das estruturas
@type  Static Function
@author lucas.franca
@since 01/02/2019
@version P12
@param oModel, Object, Modelo de dados da tela de modificação
@param oView , Object, View da tela de modificação
@return lRet, Logical, Indica se a alteração das estruturas foi feita com sucesso.
/*/
Static Function ProcEstrut(oModel,oView, aHistory)
	Local aAreaG1   := SG1->(GetArea())
	Local aModels   := {}
	Local aErros    := {}
	Local cCodPai   := ""
	Local cCodComp  := ""
	Local cRevIni   := ""
	Local cRevFim   := ""
	Local cTrt      := ""
	Local lOk       := .T.
	Local lRet      := .T.
	Local lAltQtd   := .F.
	Local lAltDtIni := .F.
	Local lAltDtFim := .F.
	Local nIndex    := 0
	Local nPos      := 0
	Local nNewQtd   := 0
	Local dNewIni   := dDataBase
	Local dNewFim   := dDataBase
	Local oMdlGrid  := oModel:GetModel("GRID_PRODUTOS")
	Local oMdl200   := Nil

	Default lAutoMacao := .F.

	IF !lAutoMacao
		nNewQtd   := oModel:GetModel("FLD_COMPONENTE"):GetValue("NQUANT")
		dNewIni   := oModel:GetModel("FLD_COMPONENTE"):GetValue("DINI")
		dNewFim   := oModel:GetModel("FLD_COMPONENTE"):GetValue("DFIM")
	ENDIF

	//Identifica quais são as informações que serão alteradas.
	lAltQtd   := !Empty(nNewQtd)
	lAltDtIni := !Empty(dNewIni)
	lAltDtFim := !Empty(dNewFim)

	SG1->(dbSetOrder(1))
	IF !lAutoMacao
		For nIndex := 1 To oMdlGrid:Length()
			If oMdlGrid:GetValue("LALTERA",nIndex)
				cCodPai  := oMdlGrid:GetValue("G1_COD"   , nIndex)
				cCodComp := oMdlGrid:GetValue("G1_COMP"  , nIndex)
				cTrt     := oMdlGrid:GetValue("G1_TRT"   , nIndex)
				cRevIni  := oMdlGrid:GetValue("G1_REVINI", nIndex)
				cRevFim  := oMdlGrid:GetValue("G1_REVFIM", nIndex)

				//Verifica no array aModels se já foi carregado um modelo para este produto PAI
				nPos := aScan(aModels,{|x| x[2] == cCodPai+cRevFim})
				If nPos == 0
					//Posiciona na SG1 para carregar o modelo do produto PAI
					If SG1->(dbSeek(xFilial("SG1")+cCodPai))
						//Carrega o modelo do produto PAI
						oMdl200 := Nil
						oMdl200 := FWLoadModel("PCPA200")
						oMdl200:SetOperation(MODEL_OPERATION_UPDATE)
						oMdl200:Activate()

						//Armazena o modelo no array aModels
						aAdd(aModels,{oMdl200,cCodPai+cRevFim,.T.})
						nPos := Len(aModels)

						//Seta o identificador de execução automática do PCPA200
						oMdl200:GetModel("SG1_MASTER"):SetValue("CEXECAUTO","S")
						//Carrega a revisão que será utilizada na alteração.
						oMdl200:GetModel("SG1_MASTER"):LoadValue("CREVPAI",cRevFim)

						//Faz a carga dos componentes.
						P200TreeCh(.F.,P200AddPai(oMdl200:GetModel("SG1_MASTER"):GetValue("G1_COD")))
					Else
						//Adiciona log de erro, pois não conseguiu posicionar na SG1 para esse produto PAI.
						aAdd(aErros,{cCodPai,"","","","",STR0100}) //"Estrutura não encontrada."
						Loop
					EndIf
				Else
					//Modelo deste PAI já está carregado, apenas o recupera.
					oMdl200 := aModels[nPos][1]
				EndIf

				//Busca o componente na grid do PCPA200
				If oMdl200:GetModel("SG1_DETAIL"):SeekLine({ {"G1_COD" , cCodPai} ,;
															{"G1_COMP", cCodComp},;
															{"G1_TRT" , cTrt} }, .F., .T.)
					//Tenta alterar as informações.
					lOk := .T.
					If lOk .And. lAltQtd
						lOk := oMdl200:GetModel("SG1_DETAIL"):SetValue("G1_QUANT",nNewQtd)
					EndIf
					If lOk .And. lAltDtIni
						lOk := oMdl200:GetModel("SG1_DETAIL"):SetValue("G1_INI",dNewIni)
					EndIf
					If lOk .And. lAltDtFim
						lOk := oMdl200:GetModel("SG1_DETAIL"):SetValue("G1_FIM",dNewFim)
					EndIf
					If !lOk
						//Não foi possível alterar as informações. Adiciona log de erro.
						aModels[nPos][3] := .F.
						aAdd(aErros,{cCodPai,cCodComp,cTrt,cRevIni,cRevFim,getError(oMdl200:GetErrorMessage())})
						Loop
					Else
						//Verifica se o modelo está válido. Se não estiver adiciona log de erro.
						If !oMdl200:GetModel("SG1_DETAIL"):VldLineData(.T.)
							aModels[nPos][3] := .F.
							aAdd(aErros,{cCodPai,cCodComp,cTrt,cRevIni,cRevFim,getError(oMdl200:GetErrorMessage())})
							Loop
						EndIf
					EndIf
				Else
					//Não encontrou o componente na grid do PCPA200. Adiciona log de erro.
					aModels[nPos][3] := .F.
					aAdd(aErros,{cCodPai,cCodComp,cTrt,cRevIni,cRevFim,STR0101}) //"Componente não encontrado na estrutura."
					Loop
				EndIf
			EndIf
		Next nIndex
	ENDIF

	//Executa a pós-validação dos modelos.
	For nIndex := 1 To Len(aModels)
		If aModels[nIndex][3] //Verifica se o modelo está válido.
			FwModelActive(aModels[nIndex][1])
			//Verifica se o modelo está válido. Se não estiver adiciona log de erro.
			If !aModels[nIndex][1]:VldData(,.T.)
				aModels[nIndex][3] := .F.
				aAdd(aErros,{aModels[nIndex][1]:GetModel("SG1_MASTER"):GetValue("G1_COD"),,,,,;
				             getError(aModels[nIndex][1]:GetErrorMessage())})
				Loop
			EndIf
		EndIf
	Next nIndex

	//Verifica se os modelos estão válidos para realizar o commit.
	lRet := ModeloOk(aModels,aErros,oView,oModel)

	If lRet
		//Faz o commit dos modelos
		For nIndex := 1 To Len(aModels)
			If aModels[nIndex][3] //Verifica se o modelo está válido.
				FwModelActive(aModels[nIndex][1])
				If aModels[nIndex][1]:VldData(,.T.)
					aModels[nIndex][1]:CommitData() //Faz o commit dos dados.
				EndIf
				//Destrói o modelo.
				If aModels[nIndex][1]:IsActive()
					aModels[nIndex][1]:DeActivate()
				EndIf
				aModels[nIndex][1]:Destroy()
			EndIf
		Next nIndex

		grvHistor(aHistory, aErros)

	Else
		//Desativa e destrói os modelos.
		For nIndex := 1 To Len(aModels)
			If aModels[nIndex][1]:IsActive()
				aModels[nIndex][1]:DeActivate()
			EndIf
			aModels[nIndex][1]:Destroy()
		Next nIndex
	EndIf

	//Remove lock's
	If lRet
		//Remove lock's - Fonte PCPA200EVDEF
		SG1UnLockR(,,soRecNo)
		soRecNo := Nil
	endif

	//Seta o modelo ativo como o modelo principal do PCPA134.
	FwModelActive(oModel)
	aSize(aModels,0)

	SG1->(RestArea(aAreaG1))
Return lRet

/*/{Protheus.doc} getError
Transforma o array de erro do MVC em uma string.
@type  Static Function
@author lucas.franca
@since 01/02/2019
@version P12
@param  aMessage, Array, Array com as informações do erro (oModel:GetErrorMessage())
@return cMessage, Character, Mensagem de erro formatada.
/*/
Static Function getError(aMessage)
	Local cMessage := ""
	cMessage := AllTrim(aMessage[MODEL_MSGERR_IDFIELDERR])+" - "+;
	            AllTrim(aMessage[MODEL_MSGERR_ID])+" - "+;
	            AllTrim(aMessage[MODEL_MSGERR_MESSAGE])

	If !Empty(aMessage[MODEL_MSGERR_SOLUCTION])
		cMessage += "/"+AllTrim(aMessage[MODEL_MSGERR_SOLUCTION])
	EndIf
Return cMessage

/*/{Protheus.doc} ModeloOk
Verifica se ocorreram erros e questiona o usuário se deverá continuar com o processamento.
@type  Static Function
@author lucas.franca
@since 01/02/2019
@version P12
@param aModels, Array , Array com os modelos instanciados
@param aErros , Array , Array com os erros identificados durante a carga dos dados alterados.
@param oView  , Object, Objeto da view ativa.
@param oModel , Object, Modelo da tela de Modificação
@return lRet, Logical, Identifica se irá prosseguir com a alteração e commitar os dados.
/*/
Static Function ModeloOk(aModels,aErros,oView,oModel)
	Local lRet       := .T.
	Local lEncontrou := .F.
	Local cMsg       := ""
	Local nIndex     := 0
	Local aButtons   := {}
	Local oViewExec  := FWViewExec():New()
	Local oViewModal
	Local oMdlErro

	If Len(aErros) > 0
		//Verifica se existe ao menos um modelo que não está com erro, para realizar o commit.
		lEncontrou := .F.
		For nIndex := 1 To Len(aModels)
			If aModels[nIndex][3]
				lEncontrou := .T.
				Exit
			EndIf
		Next nIndex
		If !lEncontrou
			//Não existe nenhum modelo para realizar o commit.
			cMsg := STR0102 //"Não existem estruturas válidas para a alteração."
		Else
			//Existem modelos que podem ser commitados, e também existem modelos com erro.
			cMsg := STR0103 //"Ocorreram erros na modificação das estruturas. Deseja confirmar o processamento das estruturas que não possuem erro?"
		EndIf

		//Abre a modal para exibir os erros para o usuário.
		oViewModal := FWFormView():New(oView)
		oViewModal:SetModel(oModel)
		oViewModal:SetOperation(oView:GetOperation())

		//Adiciona um objeto TSay no topo da tela para exibir um texto de help.
		oViewModal:AddOtherObject("VIEWMESSAGE", {|oPanel| MontaText(oPanel,cMsg) })

		oViewModal:AddGrid("GRIDERROS",GetStruErr(2),"GRID_ERROS")

		oViewModal:CreateHorizontalBox("BOX_MESSAGE" ,50,,.T.)
		oViewModal:CreateHorizontalBox("BOX_GRID"    ,100)

		oViewModal:SetOwnerView("VIEWMESSAGE","BOX_MESSAGE")
		oViewModal:SetOwnerView("GRIDERROS","BOX_GRID")

		//Adiciona botão para cancelar
		oViewModal:AddUserButton(STR0105,"",{|oView|oView:CloseOwner()},STR0104,,,.T.) //"Cancelar"###"Cancela a operação"

		If oModel != Nil .And. oModel:isActive()
			//Carrega os erros na tela modal.
			oMdlErro := oModel:GetModel("GRID_ERROS")
			oMdlErro:ClearData(.F.,.T.)
			For nIndex := 1 To Len(aErros)
				If nIndex > 1
					oMdlErro:AddLine()
				EndIf
				oMdlErro:SetValue("CG1COD"   , aErros[nIndex][1])
				oMdlErro:SetValue("CG1COMP"  , aErros[nIndex][2])
				oMdlErro:SetValue("CG1TRT"   , aErros[nIndex][3])
				oMdlErro:SetValue("CG1REVINI", aErros[nIndex][4])
				oMdlErro:SetValue("CG1REVFIM", aErros[nIndex][5])
				oMdlErro:SetValue("CMENS"    , aErros[nIndex][6])
			Next nIndex

			//Habilita os botões da tela modal
			aAdd(aButtons,{.F.,Nil}) //Copiar
			aAdd(aButtons,{.F.,Nil}) //Recortar
			aAdd(aButtons,{.F.,Nil}) //Colar
			aAdd(aButtons,{.F.,Nil}) //Calculadora
			aAdd(aButtons,{.F.,Nil}) //Spool
			aAdd(aButtons,{.F.,Nil}) //Imprimir
			aAdd(aButtons,{lEncontrou,STR0106}) //Confirmar
			aAdd(aButtons,{.F.,STR0105}) //Cancelar
			aAdd(aButtons,{.F.,Nil}) //WalkTrhough
			aAdd(aButtons,{.F.,Nil}) //Ambiente
			aAdd(aButtons,{.F.,Nil}) //Mashup
			aAdd(aButtons,{.F.,Nil}) //Help
			aAdd(aButtons,{.F.,Nil}) //Formulário HTML
			aAdd(aButtons,{.F.,Nil}) //ECM

			//Abre a VIEW
			oViewExec:setModel(oModel)
			oViewExec:setView(oViewModal)
			oViewExec:setTitle(STR0107) //"Erros na modificação das estruturas"
			oViewExec:setOperation(oView:GetOperation())
			oViewExec:setReduction(40)
			oViewExec:setButtons(aButtons)
			oViewExec:SetCloseOnOk({|| .t.})
			oViewExec:SetCloseOnCancel({|| .t.})
			oViewExec:openView(.F.)

			If oViewExec:getButtonPress() != VIEW_BUTTON_OK
				//Se não clicou na opção "Confirmar", retorna .F. para não commitar os modelos.
				lRet := .F.
			Endif
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} MontaText
Monta um objeto tSay na tela para fixar a mensagem na view.
@type  Static Function
@author lucas.franca
@since 01/02/2019
@version P12
@param oPanel, Object   , Objeto do painel
@param cMsg  , Character, Mensagem que será exibida.
@return Nil
/*/
Static Function MontaText(oPanel,cMsg)
	Local oSay
	Local oFont

	Default lAutoMacao := .F.

	//Definições da fonte utilizada para exibir a mensagem
	oFont := TFont():New('Arial',,-16,,.T.)

	IF !lAutoMacao
		//Cria o objeto de texto na tela.
		oSay := TSay():New(03,01,{||cMsg},oPanel,/*cPicture*/,oFont,,,,.T.,/*nClrText*/,/*nClrBack*/,;
						oPanel:nClientWidth/2,oPanel:nClientHeight/2)
		//Habilita a quebra de linha do texto.
		oSay:lWordWrap = .T.
	ENDIF
Return Nil

/*/{Protheus.doc} A134AltVld
Valida se é possível marcar o componente para modificação.
@type  Function
@author lucas.franca
@since 04/02/2019
@version P12
@return lRet, Logical, Identifica se será possível marcar o componente
/*/
Function A134AltVld()

	Local lRet     := .T.
	Local nPCPRLEP := SuperGetMV("MV_PCPRLEP",.F., 2)
	Local oModel   := FwModelActive()
	Local oMdlGrid := oModel:GetModel("GRID_PRODUTOS")
	Local aAreaSG1 := SG1->(GetArea())
	Local aBloqueio

	Default lAutoMacao := .F.

	//Não permite selecionar os componentes que pertencem a lista de componentes quando MV_PCPRLEP == 1
	If lRet .and. nPCPRLEP == 1 .And. oMdlGrid:GetValue("LALTERA") .And. !Empty(oMdlGrid:GetValue("G1_LISTA"))
		lRet := .F.
		Help(,,"Help",,STR0108,; //"Componentes que pertencem a uma lista de componentes não podem ser modificados."
		     1,0,,,,,,{STR0109}) //"Selecione apenas componentes que não pertencem a uma lista de componentes."
	EndIf

	//Validacao de lock da SG1
	If RegValido(oMdlGrid)
		IF !lAutoMacao
			SG1->(DbGoTo(oMdlGrid:GetValue("RECNO")))
			If !SG1->(Eof())
				soRecNo := Iif(soRecNo == Nil, JsonObject():New(), soRecNo)
				If oMdlGrid:GetValue("LALTERA")
					If SG1->(SimpleLock())                              //Bloqueou registro atual da SG1
						soRecNo[cValToChar(SG1->(RecNo()))] := .T.

					Else                                                //NAO Bloqueou registro atual da SG1
						lRet      := .F.
						If soRecNo[cValToChar(SG1->(RecNo()))] == Nil .OR. !soRecNo[cValToChar(SG1->(RecNo()))]
							aBloqueio := StrTokArr(TCInternal(53),"|")
							//Esta estrutura 'X' está bloqueada para o usuário:
							Help( ,  , "Help", ,  STR0117 + AllTrim(SG1->G1_COD) + STR0118 + aBloqueio[1] + scCRLF + scCRLF + " [" + aBloqueio[2] + "]",;
									1, 0, , , , , , {STR0119}) //"Entre em contato com o usuário ou tente novamente."
						EndIf
						soRecNo[cValToChar(SG1->(RecNo()))] := .F.
					EndIf

				Else                                                  //Desbloqueia registro atual da SG1
					soRecNo[cValToChar(SG1->(RecNo()))] := Nil
					//Remove lock - Fonte PCPA200EVDEF
					SG1UnLockR(SG1->(RecNo()))

				EndIf
			EndIf
		ENDIF
	Else
		If oMdlGrid:GetValue("LALTERA")
			AfterCheck()
			lRet := .T.
		EndIf
	EndIf

	RestArea(aAreaSG1)

Return lRet

/*/{Protheus.doc} MontaHist
Monta array com os dados (da SG1) de todos os registros selecionados para alteração
@type  Static Function
@author douglas.heydt
@since 14/02/2019
@version P12
@param oModel, Object, Modelo de dados da tela de modificação
@return aHistory, Array, contem os registros da SG1 de cada um dos registros selecionados para alteração
/*/
Static Function MontaHist(oModel)

	Local cAliasHist := GetNextAlias()
	Local cCodComp  := ""
	Local cRevIni   := ""
	Local cRevFim   := ""
	Local cTrt      := ""
	Local nIndex    := 0
	Local aHistory  := {}
	Local cQuery		:= ""
	Local oMdlGrid  := oModel:GetModel("GRID_PRODUTOS")
	Local cCodPai   //:= oMdlGrid:GetValue("G1_COD")

	Default lAutoMacao := .F.

	SG1->(dbSetOrder(1))
	IF !lAutoMacao
		For nIndex := 1 To oMdlGrid:Length()
			If oMdlGrid:GetValue("LALTERA",nIndex)
				cCodPai := oMdlGrid:GetValue("G1_COD"  , nIndex)
				cCodComp := oMdlGrid:GetValue("G1_COMP"  , nIndex)
				cTrt     := oMdlGrid:GetValue("G1_TRT"   , nIndex)
				cRevIni  := oMdlGrid:GetValue("G1_REVINI", nIndex)
				cRevFim  := oMdlGrid:GetValue("G1_REVFIM", nIndex)

				cQuery := ""
				cQuery += " SELECT *"
				cQuery += " FROM " + RetSqlName("SG1")+" WHERE "
				cQuery += " G1_FILIAL = '"+ xFilial("SG1")+ "' AND"
				cQuery += " G1_COD = '"+cCodPai+"' AND"
				cQuery += " G1_COMP = '"+cCodComp+"' AND"
				cQuery += " G1_TRT = '"+cTrt+"' AND"
				cQuery += " G1_REVINI = '"+cRevIni+"' AND"
				cQuery += " G1_REVFIM = '"+cRevFim+"' AND"
				cQuery += " D_E_L_E_T_=' '"

				//Prepara variável cComplWhere com regras para filtro 1o Nível
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasHist,.T.,.T.)
				If (cAliasHist)->(!Eof())

					aAdd(aHistory,{	(cAliasHist)->G1_FILIAL,    (cAliasHist)->G1_COD,     (cAliasHist)->G1_COMP,;
									(cAliasHist)->G1_TRT,      (cAliasHist)->G1_QUANT,   (cAliasHist)->G1_PERDA,;
									(cAliasHist)->G1_INI,      (cAliasHist)->G1_FIM,     (cAliasHist)->G1_OBSERV,;
									(cAliasHist)->G1_FIXVAR,   (cAliasHist)->G1_GROPC,   (cAliasHist)->G1_OPC,;
									(cAliasHist)->G1_REVINI,   (cAliasHist)->G1_REVFIM,  (cAliasHist)->G1_NIV,;
									(cAliasHist)->G1_NIVINV,   (cAliasHist)->G1_POTENCI, (cAliasHist)->G1_VECTOR,;
									(cAliasHist)->G1_VLCOMPE,  (cAliasHist)->G1_TIPVEC,  (cAliasHist)->G1_OK,;
									(cAliasHist)->G1_LOCCONS,  (cAliasHist)->G1_FANTASM, (cAliasHist)->G1_LISTA,;
									(cAliasHist)->G1_USAALT})
				EndIf
				(cAliasHist)->(DbCloseArea())
			EndIf

		Next nIndex
	ENDIF

Return aHistory


/*/{Protheus.doc} GrvHistor
Função que grava os dados de histórico da SG1 na tabela T4D, levando em consideração aqueles
que mesmo selecionados não foram alterados devido a validação
@type  Static Function
@author douglas.heydt
@since 14/02/2019
@version P12
@param aHistory, Array, contem os registros da SG1 de cada um dos registros selecionados para alteração
@param aErros , Array , Array com os erros identificados durante a carga dos dados alterados.
/*/
Static Function GrvHistor(aHistory, aErros)

	Local nX
	Local cCodPai
	Local cCodComp
	Local cTrt
	Local cRevIni
	Local cRevFim

	DbSelectArea("T4D")
	For nX := 1 to Len(aHistory)

		cCodPai		:=	aHistory[nX][2]
		cCodComp	:=	aHistory[nX][3]
		cTrt		:=	aHistory[nX][4]
		cRevIni		:=	aHistory[nX][13]
		cRevFim		:=	aHistory[nX][14]

		nPos := aScan(aErros,{|x| x[1] == cCodPai .And. x[2] == cCodComp .And. x[3] == cTrt .And. x[4] == cRevIni .And. x[4] == cRevFim })
		If nPos == 0
			RecLock("T4D", .T.)
			T4D->T4D_FILIAL :=	aHistory[nX][1]
			T4D->T4D_COD	:=	aHistory[nX][2]
			T4D->T4D_COMP	:=	aHistory[nX][3]
			T4D->T4D_TRT	:=	aHistory[nX][4]
			T4D->T4D_QUANT	:=	aHistory[nX][5]
			T4D->T4D_PERDA	:=	aHistory[nX][6]
			T4D->T4D_INI	:=	STOD(aHistory[nX][7])
			T4D->T4D_FIM	:=	STOD(aHistory[nX][8])
			T4D->T4D_OBSERV	:=	aHistory[nX][9]
			T4D->T4D_FIXVAR	:=	aHistory[nX][10]
			T4D->T4D_GROPC	:=	aHistory[nX][11]
			T4D->T4D_OPC	:=	aHistory[nX][12]
			T4D->T4D_REVINI	:=	aHistory[nX][13]
			T4D->T4D_REVFIM	:=	aHistory[nX][14]
			T4D->T4D_NV		:=	aHistory[nX][15]
			T4D->T4D_NVINV	:=	aHistory[nX][16]
			T4D->T4D_POTENC	:=	aHistory[nX][17]
			T4D->T4D_OK		:=	aHistory[nX][18]
			T4D->T4D_TIPVEC	:=	aHistory[nX][19]
			T4D->T4D_VECTOR	:=	aHistory[nX][20]
			T4D->T4D_VLCOMP	:=	aHistory[nX][21]
			T4D->T4D_LOCCON	:=	aHistory[nX][22]
			T4D->T4D_FANTAS	:=	aHistory[nX][23]
			T4D->T4D_LISTA	:=	aHistory[nX][24]
			T4D->T4D_USAALT	:=	aHistory[nX][25]
			T4D->T4D_DTALT	:=	dDatabase
			T4D->T4D_HRALT	:=	Time()
			T4D->T4D_ALTPRG	:=	FunName()
			T4D->T4D_USRALT	:=	RetCodUsr()

			T4D->(MSUnlock())
		EndIf
	Next nX

Return

/*/{Protheus.doc} RegValido
Verifica se o registro ainda está válido para ser selecionado
@author marcelo.neumann
@since 26/04/2019
@version 1.0
@param oMdlGrid, object, modelo da grid do Modificar
@return lValido, logical, Indica se o registro ainda está válido
/*/
Static Function RegValido(oMdlGrid)

	Local lValido      := .T.
	Default lAutoMacao := .F.

	IF !lAutoMacao
		SG1->(DbGoTo(oMdlGrid:GetValue("RECNO")))
		If SG1->(Eof()) .Or. SG1->(Deleted())
			Return .F.
		Else
			If oMdlGrid:GetValue("G1_COD") <> SG1->G1_COD
				Return .F.
			ElseIf oMdlGrid:GetValue("G1_COMP") <> SG1->G1_COMP
				Return .F.
			ElseIf oMdlGrid:GetValue("G1_TRT") <> SG1->G1_TRT
				Return .F.
			ElseIf oMdlGrid:GetValue("G1_QUANT") <> SG1->G1_QUANT
				Return .F.
			ElseIf oMdlGrid:GetValue("G1_REVINI") <> SG1->G1_REVINI
				Return .F.
			ElseIf oMdlGrid:GetValue("G1_REVFIM") <> SG1->G1_REVFIM
				Return .F.
			ElseIf oMdlGrid:GetValue("G1_INI") <> SG1->G1_INI
				Return .F.
			ElseIf oMdlGrid:GetValue("G1_FIM") <> SG1->G1_FIM
				Return .F.
			EndIf
		EndIf
	ENDIF

Return lValido

/*/{Protheus.doc} AfterCheck
Trigger para verificar se deve ser fechada a tela e aberta novamente
@author marcelo.neumann
@since 26/04/2019
@version 1.0
@return Nil
/*/
Static Function AfterCheck()

	Local oViewExec := FwViewActive()
	Local oMdlGrid  := NIL //oViewExec:GetModel():GetModel("GRID_PRODUTOS")

	Default lAutoMacao := .F.

	IF !lAutoMacao
		oMdlGrid  := oViewExec:GetModel():GetModel("GRID_PRODUTOS")
	ENDIF

	HelpInDark(.F.)
	Help( , , "Help", , STR0120, 1, 0, , , , , ,) //"Este registro foi alterado por outro usuário. A tela será recarregada."
	HelpInDark(.T.)

	//Atualiza a View do PCPA134 (de trás), refazendo o filtro
	FwViewActive(soViewPai)

	IF !lAutoMacao
		A134RecCmp(soViewPai)
	ENDIF

	//Remove lock's - Fonte PCPA200EVDEF
	SG1UnLockR(,,soRecNo)
	soRecNo := Nil

	//Atualiza a grid da tela Modificar com os novos registros
	IF !lAutoMacao
		oMdlGrid:SetNoInsertLine(.F.)
		oMdlGrid:SetNoDeleteLine(.F.)
		oMdlGrid:ClearData(.F., .F.)
		oMdlGrid:DeActivate()
		oMdlGrid:Activate()
		CarregaMdl(soViewPai:GetModel(), oViewExec:GetModel())
		oViewExec:Refresh("V_GRID_PRODUTOS")
	ENDIF

Return
