#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "VEIA318.CH"

/*/{Protheus.doc} VEIA318
	MVC - Registros de Agrega/Desagrega - VDV

	@author Andre Luis Almeida
	@since 01/03/2023
/*/
Function VEIA318()
Return

Static Function MenuDef()
Local aRotina := {}
Return aRotina

Static Function ModelDef()
Local oStrVDV := FWFormStruct(1,"VDV")
oModel := MPFormModel():New("VEIA318", /* bPre */, /* bPost */ , /* bCommit */ , /* bCancel */ )
oModel:AddFields("VDVMASTER",/*cOwner*/ , oStrVDV)
oModel:GetModel("VDVMASTER"):SetDescription(STR0001) // Registros de Agrega/Desagrega
oModel:SetDescription(STR0001) // Registros de Agrega/Desagrega
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
Local oStrVDV:= FWFormStruct(2,"VDV")

oView := FWFormView():New()
oView:SetModel(oModel)
oView:SetCloseOnOk({||.T.})
oView:AddField('VIEW_VDV', oStrVDV, 'VDVMASTER' )

// definição de como será a tela
oView:CreateHorizontalBox('CABEC' ,100)
oView:SetOwnerView( 'VIEW_VDV' , 'CABEC' ) // Registros de Agrega/Desagrega

Return oView

/*/{Protheus.doc} VA3180011_MVC_CAD_VDV
Criação/Alteração do VDV por Agrega e Desagrega

@author Andre Luis Almeida
@since 03/03/2023
/*/
Function VA3180011_MVC_CAD_VDV( nRecVDV , aVDV )
Local lRet      := .t.
Local oModelVDV := FWLoadModel( 'VEIA318' ) // VDV
Local cCodVDV   := ""
Local nCntFor   := 0
If nRecVDV == 0 // Inclusão
	oModelVDV:SetOperation( MODEL_OPERATION_INSERT )
Else // Alteração
	VDV->(DbGoto(nRecVDV))
	oModelVDV:SetOperation( MODEL_OPERATION_UPDATE )
EndIf
If oModelVDV:Activate()
	If nRecVDV == 0 // Inclusão - Campos Default
		cCodVDV := GetSXENum("VDV","VDV_CODIGO") // Batizar o Codigo Sequencial do VDV
		ConfirmSx8()
		oModelVDV:SetValue( "VDVMASTER" , "VDV_FILIAL" , xFilial("VDV")                  ) // Filial
		oModelVDV:SetValue( "VDVMASTER" , "VDV_CODIGO" , cCodVDV                         ) // Codigo Sequencial do VDV
		oModelVDV:SetValue( "VDVMASTER" , "VDV_STATUS" , "1"                             ) // 1=Ativo / 0=Cancelado
		oModelVDV:SetValue( "VDVMASTER" , "VDV_DATMOV" , dDataBase                       ) // Data do Movimento
		oModelVDV:SetValue( "VDVMASTER" , "VDV_HORMOV" , val(substr(time(),1,2)+substr(time(),4,2)) ) // Hora Movimento
		oModelVDV:SetValue( "VDVMASTER" , "VDV_CODUSR" , __cUserID                       ) // Codigo do Usuário
	EndIf
	For nCntFor := 1 to len(aVDV)
		oModelVDV:SetValue( "VDVMASTER" , aVDV[nCntFor,1] , aVDV[nCntFor,2]              ) // Campos variaveis
	Next
	If ( lRet := oModelVDV:VldData() )
		if ( lRet := oModelVDV:CommitData() )
		EndIf
	EndIf
	oModelVDV:DeActivate()
	If lRet .and. nRecVDV == 0 // Inclusão
		nRecVDV := VDV->(RecNo())
	EndIf
EndIf
Return nRecVDV