#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

PUBLISH MODEL REST NAME MATA041

//-------------------------------------------------------------------
/*/{Protheus.doc} MATA041
Cadastro de regra de custo executada através do configurador de tributos.
Esta rotina é executada a partir da rotina FISA0170, não tem execução isolada.

@author reynaldo
@since 28/08/2024
@version 12.1.2410
/*/
//-------------------------------------------------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Itens de menu para a rotina

@author reynaldo
@since 28/08/2024
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.MATA041' OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.MATA041' OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.MATA041' OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.MATA041' OPERATION 5 ACCESS 0

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Estrutura da Modelagem dos dados

@author reynaldo
@since 28/08/2024
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStructTable := FWFormStruct( 1, 'D4H', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('MATA041', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'D4HMASTER', /*cOwner*/, oStructTable, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( 'Definição da regra de Custo' )

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'D4HMASTER' ):SetDescription( 'Regra de Custo' )

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Modelagem dos dados a serem apresentados

@author reynaldo
@since 28/08/2024
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'MATA041' )
// Cria a estrutura a ser usada na View
Local oStructTable := FWFormStruct( 2, 'D4H' )
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_D4H', oStructTable, 'D4HMASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_D4H', 'TELA' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} MATA041Inf
Retorna as informações da rotina para o configurador de tributos

Chamada é feita pela função FSA170FUNC() no fonte FISA170.PRW

@author reynaldo
@since 28/08/2024
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Function MATA041Inf(aRet)
   aRet[1] 	:= 'MATA041'
   aRet[2] 	:= "D4H"
   aRet[3] 	:= ""
   aRet[4] 	:= "Regras Custos"

Return .T.
