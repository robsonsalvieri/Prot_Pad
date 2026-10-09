#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "VEIA322.CH"

Static cSiglaAMS := GetNewPar("MV_MIL0106","AMS") // Sigla da Solucao Agregada. Exemplos: AMS ou AFS ou SAG. Default: AMS

/*/{Protheus.doc} VEIA322
	MVC - AMS - Entrada - Agrega/Desagrega - VFP

	@author Andre Luis Almeida
	@since 03/04/2023
/*/
Function VEIA322()
Return

Static Function MenuDef()
Local aRotina := {}
Return aRotina

Static Function ModelDef()
Local oStrVFP := FWFormStruct(1,"VFP")
oModel := MPFormModel():New("VEIA322", /* bPre */, /* bPost */ , /* bCommit */ , /* bCancel */ )
oModel:AddFields("VFPMASTER",/*cOwner*/ , oStrVFP)
oModel:GetModel("VFPMASTER"):SetDescription(cSiglaAMS+" - "+STR0001) // Entrada - Agrega/Desagrega
oModel:SetDescription(cSiglaAMS+" - "+STR0001) // AMS de Entrada - Agrega/Desagrega
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
Local oStrVFP:= FWFormStruct(2,"VFP")

oView := FWFormView():New()
oView:SetModel(oModel)
oView:SetCloseOnOk({||.T.})
oView:AddField('VIEW_VFP', oStrVFP, 'VFPMASTER' )

// definição de como será a tela
oView:CreateHorizontalBox('CABEC' ,100)
oView:SetOwnerView( 'VIEW_VFP' , 'CABEC' ) // AMS de Entrada - Agrega/Desagrega

Return oView

/*/{Protheus.doc} VA3220011_MVC_CAD_VFP
Alteração do VFP

@author Andre Luis Almeida
@since 29/03/2023
/*/
Function VA3220011_MVC_CAD_VFP( nRecVFP , aVFP )
Local lRet      := .t.
Local oModelVFP := FWLoadModel( 'VEIA322' ) // VFP
Local nCntFor   := 0
If nRecVFP > 0 // Alteração
	VFP->(DbGoto(nRecVFP))
	oModelVFP:SetOperation( MODEL_OPERATION_UPDATE )
	If oModelVFP:Activate()
		For nCntFor := 1 to len(aVFP)
			oModelVFP:SetValue( "VFPMASTER" , aVFP[nCntFor,1] , aVFP[nCntFor,2] ) // Campos variaveis
		Next
		If ( lRet := oModelVFP:VldData() )
			if ( lRet := oModelVFP:CommitData() )
			EndIf
		EndIf
		oModelVFP:DeActivate()
	EndIf
EndIf
Return nRecVFP