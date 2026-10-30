#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEDITPANEL.CH"
#INCLUDE "ESTA101.CH"
#INCLUDE 'FWMBROWSE.CH'

// Constantes para utilizar no cCargo do Produto
#DEFINE IND_ESTR "ESTR"

// Variaveis static para utilização no DBTree
Static soTree      := Nil  // Objeto Tree para manipulação da estrutura
Static snSeqTree   := 0    // Sequencial para geração do código do cargo
Static scD5BCdPai  := ""   // Código do componente selecionado para filtro da tree
Static scRotPad    := ""   // Variável para armazenar o roteiro padrão do produto
Static scCargoAtu  := ""   // Cargo do item selecionado atualmente na tree

// Variaveis static para utilização no painel de resultados
Static snMatOri   := 0
Static snModOri   := 0
Static soMatSim   := Nil
Static soMatVar   := Nil
Static soMatVarVl := Nil
Static soModSim   := Nil
Static soModVar   := Nil
Static soModVarVl := Nil
Static soTotSim   := Nil
Static soTotVar   := Nil
Static soTotVarVl := Nil

Static lIsDark    := (GetRpoRelease() >= "12.1.2410" .And. totvs.framework.css.getNewWebAppTheme() == "DARK")

PUBLISH MODEL REST NAME ESTA101 SOURCE ESTA101

//----------------------------------------------------------------------------------
/*/{Protheus.doc} ESTA101
    Cadastro de Simulacao - Simulador de Custos
    @type Function
    @author Squad Entradas
    @since 25/03/2026
    @version 12.1.2510 
/*/
//----------------------------------------------------------------------------------
Function ESTA101()
    Local oBrowse   := Nil
    Local lExecute  := FnVldSmlCt()

    If !FwAliasInDic("D5A")
		Help('',1,'D5A',,STR0001,1,0) //"Tabela D5A Não encontrada no dicionário de dados"
		Return
	EndIf

    If lExecute
        oBrowse := BrowseDef()
        If hasSmartX()
		    oBrowse:setSmartX() //define a utilização do novo browse
	    EndIf
        oBrowse:Activate()
    EndIf
    
Return Nil

//----------------------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
    Definições do browse
    @type Function
    @author Squad Entradas
    @since 25/03/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function BrowseDef()
    Local oBrowse   := Nil
    
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("D5A") 
    oBrowse:SetDescription(STR0002) //"Simulador de Custos e Precos"
    oBrowse:SetMenuDef("ESTA101")
    
    oBrowse:AddLegend("D5A_STATUS == '1'", "BLUE"  , STR0003,,,"color-01") //"Em Andamento"
    oBrowse:AddLegend("D5A_STATUS == '2'", "GREEN" , STR0004,,,"color-11") //"Finalizada"
    
Return oBrowse

//----------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
    Definições do Menu
    @type Function
    @author Squad Entradas
    @since 25/03/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function MenuDef()
    Local aRotina := {}
    
    ADD OPTION aRotina TITLE STR0005  ACTION 'ESTA101Alt(1)'   OPERATION 2 ACCESS 0 //"Visualizar"
    ADD OPTION aRotina TITLE STR0006  ACTION 'ESTA101Inc'      OPERATION 3 ACCESS 0 //"Incluir"
    ADD OPTION aRotina TITLE STR0007  ACTION 'ESTA101Alt(4)'   OPERATION 4 ACCESS 0 //"Alterar"
    //ADD OPTION aRotina TITLE STR0008  ACTION 'VIEWDEF.ESTA101' OPERATION 5 ACCESS 0 //"Excluir"

Return aRotina

//----------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
    Definições do modelo
    @type Function
    @author Squad Entradas
    @since 25/03/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function ModelDef()
    Local oModel    := Nil
    Local oStruD5A  := FWFormStruct(1, "D5A")
    Local oStruD5B  := FWFormStruct(1, "D5B")
    Local oStruD5C  := FWFormStruct(1, "D5C")
    Local oStruD5D  := FWFormStruct(1, "D5D")
    Local oStruNo   := FWFormModelStruct():New()
    Local oEvent    := ESTA101EVDEF():New()
    Local cVldComp  := ""
    Local bVldComp  := NIL

    oModel := MPFormModel():New("ESTA101", /*bPre*/, /*bPos*/, /*bCommit*/)
    oModel:SetDescription(STR0009) //"Simulacao" 
    oModel:InstallEvent("ESTA101EVDEF", /*cOwner*/, oEvent)
    
    // Modelo D5A - Simulação
    oModel:AddFields("D5AMASTER", /*cOwner*/, oStruD5A)
    oModel:GetModel('D5AMASTER'):SetDescription(FwX2Nome('D5A'))

    oStruD5A:SetProperty("D5A_DESCEN", MODEL_FIELD_INIT, { |oModel| POSICIONE("D50",1,XFILIAL("D50") + D5A->D5A_CODCEN,"D50_DESC") })
    oStruD5A:SetProperty("D5A_PLANO", MODEL_FIELD_VALID, {|| ESTA101Pla()})

    // Modelo D5B - Componentes
    cVldComp := "ESTA101Com()"
    bVldComp := FWBuildFeature(STRUCT_FEATURE_VALID, cVldComp)
    oStruD5B:SetProperty("D5B_COMP", MODEL_FIELD_VALID, bVldComp)
	oStruD5B:SetProperty("D5B_QUANT", MODEL_FIELD_VALID, {|| VldD5BQtde()})
    oStruD5B:SetProperty("D5B_DESC", MODEL_FIELD_VALID, {|| VldD5BDesc()})
    oStruD5B:SetProperty("D5B_DESC", MODEL_FIELD_WHEN, {|| AltD5BDesc()})
    oStruD5B:AddField("Recno"        ,; // [01] Titulo
                        "NREG"       ,; // [02] ToolTip
                        "NREG"       ,; // [03] IdField
                        "N"          ,; // [04] Tipo
                        10           ,; // [05] Tamanho
                        0            ,; // [06] Decimal
                        Nil          ,; // [07] Valid
                        Nil          ,; // [08] When
                        {}           ,; // [09] Valores Permitidos
                        .F.          ,; // [10] Obrigatório
                        Nil          ,; // [11] Init
                        .F.          ,; // [12] Chave
                        .F.          ,; // [13] Update
                        .T.          )  // [14] Virtual

    oStruD5B:AddField("Cargo"        ,; // [01] Titulo
                        "Cargo"      ,; // [02] ToolTip
                        "CARGO"      ,; // [03] IdField
                        "C"          ,; // [04] Tipo
                        TamCargo()   ,; // [05] Tamanho
                        0            ,; // [06] Decimal
                        Nil          ,; // [07] Valid
                        Nil          ,; // [08] When
                        {}           ,; // [09] Valores Permitidos
                        .F.          ,; // [10] Obrigatório
                        Nil          ,; // [11] Init
                        .F.          ,; // [12] Chave
                        .F.          ,; // [13] Update
                        .T.          )  // [14] Virtual

    oStruD5B:AddField("LinDel"       ,; // [01] Titulo
                        "LinDel"     ,; // [02] ToolTip
                        "LINDEL"     ,; // [03] IdField
                        "L"          ,; // [04] Tipo
                        1            ,; // [05] Tamanho
                        0            ,; // [06] Decimal
                        Nil          ,; // [07] Valid
                        Nil          ,; // [08] When
                        {}           ,; // [09] Valores Permitidos
                        .F.          ,; // [10] Obrigatório
                        Nil          ,; // [11] Init
                        .F.          ,; // [12] Chave
                        .F.          ,; // [13] Update
                        .T.          )  // [14] Virtual

    oModel:AddGrid("D5BDETAIL", "D5AMASTER", oStruD5B)
    oModel:GetModel("D5BDETAIL"):SetDescription(FwX2Nome('D5B'))
    oModel:GetModel('D5BDETAIL'):SetOptional(.T.)
    oModel:GetModel("D5BDETAIL"):SetOnlyQuery(.T.)
    oModel:GetModel("D5BDETAIL"):SetUniqueLine({"D5B_SIMULA","D5B_COD","D5B_COMP","D5B_TRT"})
	oModel:GetModel("D5BDETAIL"):SetMaxLine(999999)
    
    // Modelo D5C - Roteiro
    oModel:AddGrid("D5CDETAIL", "D5AMASTER", oStruD5C)
    oModel:GetModel("D5CDETAIL"):SetDescription(FwX2Nome('D5C'))
    oModel:GetModel('D5CDETAIL'):SetOptional(.T.)
    oModel:GetModel("D5CDETAIL"):SetOnlyQuery(.T.)

    oStruD5C:SetProperty("D5C_OPERAC", MODEL_FIELD_VALID, {|| VldD5COper()})
    oStruD5C:SetProperty("D5C_SETUP" , MODEL_FIELD_VALID,FWBuildFeature(STRUCT_FEATURE_VALID,"Positivo()"))
	oStruD5C:SetProperty("D5C_TEMPAD", MODEL_FIELD_VALID,FWBuildFeature(STRUCT_FEATURE_VALID,"Positivo().Or.Vazio()"))
    oStruD5C:SetProperty("D5C_TAXA"  , MODEL_FIELD_WHEN, {|| .F. })
    oStruD5C:SetProperty("D5C_TAXASM", MODEL_FIELD_WHEN, {|| .T. })

    oStruD5C:AddField("Recno"        ,; // [01] Titulo
                        "NREG"       ,; // [02] ToolTip
                        "NREG"       ,; // [03] IdField
                        "N"          ,; // [04] Tipo
                        10           ,; // [05] Tamanho
                        0            ,; // [06] Decimal
                        Nil          ,; // [07] Valid
                        Nil          ,; // [08] When
                        {}           ,; // [09] Valores Permitidos
                        .F.          ,; // [10] Obrigatório
                        Nil          ,; // [11] Init
                        .F.          ,; // [12] Chave
                        .F.          ,; // [13] Update
                        .T.          )  // [14] Virtual

    oStruD5C:AddField("LinDel"       ,; // [01] Titulo
                        "LinDel"     ,; // [02] ToolTip
                        "LINDEL"     ,; // [03] IdField
                        "L"          ,; // [04] Tipo
                        1            ,; // [05] Tamanho
                        0            ,; // [06] Decimal
                        Nil          ,; // [07] Valid
                        Nil          ,; // [08] When
                        {}           ,; // [09] Valores Permitidos
                        .F.          ,; // [10] Obrigatório
                        Nil          ,; // [11] Init
                        .F.          ,; // [12] Chave
                        .F.          ,; // [13] Update
                        .T.          )  // [14] Virtual

    // Modelo D5D - Custos
    oModel:AddGrid("D5DDETAIL", "D5AMASTER", oStruD5D)
    oModel:GetModel("D5DDETAIL"):SetDescription(FwX2Nome('D5D'))
    oModel:GetModel('D5DDETAIL'):SetOptional(.T.)
    oModel:GetModel("D5DDETAIL"):SetOnlyQuery(.T.)
    oModel:GetModel("D5DDETAIL"):SetMaxLine(1)

    oStruD5D:SetProperty("D5D_CSTCOM", MODEL_FIELD_WHEN, {|| .F. })
    oStruD5D:SetProperty("D5D_TPCUST", MODEL_FIELD_VALID, {|| VldD5DCust()})

    oStruD5D:AddField("Recno"        ,; // [01] Titulo
                        "NREG"       ,; // [02] ToolTip
                        "NREG"       ,; // [03] IdField
                        "N"          ,; // [04] Tipo
                        10           ,; // [05] Tamanho
                        0            ,; // [06] Decimal
                        Nil          ,; // [07] Valid
                        Nil          ,; // [08] When
                        {}           ,; // [09] Valores Permitidos
                        .F.          ,; // [10] Obrigatório
                        Nil          ,; // [11] Init
                        .F.          ,; // [12] Chave
                        .F.          ,; // [13] Update
                        .T.          )  // [14] Virtual

    oStruD5D:AddField("LinDel"       ,; // [01] Titulo
                        "LinDel"     ,; // [02] ToolTip
                        "LINDEL"     ,; // [03] IdField
                        "L"          ,; // [04] Tipo
                        1            ,; // [05] Tamanho
                        0            ,; // [06] Decimal
                        Nil          ,; // [07] Valid
                        Nil          ,; // [08] When
                        {}           ,; // [09] Valores Permitidos
                        .F.          ,; // [10] Obrigatório
                        Nil          ,; // [11] Init
                        .F.          ,; // [12] Chave
                        .F.          ,; // [13] Update
                        .T.          )  // [14] Virtual

    // Dados do produto selecionado na arvore
    oStruNo:AddField(STR0042                 ,;  // [01] Titulo  "Produto"
                       STR0042               ,;  // [02] ToolTip  "Produto"
                       "CCODPRO"             ,;  // [03] IdField
                       "C"                   ,;  // [04] Tipo
                       TamSX3("D53_COD")[1]  ,;  // [05] Tamanho
                       0                     ,;  // [06] Decimal
                       Nil                   ,;  // [07] Valid
                       Nil                   ,;  // [08] When
                       {}                    ,;  // [09] Valores Permitidos
                       .F.                   ,;  // [10] Obrigatório
                       Nil                   ,;  // [11] Init
                       .F.                   ,;  // [12] Chave
                       .F.                   ,;  // [13] Update
                       .T.                   )   // [14] Virtual

    oStruNo:AddField(STR0043                 ,;  // [01] Titulo  "Desc. Produto" 
                       STR0043               ,;  // [02] ToolTip  "Desc. Produto" 
                       "CDESCPRO"            ,;  // [03] IdField
                       "C"                   ,;  // [04] Tipo
                       TamSX3("D53_DESC")[1] ,;  // [05] Tamanho
                       0                     ,;  // [06] Decimal
                       Nil                   ,;  // [07] Valid
                       Nil                   ,;  // [08] When
                       {}                    ,;  // [09] Valores Permitidos
                       .F.                   ,;  // [10] Obrigatório
                       Nil                   ,;  // [11] Init
                       .F.                   ,;  // [12] Chave
                       .F.                   ,;  // [13] Update
                       .T.                   )   // [14] Virtual

    oStruNo:AddField(STR0044                   ,;  // [01] Titulo  "Roteiro Pad."
                       STR0044                 ,;  // [02] ToolTip  "Roteiro Pad."
                       "CROTEIRO"              ,;  // [03] IdField
                       "C"                     ,;  // [04] Tipo
                       TamSX3("D5C_CODIGO")[1] ,;  // [05] Tamanho
                       0                       ,;  // [06] Decimal
                       Nil                     ,;  // [07] Valid
                       Nil                     ,;  // [08] When
                       {}                      ,;  // [09] Valores Permitidos
                       .F.                     ,;  // [10] Obrigatório
                       Nil                     ,;  // [11] Init
                       .F.                     ,;  // [12] Chave
                       .F.                     ,;  // [13] Update
                       .T.                     )   // [14] Virtual
    
    oStruNo:SetProperty("CROTEIRO", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, "ESTA101ROT()"))

    oModel:AddFields("NO_MASTER", "D5AMASTER", oStruNo, , , {|| loadCabInv()})
    oModel:GetModel("NO_MASTER"):SetDescription(STR0045) // "Estrutura e Roteiro"
    oModel:GetModel("NO_MASTER"):setForceLoad(.T.)

    oModel:SetPrimaryKey({})

Return oModel

//----------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
    Definições da view
    @type Function
    @author Squad Entradas
    @since 25/03/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function ViewDef()
    Local oView      := Nil
    Local cModo      := D5A->D5A_MODO
    Local cTipo      := D5A->D5A_TIPO
    Local oModel     := FWLoadModel("ESTA101")
    Local oStruSim   := FWFormStruct(2, "D5A", {|cCampo| "|" + AllTrim(cCampo) + "|" $ "|D5A_NUM|D5A_DESC|D5A_CODCEN|D5A_DESCEN|D5A_TIPO|D5A_TPCUST|D5A_STATUS|D5A_CODPRO|D5A_DESPRO|D5A_PLANO|"})
    Local oStruComp  := FWFormStruct(2, "D5B", {|cCampo| "|" + AllTrim(cCampo) + "|" $ "|D5B_COMP|D5B_DESC|D5B_TRT|D5B_QUANT|D5B_PERDA|"})
    Local oStruRote  := FWFormStruct(2, "D5C", {|cCampo| "|" + AllTrim(cCampo) + "|" $ "|D5C_OPERAC|D5C_DESCRI|D5C_RECURS|D5C_MAOOBR|D5C_SETUP|D5C_LOTPAD|D5C_TEMPAD|D5C_TPOPER|D5C_REFGRD|D5C_TAXA|D5C_TAXASM|"})
    Local oStruCust  := FWFormStruct(2, "D5D", {|cCampo| "|" + AllTrim(cCampo) + "|" $ "|D5D_TPCUST|D5D_CSTCOM|D5D_CSTFIM|"})
    Local oStruNoVir := FWFormViewStruct():New()
    Local lCenario   := !Empty(D5A->D5A_CODCEN)

    // Estrutura da Simulação
    oStruSim:SetProperty("D5A_DESC"  , MVC_VIEW_PICT, "@!S20")
    oStruSim:SetProperty("D5A_CODCEN", MVC_VIEW_CANCHANGE, .T.)
    oStruSim:SetProperty("D5A_CODCEN", MVC_VIEW_PICT, "@!S10")
    oStruSim:SetProperty("D5A_CODCEN", MVC_VIEW_CANCHANGE, .F.)
    oStruSim:SetProperty("D5A_DESCEN", MVC_VIEW_PICT, "@!S20")
    oStruSim:SetProperty("D5A_DESCEN", MVC_VIEW_CANCHANGE, .F.)
    oStruSim:SetProperty("D5A_TIPO"  , MVC_VIEW_CANCHANGE, .F.)
    oStruSim:SetProperty("D5A_TPCUST", MVC_VIEW_CANCHANGE, .F.)
    oStruSim:SetProperty("D5A_CODPRO", MVC_VIEW_PICT, "@!S15")
    oStruSim:SetProperty("D5A_DESPRO", MVC_VIEW_PICT, "@!S25")
    oStruSim:SetProperty("D5A_PLANO" , MVC_VIEW_PICT, "@!S10")
    
    If cModo == "2" .and. cTipo == "1" // Se for modo produção e produto novo, permite editar a descrição.
        oStruSim:SetProperty("D5A_CODPRO", MVC_VIEW_CANCHANGE, .F.)
        oStruSim:SetProperty("D5A_DESPRO", MVC_VIEW_CANCHANGE, .T.)
    Else
        oStruSim:SetProperty("D5A_CODPRO", MVC_VIEW_CANCHANGE, .F.)
        oStruSim:SetProperty("D5A_DESPRO", MVC_VIEW_CANCHANGE, .F.)
    EndIf    

    oView := FWFormView():New()
    oView:SetModel(oModel)

    // Divisão da tela: 25% Simulação e 75% Estrutura
    oView:CreateHorizontalBox("BOX_CABEC", 20)
    oView:CreateHorizontalBox("BOX_INFER", 80)

    oView:CreateVerticalBox("BOX_TREE", 15, "BOX_INFER")
    oView:CreateVerticalBox("BOX_GRID", 70, "BOX_INFER")
    oView:CreateVerticalBox("BOX_PAINEL", 15, "BOX_INFER")

    oView:CreateHorizontalBox("BOX_NO", 18, "BOX_GRID")
    oView:CreateHorizontalBox("BOX_TABS", 82, "BOX_GRID")

    oView:CreateFolder("PASTA_GRIDS", "BOX_TABS")
    oView:SetVldFolder({|cFolderID, nOldSheet, nSelSheet| VldFolder(cFolderID, nOldSheet, nSelSheet)})

    // Componentes (D5B)
    oView:AddSheet("PASTA_GRIDS", "ABA_D5B", STR0010) //"Estrutura"
    oView:CreateHorizontalBox("BOX_ABA_D5B", 100, , , "PASTA_GRIDS", "ABA_D5B")
    oView:AddGrid("VIEW_D5B", oStruComp, "D5BDETAIL")
    oView:SetOwnerView("VIEW_D5B", "BOX_ABA_D5B")

    // Tratamento para F3 do componente, com e sem cenário definido
    If lCenario
        oStruComp:SetProperty("D5B_COMP", MVC_VIEW_LOOKUP, "D53")
    Else
        oStruComp:SetProperty("D5B_COMP", MVC_VIEW_LOOKUP, "SB1") 
    EndIf

    // Roteiro (D5C)
    oView:AddSheet("PASTA_GRIDS", "ABA_D5C", STR0011) //"Roteiro"
    oView:CreateHorizontalBox("BOX_ABA_D5C", 100, , , "PASTA_GRIDS", "ABA_D5C")
    oView:AddGrid("VIEW_D5C", oStruRote, "D5CDETAIL")
    oView:SetOwnerView("VIEW_D5C", "BOX_ABA_D5C")

    // Custos (D5D)
    oView:AddSheet("PASTA_GRIDS", "ABA_D5D", STR0012) //"Composição do Custo"
    oView:CreateHorizontalBox("BOX_ABA_D5D", 100, , , "PASTA_GRIDS", "ABA_D5D")
    oView:AddGrid("VIEW_D5D", oStruCust, "D5DDETAIL")
    oView:SetOwnerView("VIEW_D5D", "BOX_ABA_D5D")
    
    // Cabeçalho Simulação
    oView:AddField("VIEW_SIMUL", oStruSim, "D5AMASTER")
    oView:SetOwnerView("VIEW_SIMUL", "BOX_CABEC")

    // Dados do produto selecionado na arvore
    oStruNoVir:AddField("CCODPRO"  ,; // [01]  C   Nome do Campo
                         "01"       ,; // [02]  C   Ordem
                         STR0042    ,; // [03]  C   Titulo do campo  "Produto"
                         STR0042    ,; // [04]  C   Descricao do campo  "Produto"
                         Nil        ,; // [05]  A   Array com Help
                         "C"        ,; // [06]  C   Tipo do campo
                         "@!S15"    ,; // [07]  C   Picture 
                         Nil        ,; // [08]  B   Bloco de Picture Var
                         Nil        ,; // [09]  C   Consulta F3 
                         .F.        ,; // [10]  L   Indica se o campo é alteravel
                         NIL        ,; // [11]  C   Pasta do campo
		                 NIL        ,; // [12]  C   Agrupamento do campo
		                 NIL        ,; // [13]  A   Lista de valores permitido do campo (Combo)
		                 NIL        ,; // [14]  N   Tamanho maximo da maior opção do combo
		                 NIL        ,; // [15]  C   Inicializador de Browse
		                 .T.        ,; // [16]  L   Indica se o campo é virtual
		                 NIL        ,; // [17]  C   Picture Variavel
		                 NIL        )  // [18]  L   Indica pulo de linha após o campo

    oStruNoVir:AddField("CDESCPRO"  ,; // [01]  C   Nome do Campo
                         "02"        ,; // [02]  C   Ordem
                         STR0043     ,; // [03]  C   Titulo do campo  "Desc. Produto"
                         STR0043     ,; // [04]  C   Descricao do campo  "Desc. Produto"
                         Nil         ,; // [05]  A   Array com Help
                         "C"         ,; // [06]  C   Tipo do campo 
                         "@!S25"     ,; // [07]  C   Picture  
                         Nil         ,; // [08]  B   Bloco de Picture Var 
                         Nil         ,; // [09]  C   Consulta F3  
                         .F.         ,; // [10]  L   Indica se o campo é alteravel
                         NIL         ,;	// [11]  C   Pasta do campo
		                 NIL         ,;	// [12]  C   Agrupamento do campo
		                 NIL         ,;	// [13]  A   Lista de valores permitido do campo (Combo)
		                 NIL         ,;	// [14]  N   Tamanho maximo da maior opção do combo
		                 NIL         ,;	// [15]  C   Inicializador de Browse
		                 .T.         ,;	// [16]  L   Indica se o campo é virtual
		                 NIL         ,;	// [17]  C   Picture Variavel
		                 NIL         )	// [18]  L   Indica pulo de linha após o campo

    oStruNoVir:AddField("CROTEIRO"  ,; // [01]  C   Nome do Campo
                         "03"        ,; // [02]  C   Ordem
                         STR0044     ,; // [03]  C   Titulo do campo  "Roteiro"
                         STR0044     ,; // [04]  C   Descricao do campo  "Roteiro"
                         Nil         ,; // [05]  A   Array com Help
                         "C"         ,; // [06]  C   Tipo do campo
                         "@!S5"      ,; // [07]  C   Picture 
                         Nil         ,; // [08]  B   Bloco de Picture Var
                         "D5C001"    ,; // [09]  C   Consulta F3 
                         .T.         ,; // [10]  L   Indica se o campo é alteravel
                         NIL         ,;	// [11]  C   Pasta do campo
		                 NIL         ,;	// [12]  C   Agrupamento do campo
		                 NIL         ,;	// [13]  A   Lista de valores permitido do campo (Combo)
		                 NIL         ,;	// [14]  N   Tamanho maximo da maior opção do combo
		                 NIL         ,;	// [15]  C   Inicializador de Browse
		                 .T.         ,;	// [16]  L   Indica se o campo é virtual
		                 NIL         ,;	// [17]  C   Picture Variavel
		                 NIL         )	// [18]  L   Indica pulo de linha após o campo
                         
    oView:AddField("VIEW_NO", oStruNoVir, "NO_MASTER")
    oView:SetOwnerView("VIEW_NO", "BOX_NO")
    oView:EnableTitleView("VIEW_NO", STR0045) // "Estrutura e Roteiro"

    oView:AddOtherObject("ESTR_TREE", {|oPanel| MontaTree(oPanel)})
	oView:SetOwnerView("ESTR_TREE",'BOX_TREE')
    oView:EnableTitleView("ESTR_TREE", STR0041) //"Estrutura"

    oView:AddOtherObject("CUST_PANEL", {|oPanel| MontaPanel(oPanel)})
	oView:SetOwnerView("CUST_PANEL",'BOX_PAINEL')
    oView:EnableTitleView("CUST_PANEL", STR0060) // "Resumo - Resultados"

    oView:SetViewProperty("VIEW_SIMUL", "SETLAYOUT", { FF_LAYOUT_HORZ_DESCR_TOP, 4 })
    oView:SetViewProperty("VIEW_NO", "SETLAYOUT", { FF_LAYOUT_HORZ_DESCR_TOP, 4 })

    oView:SetAfterViewActivate({|oView| AfterView(oView)})
    
    oView:SetCloseOnOk({|| .T.})

Return oView

//----------------------------------------------------------------------------------
/*/{Protheus.doc} ESTA101Inc
    Função de inclusão da simulação de custos, com validação prévia e criação do registro na tabela D5A.
    Cria um FWDialogModal para entrada dos dados necessários para a simulação.
    @type Function
    @author Squad Entradas
    @since 01/04/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Function ESTA101Inc()
    Local oModal     := Nil
    Local oPanel     := Nil
    Local oContainer := Nil
    Local oFontTit   := TFont():New("Arial", , -16, .T.) 
    Local oFontSub   := TFont():New("Arial", , -12, .F.) 
    Local oSayTit    := Nil
    Local oSaySub    := Nil 
    Local oSayCen    := Nil 
    Local oSayTipo   := Nil 
    Local oSayProd   := Nil 
    Local oSayAjuda  := Nil 
    Local oSayNome   := Nil 
    Local oSayCusto  := Nil
    Local oGetCen    := Nil 
    Local oCboTipo   := Nil 
    Local oGetProd   := Nil
    Local oGetNome   := Nil 
    Local oCboCusto  := Nil
    Local oGetPDesc  := Nil
    Local oSayPDesc  := Nil
    
    Local lConfirm  := .F.
    Local dDataInc  := Date()
    
    Local cTipo     := "1" 
    Local cProduto  := Space(TamSX3("D5A_CODPRO")[1])
    Local cPDesc    := Space(TamSX3("D5A_DESPRO")[1])
    Local cNomeSim  := Space(TamSX3("D5A_DESC")[1])
    Local cFilOri   := ""
    Local cOrig     := "3"
    Local aAreaOri  := Nil
    Local cCusto    := "1"
    Local cNumSim   := ""
    Local aOpTipo   := {STR0014, STR0015} //"1 - Novo Produto", "2 - Produto Existente"                                                                           
    Local aOpCusto  := {STR0016, STR0017, STR0018, STR0019, STR0020, STR0021, STR0022} //"1 - Custo Standard", "2 - Ult.Preco de Compra", "3 - Custo Medio Moeda 1", "4 - Custo Medio Moeda 2", "5 - Custo Medio Moeda 3", "6 - Custo Medio Moeda 4", "7 - Custo Medio Moeda 5"        
    Local cCenario  := Space(TamSX3("D50_COD")[1])

    oModal := FWDialogModal():New()
    oModal:SetSize(280, 240) 
    oModal:SetEscClose(.T.)
    oModal:SetBackground(.T.) 
    
    oModal:CreateDialog()
    oPanel := oModal:GetPanelMain()
    
    oContainer := TPanel():New(0, 0, "", oPanel, , , , , , 0, 0)
    oContainer:Align := CONTROL_ALIGN_ALLCLIENT

    // Titulo
    oSayTit := TSay():New(10, 15, {|| STR0023}, oContainer, , , , , , .T., , , 150, 12, , , , , , .T.) //"Nova Simulação de Custo"
    oSayTit:oFont := oFontTit
    //Subtitulo
    oSaySub := TSay():New(25, 15, {|| STR0024}, oContainer, , , , , , .T., , , 200, 10, , , , , , .T.) //"Crie uma nova simulação de custo para um produto existente ou inédito."
    oSaySub:oFont := oFontSub
    oSaySub:nClrText := CLR_GRAY
    // Cenário
    oSayCen := TSay():New(55, 15, {|| STR0025}, oContainer, , , , , , .T., , , 60, 10, , , , , , .T.) //"Cenário de Custo"
    oGetCen := TGet():New(52, 80, {|x| IIf(PCount()==0, cCenario, cCenario := x)}, oContainer, 105, 10, "@!", , , , , , , .T.)
    oGetCen:cF3 := "D50" 
    // Tipo de Simulação
    oSayTipo := TSay():New(85, 15, {|| STR0026}, oContainer, , , , , , .T., , , 60, 10, , , , , , .T.) //"Tipo de Simulação *"
    oCboTipo := TComboBox():New(82, 80, {|x| IIf(PCount()==0, cTipo, cTipo := x)}, aOpTipo, 105, 10, oContainer, , , , , , .T.)
    oCboTipo:bChange := {|| UpdTipoSim(cTipo, oGetProd, oGetPDesc) }
    // Produto
    oSayProd := TSay():New(115, 15, {|| STR0027}, oContainer, , , , , , .T., , , 60, 10, , , , , , .T.) //"Código do Produto *"
    oGetProd := TGet():New(112, 80, {|x| IIf(PCount()==0, cProduto, cProduto := x)}, oContainer, 105, 10, "@!", , , , , , , .T.)
    oSayPDesc := TSay():New(145, 15, {|| STR0076}, oContainer, , , , , , .T., , , 60, 10, , , , , , .T.) //"Descrição do Produto *"
    oGetPDesc := TGet():New(142, 80, {|x| IIf(PCount()==0, cPDesc, cPDesc := x)}, oContainer, 105, 10, "@!", , , , , , , .T.)
    oGetProd:cF3 := "SB1"
    oGetProd:bValid := {|| VldGetProd(cProduto, cCenario, cTipo, oGetPDesc) }
    oGetCen:bValid := {|| If(VldCenario(cCenario), (oGetProd:cF3 := If(!Empty(cCenario), "D53001", "SB1"), .T.), .F.) } // Mudança do F3 em caso de cenário definido
    // Nome da Simulação
    oSayNome := TSay():New(175, 15, {|| STR0029}, oContainer, , , , , , .T., , , 60, 10, , , , , , .T.) //"Desc. da Simulação *" 
    oGetNome := TGet():New(172, 80, {|x| IIf(PCount()==0, cNomeSim, cNomeSim := x)}, oContainer, 105, 10, "@!", , , , , , , .T.)
    // Tipo de Custo
    oSayCusto := TSay():New(205, 15, {|| STR0030}, oContainer, , , , , , .T., , , 80, 10, , , , , , .T.) //"Tipo de Custo *"
    oCboCusto := TComboBox():New(202, 80, {|x| IIf(PCount()==0, cCusto, cCusto := x)}, aOpCusto, 105, 10, oContainer, , , , , , .T.)
    oSayAjuda := TSay():New(232, 15, {|| STR0028}, oContainer, , , , , , .T., , , 200, 15, , , , , , .T.) //"O sistema detectará automaticamente se o produto tem estrutura (Modo Produção) ou Modo Compra"
    oSayAjuda:oFont := oFontSub
    oSayAjuda:nClrText := CLR_GRAY
    oModal:AddOkButton({|| If( ValidaInc(cCenario, cTipo, cProduto, cNomeSim, cPDesc), (lConfirm := .T., oModal:DeActivate()), Nil ) }, STR0031) //"Criar Simulação"
    oModal:AddCloseButton({|| lConfirm := .F., oModal:DeActivate() }, STR0032) //"Cancelar"

    oModal:Activate()

    If lConfirm
        dDataInc := Date()
        cNumSim := GetSxeNum("D5A", "D5A_NUM")

        Begin Transaction
            RecLock("D5A", .T.)
                D5A->D5A_FILIAL := xFilial("D5A")
                D5A->D5A_NUM    := cNumSim
                D5A->D5A_CODCEN := Rtrim(cCenario)
                D5A->D5A_TIPO   := Left(cTipo, 1)
                
                D5A->D5A_CODPRO := cProduto
                D5A->D5A_DESPRO := cPDesc

                If Left(cTipo, 1) == "2" // 2=produto existente
                    cFilOri := xFilial("D5A")
                    cOrig   := "1"
                    If Empty(cCenario)
                        aAreaOri := GetArea()
                        DbSelectArea("SB1")
                        SB1->(DbSetOrder(1))
                        If SB1->(DbSeek(xFilial("SB1") + PadR(cProduto, TamSX3("B1_COD")[1])))
                            cFilOri := SB1->B1_FILIAL
                            cOrig   := "1"
                        Else
                            cOrig   := "3"
                        EndIf
                        RestArea(aAreaOri)
                    Else
                        aAreaOri := GetArea()
                        DbSelectArea("D53")
                        D53->(DbSetOrder(2))
                        If D53->(DbSeek(xFilial("D53") + PadR(cCenario, TamSX3("D53_CODCEN")[1]) + PadR(cProduto, TamSX3("D53_COD")[1])))
                            cFilOri := D53->D53_FILORI
                            cOrig   := "2"
                        Else
                            cOrig   := "3"
                        EndIf
                        RestArea(aAreaOri)
                    EndIf
                EndIf
                
                D5A->D5A_FILORI := cFilOri
                D5A->D5A_ORIGEM := cOrig
                D5A->D5A_DESC   := RTrim(cNomeSim)
                D5A->D5A_TPCUST := Left(cCusto, 1)
                D5A->D5A_DTINCL := dDataInc
                D5A->D5A_STATUS := "1" 
                D5A->D5A_CODUSR := RETCODUSR()

                // deifnir da onde comparar: cenario (D54) ou producao (SG1)
                // definir se o tipo (1-novo ou 2-existente)
                // se for novo, não copia nada e abre modo produção
                // se for existente, verifica se há estrutura/roteiro
                // se não houver, abre modo compra

                If Left(cTipo, 1) == "1"
                    // Produto novo, não copia nada e inicia em branco, modo produção
                    D5A->D5A_MODO := "2" // Modo produção
                EndIf

                If Left(cTipo, 1) == "2" .And. Empty(cCenario) // ValidEstru(cProduto)
                    // Produto existente sem cenário, verifica se há estrutura/roteiro na SG1 para definir modo produção ou compra
                    If ValidEstru(cProduto) .Or. ValidRotei(cProduto)
                        // Produto existente com estrutura, copia para simulação e inicia em modo produção
                        D5A->D5A_MODO := "2" // Modo produção
                        CopiaCusto(cNumSim, cCenario, cProduto, Left(cCusto, 1))
                        CopiaNivel(cNumSim, cCenario, cProduto, Left(cCusto, 1))
                    Else
                        // Produto existente sem estrutura/roteiro, modo compra com copia do custo
                        D5A->D5A_MODO := "1" // Modo compra
                        CopiaCusto(cNumSim, cCenario, cProduto, Left(cCusto, 1))
                    EndIf
                EndIf

                If Left(cTipo, 1) == "2" .And. !Empty(cCenario) // ValidEstru(cProduto,cCenario)
                    // Produto existente com cenário, verifica se há estrutura/roteiro na D54 para definir modo produção ou compra
                    If ValidEstru(cProduto, cCenario) .Or. ValidRotei(cProduto, cCenario)
                        // Produto existente com estrutura no cenário, copia para simulação e inicia em modo produção
                        D5A->D5A_MODO := "2" // Modo produção
                        CopiaCusto(cNumSim, cCenario, cProduto, Left(cCusto, 1))
                        CopiaNivel(cNumSim, cCenario, cProduto, Left(cCusto, 1))
                    Else
                        // Produto existente sem estrutura no cenário, modo compra com copia do custo
                        D5A->D5A_MODO := "1" // Modo compra
                        CopiaCusto(cNumSim, cCenario, cProduto, Left(cCusto, 1))
                    EndIf
                EndIf

            MsUnlock()
            
        End Transaction 

        ConfirmSX8()
    Else
        RollBackSX8()
    EndIf

    If oModal != Nil
        FreeObj(oModal)
        oModal := Nil
    EndIf

    If lConfirm .And. !Empty(cNumSim)
        ESTA101Alt(4, cNumSim) // Chamada da função de alteração no final da inclusão
    EndIf 
    
Return Nil
    
//----------------------------------------------------------------------------------
/*/{Protheus.doc} ESTA101Alt
    Função que valida opção do menu, ajustando para o tipo de exibição correta da simulação
    @type Function
    @author Squad Entradas
    @since 01/04/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Function ESTA101Alt(nOpcao, cNumSim)
    Local oModel    := Nil
    Local cTitulo   := ""
    Local cModo     := ""

    Default nOpcao  := 4
    Default cNumSim := D5A->D5A_NUM

    DbSelectArea("D5A")
    D5A->(DbSetOrder(1))
    If D5A->(DbSeek(xFilial("D5A") + cNumSim))

        cModo := D5A->D5A_MODO
        
        If cModo == "1"
            cTitulo := STR0033 + cNumSim //"Modo Compra: "
        EndIf

        If cModo == "2"
            cTitulo := STR0034 + cNumSim //"Modo Produção: "
        EndIf

        oModel := FWLoadModel("ESTA101")

        FWExecView(cTitulo, "ESTA101", nOpcao, , , , , , , , , oModel)
        
    Else
        FWAlertError(STR0035) //"Não foi possível localizar o registro"
    EndIf

Return Nil

//----------------------------------------------------------------------------------
/*/{Protheus.doc} ValidaInc
    Função de validação do modal de inclusão da simulação.
    @type Function
    @author Squad Entradas
    @since 01/04/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function ValidaInc(cCenario, cTipo, cProduto, cNomeSim, cPDesc)
    Local lRet := .T.

    If Empty(cProduto)
        FWAlertInfo(STR0038, STR0037) //"O código do Produto é obrigatório." "Atenção"
        lRet := .F.
    EndIf

    If Left(cTipo, 1) == "1" .And. Empty(cPDesc) // Exige apenas se for produto novo
        FWAlertInfo(STR0077, STR0037) //"A descrição do Produto é obrigatório." "Atenção"
        lRet := .F.
    EndIf
    
    If Empty(cNomeSim)
        FWAlertInfo(STR0040, STR0037) //"A descrição da Simulação é obrigatória."
        lRet := .F.
    EndIf

Return lRet

//----------------------------------------------------------------------------------
/*/{Protheus.doc} CopiaNivel
    Função de copia dos dados da simulação, com base ou não em cenario.
    @type Function
    @author Squad Entradas
    @since 06/04/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function CopiaNivel(cNumSim, cCenario, cProdPai, cCusto)
    Local aProdComp := {}
    Local aArea     := GetArea()
    Local aAreaD58  := Nil
    Local aAreaD56  := Nil
    Local aAreaSH1  := Nil
    Local aAreaSB1  := Nil
    Local aAreaSB2  := Nil
    Local nI        := 0
    Local cRotPad   := ""
    Local cCcustoRec:= ""
    Local cProdMod  := ""
    Local cLocPad   := ""
    
    // Copia do roteiro (D55 ou SG2)
    If !Empty(cCenario)
        DbSelectArea("D55")
        D55->(DbSetOrder(2)) // Filial + Cenario + Produto
        If D55->(DbSeek(xFilial("D55") + PadR(cCenario, TamSX3("D55_CODCEN")[1]) + PadR(cProdPai, TamSX3("D55_PRODUT")[1])))
            While !D55->(Eof()) .And. D55->D55_FILIAL == xFilial("D55") .And. D55->D55_CODCEN == cCenario .And. D55->D55_PRODUT == cProdPai
                RecLock("D5C", .T.)
                    D5C->D5C_FILIAL := xFilial("D5C")
                    D5C->D5C_SIMULA := cNumSim
                    D5C->D5C_PRODUT := cProdPai
                    D5C->D5C_CODIGO := D55->D55_CODIGO
                    D5C->D5C_OPERAC := D55->D55_OPERAC
                    D5C->D5C_DESCRI := D55->D55_DESCRI
                    D5C->D5C_RECURS := D55->D55_RECURS
                    D5C->D5C_MAOOBR := D55->D55_MAOOBR
                    D5C->D5C_SETUP  := D55->D55_SETUP
                    D5C->D5C_TEMPAD := D55->D55_TEMPAD
                    D5C->D5C_LOTPAD := D55->D55_LOTPAD
                    D5C->D5C_TPOPER := D55->D55_TPOPER
                    D5C->D5C_REFGRD := D55->D55_REFGRD
                    If !Empty(D55->D55_RECURS)
                        aAreaD58 := D58->(GetArea())
                        aAreaD56 := D56->(GetArea())

                        DbSelectArea("D58")
                        D58->(DbSetOrder(2)) // D58_FILIAL+D58_CODCEN+D58_CODIGO
                        If D58->(DbSeek(xFilial("D58") + PadR(cCenario, TamSX3("D58_CODCEN")[1]) + PadR(D55->D55_RECURS, TamSX3("D58_CODIGO")[1])))
                            If !Empty(D58->D58_CCUSTO)
                                DbSelectArea("D56")
                                D56->(DbSetOrder(2)) //D56_FIILAL+D56_FILORI+D56_CODCEN+D56_CODCC
                                    If D56->(DbSeek(xFilial("D56") + PadR(D58->D58_FILORI, TamSX3("D56_FILORI")[1]) + PadR(cCenario, TamSX3("D56_CODCEN")[1]) + PadR(D58->D58_CCUSTO, TamSX3("D56_CODCC")[1])))
                                        D5C->D5C_TAXA   := D56->D56_TAXA
                                        D5C->D5C_TAXASM := D56->D56_TAXA
                                    EndIf
                            EndIf
                        EndIf
                        
                        RestArea(aAreaD58)
                        RestArea(aAreaD56)

                    EndIf
                D5C->(MsUnlock())
                D55->(DbSkip())
            EndDo
        EndIf
    Else
        DbSelectArea("SG2")
        SG2->(DbSetOrder(1)) // Filial + Produto
        If SG2->(DbSeek(xFilial("SG2") + PadR(cProdPai, TamSX3("G2_PRODUTO")[1])))
            While !SG2->(Eof()) .And. SG2->G2_FILIAL == xFilial("SG2") .And. SG2->G2_PRODUTO == cProdPai
                RecLock("D5C", .T.)
                    D5C->D5C_FILIAL := xFilial("D5C")
                    D5C->D5C_SIMULA := cNumSim
                    D5C->D5C_PRODUT := cProdPai
                    D5C->D5C_CODIGO := SG2->G2_CODIGO
                    D5C->D5C_OPERAC := SG2->G2_OPERAC
                    D5C->D5C_DESCRI := SG2->G2_DESCRI
                    D5C->D5C_RECURS := SG2->G2_RECURSO
                    D5C->D5C_MAOOBR := SG2->G2_MAOOBRA
                    D5C->D5C_SETUP  := SG2->G2_SETUP
                    D5C->D5C_TEMPAD := SG2->G2_TEMPAD
                    D5C->D5C_LOTPAD := SG2->G2_LOTEPAD
                    D5C->D5C_TPOPER := SG2->G2_TPOPER
                    D5C->D5C_REFGRD := SG2->G2_REFGRD
                    If !Empty(SG2->G2_RECURSO)
                        aAreaSH1 := SH1->(GetArea())
                        aAreaSB1 := SB1->(GetArea())
                        aAreaSB2 := SB2->(GetArea())
                        
                        DbSelectArea("SH1")
                        SH1->(DbSetOrder(1)) // H1_FILIAL+H1_CODIGO
                        If SH1->(DbSeek(xFilial("SH1") + PadR(SG2->G2_RECURSO, TamSX3("H1_CODIGO")[1])))
                            If !Empty(SH1->H1_CCUSTO)
                                cCcustoRec := RTrim(SH1->H1_CCUSTO)

                                DbSelectArea("SB1")
                                SB1->(DbSetOrder(1)) // B1_FILIAL+B1_COD
                                cProdMod := "MOD" + cCcustoRec

                                If SB1->(DbSeek(xFilial("SB1") + PadR(cProdMod, TamSX3("B1_COD")[1])))
                                    
                                    If !Empty(SB1->B1_LOCPAD)
                                        cLocPad := SB1->B1_LOCPAD
                                    Else
                                        cLocPad := "01"
                                    EndIf

                                    DbSelectArea("SB2")
                                    SB2->(DbSetOrder(1)) // B2_FILIAL+B2_COD+B2_LOCAL
                                    If SB2->(DbSeek(xFilial("SB2") + PadR(SB1->B1_COD, TamSX3("B2_COD")[1]) + PadR(cLocPad, TamSX3("B2_LOCAL")[1])))
                                        D5C->D5C_TAXA   := SB2->B2_CM1
                                        D5C->D5C_TAXASM := SB2->B2_CM1
                                    Else
                                        D5C->D5C_TAXA   := 0
                                        D5C->D5C_TAXASM := 0
                                    EndIf
                                Else
                                    SB1->(DbSetOrder(8)) // B1_FILIAL+B1_CCCUSTO+B1_GCCUSTO
                                    If SB1->(DbSeek(xFilial("SB1") + PadR(cCcustoRec, TamSX3("B1_CCCUSTO")[1]), .T.)) .And. RTrim(SB1->B1_CCCUSTO) == RTrim(cCcustoRec)
                                        
                                        If !Empty(SB1->B1_LOCPAD)
                                            cLocPad := SB1->B1_LOCPAD
                                        Else
                                            cLocPad := "01"
                                        EndIf

                                        DbSelectArea("SB2")
                                        SB2->(DbSetOrder(1)) // B2_FILIAL+B2_COD+B2_LOCAL
                                        If SB2->(DbSeek(xFilial("SB2") + PadR(SB1->B1_COD, TamSX3("B2_COD")[1]) + PadR(cLocPad, TamSX3("B2_LOCAL")[1])))
                                            D5C->D5C_TAXA   := SB2->B2_CM1
                                            D5C->D5C_TAXASM := SB2->B2_CM1
                                        EndIf
                                    Else
                                        D5C->D5C_TAXA   := 0
                                        D5C->D5C_TAXASM := 0
                                    EndIf
                                EndIf
                            EndIf
                            
                        EndIf
                        
                        RestArea(aAreaSH1)
                        RestArea(aAreaSB1)
                        RestArea(aAreaSB2)

                    EndIf
                D5C->(MsUnlock())
                SG2->(DbSkip())
            EndDo
        EndIf
    EndIf

    // Copia da estrutura (D54 ou SG1)
    If !Empty(cCenario)
        DbSelectArea("D54")
        D54->(DbSetOrder(2)) // Filial + Cenario + Produto
        If D54->(DbSeek(xFilial("D54") + PadR(cCenario, TamSX3("D54_CODCEN")[1]) + PadR(cProdPai, TamSX3("D54_COD")[1])))
            While !D54->(Eof()) .And. D54->D54_FILIAL == xFilial("D54") .And. D54->D54_CODCEN == cCenario .And. D54->D54_COD == cProdPai
                
                cRotPad := GetRotPad(D54->D54_COMP)
                
                AAdd(aProdComp, { D54->D54_COMP,  ;
                                  D54->D54_TRT,   ;
                                  D54->D54_QUANT, ;
                                  D54->D54_NIV,   ;
                                  D54->D54_NIVINV,;
                                  cRotPad         ;
                                })
                D54->(DbSkip())
            EndDo
        EndIf
    Else
        DbSelectArea("SG1")
        SG1->(DbSetOrder(1)) // Filial + Produto
        If SG1->(DbSeek(xFilial("SG1") + PadR(cProdPai, TamSX3("G1_COD")[1])))
            While !SG1->(Eof()) .And. SG1->G1_FILIAL == xFilial("SG1") .And. SG1->G1_COD == cProdPai
                
                cRotPad := GetRotPad(SG1->G1_COMP)
                
                AAdd(aProdComp, { SG1->G1_COMP,  ;
                                  SG1->G1_TRT,   ;
                                  SG1->G1_QUANT, ;
                                  SG1->G1_NIV,   ;
                                  SG1->G1_NIVINV,;
                                  cRotPad        ;
                                })
                SG1->(DbSkip())
            EndDo
        EndIf
    EndIf

    // grava estrutura e faz recursividade para os filhos
    For nI := 1 To Len(aProdComp)
        cDescri := ""

        If !Empty(cCenario)
            DbSelectArea("D53")
            D53->(DbSetOrder(2)) // D53_FILIAL + D53_CODCEN + D53_COD
            If D53->(DbSeek(xFilial("D53") + PadR(cCenario, TamSX3("D53_CODCEN")[1]) + PadR(aProdComp[nI][1], TamSX3("D53_COD")[1])))
                cDescri := D53->D53_DESC
            EndIf
        EndIf

        If Empty(cDescri)
            DbSelectArea("SB1")
            SB1->(DbSetOrder(1)) // B1_FILIAL + B1_COD
            If SB1->(DbSeek(xFilial("SB1") + PadR(aProdComp[nI][1], TamSX3("B1_COD")[1])))
                cDescri := SB1->B1_DESC
            EndIf
        EndIf

        RecLock("D5B", .T.)
            D5B->D5B_FILIAL := xFilial("D5B")
            D5B->D5B_SIMULA := cNumSim
            D5B->D5B_COD    := cProdPai
            D5B->D5B_COMP   := aProdComp[nI][1]
            D5B->D5B_DESC   := cDescri
            D5B->D5B_TRT    := aProdComp[nI][2]
            D5B->D5B_QUANT  := aProdComp[nI][3]
            D5B->D5B_NIV    := aProdComp[nI][4]
            D5B->D5B_NIVINV := aProdComp[nI][5]
            D5B->D5B_ROTPAD := aProdComp[nI][6]
            D5B->D5B_TPCUST := cCusto
        D5B->(MsUnlock())
        
        CopiaCusto(cNumSim, cCenario, aProdComp[nI][1], cCusto) 

        CopiaNivel(cNumSim, cCenario, aProdComp[nI][1], cCusto)
    Next

    RestArea(aArea)  
Return

//----------------------------------------------------------------------------------
/*/{Protheus.doc} CopiaCusto
    Função de copia dos custos da simulacao, se o produto for para compra.
    @type Function
    @author Squad Entradas
    @since 08/04/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function CopiaCusto(cNumSim, cCenario, cProduto, cCusto)
    Local nCstCom  := GetCusto(cCenario, cProduto, cCusto)
    Local cFilOri  := GetFilOri(cCenario, cProduto)
    Local lIncluir := .T.
    Local aArea    := GetArea()
    
    If nCstCom >= 0
        // Verifica se o registro já existe para evitar chave duplicada
        DbSelectArea("D5D")
        D5D->(DbSetOrder(1)) // D5D_FILIAL + D5D_SIMULA + D5D_COD + D5D_TPCUST
        lIncluir := !D5D->(DbSeek(xFilial("D5D") + PadR(cNumSim, TamSX3("D5D_SIMULA")[1]) + PadR(cProduto, TamSX3("D5D_COD")[1]) + PadR(cCusto, TamSX3("D5D_TPCUST")[1])))
        
        If lIncluir
            RecLock("D5D", .T.)
                D5D->D5D_FILIAL := xFilial("D5D")
                D5D->D5D_SIMULA := cNumSim
                D5D->D5D_COD    := cProduto
                D5D->D5D_TPCUST := cCusto
                D5D->D5D_CSTCOM := nCstCom
                D5D->D5D_CSTFIM := nCstCom
                D5D->D5D_FILORI := cFilOri
                If !Empty(cCenario)
                    D5D->D5D_CODCEN := cCenario
                EndIf
            D5D->(MsUnlock())
        EndIf
    EndIf
    
    RestArea(aArea)
    
Return .T.

//----------------------------------------------------------------------------------
/*/{Protheus.doc} ValidEstru
    Função de querifica se o produto possue estrutura em alguma tabela.
    @type Function
    @author Squad Entradas
    @since 07/04/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function ValidEstru(cProduto, cCenario)
    Local lRet := .F.
    Local aArea := GetArea()
    Default cCenario := ""

    If !Empty(cCenario)
        DbSelectArea("D54")
        D54->(DbSetOrder(2))
        If D54->(DbSeek(xFilial("D54") + PadR(cCenario, TamSX3("D54_CODCEN")[1]) + PadR(cProduto, TamSX3("D54_COD")[1])))
            lRet := .T.
        EndIf
    EndIf

    If Empty(cCenario)
        DbSelectArea("SG1")
        SG1->(DbSetOrder(1))
        If SG1->(DbSeek(xFilial("SG1") + PadR(cProduto, TamSX3("G1_COD")[1])))
            lRet := .T.
        EndIf
    EndIf

    RestArea(aArea)

Return lRet

//----------------------------------------------------------------------------------
/*/{Protheus.doc} ValidRotei
    Função de verifica se o produto possue roteiro em alguma tabela.
    @type Function
    @author Squad Entradas
    @since 07/04/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function ValidRotei(cProduto, cCenario)
    Local lRet := .F.
    Local aArea := GetArea()
    Default cCenario := ""

    If !Empty(cCenario)
        DbSelectArea("D55")
        D55->(DbSetOrder(2))
        If D55->(DbSeek(xFilial("D55") + PadR(cCenario, TamSX3("D55_CODCEN")[1]) + PadR(cProduto, TamSX3("D55_PRODUT")[1])))
            lRet := .T.
        EndIf
    EndIf

    If Empty(cCenario)
        DbSelectArea("SG2")
        SG2->(DbSetOrder(1))
        If SG2->(DbSeek(xFilial("SG2") + PadR(cProduto, TamSX3("G2_PRODUTO")[1])))
            lRet := .T.
        EndIf
    EndIf

    RestArea(aArea)

Return lRet

//----------------------------------------------------------------------------------
/*/{Protheus.doc} MontaTree
    Funcao de realiza a montagem da DBTree referente a estrutura do produto
    @type Function
    @author Squad Entradas
    @since 14/04/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function MontaTree(oPanel)
    
    If soTree == Nil
        soTree := DbTree():New(0, 0, 100, 100, oPanel,.T.,,.T.)
        soTree:Align := CONTROL_ALIGN_ALLCLIENT
        soTree:bChange   := {|| TreeChange() }
    Else
        soTree:Reset()
    EndIf

Return soTree

//----------------------------------------------------------------------------------
/*/{Protheus.doc} AdicPai
    Funcao que adiciona o produto pai na estrutura da DBTree, chamando a função MontaCargo
    para gerar a string de identificação na arvore de estrutura.
    @type Function
    @author Squad Entradas
    @since 15/04/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function AdicPai(cNumSim, cProduto)
    Local aAreaD5B := D5B->(GetArea())
    Local cCargo := ""

    D5B->(DbSetOrder(2)) // D5B_FILIAL + D5B_SIMULA + D5B_COD
    If D5B->(DbSeek(xFilial("D5B") + PadR(cNumSim, TamSX3("D5B_SIMULA")[1]) + PadR(cProduto, TamSX3("D5B_COD")[1])))
        cCargo := MontaCargo(IND_ESTR, cProduto, cProduto, D5B->(Recno())) 
    Else
        // Se não encontrar registro da D5B, inicia como RECNO 0 para não quebrar
        cCargo := MontaCargo(IND_ESTR, cProduto, cProduto, 0)
    EndIf

    RestArea(aAreaD5B)

Return cCargo

//----------------------------------------------------------------------------------
/*/{Protheus.doc} LoadEstr
    Função que adiciona o produto pai na estrutura da DBTree, chamando a função MontaCargo
    para gerar a string de identificação na arvore de estrutura.

    A primeira iteração é baseada no produto pai.
    Verifica o produto intermediario, cria seu cargo na tree e verifica se o componente
    possui filho ou não e posiciona o ponteiro da tree no produto pai.
    Se possui filho, ele chama recursivamente a função LoadEstr para iterar novamente.
    Chegando no final da estrutura do intermediário, caso não possua, finaliza com o 
    ultimo item e não faz nenhuma nova iteração recursiva.
    @type Function
    @author Squad Entradas
    @since 15/04/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function LoadEstr(soTree, cNumSim, cCodPai, cCargoPai, oModel)
    Local aFilhos     := {}
    Local nI          := 0
    Local cCargoFilho := ""
    Local cComp       := ""
    Local oEvent      := gtMdlEvent(oModel, "ESTA101EVDEF")
    Local aFieldsB    := oModel:GetModel("D5BDETAIL"):GetStruct():GetFields()
    Local nPosComp    := aScan(aFieldsB, {|x| AllTrim(x[3]) == "D5B_COMP"})
    Local nPosCargo   := aScan(aFieldsB, {|x| AllTrim(x[3]) == "CARGO"})
    Local nPosDel     := aScan(aFieldsB, {|x| AllTrim(x[3]) == "LINDEL"})

    // Lista de componentes do produto pai, vindo do JSON montado
    If oEvent:oCacheD5B:HasProperty(RTrim(cCodPai))
        aFilhos := oEvent:oCacheD5B[RTrim(cCodPai)]

        For nI := 1 To Len(aFilhos)
            If nPosDel > 0 .And. aFilhos[nI][2][nPosDel] == .T.
                Loop
            EndIf
            cComp       := aFilhos[nI][2][nPosComp]
            cCargoFilho := aFilhos[nI][2][nPosCargo]
            
            soTree:TreeSeek(cCargoPai)
            
            // Se possui item filho, adiciona novo item a arvore e chama recursividade
            // Entrando novamente na pasta para verificar os filhos dela.
            If oEvent:oCacheD5B:HasProperty(RTrim(cComp)) .And. Len(oEvent:oCacheD5B[RTrim(cComp)]) > 0
                soTree:AddItem(RTrim(cComp), cCargoFilho, "FOLDER5", "FOLDER6",,,2)             
                LoadEstr(soTree, cNumSim, cComp, cCargoFilho, oModel)
                soTree:TreeSeek(cCargoFilho)
                soTree:PTCollapse() // Fechando a pasta para replicar comportamento do cadastro estrutura
            Else
                //Se for o ultimo item sem filho, finaliza a iteração e não chama novamente.
                soTree:AddItem(RTrim(cComp), cCargoFilho, "FOLDER5", "FOLDER6",,,2)
            EndIf
        Next nI
    EndIf
Return

//----------------------------------------------------------------------------------
/*/{Protheus.doc} MontaCargo
    Funcao que gera string utilizada como identificado no DBTree da estrutura.
    Padrao: Produto Pai + Produto Filho + Recno + Sequencia iteração + Id. de Estrutura
    @type Function
    @author Squad Entradas
    @since 16/04/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function MontaCargo(cInd, cPai,cComp,nRecno)
	Local cCargo := ""
	Default nRecno := 0

    snSeqTree++

	cCargo := PadR(cPai, TamSX3("D5B_COD")[1]) + ;
	          PadR(cComp, TamSX3("D5B_COMP")[1]) + ;
	          StrZero(nRecno, 9) + ;
	          StrZero(snSeqTree, 9) + ;
	          cInd

Return PadR(cCargo,TamCargo()) //Chamo a função TamCargo() para complementar o PadR

//----------------------------------------------------------------------------------
/*/{Protheus.doc} TamCargo
    Funcao que calcula o tamanho da string do cargo da DBTree
    @type Function
    @author Squad Entradas
    @since 16/04/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function TamCargo()
    // Soma dos tamanhos: PAI + COMPONENTE + 9 (Recno) + 9 (SeqTree) + 4 (cInd)
    Local nTam := GetSx3Cache("D5B_COD" ,"X3_TAMANHO") + ;
	              GetSx3Cache("D5B_COMP","X3_TAMANHO") + ;
	              9 + 9 + 4
Return nTam

//----------------------------------------------------------------------------------
/*/{Protheus.doc} TreeChange
    Funcao que atualiza a grid de componentes da estrutura com base no item 
    selecionado na DBTree.
    @type Function
    @author Squad Entradas
    @since 22/04/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function TreeChange()
    Local oModel      := FWModelActive()
    Local oView       := FWViewActive()
    Local oModelD5B   := oModel:GetModel("D5BDETAIL")
    Local oModelD5C   := oModel:GetModel("D5CDETAIL")
    Local oModelD5D   := oModel:GetModel("D5DDETAIL")
    Local cProdPai    := oModel:GetModel("D5AMASTER"):GetValue("D5A_CODPRO")
    Local cCargo      := ""
    Local cComponent  := ""
    Local nRecnoD5B   := 0
    Local nI          := 0
    Local lTemFilho   := .F.
    Local oEvent      := gtMdlEvent(oModel, "ESTA101EVDEF")
    Local aFilhos     := {}
    Local nPosComp    := 0
    Local nPosDel     := 0
    Local nX          := 0
    Local cPaiCargo   := ""
    Local cDescri     := ""
    Local nPosDesc    := 0
    Local aFieldsD5B  := {}

    If !VldMudanca(oModel)
        Return Nil
    EndIf

    ESTA101Sav(oModel)

    If oModel <> Nil .And. oView <> Nil .And. soTree <> Nil

        cCargo := soTree:GetCargo()

        // Verificação para click duplo na tree
        If cCargo == scCargoAtu
            Return Nil
        EndIf
        
        If !Empty(cCargo)
            scCargoAtu := cCargo // para comparação de click duplo na tree

            cComponent := GetCargoInf(cCargo, "COMP")
            scD5BCdPai := cComponent
            nRecnoD5B  := GetCargoInf(cCargo, "RECNO")
            
            scRotPad := "" // Limpa a variável global

            If nRecnoD5B > 0
                D5B->(DbGoto(nRecnoD5B))
                scRotPad := D5B->D5B_ROTPAD
            EndIf

            oModel:GetModel("NO_MASTER"):LoadValue("CCODPRO" , cComponent)
            // Tratamento para exibir a descrição do produto, caso seja um produto novo simulado
            If cComponent == cProdPai
                oModel:GetModel("NO_MASTER"):LoadValue("CDESCPRO", oModel:GetModel("D5AMASTER"):GetValue("D5A_DESPRO"))
            Else
                cDescri := ""
                cPaiCargo := GetCargoInf(cCargo, "PAI")
                If oEvent != Nil .And. oEvent:oCacheD5B:HasProperty(RTrim(cPaiCargo))
                    aFilhos    := oEvent:oCacheD5B[RTrim(cPaiCargo)]
                    aFieldsD5B := oModelD5B:GetStruct():GetFields()
                    nPosComp   := aScan(aFieldsD5B, {|x| AllTrim(x[3]) == "D5B_COMP"})
                    nPosDesc   := aScan(aFieldsD5B, {|x| AllTrim(x[3]) == "D5B_DESC"})
                    For nX := 1 To Len(aFilhos)
                        If RTrim(aFilhos[nX][2][nPosComp]) == RTrim(cComponent)
                            cDescri := aFilhos[nX][2][nPosDesc]
                            Exit
                        EndIf
                    Next nX
                EndIf
                oModel:GetModel("NO_MASTER"):LoadValue("CDESCPRO", cDescri)
            EndIf
            If cComponent == cProdPai
                // Definir como será filtrado o roteiro padrão do produto pai.
            Else
                oModel:GetModel("NO_MASTER"):LoadValue("CROTEIRO", scRotPad)
            EndIf
            oView:Refresh("VIEW_NO")

            // RECARGA DA D5B
            If oModelD5B <> Nil
                If oModelD5B:CanClearData() // Preteção contra errorlog ao apagar a grid
		           oModelD5B:ClearData(.F.,.F.)
	            EndIf
                oModelD5B:DeActivate()
                oModelD5B:lForceLoad := .T.
                oModelD5B:bLoad := {|| LoadD5B(oModelD5B) }
                oModelD5B:Activate()

                // Verifica se a linha está com flag de detele, para excluir
                // visualmente na tela
                For nI := 1 To oModelD5B:GetQtdLine()
                    oModelD5B:GoLine(nI)
                    If oModelD5B:GetValue("LINDEL") == .T.
                        oModelD5B:DeleteLine()
                    EndIf
                Next nI
                
                lTemFilho := .F.
                
                // Carrega posições das colunas
                nPosComp := aScan(oModelD5B:GetStruct():GetFields(), {|x| AllTrim(x[3]) == "D5B_COMP"})
                nPosDel  := aScan(oModelD5B:GetStruct():GetFields(), {|x| AllTrim(x[3]) == "LINDEL"})
                
                If oEvent != Nil .And. oEvent:oCacheD5B:HasProperty(RTrim(cComponent))
                    aFilhos := oEvent:oCacheD5B[RTrim(cComponent)]
                Else
                    aFilhos := {}
                EndIf

                // Verifica se há filho para o item selecionado, para definir se a grid de operações deve ser habilitada
                For nX := 1 To Len(aFilhos)
                    // Se encontrar qualquer componente preenchido que não esteja deletado, é pai!
                    If !Empty(aFilhos[nX][2][nPosComp]) .And. aFilhos[nX][2][nPosDel] == .F.
                        lTemFilho := .T.
                        Exit
                    EndIf
                Next nX

                //volta para o pai selecionado na tree, para não perder a referência do item selecionado
                If oModelD5B:GetQtdLine() > 0
                    oModelD5B:GoLine(1)
                EndIf
            EndIf

            // RECARGA DA D5C
            If oModelD5C <> Nil
                If oModelD5C:CanClearData() // Preteção contra errorlog ao apagar a grid
		            oModelD5C:ClearData(.F.,.F.)
	            EndIf
                If lTemFilho
                    // Possui filhos abaixo: Trava grid
                    oModelD5C:SetNoInsertLine(.F.)
                    oModelD5C:SetNoUpdateLine(.F.)
                    oModelD5C:SetNoDeleteLine(.F.)
                Else
                    // Materia prima: Libera grid
                    oModelD5C:SetNoInsertLine(.T.)
                    oModelD5C:SetNoUpdateLine(.T.)
                    oModelD5C:SetNoDeleteLine(.T.)
                EndIf
                oModelD5C:DeActivate()
                oModelD5C:lForceLoad := .T.
                oModelD5C:bLoad := {|| LoadD5C(oModelD5C) }
                oModelD5C:Activate()
            EndIf

            // RECARGA DA D5D
            If oModelD5D <> Nil
                If oModelD5D:CanClearData()
		            oModelD5D:ClearData(.F.,.F.)
	            EndIf
                If lTemFilho
                    // Possui Estrutura: Trava grid e impede mudança de campos
                    oModelD5D:SetNoInsertLine(.T.)
                    oModelD5D:SetNoUpdateLine(.T.)
                    oModelD5D:SetNoDeleteLine(.T.)
                    oModelD5D:GetStruct():SetProperty("D5D_TPCUST", MODEL_FIELD_WHEN, {|| .F. })
                    oModelD5D:GetStruct():SetProperty("D5D_CSTFIM", MODEL_FIELD_WHEN, {|| .F. })
                Else
                    // É materia prima: libera a grid e libera alteração do tipo de custo
                    oModelD5D:SetNoInsertLine(.T.)
                    oModelD5D:SetNoUpdateLine(.F.)
                    oModelD5D:SetNoDeleteLine(.T.)
                    oModelD5D:GetStruct():SetProperty("D5D_TPCUST", MODEL_FIELD_WHEN, {|| .T. })
                    oModelD5D:GetStruct():SetProperty("D5D_CSTFIM", MODEL_FIELD_WHEN, {|| VldTpCusto() })
                EndIf
                oModelD5D:DeActivate()
                oModelD5D:lForceLoad := .T.
                oModelD5D:bLoad := {|| LoadD5D(oModelD5D) }
                oModelD5D:Activate()
            EndIf

            oView:Refresh()

        EndIf
    EndIf
Return Nil

//----------------------------------------------------------------------------------
/*/{Protheus.doc} loadCabInv
    Funcao da carga do cabecalho da grid de componentes, trazendo o produto pai dos componentes
    da estrutura.
    @type Function
    @author Squad Entradas
    @since 27/04/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function loadCabInv()
    Local aLoad := {}
    Local aDados := {}

    aDados := { Space(TamSX3("B1_COD")[1]), Space(TamSX3("B1_DESC")[1]), Space(TamSX3("D5C_CODIGO")[1]) } 

    aAdd(aLoad, aDados ) // Dados
    aAdd(aLoad, 0      ) // Recno virtual

Return aLoad

//----------------------------------------------------------------------------------
/*/{Protheus.doc} GetRotPad
    Funcao que busca o código do roteiro padrão do produto, para trazer a descrição do 
    roteiro na inclusão da simulação.
    @type Function
    @author Squad Entradas
    @since 28/04/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function GetRotPad(cProduto)
    Local cRotPad := ""
    Local aArea := GetArea()
    
    DbSelectArea("SB1")
    SB1->(DbSetOrder(1)) // Filial + Produto
    If SB1->(DbSeek(xFilial("SB1") + PadR(cProduto, TamSX3("B1_COD")[1])))
        cRotPad := SB1->B1_OPERPAD
    EndIf

    RestArea(aArea)

Return cRotPad

//----------------------------------------------------------------------------------
/*/{Protheus.doc} LoadD5B
    Funcao que faz a carga dos dados da D5B para a exibição na grid de componentes da estrutura
    @type Function
    @author Squad Entradas
    @since 30/04/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function LoadD5B(oMdlGrid)
    Local aLoad   := {}
    Local cChave  := RTrim(scD5BCdPai)
    Local oModel  := oMdlGrid:GetModel()
    Local oEvent  := gtMdlEvent(oModel, "ESTA101EVDEF")

    If oEvent:oCacheD5B:HasProperty(cChave)
        aLoad := aClone(oEvent:oCacheD5B[cChave])
    EndIf

Return aLoad

//----------------------------------------------------------------------------------
/*/{Protheus.doc} LoadD5C
    Funcao que faz a carga dos dados da D5C para a exibição na grid de operações da estrutura
    @type Function
    @author Squad Entradas
    @since 30/04/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function LoadD5C(oMdlGrid)
    Local aLoad     := {}
    Local aData     := {}
    Local aFields   := oMdlGrid:GetStruct():GetFields()
    Local nPosRot   := aScan(aFields, {|x| AllTrim(x[3]) == "D5C_CODIGO"})
    Local cChave    := RTrim(scD5BCdPai)
    Local nI        := 0
    Local oModel    := oMdlGrid:GetModel()
    Local oEvent    := gtMdlEvent(oModel, "ESTA101EVDEF")

    If Empty(cChave) .Or. oEvent:oCacheD5C == Nil .Or. !oEvent:oCacheD5C:HasProperty(cChave)
        Return aLoad
    EndIf

    aData := oEvent:oCacheD5C[cChave]

    If Empty(scRotPad)
        aLoad := aClone(aData)
    Else
        For nI := 1 To Len(aData)
            If Rtrim(aData[nI][2][nPosRot]) == Rtrim(scRotPad)
                AAdd(aLoad, aClone(aData[nI]))
            EndIf
        Next nI
    EndIf

Return aLoad

//----------------------------------------------------------------------------------
/*/{Protheus.doc} GetCargoInf
    Funcao que retorna informacoes específicas do cargo da DBTree, como o 
    produto pai, componente, recno e index da estrutura.
    @type Function
    @author Squad Entradas
    @since 30/04/2026
    @version 12.1.2510
    @param  cCargo - String do cargo selecionado na arvore
    @param  cInfo  - Qual informacao deseja extrair:
                        "PAI"    - Produto Pai
                        "COMP"   - Componente (Produto Filho)
                        "RECNO"  - Recno do registro na D5B para o componente
                        "INDEX"  - Index / Sequência da Árvore
                        "IND"    - Indicador se é estrutura ou roteiro
    @return  xRet  - Informacao extraída do cargo conforme o cInfo solicitado
/*/
//----------------------------------------------------------------------------------
Static Function GetCargoInf(cCargo, cInfo)
    Local xRet     := ""
    Local nStart   := 0
    Local nTamanho := 0
    
    Default cInfo := "PAI"

	If cInfo == "PAI"
		//Pai
		xRet := Left(cCargo, GetSx3Cache("G1_COD","X3_TAMANHO"))
    ElseIf cInfo == "COMP"
        // Componente - C
        nStart   := TamSX3("D5B_COD")[1] + 1
        nTamanho := TamSX3("D5B_COMP")[1]
        xRet := SubStr(cCargo, nStart, nTamanho)
    ElseIf cInfo == "RECNO"
        // Recno - N
        nStart   := TamSX3("D5B_COD")[1] + TamSX3("D5B_COMP")[1] + 1
        nTamanho := 9
        xRet := Val(SubStr(cCargo, nStart, nTamanho))
    EndIf
    
Return xRet

//----------------------------------------------------------------------------------
/*/{Protheus.doc} AfterView
    Funcao chamada após a ativação da view.
    Utilizado para montar a estrutura da árvore do produto pai da simulação e carregar as 
    grids de operações e componentes.
    @type Function
    @author Squad Entradas
    @since 06/04/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function AfterView(oView)
    Local oModel    := oView:GetModel()
    Local cNumSim   := oModel:GetModel("D5AMASTER"):GetValue("D5A_NUM")
    Local cProdPai  := oModel:GetModel("D5AMASTER"):GetValue("D5A_CODPRO")
    Local cCargo    := ""

    // Inicializa as varoaveis globais para evitar sujeira entre registros
    scD5BCdPai := ""
    scCargoAtu := ""
    scRotPad   := ""

    MontaCache(cNumSim, oModel)

    // Monta a arvore de estrutura do produto pai da simulação
    If soTree <> Nil
        snSeqTree := 0
        cCargo := AdicPai(cNumSim, cProdPai)

        soTree:BeginUpdate()
        soTree:AddTree(cProdPai, .T., "FOLDER5", "FOLDER6", , , cCargo)
        LoadEstr(soTree, cNumSim, cProdPai, cCargo, oModel)
        soTree:EndUpdate()

        // Posiciona no item pai e chama a TreeChange() para carragar a grid
        soTree:TreeSeek(cCargo)
        TreeChange()
        soTree:Refresh()
    EndIf

    oView:Refresh()

    ESTA101Pnl(.T.)

Return Nil

//----------------------------------------------------------------------------------
/*/{Protheus.doc} ESTA101ROT
    Funcao acionada na alteração do roteiro padrão na tela de operações, para atualizar
    a grid conforme o codigo do roteiro selecionado.
    @type Function
    @author Squad Entradas
    @since 06/04/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Function ESTA101ROT()
    Local oModel      := FWModelActive()
    Local oView       := FWViewActive()
    Local oModelNo  := oModel:GetModel("NO_MASTER")
    Local oModelD5C   := oModel:GetModel("D5CDETAIL")
    Local cNewRot     := oModelNo:GetValue("CROTEIRO")

    scRotPad := cNewRot

    If oModelD5C <> Nil .And. oView <> Nil
        oModelD5C:ClearData(.F., .F.)
        
        oModelD5C:DeActivate()
        oModelD5C:lForceLoad := .T.
        oModelD5C:bLoad := {|| LoadD5C(oModelD5C) }
        oModelD5C:Activate()

        oView:Refresh("VIEW_D5C")
    EndIf

Return .T.

//----------------------------------------------------------------------------------
/*/{Protheus.doc} ESTA101D5C
    Funcao chamada no F3 da grid de operações do produto, para retornar o filtro de 
    roteiros disponiveis para seleção.
    @type Function
    @author Squad Entradas
    @since 06/04/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Function ESTA101D5C(cSimulaDB, cProdDB)
    Local oModel     := FWModelActive()
    Local cSimulaMVC := ""
    Local cProdMVC   := ""

    If oModel <> Nil .And. oModel:GetModel("D5AMASTER") <> Nil
        cSimulaMVC := oModel:GetModel("D5AMASTER"):GetValue("D5A_NUM")
        cProdMVC   := oModel:GetModel("NO_MASTER"):GetValue("CCODPRO")
    EndIf

Return (RTrim(cSimulaDB) == RTrim(cSimulaMVC) .And. RTrim(cProdDB) == RTrim(cProdMVC))

//----------------------------------------------------------------------------------
/*/{Protheus.doc} ESTA101Com
    Funcao de validação da linha da grid de componente, que preenche a descrição do componente 
    na inclusão da linha da grid, validando se o produto existe na SB1 e preenchendo o cod. da 
    simulação e o código do produto pai.
    @type Function
    @author Squad Entradas
    @since 06/04/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Function ESTA101Com()
    Local lRet      := .T.
    Local oModel    := FWModelActive()
    Local oMdlD5B   := oModel:GetModel("D5BDETAIL")
    Local cComp     := oMdlD5B:GetValue("D5B_COMP")
    Local cCenario  := oModel:GetModel("D5AMASTER"):GetValue("D5A_CODCEN")
    Local lCenario  := !Empty(cCenario)
    Local cTpCust   := oModel:GetModel("D5AMASTER"):GetValue("D5A_TPCUST")
    Local aArea     := GetArea()
    Local cSimula   := ""
    Local lAchou    := .F.
    Local cDescri   := ""
    Local oEvent    := gtMdlEvent(oModel, "ESTA101EVDEF")
    Local aFieldsD  := oModel:GetModel("D5DDETAIL"):GetStruct():GetFields()
    Local nCstBase  := 0
    Local nInd      := 0

    If !Empty(cComp)

        // Validação de recursividade
        If ChkRecursi(cComp, scD5BCdPai, oModel, cCenario)
            Help(,,"Help",,STR0073 + RTrim(cComp) + STR0074,; // "O componente " " já faz parte da estrutura."
             1, 0,,,,,,{STR0075}) // "Selecione outro componente para a estrutura."
            Return .F.
        EndIf

        // Localizar componente na D53
        If lCenario
            DbSelectArea("D53")
            D53->(DbSetOrder(2)) // D53_FILIAL + D53_CODCEN + D53_COD
            If D53->(DbSeek(xFilial("D53") + PadR(cCenario, TamSx3("D53_CODCEN")[1]) + PadR(cComp, TamSx3("D53_COD")[1])))
                lAchou  := .T.
                cDescri := D53->D53_DESC
            EndIf
        EndIf
        // Localizar componente na SB1
        If !lCenario
            DbSelectArea("SB1")
            SB1->(DbSetOrder(1)) // B1_FILIAL + B1_COD
            If SB1->(DbSeek(xFilial("SB1") + PadR(cComp, TamSx3("B1_COD")[1])))
                lAchou  := .T.
                cDescri := SB1->B1_DESC
            EndIf
        EndIf

        cSimula := oModel:GetModel("D5AMASTER"):GetValue("D5A_NUM")
        oMdlD5B:LoadValue("D5B_SIMULA", cSimula)
        oMdlD5B:LoadValue("D5B_COD"   , scD5BCdPai)
        oMdlD5B:LoadValue("D5B_TPCUST", cTpCust)
        oMdlD5B:LoadValue("D5B_TPCUST", cTpCust)

        If lAchou //Encontrou registro do produto, atribui descrição
            oMdlD5B:LoadValue("D5B_DESC", cDescri)
            nCstBase := GetCusto(cCenario, cComp, cTpCust)
        Else
            // busca descricao de produto inedito se ja existir na grid
            cDescri := ""
            For nInd := 1 To oMdlD5B:GetQtdLine()
                // Ignora a linha atual em edição e as linhas deletadas
                If nInd != oMdlD5B:GetLine() .And. !oMdlD5B:IsDeleted(nInd)
                    If RTrim(oMdlD5B:GetValue("D5B_COMP", nInd)) == RTrim(cComp)
                        cDescri := oMdlD5B:GetValue("D5B_DESC", nInd)
                        If !Empty(cDescri)
                            Exit
                        EndIf
                    EndIf
                EndIf
            Next nInd

            oMdlD5B:LoadValue("D5B_DESC", cDescri)
            nCstBase := 0
        EndIf

        //Tratamento para TRT do componente no mesmo nivel da estutura
        If Empty(oMdlD5B:GetValue("D5B_TRT"))
            oMdlD5B:LoadValue("D5B_TRT", ProximoTrt(oMdlD5B, cComp))
        EndIf

        // Tratamento para inclusao de linha de operacao caso nao exista
        If !oEvent:oCacheD5C:HasProperty(RTrim(cComp))
            oEvent:oCacheD5C[Rtrim(cComp)] := {}
        EndIf

        //Tratamento para inclusao de linha de custo caso nao exista
        If oEvent != Nil .And. !oEvent:oCacheD5D:HasProperty(RTrim(cComp))
            CriaLinCus(oEvent, aFieldsD, cComp, cCenario, cSimula, cTpCust, nCstBase)
        EndIf

    EndIf

    RestArea(aArea)

Return lRet

//----------------------------------------------------------------------------------
/*/{Protheus.doc} MontaCache
    Funcao que realiza a carga dos dados da D5B, D5C e D5D para objetos Json, utilizando
    como chave o produto pai da estrutura.
    @type Function
    @author Squad Entradas
    @since 08/05/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function MontaCache(cNumSim, oModel)
    Local aAreaD5B := D5B->(GetArea())
    Local aAreaD5C := D5C->(GetArea())
    Local aAreaD5D := D5D->(GetArea())
    Local aFieldsB := oModel:GetModel("D5BDETAIL"):GetStruct():GetFields()
    Local aFieldsC := oModel:GetModel("D5CDETAIL"):GetStruct():GetFields()
    Local aFieldsD := oModel:GetModel("D5DDETAIL"):GetStruct():GetFields()
    Local aLinha   := {}
    Local nI       := 0
    Local cCampo   := ""
    Local cPaiAtu  := ""
    Local cProdPai := RTrim(oModel:GetModel("D5AMASTER"):GetValue("D5A_CODPRO"))
    Local cCenario := oModel:GetModel("D5AMASTER"):GetValue("D5A_CODCEN")
    Local cTpCust  := oModel:GetModel("D5AMASTER"):GetValue("D5A_TPCUST")
    Local oEvent   := gtMdlEvent(oModel, "ESTA101EVDEF")

    oEvent:oCacheD5B := JsonObject():New()
    oEvent:oCacheD5C := JsonObject():New()
    oEvent:oCacheD5D := JsonObject():New()

    // Carga da grid D5B - Componentes
    DbSelectArea("D5B")
    D5B->(DbSetOrder(2)) // D5B_FILIAL + D5B_SIMULA + D5B_COD
    If D5B->(DbSeek(xFilial("D5B") + PadR(cNumSim, TamSX3("D5B_SIMULA")[1])))
        While !D5B->(Eof()) .And. D5B->D5B_SIMULA == cNumSim
            cPaiAtu := RTrim(D5B->D5B_COD)

            If !oEvent:oCacheD5B:HasProperty(cPaiAtu)
                oEvent:oCacheD5B[cPaiAtu] := {}
            EndIf

            aLinha := Array(Len(aFieldsB))
            For nI := 1 To Len(aFieldsB)
                cCampo := AllTrim(aFieldsB[nI][3])
                If aFieldsB[nI][14] == .F.
                    aLinha[nI] := D5B->&(cCampo)
                Else
                    If cCampo == "D5B_DESC"
                        aLinha[nI] := Posicione("SB1", 1, xFilial("SB1") + D5B->D5B_COMP, "B1_DESC")
                    ElseIf cCampo == "LINDEL"
                        aLinha[nI] := .F.
                    ElseIf cCampo == "CARGO" 
                        aLinha[nI] := MontaCargo(IND_ESTR, cPaiAtu, D5B->D5B_COMP, D5B->(Recno()))
                    ElseIf cCampo == "NREG"
                        aLinha[nI] := D5B->(Recno())
                    EndIf
                EndIf
            Next nI

            AAdd(oEvent:oCacheD5B[cPaiAtu], {0, aClone(aLinha)})
            
            D5B->(DbSkip())
        EndDo
    EndIf

    // Carga da grid D5C - Operações
    DbSelectArea("D5C")
    D5C->(DbSetOrder(2)) // D5C_FILIAL + D5C_SIMULA + D5C_PRODUT
    If D5C->(DbSeek(xFilial("D5C") + PadR(cNumSim, TamSX3("D5C_SIMULA")[1])))
        While !D5C->(Eof()) .And. D5C->D5C_SIMULA == cNumSim
            cPaiAtu := Rtrim(D5C->D5C_PRODUT)

            If !oEvent:oCacheD5C:HasProperty(cPaiAtu)
                oEvent:oCacheD5C[cPaiAtu] := {}
            EndIf

            aLinha := Array(Len(aFieldsC))
            For nI := 1 To Len(aFieldsC)
                cCampo := AllTrim(aFieldsC[nI][3])
                If aFieldsC[nI][14] == .F.
                    aLinha[nI] := D5C->&(cCampo)
                Else
                    If cCampo == "LINDEL"
                        aLinha[nI] := .F.
                    ElseIf cCampo == "NREG"
                        aLinha[nI] := D5C->(Recno())
                    EndIf
                EndIf
            Next nI

            AAdd(oEvent:oCacheD5C[cPaiAtu], {0, aClone(aLinha)})

            D5C->(DbSkip())
        EndDo
    EndIf

    // Carga da grid D5D - Composição do Custo
    DbSelectArea("D5D")
    D5D->(DbSetOrder(1))
    If D5D->(DbSeek(xFilial("D5D") + PadR(cNumSim, TamSX3("D5D_SIMULA")[1])))
        While !D5D->(Eof()) .And. D5D->D5D_SIMULA == cNumSim
            cPaiAtu := Rtrim(D5D->D5D_COD)
            If !oEvent:oCacheD5D:HasProperty(cPaiAtu)
                oEvent:oCacheD5D[cPaiAtu] := {}
            EndIf
            
            aLinha := Array(Len(aFieldsD))
            For nI := 1 To Len(aFieldsD)
                cCampo := AllTrim(aFieldsD[nI][3])
                If aFieldsD[nI][14] == .F.
                    aLinha[nI] := D5D->&(cCampo)
                Else
                    If cCampo == "LINDEL"
                        aLinha[nI] := .F.
                    ElseIf cCampo == "NREG"
                        aLinha[nI] := D5D->(Recno())
                    EndIf
                EndIf
            Next nI
            AAdd(oEvent:oCacheD5D[cPaiAtu], {0, aClone(aLinha)})
            D5D->(DbSkip())
        EndDo
    EndIf

    // Tratamento para produto pai que não possui custo da D5D
    If !oEvent:oCacheD5D:HasProperty(cProdPai) .Or. Len(oEvent:oCacheD5D[cProdPai]) == 0
        oEvent:oCacheD5D[cProdPai] := {}
        
        aLinha := Array(Len(aFieldsD))
        For nI := 1 To Len(aFieldsD)
            cCampo := AllTrim(aFieldsD[nI][3])
            Do Case
                Case cCampo == "D5D_FILIAL"; aLinha[nI] := FWxFilial("D5D")
                Case cCampo == "D5D_SIMULA"; aLinha[nI] := cNumSim
                Case cCampo == "D5D_CODCEN"; aLinha[nI] := cCenario
                Case cCampo == "D5D_COD"   ; aLinha[nI] := cProdPai
                Case cCampo == "D5D_TPCUST"; aLinha[nI] := cTpCust
                Case cCampo == "D5D_CSTCOM"; aLinha[nI] := 0
                Case cCampo == "D5D_CSTFIM"; aLinha[nI] := 0
                Case cCampo == "LINDEL"    ; aLinha[nI] := .F.
                Case cCampo == "NREG"      ; aLinha[nI] := 0
            EndCase
        Next nI

        AAdd(oEvent:oCacheD5D[cProdPai], {0, aClone(aLinha)})
    EndIf

    RestArea(aAreaD5B)
    RestArea(aAreaD5C)
    RestArea(aAreaD5D)
Return

//----------------------------------------------------------------------------------
/*/{Protheus.doc} ESTA101Sav
    Funcao que recria o JSON conforme as alterações da grid.
    @type Function
    @author Squad Entradas
    @since 08/05/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Function ESTA101Sav(oModel)
    Local oMdlD5B  := oModel:GetModel("D5BDETAIL")
    Local oMdlD5C  := oModel:GetModel("D5CDETAIL")
    Local oMdlD5D  := oModel:GetModel("D5DDETAIL")
    Local oEvent   := gtMdlEvent(oModel, "ESTA101EVDEF")
    Local cPaiAtu  := Rtrim(scD5BCdPai)

    // D5B
    Local aFieldsB := {}
    Local nPosDelB := 0
    Local nLineAtuB:= 0
    Local cComp    := ""

    // D5C
    Local aFieldsC := {}
    Local nPosDelC := 0
    Local nLineAtuC:= 0
    Local cOperac  := ""

    // D5D
    Local aFieldsD := {}
    Local nPosDelD := 0
    Local nLineAtuD:= 0

    Local nI       := 0
    Local nJ       := 0
    Local aLinha   := {}

    If Empty(cPaiAtu)
        Return
    EndIf

    If oMdlD5B != Nil
        aFieldsB  := oMdlD5B:GetStruct():GetFields()
        nPosDelB  := aScan(aFieldsB, {|x| AllTrim(x[3]) == "LINDEL"})
        nLineAtuB := oMdlD5B:GetLine()
    EndIf

    If oMdlD5C != Nil
        aFieldsC  := oMdlD5C:GetStruct():GetFields()
        nPosDelC  := aScan(aFieldsC, {|x| AllTrim(x[3]) == "LINDEL"})
        nLineAtuC := oMdlD5C:GetLine()
    EndIf

    If oMdlD5D != Nil
        aFieldsD  := oMdlD5D:GetStruct():GetFields()
        nPosDelD  := aScan(aFieldsD, {|x| AllTrim(x[3]) == "LINDEL"})
        nLineAtuD := oMdlD5D:GetLine()
    EndIf

    // D5B - COMPONENTES
    If oMdlD5B != Nil
        oEvent:oCacheD5B[cPaiAtu] := {}

        For nI := 1 To oMdlD5B:GetQtdLine()
            oMdlD5B:GoLine(nI) 
            cComp := oMdlD5B:GetValue("D5B_COMP")

            If Empty(cComp) .And. !oMdlD5B:IsDeleted()
                Loop
            EndIf

            aLinha := Array(Len(aFieldsB))

            For nJ := 1 To Len(aFieldsB)
                aLinha[nJ] := oMdlD5B:GetValue(aFieldsB[nJ][3]) 
            Next nJ

            If nPosDelB > 0
                aLinha[nPosDelB] := oMdlD5B:IsDeleted()
            EndIf

            AAdd(oEvent:oCacheD5B[cPaiAtu], {0, aClone(aLinha)})
        Next nI

        If nLineAtuB > 0
            oMdlD5B:GoLine(nLineAtuB)
        EndIf
    EndIf

    // D5C - OPERAÇÕES
    If oMdlD5C != Nil
        oEvent:oCacheD5C[cPaiAtu] := {}

        For nI := 1 To oMdlD5C:GetQtdLine()
            oMdlD5C:GoLine(nI) 
            cOperac := oMdlD5C:GetValue("D5C_OPERAC")

            If Empty(cOperac) .And. !oMdlD5C:IsDeleted()
                Loop
            EndIf

            aLinha := Array(Len(aFieldsC))

            For nJ := 1 To Len(aFieldsC)
                aLinha[nJ] := oMdlD5C:GetValue(aFieldsC[nJ][3]) 
            Next nJ

            If nPosDelC > 0
                aLinha[nPosDelC] := oMdlD5C:IsDeleted()
            EndIf

            AAdd(oEvent:oCacheD5C[cPaiAtu], {0, aClone(aLinha)})
        Next nI

        If nLineAtuC > 0
            oMdlD5C:GoLine(nLineAtuC)
        EndIf
    EndIf

    // D5D - COMPOSIÇÃO DO CUSTO
    If oMdlD5D != Nil
        oEvent:oCacheD5D[cPaiAtu] := {}
        For nI := 1 To oMdlD5D:GetQtdLine()
            oMdlD5D:GoLine(nI) 
            
            If Empty(oMdlD5D:GetValue("D5D_TPCUST"))
                Loop
            EndIf

            aLinha := Array(Len(aFieldsD))
            For nJ := 1 To Len(aFieldsD)
                aLinha[nJ] := oMdlD5D:GetValue(aFieldsD[nJ][3]) 
            Next nJ

            If nPosDelD > 0
                aLinha[nPosDelD] := oMdlD5D:IsDeleted()
            EndIf

            AAdd(oEvent:oCacheD5D[cPaiAtu], {0, aClone(aLinha)})
        Next nI
        If nLineAtuD > 0
            oMdlD5D:GoLine(nLineAtuD)
        EndIf
    EndIf

Return

//----------------------------------------------------------------------------------
/*/{Protheus.doc} gtMdlEvent
    Recupera a referência do objeto dos Eventos do modelo.
    @type Function
    @author Squad Entradas
    @since 14/05/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function gtMdlEvent(oModel, cIdEvent)
    Local nIndex  := 0
    Local oEvent  := Nil
    Local oMdlPai := Nil

    If oModel != Nil
        oMdlPai := oModel:GetModel()
    EndIf

    If oMdlPai != Nil .And. AttIsMemberOf(oMdlPai, "oEventHandler", .T.) .And. oMdlPai:oEventHandler != NIL
        For nIndex := 1 To Len(oMdlPai:oEventHandler:aEvents)
            If oMdlPai:oEventHandler:aEvents[nIndex]:cIdEvent == cIdEvent
                oEvent := oMdlPai:oEventHandler:aEvents[nIndex]
                Exit
            EndIf
        Next nIndex
    EndIf
Return oEvent

//----------------------------------------------------------------------------------
/*/{Protheus.doc} ESTA101Del
    Funcao para deletar o nó selecionado na DBTree, atualizando a estrutura e a 
    grid de componentes.
    @type Function
    @author Squad Entradas
    @since 14/05/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Function ESTA101Del(cCargo, oModel, cComp)
    Local cCargoAtu  := ""
    Local oEvent     := Nil
    Local aFieldsD5C := {}
    Local aFieldsD5D := {}
    Local aFieldsD5B := {}
    Local nPosDelC   := 0
    Local nPosDelD   := 0
    Local nPosDelB   := 0
    Local nPosCompB  := 0
    Local nI         := 0

    // Exclusão visual na DBTree
    If soTree <> Nil .And. !Empty(cCargo)
        cCargoAtu := soTree:GetCargo() 
        If soTree:TreeSeek(cCargo)
            soTree:DelItem()
            soTree:Refresh()
        EndIf
        If !Empty(cCargoAtu) .And. cCargoAtu != cCargo 
            soTree:TreeSeek(cCargoAtu)
        EndIf
    EndIf

    // Manipulação recursiva do Cache
    If oModel != Nil .And. !Empty(cComp)
        oEvent := gtMdlEvent(oModel, "ESTA101EVDEF")

        // Marca exclusão na D5D
        If oEvent:oCacheD5D:HasProperty(RTrim(cComp))
            aFieldsD5D := oModel:GetModel("D5DDETAIL"):GetStruct():GetFields()
            nPosDelD   := aScan(aFieldsD5D, {|x| AllTrim(x[3]) == "LINDEL"})
            For nI := 1 To Len(oEvent:oCacheD5D[RTrim(cComp)])
                oEvent:oCacheD5D[RTrim(cComp)][nI][2][nPosDelD] := .T.
            Next nI
        EndIf
        // Marca exclusão na D5C
        If oEvent:oCacheD5C:HasProperty(RTrim(cComp))
            aFieldsD5C := oModel:GetModel("D5CDETAIL"):GetStruct():GetFields()
            nPosDelC   := aScan(aFieldsD5C, {|x| AllTrim(x[3]) == "LINDEL"})
            For nI := 1 To Len(oEvent:oCacheD5C[RTrim(cComp)])
                oEvent:oCacheD5C[RTrim(cComp)][nI][2][nPosDelC] := .T.
            Next nI
        EndIf

        // Marca exclusão nos Componentes Filhos (D5B) e chama a recursividade
        If oEvent:oCacheD5B:HasProperty(RTrim(cComp))
            aFieldsD5B := oModel:GetModel("D5BDETAIL"):GetStruct():GetFields()
            nPosDelB   := aScan(aFieldsD5B, {|x| AllTrim(x[3]) == "LINDEL"})
            nPosCompB  := aScan(aFieldsD5B, {|x| AllTrim(x[3]) == "D5B_COMP"})

            For nI := 1 To Len(oEvent:oCacheD5B[RTrim(cComp)])
                oEvent:oCacheD5B[RTrim(cComp)][nI][2][nPosDelB] := .T.
                // Recursividade (Não envia cCargo para não tentar excluir da árvore novamente)
                ESTA101Del("", oModel, oEvent:oCacheD5B[RTrim(cComp)][nI][2][nPosCompB])
            Next nI
        EndIf
    EndIf
Return Nil

//----------------------------------------------------------------------------------
/*/{Protheus.doc} ESTA101Add
    Funcao para adicionar um nó na DBTree, atualizando a estrutura e a grid de componentes.
    @type Function
    @author Squad Entradas
    @since 14/05/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Function ESTA101Add(cComp, cCargo, oModel)
    Local oEvent     := Nil
    Local aFieldsD5C := {}
    Local aFieldsD5D := {}
    Local aFieldsD5B := {}
    Local nPosDelC   := 0
    Local nPosDelD   := 0
    Local nPosDelB   := 0
    Local nPosCompB  := 0
    Local nI         := 0

    // Manipulação recursiva do Cache
    If oModel != Nil .And. !Empty(cComp)
        oEvent := gtMdlEvent(oModel, "ESTA101EVDEF")

        // Restaura D5D
        If oEvent:oCacheD5D:HasProperty(RTrim(cComp))
            aFieldsD5D := oModel:GetModel("D5DDETAIL"):GetStruct():GetFields()
            nPosDelD   := aScan(aFieldsD5D, {|x| AllTrim(x[3]) == "LINDEL"})
            For nI := 1 To Len(oEvent:oCacheD5D[RTrim(cComp)])
                oEvent:oCacheD5D[RTrim(cComp)][nI][2][nPosDelD] := .F.
            Next nI
        EndIf
        // Restaura D5C
        If oEvent:oCacheD5C:HasProperty(RTrim(cComp))
            aFieldsD5C := oModel:GetModel("D5CDETAIL"):GetStruct():GetFields()
            nPosDelC   := aScan(aFieldsD5C, {|x| AllTrim(x[3]) == "LINDEL"})
            For nI := 1 To Len(oEvent:oCacheD5C[RTrim(cComp)])
                oEvent:oCacheD5C[RTrim(cComp)][nI][2][nPosDelC] := .F.
            Next nI
        EndIf

        // Restaura Componentes Filhos (D5B) e chama a recursividade
        If oEvent:oCacheD5B:HasProperty(RTrim(cComp))
            aFieldsD5B := oModel:GetModel("D5BDETAIL"):GetStruct():GetFields()
            nPosDelB   := aScan(aFieldsD5B, {|x| AllTrim(x[3]) == "LINDEL"})
            nPosCompB  := aScan(aFieldsD5B, {|x| AllTrim(x[3]) == "D5B_COMP"})

            For nI := 1 To Len(oEvent:oCacheD5B[RTrim(cComp)])
                oEvent:oCacheD5B[RTrim(cComp)][nI][2][nPosDelB] := .F.
                // Recursividade
                ESTA101Add(oEvent:oCacheD5B[RTrim(cComp)][nI][2][nPosCompB], "", oModel)
            Next nI
        EndIf
    EndIf

    // Inclusão visual na DBTree e dos filhos
    If soTree <> Nil .And. !Empty(cComp) .And. !Empty(cCargo)
        If !soTree:TreeSeek(cCargo)
            soTree:TreeSeek(scCargoAtu) 
            soTree:AddItem(Rtrim(cComp), cCargo, "FOLDER5", "FOLDER6",,, 2)
            
            // Se foi restaurado, recarrega a estrutura visual filha na árvore
            If oModel != Nil
                LoadEstr(soTree, oModel:GetModel("D5AMASTER"):GetValue("D5A_NUM"), cComp, cCargo, oModel)
            EndIf
            soTree:Refresh()
        EndIf
    EndIf
Return Nil

//----------------------------------------------------------------------------------
/*/{Protheus.doc} ESTA101Upd
    Funcao para atualizar a árvore de componentes na DBTree, adicionando novos nós 
    conforme são adicionados na grid de componentes.
    @type Function
    @author Squad Entradas
    @since 14/05/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Function ESTA101Upd(oMdlD5B)
    Local cComp     := oMdlD5B:GetValue("D5B_COMP")
    Local cNewCargo := oMdlD5B:GetValue("CARGO")
    Local oModel    := FWModelActive()

    If !Empty(cComp) .And. soTree <> Nil .And. oMdlD5B:IsInserted()
        // Se ainda não gerou o cargo, gera e carrega no campo virtual CARGO
        If Empty(cNewCargo)
            cNewCargo := MontaCargo(IND_ESTR, scD5BCdPai, cComp, 0)
            oMdlD5B:LoadValue("CARGO", cNewCargo)
        EndIf

        If !soTree:TreeSeek(cNewCargo)
            soTree:TreeSeek(scCargoAtu) // Volta o para o pai para adicionar
            soTree:AddItem(Rtrim(cComp), cNewCargo, "FOLDER5", "FOLDER6",,, 2)
            soTree:Refresh()
        EndIf
    EndIf
    ESTA101Niv(oModel) //Chama o recalculo de niveis
Return Nil

//----------------------------------------------------------------------------------
/*/{Protheus.doc} VldFolder
    Funcao chamada na validação de troca de aba do folder.
    @type Function
    @author Squad Entradas
    @since 22/05/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function VldFolder(cFolderID, nOldSheet, nSelSheet)
    Local oModel      := FWModelActive()

Return VldMudanca(oModel)

//----------------------------------------------------------------------------------
/*/{Protheus.doc} VldMudanca
    Funcao de validação de troca de item da DBTree, para validar se existem alterações não salvas
    @type Function
    @author Squad Entradas
    @since 22/05/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function VldMudanca(oModel)

    // Tratamento de errorlog DENTRINO_CAPEX-595
    // Libera a mudança de aba/item se for visualização
    If oModel:GetOperation() != MODEL_OPERATION_INSERT .Or. oModel:GetOperation() != MODEL_OPERATION_UPDATE
        Return .T.
    EndIf

    If !oModel:VldData()
        If soTree <> Nil .And. !Empty(scCargoAtu)
            soTree:TreeSeek(scCargoAtu) 
            Help(,,'Help',,STR0046,; // "Há alterações que não foram salvas."
                 1,0,,,,,,{STR0047})  // "Salve as alterações antes de trocar de item da estrutura."
            Return .F.
        EndIf
    EndIf

Return .T.

//----------------------------------------------------------------------------------
/*/{Protheus.doc} VldD5COper
    Funcao de validacao da linha da grid de operações
    @type Function
    @author Squad Entradas
    @since 29/05/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function VldD5COper()
    Local lRet       := .T.
    Local oModel     := FWModelActive()
    Local oMdlD5C    := oModel:GetModel("D5CDETAIL")
    Local cOperac    := oMdlD5C:GetValue("D5C_OPERAC")
    Local aArea      := GetArea()
    Local cSimula    := ""
    Local nLinhaAtu  := oMdlD5C:GetLine()
    Local cCodRot    := GetCodRot(oModel, nLinhaAtu)

    If !Empty(cOperac)
        DbSelectArea("SVI")
        SVI->(DbSetOrder(1)) // Filial + Codigo de Operação
        
        If SVI->(DbSeek(xFilial("SVI") + cOperac))

            cSimula := oModel:GetModel("D5AMASTER"):GetValue("D5A_NUM")

            oMdlD5C:LoadValue("D5C_PRODUT"  , scD5BCdPai)
            oMdlD5C:LoadValue("D5C_DESCRI"  , SVI->VI_DESCRI)
            oMdlD5C:LoadValue("D5C_SIMULA"  , cSimula)
            oMdlD5C:LoadValue("D5C_CODIGO"  , cCodRot)

        Else
            Help(,,'Help',,STR0056 + cOperac + STR0057,; // "Operação " " não encontrada." 
                 1,0,,,,,,{STR0058}) // "Verifique a operação informada."
            lRet := .F.
        EndIf
    EndIf

    RestArea(aArea)
Return lRet

//----------------------------------------------------------------------------------
/*/{Protheus.doc} GetCodRot
    Funcao que sugere o código do roteiro para a operação, buscando 
    o código do roteiro da linha anterior na grid
    @type Function
    @author Squad Entradas
    @since 29/05/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function GetCodRot(oModel, nLinhaAtu)
    Local oMdlD5C    := oModel:GetModel("D5CDETAIL")
    Local cRotSugeri := ""

    If !Empty(scRotPad) // Se o roteiro padrão estiver definido
        Return scRotPad
    EndIf

    If nLinhaAtu > 1 // Olha para a linha de cima para tentar sugerir um codigo
        oMdlD5C:GoLine(nLinhaAtu - 1)
        If !oMdlD5C:IsDeleted()
            cRotSugeri := oMdlD5C:GetValue("D5C_CODIGO")
        EndIf
        oMdlD5C:GoLine(nLinhaAtu)
    EndIf

    If Empty(cRotSugeri) // Se não conseguir sugerir, atribui codigo = 01
        cRotSugeri := "01"
    EndIf

Return cRotSugeri

//----------------------------------------------------------------------------------
/*/{Protheus.doc} LoadD5D
    Funcao que faz a carga dos dados da D5D para a exibição na grid composicao do custo
    @type Function
    @author Squad Entradas
    @since 03/06/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function LoadD5D(oMdlGrid)
    Local aLoad   := {}
    Local cChave  := Rtrim(scD5BCdPai)
    Local oModel  := oMdlGrid:GetModel()
    Local oEvent  := gtMdlEvent(oModel, "ESTA101EVDEF")

    If oEvent:oCacheD5D != Nil .And. oEvent:oCacheD5D:HasProperty(cChave)
        aLoad := aClone(oEvent:oCacheD5D[cChave])
    EndIf
Return aLoad

//----------------------------------------------------------------------------------
/*/{Protheus.doc} VldD5DCust
    Funcao de validacao da linha da grid de composicao do custo
    @type Function
    @author Squad Entradas
    @since 03/06/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function VldD5DCust()
    Local lRet      := .T.
    Local oModel    := FWModelActive()
    Local oMdlD5D   := oModel:GetModel("D5DDETAIL")
    Local cTpCust   := oMdlD5D:GetValue("D5D_TPCUST")
    Local cCenario  := oModel:GetModel("D5AMASTER"):GetValue("D5A_CODCEN")
    Local cSimula   := oModel:GetModel("D5AMASTER"):GetValue("D5A_NUM")
    Local cProduto  := scD5BCdPai
    Local nCstCom   := 0

    If !Empty(cTpCust) .And. !Empty(cProduto)

        If cTpCust != "8" // tratamento para custo manual não zerar o custo
            nCstCom := GetCusto(cCenario, cProduto, cTpCust)
            oMdlD5D:LoadValue("D5D_CSTCOM", nCstCom)
            oMdlD5D:LoadValue("D5D_CSTFIM", nCstCom)
        Else // caso seja manual, zera o custo final para ser preenchido
            oMdlD5D:LoadValue("D5D_CSTFIM", 0)
        EndIf

        oMdlD5D:LoadValue("D5D_SIMULA", cSimula)
        oMdlD5D:LoadValue("D5D_COD", cProduto)
        If !Empty(cCenario) // Se houver cenário, carrega na grid
            oMdlD5D:LoadValue("D5D_CODCEN", cCenario)
        EndIf

    EndIf

Return lRet

//----------------------------------------------------------------------------------
/*/{Protheus.doc} GetCusto
    Funcao genérica para retorno do custo do produto
    @type Function
    @author Squad Entradas
    @since 03/06/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function GetCusto(cCenario, cProduto, cCusto)
    Local nCstCom := 0
    Local cLocPad := ""
    Local aArea   := GetArea()

    // Busca com cenário envolvido
    If !Empty(cCenario)
        If cCusto == "2" // ultimo preço de compra
            DbSelectArea("D57")
            D57->(DbSetOrder(2))
            If D57->(DbSeek(xFilial("D57") + PadR(cCenario, TamSX3("D57_CODCEN")[1]) + PadR(cProduto, TamSX3("D57_COD")[1])))
                nCstCom := D57->D57_UPRC
            EndIf
        Else // custo standard (1) ou medio (3 a 7)
            DbSelectArea("D53")
            D53->(DbSetOrder(2))
            If D53->(DbSeek(xFilial("D53") + PadR(cCenario, TamSX3("D53_CODCEN")[1]) + PadR(cProduto, TamSX3("D53_COD")[1])))
                Do Case
                    Case cCusto == "1"; nCstCom := D53->D53_CUSTD
                    Case cCusto == "3"; nCstCom := D53->D53_CM1
                    Case cCusto == "4"; nCstCom := D53->D53_CM2
                    Case cCusto == "5"; nCstCom := D53->D53_CM3
                    Case cCusto == "6"; nCstCom := D53->D53_CM4
                    Case cCusto == "7"; nCstCom := D53->D53_CM5
                End Case
            EndIf
        EndIf
    Else
        // Busca em produção, quando não há cenário
        If cCusto == "2" // ultimo preco de compra em producao
            DbSelectArea("SB1")
            SB1->(DbSetOrder(1)) // Filial + Produto
            If SB1->(DbSeek(xFilial("SB1") + PadR(cProduto, TamSX3("B1_COD")[1])))
                nCstCom := SB1->B1_UPRC
            EndIf
        ElseIf cCusto == "1" // custo standard em producao
            DbSelectArea("SB1")
            SB1->(DbSetOrder(1)) // Filial + Produto
            If SB1->(DbSeek(xFilial("SB1") + PadR(cProduto, TamSX3("B1_COD")[1])))
                nCstCom := SB1->B1_CUSTD 
            EndIf
        Else // custo medio moeda 1-5 em producao
            cLocPad := Posicione("SB1", 1, xFilial("SB1") + PadR(cProduto, TamSX3("B1_COD")[1]), "B1_LOCPAD")
            If Empty(cLocPad)
                cLocPad := "01" // para não quebrar, assumo o armazem = 01
            EndIf
            DbSelectArea("SB2")
            SB2->(DbSetOrder(1)) // Filial + Produto + Local
            If SB2->(DbSeek(xFilial("SB2") + PadR(cProduto, TamSX3("B2_COD")[1]) + PadR(cLocPad, TamSX3("B2_LOCAL")[1]) ))
                Do Case
                    Case cCusto == "3"; nCstCom := SB2->B2_CM1
                    Case cCusto == "4"; nCstCom := SB2->B2_CM2
                    Case cCusto == "5"; nCstCom := SB2->B2_CM3
                    Case cCusto == "6"; nCstCom := SB2->B2_CM4
                    Case cCusto == "7"; nCstCom := SB2->B2_CM5
                End Case
            EndIf
        EndIf
    EndIf
    
    RestArea(aArea)
Return nCstCom

//----------------------------------------------------------------------------------
/*/{Protheus.doc} VldTpCusto
    Funcao de validação do tipo de custo manual
    @type Function
    @author Squad Entradas
    @since 05/06/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function VldTpCusto()
    Local oModel    := FWModelActive()
    Local oMdlD5D   := oModel:GetModel("D5DDETAIL")
    Local cTpCust   := oMdlD5D:GetValue("D5D_TPCUST")
    Local lRet      := .F.

    If oMdlD5D != Nil .And. cTpCust == "8"
        lRet := .T.
    EndIf

Return lRet

//----------------------------------------------------------------------------------
/*/{Protheus.doc} GetLevels
    Funcao que recalcula níveis Produto (SB1) de acordo com Estrutura (D5B)
    @type Function
    @author Leonardo Kichitaro
    @since 05/06/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function GetLevels(cCargoPai, cComponent, oModelD5B)

    Local oModel    := FWModelActive()
    Local oEvent    := gtMdlEvent(oModel, "ESTA101EVDEF")
    Local aRet      := {'01', '99'}
    Local aFilhos   := {}
    Local nPosComp  := 0
    Local nPosNiv   := 0
    Local nPosNivIv := 0
    Local nPosDel   := 0
    Local nX        := 0

    Default cCargoPai   := ""
    Default cComponent  := ""

    If !Empty(cCargoPai) .And. !Empty(cComponent)
        // Carrega posições das colunas
        nPosComp    := aScan(oModelD5B:GetStruct():GetFields(), {|x| AllTrim(x[3]) == "D5B_COMP"})
        nPosNiv     := aScan(oModelD5B:GetStruct():GetFields(), {|x| AllTrim(x[3]) == "D5B_NIV"})
        nPosNivIv   := aScan(oModelD5B:GetStruct():GetFields(), {|x| AllTrim(x[3]) == "D5B_NIVINV"})
        nPosDel     := aScan(oModelD5B:GetStruct():GetFields(), {|x| AllTrim(x[3]) == "LINDEL"})

        If oEvent != Nil .And. oEvent:oCacheD5B:HasProperty(Rtrim(cCargoPai))
            aFilhos := oEvent:oCacheD5B[Rtrim(cCargoPai)]

            // Verifica se há filho para o item selecionado, para definir se a grid de operações deve ser habilitada
            For nX := 1 To Len(aFilhos)
                // Se encontrar o componente dentro do nó do Pai
                If !Empty(aFilhos[nX][2][nPosComp]) .And. !aFilhos[nX][2][nPosDel] .And. (Rtrim(aFilhos[nX][2][nPosComp]) == Rtrim(cComponent) .Or. Rtrim(cCargoPai) == Rtrim(cComponent))
                    If Val(aFilhos[nX][2][nPosNiv]) > 0 .And. Val(aFilhos[nX][2][nPosNivIv]) > 0
                        aRet[1] := StrZero((Val(aFilhos[nX][2][nPosNiv]) + 1),2)
                        aRet[2] := StrZero((Val(aFilhos[nX][2][nPosNivIv]) - 1),2)
                    EndIf
                    Exit
                EndIf
            Next nX
        EndIf
    EndIf

Return aRet

//----------------------------------------------------------------------------------
/*/{Protheus.doc} MontaPanel
    Funcao de montagem do painel de custo calculado
    @type Function
    @author Squad Entradas
    @since 12/06/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
 Static Function MontaPanel(oParent)
     Local oPanel := TPanel():New(0, 0, "", oParent, , , , , , 0, 0)
     Local oFontTit := TFont():New("Arial", , -14, .T.)
     Local oFontVal := TFont():New("Arial", , -12, .T.)
     Local oFontSub := TFont():New("Arial", , -11, .F.)
     Local nTop     := 10
     Local cPictCst := PesqPict("D5D", "D5D_CSTFIM") // @E 999,999,999.9999
     Local cPictPor := "@E 99999.99"
     Local cSMoeda := AllTrim(SuperGetMV("MV_SIMB1")) + " "
 
     oPanel:Align := CONTROL_ALIGN_ALLCLIENT
 
     TButton():New(nTop, 10, STR0063, oPanel, {|| ESTA101Cal(FWViewActive()) }, 120, 15, , oFontVal, , .T.) // "Recalcular Simulação"
 
     nTop += 25
 
     // MATERIAIS
     TSay():New(nTop, 10, {|| STR0064}, oPanel, , oFontTit, , , , .T., CLR_GRAY, , 150, 15) // "Materiais"
     nTop += 15
     TSay():New(nTop, 10, {|| STR0065}, oPanel, , oFontSub, , , , .T., CLR_GRAY, , 60, 15) // "Original:"
     TSay():New(nTop, 60, {|| cSMoeda + Transform(snMatOri, cPictCst)}, oPanel, , oFontVal, , , , .T., , , 100, 15)
     nTop += 15
     TSay():New(nTop, 10, {|| STR0066}, oPanel, , oFontSub, , , , .T., CLR_GRAY, , 60, 15) // "Simulado:"
     soMatSim := TSay():New(nTop, 60, {|| cSMoeda + Transform(0, cPictCst)}, oPanel, , oFontVal, , , , .T., , , 100, 15)
     nTop += 15
     TSay():New(nTop, 10, {|| STR0067+cSMoeda+":"}, oPanel, , oFontSub, , , , .T., CLR_GRAY, , 60, 15) // "Variação "
     soMatVarVl := TSay():New(nTop, 60, {|| cSMoeda + Transform(0, cPictCst)}, oPanel, , oFontVal, , , , .T., , , 100, 15)
     nTop += 15
     TSay():New(nTop, 10, {|| STR0068}, oPanel, , oFontSub, , , , .T., CLR_GRAY, , 60, 15) // "Variação %:"
     soMatVar := TSay():New(nTop, 60, {|| Transform(0, cPictPor) + " %"}, oPanel, , oFontVal, , , , .T., , , 100, 15)
                                      
 
     nTop += 15
 
     // MOD
     TSay():New(nTop, 10, {|| STR0069}, oPanel, , oFontTit, , , , .T., CLR_GRAY, , 150, 15) // "Mão de Obra"
     nTop += 15
     TSay():New(nTop, 10, {|| STR0065}, oPanel, , oFontSub, , , , .T., CLR_GRAY, , 60, 15) // "Original:"
     TSay():New(nTop, 60, {|| cSMoeda + Transform(snModOri, cPictCst)}, oPanel, , oFontVal, , , , .T., , , 100, 15)
     nTop += 15
     TSay():New(nTop, 10, {|| STR0066}, oPanel, , oFontSub, , , , .T., CLR_GRAY, , 60, 15) // "Simulado:"
     soModSim := TSay():New(nTop, 60, {|| cSMoeda + Transform(0, cPictCst)}, oPanel, , oFontVal, , , , .T., , , 100, 15)
     nTop += 15
     TSay():New(nTop, 10, {|| STR0067+cSMoeda+":"}, oPanel, , oFontSub, , , , .T., CLR_GRAY, , 60, 15) // "Variação "
     soModVarVl := TSay():New(nTop, 60, {|| cSMoeda + Transform(0, cPictCst)}, oPanel, , oFontVal, , , , .T., , , 100, 15)
     nTop += 15
     TSay():New(nTop, 10, {|| STR0068}, oPanel, , oFontSub, , , , .T., CLR_GRAY, , 60, 15) // "Variação %:"
     soModVar := TSay():New(nTop, 60, {|| Transform(0, cPictPor) + " %"}, oPanel, , oFontVal, , , , .T., , , 100, 15)
 
     nTop += 15
 
     // COMPOSIÇÃO DO CUSTO
     TSay():New(nTop, 10, {|| STR0070}, oPanel, , oFontTit, , , , .T., CLR_GRAY, , 150, 15) // "Composição do Custo"
     nTop += 15
     TSay():New(nTop, 10, {|| STR0065}, oPanel, , oFontSub, , , , .T., CLR_GRAY, , 60, 15) // "Original:"
     TSay():New(nTop, 60, {|| cSMoeda + Transform(snMatOri + snModOri, cPictCst)}, oPanel, , oFontVal, , , , .T., , , 100, 15)
     nTop += 15
     TSay():New(nTop, 10, {|| STR0066}, oPanel, , oFontSub, , , , .T., CLR_GRAY, , 60, 15) // "Simulado:"
     soTotSim := TSay():New(nTop, 60, {|| cSMoeda + Transform(0, cPictCst)}, oPanel, , oFontVal, , , , .T., , , 100, 15)
     nTop += 15
     TSay():New(nTop, 10, {|| STR0067+cSMoeda+":"}, oPanel, , oFontSub, , , , .T., CLR_GRAY, , 60, 15) // "Variação "
     soTotVarVl := TSay():New(nTop, 60, {|| cSMoeda + Transform(0, cPictCst)}, oPanel, , oFontVal, , , , .T., , , 100, 15)
     nTop += 15
     TSay():New(nTop, 10, {|| STR0068}, oPanel, , oFontSub, , , , .T., CLR_GRAY, , 60, 15) // "Variação %:"
     soTotVar := TSay():New(nTop, 60, {|| Transform(0, cPictPor) + " %"}, oPanel, , oFontVal, , , , .T., , , 100, 15)
 
 Return oPanel

//----------------------------------------------------------------------------------
/*/{Protheus.doc} ESTA101Pnl
    Funcao que calcula o custo simulado de Materiais e Mão de Obra, e 
    atualiza os campos do painel de custo.
    @type Function
    @author Squad Entradas
    @since 24/06/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Function ESTA101Pnl(lCarregaOri)
    Local oModel   := FWModelActive()
    Local oEvent   := gtMdlEvent(oModel, "ESTA101EVDEF")
    Local cProdPai := RTrim(oModel:GetModel("D5AMASTER"):GetValue("D5A_CODPRO"))
    Local aFieldsD := oModel:GetModel("D5DDETAIL"):GetStruct():GetFields()
    Local aFieldsC := oModel:GetModel("D5CDETAIL"):GetStruct():GetFields()
    
    Local nPosCstFim := aScan(aFieldsD, {|x| AllTrim(x[3]) == "D5D_CSTFIM"})
    Local nPosCstCom := aScan(aFieldsD, {|x| AllTrim(x[3]) == "D5D_CSTCOM"})
    Local nPosDelD   := aScan(aFieldsD, {|x| AllTrim(x[3]) == "LINDEL"})
    Local nPosTaxa   := aScan(aFieldsC, {|x| AllTrim(x[3]) == "D5C_TAXA"})
    Local nPosTaxaSM := aScan(aFieldsC, {|x| AllTrim(x[3]) == "D5C_TAXASM"})
    Local nPosDelC   := aScan(aFieldsC, {|x| AllTrim(x[3]) == "LINDEL"})
    
    Local nMatSim := 0
    Local nModSim := 0
    Local nVarMat := 0
    Local nVarMod := 0
    Local nVarTot := 0
    Local nVarVlMat := 0
    Local nVarVlMod := 0
    Local nVarVlTot := 0
    Local aPais   := {}
    Local aRote   := {}
    Local nI      := 0
    Local nJ      := 0
    Local nTaxOri := 0
    Local nTaxSim := 0
    Local cPictCst := PesqPict("D5D", "D5D_CSTFIM") // @E 999,999,999.9999
    Local cPictPor := "@E 99999.99"
    Local cSMoeda := AllTrim(SuperGetMV("MV_SIMB1")) + " "

    Default lCarregaOri := .F.

    If lCarregaOri
        snMatOri := 0
        snModOri := 0
    EndIf

    // Calculo Material (Lê o custo final do Produto Pai no oCacheD5D)
    If oEvent:oCacheD5D:HasProperty(cProdPai) .And. Len(oEvent:oCacheD5D[cProdPai]) > 0
        If nPosDelD == 0 .Or. oEvent:oCacheD5D[cProdPai][1][2][nPosDelD] == .F.
            nMatSim := oEvent:oCacheD5D[cProdPai][1][2][nPosCstFim]
            // Se for carga original, pega do CSTCOM (Custo Base)
            If lCarregaOri
                snMatOri := oEvent:oCacheD5D[cProdPai][1][2][nPosCstCom]
            EndIf
        EndIf
    EndIf

    // Calculo MOD (Varre oCacheD5C somando os Roteiros)
    If oEvent:oCacheD5C != Nil
        aPais := oEvent:oCacheD5C:GetNames()
        For nI := 1 To Len(aPais)
            aRote := oEvent:oCacheD5C[aPais[nI]]
            For nJ := 1 To Len(aRote)
                If nPosDelC > 0 .And. aRote[nJ][2][nPosDelC] == .T. // Trata linhas deletadas
                    Loop
                EndIf
                
                If lCarregaOri
                    // Se for carga original, usa a taxa base (D5C_TAXA) tanto para original quanto para simulado
                    nTaxOri   := aRote[nJ][2][nPosTaxa]
                    snModOri += nTaxOri
                    nModSim  += nTaxOri
                Else
                    // Se não for carga original, usa a taxa simulada (D5C_TAXASM)
                    nTaxSim := aRote[nJ][2][nPosTaxaSM]
                    nModSim += nTaxSim
                EndIf
            Next nJ
        Next nI
    EndIf

    // Se for o primeiro load, não calcula variação, apenas espelha e sai
    If lCarregaOri
        // Força a tela a criar o painel com os valores bases populados
        If soMatSim != Nil
            soMatSim:SetText(cSMoeda + Transform(snMatOri, cPictCst))
            soModSim:SetText(cSMoeda + Transform(snModOri, cPictCst))
            soTotSim:SetText(cSMoeda + Transform(snMatOri + snModOri, cPictCst))

            // Zera as variações R$
            soMatVarVl:SetText(cSMoeda + Transform(0, cPictCst))
            soModVarVl:SetText(cSMoeda + Transform(0, cPictCst))
            soTotVarVl:SetText(cSMoeda + Transform(0, cPictCst))

        EndIf
        Return Nil
    EndIf

    // Variação em moeda (Simulado - Original)
    nVarVlMat := nMatSim - snMatOri
    nVarVlMod := nModSim - snModOri
    nVarVlTot := (nMatSim + nModSim) - (snMatOri + snModOri)

    soMatVarVl:SetText(IIf(nVarVlMat > 0, "+ " + cSMoeda, cSMoeda) + Transform(nVarVlMat, cPictCst))
    soMatVarVl:nClrText := IIf(nVarVlMat > 0, CLR_HRED, IIf(nVarVlMat < 0, If(lIsDark, CLR_HGREEN, CLR_GREEN), ))

    soModVarVl:SetText(IIf(nVarVlMod > 0, "+ " + cSMoeda, cSMoeda) + Transform(nVarVlMod, cPictCst))
    soModVarVl:nClrText := IIf(nVarVlMod > 0, CLR_HRED, IIf(nVarVlMod < 0, If(lIsDark, CLR_HGREEN, CLR_GREEN), ))

    soTotVarVl:SetText(IIf(nVarVlTot > 0, "+ " + cSMoeda, cSMoeda) + Transform(nVarVlTot, cPictCst))
    soTotVarVl:nClrText := IIf(nVarVlTot > 0, CLR_HRED, IIf(nVarVlTot < 0, If(lIsDark, CLR_HGREEN, CLR_GREEN), ))

    // Variação Material
    If snMatOri > 0
        nVarMat := ((nMatSim / snMatOri) - 1) * 100
    ElseIf nMatSim > 0
        nVarMat := 100
    EndIf
    soMatVar:SetText(IIf(nVarMat > 0, "+ ", "") + Transform(nVarMat, cPictPor) + " %")
    soMatVar:nClrText := IIf(nVarMat > 0, CLR_HRED, IIf(nVarMat < 0, If(lIsDark, CLR_HGREEN, CLR_GREEN), ))

    // Variação Mão de Obra
    If snModOri > 0
        nVarMod := ((nModSim / snModOri) - 1) * 100
    ElseIf nModSim > 0
        nVarMod := 100
    EndIf
    soModVar:SetText(IIf(nVarMod > 0, "+ ", "") + Transform(nVarMod, cPictPor) + " %")
    soModVar:nClrText := IIf(nVarMod > 0, CLR_HRED, IIf(nVarMod < 0, If(lIsDark, CLR_HGREEN, CLR_GREEN), ))

    // Variação Total
    If (snMatOri + snModOri) > 0
        nVarTot := (((nMatSim + nModSim) / (snMatOri + snModOri)) - 1) * 100
    ElseIf (nMatSim + nModSim) > 0
        nVarTot := 100
    EndIf
    soTotVar:SetText(IIf(nVarTot > 0, "+ ", "") + Transform(nVarTot, cPictPor) + " %")
    soTotVar:nClrText := IIf(nVarTot > 0, CLR_HRED, IIf(nVarTot < 0, If(lIsDark, CLR_HGREEN, CLR_GREEN), ))

    // Atualiza os Valores Simulados Reais
    soMatSim:SetText(cSMoeda + Transform(nMatSim, cPictCst))
    soModSim:SetText(cSMoeda + Transform(nModSim, cPictCst))
    soTotSim:SetText(cSMoeda + Transform(nMatSim + nModSim, cPictCst))

Return Nil

//----------------------------------------------------------------------------------
/*/{Protheus.doc} ChkRecursi
    Funcao que valida se o componente possui recursividade na estrutura
    @type Function
    @author Squad Entradas
    @since 06/08/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function ChkRecursi(cComp, cPaiAtu, oModel, cCenario)
    Local cRaiz      := RTrim(oModel:GetModel("D5AMASTER"):GetValue("D5A_CODPRO"))
    Local oEvent     := gtMdlEvent(oModel, "ESTA101EVDEF")
    Local aCaminho   := {}
    Local aCaminhoDB := {}
    Local aCamposD5B := oModel:GetModel("D5BDETAIL"):GetStruct():GetFields()
    Local nPosComp   := aScan(aCamposD5B, {|x| AllTrim(x[3]) == "D5B_COMP"})
    Local nPosDel    := aScan(aCamposD5B, {|x| AllTrim(x[3]) == "LINDEL"})
    
    cComp   := RTrim(cComp)
    cPaiAtu := RTrim(cPaiAtu)

    // Caminho da raiz da simulacao ate o pai selecionado
    aCaminho := GetCaminho(cRaiz, cPaiAtu, oEvent:oCacheD5B, {}, nPosComp, nPosDel)

    // Validacao em cache
    If aScan(aCaminho, {|x| x == cComp}) > 0
        Return .T.
    EndIf

    aCaminhoDB := aClone(aCaminho)
    AAdd(aCaminhoDB, cComp)

    // Validacao em estrutura nas tabelas SG1/D54
    If RecursivDB(cComp, aCaminhoDB, cCenario)
        Return .T.
    EndIf

Return .F.

//----------------------------------------------------------------------------------
/*/{Protheus.doc} GetCaminho
    Funcao que retorna o caminho do produto da simulação até o componente
    @type Function
    @author Squad Entradas
    @since 06/08/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function GetCaminho(cItem, cAlvo, oCache, aCamAtual, nPosComp, nPosDel)
    Local aFilhos
    Local nI
    Local cFilho
    Local aRetorno := {}
    
    AAdd(aCamAtual, cItem)
    
    // produto pai é o componente
    If cItem == cAlvo
        Return aClone(aCamAtual)
    EndIf

    If oCache:HasProperty(cItem)
        aFilhos := oCache[cItem]
        For nI := 1 To Len(aFilhos)
            // Ignora linhas deletadas da grid
            If nPosDel > 0 .And. aFilhos[nI][2][nPosDel] == .T.
                Loop
            EndIf

            cFilho := RTrim(aFilhos[nI][2][nPosComp])
            If !Empty(cFilho)
                aRetorno := GetCaminho(cFilho, cAlvo, oCache, aClone(aCamAtual), nPosComp, nPosDel)
                // Se encontrou o caminho correto a baixo, devolve
                If Len(aRetorno) > 0
                    Return aRetorno
                EndIf
            EndIf
        Next nI
    EndIf

Return {}

//----------------------------------------------------------------------------------
/*/{Protheus.doc} RecursivDB
    Funcao que valida recursividade na estrutura cadastrada na SB1/D54
    @type Function
    @author Squad Entradas
    @since 06/08/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function RecursivDB(cCodPesq, aCaminho, cCenario)
    Local lExiste    := .F.
    Local cAliasSG   := IIf(Empty(cCenario), "SG1", "D54")
    Local nRecAtu    := 0
    Local aAreaSG    := GetArea()
    Local aNewCaminh := {}

    DbSelectArea(cAliasSG)
    If cAliasSG == "D54"
        (cAliasSG)->(DbSetOrder(2)) // D54_FILIAL + D54_CODCEN + D54_COD
        If (cAliasSG)->(DbSeek(xFilial(cAliasSG) + PadR(cCenario, TamSx3("D54_CODCEN")[1]) + PadR(cCodPesq, TamSx3("D54_COD")[1])))
            While !(cAliasSG)->(Eof()) .And. (cAliasSG)->D54_FILIAL == xFilial(cAliasSG) .And. (cAliasSG)->D54_CODCEN == cCenario .And. RTrim((cAliasSG)->D54_COD) == cCodPesq
                
                // encontrou recursividade
                If aScan(aCaminho, {|x| x == RTrim((cAliasSG)->D54_COMP)}) > 0
                    lExiste := .T.
                    Exit
                EndIf

                aNewCaminh := aClone(aCaminho)
                AAdd(aNewCaminh, RTrim((cAliasSG)->D54_COMP))
                
                // verifica componentes filho
                nRecAtu := (cAliasSG)->(Recno())
                If RecursivDB((cAliasSG)->D54_COMP, aCaminho, cCenario)
                    lExiste := .T.
                    Exit
                EndIf
                (cAliasSG)->(DbGoTo(nRecAtu))
                
                (cAliasSG)->(DbSkip())
            EndDo
        EndIf
    Else
        (cAliasSG)->(DbSetOrder(1)) // G1_FILIAL + G1_COD
        If (cAliasSG)->(DbSeek(xFilial(cAliasSG) + PadR(cCodPesq, TamSx3("G1_COD")[1])))
            While !(cAliasSG)->(Eof()) .And. (cAliasSG)->G1_FILIAL == xFilial(cAliasSG) .And. RTrim((cAliasSG)->G1_COD) == cCodPesq
                
                // encontrou recursividade
                If aScan(aCaminho, {|x| x == RTrim((cAliasSG)->G1_COMP)}) > 0
                    lExiste := .T.
                    Exit
                EndIf

                aNewCaminh := aClone(aCaminho)
                AAdd(aNewCaminh, RTrim((cAliasSG)->G1_COMP))
                
                // verifica componentes filho
                nRecAtu := (cAliasSG)->(Recno())
                If RecursivDB((cAliasSG)->G1_COMP, aCaminho, cCenario)
                    lExiste := .T.
                    Exit
                EndIf
                (cAliasSG)->(DbGoTo(nRecAtu))
                
                (cAliasSG)->(DbSkip())
            EndDo
        EndIf
    EndIf

    RestArea(aAreaSG)
Return lExiste

//----------------------------------------------------------------------------------
/*/{Protheus.doc} ProximoTrt
    Funcao que fornece sequencia TRT no componente da estrutura caso esteja abaixo do mesmo pai
    O primeiro item manterá o TRT vazio e o próximo será incrementado com 001.
    @type Function
    @author Squad Entradas
    @since 06/08/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function ProximoTrt(oMdlD5B, cComp)
    Local nInd       := 0
    Local nLinhaAtu  := oMdlD5B:GetLine()
    Local nTamTrt    := TamSx3("D5B_TRT")[1]
    Local cMaxTrt    := Space(nTamTrt)
    Local cProxTrt   := Space(nTamTrt)
    Local aRepetidos := {}

    // Percorre a grid buscando componentes iguais ao que esta sendo digitado
    For nInd := 1 To oMdlD5B:GetQtdLine()
        //ignora a linha incluida e deletadas
        If nInd == nLinhaAtu .Or. oMdlD5B:IsDeleted(nInd)
            Loop
        EndIf

        If RTrim(oMdlD5B:GetValue("D5B_COMP", nInd)) == RTrim(cComp)
            AAdd(aRepetidos, nInd)
            //maior TRT
            If !Empty(oMdlD5B:GetValue("D5B_TRT", nInd)) .And. oMdlD5B:GetValue("D5B_TRT", nInd) > cMaxTrt
                cMaxTrt := oMdlD5B:GetValue("D5B_TRT", nInd)
            EndIf
        EndIf
    Next nInd

    //se encontrou repetidos
    If Len(aRepetidos) > 0
        If Empty(cMaxTrt)
            // O primeiro item fica em branco, proximo ganha sequencial
            cProxTrt := StrZero(1, nTamTrt)
        Else
            // Se ja existe TRT preenchido, pega a maior sequencia encontrada e soma 1
            cProxTrt := Soma1(cMaxTrt)
        EndIf
    Else
        //sem ocorrencia, recebe valor em branco
        cProxTrt := Space(nTamTrt)
    EndIf

Return cProxTrt

//----------------------------------------------------------------------------------
/*/{Protheus.doc} AddD5BComp
    Importa a sub-estrutura do componente incluido na grid D5B para o cache em memoria.
    @type Function
    @author Squad Entradas
    @since 07/08/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function AddD5BComp(oModel, cComp, cCenario, cSimula, cTpCust, cCargoComp)
    Local lRet       := .T.
    Local lCenario   := !Empty(cCenario)
    Local oCacheTemp := Nil
    Local oEvent     := gtMdlEvent(oModel, "ESTA101EVDEF")
    Local aArea      := GetArea()
    Local oMdlD5B    := oModel:GetModel("D5BDETAIL")
    Local aFieldsB2  := oMdlD5B:GetStruct():GetFields()
    Local nPosDel2   := aScan(aFieldsB2, {|x| AllTrim(x[3]) == "LINDEL"})
    Local nPosNreg2  := aScan(aFieldsB2, {|x| AllTrim(x[3]) == "NREG"})
    Local nPosCod2   := aScan(aFieldsB2, {|x| AllTrim(x[3]) == "D5B_COD"})
    Local aLinhaComp := {}
    Local nX         := 0
    Local cPaiComp   := RTrim(scD5BCdPai)

    // Importa a sub-estrutura apenas quando o componente possui estrutura cadastrada.
    If !oEvent:oCacheD5B:HasProperty(RTrim(cComp)) .And. ValidEstru(cComp, cCenario)
        oCacheTemp := JsonObject():New()

        // Cache temporario
        CopiaCache(oEvent:oCacheD5B, @oCacheTemp, cComp)

        // Popula cache temporario recursivamente com filhos
        PopulaRec(oModel, oEvent, oCacheTemp, cComp, lCenario, cCenario, cSimula, cTpCust)

        // Cria linhas de custo na D5D para filhos
        CriaCusto(oModel, oEvent, oCacheTemp, cComp, cCenario, cSimula, cTpCust)

        // Importa roteiros para filhos
        CriaRoteir(oModel, oEvent, oCacheTemp, cCenario, cSimula)

        // Promove cache temporario ao cache oficial
        PromCache(oEvent:oCacheD5B, oCacheTemp)
    EndIf

    // A linha estava em edicao durante o Valid, portanto nao constava no cache
    aLinhaComp := Array(Len(aFieldsB2))
    For nX := 1 To Len(aFieldsB2)
        aLinhaComp[nX] := oMdlD5B:GetValue(aFieldsB2[nX][3])
    Next nX
    aLinhaComp[nPosDel2]  := .F.
    aLinhaComp[nPosNreg2] := 0
    aLinhaComp[nPosCod2]  := PadR(RTrim(cPaiComp), TamSx3("D5B_COD")[1])

    If !Empty(cPaiComp)
        AAdd(oEvent:oCacheD5B[cPaiComp], {0, aClone(aLinhaComp)})
    EndIf

    // Recalcula niveis
    ESTA101Niv(oModel)

    // Atualiza arvore lateral
    If soTree != Nil
        soTree:TreeSeek(cCargoComp)
        LoadEstr(soTree, cSimula, cComp, cCargoComp, oModel)
        soTree:TreeSeek(scCargoAtu) //reposiciona para o produto pai
        soTree:Refresh()
    EndIf

    // Atualiza painel de resultados
    ESTA101Pnl(.F.)

    RestArea(aArea)
Return lRet

//----------------------------------------------------------------------------------
/*/{Protheus.doc} CopiaCache
    Funcao que copia o CacheD5B para CacheTmp de componentes
    @type Function
    @author Squad Entradas
    @since 07/08/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function CopiaCache(oCacheOri, oCacheTmp, cComp)
    Local aNames  := {}
    Local aLinhas := {}
    Local nI      := 0
    Local nJ      := 0
    Local cChave  := ""

    aNames := oCacheOri:GetNames()

    For nI := 1 To Len(aNames)
        cChave  := RTrim(aNames[nI])
        aLinhas := {}
        For nJ := 1 To Len(oCacheOri[cChave])
            aAdd(aLinhas, aClone(oCacheOri[cChave][nJ]))
        Next nJ
        oCacheTmp[cChave] := aLinhas
    Next nI

    If !oCacheTmp:HasProperty(RTrim(cComp))
        oCacheTmp[RTrim(cComp)] := {}
    EndIf

Return

//----------------------------------------------------------------------------------
/*/{Protheus.doc} PopulaRec
    Importa recursivamente os filhos do produto pai do cache SG1 ou D54
    @type Function
    @author Squad Entradas
    @since 07/08/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function PopulaRec(oModel, oEvent, oCacheTmp, cPai, lCenario, cCenario, cSimula, cTpCust)
    Local aArea      := {}
    Local cFilho     := ""
    Local cDescri    := ""
    Local cCargo     := ""
    Local aLinha     := {}
    Local aFieldsB   := {}
    Local nSeq       := 0
    Local nCustoUni  := 0
    Local nK         := 0
    Local cCampo     := ""
    Local nPosComp   := 0

    cPai := RTrim(cPai)
    aFieldsB := oModel:GetModel("D5BDETAIL"):GetStruct():GetFields()
    aArea := GetArea()

    If lCenario
        DbSelectArea("D54")
        DbSetOrder(2) // D54_FILIAL+D54_CODCEN+D54_COD - Indice por Cenario + Produto
        DbSeek(xFilial("D54") + PadR(cCenario, TamSx3("D54_CODCEN")[1]) + PadR(cPai, TamSx3("D54_COD")[1]))

        While D54->(!Eof()) .And. RTrim(D54->D54_FILIAL) == RTrim(xFilial("D54")) ;
                .And. RTrim(D54->D54_CODCEN) == RTrim(cCenario) ;
                .And. RTrim(D54->D54_COD) == cPai ;
                .And. !D54->(Deleted())

            cFilho  := RTrim(D54->D54_COMP)
            nCustoUni := GetCusto(cCenario, cFilho, cTpCust)
            cDescri := ""

            DbSelectArea("D53")
            DbSetOrder(2)
            If D53->(DbSeek(xFilial("D53") + PadR(cCenario, TamSx3("D53_CODCEN")[1]) + PadR(cFilho, TamSx3("D53_COD")[1])))
                cDescri := RTrim(D53->D53_DESC)
            EndIf
            DbSelectArea("D54")

            cCargo  := MontaCargo(IND_ESTR, cPai, cFilho, 0)
            aLinha  := Array(Len(aFieldsB))

            For nK := 1 To Len(aFieldsB)
                cCampo := AllTrim(aFieldsB[nK][3])
                Do Case
                    Case cCampo == "D5B_FILIAL"; aLinha[nK] := xFilial("D5B")
                    Case cCampo == "D5B_SIMULA"; aLinha[nK] := cSimula
                    Case cCampo == "D5B_COD"   ; aLinha[nK] := PadR(cPai, TamSx3("D5B_COD")[1])
                    Case cCampo == "D5B_COMP"  ; aLinha[nK] := PadR(cFilho, TamSx3("D5B_COMP")[1])
                    Case cCampo == "D5B_DESC"  ; aLinha[nK] := cDescri
                    Case cCampo == "D5B_QUANT" ; aLinha[nK] := D54->D54_QUANT
                    Case cCampo == "D5B_NIV"   ; aLinha[nK] := D54->D54_NIV
                    Case cCampo == "D5B_NIVINV"; aLinha[nK] := D54->D54_NIVINV
                    Case cCampo == "D5B_PERDA" ; aLinha[nK] := D54->D54_PERDA
                    Case cCampo == "D5B_TRT"   ; aLinha[nK] := D54->D54_TRT
                    Case cCampo == "D5B_ROTPAD"; aLinha[nK] := GetRotPad(cFilho)
                    Case cCampo == "D5B_TPCUST"; aLinha[nK] := cTpCust
                    Case cCampo == "D5B_CSTUNI"; aLinha[nK] := nCustoUni
                    Case cCampo == "CARGO"     ; aLinha[nK] := cCargo
                    Case cCampo == "LINDEL"    ; aLinha[nK] := .F.
                    Case cCampo == "NREG"      ; aLinha[nK] := 0
                EndCase
            Next nK

            If !oCacheTmp:HasProperty(cPai)
                oCacheTmp[cPai] := {}
            EndIf
            aAdd(oCacheTmp[cPai], {0, aClone(aLinha)})

            If !oCacheTmp:HasProperty(cFilho)
                oCacheTmp[cFilho] := {}
            EndIf

            DbSelectArea("D54")
            D54->(DbSkip())
        EndDo
    Else
        DbSelectArea("SG1")
        DbSetOrder(1)
        DbSeek(xFilial("SG1") + PadR(cPai, TamSx3("G1_COD")[1]))

        While SG1->(!Eof()) .And. RTrim(SG1->G1_FILIAL) == RTrim(xFilial("SG1")) ;
                .And. RTrim(SG1->G1_COD) == cPai ;
                .And. !SG1->(Deleted())

            cFilho  := RTrim(SG1->G1_COMP)
            nCustoUni := GetCusto(cCenario, cFilho, cTpCust)
            cDescri := ""

            DbSelectArea("SB1")
            DbSetOrder(1)
            If SB1->(DbSeek(xFilial("SB1") + PadR(cFilho, TamSx3("B1_COD")[1])))
                cDescri := RTrim(SB1->B1_DESC)
            EndIf
            DbSelectArea("SG1")

            cCargo  := MontaCargo(IND_ESTR, cPai, cFilho, 0)
            aLinha  := Array(Len(aFieldsB))

            For nK := 1 To Len(aFieldsB)
                cCampo := AllTrim(aFieldsB[nK][3])
                Do Case
                    Case cCampo == "D5B_FILIAL"; aLinha[nK] := xFilial("D5B")
                    Case cCampo == "D5B_SIMULA"; aLinha[nK] := cSimula
                    Case cCampo == "D5B_COD"   ; aLinha[nK] := PadR(cPai, TamSx3("D5B_COD")[1])
                    Case cCampo == "D5B_COMP"  ; aLinha[nK] := PadR(cFilho, TamSx3("D5B_COMP")[1])
                    Case cCampo == "D5B_DESC"  ; aLinha[nK] := cDescri
                    Case cCampo == "D5B_QUANT" ; aLinha[nK] := SG1->G1_QUANT
                    Case cCampo == "D5B_NIV"   ; aLinha[nK] := SG1->G1_NIV
                    Case cCampo == "D5B_NIVINV"; aLinha[nK] := SG1->G1_NIVINV
                    Case cCampo == "D5B_PERDA" ; aLinha[nK] := SG1->G1_PERDA
                    Case cCampo == "D5B_TRT"   ; aLinha[nK] := SG1->G1_TRT
                    Case cCampo == "D5B_ROTPAD"; aLinha[nK] := GetRotPad(cFilho)
                    Case cCampo == "D5B_TPCUST"; aLinha[nK] := cTpCust
                    Case cCampo == "D5B_CSTUNI"; aLinha[nK] := nCustoUni
                    Case cCampo == "CARGO"     ; aLinha[nK] := cCargo
                    Case cCampo == "LINDEL"    ; aLinha[nK] := .F.
                    Case cCampo == "NREG"      ; aLinha[nK] := 0
                EndCase
            Next nK

            If !oCacheTmp:HasProperty(cPai)
                oCacheTmp[cPai] := {}
            EndIf
            aAdd(oCacheTmp[cPai], {0, aClone(aLinha)})

            If !oCacheTmp:HasProperty(cFilho)
                oCacheTmp[cFilho] := {}
            EndIf

            DbSelectArea("SG1")
            SG1->(DbSkip())
        EndDo
    EndIf

    RestArea(aArea)

    // Recursao
    If oCacheTmp:HasProperty(cPai)
        nPosComp := aScan(aFieldsB, {|x| AllTrim(x[3]) == "D5B_COMP"})
        For nSeq := 1 To Len(oCacheTmp[cPai])
            cFilho := RTrim(oCacheTmp[cPai][nSeq][2][nPosComp])
            If !Empty(cFilho)
                PopulaRec(oModel, oEvent, oCacheTmp, cFilho, lCenario, cCenario, cSimula, cTpCust)
            EndIf
        Next nSeq
    EndIf

Return

//----------------------------------------------------------------------------------
/*/{Protheus.doc} CriaCusto
    Para cada filho no cache temporario sem entrada no oCacheD5D, cria linha de custo inicial
    @type Function
    @author Squad Entradas
    @since 07/08/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function CriaCusto(oModel, oEvent, oCacheTmp, cComp, cCenario, cSimula, cTpCust)
    Local aNames   := {}
    Local aFieldsD := {}
    Local cChave   := ""
    Local nI       := 0

    aFieldsD := oModel:GetModel("D5DDETAIL"):GetStruct():GetFields()
    aNames   := oCacheTmp:GetNames()

    For nI := 1 To Len(aNames)
        cChave := RTrim(aNames[nI])

        If !oEvent:oCacheD5D:HasProperty(cChave)
            CriaLinCus(oEvent, aFieldsD, cChave, cCenario, cSimula, cTpCust)
        EndIf
    Next nI

Return

//----------------------------------------------------------------------------------
/*/{Protheus.doc} CriaLinCus
    Monta e grava no oCacheD5D a linha de custo inicial de um produto.
    @type Function
    @author Squad Entradas
    @since 13/08/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function CriaLinCus(oEvent, aFieldsD, cChave, cCenario, cSimula, cTpCust, nCusto)
    Local aLinhaD := {}
    Local cFilOri := GetFilOri(cCenario, RTrim(cChave))

    Default nCusto := GetCusto(cCenario, RTrim(cChave), cTpCust)

    aLinhaD := Array(Len(aFieldsD))

    aLinhaD[aScan(aFieldsD, {|x| AllTrim(x[3]) == "D5D_FILIAL"})] := FWxFilial("D5D")
    aLinhaD[aScan(aFieldsD, {|x| AllTrim(x[3]) == "D5D_SIMULA"})] := cSimula
    aLinhaD[aScan(aFieldsD, {|x| AllTrim(x[3]) == "D5D_CODCEN"})] := cCenario
    aLinhaD[aScan(aFieldsD, {|x| AllTrim(x[3]) == "D5D_FILORI"})] := cFilOri
    aLinhaD[aScan(aFieldsD, {|x| AllTrim(x[3]) == "D5D_COD"})]    := RTrim(cChave)
    aLinhaD[aScan(aFieldsD, {|x| AllTrim(x[3]) == "D5D_TPCUST"})] := cTpCust
    aLinhaD[aScan(aFieldsD, {|x| AllTrim(x[3]) == "D5D_CSTCOM"})] := nCusto
    aLinhaD[aScan(aFieldsD, {|x| AllTrim(x[3]) == "D5D_CSTFIM"})] := nCusto
    aLinhaD[aScan(aFieldsD, {|x| AllTrim(x[3]) == "D5D_TRT"})]    := "" //tratar posteriormente
    aLinhaD[aScan(aFieldsD, {|x| AllTrim(x[3]) == "NREG"})]       := 0
    aLinhaD[aScan(aFieldsD, {|x| AllTrim(x[3]) == "LINDEL"})]     := .F.
    
    oEvent:oCacheD5D[RTrim(cChave)] := {{0, aClone(aLinhaD)}}

Return

//----------------------------------------------------------------------------------
/*/{Protheus.doc} PromCache
    Promove todas as chaves do cache temporario para o cache oficial.
    @type Function
    @author Squad Entradas
    @since 07/08/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function PromCache(oCacheOfi, oCacheTmp)
    Local aNames := {}
    Local cChave := ""
    Local nI     := 0

    aNames := oCacheTmp:GetNames()
    For nI := 1 To Len(aNames)
        cChave := RTrim(aNames[nI])
        oCacheOfi[cChave] := oCacheTmp[cChave]
    Next nI

Return

//----------------------------------------------------------------------------------
/*/{Protheus.doc} CriaRoteir
    Para cada filho no cache temporario sem entrada no oCacheD5C, importa os roteiros 
    da D55 (cenario) ou SG2 (producao)
    @type Function
    @author Squad Entradas
    @since 10/08/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function CriaRoteir(oModel, oEvent, oCacheTmp, cCenario, cSimula)
    Local aNames   := {}
    Local aFieldsC := {}
    Local aLinhaC  := {}
    Local cChave   := ""
    Local nI       := 0
    Local nK       := 0
    Local cCampo   := ""
    Local aArea    := GetArea()
    Local lCenario := !Empty(cCenario)
    Local nTaxaAtu   := 0
    Local aAreaD58   := Nil
    Local aAreaD56   := Nil
    Local aAreaSH1   := Nil
    Local aAreaSB1   := Nil
    Local aAreaSB2   := Nil
    Local cCcustoRec := ""
    Local cProdMod   := ""
    Local cLocPad    := ""

    aFieldsC := oModel:GetModel("D5CDETAIL"):GetStruct():GetFields()
    aNames   := oCacheTmp:GetNames()

    For nI := 1 To Len(aNames)
        cChave := RTrim(aNames[nI])

        // Inicializa entrada no cache de roteiros
        If !oEvent:oCacheD5C:HasProperty(cChave)
            oEvent:oCacheD5C[cChave] := {}
        ElseIf Len(oEvent:oCacheD5C[cChave]) > 0 // Se já existe no cache e já possui linhas de operações, pula
            Loop
        EndIf

        // Importa roteiros da D55 (cenario) ou SG2 (producao)
        If lCenario
            DbSelectArea("D55")
            D55->(DbSetOrder(2)) // D55_FILIAL+D55_CODCEN+D55_PRODUT
            If D55->(DbSeek(xFilial("D55") + PadR(cCenario, TamSx3("D55_CODCEN")[1]) + PadR(cChave, TamSx3("D55_PRODUT")[1])))
                While !D55->(Eof()) .And. D55->D55_FILIAL == xFilial("D55") .And. RTrim(D55->D55_CODCEN) == RTrim(cCenario) .And. RTrim(D55->D55_PRODUT) == cChave
                    
                    // Busca de Taxa com Cenário
                    nTaxaAtu := 0
                    If !Empty(D55->D55_RECURS)
                        aAreaD58 := D58->(GetArea())
                        aAreaD56 := D56->(GetArea())

                        DbSelectArea("D58")
                        D58->(DbSetOrder(2))
                        If D58->(DbSeek(xFilial("D58") + PadR(cCenario, TamSX3("D58_CODCEN")[1]) + PadR(D55->D55_RECURS, TamSX3("D58_CODIGO")[1])))
                            If !Empty(D58->D58_CCUSTO)
                                DbSelectArea("D56")
                                D56->(DbSetOrder(2))
                                If D56->(DbSeek(xFilial("D56") + PadR(D58->D58_FILORI, TamSX3("D56_FILORI")[1]) + PadR(cCenario, TamSX3("D56_CODCEN")[1]) + PadR(D58->D58_CCUSTO, TamSX3("D56_CODCC")[1])))
                                    nTaxaAtu := D56->D56_TAXA
                                EndIf
                            EndIf
                        EndIf
                        RestArea(aAreaD58)
                        RestArea(aAreaD56)
                    EndIf
                    
                    aLinhaC := Array(Len(aFieldsC))
                    For nK := 1 To Len(aFieldsC)
                        cCampo := AllTrim(aFieldsC[nK][3])
                        Do Case
                            Case cCampo == "D5C_FILIAL"; aLinhaC[nK] := xFilial("D5C")
                            Case cCampo == "D5C_SIMULA"; aLinhaC[nK] := cSimula
                            Case cCampo == "D5C_PRODUT"; aLinhaC[nK] := cChave
                            Case cCampo == "D5C_CODIGO"; aLinhaC[nK] := D55->D55_CODIGO
                            Case cCampo == "D5C_OPERAC"; aLinhaC[nK] := D55->D55_OPERAC
                            Case cCampo == "D5C_DESCRI"; aLinhaC[nK] := D55->D55_DESCRI
                            Case cCampo == "D5C_RECURS"; aLinhaC[nK] := D55->D55_RECURS
                            Case cCampo == "D5C_MAOOBR"; aLinhaC[nK] := D55->D55_MAOOBR
                            Case cCampo == "D5C_SETUP" ; aLinhaC[nK] := D55->D55_SETUP
                            Case cCampo == "D5C_TEMPAD"; aLinhaC[nK] := D55->D55_TEMPAD
                            Case cCampo == "D5C_LOTPAD"; aLinhaC[nK] := D55->D55_LOTPAD
                            Case cCampo == "D5C_TPOPER"; aLinhaC[nK] := D55->D55_TPOPER
                            Case cCampo == "D5C_REFGRD"; aLinhaC[nK] := D55->D55_REFGRD
                            Case cCampo == "D5C_TAXA"  ; aLinhaC[nK] := nTaxaAtu
                            Case cCampo == "D5C_TAXASM"; aLinhaC[nK] := nTaxaAtu
                            Case cCampo == "D5C_TRT"   ; aLinhaC[nK] := ""
                            Case cCampo == "LINDEL"    ; aLinhaC[nK] := .F.
                            Case cCampo == "NREG"      ; aLinhaC[nK] := 0
                        EndCase
                    Next nK
                    AAdd(oEvent:oCacheD5C[cChave], {0, aClone(aLinhaC)})
                    D55->(DbSkip())
                EndDo
            EndIf
        Else
            DbSelectArea("SG2")
            SG2->(DbSetOrder(1)) // G2_FILIAL+G2_PRODUTO
            If SG2->(DbSeek(xFilial("SG2") + PadR(cChave, TamSx3("G2_PRODUTO")[1])))
                While !SG2->(Eof()) .And. SG2->G2_FILIAL == xFilial("SG2") .And. RTrim(SG2->G2_PRODUTO) == cChave
                    
                    // Busca de Taxa em produção
                    nTaxaAtu := 0
                    If !Empty(SG2->G2_RECURSO)
                        aAreaSH1 := SH1->(GetArea())
                        aAreaSB1 := SB1->(GetArea())
                        aAreaSB2 := SB2->(GetArea())
                        
                        DbSelectArea("SH1")
                        SH1->(DbSetOrder(1)) // H1_FILIAL+H1_CODIGO
                        If SH1->(DbSeek(xFilial("SH1") + PadR(SG2->G2_RECURSO, TamSX3("H1_CODIGO")[1])))
                            If !Empty(SH1->H1_CCUSTO)
                                cCcustoRec := RTrim(SH1->H1_CCUSTO)

                                DbSelectArea("SB1")
                                SB1->(DbSetOrder(1)) // B1_FILIAL+B1_COD
                                cProdMod := "MOD" + cCcustoRec

                                If SB1->(DbSeek(xFilial("SB1") + PadR(cProdMod, TamSX3("B1_COD")[1])))
                                    cLocPad := IIf(!Empty(SB1->B1_LOCPAD), SB1->B1_LOCPAD, "01")
                                    DbSelectArea("SB2")
                                    SB2->(DbSetOrder(1)) // B2_FILIAL+B2_COD+B2_LOCAL
                                    If SB2->(DbSeek(xFilial("SB2") + PadR(SB1->B1_COD, TamSX3("B2_COD")[1]) + PadR(cLocPad, TamSX3("B2_LOCAL")[1])))
                                        nTaxaAtu := SB2->B2_CM1
                                    EndIf
                                Else
                                    SB1->(DbSetOrder(8)) // B1_FILIAL+B1_CCCUSTO+B1_GCCUSTO
                                    If SB1->(DbSeek(xFilial("SB1") + PadR(cCcustoRec, TamSX3("B1_CCCUSTO")[1]), .T.)) .And. RTrim(SB1->B1_CCCUSTO) == RTrim(cCcustoRec)
                                        cLocPad := IIf(!Empty(SB1->B1_LOCPAD), SB1->B1_LOCPAD, "01")
                                        DbSelectArea("SB2")
                                        SB2->(DbSetOrder(1)) // B2_FILIAL+B2_COD+B2_LOCAL
                                        If SB2->(DbSeek(xFilial("SB2") + PadR(SB1->B1_COD, TamSX3("B2_COD")[1]) + PadR(cLocPad, TamSX3("B2_LOCAL")[1])))
                                            nTaxaAtu := SB2->B2_CM1
                                        EndIf
                                    EndIf
                                EndIf
                            EndIf
                        EndIf
                        RestArea(aAreaSH1)
                        RestArea(aAreaSB1)
                        RestArea(aAreaSB2)
                    EndIf
                    
                    aLinhaC := Array(Len(aFieldsC))
                    For nK := 1 To Len(aFieldsC)
                        cCampo := AllTrim(aFieldsC[nK][3])
                        Do Case
                            Case cCampo == "D5C_FILIAL"; aLinhaC[nK] := xFilial("D5C")
                            Case cCampo == "D5C_SIMULA"; aLinhaC[nK] := cSimula
                            Case cCampo == "D5C_PRODUT"; aLinhaC[nK] := cChave
                            Case cCampo == "D5C_CODIGO"; aLinhaC[nK] := SG2->G2_CODIGO
                            Case cCampo == "D5C_OPERAC"; aLinhaC[nK] := SG2->G2_OPERAC
                            Case cCampo == "D5C_DESCRI"; aLinhaC[nK] := SG2->G2_DESCRI
                            Case cCampo == "D5C_RECURS"; aLinhaC[nK] := SG2->G2_RECURSO
                            Case cCampo == "D5C_MAOOBR"; aLinhaC[nK] := SG2->G2_MAOOBRA
                            Case cCampo == "D5C_SETUP" ; aLinhaC[nK] := SG2->G2_SETUP
                            Case cCampo == "D5C_TEMPAD"; aLinhaC[nK] := SG2->G2_TEMPAD
                            Case cCampo == "D5C_LOTPAD"; aLinhaC[nK] := SG2->G2_LOTEPAD
                            Case cCampo == "D5C_TPOPER"; aLinhaC[nK] := SG2->G2_TPOPER
                            Case cCampo == "D5C_REFGRD"; aLinhaC[nK] := SG2->G2_REFGRD
                            Case cCampo == "D5C_TAXA"  ; aLinhaC[nK] := nTaxaAtu
                            Case cCampo == "D5C_TAXASM"; aLinhaC[nK] := nTaxaAtu
                            Case cCampo == "D5C_TRT"   ; aLinhaC[nK] := ""
                            Case cCampo == "LINDEL"    ; aLinhaC[nK] := .F.
                            Case cCampo == "NREG"      ; aLinhaC[nK] := 0
                        EndCase
                    Next nK
                    AAdd(oEvent:oCacheD5C[cChave], {0, aClone(aLinhaC)})
                    SG2->(DbSkip())
                EndDo
            EndIf
        EndIf
    Next nI

    RestArea(aArea)
Return

//----------------------------------------------------------------------------------
/*/{Protheus.doc} VldD5BQtde
    Funcao de validacao da quantidade da linha da grid de componente.
    Quando a linha e nova e o componente possui estrutura em SG1 ou D54,
    importa recursivamente os filhos para o cache em memoria
    @type Function
    @author Squad Entradas
    @since 07/08/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function VldD5BQtde()
    Local lRet       := .T.
    Local oModel     := FWModelActive()
    Local oMdlD5B    := oModel:GetModel("D5BDETAIL")
    Local cComp      := oMdlD5B:GetValue("D5B_COMP")
    Local cCenario   := oModel:GetModel("D5AMASTER"):GetValue("D5A_CODCEN")
    Local cSimula    := oModel:GetModel("D5AMASTER"):GetValue("D5A_NUM")
    Local cTpCust    := oModel:GetModel("D5AMASTER"):GetValue("D5A_TPCUST")
    Local cCargoComp := oMdlD5B:GetValue("CARGO")
    Local oEvent     := gtMdlEvent(oModel, "ESTA101EVDEF")

    // Importa componente e estrutura se houver
    If oMdlD5B:IsInserted() .And. !Empty(cComp) .And. oEvent != Nil
        AddD5BComp(oModel, cComp, cCenario, cSimula, cTpCust, cCargoComp)
    EndIf

Return lRet

//----------------------------------------------------------------------------------
/*/{Protheus.doc} VldProduto
    Funcao que valida o preenchimento do campo do produto nos tipos de simulação e
    inclusão com ou sem cenário.
    @type Function
    @author Squad Entradas
    @since 19/08/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function VldProduto(cProduto, cCenario, cTipo)
    Local lRet := .T.

    If !Empty(cProduto)
        // Validações para PRODUTO NOVO (Tipo 1)
        If Left(cTipo, 1) == "1"
            If Empty(cCenario)
                DbSelectArea("SB1")
                SB1->(DbSetOrder(1))
                If SB1->(DbSeek(xFilial("SB1") + PadR(cProduto, TamSx3("B1_COD")[1])))
                    FWAlertInfo(STR0078, STR0037) //"Código do produto já existe no Cadastro de Produto. Defina outro código." "Atenção"
                    lRet := .F.
                EndIf
            Else
                DbSelectArea("D53")
                D53->(DbSetOrder(2)) 
                If D53->(DbSeek(xFilial("D53") + PadR(cCenario, TamSx3("D53_CODCEN")[1]) + PadR(cProduto, TamSx3("D53_COD")[1])))
                    FWAlertInfo(STR0079 + RTrim(cCenario) + STR0080, STR0037) ///"Código do produto já existe no Cenário " ". Defina outro código." "Atenção"
                    lRet := .F.
                EndIf
            EndIf
        EndIf

        // Validações para PRODUTO EXISTENTE (Tipo 2)
        If Left(cTipo, 1) == "2"
            If Empty(cCenario)
                DbSelectArea("SB1")
                SB1->(DbSetOrder(1))
                If !SB1->(DbSeek(xFilial("SB1") + PadR(cProduto, TamSx3("B1_COD")[1])))
                    FWAlertInfo(STR0081, STR0037) //"Código não localizado no cadastro de Produtos." "Atenção"
                    lRet := .F.
                EndIf
            Else
                DbSelectArea("D53")
                D53->(DbSetOrder(2)) 
                If !D53->(DbSeek(xFilial("D53") + PadR(cCenario, TamSx3("D53_CODCEN")[1]) + PadR(cProduto, TamSx3("D53_COD")[1])))
                    FWAlertInfo(STR0082 + RTrim(cCenario), STR0037) //"Código não localizado no Cenário " "Atenção"
                    lRet := .F.
                EndIf
            EndIf
        EndIf
    EndIf

Return lRet

//----------------------------------------------------------------------------------
/*/{Protheus.doc} VldCenario
    Funcao de validacao do cenário
    @type Function
    @author Squad Entradas
    @since 19/08/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function VldCenario(cCenario)
    Local lRet := .T.

    If !Empty(cCenario)
        DbSelectArea("D50")
        D50->(DbSetOrder(1))
        If !D50->(DbSeek(xFilial("D50") + PadR(cCenario, TamSX3("D50_COD")[1])))
            FWAlertInfo(STR0036, STR0037) //"O código do cenário não foi encontrado." "Atenção"
            lRet := .F.
        EndIf
    EndIf

Return lRet

//----------------------------------------------------------------------------------
/*/{Protheus.doc} VldGetProd
    Funcao de retorno da descrição do produto com ou sem cenário
    @type Function
    @author Squad Entradas
    @since 19/08/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function VldGetProd(cProduto, cCenario, cTipo, oGetPDesc)
    Local lRet    := VldProduto(cProduto, cCenario, cTipo)
    Local cDescri := ""

    If lRet
        If Left(cTipo, 1) == "2"// Produto Existente
            If !Empty(cProduto) .And. Empty(cCenario)
                cDescri := Posicione("SB1", 1, xFilial("SB1") + PadR(cProduto, TamSx3("B1_COD")[1]), "B1_DESC")
            ElseIf !Empty(cProduto) .And. !Empty(cCenario)
                cDescri := Posicione("D53", 2, xFilial("D53") + PadR(cCenario, TamSx3("D53_CODCEN")[1]) + PadR(cProduto, TamSx3("D53_COD")[1]), "D53_DESC")
            EndIf
            oGetPDesc:VarPut(cDescri)
            oGetPDesc:Refresh()
        EndIf
    EndIf

Return lRet

//----------------------------------------------------------------------------------
/*/{Protheus.doc} UpdTipoSim
    Funcao de atualização de tela, quando houver mudança do tipo de simulação, limpa
    os campos de produto e descrição.
    @type Function
    @author Squad Entradas
    @since 19/08/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function UpdTipoSim(cTipo, oGetProd, oGetPDesc)
    Local lRet := .T.
    
    // apaga os campos do produto e descricao
    oGetProd:VarPut(Space(TamSx3("D5A_CODPRO")[1]))
    oGetProd:Refresh()
    
    oGetPDesc:VarPut(Space(TamSx3("D5A_DESPRO")[1]))
    oGetPDesc:Refresh()

    // Bloqueio do campo
    If Left(cTipo, 1) == "1" // Produto Novo
        oGetPDesc:Enable()
    Else                     // Produto Existente
        oGetPDesc:Disable()
    EndIf
    
Return lRet

//----------------------------------------------------------------------------------
/*/{Protheus.doc} VldD5BDesc
    Funcao de validação do campo descrição do produto na criação da simulação
    @type Function
    @author Squad Entradas
    @since 19/08/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function VldD5BDesc()
    Local oModel  := FWModelActive()
    Local oMdlD5B := oModel:GetModel("D5BDETAIL")
    Local cDesc   := oMdlD5B:GetValue("D5B_DESC")
    Local lRet    := .T.

    // Se o campo estiver habilitado e vazio, trava o usuário!
    If Empty(cDesc)
        FWAlertInfo(STR0083, STR0037) //"É obrigatório a definição de uma descrição para o produto." "Atenção"
        lRet := .F.
    EndIf

Return lRet

//----------------------------------------------------------------------------------
/*/{Protheus.doc} AltD5BDesc
    Funcao chamada no campo descrição do componente da estrutura da simulação.
    @type Function
    @author Squad Entradas
    @since 19/08/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function AltD5BDesc()
    Local oModel   := FWModelActive()
    Local oMdlD5B  := oModel:GetModel("D5BDETAIL")
    Local cComp    := oMdlD5B:GetValue("D5B_COMP")
    Local cCenario := oModel:GetModel("D5AMASTER"):GetValue("D5A_CODCEN")
    Local lExiste  := .F.
    Local aArea    := GetArea()

    If !Empty(cComp)
        If !Empty(cCenario)
            DbSelectArea("D53")
            D53->(DbSetOrder(2)) // Filial + Cenario + Produto
            lExiste := D53->(DbSeek(xFilial("D53") + PadR(cCenario, TamSx3("D53_CODCEN")[1]) + PadR(cComp, TamSx3("D53_COD")[1])))
        Else
            DbSelectArea("SB1")
            SB1->(DbSetOrder(1)) // Filial + Produto
            lExiste := SB1->(DbSeek(xFilial("SB1") + PadR(cComp, TamSx3("B1_COD")[1])))
        EndIf
    EndIf

    RestArea(aArea)

    // Se NÃO existe na base, retorna .T. (Libera digitação para o inédito)
    // Se EXISTE, retorna .F. (Bloqueia o campo e o Protheus pula para a Qtde)
Return !lExiste

//----------------------------------------------------------------------------------
/*/{Protheus.doc} GetFilOri
    Funcao que retorna a filial de origem do componente incluido.
    @type Function
    @author Squad Entradas
    @since 19/08/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function GetFilOri(cCenario, cProduto)
    Local cFilOri := ""
    Local aArea   := GetArea()

    If !Empty(cCenario)
        DbSelectArea("D53")
        D53->(DbSetOrder(2)) // D53_FILIAL + D53_CODCEN + D53_COD
        If D53->(DbSeek(xFilial("D53") + PadR(cCenario, TamSX3("D53_CODCEN")[1]) + PadR(cProduto, TamSX3("D53_COD")[1])))
            cFilOri := D53->D53_FILORI
        EndIf
    Else
        DbSelectArea("SB1")
        SB1->(DbSetOrder(1)) // B1_FILIAL + B1_COD
        If SB1->(DbSeek(xFilial("SB1") + PadR(cProduto, TamSX3("B1_COD")[1])))
            cFilOri := SB1->B1_FILIAL
        EndIf
    EndIf

    RestArea(aArea)
Return cFilOri

//----------------------------------------------------------------------------------
/*/{Protheus.doc} ESTA101Pla
    Funcao de validação do produto x Plano de Simulação, verificando se há ocorrencias
    do produto no mesmo plano.
    @type Function
    @author Squad Entradas
    @since 28/08/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Function ESTA101Pla()
    Local oModel    := FWModelActive()
    Local oMdlD5A   := oModel:GetModel("D5AMASTER")
    Local cPlano    := oMdlD5A:GetValue("D5A_PLANO")
    Local cCenario  := oMdlD5A:GetValue("D5A_CODCEN")
    Local cProduto  := oMdlD5A:GetValue("D5A_CODPRO")
    Local cSimula   := oMdlD5A:GetValue("D5A_NUM")
    Local oQuery    := Nil
    Local cQuery    := ""
    Local cAliasQry := ""
    Local lRet      := .T.

    If !Empty(cPlano)
        If Empty(cCenario)
            oModel:SetErrorMessage("D5AMASTER", "D5A_PLANO", "D5AMASTER", "D5A_PLANO", "VLDPLANO", STR0084, STR0085) //"Cenario nao informado." "O cenario deve ser informado para utilizar o agrupador."
            Return .F.
        EndIf

        // validação produto
        cQuery := " SELECT D5A_NUM FROM " + RetSqlName("D5A")
        cQuery += " WHERE D5A_FILIAL = ? "
        cQuery += "   AND D5A_PLANO  = ? "
        cQuery += "   AND D5A_CODPRO = ? "
        cQuery += "   AND D5A_NUM   <> ? "
        cQuery += "   AND D_E_L_E_T_ = ? "

        oQuery := FWExecStatement():New(cQuery)
        oQuery:SetString(1, xFilial("D5A"))
        oQuery:SetString(2, cPlano)
        oQuery:SetString(3, cProduto)
        oQuery:SetString(4, cSimula)
        oQuery:SetString(5, " ")

        cAliasQry := oQuery:OpenAlias()

        If !(cAliasQry)->(Eof())
            oModel:SetErrorMessage("D5AMASTER", "D5A_PLANO", "D5AMASTER", "D5A_PLANO", "VLDPLANOVINC", STR0086 + RTrim(cProduto) + STR0087 + (cAliasQry)->D5A_NUM, STR0088) //"O produto " " já está vinculado ao agrupador na simulação " "Utilize outro plano agrupador para a simulação."
            lRet := .F.
        EndIf

        (cAliasQry)->(DbCloseArea())
        oQuery:Destroy()
        FreeObj(oQuery)

    EndIf

Return lRet
