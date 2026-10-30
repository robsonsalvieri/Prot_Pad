#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GFEA511.CH"

//-------------------------------------------------------------------
//Inclusão Pátios 12.1.4
/*/{Protheus.doc} GFEA511
Rotina para cadastro de visitantes
Uso Geral.

@param 	oModel	    Recebe o oModel principal

@author Israel Alcantara Possoli
@since 06/09/2010
@version 1.0
/*/
//-------------------------------------------------------------------
//-------------------------------------------------------------------



Function GFEA511()
	Local oBrowse

	If !GFECheckGX4()
		Return .F.
	EndIF

	If !GFEA510COMP()
		MsgStop( "Necessário aplicar o update U_GFE11I20 para utilizar o processo de pátios e portarias." )
		Return .F.
	EndIf

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GVE")				// Alias da tabela utilizada
	oBrowse:SetMenuDef("GFEA511")		// Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription(STR0001) //"Visitantes"
	oBrowse:Activate()
Return(Nil)

//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	//-------------------------------------------------------
	// Adiciona botões do browse
	//-------------------------------------------------------
	ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"        OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.GFEA511" OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.GFEA511" OPERATION 3 ACCESS 0 //"Incluir"
	ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.GFEA511" OPERATION 4 ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.GFEA511" OPERATION 5 ACCESS 0 //"Excluir"
	ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.GFEA511" OPERATION 9 ACCESS 0 //"Copiar"
	ADD OPTION aRotina TITLE STR0008 ACTION "VIEWDEF.GFEA511" OPERATION 8 ACCESS 0 //"Imprimir"
	
Return aRotina

//-------------------------------------------------------------------

Static Function ModelDef()
	Local oModel

	// cID     Identificador do modelo 
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição
	oModel := MPFormModel():New("GFEA511", /*bPre*/, {|oX|GFEA511POS(oX)} /*bPost*/, /*bCommit*/, /*bCancel*/)
	
	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
	// bPost        Code-Block de validação do formulário de edição
	// bLoad        Code-Block de carga dos dados do formulário de edição
	oModel:AddFields("GFEA511_GVE", Nil, FWFormStruct(1,"GVE"),/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetPrimaryKey({"GVE_FILIAL", "GVE_CDVISI"})
	
Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel := FWLoadModel("GFEA511")
	Local oView  := Nil
	Local oStruct := FWFormStruct(2,"GVE")


	oView := FWFormView():New()
	// Objeto do model a se associar a view.
	oView:SetModel(oModel)
	// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
	// oStruct - Objeto do model a se associar a view.
	// cLinkID - Representa o ID criado no Model ,Só é necessári o caso estamos mundando o ID no View.
	oView:AddField( "GFEA511_GVE" , oStruct, /*cLinkID*/ )	//
	// cID		  	Id do Box a ser utilizado 
	// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. é a qtd de pixel exato)
	// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas criações uma dentro da outra.
	// lFixPixel	Determina que o valor passado no nPercHeight é na verdade a qtd de pixel a ser usada.
	// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, é necessário informar o cIDSheet
	// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
	oView:CreateHorizontalBox( "MASTER" , 100, /*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/,/*cIDSheet*/ )
	// Associa um View a um box
	oView:SetOwnerView( "GFEA511_GVE" , "MASTER" )
	
Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA511POS
Rotina para realizar as validacoes.
Uso Geral.

@param 	oModel	    Recebi o oMOdel principal

@author Israel Alcantara  Possoli
@since 22/10/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA511POS(oModel)
	local nOpc      := (oModel:GetOperation())
	local aArea     := getArea()
	local aAreaGVE  := GVE->(getArea())
	
	If nOpc == MODEL_OPERATION_INSERT
		
		If !ExistChav("GVE", oModel:GetValue("GFEA511_GVE", "GVE_CDVISI"))
			Help( ,, 'HELP',, "Já existe visitante com o código informado. Troque o código desse registro.", 1, 0)
			Return .F.
		EndIf

		If SuperGetMV('MV_CADERP',,'1') == "S"
			oModel:LoadValue('GFEA511_GVE', 'GVE_IDFUNC', "1")
		EndIf			
	EndIf

	If nOpc == MODEL_OPERATION_INSERT .Or. nOpc == MODEL_OPERATION_UPDATE  
		
		// Integração - Atribui o código da cidade, quando o campo GVE_NRCID estiver em branco, pelo nome e uf da cidade
		If AllTrim(FwFldGet("GVE_NRCID")) == "0".OR.Empty(FwFldGet("GVE_NRCID"))
			dbSelectArea("GU7")
			dbSetOrder(3)
			dbGoTop()
			
			If dbSeek(PADR(UPPER(M->GVE_NMCID),50, " ") + PADR(UPPER(M->GVE_UF),2, " "))
				oModel:LoadValue('GFEA511_GVE', 'GVE_NRCID', GU7->GU7_NRCID)
			Else
				oModel:LoadValue('GFEA511_GVE', 'GVE_NRCID',	"0")
				oModel:LoadValue('GFEA511_GVE', 'GVE_NMCID',	"")
				oModel:LoadValue('GFEA511_GVE', 'GVE_UF', 	"")
			EndIf
		EndIf
		// FIM - Integração
		
		// Verifica se CPF ja existe
		dbSelectArea("GVE")
		GVE->( dbSetOrder(1) )
		GVE->( dbGoTop() )
		While GVE->( !Eof() )

			If oModel:GetValue("GFEA511_GVE", "GVE_CPF") == GVE->GVE_CPF .and. nOpc != MODEL_OPERATION_UPDATE
				Help( ,, 'HELP',, "Já existe visitante com o CPF informado. Informe outro CPF.", 1, 0)
				Return .F.
			EndIf

			GVE->( dbSkip() )
		EndDo
				
	EndIf
	
	RestArea(aAreaGVE)
	RestArea(aArea)
	
Return .T.
 
