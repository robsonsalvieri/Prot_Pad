#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GFEA513.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA513

Cadastro de Restrições

@author Jorge Matos Valcanaia
@since 06/09/2010
@version 1.0
/*/
//-------------------------------------------------------------------
//-------------------------------------------------------------------
Function GFEA513()
	Local oBrowse          
	Private lCopy := .F.	

	If !GFECheckGX4()
		Return .F.
	EndIF

	If !GFEA510COMP()
		MsgStop( "Necessário aplicar o update U_GFE11I20 para utilizar o processo de pátios e portarias." )
		Return .F.
	EndIf

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GVM")				// Alias da tabela utilizada
	oBrowse:SetMenuDef("GFEA513")		// Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription(STR0001) //"Cadastro de Restrições"
	oBrowse:Activate()
Return(Nil)

//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	//-------------------------------------------------------
	// Adiciona botões do browse
	//-------------------------------------------------------
	ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"        OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.GFEA513" OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.GFEA513" OPERATION 3 ACCESS 0 //"Incluir"
	ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.GFEA513" OPERATION 4 ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.GFEA513" OPERATION 5 ACCESS 0 //"Excluir"
	ADD OPTION aRotina TITLE STR0007 ACTION "GFEA513CPY()"    OPERATION 9 ACCESS 0 //"Copiar"
	ADD OPTION aRotina TITLE STR0008 ACTION "VIEWDEF.GFEA513" OPERATION 8 ACCESS 0 //"Imprimir"
	
Return aRotina

//-------------------------------------------------------------------

Static Function ModelDef()
	Local oModel

	// cID     Identificador do modelo 
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição
	oModel := MPFormModel():New("GFEA513", /*bPre*/, /*bPost*/ {|oMod|GFEA513POS(oMod)}, /*bCommit*/, /*bCancel*/)
	
	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
	// bPost        Code-Block de validação do formulário de edição
	// bLoad        Code-Block de carga dos dados do formulário de edição
	oModel:AddFields("GFEA513_GVM", Nil, FWFormStruct(1,"GVM"),/*bPre*/,,/*bLoad*/)
	oModel:SetPrimaryKey({"GVM_FILIAL", "GVM_TPEMIT", "GVM_CDEMIT"})
	oModel:SetActivate( {|oMod| GFEA513ACT(oMod)} )
	
Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel := FWLoadModel("GFEA513")
	Local oView  := Nil
	Local oStruct := FWFormStruct(2,"GVM")


	oView := FWFormView():New()
	// Objeto do model a se associar a view.
	oView:SetModel(oModel)
	// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
	// oStruct - Objeto do model a se associar a view.
	// cLinkID - Representa o ID criado no Model ,Só é necessári o caso estamos mundando o ID no View.
	oView:AddField( "GFEA513_GVM" , oStruct, /*cLinkID*/ )	//
	// cID		  	Id do Box a ser utilizado 
	// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. é a qtd de pixel exato)
	// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas criações uma dentro da outra.
	// lFixPixel	Determina que o valor passado no nPercHeight é na verdade a qtd de pixel a ser usada.
	// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, é necessário informar o cIDSheet
	// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
	oView:CreateHorizontalBox( "MASTER" , 100, /*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/,/*cIDSheet*/ )
	// Associa um View a um box
	oView:SetOwnerView( "GFEA513_GVM" , "MASTER" )   
	
	oStruct:SetProperty( "GVM_CDEMIT", MVC_VIEW_LOOKUP, "GFEGVM" ) 
	
Return oView        

Function GFEA513ACT(oModel)
Local nI
Local oModelGVM  := oModel:GetModel("GFEA513_GVM")
Local aFieldsGVM := oModelGVM:GetStruct():aFields
Local aCmp       := {"GVM_TPEMIT","GVM_DTINRE","GVM_DTFIRE","GVM_IDBLOQ","GVM_RESTRI"}

If IsInCallStack("GFEA513") .And. lCopy

	For nI := 1 To Len(aFieldsGVM)
		If aFieldsGVM[nI][14]
			Loop
		ElseIf aScan( aCmp, { |x| x == aFieldsGVM[nI][3] } ) > 0 .And. !Empty(&("GVM->"+aFieldsGVM[nI][3]))
			oModelGVM:SetValue(aFieldsGVM[nI][3], &("GVM->"+aFieldsGVM[nI][3]))
		Else
			oModel:ClearField("GFEA513_GVM",aFieldsGVM[nI][3])
		EndIf
	Next nI     
	
	lCopy := .F.

EndIf

Return
             

Function GFEA513CPY()

	lCopy := .T.

	FWExecView(STR0009,"GFEA513",3,,{|| .T.}) //"Cópia"

Return

Function GFEA513EMI()
Local cTpEmit := Val(FwFldGet("GVM_TPEMIT"))
Local cTbl    := {"GU3","GUU","GVE"}[cTpEmit]
	
Return Posicione(cTbl,1,xFilial(cTbl)+FwFldGet("GVM_CDEMIT"),{"GU3_NMEMIT","GUU_NMMTR","GVE_NMVISI"}[cTpEmit])

Function GFEA513CPO()
Local lRet := .T.            
Local cCdEmit := FwFldGet("GVM_CDEMIT") 
Local cTpEmit := FwFldGet("GVM_TPEMIT")
Local aAreaGVM := GVM->( GetArea() )

If !Vazio(cCdEmit)
	If !ExistCpo({"GU3","GUU","GVE"}[Val(cTpEmit)],cCdEmit,1)
		Help( ,, 'HELP',,STR0024+{STR0021,STR0022,STR0023}[Val(cTpEmit)]+STR0025, 1, 0) //"Não existe " ### "emitente" ### "motorista/ajudante" ### "visitante" ### " para o valor informado."
		lRet := .F.
	ElseIf INCLUI .And. ExistCpo("GVM",cTpEmit+cCdEmit,1)
		Help( ,, 'HELP',,STR0026+{STR0021,STR0022,STR0023}[Val(cTpEmit)]+".", 1, 0) //"Já existe outra restrição com o mesmo " ### "emitente" ### "motorista/ajudante" ### "visitante"
		lRet := .F.
	EndIf
EndIf
	
RestArea(aAreaGVM)	
	
Return lRet

Function GFEGVMF3(cCampo)
Local lRet		:= .F.

If FwFldGet("GVM_TPEMIT") == "1"
	lRet := ConPad1(,,,"GU3")
ElseIf FwFldGet("GVM_TPEMIT") == "2"  
	lRet := ConPad1(,,,"GUU")
ElseIf FwFldGet("GVM_TPEMIT") == "3"
	lRet := ConPad1(,,,"GVE")
Endif		

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA513POS
Verificação - Data Inicial deve ser menor que a Data Final.

@author Helder Fuckner dos Santos
@since 06/08/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA513POS(oModel)
	Local lRet	:= .T.
	
	If oModel:GetOperation() != MODEL_OPERATION_DELETE
		If !GFEA513CPO()
			lRet := .F.
		EndIf
	EndIf
	
	If AllTrim( StrTran( DtoC(FwFldGet("GVM_DTFIRE")) ,"/","") ) != ""
		If FwFldGet("GVM_DTINRE") > FwFldGet("GVM_DTFIRE")
			Help( ,, 'HELP',, "Data Inicial deve ser menor que a Data Final", 1, 0) //"Data Inicial deve ser menor que a Data Final"
			lRet := .F.
		EndIf
	EndIf

Return lRet
