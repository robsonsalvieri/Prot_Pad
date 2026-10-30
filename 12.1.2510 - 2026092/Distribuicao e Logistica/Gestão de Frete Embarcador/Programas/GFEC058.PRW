#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Function GFEC058() 
	Local oBrowse
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GWP")
	oBrowse:SetDescription("Viagens")
	oBrowse:SetMenuDef("GFEC058") 
	oBrowse:AddLegend("GWP_SIT == '1'", "GREEN" ,"Aberta")
	oBrowse:AddLegend("GWP_SIT == '2'", "RED"   ,"Encerrada")
	oBrowse:Activate()
	
Return

Static Function MenuDef()
	Private aRotina := {}
	
	ADD OPTION aRotina TITLE	   "Pesquisar"			ACTION "AxPesqui"        OPERATION  1 ACCESS 0
	ADD OPTION aRotina TITLE 	   "Visualizar"			ACTION "VIEWDEF.GFEC058" OPERATION  2 ACCESS 0
	ADD OPTION aRotina TITLE 	   "Imprimir"			ACTION "VIEWDEF.GFEC058" OPERATION  8 ACCESS 0
	
Return aRotina

Static Function ModelDef()
	Local oModel := MPFormModel():New("GFEC058", /*bPre*/, /*bPost*/, /*bCommit*/, /*bCancel*/)
	Local oStructGWP := FWFormStruct(1,"GWP")
	Local oStructGWN := FWFormStruct(1,"GWN")
	
	oModel:AddFields("GFEC058_GWP", Nil, oStructGWP,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:AddGrid("GFEC058_GWN","GFEC058_GWP", oStructGWN)
	oModel:SetRelation("GFEC058_GWN",{{"GWN_VIAGEM","GWP_VIAGEM"}},"GWN_FILIAL+GWN_NRROM")
	oModel:SetPrimaryKey({"GWP_FILIAL", "GWP_VIAGEM"})
	oModel:SetVldActivate({|oModel| GFEC58VLD(oModel)})
	
	oModel:SetDescription("Viagens")
	oModel:GetModel("GFEC058_GWP"):SetDescription("Viagens")
	oModel:GetModel("GFEC058_GWN"):SetDescription("Romaneios")

Return oModel

Static Function ViewDef()
	Local oModel := FWLoadModel("GFEC058")
	Local oView := Nil
	Local oStructGWP := FWFormStruct(2,"GWP")
	Local oStructGWN := FWFormStruct(2,"GWN")
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField( "GFEC058_GWP" , oStructGWP )
	oView:AddGrid(  "GFEC058_GWN" , oStructGWN )
	
	oStructGWN:RemoveField("GWN_VIAGEM")
	oStructGWN:AddField("GWN_FILIAL","01",'Filial','Filial',,"GET")
	
	oView:CreateHorizontalBox( "MASTER" , 55)
	oView:CreateHorizontalBox( "DETAIL" , 45)
	
	oView:CreateFolder("IDFOLDER","DETAIL")
	oView:AddSheet("IDFOLDER","IDSHEET01","Romaneios")
	
	oView:CreateHorizontalBox( "DETAIL_GWN"  , 100,,,"IDFOLDER","IDSHEET01" )
	
	oView:SetOwnerView( "GFEC058_GWP" , "MASTER" )
	oView:SetOwnerView( "GFEC058_GWN" , "DETAIL_GWN" )
	oView:AddUserButton("Cons. Romaneio"   , "MAGIC_BMP", {|oView| GFEC058ROM(oView)}, ) //""
	
Return oView

Function GFEC058ROM(oView)
	Local oModel    := oView:GetModel()
	Local oModelGWN := oModel:GetModel("GFEC058_GWN")
	Local nLine     := oModelGWN:GetLine()
	Local cFil      := FWFldGet("GWN_FILIAL", nLine)
	Local cNrRom    := FWFldGet("GWN_NRROM", nLine)
	Local cFilBkp   := cFilAnt
	cFilAnt := cFil
	dbSelectArea("GWN")
	GWN->( dbSetOrder(1) )
	If cNrRom != Nil .And. !Empty(cNrRom)
		If GWN->( dbSeek(cFil + cNrRom) )
			FWExecView("Visualizar", "GFEC050", 1,,{|| .T.})
		EndIf
	EndIf
	dbSelectArea("GWP")
	cFilAnt := cFilBkp
Return

Function GFEC58VLD(oModel)
	Local lRet := .T.
	Local nOp := oModel:GetOperation()
	If nOp == MODEL_OPERATION_INSERT .Or. nOp == MODEL_OPERATION_UPDATE	 .Or. nOp == MODEL_OPERATION_DELETE
		GfeMsgErro("GFEC058 pode ser utilizado somente para consulta")
		lRet := .F.
	EndIf
Return lRet