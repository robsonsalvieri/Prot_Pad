#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GFEA512.CH"

//-------------------------------------------------------------------
//Inclusão Pátios 12.1.4
/*/{Protheus.doc} GFEA512 

Cadastro de Recorrência

@author Jorge Matos Valcanaia
@since 29/09/2010
@version 1.0
/*/
//-------------------------------------------------------------------
//-------------------------------------------------------------------
Function GFEA512 ()
	Local oBrowse 
	Private cChave := ""//Chave da recrrência p/ quando alterar, verificar se é a própria recorrência ao salvar.

	If !GFECheckGX4()
		Return .F.
	EndIF

	If !GFEA510COMP()
		MsgStop( "Necessário aplicar o update U_GFE11I20 para utilizar o processo de pátios e portarias." )
		Return .F.
	EndIf
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GVL")				// Alias da tabela utilizada
	oBrowse:SetMenuDef("GFEA512")		// Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription(STR0001) //"Cadastro de Recorrência"
	oBrowse:Activate()
	
Return(Nil)

//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	//-------------------------------------------------------
	// Adiciona botões do browse
	//-------------------------------------------------------
	ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"        OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.GFEA512 " OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.GFEA512 " OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.GFEA512 " OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.GFEA512 " OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.GFEA512 " OPERATION 8 ACCESS 0
	
Return aRotina

//-------------------------------------------------------------------

Static Function ModelDef()
	Local oModel

	// cID     Identificador do modelo 
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição
	oModel := MPFormModel():New("GFEA512", /*bPre*/,{|oModel| GFEA512POS(oModel)}, /*bCommit*/, /*bCancel*/)
	
	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
	// bPost        Code-Block de validação do formulário de edição
	// bLoad        Code-Block de carga dos dados do formulário de edição
	oModel:AddFields("GFEA512_GVL", Nil, FWFormStruct(1,"GVL"),/*bPre*/,,/*bLoad*/)
	oModel:SetPrimaryKey({"GVL_FILIAL", "GVL_CDEMIT", "GVL_CDOPER", "GVL_SEQ"})
	
	oModel:SetActivate({|oMod| GFEA512ACT(oMod)})
	
Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel := FWLoadModel("GFEA512 ")
	Local oView  := Nil
	Local oStruct := FWFormStruct(2,"GVL")


	oView := FWFormView():New()
	// Objeto do model a se associar a view.
	oView:SetModel(oModel)
	// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
	// oStruct - Objeto do model a se associar a view.
	// cLinkID - Representa o ID criado no Model ,Só é necessári o caso estamos mundando o ID no View.
	oView:AddField( "GFEA512_GVL" , oStruct, /*cLinkID*/ )	//
	// cID		  	Id do Box a ser utilizado 
	// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. é a qtd de pixel exato)
	// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas criações uma dentro da outra.
	// lFixPixel	Determina que o valor passado no nPercHeight é na verdade a qtd de pixel a ser usada.
	// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, é necessário informar o cIDSheet
	// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
	oView:CreateHorizontalBox( "MASTER" , 100, /*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/,/*cIDSheet*/ )
	// Associa um View a um box
	oView:SetOwnerView( "GFEA512_GVL" , "MASTER" )
	
Return oView                                        

Function GFEA512TP()
Local cRetorno := "1"                                                         	
	                                                                    
	dbSelectArea("GU3")
	dbSetOrder(1)
	If dbSeek(xFilial("GU3")+FwFldGet("GVL_CDEMIT"))
		If GU3->GU3_TRANSP == "1"
			cRetorno := "1"
		ElseIF GU3->GU3_CLIEN == "1"
			cRetorno := "2"
		ElseIF GU3->GU3_FORN == "1"
			cRetorno := "3"
		ElseIf GU3->GU3_AUTON == "1"
			cRetorno := "4"
		EndIf		
	EndIf
	
Return cRetorno

Function GFEA512POS(oModel)
	Local nOpc  := (oModel:GetOperation())
	Local aArea 
	
	If nOpc == 3 .Or. nOpc == 4
		aArea := GVL->(GetArea())
		dbSelectArea("GVL")
		GVL->( dbSetOrder(1) )
		If GVL->( dbSeek( xFilial("GVL") + FwFldGet("GVL_CDEMIT") + FwFldGet("GVL_CDOPER") + FwFldGet("GVL_SEQ") ) .And. cChave != FwFldGet("GVL_CDEMIT") + FwFldGet("GVL_CDOPER") + FwFldGet("GVL_SEQ") )
			Help( ,, 'HELP',,STR0008, 1, 0) //"Já existe um registro com a chave informada"
			Return .F.				
		EndIf
		RestArea(aArea)
		
		If FwFldGet("GVL_PERIOD") == "1"
			If Empty(FwFldGet("GVL_DIA1")) .And. Empty(FwFldGet("GVL_DIA2")) .And. Empty(FwFldGet("GVL_DIA3")) .And. Empty(FwFldGet("GVL_DIA4")) .And. Empty(FwFldGet("GVL_DIA5"))
				Help( ,, 'HELP',,STR0009, 1, 0) //"Pelo menos um dia deve ser preenchido"
				Return .F.				
			EndIf
			If !Empty(FwFldGet("GVL_DIA1")) .And. Empty(FwFldGet("GVL_HR1"))
				Help( ,, 'HELP',,STR0010, 1, 0) //"Deve ser informado o campo Hora1 do campo Data1"
				Return .F.
			EndIf
			
			If !Empty(FwFldGet("GVL_DIA2")) .And. Empty(FwFldGet("GVL_HR2"))
				Help( ,, 'HELP',,STR0011, 1, 0) //"Deve ser informado o campo Hora2 do campo Data2"
				Return .F.
			EndIf
			
			If !Empty(FwFldGet("GVL_DIA3")) .And. Empty(FwFldGet("GVL_HR3"))
				Help( ,, 'HELP',,STR0012, 1, 0) //"Deve ser informado o campo Hora3 do campo Data3"
				Return .F.
			EndIf
			
			If !Empty(FwFldGet("GVL_DIA4")) .And. Empty(FwFldGet("GVL_HR4"))
				Help( ,, 'HELP',,STR0013, 1, 0) //"Deve ser informado o campo Hora4 do campo Data4"
				Return .F.
			EndIf
			
			If !Empty(FwFldGet("GVL_DIA5")) .And. Empty(FwFldGet("GVL_HR5"))
				Help( ,, 'HELP',,STR0014, 1, 0) //"Deve ser informado o campo Hora5 do campo Data5"
				Return .F.
			EndIf	
		ElseIf FwFldGet("GVL_PERIOD") == "2"    
			If FwFldGet("GVL_IDSEG") == "2" .And. FwFldGet("GVL_IDTER") == "2" .And. FwFldGet("GVL_IDQUA") == "2" .And. FwFldGet("GVL_IDQUI") == "2" .And. FwFldGet("GVL_IDSEX") == "2" .And. FwFldGet("GVL_IDSAB") == "2" .And. FwFldGet("GVL_IDDOM") == "2" 
				Help( ,, 'HELP',,STR0015, 1, 0) //"Pelo menos um dia da semana deve estar marcado como 'Sim'"
				Return .F.
			EndIf
			If FwFldGet("GVL_IDSEG") == "1" .And. Empty(FwFldGet("GVL_HRSEG"))   
				Help( ,, 'HELP',,STR0016, 1, 0) //"Deve ser informado o campo Hora Seg. do campo 2°Seg"
				Return .F.
			EndIf 
			If FwFldGet("GVL_IDTER") == "1" .And. Empty(FwFldGet("GVL_HRTER"))   
				Help( ,, 'HELP',,STR0017, 1, 0) //"Deve ser informado o campo Hora Ter. do campo 3°Ter"
				Return .F.
			EndIf 
			If FwFldGet("GVL_IDQUA") == "1" .And. Empty(FwFldGet("GVL_HRQUA"))   
				Help( ,, 'HELP',,STR0018, 1, 0) //"Deve ser informado o campo Hora Qua. do campo 4°Qua"
				Return .F.
			EndIf 
			If FwFldGet("GVL_IDQUI") == "1" .And. Empty(FwFldGet("GVL_HRQUI"))   
				Help( ,, 'HELP',,STR0019, 1, 0) //"Deve ser informado o campo Hora Qui. do campo 5°Qui"
				Return .F.
			EndIf 
			If FwFldGet("GVL_IDSEX") == "1" .And. Empty(FwFldGet("GVL_HRSEX"))   
				Help( ,, 'HELP',,STR0020, 1, 0) //"Deve ser informado o campo Hora Sex. do campo 6°Sex"
				Return .F.
			EndIf 
			If FwFldGet("GVL_IDSAB") == "1" .And. Empty(FwFldGet("GVL_HRSAB"))   
				Help( ,, 'HELP',,STR0021, 1, 0) //"Deve ser informado o campo Hora Sab. do campo Sab."
				Return .F.
			EndIf 
			If FwFldGet("GVL_IDDOM") == "1" .And. Empty(FwFldGet("GVL_HRDOM"))   
				Help( ,, 'HELP',,STR0022, 1, 0) //"Deve ser informado o campo Hora Dom. do campo Dom"
				Return .F.
			EndIf 
		EndIf
		
		// Permite somente EMITENTES do tipo “transportador” ou “autônomo”
		dbSelectArea("GU3")
		GU3->( dbSetOrder(1) )
		If GU3->( dbSeek( xFilial("GU3") + FwFldGet("GVL_CDEMIT") ) )
			If !(GU3->GU3_TRANSP == "1") .And. !(GU3->GU3_AUTON == "1")
				Help(,,'HELP',, "Emitente deve ser Transportador ou Autônomo.", 1, 0) // "Emitente deve ser Transportador ou Autônomo." 
				Return .F.
			EndIf
		EndIf

	    oModelGVL := oModel:GetModel( "GFEA512_GVL" ) 	  													
		If FwFldGet("GVL_PERIOD") == "1"
			oModelGVL:LoadValue( "GVL_IDSEG","2")
			oModelGVL:ClearField( "GVL_HRSEG" )
			
			oModelGVL:LoadValue( "GVL_IDTER","2")
			oModelGVL:ClearField( "GVL_HRTER" )
			
			oModelGVL:LoadValue( "GVL_IDQUA","2")
			oModelGVL:ClearField( "GVL_HRQUA" )
			
			oModelGVL:LoadValue( "GVL_IDQUI","2")
			oModelGVL:ClearField( "GVL_HRQUI" )
			
			oModelGVL:LoadValue( "GVL_IDSEX","2")
			oModelGVL:ClearField( "GVL_HRSEX" )
			
			oModelGVL:LoadValue( "GVL_IDSAB","2")
			oModelGVL:ClearField( "GVL_HRSAB" )
			
			oModelGVL:LoadValue( "GVL_IDDOM","2")
			oModelGVL:ClearField( "GVL_HRDOM" )   
		EndIf
	EndIf
	
Return .T.      
   
Function GFEA512EMP(cCampo)
Local lRet := .T.
lRet := IIF(Empty(cCampo),.F.,.T.)
Return lRet

Function GFEA512ACT(oModel)

	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		cChave := FwFldGet("GVL_CDEMIT") + FwFldGet("GVL_CDOPER") + FwFldGet("GVL_SEQ")
	EndIf

Return
 