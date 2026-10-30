#INCLUDE "GFEA017.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA017
Cadastro de Espécie de Documento
Uso Generico.

@sample
GFEA017()

@author Israel A Possoli
@since 08/12/09
@version 1.0
--------------------------------------------------------------------------------------------------/*/
                                                                
//-------------------------------------------------------------------
Function GFEA017()
	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GVT")										// Alias da tabela utilizada
	oBrowse:SetMenuDef("GFEA017")								// Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription(STR0001)	// Descrição do browse //"Cadastro de Espécie de Documento"

	oBrowse:Activate() 
Return(Nil)

//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE STR0002  ACTION "AxPesqui"         OPERATION 1 ACCESS 0 //"Pesquisar" //"Pesquisar"
	ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.GFEA017" OPERATION 2 ACCESS 0 //"Visualizar" //"Visualizar"
	ADD OPTION aRotina TITLE STR0004 	  ACTION "VIEWDEF.GFEA017" OPERATION 3 ACCESS 0 //"Incluir" //"Incluir"
	ADD OPTION aRotina TITLE STR0005 	  ACTION "VIEWDEF.GFEA017" OPERATION 4 ACCESS 0 //"Alterar" //"Alterar"
	ADD OPTION aRotina TITLE STR0006 	  ACTION "VIEWDEF.GFEA017" OPERATION 5 ACCESS 0 //"Excluir" //"Excluir"
	ADD OPTION aRotina TITLE STR0007 	  ACTION "VIEWDEF.GFEA017" OPERATION 9 ACCESS 0 //"Copiar" //"Copiar"
	ADD OPTION aRotina TITLE STR0008   ACTION "VIEWDEF.GFEA017" OPERATION 8 ACCESS 0 //"Imprimir" //"Imprimir"

Return aRotina

//-------------------------------------------------------------------

Static Function ModelDef()
	Local oModel
	Local oStructGVT := FWFormStruct(1, "GVT")
                                              
	// cID     Identificador do modelo 
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição

	oModel := MPFormModel():New("GFEA017", ,{|oMod| GFEA017POS(oMod)}, /*bCommit*/, /*bCancel*/)
	oModel:SetVldActivate ( { |oMod| GFEA017Vl( oMod ) } ) 

	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
	// bPost        Code-Block de validação do formulário de edição
	// bLoad        Code-Block de carga dos dados do formulário de edição
	oModel:AddFields("GFEA017_GVT", Nil, oStructGVT, /*bPre*/ ,/**/,/*bLoad*/)
	oModel:SetPrimaryKey({"GVT_FILIAL", "GVT_CDESP"})

Return oModel

Static Function ViewDef()
	Local oModel := FWLoadModel("GFEA017")
	Local oView := Nil
	Local oStructGVT := FWFormStruct(2,"GVT")
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField( "GFEA017_GVT" , oStructGVT )
	
	If SuperGetMV("MV_GFEPC") != "1"
		If AScan(oStructGVT:aFields,{|x| x[1] == "GVT_CRDPC"}) != 0
			oStructGVT:SetProperty("GVT_CRDPC" , MVC_VIEW_CANCHANGE ,.F.)
		EndIf
	EndIf    
	
Return oView

Function GFEA017Vl(oModel)
	Local lRet 		:= .T.
	Local nOpc    	:= (oModel:GetOperation())
	Local oAreaGW3 	:= GW3->( GetArea() )
	      
	If nOpc == 5
		dbSelectArea("GW3")
		dbSetOrder(1)
		If dbSeek(xFilial("GW3")+GVT->GVT_CDESP)
			Help( ,, 'HELP',, STR0009, 1, 0) //"Não é possível excluir, pois existe um Documento de Frete utilizando esta espécie"
			lRet := .F.
		EndIf
	EndIf
	
	RestArea(oAreaGW3)

Return lRet

Function GFEA017POS(oModel)
	Local nOpc := oModel:GetOperation()
	
	If nOpc != MODEL_OPERATION_DELETE 
		If FwFldGet("GVT_TPIMP") != "1" .And. FwFldGet("GVT_CHVCTE") == "1"
			Help( ,, 'HELP',, "Chave CT-e não pode ser obrigatória para espécies onde o tipo do imposto seja diferente de ICMS", 1, 0,)
			Return .F.
		EndIf		
	EndIf 
Return .T.