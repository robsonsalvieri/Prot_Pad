#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GFEA049.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA049

Cadastro de Exceção Item Embarcador

@author Felipe Rafael Mendes
@since 10/09/10
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFEA049()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("GUK")					// Alias da tabela utilizada
oBrowse:SetMenuDef("GFEA049")			    // Nome do fonte onde esta a função MenuDef
oBrowse:SetDescription("Configuração de Itens com Exceção") //"Exceção Item Embarcador"

oBrowse:Activate()                                       

Return(Nil)

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
//-------------------------------------------------------------------
// Adiciona botões do browse
//-------------------------------------------------------------------
ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"        OPERATION 1  ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.GFEA049" OPERATION 2  ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.GFEA049" OPERATION 3  ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.GFEA049" OPERATION 4  ACCESS 0 //"Alterar"  
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.GFEA049" OPERATION 5  ACCESS 0 //"Excluir" 
ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.GFEA049" OPERATION 8  ACCESS 0 //"Imprimir"

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel

Local oStructGUK := FWFormStruct(1,"GUK")

// cID     Identificador do modelo 
// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
// bPost   Code-Block de validação do formulário de edição
// bCommit Code-Block de persistência do formulário de edição
// bCancel Code-Block de cancelamento do formulário de edição
oModel := MPFormModel():New("GFEA049", /*bPre*/, /*bPost*/, /*bCommit*/, /*bCancel*/)
// cId          Identificador do modelo
// cOwner       Identificador superior do modelo
// oModelStruct Objeto com  a estrutura de dados
// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
// bPost        Code-Block de validação do formulário de edição
// bLoad        Code-Block de carga dos dados do formulário de edição
oModel:AddFields("GFEA049_GUK", Nil, oStructGUK,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetPrimaryKey({"GUK_FILIAL", "GUK_ITEM"})
oModel:SetDescription("Itens com Exceção")

Return oModel

Static Function ViewDef()

Local oModel := FWLoadModel("GFEA049")
Local oView  := Nil

oView := FWFormView():New()
// Objeto do model a se associar a view.
oView:SetModel(oModel)
// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
// oStruct - Objeto do model a se associar a view.
// cLinkID - Representa o ID criado no Model ,Só é necessári o caso estamos mundando o ID no View.
oView:AddField( "GFEA049_GUK" , FWFormStruct(2,"GUK"), /*cLinkID*/ )	//
// cID		  	Id do Box a ser utilizado 
// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. é a qtd de pixel exato)
// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas criações uma dentro da outra.
// lFixPixel	Determina que o valor passado no nPercHeight é na verdade a qtd de pixel a ser usada.
// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, é necessário informar o cIDSheet
// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
oView:CreateHorizontalBox( "MASTER" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
// Associa um View a um box
oView:SetOwnerView( "GFEA049_GUK" , "MASTER" )   

Return oView  