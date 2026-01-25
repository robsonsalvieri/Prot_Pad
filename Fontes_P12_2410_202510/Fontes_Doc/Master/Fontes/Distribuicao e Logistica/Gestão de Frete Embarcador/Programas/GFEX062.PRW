#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.CH"

Function GFEX062(cTpCot,cCodCot)
	Local oBrw := Nil
	Local cFunBkp := FunName()

	Default cTpCot := "1"
	Default cCodCot := ""

	// Workaround para executar o MenuDef() correto.
	// Assim considera os privilégios específicos setados no SIGACFG.
	SetFunName("GFEX062")

	oBrw := FWMBrowse():New()
	oBrw:SetAlias("GVQ")
	oBrw:SetDescription("Cotação de frete")
	oBrw:SetMenuDef("GFEX062")
	oBrw:AddLegend("GVQ_ENVCOP == '1'","GREEN" ,"Enviada") // "Enviada"
	oBrw:AddLegend("GVQ_ENVCOP == '2'","ORANGE","Não Enviada") // "Não Enviada"
	oBrw:SetFilterDefault("@ GVQ_TPCOT = '"+cTpCot+"' AND GVQ_CODCOT = '"+cCodCot+"'")
	oBrw:Activate()

	SetFunName(cFunBkp)

Return Nil

Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE "Pesquisar"  ACTION 'AxPesqui'        OPERATION 1 ACCESS 0 DISABLE MENU // Pesquisar
	ADD OPTION aRotina TITLE "Visualizar" ACTION 'VIEWDEF.GFEX062' OPERATION 2 ACCESS 0 DISABLE MENU // Visualizar
	
Return aRotina

Static Function ModelDef()
	Local oModel := Nil
	Local oStrGVQ := FWFormStruct(1,'GVQ')
	
	// cID     Identificador do modelo 
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição
	oModel := MPFormModel():New('GFEX062', /*bPre*/, /*bPost*/, /*bCommit*/, /*bCancel*/)
	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
	// bPost        Code-Block de validação do formulário de edição
	// bLoad        Code-Block de carga dos dados do formulário de edição
	oModel:AddFields('GFEX062_GVQ', Nil, oStrGVQ,/*bPre*/,/*bPost*/,/*bLoad*/)

Return oModel

Static Function ViewDef()
	Local oModel := FWLoadModel('GFEX062')
	Local oStrGVQ := FWFormStruct(2,'GVQ')
	Local oView := Nil
		
	oView := FWFormView():New()
	// Objeto do model a se associar a view.
	oView:SetModel(oModel)
	
	// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
	// oStruct - Objeto do model a se associar a view.
	// cLinkID - Representa o ID criado no Model ,Só é necessário caso estamos mundando o ID no View.
	oView:AddField('GFEX062_GVQ' ,oStrGVQ, /*cLinkID*/)
	
Return oView
