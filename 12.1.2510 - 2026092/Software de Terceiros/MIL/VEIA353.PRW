#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "VEIA353.CH"

/*/{Protheus.doc} VEIA353
	MVC - Registros de Transferência para possibilitar Entrega em outra Filial - VWC

	@author Andre Luis Almeida
	@since 22/06/2026
/*/
Function VEIA353()
Return

Static Function MenuDef()
Local aRotina := {}
Return aRotina

Static Function ModelDef()
Local oStrVWC := FWFormStruct(1,"VWC")
oModel := MPFormModel():New("VEIA353", /* bPre */, /* bPost */ , /* bCommit */ , /* bCancel */ )
oModel:AddFields("VWCMASTER",/*cOwner*/ , oStrVWC)
oModel:GetModel("VWCMASTER"):SetDescription(STR0001) // Transferência para possibilitar Entrega em outra Filial
oModel:SetDescription(STR0001) // Transferência para possibilitar Entrega em outra Filial
Return oModel

/*/{Protheus.doc} ViewDef
Definição do interface

@author Andre Luis Almeida
@since 22/06/2026
@version 1.0
@Return oView
/*/
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrVWC:= FWFormStruct(2,"VWC")

oView := FWFormView():New()
oView:SetModel(oModel)
oView:SetCloseOnOk({||.T.})
oView:AddField('VIEW_VWC', oStrVWC, 'VWCMASTER' )

// definição de como será a tela
oView:CreateHorizontalBox('CABEC' ,100)
oView:SetOwnerView( 'VIEW_VWC' , 'CABEC' ) // Registros de Transferência para possibilitar Entrega em outra Filial

Return oView

/*/{Protheus.doc} VA3530011_MVC_CAD_VWC
Criação/Alteração do VWC por Transferência para possibilitar Entrega em outra Filial

@author Andre Luis Almeida
@since 22/06/2026
/*/
Function VA3530011_MVC_CAD_VWC( nRecVWC , aVWC )
Local lRet      := .t.
Local oModelVWC := FWLoadModel( 'VEIA353' ) // VWC
Local nCntFor   := 0
If nRecVWC == 0 // Inclusão
	oModelVWC:SetOperation( MODEL_OPERATION_INSERT )
Else // Alteração
	VWC->(DbGoto(nRecVWC))
	oModelVWC:SetOperation( MODEL_OPERATION_UPDATE )
EndIf
If oModelVWC:Activate()
	For nCntFor := 1 to len(aVWC)
		oModelVWC:SetValue( "VWCMASTER" , aVWC[nCntFor,1] , aVWC[nCntFor,2]              ) // Campos variaveis
	Next
	If ( lRet := oModelVWC:VldData() )
		if ( lRet := oModelVWC:CommitData() )
		EndIf
	EndIf
	oModelVWC:DeActivate()
	If lRet .and. nRecVWC == 0 // Inclusão
		nRecVWC := VWC->(RecNo())
	EndIf
EndIf
Return nRecVWC