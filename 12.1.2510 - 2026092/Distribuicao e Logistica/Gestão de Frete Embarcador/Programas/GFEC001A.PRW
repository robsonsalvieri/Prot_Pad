#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEC001A
Painel Gerencial - Recursos do Transportador

Uso Restrito.

@sample
GFEC001A()

@author Felipe Mendes / Alan Victor Lamb
@since 05/05/12
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFEC001A()
	Local aCoors     	 := FWGetDialogSize( oMainWnd )
	Private cCodEmit   := GU3->GU3_CDEMIT
	Private cNmEmit    := GU3->GU3_NMEMIT
	Private cTitulo    := 'Painel Gerencial - Recursos do Transportador'     
	Private aCamposCab := {}         
	
	Private oPanelVei, oPanelMot, oPanelCon, oBrowseVei, oBrowseMot, oBrowseCon, oWIN_TOP

	Define MsDialog oDlg Title cTitulo From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
	
	/*Criando objeto Layer*/
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDLG,.F.)
	
	oFWLayer:AddLine('LINE_TOP',20,.F.)
	oFWLayer:AddLine('LINE_MIDDLE',45,.F.)
	oFWLayer:AddLine('LINE_DOWN',35,.F.)
	/* Transportador selecionado */
	oFWLayer:AddCollumn('COL_TOP',100,.T.,'LINE_TOP')
	oFWLayer:AddWindow('COL_TOP','WIN_TOP','Transportador',100,.F.,.F.,,'LINE_TOP',)
    oWIN_TOP := oFWLayer:GetWinPanel('COL_TOP','WIN_TOP', 'LINE_TOP')
	/*Painel Veículos */
	oFWLayer:AddCollumn('COL_LEFT',50,.T.,'LINE_MIDDLE')
	oPanelVei := oFWLayer:GetColPanel('COL_LEFT','LINE_MIDDLE')
	/* Painel Motoristas */
	oFWLayer:AddCollumn('COL_RIGHT',50,.T.,'LINE_MIDDLE') 		
    oPanelMot := oFWLayer:GetColPanel('COL_RIGHT','LINE_MIDDLE')
	/* Painel Contatos */
	oFWLayer:AddCollumn('COL_DOWN',100,.T., 'LINE_DOWN')
	oPanelCon := oFWLayer:GetColPanel('COL_DOWN','LINE_DOWN')
	 
	//Transportador - Cabeçalho
	@ 001, 008 SAY   CodNome  PROMPT "Codigo / Nome" SIZE 040, 008 OF oWIN_TOP 		    COLORS 0, 16777215 PIXEL
    @ 000, 047 MSGET oCodEmit VAR cCodEmit 			  SIZE 047, 010 OF oWIN_TOP READONLY COLORS 0, 16777215 PIXEL
    @ 000, 100 MSGET oNmEmit  VAR cNmEmit  			  SIZE 200, 010 OF oWIN_TOP READONLY COLORS 0, 16777215 PIXEL
	
    oDLG:Activate(,,,.T.,,,{||Processa({||Iniciar()})})
Return 

Static Function Iniciar()
	//Browse Veiculos
	oBrowseVei:= FWMBrowse():New() 
	oBrowseVei:SetOwner(oPanelVei)  
	oBrowseVei:SetDescription("Veículos")
	oBrowseVei:SetAlias('GU8')
	oBrowseVei:SetFilterDefault("GU8_CDPROP == '" + cCodEmit + "'")
	oBrowseVei:DisableDetails()
	oBrowseVei:DisableConfig()
	oBrowseVei:SetWalkThru(.F.)
	oBrowseVei:SetAmbiente(.F.)
	oBrowseVei:SetProfileID("1")
	oBrowseVei:SetMenuDef("")
	oBrowseVei:AddButton("Visualizar","VIEWDEF.GFEA046",,2)
	oBrowseVei:Activate()
	 
	//Browse Motoristas
	oBrowseMot:= FWMBrowse():New() 
	oBrowseMot:SetOwner(oPanelMot)  
	oBrowseMot:SetDescription("Motoristas e Ajudantes")
	oBrowseMot:SetAlias("GUU")
	oBrowseMot:SetFilterDefault("GUU_CDTRP == '" + cCodEmit + "'")
	oBrowseMot:DisableDetails()
	oBrowseMot:DisableConfig()
	oBrowseMot:SetWalkThru(.F.)
	oBrowseMot:SetAmbiente(.F.)  
	oBrowseMot:SetProfileID("2")
	oBrowseMot:SetMenuDef("")
	oBrowseMot:AddButton("Visualizar","VIEWDEF.GFEA012",,2)
	oBrowseMot:Activate()    
	
	//Browse Contatos
	oBrowseCon:= FWMBrowse():New() 
	oBrowseCon:SetOwner(oPanelCon)  
	oBrowseCon:SetDescription("Contatos")
	oBrowseCon:SetAlias("GU2")
	oBrowseCon:SetFilterDefault("GU2_CDEMIT == '" + cCodEmit + "'")
	oBrowseCon:DisableDetails()  
	oBrowseCon:SetProfileID("3") 
	oBrowseCon:ForceQuitButton(.T.)
	oBrowseCon:SetMenuDef("GFEC001A") 
	oBrowseCon:Activate()
Return Nil

//---------------------------------------------------------------------------------------------------
//Menu dos Contatos
Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE "Pesquisar"  ACTION "AxPesqui"          OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.GFEC001A" OPERATION 2 ACCESS 0 //"Visualizar"
Return aRotina

//---------------------------------------------------------------------------------------------------
//Model dos Contatos - Chamado pelo botão Visualizar
Static Function ModelDef()
	Local oModel
	
	// cID     Identificador do modelo 
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição
	oModel := MPFormModel():New("GFEC001A",/*bPre*/,,/*bCommit*/, /*bCancel*/)
	
	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
	// bPost        Code-Block de validação do formulário de edição
	// bLoad        Code-Block de carga dos dados do formulário de edição
	oModel:AddFields("GFEC001A_GU2", /*cOwner*/, FWFormStruct(1,"GU2"),/*bPre*/,/*bPost*/,/*bLoad*/)
Return oModel

//---------------------------------------------------------------------------------------------------
//View dos Contatos - Chamado pelo botão Visualizar
Static Function ViewDef()
	Local oModel := FWLoadModel("GFEC001A")
	Local oView  := Nil
	
	oView := FWFormView():New()
	// Objeto do model a se associar a view.
	oView:SetModel(oModel)
	// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
	// oStruct - Objeto do model a se associar a view.
	// cLinkID - Representa o ID criado no Model ,Só é necessári o caso estamos mundando o ID no View.
	oView:AddField("GFEC001A_GU2",FWFormStruct(2,"GU2"))
	// cID		  	Id do Box a ser utilizado 
	// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. é a qtd de pixel exato)
	// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas criações uma dentro da outra.
	// lFixPixel	Determina que o valor passado no nPercHeight é na verdade a qtd de pixel a ser usada.
	// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, é necessário informar o cIDSheet
	// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
	
	oView:CreateHorizontalBox( "MASTER" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	
	// Associa um View a um box
	oView:SetOwnerView( "GFEC001A_GU2" , "MASTER" )
Return oView 
