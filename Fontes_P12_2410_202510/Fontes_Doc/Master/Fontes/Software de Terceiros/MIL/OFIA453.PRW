#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "OFIA453.CH"

/*/{Protheus.doc} OFIA453
MVC - Inclui Movimentações de Estoque do Servico Especializado

@author Andre Luis Almeida
@since 25/08/2022
/*/
Function OFIA453( cCodEst , cSerInt , cFilMov , cTipMov , cPorMov , cOpeMov , nQtdMov , cFilRel , cCodRel )
Local oModVPZ   := FWLoadModel( 'OFIA453' )
Default cCodEst := ""
Default cSerInt := ""
Default cFilMov := ""
Default cTipMov := "0" // 0=Entrada
Default cPorMov := "0" // 0=Normal
Default cOpeMov := "0" // 0=Compra
Default nQtdMov := 0
Default cFilRel := ""
Default cCodRel := ""
If !Empty(cCodEst)
	oModVPZ:SetOperation( MODEL_OPERATION_INSERT )
	oModVPZ:Activate()
	oModVPZ:SetValue( "VPZMASTER", "VPZ_CODEST", cCodEst )
	oModVPZ:SetValue( "VPZMASTER", "VPZ_SERINT", cSerInt )
	oModVPZ:SetValue( "VPZMASTER", "VPZ_FILMOV", cFilMov )
	oModVPZ:SetValue( "VPZMASTER", "VPZ_TIPMOV", cTipMov )
	oModVPZ:SetValue( "VPZMASTER", "VPZ_PORMOV", cPorMov )
	oModVPZ:SetValue( "VPZMASTER", "VPZ_OPEMOV", cOpeMov )
	oModVPZ:SetValue( "VPZMASTER", "VPZ_QTDMOV", nQtdMov )
	oModVPZ:SetValue( "VPZMASTER", "VPZ_FILREL", cFilRel )
	oModVPZ:SetValue( "VPZMASTER", "VPZ_CODREL", cCodRel )
	oModVPZ:VldData()
	oModVPZ:CommitData()
	oModVPZ:DeActivate()
EndIf
FreeObj(oModVPZ)
Return

/*/{Protheus.doc} MenuDef
Função para criação do menu 

@author Andre Luis Almeida
@since 25/08/2022
/*/
Static Function MenuDef()

	Local aRotina := {}
	aRotina := FWMVCMenu('OFIA453')

Return aRotina

/*/{Protheus.doc} ModelDef
ModelDef

@author Andre Luis Almeida
@since 25/08/2022
/*/
Static Function ModelDef()

	Local oModel
	Local oStrVPZ := FWFormStruct(1, "VPZ")

	oModel := MPFormModel():New('OFIA453',,,,)
	oModel:AddFields('VPZMASTER',/*cOwner*/ , oStrVPZ)
	oModel:SetDescription(STR0001) // Movimentação de Estoque do Serviço Especializado
	oModel:GetModel('VPZMASTER'):SetDescription(STR0001) // Movimentação de Estoque do Serviço Especializado

Return oModel

/*/{Protheus.doc} ViewDef
ViewDef

@author Andre Luis Almeida
@since 25/08/2022
/*/
Static Function ViewDef()

	Local oView
	Local oModel := ModelDef()
	Local oStrVPZ:= FWFormStruct(2, "VPZ")

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:CreateHorizontalBox( 'BOXVPZ', 100)
	oView:AddField('VIEW_VPZ', oStrVPZ, 'VPZMASTER')
	oView:EnableTitleView('VIEW_VPZ', STR0001) // Movimentação de Estoque do Serviço Especializado
	oView:SetOwnerView('VIEW_VPZ','BOXVPZ')

Return oView