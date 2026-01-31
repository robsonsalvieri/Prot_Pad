#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "VEIA328.CH"

Static cSiglaAMS := GetNewPar("MV_MIL0106","AMS") // Sigla da Solucao Agregada. Exemplos: AMS ou AFS ou SAG. Default: AMS

/*/{Protheus.doc} VEIA328
	MVC - AMS - Saida - Agrega/Desagrega - VFM

	@author Andre Luis Almeida
	@since 11/04/2023
/*/
Function VEIA328()
Return

Static Function MenuDef()
Local aRotina := {}
Return aRotina

Static Function ModelDef()
Local oStrVFM := FWFormStruct(1,"VFM")
oModel := MPFormModel():New("VEIA328", /* bPre */, /* bPost */ , /* bCommit */ , /* bCancel */ )
oModel:AddFields("VFMMASTER",/*cOwner*/ , oStrVFM)
oModel:GetModel("VFMMASTER"):SetDescription(cSiglaAMS+" - "+STR0001) // AMS - Saida - Agrega/Desagrega
oModel:SetDescription(cSiglaAMS+" - "+STR0001) // AMS - Saida - Agrega/Desagrega
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
Local oStrVFM:= FWFormStruct(2,"VFM")

oView := FWFormView():New()
oView:SetModel(oModel)
oView:SetCloseOnOk({||.T.})
oView:AddField('VIEW_VFM', oStrVFM, 'VFMMASTER' )

// definição de como será a tela
oView:CreateHorizontalBox('CABEC' ,100)
oView:SetOwnerView( 'VIEW_VFM' , 'CABEC' ) // AMS de Saida - Agrega/Desagrega

Return oView

/*/{Protheus.doc} VA3280011_MVC_CAD_VFM
Alteração do VFM

@author Andre Luis Almeida
@since 11/04/2023
/*/
Function VA3280011_MVC_CAD_VFM( nRecVFM , aVFM )
Local lRet      := .t.
Local oModelVFM := FWLoadModel( 'VEIA328' ) // VFM
Local nCntFor   := 0
If nRecVFM > 0 // Alteração
	VFM->(DbGoto(nRecVFM))
	oModelVFM:SetOperation( MODEL_OPERATION_UPDATE )
	If oModelVFM:Activate()
		For nCntFor := 1 to len(aVFM)
			oModelVFM:SetValue( "VFMMASTER" , aVFM[nCntFor,1] , aVFM[nCntFor,2] ) // Campos variaveis
		Next
		If ( lRet := oModelVFM:VldData() )
			if ( lRet := oModelVFM:CommitData() )
			EndIf
		EndIf
		oModelVFM:DeActivate()
	EndIf
EndIf
Return nRecVFM