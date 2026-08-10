#Include "loca229b.ch"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} MODELDEF
Definicão do modelo de 
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/12/2025
@return variant, Modelo do romaneio
/*/
STATIC FUNCTION MODELDEF()
Local oModel := FwLoadModel("LOCA229A")
Local oStruFQV := FWFormStruct( 1, 'FQV', /*bAvalCampo*/,/*lViewUsado*/ )


// Adiciona ao modelo uma estrutura de formulário de edição por Grid
oModel:AddGrid( 'GRID', "FQUMASTER", oStruFQV, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

oModel:GetModel( 'GRID' ):SetDescription(STR0001) //'Demanda' //"Itens do Romaneio"
//Setando a chave primária da rotina
oModel:SetRelation( 'GRID', { { 'FQV_FILIAL', 'xFilial("FQV")' } ,{"FQV_NUM","FQU_NUM"}}, FQV->( IndexKey( 1 ) ) )
    
oModel:GetModel( 'GRID' ):SetNoInserLine(.T.)
oModel:GetModel( 'GRID' ):SetNoDeleteLine(.T.)

Return oModel


/*/{Protheus.doc} ViewDef
Define a View da Demanda
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/12/2025
@return variant, Retorna a view da demanda
/*///-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'LOCA229B' )
Local oStruFQU := FWFormStruct( 2, 'FQU', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruFQV := FWFormStruct( 2, 'FQV', /*bAvalCampo*/,/*lViewUsado*/ )
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_FQU', oStruFQU, 'FQUMASTER' )
oView:AddGrid( 'VIEW_FQV', oStruFQV, 'GRID' )

oView:SetViewProperty("GRID", "GRIDSEEK",    {.T.})
oView:SetViewProperty("GRID", "GRIDFILTER", {.T.})
// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'CABEC' , 50 )
oView:CreateHorizontalBox( 'ITENS' , 50 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_FQU', 'CABEC' )
oView:SetOwnerView( 'VIEW_FQV', 'ITENS' )

Return oView
