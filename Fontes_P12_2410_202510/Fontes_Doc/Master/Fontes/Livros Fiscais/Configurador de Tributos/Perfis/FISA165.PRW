#Include "FISA165.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

Static lF23Tipo := F23->(Fieldpos("F23_TIPOPF")) > 0
Static lF26Tipo := F26->(Fieldpos("F26_TIPOPF")) > 0
Static lCIOTipo := Iif(AliasIndic("CIO"),CIO->(Fieldpos("CIO_TIPOPF")) > 0, .F.)
Static lPassou  := .F.
Static lAutomato := IsBlind()
Static oJCFOP := JsonObject():New()
STATIC lDadosAd := AliasIndic("CK2") .And. AliasIndic("CK4")
STATIC cConsultP := ''

PUBLISH MODEL REST NAME FISA165

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA165()

Cadastro do perfil tributário de operação - Gerador de Fundos.

@author joao.pellegrini
@since 19/06/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FISA165()

Local oBrowse := Nil

If AliasIndic("F20") .And. AliasIndic("F23")
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("F20")
    oBrowse:SetDescription(STR0001) //'Cadastro de Perfil Tributário de Operação'
    oBrowse:SetFilterDefault("F20_FILIAL == " + ValToSql(xFilial("F20")) + " .And. " + "F20_TIPO == '03'")
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0002,1,0)  //"Dicionário Desatualizado. Verifique as atualizações do motor de tributos."
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao generica MVC com as opcoes de menu

@author joao.pellegrini
@since 19/06/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------

Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.FISA165' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.FISA165' OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.FISA165' OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.FISA165' OPERATION 5 ACCESS 0 //'Excluir'
ADD OPTION aRotina TITLE 'Copiar'     ACTION 'VIEWDEF.FISA165' OPERATION 9 ACCESS 0 //'Copiar'

If FindFunction("FSA171WIZ")
    ADD OPTION aRotina TITLE 'Facilitador'  ACTION 'FSA171WIZ("1","03")' OPERATION 4 ACCESS 0 //'Facilitador'
EndIF

Return aRotina
//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef

Funcao generica MVC do model

@author joao.pellegrini
@since 19/06/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

//Criação do objeto do modelo de dados
Local oModel := Nil

//Estrutura Pai corresponndente a tabela de Perfil Tributário - F20
Local oCabecalho := FWFormStruct(1, "F20")

//Estrutura Filho correspondente a tabela de Perfil Tributário de Operação - F23
Local oCFOP := FWFormStruct(1, "F23")

//Estrutura Filho correspondente a tabela de Tipo de Operação - F26
Local oTpOper := FWFormStruct(1, "F26")

//Estrutura Filho correspondente a tabela de Código de Serviços - CIO
Local oCdServ := Nil
Local lAliasCIO := AliasInDic("CIO")

//Estrutura Filho correspondente a tabela de Dados Adicionais - CK4
Local oDadosAd  := nil

//Instanciando o modelo
oModel := MPFormModel():New('FISA165',{|oModel|CargaTpOper(oModel)},{ |oModel| Fisa165POS( oModel ) })

//Atribuindo estruturas para o modelo
oModel:AddFields("FISA165",, oCabecalho)

//Adiciona o Grid ao modelo
oModel:AddGrid('FISA165CFOP', 'FISA165', oCFOP)
//oModel:GetModel('FISA165CFOP'):SetUseOldGrid()

//Adiciona o grid do tipo de operação
oModel:AddGrid('FISA165TPOPER', 'FISA165', oTpOper,,,,{|oTpOper| ValidDel(oTpOper,1)})

//Adiciona o grid do código de serviços
If lAliasCIO
    oCdServ := FWFormStruct(1, "CIO")

    oModel:AddGrid('FISA165CDSERV', 'FISA165', oCdServ,,,,{|oCdServ| ValidDel(oCdServ,2)})
    
    //Torna o grid do código de serviço opicional.
    oModel:GetModel( 'FISA165CDSERV' ):SetOptional( .T. )

    //Define para não repetir o Código de Serviço
    oModel:GetModel('FISA165CDSERV'):SetUniqueLine({'CIO_CODISS'})
    oModel:GetModel('FISA165CDSERV'):SetMaxLine(9999)

    IF lCIOTipo
        oCdServ:SetProperty('CIO_TIPOPF' , MODEL_FIELD_INIT ,{||"03"} )
    Endif
    
    //Verifica se houve alteração da consulta padrão do campo pelo usuário admin do ERP para desativar a validação
    If Alltrim(GetSx3Cache('CIO_CODISS','X3_F3')) <> "60"
        oCdServ:SetProperty('CIO_CODISS' , MODEL_FIELD_VALID ,{|| (.T.) } )
    EndIf

    //Relacionamento entre as tabelas F20 Perfil com CIO código de serviço
    oModel:SetRelation( 'FISA165CDSERV', { { 'CIO_FILIAL', 'xFilial("CIO")' }, { 'CIO_CODIGO', 'F20_CODIGO' }, {'03','F20_TIPO'} }, CIO->( IndexKey( 1 ) ) )
EndIf

//Adiciona secao dos dados adicionais
if lDadosAd
    oDadosAd := FWFormStruct(1,"CK4")
    
    oDadosAd:RemoveField("CK4_FILIAL")
    oDadosAd:RemoveField("CK4_CONTEU")
    oDadosAd:RemoveField("CK4_CODF20")

    // Campos auxiliares para preecher o dados adicionais, mas que nao são persistidos no banco de dados:
    oDadosAd:AddField( ; // Ord. Tipo Desc.
    AllTrim( "Código do Dado Adicional" ) , ; // [01] C Titulo do campo
    AllTrim( "Código do Dado Adicional" ) , ; // [02] C ToolTip do campo
    'CK4_COD' , ; // [03] C identificador (ID) do  Field
    'C' , ; // [04] C Tipo do campo
    10 , ; // [05] N Tamanho do campo
    0 , ; // [06] N Decimal do campo
    NIL , ; // [07] B Code-block de validação do campo
    NIL , ; // [08] B Code-block de  validação When do campo
    NIL , ; // [09] A Lista de valores   permitido do campo
    .F. , ; // [10] L Indica se o campo tem preenchimento obrigatório
    NIL , ; // [11] BCode-block de inicializacao do campo
    NIL , ; // [12] L Indica se trata de um     campo chave
    NIL , ; // [13] L Indica se o campo pode receber valor em uma operação de update.
    .T. ) // [14] L Indica se o campo é virtual
    
    // Campos auxiliares para preecher o dados adicionais, mas que nao são persistidos no banco de dados:
    oDadosAd:AddField( ; // Ord. Tipo Desc.
    AllTrim( STR0071 ) , ; // [01] C Titulo do campo
    AllTrim( STR0071 ) , ; // [02] C ToolTip do campo
    'CK4_VALOR' , ; // [03] C identificador (ID) do  Field
    'C' , ; // [04] C Tipo do campo
    100 , ; // [05] N Tamanho do campo
    0 , ; // [06] N Decimal do campo
    NIL , ; // [07] B Code-block de validação do campo
    NIL , ; // [08] B Code-block de  validação When do campo
    NIL , ; // [09] A Lista de valores   permitido do campo
    .F. , ; // [10] L Indica se o campo tem preenchimento obrigatório
    NIL , ; // [11] BCode-block de inicializacao do campo
    NIL , ; // [12] L Indica se trata de um     campo chave
    NIL , ; // [13] L Indica se o campo pode receber valor em uma operação de update.
    .T. ) // [14] L Indica se o campo é virtual

    oDadosAd:AddField( ; // Ord. Tipo Desc.
    AllTrim( STR0072 ) , ; // [01] C Titulo do campo
    AllTrim( STR0072 ) , ; // [02] C ToolTip do campo
    'CK4_VALORSXB' , ; // [03] C identificador (ID) do  Field
    'C' , ; // [04] C Tipo do campo
    100 , ; // [05] N Tamanho do campo
    0 , ; // [06] N Decimal do campo
    NIL , ; // [07] B Code-block de validação do campo
    NIL , ; // [08] B Code-block de  validação When do campo
    NIL , ; // [09] A Lista de valores   permitido do campo
    .F. , ; // [10] L Indica se o campo tem preenchimento obrigatório
    NIL , ; // [11] BCode-block de inicializacao do campo
    NIL , ; // [12] L Indica se trata de um     campo chave
    NIL , ; // [13] L Indica se o campo pode receber valor em uma operação de update.
    .T. ) // [14] L Indica se o campo é virtual

    oDadosAd:AddField( ; // Ord. Tipo Desc.
    AllTrim( STR0073 ) , ; // [01] C Titulo do campo
    AllTrim( STR0073 ) , ; // [02] C ToolTip do campo
    'CK4_MEMO' , ; // [03] C identificador (ID) do  Field
    'M' , ; // [04] C Tipo do campo
    1000 , ; // [05] N Tamanho do campo
    0 , ; // [06] N Decimal do campo
    NIL , ; // [07] B Code-block de validação do campo
    NIL , ; // [08] B Code-block de  validação When do campo
    NIL , ; // [09] A Lista de valores   permitido do campo
    .F. , ; // [10] L Indica se o campo tem preenchimento obrigatório
    FwBuildFeature( STRUCT_FEATURE_INIPAD,'GetCK4()'), ; // [11] BCode-block de inicializacao do campo
    NIL , ; // [12] L Indica se trata de um     campo chave
    NIL , ; // [13] L Indica se o campo pode receber valor em uma operação de update.
    .T. ) // [14] L Indica se o campo é virtual

    oDadosAd:SetProperty('CK4_VALOR'    , MODEL_FIELD_WHEN, {|| !EmpTy( AllTrim(oModel:GetValue('DADOSADD',"CK4_COD")) ) .and. Empty(cConsultP) })
    oDadosAd:SetProperty('CK4_VALORSXB' , MODEL_FIELD_WHEN, {|| !EmpTy( AllTrim(oModel:GetValue('DADOSADD',"CK4_COD")) ) .and. !Empty(cConsultP) })
    oDadosAd:SetProperty('CK4_DESCRI'   , MODEL_FIELD_WHEN, {|| .F. })
    oDadosAd:SetProperty('CK4_COD'      , MODEL_FIELD_WHEN, {|| AtivaDadosAd(oModel) })
    oDadosAd:SetProperty('CK4_MEMO'     , MODEL_FIELD_WHEN, {|| AtivaDadosAd(oModel) })
    oDadosAd:SetProperty('CK4_MEMO'     , MODEL_FIELD_VALID, {||( validAddic( AllTrim(oModel:GetValue('DADOSADD',"CK4_MEMO")) , oModel:GetOperation() )) })
    oDadosAd:SetProperty('CK4_CODIGO'   , MODEL_FIELD_OBRIGAT, .F. )    
endif

//Grid não pode ser vazio...
oModel:GetModel('FISA165CFOP'):SetOptional(.F.)

//Inicializa o campo F20_TIPO com conteúdo "03" que significa tipo de perfil de Operação.
oCabecalho:SetProperty('F20_TIPO', MODEL_FIELD_INIT , {||"03"})

IF lF23Tipo
    oCFOP:SetProperty('F23_TIPOPF' , MODEL_FIELD_INIT ,{||"03"} )
Endif

IF lF26Tipo
    oTpOper:SetProperty('F26_TIPOPF' , MODEL_FIELD_INIT ,{||"03"} )
Endif

If lDadosAd
    oModel:AddFields("DADOSADD", "FISA165", oDadosAd)
    oModel:SetRelation( 'DADOSADD', {{'CK4_FILIAL', 'xFilial("CK4")'},{'CK4_CODF20', 'F20_CODIGO'},{'03','F20_TIPO'} }, CK4->( IndexKey(1) ))
    oModel:GetModel("DADOSADD"):SetOnlyQuery()
EndIf

//Não permite alterar o conteúdo do campo F20_CODIGO na edição
oCabecalho:SetProperty('F20_CODIGO', MODEL_FIELD_WHEN, {|| (oModel:GetOperation() == MODEL_OPERATION_INSERT)})

//Validação para não permitir informar código de perfil + tipo de perfil duplicado
oCabecalho:SetProperty('F20_CODIGO' , MODEL_FIELD_VALID, {||( VldPerfil(oModel, 'FISA165', '03') )})

oTpOper:SetProperty('F26_CODIGO'  , MODEL_FIELD_OBRIGAT,  .F. )

//Torna o grid do tipo de operação opicional.
oModel:GetModel( 'FISA165TPOPER' ):SetOptional( .T. )

//Define para não repetir o CFOP
oModel:GetModel('FISA165CFOP'):SetUniqueLine({'F23_CFOP'})
oModel:GetModel('FISA165CFOP'):SetMaxLine(1500)

//Define o valor maximo de linhas do grid
oModel:GetModel('FISA165CFOP'):SetMaxLine(9999999)

//Não permite repetir o tipo de operação
oModel:GetModel('FISA165TPOPER'):SetUniqueLine({'F26_TPOPER'})

//Define o valor maximo de linhas do grid
oModel:GetModel('FISA165TPOPER'):SetMaxLine(9999999)

//Relacionamento entre as tabelas F20 Perfil com F23 Perfil de operação
oModel:SetRelation('FISA165CFOP', {{'F23_FILIAL', 'xFilial("F23")'}, {'F23_CODIGO', 'F20_CODIGO'}, {'03', 'F20_TIPO'}}, F23->(IndexKey(1)))

//Relacionamento entre as tabelas F20 Perfil com F26 Tipo de operação
oModel:SetRelation( 'FISA165TPOPER', { { 'F26_FILIAL', 'xFilial("F26")' }, { 'F26_CODIGO', 'F20_CODIGO' }, {'03','F20_TIPO'} }, F26->( IndexKey( 1 ) ) )

//Adicionando descrição ao modelo
oModel:SetDescription(STR0001) //'Cadastro de Perfil Tributário de Operação'

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@author joao.pellegrini
@since 19/06/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Criação do objeto do modelo de dados da Interface do Cadastro
Local oModel := FWLoadModel("FISA165")

//Criação da estrutura de dados utilizada na interface do cadastro
Local oCabecalho := FWFormStruct(2, "F20")
Local oCFOP      := FWFormStruct(2, "F23")
Local oTpOper    := FWFormStruct(2, "F26")
Local oCdServ    := Nil
Local oView      := Nil
Local lAliasCIO  := AliasInDic("CIO")
Local oDadosAdd   := Nil

If lDadosAd
    oDadosAdd  := FWFormStruct(2, "CK4")    
Endif

oView := FWFormView():New()
oView:SetModel(oModel)

//Atribuindo formulários para interface
oView:AddField('VIEW_PERFIL', oCabecalho, 'FISA165')
oView:AddGrid('VIEW_CFOP'   , oCFOP     , 'FISA165CFOP')
oView:AddGrid('VIEW_TPOPER' , oTpOper   , 'FISA165TPOPER')

If lDadosAd
    oView:AddField( 'VIEW_DADOSADD' , oDadosAdd, 'DADOSADD')
EndIf

//Habilitando opções de filtros 
oView:SetViewProperty('VIEW_CFOP', "GRIDFILTER", {.T.})
oView:SetViewProperty('VIEW_CFOP', "GRIDSEEK", {.T.})
oView:SetViewProperty('VIEW_TPOPER', "GRIDFILTER", {.T.})
oView:SetViewProperty('VIEW_TPOPER', "GRIDSEEK", {.T.})

//Retira da view os campos de ID
oCabecalho:RemoveField('F20_TIPO')
oCFOP:RemoveField('F23_CODIGO')
oTpOper:RemoveField( 'F26_CODIGO')

IF lF23Tipo
    oCFOP:RemoveField('F23_TIPOPF')
Endif

IF lF26Tipo
    oTpOper:RemoveField('F26_TIPOPF')
Endif

If !lAliasCIO
    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox('SUPERIOR', 20)
    oView:CreateHorizontalBox('MEDIO',    40)
    oView:CreateHorizontalBox('INFERIOR', 40)

    //O formulário da interface será colocado dentro do container
    oView:SetOwnerView('VIEW_PERFIL', 'SUPERIOR')
    oView:SetOwnerView('VIEW_CFOP', 'MEDIO')
    oView:SetOwnerView('VIEW_TPOPER', 'INFERIOR')

Else
    //Estrutura em Folder
    //Criação da estrutura de dados utilizada na interface do cadastro
    oCdServ    := FWFormStruct(2, "CIO")
    
    //Atribuindo formulários para interface
    oView:AddGrid('VIEW_CDSERV' , oCdServ   , 'FISA165CDSERV')
    
    //Habilitando opções de filtros 
    oView:SetViewProperty('VIEW_CDSERV', "GRIDFILTER", {.T.})
    oView:SetViewProperty('VIEW_CDSERV', "GRIDSEEK", {.T.})
    
    //Retira da view os campos
    oCdServ:RemoveField( 'CIO_CODIGO')

    IF lCIOTipo
        oCdServ:RemoveField('CIO_TIPOPF')
    Endif

    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox('SUPERIOR', 20)
    oView:CreateHorizontalBox('MEDIO',    80)

    //Cria um folder
    oView:CreateFolder( 'FOLDER_GERAL', 'MEDIO' )

    //Cria dois Sheets no folder inferior
    oView:AddSheet( 'FOLDER_GERAL', 'ABA_CFOP'      , STR0004 ) //"CFOP'S"
    oView:AddSheet( 'FOLDER_GERAL', 'ABA_TPOPER'    , STR0056 ) //"Tipo de operação"
    oView:AddSheet( 'FOLDER_GERAL', 'ABA_CODSERV'   , STR0057 ) //"Código de Serviço"

    If lDadosAd
        oView:AddSheet( 'FOLDER_GERAL', 'ABA_DADOSAD'   , STR0080 ) //"Dados Adicionais de Operação"
    EndIf

    //Cria box da aba de Principais
    oView:CreateHorizontalBox( 'PAINEL_CFOP'    , 100,,, 'FOLDER_GERAL', 'ABA_CFOP'     )
    oView:CreateHorizontalBox( 'PAINEL_TPOPER'  , 100,,, 'FOLDER_GERAL', 'ABA_TPOPER'   )
    oView:CreateHorizontalBox( 'PAINEL_CODSERV' , 100,,, 'FOLDER_GERAL', 'ABA_CODSERV'  )

    If lDadosAd
        oView:CreateHorizontalBox( 'PAINEL_DADOSAD' , 70,,, 'FOLDER_GERAL', 'ABA_DADOSAD'  )
        oView:CreateHorizontalBox( 'BOTOES_DADOSAD' , 30,,, 'FOLDER_GERAL', 'ABA_DADOSAD'  )
    EndIf

    //Faz vínculo do box com a view
    oView:SetOwnerView( 'VIEW_PERFIL'      , 'SUPERIOR'    )

    //Seta a View com seu respectivo Owner
    oView:SetOwnerView( 'VIEW_CFOP'      , 'PAINEL_CFOP'    )
    oView:SetOwnerView( 'VIEW_TPOPER'    , 'PAINEL_TPOPER'  )
    oView:SetOwnerView( 'VIEW_CDSERV'    , 'PAINEL_CODSERV' )

    If lDadosAd
        oView:SetOwnerView( 'VIEW_DADOSADD'  , 'PAINEL_DADOSAD' )
    EndIf

    oView:EnableTitleView('VIEW_CDSERV', STR0057) //"Código de Serviço"

    If lDadosAd
        // Alteracoes de alguns campos da CK4
        oDadosAdd:RemoveField("CK4_FILIAL")
        oDadosAdd:RemoveField("CK4_CODIGO")
        oDadosAdd:RemoveField("CK4_CONTEU")

        oDadosAdd:SetProperty("CK4_DESCRI", MVC_VIEW_TITULO, STR0075 )//"Descrição do Dado Adicional"    
        oDadosAdd:SetProperty("CK4_DESCRI" , MVC_VIEW_ORDEM  , "2")

        oDadosAdd:AddField( ; // Ord. Tipo Desc.
        'CK4_COD' , ; // [01] C Nome do Campo
        '1' , ; // [02] C Ordem
        AllTrim( STR0074 ) , ; // [03] C Titulo do campo
        AllTrim( STR0074 ) , ; // [04] C Descrição do campo
        { STR0074 } , ; // [05] A Array com Help
        'C' , ; // [06] C Tipo do campo
        '@!' , ; // [07] C Picture
        NIL , ; // [08] B Bloco de Picture Var
        'CK22' , ; // [09] C Consulta F3
        .T. , ; // [10] L Indica se o campo é evitável
        NIL , ; // [11] C Pasta do campo
        NIL , ; // [12] C Agrupamento do campo
        NIL , ; // [13] A Lista de valores permitido do campo (Combo)
        NIL , ; // [14] N Tamanho Máximo da maior opção do combo
        NIL , ; // [15] C Inicializador de Browse
        .T. , ; // [16] L Indica se o campo é virtual
        NIL ) // [17] C Picture Variável

        oDadosAdd:AddField( ; // Ord. Tipo Desc.
        'CK4_VALOR' , ; // [01] C Nome do Campo
        '3' , ; // [02] C Ordem
        AllTrim( STR0071 ) , ; // [03] C Titulo do campo
        AllTrim( STR0071 ) , ; // [04] C Descrição do campo
        { STR0071 } , ; // [05] A Array com Help
        'C' , ; // [06] C Tipo do campo
        '@!' , ; // [07] C Picture
        NIL , ; // [08] B Bloco de Picture Var
        'SB1' , ; // [09] C Consulta F3
        .T. , ; // [10] L Indica se o campo é evitável
        NIL , ; // [11] C Pasta do campo
        NIL , ; // [12] C Agrupamento do campo
        {'','1=Sim','2=Não'} , ; // [13] A Lista de valores permitido do campo (Combo)
        NIL , ; // [14] N Tamanho Máximo da maior opção do combo
        NIL , ; // [15] C Inicializador de Browse
        .T. , ; // [16] L Indica se o campo é virtual
        NIL ) // [17] C Picture Variável

        oDadosAdd:AddField( ; // Ord. Tipo Desc.
        'CK4_VALORSXB' , ; // [01] C Nome do Campo
        '4' , ; // [02] C Ordem
        AllTrim( STR0072 ) , ; // [03] C Titulo do campo
        AllTrim( STR0072 ) , ; // [04] C Descrição do campo
        { STR0072 } , ; // [05] A Array com Help
        'C' , ; // [06] C Tipo do campo
        '@!' , ; // [07] C Picture
        NIL , ; // [08] B Bloco de Picture Var
        'CK2' , ; // [09] C Consulta F3
        .T. , ; // [10] L Indica se o campo é evitável
        NIL , ; // [11] C Pasta do campo
        NIL , ; // [12] C Agrupamento do campo
        NIL , ; // [13] A Lista de valores permitido do campo (Combo)
        NIL , ; // [14] N Tamanho Máximo da maior opção do combo
        NIL , ; // [15] C Inicializador de Browse
        .T. , ; // [16] L Indica se o campo é virtual
        NIL ) // [17] C Picture Variável

        oDadosAdd:AddField( ; // Ord. Tipo Desc.
        'CK4_MEMO' , ; // [01] C Nome do Campo
        '5' , ; // [02] C Ordem
        AllTrim( STR0076 ) , ; // [03] C Titulo do campo
        AllTrim( STR0076 ) , ; // [04] C Descrição do campo
        { STR0076 } , ; // [05] A Array com Help
        'M' , ; // [06] C Tipo do campo
        '' , ; // [07] C Picture
        NIL , ; // [08] B Bloco de Picture Var
        '' , ; // [09] C Consulta F3
        .T. , ; // [10] L Indica se o campo é evitável
        NIL , ; // [11] C Pasta do campo
        NIL , ; // [12] C Agrupamento do campo
        NIL , ; // [13] A Lista de valores permitido do campo (Combo)
        NIL , ; // [14] N Tamanho Máximo da maior opção do combo
        NIL , ; // [15] C Inicializador de Browse
        .T. , ; // [16] L Indica se o campo é virtual
        NIL ) // [17] C Picture Variável

        // Grupos de campos
        oDadosAdd:AddGroup( 'GRUPO_INSERI' , STR0077 , '' , 2 ) // "Inserir Dados Adicionais"
        oDadosAdd:AddGroup( 'GRUPO_LISTA'  , STR0078 , '' , 2 ) // "Dados Adicionais Existentes"   

        // Atribuindo os grupos aos campos
        oDadosAdd:SetProperty( 'CK4_COD'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO_INSERI' )
        oDadosAdd:SetProperty( 'CK4_VALOR'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO_INSERI' )    
        oDadosAdd:SetProperty( 'CK4_DESCRI'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO_INSERI' )    
        oDadosAdd:SetProperty( 'CK4_VALORSXB' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_INSERI' )    
        oDadosAdd:SetProperty( 'CK4_MEMO'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO_LISTA' )

        // Atribuindo a consulta dinamica, com base no registro escolhido na CK2
        oDadosAdd:SetProperty('CK4_VALORSXB', MVC_VIEW_LOOKUP, { || fGetF3() } )

        //Painel com os botões
        oView:AddOtherObject("BOTOES", {|oPanel| xBtnAdd(oPanel)})
        oView:SetOwnerView(  'BOTOES', 'BOTOES_DADOSAD')  
        oView:SetFieldAction('CK4_COD' , {|oView| CK2VAL(oView,oModel) })
    EndIf
EndIf

//Colocando título do formulário
oView:EnableTitleView('VIEW_PERFIL', STR0003) //"Informaçoes das Faixas do Anexo"
oView:EnableTitleView('VIEW_CFOP'  , STR0004) //"Informaçoes das Faixas do Anexo"
oView:EnableTitleView('VIEW_TPOPER', STR0056) //"Tipo de operação"

If lDadosAd
    oView:EnableTitleView('VIEW_DADOSADD', STR0080) //"Dados Adicionais de Operação"
EndIf

//Picture do campo código
oCabecalho:SetProperty('F20_CODIGO' , MVC_VIEW_PICT, "@!")

//Adiciona botão do Facilitador
If FindFunction("FSA171WIZ")
    oView:AddUserButton( 'Facilitador','', {|oView| FSA171WIZ("2","03")} )
EndIF

//Desabilitando opção de ordenação
oView:SetViewProperty("*", "ENABLENEWGRID")
oView:SetViewProperty( "*", "GRIDNOORDER" )

Return oView


// 
//-------------------------------------------------------------------
/*/{Protheus.doc} Fisa165POS
Acoes/Validacoes apos modelo validado, mas antes de persistir no banco de dados

@param oModel - objeto do modelo de dados
@return lRet - Retorna .T. se a operação de validacao foi bem sucedida, .F. caso contrário

@author Douglas Dourado
@since 02/06/2025
@version 2510
/*/
//-------------------------------------------------------------------
Static Function Fisa165POS( oModel  )
    Local nOperation := oModel:GetOperation()
    Local cIdF20  := AllTrim(oModel:GetValue('FISA165',"F20_CODIGO"))
    Local lAdicDataOk  := AliasIndic("CK4") .and. !Empty(cIdF20)
    Local cMemoCK4 := AllTrim(oModel:GetValue('DADOSADD',"CK4_MEMO"))
    
    If nOperation == MODEL_OPERATION_UPDATE 
        
        If lAdicDataOk        
            // Apaga a CK4 Antiga
            DeleteCK4( cIdF20 )
            // Cria a CK4 Nova
            GravaCK4( cIdF20 , cMemoCK4 ) 
        EndIf

    Elseif nOperation == MODEL_OPERATION_INSERT

        If lAdicDataOk
            If !Empty(cMemoCK4)        
                GravaCK4( cIdF20 , cMemoCK4 ) 
            EndIf
        EndIf

    Elseif nOperation == MODEL_OPERATION_DELETE
        If lAdicDataOk
            If !Empty(cIdF20)        
                DeleteCK4( cIdF20 )
            EndIf
        EndIf
    EndIf

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} GravaCK4
Função que grava os dados adicionais na tabela CK4

@param cIdF20 - Código do Perfil Tributário de Operação
@param cMemoCK4 - Conteúdo do campo CK4_MEMO que será gravado na tabela CK4
@return Sem retorno

@author Douglas Dourado
@since 02/06/2025
@version 2510

/*/
//-------------------------------------------------------------------
Static Function GravaCK4( cIdF20, cMemoCK4 )
    Local aDadosAdd := {}
    Local nX := 0

    aDadosAdd := MemoToArr(cMemoCK4) 

    For nX := 1 To Len(aDadosAdd)
        If !Empty(aDadosAdd[nX])
            RecLock("CK4",.T.)
                CK4->CK4_FILIAL := xFilial("CK4")    
                CK4->CK4_CODF20 := cIdF20        
                CK4->CK4_CODIGO := aDadosAdd[nX][1]        
                CK4->CK4_CONTEU := aDadosAdd[nX][2]        
            MsUnLock()
        EndIf    
    Next

    aSize(aDadosAdd, 0)
    aDadosAdd := Nil

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MemoToArr
Função que transforma o MEMO em array para persistir na tabela CK4

@param cMemoCK4 - Conteúdo do campo CK4_MEMO que será transformado em array
@return aDadosAdd - Array com os dados adicionais prontos para persistir na tabela CK4

@author Douglas Dourado
@since 02/06/2025
@version 2510

/*/
//-------------------------------------------------------------------
Static Function MemoToArr(cMemoCK4)
    Local aDadosAdd := {}
    Local aMemoCK4 := {}
    Local nX := 0
    Local aAux := {}

    aMemoCK4 := StrTokArr2( Alltrim(cMemoCK4) , '|')
    
    dbSelectArea("CK2")
    CK2->(dbSetOrder(1))    

    If !Empty(aMemoCK4)
        For nX := 1 To Len(aMemoCK4)
            aAux := StrTokArr2( Alltrim(aMemoCK4[nX]) , ':' )
            If !Empty(aAux) .and. Len(aAux) == 2
                If !Empty(aAux[1]) .and. !Empty(aAux[2])
                    If( CK2->(MsSeek(xFilial("CK2")+"2"+ Alltrim(aAux[1]) )) )
                        AADD(aDadosAdd , aAux)            
                    EndIf
                EndIf
            EndIf        
        Next
    EndIf

    FWFreeArray(aMemoCK4)

Return aDadosAdd

//-------------------------------------------------------------------
/*/{Protheus.doc} DeleteCK4
Função que exclui os dados adicionais na tabela CK4

@param cIdF20 - Código do Perfil Tributário de Operação a ser excluído
@return Sem retorno

@author Douglas Dourado
@since 02/06/2025
@version 2510

/*/
//-------------------------------------------------------------------
Static Function DeleteCK4( cIdF20 )

    DbSelectArea("CK4")
    CK4->(dbSetOrder(1)) // CK4_FILIAL, CK4_CODF20, CK4_CODIGO, R_E_C_N_O_, D_E_L_E_T_

    While ( CK4->(MsSeek(FwxFilial("CK4") + cIdF20)) )
        RecLock("CK4",.F.)
        CK4->(dbDelete())
        MsUnLock()
    EndDo

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} fGetF3
Função que monta a consulta F3 para o campo CK4_VALORSXB

@author Douglas Dourado
@since 02/06/2025
@version 2510

/*/
//-------------------------------------------------------------------
Static Function fGetF3()    
return cConsultP

//-------------------------------------------------------------------
/*/{Protheus.doc} CK2VAL
Função que monta dinamicamente a consulta do campo CK4_VALORSXB ou CK4_VALOR

@author Douglas Dourado
@since 02/06/2025
@version 2510

/*/
//-------------------------------------------------------------------
Function CK2VAL(oView,oModel)
    Local aOpcoes    := {}
    Local cCodigo   := ""
    Local cAux     := ""
    Local cOpcoes := ""
    Local oFormul   := nil

    IF ValType(oView) =='O'

        oModel    := FWModelActive()
        oFormul   := oModel:GetModel("DADOSADD")
        cCodigo   := AllTrim(oModel:GetValue('DADOSADD',"CK4_COD"))

        CK2->(dbSetOrder(1))
        If( CK2->(MsSeek(xFilial("CK2")+"2"+cCodigo)) )

            cConsultP := ''
            oFormul:LoadValue("CK4_VALORSXB", "" )
            oFormul:LoadValue("CK4_VALOR", "" )

            If CK2->CK2_TPORIG == "C " .AND. !Empty(CK2->CK2_CBOX) // Combobox                
            
                aOpcoes := StrTokArr2(CK2->CK2_CBOX, ';' )
                oView:SetFieldProperty("VIEW_DADOSADD","CK4_VALOR","COMBOVALUES",{aOpcoes} )                

            Elseif CK2->CK2_TPORIG == "FT" .AND. !Empty(CK2->CK2_FUNORI) .AND. FindFunction(CK2->CK2_FUNORI) // Por Funcao

                cAux := "{|| "+CK2->CK2_FUNORI+" }"
                cOpcoes := Eval(&cAux)
                aOpcoes := StrTokArr2(cOpcoes, ';' )
                oView:SetFieldProperty("VIEW_DADOSADD","CK4_VALOR","COMBOVALUES",{aOpcoes})   

            // Linhas comentadas devido a mudança de escopo - linhas não retiradas para implementação futura 

            // Elseif CK2->CK2_TPORIG == "F3" .AND. !Empty(CK2->CK2_CPDRA) // Consulta Padrao (F3)
                
            //     cConsultP := Alltrim(CK2->CK2_CPDRA)       

            // Elseif CK2->CK2_TPORIG == "X5" .AND. !Empty(CK2->CK2_TABGEN) // Tabela Generica (SX5)
                
            //     cConsultP := Alltrim(CK2->CK2_TABGEN)       

            Endif

            oFormul:LoadValue("CK4_DESCRI", Alltrim(CK2->CK2_DESCRI) )
                    
            oView:Refresh()   
        Else
            Help( ,, 'Help',,STR0081 + cCodigo, 1, 0 ) 
        EndIf     
    Endif

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} AddDadosAd
Função que adiciona os dados adicionais no MEMO via botao "Adicionar"

@author Douglas Dourado
@since 02/06/2025
@version 2510

/*/
//-------------------------------------------------------------------
Static Function AddDadosAd()

    Local oModel := FWModelActive()
    Local cCodigo    := AllTrim(oModel:GetValue('DADOSADD',"CK4_COD"))
    Local cValSXB    := AllTrim(oModel:GetValue('DADOSADD',"CK4_VALORSXB"))
    Local cValor     := AllTrim(oModel:GetValue('DADOSADD',"CK4_VALOR"))
    Local cOldMemo   := AllTrim(oModel:GetValue('DADOSADD',"CK4_MEMO"))
    Local oDadosAd	 := oModel:GetModel('DADOSADD')
    Local oView       := FWViewActive()
    Local cNewChave  := ""
    Local nOperation := oModel:GetOperation()
    Local lValidOp   := (nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE)

    If !lValidOp
        Help( ,, 'Help',,STR0067, 1, 0 ) // A operação não é válida para adicionar dados adicionais 
        Return    
    EndIf    

    If Empty(cCodigo)
        Help( ,, 'Help',,STR0068, 1, 0 )  // Código do Dado Adicional não pode ser vazio
        Return
    EndIf

    // Trecho comentado devido a mudança de escopo - linhas não retiradas para implementação futura
    // If Empty(cValor) .and. Empty(cValSXB)
    //     Help( ,, 'Help',, STR0069 , 1, 0 ) // Valor do Dado Adicional não pode ser vazio
    //     Return
    // EndIf

    If cCodigo $ cOldMemo
        Help( ,, 'Help',,STR0070 + cCodigo, 1, 0 ) // Código do Dado Adicional já existe na lista: 
        Return
    EndIf

    // Trecho comentado devido a mudança de escopo - linhas não retiradas para implementação futura
    If !Empty(cConsultP) .and. !Empty(cValSXB)
        //cNewChave  := cCodigo + ":" + cValSXB + "|"
    Elseif Empty(cConsultP) .and. Empty(cValSXB) .and. !Empty(cValor)
        cNewChave  := cCodigo + ":" + cValor + "|" 
    EndIf

    oDadosAd:LoadValue( 'CK4_MEMO', (cOldMemo + cNewChave) )
    oView:Refresh()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} validAddic
Função que valida se existe codigos duplicados no MEMO

@param cMemoCK4 Conteúdo do MEMO CK3_MEMO
@param nOperation Tipo de operação do modelo (inserção ou alteração)
@return .T. se não houver códigos duplicados, .F. caso contrário
@author Douglas Dourado
@since 25/08/2025
@version 2510

/*/
//-------------------------------------------------------------------
Static Function validAddic( cMemoCK4 , nOperation )
Local lRet := .T.
Local nX := 0
Local aAux := {}
Local aDadosAdd := {}

If (nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE) .and. !Empty(cMemoCK4)
    aDadosAdd := MemoToArr(cMemoCK4) 

    For nX := 1 To Len(aDadosAdd)
        If !Empty(aDadosAdd[nX])
            If Ascan( aAux , aDadosAdd[nX][1] ) > 0                
                Help( ,, 'Help',,STR0070 + aDadosAdd[nX][1], 1, 0 ) // Código do Dado Adicional já existe na lista
                lRet := .F.
                exit
            Else
                AAdd(aAux, aDadosAdd[nX][1])
            EndIf    
        EndIf    
    Next

EndIf

aSize(aDadosAdd, 0)
aDadosAdd := Nil

aSize(aAux, 0)
aAux := Nil

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} xBtnAdd
Função que cria o botão "Adicionar" na tela de dados adicionais

@param oPanel - Painel onde o botão será adicionado
@return cEstilo - Estilo CSS aplicado ao botão

@author Douglas Dourado
@since 02/06/2025
@version 2510

/*/
//-------------------------------------------------------------------
Static Function xBtnAdd(oPanel)

    Local cCssAdd	:= getCss("ADICIONAR_001.PNG")
    Local nYFisrtRow       := 1 //Posições do eixo Y das linhas
    Local nXFirstCol       := 2 //Posições do exixo X das linhas
    Local nWidthCss        := 65 //Largura do botão com CSS
    Local nHeightCss       := 16 //Altura do botão com CSS

    //Cria frame para colocar os componentes
    oLayer := FWLayer():New()
    oLayer:Init(oPanel, .F.)
    oLayer:AddLine('LIN1', 100, .F.) 
    oPanel1  := oLayer:getLinePanel('LIN1')

    oBtnEAdd   := TButton():New((nYFisrtRow - 1) , nXFirstCol   ,"      Adiciona" ,oPanel1,{|| AddDadosAd() },nWidthCss ,nHeightCss ,,,.F.,.T.,.F.,,.F.,{||.T.  }   ,,.F.)
    oBtnEAdd:SetCss(cCssAdd) //Aplica o CSS nos botões

    Return NIL

    Static Function getCss(cImg)

    Local cEstilo	:= ""

    cEstilo := "QPushButton {"  

    If !Empty(cImg)
        //Usando a propriedade background-image, inserimos a imagem que será utilizada, a imagem pode ser pega pelo repositório (RPO)
        cEstilo += " background-image: url(rpo:" + cImg + ");background-position: left center;background-repeat: no-repeat; margin: 2px;" 
    EndIF

    cEstilo += " border-style: outset;"
    cEstilo += " border-width: 1px;"
    cEstilo += " border: 1px solid #03396C;"
    cEstilo += " border-radius: 6px;"
    cEstilo += " border-color: #03396C;"
    cEstilo += " font: bold 12px Arial;"
    cEstilo += " padding: 6px;"
    cEstilo += " background-color: #f4f7f9;"
    cEstilo += "}"

    //Na classe QPushButton:pressed , temos o efeito pressed, onde ao se pressionar o botão ele muda
    cEstilo += "QPushButton:pressed {"
    cEstilo += " background-color: #e68a2c;"
    cEstilo += " border-style: inset;"
    cEstilo += "}" 

Return cEstilo


//-------------------------------------------------------------------
/*/{Protheus.doc} GetCK4
Função que retorna os dados adicionais na tabela CK4

@param cIdF20 - Código do Perfil Tributário de Operação
@return cMemoCK4 - Conteúdo do campo CK4_MEMO que será retornado

@author Douglas Dourado
@since 02/06/2025
@version 2510

/*/
//-------------------------------------------------------------------
Function GetCK4( cIdF20 )
    Local cQry		:= ""
    Local cMemoCK4	:= ""
    Local nOrder	:= 1
    Local oModel := FWModelActive()
    Local nOperation 	:= oModel:GetOperation()
    Local cAliasTemp
    Default cIdF20  := AllTrim(oModel:GetValue('FISA165',"F20_CODIGO")) 

    If nOperation == MODEL_OPERATION_INSERT
        Return ""
    EndIf

    cQry := " SELECT CK4_CODIGO, CK4_CONTEU" 
    cQry += " FROM ? "
    cQry += " WHERE CK4_FILIAL  = ? "
    cQry += " AND CK4_CODF20 = ? "   
    cQry += " AND D_E_L_E_T_ = ? "

    oCK4 := FWExecStatement():New(ChangeQuery(cQry))

    oCK4:SetUnsafe(nOrder++, RetSqlName("CK4"))
    oCK4:SetString(nOrder++,xFilial("CK4"))
    oCK4:SetString(nOrder++,cIdF20 )
    oCK4:SetString(nOrder++," " )

    cAliasTemp:= oCK4:OpenAlias()

    DbSelectArea(cAliasTemp)
    (cAliasTemp)->(DbGoTop())
    While (cAliasTemp)->(!Eof())
        cMemoCK4 += Alltrim((cAliasTemp)->CK4_CODIGO) + ":" + Alltrim((cAliasTemp)->CK4_CONTEU) + "|"
        (cAliasTemp)->(DbSkip())	
    EndDo

    (cAliasTemp)->(DbCloseArea())    
    oCK4:Destroy()
	oCK4:= nil

Return cMemoCK4


//-------------------------------------------------------------------
/*/{Protheus.doc} AtivaDadosAd
Função que ativa ou nao os campos de dados adicionais

@param oModel - objeto do modelo de dados
@return Retorna .T. se os campos dos dados adicionais devem ser ativados, .F. caso contrário

@author Douglas Dourado
@since 02/06/2025
@version 2510

/*/
//-------------------------------------------------------------------
Static Function AtivaDadosAd(oModel)
    Local nOperation 	:= oModel:GetOperation()
    Local lRet := .F.

    If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE
        lRet := .T.
    EndIF

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} GrvCfop

Função responsável por gravar o CFOP da carga inicial
@param cPerfil   - Código do perfil
@param cDescPerf - Descrição do perfil
@param aCfop     - Lista de CFOP a ser inserido
@param lAddF20   - Indica se deve adicionar o cabeçalho do perfil na tabela F20

@author Erick.Dias
@since 24/07/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Static Function GrvCfop(cPerfil, cDescPerf, aCfop)

Local nCont := 0
Local nX    := 0

//Cria o perfil
RecLock("F20",.T.)
F20->F20_FILIAL	    := xFilial("F20")
F20->F20_CODIGO		:= cPerfil
F20->F20_DESC  		:= cDescPerf
F20->F20_TIPO  		:= '03' //03 indica que é perfil de operação
MsUnLock()

//Laço criando os CFOPs para o perfil
For nX := 1 to Len(aCfop)
    For nCont:=1 to Len(aCfop[nX])
        If oJCFOP:hasProperty(aCfop[nX, nCont])

            RecLock("F23",.T.)
            F23->F23_FILIAL	    := xFilial("F23")
            F23->F23_CODIGO		:= cPerfil
            F23->F23_CFOP  		:= aCfop[nX, nCont]
            IF lF23Tipo
                F23->F23_TIPOPF	:= "03"
            Endif
            MsUnLock()

        EndIF
    Next nCont
Next nX

//Para todos os perfis de carga inicial automática, será preenchido no tipo de operação a opção todos
RecLock("F26",.T.)
F26->F26_FILIAL	    := xFilial("F26")
F26->F26_CODIGO		:= cPerfil
F26->F26_TPOPER		:= "TODOS"
IF lF26Tipo
    F26->F26_TIPOPF	:= "03"
Endif
MsUnLock()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA165CARG

Função responsável por efetuar a carga dos perfis de operação

@author joao.pellegrini
@since 24/07/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Function FSA165CARG()

Local aEComuInt    := {"1301","1302","1303","1304","1305","1306"}
Local aEComuInter  := {"2301","2302","2303","2304","2305","2306"}
Local aEComuImp    := {"7301"}
Local aEEneInt     := {"1251","1252","1253","1254","1255","1256","1257"}
Local aEEneInter   := {"2251","2252","2253","2254","2255","2256","2257"}
Local aEEneImp     := {"3251"}
Local aETraInt     := {"1351","1352","1353","1354","1355","1356"}
Local aETraInter   := {"2351","2352","2353","2354","2355","2356"}
Local aETraImp     := {"3351","3352","3353","3354","3355","3356"}
Local aECombInt    := {"1651","1652","1653"}
Local aECombInter  := {"2651","2652","2653"}
Local aECombImp    := {"3651","3652","3653"}
Local aEComInt     := {"1102","1113","1117","1118","1121","1403"}
Local aEComInter   := {"2102","2113","2117","2118","2121","2403"}
Local aEComImp     := {"3102"}
Local aEIndInt     := {"1101","1111","1116","1120","1122","1401"}
Local aEIndInter   := {"2101","2111","2116","2120","2122","2401"}
Local aEIndImp     := {"3101","3127"}

Local aVenInt      := {"5101","5103","5105","5109","5111","5113","5118","5122","5124","5125","5401","5402","5922"}
Local aVenInter    := {"6101","6103","6105","6107","6109","6111","6113","6118","6122","6124","6125","6401","6402","6922"}
Local aVenExt      := {"7101","7105","7127"}
Local aRevInt      := {"5102","5104","5106","5110","5112","5114","5115","5119","5120","5123","5403","5405","5922"}
Local aRevInter    := {"6102","6104","6106","6108","6110","6112","6114","6115","6119","6120","6123","6403","6404","6405","6922"}
Local aRevExt      := {"7102","7501","7106"}
Local aCombInt     := {"5651","5652","5653","5654","5655","5656"}
Local aCombInter   := {"6651","6652","6653","6654","6655","6656"}
Local aCombExt     := {"7651","7654"}
Local aTranInt     := {"5351","5352","5353","5354","5355","5356","5357","5359","5360"}
Local aTranInter   := {"6351","6352","6353","6354","6355","6356","6357","6359","6360"}
Local aTranExt     := {"7358"}
Local aEnergInt    := {"5251","5252","5253","5254","5255","5256","5257","5258"}
Local aEnergInter  := {"6251","6252","6253","6254","6255","6256","6257","6258"}
Local aEnergExt    := {"7250"}
Local aComInt      := {"5301","5302","5303","5304","5305","5306","5307"}
Local aComInter    := {"6301","6302","6303","6304","6305","6306","6307"}
Local aComExt      := {"7301"}
Local aCfopEnt     := {}
Local aCfopSai     := {}
Local aCfopAll     := {}

Local aDevCom      := {"1201", "1202", "1203", "1204", "1208", "1209", "1410", "1411", "1503", "1504", "1505", "1506", "1553", "1660", "1661", "1662", "1918", "1919", "2201", "2202", "2203", "2204", "2208", "2209", "2410", "2411", "2503", "2504", "2505", "2506", "2553", "2660", "2661", "2662", "2918", "2919", "3201", "3202", "3211", "3503", "3553"}
Local aDevVen      := {"5201", "5202", "5208", "5209", "5210", "5410", "5411", "5412", "5413", "5503", "5553", "5555", "5556", "5660", "5661", "5662", "5918", "5919", "5921", "6201", "6202", "6208", "6209", "6210", "6410", "6411", "6412", "6413", "6503", "6553", "6555", "6556", "6660", "6661", "6662", "6918", "6919", "6921", "7201", "7202", "7210", "7211", "7553", "7556"}

Local cCodPerf     := "000000"

dbSelectArea("F23")
F23->(dbSetOrder(1))
F23->(dbGoTop())

// Só faz a carga se não houver nenhum perfil na filial...
If !F23->(dbSeek(xFilial("F23")))
    
    //---------------------------------------------------
    //Carga de todos os CFOPs de entrada, saída, e todos (exceto as cfops de devolucao) 
    //---------------------------------------------------
    AllCfops(@aCfopEnt, @aCfopSai, @aCfopAll , aDevCom , aDevVen)

    //------------------------------------------
    //Carga dos CFOps de entradas de Comunicação
    //------------------------------------------
    GrvCfop(IncCod(@cCodPerf), STR0005, {aEComuInt}) //"AQUISIÇÃO DE SERVIÇO DE COMUNICAÇÃO - INTERNA"
    GrvCfop(IncCod(@cCodPerf), STR0006, {aEComuInter})//"AQUISIÇÃO DE SERVIÇO DE COMUNICAÇÃO - INTERESTADUAL"
    GrvCfop(IncCod(@cCodPerf), STR0007, {aEComuImp})//"AQUISIÇÃO DE SERVIÇO DE COMUNICAÇÃO - IMPORTAÇÃO"
    GrvCfop(IncCod(@cCodPerf), STR0008, {aEComuInt, aEComuInter, aEComuImp})//"TODAS AS AQUISIÇÕES DE COMUNICAÇÃO"
    
    //------------------------------------------------
    //Carga dos CFOps de entradas de Energia Elétrica
    //------------------------------------------------
    GrvCfop(IncCod(@cCodPerf), STR0009, {aEEneInt})//"AQUISIÇÃO DE SERVIÇO DE ENERGIA ELÉTRICA - INTERNA"
    GrvCfop(IncCod(@cCodPerf), STR0010, {aEEneInter})//"AQUISIÇÃO DE SERVIÇO DE ENERGIA ELÉTRICA - INTERESTADUAL"
    GrvCfop(IncCod(@cCodPerf), STR0011, {aEEneImp})//"AQUISIÇÃO DE SERVIÇO DE ENERGIA ELÉTRICA - IMPORTAÇÃO"
    GrvCfop(IncCod(@cCodPerf), STR0012, {aEEneInt, aEEneInter, aEEneImp})//"TODAS AS AQUISIÇÕES DE ENERGIA ELÉTRICA"

    //------------------------------------------
    //Carga dos CFOps de entradas de Transportes
    //------------------------------------------
    GrvCfop(IncCod(@cCodPerf), STR0013, {aETraInt})//"AQUISIÇÃO DE SERVIÇO DE TRANSPORTE - INTERNA"
    GrvCfop(IncCod(@cCodPerf), STR0014, {aETraInter})//"AQUISIÇÃO DE SERVIÇO DE TRANSPORTE - INTERESTADUAL"
    GrvCfop(IncCod(@cCodPerf), STR0015, {aETraImp})//"AQUISIÇÃO DE SERVIÇO DE TRANSPORTE - IMPORTAÇÃO"
    GrvCfop(IncCod(@cCodPerf), STR0016, {aETraInt, aETraInter, aETraImp})//"TODAS AS AQUISIÇÕES DE TRANSPORTE"

    //------------------------------------------
    //Carga dos CFOps de entradas de Combustível
    //------------------------------------------
    GrvCfop(IncCod(@cCodPerf), STR0017, {aECombInt})//"AQUISIÇÃO DE COMBUSTÍVEL - INTERNA"
    GrvCfop(IncCod(@cCodPerf), STR0018, {aECombInter})//"AQUISIÇÃO DE COMBUSTÍVEL - INTERESTADUAL"
    GrvCfop(IncCod(@cCodPerf), STR0019, {aECombImp})//"AQUISIÇÃO DE COMBUSTÍVEL - IMPORTAÇÃO"
    GrvCfop(IncCod(@cCodPerf), STR0020, {aECombInt, aECombInter, aECombImp})    //"TODAS AS AQUISIÇÕES DE COMBUSTÍVEL"
    
    //-------------------------------------------------------------
    //Carga dos CFOps de entradas de Compras para Comercialização
    //-------------------------------------------------------------
    GrvCfop(IncCod(@cCodPerf), STR0021, {aEComInt})//"AQUISIÇÃO PARA COMERCIALIZAÇÃO - INTERNA"
    GrvCfop(IncCod(@cCodPerf), STR0022, {aEComInter})//"AQUISIÇÃO PARA COMERCIALIZAÇÃO - INTERESTADUAL"
    GrvCfop(IncCod(@cCodPerf), STR0023, {aEComImp})//"AQUISIÇÃO PARA COMERCIALIZAÇÃO - IMPORTAÇÃO"
    GrvCfop(IncCod(@cCodPerf), STR0024, {aEComInt, aEComInter, aEComImp})    //"TODAS AS AQUISIÇÕES PARA COMERCIALIZAÇÃO"

    //-------------------------------------------------------------
    //Carga dos CFOps de entradas de Compras para Industrialização
    //-------------------------------------------------------------
    GrvCfop(IncCod(@cCodPerf), STR0025, {aEIndInt})//"AQUISIÇÃO PARA INDUSTRIALIZAÇÃO - INTERNA"
    GrvCfop(IncCod(@cCodPerf), STR0026, {aEIndInter})//"AQUISIÇÃO PARA INDUSTRIALIZAÇÃO - INTERESTADUAL"
    GrvCfop(IncCod(@cCodPerf), STR0027, {aEIndImp})//"AQUISIÇÃO PARA INDUSTRIALIZAÇÃO - IMPORTAÇÃO"
    GrvCfop(IncCod(@cCodPerf), STR0028, {aEIndInt, aEIndInter, aEIndImp})//"TODAS AS AQUISIÇÕES PARA INDUSTRIALIZAÇÃO"

    //---------------------------------------------------------------
    // Adiciona as aquisições no perfil de geral de todas aquisições
    //---------------------------------------------------------------
    GrvCfop(IncCod(@cCodPerf), STR0029, {aCfopEnt})//"TODAS AS ENTRADAS"

    // VENDAS

    GrvCfop(IncCod(@cCodPerf), STR0030, {aVenInt})//"VENDA INTERNA"
    GrvCfop(IncCod(@cCodPerf), STR0031, {aVenInter})//"VENDA INTERESTADUAL"
    GrvCfop(IncCod(@cCodPerf), STR0032, {aVenExt})//"VENDA PARA O MERCADO EXTERNO"
    GrvCfop(IncCod(@cCodPerf), STR0033, {aVenInt,aVenInter,aVenExt})//"TODAS AS VENDAS"

    // REVENDAS    

    GrvCfop(IncCod(@cCodPerf), STR0034, {aRevInt})//"REVENDA INTERNA"
    GrvCfop(IncCod(@cCodPerf), STR0035, {aRevInter})//"REVENDA INTERESTADUAL"
    GrvCfop(IncCod(@cCodPerf), STR0036, {aRevExt})//"REVENDA PARA O MERCADO EXTERNO"
    GrvCfop(IncCod(@cCodPerf), STR0037, {aRevInt, aRevInter, aRevExt})//"TODAS AS REVENDAS"

    // VENDA DE COMBUSTIVEL

    GrvCfop(IncCod(@cCodPerf), STR0038, {aCombInt})//"VENDA DE COMBUSTÍVEL EM OPERAÇÃO INTERNA"
    GrvCfop(IncCod(@cCodPerf), STR0039, {aCombInter})//"VENDA DE COMBUSTÍVEL EM OPERAÇÃO INTERESTADUAL"
    GrvCfop(IncCod(@cCodPerf), STR0040, {aCombExt})//"VENDA DE COMBUSTÍVEL EM OPERAÇÃO DE EXPORTAÇÃO"
    GrvCfop(IncCod(@cCodPerf), STR0041, {aCombInt,aCombInter,aCombExt})//"TODAS AS VENDAS DE COMBUSTÍVEL"

    // TRANSPORTE

    GrvCfop(IncCod(@cCodPerf), STR0042, {aTranInt})//"PRESTAÇÃO INTERNA DE SERVIÇO DE TRANSPORTE"
    GrvCfop(IncCod(@cCodPerf), STR0043, {aTranInter})//"PRESTAÇÃO INTERESTADUAL DE SERVIÇO DE TRANSPORTE"
    GrvCfop(IncCod(@cCodPerf), STR0044, {aTranExt})//"PRESTAÇÃO DE SERVIÇO DE TRANSPORTE PARA O EXTERIOR"
    GrvCfop(IncCod(@cCodPerf), STR0045, {aTranInt,aTranInter,aTranExt})//"TODAS AS PRESTAÇÕES DE SERVIÇO DE TRANSPORTE"

    // VENDA DE ENERGIA ELÉTRICA

    GrvCfop(IncCod(@cCodPerf), STR0046, {aEnergInt})//"VENDA DE ENERGIA ELÉTRICA EM OPERAÇÃO INTERNA"
    GrvCfop(IncCod(@cCodPerf), STR0047, {aEnergInter})//"VENDA DE ENERGIA ELÉTRICA EM OPERAÇÃO INTERESTADUAL"
    GrvCfop(IncCod(@cCodPerf), STR0048, {aEnergExt})//"VENDA DE ENERGIA ELÉTRICA EM OPERAÇÃO DE EXPORTAÇÃO"
    GrvCfop(IncCod(@cCodPerf), STR0049, {aEnergInt,aEnergInter,aEnergExt})//"TODAS AS VENDAS DE ENERGIA ELÉTRICA"

    // COMUNICAÇÃO

    GrvCfop(IncCod(@cCodPerf), STR0050, {aComInt})//"PRESTAÇÃO INTERNA DE SERVIÇO DE COMUNICAÇÃO"
    GrvCfop(IncCod(@cCodPerf), STR0051, {aComInter})//"PRESTAÇÃO INTERESTADUAL DE SERVIÇO DE COMUNICAÇÃO"
    GrvCfop(IncCod(@cCodPerf), STR0052, {aComExt})//"PRESTAÇÃO DE SERVIÇO DE COMUNICAÇÃO PARA O EXTERIOR"
    GrvCfop(IncCod(@cCodPerf), STR0053, {aComInt,aComInter,aComExt})//"TODAS AS PRESTAÇÕES DE SERVIÇO DE COMUNICAÇÃO"

    // Adiciona as vendas no perfil geral de saídas
    GrvCfop(IncCod(@cCodPerf), STR0054, {aCfopSai})//"TODAS AS SAÍDAS"

    // Perfil de TODOS os CFOPS
    GrvCfop(IncCod(@cCodPerf), STR0055, {aCfopAll})//"TODOS OS CFOPs"

    // DEVOLUCAO - Adiciona as devoluções de compras e vendas
    GrvCfop(IncCod(@cCodPerf), STR0065, {aDevCom})//"DEVOLUÇÃO DE COMPRAS"
    GrvCfop(IncCod(@cCodPerf), STR0066, {aDevVen})//"DEVOLUÇÃO DE VENDAS"
    
EndIf

//Limpo todos os arrays
aEComuInt    := Nil
aEComuInter  := Nil
aEComuImp    := Nil
aEEneInt     := Nil
aEEneInter   := Nil
aEEneImp     := Nil
aETraInt     := Nil
aETraInter   := Nil
aETraImp     := Nil
aECombInt    := Nil
aECombInter  := Nil
aECombImp    := Nil
aEComInt     := Nil
aEComInter   := Nil
aEComImp     := Nil
aEIndInt     := Nil
aEIndInter   := Nil
aEIndImp     := Nil
aVenInt      := Nil
aVenInter    := Nil
aVenExt      := Nil
aRevInt      := Nil
aRevInter    := Nil
aRevExt      := Nil
aCombInt     := Nil
aCombInter   := Nil
aCombExt     := Nil
aTranInt     := Nil
aTranInter   := Nil
aTranExt     := Nil
aEnergInt    := Nil
aEnergInter  := Nil
aEnergExt    := Nil
aComInt      := Nil
aComInter    := Nil
aComExt      := Nil
aCfopEnt     := Nil
aCfopSai     := Nil
aCfopAll     := Nil

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} IncCod

Função que retornará o código do próximo perfil de CFOP da caraga automática

@author joao.pellegrini
@since 24/07/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Static Function IncCod(cCodigo)
cCodigo := Soma1(cCodigo)
Return cCodigo

//-------------------------------------------------------------------
/*/{Protheus.doc} AllCfops
Função que percorrerá todos os CFOPs da SX5 para realizar a carga automática
@author Erick.Dias
@since 24/07/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function AllCfops(aCfopEnt, aCfopSai, aCfopAll , aDevEnt , aDevSai )

Local cCfop     := ""
Local nX        := 0
Local aDadosSX5 := FWGetSX5( "13" )

//Posiciono na SX5 a tabela 13 de CFOPs
For nX := 1 to Len(aDadosSX5)
    cCfop   := Alltrim(aDadosSX5[nX][3])
    
    //Somente considera CFOPs com 4 dígitos
    If Len(cCfop) == 4

        If left(cCfop,1) $ "1/2/3" .and. ASCAN( aDevEnt, cCfop ) <= 0
            //CFOP de entrada
            aAdd(aCfopEnt,cCfop)

        ElseIf left(cCfop,1) $ "5/6/7" .and. ASCAN( aDevSai, cCfop ) <= 0
            //CFOP de saída
            aAdd(aCfopSai,cCfop)
        EndIF

        //Adiciona o CFOP no array que contém todos os CFOPs
        aAdd(aCfopAll,cCfop)

        oJCFOP[cCfop] := Alltrim(aDadosSX5[nX][4])

    EndIF        
Next


Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA165GF23
Função para gravação em lote da F23 CFOPs

@author Erick Dias
@since 26/09/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Function FSA165GF23(cCodPerfil, aCfop, cAcao, nQtdTot, nQtdProc, oSay)

Local cCfop         := ''
Local oModel        := NIL
Local oModelCfop    := NIL
Local lAchouF23     := .F.
Local lRet          := .F.
Local nCont         := 0

oModel := FWLoadModel("FISA165")
oModel:SetOperation(MODEL_OPERATION_UPDATE)

DbSelectArea("F20")
F20->(DbSetOrder(1))

If F20->(DbSeek(xFilial("F20") + cCodPerfil + "03"))

    oModel:Activate()

    oModelCfop := oModel:GetModel("FISA165CFOP")

    For nCont := 1 to Len(aCfop)
        
        nQtdTot     += 1
        cCfop       := padr(aCfop[nCont][1] ,4) 
        lAchouF23   := F23->( MsSeek ( xFilial('F23') + cCodPerfil + cCfop ) )
        
        IF !lAutomato
            oSay:cCaption := ("Processando perfil: " + cCodPerfil + " , CFOP: " + cCfop)
            ProcessMessages()
        EndIf       

        If cAcao == '1' .AND. !lAchouF23
            //A informação ainda não existe na tabela
            oModelCfop:AddLine()
            oModelCfop:SetValue("F23_CFOP" , cCfop)            
            IF lF23Tipo
                oModelCfop:SetValue("F23_TIPOPF"   , '03')
            Endif
            nQtdProc += 1
        
        ElseIF cAcao == '2' .AND. lAchouF23
            //Operação de exclusão e a informação já existe na tabela, então será deletada
            RecLock("F23",.F.)
            F23->(dbDelete())
            MsUnLock()
            F23->(FkCommit())
            nQtdProc += 1

        EndIF

    Next nCont    

    If oModel:VldData()
        lRet := oModel:CommitData()
    Else
        aErros := oModel:GetErrorMessage()
    EndIf

EndIf

oModel:Deactivate()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA165GF26
Função para gravação em lote da F26 Tipo de Operação

@author Erick Dias
@since 26/09/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Function FSA165GF26(cCodPerfil, aTpOper, cAcao, nQtdTot, nQtdProc, oSay)

Local oModel        := NIL
Local oModelOper    := NIL
Local lAchouF26     := .F.
Local lRet          := .F.
Local nCont         := 0

oModel := FWLoadModel("FISA165")
oModel:SetOperation(MODEL_OPERATION_UPDATE)

DbSelectArea("F20")
F20->(DbSetOrder(1))

If F20->(DbSeek(xFilial("F20") + cCodPerfil + "03"))

    oModel:Activate()

    oModelOper := oModel:GetModel("FISA165TPOPER")

    For nCont := 1 to Len(aTpOper)
        
        nQtdTot     += 1        
        lAchouF26   := F26->( MsSeek ( xFilial('F26') + cCodPerfil + aTpOper[nCont][1] ) )
        
        oSay:cCaption := ("Processando perfil: " + cCodPerfil + " , Tipo de Operação: " + aTpOper[nCont][1])
        ProcessMessages()        

        If cAcao == '1' .AND. !lAchouF26
            //A informação ainda não existe na tabela
            oModelOper:AddLine()
            oModelOper:SetValue("F26_TPOPER" , aTpOper[nCont][1])
            IF lF26Tipo
                oModelOper:SetValue("F26_TIPOPF"   , '03')
            Endif
            nQtdProc += 1
        
        ElseIF cAcao == '2' .AND. lAchouF26
            //Operação de exclusão e a informação já existe na tabela, então será deletada
            RecLock("F26",.F.)
            F26->(dbDelete())
            MsUnLock()
            F26->(FkCommit())
            nQtdProc += 1

        EndIF

    Next nCont    

    If oModel:VldData()
        lRet := oModel:CommitData()
    Else
        aErros := oModel:GetErrorMessage()
    EndIf

EndIf

oModel:Deactivate()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA165DOPE
Função auxiliar para tratar o inicializador padrão da descrição do 
tipo de operação, pois o campo X3_RELACAO é limitado e não cabia 
toda a instrução necessária.

@author Erick Dias
@since 11/10/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Function FSA165DOPE()

Local cDescr    := ""

If !INCLUI
    If Upper(Alltrim(F26->F26_TPOPER))=="TODOS"
        cDescr  := "TODOS OS TIPOS DE OPERACAO"
    Else
        cDescr  := POSICIONE("SX5",1,xFilial("SX5")+"DJ"+F26->F26_TPOPER,"X5DESCRI()")
    EndIF
EndIF

Return cDescr

//-------------------------------------------------------------------
/*/{Protheus.doc} CargaTpOper
Função que faz a carga automática do tipo de operação no Grid.
O objetivo é facilitar o cadastro do usuário.

@author Erick G Dias
@since 21/11/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function CargaTpOper(oModel)

Local oTipoOper		:= oModel:GetModel("FISA165TPOPER")

//A carga será realizada somente no momento da inclusão do perfil
If oModel:GetOperation() == MODEL_OPERATION_INSERT .AND. oTipoOper:Length() == 1        
    oTipoOper:LoadValue("F26_TPOPER" , "TODOS")
    oTipoOper:LoadValue("F26_DESCRI" , "TODOS OS TIPOS DE OPERACAO")
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA165GCIO
Função para gravação em lote da CIO Código de ISS.
Utilizado no fonte FISA171

@author Renato Rezende
@since 23/07/2020
@version 12.1.30

/*/
//-------------------------------------------------------------------
Function FSA165GCIO(cCodPerfil, aCodISS, cAcao, nQtdTot, nQtdProc, oSay)

Local oModel        := NIL
Local oModelOper    := NIL
Local lAchouCIO     := .F.
Local lRet          := .F.
Local nCont         := 0

oModel := FWLoadModel("FISA165")
oModel:SetOperation(MODEL_OPERATION_UPDATE)

DbSelectArea("F20")
F20->(DbSetOrder(1))

If F20->(DbSeek(xFilial("F20") + cCodPerfil + "03"))

    oModel:Activate()

    oModelOper := oModel:GetModel("FISA165CDSERV")

    For nCont := 1 to Len(aCodISS)
        
        nQtdTot     += 1        
        lAchouCIO   := CIO->( MsSeek ( xFilial('CIO') + cCodPerfil + aCodISS[nCont][1] ) )
        
        oSay:cCaption := ("Processando perfil: " + cCodPerfil + " , Código ISS: " + aCodISS[nCont][1])
        ProcessMessages()        

        If cAcao == '1' .AND. !lAchouCIO
            //A informação ainda não existe na tabela
            oModelOper:AddLine()
            oModelOper:SetValue("CIO_CODISS" , aCodISS[nCont][1])            
            IF lCIOTipo
                oModelOper:SetValue("CIO_TIPOPF" , '03')            
            Endif
            nQtdProc += 1
        
        ElseIF cAcao == '2' .AND. lAchouCIO
            //Operação de exclusão e a informação já existe na tabela, então será deletada
            RecLock("CIO",.F.)
                CIO->(dbDelete())
            CIO->(MsUnLock())
            CIO->(FkCommit())
            nQtdProc += 1

        EndIF

    Next nCont    

    If oModel:VldData()
        lRet := oModel:CommitData()
    Else
        aErros := oModel:GetErrorMessage()
    EndIf

EndIf

oModel:Deactivate()

Return lRet

/*/{Protheus.doc} AtuTpPF03
    (Atualiza novos campos F25_TIPOPF e F24_TIPOPF)

@author Rafael S Oliveira
@since 01/03/2021
@version P12.1.30

    /*/
Function AtuTpPF03()

IF lF23Tipo
    cQuery := "UPDATE " +  RetSqlName('F23') + " SET F23_TIPOPF = '03' WHERE F23_FILIAL = " + ValToSql(xFilial('F23')) + " AND F23_TIPOPF = ' '
    TcSqlExec(cQuery)
Endif
IF lF26Tipo
    cQuery := "UPDATE " +  RetSqlName('F26') + " SET F26_TIPOPF = '03' WHERE F26_FILIAL = " + ValToSql(xFilial('F26')) + " AND F26_TIPOPF = ' '
    TcSqlExec(cQuery)
Endif
IF lCIOTipo
    cQuery := "UPDATE " +  RetSqlName('CIO') + " SET CIO_TIPOPF = '03' WHERE CIO_FILIAL = " + ValToSql(xFilial('CIO')) + " AND CIO_TIPOPF = ' '
    TcSqlExec(cQuery)
Endif

Return

/*/{Protheus.doc} VldTodos
    Valida a inclusão do tipo TODOS

@author Yuri Gimenes
@since 08/04/2022
@version P12.1.33

    /*/
static Function ValidDel(oObjeto,nOpcao)

Local lRet      := .T.
Local lOperTd    := .F.
Local lOperAv    := .F.
Local lISSTd    := .F.
Local lISSAv    := .F.
Local nY
Local oModelGrid := oObjeto

/*
nOpcao == 1 -> Tipo de Operação
nOpcao == 2 -> Código de Serviço
*/
oModelPad   := FwModelActive()

If nOpcao == 1

    For nY := 1 to oModelGrid:Length()

        oModelGrid:GoLine(nY)

        iF !oModelGrid:IsDeleted()

            cTpOper := AllTrim(oModelGrid:GetValue ("F26_TPOPER"))

            lOperTd := iif(lOperTd==.F.,iif(AllTrim(cTpOper)=="TODOS",.t.,.f.),.T.)
            lOperAv := iif(lOperAv==.F.,iif(AllTrim(cTpOper)<>"TODOS",.t.,.f.),.T.)

            If lOperTd .and. lOperAv
                exit
            ENDIF

        EndIf

    Next nY

    nY := 0

    If lOperTd .and. lOperAv

        If lAutomato .or. MsgYesNo(STR0058 + chr(13)+chr(10) +;    //"Existem tipos de operação e/ou código de serviço configurados como'TODOS' no Grid."
                    STR0059 + chr(13)+chr(10) +;    //"Os tipos de operação e/ou código de serviço diferente de TODOS serão excluídos"
                    STR0060, STR0003)            //"Deseja continuar?"

            For nY := 1 to oModelGrid:Length()

            oModelGrid:GoLine(nY)

                cTpOper := AllTrim(oModelGrid:GetValue ("F26_TPOPER"))

                if(!("TODOS" $ cTpOper) .and. lOperTd)
                    oModelGrid:DeleteLine()
                EndIf
            Next nY
            lPassou := .T.
        else
            lRet := .F.
            oModelPad:SetErrorMessage(,,,,,STR0063,STR0064)
        EndIf
    EndIF

Elseif nOpcao == 2

    For nY := 1 to oModelGrid:Length()

        oModelGrid:GoLine(nY)

        iF !oModelGrid:IsDeleted()

            cCodServ := AllTrim(oModelGrid:GetValue ("CIO_CODISS"))

            lISSTd := iif(lISSTd==.F.,iif(AllTrim(cCodServ)=="TODOS",.t.,.f.),.T.)
            lISSAv := iif(lISSAv==.F.,iif(AllTrim(cCodServ)<>"TODOS",.t.,.f.),.T.)

            If lISSTd .and. lISSAv
                exit
            ENDIF

        EndIf
    Next nY

    nY := 0

    If lISSTd .and. lISSAv

        If !lpassou

            lPassou :=  lAutomato .or. MsgYesNo(STR0061 + chr(13)+chr(10) +;   //"Existem códigos de serviço configurados como 'TODOS' no Grid."
                                 STR0062 + chr(13)+chr(10) +;   //"Os códigos de serviço diferente de TODOS serão excluídos"
                                 STR0060, "Atenção!")           //"Deseja continuar?"
        ENDIF

        If lPassou

            For nY := 1 to oModelGrid:Length()

                oModelGrid:GoLine(nY)

                iF !oModelGrid:IsDeleted()

                    cCodServ := AllTrim(oModelGrid:GetValue ("CIO_CODISS"))

                    if(!("TODOS" $ cCodServ) .and. lISSTd)
                        oModelGrid:DeleteLine()
                    EndIf
                    
                EndIf

            Next nY
            lPassou := .F.
        else
            lRet := .F.
            oModelPad:SetErrorMessage(,,,,,STR0063,STR0064)
        EndIF
    EndIf
EndIF

Return lRet
