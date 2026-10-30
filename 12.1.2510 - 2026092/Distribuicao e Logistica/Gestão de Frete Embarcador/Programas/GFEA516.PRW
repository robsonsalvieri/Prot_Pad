#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GFEA516.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA516

Cadastro de Perguntas

@author Jorge Matos Valcanaia
@since 07/09/2010
@version 1.0
/*/
//-------------------------------------------------------------------
//-------------------------------------------------------------------
Function GFEA516()
	Local oBrowse
	
	If !GFECheckGX4()
		Return .F.
	EndIF

	If !GFEA510COMP()
		MsgStop( "Necessário aplicar o update U_GFE11I20 para utilizar o processo de pátios e portarias." )
		Return .F.
	EndIf
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GVG")				// Alias da tabela utilizada
	oBrowse:SetMenuDef("GFEA516")		// Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription(STR0001) //"Perguntas"
	oBrowse:Activate()
Return(Nil)

//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	//-------------------------------------------------------
	// Adiciona botões do browse
	//-------------------------------------------------------
	ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"        OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.GFEA516" OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.GFEA516" OPERATION 3 ACCESS 0 //"Incluir"
	ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.GFEA516" OPERATION 4 ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.GFEA516" OPERATION 5 ACCESS 0 //"Excluir"
	ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.GFEA516" OPERATION 8 ACCESS 0 //"Imprimir"
	
Return aRotina

//-------------------------------------------------------------------

Static Function ModelDef()
	Local oModel

	// cID     Identificador do modelo 
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição
	oModel := MPFormModel():New("GFEA516", /*bPre*/, {|oModel|GFEA516POS(oModel)} /*bPost*/, /*bCommit*/, /*bCancel*/)
	
	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
	// bPost        Code-Block de validação do formulário de edição
	// bLoad        Code-Block de carga dos dados do formulário de edição
	oModel:AddFields("GFEA516_GVG", Nil, FWFormStruct(1,"GVG"),/*bPre*/,,/*bLoad*/)
	oModel:SetPrimaryKey({"GVG_FILIAL", "GVG_CDPERG"})
	
Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel := FWLoadModel("GFEA516")
	Local oView  := Nil
	Local oStruct := FWFormStruct(2,"GVG")


	oView := FWFormView():New()
	// Objeto do model a se associar a view.
	oView:SetModel(oModel)
	// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
	// oStruct - Objeto do model a se associar a view.
	// cLinkID - Representa o ID criado no Model ,Só é necessári o caso estamos mundando o ID no View.
	oView:AddField( "GFEA516_GVG" , oStruct, /*cLinkID*/ )	//
	// cID		  	Id do Box a ser utilizado 
	// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. é a qtd de pixel exato)
	// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas criações uma dentro da outra.
	// lFixPixel	Determina que o valor passado no nPercHeight é na verdade a qtd de pixel a ser usada.
	// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, é necessário informar o cIDSheet
	// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
	oView:CreateHorizontalBox( "MASTER" , 100, /*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/,/*cIDSheet*/ )
	// Associa um View a um box
	oView:SetOwnerView( "GFEA516_GVG" , "MASTER" )   
		
Return oView
//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA516POS
Rotina para realizar as validacoes.
Uso Geral.

@param 	oModel	    Recebi o oMOdel principal

@author Helder Fuckner dos Santos
@since 20/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA516POS(oModel)
	Local nOpc	:= (oModel:GetOperation())
	
	If nOpc == MODEL_OPERATION_INSERT
		If !ExistChav("GVG", oModel:GetValue("GFEA516_GVG", "GVG_CDPERG"))
			Help( ,, 'HELP',, "Já existe pergunta com o código informado. Troque o código desse registro.", 1, 0)
			Return .F.
		EndIf
	EndIf
	
Return .T.
  