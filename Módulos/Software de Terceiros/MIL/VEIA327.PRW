#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "VEIA327.CH"

/*/{Protheus.doc} VEIA327
	MVC - Peças - Entrada - Agrega/Desagrega - VFQ

	@author Andre Luis Almeida
	@since 03/04/2023
/*/
Function VEIA327()
Return

Static Function MenuDef()
Local aRotina := {}
Return aRotina

Static Function ModelDef()
Local oStrVFQ := FWFormStruct(1,"VFQ")
oModel := MPFormModel():New("VEIA327", /* bPre */, /* bPost */ , /* bCommit */ , /* bCancel */ )
oModel:AddFields("VFQMASTER",/*cOwner*/ , oStrVFQ)
oModel:GetModel("VFQMASTER"):SetDescription(STR0001) // Peças - Entrada - Agrega/Desagrega
oModel:SetDescription(STR0001) // Peças - Entrada - Agrega/Desagrega
Return oModel

/*/{Protheus.doc} ViewDef
Definição do interface

@author Andre Luis Almeida
@since 03/04/2023
@version 1.0
@Return oView
/*/
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrVFQ:= FWFormStruct(2,"VFQ")

oView := FWFormView():New()
oView:SetModel(oModel)
oView:SetCloseOnOk({||.T.})
oView:AddField('VIEW_VFQ', oStrVFQ, 'VFQMASTER' )

// definição de como será a tela
oView:CreateHorizontalBox('CABEC' ,100)
oView:SetOwnerView( 'VIEW_VFQ' , 'CABEC' ) // Peças - Entrada - Agrega/Desagrega

Return oView

/*/{Protheus.doc} VA3270011_MVC_CAD_VFQ
Alteração do VFQ

@author Andre Luis Almeida
@since 29/03/2023
/*/
Function VA3270011_MVC_CAD_VFQ( nRecVFQ , aVFQ )
Local lRet      := .t.
Local oModelVFQ := FWLoadModel( 'VEIA327' ) // VFQ
Local nCntFor   := 0
If nRecVFQ > 0 // Alteração
	VFQ->(DbGoto(nRecVFQ))
	oModelVFQ:SetOperation( MODEL_OPERATION_UPDATE )
	If oModelVFQ:Activate()
		For nCntFor := 1 to len(aVFQ)
			oModelVFQ:SetValue( "VFQMASTER" , aVFQ[nCntFor,1] , aVFQ[nCntFor,2] ) // Campos variaveis
		Next
		If ( lRet := oModelVFQ:VldData() )
			if ( lRet := oModelVFQ:CommitData() )
			EndIf
		EndIf
		oModelVFQ:DeActivate()
	EndIf
EndIf
Return nRecVFQ