#Include "loca092.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'

Function LOCA092()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('FPK')
oBrowse:SetDescription(STR0001) //'Monitoramento de Faturamento '
oBrowse:SetTimer({|| oBrowse:Refresh(.T.) }, 30 * 1000) // Timer de REfersh do Browse

oBrowse:AddLegend("FPK->FPK_STATUS = '1'", "GREEN" , STR0002, , .T.) //"Pendente"
oBrowse:AddLegend("FPK->FPK_STATUS = '2'", "ORANGE", STR0003, , ) //"Processando"
oBrowse:AddLegend("FPK->FPK_STATUS = '3'", "BLACK", STR0004, ,.T.) //"Processado"
oBrowse:AddLegend("FPK->FPK_STATUS = '4'", "RED", STR0005, ,.T.) //"Processado com Erro"

oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.LOCA092' OPERATION 2 ACCESS 0 //'Visualizar'
//ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.LOCA092' OPERATION 5 ACCESS 0
//ADD OPTION aRotina TITLE 'Processar'  ACTION 'LOCA021GER()' OPERATION 2 ACCESS 0

Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruFPK := FWFormStruct( 1, 'FPK', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'LOCA092' , /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/)
//oModel := MPFormModel():New('COMP011MODEL', /*bPreValidacao*/, { |oMdl| COMP011POS( oMdl ) }, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'FPKMASTER' , /*cOwner*/, oStruFPK, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( 'Modelo de Log Processamento' )

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'FPKMASTER' ):SetDescription( 'Log de Processamento' )

Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'LOCA092' )
// Cria a estrutura a ser usada na View
Local oStruFPK := FWFormStruct( 2, 'FPK' )
//Local oStruZA0 := FWFormStruct( 2, 'ZA0', { |cCampo| COMP11STRU(cCampo) } )
Local oView


// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_FPK', oStruFPK, 'FPKMASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_FPK', 'TELA' )

Return oView
