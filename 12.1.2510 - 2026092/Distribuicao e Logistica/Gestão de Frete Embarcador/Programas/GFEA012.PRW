#INCLUDE "GFEA012.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GFEA012  ³ Autor ³ Luiz Fernando Soares  ³ Data ³ 29.10.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cadastro de Motoristas e Ajudantes	                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ GFEA012()	                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ 			 ³        ³XXXXXX³	                                      ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

//-------------------------------------------------------------------

Function GFEA012()
	Local oBrowse
	Private aRotina := MenuDef()

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GUU")			// Alias da tabela utilizada
	oBrowse:SetMenuDef("GFEA012")	// Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription(STR0001)	// Descrição do browse //"Cadastro de Motoristas e Ajudantes"
	oBrowse:Activate() 

	                                      
Return(Nil)

//-------------------------------------------------------------------//
//-------------------------Funcao MenuDEF----------------------------//
//-------------------------------------------------------------------//
Static Function MenuDef()
	Local aRotina := {}
	//-------------------------------------------------------
	// Adiciona botões do browse
	//-------------------------------------------------------    
	ADD OPTION aRotina TITLE STR0002   	ACTION "AxPesqui"        OPERATION 1 ACCESS 0 // "Pesquisar"
	ADD OPTION aRotina TITLE STR0004   	ACTION "VIEWDEF.GFEA012" OPERATION 2 ACCESS 0 // "Visualizar"
	/*
	Habilitar botões (Incluir, excluir, Copiar) SOMENTE SE:
	SE o ERP Integrado (MV_ERPGFE) for Protheus E Origem dos Cadastros OMS (MV_CADOMS) = SIGAGFE
	OU
	ERP Integrado (MV_ERPGFE) diferente de Protheus e Origem dos Cadastros (MV_CADERP) = SIGAGFE.
	*/

	// Integração - Retira botão incluir quando for integrago com o ERP
	If ((SuperGetMv("MV_ERPGFE",.F.,"2") == "2").and.(SuperGetMv("MV_CADOMS",.F.,"2") == "2")) .or. ((SuperGetMv("MV_ERPGFE",.F.,"2")!= "2"))
		ADD OPTION aRotina TITLE STR0006   	ACTION "VIEWDEF.GFEA012" OPERATION 3 ACCESS 0 // "Incluir"      
	EndIf
	ADD OPTION aRotina TITLE STR0007   	ACTION "VIEWDEF.GFEA012" OPERATION 4 ACCESS 0 // "Alterar"
	
	// Integração - Retira botão incluir quando for integrago com o ERP
	If ((SuperGetMv("MV_ERPGFE",.F.,"2") == "2").and.(SuperGetMv("MV_CADOMS",.F.,"2") == "2")) .or. ((SuperGetMv("MV_ERPGFE",.F.,"2")!= "2"))
		ADD OPTION aRotina TITLE STR0008   	ACTION "VIEWDEF.GFEA012" OPERATION 5 ACCESS 0 // "Excluir"
		ADD OPTION aRotina TITLE STR0009   	ACTION "VIEWDEF.GFEA012" OPERATION 9 ACCESS 0 // "Copiar"
	EndIf
	
	ADD OPTION aRotina TITLE STR0010 	ACTION "VIEWDEF.GFEA012" OPERATION 8 ACCESS 0 // "Imprimir"
    ADD OPTION aRotina TITLE "Anexos" ACTION "MsDocument('GUU',GUU->(RecNo()), 4)"  OPERATION 4 ACCESS 0  // "Anexo"
	
Return aRotina

//-------------------------------------------------------------------//
//-------------------------Funcao ModelDEF----------------------------//
//-------------------------------------------------------------------//
Static Function ModelDef()
	Local oStruGUU := FWFormStruct( 1, 'GUU' ) // Estrutura da tabela
	Local oModel
	
	// Acrescenta um campo a estrutura antes a criação do model
	oStruGUU:AddField( ;                      // Ord. Tipo Desc.
	STR0015          , ;      // [01]  C   Titulo do campo
	STR0015          , ;      // [02]  C   ToolTip do campo
	'GUU_CARGO'      , ;      // [03]  C   Id do Field
	'C'              , ;      // [04]  C   Tipo do campo
	8                , ;      // [05]  N   Tamanho do campo
	0                , ;      // [06]  N   Decimal do campo
	NIL              , ;      // [07]  B   Code-block de validação do campo
	NIL              , ;      // [08]  B   Code-block de validação When do campo
	NIL              , ;      // [09]  A   Lista de valores permitido do campo
	NIL              , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
	{ || '' }        , ;      // [11]  B   Code-block de inicializacao do campo
	NIL              , ;      // [12]  L   Indica se trata-se de um campo chave
	NIL              , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.T.              )        // [14]  L   Indica se o campo é virtual	
	
	// cID     Identificador do modelo 
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição
	oModel := MPFormModel():New("GFEA012", /*bPre*/,{ |oX| GFEA012POS( oX ) }  /*bPost*/, /*bCommit*/, /*bCancel*/)
	/* oModel:SetVldActivate ( { |oMod| GFEA012VLD( oMod ) } ) */
	
	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
	// bPost        Code-Block de validação do formulário de edição
	// bLoad        Code-Block de carga dos dados do formulário de edição
	oModel:AddFields("GFEA012_GUU", Nil, oStruGUU,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetPrimaryKey({"GUU_FILIAL", "GUU_CDMTR"})
Return oModel

//-------------------------------------------------------------------//
//-------------------------Funcao ViewDef----------------------------//
//-------------------------------------------------------------------//
Static Function ViewDef()
	Local oModel  := FWLoadModel("GFEA012")
	Local oView   := Nil 
	Local oStruct := FWFormStruct(2,"GUU")
	
	// Integração - Desabilita campos
	If SuperGetMV("MV_CADOMS",,"1") $ "1S"
		oStruct:SetProperty( "GUU_CDMTR"  , MVC_VIEW_CANCHANGE ,.F.)
		oStruct:SetProperty( "GUU_NMMTR"  , MVC_VIEW_CANCHANGE ,.F.)
		oStruct:SetProperty( "GUU_PSEUD"  , MVC_VIEW_CANCHANGE ,.F.)
		oStruct:SetProperty( "GUU_TPMTR"  , MVC_VIEW_CANCHANGE ,.F.)
		oStruct:SetProperty( "GUU_IDFED"  , MVC_VIEW_CANCHANGE ,.F.)
		oStruct:SetProperty( "GUU_RG"     , MVC_VIEW_CANCHANGE ,.F.)
		oStruct:SetProperty( "GUU_ORGEXP" , MVC_VIEW_CANCHANGE ,.F.)
		oStruct:SetProperty( "GUU_CDTRP"  , MVC_VIEW_CANCHANGE ,.F.)
		oStruct:SetProperty( "GUU_NMTRP"  , MVC_VIEW_CANCHANGE ,.F.)
		oStruct:SetProperty( "GUU_SIT"    , MVC_VIEW_CANCHANGE ,.F.)
		oStruct:SetProperty( "GUU_NUMCNH" , MVC_VIEW_CANCHANGE ,.F.)
		oStruct:SetProperty( "GUU_REGCNH" , MVC_VIEW_CANCHANGE ,.F.)
		oStruct:SetProperty( "GUU_DTECNH" , MVC_VIEW_CANCHANGE ,.F.)
		oStruct:SetProperty( "GUU_DTVCNH" , MVC_VIEW_CANCHANGE ,.F.)
		oStruct:SetProperty( "GUU_MUNCNH" , MVC_VIEW_CANCHANGE ,.F.)
		oStruct:SetProperty( "GUU_ESTCNH" , MVC_VIEW_CANCHANGE ,.F.)
		oStruct:SetProperty( "GUU_CATCNH" , MVC_VIEW_CANCHANGE ,.F.)
		oStruct:SetProperty( "GUU_MOPP"   , MVC_VIEW_CANCHANGE ,.F.)
 	EndIf
 	//Fim integração

	oView := FWFormView():New()
	// Objeto do model a se associar a view.
	oView:SetModel(oModel)
	// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
	// oStruct - Objeto do model a se associar a view.
	// cLinkID - Representa o ID criado no Model ,Só é necessári o caso estamos mundando o ID no View.
	oView:AddField( "GFEA012_GUU" , oStruct, /*cLinkID*/ )	//
	// cID		  	Id do Box a ser utilizado 
	// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. é a qtd de pixel exato)
	// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas criações uma dentro da outra.
	// lFixPixel	Determina que o valor passado no nPercHeight é na verdade a qtd de pixel a ser usada.
	// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, é necessário informar o cIDSheet
	// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
	oView:CreateHorizontalBox( "MASTER" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	// Associa um View a um box
	oView:SetOwnerView( "GFEA012_GUU" , "MASTER" )
	oView:AddUserButton("Capturar Foto","MAGIC_BMP",{|| GFEGetFoto("GUU",/*Id Foto*/, oModel,"GUU_BITMAP","GUU_CDMTR"),oView:LMODIFY :=.T.,oModel:LMODIFY := .T.}) //Foto

Return oView

//-------------------------

Function GFEA012POS(oModel)
	Local lRet     := .T.
	local nOpc     := (oModel:GetOperation())
	Local aArea    := GetArea()
	Local aAreaGUU := GUU->(GetArea())
	

	
	//Quando a integração for oms e o motorista e for excluido no omsa040, será excluido tbm no gfe.
	If lRet.AND.nOpc == 4
		If GUU->GUU_SIT <> FwFldGet( 'GUU_SIT' )
			RecLock("GUU",.F.)
				GUU->GUU_DTSIT := DDATABASE
			MsUnLock("GUU")			
		EndIf
	EndIf

	//Não é permitido mais de um motorista/ajudante com mesmo CPF, quando a origem dos dados for diferente de OMS.
	If lRet .AND. SuperGetMV("MV_CADOMS",,"1") <> "1" .AND. (nOpc == 3 .Or. nOpc == 4)
		dbSelectArea('GUU')
		dbSetOrder(2)
		If dbSeek(xFilial('GUU')+FwFldGet("GUU_IDFED"))
			If !(nOpc == 4 .And. GUU->GUU_FILIAL == xFilial("GUU") .And. GUU->GUU_CDMTR == FwFldGet("GUU_CDMTR"))
				Help( ,, STR0011,, STR0012, 1, 0) //'HELP'###'Não é permitido mais de um motorista/ajudante com mesmo CPF.'
				lRet := .F.
			EndIf
		EndIf
	EndIf
	
	RestArea(aAreaGUU)
	RestArea(aArea)

Return lRet 

 