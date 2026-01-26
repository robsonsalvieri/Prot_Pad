
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FSMA001
Negociação
@author Vitor kwon
@since 30/10/2023
@version 1.0
/*/
//-------------------------------------------------------------------

PUBLISH MODEL REST NAME FSMVENDEDOR source FSMA001 RESOURCE OBJECT FsmRestModel
Function FSMA001()

Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( 'Vendedores Field' ) 
oBrowse:SetAlias( "SA3" )
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Vitor kwon
@since 30/10/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { 'Pesquisar', "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"


Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Negociação
@author Vitor Kwon
@since 30/20/2023
@version 1.0
@obs FSMASA1 - Dados do Negociação

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel    := NIL
Local oStFSMSA3 := FWFormStruct( 1, "SA3" )
//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "FSMA001", /*Pre-Validacao*/, /*Pos-Validacao*/,,/*Commit*/,/*Cancel*/)
oModel:AddFields( "FSMASA3", NIL, oStFSMSA3, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( 'Vendedores' ) 

oModel:GetModel( "FSMASA3" ):SetDescription( 'Vendedores' ) 


Return oModel

