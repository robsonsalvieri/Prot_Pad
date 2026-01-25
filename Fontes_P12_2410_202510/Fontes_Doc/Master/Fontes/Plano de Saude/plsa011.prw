
#include "PLSMGER.CH"
#include "PROTHEUS.CH"
#include "plsa011.ch"
#include "fwbrowse.ch"
#include "fwmvcdef.ch"

//-----------------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------------

/*/ {Protheus.doc} PLSA011
Tela de Cadastro de Grupos de Serviço
@author Renan Marinho
@since 02/2023
@version P12 
/*/
Function PLSA011(lAutomato)

Local oBrowse

//Instancia objeto
oBrowse := FWMBrowse():New()

//Define tabela de origem do Browse
oBrowse:SetAlias('BH7')

//Define nome da tela
oBrowse:SetDescription(STR0001) //Cadastro de Grupo de servico

If(!lAutomato,oBrowse:Activate(),)

//AxCadastro("BH7","Cadastro de Grupos de Servico")
Return

//-----------------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------------

/*/{Protheus.doc} MenuDef
Menus
@author Renan Marinho
@since 02/2023
@version P12 
/*/
Static Function MenuDef()
Local aRotina := {}

Add Option aRotina Title  STR0002 Action "VIEWDEF.PLSA011" Operation 2 Access 0  //Visualizar
Add Option aRotina Title  STR0003 Action 'VIEWDEF.PLSA011' Operation 3 Access 0  //Incluir
Add Option aRotina Title  STR0004 Action 'VIEWDEF.PLSA011' Operation 4 Access 0  //Alterar
Add Option aRotina Title  STR0005 Action 'VIEWDEF.PLSA011'	Operation 5 Access 0  //Excluir

Return aRotina //StaticCall(MATXATU,MENUDEF)

//-----------------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------------

/*/{Protheus.doc} ModelDef
Definição do modelo de Dados.
@author Renan Marinho
@since 02/2023
@version P12
/*/
Static Function ModelDef()
Local oModel                            // Modelo de dados construído
Local oStrBH7	:= FWFormStruct(1,'BH7')// Cria as estruturas a serem usadas no Modelo de Dados, ajustando os campos que irá considerar

oModel := MPFormModel():New( 'PLSA011') // Cria o objeto do Modelo de Dados

// Adiciona ao modelo um componente de formulário
oModel:AddFields( 'BH7MASTER', /*cOwner*/, oStrBH7 )
 
// Adiciona a descrição do Modelo de Dados
oModel:SetDescription(STR0001)  //Cadastro de grupo de serviço

// Adiciona a descrição dos Componentes do Modelo de Dados
oModel:GetModel( 'BH7MASTER' ):SetDescription(STR0001)

oModel:SetPrimaryKey({"BH7_FILIAL", "BH7_CODIGO"}) 

Return oModel // Retorna o Modelo de dados

//-----------------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------------

/*/{Protheus.doc} ViewDef
Definição da interface.
@author Renan Marinho
@since 02/2023
@version P12
/*/
Static Function ViewDef()                   // Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
Local oView                                 // Interface de visualização construída
Local oModel	:= FWLoadModel( 'PLSA011' ) // Cria as estruturas a serem usadas na View
Local oStrBH7	:= FWFormStruct(2,'BH7')

oModel:SetPrimaryKey({"BH7_FILIAL", "BH7_CODIGO"}) 

// Cria o objeto de View
oView := FWFormView():New()

// Define qual Modelo de dados será utilizado
oView:SetModel( oModel )

// Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)
oView:AddField( 'VIEW_BH7', oStrBH7, 'BH7MASTER' )

// Cria um "box" horizontal para receber cada elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 100 )
//oView:CreateHorizontalBox( 'TELA', 100 )

// Relaciona o identificador (ID) da View com o "box" para exibição
oView:SetOwnerView( 'VIEW_BH7', 'SUPERIOR' )

Return oView

//-----------------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------------



