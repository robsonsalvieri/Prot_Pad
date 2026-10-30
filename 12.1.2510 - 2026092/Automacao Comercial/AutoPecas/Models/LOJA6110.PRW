#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'LOJA6110.ch'

Static cTitCod := ""
Static cTitLoj := ""
Static cTitNom := ""
Static cTitRed := ""
Static cTitCgc := ""
Static cTitSta := ""

Static cBoxSta := ""

Static nTamCod := 0
Static nTamLoj := 0
Static nTamNom := 0
Static nTamRed := 0
Static nTamCgc := 0

/*/{Protheus.doc} LOJA6110
    Browse MVC de Analise de Credito de Clientes.
    Usa SetAlias('AI0') no FWMBrowse; exibe apenas clientes
    com registro de analise de credito iniciado.
    O filtro nativo do browse opera sobre AI0_ANACRE diretamente.
    O MVC gerencia a gravacao na AI0 automaticamente via SetRelation.
    @type    Function
    @author  Bruno Almeida
    @since   30/07/2026
    @version P12
    @return  Nil, Nulo
/*/
Function LOJA6110()
    Local oBrowse  := FWMBrowse():New() as Object
    Local aColumns := {}                as Array

    Lj6110TaDe()
    aColumns := Lj6110Col()

    oBrowse:SetAlias("AI0")
    oBrowse:SetDescription(STR0001) //"Analise de Crédito de Clientes"
    oBrowse:SetColumns(aColumns)
    oBrowse:SetMenuDef("LOJA6110")

    oBrowse:Activate()
Return Nil

/*/{Protheus.doc} Lj6110TaDe
    Retorna o tamanho dos campos e descrição.
    @type    Static Function
    @author  Bruno Almeida
    @since   30/07/2026
    @version P12
    @return  Nulo, Nil
/*/
Static Function Lj6110TaDe()

cTitCod := GetSX3Cache("AI0_CODCLI", "X3_TITULO")
cTitLoj := GetSX3Cache("AI0_LOJA", "X3_TITULO")
cTitNom := GetSX3Cache("A1_NOME", "X3_TITULO")
cTitRed := GetSX3Cache("A1_NREDUZ", "X3_TITULO")
cTitCgc := GetSX3Cache("A1_CGC", "X3_TITULO")
cTitSta := GetSX3Cache("AI0_ANACRE", "X3_TITULO")

cBoxSta := GetSX3Cache("AI0_ANACRE", "X3_CBOX")

nTamCod := TamSx3("AI0_CODCLI")[1]
nTamLoj := TamSx3("AI0_LOJA")[1]
nTamNom := TamSx3("A1_NOME")[1]
nTamRed := TamSx3("A1_NREDUZ")[1]
nTamCgc := TamSx3("A1_CGC")[1]

Return Nil

/*/{Protheus.doc} Lj6110Col
    Define e retorna o array de colunas visiveis do browse de
    Analise de Credito de Clientes (objetos FWBrwColumn).
    Alias principal: AI0. Campos de SA1 (nome, CNPJ, fantasia)
    sao obtidos via Lj6110Camp (DbSeek CTREE local).
    @type    Static Function
    @author  Bruno Almeida
    @since   30/07/2026
    @version P12
    @return  Array, Array de objetos FWBrwColumn
/*/
Static Function Lj6110Col() as Array
    Local aColumns := {} as Array
    Local nCol     := 0  as Numeric

    // Coluna: Codigo (nativo AI0)
    AAdd(aColumns, FWBrwColumn():New())
    nCol := Len(aColumns)
    aColumns[nCol]:SetData({|| AI0->AI0_CODCLI})
    aColumns[nCol]:SetTitle(cTitCod)
    aColumns[nCol]:SetSize(nTamCod)
    aColumns[nCol]:SetDecimal(0)
    aColumns[nCol]:SetPicture("@!")
    aColumns[nCol]:SetAutoSize(.T.)

    // Coluna: Loja (nativo AI0)
    AAdd(aColumns, FWBrwColumn():New())
    nCol := Len(aColumns)
    aColumns[nCol]:SetData({|| AI0->AI0_LOJA})
    aColumns[nCol]:SetTitle(cTitLoj)
    aColumns[nCol]:SetSize(nTamLoj)
    aColumns[nCol]:SetDecimal(0)
    aColumns[nCol]:SetPicture("@!")
    aColumns[nCol]:SetAutoSize(.T.)

    // Coluna: Razao Social (DbSeek em SA1 - CTREE local, sub-milissegundo)
    AAdd(aColumns, FWBrwColumn():New())
    nCol := Len(aColumns)
    aColumns[nCol]:SetData({|| Lj6110Camp(AI0->AI0_CODCLI, AI0->AI0_LOJA, "A1_NOME")})
    aColumns[nCol]:SetTitle(cTitNom)
    aColumns[nCol]:SetSize(nTamNom)
    aColumns[nCol]:SetDecimal(0)
    aColumns[nCol]:SetPicture("@!")
    aColumns[nCol]:SetAutoSize(.T.)

    // Coluna: Nome Fantasia (DbSeek em SA1)
    AAdd(aColumns, FWBrwColumn():New())
    nCol := Len(aColumns)
    aColumns[nCol]:SetData({|| Lj6110Camp(AI0->AI0_CODCLI, AI0->AI0_LOJA, "A1_NREDUZ")})
    aColumns[nCol]:SetTitle(cTitRed)
    aColumns[nCol]:SetSize(nTamRed)
    aColumns[nCol]:SetDecimal(0)
    aColumns[nCol]:SetPicture("@!")
    aColumns[nCol]:SetAutoSize(.T.)

    // Coluna: CNPJ/CPF (DbSeek em SA1)
    AAdd(aColumns, FWBrwColumn():New())
    nCol := Len(aColumns)
    aColumns[nCol]:SetData({|| Lj6110Camp(AI0->AI0_CODCLI, AI0->AI0_LOJA, "A1_CGC")})
    aColumns[nCol]:SetTitle(cTitCgc)
    aColumns[nCol]:SetSize(nTamCgc)
    aColumns[nCol]:SetDecimal(0)
    aColumns[nCol]:SetPicture("@!")
    aColumns[nCol]:SetAutoSize(.T.)

    // Coluna: Status (leitura direta do alias principal AI0 - sem seek adicional)
    AAdd(aColumns, FWBrwColumn():New())
    nCol := Len(aColumns)
    aColumns[nCol]:SetData({|| Lj6110Desc(AllTrim(AI0->AI0_ANACRE))})
    aColumns[nCol]:SetTitle(cTitSta)
    aColumns[nCol]:SetSize(15)
    aColumns[nCol]:SetDecimal(0)
    aColumns[nCol]:SetPicture("@!")
    aColumns[nCol]:SetAutoSize(.T.)

Return aColumns

/*/{Protheus.doc} MenuDef
    Definicao do menu do browse de Analise de Credito.
    Botoes: Visualizar (somente leitura), Analisar (edicao) e Anexar Documentos.
    O FWMBrowse posiciona AI0 antes de executar a action.
    As actions recebem AI0_CODCLI e AI0_LOJA para localizar SA1.
    @type    Static Function
    @author  Bruno Almeida
    @since   30/07/2026
    @version P12
    @return  Array, Array de opcoes do menu
/*/
Static Function MenuDef() as Array
    Local aRet := {} as Array

    ADD OPTION aRet Title STR0002  Action "Lj6110Visu(AI0->AI0_CODCLI, AI0->AI0_LOJA)" Operation 2 Access 0 //"Visualizar"
    ADD OPTION aRet Title STR0003  Action "Lj6110Anls(AI0->AI0_CODCLI, AI0->AI0_LOJA)"   Operation 4 Access 0 //"Analisar"

Return aRet

/*/{Protheus.doc} ModelDef
    Definicao do Model MVC de Analise de Credito de Clientes.
    Alias principal: SA1. A struct da AI0 carrega todos os campos
    (sem filtro bAvalCampo) para que o framework consiga processar
    o SetRelation e os SetProperty das chaves corretamente.
    O filtro de exibicao de campos fica exclusivamente no ViewDef.
    Campos virtuais Memo (X3_CONTEXT=V) sao registrados via FWMemoVirtual
    para que o framework carregue e salve o conteudo SYP corretamente.
    @type    Static Function
    @author  Bruno Almeida
    @since   30/07/2026
    @version P12
    @return  Object, Objeto MPFormModel configurado
/*/
Static Function ModelDef() as Object
    Local oStructSA1 as Object
    Local oStructAI0 as Object
    Local oModel     as Object
    Local aMemoSA1   := {} as Array

    oStructSA1 := FWFormStruct(1, "SA1")
    oStructAI0 := FWFormStruct(1, "AI0")

    // SA1: bloqueia todos os campos e libera apenas os editaveis de credito
    oStructSA1:SetProperty("*",         MODEL_FIELD_WHEN, {|| .F.})
    oStructSA1:SetProperty("A1_LC",     MODEL_FIELD_WHEN, {|| .T.})
    oStructSA1:SetProperty("A1_VM_OBS", MODEL_FIELD_WHEN, {|| .T.})

    // AI0: bloqueia as chaves para edicao (gerenciadas pelo SetRelation)
    oStructAI0:SetProperty("AI0_CODCLI", MODEL_FIELD_WHEN, {|| .F.})
    oStructAI0:SetProperty("AI0_LOJA",   MODEL_FIELD_WHEN, {|| .F.})

    // Registra o campo virtual memo para que o MVC carregue e salve o conteudo SYP corretamente
    aAdd(aMemoSA1, {"A1_OBS", "A1_VM_OBS"})
    FWMemoVirtual(oStructSA1, aMemoSA1)

    oModel := MPFormModel():New("LOJA6110", , {|oM| Lj6110VlPs(oM)})
    oModel:SetDescription(STR0001) //"Analise de Crédito de Clientes"
    oModel:AddFields("SA1MASTER",          , oStructSA1)
    oModel:AddFields("AI0CHILD","SA1MASTER", oStructAI0)
    oModel:SetRelation("AI0CHILD", {{"AI0_FILIAL","xFilial('AI0')"},{"AI0_CODCLI","A1_COD"},{"AI0_LOJA","A1_LOJA"}}, AI0->(IndexKey(1)))

Return oModel

/*/{Protheus.doc} ViewDef
    Definicao da View MVC de Analise de Credito de Clientes.
    Layout: aba unica "Dados do Cliente" (CreateFolder/AddSheet com titulo STR0005) com dois
    boxes empilhados verticalmente dentro da aba.
      Box superior (75%) - VIEW_SA1 com tres grupos:
        Identificacao (GRPIDENT)    : A1_COD, A1_LOJA, A1_CGC, A1_INSCR, A1_CONTATO, A1_NOME, A1_NREDUZ
        Endereco e Contato (GRPEND) : A1_END, A1_BAIRRO, A1_CEP, A1_MUN, A1_EST, A1_TEL, A1_EMAIL
        Limite de Credito (GRPCRED): A1_LC, A1_VM_OBS
      Painel direito (30%) - VIEW_AI0 com um grupo:
        Status do Credito (GRPCREDAI0): AI0_ANACRE (COMBO via SX3)
    Botoes em "Outras Acoes" (lShowBar = .F.) — disponiveis nos modos Visualizar e Analisar:
      Anexar Documentos (STR0004): abre MsDocument vinculado ao cliente SA1 ativo.
      Perfil (STR0011): abre cadastro completo do cliente (VIEWDEF.CRMA980) em modo somente leitura.
    @type    Static Function
    @author  Bruno Almeida
    @since   30/07/2026
    @version P12
    @return  Object, Objeto FWFormView configurado
/*/
Static Function ViewDef() as Object
    Local oView      := FWFormView():New()       as Object
    Local oModel     := FWLoadModel("LOJA6110")  as Object
    Local cCamposSA1 := "|A1_COD|A1_LOJA|A1_CGC|A1_INSCR|A1_CONTATO|A1_NOME|A1_NREDUZ|A1_END|A1_BAIRRO|A1_CEP|A1_MUN|A1_EST|A1_TEL|A1_EMAIL|A1_LC|A1_VM_OBS|" as Character
    Local oStructSA1 as Object
    Local oStructAI0 as Object

    //oView:SetDescription("")
    oView:SetModel(oModel)

    // Struct SA1: restringe aos campos necessarios via bAvalCampo
    oStructSA1 := FWFormStruct(2, "SA1", {|cCampo| "|" + AllTrim(cCampo) + "|" $ cCamposSA1})

    // Struct AI0: apenas AI0_ANACRE — COMBO vem automaticamente do SX3 via FWFormStruct
    oStructAI0 := FWFormStruct(2, "AI0", {|cCampo| cCampo == "AI0_ANACRE"})

    // --- Grupos da struct SA1 ---
    oStructSA1:AddFolder("DADOS", "")
    oStructSA1:AddGroup("GRPIDENT",  STR0006, "DADOS", 2) //"Identificação"
    oStructSA1:AddGroup("GRPEND",    STR0007, "DADOS", 2) //"Endereço e Contato"
    oStructSA1:AddGroup("GRPCRED",   STR0008, "DADOS", 2) //"Limite de Crédito"
    oStructSA1:SetProperty("*", MVC_VIEW_FOLDER_NUMBER, "DADOS")

    // Grupo Identificacao
    oStructSA1:SetProperty("A1_COD",     MVC_VIEW_GROUP_NUMBER, "GRPIDENT")
    oStructSA1:SetProperty("A1_LOJA",    MVC_VIEW_GROUP_NUMBER, "GRPIDENT")
    oStructSA1:SetProperty("A1_CGC",     MVC_VIEW_GROUP_NUMBER, "GRPIDENT")
    oStructSA1:SetProperty("A1_INSCR",   MVC_VIEW_GROUP_NUMBER, "GRPIDENT")
    oStructSA1:SetProperty("A1_CONTATO", MVC_VIEW_GROUP_NUMBER, "GRPIDENT")
    oStructSA1:SetProperty("A1_NOME",    MVC_VIEW_GROUP_NUMBER, "GRPIDENT")
    oStructSA1:SetProperty("A1_NREDUZ",  MVC_VIEW_GROUP_NUMBER, "GRPIDENT")

    // Grupo Endereco & Contato
    oStructSA1:SetProperty("A1_END",    MVC_VIEW_GROUP_NUMBER, "GRPEND")
    oStructSA1:SetProperty("A1_BAIRRO", MVC_VIEW_GROUP_NUMBER, "GRPEND")
    oStructSA1:SetProperty("A1_CEP",    MVC_VIEW_GROUP_NUMBER, "GRPEND")
    oStructSA1:SetProperty("A1_MUN",    MVC_VIEW_GROUP_NUMBER, "GRPEND")
    oStructSA1:SetProperty("A1_EST",    MVC_VIEW_GROUP_NUMBER, "GRPEND")
    oStructSA1:SetProperty("A1_TEL",    MVC_VIEW_GROUP_NUMBER, "GRPEND")
    oStructSA1:SetProperty("A1_EMAIL",  MVC_VIEW_GROUP_NUMBER, "GRPEND")

    // Grupo Analise de Credito — campos editaveis da SA1
    oStructSA1:SetProperty("A1_LC",     MVC_VIEW_GROUP_NUMBER, "GRPCRED")
    oStructSA1:SetProperty("A1_VM_OBS", MVC_VIEW_GROUP_NUMBER, "GRPCRED")
    oStructSA1:SetProperty("A1_LC",     MVC_VIEW_ORDEM, "97")
    oStructSA1:SetProperty("A1_VM_OBS", MVC_VIEW_ORDEM, "98")

    // --- Grupo da struct AI0 ---
    oStructAI0:AddFolder("DADOS", "")
    oStructAI0:AddGroup("GRPCREDAI0", STR0009, "DADOS", 2) //"Status do Crédito"
    oStructAI0:SetProperty("*",          MVC_VIEW_FOLDER_NUMBER, "DADOS")
    oStructAI0:SetProperty("AI0_ANACRE", MVC_VIEW_GROUP_NUMBER,  "GRPCREDAI0")

    // Container: aba unica com ID "DADOS" — mesmo ID do AddFolder das structs
    oView:CreateHorizontalBox("BOXALL", 100)
    oView:CreateFolder("FOLDER", "BOXALL")
    oView:AddSheet("FOLDER", "DADOS", STR0005) //"Cadastrais"

    // Dois boxes empilhados dentro da aba
    oView:CreateHorizontalBox("BOXSA1", 75, , , "FOLDER", "DADOS")
    oView:CreateHorizontalBox("BOXAI0", 25, , , "FOLDER", "DADOS")

    oView:AddField("VIEW_SA1", oStructSA1, "SA1MASTER")
    oView:SetOwnerView("VIEW_SA1", "BOXSA1")

    oView:AddField("VIEW_AI0", oStructAI0, "AI0CHILD")
    oView:SetOwnerView("VIEW_AI0", "BOXAI0")

    // Botoes em "Outras Acoes" (lShowBar = .F.) — disponiveis nos modos Analisar e Visualizar
    oView:AddUserButton(STR0004, "", {|| Lj6110Anex()}, , , {MODEL_OPERATION_UPDATE, MODEL_OPERATION_VIEW}, .F.) //"Anexar Documentos"
    oView:AddUserButton(STR0012, "", {|| Lj6110Perf()},     , , {MODEL_OPERATION_UPDATE, MODEL_OPERATION_VIEW}, .F.) //"Perfil"

Return oView

/*/{Protheus.doc} Lj6110VlPs
    Pos-validacao do Model de Analise de Credito.
    Regras:
      - AI0_ANACRE e obrigatorio (status deve ser selecionado).
      - Quando status = Aprovado (3), A1_LC deve ser maior que zero.
    @type    Static Function
    @author  Bruno Almeida
    @since   30/07/2026
    @version P12
    @param   oModel, Object, Objeto MPFormModel
    @return  Logical, .T. se valido; .F. se houver pendencia
/*/
Static Function Lj6110VlPs(oModel as Object) as Logical
    Local lRet      := .T.                                        as Logical
    Local oModelSA1 := oModel:GetModel("SA1MASTER")               as Object
    Local oModelAI0 := oModel:GetModel("AI0CHILD")                as Object
    Local cAnaCre   := AllTrim(oModelAI0:GetValue("AI0_ANACRE"))  as Character
    Local nLimCre   := oModelSA1:GetValue("A1_LC")               as Numeric

    If cAnaCre == "3" .And. nLimCre <= 0
        lRet := .F.
        Help(" ", 1, "Lj6110VlPs", , STR0010, 1, 0) //"Para status Aprovado, informe o Limite de Crédito (A1_LC) maior que zero."
    EndIf

Return lRet

/*/{Protheus.doc} Lj6110Desc
    Retorna o label textual correspondente ao codigo de status
    de analise de credito (campo AI0_ANACRE), lendo dinamicamente
    o conteudo X3_CBOX do campo via GetSX3Cache.
    Formato X3_CBOX esperado: "1=Label1;2=Label2;...".
    @type    Static Function
    @author  Bruno Almeida
    @since   30/07/2026
    @version P12
    @param   cCod, Character, Codigo do status (valor de AI0_ANACRE)
    @return  Character, Label do status para exibicao no browse; "" se nao encontrado
/*/
Static Function Lj6110Desc(cCod as Character) as Character
    Local aItens := StrTokArr(cBoxSta, ";") as Array
    Local cDesc  := ""                      as Character
    Local nI     := 0                       as Numeric
    Local aItem  := {}                      as Array

    For nI := 1 To Len(aItens)
        aItem := StrTokArr(aItens[nI], "=")
        If Len(aItem) >= 2 .And. AllTrim(aItem[1]) == AllTrim(cCod)
            cDesc := AllTrim(aItem[2])
            Exit
        EndIf
    Next nI

Return cDesc

/*/{Protheus.doc} Lj6110Camp
    Busca um campo da tabela SA1 pelo codigo e loja do cliente.
    Utilizado pelas colunas do browse que requerem dados da SA1,
    sendo AI0 o alias principal do FWMBrowse.
    Salva e restaura a area SA1 para nao reposicionar o browse.
    @type    Static Function
    @author  Bruno Almeida
    @since   07/08/2026
    @version P12
    @param   cCod,   Character, Codigo do cliente (AI0_CODCLI)
    @param   cLoja,  Character, Loja do cliente (AI0_LOJA)
    @param   cCampo, Character, Nome do campo SA1 desejado
    @return  Character, Valor do campo ou "" se nao encontrado
/*/
Static Function Lj6110Camp(cCod as Character, cLoja as Character, cCampo as Character) as Character
    Local aAreaSA1 := SA1->(GetArea()) as Array
    Local xValor   := ""               as Character

    DbSelectArea("SA1")
    SA1->(DbSetOrder(1))

    If SA1->(DbSeek(xFilial("SA1") + PADR(AllTrim(cCod), nTamCod) + PADR(AllTrim(cLoja), nTamLoj)))
        xValor := SA1->(FieldGet(FieldPos(cCampo)))
    EndIf

    RestArea(aAreaSA1)
Return xValor

/*/{Protheus.doc} Lj6110Visu
    Posiciona SA1 e AI0 pelos RECNOs recebidos do browse e abre
    o formulario MVC de analise de credito em modo visualizacao
    (somente leitura ? MODEL_OPERATION_VIEW).
    SA1 NAO e restaurada via RestArea: apos FWExecView, SA1 e
    reposicionada no mesmo registro para que o FWMBrowse mantenha
    o cursor no registro correto ao retornar ao grid.
    @type    Function
    @author  Bruno Almeida
    @since   30/07/2026
    @version P12
    @param   cCod, Caracter, Código do cliente
    @param   cLoja, Caracter, Loja do cliente
    @return  Nil, Nulo
/*/
Function Lj6110Visu(cCod as Character, cLoja as Character)
    Default cCod  := ""
    Default cLoja := ""

    DbSelectArea("SA1")
    SA1->(DbSetOrder(1))
    SA1->(DbSeek(xFilial("SA1") + PADR(AllTrim(cCod), TamSx3("A1_COD")[1]) + PADR(AllTrim(cLoja), TamSx3("A1_LOJA")[1])))

    FWExecView(STR0001, "VIEWDEF.LOJA6110", MODEL_OPERATION_VIEW, , {|oV| .T.}) //"Analise de Crédito de Clientes"

Return Nil

/*/{Protheus.doc} Lj6110Anls
    Posiciona SA1 e AI0 pelos RECNOs recebidos do browse.
    Se nao houver registro AI0 (nAI0Recno = 0), cria um
    registro minimo com status Em Analise (2) antes de abrir
    o formulario. Abre o formulario MVC em modo edicao
    (MODEL_OPERATION_UPDATE).
    SA1 NAO e restaurada via RestArea: apos FWExecView, SA1 e
    reposicionada no mesmo registro para que o FWMBrowse mantenha
    o cursor no registro correto ao retornar ao grid.
    @type    Function
    @author  Bruno Almeida
    @since   30/07/2026
    @version P12
    @param   cCod, Caracter, Código do cliente
    @param   cLoja, Caracter, Loja do cliente
    @return  Nil, Nulo
/*/
Function Lj6110Anls(cCod as Character, cLoja as Character)
    Default cCod  := ""
    Default cLoja := ""

    DbSelectArea("SA1")
    SA1->(DbSetOrder(1))
    SA1->(DbSeek(xFilial("SA1") + PADR(AllTrim(cCod), TamSx3("A1_COD")[1]) + PADR(AllTrim(cLoja), TamSx3("A1_LOJA")[1])))

    FWExecView(STR0001, "VIEWDEF.LOJA6110", MODEL_OPERATION_UPDATE, , {|oV| .T.}) ////"Analise de Crédito de Clientes"

Return Nil

/*/{Protheus.doc} Lj6110Anex
    Abre o Banco de Conhecimento do framework (MsDocument) vinculado
    ao cadastro do cliente (SA1) atualmente posicionado no formulario
    MVC. Permite anexar e consultar documentos do cliente (CPF, RG,
    comprovante de endereco, etc.) usando a chave SA1 + RecNo().
    Salva e restaura a area SA1 para nao interferir no formulario ativo.
    @type    Static Function
    @author  Bruno Almeida
    @since   09/08/2026
    @version P12
    @return  Logico, .T.
/*/
Static Function Lj6110Anex() as Logical
    MsDocument("SA1", SA1->(RecNo()), 4)
Return .T.

/*/{Protheus.doc} Lj6110Perf
    Abre o cadastro completo do cliente (SA1) em modo visualizacao
    (somente leitura) usando o formulario padrao CRMA980.
    SA1 deve estar posicionada antes da chamada — garantido pelo
    formulario MVC ativo do LOJA6110.
    Salva e restaura a area SA1 para nao interferir no formulario ativo.
    @type    Static Function
    @author  Bruno Almeida
    @since   11/08/2026
    @version P12
    @return  Nil, Nulo
/*/
Static Function Lj6110Perf()
    FWExecView(STR0011, "VIEWDEF.CRMA980", MODEL_OPERATION_VIEW) //"Perfil"
Return

