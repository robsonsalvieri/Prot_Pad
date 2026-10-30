#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "OFIA465.CH"

/*/{Protheus.doc} OFIA466
	Transferência de Serviços Especializados - MVC somente para atualizar o cabeçalho VRT

	@author Andre Luis Almeida
	@since 01/11/2022
/*/
Function OFIA466()
Return

Static Function ModelDef()
Local oStrVRT := FWFormStruct(1,"VRT")
oModel := MPFormModel():New("OFIA466", /* bPre */, /* bPost */ , /* bCommit */ , /* bCancel */ )
oModel:AddFields("VRTMASTER",/*cOwner*/ , oStrVRT)
oModel:GetModel("VRTMASTER"):SetDescription(STR0001) // Transferência de Serviços Especializados
oModel:SetDescription(STR0001) // Transferência de Serviços Especializados
Return oModel

/*/{Protheus.doc} ViewDef
Definição do interface

@author Andre Luis Almeida
@since 01/11/2022
@version 1.0
@Return oView
/*/
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrVRT:= FWFormStruct(2,"VRT", { |cCampo| !ALLTRIM(cCampo) $ "VRT_CODIGO/" } )
oView := FWFormView():New()
oView:SetModel(oModel)
oView:SetCloseOnOk({||.T.})
oView:AddField( 'VIEW_VRT', oStrVRT, 'VRTMASTER' )
oView:CreateHorizontalBox('CABEC' , 100)
oView:SetOwnerView('VIEW_VRT', 'CABEC' )
Return oView