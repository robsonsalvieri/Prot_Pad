#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "OFIA460.CH"

/*/{Protheus.doc} OFIA461
	Entrada de Serviços Especializados - MVC somente para atualizar o cabeçalho VRP

	@author Andre Luis Almeida
	@since 01/11/2022
/*/
Function OFIA461()
Return

Static Function ModelDef()
Local oStrVRP := FWFormStruct(1,"VRP")
oModel := MPFormModel():New("OFIA461", /* bPre */, /* bPost */ , /* bCommit */ , /* bCancel */ )
oModel:AddFields("VRPMASTER",/*cOwner*/ , oStrVRP)
oModel:GetModel("VRPMASTER"):SetDescription(STR0001) // Entrada de Serviços Especializados
oModel:SetDescription(STR0001) // Entrada de Serviços Especializados
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
Local oStrVRP:= FWFormStruct(2,"VRP", { |cCampo| !ALLTRIM(cCampo) $ "VRP_CODIGO/" } )
oView := FWFormView():New()
oView:SetModel(oModel)
oView:SetCloseOnOk({||.T.})
oView:AddField( 'VIEW_VRP', oStrVRP, 'VRPMASTER' )
oView:CreateHorizontalBox('CABEC' , 100)
oView:SetOwnerView('VIEW_VRP', 'CABEC' )
Return oView