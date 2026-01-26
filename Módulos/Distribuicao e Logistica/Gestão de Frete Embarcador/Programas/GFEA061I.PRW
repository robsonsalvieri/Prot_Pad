#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"               

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA061I
Componentes de tabela de frete do tipo vínculo.
Uso Generico.

@sample
GFEA061I()

@author Alan Victor Lamb
@since 23/07/13
@version 1.0
--------------------------------------------------------------------------------------------------/*/      
Function GFEA061I()
	
Return

Static Function ModelDef()
	Local oModel
	oModel := MPFormModel():New("GFEA061",/*bPre*/,{|oX| GFEA61POS(oX)},/*bCommit*/, /*bCancel*/)
	
	oModel:SetVldActivate({|oMod| GFEA061VLD(oMod)})
	oModel:AddFields("GFEA061_GVA", /*cOwner*/, FWFormStruct(1,"GVA"),/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:AddGrid("GFEA061_GVB", "GFEA061_GVA", FWFormStruct(1,"GVB"), /*bLinePre*/, /*bLinePos*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/) 
	
	oModel:SetRelation("GFEA061_GVB",{{"GVB_FILIAL",'xFilial("GVB")'},{"GVB_CDEMIT","GVA_CDEMIT"},{"GVB_NRTAB","GVA_NRTAB"}},"GVB_CDCOMP") 
	oModel:SetPrimaryKey({"GVA_FILIAL", "GVA_CDEMIT", "GVA_NRTAB"})
	oModel:AddRules("GFEA061_GVA","GVA_TABVIN","GFEA061_GVA","GVA_EMIVIN", 1)
	
	oModel:GetModel("GFEA061_GVA"):SetOnlyView('GFEA061_GVA', .T.)
	
	oModel:GetModel("GFEA061_GVB"):SetUniqueLine({"GVB_CDCOMP"})
	oModel:SetOptional("GFEA061_GVB", .T.)
Return oModel

Static Function ViewDef()
	Local oModel		:= FWLoadModel("GFEA061I")
	Local oView 		:= Nil
	Local oStructGVA 	:= FWFormStruct(2,"GVA")
	
	oStructGVA:SetNoFolders()
	
	oStructGVA:RemoveField("GVA_DTNEG")
	oStructGVA:RemoveField("GVA_NMCONT")
	oStructGVA:RemoveField("GVA_NMPROF")
	oStructGVA:RemoveField("GVA_TPARRE")
	oStructGVA:RemoveField("GVA_DTCRIA")
	oStructGVA:RemoveField("GVA_HRCRIA")
	oStructGVA:RemoveField("GVA_USUCRI")
	oStructGVA:RemoveField("GVA_DTATU")
	oStructGVA:RemoveField("GVA_HRATU")
	oStructGVA:RemoveField("GVA_USUATU")
	oStructGVA:RemoveField("GVA_ENVAPR")
	oStructGVA:RemoveField("GVA_DTAPR")
	oStructGVA:RemoveField("GVA_HRAPR")
	oStructGVA:RemoveField("GVA_USUAPR")
	oStructGVA:RemoveField("GVA_MTVRPR")
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	oView:AddField("GFEA061_GVA",oStructGVA,"GFEA061_GVA")
	oView:AddGrid("GFEA061_GVB",FWFormStruct(2,"GVB"),"GFEA061_GVB")
	
	oView:CreateHorizontalBox("MASTER" , 60)
	oView:CreateHorizontalBox("DETAIL" , 40) 
	oView:CreateHorizontalBox("DETAILFOLDER" , 100,,,"FOLDER01","SHEET01" ) 
	
	oView:CreateFolder("FOLDER01","DETAIL")
	oView:AddSheet("FOLDER01","SHEET01","Componentes - Vínculo")
	
	oView:SetOwnerView("GFEA061_GVA" , "MASTER")
	oView:SetOwnerView("GFEA061_GVB" , "DETAILFOLDER")
Return oView