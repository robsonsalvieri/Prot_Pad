#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'gtpa904a.ch'
#INCLUDE 'PROTHEUS.CH'

/*/{Protheus.doc} GTPA904A
Teste de tela todas as operações para depois estanciar
@type function
@author kaique.olivero
@since 26/07/2023
/*/
Function GTPA904A()
Local oBrowse  := Nil

oBrowse := FwMBrowse():New()
oBrowse:SetAlias('H6A')
oBrowse:SetDescription('Rateio de Produtos para Clientes') //'Rateio de Produtos para Clientes'
oBrowse:Activate()

Return Nil

//------------------------------------------------------------------------------
/* /{Protheus.doc} ModelDef

Responsável pela definição do modelo de dados

@type Static Function
@author Fernando Radu Muscalu
@since 25/07/2023
@version 1.0
@param  
@return oModel, objeto, instância da classe FWFormModel
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

    Local oModel
    Local oStrH6A   := FwFormStruct(1,"H6A")
    Local oStrH6Q   := FwFormStruct(1,"H6Q")
    
    ModelStruct(@oStrH6A,@oStrH6Q)
    
    oModel := MPFormModel():New('GTPA904A')//, /*bPreValidacao*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/ )

    oModel:AddFields('H6AMASTER',/*cOwner*/,oStrH6A)
    oModel:AddGrid('H6QDETAIL','H6AMASTER',oStrH6Q)
    
    oModel:SetRelation('H6QDETAIL',{{ 'H6Q_FILIAL','xFilial("H6Q")'},{'H6Q_CODH6A','H6A_CODIGO' }},H6Q->(IndexKey(3)))//H6Q_FILIAL+H6Q_CODIGO+H6Q_SEQ+H6Q_PRODUT
    
    oModel:GetModel( 'H6AMASTER' ):SetOnlyQuery(.T.)
    oModel:GetModel( 'H6QDETAIL' ):SetOnlyQuery(.T.)
    oModel:GetModel( 'H6QDETAIL' ):SetOptional(.T.)
    
    oModel:SetDescription(STR0001)//"Consulta de Rateio"
    oModel:SetPrimaryKey({})

Return(oModel)

//------------------------------------------------------------------------------
/* /{Protheus.doc} ViewDef

Responsável pela definição da view do MVC

@type Static Function
@author Fernando Radu Muscalu
@since 25/07/2023
@version 1.0
@param  
@return oView, objeto, instância da classe FWFormView
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

    Local oView		:= FWFormView():New()
    Local oModel	:= FwLoadModel('GTPA904A')
    Local oStrH6A   := FwFormStruct(2,"H6A")
    Local oStrH6Q   := FwFormStruct(2,"H6Q")

    ViewStruct(@oStrH6A,@oStrH6Q)
    
    oView:SetModel(oModel)
    
    oView:AddField('VIEW_H6A',  oStrH6A,    'H6AMASTER')
    oView:AddGrid('VIEW_H6Q',   oStrH6Q,    'H6QDETAIL')
    
    oView:CreateHorizontalBox('UPPER'   , 30)
    oView:CreateHorizontalBox('RATEIO'  , 70)

    oView:SetOwnerView('VIEW_H6A','UPPER')
    oView:SetOwnerView('VIEW_H6Q','RATEIO')
    oView:EnableTitleView("VIEW_H6A", STR0002) //"Informações Fretamento"
    oView:EnableTitleView("VIEW_H6Q", STR0003) //"Rateio de Produtos"
    
    oView:SetDescription(STR0001) //"Consulta de Rateio"
    
Return(oView)

//------------------------------------------------------------------------------
/* /{Protheus.doc} ModelStruct

Responsável pela configuração das estruturas do modelo de dados

@type Static Function
@author Fernando Radu Muscalu
@since 25/07/2023
@version 1.0
@param  oStrH6A, objeto, instância da classe FwFormModelStruct - estrutura de H6A
        oStrH6B, objeto, instância da classe FwFormModelStruct - estrutura de H6B
@return nIL
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function ModelStruct(oStrH6A,oStrH6Q)
Local bIni := {|oMdl,cField| GetInit(oMdl,cField)}

    //H6A,;
    If oStrH6A:HasField("H6A_DESCRI")//H6A->(FIELDPOS("H6A_DESCRI")) > 0
        oStrH6A:SetProperty('H6A_DESCRI', MODEL_FIELD_INIT, bIni )
    EndIf

    oStrH6A:AddField(   GetSx3Cache("G54_NUMGY0","X3_TITULO"),; // 	[01]  C   Titulo do campo 
                        GetSx3Cache("G54_NUMGY0","X3_DESCRIC"),;// 	[02]  C   ToolTip do campo
                        "FAKE_ORCAM",;                          // 	[03]  C   Id do Field
                        GetSx3Cache("G54_NUMGY0","X3_TIPO"),;   // 	[04]  C   Tipo do campo
                        GetSx3Cache("G54_NUMGY0","X3_TAMANHO"),;// 	[05]  N   Tamanho do campo
                        GetSx3Cache("G54_NUMGY0","X3_DECIMAL"),;// 	[06]  N   Decimal do campo
                        {|| .T.},;                              // 	[07]  B   Code-block de validação do campo
                        {|| .T.},;                              // 	[08]  B   Code-block de validação When do campo
                        {},;                                    //	[09]  A   Lista de valores permitido do campo
                        .F.,;                                   //	[10]  L   Indica se o campo tem preenchimento obrigatório
                        bIni,;                                  //	[11]  B   Code-block de inicializacao do campo
                        .F.,;                                   //	[12]  L   Indica se trata-se de um campo chave
                        .F.,;                                   //	[13]  L   Indica se o campo pode receber valor em uma operação de update.
                        .T.)                                    // 	[14]  L   Indica se o campo é virtual
    oStrH6A:AddField(   GetSx3Cache("G54_CODGQR","X3_TITULO"),; // 	[01]  C   Titulo do campo 
                        GetSx3Cache("G54_CODGQR","X3_DESCRIC"),;// 	[02]  C   ToolTip do campo
                        "FAKE_APURA",;                          // 	[03]  C   Id do Field
                        GetSx3Cache("G54_CODGQR","X3_TIPO"),;   // 	[04]  C   Tipo do campo
                        GetSx3Cache("G54_CODGQR","X3_TAMANHO"),;// 	[05]  N   Tamanho do campo
                        GetSx3Cache("G54_CODGQR","X3_DECIMAL"),;// 	[06]  N   Decimal do campo
                        {|| .T.},;                              // 	[07]  B   Code-block de validação do campo
                        {|| .T.},;                              // 	[08]  B   Code-block de validação When do campo
                        {},;                                    //	[09]  A   Lista de valores permitido do campo
                        .F.,;                                   //	[10]  L   Indica se o campo tem preenchimento obrigatório
                        bIni,;                                  //	[11]  B   Code-block de inicializacao do campo
                        .F.,;                                   //	[12]  L   Indica se trata-se de um campo chave
                        .F.,;                                   //	[13]  L   Indica se o campo pode receber valor em uma operação de update.
                        .T.)                                    // 	[14]  L   Indica se o campo é virtual
    oStrH6A:AddField(   GetSx3Cache("G54_CODGI2","X3_TITULO"),; // 	[01]  C   Titulo do campo 
                        GetSx3Cache("G54_CODGI2","X3_DESCRIC"),;// 	[02]  C   ToolTip do campo
                        "FAKE_LINHA",;                          // 	[03]  C   Id do Field
                        GetSx3Cache("G54_CODGI2","X3_TIPO"),;   // 	[04]  C   Tipo do campo
                        GetSx3Cache("G54_CODGI2","X3_TAMANHO"),;// 	[05]  N   Tamanho do campo
                        GetSx3Cache("G54_CODGI2","X3_DECIMAL"),;// 	[06]  N   Decimal do campo
                        {|| .T.},;                              // 	[07]  B   Code-block de validação do campo
                        {|| .T.},;                              // 	[08]  B   Code-block de validação When do campo
                        {},;                                    //	[09]  A   Lista de valores permitido do campo
                        .F.,;                                   //	[10]  L   Indica se o campo tem preenchimento obrigatório
                        bIni,;                                  //	[11]  B   Code-block de inicializacao do campo
                        .F.,;                                   //	[12]  L   Indica se trata-se de um campo chave
                        .F.,;                                   //	[13]  L   Indica se o campo pode receber valor em uma operação de update.
                        .T.)                                    // 	[14]  L   Indica se o campo é virtual
    
    oStrH6A:AddField(   STR0004,;                               // 	[01]  C   Titulo do campo   //"Desc.Linha"
                        STR0005,;                               // 	[02]  C   ToolTip do campo  //"Descrição Linha Gerada"
                        "FAKE_DSCLN",;                          // 	[03]  C   Id do Field
                        "C",;                                   // 	[04]  C   Tipo do campo
                        50,;                                    // 	[05]  N   Tamanho do campo
                        0,;                                     // 	[06]  N   Decimal do campo
                        {|| .T.},;                              // 	[07]  B   Code-block de validação do campo
                        {|| .T.},;                              // 	[08]  B   Code-block de validação When do campo
                        {},;                                    //	[09]  A   Lista de valores permitido do campo
                        .F.,;                                   //	[10]  L   Indica se o campo tem preenchimento obrigatório
                        bIni,;                                  //	[11]  B   Code-block de inicializacao do campo
                        .F.,;                                   //	[12]  L   Indica se trata-se de um campo chave
                        .F.,;                                   //	[13]  L   Indica se o campo pode receber valor em uma operação de update.
                        .T.)                                    // 	[14]  L   Indica se o campo é virtual
    //----------------------------------------------------------------------------------------------------------------------------------------------------
    //H6Q
    oStrH6Q:AddField(   STR0006,;                   // 	[01]  C   Titulo do campo   //"Total" 
                        STR0006,;                   // 	[02]  C   ToolTip do campo  //"Total"
                        "FAKE_TOTAL",;              // 	[03]  C   Id do Field
                        "N",;                       // 	[04]  C   Tipo do campo
                        16,;                        // 	[05]  N   Tamanho do campo
                        2,;                         // 	[06]  N   Decimal do campo
                        {|| .T.},;                  // 	[07]  B   Code-block de validação do campo
                        {|| .T.},;                  // 	[08]  B   Code-block de validação When do campo
                        {},;                        //	[09]  A   Lista de valores permitido do campo
                        .F.,;                       //	[10]  L   Indica se o campo tem preenchimento obrigatório
                        bIni,;                      //	[11]  B   Code-block de inicializacao do campo
                        .F.,;                       //	[12]  L   Indica se trata-se de um campo chave
                        .F.,;                       //	[13]  L   Indica se o campo pode receber valor em uma operação de update.
                        .T.)                        // 	[14]  L   Indica se o campo é virtual

    If oStrH6Q:HasField("H6Q_PRODES")
        oStrH6Q:SetProperty('H6Q_PRODES', MODEL_FIELD_INIT, bIni )
    EndIf

Return()

//------------------------------------------------------------------------------
/* /{Protheus.doc} ViewStruct

Responsável pela configuração das estruturas da View do MVC

@type Static Function
@author Fernando Radu Muscalu
@since 25/07/2023
@version 1.0
@param  oStrH6A, objeto, instância da classe FwFormViewStruct - estrutura de H6A
        oStrH6B, objeto, instância da classe FwFormViewStruct - estrutura de H6B
@return nIL
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function ViewStruct(oStrH6A,oStrH6Q)
    oStrH6A:RemoveField("H6A_FILIAL")
    oStrH6A:RemoveField("H6A_STATUS")
    oStrH6Q:RemoveField('H6Q_CODIGO')
    oStrH6Q:RemoveField('H6Q_CODH6A')

    //H6A
    //--------------------------------------------------------------------------------------------------------------------------
    oStrH6A:AddField(  "FAKE_ORCAM",;                               // [01]  C   Nome do Campo
                        "90",;                                      // [02]  C   Ordem
                        GetSx3Cache("G54_NUMGY0","X3_TITULO"),;     // [03]  C   Titulo do campo
                        GetSx3Cache("G54_NUMGY0","X3_DESCRIC"),;    // [04]  C   Descricao do campo
                        {GetSx3Cache("G54_NUMGY0","X3_DESCRIC")},;  // [05]  A   Array com Help
                        "GET",;                                     // [06]  C   Tipo do campo
                        "@!",;                                      // [07]  C   Picture
                        NIL,;                                       // [08]  B   Bloco de Picture Var
                        "",;                                        // [09]  C   Consulta F3
                        .T.,;                                       // [10]  L   Indica se o campo é alteravel
                        NIL,;                                       // [11]  C   Pasta do campo
                        NIL,;                                       // [12]  C   Agrupamento do campo
                        {},;                                        // [13]  A   Lista de valores permitido do campo (Combo)
                        NIL,;                                       // [14]  N   Tamanho maximo da maior opção do combo
                        NIL,;                                       // [15]  C   Inicializador de Browse
                        .T.,;                                       // [16]  L   Indica se o campo é virtual    
                        Nil,;                                       // [17]  C   Picture Variavel
                        Nil)                                        // [18]  L   Indica pulo de linha após o campo

    oStrH6A:AddField(  "FAKE_APURA",;                               // [01]  C   Nome do Campo
                        "91",;                                      // [02]  C   Ordem
                        GetSx3Cache("G54_CODGQR","X3_TITULO"),;     // [03]  C   Titulo do campo
                        GetSx3Cache("G54_CODGQR","X3_DESCRIC"),;    // [04]  C   Descricao do campo
                        {GetSx3Cache("G54_CODGQR","X3_DESCRIC")},;  // [05]  A   Array com Help
                        "GET",;                                     // [06]  C   Tipo do campo
                        "@!",;                                      // [07]  C   Picture
                        NIL,;                                       // [08]  B   Bloco de Picture Var
                        "",;                                        // [09]  C   Consulta F3
                        .T.,;                                       // [10]  L   Indica se o campo é alteravel
                        NIL,;                                       // [11]  C   Pasta do campo
                        NIL,;                                       // [12]  C   Agrupamento do campo
                        {},;                                        // [13]  A   Lista de valores permitido do campo (Combo)
                        NIL,;                                       // [14]  N   Tamanho maximo da maior opção do combo
                        NIL,;                                       // [15]  C   Inicializador de Browse
                        .T.,;                                       // [16]  L   Indica se o campo é virtual    
                        Nil,;                                       // [17]  C   Picture Variavel
                        Nil)                                        // [18]  L   Indica pulo de linha após o campo

    oStrH6A:AddField(  "FAKE_LINHA",;                               // [01]  C   Nome do Campo
                        "92",;                                      // [02]  C   Ordem
                        GetSx3Cache("G54_CODGI2","X3_TITULO"),;     // [03]  C   Titulo do campo
                        GetSx3Cache("G54_CODGI2","X3_DESCRIC"),;    // [04]  C   Descricao do campo
                        {GetSx3Cache("G54_CODGI2","X3_DESCRIC")},;  // [05]  A   Array com Help
                        "GET",;                                     // [06]  C   Tipo do campo
                        "@!",;                                      // [07]  C   Picture
                        NIL,;                                       // [08]  B   Bloco de Picture Var
                        "",;                                        // [09]  C   Consulta F3
                        .T.,;                                       // [10]  L   Indica se o campo é alteravel
                        NIL,;                                       // [11]  C   Pasta do campo
                        NIL,;                                       // [12]  C   Agrupamento do campo
                        {},;                                        // [13]  A   Lista de valores permitido do campo (Combo)
                        NIL,;                                       // [14]  N   Tamanho maximo da maior opção do combo
                        NIL,;                                       // [15]  C   Inicializador de Browse
                        .T.,;                                       // [16]  L   Indica se o campo é virtual    
                        Nil,;                                       // [17]  C   Picture Variavel
                        Nil)                                        // [18]  L   Indica pulo de linha após o campo

    oStrH6A:AddField(  "FAKE_DSCLN",;                               // [01]  C   Nome do Campo
                        "93",;                                      // [02]  C   Ordem
                        STR0004,;                                   // [03]  C   Titulo do campo    //"Desc.Linha"
                        STR0005,;                                   // [04]  C   Descricao do campo //"Descrição Linha Gerada"
                        {STR0005},;                                 // [05]  A   Array com Help     //"Descrição Linha Gerada"
                        "GET",;                                     // [06]  C   Tipo do campo
                        "@!",;                                      // [07]  C   Picture
                        NIL,;                                       // [08]  B   Bloco de Picture Var
                        "",;                                        // [09]  C   Consulta F3
                        .T.,;                                       // [10]  L   Indica se o campo é alteravel
                        NIL,;                                       // [11]  C   Pasta do campo
                        NIL,;                                       // [12]  C   Agrupamento do campo
                        {},;                                        // [13]  A   Lista de valores permitido do campo (Combo)
                        NIL,;                                       // [14]  N   Tamanho maximo da maior opção do combo
                        NIL,;                                       // [15]  C   Inicializador de Browse
                        .T.,;                                       // [16]  L   Indica se o campo é virtual    
                        Nil,;                                       // [17]  C   Picture Variavel
                        Nil)                                        // [18]  L   Indica pulo de linha após o campo
    
    //H6Q
    //--------------------------------------------------------------------------------------------------------------------------
    oStrH6Q:AddField(  "FAKE_TOTAL",;                       // [01]  C   Nome do Campo
                        "99",;                              // [02]  C   Ordem
                        STR0006,;                           // [03]  C   Titulo do campo    //"Total"
                        STR0007,;                           // [04]  C   Descricao do campo //"Total Rateio"
                        {STR0008},;                         // [05]  A   Array com Help     //"Total rateado para produto"
                        "GET",;                             // [06]  C   Tipo do campo
                        "@e 9,999,999,999.99",;             // [07]  C   Picture
                        NIL,;                               // [08]  B   Bloco de Picture Var
                        "",;                                // [09]  C   Consulta F3
                        .T.,;                               // [10]  L   Indica se o campo é alteravel
                        NIL,;                               // [11]  C   Pasta do campo
                        NIL,;                               // [12]  C   Agrupamento do campo
                        {},;                                // [13]  A   Lista de valores permitido do campo (Combo)
                        NIL,;                               // [14]  N   Tamanho maximo da maior opção do combo
                        NIL,;                               // [15]  C   Inicializador de Browse
                        .T.,;                               // [16]  L   Indica se o campo é virtual    
                        Nil,;                               // [17]  C   Picture Variavel
                        Nil)                                // [18]  L   Indica pulo de linha após o campo
Return()

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetInit()
Monta o init dos campos 
@sample	GetInit() 
@return	xRet - Informação da inicialização do campo 
@since	27/07/2023
/*/
//------------------------------------------------------------------------------------------
Static Function GetInit(oMdl,cCamp)

Local lOrc  := FwIsInCallStack("G900Rateio")    //Orçamento 
Local lApu  := FwIsInCallStack("G903Rateio")    //Apuração
Local xRet  := Nil

If cCamp == "H6A_DESCRI"

    If lOrc
        xRet := GetMdlInit("GYD_NOMCLI","1")
    ElseIf lApu
        xRet := GetMdlInit("G54_NOMECL","2")
    Endif

Elseif cCamp == "FAKE_ORCAM"
    
    If lOrc
        xRet := GetMdlInit("GY0_NUMERO","1")
    ElseIf lApu
        xRet := GetMdlInit("G54_NUMGY0","2")
    Endif

Elseif cCamp == "FAKE_APURA"

    xRet := IIf(lApu,GetMdlInit("GQR_CODIGO","2"),"")

Elseif cCamp == "FAKE_LINHA"
    
    If lOrc
        xRet := GetMdlInit("GYD_CODGI2","1")
    ElseIf lApu
        xRet := GetMdlInit("G54_CODGI2","2")
    Endif

Elseif cCamp == "FAKE_DSCLN"
    
    xRet := GetMdlInit("FAKE_DSCLN",IIf(lOrc,"1","2"))
    
Elseif cCamp == "H6Q_PRODES"

    xRet := Posicione('SB1',1,xFilial('SB1') + H6Q->H6Q_PRODUT,'B1_DESC')

Elseif cCamp == "FAKE_TOTAL"
   
   If lOrc
        xRet := GetMdlInit("GYD_VLRTOT","1")
    ElseIf lApu
        xRet := GetMdlInit("G54_TOTAL","2")
    Endif

Endif

Return xRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetMdlInit()
Função auxiliar para retornar o valor do campo inicializado.
@sample	GetMdlInit() 
@return	xRet - Informação da inicialização do campo 
@since	27/07/2023
/*/
//------------------------------------------------------------------------------------------
Static Function GetMdlInit(cCmpTbl,cTipMdl)

    Local xRet := Nil

    Default cTipMdl := "1"

    If cTipMdl == "1"
        xRet := Orcamento(cCmpTbl)
    Else
        xRet := Apuracao(cCmpTbl)
    Endif

Return xRet

Static Function Orcamento(cCmpTbl)
    
    Local oModel    := IIf(G900IsActive(),G900Modelo(),Nil)
    Local xRet      := Nil

    If (ValType(oModel) == "O" )

        If cCmpTbl == "GYD_NOMCLI" //Nome do Cliente - Orçamento
            xRet := oModel:GetModel("GYDDETAIL"):GetValue(cCmpTbl)
            If Empty(xRet)
                xRet := oModel:GetModel("GY0MASTER"):GetValue("GY0_NOMCLI")
            Endif
        ElseIf cCmpTbl == "GY0_NUMERO" //Cod Orçamento - Orçamento
            xRet := oModel:GetModel("GY0MASTER"):GetValue(cCmpTbl)
        ElseIf cCmpTbl == "GYD_CODGI2" //Coddigo da linha - Orçamento
            xRet := oModel:GetModel("GYDDETAIL"):GetValue(cCmpTbl)
        ElseIf cCmpTbl == "FAKE_DSCLN" //Descrição da linha - Orçamento
            xRet := TPNomeLinh(oModel:GetModel("GYDDETAIL"):GetValue("GYD_CODGI2"))
        Elseif cCmpTbl == "GYD_VLRTOT" //Total da linha - Orçamento
            xRet := (H6Q->H6Q_RATEIO/100) * oModel:GetModel("GYDDETAIL"):GetValue(cCmpTbl)
        Endif
    Endif

Return xRet

Static Function Apuracao(cCmpTbl)
    
    Local oModel := IIf(G903IsActive(),G903Modelo(),Nil)
    
    Local xRet := Nil

    If (ValType(oModel) == "O" )

        If cCmpTbl == "G54_NOMECL" //Nome do Cliente - Orçamento
            xRet := oModel:GetModel("G54DETAIL"):GetValue(cCmpTbl)
        ElseIf cCmpTbl == "GQR_CODIGO" //Cod Orçamento - Orçamento
            xRet := oModel:GetModel("GQRMASTER"):GetValue(cCmpTbl)
        ElseIf cCmpTbl == "G54_NUMGY0" //Cod Orçamento - Orçamento
            xRet := oModel:GetModel("G54DETAIL"):GetValue(cCmpTbl)
        ElseIf cCmpTbl == "G54_CODGI2" //Coddigo da linha - Orçamento
            xRet := oModel:GetModel("G54DETAIL"):GetValue(cCmpTbl)
        ElseIf cCmpTbl == "FAKE_DSCLN" //Descrição da linha - Orçamento
            xRet := TPNomeLinh(oModel:GetModel("G54DETAIL"):GetValue("G54_CODGI2"))
        Elseif cCmpTbl == "G54_TOTAL" //Total da linha - Orçamento
            xRet := (H6Q->H6Q_RATEIO/100) * oModel:GetModel("G54DETAIL"):GetValue(cCmpTbl)
        Endif
    Endif
    
Return xRet
