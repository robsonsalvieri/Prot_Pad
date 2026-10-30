#INCLUDE "GFEA046.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/
//Inclusão Pátios 12.1.4   
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GFEA046 ³ Autor ³ Luiz Fernando Soares  ³ Data ³ 29.10.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cadastro de Veiculos					                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ GFEA046()	                                              ³±±
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
Function GFEA046()
	Local oBrowse
	Private aRotina := MenuDef()
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GU8")							// Alias da tabela utilizada
	oBrowse:SetMenuDef("GFEA046")				    // Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription(STR0009)	// Descrição do browse //"Cadastro de Veículos"
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
	ADD OPTION aRotina TITLE STR0001   ACTION "AxPesqui"        OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE STR0002   ACTION "VIEWDEF.GFEA046" OPERATION 2 ACCESS 0 //"Visualizar"

	/*
	Habilitar botões (Incluir, excluir, Copiar) SOMENTE SE:
	SE o ERP Integrado (MV_ERPGFE) for Protheus E Origem dos Cadastros OMS (MV_CADOMS) = SIGAGFE
	OU
	ERP Integrado (MV_ERPGFE) diferente de Protheus e Origem dos Cadastros (MV_CADERP) = SIGAGFE.
	*/

	If ((SuperGetMv("MV_ERPGFE",.F.,"2") == "2").and.(SuperGetMv("MV_CADOMS",.F.,"2") == "2")) .or. ((SuperGetMv("MV_ERPGFE",.F.,"2")!= "2"))
		ADD OPTION aRotina TITLE STR0003   ACTION "VIEWDEF.GFEA046" OPERATION 3 ACCESS 0 //"Incluir"
	Endif
	
	ADD OPTION aRotina TITLE STR0004   ACTION "VIEWDEF.GFEA046" OPERATION 4 ACCESS 0 //"Alterar"
	
	If ((SuperGetMv("MV_ERPGFE",.F.,"2") == "2").and.(SuperGetMv("MV_CADOMS",.F.,"2") == "2")) .or. ((SuperGetMv("MV_ERPGFE",.F.,"2")!= "2"))
		ADD OPTION aRotina TITLE STR0005   ACTION "VIEWDEF.GFEA046" OPERATION 5 ACCESS 0 //"Excluir"
		ADD OPTION aRotina TITLE STR0006   ACTION "VIEWDEF.GFEA046" OPERATION 9 ACCESS 0 //"Copiar"
	Endif
	
	ADD OPTION aRotina TITLE STR0007   ACTION "VIEWDEF.GFEA046" OPERATION 8 ACCESS 0 //"Imprimir"
    ADD OPTION aRotina TITLE "Anexos" ACTION "MsDocument('GU8',GU8->(RecNo()), 3)"  OPERATION 4 ACCESS 0  // "Anexo"
	
	Return aRotina
	
	//-------------------------------------------------------------------//
	//-------------------------Funcao ModelDEF----------------------------//
	//-------------------------------------------------------------------//
	Static Function ModelDef()
	
	Local oModel
	
	// cID     Identificador do modelo 
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição
	oModel := MPFormModel():New("GFEA046", /*bPre*/, { |oX| GFEA046POS( oX ) } /* bPost*/, /*bCommit*/, /*bCancel*/)
	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
	// bPost        Code-Block de validação do formulário de edição
	// bLoad        Code-Block de carga dos dados do formulário de edição
	oModel:AddFields("GFEA046_GU8", Nil, FWFormStruct(1,"GU8"),/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetPrimaryKey({"GU8_FILIAL", "GU8_CDVEIC"})
Return oModel

//-------------------------------------------------------------------//
//-------------------------Funcao ViewDef----------------------------//
//-------------------------------------------------------------------//
Static Function ViewDef()
	Local oModel := FWLoadModel("GFEA046")
	Local oView  := Nil
	Local oStructGU8 := FWFormStruct(2,"GU8")   
	
	// Integração - Desabilita campos
	If SuperGetMV("MV_CADOMS",,"1") $ "1S"
		oStructGU8:SetProperty( "GU8_CDVEIC" , MVC_VIEW_CANCHANGE ,.F.)
		oStructGU8:SetProperty( "GU8_CDTPVC" , MVC_VIEW_CANCHANGE ,.F.)
		oStructGU8:SetProperty( "GU8_PLACA"  , MVC_VIEW_CANCHANGE ,.F.)
		oStructGU8:SetProperty( "GU8_UFPLAC" , MVC_VIEW_CANCHANGE ,.F.)
		oStructGU8:SetProperty( "GU8_SIT"    , MVC_VIEW_CANCHANGE ,.F.)
		oStructGU8:SetProperty( "GU8_VOLUT"  , MVC_VIEW_CANCHANGE ,.F.)
		oStructGU8:SetProperty( "GU8_CARGUT" , MVC_VIEW_CANCHANGE ,.F.)
	Endif                            
	//Fim integração                        
	
	oView := FWFormView():New()
	// Objeto do model a se associar a view.
	oView:SetModel(oModel)
	// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
	// oStruct - Objeto do model a se associar a view.
	// cLinkID - Representa o ID criado no Model ,Só é necessári o caso estamos mundando o ID no View.
	oView:AddField( "GFEA046_GU8" , oStructGU8, /*cLinkID*/ )	//
	// cID		  	Id do Box a ser utilizado 
	// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. é a qtd de pixel exato)
	// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas criações uma dentro da outra.
	// lFixPixel	Determina que o valor passado no nPercHeight é na verdade a qtd de pixel a ser usada.
	// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, é necessário informar o cIDSheet
	// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
	oView:CreateHorizontalBox( "MASTER" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	// Associa um View a um box
	oView:SetOwnerView( "GFEA046_GU8" , "MASTER" )   
Return oView



//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA046POS
Rotina para realizar as validacoes do formulário de edição (bPost)
Uso Geral.

@param 	oModel	    Recebi o oModel principal

@author Israel A. Possoli
@since 02/11/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA046POS (oModel)
	Local lRet    := .T.
	Local nOpc    := (oModel:GetOperation())

	If lRet .And. (nOpc == MODEL_OPERATION_INSERT .Or. nOpc == MODEL_OPERATION_UPDATE)
	  	If oModel:GetValue( 'GFEA046_GU8', 'GU8_SIT' )  == "2" .and. Empty(M->GU8_DSSIT)
			Help( ,, 'HELP',, STR0008, 1, 0,) //'Informar descrição do motivo de estar inativo'
			lRet := .F.
		EndIf
	Endif
	If lRet .And. nOpc == MODEL_OPERATION_INSERT
		dbSelectArea("GU8")
		dbSetOrder(2)
		If dbSeek(xFilial("GU8")+FwFldGet("GU8_PLACA"))
			While !Eof() .And. GU8->GU8_PLACA == FwFldGet("GU8_PLACA")
				If !Empty(GU8->GU8_CDPROP) .And. FwFldGet("GU8_CDPROP") == GU8->GU8_CDPROP
					Help( ,, 'HELP',, 'Proprietário já existente para a placa informada.', 1, 0,) //'Proprietário já existente para a placa informada.'
					Return .F.	
				EndIf
				dbSkip()
			EndDo
		EndIf	
	Endif
	
	
Return(lRet) 


Function GFEA046WIF()
Return .T.