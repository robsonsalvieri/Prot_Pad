#INCLUDE "GFEC061B.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEC061B
Consulta do Componente da tabela de frete
Generico

@sample
GFEC061B()

@author Jorge Matos Valcanaia
@since 04/11/09
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFEC061B( lFiltGV9 )
Local oBrowse

Default lFiltGV9 := .F.

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("GUY")						 // Alias da tabela utilizada
oBrowse:SetMenuDef("GFEC061B")				 // Nome do fonte onde esta a função MenuDef
oBrowse:SetDescription(STR0001)	 // Descrição do browse //"Componente da tabela de frete"

If lFiltGV9    
	oBrowse:SetFilterDefault( "GUY_FILIAL+GUY_CDEMIT+GUY_NRTAB+GUY_NRNEG == '"  + GV9->(GV9_FILIAL+GV9_CDEMIT+GV9_NRTAB+GV9_NRNEG)+ "'")
Endif

oBrowse:Activate()

Return(Nil)

//---------------------------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
// Adiciona botões do browse
ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"        OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.GFEC061B" OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0008 ACTION "VIEWDEF.GFEC061B" OPERATION 8 ACCESS 0 //"Imprimir"

Return aRotina

//---------------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel

// cID     Identificador do modelo 
// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
// bPost   Code-Block de validação do formulário de edição
// bCommit Code-Block de persistência do formulário de edição
// bCancel Code-Block de cancelamento do formulário de edição
oModel := MPFormModel():New("GFEC061B", /*bPre*/,/*bCommit*/, /*bCancel*/)
// cId          Identificador do modelo
// cOwner       Identificador superior do modelo
// oModelStruct Objeto com  a estrutura de dados
// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
// bPost        Code-Block de validação do formulário de edição
// bLoad        Code-Block de carga dos dados do formulário de edição
oModel:AddFields("GFEC061B_GUY", Nil, FWFormStruct(1,"GUY"),/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetPrimaryKey({"GUY_FILIAL", "GUY_CDEMIT", "GUY_NRTAB", "GUY_NRNEG", "GUY_CDCOMP"}) 

Return oModel

//---------------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oModel := FWLoadModel("GFEC061B")
Local oView  := Nil

oView := FWFormView():New()
// Objeto do model a se associar a view.
oView:SetModel(oModel)
// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
// oStruct - Objeto do model a se associar a view.
// cLinkID - Representa o ID criado no Model ,Só é necessári o caso estamos mundando o ID no View.
oView:AddField( "GFEC061B_GUY" , FWFormStruct(2,"GUY"), /*cLinkID*/ )	//
// cID		  	Id do Box a ser utilizado 
// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. é a qtd de pixel exato)
// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas criações uma dentro da outra.
// lFixPixel	Determina que o valor passado no nPercHeight é na verdade a qtd de pixel a ser usada.
// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, é necessário informar o cIDSheet
// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
oView:CreateHorizontalBox( "MASTER" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
// Associa um View a um box
oView:SetOwnerView( "GFEC061B_GUY" , "MASTER" )

Return oView