#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
//-------------------------------------------------------------------
//Inclusão Pátios 12.1.4
/*/{Protheus.doc} GFEA520

Visualização de Endereços

@author Alexandre José Cuchi
@since 06/05/2014
@version 1.0
/*/
Function GFEC517()
	Local oBrowse 
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GVD")
	oBrowse:SetMenuDef("GFEC517")
	oBrowse:SetDescription("Cadastro de Endereços de Mercadorias")
	oBrowse:Activate()	
Return

Static Function MenuDef()
	Local aRotina := {}
	Local aTitle  := {"Pesquisar","Visualizar","Imprimir"}
	
	ADD OPTION aRotina TITLE aTitle[1] ACTION "AxPesqui"        OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE aTitle[2] ACTION "VIEWDEF.GFEC517" OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE aTitle[3] ACTION "VIEWDEF.GFEC517" OPERATION 8 ACCESS 0 //"Imprimir"
Return aRotina

Static Function ModelDef()
	Local oModel
	Local oStructGVD := FWFormStruct(1,"GVD")
	Local oStructGVK := FWFormStruct(1,"GVK")
	
	oModel := MPFormModel():New("GFEC517_")
	oModel:AddFields("GFEC517_GVD", Nil, oStructGVD)
	oModel:SetPrimaryKey({"GVD_FILIAL", "GVD_CDOPER"})
	oModel:AddGrid("GFEC517_GVK","GFEC517_GVD", oStructGVK,/*bLinePre*/)
	oModel:setRelation("GFEC517_GVK",{{"GVK_FILIAL",'xFilial("GVK")'},{"GVK_CDENDE","GVD_CDENDE"}},"GVK_FILIAL+GVK_CDENDE")
	oModel:SetPrimaryKey({"GVD_FILIAL", "GVD_CDENDE"})
	oModel:GetModel("GFEC517_GVK"):SetDelAllLine(.T.)
Return oModel

Static Function ViewDef()
	Local oView
	Local oModel 		:= FWLoadModel("GFEC517")
	Local oStructGVD	:= FWFormStruct(2,"GVD")
	Local oStructGVK	:= FWFormStruct(2,"GVK")
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	oStructGVD:SetProperty("GVD_IDOCUP", MVC_VIEW_CANCHANGE, .T.) 	
	oStructGVD:SetProperty("GVD_CDENDE", MVC_VIEW_CANCHANGE, .F.) 
	oStructGVD:SetProperty("GVD_DSENDE", MVC_VIEW_CANCHANGE, .F.) 
	oStructGVD:SetProperty("GVD_SIT"   , MVC_VIEW_CANCHANGE, .F.) 
	oStructGVD:SetProperty("GVD_DTSIT" , MVC_VIEW_CANCHANGE, .F.) 
	oStructGVD:SetProperty("GVD_HRSIT" , MVC_VIEW_CANCHANGE, .F.) 
	oStructGVD:SetProperty("GVD_SENTID", MVC_VIEW_CANCHANGE, .F.) 
	oStructGVK:RemoveField("GVK_CDENDE")

	oView:AddField("GFEC517_GVD", oStructGVD)
	oView:AddGrid("GFEC517_GVK" , oStructGVK)
	oView:AddIncrementField("GFEC517_GVK","GVK_SEQ")
	
	oView:CreateHorizontalBox("MASTER",50)
	oView:CreateHorizontalBox("DETAIL",50)
	oView:CreateFolder("IDFOLDER","DETAIL")
	oView:AddSheet("IDFOLDER","IDSHEET01","Fila")
	oView:CreateHorizontalBox("DETAILPO",100,,,"IDFOLDER","IDSHEET01")
	
	oView:SetOwnerView("GFEC517_GVD","MASTER")
	oView:SetOwnerView("GFEC517_GVK","DETAILPO")
Return oView 
