#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
 
/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA096A
Lotes Provisão

@sample
GFEA096()

@author Siegklenes.Beulke 
@since 09/01/2014
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Static Function ViewDef()
	Local oView := FWFormView():New()
	
	Local oStructGXE := FWFormStruct(2, "GXE")
	Local oStructGXF := FWFormStruct(2, "GXF")
	Local oStructGXD := FWFormStruct(2, "GXD")
	Local oStructGXN := IIF( GFEA105ATV(),FWFormStruct(2, "GXN"),"" )
	
	Local oModel := FWLoadModel("GFEA096")
	Local oCalcGXF := FWCalcStruct( oModel:GetModel( 'CALCGXF_VLR') )
	
	oStructGXF:RemoveField("GXF_FILIAL")
	oStructGXF:RemoveField("GXF_CODLOT")
	
	oStructGXD:RemoveField("GXD_FILIAL")
	oStructGXD:RemoveField("GXD_CODLOT")
	
	If GFEA105ATV()
		oStructGXN:RemoveField("GXN_FILIAL")
		oStructGXN:RemoveField("GXN_CODLOT")
	EndIf
	
	oStructGXE:AddGroup("GrpId" , "Geral", "", 2)
	oStructGXE:AddGroup("GrpCon", "Controle", "", 2)
	
	oStructGXE:SetProperty("GXE_CODLOT"	,MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGXE:SetProperty("GXE_DTCRIA"	,MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGXE:SetProperty("GXE_FILDE"	,MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGXE:SetProperty("GXE_FILATE"	,MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGXE:SetProperty("GXE_PERIOD"	,MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGXE:SetProperty("GXE_CDEMIT"	,MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGXE:SetProperty("GXE_DTDE"	,MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGXE:SetProperty("GXE_DTATE"	,MVC_VIEW_GROUP_NUMBER, "GrpId")
	
	oStructGXE:SetProperty("GXE_SIT"	,MVC_VIEW_GROUP_NUMBER, "GrpCon")
	oStructGXE:SetProperty("GXE_DTSIT"	,MVC_VIEW_GROUP_NUMBER, "GrpCon")
	oStructGXE:SetProperty("GXE_MOTIVO"	,MVC_VIEW_GROUP_NUMBER, "GrpCon")
	
	oView:SetModel(oModel)
	
	oView:AddField("GFEA096_GXE",oStructGXE)
	oView:AddGrid("GFEA096_GXD",oStructGXD)
	oView:AddGrid("GFEA096_GXF",oStructGXF)
	If GFEA105ATV()
		oView:AddGrid("GFEA096_GXN",oStructGXN)
	EndIf
	oView:AddField( 'VIEWCALC_GXF', oCalcGXF, 'CALCGXF_VLR' )
		
	oView:SetOnlyView('GFEA096_GXF')
	oView:SetOnlyView('GFEA096_GXD')
	If GFEA105ATV()
		oView:SetOnlyView('GFEA096_GXN')
	EndIf
			
	oView:CreateHorizontalBox( 'MASTER', 40 ) 
	oView:CreateHorizontalBox( 'DETAIL', 60 ) 

	oView:CreateFolder('IDFOLDER', 'DETAIL') 
	oView:AddSheet('IDFOLDER', 'IDSHEET01', "Cálculos de Frete") 
	oView:AddSheet('IDFOLDER', 'IDSHEET02', "Lançamentos de Provisão")
	If GFEA105ATV()
		oView:AddSheet('IDFOLDER', 'IDSHEET03', "Sublotes de Estorno")
		
		oView:CreateHorizontalBox('DET_GXD' , 100,,, 'IDFOLDER', 'IDSHEET01') //"Cálculos de Frete"
		
		oView:CreateHorizontalBox('DET_GXF'    , 80,,, 'IDFOLDER', 'IDSHEET02') // "Lançamentos de Provisão"
		oView:CreateHorizontalBox('DET_GXFCALC', 20,,,  'IDFOLDER', 'IDSHEET02') // Campo Valor Lote
		
		oView:CreateHorizontalBox('DET_GXN', 100,,, 'IDFOLDER', 'IDSHEET03') // "Lançamentos de Estorno"
	Else
		oView:CreateHorizontalBox('DET_GXD',100,,, 'IDFOLDER', 'IDSHEET01')
		oView:CreateHorizontalBox('DET_GXF',80,,, 'IDFOLDER', 'IDSHEET02')
		oView:CreateHorizontalBox('DET_GXFCALC', 20,,, 'IDFOLDER', 'IDSHEET02')
	EndIf
	
	oView:SetOwnerView("GFEA096_GXE",'MASTER')
	oView:SetOwnerView("GFEA096_GXD",'DET_GXD')
	
	oView:SetOwnerView("GFEA096_GXF",'DET_GXF')
	oView:SetOwnerView("VIEWCALC_GXF",'DET_GXFCALC')
	
	If GFEA105ATV()
		oView:SetOwnerView("GFEA096_GXN",'DET_GXN')
		
		// Remove o campo repetido da tela
		oStructGXN:RemoveField( 'GXN_FILIAL' )
		oStructGXN:RemoveField( 'GXN_CODLOT' )
		oStructGXN:RemoveField( 'GXN_PERIOD' )
		oStructGXN:RemoveField( 'GXN_USUCRI' )
		
		oView:AddUserButton( 'Consulta Sublote', 'GFEA096_GXN', {|oView| GFEC105CON(oView)}, )
	EndIf
	
Return oView

Function GFEC105CON(oView)
	
	Local oModel    := oView:GetModel()
	Local oModelGXN := oModel:GetModel("GFEA096_GXN")
	Local nLine     := oModelGXN:GetLine()
	
	dbSelectArea("GXN")
	GXN->( dbSetOrder(1) )
	If GXN->( dbSeek(xFilial("GXN") + FWFldGet("GXN_CODLOT", nLine) + FWFldGet("GXN_CODEST", nLine)))
		FWExecView("Visualiza", "GFEC105", 1,,{|| .T.})
	Else
		Help(,,'HELP',,'Não foi possível localizar o Sublote de Estorno.',1,0)
	EndIf
	
Return Nil