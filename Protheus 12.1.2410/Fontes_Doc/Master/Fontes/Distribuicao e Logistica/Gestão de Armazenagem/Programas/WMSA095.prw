#Include "PROTHEUS.CH"  
#Include "FWMVCDEF.CH"
#Include "WMSA095.CH"

//-----------------------------------------------------------------------------
/*/{Protheus.doc} WMSA090
Alteracao de Prioridade dos endereços WMS
@author Alexsander Corrêa
@since 25/11/2015
@version 1.0
/*/
//-----------------------------------------------------------------------------
Function WMSA095()
Local oBrw := FWMBrowse():New()

	// Permite efetuar validações, apresentar mensagem e abortar o programa quando desejado
	If !WMSChkPrg(FunName(),"1")
		Return Nil
	EndIf
	
	oBrw:SetAlias("D14")
	oBrw:SetDescription(STR0004) // Prioridade endereço
	oBrw:SetMenuDef("WMSA095")
	oBrw:Activate()
Return
//-----------------------------------------------------------------------------
// MenuDef
//-----------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
	
	ADD OPTION aRotina TITLE STR0001 ACTION 'AxPesqui'        OPERATION 1 ACCESS 0 DISABLE MENU // Pesquisar
	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.WMSA095' OPERATION 2 ACCESS 0 DISABLE MENU // Visualizar
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.WMSA095' OPERATION 4 ACCESS 0 DISABLE MENU // Alterar
Return aRotina
//-----------------------------------------------------------------------------
// ModelDef
//-----------------------------------------------------------------------------
Static Function ModelDef()
Local oModel := Nil
Local oStrD14 := FWFormStruct(1,"D14")
	
	oStrD14:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)
	
	// cID     Identificador do modelo 
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição
	oModel := MPFormModel():New('WMSA095',/*bPre*/,/*bPost*/,/*bCommit*/,/*bCancel*/)
	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
	// bPost        Code-Block de validação do formulário de edição
	// bLoad        Code-Block de carga dos dados do formulário de edição
	oModel:AddFields('095D14',Nil,oStrD14,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetPrimaryKey({'D14_FILIAL','D14_LOCAL','D14_ENDER','D14_PRDORI','D14_PRODUT','D14_LOTECT','D14_NUMLOT','D14_NUMSER'})
	
Return oModel
//-----------------------------------------------------------------------------
// ViewDef
//-----------------------------------------------------------------------------
Static Function ViewDef()
Local oView := Nil
Local oModel := FWLoadModel('WMSA095')
Local oStrD14 := FWFormStruct(2,'D14')
	
	oStrD14:SetProperty("*",MVC_VIEW_CANCHANGE,.F.)
	oStrD14:SetProperty("D14_PRIOR",MVC_VIEW_CANCHANGE,.T.)
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
	// oStruct - Objeto do model a se associar a view.
	// cLinkID - Representa o ID criado no Model ,Só é necessário caso estamos mundando o ID no View.
	oView:AddField('095D14',oStrD14)
	oView:CreateHorizontalBox('MASTER',100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	oView:SetOwnerView('095D14','MASTER')
Return oView
