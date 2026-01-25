#INCLUDE "GFEA043.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA043

Cadastro de Unitilizadores de Itens

@author Jorge Matos Valcanaia
@since 27/10/09
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFEA043()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("GUG")		 // Alias da tabela utilizada
oBrowse:SetMenuDef("GFEA043")	 // Nome do fonte onde esta a função MenuDef
oBrowse:SetDescription("Cadastro de Unitizadores de Carga")	 // Descrição do browse //"Unitizadores de Itens"
oBrowse:Activate()                                       

Return(Nil)

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
//-------------------------------------------------------------------
// Adiciona botões do browse
//-------------------------------------------------------------------
ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"        OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.GFEA043" OPERATION 2 ACCESS 0 //"Visualizar"

// Integração - Habilita botão Incluir quando a integração for SIGAGFE ou a integração for ERP e o ERP for Protheus
If SuperGetMV("MV_CADERP",,"1") == "2" .Or. (SuperGetMV("MV_CADERP",,"1") == "1" .And. (SuperGetMV("MV_ERPGFE",,"2") == "2" .or. (SuperGetMV("MV_ERPGFE",,"2") == "4")))
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.GFEA043" OPERATION 3 ACCESS 0 //"Incluir"
EndIf

ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.GFEA043" OPERATION 4 ACCESS 0 //"Alterar"

// Integração - Habilita botão Incluir quando a integração for SIGAGFE ou a integração for ERP e o ERP for Protheus
If SuperGetMV("MV_CADERP",,"1") == "2" .Or. (SuperGetMV("MV_CADERP",,"1") == "1" .And. (SuperGetMV("MV_ERPGFE",,"2") == "2" .or. (SuperGetMV("MV_ERPGFE",,"2") == "4")))
	ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.GFEA043" OPERATION 5 ACCESS 0 //"Excluir"
EndIf

ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.GFEA043" OPERATION 8 ACCESS 0 //"Imprimir"

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel

Local oStructGUG := FWFormStruct(1,"GUG")                                

// cID     Identificador do modelo 
// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
// bPost   Code-Block de validação do formulário de edição
// bCommit Code-Block de persistência do formulário de edição
// bCancel Code-Block de cancelamento do formulário de edição
oModel := MPFormModel():New("GFEA043", /*bPre*/, /*{ |oX| ValidCpo( oX ) }*/,/*bPost*/, /*bCommit*/, /*bCancel*/)
// cId          Identificador do modelo
// cOwner       Identificador superior do modelo
// oModelStruct Objeto com  a estrutura de dados
// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
// bPost        Code-Block de validação do formulário de edição
// bLoad        Code-Block de carga dos dados do formulário de edição
oModel:AddFields("GFEA043_GUG", Nil, oStructGUG,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetPrimaryKey({"GUG_FILIAL", "GUG_CDUNIT"})


Return oModel

//-------------------------------------------------------------------

Static Function ViewDef()

Local oModel  := FWLoadModel("GFEA043")
Local oView   := Nil
Local oStruct := FWFormStruct(2,"GUG")

// Integração - Desabilita campos
If SuperGetMV("MV_CADERP",,"1") == "1" .And. SuperGetMV("MV_ERPGFE",,"2") != "2"
	oStruct:SetProperty("GUG_CDUNIT", MVC_VIEW_CANCHANGE ,.F.)
	oStruct:SetProperty("GUG_DSUNIT", MVC_VIEW_CANCHANGE ,.F.)
EndIf
// FIM - Integração


oView := FWFormView():New()
// Objeto do model a se associar a view.
oView:SetModel(oModel)
// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
// oStruct - Objeto do model a se associar a view.
// cLinkID - Representa o ID criado no Model ,Só é necessári o caso estamos mundando o ID no View.
oView:AddField( "GFEA043_GUG" , oStruct, /*cLinkID*/ )	//
// cID		  	Id do Box a ser utilizado 
// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. é a qtd de pixel exato)
// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas criações uma dentro da outra.
// lFixPixel	Determina que o valor passado no nPercHeight é na verdade a qtd de pixel a ser usada.
// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, é necessário informar o cIDSheet
// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
oView:CreateHorizontalBox( "MASTER" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
// Associa um View a um box
oView:SetOwnerView( "GFEA043_GUG" , "MASTER" )   

Return oView