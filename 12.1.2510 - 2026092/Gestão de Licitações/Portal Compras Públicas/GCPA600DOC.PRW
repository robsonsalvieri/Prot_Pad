#Include 'PROTHEUS.CH'
#Include 'TOTVS.CH'
#Include 'FWMVCDef.ch'
#Include 'gcpa600doc.ch'
  
Static cAliasQry := nil
Static cTpDoc    := ""


/*/{Protheus.doc} Gcpa600Doc()
    (Rotina que faz Amarração do produto do portal de compras públicas 
    com o produto no protheus)
    @type  Function
    @author Thiago Rodrigues
    @since 21/10/2024
/*/
Function Gcpa600Doc(aFornVenc)
Local nx        := 0
Local nY        := 0
Local aFields   := {}

//Proximo alias disponivel
cAliasQry := GetNextAlias() 

//Váriavel de controle do documento gerado
cTpDoc    := ""

//Estrutura da tabela temporária
AAdd(aFields, {"TMP_IDITEM", "C", 005, 0})
AAdd(aFields, {"TMP_NRLOTE", "C", 005, 0})
AAdd(aFields, {"TMP_CODFOR", "C", 006, 0})
AAdd(aFields, {"TMP_LOJFOR", "C", 002, 0})
AAdd(aFields, {"TMP_NOMFOR", "C", 025, 0})
AAdd(aFields, {"TMP_DSITEM", "C", 030, 0})
AAdd(aFields, {"TMP_CODSB1", "C", 030, 0})
AAdd(aFields, {"TMP_UNITEM", "C", 002, 0})
AAdd(aFields, {"TMP_QTITEM", "N", 012, 2})
AAdd(aFields, {"TMP_VLITEM", "N", 014, 2})
AAdd(aFields, {"TMP_TTITEM", "N", 014, 2})

//Define as colunas usadas, adiciona indice e cria a temporaria no banco
oTabTemp:= FWTemporaryTable():New(cAliasQry)
oTabTemp:SetFields(aFields) 
oTabTemp:AddIndex("01", {"TMP_CODFOR","TMP_LOJFOR","TMP_IDITEM","TMP_NRLOTE"})
oTabTemp:Create() 

//carrega tabela temporaria
For nX := 1 To Len(aFornVenc)
    For nY := 1 To Len(aFornVenc[nX][4])
        RecLock((cAliasQry), .T.)
        (cAliasQry)->TMP_IDITEM := AllTrim(Str(aFornVenc[nX][4][nY][1]))
        (cAliasQry)->TMP_NRLOTE := AllTrim(Str(aFornVenc[nX][4][nY][7]))
        (cAliasQry)->TMP_CODFOR := aFornVenc[nX][1]
        (cAliasQry)->TMP_LOJFOR := aFornVenc[nX][2]
        (cAliasQry)->TMP_NOMFOR := aFornVenc[nX][3]
        (cAliasQry)->TMP_DSITEM := Iif(!Empty(aFornVenc[nX][4][nY][2]), AllTrim(aFornVenc[nX][4][nY][2])+" - ", "") + AllTrim(aFornVenc[nX][4][nY][3])
        (cAliasQry)->TMP_UNITEM := aFornVenc[nX][4][nY][4]
        (cAliasQry)->TMP_QTITEM := aFornVenc[nX][4][nY][5]
        (cAliasQry)->TMP_VLITEM := aFornVenc[nX][4][nY][9]
        (cAliasQry)->TMP_TTITEM := aFornVenc[nX][4][nY][10]

        aFornVenc[nX][4][nY][11] := (cAliasQry)->(Recno())

        (cAliasQry)->(MsUnlock())
    Next nY
Next nX

//Executa a rotina em modo de alteração
FWExecView('Alterar', "GcpA600DOC", MODEL_OPERATION_UPDATE, , { || .T. } )

//Carrega os códigos de produtos no array de geração do documento
If !Empty(cTpDoc)
    For nX := 1 To Len(aFornVenc)
        For nY := 1 To Len(aFornVenc[nX][4])
            (cAliasQry)->(dbGoTo(aFornVenc[nX][4][nY][11]))
            aFornVenc[nX][4][nY][12] := (cAliasQry)->TMP_CODSB1
        Next nY
    Next nX
EndIf

oTabTemp:Delete()
FreeObj(oTabTemp)
FwFreeArray(aFields)

Return cTpDoc


/*/{Protheus.doc} ModelDef()
    (Monta Modelo de dados)
    @type  Static Function
    @author Thiago Rodrigues
    @since 21/10/2024
/*/
Static Function ModelDef()
    Local oModel    As Object
    Local oStrDKF   As Object 
    Local oStrGrid  As Object
    Local bLoad     := {|oModel| GcPCarGrid(oModel)}

    //Proximo Alias, para casos de instância direto no model
    If cAliasQry == Nil 
        cAliasQry := GetNextAlias() 
    endif 

    //Estrutura do cabeçalho
    oStrDKF := FWFormStruct(1,'DKF') // Cabeçalho
  
    //Estrutura do grid
    oStrGrid := FWFormModelStruct():New() 
    oStrGrid:AddTable(cAliasQry, {"TMP_IDITEM","TMP_NRLOTE","TMP_CODFOR","TMP_LOJFOR","TMP_NOMFOR","TMP_DSITEM","TMP_CODSB1",;
                                 "TMP_DSCSB1","TMP_UNITEM","TMP_QTITEM","TMP_VLITEM","TMP_TTITEM"}, "Temporaria")
       
   
    //Adiciona os campos da estrutura do Cabeçalho
    oStrDKF:AddField(;
        STR0006,;                             // [01]  C   Titulo do campo
        STR0006,;                             // [02]  C   ToolTip do campo
        "TMP_TPDOC",;                                // [03]  C   Id do Field
        "C",;                                        // [04]  C   Tipo do campo
        1,;                                          // [05]  N   Tamanho do campo
        Nil,;                                        // [06]  N   Decimal do campo
        Nil,;                                        // [07]  B   Code-block de validação do campo
        Nil,;                                        // [08]  B   Code-block de validação When do campo
        {STR0004,STR0005},;        // [09]  A   Lista de valores permitido do campo
        .T.,;                                        // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, '1' ),;  // [11]  B   Code-block de inicializacao do campo
        .F.,;                                        // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                        // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.) 
   
   
    //Adiciona os campos da estrutura do grid
    oStrGrid:AddField(;
        STR0007,;                           // [01]  C   Titulo do campo
        STR0007,;                           // [02]  C   ToolTip do campo
        "TMP_IDITEM",;                        // [03]  C   Id do Field
        "C",;                                  // [04]  C   Tipo do campo
        05,;                                   // [05]  N   Tamanho do campo
        0,;                                    // [06]  N   Decimal do campo
        Nil,;                                  // [07]  B   Code-block de validação do campo
        Nil,;                                  // [08]  B   Code-block de validação When do campo
        {},;                                   // [09]  A   Lista de valores permitido do campo
        .T.,;                                  // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasQry+"->TMP_IDITEM" ),;   // [11]  B   Code-block de inicializacao do campo
        .T.,;                                  // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                  // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                   // [14]  L   Indica se o campo é virtual
        
    oStrGrid:AddField(; 
        STR0008,;                               // [01]  C   Titulo do campo
        STR0008,;                               // [02]  C   ToolTip do campo
        "TMP_NRLOTE",;                          // [03]  C   Id do Field
        "C",;                                   // [04]  C   Tipo do campo
        05,;                                    // [05]  N   Tamanho do campo
        0,;                                     // [06]  N   Decimal do campo
        Nil,;                                   // [07]  B   Code-block de validação do campo
        Nil,;                                   // [08]  B   Code-block de validação When do campo
        {},;                                    // [09]  A   Lista de valores permitido do campo
        .T.,;                                   // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasQry+"->TMP_NRLOTE" ),; // [11]  B   Code-block de inicializacao do campo
        .F.,;                                   // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                   // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                    // [14]  L   Indica se o campo é virtual

      oStrGrid:AddField(;
        STR0009,;                              // [01]  C   Titulo do campo
        STR0009,;                              // [02]  C   ToolTip do campo
        "TMP_CODFOR",;                         // [03]  C   Id do Field
        "C",;                                  // [04]  C   Tipo do campo
        06,;                                   // [05]  N   Tamanho do campo
        0,;                                    // [06]  N   Decimal do campo
        Nil,;                                  // [07]  B   Code-block de validação do campo
        Nil,;                                  // [08]  B   Code-block de validação When do campo
        {},;                                   // [09]  A   Lista de valores permitido do campo
        .T.,;                                  // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasQry+"->TMP_CODFOR" ),; // [11]  B   Code-block de inicializacao do campo
        .F.,;                                  // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                  // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                   // [14]  L   Indica se o campo é virtual
  
        oStrGrid:AddField(;
        STR0010,;                               // [01]  C   Titulo do campo
        STR0010,;                               // [02]  C   ToolTip do campo
        "TMP_LOJFOR",;                         // [03]  C   Id do Field
        "C",;                                  // [04]  C   Tipo do campo
        02,;                                   // [05]  N   Tamanho do campo
        0,;                                    // [06]  N   Decimal do campo
        Nil,;                                  // [07]  B   Code-block de validação do campo
        Nil,;                                  // [08]  B   Code-block de validação When do campo
        {},;                                   // [09]  A   Lista de valores permitido do campo
        .T.,;                                  // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasQry+"->TMP_LOJFOR" ),; // [11]  B   Code-block de inicializacao do campo
        .F.,;                                  // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                  // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                   // [14]  L   Indica se o campo é virtual

        oStrGrid:AddField(;
        STR0011,;                               // [01]  C   Titulo do campo
        STR0011,;                               // [02]  C   ToolTip do campo
        "TMP_NOMFOR",;                         // [03]  C   Id do Field
        "C",;                                  // [04]  C   Tipo do campo
        25,;                                   // [05]  N   Tamanho do campo
        0,;                                    // [06]  N   Decimal do campo
        Nil,;                                  // [07]  B   Code-block de validação do campo
        Nil,;                                  // [08]  B   Code-block de validação When do campo
        {},;                                   // [09]  A   Lista de valores permitido do campo
        .T.,;                                  // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasQry+"->TMP_NOMFOR" ),;  // [11]  B   Code-block de inicializacao do campo
        .F.,;                                  // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                  // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                   // [14]  L   Indica se o campo é virtual

        oStrGrid:AddField(;
        STR0012,;                     // [01]  C   Titulo do campo
        STR0012,;                     // [02]  C   ToolTip do campo
        "TMP_DSITEM",;                         // [03]  C   Id do Field
        "C",;                                  // [04]  C   Tipo do campo
        30,;                                   // [05]  N   Tamanho do campo
        0,;                                    // [06]  N   Decimal do campo
        Nil,;                                  // [07]  B   Code-block de validação do campo
        Nil,;                                  // [08]  B   Code-block de validação When do campo
        {},;                                   // [09]  A   Lista de valores permitido do campo
        .T.,;                                  // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD,  cAliasQry+"->TMP_DSITEM"  ),;// [11]  B   Code-block de inicializacao do campo
        .F.,;                                  // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                  // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                   // [14]  L   Indica se o campo é virtual

        oStrGrid:AddField(;
        STR0013,;                     // [01]  C   Titulo do campo
        STR0013,;                     // [02]  C   ToolTip do campo
        "TMP_CODSB1",;                         // [03]  C   Id do Field
        "C",;                                  // [04]  C   Tipo do campo
        30,;                                   // [05]  N   Tamanho do campo
        0,;                                    // [06]  N   Decimal do campo
        FwBuildFeature( STRUCT_FEATURE_VALID,'ExistCpo("SB1")'),; // [07]  B   Code-block de validação do campo
        Nil,;                                  // [08]  B   Code-block de validação When do campo
        {},;                                   // [09]  A   Lista de valores permitido do campo
        .T.,;                                  // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "" ),;// [11]  B   Code-block de inicializacao do campo
        .F.,;                                  // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                  // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                   // [14]  L   Indica se o campo é virtual

        oStrGrid:AddField(;
        STR0014,;                           // [01]  C   Titulo do campo
        STR0014,;                           // [02]  C   ToolTip do campo
        "TMP_UNITEM",;                        // [03]  C   Id do Field
        "C",;                                 // [04]  C   Tipo do campo
        02,;                                  // [05]  N   Tamanho do campo
        0,;                                   // [06]  N   Decimal do campo
        Nil,;                                 // [07]  B   Code-block de validação do campo
        Nil,;                                 // [08]  B   Code-block de validação When do campo
        {},;                                  // [09]  A   Lista de valores permitido do campo
        .T.,;                                 // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasQry+"->TMP_UNITEM" ),; // [11]  B   Code-block de inicializacao do campo
        .F.,;                                 // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                 // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                  // [14]  L   Indica se o campo é virtual

        oStrGrid:AddField(;
        STR0015,;                        // [01]  C   Titulo do campo
        STR0015,;                        // [02]  C   ToolTip do campo
        "TMP_QTITEM",;                        // [03]  C   Id do Field
        "N",;                                 // [04]  C   Tipo do campo
        12,;                                  // [05]  N   Tamanho do campo
        2,;                                   // [06]  N   Decimal do campo
        Nil,;                                 // [07]  B   Code-block de validação do campo
        Nil,;                                 // [08]  B   Code-block de validação When do campo
        {},;                                  // [09]  A   Lista de valores permitido do campo
        .T.,;                                 // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasQry+"->TMP_QTITEM" ),; // [11]  B   Code-block de inicializacao do campo
        .F.,;                                 // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                 // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                  // [14]  L   Indica se o campo é virtual

        oStrGrid:AddField(;
        STR0016,;                   // [01]  C   Titulo do campo
        STR0016,;                   // [02]  C   ToolTip do campo
        "TMP_VLITEM",;                       // [03]  C   Id do Field
        "N",;                                // [04]  C   Tipo do campo
        14,;                                 // [05]  N   Tamanho do campo
        2,;                                  // [06]  N   Decimal do campo
        Nil,;                                // [07]  B   Code-block de validação do campo
        Nil,;                                // [08]  B   Code-block de validação When do campo
        {},;                                 // [09]  A   Lista de valores permitido do campo
        .T.,;                                // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasQry+"->TMP_VLITEM" ),;// [11]  B   Code-block de inicializacao do campo
        .F.,;                                // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                 // [14]  L   Indica se o campo é virtual

        oStrGrid:AddField(;
        STR0017,;                     // [01]  C   Titulo do campo
        STR0017,;                     // [02]  C   ToolTip do campo
        "TMP_TTITEM",;                      // [03]  C   Id do Field
        "N",;                               // [04]  C   Tipo do campo
        14,;                                // [05]  N   Tamanho do campo
        2,;                                 // [06]  N   Decimal do campo
        Nil,;                               // [07]  B   Code-block de validação do campo
        Nil,;                               // [08]  B   Code-block de validação When do campo
        {},;                                // [09]  A   Lista de valores permitido do campo
        .T.,;                               // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasQry+"->TMP_TTITEM" ),; // [11]  B   Code-block de inicializacao do campo
        .F.,;                               // [12]  L   Indica se trata-se de um campo chave
        .F.,;                               // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                // [14]  L   Indica se o campo é virtual
        
    // Instancia o objeto do modelo de dados
    oModel := MPFormModel():New('Gcpa600Doc',/*bPreValid*/ , {|oModel|A600VldOk(oModel)})
    
    //Adiciona o cabeçalho e Grid
    oModel:AddFields('CABID', , oStrDKF)
    oModel:AddGrid('GRIDID', 'CABID', oStrGrid,,,,,bLoad)

    //Não permite deletar linha no grid
    oModel:GetModel('GRIDID'):SetNoDeleteLine(.T.)
    oModel:GetModel('GRIDID'):SetNoInsertLine(.T.)

    oModel:SetDescription(STR0001) //"Relacionar Itens do Processo"
    oModel:GetModel("CABID"):SetDescription( STR0002 ) //"Dados da Integração"
	oModel:GetModel("GRIDID"):SetDescription( STR0003 ) //"Itens do Processo x Sistema"
  
  	//Definindo campos unicos da linha
	oModel:GetModel("GRIDID"):SetUniqueLine({'TMP_IDITEM','TMP_NRLOTE','TMP_CODFOR','TMP_LOJFOR'})
Return oModel


/*/{Protheus.doc} ViewDef()
    (View da rotina)
    @type  Static Function
    @author Thiago Rodrigues
    @since 21/10/2024
/*/
Static Function ViewDef()
    Local oView    As Object
    Local oModel   As Object
    Local oStrCab  As Object
    Local oStrGrid As Object
  
    //Estrtutura do cabeçalho na visualização dos dados
    oStrCab := FWFormStruct(2, 'DKF', { |cCampo| PLSCMPDKF(cCampo) } )

    //Agora a estrutura do Grid
    oStrGrid := FWFormViewStruct():New()
   

    //Adicionando campos da estrutura do cabeçalho
    oStrCab:AddField(;
        "TMP_TPDOC",;               // [01]  C   Nome do Campo
        "99",;                      // [02]  C   Ordem
        STR0006,;                   // [03]  C   Titulo do campo
        STR0006,;                   // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .T.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        {STR0004,STR0005},;         // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo




    //Adicionando campos da estrutura do grid
    oStrGrid:AddField(;
        "TMP_IDITEM",;              // [01]  C   Nome do Campo
        "01",;                      // [02]  C   Ordem
        STR0007,;                   // [03]  C   Titulo do campo
        STR0007,;                   // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .F.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo
    
    oStrGrid:AddField(;
        "TMP_NRLOTE",;              // [01]  C   Nome do Campo
        "02",;                      // [02]  C   Ordem
        STR0008,;                   // [03]  C   Titulo do campo
        STR0008,;                   // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .F.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo
  
      oStrGrid:AddField(;
        "TMP_CODFOR",;              // [01]  C   Nome do Campo
        "03",;                      // [02]  C   Ordem
        STR0009,;          // [03]  C   Titulo do campo
        STR0009,;          // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .F.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

      oStrGrid:AddField(;
        "TMP_LOJFOR",;              // [01]  C   Nome do Campo
        "04",;                      // [02]  C   Ordem
        STR0010,;                    // [03]  C   Titulo do campo
        STR0010,;                    // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .F.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

      oStrGrid:AddField(;
        "TMP_NOMFOR",;              // [01]  C   Nome do Campo
        "05",;                      // [02]  C   Ordem
        STR0011,;                    // [03]  C   Titulo do campo
        STR0011,;                    // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .F.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

      oStrGrid:AddField(;
        "TMP_DSITEM",;              // [01]  C   Nome do Campo
        "06",;                      // [02]  C   Ordem
        STR0012,;          // [03]  C   Titulo do campo
        STR0012,;          // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .F.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

      oStrGrid:AddField(;
        "TMP_CODSB1",;              // [01]  C   Nome do Campo
        "07",;                      // [02]  C   Ordem
        STR0013,;            // [03]  C   Titulo do campo
        STR0013,;            // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        "SB1",;                     // [09]  C   Consulta F3
        .T.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

      oStrGrid:AddField(;
        "TMP_UNITEM",;              // [01]  C   Nome do Campo
        "08",;                      // [02]  C   Ordem
        STR0014,;                 // [03]  C   Titulo do campo
        STR0014,;                 // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .F.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

      oStrGrid:AddField(;
        "TMP_QTITEM",;              // [01]  C   Nome do Campo
        "09",;                      // [02]  C   Ordem
        STR0015,;              // [03]  C   Titulo do campo
        STR0015,;              // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        "@E 999,999,999.99",;       // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .F.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

      oStrGrid:AddField(;
        "TMP_VLITEM",;              // [01]  C   Nome do Campo
        "10",;                      // [02]  C   Ordem
        STR0016,;                   // [03]  C   Titulo do campo
        STR0016,;                   // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "N",;                       // [06]  C   Tipo do campo
        "@E 99,999,999,999.99",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .F.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

      oStrGrid:AddField(;
        "TMP_TTITEM",;              // [01]  C   Nome do Campo
        "11",;                      // [02]  C   Ordem
        STR0017,;          // [03]  C   Titulo do campo
        STR0017,;          // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "N",;                       // [06]  C   Tipo do campo
        "@E 99,999,999,999.99",;    // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .F.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

    //Carrega o ModelDef
    oModel  := FWLoadModel('Gcpa600Doc')
  
    //carrega o modelo, define o cabeçalho e a grid, e no cabeçalho coloca 0% de visualização, e na grid coloca 100%
    oView := FwFormView():New()
    oView:SetModel(oModel)

    //Cabeçalho
    oView:AddField('CAB', oStrCab, 'CABID')

    //Grid
    oView:AddGrid('GRID', oStrGrid, 'GRIDID')

    //Espaço que o cabeçalho irá ocupar
    oView:CreateHorizontalBox('TOHID', 30)

    //Espaço que o Grid irá ocupar
    oView:CreateHorizontalBox('TOSHOW', 70)
    
    //Seta o oWner na View
    oView:SetOwnerView('CAB' , 'TOHID')
    oView:SetOwnerView('GRID', 'TOSHOW')

    //Desativa a mensagem de update
    oView:showUpdateMsg(.F.)

    //Titulos
	oView:EnableTitleView("CAB", STR0002) 
	oView:EnableTitleView("GRID",STR0018)

Return oView

/*/{Protheus.doc} PLSCMPDKF()
    (Campos que serão exibidos no cabeçalho da rotina)
    @type  Static Function
    @author Thiago Rodrigues
    @since 21/10/2024
/*/
static function PLSCMPDKF(cCampo)
Local lRet := .f.

if alltrim(cCampo) $ 'DKF_IDLICT,DKF_NRLICT,DKF_ANOAB,DKF_CODEDT,DKF_NUMPRO,DKF_DTATUA,DKF_DESMOD'
	lRet := .t.
endif
return lRet


/*/{Protheus.doc} A600VldOk()
    (Pos validação do modelo)
    @type  Static Function
    @author Thiago Rodrigues
    @since 21/10/2024
/*/
Static Function A600VldOk(oModel)
Local lRet		 := .T.
Local aSaveLines := {}
Local nI         := 1
Local oCab       := oModel:GetModel("CABID")
Local oGrid      := oModel:GetModel("GRIDID")
local aAreaTemp  := (cAliasQry)->(GetArea())
local aAuxHelp   := ""

//Valida se todos os produtos foram preenchidos
for nI := 1 to oGrid:Length()
    oGrid:GoLine(nI)
    If Empty(oGrid:GetValue("TMP_CODSB1"))
        oModel:SetErrorMessage (,,,,STR0019,STR0020 + Alltrim(oGrid:GetValue("TMP_IDITEM")),STR0021) //"Não foi informado produto para o item: nnnnn Todos os produtos devem estar preenchidos para prosseguir com a geração do documento. "
        lRet := .F.
        Exit
    else 
        dbSelectArea(cAliasQry)
        DbSetOrder(1)
        if (cAliasQry)->(Msseek(oGrid:GetValue("TMP_CODFOR")+oGrid:GetValue("TMP_LOJFOR")+oGrid:GetValue("TMP_IDITEM")+oGrid:GetValue("TMP_NRLOTE")))
            (cAliasQry)->(RecLock((cAliasQry), .F.)) //Atualiza o produto na tabela temporária
                (cAliasQry)->TMP_CODSB1 := oGrid:GetValue("TMP_CODSB1")
            (cAliasQry)->(MsUnlock())
        endif
    endif
Next nI

//Atualiza o tipo de documento para retornar pra geração do documento
if lRet
    cTpDoc := oCab:GetValue("TMP_TPDOC")
    aAuxHelp := iif(cTpDoc == "1",STR0022,STR0023)

    //Confirma a geração do documento
    if !(lRet := MsgYesNo(STR0024 + aAuxHelp +" ?",STR0019)) //Atenção "Deseja realmente gerar "
        cTpDoc := ""
        oModel:SetErrorMessage (,,,,STR0019,STR0025,"")
    endif

endif

FWRestRows(aSaveLines)
FwFreeArray(aSaveLines)
RestArea(aAreaTemp) 

Return lRet


/*/{Protheus.doc} GcPCarGrid()
    (Carrega os dados da tabela temporária no grid)
    @type  Static Function
    @author Thiago Rodrigues
    @since 21/10/2024
/*/
Static Function GcPCarGrid(oSubModel)
Local aReg  := {}

aReg := FWLoadByAlias(oSubModel,oTabTemp:GetAlias(),oTabTemp:GetRealName())

Return aReg
