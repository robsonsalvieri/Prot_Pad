#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static Function CamposGWF(cCampo)
	Local lRet	:= .F.

	lRet := !(AllTrim(cCampo) $ "GWF_FILIAL|GWF_EMIREM|GWF_NMREM|GWF_EMIDES|GWF_NMDEST|GWF_EMIPAG|GWF_NMPAG|GWF_CIDORI|GWF_NMCIOR|GWF_CIDDES|GWF_NMCIDE|GWF_ENDENT|GWF_BAIENT|GWF_CIDENT|GWF_DTPREN|GWF_HRPREN|GWF_GWF_NRROM|GWF_GWF_IDFRVI|GWF_AGRUP|GWF_SEQTRE|GWF_VLAJUS|GWF_OBS|GWF_FILPRE|GWF_NRPREF|GWF_NRCONT|GWF_NROCO|GWF_ORIGEM|GWF_CDESP|GWF_EMISDF|GWF_SERDF|GWF_NRDF|GWF_DTEMDF|GWF_CDTPSE|GWF_DSTPSE|GWF_CARREG|GWF_EMIRED|GWF_NMRED|GWF_FINCAL")
Return lRet

Static Function ModelDef()                       
	Local oModel
	Local oStructGWF := FWFormStruct(1, "GWF",{|cCampo| CamposGWF(cCampo)})

	oModel := MPFormModel():New("GFEA086A",  /*bPre*/,/*bPost*/, /*bCommit*/, /*bCancel*/)

	oModel:AddFields("GFEA086A_GWF", Nil,oStructGWF,/*bPre*/,/*bPost*/,/*bLoad*/) 
Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel     := FWLoadModel("GFEA086A")
	Local oView      := Nil
	Local oStruct    := FWFormStruct(2,"GWF",{|cCampo| CamposGWF(cCampo)})

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("GFEA086A_GWF" , oStruct, /*cLinkID*/)
Return oView
