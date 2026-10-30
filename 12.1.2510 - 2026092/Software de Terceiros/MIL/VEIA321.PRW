#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "VEIA321.CH"

/*/{Protheus.doc} VEIA321
	MVC - NFs Entradas relacionadas aos Registros de Agrega/Desagrega - VFL

	@author Andre Luis Almeida
	@since 02/03/2023
/*/
Function VEIA321()
Return

Static Function MenuDef()
Local aRotina := {}
Return aRotina

Static Function ModelDef()
Local oStrVFL := FWFormStruct(1,"VFL")
oModel := MPFormModel():New("VEIA321", /* bPre */, /* bPost */ , /* bCommit */ , /* bCancel */ )
oModel:AddFields("VFLMASTER",/*cOwner*/ , oStrVFL)
oModel:GetModel("VFLMASTER"):SetDescription(STR0001) // NFs Entradas relacionadas aos Registros de Agrega/Desagrega
oModel:SetDescription(STR0001) // NFs Entradas relacionadas aos Registros de Agrega/Desagrega
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
Local oStrVFL:= FWFormStruct(2,"VFL")

oView := FWFormView():New()
oView:SetModel(oModel)
oView:SetCloseOnOk({||.T.})
oView:AddField('VIEW_VFL', oStrVFL, 'VFLMASTER' )

// definição de como será a tela
oView:CreateHorizontalBox('CABEC' ,100)
oView:SetOwnerView( 'VIEW_VFL' , 'CABEC' ) // NFs Entradas relacionadas aos Registros de Agrega/Desagrega

Return oView

/*/{Protheus.doc} VA3210011_MVC_CAD_VFL
Inclusão/Alteração do VFL

@author Andre Luis Almeida
@since 06/03/2023
/*/
Function VA3210011_MVC_CAD_VFL( nRecVFL , aVFL )
Local lRet      := .t.
Local oModelVFL := FWLoadModel( 'VEIA321' ) // VFL
Local nCntFor   := 0
If nRecVFL == 0 // Inclusão
	oModelVFL:SetOperation( MODEL_OPERATION_INSERT )
Else // Alteração
	VFL->(DbGoto(nRecVFL))
	oModelVFL:SetOperation( MODEL_OPERATION_UPDATE )
EndIf
If oModelVFL:Activate()
	For nCntFor := 1 to len(aVFL)
		oModelVFL:SetValue( "VFLMASTER" , aVFL[nCntFor,1] , aVFL[nCntFor,2] ) // Campos variaveis
	Next
	If ( lRet := oModelVFL:VldData() )
		if ( lRet := oModelVFL:CommitData() )
		EndIf
	EndIf
	oModelVFL:DeActivate()
EndIf
Return lRet