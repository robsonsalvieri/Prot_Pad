#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "GFEA063.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA063
Rotina para cadastro de Aprovadores da Tabela de Frete
Uso Geral.

@author Jorge Matos Valcanaia
@since 31/03/10
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFEA063()
Local oBrowse

// Quando integração com Datasul + controle de aprovação por MLA
If SuperGetMv("MV_ERPGFE",.F.,"2") == "1" .And. SuperGetMv("MV_TFMLA",.F.,"2") == "1"
	Help(,,"HELP",,"Esta rotina está bloqueada, pois o sistema está parametrizado para cotrole de aprovação de Tabelas de Frete por MLA (MV_TFMLA).",1,0) //"Esta rotina está bloqueada, pois o sistema está parametrizado para cotrole de aprovação de Tabelas de Frete por MLA (MV_TFMLA)."
	Return .F.
EndIf

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("GUX")			// Alias da tabela utilizada
oBrowse:SetMenuDef("GFEA063")	// Nome do fonte onde esta a função MenuDef
oBrowse:SetDescription("Cadastro de Aprovadores de Tabela de Frete")	// "Aprovadores Tabela de Frete"
oBrowse:Activate()                                       

Return(Nil)

//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}


	//-------------------------------------------------------
	// Adiciona botões do browse
	//-------------------------------------------------------
	ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"        OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.GFEA063" OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.GFEA063" OPERATION 3 ACCESS 0 //"Incluir"
	ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.GFEA063" OPERATION 4 ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.GFEA063" OPERATION 5 ACCESS 0 //"Excluir"
	
Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel

// cID     Identificador do modelo 
// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
// bPost   Code-Block de validação do formulário de edição
// bCommit Code-Block de persistência do formulário de edição
// bCancel Code-Block de cancelamento do formulário de edição
oModel := MPFormModel():New("GFEA063", /*bPre*/, /*bPost*/, /*bCommit*/, /*bCancel*/)
// cId          Identificador do modelo
// cOwner       Identificador superior do modelo
// oModelStruct Objeto com  a estrutura de dados
// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
// bPost        Code-Block de validação do formulário de edição
// bLoad        Code-Block de carga dos dados do formulário de edição
oModel:AddFields("GFEA063_GUX", Nil, FWFormStruct(1,"GUX"),/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetPrimaryKey({"GUX_FILIAL", "GUX_USUAPR"})
oModel:SetDescription("Aprovadores de Tabela de Frete")

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel := FWLoadModel("GFEA063")
	Local oView  := Nil

	
	oView := FWFormView():New()
	// Objeto do model a se associar a view.
	oView:SetModel(oModel)
	// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
	// oStruct - Objeto do model a se associar a view.
	// cLinkID - Representa o ID criado no Model ,Só é necessári o caso estamos mundando o ID no View.
	oView:AddField( "GFEA063_GUX" , FWFormStruct(2,"GUX"), /*cLinkID*/ )	//
	// cID		  	Id do Box a ser utilizado 
	// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. é a qtd de pixel exato)
	// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas criações uma dentro da outra.
	// lFixPixel	Determina que o valor passado no nPercHeight é na verdade a qtd de pixel a ser usada.
	// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, é necessário informar o cIDSheet
	// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
	oView:CreateHorizontalBox( "MASTER" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	// Associa um View a um box
	oView:SetOwnerView( "GFEA063_GUX" , "MASTER" )

Return oView
