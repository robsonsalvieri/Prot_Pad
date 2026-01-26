#INCLUDE "GFEA011.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
 
//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA011
Rotina para cadastro do grupo de emitentes
Uso Geral.
 
@param 	oModel	    Recebi o oMOdel principal

@author Luiz Fernando Soares
@since 21/10/09
@version 1.0

/*/
//-------------------------------------------------------------------
//-------------------------------------------------------------------

Function GFEA011()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("GU1")		// Alias da tabela utilizada
oBrowse:SetMenuDef("GFEA011")	// Nome do fonte onde esta a função MenuDef
oBrowse:SetDescription(STR0001)	// Descrição do browse //"Grupo de Emitentes"
oBrowse:Activate()                                       

Return(Nil)

//-------------------------------------------------------------------
Static Function MenuDef()
	
	Local aRotina := {}
	//-------------------------------------------------------
	// Adiciona botões do browse
	//-------------------------------------------------------
	ADD OPTION aRotina TITLE STR0002 ACTION STR0003 OPERATION 1 ACCESS 0 //"Pesquisar"###"AxPesqui"
	ADD OPTION aRotina TITLE STR0004 ACTION STR0005 OPERATION 2 ACCESS 0 //"Visualizar"###"VIEWDEF.GFEA011"
	ADD OPTION aRotina TITLE STR0006 ACTION STR0005 OPERATION 3 ACCESS 0 //"Incluir"###"VIEWDEF.GFEA011"
	ADD OPTION aRotina TITLE STR0007 ACTION STR0005 OPERATION 4 ACCESS 0 //"Alterar"###"VIEWDEF.GFEA011"
	ADD OPTION aRotina TITLE STR0008 ACTION STR0005 OPERATION 5 ACCESS 0 //"Excluir"###"VIEWDEF.GFEA011"
	ADD OPTION aRotina TITLE STR0010 ACTION STR0005 OPERATION 8 ACCESS 0 //"Imprimir"###"VIEWDEF.GFEA011"

Return aRotina

//-------------------------------------------------------------------

Static Function ModelDef()

	Local oModel
	
	// cID     Identificador do modelo 
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição
	oModel := MPFormModel():New("GFEA011", /*bPre*/, /*bPost*/, /*bCommit*/, /*bCancel*/)
	
	oModel:SetVldActivate({|oModel| GFEA011VLD(oModel)})
	
	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
	// bPost        Code-Block de validação do formulário de edição
	// bLoad        Code-Block de carga dos dados do formulário de edição
	oModel:AddFields("GFEA011_GU1", Nil, FWFormStruct(1,"GU1"),/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetPrimaryKey({"GU1_FILIAL", "GU1_CDGREM"})

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel  := FWLoadModel("GFEA011")
Local oView   := Nil
Local oStruct := FWFormStruct(2, "GU1")

oView := FWFormView():New()
// Objeto do model a se associar a view.
oView:SetModel(oModel)
// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
// oStruct - Objeto do model a se associar a view.
// cLinkID - Representa o ID criado no Model ,Só é necessári o caso estamos mundando o ID no View.
oView:AddField( "GFEA011_GU1" , oStruct, /*cLinkID*/ )	//
// cID		  	Id do Box a ser utilizado 
// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. é a qtd de pixel exato)
// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas criações uma dentro da outra.
// lFixPixel	Determina que o valor passado no nPercHeight é na verdade a qtd de pixel a ser usada.
// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, é necessário informar o cIDSheet
// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
oView:CreateHorizontalBox( "MASTER" , 100, /*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/,/*cIDSheet*/ )
// Associa um View a um box
oView:SetOwnerView( "GFEA011_GU1" , "MASTER" )

Return oView

//--------------Função de validação do Model

Function GFEA011VLD(oModel)
	
	Local nOp := oModel:GetOperation()
	
	If GU1->GU1_ORIGEM == "1" .And. nOp == MODEL_OPERATION_DELETE
		Help( ,, 'HELP',, "O Grupo de Emitente é de origem ERP, portanto, não poderá ser excluído.", 1, 0)
		Return .F.
	EndIf
	
Return .T.

