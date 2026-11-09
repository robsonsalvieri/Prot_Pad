#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "VEIA317.CH"

/*/{Protheus.doc} VEIA317
	MVC - Alteração dos Campos do VFJ - Processo Multieventos Agrega/Desagrega

	@author Andre Luis Almeida
	@since 17/02/2023
/*/
Function VEIA317()
Return

Static Function MenuDef()
Local aRotina := {}
Return aRotina

Static Function ModelDef()
Local oStrVFJ := FWFormStruct(1,"VFJ")
oModel := MPFormModel():New("VEIA317", /* bPre */, /* bPost */ , /* bCommit */ , /* bCancel */ )
oModel:AddFields("VFJMASTER",/*cOwner*/ , oStrVFJ)
oModel:GetModel("VFJMASTER"):SetDescription(STR0001) // Processo Multieventos Agrega/Desagrega
oModel:SetDescription(STR0001) // Processo Multieventos Agrega/Desagrega
Return oModel

/*/{Protheus.doc} ViewDef
Definição do interface

@author Andre Luis Almeida
@since 17/02/2023
@version 1.0
@Return oView
/*/
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrVFJ:= FWFormStruct(2,"VFJ")

oView := FWFormView():New()
oView:SetModel(oModel)
oView:SetCloseOnOk({||.T.})
oView:AddField('VIEW_VFJ', oStrVFJ, 'VFJMASTER' )

// definição de como será a tela
oView:CreateHorizontalBox('CABEC' ,100)
oView:SetOwnerView( 'VIEW_VFJ' , 'CABEC' ) // Processo

Return oView

/*/{Protheus.doc} VA3170011_MVC_CAD_VFJ
Alteração do VFJ

@author Andre Luis Almeida
@since 29/03/2023
/*/
Function VA3170011_MVC_CAD_VFJ( nRecVFJ , aVFJ )
Local lRet      := .t.
Local oModelVFJ := FWLoadModel( 'VEIA317' ) // VFJ
Local nCntFor   := 0
If nRecVFJ > 0 // Alteração
	VFJ->(DbGoto(nRecVFJ))
	oModelVFJ:SetOperation( MODEL_OPERATION_UPDATE )
	If oModelVFJ:Activate()
		For nCntFor := 1 to len(aVFJ)
			oModelVFJ:SetValue( "VFJMASTER" , aVFJ[nCntFor,1] , aVFJ[nCntFor,2]              ) // Campos variaveis
		Next
		If ( lRet := oModelVFJ:VldData() )
			if ( lRet := oModelVFJ:CommitData() )
			EndIf
		EndIf
		oModelVFJ:DeActivate()
	EndIf
EndIf
Return nRecVFJ