#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//--------------------------------------------------------------------------------------------------- 
/*/{Protheus.doc} GFEC050
Consultar Requisições de Negociação de Frete
Generico

@sample
GFEC059()

@author Leandro Conradi Zmovirzynski    
@since 11/05/2018
@version 1.0                                                                                      
/*/
//------------------------------------------------------------------------------------------------

Function GFEC059()
    Local oBrowse := Nil

	oBrowse := FWMBrowse():New()
	oBrowse:setAlias("GXR")
	oBrowse:setMenuDef("GFEC059")
	oBrowse:setDescription("Consulta de Requisição de Negociação de Frete")
	
	oBrowse:AddLegend("GXR_SIT=='1'", "WHITE", "Em Edição") //"Em Edição"
	oBrowse:AddLegend("GXR_SIT=='2'", "BLUE", "Requisitada") //"Requisitada"
	oBrowse:AddLegend("GXR_SIT=='3'", "YELLOW", "Em Negociação") //"Em Negociação"
	oBrowse:AddLegend("GXR_SIT=='4'", "GREEN", "Atendida") //"Atendida"
	oBrowse:AddLegend("GXR_SIT=='5'", "RED", "Cancelada") //"Cancelada"
	

	
	oBrowse:Activate()
    
Return Nil  


//------------------------------------------------------------------------------
// Função MenuDef
//------------------------------------------------------------------------------

Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE "Pesquisar"      ACTION "AxPesqui"			OPERATION 1 ACCESS 0 	//"Pesquisar"
	ADD OPTION aRotina TITLE "Visualizar"	  	ACTION "VIEWDEF.GFEC059"	OPERATION 2 ACCESS 0 	//"Visualizar"
	ADD OPTION aRotina TITLE "Imprimir"       ACTION "VIEWDEF.GFEC059"  OPERATION 8 ACCESS 0   //"Imprimir"
	
Return aRotina

//------------------------------------------------------------------------------
// Função ModelDef
//------------------------------------------------------------------------------
Static Function ModelDef()
    Local oModel   := MPFormModel():New('GFEC059', /*bPreValid*/ , /*pValid*/ , /*bComValid*/ ,/*bCancel*/ )
    Local oStruGXR := FWFormStruct(1,'GXR')

    oModel:AddFields('GFEC059_GXR', /*cOwner*/, oStruGXR)
	
	oModel:SetPrimaryKey({"GXR_FILIAL", "GXR_IDREQ"})  
	
	oModel:AddGrid("GFEC059_GXS", "GFEC059_GXR",FWFormStruct(1,'GXS'))                           
	oModel:SetRelation("GFEC059_GXS",{{"GXS_FILIAL","GXR_FILIAL"} ,{"GXS_IDREQ","GXR_IDREQ"}},"GXS_FILIAL+GXS_IDREQ")
	
	oModel:AddGrid("GFEC059_GXW", "GFEC059_GXR",FWFormStruct(1,'GXW'))                           
	oModel:SetRelation("GFEC059_GXW",{{"GXW_FILIAL","GXR_FILIAL"} ,{"GXW_IDREQ","GXR_IDREQ"}},"GXW_FILIAL+GXW_IDREQ")

	If(IsInCallStack("GFEA059")) 
		oModel:GetModel( 'GFEC059_GXS' ):SetLoadFilter( { { 'GXS_MRKBR', "'T'" } } ) 
	EndIf
	
	oModel:SetActivate()

Return oModel

//------------------------------------------------------------------------------
// Função ViewDef 
//------------------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel('GFEC059')
	Local oView    := FWFormView():New()
	Local oStruGXR := FWFormStruct(2,'GXR')
	Local oStruGXS := FWFormStruct(2,'GXS')
	Local oStruGXW := FWFormStruct(2,'GXW')
	
	oView:SetModel(oModel)
	oView:AddField('GFEC059_GXR', oStruGXR, /**/ )
	oView:AddGrid('GFEC059_GXS',  oStruGXS)
	oView:AddGrid('GFEC059_GXW',  oStruGXW)
	 
	oStruGXS:RemoveField("GXS_IDREQ")
	oStruGXW:RemoveField("GXW_IDREQ")
	 
	oView:createHorizontalBox("MASTER", 70)
	oView:createHorizontalBox("DETAIL", 30)

	oView:CreateFolder('DETAIL_FOLDER', 'DETAIL')
	oView:AddSheet('DETAIL_FOLDER','ABA_GXS','Cotações de Frete')
	oView:AddSheet('DETAIL_FOLDER','ABA_GXW','Comentários')
	
	oView:CreateHorizontalBox( 'BOX_GXS', 100, , , 'DETAIL_FOLDER', 'ABA_GXS')
	oView:CreateHorizontalBox( 'BOX_GXW', 100, , , 'DETAIL_FOLDER', 'ABA_GXW')

	oView:SetOwnerView("GFEC059_GXR","MASTER")
	oView:SetOwnerView("GFEC059_GXS","BOX_GXS")
	oView:SetOwnerView("GFEC059_GXW","BOX_GXW")

Return oView