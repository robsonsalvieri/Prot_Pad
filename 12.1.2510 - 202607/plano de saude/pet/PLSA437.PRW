#INCLUDE 'TOTVS.CH'
#INCLUDE 'PLSA437.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA437
pai/filho em MVC

@author Rafael.aoliveira
@since 02/12/2025
@version P10
/*/
//-------------------------------------------------------------------
Function PLSA437()
Local oBrowse

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'BO8' )
oBrowse:SetDescription( STR0001 ) //'Cadastro de Espécies'
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Menu Funcional da Rotina 

@author Rafael.Aoliveira
@since 02/2026
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title 'Visualizar'  Action 'VIEWDEF.PLSA437' OPERATION 2 ACCESS 0
ADD OPTION aRotina Title 'Incluir'     Action 'VIEWDEF.PLSA437' OPERATION 3 ACCESS 0
ADD OPTION aRotina Title 'Alterar'     Action 'VIEWDEF.PLSA437' OPERATION 4 ACCESS 0
ADD OPTION aRotina Title 'Excluir'     Action 'VIEWDEF.PLSA437' OPERATION 5 ACCESS 0
ADD OPTION aRotina Title 'Imprimir'    Action 'VIEWDEF.PLSA437' OPERATION 8 ACCESS 0
ADD OPTION aRotina Title 'Copiar'      Action 'VIEWDEF.PLSA437' OPERATION 9 ACCESS 0

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Menu Funcional da Rotina 

@author Rafael.Aoliveira
@since 02/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruBO8 := FWFormStruct( 1, 'BO8', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruBO9 := FWFormStruct( 1, 'BO9', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel

oStruBO9:SetProperty('BO9_CODRAC', MODEL_FIELD_INIT, { |oMdl| IncleCodRac(oMdl)})

oModel := MPFormModel():New( 'PLSA437', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

oModel:AddFields( 'BO8MASTER', /*cOwner*/, oStruBO8 )

oModel:AddGrid( 'BO9DETAIL', 'BO8MASTER', oStruBO9, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

// Faz relaciomanet entre os compomentes do model
oModel:SetRelation( 'BO9DETAIL', { { 'BO9_FILIAL', 'xFilial( "BO9" )' }, { 'BO9_CODESP' , 'BO8_CODESP' } }, BO9->( IndexKey( 1 ) ) )
oModel:SetPrimaryKey({'BO9_CODESP','BO9_RACA'})

// Liga o controle de nao repeticao de linha
oModel:GetModel( 'BO9DETAIL' ):SetUniqueLine( { 'BO9_RACA' } )

oModel:SetDescription( 'Cadastro Pet' )

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'BO8MASTER' ):SetDescription( STR0002 ) //'Dados da Espécies'
oModel:GetModel( 'BO9DETAIL' ):SetDescription( STR0003 ) //'Dados da Raças'

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface com usuário
@author rafael.aolivera
@since 02/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oStruBO8 := FWFormStruct( 2, 'BO8', {|x| !AllTrim(x)+'|' $ "BO8_FILIAL|"} )
Local oStruBO9 := FWFormStruct( 2, 'BO9', {|x| !AllTrim(x)+'|' $ "BO9_FILIAL|BO9_CODESP|"} )

// Cria a estrutura a ser usada na View
Local oModel   := FWLoadModel( 'PLSA437' )
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados ser  utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_BO8', oStruBO8, 'BO8MASTER' )

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_BO9', oStruBO9, 'BO9DETAIL' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 30 )
oView:CreateHorizontalBox( 'INFERIOR', 70 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_BO8', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_BO9', 'INFERIOR' )


oView:EnableTitleView('VIEW_BO9',STR0004) //'Cadastro de Raças'

Return oView


/*/{Protheus.doc} IncleCodRac
    Retorna valor a se adicionado cod raça
    @author rafael.aoliveira
    @since 14/02/2026
/*/
Static Function IncleCodRac(oMdl)

    Local cChv := ""
    Local nOperation:= oMdl:GetOperation()

    if nOperation == MODEL_OPERATION_INSERT
        cChv := M->BO8_CODESP + StrZero(oMdl:NLINE + 1, 3) 
    else
        cChv := BO8->BO8_CODESP + StrZero(oMdl:NLINE + 1, 3)  
    endif
    

Return cChv
