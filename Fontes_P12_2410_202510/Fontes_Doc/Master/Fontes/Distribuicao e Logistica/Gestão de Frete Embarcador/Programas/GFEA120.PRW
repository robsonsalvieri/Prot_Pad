//#INCLUDE "GFEA120.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
 
//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA120
Rotina para cadastro de Tipos de Serviço de Frete
Uso Geral.

@param 	oModel	    Recebi o oMOdel principal

@author Marcos Wagner Junior
@since 30/09/16
@version 1.0
/*/
//-------------------------------------------------------------------
//-------------------------------------------------------------------
Function GFEA120()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("GVU")		// Alias da tabela utilizada
oBrowse:SetMenuDef("GFEA120")	// Nome do fonte onde esta a função MenuDef
oBrowse:SetDescription("Tipos Serviço de Frete")	// Descrição do browse //"Tipos Serviço de Frete"
oBrowse:Activate()                                       

Return(Nil)

//-------------------------------------------------------------------
Static Function MenuDef()
	
	Local aRotina := {}
	//-------------------------------------------------------
	// Adiciona botões do browse
	//-------------------------------------------------------
	ADD OPTION aRotina TITLE "Pesquisar" ACTION "#AxPesqui" OPERATION 1 ACCESS 0 //"Pesquisar"###"AxPesqui"
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.GFEA120" OPERATION 2 ACCESS 0 //"Visualizar"###"VIEWDEF.GFEA120"
	ADD OPTION aRotina TITLE "Incluir" ACTION "VIEWDEF.GFEA120" OPERATION 3 ACCESS 0 //"Incluir"###"VIEWDEF.GFEA120"
	ADD OPTION aRotina TITLE "Alterar" ACTION "VIEWDEF.GFEA120" OPERATION 4 ACCESS 0 //"Alterar"###"VIEWDEF.GFEA120"
	ADD OPTION aRotina TITLE "Excluir" ACTION "VIEWDEF.GFEA120" OPERATION 5 ACCESS 0 //"Excluir"###"VIEWDEF.GFEA120"
	ADD OPTION aRotina TITLE "Imprimir" ACTION "VIEWDEF.GFEA120" OPERATION 8 ACCESS 0 //"Imprimir"###"VIEWDEF.GFEA120"*/

Return aRotina

//-------------------------------------------------------------------

Static Function ModelDef()

	Local oModel
	
	// cID     Identificador do modelo 
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição
	oModel := MPFormModel():New("GFEA120", /*PreValidacao*/,/**/, /**/, /**/, /*bCancel*/)
	oModel:SetVldActivate ( { |oMod| GFEA120VLD( oMod ) } )
	
	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
	// bPost        Code-Block de validação do formulário de edição
	// bLoad        Code-Block de carga dos dados do formulário de edição
	oModel:AddFields("GFEA120_GVU", Nil, FWFormStruct(1,"GVU"),/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetPrimaryKey({"GVU_FILIAL", "GVU_CDTPSE"})

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel  := FWLoadModel("GFEA120")
Local oView   := Nil
Local oStruct := FWFormStruct(2, "GVU")

oView := FWFormView():New()
// Objeto do model a se associar a view.
oView:SetModel(oModel)
// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
// oStruct - Objeto do model a se associar a view.
// cLinkID - Representa o ID criado no Model ,Só é necessári o caso estamos mundando o ID no View.
oView:AddField( "GFEA120_GVU" , oStruct, /*cLinkID*/ )	//
// cID		  	Id do Box a ser utilizado 
// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. é a qtd de pixel exato)
// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas criações uma dentro da outra.
// lFixPixel	Determina que o valor passado no nPercHeight é na verdade a qtd de pixel a ser usada.
// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, é necessário informar o cIDSheet
// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
oView:CreateHorizontalBox( "MASTER" , 100, /*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/,/*cIDSheet*/ )
// Associa um View a um box
oView:SetOwnerView( "GFEA120_GVU" , "MASTER" )

Return oView

//--------------Função de validação do Model

Function GFEA120VLD(oModel)
Local lRet := .T.
Local aOldArea := GetArea()
Local nOp := oModel:GetOperation()
	
	If nOp == MODEL_OPERATION_DELETE
	   dbSelectArea("GV2")
	   dbSetOrder(3)
	   If dbSeek(xFilial("GVU")+ AllTrim(GVU->GVU_CDTPSE))
	      Help( ,, 'HELP',, "Não é possível excluir o tipo de serviço pois está sendo utilizado no componente "+GV2->GV2_CDCOMP+".", 1, 0)
	      lRet := .F.
	   EndIF   
	EndIf
	
	RestArea(aOldArea)

Return lRet
