#INCLUDE "GFEA092.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA092

Grupos Contábeis X Contas Contábeis

@author Jorge Matos Valcanaia
@since 15/11/09
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFEA092()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("GUF")										        // Alias da tabela utilizada
oBrowse:SetMenuDef("GFEA092")				  			            // Nome do fonte onde esta a função MenuDef
oBrowse:SetDescription(STR0001)	    // Descrição do browse //"Grupos Contábeis X Contas Contábeis"
oBrowse:Activate()                                       

Return(Nil)

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
//-------------------------------------------------------------------
// Adiciona botões do browse
//-------------------------------------------------------------------
ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"        OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.GFEA092" OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.GFEA092" OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.GFEA092" OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0006 ACTION "GFEA92VAL"       OPERATION 9 ACCESS 0 //"Excluir"
ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.GFEA092" OPERATION 8 ACCESS 0   //"Imprimir"

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel

Local oStructGUF := FWFormStruct(1,"GUF")

// cID     Identificador do modelo 
// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
// bPost   Code-Block de validação do formulário de edição
// bCommit Code-Block de persistência do formulário de edição
// bCancel Code-Block de cancelamento do formulário de edição
oModel := MPFormModel():New("GFEA092", /*bPre*/, { |oX| GFE092POS( oX ) }/*bPost*/, /*bCommit*/, /*bCancel*/)
// cId          Identificador do modelo
// cOwner       Identificador superior do modelo
// oModelStruct Objeto com  a estrutura de dados
// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
// bPost        Code-Block de validação do formulário de edição
// bLoad        Code-Block de carga dos dados do formulário de edição
oModel:AddFields("GFEA092_GUF", Nil, oStructGUF,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetPrimaryKey({"GUF_FILIAL"},{"GUF_GRP1"},{"GUR_GRP2"},{"GUR_GRP3"},{"GUR_GRP4"},{"GUR_GRP5"},{"GUR_GRP6"},{"GUR_GRP7"})


Return oModel

Static Function ViewDef()

Local oModel := FWLoadModel("GFEA092")
Local oView  := Nil
Local oStructGUF
Local aOpGrp	:= {"Nenhum","Filial","Tipo Operação","Item","Reg Comecial","Grupo Emitente","Tipo Doc Carga","Classificação Frete","Tipo de Frete","Info Ctb 1","Info Ctb 2","Info Ctb 3","Info Ctb 4","Info Ctb 5","Representante", "Unidade de Negócio","CFOP Item Doc Carga","Tipo de Serviço","Grupo de Transportador","Série Doc Carga"}

oView := FWFormView():New()
// Objeto do model a se associar a view.
oStructGUF := FWFormStruct(2,"GUF")

oStructGUF:AddGroup("GrpGeral", "Geral", "1", 2)
oStructGUF:AddGroup("GrpReal", "Realização", "1", 2)

If GFEVerCmpo({"GUF_CTPROV"})
	oStructGUF:AddGroup("GrpProv" , "Provisão", "1", 2)
EndIf

oStructGUF:SetProperty("GUF_GRP1", MVC_VIEW_TITULO , aOpGrp[ ( Val( SuperGetMv( "MV_TPGRP1" ,.F.,"0")) + 1)])
oStructGUF:SetProperty("GUF_GRP2", MVC_VIEW_TITULO , aOpGrp[ ( Val( SuperGetMv( "MV_TPGRP2" ,.F.,"0")) + 1)])
oStructGUF:SetProperty("GUF_GRP3", MVC_VIEW_TITULO , aOpGrp[ ( Val( SuperGetMv( "MV_TPGRP3" ,.F.,"0")) + 1)])
oStructGUF:SetProperty("GUF_GRP4", MVC_VIEW_TITULO , aOpGrp[ ( Val( SuperGetMv( "MV_TPGRP4" ,.F.,"0")) + 1)])
oStructGUF:SetProperty("GUF_GRP5", MVC_VIEW_TITULO , aOpGrp[ ( Val( SuperGetMv( "MV_TPGRP5" ,.F.,"0")) + 1)])
oStructGUF:SetProperty("GUF_GRP6", MVC_VIEW_TITULO , aOpGrp[ ( Val( SuperGetMv( "MV_TPGRP6" ,.F.,"0")) + 1)])
oStructGUF:SetProperty("GUF_GRP7", MVC_VIEW_TITULO , aOpGrp[ ( Val( SuperGetMv( "MV_TPGRP7" ,.F.,"0")) + 1)])

oStructGUF:SetProperty("GUF_GRP1", MVC_VIEW_GROUP_NUMBER, "GrpGeral")
oStructGUF:SetProperty("GUF_GRP2", MVC_VIEW_GROUP_NUMBER, "GrpGeral")
oStructGUF:SetProperty("GUF_GRP3", MVC_VIEW_GROUP_NUMBER, "GrpGeral")
oStructGUF:SetProperty("GUF_GRP4", MVC_VIEW_GROUP_NUMBER, "GrpGeral")
oStructGUF:SetProperty("GUF_GRP5", MVC_VIEW_GROUP_NUMBER, "GrpGeral")
oStructGUF:SetProperty("GUF_GRP6", MVC_VIEW_GROUP_NUMBER, "GrpGeral")
oStructGUF:SetProperty("GUF_GRP7", MVC_VIEW_GROUP_NUMBER, "GrpGeral")
oStructGUF:SetProperty("GUF_USO", MVC_VIEW_GROUP_NUMBER, "GrpGeral")

oStructGUF:SetProperty("GUF_CTFRET", MVC_VIEW_GROUP_NUMBER, "GrpReal")
oStructGUF:SetProperty("GUF_CCFRET", MVC_VIEW_GROUP_NUMBER, "GrpReal")
oStructGUF:SetProperty("GUF_DSCTFR", MVC_VIEW_GROUP_NUMBER, "GrpReal")
oStructGUF:SetProperty("GUF_DSCCFR", MVC_VIEW_GROUP_NUMBER, "GrpReal")

If GFEVerCmpo({"GUF_CTPROV"})
	oStructGUF:SetProperty("GUF_CTPROV", MVC_VIEW_GROUP_NUMBER, "GrpProv")
	oStructGUF:SetProperty("GUF_CCPROV", MVC_VIEW_GROUP_NUMBER, "GrpProv")
	oStructGUF:SetProperty("GUF_DSCTPR", MVC_VIEW_GROUP_NUMBER, "GrpProv")
	oStructGUF:SetProperty("GUF_DSCCPR", MVC_VIEW_GROUP_NUMBER, "GrpProv")
EndIf

oView:SetModel(oModel)
// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
// oStruct - Objeto do model a se associar a view.
// cLinkID - Representa o ID criado no Model ,Só é necessári o caso estamos mundando o ID no View.
oView:AddField( "GFEA092_GUF" , oStructGUF, /*cLinkID*/ )	//
// cID		  	Id do Box a ser utilizado 
// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. é a qtd de pixel exato)
// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas criações uma dentro da outra.
// lFixPixel	Determina que o valor passado no nPercHeight é na verdade a qtd de pixel a ser usada.
// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, é necessário informar o cIDSheet
// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
oView:CreateHorizontalBox( "MASTER" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
// Associa um View a um box
oView:SetOwnerView( "GFEA092_GUF" , "MASTER" )

Return oView 

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA92VAL

Executa uma mensagem em tela para que o usuario saiba que podera ocorrer erros em um futuro 
se a conta contabil por grupo for eliminado

@author Jorge Matos Valcanaia
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFEA92VAL(oModel) 

If msgyesno(STR0008)         //"Conta Contábeis para Grupos informados podem ter sido utilizadas, sua eliminação podem trazer problemas futuros por falta do grupo de contas."
	GFEA92DEL()
Endif

Return    

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA92DEL

Executa a funcao padrao do programa que é utilizada aqui por existir uma mensagem 
de alerta antes dela para o usuario GFEA92VAL

@author Jorge Matos Valcanaia
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFEA92DEL()
	FWExecView("",'GFEA092',5,,{||.T.})  		
return                                 


//-------------------------------------------------------------------
/*/{Protheus.doc} GFE092POS

Validação de Pós inclusão 

@author Felipe Rafael Mendes
@since 24/04/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFE092POS(oModel)
	Local nOpc     := oModel:GetOperation()
	Local cCentroC := FwFldGet("GUF_CCFRET")
	Local cContaC  := FwFldGet("GUF_CTFRET")
	Local cCProvF := FwFldGet("GUF_CCPROV")
	Local cCCProv  := FwFldGet("GUF_CTPROV")	

	If nOpc == MODEL_OPERATION_INSERT
		
	    DbSelectArea("GUF")	
		Chkfile( "GUF",,"GUFBF")
	    DbSelectArea("GUFBF")
	    DbSetOrder(01)
	    If dbSeek(xFilial("GUF") + oModel:GetValue('GFEA092_GUF','GUF_GRP1') + oModel:GetValue('GFEA092_GUF','GUF_GRP2') + ;
	                               oModel:GetValue('GFEA092_GUF','GUF_GRP3') + oModel:GetValue('GFEA092_GUF','GUF_GRP4') + ;
	                               oModel:GetValue('GFEA092_GUF','GUF_GRP5') + oModel:GetValue('GFEA092_GUF','GUF_GRP6') + ;
	                               oModel:GetValue('GFEA092_GUF','GUF_GRP7'))
	 		Help(,,'HELP',, STR0009,1,0) //"Já existe Grupo cadastrado com as chaves informadas."
	 		GUFBF->( dbCloseArea() )
			Return .F.
		EndIf
		GUFBF->( dbCloseArea() )
	EndIf

	If nOpc == MODEL_OPERATION_INSERT .Or. nOpc == MODEL_OPERATION_UPDATE
		
		If Empty(cContaC)
			Help(,,'HELP',, "É necessário informar uma Conta Contábil de Frete.",1,0) 
			Return .F.
		EndIf
		
		dbSelectArea("GUE")
		GUE->( dbSetOrder(1) )
		If GUE->( dbSeek(xFilial("GUE") + cContaC) )
			If GUE->GUE_SIT == "2"
				Help(,,'HELP',, "A Conta Contábil de Frete está inativa.",1,0) 
				Return .F.
			EndIf
		EndIf
		
		If !Empty(cCentroC)
			dbSelectArea("GUH")
			GUH->( dbSetOrder(1) )
			If GUH->( dbSeek(xFilial("GUH") + cCentroC) )
				If GUH->GUH_SIT == "2"
					Help(,,'HELP',, "O Centro de Custo de Frete está inativo.",1,0) 
					Return .F.
				EndIf
			EndIf
			
			dbSelectArea("GUM")
			GUM->( dbSetOrder(1) )
			If !GUM->( dbSeek(xFilial("GUM") + cCentroC + cContaC) )
				Help( ,, 'HELP',, "O Centro de Custo de Frete não possui relacionamento com a Conta Contábil no cadastro de Centro de Custo.", 1, 0) 
				Return .F.
			EndIf			
		EndIf
		
	EndIf

	If (nOpc == MODEL_OPERATION_INSERT .Or. nOpc == MODEL_OPERATION_UPDATE) .and. oModel:GetValue('GFEA092_GUF','GUF_USO') == "1"
		
		If Empty(cCCProv)
			Help(,,'HELP',, "É necessário informar uma Conta Contábil de Provisão.",1,0) 
			Return .F.
		EndIf
		
		dbSelectArea("GUE")
		GUE->( dbSetOrder(1) )
		If GUE->( dbSeek(xFilial("GUE") + cCCProv) )
			If GUE->GUE_SIT == "2"
				Help(,,'HELP',, "A Conta Contábil de Provisão está inativa.",1,0) 
				Return .F.
			EndIf
		EndIf
		
		If !Empty(cCProvF)
			dbSelectArea("GUH")
			GUH->( dbSetOrder(1) )
			If GUH->( dbSeek(xFilial("GUH") + cCProvF) )
				If GUH->GUH_SIT == "2"
					Help(,,'HELP',, "O Centro de Custo de Provisão está inativo.",1,0) 
					Return .F.
				EndIf
			EndIf
			
			dbSelectArea("GUM")
			GUM->( dbSetOrder(1) )
			If !GUM->( dbSeek(xFilial("GUM") + cCProvF + cCCProv) )
				Help( ,, 'HELP',, "O Centro de Custo de Provisão não possui relacionamento com a Conta Contábil no cadastro de Centro de Custo.", 1, 0) 
				Return .F.
			EndIf			
		EndIf
		
	EndIf

Return .T.

