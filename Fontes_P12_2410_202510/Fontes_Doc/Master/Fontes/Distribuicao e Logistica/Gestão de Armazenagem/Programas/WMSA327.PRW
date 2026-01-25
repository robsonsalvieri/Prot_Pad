#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "WMSA327.CH"

#DEFINE WMSA32701 "WMSA32701"

//----------------------------------------------------------
/*/{Protheus.doc} WMSA327
Cliente x Endereço Blocado
@author felipe.m
@since 08/09/2014
@version 1.0
@return ${Nil}, ${Nulo}
/*/
//----------------------------------------------------------
Function WMSA327()
Local oBrowse

	// Permite efetuar validações, apresentar mensagem e abortar o programa quando desejado
	If !WMSChkPrg(FunName(),"1")
		Return Nil
	EndIf

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('D10')
	oBrowse:SetDescription(STR0001) // Cliente x Endereço Blocado
	oBrowse:Activate()
Return Nil

//----------------------------------------------------------
// MenuDef
//----------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}   
	//----------------------------------------------------------
	// Adiciona botões do browse
	//----------------------------------------------------------
	ADD OPTION aRotina TITLE STR0002 ACTION 'AxPesqui'        OPERATION 1 ACCESS 0 DISABLE MENU // Pesquisar
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.WMSA327' OPERATION 2 ACCESS 0 DISABLE MENU // Visualizar
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.WMSA327' OPERATION 3 ACCESS 0 DISABLE MENU // Incluir
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.WMSA327' OPERATION 4 ACCESS 0 DISABLE MENU // Alterar	
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.WMSA327' OPERATION 5 ACCESS 0 DISABLE MENU // Excluir
	ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.WMSA327' OPERATION 8 ACCESS 0 DISABLE MENU // Imprimir
	ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.WMSA327' OPERATION 9 ACCESS 0 DISABLE MENU // Copiar
Return aRotina
//----------------------------------------------------------
// ModelDef
//----------------------------------------------------------
Static Function ModelDef()
Local oModel  	 := Nil
Local oStructD10 := FWFormStruct(1,'D10')
	// cID     Identificador do modelo 
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição
	oModel := MPFormModel():New('WMSA327', /*bPre*/, /*bPost*/, /*bCommit*/, /*bCancel*/)
	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
	// bPost        Code-Block de validação do formulário de edição
	// bLoad        Code-Block de carga dos dados do formulário de edição
	oModel:AddFields('D10FIELDS', Nil, oStructD10,/*bPre*/,/*bPost*/,/*bLoad*/)
Return oModel
//----------------------------------------------------------
// ViewDef
//----------------------------------------------------------
Static Function ViewDef()
Local oModel := FWLoadModel('WMSA327')
Local oStructD06 := FWFormStruct(2,'D10')
Local oView
	oView := FWFormView():New()
	// Objeto do model a se associar a view.
	oView:SetModel(oModel)
	// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
	// oStruct - Objeto do model a se associar a view.
	// cLinkID - Representa o ID criado no Model ,Só é necessário caso estamos mundando o ID no View.

	oView:AddField('D10FIELDS' ,oStructD06)
Return oView
//---------------------------------------------------------------------
/*/{Protheus.doc} WMSA327VTE
Validação do tipo de estrutura do endereço informado.
Deve ser tipo 3=Cross Docking;4=Blocado;5=Box/Doca;6=Blocado Fracionado
@author felipe.m
@since 14/10/2014
@version 1.0
@return ${lRet}, ${Verdadeiro ou Falso}
/*/
//---------------------------------------------------------------------
Function WMSA327VTE()
Local lRet := .T.
	SBE->( dbSetOrder(1) ) // BE_FILIAL+BE_LOCAL+BE_LOCALIZ
	If SBE->( dbSeek(xFilial("SBE")+M->D10_LOCAL+M->D10_ENDER) )
		DC8->( dbSetOrder(1) ) // DC8_FILIAL+DC8_TPESTR
		If DC8->( dbSeek(xFilial("DC8")+SBE->BE_ESTFIS ) )
			If DC8->DC8_TPESTR $ "1|2"
				WmsMessage(STR0010,WMSA32701,5/*MSG_HELP*/) // Endereço não possui tipo de estrutura válido. (3=Cross Docking;4=Blocado;5=Box/Doca;6=Blocado Fracionado)
				lRet := .F.
			EndIf
		EndIf
	EndIf
Return lRet