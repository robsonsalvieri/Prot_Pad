#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "VEIA319.CH"

/*/{Protheus.doc} VEIA319
	MVC - Movimentações Internas relacionadas aos Registros de Agrega/Desagrega - VBH

	@author Andre Luis Almeida
	@since 01/03/2023
/*/
Function VEIA319()
Return

Static Function MenuDef()
Local aRotina := {}
Return aRotina

Static Function ModelDef()
Local oStrVBH := FWFormStruct(1,"VBH")
oModel := MPFormModel():New("VEIA319", /* bPre */, /* bPost */ , /* bCommit */ , /* bCancel */ )
oModel:AddFields("VBHMASTER",/*cOwner*/ , oStrVBH)
oModel:GetModel("VBHMASTER"):SetDescription(STR0001) // Movimentações Internas relacionadas aos Registros de Agrega/Desagrega
oModel:SetDescription(STR0001) // Movimentações Internas relacionadas aos Registros de Agrega/Desagrega
Return oModel

/*/{Protheus.doc} ViewDef
Definição do interface

@author Andre Luis Almeida
@since 01/03/2023
@version 1.0
@Return oView
/*/
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrVBH:= FWFormStruct(2,"VBH")

oView := FWFormView():New()
oView:SetModel(oModel)
oView:SetCloseOnOk({||.T.})
oView:AddField('VIEW_VBH', oStrVBH, 'VBHMASTER' )

// definição de como será a tela
oView:CreateHorizontalBox('CABEC' ,100)
oView:SetOwnerView( 'VIEW_VBH' , 'CABEC' ) // Movimentações Internas relacionadas aos Registros de Agrega/Desagrega

Return oView

/*/{Protheus.doc} VA3190011_MVC_CAD_VBH
Criação/Alteração do VBH por Agrega e Desagrega

@author Andre Luis Almeida
@since 13/03/2023
/*/
Function VA3190011_MVC_CAD_VBH( nRecVBH , aVBH )
Local lRet      := .t.
Local oModelVBH := FWLoadModel( 'VEIA319' ) // VBH
Local cCodVBH   := ""
Local nCntFor   := 0
If nRecVBH == 0 // Inclusão
	oModelVBH:SetOperation( MODEL_OPERATION_INSERT )
Else // Alteração
	VBH->(DbGoto(nRecVBH))
	oModelVBH:SetOperation( MODEL_OPERATION_UPDATE )
EndIf
If oModelVBH:Activate()
	If nRecVBH == 0 // Inclusão - Campos Default
		cCodVBH := GetSXENum("VBH","VBH_CODIGO") // Batizar o Codigo Sequencial do VBH
		ConfirmSx8()
		oModelVBH:SetValue( "VBHMASTER" , "VBH_FILIAL" , xFilial("VBH")                  ) // Filial
		oModelVBH:SetValue( "VBHMASTER" , "VBH_CODIGO" , cCodVBH                         ) // Codigo Sequencial do VBH
	EndIf
	For nCntFor := 1 to len(aVBH)
		oModelVBH:SetValue( "VBHMASTER" , aVBH[nCntFor,1] , aVBH[nCntFor,2]              ) // Campos variaveis
	Next
	If ( lRet := oModelVBH:VldData() )
		if ( lRet := oModelVBH:CommitData() )
		EndIf
	EndIf
	oModelVBH:DeActivate()
	If lRet .and. nRecVBH == 0 // Inclusão
		nRecVBH := VBH->(RecNo())
	EndIf
EndIf
Return nRecVBH