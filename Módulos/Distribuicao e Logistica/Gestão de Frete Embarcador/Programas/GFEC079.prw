#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
//--------------------------------------------------------------------------------------------------- 
/*/{Protheus.doc} GFEC079
Contrato Transporte
Generico

@author Gabriela Lima
@since 12/11/18
@version 1.0                                                                                      
/*/
//------------------------------------------------------------------------------------------------
 
Function GFEC079()
Local oBrowse := Nil
Private aRotina := MenuDef()

oBrowse := FWMBrowse():New()
oBrowse:setAlias("GXT")
oBrowse:setMenuDef("GFEC079")
oBrowse:setDescription("Contratos de Transporte")

oBrowse:AddLegend("GXT_SIT=='1'", "WHITE" ,'Criado')    // Criado
oBrowse:AddLegend("GXT_SIT=='2'", "YELLOW",'Emitido')   // Emitido
oBrowse:AddLegend("GXT_SIT=='3'", "GRAY"  ,'Enviado') 	// Enviado
oBrowse:AddLegend("GXT_SIT=='4'", "BLUE"  ,'Confirmado')// Confirmado
oBrowse:AddLegend("GXT_SIT=='5'", "ORANGE",'Encerrado') // Encerrado
oBrowse:AddLegend("GXT_SIT=='6'", "RED"   ,'Cancelado') // Cancelado

oBrowse:Activate()

Return Nil

//------------------------------------------------------------------------------
// Função MenuDef
//------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

	AAdd(aRotina,{"Pesquisar"   ,"AxPesqui"             , 0,  1 , 0, .T. /*Habilita Menu Funcional*/})
	AAdd(aRotina,{"Visualizar"  ,"VIEWDEF.GFEC079"      , 0,  2 , 0, .T. /*Habilita Menu Funcional*/})

Return aRotina                                                                                         

//------------------------------------------------------------------------------
// Função ModelDef
//------------------------------------------------------------------------------
Static Function ModelDef()
	Local oModel   
    Local oStruGXT := FWFormStruct(1,'GXT')
	Local oStruGXU := FWFormStruct(1,'GXU')
	Local oStruGXY := FWFormStruct(1,'GXY')
	Local oStruGXZ := FWFormStruct(1,'GXZ')
	Local oStruGVW := FWFormStruct(1,'GVW')
	
	oModel := MPFormModel():New("GFEC079", /* */, , /**/, /**/, /*bCancel*/)
	oModel:AddFields('GFEC079_GXT', Nil, oStruGXT)
	oModel:SetPrimaryKey({"GXT_FILIAL", "GXT_NRCT"})

	oModel:AddGrid("GFEC079_GXU", "GFEC079_GXT", oStruGXU)
	oModel:AddGrid("GFEC079_GXY", "GFEC079_GXT", oStruGXY)
	oModel:AddGrid("GFEC079_GXZ", "GFEC079_GXT", oStruGXZ)
	oModel:AddGrid("GFEC079_GVW", "GFEC079_GXT", oStruGVW)

	oModel:SetRelation("GFEC079_GXU",{{"GXU_FILIAL","xFilial('GXU')"} ,{"GXU_NRCT","GXT_NRCT"}},"GXU_FILIAL+GXU_NRCT")
	oModel:SetRelation("GFEC079_GXY",{{"GXY_FILIAL","xFilial('GXY')"} ,{"GXY_NRCT","GXT_NRCT"}},"GXY_FILIAL+GXY_NRCT")
	oModel:SetRelation("GFEC079_GXZ",{{"GXZ_FILIAL","xFilial('GXZ')"} ,{"GXZ_NRCT","GXT_NRCT"}},"GXZ_FILIAL+GXZ_NRCT")
	oModel:SetRelation("GFEC079_GVW",{{"GVW_FILIAL","xFilial('GVW')"} ,{"GVW_NRCT","GXT_NRCT"}},"GVW_FILIAL+GVW_NRCT")
	oModel:SetActivate()
	
Return oModel

//------------------------------------------------------------------------------
// Função ViewDef
//------------------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel('GFEC079')
	Local oView    := FWFormView():New()
	Local oStruGXT := FWFormStruct(2,'GXT')
	Local oStruGXU := FWFormStruct(2,'GXU')
	Local oStruGXY := FWFormStruct(2,'GXY')
	Local oStruGXZ := FWFormStruct(2,'GXZ')
	Local oStruGVW := FWFormStruct(2,'GVW')
	
	oView:SetModel(oModel)
	oView:AddField('GFEC079_GXT', oStruGXT)
	oView:AddGrid('GFEC079_GXU', oStruGXU) // Rotas
	oView:AddGrid('GFEC079_GXY', oStruGXY) // Cálculo
    oView:AddGrid('GFEC079_GXZ', oStruGXZ) // Documento de Frete
    oView:AddGrid('GFEC079_GVW', oStruGVW) // Contrato x Tabela de Frete

	oView:createHorizontalBox("MASTER", 60)
	oView:createHorizontalBox("DETAIL", 40)
	
	//Criando a folder dos filhos
    oView:CreateFolder('PASTA_GRID', 'DETAIL')
    oView:AddSheet('PASTA_GRID', 'ABA_GXU', "Rotas")
    oView:AddSheet('PASTA_GRID', 'ABA_GXY', "Cálculo")
    oView:AddSheet('PASTA_GRID', 'ABA_GXZ', "Documento de Frete")
    oView:AddSheet('PASTA_GRID', 'ABA_GVW', "Contrato x Tabela de Frete")

	//Criando os vinculos onde serão mostrado os dados
	oView:CreateHorizontalBox('ITENS_GXU', 100,,, 'PASTA_GRID', 'ABA_GXU' )
    oView:CreateHorizontalBox('ITENS_GXY', 100,,, 'PASTA_GRID', 'ABA_GXY' )
    oView:CreateHorizontalBox('ITENS_GXZ', 100,,, 'PASTA_GRID', 'ABA_GXZ' )
    oView:CreateHorizontalBox('ITENS_GVW', 100,,, 'PASTA_GRID', 'ABA_GVW' )
	
	oView:SetOwnerView("GFEC079_GXT","MASTER")
	oView:SetOwnerView("GFEC079_GXU","ITENS_GXU")
    oView:SetOwnerView("GFEC079_GXY","ITENS_GXY")
    oView:SetOwnerView("GFEC079_GXZ","ITENS_GXZ")
    oView:SetOwnerView("GFEC079_GVW","ITENS_GVW")

	oStruGXT:RemoveField("GXT_FILIAL")
	oStruGXU:RemoveField("GXU_FILIAL")
	oStruGXU:RemoveField("GXU_NRCT")
    oStruGXY:RemoveField("GXY_FILIAL")
    oStruGXY:RemoveField("GXY_NRCT")
    oStruGXZ:RemoveField("GXZ_FILIAL")
    oStruGXZ:RemoveField("GXZ_NRCT")
    oStruGVW:RemoveField("GVW_FILIAL")
    oStruGVW:RemoveField("GVW_CDEMIT")
    oStruGVW:RemoveField("GVW_NMEMIT")
    oStruGVW:RemoveField("GVW_FILGXT")
    oStruGVW:RemoveField("GVW_NRCT")
	
	oView:AddIncrementField("GFEC079_GXU","GXU_SEQ") 
		
Return oView

//-------------------------------------------------------------------
