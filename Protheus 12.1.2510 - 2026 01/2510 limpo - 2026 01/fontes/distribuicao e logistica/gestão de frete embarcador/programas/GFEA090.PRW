#INCLUDE "GFEA090.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

 
//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA090

Cadastro de Contas Contábeis

@author Jorge Matos Valcanaia
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFEA090()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("GUE")										// Alias da tabela utilizada
oBrowse:SetMenuDef("GFEA090")				  			    // Nome do fonte onde esta a função MenuDef
oBrowse:SetDescription(STR0001)	    // Descrição do browse //"Cadastro de Contas Contábeis"
oBrowse:Activate()                                       

Return(Nil)

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
//-------------------------------------------------------------------
// Adiciona botões do browse
//-------------------------------------------------------------------
ADD OPTION aRotina TITLE STR0002    ACTION "AxPesqui"         OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0003   ACTION "VIEWDEF.GFEA090" OPERATION 2 ACCESS 0 //"Visualizar"

// Integração - Retira botão incluir quando for integrago com o ERP
If SuperGetMV("MV_CADERP",,"1") $ "2N"
	ADD OPTION aRotina TITLE STR0004      ACTION "VIEWDEF.GFEA090" OPERATION 3 ACCESS 0 //"Incluir"
EndIf

ADD OPTION aRotina TITLE STR0005      ACTION "VIEWDEF.GFEA090" OPERATION 4 ACCESS 0 //"Alterar"

// Integração - Retira botão excluir quando for integrago com o ERP
If SuperGetMV("MV_CADERP",,"1") $ "2N"
	ADD OPTION aRotina TITLE STR0006      ACTION "VIEWDEF.GFEA090" OPERATION 5 ACCESS 0 //"Excluir"
EndIf
// Fim - Integração

ADD OPTION aRotina TITLE STR0007     ACTION "VIEWDEF.GFEA090" OPERATION 8 ACCESS 0   //"Imprimir"

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel
	Local oStructGUE := FWFormStruct(1,"GUE")

	
// cID     Identificador do modelo 
// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
// bPost   Code-Block de validação do formulário de edição
// bCommit Code-Block de persistência do formulário de edição
// bCancel Code-Block de cancelamento do formulário de edição
oModel := MPFormModel():New("GFEA090", /*bPre*/, {|oMod| GFEA90POS(oMod)},, /*bCancel*/)
// cId          Identificador do modelo
// cOwner       Identificador superior do modelo
// oModelStruct Objeto com  a estrutura de dados
// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
// bPost        Code-Block de validação do formulário de edição
// bLoad        Code-Block de carga dos dados do formulário de edição

oModel:AddFields("GFEA090_GUE", Nil, oStructGUE,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetPrimaryKey({"GUE_FILIAL", "GUE_CTACTB"})

Return oModel

Static Function ViewDef()
Local oModel  := FWLoadModel("GFEA090")
Local oView   := Nil
Local oStruct := FWFormStruct(2,"GUE")

	
// Integração - Desabilita campos
If SuperGetMV("MV_CADERP",,"1") $ "1S"
	oStruct:SetProperty("GUE_CTACTB", MVC_VIEW_CANCHANGE ,.F.)
EndIf
// FIM - Integração	

oView := FWFormView():New()
// Objeto do model a se associar a view.
oView:SetModel(oModel)
// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
// oStruct - Objeto do model a se associar a view.
// cLinkID - Representa o ID criado no Model ,Só é necessári o caso estamos mundando o ID no View.
oView:AddField( "GFEA090_GUE" , oStruct, /*cLinkID*/ )	//
// cID		  	Id do Box a ser utilizado 
// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. é a qtd de pixel exato)
// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas criações uma dentro da outra.
// lFixPixel	Determina que o valor passado no nPercHeight é na verdade a qtd de pixel a ser usada.
// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, é necessário informar o cIDSheet
// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
oView:CreateHorizontalBox( "MASTER" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
// Associa um View a um box
oView:SetOwnerView( "GFEA090_GUE" , "MASTER" )   

Return oView

//------------------------------------------------------

Static Function GFEA90IMPD(oModel)
	Local aGUSFields := FWFormStruct(1, "GUS"):GetFields()
	Local aGUFFields := FWFormStruct(1, "GUF"):GetFields()
	Local cContaC    := oModel:GetModel("GFEA090_GUE"):GetValue("GUE_CTACTB")
	Local nI
	Local cFiltro    := ""
	Local lImped     := .F.
	
	For nI := 1 To Len(aGUSFields)
			
		If GFEUSADO(aGUSFields[nI][3]) .And. "GUS_CT" $ aGUSFields[nI][3]
			
			If !Empty(cFiltro)
				cFiltro += " .Or. "
			EndIf
			
			cFiltro += "GUS->" + aGUSFields[nI][3] + " == '" + cContaC + "'"
			
		EndIf
		
	Next nI
	
	dbSelectArea("GUS")
	GUS->( dbSetOrder(1) )
	GUS->( dbSetFilter({|| &(cFiltro)}, "") )
	GUS->( dbGoTop() )
	If !GUS->( Eof() )
		lImped := .T.
	EndIf
	
	GUS->( dbClearFilter() )
	
	If !lImped
		
		cFiltro := ""
		
		For nI := 1 To Len(aGUFFields)
			
			If GFEUSADO(aGUFFields[nI][3]) .And. "GUF_CT" $ aGUFFields[nI][3]
				
				If !Empty(cFiltro)
					cFiltro += " .Or. "
				EndIf
				
				cFiltro += "GUF->" + aGUFFields[nI][3] + " == '" + cContaC + "'"
				
			EndIf
			
		Next nI
		
		dbSelectArea("GUF")
		GUF->( dbSetOrder(1) )
		GUF->( dbSetFilter({|| &(cFiltro)}, "") )
		GUF->( dbGoTop() )
		If !GUF->( Eof() )
			lImped := .T.
		EndIf
		
		GUF->( dbClearFilter() )
		
	EndIf
	
Return lImped

//--------------------------------------

Function GFEA90POS(oModel)

	If GFEWSFUNLG() .And. FunName() != "GFEA090"
	   Help( ,, 'HELP', '', 'Não é possível receber cadastro do Protheus quando ERP for Datasul.', 1, 0)
	   Return .F.
	EndIf
	
	If oModel:GetOperation() == MODEL_OPERATION_DELETE
				
		If !IsBlind() .And. GFEA90IMPD(oModel)
		
			Help( ,, 'HELP',, "A Conta Contábil está informada em outros cadastros, portanto não poderá ser excluída. " + ;
							  "Retire os relacionamentos ou altere a Conta Contábil para Inativa.", 1, 0,) //"A Conta Contábil está informada em outros cadastros, portanto não poderá ser excluída. Retire os relacionamentos ou altere a Conta Contábil para Inativa."
			Return .F.
			
		EndIf
		
	EndIf
	
Return .T.

/*
=========================================================================================================
// {Protheus.doc} IntegDef
// TODO Chamada da Rotina de Integração de Mensagem Unica 
@author Adm de Frete Embarcador
@since 13/11/2017
@version 1.000
@param cXml     : Xml definido de acordo com o XSD da mensagem de envio/recebimento.
@param nType    : numeric / Informa o tipo de Mensagem tratada: 0=Response;1=Envio;
@param cTypeMsg : Informa qual o tipo de mensagem que será processada se é uma: Business Message, Receipt Message, WhoIs Message 
@type function
=========================================================================================================
*/
Static Function IntegDef(cXml,nType,cTypeMsg)
// Função tem que ser statica segundo documentação
Local  aResult := {}
       aResult := GFEI090(cXml,nType,cTypeMsg)
Return aResult

