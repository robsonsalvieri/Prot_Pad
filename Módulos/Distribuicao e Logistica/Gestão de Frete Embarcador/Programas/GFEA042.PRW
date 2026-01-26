#INCLUDE "GFEA042.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA042      

Cadastro da Classificação do Frete

@author Jorge Matos Valcanaia
@since 27/10/09
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFEA042()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("GUB")									// Alias da tabela utilizada
oBrowse:SetMenuDef("GFEA042")				    		// Nome do fonte onde esta a função MenuDef
oBrowse:SetDescription("Cadastro de Classificações de Frete")	    // Descrição do browse //"Classificação de Frete"
oBrowse:Activate()                                       

Return(Nil)

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
//-------------------------------------------------------------------
// Adiciona botões do browse
//-------------------------------------------------------------------
ADD OPTION aRotina TITLE STR0002    ACTION "AxPesqui"        OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0003   ACTION "VIEWDEF.GFEA042" OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0004      ACTION "VIEWDEF.GFEA042" OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0005      ACTION "VIEWDEF.GFEA042" OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0006      ACTION "VIEWDEF.GFEA042" OPERATION 5 ACCESS 0 //"Excluir"
ADD OPTION aRotina TITLE STR0007     ACTION "VIEWDEF.GFEA042" OPERATION 8 ACCESS 0   //"Imprimir"


Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel

Local oStructGUB := FWFormStruct(1,"GUB")

// cID     Identificador do modelo 
// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
// bPost   Code-Block de validação do formulário de edição
// bCommit Code-Block de persistência do formulário de edição
// bCancel Code-Block de cancelamento do formulário de edição
oModel := MPFormModel():New("GFEA042", /*bPre*/, /*bPost*/, /*bCommit*/, /*bCancel*/)
// cId          Identificador do modelo
// cOwner       Identificador superior do modelo
// oModelStruct Objeto com  a estrutura de dados
// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
// bPost        Code-Block de validação do formulário de edição
// bLoad        Code-Block de carga dos dados do formulário de edição
oModel:AddFields("GFEA042_GUB", Nil, oStructGUB,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetPrimaryKey({"GUB_FILIAL", "GUB_CDCLFR"})

Return oModel

//-------------------------------------------------------------------

Static Function ViewDef()

Local oModel := FWLoadModel("GFEA042")
Local oView  := Nil

oView := FWFormView():New()
// Objeto do model a se associar a view.
oView:SetModel(oModel)
// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
// oStruct - Objeto do model a se associar a view.
// cLinkID - Representa o ID criado no Model ,Só é necessári o caso estamos mundando o ID no View.
oView:AddField( "GFEA042_GUB" , FWFormStruct(2,"GUB"), /*cLinkID*/ )	//
// cID		  	Id do Box a ser utilizado 
// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. é a qtd de pixel exato)
// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas criações uma dentro da outra.
// lFixPixel	Determina que o valor passado no nPercHeight é na verdade a qtd de pixel a ser usada.
// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, é necessário informar o cIDSheet
// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
oView:CreateHorizontalBox( "MASTER" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
// Associa um View a um box
oView:SetOwnerView( "GFEA042_GUB" , "MASTER" )   

Return oView