#Include "FISA160J.ch"
#include "protheus.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#Include "FWEditPanel.CH"

STATIC lDadosAd := AliasIndic("CK2") .And. AliasIndic("CK3")
STATIC cConsultP := ''

PUBLISH MODEL REST NAME FISA160J

//TODO - Gravação do histórico da tabela
//TODO - Exibir histórico
//TODO - Rever grupos para adicionar campos de fórmulas

STATIC lNrLivro := fisExtCmp('12.1.2510', .T., 'CJ2' , 'CJ2_NLIVRO')

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA160J()

Esta rotina tem objetivo de criar rtina para composição da regra
de escrituração do tributo. Esta regra será vinculada ao cadastro 

CJ2 - Cabeçalho

@author Erick Dias
@since 13/08/2020
@version P12.1.30
/*/
//-------------------------------------------------------------------
Function FISA160J()
Local   oBrowse := Nil

//Verifico se as tabelas existem antes de prosseguir
IF AliasIndic("CJ2")
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("CJ2")    
    oBrowse:SetDescription(STR0001) //"Cadastro da Regra de Escrituração"
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0002,1,0) //"Dicionário desatualizado, verifique as atualizações do configurador de tributos"
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao responsável por gerar o menu.

@author Erick Dias
@since 13/08/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FISA160J' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FISA160J' OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.FISA160J' OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.FISA160J' OPERATION 5 ACCESS 0 //'Excluir'
ADD OPTION aRotina TITLE STR0009 ACTION 'VIEWDEF.FISA160J' OPERATION 9 ACCESS 0 //'Copiar'
ADD OPTION aRotina TITLE STR0010 ACTION 'FSA160JHist'      OPERATION 4 ACCESS 0 //"Histórico de Alterações"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Função que criará o modelo da regra de escrituração

@author Erick Dias
@since 13/08/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

    //Criação do objeto do modelo de dados
    Local oModel    := Nil

//Estrutura da tabela CJ2 com os campos do cabeçalho da regra
Local oCabecalho  := FWFormStruct(1, "CJ2" )
Local oDadosAd  := nil

if lDadosAd
    oDadosAd := FWFormStruct(1,"CK3")

    oDadosAd:RemoveField("CK3_IDCJ2")
    oDadosAd:RemoveField("CK3_FILIAL")
    oDadosAd:RemoveField("CK3_CONTEU")
    
    oDadosAd:AddField( ; // Ord. Tipo Desc.
    AllTrim( STR0029 ) , ; // [01] C Titulo do campo
    AllTrim( STR0029 ) , ; // [02] C ToolTip do campo
    'CK3_VALOR' , ; // [03] C identificador (ID) do  Field
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
    AllTrim( STR0030 ) , ; // [01] C Titulo do campo
    AllTrim( STR0030 ) , ; // [02] C ToolTip do campo
    'CK3_VALORSXB' , ; // [03] C identificador (ID) do  Field
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
    AllTrim( STR0031 ) , ; // [01] C Titulo do campo
    AllTrim( STR0031 ) , ; // [02] C ToolTip do campo
    'CK3_MEMO' , ; // [03] C identificador (ID) do  Field
    'M' , ; // [04] C Tipo do campo
    1000 , ; // [05] N Tamanho do campo
    0 , ; // [06] N Decimal do campo
    NIL , ; // [07] B Code-block de validação do campo
    NIL , ; // [08] B Code-block de  validação When do campo
    NIL , ; // [09] A Lista de valores   permitido do campo
    .F. , ; // [10] L Indica se o campo tem preenchimento obrigatório
    FwBuildFeature( STRUCT_FEATURE_INIPAD,'GetCK3()'), ; // [11] BCode-block de inicializacao do campo
    NIL , ; // [12] L Indica se trata de um     campo chave
    NIL , ; // [13] L Indica se o campo pode receber valor em uma operação de update.
    .T. ) // [14] L Indica se o campo é virtual

    oDadosAd:SetProperty('CK3_VALOR'    , MODEL_FIELD_WHEN, {|| !EmpTy( AllTrim(oModel:GetValue('DADOSADD',"CK3_CODIGO")) ) .and. Empty(cConsultP) })
    oDadosAd:SetProperty('CK3_VALORSXB' , MODEL_FIELD_WHEN, {|| !EmpTy( AllTrim(oModel:GetValue('DADOSADD',"CK3_CODIGO")) ) .and. !Empty(cConsultP) })
    oDadosAd:SetProperty('CK3_DESCRI'   , MODEL_FIELD_WHEN, {|| .F. })
    oDadosAd:SetProperty('CK3_CODIGO'   , MODEL_FIELD_WHEN, {|| AtivaDadosAd(oModel) })
    oDadosAd:SetProperty('CK3_MEMO'     , MODEL_FIELD_WHEN, {|| AtivaDadosAd(oModel) })
    oDadosAd:SetProperty('CK3_MEMO'     , MODEL_FIELD_VALID, {||( validAddic( AllTrim(oModel:GetValue('DADOSADD',"CK3_MEMO")) , oModel:GetOperation() )) })
    oDadosAd:SetProperty('CK3_CODIGO'   , MODEL_FIELD_OBRIGAT, .F. )    
endif

    //Instanciando o modelo
    oModel	:=	MPFormModel():New('FISA160J',,,{|oModel|FSA160JGrv(oModel)})

    //Atribuindo cabeçalho para o modelo
    oModel:AddFields("FISA160J",,oCabecalho)

    If lDadosAd
        oModel:AddFields("DADOSADD", "FISA160J", oDadosAd)
        oModel:SetRelation( 'DADOSADD', {{'CK3_FILIAL', 'xFilial("CK3")'},{'CK3_IDCJ2', 'CJ2_ID'}}, CK3->( IndexKey(1) ))
    EndIf

    //Não permite alterar o código da regra
    oCabecalho:SetProperty('CJ2_CODIGO' , MODEL_FIELD_KEY,  .T. )
    oCabecalho:SetProperty('CJ2_CODIGO' , MODEL_FIELD_VALID, {||( VldCod(oModel) )})

    oCabecalho:SetProperty('CJ2_CST'    , MODEL_FIELD_VALID, {||( VldCST(oModel) )})
    oCabecalho:SetProperty('CJ2_CSTDEV' , MODEL_FIELD_VALID, {||( VldCST(oModel) )})

    oCabecalho:SetProperty('CJ2_DESCST' , MODEL_FIELD_INIT , {||( getInitCST(oModel) )})

    if fisExtCmp('12.1.2510', .T., 'CJ2', 'CJ2_CSTCCT')
        //Mudo os campos dinamicamente
        oCabecalho:SetProperty('CJ2_CSTCAB' , MODEL_FIELD_WHEN, {|| ( Empty(oModel:GetValue('FISA160J',"CJ2_CSTCCT")) )})
        oCabecalho:SetProperty('CJ2_CST'    , MODEL_FIELD_WHEN, {|| ( Empty(oModel:GetValue('FISA160J',"CJ2_CSTCCT")) .and. !Empty(oModel:GetValue('FISA160J',"CJ2_CSTCAB")) )})
        oCabecalho:SetProperty('CJ2_CSTDEV' , MODEL_FIELD_WHEN, {|| ( Empty(oModel:GetValue('FISA160J',"CJ2_CSTCCT")) .and. !Empty(oModel:GetValue('FISA160J',"CJ2_CSTCAB")) )})
        oCabecalho:SetProperty('CJ2_CSTCCT' , MODEL_FIELD_WHEN, {|| ( Empty(oModel:GetValue('FISA160J',"CJ2_CSTCAB")) )})
    endIf
    
    oModel:SetPrimaryKey( {"CJ2_CODIGO","CJ2_ID"} )

    //Adicionando descrição ao modelo
    oModel:SetDescription(STR0003) //"Regras de Escrituração do Tributo"

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função que monta a view da rotina.

@author Erick Dias
@since 13/08/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

    //Criação do objeto do modelo de dados da Interface do Cadastro
    Local oModel     := FWLoadModel( "FISA160J" )

    //Criação da estrutura de dados utilizada na interface do cadastro
    Local oCabecalho := FWFormStruct(2, "CJ2")
    Local oView      := Nil
    Local lCSTCCT    := fisExtCmp('12.1.2510', .T., 'CJ2', 'CJ2_CSTCCT')
    Local oDadosAdd   := Nil

    If lDadosAd
        oDadosAdd  := FWFormStruct(2, "CK3")    
    Endif

    oView:= FWFormView():New()
    oView:SetModel( oModel )

    //Atribuindo formulários para interface
    oView:AddField('VIEW_ESCRITURACAO', oCabecalho, 'FISA160J')

    //Retira os campos da View
    oCabecalho:RemoveField('CJ2_ID')
    oCabecalho:RemoveField('CJ2_ALTERA')
    oCabecalho:RemoveField('CJ2_HRALT')
    oCabecalho:RemoveField('CJ2_DTALT')

    oCabecalho:AddGroup( 'GRUPO_CABE'       , STR0011 , '' , 2 ) //"Definição da Regra de Escrituração"
    oCabecalho:AddGroup( 'GRUPO_INCIDENCIA' , STR0012 , '' , 2 ) //"Incidência"

    if lCSTCCT
        oCabecalho:AddGroup( 'GRUPO_CSTCCT'     , STR0042 , '' , 2 ) //"Código de Classificação Tributária IBS e CBS"
    endIf

    oCabecalho:AddGroup( 'GRUPO_CST'        , STR0013 , '' , 2 ) //"Código da Situação Tributária"
    oCabecalho:AddGroup( 'GRUPO_CSTDEV'     , ""      , '' , 2 )

    oCabecalho:SetProperty( 'CJ2_CODIGO'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO_CABE' )
    oCabecalho:SetProperty( 'CJ2_DESCR'    , MVC_VIEW_GROUP_NUMBER, 'GRUPO_CABE' )

    oCabecalho:SetProperty( 'CJ2_INCIDE'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO_INCIDENCIA' )
    oCabecalho:SetProperty( 'CJ2_STOTNF'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO_INCIDENCIA' )
    oCabecalho:SetProperty( 'CJ2_PERDIF'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO_INCIDENCIA' )
    oCabecalho:SetProperty( 'CJ2_IREDBS'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO_INCIDENCIA' )

    If lNrLivro
        oCabecalho:SetProperty( 'CJ2_NLIVRO'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO_INCIDENCIA' )
    EndIf

    if lCSTCCT
        oCabecalho:SetProperty( 'CJ2_CSTCCT'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO_CSTCCT' )
        oCabecalho:SetProperty( 'CJ2_CCT'      , MVC_VIEW_GROUP_NUMBER, 'GRUPO_CSTCCT' )
        oCabecalho:SetProperty( 'CJ2_CCTVIG'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO_CSTCCT' )
        oCabecalho:SetProperty( 'CJ2_DESCCT'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO_CSTCCT' )
    endIf

    oCabecalho:SetProperty( 'CJ2_CSTCAB'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO_CST' )
    oCabecalho:SetProperty( 'CJ2_DCBCST'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO_CST' )
    oCabecalho:SetProperty( 'CJ2_CST'      , MVC_VIEW_GROUP_NUMBER, 'GRUPO_CST' )
    oCabecalho:SetProperty( 'CJ2_DESCST'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO_CST' )
    
    oCabecalho:SetProperty( 'CJ2_CSTDEV'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO_CSTDEV' )
    oCabecalho:SetProperty( 'CJ2_DCSTDE'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO_CSTDEV' )

    //Ordem dos campos
    oCabecalho:SetProperty("CJ2_CODIGO"  , MVC_VIEW_ORDEM, "01")
    oCabecalho:SetProperty("CJ2_DESCR"   , MVC_VIEW_ORDEM, "02")
    oCabecalho:SetProperty("CJ2_INCIDE"  , MVC_VIEW_ORDEM, "03")
    oCabecalho:SetProperty("CJ2_STOTNF"  , MVC_VIEW_ORDEM, "04")
    oCabecalho:SetProperty("CJ2_PERDIF"  , MVC_VIEW_ORDEM, "05")

    if lCSTCCT
        oCabecalho:SetProperty("CJ2_CSTCCT"  , MVC_VIEW_ORDEM, "06")
        oCabecalho:SetProperty("CJ2_CCT"     , MVC_VIEW_ORDEM, "07")
        oCabecalho:SetProperty("CJ2_CCTVIG"  , MVC_VIEW_ORDEM, "08")
        oCabecalho:SetProperty("CJ2_DESCCT"  , MVC_VIEW_ORDEM, "09")
    endIf

    oCabecalho:SetProperty("CJ2_CSTCAB"  , MVC_VIEW_ORDEM, "10")
    oCabecalho:SetProperty("CJ2_DCBCST"  , MVC_VIEW_ORDEM, "11")
    oCabecalho:SetProperty("CJ2_CST"     , MVC_VIEW_ORDEM, "12")
    oCabecalho:SetProperty("CJ2_DESCST"  , MVC_VIEW_ORDEM, "13")
    oCabecalho:SetProperty("CJ2_CSTDEV"  , MVC_VIEW_ORDEM, "14")
    oCabecalho:SetProperty("CJ2_DCSTDE"  , MVC_VIEW_ORDEM, "15")

    //Alteração dos títulos de alguns campos:
    oCabecalho:SetProperty("CJ2_STOTNF", MVC_VIEW_TITULO, STR0020) //"Total da Nota"
    oCabecalho:SetProperty("CJ2_PERDIF", MVC_VIEW_TITULO, STR0021) //"Percentual de Diferimento"
    oCabecalho:SetProperty("CJ2_CSTCAB", MVC_VIEW_TITULO, STR0022) //"Tabela CST"
    oCabecalho:SetProperty("CJ2_IREDBS", MVC_VIEW_TITULO, STR0040) //"Incidencia Parcela Reduzida"

    if lCSTCCT
        oCabecalho:SetProperty("CJ2_CCTVIG", MVC_VIEW_TITULO, STR0041) //"Vigência Class Trib"
    endIf

    //Seto o layout para que o campo memo fique um pouco maior, preenchendo mais tela
    oView:SetViewProperty( "VIEW_ESCRITURACAO", "SETLAYOUT", { FF_LAYOUT_VERT_DESCR_TOP , 3 } )

    If lDadosAd

        // Alteracoes de alguns campos da CK3
        oDadosAdd:RemoveField("CK3_IDCJ2")
        oDadosAdd:RemoveField("CK3_FILIAL")
        oDadosAdd:RemoveField("CK3_CONTEU")

        oDadosAdd:SetProperty("CK3_CODIGO", MVC_VIEW_TITULO, STR0032 )//"Código do Dado Adicional"
        oDadosAdd:SetProperty("CK3_DESCRI", MVC_VIEW_TITULO, STR0033 )//"Descrição do Dado Adicional"    

        oDadosAdd:AddField( ; // Ord. Tipo Desc.
        'CK3_VALOR' , ; // [01] C Nome do Campo
        '3' , ; // [02] C Ordem
        AllTrim( STR0029 ) , ; // [03] C Titulo do campo
        AllTrim( STR0029 ) , ; // [04] C Descrição do campo
        { STR0029 } , ; // [05] A Array com Help
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
        'CK3_VALORSXB' , ; // [01] C Nome do Campo
        '3' , ; // [02] C Ordem
        AllTrim( STR0030 ) , ; // [03] C Titulo do campo
        AllTrim( STR0030 ) , ; // [04] C Descrição do campo
        { STR0030 } , ; // [05] A Array com Help
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
        'CK3_MEMO' , ; // [01] C Nome do Campo
        '4' , ; // [02] C Ordem
        AllTrim( STR0034 ) , ; // [03] C Titulo do campo
        AllTrim( STR0034 ) , ; // [04] C Descrição do campo
        { STR0034 } , ; // [05] A Array com Help
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

        oView:AddField( 'VIEW_DADOSADD' , oDadosAdd, 'DADOSADD')
        
        // Grupos de campos
        oDadosAdd:AddGroup( 'GRUPO_INSERI' , STR0035 , '' , 2 ) // "Inserir Dados Adicionais"
        oDadosAdd:AddGroup( 'GRUPO_LISTA'  , STR0036 , '' , 2 ) // "Dados Adicionais Existentes"   

        // Atribuindo os grupos aos campos
        oDadosAdd:SetProperty( 'CK3_CODIGO'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO_INSERI' )
        oDadosAdd:SetProperty( 'CK3_VALOR'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO_INSERI' )    
        oDadosAdd:SetProperty( 'CK3_DESCRI'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO_INSERI' )    
        oDadosAdd:SetProperty( 'CK3_VALORSXB' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_INSERI' )    
        oDadosAdd:SetProperty( 'CK3_MEMO'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO_LISTA' )

        // Atribuindo a consulta dinamica, com base no registro escolhido na CK2
        oDadosAdd:SetProperty('CK3_VALORSXB', MVC_VIEW_LOOKUP, { || fGetF3() } )

        //Divide a tela em duas pastas
        oView:CreateFolder( 'PASTAS' )
        oView:AddSheet( 'PASTAS', 'ABA01', STR0037 ) //"Definição da Regra de Escrituração"
        oView:AddSheet( 'PASTAS', 'ABA02', STR0038 ) //"Dados Adicionais da Escrituração" 

        //Aba da esquerda cheia
        oView:CreateHorizontalBox( 'ESQUERDA', 100,,, 'PASTAS', 'ABA01' ) //Aqui ficarão todos os componentes de tela que já estavam na regra de escrituração (CJ2)

        //Aba da direita com os compoentes de dados adicionais
        oView:CreateHorizontalBox( 'DIREITA_SUPERIOR',  50,,, 'PASTAS', 'ABA02') 
        oView:CreateHorizontalBox( 'DIREITA_INFERIOR',  50,,, 'PASTAS', 'ABA02') 

        //Painel com os botões
        oView:AddOtherObject("BOTOES", {|oPanel| xBtnAdd(oPanel)})

        //Aba da esquerda
        oView:SetOwnerView( 'VIEW_ESCRITURACAO', 'ESQUERDA')   

        //Aba da direita
        oView:SetOwnerView( 'VIEW_DADOSADD'    , 'DIREITA_SUPERIOR')       
        //Botões 
        oView:SetOwnerView( 'BOTOES'           , 'DIREITA_INFERIOR')  

        oView:SetViewProperty( "VIEW_DADOSADD", "SETLAYOUT", { FF_LAYOUT_VERT_DESCR_TOP , 4 } )

        oView:SetFieldAction('CK3_CODIGO' , {|oView| XCK2VAL(oView,oModel) })
    EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} fGetF3
Função que monta a consulta F3 para o campo CK3_VALORSXB

@author Douglas Dourado
@since 14/05/2025
@version 2510

/*/
//-------------------------------------------------------------------
Static Function fGetF3()    
return cConsultP

//-------------------------------------------------------------------
/*/{Protheus.doc} XCK2VAL
Função que monta dinamicamente a consulta do campo CK3_VALORSXB ou CK3_VALOR

@author Douglas Dourado
@since 14/05/2025
@version 2510

/*/
//-------------------------------------------------------------------
Function XCK2VAL(oView,oModel)
Local aOpcoes    := {}
Local cCodigo   := ""
Local cAux     := ""
Local cOpcoes := ""
Local oFormul   := nil

IF ValType(oView) =='O'

    oModel    := FWModelActive()
    oFormul   := oModel:GetModel("DADOSADD")
    cCodigo   := AllTrim(oModel:GetValue('DADOSADD',"CK3_CODIGO"))

    CK2->(dbSetOrder(1))
    If( CK2->(MsSeek(xFilial("CK2")+"1"+cCodigo)) )

        cConsultP := ''
        oFormul:LoadValue("CK3_VALORSXB", "" )
        oFormul:LoadValue("CK3_VALOR", "" )

        //Trecho comentado devido a alteração no projeto reduzindo o escopo de consulta - o trecho será mantido para futuras implementações

        // If CK2->CK2_TPORIG == "C " .AND. !Empty(CK2->CK2_CBOX) // Combobox                
           
        //     aOpcoes := StrTokArr2(CK2->CK2_CBOX, ';' )
        //     oView:SetFieldProperty("VIEW_DADOSADD","CK3_VALOR","COMBOVALUES",{aOpcoes} )                

        // Elseif CK2->CK2_TPORIG == "FT" .AND. !Empty(CK2->CK2_FUNORI) .AND. FindFunction(CK2->CK2_FUNORI) // Por Funcao

        //     cAux := "{|| "+CK2->CK2_FUNORI+" }"
        //     cOpcoes := Eval(&cAux)
        //     aOpcoes := StrTokArr2(cOpcoes, ';' )
        //     oView:SetFieldProperty("VIEW_DADOSADD","CK3_VALOR","COMBOVALUES",{aOpcoes})    

        // Elseif CK2->CK2_TPORIG == "F3" .AND. !Empty(CK2->CK2_CPDRA) // Consulta Padrao (F3)
            
        //     cConsultP := Alltrim(CK2->CK2_CPDRA)       

        // Elseif CK2->CK2_TPORIG == "X5" .AND. !Empty(CK2->CK2_TABGEN) // Tabela Generica (SX5)
            
        //     cConsultP := Alltrim(CK2->CK2_TABGEN)       

        // Endif

        cAux := "{|| "+CK2->CK2_FUNORI+" }"
        cOpcoes := Eval(&cAux)
        aOpcoes := StrTokArr2(cOpcoes, ';' )
        oView:SetFieldProperty("VIEW_DADOSADD","CK3_VALOR","COMBOVALUES",{aOpcoes})
 
        oFormul:LoadValue("CK3_DESCRI", Alltrim(CK2->CK2_DESCRI) )
                
        oView:Refresh()   
    Else
        Help( ,, 'Help',,STR0039 + cCodigo, 1, 0 ) 
    EndIf     
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddDadosAd
Função que adiciona os dados adicionais no MEMO via botao "Adicionar"

@author Douglas Dourado
@since 14/05/2025
@version 2510

/*/
//-------------------------------------------------------------------
Static Function AddDadosAd()

Local oModel := FWModelActive()
Local cCodigo    := AllTrim(oModel:GetValue('DADOSADD',"CK3_CODIGO"))
Local cValSXB    := AllTrim(oModel:GetValue('DADOSADD',"CK3_VALORSXB"))
Local cValor     := AllTrim(oModel:GetValue('DADOSADD',"CK3_VALOR"))
Local cOldMemo   := AllTrim(oModel:GetValue('DADOSADD',"CK3_MEMO"))
Local oDadosAd	 := oModel:GetModel('DADOSADD')
Local oView       := FWViewActive()
Local cNewChave  := ""
Local nOperation := oModel:GetOperation()
Local lValidOp   := (nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE)

If !lValidOp
    Help( ,, 'Help',,STR0025, 1, 0 ) // A operação não é válida para adicionar dados adicionais 
    Return    
EndIf    

If Empty(cCodigo)
    Help( ,, 'Help',,STR0026, 1, 0 )  // Código do Dado Adicional não pode ser vazio
    Return
EndIf

// Linha comentada devido a alteração no projeto reduzindo o escopo de consulta - o trecho será mantido para futuras implementações
// If Empty(cValor) .and. Empty(cValSXB)
//     Help( ,, 'Help',, STR0027 , 1, 0 ) // Valor do Dado Adicional não pode ser vazio
//     Return
// EndIf

If cCodigo $ cOldMemo
    Help( ,, 'Help',,STR0028 + cCodigo, 1, 0 ) // Código do Dado Adicional já existe na lista: 
    Return
EndIf

If !Empty(cConsultP) .and. !Empty(cValSXB)
    //cNewChave  := cCodigo + ":" + cValSXB + "|"
Elseif Empty(cConsultP) .and. Empty(cValSXB) .and. !Empty(cValor)
    cNewChave  := cCodigo + ":" + cValor + "|" 
EndIf

oDadosAd:LoadValue( 'CK3_MEMO', (cOldMemo + cNewChave) )
oView:Refresh()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} validAddic
Função que valida se existe codigos duplicados no MEMO

@param cMemoCK3 Conteúdo do MEMO CK3_MEMO
@param nOperation Tipo de operação do modelo (inserção ou alteração)
@return .T. se não houver códigos duplicados, .F. caso contrário
@author Douglas Dourado
@since 25/08/2025
@version 2510

/*/
//-------------------------------------------------------------------
Static Function validAddic( cMemoCK3 , nOperation )
Local lRet := .T.
Local nX := 0
Local aAux := {}
Local aDadosAdd := {}

If (nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE) .and. !Empty(cMemoCK3)
    aDadosAdd := MemoToArr(cMemoCK3) 

    For nX := 1 To Len(aDadosAdd)
        If !Empty(aDadosAdd[nX])
            If Ascan( aAux , aDadosAdd[nX][1] ) > 0                
                Help( ,, 'Help',,STR0028 + aDadosAdd[nX][1], 1, 0 ) // Código do Dado Adicional já existe na lista
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

@author Douglas Dourado
@since 14/05/2025
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
/*/{Protheus.doc} VldCod
Função que valida se o código de regra  já existe

@author Erick Dias
@since 13/08/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function VldCod(oModel)

Local lRet      := .T.

dbSelectArea("CJ2")
dbSetOrder(1) 

//Verifico se na inclusão o código já foi utilizado
IF oModel:GetOperation() == MODEL_OPERATION_INSERT .AND. CJ2->( MsSeek ( xFilial('CJ2') + oModel:GetValue ('FISA160J',"CJ2_CODIGO") ) )
    Help( ,, 'Help',,STR0004, 1, 0 ) //"Código da Regra de Escrituração já cadastrada"
    return .F.
EndIF

Return lRet

//------------------------------------------------------------
/*/{Protheus.doc} VldCST
Função de validação do CST

@author Erick Dias
@since 17/08/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function VldCST(oModel)

    Local cCst      := oModel:GetValue ('FISA160J',"CJ2_CST")
    Local cCstTab   := oModel:GetValue ('FISA160J',"CJ2_CSTCAB")
    Local cCstDev   := oModel:GetValue ('FISA160J',"CJ2_CSTDEV")
    Local cClassTrib:= ""

    dbSelectArea("CJ1")
    dbSetOrder(2) 

    if fisExtCmp('12.1.2510', .T., 'CJ2', 'CJ2_CSTCCT')
        cClassTrib := oModel:GetValue ('FISA160J',"CJ2_CSTCCT")
    endIf

    IF Empty(cClassTrib) .And. (!Empty(cCst) .AND. !Empty(cCstTab) .AND. !CJ1->( MsSeek ( xFilial('CJ1') + cCstTab + cCst ) )) .Or. (!Empty(cCstDev) .AND. !Empty(cCstTab) .AND. !CJ1->( MsSeek ( xFilial('CJ1') + cCstTab + cCstDev ) ))
        //Código inválido
        Help( ,, 'Help',,STR0023, 1, 0 ) //"Código de CST inválido"
        return .F.

    Elseif Empty(cClassTrib) .And. (!Empty(cCst) .AND. Empty(cCstTab)) .Or. (!Empty(cCstDev) .AND. Empty(cCstTab))
        //Informar tabela primeiro
        Help( ,, 'Help',,STR0024, 1, 0 ) //"Por favor, informe primeiro o código da tabela de CST"
        return .F.
    EndIF

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA160JGrv
Função que fará controle para gravação da tabela CJ2, com controle
de histórico

@author Erick Dias
@since 14/08/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function FSA160JGrv(oModel)

    Local nOperation 	:= oModel:GetOperation()
    Local cCodigo       := oModel:GetValue ('FISA160J',"CJ2_CODIGO")   
    Local cDescr        := oModel:GetValue ('FISA160J',"CJ2_DESCR")   
    Local cIncide       := oModel:GetValue ('FISA160J',"CJ2_INCIDE")  
    Local cStotNf       := oModel:GetValue ('FISA160J',"CJ2_STOTNF")  
    Local nPerDif       := oModel:GetValue ('FISA160J',"CJ2_PERDIF")  
    Local cCabCST       := oModel:GetValue ('FISA160J',"CJ2_CSTCAB")  
    Local cCst          := oModel:GetValue ('FISA160J',"CJ2_CST")   
    Local cCstDev       := oModel:GetValue ('FISA160J',"CJ2_CSTDEV")   
    Local cIncRed       := oModel:GetValue ('FISA160J',"CJ2_IREDBS")   
    Local cClassTrib    := ""
    Local dVigClassTRib := cTod("  /  /    ")
    Local cCCT          := ""
    Local lChvMD5       := CJ2->(FieldPos('CJ2_CHVMD5') > 0)
    Local cChvMD5       := ""
    Local cMemoCK3      := ""
    Local cUUid         := ""
    Local cNLivro       := ""

    if fisExtCmp('12.1.2510', .T., 'CJ2', 'CJ2_CSTCCT')
        cClassTrib    := oModel:GetValue ('FISA160J',"CJ2_CSTCCT")   
        dVigClassTRib := oModel:GetValue ('FISA160J',"CJ2_CCTVIG")   
        cCCT          := oModel:GetValue ('FISA160J',"CJ2_CCT")   
    endIf
    If lNrLivro
        cNLivro := oModel:GetValue ('FISA160J',"CJ2_NLIVRO")
    EndIf

    If nOperation == MODEL_OPERATION_INSERT .Or.  nOperation == MODEL_OPERATION_UPDATE

        //Na edição preciso alterar o flag como alterado para manter o histórico de alterações
        If nOperation == MODEL_OPERATION_UPDATE
            
            //Chama função para alterar registro atual        
            GravaCJ2(2, cCodigo, cDescr, cIncide, cStotNf,nPerDif, cCst, cCabCST,cIncRed,cCstDev,,,,,cNLivro)

        EndIF

        If ( lChvMD5 )
            cChvMD5 := GetChvMd5()
        EndIf    

        //Agora chamo função para inserir novo registro, seja na operação de inclusão ou edição.
        cUUid := GravaCJ2(1, cCodigo, cDescr, cIncide, cStotNf,nPerDif, cCst, cCabCST, cIncRed, cCstDev, cChvMD5, cClassTrib, dVigClassTRib, cCCT , cNLivro)
    
        If lDadosAd
            cMemoCK3 := AllTrim(oModel:GetValue('DADOSADD',"CK3_MEMO"))
            If !Empty(cMemoCK3)        
                GravaCK3( cUUid , cMemoCK3 ) 
            EndIf
        EndIf
        
    ElseIf nOperation == MODEL_OPERATION_DELETE

        //Faz exclusão do registro
        RecLock("CJ2",.F.)
        CJ2->(dbDelete())
        MsUnLock()

        If lDadosAd
            cUUid := AllTrim(oModel:GetValue('FISA160J',"CJ2_ID"))

            If !Empty(cUUid)        
                DeleteCK3( cUUid )
            EndIf
        EndIf

    EndIF

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaCJ2
Função que fará a presistência na tabela CJ2

@author Erick Dias
@since 14/08/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function GravaCJ2(nOpc, cCodigo, cDescr, cIncide, cStotNf,nPerDif, cCst, cCabCST, cIncRed, cCstDev, cChvMD5, cClassTrib, dVigClassTRib, cCCT , cNLivro)
Local cUUid := ""

    If nOpc == 1 //Inclusão
        
        RecLock("CJ2",.T.)
    cUUid     := FWUUID("CJ2")
        CJ2->CJ2_FILIAL := xFilial("CJ2")    
        CJ2->CJ2_ID     := cUUid
        CJ2->CJ2_CODIGO := cCodigo
        CJ2->CJ2_DESCR  := cDescr
        CJ2->CJ2_INCIDE := cIncide
        CJ2->CJ2_STOTNF := cStotNf
        CJ2->CJ2_PERDIF := nPerDif
        CJ2->CJ2_CSTCAB := cCabCST
        CJ2->CJ2_CST    := cCst
        CJ2->CJ2_CSTDEV := cCstDev
        CJ2->CJ2_IREDBS := cIncRed
        CJ2->CJ2_ALTERA := "2" //Indica sem alterações
        
        if fisExtCmp('12.1.2510', .T., 'CJ2', 'CJ2_CSTCCT')
            CJ2->CJ2_CSTCCT := cClassTrib //Indica sem alterações
            CJ2->CJ2_CCTVIG := dVigClassTRib //Indica sem alterações
            CJ2->CJ2_CCT    := cCCT //Indica sem alterações
        endIf

        If lNrLivro
            CJ2->CJ2_NLIVRO := cNLivro
        EndIf

        If ( !Empty(cChvMD5) )
            CJ2->CJ2_CHVMD5 := cChvMD5
        EndIf

        MsUnLock()

    Elseif nOpc == 2
        
        RecLock("CJ2",.F.)
        CJ2->CJ2_ALTERA := "1" //Indica que sofreu alterações
        CJ2->CJ2_DTALT := Date()
        CJ2->CJ2_HRALT := Time()
        MsUnLock()

    EndIF

Return cUUid

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaCK3
Função que grava os dados adicionais na tabela CK3

@author Douglas Dourado
@since 14/05/2025
@version 2510

/*/
//-------------------------------------------------------------------
Static Function GravaCK3( cIdCJ2, cMemoCK3 )
Local aDadosAdd := {}
Local nX := 0

    aDadosAdd := MemoToArr(cMemoCK3) 

    For nX := 1 To Len(aDadosAdd)
        If !Empty(aDadosAdd[nX])
            RecLock("CK3",.T.)
                CK3->CK3_FILIAL := xFilial("CK3")    
                CK3->CK3_IDCJ2 := cIdCJ2        
                CK3->CK3_CODIGO := aDadosAdd[nX][1]        
                CK3->CK3_CONTEU := aDadosAdd[nX][2]        
            MsUnLock()
        EndIf    
    Next

    aSize(aDadosAdd, 0)
    aDadosAdd := Nil

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaCK3
Função que transforma o MEMO em array para persistir na tabela CK3

@author Douglas Dourado
@since 14/05/2025
@version 2510

/*/
//-------------------------------------------------------------------
Static Function MemoToArr(cMemoCK3)
Local aDadosAdd := {}
Local aMemoCK3 := {}
Local nX := 0
Local aAux := {}

    aMemoCK3 := StrTokArr2( Alltrim(cMemoCK3) , '|')
    
    dbSelectArea("CK2")
    CK2->(dbSetOrder(1))    

    If !Empty(aMemoCK3) .and. Len(aMemoCK3) > 0
        For nX := 1 To Len(aMemoCK3)
            aAux := StrTokArr2( Alltrim(aMemoCK3[nX]) , ':' )
            If !Empty(aAux) .and. Len(aAux) == 2
                If !Empty(aAux[1]) .and. !Empty(aAux[2])
                    If( CK2->(MsSeek(xFilial("CK2")+"1"+ Alltrim(aAux[1]) )) )
                        AADD(aDadosAdd , aAux)            
                    EndIf
                EndIf
            EndIf        
        Next
    EndIf

    FWFreeArray(aMemoCK3)

Return aDadosAdd

//-------------------------------------------------------------------
/*/{Protheus.doc} DeleteCK3
Função que exclui os dados adicionais na tabela CK3

@author Douglas Dourado
@since 14/05/2025
@version 2510

/*/
//-------------------------------------------------------------------
Static Function DeleteCK3( cIdCJ2 )

    DbSelectArea("CK3")
    CK3->(dbSetOrder(1)) // CK3_FILIAL, CK3_IDCJ2, CK3_CODIGO, R_E_C_N_O_, D_E_L_E_T_

    While ( CK3->(MsSeek(FwxFilial("CK3") + cIdCJ2)) )
        RecLock("CK3",.F.)
        CK3->(dbDelete())
        MsUnLock()
    EndDo

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCK3
Função que retorna os dados adicionais na tabela CK3

@author Douglas Dourado
@since 14/05/2025
@version 2510

/*/
//-------------------------------------------------------------------
Function GetCK3( cIdCJ2 )
Local cQry		:= ""
Local cMemoCK3	:= ""
Local nOrder	:= 1
Local oModel := FWModelActive()
Local nOperation 	:= oModel:GetOperation()
Local cAliasTemp
Default cIdCJ2  := AllTrim(oModel:GetValue('FISA160J',"CJ2_ID")) 

    If nOperation == MODEL_OPERATION_INSERT
        Return ""
    EndIf

    cQry := " SELECT CK3_CODIGO, CK3_CONTEU" 
    cQry += " FROM ? "
    cQry += " WHERE CK3_FILIAL  = ? "
    cQry += " AND CK3_IDCJ2 = ? "   
    cQry += " AND D_E_L_E_T_ = ? "

    oCK3 := FWExecStatement():New(ChangeQuery(cQry))
    nOrder := 1

    oCK3:SetUnsafe(nOrder++, RetSqlName("CK3"))
    oCK3:SetString(nOrder++,xFilial("CK3"))
    oCK3:SetString(nOrder++,cIdCJ2 )
    oCK3:SetString(nOrder++," " )

    cAliasTemp:= oCK3:OpenAlias()

    DbSelectArea(cAliasTemp)
    (cAliasTemp)->(DbGoTop())
    While (cAliasTemp)->(!Eof())
        cMemoCK3 += Alltrim((cAliasTemp)->CK3_CODIGO) + ":" + Alltrim((cAliasTemp)->CK3_CONTEU) + "|"
        (cAliasTemp)->(DbSkip())	
    EndDo

    (cAliasTemp)->(DbCloseArea())    
    oCK3:Destroy()
	oCK3:= nil

Return cMemoCK3

//-------------------------------------------------------------------
/*/{Protheus.doc} AtivaDadosAd
Função que ativa ou nao os campos de dados adicionais

@author Douglas Dourado
@since 14/05/2025
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
/*/{Protheus.doc} FSA160JHist
Função que exibirá Browse com o histórico de alteações da rotina

@author Erick Dias
@since 24/06/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function FSA160JHist()
Local cFiltro   := ""
Local aColunas  := {}

//Adicionando as colunas de Data e horario de alteração, pois o UPDDISTR não altera o X3_BROWSE, por isso estou adicionado a coluna manualmente.
/* Posições dos arrays
1 - Título
2 - Codeblock para carregra a ~informação
3 - Tipo
4 - Alinhamento (1 alinhado a esquera)
5 - Tamanho
6 - Decimal
7 - Indica se permite alteração
*/
AADD(aColunas,{ STR0014, &("{ || IIf(CJ2->CJ2_ALTERA == '1','" + STR0015 + "','" + STR0016 + "') }"), "C", "", 1, 1, 0, .f.}) //"Status - ALterado - Nõo alterado"
AADD(aColunas,{ STR0017, &("{ || CJ2->CJ2_DTALT }"), "D", "", 1, 1, 0, .f.}) //"Data de Alteração"
AADD(aColunas,{ STR0018, &("{ || Alltrim(CJ2->CJ2_HRALT) }"), "C", "", 1, 1, 0, .f.}) //"Horário de Alteração"

//Atribuo o Alias para variavel pública 
c170AlsHist := "CJ2"

//Monto o filtro abaixo somente com linhas que foram alteradas e não estão mais vigentes
cFiltro :="CJ2_FILIAL == '" + xFilial("CJ2") + "'"
cFiltro	+= " .AND. CJ2_CODIGO == '" + CJ2->CJ2_CODIGO +  "'"

//Utilizo segundo índice para facilitar a visualização
CJ2->(DbSetOrder(4))

//Chamo a função auxiliar que montará o Browse com as regras alteradas.
FSA16XHist("CJ2", cFiltro, STR0019 , aColunas) //"Histórico de Alterações da Regra de Cálculo de Tributo"

//Retorno o Alias e filtro padrão
c170AlsHist := ""
CJ2->(DbSetOrder(1))

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} 160JVTotDp
Função que irá retornar a lista do combo para o campo CJ2_STOTNF

@author Renato Rezende
@since 31/08/2020
@version P12.1.31
/*/
//-------------------------------------------------------------------
Function x160JTotDp()

Local cRet	:= ""

cRet+="1=Sem Ação;"
cRet+="2=Subtrai somente do total da nota;"
cRet+="3=Subtrai do total da nota e da duplicata;"
cRet+="4=Subtrai somente do total da duplicata;"
cRet+="5=Soma somente no total da nota;"
cRet+="6=Soma no total da nota e da duplicata;"
cRet+="7=Soma somente no total da duplicata;"
cRet+="8=Gross up no total da duplicata"

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetChvMd5
Função para atualização do campo MD5.

@author Juliano Fernandes
@since 25/04/2024
@version P12.1.2310
/*/
//-------------------------------------------------------------------
static function GetChvMd5()

    local oModel := FWModelActive()
    local cChave := ''
    local cPrefixo := 'CONFITRIB-' 
    local cChvMd5 := ''
    local lIsClassification := FWIsInCallStack('IntegraRegras')

    if ( lIsClassification )
        cPrefixo := 'CLASSTRIB-'
    endif

    cChave := oModel:GetValue('FISA160J', 'CJ2_INCIDE')
    cChave += oModel:GetValue('FISA160J', 'CJ2_STOTNF')
    cChave += CValToChar(oModel:GetValue('FISA160J', 'CJ2_PERDIF'))
    cChave += oModel:GetValue('FISA160J', 'CJ2_IREDBS')
    cChave += oModel:GetValue('FISA160J', 'CJ2_CSTCAB')
    cChave += oModel:GetValue('FISA160J', 'CJ2_CST')
    cChave += oModel:GetValue('FISA160J', 'CJ2_CSTDEV')

    if fisExtCmp('12.1.2510', .T., 'CJ2', 'CJ2_CSTCCT')
        cChave += oModel:GetValue('FISA160J', 'CJ2_CSTCCT')
        cChave += dToS(oModel:GetValue('FISA160J', 'CJ2_CCTVIG'))
    endIf

    cChvMd5 := cPrefixo + Md5(cChave)

return cChvMd5

//-------------------------------------------------------------------
/*/{Protheus.doc} getInitCST
Crio um inicializador padrão para preencher a descrição do CST, pois pode ser apresentado pela tabela de CST (CJ1) ou pelo cClassTrib (CKB)

@param oModel, object, modelo de dados da rotina FISA160J
@return cResult, character, retorna a descrição do CST ou Classificação Tributária
@author Matheus Bispo
@since 17/06/2025
@type static function
@version P12.1.2510

/*/
//-------------------------------------------------------------------
static function getInitCST(oModel)

    local cCSTCab := oModel:GetValue('FISA160J', 'CJ2_CSTCAB')
    local cCST := oModel:GetValue('FISA160J', 'CJ2_CST')
    local cClassTrib := ""
    local cResult := ""
    local dVigClassTrib := cTod("  /  /    ")
    local lInclude := oModel:GetOperation() == MODEL_OPERATION_INSERT

    if fisExtCmp('12.1.2510', .T., 'CJ2', 'CJ2_CSTCCT')
        cClassTrib := oModel:GetValue('FISA160J', 'CJ2_CSTCCT')
        dVigClassTrib := oModel:GetValue('FISA160J', 'CJ2_CCTVIG')
    endIf

    if !lInclude
        if !Empty(cCSTCab)
            cResult := Posicione("CJ1", 2, xFilial("CJ1") + cCSTCab + cCST + "2", "CJ1_DESCR")
        elseif !Empty(cClassTrib)
            cResult := Posicione("CKB", 1, xFilial("CKB") + cClassTrib + dToS(dVigClassTrib), "CKB_DESCST")
        endif
    endif

return cResult

//-------------------------------------------------------------------
/*/{Protheus.doc} F160JVIG
Usada no gatilho do campo CJ3_CSTCCT (Regra) para buscar a data de vigencia mais recente caso o usuario digite o codigo na mao, sem uso de consulta padrao (F3)

@param nil, nil, nao ha
@return dVigencia, date, retorna a data  de vigencia mais recente cadastrada na CKB
@author Matheus Bispo
@since 03/07/2025
@type Function
@version P12.1.2510

/*/
//-------------------------------------------------------------------
Function F160JVIG()
    Local oQryTmp := nil
    Local cQuery := ""
    Local cAlias := ""
    Local dVigencia := CTOD("  /  /  ")

    // Monta a query para buscar a data mais atual
    cQuery := " SELECT MAX(CKB_DTINI) AS CKB_DTINI "
    cQuery += " FROM " + RetSQLName("CKB") + " CKB "
    cQuery += " WHERE CKB.CKB_FILIAL = ? "
    cQuery += " AND CKB.CKB_CSTCCT = ? "
    cQuery += " AND CKB.D_E_L_E_T_ = ? "

    oQryTmp := FWExecStatement():new(cQuery)

    oQryTmp:setString(1, xFilial("CKB"))
    oQryTmp:setString(2, M->CJ2_CSTCCT) // Obtém o valor do campo CJ2_CSTCCT do modelo
    oQryTmp:setString(3, " ")

    cAlias := oQryTmp:OpenAlias(GetNextAlias())

    dVigencia := sToD((cAlias)->CKB_DTINI)

    oQryTmp:destroy()
    oQryTmp := nil 

    (cAlias)->(dbCloseArea())

return dVigencia
