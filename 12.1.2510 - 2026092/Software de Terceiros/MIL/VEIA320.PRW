#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "VEIA320.CH"

/*/{Protheus.doc} VEIA320
	MVC - NFs Saidas relacionadas aos Registros de Agrega/Desagrega - VFK

	@author Andre Luis Almeida
	@since 02/03/2023
/*/
Function VEIA320()
Return

Static Function MenuDef()
Local aRotina := {}
Return aRotina

Static Function ModelDef()
Local oStrVFK := FWFormStruct(1,"VFK")
oModel := MPFormModel():New("VEIA320", /* bPre */, /* bPost */ , /* bCommit */ , /* bCancel */ )
oModel:AddFields("VFKMASTER",/*cOwner*/ , oStrVFK)
oModel:GetModel("VFKMASTER"):SetDescription(STR0001) // NFs Saidas relacionadas aos Registros de Agrega/Desagrega
oModel:SetDescription(STR0001) // NFs Saidas relacionadas aos Registros de Agrega/Desagrega
Return oModel

/*/{Protheus.doc} ViewDef
Definição do interface

@author Andre Luis Almeida
@since 02/03/2023
@version 1.0
@Return oView
/*/
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrVFK:= FWFormStruct(2,"VFK")

oView := FWFormView():New()
oView:SetModel(oModel)
oView:SetCloseOnOk({||.T.})
oView:AddField('VIEW_VFK', oStrVFK, 'VFKMASTER' )

// definição de como será a tela
oView:CreateHorizontalBox('CABEC' ,100)
oView:SetOwnerView( 'VIEW_VFK' , 'CABEC' ) // NFs Saidas relacionadas aos Registros de Agrega/Desagrega

Return oView

/*/{Protheus.doc} VA3200011_MVC_CAD_VFK
Inclusão/Alteração do VFK

@author Andre Luis Almeida
@since 06/03/2023
/*/
Function VA3200011_MVC_CAD_VFK( nRecVFK , aVFK )
Local lRet      := .t.
Local oModelVFK := FWLoadModel( 'VEIA320' ) // VFK
Local nCntFor   := 0
If nRecVFK == 0 // Inclusão
	oModelVFK:SetOperation( MODEL_OPERATION_INSERT )
Else // Alteração
	VFK->(DbGoto(nRecVFK))
	oModelVFK:SetOperation( MODEL_OPERATION_UPDATE )
EndIf
If oModelVFK:Activate()
	For nCntFor := 1 to len(aVFK)
		oModelVFK:SetValue( "VFKMASTER" , aVFK[nCntFor,1] , aVFK[nCntFor,2] ) // Campos variaveis
	Next
	If ( lRet := oModelVFK:VldData() )
		if ( lRet := oModelVFK:CommitData() )
		EndIf
	EndIf
	oModelVFK:DeActivate()
EndIf
Return lRet