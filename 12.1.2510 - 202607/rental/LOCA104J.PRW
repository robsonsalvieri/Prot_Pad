#Include "loca104j.ch"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} MODELDEF
Definicão do modelo de Consulta a Romaneio de Devolução
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/12/2025
@return variant, Modelo do romaneio
/*/
STATIC FUNCTION MODELDEF()
Local oModel := FwLoadModel("LOCA104A")
Local oStruFQX := FWFormStruct( 1, 'FQX', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruFH2 := FWFormStruct( 1, 'FH2', /*bAvalCampo*/,/*lViewUsado*/ )


// Adiciona ao modelo uma estrutura de formulário de edição por Grid
oModel:AddGrid( 'GRID', "FQWMASTER", oStruFQX, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

oModel:GetModel( 'GRID' ):SetDescription(STR0001) //"Romaneio de Devolução"
//Setando a chave primária da rotina
oModel:SetRelation( 'GRID', { { 'FQX_FILIAL', 'xFilial("FQX")' } ,{"FQX_NUM","FQW_NUM"}}, FQX->( IndexKey( 1 ) ) )
    
oModel:GetModel( 'GRID' ):SetNoInserLine(.T.)
oModel:GetModel( 'GRID' ):SetNoDeleteLine(.T.)

oModel:AddGrid( 'GRIDFH2', 'GRID', oStruFH2, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:GetModel( 'GRIDFH2' ):SetDescription("Equip. Quantif.") //"Equipamentos (Quantificaveis)"
oModel:SetRelation( 'GRIDFH2', { { 'FH2_FILIAL', 'xFilial("FH2")' }, {'FH2_AS', 'FQX_AS'} }, FH2->( IndexKey( 1 ) ) )
oModel:GetModel( 'GRIDFH2' ):SetNoInserLine(.T.)
oModel:GetModel( 'GRIDFH2' ):SetNoDeleteLine(.T.)
oModel:GetModel( 'GRIDFH2' ):SetOptional(.T.)
oModel:GetModel( 'GRIDFH2' ):SetLoadFilter( , "FH2_ROMRET = '"+Alltrim(FQW->FQW_NUM)+"'" )

Return oModel


/*/{Protheus.doc} ViewDef
Define a View da Consulta ao Romameio de Devolução
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/12/2025
@return variant, Retorna a view do Romaneio de Devolução
/*///-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'LOCA104J' )
Local oStruFQW := FWFormStruct( 2, 'FQW', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruFQX := FWFormStruct( 2, 'FQX', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruFH2 := FWFormStruct( 2, 'FH2', {|cCampo| cCampo $ "FH2_CODBEM FH2_NOMBEM "} ,/*lViewUsado*/ )
Local oView

oStruFQW:RemoveField("FQW_STATUS")
// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_FQW', oStruFQW, 'FQWMASTER' )
oView:AddGrid( 'VIEW_FQX', oStruFQX, 'GRID' )
oView:AddGrid( 'VIEW_FH2', oStruFH2, 'GRIDFH2' )

oView:SetViewProperty("GRID",    "GRIDSEEK",   {.T.})
oView:SetViewProperty("GRID",    "GRIDFILTER", {.T.})
oView:SetViewProperty("GRIDFH2", "GRIDSEEK",   {.T.})
oView:SetViewProperty("GRIDFH2", "GRIDFILTER", {.T.})
// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'CABEC' , 35 )
oView:CreateHorizontalBox( 'ITENS' , 35 )
oView:CreateHorizontalBox( 'BENS'  , 30 )  //"Equipamentos Quantificaveis"

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_FQW', 'CABEC' )
oView:SetOwnerView( 'VIEW_FQX', 'ITENS' )
oView:SetOwnerView( 'VIEW_FH2', 'BENS'  )

Return oView
