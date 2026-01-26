// Bibliotecas necessárias
#Include "TOTVS.ch"
#Include "FWMVCDEF.ch"
#Include "TECA740L.ch"

// Definição de constantes
#Define DEF_TITULO_DO_CAMPO  01 // MODEL: Título do campo
#Define DEF_TOOLTIP_DO_CAMPO 02 // MODEL: Texto informativo (tooltip) exibido ao passar o mouse sobre o campo
#Define DEF_IDENTIFICADOR    03 // MODEL: Identificador do campo (field)
#Define DEF_TIPO_DO_CAMPO    04 // MODEL: Tipo de dado do campo
#Define DEF_TAMANHO_DO_CAMPO 05 // MODEL: Tamanho do campo
#Define DEF_DECIMAL_DO_CAMPO 06 // MODEL: Quantidade de decimais do campo
#Define DEF_CODEBLOCK_VALID  07 // MODEL: Bloco de código (code-block) de validação do campo
#Define DEF_CODEBLOCK_WHEN   08 // MODEL: Bloco de código (code-block) de desbloqueio (X3_WHEN) do campo
#Define DEF_LISTA_VAL        09 // MODEL: Lista de valores permitido do campo
#Define DEF_OBRIGAT          10 // MODEL: Indica se o campo tem preenchimento obrigatório
#Define DEF_CODEBLOCK_INIT   11 // MODEL: Bloco de código (code-block) de inicialização do campo
#Define DEF_CAMPO_CHAVE      12 // MODEL: Chave para indicar se este é um campo chave
#Define DEF_RECEBE_VAL       13 // MODEL: Chave para indicar se o campo pode receber valor em uma operação de alteração (update)
#Define DEF_VIRTUAL          14 // MODEL: Chave para indicar se o campo é virtual
#Define DEF_VALID_USER       15 // MODEL: Bloco de código (code-block) de validação em nível de usuário (X3_VLDUSR)
#Define DEF_ORDEM            16 // VIEW: Ordem de exibição do campo
#Define DEF_HELP             17 // VIEW: Lista (array) com o a mensagem de ajuda (Help) dos campos
#Define DEF_PICTURE          18 // VIEW: Máscara (picture) do campo
#Define DEF_PICT_VAR         19 // VIEW: Bloco de máscara (picture) variável
#Define DEF_LOOKUP           20 // VIEW: Chave para ser usado na Consulta Padrão (Lookup)
#Define DEF_CAN_CHANGE       21 // VIEW: Chave para habilitar a alteração/bloqueio do campo
#Define DEF_ID_FOLDER        22 // VIEW: Identificador da pasta (folder) onde o campo (field) está
#Define DEF_ID_GROUP         23 // VIEW: Identificador do grupo (group) onde o campo (field) está
#Define DEF_COMBO_VAL        24 // VIEW: Lista (array) com os valores da caixa de combinações (combo box)
#Define DEF_TAM_MAX_COMBO    25 // VIEW: Tamanho máximo da maior opção da caixa de combinações (combo box)
#Define DEF_INIC_BROWSE      26 // VIEW: Inicializador do navegador (browser)
#Define DEF_PICTURE_VARIAVEL 27 // VIEW: Chave para habilitar a máscara (picture) variável
#Define DEF_INSERT_LINE      28 // VIEW: Chave para habilitar salto de linha após o campo
#Define DEF_WIDTH            29 // VIEW: Largura fixa da apresentação do campo
#Define DEF_TIPO_CAMPO_VIEW  30 // VIEW: Tipo do campo
#Define QUANTIDADE_DEFS      30 // Quantidade de constantes de metadados (SX3) para montagem das telas

// Variáveis estáticas
Static aTCXLoad  := {}  // Lista de carga de dados no grid (LOAD)
Static cConfCal  := ""  // Código da memória/configuração de cálculo
Static cSheetXML := ""  // Memória de cálculo da planilha
Static oXMLSheet := NIL // Objeto da planilha XML
Static oParent   := NIL // Modelo pai (TECA740)
Static lAparece	:= .T.//Define se aparece o botão de "Confirmar" na tela

/*/{Protheus.doc} TECA740L
    Configuração de verbas adicionais relacionadas à despesas - Folha da planilha de despesas (TCX).
    @type Function
    @version 12.1.2210
    @author Guilherme Bigois
    @since 29/08/2023
    @param oModel, Object, Modelo de dados completo da rotina Orçamento de Serviços (TECA740)
    @return Variant, Retorno nulo fixado
/*/
Function TECA740L(oModel As Object) As Variant
    // Variáveis locais
    Local oView    As Object    // Objeto de manipulação da camada de apresentação (view)
    Local oMdlTFF  As Object    // Submodelo do modelo pai referente aos postos (TFF_RH)
    Local aRows    As Array     // Estado anterior das linhas do objeto pai
    Local aFolders As Array     // Abas ativas no objeto pai (TECA740: Orçamento de Serviços)
    Local aButtons As Array     // Operações disponíveis no botão "Outras Ações" da tela em criação
    Local cSheet   As Character // Código da planilha de preço
    Local cRevSh   As Character // Sequencial da revisão da planilha de preço
    Local cCodTFF  As Character // Código do Posto (TFF)
    Local lOK      As Logical   // Verifica se opção selecionada pelo usuário (0|.T. = Confirmar; 1|.F. = Cancelar)
    Local nOpc     As Numeric
    Local cTitle   As Character
    Local lRet     As Logical

    // Inicialização de variáveis
    oView    := FwViewActive()
    oMdlTFF  := oModel:GetModel("TFF_RH")
    aRows    := FwSaveRows()
    aFolders := oView:GetFolderActive("ABAS", 2)
    aButtons := {}
    cSheet   := ""
    cRevSh   := ""
    cCodTFF  := ""
    lOK      := .F.
    nOpc     := 0
    cTitle	 := STR0005
    lRet     := .T.

    // Inicia uma sequência de processamento
    BEGIN SEQUENCE
        // Gera exceção se a aba "RH - Postos" não estiver posicionada
        If (aFolders[1] != 2)
            Help(NIL, NIL, "AT740L_WRONG_FOLDER", NIL, STR0001, 1, 0, NIL, NIL, NIL, NIL, .F., {STR0002}) // 'Posto não selecionado.' # 'Selecione um posto na aba "Recursos Humanos" para utilizar esta função.'
            BREAK
        EndIf

		nOpc := oModel:GetOperation()

		//Se for visualização retira o botão de "Confirmar"
		If nOpc == 1
			lAparece := .F.
			cTitle += " - "+STR0021 //"Visualizar"
		EndIf

        // Adiciona os campos "Confirmar" e "Cancelar"
		aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{lAparece,Nil}/*Confirmar*/,{.T.,Nil}/*Cancelar*/,{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}

        // Captura os conteúdos necessários (estáticos e locais) para o Posicione()
        cSheet    := oMdlTFF:GetValue("TFF_PLACOD")
        cRevSh    := oMdlTFF:GetValue("TFF_PLAREV")
        cSheetXML := oMdlTFF:GetValue("TFF_CALCMD")
        cCodTFF   := oMdlTFF:GetValue("TFF_COD")
        oParent   := oModel

        // Gera exceção se a planilha de preço ou a memória de cálculo não estiverem preenchidas
        If (Empty(cSheet) .Or. Empty(cSheetXML))
            Help(NIL, NIL, "AT740L_EMPTY_LIST", NIL, STR0003, 1, 0, NIL, NIL, NIL, NIL, .F., {STR0004}) // 'Planilha de preços não encontrada' # 'Carregue uma planilha de preços para o posto selecionado.'
            BREAK
        EndIf

        // Captura o código da memória/configuração de cálculo
        cConfCal := Posicione("ABW", 1, FwXFilial("ABW") + cSheet + cRevSh, "ABW_CODTCW")

        // Exibe a tela para ajustes do usuário
        FwMsgRun(NIL, {||lOK := FwExecView(cTitle, ;
                                        "VIEWDEF.TECA740L", ;
                                        MODEL_OPERATION_INSERT, ;
                                        NIL, ;
                                        {|| TecModFalse(!lAparece)}, ;
                                        NIL, ;
                                        55, ;
                                        aButtons, ;
                                        {|| TecModFalse(.T.)}) == 0}, ;
                                NIL, STR0006) // 'Ajuste de Despesas' # 'Carregando dados...'

        // Apenas atualiza as informações se o usuário tiver clicado em OK
        If (lOK)
            // Atualiza as informações na TFF do modelo pai (Recursos Humanos)
            FwMsgRun(NIL, {|| ParentUpdate(oParent)}, NIL, STR0007) // 'Salvando dados...'
            oView:Refresh("VIEW_RH")
        EndIf

        If !lOK .Or. !lAparece
            lRet := .F.
        EndIf

    END SEQUENCE

    // Limpa as variáveis estáticas e restaura o estado anterior das linhas
    Clear()
    FwRestRows(aRows, oParent)

    // Remove os vetores da memória
    FwFreeArray(aRows)
    FwFreeArray(aFolders)
    FwFreeArray(aButtons)
Return lRet

/*/{Protheus.doc} ModelDef
    Regras de negócio definidas para o modelo atual.
    @type Function
    @version 12.1.2210
    @author Guilherme Bigois
    @since 29/08/2023
    @return Object, Modelo de dados completo da rotina atual
/*/
Static Function ModelDef() As Object
    // Variáveis locais
    Local oModel     As Object    // Modelo de dados da rotina atual
    Local oStruTCW   As Object    // Estrutura virtual de campos da configuração de cálculo
    Local oStruTCX   As Object    // Estrutura virtual de campos dos itens da configuração de cálculo
    Local aFields    As Array     // Lista de campos e suas estruturas (SX3 virtual)
    Local aTables    As Array     // Tabelas que comporão o modelo atual
    Local bCommit    As CodeBlock // Bloco de persistência
    Local bActive    As CodeBlock // Bloco de ativação e carga do modelo
    Local bPreLinTCX As CodeBlock // Bloco de pré-validação do submodelo
    Local nTable     As Numeric   // Contador do laço de tabelas
    Local nField     As Numeric   // Contador do laço de campos

    // Inicialização de variáveis
    oModel     := NIL
    oStruTCW   := FwFormModelStruct():New()
    oStruTCX   := FwFormModelStruct():New()
    aFields    := {}
    aTables    := {}
    bCommit    := {|oModel| Commit(oModel)}
    bActive    := {|oModel| Load(oModel)}
    bPreLinTCX := {|oGrid, nLine, cAction, cField, xOldValue, xNewValue| PreLinTCX(oGrid, nLine, cAction, cField, xOldValue, xNewValue)}
    nTable     := 0
    nField     := 0

    // Define as duas estruturas sem metadados
    oStruTCW:AddTable("TCW", NIL, FwSX2Util():GetX2Name("TCW")) // 'Configuracao de Calculo'
    oStruTCX:AddTable("TCX", NIL, FwSX2Util():GetX2Name("TCX")) // 'Itens da Configuracao de Calc.'

    // Define a lista de tabelas para montagem
    AAdd(aTables, {oStruTCW, "TCW"})
    AAdd(aTables, {oStruTCX, "TCX"})

    // Percorre a lista de tabelas para montagem
    For nTable := 1 To Len(aTables)
        // Carrega a estrutura de campos para a tabela em interação
        aFields := GetStruct(aTables[nTable][2])

        // Define a estrutura de modelo do campo em interação com base no retorno de GetStruct()
        For nField := 1 To Len(aFields)
            aTables[nTable][1]:AddField(aFields[nField][DEF_TITULO_DO_CAMPO ],;
                                        aFields[nField][DEF_TOOLTIP_DO_CAMPO],;
                                        aFields[nField][DEF_IDENTIFICADOR   ],;
                                        aFields[nField][DEF_TIPO_DO_CAMPO   ],;
                                        aFields[nField][DEF_TAMANHO_DO_CAMPO],;
                                        aFields[nField][DEF_DECIMAL_DO_CAMPO],;
                                        aFields[nField][DEF_CODEBLOCK_VALID ],;
                                        aFields[nField][DEF_CODEBLOCK_WHEN  ],;
                                        aFields[nField][DEF_LISTA_VAL       ],;
                                        aFields[nField][DEF_OBRIGAT         ],;
                                        aFields[nField][DEF_CODEBLOCK_INIT  ],;
                                        aFields[nField][DEF_CAMPO_CHAVE     ],;
                                        aFields[nField][DEF_RECEBE_VAL      ],;
                                        aFields[nField][DEF_VIRTUAL         ],;
                                        aFields[nField][DEF_VALID_USER      ])
        Next nField
    Next nTable

    // Define a estrutura do modelo principal
    oModel := MPFormModel():New("TECA740L", NIL, NIL, bCommit, NIL)
    oModel:SetDescription(STR0009) // 'Modelo de Ajuste de Despesas'

    // Definição do submodelo de cabeçalho
    oModel:AddFields("TCWMASTER", NIL, oStruTCW)
    oModel:GetModel("TCWMASTER"):SetDescription(STR0010) // 'Cabeçalho de Ajuste de Despesas'

    // Definição do submodelo de lista (grid)
    oModel:AddGrid("TCXDETAIL", "TCWMASTER", oStruTCX, bPreLinTCX)
    oModel:GetModel("TCXDETAIL"):SetDescription(STR0011) // 'Listagem de Verbas'

    If (TCW->(ColumnPos('TCW_REVISA')) > 0)
        oModel:SetRelation("TCXDETAIL", {{"TCX_FILIAL","xFilial('TCX')"}, {"TCX_CODTCW","TCW_CODIGO"}, {"TCX_REVISA","TCW_REVISA"}}, TCX->(IndexKey(1)))
    Else
        oModel:SetRelation("TCXDETAIL", {{"TCX_FILIAL","xFilial('TCX')"}, {"TCX_CODTCW","TCW_CODIGO"}}, TCX->(IndexKey(1)))
    EndIf

    // Define que o submodelo será opcional e não persistente
    oModel:GetModel("TCXDETAIL"):SetOnlyQuery(.T.)
    oModel:GetModel("TCXDETAIL"):SetOptional(.T.)

    // Define a chave primária e ativa o modelo
    oModel:SetPrimaryKey({"TCW_FILIAL", "TCW_CODIGO"})
    oModel:SetActivate(bActive)
Return (oModel)

/*/{Protheus.doc} ViewDef
    Regras de apresentação definidas para a visualização (view) atual.
    @type Function
    @version 12.1.2210
    @author Guilherme Bigois
    @since 29/08/2023
    @return Object, Camada de apresentação completa da rotina atual
/*/
Static Function ViewDef() As Object
    // Variáveis locais
    Local oModel   As Object  // Modelo de dados da rotina atual
    Local oView    As Object  // Camada de apresentação da rotina atual
    Local oStruTCW As Object  // Estrutura virtual de campos da configuração de cálculo
    Local oStruTCX As Object  // Estrutura virtual de campos dos itens da configuração de cálculo
    Local aFields  As Array   // Lista de campos e suas estruturas (SX3 virtual)
    Local aTables  As Array   // Tabelas que comporão o modelo atual
    Local nTable   As Numeric // Contador do laço de tabelas
    Local nField   As Numeric // Contador do laço de campos

    // Inicialização de variáveis
    oModel   := FwLoadModel("TECA740L")
    oView    := NIL
    oStruTCW := FwFormViewStruct():New()
    oStruTCX := FwFormViewStruct():New()
    aFields  := {}
    aTables  := {}
    nTable   := 0
    nField   := 0

    // Define a lista de tabelas para montagem
    AAdd(aTables, {oStruTCW, "TCW"})
    AAdd(aTables, {oStruTCX, "TCX"})

    // Percorre a lista de tabelas para montagem
    For nTable := 1 To Len(aTables)
        // Carrega a estrutura de campos para a tabela em interação
        aFields := GetStruct(aTables[nTable][2])

        // Define a estrutura de visualização do campo em interação com base no retorno de GetStruct()
        For nField := 1 To Len(aFields)
            aTables[nTable][1]:AddField(aFields[nField][DEF_IDENTIFICADOR   ],;
                                        aFields[nField][DEF_ORDEM           ],;
                                        aFields[nField][DEF_TITULO_DO_CAMPO ],;
                                        aFields[nField][DEF_TOOLTIP_DO_CAMPO],;
                                        aFields[nField][DEF_HELP            ],;
                                        aFields[nField][DEF_TIPO_CAMPO_VIEW ],;
                                        aFields[nField][DEF_PICTURE         ],;
                                        aFields[nField][DEF_PICT_VAR        ],;
                                        aFields[nField][DEF_LOOKUP          ],;
                                        aFields[nField][DEF_CAN_CHANGE      ],;
                                        aFields[nField][DEF_ID_FOLDER       ],;
                                        aFields[nField][DEF_ID_GROUP        ],;
                                        aFields[nField][DEF_COMBO_VAL       ],;
                                        aFields[nField][DEF_TAM_MAX_COMBO   ],;
                                        aFields[nField][DEF_INIC_BROWSE     ],;
                                        aFields[nField][DEF_VIRTUAL         ],;
                                        aFields[nField][DEF_PICTURE_VARIAVEL],;
                                        aFields[nField][DEF_INSERT_LINE     ],;
                                        aFields[nField][DEF_WIDTH           ])
        Next nField
    Next nTable

    // Instancia a camada de apresentação de define o modelo
    oView := FwFormView():New()
    oView:SetModel(oModel)

    oView:AddField("VIEW_CAB", oStruTCW, "TCWMASTER")
    oView:AddGrid("VIEW_GRID", oStruTCX, "TCXDETAIL")

    // Define o percentual de tamanho dos boxes
    oView:CreateHorizontalBox("TOP",    15)
    oView:CreateHorizontalBox("BOTTOM", 85)

    // Vincula os boxes às sub
    oView:SetOwnerView("VIEW_CAB",  "TOP")
    oView:SetOwnerView("VIEW_GRID", "BOTTOM")

    // Define a descrição da view
    oView:SetDescription(STR0012) // 'Visualização de Ajuste de Despesas'

    // Remove os campos de estrutura de grid
    oStruTCX:RemoveField("TCX_NICK")
    oStruTCX:RemoveField("TCX_NICKPO")
    oStruTCX:RemoveField("TCX_FORMUL")
    oStruTCX:RemoveField("TCX_TIPTBL")
    oStruTCX:RemoveField("TCX_CODTBL")
    oStruTCX:RemoveField("TCX_CODTCW")
Return (oView)

/*/{Protheus.doc} GetStruct
    Retorna a estrutura virtual de uma tabela conforme o apelido (alias) informado.
    @type Function
    @version 12.1.2210
    @author Guilherme Bigois
    @since 29/08/2023
    @param cTable, Character, Nome da tabela para obtenção da estrutura (TCW ou TCX)
    @return Array, Estrutura dos campos conforme tabela informada
/*/
Static Function GetStruct(cTable As Character) As Array
    // Variáveis locais
    Local nSize   As Numeric // Auxiliar de montagem do vetor de campos
    Local aStruct As Array   // Estrutura virtual de campos

    // Inicialização de variáveis
    nSize   := 0
    aStruct := {}

    // Definição de campos para a tabela TCW (cabeçalho) ou TCX (itens)
    If (cTable == "TCW")
        // TCW_CODIGO
        nSize++
        AAdd(aStruct, Array(QUANTIDADE_DEFS))
        aStruct[nSize][DEF_TITULO_DO_CAMPO]  := GetSX3Cache("TCW_CODIGO", "X3_TITULO") // Código
        aStruct[nSize][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache("TCW_CODIGO", "X3_TITULO") // Código
        aStruct[nSize][DEF_IDENTIFICADOR]    := "TCW_CODIGO"
        aStruct[nSize][DEF_TIPO_DO_CAMPO]    := "C"
        aStruct[nSize][DEF_TIPO_CAMPO_VIEW]  := "C"
        aStruct[nSize][DEF_TAMANHO_DO_CAMPO] := GetSX3Cache("TCW_CODIGO", "X3_TAMANHO")
        aStruct[nSize][DEF_DECIMAL_DO_CAMPO] := 0
        aStruct[nSize][DEF_CODEBLOCK_WHEN]   := {|| .F.}
        aStruct[nSize][DEF_OBRIGAT]          := .F.
        aStruct[nSize][DEF_RECEBE_VAL]       := .T.
        aStruct[nSize][DEF_VIRTUAL]          := .T.
        aStruct[nSize][DEF_ORDEM]            := "01"
        aStruct[nSize][DEF_PICTURE]          := "@!"
        aStruct[nSize][DEF_CAN_CHANGE]       := .T.

        // TCW_DESCRI
        nSize++
        AAdd(aStruct, Array(QUANTIDADE_DEFS))
        aStruct[nSize][DEF_TITULO_DO_CAMPO]  := GetSX3Cache("TCW_DESCRI", "X3_TITULO") // Descrição
        aStruct[nSize][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache("TCW_DESCRI", "X3_TITULO") // Descrição
        aStruct[nSize][DEF_IDENTIFICADOR]    := "TCW_DESCRI"
        aStruct[nSize][DEF_TIPO_DO_CAMPO]    := "C"
        aStruct[nSize][DEF_TIPO_CAMPO_VIEW]  := "C"
        aStruct[nSize][DEF_TAMANHO_DO_CAMPO] := GetSX3Cache("TCW_DESCRI", "X3_TAMANHO")
        aStruct[nSize][DEF_DECIMAL_DO_CAMPO] := 0
        aStruct[nSize][DEF_CODEBLOCK_WHEN]   := {|| .F.}
        aStruct[nSize][DEF_OBRIGAT]          := .F.
        aStruct[nSize][DEF_RECEBE_VAL]       := .T.
        aStruct[nSize][DEF_VIRTUAL]          := .T.
        aStruct[nSize][DEF_ORDEM]            := "02"
        aStruct[nSize][DEF_PICTURE]          := "@!"
        aStruct[nSize][DEF_CAN_CHANGE]       := .T.

        // TCW_CODCCT
        nSize++
        AAdd(aStruct, Array(QUANTIDADE_DEFS))
        aStruct[nSize][DEF_TITULO_DO_CAMPO]  := GetSX3Cache("TCW_CODCCT", "X3_TITULO") // Código CCT
        aStruct[nSize][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache("TCW_CODCCT", "X3_TITULO") // Código CCT
        aStruct[nSize][DEF_IDENTIFICADOR]    := "TCW_CODCCT"
        aStruct[nSize][DEF_TIPO_DO_CAMPO]    := "C"
        aStruct[nSize][DEF_TIPO_CAMPO_VIEW]  := "C"
        aStruct[nSize][DEF_TAMANHO_DO_CAMPO] := GetSX3Cache("TCW_CODCCT", "X3_TAMANHO")
        aStruct[nSize][DEF_DECIMAL_DO_CAMPO] := 0
        aStruct[nSize][DEF_CODEBLOCK_WHEN]   := {|| .F.}
        aStruct[nSize][DEF_OBRIGAT]          := .F.
        aStruct[nSize][DEF_RECEBE_VAL]       := .T.
        aStruct[nSize][DEF_VIRTUAL]          := .T.
        aStruct[nSize][DEF_ORDEM]            := "03"
        aStruct[nSize][DEF_PICTURE]          := "@!"
        aStruct[nSize][DEF_CAN_CHANGE]       := .T.
    ElseIf (cTable == "TCX")
        // TCX_DESCRI
        nSize++
        AAdd(aStruct, Array(QUANTIDADE_DEFS))
        aStruct[nSize][DEF_TITULO_DO_CAMPO]  := STR0008 // 'Verbas'
        aStruct[nSize][DEF_TOOLTIP_DO_CAMPO] := STR0008 // 'Verbas'
        aStruct[nSize][DEF_IDENTIFICADOR]    := "TCX_DESCRI"
        aStruct[nSize][DEF_TIPO_DO_CAMPO]    := "C"
        aStruct[nSize][DEF_TIPO_CAMPO_VIEW]  := "C"
        aStruct[nSize][DEF_TAMANHO_DO_CAMPO] := GetSX3Cache("TCX_DESCRI", "X3_TAMANHO")
        aStruct[nSize][DEF_DECIMAL_DO_CAMPO] := 0
        aStruct[nSize][DEF_CODEBLOCK_WHEN]   := {|| .F.}
        aStruct[nSize][DEF_OBRIGAT]          := .F.
        aStruct[nSize][DEF_RECEBE_VAL]       := .T.
        aStruct[nSize][DEF_VIRTUAL]          := .T.
        aStruct[nSize][DEF_ORDEM]            := "01"
        aStruct[nSize][DEF_PICTURE]          := "@!"
        aStruct[nSize][DEF_CAN_CHANGE]       := .F.

        // TCX_OBRGT
        nSize++
        AAdd(aStruct, Array(QUANTIDADE_DEFS))
        aStruct[nSize][DEF_TITULO_DO_CAMPO]  := STR0013 // 'Obrigatório?'
        aStruct[nSize][DEF_TOOLTIP_DO_CAMPO] := STR0013 // 'Obrigatório?'
        aStruct[nSize][DEF_IDENTIFICADOR]    := "TCX_OBRGT"
        aStruct[nSize][DEF_TIPO_DO_CAMPO]    := "C"
        aStruct[nSize][DEF_TIPO_CAMPO_VIEW]  := "C"
        aStruct[nSize][DEF_TAMANHO_DO_CAMPO] := 1
        aStruct[nSize][DEF_DECIMAL_DO_CAMPO] := 0
        aStruct[nSize][DEF_CODEBLOCK_WHEN]   := {|| .F.}
        aStruct[nSize][DEF_OBRIGAT]          := .F.
        aStruct[nSize][DEF_RECEBE_VAL]       := .T.
        aStruct[nSize][DEF_VIRTUAL]          := .T.
        aStruct[nSize][DEF_ORDEM]            := "02"
        aStruct[nSize][DEF_PICTURE]          := "9"
        aStruct[nSize][DEF_CAN_CHANGE]       := .F.
        aStruct[nSize][DEF_LISTA_VAL]        := {"1=" + STR0014, "2=" + STR0015} // 'Sim' # 'Não'
        aStruct[nSize][DEF_COMBO_VAL]        := {"1=" + STR0014, "2=" + STR0015} // 'Sim' # 'Não'

        // TCX_TIPTBL
        nSize++
        AAdd(aStruct, Array(QUANTIDADE_DEFS))
        aStruct[nSize][DEF_TITULO_DO_CAMPO]  := STR0016 // 'Tipo de taxa'
        aStruct[nSize][DEF_TOOLTIP_DO_CAMPO] := STR0016 // 'Tipo de taxa'
        aStruct[nSize][DEF_IDENTIFICADOR]    := "TCX_TIPTBL"
        aStruct[nSize][DEF_TIPO_DO_CAMPO]    := "C"
        aStruct[nSize][DEF_TIPO_CAMPO_VIEW]  := "C"
        aStruct[nSize][DEF_TAMANHO_DO_CAMPO] := GetSX3Cache("TCX_TIPTBL", "X3_TAMANHO")
        aStruct[nSize][DEF_DECIMAL_DO_CAMPO] := 0
        aStruct[nSize][DEF_CODEBLOCK_WHEN]   := {|| .F.}
        aStruct[nSize][DEF_OBRIGAT]          := .F.
        aStruct[nSize][DEF_RECEBE_VAL]       := .T.
        aStruct[nSize][DEF_VIRTUAL]          := .T.
        aStruct[nSize][DEF_ORDEM]            := "03"
        aStruct[nSize][DEF_PICTURE]          := "@!"
        aStruct[nSize][DEF_CAN_CHANGE]       := .F.

        // TCX_PORCEN
        nSize++
        AAdd(aStruct, Array(QUANTIDADE_DEFS))
        aStruct[nSize][DEF_TITULO_DO_CAMPO]  := STR0017 // 'Valor CCT'
        aStruct[nSize][DEF_TOOLTIP_DO_CAMPO] := STR0017 // 'Valor CCT'
        aStruct[nSize][DEF_IDENTIFICADOR]    := "TCX_PORCEN"
        aStruct[nSize][DEF_TIPO_DO_CAMPO]    := "N"
        aStruct[nSize][DEF_TIPO_CAMPO_VIEW]  := "N"
        aStruct[nSize][DEF_TAMANHO_DO_CAMPO] := GetSX3Cache("TCX_PORCEN", "X3_TAMANHO")
        aStruct[nSize][DEF_DECIMAL_DO_CAMPO] := 2
        aStruct[nSize][DEF_CODEBLOCK_WHEN]   := {|| .F.}
        aStruct[nSize][DEF_OBRIGAT]          := .F.
        aStruct[nSize][DEF_RECEBE_VAL]       := .T.
        aStruct[nSize][DEF_VIRTUAL]          := .T.
        aStruct[nSize][DEF_ORDEM]            := "04"
        aStruct[nSize][DEF_PICTURE]          := "@E 99,999,999,999.99"
        aStruct[nSize][DEF_CAN_CHANGE]       := .F.

        // TCX_PORALT
        nSize++
        AAdd(aStruct, Array(QUANTIDADE_DEFS))
        aStruct[nSize][DEF_TITULO_DO_CAMPO]  := STR0018 // 'Vl. Alterável'
        aStruct[nSize][DEF_TOOLTIP_DO_CAMPO] := STR0018 // 'Vl. Alterável'
        aStruct[nSize][DEF_IDENTIFICADOR]    := "TCX_PORALT"
        aStruct[nSize][DEF_TIPO_DO_CAMPO]    := "N"
        aStruct[nSize][DEF_TIPO_CAMPO_VIEW]  := "N"
        aStruct[nSize][DEF_TAMANHO_DO_CAMPO] := GetSX3Cache("TCX_PORALT", "X3_TAMANHO")
        aStruct[nSize][DEF_DECIMAL_DO_CAMPO] := 2
        aStruct[nSize][DEF_OBRIGAT]          := .F.
        aStruct[nSize][DEF_RECEBE_VAL]       := .T.
        aStruct[nSize][DEF_VIRTUAL]          := .T.
        aStruct[nSize][DEF_ORDEM]            := "05"
        aStruct[nSize][DEF_PICTURE]          := "@E 99,999,999,999.99"
        aStruct[nSize][DEF_CAN_CHANGE]       := .T.

        // TCX_NICKPO
        nSize++
        AAdd(aStruct, Array(QUANTIDADE_DEFS))
        aStruct[nSize][DEF_TITULO_DO_CAMPO]  := GetSX3Cache("TCX_NICKPO", "X3_TITULO") // Nome Porcent
        aStruct[nSize][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache("TCX_NICKPO", "X3_TITULO") // Nome Porcent
        aStruct[nSize][DEF_IDENTIFICADOR]    := "TCX_NICKPO"
        aStruct[nSize][DEF_TIPO_DO_CAMPO]    := "C"
        aStruct[nSize][DEF_TIPO_CAMPO_VIEW]  := "C"
        aStruct[nSize][DEF_TAMANHO_DO_CAMPO] := GetSX3Cache("TCX_NICKPO", "X3_TAMANHO")
        aStruct[nSize][DEF_DECIMAL_DO_CAMPO] := 0
        aStruct[nSize][DEF_CODEBLOCK_WHEN]   := {|| .F.}
        aStruct[nSize][DEF_OBRIGAT]          := .F.
        aStruct[nSize][DEF_RECEBE_VAL]       := .T.
        aStruct[nSize][DEF_VIRTUAL]          := .T.
        aStruct[nSize][DEF_ORDEM]            := "06"
        aStruct[nSize][DEF_PICTURE]          := "@!"
        aStruct[nSize][DEF_CAN_CHANGE]       := .F.

        // TCX_NICK
        nSize++
        AAdd(aStruct, Array(QUANTIDADE_DEFS))
        aStruct[nSize][DEF_TITULO_DO_CAMPO]  := GetSX3Cache("TCX_NICK", "X3_TITULO") // Nome Célula
        aStruct[nSize][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache("TCX_NICK", "X3_TITULO") // Nome Célula
        aStruct[nSize][DEF_IDENTIFICADOR]    := "TCX_NICK"
        aStruct[nSize][DEF_TIPO_DO_CAMPO]    := "C"
        aStruct[nSize][DEF_TIPO_CAMPO_VIEW]  := "C"
        aStruct[nSize][DEF_TAMANHO_DO_CAMPO] := GetSX3Cache("TCX_NICK", "X3_TAMANHO")
        aStruct[nSize][DEF_DECIMAL_DO_CAMPO] := 0
        aStruct[nSize][DEF_CODEBLOCK_WHEN]   := {|| .F.}
        aStruct[nSize][DEF_OBRIGAT]          := .F.
        aStruct[nSize][DEF_RECEBE_VAL]       := .T.
        aStruct[nSize][DEF_VIRTUAL]          := .T.
        aStruct[nSize][DEF_ORDEM]            := "07"
        aStruct[nSize][DEF_PICTURE]          := "@!"
        aStruct[nSize][DEF_CAN_CHANGE]       := .F.

        // TCX_FORMUL
        nSize++
        AAdd(aStruct, Array(QUANTIDADE_DEFS))
        aStruct[nSize][DEF_TITULO_DO_CAMPO]  := GetSX3Cache("TCX_FORMUL", "X3_TITULO") // Fórmula Vlr.
        aStruct[nSize][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache("TCX_FORMUL", "X3_TITULO") // Fórmula Vlr.
        aStruct[nSize][DEF_IDENTIFICADOR]    := "TCX_FORMUL"
        aStruct[nSize][DEF_TIPO_DO_CAMPO]    := "C"
        aStruct[nSize][DEF_TIPO_CAMPO_VIEW]  := "C"
        aStruct[nSize][DEF_TAMANHO_DO_CAMPO] := GetSX3Cache("TCX_FORMUL", "X3_TAMANHO")
        aStruct[nSize][DEF_DECIMAL_DO_CAMPO] := 0
        aStruct[nSize][DEF_CODEBLOCK_WHEN]   := {|| .F.}
        aStruct[nSize][DEF_OBRIGAT]          := .F.
        aStruct[nSize][DEF_RECEBE_VAL]       := .T.
        aStruct[nSize][DEF_VIRTUAL]          := .T.
        aStruct[nSize][DEF_ORDEM]            := "08"
        aStruct[nSize][DEF_PICTURE]          := "@!"
        aStruct[nSize][DEF_CAN_CHANGE]       := .F.

        // TCX_CODTBL
        nSize++
        AAdd(aStruct, Array(QUANTIDADE_DEFS))
        aStruct[nSize][DEF_TITULO_DO_CAMPO]  := GetSX3Cache("TCX_CODTBL", "X3_TITULO") // Cod. Tabela
        aStruct[nSize][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache("TCX_CODTBL", "X3_TITULO") // Cod. Tabela
        aStruct[nSize][DEF_IDENTIFICADOR]    := "TCX_CODTBL"
        aStruct[nSize][DEF_TIPO_DO_CAMPO]    := "C"
        aStruct[nSize][DEF_TIPO_CAMPO_VIEW]  := "C"
        aStruct[nSize][DEF_TAMANHO_DO_CAMPO] := GetSX3Cache("TCX_CODTBL", "X3_TAMANHO")
        aStruct[nSize][DEF_DECIMAL_DO_CAMPO] := 0
        aStruct[nSize][DEF_CODEBLOCK_WHEN]   := {|| .F.}
        aStruct[nSize][DEF_OBRIGAT]          := .F.
        aStruct[nSize][DEF_RECEBE_VAL]       := .T.
        aStruct[nSize][DEF_VIRTUAL]          := .T.
        aStruct[nSize][DEF_ORDEM]            := "09"
        aStruct[nSize][DEF_PICTURE]          := "@!"
        aStruct[nSize][DEF_CAN_CHANGE]       := .F.

        // TCX_CODTCW
        nSize++
        AAdd(aStruct, Array(QUANTIDADE_DEFS))
        aStruct[nSize][DEF_TITULO_DO_CAMPO]  := GetSX3Cache("TCX_CODTCW", "X3_TITULO") // Cod. Config
        aStruct[nSize][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache("TCX_CODTCW", "X3_TITULO") // Cod. Config
        aStruct[nSize][DEF_IDENTIFICADOR]    := "TCX_CODTCW"
        aStruct[nSize][DEF_TIPO_DO_CAMPO]    := "C"
        aStruct[nSize][DEF_TIPO_CAMPO_VIEW]  := "C"
        aStruct[nSize][DEF_TAMANHO_DO_CAMPO] := GetSX3Cache("TCX_CODTCW", "X3_TAMANHO")
        aStruct[nSize][DEF_DECIMAL_DO_CAMPO] := 0
        aStruct[nSize][DEF_CODEBLOCK_WHEN]   := {|| .F.}
        aStruct[nSize][DEF_OBRIGAT]          := .F.
        aStruct[nSize][DEF_RECEBE_VAL]       := .T.
        aStruct[nSize][DEF_VIRTUAL]          := .T.
        aStruct[nSize][DEF_ORDEM]            := "10"
        aStruct[nSize][DEF_PICTURE]          := "@!"
        aStruct[nSize][DEF_CAN_CHANGE]       := .F.
    EndIf
Return (aStruct)

/*/{Protheus.doc} Load
    Função de carga dos dados para o modelo virtual.
    @type Function
    @version 12.1.2210
    @author Guilherme Bigois
    @since 29/08/2023
    @param oModel, Object, Modelo de dados completo da rotina atual
    @return Variant, Retorno nulo fixado
/*/
Static Function Load(oModel As Object) As Variant
    // Variáveis locais
    Local aData   As Array     // Conjunto de dados para inserção nas linhas do grid
    Local nLine   As Numeric   // Contador do conjunto de linhas
    Local cBranch As Character // Filial da tabela TCW para montagem de Posicione()
    Local oMdlTCW As Object    // Submodelo do cabeçalho (TCW)
    Local oMdlTCX As Object    // Submodelo do grid (TCX)

    // Inicialização de variáveis
    aData   := GetData()
    nLine   := 0
    cBranch := FwXFilial("TCW")
    oMdlTCW := oModel:GetModel("TCWMASTER")
    oMdlTCX := oModel:GetModel("TCXDETAIL")

    // Preenche os campos do cabeçalho
    oMdlTCW:LoadValue("TCW_CODIGO", AllTrim(Posicione("TCW", 1, cBranch + cConfCal, "TCW_CODIGO")))
    oMdlTCW:LoadValue("TCW_DESCRI", AllTrim(Posicione("TCW", 1, cBranch + cConfCal, "TCW_DESCRI")))
    oMdlTCW:LoadValue("TCW_CODCCT", AllTrim(Posicione("TCW", 1, cBranch + cConfCal, "TCW_CODCCT")))

    oMdlTCX:SetNoInsertLine(.F.)
    oMdlTCX:SetNoDeleteLine(.F.)

    // Apenas prossegue com a carga do grid se houverem dados para tal
    If Len(aData) > 0
        // Percorre os dados retornados pela função GetData()
        For nLine := 1 To Len(aData)
            // Apenas adiciona mais linhas se for a partir da segunda
            If (nLine > 1)
                oMdlTCX:AddLine()
            EndIf

            // Posiciona na linha atual e insere as informações
            oMdlTCX:GoLine(nLine)
            oMdlTCX:LoadValue("TCX_DESCRI", aData[nLine][1][1])
            oMdlTCX:LoadValue("TCX_OBRGT",  aData[nLine][1][2])
            oMdlTCX:LoadValue("TCX_TIPTBL", aData[nLine][1][3])
            oMdlTCX:LoadValue("TCX_PORCEN", aData[nLine][1][4])
            oMdlTCX:LoadValue("TCX_PORALT", aData[nLine][1][5])
            oMdlTCX:LoadValue("TCX_NICKPO", aData[nLine][1][6])
            oMdlTCX:LoadValue("TCX_NICK",   aData[nLine][1][7])
            oMdlTCX:LoadValue("TCX_FORMUL", aData[nLine][1][8])
            oMdlTCX:LoadValue("TCX_CODTBL", aData[nLine][1][9])
            oMdlTCX:LoadValue("TCX_CODTCW", aData[nLine][1][10])
        Next nLine
    EndIf

    // Define o grid apenas como alteração
    oMdlTCX:SetNoInsertLine(.T.)
    oMdlTCX:SetNoDeleteLine(.T.)
    oMdlTCX:SetNoUpdateLine(.F.)

    If !lAparece
        oMdlTCX:SetNoUpdateLine(.T.)
    EndIf

Return (NIL)

/*/{Protheus.doc} GetData
    Consulta e prepara os dados que serão apresentados na listagem de verbas de cálculo.
    @type Function
    @version 12.1.2210
    @author Guilherme Bigois
    @since 29/08/2023
    @return Array, Dados das verbas de cálculo (TCX)
/*/
Static Function GetData() As Array
    // Variáveis locais
    Local cAliasTCX As Character // Alias da consulta de itens de cálculo (verbas)
    Local cType  As Character // Aba de despesas da rotina de configuração de cálculo
    Local aArea  As Array     // Área anteriormente posicionada
    Local aData  As Array     // Dados dos itens de cálculo
    Local aAux   As Array     // Auxiliar de montagem do vetor de itens de cálculo

    // Inicialização de variáveis
    cAliasTCX := GetNextAlias()
    cType  := "3"
    aArea  := FwGetArea()
    aData  := {}
    aAux   := {}

    // Pesquisa pelas configurações de cálculo da aba de despesas
    BEGINSQL ALIAS cAliasTCX
        SELECT
            TCX.TCX_DESCRI,
            TCX.TCX_TIPTBL,
            TCX.TCX_PORCEN,
            TCX.TCX_PORALT,
            TCX.TCX_NICKPO,
            TCX.TCX_NICK,
            TCX.TCX_FORMUL,
            TCX.TCX_OBRGT,
            TCX.TCX_CODTBL,
            TCX.TCX_CODTCW
        FROM
            %TABLE:TCX% TCX
        WHERE
            TCX.TCX_FILIAL = %XFILIAL:TCX%
            AND TCX.TCX_CODTCW = %EXP:cConfCal%
            AND TCX.TCX_TIPOPE = %EXP:cType%
            AND TCX.TCX_ITEM <> '001'
            AND TCX.%NOTDEL%
    ENDSQL

    // Percorre as linhas da consulta atual
    While (!EOF())
        // Preenche a linha atual
        AAdd(aAux, TCX_DESCRI)
        AAdd(aAux, TCX_OBRGT)
        AAdd(aAux, TCX_TIPTBL)
        AAdd(aAux, TCX_PORCEN)
        AAdd(aAux, TCX_PORALT)
        AAdd(aAux, TCX_NICKPO)
        AAdd(aAux, TCX_NICK)
        AAdd(aAux, TCX_FORMUL)
        AAdd(aAux, TCX_CODTBL)
        AAdd(aAux, TCX_CODTCW)

        // Adiciona uma nova linha e limpa o vetor auxiliar
        AAdd(aData, {aAux})
        aAux := {}

        // Salta para o próximo registro
        DBSkip()
    End

    (cAliasTCX)->(DbCloseArea())

    // Carrega os dados da planilha do posto em memória (variável estática)
    If (Len(aData) > 0)
        aTCXLoad := UpdateLoad(aData)
        aData := {}
    EndIf

    // Restaura a área anteriormente posicionada
    FwRestArea(aArea)

    // Remove os vetores da memória
    FwFreeArray(aAux)
    FwFreeArray(aData)
    FwFreeArray(aArea)
Return (aTCXLoad)

/*/{Protheus.doc} Clear
    Limpa variáveis estáticas devolvendo o seu estado inicial.
    @type Function
    @version 12.1.2210
    @author Guilherme Bigois
    @since 29/08/2023
    @return Variant, Retorno nulo fixado
/*/
Static Function Clear() As Variant
    // Devolve o conteúdo padrão das variáveis
    aTCXLoad  := {}
    cConfCal  := ""
    cSheetXML := ""
    oXMLSheet := NIL
    oParent   := NIL
    lAparece  := .T.
Return (NIL)

/*/{Protheus.doc} UpdateLoad
    Atualiza o array de carga de dados (GetData) com base no planilha.
    @type Function
    @version 12.1.2210
    @author Guilherme Bigois
    @since 29/08/2023
    @param aData, Array, Dados para carga da camada de apresentação (view)
    @return Array, Dados das verbas de cálculo (TCX) atualizado com a planilha
/*/
Static Function UpdateLoad(aData As Array) As Array
    // Variáveis locais
    Local nLine    As Numeric // Contador de laço de dados a serem carregador
    Local nPercent As Numeric // Percentual base definido para a verba

    // Inicialização de variáveis
    nLine    := 0
    nPercent := 0

    // Instancia e carrega o objeto da planilha de configurações de verbas
    oXMLSheet := FwUIWorkSheet():New(NIL, .F., NIL, 11, "PLAN_LOAD")
    oXMLSheet:LoadXMLModel(cSheetXML)

    // Percorre as verbas de cálculo
    For nLine := 1 To Len(aData)
        // Carrega o percentual CCT caso a verba seja obrigatória
        If (oXMLSheet:CellExists(AllTrim(aData[nLine][1][6])))
            // Captura o valor definido na planilha e o converte para numérico se necessário
            nPercent := oXMLSheet:GetCellValue(aData[nLine][1][6])
            aData[nLine][1][5] := IIf(ValType(nPercent) != "N", Val(nPercent), nPercent)
        Else
            // Define o valor como zerado se não for obrigatório
            If (aData[nLine][1][2] != "1")
                aData[nLine][1][5] := 0
            EndIf
        EndIf
    Next nLine
Return (aData)

/*/{Protheus.doc} PreLinTCX
    Atualiza o array de carga de dados (GetData) com base no planilha.
    @type Function
    @version 12.1.2210
    @author Guilherme Bigois
    @since 29/08/2023
    @param oGrid, Object, Submodelo da grid posicionada
    @param nLine, Numeric, Número da linha posicionada no grid
    @param cAction, Character, Ação que está sendo executada no campo da grid
    @param cField, Character, Campo da grid na linha atual onde a ação está ocorrendo
    @param xOldValue, Variant, Valor anterior a alteração
    @param xNewValue, Variant, Valor alvo da alteração
    @return Array, Dados das verbas de cálculo (TCX) atualizado com a planilha
/*/
Static Function PreLinTCX(oGrid As Object, nLine As Numeric, cAction As Character, cField As Character, xNewValue As Variant, xOldValue As Variant) As Logical
    // Variáveis locais
    Local lOK       As Logical // Retorno lógico da pré-validação
    Local lRequired As Logical // Flag de identificação de campo obrigatório
    Local nPercCCT  As Numeric // Percentual definido na CCT

    // Inicialização de variáveis
    lOK       := .T.
    lRequired := .T.
    nPercCCT  := 0

    // Apenas efetua a validação se o campo alterado for o percentual alterantivo
    If (cAction == "SETVALUE" .And. cField == "TCX_PORALT")
        // Define o campo como não obrigatório se o percentual estiver zerado e marcado como não obrigatório
        If (aTCXLoad[nLine][1][2] != "1" .And. xNewValue == 0)
            lRequired := .F.
        EndIf

        // Captura o percentual da CCT
        nPercCCT := oGrid:GetValue("TCX_PORCEN", nLine)

        // Gera exceção se o percentual da CCT for mais que zero, a verba obrigatória e o valor alternativo menor que a CCT
        If (nPercCCT != 0 .And. lRequired .And. xNewValue < nPercCCT)
            lOK := .F.
            Help(NIL, NIL, "AT740L_PRELIN", NIL, STR0019, 1, 0, NIL, NIL, NIL, NIL, .F., {STR0020 + CValToChar(nPercCCT) + "."}) // 'O Valor do campo não pode ser menor do que o estabelecido na CCT.' # 'O valor deve ser igual ou maior que X.'
        EndIf
    EndIf
Return (lOK)

/*/{Protheus.doc} Commit
    Responsável pela persistência do modelo de dados nas informações na planilha de cálculo.
    @type Function
    @version 12.1.2210
    @author Guilherme Bigois
    @since 29/08/2023
    @param oModel, Object, Modelo de dados completo da rotina atual
    @return Logical, Retorno lógico verdadeiro (.T.) fixado
/*/
Static Function Commit(oModel As Object) As Logical
    // Variáveis locais
    Local cFormula As Character // Fórmula que será inserida na coluna
    Local lUpdate  As Logical   // Indicador de atualização/criação de linhas
    Local nX       As Numeric   // Contador do laço da tabela TCX
    Local nLine    As Numeric   // Auxiliar de contagem de linhas da planilha
    Local oMdlTCX  As Object    // Submodelo de verbas (TCX) no modelo atual

    // Inicialização de variáveis
    cFormula := "=0"
    lUpdate  := .F.
    nX       := 0
    nLine    := 3
    oMdlTCX  := oModel:GetModel("TCXDETAIL")

    // Percoprre as linhas de verbas adicionais
    For nX := 1 To oMdlTCX:Length()
        oMdlTCX:GoLine(nX)

        // Define lógica de alteração de valores ou inserção de novos
        If oMdlTCX:GetValue("TCX_PORALT") != aTCXLoad[nX][1][5]
            // Habilita a flag de atualização do XML da planilha
            lUpdate := .T.

            // Altera os registros já existente com base no apelido (nickname) e caso não exista, os cria
            If (oXMLSheet:CellExists(oMdlTCX:GetValue("TCX_NICKPO")))
                oXMLSheet:SetCellValue(oMdlTCX:GetValue("TCX_NICKPO"),oMdlTCX:GetValue("TCX_PORALT"))
            Else
                // A partir da 3º linha, verifica se existe valor na linha seguinte até encontrar uma linha em branco
                While (ValType(oXMLSheet:GetCell("I" + CValToChar(nLine))) == "O")
                    nLine++
                End

                // Captura a fórmula definida para a verba
                If !Empty(oMdlTCX:GetValue("TCX_FORMUL"))
                    cFormula := "=" + AllTrim(oMdlTCX:GetValue("TCX_FORMUL"))
                EndIf

                // Coluna I: Descrição da verba
                oXMLSheet:SetCellValue("I" + CValToChar(nLine), oMdlTCX:GetValue("TCX_DESCRI"), NIL, .T.)

                // Coluna J: Valor
                oXMLSheet:SetNickName("J" + CValToChar(nLine), oMdlTCX:GetValue("TCX_NICKPO"))
                oXMLSheet:SetCellValue("J" + CValToChar(nLine), oMdlTCX:GetValue("TCX_PORALT"), NIL, .T.)

                // Coluna K: Fórmula
                oXMLSheet:SetNickName("K" + CValToChar(nLine), oMdlTCX:GetValue("TCX_NICK"))
                oXMLSheet:SetCellValue("K" + CValToChar(nLine), cFormula, NIL, .T.)
            EndIf
        EndIf
    Next nX

    // Se houve alterações, captura o XML atualizado se adicionar na TFF
    If (lUpdate)
        cSheetXML := oXMLSheet:GetXMLModel(NIL, NIL, NIL, NIL, .F., .T., .F.)

        If ExistBlock("at740LXml")
			ExecBlock("at740LXml",.F.,.F.,{oMdlTCX,cSheetXML})
		EndIf
    EndIf

    // Desativa o modelo de dados após a utilização
    oModel:DeActivate()
Return (.T.)

/*/{Protheus.doc} ParentUpdate
    Realiza a atualização dos totais e XML da planilha (POSTO TFF - RH).
    @type Function
    @version 12.1.2210
    @author Guilherme Bigois
    @since 29/08/2023
    @param oModel, Object, Modelo de dados completo da rotina atual
    @return Variant, Retorno nulo fixado
/*/
Static Function ParentUpdate(oModel As Object) As Variant
    // Variáveis locais
    Local nTotHR  As Numeric // Valor total vindos da planilha atualizada (TOTAL_CUSTO)
    Local nTotSh  As Numeric // Valor bruto vindos da planilha atualizada (TOTAL_BRUTO)
    Local oMdlTFF As Object  //

    // Inicialização de variáveis
    nTotHR  := 0
    nTotSh  := 0
    oMdlTFF := oParent:GetModel("TFF_RH")

    // Carrega novamente o XML para atualizar a planilha
    oXMLSheet:LoadXMLModel(cSheetXML)

    // Atualiza o valor de custo se o campo existir
    If (oXMLSheet:CellExists("TOTAL_CUSTO"))
        nTotHR := oXMLSheet:GetCellValue("TOTAL_CUSTO")
    EndIf

    // Atualiza o valor bruto se o campo existir
    If (oXMLSheet:CellExists("TOTAL_BRUTO"))
        nTotSh := oXMLSheet:GetCellValue("TOTAL_BRUTO")
    EndIf

    //Pega planilha atualizada
	oXMLSheet:Refresh(.T.)
	cSheetXML := oXMLSheet:GetXmlModel(,,,,.F.,.T.,.F.)

    // Altera a informação no modelo pai
    oMdlTFF:SetValue("TFF_CALCMD", cSheetXML)
    oMdlTFF:SetValue("TFF_PRCVEN", Round(nTotHR, GetSX3Cache("TFF_PRCVEN", "X3_DECIMAL")))
    oMdlTFF:SetValue("TFF_TOTPLA", Round(nTotSh, GetSX3Cache("TXS_TOTPLA", "X3_DECIMAL")))

    If ExistBlock("at740LUpd")
		ExecBlock("at740LUpd",.F.,.F.,{oMdlTFF,oXMLSheet})
	EndIf
Return (NIL)
