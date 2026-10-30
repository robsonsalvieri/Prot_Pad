#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "ESTA100.CH"

Static cModelLoad   := ""
Static aFiltroGrid  := {}

PUBLISH MODEL REST NAME ESTA100 SOURCE ESTA100

//----------------------------------------------------------------------------------
/*/{Protheus.doc} ESTA100
    Cadastro de Cenário - Simulador de Custos
    @type Function
    @author Squad Entradas
    @since 16/02/2026
    @version 12.1.2510 
/*/
//----------------------------------------------------------------------------------
Function ESTA100()
    Local oBrowse   := Nil
    Local lExecute  := FnVldSmlCt()
    
    If !FwAliasInDic("D50")
		Help('',1,'D50',,STR0013,1,0)  //Tabela D50 Não encontrada no dicionário de dados
		Return
	EndIf
    
    If lExecute
        oBrowse := BrowseDef()
        oBrowse:Activate()
    EndIf
    
Return Nil

//----------------------------------------------------------------------------------
/*/{Protheus.doc} BrowserDef
    Definições do browser
    @type Function
    @author Squad Entradas
    @since 16/02/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function BrowseDef()
    Local oBrowse   := Nil
    
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("D50") 
    oBrowse:SetDescription(STR0007) //Cenario de Simulacao
    oBrowse:SetMenuDef("ESTA100")
    
    // Validar legendas com PO
    oBrowse:AddLegend("D50_STATUS == '1'", "BLUE"    , STR0008) //Novo
    oBrowse:AddLegend("D50_STATUS == '2' .And. !Empty(D50_PROC)", "GREEN"   , STR0009) //Processado
    oBrowse:AddLegend("D50_STATUS == '3'", "BLACK"   , STR0010) //Em Copia
    oBrowse:AddLegend("D50_STATUS == '4'", "YELLOW"  , STR0011) //Em Aberto
    oBrowse:AddLegend("D50_STATUS == '5'", "RED"  , STR0021) //Recalculando taxas
    
Return oBrowse

//----------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
    Definições do Menu
    @type Function
    @author Squad Entradas
    @since 16/02/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function MenuDef()
    Local aRotina := {}
    Local aSubAlt := {}
    
    ADD OPTION aRotina TITLE STR0001  ACTION 'VIEWDEF.ESTA100' OPERATION 2 ACCESS 0 //Visualizar
    ADD OPTION aRotina TITLE STR0014  ACTION 'WizESTA100'      OPERATION 3 ACCESS 0 //Wizard Cenario
    ADD OPTION aRotina TITLE STR0004  ACTION 'VIEWDEF.ESTA100' OPERATION 5 ACCESS 0 //Excluir

    AAdd(aSubAlt, {STR0022        , 'ESTA100Alt("D51")', 0, 4, 0, Nil}) // "Volumes de Producao"
    AAdd(aSubAlt, {STR0023        , 'ESTA100Alt("D52")', 0, 4, 0, Nil}) // "Saldos de Centros de Custo"
    AAdd(aSubAlt, {STR0024        , 'ESTA100Alt("D57")', 0, 4, 0, Nil}) // "Precos de Entrada"
    AAdd(aSubAlt, {STR0025        , 'ESTA100Alt("D56")', 0, 4, 0, Nil}) // "Taxa de Absorção"
    AAdd(aRotina, {STR0026        , aSubAlt            , 0, 4, 0, Nil}) // "Alterar"

    ADD OPTION aRotina TITLE STR0020  ACTION 'EST100Taxa'      OPERATION 4 ACCESS 0 //Recalcular Taxas

Return aRotina

//----------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
    Definições do modelo
    @type Function
    @author Squad Entradas
    @since 16/02/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function ModelDef()
    Local oModel    := Nil
    Local oStruD50  := FWFormStruct(1, "D50")
    Local oStruD51  := FWFormStruct(1, "D51")
    Local oStruD52  := FWFormStruct(1, "D52")
    Local oStruD57  := FWFormStruct(1, "D57")
    Local cFieldsD56:= "D56_FILIAL|D56_FILORI|D56_CODCEN|D56_CODCC|D56_HORAS|D56_TOTAL|D56_TAXA"
    Local oStruD56  := FWFormStruct(1, "D56", {|x| AllTrim(x) $ cFieldsD56})
    Local aCamposD51:= oStruD51:GetFields()
    Local aCamposD52:= oStruD52:GetFields()
    Local aCamposD57:= oStruD57:GetFields()
    Local aCamposD56:= oStruD56:GetFields()
    Local nX        := 0
    Local bPosValid := {|oModel| EST100PosV(oModel) }

    oModel := MPFormModel():New("ESTA100", /*bPre*/, bPosValid, /*bCommit*/)
    oModel:SetDescription(STR0012)  //Cenário
    
    // D50 - Cenario de Simulacao
    oStruD50:SetProperty("D50_STATUS", MODEL_FIELD_INIT, { || "4" })    // Inic. Padrão Status = A-Aberto
    oStruD50:SetProperty("D50_STATUS", MODEL_FIELD_WHEN, { || .F. })    // Bloq. Edição - Campo controle
    oStruD50:SetProperty("D50_DTCAD", MODEL_FIELD_WHEN, { || .F. })     // Bloq. Edição - Campo controle
    oStruD50:SetProperty("D50_PROC", MODEL_FIELD_WHEN, { || .F. })      // Bloq. Edição - Campo processamento
    
    oModel:AddFields("D50MASTER", /*cOwner*/, oStruD50)
    oModel:GetModel('D50MASTER'):SetDescription(FwX2Nome('D50'))
    oModel:GetModel("D50MASTER"):SetPrimaryKey({"D50_FILIAL", "D50_COD"})

    // D51 - Volumes de Producao
    If cModelLoad = "D51" .And. FwAliasInDic('D51')
        oModel:AddGrid("D51DETAIL", "D50MASTER", oStruD51)
        oModel:SetRelation('D51DETAIL', {{'D51_FILIAL', 'D50_FILIAL'}, {'D51_CODCEN', 'D50_COD'}}, D51->(IndexKey(1)))
        oModel:GetModel('D51DETAIL'):SetDescription(FwX2Nome('D51'))
        oModel:GetModel("D51DETAIL"):SetUniqueLine({"D51_FILIAL", "D51_FILORI", "D51_CODCEN", "D51_COD"})
        oModel:GetModel("D51DETAIL"):SetOptional(.T.)
        // oModel:GetModel("D51DETAIL"):SetMaxLine(10) -> Avaliado no Spike DENTRINO_CAPEX-126   

        For nX := 1 To Len(aCamposD51)
            If aCamposD51[nX][3] != "D51_VOLSIM"
                oStruD51:SetProperty(aCamposD51[nX][3], MODEL_FIELD_WHEN, {|| .F.})
            EndIf
        Next nX   

        // D51_DESC  
        oStruD51:SetProperty("D51_DESC", MODEL_FIELD_VIRTUAL, .T.)
        oStruD51:SetProperty("D51_DESC", MODEL_FIELD_INIT, { |oModel| Posicione("SB1", 1, D51->D51_FILORI + D51->D51_COD, "B1_DESC") })   
        // D51_UM
        oStruD51:SetProperty("D51_UM", MODEL_FIELD_VIRTUAL, .T.)
        oStruD51:SetProperty("D51_UM", MODEL_FIELD_INIT, { |oModel| Posicione("SB1", 1, D51->D51_FILORI + D51->D51_COD, "B1_UM") })  

        oStruD51:AddTrigger("D51_VOLSIM", "D51_VARIA", {|| .T.}, { |oModel| CalcVaria(oModel, "D51_VOLORI", "D51_VOLSIM") })  

        oStruD51:AddField( ;
            "Selecionar",;                                            // [01] C Titulo do campo
            "Selecionar Item",;                                       // [02] C ToolTip do campo
            "D51_MARK",;                                              // [03] C identificador (ID) do Field
            "L",;                                                     // [04] C Tipo do campo
            1,;                                                       // [05] N Tamanho do campo
            0,;                                                       // [06] N Decimal do campo
            FwBuildFeature(STRUCT_FEATURE_VALID, "AlwaysTrue()"),;    // [07] B Code-block de validação do campo
            FwBuildFeature(STRUCT_FEATURE_WHEN, "AlwaysTrue()"),;     // [08] B Code-block de validação When do campo
            Nil,;                                                     // [09] A Lista de valores permitido do campo
            .F.,;                                                     // [10] L Indica se o campo tem preenchimento obrigatório
            Nil,;                                                     // [11] B Code-block de inicializacao do campo
            .F.,;                                                     // [12] L Indica se trata de um campo chave
            .F.,;                                                     // [13] L Indica se o campo pode receber valor em uma operação de update.
            .T.;                                                      // [14] L Indica se o campo é virtual
        )

        If Len(aFiltroGrid) > 0 .And. cModelLoad == "D51"
            oModel:GetModel('D51DETAIL'):SetLoadFilter( aFiltroGrid )
        EndIf

    EndIf

    // D52 - Saldos de Centros de Custo
    If cModelLoad = "D52" .And. FwAliasInDic('D52')
        oModel:AddGrid("D52DETAIL", "D50MASTER", oStruD52)
        oModel:SetRelation('D52DETAIL', {{'D52_FILIAL', 'D50_FILIAL'}, {'D52_CODCEN', 'D50_COD'}}, D52->(IndexKey(1)))
        oModel:GetModel('D52DETAIL'):SetUniqueLine({"D52_FILIAL","D52_FILORI","D52_CODCEN","D52_CODCC"})
        oModel:GetModel('D52DETAIL'):SetDescription(FwX2Nome('D52'))
        oModel:GetModel("D52DETAIL"):SetOptional(.T.)

        For nX := 1 To Len(aCamposD52)
            If aCamposD52[nX][3] != "D52_SLDSIM"
                oStruD52:SetProperty(aCamposD52[nX][3], MODEL_FIELD_WHEN, {|| .F.})
            EndIf
        Next nX 

        // D52_DESCCC
        oStruD52:SetProperty("D52_DESCCC", MODEL_FIELD_VIRTUAL, .T.)
        oStruD52:SetProperty("D52_DESCCC", MODEL_FIELD_INIT, { || Posicione("CTT", 1, D52->D52_FILORI + D52->D52_CODCC, "CTT_DESC01") })

        oStruD52:AddTrigger("D52_SLDSIM", "D52_VARIA", {|| .T.}, { |oModel| CalcVaria(oModel, "D52_SLDORI", "D52_SLDSIM") })

        oStruD52:AddField( ;
            "Selecionar",;                                            // [01] C Titulo do campo
            "Selecionar Item",;                                       // [02] C ToolTip do campo
            "D52_MARK",;                                              // [03] C identificador (ID) do Field
            "L",;                                                     // [04] C Tipo do campo
            1,;                                                       // [05] N Tamanho do campo
            0,;                                                       // [06] N Decimal do campo
            FwBuildFeature(STRUCT_FEATURE_VALID, "AlwaysTrue()"),;    // [07] B Code-block de validação do campo
            FwBuildFeature(STRUCT_FEATURE_WHEN, "AlwaysTrue()"),;     // [08] B Code-block de validação When do campo
            Nil,;                                                     // [09] A Lista de valores permitido do campo
            .F.,;                                                     // [10] L Indica se o campo tem preenchimento obrigatório
            Nil,;                                                     // [11] B Code-block de inicializacao do campo
            .F.,;                                                     // [12] L Indica se trata de um campo chave
            .F.,;                                                     // [13] L Indica se o campo pode receber valor em uma operação de update.
            .T.;                                                      // [14] L Indica se o campo é virtual
        )

        If !Empty(aFiltroGrid) .And. cModelLoad == "D52"
            oModel:GetModel('D52DETAIL'):SetLoadFilter( aFiltroGrid )
        EndIf
        
    EndIf

    // D57 - Precos de Entrada
    If cModelLoad = "D57" .And. FwAliasInDic('D57')
        oModel:AddGrid("D57DETAIL", "D50MASTER", oStruD57)
        oModel:SetRelation('D57DETAIL', {{'D57_FILIAL', 'D50_FILIAL'}, {'D57_CODCEN', 'D50_COD'}}, D57->(IndexKey(1)))
        oModel:GetModel('D57DETAIL'):SetUniqueLine({"D57_FILIAL","D57_FILORI","D57_CODCEN","D57_COD"})
        oModel:GetModel('D57DETAIL'):SetDescription(FwX2Nome('D57'))
        oModel:GetModel("D57DETAIL"):SetOptional(.T.)
    
        For nX := 1 To Len(aCamposD57)
            If aCamposD57[nX][3] != "D57_UPRCSM"
                oStruD57:SetProperty(aCamposD57[nX][3], MODEL_FIELD_WHEN, {|| .F.})
            EndIf
        Next nX

        // D57_DESC
        oStruD57:SetProperty("D57_DESC", MODEL_FIELD_VIRTUAL, .T.)
        oStruD57:SetProperty("D57_DESC", MODEL_FIELD_INIT, { || Posicione("SB1", 1, D57->D57_FILORI + D57->D57_COD, "B1_DESC") })

        // D57_UM
        oStruD57:SetProperty("D57_UM", MODEL_FIELD_VIRTUAL, .T.)
        oStruD57:SetProperty("D57_UM", MODEL_FIELD_INIT, { |oModel| Posicione("SB1", 1, D57->D57_FILORI + D57->D57_COD, "B1_UM") })

        oStruD57:AddTrigger("D57_UPRCSM", "D57_VARIA", {|| .T.}, { |oModel| CalcVaria(oModel, "D57_UPRC", "D57_UPRCSM") })

        oStruD57:AddField( ;
            "Selecionar",;                                            // [01] C Titulo do campo
            "Selecionar Item",;                                       // [02] C ToolTip do campo
            "D57_MARK",;                                              // [03] C identificador (ID) do Field
            "L",;                                                     // [04] C Tipo do campo
            1,;                                                       // [05] N Tamanho do campo
            0,;                                                       // [06] N Decimal do campo
            FwBuildFeature(STRUCT_FEATURE_VALID, "AlwaysTrue()"),;    // [07] B Code-block de validação do campo
            FwBuildFeature(STRUCT_FEATURE_WHEN, "AlwaysTrue()"),;     // [08] B Code-block de validação When do campo
            Nil,;                                                     // [09] A Lista de valores permitido do campo
            .F.,;                                                     // [10] L Indica se o campo tem preenchimento obrigatório
            Nil,;                                                     // [11] B Code-block de inicializacao do campo
            .F.,;                                                     // [12] L Indica se trata de um campo chave
            .F.,;                                                     // [13] L Indica se o campo pode receber valor em uma operação de update.
            .T.;                                                      // [14] L Indica se o campo é virtual
        )

        If Len(aFiltroGrid) > 0 .And. cModelLoad == "D57"
            oModel:GetModel('D57DETAIL'):SetLoadFilter( aFiltroGrid )
        EndIf

    EndIf

    // D56 - Taxa de Absorção
    If cModelLoad = "D56" .And. FwAliasInDic('D56')
        oModel:AddGrid("D56DETAIL", "D50MASTER", oStruD56)
        oModel:SetRelation('D56DETAIL', {{'D56_FILIAL', 'D50_FILIAL'}, {'D56_CODCEN', 'D50_COD'}}, D56->(IndexKey(1)))
        oModel:GetModel('D56DETAIL'):SetDescription(FwX2Nome('D56'))
        oModel:GetModel("D56DETAIL"):SetUniqueLine({"D56_FILIAL", "D56_FILORI", "D56_CODCEN", "D56_CODCC"})
        oModel:GetModel("D56DETAIL"):SetOptional(.T.)

        For nX := 1 To Len(aCamposD56)
            If aCamposD56[nX][3] != "D56_TAXA"
                oStruD56:SetProperty(aCamposD56[nX][3], MODEL_FIELD_WHEN, {|| .F.})
            EndIf
        Next nX   

        oStruD56:AddField( ;
            "Selecionar",;                                            // [01] C Titulo do campo
            "Selecionar Item",;                                       // [02] C ToolTip do campo
            "D56_MARK",;                                              // [03] C identificador (ID) do Field
            "L",;                                                     // [04] C Tipo do campo
            1,;                                                       // [05] N Tamanho do campo
            0,;                                                       // [06] N Decimal do campo
            FwBuildFeature(STRUCT_FEATURE_VALID, "AlwaysTrue()"),;    // [07] B Code-block de validação do campo
            FwBuildFeature(STRUCT_FEATURE_WHEN, "AlwaysTrue()"),;     // [08] B Code-block de validação When do campo
            Nil,;                                                     // [09] A Lista de valores permitido do campo
            .F.,;                                                     // [10] L Indica se o campo tem preenchimento obrigatório
            Nil,;                                                     // [11] B Code-block de inicializacao do campo
            .F.,;                                                     // [12] L Indica se trata de um campo chave
            .F.,;                                                     // [13] L Indica se o campo pode receber valor em uma operação de update.
            .T.;                                                      // [14] L Indica se o campo é virtual
        )

        If Len(aFiltroGrid) > 0 .And. cModelLoad == "D56"
            oModel:GetModel('D56DETAIL'):SetLoadFilter( aFiltroGrid )
        EndIf

    EndIf

Return oModel

//----------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
    Definições da view
    @type Function
    @author Squad Entradas
    @since 16/02/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function ViewDef()
    Local oView     := Nil
    Local oModel    := FWLoadModel("ESTA100")
    Local oStruD50  := FWFormStruct(2, "D50", {|x| ALLTRIM(x) $ 'D50_COD, D50_DESC, D50_STATUS, D50_DTCAD, D50_PROC'})
    Local oStruD51  := FWFormStruct(2, "D51")
    Local oStruD52  := FWFormStruct(2, "D52")
    Local oStruD57  := FWFormStruct(2, "D57")
    Local cFieldsD56:= "D56_FILIAL|D56_FILORI|D56_CODCEN|D56_CODCC|D56_HORAS|D56_TOTAL|D56_TAXA"
    Local oStruD56  := FWFormStruct(2, "D56", {|x| AllTrim(x) $ cFieldsD56})
    
    oView := FWFormView():New()
    oView:SetModel(oModel)

    // Criação Box
    oView:CreateHorizontalBox("BOX_CABEC", 20)
    oView:CreateHorizontalBox("BOX_DETAIL", 80)

    // D50 - Cenario de Simulacao
    oView:AddField("VIEW_D50", oStruD50, "D50MASTER")
    oView:SetOwnerView('VIEW_D50', 'BOX_CABEC')
    // Remoção de campos de controle
    oStruD50:RemoveField("D50_PRODIN")
    oStruD50:RemoveField("D50_PRODFI")

    // D51 - Volumes de Producao
    If cModelLoad = "D51"
        oView:AddGrid("VIEW_D51", oStruD51, "D51DETAIL")
        oView:SetOwnerView("VIEW_D51", "BOX_DETAIL") 
        oView:SetViewProperty("VIEW_D51", "GRIDSEEK", {.T.})
        oView:EnableTitleView("VIEW_D51", FwX2Nome('D51'))
        oStruD51:RemoveField("D51_CODCEN")
        oStruD51:SetProperty("D51_VARIA", MVC_VIEW_PICT, "@E 999,999.99 %")
        oStruD51:AddField(;
            "D51_MARK",;        // [01] ID do Campo (Igual ao Model)
            "00",;              // [02] Ordem ("00" joga a coluna para o começo do grid)
            "Sel.",;            // [03] Titulo da Coluna
            "Selecionar",;      // [04] Descrição
            Nil,;               // [05] Help
            "Check",;           // [06] TIPO (A Mágica do MVC: 'Check' desenha a caixinha)
            Nil,;               // [07] Picture
            Nil,;               // [08] bPictVar
            Nil,;               // [09] Consulta F3
            .T.,;               // [10] Editavel
            Nil,;               // [11] Folder
            Nil,;               // [12] Group
            Nil,;               // [13] aCombo
            Nil,;               // [14] nMaxCombo
            Nil,;               // [15] cIniBrow
            .T.)                // [16] Lógico Virtual
    EndIf

    // D52 - Saldos de Centros de Custo
    If cModelLoad = "D52"
        oView:AddGrid("VIEW_D52", oStruD52, "D52DETAIL")
        oView:SetOwnerView("VIEW_D52", "BOX_DETAIL") 
        oView:SetViewProperty("VIEW_D52", "GRIDSEEK", {.T.})
        oView:EnableTitleView("VIEW_D52", FwX2Nome('D52'))
        oStruD52:RemoveField("D52_CODCEN")
        oStruD52:SetProperty("D52_VARIA", MVC_VIEW_PICT, "@E 999,999.99 %")
        oStruD52:AddField(;
            "D52_MARK",;        // [01] ID do Campo (Igual ao Model)
            "00",;              // [02] Ordem ("00" joga a coluna para o começo do grid)
            "Sel.",;            // [03] Titulo da Coluna
            "Selecionar",;      // [04] Descrição
            Nil,;               // [05] Help
            "Check",;           // [06] TIPO (A Mágica do MVC: 'Check' desenha a caixinha)
            Nil,;               // [07] Picture
            Nil,;               // [08] bPictVar
            Nil,;               // [09] Consulta F3
            .T.,;               // [10] Editavel
            Nil,;               // [11] Folder
            Nil,;               // [12] Group
            Nil,;               // [13] aCombo
            Nil,;               // [14] nMaxCombo
            Nil,;               // [15] cIniBrow
            .T.)                // [16] Lógico Virtual
    EndIf

    // D57 - Precos de Entrada
    If cModelLoad = "D57"
        oView:AddGrid("VIEW_D57", oStruD57, "D57DETAIL")
        oView:SetOwnerView("VIEW_D57", "BOX_DETAIL") 
        oView:SetViewProperty("VIEW_D57", "GRIDSEEK", {.T.})
        oView:EnableTitleView("VIEW_D57", FwX2Nome('D57'))
        oStruD57:RemoveField("D57_CODCEN")
        oStruD57:SetProperty("D57_VARIA", MVC_VIEW_PICT, "@E 999,999.99 %")
        oStruD57:AddField(;
            "D57_MARK",;        // [01] ID do Campo (Igual ao Model)
            "00",;              // [02] Ordem ("00" joga a coluna para o começo do grid)
            "Sel.",;            // [03] Titulo da Coluna
            "Selecionar",;      // [04] Descrição
            Nil,;               // [05] Help
            "Check",;           // [06] TIPO (A Mágica do MVC: 'Check' desenha a caixinha)
            Nil,;               // [07] Picture
            Nil,;               // [08] bPictVar
            Nil,;               // [09] Consulta F3
            .T.,;               // [10] Editavel
            Nil,;               // [11] Folder
            Nil,;               // [12] Group
            Nil,;               // [13] aCombo
            Nil,;               // [14] nMaxCombo
            Nil,;               // [15] cIniBrow
            .T.)                // [16] Lógico Virtual
    EndIf

    // D56 - Taxa de Absorção
    If cModelLoad = "D56"
        oView:AddGrid("VIEW_D56", oStruD56, "D56DETAIL")
        oView:SetOwnerView("VIEW_D56", "BOX_DETAIL") 
        oView:SetViewProperty("VIEW_D56", "GRIDSEEK", {.T.})
        oView:EnableTitleView("VIEW_D56", FwX2Nome('D56'))
        oStruD56:RemoveField("D56_CODCEN")
        oStruD56:AddField(;
            "D56_MARK",;        // [01] ID do Campo (Igual ao Model)
            "00",;              // [02] Ordem ("00" joga a coluna para o começo do grid)
            "Sel.",;            // [03] Titulo da Coluna
            "Selecionar",;      // [04] Descrição
            Nil,;               // [05] Help
            "Check",;           // [06] TIPO (A Mágica do MVC: 'Check' desenha a caixinha)
            Nil,;               // [07] Picture
            Nil,;               // [08] bPictVar
            Nil,;               // [09] Consulta F3
            .T.,;               // [10] Editavel
            Nil,;               // [11] Folder
            Nil,;               // [12] Group
            Nil,;               // [13] aCombo
            Nil,;               // [14] nMaxCombo
            Nil,;               // [15] cIniBrow
            .T.)                // [16] Lógico Virtual
    EndIf

    //Adiciona botões no menu "Outras Ações"
    oView:AddUserButton(STR0016, "", {|oView| ReajLote(oView,cModelLoad)} , , , {MODEL_OPERATION_UPDATE} ) //"Reajuste em Lote"
    
Return oView

//----------------------------------------------------------------------------------
/*/{Protheus.doc} ESTA100Alt
    Função responsavel pela filtragem dos submodelos na alteração das entidades
    @type Function
    @author Squad Entradas
    @since 11/03/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Function ESTA100Alt(cModel)
    Local aPerg      := {}
    Local aRet       := {}
    Local aFiltroMVC := {}
    Local cTitulo    := ""
    Local cCenario   := D50->D50_COD

    If D50->D50_STATUS $ "3|5"
        FWAlertInfo(STR0027, STR0028) // "O cenario selecionado esta em processamento e nao pode ser alterado no momento.", "Atenção"
        Return
    EndIf

    Do Case
        Case cModel == "D51" // Volumes de Producao
            cTitulo := STR0029 // "Alterar Volumes de Producao"
            AAdd(aPerg, {1, STR0030 , Space(TamSx3("D51_FILORI")[1]), "@!", "", "SM0", "", 50, .F.}) // "Filial Origem De"
            AAdd(aPerg, {1, STR0031, PadR("ZZZ", TamSx3("D51_FILORI")[1]), "@!", "", "SM0", "", 50, .F.}) // "Filial Origem Ate"
            AAdd(aPerg, {1, STR0032 , Space(TamSx3("D51_COD")[1]), "@!", "", "SB1", "", 100, .F.}) // "Produto De"
            AAdd(aPerg, {1, STR0033, PadR("ZZZ", TamSx3("D51_COD")[1]), "@!", "", "SB1", "", 100, .F.}) // "Produto Ate"

        Case cModel == "D52" // Saldos de CC
            cTitulo := STR0034 // "Alterar Saldos de Centro Custo"
            AAdd(aPerg, {1, STR0030 , Space(TamSx3("D51_FILORI")[1]), "@!", "", "SM0", "", 50, .F.}) // "Filial Origem De"
            AAdd(aPerg, {1, STR0031, PadR("ZZZ", TamSx3("D51_FILORI")[1]), "@!", "", "SM0", "", 50, .F.}) // "Filial Origem Ate"
            AAdd(aPerg, {1, STR0035 , Space(TamSx3("D52_CODCC")[1]), "@!", "", "CTT", "", 100, .F.}) // "Centro Custo De"
            AAdd(aPerg, {1, STR0036, PadR("ZZZ", TamSx3("D52_CODCC")[1]), "@!", "", "CTT", "", 100, .F.}) // "Centro Custo Ate"

        Case cModel == "D57" // Precos de Entrada
            cTitulo := STR0037 // "Alterar Precos de Entrada"
            AAdd(aPerg, {1, STR0030 , Space(TamSx3("D51_FILORI")[1]), "@!", "", "SM0", "", 50, .F.}) // "Filial Origem De"
            AAdd(aPerg, {1, STR0031, PadR("ZZZ", TamSx3("D51_FILORI")[1]), "@!", "", "SM0", "", 50, .F.}) // "Filial Origem Ate"
            AAdd(aPerg, {1, STR0032 , Space(TamSx3("D57_COD")[1]), "@!", "", "SB1", "", 100, .F.}) // "Produto De"
            AAdd(aPerg, {1, STR0033, PadR("ZZZ", TamSx3("D57_COD")[1]), "@!", "", "SB1", "", 100, .F.}) // "Produto Ate"

        Case cModel == "D56" // Taxa de absorção
            cTitulo := STR0038 // "Alterar Taxa de Absorcao"
            AAdd(aPerg, {1, STR0030 , Space(TamSx3("D51_FILORI")[1]), "@!", "", "SM0", "", 50, .F.}) // "Filial Origem De"
            AAdd(aPerg, {1, STR0031, PadR("ZZZ", TamSx3("D51_FILORI")[1]), "@!", "", "SM0", "", 50, .F.}) // "Filial Origem Ate"
            AAdd(aPerg, {1, STR0035 , Space(TamSx3("D56_CODCC ")[1]), "@!", "", "CTT", "", 100, .F.}) // "Centro Custo De"
            AAdd(aPerg, {1, STR0036, PadR("ZZZ", TamSx3("D56_CODCC ")[1]), "@!", "", "CTT", "", 100, .F.}) // "Centro Custo Ate"
    EndCase

    If ParamBox(aPerg, FwX2Nome(cModel), @aRet)

        If !ValQntReg(cModel, cCenario, aRet)
            Return
        EndIf

        Do Case
            Case cModel == "D51"
                AAdd(aFiltroMVC, { "D51_FILORI", "'" + aRet[1] + "'", MVC_LOADFILTER_GREATER_EQUAL, MVC_LOADFILTER_AND }) 
                AAdd(aFiltroMVC, { "D51_FILORI", "'" + aRet[2] + "'", MVC_LOADFILTER_LESS_EQUAL,    MVC_LOADFILTER_AND })
                AAdd(aFiltroMVC, { "D51_COD"   , "'" + aRet[3] + "'", MVC_LOADFILTER_GREATER_EQUAL, MVC_LOADFILTER_AND }) 
                AAdd(aFiltroMVC, { "D51_COD"   , "'" + aRet[4] + "'", MVC_LOADFILTER_LESS_EQUAL,    MVC_LOADFILTER_AND }) 
                
            Case cModel == "D52"
                AAdd(aFiltroMVC, { "D52_FILORI", "'" + aRet[1] + "'", MVC_LOADFILTER_GREATER_EQUAL, MVC_LOADFILTER_AND }) 
                AAdd(aFiltroMVC, { "D52_FILORI", "'" + aRet[2] + "'", MVC_LOADFILTER_LESS_EQUAL,    MVC_LOADFILTER_AND })
                AAdd(aFiltroMVC, { "D52_CODCC" , "'" + aRet[3] + "'", MVC_LOADFILTER_GREATER_EQUAL, MVC_LOADFILTER_AND }) 
                AAdd(aFiltroMVC, { "D52_CODCC" , "'" + aRet[4] + "'", MVC_LOADFILTER_LESS_EQUAL,    MVC_LOADFILTER_AND }) 
                
            Case cModel == "D57"
                AAdd(aFiltroMVC, { "D57_FILORI", "'" + aRet[1] + "'", MVC_LOADFILTER_GREATER_EQUAL, MVC_LOADFILTER_AND }) 
                AAdd(aFiltroMVC, { "D57_FILORI", "'" + aRet[2] + "'", MVC_LOADFILTER_LESS_EQUAL,    MVC_LOADFILTER_AND })
                AAdd(aFiltroMVC, { "D57_COD"   , "'" + aRet[3] + "'", MVC_LOADFILTER_GREATER_EQUAL, MVC_LOADFILTER_AND }) 
                AAdd(aFiltroMVC, { "D57_COD"   , "'" + aRet[4] + "'", MVC_LOADFILTER_LESS_EQUAL,    MVC_LOADFILTER_AND }) 

            Case cModel == "D56"
                AAdd(aFiltroMVC, { "D56_FILORI", "'" + aRet[1] + "'", MVC_LOADFILTER_GREATER_EQUAL, MVC_LOADFILTER_AND })
                AAdd(aFiltroMVC, { "D56_FILORI", "'" + aRet[2] + "'", MVC_LOADFILTER_LESS_EQUAL,    MVC_LOADFILTER_AND })
                AAdd(aFiltroMVC, { "D56_CODCC" , "'" + aRet[3] + "'", MVC_LOADFILTER_GREATER_EQUAL, MVC_LOADFILTER_AND }) 
                AAdd(aFiltroMVC, { "D56_CODCC" , "'" + aRet[4] + "'", MVC_LOADFILTER_LESS_EQUAL,    MVC_LOADFILTER_AND }) 
        EndCase
        
        cModelLoad  := cModel
        aFiltroGrid := aFiltroMVC 

        FWExecView(cTitulo, "ESTA100", 4)

        cModelLoad  := ""
        aFiltroGrid := {}
    EndIf

Return

//----------------------------------------------------------------------------------
/*/{Protheus.doc} ValQntReg
    Função responsavel por retornar o total do filtro de alteração, limitando os registros
    para exibição, pois o excesso de registros tornam a rotina lenta para carregamento
    @type Function
    @author Squad Entradas
    @since 16/03/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function ValQntReg(cAlias, cCenario, aRet)
    Local cQuery    := ""
    Local cAliasQry := ""
    Local oQuery    As Object
    Local nTotReg   := 0
    Local lRet      := .T.

    cQuery := " SELECT COUNT(*) AS QTD FROM " + RetSqlName(cAlias)
    cQuery += " WHERE " + cAlias + "_FILIAL = ? "
    cQuery += " AND " + cAlias + "_CODCEN = ? "

    Do Case
        Case cAlias == "D51"
            cQuery += " AND D51_FILORI BETWEEN ? AND ? "
            cQuery += " AND D51_COD BETWEEN ? AND ? "
        Case cAlias == "D52"
            cQuery += " AND D52_FILORI BETWEEN ? AND ? "
            cQuery += " AND D52_CODCC BETWEEN ? AND ? "
        Case cAlias == "D57"
            cQuery += " AND D57_FILORI BETWEEN ? AND ? "
            cQuery += " AND D57_COD BETWEEN ? AND ? "
        Case cAlias == "D56"
            cQuery += " AND D56_FILORI BETWEEN ? AND ? "
            cQuery += " AND D56_CODCC BETWEEN ? AND ? "
    EndCase

    cQuery += " AND D_E_L_E_T_ = ? "

    oQuery := FWExecStatement():New(cQuery)
    
    oQuery:SetString(1, xFilial(cAlias))
    oQuery:SetString(2, cCenario)

    Do Case
        Case cAlias == "D51"
            oQuery:SetString(3, Trim(aRet[1]))
            oQuery:SetString(4, Trim(aRet[2]))
            oQuery:SetString(5, Trim(aRet[3]))
            oQuery:SetString(6, Trim(aRet[4]))
            oQuery:SetString(7, " ")          
        Case cAlias == "D52"
            oQuery:SetString(3, Trim(aRet[1]))
            oQuery:SetString(4, Trim(aRet[2]))
            oQuery:SetString(5, Trim(aRet[3]))
            oQuery:SetString(6, Trim(aRet[4]))
            oQuery:SetString(7, " ")          
        Case cAlias == "D57"
            oQuery:SetString(3, Trim(aRet[1]))
            oQuery:SetString(4, Trim(aRet[2]))
            oQuery:SetString(5, Trim(aRet[3]))
            oQuery:SetString(6, Trim(aRet[4]))
            oQuery:SetString(7, " ")    
        Case cAlias == "D56"
            oQuery:SetString(3, Trim(aRet[1]))
            oQuery:SetString(4, Trim(aRet[2]))
            oQuery:SetString(5, Trim(aRet[3]))
            oQuery:SetString(6, Trim(aRet[4]))
            oQuery:SetString(7, " ")
    EndCase

    cAliasQry := oQuery:OpenAlias()
    nTotReg   := (cAliasQry)->QTD

    (cAliasQry)->(DbCloseArea())
    oQuery:Destroy()
    FreeObj(oQuery)

    If nTotReg > 2000
        FWAlertInfo(STR0039 + Alltrim(Str(nTotReg)) + STR0040, STR0028) // "A pesquisa retornou " + " registros. Por favor, refine o filtro.", "Atencao"
        lRet := .F.
    EndIf

    If nTotReg = 0
        FWAlertInfo(STR0041, STR0028) // "A pesquisa nao retornou nenhum registro. Por favor, refine o filtro.", "Atencao"
        lRet := .F.
    EndIf

Return lRet

//----------------------------------------------------------------------------------
/*/{Protheus.doc} FnVldSmlCt
    Função para retornar o contúdo do parâmetro 'MV_FFSIMC' Feature Flag
    @type Function
    @author Squad Entradas
    @since 18/03/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Function FnVldSmlCt()
Return SuperGetMv("MV_FFSIMC",.F.,.F.)

//----------------------------------------------------------------------------------
/*/{Protheus.doc} CalcVaria
    Função para calcular a variação percentual entre o valor original e o valor simulado
    @type Function
    @author Squad Entradas
    @since 19/03/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function CalcVaria(oModel, cCampoOri, cCampoSim)
    Local nValOri := oModel:GetValue(cCampoOri)
    Local nValSim := oModel:GetValue(cCampoSim)
    Local nRet    := 0

    If nValOri <> 0
        nRet := ((nValSim / nValOri) - 1) * 100
    Else
        nRet := 100 //Qualquer valor acima de 0 significa 100% de variação
    EndIf

Return nRet

//----------------------------------------------------------------------------------
/*/{Protheus.doc} ReajLote
    Reajuste de valores em Lote
    @type Function
    @author Squad Entradas
    @since 24/03/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function ReajLote(oViewRj,cModel)
    Local aBackVar  := Array(2)
    Local aButtons  := {}
    Local lOk       := .F.
    Local lRet      := .T.
    Local nReaj     := 0

    DEFINE MSDIALOG oDlg FROM 000,000 TO 200,500 TITLE STR0016 PIXEL  //"Reajuste em Lote"

    TGet():New(40,  05, {|u| If(PCount()>0, nReaj:=u, nReaj )}, oDlg, 30, 15, '999.99',;
	           ,/*09*/,/*10*/,/*11*/,/*12*/,/*13*/,.T.,/*15*/,/*16*/,/*17*/,/*18*/,/*19*/,;
			   /*20*/,/*21*/,/*22*/,/*23*/,"nReaj"  ,/*25*/,/*26*/,/*27*/,.F.,.T.,/*30*/,STR0019,2) //"Percentual de Reajuste (%):"

    /*
	Variáveis INCLUI e ALTERA definidas como .F. neste ponto, para que a função EnchoiceBar crie os botões com as descrições
	corretas (Confirmar/Cancelar) em todos os pontos.
	*/
	aBackVar[1] := Iif(Type("INCLUI")=="L",INCLUI,Nil)
	aBackVar[2] := Iif(Type("ALTERA")=="L",ALTERA,Nil)
	INCLUI := .F.
	ALTERA := .F.

	ACTIVATE MSDIALOG oDlg CENTER ;
        ON INIT (EnchoiceBar(oDlg, {|| Iif(nReaj <> 0, (lOk:=.T., oDlg:End()), lOk := .F.)} , {|| (lOk := .F., oDlg:End())},,aButtons ))
		If lOk	//Processa substituicao dos componentes
			Processa({|| ProcReaj(oViewRj,cModel,nReaj) })
		EndIf

	INCLUI := aBackVar[1]
	ALTERA := aBackVar[2]

Return lRet

//----------------------------------------------------------------------------------
/*/{Protheus.doc} ProcReaj
    Processa o % de reajuste em lote
    @type Function
    @author Squad Entradas
    @since 27/03/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function ProcReaj(oViewRj,cModel,nReaj)
    Local oModel    := oViewRj:GetModel()
    Local oModelD51 := oModel:GetModel("D51DETAIL")
    Local oModelD52 := oModel:GetModel("D52DETAIL")
    Local oModelD57 := oModel:GetModel("D57DETAIL")
    Local oModelD56 := oModel:GetModel("D56DETAIL")
    Local nLinha    := 1
    Local nTotal    := 0

    // D52 - Saldos de Centros de Custo
    If cModel = "D51" .And. FwAliasInDic('D51')
        nTotal    := oModelD51:Length()
        // Percorre o submodelo enquanto houver linhas
        While nLinha <= nTotal
            oModelD51:goLine(nLinha)
            If oModel:GetModel("D51DETAIL"):GetValue("D51_MARK") 
                oModel:GetModel("D51DETAIL"):SetValue("D51_VOLSIM", (oModel:GetModel("D51DETAIL"):GetValue("D51_VOLSIM")) * (1 + (nReaj / 100)))
            EndIf 
            nLinha++
        EndDo
    ElseIf cModel = "D52" .And. FwAliasInDic('D52')
        nTotal    := oModelD52:Length()
        // Percorre o submodelo enquanto houver linhas
        While nLinha <= nTotal
            oModelD52:goLine(nLinha)
            If oModel:GetModel("D52DETAIL"):GetValue("D52_MARK") 
                oModel:GetModel("D52DETAIL"):SetValue("D52_SLDSIM", (oModel:GetModel("D52DETAIL"):GetValue("D52_SLDSIM")) * (1 + (nReaj / 100)))
            EndIf 
            nLinha++
        EndDo
    ElseIf cModel = "D57" .And. FwAliasInDic('D57')
        nTotal    := oModelD57:Length()
        // Percorre o submodelo enquanto houver linhas
        While nLinha <= nTotal
            oModelD57:goLine(nLinha)
            If oModel:GetModel("D57DETAIL"):GetValue("D57_MARK") 
                oModel:GetModel("D57DETAIL"):SetValue("D57_UPRCSM", (oModel:GetModel("D57DETAIL"):GetValue("D57_UPRCSM")) * (1 + (nReaj / 100)))
            EndIf 
            nLinha++
        EndDo
    ElseIf cModel = "D56" .And. FwAliasInDic('D56')
        nTotal    := oModelD56:Length()
        // Percorre o submodelo enquanto houver linhas
        While nLinha <= nTotal
            oModelD56:goLine(nLinha)
            If oModel:GetModel("D56DETAIL"):GetValue("D56_MARK") 
                oModel:GetModel("D56DETAIL"):SetValue("D56_TAXA", (oModel:GetModel("D56DETAIL"):GetValue("D56_TAXA")) * (1 + (nReaj / 100)))
            EndIf 
            nLinha++
        EndDo
    EndIf

Return Nil


/*/{Protheus.doc} EST100PosV
    Funcao de pos validacao do modelo
    @type  Function
    @author Squad.Entradas
    @since 14/05/2026
    @version 1.0
    @param oModel, object, modelo a ser validado
    @return lRet, logical, indica se a validacao foi bem-sucedida
    /*/
Function EST100PosV(oModel)
    Local lRet := .T.

    If oModel:GetOperation() == MODEL_OPERATION_DELETE
        If D50->D50_STATUS $ "3|5"
            Help(, 1, "EST330DEL", , STR0042, 1, 0, , , , , , {STR0043}) // "Cenario de custo em processamento." , "Exclusao nao permitida."
            lRet := .F.
        EndIf
    EndIf

Return lRet
