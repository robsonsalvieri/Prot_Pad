#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "VEIA329.CH"

/*/{Protheus.doc} VEIA329
	MVC - Peças - Saida - Agrega/Desagrega - VFN

	@author Andre Luis Almeida
	@since 11/04/2023
/*/
Function VEIA329()
Return

Static Function MenuDef()
Local aRotina := {}
Return aRotina

Static Function ModelDef()
Local oStrVFN := FWFormStruct(1,"VFN")
oModel := MPFormModel():New("VEIA329", /* bPre */, /* bPost */ , /* bCommit */ , /* bCancel */ )
oModel:AddFields("VFNMASTER",/*cOwner*/ , oStrVFN)
oModel:GetModel("VFNMASTER"):SetDescription(STR0001) // Peças - Saida - Agrega/Desagrega
oModel:SetDescription(STR0001) // Peças - Saida - Agrega/Desagrega
Return oModel

/*/{Protheus.doc} ViewDef
Definição do interface

@author Andre Luis Almeida
@since 11/04/2023
@version 1.0
@Return oView
/*/
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrVFN:= FWFormStruct(2,"VFN")

oView := FWFormView():New()
oView:SetModel(oModel)
oView:SetCloseOnOk({||.T.})
oView:AddField('VIEW_VFN', oStrVFN, 'VFNMASTER' )

// definição de como será a tela
oView:CreateHorizontalBox('CABEC' ,100)
oView:SetOwnerView( 'VIEW_VFN' , 'CABEC' ) // Peças - Saida - Agrega/Desagrega

Return oView

/*/{Protheus.doc} VA3290011_MVC_CAD_VFN
Alteração do VFN

@author Andre Luis Almeida
@since 11/04/2023
/*/
Function VA3290011_MVC_CAD_VFN( nRecVFN , aVFN )
Local lRet      := .t.
Local oModelVFN := FWLoadModel( 'VEIA329' ) // VFN
Local nCntFor   := 0
If nRecVFN > 0 // Alteração
	VFN->(DbGoto(nRecVFN))
	oModelVFN:SetOperation( MODEL_OPERATION_UPDATE )
	If oModelVFN:Activate()
		For nCntFor := 1 to len(aVFN)
			oModelVFN:SetValue( "VFNMASTER" , aVFN[nCntFor,1] , aVFN[nCntFor,2] ) // Campos variaveis
		Next
		If ( lRet := oModelVFN:VldData() )
			if ( lRet := oModelVFN:CommitData() )
			EndIf
		EndIf
		oModelVFN:DeActivate()
	EndIf
EndIf
Return nRecVFN