#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static Function CamposGWF(cCampo)

Return !(AllTrim(cCampo) $ "GWF_FILIAL|GWF_VLAJUS|GWF_FILPRE|GWF_NRPREF|GWF_NRCONT|GWF_NROCO|GWF_ORIGEM|GWF_CDESP|GWF_EMISDF|GWF_SERDF|GWF_NRDF|GWF_DTEMDF|GWF_CDTPSE|GWF_DSTPSE|GWF_CARREG|GWF_EMIRED|GWF_NMRED")

Static Function CamposGWH(cCampo)

Return AllTrim(cCampo) $ "GWH_FILIAL|GWH_NRDC|GWH_CDTPDC|GWH_EMISDC|GWH_SERDC|GWH_TRECHO"

Static Function CamposGWI(cCampo)

Return AllTrim(cCampo) $ "GWI_CDCOMP|GWI_VLFRET|GWI_BASICM|GWI_BASPIS|"

Function GF84ACAMPOS(cTabela,cCampo)
	If cTabela == "GWF"
		Return CamposGWF(cCampo)
	ElseIf cTabela == "GWH"
		Return CamposGWH(cCampo)
	ElseIf cTabela == "GWI"
		Return CamposGWI(cCampo)
	EndIf
Return

Static Function ModelDef()

	Local oModel
	Local oStruGWFA := FWFormStruct(1, "GWF",{|cCampo| CamposGWF(cCampo)})
	Local oStruGWFB := FWFormStruct(1, "GWF",{|cCampo| CamposGWF(cCampo)})
	Local oStruGWH  := FWFormStruct(1, "GWH",{|cCampo| CamposGWH(cCampo)})
	Local oStruGWI  := FWFormStruct(1, "GWI",{|cCampo| CamposGWI(cCampo)})
	
	oStruGWFA:AddField("COMMIT","COMMIT","COMMIT","C",1)
	
	oModel := MPFormModel():New("GFEA084A", /*bPre*/, /* bPost*/, {|oModel| .T.}/*bCommit*/, /*bCancel*/)
	
	oModel:AddFields("Fantasma", Nil, oStruGWFA, /*bLinePre*/,, /*bPre*/, /*bPost*/, /*bLoad*/)
	
	oModel:GetModel("Fantasma"):SetDescription("Confirmação")
	oModel:SetDescription("Confirmação")
	
	oStruGWFB:AddField("Total Frete","Total Frete","TOTFRE","N",12,2)
	oStruGWFB:AddField("Valor Combinado","Valor Combinado","COMB","N",12,2)
	
	oModel:AddGrid("GFEA084A_GWFA", "Fantasma", oStruGWFB, /*bLinePre*/,, /*bPre*/, /*bPost*/, /*bLoad*/)
	
	oModel:AddFields("GFEA084A_GWFC", "GFEA084A_GWFA", oStruGWFA, /*bLinePre*/,, /*bPre*/, /*bPost*/, loadGWFC())
	
	oModel:AddGrid("GFEA084A_GWH", "GFEA084A_GWFA", oStruGWH, /*bLinePre*/,, /*bPre*/, /*bPost*/, /*bLoad*/)
	
	oModel:AddGrid("GFEA084A_GWI", "GFEA084A_GWFA", oStruGWI, /*bLinePre*/,, /*bPre*/, /*bPost*/, /*bLoad*/)
	
	oModel:SetRelation("GFEA084A_GWH", {{"GWH_NRCALC","GWF_NRCALC"}},"GWH_FILIAL+GWH_NRCALC")
	oModel:SetRelation("GFEA084A_GWI", {{"GWI_NRCALC","GWF_NRCALC"}},"GWI_FILIAL+GWI_NRCALC")
	
	oStruGWFA:SetProperty("*",MODEL_FIELD_INIT,)
	oStruGWFB:SetProperty("*",MODEL_FIELD_INIT,)
	oStruGWI:SetProperty("*",MODEL_FIELD_INIT,)
	oStruGWH:SetProperty("*",MODEL_FIELD_INIT,)
	
	oStruGWFA:SetProperty("*",MODEL_FIELD_VALID,{||.T.})
	oStruGWFB:SetProperty("*",MODEL_FIELD_VALID,{||.T.})
	oStruGWI:SetProperty("*",MODEL_FIELD_VALID,{||.T.})
	oStruGWH:SetProperty("*",MODEL_FIELD_VALID,{||.T.})
	
	oStruGWFA:SetProperty("*",MODEL_FIELD_WHEN,{||.T.})
	oStruGWFB:SetProperty("*",MODEL_FIELD_WHEN,{||.T.})
	oStruGWI:SetProperty("*",MODEL_FIELD_WHEN,{||.T.})
	oStruGWH:SetProperty("*",MODEL_FIELD_WHEN,{||.T.})
	
	oStruGWFA:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)
	oStruGWFB:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)
	oStruGWI:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)
	oStruGWH:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)

Return oModel

Static Function ViewDef()
	Local oModel    := FWLoadModel("GFEA084A")
	Local oView     := Nil
	Local oStruGWFA := FWFormStruct(2, "GWF",{|cCampo| CamposGWF(cCampo)})
	Local oStruGWFB := FWFormStruct(2, "GWF",{|cCampo| CamposGWF(cCampo)})
	Local oStruGWH  := FWFormStruct(2, "GWH",{|cCampo| CamposGWH(cCampo)},.F.,.F.,.T.)
	Local oStruGWI  := FWFormStruct(2, "GWI",{|cCampo| CamposGWI(cCampo)})
	
	oStruGWFA:RemoveField("GWF_NRCALC")
	
	oStruGWFB:AddField("TOTFRE",'03',"Total Frete","Total Frete", ,'GET', "@E 999,999,999.99")
	oStruGWFB:AddField("COMB"  ,'03',"Valor Combinado","Valor Combinado", ,'GET', "@E 999,999,999.99")
	oStruGWFB:RemoveField("GWF_NRCALC")
	
	oStruGWH:SetProperty("GWH_TRECHO", MVC_VIEW_TITULO, 'Trecho')
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	oView:AddGrid("GFEA084A_GWFA", oStruGWFB)
	oView:AddGrid("GFEA084A_GWH", oStruGWH)
	oView:AddGrid("GFEA084A_GWI", oStruGWI)
	oView:AddField("GFEA084A_GWFC", oStruGWFA )
	
	oView:SetOnlyView(    "GFEA084A_GWFC")
	oView:SetViewProperty("GFEA084A_GWI", "ONLYVIEW")

	oView:CreateHorizontalBox("MASTER", 20)
	oView:CreateHorizontalBox("DETAILA", 40)
	oView:CreateHorizontalBox("DETAILB", 40)
	
	oView:CreateFolder("IDFOLDER", "DETAILB")
	
	oView:AddSheet("IDFOLDER", "IDSHEET01","Componentes de Frete") //
	oView:AddSheet("IDFOLDER", "IDSHEET02", "Documentos de Carga") //

	oView:CreateHorizontalBox("DETAIL_GWI", 100,,, "IDFOLDER", "IDSHEET01" )
	oView:CreateHorizontalBox("EMBAIXOESQ", 100,,, "IDFOLDER", "IDSHEET02" )
	oView:SetOwnerView("GFEA084A_GWFA", "MASTER")
	oView:SetOwnerView("GFEA084A_GWFC", "DETAILA")
	oView:SetOwnerView("GFEA084A_GWI", "DETAIL_GWI")
	oView:SetOwnerView("GFEA084A_GWH", "EMBAIXOESQ")
	
	oView:showInsertMsg(.F.)
	
Return oView

Static function loadGWFC()
	aData := aAuxCalc2
Return aData
