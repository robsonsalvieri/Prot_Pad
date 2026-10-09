#INCLUDE "GFEC070.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEC070
Consulta de Faturas de Frete
Generico

@sample
GFEC070()

@author Fabiane
@since 04/06/2010
@version 1.0
/*///------------------------------------------------------------------------------------------------

Function GFEC070()
	Local oBrowse
	Private aRotina := MenuDef()

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GW6")							             // Alias da tabela utilizada
	oBrowse:SetMenuDef("GFEC070")					             // Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription(STR0001)	 // Descrição do browse      //"Faturas de Frete"

	oBrowse:AddLegend("GW6_SITAPR == '1'", "BLACK" , STR0002) //Legenda do Browser //"Recebida"
	oBrowse:AddLegend("GW6_SITAPR == '2'", "RED"   , STR0003) //"Bloqueado"
	oBrowse:AddLegend("GW6_SITAPR == '3'", "GREEN" , STR0004) //"Aprovada Sistema"
	oBrowse:AddLegend("GW6_SITAPR == '4'", "BLUE"  , STR0005) //"Aprovada Usuario"

	oBrowse:Activate()

Return(Nil)

//------------------------------------------------------------------------------------------------ 

Static Function MenuDef()
	Local aRotina := {}

	// Adiciona botões do browse
	ADD OPTION aRotina TITLE STR0006 ACTION "AxPesqui"        OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.GFEC070" OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0008 ACTION "GFEA070CF()"     OPERATION 4 ACCESS 0 //"Detalhe Conf."
	ADD OPTION aRotina TITLE STR0009 ACTION "VIEWDEF.GFEC070" OPERATION 8 ACCESS 0 //"Imprimir"
	ADD OPTION aRotina TITLE "Visualizar Anexo" ACTION "ValX2Unico()" OPERATION 2  ACCESS 0  

Return aRotina       

//------------------------------------------------------------------------------------------------ 

Static Function ModelDef()
	Local oModel
	Local oStruGW3 := FWFormStruct( 1, 'GW3', /*bAvalCampo*/, /*lViewUsado*/ ) 
	Local oStruGWJ := FWFormStruct( 1, 'GWJ', /*bAvalCampo*/, /*lViewUsado*/ ) 
	Local oStruGW7 := FWFormStruct( 1, 'GW7', /*bAvalCampo*/, /*lViewUsado*/ )

	oModel := MPFormModel():New('GFEC070C', /*bPre*/, /*bPost*/, /*bCommit*/, /*bCancel*/)

	oModel:AddFields('GFEC070C_GW6', , FWFormStruct(1,'GW6'),/*bPre*/,/*bPost*/,/*bLoad*/)  

	oModel:AddGrid('GFEC070C_GW3','GFEC070C_GW6',oStruGW3,/*bLinePre*/, /*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:AddGrid('GFEC070C_GWJ','GFEC070C_GW6',oStruGWJ,/*bLinePre*/, /*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:AddGrid('GFEC070C_GW7','GFEC070C_GW6',oStruGW7,/*bLinePre*/, /*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)

	oModel:SetOptional('GFEC070C_GW3', .T. )
	oModel:SetOptional('GFEC070C_GWJ', .T. )

	oModel:SetRelation('GFEC070C_GW3',{{'GW3_FILFAT','GW6_FILIAL'},{'GW3_EMIFAT','GW6_EMIFAT'},{'GW3_SERFAT','GW6_SERFAT'},{'GW3_NRFAT','GW6_NRFAT'},{'GW3_DTEMFA','GW6_DTEMIS'}},'GW3_FILIAL+GW3_CDESP+GW3_EMISDF+GW3_SERDF+GW3_NRDF')
	oModel:SetRelation('GFEC070C_GWJ',{{'GWJ_FILFAT','GW6_FILIAL'},{'GWJ_EMIFAT','GW6_EMIFAT'},{'GWJ_SERFAT','GW6_SERFAT'},{'GWJ_NRFAT','GW6_NRFAT'},{'GWJ_DTEMFA','GW6_DTEMIS'}},'GWJ_FILIAL+GWJ_NRPF')
	oModel:SetRelation('GFEC070C_GW7',{{'GW7_FILIAL','GW6_FILIAL'},{'GW7_EMIFAT','GW6_EMIFAT'},{'GW7_SERFAT','GW6_SERFAT'},{'GW7_NRFAT','GW6_NRFAT'},{'GW7_DTEMIS','GW6_DTEMIS'}},'GW7_SEQ')

Return oModel

//------------------------------------------------------------------------------------------------  

Static Function ViewDef()
	Local oModel := FWLoadModel('GFEC070')
	Local oView  := Nil
	Local oStructGW6 := FWFormStruct(2,'GW6')
	Local oStructGWJ := FWFormStruct(2,'GWJ')
	Local oStructGW3 := FWFormStruct(2,'GW3')
	Local oStructGW7 := FWFormStruct(2,'GW7')

	oStructGW7:RemoveField("GW7_FILIAL")
	oStructGW7:RemoveField("GW7_EMIFAT")
	oStructGW7:RemoveField("GW7_SERFAT")
	oStructGW7:RemoveField("GW7_NRFAT")
	oStructGW7:RemoveField("GW7_DTEMIS")

	oStructGW6:AddGroup("GrpGrl", STR0010, "1", 2) // "Geral"
	oStructGW6:AddGroup("GrpVal", STR0011, "1", 2) // "Valores"
	oStructGW6:AddGroup("GrpImp", STR0012, "1", 2) // "Impostos"
	oStructGW6:AddGroup("GrpObs", STR0013, "1", 2) // "Observações"

	oStructGW6:AddGroup("GrpBlq", STR0014, "2", 2) // "Bloqueio"
	oStructGW6:AddGroup("GrpApr", STR0015, "2", 2) // "Aprovação"
	oStructGW6:AddGroup("GrpInt", STR0016, "2", 2) // "Integração"

	oStructGW6:SetProperty("GW6_EMIFAT", MVC_VIEW_GROUP_NUMBER, "GrpGrl")
	oStructGW6:SetProperty("GW6_NMEMIT", MVC_VIEW_GROUP_NUMBER, "GrpGrl")
	oStructGW6:SetProperty("GW6_SERFAT", MVC_VIEW_GROUP_NUMBER, "GrpGrl")
	oStructGW6:SetProperty("GW6_NRFAT" , MVC_VIEW_GROUP_NUMBER, "GrpGrl")
	oStructGW6:SetProperty("GW6_DTEMIS", MVC_VIEW_GROUP_NUMBER, "GrpGrl")
	oStructGW6:SetProperty("GW6_DTCRIA", MVC_VIEW_GROUP_NUMBER, "GrpGrl")
	oStructGW6:SetProperty("GW6_DTVENC", MVC_VIEW_GROUP_NUMBER, "GrpGrl")
	oStructGW6:SetProperty("GW6_ORIGEM", MVC_VIEW_GROUP_NUMBER, "GrpGrl")
	oStructGW6:SetProperty("GW6_SITAPR", MVC_VIEW_GROUP_NUMBER, "GrpGrl")

	oStructGW6:SetProperty("GW6_VLFATU", MVC_VIEW_GROUP_NUMBER, "GrpVal")
	oStructGW6:SetProperty("GW6_VLDESC", MVC_VIEW_GROUP_NUMBER, "GrpVal")
	oStructGW6:SetProperty("GW6_VLJURO", MVC_VIEW_GROUP_NUMBER, "GrpVal")
	oStructGW6:SetProperty("GW6_DINDEN", MVC_VIEW_GROUP_NUMBER, "GrpVal")

	oStructGW6:SetProperty("GW6_VLISS" , MVC_VIEW_GROUP_NUMBER, "GrpImp")
	oStructGW6:SetProperty("GW6_VLISRE", MVC_VIEW_GROUP_NUMBER, "GrpImp")
	oStructGW6:SetProperty("GW6_DSISCD", MVC_VIEW_GROUP_NUMBER, "GrpImp")
	oStructGW6:SetProperty("GW6_DSISCL", MVC_VIEW_GROUP_NUMBER, "GrpImp")
	oStructGW6:SetProperty("GW6_VLICMS", MVC_VIEW_GROUP_NUMBER, "GrpImp")
	oStructGW6:SetProperty("GW6_VLICRE", MVC_VIEW_GROUP_NUMBER, "GrpImp")
	oStructGW6:SetProperty("GW6_DSICCD", MVC_VIEW_GROUP_NUMBER, "GrpImp")
	oStructGW6:SetProperty("GW6_DSICCL", MVC_VIEW_GROUP_NUMBER, "GrpImp")
	oStructGW6:SetProperty("GW6_DSESPF", MVC_VIEW_GROUP_NUMBER, "GrpImp")
	oStructGW6:SetProperty("GW6_PRNAT" , MVC_VIEW_GROUP_NUMBER, "GrpImp")
	oStructGW6:SetProperty("GW6_MATREX", MVC_VIEW_GROUP_NUMBER, "GrpImp")
	oStructGW6:SetProperty("GW6_VLIRRF", MVC_VIEW_GROUP_NUMBER, "GrpImp")
	oStructGW6:SetProperty("GW6_NATURE", MVC_VIEW_GROUP_NUMBER, "GrpImp")
	If GFXCP2510("GW6_VLIBS") .And. GFXCP2510("GW6_VLIBSM") .And. GFXCP2510("GW6_VLCBS")
		oStructGW6:SetProperty("GW6_VLIBS" , MVC_VIEW_GROUP_NUMBER, "GrpImp")
		oStructGW6:SetProperty("GW6_VLIBSM", MVC_VIEW_GROUP_NUMBER, "GrpImp")
		oStructGW6:SetProperty("GW6_VLCBS" , MVC_VIEW_GROUP_NUMBER, "GrpImp")
	EndIf

	oStructGW6:SetProperty("GW6_OBS"   , MVC_VIEW_GROUP_NUMBER, "GrpObs")

	oStructGW6:SetProperty("GW6_DTBLOQ", MVC_VIEW_GROUP_NUMBER, "GrpBlq")
	oStructGW6:SetProperty("GW6_HRBLOQ", MVC_VIEW_GROUP_NUMBER, "GrpBlq")
	oStructGW6:SetProperty("GW6_USUBLO", MVC_VIEW_GROUP_NUMBER, "GrpBlq")
	oStructGW6:SetProperty("GW6_MOTBLO", MVC_VIEW_GROUP_NUMBER, "GrpBlq")

	oStructGW6:SetProperty("GW6_DTAPR" , MVC_VIEW_GROUP_NUMBER, "GrpApr")
	oStructGW6:SetProperty("GW6_HRAPR" , MVC_VIEW_GROUP_NUMBER, "GrpApr")
	oStructGW6:SetProperty("GW6_USUAPR", MVC_VIEW_GROUP_NUMBER, "GrpApr")
	oStructGW6:SetProperty("GW6_MOTDES", MVC_VIEW_GROUP_NUMBER, "GrpApr")

	oStructGW6:SetProperty("GW6_SITFIN", MVC_VIEW_GROUP_NUMBER, "GrpInt")
	oStructGW6:SetProperty("GW6_DTFIN" , MVC_VIEW_GROUP_NUMBER, "GrpInt")
	oStructGW6:SetProperty("GW6_HRFIN" , MVC_VIEW_GROUP_NUMBER, "GrpInt")
	oStructGW6:SetProperty("GW6_USUFIN", MVC_VIEW_GROUP_NUMBER, "GrpInt")
	oStructGW6:SetProperty("GW6_MOTFIN", MVC_VIEW_GROUP_NUMBER, "GrpInt")
	oStructGW6:SetProperty("GW6_DTLIQD", MVC_VIEW_GROUP_NUMBER, "GrpInt")

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField( 'GFEC070C_GW6' , oStructGW6, /*cLinkID*/ )

	oView:AddGrid( 'GFEC070C_GWJ' , oStructGWJ )
	oView:AddGrid( 'GFEC070C_GW3' , oStructGW3 )
	oView:AddGrid( 'GFEC070C_GW7' , oStructGW7 )

	oView:CreateHorizontalBox( 'MASTER' , 55 )
	oView:CreateHorizontalBox( 'DETAILFOLDE' , 45 )
	oView:CreateHorizontalBox( 'DETAILNETO1' , 100,,,'IDFOLDER01','IDSHEET01'  )
	oView:CreateHorizontalBox( 'DETAILNETO2' , 100,,,'IDFOLDER01','IDSHEET02'  )
	oView:CreateHorizontalBox( 'DETAILNETO3' , 100,,,'IDFOLDER01','IDSHEET03'  )

	oView:CreateFolder('IDFOLDER01','DETAILFOLDE') 
	oView:AddSheet('IDFOLDER01','IDSHEET01',STR0017)  //'Pré-Fatura'
	oView:AddSheet('IDFOLDER01','IDSHEET02',STR0018)  //'Documentos de Frete'
	oView:AddSheet('IDFOLDER01','IDSHEET03',"Rateio Contábil") 

	oView:SetOwnerView( 'GFEC070C_GW6' , 'MASTER' )
	oView:SetOwnerView( 'GFEC070C_GWJ' , 'DETAILNETO1' )   
	oView:SetOwnerView( 'GFEC070C_GW3' , 'DETAILNETO2' )   
	oView:SetOwnerView( 'GFEC070C_GW7' , 'DETAILNETO3' ) 

	oView:AddUserButton("Cons. Doc. Frete", "MAGIC_BMP", {|oView| GFEC070CDC(oView)}, ) 
	oView:AddUserButton("Cons. Pré Fat."  , "MAGIC_BMP", {|oView| GFEC070CCL(oView)}, ) 
Return oView

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEC070CDC
Consulta de Doc. Frete
Generico

@author Ana Claudia da Silva	
@since 06/03/2014
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFEC070CDC(oView)
	Local oModel    := oView:GetModel()
	Local oModelGW3 := oModel:GetModel("GFEC070C_GW3")
	Local nLine     := oModelGW3:GetLine()
	
	dbSelectArea("GW3")
	GW3->( dbSetOrder(1) ) 
	If GW3->( dbSeek(xFilial("GW3") + FWFldGet("GW3_CDESP", nLine) + FWFldGet("GW3_EMISDF", nLine)+  FWFldGet("GW3_SERDF", nLine)+  FWFldGet("GW3_NRDF", nLine)) )
		FWExecView("Visualiza", "GFEC065", 1,,{|| .T.})
	Else 
		MsgInfo("Não existe Documento de Frete relacionado a Fatura.")
	EndIf
	
Return
     
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEC070CCL
Consulta Pé Fatura
Generico

@author Ana Claudia da Silva	
@since 06/03/2014
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFEC070CCL(oView)
	Local oModel    := oView:GetModel()
	Local oModelGWJ := oModel:GetModel("GFEC070C_GWJ")
	Local nLine     := oModelGWJ:GetLine()

	dbSelectArea("GWJ")
	GWJ->( dbSetOrder(1) )
	If GWJ->( dbSeek(xFilial("GWJ") + FWFldGet("GWJ_NRPF", nLine) ))
		FWExecView("Visualiza", "GFEC055", 1,,{|| .T.})		
	Else 
		MsgInfo("Não existe Pré Fatura relacionada a Fatura.")
	EndIf

Return