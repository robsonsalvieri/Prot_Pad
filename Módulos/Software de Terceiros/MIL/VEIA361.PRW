#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "VEIA360.CH"

/*/{Protheus.doc} VEIA361
	MVC - Registros de Origens relacionadas ao Antecipo - VBT ( execução via VEIA360 )

	@author Andre Luis Almeida
	@since 12/12/2024
/*/

/*/{Protheus.doc} ModelDef
ModelDef MVC

@author Andre Luis Almeida
@since 12/12/2024
@version 1.0
@Return oView
/*/
Static Function ModelDef()
Local oStrVBT := FWFormStruct(1,"VBT")
oModel := MPFormModel():New("VEIA361", /* bPre */, /* bPost */ , /* bCommit */ , /* bCancel */ )
oModel:AddFields("VBTMASTER",/*cOwner*/ , oStrVBT)
oModel:GetModel("VBTMASTER"):SetDescription(STR0009) // Origens relacionadas ao Antecipo
oModel:SetDescription(STR0009) // Origens relacionadas ao Antecipo
Return oModel

/*/{Protheus.doc} ViewDef
Definição do interface MVC

@author Andre Luis Almeida
@since 12/12/2024
@version 1.0
@Return oView
/*/
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrVBT:= FWFormStruct(2,"VBT")

oView := FWFormView():New()
oView:SetModel(oModel)
oView:SetCloseOnOk({||.T.})
oView:AddField('VIEW_VBT', oStrVBT, 'VBTMASTER' )

// definição de como será a tela
oView:CreateHorizontalBox('CABEC' ,100)
oView:SetOwnerView( 'VIEW_VBT' , 'CABEC' ) // Origens relacionadas ao Antecipo

Return oView

/*/{Protheus.doc} VA3610011_MVC_VBT
Inclusão/Alteração do VBT

@author Andre Luis Almeida
@since 12/12/2024
/*/
Function VA3610011_MVC_VBT( nRecVBT , aVBT )
Local lRet      := .t.
Local oModelVBT := FWLoadModel( 'VEIA361' ) // VBT
Local nCntFor   := 0
If nRecVBT == 0 // Inclusão
	oModelVBT:SetOperation( MODEL_OPERATION_INSERT )
Else // Alteração
	VBT->(DbGoto(nRecVBT))
	oModelVBT:SetOperation( MODEL_OPERATION_UPDATE )
EndIf
If oModelVBT:Activate()
	For nCntFor := 1 to len(aVBT)
		oModelVBT:SetValue( "VBTMASTER" , aVBT[nCntFor,1] , aVBT[nCntFor,2] ) // Campos variaveis
	Next
	If ( lRet := oModelVBT:VldData() )
		if ( lRet := oModelVBT:CommitData() )
		EndIf
	EndIf
	oModelVBT:DeActivate()
	If lRet .and. nRecVBT == 0 // Inclusão
		nRecVBT := VBT->(RecNo())
	EndIf
EndIf
Return nRecVBT

/*/{Protheus.doc} VA3610021_MVC_VBT_DESATIVAR
Chama MVC para Alterar e gravar os campos de desativação

@author Andre Luis Almeida
@since 17/12/2024
/*/
Function VA3610021_MVC_VBT_DESATIVAR( nRecVBT )
Local aVBT := {}
aAdd(aVBT,{ "VBT_DATDEL" , FGX_Timestamp() })
aAdd(aVBT,{ "VBT_USRDEL" , __cUserID })
aAdd(aVBT,{ "VBT_ATIVO"  , "0" }) // 0=Nao
VA3610011_MVC_VBT( nRecVBT , aVBT )
Return