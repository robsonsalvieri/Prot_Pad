#INCLUDE "GFEA515.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
//Inclusão Pátios 12.1.4
/*/{Protheus.doc} GFEA515

Cadastro de Ponto de Controle

@author Jorge Matos Valcanaia
@since 07/09/2010
@version 1.0
/*/
//-------------------------------------------------------------------
//------------------------------------------------------------------- 

Function GFEA515()
	Local oBrowse          

	If !GFECheckGX4()
		Return .F.
	EndIF

	If !GFEA510COMP()
		MsgStop( "Necessário aplicar o update U_GFE11I20 para utilizar o processo de pátios e portarias." )
		Return .F.
	EndIf

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GVF")				// Alias da tabela utilizada
	oBrowse:SetMenuDef("GFEA515")		// Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription(STR0010) //"Ponto de Controle"
	oBrowse:Activate()
Return(Nil)

//-------------------------------------------------------------------  

Static Function MenuDef()
	Local aRotina := {}
	//-------------------------------------------------------
	// Adiciona botões do browse
	//-------------------------------------------------------
	ADD OPTION aRotina TITLE STR0001 ACTION "AxPesqui"        OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.GFEA515" OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.GFEA515" OPERATION 3 ACCESS 0
	// Utilizado desta forma, pois cadastro com filhos, ao alterar e clicar em confirmar... se estiver algum filho cadastrado,
	// ao invés de deixar os registros, faraá igual em inclusão, limpando todos os campos.
	// Desta forma abaixo, sai da tela de ALTERACAO
	ADD OPTION aRotina TITLE STR0004 ACTION "FwExecView('Alterar','GFEA515',4,,{||.T.})" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.GFEA515" OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.GFEA515" OPERATION 8 ACCESS 0
	
	ADD OPTION aRotina TITLE "Copiar" ACTION "VIEWDEF.GFEA515"  	OPERATION 9  ACCESS 0  	//"Copiar"
	
Return aRotina

//-------------------------------------------------------------------

Static Function ModelDef()
Local oModel                      	
Local oStructGVF := FWFormStruct(1,"GVF")
Local oStructGVH := FWFormStruct(1,"GVH") 
Local oStructGVP := FWFormStruct(1,"GVP") 

oStructGVH:SetProperty("GVH_CDPTCT", MODEL_FIELD_INIT, {|a,b,c| FWInitCpo(a,b,c),lRetorno:=(IF((INCLUI.Or.ALTERA).AND.Vazio(),'0',M->GVH_CDPTCT)),FWCloseCpo(a,b,c,.t.),lRetorno }) 

// cID     Identificador do modelo
// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
// bPost   Code-Block de validação do formulário de edição
// bCommit Code-Block de persistência do formulário de edição
// bCancel Code-Block de cancelamento do formulário de edição
oModel := MPFormModel():New("GFEA515", /*bPre*/, {|oMod| GFEA515INC(oMod)},/*bPost*/, /*bCommit*/, /*bCancel*/)

// cId          Identificador do modelo
// cOwner       Identificador superior do modelo
// oModelStruct Objeto com  a estrutura de dados
// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
// bPost        Code-Block de validação do formulário de edição
// bLoad        Code-Block de carga dos dados do formulário de edição

oStructGVF:SetProperty("GVF_CDPTCT",MODEL_FIELD_WHEN,{|| !ALTERA })
oModel:AddFields("GFEA515_GVF", Nil, oStructGVF,/*bPre*/,,/*bLoad*/)
	
oModel:AddGrid("GFEA515_GVH","GFEA515_GVF",oStructGVH,/*bLinePre*/,{|oMod| GFEA515LPO(oMod)},/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetRelation("GFEA515_GVH",{{"GVH_FILIAL",'xFilial("GVH")'},{"GVH_CDPTCT","GVF_CDPTCT"}},"GVH_FILIAL+GVH_CDPTCT")
oModel:SetPrimaryKey({"GVF_FILIAL", "GVF_CDPTCT"})
//oModel:GetModel("GFEA515_GVH"):SetDelAllLine(.T.) 

oModel:AddGrid("GFEA515_GVP","GFEA515_GVF",oStructGVP,/*bLinePre*/,{|oMod| GFEA515GVP(oMod)},/*bPre*/,/*bPost*/,/*bLoad*/)
If GFXCP12123("GVP_GRPUSU")
	oModel:SetRelation("GFEA515_GVP",{{"GVP_FILIAL",'xFilial("GVP")'},{"GVP_CDPTCT","GVF_CDPTCT"}},"GVP_FILIAL+GVP_CDUSUR+GVP_GRPUSU+GVP_CDPTCT")
Else
	oModel:SetRelation("GFEA515_GVP",{{"GVP_FILIAL",'xFilial("GVP")'},{"GVP_CDPTCT","GVF_CDPTCT"}},"GVP_FILIAL+GVP_CDUSUR+GVP_CDPTCT")
EndIf

oModel:GetModel("GFEA515_GVH"):SetOptional( .T. )
oModel:GetModel("GFEA515_GVP"):SetOptional( .T. )

Return oModel

//-------------------------------------------------------------------            

Static Function ViewDef()
	Local oModel := FWLoadModel("GFEA515")
	Local oView  := Nil
	Local oStructGVF := FWFormStruct(2,"GVF")
	Local oStructGVH := FWFormStruct(2,"GVH")
	Local oStructGVP := FWFormStruct(2,"GVP")
	
	oStructGVH:RemoveField("GVH_FILIAL")
	oStructGVH:RemoveField("GVH_CDPTCT")
	oStructGVH:RemoveField("GVH_DSPTCT")
	
	oStructGVP:RemoveField("GVP_CDPTCT")
	oStructGVP:RemoveField("GVP_DSPTCT")

	oView := FWFormView():New()
	// Objeto do model a se associar a view.
	oView:SetModel(oModel)
	// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
	// oStruct - Objeto do model a se associar a view.
	// cLinkID - Representa o ID criado no Model ,Só é necessári o caso estamos mundando o ID no View.
	oView:AddField( "GFEA515_GVF" , oStructGVF, /*cLinkID*/ )	//    
	oView:AddGrid( "GFEA515_GVH" , oStructGVH )	
	oView:AddGrid( "GFEA515_GVP" , oStructGVP )
	
	// cID		  	Id do Box a ser utilizado 
	// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. é a qtd de pixel exato)
	// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas criações uma dentro da outra.
	// lFixPixel	Determina que o valor passado no nPercHeight é na verdade a qtd de pixel a ser usada.
	// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, é necessário informar o cIDSheet
	// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
	
	oView:CreateHorizontalBox( "MASTER" , 60 )
	oView:CreateHorizontalBox( "DETAIL" , 40 )
	
	oView:CreateFolder("IDFOLDER","DETAIL")
	oView:AddSheet("IDFOLDER","IDSHEET01", STR0011) //"Perguntas"
	oView:AddSheet("IDFOLDER","IDSHEET02", STR0012) //"Usuários"
	
	oView:CreateHorizontalBox( "DETAILPER"  , 100,,,"IDFOLDER","IDSHEET01" )
	oView:CreateHorizontalBox( "DETAILUSU"  , 100,,,"IDFOLDER","IDSHEET02" )
	
	// Associa um View a um box
	oView:SetOwnerView( "GFEA515_GVF" , "MASTER"    )    
	oView:SetOwnerView( "GFEA515_GVH" , "DETAILPER" )
	oView:SetOwnerView( "GFEA515_GVP" , "DETAILUSU" )
		
Return oView

//-------------------------------------------------------

Static Function GFEA515INC(oMod)
Local oModGVH := oMod:GetModel("GFEA515_GVH")
Local oModGVP := oMod:GetModel("GFEA515_GVP")
Local nQtd := oModGVH:GetQtdLine()
Local nQtUsu := oModGVP:GetQtdLine()
Local lRecs := .F. 
Local LRecUsu := .F.
Local nLine                          

// Validação para perguntas
If nQtd > 0 .And. oMod:GetOperation() != MODEL_OPERATION_DELETE
	
	For nLine := 1 To nQtd
		oModGVH:GoLine(nLine)
		If !oModGVH:IsDeleted() .And. !Empty(FwFldGet("GVH_CDPERG",1)) .And. !lRecs
			lRecs := .T. 
		EndIf
	Next nLine
	
	If FwFldGet("GVF_IDPERG") == "1"
		If !lRecs
			Help(,, "Help",, STR0007, 1, 0) //"O campo Vincula Perg está como 'Sim', deve haver perguntas vinculadas ao ponto de controle."
			Return .F.
		EndIf
	ElseIf FwFldGet("GVF_IDPERG") == "2"
		If lRecs
			Help(,, "Help",, STR0008, 1, 0) //"O campo Vincula Perg está como 'Não', não poderá haver perguntas vinculadas ao ponto de controle."
			Return .F.
		EndIf
	EndIf
	
	For nLine := 1 To nQtd
		oModGVH:GoLine(nLine)
		If !Empty(FwFldGet("GVH_CDPERG",1)) .And. Empty(FwFldGet("GVH_CDPTCT"))
			oModGVH:SetValue("GVH_CDPTCT",FwFldGet("GVF_CDPTCT"))
		EndIf
	Next nLine
	
EndIf

// Validação para Usuarios
If nQtUsu > 0 .And. oMod:GetOperation() != MODEL_OPERATION_DELETE

	For nLine := 1 To nQtUsu
		oModGVP:GoLine(nLine)
		If GFXCP12123("GVP_GRPUSU")
			If !oModGVP:IsDeleted() .And. !LRecUsu .And. (!Empty(FwFldGet("GVP_CDUSUR",nLine)) .Or. !Empty(FwFldGet("GVP_GRPUSU",nLine)))
				LRecUsu := .T. 
			EndIf
		Else
			If !oModGVP:IsDeleted() .And. !LRecUsu .And. !Empty(FwFldGet("GVP_CDUSUR",nLine)) 
				LRecUsu := .T. 
			EndIf
		EndIf
	Next nLine	
	
	If FwFldGet("GVF_IDEMIT") == "1"
		If !LRecUsu
			Help(,, "Help",, "O campo Vincula Pessoa está como 'Sim', deve haver usuários vinculados ao ponto de controle.", 1, 0) //"O campo Vincula Pessoa está como 'Sim', deve haver pessoas vinculadas ao ponto de controle."
			Return .F.
		EndIf
	ElseIf FwFldGet("GVF_IDEMIT") == "2"
		If LRecUsu
			Help(,, "Help",, "O campo Vincula Pessoa está como 'Não', não poderá haver pessoas vinculadas ao ponto de controle.", 1, 0) //"O campo Vincula Pessoa está como 'Não', não poderá haver pessoas vinculadas ao ponto de controle."
			Return .F.
		EndIf
	EndIf
	
	For nLine := 1 To nQtUsu
		oModGVP:GoLine(nLine)
		//Validação para que não tenha usuário e grupo preenchidos na mesma linha do Model.
		If !oModGVP:IsDeleted() .And. !Empty(FwFldGet("GVP_CDUSUR",nLine)) .And. (GFXCP12123("GVP_GRPUSU") .And. !Empty(FwFldGet("GVP_GRPUSU",nLine)))
			Help(,, "Help",, "Deve ser informado na linha apenas o Usuário ou o Grupo.", 1, 0) //"Deve ser informado na linha apenas o Usuário ou o Grupo."
			Return .F.
		EndIf 
	Next nLine
		
EndIf

	If FwFldGet("GVF_IDENDE") == "2" .And. FwFldGet("GVF_IDFILA") == "1"
		Help(,,'HELP',,"Não é possível colocar a situação 'Em Fila' sem antes colocar a situação 'Endereçado'",1,0)
		Return .F.
	EndIf 
Return .T.                                                      

//--------------------------------------------------------

Static Function GFEA515LPO(oModGVH)
Local nRow := oModGVH:GetLine()
Local nQtd := oModGVH:Length()
Local nLine

For nLine := 1 To nQtd
	If nRow != nLine
		oModGVH:GoLine(nLine)
		If !oModGVH:IsDeleted()
			If FwFldGet("GVH_CDPERG",nRow) == FwFldGet("GVH_CDPERG",nLine)
				oModGVH:GoLine(nRow)
				Help(,, "Help",, StrTran(StrTran(STR0009,"[reg1]",If(nLine>nRow,AllTrim(Str(nRow)),AllTrim(Str(nLine)))),"[reg2]",If(nLine>nRow,AllTrim(Str(nLine)),AllTrim(Str(nRow)))), 1, 0)
				Return .F.
			EndIf
		EndIf
	EndIf
Next nLine 

oModGVH:GoLine(nRow)

Return .T.

//------------------------------------------------------

Static Function GFEA515GVP(oModelGVP)
	Local nLine := oModelGVP:GetLine()   
	Local nI
	
	For nI := 1 To oModelGVP:Length()
		If nLine != nI
			oModelGVP:GoLine(nI)
			If !Empty(FwFldGet("GVP_CDUSUR", nLine)) .And. !Empty(FwFldGet("GVP_CDUSUR", nI)) .And.;
			   FwFldGet("GVP_CDUSUR", nLine) == FwFldGet("GVP_CDUSUR", nI) .And. !oModelGVP:IsDeleted()
				oModelGVP:GoLine(nLine)
				Help(,, "Help",, STR0013 + AllTrim(Str(nI)) + ".", 1, 0) //"O usuário já foi informado na linha "
				Return .F.
			ElseIf GFXCP12123("GVP_GRPUSU") .And. !Empty(FwFldGet("GVP_GRPUSU", nLine)) .And. !Empty(FwFldGet("GVP_GRPUSU", nI)) .And.;
			   FwFldGet("GVP_GRPUSU", nLine) == FwFldGet("GVP_GRPUSU", nI) .And. !oModelGVP:IsDeleted()
				oModelGVP:GoLine(nLine)
				Help(,, "Help",, "O Grupo de Usuário já foi informado na linha" + AllTrim(Str(nI)) + ".", 1, 0) //"O usuário já foi informado na linha "
				Return .F.
			EndIf
		EndIf	
	Next nI
	
	oModelGVP:GoLine(nLine)

Return .T.

/* --------------------------------- */
