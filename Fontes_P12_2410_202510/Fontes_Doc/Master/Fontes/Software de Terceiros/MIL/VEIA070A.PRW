#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "VEIA070.CH"

/*/{Protheus.doc} VEIA070X
	Função Replicar em Cadastro de veículos MVC (VV1)
	@type function
	@author Cristiam Rossi
	@since 08/01/2024
/*/
static function ViewDef()

	Local oModel    := FWLoadModel( 'VEIA070' )
	Local oStruVV1  := FWFormStruct( 2, 'VV1' )
	Local oView
	Local oReplicar := VA070022C_Replicar()
	Local oViewRoda := oReplicar:GetView()
	Local oModelRoda := oReplicar:GetModel()

	oModel:AddGrid( 'REPLICAR', 'MODEL_VV1', oModelRoda , /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePos > */ , /* <bLoad> */ )
	oModel:GetModel('REPLICAR'):SetDescription(STR0052) // Outros Veiculos
	oModel:GetModel('REPLICAR'):SetNoDeleteLine( .F. )
	oModel:GetModel('REPLICAR'):SetOptional( .T. )

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_VV1', oStruVV1, 'MODEL_VV1' )

	oView:CreateHorizontalBox( 'TELA' , 80 )
	oView:SetOwnerView( 'VIEW_VV1', 'TELA' )

	oView:CreateHorizontalBox( 'TELA2' , 20 )
	oView:AddGrid('FORM2', oViewRoda, 'REPLICAR')
	oView:SetOwnerView('FORM2','TELA2')
return oView
