#INCLUDE "GFEA103.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA103

Tabela de IR 

@author Jorge Matos Valcanaia
@since 23/02/10
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFEA103()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("GUP")							// Alias da tabela utilizada
oBrowse:SetMenuDef("GFEA103")					// Nome do fonte onde esta a função MenuDef
oBrowse:SetDescription(STR0001)      	// Descrição do browse //"Tabela de IR"
oBrowse:Activate()                                       

Return(Nil)

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
//-------------------------------------------------------
// Adiciona botões do browse
//-------------------------------------------------------
ADD OPTION aRotina TITLE STR0002  ACTION "AxPesqui"        OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.GFEA103" OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0004    ACTION "VIEWDEF.GFEA103" OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0005    ACTION "VIEWDEF.GFEA103" OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0006    ACTION "VIEWDEF.GFEA103" OPERATION 5 ACCESS 0 //"Excluir"
ADD OPTION aRotina TITLE STR0007   ACTION "VIEWDEF.GFEA103" OPERATION 8 ACCESS 0 //"Imprimir"

Return aRotina

//-------------------------------------------------------
//Função ModelDef
//-------------------------------------------------------

Static Function ModelDef()

Local oModel 
Local oStructGUP := FWFormStruct(1,"GUP")
Local oStructGUI := FWFormStruct(1,"GUI")

// cID     Identificador do modelo 
// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
// bPost   Code-Block de validação do formulário de edição
// bCommit Code-Block de persistência do formulário de edição
// bCancel Code-Block de cancelamento do formulário de edição
oModel := MPFormModel():New("GFEA103", /*bPre*/,{ |oX| GFEA100PS( oX ) }/*bPost*/, /*bCommit*/, /*bCancel*/)
// cId          Identificador do modelo
// cOwner       Identificador superior do modelo
// oModelStruct Objeto com  a estrutura de dados
// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
// bPost        Code-Block de validação do formulário de edição
// bLoad        Code-Block de carga dos dados do formulário de edição
oModel:AddFields("GFEA103_GUP", Nil, oStructGUP,/*bPre*/,/*bPost*/,/*bLoad*/)

oModel:AddGrid("GFEA103_GUI","GFEA103_GUP",oStructGUI,/*bLinePre*/,{ | oX | GFE103BW( oX ) },/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)

oModel:SetRelation("GFEA103_GUI",{{"GUI_FILIAL",'xFilial("GUI")'},{"GUI_INIVAL","GUP_INIVAL"}},"GUI_FILIAL+GUI_INIVAL")     

oModel:SetPrimaryKey({"GUP_FILIAL", "GUP_INIVAL"}) 

oModel:GetModel('GFEA103_GUI'):SetUniqueLine({'GUI_SEQ'})
 
oModel:GetModel("GFEA103_GUI"):SetDelAllLine(.T.) 

oModel:SetOptional("GFEA103_GUI", .T. )

Return oModel

//-------------------------------------------------------
//Função viewDef
//-------------------------------------------------------

Static Function ViewDef()

Local oModel := FWLoadModel("GFEA103")
Local oView 
Local oStructGUI := FWFormStruct(2,"GUI")

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField( "GFEA103_GUP" , FWFormStruct(2,"GUP") ) 
oView:AddGrid( "GFEA103_GUI" , oStructGUI )

oView:CreateHorizontalBox( "MASTER" , 15 )
oView:CreateHorizontalBox( "DETAIL" , 85 )

oView:CreateFolder("IDFOLDER","DETAIL")
oView:AddSheet("IDFOLDER","IDSHEET01",STR0008) //"Faixas"

oView:CreateHorizontalBox( "DETAILFAI"  , 100,,,"IDFOLDER","IDSHEET01" )
oStructGUI:RemoveField("GUI_INIVAL") 

oView:SetOwnerView( "GFEA103_GUP" , "MASTER" )
oView:SetOwnerView( "GFEA103_GUI" , "DETAILFAI" )      

oView:AddIncrementField("GFEA103_GUI","GUI_SEQ")


Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA100PS

Validações de quando é confirmado a inclusão do registro (bPost)

@author Jorge Matos Valcanaia
@since 23/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA100PS(oModel)     
Local lRet      := .T.
local nOpc      := (oModel:GetOperation())

	DbSelectArea('GUP')
	Chkfile( 'GUP',,'GUPBF')

	If nOpc == 3 .Or. nOpc == 4 
		if !empty(FwFldGet("GUP_FINVAL"))                                                                                                  
			If FwFldGet("GUP_INIVAL") > FwFldGet("GUP_FINVAL")                                                                                               
				Help( ,, 'HELP',, STR0009, 1, 0) //"Data Inicial da Validade deve ser menor que a Data final da Validade."
				lRet := .F.
			Endif
		endif	
		If FwFldGet("GUI_BAIRIN") > FwFldGet("GUI_BAIRFN") 
		    Help( ,, 'HELP',, STR0010, 1, 0) //"Base Cálculo inicial deve ser menor que a Base de Cálculo final."
		    lRet := .F.                                                                                                                                  		    
		Endif
	Endif   
	
	If nOpc == 3 
		DbSelectArea('GUPBF')
		DbSetOrder(01)
		If DbSeek(xFilial('GUP')+DtoS(FwFldGet("GUP_INIVAL")))  
			Help( ,, 'HELP',, STR0011, 1, 0) //"Já existe registro com a Data Inicial da Validade informada"
		    lRet := .F. 
		EndIf
	EndIf
	
	GUPBF->( dbCloseArea() )
	
Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} GFE103BW

Validações de quando é confirmado a inclusão do registro no grid(bLinePost)

@author Felipe Rafael Mendes
@since 23/04/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFE103BW(oModel)      
Local lRet := .T.
Local aSaveLines := FWSaveRows()
Local nLine := oModel:getLine(), nCont
Local nGUI_BAIRIN := FwFldGet("GUI_BAIRIN",nLine), nGUI_BAIRFN := FwFldGet("GUI_BAIRFN",nLine)

//A Base Calculo Inicial deve ser menor que Base Calculo Final.
If nGUI_BAIRIN >= nGUI_BAIRFN  .And. nGUI_BAIRIN > 0
    Help( ,, 'HELP',, STR0012, 1, 0) //"A Base Cálculo Inicial deve ser menor que Base cálculo Final."
    lRet := .F. 
EndIf
//A Base cálculo Inicial deve ser maior que zero
If nGUI_BAIRIN < 0 
    Help( ,, 'HELP',, STR0013, 1, 0) //"A Base Cálculo Inicial deve ser maior que zero ou igual a zero"
    lRet := .F. 
EndIf
//A Base cálculo Final deve ser maior que zero.
If nGUI_BAIRFN <= 0
    Help( ,, 'HELP',, STR0014, 1, 0) //"A Base Cálculo Final deve ser maior que zero."
    lRet := .F. 
EndIf


//Verifica a integridade do registro ( menor que o posterior e maior que o anterior) 
For nCont := 1 To oModel:GetQtdLine() 
	oModel:GoLine(nCont) 
	
	If nGUI_BAIRIN <= FwFldGet("GUI_BAIRFN",nCont) .And. nCont == nLine - 1 .And. nLine != 1
	    Help( ,, 'HELP',, STR0015 + STR(FwFldGet("GUI_BAIRFN",nCont)) + ".", 1, 0) //"A Base Cálculo Inicial deve ser maior que "
	    lRet := .F. 
	EndIf 
	
	If nGUI_BAIRFN >= FwFldGet("GUI_BAIRIN",nCont) .And. nCont == nLine + 1 .And. nLine != oModel:GetQtdLine()
	    Help( ,, 'HELP',, STR0016 + STR(FwFldGet("GUI_BAIRIN",nCont)) + ".", 1, 0) //"A Base Cálculo Final deve ser menor que "
	    lRet := .F. 
	EndIf

End 


FWRestRows( aSaveLines )

Return lRet